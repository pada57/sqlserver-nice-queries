USE RCP_testresults

SELECT * FROM TestSets
SELECT * FROM TestRuns order BY 1 desc
SELECT * FROM TestExecutionResults where TestRunID > 9020 AND TestResult = 0
SELECT * FROM TestExecutionResults where TestRunID = 6539 and TestResult = 0
SELECT * FROM TestExecutionResults_SubSteps where ResultID IN (SELECT TestExecutionResults.ResultID FROM TestExecutionResults where TestRunID = 6260 and TestResult = 0)

SELECT TRR.TestCaseID, TS.TestSetName, TR.*, TRR.*
FROM TestRuns TR 
INNER JOIN TestSets TS ON TR.TestSetID = TS.TestSetID 
INNER JOIN TestExecutionResults TRR ON TR.TestRunID = TRR.TestRunID
--INNER JOIN TestExecutionResults_SubSteps TSS ON TRR.ResultID = TSS.ResultID
where TR.TestRunID > 13410 AND TRR.TestResult = 0 
ORDER BY TRR.TestCaseID, TR.TestRunDate DESC


DELETE FROM TestExecutionResults_SubSteps where ResultID IN (SELECT TestExecutionResults.ResultID FROM TestExecutionResults where TestRunID > 8880)
DELETE FROM TestExecutionResults where TestRunID > 8880
DELETE FROM TestRuns where TestRunID > 8880

SELECT * FROM TestCases_FailureOutput
select * FROM TestCases

update TestRuns SET Machine = 'AMS-AS-49' WHERE Version = 'CalcTest' and Machine = 'AMS-AS-30'

select * FROM ShareClasses_Fees order BY ShareClassID

select * from dbo.TestExecutionResults_SubSteps where ResultID = 232669

select Duration,  datediff(ms, '00:00:00.0000000', Duration) / cast((60 * 1000) as float) from dbo.TestExecutionResults_SubSteps
select Duration, cast(Duration as float) from dbo.TestExecutionResults_SubSteps

select ResultID, Duration = round(SUM(datediff(ms, '00:00:00.0000000', Duration) / cast((60 * 1000) as float)), 2)
from dbo.TestExecutionResults_SubSteps
group by ResultID

select ResultID, Duration = round(SUM(datediff(mi, '00:00:00', Duration)), 2)
from dbo.TestExecutionResults_SubSteps
group by ResultID

--
SELECT TS.TestSetID, TS.TestSetName, ISNULL(NULLIF(REPLACE(TR.[Version], 'CalcTest', ''), ''), 'Main') As Version, COUNT(*) as CountFailure
, LEFT(( SELECT CONVERT(NVARCHAR(10), TRR2.TestCaseID) + ','
           FROM TestExecutionResults TRR2
          WHERE TRR2.TestRunID = TRR.TestRunID
            AND TRR2.TestResult = 0            
          ORDER BY TestCaseID
            FOR XML PATH('') ), 50) AS TestCaseIDs
FROM TestRuns TR 
INNER JOIN TestSets TS ON TR.TestSetID = TS.TestSetID 
INNER JOIN TestExecutionResults TRR ON TR.TestRunID = TRR.TestRunID
--INNER JOIN TestExecutionResults_SubSteps TSS ON TRR.ResultID = TSS.ResultID
where DATEDIFF(HH, TR.TestRunDate, GETDATE()) < 24
    AND TRR.TestResult = 0
GROUP BY TRR.TestRunID, TS.TestSetID, TS.TestSetName, TR.Version
ORDER BY TR.Version, TS.TestSetName

-- Query from report
SELECT *
FROM (
select 
    TestVersion = ISNULL(NULLIF(REPLACE(TR.[Version], 'CalcTest', ''), ''), 'Main'),
    TestMachine = TR.Machine,
    TestSetName = isnull(TS.TestSetName, 'Summary'),
    TestsExecuted = Count(*) - sum(ISNULL(IsSkipped,0)), 
    TestsSuccessful = sum(ISNULL(TestResult,0)) - sum(ISNULL(IsSkipped,0)),
    TestsFailed = Count(*) - sum(ISNULL(TestResult,0)),
    TestsSkipped = sum(ISNULL(IsSkipped,0)),
    ExectionTimeInMinutes = round(sum(isnull(SS.Duration, 0)) / cast((60 * 1000) as float), 2),
    FinishTime = max(EndDate)
from (select max(TestRunID) as LastTestRunID, TestSetID, [Version], Machine from TestRuns
    group by TestSetID, [Version], Machine) LTR    
inner join TestExecutionResults TER on TER.TestRunID = LTR.LastTestRunID
left join TestSets TS on LTR.TestSetID = TS.TestSetID
left join ( 
    select ResultID, Duration = ISNULL(sum(datediff(ms, '00:00:00.0000000', Duration)), 0)
    from dbo.TestExecutionResults_SubSteps 
    group by ResultID ) SS 
  on TER.ResultID = SS.ResultID
left join TestRuns TR on LTR.LastTestRunID = TR.TestRunID
where TS.TestSetID is not null AND DATEDIFF(dd, TR.TestRunDate, GETDATE()) < 30
group by 
    cube(TS.TestSetName, TR.[Version]), TR.Machine
having TR.[Version] is not null AND TR.Machine is not null) as MAIN
ORDER BY MAIN.TestVersion


SELECT TOP 100 * FROM dbo.TestRuns
-- exec test
begin transaction exectest

    EXEC UT_ExecuteTestCase 82, 0, 0
    
    DECLARE @AgrCode NVARCHAR(20)
    SET @AgrCode = 'TAT29'
    SELECT * FROM Agreements where AgreementCode = @AgrCode
    SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_AUMRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
    UNION
    SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_DailyAccrualDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
    SELECT acv.VersionName, acv.DateStart, acv.DateEnd, acv.TradeBasisID, acv.ThresholdCurrencyID
	    , acv.ThresholdCalculationBasisID, acv.RebateCalculationBasisID, acv.AccrualMethodID
	    , ARS.FundPoolID, ARS.ScaleID, ARS.UseDefaultScale, ARS.UseDefaultHOP 
	    , ats.FundPoolID, ats.UseCalculationHOP, ats.UseCalculationFundPool
	    , ahop.AgentID, AG.AgentCode
    FROM Agreements_CalculationSettings acs 
	    INNER JOIN Agreements_CalculationVersions acv on acs.AgreementCalculationVersionID = acv.AgreementCalculationVersionID
	    INNER JOIN Agreements_CalculationVersionGroups acvg ON acv.AgreementCalculationVersionGroupID = acvg.AgreementCalculationVersionGroupID
	    INNER JOIN Agreements_RebateSettings ARS ON acs.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	    INNER JOIN Agreements_ThresholdSettings ats ON ats.AgreementThresholdSettingID = acs.AgreementThresholdSettingID
	    INNER JOIN Agreements_HOPMembers ahop ON ahop.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	    LEFT JOIN Agents AG ON AG.AgentID = ahop.AgentID
	    where acv.AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)

    SELECT SC.CurrencyID, A.SplitPercentage, RetroFinal = IsNull(Retro, 0) - Round(IsNull(Retro, 0) * A.SplitPercentage / 100, AM.NumberOfDecimals), BAD.* FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID INNER JOIN Agreements A ON A.AgreementID = BAD.AgreementID INNER JOIN AssetManagers AM ON AM.AssetManagerID = A.AssetManagerID where BAD.AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY A.AgreementID, Period, SC.CurrencyID
    --SELECT AgreementID, AgreementVersionID, AgreementCalculationSettingID, Period, PeriodTypeID, SC.CurrencyID, SUM(Retro), SUM(RetroFinal) FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) GROUP BY AgreementID, AgreementVersionID, AgreementCalculationSettingID, Period, PeriodTypeID, SC.CurrencyID ORDER BY AgreementID, Period, SC.CurrencyID
    SELECT * FROM Balances_AUMRetroTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period
    SELECT * FROM Balances_DailyAccrualDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID  where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Date, SC.CurrencyID
    SELECT * FROM Balances_DailyAccrualTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Date


    SELECT R.ReinvestmentReference as Reference
          , Cast(CONVERT(DECIMAL(10,4),SUM(ISNULL(RD.Reinvestment, 0))) as nvarchar) Amount
      FROM Reinvestments R
          INNER JOIN Reinvestments_Details RD
                      ON RD.ReinvestmentID = R.ReinvestmentID
          INNER JOIN Agreements A
                      ON A.AgreementID = R.AgreementID
                      AND A.AgreementCode = @AgrCode
    GROUP BY R.ReinvestmentReference 
    ORDER BY R.ReinvestmentReference

    ---Payments
    SELECT P.InvoiceNumber
	    , Cast(CONVERT(DECIMAL(10,4),SUM(ISNULL(PD.Retrocession, 0))) as nvarchar) Amount
    FROM Payments P
    INNER JOIN Payments_Details PD
					    ON PD.PaymentID = P.PaymentID
    INNER JOIN Agreements A
                      ON A.AgreementID = P.AgreementID
                      AND A.AgreementCode = @AgrCode
    GROUP BY P.InvoiceNumber
    ORDER BY P.InvoiceNumber
    

ROLLBACK transaction exectest

-- Test case 10066 Last day of period calculation
 
BEGIN TRANSACTION test
		
	EXEC [dbo].[Computation_Disable]
	
	select 'Computation_BalancesPendingThresholdAUM', * from dbo.Computation_BalancesPendingThresholdAUM

-- Remove shareclasses SC05 and SC20 from the fund pool FP1
            DELETE FPSC
              FROM Agreements_CalculationVersions ACV
                INNER JOIN Agreements_CalculationSettings ACS
                        ON ACV.AgreementCalculationVersionID = ACS.AgreementCalculationVersionID
                INNER JOIN Agreements_ThresholdSettings ATS
                        ON ATS.AgreementThresholdSettingID = ACS.AgreementThresholdSettingID
                INNER JOIN FundPools_ShareClasses FPSC
                        ON FPSC.FundPoolID = ATS.FundPoolID
                       AND FPSC.ShareClassID = 100020
                       AND FPSC.DateStart = ACV.DateStart
                       AND ISNULL(FPSC.DateEnd, '19000101') = ISNULL(ACV.DateEnd, '19000101') 
             WHERE ACV.VersionName = 'TA10024-V1'

             DELETE FPSC
              FROM Agreements_CalculationVersions ACV
                INNER JOIN Agreements_CalculationSettings ACS
                        ON ACV.AgreementCalculationVersionID = ACS.AgreementCalculationVersionID
                INNER JOIN Agreements_ThresholdSettings ATS
                        ON ATS.AgreementThresholdSettingID = ACS.AgreementThresholdSettingID
                INNER JOIN FundPools_ShareClasses FPSC
                        ON FPSC.FundPoolID = ATS.FundPoolID
                       AND FPSC.ShareClassID = 100005
                       AND FPSC.DateStart = ACV.DateStart
                       AND ISNULL(FPSC.DateEnd, '19000101') = ISNULL(ACV.DateEnd, '19000101') 
             WHERE ACV.VersionName = 'TA10024-V1'
             
             EXEC dbo.SysteminformationComputationQueue_GetTable_All
             
             select 'Computation_BalancesPendingThresholdAUM', * from dbo.Computation_BalancesPendingThresholdAUM
             
ROLLBACK TRANSACTION test

SELECT * 
FROM Agreements_CalculationVersions ACV
                INNER JOIN Agreements_CalculationSettings ACS
                        ON ACV.AgreementCalculationVersionID = ACS.AgreementCalculationVersionID
                INNER JOIN Agreements_ThresholdSettings ATS
                        ON ATS.AgreementThresholdSettingID = ACS.AgreementThresholdSettingID      
                         where acv.AgreementID = 100028

SELECT dbo.DT2LM('2009-01-01')

SELECT FPSC.* , ACV.AgreementID  , ACV.DateStart, ACV.DateEnd         
FROM Agreements_CalculationVersions ACV
                INNER JOIN Agreements_CalculationSettings ACS
                        ON ACV.AgreementCalculationVersionID = ACS.AgreementCalculationVersionID
                INNER JOIN Agreements_ThresholdSettings ATS
                        ON ATS.AgreementThresholdSettingID = ACS.AgreementThresholdSettingID                
                INNER JOIN FundPools_ShareClasses FPSC
                        ON FPSC.FundPoolID = ATS.FundPoolID
                       AND FPSC.ShareClassID = 100020
                       AND FPSC.DateStart = ACV.DateStart
                       AND ISNULL(FPSC.DateEnd, '19000101') = ISNULL(ACV.DateEnd, '19000101') 
             WHERE ACV.AgreementID = 100044 -- ACV.VersionName = 'TA10024-V1'
                       
SELECT FPSC.* , ACV.AgreementID , ACV.DateStart, ACV.DateEnd         
FROM Agreements_CalculationVersions ACV
                INNER JOIN Agreements_CalculationSettings ACS
                        ON ACV.AgreementCalculationVersionID = ACS.AgreementCalculationVersionID
                INNER JOIN Agreements_ThresholdSettings ATS
                        ON ATS.AgreementThresholdSettingID = ACS.AgreementThresholdSettingID
                INNER JOIN FundPools_ShareClasses FPSC
                        ON FPSC.FundPoolID = ATS.FundPoolID
                       AND FPSC.ShareClassID = 100005
                       AND FPSC.DateStart = ACV.DateStart
                       AND ISNULL(FPSC.DateEnd, '19000101') = ISNULL(ACV.DateEnd, '19000101') 
             WHERE ACV.VersionName = 'TA10024-V1'
             
SELECT *
FROM Agreements_CalculationVersions ACV
                INNER JOIN Agreements_CalculationSettings ACS
                        ON ACV.AgreementCalculationVersionID = ACS.AgreementCalculationVersionID
                INNER JOIN Agreements_ThresholdSettings ATS
                        ON ATS.AgreementThresholdSettingID = ACS.AgreementThresholdSettingID
                        
                INNER JOIN Agreements_HOPMembers AHOP on AHOP.AgreementThresholdSettingID = ATS.AgreementThresholdSettingID
where ACV.AgreementID = 100028




