-- ============================================================================
--  SQL DAY 4 -- GROUP BY & HAVING
-- ============================================================================
--  Author              : Shalinee Priya
--  Module              : SQL Training -- Day 4 of B.Tech SQL Training Series
--  Continuation Of     : SQL Day 3 -- Aggregate Functions
--
--  Learning Objectives :
--      1. Understand why GROUP BY is used to summarize data by CATEGORY,
--         not just as a single overall total.
--      2. Learn SQL's true execution order and see how it differs from the
--         order in which we type SELECT ... FROM ... WHERE ... GROUP BY.
--      3. Combine GROUP BY with WHERE and HAVING to answer targeted,
--         filtered business questions.
--      4. Understand why HAVING can filter on aggregate results (AVG, SUM,
--         COUNT) while WHERE cannot.
--      5. Rank grouped results with ORDER BY and recognize the most common
--         GROUP BY / HAVING interview mistakes.
--
--  Execution Instructions :
--      1. Open this file in MySQL Workbench (MySQL 8.0+).
--      2. Ensure the `college_db` database and its `students` table already
--         exist (created in Day 1, extended with fees/attendance/email/
--         phone_no in Day 3). This script does NOT create or alter the
--         table -- it only queries the existing data.
--      3. Run the script top to bottom (Ctrl+Shift+Enter to run all, or
--         run statement by statement / section by section).
--      4. Section 8 shows INCORRECT queries as commented-out SQL for
--         teaching purposes -- do not uncomment and run them as-is; only
--         the CORRECT versions beneath them are meant to be executed.
--      5. Section 9 contains interview questions as comments ONLY -- there
--         are no solution queries for them. Use them for self-practice.
-- ============================================================================


-- ============================================================================
--  SECTION 2 -- CONTINUE EXISTING DATASET
-- ============================================================================

-- Use the existing database created on Day 1 and extended on Day 3.
-- Do NOT recreate the database or the table.
USE college_db;

-- ----------------------------------------------------------------------------
-- 2.1  Verify the dataset before running any GROUP BY / HAVING queries.
-- ----------------------------------------------------------------------------
SELECT *
FROM   students
ORDER BY student_id;

-- ----------------------------------------------------------------------------
-- 2.2  Quick Dataset Snapshot
--      Understand the categories before using GROUP BY.
-- ----------------------------------------------------------------------------

SELECT DISTINCT branch
FROM students;

SELECT DISTINCT city
FROM students;

-- ============================================================================
--  SECTION 3 -- SQL EXECUTION ORDER
-- ============================================================================
-- SQL is NOT executed in the order we type it. MySQL resolves FROM and
-- WHERE first, then forms groups, then filters those groups, and only
-- after that picks the columns listed in SELECT. ORDER BY runs last.
--
--   WRITING ORDER     (how we TYPE the query)
--   ------------------------------------------
--     SELECT -> FROM -> WHERE -> GROUP BY -> HAVING -> ORDER BY
--
--   EXECUTION ORDER   (how MySQL actually RUNS it)
--   ------------------------------------------------
--     FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY
--
--   +--------+     +-------+     +----------+     +--------+     +--------+     +----------+
--   |  FROM  | --> | WHERE | --> | GROUP BY | --> | HAVING | --> | SELECT | --> | ORDER BY |
--   +--------+     +-------+     +----------+     +--------+     +--------+     +----------+
--      (1)            (2)             (3)             (4)            (5)            (6)
--
-- This is exactly why HAVING is allowed to use AVG() / SUM() / COUNT(), but
-- WHERE is not -- by the time WHERE runs, no aggregate has been calculated
-- yet, because GROUP BY (step 3) and HAVING (step 4) haven't happened.


-- ============================================================================
--  SECTION 4 -- GROUP BY BASICS
-- ============================================================================
-- GROUP BY collapses many rows into ONE summary row per distinct value.
-- Any aggregate function in the SELECT list is then calculated separately
-- within each group, not across the whole table.

-- ----------------------------------------------------------------------------
-- 4.1  Example 1: Average CGPA, branch-wise.
--      Business question: How is each branch performing academically?
-- ----------------------------------------------------------------------------
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch;

-- ----------------------------------------------------------------------------
-- 4.2  Example 2: Student count, city-wise.
--      Business question: How many students do we have in each city?
-- ----------------------------------------------------------------------------
SELECT city,
       COUNT(*) AS student_count
FROM   students
GROUP BY city;

-- ----------------------------------------------------------------------------
-- 4.3  Example 3: Total fees collected, branch-wise.
--      Business question: How much fee revenue does each branch bring in?
-- ----------------------------------------------------------------------------
SELECT branch,
       SUM(fees) AS total_fees
FROM   students
GROUP BY branch;

-- ----------------------------------------------------------------------------
-- 4.4  Example 4: Maximum attendance, city-wise.
--      Business question: What is the best attendance recorded in each city?
-- ----------------------------------------------------------------------------
SELECT city,
       MAX(attendance) AS highest_attendance
FROM   students
GROUP BY city;


-- ============================================================================
--  SECTION 5 -- GROUP BY + WHERE
-- ============================================================================
-- WHERE filters ROWS before they are ever handed to GROUP BY. Only the rows
-- that survive WHERE take part in forming groups -- this is what it means
-- to "filter before grouping".

-- ----------------------------------------------------------------------------
-- 5.1  Delhi students only -- average CGPA branch-wise, Delhi students only.
-- ----------------------------------------------------------------------------
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
WHERE  city = 'Delhi'
GROUP BY branch;

-- ----------------------------------------------------------------------------
-- 5.2  IT students only -- student count city-wise, IT branch only.
-- ----------------------------------------------------------------------------
SELECT city,
       COUNT(*) AS it_student_count
FROM   students
WHERE  branch = 'IT'
GROUP BY city;

-- ----------------------------------------------------------------------------
-- 5.3  Age above 20 -- average fees branch-wise, students older than 20 only.
-- ----------------------------------------------------------------------------
SELECT branch,
       AVG(fees) AS avg_fees
FROM   students
WHERE  age > 20
GROUP BY branch;


-- ============================================================================
--  SECTION 6 -- HAVING
-- ============================================================================
-- HAVING filters GROUPS, after GROUP BY has already summarized the rows.
-- Because grouping has already happened by this point, HAVING is allowed
-- to test aggregate values such as AVG(), SUM(), and COUNT() -- something
-- WHERE can never do (see Section 3's execution order).

-- ----------------------------------------------------------------------------
-- 6.1  Branches with average CGPA above 8.
-- ----------------------------------------------------------------------------
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch
HAVING AVG(cgpa) > 8;

-- ----------------------------------------------------------------------------
-- 6.2  Cities having at least 2 students.
-- ----------------------------------------------------------------------------
SELECT city,
       COUNT(*) AS student_count
FROM   students
GROUP BY city
HAVING COUNT(*) >= 2;

-- ----------------------------------------------------------------------------
-- 6.3  Branches whose total fees exceed Rs. 2,00,000.
-- ----------------------------------------------------------------------------
SELECT branch,
       SUM(fees) AS total_fees
FROM   students
GROUP BY branch
HAVING SUM(fees) > 200000;


-- ============================================================================
--  SECTION 7 -- ORDER BY WITH GROUP BY
-- ============================================================================
-- GROUP BY forms the groups; ORDER BY then ranks the resulting summary
-- rows. GROUP BY always runs before ORDER BY (see Section 3).

-- ----------------------------------------------------------------------------
-- 7.1  Rank branches by average CGPA, best branch first.
-- ----------------------------------------------------------------------------
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch
ORDER BY avg_cgpa DESC;

-- ----------------------------------------------------------------------------
-- 7.2  Rank cities by student count, most students first.
-- ----------------------------------------------------------------------------
SELECT city,
       COUNT(*) AS student_count
FROM   students
GROUP BY city
ORDER BY student_count DESC;

-- ----------------------------------------------------------------------------
-- 7.3  Rank branches by total fees collected, highest first.
-- ----------------------------------------------------------------------------
SELECT branch,
       SUM(fees) AS total_fees
FROM   students
GROUP BY branch
ORDER BY total_fees DESC;

-- ============================================================================
--  REMEMBER:
--  WHERE filters rows  → GROUP BY creates groups → HAVING filters groups
-- ============================================================================

-- ============================================================================
--  SECTION 8 -- COMMON INTERVIEW MISTAKES
-- ============================================================================
-- Each mistake below shows the INCORRECT query first, commented out (some
-- of these genuinely fail with an error in MySQL 8), followed by the
-- CORRECTED version that actually runs.

-- ----------------------------------------------------------------------------
-- 8.1  Mistake: Using WHERE with an aggregate function.
--      WHERE (execution step 2) runs before GROUP BY / HAVING (steps 3-4),
--      so no aggregate value exists yet for WHERE to test.
-- ----------------------------------------------------------------------------
-- INCORRECT -- raises "Invalid use of group function"
-- SELECT branch, AVG(cgpa)
-- FROM   students
-- WHERE  AVG(cgpa) > 8
-- GROUP BY branch;

-- CORRECT -- use HAVING to filter on an aggregate, after grouping.
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch
HAVING AVG(cgpa) > 8;

-- ----------------------------------------------------------------------------
-- 8.2  Mistake: Missing GROUP BY column.
--      Selecting branch as a plain column while grouping by something else
--      (or not at all) leaves MySQL unable to produce one row per branch.
-- ----------------------------------------------------------------------------
-- INCORRECT -- branch is selected but the query groups by city instead
-- SELECT branch, AVG(cgpa)
-- FROM   students
-- GROUP BY city;

-- CORRECT -- GROUP BY must include every non-aggregated column you SELECT.
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch;

-- ----------------------------------------------------------------------------
-- 8.3  Mistake: Thinking GROUP BY sorts the data.
--      GROUP BY only creates groups -- it does NOT guarantee any particular
--      row order in the result. A specific order always needs ORDER BY.
-- ----------------------------------------------------------------------------
-- MISCONCEPTION -- this does NOT guarantee branches come back alphabetically
-- or in any ranked order, even though the output can look sorted by chance.
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch;

-- CORRECT -- add ORDER BY explicitly whenever a specific order is required.
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch
ORDER BY branch;

-- ----------------------------------------------------------------------------
-- 8.4  Mistake: Selecting non-grouped columns.
--      Every non-aggregated column in SELECT must also appear in GROUP BY,
--      otherwise MySQL cannot decide which single value to display per
--      group -- e.g. which student's name to show for a whole branch.
-- ----------------------------------------------------------------------------
-- INCORRECT -- name is neither aggregated nor in GROUP BY; with
-- ONLY_FULL_GROUP_BY enabled (the MySQL 8 default) this raises an error.
-- SELECT name, branch, AVG(cgpa)
-- FROM   students
-- GROUP BY branch;

-- CORRECT -- either remove the non-grouped column, or aggregate it too.
SELECT branch,
       AVG(cgpa) AS avg_cgpa
FROM   students
GROUP BY branch;


-- ============================================================================
--  SECTION 9 -- INTERVIEW PRACTICE  (Questions Only -- No Solutions Below)
-- ============================================================================
-- Write the SQL query for each question yourself. Do not scroll to any
-- "answer" -- there isn't one in this file. Use Sections 4-7 above as a
-- reference for the syntax you'll need.

-- ---------------------------
-- FOUNDATION
-- ---------------------------
-- 1.  Find the average CGPA, branch-wise.
-- 2.  Count students, city-wise.
-- 3.  Find the total fees, branch-wise.
-- 4.  Find the highest attendance, city-wise.
-- 5.  Find the lowest CGPA, branch-wise.

-- ---------------------------
-- MEDIUM
-- ---------------------------
-- 6.  Find the average attendance of Delhi students, branch-wise.
-- 7.  Find the cities that have at least 2 students.
-- 8.  Find the branches whose average CGPA exceeds 8.
-- 9.  Count students with a non-NULL email, branch-wise.
-- 10. Find the total fees of IT students, branch-wise.

-- ---------------------------
-- PLACEMENT LEVEL
-- ---------------------------
-- 11. Rank branches by average CGPA.
-- 12. Find the top-performing branch.
-- 13. Find the city contributing the highest total fees.
-- 14. Find the branch with the maximum attendance.
-- 15. Count students branch-wise and sort the result in descending order.
-- 16. Find the average fees, city-wise.
-- 17. Find the highest CGPA, city-wise.
-- 18. Find the lowest attendance, branch-wise.
-- 19. Find the branches having more than 2 students.
-- 20. Explain why WHERE cannot use AVG() directly, and write the corrected
--     query using HAVING to prove your answer.

-- ============================================================================
--  END OF SQL DAY 4 SCRIPT
-- ============================================================================
