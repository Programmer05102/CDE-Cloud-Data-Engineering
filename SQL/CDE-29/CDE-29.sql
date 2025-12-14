-- Disable Index

ALTER INDEX [ix_customers_city]
ON [sales].[customers]
DISABLE;

-- FOR ALL INDEXES

ALTER INDEX ALL
ON [sales].[customers]
DISABLE;

-- Enable Index

ALTER INDEX ALL
ON [sales].[customers]
REBUILD;

-- TASK:
-- simply query on any table.
SELECT product_name FROM production.products;
-- create non-cluster index
CREATE INDEX try_index
ON production.products(product_name);
-- query again and observe
SELECT product_name FROM production.products;
-- rename the index
-- query again and observe
SELECT product_name FROM production.products;
-- disable the index
ALTER INDEX try_index ON production.products DISABLE;
-- query again and oberve
SELECT product_name FROM production.products;
-- rebuild and query again
ALTER INDEX try_index
ON [production].[products]
REBUILD;
SELECT product_name FROM production.products;

-- UNIQUE INDEX

SELECT
    customer_id, 
    email 
FROM
    sales.customers
WHERE 
    email = 'caren.stephens@msn.com';

-- Duplicate Emails
SELECT 
    email, 
    COUNT(email)
FROM 
    sales.customers
GROUP BY 
    email
HAVING 
    COUNT(email) > 1;

-- Creating Unique Index
CREATE UNIQUE INDEX ix_cust_email 
ON sales.customers(email)

------------------------------------------

CREATE TABLE t1 (
    a INT, 
    b INT
);
-- Composite Unique Index
CREATE UNIQUE INDEX ix_uniq_ab 
ON t1(a, b);

--Inserting Unique Values
INSERT INTO t1(a,b) VALUES(1,1);
INSERT INTO t1(a,b) VALUES(1,2);
INSERT INTO t1(a,b) VALUES(1,2);

------------------------
CREATE TABLE t2(
    a INT
);

CREATE UNIQUE INDEX a_uniq_t2
ON t2(a);

INSERT INTO t2(a) VALUES(NULL);

-- DROP Index

DROP INDEX try_index ON production.products;

-- Multiple Filter with multiple column

SELECT    
    customer_id, 
    email,
	first_name
FROM    
    sales.customers
WHERE 
    email = 'aide.franco@msn.com';


-- Included Columns
CREATE UNIQUE INDEX ix_cust_email_inc
ON sales.customers(email)
INCLUDE(first_name,last_name);

-- Filter Index
SELECT 
    SUM(CASE
            WHEN phone IS NULL
            THEN 1
            ELSE 0
        END) AS [Has Phone], 
    SUM(CASE
            WHEN phone IS NULL
            THEN 0
            ELSE 1
        END) AS [No Phone]
FROM 
    sales.customers;

CREATE INDEX ix_cust_phone
ON sales.customers(phone)
WHERE phone IS NOT NULL;

SELECT    
    first_name,
    last_name, 
    phone
FROM    
    sales.customers
WHERE phone = '(281) 363-3309';

-- Computed Columns
SELECT    
    first_name,
    last_name,
    email
FROM    
    sales.customers
WHERE 
    SUBSTRING(email, 0, 
        CHARINDEX('@', email, 0)
    ) = 'garry.espinoza';

ALTER TABLE sales.customers
ADD 
    email_local_part AS 
        SUBSTRING(email, 
            0, 
            CHARINDEX('@', email, 0)
        );

CREATE INDEX ix_cust_email_local_part
ON sales.customers(email_local_part);

SELECT    
    first_name,
    last_name,
    email
FROM    
    sales.customers
WHERE 
    email_local_part = 'garry.espinoza';