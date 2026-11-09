-- KPI 20: Days to decide
-- Definition : Average time from first contact to first payment (trial or full).
-- Formula    : AVERAGE(first payment date − lead created date) for families who paid in the period
-- Source     : ClickUp + enrolments
-- Target     : 45 days or fewer
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT round(AVG(first_paid_on - created_on)) AS days_to_decide,
       COUNT(*)                               AS families_paid,
       ops.setting('days_to_decide')          AS target_days
FROM leads.v_lead_state, p
WHERE first_paid_on BETWEEN p.s AND p.e;
