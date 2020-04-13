-------Examples From sections Understanding isolation levels and concurrency

-----Understanding and handling common concurrency scenarios

--** Note, in all of these examples, transaction 1 and transaction 2 should be different connections to simulate contention

USE tempdb; --Or any database if you wish to keep the example around longer than a reboot


--Understanding concurrency: two requests updating the same rows

CREATE SCHEMA Demo;
GO

CREATE TABLE Demo.RC_Test (Type int);
INSERT INTO Demo.RC_Test VALUES (0),(1);
GO


--Transaction 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION; 
UPDATE Demo.RC_Test SET Type = 2
WHERE  Type = 1;

--Transaction 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE Demo.RC_Test SET Type = 3
WHERE  TYPE = 2;
GO

--Transaction 1
COMMIT;

--Understanding concurrency: a write blocks a read

CREATE TABLE Demo.RC_Test_Write_V_Read (Type int);
INSERT INTO Demo.RC_Test_Write_V_Read VALUES (0),(1);
GO

--Transaction 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION; 
UPDATE Demo.RC_Test_Write_V_Read SET Type = 2
WHERE  Type = 1;
GO

--Transaction 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT Type 
FROM   Demo.RC_Test_Write_V_Read 
WHERE  Type = 2;
GO

--Transaction 1
COMMIT;


--Understanding concurrency: nonrepeatable reads

CREATE TABLE Demo.RR_Test (Type int);
INSERT INTO Demo.RR_Test VALUES (0),(1);
GO

--Transaction 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION 
SELECT Type
FROM   Demo.RR_Test
WHERE  TYPE = 1;
GO

--Transaction 2
BEGIN TRANSACTION;
UPDATE Demo.RR_Test
SET  Type = 2
WHERE Type = 1;
GO

--Transaction 1
SELECT Type
FROM   Demo.RR_Test
WHERE  TYPE = 1;

--Transaction 2
COMMIT TRANSACTION;

 --Transaction 1
COMMIT TRANSACTION;

--Understanding concurrency: preventing a nonrepeatable read

CREATE TABLE Demo.RR_Test_Prevent (Type int);
INSERT INTO Demo.RR_Test_Prevent VALUES (0),(1);
GO

--Transaction 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT Type
FROM   Demo.RR_Test_Prevent
WHERE  TYPE = 1;
GO

--Transaction 2
BEGIN TRANSACTION;
UPDATE Demo.RR_Test_Prevent
SET  Type = 2
WHERE Type = 1;

--Transaction 1
COMMIT TRANSACTION;

--Transaction 2
COMMIT TRANSACTION;

--Understanding concurrency: experiencing phantom reads

CREATE TABLE Demo.PR_Test (Type int);
INSERT INTO Demo.PR_Test VALUES (0),(1);
GO

--Transaction 1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION; 
SELECT Type
FROM   Demo.PR_Test
WHERE  Type = 1;
GO

--Transaction 2
INSERT INTO Demo.PR_Test(Type)
VALUES(1);
GO

--Transaction 1
SELECT Type
FROM   Demo.PR_Test
WHERE  Type = 1;
GO

--Transaction 1
COMMIT TRANSACTION;
GO



--Understanding concurrency: preventing phantom reads


CREATE TABLE Demo.PR_Test_Prevent (Type int);
INSERT INTO Demo.PR_Test_Prevent VALUES (0),(1);
GO


 --Transaction 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION; 
SELECT Type
FROM   Demo.PR_Test_Prevent
WHERE  Type = 1;
GO

--Transaction 2
INSERT INTO Demo.PR_Test_Prevent(Type)
VALUES(1);
GO

--Transaction 1
SELECT Type
FROM   Demo.PR_Test_Prevent
WHERE  Type = 1;
GO

--Transaction 1
COMMIT TRANSACTION;;

--Transaction 2
COMMIT TRANSACTION;



-----Understanding concurrency: accessing data in SNAPSHOT isolation level

CREATE TABLE Demo.SS_Test (Type int);
INSERT INTO Demo.SS_Test VALUES (0),(1);

--Transaction 1
BEGIN TRANSACTION 
UPDATE Demo.SS_Test
SET  Type = 2
WHERE Type = 1;
GO

--Transaction2
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
GO

--Transaction 2
SELECT Type
FROM   Demo.SS_Test
WHERE  Type = 1;
GO

--Transaction 1
COMMIT TRANSACTION;
GO

--Transaction 2
SELECT Type
FROM   Demo.SS_Test
WHERE  Type = 1;
GO

--Transaction 2
ROLLBACK TRANSACTION;
GO

--Understanding update operations in SNAPSHOT isolation level

--** Note, these examples must be in a database other than tempdb


--change databasename to the datatabase you need to change
ALTER DATABASE databasename SET ALLOW_SNAPSHOT_ISOLATION ON;
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

ALTER DATABASE databasename SET READ_COMMITTED_SNAPSHOT ON;



CREATE TABLE Demo.SS_Update_Test 
(Type int CONSTRAINT PKSS_Update_Test PRIMARY KEY,
 Value nvarchar(10));
INSERT INTO Demo.SS_Update_Test VALUES (0,'Zero'),(1,'One'),(2,'Two'),(3,'Three');
GO

--Transaction 1
BEGIN TRANSACTION ;
UPDATE Demo.SS_Update_Test
SET  Value = 'Won'
WHERE Type = 1;
GO

--Transaction 2
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION 
UPDATE Demo.SS_Update_Test
SET  Value = 'Wun'
WHERE Type = 1;
GO

--Transaction 1
COMMIT TRANSACTION;
GO
