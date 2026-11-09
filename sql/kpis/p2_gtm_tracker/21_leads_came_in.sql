-- KPI 21: Leads / families who came in
-- Definition : Website form leads plus workshop attendees in the period, by entry path.
-- Formula    : COUNT(leads) where created date in period, by entry path
-- Source     : n8n lead webhook → ClickUp; workshop attendance
-- Target     : —
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT entry_path,
       COUNT(*) FILTER (WHERE created_on BETWEEN p.s AND p.e)                               AS this_period,
       COUNT(*) FILTER (WHERE created_on BETWEEN ops.prev_start(p.s, p.e) AND p.s - 1)      AS period_before
FROM leads.leads, p
GROUP BY entry_path ORDER BY entry_path;
