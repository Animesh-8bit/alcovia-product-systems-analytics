-- KPI 29: Cost per qualified lead
-- Definition : Program ad spend per qualified lead, with the period before.
-- Formula    : Program ad spend in period ÷ paid-ad leads qualified in period
-- Source     : Meta Ads + ClickUp
-- Target     : ₹5,000 or less
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
win(name, s, e) AS (SELECT 'This period', p.s, p.e FROM p UNION ALL SELECT 'Period before', ops.prev_start(p.s, p.e), p.s - 1 FROM p),
spend AS (SELECT win.name, SUM(d.spend) AS program_spend
          FROM win JOIN ads.ad_daily d ON d.day BETWEEN win.s AND win.e
          JOIN ads.ads a USING (ad_id) JOIN ads.campaigns c USING (campaign_id)
          WHERE c.campaign_type = 'Program' GROUP BY win.name),
qual AS (SELECT win.name, COUNT(l.lead_id) AS qualified_leads
         FROM win LEFT JOIN leads.leads l ON l.source = 'Paid' AND l.qualified_on BETWEEN win.s AND win.e GROUP BY win.name)
SELECT name, program_spend, qualified_leads,
       round(program_spend / NULLIF(qualified_leads, 0)) AS cost_per_qualified_lead,
       ads.target('cpql') AS ceiling
FROM spend JOIN qual USING (name) ORDER BY name DESC;
