# Alcovia — Business Model Context

_Compiled 30 Oct 2026 from the assignment brief, alcovia.life, and the May 2025 launch press release._
_Legend: **[F]** = stated fact (with source) · **[I]** = my inference, needs validation · **[?]** = open question_

---

## 1. What Alcovia is

- **[F]** "World's first Ambition building program for Teenagers" — a selective, year-long, offline-first community for high-potential teens aged **11–16** (grades 6–10). _(alcovia.life, press release)_
- **[F]** Framework: **Ambition = Vision × Execution × Drive**
  - Vision — how big the teen thinks (career discovery, mentors, podcasts)
  - Execution — real-world doing to build grit (entrepreneurship, social work, competitions)
  - Drive — fitness, nutrition, mental wellbeing, productivity / anti-distraction coaching, peer community
- **[F]** Tagline: "Ahead of the Curve". Positioning: "Purpose beyond status", "entry is earned", "3% selection rate", "top 1%".
- **[F]** Based in Gurugram (WeWork, Two Horizon Center, DLF Phase 5). Launched in Delhi-NCR on 26 May 2025.

## 2. Customer

| | Who | What they care about |
|---|---|---|
| **User** | Teen, 11–16, Delhi-NCR, ambitious / high-performing | Fun, status, peers, discovering what they want to do |
| **Buyer** | Parents (affluent, likely top private schools; team lists Vasant Valley and British School alumni) | Academic results, career clarity, competitive edge (e.g. summer school admissions), wellbeing, less screen distraction |

- **[I]** This is a premium, parent-paid product. The parent is the economic buyer and the teen is the engagement driver. Every system (app, dashboard, reports) has to serve both, and the brief itself says end users "can either be parents or teenagers".

## 3. Products and revenue streams

| Stream | What it is | Price | Source |
|---|---|---|---|
| **Full program** | Year-long cohort membership (the full rigour described in Problem 4) | **[?] not public** | brief, site |
| **3-month trial** | Shorter entry construct that renews into the program | **[?] not public** | brief (GTM tracker: "renewals coming up for 3 month trial teens") |
| **Workshops** | Fortnightly, in-person, 4-hour career-simulation workshops, open to grades 6–12 | **₹3,999 / seat**, paid via Razorpay | brief, alcovia.life/workshop |

**Example workshop: "The Money Room" (Sat 31 Oct 2026, 11 AM–3 PM)**
1. Expert session with the CFO of Nothing India.
2. Teens in trios run a fintech product, with roles for Numbers, Customer and Market.
3. A mid-game curveball.
4. Each trio makes a 60-second launch reel and the room invests play money.

Seats are capped. **[I]** The format matches the "Workshop 1/2" construct in Problem 4: a professional's story, then a simulation, with 11 soft skills tracked.

- **[Decided]** Workshops are a **standalone revenue line**, not a feeder into the program funnel ("a workshop is a workshop"). The GTM tracker treats them as a separate P&L line: seats sold × ₹3,999, fill rate, revenue per workshop.
  - _Parked idea:_ attendees could later be tagged as a lead source to test whether they convert. This would be an experiment, not the current model.
- **[I]** The 3-month trial lowers the commitment barrier for a high-ticket annual product. **Trial→full conversion** is likely one of the most important numbers in the business.

## 4. Acquisition funnel (program)

```
Meta ads ─┐
Organic ──┼─► Lead (ClickUp) ─► Qualified ─► Discovery call ─► Ambition interview ─► Architect session ─► Paid (trial / full)
Workshop? ┘    [n8n automations]            [Smallest.ai AI     (with teen;          (parents + teen;
                                             reminder calls     "selection")         personalised
                                             → show-up rate]                         roadmap = the close)
```

- **[F]** Stages and metrics come from the brief: show-up rate at Discovery, drop-off at the Ambition interview, CPQL, conversion %, organic count, and average days in the funnel.
- **[Decided]** The **Ambition interview is genuinely selective**: teens can be rejected. So drop-off at this stage has two causes that the funnel must separate:
  - **Rejected by Alcovia** (healthy; this is the filter working)
  - **Dropped by family** (no-show, lost interest, price; this is leakage to fix)

  Mixing the two would make a strict selection look like a failing funnel.
- **[I]** The **Architect session** is the real sales close: the parent sees a personalised roadmap before paying.
- **[I]** This is a high-touch, consultative sale with ~4 human touchpoints per lead, so team capacity per lead is a real constraint. CPQL and show-up rate matter more than raw lead volume.

## 5. Delivery model (what the fee buys)

| Cadence | Components |
|---|---|
| **Daily** | Timetable, 8 PM GK quiz, focus time (in-app), active minutes and recovery (wearables) |
| **Weekly** | Academic advisor session(s): score targets, timetable, syllabus rigour, sprints |
| **Monthly** | 2 workshops, pod session (5 teens, 2 hrs), peer session, mentor call, personal-branding shoot |
| **Quarterly** | Podcast shoot, competition prep, parent–child workshop, out-of-city experience, theme (social work / entrepreneurship), summer-school applications |
| **Ongoing** | Career, personal and academic roadmaps |

- **[I]** Delivery is very **people-heavy**: advisor time, events, shoots and mentors. Margins and scale depend on how much of the tracking and nudging is automated. That is the real reason Problems 1, 3 and 4 exist, so the app and dashboards are leverage on advisor time.

## 6. Team (roles, per alcovia.life/meet-the-team)

| Role | Relevance to this assignment |
|---|---|
| Leadership | Overview of the GTM tracker; final say on targets |
| Lead Advisor | Owner and user of the student dashboard (P4) |
| Strategy Head | |
| AI Product Manager | |
| Systems Designer | Reports to the PM |
| Full Stack Engineer | Reports to the PM |
| GTM & Marketing Lead | Main user of the GTM tracker (P2) |
| GTM | |

## 7. Scale today (signals)

- **[F]** Launch target: a cohort of 40 teens. _(press release, May 2025)_
- **[F]** The app has had 20 student users in the last 45 days and 11–17 per week. _(brief)_
- **[I]** That puts the paying base at roughly **20–40 students**. Every metric is small-n, so dashboards should show counts alongside percentages, and one student moving can swing a % by 5 points or more.
- **[F]** The brief frames the GTM tracker as preparation for "scale up", so growth is the next phase.

## 8. Tool stack

| Tool | Current role | Note |
|---|---|---|
| ClickUp | CRM (leads, qualification, nurture), parent-conversation notes, team chat, scattered student progress | Single source of truth for leads, but not for students |
| n8n | Automations | Glue layer and the obvious ETL path into dashboards |
| Smallest.ai | AI voice calls to drive show-ups | Feeds the show-up rate metric |
| Razorpay | Payments (workshops, likely program invoices) | Revenue source of truth |
| Meta Ads | Paid acquisition | Campaign, CTR and frequency data |
| Student app | Home, Study, Plan, Focus & game (Realm), Wellness (WHOOP) | Stable but low engagement (2.15 min vs. a 30-min target) |

**Website stack, observed** (domains the alcovia.life site connected to on one visit; a single page load, so tags that fire only on other pages or events may be missing):

| Domain | What it is | Relevance to P2 |
|---|---|---|
| alcovia.life, www.alcovia.life | The marketing site / landing pages | Pages whose health we track |
| api.alcovia.life → onrender.com (via Cloudflare) | Alcovia's own backend, hosted on **Render**, behind Cloudflare | App / platform backend |
| n8n.alcovia.life | **Self-hosted n8n**. The website lead form posts to `n8n.alcovia.life/webhook/lead-form` (confirmed) | **Lead capture runs through n8n**, so campaign tags can be saved on the lead there |
| clarity.ms | **Microsoft Clarity**: session recordings, heatmaps, scroll depth, dead / rage clicks, quick-backs | **Landing-page drop-off and behaviour** |
| connect.facebook.net | **Meta Pixel** | Ties ad clicks to on-site lead events, per campaign / ad |
| googletagmanager.com, analytics.google.com | **Google Analytics 4** (gtag, property G-T46NRQ65FV), loaded via Google's tag script | Traffic, sources and page-level drop-off. _(Corrected after the teardown: GA4 is running.)_ |
| res.cloudinary.com | **Cloudinary**: image / video hosting for the site | Heavy media is a usual cause of slow pages |
| Cloudflare | CDN / DNS in front of the site and API | — |

**Website teardown (31 Oct 2026, read-only: pages and their code inspected in Chrome, no forms submitted)**

- **Built with** Next.js, generated with v0 (Vercel). Pages: home, /workshop, /vision, /execution, /drive, /meet-the-team.
- **Two funnels on the site:**
  - **Program:** "Apply now" opens a **"Book a fit call"** form: Student / Parent toggle, student name, parent name, phone, school, grade (6th–12th), city (Delhi NCR + 14 other cities + Other), email, consent checkbox. There is also an **exit-intent brochure download** form (`lead_type: brochure`).
  - **Workshop:** /workshop sells the current workshop at **₹3,999** through a **Razorpay payment link** (the page also lists past workshops, e.g. Data Storytelling, 25 Jul 2026). It tracks *InitiateCheckout* and *Purchase*, tagged `funnel_name: workshop`.
- **Attribution is already built in:**
  - The site saves the first-touch UTMs, traffic source, referrer and landing page in the browser (`alcovia_utm`), plus a Meta visitor id.
  - Every form posts to **`n8n.alcovia.life/webhook/lead-form`** with `utm_source / medium / campaign / content`, `fbc` / `fbp` (Meta click and browser ids), `lead_type`, `form_open_source`, landing page and a `meta_event_id`.
  - Meta gets the same event **twice, deduplicated**: browser Pixel (*Lead*, *BrochureDownload*, *InitiateCheckout*, *Purchase*) and server-side **Conversions API** via the site's own `/api/meta-capi`, both with the same event id.
- **Analytics:** GA4 + Microsoft Clarity + Meta Pixel (id 1606881963979917).
- **Speed (desktop, fast connection, warm cache):** first paint and largest paint ~0.26 s, page load ~0.35 s. Videos use `preload="none"`, so they don't block the first view. **Not representative of mobile on 4G**; the PageSpeed API needs a key for a real mobile reading.

**What this means for P2:**
- **No engineering needed for attribution.** Campaign and ad tags already arrive at n8n with every lead; the SD only needs to make sure the `lead-form` workflow writes them onto the ClickUp lead as fields.
- **Organic vs. paid** comes from `utm_source` / traffic source on the lead.
- **Landing-page health** comes from **GA4** (sessions, engagement, drop-off by page) and **Clarity** (scroll depth, quick-backs, rage clicks), with **load time** from the PageSpeed Insights API (free key) run daily by n8n.
- **Workshop revenue** can be matched to campaigns, because checkout carries the same UTMs as the Razorpay payment.
- **Gap to check:** `utm_term` and the Meta **ad id** aren't in the payload, so creative-level CTR comes from the Meta Ads API, but lead-to-creative matching depends on `utm_content` being set per ad (e.g. `{{ad.name}}` in Meta's URL parameters).

---

## 9. Open questions → answers

| # | Question | Answer | Status |
|---|---|---|---|
| 1 | Program and 3-month trial prices, payment plans | Not public | Use placeholders (§9a) |
| 2 | Trial→full conversion and renewal rate | Not public | Use placeholders (§9a) |
| 3 | Paying base (trial vs. full) | Not public | Use placeholders (§9a) |
| 4 | Do workshop attendees get nurtured into the program? | **No.** A workshop is a workshop: standalone revenue | Decided |
| 5 | Is the Ambition interview selective? | **Yes**, teens can be rejected | Decided |
| 6 | Primary daily user of the dashboards | **GTM team and Leadership**, at different granularity | Decided |
| 7 | Reporting line | **I am the Product Manager**; the systems designer and full-stack engineer report to me | Decided |

### 9a. Working assumptions for mock data (dummy, to be replaced with real numbers)

| Assumption | Placeholder | Why this number |
|---|---|---|
| Full program price | ₹2,40,000 / year | Premium, parent-paid, high-touch annual program in NCR |
| 3-month trial price | ₹75,000 | A small premium over 3/12 of annual, so converting to full is the better deal |
| Paying base | ~30 students (≈ 20 full, 10 trial) | Between the 40-seat launch target and 20 app users |
| Trial → full conversion | ~50% | Placeholder only |
| Workshop seats | 15–25 per workshop, 2 per month | Capped seats, fortnightly cadence |

### 9b. Dashboard audiences (from answer 6)

| Viewer | Granularity | Cadence | Question it answers |
|---|---|---|---|
| **Leadership** | Summary: 5–7 KPIs, target vs. actual, red/amber/green flags | Weekly glance, monthly review | "Are we on track, and where do I need to step in?" |
| **GTM team** | Granular: stage-by-stage funnel, campaign and ad-set level, per-lead ageing, unpaid invoices list | Daily | "What do I do today: which leads to chase, which ads to kill or refresh?" |

→ One data model with two views (Leadership overview + GTM drill-down), not two separate dashboards.

**Sources**
- Assignment brief (Alcovia's, not included in this repository)
- https://alcovia.life · /about · /workshop · /meet-the-team
- Launch press release (paid/advertorial, 26 May 2025): https://www.tribuneindia.com/news/business/alcovia-launches-in-delhi-ncr-a-new-premier-community-for-indias-most-driven-young-minds
