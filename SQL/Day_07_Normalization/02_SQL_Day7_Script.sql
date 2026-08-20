-- =============================================================================
-- SQL DAY 7 -- DATABASE NORMALIZATION (1NF, 2NF & 3NF)
-- =============================================================================
-- Author         : Shalinee Priya  |  Data Analyst & SQL Trainer
-- Module         : Day 7 of the B.Tech SQL Training Series
-- Continuation   : Direct continuation of Day 6 (ER Model & Database Design)
-- Database       : MySQL 8.0+
--
-- -----------------------------------------------------------------------------
-- LEARNING OBJECTIVES
-- -----------------------------------------------------------------------------
--   1. Understand WHY normalization is required, even after a database has
--      already been designed using an ER Model
--   2. Identify Data Redundancy and the three classic Database Anomalies --
--      Update, Insert, and Delete
--   3. Convert an unnormalized table into First Normal Form (1NF) by
--      removing multi-valued (non-atomic) columns
--   4. Convert a 1NF table into Second Normal Form (2NF) by removing
--      Partial Dependency (requires a composite key)
--   5. Convert a 2NF table into Third Normal Form (3NF) by removing
--      Transitive Dependency
--   6. Apply the full UNF -> 1NF -> 2NF -> 3NF transformation to a
--      real-world E-commerce Orders system
--   7. Prepare for Normalization interview questions asked at placement
--      level
--
-- -----------------------------------------------------------------------------
-- EXECUTION INSTRUCTIONS
-- -----------------------------------------------------------------------------
--   1. Run this script top-to-bottom in MySQL Workbench / MySQL CLI (v8.0+)
--   2. The script DROPS and recreates its own database (normalization_db),
--      so it is completely safe to re-run any number of times
--   3. Sections 3, 6, 10, 11 and 12 are teaching commentary written as SQL
--      comments (no executable statements) -- this is intentional, keeps
--      the classroom discussion inline with the code, and does not break
--      top-to-bottom execution
--   4. A few statements inside Section 6 (the anomaly demonstrations) are
--      deliberately left COMMENTED OUT because they are destructive
--      (UPDATE / DELETE) -- uncomment them live in class to demonstrate the
--      anomaly, then re-run the script fresh afterwards
--   5. Total run time: under 2 seconds
--
-- -----------------------------------------------------------------------------
-- TABLE OF CONTENTS
-- -----------------------------------------------------------------------------
--   SECTION 1  : Professional Header                         (this section)
--   SECTION 2  : Create Fresh Database
--   SECTION 3  : Visual Revision Block -- Day 6 Recap
--   SECTION 4  : Create UNNORMALIZED Table (OrderData)
--   SECTION 5  : Observe Redundancy
--   SECTION 6  : Database Anomalies (Update / Insert / Delete)
--   SECTION 7  : Convert to 1NF (Atomic Values)
--   SECTION 8  : Convert to 2NF (Remove Partial Dependency)
--   SECTION 9  : Convert to 3NF (Remove Transitive Dependency)
--   SECTION 10 : Before vs After Comparison (UNF -> 3NF)
--   SECTION 11 : Practical Lab Activity
--   SECTION 12 : Common Interview Questions (20)
--   SECTION 13 : End Summary
-- =============================================================================


-- =============================================================================
-- SECTION 2 : CREATE FRESH DATABASE
-- -----------------------------------------------------------------------------
-- Reason: Keep the Normalization schema independent from Day 1-6 modules so
-- this demo can be built, broken, and rebuilt live in class without touching
-- or risking any earlier database.
-- =============================================================================
DROP DATABASE IF EXISTS normalization_db;
CREATE DATABASE normalization_db;
USE normalization_db;


-- =============================================================================
-- SECTION 3 : VISUAL REVISION BLOCK -- DAY 6 RECAP
-- -----------------------------------------------------------------------------
-- DAY 6 RECAP
--
-- Entity     -> Table
-- Attribute  -> Column
-- PK         -> Identity
-- FK         -> Relationship
--
-- Today:
-- Poor Design -> Normalized Database
-- -----------------------------------------------------------------------------
-- Day 6 taught us HOW to turn an ER Model into relational tables using
-- PRIMARY KEY and FOREIGN KEY. That answers "how do tables connect?" -- but
-- it does NOT guarantee the tables themselves are well-designed. A table can
-- have perfectly valid keys and still be full of repeated, redundant data.
-- Normalization is the next step: a set of rules (1NF, 2NF, 3NF) that clean
-- up the INSIDE of each table, not just the relationships between tables.
-- =============================================================================


-- =============================================================================
-- SECTION 4 : CREATE UNNORMALIZED TABLE (ORDERDATA)
-- -----------------------------------------------------------------------------
-- Business Scenario: An online shopping company stores all order information
-- -- customer, product, and supplier details -- in a single flat table. This
-- is how many real systems start out before anyone applies normalization.
-- =============================================================================
CREATE TABLE OrderData (
    OrderID         INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName    VARCHAR(50),
    Phone           VARCHAR(15),
    Address         VARCHAR(100),
    ProductName     VARCHAR(50),
    Category        VARCHAR(30),
    SupplierName    VARCHAR(50),
    SupplierPhone   VARCHAR(15),
    Quantity        INT,
    Price           DECIMAL(10,2)
);

-- Verify the schema MySQL actually created.
DESC OrderData;

-- ---- Insert Sample Data (12 records) -----------------------------------------
-- Notice on purpose: "Rahul", "TechZone Supplies", and "Electronics" are each
-- repeated across several rows -- this redundancy is the entire problem
-- Normalization exists to solve.
INSERT INTO OrderData
    (CustomerName, Phone, Address, ProductName, Category, SupplierName, SupplierPhone, Quantity, Price)
VALUES
    ('Rahul',   '9876543210', 'Delhi',      'Laptop',       'Electronics', 'TechZone Supplies',     '8800011122', 1,  55000.00),
    ('Rahul',   '9876543210', 'Delhi',      'Mouse',        'Electronics', 'TechZone Supplies',     '8800011122', 2,    500.00),
    ('Rahul',   '9876543210', 'Delhi',      'Keyboard',     'Electronics', 'TechZone Supplies',     '8800011122', 1,   1200.00),
    ('Sneha',   '9123456780', 'Mumbai',     'Notebook',     'Stationery',  'PaperWorld Traders',    '7700022233', 5,     50.00),
    ('Sneha',   '9123456780', 'Mumbai',     'Pen Set',      'Stationery',  'PaperWorld Traders',    '7700022233', 3,    150.00),
    ('Karan',   '9988776655', 'Bengaluru',  'Laptop',       'Electronics', 'TechZone Supplies',     '8800011122', 1,  58000.00),
    ('Karan',   '9988776655', 'Bengaluru',  'Headphones',   'Electronics', 'TechZone Supplies',     '8800011122', 1,   2000.00),
    ('Meera',   '9090909090', 'Chennai',    'Office Chair', 'Furniture',   'HomeStyle Furnishings', '7000033344', 1,   4500.00),
    ('Meera',   '9090909090', 'Chennai',    'Study Table',  'Furniture',   'HomeStyle Furnishings', '7000033344', 1,   6000.00),
    ('Rahul',   '9876543210', 'Delhi',      'Webcam',       'Electronics', 'TechZone Supplies',     '8800011122', 1,   1800.00),
    ('Aditya',  '9345612780', 'Pune',       'Notebook',     'Stationery',  'PaperWorld Traders',    '7700022233', 10,    45.00),
    ('Sneha',   '9123456780', 'Mumbai',     'Desk Lamp',    'Furniture',   'HomeStyle Furnishings', '7000033344', 2,    700.00);


-- =============================================================================
-- SECTION 5 : OBSERVE REDUNDANCY
-- -----------------------------------------------------------------------------
-- Difficulty: Easy
-- Run the query below and answer the questions as a class before scrolling
-- further.
-- =============================================================================
SELECT * FROM OrderData;

-- Discussion Questions (answer out loud, no solutions written here):
--   1. Which customer name is repeated, and how many times?
--   2. Which supplier name is repeated, and how many times?
--   3. Which category is repeated the most?
--   4. Rahul's phone number appears in how many rows?


-- =============================================================================
-- SECTION 6 : DATABASE ANOMALIES (UPDATE / INSERT / DELETE)
-- -----------------------------------------------------------------------------
-- Three demonstrations using the OrderData table above. Destructive
-- statements are commented out on purpose -- uncomment and run ONE at a time
-- live in class, then re-run the whole script to reset the table.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. UPDATE ANOMALY
-- -----------------------------------------------------------------------------
--   Rahul's phone number is stored in every row that contains one of his
--   orders (4 rows). Changing his phone number correctly means updating ALL
--   4 rows -- miss even one, and the table now contradicts itself (two
--   different phone numbers for the same person).
-- -----------------------------------------------------------------------------
-- UPDATE OrderData SET Phone = '9999999999' WHERE CustomerName = 'Rahul';
--   ^ Uncomment to demonstrate, then check: did EVERY Rahul row change?

-- -----------------------------------------------------------------------------
-- 2. INSERT ANOMALY
-- -----------------------------------------------------------------------------
--   OrderData has no row that can exist without a product, supplier, and
--   order. A brand-new customer who has not placed an order yet CANNOT be
--   stored at all -- the table structure itself blocks a perfectly valid
--   piece of business data (a new customer's contact details).
-- -----------------------------------------------------------------------------
-- INSERT INTO OrderData (CustomerName, Phone, Address) VALUES ('Vikram', '9111122223', 'Kolkata');
--   ^ This "succeeds" only because unrelated columns allow NULL -- in a
--     stricter design (NOT NULL on ProductName/SupplierName), it would fail
--     outright. Either way, registering a customer without an order is not
--     something this table was meant to represent.

-- -----------------------------------------------------------------------------
-- 3. DELETE ANOMALY
-- -----------------------------------------------------------------------------
--   Aditya appears in exactly ONE row (OrderID for the Notebook order).
--   Deleting that single row does not just remove an order -- it silently
--   erases every piece of information the business ever had about Aditya
--   as a customer.
-- -----------------------------------------------------------------------------
-- DELETE FROM OrderData WHERE CustomerName = 'Aditya';
--   ^ Uncomment to demonstrate, then run: SELECT * FROM OrderData WHERE CustomerName = 'Aditya';
--     -- zero rows returned. Aditya no longer exists anywhere in the database.


-- =============================================================================
-- NORMALIZATION DECISION TREE (REVISION)
--
-- Does a column contain multiple values?
--      YES → 1NF
--
-- Is there a composite key with partial dependency?
--      YES → 2NF
--
-- Does a non-key attribute depend on another non-key attribute?
--      YES → 3NF
--
-- Interview Shortcut:
-- 1NF = Atomic Values
-- 2NF = Remove Partial Dependency
-- 3NF = Remove Transitive Dependency
-- =============================================================================

-- =============================================================================
-- SECTION 7 : CONVERT TO 1NF (ATOMIC VALUES)
-- -----------------------------------------------------------------------------
-- Rule: Every cell must contain exactly ONE (atomic) value.
-- Classroom Example: a Student | Subjects table where Subjects stores
-- 'Python, SQL' in a single cell is NOT in 1NF -- it must become two rows.
-- -----------------------------------------------------------------------------
-- IMPORTANT: 1NF removes MULTI-VALUED attributes, not duplicate rows.
-- OrderData above is already technically atomic in every column, which is
-- exactly why its redundancy problem (Section 5) survives all the way to
-- 2NF and 3NF -- 1NF alone was never going to fix it.
-- =============================================================================
CREATE TABLE student_subjects_1nf (
    record_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_name  VARCHAR(50),
    subject       VARCHAR(50)
);

-- Verify the schema.
DESC student_subjects_1nf;

-- BEFORE (violates 1NF): ('Rahul', 'Python, SQL')  -- one cell, two values
-- AFTER  (1NF-compliant): split into two atomic rows below
INSERT INTO student_subjects_1nf (student_name, subject) VALUES
('Rahul', 'Python'),
('Rahul', 'SQL');

-- Verify: every row now holds exactly one subject per student.
SELECT * FROM student_subjects_1nf;


-- =============================================================================
-- SECTION 8 : CONVERT TO 2NF (REMOVE PARTIAL DEPENDENCY)
-- -----------------------------------------------------------------------------
-- Rule: 2NF applies only when a table has a COMPOSITE (multi-column)
-- PRIMARY KEY. It requires every non-key column to depend on the WHOLE key,
-- not just PART of it.
-- Classroom Example: Enrollment(StudentID, CourseID, StudentName, CourseName)
--   -> StudentName depends only on StudentID (a PARTIAL dependency)
--   -> CourseName depends only on CourseID (also a PARTIAL dependency)
--   -> Fix: split into Students, Courses, and a clean Enrollment table
-- =============================================================================
CREATE TABLE students_2nf (
    student_id    INT AUTO_INCREMENT PRIMARY KEY,
    student_name  VARCHAR(50) NOT NULL
);

DESC students_2nf;

CREATE TABLE courses_2nf (
    course_id     INT AUTO_INCREMENT PRIMARY KEY,
    course_name   VARCHAR(50) NOT NULL
);

DESC courses_2nf;

-- -----------------------------------------------------------------------------
-- Dependency check before creating the junction table below:
--   student_name  -> depends only on student_id      (now lives in students_2nf)
--   course_name   -> depends only on course_id        (now lives in courses_2nf)
--   nothing left  -> depends on the FULL (student_id, course_id) pair, which
--                    is exactly why enrollment_2nf below has NO extra columns
-- -----------------------------------------------------------------------------
CREATE TABLE enrollment_2nf (
    student_id  INT,
    course_id   INT,
    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enrollment2nf_student FOREIGN KEY (student_id) REFERENCES students_2nf(student_id),
    CONSTRAINT fk_enrollment2nf_course  FOREIGN KEY (course_id)  REFERENCES courses_2nf(course_id)
);

DESC enrollment_2nf;

-- ---- Sample data --------------------------------------------------------
INSERT INTO students_2nf (student_name) VALUES ('Rahul'), ('Sneha'), ('Karan');
INSERT INTO courses_2nf (course_name) VALUES ('Python Programming'), ('Database Systems');
INSERT INTO enrollment_2nf (student_id, course_id) VALUES
(1, 1), (1, 2), (2, 1), (3, 2);

-- Verify all three tables.
SELECT * FROM students_2nf;
SELECT * FROM courses_2nf;
SELECT * FROM enrollment_2nf;


-- =============================================================================
-- SECTION 9 : CONVERT TO 3NF (REMOVE TRANSITIVE DEPENDENCY)
-- -----------------------------------------------------------------------------
-- Rule: Every non-key column must depend ONLY on the Primary Key -- not on
-- another non-key column.
-- This section applies 1NF + 2NF + 3NF together to the real OrderData table
-- from Section 4, producing exactly the five tables shown in the Day 7
-- slide deck (Slide 4 / Slide 9): Customers, Suppliers, Products, Orders,
-- OrderDetails.
--
-- Transitive dependency being removed: in OrderData, SupplierPhone depends
-- on SupplierName, and SupplierName travels along with ProductName -- i.e.
-- SupplierPhone depends on OrderID only THROUGH SupplierName. Moving
-- supplier details into their own Suppliers table removes that chain.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Customers  (was: CustomerName, Phone, Address columns repeated in OrderData)
-- -----------------------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID    INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName  VARCHAR(50) NOT NULL,
    Phone         VARCHAR(15),
    Address       VARCHAR(100)
);

DESC Customers;

-- -----------------------------------------------------------------------------
-- Suppliers  (was: SupplierName, SupplierPhone columns repeated in OrderData)
-- -----------------------------------------------------------------------------
CREATE TABLE Suppliers (
    SupplierID     INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName   VARCHAR(50) NOT NULL,
    SupplierPhone  VARCHAR(15)
);

DESC Suppliers;

-- -----------------------------------------------------------------------------
-- Products  (was: ProductName, Category, Price, tied to a Supplier)
--   -> SupplierID is a FOREIGN KEY referencing Suppliers(SupplierID)
-- -----------------------------------------------------------------------------
CREATE TABLE Products (
    ProductID     INT AUTO_INCREMENT PRIMARY KEY,
    ProductName   VARCHAR(50) NOT NULL,
    Category      VARCHAR(30),
    Price         DECIMAL(10,2),
    SupplierID    INT,
    CONSTRAINT fk_products_supplier FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

DESC Products;

-- -----------------------------------------------------------------------------
-- Orders  (was: one row per purchase event, now just the customer link)
--   -> CustomerID is a FOREIGN KEY referencing Customers(CustomerID)
-- -----------------------------------------------------------------------------
CREATE TABLE Orders (
    OrderID     INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID  INT,
    CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

DESC Orders;

-- -----------------------------------------------------------------------------
-- OrderDetails  (junction table -- resolves the M:N link between Orders and
-- Products, exactly the way Enrollments resolved Students <-> Courses on
-- Day 6)
--   -> OrderID   is a FOREIGN KEY referencing Orders(OrderID)
--   -> ProductID is a FOREIGN KEY referencing Products(ProductID)
-- -----------------------------------------------------------------------------
CREATE TABLE OrderDetails (
    OrderID     INT,
    ProductID   INT,
    Quantity    INT,
    PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT fk_orderdetails_order   FOREIGN KEY (OrderID)   REFERENCES Orders(OrderID),
    CONSTRAINT fk_orderdetails_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

DESC OrderDetails;

-- ---- Insert normalized data (traced directly from OrderData, Section 4) ----

-- Customers (5) -- each customer stored exactly ONCE, no matter how many
-- orders they place.
INSERT INTO Customers (CustomerName, Phone, Address) VALUES
('Rahul',  '9876543210', 'Delhi'),
('Sneha',  '9123456780', 'Mumbai'),
('Karan',  '9988776655', 'Bengaluru'),
('Meera',  '9090909090', 'Chennai'),
('Aditya', '9345612780', 'Pune');

-- Suppliers (3) -- each supplier stored exactly ONCE.
INSERT INTO Suppliers (SupplierName, SupplierPhone) VALUES
('TechZone Supplies',     '8800011122'),
('PaperWorld Traders',    '7700022233'),
('HomeStyle Furnishings', '7000033344');

-- Products (10) -- each product stored exactly ONCE, linked to its supplier.
INSERT INTO Products (ProductName, Category, Price, SupplierID) VALUES
('Laptop',       'Electronics', 55000.00, 1),
('Mouse',        'Electronics',   500.00, 1),
('Keyboard',     'Electronics',  1200.00, 1),
('Headphones',   'Electronics',  2000.00, 1),
('Webcam',       'Electronics',  1800.00, 1),
('Notebook',     'Stationery',     50.00, 2),
('Pen Set',      'Stationery',    150.00, 2),
('Office Chair', 'Furniture',    4500.00, 3),
('Study Table',  'Furniture',    6000.00, 3),
('Desk Lamp',    'Furniture',     700.00, 3);

-- Orders (12) -- one row per original purchase event, now just a customer link.
INSERT INTO Orders (CustomerID) VALUES
(1), (1), (1), (2), (2), (3), (3), (4), (4), (1), (5), (2);

-- OrderDetails (12) -- which product, and how many, per order.
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1,  1, 1),   -- Rahul  -> Laptop
(2,  2, 2),   -- Rahul  -> Mouse
(3,  3, 1),   -- Rahul  -> Keyboard
(4,  6, 5),   -- Sneha  -> Notebook
(5,  7, 3),   -- Sneha  -> Pen Set
(6,  1, 1),   -- Karan  -> Laptop
(7,  4, 1),   -- Karan  -> Headphones
(8,  8, 1),   -- Meera  -> Office Chair
(9,  9, 1),   -- Meera  -> Study Table
(10, 5, 1),   -- Rahul  -> Webcam
(11, 6, 10),  -- Aditya -> Notebook
(12, 10, 2);  -- Sneha  -> Desk Lamp

-- ---- Verify every normalized table ---------------------------------------
SELECT * FROM Customers;
SELECT * FROM Suppliers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;

-- ---- BONUS LIVE DEMO -- read the fully normalized data like a sentence ----
SELECT
    o.OrderID,
    c.CustomerName,
    p.ProductName,
    s.SupplierName,
    od.Quantity,
    p.Price,
    (od.Quantity * p.Price) AS LineTotal
FROM OrderDetails od
JOIN Orders o     ON od.OrderID = o.OrderID
JOIN Customers c  ON o.CustomerID = c.CustomerID
JOIN Products p   ON od.ProductID = p.ProductID
JOIN Suppliers s  ON p.SupplierID = s.SupplierID
ORDER BY o.OrderID;

-- Proof that redundancy is gone: Rahul's phone number now exists in exactly
-- ONE row, no matter how many orders he places.
SELECT COUNT(*) AS rahul_phone_row_count
FROM Customers
WHERE CustomerName = 'Rahul';


-- =============================================================================
-- SECTION 10 : BEFORE VS AFTER COMPARISON (UNF -> 3NF)
-- -----------------------------------------------------------------------------
--   UNF
--    |
--    v
--   OrderData
--
--   1NF
--    |
--    v
--   Atomic Values
--
--   2NF
--    |
--    v
--   Students | Courses | Enrollment
--
--   3NF
--    |
--    v
--   Customers | Products | Suppliers | Orders | OrderDetails
-- -----------------------------------------------------------------------------
-- One messy, repeating-values table became FIVE clean, relational tables --
-- each one holding exactly one kind of fact, connected only through keys.
-- =============================================================================


-- =============================================================================
-- SECTION 11 : PRACTICAL LAB ACTIVITY
-- -----------------------------------------------------------------------------
-- Work through every step below using the OrderData table from Section 4.
-- Do NOT copy the answers already demonstrated above -- work them out
-- independently first, then compare.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- STEP 1 : Identify Redundancy                                 [Difficulty: Easy]
-- -----------------------------------------------------------------------------
--   Run: SELECT * FROM OrderData;
--   List every column whose value repeats across more than one row.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- STEP 2 : Find the Anomalies                                  [Difficulty: Easy]
-- -----------------------------------------------------------------------------
--   Write one real example, using actual values from OrderData, of:
--     (a) an Update Anomaly   (b) an Insert Anomaly   (c) a Delete Anomaly
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- STEP 3 : Draw the Normalized Schema                        [Difficulty: Medium]
-- -----------------------------------------------------------------------------
--   On paper or a whiteboard, draw the five normalized tables (Customers,
--   Suppliers, Products, Orders, OrderDetails), marking every PRIMARY KEY
--   and FOREIGN KEY, BEFORE looking at Section 9 above.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- STEP 4 : Create the Tables                                 [Difficulty: Medium]
-- -----------------------------------------------------------------------------
--   Write the CREATE TABLE statements for your Step 3 design from scratch,
--   in a scratch database, without copying Section 9.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- STEP 5 : Insert Data                                       [Difficulty: Medium]
-- -----------------------------------------------------------------------------
--   Insert at least 5 customers, 3 suppliers, and 8 products into your own
--   tables, then link them through Orders and OrderDetails.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- STEP 6 : Verify the Output                                   [Difficulty: Easy]
-- -----------------------------------------------------------------------------
--   Run a SELECT on every table you created, then re-run the BONUS LIVE
--   DEMO join query pattern from Section 9 against your own tables.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- CHALLENGE ACTIVITY                                             [Difficulty: Hard]
-- -----------------------------------------------------------------------------
--   Using your Step 4 tables, prove the normalized design fixes all three
--   anomalies from Section 6:
--     1. Add a new customer WITHOUT creating an order for them.
--        (Proves the Insert Anomaly is gone.)
--     2. Update one supplier's phone number in ONE place only.
--        (Proves the Update Anomaly is gone.)
--     3. Delete one order and verify the customer's own record still exists.
--        (Proves the Delete Anomaly is gone.)
--   No solutions are provided here on purpose.
-- -----------------------------------------------------------------------------


-- =============================================================================
-- SECTION 12 : COMMON INTERVIEW QUESTIONS (NO SOLUTIONS)
-- -----------------------------------------------------------------------------
-- 20 questions, grouped by difficulty. Answer out loud / on a whiteboard --
-- no solutions are written here on purpose.
-- =============================================================================

-- ---- FOUNDATION -------------------------------------------------------------
--   1. What is Normalization, and why is it needed in database design?
--   2. What is Data Redundancy? Give a real-world example.
--   3. What is an Update Anomaly?
--   4. What is an Insert Anomaly?
--   5. What is a Delete Anomaly?
--   6. What is the difference between an unnormalized table and a
--      normalized table?
--   7. Name the first three Normal Forms, in order.

-- ---- MEDIUM -------------------------------------------------------------------
--   8. What is First Normal Form (1NF)? What rule must every column
--      satisfy?
--   9. Does 1NF remove duplicate rows? Explain your answer.
--  10. What is a Composite Key? Give an example.
--  11. What is Partial Dependency, and in which Normal Form is it removed?
--  12. What is Second Normal Form (2NF)? When does it not apply to a table?
--  13. Why must a table have a composite key before Partial Dependency can
--      even exist?
--  14. Convert the table Enrollment(StudentID, CourseID, StudentName,
--      CourseName) into 2NF.

-- ---- PLACEMENT ----------------------------------------------------------
--  15. What is the difference between 2NF and 3NF?
--  16. What is Transitive Dependency? Give a real-world example.
--  17. What is Third Normal Form (3NF)? State its rule in one line.
--  18. When would you deliberately denormalize a database? Give a business
--      scenario.
--  19. Design a normalized schema (up to 3NF) for an E-commerce Orders
--      system -- name every table and its keys.
--  20. How does normalization affect JOIN performance, and why might a
--      production reporting system choose to denormalize anyway?


-- =============================================================================
-- SECTION 13 : END SUMMARY
-- =============================================================================
-- SKILLS MASTERED
--
-- ✔ Redundancy
-- ✔ Update / Insert / Delete Anomaly
-- ✔ First Normal Form
-- ✔ Second Normal Form
-- ✔ Third Normal Form
-- ✔ Partial Dependency
-- ✔ Transitive Dependency
-- ✔ Database Design
--
-- Next Module : SQL JOINS
-- =============================================================================
