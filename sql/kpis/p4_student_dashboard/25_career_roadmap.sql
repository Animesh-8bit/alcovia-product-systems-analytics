-- P4 KPI 25: Career roadmap  (Roadmap)
-- Collection  : Advisor notes · 1-tap rating
-- Quantity    : % of students with a career roadmap made
-- Quality     : Student rating of the roadmap
-- Performance : Done / not done (binary, per the brief)
-- Source      : ClickUp notes → n8n + LLM · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Roadmaps =='
SELECT COUNT(*) FILTER (WHERE made_on IS NOT NULL) AS made, COUNT(*) AS students,
       round(100.0 * COUNT(*) FILTER (WHERE made_on IS NOT NULL) / COUNT(*)) AS made_pct,
       round(AVG(rating), 1) AS avg_rating
FROM students.roadmaps WHERE kind = 'Career';

\echo '== Done / not done per student =='
SELECT s.student_id, s.name, s.career_roadmap AS status
FROM students.students s WHERE s.career_roadmap IS NOT NULL ORDER BY s.career_roadmap, s.student_id;
