CREATE SCHEMA Tools;
GO
CREATE FUNCTION Tools.Bit_Translate
(
	@value bit 
)
RETURNS varchar(5)
as
 BEGIN
	RETURN (CASE WHEN @value = 1 THEN 'True' ELSE 'False' END);
 END;
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140; --SQL Server 2017
 GO
SELECT Tools.Bit_Translate(IsCompressed) AS CompressedFlag,
	       CASE WHEN IsCompressed = 1 THEN 'True' ELSE 'False' END
 FROM   Warehouse.VehicleTemperatures;
GO
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 150; -- SQL Server 2019
 GO
SELECT Tools.Bit_Translate(IsCompressed) AS CompressedFlag,
	       CASE WHEN IsCompressed = 1 THEN 'True' ELSE 'False' END
FROM   Warehouse.VehicleTemperatures;
SELECT COUNT(DISTINCT(CustomerID))
FROM   Sales.Invoices;
SELECT APPROX_COUNT_DISTINCT(CustomerID)
FROM Sales.Invoices;  
