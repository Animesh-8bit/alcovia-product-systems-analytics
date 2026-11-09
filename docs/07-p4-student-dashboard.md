# Problem 4: Student Dashboard

## 1. The problem

Every week, progress for each student is discussed and written into a **ClickUp document** or scattered across ClickUp folders. The notes are **qualitative**, so:
- there is no **average view across all students**,
- trends can't be seen week over week,
- nobody can tell, at a glance, whether Alcovia **delivered** what it promised, whether students **liked** it, and how students **performed**.

**Note:** With 20–40 students, one student can move a % by 5 points or more, so every % is shown with its count (e.g. "72% · 13 of 18").

## 2. KPI framework

**Collection method:** 
- _Automatic_ = recorded by a system with no human step
- _1-tap_ = the student or parent answers one in-app question
- _Host closes event_ = host taps "Mark as done" (§5), which also sends the rating push
- _Advisor notes_ = what the advisor already writes in the ClickUp doc, read by n8n + LLM (§4).

| Level | Item | Collection method | Quantity (did Alcovia conduct it?) | Quality (did they like it?) | Performance (how did they perform?) | Source |
|---|---|---|---|---|---|---|
| **Day** | **Timetable management** | Automatic · 1-tap weekly pulse | % of students with an advisor-built weekly timetable, updated this week | "Did your timetable work this week?" (1–5) | **Timetable adherence:** % of planned self-study slots that had a linked focus session | Advisor portal · Student app |
| **Day** | **Daily 8 PM quiz** | Automatic · 1-tap rating | Quizzes published at 8 PM ÷ days in period | Rating at the end of each quiz | **Participation** (% of students who took it) · **accuracy %** · trend per topic | Student app |
| **Day** | **Focus time** | Automatic | % of students with the advisor's plan pushed to the app (so linked focus is possible) | **Voluntary repeat use:** % of students running focus on ≥5 days a week | **Counted minutes per day** vs. the 30-min target · streak length | Student app · Advisor portal |
| **Day** | **Active minutes** | Automatic (one-time permission) | % of students with health data connected | _Not rated: passive data_ | Days with ≥60 active minutes | Apple Health / Health Connect via the app |
| **Day** | **Active recovery (sleep)** | Automatic (one-time permission) | Same connection rate as above | _Not rated: passive data_ | Average sleep hours vs. 8–10 h (teen guideline) · nights below 7 h | Apple Health / Health Connect via the app |
| **Week** | **Weekly advisor session** | Host closes event · Advisor notes | Sessions held ÷ planned, per student | Student rating after the session (1–5) | Actions agreed last week that were completed | Event system · ClickUp notes → n8n + LLM |
| **Week** | **Score targets** (Formative, UT, mid-term / half-yearly) | Automatic · Advisor notes | % of students with targets set for every subject and exam type, **and aligned with parents** | Parent confirmation of targets (yes / no) | **Actual vs. target** per exam · % of subjects at or above target | Advisor portal · Student app · ClickUp notes → n8n + LLM |
| **Week** | **Time management** | Automatic | % of students with tasks assigned this week | _Covered by the timetable pulse_ | **Task completion rate** · **deadline adherence** · **time-estimation accuracy** (actual ÷ estimated hours) | Student app · Advisor portal |
| **Week** | **Syllabus completion** | Automatic | % of students whose syllabus is loaded in the advisor portal | _—_ | % syllabus complete vs. pace target (**25% per quarter**) | Advisor portal · Student app |
| **Week** | **Rigour of completion** | Automatic · Advisor notes | Monthly re-evaluation done by the advisor (yes / no per student) | _—_ | **Chapter readiness score** (§3) · **rigour adherence:** % of chapters marked complete that went through all 5 stages | Student app · ClickUp notes → n8n + LLM |
| **Week** | **Monthly sprints** (missed timelines) | Advisor notes · 1-tap rating | Sprints created ÷ students with missed timelines | Student rating of the sprint | % of sprint chapters recovered by month end | ClickUp notes → n8n + LLM · Student app |
| **Week** | **Advisor inputs** | Automatic · Advisor notes | % of students with targets aligned · deviation alerts sent when performance deviates by X% · tutor / academy support assigned when triggered | _—_ | _Inputs, not student outcomes: shown in the advisor view_ | Advisor portal · n8n alerts · ClickUp notes → n8n + LLM |
| **Month** | **Workshop 1 & 2** (career discovery) | Host closes event · host rubric in the portal | Workshops held ÷ 2 per month · attendance % | Student rating (1–5) | **Soft-skill scores** (engagement, teamwork, crisis management, adaptability, public speaking and the other tracked skills), scored by the host on a 1–5 rubric · trend per skill across workshops | Event system · Advisor portal |
| **Month** | **Pod session** | Host closes event | Pods held ÷ planned · attendance % | Student rating (1–5) | Host-marked participation (1–5) | Event system · Advisor portal |
| **Month** | **Peer session** | Host closes event | Sessions set up by the advisor ÷ planned | Rating by both students | _Learning exchange, not scored_ | Event system |
| **Month** | **Mentor call** | Host closes event · Advisor notes | Calls held ÷ 1 per student per month | Rating (already in the app) | Follow-up action logged after the call (yes / no) | Event system · Student app · ClickUp notes → n8n + LLM |
| **Month** | **Personal branding** | Status change in the content tracker · 1-tap approval | **Shoots done ÷ planned per student · clips published on Instagram (managed by Alcovia)** | Student approves the edited clip (yes / no) | _Not a student metric: this is Alcovia's accountability. Shown to **parents** as done / on schedule._ | ClickUp content tracker · Student app |
| **Quarter** | **Podcast shoot** | Host closes event · status change in the content tracker | Shoots held ÷ students due this quarter · episodes published | Student rating | Host rating of preparation (questions researched, 1–5) | Event system · ClickUp content tracker |
| **Quarter** | **Competition prep** | Advisor notes · 1-tap rating | % of students entered in a competition this quarter | Student rating of the prep | Outcome: participated / shortlisted / placed | ClickUp notes → n8n + LLM · Student app |
| **Quarter** | **Parent–child workshop** | Host closes event | Held (1 per quarter) · % of families with a parent present | **Student and parent** ratings | _Bonding outcome, not scored: parent rating is the measure_ | Event system |
| **Quarter** | **Out-of-city experience** | Host closes event | Held (1 per quarter) · attendance % | Student rating | _Experience, not scored_ | Event system |
| **Quarter** | **Theme: social work** | Advisor notes · 1-tap rating at quarter end | Group projects running ÷ groups | Student rating at quarter end | Monthly milestones hit ÷ planned | ClickUp notes → n8n + LLM · Student app |
| **Quarter** | **Theme: entrepreneurship** | Advisor notes · 1-tap rating at quarter end | Students with an active startup ÷ students in the theme | Student rating at quarter end | Monthly milestones hit ÷ planned | ClickUp notes → n8n + LLM · Student app |
| **Quarter** | **Summer program applications** | Advisor notes | Applications planned per student | _—_ | Applications submitted ÷ planned · acceptances | ClickUp notes → n8n + LLM |
| **Roadmap** | **Career** | Advisor notes · 1-tap rating | % of students with a career roadmap made | Student rating of the roadmap | **Done / not done** (binary, per the brief) | ClickUp notes → n8n + LLM · Student app |
| **Roadmap** | **Personal** | Advisor notes | % of students with monthly milestones set | _—_ | Monthly milestones hit ÷ due | ClickUp notes → n8n + LLM |
| **Roadmap** | **Academic** | _See the Week rows_ | _See the Week rows_ | _See the Week rows_ | _See the Week rows_ | — |
| **Roadmap** | **Syllabus completion** | Automatic | — | — | On track vs. 25% per quarter (yes / no per subject) | Advisor portal · Student app |
| **Roadmap** | **Rigour of completion** | Automatic | — | — | Rigour adherence (Week rows) | Student app |


## 3. Chapter readiness score

Today every stage is self-reported and accepted as is. The score counts the self-reported stages but **requires evidence for the stages that matter most**:

| Stage (from the brief) | Points | Evidence needed |
|---|---|---|
| 1. Chapter reading | 20 | Self-reported progress check at the end of a linked focus session (P1) |
| 2. Notes / Revisions | 20 | Same |
| 3. Practice questions, accuracy >70% | 20 | **Score entered** (worksheet / chapter questions) ≥70% |
| 4. Timed past paper | 20 | Linked focus session with activity "Past paper" (the timer proves the time limit) **+ score entered** |
| 5. Readiness, accuracy >80% | 20 | Mock / test score ≥80% |

- **Chapter readiness score** = sum of points (0–100). 
- **Subject readiness** = average across chapters due by now. 
- Stages 3–5 require scores to calculate.

## 4. Turning ClickUp notes into numbers

Advisors keep doing what they do today: **write the weekly review for each student in a ClickUp doc**, in their own words. No new forms or sheets. An n8n workflow reads the notes and uses an LLM to turn them into structured records.

**What the LLM extracts** (only what no system already captures; focus, quiz, chapter progress, targets and attendance come from the app and portal):
- **Scores:** subject, exam type, marks, max marks, chapter (if mentioned)
- **Actions and sprints:** action, owner (student / advisor / parent / tutor), due date, status
- **Milestones:** track (personal, career roadmap, social work, entrepreneurship, competition, summer program), milestone, status, outcome
- **Parent alignment** on targets (yes / no) and whether the monthly re-evaluation happened
- **Concerns:** each tagged by topic (academic / motivation / health / family / app usage), sentiment, and whether follow-up is needed

```
Advisor updates the ClickUp doc
      │  (n8n: ClickUp trigger on doc update, plus a nightly sweep)
      ▼
LLM extracts → JSON against a fixed schema
      │  every field carries the sentence it came from + a confidence score
      ▼
Validation in n8n: known student? subject and chapter match the portal?
                   marks ≤ max? date in the current term?
      │                                   │
   passes                        fails or low confidence
      ▼                                   ▼
Written to the database            1-tap "confirm / fix" card to the
                                   advisor in ClickUp; written only
                                   after confirmation
```

**The notes will carry less over time.** Today, much of what's discussed in a weekly review exists only in the advisor's notes. As the app-adoption work (P1) ships, more of it moves into the app and is recorded automatically.

So the LLM workflow gradually narrows to what is actually qualitative (concerns, actions and sprints, milestones, parent alignment), and the share of dashboard numbers that depend on it keeps shrinking.

**Notes:**
- **No new habit for advisors.** The input is the same doc they write today.
- **Fixed schema and validation.** Student IDs are matched against the advisor portal's lists of students, subjects and chapters; impossible values are rejected.
- If a note doesn't mention something, the field stays empty rather than being inferred.
- Each record keeps the doc it came from, so any value on the dashboard can be clicked back to the advisor's note.
- Low-confidence or failed records go to a confirm / fix card, never straight into the dashboard.
- An n8n alert goes to the advisor if a student has no weekly review by coming Monday.
- The last few weeks of existing ClickUp reviews are run through the same workflow once, so the dashboard can start with trends.

## 5. Recording events and ratings with minimal human work

### Feature : Events are created in the Alcovia system, not in Google Calendar

A calendar slot can say 2 hours while the event runs 3, so sending the rating at the calendar end time doesn't work. The fix (FSE build):

```
Host creates the event in the Alcovia system (advisor portal)
      │  sync
      ▼
Google Calendar invite to students (and parents, where relevant)
      │
      ▼
Event happens ── Host taps "Mark as done" when it actually ends
      │           
      ▼
Rating push to attendees only (students; parents too for the parent–child workshop)
      │
      ▼
Reminder after 24 h if not rated · quantity and quality update automatically
```

An n8n alert goes to the host if an event is **still open 2 hours after its scheduled end**, so nothing is left unclosed.

## 6. Where it lives: Metabase

**Metabase** (open source, self-hosted): no licence cost, only hosting. Dashboards and questions can be changed by the team without engineering work, once the tables are syncing to metabase thorugh a pipeline.

```
Student app DB ─┐
Advisor portal ─┤
Event system ───┼──► Postgres (reporting schema) ──► Metabase dashboards
n8n + LLM:      │
ClickUp notes ──┘
Health data ────┘
```

- n8n checks each source daily; if a feed hasn't updated on schedule, the SD is notified (P3, stage 8).

## 7. Dashboard design

**Global filters on every view:** time range (week / month / quarter / custom) · cohort · advisor · student · theme.

### View 1: Program overview (Leadership, monthly review)
- **Top row, one tile per lens:** % of planned sessions held · average rating (response rate) · % of students on track academically. Each with count and change vs. last period.
- **Delivery heatmap:** rows = program items (day → quarter), columns = weeks, colour = held vs. planned. Gaps in delivery show up instantly.
- **Quality table:** items ranked by average rating, lowest first, with response rate.
- **Cohort performance:** average counted minutes, quiz accuracy, syllabus completion vs. pace, % of subjects at target.

### View 2: Cohort average (Advisors, weekly review; the view that's missing today)
- **Student table:** one row per student, with their theme tag (group / startup name), columns = key KPIs (counted minutes, quiz participation, syllabus vs. pace, readiness score, attendance, last rating), with red / amber / green against target. Sorted worst first, so the review starts with the students who need it.
- **Cohort average line** on each KPI, so any student can be compared to the group.
- **Alerts panel:** deviation alerts, unusual-hours alerts (P1), missed deadlines this week.

### View 3: Student drill-down (Advisor, during the weekly session)
- Subject cards: syllabus % vs. pace, readiness score, latest score vs. target.
- Trends: counted minutes, quiz accuracy, sleep and active minutes over 8 weeks.
- Program participation: attended / missed per item, with ratings given.
- Theme tag at the top of the profile, with the student's group or startup and its milestones.
- Roadmaps: career (done / not done), personal milestones.
- Last week's actions and whether they were completed.

### View 4: Parent accountability view
What Alcovia owes the family: sessions held, attendance, shoots done and clips published, podcast and parent–child workshop status, plus the headline academic numbers.

## 8. Owners and timeline (dashboard v1 live in Week 12: 18–22 Jan 2027)

This runs alongside the app-adoption plan (P1), with the same team. The engineer's time is mostly on P1, so the dashboard uses the engineer in **two short slots** (Week 4 and Week 11), and the systems designer carries the rest. Same release rhythm as P3: built in a week, released the following Monday.

| Week/s | Dates | Full-Stack Engineer | Systems Designer | Myself | Gate |
|---|---|---|---|---|---|
| **2–3** | 9–20 Nov | — | — | **Design:** finalise KPI definitions (§2), targets and the 4 dashboard views (§7) with advisors and Leadership. | KPIs and views signed off. |
| **4** | 23–27 Nov | **Event system:** host creates the event → synced to Google Calendar → host marks it done → rating push to attendees (parents for the parent–child workshop). | Define the **extraction schema** (fields the LLM pulls from the notes) and the validation rules with advisors. | Brief hosts on closing events. | Event system live for hosts on **30 Nov**. Ratings and held-vs-planned data start collecting. |
| **5 – mid 7** | 30 Nov – 16 Dec | — | Collect sample notes from advisors to test the extraction. | Check rating response rate and events left open; fix the flow if needed. | Every event closed by its host; response rate tracked. |
| **mid 7 – mid 10** | 17 Dec – 6 Jan | — | **Metabase** self-hosted · **reporting tables** (§6) · **notes workflow** (ClickUp → n8n + LLM → JSON, validation, confirm / fix cards, backfill of recent reviews) · **dashboard views** built on event and rating data, test data for the rest · **data-freshness alerts**. | Review the views with 1–2 advisors; adjust. | All 4 views built. Notes workflow reading the weekly reviews. |
| **11** | 11–15 Jan | **App data push** to the reporting database: focus sessions, quiz attempts, chapter progress, scores, health data. | Switch dashboards to real data; **reconcile numbers against the source systems**. | Spot-check each student's numbers against the app. | Numbers match the sources. |
| **12** | 18–22 Jan | Fixes only. | Walk advisors through the views; monitor freshness alerts. | Run the first weekly review on the dashboard; first Leadership review on View 1. | **Dashboard v1 live.** Weekly review runs from the dashboard |

## 9. Risks

| Risk | Mitigation |
|---|---|
| LLM extracts a value wrongly | Fixed schema + validation against portal lists; every value keeps its source sentence; low-confidence records go to the advisor to confirm, never straight in |
| Notes are too vague to extract from | Fields stay empty rather than guessed; the dashboard shows the gap, and the advisor sees which fields were missing |
| Advisor skips a week | Alert if a student has no weekly review by Monday |
| Hosts forget to mark events done | Open-event alert 2 h after scheduled end |
| Low rating response | One tap, attendees only, one reminder; show response rate next to every rating |
| Self-reported stages inflate readiness | Stages 3–5 need a score; readiness is 40 at most on self-report alone |
| Small cohort makes % noisy | Counts shown with every %; trends over 4+ weeks before judging |
