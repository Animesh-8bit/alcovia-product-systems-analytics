-- KPI 5: Trial revenue
-- Definition : Money from 3-month trials.
-- Formula    : SUM(amount) of payments in the 'Trial' stream
-- Source     : Razorpay
-- Target     : 6 × ₹50,000 per month
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT SUM(amount) AS revenue,
       SUM(amount) FILTER (WHERE payment_type = 'Trial renewal') AS of_which_trial_renewals,
       COUNT(*) AS payments
FROM revenue.v_payment_stream, p
WHERE stream = 'Trial' AND paid_on BETWEEN p.s AND p.e;
