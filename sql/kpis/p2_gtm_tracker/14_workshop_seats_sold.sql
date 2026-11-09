-- KPI 14: Workshop seats sold
-- Definition : Seats paid for in the period.
-- Formula    : COUNT(Workshop seat payments) in period
-- Source     : Razorpay
-- Target     : 60 per month (30 × 2 workshops)
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT COUNT(*) FILTER (WHERE paid_on BETWEEN p.s AND p.e AND payment_type IN ('Workshop seat'))                          AS this_period,
       round(ads.target('seats_month') * ops.months_of_target(p.s, p.e))                                           AS target,
       COUNT(*) FILTER (WHERE paid_on BETWEEN p.s AND p.e AND payment_type IN ('Workshop seat'))
     - COUNT(*) FILTER (WHERE paid_on BETWEEN ops.prev_start(p.s, p.e) AND p.s - 1 AND payment_type IN ('Workshop seat')) AS change_vs_before
FROM revenue.payments, p
GROUP BY p.s, p.e;
