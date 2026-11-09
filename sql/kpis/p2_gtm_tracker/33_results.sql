-- KPI 33: Results
-- Definition : What each ad is for: qualified leads (program) or seats sold (workshop).
-- Formula    : Program: paid-ad leads qualified in period · workshop: seat payments in period, per ad
-- Source     : ClickUp / Razorpay, matched on campaign tags
-- Target     : —
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT campaign, ad, type, leads, results,
       CASE type WHEN 'Program' THEN 'qualified leads' ELSE 'seats sold' END AS result_is
FROM p, ads.period_ads(p.s, p.e)
ORDER BY campaign, results DESC;
