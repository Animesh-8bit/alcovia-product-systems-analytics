-- P4 KPI 18: Podcast shoot  (Quarter)
-- Collection  : Host closes event · status change in the content tracker
-- Quantity    : Shoots held ÷ students due this quarter · episodes published
-- Quality     : Student rating
-- Performance : Host rating of preparation (questions researched, 1–5)
-- Source      : Event system · ClickUp content tracker
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: shoots held of planned this quarter, rating =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), q
WHERE t.name = 'Podcast shoot' AND d.month BETWEEN q.s AND q.e AND d.planned > 0;

\echo '== Quantity: episodes published this quarter =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT COUNT(published_on) AS episodes_published FROM students.content_items, q WHERE kind = 'Podcast' AND due_month BETWEEN q.s AND q.e;

\echo '== Performance: preparation (host rating) =='
WITH q AS (SELECT date_trunc('quarter', :'month'::date)::date AS s, (date_trunc('quarter', :'month'::date) + interval '3 months - 1 day')::date AS e)
SELECT round(AVG(prep_rating), 1) AS avg_prep_rating, COUNT(prep_rating) AS rated
FROM students.content_items, q WHERE kind = 'Podcast' AND due_month BETWEEN q.s AND q.e;
