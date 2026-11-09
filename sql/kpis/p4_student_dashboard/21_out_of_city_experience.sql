-- P4 KPI 21: Out-of-city experience  (Quarter)
-- Collection  : Host closes event
-- Quantity    : Held (1 per quarter) · attendance %
-- Quality     : Student rating
-- Performance : Experience, not scored
-- Source      : Event system
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: held this quarter (target 1), attendance, rating =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), q
WHERE t.name = 'Out-of-city experience' AND d.month BETWEEN q.s AND q.e AND d.planned > 0;
