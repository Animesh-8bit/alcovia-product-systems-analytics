# Alcovia Student App: Feature Breakdown

_Source: assignment brief (feature map and adoption data, 30 Aug – 13 Oct 2026). Student app only; parent, advisor, counselor and admin apps are out of scope._
_Legend: **[F]** = from the brief · **[I]** = my inference · **—** = no data given_

---

## 1. Headline numbers

| Metric | Value |
|---|---|
| Avg usage today | **2.15 min** |
| Target (stable state) | **30 min**, a **~14×** gap |
| Students active, last 45 days | 20 |
| Students active, any given week | 11–17 (13 this week) |
| Dormant (no open in 14 days) | 7 of 20 (35%) |
| Features available | ~25, across 5 areas |
| Stability | Zero app failures, so the gap is **not a reliability problem** |

**[Decided] Definition:** 2.15 min = **per day, averaged across all 20 students** (dormant included).
- Whole base today: 20 × 2.15 ≈ **43 min/day in total**. Target: 20 × 30 = **600 min/day**.
- The 7 dormant students contribute 0, so even perfect engagement from the active 13 would need about 46 min/day each. **Reactivating the dormant students is part of the problem, not a side task.**
- **[Decided] Instrumentation:** we only have *opens* per feature, not time per feature. We can't tell which feature produces the 2.15 minutes. Per-feature time-in-app tracking is a prerequisite for managing a time-based target.

## 2. Navigation

Three bottom tabs (**Home · Study · Tasks**), a **Realm** button and a **Profile** reached from the avatar on Home.
- **[I]** Plan features (Goals, Mentor sessions, Calendar) and all of Wellness have no tab of their own, so they're likely reached via Home cards or Discover. This may matter for discoverability.

## 3. Feature inventory with usage

| Area | Feature | What the student does | Usage, 45 days (n=20) | Usage, 7 days (n=13) | Signal |
|---|---|---|---|---|---|
| **Home** | Home dashboard | Feed of cards: focus score, syllabus pace, attendance, exams, sessions, calendar, wellness, nudges | 20 (100%) | 13 (100%) | 🟢 Universal, the landing screen |
| | Daily login reward | Collect daily coins | — | — | |
| | Discover / Feature guide | Browse all features | — | — | |
| | Welcome carousel and guided tour | First-run onboarding | — | — | |
| **Focus & game** _(area: 15 / 7)_ | **The Realm** | Conquer territories on a 3D globe | **13 (65%)** | **Most used this week** | 🟢 Strongest pull |
| | Focus Timer | Focus sessions that hatch dragon eggs | 11 opened | **5 regular** | 🟡 Tried, half drop |
| | Dragons | Collect dragons | — | — | |
| | AlcoCoins and Streak | Coins; daily streak | Streak: **1** | — | 🔴 |
| | Rankings | Leaderboard | **1** | — | 🔴 |
| | Side Quests | Advisor-assigned quests | — | — | |
| **Study** _(area: 13 / 2)_ | Syllabus | Chapters: update tasks, run revisions, record scores | 10 | **1** | 🔴 Steep fade |
| | Attendance | Check attendance | — | — | |
| | Study Planner | Hours budget | — | **0** | 🔴 |
| | Exams | Exam countdowns | — | — | |
| | Academic history | Past records | — | **0** | 🔴 |
| **Plan** _(area: 13 / 6)_ | Tasks / To-dos | Own and advisor-assigned tasks | — | — | 🟡 (area holds at 46%) |
| | Goals & Roadmap | Quarterly and monthly goals | **1 completion** | — | 🔴 |
| | Mentor sessions | See and rate sessions | — | — | |
| | Calendar | Day plan, Google-synced | — | — | |
| **Wellness** _(area: 12 / 2)_ | Wellness dashboard | Recovery, sleep, activity | — | — | 🔴 |
| | Wellness extras | Rest Mode, League, feed, badges, trends | — | — | |
| | WHOOP connect | Link wearable | **1 connected** | — | 🔴 Hard dependency |
| | Insights and screen time | Mood, habit and screen-time insights | — | — | |
| **Other** _(area: 8 / 4)_ | Notifications | Push alerts that deep-link to a screen | — | — | |
| | Profile | Journey card, stats, settings, mentors, support | — | — | |

### Area retention: of the students who tried an area in 45 days, how many used it this week

Calculation: **students who used the area this week ÷ students who tried it in the last 45 days**. Both counts come from the brief's chart. This week sits inside the 45-day window, so this week's users are a subset of the triers and the ratio is valid.

| Area | Tried, 45 days (of 20) | Used this week (of 13 active) | Retention |
|---|---|---|---|
| Home | 20 | 13 | 65% (only lost the dormant 7) |
| Other (profile, notifications) | 8 | 4 | 50% |
| Focus & game | 15 | 7 | 47% |
| Plan | 13 | 6 | 46% |
| Wellness | 12 | 2 | **17%** |
| Study | 13 | 2 | **15%** |

_Study and Wellness keep about 1 in 6 of the students who tried them. Game and Plan keep about half._

## 4. Mapping: what the program needs vs. what the app has (from Problem 4)

| Program rigour item | Cadence | App feature today | Gap |
|---|---|---|---|
| Timetable management (post-school timeboxing) | Daily | Calendar, Study Planner | ❌ Planner unused. **[My hypothesis] It goes unused because of the manual effort it needs.** |
| **8 PM general-knowledge quiz** | Daily | **None** | ❌ Tracked in Attendance, but no in-app quiz screen |
| Focus time (phone locked; only whitelisted parent calls allowed) | Daily | Focus Timer | ✅ **Blocks** other apps (confirmed) |
| Active minutes (strain) | Daily | Wellness via WHOOP | ⚠️ WHOOP was added in staging only. **Direction: phone health platforms** (see note below) |
| Sleep and recovery | Daily | Wellness via WHOOP | ⚠️ Same |
| Score targets per exam type | Weekly/yearly | Exams, Academic history | Partial; no target-vs-actual view mentioned |
| Syllabus rigour (read → notes → practice >70% → past papers → ready >80%) | Weekly | Syllabus (tasks, revisions, scores) | ⚠️ [?] Are the 5 rigour stages modelled explicitly? |
| Task completion, deadline adherence, time-estimate accuracy | Weekly | Tasks / To-dos | Metrics not surfaced to the student |
| Monthly sprints for missed timelines | Monthly | Side Quests? | Unclear |
| Workshops (2/month), pod session, peer session | Monthly | Calendar + Attendance | ⚠️ **Booked outside the app, synced in as calendar invites.** No recap or soft-skill score in the app |
| Mentor call | Monthly | Mentor sessions | ✅ Exists |
| Personal branding shoots | Monthly | Calendar | ⚠️ Booked outside the app, synced as a calendar invite. Nothing after the event |
| Podcast, competition, parent workshop, out-of-city trip | Quarterly | Calendar | ⚠️ Same |

**Note on wearables (my recommendation: software over hardware):** instead of integrating each brand, read from the phone's health platform. **Apple HealthKit** on iOS and **Android Health Connect** on Android, which Samsung Health and Garmin can write into. That's one integration per OS. It covers sleep, steps and active minutes for students without a premium wearable, and needs the student's permission.

**Note on offline events:** everything offline (workshops, shoots, podcasts) reaches the app as a **Google Calendar invite**. So the calendar sync is effectively the app's event feed: whatever happens around those events (reminders, recap, attendance, rating) can hook into the calendar entries.
| Career / personal / academic roadmaps | Ongoing | Goals & Roadmap | 1 completion in 45 days |

## 5. Patterns in the data (observations, not diagnosis)

1. **Use concentrates where the app gives something back right away.** Home (a feed) and the Realm (a game) are used. Features that need the student to *enter* data (Syllabus updates, Study Planner, Goals) fade.
2. **Game mechanics are split.** The Realm is the top feature, but Streak and Rankings, the mechanics meant to create daily return and social pull, each have only one user.
3. **Focus Timer is the bridge feature.** It's the only one that links the game (dragon eggs) to the program's core rigour (focus time), and it already has a regular core of 5 students.
4. **Time arithmetic:** a Home check or Realm session is short. **[I]** The only feature that can structurally produce 30 min/day is a focus session (25–50 min blocks). Whether locked-phone focus time counts as "app usage" needs confirming, because it decides whether the 30-min target is about focus sessions or engagement.
5. **Hardware gate:** Wellness depends on owning and connecting a WHOOP. With 1 connection, the area can't work for 19 of 20 students.
6. **Many offline program moments are absent from the app.** The quiz, workshops, pods, shoots and podcasts are what students experience as Alcovia, yet none appear in the app.
7. **Breadth:** about 25 features for about 20 students is more than one feature per user.

## 6. Questions → answers

| # | Question | Answer |
|---|---|---|
| 1 | How is 2.15 min measured? | **Per day, averaged across all 20 students** (§1) |
| 2 | Does the Focus Timer lock the phone? | **Yes, it blocks** |
| 3 | Where does the 8 PM quiz run? | Open. Tracked in Attendance, but not playable in the app |
| 4 | Are the syllabus rigour stages modelled? | **Partly** (see 03, §1): steps exist; the accuracy gates (70%, 80%) and timed past papers don't |
| 5 | Who assigns Tasks and Side Quests? | **Alcovia advisors.** Adoption on the advisor side is 100% by compliance, so it isn't a risk |
| 6 | Per-feature time or only opens? | **Only opens.** Per-feature time tracking is a gap to close |
| 7 | What do parents see? | **Unknown.** Nothing shared about the parent app, so out of scope |
| 8 | How do offline events reach the app? | **Booked outside the app, synced as calendar invites** (workshops, shoots, podcasts) |
| 9 | Wearables beyond WHOOP? | WHOOP was a staging addition. Direction: Apple Health and Android Health Connect |
