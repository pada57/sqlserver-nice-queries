--====== Generate data ======--
EXEC ___Data_Generate_TestData001 @TestEnv=1
EXEC UT_DeleteAllAgreements

--====== Clean before test ======--
truncate table TestCases_FailureOutput
EXEC Computation_CleanQueues
UPDATE TestCases SET HasRun = NULL, Succeeded = NULL

exec dbo.UT_ExecuteTestCase 1, 0, 0 -- Create agreements
exec dbo.UT_ExecuteTestCase 2, 0, 0 -- Tiered
exec dbo.UT_ExecuteTestCase 3, 0, 0 -- Flat
exec dbo.UT_ExecuteTestCase 4, 0, 0 -- Mixed
exec dbo.UT_ExecuteTestCase 5, 0, 0 -- Mixed with product scope = false
exec dbo.UT_ExecuteTestCase 6, 0, 0 -- Mixed with retain rate = true / use retro rate in
exec dbo.UT_ExecuteTestCase 7, 0, 0 -- TC2 close payments
exec dbo.UT_ExecuteTestCase 8, 0, 0 -- TC3 close payments

SELECT * FROM Balances_IN
SELECT * FROM FeeDistribution_IN
SELECT * FROM Balances_FeeRetroDetails
SELECT * FROM Agreements_CalculationSettings
SELECT * FROM UT_Agreements_CalculationSettings


--====== Execute test  ======-- (second param to regenerate test data and third to execute related test before)
begin
    declare @i int = 1
        , @maxtcid int = 45
    
    --EXEC ___Data_Generate_TestData001 @TestEnv=1
    --EXEC UT_DeleteAllAgreements
    
    --truncate table TestCases_FailureOutput
    --EXEC Computation_CleanQueues
    --UPDATE TestCases SET HasRun = NULL, Succeeded = NULL
    
    while (@i < @maxtcid)
    begin    
        exec dbo.UT_ExecuteTestCase @i, 0, 0
        set @i += 1
    end
end

select  * FROM AuditTrails_ComputationSteps where LogDate > DATEADD(MINUTE, -1, GETDATE())	
SELECT * FROM TestCases_FailureOutput

--====== Test output ======--
SELECT * FROM TestCases_FailureOutput
---- Force test verification
EXEC [UT_VerifyResultForTestCase] @TestCaseID=36
---- Sanity Check
DECLARE @NbErrors INT
EXEC UT_RunSanityChecks @TestCaseID=1, @NbError = @NbErrors
EXEC Computation_SanityCheck
-- Check test
SELECT * FROM TestCases_FailureOutput 

--====== Execute computation step by step  ======--
Exec Computation_Start @Debug = 1
SELECT * FROM sys.triggers where name LIKE '%StartComputation'
EXEC [dbo].[Computation_Enable]
EXEC Computation_CleanQueues
EXEC [dbo].[Computation_Disable]

BEGIN transaction
    EXEC UT_CreateAgreementsFromTestCase @TestCaseID = 1

BEGIN transaction
    EXEC UT_ExecuteExtendedScenarioByTestCase @TestCaseID = 5

BEGIN transaction
    EXEC UT_ExecuteTestCase 45, 0 , 0
    
COMMIT TRANSACTION
ROLLBACK TRANSACTION

SELECT @@trancount
select * FROM Balances_FeeRetroDetails

BEGIN TRANSACTION test
BEGIN TRY
    EXEC [dbo].[Computation_Disable]
	EXEC dbo.Computation_Step @Debug = 1
	EXEC dbo.SysteminformationComputationQueue_GetTable_All
	
	select  * FROM AuditTrails_ComputationSteps where LogDate > DATEADD(MINUTE, -1, GETDATE())	
	--SELECT * FROM System_Alerts	
	
	ROLLBACK TRANSACTION 
	--COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	print 'error'
	select * from AuditTrails_Monitoring order BY 1 desc
	SELECT * FROM System_Alerts
	ROLLBACK TRANSACTION 
END CATCH

SELECT * FROM SubServiceTypes

--======= Performance test ======--
EXEC [dbo].[Computation_Disable]
EXEC UT_Agreements_DeleteByTestCase @TestCaseID = 201
EXEC UT_CreateAgreementsFromTestCase @TestCaseID = 1, @GridSync = 0
EXEC [UT_CloneAgreementsFromTestCase] @TestCaseID = 201, @NumberOfClone = 3000
-- Clean cache
DBCC DROPCLEANBUFFERS
DBCC FREEPROCCACHE
SELECT GridID FROM Grids WHERE ShortName = 'G3'

BEGIN
    --DECLARE @GridId INT
    --SELECT @GridId = GridID FROM Grids WHERE ShortName = 'G3'    
    EXEC UT_DeleteAllAgreements
    EXEC [dbo].[Computation_Disable]
    EXEC Computation_CleanQueues
    EXEC UT_CreateAgreementsFromTestCase @TestCaseID = 2, @GridSync = 0
    EXEC [UT_CloneAgreementsFromTestCase] @TestCaseID = 1, @NumberOfClone = 3000
       
    DECLARE @GridId INT
    SET @GridId = 100001
    EXEC Grids_Synchronize @GridID = @GridId, @FourE_AgreementCalculationVersionGroupID = NULL
END

-- Test Grid sync
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION test
        
        EXEC [dbo].[Computation_Disable]
        EXEC UT_ExecuteExtendedScenarioByTestCase @TestCaseID = 3
        EXEC Grids_Synchronize @GridID = 100001, @FourE_AgreementCalculationVersionGroupID = NULL
        EXEC dbo.Computation_Step @Debug = 1

        SELECT * FROM Grids
        SELECT * FROM Grids_CalculationVersions
        SELECT * FROM Grids_CalculationSettings
        SELECT * FROM FourE_Grids_CalculationSettings
        SELECT * FROM Agreements
        SELECT * FROM Agreements_CalculationVersionGroups
        SELECT * FROM Agreements_CalculationVersions
        SELECT * FROM Agreements_CalculationSettings
        SELECT * FROM Agreements_RebateSettings
        SELECT * FROM Agreements_ThresholdSettings
        SELECT * FROM Agreements_DefaultRebateHOPMembers
        SELECT * FROM Agreements_HOPMembers
        SELECT * FROM Scales
        SELECT * FROM Scales_Bands
        SELECT * FROM FourE_Agreements_CalculationVersions        
        SELECT * FROM FOurE_Agreements_CalculationSettings
        
        SELECT * FROM Payments
        SELECT * FROM Payments_Details
        SELECT * FROM Payments_BalancesAUMDetails

        SELECT * FROM Balances_IN
        SELECT * FROM Balances_AUMRetroDetails
        SELECT * FROM Balances_DailyAccrualDetails
        SELECT * FROM Balances_FeeRetroDetails
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION test
    END CATCH
    --ROLLBACK TRANSACTION test
END


BEGIN TRANSACTION test

    EXEC UT_CreateAgreementsFromTestCase @TestCaseID = 3
    --EXEC Grids_Synchronize @GridID = 100003, @FourE_AgreementCalculationVersionGroupID = NULL
    
    SELECT 'After checks'
    select 'Grids', * from Grids
    select 'FourE_Grids', * from FourE_Grids
    select 'Grids_CalculationVersions', * from Grids_CalculationVersions
    select 'FourE_Grids_CalculationVersions', * from FourE_Grids_CalculationVersions
    select 'Grids_CalculationSettings', * from Grids_CalculationSettings
    select 'FourE_Grids_CalculationSettings', * from FourE_Grids_CalculationSettings	
    select 'Agreements', * FROM Agreements
    select 'FourE_Agreements', * from FourE_Agreements	
    select 'Agreements_CalculationVersionGroups', * FROM Agreements_CalculationVersionGroups
    select 'Agreements_CalculationVersions', * FROM Agreements_CalculationVersions
    select 'FourE_Agreements_CalculationVersions', * FROM FourE_Agreements_CalculationVersions    
    select 'Scales', * FROM Scales where name like '%Grid%' 
    select 'FourE_Scales', * FROM FourE_Scales where name like '%Grid%' order BY FourE_ScaleID desc
    select 'Scales_Bands', * from Scales_Bands order BY ScaleBandID desc
    select 'FourE_Scales_Bands', * from FourE_Scales_Bands order BY FourEScaleBandID desc    
    select 'Agreements_DefaultRebateHOPMembers', * FROM Agreements_DefaultRebateHOPMembers  
    select 'FourE_Agreements_DefaultRebateHOPMembers', * FROM FourE_Agreements_DefaultRebateHOPMembers  
    select 'Agreements_CalculationSettings', * FROM Agreements_CalculationSettings
    select 'Agreements_ThresholdSettings', * FROM Agreements_ThresholdSettings
    select 'Agreements_RebateSettings', * FROM Agreements_RebateSettings 
    select 'Agreements_HOPMembers', * FROM Agreements_HOPMembers
        
COMMIT TRANSACTION test


--=======  Alerts & Queues & Audits =======--
SELECT * FROM System_Alerts
SELECT * FROM sys.dm_tran_active_transactions
select @@trancount

-- Queues
EXEC dbo.SysteminformationComputationQueue_GetTable_All

select * from dbo.Balances_FeeRetroDetails
select * FROM dbo.Computation_AUMFees
select * from dbo.Computation_CommissionsFees
select * from dbo.Computation_StocksPendingNbShares
select * from dbo.Computation_BalancesPendingThresholdAUM
select * from dbo.Computation_BalancesPendingDailyAUM
SELECT * FROM dbo.Computation_ThresholdLeverage
select * from dbo.Computation_BalancesPendingCalculationAUM
select * from dbo.Computation_BalancesPendingDailyTotalAUM
select * from dbo.Computation_BalancesPendingCommissions
select * from dbo.Computation_BalancesPendingDailyCommissions
select * from dbo.Computation_BalancesPendingCommissionsLeverage
select * from dbo.Computation_BalancesUpdateReinvestments		
select * from dbo.Computation_BalancesUpdateReinvestmentsSimple	
select * from dbo.Computation_Payments
select * from dbo.Computation_Reinvestments
select * from dbo.Computation_PaymentsDelta order BY Date
select * from dbo.Computation_ReinvestmentsDelta
select * from dbo.Computation_ReinvestmentsFinal
select * from dbo.Computation_OtherCommissions
select * from dbo.Computation_LifeInsuranceTransactions
select * from dbo.Computation_DeletePayments
select * from dbo.Computation_DeleteReinvestments
select * from dbo.Computation_AssetManagersCommissions
select * from dbo.Computation_PaymentsTransactions
select * from dbo.Computation_ThresholdLeverage
select * FROM WKT_PaymentsPendingApprovalChecks
select * FROM WKT_ReinvestmentsPendingApprovalChecks

-- Audit
select  * FROM AuditTrails_ComputationSteps order BY AuditTrails_ComputationStepID asc

--=======      =======--
--======= DATA =======--
--=======      =======--
-- Balance tables
DECLARE @AgrCode NVARCHAR(20)= 'TA1'
SELECT SC.CurrencyID, BAD.* FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period, SC.CurrencyID
--SELECT SC.CurrencyID, A.SplitPercentage, RetroFinal = IsNull(Retro, 0) - Round(IsNull(Retro, 0) * A.SplitPercentage / 100, AM.NumberOfDecimals), BAD.* FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID INNER JOIN Agreements A ON A.AgreementID = BAD.AgreementID INNER JOIN AssetManagers AM ON AM.AssetManagerID = A.AssetManagerID where BAD.AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY A.AgreementID, Period, SC.CurrencyID
--SELECT AgreementID, AgreementVersionID, AgreementCalculationSettingID, Period, PeriodTypeID, SC.CurrencyID, SUM(Retro), SUM(RetroFinal) FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) GROUP BY AgreementID, AgreementVersionID, AgreementCalculationSettingID, Period, PeriodTypeID, SC.CurrencyID ORDER BY AgreementID, Period, SC.CurrencyID
SELECT * FROM Balances_AUMRetroTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period
SELECT * FROM Balances_DailyAccrualDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID  where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, BAD.PortfolioID, BAD.ShareClassID, Date 
--SELECT AgreementID, AgreementCalculationVersionID, AgreementCalculationSettingID, SC.CurrencyID, SUM(BAD.Retrocession) - SUM(BAD.RetrocessionFinal)FROM Balances_DailyAccrualDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) GROUP BY AgreementID, AgreementCalculationVersionID, AgreementCalculationSettingID, SC.CurrencyID ORDER BY AgreementID, SC.CurrencyID
--SELECT *FROM Balances_DailyAccrualTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Date
SELECT DISTINCT AgreementID, ShareClassCurrencyID, ThresholdCurrencyID, AccrualCurrencyID FROM Balances_DailyAccrualTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) --ORDER BY AgreementID, Date

SELECT * FROM Balances_AUMRetroDetails
SELECT * FROM Balances_DailyAccrualDetails

-- Reinvestment tables
SELECT 'Reinvestments', * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Reinvestments_Details', * FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY Period
SELECT 'Reinvestments_BalancesAUMDetails', SC.CurrencyID, RBAD.* FROM Reinvestments_BalancesAUMDetails RBAD INNER JOIN Reinvestments_Details RD ON RD.ReinvestmentDetailID = RBAD.ReinvestmentDetailID INNER JOIN ShareClasses SC ON SC.ShareClassID = RBAD.ShareClassID where RBAD.ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)) ORDER BY RD.ReinvestmentID, RD.Period, SC.CurrencyID
SELECT 'Reinvestments_BalancesAUMTotals', RBAT.* FROM Reinvestments_BalancesAUMTotals RBAT INNER JOIN Reinvestments_Details RD ON RD.ReinvestmentDetailID = RBAT.ReinvestmentDetailID where RBAT.ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)) ORDER BY RD.ReinvestmentID, RD.Period
SELECT 'Reinvestments_Stocks', * FROM Reinvestments_Stocks where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_NAVs', * FROM Reinvestments_NAVs where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_CurrenciesExchangeRates', * FROM Reinvestments_CurrenciesExchangeRates where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_CalculationVersionGroups', * FROM Reinvestments_CalculationVersionGroups where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_CalculationVersions', * FROM Reinvestments_CalculationVersions where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_CalculationSettings', * FROM Reinvestments_CalculationSettings where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_RebateSettings', * FROM Reinvestments_RebateSettings where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_ThresholdSettings', * FROM Reinvestments_ThresholdSettings where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_Scales', * FROM Reinvestments_Scales where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_Scales_Bands', * FROM Reinvestments_Scales_Bands where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_AgentsHierarchy', * FROM Reinvestments_AgentsHierarchy where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_HOPMembers', * FROM Reinvestments_HOPMembers where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Reinvestments_ReinvestmentsAttributes', * FROM Reinvestments_ReinvestmentsAttributes where ReinvestmentID in (SELECT Reinvestments.ReinvestmentID FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))

SELECT 'Check stock difference', RS.Date, ISNULL(RS.NbOfShares,-1) as ReinvestmentNbOfShares, ISNULL(S.NbOfShares, -1) as StockShares
FROM Reinvestments_Stocks RS
FULL JOIN Stocks S
	ON S.PortfolioID = RS.PortfolioID
		AND S.ShareClassID = RS.ShareClassID
		AND S.TradeBasisID =  RS.TradeBasisID
		AND S.Date = RS.Date		
where RS.ReinvestmentDetailID 
	IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
AND ISNULL(RS.NbOfShares,-1) <> ISNULL(S.NbOfShares, -1)
/*
SELECT 'Reinvestments' as Reinvestments, R.*, 'Reinvestments_Details' as Reinvestments_Details, RD.*, 'Reinvestments_BalancesAUMDetails' as Reinvestments_BalancesAUMDetails, RBAD.* 
FROM Reinvestments R
LEFT JOIN Reinvestments_Details RD ON R.ReinvestmentID = RD.ReinvestmentID
LEFT JOIN Reinvestments_BalancesAUMDetails RBAD ON RD.ReinvestmentDetailID = RBAD.ReinvestmentDetailID
where R.AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
*/

-- Payments Data
DECLARE @AgrCode NVARCHAR(20)= 'TA15'
select * from dbo.Computation_DeletePayments
SELECT 'Payments', * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY StartPeriod
--SELECT 'Payments_Details', * FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Payments_Details', * FROM Payments_Details where PaymentID IN (select PaymentID FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
--SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where PaymentID IN (select PaymentID FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)))
--SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where PaymentID IN (select PaymentID FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)))
--and AgreementVersionID = 100111 AND PortfolioID = 100005 AND ShareClassID = 100007 AND Date = '20100101'
SELECT 'Payments_BalancesAUMTotals', * FROM Payments_BalancesAUMTotals where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
 
-- Agreements Data related
DECLARE @AgrCode NVARCHAR(20)
SET @AgrCode = 'UKT0002'
SELECT * FROM Agreements where AgreementCode = @AgrCode
SELECT acv.VersionName, acv.DateStart, acv.DateEnd, acv.TradeBasisID, acv.ThresholdCurrencyID
	, acv.AccrualMethodID
	--, acv.ThresholdCalculationBasisID, acv.RebateCalculationBasisID
	, acs.ThresholdCalculationBasisID, acs.RebateCalculationBasisID
	, ARS.FundPoolID, ARS.ScaleID, ARS.UseDefaultScale, ARS.UseDefaultHOP 
	, ats.FundPoolID, ats.UseCalculationHOP, ats.UseCalculationFundPool
	, ahop.AgentID, AG.AgentCode
	, ADRHOP.AgentID, API.PaymentCurrencyID as DefaultPaymentCurrency
	, APS.DefaultPaymentInstructionID
FROM    
    Agreements_CalculationSettings acs 
	INNER JOIN Agreements_CalculationVersions acv on acs.AgreementCalculationVersionID = acv.AgreementCalculationVersionID
	INNER JOIN Agreements A ON acv.AgreementID = A.AgreementID
	INNER JOIN Agreements_CalculationVersionGroups acvg ON acv.AgreementCalculationVersionGroupID = acvg.AgreementCalculationVersionGroupID
	INNER JOIN Agreements_RebateSettings ARS ON acs.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	INNER JOIN Agreements_ThresholdSettings ats ON ats.AgreementThresholdSettingID = acs.AgreementThresholdSettingID
	LEFT JOIN Agreements_DefaultRebateHOPMembers ADRHOP ON ADRHOP.AgreementCalculationVersionGroupID =acvg.AgreementCalculationVersionGroupID
	LEFT JOIN Agreements_HOPMembers ahop ON ahop.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	LEFT JOIN Agents AG ON AG.AgentID = ahop.AgentID
	LEFT JOIN Agreements_PaymentInstructions API ON API.AgreementPaymentInstructionID = a.DefaultPaymentInstructionID
	LEFT JOIN Agreements_PaymentSettings APS ON APS.AgreementID = A.AgreementID
	where A.AgreementCode = @AgrCode
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_AUMRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
UNION
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_DailyAccrualDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT * FROM Agreements_PaymentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT * FROM Agreements_ReinvestmentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 

/*
SELECT * FROM Scales where ScaleID = 100202
SELECT * FROM Scales_Bands where ScaleID = 100202
SELECT * FROM Agents_Portfolios where AgentID = 100001
SELECT * FROM FundPools_ShareClasses WHERE FundPoolID = 100001
SELECT * FROM Stocks where PortfolioID IN (100001, 100002, 100003)
*/

--- Check amounts
SELECT TCR.Reference ExpectedReference
                  , TCR.Amount ExpectedAmount
                  , Result.Amount CalculatedAmount
                  , CASE WHEN ISNULL(TCR.Amount, 0) = ISNULL(Result.Amount, 0) THEN 1 ELSE 0 END IsOk
                  , CASE WHEN ISNULL(TCR.Amount, 0) <> ISNULL(Result.Amount, 0) THEN 1 ELSE 0 END IsNotOk                  
                  , 1 as ResultType
              FROM TestCases_ReinvestmentResults TCR
                  FULL JOIN (
                                    SELECT R.ReinvestmentReference as Reference
                                          , SUM(ISNULL(RD.Reinvestment, 0)) Amount
                                      FROM Reinvestments R
                                          INNER JOIN Reinvestments_Details RD
                                                      ON RD.ReinvestmentID = R.ReinvestmentID
                                          INNER JOIN Agreements A
                                                      ON A.AgreementID = R.AgreementID
                                    GROUP BY R.ReinvestmentReference
                                    ) Result
                              ON Result.Reference = TCR.Reference
            WHERE TCR.TestCaseID = 23

SELECT * FROM TestCases_ReinvestmentResults  where TestCaseID = 23
       
-- Current output

--- Reinvestments
DECLARE @AgrCode NVARCHAR(20)= 'TA15'
SELECT R.ReinvestmentReference as Reference
      , Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(RD.Reinvestment, 0))) as nvarchar) Amount
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
	, Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(PD.Retrocession, 0))) as nvarchar) Amount
FROM Payments P
INNER JOIN Payments_Details PD
					ON PD.PaymentID = P.PaymentID
INNER JOIN Agreements A
                  ON A.AgreementID = P.AgreementID
                  AND A.AgreementCode = @AgrCode
GROUP BY P.InvoiceNumber
ORDER BY P.InvoiceNumber
   
    
-- Compare totals & details 


DECLARE @AgrCode NVARCHAR(20)= 'TA14'

select * from Balances_DailyAccrualDetails where AgreementID IN (SELECT AgreementID from Agreements where AgreementCode = @AgrCode)
SELECT pt.* FROM Payments_Details PD INNER join Payments_BalancesAUMDetails PT on PD.PaymentDetailID = PT.PaymentDetailID where PD.AgreementID IN (SELECT AgreementID from Agreements where AgreementCode = @AgrCode)

select 'Totals', * from (
select AgreementID, Date, R=SUM(RetrocessionFinal) from Balances_DailyAccrualTotals where AgreementID IN (SELECT AgreementID from Agreements where AgreementCode = @AgrCode)
group by AgreementID, Date --order by Date
) A
--select SUM(RetrocessionFinal) from Balances_DailyAccrualTotals where AgreementID = 100024
full join (
select PD.AgreementID, Date, R=SUM(Delta_Retro) from Payments P
inner join Payments_Details PD on P.PaymentID = PD.PaymentID
inner join Payments_BalancesAUMTotals PT on PD.PaymentDetailID = PT.PaymentDetailID
where PD.AgreementID IN (SELECT P.AgreementID from Agreements where AgreementCode = @AgrCode)
group by PD.AgreementID, Date --order by Date
) B on A.Date = B.Date
    AND A.AgreementID = B.AgreementID
where A.R <> B.R
order by A.AgreementID, A.Date


select 'Details', * from (
select AgreementID, Date, R=SUM(RetrocessionFinal) from Balances_DailyAccrualDetails where AgreementID IN (SELECT AgreementID from Agreements where AgreementCode = @AgrCode)
group by AgreementID, Date --order by Date
) A
full join (
select PD.AgreementID, Date, R=SUM(PT.Delta_Retro) from Payments P
inner join Payments_Details PD on P.PaymentID = PD.PaymentID
inner join Payments_BalancesAUMDetails PT on PD.PaymentDetailID = PT.PaymentDetailID
where PD.AgreementID IN (SELECT P.AgreementID from Agreements where AgreementCode = @AgrCode)
group by PD.AgreementID, Date --order by Date
) B on A.Date = B.Date
    AND A.AgreementID = B.AgreementID
where A.R <> B.R
order by A.AgreementID, A.Date


