-- 1.What is the total amount each customer spent at the restaurant?
SELECT s.customer_id,SUM(price) AS total_spent
FROM sales s
JOIN menu m
ON s.product_id=m.product_id
GROUP BY s.customer_id;

-- 2.How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(customer_id) AS count_each_customer_visited 
FROM sales
GROUP BY customer_id;

-- 3.What was the first item from the menu purchased by each customer?
WITH first_purchase AS
(SELECT s.customer_id,s.order_date,m.product_name,
 ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
)

SELECT customer_id,product_name
FROM first_purchase
WHERE rn = 1;

-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?

--  the most purchased item on the menu 
SELECT product_id,COUNT(*) as total_purchased_item
FROM sales
GROUP BY product_id;


SELECT m.product_name,COUNT(*) as total_purchase
FROM menu m
JOIN sales s
ON s.product_id=m.product_id
GROUP BY product_name
ORDER BY total_purchase DESC
LIMIT 1;

-- 5.Which item was the most popular for each customer
WITH cte AS
(
SELECT s.customer_id,m.product_name,
COUNT(*) total_orders,
RANK() OVER
(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) rnk
FROM sales s
JOIN menu m
ON s.product_id=m.product_id
GROUP BY s.customer_id,m.product_name
)

SELECT * FROM cte
WHERE rnk=1;


-- 6.Which item was purchased first by the customer after they became a member?
SELECT * FROM members;
SELECT * FROM sales;

WITH tables AS(
SELECT s.customer_id,s.product_id,s.order_date,
ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as rnk
FROM sales s
JOIN members m
ON s.customer_id=m.customer_id
WHERE s.order_date>=m.join_date
)

SELECT * FROM tables
WHERE rnk=1;



-- 7.Which item was purchased just before the customer became a member?
WITH befores AS (
SELECT s.customer_id,me.product_name,s.order_date,
ROW_NUMBER() OVER(PARTITION BY s.customer_id) AS rnk
FROM sales s
JOIN members m
ON s.customer_id=m.customer_id
JOIN menu me
ON s.product_id=me.product_id
WHERE s.order_date < m.join_date
)

SELECT customer_id,product_name FROM befores;



-- 8.What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
COUNT(*)  AS 'total_items',
SUM(m.price) AS 'amount_spend'
FROM sales s
JOIN menu m
ON s.product_id=m.product_id
JOIN members me
ON s.customer_id=me.customer_id
WHERE s.order_date<me.join_date
GROUP BY s.customer_id;


-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id,
SUM(
CASE 
WHEN m.product_name='sushi' THEN m.price*20
ELSE m.price*10 
END
) total_points
FROM sales s
JOIN menu m
ON s.product_id=m.product_id
GROUP BY s.customer_id;