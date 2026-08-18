-- ============================================================================
-- SQL DAY 1 - INTRODUCTION TO DATABASES & SQL
-- ============================================================================
-- Title    : SQL Day 1 - Introduction to Databases & SQL
-- Author   : Shalinee Priya
-- Module   : B.Tech SQL Training
--
-- Description:
--   This script introduces first-year B.Tech students to the fundamentals
--   of relational databases using MySQL. By running this script from top
--   to bottom in MySQL Workbench, students will learn how to:
--     1. Create and select a database.
--     2. Create a table with appropriate data types and a primary key.
--     3. Insert multiple records into a table using a single statement.
--     4. Write basic SELECT queries (SELECT *, specific columns, WHERE,
--        ORDER BY, and LIMIT).
--     5. Attempt independent practice questions to reinforce the concepts
--        covered in this session.
--
-- Instructions:
--   Run this script sequentially in MySQL Workbench (top to bottom).
--   Highlight and execute one statement at a time if you want to observe
--   the result of each step individually.
-- ============================================================================


-- ============================================================================
-- SECTION 1 : CREATE DATABASE
-- ============================================================================

-- Create a new database named 'college_db' to store our student records.
-- This will fail with an error if a database with the same name already
-- exists, so drop it first only if you intend to start fresh.
DROP DATABASE IF EXISTS college_db;
CREATE DATABASE college_db;

-- List all databases currently available on the MySQL server.
-- This helps confirm that 'college_db' was created successfully.
SHOW DATABASES;

-- Select 'college_db' as the active database for all following commands.
-- Every CREATE TABLE / INSERT / SELECT statement below will run inside
-- this database until another USE statement changes the context.
USE college_db;


-- ============================================================================
-- SECTION 2 : CREATE TABLE
-- ============================================================================

-- Create a 'students' table to hold basic academic information.
-- Column details:
--   student_id  -> Unique identifier for each student (Primary Key)
--   name        -> Full name of the student
--   branch      -> Engineering branch/department (e.g., CSE, ECE, MECH)
--   cgpa        -> Cumulative Grade Point Average (e.g., 8.5)
--   age         -> Age of the student in years
--   city        -> Home city of the student
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name       VARCHAR(50),
    branch     VARCHAR(20),
    cgpa       DECIMAL(3,1),
    age        INT,
    city       VARCHAR(30)
);

-- Display the structure (column names, data types, keys) of the
-- 'students' table to verify it was created as expected.
DESCRIBE students;


-- ============================================================================
-- SECTION 3 : INSERT DATA
-- ============================================================================

-- Insert 10 sample student records in a single INSERT statement.
-- Records include a diverse mix of branches, ages, cities, and CGPAs
-- so that later queries (WHERE, ORDER BY, etc.) return meaningful results.
INSERT INTO students (student_id, name, branch, cgpa, age, city)
VALUES
    (1,  'Aarav Sharma',    'CSE',  9.1, 19, 'Delhi'),
    (2,  'Priya Nair',      'ECE',  8.4, 20, 'Kochi'),
    (3,  'Rohan Verma',     'MECH', 7.2, 21, 'Lucknow'),
    (4,  'Ishita Gupta',    'CSE',  8.9, 19, 'Jaipur'),
    (5,  'Kabir Singh',     'CIVIL',6.8, 22, 'Chandigarh'),
    (6,  'Ananya Reddy',    'ECE',  9.3, 20, 'Hyderabad'),
    (7,  'Vivaan Joshi',    'IT',   7.6, 19, 'Pune'),
    (8,  'Sneha Iyer',      'CSE',  8.1, 21, 'Chennai'),
    (9,  'Aditya Kumar',    'MECH', 6.5, 22, 'Patna'),
    (10, 'Meera Pillai',    'IT',   8.7, 20, 'Thiruvananthapuram');


-- ============================================================================
-- SECTION 4 : FIRST QUERIES
-- ============================================================================

-- Query 1: SELECT * - Retrieve all columns and all rows from the
-- 'students' table. Useful for viewing the entire dataset at once.
SELECT *
FROM students;

-- Query 2: SELECT specific columns - Retrieve only the 'name' and
-- 'branch' columns instead of the entire table.
SELECT name, branch
FROM students;

-- Query 3: WHERE clause - Filter rows to show only students who belong
-- to the 'CSE' branch.
SELECT *
FROM students
WHERE branch = 'CSE';

-- Query 4: ORDER BY - Retrieve all students sorted by CGPA in
-- descending order (highest CGPA first).
SELECT *
FROM students
ORDER BY cgpa DESC;

-- Query 5: LIMIT - Retrieve only the first 5 rows from the table.
-- Useful when you only need a quick preview of the data.
SELECT *
FROM students
LIMIT 5;


-- ============================================================================
-- SECTION 5 : PRACTICE QUESTIONS
-- ============================================================================
-- Attempt the following questions on your own using the 'students' table.
-- Do NOT look up the answers immediately - try writing the queries first.
-- (No solutions are provided here; solutions will be discussed in class.)

-- 1. Display all students and all their details.

-- 2. Show only the students who belong to the CSE branch.

-- 3. Find all students with a CGPA above 8.0.

-- 4. Display only the names and cities of all students.

-- 5. Show the details of the oldest student (maximum age).

-- 6. List all students sorted by name in alphabetical (ascending) order.

-- 7. Display the top 3 students with the highest CGPA.

-- 8. Find all students who live in 'Pune' or 'Chennai'.

-- 9. Show all students aged between 19 and 21 (inclusive).

-- 10. Display all ECE and IT branch students, sorted by CGPA in
--     descending order.

-- ============================================================================
-- END OF SQL DAY 1 SCRIPT
-- ============================================================================
