DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS


SELECT * FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE t.text LIKE '%Database'+'Log%';