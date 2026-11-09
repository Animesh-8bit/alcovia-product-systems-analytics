-- KPI 39: Ad spend per workshop seat
-- Definition : Workshop ad spend per seat sold, per workshop in the period.
-- Formula    : Workshop ad spend since the previous workshop ÷ seats sold
-- Source     : Meta Ads + Razorpay
-- Target     : ₹800 or less
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
w AS (SELECT ev.*, LAG(held_on) OVER (ORDER BY held_on) AS previous_on
      FROM events.events ev JOIN events.event_types t USING (event_type_id) WHERE t.name = 'Public workshop'),
spend AS (SELECT w.event_id, COALESCE(SUM(d.spend), 0) AS ad_spend
          FROM w LEFT JOIN (ads.ad_daily d JOIN ads.ads a USING (ad_id) JOIN ads.campaigns c USING (campaign_id))
            ON c.campaign_type = 'Workshop' AND d.day > COALESCE(w.previous_on, '-infinity') AND d.day <= w.held_on
          GROUP BY w.event_id)
SELECT w.event_id AS workshop_id, w.held_on, w.seats_sold, spend.ad_spend,
       round(spend.ad_spend / NULLIF(w.seats_sold, 0)) AS ad_spend_per_seat,
       ads.target('cost_per_seat') AS ceiling
FROM w JOIN spend USING (event_id) CROSS JOIN p
WHERE w.held_on BETWEEN p.s AND (date_trunc('month', p.e) + interval '1 month - 1 day')::date
ORDER BY w.held_on;
