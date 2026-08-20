-- ============================================================
-- SQL DAY 12 : SQL INDEXES
-- FILE        : 03_SQL_Day12_Dataset.sql
-- PURPOSE     : HR Analytics dataset (same business domain as Day 10 / Day 11)
--               Rebuilt at sufficient volume so that index behaviour,
--               EXPLAIN output, and selectivity concepts are visible
--               and meaningful, not just theoretical.
-- DATABASE    : MySQL 8.0+
-- CLIENT      : MySQL Workbench
-- RERUNNABLE  : Yes. Safe to execute top to bottom, any number of times.
-- ============================================================

DROP DATABASE IF EXISTS hr_analytics_day12;
CREATE DATABASE hr_analytics_day12;
USE hr_analytics_day12;

-- ------------------------------------------------------------
-- 1. TABLE STRUCTURE
-- ------------------------------------------------------------
-- NOTE: No indexes other than the PRIMARY KEY are created here.
-- Every SECONDARY / UNIQUE / COMPOSITE index used in this module
-- is created intentionally inside 02_SQL_Day12_Script.sql so that
-- students can observe the "before vs after" effect.
-- ------------------------------------------------------------

CREATE TABLE employees (
    emp_id      INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50)    NOT NULL,
    last_name   VARCHAR(50)    NOT NULL,
    email       VARCHAR(120)   NOT NULL,
    department  VARCHAR(30)    NOT NULL,
    city        VARCHAR(30)    NOT NULL,
    salary      DECIMAL(10,2)  NOT NULL,
    hire_date   DATE           NOT NULL,
    phone       VARCHAR(15)    NOT NULL,
    bonus_pct   DECIMAL(5,2)   NOT NULL DEFAULT 0.00
);

-- ------------------------------------------------------------
-- 2. REFERENCE LISTS (used only to generate realistic data)
-- ------------------------------------------------------------

CREATE TEMPORARY TABLE ref_first_names (id INT, name VARCHAR(50));
INSERT INTO ref_first_names (id, name) VALUES
(0,'Aarav'),(1,'Vivaan'),(2,'Aditya'),(3,'Vihaan'),(4,'Arjun'),
(5,'Sai'),(6,'Reyansh'),(7,'Krishna'),(8,'Ishaan'),(9,'Rohan'),
(10,'Ananya'),(11,'Diya'),(12,'Isha'),(13,'Kavya'),(14,'Meera'),
(15,'Priya'),(16,'Riya'),(17,'Saanvi'),(18,'Tanya'),(19,'Zara'),
(20,'Karan'),(21,'Nikhil'),(22,'Manish'),(23,'Suresh'),(24,'Ramesh'),
(25,'Deepak'),(26,'Anil'),(27,'Sanjay'),(28,'Vikram'),(29,'Rajesh'),
(30,'Neha'),(31,'Pooja'),(32,'Swati'),(33,'Anjali'),(34,'Kritika'),
(35,'Shalini'),(36,'Divya'),(37,'Sneha'),(38,'Simran'),(39,'Nidhi'),
(40,'Aman'),(41,'Harsh'),(42,'Yash'),(43,'Kabir'),(44,'Dev'),
(45,'Om'),(46,'Aryan'),(47,'Raghav'),(48,'Siddharth'),(49,'Varun');

CREATE TEMPORARY TABLE ref_last_names (id INT, name VARCHAR(50));
INSERT INTO ref_last_names (id, name) VALUES
(0,'Sharma'),(1,'Verma'),(2,'Gupta'),(3,'Kumar'),(4,'Singh'),
(5,'Patel'),(6,'Reddy'),(7,'Rao'),(8,'Nair'),(9,'Iyer'),
(10,'Mehta'),(11,'Joshi'),(12,'Kapoor'),(13,'Malhotra'),(14,'Chopra'),
(15,'Bose'),(16,'Das'),(17,'Pillai'),(18,'Menon'),(19,'Agarwal'),
(20,'Bansal'),(21,'Saxena'),(22,'Trivedi'),(23,'Bhatt'),(24,'Desai'),
(25,'Chauhan'),(26,'Rathore'),(27,'Yadav'),(28,'Mishra'),(29,'Pandey'),
(30,'Tiwari'),(31,'Dubey'),(32,'Shah'),(33,'Khan'),(34,'Ahmed'),
(35,'Sinha'),(36,'Ghosh'),(37,'Chatterjee'),(38,'Mukherjee'),(39,'Dutta'),
(40,'Kaur'),(41,'Grewal'),(42,'Chandra'),(43,'Bhatia'),(44,'Suri'),
(45,'Arora'),(46,'Khanna'),(47,'Sethi'),(48,'Bhalla'),(49,'Chawla');

CREATE TEMPORARY TABLE ref_departments (id INT, name VARCHAR(30));
INSERT INTO ref_departments (id, name) VALUES
(0,'IT'),(1,'HR'),(2,'Finance'),(3,'Sales'),(4,'Marketing'),
(5,'Operations'),(6,'Support'),(7,'Legal'),(8,'Admin'),(9,'R&D');

CREATE TEMPORARY TABLE ref_cities (id INT, name VARCHAR(30));
INSERT INTO ref_cities (id, name) VALUES
(0,'Bangalore'),(1,'Mumbai'),(2,'Delhi'),(3,'Hyderabad'),(4,'Chennai'),
(5,'Pune'),(6,'Kolkata'),(7,'Ahmedabad'),(8,'Jaipur'),(9,'Lucknow'),
(10,'Noida'),(11,'Gurgaon'),(12,'Chandigarh'),(13,'Kochi'),(14,'Indore');

-- ------------------------------------------------------------
-- 3. BULK DATA GENERATION
-- ------------------------------------------------------------
-- 100,000 employee rows: large enough that a full table scan is
-- measurably slower than an index lookup, which is the entire
-- point of this module. Distribution is deliberately UNEVEN
-- across department/city so selectivity differences are real,
-- not simulated.
-- ------------------------------------------------------------

SET SESSION cte_max_recursion_depth = 200000;

INSERT INTO employees (first_name, last_name, email, department, city, salary, hire_date, phone, bonus_pct)
WITH RECURSIVE seq (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT
    fn.name AS first_name,
    ln.name AS last_name,
    CONCAT(
        LOWER(fn.name), '.', LOWER(ln.name), s.n, '@hranalytics.com'
    ) AS email,
    -- Uneven department distribution: IT/Sales/Operations are large,
    -- Legal/R&D are deliberately small (low cardinality demo later).
    CASE
        WHEN s.n MOD 100 < 25 THEN 'IT'
        WHEN s.n MOD 100 < 45 THEN 'Sales'
        WHEN s.n MOD 100 < 60 THEN 'Operations'
        WHEN s.n MOD 100 < 72 THEN 'Support'
        WHEN s.n MOD 100 < 82 THEN 'Finance'
        WHEN s.n MOD 100 < 90 THEN 'Marketing'
        WHEN s.n MOD 100 < 95 THEN 'HR'
        WHEN s.n MOD 100 < 98 THEN 'Admin'
        WHEN s.n MOD 100 < 99 THEN 'Legal'
        ELSE 'R&D'
    END AS department,
    city.name AS city,
    -- Salary varies by a base tied to department "rank" plus a spread
    ROUND(28000 + ((s.n * 37) MOD 95) * 950 + ((s.n MOD 11) * 1500), 2) AS salary,
    DATE_ADD('2015-01-01', INTERVAL (s.n * 7) MOD 4250 DAY) AS hire_date,
    CONCAT('9', LPAD((100000000 + s.n), 9, '0')) AS phone,
    ROUND((s.n MOD 16), 2) AS bonus_pct
FROM seq s
JOIN ref_first_names fn  ON fn.id = s.n MOD 50
JOIN ref_last_names  ln  ON ln.id = (s.n * 3) MOD 50
JOIN ref_cities       city ON city.id = (s.n * 7) MOD 15;

DROP TEMPORARY TABLE IF EXISTS ref_first_names;
DROP TEMPORARY TABLE IF EXISTS ref_last_names;
DROP TEMPORARY TABLE IF EXISTS ref_departments;
DROP TEMPORARY TABLE IF EXISTS ref_cities;

-- ------------------------------------------------------------
-- 4. SANITY CHECKS
-- ------------------------------------------------------------

SELECT COUNT(*) AS total_employees FROM employees;

SELECT department, COUNT(*) AS headcount
FROM employees
GROUP BY department
ORDER BY headcount DESC;

SELECT MIN(salary) AS min_salary, MAX(salary) AS max_salary, ROUND(AVG(salary),2) AS avg_salary
FROM employees;

-- Dataset generation complete.
-- No indexes beyond PRIMARY KEY (emp_id) exist at this point.
-- All indexing is taught and created inside 02_SQL_Day12_Script.sql.
