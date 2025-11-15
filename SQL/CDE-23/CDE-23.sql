USE BikeStores

SELECT
	state,
	COUNT(state) AS customer_per_sales
FROM [sales].[customers]
GROUP BY state
HAVING COUNT(state) > 200

SELECT
	brand,
	category,
	SUM(sales) as total_sales
FROM [sales].[sales_summary]
GROUP BY brand, category;

-- GROUPING SET -> Is a Nested Function of GROUPBY
-- a, b = (), (a), (b), (a,b)
-- brand, category -> a,b = 
-- () 
-- (a) -> brand
-- (b) -> category
-- (a, b) - > brand, category

SELECT
	brand,
	category,
	SUM(sales) as total_sales
FROM [sales].[sales_summary]
GROUP BY
	GROUPING SETS (
		(),
		(brand),
		(category),
		(brand, category)
	);

-- CUBE -> Is a Nested Function of GROUPBY

SELECT
	brand,
	category,
	SUM(sales) as total_sales
FROM [sales].[sales_summary]
GROUP BY
	CUBE (brand, category);

-- ROLLUP -> Is a Nested Function of GROUPBY

SELECT
	brand,
	category,
	SUM(sales) as total_sales
FROM [sales].[sales_summary]
GROUP BY
	ROLLUP (brand, category);

-- SUB-QUERY

SELECT * FROM [sales].[customers] WHERE state = 'NY';

SELECT * FROM [sales].[orders]
WHERE customer_id IN (
	SELECT customer_id
	FROM [sales].[customers]
	WHERE state = 'NY'
);

SELECT * FROM [sales].[orders]
WHERE store_id IN (
	SELECT store_id
	FROM [sales].[stores]
	WHERE state = 'NY'
);

SELECT
    product_name,
    list_price,
    category_id
FROM
    production.products p1
WHERE
    list_price IN (
        SELECT
            MAX (p2.list_price)
        FROM
            production.products p2
        WHERE
            p2.category_id = p1.category_id
        GROUP BY
            p2.category_id
    )
ORDER BY
    category_id,
    product_name;



