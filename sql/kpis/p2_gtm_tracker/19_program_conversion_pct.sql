-- KPI 19: Program conversion %
-- Definition : Share of families who came in during the period and converted.
-- Formula    : Converted ÷ families who came in during the period
-- Source     : ClickUp + enrolments
-- Target     : —
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
paths AS (SELECT unnest(ARRAY['All', 'Ads', 'Workshop']) AS path)
SELECT paths.path, COUNT(l.lead_id) AS came_in, COUNT(l.converted_on) AS converted,
       COUNT(*) FILTER (WHERE l.state = 'Trial') AS still_in_trial,
       round(100.0 * COUNT(l.converted_on) / NULLIF(COUNT(l.lead_id), 0), 1) AS conversion_pct
FROM paths CROSS JOIN p
LEFT JOIN leads.v_lead_state l ON (paths.path = 'All' OR l.entry_path = paths.path) AND l.created_on BETWEEN p.s AND p.e
GROUP BY paths.path ORDER BY paths.path;
