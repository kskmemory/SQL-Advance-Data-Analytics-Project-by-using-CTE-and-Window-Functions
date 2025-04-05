/*
PRODUCT REPORT

Purpose:
- This report consolidates key product metrics and behaviours.

Highlights:
	1. Gathers essential fields such as product name,category,subcategory and cost.
	2. Segments products by revenue to identify High-Performers,Midd-Range,or Low-Range
	3.Aggregates product-level metrics:
		-total orders
		-total sales
		-total quantity sold
		-total customers (unique)
		-lifespan (in months)
	4.Calculates valueable KPIs:
		- recency(months sincelast sale)
		-average order revenue (AOR)
		-average monthly revenue
	*/
CREATE VIEW gold.report_products AS 
WITH base_query AS (
SELECT 
s.order_number,
s.order_date,
s.customer_key,
s.sales_amount,
s.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost

FROM gold.fact_sales s 
LEFT JOIN  gold.dim_products as p
ON p.product_key=s.product_key
WHERE order_date IS NOT NULL
)
,
product_aggregations AS 
(
SELECT 
product_key,
product_name,
category,
subcategory,
cost,
DATEDIFF(MONTH,MIN(order_date), MAX(order_date)) AS lifespan,
MAX(order_date) as last_sale_date,
COUNT(DISTINCT order_number) AS  total_orders,
COUNT(DISTINCT customer_key) AS  total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount as FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date,GETDATE()) AS recency_in_months,
	CASE	
		WHEN total_sales > 50000 THEN 'High Performer'
		WHEN total_sales >= 10000 THEN 'Mid Range'
		ELSE 'Low Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_customers,
	total_sales,
	total_quantity,
	avg_selling_price,
	-- Average ORDER Revenue
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,
	--Average Monthly Revenue
	CASE	
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations