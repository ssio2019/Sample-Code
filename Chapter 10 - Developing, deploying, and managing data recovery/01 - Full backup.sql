--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2020 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 10: DEVELOPING, DEPLOYING, AND MANAGING DATA RECOVERY
-- T-SQL SAMPLE 1
--

BACKUP DATABASE WideWorldImporters
TO DISK = N'C:\SQLData\Backup\SERVER_WWI_FULL_20191218_210912.BAK';
GO