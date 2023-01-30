USE MASTER
GO
SET QUOTED_IDENTIFIER ON
GO
SET ARITHABORT ON
GO  

DECLARE @DBName NVARCHAR(255),@LogicalFileName NVARCHAR(255),@DBRecoveryDesc Varchar(200)  

DECLARE DatabaseList CURSOR
FOR
SELECT name,recovery_model_desc
FROM sys.databases
WHERE state_desc = 'ONLINE'
AND is_read_only = 0
and database_id>4
ORDER BY name  

OPEN DatabaseList
FETCH NEXT FROM DatabaseList INTO @DBName,@DBRecoveryDesc
WHILE @@FETCH_STATUS = 0
BEGIN   

SET @LogicalFileName=(SELECT top 1 name FROM sys.master_files AS mf WHERE DB_NAME(database_id)=@DBName and type_desc='LOG')  

If @DBRecoveryDesc='Full'
Begin
     Print('Use ['+@DBName+'] 
            GO  

       ALTER DATABASE ['+@DBName+'] SET RECOVERY SIMPLE WITH NO_WAIT
       GO   
	   CHECKPOINT
	   GO
        DBCC SHRINKFILE ('''+@LogicalFileName+''',10)  
        GO  
        ALTER DATABASE ['+@DBName+'] SET RECOVERY FULL WITH  NO_WAIT
        GO 
        ')  
--Print '----------------------------------------------------------- '
END  

If @DBRecoveryDesc='Simple'
Begin
     Print('Use ['+@DBName+']
            GO  
			CHECKPOINT
			GO
        DBCC SHRINKFILE ('''+@LogicalFileName+''',10)    
        GO    
 ')
--Print '----------------------------------------------------------- '

END

     FETCH NEXT FROM DatabaseList INTO @DBName,@DBRecoveryDesc
  END  
CLOSE DatabaseList
DEALLOCATE DatabaseList