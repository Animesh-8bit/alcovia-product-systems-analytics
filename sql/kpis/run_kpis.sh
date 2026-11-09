#!/usr/bin/env bash
# Rebuild the reporting database and run every KPI file (42 for P2, 29 for P4).
# Needs the alcovia-db container from db/README.md. Usage, from the repo root: ./sql/kpis/run_kpis.sh
# Change the period: START_ON=2027-02-01 END_ON=2027-02-26 MONTH=2027-08-01 ./sql/kpis/run_kpis.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
docker cp db/. alcovia-db:/db >/dev/null
docker exec alcovia-db rm -rf /sql && docker cp sql/. alcovia-db:/sql >/dev/null
psql() { docker exec -w "${WD:-/}" alcovia-db psql -U postgres -d alcovia -v ON_ERROR_STOP=1 "$@"; }
psql -q -c "DROP SCHEMA IF EXISTS students, leads, ads, revenue, events, ops CASCADE;" 2>/dev/null
psql -q -f /db/schema.sql
psql -q -f /db/seed.sql
psql -q -f /sql/00_helpers.sql
vars=()
[ -n "${START_ON:-}" ] && vars+=(-v "start_on=$START_ON")
[ -n "${END_ON:-}" ] && vars+=(-v "end_on=$END_ON")
[ -n "${MONTH:-}" ] && vars+=(-v "month=$MONTH")
for f in sql/kpis/p2_gtm_tracker/*.sql; do echo "######## $f"; WD=/sql/kpis/p2_gtm_tracker psql ${vars[@]+"${vars[@]}"} -f "$(basename "$f")"; done
for f in sql/kpis/p4_student_dashboard/*.sql; do echo "######## $f"; WD=/sql/kpis/p4_student_dashboard psql ${vars[@]+"${vars[@]}"} -f "$(basename "$f")"; done
