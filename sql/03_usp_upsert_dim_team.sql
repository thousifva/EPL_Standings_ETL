-- NOTE: reconstructed - follows the same pattern as usp_upsert_pl_standings.
-- The original dim_team procedure was not fully visible in the recovered conversation.
CREATE OR ALTER PROCEDURE dbo.usp_upsert_dim_team
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE t
    SET t.team_name      = s.team_name,
        t.team_code      = s.team_code,
        t.country        = s.country,
        t.founded        = s.founded,
        t.venue_name     = s.venue_name,
        t.venue_city     = s.venue_city,
        t.venue_capacity = s.venue_capacity
    FROM dbo.dim_team AS t
    JOIN dbo.stg_dim_team AS s
      ON t.team_id = s.team_id;

    INSERT INTO dbo.dim_team
        (team_id, team_name, team_code, country, founded,
         venue_name, venue_city, venue_capacity)
    SELECT s.team_id, s.team_name, s.team_code, s.country, s.founded,
           s.venue_name, s.venue_city, s.venue_capacity
    FROM dbo.stg_dim_team AS s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.dim_team AS t
        WHERE t.team_id = s.team_id
    );

    COMMIT TRANSACTION;
END
