-- Month for the P4 KPI queries. Override: psql -v month=2027-08-01 -f ...
-- Quarter-level items use the quarter that contains the month.
\if :{?month}
\else
\set month 2027-09-01
\endif
