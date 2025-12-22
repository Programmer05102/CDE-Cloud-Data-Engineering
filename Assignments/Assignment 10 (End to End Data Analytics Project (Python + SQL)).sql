SELECT * FROM df_orders;

--find top 10 highest reveue generating products
SELECT TOP 10 product_id, SUM(sale_price) as sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC;

--find top 5 highest selling products in each region
WITH CTE as (
	SELECT product_id, region, SUM(sale_price) sales
	FROM df_orders
	GROUP BY region, product_id)
	SELECT * FROM (
		SELECT *, ROW_NUMBER() OVER(
			PARTITION BY Region 
			ORDER BY sales DESC) RN
		FROM CTE) A
		WHERE RN <= 5;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH CTE as (
	SELECT
		YEAR(order_date) order_year,
		MONTH(order_date) order_month,
		SUM(sale_price) sales
	FROM df_orders
	GROUP BY YEAR(order_date), MONTH(order_date))
SELECT 
	order_month, 
	SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) sales_2022,
	SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) sales_2023
FROM CTE
GROUP BY order_month
ORDER BY order_month;

--for each category which month had highest sales
WITH CTE as (
    SELECT category,
    format(order_date,'yyyyMM') Order_Year_Month,
    SUM(sale_price) Sales
    FROM df_orders
    GROUP BY category,format(order_date,'yyyyMM'))
SELECT *
FROM (SELECT *,
      ROW_NUMBER() OVER(PARTITION BY category
                        ORDER BY sales DESC) rn from CTE ) A
      WHERE rn=1;

--which sub category had highest growth by profit in 2023 compare to 2022
WITH CTE as (
    SELECT sub_category,
           YEAR(order_date) Order_Year,
           SUM(sale_price) Sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)),
CTE2 as (
    SELECT sub_category ,
           SUM(CASE WHEN Order_Year = 2022 THEN Sales ELSE 0 END) sales_2022,
           SUM(CASE WHEN Order_Year = 2023 THEN Sales ELSE 0 END) Sales_2023
    FROM CTE
    GROUP BY sub_category)
SELECT TOP 1 * ,
       (Sales_2023-Sales_2022)
FROM CTE2
ORDER BY (Sales_2023-Sales_2022) DESC;