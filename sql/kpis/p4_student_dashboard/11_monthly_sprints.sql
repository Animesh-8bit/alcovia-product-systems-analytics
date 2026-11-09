-- P4 KPI 11: Monthly sprints (missed timelines)  (Week)
-- Collection  : Advisor notes · 1-tap rating
-- Quantity    : Sprints created ÷ students with missed timelines
-- Quality     : Student rating of the sprint
-- Performance : % of sprint chapters recovered by month end
-- Source      : ClickUp notes → n8n + LLM · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: sprints for students behind =='
SELECT (SELECT COUNT(*) FROM students.sprints WHERE month = :'month'::date) AS sprints,
       (SELECT COUNT(*) FROM students.student_month WHERE month = :'month'::date AND syllabus_pct < pace_pct - 8) AS students_behind_8_pts;

\echo '== Quality: sprint rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = 'Monthly sprint' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Performance: chapters recovered =='
SELECT SUM(chapters_recovered) AS recovered, SUM(chapters_planned) AS planned,
       round(100.0 * SUM(chapters_recovered) / NULLIF(SUM(chapters_planned), 0)) AS recovered_pct
FROM students.sprints WHERE month = :'month'::date;
