USE PremierLeagueDB;

-- PART A: What exists in the warehouse (tables, procedures, foreign key)

SELECT name AS table_name, create_date FROM sys.tables ORDER BY name;
SELECT name AS procedure_name, modify_date FROM sys.procedures ORDER BY name;

SELECT fk.name AS foreign_key,
       OBJECT_NAME(fk.parent_object_id)     AS child_table,
       OBJECT_NAME(fk.referenced_object_id) AS parent_table
FROM sys.foreign_keys AS fk;

-- PART B: View the loaded data: dimension table, then the full league table via a join

SELECT * FROM dbo.dim_team ORDER BY team_name;

SELECT s.season, s.rank, t.team_name, t.venue_name,
       s.played, s.won, s.drawn, s.lost, s.goals_for, s.goals_against,
       s.goals_diff, s.points
FROM dbo.pl_standings AS s
JOIN dbo.dim_team AS t ON s.team_id = t.team_id
ORDER BY s.rank;

-- PART C: Prove the UPSERT. Damage the data on purpose, rerun the notebook load, and show it repaired:
--         the DELETE tests the INSERT path, and the points = 0 change tests the UPDATE path

UPDATE dbo.pl_standings SET points = 0 WHERE season = 2024 AND team_id = 40;  -- Liverpool
DELETE FROM dbo.pl_standings WHERE season = 2024 AND team_id = 33;             -- one other team

SELECT COUNT(*) AS rows_now FROM dbo.pl_standings;                             -- expect 19
SELECT team_id, points FROM dbo.pl_standings WHERE team_id = 40;               -- expect 0

-- go back to the notebook and run Cell 15 again (it reloads both tables)

SELECT COUNT(*) AS rows_now FROM dbo.pl_standings;                             -- expect 20 (INSERT path)
SELECT team_id, points FROM dbo.pl_standings WHERE team_id = 40;               -- expect 84 (UPDATE path)

-- PART D: Show the procedure code live with sp_helptext

EXEC sp_helptext 'dbo.usp_upsert_pl_standings';
EXEC sp_helptext 'dbo.usp_upsert_dim_team';