-- KPI 17: Trials ending in 30 days
-- Definition : Trials still running that end within 30 days. Not period-based.
-- Formula    : Trial end date − today, for trials in the Trial state, where ≤ 30
-- Source     : students.enrolments
-- Target     : Yellow 16–30, amber 8–15, red ≤ 7 days left
-- Access     : full_access, team_access

SELECT e.student_id, f.lead_id, e.ends_on,
       e.ends_on - ops.as_of() AS days_left,
       CASE WHEN e.ends_on - ops.as_of() <= ops.setting('renewal_red')   THEN 'Red'
            WHEN e.ends_on - ops.as_of() <= ops.setting('renewal_amber') THEN 'Amber'
            ELSE 'Yellow' END AS colour
FROM students.enrolments e
JOIN students.students s USING (student_id)
JOIN students.families f USING (family_id)
WHERE e.status = 'In trial' AND e.ends_on - ops.as_of() <= ops.setting('renewal_yellow')
ORDER BY days_left;
