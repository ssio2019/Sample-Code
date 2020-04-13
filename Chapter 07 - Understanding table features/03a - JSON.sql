--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2019 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 7: UNDERSTANDING TABLE FEATURES
-- T-SQL SAMPLE 3
--

DECLARE @SomeJSON nvarchar(50) = '{ "test": "value" }';

SELECT ISJSON(@SomeJSON) IsValid, JSON_VALUE(@SomeJSON, '$.test') [Status];