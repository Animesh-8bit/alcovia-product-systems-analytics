# SQL

| Folder | What |
|---|---|
| [`kpis/`](kpis/README.md) | **One file per KPI**: 42 for P2 (one per row of `alcovia-gtm-kpis.xlsx`), 29 for P4 (one per row of the P4 KPI framework). Run with `./sql/kpis/run_kpis.sh`. |
| `00_helpers.sql` | Shared rules used by every query: settings and targets, period scaling, each lead's conversion state, revenue streams, ad actions. |
| `p2_gtm_tracker.old/`, `p4_student_dashboard.old/` | The earlier files, grouped by dashboard tab (the notes below). Run with `./sql/run_old.sh`. |

---

## Earlier files (grouped by dashboard tab)

One Postgres query per KPI in `alcovia-gtm-kpis.xlsx` (P2) and the P4 KPI framework, run against the reporting database in [`../db`](../db) (schemas `students`, `leads`, `events`, `ops`, `ads`, `revenue`). On the sample data they return the same numbers as the dashboards.

| File | KPIs |
|---|---|
| `00_helpers.sql` | Shared rules: settings and targets lookup, as-of date, months of target in a period, the period before, each lead's conversion state (from enrolments), revenue stream of each payment |
| **p2_gtm_tracker.old/** | |
| `01_revenue.sql` | Revenue vs target and the period before · each stream (full program, trial, workshops) vs its target and share · revenue by stream by month · unpaid invoices with colour |
| `02_signups_conversion.sql` | Conversions (full term paid), trials started, workshop seats vs target · students onboarded by month · trial-to-full renewal rate · trials ending in 30 days |
| `03_funnel.sql` | Funnel by entry path with the period before · share lost between steps · interview outcomes, lead sources, call show-up · workshop → program rate · days to decide |
| `04_leads_ageing.sql` | Open leads past 45 days · weekly ageing trend in 46–60 / 61–90 / 90+ day bands |
| `05_ads_and_actions.sql` | Cost per qualified lead · every ad with click rate, frequency, cost per result and Scale / Refresh / Drop / Watch with the reason · campaigns · action totals · one campaign by week |
| `06_workshops.sql` | Workshop break-even, ad spend per seat, families converted later |
| `07_landing_pages.sql` | Drop-off and load time per landing page, with the period before |
| **p4_student_dashboard.old/** | |
| `01_program_overview.sql` | Sessions held of planned, rating, on track, counted minutes, with change · delivery grid · ratings by item · weekly minutes and sleep |
| `02_cohort_review.sql` | All-student averages · every student with green / amber / red, needing attention first · alerts |
| `03_student_and_parent.sql` | One student: profile, subjects, weekly trend, soft skills, milestones · parent view |

## Run

```bash
./sql/run_old.sh                     # rebuild the database and run everything
```

Each file takes its period as psql variables, defaulting to the dashboards' sample views:

```bash
docker exec -w /sql/p2_gtm_tracker.old alcovia-db psql -U postgres -d alcovia \
  -v start_on=2027-02-01 -v end_on=2027-02-26 -f 01_revenue.sql          # P2, any period
docker exec -w /sql/p2_gtm_tracker.old alcovia-db psql -U postgres -d alcovia \
  -v campaign='Program: brand' -f 05_ads_and_actions.sql                  # P2, another campaign
docker exec -w /sql/p4_student_dashboard.old alcovia-db psql -U postgres -d alcovia \
  -v month=2027-08-01 -v student_id=S07 -f 03_student_and_parent.sql      # P4, another month or student
```

In Metabase the same queries become native questions, with `{{start_on}}` and `{{end_on}}` as filters.

## Rules the queries follow

- **Conversion** = the family paid for the full term: a full program payment, or a trial renewal. A family with only a trial payment is in the Trial state.
- **Days to decide** = first contact to first payment (trial or full); the trial months are not decision time.
- **Targets** scale with the period: each month counts the share of its days inside the period (1 Dec – 26 Feb = 2.93 months).
- **Ad actions**, in order: Ended (not running on the last day) → Drop (5+ leads and none qualified, or over the ceiling in the last 2 weeks and the 2 before) → Refresh (frequency 3+) → Scale (under the ceiling) → Watch.
- **On track** (P4) = syllabus done within 2 points of pace.

**Access:** the P2 revenue, ads, workshop and landing-page queries read `ads` / `revenue`, so they need `full_access`. The funnel, lead-ageing and all P4 queries run as `team_access` too.
