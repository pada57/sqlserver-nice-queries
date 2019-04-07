
Declare @Databasename nvarchar(50)
Declare @SPame nvarchar(50)
SET @Databasename = 'RCP'
SET @SPame = 'Migration_CleanDatabaseByAssetManager'


Declare @ExcludedTables table (Table_Name nvarchar(50))
-- All WKT tables
Insert into @ExcludedTables
SELECT  Table_Name FROM INFORMATION_SCHEMA.TABLES  
      where TABLE_CATALOG = @Databasename 
      and (TABLE_NAME like 'WKT_%' 
            or TABLE_NAME like 'aspnet_%'
            or TABLE_NAME like 'amsfw_%'
            or TABLE_NAME like 'vw_aspnet_%')



SELECT  T.Table_Name as UnreferencedTable
FROM INFORMATION_SCHEMA.TABLES  T
where T.TABLE_CATALOG = @Databasename
and  (SELECT COUNT(*)
            FROM sysobjects o  
            INNER JOIN syscomments c ON c.Id = o.Id  
            WHERE category = 0 AND c.text like '%' + T.Table_Name  + '%'  
            and name = @SPame) = 0
and T.Table_Name not in (Select Table_Name from @ExcludedTables) 
order by T.TABLE_NAME
