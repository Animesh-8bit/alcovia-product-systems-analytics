-- KPI 24: Discovery call show-up rate
-- Definition : Booked discovery calls that were attended (ads path).
-- Formula    : Calls attended ÷ calls booked
-- Source     : ClickUp + Smallest.ai
-- Target     : Proposal: 80%+
-- Access     : full_access, team_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e)
SELECT COUNT(call_booked_on) AS booked, COUNT(call_attended_on) AS attended,
       round(100.0 * COUNT(call_attended_on) / NULLIF(COUNT(call_booked_on), 0)) AS show_up_pct
FROM leads.leads, p
WHERE created_on BETWEEN p.s AND p.e;
