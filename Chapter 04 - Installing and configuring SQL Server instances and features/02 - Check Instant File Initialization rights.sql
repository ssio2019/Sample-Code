--You can verify the current setting for Instant File Initialization in the sys.dm_server_services dynamic management view:
SELECT servicename, instant_file_initialization_enabled 
FROM sys.dm_server_services
WHERE filename LIKE '%sqlservr.exe%';