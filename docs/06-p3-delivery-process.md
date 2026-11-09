# Problem 3: A Delivery Structure That Makes Every OKR Land

## 1. The problem

Products and systems get built, but don't consistently work at their best: they don't produce the insight they should, they add cognitive load, and they aren't always functional for the end user (a teen or a parent).

**What usually goes wrong** (visible in the app today):
| Failure | Example from the current app |
|---|---|
| **"Shipped" is treated as "done"** | Features exist (Goals, Study Planner, Wellness extras) but have 0–1 users |
| **No success metric or baseline before building** | Only app opens are tracked, so nobody knows which feature produces the 2.15 minutes |
| **Built for the system, not the user** | The streak depends on syllabus velocity, which needs heavy self-reported input |
| **No check of effort vs. reward for the user** | A chapter-linked focus session takes 4–5 taps plus an hour entry |
| **No owner after launch** | The coin re-pay bug and Realm heating went unnoticed |

**Principle of the fix:** an OKR is done when its **metric moves**, not when its feature ships. Every stage below exists to protect that.

## 2. The flow at a glance

```
 ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
 │ 1 INTAKE │──►│ 2 FRAME  │──►│3 DISCOVER│──►│ 4 DESIGN │──►│ 5 BUILD  │──►│6 RELEASE │──►│7 MEASURE │
 │          │   │          │   │          │   │          │   │ + VERIFY │   │ (staged) │   │ & DECIDE │
 └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘   └────┬─────┘
   Is it worth    What metric,     Why is it       Least-effort     Built with      5 users →        │
   doing now?     from what        happening?      solution for     tracking,       everyone,        ▼
                  baseline?                        the user         tested          SOP handed   ┌──────────┐
                                                                                    over         │ 8 OPERATE│
                                                                                                 └──────────┘
   Gate ✓          Gate ✓          Gate ✓          Gate ✓          Gate ✓          Gate ✓        Scale / Iterate / Kill
```

**Each stage has:** one owner · one artifact (a short template) · one gate (a yes/no checklist). A piece of work can't move to the next stage until its gate is passed.

**This is not a waterfall.** The stages describe what every piece of work must pass through. The **agile operating model in §6** sets when and in what size:
- An OKR is broken into **small slices (user stories)**. Each slice loops through stages 4–7 in **one-week sprints**, and something usable ships behind a flag every sprint.
- **Discovery and delivery run in parallel (dual-track).** While the engineer builds this sprint's slices, the PM and SD are framing and discovering the next ones. Stages 1–4 feed a ready backlog, and stages 5–7 drain it.
- What we learn in stage 7 goes straight back into the backlog and changes the next sprint's plan.

```
 DISCOVERY TRACK (PM + SD)      Intake → Frame → Discover → Design ──► READY BACKLOG
                                          ▲                                 │
                                          │ learning                        ▼
 DELIVERY TRACK (FSE + SD)      Measure ◄── Release ◄──── Build + Verify ◄── Sprint commitment
                               (Fri reads)  (next Mon AM)     (Mon–Fri)        (Thu, week before)
```

## 3. Roles

| Role | Owns | In one line |
|---|---|---|
| **Product Manager** | The outcome. Stages 1–3 and 7. Final call at every gate. **Product owner:** owns and orders the backlog, sets each sprint goal, accepts stories against acceptance criteria. Facilitates the sprint ceremonies. | "Are we solving the right problem, and did it work?" |
| **Systems Designer** | The process and data side. Stage 4 (flows, SOPs, automations, data definitions) and stage 8 (operations). | "Will it work every day without breaking or depending on one person?" |
| **Full-Stack Engineer** | The build. Feasibility in stage 4, stages 5–6, tracking and performance. | "Does it work, does it measure itself, can we roll it back?" |
| **Leadership** | Priorities and target sign-off (stages 1–2). Monthly OKR review. | "Is this the right bet?" |
| **Advisors / GTM team** | The voice of the user in stage 3. Adoption of SOPs. Feedback after release. | "Does it fit how we actually work with teens and parents?" |

**RACI by stage**

| Stage | PM | SD | FSE | Leadership | Advisors / GTM |
|---|---|---|---|---|---|
| 1 Intake | A/R | C | C | C (priority) | I |
| 2 Frame | A/R | C | C | A (target sign-off) | C |
| 3 Discover | A/R | R | C | I | C |
| 4 Design | A | R (process, data) | R (tech) | I | C |
| 5 Build + Verify | A | R (SOP, automations) | R | I | I |
| 6 Release | A | R (SOP handover) | R | I | I |
| 7 Measure & Decide | A/R | C | C | I (monthly) | C |
| 8 Operate | I | A/R | R (fixes) | I | R (follow SOP) |

## 4. The stages in detail

### Stage 1: Intake (Is it worth doing now?)
**Why:** asks arrive daily, from Leadership, advisors, the GTM team and data. Without a single entry point, the loudest ask wins.

| | |
|---|---|
| **Owner** | PM |
| **How** | Every ask goes into **one ClickUp intake form**, nowhere else (no WhatsApp asks). Triage weekly (Monday). |
| **Artifact** | Intake card: _What's the ask · Who is it for (teen / parent / advisor / internal) · What would change if we did it · Type (Feature / System-automation / Analytics / Fix) · Urgency_ |
| **Prioritise by** | **Impact** on a company OKR × **Confidence** we can move it ÷ **Effort**. Fixes for broken or exploited things jump the queue. |
| **Gate ✓** | ☐ Linked to a company OKR · ☐ Type assigned · ☐ Has a priority rank · ☐ Leadership agrees with the top 3 |

### Stage 2: Frame (What does success look like, from where?)
**Why:** most "it didn't work" outcomes trace back to never agreeing what "work" meant.

| | |
|---|---|
| **Owner** | PM; target signed off by Leadership |
| **Artifact** | **One-page Problem Brief** |
| **Must contain** | Problem in one sentence · Who it's for · **Success metric with its baseline and target** · **Guardrails** (what must not get worse) · How the metric is counted (exact definition) · Out of Scope items |
| **Rule** | **No baseline, no build.** If the metric isn't tracked yet, the first task is to track it. |
| **Gate ✓** | ☐ One success metric, exactly defined · ☐ Baseline exists (or tracking is task #1) · ☐ Target signed off · ☐ Guardrails listed |

### Stage 3: Discover (Why is it happening?)
**Why:** solving symptoms is how features end up with 0 users.

| | |
|---|---|
| **Owner** | PM, with SD |
| **How** | Three sources: **(1) data** (what the tracking says), **(2) users** (talk to 5–10 teens, parents or advisors), **(3) walkthrough** (run through the product screen by screen, and count taps and inputs) |
| **Artifact** | **Root-cause note**: the causal chain, each link backed by evidence |
| **Time-box** | 3–5 working days. Small fixes can skip this stage. |
| **Gate ✓** | ☐ Root cause stated in one line · ☐ Each link has evidence (data, a quote or a screenshot) · ☐ At least 5 users spoken to (features) |

### Stage 4: Design (The least-effort solution for the user)
**Why:** the brief asks for "least cognitive load". It has to be checked explicitly, or it gets lost.

| | |
|---|---|
| **Owner** | SD (flows, process, data); FSE (technical feasibility); PM approves |
| **Artifacts** | Solution note (what changes, and why it fixes the root cause) · user flow · **tracking spec** (which events prove the metric moved) · **data-capture plan** (where each data point comes from; manual entry only when nothing else can supply it) · SOP draft if people are involved |
| **Cognitive-load check** | ☐ Core action reachable in **≤3 taps** · ☐ Nothing asked of the user that the system can derive or pre-fill · ☐ One primary action per screen · ☐ Sensible defaults (e.g. 25 min) · ☐ Works for its user (teen *or* parent) without explanation |
| **Slicing** | The solution is split into **user stories** , each with acceptance criteria and small enough to finish inside one sprint. Slice so the first story already gives users something usable (MVP). |
| **Gate ✓ (design review = Definition of Ready)** | ☐ Solution traces back to the root cause · ☐ Cognitive-load check passed · ☐ Tracking spec written · ☐ Rollback plan exists · ☐ Sliced into user stories with acceptance criteria, each sized to fit one sprint |

### Stage 5: Build + Verify (Built to measure itself)
| | |
|---|---|
| **Owner** | FSE (build, tests, tracking); SD (automations, SOP) |
| **Rules** | Only stories that passed the Definition of Ready are pulled into a sprint. **Tracking ships with the feature** (part of "done", not a follow-up). Everything sits **behind a feature flag**. Each sprint ends with a Friday demo of working software. |
| **Verify checklist** | ☐ Works end to end on test accounts · ☐ Edge cases (empty data, offline, repeated taps) · ☐ **Integrity** (no reward or data can be earned twice) · ☐ **Performance** on a mid-range device (no heating, no lag) · ☐ Tracking events fire and the numbers reconcile with reality · ☐ Rollback tested |
| **Gate ✓ (Definition of Done, per story)** | ☐ Acceptance criteria met · ☐ Verify checklist complete · ☐ PM has used it personally and accepted it · ☐ SOP ready (if people are involved) |

### Stage 6: Release (Staged)
| | |
|---|---|
| **Owner** | FSE (rollout); SD (SOP handover); PM (communication) |
| **How** | **5 power users**, for a week, watching guardrails daily → **everyone**. With a cohort of ~20, A/B tests can't give reliable answers, so staged release plus per-user before/after is the method. |
| **When** | Feature releases go out **Monday morning**, never on a Friday, so the whole team is around for the days right after a release. Bug fixes can go out any day. |
| **Also** | Short release note to advisors and the GTM team (what changed, what to tell students and parents). SOP walk-through for anyone who operates it. |
| **Gate ✓** | ☐ Guardrails held for the first 5 users · ☐ No critical bugs · ☐ Advisors and GTM briefed |

### Stage 7: Measure & Decide (Did the metric move?)
| | |
|---|---|
| **Owner** | PM |
| **When** | Fixed reads at **Day 7, Day 14, Day 28** after full release |
| **Decision** | **Scale** (metric moving, guardrails fine: keep going, next slice) · **Iterate** (moving too little: back to stage 3 or 4 with what we learned) · **Kill** (not moving after an iteration: remove it, so it stops adding load) |
| **Artifact** | **Decision log** entry: metric before/after, decision, why |
| **Rule** | **The OKR closes only when the metric hits target**, never when the feature ships. |
| **Feeds back** | Every read updates the backlog: new stories for "iterate", removal stories for "kill", and re-ordering for the next sprint planning. |
| **Gate ✓** | ☐ Metric read against baseline · ☐ Guardrails checked · ☐ Decision logged · ☐ Backlog updated |

### Stage 8: Operate (So it doesn't break later)
| | |
|---|---|
| **Owner** | SD (with FSE for fixes) |
| **How** | Every live feature or system has a **named owner role**, a **written SOP**, and an **alert**: n8n notifies the owner when a metric drops, a guardrail breaks, or an SOP step is missed (e.g. an advisor plan not pushed by Monday). |
| **Monthly health check** | Each live feature: still used? still moving its metric? any new bugs? Features nobody uses go back to stage 7 for a kill/iterate decision. |

## 5. Lighter paths by OKR type

Not every OKR needs every stage at full depth:

| Stage | Feature release | System / automation (n8n, ClickUp) | Analytics upload (dashboard, data) | Fix (bug, exploit) |
|---|---|---|---|---|
| 1 Intake | ✓ | ✓ | ✓ | ✓ (jumps the queue) |
| 2 Frame | ✓ full brief | ✓ metric = time saved / error rate | ✓ metric = decisions made with it / weekly views | Light: what's broken, how we'll know it's fixed |
| 3 Discover | ✓ data + users + walkthrough | ✓ map the current manual process | ✓ ask: which decision will this support? | Reproduce the bug |
| 4 Design | ✓ full check | ✓ + failure modes (what if a step fails?) | ✓ metric definitions + data sources | Light |
| 5 Build + Verify | ✓ | ✓ + test with real data | ✓ **numbers reconcile with source systems** | ✓ + regression test |
| 6 Release | Staged | Parallel-run with the old process for 1 week | Walk-through with the people who will use it | Direct |
| 7 Measure | D7 / D14 / D28 | Time saved, errors | Usage, and decisions taken from it | Confirm it's fixed |
| 8 Operate | ✓ | ✓ alerts essential | ✓ data-freshness alert | — |

## 6. Sprints sizing for quicker delivery

**Why one-week sprints:** A one-week loop matches the Friday metric read and the staged release (5 students for a week, then everyone).

### 6a. Backlog structure
| Level | What it is | Example (from P1) | Owner |
|---|---|---|---|
| **OKR** | The outcome and its metric | Counted minutes 2.15 → 30 per day | PM + Leadership |
| **Epic** | One solution that moves the OKR | Linked focus and rewards | PM |
| **User story** | A slice that ships within one sprint, with acceptance criteria | "As a student, I want my advisor's chapter pre-filled when I start focus, so that I can start in ≤3 taps." | PM writes, team sizes |
| **Task** | The work inside a story | API for the portal push; focus setup screen; tracking events | FSE / SD |

- **One ordered backlog** in ClickUp. The PM orders it by Impact × Confidence ÷ Effort (stage 1). Fixes for broken or exploited things go to the top.
- **Sizing:** S / M / L (S ≤1 day, M 2–3 days, L = split it before it enters a sprint). No story points: the team is too small for velocity charts to mean much. Instead, after 3 sprints we track **how many stories we planned vs. finished** and plan to that.
- **Definition of Ready** = the stage-4 gate. **Definition of Done** = the stage-5 gate. Neither is negotiable mid-sprint.

### 6b. The sprint cycle
Every sprint is **prepared in the week before it runs**. So in any given week, the team is building sprint N while preparing sprint N+1.

```
              Mon         Tue     Wed          Thu          Fri          Mon (next)
 Sprint N+1   Grooming            Estimation   Alignment
 (prep)       ─────────────────────────────────────────►  committed
 Sprint N     Dev starts ─────────────────────────────────►  Demo + retro  Release AM
 (build)      (release of N-1 AM)                           code complete
```

### 6c. Unplanned work (Kanban lane)
Bugs, exploits and operational issues don't wait for the sprint cycle or for a Monday release. They go into a **separate Kanban lane** with a **WIP limit of 1** for the FSE, paid for from the 20% capacity buffer, and ship as soon as they pass verification. If the buffer runs out, the PM drops a story from the sprint rather than stretching the week. The sprint goal stays fixed. Scope moves, not the deadline.

### 6d. How the 12-week P1 plan reads as sprints
Each week of the P1 plan is one sprint with one goal. For example: **Sprint 1** goal: "Fix the coin exploit and Realm heating, and start counting minutes." **Sprint 3** goal: "Five students can start a chapter-linked focus session in ≤3 taps." Discovery for Sprint 3 (the 10 student interviews and the linked-focus design) happens in Sprints 1–2 on the discovery track.

_Note: P1 = Problem statement 1_

## 7. Team rules that keep delivery honest

1. **One entry point** for asks (the ClickUp intake form).
2. **No baseline, no build.** Tracking first if needed.
3. **Done = metric moved**, not "feature shipped".
4. **Fix before build.** Exploits and broken experiences go first.
5. **WIP limit:** FSE has at most **1 story + 1 fix** in progress. ~20% of FSE time is reserved for bugs and operations.
6. **One change at a time** to any core mechanic, so effects can be attributed.
7. **Every live system has an owner, an SOP and an alert.** Nothing depends on one person remembering.
8. **Kill what doesn't work.** An unused feature is not neutral: it adds cognitive load.
9. **Software first.** Use what the user already has before asking for new hardware or effort.
10. **Ship something every sprint.** Even if it's behind a flag for 5 students, working software beats a finished document.
11. **The sprint goal doesn't change mid-sprint.** New asks go to the backlog; only a critical fix can enter, and it displaces a story.
12. **No Friday feature releases.** Features go out Monday morning; bug fixes go out whenever they're ready.

**ClickUp setup:**
- **Backlog list:** OKRs as Goals, epics as tasks, user stories as subtasks with an S/M/L size and acceptance criteria. Statuses mirror the discovery stages (Intake → Frame → Discover → Design → Ready).
- **Sprint lists:** ClickUp's Sprints feature, one-week cycles. Statuses mirror delivery (To do → Building → Verify → Done → Released → Measured).
- **Kanban lane:** a separate list for fixes and ops, with a WIP limit of 1.
- Brief, gate checklists and story template are saved as ClickUp templates. The board *is* the process: anyone can see where every OKR and story stands.

## 8. Worked example: Problem 1 (app adoption) run through this process

| Stage | What happened / happens |
|---|---|
| **1 Intake** | Ask: "App usage is 2.15 min/day, needs 30." Type: Feature. Linked OKR: student engagement. Top priority. |
| **2 Frame** | Metric defined exactly: **counted minutes = Study + Quiz + min(Games, 0.5 × (Study + Quiz))**, averaged over all 20 students. Baseline 2.15, target 30, stable = 4 consecutive weeks. Guardrails: crash-free, device performance, sleep, coin integrity. Gap found: time per feature isn't tracked, so **tracking became Week-1 work**. |
| **3 Discover** | Data (usage by feature, retention by area) + walkthrough (74 screens, taps counted) + 10 student interviews (Week 1). Root cause: rewards go to activity that doesn't move academics, while the activity that does is expensive. |
| **4 Design** | Cognitive-load check drove the decisions: hours no longer required to start a session; the advisor's plan pre-fills subject, chapter and activity; a one-tap progress check when the timer ends. Software first: Apple Health / Health Connect instead of a specific wearable. |
| **5 Build + Verify** | Fix before build: the coin re-pay exploit and the Realm heating are fixed in Week 1. Tracking ships first. Integrity check: one payout per item. |
| **6 Release** | Linked focus goes to 5 students first, then everyone after a week if guardrails hold. |
| **7 Measure & Decide** | Friday metric reads at each sprint review. Stable state judged over 28 Dec – 22 Jan. |
| **8 Operate** | SD-owned advisor push SOP with a missed-push alert. The question bank is refreshed daily. An unusual-hours alert sends advisors to correct course (academic help or app-usage correction). |
| **Sprints** | 12 one-week sprints, each with one goal. Discovery for linked focus runs in Sprints 1–2 while the FSE fixes bugs; the quiz pipeline is refined while linked focus is being built. |
