-- =============================================================================
-- SQL Day 8 Dataset : E-commerce Database
-- Author : Shalinee Priya
-- Module : SQL JOINS
-- Description : Reusable dataset for Day 8 and later modules (Day 9 Subqueries,
--               Day 10 Views, ...). This is the single source of truth for the
--               five tables used across this module chain — later modules
--               SOURCE this file and must never ALTER the tables it creates.
--
-- v2 NOTE: Suppliers.city and Orders.order_date are included from the start
-- (previously bolted on later by Day 9 via ALTER TABLE). Baking them in here
-- means every downstream module reads a finalized schema and no module has to
-- mutate a prior module's tables to teach its own content.
-- =============================================================================

DROP DATABASE IF EXISTS joins_db;
CREATE DATABASE joins_db;
USE joins_db;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50)
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE OrderDetails (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

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

-- Suppliers.city powers the Day 9 "products supplied by Delhi suppliers" scenario.
INSERT INTO Suppliers VALUES
(1,'TechWorld','9991111111','Delhi'),
(2,'HomeEssentials','9991111112','Mumbai'),
(3,'FashionHub','9991111113','Delhi'),
(4,'FreshFoods','9991111114','Pune'),
(5,'OfficeMart','9991111115','Delhi'),
(6,'Global Suppliers','9991111116','Bangalore'),
(7,'Future Electronics','9991111117','Delhi'),
(8,'Dream Traders','9991111118','Chandigarh');

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

-- Orders.order_date powers the Day 9 "latest order" scenario. Dates follow the
-- same sequence the order_ids were assigned in (1001 = earliest, 1012 = most
-- recent), so "latest order" resolves exactly as it would with real timestamps.
INSERT INTO Orders VALUES
(1001,101,'2026-01-05'),
(1002,102,'2026-01-07'),
(1003,101,'2026-01-09'),
(1004,103,'2026-01-12'),
(1005,104,'2026-01-15'),
(1006,105,'2026-01-18'),
(1007,106,'2026-01-21'),
(1008,107,'2026-01-24'),
(1009,108,'2026-01-27'),
(1010,109,'2026-01-30'),
(1011,105,'2026-02-02'),
(1012,110,'2026-02-05');

INSERT INTO OrderDetails VALUES
(1001,201,1),(1001,202,2),
(1002,203,1),(1002,206,3),
(1003,204,1),(1003,203,5),
(1004,205,1),(1004,207,2),
(1005,208,4),(1005,209,3),
(1006,201,1),(1006,213,2),
(1007,202,4),(1007,211,1),
(1008,203,2),
(1009,212,1),(1009,206,2),
(1010,207,3),(1010,208,2),
(1011,201,1),(1011,205,1),
(1012,202,3),(1012,209,4);

-- Verification
SELECT * FROM Customers;
SELECT * FROM Suppliers;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;
