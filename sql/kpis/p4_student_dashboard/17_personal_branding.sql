-- P4 KPI 17: Personal branding  (Month)
-- Collection  : Status change in the content tracker · 1-tap approval
-- Quantity    : Shoots done ÷ planned per student · clips published on Instagram
-- Quality     : Student approves the edited clip (yes / no)
-- Performance : Not a student metric: Alcovia's accountability, shown to parents as done / on schedule
-- Source      : ClickUp content tracker · Student app
-- Access      : full_access, team_access
\ir ../../_month.sql

\echo '== Quantity: shoots done of planned, rating =='
WITH m AS (SELECT :'month'::date AS s, (:'month'::date + interval '1 month - 1 day')::date AS e)
SELECT SUM(d.held) AS held, SUM(d.planned) AS planned,
       round(100.0 * SUM(d.held) / NULLIF(SUM(d.planned), 0)) AS held_pct,
       round(SUM(d.rating_avg * d.ratings_n) / NULLIF(SUM(d.ratings_n), 0), 1) AS avg_rating, SUM(d.ratings_n) AS ratings,
       round(SUM(d.attendance_pct * d.held) / NULLIF(SUM(d.held) FILTER (WHERE d.attendance_pct IS NOT NULL), 0)) AS attendance_pct
FROM events.delivery_month d JOIN events.event_types t USING (event_type_id), m
WHERE t.name = 'Personal branding shoot' AND d.month BETWEEN m.s AND m.e AND d.planned > 0;

\echo '== Quantity: clips published on Instagram =='
SELECT COUNT(*) FILTER (WHERE published_on IS NOT NULL) AS clips_published, COUNT(*) AS clips
FROM students.content_items WHERE kind = 'Clip' AND due_month = :'month'::date;

\echo '== Quality: clips approved by the student =='
SELECT COUNT(*) FILTER (WHERE student_approved) AS approved, COUNT(*) AS clips,
       round(100.0 * COUNT(*) FILTER (WHERE student_approved) / NULLIF(COUNT(*), 0)) AS pct
FROM students.content_items WHERE kind = 'Clip' AND due_month = :'month'::date;

\echo '== Parent view: status this quarter =='
SELECT status, COUNT(*) AS students
FROM events.family_deliverables WHERE item IN ('Personal branding shoots', 'Clips published on Instagram')
GROUP BY status ORDER BY status;
