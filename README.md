# EPL Standings ETL

A data pipeline that pulls English Premier League standings from the API-Football REST API and loads them into a small SQL Server warehouse, ready for Power BI reporting. Built as a guided training project (Rows & Columns data analytics programme).

## What it does

- Extracts standings and team data for 20 clubs (2024-25 season) from 2 API endpoints using Python (requests, pandas) in a Jupyter notebook.
- Loads each batch into a staging table, then merges it into the warehouse with stored procedures - rerunning the load updates changed rows instead of adding duplicates (idempotent upserts).
- Warehouse design: a team dimension and a standings table whose primary key is the (season, team_id) pair, so each team can appear only once per season.
- Built-in checks: after loading, the pipeline queries SQL Server for row counts and duplicate keys so a bad load is caught immediately.
- Power BI connects to both tables for standings reporting.

## Tools

Python (requests, pandas, SQLAlchemy), SQL Server (T-SQL stored procedures), Power BI, Jupyter.

## Setup and run

1. Install the Python dependencies:

   ```
   pip install requests pandas sqlalchemy pyodbc python-dotenv jupyter
   ```

2. Copy `.env.example` to `.env` and fill in your API-Football key and SQL Server instance.
3. Run `sql/01_create_tables.sql`, `02_usp_upsert_pl_standings.sql` and `03_usp_upsert_dim_team.sql` against your SQL Server, in order. `04_checks.sql` holds the post-load checks; `05_test_upsert_optional.sql` is an optional manual test.
4. Open `PL_Standings_ETL.ipynb` and run the cells top to bottom.

**Warnings**

- The notebook **drops and recreates the PremierLeagueDB database unconditionally** at the start of a run. Do not point it at a SQL Server where that name is already used for something you want to keep.
- `sql/05_test_upsert_optional.sql` **deliberately damages rows** (zeroes one team's points, deletes another) to prove the upsert repairs them on the next load. Only run it against the training database.

## Structure

- `PL_Standings_ETL.ipynb` - extract, transform and load, step by step
- `sql/` - table definitions, upsert stored procedures, checks and an optional upsert test
- `.env.example` - expected environment variables (API key, database connection)

## Status

Reconstructed from the project conversation for review; the final local version may differ. Individual cells marked "reconstructed" were rewritten where the original was incomplete.

Note: training project on public API data, not client work.
