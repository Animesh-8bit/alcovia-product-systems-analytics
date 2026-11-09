-- P4 KPI 19: Competition prep  (Quarter)
-- Collection  : Advisor notes · 1-tap rating
-- Quantity    : % of students entered in a competition this quarter
-- Quality     : Student rating of the prep
-- Performance : Outcome: participated / shortlisted / placed
-- Source      : ClickUp notes → n8n + LLM · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: students entered this quarter =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT COUNT(DISTINCT c.student_id) AS students_entered,
       (SELECT COUNT(DISTINCT student_id) FROM students.student_month) AS students
FROM students.competitions c, q WHERE c.quarter = q.s;

\echo '== Quality: rating of the prep sessions =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), q
WHERE t.name = 'Competition prep' AND d.month BETWEEN q.s AND q.e AND d.planned > 0;

\echo '== Performance: outcomes =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT COALESCE(outcome, 'Not yet') AS outcome, COUNT(*) AS entries
FROM students.competitions c, q WHERE c.quarter = q.s GROUP BY 1 ORDER BY 2 DESC;
