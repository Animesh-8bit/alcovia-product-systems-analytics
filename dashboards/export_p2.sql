-- Data for the static P2 GTM tracker, exported from the reporting database as one JSON object.
-- Field names are the ones the HTML dashboard reads. Run: psql -At -f export_p2.sql > p2.json
SELECT json_build_object(
  'targets', (SELECT json_agg(x ORDER BY ord) FROM (
      SELECT 1 AS ord, 'as_of' AS key, 'Data as of' AS label, to_json(ops.as_of()::text) AS value UNION ALL
      SELECT 2, 'first_month', 'First month with data', to_json((SELECT value_text FROM ops.settings WHERE key = 'first_month')) UNION ALL
      SELECT 3, 'days_to_decide', label, to_json(value_num) FROM ops.settings WHERE key = 'days_to_decide' UNION ALL
      SELECT 4, key, label, to_json(value_num) FROM ads.targets WHERE key <> 'drop_weeks') x),
  'ads_daily', (SELECT json_agg(json_build_object('date', d.day, 'campaign', c.name, 'type', c.campaign_type, 'ad', a.name,
                  'spend', d.spend, 'impressions', d.impressions, 'clicks', d.clicks, 'frequency', d.frequency) ORDER BY d.day, a.name)
                FROM ads.ad_daily d JOIN ads.ads a USING (ad_id) JOIN ads.campaigns c USING (campaign_id)),
  'pages', (SELECT json_agg(json_build_object('date', day, 'page', page, 'visitors', visitors, 'dropoffs', dropoffs,
                  'load_mobile_s', load_mobile_s, 'load_desktop_s', load_desktop_s) ORDER BY day, page) FROM ads.page_daily),
  'workshops', (SELECT json_agg(json_build_object('workshop_id', e.event_id, 'date', e.held_on, 'venue', e.venue, 'seats_sold', e.seats_sold,
                  'attended', e.attended) ORDER BY e.held_on)
                FROM events.events e JOIN events.event_types t USING (event_type_id) WHERE t.name = 'Public workshop'),
  'leads', (SELECT json_agg(json_build_object('lead_id', l.lead_id, 'created', l.created_on, 'path', l.entry_path, 'source', l.source,
                  'ad', a.name, 'workshop_id', l.workshop_id, 'qualified', l.qualified_on, 'call_booked', l.call_booked_on,
                  'call_attended', l.call_attended_on, 'interview', l.interview_on, 'interview_outcome', l.interview_outcome,
                  'architect', l.architect_on, 'paid', i.paid_on, 'plan', i.plan, 'closed', l.closed_on, 'closed_reason', l.closed_reason)
                  ORDER BY l.created_on, l.lead_id)
            FROM leads.leads l LEFT JOIN ads.ads a USING (ad_id) LEFT JOIN revenue.invoices i ON i.lead_id = l.lead_id),
  'invoices', (SELECT json_agg(json_build_object('invoice_id', invoice_id, 'family', 'Family ' || substr(lead_id, 2), 'plan', plan,
                  'amount', amount, 'issued', issued_on, 'paid', paid_on) ORDER BY invoice_id) FROM revenue.invoices),
  'trials', (SELECT json_agg(json_build_object('trial_id', 'T-' || substr(f.lead_id, 2), 'family', 'Family ' || substr(f.lead_id, 2),
                  'start', e.started_on, 'end', e.ends_on, 'status', e.status) ORDER BY e.started_on)
             FROM students.enrolments e JOIN students.students s USING (student_id) JOIN students.families f USING (family_id) WHERE e.plan = 'Trial'),
  'payments', (SELECT json_agg(json_build_object('payment_id', p.payment_id, 'date', p.paid_on,
                  'type', CASE p.payment_type WHEN 'Trial renewal' THEN 'Renewal' ELSE p.payment_type END, 'amount', p.amount,
                  'ref', COALESCE(p.invoice_id, p.workshop_id), 'path', p.entry_path, 'ad', a.name) ORDER BY p.payment_id)
               FROM revenue.payments p LEFT JOIN ads.ads a USING (ad_id))
);
