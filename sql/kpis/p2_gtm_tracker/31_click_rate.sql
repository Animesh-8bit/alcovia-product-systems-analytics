-- KPI 31: Click rate (CTR)
-- Definition : How often people who saw an ad clicked it, best to worst.
-- Formula    : Clicks ÷ impressions
-- Source     : Meta Ads
-- Target     : —
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT ad, campaign, type, impressions, clicks, ctr_pct
FROM p, ads.period_ads(p.s, p.e)
ORDER BY ctr_pct DESC;
