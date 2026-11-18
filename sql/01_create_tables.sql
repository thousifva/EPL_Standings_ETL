-- ======================================================
-- DIMENSION TABLE: dim_team
-- Describes WHO the team is. One row per team, regardless of season.
-- ======================================================
CREATE TABLE dbo.dim_team (
    team_id        INT            NOT NULL PRIMARY KEY,  -- unique id from the API; the link to standings
    team_name      NVARCHAR(100)  NOT NULL,
    team_code      NVARCHAR(10)   NULL,                  -- NULL allowed: API may not supply every detail
    country        NVARCHAR(50)   NULL,
    founded        INT            NULL,
    venue_name     NVARCHAR(150)  NULL,
    venue_city     NVARCHAR(100)  NULL,
    venue_capacity INT            NULL
);

-- ======================================================
-- STANDINGS TABLE: pl_standings
-- Holds the NUMBERS. One row per team per season.
-- ======================================================
CREATE TABLE dbo.pl_standings (
    season         INT            NOT NULL,
    team_id        INT            NOT NULL,
    rank           INT            NOT NULL,
    team_name      NVARCHAR(100)  NOT NULL,
    points         INT            NOT NULL,
    goals_diff     INT            NOT NULL,
    form           NVARCHAR(20)   NULL,                  -- can be empty early in a season
    played         INT            NOT NULL,
    won            INT            NOT NULL,
    drawn          INT            NOT NULL,
    lost           INT            NOT NULL,

    goals_for      INT            NOT NULL,
    goals_against  INT            NOT NULL,

    -- COMPOSITE PRIMARY KEY: a team can appear only once per season,
    -- so the database itself blocks duplicates
    CONSTRAINT PK_pl_standings PRIMARY KEY (season, team_id),

    -- FOREIGN KEY: every standings row must point to a real team in dim_team
    -- (this is why teams must be loaded BEFORE standings)
    CONSTRAINT FK_standings_team FOREIGN KEY (team_id) REFERENCES dbo.dim_team (team_id)
);

-- ======================================================
-- STAGING TABLES: temporary landing area for each new batch
-- Same columns as the warehouse tables, but no keys.
-- WHERE 1 = 0 copies the structure only, with no rows.
-- ======================================================
SELECT * INTO dbo.stg_dim_team     FROM dbo.dim_team     WHERE 1 = 0;
SELECT * INTO dbo.stg_pl_standings FROM dbo.pl_standings WHERE 1 = 0;
