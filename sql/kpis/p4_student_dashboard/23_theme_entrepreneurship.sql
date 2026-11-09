-- P4 KPI 23: Theme: entrepreneurship  (Quarter)
-- Collection  : Advisor notes · 1-tap rating at quarter end
-- Quantity    : Group projects / active startups ÷ groups / students in the theme
-- Quality     : Student rating at quarter end
-- Performance : Monthly milestones hit ÷ planned
-- Source      : ClickUp notes → n8n + LLM · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: students with an active project =='
SELECT COUNT(*) FILTER (WHERE EXISTS (SELECT 1 FROM students.milestones mi WHERE mi.student_id = s.student_id AND mi.track = 'Entrepreneurship')
                       AND s.startup IS NOT NULL) AS active_projects,
       COUNT(*) AS students
FROM students.students s WHERE s.student_id IN (SELECT student_id FROM students.student_month);

\echo '== Quality: quarter-end rating =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT round(AVG(answer), 1) AS avg_rating, COUNT(*) AS responses
FROM students.pulse_responses, q
WHERE question = 'How was this quarter''s theme?' AND asked_on BETWEEN q.s AND q.e AND 'Entrepreneurship' = 'Entrepreneurship';

\echo '== Performance: milestones hit, by month =='
SELECT to_char(due_month, 'YYYY-MM') AS month, COUNT(*) AS due,
       COUNT(*) FILTER (WHERE status = 'Done') AS hit,
       round(100.0 * COUNT(*) FILTER (WHERE status = 'Done') / NULLIF(COUNT(*), 0)) AS hit_pct
FROM students.milestones WHERE track = 'Entrepreneurship' GROUP BY due_month ORDER BY due_month;
