-- P4 KPI 15: Peer session  (Month)
-- Collection  : Host closes event
-- Quantity    : Sessions set up by the advisor ÷ planned
-- Quality     : Rating by both students
-- Performance : Learning exchange, not scored
-- Source      : Event system
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: held of planned, attendance, rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = 'Peer session' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Quality: sessions where both students rated =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), m WHERE t.name = 'Peer session' AND e.held_on BETWEEN m.s AND m.e),
per AS (SELECT ev.event_id, COUNT(r.*) AS raters FROM ev LEFT JOIN events.event_ratings r USING (event_id) WHERE ev.status = 'Held' GROUP BY ev.event_id)
SELECT COUNT(*) FILTER (WHERE raters >= 2) AS both_rated, COUNT(*) AS sessions FROM per;
