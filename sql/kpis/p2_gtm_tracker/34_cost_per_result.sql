-- KPI 34: Cost per result
-- Definition : Spend per qualified lead (program) or per seat (workshop), per ad and per campaign.
-- Formula    : Spend ÷ results
-- Source     : Meta Ads + ClickUp / Razorpay
-- Target     : ₹5,000 per lead; ₹800 per seat
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT campaign, ad, spend, results, cost_per_result, ceiling,
       round(SUM(spend) OVER (PARTITION BY campaign) / NULLIF(SUM(results) OVER (PARTITION BY campaign), 0)) AS campaign_cost_per_result
FROM p, ads.period_ads(p.s, p.e)
ORDER BY campaign, cost_per_result;
