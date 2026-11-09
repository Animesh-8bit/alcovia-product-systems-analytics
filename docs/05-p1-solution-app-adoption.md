# Problem 1: App Adoption, 2.15 → 30 min/day


## 1. The problem in one view

| | Today | Target |
|---|---|---|
| Avg counted minutes / student / day (all 20) | **2.15** | **30** |
| Total student-minutes / day | ~43 | 600 |
| Dormant students (no open in 14 days) | 7 of 20 | **≤5** |
| Students with an active streak | 1 | **10** (driven by linked focus) |
| Syllabus users this week | 1 | **10** (driven by linked focus) |

**Root cause:** the app pays students for activity that doesn't move their academics (Free Focus, the Realm through unlinked timers and PvP), and makes the activity that does move them cost planning and data entry with no immediate payoff (4–5 taps plus hour estimates, self-reported statuses, tasks not linked to the syllabus). The streak, the only daily-return mechanic, sits on that expensive path.

## 2. What counts as app time, and where 30 minutes comes from

### Counting rule
| Activity | Counts toward app time |
|---|---|
| Focus sessions (app in foreground, other apps blocked) | **Fully** |
| App-dependent program activities, e.g. the 8 PM quiz once it moves into the app | **Fully** |
| Games (Realm, Dragons, mini-games) | **Only up to 0.5× the student's study + quiz time that day** |
| Everything else (Home, Tasks, Profile, Wellness views, breathers) | **Not counted** |

**Counted minutes = Study + Quiz + min(Games, 0.5 × (Study + Quiz))**

The metric counts only time that builds the student: study and program activities, with games allowed to add at most half as much on top.

### Target shape of a student's day
| Block | Minutes counted |
|---|---|
| One focus session | 25 |
| 8 PM quiz | 5–7 |
| **Study + quiz** | **30–32** |
| Realm / dragons (capped at 0.5× of study + quiz, i.e. up to ~16) | bonus |

## 3. Solution

### Foundation: the Advisor portal pushes the plan
**Assumption:** the Advisor portal already exists and already pushes some data to the app (subjects and chapters).

The portal is the source of everything the student is asked to do. Advisors own the plan (adoption on the advisor side is by compliance), and the portal pushes it to each student's app. What the updated payload needs to carry:
- **Subjects and chapters** (already pushed).
- **The next due chapter and activity**, so the focus setup can suggest them first.
- **Estimated hours** per chapter/activity, where the advisor has them.
- **Advisor-assigned tasks, linked to a subject and chapter**, so completing them moves syllabus progress.

The student's job becomes **"focus on what's suggested"**, not "maintain a project plan".

### Shift 2: Fixes
- **Coin re-pay bug.** A roadmap item marked done → undone → done pays out again, repeatedly. Fix: every reward is paid **once per item** (a reward ledger keyed by item ID), which closes the whole class of exploits rather than one bug.
- **Device heating and lag in the Realm.** Conquering a fort on the 3D map made my Samsung A52s heat up and lag. Profile and fix on mid-range devices before anything else is tied to the Realm.

### Shift 3: Link focus to chapters, and reward only what moves academics
**Focus setup**:
> **Select time (default 25 min) → Select subject → Select chapter → Select activity → Start timer**

- Each step is **pre-suggested from the portal push** (next due subject, chapter and activity first). Skipping the link starts Free Focus.
- **Activities** (match the chapter rigour stages): Read textbook · Make notes · Textbook Qs · Worksheets · Revision · Past paper.
- **Hours are never required to start.** Time is **auto-logged to the chapter as hours spent**. If no estimate exists yet, the comparison of hours spent vs. estimated appears once one is added (by the advisor or the student).
- **Progress check when the timer ends:** one question, one tap: _"How far did you get with [activity] in [chapter]?"_, answered with the existing states (Not started · Have started · In progress · Almost done · Done).
- **New Task** (student-created) gets an optional subject/chapter field.
- **Log past session:** for study done without the timer, a quick entry (subject, chapter, activity, duration, progress state) records it at a **lower, unverified coin rate**, so timer-tracked study always pays more.

**Rewards:**
| Mechanic | Change |
|---|---|
| **Streak** | A day counts if the student completes **≥1 linked focus session (25 min)**. That's achievable, binary and in the student's control. The 1.33% syllabus velocity stays as a progress metric. |
| **Coins** | Linked focus earns the full (higher) rate. Free Focus earns a reduced rate. The chapter completion bonus stays. |
| **Realm** | After the performance fix, Realm actions need **energy**, which comes only from **linked focus minutes**, so conquering requires studying. PvP stays as the social layer. **No new Realm features.** |

**Realm energy (definition):**
- **What it is:** a second resource next to coins, used **only in the Realm**. Energy is needed to take Realm actions (attack or capture a fort, defend a castle).
- **How it's earned:** **only** from focus minutes linked to a chapter. Not from Free Focus, login, quests or rest
mode. Placeholder rate: **1 linked minute = 1 energy**.
- **What it costs:** e.g. capturing a fort = **25 energy** (one linked session). Placeholder costs, tuned with data.
- **Coins vs. energy:** coins still pay for upgrades and cosmetics. Energy decides whether you can *act*.
- **Why a separate resource:** coins come from many sources (Free Focus, login, quests), so gating the Realm on coi
ns wouldn't tie it to study. Energy has only one source, which makes the link clean without reworking the whole coin economy.
- **Cognitive load:** shown as one bar on the Realm screen, with a single line: _"Earn energy by focusing on a chapter."_
- **Note:** This might come as a double edged sword which rather make students inactive with the realm feature or make them start using focus as well.

### Shift 4: Breather sessions and chaining
After each completed focus session and its progress check:
1. **Suggest a breather** (the existing Rest Mode).
2. **Verify it where possible.** If the student has a smartband or watch, heart-rate data for the breather window confirms it happened. Without a wearable, completing it in the app still counts.
3. **Offer another focus session** to continue the same chapter, a one tap to continue, and also keep change subject/chapter option.
4. **Up to 3 cycles in a row, with a rising coin multiplier**, e.g. 1× → 1.25× → 1.5× (placeholder rates, tuned with data). The cap at 3 protects against burnout. The cap can be adjusted based on the time selected by the student, for now assumption is the student will take use the minimum 25 mins everytime.

### Shift 5: The 8 PM quiz moves into the app
- Since it's already a daily ritual, and it can count fully toward app time (5–7 min).
- A push notification a bit before 8 PM. After the quiz, a quick summary shows.

### Shift 6: Dormant students and wellness
- **Reactivation playbook for dormant students.** The advisor reaches out personally, the student gets a fresh plan through the portal and a streak restart, and a "welcome back" state replaces the backlog of overdue items and broken streaks.
- **Wellness - software fallback**: Read sleep and activity from **Apple Health** and **Android Health Connect**, which already collect such data points.

### Shift 7: Unusual-hours alert to the advisor
Linked focus logs **hours spent per subject and chapter**, so the system can spot when a student is spending unusual time on one subject and **alert their advisor for course correction**.

**What counts as "unusual"** (thresholds are placeholders, calibrated on the first weeks of data):
| Signal | Example trigger |
|---|---|
| Chapter hours vs. baseline | Hours spent > the baseline hours (baseline in case estimate is unavailable), with the chapter not yet "Done" |
| Chapter hours vs. estimate | Hours spent > **1.5×** the estimated hours, with the chapter not yet "Done" |
| Subject share vs. plan | A subject takes a much larger (or smaller) share of the week's focus time than the advisor's plan allocates |
| Student vs. cohort | Hours on a chapter > **2×** the cohort median for the same chapter |

**What happens:**
1. The system raises an alert to the **respective advisor** (via n8n), with the student, subject, chapter, hours spent vs. estimate, and the progress states logged.
2. The advisor identifies the **root cause** and corrects course:
   - **Academic** (the student is genuinely stuck): help them academically, e.g. re-plan the chapter, break it into smaller activities, arrange a peer session, or route to tuition/academy support.
   - **App usage** (the hours don't reflect real study): correct how the app is used, e.g. sessions linked to the wrong chapter, a timer left running, or sessions run for coins and streaks rather than study.
3. The advisor logs the cause and the action taken, so repeated patterns (a chapter many students struggle with, a common usage mistake) become visible.

## 4. Metrics

**North star:** average **counted** app minutes per student per day, across all 20 students (counting rule in §2).

| Type | Metric | Baseline | Target |
|---|---|---|---|
| North star | Avg counted min / student / day | 2.15 | **>30** |
| Driver: reach | % of students opening the app daily | from week-1 tracking | 85%+ |
| Driver: depth | Linked focus min / active student / day | from week-1 tracking | 25 mins|
| Driver: linking | % of focus minutes linked to a chapter/activity | from week-1 tracking | majority |
| Driver: habit | Students with an active streak | 1 | **>5** |
| Driver: syllabus | Students using Syllabus (via linked focus) this week | 1 | **>5** |
| Driver: chaining | Avg focus cycles per session start (max 3) | n/a | grows over time |
| Driver: ritual | Quiz completion rate (in app) | n/a | 80%+ |
| Driver: reactivation | Dormant students (14 days) | 7 | **≤5** |
| Input: advisors | Students with a current plan pushed from the portal | from week-1 process mapping | 100% |
| Input: advisors | Unusual-hours alerts actioned (cause + action logged) within 48 hours | n/a | 100% |
| Input: focus session fail | failed focus sessions | from week-1 tracking | ≤10% |

**Guardrails** (fix these first in case any of these break):
- **Crash-free sessions:** stays at 100%.
- **Device performance:** no heating or lag in the Realm
- **Focus session fail rate:** doesn't rise. If it does, sessions are too long or badly placed.
- **Sleep:** average sleep from Health data doesn't drop. We want more study, not later nights.
- **Coin integrity:** zero repeat payouts per item.
- **Game share:** game time stays within the 0.5× cap for most students (observation, no policing).

**"Stable state"** = 4 consecutive weeks at ≥30 counted min average.

## 5. Plan and timeline (12 weeks: 2 Nov 2026 – 22 Jan 2027)

Each phase ends on a **delivery and adoption gate** (what shipped, and whether it's being used), not on interim minute targets.

**Release rhythm (from the delivery process in P3):** weeks run Monday to Friday. A feature built in a week is released the **following Monday morning to 5 power user**, and to **everyone a week later** if guardrails hold. Bug fixes go out whenever they're ready. **Every feature release comes with a demo** (owned by me): a live walkthrough for the first 5 students and a short screen recording (1–2 min) for everyone else and for advisors, shared with the release note.

| Week/s | Dates | Full-Stack Engineer | Systems Designer | Myself | Gate |
|---|---|---|---|---|---|
| **1** | 2–6 Nov | Fix the **coin re-pay bug** (reward ledger, one payout per item). Fix **device heating and lag** in the Realm. Add **tracking**: per-feature time-in-app (study, quiz, games, other), the **counted-minutes** calculation with the 0.5× game cap, and a **linked / free** tag on every focus session. | Define the **process for Advisors to push data to students**: what is pushed (plan, next due chapter/activity, estimates, linked tasks), when (e.g. every Sunday), and who checks it went out. | **Interview 10 students** (active and dormant) and the advisors to set **baselines** and **recalibrate assumptions** (targets, coin rates, session length). | Bugs fixed and verified. Tracking live. Push process agreed. Baselines published. |
| **2** | 9–13 Nov | **Build data push from the Advisor portal to students**: next due chapter/activity, estimates, chapter-linked tasks. | Set up the **quiz content pipeline**: question bank structure and daily scheduling. | Write the specs for Week 3 (focus setup flow, progress check, reward rules) from the first week of tracking data. **Demo for advisors:** how their plan reaches the student's app (with the 16 Nov release). | Every student's app receives a current plan from the portal (released 16 Nov). |
| **3** | 16–20 Nov | **Linked focus:** focus setup (time → subject → chapter → activity), auto-log hours spent, progress check when the timer ends, task chapter link, log past session. **Rewards:** new streak rule, linked vs. free coin rates. | Advisor push SOP live; missing pushes flagged. | Write the specs for breather and chaining. Pick the first 5 students for the staged rollout. **Demo: linked focus and the new rewards**: live walkthrough for the first 5 students on 23 Nov, recording for everyone and for advisors before 30 Nov. | Linked focus built and verified. Released to 5 students on **23 Nov**. |
| **4** | 23–27 Nov | **Student dashboard (P4): event system**: host creates the event → synced to Google Calendar → host marks it done → rating push to attendees. On hand for linked-focus fixes. | Monitor the advisor push cadence. Draft the weekly review template with advisors (P4). | Watch guardrails for the first 5 linked-focus students daily. **Demo for hosts and advisors:** creating an event and marking it done (with the 30 Nov release). | Linked focus to **everyone on 30 Nov**. Event system released to hosts on 30 Nov. |
| **5** | 30 Nov – 4 Dec | **Breather after each session, chaining up to 3 cycles** with the coin multiplier. | Build the **unusual-hours alert** (n8n): thresholds calibrated on the first linked-focus hours data, alert to the respective advisor, advisor logs cause (academic / app usage) and action. | Tune coin rates from linking data. Agree alert thresholds with advisors. **Demo: breather and chaining**: live for the first 5 students on 7 Dec, recording for everyone before 14 Dec. | Breather + chaining to 5 students on **7 Dec**, everyone on **14 Dec**. |
| **6 – mid 7** (1.5 weeks) | 7–16 Dec | **8 PM quiz in the app** (on the Week-2 pipeline), push notification, "tomorrow's chapter" card. | Unusual-hours alert live. Start the **reactivation playbook** with advisors. | Tune multipliers from chaining data. Contact every dormant student with a fresh plan. **Demo: the 8 PM quiz in the app**: live for the first 5 students on 21 Dec, recording for everyone before 28 Dec. | Quiz to 5 students on **21 Dec**, everyone on **28 Dec**. **Unusual-hours alerts reaching advisors.** |
| **mid 7 – mid 10** (3 weeks) | 17 Dec – 6 Jan | **Apple Health / Health Connect read**, including breather verification. **Realm energy from linked focus minutes.** | **Student dashboard (P4):** Metabase setup, reporting tables, notes-reading pipeline (n8n + LLM), dashboard views. Continue the reactivation playbook. | Track quiz completion. Weekly metric review; per-student follow-ups. **Stability window starts 28 Dec.** **Demo: connecting Apple Health / Health Connect and Realm energy**: live for the first 5 students on 11 Jan, recording for everyone before 18 Jan. | Health read + Realm energy to 5 students on **11 Jan**, everyone on **18 Jan**. |
| **mid 10 – 12** (2.5 weeks) | 7–22 Jan | **Stabilise:** bug fixes and performance only, no new app features. Week 11 (11–15 Jan): **app data push to Metabase** (P4; no student-facing change). | Document SOPs; steady-state operation. Dashboards switched to real data. | Weekly review; per-student follow-ups. | **4 consecutive weeks ≥30 counted min (28 Dec – 22 Jan) = stable state.** Student dashboard v1 live in Week 12. |
| **Ongoing** | from Week 2, every day | — | **Question bank:** add and refresh questions **daily**. The bank is always evolving. | — | No day without a fresh quiz. |


For CBSE Class 10 students, Dec–Feb is pre-board and board-exam season. Advisor-planned, chapter-linked focus is most useful when the later phases land.

## 6. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Students skip the chapter link | Linked sessions earn the full coin rate, build the streak and power the Realm. The suggested subject, chapter and activity are pre-filled, so linking takes a few taps. Track the % linked weekly. |
| Advisors don't push plans on time | The SD-defined process flags missing pushes. The app falls back to suggesting the chapter with the lowest progress. |
| Students find suggestions too rigid | Any planned chapter can be picked, not just the top one. Free Focus remains available. |
| Reduced Free Focus coins feel like a penalty | Presented as "linked sessions earn more" rather than "free earns less", a free focus can earn full coins once the focus time is attached to a chapter even at a later time. |
| Game time inflates the north star | Counted only up to 0.5× study + quiz, by definition. |
| Breather loop pushes students past healthy limits | Soft cap at 3 cycles.|
| Too many alerts, so advisors start ignoring them | Thresholds calibrated on real data and reviewed after 2 weeks. Alerts limited to genuine outliers. Repeat alerts for the same chapter are grouped. |
| Exam season pushes the app aside | The app holds the exam plan, with advisor plans built around exam dates. |

## 7. What we're deliberately not doing
- Not changing the Home "Start Focus" button. Linking is added in the focus setup, not forced.
- Not adding new features to Wellness or the Realm before the core loop works. The Realm gets a performance fix and a link to study, nothing more.
- Not redesigning the whole app. The changes are concentrated on the portal push, focus setup, streak, coins and tasks.
- Not building parent-facing features (out of scope for this brief).
- Decluttering Home screen.
