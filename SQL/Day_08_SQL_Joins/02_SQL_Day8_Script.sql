-- =============================================================================
-- =============================================================================
--                         SQL DAY 8 : SQL JOINS
--            INNER JOIN | LEFT JOIN | RIGHT JOIN | FULL JOIN | CROSS JOIN
-- =============================================================================
-- =============================================================================
--
--  Author        : Shalinee Priya  |  Data Analyst  |  SQL Trainer
--  Module        : Day 8 of the "Structured Query Language · B.Tech SQL Training"
--                   series (continues directly from Day 7 : Database Normalization)
--
--  OBJECTIVES
--  ----------------------------------------------------------------------------
--  1. Understand WHY normalized tables need to be reconnected using JOINs.
--  2. Master INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN (workaround),
--     and CROSS JOIN with real business scenarios.
--  3. Read and write multi-table business reports (Amazon-style order reports).
--  4. Recognise and avoid common JOIN mistakes (missing ON, Cartesian product,
--     ambiguous columns).
--  5. Build interview-ready confidence on JOIN theory and SQL execution order.
--
--  EXECUTION GUIDE
--  ----------------------------------------------------------------------------
--  * Engine        : MySQL 8.0+
--  * Run this file top-to-bottom in MySQL Workbench / MySQL CLI / DBeaver.
--  * Every CREATE TABLE is followed by a DESC so you can verify structure.
--  * Every teaching query is preceded by a business requirement comment —
--    read the requirement, try writing the query yourself, THEN scroll to
--    the provided solution.
--  * Sections 13 and 15 are PRACTICE ONLY (business requirements / interview
--    questions) and intentionally contain NO solution queries — that is by
--    design, so you can practice independently.
-- =============================================================================


-- =============================================================================
-- SECTION 2 : CREATE DATABASE
-- =============================================================================

DROP DATABASE IF EXISTS joins_db;
CREATE DATABASE joins_db;
USE joins_db;


-- =============================================================================
-- SECTION 3 : DAY 7 RECAP
--
-- Normalization separated data into multiple related tables.
-- Today we retrieve that related data using SQL JOINs.
-- =============================================================================
--
-- Day 7 gave us clean, non-redundant tables:
--   Customers, Suppliers, Products, Orders, OrderDetails
--
-- The trade-off of normalization: a single business question (e.g. "which
-- customer bought which product, from which supplier, at what price?") can
-- no longer be answered from ONE table. The answer is scattered across FIVE
-- related tables, connected only by Primary Key / Foreign Key relationships.
--
-- SQL JOINs are the tool that reconnects normalized data back into a single,
-- business-readable report — without duplicating storage the way a single
-- flat table would.
-- =============================================================================


-- =============================================================================
-- SECTION 4 : CREATE TABLES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 4.1 Customers  — one row per customer
-- -----------------------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID   INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Phone        VARCHAR(15),
    City         VARCHAR(50)
);

-- -----------------------------------------------------------------------------
-- 4.2 Suppliers  — one row per supplier (vendor who supplies products)
-- -----------------------------------------------------------------------------
CREATE TABLE Suppliers (
    SupplierID   INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    Phone        VARCHAR(15)
);

-- -----------------------------------------------------------------------------
-- 4.3 Products  — one row per product; FK -> Suppliers
-- -----------------------------------------------------------------------------
CREATE TABLE Products (
    ProductID   INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category    VARCHAR(50),
    Price       DECIMAL(10,2) NOT NULL,
    SupplierID  INT,
    CONSTRAINT fk_products_supplier
        FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- -----------------------------------------------------------------------------
-- 4.4 Orders  — one row per order; FK -> Customers
-- -----------------------------------------------------------------------------
CREATE TABLE Orders (
    OrderID    INT PRIMARY KEY,
    CustomerID INT,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- -----------------------------------------------------------------------------
-- 4.5 OrderDetails  — line items per order; FK -> Orders, FK -> Products
--     (composite PRIMARY KEY: one product appears at most once per order)
-- -----------------------------------------------------------------------------
CREATE TABLE OrderDetails (
    OrderID   INT,
    ProductID INT,
    Quantity  INT NOT NULL,
    PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT fk_orderdetails_order
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT fk_orderdetails_product
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- -----------------------------------------------------------------------------
-- SCHEMA VERIFICATION — confirm every table was created correctly
-- -----------------------------------------------------------------------------
DESC Customers;
DESC Suppliers;
DESC Products;
DESC Orders;
DESC OrderDetails;


-- =============================================================================
-- SECTION 5 : INSERT SAMPLE DATA
-- Dataset: 14 Customers | 8 Suppliers | 15 Products | 12 Orders | OrderDetails
-- =============================================================================

INSERT INTO Customers VALUES
(101,'Amit Sharma','9876543210','Delhi'),
(102,'Priya Singh','9876543211','Mumbai'),
(103,'Rahul Verma','9876543212','Delhi'),
(104,'Sneha Gupta','9876543213','Pune'),
(105,'Arjun Mehta','9876543214','Bangalore'),
(106,'Neha Kapoor','9876543215','Delhi'),
(107,'Rohan Das','9876543216','Kolkata'),
(108,'Simran Kaur','9876543217','Chandigarh'),
(109,'Anjali Roy','9876543218','Mumbai'),
(110,'Vikas Yadav','9876543219','Lucknow'),
(111,'Karan Malhotra','9876543220','Delhi'),
(112,'Pooja Jain','9876543221','Jaipur'),
(113,'Harsh Kumar','9876543222','Delhi'),
(114,'Nikita Sharma','9876543223','Mumbai');

INSERT INTO Suppliers VALUES
(1,'TechWorld','9991111111'),
(2,'HomeEssentials','9991111112'),
(3,'FashionHub','9991111113'),
(4,'FreshFoods','9991111114'),
(5,'OfficeMart','9991111115'),
(6,'Global Suppliers','9991111116'),
(7,'Future Electronics','9991111117'),
(8,'Dream Traders','9991111118');

INSERT INTO Products VALUES
(201,'Laptop','Electronics',55000,1),
(202,'Mouse','Electronics',800,1),
(203,'Keyboard','Electronics',1500,1),
(204,'Office Chair','Furniture',6500,2),
(205,'Dining Table','Furniture',12000,2),
(206,'T-Shirt','Clothing',700,3),
(207,'Jeans','Clothing',1500,3),
(208,'Rice Bag','Groceries',1800,4),
(209,'Cooking Oil','Groceries',1800,4),
(210,'Notebook','Stationery',120,5),
(211,'Printer','Electronics',12000,5),
(212,'Monitor','Electronics',15000,7),
(213,'Headphones','Electronics',2500,7),
(214,'Bookshelf','Furniture',6500,2),
(215,'Pen Drive','Electronics',800,1);

INSERT INTO Orders VALUES
(1001,101),
(1002,102),
(1003,101),
(1004,103),
(1005,104),
(1006,105),
(1007,106),
(1008,107),
(1009,108),
(1010,109),
(1011,105),
(1012,110);

INSERT INTO OrderDetails VALUES
(1001,201,1),
(1001,202,2),
(1002,203,1),
(1002,206,3),
(1003,204,1),
(1003,203,5),
(1004,205,1),
(1004,207,2),
(1005,208,4),
(1005,209,3),
(1006,201,1),
(1006,213,2),
(1007,202,4),
(1007,211,1),
(1008,203,2),
(1009,212,1),
(1009,206,2),
(1010,207,3),
(1010,208,2),
(1011,201,1),
(1011,205,1),
(1012,202,3),
(1012,209,4);


-- =============================================================================
-- SECTION 6 : RELATIONSHIP VERIFICATION
-- =============================================================================

SELECT * FROM Customers;
SELECT * FROM Suppliers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

-- -----------------------------------------------------------------------------
-- RELATIONSHIP MAP (how normalized tables connect back together)
-- -----------------------------------------------------------------------------
--   Customers (1)
--        │  CustomerID
--        ▼
--     Orders (N)                 <- one customer can place many orders
--        │  OrderID
--        ▼
--   OrderDetails                 <- one order can contain many products (line items)
--        │  ProductID
--        ▼
--     Products                   <- one product can appear in many order lines
--        │  SupplierID
--        ▼
--    Suppliers                   <- one supplier can supply many products
--
-- Customers.CustomerID   -> Orders.CustomerID          (1 customer  : N orders)
-- Orders.OrderID         -> OrderDetails.OrderID        (1 order     : N line items)
-- Products.ProductID     -> OrderDetails.ProductID      (1 product   : N line items)
-- Suppliers.SupplierID   -> Products.SupplierID         (1 supplier  : N products)
-- =============================================================================


-- =============================================================================
-- SECTION 7 : INNER JOIN  (Progressive Practice)
-- INNER JOIN returns only rows where a match exists in BOTH tables.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- [EASY] Q1. Business Requirement:
-- The customer support team wants to call every customer who has placed an
-- order. Prepare a report showing the Customer Name along with the Order ID.
-- -----------------------------------------------------------------------------
SELECT c.CustomerName, o.OrderID
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID;

-- -----------------------------------------------------------------------------
-- [EASY] Q2. Business Requirement:
-- The inventory manager wants to know which supplier provides each product.
-- Display the Product Name and Supplier Name.
-- -----------------------------------------------------------------------------
SELECT p.ProductName, s.SupplierName
FROM Products p
INNER JOIN Suppliers s
    ON p.SupplierID = s.SupplierID;

-- -----------------------------------------------------------------------------
-- [EASY] Q3. Business Requirement:
-- The warehouse team needs to pack customer orders. Show the Order ID,
-- Product Name, and Quantity Ordered.
-- -----------------------------------------------------------------------------
SELECT od.OrderID, p.ProductName, od.Quantity
FROM OrderDetails od
INNER JOIN Products p
    ON od.ProductID = p.ProductID;

-- -----------------------------------------------------------------------------
-- [MEDIUM] Q4. Business Requirement:
-- The sales manager wants to know which customer placed each order.
-- Display the Customer Name, Order ID, and Customer Phone Number.
-- -----------------------------------------------------------------------------
SELECT c.CustomerName, o.OrderID, c.Phone
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID;

-- -----------------------------------------------------------------------------
-- [MEDIUM] Q5. Business Requirement:
-- The procurement team wants to know which supplier supplies the products
-- ordered by customers. Display the Product Name, Supplier Name, and
-- Quantity Ordered.
-- -----------------------------------------------------------------------------
SELECT p.ProductName, s.SupplierName, od.Quantity
FROM OrderDetails od
INNER JOIN Products p  ON od.ProductID  = p.ProductID
INNER JOIN Suppliers s ON p.SupplierID  = s.SupplierID;

-- -----------------------------------------------------------------------------
-- [MEDIUM] Q6. Business Requirement:
-- The finance department wants to verify product prices before generating
-- invoices. Display the Product Name, Price, and Quantity Ordered.
-- -----------------------------------------------------------------------------
SELECT p.ProductName, p.Price, od.Quantity
FROM OrderDetails od
INNER JOIN Products p
    ON od.ProductID = p.ProductID;

-- INTERVIEW INSIGHT:
-- INNER JOIN is the most commonly used JOIN in real-world reporting because
-- most business questions ("who bought what") only care about rows that
-- actually have a matching relationship on both sides.


-- =============================================================================
-- SECTION 8 : LEFT JOIN
-- LEFT JOIN returns ALL rows from the left table, plus matching rows from the
-- right table. When there is no match, the right-side columns return NULL.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Business Use: Show ALL customers, including those who never placed an order.
-- -----------------------------------------------------------------------------
SELECT c.CustomerName, o.OrderID
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID;

-- -----------------------------------------------------------------------------
-- Business Use: Show products that have NEVER been purchased
-- (the LEFT JOIN + WHERE ... IS NULL pattern — very common in interviews).
-- -----------------------------------------------------------------------------
SELECT p.ProductName
FROM Products p
LEFT JOIN OrderDetails od
    ON p.ProductID = od.ProductID
WHERE od.ProductID IS NULL;

-- -----------------------------------------------------------------------------
-- Business Use: Show only customers with NULL orders (customers who placed
-- no order at all) — same pattern applied to Customers/Orders.
-- -----------------------------------------------------------------------------
SELECT c.CustomerName, o.OrderID
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- NULL BEHAVIOR EXPLAINED:
-- When a left-table row has no matching right-table row, MySQL fills every
-- selected right-table column with NULL instead of dropping the row. This
-- is what makes LEFT JOIN the standard tool for "find missing data" reports.


-- =============================================================================
-- SECTION 9 : RIGHT JOIN
-- RIGHT JOIN returns ALL rows from the right table, plus matching rows from
-- the left table. It is the mirror image of LEFT JOIN.
-- =============================================================================

-- RIGHT JOIN version: all suppliers, even ones with no products yet.
SELECT s.SupplierName, p.ProductName
FROM Products p
RIGHT JOIN Suppliers s
    ON p.SupplierID = s.SupplierID;

-- EQUIVALENT LEFT JOIN (industry preferred style — simply swap table order):
SELECT s.SupplierName, p.ProductName
FROM Suppliers s
LEFT JOIN Products p
    ON p.SupplierID = s.SupplierID;

-- INTERVIEW INSIGHT — Why is LEFT JOIN preferred over RIGHT JOIN in industry?
-- Both produce identical results when you swap the table order, but LEFT
-- JOIN is preferred because most developers read queries left-to-right and
-- find it more natural to put the "keep everything from this table" table
-- FIRST. It keeps codebases consistent and easier to review.


-- =============================================================================
-- SECTION 10 : FULL OUTER JOIN (MySQL Workaround)
-- MySQL does NOT support FULL OUTER JOIN natively. It is simulated using
-- LEFT JOIN UNION RIGHT JOIN.
-- =============================================================================

-- Business Use: Show every customer and every order, matched where possible,
-- with NULLs on whichever side has no match (a true "all data, both sides"
-- picture).
SELECT c.CustomerName, o.OrderID
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID

UNION

SELECT c.CustomerName, o.OrderID
FROM Customers c
RIGHT JOIN Orders o
    ON c.CustomerID = o.CustomerID;

-- NOTE: UNION automatically removes duplicate rows, which is exactly what we
-- want here — the matching rows produced by both the LEFT JOIN and the
-- RIGHT JOIN would otherwise appear twice. Do NOT claim FULL OUTER JOIN
-- exists as a native MySQL keyword — it does not. PostgreSQL and SQL Server
-- do support it natively; MySQL requires this UNION workaround.


-- =============================================================================
-- SECTION 11 : CROSS JOIN
-- CROSS JOIN returns the Cartesian product: every row of table A combined
-- with every row of table B. Rows returned = rows(A) x rows(B).
-- =============================================================================

CREATE TABLE Plans (
    PlanID   INT PRIMARY KEY,
    PlanName VARCHAR(50)
);

INSERT INTO Plans VALUES
(1,'Basic'),
(2,'Premium');

DESC Plans;

-- Demonstration: 3 Customers x 2 Plans = 6 combinations
-- (LIMIT 3 picks a small, readable sample of customers for the demo)
SELECT c.CustomerName, pl.PlanName
FROM (SELECT * FROM Customers LIMIT 3) c
CROSS JOIN Plans pl;

-- WARNING BOX:
-- Cartesian Product = Every Possible Combination.
-- A CROSS JOIN on large tables (e.g. 10,000 customers x 500 products) returns
-- 5,000,000 rows. Use CROSS JOIN deliberately — for promotional pairing,
-- combination generation, or test data — never by accident.


-- =============================================================================
-- SECTION 12 : BUSINESS REPORTS (Progressively Difficult)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- [MEDIUM] Customer Purchase Report
-- -----------------------------------------------------------------------------
SELECT
    c.CustomerName,
    p.ProductName,
    od.Quantity,
    p.Price,
    (p.Price * od.Quantity) AS total_amount
FROM Customers c
INNER JOIN Orders o        ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID    = od.OrderID
INNER JOIN Products p      ON od.ProductID = p.ProductID;

-- -----------------------------------------------------------------------------
-- [MEDIUM] Invoice Report — full itemised invoice per order
-- -----------------------------------------------------------------------------
SELECT
    o.OrderID,
    c.CustomerName,
    p.ProductName,
    p.Price,
    od.Quantity,
    (p.Price * od.Quantity) AS total_amount
FROM Orders o
INNER JOIN Customers c     ON o.CustomerID = c.CustomerID
INNER JOIN OrderDetails od ON o.OrderID    = od.OrderID
INNER JOIN Products p      ON od.ProductID = p.ProductID
ORDER BY o.OrderID;

-- -----------------------------------------------------------------------------
-- [MEDIUM] Warehouse Report — what to pick and pack, grouped by order
-- -----------------------------------------------------------------------------
SELECT
    o.OrderID,
    p.ProductName,
    p.Category,
    od.Quantity
FROM Orders o
INNER JOIN OrderDetails od ON o.OrderID    = od.OrderID
INNER JOIN Products p      ON od.ProductID = p.ProductID
ORDER BY o.OrderID;

-- -----------------------------------------------------------------------------
-- [ADVANCED] Supplier-wise Products Report
-- -----------------------------------------------------------------------------
SELECT
    s.SupplierName,
    p.ProductName,
    p.Category,
    p.Price
FROM Suppliers s
INNER JOIN Products p
    ON s.SupplierID = p.SupplierID
ORDER BY s.SupplierName;

-- -----------------------------------------------------------------------------
-- [ADVANCED] Finance Report — revenue per product line item
-- -----------------------------------------------------------------------------
SELECT
    p.ProductName,
    od.Quantity,
    p.Price,
    (p.Price * od.Quantity) AS total_amount
FROM OrderDetails od
INNER JOIN Products p ON od.ProductID = p.ProductID
ORDER BY total_amount DESC;

-- -----------------------------------------------------------------------------
-- [ADVANCED] CEO Sales Report — the full, boardroom-ready picture
-- -----------------------------------------------------------------------------
SELECT
    c.CustomerName,
    c.Phone           AS CustomerPhone,
    o.OrderID,
    p.ProductName,
    p.Category,
    s.SupplierName,
    od.Quantity,
    p.Price            AS UnitPrice,
    (p.Price * od.Quantity) AS total_amount
FROM Customers c
INNER JOIN Orders o        ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID    = od.OrderID
INNER JOIN Products p      ON od.ProductID = p.ProductID
INNER JOIN Suppliers s     ON p.SupplierID = s.SupplierID
ORDER BY c.CustomerName;


-- =============================================================================
-- SECTION 13 : 50 PRACTICE QUESTIONS (Business Requirements Only — No Solutions)
-- Work through these independently. Solve each using the tables above.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- LEVEL 1 — EASY (Q1–Q8)
-- -----------------------------------------------------------------------------
-- Q1. The sales manager wants a report showing every customer's name along
--     with the Order ID they placed.
-- Q2. Display the product name, price, and supplier name for every product
--     available in the store.
-- Q3. The warehouse manager wants to know which products belong to the
--     Electronics category along with the supplier supplying them.
-- Q4. Show customer names who have placed an order. Arrange the result
--     alphabetically.
-- Q5. Display every supplier along with the products supplied by them.
--     Sort supplier names in ascending order.
-- Q6. The finance team wants the Order ID, Product Name, Quantity and Price
--     for every purchased product.
-- Q7. Display customer name, product name and quantity purchased.
-- Q8. Find all products costing more than ₹1000 along with their supplier
--     names.

-- -----------------------------------------------------------------------------
-- LEVEL 2 — FILTERING + JOINS (Q9–Q15)
-- -----------------------------------------------------------------------------
-- Q9.  Display customers whose names start with 'A' along with the orders
--      they placed.
-- Q10. Show all products supplied by suppliers whose names contain the word
--      "Tech".
-- Q11. Find products costing between ₹500 and ₹3000 along with supplier
--      names. Sort by price descending.
-- Q12. Display customers living in Delhi along with their Order IDs.
-- Q13. Show all purchased products whose quantity is greater than 5.
--      Display product name and quantity.
-- Q14. Find all suppliers supplying products in either Electronics or
--      Furniture category.
-- Q15. Display all customers except those living in Mumbai, along with the
--      orders they placed.

-- -----------------------------------------------------------------------------
-- LEVEL 3 — FINDING MISSING DATA (Q16–Q20)
-- -----------------------------------------------------------------------------
-- Q16. The marketing team wants a list of all customers, including those
--      who have never placed any order.
-- Q17. The inventory manager wants to see every product, including products
--      that have never been purchased.
-- Q18. Display all suppliers along with the products they supply. Also
--      include suppliers who currently supply no products.
-- Q19. Find customers who have never placed any order.
-- Q20. Display products that have never been ordered.

-- -----------------------------------------------------------------------------
-- LEVEL 4 — AGGREGATION + JOINS (Q21–Q30)
-- -----------------------------------------------------------------------------
-- Q21. Display each customer's total number of orders. Sort from highest to
--      lowest.
-- Q22. Find the total quantity sold for every product.
-- Q23. Display the total revenue generated by each product.
--      (Revenue = Quantity x Price)
-- Q24. Show supplier-wise total number of products supplied.
-- Q25. Display category-wise average product price. Only show categories
--      where the average price is greater than ₹1000.
-- Q26. Find customers who have placed more than one order.
-- Q27. Display suppliers supplying more than two products.
-- Q28. The management wants to know the Top 5 most expensive purchased
--      products along with customer name, supplier name, quantity
--      purchased and price.
-- Q29. Find the customer who has purchased the highest total quantity of
--      products. Display customer name and total quantity.
-- Q30. Generate a report showing: Customer Name, Order ID, Product Name,
--      Category, Supplier Name, Quantity, Price, Total Amount
--      (Quantity x Price). Arrange the report by Customer Name and then
--      Product Name.

-- -----------------------------------------------------------------------------
-- LEVEL 5 — ADVANCED BUSINESS THINKING (Q31–Q38)
-- -----------------------------------------------------------------------------
-- Q31. The company is planning to discontinue products that have never been
--      sold. Generate the required report.
-- Q32. The purchasing team wants to know which suppliers have supplied
--      products worth more than ₹10,000 in total inventory value.
--      (Inventory Value = Sum of Product Prices)
-- Q33. Display every customer and the total money they have spent. Sort
--      from highest spender to lowest.
-- Q34. Find suppliers whose average product price is greater than ₹2000.
-- Q35. The sales team wants to know the most sold product in terms of
--      quantity.
-- Q36. Display customers who purchased products supplied by suppliers
--      whose names start with 'S'.
-- Q37. Find products that were ordered at least three times.
-- Q38. Display the top three customers based on total purchase amount.

-- -----------------------------------------------------------------------------
-- SELF JOIN THINKING (Q39–Q44)
-- These intentionally do not mention "Self Join" — recognise when the same
-- table must be joined to itself.
-- -----------------------------------------------------------------------------
-- Q39. Your manager wants to compare every product with other products
--      belonging to the same category. Display both product names and
--      their common category. Do not compare a product with itself.
-- Q40. Find all pairs of customers who live at the same address. Display
--      both customer names and the address.
-- Q41. Show all pairs of products supplied by the same supplier. Do not
--      display duplicate pairs.
-- Q42. Find products that have the same price as another product. Display
--      both product names and the common price.
-- Q43. Display every pair of suppliers whose names start with the same
--      alphabet.
-- Q44. Find customers sharing the same phone number.

-- -----------------------------------------------------------------------------
-- CROSS JOIN THINKING (Q45–Q48)
-- -----------------------------------------------------------------------------
-- Q45. The company wants to see every possible combination of customers and
--      products for a promotional campaign.
-- Q46. Generate every possible combination of suppliers and product
--      categories.
-- Q47. Create every possible pair of customers and suppliers for a survey.
-- Q48. Generate every possible combination of orders and products.

-- -----------------------------------------------------------------------------
-- MEGA CHALLENGES (Q49–Q50)
-- -----------------------------------------------------------------------------
-- Q49. Prepare a complete sales dashboard report containing: Customer Name,
--      Supplier Name, Product Name, Category, Quantity, Price, Total
--      Amount. Only include records where Price is greater than ₹1000 AND
--      Quantity is at least 2. Arrange the report by total amount in
--      descending order.
-- Q50. The CEO wants a business summary showing: Supplier Name, Number of
--      Products, Total Products Sold (Quantity), Total Revenue Generated.
--      Only display suppliers whose revenue exceeds ₹20,000. Arrange the
--      result from highest revenue to lowest.


-- =============================================================================
-- SECTION 14 : COMMON ERRORS (Demonstrations — Commented Out)
-- =============================================================================

-- ERROR 1 — Missing ON clause (creates an accidental Cartesian product):
-- SELECT c.CustomerName, o.OrderID FROM Customers c, Orders o;
-- Explanation: With no ON/WHERE linking condition, MySQL pairs every
-- customer row with every order row instead of only matching ones.

-- ERROR 2 — Wrong join column (joins on a column that isn't the real
-- relationship, silently returning a meaningless result):
-- SELECT c.CustomerName, o.OrderID
-- FROM Customers c JOIN Orders o ON c.CustomerID = o.OrderID;
-- Explanation: CustomerID and OrderID are unrelated keys — this "runs"
-- without an error but the output is business-nonsense.

-- ERROR 3 — Ambiguous columns (both tables have a column with the same
-- name, and it isn't qualified with a table alias):
-- SELECT CustomerID, OrderID FROM Customers JOIN Orders ON ...;
-- Explanation: If both tables expose CustomerID, MySQL throws
-- "Column 'CustomerID' in field list is ambiguous" unless you prefix it,
-- e.g. c.CustomerID.

-- ERROR 4 — SELECT * in a JOIN (returns every column from every joined
-- table, including duplicate foreign key columns — hard to read, slow on
-- wide tables, and fragile if columns are later added):
-- SELECT * FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID;
-- Explanation: Always SELECT only the columns the report actually needs.

-- ERROR 5 — Cartesian Product (using CROSS JOIN, or forgetting ON, on large
-- tables):
-- SELECT * FROM Customers CROSS JOIN Products;
-- Explanation: 14 customers x 15 products = 210 rows here — harmless at this
-- scale, but the same mistake on production tables (millions of rows) can
-- crash a server or generate a multi-billion-row result set.


-- =============================================================================
-- SECTION 15 : INTERVIEW QUESTIONS (20) — No Answers
-- =============================================================================

-- FOUNDATION
-- 1.  What is the difference between INNER JOIN and LEFT JOIN?
-- 2.  Why is the ON clause mandatory in a JOIN (conceptually, not just
--     syntactically)?
-- 3.  What is a Primary Key, and how does it relate to a Foreign Key in a
--     JOIN?
-- 4.  What happens to unmatched rows in a LEFT JOIN?
-- 5.  What is the difference between JOIN ... ON and WHERE filtering?

-- MEDIUM
-- 6.  Explain RIGHT JOIN with an example. Why is it used less often than
--     LEFT JOIN in industry?
-- 7.  Why doesn't MySQL support FULL OUTER JOIN natively, and how do you
--     simulate it?
-- 8.  What is a Cartesian Product, and when would a JOIN accidentally
--     produce one?
-- 9.  When would you deliberately use a CROSS JOIN in a real project?
-- 10. How do NULL values behave in JOIN conditions?
-- 11. What is the difference between an ambiguous column error and a wrong
--     join column bug?
-- 12. Can you JOIN more than two tables in a single query? How does
--     execution order work?

-- PLACEMENT
-- 13. Write a query to find customers who have never placed an order
--     (conceptually — which JOIN type and which extra condition?).
-- 14. Write a query to find products that were never purchased.
-- 15. How would you find duplicate records using a self join?
-- 16. What is the performance impact of joining on a non-indexed column?
-- 17. Explain the logical execution order of a SQL query containing JOIN,
--     WHERE, GROUP BY, HAVING, and ORDER BY.
-- 18. What's the difference between UNION and UNION ALL, and why does the
--     FULL OUTER JOIN workaround use UNION and not UNION ALL?
-- 19. How would you design a report needing data from 5 normalized tables?
-- 20. In an interview, how would you explain "Normalization separates data,
--     JOINs reconnect it" to a non-technical interviewer?


-- =============================================================================
-- SECTION 16 : END SUMMARY
-- =============================================================================
-- =============================================================================
-- SKILLS MASTERED
--
-- ✔ INNER JOIN
-- ✔ LEFT JOIN
-- ✔ RIGHT JOIN
-- ✔ FULL OUTER JOIN
-- ✔ CROSS JOIN
-- ✔ Business Reports
-- ✔ Aliases
-- ✔ Cartesian Product
--
-- Next Module : SQL Subqueries
-- =============================================================================
