--queries from executioni plans section

SELECT *
FROM Sales.Invoices
		JOIN Sales.Customers
			on Customers.CustomerId = Invoices.CustomerId
WHERE Invoices.InvoiceID like '1%';


SELECT i.InvoiceID
FROM [Sales].[Invoices] as i
WHERE i.InvoiceID like '1%';



SET STATISTICS XML ON
SELECT Invoices.InvoiceID
FROM Sales.Invoices
WHERE Invoices.InvoiceID like '1%'
