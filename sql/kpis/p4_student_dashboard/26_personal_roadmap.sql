-- P4 KPI 26: Personal roadmap  (Roadmap)
-- Collection  : Advisor notes
-- Quantity    : % of students with monthly milestones set
-- Quality     : —
-- Performance : Monthly milestones hit ÷ due
-- Source      : ClickUp notes → n8n + LLM
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: personal roadmap set =='
SELECT COUNT(*) FILTER (WHERE made_on IS NOT NULL) AS set, COUNT(*) AS students,
       round(100.0 * COUNT(*) FILTER (WHERE made_on IS NOT NULL) / COUNT(*)) AS pct
FROM students.roadmaps WHERE kind = 'Personal';

\echo '== Performance: personal milestones hit, by month =='
SELECT to_char(due_month, 'YYYY-MM') AS month, COUNT(*) AS due,
       COUNT(*) FILTER (WHERE status = 'Done') AS hit,
       round(100.0 * COUNT(*) FILTER (WHERE status = 'Done') / NULLIF(COUNT(*), 0)) AS hit_pct
FROM students.milestones WHERE track = 'Personal' GROUP BY due_month ORDER BY due_month;
