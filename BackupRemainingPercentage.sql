-- Backup remaining percentage
SELECT session_id as SPID, command, sh.text AS Query, start_time, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time
FROM sys.dm_exec_requests req CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) sh
WHERE percent_complete>0