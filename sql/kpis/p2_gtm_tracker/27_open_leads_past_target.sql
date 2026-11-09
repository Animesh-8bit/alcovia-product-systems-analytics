-- KPI 27: Open leads past target
-- Definition : Leads still in play today that came in more than 45 days ago. Not period-based.
-- Formula    : COUNT(leads) where not paid, not closed, today − created > 45
-- Source     : ClickUp + enrolments
-- Target     : 0
-- Access     : full_access, team_access

SELECT lead_id,
       CASE entry_path WHEN 'Ads' THEN 'Ads and website form' ELSE 'Workshop' END AS came_from,
       CASE WHEN architect_on     IS NOT NULL THEN 'Architect session'
            WHEN interview_on     IS NOT NULL THEN 'Ambition interview'
            WHEN call_attended_on IS NOT NULL THEN 'Discovery call held'
            WHEN call_booked_on   IS NOT NULL THEN 'Discovery call booked'
            WHEN qualified_on     IS NOT NULL THEN 'Qualified or in nurture'
            ELSE 'New lead' END                                                   AS furthest_step,
       COALESCE(architect_on, interview_on, call_attended_on, call_booked_on, qualified_on, created_on) AS last_step_on,
       ops.as_of() - created_on                                                   AS days_open
FROM leads.v_lead_state
WHERE first_paid_on IS NULL AND closed_on IS NULL
  AND ops.as_of() - created_on > ops.setting('days_to_decide')
ORDER BY days_open DESC;
