# Alcovia: Product, Systems & Analytics Lead assignment

Solutions to the four problems in the assignment, with the technical deliverables behind them. Everything runs on **made-up sample data**: no figure here is Alcovia's.

**Live dashboards:** https://animesh-8bit.github.io/alcovia-product-systems-analytics/

| Problem | Solution | Built |
|---|---|---|
| **P1** App adoption, 2.15 → 30 min/day | [docs/05](docs/05-p1-solution-app-adoption.md): root cause, the shifts that change the daily habit, metrics, 12-week plan across PM, engineer and systems designer. The solution doc doubles as the mini PRDs for its features. | Bug evidence: [media/coin-tasks-bug.mp4](media/coin-tasks-bug.mp4) |
| **P2** GTM tracker | [docs/08](docs/08-p2-gtm-tracker.md): targets and rules, two entry paths, ad ceilings, Scale / Refresh / Drop, metric definitions, data flow | [GTM tracker](https://animesh-8bit.github.io/alcovia-product-systems-analytics/gtm-tracker/) · KPI dictionary [alcovia-gtm-kpis.xlsx](docs/alcovia-gtm-kpis.xlsx) · 42 KPI queries · Metabase dashboard |
| **P3** Delivery process | [docs/06](docs/06-p3-delivery-process.md): 8 stages with gates, RACI, one-week sprints, release rhythm, worked example | |
| **P4** Student dashboard | [docs/07](docs/07-p4-student-dashboard.md): KPI framework (quantity · quality · performance), chapter readiness score, notes → n8n + LLM → JSON, event system, timeline | [Student dashboard](https://animesh-8bit.github.io/alcovia-product-systems-analytics/student-dashboard/) · 29 KPI files · Metabase dashboard |

Context: [01 business model](docs/01-business-model-context.md) · [02 app features](docs/02-app-feature-breakdown.md) · [03 app walkthrough](docs/03-app-walkthrough-findings.md) · [04 problem statements](docs/04-problem-statements.md).

## Technical deliverables

| Folder | What | Start here |
|---|---|---|
| [`db/`](db) | Postgres reporting database: 6 schemas by domain (`students`, `leads`, `events`, `ops`, `ads`, `revenue`), 41 tables, roles that keep ads and revenue to product / data / analytics / leadership, sample data | [SCHEMA.md](db/SCHEMA.md) |
| [`sql/`](sql) | KPI queries, **one file per KPI**: 42 for P2 (one per row of the KPI workbook), 29 for P4 (one per row of the KPI framework), plus shared rules | [sql/kpis/README.md](sql/kpis/README.md) |
| [`metabase/`](metabase) | Both dashboards in Metabase, built from the SQL files by a script: 107 saved questions, tabs, period filters, team vs full access connections | [metabase/README.md](metabase/README.md) |
| [`dashboards/`](dashboards) | The static dashboards on GitHub Pages, fed by SQL exports from the same database | [dashboards/README.md](dashboards/README.md) |

On the sample data, the SQL files, the Metabase dashboards and the static dashboards all show the same numbers (for example P2, 1 Dec 2026 – 26 Feb 2027: revenue ₹60,51,822 at 138% of target, 21 conversions, ₹4,592 per qualified lead).

## Run it

Needs Docker and Python 3.

```bash
# Database
docker run -d --name alcovia-db -e POSTGRES_PASSWORD=alcovia -e POSTGRES_DB=alcovia \
  -p 5433:5432 -v "$PWD/db":/db postgres:16

# Load it and run all 71 KPI queries
./sql/kpis/run_kpis.sh
START_ON=2027-02-01 END_ON=2027-02-26 MONTH=2027-08-01 ./sql/kpis/run_kpis.sh   # another period

# Static dashboards from the database
./dashboards/build_static.sh && open dashboards/site/index.html

# Metabase (see metabase/README.md)
```

## Rules used throughout

- **Conversion** counts only when a family pays for the full term: the full program, or a 3-month trial that renews into it. A family on a trial is in the Trial state.
- **Two entry paths:** Meta ads → website form, and workshops. Both meet at the Ambition interview.
- **Targets** (₹15L a month: 4 full program, 6 trials, 60 workshop seats; ₹5,000 per qualified lead; ₹800 ad spend per workshop seat) live in one settings table, so they change without touching queries or dashboards.
