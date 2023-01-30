--Sql count per object types 
select *
from (
 -- object type counts
SELECT
       'Count' = COUNT(*),
       s.Type,
       'Description' = CASE [Type]
       WHEN 'AF' THEN 'Aggregate function (CLR)'
       WHEN 'C' THEN 'CHECK Constraint'
       WHEN 'D' THEN 'DEFAULT (constraint or stand-alone)'
       WHEN 'EC' THEN 'Edge Constraint'
       WHEN 'F' THEN 'FOREIGN KEY Constraint'
       WHEN 'FN' THEN 'Scalar functions'
       WHEN 'IF' THEN 'SQL Inline Table-valued Function'
       WHEN 'IT' THEN 'Internal table'
       WHEN 'P' THEN 'SQL Stored Procedure'
       WHEN 'PK' THEN 'Primary Key'
       WHEN 'R' THEN 'Rule (old-style, stand-alone)'
       WHEN 'RF' THEN 'Replication-filter procedure'
       WHEN 'S' THEN 'System base table'
       WHEN 'SN' THEN 'Synonym'
       WHEN 'SO' THEN 'Sequence  Object'
       WHEN 'SQ' then 'Service Queue'
       WHEN 'TA' THEN 'Assembly (CLR) DML trigger'
       WHEN 'TF' THEN 'SQL table-valued-function'
       WHEN 'TR' THEN 'SQL DML trigger'
       WHEN 'TT' THEN 'Table type'
       WHEN 'UQ' THEN 'UNIQUE Constraint'
       WHEN 'U' THEN 'User Table'
       WHEN 'V' THEN 'View'
       WHEN 'X' THEN 'Extended stored procedure'
       WHEN 'FT' THEN 'CLR table-valued-function'
       WHEN 'FS' THEN 'CLR scalar-function'
       ELSE type END
FROM
       sys.objects s
GROUP BY
       s.type      
) X 
ORDER BY x.count desc,  x.type