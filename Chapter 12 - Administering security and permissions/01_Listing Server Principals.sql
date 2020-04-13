
--get the sid and type of principals 

SELECT name, sid, type_desc
FROM   sys.server_principals;

--List server principals

SELECT name, type_desc, is_disabled
FROM    sys.server_principals
ORDER BY type_desc;

