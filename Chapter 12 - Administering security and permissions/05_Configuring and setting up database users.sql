------From section Security principals; Configuring database principals; Configuring and setting up database users

--Users mapped to logins and groups (note, some code not executable unless you use you're own domain logins, but do so with permission.

CREATE LOGIN Bob WITH PASSWORD = 'Bob Is A Graat Guy'; --Misspellings in passwords can be helpful!

CREATE LOGIN [Domain\Fred] FROM WINDOWS;

--Then you could create users for these logins using:
CREATE USER [Domain\Fred] FOR LOGIN [Domain\Fred];

CREATE USER Bob FOR LOGIN Bob;
GO

CREATE USER fred FOR LOGIN [Domain\Fred];
GO

--Users mapped to Windows Authentication principals directly

CREATE USER [Domain\Fred] FOR LOGIN [Domain\Sam];

--Users that cannot be authenticated to at all

CREATE USER Sally WITHOUT LOGIN;

ALTER RoleYouWantToTest ADD MEMBER Sally;

EXECUTE AS USER = 'Sally';
