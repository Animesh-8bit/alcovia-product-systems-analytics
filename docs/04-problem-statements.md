# Alcovia Assignment: Problem Statements

_Context: the PM joins on **1 Nov 2026**, with a full-stack engineer and a systems designer reporting to them._

---

## Overarching task (applies to all four)
1. Solve each problem as efficiently as possible, **assigning tasks and timelines** across the 3 people (me, engineer, systems designer).
2. **Timebox** the solutioning from 1 Nov, manage it within team capacity, and build **systems that don't break**.

**Current stack to build on:** ClickUp (CRM, notes, comms), n8n (automations), Smallest.ai (AI calls for show-ups), Razorpay (payments), Meta Ads, Google Calendar, the student app.

---

## P1. App adoption: 2.15 → 30 min/day
**Ask:** the app is stable (zero failures) but usage is ~2.15 min/day averaged over all 20 students. Get it to 30 min/day in a stable state.
**Deliverable:** a plan to raise usage, with owners and timeline.
**Solution:** [05](05-p1-solution-app-adoption.md), with context in [02](02-app-feature-breakdown.md) and [03](03-app-walkthrough-findings.md).

## P2. GTM tracker dashboard
**Ask:** a dashboard with a **timeline selector**, populated with **dummy data**, showing the best visual representation. It must track:
- **Revenue:**
  - Monthly target vs. achievement
  - 3-month trial vs. full program split
  - Students onboarded per month
  - Workshop revenue (₹3,999/seat via Razorpay, fortnightly)
  - Program vs. workshop revenue
  - Invoices generated but unpaid
  - Upcoming trial renewals
- **Funnel (Meta ads → program):** Total leads → Qualified → Discovery call (show-up rate) → Ambition interview (drop-off) → Architect session. Top metrics: cost per qualified lead, conversion %, organic leads, average days in funnel.
- **Campaign performance:** highest and lowest CTR assets (refresh list), ad-set frequency (3+ means change), landing-page health (drop-off, load time).
- **RCA:** metrics that decide which campaigns to **drop / refresh / scale**.

**Deliverable:** a working dashboard (visual) plus how it's built and fed.
**Solution:** [08](08-p2-gtm-tracker.md) · KPI dictionary [alcovia-gtm-kpis.xlsx](alcovia-gtm-kpis.xlsx) · SQL [`sql/kpis/p2_gtm_tracker`](../sql/kpis/p2_gtm_tracker) · dashboards: static [`dashboards/site/gtm-tracker`](../dashboards/site/gtm-tracker), Metabase [`metabase/`](../metabase).

## P3. Structure for product/system delivery
**Ask:** products and systems haven't consistently worked at their best (insight, low cognitive load, functional for teens and parents). As the lead of 2 people, describe a **very detailed, easy-to-follow process** that gives every new OKR (feature release, analytics upload, etc.) the highest chance of hitting its success metric.
**Deliverable:** a step-by-step operating process, from idea to measured outcome.
**Solution:** [06](06-p3-delivery-process.md).

## P4. Student dashboard
**Ask:** weekly progress reviews currently live in documents and scattered ClickUp folders, with no view of average progress across all students. Design a dashboard covering the program's rigour:
- **Daily:** timetable, 8 PM quiz, focus time, active minutes, recovery
- **Weekly:** academic roadmap (score targets, time management, chapter rigour, advisor inputs, sprints)
- **Monthly:** 2 workshops, pod, peer session, mentor call, personal branding
- **Quarterly:** podcast, competition prep, parent–child workshop, out-of-city trip, themes (social work, entrepreneurship), summer program applications
- **Roadmaps:** career, personal, academic, syllabus completion, rigour of completion

**KPIs through 3 lenses:**
1. **Quantity:** did Alcovia conduct it?
2. **Quality:** did Alcovians like it?
3. **Performance:** how did the Alcovian perform?

**Must answer:**
- How will the dashboard be designed?
- In what time?
- Where will it live?
- How will it record data with **minimal human intervention**?

**Deliverable:** KPI framework, dashboard design, build timeline, data-capture plan.
**Solution:** [07](07-p4-student-dashboard.md) · SQL [`sql/kpis/p4_student_dashboard`](../sql/kpis/p4_student_dashboard) · dashboards: static [`dashboards/site/student-dashboard`](../dashboards/site/student-dashboard), Metabase [`metabase/`](../metabase).

---

## How the problems connect
- **P1 ↔ P4:** the app is the main data source for the student dashboard. The P1 fixes (plan-linked focus, auto-logging) are what reduce manual entry for P4.
- **P3:** the operating system for running P1, P2 and P4 together through the team.
- **P2:** largely independent. It's a data pipeline from ClickUp, Razorpay and Meta, through n8n, into a dashboard.
