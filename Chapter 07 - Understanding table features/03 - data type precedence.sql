--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2019 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 7: UNDERSTANDING TABLE FEATURES
-- T-SQL SAMPLE 4
--

DECLARE @MyDate datetime2(0) = '2019-12-22T20:05:00';
DECLARE @TheirString varchar(10) = '2019-12-20';
SELECT DATEDIFF(MINUTE, @TheirString, @MyDate);