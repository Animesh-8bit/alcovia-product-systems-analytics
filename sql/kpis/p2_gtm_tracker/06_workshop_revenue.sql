-- KPI 6: Workshop revenue
-- Definition : Money from workshop seats.
-- Formula    : SUM(amount) of payments in the 'Workshops' stream
-- Source     : Razorpay
-- Target     : 60 × ₹3,999 per month
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT SUM(amount) AS revenue,
       SUM(amount) FILTER (WHERE payment_type = 'Trial renewal') AS of_which_trial_renewals,
       COUNT(*) AS payments
FROM revenue.v_payment_stream, p
WHERE stream = 'Workshops' AND paid_on BETWEEN p.s AND p.e;
