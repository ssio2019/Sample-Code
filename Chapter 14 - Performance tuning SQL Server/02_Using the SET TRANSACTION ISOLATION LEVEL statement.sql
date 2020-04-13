
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT...;
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
COMMIT TRAN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SELECT...
/*
Msg 3951, Level 16, State 1, Line 4
Transaction failed in database 'databasename' because the statement was run under snapshot isolation but the transaction did not start in snapshot isolation. You cannot change the isolation level of the transaction after the transaction has started.
*/
