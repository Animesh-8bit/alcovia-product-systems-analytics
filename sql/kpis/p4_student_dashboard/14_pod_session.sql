-- P4 KPI 14: Pod session  (Month)
-- Collection  : Host closes event
-- Quantity    : Pods held ÷ planned · attendance %
-- Quality     : Student rating (1–5)
-- Performance : Host-marked participation (1–5)
-- Source      : Event system · Advisor portal
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: held of planned, attendance, rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = 'Pod session' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Performance: host-marked participation =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), m WHERE t.name = 'Pod session' AND e.held_on BETWEEN m.s AND m.e)
SELECT round(AVG(a.participation_score), 1) AS avg_participation
FROM ev JOIN events.event_attendance a USING (event_id);
