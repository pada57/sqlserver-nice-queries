-- Parameters
select * from Computation_Parameters

-- Generate data
EXEC ___Data_Generate_TestData001 @TestEnv=1
EXEC UT_DeleteAllAgreements

-- Clean 
EXEC Computation_CleanQueues

-- Trigger computation manually
SELECT * from Calculation_Basis
select * from NumberDaysYear
UPDATE Agreements_CalculationVersionGroups SET  DateStart = '2011-05-01', DateEnd = '2011-09-30' WHERE AgreementCalculationVersionGroupID = 429
UPDATE Agreements_CalculationVersionGroups SET  DateStart = '2011-10-01' WHERE AgreementCalculationVersionGroupID = 430
UPDATE Agreements_CalculationVersions SET  DateStart = '2011-05-01', DateEnd = '2011-09-30' WHERE AgreementCalculationVersionID = 429
UPDATE Agreements_CalculationVersions SET  DateStart = '2011-10-01' WHERE AgreementCalculationVersionID = 430
UPDATE Agreements_CalculationVersions SET ThresholdCalculationBasisID = NULL, RebateCalculationBasisID = NULL, NumberDaysYearID = NULL WHERE AgreementCalculationVersionID = 429
UPDATE Agreements_CalculationVersions SET ThresholdCalculationBasisID = NULL, RebateCalculationBasisID = NULL, NumberDaysYearID = NULL WHERE AgreementCalculationVersionID = 430
UPDATE Agreements_CalculationSettings SET ThresholdCalculationBasisID = 4, RebateCalculationBasisID = 4, NumberDaysYearID = 4 WHERE AgreementCalculationVersionID = 429
UPDATE Agreements_CalculationSettings SET ThresholdCalculationBasisID = 2, RebateCalculationBasisID = 2, NumberDaysYearID = 2 WHERE AgreementCalculationVersionID = 430

BEGIN tran
UPDATE Agreements_CalculationSettings SET ThresholdCalculationBasisID = 4, RebateCalculationBasisID = 4, NumberDaysYearID = 4 WHERE AgreementCalculationVersionID = 429
SELECT * FROM [Computation_DeletePayments]
SELECT * FROM [Computation_Payments]
SELECT * FROM [Computation_DeleteReinvestments]
SELECT * FROM [Computation_Reinvestments]
ROLLBACK tran

-- Execute computation step by step
SELECT * FROM sys.triggers where name LIKE '%StartComputation'
EXEC [dbo].[Computation_Enable]
EXEC [dbo].[Computation_Disable]
exec amsfw_StartJob 'RCP_Compute'

-- Execute next step
BEGIN TRANSACTION 
BEGIN TRY
    DECLARE @AgrCode NVARCHAR(20) = 'UKT01'
    select * from dbo.Computation_Reinvestments
	EXEC dbo.Computation_Step @Debug = 1

SELECT 'Payments', * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Payments_Details', * FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Payments_BalancesAUMTotals', * FROM Payments_BalancesAUMTotals where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Payments_CalculationVersions', * FROM Payments_CalculationVersions where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Payments_CalculationSettings', * FROM Payments_CalculationSettings where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))


SELECT 'Reinvestments', * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Reinvestments_Details', * FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY Period
SELECT 'Reinvestments_Details', Period, SUM(Reinvestment) FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) GROUP BY Period
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

	select  * FROM AuditTrails_ComputationSteps where LogDate > DATEADD(MINUTE, -1, GETDATE())		
	SELECT * FROM System_Alerts
	EXEC dbo.SysteminformationComputationQueue_GetTable_All
	ROLLBACK TRANSACTION 
	--COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	
	select * from AuditTrails_Monitoring order BY 1 desc
	SELECT * FROM System_Alerts
	ROLLBACK TRANSACTION 
END CATCH

-- Alerts & Audit
SELECT * FROM System_Alerts
select  * FROM AuditTrails_ComputationSteps order BY AuditTrails_ComputationStepID desc
SELECT * FROM sys.dm_tran_active_transactions
select @@trancount
EXEC Computation_SanityCheck

-- Queues
EXEC dbo.SysteminformationComputationQueue_GetTable_All

select * from dbo.Computation_StocksPendingNbShares
select * from dbo.Computation_BalancesPendingThresholdAUM
select * from dbo.Computation_BalancesPendingDailyAUM
select * from dbo.Computation_BalancesPendingCalculationAUM
select * from dbo.Computation_BalancesPendingDailyTotalAUM
select * from dbo.Computation_BalancesPendingCommissions
select * from dbo.Computation_BalancesPendingDailyCommissions
select * from dbo.Computation_BalancesUpdateReinvestments		
select * from dbo.Computation_BalancesUpdateReinvestmentsSimple	
select * from dbo.Computation_Payments
select * from dbo.Computation_Reinvestments
select * from dbo.Computation_PaymentsDelta
select * from dbo.Computation_ReinvestmentsDelta
select * from dbo.Computation_OtherCommissions
select * from dbo.Computation_LifeInsuranceTransactions
select * from dbo.Computation_DeletePayments
select * from dbo.Computation_DeleteReinvestments
select * from dbo.Computation_BalancesPendingCommissionsLeverage
select * from dbo.Computation_AssetManagersCommissions
select * from dbo.Computation_PaymentsTransactions
select * from dbo.Computation_ThresholdLeverage
select * FROM WKT_PaymentsPendingApprovalChecks
select * FROM WKT_ReinvestmentsPendingApprovalChecks


-- Balance tables
DECLARE @AgrCode NVARCHAR(20) = 'UKT01'
SELECT * FROM Balances_AUMRetroDetails BAD where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period
SELECT * FROM Balances_AUMRetroTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period
SELECT * FROM Balances_DailyAccrualDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID  where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Date, SC.CurrencyID
SELECT * FROM Balances_DailyAccrualTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Date

-- Agreements Data related
DECLARE @AgrCode NVARCHAR(20) = 'UKT01'
SELECT * FROM Agreements where AgreementCode = @AgrCode
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_AUMRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
UNION
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_DailyAccrualDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT acv.AgreementCalculationVersionID, acv.VersionName, acv.DateStart, acv.DateEnd, acv.TradeBasisID, acv.ThresholdCurrencyID, acv.AccrualMethodID
	,'Version' as C, acv.ThresholdCalculationBasisID, acv.RebateCalculationBasisID, acv.NumberDaysYearID
	,'Settings' as C2, acs.ThresholdCalculationBasisID, acs.RebateCalculationBasisID, acs.NumberDaysYearID
	,'FourE ACV' as C3, feACV.ThresholdCalculationBasisID, feACV.RebateCalculationBasisID, feACV.NumberDaysYearID
	, ARS.FundPoolID, ARS.ScaleID, ARS.UseDefaultScale, ARS.UseDefaultHOP 
	, ats.FundPoolID, ats.UseCalculationHOP, ats.UseCalculationFundPool
	, ahop.AgentID, AG.AgentCode, acvg.VersionName
FROM Agreements_CalculationVersionGroups acvg 
	INNER JOIN Agreements_CalculationVersions acv on acv.AgreementCalculationVersionGroupID = acvg.AgreementCalculationVersionGroupID
	LEFT JOIN Agreements_CalculationSettings acs ON  acs.AgreementCalculationVersionID = acv.AgreementCalculationVersionID
	LEFT JOIN Agreements_RebateSettings ARS ON acs.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	LEFT JOIN Agreements_ThresholdSettings ats ON ats.AgreementThresholdSettingID = acs.AgreementThresholdSettingID
	LEFT JOIN Agreements_HOPMembers ahop ON ahop.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	LEFT JOIN Agents AG ON AG.AgentID = ahop.AgentID
	LEFT JOIN FourE_Agreements_CalculationVersions feACV ON feACV.AgreementCalculationVersionID = acv.AgreementCalculationVersionID
	where acv.AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)


SELECT * FROM Agreements_PaymentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT * FROM Agreements_ReinvestmentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 

SELECT * FROM Scales where ScaleID = 100458
SELECT * FROM Scales_Bands where ScaleID = 100458
SELECT * FROM Agents_Portfolios where AgentID = 100002
SELECT * FROM Stocks where PortfolioID IN (100001, 100002, 100003)
SELECT * FROM FundPools where FundPoolID = 721
SELECT * FROM Agents where AgentID = 1269

-- Payments Data
DECLARE @AgrCode NVARCHAR(20)
SET @AgrCode = 'UKT01'
SELECT 'Payments', * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Payments_Details', * FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Payments_BalancesAUMTotals', * FROM Payments_BalancesAUMTotals where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Payments_CalculationVersions', * FROM Payments_CalculationVersions where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 'Payments_CalculationSettings', * FROM Payments_CalculationSettings where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))

-- Reinvestment tables
SELECT 'Reinvestments', * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 'Reinvestments_Details', * FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY Period
SELECT 'Reinvestments_Details', Period, SUM(Reinvestment) FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) GROUP BY Period
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

