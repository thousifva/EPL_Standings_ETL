CREATE OR ALTER PROCEDURE dbo.usp_upsert_pl_standings
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    -- 1) UPDATE rows that already exist (same season + team_id)
    UPDATE t
    SET t.rank          = s.rank,
        t.team_name     = s.team_name,
        t.points        = s.points,
        t.goals_diff    = s.goals_diff,
        t.form          = s.form,
        t.played        = s.played,
        t.won           = s.won,
        t.drawn         = s.drawn,
        t.lost          = s.lost,
        t.goals_for     = s.goals_for,
        t.goals_against = s.goals_against
    FROM dbo.pl_standings AS t
    JOIN dbo.stg_pl_standings AS s
      ON t.season = s.season AND t.team_id = s.team_id;


    -- 2) INSERT rows that are new
    INSERT INTO dbo.pl_standings
        (season, team_id, rank, team_name, points, goals_diff, form,
         played, won, drawn, lost, goals_for, goals_against)
    SELECT s.season, s.team_id, s.rank, s.team_name, s.points, s.goals_diff, s.form,
           s.played, s.won, s.drawn, s.lost, s.goals_for, s.goals_against
    FROM dbo.stg_pl_standings AS s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.pl_standings AS t
        WHERE t.season = s.season AND t.team_id = s.team_id
    );

    COMMIT TRANSACTION;
END
