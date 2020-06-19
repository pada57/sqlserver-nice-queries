SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT
	S.session_id, S.status ses_status, R.status req_status,
	CONVERT(NVARCHAR(12), R.start_time, 108) last_start, CONVERT(NVARCHAR(12), GETDATE() - R.start_time, 108) run_time,
	D.dbid, D.name, OBJECT_NAME(T.objectid, D.dbid) sp_name,
	SUBSTRING(T.text, R.statement_start_offset / 2, CASE R.statement_end_offset WHEN -1 THEN 50 ELSE (R.statement_end_offset - R.statement_start_offset) / 2 + 1 END) stmt,
	R.blocking_session_id, R.wait_type, R.wait_time, R.wait_resource
FROM 
	sys.dm_exec_sessions S 
	INNER JOIN sys.dm_exec_requests R ON S.session_id = R.session_id
	INNER JOIN sys.sysdatabases D ON R.database_id = D.dbid
	CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T
WHERE
	S.session_id <> @@spid
	AND S.is_user_process = 1
UNION 
SELECT
	S.session_id, S.status ses_status, R.status req_status,
	CONVERT(NVARCHAR(12), R.start_time, 108) last_start, CONVERT(NVARCHAR(12), GETDATE() - R.start_time, 108) run_time,
	D.dbid, D.name, OBJECT_NAME(T.objectid, D.dbid) sp_name,
	SUBSTRING(T.text, R.statement_start_offset / 2, CASE R.statement_end_offset WHEN -1 THEN 50 ELSE (R.statement_end_offset - R.statement_start_offset) / 2 + 1 END) stmt,
	R.blocking_session_id, R.wait_type, R.wait_time, R.wait_resource
FROM 
	sys.dm_exec_sessions S 
	LEFT JOIN sys.dm_exec_requests R ON S.session_id = R.session_id
	LEFT JOIN sys.sysdatabases D ON R.database_id = D.dbid
	OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) T
WHERE
	S.session_id IN (SELECT blocking_session_id FROM sys.dm_exec_requests WHERE blocking_session_id IS NOT NULL)

	--KILL 82

	--	)DELETE FROM IpRight WHERE IpRightId IN (SELECT @Ids WHERE 1 = 0


	  