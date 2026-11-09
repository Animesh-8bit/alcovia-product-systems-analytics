-- KPI 42: Load time
-- Definition : How fast each landing page loads, mobile and desktop.
-- Formula    : AVERAGE(daily page-speed check)
-- Source     : Google PageSpeed Insights
-- Target     : Mobile 3 s or less
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT page,
       round(AVG(load_mobile_s), 2)  AS mobile_load_s,
       round(AVG(load_desktop_s), 2) AS desktop_load_s,
       AVG(load_mobile_s) > 3        AS mobile_over_3s
FROM ads.page_daily, p
WHERE day BETWEEN p.s AND p.e
GROUP BY page ORDER BY page;
