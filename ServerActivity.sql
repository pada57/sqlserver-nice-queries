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



--	)SELECT COUNT(*) FROM (SELECT rm.[Id]                      ,rm.[Title]                      ,rm.[UniqueCaseKey]                      ,rm.[IpType]                      ,rm.[CustomerId]                      ,rm.[CustomerName]                      ,rm.[RegisteredOwnerNames]                      ,rm.[Country]                      ,rm.[MainNumber]                      ,rm.[ApplicationNumber]                      ,rm.[ApplicationDate]                      ,rm.[PublicationNumber]                      ,rm.[PublicationDate]                      ,rm.[GrantRegistrationNumber]                      ,rm.[GrantRegistrationDate]                      ,rm.[PriorityNumber]                      ,rm.[PriorityDate]                      ,rm.[PCTApplicationNumber]                      ,rm.[PCTApplicationDate]                      ,rm.[ExpiryDate]                      ,rm.[OverriddenExpiryDate]                      ,rm.[NumberOfClaims]                      ,rm.[ParentId]                      ,rm.[CountryId]                      ,rm.[IpOrigin]                      ,rm.[IpMainTypeInternalCode]                      ,rm.[IpStatus]                      ,rm.[DennemeyerOfficeId]                      ,rm.[IpRightFamilyId]                      ,rm.[ClientInfo]                      ,rm.[DueDate]                      ,rm.[HasMaintenanceAction]                      ,rm.[IsActive]                      ,rm.[ValidatedStatesReceived]                      ,CASE WHEN x.IpRightId IS NULL THEN 0 ELSE 1 END HasClientInfo                      ,CASE WHEN rm.PayeeType = 'Agent' THEN rm.[PaymentName] ELSE '' END AgentName                      ,rm.[DataCheckStatus]                      ,rm.[LastCheckDate]                      ,rm.[RecheckDate]                      FROM ReadModel_IpRightList rm                           LEFT JOIN                           (                              SELECT ib.IpRightId FROM V_IpRight_ActiveBillingInfo ib INNER JOIN Customer c ON c.CustomerId = ib.CompanyId                               WHERE (1=1)                              GROUP BY ib.IpRightId                          ) x ON rm.Id = x.IpRightId) AS X WHERE ((IsActive IN (@IsActive1))
 --UPDATE ipmap    SET ipmap.Recalculate = 1    FROM CountryLawConfigIpRightMap ipmap     WHERE ipmap.CountryLawConfigId = @i
 --SELECT DISTINCT re.RecipientId                               ,re.RecipientType                               ,re.DnCronExpression AS CronExpression                               ,re.DnBillingPeriod AS BillingPeriod                               ,re.DnCaseDue AS CaseDue                                  ,rm.DnProducedUpTo as DnProducedUpTo                              FROM V_Recipients re                           LEFT JOIN ReadModel_CustomerList rm ON rm.Id = re.RecipientId                               WHERE RecipientAddressTypeInternalCode = 'DebitNote'                               AND RecipientType <> 'Division

 
				