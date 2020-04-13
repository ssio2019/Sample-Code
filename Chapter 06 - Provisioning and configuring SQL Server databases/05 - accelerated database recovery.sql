--New for SQL Server 2019, Accelerated Database Recovery (ADR) does not appear in the Database Properties page of SSMS as of this writing, nor is it enabled by default. ADR can be enabled with a T-SQL statement:
ALTER DATABASE whatever SET ACCELERATED_DATABASE_RECOVERY = ON;

