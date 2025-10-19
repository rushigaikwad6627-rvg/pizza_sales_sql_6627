-- Find the total number of orders, returns, and refunds

SELECT 
  (SELECT COUNT(*) FROM orders) AS total_orders,
  (SELECT COUNT(*) FROM returns) AS total_returns,
  (SELECT COUNT(*) FROM refunds) AS total_refunds;
  
--  list the Top 10 most expensive products ordered

SELECT DISTINCT p.product_name, p.price
FROM products p
JOIN returns r ON p.product_id = r.product_id
ORDER BY p.price DESC
LIMIT 10;

-- show all Customers who have returned at least one product

SELECT DISTINCT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN returns r ON o.order_id = r.order_id;

-- find the Return percentage per product category

SELECT p.category,
       COUNT(r.return_id) * 100.0 / COUNT(o.order_id) AS return_percentage
FROM orders o
JOIN returns r ON o.order_id = r.order_id
JOIN products p ON r.product_id = p.product_id
GROUP BY p.category
ORDER BY return_percentage DESC;

-- list the Top 10 customers with most returns

SELECT c.customer_id, c.name, COUNT(r.return_id) AS total_returns
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN returns r ON o.order_id = r.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_returns DESC
LIMIT 10;

 -- find the Most common return reason

SELECT return_reason, COUNT(*) AS reason_count
FROM returns
GROUP BY return_reason
ORDER BY reason_count DESC
LIMIT 1;

-- Calculate the average refund amount per category

SELECT p.category, AVG(rf.refund_amount) AS avg_refund
FROM refunds rf
JOIN returns r ON rf.return_id = r.return_id
JOIN products p ON r.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_refund DESC;

-- Find the customers who received the highest total refund amount

SELECT c.customer_id, c.name, SUM(rf.refund_amount) AS total_refunds
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN returns r ON o.order_id = r.order_id
JOIN refunds rf ON r.return_id = rf.return_id
GROUP BY c.customer_id, c.name
ORDER BY total_refunds DESC
LIMIT 10;

-- Calculate the average refund processing time

SELECT AVG(DATEDIFF(rf.refund_date, r.return_date)) AS avg_processing_days
FROM refunds rf
JOIN returns r ON rf.return_id = r.return_id
WHERE rf.refund_status = 'Processed';

-- City-wise return percentage

SELECT c.city,
       COUNT(r.return_id) * 100.0 / COUNT(o.order_id) AS city_return_rate
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY c.city
ORDER BY city_return_rate DESC;

--  Find the month-wise trend of returns

SELECT DATE_FORMAT(r.return_date, '%Y-%m') AS month, COUNT(*) AS total_returns
FROM returns r
WHERE r.return_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY month
ORDER BY month;

-- Identify customers with suspicious behavior 

SELECT c.customer_id, c.name,
       COUNT(r.return_id) * 100.0 / COUNT(o.order_id) AS return_rate
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY c.customer_id, c.name
HAVING return_rate > 50
ORDER BY return_rate DESC;

--  Calculate the total revenue lost due to refunds 

SELECT SUM(refund_amount) AS total_loss
FROM refunds
WHERE refund_status = 'Processed';

-- Find the product category causing maximum financial loss 

SELECT p.category, SUM(rf.refund_amount) AS total_loss
FROM refunds rf
JOIN returns r ON rf.return_id = r.return_id
JOIN products p ON r.product_id = p.product_id
WHERE rf.refund_status = 'Processed'
GROUP BY p.category
ORDER BY total_loss DESC
LIMIT 1;

-- Detect refunds still pending after 7 day 

SELECT rf.refund_id, r.return_id, DATEDIFF(CURDATE(), r.return_date) AS days_pending
FROM refunds rf
JOIN returns r ON rf.return_id = r.return_id
WHERE rf.refund_status = 'Pending'
  AND DATEDIFF(CURDATE(), r.return_date) > 7;






