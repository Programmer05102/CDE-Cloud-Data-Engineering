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

SELECT 
    sh.ShipmentID,
    w.OpeningHours WarehouseName,   -- No Name column in warehouse; using identifier info
    e.Name ManagerName,
    p.Name ProductName,
    sd.Quantity,
    sh.TrackingNumber
FROM shipment sh
INNER JOIN shipmentdetail sd ON sh.ShipmentID = sd.ShipmentID
INNER JOIN warehouse w ON sh.WarehouseID = w.WarehouseID
INNER JOIN employee e ON w.ManagerID = e.EmployeeID
INNER JOIN product p ON sd.ProductID = p.ProductID;

--Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.

SELECT 
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM (
    SELECT 
        c.CustomerID,
        c.Name AS CustomerName,
        s.OrderID,
        s.TotalAmount,
        RANK() OVER (PARTITION BY c.CustomerID ORDER BY s.TotalAmount DESC) rnk
    FROM customer c
    INNER JOIN salesorder s ON c.CustomerID = s.CustomerID
) ranked_orders
WHERE rnk <= 3
ORDER BY CustomerID, rnk;

--Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.

SELECT
    p.ProductID,
    p.Name ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    (
        SELECT TOP 1 sod2.Quantity
        FROM salesorderdetail sod2
        INNER JOIN salesorder so2 ON sod2.OrderID = so2.OrderID
        WHERE sod2.ProductID = sod.ProductID AND so2.OrderDate < so.OrderDate
    ) PrevQuantity,
    (
        SELECT TOP 1 sod3.Quantity
        FROM salesorderdetail sod3
        INNER JOIN salesorder so3 ON sod3.OrderID = so3.OrderID
        WHERE sod3.ProductID = sod.ProductID AND so3.OrderDate > so.OrderDate
    ) NextQuantity

FROM salesorderdetail sod
INNER JOIN salesorder so ON sod.OrderID = so.OrderID
INNER JOIN product p ON sod.ProductID = p.ProductID
ORDER BY p.ProductID, so.OrderDate;


--Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
--CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.

CREATE VIEW vw_CustomerOrderSummary AS
SELECT
    c.CustomerID,
    c.Name CustomerName,
    COUNT(s.OrderID) TotalOrders,
    COALESCE(SUM(s.TotalAmount), 0) TotalAmountSpent,
    MAX(s.OrderDate) LastOrderDate
FROM customer c
LEFT JOIN salesorder s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.Name;

--Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.

CREATE PROCEDURE sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SELECT
        sup.SupplierID,
        sup.Name SupplierName,
        SUM(sod.TotalAmount) TotalSalesAmount
    FROM supplier sup
    INNER JOIN purchaseorder po ON sup.SupplierID = po.SupplierID
    INNER JOIN purchaseorderdetail pod ON po.OrderID = pod.OrderID
    INNER JOIN product p ON pod.ProductID = p.ProductID
    INNER JOIN salesorderdetail sod ON p.ProductID = sod.ProductID
    WHERE sup.SupplierID = @SupplierID
    GROUP BY sup.SupplierID, sup.Name;
END;