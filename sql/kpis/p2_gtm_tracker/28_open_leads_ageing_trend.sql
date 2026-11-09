-- KPI 28: Open leads ageing trend
-- Definition : Each week, how many open leads were older than the target, by age band.
-- Formula    : For each week end W: COUNT(leads created ≤ W, not paid by W, not closed by W, W − created > 45), split 46–60 / 61–90 / 90+
-- Source     : ClickUp + enrolments
-- Target     : Falling to 0
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
weeks AS (
    SELECT w::date AS week, LEAST(w::date + 6, ops.as_of()) AS week_end
    FROM p, generate_series(date_trunc('week', p.s), p.e, interval '7 days') AS w
)
SELECT weeks.week, weeks.week_end,
       COUNT(*) FILTER (WHERE age BETWEEN ops.setting('days_to_decide') + 1 AND 60) AS days_46_60,
       COUNT(*) FILTER (WHERE age BETWEEN 61 AND 90)                                 AS days_61_90,
       COUNT(*) FILTER (WHERE age > 90)                                              AS over_90_days,
       COUNT(*) FILTER (WHERE age > ops.setting('days_to_decide'))                   AS total
FROM weeks
LEFT JOIN LATERAL (
    SELECT weeks.week_end - l.created_on AS age
    FROM leads.v_lead_state l
    WHERE l.created_on <= weeks.week_end
      AND (l.first_paid_on IS NULL OR l.first_paid_on > weeks.week_end)
      AND (l.closed_on IS NULL OR l.closed_on > weeks.week_end)
) open_leads ON true
GROUP BY weeks.week, weeks.week_end
ORDER BY weeks.week;
