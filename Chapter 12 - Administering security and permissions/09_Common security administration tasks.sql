----- From section Common security administration tasks

--list logins to replace from database
SELECT   'ALTER USER [' + dp.name COLLATE DATABASE_DEFAULT + ']' +
        ' WITH LOGIN = [' + sp.name + ']; ' AS SQLText
FROM     sys.database_principals AS dp
         LEFT OUTER JOIN sys.server_principals AS sp
             ON dp.sid = sp.sid
WHERE    dp.is_fixed_role = 0
    AND dp.sid NOT IN ( 0x01, 0x01 ) --dbo and guest
    AND sp.name IS NOT NULL --skip users without logins
    AND dp.type_desc = 'SQL_USER' 
ORDER BY dp.name;

--Script to reenable logins
SELECT 'ALTER LOGIN ' + QUOTENAME(name) + ' ENABLE;'
FROM   sys.sql_logins
WHERE  sql_logins.is_disabled = 1
AND name NOT LIKE 'NT SERVICE\%'
AND is_disabled = 0
--Beware: You should not necessarily enable all logins on a server. Make sure 
-- to know the accounts you are enabling…



--Create script for windows logins to transfer
SELECT CONCAT('CREATE LOGIN ', QUOTENAME(name) +
          ' FROM WINDOWS WITH DEFAULT_DATABASE =' + QUOTENAME(default_database_name)+
	  ', DEFAULT_LANGUAGE = '+ QUOTENAME(default_language_name))  + ';'AS CreateTSQL_Source 
FROM sys.server_principals
WHERE type_desc in ('WINDOWS_LOGIN','WINDOWS_GROUP')
AND name NOT LIKE 'NT SERVICE\%'
AND is_disabled = 0
ORDER BY name, type_desc;


--Script server roles
SELECT DISTINCT
 CONCAT('ALTER SERVER ROLE ',  QUOTENAME(R.NAME) , ' ADD MEMBER ' , QUOTENAME(M.NAME) ) AS CREATETSQL
FROM SYS.SERVER_ROLE_MEMBERS AS RM
INNER JOIN SYS.SERVER_PRINCIPALS R ON RM.ROLE_PRINCIPAL_ID = R.PRINCIPAL_ID
INNER JOIN SYS.SERVER_PRINCIPALS M ON RM.MEMBER_PRINCIPAL_ID = M.PRINCIPAL_ID
WHERE R.IS_DISABLED = 0 AND M.IS_DISABLED = 0 -- IGNORE DISABLED ACCOUNTS
AND M.NAME NOT IN ('DBO', 'SA'); -- IGNORE BUILT-IN ACCOUNTS


--Script server level security 
SELECT   RM.state_desc + N' ' + RM.permission_name + CASE WHEN E.name IS NOT NULL
                                                              THEN 'ON ENDPOINT::[' + E.name + '] '
                                                          ELSE ''
                                                     END + N' TO '
         + CAST(QUOTENAME(U.name COLLATE DATABASE_DEFAULT) AS nvarchar(256)) + ';' AS CREATETSQL
FROM     sys.server_permissions AS RM
         INNER JOIN sys.server_principals AS U
             ON RM.grantee_principal_id = U.principal_id
         LEFT OUTER JOIN sys.endpoints AS E
             ON E.endpoint_id = RM.major_id
                 AND RM.class_desc = 'ENDPOINT'
--NOTE: this ignores many of the built in accounts, but if you have made changes to these 
--accounts you may need to make changes to the WHERE clause
WHERE    U.name NOT LIKE '##%' -- IGNORE SYSTEM ACCOUNTS
    AND U.name NOT IN ( 'DBO', 'SA','public' ) -- IGNORE BUILT-IN ACCOUNTS
	AND U.name NOT LIKE 'NT SERVICE%'
	AND U.name NOT LIKE 'NT AUTHORITY%'
ORDER BY RM.permission_name, U.name;
