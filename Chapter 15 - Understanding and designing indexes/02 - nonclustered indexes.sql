--When creating new nonclustered indexes for a table you must always compare the index to existing indexes. 
-- The order of the key of the index matters. In Transact-SQL (T-SQL), this looks like this:
CREATE NONCLUSTERED INDEX IDX_NC_InvoiceLines_InvoiceID_StockItemID
ON [Sales].[InvoiceLines] (InvoiceID, StockItemID);

--Note that the second index’s keys are in a different order. This is physically and logically a different structure than the first index.
CREATE NONCLUSTERED INDEX IDX_NC_InvoiceLines_InvoiceID_StockItemID
ON [Sales].[InvoiceLines] (InvoiceID, StockItemID);
CREATE NONCLUSTERED INDEX IDX_NC_InvoiceLines_StockItemID_InvoiceID
ON [Sales].[InvoiceLines] (StockItemID, InvoiceID);

--If queries frequently call for data to be sorted by a column in descending order,
-- which may be common for queries looking for the most recent data, you could provide that key value like this:
CREATE INDEX IDX_NC_InvoiceLines_InvoiceID_StockItemID
ON [Sales].[InvoiceLines] (InvoiceID DESC, StockItemID);

--These two indexes overlap
CREATE INDEX IDX_NC_InvoiceLines_InvoiceID_StockItemID_UnitPrice_Quantity
ON [Sales].[InvoiceLines] (InvoiceID, StockItemID, UnitPrice, Quantity);
CREATE INDEX IDX_NC_InvoiceLines_InvoiceID_StockItemID
ON [Sales].[InvoiceLines] (InvoiceID, StockItemID);

--You can view the page_count, record_count, space_used statistics,
-- and more for each level of a B+tree by using the DETAILED mode of the sys.dm_db_index_ physical_stats dynamic management function. 
SELECT * FROM sys.dm_db_index_physical_stats
(DB_ID(),   object_id('Sales.Invoices'), null , null, 'DETAILED');

--Consider the following query and execution plan (Figure 10-1) from the WideWorldImporters database:
SELECT CustomerID, AccountsPersonID
FROM [Sales].[Invoices]
WHERE CustomerID = 832;

--Here is the code of the nonclustered index FK_Sales_Invoices_ CustomerID, named   because it is for CustomerID, a foreign key reference:
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_CustomerID] ON [Sales].[Invoices]
( [CustomerID] ASC )
ON [USERDATA];

--To remove the Key Lookup, let’s add an included column to the nonclustered index, so that the query can retrieve all the data it needs from a single object:
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_CustomerID] ON [Sales].[Invoices]
( [CustomerID] ASC )
INCLUDE ( [AccountsPersonID] )
WITH (DROP_EXISTING = ON)
ON [USERDATA];

--A filter can be added to an index easily, for example:
CREATE INDEX [IX_Application_People_IsEmployee]
ON [Application].[People]([IsEmployee])
WHERE IsEmployee = 1;

