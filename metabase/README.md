# Metabase dashboards (built from the KPI SQL)

Metabase (open source, self-hosted) reading the reporting database. Every file in `sql/kpis/` is a saved question: 42 for the P2 GTM tracker, 65 for the P4 student dashboard (one per section of the 29 P4 files). All 107 run with no errors and return the same numbers as the SQL files.

| Dashboard | Tabs | Filters | Database connection |
|---|---|---|---|
| Alcovia GTM tracker | Overview · Revenue · Funnel · Campaigns · Actions | Period start, period end | `metabase_full` (role `full_access`) |
| Alcovia student dashboard | Day · Week · Month · Quarter · Roadmap | Month | `metabase_team` (role `team_access`: no ads or revenue) |

Screenshots: [`screenshots/`](screenshots). Definitions (cards, layout, SQL): [`export/`](export).

## Run it locally

```bash
# 1. Database (see db/README.md), on a shared network with Metabase
docker network create alcovia-net
docker network connect alcovia-net alcovia-db
./sql/kpis/run_kpis.sh > /dev/null          # loads schema, sample data and helpers

# 2. Metabase
docker run -d --name alcovia-metabase --network alcovia-net -p 3000:3000 metabase/metabase:v0.50.20

# 3. Questions and dashboards from the SQL files
python3 metabase/setup_metabase.py          # prints the two public dashboard links
```

`setup_metabase.py` reads test credentials from `metabase/.env` (not committed). Create it with `MB_ADMIN_EMAIL`, `MB_ADMIN_PASSWORD`, `MB_FULL_DB_PASSWORD` and `MB_TEAM_DB_PASSWORD`. It creates the two database logins, the admin user, both connections, the questions, both dashboards and a read-only public link for each. Run it again after changing a SQL file: it updates the questions in place.

How a SQL file becomes a question: psql lines (`\ir`, `\echo`) are dropped and `:'start_on'`, `:'end_on'`, `:'month'` become Metabase date filters `{{start_on}}`, `{{end_on}}`, `{{month}}`, wired to the dashboard filters.
