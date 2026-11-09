-- KPI 25: Ambition interview outcomes
-- Definition : Interview results split by who said no.
-- Formula    : COUNT by outcome: passed / rejected by Alcovia / dropped by family
-- Source     : ClickUp stage + reason
-- Target     : —
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT interview_outcome, COUNT(*) AS families,
       round(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()) AS share_pct
FROM leads.leads, p
WHERE created_on BETWEEN p.s AND p.e AND interview_outcome IS NOT NULL
GROUP BY interview_outcome ORDER BY families DESC;
