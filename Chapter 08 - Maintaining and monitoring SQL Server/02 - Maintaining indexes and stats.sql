--You can use the performance counter DMV to measure page splits in aggregate on Windows server, as shown here:
SELECT * FROM sys.dm_os_performance_counters WHERE counter_name ='Page Splits/sec';  

--For example, to find the fragmentation level of all indexes on the Sales.Orders table in the WideWorldImporters sample database, you can we could use a query such as the following :
SELECT DB = db_name(s.database_id)
, [schema_name] = sc.name
, [table_name] = o.name
, index_name = i.name
, s.index_type_desc
, s.partition_number -- if the object is partitioned
, avg_fragmentation_pct = s.avg_fragmentation_in_percent
, s.page_count -- pages in object partition
FROM sys.indexes AS i
CROSS APPLY sys.dm_db_index_physical_stats (DB_ID(),i.object_id,i.index_id, NULL, NULL) AS s
INNER JOIN sys.objects AS o ON o.object_id = s.object_id
INNER JOIN sys.schemas AS sc ON o.schema_id = sc.schema_id
WHERE i.is_disabled = 0
AND o.object_id = OBJECT_ID('Sales.Orders');

--For example, if you run the following you will see fragmentation statistics for all databases, all objects, all indexes, and all partitions.
SELECT * FROM sys.dm_db_index_physical_stats(NULL,NULL,NULL,NULL,NULL);

--For the syntax to rebuild the FK_Sales_Orders_CustomerID nonclustered index on the Sales.Orders table with the ONLINE functionality in Enterprise edition, see the following code sample:
ALTER INDEX FK_Sales_Orders_CustomerID
ON Sales.Orders
REBUILD WITH (ONLINE=ON); 

--For example, to rebuild all indexes on the Sales.Orders table, do the following:
ALTER INDEX ALL ON Sales.Orders REBUILD; 

--Demonstrate the WAIT_AT_LOW_PRIORITY option:
ALTER INDEX PK_Sales_OrderLines on [Sales].[OrderLines]
REBUILD WITH (ONLINE=ON (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 0 MINUTES,
ABORT_AFTER_WAIT = SELF)));



--A sample scenario of a paused/resumed index maintenance operation is below:
ALTER INDEX PK_Sales_OrderLines on [Sales].[OrderLines] REBUILD WITH (ONLINE = ON, RESUMABLE = ON);
--From another session, show that the index rebuild is RUNNING with the RESUMABLE option:
SELECT object_name = object_name (object_id), * FROM sys.index_resumable_operations;
--From another session, run the below to pause the operation:
ALTER INDEX PK_Sales_OrderLines on [Sales].[OrderLines] PAUSE;
--Show that the index rebulild is PAUSED
SELECT object_name = object_name (object_id), * FROM sys.index_resumable_operations;
--To resume the index maintenance operation, two options:
--1. Reissue the same index maintenance operation, which will warn you it'll just resume instead.
ALTER INDEX PK_Sales_OrderLines on [Sales].[OrderLines] REBUILD WITH (ONLINE = ON, RESUMABLE = ON);
--Warning: An existing resumable operation with the same options was identified for the same index on 'tablename'. The existing operation will be resumed instead.
--2. Or, issue a RESUME to the same index.
ALTER INDEX PK_Sales_OrderLines on [Sales].[OrderLines] RESUME;


--The RESUMABLE syntax also supports a MAX_DURATION syntax, which has a different mention than the MAX_DURATION syntax used in the ABORT_AFTER_WAIT:
ALTER INDEX PK_Sales_OrderLines on [Sales].[OrderLines]
REBUILD WITH (ONLINE=ON, RESUMABLE=ON, MAX_DURATION = 60 MINUTES );


--The following example presents the syntax to reorganize the PK_Sales_OrderLines index on the Sales.OrderLines table:
ALTER INDEX PK_Sales_OrderLines on [Sales].[OrderLines] REORGANIZE;


--The basic syntax to update the statistics for an individual table is simple:
UPDATE STATISTICS [Sales].[Invoices];  
