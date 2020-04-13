--The following query uses the FILEPROPERTY function to reveal how much data there actually is inside a file reservation
DECLARE @FILEPROPERTY TABLE
( DatabaseName sysname
,DatabaseFileName nvarchar(500)
,FileLocation nvarchar(500)
,FileId int
,[type_desc] varchar(50)
,FileSizeMB decimal(19,2)
,SpaceUsedMB decimal(19,2)
,AvailableMB decimal(19,2)
,FreePercent decimal(19,2) );
INSERT INTO @FILEPROPERTY
exec sp_MSforeachdb  'USE [?]; 
SELECT 
  Database_Name					= d.name
, Database_Logical_File_Name	= df.name
, File_Location					= df.physical_name
, df.File_ID
, df.type_desc
, FileSize_MB		= CAST(size/128.0 as Decimal(19,2))
, SpaceUsed_MB		= CAST(CAST(FILEPROPERTY(df.name, ''SpaceUsed'') AS int)/128.0 AS decimal(19,2))
, Available_MB		= CAST(size/128.0 - CAST(FILEPROPERTY(df.name, ''SpaceUsed'') AS int)/128.0 AS decimal(19,2))
, FreePercent		= CAST((((size/128.0) - (CAST(FILEPROPERTY(df.name, ''SpaceUsed'') AS int)*8/1024.0)) / (size*8/1024.0) ) * 100. AS decimal(19,2))
 FROM sys.database_files as df
 CROSS APPLY sys.databases as d
 WHERE d.database_id = DB_ID();'
SELECT * FROM @FILEPROPERTY
WHERE SpaceUsedMB is not null
ORDER BY FreePercent asc; --Find files with least amount of free space at top

--A following sample script of this process assumes a preceding transaction log backup has been taken to truncate the database transaction log,
--and that the database log file is mostly empty. It also grows the transaction log file backup to an example size of 9 GB (9,216 MB or 9,437,184 KB).
-- Note the intermediate step of growing the file first to 8000MB, then to its intended size.
USE [WideWorldImporters];
--TRUNCATEONLY returns all free space to the OS
DBCC SHRINKFILE (N'WWI_Log' , 0, TRUNCATEONLY);
GO
USE [master];
ALTER DATABASE [WideWorldImporters]
MODIFY FILE ( NAME = N'WWI_Log', SIZE = 8192000KB );
ALTER DATABASE [WideWorldImporters]
MODIFY FILE ( NAME = N'WWI_Log', SIZE = 9437184KB );
GO
