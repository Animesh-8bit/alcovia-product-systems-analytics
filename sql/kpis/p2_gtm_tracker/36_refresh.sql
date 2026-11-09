-- KPI 36: Refresh
-- Definition : Ads whose audience has seen them 3 or more times: new creative, same audience.
-- Formula    : See the rule in 00_helpers.sql (ads.period_ads)
-- Source     : Derived
-- Target     : —
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT ad, campaign, spend, frequency, results, cost_per_result, reason
FROM p, ads.period_ads(p.s, p.e)
WHERE action = 'Refresh'
ORDER BY spend DESC;
