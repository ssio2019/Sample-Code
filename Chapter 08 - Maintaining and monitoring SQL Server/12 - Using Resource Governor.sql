--The sample code that follows defines a classifier function that returns GovGroupReports for all queries coming from two known-fictional reporting servers. 
--You can see in the comments other sample connection identifying functions, with many more options possible.
CREATE FUNCTION dbo.fnCLASSIFIER() RETURNS sysname
WITH SCHEMABINDING AS 
BEGIN
   -- Note that any request that you do not assign a @grp_name value for returns NULL, and is classified into the 'default' group.
DECLARE @grp_name sysname
IF (
--Use built-in functions for connection string properties
    HOST_NAME() IN ('reportserver1','reportserver2')
--OR APP_NAME() IN ('some application') --further samples you can use
--AND SUSER_SNAME() IN ('whateveruser') --further samples you can use
)
   BEGIN
      SET @grp_name = 'GovGroupReports';
    END
RETURN @grp_name 
END; 


--In this example, we create a pool that limits all covered sessions to 50% of the instance’s memory, 
--and a group that limits any single query to 30% of the instance’s memory, 
--and forces the sessions into MAXDOP = 1, overriding any server, database, or query-level setting:
CREATE RESOURCE POOL GovPoolMAXDOP1;
CREATE WORKLOAD GROUP GovGroupReports;
GO
ALTER RESOURCE POOL GovPoolMAXDOP1
WITH (-- MIN_CPU_PERCENT = value
     --,MAX_CPU_PERCENT = value
     --,MIN_MEMORY_PERCENT = value
       MAX_MEMORY_PERCENT = 50
);
GO
ALTER WORKLOAD GROUP GovGroupReports
WITH (
     --IMPORTANCE = { LOW | MEDIUM | HIGH }
      --,REQUEST_MAX_CPU_TIME_SEC = value
      --,REQUEST_MEMORY_GRANT_TIMEOUT_SEC = value
       --,GROUP_MAX_REQUESTS = value
       REQUEST_MAX_MEMORY_GRANT_PERCENT = 30
       , MAX_DOP = 1
)
USING GovPoolMAXDOP1; 


--With the Workload Groups and Resource Pools in place, you are ready to tell Resource Governor to start using your changes.  
-- Register the classifier function with Resource Governor
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION= dbo.fnCLASSIFIER);
--If anything goes awry, you can disable resource governor with the following command, and re-enable with with the same command as above.
--Disable Resource Governor
ALTER RESOURCE GOVERNOR DISABLE;


--After you configure it and turn it on, you can query the status of Resource Governor and the name of the classifier function by using the following sample script:
SELECT rgc.is_enabled, o.name
FROM sys.resource_governor_configuration AS rgc
LEFT OUTER JOIN master.sys.objects AS o
ON rgc.classifier_function_id = o.object_id
          INNER JOIN master.sys.schemas AS s
           ON o.schema_id = s.schema_id; 

--You can query the groups and pools via the DMVs sys.resource_governor_workload_groups and sys.resource_governor_resource_pools. 
--Use the following sample query to observe the number of sessions that have been sorted into groups, noting that group_id = 1 is the internal group, 
--group_id = 2 is the default group, and other groups defined by you, the administrator:
SELECT
    rgg.group_id, rgp.pool_id
, Pool_Name = rgp.name, Group_Name = rgg.name
, session_count= ISNULL(count(s.session_id) ,0)
FROM sys.dm_resource_governor_workload_groups AS rgg
LEFT OUTER JOIN sys.dm_resource_governor_resource_pools AS rgp
ON rgg.pool_id = rgp.pool_id
LEFT OUTER JOIN sys.dm_exec_sessions AS s
ON s.group_id = rgg.group_id
GROUP BY rgg.group_id, rgp.pool_id, rgg.name, rgp.name
ORDER BY rgg.name, rgp.name; 
