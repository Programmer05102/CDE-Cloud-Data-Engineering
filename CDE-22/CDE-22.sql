-- DDL (Data Definition Language)

CREATE DATABASE MISC;

USE MISC;

CREATE TABLE Lefttable (
	Dated date,
	Country_ID int,
	Units int
	);

CREATE TABLE Righttable (
	ID int,
	Country varchar(100)
	);

-- DML (Data Manipulation Language)

INSERT INTO Lefttable(Dated,Country_ID,Units) VALUES
('2020-01-01',1,40),
('2020-01-02',1,25),
('2020-01-03',3,30),
('2020-01-04',2,35);


INSERT INTO Righttable(ID,Country) VALUES
(3,'PANAMA'),
(4,'SPAIN');

-- Querying

SELECT * FROM Lefttable;
SELECT * FROM Righttable;

--SEMI-JOIN
SELECT 
L.Country_ID, L.Dated, L.Units
FROM Lefttable L
LEFT JOIN Righttable R
ON L.Country_ID = R.ID
WHERE Country_ID != R.ID;

--CROSS-JOIN
SELECT *
FROM Lefttable L
CROSS JOIN Righttable R;

--FULL OUTER JOIN
SELECT *
FROM Lefttable L
FULL OUTER JOIN Righttable R
ON L.Country_ID = R.ID;

-- INNER JOIN
SELECT *
FROM Lefttable AS L
INNER JOIN Righttable AS R
ON L.Country_ID = R.ID;

--LEFT JOIN
SELECT
L.Dated, L.Country_ID, L.Units, R.Country
FROM Lefttable L
LEFT JOIN Righttable R
ON L.Country_ID = R.ID;

--RIGHT JOIN
SELECT
R.ID, R.Country, L.Dated, L.Units
FROM Lefttable L
RIGHT JOIN Righttable R
ON L.Country_ID = R.ID;

--FULL JOIN
SELECT *
FROM Lefttable L
FULL JOIN Righttable R
ON L.Country_ID = R.ID;

--LEFT-ANTI JOIN
SELECT
L.Dated, L.Country_ID, L.Units
FROM Lefttable L
LEFT JOIN Righttable R
ON L.Country_ID = R.ID
WHERE R.ID iS NULL;

--RIGHT-ANTI JOIN
SELECT
R.ID, R.Country
FROM Lefttable L
RIGHT JOIN Righttable R
ON L.Country_ID = R.ID
WHERE L.Country_ID IS NULL;

--FROM/JOIN >> WHERE >> GROUP BY >> HAVING >> SELECT >> DISTINCT >> ORDER BY >> LIMIT/OFFSET

USE BikeStores

--SELF JOIN
SELECT 
	e.First_Name + ' ' + e.Last_Name AS Employee_Name,
	m.First_Name + ' ' + m.Last_Name AS Manager_Name
FROM [sales].[staffs] e
INNER JOIN [sales].[staffs] m
ON e.staff_id = m.manager_id;

SELECT 
	e.First_Name + ' ' + e.Last_Name AS Employee_Name,
	m.First_Name + ' ' + m.Last_Name AS Manager_Name
FROM [sales].[staffs] e
LEFT JOIN [sales].[staffs] m
ON e.staff_id = m.manager_id;

--GROUP BY
SELECT
	state,
	count(*) State_Count
FROM sales.customers
GROUP BY state;

--HAVING
SELECT
	state,
	count(*) State_Count
FROM sales.customers
GROUP BY state
HAVING Count(*) > 1000;

--GROUPING-SETS

--Creating New Table Sales_Summary
SELECT
    b.brand_name AS brand,
    c.category_name AS category,
    p.model_year,
    round(
        SUM (
            quantity * i.list_price * (1 - discount)
        ),
        0
    ) sales INTO sales.sales_summary
FROM
    sales.order_items i
INNER JOIN production.products p ON p.product_id = i.product_id
INNER JOIN production.brands b ON b.brand_id = p.brand_id
INNER JOIN production.categories c ON c.category_id = p.category_id
GROUP BY
    b.brand_name,
    c.category_name,
    p.model_year
ORDER BY
    b.brand_name,
    c.category_name,
    p.model_year;

----------------
SELECT
	*
FROM
	sales.sales_summary
ORDER BY
	brand,
	category,
	model_year;

-- Grouping By Brand
SELECT
    brand,
    SUM (sales) sales
FROM
    sales.sales_summary
GROUP BY
    brand;

-- Grouping By Brand And Category
SELECT
    brand,
    category,
    SUM (sales) sales
FROM
    sales.sales_summary
GROUP BY
    brand,
    category;

-- Total Sales
SELECT SUM(sales) Total_Sales
FROM sales.sales_summary;

SELECT
	brand,
	category,
	SUM (sales) sales
FROM
	sales.sales_summary
GROUP BY
	GROUPING SETS (
		(brand, category),
		(brand),
		(category),
		()
	)
ORDER BY
	brand,
	category;