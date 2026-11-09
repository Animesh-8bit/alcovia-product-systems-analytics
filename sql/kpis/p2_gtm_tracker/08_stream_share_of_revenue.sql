-- KPI 8: Stream share of revenue
-- Definition : How much of all revenue each stream brought.
-- Formula    : Stream revenue ÷ revenue collected
-- Source     : Razorpay
-- Target     : —
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT stream, SUM(amount) AS revenue,
       round(100 * SUM(amount) / SUM(SUM(amount)) OVER ()) AS share_pct
FROM revenue.v_payment_stream, p
WHERE paid_on BETWEEN p.s AND p.e
GROUP BY stream ORDER BY stream;
