-- P4 KPI 10: Rigour of completion  (Week)
-- Collection  : Automatic · advisor notes
-- Quantity    : Monthly re-evaluation done by the advisor (yes / no per student)
-- Quality     : —
-- Performance : Chapter readiness score · rigour adherence: % of chapters marked complete that went through all 5 stages
-- Source      : Student app · ClickUp notes → n8n + LLM
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: monthly re-evaluation done =='
SELECT COUNT(*) FILTER (WHERE reevaluation_done) AS done, COUNT(*) AS students,
       round(100.0 * COUNT(*) FILTER (WHERE reevaluation_done) / COUNT(*)) AS pct
FROM ops.advisor_reviews WHERE month = :'month'::date;

\echo '== Performance: readiness and rigour adherence =='
SELECT (SELECT round(AVG(readiness), 1) FROM students.student_month WHERE month = :'month'::date) AS avg_readiness,
       COUNT(*) FILTER (WHERE marked_complete_on IS NOT NULL) AS chapters_complete,
       COUNT(*) FILTER (WHERE marked_complete_on IS NOT NULL AND stages_done = 5) AS through_all_5_stages,
       round(100.0 * COUNT(*) FILTER (WHERE marked_complete_on IS NOT NULL AND stages_done = 5)
             / NULLIF(COUNT(*) FILTER (WHERE marked_complete_on IS NOT NULL), 0)) AS rigour_adherence_pct
FROM students.chapters WHERE marked_complete_on <= (:'month'::date + interval '1 month - 1 day')::date;
