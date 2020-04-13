--In a new, empty database, returns no records.
SELECT FEATURE_NAME FROM SYS.DM_DB_PERSISTED_SKU_FEATURES; 
GO
--Create a partitioning function, used for table partitioning.
CREATE PARTITION FUNCTION PartitionFunc_TestHorizontalPartitioning (int)
AS RANGE RIGHT FOR VALUES (0,1); 
GO
--Now returns the value "Partitioning"
SELECT FEATURE_NAME FROM SYS.DM_DB_PERSISTED_SKU_FEATURES; 

/*
So SYS.DM_DB_PERSISTED_SKU_FEATURES can be a useful DMV for evaluating edition upgrades or compatibility. 
For more information on the data returned by this DMV, 
visit: https://docs.microsoft.com/sql/relational-databases/system-dynamic-management-views/sys-dm-db-persisted-sku-features-transact-sql. 
For more information on features by edition, 
visit: https://docs.microsoft.com/sql/sql-server/editions-and-components-of-sql-server-version-15.

*/