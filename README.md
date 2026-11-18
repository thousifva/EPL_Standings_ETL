# EPL Standings ETL

An end-to-end data pipeline that pulls English Premier League standings from the API-Football REST API, loads them into a small SQL Server warehouse with idempotent upserts, and serves a Power BI season dashboard. Built as a guided training project (Rows & Columns data analytics programme).

## About this project

Most beginner analysis stops at a CSV. This project goes the full route a data team would: ask an API for data, keep the raw reply, shape it into clean tables, load it into a real database that protects itself from bad data, prove the load worked, and only then build a dashboard on top. Everything is driven from one Jupyter notebook, and rerunning it any week of the season refreshes the numbers without creating duplicates.

**Flow:** API-Football -> raw JSON -> pandas DataFrame -> staging tables -> stored procedures (UPSERT) -> warehouse tables in SQL Server -> Power BI

| Stage | What happens | Where (notebook) |
|---|---|---|
| Extract | GET request to the API, reply saved as raw JSON | Cells 3 |
| Transform | Parse JSON, check the API's own `errors` field, flatten into DataFrames | Cells 4-6 |
| Load | Build warehouse in SQL, upsert via staging | Cells 7-12 |
| Check | Verify counts, duplicates, joins, re-run safety | Cells 13-16 |
| Visualize | Power BI reads the warehouse tables | Power BI |

## Why it matters

The pipeline is built around the habits that make data work trustworthy:

- **Idempotent upserts.** Each stored procedure runs an `UPDATE ... JOIN` then an `INSERT ... WHERE NOT EXISTS` inside one transaction. Run the load twice, or after every match week, and you get fresh numbers with no duplicates; if anything fails halfway, the transaction rolls back.
- **The database enforces the rules.** `pl_standings` has a composite primary key on (`season`, `team_id`), so a team can appear only once per season, and a foreign key to `dim_team`, so standings cannot point at a team that does not exist. That is why teams load before standings.
- **"Load finished" is not proof.** After loading, the notebook asks SQL Server directly: row counts (20 teams, 20 standings rows), a duplicate scan on the key (expected 0), and a join check. The validation script goes further: it damages rows on purpose, reloads, and shows them repaired, proving both the INSERT and UPDATE paths.
- **Staging before warehouse.** New batches land in keyless staging tables that hold only the current batch, so a bad batch never touches the warehouse directly.

## Dashboard

![Premier League 2024 - Season Overview](powerbi/dashboard.png)

The report reads `dim_team` and `pl_standings`, linked on `team_id` (one team to many standings rows), so stadium details sit next to league points. Staging tables are not imported; they are only landing areas. The values shown (380 matches, 1,115 goals, Liverpool champions with 84 points) are from the author's own 2024-25 load, as displayed on his finished dashboard. The custom Floodlit Pitch theme is included in `powerbi/`.

## API usage

- Provider: [API-Football](https://www.api-football.com/) REST API (`BASE_URL` defaults to `https://v3.football.api-sports.io`).
- Two endpoints: `/standings` (the numbers) and `/teams` (team and stadium details).
- Every request identifies itself with the `x-apisports-key` header and asks for `league=39` (Premier League), `season=2024`. Both are variables; change one line to load another league or season.
- The raw reply is saved exactly as received before any parsing, and the API's own `errors` field is checked: HTTP 200 only means the server answered, not that it sent data.

## Setup

**Prerequisites:** Python 3 with `requests pandas sqlalchemy pyodbc python-dotenv` (the notebook's first cell installs them), SQL Server with the ODBC Driver 17, and a free API-Football key.

**Configuration:** copy `.env.example` to `.env` and fill in your values. The notebook reads everything from here, so no secret ever appears in code or on screen:

```
API_KEY=your-api-football-key-here
BASE_URL=https://v3.football.api-sports.io
MSSQL_SERVER=.\SQLEXPRESS
```

Blank user/password in the config cell means Windows Authentication; no database password is stored anywhere. Set `MSSQL_SERVER` only if your instance has a different name.

**Run order:**

1. Apply `sql/01_create_tables.sql`, `02_usp_upsert_pl_standings.sql` and `03_usp_upsert_dim_team.sql` (the notebook also carries this SQL inline and can build the database itself).
2. Run the notebook cells in order: extract, transform, load, check.
3. Optionally run `sql/04_checks_and_upsert_demo.sql` in SSMS to inventory the objects, view the league table, and watch the deliberate-damage upsert test repair itself.
4. Open `powerbi/Premier_League_2024_Dashboard.pbix` and point it at your `PremierLeagueDB`.

## Key concepts demonstrated

- REST API consumption with headers, params and defensive error handling
- JSON parsing and flattening with `pandas.json_normalize()`, with SQL-friendly column naming
- Dimensional modelling: a `dim_team` dimension and a `pl_standings` fact table linked by `team_id`
- Composite primary keys and foreign keys as data-quality guardrails
- Transactional UPSERT stored procedures (`UPDATE` + `INSERT WHERE NOT EXISTS`)
- Staging-table load patterns and post-load verification
- Power BI modelling, relationships and custom themes

## Structure

- `PL_Standings_ETL.ipynb` - the author's final notebook: extract, transform, load and check, step by step, with its real run outputs
- `sql/01_create_tables.sql`, `02_usp_upsert_pl_standings.sql`, `03_usp_upsert_dim_team.sql` - standalone table definitions and upsert stored procedures (reconstructed from project notes; the notebook carries the same SQL inline)
- `sql/04_checks_and_upsert_demo.sql` - the author's validation script: object inventory, league-table join, deliberate-damage upsert test, procedure listing
- `powerbi/` - the report file (.pbix), the Floodlit Pitch theme, and a dashboard screenshot
- `.env.example` - expected environment variables (API key, base URL, SQL Server instance)

## Status and limitations

The notebook, validation script, theme and Power BI report are the author's final working files; the notebook keeps its real run outputs. The standalone SQL setup scripts (01-03) are reconstructed from project notes and are syntax-checked, not run-tested. One privacy scrub: the author's machine name in the config cell was replaced with the `MSSQL_SERVER` environment variable. The pipeline loads one league and season per configuration; the database name (`PremierLeagueDB`) is fixed in the scripts.

Note: training project on public API data, not client work.
