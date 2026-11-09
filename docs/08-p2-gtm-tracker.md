# Problem 2: GTM Tracker

## 1. Targets and rules

### 1a. Monthly revenue target: ₹15,00,000
| Source | Target | Price | Revenue |
|---|---|---|---|
| Full program sign-ups | **4** | ₹2,40,000 | ₹9,60,000 |
| Trial sign-ups | **6** | ₹50,000 | ₹3,00,000 |
| Workshop seats | **60** (30 per workshop, 2 workshops) | ₹3,999 | ₹2,39,940 |
| **Total** | **10 sign-ups + 60 seats** | | **≈ ₹15,00,000** |

_Placeholder prices and volumes; the dashboard reads targets from one settings table, so Alcovia can change them without touching the views._

### 1b. Two ways in
Families enter the funnel from **two places**, and the tracker keeps both:

```
Meta ads ──► website form ──► qualified ──► discovery call ──┐
                                                            ├──► Ambition interview ──► Architect session (Leadership-led) ──► paid
Workshop ──► attended ────► nurture ───────────────────────┘
```

Every lead carries its **entry path** (ads or workshop), so each view can show the two side by side or together.

**When a family counts as converted.** A conversion is counted only when the family **pays for the full term**. A family that pays for a 3-month trial is in the **Trial** state of the conversion state machine, not converted; it converts when it renews into the full program.

```
… ──► Architect session ──┬──► Trial (₹50,000 paid) ──┬──► Converted (renewed into full program)
                          │                           └──► Not renewed
                          └──► Converted (full program paid)
```

So "full program conversions" = full program sign-ups + trials that renewed, and conversion rates use converted families only. Days to decide still runs from first contact to the **first payment**, since the trial months are not decision time.

### 1c. Ad spend ceilings
| Campaign type | Ceiling | Why |
|---|---|---|
| Program | **₹5,000** per qualified lead | ~20% of an enrollment's value, spread over the families who don't enroll |
| Workshop | **₹800** ad spend per seat sold | With a venue at **₹1,00,000** per workshop and 30 seats at ₹3,999 (₹1.2L), ₹800 a seat keeps the workshop around break-even, as it ran before |

### 1d. What to do with each ad
| Action | When | In the dashboard |
|---|---|---|
| **Scale** (spend more) | It brings good-fit leads (program) or seats (workshop) **under target cost** | Green tag |
| **Refresh** (new creative, same audience) | **Frequency ≥ 3**: on average, people have seen it 3 or more times | Amber tag |
| **Drop** (switch off) | **Too expensive**: cost per good-fit lead above ₹5,000 (or ad spend per workshop seat above ₹800) for **2 weeks running**; **or** it brings leads but **none qualify** | Red tag |

Every tag shows its reason ("₹7,200 per qualified lead for 2 weeks", "frequency 3.4"), so the team can check it, not just follow it.

### 1e. Unpaid invoices
| Days unpaid | Colour |
|---|---|
| Under 5 | — |
| 5 to 9 | Amber |
| 10 or more | Red |

### 1f. Upcoming trial renewals
| Days until the 3-month trial ends | Colour |
|---|---|
| 30 to 16 | Yellow |
| 15 to 8 | Amber |
| 7 or fewer | Red |

## 2. Metric definitions

The full KPI dictionary, with every formula, source and target, is in **alcovia-gtm-kpis.xlsx** (sheets: KPIs, Targets, Worked example).

### Revenue
| Metric | Definition | Source |
|---|---|---|
| Revenue vs. target | Payments received in the period vs. the period's target (₹15L × months) | Razorpay |
| Trial vs. full program | Sign-ups and revenue split by plan, vs. targets of 6 trials and 4 full | Razorpay (plan / amount) + ClickUp |
| Trial-to-full renewal rate | Trials that renewed into the full program ÷ trials that ended | ClickUp + Razorpay |
| Students onboarded | New paying students in the period (first payment date) | Razorpay + ClickUp |
| Workshop revenue | Seats sold × ₹3,999, per workshop | Razorpay payment links |
| Program vs. workshop | Share of revenue from each | Razorpay |
| Workshop break-even | Seat revenue ÷ (workshop ad spend + ₹1L venue), per workshop; 1.0 or more = break-even | Razorpay + Meta Ads + venue cost |
| Unpaid invoices | Invoices issued and not paid, with days outstanding | Razorpay invoices |
| Upcoming renewals | Trials whose 3 months end within 30 days | ClickUp (trial start date) |

### Funnel
| Metric | Definition | Source |
|---|---|---|
| Leads | Form submissions (program fit-call form + brochure) and workshop attendees, split by entry path (ads / workshop) | n8n lead webhook → ClickUp; workshop attendance |
| Workshop → program | Workshop families who enroll in the program ÷ workshop families (past result: ~1 in 18) | ClickUp + Razorpay |
| Nurture | Families in follow-up after a workshop or call, with days since last touch | ClickUp stage + dates |
| Qualified | Leads marked good fit (grade, city, intent) | ClickUp stage |
| Discovery call show-up rate | Calls attended ÷ calls booked | ClickUp + Smallest.ai call outcomes |
| Ambition interview drop-off | Split in two: **rejected by Alcovia** (selective) vs. **dropped by family** (leakage to fix) | ClickUp stage + reason |
| Architect session (Leadership-led conversion) | Sessions held | ClickUp stage |
| Program conversion % | Converted (full term paid: full program, or trial renewed) ÷ leads created in the period; families still on a trial are shown separately in the Trial state | ClickUp + Razorpay |
| Cost per qualified lead | Meta spend ÷ qualified leads, per campaign | Meta Ads + ClickUp (joined on campaign tag) |
| Organic leads | Leads with no paid campaign tag | ClickUp (source field) |
| Days to decide | Days from first contact to first payment (trial or full), or to dropped; target ≤ 45 days, leads past 45 days flagged | ClickUp stage dates |

### Campaigns and landing pages
| Metric | Definition | Source |
|---|---|---|
| Click rate (CTR) by creative | Clicks ÷ impressions; best and worst listed | Meta Ads |
| Frequency by ad set | Average times each person saw the ad (≥ 3 → refresh) | Meta Ads |
| Landing-page drop-off | Visitors who leave without acting; scroll depth, quick-backs | Google Analytics 4 + Microsoft Clarity |
| Load time | Mobile and desktop page speed, checked daily | Google PageSpeed Insights |

## 3. How the data gets in

From the website teardown (01): every form already sends its campaign tags and Meta click IDs to the n8n lead webhook, and the workshop checkout carries the same tags to Razorpay.

```
Website forms ── n8n lead webhook ──► ClickUp lead (with campaign tags)
ClickUp (stages, dates, reasons) ──┐
Razorpay (payments, invoices) ─────┤
Meta Ads (spend, CTR, frequency) ──┤
Smallest.ai (call outcomes) ───────┼──► n8n (daily + on change) ──► Postgres (reporting) ──► Metabase
Google Analytics 4 (page drop-off) ┤
Microsoft Clarity (behaviour) ─────┤
PageSpeed Insights (load time) ────┘
```

- **Same Metabase and reporting database as the student dashboard (P4).** Since hosting is already paid for.
- **To check first:** the `lead-form` workflow writes every campaign field onto the ClickUp lead; and each Meta ad passes its own name in its URL settings, so a lead can be matched to the exact creative.
- **Data-freshness alert:** n8n flags any source that hasn't updated on schedule (P3, stage 8).

## 4. Dashboard design

**Timeline selector** at the top of every view: This month · Last month · Last 3 months · Quarter to date · Custom range. Every number shows its change vs. the period just before, of the same length.

| View | For | What's on it |
|---|---|---|
| **Overview** | Leadership | 8 tiles vs. target (revenue, full program, trials, workshop seats, workshop → program, cost per qualified lead, days to decide, unpaid invoices), with progress bars. Revenue by stream by month (full program, trial, workshops, stacked, with the target) and students onboarded by month (full vs. trial, stacked), both for the selected months. Each stream against its own target. |
| **Revenue** | Both | Revenue per stream (full program incl. renewals, trial, workshop), trial-to-full renewal rate, one chart per stream by month vs. its target, workshop break-even per workshop, unpaid invoices (amber / red), trials ending in 30 days (yellow / amber / red) |
| **Funnel** | GTM team | Funnel for both entry paths with an entry-path filter, drop-off between steps and the period before; Ambition interview outcomes (*rejected by Alcovia* vs. *dropped by family*); where families came from (ads, organic, workshops); show-up rate and days to decide; open leads past 45 days as a weekly trend by age (46–60, 61–90, over 90 days) plus the list |
| **Campaigns** | GTM team | Campaign table and click rate by ad. **Click a campaign** to see its spend, click rate, frequency, results and cost per result, with weekly charts of results, cost per result (vs. the ceiling) and frequency (vs. 3), and its ads with Scale / Refresh / Drop. Landing-page drop-off and load times. |
| **Actions** | GTM team, Leadership | Count and spend per action, and every running ad tagged **Scale / Refresh / Drop / Watch** with its reason, sorted by spend; a click opens its campaign |

**Look:** Alcovia's brand colours (deep green header, gold accent; maroon, gold and navy for full program, trial and workshops). The offline copy also carries the logo.
