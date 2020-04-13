--You should periodically and proactively compare the number of unique key values to the total number of rows in the table and
-- then maintain the number of buckets in a memory-optimized hash index by using the ALTER TABLE/ALTER INDEX/REBUILD commands; for example:

ALTER TABLE [dbo].[Transactions]
ALTER INDEX [IDX_NC_H Transactions_1]
REBUILD WITH (BUCKET_COUNT = 524288);  --will always round up to the nearest power of two
