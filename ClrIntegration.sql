USE TestDb --RCP
GO
-- Enable CLR INtegration
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO
ALTER DATABASE RCP SET TRUSTWORTHY ON 
ALTER DATABASE TestDb SET TRUSTWORTHY ON 

GO
-- Clr version
select * from sys.dm_clr_properties

-- Clr information
select * from sys.dm_clr_appdomains
select * from sys.dm_clr_loaded_assemblies
select * from sys.dm_clr_tasks


-- Drop if exist
IF  EXISTS (SELECT * FROM sys.assembly_types WHERE name = N'TestSharedType')
    DROP TYPE [dbo].[TestSharedType]
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'HelloWorld')
    DROP PROCEDURE HelloWorld
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TestInputOutput')
    DROP PROCEDURE TestInputOutput
GO
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'TestSendData')
    DROP PROCEDURE TestSendData
GO
IF EXISTS (SELECT name FROM sys.assemblies WHERE name = 'RcpClrStoredProc')
   DROP ASSEMBLY RcpClrStoredProc
GO

-- CREATE ASSEMBLY
CREATE ASSEMBLY RcpClrStoredProc from 'c:\users\sjabbour\documents\visual studio 2012\Projects\RcpClrStoredProc\bin\Debug\RcpClrStoredProc.dll' WITH PERMISSION_SET = UNSAFE  -- SAFE
GO

-- CREATE PROC
CREATE PROCEDURE HelloWorld
@i nchar(25) OUTPUT
AS
EXTERNAL NAME RcpClrStoredProc.HelloWorldProc.HelloWorld
GO
CREATE PROCEDURE TestSendData
AS
EXTERNAL NAME RcpClrStoredProc.HelloWorldProc.SendData
GO
--CREATE PROCEDURE TestInputOutput
--@input AS dbo.AgentHOPInput READONLY
--,@output AS dbo.AgentHOPInput OUTPUT
--AS
--EXTERNAL NAME RcpClrStoredProc.HelloWorldProc.TestInputOutput
--GO
--CREATE TYPE TestSharedType
--EXTERNAL NAME RcpClrStoredProc.TestSharedType

GO
-- Test
DECLARE @text nvarchar(25)
EXEC HelloWorld @text out
PRINT @text

EXEC TestSendData
