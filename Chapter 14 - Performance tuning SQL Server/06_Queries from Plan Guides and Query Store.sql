
USE WideWorldImporters;
GO


CREATE OR ALTER PROCEDURE Purchasing.PurchaseOrders_BySupplierId 
@SupplierId int
AS
SELECT PurchaseOrders.PurchaseOrderID,
       PurchaseOrders.SupplierID,
       PurchaseOrders.OrderDate
 FROM   Purchasing.PurchaseOrders
WHERE  PurchaseOrders.SupplierID = @SupplierId;
GO


EXECUTE sp_create_plan_guide   
@name = N' SP-Purchasing.PurchaseOrders_BySupplierId_AddOption',  
@stmt = N'SELECT PurchaseOrders.PurchaseOrderID,
       PurchaseOrders.SupplierID,
       PurchaseOrders.OrderDate
 FROM   Purchasing.PurchaseOrders
WHERE  PurchaseOrders.SupplierID = @SupplierId',  
@type = N'OBJECT',  
@module_or_batch = N'Purchasing.PurchaseOrders$BySupplierId',  
@params = NULL,  --null for object since it is declare in the parameters
@hints = N'OPTION (OPTIMIZE FOR (@SupplierId = 13))';
GO

EXEC sp_control_plan_guide 'DROP', N' SP-Purchasing.  PurchaseOrders_BySupplierId_AddOption';
EXECUTE sp_executesql @stmt = N'SELECT PurchaseOrders.PurchaseOrderID,
		   PurchaseOrders.SupplierID,
		   PurchaseOrders.OrderDate
FROM   Purchasing.PurchaseOrders
WHERE PurchaseOrders.SupplierID = @SupplierId',
@params = N'@SupplierId int',
@SupplierId = 2;
GO

EXECUTE sp_create_plan_guide   
	@name = N'SQL-Purchasing_PurchaseOrders$BySupplierId_NoParallelism',  
	@stmt = 
'SELECT PurchaseOrders.PurchaseOrderID,
		   PurchaseOrders.SupplierID,
		   PurchaseOrders.OrderDate
FROM   Purchasing.PurchaseOrders
WHERE PurchaseOrders.SupplierID = @SupplierId',  
	@type = N'SQL',  
	@module_or_batch = NULL,  
	@params = '@SupplierId int',
	@hints = N'OPTION (OPTIMIZE FOR (@SupplierId = 2))';
GO


SELECT * FROM Sales.Orders AS o
INNER JOIN Sales.OrderLines AS ol
    ON ol.OrderID = o.OrderID
WHERE o.OrderId = 679;
GO

DECLARE @stmt nvarchar(max);  
DECLARE @params nvarchar(max);  
EXEC sp_get_query_template   
    N'SELECT * FROM Sales.Orders AS o
      INNER JOIN Sales.OrderLines AS ol
           ON ol.OrderID = o.OrderID
      WHERE o.OrderId = 679;  ',  
    @stmt OUTPUT,   
    @params OUTPUT  
GO

EXEC sp_create_plan_guide N'TemplateGuide1',   
    @stmt,   
    N'TEMPLATE',   
    NULL,   
    @params,   
GO

ALTER DATABASE [DatabaseOne] SET QUERY_STORE = ON;
GO
ALTER DATABASE WideWorldImporters SET AUTOMATIC_TUNING (FORCE_LAST_GOOD_PLAN = ON );
GO
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF;
GO

