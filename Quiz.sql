--Q1. List top 5 customers by total order amount.
--Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.

SELECT  TOP 5 c.CustomerID, c.Name CustomerName, SUM(s.TotalAmount) Total_Spent
FROM Customer c
INNER JOIN SalesOrder s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY Total_Spent DESC;

--Q2. Find the number of products supplied by each supplier.
--Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

SELECT s.SupplierID, s.Name SupplierName, COUNT(DISTINCT pd.ProductID) ProductCount
FROM Supplier s
INNER JOIN PurchaseOrder p ON p.SupplierID = s.SupplierID
INNER JOIN PurchaseOrderDetail pd ON p.OrderID = pd.OrderID
GROUP BY s.SupplierID, s.Name
HAVING COUNT(DISTINCT pd.ProductID) > 10
ORDER BY ProductCount DESC;

--Q3. Identify products that have been ordered but never returned.
--Show ProductID, ProductName, and total order quantity.

SELECT p.ProductID, p.Name ProductName, SUM(s.Quantity) AS TotalOrderQuantity
FROM Product p
INNER JOIN SalesOrderDetail s ON p.ProductID = s.ProductID
LEFT JOIN ReturnDetail r ON p.ProductID = r.ProductID
WHERE r.ProductID IS NULL
GROUP BY p.ProductID, p.Name;

--Q4. For each category, find the most expensive product.
--Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.

SELECT c.CategoryID, c.Name CategoryName, p.Name ProductName, p.Price
FROM Category c
INNER JOIN Product p ON c.CategoryID = p.CategoryID
INNER JOIN (
	SELECT CategoryID, MAX(Price) MaxPrice
	FROM Product
    GROUP BY CategoryID
) mp ON p.CategoryID = mp.CategoryID AND p.Price = mp.MaxPrice
	ORDER BY c.CategoryID;


--Q5. List all sales orders with customer name, product name, category, and supplier.
--For each sales order, display:
--OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

SELECT s.OrderID, c.Name CustomerName, p.Name ProductName, cg.Name CategoryName, sup.Name SupplierName, sod.Quantity
FROM SalesOrder s
INNER JOIN Customer c ON s.CustomerID = c.CustomerID
INNER JOIN SalesOrderDetail sod ON s.OrderID = sod.OrderID
INNER JOIN Product p ON sod.ProductID = p.ProductID
INNER JOIN Category cg ON p.CategoryID = cg.CategoryID
INNER JOIN PurchaseOrderDetail pod ON p.ProductID = pod.ProductID
INNER JOIN PurchaseOrder po ON pod.OrderID = po.OrderID
INNER JOIN Supplier sup ON po.SupplierID = sup.SupplierID;

--Q6. Find all shipments with details of warehouse, manager, and products shipped.
--Display:
--ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.

--Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.

--Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.

--Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
--CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.

--Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.