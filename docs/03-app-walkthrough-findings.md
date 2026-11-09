# Alcovia Student App: Walkthrough Findings

_Source: 74 screenshots of the TestFlight (staging) build, test account, 30 Oct 2026. Saved in `app-screenshots/`._
_Caveat: staging data isn't production. The test account has 200K coins, WHOOP connected and a staff Google calendar, so **numbers are ignored**. This note covers flows, rules, copy and data entry only._

---

## 1. Questions from the feature breakdown, now answered

| Question (from 02) | What the app shows |
|---|---|
| Does the Focus Timer lock the phone? | **Yes, it blocks (confirmed by the team).** The on-screen copy still says "Leaving the app will fail your session", and "Give up" costs −50 coins with a cracked egg. |
| Where does the 8 PM quiz live? | It's **tracked** (Attendance has a "Quizzes 0/0" tile; the coin rules list "Quizzes: bonus based on accuracy"), but **no quiz screen** appeared anywhere. Taking the quiz in the app doesn't seem possible. |
| Are the 5 syllabus rigour stages modelled? | **Yes, but soft (confirmed).** Each stage is **self-reported by the student and accepted as is, with no verification.** Each chapter has Study mode (Read textbook → Watch videos → Make notes → Textbook Qs → Worksheets → Worksheet checked?), Revision mode (revise-notes and worksheet attempts) and Scores (worksheet or mock-test marks). **Missing:** the >70% accuracy gate, timed past papers, and the >80% "readiness" score. |
| Does wellness work without WHOOP? | Couldn't check, because the test account has WHOOP connected. Still worth a look on a fresh account. |

## 2. Screen-by-screen notes

| Area | What's there | Notes |
|---|---|---|
| **Onboarding** | 11-step coach-mark tour over Home, plus a notification permission prompt | Long. The tour explains Home cards instead of getting the student to do one thing. It ends with "Start Focusing!" |
| **Home** | Today's Focus (score / goal 120, recovery, strain, Start Focus) → Daily Velocity (0.3% vs. 1.33% target, "Slightly behind") → Streak → Study Planner → Attendance and Syllabus rings → Sessions → Google Calendar → Wellness link → Daily Habit Analysis (24-hour breakdown vs. "Top 30") → 3 insight warnings → Dragon Sanctuary → Discover | ~12 cards in one long scroll. The first screen is good: focus is the main call to action. |
| **Explore / Feature guide** | 16 features in 4 groups | The grouping differs from the tabs (Calendar sits under Study; Tasks sits under "Compete & Connect"). |
| **Focus Timer** | Pick minutes (25 default) → pick egg (rarer eggs unlock at 35/45/60/75/90 min; a special egg is reserved for a 30-day streak) → countdown with a quote | The best-designed loop in the app. Failing is very visible: cracked egg, red "Session Failed". The staging Dragon Pit shows "4 dragons · 64 failed". |
| **AlcoCoins** | Balance, earned today, ledger, "Rules & Lore" | Earn rates: focus **15 / 25 min**, login 5, daily target 50, chapter 100, rest mode 5, plus streak multipliers up to 2×. Realm spends: upgrades **100–1,000**. Achievements pay **+2,000** for conquest. "Dragon Rewards Shop arriving soon." |
| **Realm** | 3D globe, castles, seasons (Season 4, 8 days left), season objectives, Power Rankings, Hall of Fame, Sanctuary, Quests | Rich. Rival notifications ("Your castle was taken!") are the only social or competitive hook that works. |
| **Side Quests** | One advisor-style quest ("Extraordinary Streak: ≥1.33% syllabus daily for 100 days") plus game achievements (War God, Legendary Citadel, Deep Scholar…) | Most quests are Realm achievements, not advisor quests. |
| **Study** | 9 subjects with % rings, Add Exam, Performance History | Exam types are **Term 1 / Mid-Sem / Term 2 / End-Sem**: college terms, not the school constructs in the brief (Formative, UT, Half-yearly). "Performance History" lists past exams **with no marks**. |
| **Chapter** | 6 core tasks, each with a 5-state status (Not started → Have started → In progress → Almost done → Done) and estimated/actual hours; Revision attempts; Score entry | **Very heavy data entry.** Per chapter: about 6 tasks × status taps × hour estimates, plus revisions and marks. |
| **Study Planner** | Weekly budget (20 h), quarterly bars, Actual vs. Expected syllabus (2.7% vs. 77.8%, gap **−75.1%** in red), per-subject hour estimates | Only 2 of 9 subjects have estimates, so the planner breaks down unless the student pre-fills everything. |
| **Attendance** | 68% overall; tiles for Workshops, Quizzes, Academic Advisor, Career Counselor, Mentor, Pod | Good: it already counts the **offline program moments**. Useful for the student dashboard (P4). |
| **Sessions** | Monthly allocation (Career 4, Academic 2, Personal 2), upcoming and past | Workshop shows up as a session (Fintech Workshop, 31 Oct). |
| **Tasks** | "Today's Mission": 158 tasks, 42 overdue; monthly goal cards; goal tasks; a create-task sheet | The overdue count is front and centre. Advisor and self tasks are mixed. |
| **Goals & Roadmap** | Annual → quarterly → monthly goals by Career / Academic / Personal | The Q3 card shows **0%** while a goal inside it is at 67% with 2 of 3 months achieved, which is confusing. Monthly goals have "No description set". |
| **Wellness** | Recovery ring, sleep/activity/recovery score out of 100, weekly bars, trends, sleep/activity/recovery streaks, "You need a break" → Rest Mode (60-second breathing, +5 coins, 1.1× focus boost) | Also: Wellness **League** (leaderboard), **Feed**, **Badges** (0/10), and a **Fruit Slice** mini-game. A lot is built here. |
| **Wellness Feed** | Social feed | **Every item is "Streak Broken 💔"**, so it only ever broadcasts failure. |
| **Daily Insights** | Burnout-risk emoji 😵, Sleep deficit, Morning opportunity missed, Narrow focus, Actual vs. Top-30 benchmark, Screen Time (grant access) | Framed around deficits. |
| **Profile** | Class-10 year progress (218/365 days), streak, attendance, coins, chapters, achievements, weekly activity | |
| **My Streak** | "No streak yet. **Hit your daily target** today to start your streak." 7-day milestone gives a Dragon Egg | ⚠️ See finding A. |
| **Settings** | WHOOP connect, Google Calendar connect, account (board CBSE, program start), mentors (advisor name + "Send Email") | Mentors can only be reached by email. There's no in-app contact. |

## 3. Key findings

**A. The streak is tied to syllabus progress, not to showing up.**
A streak day only counts if the student hits the **daily syllabus velocity target (1.33%)**, and the "Extraordinary Streak" quest needs it for 100 days straight. Velocity only moves when the student logs chapter tasks. So the main daily-return mechanic sits behind the heaviest data-entry flow in the app. That fits the brief's "Streak: 1 student" and "Syllabus: 1 student this week".

**B. Study features need a lot of input and give little back.**
Each chapter needs about 6 task statuses with hour estimates, plus revision attempts and marks. The planner needs per-subject hour estimates (7 of 9 subjects are empty), and exams are added by hand. The reward for doing all that is mostly a progress bar that says you're behind.

**C. ~~Most of what the app tells students is that they're failing~~: downgraded.**
The negative states seen (broken streaks, "42 overdue", −75.1% gap, a feed of "Streak Broken") come from the **test account being unused**, not from how an active student experiences the app.
- _Residual note:_ this is exactly what a **dormant student sees when they come back**, and 7 of 20 are dormant. The return experience may be worth a look as part of reactivation. It's a narrow point, not a headline finding.

**D. The coin economy is exploitable and weakly tied to study.**
- **Exploit (confirmed by the team):** marking a roadmap item done pays coins, and it can be marked **undone and done again to pay again, repeatedly**. Coins can be farmed without doing anything, which undermines both the economy and the Realm leaderboard.
  - _Fix direction:_ pay once per item (store an "already rewarded" flag; never reverse or re-pay on toggle).
- **Study earns little vs. Realm costs:** a 25-min focus session earns 15 coins, while a castle upgrade costs 100–1,000 (about 2.5–28 hours of focus).
- **Quests are fine:** achievement rewards (e.g. +2,000) pay **once only**, so they're a one-time boost, not an ongoing imbalance.
- **Nothing else to buy:** the rewards shop is "arriving soon", so coins only buy Realm items.

**E. ~~Numbers disagree across screens~~: dropped.** This is staging, with test data mixed in, so mismatched numbers aren't a valid finding. One point is still worth a quick check in production: a chapter's % is driven by task progress, so "0/4 chapters done" can sit next to "19%". Students may not know which number to trust.

**F. A lot is built for a small, highly selected cohort.**
Wellness alone has a dashboard, trends, a league, a feed, badges, Rest Mode, a mini-game and insights. Home has about 12 cards. That's ~25 features for ~20 students.
- _Context (team view):_ these students are a **very select group admitted after a long selection process**, on a premium program. Depth per student is expected, and breadth isn't a problem in itself.
- So the question isn't "too many features". It's **which features actually earn daily time**, and whether the rest are easy to reach without crowding them out.

**G. Offline Alcovia barely appears.**
Attendance and Sessions count workshops and pods, but there's no workshop recap, soft-skill score, pod content, quiz or shoot in the app. The parts students love most are invisible.

**H. Other**
- **Daily-login coins:** the ledger shows a "Daily Login" entry as **−5**, which looks like a sign bug.
- **Revision dialog:** it labels hours as *required* in one state and *optional* in another.

## 4. What the walkthrough couldn't show

- ~~A brand-new student's first session (empty states)~~: **not needed.** There's no public signup. Credentials are generated and emailed **after a student is selected**, so onboarding is a controlled, advisor-led moment rather than a cold start.
- Wellness without WHOOP. WHOOP was a staging addition. **My recommendation: use software, not hardware.** Read from Apple Health and Android Health Connect, which already collect phone and watch data, instead of depending on students buying a specific wearable.
- The parent's view (out of scope, nothing shared)
- Real notification timing and frequency
- Whether the 8 PM quiz exists anywhere in the app

## 5. Observations

### O1. Gamification is decoupled from academic rigour
The primary CTA on Home launches **"Free Focus"**. Students can run timers, hatch dragons and mint AlcoCoins **without ever selecting a syllabus chapter or an advisor-assigned task**. The 3D globe in the Realm can likewise be conquered purely through **unlinked timers and PvP battle achievements**.

_Evidence:_ the Home "Start Focus" button opens a screen labelled "FOCUS MODE · Free Focus" with only a minutes picker and an egg picker, and no subject, chapter or task selector.

### O2. The student is forced to be a project manager
Instead of executing pre-set plans, the student has to **input and update data**. Running a chapter-linked focus timer takes **4–5 taps plus defining hours** before the timer unlocks.

_Evidence (path from screenshots):_ Study tab → subject → chapter → task (enter estimated hours) → Start Focus Timer. Chapter-linked focus is buried, and the unlinked option is the first thing on Home.

### O3. Tasks are not connected to the syllabus
Creating a **New Task** doesn't link back to the syllabus.

_Evidence:_ the New Task sheet has only Title, Description, Due date and Priority. There's no subject or chapter field, so a completed task never moves syllabus progress.

---

## 6. Root cause: Problem 1 (2.15 min → 30 min)

### The problem in numbers
2.15 min/day averaged across 20 students is **~43 student-minutes a day**. The target is **600**. The 7 dormant students contribute zero.

### Root cause, in one line
> **The app pays students for activity that doesn't move their academics, and makes the activity that does move them cost planning and data entry with no immediate payoff.** Students come for the game, leave within minutes, and the study habit (and the streak built on it) never forms.

### The causal chain

| # | Link in the chain | Evidence |
|---|---|---|
| 1 | **The default action is unlinked.** Home's main CTA is "Free Focus": timers, dragons and coins with no chapter or task attached. The Realm can be won through unlinked timers and PvP achievements. | O1 |
| 2 | **The linked path is expensive.** A chapter-linked focus session takes 4–5 taps plus an hour estimate. Each chapter carries ~6 tasks with 5-state statuses, all self-reported. The student plans *and* executes. | O2, B |
| 3 | **Work done elsewhere doesn't count.** Tasks (including advisor-assigned ones) don't link to the syllabus. Offline Alcovia (workshops, pods, shoots) leaves no trace beyond attendance. | O3, G |
| 4 | **The habit mechanic sits on the expensive path.** A streak day requires 1.33% daily syllabus velocity, which only moves through chapter-linked logging. The cheap path can never build a streak. | A |
| 5 | **Rewards don't tell the two paths apart, and can be gamed.** Free and linked focus both mint coins; roadmap items can be toggled for repeat coins; Realm progress comes mostly from PvP. | D |

**Result, as the usage data shows:**
- **Home:** every student uses it.
- **Realm:** the most used feature this week.
- **Focus Timer:** 11 opened it, but only 5 use it regularly.
- **Syllabus:** 10 students opened it, but only 1 this week.
- **Streak:** 1 student.
- **Study:** keeps 15% of the students who try it.
- **Goals:** 1 completion in 45 days.

### Why it shows up as *minutes*
- **Only focus sessions can fill 30 minutes.** A Home check or a Realm visit is a couple of minutes, so 30 min/day can only come from **focus sessions** (25-minute blocks).
- **Nothing tells a student to focus today.** Focus is decoupled from the plan, so the app never says "today: 2 × 25 min on Thermodynamics". It stays an optional mini-game instead of the main thing the student does.
- **Nothing pulls dormant students back.** They have no running streak and no plan, and nothing from offline Alcovia appears in the app. So 7 of 20 add zero minutes.

### What it is *not*
- **Not stability:** zero app failures.
- **Not feature count:** the cohort is small and carefully selected, so depth is expected.
- **Not the advisor side:** advisors use Tasks and Quests because they're required to.

### What any fix must therefore do (design principles, not yet the solution)
1. **Make the plan the default.** Home's main CTA should start *the next planned block*: chapter and task pre-selected from the advisor's plan, one tap to begin. Free Focus becomes secondary.
2. **Move data entry off the student.** Advisors (already compliant) and the system set the plan and hour estimates. A focus session auto-logs actual time and advances the task. The student executes; they don't administer.
3. **Pay only for linked work.** Linked focus earns the coins, dragons and streak. Remove repeat-reward exploits. Realm progress should come from study, not mostly from PvP.
4. **Bring offline Alcovia into the loop.** Use the calendar invites that already exist to attach reminders, check-ins and post-event moments to workshops and sessions.

### How we'll know this diagnosis is right (to validate in week 1)
- **Instrument per-feature time** (today only opens are tracked). Confirm where the 2.15 minutes is spent.
- **Measure linked vs. unlinked focus.** Share of focus sessions and minutes tied to a chapter or task. The diagnosis predicts this is low.
- **Taps to start a linked session:** baseline 4–5 plus an hour entry.
- **Leading indicator to track:** linked focus minutes per student per day.
