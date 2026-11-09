-- P4 KPI 9: Syllabus completion  (Week)
-- Collection  : Automatic
-- Quantity    : % of students whose syllabus is loaded in the advisor portal
-- Quality     : —
-- Performance : % syllabus complete vs. pace target (25% per quarter)
-- Source      : Advisor portal · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: syllabus loaded =='
SELECT COUNT(DISTINCT c.student_id) AS students_with_syllabus,
       (SELECT COUNT(DISTINCT student_id) FROM students.student_month) AS students
FROM students.chapters c;

\echo '== Performance: syllabus done vs pace, by student =='
SELECT sm.student_id, sm.syllabus_pct, sm.pace_pct, sm.syllabus_pct - sm.pace_pct AS gap,
       sm.syllabus_pct >= sm.pace_pct - 2 AS on_track
FROM students.student_month sm WHERE sm.month = :'month'::date ORDER BY gap;
