-- P4 KPI 8: Time management  (Week)
-- Collection  : Automatic
-- Quantity    : % of students with tasks assigned this week
-- Quality     : Covered by the timetable pulse
-- Performance : Task completion rate · deadline adherence · time-estimation accuracy (actual ÷ estimated hours)
-- Source      : Student app · Advisor portal
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: students with tasks assigned, per week =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), active AS (SELECT sm.student_id FROM students.student_month sm, m WHERE sm.month = m.s),
weeks AS (SELECT w::date AS week FROM m, generate_series(date_trunc('week', m.s), m.e, interval '7 days') w)
SELECT weeks.week, COUNT(DISTINCT t.student_id) AS students_with_tasks,
       round(100.0 * COUNT(DISTINCT t.student_id) / (SELECT COUNT(*) FROM active)) AS pct
FROM weeks LEFT JOIN students.tasks t ON t.assigned_on BETWEEN weeks.week AND weeks.week + 6
GROUP BY weeks.week ORDER BY weeks.week;

\echo '== Performance: completion, deadlines, estimates =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT (SELECT round(AVG(task_completion_pct), 1) FROM students.student_month WHERE month = m.s)    AS completion_pct,          -- monthly summary
       (SELECT round(AVG(deadline_adherence_pct), 1) FROM students.student_month WHERE month = m.s) AS deadline_adherence_pct,  -- monthly summary
       round(AVG(actual_hrs / NULLIF(estimated_hrs, 0)), 2) AS actual_over_estimated                                            -- task data
FROM students.tasks, m WHERE due_on BETWEEN m.s AND m.e
GROUP BY m.s;
