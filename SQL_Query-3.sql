/* Which Categories contribute the most to overall sales?*/
WITH category_sales as (
select p.category,
SUM(s.sales_amount) AS Total_Sales
FROM gold.fact_sales as s
INNER JOIN gold.dim_products as p ON s.product_key=p.product_key
GROUP BY p.category)

SELECT 
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER ())*100,2), '%') as percentage_of_total
FROM category_sales
