/* Analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales */

WITH yearly_product_sales as
(
select 
YEAR(f.order_date) AS ORDER_YEAR,
p.product_name,
SUM(f.sales_amount) AS CURRENT_SALES
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key=p.product_key
WHERE f.order_date is not null
GROUP BY
YEAR(f.order_date),p.product_name
)
SELECT  
order_year,
product_name,
CURRENT_SALES,
AVG(current_sales) OVER (PARTITION BY product_name) AS AVG_SALES,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS DIFF_AVG,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0  THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'AVG'
END Avg_change
FROM yearly_product_sales
ORDER BY product_name,order_year