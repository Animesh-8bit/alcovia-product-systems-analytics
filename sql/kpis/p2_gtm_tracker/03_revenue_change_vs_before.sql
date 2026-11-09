-- KPI 3: Revenue change vs before
-- Definition : How revenue moved against the same-length period just before.
-- Formula    : (Revenue this period − revenue period before) ÷ revenue period before
-- Source     : Razorpay
-- Target     : Above 0%
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
cur  AS (SELECT SUM(amount) AS revenue FROM revenue.payments, p WHERE paid_on BETWEEN p.s AND p.e),
prev AS (SELECT SUM(amount) AS revenue FROM revenue.payments, p WHERE paid_on BETWEEN ops.prev_start(p.s, p.e) AND p.s - 1)
SELECT cur.revenue AS this_period, prev.revenue AS period_before,
       round(100 * (cur.revenue - prev.revenue) / NULLIF(prev.revenue, 0)) AS change_pct
FROM cur, prev;
