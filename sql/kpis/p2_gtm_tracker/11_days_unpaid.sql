-- KPI 11: Days unpaid
-- Definition : How long each open invoice has waited.
-- Formula    : Today − invoice issue date
-- Source     : Razorpay invoices
-- Target     : Amber 5–9 days, red 10+ days
-- Access     : full_access

SELECT invoice_id, lead_id, plan, amount, issued_on,
       ops.as_of() - issued_on AS days_unpaid,
       CASE WHEN ops.as_of() - issued_on >= ops.setting('invoice_red')   THEN 'Red'
            WHEN ops.as_of() - issued_on >= ops.setting('invoice_amber') THEN 'Amber' END AS colour
FROM revenue.invoices
WHERE paid_on IS NULL AND issued_on <= ops.as_of()
ORDER BY days_unpaid DESC;
