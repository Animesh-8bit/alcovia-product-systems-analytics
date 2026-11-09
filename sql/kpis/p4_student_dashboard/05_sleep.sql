-- P4 KPI 5: Active recovery (sleep)  (Day)
-- Collection  : Automatic (one-time permission)
-- Quantity    : Same connection rate as active minutes
-- Quality     : Not rated: passive data
-- Performance : Average sleep hours vs. 8–10 h (teen guideline) · nights below 7 h
-- Source      : Apple Health / Health Connect via the app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Performance: sleep =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT (SELECT round(AVG(sleep_hrs), 1) FROM students.student_month WHERE month = m.s) AS avg_sleep_hrs,   -- monthly summary
       '8–10' AS guideline,
       COUNT(*) FILTER (WHERE sleep_hrs < 7) AS nights_below_7h, COUNT(*) AS nights,                          -- daily health data
       round(100.0 * COUNT(*) FILTER (WHERE sleep_hrs < 7) / NULLIF(COUNT(*), 0)) AS pct_below_7h
FROM students.health_daily, m WHERE day BETWEEN m.s AND m.e
GROUP BY m.s;
