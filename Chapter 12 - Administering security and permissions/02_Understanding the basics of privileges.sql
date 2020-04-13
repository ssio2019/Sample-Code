----- From Section: Security principals; Understanding the basics of privileges

--Note these are not real objects or principals. Just samples of how to write certain statements.

GRANT  permission(s) ON objecttype::Securable TO principal;
DENY  permission(s)  ON objecttype::Securable TO principal;
REVOKE permission(s) ON objecttype::Securable  FROM | TO principal;


GRANT EXECUTE TO [domain\katie.sql];

GRANT SELECT on SCHEMA::Sales to [domain\katie.sql];

DENY SELECT on OBJECT::Sales.InvoiceLines to [domain\katie.sql];

GRANT INSERT, UPDATE, DELETE on SCHEMA::Sales to [domain\katie.sql];

REVOKE SELECT on OBJECT::Sales.InvoiceLines to [domain\katie.sql];

REVOKE SELECT on SCHEMA::Sales to [domain\katie.sql];
REVOKE INSERT, UPDATE, DELETE on SCHEMA::Sales to [domain\katie.sql];
