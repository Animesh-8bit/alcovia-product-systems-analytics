-- KPI 23: Share lost between steps
-- Definition : How many families each step loses (both paths).
-- Formula    : 1 − (count at step ÷ count at the step before)
-- Source     : ClickUp + enrolments
-- Target     : —
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
c AS (SELECT l.* FROM leads.v_lead_state l, p WHERE l.created_on BETWEEN p.s AND p.e),
steps(n, step, families) AS (
    SELECT 1, 'Came in', COUNT(*) FROM c UNION ALL
    SELECT 2, 'Qualified or in nurture', COUNT(qualified_on) FROM c UNION ALL
    SELECT 3, 'Ambition interview', COUNT(interview_on) FROM c UNION ALL
    SELECT 4, 'Architect session (Leadership)', COUNT(architect_on) FROM c UNION ALL
    SELECT 5, 'Paid (trial or full)', COUNT(first_paid_on) FROM c UNION ALL
    SELECT 6, 'Converted: full term paid', COUNT(converted_on) FROM c)
SELECT step, families,
       round(100 * (1 - families::numeric / NULLIF(LAG(families) OVER (ORDER BY n), 0))) AS lost_pct
FROM steps ORDER BY n;
