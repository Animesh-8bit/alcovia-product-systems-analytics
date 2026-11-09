-- Alcovia reporting database (Postgres 15+)
-- Six schemas, by domain:
--   students : families and students on the platform: profile, plan (enrolments), in-app progress
--   leads    : families still in the conversion stages, not on the platform yet
--   ads      : Meta campaigns, ads, daily spend, targets, landing pages        (restricted)
--   revenue  : invoices and payments                                          (restricted)
--   events   : workshops, quiz, advisor sessions and other things Alcovia runs, planned vs held
--   ops      : advisors, alerts sent to them, shared settings
-- n8n writes the tables; Metabase reads them. Derived numbers (percentages, totals, colours,
-- Scale / Refresh / Drop) are not stored: they come from views and the KPI queries.
-- Access (bottom of file): full_access sees everything; team_access sees students, leads, events, ops.

CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS events;
CREATE SCHEMA IF NOT EXISTS ads;
CREATE SCHEMA IF NOT EXISTS leads;
CREATE SCHEMA IF NOT EXISTS students;
CREATE SCHEMA IF NOT EXISTS revenue;

-- =====================================================================
-- ops: advisors, alerts, shared settings
-- =====================================================================

-- Settings every team can read: as-of date, days-to-decide target, colour thresholds
CREATE TABLE ops.settings (
    key         text PRIMARY KEY,
    label       text NOT NULL,
    value_num   numeric,
    value_text  text,
    CHECK (value_num IS NOT NULL OR value_text IS NOT NULL)
);

CREATE TABLE ops.advisors (
    advisor_id  serial PRIMARY KEY,
    name        text NOT NULL UNIQUE
);

-- =====================================================================
-- events: what Alcovia runs
-- =====================================================================

CREATE TABLE events.event_types (
    event_type_id  serial PRIMARY KEY,
    name           text NOT NULL UNIQUE,          -- 'Public workshop', '8 PM quiz', 'Advisor session', 'Mentor call', ...
    level          text NOT NULL CHECK (level IN ('Day', 'Week', 'Month', 'Quarter'))
);

-- One row per event. Public workshops carry seats sold (Razorpay payment links) and attendance (check-in).
-- Program events will also get per-student attendance and ratings once the event system is live (P4, week 4).
CREATE TABLE events.events (
    event_id       text PRIMARY KEY,              -- e.g. 'W05'
    event_type_id  int  NOT NULL REFERENCES events.event_types,
    held_on        date NOT NULL,
    venue          text,
    seats_sold     int,
    attended       int                            -- null until it has happened
);

-- Planned vs held per event type per month, with ratings (event system: host marks done, rating push)
CREATE TABLE events.delivery_month (
    month           date NOT NULL CHECK (extract(day FROM month) = 1),
    event_type_id   int  NOT NULL REFERENCES events.event_types,
    planned         int  NOT NULL DEFAULT 0,
    held            int  NOT NULL DEFAULT 0,
    attendance_pct  numeric(5,1),
    ratings_n       int  NOT NULL DEFAULT 0,
    rating_avg      numeric(3,1),
    response_rate   numeric(5,1),
    PRIMARY KEY (month, event_type_id)
);

-- =====================================================================
-- ads: Meta Ads, targets, landing pages (restricted)
-- =====================================================================

-- Money and ad targets: revenue and volume targets, prices, cost ceilings, refresh frequency, venue cost
CREATE TABLE ads.targets (
    key         text PRIMARY KEY,
    label       text NOT NULL,
    value_num   numeric NOT NULL
);

CREATE TABLE ads.campaigns (
    campaign_id   serial PRIMARY KEY,
    name          text NOT NULL UNIQUE,           -- e.g. 'Program: parent stories'
    campaign_type text NOT NULL CHECK (campaign_type IN ('Program', 'Workshop'))
);

CREATE TABLE ads.ads (
    ad_id        serial PRIMARY KEY,
    campaign_id  int  NOT NULL REFERENCES ads.campaigns,
    name         text NOT NULL UNIQUE,            -- creative name, passed in the ad's URL so leads match it
    started_on   date,
    ended_on     date                             -- null while running
);

-- Daily pull from Meta Ads (n8n, once a day)
CREATE TABLE ads.ad_daily (
    day          date NOT NULL,
    ad_id        int  NOT NULL REFERENCES ads.ads,
    spend        numeric(12,2) NOT NULL CHECK (spend >= 0),   -- ₹
    impressions  int  NOT NULL CHECK (impressions >= 0),
    clicks       int  NOT NULL CHECK (clicks >= 0),
    frequency    numeric(6,2) NOT NULL,           -- running impressions ÷ reach, as Meta reports it
    PRIMARY KEY (day, ad_id)
);

-- Landing-page health per day (Google Analytics 4 + Microsoft Clarity + PageSpeed Insights)
CREATE TABLE ads.page_daily (
    day             date NOT NULL,
    page            text NOT NULL,                -- 'Home', 'Program page', 'Workshop booking'
    visitors        int  NOT NULL,
    dropoffs        int  NOT NULL,                -- left without filling a form or booking
    load_mobile_s   numeric(5,2),
    load_desktop_s  numeric(5,2),
    PRIMARY KEY (day, page)
);

-- =====================================================================
-- leads: families in the conversion stages
-- =====================================================================

-- One row per family who came in: website form lead or workshop attendee.
-- n8n creates it from the lead webhook / attendance and keeps the stage dates in step with ClickUp.
-- The row stays after the family pays, so the funnel history is kept; the family record points back to it.
CREATE TABLE leads.leads (
    lead_id           text PRIMARY KEY,           -- e.g. 'L0425' (ClickUp task id in production)
    created_on        date NOT NULL,
    entry_path        text NOT NULL CHECK (entry_path IN ('Ads', 'Workshop')),
    source            text NOT NULL CHECK (source IN ('Paid', 'Organic', 'Workshop')),
    ad_id             int  REFERENCES ads.ads,    -- the ad behind the lead or the workshop seat, if any
    workshop_id       text REFERENCES events.events,
    qualified_on      date,                       -- ads: marked good fit · workshop: moved into nurture
    call_booked_on    date,                       -- discovery call (ads path)
    call_attended_on  date,
    interview_on      date,                       -- Ambition interview
    interview_outcome text CHECK (interview_outcome IN ('Passed', 'Rejected by Alcovia', 'Dropped by family')),
    architect_on      date,                       -- Architect session (Leadership-led)
    closed_on         date,                       -- left the funnel without paying
    closed_reason     text CHECK (closed_reason IN ('Not a fit', 'No-show', 'Rejected by Alcovia', 'Dropped by family', 'Went cold')),
    CHECK (entry_path = 'Workshop' OR workshop_id IS NULL)
);

-- =====================================================================
-- students: families and students on the platform
-- =====================================================================

CREATE TABLE students.families (
    family_id   text PRIMARY KEY,                 -- e.g. 'F0442'
    lead_id     text UNIQUE REFERENCES leads.leads,  -- null for families who joined before lead tracking
    city        text
);

CREATE TABLE students.students (
    student_id        text PRIMARY KEY,           -- e.g. 'S01' (advisor portal id)
    family_id         text NOT NULL REFERENCES students.families,
    name              text,
    grade             int,
    advisor_id        int  REFERENCES ops.advisors,
    startup           text,                       -- quarter theme project (Entrepreneurship)
    career_roadmap    text CHECK (career_roadmap IN ('Done', 'Not done')),
    health_connected  boolean NOT NULL DEFAULT false  -- Apple Health / Health Connect linked
);

-- Plan per student: the conversion state machine.
-- Trial (3 months) → Renewed (a Full program row starts on the trial's end date) or Did not renew.
-- A Full program row = converted. A student whose only row is a Trial is in the Trial state.
CREATE TABLE students.enrolments (
    enrolment_id  serial PRIMARY KEY,
    student_id    text NOT NULL REFERENCES students.students,
    plan          text NOT NULL CHECK (plan IN ('Trial', 'Full program')),
    started_on    date NOT NULL,                  -- date paid (trial or full), or the trial's end date for a renewal
    ends_on       date,                           -- trial end (start + 3 months)
    status        text NOT NULL CHECK (status IN ('In trial', 'Renewed', 'Did not renew', 'Active')),
    via_trial     boolean NOT NULL DEFAULT false, -- Full program reached by renewing a trial
    CHECK ((plan = 'Trial') = (status IN ('In trial', 'Renewed', 'Did not renew')))
);

-- Monthly figures per student (app, advisor portal, event system, notes extraction)
CREATE TABLE students.student_month (
    student_id              text NOT NULL REFERENCES students.students,
    month                   date NOT NULL CHECK (extract(day FROM month) = 1),
    counted_min             numeric(5,1),         -- counted app minutes per day
    quiz_participation_pct  numeric(5,1),
    quiz_accuracy_pct       numeric(5,1),
    syllabus_pct            numeric(5,1),         -- syllabus done
    pace_pct                numeric(5,1),         -- where the syllabus should be by now
    readiness               numeric(5,1),         -- chapter readiness score, 0–100
    attendance_pct          numeric(5,1),
    rating_given            numeric(3,1),         -- average rating the student gave sessions, 1–5
    task_completion_pct     numeric(5,1),
    deadline_adherence_pct  numeric(5,1),
    sleep_hrs               numeric(3,1),         -- null when health data is not connected
    active_days_pct         numeric(5,1),
    PRIMARY KEY (student_id, month)
);

CREATE TABLE students.student_week (
    student_id   text NOT NULL REFERENCES students.students,
    week         date NOT NULL CHECK (extract(isodow FROM week) = 1),  -- Monday
    counted_min  numeric(5,1),
    sleep_hrs    numeric(3,1),
    active_min   numeric(5,1),
    PRIMARY KEY (student_id, week)
);

CREATE TABLE students.subject_progress (
    student_id    text NOT NULL REFERENCES students.students,
    subject       text NOT NULL,
    syllabus_pct  numeric(5,1),
    pace_pct      numeric(5,1),
    readiness     numeric(5,1),
    latest_score  numeric(5,1),
    target_score  numeric(5,1),
    PRIMARY KEY (student_id, subject)
);

-- Soft skills scored 1–5 by the workshop host
CREATE TABLE students.soft_skill_scores (
    student_id    text NOT NULL REFERENCES students.students,
    skill         text NOT NULL,
    first_score   numeric(3,1),
    latest_score  numeric(3,1),
    PRIMARY KEY (student_id, skill)
);

-- Milestones from advisor notes (n8n + LLM extraction)
CREATE TABLE students.milestones (
    milestone_id  text PRIMARY KEY,
    student_id    text NOT NULL REFERENCES students.students,
    track         text NOT NULL,                  -- Entrepreneurship, Personal, Competition, Summer program
    milestone     text NOT NULL,
    due_month     date NOT NULL CHECK (extract(day FROM due_month) = 1),
    status        text NOT NULL CHECK (status IN ('Done', 'In progress', 'Missed'))
);

-- What Alcovia owes each family this quarter (parent view): planned vs done per item
CREATE TABLE events.family_deliverables (
    student_id  text NOT NULL REFERENCES students.students,
    item        text NOT NULL,                    -- e.g. 'Advisor sessions', 'Personal branding shoots'
    planned     int  NOT NULL,
    done        int  NOT NULL,
    status      text CHECK (status IN ('On schedule', 'Slightly behind', 'Behind')),
    PRIMARY KEY (student_id, item)
);

-- Alerts n8n sends to advisors
CREATE TABLE ops.alerts (
    alert_id    text PRIMARY KEY,
    student_id  text NOT NULL REFERENCES students.students,
    advisor_id  int  REFERENCES ops.advisors,
    raised_on   date NOT NULL,
    alert_type  text NOT NULL,                    -- 'Unusual hours', 'Deviation', 'Missed deadline'
    detail      text NOT NULL,
    status      text NOT NULL CHECK (status IN ('Open', 'Actioned'))
);

-- =====================================================================
-- revenue: invoices and payments (restricted)
-- =====================================================================

-- Program invoices from Razorpay. Issued after the Architect session, while the family is still a lead.
CREATE TABLE revenue.invoices (
    invoice_id  text PRIMARY KEY,                 -- e.g. 'INV-0001'
    lead_id     text NOT NULL REFERENCES leads.leads,
    plan        text NOT NULL CHECK (plan IN ('Full program', 'Trial')),
    amount      numeric(12,2) NOT NULL,
    issued_on   date NOT NULL,
    paid_on     date                              -- null = unpaid
);

-- Every payment received (Razorpay webhook). Revenue is counted on paid_on.
CREATE TABLE revenue.payments (
    payment_id    text PRIMARY KEY,
    paid_on       date NOT NULL,
    payment_type  text NOT NULL CHECK (payment_type IN ('Full program', 'Trial', 'Trial renewal', 'Workshop seat')),
    amount        numeric(12,2) NOT NULL CHECK (amount > 0),
    lead_id       text REFERENCES leads.leads,    -- program payments (null for workshop seats)
    invoice_id    text REFERENCES revenue.invoices,
    workshop_id   text REFERENCES events.events,  -- workshop seats
    entry_path    text NOT NULL CHECK (entry_path IN ('Ads', 'Workshop')),
    ad_id         int  REFERENCES ads.ads,
    CHECK ((payment_type = 'Workshop seat') = (workshop_id IS NOT NULL))
);

-- =====================================================================
-- Raw tables (production grain). n8n fills these from the student app, advisor portal,
-- event system, ClickUp content tracker and the notes extraction. The P4 KPI queries read them.
-- =====================================================================

-- events: status per event, who took part, ratings, follow-ups
ALTER TABLE events.events ADD COLUMN status text NOT NULL DEFAULT 'Held' CHECK (status IN ('Held', 'Not held', 'Upcoming'));
ALTER TABLE events.events ADD COLUMN host text;

CREATE TABLE events.event_attendance (
    event_id             text NOT NULL REFERENCES events.events,
    student_id           text NOT NULL REFERENCES students.students,
    role                 text NOT NULL DEFAULT 'Student' CHECK (role IN ('Student', 'Parent')),
    attended             boolean NOT NULL,
    participation_score  numeric(2,1),            -- host-marked, 1–5 (pod sessions)
    PRIMARY KEY (event_id, student_id, role)
);

-- 1-tap ratings after the host marks the event done
CREATE TABLE events.event_ratings (
    event_id    text NOT NULL REFERENCES events.events,
    student_id  text NOT NULL REFERENCES students.students,
    rater       text NOT NULL CHECK (rater IN ('Student', 'Parent')),
    rating      int  NOT NULL CHECK (rating BETWEEN 1 AND 5),
    PRIMARY KEY (event_id, student_id, rater)
);

-- Actions agreed in an advisor session or mentor call (from the advisor's notes)
CREATE TABLE events.event_follow_ups (
    follow_up_id  serial PRIMARY KEY,
    event_id      text NOT NULL REFERENCES events.events,
    student_id    text NOT NULL REFERENCES students.students,
    action        text NOT NULL,
    due_on        date,
    completed_on  date
);

-- students: app, health, timetable, tasks, exams, chapters and the quarter's projects
CREATE TABLE students.timetable_slots (           -- advisor-built weekly timetable, pushed to the app
    slot_id      serial PRIMARY KEY,
    student_id   text NOT NULL REFERENCES students.students,
    slot_date    date NOT NULL,
    subject      text NOT NULL,
    planned_min  int  NOT NULL,
    created_on   date NOT NULL                    -- when the advisor last updated it
);

CREATE TABLE students.app_sessions (
    session_id      serial PRIMARY KEY,
    student_id      text NOT NULL REFERENCES students.students,
    started_at      timestamp NOT NULL,
    minutes         numeric(5,1) NOT NULL,
    kind            text NOT NULL CHECK (kind IN ('Focus', 'Quiz', 'Game')),
    linked_slot_id  int REFERENCES students.timetable_slots   -- focus started from a timetable slot
);

CREATE TABLE students.quiz_attempts (
    event_id    text NOT NULL REFERENCES events.events,    -- the day's 8 PM quiz
    student_id  text NOT NULL REFERENCES students.students,
    topic       text,
    score_pct   numeric(5,1) NOT NULL,
    rating      int CHECK (rating BETWEEN 1 AND 5),         -- optional rating at the end of the quiz
    PRIMARY KEY (event_id, student_id)
);

CREATE TABLE students.health_daily (              -- Apple Health / Health Connect
    student_id  text NOT NULL REFERENCES students.students,
    day         date NOT NULL,
    sleep_hrs   numeric(3,1),
    active_min  int,
    PRIMARY KEY (student_id, day)
);

CREATE TABLE students.pulse_responses (           -- 1-tap weekly questions, e.g. 'Did your timetable work this week?'
    student_id  text NOT NULL REFERENCES students.students,
    asked_on    date NOT NULL,
    question    text NOT NULL,
    answer      int  NOT NULL CHECK (answer BETWEEN 1 AND 5),
    PRIMARY KEY (student_id, asked_on, question)
);

CREATE TABLE students.tasks (
    task_id        serial PRIMARY KEY,
    student_id     text NOT NULL REFERENCES students.students,
    assigned_on    date NOT NULL,
    due_on         date NOT NULL,
    completed_on   date,
    estimated_hrs  numeric(4,1),
    actual_hrs     numeric(4,1)
);

CREATE TABLE students.score_targets (
    student_id        text NOT NULL REFERENCES students.students,
    subject           text NOT NULL,
    exam_type         text NOT NULL CHECK (exam_type IN ('Formative', 'Unit test', 'Half-yearly')),
    target_pct        numeric(5,1) NOT NULL,
    parent_confirmed  boolean NOT NULL DEFAULT false,
    PRIMARY KEY (student_id, subject, exam_type)
);

CREATE TABLE students.exam_results (
    student_id  text NOT NULL REFERENCES students.students,
    subject     text NOT NULL,
    exam_type   text NOT NULL CHECK (exam_type IN ('Formative', 'Unit test', 'Half-yearly')),
    exam_on     date NOT NULL,
    score_pct   numeric(5,1) NOT NULL,
    PRIMARY KEY (student_id, subject, exam_type)
);

-- Chapters in the advisor portal; stages 1–5 of the readiness score (P4 §3)
CREATE TABLE students.chapters (
    student_id          text NOT NULL REFERENCES students.students,
    subject             text NOT NULL,
    chapter             text NOT NULL,
    stages_done         int  NOT NULL DEFAULT 0 CHECK (stages_done BETWEEN 0 AND 5),
    marked_complete_on  date,
    readiness           numeric(5,1),
    PRIMARY KEY (student_id, subject, chapter)
);

CREATE TABLE students.sprints (                   -- monthly sprint for students behind their timeline
    sprint_id           serial PRIMARY KEY,
    student_id          text NOT NULL REFERENCES students.students,
    month               date NOT NULL CHECK (extract(day FROM month) = 1),
    chapters_planned    int NOT NULL,
    chapters_recovered  int NOT NULL DEFAULT 0,
    rating              int CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE students.roadmaps (
    student_id  text NOT NULL REFERENCES students.students,
    kind        text NOT NULL CHECK (kind IN ('Career', 'Personal')),
    made_on     date,
    rating      int CHECK (rating BETWEEN 1 AND 5),
    PRIMARY KEY (student_id, kind)
);

CREATE TABLE students.competitions (
    student_id   text NOT NULL REFERENCES students.students,
    quarter      date NOT NULL,                   -- first day of the quarter
    competition  text NOT NULL,
    outcome      text CHECK (outcome IN ('Participated', 'Shortlisted', 'Placed')),
    prep_rating  int CHECK (prep_rating BETWEEN 1 AND 5),
    PRIMARY KEY (student_id, quarter, competition)
);

CREATE TABLE students.summer_applications (
    student_id    text NOT NULL REFERENCES students.students,
    program       text NOT NULL,
    submitted_on  date,                           -- null = planned, not yet submitted
    outcome       text CHECK (outcome IN ('Pending', 'Accepted', 'Rejected')),
    PRIMARY KEY (student_id, program)
);

-- Personal branding and podcast (ClickUp content tracker)
CREATE TABLE students.content_items (
    item_id           serial PRIMARY KEY,
    student_id        text NOT NULL REFERENCES students.students,
    kind              text NOT NULL CHECK (kind IN ('Shoot', 'Clip', 'Podcast')),
    due_month         date NOT NULL CHECK (extract(day FROM due_month) = 1),
    done_on           date,
    published_on      date,                       -- clips on Instagram, podcast episodes
    student_approved  boolean,                    -- clips: student approves the edit
    prep_rating       int CHECK (prep_rating BETWEEN 1 AND 5)  -- podcast: host rates preparation
);

-- ops: what the advisor did for each student each month
CREATE TABLE ops.advisor_reviews (
    student_id          text NOT NULL REFERENCES students.students,
    month               date NOT NULL CHECK (extract(day FROM month) = 1),
    reevaluation_done   boolean NOT NULL,         -- monthly re-evaluation of chapters
    targets_aligned     boolean NOT NULL,         -- score targets aligned with parents
    support_assigned    boolean NOT NULL DEFAULT false,  -- tutor / academy support when triggered
    PRIMARY KEY (student_id, month)
);

-- =====================================================================
-- Indexes
-- =====================================================================
CREATE INDEX ON leads.leads (created_on);
CREATE INDEX ON leads.leads (ad_id);
CREATE INDEX ON revenue.payments (paid_on);
CREATE INDEX ON revenue.payments (payment_type);
CREATE INDEX ON ads.ad_daily (ad_id, day);
CREATE INDEX ON students.enrolments (student_id);
CREATE INDEX ON students.student_month (month);
CREATE INDEX ON ops.alerts (raised_on);
CREATE INDEX ON students.app_sessions (student_id, started_at);
CREATE INDEX ON students.health_daily (day);
CREATE INDEX ON events.events (held_on);

-- =====================================================================
-- Access
--   full_access : product, data, analytics, leadership. Everything.
--   team_access : advisors, GTM team. students, leads, events, ops; no ads or revenue.
--                 The GTM team sees campaign numbers only through Metabase dashboards shared with them.
--   n8n_writer  : the pipelines. Read and write everything.
-- Metabase uses two connections: one as full_access, one as team_access.
-- =====================================================================
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'full_access') THEN CREATE ROLE full_access NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'team_access') THEN CREATE ROLE team_access NOLOGIN; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'n8n_writer')  THEN CREATE ROLE n8n_writer  NOLOGIN; END IF;
END $$;

GRANT USAGE ON SCHEMA students, leads, events, ops, ads, revenue TO full_access, n8n_writer;
GRANT USAGE ON SCHEMA students, leads, events, ops TO team_access;

GRANT SELECT ON ALL TABLES IN SCHEMA students, leads, events, ops, ads, revenue TO full_access;
GRANT SELECT ON ALL TABLES IN SCHEMA students, leads, events, ops TO team_access;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA students, leads, events, ops, ads, revenue TO n8n_writer;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA students, leads, events, ops, ads, revenue TO n8n_writer;

-- Tables added later get the same access
ALTER DEFAULT PRIVILEGES IN SCHEMA students, leads, events, ops GRANT SELECT ON TABLES TO full_access, team_access;
ALTER DEFAULT PRIVILEGES IN SCHEMA ads, revenue GRANT SELECT ON TABLES TO full_access;
ALTER DEFAULT PRIVILEGES IN SCHEMA students, leads, events, ops, ads, revenue GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO n8n_writer;
