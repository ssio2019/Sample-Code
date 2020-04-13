--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2019 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 7: UNDERSTANDING TABLE FEATURES
-- T-SQL SAMPLE 7
--
CREATE TYPE CustomerNameType FROM NVARCHAR(100) NOT NULL;
GO

-- Create a database-wide default
CREATE DEFAULT CustomerNameDefault
AS 'NA';
GO