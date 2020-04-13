USE WideworldImporters;
GO
-- Recommend restoring a fresh copy of WideWorldImporters from https://docs.microsoft.com/sql/samples/wide-world-importers-oltp-install-configure

-- Fill haystack with 3+ million rows
INSERT INTO Sales.InvoiceLines (InvoiceLineID, InvoiceID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice, TaxRate, TaxAmount, LineProfit, ExtendedPrice, LastEditedBy, LastEditedWhen)
SELECT InvoiceLineID = NEXT VALUE FOR [Sequences].[InvoiceLineID], InvoiceID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice, TaxRate, TaxAmount, LineProfit, ExtendedPrice, LastEditedBy, LastEditedWhen
FROM Sales.InvoiceLines;
GO 3 --Run the above three times

-- Insert millions of records for InvoiceID 69776
INSERT INTO Sales.InvoiceLines (InvoiceLineID, InvoiceID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice, TaxRate, TaxAmount, LineProfit, ExtendedPrice, LastEditedBy, LastEditedWhen)
SELECT InvoiceLineID = NEXT VALUE FOR [Sequences].[InvoiceLineID], 69776, StockItemID, Description, PackageTypeID, Quantity, UnitPrice, TaxRate, TaxAmount, LineProfit, ExtendedPrice, LastEditedBy, LastEditedWhen
FROM Sales.invoicelines;
GO 
 
SELECT COUNT(1) FROM sales.InvoiceLines (NOLOCK); -- Should be 3+ million
SELECT COUNT(1) FROM sales.InvoiceLines where InvoiceID = 69776; -- Should be half the table, about 1.8 million
SELECT COUNT(1) FROM sales.InvoiceLines where InvoiceID = 1; -- Should be only a few
GO
--Clear cache, drop other indexes to only test our comparison scenario
DBCC FREEPROCCACHE
DROP INDEX IF EXISTS [NCCX_Sales_InvoiceLines]  ON [Sales].[InvoiceLines];
DROP INDEX IF EXISTS IDX_NC_InvoiceLines_InvoiceID_StockItemID_Quantity ON [Sales].[InvoiceLines];
DROP INDEX IF EXISTS IDX_CS_InvoiceLines_InvoiceID_StockItemID_Quantity ON [Sales].[InvoiceLines];
GO
--Create a rowstore nonclustered index for comparison
CREATE INDEX IDX_NC_InvoiceLines_InvoiceID_StockItemID_Quantity
	ON [Sales].[InvoiceLines] (InvoiceID, StockItemID, Quantity);
GO

--Now that the data is loaded, you can perform the query again for testing
SET STATISTICS TIME ON;

SELECT il.StockItemID, AvgQuantity = AVG(il.quantity)
FROM [Sales].[InvoiceLines] AS il
WHERE il.InvoiceID = 1 -- 8 rows
GROUP BY il.StockItemID;

SET STATISTICS TIME OFF;
GO

SET STATISTICS TIME ON;

SELECT il.StockItemID, AvgQuantity = AVG(il.quantity)
FROM [Sales].[InvoiceLines] AS il
WHERE il.InvoiceID = 69776 --1.8million records
GROUP BY il.StockItemID;

SET STATISTICS TIME OFF;
GO

--Now, let’s create a columnstore index, and watch our analytical-scale query benefit.
--Create a columnstore nonclustered index for comparison
CREATE COLUMNSTORE INDEX IDX_CS_InvoiceLines_InvoiceID_StockItemID_quantity
	ON [Sales].[InvoiceLines] (InvoiceID, StockItemID, Quantity) WITH (ONLINE = ON);
GO

--Perform the query again for testing.
SET STATISTICS TIME ON;

SELECT il.StockItemID, AvgQuantity = AVG(il.quantity)
FROM [Sales].[InvoiceLines] AS il
WHERE il.InvoiceID = 1 -- 8 rows
GROUP BY il.StockItemID;

SET STATISTICS TIME OFF;
GO

SET STATISTICS TIME ON;
--Run the same query as above, but now it will use the columnstore
SELECT il.StockItemID, AvgQuantity = AVG(il.quantity)
FROM [Sales].[InvoiceLines] AS il
WHERE il.InvoiceID = 69776 --1.8million records
GROUP BY il.StockItemID;

SET STATISTICS TIME OFF;
GO

--Cleanup
DROP INDEX IF EXISTS IDX_CS_InvoiceLines_InvoiceID_StockItemID_quantity ON [Sales].[InvoiceLines];
GO
DROP INDEX IF EXISTS IDX_NC_InvoiceLines_InvoiceID_StockItemID_Quantity ON [Sales].[InvoiceLines];
GO