--First part of the script
SELECT instance_name AS 'Database',
[Data File(s) Size (KB)]/1024 AS [Data file (MB)],
[Log File(s) Size (KB)]/1024 AS [Log file (MB)],
[Log File(s) Used Size (KB)]/1024 AS [Log file space used (MB)]
FROM (SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name IN
('Data File(s) Size (KB)',
'Log File(s) Size (KB)',
'Log File(s) Used Size (KB)')
AND instance_name = 'tempdb') AS A
PIVOT
(MAX(cntr_value) FOR counter_name IN
([Data File(s) Size (KB)],
[LOG File(s) Size (KB)],
[Log File(s) Used Size (KB)])) AS B
GO
--
--Second part of the script
SELECT create_date AS [Creation date],
recovery_model_desc [Recovery model]
FROM sys.databases WHERE name = 'tempdb'
GO

SELECT SUM(size)/128 AS [Total database size (MB)]
FROM tempdb.sys.database_files

GO
SELECT 
(SUM(unallocated_extent_page_count)/128) AS [Free space (MB)],
SUM(internal_object_reserved_page_count)*8 AS [Internal objects (KB)],
SUM(user_object_reserved_page_count)*8 AS [User objects (KB)],
SUM(version_store_reserved_page_count)*8 AS [Version store (KB)]
FROM sys.dm_db_file_space_usage
--database_id '2' represents tempdb
WHERE database_id = 2
GO
USE tempdb
SELECT tb.name AS [Temporary table name],
stt.row_count AS [Number of rows], 
stt.used_page_count * 8 AS [Used space (KB)], 
stt.reserved_page_count * 8 AS [Reserved space (KB)] FROM tempdb.sys.partitions AS prt 
INNER JOIN tempdb.sys.dm_db_partition_stats AS stt 
ON prt.partition_id = stt.partition_id 
AND prt.partition_number = stt.partition_number 
INNER JOIN tempdb.sys.tables AS tb 
ON stt.object_id = tb.object_id 
ORDER BY tb.name

GO
SELECT R1.session_id, R1.request_id, R1.Task_request_internal_objects_alloc_page_count, R1.Task_request_internal_objects_dealloc_page_count,
R1.Task_request_user_objects_alloc_page_count,R1.Task_request_user_objects_dealloc_page_count,R3.Session_request_internal_objects_alloc_page_count ,
R3.Session_request_internal_objects_dealloc_page_count,R3.Session_request_user_objects_alloc_page_count,R3.Session_request_user_objects_dealloc_page_count,
R2.sql_handle, RL2.text as SQLText, R2.statement_start_offset, R2.statement_end_offset, R2.plan_handle FROM (SELECT session_id, request_id, 
SUM(internal_objects_alloc_page_count) AS Task_request_internal_objects_alloc_page_count, SUM(internal_objects_dealloc_page_count)AS
Task_request_internal_objects_dealloc_page_count,SUM(user_objects_alloc_page_count) AS Task_request_user_objects_alloc_page_count,
SUM(user_objects_dealloc_page_count)AS Task_request_user_objects_dealloc_page_count FROM sys.dm_db_task_space_usage 
GROUP BY session_id, request_id) R1 INNER JOIN (SELECT session_id, SUM(internal_objects_alloc_page_count) AS Session_request_internal_objects_alloc_page_count,
SUM(internal_objects_dealloc_page_count)AS Session_request_internal_objects_dealloc_page_count,SUM(user_objects_alloc_page_count) AS Session_request_user_objects_alloc_page_count,
SUM(user_objects_dealloc_page_count)AS Session_request_user_objects_dealloc_page_count FROM sys.dm_db_Session_space_usage 
GROUP BY session_id) R3 on R1.session_id = R3.session_id 
left outer JOIN sys.dm_exec_requests R2 ON R1.session_id = R2.session_id and R1.request_id = R2.request_id
OUTER APPLY sys.dm_exec_sql_text(R2.sql_handle) AS RL2
Where
Task_request_internal_objects_alloc_page_count >0 or
Task_request_internal_objects_dealloc_page_count>0 or
Task_request_user_objects_alloc_page_count >0 or
Task_request_user_objects_dealloc_page_count >0 or
Session_request_internal_objects_alloc_page_count >0 or
Session_request_internal_objects_dealloc_page_count >0 or
Session_request_user_objects_alloc_page_count >0 or
Session_request_user_objects_dealloc_page_count >0 
GO
SELECT database_transaction_log_bytes_reserved,session_id 
  FROM sys.dm_tran_database_transactions AS tdt 
  INNER JOIN sys.dm_tran_session_transactions AS tst 
  ON tdt.transaction_id = tst.transaction_id 
  WHERE database_id = 10; 
  GO
  SELECT *
FROM sys.sysprocesses
GO
SELECT  COALESCE(T1.session_id, T2.session_id) [session_id] ,        T1.request_id ,
        COALESCE(T1.database_id, T2.database_id) [database_id],
        COALESCE(T1.[Total Allocation User Objects], 0)
        + T2.[Total Allocation User Objects] [Total Allocation User Objects] ,
        COALESCE(T1.[Net Allocation User Objects], 0)
        + T2.[Net Allocation User Objects] [Net Allocation User Objects] ,
        COALESCE(T1.[Total Allocation Internal Objects], 0)
        + T2.[Total Allocation Internal Objects] [Total Allocation Internal Objects] ,
        COALESCE(T1.[Net Allocation Internal Objects], 0)
        + T2.[Net Allocation Internal Objects] [Net Allocation Internal Objects] ,
        COALESCE(T1.[Total Allocation], 0) + T2.[Total Allocation] [Total Allocation] ,
        COALESCE(T1.[Net Allocation], 0) + T2.[Net Allocation] [Net Allocation] ,
        COALESCE(T1.[Query Text], T2.[Query Text]) [Query Text]
FROM    ( SELECT    TS.session_id ,
                    TS.request_id ,
                    TS.database_id ,
                    CAST(TS.user_objects_alloc_page_count / 128 AS DECIMAL(15,
                                                              2)) [Total Allocation User Objects] ,
                    CAST(( TS.user_objects_alloc_page_count
                           - TS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15,
                                                              2)) [Net Allocation User Objects] ,
                    CAST(TS.internal_objects_alloc_page_count / 128 AS DECIMAL(15,
                                                              2)) [Total Allocation Internal Objects] ,
                    CAST(( TS.internal_objects_alloc_page_count
                           - TS.internal_objects_dealloc_page_count ) / 128 AS DECIMAL(15,
                                                              2)) [Net Allocation Internal Objects] ,
                    CAST(( TS.user_objects_alloc_page_count
                           + internal_objects_alloc_page_count ) / 128 AS DECIMAL(15,
                                                              2)) [Total Allocation] ,
                    CAST(( TS.user_objects_alloc_page_count
                           + TS.internal_objects_alloc_page_count
                           - TS.internal_objects_dealloc_page_count
                           - TS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15,
                                                              2)) [Net Allocation] ,
                    T.text [Query Text]
          FROM      sys.dm_db_task_space_usage TS
                    INNER JOIN sys.dm_exec_requests ER ON ER.request_id = TS.request_id
                                                          AND ER.session_id = TS.session_id
                    OUTER APPLY sys.dm_exec_sql_text(ER.sql_handle) T
        ) T1
        RIGHT JOIN ( SELECT SS.session_id ,
                            SS.database_id ,
                            CAST(SS.user_objects_alloc_page_count / 128 AS DECIMAL(15,
                                                              2)) [Total Allocation User Objects] ,
                            CAST(( SS.user_objects_alloc_page_count
                                   - SS.user_objects_dealloc_page_count )
                            / 128 AS DECIMAL(15, 2)) [Net Allocation User Objects] ,
                            CAST(SS.internal_objects_alloc_page_count / 128 AS DECIMAL(15,
                                                              2)) [Total Allocation Internal Objects] ,
                            CAST(( SS.internal_objects_alloc_page_count
                                   - SS.internal_objects_dealloc_page_count )
                            / 128 AS DECIMAL(15, 2)) [Net Allocation Internal Objects] ,
                            CAST(( SS.user_objects_alloc_page_count
                                   + internal_objects_alloc_page_count ) / 128 AS DECIMAL(15,
                                                              2)) [Total Allocation] ,
                            CAST(( SS.user_objects_alloc_page_count
                                   + SS.internal_objects_alloc_page_count
                                   - SS.internal_objects_dealloc_page_count
                                   - SS.user_objects_dealloc_page_count )
                            / 128 AS DECIMAL(15, 2)) [Net Allocation] ,
                            T.text [Query Text]
                     FROM   sys.dm_db_session_space_usage SS
                            LEFT JOIN sys.dm_exec_connections CN ON CN.session_id = SS.session_id
                            OUTER APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) T
                   ) T2 ON T1.session_id = T2.session_id

GO
SELECT
st.dbid AS QueryExecutionContextDBID,
DB_NAME(st.dbid) AS QueryExecContextDBNAME,
st.objectid AS ModuleObjectId,
SUBSTRING(st.TEXT,
dmv_er.statement_start_offset/2 + 1,
(CASE WHEN dmv_er.statement_end_offset = -1
THEN LEN(CONVERT(NVARCHAR(MAX),st.TEXT)) * 2
ELSE dmv_er.statement_end_offset
END - dmv_er.statement_start_offset)/2) AS Query_Text,
dmv_tsu.session_id ,
dmv_tsu.request_id,
dmv_tsu.exec_context_id,
(dmv_tsu.user_objects_alloc_page_count - dmv_tsu.user_objects_dealloc_page_count) AS OutStanding_user_objects_page_counts,
(dmv_tsu.internal_objects_alloc_page_count - dmv_tsu.internal_objects_dealloc_page_count) AS OutStanding_internal_objects_page_counts,
dmv_er.start_time,
dmv_er.command,
dmv_er.open_transaction_count,
dmv_er.percent_complete,
dmv_er.estimated_completion_time,
dmv_er.cpu_time,
dmv_er.total_elapsed_time,
dmv_er.reads,dmv_er.writes,
dmv_er.logical_reads,
dmv_er.granted_query_memory,
dmv_es.HOST_NAME,
dmv_es.login_name,
dmv_es.program_name
FROM sys.dm_db_task_space_usage dmv_tsu
INNER JOIN sys.dm_exec_requests dmv_er
ON (dmv_tsu.session_id = dmv_er.session_id AND dmv_tsu.request_id = dmv_er.request_id)
INNER JOIN sys.dm_exec_sessions dmv_es
ON (dmv_tsu.session_id = dmv_es.session_id)
CROSS APPLY sys.dm_exec_sql_text(dmv_er.sql_handle) st
WHERE (dmv_tsu.internal_objects_alloc_page_count + dmv_tsu.user_objects_alloc_page_count) > 0
ORDER BY (dmv_tsu.user_objects_alloc_page_count - dmv_tsu.user_objects_dealloc_page_count) + (dmv_tsu.internal_objects_alloc_page_count - dmv_tsu.internal_objects_dealloc_page_count) DESC
GO
SELECT top 5 a.session_id, a.transaction_id, a.transaction_sequence_num, a.elapsed_time_seconds,
b.program_name, b.open_tran, b.status
FROM sys.dm_tran_active_snapshot_database_transactions a
join sys.sysprocesses b
on a.session_id = b.spid
ORDER BY elapsed_time_seconds DESC
  