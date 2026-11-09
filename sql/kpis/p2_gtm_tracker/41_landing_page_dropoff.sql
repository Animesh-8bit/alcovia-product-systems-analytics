-- KPI 41: Landing-page drop-off
-- Definition : Visitors who left without filling a form or booking, with the period before.
-- Formula    : Visitors who left without acting ÷ visitors
-- Source     : Google Analytics 4 + Microsoft Clarity
-- Target     : Falling vs period before
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT page,
       SUM(visitors) FILTER (WHERE day BETWEEN p.s AND p.e) AS visitors,
       round(100.0 * SUM(dropoffs) FILTER (WHERE day BETWEEN p.s AND p.e) / SUM(visitors) FILTER (WHERE day BETWEEN p.s AND p.e), 1) AS dropoff_pct,
       round(100.0 * SUM(dropoffs) FILTER (WHERE day < p.s) / NULLIF(SUM(visitors) FILTER (WHERE day < p.s), 0), 1)               AS dropoff_pct_before
FROM ads.page_daily, p
WHERE day BETWEEN ops.prev_start(p.s, p.e) AND p.e
GROUP BY page ORDER BY visitors DESC;
