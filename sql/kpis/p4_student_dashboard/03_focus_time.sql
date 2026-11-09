-- P4 KPI 3: Focus time  (Day)
-- Collection  : Automatic
-- Quantity    : % of students with the advisor's plan pushed to the app (so linked focus is possible)
-- Quality     : Voluntary repeat use: % of students running focus on ≥5 days a week
-- Performance : Counted minutes per day vs. the 30-min target · streak length
-- Source      : Student app · Advisor portal
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: plan pushed to the app =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), active AS (SELECT sm.student_id FROM students.student_month sm, m WHERE sm.month = m.s)
SELECT COUNT(DISTINCT ts.student_id) AS students_with_plan, (SELECT COUNT(*) FROM active) AS students,
       round(100.0 * COUNT(DISTINCT ts.student_id) / (SELECT COUNT(*) FROM active)) AS pct
FROM students.timetable_slots ts, m WHERE ts.slot_date BETWEEN m.s AND m.e;

\echo '== Quality: voluntary repeat use (student-weeks with focus on 5+ days) =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e),
wk AS (SELECT student_id, date_trunc('week', started_at)::date AS week, COUNT(DISTINCT started_at::date) AS focus_days
       FROM students.app_sessions, m WHERE kind = 'Focus' AND started_at::date BETWEEN m.s AND m.e GROUP BY 1, 2)
SELECT COUNT(*) FILTER (WHERE focus_days >= 5) AS student_weeks_5_plus, COUNT(*) AS student_weeks,
       round(100.0 * COUNT(*) FILTER (WHERE focus_days >= 5) / NULLIF(COUNT(*), 0)) AS pct
FROM wk;

\echo '== Performance: counted minutes per day (study + quiz + games capped at half of study and quiz; monthly summary) =='
SELECT round(AVG(counted_min), 1) AS counted_min_per_day, 30 AS target,
       COUNT(*) FILTER (WHERE counted_min >= 30) AS students_at_target, COUNT(*) AS students
FROM students.student_month WHERE month = :'month'::date;

\echo '== Performance: longest focus streak per student (days in a row) =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e),
d AS (SELECT DISTINCT student_id, started_at::date AS day FROM students.app_sessions, m WHERE kind = 'Focus' AND started_at::date BETWEEN m.s AND m.e),
g AS (SELECT student_id, day - (ROW_NUMBER() OVER (PARTITION BY student_id ORDER BY day))::int AS grp FROM d),
streaks AS (SELECT student_id, COUNT(*) AS streak FROM g GROUP BY student_id, grp)
SELECT round(AVG(best), 1) AS avg_longest_streak, MAX(best) AS best_streak
FROM (SELECT student_id, MAX(streak) AS best FROM streaks GROUP BY student_id) s;
