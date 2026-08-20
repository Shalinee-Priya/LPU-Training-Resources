-- =============================================================================
-- =============================================================================
--                    SQL DAY 9 : SQL SUBQUERIES (NESTED QUERIES)
-- =============================================================================
-- =============================================================================
--
--  Author        : Shalinee Priya  |  Data Analyst  |  SQL Trainer
--  Module        : Day 9 of the "Structured Query Language · B.Tech SQL Training"
--                   series (continues directly from Day 8 : SQL JOINS)
--
--  OBJECTIVES
--  ----------------------------------------------------------------------------
--  1. Understand WHY some business questions cannot be answered in one pass and
--     need the result of one query fed into another.
--  2. Write Single Row (scalar) Subqueries (=, >, <, >=, <=) and Multi Row
--     Subqueries (IN, NOT IN, ANY, ALL, EXISTS, NOT EXISTS).
--  3. Recognise when a subquery is correlated (references the outer row)
--     versus non-correlated (runs independently), using EXISTS as the
--     primary example.
--  4. Decide, for a given business question, whether a JOIN or a SUBQUERY is
--     the right tool.
--  5. Avoid the most common subquery mistakes made by beginners.
--
--  EXECUTION GUIDE
--  ----------------------------------------------------------------------------
--  * Engine : MySQL 8.0+
--  * This module REUSES the Day 8 dataset as its single source of truth for
--    all five tables — it does not create, alter, or mutate any of them.
--
--        Step 1 -> Run 03_SQL_Day8_Dataset.sql   (creates & loads joins_db)
--        Step 2 -> Run 02_SQL_Day9_Script.sql     (this file)
--
--    From the MySQL client, that looks like:
--        SOURCE /path/to/Day_08_SQL_Joins/03_SQL_Day8_Dataset.sql;
--        SOURCE /path/to/Day_09_SQL_Subqueries/02_SQL_Day9_Script.sql;
--
--  * Every teaching query is preceded by a business requirement comment —
--    read the requirement, try writing the query yourself, THEN scroll to
--    the provided solution.
--  * Section 10 and Section 12 are PRACTICE ONLY (business requirements /
--    interview questions) and intentionally contain NO solution queries —
--    that is by design, so you can practice independently.
--  * DATASET NOTE: 03_SQL_Day8_Dataset.sql already includes Suppliers.city
--    and Orders.order_date from the start — these power the "Delhi suppliers"
--    and "latest order" scenarios below. This script only READS them; it
--    contains no ALTER TABLE or UPDATE against any Day 8 table, so it is
--    safe to re-run any number of times as long as Step 1 has been (re)run
--    first.
-- =============================================================================


-- =============================================================================
-- SECTION 2 : DATABASE SETUP & VERIFICATION  (read-only — Day 9 alters nothing)
-- =============================================================================

-- Day 9 reuses the finalized Day 8 dataset.
-- No Day 8 table is altered by this script.

-- Execute the Day 8 dataset first (Step 1 above), then:
USE joins_db;

-- -----------------------------------------------------------------------------
-- SCHEMA VERIFICATION — confirm the finalized Day 8 tables are present, and
-- that Suppliers.city / Orders.order_date already exist (added in Day 8, not
-- here) before continuing.
-- -----------------------------------------------------------------------------
DESC Customers;
DESC Products;
DESC Suppliers;
DESC Orders;
DESC OrderDetails;

-- Confirm the two columns Day 9 depends on are already populated
SELECT supplier_id, supplier_name, city
FROM Suppliers;

SELECT order_id, customer_id, order_date
FROM Orders
ORDER BY order_date;


-- =============================================================================
-- SECTION 3 : DAY 8 RECAP
-- =============================================================================
--
--   Customers (1)
--        │
--        ▼
--     Orders (N)
--        │
--        ▼
--   OrderDetails
--        │
--        ▼
--     Products
--        │
--        ▼
--    Suppliers
--
-- Teaching note:
-- Yesterday we connected these five tables using JOINs to build multi-table
-- reports. Today we solve a different kind of problem — one where a query
-- needs the RESULT of another query (an average, a maximum, a list of IDs)
-- rather than needing columns from another table. That is what a SUBQUERY
-- is for.
-- =============================================================================


-- =============================================================================
-- SECTION 4 : WHY SUBQUERIES?
-- Business scenario: Find products priced above the average product price.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- This does NOT work — an aggregate function cannot be used directly inside
-- WHERE, because WHERE filters individual rows before aggregation happens:
-- -----------------------------------------------------------------------------
-- SELECT * FROM Products WHERE price > AVG(price);   -- ERROR

-- -----------------------------------------------------------------------------
-- TWO-QUERY SOLUTION (the manual way)
-- -----------------------------------------------------------------------------
-- Step 1: find the average price
SELECT AVG(price) AS avg_price FROM Products;
-- (read the value returned above — on this dataset it is 7901.33)

-- Step 2: manually copy that number into a second query
SELECT * FROM Products WHERE price > 7901.33;
-- Problem: fragile (breaks the moment prices change) and manual (you have to
-- read a number off the screen and retype it).

-- -----------------------------------------------------------------------------
-- ONE-QUERY SUBQUERY SOLUTION (the SQL way)
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE price >
(
    SELECT AVG(price)
    FROM Products
);

-- WHY THIS IS BETTER:
-- The inner query (SELECT AVG(price) FROM Products) always runs first and
-- always reflects the CURRENT data — there is nothing to copy, paste, or
-- forget to update. This is the entire motivation for subqueries: SQL lets
-- you nest one query inside another instead of running two queries by hand.


-- =============================================================================
-- SECTION 5 : SINGLE ROW SUBQUERIES (Progressive Practice)
-- Scalar Subquery: Returns one column and at most one row.
-- Commonly used with =, >, <, >= and <=.
-- If it returns no row, the scalar result is NULL.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- [EASY] Products priced above the average price
-- -----------------------------------------------------------------------------
SELECT product_name, category, price
FROM Products
WHERE price >
(
    SELECT AVG(price)
    FROM Products
);

-- -----------------------------------------------------------------------------
-- [EASY] Costliest product
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE price =
(
    SELECT MAX(price)
    FROM Products
);

-- -----------------------------------------------------------------------------
-- [EASY] Cheapest product
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE price =
(
    SELECT MIN(price)
    FROM Products
);

-- -----------------------------------------------------------------------------
-- [MEDIUM] Latest order (uses the order_date column built into the Day 8
-- dataset — see Section 2)
-- -----------------------------------------------------------------------------
SELECT *
FROM Orders
WHERE order_date =
(
    SELECT MAX(order_date)
    FROM Orders
);

-- -----------------------------------------------------------------------------
-- [MEDIUM] Highest priced Electronics product
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE price =
(
    SELECT MAX(price)
    FROM Products
    WHERE category = 'Electronics'
)
AND category = 'Electronics';

-- -----------------------------------------------------------------------------
-- [MEDIUM] Lowest Furniture price
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE price =
(
    SELECT MIN(price)
    FROM Products
    WHERE category = 'Furniture'
)
AND category = 'Furniture';

-- INTERVIEW INSIGHT:
-- If a scalar subquery returns multiple rows in a scalar context, MySQL
-- raises "Subquery returns more than 1 row". That is exactly what Section 6
-- (multi row subqueries) is designed to handle instead.


-- =============================================================================
-- SECTION 6 : MULTI ROW SUBQUERIES — IN / NOT IN
-- A multi-row subquery can return multiple rows. Operators such as IN,
-- NOT IN, ANY and ALL are commonly used when the inner query returns
-- multiple values. EXISTS and NOT EXISTS test whether the inner query
-- returns at least one row or no rows (see Section 8).
-- Note: "=" still expects a scalar result — using it against a multi-row
-- subquery raises "Subquery returns more than 1 row" (see Section 5).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Business scenario: Customers who have placed at least one order
-- -----------------------------------------------------------------------------
SELECT *
FROM Customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM Orders
);

-- -----------------------------------------------------------------------------
-- Business scenario: Customers who never placed any order
-- -----------------------------------------------------------------------------
SELECT *
FROM Customers
WHERE customer_id NOT IN
(
    SELECT customer_id
    FROM Orders
);

-- -----------------------------------------------------------------------------
-- Business scenario: Products supplied by Delhi suppliers
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE supplier_id IN
(
    SELECT supplier_id
    FROM Suppliers
    WHERE city = 'Delhi'
);

-- -----------------------------------------------------------------------------
-- Business scenario: Products that have never been ordered
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE product_id NOT IN
(
    SELECT product_id
    FROM OrderDetails
);

-- INTERVIEW INSIGHT:
-- NOT IN can produce unexpected results when the subquery returns NULL,
-- because SQL uses three-valued logic (TRUE / FALSE / UNKNOWN) — a single
-- NULL in the inner query's result can make the whole NOT IN comparison
-- evaluate to UNKNOWN for every row, so it silently returns zero rows. When
-- NULLs may be present, NOT EXISTS is often a safer alternative for
-- expressing an anti-match condition (see Section 8).


-- =============================================================================
-- SECTION 7 : ANY & ALL
-- ANY  = TRUE if the comparison holds for AT LEAST ONE value returned by the
--        subquery.
-- ALL  = TRUE only if the comparison holds for EVERY value returned by the
--        subquery.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Per the concept notes: compare against Stationery category prices.
-- NOTE: this dataset currently has only ONE Stationery product (Notebook,
-- ₹120), so ANY and ALL return the SAME result here — with a single value,
-- "at least one" and "every value" are the same condition. This is still a
-- useful thing to notice: ANY/ALL only visibly diverge when the subquery
-- returns MULTIPLE values (see the Clothing example right below).
-- -----------------------------------------------------------------------------
SELECT *
FROM Products
WHERE price > ANY
(
    SELECT price
    FROM Products
    WHERE category = 'Stationery'
);

SELECT *
FROM Products
WHERE price > ALL
(
    SELECT price
    FROM Products
    WHERE category = 'Stationery'
);

-- -----------------------------------------------------------------------------
-- Clothing category has TWO different prices (T-Shirt ₹700, Jeans ₹1,500) —
-- this is where ANY and ALL genuinely produce DIFFERENT result sets.
-- -----------------------------------------------------------------------------

-- ANY: price beats AT LEAST ONE clothing price (i.e. price > 700) — a wide net
SELECT product_name, price
FROM Products
WHERE price > ANY
(
    SELECT price
    FROM Products
    WHERE category = 'Clothing'
);

-- ALL: price beats EVERY clothing price (i.e. price > 1500) — a narrow net
SELECT product_name, price
FROM Products
WHERE price > ALL
(
    SELECT price
    FROM Products
    WHERE category = 'Clothing'
);

-- INTERVIEW INSIGHT:
-- "price > ANY (list)" is logically the same as "price > MIN(list)".
-- "price > ALL (list)" is logically the same as "price > MAX(list)".


-- =============================================================================
-- SECTION 8 : EXISTS
-- EXISTS returns TRUE when the inner query returns at least one row, and
-- FALSE when it returns no rows. EXISTS is commonly used with a correlated
-- subquery, but correlation is not a requirement of EXISTS — the two
-- examples below are correlated because that is the most common and most
-- useful way EXISTS shows up in real business queries.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Business scenario: Customers having at least one order
-- -----------------------------------------------------------------------------
SELECT customer_name
FROM Customers c
WHERE EXISTS
(
    SELECT *
    FROM Orders o
    WHERE c.customer_id = o.customer_id
);

-- -----------------------------------------------------------------------------
-- Business scenario: Suppliers supplying at least one product
-- -----------------------------------------------------------------------------
SELECT supplier_name
FROM Suppliers s
WHERE EXISTS
(
    SELECT *
    FROM Products p
    WHERE p.supplier_id = s.supplier_id
);

-- CORRELATED BEHAVIOR EXPLAINED:
-- Every earlier subquery in this script (AVG, MAX, IN, ANY, ALL) is
-- NON-CORRELATED — it can run completely on its own, with no knowledge of
-- the outer query. EXISTS above is CORRELATED — the inner query references
-- c.customer_id / s.supplier_id from the outer row, so it cannot run by
-- itself. Conceptually, the correlated subquery is evaluated in the context
-- of each outer row; the optimizer may transform the execution plan. That
-- correlation is what makes EXISTS different from IN, even when both can
-- express the same business question.


-- =============================================================================
-- SECTION 9 : JOIN vs SUBQUERY — Same Question, Two Approaches
-- Business scenario: Customers who placed orders.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- VERSION 1 — JOIN (best when you also need columns from Orders, e.g. OrderID)
-- -----------------------------------------------------------------------------
SELECT DISTINCT c.customer_name
FROM Customers c
INNER JOIN Orders o
    ON c.customer_id = o.customer_id;

-- -----------------------------------------------------------------------------
-- VERSION 2 — SUBQUERY (best when you only need to filter Customers, and
-- don't need any column from Orders in the output)
-- -----------------------------------------------------------------------------
SELECT customer_name
FROM Customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM Orders
);

-- TEACHING RULE OF THUMB:
-- JOIN and Subquery are not competitors with one universally "better" choice
-- — they usually answer different kinds of business questions.
--
-- JOIN is often the natural choice when:
--   - the final result needs columns from MULTIPLE related tables
--   - you are building a multi-table report
--
-- Subquery is often the natural choice when:
--   - one query's result is needed as a CONDITION or COMPARISON
--   - you are checking membership or existence (IN, EXISTS)
--   - you are comparing against an AGGREGATE or DERIVED threshold (AVG, MAX...)
--
-- In real systems, the query optimizer, available indexes, data volume, and
-- the exact shape of the query all influence which approach performs better
-- for a given case — there is no universal rule that one is always faster.


-- =============================================================================
-- SECTION 10 : 25 BUSINESS PRACTICE QUESTIONS (Business Requirements Only —
-- No Solutions). Work through these independently using Sections 4-9 above.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LEVEL 1 — EASY (Q1–Q8)
-- -----------------------------------------------------------------------------
-- Q1. Find products priced above the average product price.
-- Q2. Find the costliest product in the store.
-- Q3. Find the cheapest product in the store.
-- Q4. Find customers who have placed at least one order.
-- Q5. Find customers who have never placed an order.
-- Q6. Find products that have never been ordered.
-- Q7. Find products supplied by suppliers based in Delhi.
-- Q8. Find the most recently placed order (latest order date).

-- -----------------------------------------------------------------------------
-- LEVEL 2 — AGGREGATE THINKING (Q9–Q15)
-- -----------------------------------------------------------------------------
-- Q9.  Find the highest-priced product within the Electronics category.
-- Q10. Find the lowest-priced product within the Furniture category.
-- Q11. Find suppliers who supply at least one product priced above the
--      overall average product price.
-- Q12. Find products priced above the average price of their OWN category
--      (i.e. compare each product only against others in the same category).
-- Q13. Find the second highest priced product, without using LIMIT/OFFSET.
-- Q14. Find customers who ordered at least one product costing more than the
--      overall average product price.
-- Q15. Find categories whose average product price is above ₹5,000.

-- -----------------------------------------------------------------------------
-- LEVEL 3 — EXISTS / NOT IN (Q16–Q20)
-- -----------------------------------------------------------------------------
-- Q16. Using EXISTS, find customers who have placed at least one order.
-- Q17. Using NOT EXISTS, find customers who have never placed an order.
-- Q18. Using EXISTS, find suppliers who currently supply at least one
--      product.
-- Q19. Using NOT EXISTS, find suppliers who currently supply no products
--      at all.
-- Q20. Using NOT IN, find products that were never included in any order —
--      then rewrite the same question using NOT EXISTS and compare.

-- -----------------------------------------------------------------------------
-- LEVEL 4 — INTERVIEW CHALLENGES (Q21–Q25)
-- -----------------------------------------------------------------------------
-- Q21. Find products that cost more than EVERY product in the Stationery
--      category (use ALL).
-- Q22. Find products that cost more than AT LEAST ONE product in the
--      Clothing category (use ANY).
-- Q23. Find suppliers whose products have never been ordered by any
--      customer (a supplier-level "never sold" report).
-- Q24. The CEO wants to know which customers spent more than the AVERAGE
--      total amount spent per customer (Amount = Price x Quantity, summed
--      per customer). Which subqueries would you nest to answer this?
-- Q25. A customer complains they were charged for a product no longer sold
--      by any active supplier in Delhi. Design a subquery-based query that
--      would flag such order lines for investigation.


-- =============================================================================
-- SECTION 11 : COMMON MISTAKES (Demonstrations — Commented Out)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- IMPORTANT INTERVIEW CONCEPT — Correlated vs Non-Correlated Subqueries
-- -----------------------------------------------------------------------------
-- NON-CORRELATED:
-- The inner query does not depend on the outer query — it could run entirely
-- on its own. Every subquery in Sections 4-7 (AVG, MAX, MIN, IN, ANY, ALL) is
-- non-correlated. Example (the inner query never mentions Products p):
--
--   SELECT * FROM Products
--   WHERE price > (SELECT AVG(price) FROM Products);
--
-- CORRELATED:
-- The inner query references a column from the outer query, so it cannot run
-- by itself — it depends logically on the current outer row. Conceptually,
-- the correlated subquery is evaluated in the context of each outer row; the
-- optimizer may transform the execution plan. This is exactly what the
-- EXISTS query from Section 8 does:
--
--   SELECT customer_name FROM Customers c
--   WHERE EXISTS
--   (
--       SELECT * FROM Orders o
--       WHERE c.customer_id = o.customer_id   -- <- references the outer row
--   );
--
-- INTERVIEW TIP: if you can delete the outer table's alias (c.customer_id
-- above) from the inner query and it still runs standalone, the subquery is
-- non-correlated. If deleting it breaks the inner query, it is correlated.

-- MISTAKE 1 — Using "=" when the subquery returns MULTIPLE rows:
-- SELECT * FROM Customers WHERE customer_id = (SELECT customer_id FROM Orders);
-- Explanation: Orders has 12 rows, so this inner query returns 12 values.
-- MySQL raises "Subquery returns more than 1 row". Fix: use IN instead of =.

-- MISTAKE 2 — Forgetting parentheses around the subquery:
-- SELECT * FROM Products WHERE price > SELECT AVG(price) FROM Products;
-- Explanation: a subquery is a complete SELECT statement and MUST be wrapped
-- in parentheses, or MySQL cannot parse the outer query at all (syntax error).

-- MISTAKE 3 — Subquery returning multiple COLUMNS when only one is expected:
-- SELECT * FROM Products
-- WHERE price = (SELECT price, category FROM Products WHERE product_id = 201);
-- Explanation: a scalar subquery used with "=" must return exactly one
-- column AND one row. Select only the single column you actually need.

-- MISTAKE 4 — Confusing JOIN with SUBQUERY:
-- Using a JOIN when you only need to FILTER one table (adds unnecessary
-- duplicate rows and requires DISTINCT to clean up), or using a correlated
-- subquery when you actually need columns from both tables in the output
-- (forces you to bolt on extra subqueries just to fetch data a JOIN would
-- have given you for free). Match the tool to the business question — see
-- Section 9's rule of thumb.

-- MISTAKE 5 — Writing an aggregate function directly inside WHERE:
-- SELECT * FROM Products WHERE price > AVG(price);
-- Explanation: WHERE filters rows BEFORE aggregation happens, so MySQL has
-- no "AVG" to compare against yet. Aggregates belong in a subquery (or after
-- GROUP BY, filtered with HAVING) — never directly inside WHERE.


-- =============================================================================
-- SECTION 12 : 20 INTERVIEW QUESTIONS — No Answers
-- =============================================================================

-- FOUNDATION
-- 1.  What is a Subquery? What are its other two common names?
-- 2.  What is the difference between an Inner Query and an Outer Query?
-- 3.  In which SQL clauses can a subquery legally appear?
-- 4.  Why does "WHERE price > AVG(price)" fail without a subquery?
-- 5.  What data type must a scalar (single row) subquery return?

-- MEDIUM
-- 6.  What is the difference between a Single Row and a Multi Row subquery?
-- 7.  What is the difference between IN and EXISTS? When would you prefer
--     one over the other?
-- 8.  Explain the difference between ANY and ALL with an example.
-- 9.  Why can NOT IN silently return zero rows, and how do you avoid that
--     trap?
-- 10. Can a subquery be used inside SELECT, FROM, INSERT, UPDATE, and
--     DELETE? Give one example of each.
-- 11. What happens if a subquery used with "=" returns more than one row?
-- 12. Is a subquery in the FROM clause required to have an alias? Why?

-- PLACEMENT
-- 13. What is a Correlated Subquery? How is it different from a regular
--     (independent) subquery?
-- 14. Between JOIN and Subquery, which is generally faster, and why is that
--     answer "it depends" in real systems?
-- 15. When would a JOIN be the WRONG choice even though it can technically
--     produce the same output as a subquery?
-- 16. How would you find the "second highest" value using a subquery,
--     without using LIMIT/OFFSET?
-- 17. Describe a real business scenario where EXISTS is clearly the better
--     choice over IN.
-- 18. Describe a real business scenario where a subquery in FROM (a derived
--     table) is necessary.
-- 19. How does MySQL's optimizer typically treat a correlated subquery
--     differently from an independent one, performance-wise?
-- 20. A manager asks for "customers who spent more than average" — walk
--     through, in words, how you would nest the subqueries to answer this.


-- =============================================================================
-- SECTION 13 : END SUMMARY
-- =============================================================================
-- =============================================================================
-- SKILLS MASTERED
--
-- ✔ Subqueries
-- ✔ Single Row
-- ✔ Multi Row
-- ✔ IN / NOT IN
-- ✔ ANY / ALL
-- ✔ EXISTS
-- ✔ JOIN vs Subquery
--
-- Next Module : SQL Views
-- =============================================================================
