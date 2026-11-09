-- P4 KPI 7: Score targets (Formative, unit test, half-yearly)  (Week)
-- Collection  : Automatic · advisor notes
-- Quantity    : % of students with targets set for every subject and exam type, and aligned with parents
-- Quality     : Parent confirmation of targets (yes / no)
-- Performance : Actual vs. target per exam · % of subjects at or above target
-- Source      : Advisor portal · Student app · ClickUp notes → n8n + LLM
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: students with every target set, and all confirmed by parents =='
WITH per AS (
    SELECT s.student_id, COUNT(t.*) AS targets_set, COUNT(*) FILTER (WHERE t.parent_confirmed) AS confirmed
    FROM students.students s LEFT JOIN students.score_targets t USING (student_id)
    WHERE s.student_id IN (SELECT student_id FROM students.student_month) GROUP BY s.student_id)
SELECT COUNT(*) FILTER (WHERE targets_set = 15)                    AS all_targets_set,
       COUNT(*) FILTER (WHERE targets_set = 15 AND confirmed = 15) AS all_set_and_parent_aligned,
       COUNT(*)                                                    AS students
FROM per;   -- 5 subjects × 3 exam types = 15

\echo '== Quality: parent confirmation =='
SELECT COUNT(*) FILTER (WHERE parent_confirmed) AS confirmed, COUNT(*) AS targets,
       round(100.0 * COUNT(*) FILTER (WHERE parent_confirmed) / COUNT(*)) AS pct
FROM students.score_targets;

\echo '== Performance: actual vs target per exam =='
SELECT r.exam_type, round(AVG(r.score_pct - t.target_pct), 1) AS avg_gap_pts,
       COUNT(*) FILTER (WHERE r.score_pct >= t.target_pct) AS subjects_at_or_above, COUNT(*) AS subjects,
       round(100.0 * COUNT(*) FILTER (WHERE r.score_pct >= t.target_pct) / COUNT(*)) AS pct_at_or_above
FROM students.exam_results r JOIN students.score_targets t USING (student_id, subject, exam_type)
GROUP BY r.exam_type ORDER BY MIN(r.exam_on);
