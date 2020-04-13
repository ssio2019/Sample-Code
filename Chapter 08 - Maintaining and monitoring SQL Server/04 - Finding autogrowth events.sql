-- To view and analyze autogrowth events faster, and for all databases simultaneously, you can query the SQL Server instance’s default trace yourself. 
SELECT
DB = g.DatabaseName
, Logical_File_Name = mf.name
, Physical_File_Loc = mf.physical_name
, mf.type
-- The size in MB (converted from the number of 8KB pages) the file increased.
, EventGrowth_MB = convert(decimal(19,2),g.IntegerData*8/1024.)
, g.StartTime --Time of the autogrowth event
-- Length of time (in seconds) necessary to extend the file.
, EventDuration_s = convert(decimal(19,2),g.Duration/1000./1000.)
, Current_Auto_Growth_Set = CASE
WHEN mf.is_percent_growth = 1
   THEN CONVERT(char(2), mf.growth) + '%'
   ELSE CONVERT(varchar(30), mf.growth*8./1024.) + 'MB'
END
, Current_File_Size_MB = CONVERT(decimal(19,2),mf.size*8./1024.)
, d.recovery_model_desc
FROM fn_trace_gettable(
(select substring((SELECT path
FROM sys.traces WHERE is_default =1), 0, charindex('\log_',
(SELECT path FROM sys.traces WHERE is_default =1),0)+4)
+ '.trc'), default) g
INNER JOIN sys.master_files mf
ON mf.database_id = g.DatabaseID
AND g.FileName = mf.name
INNER JOIN sys.databases d
ON d.database_id = g.DatabaseID
ORDER BY StartTime desc;  
