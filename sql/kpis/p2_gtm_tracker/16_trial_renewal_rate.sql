-- KPI 16: Trial-to-full renewal rate
-- Definition : Share of trials that ended in the period and renewed into the full program.
-- Formula    : Trials renewed ÷ trials that ended in period
-- Source     : students.enrolments
-- Target     : Proposal: 50%+
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT COUNT(*)                                   AS trials_ended,
       COUNT(*) FILTER (WHERE status = 'Renewed') AS renewed,
       round(100.0 * COUNT(*) FILTER (WHERE status = 'Renewed') / NULLIF(COUNT(*), 0)) AS renewal_rate_pct
FROM students.enrolments, p
WHERE plan = 'Trial' AND status <> 'In trial' AND ends_on BETWEEN p.s AND p.e;
