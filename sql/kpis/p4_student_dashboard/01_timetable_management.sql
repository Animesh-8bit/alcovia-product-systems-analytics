-- P4 KPI 1: Timetable management  (Day)
-- Collection  : Automatic · 1-tap weekly pulse
-- Quantity    : % of students with an advisor-built weekly timetable, updated this week
-- Quality     : "Did your timetable work this week?" (1–5)
-- Performance : Timetable adherence: % of planned self-study slots that had a linked focus session
-- Source      : Advisor portal · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: students with a timetable updated, per week =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), active AS (SELECT sm.student_id FROM students.student_month sm, m WHERE sm.month = m.s),
weeks AS (SELECT w::date AS week FROM m, generate_series(date_trunc('week', m.s), m.e, interval '7 days') w)
SELECT weeks.week,
       COUNT(DISTINCT ts.student_id) AS students_updated,
       (SELECT COUNT(*) FROM active) AS students,
       round(100.0 * COUNT(DISTINCT ts.student_id) / (SELECT COUNT(*) FROM active)) AS pct
FROM weeks LEFT JOIN students.timetable_slots ts ON ts.created_on = weeks.week
GROUP BY weeks.week ORDER BY weeks.week;

\echo '== Quality: timetable pulse =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT round(AVG(answer), 1) AS avg_answer, COUNT(*) AS responses
FROM students.pulse_responses, m
WHERE question = 'Did your timetable work this week?' AND asked_on BETWEEN m.s AND m.e;

\echo '== Performance: timetable adherence =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT COUNT(*) AS planned_slots,
       COUNT(*) FILTER (WHERE EXISTS (SELECT 1 FROM students.app_sessions a WHERE a.linked_slot_id = ts.slot_id)) AS slots_with_linked_focus,
       round(100.0 * COUNT(*) FILTER (WHERE EXISTS (SELECT 1 FROM students.app_sessions a WHERE a.linked_slot_id = ts.slot_id)) / NULLIF(COUNT(*), 0)) AS adherence_pct
FROM students.timetable_slots ts, m
WHERE ts.slot_date BETWEEN m.s AND m.e;
