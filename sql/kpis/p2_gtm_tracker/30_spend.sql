-- KPI 30: Spend
-- Definition : Meta ad spend in the period, per campaign and per ad.
-- Formula    : SUM(spend) in period, per ad or campaign
-- Source     : Meta Ads
-- Target     : —
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT campaign, ad, spend, SUM(spend) OVER (PARTITION BY campaign) AS campaign_spend
FROM p, ads.period_ads(p.s, p.e)
ORDER BY campaign_spend DESC, spend DESC;
