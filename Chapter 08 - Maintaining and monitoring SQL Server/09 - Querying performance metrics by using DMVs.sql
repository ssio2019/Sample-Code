--This following code sample uses sys.dm_os_performance_counters to return the server total memory, the instance’s current target server memory, total server memory, and page life expectancy:
SELECT Time_Observed = SYSDATETIMEOFFSET()
, OS_Memory_GB   = MAX(convert(decimal(19,3), os.physical_memory_kb/1024./1024.))
, OS_Available_Memory_GB = max(convert(decimal(19,3), sm.available_physical_memory_kb/1024./1024.))
, SQL_Target_Server_Mem_GB = max(CASE counter_name 
    WHEN 'Target Server Memory (KB)' THEN convert(decimal(19,3), cntr_value/1024./1024.) END)
, SQL_Total_Server_Mem_GB = max(CASE counter_name
    WHEN 'Total Server Memory (KB)' THEN convert(decimal(19,3), cntr_value/1024./1024.) END)
, PLE_s = MAX(CASE counter_name WHEN 'Page life expectancy' THEN cntr_value END)
FROM sys.dm_os_performance_counters as pc
CROSS APPLY sys.dm_os_sys_info as os
CROSS APPLY sys.dm_os_sys_memory as sm;

--This code sample divides two metrics to provide the Buffer Cache Hit Ratio:
SELECT Time_Observed = SYSDATETIMEOFFSET(), 
Buffer_Cache_Hit_Ratio = convert(int  , 100 *
    (SELECT cntr_value = convert(decimal (9,1), cntr_value)
    FROM sys.dm_os_performance_counters as pc
    WHERE pc.COUNTER_NAME = 'Buffer cache hit ratio'
    AND pc.OBJECT_NAME like '%:Buffer Manager%')
   /
    (SELECT cntr_value = convert(decimal (9,1), cntr_value)
    FROM sys.dm_os_performance_counters as pc
    WHERE pc.COUNTER_NAME = 'Buffer cache hit ratio base'
    AND pc.OBJECT_NAME like '%:Buffer Manager%'));

--Let’s return to our earlier example of finding page splits where we demonstrated how to find the accumulating value.   The counter_name “Page Splits/sec” is misleading when accessed via the DMV, because it is an incrementing number.
DECLARE @page_splits_Start_ms bigint, @page_splits_Start bigint
, @page_splits_End_ms bigint, @page_splits_End bigint;
SELECT @page_splits_Start_ms = ms_ticks
, @page_splits_Start = cntr_value
FROM sys.dm_os_sys_info CROSS APPLY 
sys.dm_os_performance_counters
WHERE counter_name ='Page Splits/sec'
AND object_name LIKE '%SQL%Access Methods %'; --Find the object that contains page splits
WAITFOR DELAY '00:00:05'; --Duration between samples 5s 
SELECT @page_splits_End_ms = MAX(ms_ticks), 
@page_splits_End = MAX(cntr_value)
FROM sys.dm_os_sys_info CROSS APPLY
sys.dm_os_performance_counters
WHERE counter_name ='Page Splits/sec'
AND object_name LIKE '%SQL%Access Methods%'; --Find the object that contains page splits
SELECT Time_Observed = SYSDATETIMEOFFSET(), 
Page_Splits_per_s = convert(decimal(19,3), 
(@page_splits_End - @page_splits_Start)*1.
/ NULLIF(@page_splits_End_ms - @page_splits_Start_ms,0)); 

--In the code sample that follows, we pull the SQL Server instance’s current CPU utilization percentage and the current server idle CPU percentage for the past few hours.   The remaining CPU percentage can be chalked up to other applications or services running on the server, including other SQL Server instances.
SELECT  [Event_Time] = DATEADD(ms, -1 * (si.cpu_ticks / (si.cpu_ticks/si.ms_ticks) – x.[timestamp]), SYSDATETIMEOFFSET())
, CPU_SQL_pct = bufferxml.value('(./Record/ScedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
, CPU_Idle_pct = bufferxml.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')
FROM (SELECT timestamp, CONVERT(xml, record) AS bufferxml
   FROM sys.dm_os_ring_buffers
   WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR') AS x
CROSS APPLY sys.dm_os_sys_info AS si
ORDER BY [Event_Time] desc;

--PLE
select object_name, counter_name, cntr_value from 
sys.dm_os_performance_counters 
WHERE object_name like '%Buffer Manager%'
AND counter_name = 'Page life expectancy'  

--Page Reads
select object_name, counter_name, cntr_value from 
sys.dm_os_performance_counters
WHERE object_name like '%Buffer Manager%'
AND counter_name = 'Page reads/sec' 

--Batch Requests
select object_name, counter_name, cntr_value from 
sys.dm_os_performance_counters
WHERE object_name like '%SQL Statistics%'
AND counter_name = 'Batch Requests/sec'

--Available Memory
SELECT available_physical_memory_GB = cast(available_physical_memory_kb / 1024. / 1024. as decimal(19,2)) 
, cast(total_physical_memory_kb / 1024. / 1024. as decimal(19,2)) 
from sys.dm_os_sys_memory

--Total Server Memory
select Total_Server_Memory_GB = cntr_value /1024./1024.,* from sys.dm_os_performance_counters
WHERE object_name like '%Memory Manager%'
AND counter_name = 'Total Server Memory (KB)'

--Target Server Memory
select Target_Server_Memory_GB = cntr_value /1024./1024.,* from sys.dm_os_performance_counters
WHERE object_name like '%Memory Manager%'
AND counter_name = 'Target Server Memory (KB)'


