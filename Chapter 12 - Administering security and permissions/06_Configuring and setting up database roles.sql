------From section Security principals; Configuring database principals; Configuring and setting up database roles

--dbowner

CREATE USER fred WITHOUT LOGIN;
ALTER ROLE db_owner ADD MEMBER fred;
DENY SELECT ON Sales.BuyingGroups TO fred;
GO
EXECUTE AS USER = 'fred';
SELECT *
FROM test;


EXECUTE AS USER = 'dbo'
SELECT *
FROM test
GO
REVERT; REVERT; --Revert twice, once to get back to fred, and another to get back to your security context.

GO

CREATE ROLE ALLPowerful;
ALTER ROLE db_owner ADD MEMBER allPowerful;


--Creating custom database roles

--Create a new custom database role
USE WideWorldImporters;
GO
-- Create the database role
CREATE ROLE WebsiteExecute AUTHORIZATION dbo;
GO
-- Grant access rights to a specific schema in the database
GRANT EXECUTE ON Schema::Website TO WebsiteExecute;
GO


CREATE ROLE ReadOneTable AUTHORIZATION dbo;

ALTER ROLE db_owner ADD MEMBER ReadOneTable;

--Using role membership to handle environment differences

CREATE ROLE SalesSchemaRead;

GRANT SELECT ON SCHEMA::Sales TO SalesSchemaRead;