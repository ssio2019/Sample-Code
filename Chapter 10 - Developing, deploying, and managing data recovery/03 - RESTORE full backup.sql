--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2020 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 10: DEVELOPING, DEPLOYING, AND MANAGING DATA RECOVERY
-- T-SQL SAMPLE 3
--

RESTORE DATABASE WideWorldImporters
FROM DISK = N'C:\SQLData\Backup\SERVER_WideWorldImporters_FULL_20190918_210912.BAK'
WITH
MOVE N'WideWorldImporters' TO N'C:\SQLData\WWI.mdf',
MOVE N'WideWorldImporters_log' TO N'C:\SQLData\WWI.ldf',
STATS = 5,
RECOVERY;
GO