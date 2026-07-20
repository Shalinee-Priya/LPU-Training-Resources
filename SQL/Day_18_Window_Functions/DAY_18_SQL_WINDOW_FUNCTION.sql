-- ===========================================================
-- DAY_18_SQL_WINDOW_FUNCTIONS_COMPLETE.sql
-- PART 1 : Introduction + Dataset + OVER() + PARTITION BY
--           ORDER BY + ROW_NUMBER() + RANK() + DENSE_RANK()
-- Compatible with: MySQL 8.0+
-- ===========================================================

/*
WINDOW FUNCTIONS
----------------
A Window Function performs calculations across a set of rows without collapsing them like GROUP BY.

Syntax:
FUNCTION_NAME(...) OVER(
    [PARTITION BY column]
    [ORDER BY column]
)

Dataset: E-Commerce Analytics
*/

DROP DATABASE IF EXISTS ecommerce_window_demo;
CREATE DATABASE ecommerce_window_demo;
USE ecommerce_window_demo;

-- ==========================
-- TABLES
-- ==========================

CREATE TABLE categories(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY(category_id) REFERENCES categories(category_id)
);

CREATE TABLE salespersons(
    salesperson_id INT PRIMARY KEY,
    salesperson_name VARCHAR(100),
    region VARCHAR(30)
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    order_date DATE,
    salesperson_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY(salesperson_id) REFERENCES salespersons(salesperson_id),
    FOREIGN KEY(product_id) REFERENCES products(product_id)
);

-- ==========================
-- SAMPLE DATA
-- ==========================

INSERT INTO categories VALUES
(1,'Mobile'),
(2,'Laptop'),
(3,'Electronics'),
(4,'Accessories');

INSERT INTO products VALUES
(101,'iPhone 16',1,85000),
(102,'Galaxy S25',1,78000),
(103,'OnePlus 14',1,52000),
(201,'Dell Inspiron',2,72000),
(202,'HP Pavilion',2,68000),
(301,'Sony Smart TV',3,62000),
(302,'LG OLED TV',3,95000),
(401,'Wireless Earbuds',4,4500),
(402,'Mechanical Keyboard',4,6500),
(403,'Gaming Mouse',4,3200);

INSERT INTO salespersons VALUES
(1,'Rahul','North'),
(2,'Priya','South'),
(3,'Amit','East'),
(4,'Sneha','West');

INSERT INTO orders VALUES
(1001,'2026-01-02',1,101,2),
(1002,'2026-01-02',2,201,1),
(1003,'2026-01-03',3,301,1),
(1004,'2026-01-03',4,102,3),
(1005,'2026-01-05',1,401,10),
(1006,'2026-01-05',2,202,2),
(1007,'2026-01-06',3,302,1),
(1008,'2026-01-06',4,103,4),
(1009,'2026-01-08',1,402,5),
(1010,'2026-01-08',2,403,8),
(1011,'2026-01-09',3,101,1),
(1012,'2026-01-10',4,201,2),
(1013,'2026-01-10',1,301,2),
(1014,'2026-01-11',2,401,12),
(1015,'2026-01-12',3,102,2),
(1016,'2026-01-13',4,302,1);

-- ============================================================
-- Create a reusable sales view
-- ============================================================

CREATE OR REPLACE VIEW vw_sales AS
SELECT
    o.order_id,
    o.order_date,
    s.salesperson_name,
    s.region,
    p.product_name,
    c.category_name,
    o.quantity,
    p.unit_price,
    o.quantity * p.unit_price AS sales_amount
FROM orders o
JOIN products p
ON o.product_id=p.product_id
JOIN categories c
ON p.category_id=c.category_id
JOIN salespersons s
ON o.salesperson_id=s.salesperson_id;

-- ============================================================
-- OVER()
-- ============================================================

-- Total sales while keeping every row.
SELECT *,
SUM(sales_amount) OVER() AS company_total_sales
FROM vw_sales;

-- Average sales
SELECT *,
AVG(sales_amount) OVER() AS company_average_sale
FROM vw_sales;

-- ============================================================
-- PARTITION BY
-- ============================================================

-- Category wise total
SELECT
product_name,
category_name,
sales_amount,
SUM(sales_amount)
OVER(PARTITION BY category_name) AS category_total
FROM vw_sales;

-- Region wise average
SELECT
salesperson_name,
region,
sales_amount,
AVG(sales_amount)
OVER(PARTITION BY region) AS regional_average
FROM vw_sales;


-- ============================================================
-- ORDER BY inside OVER()
-- ============================================================

-- Running sales
SELECT
order_date,
sales_amount,
SUM(sales_amount)
OVER(ORDER BY order_date) AS running_total
FROM vw_sales;

-- Descending running total example
SELECT
order_date,
sales_amount,
SUM(sales_amount)
OVER(ORDER BY order_date DESC) AS reverse_running_total
FROM vw_sales;

-- ============================================================
-- ROW_NUMBER()
-- ============================================================

-- Overall ranking
SELECT
product_name,
sales_amount,
ROW_NUMBER()
OVER(ORDER BY sales_amount DESC) AS row_num
FROM vw_sales;

-- Ranking within category
SELECT
category_name,
product_name,
sales_amount,
ROW_NUMBER()
OVER(PARTITION BY category_name ORDER BY sales_amount DESC) AS category_row
FROM vw_sales;

-- ============================================================
-- RANK()
-- ============================================================

SELECT
product_name,
sales_amount,
RANK()
OVER(ORDER BY sales_amount DESC) AS sales_rank
FROM vw_sales;

SELECT
category_name,
product_name,
sales_amount,
RANK()
OVER(
PARTITION BY category_name
ORDER BY sales_amount DESC
) AS category_rank
FROM vw_sales;

-- ============================================================
-- DENSE_RANK()
-- ============================================================

SELECT
product_name,
sales_amount,
DENSE_RANK()
OVER(ORDER BY sales_amount DESC) AS dense_rank_no
FROM vw_sales;

SELECT
category_name,
product_name,
sales_amount,
DENSE_RANK()
OVER(
PARTITION BY category_name
ORDER BY sales_amount DESC
) AS category_dense_rank
FROM vw_sales;

-- ============================================================
-- PRACTICE
-- ============================================================
-- 1. Find Top 2 sales in every category.
-- 2. Rank salespersons by revenue.
-- 3. Find highest order in each region.
-- 4. Find running sales by order date.
-- 5. Compare ROW_NUMBER(), RANK() and DENSE_RANK() on same data.

-- ============================================================
-- PART 2 : NTILE(), LAG(), LEAD(),
--          FIRST_VALUE(), LAST_VALUE(), NTH_VALUE()
-- ============================================================

/*
NTILE(n)
---------
Divides ordered rows into n approximately equal buckets. Useful for quartiles, performance bands, customer segmentation.
*/

-- Divide all orders into 4 performance groups.
SELECT
order_id,
product_name,
sales_amount,
NTILE(4) OVER(ORDER BY sales_amount DESC) AS quartile
FROM vw_sales;

-- Divide sales into 3 groups within each category.
SELECT
category_name,
product_name,
sales_amount,
NTILE(3) OVER(
    PARTITION BY category_name
    ORDER BY sales_amount DESC
) AS category_band
FROM vw_sales;

-- ===========================================================
-- LAG()
-- ===========================================================

/*
LAG(column, offset, default)
Returns a value from a previous row.
*/

-- Previous order's sales amount.
SELECT
order_id,
order_date,
sales_amount,
LAG(sales_amount) OVER(ORDER BY order_date, order_id) AS previous_sale
FROM vw_sales;

-- Difference from previous sale.
SELECT
order_id,
order_date,
sales_amount,
LAG(sales_amount) OVER(ORDER BY order_date, order_id) AS previous_sale,
sales_amount -
LAG(sales_amount) OVER(ORDER BY order_date, order_id) AS change_amount
FROM vw_sales;

-- Previous sale within each salesperson.
SELECT
salesperson_name,
order_date,
sales_amount,
LAG(sales_amount) OVER(
PARTITION BY salesperson_name
ORDER BY order_date, order_id
) AS previous_personal_sale
FROM vw_sales;

-- ===========================================================
-- LEAD()
-- ===========================================================

/*
LEAD(column)
Returns a value from the following row.
*/

SELECT
order_id,
order_date,
sales_amount,
LEAD(sales_amount) OVER(ORDER BY order_date, order_id) AS next_sale
FROM vw_sales;

SELECT
salesperson_name,
order_date,
sales_amount,
LEAD(sales_amount) OVER(
PARTITION BY salesperson_name
ORDER BY order_date, order_id
) AS next_personal_sale
FROM vw_sales;

-- Compare current sale with next sale.
SELECT
order_id,
sales_amount,
LEAD(sales_amount) OVER(ORDER BY order_date, order_id) AS next_sale,
LEAD(sales_amount) OVER(ORDER BY order_date, order_id)-sales_amount AS future_difference
FROM vw_sales;

-- ===========================================================
-- FIRST_VALUE()
-- ===========================================================

/*
Returns the first value in the window.
*/

SELECT
category_name,
product_name,
sales_amount,
FIRST_VALUE(product_name)
OVER(
PARTITION BY category_name
ORDER BY sales_amount DESC
) AS highest_product_in_category
FROM vw_sales;

SELECT
salesperson_name,
order_date,
sales_amount,
FIRST_VALUE(sales_amount)
OVER(
PARTITION BY salesperson_name
ORDER BY order_date
) AS first_sale_of_salesperson
FROM vw_sales;

-- ===========================================================
-- LAST_VALUE()
-- ===========================================================

/*
Important:
LAST_VALUE() uses the current window frame.
To get the true last value, specify
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING.
*/

SELECT
salesperson_name,
order_date,
sales_amount,
LAST_VALUE(sales_amount)
OVER(
PARTITION BY salesperson_name
ORDER BY order_date
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
) AS final_sale
FROM vw_sales;

SELECT
category_name,
product_name,
sales_amount,
LAST_VALUE(product_name)
OVER(
PARTITION BY category_name
ORDER BY sales_amount
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
) AS most_expensive_product_in_partition
FROM vw_sales;

-- ===========================================================
-- NTH_VALUE()
-- ===========================================================

/*
Returns the Nth value from the ordered window.
*/

SELECT
category_name,
product_name,
sales_amount,
NTH_VALUE(product_name,2)
OVER(
PARTITION BY category_name
ORDER BY sales_amount DESC
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
) AS second_highest_product
FROM vw_sales;

SELECT
salesperson_name,
order_date,
sales_amount,
NTH_VALUE(sales_amount,3)
OVER(
PARTITION BY salesperson_name
ORDER BY order_date
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
) AS third_sale
FROM vw_sales;

-- ===========================================================
-- MINI BUSINESS CASES
-- ===========================================================

-- 1. Identify the previous transaction amount for every order.
-- 2. Compare current sale with next sale.
-- 3. Divide all sales into Gold, Silver, Bronze quartiles.
-- 4. Find the first and final sale made by each salesperson.
-- 5. Find the second highest sale within every category.

-- ===========================================================
-- PRACTICE QUESTIONS
-- ===========================================================

-- Q1 Find customers/products in the top 25% using NTILE().
-- Q2 Compare each order with the previous order.
-- Q3 Find orders whose sales increased compared to the previous order.
-- Q4 Display the last sale made by every salesperson.
-- Q5 Find the second highest product in every category using NTH_VALUE().
-- Q6 Show the next order amount for every transaction.
-- Q7 Find categories where the second highest sale exceeds 50,000.
-- Q8 Create performance bands using NTILE(5).

-- ===========================================================
-- PART 3 : Aggregate Window Functions & Window Frames
-- ===========================================================

-- ===========================================================
-- SUM() OVER()
-- ===========================================================
/*
SUM() OVER() computes totals without collapsing rows.
*/

-- Company total repeated for every row.
SELECT
order_id,
product_name,
sales_amount,
SUM(sales_amount) OVER() AS company_total
FROM vw_sales;

-- Category total.
SELECT
category_name,
product_name,
sales_amount,
SUM(sales_amount)
OVER(PARTITION BY category_name) AS category_total
FROM vw_sales;

-- Running total by order date.
SELECT
order_date,
order_id,
sales_amount,
SUM(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS running_total
FROM vw_sales;

-- ===========================================================
-- AVG() OVER()
-- ===========================================================

-- Overall average.
SELECT
product_name,
sales_amount,
AVG(sales_amount) OVER() AS overall_average
FROM vw_sales;

-- Category average.
SELECT
category_name,
product_name,
sales_amount,
AVG(sales_amount)
OVER(PARTITION BY category_name) AS category_average
FROM vw_sales;

-- Running average.
SELECT
order_date,
sales_amount,
AVG(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS running_average
FROM vw_sales;

-- ===========================================================
-- COUNT() OVER()
-- ===========================================================

-- Total rows.
SELECT
order_id,
COUNT(*) OVER() AS total_orders
FROM vw_sales;

-- Orders per category.
SELECT
category_name,
product_name,
COUNT(*) OVER(PARTITION BY category_name) AS orders_in_category
FROM vw_sales;

-- Running count.
SELECT
order_date,
COUNT(*) OVER(
ORDER BY order_date, order_id
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS running_count
FROM vw_sales;

-- ===========================================================
-- MIN() OVER()
-- ===========================================================

-- Lowest sale overall.
SELECT
product_name,
sales_amount,
MIN(sales_amount) OVER() AS minimum_sale
FROM vw_sales;

-- Lowest sale by category.
SELECT
category_name,
product_name,
sales_amount,
MIN(sales_amount)
OVER(PARTITION BY category_name) AS category_minimum
FROM vw_sales;

-- Lowest sale seen so far.
SELECT
order_date,
sales_amount,
MIN(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS running_minimum
FROM vw_sales;

-- ===========================================================
-- MAX() OVER()
-- ===========================================================

-- Highest sale overall.
SELECT
product_name,
sales_amount,
MAX(sales_amount) OVER() AS maximum_sale
FROM vw_sales;

-- Highest sale in category.
SELECT
category_name,
product_name,
sales_amount,
MAX(sales_amount)
OVER(PARTITION BY category_name) AS category_maximum
FROM vw_sales;

-- Highest sale till current row.
SELECT
order_date,
sales_amount,
MAX(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS running_maximum
FROM vw_sales;

-- ===========================================================
-- WINDOW FRAMES
-- ===========================================================

/*
Default frame:
RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

For predictable row-by-row calculations,
ROWS is generally preferred.
*/

-- Current row only.
SELECT
order_id,
sales_amount,
SUM(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN CURRENT ROW AND CURRENT ROW
) AS current_row_total
FROM vw_sales;

-- Previous row + current row.
SELECT
order_id,
sales_amount,
SUM(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
) AS previous_plus_current
FROM vw_sales;

-- Current row + next row.
SELECT
order_id,
sales_amount,
SUM(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING
) AS current_plus_next
FROM vw_sales;

-- 3-row moving total.
SELECT
order_id,
sales_amount,
SUM(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS moving_3_row_total
FROM vw_sales;

-- 3-row moving average.
SELECT
order_id,
sales_amount,
AVG(sales_amount)
OVER(
ORDER BY order_date, order_id
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS moving_3_row_average
FROM vw_sales;

-- ===========================================================
-- BUSINESS SCENARIOS
-- ===========================================================
-- 1. Show cumulative company revenue.
-- 2. Compare each sale with category average.
-- 3. Monitor highest sale achieved till each date.
-- 4. Build a dashboard with running KPIs.
-- 5. Calculate rolling 3-order average sales.

-- ===========================================================
-- PRACTICE QUESTIONS
-- ===========================================================
-- Q1 Display cumulative sales by date.
-- Q2 Show products above category average.
-- Q3 Find categories whose maximum sale exceeds 1,00,000.
-- Q4 Calculate a 5-row moving average.
-- Q5 Display running minimum and maximum together.
-- Q6 Show running count by salesperson.
-- Q7 Calculate cumulative revenue within each category.
-- Q8 Compare current sale against running average.
-- Q9 Show previous, current and next row totals.
-- Q10 Build a dashboard query using multiple window functions.

-- ===========================================================
-- PART 4 : Revision, Comparisons, Interview & Business Problems
-- ===========================================================

-- ===========================================================
-- GROUP BY vs WINDOW FUNCTIONS
-- ===========================================================

/*
GROUP BY
--------
1. Combines rows into one row per group.
2. Detail rows are lost.
3. Used for summaries.

WINDOW FUNCTIONS
----------------
1. Keep every row.
2. Add analytical calculations.
3. Ideal for dashboards and reporting.
*/

-- GROUP BY Example
SELECT
category_name,
SUM(sales_amount) AS total_sales
FROM vw_sales
GROUP BY category_name;

-- WINDOW FUNCTION Example
SELECT
category_name,
product_name,
sales_amount,
SUM(sales_amount) OVER(PARTITION BY category_name) AS category_total
FROM vw_sales;

-- ===========================================================
-- WINDOW FUNCTION vs SELF JOIN
-- ===========================================================

-- Previous sale using LAG()
SELECT
order_id,
sales_amount,
LAG(sales_amount) OVER(ORDER BY order_date,order_id) AS previous_sale
FROM vw_sales;

-- Equivalent idea using self join (less elegant)
SELECT
v1.order_id,
v1.sales_amount,
v2.sales_amount AS previous_sale
FROM vw_sales v1
LEFT JOIN vw_sales v2
ON v2.order_id = (
    SELECT MAX(order_id)
    FROM vw_sales x
    WHERE x.order_id < v1.order_id
);

-- ===========================================================
-- WINDOW FUNCTION vs SUBQUERY
-- ===========================================================

-- Products above category average using window function
WITH sales_cte AS
(
SELECT *,
AVG(sales_amount) OVER(PARTITION BY category_name) AS category_avg
FROM vw_sales
)
SELECT *
FROM sales_cte
WHERE sales_amount > category_avg;

-- Same concept using correlated subquery
SELECT *
FROM vw_sales v
WHERE sales_amount >
(
SELECT AVG(v2.sales_amount)
FROM vw_sales v2
WHERE v2.category_name=v.category_name
);

-- ===========================================================
-- COMMON MISTAKES
-- ===========================================================

/*
1. Forgetting ORDER BY with ROW_NUMBER().
2. Confusing RANK() and DENSE_RANK().
3. Using LAST_VALUE() without an explicit frame.
4. Assuming GROUP BY and window functions behave the same.
5. Using window functions directly in WHERE.
6. Ignoring PARTITION BY.
7. Expecting COUNT() OVER() to reduce rows.
8. Not understanding default window frames.
9. Mixing aggregate queries and detail rows incorrectly.
10. Forgetting MySQL version 8.0 requirement.
*/

-- Incorrect (will fail)
-- SELECT * FROM vw_sales
-- WHERE ROW_NUMBER() OVER(ORDER BY sales_amount)=1;

-- Correct
WITH ranked AS
(
SELECT *,
ROW_NUMBER() OVER(ORDER BY sales_amount DESC) AS rn
FROM vw_sales
)
SELECT *
FROM ranked
WHERE rn=1;

-- ===========================================================
-- PERFORMANCE NOTES
-- ===========================================================

/*
Use indexes on columns frequently used in:
1. PARTITION BY
2. ORDER BY
3. JOIN conditions

Window functions usually improve readability over complex
self joins and correlated subqueries.
*/

-- ===========================================================
-- INTERVIEW QUESTIONS
-- ===========================================================

/*
1. What is a Window Function?
2. Difference between GROUP BY and Window Functions?
3. What is OVER()?
4. Why is ORDER BY important?
5. Difference between ROW_NUMBER(), RANK(), DENSE_RANK()?
6. What does PARTITION BY do?
7. Explain LAG() and LEAD().
8. Explain FIRST_VALUE() and LAST_VALUE().
9. Why is LAST_VALUE() confusing?
10. What is NTH_VALUE()?
11. What is NTILE()?
12. What are Window Frames?
13. Difference between RANGE and ROWS?
14. Can Window Functions be used in WHERE?
15. How do you filter on ROW_NUMBER()?
16. Running total query?
17. Moving average query?
18. Previous row comparison?
19. Top 3 products per category?
20. Real-world use cases?
*/

-- ===========================================================
-- BUSINESS PROBLEM STATEMENTS
-- ===========================================================

/*
1. Find the top 3 selling products in every category.
2. Rank salespersons by region based on revenue.
3. Show cumulative company revenue by order date.
4. Find products whose sales exceed their category average.
5. Identify the first and last sale made by each salesperson.
6. Divide products into four performance bands.
7. Find products whose sales decreased compared to the previous order.
8. Display the highest revenue order in each category.
9. Build a rolling 3-order average revenue report.
10. Design a dashboard query showing:
    - Running Total
    - Category Total
    - Category Rank
    - Previous Sale
    - Company Total
    in one result set.
*/

-- ===========================================================
-- CHEAT SHEET
-- ===========================================================

/*
ROW_NUMBER()   -> Unique ranking
RANK()         -> Skips rank after tie
DENSE_RANK()   -> No skipped ranks
NTILE()        -> Buckets/groups
LAG()          -> Previous row
LEAD()         -> Next row
FIRST_VALUE()  -> First value in window
LAST_VALUE()   -> Last value in frame
NTH_VALUE()    -> Nth value
SUM() OVER()   -> Running / partition total
AVG() OVER()   -> Running / partition average
COUNT() OVER() -> Row count without collapsing rows
MIN() OVER()   -> Running minimum
MAX() OVER()   -> Running maximum
*/

-- ======================= END OF WINDOWS FUNCTION =======================