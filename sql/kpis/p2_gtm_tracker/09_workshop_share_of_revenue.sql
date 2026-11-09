-- KPI 9: Workshop share of revenue
-- Definition : Workshop revenue as a share of all revenue.
-- Formula    : Workshop revenue ÷ revenue collected
-- Source     : Razorpay
-- Target     : —
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT SUM(amount) FILTER (WHERE stream = 'Workshops') AS workshop_revenue,
       SUM(amount)                                     AS all_revenue,
       round(100 * SUM(amount) FILTER (WHERE stream = 'Workshops') / SUM(amount)) AS workshop_share_pct
FROM revenue.v_payment_stream, p
WHERE paid_on BETWEEN p.s AND p.e;
