--From Section Choosing Server Authentication mode

CREATE LOGIN BadPassword WITH PASSWORD = 'Password';

SELECT Name
FROM   sys.sql_logins
WHERE PWDCOMPARE ( 'Password', password_hash) = 1;

DROP LOGIN BadPassword;

--From section Security principals; configuring login sever principals; Configuring and setting up server roles

--Katie is made a domain admin on 2019-01-01, because she is a DBA in good standing
ALTER SERVER ROLE serveradmin ADD MEMBER [domain\katie.sql]
GO
ALTER SERVER ROLE processadmin DROP MEMBER [domain\katie.sql]
GO

--testing a security context and reverting:

--For a domain account, do not include square brackets or the account will not be found
CREATE LOGIN Login1 WITH PASSWORD = 'rt8wkrt98324y2vvc'
USE tempdb
GO
EXECUTE AS LOGIN = 'Login1'; 
SELECT SUSER_SNAME() AS ActingAs, ORIGINAL_LOGIN() AS ActuallyAre;
SELECT * FROM dbo.Table1;
REVERT;

-- sysadmin

USE Master;
GO
--using standard security for simplicity
CREATE LOGIN TestSysadminDeny WITH PASSWORD = 'S3cure1$'
GO
GRANT CONTROL SERVER TO TestSysadminDeny;
DENY VIEW SERVER STATE TO  TestSysadminDeny;
GO
EXECUTE AS LOGIN = 'TestSysadminDeny';
SELECT * FROM sys.dm_exec_cached_plans;
GO
REVERT;
GO

--this will oeverride the DENY
ALTER SERVER ROLE sysadmin ADD MEMBER TestSysadminDeny;

-- dbcreator

USE Master;
GO
--using standard security for simplicity
CREATE LOGIN TestDbcreator WITH PASSWORD = 'S3cure1$'
GO
ALTER SERVER ROLE dbcreator ADD MEMBER TestDbcreator
GO


CREATE DATABASE TestDropSa
ALTER AUTHORIZATION ON DATABASE::TestDropSa TO sa;
GO

--Now, impersonating the TestDbcreator principal, attempt to create, alter, and drop databases.
EXECUTE AS LOGIN = 'TestDbcreator';
CREATE DATABASE TestDrop;
ALTER AUTHORIZATION ON DATABASE::TestDrop TO sa; --This statement fails

--You can, however, change very important settings:
ALTER DATABASE TestDropSa SET SINGLE_USER;
ALTER DATABASE TestDropSa SET READ_COMMITTED_SNAPSHOT ON;

--And you can drop the databases:
DROP DATABASE TestDrop;
DROP DATABASE TestDropSa;
REVERT;


---Custom Server Roles

--Create a new custom server role
CREATE SERVER ROLE SupportViewServer;
GO
--Grant permissions to the custom server role
--Run DMVs, see server information
GRANT VIEW SERVER STATE to SupportViewServer;
--See metadata of any database
GRANT VIEW ANY DATABASE to SupportViewServer;
--Set context to any database
GRANT CONNECT ANY DATABASE to SupportViewServer;
--Permission to SELECT from any data object in any databases
GRANT SELECT ALL USER SECURABLES to SupportViewServer;
GO
--Add the DBA team’s accounts
ALTER SERVER ROLE SupportViewServer ADD MEMBER [domain\Katherine];
ALTER SERVER ROLE SupportViewServer ADD MEMBER [domain\Colby];
ALTER SERVER ROLE SupportViewServer ADD MEMBER [domain\David];
