SELECT
   when_observed = sysdatetime()
, s.session_id, r.request_id
, session_status = s.[status] -- running, sleeping, dormant, preconnect
, request_status = r.[status] -- running, runnable, suspended, sleeping, background
, blocked_by = r.blocking_session_id
, database_name = db_name(r.database_id)
, s.login_time, r.start_time
, query_text = CASE
   WHEN r.statement_start_offset = 0
   and r.statement_end_offset= 0 THEN left(est.text, 4000)
   ELSE SUBSTRING (est.[text], r.statement_start_offset/2 + 1,
   CASE WHEN r.statement_end_offset = -1
      THEN LEN (CONVERT(nvarchar(max), est.[text]))
      ELSE r.statement_end_offset/2 - r.statement_start_offset/2 + 1
    END
) END --the actual query text is stored as nvarchar, so we must divide by 2 for the character offsets
, qp.query_plan
, cacheobjtype = LEFT (p.cacheobjtype + ' (' + p.objtype + ')', 35)
, est.objectid
, s.login_name, s.client_interface_name
, endpoint_name = e.name, protocol = e.protocol_desc
, s.host_name, s.program_name
, cpu_time_s = r.cpu_time, tot_time_s = r.total_elapsed_time
, wait_time_s = r.wait_time, r.wait_type, r.wait_resource, r.last_wait_type
, r.reads, r.writes, r.logical_reads --accumulated request statistics
FROM sys.dm_exec_sessions as s
LEFT OUTER JOIN sys.dm_exec_requests as r on r.session_id = s.session_id
LEFT OUTER JOIN sys.endpoints as e ON e.endpoint_id = s.endpoint_id
LEFT OUTER JOIN sys.dm_exec_cached_plans as p ON p.plan_handle = r.plan_handle
OUTER APPLY sys.dm_exec_query_plan (r.plan_handle) as qp
OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) as est
LEFT OUTER JOIN sys.dm_exec_query_stats as stat on stat.plan_handle = r.plan_handle
AND r.statement_start_offset = stat.statement_start_offset
AND r.statement_end_offset = stat.statement_end_offset
WHERE 1=1 --Veteran trick that makes for easier commenting of filters
AND s.session_id >= 50 --retrieve only user spids
AND s.session_id <> @@SPID --ignore myselfthis session
ORDER BY r.blocking_session_id desc, s.session_id asc;
