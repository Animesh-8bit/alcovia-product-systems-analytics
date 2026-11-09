-- KPI 13: Trials started
-- Definition : Families who paid for a 3-month trial in the period. They are in the Trial state, not converted.
-- Formula    : COUNT(Trial payments) in period
-- Source     : Razorpay
-- Target     : 6 per month
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT COUNT(*) FILTER (WHERE paid_on BETWEEN p.s AND p.e AND payment_type IN ('Trial'))                          AS this_period,
       round(ads.target('trial_month') * ops.months_of_target(p.s, p.e))                                           AS target,
       COUNT(*) FILTER (WHERE paid_on BETWEEN p.s AND p.e AND payment_type IN ('Trial'))
     - COUNT(*) FILTER (WHERE paid_on BETWEEN ops.prev_start(p.s, p.e) AND p.s - 1 AND payment_type IN ('Trial')) AS change_vs_before
FROM revenue.payments, p
GROUP BY p.s, p.e;
