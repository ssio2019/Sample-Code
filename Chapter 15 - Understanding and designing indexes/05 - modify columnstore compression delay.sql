--Changing the COMPRESSION_DELAY setting of the index, unlike many other index settings, does
--not require a rebuild of the index, and you can change it at any time; for example:
ALTER INDEX [NCCX_Sales_InvoiceLines]
ON [Sales].[InvoiceLines]
SET (COMPRESSION_DELAY = 10 MINUTES);