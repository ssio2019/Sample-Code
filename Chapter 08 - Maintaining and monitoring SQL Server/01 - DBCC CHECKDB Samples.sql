--This can reduce the duration of the integrity check by skipping checks on   nonclustered rowstore and columnstore indexes. It is not recommended.
DBCC CHECKDB (databasename, NOINDEX);

/*
--Caution!
DBCC CHECKDB (databasename) WITH REPAIR_REBUILD;
*/
/*
--Example usage: (last resort only, not recommended!)
--Caution!
ALTER DATABASE WorldWideImporters SET EMERGENCY, SINGLE_USER;
DBCC CHECKDB(‘WideWorldImporters’, REPAIR_ALLOW_DATA_LOSS);
ALTER DATABASE WorldWideImporters SET MULTI_USER;
*/

--This suppresses informational status messages and returns only errors.
DBCC CHECKDB (databasename) WITH NO_INFOMSGS;

--This does not provide an estimate of the duration of a CHECKDB (without other parameters), only an amount of space required in TempDB.
DBCC CHECKDB (databasename) WITH ESTIMATEONLY;

--Similar to limiting the Maximum Degrees of Parallelism in other areas of SQL Server, this option limits the CHECKDB operation’s parallelism
--Example usage, combined with the earlier NO_INFOMSGS to show multiple parameters:
DBCC CHECKDB (databasename) WITH NO_INFOMSGS, MAXDOP = 0;

--You can retrieve the latest good known execution date of DBCC CHECKDB from the undocumented but well-known command DBCC DBINFO. 
--One of the fields returned by this query is ‘dbi_dbccLastKnownGood’. 
DBCC DBINFO ([databasename]) WITH TABLERESULTS;

--Or, use this snippet to review all databases in a SQL instance, leveraging another undocumented stored procedure, 
--sp_msforeachdb, which cursors through each database, substituting the database name for the ‘?’ character:
EXEC sp_MSforeachdb '
--Table variable to capture the DBCC DBINFO output, look for the field we want in each database output
DECLARE @DBCC_DBINFO TABLE (ParentObject VARCHAR(255) NOT NULL, [Object] VARCHAR(255)  NOT NULL, [Field] VARCHAR(255) NOT NULL INDEX idx_dbinfo_field CLUSTERED, [Value] VARCHAR(255));
INSERT INTO @DBCC_DBINFO EXECUTE ("DBCC DBINFO ([?]) WITH TABLERESULTS");
SELECT ''?'', [Value] FROM @DBCC_DBINFO WHERE Field = ''dbi_dbccLastKnownGood'';
';

--Recovering from database transaction log file corruption
/*
--Caution!
ALTER DATABASE WorldWideImporters SET EMERGENCY, SINGLE_USER;
ALTER DATABASE WorldWideImporters REBUILD LOG
ON (NAME=WWI_Log, FILENAME='F:\DATA\WideWorldImporters_new.ldf');
ALTER DATABASE WorldWideImporters SET MULTI_USER;
*/