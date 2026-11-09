-- P4 KPI 24: Summer program applications  (Quarter)
-- Collection  : Advisor notes
-- Quantity    : Applications planned per student
-- Quality     : —
-- Performance : Applications submitted ÷ planned · acceptances
-- Source      : ClickUp notes → n8n + LLM
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Applications =='
SELECT COUNT(DISTINCT student_id) AS students_applying, COUNT(*) AS planned,
       COUNT(submitted_on) AS submitted,
       round(100.0 * COUNT(submitted_on) / NULLIF(COUNT(*), 0)) AS submitted_pct,
       COUNT(*) FILTER (WHERE outcome = 'Accepted') AS accepted
FROM students.summer_applications;
