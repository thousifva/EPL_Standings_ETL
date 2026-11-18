-- OPTIONAL manual test: prove the upsert updates and deletes nothing by accident.
-- Change some rows by hand, rerun the load, and confirm the counts return to 20.

UPDATE dbo.pl_standings SET points = 0 WHERE season = 2024 AND team_id = 40;  -- Liverpool
DELETE FROM dbo.pl_standings WHERE season = 2024 AND team_id = 33;             -- one other team

SELECT COUNT(*) AS rows_now FROM dbo.pl_standings;                             -- expect 19
SELECT team_id, points FROM dbo.pl_standings WHERE team_id = 40;               -- expect 0

-- After rerunning the notebook load:
SELECT COUNT(*) AS rows_now FROM dbo.pl_standings;                             -- expect 20 (INSERT path)
SELECT team_id, points FROM dbo.pl_standings WHERE team_id = 40;               -- expect 84 (UPDATE path)
