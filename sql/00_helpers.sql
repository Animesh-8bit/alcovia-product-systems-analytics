-- Helpers used by the KPI queries. Run once after schema.sql and seed.sql.
-- Every KPI query takes a period (start_on, end_on); these keep the shared rules in one place.
-- Functions and views live in the schema whose data they read, so the access rules carry over:
-- ops / leads helpers work for team_access; ads / revenue helpers need full_access.

-- A shared setting, e.g. ops.setting('days_to_decide') = 45
CREATE OR REPLACE FUNCTION ops.setting(k text) RETURNS numeric
LANGUAGE sql STABLE AS $$ SELECT value_num FROM ops.settings WHERE key = k $$;

-- A money or ad target, e.g. ads.target('cpql') = 5000 (restricted)
CREATE OR REPLACE FUNCTION ads.target(k text) RETURNS numeric
LANGUAGE sql STABLE AS $$ SELECT value_num FROM ads.targets WHERE key = k $$;

-- The date the data runs to. In production this is current_date; the sample data stops on 26 Feb 2027.
CREATE OR REPLACE FUNCTION ops.as_of() RETURNS date
LANGUAGE sql STABLE AS $$ SELECT COALESCE((SELECT value_text::date FROM ops.settings WHERE key = 'as_of'), current_date) $$;

-- How many months of target a period covers. Each month counts the share of its days inside the period,
-- so 1 Dec – 26 Feb = 1 + 1 + 26/28 = 2.93.
CREATE OR REPLACE FUNCTION ops.months_of_target(start_on date, end_on date) RETURNS numeric
LANGUAGE sql IMMUTABLE AS $$
    SELECT round(SUM(
        (LEAST(end_on, (m + interval '1 month - 1 day')::date) - GREATEST(start_on, m::date) + 1)::numeric
        / extract(day FROM (m + interval '1 month - 1 day'))
    ), 2)
    FROM generate_series(date_trunc('month', start_on), date_trunc('month', end_on), interval '1 month') AS m
$$;

-- The same-length period just before a period, e.g. 1 Dec – 26 Feb (88 days) → 4 Sep – 30 Nov
CREATE OR REPLACE FUNCTION ops.prev_start(start_on date, end_on date) RETURNS date
LANGUAGE sql IMMUTABLE AS $$ SELECT start_on - (end_on - start_on + 1) $$;

-- Each lead with its conversion state, from the student's enrolments (no money involved, so the team can read it).
-- A family converts only when it pays for the full term: a Full program enrolment (paid directly, or a renewed trial).
-- A family whose only enrolment is a Trial is in the Trial state.
CREATE OR REPLACE VIEW leads.v_lead_state AS
SELECT l.*,
       s.student_id,
       e.first_paid_on,                                           -- first payment of any plan (trial or full)
       e.first_plan,
       e.converted_on,                                            -- full term paid
       CASE
           WHEN e.converted_on IS NOT NULL THEN 'Converted'
           WHEN e.first_plan = 'Trial' THEN 'Trial'
           WHEN l.closed_on IS NOT NULL THEN 'Closed'
           ELSE 'Open'
       END AS state
FROM leads.leads l
LEFT JOIN students.families f ON f.lead_id = l.lead_id
LEFT JOIN students.students s ON s.family_id = f.family_id
LEFT JOIN LATERAL (
    SELECT MIN(started_on) AS first_paid_on,
           (array_agg(plan ORDER BY started_on, plan DESC))[1] AS first_plan,   -- 'Trial' sorts after 'Full program'
           MIN(started_on) FILTER (WHERE plan = 'Full program') AS converted_on
    FROM students.enrolments en WHERE en.student_id = s.student_id
) e ON true;

-- Revenue stream of each payment: full program (including trial renewals), trial, workshops (restricted)
CREATE OR REPLACE VIEW revenue.v_payment_stream AS
SELECT p.*,
       CASE p.payment_type
           WHEN 'Full program' THEN 'Full program'
           WHEN 'Trial renewal' THEN 'Full program'
           WHEN 'Trial' THEN 'Trial'
           ELSE 'Workshops'
       END AS stream
FROM revenue.payments p;

GRANT SELECT ON leads.v_lead_state TO full_access, team_access;
GRANT SELECT ON revenue.v_payment_stream TO full_access;

-- Every ad that ran in a period, with its results, cost per result and action (restricted).
-- Results: qualified leads for program ads, seats sold for workshop ads.
-- Action rules (P2 doc §1d), checked in this order:
--   Ended   : no spend on the last day of the period
--   Drop    : program ad with 5+ leads and none qualified, OR cost per result over the ceiling
--             in the last 2 weeks AND in the 2 weeks before
--   Refresh : frequency 3 or more
--   Scale   : cost per result at or under the ceiling
--   Watch   : anything else (over the ceiling for less than 2 weeks)
CREATE OR REPLACE FUNCTION ads.ad_results(p_ad int, p_type text, s date, e date) RETURNS bigint
LANGUAGE sql STABLE AS $$
    SELECT CASE p_type
        WHEN 'Program' THEN (SELECT COUNT(*) FROM leads.leads WHERE ad_id = p_ad AND source = 'Paid' AND qualified_on BETWEEN s AND e)
        ELSE (SELECT COUNT(*) FROM revenue.payments WHERE ad_id = p_ad AND payment_type = 'Workshop seat' AND paid_on BETWEEN s AND e)
    END
$$;

CREATE OR REPLACE FUNCTION ads.period_ads(s date, e date)
RETURNS TABLE (ad_id int, ad text, campaign text, type text, ceiling numeric, spend numeric, impressions bigint, clicks bigint,
               ctr_pct numeric, frequency numeric, leads bigint, results bigint, cost_per_result numeric, action text, reason text)
LANGUAGE sql STABLE AS $$
WITH r AS (
    SELECT a.ad_id, a.name AS ad, c.name AS campaign, c.campaign_type AS type,
           CASE c.campaign_type WHEN 'Program' THEN ads.target('cpql') ELSE ads.target('cost_per_seat') END AS ceiling,
           SUM(d.spend) AS spend, SUM(d.impressions) AS impressions, SUM(d.clicks) AS clicks,
           (array_agg(d.frequency ORDER BY d.day DESC))[1] AS frequency,
           MAX(d.day) = e AS running
    FROM ads.ad_daily d JOIN ads.ads a USING (ad_id) JOIN ads.campaigns c USING (campaign_id)
    WHERE d.day BETWEEN s AND e
    GROUP BY a.ad_id, a.name, c.name, c.campaign_type
),
m AS (
    SELECT r.*,
           (SELECT COUNT(*) FROM leads.leads l WHERE l.ad_id = r.ad_id AND l.source = 'Paid' AND l.created_on BETWEEN s AND e) AS leads,
           ads.ad_results(r.ad_id, r.type, s, e) AS results,
           (SELECT COALESCE(SUM(x.spend), 0) FROM ads.ad_daily x WHERE x.ad_id = r.ad_id AND x.day BETWEEN e - 13 AND e)
               / GREATEST(ads.ad_results(r.ad_id, r.type, e - 13, e), 0.0001) AS cost_last_2w,
           (SELECT COALESCE(SUM(x.spend), 0) FROM ads.ad_daily x WHERE x.ad_id = r.ad_id AND x.day BETWEEN e - 27 AND e - 14)
               / GREATEST(ads.ad_results(r.ad_id, r.type, e - 27, e - 14), 0.0001) AS cost_2w_before
    FROM r
)
SELECT ad_id, ad, campaign, type, ceiling, spend, impressions, clicks,
       round(100.0 * clicks / NULLIF(impressions, 0), 2),
       frequency, CASE type WHEN 'Program' THEN leads END, results,
       round(spend / NULLIF(results, 0)),
       CASE
           WHEN NOT running THEN 'Ended'
           WHEN type = 'Program' AND leads >= 5 AND results = 0 THEN 'Drop'
           WHEN cost_last_2w > ceiling AND cost_2w_before > ceiling THEN 'Drop'
           WHEN frequency >= ads.target('frequency') THEN 'Refresh'
           WHEN results > 0 AND spend / results <= ceiling THEN 'Scale'
           ELSE 'Watch'
       END,
       CASE
           WHEN NOT running THEN 'Stopped running before the end of the period'
           WHEN type = 'Program' AND leads >= 5 AND results = 0 THEN leads || ' leads, none qualified'
           WHEN cost_last_2w > ceiling AND cost_2w_before > ceiling THEN
               CASE WHEN cost_last_2w > 1e6 THEN 'No results' ELSE '₹' || round(cost_last_2w) END || ' per result in the last 2 weeks, '
               || CASE WHEN cost_2w_before > 1e6 THEN 'no results' ELSE '₹' || round(cost_2w_before) END || ' the 2 before; ceiling ₹' || ceiling
           WHEN frequency >= ads.target('frequency') THEN 'Frequency ' || frequency || ', at or over ' || ads.target('frequency')
           WHEN results > 0 AND spend / results <= ceiling THEN '₹' || round(spend / results) || ' per result, under ₹' || ceiling
           ELSE 'Over the ceiling for under 2 weeks'
       END
FROM m
$$;
