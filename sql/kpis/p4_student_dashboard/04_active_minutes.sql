-- P4 KPI 4: Active minutes  (Day)
-- Collection  : Automatic (one-time permission)
-- Quantity    : % of students with health data connected
-- Quality     : Not rated: passive data
-- Performance : Days with ≥60 active minutes
-- Source      : Apple Health / Health Connect via the app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: health data connected =='
SELECT COUNT(*) FILTER (WHERE health_connected) AS connected, COUNT(*) AS students,
       round(100.0 * COUNT(*) FILTER (WHERE health_connected) / COUNT(*)) AS pct
FROM students.students WHERE student_id IN (SELECT student_id FROM students.student_month);

\echo '== Performance: days with 60+ active minutes (monthly summary) =='
SELECT round(AVG(active_days_pct), 1) AS pct_days_60_plus, COUNT(active_days_pct) AS students_measured
FROM students.student_month WHERE month = :'month'::date;
