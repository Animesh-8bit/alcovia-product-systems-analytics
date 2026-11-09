-- KPI 37: Drop
-- Definition : Ads too expensive for 2 weeks running, or bringing leads and no good fits: switch off.
-- Formula    : See the rule in 00_helpers.sql (ads.period_ads)
-- Source     : Derived
-- Target     : —
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT ad, campaign, spend, frequency, results, cost_per_result, reason
FROM p, ads.period_ads(p.s, p.e)
WHERE action = 'Drop'
ORDER BY spend DESC;
