-- P4 KPI 29: Rigour of completion (roadmap)  (Roadmap)
-- Collection  : Automatic
-- Quantity    : —
-- Quality     : —
-- Performance : Rigour adherence (see row 10), per student
-- Source      : Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Rigour adherence per student =='
SELECT student_id,
       COUNT(*) FILTER (WHERE marked_complete_on IS NOT NULL) AS chapters_complete,
       round(100.0 * COUNT(*) FILTER (WHERE marked_complete_on IS NOT NULL AND stages_done = 5)
             / NULLIF(COUNT(*) FILTER (WHERE marked_complete_on IS NOT NULL), 0)) AS rigour_adherence_pct
FROM students.chapters GROUP BY student_id ORDER BY rigour_adherence_pct;
