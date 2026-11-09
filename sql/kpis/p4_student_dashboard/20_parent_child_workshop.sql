-- P4 KPI 20: Parent–child workshop  (Quarter)
-- Collection  : Host closes event
-- Quantity    : Held (1 per quarter) · % of families with a parent present
-- Quality     : Student and parent ratings
-- Performance : Bonding outcome, not scored: parent rating is the measure
-- Source      : Event system
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: held this quarter (target 1), student rating =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), q
WHERE t.name = 'Parent–child workshop' AND d.month BETWEEN q.s AND q.e AND d.planned > 0;

\echo '== Quantity: families with a parent present =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), q WHERE t.name = 'Parent–child workshop' AND e.held_on BETWEEN q.s AND q.e)
SELECT COUNT(*) FILTER (WHERE a.attended) AS present, COUNT(*) AS invited, round(100.0 * COUNT(*) FILTER (WHERE a.attended) / NULLIF(COUNT(*), 0)) AS attendance_pct FROM ev JOIN events.event_attendance a USING (event_id) WHERE a.role = 'Parent';

\echo '== Quality: parent rating =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e), ev AS (SELECT e.* FROM events.events e JOIN events.event_types t USING (event_type_id), q WHERE t.name = 'Parent–child workshop' AND e.held_on BETWEEN q.s AND q.e)
SELECT round(AVG(r.rating), 1) AS avg_rating, COUNT(*) AS ratings FROM ev JOIN events.event_ratings r USING (event_id) WHERE r.rater = 'Parent';
