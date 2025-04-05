/* Group customers into three segments based on their spending behaviours:
-VIP : Customers with at least 12months of history and spending more than $5000.
-REGULAR : Customers with at least 12 months of history but spending 5000$ or less
-NEW : Customers with a lifespan less than 12 months.
And find the total numbers od customers by each group */
WITH customer_spending AS (
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) first_order,
MAX(order_date) last_order,
DATEDIFF (month,MIN(order_date), MAX(order_date)) AS lifespan
FROM [gold].[fact_sales] f
LEFT JOIN  gold.dim_customers c
ON f.customer_key=c.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
SELECT 
customer_key,
CASE WHEN lifespan >= 12 AND total_spending  > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 AND total_spending  <= 5000 THEN 'Regular'
	 ELSE 'New'
END AS customer_segment
FROM customer_spending ) t
GROUP BY customer_segment
ORDER BY total_customers DESC