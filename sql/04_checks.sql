-- Run after every load.

SELECT 'dim_team'     AS table_name, COUNT(*) AS row_count FROM dbo.dim_team
UNION ALL
SELECT 'pl_standings' AS table_name, COUNT(*) AS row_count FROM dbo.pl_standings

SELECT COUNT(*) AS duplicate_keys
FROM (
    SELECT season, team_id
    FROM dbo.pl_standings
    GROUP BY season, team_id
    HAVING COUNT(*) > 1
) AS d

-- Inspect objects and loaded data:
USE PremierLeagueDB;

SELECT name AS table_name, create_date FROM sys.tables ORDER BY name;
SELECT name AS procedure_name, modify_date FROM sys.procedures ORDER BY name;

SELECT fk.name AS foreign_key,
       OBJECT_NAME(fk.parent_object_id)     AS child_table,
       OBJECT_NAME(fk.referenced_object_id) AS parent_table
FROM sys.foreign_keys AS fk;

-- Part B: view the loaded data


SELECT * FROM dbo.dim_team ORDER BY team_name;

SELECT s.season, s.rank, t.team_name, t.venue_name,
       s.played, s.won, s.drawn, s.lost, s.goals_for, s.goals_against,
       s.goals_diff, s.points
FROM dbo.pl_standings AS s
JOIN dbo.dim_team AS t ON s.team_id = t.team_id
ORDER BY s.rank;
