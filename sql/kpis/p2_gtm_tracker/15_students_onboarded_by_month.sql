-- KPI 15: Students onboarded (by month)
-- Definition : New paying students each month, split full program and trial.
-- Formula    : COUNT(Full program payments) + COUNT(Trial payments) per month
-- Source     : Razorpay + ClickUp
-- Target     : 10 per month
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT to_char(date_trunc('month', paid_on), 'YYYY-MM')                       AS month,
       COUNT(*) FILTER (WHERE payment_type = 'Full program')                  AS full_program,
       COUNT(*) FILTER (WHERE payment_type = 'Trial')                         AS trial,
       COUNT(*) FILTER (WHERE payment_type IN ('Full program', 'Trial'))      AS onboarded,
       round((ads.target('full_month') + ads.target('trial_month')) * ops.months_of_target(
           GREATEST(date_trunc('month', paid_on)::date, p.s),
           LEAST((date_trunc('month', paid_on) + interval '1 month - 1 day')::date, p.e)), 1) AS target
FROM revenue.payments, p
WHERE paid_on BETWEEN p.s AND p.e
GROUP BY date_trunc('month', paid_on), p.s, p.e
ORDER BY 1;
