# Static dashboards (GitHub Pages)

[`site/`](site) is the published site: a landing page plus the P2 GTM tracker and P4 student dashboard as plain HTML that runs in any browser, no server or login.

Their data comes from the reporting database: `build_static.sh` runs [`export_p2.sql`](export_p2.sql) and [`export_p4.sql`](export_p4.sql) against Postgres and writes each dashboard's `data/data.js`. On the sample data the static dashboards show the same numbers as the SQL KPI files and the Metabase dashboards.

```bash
./dashboards/build_static.sh      # needs the alcovia-db container (db/README.md)
open dashboards/site/index.html
```
