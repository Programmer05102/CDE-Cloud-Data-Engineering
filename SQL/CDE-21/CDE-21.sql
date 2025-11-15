-- Querying Data

-- Fully Qualified Naming
--[BikeStores].[sales].[customers]
--[database].[schema].[table/view]

SELECT * FROM [BikeStores].[sales].[customers];

SELECT first_name FROM [BikeStores].[sales].[customers];

SELECT first_name,last_name FROM [BikeStores].[sales].[customers];

-- Conditions

SELECT * FROM [BikeStores].[sales].[customers] WHERE state = 'NY';

SELECT * FROM [BikeStores].[sales].[customers] WHERE customer_id > 100;

SELECT * FROM [BikeStores].[sales].[customers] WHERE state <> 'NY';

-- Operators (AND, OR, NOT, BETWEEN)

SELECT * FROM [BikeStores].[sales].[customers] WHERE customer_id > 100 AND state = 'NY';

SELECT * FROM [BikeStores].[sales].[customers] WHERE phone IS NOT NULL; -- Recommended
SELECT * FROM [BikeStores].[sales].[customers] WHERE phone <> 'NULL';
SELECT * FROM [BikeStores].[sales].[customers] WHERE phone != 'NULL';
SELECT * FROM [BikeStores].[sales].[customers] WHERE phone <> '';

SELECT * FROM [BikeStores].[sales].[customers] WHERE customer_id BETWEEN 101 AND 155;

SELECT * FROM [BikeStores].[sales].[customers] WHERE last_name = 'Bates' OR first_name = 'Marget';

-- LIKE (WITH WILDCARD)
-- % (Percent Sign): Represents Zero, One, or Multiple Characters
-- _ (Underscore): Represents One
--[] (Brackets): Represents JOIN

SELECT * FROM [BikeStores].[sales].[customers] 
WHERE first_name LIKE 'Aa%';


-- Sorting ORDER BY, ASC/DESC (Optonal: Default ASC)

SELECT * FROM [BikeStores].[sales].[customers] ORDER BY first_name;

SELECT * FROM [BikeStores].[sales].[customers] ORDER BY first_name, state;
SELECT * FROM [BikeStores].[sales].[customers] ORDER BY state, first_name;

SELECT * 
FROM [BikeStores].[sales].[customers] 
ORDER BY state DESC, first_name ASC;

-- limiting (Top, OFFSET/FETCH)
-- OFFSET WORKS ONLY WITH ORDER BY
-- OFFSET offset_row_count {ROW | ROWS}
-- FETCH {FIRST | NEXT} fetch_row_count {ROW | ROWS} only

SELECT TOP(15) *
FROM [BikeStores].[sales].[customers];

SELECT * 
FROM [BikeStores].[sales].[customers] 
ORDER BY first_name
OFFSET 5 ROWS
FETCH NEXT 10 ROWS ONLY;

SELECT
    product_name,
    list_price
FROM
    production.products
ORDER BY
    list_price,
    product_name;

SELECT
    product_name,
    list_price
FROM
    production.products
ORDER BY
    list_price,
    product_name 
OFFSET 10 ROWS 
FETCH NEXT 10 ROWS ONLY;
