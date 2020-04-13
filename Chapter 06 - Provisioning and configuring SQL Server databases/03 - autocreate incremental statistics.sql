Use [WideWorldImporters]
--To affect existing statistics objects on tables on tables with partitions, you should update the statistics objects to include the INCREMENTAL = ON parameter, as shown here:
UPDATE STATISTICS [Purchasing].[SupplierTransactions] [CX_Purchasing_SupplierTransactions] WITH RESAMPLE, INCREMENTAL = ON;
--You should also, when applicable, update any manual scripts you have implemented to update statistics to use the ON PARTITIONS parameter. In the catalog view sys.stats, the is_incremental column will equal 1 if the statistics were created incrementally, as demonstrated here:
UPDATE STATISTICS  [Purchasing].[SupplierTransactions] [CX_Purchasing_SupplierTransactions] WITH RESAMPLE ON PARTITIONS (1);
