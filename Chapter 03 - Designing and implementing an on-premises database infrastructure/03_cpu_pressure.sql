SELECT
    AVG(runnable_tasks_count)
FROM
    sys.dm_os_schedulers
WHERE
    status = 'VISIBLE ONLINE';
