"""Build the P2 GTM tracker and P4 student dashboard in Metabase from the KPI SQL files.

Every file in sql/kpis becomes a saved native question (P4 files become one question per section),
then both dashboards are laid out with tabs and period filters, made public (read-only link), and
their definitions exported to metabase/export/.

Usage (from the repo root, Metabase on http://localhost:3000, database loaded):
    python3 metabase/setup_metabase.py
Credentials come from metabase/.env (local test values, not committed).
"""
import json
import re
import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MB = "http://localhost:3000"
ENV = dict(l.split("=", 1) for l in (ROOT / "metabase/.env").read_text().split() if "=" in l)
DEFAULTS = {"start_on": "2026-12-01", "end_on": "2027-02-26", "month": "2027-09-01"}
TAG_NAMES = {"start_on": "Period start", "end_on": "Period end", "month": "Month"}
session = None


def api(method, path, body=None):
    req = urllib.request.Request(MB + path, method=method, data=json.dumps(body).encode() if body is not None else None,
                                 headers={"Content-Type": "application/json", **({"X-Metabase-Session": session} if session else {})})
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            raw = r.read()
            return json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        raise SystemExit(f"{method} {path} failed: {e.code} {e.read()[:400]!r}")


# ---------------------------------------------------------------- database logins
def psql(sql):
    subprocess.run(["docker", "exec", "-i", "alcovia-db", "psql", "-U", "postgres", "-d", "alcovia", "-v", "ON_ERROR_STOP=1", "-q"],
                   input=sql.encode(), check=True)


psql(f"""
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metabase_full') THEN CREATE ROLE metabase_full LOGIN IN ROLE full_access; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metabase_team') THEN CREATE ROLE metabase_team LOGIN IN ROLE team_access; END IF;
END $$;
ALTER ROLE metabase_full PASSWORD '{ENV["MB_FULL_DB_PASSWORD"]}';
ALTER ROLE metabase_team PASSWORD '{ENV["MB_TEAM_DB_PASSWORD"]}';
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ops, ads, leads, students, events, revenue TO full_access;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ops, leads, students, events TO team_access;
""")

# ---------------------------------------------------------------- setup and login
for _ in range(120):
    try:
        if api("GET", "/api/health").get("status") == "ok":
            break
    except Exception:
        pass
    time.sleep(2)
props = api("GET", "/api/session/properties")
if props.get("setup-token") and not props.get("has-user-setup"):
    session = api("POST", "/api/setup", {
        "token": props["setup-token"],
        "user": {"email": ENV["MB_ADMIN_EMAIL"], "password": ENV["MB_ADMIN_PASSWORD"], "first_name": "Alcovia", "last_name": "Admin", "site_name": "Alcovia reporting"},
        "prefs": {"site_name": "Alcovia reporting", "allow_tracking": False}})["id"]
else:
    session = api("POST", "/api/session", {"username": ENV["MB_ADMIN_EMAIL"], "password": ENV["MB_ADMIN_PASSWORD"]})["id"]
api("PUT", "/api/setting/enable-public-sharing", {"value": True})


def database(name, user, password):
    for d in api("GET", "/api/database")["data"]:
        if d["name"] == name:
            return d["id"]
    return api("POST", "/api/database", {"engine": "postgres", "name": name, "is_full_sync": True, "details": {
        "host": "alcovia-db", "port": 5432, "dbname": "alcovia", "user": user, "password": password, "ssl": False}})["id"]


DB_FULL = database("Alcovia reporting (full access)", "metabase_full", ENV["MB_FULL_DB_PASSWORD"])
DB_TEAM = database("Alcovia reporting (team access)", "metabase_team", ENV["MB_TEAM_DB_PASSWORD"])


def collection(name):
    for c in api("GET", "/api/collection"):
        if c.get("name") == name and not c.get("archived"):
            return c["id"]
    return api("POST", "/api/collection", {"name": name, "color": "#08261E"})["id"]


# ---------------------------------------------------------------- questions from the SQL files
def to_metabase(sql):
    """psql file → Metabase native SQL: drop psql commands, turn :'var' into {{var}}."""
    lines = [l for l in sql.splitlines() if not l.startswith("\\")]
    q = "\n".join(lines).strip()
    for v in DEFAULTS:
        q = q.replace(f":'{v}'", "{{" + v + "}}")
    return q.rstrip(";")


def tags(q):
    return {v: {"id": f"tag-{v}", "name": v, "display-name": TAG_NAMES[v], "type": "date", "default": DEFAULTS[v], "required": True}
            for v in DEFAULTS if "{{" + v + "}}" in q}


def split_sections(text):
    """P4 files: one question per \\echo '== title ==' section. P2 files: one question."""
    parts = re.split(r"^\\echo '== (.*) =='$", text, flags=re.M)
    if len(parts) == 1:
        return [(None, text)]
    return [(parts[i], parts[i + 1]) for i in range(1, len(parts), 2)]


def card(name, sql, db, coll, display="table", viz=None):
    q = to_metabase(sql)
    body = {"name": name, "collection_id": coll, "display": display, "visualization_settings": viz or {},
            "dataset_query": {"type": "native", "database": db, "native": {"query": q, "template-tags": tags(q)}}}
    for c in api("GET", f"/api/collection/{coll}/items?models=card")["data"]:
        if c["name"] == name:
            api("PUT", f"/api/card/{c['id']}", body)
            return c["id"], list(tags(q))
    return api("POST", "/api/card", body)["id"], list(tags(q))


def bar(dim, metrics, stacked=False, row=False):
    v = {"graph.dimensions": [dim], "graph.metrics": metrics, "graph.show_values": True}
    if stacked:
        v["stackable.stack_type"] = "stacked"
    return ("row" if row else "bar", v)


SCALAR = lambda f: ("scalar", {"scalar.field": f})

# P2: tab, size, display per KPI number
P2 = {
    "Overview": [(1, 6, 3, SCALAR("revenue_collected")), (2, 6, 3, SCALAR("pct_of_target")), (3, 6, 3, SCALAR("change_pct")), (12, 6, 3, SCALAR("this_period")),
                 (13, 6, 3, SCALAR("this_period")), (14, 6, 3, SCALAR("this_period")), (18, 6, 3, SCALAR("workshop_to_program_pct")), (20, 6, 3, SCALAR("days_to_decide")),
                 (7, 12, 6, bar("stream", ["revenue", "target"])), (15, 12, 6, bar("month", ["full_program", "trial"], stacked=True)),
                 (29, 12, 4, ("table", {})), (10, 12, 4, ("table", {}))],
    "Revenue": [(4, 8, 3, SCALAR("revenue")), (5, 8, 3, SCALAR("revenue")), (6, 8, 3, SCALAR("revenue")),
                (8, 8, 6, ("pie", {"pie.dimension": "stream", "pie.metric": "revenue"})), (9, 8, 3, SCALAR("workshop_share_pct")), (16, 8, 3, SCALAR("renewal_rate_pct")),
                (40, 16, 6, bar("held_on", ["break_even"])), (39, 12, 5, ("table", {})), (11, 12, 5, ("table", {})), (17, 12, 5, ("table", {}))],
    "Funnel": [(23, 12, 7, ("funnel", {"funnel.dimension": "step", "funnel.metric": "families"})), (22, 12, 7, ("table", {})),
               (21, 8, 5, bar("entry_path", ["this_period", "period_before"])), (25, 8, 5, ("pie", {"pie.dimension": "interview_outcome", "pie.metric": "families"})),
               (26, 8, 5, ("pie", {"pie.dimension": "source", "pie.metric": "families"})), (24, 6, 3, SCALAR("show_up_pct")), (19, 18, 3, ("table", {})),
               (28, 12, 6, bar("week", ["days_46_60", "days_61_90", "over_90_days"], stacked=True)), (27, 12, 6, ("table", {}))],
    "Campaigns": [(31, 12, 7, bar("ad", ["ctr_pct"], row=True)), (34, 12, 7, ("table", {})), (30, 12, 6, ("table", {})), (32, 12, 6, ("table", {})),
                  (33, 12, 6, ("table", {})), (41, 12, 5, bar("page", ["dropoff_pct", "dropoff_pct_before"])), (42, 12, 5, ("table", {}))],
    "Actions": [(35, 12, 5, ("table", {})), (36, 12, 5, ("table", {})), (37, 24, 5, ("table", {})), (38, 24, 4, ("table", {}))],
}
# P4: tab per level; charts for a few sections, tables elsewhere
P4_TABS = {"Day": range(1, 6), "Week": range(6, 13), "Month": range(13, 18), "Quarter": range(18, 25), "Roadmap": range(25, 30)}
P4_VIZ = {
    "students with a timetable updated, per week": bar("week", ["pct"]),
    "accuracy by topic": bar("topic", ["accuracy_pct"], row=True),
    "soft skills, first vs latest workshop": bar("skill", ["first", "latest"]),
    "milestones hit, by month": bar("month", ["hit", "due"]),
    "personal milestones hit, by month": bar("month", ["hit", "due"]),
    "actual vs target per exam": bar("exam_type", ["pct_at_or_above"]),
    "On track per subject": bar("subject", ["pct"], row=True),
    "outcomes": ("pie", {"pie.dimension": "outcome", "pie.metric": "entries"}),
}


def layout(dash_id, tabs, params):
    """tabs: [(tab name, [(card_id, tag names, w, h)])] → dashcards placed left to right on a 24-wide grid."""
    dashcards, tab_defs, n = [], [], 0
    for t_i, (tab, cards) in enumerate(tabs, 1):
        tab_defs.append({"id": -t_i, "name": tab})
        row = col = row_h = 0
        for card_id, card_tags, w, h in cards:
            if col + w > 24:
                row, col, row_h = row + row_h, 0, 0
            n += 1
            dashcards.append({"id": -n, "card_id": card_id, "dashboard_tab_id": -t_i, "row": row, "col": col, "size_x": w, "size_y": h,
                              "visualization_settings": {}, "parameter_mappings": [
                                  {"parameter_id": f"p-{v}", "card_id": card_id, "target": ["variable", ["template-tag", v]]} for v in card_tags]})
            col += w
            row_h = max(row_h, h)
    api("PUT", f"/api/dashboard/{dash_id}", {"tabs": tab_defs, "dashcards": dashcards, "parameters": params})


def dashboard(name, coll, description):
    for d in api("GET", f"/api/collection/{coll}/items?models=dashboard")["data"]:
        if d["name"] == name:
            return d["id"]
    return api("POST", "/api/dashboard", {"name": name, "collection_id": coll, "description": description})["id"]


def param(v):
    return {"id": f"p-{v}", "name": TAG_NAMES[v], "slug": v, "type": "date/single", "default": DEFAULTS[v]}


# P2
c2 = collection("P2 GTM tracker")
files2 = {int(f.name[:2]): f for f in sorted((ROOT / "sql/kpis/p2_gtm_tracker").glob("*.sql"))}
tabs2 = []
for tab, items in P2.items():
    cards = []
    for num, w, h, (display, viz) in items:
        f = files2[num]
        title = f.read_text().splitlines()[0].split(": ", 1)[1]
        cid, t = card(f"{num:02d} · {title}", f.read_text(), DB_FULL, c2, display, viz)
        cards.append((cid, t, w, h))
    tabs2.append((tab, cards))
d2 = dashboard("Alcovia GTM tracker", c2, "P2 · sample data, made up for illustration. Every card is a KPI file from sql/kpis/p2_gtm_tracker.")
layout(d2, tabs2, [param("start_on"), param("end_on")])

# P4
c4 = collection("P4 student dashboard")
files4 = {int(f.name[:2]): f for f in sorted((ROOT / "sql/kpis/p4_student_dashboard").glob("*.sql"))}
tabs4 = []
for tab, nums in P4_TABS.items():
    cards = []
    for num in nums:
        text = files4[num].read_text()
        item = re.match(r"-- P4 KPI \d+: (.*)  \(", text.splitlines()[0]).group(1)
        for title, sql in split_sections(text):
            short = title.split(": ", 1)[-1]
            display, viz = next((v for k, v in P4_VIZ.items() if k.lower() in title.lower()), ("table", {}))
            cid, t = card(f"{num:02d} · {item} · {title}", "\n".join(l for l in text.splitlines() if l.startswith("--")) + "\n" + sql,
                          DB_TEAM, c4, display, viz)
            cards.append((cid, t, 12, 6 if display != "table" or "per " in title.lower() or "by student" in title.lower() else 4))  # two per row
    tabs4.append((tab, cards))
d4 = dashboard("Alcovia student dashboard", c4, "P4 · sample data, made up for illustration. Every card is a section of a KPI file from sql/kpis/p4_student_dashboard.")
layout(d4, tabs4, [param("month")])

# ---------------------------------------------------------------- public links and export
links = {}
for name, d in (("P2 GTM tracker", d2), ("P4 student dashboard", d4)):
    uuid = api("POST", f"/api/dashboard/{d}/public_link")["uuid"]
    links[name] = f"{MB}/public/dashboard/{uuid}"
out = ROOT / "metabase/export"
out.mkdir(exist_ok=True)
for name, d in (("p2_gtm_tracker", d2), ("p4_student_dashboard", d4)):
    full = api("GET", f"/api/dashboard/{d}")
    keep = {"name": full["name"], "description": full["description"], "parameters": full["parameters"], "tabs": full.get("tabs"),
            "cards": [{"tab": dc.get("dashboard_tab_id"), "row": dc["row"], "col": dc["col"], "size_x": dc["size_x"], "size_y": dc["size_y"],
                       "name": dc["card"]["name"], "display": dc["card"]["display"], "visualization_settings": dc["card"]["visualization_settings"],
                       "sql": dc["card"]["dataset_query"]["native"]["query"]} for dc in full["dashcards"]]}
    (out / f"{name}.json").write_text(json.dumps(keep, indent=2, ensure_ascii=False))
print(json.dumps({"dashboards": {"P2": d2, "P4": d4}, "public_links": links}, indent=2))
