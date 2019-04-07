SELECT DISTINCT so.name, so.type --, com.text
FROM sys.all_objects so 
INNER JOIN sys.syscomments com ON so.object_id = com.id
WHERE so.type IN ('P', 'TR', 'FN','TF','IF','V') -- trigger  / procedure / function
AND com.text LIKE '%Computation\_FeeDistribution\_IN%' escape '\'

--AND com.text LIKE '%Payments_Reinvestments_AuditTrailsInsert%'
--AND com.text LIKE '%Payments_UpdateReinvestmentsStatus%'
--AND com.text NOT LIKE '%Computation_Start%'
--AND so.name NOT LIKE 'Payments_UpdateReinvestmentsStatus'
--AND so.name NOT LIKE 'Payments_Reinvestments_AuditTrailsInsert'
--AND so.name NOT LIKE 'AuditTrailsSnapshot_Payments_Reinvestments'
--AND so.name NOT LIKE 'Reinvestments_AuditTrailsInsert'
--AND so.name NOT LIKE 'Reinvestments_UpdateReinvestmentsStatus'
--AND so.name NOT LIKE 'Migration_CleanDatabaseByAssetManager'
--AND so.name NOT LIKE 'DE_%'
ORDER BY so.name


-- TODO .NET : delete usage of Payments_UpdateReinvestmentsStatus ?
/*
--> Table Payments_Reinvestments
DE_Migration_CleanTables ?????????
Report_AgreementCalculationReInvestments
Report_PaymentCalculationReInvestments
Report_Reinvestments
*/

 

