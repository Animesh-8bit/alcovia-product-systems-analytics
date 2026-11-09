# Reporting database: how to run it

Postgres 16 with the made-up sample data from both dashboards. Schema overview: [SCHEMA.md](SCHEMA.md).

```bash
# 1. Start Postgres (Docker)
docker run -d --name alcovia-db -e POSTGRES_PASSWORD=alcovia -e POSTGRES_DB=alcovia \
  -p 5433:5432 -v "$PWD/db":/db postgres:16

# 2. Create the tables and load the sample data
docker exec alcovia-db psql -U postgres -d alcovia -v ON_ERROR_STOP=1 -f /db/schema.sql
docker exec alcovia-db psql -U postgres -d alcovia -v ON_ERROR_STOP=1 -f /db/seed.sql

# 3. Query it
docker exec -it alcovia-db psql -U postgres -d alcovia
```

`seed.sql` is generated from the dashboards' sample JSON:

```bash
python3 db/build_seed.py db/sample_source/p2 db/sample_source/p4 > db/seed.sql
```

Check: for 1 Dec 2026 – 26 Feb 2027 the payments add up to ₹60,51,822, with 21 conversions, 13 trials started and 178 workshop seats, the same as the GTM dashboard's "Last 3 months".
