-- P4 KPI 2: Daily 8 PM quiz  (Day)
-- Collection  : Automatic · 1-tap rating
-- Quantity    : Quizzes published at 8 PM ÷ days in period
-- Quality     : Rating at the end of each quiz
-- Performance : Participation (% of students who took it) · accuracy % · trend per topic
-- Source      : Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: quizzes published (held of days) and rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = '8 PM quiz' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Performance: participation and accuracy (monthly summary) =='
SELECT round(AVG(quiz_participation_pct), 1) AS participation_pct, round(AVG(quiz_accuracy_pct), 1) AS accuracy_pct
FROM students.student_month WHERE month = :'month'::date;

\echo '== Performance: accuracy by topic =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), m WHERE t.name = '8 PM quiz' AND e.held_on BETWEEN m.s AND m.e)
SELECT qa.topic, COUNT(*) AS attempts, round(AVG(qa.score_pct), 1) AS accuracy_pct
FROM ev JOIN students.quiz_attempts qa USING (event_id)
GROUP BY qa.topic ORDER BY accuracy_pct;
