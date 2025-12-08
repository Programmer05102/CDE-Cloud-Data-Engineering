-- CASE
SELECT
	CASE order_status
	WHEN 1 THEN 'PENDING'
	WHEN 2 THEN 'PROCESSING'
	WHEN 3 THEN 'REJECTED'
	WHEN 4 THEN 'COMPLETED'
	END AS modified_or_status,
	COUNT(*) AS or_status_count
FROM sales.orders
GROUP BY
	CASE order_status
	WHEN 1 THEN 'PENDING'
	WHEN 2 THEN 'PROCESSING'
	WHEN 3 THEN 'REJECTED'
	WHEN 4 THEN 'COMPLETED'
	END;

-- CASE
SELECT    
    o.order_id, 
    SUM(quantity * list_price) order_value,
    CASE
        WHEN SUM(quantity * list_price) <= 500 
            THEN 'Very Low'
        WHEN SUM(quantity * list_price) > 500 AND 
            SUM(quantity * list_price) <= 1000 
            THEN 'Low'
        WHEN SUM(quantity * list_price) > 1000 AND 
            SUM(quantity * list_price) <= 5000 
            THEN 'Medium'
        WHEN SUM(quantity * list_price) > 5000 AND 
            SUM(quantity * list_price) <= 10000 
            THEN 'High'
        WHEN SUM(quantity * list_price) > 10000 
            THEN 'Very High'
    END order_priority
FROM    
    sales.orders o
INNER JOIN sales.order_items i ON i.order_id = o.order_id
WHERE 
    YEAR(order_date) = 2018
GROUP BY 
    o.order_id;


-- COALESCE
SELECT COALESCE(NULL, 'HELLO');
SELECT COALESCE('Hi', NULL);

SELECT first_name, last_name, COALESCE(phone, 'N/A') phone
FROM sales.customers;

-- NULLIF
-- LHS != RHS (LHS)
-- LHS == RHS (NULL)

SELECT NULLIF(10, 10);

SELECT NULLIF('HI','HELLO');

-- HANDING DUPLICATES
---------------------
DROP TABLE IF EXISTS t1;
CREATE TABLE t1 (
    id INT IDENTITY(1, 1), 
    a  INT, 
    b  INT, 
    PRIMARY KEY(id)
);

INSERT INTO
    t1(a,b)
VALUES
    (1,1),
    (1,2),
    (1,3),
    (2,1),
    (1,2),
    (1,3),
    (2,1),
    (2,2);

SELECT * FROM t1;

SELECT
	a,
	b,
	count(*) count_records
FROM t1
GROUP BY a,b
HAVING count(*) < 2;


SELECT
	a,
	b,
	count(*) count_records
FROM t1
GROUP BY a,b
HAVING count(*) > 1;

WITH CTE AS (
SELECT
	a,
	b,
	count(*) count_records
FROM t1
GROUP BY a,b
HAVING count(*) > 1)
SELECT
	t1.id,
	t1.a,
	t1.b
FROM t1
INNER JOIN CTE ON
					CTE.a = t1.a
				AND 
					CTE.b = t1.b;


-- USING ROW_NUMBER
WITH CTE_DUPLICATES AS (
	SELECT
		id,
		a,
		b,
		ROW_NUMBER() OVER(
			PARTITION BY a, b
			ORDER BY a, b
		) AS RN
	FROM t1)
SELECT
	id,
	a,
	b
FROM
	CTE_DUPLICATES
WHERE 
	RN = 1;

-- JOINS
CREATE VIEW product_catalog AS
	SELECT
		p.product_id,
		p.product_name,
		p.model_year,
		p.list_price,
		c.category_id,
		c.category_name,
		b.brand_id,
		b.brand_name,
		s.store_id,
		s.quantity
	FROM production.products p
		JOIN  production.categories c 
			ON p.category_id = c.category_id
		JOIN production.brands b 
			ON p.brand_id = b.brand_id
		JOIN production.stocks s 
			ON p.product_id = s.product_id;

SELECT *
FROM dbo.product_catalog;

-- LISTING THE VIEW
SELECT name FROM sys.all_views
SELECT * FROM sys.objects WHERE type = 'V';