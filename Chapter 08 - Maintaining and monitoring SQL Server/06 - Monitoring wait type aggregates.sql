--This code sample shows how the DMV returns one row per session, per wait type experienced, for user sessions:
SELECT * FROM sys.dm_exec_session_wait_stats AS wt  ;

--We can view aggregate wait types at the instance level with the sys.dm_os_wait_stats DMV. This is the same as sys.dm_exec_session_wait_stats, but without the session_id, which includes all activity in the SQL Server instance, without any granularity to database, query, timeframe, and so on. This can be useful for getting the “big picture,” but it is limited over long spans of time because the wait_time_ms counter accumulates, as illustrated here:
SELECT TOP (25)
  wait_type
, wait_time_s = wait_time_ms / 1000.
, Pct = 100. * wait_time_ms/nullif(sum(wait_time_ms) OVER(),0)
, avg_ms_per_wait = wait_time_ms / nullif(waiting_tasks_count,0)
FROM sys.dm_os_wait_stats as wt ORDER BY Pct desc;
--Over time, the wait_time_ms numbers will be so large for certain wait types, that trends or changes in wait type accumulations rates will be mathematically difficult to see. You want to use the wait stats to keep a close eye on server performance as it trends and changes over time, so you need to capture these accumulated wait statistics in chunks of time, such as one day or one week. 
--Script to setup capturing these statistics over time
CREATE TABLE dbo.sys_dm_os_wait_stats
(    id int NOT NULL IDENTITY(1,1)
,    datecapture datetimeoffset(0) NOT NULL
,    wait_type nvarchar(512) NOT NULL
,    wait_time_s decimal(19,1) NOT NULL
,    Pct decimal(9,1) NOT NULL
,    avg_ms_per_wait decimal(19,1) NOT NULL
,    CONSTRAINT PK_sys_dm_os_wait_stats PRIMARY KEY CLUSTERED (id)
);
--This part of the script should be in a SQL Agent job, run regularly
INSERT INTO
dbo.sys_dm_os_wait_stats 
(datecapture, wait_type, wait_time_s, Pct, avg_ms_per_wait)
SELECT 
datecapture = SYSDATETIMEOFFSET()
, wait_type
, wait_time_s = convert(decimal(19,1), round( wait_time_ms / 1000.0,1))
, Pct = wait_time_ms/ nullif(sum(wait_time_ms) OVER(),0)
, avg_ms_per_wait = wait_time_ms / nullif(waiting_tasks_count,0)
FROM sys.dm_os_wait_stats wt
WHERE wait_time_ms > 0
ORDER BY wait_time_s;
--Using the metrics returned above, you can calculate the difference between always-ascending wait times and counts to determine the counts between intervals. You can customize the schedule for this data to be captured in tables, building your own internal wait stats reporting table.
--The sys.dm_os_wait_stats DMV is reset and all accumulated metrics are lost upon restart of the SQL Server service, but you can also clear them manually if you desire. Understandably, this would clear the statistics for the SQL instance. Here is a sample script of how you can capture wait statistics at any interval:
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR); --Reset the accumulated statistics for the whole instance

--return potentially useful information about the object in contention when PAGE blocking is present:
SELECT r.request_id, pi.database_id, pi.file_id, pi.page_id, pi.object_id, pi.page_type_desc, pi.index_id, pi.page_level, rows_in_page = pi.slot_count  
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.fn_PageResCracker (r.page_resource) AS  prc
CROSS APPLY sys.dm_db_page_info(r.database_id, prc.file_id, prc.page_id, 'DETAILED') AS pi;

--We can view aggregate wait types at the instance level with the sys.dm_os_wait_stats DMV, now with the WHERE clause of probably innocuous wait types.
--You may find many more wait types worth ignoring in your workload.
SELECT TOP (25)
  wait_type
, wait_time_s		= wait_time_ms / 1000.
, Pct				= 100. * wait_time_ms/nullif(sum(wait_time_ms) OVER(), 0)
, avg_ms_per_wait	=	wait_time_ms / nullif(waiting_tasks_count,0)
FROM sys.dm_os_wait_stats as wt 
WHERE
    wt.wait_type NOT LIKE '%SLEEP%' --can be safely ignored, sleeping
AND wt.wait_type NOT LIKE 'BROKER%' -- internal process
AND wt.wait_type NOT LIKE '%XTP_WAIT%' -- for memory-optimized tables
AND wt.wait_type NOT LIKE '%SQLTRACE%' -- internal process
AND wt.wait_type NOT LIKE 'QDS%' -- asynchronous Query Store data
AND wt.wait_type NOT IN ( -- common benign wait types
'CHECKPOINT_QUEUE'
,'CLR_AUTO_EVENT','CLR_MANUAL_EVENT' ,'CLR_SEMAPHORE'
,'DBMIRROR_DBM_MUTEX','DBMIRROR_EVENTS_QUEUE','DBMIRRORING_CMD'
,'DIRTY_PAGE_POLL'
,'DISPATCHER_QUEUE_SEMAPHORE'
,'FT_IFTS_SCHEDULER_IDLE_WAIT','FT_IFTSHC_MUTEX'
,'HADR_FILESTREAM_IOMGR_IOCOMPLETION'
,'KSOURCE_WAKEUP'
,'LOGMGR_QUEUE'
,'ONDEMAND_TASK_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH'
,'XE_DISPATCHER_WAIT','XE_TIMER_EVENT'
--Ignorable HADR waits
, 'HADR_WORK_QUEUE'
,'HADR_TIMER_TASK'
,'HADR_CLUSAPI_CALL');

--You may find many more wait types worth ignoring in your workload. Add them here.
)
ORDER BY Pct desc;