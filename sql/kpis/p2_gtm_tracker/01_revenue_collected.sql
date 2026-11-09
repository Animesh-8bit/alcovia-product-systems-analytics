-- KPI 1: Revenue collected
-- Definition : All payments received in the period, across the three streams.
-- Formula    : SUM(payment amount) where payment date in period
-- Source     : Razorpay
-- Target     : ₹15,00,000 × months in period
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT SUM(amount) AS revenue_collected, COUNT(*) AS payments
FROM revenue.payments, p
WHERE paid_on BETWEEN p.s AND p.e;
