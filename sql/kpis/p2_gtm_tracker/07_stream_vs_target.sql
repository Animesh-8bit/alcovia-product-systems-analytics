-- KPI 7: Stream vs target %
-- Definition : Each stream's revenue against its own target.
-- Formula    : Stream revenue ÷ (stream monthly volume target × price × months in period)
-- Source     : Razorpay + targets
-- Target     : 100% or more
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
streams(stream, monthly_target) AS (VALUES
    ('Full program', ads.target('full_month')  * ads.target('full_price')),
    ('Trial',        ads.target('trial_month') * ads.target('trial_price')),
    ('Workshops',    ads.target('seats_month') * ads.target('seat_price'))),
rev AS (SELECT stream, SUM(amount) AS revenue FROM revenue.v_payment_stream, p WHERE paid_on BETWEEN p.s AND p.e GROUP BY stream)
SELECT st.stream, COALESCE(rev.revenue, 0) AS revenue,
       round(st.monthly_target * ops.months_of_target(p.s, p.e)) AS target,
       round(100 * COALESCE(rev.revenue, 0) / (st.monthly_target * ops.months_of_target(p.s, p.e))) AS pct_of_target
FROM streams st CROSS JOIN p LEFT JOIN rev USING (stream)
ORDER BY st.stream;
