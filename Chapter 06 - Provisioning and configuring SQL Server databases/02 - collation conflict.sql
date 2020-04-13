/*For example, if you write a query that includes a table in a database that’s set to the collation SQL_Latin1_General_CP1_CI_AS (which is case insensitive and accent sensitive) and a join to a table in a database that’s also set to SQL_Latin1_General_CP1_CS_AS, you will receive the following error:
*/
--Cannot resolve the collation conflict between "SQL_Latin1_General_CP1_CI_AS" and "SQL_Latin1_General_CP1_CS_AS" in the equal to operation.
/*
Short of changing either database to match the other, you will need to modify your code to use the COLLATE statement when referencing columns in each query, as demonstrated in the following example:
*/
--The following sample succeeds in joining two sample database tables together, despite the mismatched database collations.
SELECT * FROM
CS_AS.sales.sales s1
INNER JOIN CI_AS.sales.sales s2
ON s1.[salestext] COLLATE SQL_Latin1_General_CP1_CI_AS = s2.[salestext];
