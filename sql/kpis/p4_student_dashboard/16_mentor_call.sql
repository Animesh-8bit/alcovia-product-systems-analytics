-- P4 KPI 16: Mentor call  (Month)
-- Collection  : Host closes event · advisor notes
-- Quantity    : Calls held ÷ 1 per student per month
-- Quality     : Rating (already in the app)
-- Performance : Follow-up action logged after the call (yes / no)
-- Source      : Event system · Student app · ClickUp notes → n8n + LLM
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: held of planned, attendance, rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = 'Mentor call' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Performance: follow-up logged =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), m WHERE t.name = 'Mentor call' AND e.held_on BETWEEN m.s AND m.e)
SELECT COUNT(*) FILTER (WHERE ev.status = 'Held') AS calls_held,
       COUNT(DISTINCT f.event_id) AS with_follow_up,
       round(100.0 * COUNT(DISTINCT f.event_id) / NULLIF(COUNT(*) FILTER (WHERE ev.status = 'Held'), 0)) AS pct
FROM ev LEFT JOIN events.event_follow_ups f USING (event_id);
