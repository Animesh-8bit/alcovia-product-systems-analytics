-- KPI 26: Where families came from
-- Definition : Intake split by source. Organic = form lead with no paid campaign tag.
-- Formula    : COUNT(leads) by source: Meta ads / organic form / workshop
-- Source     : ClickUp source + campaign tags
-- Target     : —
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT CASE source WHEN 'Paid' THEN 'Meta ads' WHEN 'Organic' THEN 'Organic (form, no ad)' ELSE 'Workshops' END AS source,
       COUNT(*) AS families,
       round(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()) AS share_pct
FROM leads.leads, p
WHERE created_on BETWEEN p.s AND p.e
GROUP BY 1 ORDER BY families DESC;
