drop table dbo.Numbers

SELECT TOP (1000000) n = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id])), P.Period, P.PeriodTypeID
INTO dbo.Numbers
FROM sys.all_objects AS s1 
--CROSS JOIN sys.all_objects AS s2
CROSS JOIN dbo.Periods P
CROSS JOIN dbo.Periods P2
OPTION (MAXDOP 1);

DROP TABLE Result1
DROP TABLE Result2

SELECT * FROM Numbers

--------------                                       
-- Start testing
-------------- 
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
DECLARE @StartTime datetime,@EndTime datetime, @Date DATETIME --@Period INT

print 'Start LP2DT ' + convert(varchar, getdate(), 21)
SELECT @StartTime=GETDATE()

SELECT @Date = dbo.LP2DT(Period, PeriodTypeID) --@Period =  dbo.DT2LP(dbo.LP2DT(Period, PeriodTypeID), PeriodTypeID) --as Date into Result1
FROM Numbers

SELECT @EndTime=GETDATE()

print 'End LP2DT ' + convert(varchar, getdate(), 21)
SELECT 'LP2DT old :', DATEDIFF(ms,@StartTime,@EndTime) AS [Duration in microseconds] 

DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE

print 'Start LP2DT_New ' + convert(varchar, getdate(), 21)
SELECT @StartTime=GETDATE()

SELECT @Date = dbo.LP2DT_New(Period, PeriodTypeID)  --@Period = dbo.DT2LP_New(dbo.LP2DT_New(Period, PeriodTypeID), PeriodTypeID) --as Date  into Result2
FROM Numbers

SELECT @EndTime=GETDATE()

print 'End LP2DT_New ' + convert(varchar, getdate(), 21)
SELECT 'LP2DT_New :', DATEDIFF(ms,@StartTime,@EndTime) AS [Duration in microseconds] 