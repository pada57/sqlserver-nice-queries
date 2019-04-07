TRUNCATE TABLE dbo.Balances_IN
TRUNCATE table dbo.DE_Balances_IN
TRUNCATE TABLE dbo.WKT_Balances_IN
TRUNCATE TABLE dbo.Computation_Balances_IN
TRUNCATE TABLE dbo.Balances_IN_Processed
TRUNCATE TABLE RCP_DataExchange.dbo.RCP_Balances_IN_Errors
TRUNCATE TABLE RCP_DataExchange.dbo.RCP_Balances_IN
TRUNCATE TABLE RCP_DataExchange.dbo.Balances_IN
DELETE FROM dbo.Payments_Details            where PaymentID in (select PaymentID from dbo.Payments where UserName = 'Payments_IN stored procedure')
DELETE FROM dbo.Payments_PaymentsAttributes where PaymentID in (select PaymentID from dbo.Payments where UserName = 'Payments_IN stored procedure')
DELETE from dbo.Payments                    where UserName = 'Payments_IN stored procedure'