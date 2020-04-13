--Starting with SQL Server 2016 SP1, you can check whether the Lock Pages in Memory permission has been granted to the SQL Server Database Engine service:

SELECT sql_memory_model_Desc 
FROM sys.dm_os_sys_info 

-- Output interpretation:
-- CONVENTIONAL = Lock Pages in Memory privilege is not granted
-- LOCK_PAGES = Lock Pages in Memory privilege is granted
-- LARGE_PAGES = Lock Pages in Memory privilege is granted in Enterprise mode with Trace Flag 834 ON
