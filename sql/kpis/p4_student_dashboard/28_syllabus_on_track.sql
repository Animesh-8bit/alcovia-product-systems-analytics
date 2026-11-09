-- P4 KPI 28: Syllabus completion (roadmap)  (Roadmap)
-- Collection  : Automatic
-- Quantity    : —
-- Quality     : —
-- Performance : On track vs. 25% per quarter (yes / no per subject)
-- Source      : Advisor portal · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== On track per subject (within 2 points of pace) =='
SELECT subject, COUNT(*) FILTER (WHERE syllabus_pct >= pace_pct - 2) AS on_track, COUNT(*) AS students,
       round(100.0 * COUNT(*) FILTER (WHERE syllabus_pct >= pace_pct - 2) / COUNT(*)) AS pct
FROM students.subject_progress GROUP BY subject ORDER BY pct;
