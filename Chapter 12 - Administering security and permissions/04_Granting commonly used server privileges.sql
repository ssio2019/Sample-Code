--From section Security principals; configuring login sever principals; Granting commonly used server privileges

USE master
CREATE LOGIN ListEffectivePermissions WITH PASSWORD = 'S3cure#';
GRANT CONNECT ANY DATABASE TO ListEffectivePermissions;


EXECUTE AS LOGIN = 'ListEffectivePermissions';
SELECT permissions.permission_name
FROM    fn_my_permissions(NULL, 'SERVER') AS permissions 
REVERT;


--just example syntax, not executable as is:

GRANT VIEW SERVER STATE TO [server_principal]

GRANT CONNECT ANY DATABASE TO [server_principal]

GRANT SELECT ALL USER SECURABLES TO [server_principal]

GRANT CONTROL SERVER TO [server_principal]

GRANT IMPERSONATE ON LOGIN::[server_principal] TO [server_principal]

GRANT ALTER ANY EVENT SESSION TO [server_principal]

GRANT ALTER TRACE TO [server_principal]