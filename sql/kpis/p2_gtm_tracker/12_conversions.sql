-- KPI 12: Conversions
-- Definition : Families who paid for the full term in the period: the full program, or a trial renewal.
-- Formula    : COUNT(Full program payments) + COUNT(Trial renewal payments) in period
-- Source     : Razorpay
-- Target     : 4 per month
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT COUNT(*) FILTER (WHERE paid_on BETWEEN p.s AND p.e AND payment_type IN ('Full program', 'Trial renewal'))                          AS this_period,
       COUNT(*) FILTER (WHERE paid_on BETWEEN p.s AND p.e AND payment_type = 'Trial renewal')                AS of_which_via_trial,
       round(ads.target('full_month') * ops.months_of_target(p.s, p.e))                                           AS target,
       COUNT(*) FILTER (WHERE paid_on BETWEEN p.s AND p.e AND payment_type IN ('Full program', 'Trial renewal'))
     - COUNT(*) FILTER (WHERE paid_on BETWEEN ops.prev_start(p.s, p.e) AND p.s - 1 AND payment_type IN ('Full program', 'Trial renewal')) AS change_vs_before
FROM revenue.payments, p
GROUP BY p.s, p.e;
