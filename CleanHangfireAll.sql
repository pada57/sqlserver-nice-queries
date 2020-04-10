SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--SELECT * FROM [HangFire].[JobQueue]
--SELECT * FROM HangFire.Job j 
--INNER JOIN HangFire.JobParameter jp ON j.Id = jp.JobId
----WHERE StateName = 'Processing' 
--WHERE j.InvocationData LIKE '{"Type":"Psx.Reporting.Domain.ReportJobRunner%'
--ORDER BY 1 DESC

TRUNCATE TABLE [HangFire].[AggregatedCounter]
TRUNCATE TABLE [HangFire].[Counter]
TRUNCATE TABLE [HangFire].[JobParameter]
TRUNCATE TABLE [HangFire].[JobQueue]
TRUNCATE TABLE [HangFire].[List]
TRUNCATE TABLE [HangFire].[State]
DELETE FROM [HangFire].[Job]
DBCC CHECKIDENT ('[HangFire].[Job]', reseed, 0)
UPDATE [HangFire].[Hash] SET Value = 1 WHERE Field = 'LastJobId'
	
--{"Type":"Psx.Reporting.Domain.ReportJobRunner, Psx.Reporting, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null","Method":"SchedulerCallback","ParameterTypes":"[\"System.Guid, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089\",\"System.Int32, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089\"]","Arguments":"[\"\\\"3e0a7b7c-33aa-42a4-9230-7529d9bb8962\\\"\",\"1437\"]"}

--select count(*) from [HangFire].[JobQueue]
--select count(*) from [HangFire].[Job]
