-- P4 KPI 27: Academic roadmap  (Roadmap)
-- Collection  : See the Week rows
-- Quantity    : See the Week rows
-- Quality     : See the Week rows
-- Performance : See the Week rows: score targets (7), syllabus (9), rigour (10)
-- Source      : —
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Academic summary per student for the month =='
SELECT sm.student_id, sm.syllabus_pct, sm.pace_pct, sm.readiness,
       (SELECT round(AVG(r.score_pct - t.target_pct), 1) FROM students.exam_results r JOIN students.score_targets t USING (student_id, subject, exam_type)
         WHERE r.student_id = sm.student_id) AS avg_gap_to_target
FROM students.student_month sm WHERE sm.month = :'month'::date ORDER BY sm.student_id;
