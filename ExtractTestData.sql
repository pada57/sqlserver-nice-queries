-- Test cases
SELECT TestCaseID, TestCaseCode, TestCaseName FROM TestCases
-- Test cases Results
SELECT * FROM TestCases_PaymentResults order BY TestCaseID
SELECT * FROM TestCases_ReinvestmentResults order BY TestCaseID

-- Agreement definitions
select A.TestCaseID as TestCaseCreated
    , AgreementCode
    , AD.AgreementDirectionName
    , PC.Label as PaymentCycle
    , PT.Name as CalculationPeriod
from UT_Agreements A
LEFT JOIN Agreements_Directions AD 
    ON A.AgreementDirectionID = AD.AgreementDirectionID
LEFT JOIN Payments_Cycles PC
    ON PC.PaymentCycleID = A.PaymentCycleId
LEFT JOIN Periods_Types PT
    ON A.CalculationPeriodTypeID = PT.PeriodTypeID
ORDER BY UT_AgreementID

-- Agreement versions
select VersionName, DateStart, DateEnd
    , c.CurrencyCode as ThesholdCurrency
    , tb.Label as TradeBasis
    , am.MethodName as AccrualMethod
from UT_Agreements_CalculationVersions acv
left join Currencies c
    on acv.ThresholdCurrencyID = c.CurrencyID
left join Trade_Basis tb
    on acv.TradeBasisID = tb.TradeBasisID
left join AccrualMethods am
    on am.AccrualMethodID = acv.AccrualMethodID
 
-- Calculation settings
select DISTINCT CS.UT_AgreementCalculationSettingID
    , S.ShortName 
    , ST.ServiceCode
    , SST.SubServiceCode
    , FM.Name as FeeModel
    , case when CS.DefineProductScope = 1 THEN 'TRUE' ELSE 'FALSE' END as DefineProductScope
    , CASE WHEN FP.FundPoolID IS NOT NULL THEN FP.ShortName ELSE 'N/A' END as ProductGroup
    , [dbo].[GetCalculationFormula](S.RetainRate, SB.RatePercent, SB.PointBaseRate, S.UseRetroIn) as Formula
    , CASE WHEN CS.FeeModelID = 1 THEN TCB.Label ELSE TFB.Label END as ThresholdBasis
    , CASE WHEN CS.FeeModelID = 1 THEN RCB.Label ELSE RFB.Label END as RebateBasis
    , NBD.Label as NumberDaysYear
    , CASE WHEN SM.SettingModeID = 1 THEN 'Normal Setting' ELSE 'Exception ' + SM.Label END as SettingModel     
 from [UT_Scales_Bands] SB 
 INNER JOIN UT_Scales S
    ON SB.UT_ScaleID = S.UT_ScaleID
 INNER JOIN UT_Agreements_RebateSettings RS
    ON RS.UT_ScaleID = S.UT_ScaleID
 INNER JOIN UT_Agreements_CalculationSettings CS
    ON RS.UT_AgreementRebateSettingID = CS.UT_AgreementRebateSettingID
 LEFT JOIN ServiceTypes ST
    ON CS.ServiceID = ST.ServiceID
 LEFT JOIN SubServiceTypes SST
    ON CS.SubServiceID = SST.SubServiceID
 LEFT JOIN FeeModels FM
    ON FM.FeeModelID = CS.FeeModelID
 LEFT JOIN Calculation_Basis TCB
    ON TCB.CalculationBasisID = CS.ThresholdCalculationBasisID
 LEFT JOIN Calculation_Basis RCB
    ON TCB.CalculationBasisID = CS.RebateCalculationBasisID
 LEFT JOIN Fee_Basis TFB
    ON TFB.FeeBasisID = CS.ThresholdFeeBasisID
 LEFT JOIN Fee_Basis RFB
    ON RFB.FeeBasisID = CS.RebateFeeBasisID
 LEFT JOIN NumberDaysYear NBD
    ON CS.NumberDaysYearID = NBD.NumberDaysYearID
 LEFT JOIN SettingModes SM
    ON SM.SettingModeID = CS.SettingModeID
 LEFT JOIN FundPools FP
    ON FP.FundPoolID = RS.FundPoolID
 WHERE ST.ServiceCode IS NOT NULL
 ORDER BY CS.UT_AgreementCalculationSettingID
 
 -- HOP
select ACS.UT_AgreementCalculationSettingID, A.AgentCode as RebateAgent, NULL as ThresholdAgent, P.PortfolioCode as RebatePortfolio, NULL as ThresholdPortfolio
from UT_Agreements_HOPMembers HOP
INNER JOIN UT_Agreements_RebateSettings ARS
    ON ARS.UT_AgreementRebateSettingID = HOP.UT_AgreementRebateSettingID
INNER JOIN UT_Agreements_CalculationSettings  ACS
    ON ACS.UT_AgreementRebateSettingID = ARS.UT_AgreementRebateSettingID
LEFT JOIN Agents A
    ON HOP.AgentID = A.AgentID
LEFT JOIN Portfolios P
    ON HOP.PortfolioID = P.PortfolioID
UNION
select ACS.UT_AgreementCalculationSettingID, NULL as RebateAgent, A.AgentCode as ThresholdAgent, P.PortfolioCode as RebatePortfolio, NULL as ThresholdPortfolio
from UT_Agreements_HOPMembers HOP
INNER JOIN UT_Agreements_ThresholdSettings ARS
    ON ARS.UT_AgreementThresholdSettingID = HOP.UT_AgreementThresholdSettingID
INNER JOIN UT_Agreements_CalculationSettings  ACS
    ON ACS.UT_AgreementThresholdSettingID = ARS.UT_AgreementThresholdSettingID
LEFT JOIN Agents A
    ON HOP.AgentID = A.AgentID
LEFT JOIN Portfolios P
    ON HOP.PortfolioID = P.PortfolioID
    

---- Scales
--SELECT ShortName
--, CASE ScaleTypeID WHEN 1 THEN 'Flat' WHEN 2 THEN 'Tiered' ELSE 'Mixed' END as 'Scale Type'
----, CASE WHEN RetainRate = 0 THEN 'false' ELSE 'true' END as 'Margin'
----, CASE WHEN UseRetroIN = 0 THEN 'false' ELSE 'true' END as 'Use Retro IN'
-- FROM UT_Scales
 
 
-- Scales bands
select S.ShortName, SB.FromAmount, SB.ToAmount
, CAST(CASE WHEN RatePercent IS NOT NULL THEN RatePercent ELSE PointBaseRate END AS nvarchar(100)) as Rate 
, CAST(CASE WHEN RatePercent IS NOT NULL THEN '%' ELSE 'Bps' END AS nvarchar(100)) as Unit
, CASE BandTypeID WHEN 1 THEN 'Flat' WHEN 2 THEN 'Tiered' END as 'Band Type'
from [UT_Scales_Bands] SB
INNER JOIN UT_Scales S
ON SB.UT_ScaleID = S.UT_ScaleID


-- Grids version
select VersionName, DateStart, DateEnd
    , c.CurrencyCode as ThesholdCurrency
    , tb.Label as TradeBasis
    , am.MethodName as AccrualMethod
from [UT_Grids_CalculationVersions] acv
left join Currencies c
    on acv.ThresholdCurrencyID = c.CurrencyID
left join Trade_Basis tb
    on acv.TradeBasisID = tb.TradeBasisID
left join AccrualMethods am
    on am.AccrualMethodID = acv.AccrualMethodID

-- Grid calc settings 
select DISTINCT CS.Description
    , S.ShortName 
    , ST.ServiceCode
    , SST.SubServiceCode
    , FM.Name as FeeModel
    , case when CS.DefineProductScope = 1 THEN 'TRUE' ELSE 'FALSE' END as DefineProductScope
    , [dbo].[GetCalculationFormula](S.RetainRate, SB.RatePercent, SB.PointBaseRate, S.UseRetroIn) as Formula
    , CASE WHEN CS.FeeModelID = 1 THEN TCB.Label ELSE TFB.Label END as ThresholdBasis
    , CASE WHEN CS.FeeModelID = 1 THEN RCB.Label ELSE RFB.Label END as RebateBasis
    , NBD.Label as NumberDaysYear
 from [UT_Scales_Bands] SB 
 INNER JOIN UT_Scales S
    ON SB.UT_ScaleID = S.UT_ScaleID
 INNER JOIN [UT_Grids_CalculationSettings] CS
    ON S.UT_ScaleID = CS.UT_RebateScaleID
 LEFT JOIN ServiceTypes ST
    ON CS.ServiceID = ST.ServiceID
 LEFT JOIN SubServiceTypes SST
    ON CS.SubServiceID = SST.SubServiceID
 LEFT JOIN FeeModels FM
    ON FM.FeeModelID = CS.FeeModelID
 LEFT JOIN Calculation_Basis TCB
    ON TCB.CalculationBasisID = CS.ThresholdCalculationBasisID
 LEFT JOIN Calculation_Basis RCB
    ON TCB.CalculationBasisID = CS.RebateCalculationBasisID
 LEFT JOIN Fee_Basis TFB
    ON TFB.FeeBasisID = CS.ThresholdFeeBasisID
 LEFT JOIN Fee_Basis RFB
    ON RFB.FeeBasisID = CS.RebateFeeBasisID
 LEFT JOIN NumberDaysYear NBD
    ON CS.NumberDaysYearID = NBD.NumberDaysYearID
 WHERE ST.ServiceCode IS NOT NULL
 ORDER BY CS.Description
 
 
 -- Fee distributiond details
 
 SELECT P.PortfolioCode, SC.ExternalReference AS ShareClassExtRef, ST.ServiceCode, SST.SubServiceCode, STF.Name, AUMCUr.CurrencyCode as 'AUM Currency'
, RetroCur.CurrencyCode AS 'Fee Amount Currency',  '''' + CAST(FIN.AUM as nvarchar(100)) as AUM, '''' + CAST(FIN.Quantity as nvarchar(100)) as Quantity
, '''' + CAST(FIN.FeeRate as nvarchar(100)) as FeeRate, '''' + CAST(FIN.FeeAmount as nvarchar(100)) as FeeAmount, FIN.EffectiveDate, FIN.RebateDate
from FeeDistribution_IN FIN
INNER JOIN Portfolios P
    ON FIN.PortfolioID = P.PortfolioID
INNER JOIN ShareClasses SC
    ON SC.ShareClassID = FIN.ProductID
INNER JOIN Currencies AUMCUr 
    ON FIN.AUMCurrencyID = AUMCUr.CurrencyID
INNER JOIN Currencies RetroCur 
    ON FIN.FeeAmountCurrencyID = RetroCur.CurrencyID
INNER JOIN SubServiceTypes SST
    ON FIN.SubServiceID = SST.SubServiceID
INNER JOIN ServiceTypes ST
    ON SST.ServiceID = ST.ServiceID
INNER JOIN ServiceTypeFrequency STF
    ON ST.FrequencyID = STF.FrequencyID
   
 
 