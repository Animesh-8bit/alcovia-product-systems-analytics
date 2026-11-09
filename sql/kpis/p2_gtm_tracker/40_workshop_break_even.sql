-- KPI 40: Workshop break-even
-- Definition : Whether a workshop paid for its ads and venue.
-- Formula    : Seat revenue ÷ (workshop ad spend + venue cost)
-- Source     : Razorpay + Meta Ads + venue cost
-- Target     : 1.00 or more
-- Access     : full_access
\ir ../../_period.sql

WITH p AS (SELECT :'start_on'::date AS s, :'end_on'::date AS e),
w AS (SELECT ev.*, LAG(held_on) OVER (ORDER BY held_on) AS previous_on
      FROM events.events ev JOIN events.event_types t USING (event_type_id) WHERE t.name = 'Public workshop'),
spend AS (SELECT w.event_id, COALESCE(SUM(d.spend), 0) AS ad_spend
          FROM w LEFT JOIN (ads.ad_daily d JOIN ads.ads a USING (ad_id) JOIN ads.campaigns c USING (campaign_id))
            ON c.campaign_type = 'Workshop' AND d.day > COALESCE(w.previous_on, '-infinity') AND d.day <= w.held_on
          GROUP BY w.event_id)
SELECT w.event_id AS workshop_id, w.held_on, w.held_on > ops.as_of() AS still_selling,
       w.seats_sold * ads.target('seat_price')                                                   AS seat_revenue,
       spend.ad_spend, ads.target('venue')                                                       AS venue_cost,
       round(w.seats_sold * ads.target('seat_price') / (spend.ad_spend + ads.target('venue')), 2) AS break_even,
       (SELECT COUNT(converted_on) FROM leads.v_lead_state l WHERE l.workshop_id = w.event_id)   AS converted_later
FROM w JOIN spend USING (event_id) CROSS JOIN p
WHERE w.held_on BETWEEN p.s AND (date_trunc('month', p.e) + interval '1 month - 1 day')::date
ORDER BY w.held_on;
