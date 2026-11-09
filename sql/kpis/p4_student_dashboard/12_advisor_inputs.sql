-- P4 KPI 12: Advisor inputs  (Week)
-- Collection  : Automatic · advisor notes
-- Quantity    : % of students with targets aligned · deviation alerts sent · tutor / academy support assigned when triggered
-- Quality     : —
-- Performance : Inputs, not student outcomes: shown in the advisor view
-- Source      : Advisor portal · n8n alerts · ClickUp notes → n8n + LLM
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Inputs per advisor =='
SELECT a.name AS advisor,
       COUNT(*) AS students,
       round(100.0 * COUNT(*) FILTER (WHERE r.targets_aligned) / COUNT(*)) AS targets_aligned_pct,
       COUNT(*) FILTER (WHERE r.support_assigned) AS support_assigned,
       (SELECT COUNT(*) FROM ops.alerts al WHERE al.advisor_id = a.advisor_id AND al.alert_type = 'Deviation'
          AND date_trunc('month', al.raised_on) = :'month'::date) AS deviation_alerts
FROM ops.advisor_reviews r JOIN students.students s USING (student_id) JOIN ops.advisors a ON a.advisor_id = s.advisor_id
WHERE r.month = :'month'::date GROUP BY a.advisor_id, a.name ORDER BY a.name;
