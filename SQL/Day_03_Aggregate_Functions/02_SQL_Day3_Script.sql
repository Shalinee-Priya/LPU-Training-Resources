-- ============================================================================
--  SQL DAY 3 -- AGGREGATE FUNCTIONS
-- ============================================================================
--  Author              : Shalinee Priya
--  Module              : SQL Training -- Day 3 of B.Tech SQL Training Series
--  Continuation Of     : SQL Day 2 -- Data Retrieval & Filtering
--
--  Learning Objectives :
--      1. Understand why businesses need summarized (aggregate) results
--         instead of raw row-by-row data.
--      2. Use COUNT(), SUM(), AVG(), MIN(), and MAX() to answer real
--         business questions.
--      3. Understand the difference between COUNT(*) and COUNT(column),
--         especially in the presence of NULL values.
--      4. Practice combining aggregate functions with WHERE to answer
--         targeted, single-branch / single-city business questions.
--
--  Execution Instructions :
--      1. Open this file in MySQL Workbench (MySQL 8.0+).
--      2. Ensure the `college_db` database and its `students` table already
--         exist (created in the Day 1 / Day 2 scripts). This script does
--         NOT create the database or the table -- it only extends it.
--      3. Run the script top to bottom (Ctrl+Shift+Enter to run all, or
--         run statement by statement / section by section).
--      4. Section 8 contains interview questions as comments ONLY -- there
--         are no solution queries for them. Use them for self-practice.
-- ============================================================================


-- ============================================================================
--  SECTION 2 -- CONTINUE EXISTING DATASET
-- ============================================================================

-- Use the existing database created on Day 1. Do NOT recreate it.
USE college_db;
-- ============================================================================
-- 2.1  EXTEND THE EXISTING STUDENTS TABLE
--      (Continuation of Day 1 & Day 2)
--
-- Assumes the `students` table already contains:
-- student_id, name, branch, cgpa, age, city
--
-- Expected Result:
-- The table should contain the same 10 students with four new columns
-- (fees, attendance, email, phone_no) populated successfully.
-- ============================================================================

ALTER TABLE students
    ADD COLUMN IF NOT EXISTS fees INT,
    ADD COLUMN IF NOT EXISTS attendance INT,
    ADD COLUMN IF NOT EXISTS email VARCHAR(100),
    ADD COLUMN IF NOT EXISTS phone_no VARCHAR(15);

-- ----------------------------------------------------------------------------
-- 2.2  Update all 10 existing students with realistic values.
--      Fees        : between 75,000 and 1,20,000
--      Attendance  : between 68 and 98
--      Email       : a few students left NULL on purpose
--      Phone No.   : a few students left NULL on purpose
--      name, branch, cgpa, age, city are NOT touched.
-- ----------------------------------------------------------------------------
UPDATE students
SET    fees = 118000, attendance = 96, email = 'aarav.sharma@example.com', phone_no = '9876500001'
WHERE  student_id = 101;

UPDATE students
SET    fees = 105000, attendance = 92, email = 'diya.verma@example.com',   phone_no = NULL
WHERE  student_id = 102;

UPDATE students
SET    fees = 82000,  attendance = 88, email = NULL,                       phone_no = '9876500003'
WHERE  student_id = 103;

UPDATE students
SET    fees = 95000,  attendance = 90, email = 'meera.nair@example.com',   phone_no = '9876500004'
WHERE  student_id = 104;

UPDATE students
SET    fees = 76000,  attendance = 79, email = 'sanya.gupta@example.com',  phone_no = '9876500005'
WHERE  student_id = 105;

UPDATE students
SET    fees = 99000,  attendance = 85, email = NULL,                       phone_no = NULL
WHERE  student_id = 106;

UPDATE students
SET    fees = 120000, attendance = 94, email = 'ananya.iyer@example.com',  phone_no = '9876500007'
WHERE  student_id = 107;

UPDATE students
SET    fees = 88000,  attendance = 68, email = 'aditya.rao@example.com',   phone_no = '9876500008'
WHERE  student_id = 108;

UPDATE students
SET    fees = 75000,  attendance = 81, email = NULL,                       phone_no = '9876500009'
WHERE  student_id = 109;

UPDATE students
SET    fees = 110000, attendance = 98, email = 'priya.menon@example.com',  phone_no = NULL
WHERE  student_id = 110;

-- ============================================================================
-- VERIFY UPDATED DATASET
-- ============================================================================
SELECT
    student_id,
    name,
    branch,
    cgpa,
    fees,
    attendance,
    email,
    phone_no
FROM students
ORDER BY student_id;

-- Quick check: confirm the table now carries the new columns and values.
SELECT * FROM students;


-- ============================================================================
--  SECTION 3 -- COUNT()
-- ============================================================================
-- COUNT() tells us HOW MANY rows/values exist. It is the most commonly
-- used aggregate function for business questions like "how many students?"

-- 3.1  COUNT(*) -- counts every row in the table, NULLs included.
SELECT COUNT(*) AS total_students
FROM   students;

-- 3.2  COUNT(student_id) -- counts non-NULL values in student_id.
--      Since student_id is a primary key (never NULL), this equals COUNT(*).
SELECT COUNT(student_id) AS total_student_ids
FROM   students;

-- 3.3  COUNT(email) -- counts only rows where email IS NOT NULL.
--      This will be LESS than COUNT(*) because some emails are NULL.
SELECT COUNT(email) AS students_with_email
FROM   students;

-- 3.4  COUNT with WHERE -- count rows that match a condition.
--      Business question: How many students belong to CSE?
SELECT COUNT(*) AS cse_student_count
FROM   students
WHERE  branch = 'CSE';


-- ============================================================================
--  SECTION 4 -- SUM()
-- ============================================================================
-- SUM() adds up every value in a numeric column. It only works on numeric
-- columns -- using it on a text column raises an error.

-- 4.1  Total fees collected across ALL students.
--      Business question: What is our total fee collection this year?
SELECT SUM(fees) AS total_fees_collected
FROM   students;

-- 4.2  Total fees collected from CSE students only.
--      Business question: How much fee revenue came from the CSE branch?
SELECT SUM(fees) AS total_fees_cse
FROM   students
WHERE  branch = 'CSE';

-- 4.3  Total attendance -- shown ONLY to demonstrate how SUM() behaves.
--      NOTE: Summing attendance percentages across students is not a
--      meaningful business metric (attendance is normally AVERAGED, not
--      added up) -- this row exists purely for teaching purposes.
SELECT SUM(attendance) AS total_attendance_demo_only
FROM   students;


-- ============================================================================
--  SECTION 5 -- AVG()
-- ============================================================================
-- AVG() returns the mean (average) of a numeric column.

-- 5.1  Average CGPA across all students.
--      Business question: How is the batch performing academically overall?
SELECT AVG(cgpa) AS average_cgpa
FROM   students;

-- 5.2  Average attendance across all students.
--      Business question: What is the overall attendance health of the batch?
SELECT AVG(attendance) AS average_attendance
FROM   students;

-- 5.3  Average fees of IT students only (AVG paired with WHERE).
--      Business question: What is the average fee paid by IT students?
SELECT AVG(fees) AS average_fees_it
FROM   students
WHERE  branch = 'IT';


-- ============================================================================
--  SECTION 6 -- MIN() & MAX()
-- ============================================================================
-- MIN() and MAX() find the smallest and largest value in a column.
-- They work on BOTH numbers and text:
--   - On numeric columns, MIN/MAX compare values mathematically.
--   - On text (VARCHAR) columns, MySQL compares strings using the column's
--     collation, which -- for the default collations -- sorts them the same
--     way a dictionary does (A, B, C ... Z). So MIN(name) returns the name
--     that would appear FIRST alphabetically, and MAX(name) returns the
--     name that would appear LAST alphabetically.

-- 6.1  Youngest student (smallest age).
SELECT MIN(age) AS youngest_age
FROM   students;

-- 6.2  Highest CGPA in the college.
SELECT MAX(cgpa) AS highest_cgpa
FROM   students;

-- 6.3  Lowest attendance recorded.
SELECT MIN(attendance) AS lowest_attendance
FROM   students;

-- 6.4  Alphabetically first student name.
SELECT MIN(name) AS first_name_alphabetically
FROM   students;

-- 6.5  Alphabetically last student name.
SELECT MAX(name) AS last_name_alphabetically
FROM   students;


-- ============================================================================
--  SECTION 7 -- COUNT(*) vs COUNT(column)
-- ============================================================================
-- KEY DIFFERENCE:
--   COUNT(*)       -> counts EVERY row, regardless of NULLs.
--   COUNT(column)  -> counts only the rows where that COLUMN is NOT NULL.
--
-- We deliberately left some `email` values as NULL in Section 2, so the
-- two counts below will differ -- run them side by side to see it.

-- 7.1  COUNT(*) -- total number of rows in the table.
SELECT COUNT(*) AS count_star
FROM   students;

-- 7.2  COUNT(email) -- only rows where email IS NOT NULL.
SELECT COUNT(email) AS count_email
FROM   students;

-- 7.3  Side-by-side comparison in a single result set.
SELECT COUNT(*)     AS count_star,
       COUNT(email) AS count_email,
       COUNT(*) - COUNT(email) AS students_missing_email
FROM   students;


-- ============================================================================
--  SECTION 8 -- INTERVIEW PRACTICE  (Questions Only -- No Solutions Below)
-- ============================================================================
-- Write the SQL query for each question yourself. Do not scroll to any
-- "answer" -- there isn't one in this file. Use Sections 3-7 above as a
-- reference for the syntax you'll need.

-- ---------------------------
-- EASY
-- ---------------------------
-- 1. Count all students.
-- 2. Find the highest CGPA in the college.
-- 3. Find the lowest age among all students.
-- 4. Find the average attendance of all students.
-- 5. Find the total fees collected from all students.

-- ---------------------------
-- MEDIUM
-- ---------------------------
-- 6.  Count how many students are from Delhi.
-- 7.  Find the average CGPA of CSE students.
-- 8.  Find the highest attendance among IT students.
-- 9.  Find the lowest fees paid among ECE students.
-- 10. Count how many students have a phone number available (not NULL).

-- ---------------------------
-- PLACEMENT LEVEL
-- ---------------------------
-- 11. Count how many students have a NULL email.
-- 12. Find the average fees of students aged above 20.
-- 13. Find the highest CGPA among students from Delhi.
-- 14. Find the total fees collected from CSE and IT students combined.
-- 15. Explain the difference between COUNT(*) and COUNT(email) for this
--     table, and write both queries to prove your answer.

-- ============================================================================
--  END OF SQL DAY 3 SCRIPT
-- ============================================================================
