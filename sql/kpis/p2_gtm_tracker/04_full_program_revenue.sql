-- KPI 4: Full program revenue
-- Definition : Money from the full program, including trials that renewed into it.
-- Formula    : SUM(amount) of payments in the 'Full program' stream
-- Source     : Razorpay
-- Target     : 4 × ₹2,40,000 per month
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT SUM(amount) AS revenue,
       SUM(amount) FILTER (WHERE payment_type = 'Trial renewal') AS of_which_trial_renewals,
       COUNT(*) AS payments
FROM revenue.v_payment_stream, p
WHERE stream = 'Full program' AND paid_on BETWEEN p.s AND p.e;
