-- KPI 10: Unpaid invoices (amount, count)
-- Definition : Invoices issued and not yet paid today. Not period-based.
-- Formula    : SUM / COUNT of invoices where issued ≤ today and paid date is empty
-- Source     : Razorpay invoices
-- Target     : 0
-- Access     : full_access

SELECT COUNT(*)                                                                   AS unpaid_invoices,
       SUM(amount)                                                                AS unpaid_amount,
       COUNT(*) FILTER (WHERE ops.as_of() - issued_on >= ops.setting('invoice_red')) AS unpaid_10_days_or_more
FROM revenue.invoices
WHERE paid_on IS NULL AND issued_on <= ops.as_of();
