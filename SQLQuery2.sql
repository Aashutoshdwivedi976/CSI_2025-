-- 1. List of all customers
SELECT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.PersonID IS NOT NULL;

-- 2. Customers where company name ends in 'N'
SELECT c.CustomerID, s.Name AS CompanyName
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';

-- 3. Customers who live in Berlin or London
SELECT DISTINCT c.CustomerID, a.City
FROM Sales.Customer c
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

-- 4. Customers who live in UK or USA
SELECT DISTINCT c.CustomerID, cr.Name AS Country
FROM Sales.Customer c
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

-- 5. All products sorted by product name
SELECT ProductID, Name
FROM Production.Product
ORDER BY Name;

-- 6. Products where name starts with 'A'
SELECT ProductID, Name
FROM Production.Product
WHERE Name LIKE 'A%';

-- 7. Customers who ever placed an order
SELECT DISTINCT CustomerID
FROM Sales.SalesOrderHeader;

-- 8. Customers who live in London and bought chai
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.BusinessEntityAddress bea ON soh.CustomerID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City = 'London' AND p.Name = 'Chai';

-- 9. Customers who never placed an order
SELECT CustomerID
FROM Sales.Customer
WHERE CustomerID NOT IN (
  SELECT DISTINCT CustomerID FROM Sales.SalesOrderHeader
);

-- 10. Customers who ordered Tofu
SELECT DISTINCT soh.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

-- 11. Details of first order
SELECT TOP 1 * 
FROM Sales.SalesOrderHeader
ORDER BY OrderDate;

-- 12. Most expensive order date
SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- 13. OrderID and avg quantity of items in order
SELECT SalesOrderID, AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- 14. OrderID, min, max quantity
SELECT SalesOrderID, MIN(OrderQty) AS MinQty, MAX(OrderQty) AS MaxQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

-- 15. All managers and employees reporting to them
SELECT m.EmployeeID, m.FirstName, m.LastName, COUNT(e.EmployeeID) AS NumberOfReports
FROM Employees m
JOIN Employees e ON m.EmployeeID = e.ReportsTo
GROUP BY m.EmployeeID, m.FirstName, m.LastName;

-- 16. Orders with total quantity > 300
SELECT SalesOrderID, SUM(OrderQty) AS TotalQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

-- 17. Orders placed on or after 1996-12-31
SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';


-- 19. Orders where total > 200
SELECT *
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;

-- 20. Countries and sales made
SELECT cr.Name AS Country, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name;

-- 21. Customer contact name + number of orders
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName;

-- 22. Customer contact names with >3 orders
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(*) AS Orders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(*) > 3;

-- 23. Discontinued products ordered between 1997-01-01 and 1998-01-01
SELECT DISTINCT p.ProductID, p.Name
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.SellEndDate IS NOT NULL
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24. Employee + supervisor name
SELECT e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;



-- 28. Product names + order count
SELECT p.Name, COUNT(*) AS OrderCount
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name;

-- 29. Orders by best customer (most orders)
SELECT TOP 1 CustomerID, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY OrderCount DESC;

-- 30. Orders by customers without Fax number
SELECT soh.SalesOrderID
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE p.EmailPromotion = 0;

-- 31. Postal codes where Tofu was shipped
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';





-- 34. Products never ordered
SELECT p.Name
FROM Production.Product p
WHERE p.ProductID NOT IN (
  SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail
);

-- 36. Top 10 countries by sales
SELECT TOP 10 cr.Name, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY OrderCount DESC;

-- 37. Orders per employee for customers between A and AO
SELECT SalesPersonID, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (
  SELECT CustomerID
  FROM Sales.Customer c
  JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
  WHERE p.LastName BETWEEN 'A' AND 'AO'
)
GROUP BY SalesPersonID;

-- 38. Date of most expensive order
SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- 39. Product name and total revenue
SELECT p.Name, SUM(sod.LineTotal) AS Revenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name;



-- 41. Top 10 customers based on business
SELECT TOP 10 CustomerID, SUM(TotalDue) AS TotalBusiness
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY TotalBusiness DESC;

-- 42. Total revenue of company
SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;

-- 18. 
SELECT * FROM Orders
WHERE ShipCountry = 'Canada';

-- 25
SELECT e.EmployeeID, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID;

--26
SELECT * FROM Employees
WHERE FirstName LIKE '%a%';

--27.
SELECT m.EmployeeID, m.FirstName, m.LastName, COUNT(e.EmployeeID) AS NumberOfReports
FROM Employees m
JOIN Employees e ON m.EmployeeID = e.ReportsTo
GROUP BY m.EmployeeID, m.FirstName, m.LastName
HAVING COUNT(e.EmployeeID) > 4;

--32.
SELECT DISTINCT p.ProductName
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.ShipCountry = 'France';

--33
SELECT p.ProductName, c.CategoryName
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE s.CompanyName = 'Specialty Biscuits, Ltd.';

--35
SELECT * FROM Products
WHERE UnitsInStock < 10 AND UnitsOnOrder = 0;


--40
SELECT SupplierID, COUNT(*) AS NumberOfProducts
FROM Products
GROUP BY SupplierID;