-- P4 KPI 13: Workshop 1 & 2 (career discovery)  (Month)
-- Collection  : Host closes event · host rubric in the portal
-- Quantity    : Workshops held ÷ 2 per month · attendance %
-- Quality     : Student rating (1–5)
-- Performance : Soft-skill scores (1–5 rubric) · trend per skill
-- Source      : Event system · Advisor portal
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity and quality: held (target 2 a month), attendance, rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = 'Workshop' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Performance: soft skills, first vs latest workshop =='
SELECT skill, round(AVG(first_score), 1) AS first, round(AVG(latest_score), 1) AS latest,
       round(AVG(latest_score - first_score), 1) AS change
FROM students.soft_skill_scores GROUP BY skill ORDER BY change DESC;
