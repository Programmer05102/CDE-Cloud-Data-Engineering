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

-- Customer who have placed orders more than twice

SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers c
WHERE
    EXISTS (
        SELECT
            COUNT (*)
        FROM
            sales.orders o
        WHERE
            o.customer_id = c.customer_id
        GROUP BY
            customer_id
        HAVING
            COUNT (*) >= 2
    )

-- Using IN

SELECT
    customer_id,
    first_name,
    last_name
FROM
    sales.customers c
WHERE
    customer_id IN (
        SELECT
            o.customer_id
        FROM
            sales.orders o
        GROUP BY
            o.customer_id
        HAVING
            COUNT(*) >= 2
    )

-- ANY (ONLY ONE HAS TO MATCH)

SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    product_id = ANY (
        SELECT
            product_id
        FROM
            sales.order_items
        WHERE
            quantity >= 2
    )
ORDER BY
    product_name;

-- ALL (ALL HAS TO MATCH)

SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price > ALL (
        SELECT
            AVG (list_price) avg_list_price
        FROM
            production.products
        GROUP BY
            brand_id
    )
ORDER BY
    list_price;

SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price < ALL (
        SELECT
            AVG (list_price) avg_list_price
        FROM
            production.products
        GROUP BY
            brand_id
    )
ORDER BY
    list_price DESC;


-- UNION

SELECT
    first_name,
    last_name
FROM
    sales.staffs
UNION
SELECT
    first_name,
    last_name
FROM
    sales.customers;

-- UNION ALL

SELECT
    first_name,
    last_name
FROM
    sales.staffs
UNION ALL
SELECT
    first_name,
    last_name
FROM
    sales.customers;

-- INTERSECT
SELECT
    first_name,
    last_name
FROM
    sales.staffs
INTERSECT
SELECT
    first_name,
    last_name
FROM
    sales.customers;

-- DUPLICATE ROW
SELECT
    first_name,
    last_name,
	COUNT (*)
FROM
    sales.customers
GROUP BY
	first_name,
	last_name
HAVING
	COUNT (*) >= 2;

-- EXCEPT

SELECT
    product_id
FROM
    production.products
EXCEPT
SELECT
    product_id
FROM
    sales.order_items;

-- EXCEPT WITH ORDER BY

SELECT
    product_id
FROM
    production.products
EXCEPT
SELECT
    product_id
FROM
    sales.order_items
ORDER BY 
	product_id;

