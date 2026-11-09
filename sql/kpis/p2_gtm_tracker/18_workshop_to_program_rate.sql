-- KPI 18: Workshop → program rate
-- Definition : Share of workshop attendees in the period who later converted.
-- Formula    : Workshop attendees who converted ÷ workshop attendees in period
-- Source     : Workshop attendance + ClickUp + enrolments
-- Target     : Past result about 1 in 18 (5.6%)
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT COUNT(*)                                               AS workshop_attendees,
       COUNT(converted_on)                                    AS converted,
       round(100.0 * COUNT(converted_on) / NULLIF(COUNT(*), 0), 1) AS workshop_to_program_pct
FROM leads.v_lead_state, p
WHERE entry_path = 'Workshop' AND created_on BETWEEN p.s AND p.e;
