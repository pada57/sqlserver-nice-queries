--====== Generate data ======--
EXEC ___Data_Generate_TestData001 @TestEnv=1
EXEC UT_DeleteAllAgreements

--====== Clean before test ======--
truncate table TestCases_FailureOutput
truncate table System_Alerts
EXEC Computation_CleanQueues
UPDATE TestCases SET HasRun = NULL, Succeeded = NULL

select * from TestCases

exec dbo.UT_ExecuteTestCase 1, 0, 0 
exec dbo.UT_ExecuteTestCase 2, 0, 0 
exec dbo.UT_ExecuteTestCase 3, 0, 0 
exec dbo.UT_ExecuteTestCase 4, 0, 0 
exec dbo.UT_ExecuteTestCase 5, 0, 0 


select * from feedistribution_in

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

SELECT * FROM Agents_Agents
SELECT * FROM Agents_Portfolios WHERE AgentID = 24469
SELECT *  FROM Computation_1Threshold WHERE PortfolioID = 192990
UPDATE Computation_1Threshold SET Status = 1 WHERE PortfolioID = 192990

--====== Execute test  ======-- (second param to regenerate test data and third to execute related test before)
begin
    declare @currentid int = 1
        , @FromId int = 1
        , @maxtcid int = 50
        
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

--====== Test output ======--
SELECT * FROM TestCases_FailureOutput
exec dbo.UT_ExecuteTestCase 301, 0, 0
select  * FROM AuditTrails_ComputationSteps where LogDate > DATEADD(MINUTE, -1, GETDATE())	
---- Force test verification
EXEC [UT_VerifyResultForTestCase] @TestCaseID=31
---- Sanity Check
DECLARE @NbErrors INT
EXEC UT_RunSanityChecks @TestCaseID=2, @NbError = @NbErrors
EXEC Computation_SanityCheck

--====== Execute computation step by step  ======--
Exec Computation_Start @Debug = 1
SELECT * FROM sys.triggers where name LIKE '%StartComputation'
SELECT * FROM sys.triggers where is_disabled = 1
EXEC [dbo].[Computation_Enable]

EXEC Computation_CleanQueues
EXEC [dbo].[Computation_Disable]
SELECT @@trancount

insert into WKT_PaymentsPendingApprovalChecks (AgreementID, Status, ChangedEntityID)
select 100077, 0, 0

BEGIN transaction
    UPDATE Agreements SET SplitPercentage = 20.00 WHERE AgreementID = 495

BEGIN transaction
    EXEC UT_CreateAgreementsFromTestCase @TestCaseID = 300

BEGIN transaction
    EXEC UT_ExecuteExtendedScenarioByTestCase @TestCaseID = 32
    
select * from Agreements_CalculationSettings

BEGIN transaction
    EXEC UT_ExecuteTestCase 300, 0 , 0

COMMIT TRANSACTION
ROLLBACK TRANSACTION

EXEC Computation_CleanQueues
EXEC [dbo].[Computation_Disable]

select * from Fees where FeeTypeID = 5
select * from FourE_Fees where FeeTypeID = 5

UPDATE Computation_1Threshold SET Status = 0

SELECT * FROM Computation_1Threshold

insert INTO Computation_1Threshold
SELECT * FROM Computation_1ThresholdCopy

INSERT INTO Computation_PaymentsStatus		   (			[AgreementID]		   ,[ShareClassID]		   ,[FundPoolID]		   ,[Status]		   ,[ChangedEntityID]		   )
		SELECT DISTINCT 			   100057			 , NULL			 , NULL			 , 0			 , 143

INSERT INTO Computation_CommissionsPeriod (AgreementID, AgreementVersionID, AgreementCalculationSettingID, ShareClassID, Period, PeriodTypeID, DateStart, DateEnd, ChangeDate, Status, ChangedEntityID)
VALUES (100031, 100107,	100103,	100003,	24164, 1, '20130901', '20130930', GETDATE(), 0, 0)

select dbo.LP2DT(24111, 1)

truncate table Computation_CommissionsPeriod
update Computation_PaymentsDelta set Status = 0

SELECT @@trancount

BEGIN TRANSACTION
BEGIN TRY
    EXEC [dbo].Computation_Disable
	EXEC dbo.Computation_Step @Debug = 1
	EXEC dbo.SysteminformationComputationQueue_GetTable_All
	select * from System_Alerts
	
	select * from Balances_DailyAccrualDetails where AgreementCalculationSettingID = 100119
	select * from Balances_DailyAccrualDetails where AgreementCalculationSettingID = 100120
	
	select * from Agreements where AgreementID = 100035
	select * from Agreements_CalculationVersions where AgreementID = 100035
	select * from Agreements_CalculationSettings where AgreementCalculationVersionID = 100119
	select * from Agreements_CalculationSettings where AgreementCalculationVersionID = 100117
	
	select 0 as 'Computation_BalancesPendingThresholdAUM', * FROM dbo.Computation_BalancesPendingThresholdAUM where AgreementID = 100035
	select 0 as 'Computation_BalancesUpdateReinvestments', * FROM dbo.Computation_BalancesUpdateReinvestments where AgreementID = 100035
	select * from Computation_BalancesPendingDailyCommissions where AgreementID = 100035 and Date = '2009-07-01 00:00:00'	
	select * from Balances_DailyAccrualDetails where AgreementID = 100035 and AgreementCalculationSettingID = 100128
	
	select  * FROM AuditTrails_ComputationSteps where LogDate > DATEADD(MINUTE, -20, GETDATE()) ORDER BY AuditTrails_ComputationStepID DESC	
	select * from ComputationSteps
	select * from TestCases_FailureOutput where ResultType = 1
	--SELECT * FROM System_Alerts	
	
	ROLLBACK TRANSACTION 
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	print 'error'
	select * from AuditTrails_Monitoring order BY 1 desc
	SELECT * FROM System_Alerts
	ROLLBACK TRANSACTION 
END CATCH

EXEC Grids_Synchronize @GridID = 100001, @FourE_AgreementCalculationVersionGroupID = NULL

truncate table Computation_PaymentsVAT
insert Computation_PaymentsVAT
select * from Computation_PaymentsVATCopy

select * from VATProfiles
update Agreements set VATProfileID = 1 where AgreementCode = 'AI01'

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

--=======  Alerts & Queues & Audits =======--
SELECT * FROM System_Alerts
SELECT * FROM sys.dm_tran_active_transactions
select @@trancount

-- Queues
EXEC dbo.SysteminformationComputationQueue_GetTable_All

select 0 as 'Computation_0Stocks',* FROM dbo.Computation_StocksPendingNbShares
select 0 as 'Computation_1Threshold', * FROM dbo.Computation_BalancesPendingThresholdAUM
select 0 as 'Computation_AUMDaily', * FROM dbo.Computation_BalancesPendingDailyAUM
select 0 as 'Computation_AUMDailyTotal', * FROM dbo.Computation_BalancesPendingDailyTotalAUM
select 0 as 'Computation_AUMLeverage', * FROM dbo.Computation_ThresholdLeverage
select 0 as 'Computation_AUMPeriodTotal', * from dbo.Computation_BalancesPendingCalculationAUM
select 0 as 'Computation_CommissionsDaily', * from dbo.Computation_BalancesPendingDailyCommissions
select 0 as 'Computation_CommissionsDailyTotal', * from dbo.Computation_BalancesPendingDailyTotalCommissions
select 0 as 'Computation_CommissionsLeverage', * from dbo.Computation_BalancesPendingCommissionsLeverage
select 0 as 'Computation_CommissionsPeriod', * from dbo.Computation_BalancesPendingCommissions
select 0 as 'Computation_CommissionsSplitReinvestment', * from dbo.Computation_BalancesUpdateReinvestments
select 0 as 'Computation_PaymentsDelete', * from dbo.Computation_DeletePayments
select 0 as 'Computation_ReinvestmentsDelete', * from dbo.Computation_DeleteReinvestments
select 0 as 'Computation_Payments', * from dbo.Computation_Payments where AgreementID = 100127
select 0 as 'Computation_Reinvestments', * from dbo.Computation_Reinvestments
select 0 as 'Computation_PaymentsDelta', * from dbo.Computation_PaymentsDelta order BY Date
select 0 as 'Computation_ReinvestmentsDelta', * from dbo.Computation_ReinvestmentsDelta
select 0 as 'Computation_ReinvestmentsFinal', * from dbo.Computation_ReinvestmentsFinal
select 0 as 'Computation_PaymentsTransactions', * from dbo.Computation_PaymentsTransactions

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

--== Agreements Data related
select * FROM Agreements
select * FROM Agreements_CalculationVersions
select * FROM Agreements_CalculationVersionGroups
select * FROM Agreements_CalculationSettings
select * FROM Agreements_RebateSettings
select * FROM Agreements_ThresholdSettings
select * FROM Agreements_DefaultRebateHOPMembers
select * FROM Agreements_HOPMembers
select * FROM Scales where ScaleID = 100240
select * FROM Scales_Bands where ScaleID = 100240

select * from Agreements_CalculationSettings
select * from FourE_Agreements_CalculationSettings

select * FROM FourE_Agreements_CalculationVersions
select * from FourE_Scales where FourE_ScaleID = 2808
select * from FourE_Scales_Bands where FourE_ScaleID = 2808
select * from Agreements where AgreementID = 100035

DECLARE @AgrCode NVARCHAR(20) = 'RA12'
SELECT * FROM Agreements where AgreementCode = @AgrCode
SELECT  acs.AgreementCalculationSettingID, acv.AgreementCalculationVersionID, acv.VersionName, acv.DateStart, acv.DateEnd, acv.TradeBasisID, acv.ThresholdCurrencyID
	, acv.AccrualMethodID
	, acv.ThresholdCalculationBasisID, acv.RebateCalculationBasisID
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
where A.AgreementCode = @AgrCode
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_AUMRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
UNION
SELECT DISTINCT PortfolioID, ShareClassID FROM Balances_DailyAccrualDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT * FROM Agreements_PaymentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode)
SELECT * FROM Agreements_ReinvestmentInstructions where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Payments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Reinvestments where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 
SELECT * FROM Balances_FeeRetroDetails where AgreementID IN (SELECT AgreementID FROM Agreements where AgreementCode = @AgrCode) 

select * from Agreements_CalculationVersions where AgreementCalculationVersionID = 100115
select * from Agreements_CalculationSettings where AgreementCalculationVersionID = 100115
select * from Agreements_RebateSettings where AgreementRebateSettingID = 100119 or AgreementRebateSettingID = 100120
select * from Agreements_HOPMembers where AgreementRebateSettingID = 100119 OR AgreementThresholdSettingID = 100119
select * from Agreements_HOPMembers where AgreementRebateSettingID = 100120 OR AgreementThresholdSettingID = 100120

SELECT * FROM Scales where ScaleID = 100244
SELECT * FROM Scales_Bands where ScaleID = 100244
SELECT * FROM Agents_Portfolios where AgentID = 100001
SELECT * FROM FundPools_ShareClasses WHERE FundPoolID = 100003
SELECT * FROM Stocks where PortfolioID IN (100001, 100002, 100003)

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
SELECT * FROM dbo.RCP_Balances_IN_Errors
SELECT * FROM FeeDistribution_IN where PortfolioID = 100004 and ProductID <> -97 order by EffectiveDate, RebateDate
SELECT * FROM FeeDistribution_IN where PortfolioID in ( 100004,  100005, 100006)
SELECT * FROM FeeDistribution_IN where SubServiceID = 3 and rebatedate < '20110101'
SELECT * FROM Balances_AUMRetroDetails where AgreementID = 100047
SELECT * FROM Balances_DailyAccrualDetails where AgreementID = 100047
SELECT * FROM Balances_FeeRetroDetails where AgreementID = 100074 
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

DECLARE @AgrCode NVARCHAR(20)= 'TC300TA1'
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

select * from Agreements
select * from FeeTypes
select * from Fees where FeeTypeID = 6
select * from FourE_Fees where FeeTypeID = 6

insert FourE_Fees (FeeID, FeeTypeID, PortfolioID, ProductID, DateStart, ExceptionDateEnd, FeeValue)
select FeeID, FeeTypeID, PortfolioID, ProductID, DateStart, ExceptionDateEnd, FeeValue
from fees where FeeID = 100103

select (CASE WHEN ISNULL(B.InitialAUMThreshold, 0) <> 0 THEN (CONVERT(NUMERIC(38,18), ISNULL(B.AUMThreshold, 0)) / ISNULL(B.InitialAUMThreshold, 1))                          
                                ELSE 1 END) from Balances_FeeRetroDetails B where AgreementCalculationSettingID = 100110 and RowID = 1
select * from Balances_FeeRetroDetails B where AgreementCalculationSettingID = 100110 and RowID = 1
select * from Agreements
select * from Payments where AgreementID = 100071

declare @paymentid int = 100523
select * from Payments where PaymentID = @paymentid
select * from Payments_Details where PaymentID = @paymentid
select * from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) 
select distinct PaymentFXRateID from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid)
select * from Balances_AUMRetroDetails where AgreementCalculationSettingID  IN (select AgreementCalculationSettingID from Payments_BalancesAUMDetails where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid))
select * from Payments_Stocks where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) and ShareClassID = 100015
select * from Payments_NAVs where PaymentDetailID in (select PaymentDetailID from Payments_Details where PaymentID = @paymentid) and ShareClassID = 100015

SELECT * FROM dbo.Agreements_CalculationSettings where AgreementCalculationSettingID IN (100102, 100105, 100114)
SELECT * FROM dbo.Balances_DailyAccrualDetails where AgreementCalculationSettingID IN (100102, 100105, 100114)
SELECT * FROM dbo.Trade_Basis
select * FROM dbo.Portfolios

SELECT *
FROM (
SELECT DISTINCt PBAD.AgreementVersionID, PBAD.AgreementCalculationSettingID, PBAD.RetroCurrencyID,  PortfolioID, ShareClassID, Date
FROM Payments_BalancesAUMDetails PBAD
INNER JOIN Payments_Details PD
ON PD.PaymentDetailID = PBAD.PaymentDetailID
 WHERE PD.AgreementID = 100048
EXCEPT
SELECT DISTINCt AgreementCalculationVersionID, AgreementCalculationSettingID, AccrualCurrencyID, PortfolioID, ShareClassID, Date
FROM Balances_DailyAccrualDetails
WHERE AgreementID = 100048
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
exec Computation_Disable
EXEC Computation_CleanQueues

EXEC Computation_Start @Debug = 1

BEGIN transaction
    exec dbo.UT_ExecuteTestCase 104, 0, 0

COMMIT TRANSACTION
ROLLBACK TRANSACTION

SELECT * FROM TestCases_FailureOutput
select * from Agreements
select * FROM Payments
select * FROM Balances_IN
select * FROM FeeDistribution_IN
select * from AssetManagers
select * from Balances_AUMRetroDetails order by period
select * FROM Payments_BalancesAUMDetails

select * FROM Balances_FeeRetroDetails where AgreementID = 100170
select * from Payments where AgreementID = 100025
select * from Payments_Details where AgreementID = 100025
select * from Payments_BalancesAUMDetails  where PaymentDetailID in (select PaymentDetailID from Payments_Details where AgreementID = 100025)

BEGIN transaction
    exec dbo.UT_ExecuteExtendedScenarioByTestCase 303

exec Computation_Disable
exec Computation_Start @Debug = 1
select @@trancount
BEGIN transaction
    exec dbo.UT_ExecuteTestCase 31, 0, 0

COMMIT TRANSACTION
ROLLBACK TRANSACTION

DECLARE @AgrCode NVARCHAR(20)= NULL -- 'TC4TA01'
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


---Payments
SELECT P.PaymentID, P.InvoiceNumber
	, Cast(CONVERT(DECIMAL(15,4),SUM(ISNULL(PD.Retrocession, 0))) as nvarchar) Amount
FROM Payments P
INNER JOIN Payments_Details PD
					ON PD.PaymentID = P.PaymentID
LEFT JOIN Agreements A
                  ON A.AgreementID = P.AgreementID
                  AND A.AgreementCode = @AgrCode
GROUP BY P.AgreementID, P.InvoiceNumber, P.CurrencyID, P.PaymentID
ORDER BY P.AgreementID, P.CurrencyID, P.InvoiceNumber, P.PaymentID




