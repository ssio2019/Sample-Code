------From section Permissions; Understanding overlapping permissions

CREATE ROLE SalesSchemaRead GRANT SELECT on SCHEMA::sales to SalesSchemaRead;

DENY SELECT on OBJECT::sales.InvoiceLines to SalesSchemaRead;


CREATE USER TestPermissions WITHOUT LOGIN;

ALTER ROLE SalesSchemaRead ADD MEMBER TestPermissions;



USE WideWorldImporters;
GO
EXECUTE AS USER = 'TestPermissions';
SELECT TOP 100 * FROM Sales.Invoices; 
SELECT TOP 100 * FROM Sales.InvoiceLines;
REVERT;


--Msg 229, Level 14, State 5, Line 4
--The SELECT permission was denied on the object 'InvoiceLines', database 'WideWorldImporters', schema 'sales'.

CREATE ROLE SalesSchemaDeny;

DENY SELECT on SCHEMA::sales to SalesSchemaDeny;

ALTER ROLE SalesSchemaDeny ADD MEMBER TestPermissions;


EXECUTE AS USER = 'TestPermissions';
SELECT TOP 100 * FROM Sales.Invoices; 
SELECT TOP 100 * FROM Sales.InvoiceLines;
REVERT;

--Msg 229, Level 14, State 5, Line 4
--The SELECT permission was denied on the object 'Invoices', database 'WideWorldImporters', schema 'sales'.
--Msg 229, Level 14, State 5, Line 5
--The SELECT permission was denied on the object 'InvoiceLines', database 'WideWorldImporters', schema 'sales'.

REVOKE SELECT on SCHEMA::sales to SalesSchemaDeny;
