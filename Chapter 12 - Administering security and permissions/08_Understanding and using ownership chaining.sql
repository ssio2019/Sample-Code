------From section Permissions; Understanding and using ownership chaining

--A demonstration of permissions with views, stored procedures, and functions

USE tempdb;
GO
CREATE USER TestOwnershipChaining WITHOUT LOGIN;
GO
CREATE SCHEMA Demo;
GO
CREATE TABLE Demo.Sample (
SampleId INT IDENTITY (1,1) NOT NULL CONSTRAINT PKOwnershipChain PRIMARY KEY,
Value NVARCHAR(10) );
GO
INSERT INTO Demo.Sample (Value) VALUES ('Value');
GO 2 --runs this batch 2 times so we get two rows

--Test permissions using a view

CREATE VIEW Demo.SampleView 
AS
        SELECT Value AS ValueFromView 
        FROM Demo.Sample;
GO
GRANT SELECT ON Demo.SampleView TO TestOwnershipChaining;
GO


EXECUTE AS USER = 'TestOwnershipChaining';
SELECT * FROM Demo.Sample;
REVERT;

--Msg 229, Level 14, State 5, Line 26
--The SELECT permission was denied on the object 'Sample', database 'tempdb', schema 'Demo'.

EXECUTE AS USER = 'TestOwnershipChaining';
SELECT * FROM Demo.SampleView;
REVERT;

--Test permissions using a stored procedure

CREATE PROCEDURE Demo.SampleProcedure AS
BEGIN
SELECT Value AS ValueFromProcedure
FROM Demo.Sample;
END
GO

GRANT EXECUTE ON Demo.SampleProcedure to TestOwnershipChaining;
EXECUTE AS USER = 'TestOwnershipChaining';
EXEC Demo.SampleProcedure;
REVERT; 


CREATE PROC Demo.SampleProcedure_Dynamic AS
BEGIN
DECLARE @sql nvarchar(max)
SELECT @sql = 'SELECT Value as ValueFromProcedureDynamic
                            FROM Demo.Sample;';
EXEC sp_executesql @SQL;
END
GO
GRANT EXECUTE ON Demo.SampleProcedure_Dynamic to TestOwnershipChaining;



EXECUTE AS USER = 'TestOwnershipChaining';
EXEC Demo.SampleProcedure_Dynamic;
REVERT; 


CREATE USER ElevatedRights WITHOUT LOGIN; 
GRANT SELECT ON OBJECT::Demo.Sample TO ElevatedRights;
GO

CREATE OR ALTER PROC Demo.SampleProcedure_Dynamic 
WITH EXECUTE AS 'ElevatedRights' 
AS
BEGIN
DECLARE @sql nvarchar(1000)
SELECT @sql = 'SELECT Value as ValueFromProcedureDynamic
               FROM Demo.Sample;';
EXEC sp_executesql @SQL;
END
GO

EXECUTE AS USER = 'TestOwnershipChaining';
EXEC Demo.SampleProcedure_Dynamic;
REVERT;


--Access a table even when SELECT is denied

DENY SELECT ON Demo.Sample TO TestOwnershipChaining;
GO

EXECUTE AS USER = 'TestOwnershipChaining';
SELECT * FROM Demo.SampleView --test the view
GO
EXEC Demo.SampleProcedure; --test the stored procedure
GO
EXEC Demo.SampleProcedure_Dynamic; --test the stored procedure
GO
REVERT;
GO

--rename the table, with may be complicated by things like
--schemabound views
EXEC sp_rename 'Demo.Sample', 'SampleNewName'
GO

CREATE VIEW Demo.Sample
AS
	SELECT SampleId, Value
	FROM   Demo.SampleNewName
	WHERE IS_MEMBER('db_owner') = 1;
GO