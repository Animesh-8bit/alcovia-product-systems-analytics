-- KPI 22: Funnel step count
-- Definition : Families from the period's intake who reached each step, by entry path.
-- Formula    : COUNT(leads in intake) where the step's date is filled
-- Source     : ClickUp stage dates + enrolments
-- Target     : —
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
paths AS (SELECT unnest(ARRAY['All', 'Ads', 'Workshop']) AS path)
SELECT paths.path,
       COUNT(l.lead_id)          AS came_in,
       COUNT(l.qualified_on)     AS qualified_or_nurture,
       COUNT(l.call_booked_on)   AS call_booked,
       COUNT(l.call_attended_on) AS call_held,
       COUNT(l.interview_on)     AS ambition_interview,
       COUNT(l.architect_on)     AS architect_session,
       COUNT(l.first_paid_on)    AS paid_trial_or_full,
       COUNT(*) FILTER (WHERE l.first_plan = 'Trial') AS of_which_trial,
       COUNT(l.converted_on)     AS converted
FROM paths CROSS JOIN p
LEFT JOIN leads.v_lead_state l ON (paths.path = 'All' OR l.entry_path = paths.path) AND l.created_on BETWEEN p.s AND p.e
GROUP BY paths.path ORDER BY paths.path;
