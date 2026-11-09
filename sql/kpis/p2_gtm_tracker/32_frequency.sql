-- KPI 32: Frequency
-- Definition : Average times each person has seen the ad (latest in the period); campaign = highest of its ads.
-- Formula    : Impressions ÷ reach as Meta reports it
-- Source     : Meta Ads
-- Target     : Below 3
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT campaign, ad, frequency,
       MAX(frequency) OVER (PARTITION BY campaign) AS campaign_frequency,
       frequency >= ads.target('frequency')        AS needs_refresh
FROM p, ads.period_ads(p.s, p.e)
ORDER BY frequency DESC;
