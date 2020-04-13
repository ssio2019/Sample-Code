--Consider setting the TARGET_RECOVERY_TIME database configuration to 60 seconds to match the default for all databases 
-- created in SQL Server 2016 or higher, as shown here:
ALTER DATABASE [database_name] SET TARGET_RECOVERY_TIME = 60 SECONDS;

