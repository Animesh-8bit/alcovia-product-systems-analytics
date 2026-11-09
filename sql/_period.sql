-- Period for the KPI queries. Override from the command line:
--   psql -v start_on=2027-02-01 -v end_on=2027-02-26 -f gtm/01_revenue.sql
-- Default: the dashboard's "Last 3 months" on the sample data.
\if :{?start_on}
\else
\set start_on 2026-12-01
\endif
\if :{?end_on}
\else
\set end_on 2027-02-26
\endif
