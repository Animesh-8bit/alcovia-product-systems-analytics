"""Made-up raw rows (production grain) for the 20 sample students, Jul–Sep 2027.

Called from build_seed.py. Each student's raw rows are drawn from their monthly figures in the P4 sample
(counted minutes, quiz participation and accuracy, sleep, active days, task completion, deadline adherence,
syllabus, readiness), and event counts match events.delivery_month, so the raw tables and the summaries agree.
"""
import calendar
import datetime as dt
import random

R = random.Random(11)
D = dt.date
MONTHS = [D(2027, 7, 1), D(2027, 8, 1), D(2027, 9, 1)]
SUBJECTS = ["English", "Hindi", "Maths", "Science", "Social Science"]


def days_of(m):
    return [D(m.year, m.month, d) for d in range(1, calendar.monthrange(m.year, m.month)[1] + 1)]


def clamp(v, lo, hi):
    return max(lo, min(hi, v))


def rating_around(avg):
    return int(clamp(round(R.gauss(avg, 0.7)), 1, 5))


def build(p4_load, insert, type_id):
    students = p4_load("students")
    sids = [s["student_id"] for s in students]
    kpi = {(k["student_id"], k["month"]): k for k in p4_load("student_kpis")}
    subj = {(s["student_id"], s["subject"]): s for s in p4_load("subjects")}
    health = {s["student_id"]: s["health_connected"] for s in students}
    mk = lambda m: m.strftime("%Y-%m")
    iso = lambda d: d.isoformat() if d else None

    # ---------------- events from delivery_month: planned rows, first `held` of them held ----------------
    events, attendance, ratings, follow_ups = [], [], [], []
    quiz_events = {}            # day -> event_id
    student_events = {}         # (student, type, month) -> [(event_id, held)]
    n = 0

    def new_event(tname, day, held):
        nonlocal n
        n += 1
        eid = f"E{n:04d}"
        events.append((eid, type_id[tname], iso(day), None, None, None, "Held" if held else "Not held", None))
        return eid

    def rate(eid, people, d, rater="Student"):
        for sid in people:
            if R.random() < (d["response_rate"] or 0) / 100:
                ratings.append((eid, sid, rater, rating_around(d["rating_avg"] or 4)))

    behind = {}  # month -> students furthest behind their pace (sprint candidates)
    for m in MONTHS:
        behind[m] = sorted(sids, key=lambda s: kpi[(s, mk(m))]["syllabus_pct"] - kpi[(s, mk(m))]["pace_pct"])

    for d in p4_load("delivery"):
        m = D.fromisoformat(d["month"] + "-01")
        planned, held, t = d["planned"] or 0, d["held"] or 0, d["item"]
        if not planned:
            continue
        held_flags = [True] * held + [False] * (planned - held)
        R.shuffle(held_flags)
        days = days_of(m)
        weekdays = [x for x in days if x.weekday() < 6]
        att = (d["attendance_pct"] or 100) / 100
        if t == "8 PM quiz":
            for day, h in zip(days, held_flags):
                quiz_events[day] = new_event(t, day, h)
        elif t in ("Advisor session", "Mentor call", "Personal branding shoot", "Podcast shoot", "Competition prep", "Monthly sprint"):
            # one student per event
            pool = behind[m] if t == "Monthly sprint" else sids
            for i, h in enumerate(held_flags):
                sid = pool[i % len(pool)]
                day = R.choice(weekdays) if t != "Advisor session" else weekdays[min(len(weekdays) - 1, (i // len(sids)) * 6 + R.randint(0, 4))]
                eid = new_event(t, day, h)
                student_events.setdefault((sid, t, m), []).append((eid, h, day))
                if h:
                    attendance.append((eid, sid, "Student", True, None))
                    rate(eid, [sid], d)
                    if t == "Advisor session":
                        for a in range(R.randint(1, 2)):
                            due = day + dt.timedelta(7)
                            done = due + dt.timedelta(R.randint(-4, 2)) if R.random() < 0.7 else None
                            follow_ups.append((eid, sid, R.choice(["Finish worksheet", "Revise chapter", "Book tutor slot", "Update timetable"]),
                                               iso(due), iso(done if done and done <= D(2027, 9, 30) else None)))
                    if t == "Mentor call" and R.random() < 0.8:
                        follow_ups.append((eid, sid, "Follow-up action logged after the call", iso(day + dt.timedelta(10)), iso(day + dt.timedelta(R.randint(2, 9)))))
        else:
            # group events: workshops, pods (5), peer sessions (2), parent–child, out-of-city
            size = {"Pod session": 5, "Peer session": 2}.get(t, len(sids))
            for i, h in enumerate(held_flags):
                day = R.choice([x for x in days if x.weekday() == 5])
                eid = new_event(t, day, h)
                group = sids[(i * size) % len(sids):][:size] if size < len(sids) else sids
                if not h:
                    continue
                present = [s for s in group if R.random() < att]
                for s in group:
                    score = round(R.uniform(2, 5), 1) if t == "Pod session" and s in present else None
                    attendance.append((eid, s, "Student", s in present, score))
                rate(eid, present, d)
                if t == "Parent–child workshop":
                    parents = [s for s in group if R.random() < 0.75]
                    for s in group:
                        attendance.append((eid, s, "Parent", s in parents, None))
                    rate(eid, parents, d, "Parent")
                if t == "Peer session":
                    rate(eid, present, d)  # both students rate (already one each); kept as is

    insert("events.events", ["event_id", "event_type_id", "held_on", "venue", "seats_sold", "attended", "status", "host"], events)
    insert("events.event_attendance", ["event_id", "student_id", "role", "attended", "participation_score"], attendance)
    insert("events.event_ratings", ["event_id", "student_id", "rater", "rating"], list({(e, s, r): (e, s, r, v) for e, s, r, v in ratings}.values()))
    insert("events.event_follow_ups", ["event_id", "student_id", "action", "due_on", "completed_on"], follow_ups)

    # ---------------- timetable, app sessions, quiz, health, pulse ----------------
    slots, sessions, quiz, health_rows, pulses = [], [], [], [], []
    slot_id = 0
    for sid in sids:
        for m in MONTHS:
            k = kpi[(sid, mk(m))]
            mins = k["counted_min"]
            p_day = clamp(mins / 34, 0.35, 0.97)
            for day in days_of(m):
                week_start = day - dt.timedelta(day.weekday())
                updated = R.random() < (0.9 if mins >= 22 else 0.65)
                today_slot = None
                if day.weekday() < 6 and updated:
                    slot_id += 1
                    today_slot = slot_id
                    slots.append((slot_id, sid, iso(day), SUBJECTS[(day.toordinal() + int(sid[1:])) % 5], 45, iso(week_start)))
                if R.random() < p_day:
                    focus = max(5, R.gauss(mins * 0.75 / p_day, 6))
                    parts = [focus] if focus < 35 else [focus * 0.6, focus * 0.4]
                    for j, part in enumerate(parts):
                        linked = today_slot if j == 0 and today_slot and R.random() < 0.75 else None
                        sessions.append((sid, f"{iso(day)} {17 + j * 2}:{R.randint(0, 59):02d}", round(part, 1), "Focus", linked))
                    if R.random() < 0.5:
                        sessions.append((sid, f"{iso(day)} 21:{R.randint(0, 59):02d}", round(R.uniform(3, mins * 0.3), 1), "Game", None))
                eid = quiz_events.get(day)
                if eid and R.random() < k["quiz_participation"] / 100:
                    quiz.append((eid, sid, SUBJECTS[day.toordinal() % 5], round(clamp(R.gauss(k["quiz_accuracy"], 12), 0, 100), 1),
                                 rating_around(4.1) if R.random() < 0.25 else None))
                    sessions.append((sid, f"{iso(day)} 20:0{R.randint(0, 9)}", round(R.uniform(3, 6), 1), "Quiz", None))
                if health[sid] and k["sleep_hrs"] is not None:
                    active = R.randint(60, 110) if R.random() < k["active_days_pct"] / 100 else R.randint(15, 59)
                    health_rows.append((sid, iso(day), round(clamp(R.gauss(k["sleep_hrs"], 0.8), 4, 11), 1), active))
                if day.weekday() == 6 and R.random() < 0.7:
                    pulses.append((sid, iso(day), "Did your timetable work this week?", int(clamp(round(R.gauss(3 + mins / 25, 0.8)), 1, 5))))
    # 1-tap rating of the quarter's theme (Entrepreneurship), asked on the last day of the quarter
    for sid in sids:
        if R.random() < 0.8:
            pulses.append((sid, "2027-09-30", "How was this quarter's theme?", rating_around(4.2)))
    # keep only quiz attempts on held quizzes
    held_quiz = {e[0] for e in events if e[6] == "Held"}
    insert("students.timetable_slots", ["slot_id", "student_id", "slot_date", "subject", "planned_min", "created_on"], slots)
    insert("students.app_sessions", ["student_id", "started_at", "minutes", "kind", "linked_slot_id"], sessions)
    insert("students.quiz_attempts", ["event_id", "student_id", "topic", "score_pct", "rating"], [q for q in quiz if q[0] in held_quiz])
    insert("students.health_daily", ["student_id", "day", "sleep_hrs", "active_min"], health_rows)
    insert("students.pulse_responses", ["student_id", "asked_on", "question", "answer"], pulses)

    # ---------------- tasks, targets, exams, chapters, reviews, sprints ----------------
    tasks, targets, exams, chapters, reviews, sprints = [], [], [], [], [], []
    exam_dates = {"Formative": D(2027, 7, 20), "Unit test": D(2027, 8, 20), "Half-yearly": D(2027, 9, 25)}
    for sid in sids:
        for m in MONTHS:
            k = kpi[(sid, mk(m))]
            for day in days_of(m):
                if day.weekday() == 0:
                    for _ in range(3):
                        due = day + dt.timedelta(R.randint(3, 6))
                        est = R.choice([1, 1.5, 2, 3])
                        done = None
                        if R.random() < k["task_completion"] / 100:
                            done = due - dt.timedelta(R.randint(0, 2)) if R.random() < k["deadline_adherence"] / 100 else due + dt.timedelta(R.randint(1, 4))
                        tasks.append((sid, iso(day), iso(due), iso(done), est, round(est * clamp(R.gauss(1.15, 0.3), 0.5, 2.5), 1) if done else None))
            reviews.append((sid, iso(m), R.random() < 0.85, R.random() < 0.9, k["readiness"] < 55))
        parents_aligned = R.random() < 0.75          # parents confirm the student's whole set of targets
        for s in SUBJECTS:
            sp = subj[(sid, s)]
            for e, day in exam_dates.items():
                if R.random() < 0.98:
                    targets.append((sid, s, e, sp["target"], parents_aligned))
                score = sp["latest_score"] if e == "Half-yearly" else round(clamp(R.gauss(sp["latest_score"], 6), 20, 100), 1)
                exams.append((sid, s, e, iso(day), score))
            done = round(12 * sp["syllabus_pct"] / 100)
            for c in range(1, 13):
                if c <= done:
                    stages = 5 if R.random() < 0.8 else R.randint(3, 4)
                    chapters.append((sid, s, f"Chapter {c}", stages, iso(D(2027, 7, 1) + dt.timedelta(R.randint(0, 88))),
                                     round(clamp(R.gauss(sp["readiness"], 8), 0, 100), 1)))
                else:
                    chapters.append((sid, s, f"Chapter {c}", R.randint(0, 2), None, None))
    for (sid, t, m), evs in student_events.items():
        if t == "Monthly sprint":
            for eid, h, day in evs:
                rec = R.choices([0, 1, 2, 3], [1, 2, 4, 3])[0] if h else 0
                sprints.append((sid, iso(m), 3, rec, rating_around(4.3) if h and R.random() < 0.75 else None))
    insert("students.tasks", ["student_id", "assigned_on", "due_on", "completed_on", "estimated_hrs", "actual_hrs"], tasks)
    insert("students.score_targets", ["student_id", "subject", "exam_type", "target_pct", "parent_confirmed"], targets)
    insert("students.exam_results", ["student_id", "subject", "exam_type", "exam_on", "score_pct"], exams)
    insert("students.chapters", ["student_id", "subject", "chapter", "stages_done", "marked_complete_on", "readiness"], chapters)
    insert("ops.advisor_reviews", ["student_id", "month", "reevaluation_done", "targets_aligned", "support_assigned"], reviews)
    insert("students.sprints", ["student_id", "month", "chapters_planned", "chapters_recovered", "rating"], sprints)

    # ---------------- roadmaps, competitions, summer programs, content ----------------
    roadmaps, comps, summer, content = [], [], [], []
    for s in students:
        sid = s["student_id"]
        if s["career_roadmap"] == "Done":
            roadmaps.append((sid, "Career", iso(D(2027, 7, 1) + dt.timedelta(R.randint(0, 80))), R.randint(3, 5)))
        else:
            roadmaps.append((sid, "Career", None, None))
        roadmaps.append((sid, "Personal", iso(D(2027, 7, R.randint(3, 10))) if R.random() < 0.9 else None, None))
        if R.random() < 0.4:
            for prog in R.sample(["Young Founders Lab", "Global Leaders Summer", "STEM Discovery Camp", "Design Thinking School"], 2):
                sub = R.random() < 0.6
                summer.append((sid, prog, iso(D(2027, 8, R.randint(1, 28))) if sub else None,
                               R.choice(["Pending", "Accepted", "Rejected"]) if sub else None))
    for (sid, t, m), evs in student_events.items():
        for eid, h, day in evs:
            if t == "Competition prep":
                comps.append((sid, iso(D(2027, 7, 1)), f"Inter-school {R.choice(['business plan', 'debate', 'science'])} competition",
                              R.choice(["Participated", "Participated", "Shortlisted", "Placed"]) if h else None, R.randint(3, 5) if h else None))
            if t == "Personal branding shoot":
                content.append((sid, "Shoot", iso(m), iso(day) if h else None, None, None, None))
                if h:
                    pub = day + dt.timedelta(R.randint(5, 10))
                    content.append((sid, "Clip", iso(m), iso(pub - dt.timedelta(2)), iso(pub) if R.random() < 0.9 and pub <= D(2027, 9, 30) else None,
                                    R.random() < 0.85, None))
            if t == "Podcast shoot":
                content.append((sid, "Podcast", iso(m), iso(day) if h else None, iso(day + dt.timedelta(14)) if h and day + dt.timedelta(14) <= D(2027, 9, 30) else None,
                                None, R.randint(2, 5) if h else None))
    insert("students.roadmaps", ["student_id", "kind", "made_on", "rating"], roadmaps)
    insert("students.competitions", ["student_id", "quarter", "competition", "outcome", "prep_rating"],
           list({(c[0], c[1], c[2]): c for c in comps}.values()))
    insert("students.summer_applications", ["student_id", "program", "submitted_on", "outcome"], summer)
    insert("students.content_items", ["student_id", "kind", "due_month", "done_on", "published_on", "student_approved", "prep_rating"], content)
