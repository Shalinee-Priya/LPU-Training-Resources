-- =====================================================================
-- SECTION 1: HEADER
-- =====================================================================
-- Title              : SQL Day 2 -- Data Retrieval & Filtering
-- Author             : Shalinee Priya
-- Module             : SQL Training Series -- Day 2
-- Database           : college_db (created and populated on Day 1)
-- Table Used         : students (student_id, name, branch, cgpa, age, city)
--
-- Learning Objectives:
--   1. Recall the Day 1 database and table structure.
--   2. Retrieve data using SELECT, column lists, and DISTINCT.
--   3. Rename and compute columns using AS and expressions.
--   4. Filter rows using WHERE, AND, OR, and NOT.
--   5. Apply BETWEEN, IN, LIKE, and IS NULL for real-world filtering.
--   6. Sort and limit results using ORDER BY and LIMIT.
--   7. Apply today's concepts to interview-style business questions.
--
-- Execution Instruction:
--   Open this file in MySQL Workbench with a live connection to the
--   MySQL server used on Day 1. Run statements top to bottom, one at a
--   time (Ctrl+Enter / the lightning-bolt "Execute Current Statement"
--   icon), so each result grid can be inspected before moving on.
--   Do NOT run the whole script in one click on a shared/production
--   server -- it is written for sequential, classroom-style execution.
-- =====================================================================


-- =====================================================================
-- SECTION 2: DAY 1 REVISION
-- =====================================================================

-- Switch the active connection to the college_db database created on
-- Day 1. Every statement below runs against this database.
USE college_db;

-- List every table that exists inside college_db. On Day 2 this should
-- show a single table: students.
SHOW TABLES;

-- Describe the structure of the students table -- column names, data
-- types, nullability, keys, and defaults. Use this to recall the exact
-- column list before writing any query.
DESC students;

-- Retrieve every column and every row currently stored in students.
-- This is the full Day 1 dataset, unfiltered.
SELECT *
FROM students;


-- =====================================================================
-- SECTION 3: DATA RETRIEVAL
-- =====================================================================

-- --------------------------------------------------------------
-- 3.1 SELECT * -- return every column for every row
-- --------------------------------------------------------------
SELECT *
FROM students;

-- --------------------------------------------------------------
-- 3.2 Specific columns -- return only the columns that are needed
-- --------------------------------------------------------------
SELECT name, branch, cgpa
FROM students;

-- --------------------------------------------------------------
-- 3.3 DISTINCT -- remove duplicate values from the result
-- --------------------------------------------------------------
-- Business need: "What branches does the college actually offer?"
SELECT DISTINCT branch
FROM students;

-- --------------------------------------------------------------
-- 3.4 AS -- alias a column so the output reads more clearly
-- --------------------------------------------------------------
-- AS only renames the column in the RESULT SET; the students table
-- itself is never modified.
SELECT name AS student_name,
       branch AS department_name
FROM students;

-- --------------------------------------------------------------
-- 3.5 Expressions -- compute a new value from existing columns
-- --------------------------------------------------------------
-- Example 1: project each student's age one year from now.
SELECT name,
       age,
       age + 1 AS age_next_year
FROM students;

-- Example 2: convert CGPA (out of 10) into a percentage.
SELECT name,
       cgpa,
       cgpa * 10 AS percentage
FROM students;


-- =====================================================================
-- SECTION 4: FILTERING
-- =====================================================================

-- --------------------------------------------------------------
-- 4.1 WHERE -- return only the rows that match a condition
-- --------------------------------------------------------------
-- Business need: "Which students are placement-ready (CGPA > 8.0)?"
SELECT name, cgpa
FROM students
WHERE cgpa > 8.0;

-- --------------------------------------------------------------
-- 4.2 AND -- every condition must be true
-- --------------------------------------------------------------
SELECT name, branch, age
FROM students
WHERE branch = 'CSE'
  AND age > 20;

-- --------------------------------------------------------------
-- 4.3 OR -- at least one condition must be true
-- --------------------------------------------------------------
SELECT name, branch
FROM students
WHERE branch = 'CSE'
   OR branch = 'IT';

-- --------------------------------------------------------------
-- 4.4 NOT -- reverse a condition
-- --------------------------------------------------------------
SELECT name, branch
FROM students
WHERE NOT branch = 'ECE';


-- =====================================================================
-- SECTION 5: SPECIAL OPERATORS
-- =====================================================================

-- --------------------------------------------------------------
-- 5.1 BETWEEN -- match values within an inclusive range
-- --------------------------------------------------------------
-- Business need: "Find students aged 18 to 22 for an internship drive."
SELECT name, age
FROM students
WHERE age BETWEEN 18 AND 22;

-- --------------------------------------------------------------
-- 5.2 IN -- match any value from a fixed list
-- --------------------------------------------------------------
SELECT name, branch
FROM students
WHERE branch IN ('CSE', 'IT', 'ECE');

-- --------------------------------------------------------------
-- 5.3 LIKE -- match a text pattern (% = any characters, _ = one)
-- --------------------------------------------------------------
-- Business need: "Find every student whose name starts with 'A'."
SELECT name
FROM students
WHERE name LIKE 'A%';

-- --------------------------------------------------------------
-- 5.4 IS NULL -- find rows with missing data
-- --------------------------------------------------------------
-- Business need: "Which student records are missing a city value?"
SELECT name, city
FROM students
WHERE city IS NULL;


-- =====================================================================
-- SECTION 6: SORTING & LIMITING
-- =====================================================================

-- --------------------------------------------------------------
-- 6.1 ORDER BY ... ASC -- sort lowest to highest (default order)
-- --------------------------------------------------------------
SELECT name, cgpa
FROM students
ORDER BY cgpa ASC;

-- --------------------------------------------------------------
-- 6.2 ORDER BY ... DESC -- sort highest to lowest
-- --------------------------------------------------------------
SELECT name, cgpa
FROM students
ORDER BY cgpa DESC;

-- --------------------------------------------------------------
-- 6.3 Multiple-column sorting -- sort by branch first, then by CGPA
--     within each branch (useful for branch-wise merit lists)
-- --------------------------------------------------------------
SELECT name, branch, cgpa
FROM students
ORDER BY branch ASC, cgpa DESC;

-- --------------------------------------------------------------
-- 6.4 LIMIT -- restrict the output to a fixed number of rows
-- --------------------------------------------------------------
SELECT name, cgpa
FROM students
LIMIT 5;

-- --------------------------------------------------------------
-- 6.5 ORDER BY + LIMIT together -- the classic "Top N" pattern
-- --------------------------------------------------------------
-- Business need: "Show the top 5 students with the highest CGPA."
SELECT name, cgpa
FROM students
ORDER BY cgpa DESC
LIMIT 5;


-- =====================================================================
-- SECTION 7: MINI CHALLENGE (INTERVIEW-STYLE QUESTIONS)
-- =====================================================================
-- The 10 business questions below are for practice only.
-- Write and test your own SQL for each one -- no solutions are
-- provided in this script.

-- 1.  Display all unique branches offered by the college.

-- 2.  Find all students aged between 18 and 22.

-- 3.  Show each student's name with their CGPA percentage
--     (cgpa * 10) as percentage.

-- 4.  Display the top 3 students by CGPA.

-- 5.  Find students whose names start with 'S' and whose branch
--     is not 'ECE'.

-- 6.  List all students from the 'CSE' branch who have a CGPA
--     above 8.5.

-- 7.  Find every student record that has no city on file.

-- 8.  Display all students sorted by branch (A-Z), and within each
--     branch by CGPA (highest first).

-- 9.  Retrieve the bottom 5 students by CGPA (lowest scorers first).

-- 10. Find students whose name contains the letter 'a' and who are
--     older than 20 years.

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
