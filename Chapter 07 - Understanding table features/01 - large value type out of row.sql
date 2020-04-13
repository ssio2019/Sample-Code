--##############################################################################
--
-- SAMPLE SCRIPTS TO ACCOMPANY "SQL SERVER 2019 ADMINISTRATION INSIDE OUT"
--
-- © 2019 MICROSOFT PRESS
--
--##############################################################################
--
-- CHAPTER 7: UNDERSTANDING TABLE FEATURES
-- T-SQL SAMPLE 1
--

USE WideWorldImporters;
GO

DECLARE @TableName NVARCHAR(776) = N'Purchasing.PurchaseOrders';

-- Turn the option on
EXEC sp_tableoption @TableNamePattern = @TableName
	, @OptionName = 'large value types out of row'
	, @OptionValue = 1;

-- Verify the option setting
SELECT [name], large_value_types_out_of_row
FROM sys.tables
WHERE object_id = OBJECT_ID(@TableName);