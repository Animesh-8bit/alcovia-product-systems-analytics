# KPI queries: one file per KPI

- **P2 GTM tracker:** one file per row of `alcovia-gtm-kpis.xlsx` (42). The workbook's "SQL file" column points here.
- **P4 student dashboard:** one file per row of the P4 KPI framework (29). Each file has a query for quantity (did Alcovia conduct it?), quality (did they like it?) and performance (how did they perform?), where the framework defines one.

Each file starts with the KPI's definition, formula, source, target and who can run it. Shared rules (conversion, period scaling, ad actions) live in [`../00_helpers.sql`](../00_helpers.sql).

## Run

```bash
./sql/kpis/run_kpis.sh                                                   # rebuild the database, run all 71
START_ON=2027-02-01 END_ON=2027-02-26 MONTH=2027-08-01 ./sql/kpis/run_kpis.sh   # another period / month
docker exec -w /sql/kpis/p2_gtm_tracker alcovia-db psql -U postgres -d alcovia -f 12_conversions.sql   # one KPI
```

Defaults: P2 period 1 Dec 2026 – 26 Feb 2027 (the dashboard's "Last 3 months"), P4 month September 2027 (quarter-level items use Jul–Sep).

## P2: GTM tracker

| # | File | KPI | Access |
|---|---|---|---|
| 01 | [01_revenue_collected.sql](p2_gtm_tracker/01_revenue_collected.sql) | Revenue collected | Restricted |
| 02 | [02_revenue_vs_target.sql](p2_gtm_tracker/02_revenue_vs_target.sql) | Revenue vs target % | Restricted |
| 03 | [03_revenue_change_vs_before.sql](p2_gtm_tracker/03_revenue_change_vs_before.sql) | Revenue change vs before | Restricted |
| 04 | [04_full_program_revenue.sql](p2_gtm_tracker/04_full_program_revenue.sql) | Full program revenue | Restricted |
| 05 | [05_trial_revenue.sql](p2_gtm_tracker/05_trial_revenue.sql) | Trial revenue | Restricted |
| 06 | [06_workshop_revenue.sql](p2_gtm_tracker/06_workshop_revenue.sql) | Workshop revenue | Restricted |
| 07 | [07_stream_vs_target.sql](p2_gtm_tracker/07_stream_vs_target.sql) | Stream vs target % | Restricted |
| 08 | [08_stream_share_of_revenue.sql](p2_gtm_tracker/08_stream_share_of_revenue.sql) | Stream share of revenue | Restricted |
| 09 | [09_workshop_share_of_revenue.sql](p2_gtm_tracker/09_workshop_share_of_revenue.sql) | Workshop share of revenue | Restricted |
| 10 | [10_unpaid_invoices.sql](p2_gtm_tracker/10_unpaid_invoices.sql) | Unpaid invoices (amount, count) | Restricted |
| 11 | [11_days_unpaid.sql](p2_gtm_tracker/11_days_unpaid.sql) | Days unpaid | Restricted |
| 12 | [12_conversions.sql](p2_gtm_tracker/12_conversions.sql) | Conversions | Restricted |
| 13 | [13_trials_started.sql](p2_gtm_tracker/13_trials_started.sql) | Trials started | Restricted |
| 14 | [14_workshop_seats_sold.sql](p2_gtm_tracker/14_workshop_seats_sold.sql) | Workshop seats sold | Restricted |
| 15 | [15_students_onboarded_by_month.sql](p2_gtm_tracker/15_students_onboarded_by_month.sql) | Students onboarded (by month) | Restricted |
| 16 | [16_trial_renewal_rate.sql](p2_gtm_tracker/16_trial_renewal_rate.sql) | Trial-to-full renewal rate | Everyone |
| 17 | [17_trials_ending_30_days.sql](p2_gtm_tracker/17_trials_ending_30_days.sql) | Trials ending in 30 days | Everyone |
| 18 | [18_workshop_to_program_rate.sql](p2_gtm_tracker/18_workshop_to_program_rate.sql) | Workshop → program rate | Everyone |
| 19 | [19_program_conversion_pct.sql](p2_gtm_tracker/19_program_conversion_pct.sql) | Program conversion % | Everyone |
| 20 | [20_days_to_decide.sql](p2_gtm_tracker/20_days_to_decide.sql) | Days to decide | Everyone |
| 21 | [21_leads_came_in.sql](p2_gtm_tracker/21_leads_came_in.sql) | Leads / families who came in | Everyone |
| 22 | [22_funnel_step_count.sql](p2_gtm_tracker/22_funnel_step_count.sql) | Funnel step count | Everyone |
| 23 | [23_share_lost_between_steps.sql](p2_gtm_tracker/23_share_lost_between_steps.sql) | Share lost between steps | Everyone |
| 24 | [24_call_show_up_rate.sql](p2_gtm_tracker/24_call_show_up_rate.sql) | Discovery call show-up rate | Everyone |
| 25 | [25_interview_outcomes.sql](p2_gtm_tracker/25_interview_outcomes.sql) | Ambition interview outcomes | Everyone |
| 26 | [26_where_families_came_from.sql](p2_gtm_tracker/26_where_families_came_from.sql) | Where families came from | Everyone |
| 27 | [27_open_leads_past_target.sql](p2_gtm_tracker/27_open_leads_past_target.sql) | Open leads past target | Everyone |
| 28 | [28_open_leads_ageing_trend.sql](p2_gtm_tracker/28_open_leads_ageing_trend.sql) | Open leads ageing trend | Everyone |
| 29 | [29_cost_per_qualified_lead.sql](p2_gtm_tracker/29_cost_per_qualified_lead.sql) | Cost per qualified lead | Restricted |
| 30 | [30_spend.sql](p2_gtm_tracker/30_spend.sql) | Spend | Restricted |
| 31 | [31_click_rate.sql](p2_gtm_tracker/31_click_rate.sql) | Click rate (CTR) | Restricted |
| 32 | [32_frequency.sql](p2_gtm_tracker/32_frequency.sql) | Frequency | Restricted |
| 33 | [33_results.sql](p2_gtm_tracker/33_results.sql) | Results | Restricted |
| 34 | [34_cost_per_result.sql](p2_gtm_tracker/34_cost_per_result.sql) | Cost per result | Restricted |
| 35 | [35_scale.sql](p2_gtm_tracker/35_scale.sql) | Scale | Restricted |
| 36 | [36_refresh.sql](p2_gtm_tracker/36_refresh.sql) | Refresh | Restricted |
| 37 | [37_drop.sql](p2_gtm_tracker/37_drop.sql) | Drop | Restricted |
| 38 | [38_watch.sql](p2_gtm_tracker/38_watch.sql) | Watch | Restricted |
| 39 | [39_ad_spend_per_workshop_seat.sql](p2_gtm_tracker/39_ad_spend_per_workshop_seat.sql) | Ad spend per workshop seat | Restricted |
| 40 | [40_workshop_break_even.sql](p2_gtm_tracker/40_workshop_break_even.sql) | Workshop break-even | Restricted |
| 41 | [41_landing_page_dropoff.sql](p2_gtm_tracker/41_landing_page_dropoff.sql) | Landing-page drop-off | Restricted |
| 42 | [42_load_time.sql](p2_gtm_tracker/42_load_time.sql) | Load time | Restricted |

Restricted = needs `full_access` (reads `ads` or `revenue`). Everyone = also runs as `team_access`.

## P4: student dashboard

| # | File | Item | Level |
|---|---|---|---|
| 01 | [01_timetable_management.sql](p4_student_dashboard/01_timetable_management.sql) | Timetable management | Day |
| 02 | [02_daily_quiz.sql](p4_student_dashboard/02_daily_quiz.sql) | Daily 8 PM quiz | Day |
| 03 | [03_focus_time.sql](p4_student_dashboard/03_focus_time.sql) | Focus time | Day |
| 04 | [04_active_minutes.sql](p4_student_dashboard/04_active_minutes.sql) | Active minutes | Day |
| 05 | [05_sleep.sql](p4_student_dashboard/05_sleep.sql) | Active recovery (sleep) | Day |
| 06 | [06_weekly_advisor_session.sql](p4_student_dashboard/06_weekly_advisor_session.sql) | Weekly advisor session | Week |
| 07 | [07_score_targets.sql](p4_student_dashboard/07_score_targets.sql) | Score targets (Formative, unit test, half-yearly) | Week |
| 08 | [08_time_management.sql](p4_student_dashboard/08_time_management.sql) | Time management | Week |
| 09 | [09_syllabus_completion.sql](p4_student_dashboard/09_syllabus_completion.sql) | Syllabus completion | Week |
| 10 | [10_rigour_of_completion.sql](p4_student_dashboard/10_rigour_of_completion.sql) | Rigour of completion | Week |
| 11 | [11_monthly_sprints.sql](p4_student_dashboard/11_monthly_sprints.sql) | Monthly sprints (missed timelines) | Week |
| 12 | [12_advisor_inputs.sql](p4_student_dashboard/12_advisor_inputs.sql) | Advisor inputs | Week |
| 13 | [13_career_workshops.sql](p4_student_dashboard/13_career_workshops.sql) | Workshop 1 & 2 (career discovery) | Month |
| 14 | [14_pod_session.sql](p4_student_dashboard/14_pod_session.sql) | Pod session | Month |
| 15 | [15_peer_session.sql](p4_student_dashboard/15_peer_session.sql) | Peer session | Month |
| 16 | [16_mentor_call.sql](p4_student_dashboard/16_mentor_call.sql) | Mentor call | Month |
| 17 | [17_personal_branding.sql](p4_student_dashboard/17_personal_branding.sql) | Personal branding | Month |
| 18 | [18_podcast_shoot.sql](p4_student_dashboard/18_podcast_shoot.sql) | Podcast shoot | Quarter |
| 19 | [19_competition_prep.sql](p4_student_dashboard/19_competition_prep.sql) | Competition prep | Quarter |
| 20 | [20_parent_child_workshop.sql](p4_student_dashboard/20_parent_child_workshop.sql) | Parent–child workshop | Quarter |
| 21 | [21_out_of_city_experience.sql](p4_student_dashboard/21_out_of_city_experience.sql) | Out-of-city experience | Quarter |
| 22 | [22_theme_social_work.sql](p4_student_dashboard/22_theme_social_work.sql) | Theme: social work | Quarter |
| 23 | [23_theme_entrepreneurship.sql](p4_student_dashboard/23_theme_entrepreneurship.sql) | Theme: entrepreneurship | Quarter |
| 24 | [24_summer_program_applications.sql](p4_student_dashboard/24_summer_program_applications.sql) | Summer program applications | Quarter |
| 25 | [25_career_roadmap.sql](p4_student_dashboard/25_career_roadmap.sql) | Career roadmap | Roadmap |
| 26 | [26_personal_roadmap.sql](p4_student_dashboard/26_personal_roadmap.sql) | Personal roadmap | Roadmap |
| 27 | [27_academic_roadmap.sql](p4_student_dashboard/27_academic_roadmap.sql) | Academic roadmap | Roadmap |
| 28 | [28_syllabus_on_track.sql](p4_student_dashboard/28_syllabus_on_track.sql) | Syllabus completion (roadmap) | Roadmap |
| 29 | [29_rigour_adherence_roadmap.sql](p4_student_dashboard/29_rigour_adherence_roadmap.sql) | Rigour of completion (roadmap) | Roadmap |

All P4 files run as `team_access` too.

**In line with the dashboard.** Where the P4 dashboard has a figure, the KPI file reads the same monthly summary (`students.student_month`, `events.delivery_month`, `students.subject_progress`, `students.soft_skill_scores`, `students.milestones`), so the numbers match it exactly: counted minutes, quiz participation and accuracy, sleep, active days, task completion and deadline adherence, readiness, syllabus vs pace, held vs planned, attendance and ratings per event type. P2 files match the GTM dashboard exactly. Raw tables are read only for KPIs the dashboard doesn't show.

The raw tables they read (app sessions, quiz attempts, health, timetable, tasks, targets, exams, chapters, events, attendance, ratings, follow-ups, content) hold made-up rows for the 20 sample students, drawn from their monthly figures. In production n8n fills them.

Older files grouped by dashboard tab are kept in `../p2_gtm_tracker.old/` and `../p4_student_dashboard.old/` (`../run_old.sh` runs them).
