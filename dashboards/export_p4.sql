-- Data for the static P4 student dashboard, exported from the reporting database as one JSON object.
-- Field names are the ones the HTML dashboard reads. Run: psql -At -f export_p4.sql > p4.json
SELECT json_build_object(
  'students', (SELECT json_agg(json_build_object('student_id', s.student_id, 'student', s.name, 'advisor', a.name, 'startup', s.startup,
                  'career_roadmap', s.career_roadmap, 'health_connected', s.health_connected) ORDER BY s.student_id)
               FROM students.students s JOIN ops.advisors a USING (advisor_id)),
  'student_kpis', (SELECT json_agg(json_build_object('month', to_char(month, 'YYYY-MM'), 'student_id', student_id, 'counted_min', counted_min,
                  'quiz_participation', quiz_participation_pct, 'quiz_accuracy', quiz_accuracy_pct, 'syllabus_pct', syllabus_pct, 'pace_pct', pace_pct,
                  'on_track', CASE WHEN syllabus_pct >= pace_pct - 2 THEN 'Yes' ELSE 'No' END, 'readiness', readiness, 'attendance_pct', attendance_pct,
                  'rating_given', rating_given, 'task_completion', task_completion_pct, 'deadline_adherence', deadline_adherence_pct,
                  'sleep_hrs', sleep_hrs, 'active_days_pct', active_days_pct) ORDER BY month, student_id) FROM students.student_month),
  'weekly', (SELECT json_agg(json_build_object('week', week, 'student_id', student_id, 'counted_min', counted_min, 'sleep_hrs', sleep_hrs,
                  'active_min', active_min) ORDER BY week, student_id) FROM students.student_week),
  'subjects', (SELECT json_agg(json_build_object('student_id', student_id, 'subject', subject, 'syllabus_pct', syllabus_pct, 'pace_pct', pace_pct,
                  'readiness', readiness, 'latest_score', latest_score, 'target', target_score, 'gap', latest_score - target_score) ORDER BY student_id, subject)
               FROM students.subject_progress),
  'soft_skills', (SELECT json_agg(json_build_object('student_id', student_id, 'skill', skill, 'first_workshop', first_score,
                  'latest_workshop', latest_score) ORDER BY student_id, skill) FROM students.soft_skill_scores),
  'delivery', (SELECT json_agg(json_build_object('month', to_char(d.month, 'YYYY-MM'), 'level', t.level, 'item', t.name,
                  'planned', NULLIF(d.planned, 0), 'held', NULLIF(d.held, 0) , 'held_pct', round(100.0 * d.held / NULLIF(d.planned, 0)),
                  'attendance_pct', d.attendance_pct, 'ratings_n', d.ratings_n, 'rating_avg', d.rating_avg, 'response_rate', d.response_rate)
                  ORDER BY d.month, t.event_type_id)
               FROM events.delivery_month d JOIN events.event_types t USING (event_type_id)),
  'alerts', (SELECT json_agg(json_build_object('alert_id', al.alert_id, 'month', to_char(al.raised_on, 'YYYY-MM'), 'date', al.raised_on,
                  'student_id', al.student_id, 'advisor', a.name, 'type', al.alert_type, 'detail', al.detail, 'status', al.status) ORDER BY al.alert_id)
             FROM ops.alerts al JOIN ops.advisors a USING (advisor_id)),
  'milestones', (SELECT json_agg(json_build_object('milestone_id', milestone_id, 'student_id', student_id, 'track', track, 'milestone', milestone,
                  'month_due', to_char(due_month, 'YYYY-MM'), 'status', status) ORDER BY milestone_id) FROM students.milestones),
  'parent_view', (SELECT json_agg(json_build_object('student_id', student_id, 'item', item, 'planned', planned, 'done', done, 'status', status)
                  ORDER BY student_id, item) FROM events.family_deliverables)
);
