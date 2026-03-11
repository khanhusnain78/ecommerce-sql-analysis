-- =====================================================
-- SECTION 1: EXPLORATORY DATA ANALYSIS
-- =====================================================

-- Query 1: Total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Query 2: Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Query 3: Total number of products
SELECT COUNT(*) AS total_products
FROM products;

-- Query 4: Total number of order items
SELECT COUNT(*) AS total_items_sold
FROM order_items;

-- Query 5: Total revenue generated
SELECT SUM(payment_value) AS total_revenue
FROM order_payments;


-- =====================================================
-- SECTION 2: REVENUE ANALYSIS
-- =====================================================

-- Query 6: Monthly revenue trend
SELECT
DATE_TRUNC('month', order_purchase_timestamp) AS month,
SUM(payment_value) AS revenue
FROM orders
JOIN order_payments
ON orders.order_id = order_payments.order_id
GROUP BY month
ORDER BY month;

-- Query 7: Average order value
select avg(payment_value) as avg_order_value 
from order_payments;

-- Query 8: Top revenue generating months
SELECT 
DATE_TRUNC('month', order_purchase_timestamp) AS month,
SUM(payment_value) AS revenue
FROM orders
JOIN order_payments
ON orders.order_id = order_payments.order_id
GROUP BY month
ORDER BY revenue DESC
LIMIT 5;

-- Query 9: Revenue by payment method

SELECT 
payment_type,
SUM(payment_value) AS revenue
FROM order_payments
GROUP BY payment_type
ORDER BY revenue DESC;

-- Query 10: Top revenue generating cities

SELECT 
customers.customer_city,
SUM(order_payments.payment_value) AS revenue
FROM customers
JOIN orders
ON customers.customer_id = orders.customer_id
JOIN order_payments
ON orders.order_id = order_payments.order_id
GROUP BY customers.customer_city
ORDER BY revenue DESC
LIMIT 10;



-- =====================================================
-- SECTION 3: PRODUCT ANALYSIS
-- =====================================================

-- Query 11: Top selling product categories

SELECT 
p.product_category_name,
COUNT(oi.order_id) AS total_items_sold
FROM order_items AS oi
JOIN products AS p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC
LIMIT 10;

-- Query 12: Top revenue generating product categories

SELECT
p.product_category_name,
SUM(pay.payment_value) AS revenue
FROM order_items AS oi
JOIN products AS p
ON oi.product_id = p.product_id
JOIN order_payments AS pay
ON oi.order_id = pay.order_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- Query 13: Average product price by category

SELECT
p.product_category_name,
AVG(oi.price) AS avg_product_price
FROM order_items AS oi
JOIN products AS p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_product_price DESC
LIMIT 10;

-- Query 14: Top selling products

SELECT
oi.product_id,
COUNT(oi.order_id) AS total_sales
FROM order_items AS oi
GROUP BY oi.product_id
ORDER BY total_sales DESC
LIMIT 10;

-- Query 15: Top revenue generating products

SELECT
oi.product_id,
SUM(pay.payment_value) AS revenue
FROM order_items AS oi
JOIN order_payments AS pay
ON oi.order_id = pay.order_id
GROUP BY oi.product_id
ORDER BY revenue DESC
LIMIT 10;

-- Query 16: Revenue by state

SELECT
c.customer_state,
SUM(pay.payment_value) AS revenue
FROM customers AS c
JOIN orders AS o
ON c.customer_id = o.customer_id
JOIN order_payments AS pay
ON o.order_id = pay.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- Query 17: Revenue by product category

SELECT
p.product_category_name,
SUM(pay.payment_value) AS revenue
FROM order_items AS oi
JOIN products AS p
ON oi.product_id = p.product_id
JOIN order_payments AS pay
ON oi.order_id = pay.order_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- Query 18: Revenue by year

SELECT
EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
SUM(pay.payment_value) AS revenue
FROM orders AS o
JOIN order_payments AS pay
ON o.order_id = pay.order_id
GROUP BY year
ORDER BY year;


-- =====================================================
-- SECTION 4: CUSTOMER ANALYSIS
-- =====================================================

-- Query 19: Top cities by number of customers

SELECT
customer_city,
COUNT(customer_id) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;

-- Query 20: Average number of orders per customer

SELECT
AVG(order_count) AS avg_orders_per_customer
FROM
(
SELECT
customer_id,
COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
) AS customer_orders;

-- Query 21: Customers with more than one order

SELECT
COUNT(*) AS repeat_customers
FROM
(
SELECT
customer_unique_id,
COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(o.order_id) > 1
) AS repeat_orders;

-- Query 22: Cities with most repeat customers

SELECT
c.customer_city,
COUNT(*) AS repeat_customers
FROM
(
SELECT
customer_unique_id
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(o.order_id) > 1
) AS repeat_orders
JOIN customers c
ON repeat_orders.customer_unique_id = c.customer_unique_id
GROUP BY c.customer_city
ORDER BY repeat_customers DESC
LIMIT 10;
-- Query 23: Top customers by total spending

SELECT
c.customer_unique_id,
SUM(pay.payment_value) AS total_spent
FROM customers AS c
JOIN orders AS o
ON c.customer_id = o.customer_id
JOIN order_payments AS pay
ON o.order_id = pay.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;


-- =====================================================
-- SECTION 5: SELLER ANALYSIS
-- =====================================================
-- Query 24: Top sellers by revenue

SELECT
oi.seller_id,
SUM(pay.payment_value) AS total_revenue
FROM order_items AS oi
JOIN order_payments AS pay
ON oi.order_id = pay.order_id
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 25: Sellers with most orders

SELECT
seller_id,
COUNT(order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;

-- Query 26: Average revenue per seller

SELECT
AVG(seller_revenue) AS avg_revenue_per_seller
FROM
(
SELECT
oi.seller_id,
SUM(pay.payment_value) AS seller_revenue
FROM order_items oi
JOIN order_payments pay
ON oi.order_id = pay.order_id
GROUP BY oi.seller_id
) AS seller_stats;


-- =====================================================
-- SECTION 6: ORDERS AND DELIEVERY ANALYSIS
-- =====================================================

-- Query 27: Order status distribution

SELECT
order_status,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Query 28: Average delivery time

SELECT
AVG(order_delivered_customer_date - order_purchase_timestamp) AS avg_delivery_time
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Query 29: Orders per month

SELECT
DATE_TRUNC('month', order_purchase_timestamp) AS month,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

-- Query 30: Average orders per day

SELECT
DATE(order_purchase_timestamp) AS order_date,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- Query 31: Orders by day of week

SELECT
EXTRACT(DOW FROM order_purchase_timestamp) AS day_of_week,
COUNT(order_id) AS total_orders
FROM orders
GROUP BY day_of_week
ORDER BY total_orders DESC;

-- Query 32: Orders delivered late

SELECT
COUNT(order_id) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- Query 33: Percentage of late deliveries

SELECT
ROUND(
(COUNT(CASE 
WHEN order_delivered_customer_date > order_estimated_delivery_date 
THEN 1 END) * 100.0) / COUNT(order_id), 2
) AS late_delivery_percentage
FROM orders
WHERE order_status = 'delivered';