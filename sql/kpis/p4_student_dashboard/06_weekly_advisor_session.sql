-- P4 KPI 6: Weekly advisor session  (Week)
-- Collection  : Host closes event · advisor notes
-- Quantity    : Sessions held ÷ planned, per student
-- Quality     : Student rating after the session (1–5)
-- Performance : Actions agreed last week that were completed
-- Source      : Event system · ClickUp notes → n8n + LLM
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: sessions held of planned, student rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = 'Advisor session' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Quantity: per student =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), m WHERE t.name = 'Advisor session' AND e.held_on BETWEEN m.s AND m.e)
SELECT a.student_id, COUNT(*) AS planned, COUNT(*) FILTER (WHERE ev.status = 'Held') AS held
FROM ev JOIN events.event_attendance a USING (event_id) GROUP BY a.student_id
UNION ALL
SELECT '(not held, no attendee)', COUNT(*), 0 FROM ev WHERE status <> 'Held'
ORDER BY held, student_id;

\echo '== Performance: agreed actions completed =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), m WHERE t.name = 'Advisor session' AND e.held_on BETWEEN m.s AND m.e)
SELECT COUNT(*) AS actions_agreed, COUNT(f.completed_on) AS completed,
       round(100.0 * COUNT(f.completed_on) / NULLIF(COUNT(*), 0)) AS completed_pct
FROM ev JOIN events.event_follow_ups f USING (event_id);
