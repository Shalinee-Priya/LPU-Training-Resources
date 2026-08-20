-- ============================================================
-- SQL DAY 12 : SQL INDEXES
-- FILE        : 02_SQL_Day12_Script.sql
-- DATABASE    : MySQL 8.0+   |   CLIENT : MySQL Workbench
-- PREREQUISITE: 03_SQL_Day12_Dataset.sql must sit in the SAME FOLDER
--               as this file (this script loads it automatically).
--
-- CURRICULUM POSITION
--   Day 10 -> String, Numeric & Date/Time Functions
--   Day 11 -> SQL Views
--   Day 12 -> SQL Indexes  (THIS FILE)
--
-- WHAT THIS FILE TEACHES
--   How MySQL actually FINDS rows, and how to make it fast on purpose:
--   Primary/Secondary/Unique/Composite indexes, the Leftmost Prefix Rule,
--   SHOW INDEX, DROP INDEX, EXPLAIN, Selectivity, Covering Indexes, and
--   when indexing helps vs. hurts.
--
-- RERUNNABLE: Yes. Running this file from top to bottom always leaves
--             the database in the same, predictable state.
-- ============================================================


-- ============================================================
-- SECTION 0 : SETUP
-- ============================================================
-- Rebuilding the database fresh each run means every CREATE INDEX /
-- DROP INDEX statement below behaves identically no matter how many
-- times you execute this script.

DROP DATABASE IF EXISTS hr_analytics_day12;

-- Loads the employees table + 100,000 rows.
-- If SOURCE fails because Workbench's working directory does not
-- match this folder, simply run 03_SQL_Day12_Dataset.sql manually
-- once, then continue running this script from SECTION 1 onward.
SOURCE 03_SQL_Day12_Dataset.sql;

USE hr_analytics_day12;

SELECT COUNT(*) AS total_employees FROM employees;   -- expect 100000


-- ============================================================
-- SECTION 1 : WHAT IS AN INDEX?
-- ============================================================
-- Simple definition:
--   "An index is a data structure that helps MySQL locate rows
--    faster, without having to check every row in the table."
--
-- THE BOOK ANALOGY (no B-Tree talk yet)
--   A 600-page textbook with NO index:
--     To find every mention of "Normalization" you must flip
--     through all 600 pages, one at a time.
--   The SAME textbook WITH an index at the back:
--     You look up "Normalization" in the index, see "pg. 214, 391",
--     and turn straight to those two pages.
--
--   The index does not contain the content itself -- it contains a
--   SORTED list of key terms, each pointing to WHERE the real content
--   lives. A database index works the same way: it does not replace
--   the table, it points into it.
--
-- Right now, our employees table has 100,000 rows and only ONE
-- index -- the PRIMARY KEY on emp_id. Every other column is
-- "un-indexed" -- exactly like a book with no index at the back.

SELECT emp_id, first_name, last_name, email, department, city, salary
FROM employees
LIMIT 5;


-- ============================================================
-- SECTION 2 : WITHOUT INDEX vs WITH INDEX
-- ============================================================
-- Business problem:
--   The HR system needs to look up ONE employee by email.
--   employees currently has 100,000 rows and NO index on email.
--
-- BEFORE: MySQL must scan the table looking for a match.
-- (EXPLAIN shows HOW MySQL plans to run a query, without running it.)

EXPLAIN SELECT * FROM employees
WHERE email = 'aman.bansal44590@hranalytics.com';
-- Observed on this dataset:
--   type = ALL             -> full table scan
--   key  = NULL            -> no index used
--   rows ~ 97,000-100,000  -> MySQL expects to examine almost every row
--   (the exact "rows" estimate can vary slightly run to run -- InnoDB
--   builds it from a random SAMPLE of pages, not an exact count)

-- Let's add an index and ask the exact same question again.
CREATE INDEX idx_email_demo ON employees(email);

EXPLAIN SELECT * FROM employees
WHERE email = 'aman.bansal44590@hranalytics.com';
-- Observed after indexing:
--   type = ref              -> index lookup, not a scan
--   key  = idx_email_demo   -> the new index is actually used
--   rows = 1                -> MySQL expects to touch exactly ONE row
--
-- This is the entire value proposition of an index in one comparison:
-- ~97,195 rows examined  --->  1 row examined.

-- This was only a demonstration index -- drop it. The "real" email
-- index is created properly (as a UNIQUE index) in Section 5.
DROP INDEX idx_email_demo ON employees;


-- ============================================================
-- SECTION 3 : PRIMARY KEY INDEX
-- ============================================================
-- In InnoDB (MySQL's default storage engine), the PRIMARY KEY is not
-- just a constraint -- it automatically becomes the table's main,
-- clustered-style index. The table's rows are physically organized
-- around it, so looking up a row by its primary key is about as fast
-- as a lookup can get.
--
-- Properties of a Primary Key Index:
--   - Uniqueness is enforced automatically (no duplicate emp_id)
--   - NULL is not allowed
--   - Every table should have exactly ONE primary key
--   - Lookups by primary key are extremely fast

SHOW CREATE TABLE employees;

EXPLAIN SELECT * FROM employees WHERE emp_id = 50000;
-- Observed: type = const, key = PRIMARY, rows = 1
-- "const" is even faster than "ref" -- MySQL knows there can be at
-- most one matching row before it even runs the query.

-- The following statement is intentionally commented out: it would
-- FAIL because emp_id = 1 already exists, and the Primary Key Index
-- guarantees uniqueness. Uncomment to see the duplicate-key error.
-- INSERT INTO employees (emp_id, first_name, last_name, email, department, city, salary, hire_date, phone, bonus_pct)
-- VALUES (1, 'Dup', 'Test', 'dup.test@hranalytics.com', 'IT', 'Pune', 50000, '2022-01-01', '9000000000', 5);


-- ============================================================
-- SECTION 4 : SECONDARY INDEX
-- ============================================================
-- A secondary index is any index OTHER than the primary key. It is a
-- separate structure that points back to the primary key, so MySQL
-- can find matching rows without scanning the whole table.
--
-- Naming convention used throughout this module:
--   idx_<column>            for a single-column index
--   idx_<col1>_<col2>       for a composite index
-- Consistent, predictable names make a schema easy to maintain --
-- "idx_department" tells you exactly what it indexes, at a glance.

CREATE INDEX idx_department ON employees(department);
CREATE INDEX idx_city       ON employees(city);
CREATE INDEX idx_email      ON employees(email);   -- plain (non-unique) for now

SHOW INDEX FROM employees;

EXPLAIN SELECT * FROM employees WHERE department = 'IT';
-- type = ref, key = idx_department -- fast lookup, no full scan

EXPLAIN SELECT * FROM employees WHERE city = 'Pune';
-- type = ref, key = idx_city

-- PRIMARY vs SECONDARY INDEX
--   Primary Index   : one per table, defines physical row storage,
--                      always unique, always NOT NULL.
--   Secondary Index : many per table, does NOT change physical
--                      storage, may or may not be unique, points
--                      back to the primary key to fetch full rows.


-- ============================================================
-- SECTION 5 : UNIQUE INDEX
-- ============================================================
-- idx_email above is a REGULAR index -- it speeds up lookups, but it
-- does NOT stop duplicate emails from being inserted. Watch:

INSERT INTO employees (first_name, last_name, email, department, city, salary, hire_date, phone, bonus_pct)
VALUES ('Test', 'Duplicate', 'aman.bansal44590@hranalytics.com', 'IT', 'Pune', 50000, '2022-01-01', '9999999999', 5);

SELECT COUNT(*) AS rows_with_this_email
FROM employees
WHERE email = 'aman.bansal44590@hranalytics.com';
-- Returns 2. A regular index enforces NOTHING -- it only speeds up search.

-- Clean up the duplicate we just proved a point with.
DELETE FROM employees WHERE first_name = 'Test' AND last_name = 'Duplicate';

-- Business rule: email must be unique per employee.
-- Swap the plain index for a UNIQUE index.
DROP INDEX idx_email ON employees;
CREATE UNIQUE INDEX idx_email ON employees(email);

-- Now the exact same INSERT that succeeded a moment ago will FAIL.
-- Uncomment to see: ERROR 1062 - Duplicate entry ... for key 'idx_email'
-- INSERT INTO employees (first_name, last_name, email, department, city, salary, hire_date, phone, bonus_pct)
-- VALUES ('Test', 'Duplicate', 'aman.bansal44590@hranalytics.com', 'IT', 'Pune', 50000, '2022-01-01', '9999999999', 5);

-- UNIQUE INDEX vs PRIMARY KEY (preview -- full comparison in Section 17):
--   Both enforce uniqueness. A table can have only ONE primary key,
--   but MANY unique indexes. A unique index still allows one NULL
--   (per NULL-able column); a primary key allows none at all.


-- ============================================================
-- SECTION 6 : COMPOSITE INDEX
-- ============================================================
-- A composite (multi-column) index speeds up queries that filter on
-- MORE THAN ONE column together.

CREATE INDEX idx_dept_salary ON employees(department, salary);

EXPLAIN SELECT * FROM employees WHERE department = 'IT' AND salary > 130000;
-- type = range, key = idx_dept_salary, rows ~ 96
-- One index serves BOTH conditions at once.

-- WHY COLUMN ORDER MATTERS
-- Let's build the SAME two columns in the OPPOSITE order and compare.
CREATE INDEX idx_salary_dept ON employees(salary, department);

-- A query that filters ONLY on salary (department not mentioned):
EXPLAIN SELECT * FROM employees WHERE salary > 130000;
-- With idx_salary_dept (salary, department): salary IS the leading
-- column, so this index IS usable.
--   type = range, key = idx_salary_dept, rows ~ 384
--
-- Compare that to what happens on a salary-only filter when the ONLY
-- composite index available is idx_dept_salary (department, salary),
-- i.e. before idx_salary_dept existed:
--   type = ALL, key = NULL   -- department is the leading column, and
--   it is missing from the WHERE clause, so idx_dept_salary is
--   skipped entirely and MySQL falls back to a full table scan.
--
-- (department, salary)  -> great for "department first" questions
-- (salary, department)  -> great for "salary first" questions
-- Same two columns, same storage cost, completely different usefulness.
-- This is exactly WHY column order in a composite index is a design
-- decision, not a formality -- and it leads directly into Section 7.

-- idx_salary_dept was only built to prove the ordering point above.
DROP INDEX idx_salary_dept ON employees;


-- ============================================================
-- SECTION 7 : LEFTMOST PREFIX RULE
-- ============================================================
-- A composite index can only be used efficiently when the query's
-- WHERE clause includes a matching PREFIX of its columns, starting
-- from the LEFTMOST one. Skip the leftmost column, and the index is
-- effectively invisible to that query.

CREATE INDEX idx_dept_city_salary ON employees(department, city, salary);

-- Index built as: (department, city, salary)
--
-- | Query filters on                    | Uses idx_dept_city_salary? |
-- |--------------------------------------|-----------------------------|
-- | department                           | YES (leftmost column)       |
-- | department + city                    | YES (leftmost 2 columns)    |
-- | department + city + salary           | YES (full index)            |
-- | city only                            | NO  (skips leftmost column) |
-- | salary only                          | NO  (skips leftmost column) |
-- | city + salary (no department)        | NO  (skips leftmost column) |

-- Proof, straight from EXPLAIN's possible_keys column:

EXPLAIN SELECT * FROM employees WHERE department = 'IT';
-- possible_keys includes idx_dept_city_salary -- usable

EXPLAIN SELECT * FROM employees WHERE department = 'IT' AND city = 'Pune';
-- possible_keys includes idx_dept_city_salary -- usable

EXPLAIN SELECT * FROM employees WHERE department = 'IT' AND city = 'Pune' AND salary > 100000;
-- possible_keys includes idx_dept_city_salary -- fully usable

EXPLAIN SELECT * FROM employees WHERE city = 'Pune';
-- possible_keys does NOT include idx_dept_city_salary
-- (only idx_city, a separate single-column index, is offered)

EXPLAIN SELECT * FROM employees WHERE salary > 130000;
-- possible_keys does NOT include idx_dept_city_salary at all
-- (type = ALL -- full scan, because no usable index exists for this
-- filter yet)

EXPLAIN SELECT * FROM employees WHERE city = 'Pune' AND salary > 100000;
-- possible_keys still does NOT include idx_dept_city_salary
-- (department -- the leftmost column -- is missing)

-- Rule of thumb when designing a composite index: put the column you
-- filter on MOST OFTEN, or the one that is the most selective and
-- most likely to appear ALONE in a WHERE clause, on the LEFT.


-- ============================================================
-- SECTION 8 : SHOW INDEX
-- ============================================================

SHOW INDEX FROM employees;

-- Columns worth understanding (ignore the rest for now):
--   Key_name      -> the index's name (what you'd use in DROP INDEX)
--   Column_name   -> which column this row of output describes
--   Seq_in_index  -> the column's POSITION inside a composite index
--                     (1 = leftmost column, 2 = second column, ...)
--   Non_unique    -> 0 = unique index (or PRIMARY), 1 = duplicates allowed
--   Cardinality   -> MySQL's ESTIMATE of the number of distinct values
--                     in that column. Central to Section 11 (Selectivity).


-- ============================================================
-- SECTION 9 : DROP INDEX
-- ============================================================
-- Syntax:  DROP INDEX index_name ON table_name;

DROP INDEX idx_city ON employees;

-- Confirm it is gone:
SELECT COUNT(*) AS idx_city_still_exists
FROM information_schema.statistics
WHERE table_schema = 'hr_analytics_day12'
  AND table_name = 'employees'
  AND index_name = 'idx_city';
-- Expect 0

-- Why this matters for rerunnable scripts: MySQL has NO
-- "DROP INDEX IF EXISTS" or "CREATE INDEX IF NOT EXISTS" syntax.
-- That is exactly why this script rebuilds the database from scratch
-- in SECTION 0 -- it is the simplest way to guarantee every CREATE
-- INDEX below always runs against a clean, predictable slate.
-- (idx_city is re-created in Section 12, where the business case
-- genuinely calls for it again.)


-- ============================================================
-- SECTION 10 : EXPLAIN (FOUNDATION)
-- ============================================================
-- EXPLAIN shows MySQL's QUERY PLAN -- what it intends to do -- without
-- actually running the query. The columns that matter most for a
-- beginner/intermediate reading of a plan:
--
--   type           how MySQL accesses the table for this query.
--                  From best to worst (roughly):
--                  system/const > eq_ref > ref > range > index > ALL
--                  ("ALL" means full table scan -- the one to worry about)
--   possible_keys  every index MySQL COULD have used
--   key            the index MySQL actually chose to use (or NULL)
--   rows           MySQL's ESTIMATE of how many rows it must examine
--   Extra          extra execution detail, e.g. "Using filesort"
--                  (an expensive extra sort step) or "Using index"
--                  (a covering index -- see Section 16)
--
-- BEFORE vs AFTER: sorting is expensive too, not just filtering.

EXPLAIN SELECT emp_id, first_name, last_name, hire_date
FROM employees
WHERE department = 'IT'
ORDER BY hire_date DESC
LIMIT 20;
-- BEFORE a supporting index exists:
--   key = idx_dept_city_salary (used for the WHERE, not the ORDER BY)
--   Extra = Using filesort   <-- MySQL sorts 45,000+ rows in memory/disk

CREATE INDEX idx_dept_hire ON employees(department, hire_date);

EXPLAIN SELECT emp_id, first_name, last_name, hire_date
FROM employees
WHERE department = 'IT'
ORDER BY hire_date DESC
LIMIT 20;
-- AFTER: key = idx_dept_hire
--   Extra = Backward index scan   <-- rows come out of the index
--   ALREADY SORTED. No filesort needed at all.
--
-- Lesson: indexes don't just help WHERE -- a well-designed composite
-- index can eliminate an expensive sort too.


-- ============================================================
-- SECTION 11 : INDEX SELECTIVITY
-- ============================================================
-- Selectivity = (number of DISTINCT values) / (total number of rows)
-- Closer to 1.0 = highly selective = excellent index candidate.
-- Closer to 0.0 = low selectivity = poor index candidate on its own.

SELECT
    (SELECT COUNT(*) FROM employees)                    AS total_rows,
    (SELECT COUNT(DISTINCT email)      FROM employees)   AS distinct_email,
    (SELECT COUNT(DISTINCT department) FROM employees)   AS distinct_department,
    (SELECT COUNT(DISTINCT city)       FROM employees)   AS distinct_city,
    (SELECT COUNT(DISTINCT salary)     FROM employees)   AS distinct_salary;

-- On this 100,000-row dataset:
--   email       -> 100,000 distinct  -> selectivity = 1.00000  (excellent)
--   salary      ->   1,045 distinct  -> selectivity = 0.01045  (decent)
--   city        ->      15 distinct  -> selectivity = 0.00015  (poor alone)
--   department  ->      10 distinct  -> selectivity = 0.00010  (poor alone)
--
-- "Good candidate"    : email, emp_id (near-unique columns)
-- "Poor candidate"    : department, city, or any low-cardinality flag
--                       column, used BY ITSELF
-- "Depends"           : department can still be a GOOD leading column
--                       in a COMPOSITE index (Sections 6-7), even
--                       though it is a poor STANDALONE index -- context
--                       (how it's combined with other columns) matters.
--
-- A low-selectivity index doesn't help much because MySQL still has
-- to fetch a large fraction of the table's rows to satisfy the query
-- (this connects directly to Section 15 -- When Indexes Hurt).


-- ============================================================
-- SECTION 12 : BUSINESS OPTIMIZATION (CASE STUDY)
-- ============================================================
-- Same HR Analytics dataset used across Day 10 - Day 12. Each
-- business question below gets the index it actually needs.

-- (1) Find employee by email  -> already solved: idx_email (UNIQUE)
EXPLAIN SELECT * FROM employees WHERE email = 'aman.bansal44590@hranalytics.com';

-- (2) All employees in IT -> already solved: MySQL will pick whichever
--     department-leading index it estimates is cheapest (idx_department
--     or one of the composite indexes built on top of it) -- either way,
--     it is an index lookup, not a full scan.
EXPLAIN SELECT * FROM employees WHERE department = 'IT';

-- (3) Department + Salary together -> already solved: idx_dept_salary
EXPLAIN SELECT * FROM employees WHERE department = 'IT' AND salary > 130000;

-- (4) Sort the ENTIRE workforce by hire date (no department filter).
--     idx_dept_hire does NOT help here -- department is its leftmost
--     column and this query does not filter on department at all.
EXPLAIN SELECT emp_id, first_name, hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 20;
-- BEFORE idx_hire_date: type = ALL, Extra = Using filesort

CREATE INDEX idx_hire_date ON employees(hire_date);

EXPLAIN SELECT emp_id, first_name, hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 20;
-- AFTER: type = index, key = idx_hire_date, Extra = Backward index scan

-- (5) Find employees in a given city.
--     idx_city was DROPPED in Section 9 for demonstration purposes --
--     the business genuinely needs it, so it is legitimately re-created here.
CREATE INDEX idx_city ON employees(city);
EXPLAIN SELECT * FROM employees WHERE city = 'Pune';

-- (6) Recent hires (last N hired, across the company)
--     -> reuses idx_hire_date from (4) above.
SELECT emp_id, first_name, last_name, department, hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 10;

-- (7) High salary employees (across ALL departments, not just one)
--     idx_dept_salary does NOT help here -- department is its leftmost
--     column and this query never filters on department.
CREATE INDEX idx_salary ON employees(salary);
EXPLAIN SELECT emp_id, first_name, last_name, department, salary
FROM employees
WHERE salary > 130000;
-- key = idx_salary, type = range, rows ~ 384


-- ============================================================
-- SECTION 13 : GUIDED PRACTICE (10 Questions)
-- ============================================================
-- Work through these WITH your instructor. Write the SQL yourself --
-- no solutions are provided in this file.
--
-- 1. Run EXPLAIN on a query that filters employees by `bonus_pct`.
--    What is the `type` and `key`? Why?
-- 2. Create a single-column index on `first_name` following the
--    naming convention used in this script.
-- 3. Using SHOW INDEX, identify which indexes on employees are
--    unique and which are not.
-- 4. Write a query that filters on department AND city. Which index
--    from this script does EXPLAIN say it uses?
-- 5. Create a composite index on (city, department). Explain, using
--    the Leftmost Prefix Rule, one query that WOULD use it and one
--    query that would NOT.
-- 6. Compute the selectivity of the `phone` column. Is it a good
--    index candidate? Justify using the ratio, not just intuition.
-- 7. Drop the index you created in Question 2 using proper DROP
--    INDEX syntax.
-- 8. Run EXPLAIN on: SELECT * FROM employees WHERE salary BETWEEN
--    50000 AND 80000; What type of index access does MySQL choose?
-- 9. Write a query that sorts employees by salary DESC and uses an
--    existing index to avoid "Using filesort". Prove it with EXPLAIN.
-- 10. Explain, in your own words, why `idx_dept_city_salary` from
--     Section 7 does NOT help a query that filters only on `salary`.


-- ============================================================
-- SECTION 14 : INDEPENDENT PRACTICE (10 Questions)
-- ============================================================
-- Complete these on your own. No solutions are provided in this file.
--
-- 1. Create a UNIQUE index on `phone`. Is this a realistic business
--    rule? Justify your answer with a real-world scenario.
-- 2. Write and EXPLAIN a query that benefits from idx_dept_hire.
-- 3. Write and EXPLAIN a query that CANNOT use idx_dept_hire despite
--    filtering on `hire_date`.
-- 4. Using information_schema.statistics, list every index that
--    currently exists on the employees table, ordered by Key_name.
-- 5. Create a composite index that would help this exact query:
--    SELECT * FROM employees WHERE department = 'Sales' AND
--    hire_date > '2023-01-01' ORDER BY salary DESC;
-- 6. Identify one column in employees that would make a POOR
--    standalone index. Justify using the selectivity formula.
-- 7. Rewrite a SELECT * query as a covering-index query (select only
--    indexed columns) and confirm "Using index" appears in EXPLAIN.
-- 8. Drop every index you personally created in this practice
--    section, using correct DROP INDEX syntax for each.
-- 9. Explain the difference between `Cardinality` (from SHOW INDEX)
--    and true selectivity. Are they exactly the same number?
-- 10. Design (on paper, then in SQL) the index you would create to
--     speed up: "list all employees hired in the last 90 days,
--     sorted by salary, within a single department."


-- ============================================================
-- SECTION 15 : BUSINESS PROBLEMS (10 Questions)
-- ============================================================
-- Scenario-based. For each, decide WHICH index (if any) solves it,
-- and justify why using selectivity + Leftmost Prefix reasoning.
-- No solutions are provided in this file.
--
-- 1. The HR portal's "search by email" feature has become slow as
--    the company grew past 50,000 employees. Diagnose and fix it.
-- 2. Payroll needs: "all employees in Finance earning above a given
--    threshold, sorted by salary." Design the index.
-- 3. A manager complains that filtering by city is slow even though
--    an index exists on city. Investigate using EXPLAIN -- what
--    could still be wrong?
-- 4. The recruitment team frequently runs: "show the 50 most
--    recently hired employees, company-wide." Design for this.
-- 5. Finance wants a report of the highest-paid employee in EACH
--    department. Which existing index(es) help, and why?
-- 6. A junior developer indexes `bonus_pct` expecting a big
--    performance win. Evaluate whether this is a good idea.
-- 7. The application inserts ~500 new employees every night in a
--    batch job, and it has slowed down since 6 indexes were added
--    to employees. Explain WHY, in business terms.
-- 8. A dashboard runs: "count employees per department" every time
--    it loads. Which index helps, and why does EXPLAIN show
--    "Using index" rather than "Using where"?
-- 9. Two indexes exist: (department, salary) and (salary,
--    department). A colleague says "one of these is redundant."
--    Are they right? Justify with example queries.
-- 10. The company is about to double its headcount to 200,000
--     employees. Which of this module's indexes remain useful, and
--     which might need to be revisited?


-- ============================================================
-- SECTION 16 : INTERVIEW CHALLENGE (15 Questions)
-- ============================================================
-- Conceptual and rapid-fire. No solutions are provided in this file.
--
-- 1. What is an index, in one sentence, without using the word "fast"?
-- 2. What's the difference between a Primary Index and a Secondary Index?
-- 3. Is "Primary Key" the same thing as "Index"? Explain precisely.
-- 4. What does the Leftmost Prefix Rule say, and why does it exist?
-- 5. Give an example composite index and one query that CANNOT use it.
-- 6. What is index selectivity, and how is it calculated?
-- 7. Name one column type that usually makes a poor index and explain why.
-- 8. What does EXPLAIN's `type = ALL` mean, and why is it a red flag?
-- 9. What is the difference between `possible_keys` and `key` in EXPLAIN?
-- 10. What is a covering index? What must be true about the SELECT
--     list for one to apply?
-- 11. Do indexes speed up INSERT statements? Explain your answer.
-- 12. Why can't a table have more than one PRIMARY KEY, but it can
--     have many UNIQUE indexes?
-- 13. A table has 10 indexes. Is that automatically a design problem?
--     Under what conditions would it be?
-- 14. Does every WHERE clause automatically use an available index?
--     Give a counter-example.
-- 15. If you were told "just index every column to be safe," how
--     would you respond, and why?


-- ============================================================
-- SECTION 17 : COMMON MISTAKES
-- ============================================================
-- 1. Indexing every column "just in case."
--    Every extra index adds storage and slows down INSERT/UPDATE/
--    DELETE. Index deliberately, based on real query patterns.
--
-- 2. Ignoring column order in a composite index.
--    (department, salary) and (salary, department) are NOT
--    interchangeable -- see Section 6.
--
-- 3. Creating too many overlapping indexes.
--    idx_department, idx_dept_salary, and idx_dept_city_salary all
--    overlap on `department`. Overlap is sometimes fine, but should
--    be a deliberate decision, not an accident.
--
-- 4. Indexing low-cardinality columns alone.
--    A standalone index on a column with only 2-10 distinct values
--    (e.g., department, a status flag) rarely earns back its
--    maintenance cost -- see Section 11 (Selectivity).
--
-- 5. Confusing UNIQUE INDEX with PRIMARY KEY.
--    Both enforce uniqueness; only PRIMARY KEY defines the table's
--    physical row organization and disallows NULL outright -- see
--    Section 17 [comparison table] in the slide deck.
--
-- 6. Ignoring EXPLAIN entirely.
--    "It has an index" does not mean "the query uses it." Always
--    verify with EXPLAIN, especially after adding a WHERE condition,
--    ORDER BY, or JOIN.
--
-- 7. Assuming indexes always improve speed.
--    They speed up reads (WHERE / JOIN / ORDER BY / GROUP BY) at the
--    cost of slower writes (INSERT / UPDATE / DELETE) and extra
--    storage. It is a trade-off, not a free upgrade -- see Section 15.


-- ============================================================
-- SECTION 18 : FINAL RECAP
-- ============================================================
-- Today you learned to think about a query the way MySQL does:
--   - An index is a sorted structure that helps MySQL locate rows
--     without scanning the whole table (Section 1-2).
--   - PRIMARY KEY = automatic, unique, defines row storage (Section 3).
--   - SECONDARY indexes are created deliberately with CREATE INDEX
--     (Section 4); UNIQUE indexes additionally enforce no duplicates
--     (Section 5).
--   - COMPOSITE indexes serve multi-column filters, but column ORDER
--     is a design decision governed by the Leftmost Prefix Rule
--     (Sections 6-7).
--   - SHOW INDEX / DROP INDEX are the everyday tools for inspecting
--     and maintaining indexes (Sections 8-9).
--   - EXPLAIN is how you PROVE an index is actually being used,
--     rather than assuming it (Section 10).
--   - SELECTIVITY tells you, mathematically, whether a column is
--     worth indexing on its own (Section 11).
--   - Every index is a trade-off: faster reads, slower writes, extra
--     storage (Sections 14-15).
--   - A COVERING INDEX can satisfy an entire query from the index
--     alone, without touching the table (Section 10, "Using index").
--
-- NEXT MODULE PREVIEW
--   Indexing makes READS fast. The next layer of professional MySQL
--   usage is making sure WRITES stay correct when multiple users hit
--   the database at once -- transactions, COMMIT/ROLLBACK, and data
--   integrity under concurrent access.

SELECT 'Day 12 - SQL Indexes - Script Complete' AS status;
