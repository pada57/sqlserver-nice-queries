--====== Generate data ======--
EXEC ___Data_Generate_TestData001 @TestEnv=1
EXEC UT_DeleteAllAgreements

--====== Clean before test ======--
truncate table TestCases_FailureOutput
truncate table System_Alerts
EXEC Computation_CleanQueues
UPDATE TestCases SET HasRun = NULL, Succeeded = NULL

select * from TestCases
select * from TransferAgencySystems

exec dbo.UT_ExecuteTestCase 1, 0, 0 
exec dbo.UT_ExecuteTestCase 2, 0, 0 
exec dbo.UT_ExecuteTestCase 3, 0, 0 
exec dbo.UT_ExecuteTestCase 4, 0, 0 
exec dbo.UT_ExecuteTestCase 5, 0, 0 


SELECT AgentID, NB = COUNT(*) FROM Agents_Portfolios GROUP BY AgentID ORDER BY NB DESC
; WITH TopAgents AS (
    select TOP 10 agentID from (
    SELECT AgentID, NB = COUNT(*) FROM Agents_Portfolios GROUP BY AgentID 
    ) A
    ORDER BY A.NB DESC
)
SELECT AgentID_Parent from Agents_Agents where AgentID IN (SELECT AgentID FROM TopAgents) OR AgentID_Parent IN (SELECT AgentID FROM TopAgents)

SELECT AgentID, NB = COUNT(*) FROM Agents_Portfolios WHERE AgentID = 23473 GROUP BY AgentID 
SELECT * from Agents_Agents where AgentID IN (23473) OR AgentID_Parent IN (23473)

-- Grid nb calc sets
SELECT *
from(
SELECT G.GridID, G.Name, count(gcs.GridCalculationSettingID) as NbSets
FROM Grids G
INNER JOIN dbo.Grids_CalculationVersions GCV
    ON G.GridID = GCV.GridID
INNER JOIN dbo.Grids_CalculationSettings GCS
    ON GCV.GridCalculationVersionID = GCS.GridCalculationVersionID
GROUP BY G.GridID, G.Name
) as T
ORDER BY T.NbSets desc

return

--====== Execute test  ======-- (second param to regenerate test data and third to execute related test before)
begin
    declare @currentid int = 1
        , @FromId int = 1
        , @maxtcid int = 10059
        
    DECLARE testcases CURSOR FOR
        SELECT [TestCaseID] FROM TestCases WHERE TestCaseID < @maxtcid AND TestCaseID >= @FromId ORDER BY TestCaseID
   
    OPEN testcases

    FETCH NEXT FROM testcases 
        INTO @currentid

    WHILE @@FETCH_STATUS = 0
    begin    
        exec dbo.UT_ExecuteTestCase @currentid, 0, 0
        
        FETCH NEXT FROM testcases 
            INTO @currentid
    end
    
    CLOSE testcases;
    DEALLOCATE testcases;
end

return
--====== Test output ======--
SELECT * FROM TestCases_FailureOutput
exec dbo.UT_ExecuteTestCase 1, 0, 0
select  * FROM AuditTrails_ComputationSteps where LogDate > DATEADD(MINUTE, -1, GETDATE())	
---- Force test verification
EXEC [UT_VerifyResultForTestCase] @TestCaseID=10059
---- Sanity Check
DECLARE @NbErrors INT
EXEC UT_RunSanityChecks @TestCaseID=2, @NbError = @NbErrors
EXEC Computation_SanityCheck

--====== Execute computation step by step  ======--
Exec Computation_Start @Debug = 1
SELECT * FROM sys.triggers where name LIKE '%StartComputation'
EXEC sys.sp_MSforeachtable 'ENABLE TRIGGER ALL ON ?'
SELECT * FROM sys.triggers where is_disabled = 1
EXEC [dbo].[Computation_Enable]

EXEC Computation_CleanQueues
EXEC [dbo].[Computation_Disable]
SELECT @@trancount

TRUNCATE TABLE AuditTrails_ComputationSteps
BEGIN transaction
    EXEC UT_ExecuteTestCase 10067, 0 , 0
    SELECT * from dbo.TestCases_FailureOutput    
    select * FROM dbo.Payments order by InvoiceNumber     

COMMIT TRANSACTION
ROLLBACK TRANSACTION

select * FROM dbo.CurrenciesExchangeRates where Date > '20100101'
SELECT * from dbo.FeeDistribution_IN

BEGIN transaction
    EXEC UT_CreateAgreementsFromTestCase @TestCaseID = 10059

BEGIN transaction
    EXEC UT_ExecuteExtendedScenarioByTestCase @TestCaseID = 10067       
rollback
    
SELECT * FROM TestCases_FailureOutput where FailureReason <> 'Computed successfully'

EXEC Computation_CleanQueues
EXEC [dbo].[Computation_Disable]
EXEC [dbo].[Computation_Enable]

SELECT @@trancount

update dbo.Computation_1Threshold SET Status = 0

BEGIN TRANSACTION
BEGIN TRY
    EXEC [dbo].Computation_Disable
	EXEC dbo.Computation_Step @Debug = 1
	EXEC dbo.SysteminformationComputationQueue_GetTable_All
	
	SELECT * FROM dbo.FeeDistribution_IN order BY EffectiveDate 
	SELECT * from dbo.Fees where FeeTypeID = 1
	SELECT * FROM dbo.System_Alerts
	
	select dbo.LP2DT(24112, 1)
	
	select * FROM dbo.Computation_1HierarchyAgentPortfolios
	SELECT * FROM dbo.Computation_1Threshold
	SELECT * FROM dbo.Computation_Payments
	SELECT * FROM dbo.Computation_PaymentsDelta
	select * FROM dbo.Computation_AUMFees where AgreementID = 100027
	select * FROM dbo.Payments where AgreementID = 100081
	
	SELECT * from dbo.WKT_HierarchyAgentPortfolios where ThresholdSettingID = 100126
	
	SELECT * FROM dbo.Agreements 
	select * FROM dbo.Balances_AUMRetroDetails where AgreementID = 100044 AND Period = 24111 
	SELECT * FROM dbo.Payments where AgreementID = 100031
	select dbo.LP2DT(8038, 2)
	select dbo.LP2DT(24114, 1)
	select * FROM dbo.SubServiceTypes
	select * from dbo.Portfolios
	select * FROM dbo.FeeDistribution_IN where SubServiceID = 2 AND PortfolioID in(100004, 100005, 100006) AND RebateDate BETWEEN '20080101' and '20081231' 
	select * from dbo.Balances_FeeRetroDetails where AgreementID = 100077 ORDER BY AgreementCalculationSettingID, Period, PortfolioID
	SELECT * from dbo.Balances_FeeRetroDetails where RowID = 36
	SELECT * FROM dbo.Balances_IN where PortfolioID IN (100001, 100002) AND RetroDate BETWEEN '20110101' AND '20110430'
	
	
declare @paymentid INT = 101288
select * from Payments where PaymentID = @paymentid
select * from Payments_Details where PaymentID = @paymentid
select * from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) 
	
	select dbo.ConvertPeriod(4020, 3, 1)
	SELECT * FROM dbo.Payments where AgreementID = 100032
	DECLARE @paymentid int = 100429
	select * from Payments where PaymentID = @paymentid
    select * from Payments_Details where PaymentID = @paymentid
    select * from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) 

		SELECT * FROM dbo.WKT_HierarchyAgentPortfolios
		
	select  * FROM AuditTrails_ComputationSteps where LogDate > DATEADD(MINUTE, -4, GETDATE()) ORDER BY AuditTrails_ComputationStepID DESC	
	select * from ComputationSteps	
	
	ROLLBACK TRANSACTION 
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	print 'error'
	select * from AuditTrails_Monitoring order BY 1 desc
	SELECT * FROM System_Alerts
	ROLLBACK TRANSACTION 
END CATCH

BEGIN TRAN
    SELECT * FROM dbo.Scales where ScaleID = 100259
	SELECT * FROM dbo.Scales_Bands where ScaleID = 100259
	SELECT * FROM dbo.FourE_Scales where ScaleID = 100259
	SELECT * FROM dbo.FourE_Scales_Bands where FourE_ScaleID = 260
    exec [dbo].[GridsCalculationSettings_ScreenAccept] @FourE_GridCalculationVersionID = 100015, @Language = 'en-GB', @UserName = 'admin'
    SELECT * FROM dbo.Scales where ScaleID = 100259
	SELECT * FROM dbo.Scales_Bands where ScaleID = 100259
	SELECT * FROM dbo.FourE_Scales where ScaleID = 100259
	SELECT * FROM dbo.FourE_Scales_Bands where FourE_ScaleID = 260
	
BEGIN TRAN
    --select * FROM dbo.Grids_CalculationVersions
    --select * FROM dbo.Grids_CalculationSettings
    --select * FROM dbo.Agreements_CalculationVersionGroups
    --select * FROM dbo.Agreements_CalculationVersions
    --select * FROM dbo.Agreements_CalculationSettings
    --SELECT * FROM dbo.Attributes_ToCompare
    SELECT * FROM dbo.Attributes_ToCompareValues
    --SELECT * FROM dbo.FourE_Attributes_ToCompare
    --SELECT * FROM dbo.FourE_Attributes_ToCompareValues
    EXEC Grids_Synchronize @GridID = 100001, @FourE_AgreementCalculationVersionGroupID = NULL
    --SELECT * FROM dbo.Attributes_ToCompare
    SELECT * FROM dbo.Attributes_ToCompareValues
    --SELECT * FROM dbo.FourE_Attributes_ToCompare
    --SELECT * FROM dbo.FourE_Attributes_ToCompareValues
    --select * FROM dbo.Agreements_CalculationVersionGroups
    --select * FROM dbo.Agreements_CalculationVersions
    --select * FROM dbo.Agreements_CalculationSettings
rollback tran
commit tran



truncate table Computation_PaymentsVAT
insert Computation_PaymentsVAT
select * from Computation_PaymentsVATCopy

select * from VATProfiles
update Agreements set VATProfileID = 1 where AgreementCode = 'AI01'

--SELECT * FROM Agreements_HOPMembers
--select * FROM Agents_Portfolios where AgentID = 24469
--SELECT * FROM Portfolios WHERE PortfolioID = 192990
--SELECT * FROM Attributes_Values WHERE EntityRowID = 192990

--select 0 as 'Computation_1Threshold', * FROM dbo.Computation_1Threshold
--select * INTO dbo.Computation_1ThresholdDaily FROM dbo.Computation_1Threshold 
--TRUNCATE TABLE dbo.Computation_1Threshold
--INSERT INTO dbo.Computation_1Threshold 
--SELECT TOP 100 * FROM dbo.Computation_1ThresholdDaily WHERE PortfolioID = 192990
--select * from Attributes_Attributes
--select * FROM Attributes_ToCompare
--select * FROM Attributes_ToCompareValues

--delete FROM Attributes_ToCompareValues WHERE AttributeToCompareID NOT IN (13,14)
--delete FROM Attributes_ToCompare WHERE AttributeToCompareID NOT IN (13,14)

--select * FROM Balances_FeeRetroDetails
--truncate table AuditTrails_ComputationSteps
--SELECT TOP 1000 *  FROM Computation_1ThresholdCopy
--TRUNCATE TABLE Computation_1Threshold
--INSERT Computation_1Threshold
--SELECT TOP 300000 * FROM Computation_1ThresholdCopy

--INSERT Computation_1Threshold 
--SELECT AgreementID, PortfolioID, ShareClassID, AgreementVersionID, StockType, DateStart, DateEnd, Status, 0, FundPoolID, FeeModelID, SubServiceID    
--FROM Computation_1ThresholdCopy
--EXCEPT 
--SELECT AgreementID, PortfolioID, ShareClassID, AgreementVersionID, StockType, DateStart, DateEnd, Status, 0, FundPoolID, FeeModelID, SubServiceID
--FROM Computation_1Threshold

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

-- sync all grids
begin
    declare @gridid int = 1
        
    DECLARE grids CURSOR FOR
        SELECT GridID FROM Grids
   
    OPEN grids

    FETCH NEXT FROM grids 
        INTO @gridid

    WHILE @@FETCH_STATUS = 0
    begin    
        
        PRINT CONVERT(NVARCHAR(30), GETDATE(), 121) + ', Start exec Grids_Synchronize @GridID=' + CONVERT(NVARCHAR(10), @gridid)
        
        exec dbo.Grids_Synchronize @GridID = @gridid, @FourE_AgreementCalculationVersionGroupID = NULL
        
        FETCH NEXT FROM grids 
            INTO @gridid
            
        PRINT CONVERT(NVARCHAR(30), GETDATE(), 121) + ', END exec Grids_Synchronize @GridID=' + CONVERT(NVARCHAR(10), @gridid)
    end
    
    CLOSE grids;
    DEALLOCATE grids;
end

--=======  Alerts & Queues & Audits =======--
SELECT * FROM System_Alerts
SELECT * FROM sys.dm_tran_active_transactions
select @@trancount

-- Queues
EXEC dbo.SysteminformationComputationQueue_GetTable_All

select 0 as 'Computation_HierarchyAgentPortfolios',* FROM dbo.Computation_HierarchyAgentPortfolios
select 0 as 'Computation_0Stocks',* FROM dbo.Computation_0Stocks
select 0 as 'Computation_1Threshold', * FROM dbo.Computation_1Threshold
select 0 as 'Computation_AUMDaily', * FROM dbo.Computation_AUMDaily
select 0 as 'Computation_AUMDailyTotal', * FROM dbo.Computation_AUMDailyTotal
select 0 as 'Computation_AUMFees', * FROM dbo.Computation_AUMFees
select 0 as 'Computation_AUMLeverage', * FROM dbo.Computation_AUMLeverage
select 0 as 'Computation_AUMPeriodTotal', * from dbo.Computation_AUMPeriodTotal
select 0 as 'Computation_CommissionsDaily', * from dbo.Computation_CommissionsDaily
select 0 as 'Computation_CommissionsDailyTotal', * from dbo.Computation_CommissionsDailyTotal
select 0 as 'Computation_CommissionsLeverage', * from dbo.Computation_CommissionsLeverage
select 0 as 'Computation_CommissionsPeriod', * from dbo.Computation_CommissionsPeriod
select 0 as 'Computation_CommissionsFees', * from dbo.Computation_CommissionsFees
select 0 as 'Computation_CommissionsSettings', * from dbo.Computation_CommissionsSettings
select 0 as 'Computation_CommissionsSplitReinvestment', * from dbo.Computation_CommissionsSplitReinvestment
select 0 as 'Computation_PaymentsDelete', * from dbo.Computation_PaymentsDelete
select 0 as 'Computation_ReinvestmentsDelete', * from dbo.Computation_ReinvestmentsDelete
select 0 as 'Computation_Payments', * from dbo.Computation_Payments where AgreementID = 100127
select 0 as 'Computation_Reinvestments', * from dbo.Computation_Reinvestments
select 0 as 'Computation_PaymentsDelta', * from dbo.Computation_PaymentsDelta order BY Date
select 0 as 'Computation_ReinvestmentsDelta', * from dbo.Computation_ReinvestmentsDelta
select 0 as 'Computation_ReinvestmentsFinal', * from dbo.Computation_ReinvestmentsFinal
select 0 as 'Computation_PaymentsTransactions', * from dbo.Computation_PaymentsTransactions
select 0 as 'Computation_PaymentsVAT', * from dbo.Computation_PaymentsVAT

select 0 as 'Computation_PaymentsDelta', * from dbo.Computation_PaymentsDelta WHERE AgreementID = 100048 AND Date BETWEEN '2010-06-01 00:00:00' AND '2010-06-15 00:00:00'
select 0 as 'Computation_CommissionsDaily', * from dbo.Computation_CommissionsDaily WHERE AgreementID = 100048 AND Date BETWEEN '2010-06-01 00:00:00' AND '2010-06-15 00:00:00'        
select 0 as 'Computation_AUMFees', * FROM dbo.Computation_AUMFees where AgreementID = 100025

--=======      =======--
--======= DATA =======--
--=======      =======--

--== Audit & Alerts
select * from AuditTrails_ObjectTypes order by ObjectTypeID
select *  from System_Alerts
select * from AuditTrails order by LogDate desc

--== Test Data
select TestCaseID, TestCaseCode, TestCaseName FROM TestCases
SELECT * FROM TestCases_PaymentResults


--== Portfolio/Product(shareclass) data
select * from Agents
select * from Investors
SELECT * FROM Stocks
select * from Portfolios
select * from ShareClasses
select * from Agents_Agents 
select * from Agents_Portfolios where PortfolioID = 100005
select * from FourE_Agents_Portfolios where PortfolioID = 100005  and AgentID = 100002 order by FourE_AgentPortfolioID desc
select * FROM FundPools
select * FROM FundPools_ShareClasses
select * FROM FundPools_ShareClasses where FundPoolID = 100001
select * from ShareClasses where ShareClassID = 100013
select * from System_Alerts
select * from Investors_Portfolios
select * from FourE_Investors_Portfolios where FourE_ActionID is not null

--== Fee Data
select * from FeeDistribution_IN
select * from Balances_IN
select * from SubServiceTypes

--== Invoices Data
select * from Invoices
select * from Invoices_BalancesDetails
select * from Payments_Status
--select * from Invoices_Status

select * from AuditTrails_OperationTypes
select * from AuditTrails order by 2 desc

select * from Payments_Status

update Invoices set StatusID = 6

delete Balances_IN

update Invoices_BalancesDetails set ProductID = -97 where BalanceINID = 2
update Balances_IN set ProductID = -97 where BalanceINID = 2

select ServiceID, ServiceCode + ' - ' + ISNULL(ServiceName, ServiceCode) as ServiceLabel 
from ServiceTypes

select * from Agreements where AgreementDirectionID = 1
select * from Payments where AgreementID = 100057
select * from Payments_Details where AgreementID = 100057
SELECT * from Balances_IN where AgreementID = 100057
select * from Invoices_BalancesDetails where BalanceINID = 2

delete Invoices_BalancesDetails
delete Invoices
delete Balances_IN 
delete Balances_IN where BalanceINID = 6
--update Balances_IN set RetroAmountIN = OriginalRetroAmountIN - 1
--update Balances_IN set ReadyToInvoiceAmountIN = 0, NotInvoicedAmountIN = RetroAmountIN

-- Insert payments and details
SET IDENTITY_INSERT [dbo].[Payments] ON
INSERT INTO [dbo].[Payments] ([PaymentID], [Payment_CycleID], [AgreementID], [StartPeriod], [IsACorrection], [StatusID], [InvoiceNumber], [DetailLevelID], [UserName], [Closed], [PaymentInstructionID], [RebateContactAgentID], [RebateContactInvestorID], [RebateContactAgreementID], [RebateDeliveryModeID], [CurrencyID], [PI_ExportID], [PI_BankName], [PI_SWIFTCode], [PI_IBAN], [PI_BeneficiaryName], [PI_BankCountry], [PI_CorrespondentBankName], [PI_CorrespondentSWIFTCode], [PI_PaymentNarrative], [PI_CorrespondentPaymentNarrative], [RCD_ExportID], [RCD_Code], [RCD_Name], [RCD_FaxNumber], [RCD_Email], [RCD_AdressDetail], [RCD_AdressCity], [RCD_AdressPostalCode], [RCD_AdressCountry], [RCD_Language], [ValueDate], [Amount], [ExportPaymentReference], [HoldbackPayment], [ExportPaymentDate], [ValidatingUsername], [AuthorisingUsername], [LastAmendingUsername], [DocumentID], [PaidStatus], [PaymentExecutionDate], [ValidatedOn], [InvoiceDate], [IsManuallyCreated], [CreationDate], [InvoiceMatchCalculation]) 
VALUES (100137, 1, 100057, 24120, 0, 11, N'AM1-SJ_IN-2010-01-EUR', 1, N'Payments_IN stored procedure', 0, NULL, NULL, NULL, 100022, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'2014-03-04 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, N'2014-02-28 00:00:00', 0)
SET IDENTITY_INSERT [dbo].[Payments] OFF

SET IDENTITY_INSERT [dbo].[Payments_Details] ON
INSERT INTO [dbo].[Payments_Details] ([PaymentDetailID], [PaymentID], [AgreementID], [Period], [PeriodTypeID], [Closed], [Retrocession], [VAT], [CommOtherCommissions]) VALUES (100197, 100137, 100057, 24120, 1, 0, CAST(214.5200 AS Money), CAST(0.0000 AS Money), CAST(0.0000 AS Money))
SET IDENTITY_INSERT [dbo].[Payments_Details] OFF

SET IDENTITY_INSERT [dbo].[Balances_IN] ON
INSERT INTO [dbo].[Balances_IN] ([BalanceINID], [AgreementID], [PortfolioID], [TransferAgencySystemID], [ProductID], [ApplicationDate], [SubServiceID], [PeriodTypeID], [AUMCurrencyID], [RetroCurrencyID], [Period], [Closed], [PaymentID], [PaymentDetailID], [AgreementReference], [AgreementAssetManagerReference], [PortfolioExternalReference], [PortfolioAssetManagerReference], [PortfolioSourceSystem], [ProductExternalReference], [SubServiceCode], [PeriodTypeName], [BusinessPeriodName], [StartPeriod], [InvoiceNumber], [AUM], [Quantity], [RetroRateIN], [RetroAmountIN], [OriginalRetroAmountIN], [VATRetroAmount], [VATRate], [VATReferenceID], [_Insert_ImportID], [_Insert_ProcessRunID], [_Insert_ProcessRunStepID], [_InsertDate], [_Update_ImportID], [_Update_ProcessRunID], [_Update_ProcessRunStepID], [_UpdateDate]) VALUES (1, 100057, 100001, 1, 100001, N'2010-01-14', 3, 1, 1, 1, 24120, 0, 100137, 100197, N'SJ_IN', N'AM1', N'PS1', N'AM1', N'RCP', N'SC1', N'ADHSUB', N'Month', N'January-2010', 24120, N'AM1-SJ_IN-2010-01-EUR', CAST(987.6600 AS Money), CAST(19100.000000000 AS Decimal(29, 9)), CAST(1.020000 AS Decimal(10, 6)), CAST(10.0100 AS Money), CAST(11.0100 AS Money), CAST(0.0000 AS Money), CAST(0.0000 AS Decimal(9, 4)), 1, 1, 32, 31, N'2014-02-28 21:11:26', NULL, NULL, NULL, NULL)
INSERT INTO [dbo].[Balances_IN] ([BalanceINID], [AgreementID], [PortfolioID], [TransferAgencySystemID], [ProductID], [ApplicationDate], [SubServiceID], [PeriodTypeID], [AUMCurrencyID], [RetroCurrencyID], [Period], [Closed], [PaymentID], [PaymentDetailID], [AgreementReference], [AgreementAssetManagerReference], [PortfolioExternalReference], [PortfolioAssetManagerReference], [PortfolioSourceSystem], [ProductExternalReference], [SubServiceCode], [PeriodTypeName], [BusinessPeriodName], [StartPeriod], [InvoiceNumber], [AUM], [Quantity], [RetroRateIN], [RetroAmountIN], [OriginalRetroAmountIN], [VATRetroAmount], [VATRate], [VATReferenceID], [_Insert_ImportID], [_Insert_ProcessRunID], [_Insert_ProcessRunStepID], [_InsertDate], [_Update_ImportID], [_Update_ProcessRunID], [_Update_ProcessRunStepID], [_UpdateDate]) VALUES (2, 100057, 100001, 1, 100001, N'2010-01-15', 3, 1, 1, 1, 24120, 0, 100137, 100197, N'SJ_IN', N'AM1', N'PS1', N'AM1', N'RCP', N'SC1', N'ADHSUB', N'Month', N'January-2010', 24120, N'AM1-SJ_IN-2010-01-EUR', CAST(1987.6600 AS Money), CAST(119100.000000000 AS Decimal(29, 9)), CAST(53.010000 AS Decimal(10, 6)), CAST(44.0100 AS Money), CAST(51.0100 AS Money), CAST(0.0000 AS Money), CAST(0.0000 AS Decimal(9, 4)), 1, 2, 32, 31, N'2014-02-28 21:11:26', NULL, NULL, NULL, NULL)
INSERT INTO [dbo].[Balances_IN] ([BalanceINID], [AgreementID], [PortfolioID], [TransferAgencySystemID], [ProductID], [ApplicationDate], [SubServiceID], [PeriodTypeID], [AUMCurrencyID], [RetroCurrencyID], [Period], [Closed], [PaymentID], [PaymentDetailID], [AgreementReference], [AgreementAssetManagerReference], [PortfolioExternalReference], [PortfolioAssetManagerReference], [PortfolioSourceSystem], [ProductExternalReference], [SubServiceCode], [PeriodTypeName], [BusinessPeriodName], [StartPeriod], [InvoiceNumber], [AUM], [Quantity], [RetroRateIN], [RetroAmountIN], [OriginalRetroAmountIN], [VATRetroAmount], [VATRate], [VATReferenceID], [_Insert_ImportID], [_Insert_ProcessRunID], [_Insert_ProcessRunStepID], [_InsertDate], [_Update_ImportID], [_Update_ProcessRunID], [_Update_ProcessRunStepID], [_UpdateDate]) VALUES (3, 100057, 100004, 1, 100001, N'2010-01-16', 3, 1, 1, 1, 24120, 0, 100137, 100197, N'SJ_IN', N'AM1', N'PS2', N'AM1', N'RCP', N'SC1', N'ADHSUB', N'Month', N'January-2010', 24120, N'AM1-SJ_IN-2010-01-EUR', CAST(4000.0100 AS Money), CAST(254000.000000000 AS Decimal(29, 9)), CAST(45.050000 AS Decimal(10, 6)), CAST(77.0600 AS Money), CAST(78.0600 AS Money), CAST(0.0000 AS Money), CAST(0.0000 AS Decimal(9, 4)), 1, 3, 32, 31, N'2014-02-28 21:11:26', NULL, NULL, NULL, NULL)
INSERT INTO [dbo].[Balances_IN] ([BalanceINID], [AgreementID], [PortfolioID], [TransferAgencySystemID], [ProductID], [ApplicationDate], [SubServiceID], [PeriodTypeID], [AUMCurrencyID], [RetroCurrencyID], [Period], [Closed], [PaymentID], [PaymentDetailID], [AgreementReference], [AgreementAssetManagerReference], [PortfolioExternalReference], [PortfolioAssetManagerReference], [PortfolioSourceSystem], [ProductExternalReference], [SubServiceCode], [PeriodTypeName], [BusinessPeriodName], [StartPeriod], [InvoiceNumber], [AUM], [Quantity], [RetroRateIN], [RetroAmountIN], [OriginalRetroAmountIN], [VATRetroAmount], [VATRate], [VATReferenceID], [_Insert_ImportID], [_Insert_ProcessRunID], [_Insert_ProcessRunStepID], [_InsertDate], [_Update_ImportID], [_Update_ProcessRunID], [_Update_ProcessRunStepID], [_UpdateDate]) VALUES (4, 100057, 100004, 1, 100003, N'2010-01-17', 3, 1, 1, 1, 24120, 0, 100137, 100197, N'SJ_IN', N'AM1', N'PS2', N'AM1', N'RCP', N'SC3', N'ADHSUB', N'Month', N'January-2010', 24120, N'AM1-SJ_IN-2010-01-EUR', CAST(5000.0100 AS Money), CAST(355000.000000000 AS Decimal(29, 9)), CAST(48.090000 AS Decimal(10, 6)), CAST(78.4400 AS Money), CAST(79.4400 AS Money), CAST(0.0000 AS Money), CAST(0.0000 AS Decimal(9, 4)), 1, 4, 32, 31, N'2014-02-28 21:11:26', NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Balances_IN] OFF

-- Insert invoice and details
INSERT dbo.Invoices (PaymentID, InvoiceReference, InvoiceNumber, StatusID, CreationDate, Closed, IsManuallyCreated) values
(100137, 'AM1-SJ_IN-2010-01-EUR-1', 1, 11, GETDATE()-2, 0, 0)
INSERT dbo.Invoices (PaymentID, InvoiceReference, InvoiceNumber, StatusID, CreationDate, Closed, IsManuallyCreated) values
(100137, 'AM1-SJ_IN-2010-01-EUR-2', 2, 11, GETDATE()-5, 0, 0)
DECLARE @InvoiceID INT = (SELECT InvoiceID FROM Invoices WHERE InvoiceReference = 'AM1-SJ_IN-2010-01-EUR-1')
INSERT dbo.Invoices_BalancesDetails ( InvoiceID, [BalanceINID],[AgreementID],[PortfolioID],[TransferAgencySystemID],[ProductID],[ApplicationDate],[SubServiceID],[PeriodTypeID],[AUMCurrencyID],[RetroCurrencyID],[Period],[Closed],[PaymentID],[PaymentDetailID],[AgreementReference],[AgreementAssetManagerReference],[PortfolioExternalReference],[PortfolioAssetManagerReference],[PortfolioSourceSystem],[ProductExternalReference],[SubServiceCode],[PeriodTypeName],[BusinessPeriodName],[StartPeriod],[InvoiceNumber],[AUM],[Quantity],[RetroRateIN],[RetroAmountIN],[OriginalRetroAmountIN],[VATRetroAmount],[VATRate],[VATReferenceID])
SELECT @InvoiceID, [BalanceINID],[AgreementID],[PortfolioID],[TransferAgencySystemID],[ProductID],[ApplicationDate],[SubServiceID],[PeriodTypeID],[AUMCurrencyID],[RetroCurrencyID],[Period],[Closed],[PaymentID],[PaymentDetailID],[AgreementReference],[AgreementAssetManagerReference],[PortfolioExternalReference],[PortfolioAssetManagerReference],[PortfolioSourceSystem],[ProductExternalReference],[SubServiceCode],[PeriodTypeName],[BusinessPeriodName],[StartPeriod],[InvoiceNumber],[AUM],[Quantity],[RetroRateIN],[RetroAmountIN],[OriginalRetroAmountIN],[VATRetroAmount],[VATRate],[VATReferenceID]
FROM Balances_IN
WHERE BalanceINID IN (1, 2)
SET @InvoiceID = (SELECT InvoiceID FROM Invoices WHERE InvoiceReference = 'AM1-SJ_IN-2010-01-EUR-2')
INSERT dbo.Invoices_BalancesDetails ( InvoiceID, [BalanceINID],[AgreementID],[PortfolioID],[TransferAgencySystemID],[ProductID],[ApplicationDate],[SubServiceID],[PeriodTypeID],[AUMCurrencyID],[RetroCurrencyID],[Period],[Closed],[PaymentID],[PaymentDetailID],[AgreementReference],[AgreementAssetManagerReference],[PortfolioExternalReference],[PortfolioAssetManagerReference],[PortfolioSourceSystem],[ProductExternalReference],[SubServiceCode],[PeriodTypeName],[BusinessPeriodName],[StartPeriod],[InvoiceNumber],[AUM],[Quantity],[RetroRateIN],[RetroAmountIN],[OriginalRetroAmountIN],[VATRetroAmount],[VATRate],[VATReferenceID])
SELECT @InvoiceID, [BalanceINID],[AgreementID],[PortfolioID],[TransferAgencySystemID],[ProductID],[ApplicationDate],[SubServiceID],[PeriodTypeID],[AUMCurrencyID],[RetroCurrencyID],[Period],[Closed],[PaymentID],[PaymentDetailID],[AgreementReference],[AgreementAssetManagerReference],[PortfolioExternalReference],[PortfolioAssetManagerReference],[PortfolioSourceSystem],[ProductExternalReference],[SubServiceCode],[PeriodTypeName],[BusinessPeriodName],[StartPeriod],[InvoiceNumber],[AUM],[Quantity],[RetroRateIN],[RetroAmountIN],[OriginalRetroAmountIN],[VATRetroAmount],[VATRate],[VATReferenceID]
FROM Balances_IN
WHERE BalanceINID IN (3)
-- Update amounts
UPDATE dbo.Invoices_BalancesDetails
SET InvoiceAmount = OriginalRetroAmountIN - 4    
    , RetroAmountIN = OriginalRetroAmountIN - 1

delete FourE_ShareClasses where ShareClassID < 0
delete Invoices_BalancesDetails
delete Invoices
delete ShareClasses where ShareClassID < 0

--== Attribute Data
select * FROM Attributes_Attributes
select * FROM Attributes_ConfiguredAttributes
select * FROM Attributes_Operators
select * FROM Attributes_OperatorsTypes
select * FROM Attributes_Types
select * FROM Attributes_ReferenceTypes
select * FROM Attributes_Functions
select COUNT(*) FROM Attributes_Values
select * FROM Attributes_Values
select * FROM Attributes_ToCompare 
select * FROM Attributes_ToCompareValues 
select * FROM FourE_Attributes_ToCompare
select * FROM FourE_Attributes_ToCompareValues

select * FROM FourE_Attributes_ToCompare where FourE_ReferenceID = 100011
select * FROM FourE_Attributes_ToCompareValues where FourE_AttributeToCompareID in (select FourE_AttributeToCompareID FROM FourE_Attributes_ToCompare where FourE_ReferenceID = 100011)
select * FROM Attributes_ToCompare where ReferenceID = 100001
select * FROM Attributes_ToCompareValues where AttributeToCompareID in (select AttributeToCompareID FROM Attributes_ToCompare where ReferenceID = 100001)
delete FourE_Attributes_ToCompareValues where FourE_AttributeToCompareID in (select FourE_AttributeToCompareID from  FourE_Attributes_ToCompare where FourE_ReferenceID = 100011)
delete FourE_Attributes_ToCompare where FourE_ReferenceID = 100011
delete Attributes_ToCompareValues where AttributeToCompareID in (select AttributeToCompareID FROM Attributes_ToCompare where ReferenceID = 100001)
delete Attributes_ToCompare where ReferenceID = 100001

SELECT * FROM dbo.FourE_Agreements_CalculationSettings where FourE_AgreementCalculationSettingID = 100111
select * FROM Attributes_ToCompare where ReferenceID = 100102
select * FROM Attributes_ToCompareValues where AttributeToCompareID IN (select AttributeToCompareID FROM Attributes_ToCompare where ReferenceID = 100102)
select * FROM FourE_Attributes_ToCompare where FourE_ReferenceID = 100111
select * FROM FourE_Attributes_ToCompareValues where FourE_AttributeToCompareID IN (select FourE_AttributeToCompareID FROM FourE_Attributes_ToCompare where FourE_ReferenceID = 100111)


delete FourE_Attributes_ToCompareValues where FourE_AttributeToCompareID IN (select FourE_AttributeToCompareID FROM FourE_Attributes_ToCompare where FourE_ReferenceID = 100111)
DELETE FourE_Attributes_ToCompare where FourE_ReferenceID = 100111
UPDATE FourE_Attributes_ToCompareValues SET FourE_ActionID = 1 WHERE FourE_AttributeToCompareValueID = 342

--== Agreements Data related
select * FROM Agreements
select * FROM Agreements_CalculationVersions
select * FROM Agreements_CalculationVersionGroups
select * FROM Agreements_CalculationSettings
select * FROM Agreements_RebateSettings
select * FROM Agreements_ThresholdSettings
select * FROM Agreements_DefaultRebateHOPMembers
select * FROM Agreements_HOPMembers
select * FROM Scales where ScaleID = 100251
select * FROM Scales_Bands where ScaleID = 100251

select * from Agreements_CalculationSettings
select * from FourE_Agreements_CalculationSettings

select * FROM FourE_Agreements_CalculationVersions
select * from FourE_Scales where FourE_ScaleID = 2808
select * from FourE_Scales_Bands where FourE_ScaleID = 2808
SELECT * FROM dbo.SubServiceTypes

DECLARE @AgrCode NVARCHAR(20) = 'YTD04'
SELECT * FROM Agreements where AgreementCode = @AgrCode
SELECT  acs.AgreementCalculationSettingID, acs.Description, acv.AgreementCalculationVersionID, acv.VersionName, acv.DateStart, acv.DateEnd, acv.TradeBasisID, acv.ThresholdCurrencyID
	, acv.AccrualMethodID
	--, acv.ThresholdCalculationBasisID, acv.RebateCalculationBasisID
	, acs.ThresholdCalculationBasisID, acs.RebateCalculationBasisID
	, acs.ThresholdFeeBasisID, acs.RebateFeeBasisID
	, FM.Name, acs.SubServiceID, SST.SubServiceCode, acs.DefineProductScope
	, ARS.FundPoolID, ARS.ScaleID, ARS.UseDefaultScale, ARS.UseDefaultHOP 
	, ats.FundPoolID, ats.UseCalculationHOP, ats.UseCalculationFundPool
	, ahop.AgentID, AG.AgentCode
	, ADRHOP.AgentID, API.PaymentCurrencyID as DefaultPaymentCurrency
	, APS.DefaultPaymentInstructionID
FROM Agreements A     
	INNER JOIN Agreements_CalculationVersions acv on a.AgreementID = acv.AgreementID	
	INNER JOIN Agreements_CalculationSettings acs on acs.AgreementCalculationVersionID = acv.AgreementCalculationVersionID
	INNER JOIN Agreements_CalculationVersionGroups acvg ON acv.AgreementCalculationVersionGroupID = acvg.AgreementCalculationVersionGroupID
	INNER JOIN Agreements_RebateSettings ARS ON acs.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	INNER JOIN Agreements_ThresholdSettings ats ON ats.AgreementThresholdSettingID = acs.AgreementThresholdSettingID
	LEFT JOIN Agreements_DefaultRebateHOPMembers ADRHOP ON ADRHOP.AgreementCalculationVersionGroupID =acvg.AgreementCalculationVersionGroupID
	LEFT JOIN Agreements_HOPMembers ahop ON ahop.AgreementRebateSettingID = ARS.AgreementRebateSettingID
	LEFT JOIN Agents AG ON AG.AgentID = ahop.AgentID
	LEFT JOIN Agreements_PaymentInstructions API ON API.AgreementPaymentInstructionID = a.DefaultPaymentInstructionID
	LEFT JOIN Agreements_PaymentSettings APS ON APS.AgreementID = A.AgreementID
	left join SubServiceTypes SST ON ACS.SubServiceID = SST.SubServiceID
	left join FeeModels FM ON FM.FeeModelID = ACS.FeeModelID
where A.AgreementCode = @AgrCode
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_AUMRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
UNION
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_DailyAccrualDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT * FROM Agreements_PaymentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT * FROM Agreements_ReinvestmentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Balances_FeeRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 

SELECT * FROM Scales where ScaleID = 100203
SELECT * FROM Scales_Bands where ScaleID = 100203
SELECT * FROM Agents_Portfolios where AgentID = 100001
SELECT * FROM FundPools_ShareClasses WHERE FundPoolID = 100003
SELECT * FROM Stocks where PortfolioID IN (100001, 100002, 100003)

--> Dump agreement
DECLARE @AgreementID INT = 100076
SELECT 0 as 'Agreements', * FROM dbo.Agreements where AgreementID = @AgreementID
SELECT 0 as 'Agreements_CalculationVersions', ACV.* FROM dbo.Agreements_CalculationVersions ACV INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Agreements_CalculationVersionGroups', ACVG.* FROM dbo.Agreements_CalculationVersionGroups ACVG INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACV.AgreementCalculationVersionGroupID = ACVG.AgreementCalculationVersionGroupID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Agreements_CalculationSettings', ACS.* FROM dbo.Agreements_CalculationSettings ACS INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Agreements_HOPMembers Rebate', AHOP.* FROM dbo.Agreements_HOPMembers AHOP INNER JOIN dbo.Agreements_CalculationSettings ACS ON AHOP.AgreementRebateSettingID = ACS.AgreementRebateSettingID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Agreements_HOPMembers Threshold', AHOP.* FROM dbo.Agreements_HOPMembers AHOP INNER JOIN dbo.Agreements_CalculationSettings ACS ON AHOP.AgreementThresholdSettingID = ACS.AgreementRebateSettingID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Agreements_RebateSettings', ARS.* FROM dbo.Agreements_RebateSettings ARS INNER JOIN dbo.Agreements_CalculationSettings ACS ON ARS.AgreementRebateSettingID = ACS.AgreementRebateSettingID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Agreements_ThresholdSettings', ATS.* FROM dbo.Agreements_ThresholdSettings ATS INNER JOIN dbo.Agreements_CalculationSettings ACS ON ATS.AgreementThresholdSettingID = ACS.AgreementThresholdSettingID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Agreements_PaymentInstructions', API.* FROM dbo.Agreements_PaymentInstructions API INNER JOIN dbo.Agreements A ON A.AgreementID = API.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Scales', S.* FROM dbo.Scales S INNER JOIN dbo.Agreements_RebateSettings ARS ON S.ScaleID = ARS.ScaleID INNER JOIN dbo.Agreements_CalculationSettings ACS ON ARS.AgreementRebateSettingID = ACS.AgreementRebateSettingID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Scales_Bands', SB.* FROM dbo.Scales_Bands SB INNER JOIN dbo.Scales S ON SB.ScaleID = S.ScaleID INNER JOIN dbo.Agreements_RebateSettings ARS ON S.ScaleID = ARS.ScaleID INNER JOIN dbo.Agreements_CalculationSettings ACS ON ARS.AgreementRebateSettingID = ACS.AgreementRebateSettingID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Attributes_ToCompare', ATC.* FROM dbo.Attributes_ToCompare ATC INNER JOIN dbo.Agreements_CalculationSettings ACS ON ACS.AgreementCalculationSettingID = ATC.ReferenceID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Attributes_ToCompareValues', ATCV.* FROM dbo.Attributes_ToCompareValues ATCV INNER JOIN dbo.Attributes_ToCompare ATC ON ATC.AttributeToCompareID = ATCV.AttributeToCompareID INNER JOIN dbo.Agreements_CalculationSettings ACS ON ACS.AgreementCalculationSettingID = ATC.ReferenceID INNER JOIN dbo.Agreements_CalculationVersions ACV ON ACS.AgreementCalculationVersionID = ACV.AgreementCalculationVersionID INNER JOIN dbo.Agreements A ON A.AgreementID = ACV.AgreementID where A.AgreementID = @AgreementID
SELECT 0 as 'Balances_FeeRetroDetails', * FROM dbo.Balances_FeeRetroDetails where AgreementID = @AgreementID

--== Grid Data related
select * FROM Grids
select * FROM Grids_CalculationVersions
select * FROM Grids_CalculationSettings

--== VAT Data related
select * FROM VATRateTypes
select * FROM VATReferences
select * FROM VATProfiles
select * FROM VATRates
select * FROM FourE_VATProfiles
select * FROM FourE_VATRates

delete from FourE_VATRates where FourE_ActionID is not null
delete from FourE_VATProfiles where FourE_ActionID is not null
delete from FourE_VATProfiles
delete from VATRates 
delete from VATProfiles

truncate table balances_in
select * FROM Balances_IN
select * from DE_Balances_IN
select * from ewoc_Errors
select * from RCP_Balances_IN_Errors order by  _ImportFileDate desc

--== Balance tables
SELECT * FROM Balances_AUMRetroDetails
SELECT * FROM Balances_AUMRetroTotals
SELECT * FROM Balances_DailyAccrualDetails order BY AgreementID, AgreementCalculationVersionID, AgreementCalculationSettingID, Date
SELECT * FROM Balances_DailyAccrualTotals 
SELECT * FROM Balances_IN
SELECT * FROM FeeDistribution_IN where PortfolioID = 100004 and ProductID <> -97 order by EffectiveDate, RebateDate
SELECT * FROM FeeDistribution_IN where PortfolioID in ( 100004,  100005, 100006)
SELECT * FROM FeeDistribution_IN where SubServiceID = 3 and rebatedate < '20110101'
SELECT * FROM Balances_AUMRetroDetails where AgreementID = 100029 ORDER BY period, PortfolioID
SELECT * FROM Balances_DailyAccrualDetails where AgreementID = 100047
SELECT * FROM Balances_FeeRetroDetails where AgreementID = 100105 
select * from Payments where AgreementID = 100074
select * from Payments_Details where PaymentID = 100789
select * from Payments_BalancesAUMDetails where PaymentDetailID in (101211)
select * from Payments_BalancesAUMDetails where AgreementCalculationSettingID = 100127
select * from Payments_CalculationSettings where PaymentDetailID in (100469,100470,100471)
select * from Payments_BalancesAUMTotals where PaymentDetailID in (100469,100470,100471)
select * from Scales_Bands where ScaleBandID = 100945
select * from Scales where ScaleID = 100338
select * from Agreements_CalculationVersions where AgreementCalculationVersionID = 100156
select * from FundPools_ShareClasses where FundPoolID = 100001
select * from Agreements
select * FROM dbo.Balances_IN where AgreementReference = 'TUKIN01'
SELECT dbo.LP2DT(24162, 1)

DECLARE @AgrCode NVARCHAR(20)= 'CC01'
SELECT SC.CurrencyID, BAD.* FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period, SC.CurrencyID
--SELECT SC.CurrencyID, A.SplitPercentage, RetroFinal = IsNull(Retro, 0) - Round(IsNull(Retro, 0) * A.SplitPercentage / 100, AM.NumberOfDecimals), BAD.* FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID INNER JOIN Agreements A ON A.AgreementID = BAD.AgreementID INNER JOIN AssetManagers AM ON AM.AssetManagerID = A.AssetManagerID where BAD.AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY A.AgreementID, Period, SC.CurrencyID
--SELECT AgreementID, AgreementVersionID, AgreementCalculationSettingID, Period, PeriodTypeID, SC.CurrencyID, SUM(Retro), SUM(RetroFinal) FROM Balances_AUMRetroDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) GROUP BY AgreementID, AgreementVersionID, AgreementCalculationSettingID, Period, PeriodTypeID, SC.CurrencyID ORDER BY AgreementID, Period, SC.CurrencyID
SELECT * FROM Balances_AUMRetroTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period
SELECT * FROM Balances_DailyAccrualDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID  where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, BAD.PortfolioID, BAD.ShareClassID, Date 
--SELECT AgreementID, AgreementCalculationVersionID, AgreementCalculationSettingID, SC.CurrencyID, SUM(BAD.Retrocession) - SUM(BAD.RetrocessionFinal)FROM Balances_DailyAccrualDetails BAD INNER JOIN ShareClasses SC ON BAD.ShareClassID = SC.ShareClassID where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) GROUP BY AgreementID, AgreementCalculationVersionID, AgreementCalculationSettingID, SC.CurrencyID ORDER BY AgreementID, SC.CurrencyID
--SELECT *FROM Balances_DailyAccrualTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Date
SELECT DISTINCT AgreementID, ShareClassCurrencyID, ThresholdCurrencyID, AccrualCurrencyID FROM Balances_DailyAccrualTotals where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) --ORDER BY AgreementID, Date
SELECT * FROM Balances_FeeRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY AgreementID, Period

select * FROM Agreements_CalculationSettings
select * FROM Agreements
select * FROM FeeDistribution_IN
SELECT * FROM Balances_FeeRetroDetails where AgreementID = 100070 ORDER BY Period, PortfolioID
SELECT Period, SUM(Retro) FROM Balances_FeeRetroDetails WHERE AgreementID = 100033 GROUP by Period
SELECT * FROM TestCases_FailureOutput

--== Reinvestment tables
DECLARE @AgrCode NVARCHAR(20)= 'SJT'
SELECT 0 as 'Reinvestments', * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT 0 as 'Reinvestments_Details', * FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY Period
SELECT 0 as 'Reinvestments_BalancesAUMDetails', SC.CurrencyID, RBAD.* FROM Reinvestments_BalancesAUMDetails RBAD INNER JOIN Reinvestments_Details RD ON RD.ReinvestmentDetailID = RBAD.ReinvestmentDetailID INNER JOIN ShareClasses SC ON SC.ShareClassID = RBAD.ShareClassID where RBAD.ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)) ORDER BY RD.ReinvestmentID, RD.Period, SC.CurrencyID
SELECT 0 as 'Reinvestments_BalancesAUMTotals', RBAT.* FROM Reinvestments_BalancesAUMTotals RBAT INNER JOIN Reinvestments_Details RD ON RD.ReinvestmentDetailID = RBAT.ReinvestmentDetailID where RBAT.ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)) ORDER BY RD.ReinvestmentID, RD.Period
SELECT 0 as 'Reinvestments_Stocks', * FROM Reinvestments_Stocks where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_NAVs', * FROM Reinvestments_NAVs where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_CurrenciesExchangeRates', * FROM Reinvestments_CurrenciesExchangeRates where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_CalculationVersionGroups', * FROM Reinvestments_CalculationVersionGroups where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_CalculationVersions', * FROM Reinvestments_CalculationVersions where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_CalculationSettings', * FROM Reinvestments_CalculationSettings where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_RebateSettings', * FROM Reinvestments_RebateSettings where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_ThresholdSettings', * FROM Reinvestments_ThresholdSettings where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_Scales', * FROM Reinvestments_Scales where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_Scales_Bands', * FROM Reinvestments_Scales_Bands where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_AgentsHierarchy', * FROM Reinvestments_AgentsHierarchy where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_HOPMembers', * FROM Reinvestments_HOPMembers where ReinvestmentDetailID IN (SELECT ReinvestmentDetailID FROM Reinvestments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))
SELECT 0 as 'Reinvestments_ReinvestmentsAttributes', * FROM Reinvestments_ReinvestmentsAttributes where ReinvestmentID in (SELECT Reinvestments.ReinvestmentID FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))

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


--== Payments Data
select * FROM Payments order BY AgreementID, StartPeriod, IsACorrection
select * FROM Payments_Details order BY AgreementID, Period
select * FROM Payments_BalancesAUMDetails WHERE PaymentDetailID = 100016
select * from AuditTrails order by 2 desc
select * FROM Payments where AgreementID = 100071
select * from Agreements

DECLARE @AgrCode NVARCHAR(20)= 'YTD01'
SELECT 'Payments', * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) ORDER BY StartPeriod, closed desc
SELECT 'Payments_Details', * FROM Payments_Details where PaymentID IN (select PaymentID FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)) ORDER BY AgreementID, Period
--SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where PaymentID IN (select PaymentID FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)))
--SELECT 'Payments_BalancesAUMTotals', * FROM Payments_BalancesAUMTotals where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))

SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where PaymentID IN (select PaymentID FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))) AND PaymentDetailID IN (100039)
SELECT 'Payments_BalancesAUMDetails', * FROM Payments_BalancesAUMDetails where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where PaymentID IN (select PaymentID FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))) -- AND Date = '20100101'
SELECT 'Payments_BalancesAUMTotals', * FROM Payments_BalancesAUMTotals where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)) --AND PaymentDetailID IN (100049, 100001)
SELECT 'Payments_BalancesAUMTotals', * FROM Payments_BalancesAUMTotals where PaymentDetailID IN (select PaymentDetailID FROM Payments_Details where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode))-- AND Date = '20100101'
SELECT * FROM Payments_CurrenciesExchangeRates
SELECT * FROM Payments_NAVs where PaymentDetailID = 100149
select * FROM Payments_Stocks where PaymentDetailID = 100149
select * from Payments_AgentsHierarchy
select * FROM Payments_HOPMembers
SELECT * FROM Payments_CalculationSettings
SELECT * FROM Payments_CalculationVersions
SELECT * FROM Payments_CalculationVersionGroups

select * from dbo.Balances_AUMRetroDetails where AgreementCalculationSettingID = 100203 AND Period = 24114 ORDER BY PortfolioID, ShareClassID, BandRowNumber
select * from dbo.Balances_AUMRetroDetails where AgreementCalculationSettingID = 100101 AND Period = 24129 ORDER BY PortfolioID, ShareClassID, BandRowNumber

SELECT dbo.LP2DT(8030, 2)
SELECT dbo.LP2DT(24091, 1)

SELECT * from dbo.Balances_FeeRetroDetails where Period = dbo.ConvertPeriod(8030, 2, 1) AND AgreementID = 100076
SELECT * FROM dbo.Balances_FeeRetroDetails where RowID = 36

declare @paymentid INT = 101266
select * from Payments where PaymentID = @paymentid
select * from Payments_Details where PaymentID = @paymentid
select * from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) 
select distinct PaymentFXRateID from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid)
select * from Balances_AUMRetroDetails where AgreementCalculationSettingID  IN (select AgreementCalculationSettingID from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid))
select * from Payments_Stocks where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) and ShareClassID = 100015
select * from Payments_NAVs where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) and ShareClassID = 100015

-- Zero payments
SELECT P.PaymentID, P.InvoiceNumber
	, Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(PD.Retrocession, 0))) as nvarchar) Amount
	, Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(PD.VAT, 0))) as nvarchar) VATAmount
	, CASE WHEN A.AgreementDirectionID = 1 THEN 'IN' ELSE 'OUT' END
FROM Payments P
LEFT JOIN Payments_Details PD
    ON PD.PaymentID = P.PaymentID
LEFT JOIN Agreements A
    ON A.AgreementID = P.AgreementID
GROUP BY P.AgreementID, P.InvoiceNumber, P.CurrencyID, P.PaymentID, A.AgreementDirectionID
HAVING SUM(ISNULL(PD.Retrocession, 0)) = 0
ORDER BY P.PaymentID DESC

SELECT *
FROM (
SELECT DISTINCt AgreementVersionID, AgreementCalculationSettingID, Period,  PortfolioID, ShareClassID, BandRowNumber
FROM dbo.Balances_AUMRetroDetails
WHERE AgreementID = 100028
EXCEPT
SELECT DISTINCt PBAD.AgreementVersionID, PBAD.AgreementCalculationSettingID, PD.Period, PortfolioID, ShareClassID, PBAD.BandRowNumber
FROM Payments_BalancesAUMDetails PBAD
INNER JOIN Payments_Details PD
ON PD.PaymentDetailID = PBAD.PaymentDetailID
 WHERE PD.AgreementID = 100028
) AS T
--WHERE T.ShareClassID <> 100009
ORDER BY T.Period

SELECT *
FROM dbo.Balances_FeeRetroDetails 
where AgreementID = 100028

SELECT * FROM dbo.Payments where AgreementID = 100831
SELECT * FROM dbo.Agreements_CalculationSettings where AgreementCalculationVersionID = 100103
SELECT * FROM dbo.Agreements_CalculationSettings where AgreementCalculationSettingID = 100107

SELECT *
FROM (
SELECT DISTINCt PBAD.AgreementVersionID, PBAD.AgreementCalculationSettingID, PBAD.RetroCurrencyID,  PortfolioID, ShareClassID, Date
FROM Payments_BalancesAUMDetails PBAD
INNER JOIN Payments_Details PD
ON PD.PaymentDetailID = PBAD.PaymentDetailID
 WHERE PD.AgreementID = 100028
EXCEPT
SELECT DISTINCt AgreementCalculationVersionID, AgreementCalculationSettingID, AccrualCurrencyID, PortfolioID, ShareClassID, Date
FROM Balances_DailyAccrualDetails
WHERE AgreementID = 100028
) AS T
--WHERE T.ShareClassID <> 100009
ORDER BY T.Date


SELECT *
FROM (
SELECT DISTINCt AgreementCalculationVersionID, AgreementCalculationSettingID, AccrualCurrencyID, PortfolioID, ShareClassID, Date
FROM Balances_DailyAccrualDetails
WHERE AgreementID = 100048
EXCEPT
SELECT DISTINCt PBAD.AgreementVersionID, PBAD.AgreementCalculationSettingID, PBAD.RetroCurrencyID,  PortfolioID, ShareClassID, Date
FROM Payments_BalancesAUMDetails PBAD
INNER JOIN Payments_Details PD
ON PD.PaymentDetailID = PBAD.PaymentDetailID
 WHERE PD.AgreementID = 100048
) AS T
--WHERE T.ShareClassID <> 100009
ORDER BY T.Date


SELECT *
FROM (
SELECT DISTINCt AgreementVersionID, AgreementCalculationSettingID, RetroCurrencyID, PortfolioID, ShareClassID, Date
FROM Balances_FeeRetroDetails
WHERE AgreementID = 100066
EXCEPT
SELECT DISTINCt PBAD.AgreementVersionID, PBAD.AgreementCalculationSettingID, PBAD.RetroCurrencyID,  PortfolioID, ShareClassID, Date
FROM Payments_BalancesAUMDetails PBAD
INNER JOIN Payments_Details PD
ON PD.PaymentDetailID = PBAD.PaymentDetailID
 WHERE PD.AgreementID = 100066
) AS T
--WHERE T.ShareClassID <> 100009
ORDER BY T.Date

--- Review Report

SELECT * FROM dbo.Payments where PaymentID = 101256
EXEC dbo.Report_PaymentReview_CalculationSummary @PaymentID = 101260, @StartDate = NULL, @EndDate = NULL, @AssetManagerID = NULL, @AgreementID = NULL
EXEC dbo.Report_PaymentReview_CalculationDaily @PaymentID = 101260, @StartDate = NULL, @EndDate = NULL, @AssetManagerID = NULL, @AgreementID = NULL


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
select @@trancount
exec dbo.Computation_Enable
exec Computation_Disable
EXEC Computation_CleanQueues

EXEC Computation_Start @Debug = 1

BEGIN transaction
    exec dbo.UT_ExecuteTestCase 33, 0, 0

COMMIT TRANSACTION
ROLLBACK TRANSACTION

SELECT * FROM TestCases_FailureOutput
select * from Agreements
select * from dbo.Agreements_CalculationVersions
select * from dbo.Agreements_CalculationSettings
select * FROM Payments
select * FROM Balances_IN
select * FROM dbo.SubServiceTypes
select * FROM FeeDistribution_IN  where SubServiceID = 4
select * from AssetManagers
select * from Balances_AUMRetroDetails where AgreementID = 100077 order by period
SELECT * FROM dbo.Balances_DailyAccrualDetails where AgreementID = 100060 AND AUMRebate = 0
select * FROM Payments_BalancesAUMDetails

select * from dbo.Balances_AUMRetroDetails where AgreementID = 100029 ORDER BY Period, PortfolioID, ShareClassID, BandRowNumber
select * FROM Balances_FeeRetroDetails where AgreementCalculationSettingID = 100107
SELECT * FROM dbo.Payments where InvoiceNumber = 'AM1-TA10040-2009-06-EUR'
select * from Payments where PaymentID = 100609
select * from Payments_Details where PaymentID = 100609
SELECT * FROM dbo.Payments_BalancesAUMDetails where PaymentDetailID = 101519
select * from Payments_BalancesAUMDetails  where PaymentDetailID in (select PaymentDetailID from Payments_Details where AgreementID = 100034)
SELECT * FROM dbo.CurrenciesExchangeRates where CurrencyExchangeRateID =100299
SELECT dbo.LP2DT(24161, 1)

SELECT * FROM dbo.ShareClasses where ShortName = 'SC3'
SELECT * FROM dbo.Fees where ProductID = 100013
BEGIN transaction
    exec dbo.UT_ExecuteExtendedScenarioByTestCase 13

exec Computation_Disable
exec Computation_Start @Debug = 1
select @@trancount
    
SELECT * from dbo.Attributes_Values    
SELECT * from dbo.Attributes_ToCompare
SELECT * from dbo.Attributes_ToCompareValues
select * FROM dbo.Agreements
select * FROM dbo.Balances_FeeRetroDetails where AgreementID = 100028
SELECT * from dbo.Scales_Bands where ScaleBandID = 100801
SELECT * FROM dbo.Fees WHERE ProductID = (SELECT ShareClassID FROM ShareClasses WHERE ShortName = 'SC3') AND FeeTypeID = 1  	

EXEC dbo.Computation_Disable
EXEC dbo.SysteminformationComputationQueue_GetTable_All
SELECT * FROM dbo.TestCases_FailureOutput

BEGIN transaction    
    exec dbo.UT_ExecuteExtendedScenarioByTestCase 10121
    
BEGIN transaction    
    exec dbo.UT_ExecuteTestCase 10122, 0, 0
        
BEGIN transaction
    exec dbo.UT_ExecuteTestCase 201, 0, 0
    
        
COMMIT TRANSACTION
ROLLBACK TRANSACTION

RETURN

DECLARE @AgrCode NVARCHAR(20)=  'TEX01' --NULL
---Payments
SELECT P.PaymentID, P.InvoiceNumber
	, Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(PD.Retrocession, 0))) as nvarchar) Amount
	, Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(PD.VAT, 0))) as nvarchar) VATAmount
FROM Payments P
INNER JOIN Payments_Details PD
					ON PD.PaymentID = P.PaymentID
LEFT JOIN Agreements A
                  ON A.AgreementID = P.AgreementID
                  AND A.AgreementCode = @AgrCode
GROUP BY P.AgreementID, P.InvoiceNumber, P.CurrencyID, P.PaymentID
ORDER BY P.AgreementID, P.CurrencyID, P.InvoiceNumber, P.PaymentID

--- Reinvestments
SELECT R.ReinvestmentReference as Reference
      , Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(RD.Reinvestment, 0))) as nvarchar) Amount
  FROM Reinvestments R
      INNER JOIN Reinvestments_Details RD
                  ON RD.ReinvestmentID = R.ReinvestmentID
      LEFT JOIN Agreements A
                  ON A.AgreementID = R.AgreementID
                  AND A.AgreementCode = @AgrCode
GROUP BY R.AgreementID, R.ReinvestmentReference, R.ReinvestmentID
ORDER BY R.AgreementID, R.ReinvestmentReference, R.ReinvestmentID

