#!/usr/bin/env bash
# Build the static dashboards (GitHub Pages) from the reporting database.
# Runs export_p2.sql / export_p4.sql against the alcovia-db container and writes each dashboard's data/data.js.
# Usage, from the repo root: ./dashboards/build_static.sh
set -euo pipefail
cd "$(dirname "$0")"
for n in p2 p4; do
  docker cp "export_$n.sql" alcovia-db:/tmp/ >/dev/null
  docker exec alcovia-db psql -U postgres -d alcovia -At -v ON_ERROR_STOP=1 -f "/tmp/export_$n.sql" > "/tmp/alcovia_$n.json"
done
python3 - <<'PY'
import json
for n, folder, params in (("p2", "site/gtm-tracker", {"range": "last_3_months", "path": "All"}),
                          ("p4", "site/student-dashboard", {"month": "2027-09", "student": "S01"})):
    data = json.load(open(f"/tmp/alcovia_{n}.json"))
    with open(f"{folder}/data/data.js", "w") as f:
        f.write("// Exported from the reporting database by dashboards/build_static.sh (export_%s.sql). Sample data, made up for illustration.\n" % n)
        f.write("window.AX_DATA = " + json.dumps(data, ensure_ascii=False, separators=(",", ":")) + ";\n")
        f.write("window.AX_PARAMS = " + json.dumps(params) + ";\n")
    print(n, {k: len(v) for k, v in data.items()})
PY
