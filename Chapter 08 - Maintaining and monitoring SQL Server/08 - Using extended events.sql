--Retrieve deadlocks from the default extended events session
DECLARE @XELFile nvarchar(256), @XELFiles nvarchar(256)
		, @XELPath nvarchar(256);

--Get the folder path where the system_health .xel files are 
SELECT 	@XELFile = 	CAST(t.target_data as XML)
		.value('EventFileTarget[1]/File[1]/@name', 'NVARCHAR(256)')
FROM sys.dm_xe_session_targets t
	INNER JOIN sys.dm_xe_sessions s 
	ON s.address = t.event_session_address
WHERE s.name = 'system_health' AND t.target_name = 'event_file';

--Provide wildcard path search for all currently retained .xel files
SELECT @XELPath = 
	LEFT(@XELFile, Len(@XELFile)-CHARINDEX('\',REVERSE(@XELFile))) 
SELECT @XELFiles = @XELPath + '\system_health_*.xel';

--Query the .xel files for deadlock reports 
SELECT DeadlockGraph = CAST(event_data AS XML)
	, DeadlockID = Row_Number() OVER(ORDER BY file_name, file_offset)
FROM sys.fn_xe_file_target_read_file(@XELFiles, null, null, null) AS F
WHERE event_data like '<event name="xml_deadlock_report%';


--Here’s a quick, two connection script to produce a deadlock. Open two query connections in SSMS to a testing database.
--You should then be able to use the default system_health Extended Events session to view the details of the deadlock, using the above script.
--Run this script in connection 1:
CREATE TABLE dbo.dead (col1 INT)
INSERT INTO dbo.dead SELECT 1
CREATE TABLE dbo.lock (col1 INT)
INSERT INTO dbo.lock SELECT 1
BEGIN TRAN t1
UPDATE dbo.dead WITH (TABLOCK) SET col1 = 2
--Run this script in connection 2:
BEGIN TRAN t2
UPDATE dbo.lock WITH (TABLOCK) SET col1 = 3
UPDATE dbo.dead WITH (TABLOCK) SET col1 = 3
COMMIT TRAN t2
GO
--Now, back in connection 1: 
UPDATE dbo.lock WITH (TABLOCK) SET col1 = 4
COMMIT TRAN t1
GO
--Within a moment, the session in connection 2 is closed as the victim of a deadlock. 


--The following is a sample T-SQL script to create a startup session that captures autogrowth events to an .xel event file and also a histogram target that counts the number of autogrowth instances per database:
CREATE EVENT SESSION [autogrowths] ON SERVER
ADD EVENT sqlserver.database_file_size_change(
    ACTION(package0.collect_system_time,sqlserver.database_id,sqlserver.database_name,sqlserver.sql_text)),
ADD EVENT sqlserver.databases_log_file_size_changed(
   ACTION(package0.collect_system_time,sqlserver.database_id,sqlserver.database_name,sqlserver.sql_text))
ADD TARGET package0.event_file(--.xel file target
SET filename=N'F:\DATA\autogrowths.xel'),
ADD TARGET package0.histogram(--Histogram target, counting events per database_name
SET filtering_event_name=N'sqlserver.database_file_size_change' ,source=N'database_name',source_type=(0)) --Start session at server startup
WITH (STARTUP_STATE=ON);
GO
--Start the session now
ALTER EVENT SESSION [autogrowths]
ON SERVER STATE = START ; 

--The following sample T-SQL script creates a startup session that captures autogrowth events to an .xel event file and also a histogram target that counts the number of page_splits per database:
CREATE EVENT SESSION [page_splits] ON SERVER
ADD EVENT sqlserver.page_split(
    ACTION(sqlserver.database_name,sqlserver.sql_text))
ADD TARGET package0.event_file(
SET filename=N'page_splits' ,max_file_size=(100)),
ADD TARGET package0.histogram(
SET filtering_event_name=N'sqlserver.page_split' ,source=N'database_id',source_type=(0))
--Start session at server startup
WITH (STARTUP_STATE=ON);
GO
--Start the session now
   ALTER EVENT SESSION [page_splits] ON SERVER STATE = START ; 



