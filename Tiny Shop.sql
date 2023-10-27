CREATE DATABASE Tiny_Shop;

Use Tiny_Shop;

CREATE TABLE customers (
				customer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                first_name VARCHAR(20) NOT NULL,
                last_name VARCHAR(20) NOT NULL,
                email VARCHAR(50) NOT NULL);
                
CREATE TABLE products (
				product_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                product_name VARCHAR(10) NOT NULL,
                price INT NOT NULL);
                
CREATE TABLE orders (
				order_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                customer_id INT NOT NULL,
                order_date DATE,
                FOREIGN KEY (customer_id) REFERENCES customers(customer_id));
                
CREATE TABLE order_items (
				order_id INT NOT NULL,
                product_id INT NOT NULL,
                quantity INT NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders(order_id),
                FOREIGN KEY (product_id) REFERENCES products(product_id));
                
INSERT INTO customers (first_name, last_name, email)
				VALUES ('John','Doe','johndoe@hmail.com'),
					   ('Jane','Smith','janesmith@gmail.com'),
                       ('Bob','Johnson','bobjohnson@gmail.com'),
                       ('Alice','Brown','alicebrown@gmail.com'),
                       ('Charlie','Davis','charliedavis@gmail.com'),
                       ('Eva','Fisher','evafisher@gmail.com'),
                       ('George','Harris','georgeharris@gmail.com'),
                       ('Ivy','Jones','ivyjones@gmail.com'),
                       ('Kevin','Miller','kevinmiller@gmail.com'),
                       ('Lily','Nelson','lilynelson@gmail.com'),
                       ('Oliver','Patterson','oliverpatterson@gmail.com'),
                       ('Quinn','Roberts','quinnroberts@gmail.com'),
                       ('Sophia','Thomas','sophiathomas@gmail.com');
                       
INSERT INTO products (product_name, price)
				VALUES ('Product A', 10),
					   ('Product B', 15),
                       ('Product C', 20),
                       ('Product D', 25),
                       ('Product E', 30),
                       ('Product F', 35),
                       ('Product G', 40),
                       ('Product H', 45),
                       ('Product I', 50),
                       ('Product J', 55),
                       ('Product K', 60),
                       ('Product L', 65),
                       ('Product M', 70);
                       
INSERT INTO orders (order_date, customer_id)
				VALUES ('2023-05-01',1),
					   ('2023-05-02',2),
                       ('2023-05-03',3),
                       ('2023-05-04',1),
                       ('2023-05-05',2),
                       ('2023-05-06',3),
                       ('2023-05-07',4),
                       ('2023-05-08',5),
                       ('2023-05-09',6),
                       ('2023-05-10',7),
                       ('2023-05-11',8),
                       ('2023-05-12',9),
                       ('2023-05-13',10),
                       ('2023-05-14',11),
                       ('2023-05-15',12),
                       ('2023-05-16',13);
                       
INSERT INTO order_items (order_id, product_id, quantity)
				VALUES  (1,1,2),
						(1,2,1),
                        (2,2,1),
                        (2,3,3),
                        (3,1,1),
                        (3,3,2),
                        (4,2,4),
                        (4,3,1),
                        (5,1,1),
                        (5,3,2),
                        (6,2,3),
                        (6,1,1),
                        (7,4,1),
                        (7,5,2),
                        (8,6,3),
                        (8,7,1),
                        (9,8,2),
                        (9,9,1),
                        (10,10,3),
                        (10,11,2),
                        (11,12,1),
                        (11,13,3),
                        (12,4,2),
                        (12,5,1),
                        (13,6,3),
                        (13,7,2),
                        (14,8,1),
                        (14,9,2),
                        (15,10,3),
                        (15,11,1),
                        (16,12,2),
                        (16,13,3);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- 1) Which product has the higher price? Only return a single row.
SELECT product_id, product_name, price
FROM products
ORDER BY Price DESC LIMIT 1;

-- 2) Which customer has made the most orders?
WITH O AS(
SELECT CONCAT(first_name, ' ' , last_name) AS Customer_Name, COUNT(order_id) AS NO_OF_ORDERS, 
RANK() OVER(ORDER BY COUNT(o.order_id) DESC) AS RANKS
From customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY Customer_Name
ORDER BY NO_OF_ORDERS DESC)
SELECT * 
FROM O
WHERE RANKS = 1;

-- 3) What's the total revenue per product?
SELECT product_name, SUM(price*quantity) AS Revenue
FROM products p
JOIN order_items oi 
ON p.product_id = oi.product_id
GROUP BY product_name
ORDER BY Revenue;

-- 4) Find the day with the highest revenue.
SELECT order_date, SUM(price*quantity) AS Highest_Revenue 
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY order_date
ORDER BY Highest_Revenue DESC LIMIT 1;

-- 5) Find the first order (by date) for each customer?
SELECT c.customer_id, CONCAT(first_name, ' ' , last_name) AS Customer_Name, o.order_id, MIN(o.order_date) AS First_Order
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY Customer_Name
ORDER BY First_Order;

-- 6) Find the top 3 customers who have ordered the most distinct products?
WITH DP AS
(
SELECT c.customer_id, CONCAT(first_name, ' ' , last_name) AS Customer_Name,
COUNT(DISTINCT p.product_id) AS No_of_Products,
RANK() OVER(ORDER BY COUNT(DISTINCT p.product_id) DESC) AS Product
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY customer_id)
SELECT * 
FROM DP
WHERE Product = 1;

-- 7) Which product had been brought the least in terms of quantity?
WITH L AS
(
SELECT product_name, SUM(quantity) AS Least_Purchased
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY product_name
ORDER BY Least_Purchased)
SELECT *
FROM L 
WHERE Least_Purchased = 3;

-- 8) What is the median order total?

WITH OrderedTotals AS (
  SELECT
    o.order_id,
    SUM(p.price * oi.quantity) AS order_total
  FROM order_items oi
  JOIN products p ON oi.product_id = p.product_id
  JOIN orders o ON oi.order_id = o.order_id
  GROUP BY o.order_id
),
SortedTotals AS (
  SELECT
    order_total,
    ROW_NUMBER() OVER (ORDER BY order_total) AS row_num,
    COUNT(*) OVER () AS total_rows
  FROM OrderedTotals
)
SELECT
  ROUND(AVG(order_total),2) AS median_order_total
FROM SortedTotals
WHERE row_num IN (total_rows / 2, (total_rows / 2) + 1);

-- 9) For each order, determine if it was 'Expensive' (total over 300),
-- 'Affordable' (total over 100), or 'Cheap'.
SELECT o.order_id, SUM(price*quantity) AS Total,
CASE
	WHEN SUM(price*quantity) > 300 THEN 'Expensive'
    WHEN SUM(price*quantity) > 100 THEN 'Affordable'
    ELSE 'Cheap'
END AS Status
FROM products p 
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o
ON oi.order_id = o.order_id
GROUP BY order_id
ORDER BY Total DESC;

-- 10) Find the customer who has ordered the product with the highest price.
WITH Highest_Price_Product AS
(
SELECT CONCAT(first_name, ' ' , last_name) AS Customer_Name, 
RANK() OVER(ORDER BY price DESC) AS Highest_Price
FROM customers c
JOIN orders o 
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p 
ON oi.product_id = p.product_id
)
SELECT Customer_Name
FROM Highest_Price_Product
WHERE Highest_Price = 1;