-- KPI 2: Revenue vs target %
-- Definition : Revenue collected as a share of the period's target.
-- Formula    : Revenue ÷ (monthly revenue target × months in period)
-- Source     : Razorpay + targets
-- Target     : 100% or more
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT SUM(amount)                                 AS revenue,
       round(ads.target('revenue_month') * ops.months_of_target(p.s, p.e))                                AS target,
       round(100 * SUM(amount) / (ads.target('revenue_month') * ops.months_of_target(p.s, p.e)))          AS pct_of_target
FROM revenue.payments, p
WHERE paid_on BETWEEN p.s AND p.e
GROUP BY p.s, p.e;
