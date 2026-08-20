-- =============================================================================
-- =============================================================================
--     SQL DAY 10 : STRING + NUMERIC + DATE/TIME FUNCTIONS
-- =============================================================================
-- =============================================================================
-- Author  : Shalinee Priya | Data Analyst | SQL Trainer
-- Track   : B.Tech CSE SQL Training Series
-- Engine  : MySQL 8.0+ / MySQL Workbench
--
-- WHERE DAY 10 SITS IN THE JOURNEY
-- Day 1  -> SQL Introduction
-- Day 2  -> Data Retrieval & Filtering
-- Day 3  -> Aggregate Functions
-- Day 4  -> GROUP BY & HAVING
-- Day 5  -> Keys & Constraints
-- Day 6  -> ER Model & Database Design
-- Day 7  -> Normalization
-- Day 8  -> JOINs
-- Day 9  -> Subqueries
-- Day 10 -> STRING + NUMERIC + DATE/TIME FUNCTIONS   <-- you are here
-- Day 11 -> Views (next)
--
-- Days 1-9 taught you how to COMBINE and FILTER rows across tables. Day 10
-- teaches something different: how to TRANSFORM, CLEAN, FORMAT, CALCULATE
-- and ANALYZE the individual VALUES sitting inside a single row/column —
-- a messy name, a raw salary, a stored date. Day 11 (Views) will then save
-- queries like these as reusable, named objects.
--
-- EXECUTION GUIDE
-- Step 1 -> Run 03_SQL_Day10_Dataset.sql (creates hr_analytics, loads
--           departments + employees).
-- Step 2 -> Run this file (02_SQL_Day10_Script.sql) against that database.
-- This script only READS the dataset (SELECT/USE/DESC) — it never creates,
-- alters, updates, or inserts into hr_analytics tables, so it is safe to
-- run as many times in a row as you like.
-- =============================================================================


-- =============================================================================
-- SECTION 0 : SETUP / DATASET VERIFICATION
-- =============================================================================
USE hr_analytics;

DESC departments;
DESC employees;

SELECT * FROM departments;
SELECT * FROM employees;


-- =============================================================================
-- SECTION 1 : WHAT ARE SQL FUNCTIONS?
-- =============================================================================
/*
WHAT:
A SQL function is a built-in operation the database engine performs on data
you give it, returning a computed result. You have already met one whole
category of functions — Aggregate Functions (SUM, AVG, COUNT, MIN, MAX) —
in Day 3. Day 10 introduces the other three built-in categories that MySQL
groups under "Single-Row (Scalar) Functions":

    1. String Functions     -> operate on text (VARCHAR/CHAR)
    2. Numeric Functions     -> operate on numbers (INT/DECIMAL/FLOAT)
    3. Date & Time Functions -> operate on DATE/DATETIME/TIME values

WHY FUNCTIONS MATTER:
Raw stored data is rarely report-ready. A name may have stray spaces, a
salary may need rounding for a financial report, a DATE column may need to
become "15 March 2019" for a dashboard. Functions do this transformation
inside the query itself, so the destination (report, API, dashboard) always
receives clean, ready-to-use values instead of raw table data.
*/


-- =============================================================================
-- SECTION 2 : SCALAR FUNCTIONS vs AGGREGATE FUNCTIONS
-- =============================================================================
/*
                        SQL FUNCTIONS
                              |
                -----------------------------
                |                           |
             SCALAR                    AGGREGATE
                |                           |
        one input value per row      many rows in
        -> one result per row        -> one result
                |                           |
        String / Numeric /          SUM, AVG, COUNT,
        Date-Time functions           MIN, MAX

SCALAR   : Evaluated independently for EVERY row. If the table has 14 rows,
           UPPER(first_name) runs 14 times and returns 14 results.
AGGREGATE: Evaluated across a GROUP of rows (or the whole table). COUNT(*)
           collapses all 14 rows into a single number.

This is exactly why the two combine so well: GROUP BY first collapses rows
into groups (aggregate territory), and a scalar function can still run on
each group's representative row or on the raw values before grouping. You
will see both working together throughout this module.
*/

-- SCALAR — one result PER ROW (14 rows in, 14 results out)
SELECT first_name, UPPER(first_name) AS upper_name
FROM employees;

-- AGGREGATE — MANY rows IN, ONE result out (Day 3 recap, not re-taught)
SELECT COUNT(*) AS total_employees
FROM employees;

-- Side by side, same query: a scalar column next to an aggregate window
-- (aggregate functions only make sense per-group or per-table, not per-row,
-- which is precisely the distinction being illustrated here)
SELECT department,
       COUNT(*)        AS employees_in_dept,   -- aggregate: one row per group
       ROUND(AVG(salary),2) AS avg_salary_in_dept
FROM employees
GROUP BY department;


-- =============================================================================
-- SECTION 3 : STRING FUNCTIONS — CORE COVERAGE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3A. UPPER() / LOWER() — Case Conversion
-- -----------------------------------------------------------------------------
-- WHAT: Converts text to all-uppercase or all-lowercase.
-- SYNTAX: UPPER(string) | LOWER(string)

-- SIMPLE EXAMPLE
SELECT UPPER('sql training') AS upper_demo,
       LOWER('SQL TRAINING') AS lower_demo;

-- COLUMN-BASED EXAMPLE
SELECT first_name, UPPER(first_name) AS name_upper, LOWER(department) AS dept_lower
FROM employees;

-- BUSINESS EXAMPLE: HR wants every employee's email normalized to lowercase
-- (emails are case-insensitive in practice, but display consistency matters)
SELECT email, LOWER(email) AS normalized_email
FROM employees;

-- PRACTICE: Display every department name in uppercase, without duplicates.


-- -----------------------------------------------------------------------------
-- 3B. CONCAT() / CONCAT_WS() — Concatenation
-- -----------------------------------------------------------------------------
-- WHAT: Joins two or more strings into one.
-- SYNTAX: CONCAT(str1, str2, ...) | CONCAT_WS(separator, str1, str2, ...)
--
-- CONCAT vs CONCAT_WS:
--   CONCAT()    joins values with NO separator unless you type one in
--               manually between every pair of arguments.
--   CONCAT_WS() ("With Separator") takes the separator ONCE as its first
--               argument and inserts it automatically between every value
--               that follows — shorter and less error-prone for 3+ values.
--
-- NULL BEHAVIOR (interview-relevant):
--   CONCAT()    returns NULL for the WHOLE result if ANY argument is NULL.
--   CONCAT_WS() SKIPS NULL arguments and still joins the remaining ones —
--               it only returns NULL if the separator itself is NULL.

-- SIMPLE EXAMPLE
SELECT CONCAT('Shalinee', ' ', 'Priya')            AS concat_demo,
       CONCAT_WS(' ', 'Shalinee', 'Priya', 'SQL')  AS concat_ws_demo;

-- NULL BEHAVIOR DEMO
SELECT CONCAT('Report', NULL, 'Ready')      AS concat_with_null,   -- NULL
       CONCAT_WS('-', 'Report', NULL, 'Ready') AS concat_ws_with_null; -- 'Report-Ready'

-- COLUMN-BASED EXAMPLE
SELECT emp_id, CONCAT(first_name, ' ', last_name) AS full_name
FROM employees;

-- BUSINESS EXAMPLE: build a one-line employee label for a dropdown/report
SELECT CONCAT_WS(' | ', CONCAT(first_name,' ',last_name), department, email) AS employee_label
FROM employees;

-- PRACTICE: Using CONCAT_WS(), build "FirstName LastName (Department)" for
-- every employee, e.g. "Amit Sharma (Sales)".


-- -----------------------------------------------------------------------------
-- 3C. LENGTH() vs CHAR_LENGTH() — Length
-- -----------------------------------------------------------------------------
-- WHAT: Both measure the size of a string, but they measure DIFFERENT things.
-- SYNTAX: LENGTH(string) | CHAR_LENGTH(string)
--
-- INTERVIEW-WORTHY DISTINCTION:
--   LENGTH()      -> returns size in BYTES.
--   CHAR_LENGTH()  -> returns size in CHARACTERS.
-- For plain ASCII text (A-Z, 0-9, common punctuation) every character is
-- exactly 1 byte in UTF-8, so the two functions agree. The moment a string
-- contains a multi-byte character (accented letters, emoji, Indian-language
-- script, etc. under utf8mb4), LENGTH() counts more than CHAR_LENGTH() does.

-- ASCII EXAMPLE — identical result, because every character is 1 byte
SELECT LENGTH('Sales') AS length_bytes, CHAR_LENGTH('Sales') AS length_chars;

-- UNICODE EXAMPLE — 'é' is one CHARACTER but takes 2 BYTES in UTF-8
SELECT LENGTH('café') AS length_bytes, CHAR_LENGTH('café') AS length_chars;
-- length_bytes = 5 (c-a-f-é(2 bytes)), length_chars = 4 (c-a-f-é)

-- COLUMN-BASED EXAMPLE
SELECT email, LENGTH(email) AS email_length_bytes
FROM employees;

-- BUSINESS EXAMPLE: flag emails longer than 24 characters for a UI truncation rule
SELECT email, CHAR_LENGTH(email) AS char_count
FROM employees
WHERE CHAR_LENGTH(email) > 24;

-- PRACTICE: Find every employee whose full name (first + last, with a space)
-- is longer than 12 characters.


-- -----------------------------------------------------------------------------
-- 3D. TRIM() / LTRIM() / RTRIM() — Trimming / Cleaning
-- -----------------------------------------------------------------------------
-- WHAT: Removes unwanted spaces (or a specific character/string) from text.
-- SYNTAX:
--   TRIM(string)                                  -- removes leading+trailing spaces
--   TRIM(LEADING  'char' FROM string)              -- removes a specific leading value
--   TRIM(TRAILING 'char' FROM string)              -- removes a specific trailing value
--   TRIM(BOTH     'char' FROM string)               -- removes it from both sides
--   LTRIM(string)                                  -- removes LEADING spaces only
--   RTRIM(string)                                  -- removes TRAILING spaces only
--
-- IMPORTANT CORRECTION: in MySQL, LTRIM() and RTRIM() take ONLY ONE argument
-- (the string) — they always strip plain whitespace and do NOT accept a
-- second "characters to remove" argument. To strip a specific character
-- (not just spaces), use TRIM(LEADING/TRAILING/BOTH '<char>' FROM string) as
-- shown above, not LTRIM(string, '<char>') / RTRIM(string, '<char>').

-- SIMPLE EXAMPLE
SELECT TRIM('   SQL Training   ')                    AS trim_demo,
       LTRIM('   SQL Training   ')                   AS ltrim_demo,
       RTRIM('   SQL Training   ')                   AS rtrim_demo,
       TRIM(LEADING '0' FROM '00042')                AS trim_specific_char;

-- LENGTH BEFORE/AFTER, to prove the spaces were really removed
SELECT LENGTH('   SQL Training   ')        AS before_trim,
       LENGTH(TRIM('   SQL Training   '))  AS after_trim;

-- COLUMN-BASED EXAMPLE — emp_id 11 (Farhan Khan) was loaded with
-- '  Farhan  ' (leading + trailing spaces) on purpose. This is the row that
-- makes TRIM() a real cleaning operation instead of a no-op demo.
SELECT emp_id, first_name,
       LENGTH(first_name)       AS raw_length,
       TRIM(first_name)         AS cleaned_name,
       LENGTH(TRIM(first_name)) AS cleaned_length
FROM employees
WHERE emp_id = 11;

-- BUSINESS EXAMPLE: clean every first_name before building a mailing list
SELECT emp_id, CONCAT(TRIM(first_name), ' ', last_name) AS clean_full_name
FROM employees;

-- PRACTICE: Confirm that TRIM(first_name) matches first_name for every
-- employee EXCEPT emp_id 11.


-- -----------------------------------------------------------------------------
-- 3E. SUBSTRING() / SUBSTR() / LEFT() / RIGHT() — Substring Extraction
-- -----------------------------------------------------------------------------
-- WHAT: Extracts part of a string.
-- SYNTAX:
--   SUBSTRING(string, start_position, length)   -- length is optional
--   SUBSTR(string, start_position, length)      -- SUBSTR is a MySQL synonym
--                                                   for SUBSTRING, identical
--                                                   behavior, either name works
--   LEFT(string, n)                             -- first n characters
--   RIGHT(string, n)                             -- last n characters
--
-- POSITIONS ARE 1-INDEXED (the first character is position 1, not 0).
-- If you omit the length in SUBSTRING(), it returns everything from the
-- start position to the end of the string.

-- SIMPLE EXAMPLE
SELECT SUBSTRING('SQL Training', 1, 3)  AS substring_demo,   -- 'SQL'
       SUBSTR('SQL Training', 5)        AS substr_no_length,  -- 'Training'
       LEFT('SQL Training', 3)          AS left_demo,         -- 'SQL'
       RIGHT('SQL Training', 8)         AS right_demo;        -- 'Training'

-- COLUMN-BASED EXAMPLE
SELECT first_name, LEFT(first_name, 3) AS first_three, RIGHT(last_name, 3) AS last_three
FROM employees;

-- BUSINESS EXAMPLE: generate a 2-letter department code for a badge system
SELECT dept_name, UPPER(LEFT(dept_name, 2)) AS dept_code
FROM departments;

-- PRACTICE: Display each employee's first_name with the FIRST character
-- removed (hint: SUBSTRING starting at position 2).


-- -----------------------------------------------------------------------------
-- 3F. LOCATE() / INSTR() — Searching Inside Strings
-- -----------------------------------------------------------------------------
-- WHAT: Returns the 1-indexed POSITION of the first occurrence of a
-- substring inside a string. Both return 0 if the substring is NOT found —
-- MySQL never returns NULL or -1 here, it returns 0.
-- SYNTAX:
--   LOCATE(substring, string)   -- note the ARGUMENT ORDER: needle, haystack
--   INSTR(string, substring)    -- note the OPPOSITE order: haystack, needle

-- SIMPLE EXAMPLE
SELECT LOCATE('@', 'amit.sharma@company.com') AS locate_position,  -- 12
       INSTR('amit.sharma@company.com', '@')  AS instr_position,   -- 12 (same answer, opposite arg order)
       LOCATE('xyz', 'amit.sharma@company.com') AS not_found_result; -- 0

-- COLUMN-BASED EXAMPLE
SELECT email, LOCATE('@', email) AS at_position
FROM employees;

-- BUSINESS EXAMPLE: find employees whose email domain is NOT "company.com"
SELECT email
FROM employees
WHERE INSTR(email, '@company.com') = 0;
-- (returns 0 rows here — every employee uses the same corporate domain;
--  the query is still worth running to see 0 rows, not an error)

-- PRACTICE: Find every employee whose last_name contains the letter 'a'
-- using LOCATE() instead of LIKE.


-- -----------------------------------------------------------------------------
-- 3G. REPLACE() — Replacement
-- -----------------------------------------------------------------------------
-- WHAT: Replaces every occurrence of a substring with another substring.
-- SYNTAX: REPLACE(string, old_substring, new_substring)

-- SIMPLE EXAMPLE
SELECT REPLACE('SQL Training Batch', ' ', '_') AS replace_demo;

-- BUSINESS EXAMPLE 1: the company is migrating email domains
SELECT email, REPLACE(email, 'company.com', 'newcorp.io') AS migrated_email
FROM employees;

-- BUSINESS EXAMPLE 2: standardize department text for an old export that
-- used underscores instead of spaces
SELECT REPLACE('Human_Resources', '_', ' ') AS standardized_text;

-- PRACTICE: Replace every space in each employee's full name
-- (first + last) with a hyphen, to build a URL-safe profile slug.


-- -----------------------------------------------------------------------------
-- 3H. SUBSTRING_INDEX() — Split / Extract Based on a Delimiter
-- -----------------------------------------------------------------------------
-- WHAT: MySQL has NO native SPLIT() or SPLIT_PART() function (these exist in
-- some other database systems, but calling them in MySQL raises
-- "FUNCTION ... does not exist"). The correct MySQL tool for delimiter-based
-- extraction is SUBSTRING_INDEX().
-- SYNTAX: SUBSTRING_INDEX(string, delimiter, count)
--   count > 0 -> returns everything BEFORE the count-th delimiter (from the left)
--   count < 0 -> returns everything AFTER the count-th delimiter (from the right)
--
-- EMAIL EXAMPLE: amit.sharma@company.com
--   SUBSTRING_INDEX(email, '@', 1)  -> 'amit.sharma'    (username, before @)
--   SUBSTRING_INDEX(email, '@', -1) -> 'company.com'    (domain, after @)

-- SIMPLE EXAMPLE
SELECT SUBSTRING_INDEX('amit.sharma@company.com', '@', 1)  AS username_demo,
       SUBSTRING_INDEX('amit.sharma@company.com', '@', -1) AS domain_demo;

-- COLUMN-BASED EXAMPLE
SELECT email,
       SUBSTRING_INDEX(email, '@', 1)  AS username,
       SUBSTRING_INDEX(email, '@', -1) AS domain
FROM employees;

-- BUSINESS EXAMPLE: username can itself be split further on '.' to get a
-- first-name-like token (useful when email is the only text source available)
SELECT email,
       SUBSTRING_INDEX(SUBSTRING_INDEX(email, '@', 1), '.', 1) AS email_first_token
FROM employees;

-- PRACTICE: Count how many distinct email domains exist in the employees table.


-- -----------------------------------------------------------------------------
-- 3I. LPAD() / RPAD() — Padding
-- -----------------------------------------------------------------------------
-- WHAT: Pads a string on the LEFT or RIGHT with a repeating character until
-- it reaches a target total length. If the string is already >= that
-- length, MySQL truncates it to fit instead of padding.
-- SYNTAX: LPAD(string, total_length, pad_string) | RPAD(string, total_length, pad_string)

-- SIMPLE EXAMPLE
SELECT LPAD('42', 5, '0')  AS lpad_demo,   -- '00042'
       RPAD('42', 5, '-')  AS rpad_demo;   -- '42---'

-- BUSINESS EXAMPLE 1: fixed-width Employee ID codes, e.g. EMP-0001
SELECT emp_id, CONCAT('EMP-', LPAD(emp_id, 4, '0')) AS employee_code
FROM employees;

-- BUSINESS EXAMPLE 2: fixed-width invoice-style numbering (right-padded label column)
SELECT dept_name, RPAD(dept_name, 12, '.') AS padded_label
FROM departments;

-- PRACTICE: Generate an "INV-2026-####" style invoice number for each
-- employee using their emp_id, zero-padded to 4 digits.


-- -----------------------------------------------------------------------------
-- 3J. REVERSE() — Reversal
-- -----------------------------------------------------------------------------
-- WHAT: Reverses the character order of a string. Mostly an interview/
-- awareness function (palindrome checks, obfuscation demos) rather than a
-- everyday business tool.
-- SYNTAX: REVERSE(string)

SELECT first_name, REVERSE(first_name) AS reversed_name
FROM employees;

-- PRACTICE: Using REVERSE(), check whether the word 'LEVEL' is a palindrome.


-- -----------------------------------------------------------------------------
-- 3K. REPEAT() / ASCII() / CHAR() — Awareness Level
-- -----------------------------------------------------------------------------
-- WHAT (brief, interview-level — not lengthy classroom treatment):
--   REPEAT(string, n)  -> repeats a string n times
--   ASCII(char)         -> returns the numeric ASCII code of the FIRST character
--   CHAR(code)          -> the reverse of ASCII() — turns a numeric code back
--                          into its character

SELECT REPEAT('=', 10)  AS repeat_demo,   -- '=========='
       ASCII('A')       AS ascii_demo,    -- 65
       CHAR(65)         AS char_demo;     -- 'A'

-- Practical micro-use: a simple masked-password-style display bar
SELECT first_name, CONCAT(LEFT(first_name,1), REPEAT('*', LENGTH(first_name)-1)) AS masked_name
FROM employees;


-- -----------------------------------------------------------------------------
-- 3L. STRING FUNCTIONS + LIKE (Pattern Matching You Already Know)
-- -----------------------------------------------------------------------------
-- You already learned LIKE, %, and _ before Day 10. Functions become more
-- powerful once combined with the filtering you already know.

-- Employees whose last_name starts with 'K'
SELECT first_name, last_name FROM employees WHERE last_name LIKE 'K%';

-- Employees whose email's username portion contains a period (two-word names)
SELECT email FROM employees WHERE SUBSTRING_INDEX(email, '@', 1) LIKE '%.%';

-- Case-insensitive search is "built in" in MySQL's default collation, but
-- combining LOWER() with LIKE makes the intent explicit and portable
SELECT first_name, last_name FROM employees WHERE LOWER(last_name) LIKE '%a%';

-- PRACTICE: Find every employee whose department name is exactly 5
-- characters long AND starts with 'S' (combine CHAR_LENGTH with LIKE).


-- =============================================================================
-- SECTION 3X : STRING FUNCTION INTERVIEW CALLOUTS
-- =============================================================================
/*
INTERVIEW INSIGHT — LENGTH() vs CHAR_LENGTH():
LENGTH() counts BYTES, CHAR_LENGTH() counts CHARACTERS. They agree for plain
ASCII text and diverge the moment a multi-byte character appears (accents,
emoji, non-Latin scripts under utf8mb4).

INTERVIEW INSIGHT — CONCAT() vs CONCAT_WS():
CONCAT() returns NULL if ANY argument is NULL. CONCAT_WS() silently skips
NULL arguments and only fails if the separator itself is NULL — a common
reason production code prefers CONCAT_WS() when joining optional columns.

INTERVIEW INSIGHT — SUBSTRING() vs LEFT()/RIGHT():
SUBSTRING() is the general-purpose tool (any start position, any length).
LEFT()/RIGHT() are shorthand for the common case of "from the very start"
or "from the very end" — LEFT(s,n) is equivalent to SUBSTRING(s,1,n).

INTERVIEW INSIGHT — LOCATE() vs INSTR():
Both return a 1-indexed position, and 0 when not found. The only difference
is ARGUMENT ORDER: LOCATE(substring, string) vs INSTR(string, substring).
Mixing up the order is the single most common bug with these two.

INTERVIEW INSIGHT — TRIM() vs LTRIM()/RTRIM():
LTRIM()/RTRIM() only ever strip whitespace, from one side, with no second
argument. TRIM() is more flexible: TRIM(BOTH/LEADING/TRAILING '<char>' FROM
string) can strip any specific character or substring, from either or both
sides.

INTERVIEW INSIGHT — SUBSTRING_INDEX() for delimiter-based extraction:
This is MySQL's real answer to "split a string." A positive count counts
delimiters from the left (return everything BEFORE it); a negative count
counts from the right (return everything AFTER it). There is no SPLIT() or
SPLIT_PART() in MySQL.

INTERVIEW INSIGHT — String functions in SELECT vs WHERE:
Using a function in SELECT only changes how a value is DISPLAYED. Using the
SAME function in WHERE changes which ROWS are RETURNED — e.g.
SELECT UPPER(last_name) just formats output, while WHERE UPPER(last_name) =
'SHARMA' is a filter condition evaluated per row.

INTERVIEW INSIGHT — functions on columns inside WHERE and index usage:
Wrapping an indexed column in a function inside WHERE (e.g. WHERE
UPPER(last_name) = 'SHARMA') can, in some cases, prevent MySQL from using a
regular index efficiently on that column, because the engine must first
evaluate the function for every row before it can compare the result. This
is worth being AWARE of; it is not the focus of this module and is not a
reason to avoid functions in WHERE altogether — just something to keep in
mind for large, performance-critical tables.
*/


-- =============================================================================
-- SECTION 4 : STRING FUNCTION COMBINATIONS (Function Nesting)
-- =============================================================================
/*
Real business queries rarely use one string function alone — they NEST
functions, with the innermost function evaluating first, exactly like the
subquery inner-query-first rule you learned in Day 9.
*/

-- Clean + case-convert together: strip stray spaces, THEN uppercase
SELECT emp_id, first_name, UPPER(TRIM(first_name)) AS clean_upper_name
FROM employees
WHERE emp_id = 11;

-- Proper-case a name: first letter uppercase, rest lowercase
SELECT first_name,
       CONCAT(UPPER(LEFT(TRIM(first_name),1)), LOWER(SUBSTRING(TRIM(first_name),2))) AS proper_case_name
FROM employees;

-- Build initials from first_name + last_name
SELECT first_name, last_name,
       CONCAT(UPPER(LEFT(TRIM(first_name),1)), UPPER(LEFT(last_name,1))) AS initials
FROM employees;

-- Extract + format the email domain in uppercase for a report header
SELECT email, UPPER(SUBSTRING_INDEX(email, '@', -1)) AS domain_upper
FROM employees;

-- Masked email for a "forgot password" style confirmation screen:
-- show the first 2 characters of the username, mask the rest, keep the domain
SELECT email,
       CONCAT(LEFT(SUBSTRING_INDEX(email,'@',1), 2),
              REPEAT('*', GREATEST(CHAR_LENGTH(SUBSTRING_INDEX(email,'@',1)) - 2, 0)),
              '@', SUBSTRING_INDEX(email,'@',-1)) AS masked_email
FROM employees;

-- PRACTICE: Build a single "display label" column formatted as
-- "SHARMA, Amit — Sales" (LAST NAME in caps, comma, first name, em dash,
-- department) using only the functions covered so far.


-- =============================================================================
-- SECTION 5 : NUMERIC FUNCTIONS — CORE COVERAGE
-- =============================================================================
/*
CORE BUSINESS FUNCTIONS (frequent, everyday use):
  ROUND, TRUNCATE, CEIL/CEILING, FLOOR, ABS, MOD, POWER, SQRT, SIGN,
  GREATEST, LEAST

INTERVIEW / AWARENESS FUNCTIONS (know they exist, rarely hand-written in
day-to-day business SQL): RAND, LOG, LOG10, EXP, PI
*/

-- -----------------------------------------------------------------------------
-- 5A. ROUND() vs TRUNCATE() — the single most-asked numeric interview pair
-- -----------------------------------------------------------------------------
-- WHAT: Both reduce a number to a target number of decimal places, but
-- ROUND() rounds mathematically (up or down, whichever is nearer) while
-- TRUNCATE() simply CUTS OFF the extra digits with no rounding at all.
-- SYNTAX: ROUND(number, decimal_places) | TRUNCATE(number, decimal_places)

-- SIMPLE EXAMPLE — the classic textbook case
SELECT 15.789 AS original,
       ROUND(15.789, 2)    AS rounded,     -- 15.79 (rounds up, nearest)
       TRUNCATE(15.789, 2) AS truncated;   -- 15.78 (just chops off the '9')

-- COLUMN-BASED EXAMPLE
SELECT emp_id, salary,
       ROUND(salary, 0)    AS rounded_salary,
       TRUNCATE(salary, 0) AS truncated_salary
FROM employees
WHERE emp_id IN (1, 3, 13);

-- BUSINESS EXAMPLE: a finance report that must always round to the nearest rupee
SELECT first_name, salary, ROUND(salary, 0) AS salary_for_report
FROM employees;

-- PRACTICE: For every employee, show salary rounded to the nearest 1000
-- (hint: ROUND() accepts a negative decimal-places argument).


-- -----------------------------------------------------------------------------
-- 5B. CEIL() / CEILING() vs FLOOR()
-- -----------------------------------------------------------------------------
-- WHAT: CEIL()/CEILING() (identical, CEILING is the longer synonym) always
-- rounds UP to the next integer. FLOOR() always rounds DOWN to the previous
-- integer — regardless of how close the decimal part is.
-- SYNTAX: CEIL(number) | CEILING(number) | FLOOR(number)

SELECT 15.1 AS original, CEIL(15.1) AS ceil_demo, CEILING(15.1) AS ceiling_demo, FLOOR(15.1) AS floor_demo;
SELECT 15.9 AS original, CEIL(15.9) AS ceil_demo, FLOOR(15.9) AS floor_demo;

-- BUSINESS EXAMPLE: shipping calculates "boxes needed" — always rounds UP,
-- since a partially-full box still needs a whole box
SELECT 47 AS items, 10 AS items_per_box, CEIL(47/10) AS boxes_needed;

SELECT emp_id, salary, CEIL(salary) AS ceiling_value, FLOOR(salary) AS floor_value
FROM employees
WHERE emp_id IN (1, 5);

-- PRACTICE: How many whole ₹10,000 salary "brackets" does each employee's
-- salary fully complete? (hint: FLOOR(salary / 10000))


-- -----------------------------------------------------------------------------
-- 5C. ABS() — Absolute Value
-- -----------------------------------------------------------------------------
-- WHAT: Strips the sign from a number, always returning a positive value.
-- Extremely useful for "difference analysis" where you only care about the
-- SIZE of a gap, not its direction.
-- SYNTAX: ABS(number)

SELECT ABS(-45.5) AS absolute_value;

-- BUSINESS EXAMPLE: how far is each employee's salary from the company
-- average, regardless of whether they earn more or less?
SELECT first_name, salary,
       ROUND(salary - (SELECT AVG(salary) FROM employees), 2) AS diff_from_avg,
       ROUND(ABS(salary - (SELECT AVG(salary) FROM employees)), 2) AS absolute_diff_from_avg
FROM employees;

-- PRACTICE: Find the 3 employees whose salary is CLOSEST to the company
-- average (smallest absolute difference).


-- -----------------------------------------------------------------------------
-- 5D. MOD() — Remainder
-- -----------------------------------------------------------------------------
-- WHAT: Returns the remainder of a division. Same result as the % operator
-- in MySQL, but MOD() reads more clearly and works well inside CASE/WHERE.
-- SYNTAX: MOD(dividend, divisor)     -- MOD(17, 5) and 17 % 5 are equivalent

SELECT MOD(17, 5) AS mod_demo, 17 % 5 AS percent_operator_demo;

-- BUSINESS EXAMPLE 1: even/odd employee IDs (a classic cyclic-logic demo)
SELECT emp_id, first_name,
       CASE WHEN MOD(emp_id, 2) = 0 THEN 'Even' ELSE 'Odd' END AS id_parity
FROM employees;

-- BUSINESS EXAMPLE 2: cyclic assignment — put employees into 3 rotating
-- shift groups (0, 1, 2) purely from their emp_id, no extra column needed
SELECT emp_id, first_name, MOD(emp_id, 3) AS shift_group
FROM employees;

-- PRACTICE: Using MOD(), list only the employees with an ODD emp_id.


-- -----------------------------------------------------------------------------
-- 5E. POWER() / SQRT()
-- -----------------------------------------------------------------------------
-- SYNTAX: POWER(base, exponent) | SQRT(number)

SELECT POWER(5, 2) AS power_demo, SQRT(144) AS sqrt_demo;

-- Rarely applied directly to business columns like salary — shown here for
-- syntax familiarity, since "square/cube a number" is a common exam ask
SELECT bonus_pct, POWER(bonus_pct, 2) AS bonus_pct_squared
FROM employees
WHERE emp_id = 5;


-- -----------------------------------------------------------------------------
-- 5F. SIGN()
-- -----------------------------------------------------------------------------
-- WHAT: Returns -1 (negative), 0 (zero), or 1 (positive) depending on the
-- sign of the number — useful for quick profit/loss style classification.
-- SYNTAX: SIGN(number)

SELECT SIGN(-25) AS negative, SIGN(0) AS zero_case, SIGN(25) AS positive;

SELECT first_name,
       ROUND(salary - 60000, 2) AS diff_from_60k,
       SIGN(salary - 60000)     AS sign_of_diff   -- 1 = above 60k, -1 = below, 0 = exactly 60k
FROM employees;


-- -----------------------------------------------------------------------------
-- 5G. GREATEST() / LEAST()
-- -----------------------------------------------------------------------------
-- WHAT: Compares two or more VALUES ON THE SAME ROW and returns the largest
-- (GREATEST) or smallest (LEAST) of them.
-- SYNTAX: GREATEST(value1, value2, ...) | LEAST(value1, value2, ...)
--
-- INTERVIEW INSIGHT — MAX(column) vs GREATEST(value1, value2, ...):
-- MAX() is an AGGREGATE function: it scans MANY ROWS in one column and
-- returns the single largest value across all of them (Day 3 concept).
-- GREATEST() is a SCALAR function: it compares MULTIPLE COLUMNS (or literal
-- values) WITHIN THE SAME ROW and returns the largest of those — it never
-- looks at other rows at all. "Find the highest salary in the company" is
-- MAX(salary). "For each employee, which is bigger — their salary or their
-- bonus scaled up?" is GREATEST(salary, bonus_pct * 1000) per row. Mixing
-- these two up is one of the most common numeric-function interview traps.

SELECT GREATEST(10, 25, 3, 47, 8) AS greatest_demo, LEAST(10, 25, 3, 47, 8) AS least_demo;

-- MAX() (aggregate — one answer for the whole table)
SELECT MAX(salary) AS highest_salary_in_company FROM employees;

-- GREATEST() (scalar — one answer PER ROW, comparing two columns)
SELECT emp_id, salary, bonus_pct,
       GREATEST(salary, bonus_pct * 1000) AS greater_of_the_two
FROM employees;

-- INTERVIEW / AWARENESS — GREATEST()/LEAST() and NULL:
SELECT GREATEST(10, NULL, 20) AS result;   -- NULL, not 20
-- In MySQL, a NULL argument affects the GREATEST()/LEAST() result — if ANY
-- argument is NULL, the function returns NULL. Do not assume NULL behaves
-- like 0 (which would make 20 the "obvious" answer) — it does not.

-- PRACTICE: For every employee, display the SMALLER of (salary/12) and 6000
-- using LEAST().


-- -----------------------------------------------------------------------------
-- 5H. AWARENESS / INTERVIEW-LEVEL NUMERIC FUNCTIONS
-- -----------------------------------------------------------------------------
-- These exist in MySQL and are worth recognizing, but are not core, everyday
-- business tools — kept brief on purpose.
--   RAND()   -> random floating-point number between 0 and 1
--   LOG()    -> natural logarithm (base e); LOG(base, number) for a custom base
--   LOG10()  -> logarithm to base 10
--   EXP()    -> e raised to the given power
--   PI()     -> the constant pi (3.141592...)

SELECT RAND()          AS random_0_to_1,
       LOG(100)        AS natural_log_100,
       LOG10(1000)     AS log10_of_1000,   -- 3
       EXP(1)          AS e_to_the_1,      -- ~2.71828
       PI()            AS value_of_pi;     -- 3.141593


-- =============================================================================
-- SECTION 6 : NUMERIC BUSINESS CALCULATIONS
-- =============================================================================
-- These are ordinary arithmetic EXPRESSIONS (not new functions) that become
-- genuinely useful once wrapped in ROUND() for presentation.

-- Bonus amount for every employee: salary * bonus_pct / 100
SELECT first_name, salary, bonus_pct,
       ROUND(salary * bonus_pct / 100, 2) AS bonus_amount
FROM employees;

-- Monthly salary (annual salary stored / 12 months)
SELECT first_name, salary, ROUND(salary / 12, 2) AS monthly_salary
FROM employees;

-- Projected salary after a 10% annual raise
SELECT first_name, salary, ROUND(salary * 1.10, 2) AS salary_after_10pct_raise
FROM employees;

-- Total annual compensation = salary + bonus amount
SELECT first_name, salary,
       ROUND(salary * bonus_pct / 100, 2)                    AS bonus_amount,
       ROUND(salary + (salary * bonus_pct / 100), 2)         AS total_annual_compensation
FROM employees;

-- NULL BEHAVIOR IN NUMERIC EXPRESSIONS (interview point, previewed here,
-- covered fully in Section 9): any arithmetic expression involving a NULL
-- operand evaluates to NULL, not 0 and not an error. There is no NULL
-- numeric column in this dataset's salary/bonus_pct fields to demonstrate
-- this live, but it applies the moment one is introduced — e.g. a missing
-- bonus_pct would make bonus_amount evaluate to NULL, not 0.

-- PRACTICE: Prepare a report with employee name, monthly salary (rounded to
-- 2 decimals) and bonus amount (rounded to 2 decimals), ordered by monthly
-- salary descending.


-- =============================================================================
-- SECTION 7 : DATE & TIME FUNCTIONS — CORE COVERAGE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 7A. Current Date / Time Functions
-- -----------------------------------------------------------------------------
-- CURDATE() / CURRENT_DATE()       -> today's date (identical, CURRENT_DATE
--                                     is the standard-SQL-style synonym)
-- CURTIME() / CURRENT_TIME()       -> current time (identical pair)
-- NOW() / CURRENT_TIMESTAMP()      -> current date AND time (identical pair)
--
-- These all reflect the moment the QUERY STATEMENT begins executing, and
-- stay fixed for that entire statement even if the statement takes a while
-- to run.
--
-- AWARENESS: SYSDATE() also returns the current date and time, but unlike
-- NOW(), it reflects the exact moment SYSDATE() itself is evaluated — so
-- two SYSDATE() calls in a slow-running statement CAN return different
-- values, while two NOW() calls in the same statement never will. This is
-- a subtle awareness point, not a function you need to reach for often.

SELECT CURDATE() AS curdate_value, CURRENT_DATE() AS current_date_value,
       CURTIME() AS curtime_value, CURRENT_TIME() AS current_time_value,
       NOW()     AS now_value,     CURRENT_TIMESTAMP() AS current_timestamp_value;

-- NOTE ON EXPECTED OUTPUT: every query in this subsection depends on WHEN
-- you run it. Do not expect the same value twice on two different days —
-- that is correct behavior, not a bug.


-- -----------------------------------------------------------------------------
-- 7B. Extracting Date/Time Parts
-- -----------------------------------------------------------------------------
-- YEAR(), MONTH(), MONTHNAME(), DAY(), DAYOFMONTH(), DAYNAME(),
-- DAYOFWEEK(), DAYOFYEAR(), QUARTER(), WEEK()   -- all work on DATE columns
-- HOUR(), MINUTE(), SECOND()                     -- need a DATETIME/TIME value

SELECT hire_date,
       YEAR(hire_date)      AS yr,
       MONTH(hire_date)     AS mon_num,
       MONTHNAME(hire_date) AS mon_name,
       DAY(hire_date)       AS day_num,          -- same as DAYOFMONTH()
       DAYOFMONTH(hire_date) AS day_of_month,
       DAYNAME(hire_date)   AS weekday_name,
       DAYOFWEEK(hire_date) AS weekday_num,       -- 1 = Sunday ... 7 = Saturday
       DAYOFYEAR(hire_date) AS day_of_year,
       QUARTER(hire_date)   AS qtr,
       WEEK(hire_date)      AS week_num           -- see WEEK() awareness note below
FROM employees
WHERE emp_id = 1;   -- Amit Sharma, hire_date 2019-03-15 (a Friday)

-- INTERVIEW / AWARENESS — DAYOFWEEK() vs WEEKDAY(): two DIFFERENT numbering
-- systems for "which day of the week," easy to confuse:
--   DAYOFWEEK(date)  -> Sunday = 1, Monday = 2, ... Saturday = 7
--   WEEKDAY(date)    -> Monday = 0, Tuesday = 1, ... Sunday = 6
-- For hire_date 2019-03-15 (a Friday): DAYOFWEEK() returns 6, WEEKDAY()
-- returns 4 — SAME day, two different numbers, because the two functions
-- start counting from a different day AND from a different base (1 vs 0).
-- Do not assume the two are interchangeable.
SELECT hire_date, DAYNAME(hire_date) AS weekday_name,
       DAYOFWEEK(hire_date) AS dayofweek_sun_is_1,
       WEEKDAY(hire_date)   AS weekday_mon_is_0
FROM employees
WHERE emp_id = 1;

-- INTERVIEW / AWARENESS — WEEK(): the week NUMBER it returns depends on
-- MySQL's week-mode rules (which day a week is considered to start on, and
-- how the first week of the year is defined) — WEEK(date) uses a default
-- mode unless a second argument is supplied. Do not assume a universal
-- Monday/Sunday convention without checking the mode; this is worth knowing
-- exists, not a rule to memorize in depth for this module.

-- HOUR()/MINUTE()/SECOND() need last_login (a DATETIME), not hire_date (a DATE)
SELECT first_name, last_login,
       HOUR(last_login)   AS login_hour,
       MINUTE(last_login) AS login_minute,
       SECOND(last_login) AS login_second
FROM employees
WHERE last_login IS NOT NULL;

-- BUSINESS USE: these extraction functions power monthly/yearly/quarterly
-- reporting, weekday hiring-pattern analysis, and login-time analysis —
-- you will use several of them together in Section 11 and Section 12.


-- -----------------------------------------------------------------------------
-- 7C. DATE() and TIME() — Splitting a DATETIME into its Date/Time Portion
-- -----------------------------------------------------------------------------
-- WHAT: DATE(datetime_value) returns just the date portion of a DATETIME.
-- TIME(datetime_value) returns just the time portion. Both return a real
-- DATE/TIME VALUE — not formatted text — so the result can still be used in
-- further date calculations, comparisons, or GROUP BY.
-- SYNTAX: DATE(datetime_expr) | TIME(datetime_expr)
--
-- IMPORTANT DISTINCTION — DATE()/TIME() vs DATE_FORMAT()/TIME_FORMAT()
-- (the formatting functions covered next, in Section 8C):
--   DATE() / TIME()               -> EXTRACT a date/time VALUE (still a
--                                     real DATE/TIME, usable in more
--                                     calculations)
--   DATE_FORMAT() / TIME_FORMAT() -> FORMAT a value for PRESENTATION and
--                                     return TEXT (a display string, not a
--                                     usable date/time anymore)

-- SIMPLE EXAMPLE — last_login = '2026-07-01 09:15:00'
SELECT last_login,
       DATE(last_login) AS date_part,   -- 2026-07-01 (still a DATE)
       TIME(last_login) AS time_part    -- 09:15:00   (still a TIME)
FROM employees
WHERE emp_id = 1;

-- BUSINESS EXAMPLE: how many DISTINCT calendar days had at least one login?
-- (GROUP BY needs the DATE portion only — the exact time would make every
-- login its own group)
SELECT DATE(last_login) AS login_day, COUNT(*) AS logins_that_day
FROM employees
WHERE last_login IS NOT NULL
GROUP BY DATE(last_login);

-- INTERVIEW NOTE: DATE(last_login) = '2026-07-01' can be compared directly
-- to another DATE value or used inside DATEDIFF()/TIMESTAMPDIFF(). The
-- MOMENT you wrap it in DATE_FORMAT(last_login, '%d %M %Y') instead, the
-- result becomes the TEXT '01 July 2026' — still readable, but no longer
-- something you can subtract, compare with <, or pass into another date
-- function. Reach for DATE()/TIME() when you still need to CALCULATE;
-- reach for DATE_FORMAT()/TIME_FORMAT() only at the final PRESENTATION step
-- (see "Calculate First, Format Last" in Section 8C).


-- =============================================================================
-- SECTION 8 : DATE ARITHMETIC / DIFFERENCE / FORMATTING
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 8A. Date Arithmetic — DATE_ADD() / DATE_SUB()
-- -----------------------------------------------------------------------------
-- SYNTAX: DATE_ADD(date, INTERVAL n unit) | DATE_SUB(date, INTERVAL n unit)
-- unit can be DAY, MONTH, YEAR, WEEK, HOUR, etc.
-- AWARENESS: ADDDATE()/SUBDATE() are MySQL alternatives with identical
-- behavior to DATE_ADD()/DATE_SUB() (ADDDATE also accepts a plain number of
-- days with no INTERVAL keyword, as a shorthand).

SELECT hire_date,
       DATE_ADD(hire_date, INTERVAL 90 DAY)  AS probation_end_90_days,
       DATE_ADD(hire_date, INTERVAL 1 YEAR)  AS one_year_anniversary,
       DATE_SUB(hire_date, INTERVAL 1 MONTH) AS one_month_before_hire
FROM employees
WHERE emp_id = 1;

-- ADDDATE()/SUBDATE() awareness
SELECT hire_date,
       ADDDATE(hire_date, INTERVAL 2 YEAR) AS two_years_after_interval_form,
       ADDDATE(hire_date, 30)              AS thirty_days_after_plain_number_form,
       SUBDATE(hire_date, 15)              AS fifteen_days_before
FROM employees
WHERE emp_id = 1;

-- BUSINESS EXAMPLE: retirement/long-service eligibility — 25 years from hire
SELECT first_name, hire_date, DATE_ADD(hire_date, INTERVAL 25 YEAR) AS long_service_eligibility_date
FROM employees;

-- -----------------------------------------------------------------------------
-- 8B. Date Difference — DATEDIFF() vs TIMEDIFF() vs TIMESTAMPDIFF()
-- -----------------------------------------------------------------------------
/*
INTERVIEW COMPARISON TABLE:
+------------------+---------------------------------+---------------------+
| Function         | Compares                         | Result Unit         |
+------------------+---------------------------------+---------------------+
| DATEDIFF()       | two DATE (or DATETIME) values    | always DAYS         |
| TIMEDIFF()       | two TIME or two DATETIME values  | HH:MM:SS duration    |
| TIMESTAMPDIFF()  | two DATE/DATETIME values         | the UNIT you choose  |
|                  | (YEAR, MONTH, DAY, HOUR, etc.)   | (YEAR/MONTH/DAY/...) |
+------------------+---------------------------------+---------------------+

DATEDIFF()      -> difference in DAYS. Simple, but ONLY days — dividing that
                   by 365 to estimate "years" is inaccurate (leap years, and
                   it never rounds the way a human counts completed years).
TIMEDIFF()      -> returns a TIME-format duration and is useful for
                   calculating elapsed time between TIME/DATETIME values
                   (e.g. shift lengths or session durations). For date
                   differences expressed in days, months or years,
                   DATEDIFF() or TIMESTAMPDIFF() is usually more
                   appropriate.
TIMESTAMPDIFF(unit, start, end) -> the most flexible: YOU pick the unit
                   (YEAR, MONTH, DAY, HOUR...). This is why
                   TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) is preferred
                   over DATEDIFF(CURDATE(), birth_date) / 365 for age — it
                   correctly counts only COMPLETED years, accounting for
                   whether this year's birthday has already occurred.
*/

-- DATEDIFF() — always days
SELECT first_name, hire_date, DATEDIFF(CURDATE(), hire_date) AS days_since_hired
FROM employees
WHERE emp_id = 1;

-- TIMEDIFF() — HH:MM:SS between two TIME/DATETIME values of the same kind
SELECT TIMEDIFF('18:30:00', '09:15:00') AS work_hours_diff;

-- TIMESTAMPDIFF() — you choose the unit; this is how age and tenure should
-- be calculated, NOT by dividing DATEDIFF's day count by 365
SELECT first_name, birth_date, hire_date,
       TIMESTAMPDIFF(YEAR,  birth_date, CURDATE()) AS age_in_completed_years,
       TIMESTAMPDIFF(YEAR,  hire_date,  CURDATE()) AS years_of_service,
       TIMESTAMPDIFF(MONTH, hire_date,  CURDATE()) AS tenure_in_months
FROM employees;
-- NOTE ON EXPECTED OUTPUT: age_in_completed_years and years_of_service
-- depend on CURDATE() at execution time and will change as real time
-- passes — that is correct, not a bug. Re-running this query next year
-- will correctly show one more completed year for everyone still employed.

-- PRACTICE: Which employees have completed 5 or more years of service as of
-- today? Order the most recently hired first.


-- -----------------------------------------------------------------------------
-- 8C. Date Formatting — DATE_FORMAT() / TIME_FORMAT()
-- -----------------------------------------------------------------------------
-- SYNTAX: DATE_FORMAT(date, format_string)
-- KEY FORMAT SPECIFIERS:
--   %d = day of month (01-31)      %m = month number (01-12)
--   %Y = 4-digit year               %y = 2-digit year
--   %M = full month name            %b = abbreviated month name (Jan, Feb...)
--   %W = full weekday name          %a = abbreviated weekday name (Mon, Tue...)

SELECT hire_date,
       DATE_FORMAT(hire_date, '%d %M %Y')      AS report_style,      -- '15 March 2019'
       DATE_FORMAT(hire_date, '%W, %d %M %Y')  AS full_report_style, -- 'Friday, 15 March 2019'
       DATE_FORMAT(hire_date, '%b-%Y')         AS short_style,       -- 'Mar-2019'
       DATE_FORMAT(hire_date, '%d/%m/%y')      AS numeric_style      -- '15/03/19'
FROM employees
WHERE emp_id = 1;

-- TIME_FORMAT() — same idea, for TIME/DATETIME presentation
-- %H = hour (24-hour), %h = hour (12-hour), %i = minutes, %s = seconds, %p = AM/PM
SELECT last_login,
       TIME_FORMAT(TIME(last_login), '%H:%i:%s') AS time_24hr,
       TIME_FORMAT(TIME(last_login), '%h:%i %p') AS time_12hr
FROM employees
WHERE last_login IS NOT NULL;

-- BUSINESS EXAMPLE: a management-ready one-line hire summary
SELECT CONCAT(first_name, ' ', last_name, ' joined ', department, ' on ',
              DATE_FORMAT(hire_date, '%d %M %Y')) AS hire_summary
FROM employees
WHERE emp_id = 1;

-- INTERVIEW INSIGHT — "CALCULATE FIRST, FORMAT LAST":
--
--        CALCULATE FIRST
--              |
--   DATEDIFF() / TIMESTAMPDIFF() / DATE_ADD() / DATE_SUB()
--   (real DATE/DATETIME values in, real DATE/DATETIME/number out)
--              |
--              v
--         FORMAT LAST
--              |
--     DATE_FORMAT() / TIME_FORMAT()
--     (returns TEXT — for display only, not for further calculation)
--
-- DATE_FORMAT() returns TEXT. Treat the formatted result as presentation
-- output rather than as the working DATE/DATETIME value. Perform date
-- calculations on the original DATE/DATETIME value before formatting.
-- Do all date arithmetic and differencing on the REAL date/datetime values
-- first (e.g. DATEDIFF(CURDATE(), hire_date) to get days of service), and
-- only wrap the values that actually need to be DISPLAYED in DATE_FORMAT()
-- at the end — for example, in the query above, DATE_FORMAT(hire_date, ...)
-- runs on the original hire_date, not on some already-formatted string.

-- PRACTICE: Format every employee's hire_date as "Jul-2026"-style
-- (abbreviated month + 4-digit year).


-- -----------------------------------------------------------------------------
-- 8D. Date Conversion — STR_TO_DATE() / CAST()
-- -----------------------------------------------------------------------------
-- WHAT: DATE_FORMAT() turns a DATE into a display STRING. STR_TO_DATE() does
-- the reverse — turns a STRING into a real DATE value MySQL can calculate
-- with. CAST() converts between datatypes more generally (string<->date,
-- date<->char, etc.) and is useful whenever a value needs to change type,
-- not just be reformatted for display.
-- SYNTAX: STR_TO_DATE(string, format) | CAST(value AS target_type)

SELECT STR_TO_DATE('15-08-2023', '%d-%m-%Y')        AS string_to_date_demo,
       STR_TO_DATE('March 15, 2019', '%M %d, %Y')   AS string_to_date_demo2;

SELECT CAST('2026-08-20' AS DATE)  AS cast_string_to_date,
       CAST(hire_date AS CHAR)     AS cast_date_to_string
FROM employees
WHERE emp_id = 1;

-- PRACTICE: Convert the text '01-Jan-2025' into a proper DATE value using
-- STR_TO_DATE(), then add 6 months to it using DATE_ADD().


-- -----------------------------------------------------------------------------
-- 8E. Date Utility Functions — LAST_DAY() / EXTRACT()
-- -----------------------------------------------------------------------------
-- LAST_DAY(date) -> returns the last calendar date of that date's month.
-- Practical use: end-of-month billing cycles, "days remaining in this month."
SELECT hire_date, LAST_DAY(hire_date) AS end_of_hire_month
FROM employees
WHERE emp_id = 1;

SELECT hire_date, DATEDIFF(LAST_DAY(hire_date), hire_date) AS days_left_in_hire_month
FROM employees
WHERE emp_id = 1;

-- EXTRACT(part FROM date) -> a flexible, standard-SQL-style alternative to
-- calling YEAR()/MONTH()/QUARTER() individually — useful when you want one
-- consistent syntax for many different date parts.
SELECT hire_date,
       EXTRACT(YEAR    FROM hire_date) AS ext_year,
       EXTRACT(MONTH   FROM hire_date) AS ext_month,
       EXTRACT(QUARTER FROM hire_date) AS ext_quarter
FROM employees
WHERE emp_id = 1;


-- -----------------------------------------------------------------------------
-- 8F. Time Zone / UTC — Awareness Only
-- -----------------------------------------------------------------------------
-- UTC_DATE(), UTC_TIME(), UTC_TIMESTAMP() return the current date/time in
-- Coordinated Universal Time, ignoring the server's local time zone setting.
-- In distributed systems (servers/users across different regions), storing
-- and comparing timestamps in UTC avoids ambiguity about "which local time
-- zone does this value belong to" — a brief awareness point, not a function
-- you will use heavily inside this module.

SELECT UTC_DATE() AS utc_date_value, UTC_TIME() AS utc_time_value, UTC_TIMESTAMP() AS utc_timestamp_value;
SELECT NOW() AS local_datetime, UTC_TIMESTAMP() AS utc_datetime;


-- =============================================================================
-- SECTION 9 : NULL HANDLING — IS NULL, IFNULL(), COALESCE(), NULLIF()
-- =============================================================================
/*
The dataset has exactly one NULL value on purpose: emp_id 6 (Neha Gupta) has
never logged in, so last_login is NULL. This is intentional, real-world
data, not missing/broken data — use it to teach NULL handling properly.

IMPORTANT: NULL means "unknown / not applicable" — it is NOT the same as 0
and NOT the same as an empty string ''. Do not let this be misunderstood.
Many arithmetic expressions involving NULL evaluate to NULL (see Section 6).
String functions, however, have FUNCTION-SPECIFIC NULL behavior rather than
one universal rule — for example, CONCAT() returns NULL when ANY argument
is NULL, while CONCAT_WS() skips NULL arguments and keeps joining the rest
(see Section 3B). Always check the specific function's behavior rather than
assuming a blanket rule.
*/

-- IS NULL / IS NOT NULL — the only correct way to test for NULL
SELECT first_name, last_login FROM employees WHERE last_login IS NULL;
SELECT first_name, last_login FROM employees WHERE last_login IS NOT NULL;

-- COMMON MISTAKE (do not do this): = NULL never matches anything, because
-- NULL is not "equal" to anything, including itself. This intentionally
-- returns ZERO rows even though a NULL row exists, illustrating the trap.
SELECT first_name, last_login FROM employees WHERE last_login = NULL;

-- IFNULL() — substitutes a fallback value ONLY when the expression is NULL
SELECT first_name, last_login,
       IFNULL(last_login, 'Never Logged In') AS last_login_display
FROM employees;

-- COALESCE() — returns the FIRST non-NULL value from a LIST of expressions
-- (IFNULL only ever checks one expression against one fallback; COALESCE
-- can check many, in order, which is why it generalizes IFNULL). Kept to
-- ONE consistent datatype (text) below, so the example teaches the
-- mechanic itself rather than an incidental datatype conversion.
SELECT COALESCE(NULL, NULL, 'Fallback Reached') AS coalesce_mechanic_demo;
-- all three arguments are text, so this is purely "scan left to right,
-- return the first non-NULL one" — the actual mechanic COALESCE performs.

-- Applied to a real nullable column, paired with a single text fallback:
SELECT first_name, last_login,
       COALESCE(last_login, 'Never Logged In') AS last_login_or_fallback
FROM employees;
-- NOTE: with only TWO arguments, COALESCE() and IFNULL() behave
-- identically here. COALESCE()'s real advantage over IFNULL() is
-- supporting a THIRD, FOURTH, ... fallback in a chain, as shown above.

-- INTERVIEW INSIGHT — IFNULL() vs COALESCE():
-- IFNULL(expr, fallback) takes exactly TWO arguments. COALESCE(expr1,
-- expr2, expr3, ...) accepts ANY NUMBER of expressions and returns the
-- first one that is not NULL — a strict superset of what IFNULL can do.
-- Many teams standardize on COALESCE() everywhere for this flexibility,
-- even in the simple two-argument case.

-- NULLIF() — returns NULL if two expressions are EQUAL, otherwise returns
-- the first expression. Useful for turning a "sentinel" value into a
-- genuine NULL (e.g. treating a placeholder bonus_pct of 0 as "not set").
SELECT emp_id, bonus_pct, NULLIF(bonus_pct, 0) AS bonus_pct_or_null
FROM employees;

-- PRACTICE: Display a report listing every employee's last_login, showing
-- 'NEVER LOGGED IN' (in uppercase) instead of NULL where applicable.


-- =============================================================================
-- SECTION 10 : CASE + FUNCTIONS — SUPPORTING BUSINESS LOGIC
-- =============================================================================
-- Functions become far more useful for reporting once combined with CASE,
-- which turns a raw calculated value into a business-meaningful CATEGORY.

-- Salary bands
SELECT first_name, salary,
       CASE
           WHEN salary >= 80000 THEN 'High'
           WHEN salary >= 60000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_band
FROM employees;

-- Tenure categories, built on TIMESTAMPDIFF from Section 8
SELECT first_name, hire_date,
       TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_of_service,
       CASE
           WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 8 THEN 'Veteran'
           WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 3 THEN 'Established'
           ELSE 'New Joiner'
       END AS tenure_category
FROM employees;

-- Recent vs stale login classification, built on IS NULL + DATEDIFF
SELECT first_name, last_login,
       CASE
           WHEN last_login IS NULL THEN 'Never Logged In'
           WHEN DATEDIFF(CURDATE(), last_login) <= 14 THEN 'Recent'
           ELSE 'Inactive'
       END AS login_status
FROM employees;

-- Bonus band, built on the bonus amount calculated in Section 6
SELECT first_name, ROUND(salary * bonus_pct / 100, 2) AS bonus_amount,
       CASE
           WHEN salary * bonus_pct / 100 >= 8000 THEN 'Top Bonus'
           WHEN salary * bonus_pct / 100 >= 4000 THEN 'Standard Bonus'
           ELSE 'Entry Bonus'
       END AS bonus_band
FROM employees;

-- PRACTICE: Add a "Retirement Track" column that shows 'Eligible Soon' for
-- employees who will complete 25 years of service within the next 5 years,
-- and 'Not Yet' otherwise.


-- =============================================================================
-- SECTION 11 : FUNCTIONS COMBINED WITH PREVIOUS SQL CONCEPTS
-- =============================================================================
-- This is where Day 10 becomes interview-ready: functions rarely appear
-- alone in real queries — they show up inside WHERE, GROUP BY, HAVING,
-- ORDER BY, JOIN and subqueries you already know from Days 1-9.

-- Function inside WHERE
SELECT first_name, hire_date FROM employees WHERE YEAR(hire_date) = 2020;

-- Function inside GROUP BY (monthly hiring pattern)
SELECT YEAR(hire_date) AS yr, MONTH(hire_date) AS mn, COUNT(*) AS hires
FROM employees
GROUP BY YEAR(hire_date), MONTH(hire_date)
ORDER BY yr, mn;

-- Function inside ORDER BY
SELECT first_name, salary FROM employees ORDER BY ROUND(salary, 0) DESC;

-- Function inside WHERE with LIKE
SELECT first_name, last_name FROM employees WHERE LOWER(last_name) LIKE '%a%';

-- Function inside HAVING
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(ROUND(salary, 2)) > 55000;

-- JOIN + string function (departments + employees together)
SELECT e.first_name, e.department, UPPER(d.location) AS office_location_upper
FROM employees e
JOIN departments d ON e.department = d.dept_name;

-- Subquery + numeric function (Day 9 callback)
SELECT first_name, salary
FROM employees
WHERE salary > (SELECT ROUND(AVG(salary), 2) FROM employees);

-- Date function + filtering (employees hired in the second half of the year)
SELECT first_name, hire_date FROM employees WHERE MONTH(hire_date) >= 7;

-- PRACTICE: Using GROUP BY and a date function, show how many employees
-- were hired in each QUARTER (across all years combined).


-- =============================================================================
-- SECTION 12 : GUIDED BUSINESS PROBLEMS (Worked Examples)
-- =============================================================================
-- These 10 problems are SOLVED here, worked through step by step, before you
-- move on to the unsolved Independent Practice and Mixed Business Problems
-- in Section 13.

-- G1. Build a clean, presentable full name for every employee (some names
--     may have stray spaces).
SELECT CONCAT(TRIM(first_name), ' ', last_name) AS clean_full_name
FROM employees;

-- G2. Create an employee display label: "LASTNAME, Firstname (Department)"
SELECT CONCAT(UPPER(last_name), ', ', TRIM(first_name), ' (', department, ')') AS display_label
FROM employees;

-- G3. Extract every employee's email username and domain into separate columns.
SELECT email,
       SUBSTRING_INDEX(email, '@', 1)  AS username,
       SUBSTRING_INDEX(email, '@', -1) AS domain
FROM employees;

-- G4. Generate a fixed-width employee code like "EMP-0001".
SELECT emp_id, CONCAT('EMP-', LPAD(emp_id, 4, '0')) AS employee_code
FROM employees;

-- G5. Calculate each employee's monthly salary and bonus amount, both
--     rounded to 2 decimal places.
SELECT first_name,
       ROUND(salary / 12, 2)               AS monthly_salary,
       ROUND(salary * bonus_pct / 100, 2)  AS bonus_amount
FROM employees;

-- G6. Categorize every employee into a salary band (High / Medium / Low).
SELECT first_name, salary,
       CASE WHEN salary >= 80000 THEN 'High'
            WHEN salary >= 60000 THEN 'Medium'
            ELSE 'Low' END AS salary_band
FROM employees;

-- G7. Calculate each employee's current age and completed years of service.
SELECT first_name,
       TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS current_age,
       TIMESTAMPDIFF(YEAR, hire_date, CURDATE())  AS years_of_service
FROM employees;

-- G8. Identify employees who are due for their 5-year work anniversary
--     within the next 12 months.
SELECT first_name, hire_date,
       DATE_ADD(hire_date, INTERVAL 5 YEAR) AS five_year_anniversary_date
FROM employees
WHERE DATE_ADD(hire_date, INTERVAL 5 YEAR) BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 12 MONTH);

-- G9. List employees who have never logged in, clearly labeled.
SELECT first_name, IFNULL(last_login, 'NEVER LOGGED IN') AS last_login_status
FROM employees
WHERE last_login IS NULL;

-- G10. Build a one-line management summary combining name, department,
--      formatted hire date, and rounded salary.
SELECT CONCAT(TRIM(first_name), ' ', last_name, ' joined ', department, ' on ',
              DATE_FORMAT(hire_date, '%d %b %Y'), ' at a salary of ~',
              ROUND(salary, 0)) AS management_summary
FROM employees;


-- =============================================================================
-- SECTION 13 : INDEPENDENT PRACTICE (Unsolved)
-- =============================================================================
-- No solutions below. Choose the appropriate function(s)/concepts yourself.

-- -----------------------------------------------------------------------------
-- LEVEL 2 : INDEPENDENT PRACTICE — 15 questions
-- -----------------------------------------------------------------------------
/*
 1. Display every employee's email in lowercase, with any stray spaces removed.
 2. Show the first 4 characters of every employee's last_name.
 3. Find the character length of every department name.
 4. Concatenate first_name and department into one column, separated by " - ".
 5. Replace every occurrence of "company.com" in the email column with "hrms.company.com".
 6. Display each employee's initials (first letter of first_name + first letter of last_name).
 7. Find all employees whose email username contains a period (".").
 8. Display each employee's salary rounded to the nearest 500.
 9. Show the absolute difference between each employee's bonus_pct and 10.
10. List employees whose emp_id, when divided by 4, leaves no remainder.
11. Display each employee's hire_date formatted as "15-Mar-2019" style.
12. Calculate how many days remain until each employee's next work anniversary.
13. Show the weekday name on which each employee was born.
14. Display each employee's last_login time in 12-hour format with AM/PM.
15. For every employee, show the LAST day of the month they were hired in.
*/

-- -----------------------------------------------------------------------------
-- LEVEL 3 : MIXED BUSINESS PROBLEMS — 15 questions
-- -----------------------------------------------------------------------------
-- These intentionally mix String + Numeric + Date/Time with concepts from
-- earlier days (WHERE, GROUP BY, HAVING, ORDER BY, JOIN, Subquery, CASE,
-- LIKE, BETWEEN, IN, IS NULL) — exactly like the Day 13 Mixed Business
-- Problem Statements you have already practiced with. Identify the
-- required concepts yourself; they are not named for you.
/*
 1. Prepare a report showing employee name, department, and completed years
    of service, ordered from most to least senior.
 2. Find departments where the average salary exceeds the company-wide
    average salary.
 3. Display employees hired in the same month as Amit Sharma (any year).
 4. Find the department with the highest total bonus payout.
 5. List employees whose full name (first + last) is longer than 14
    characters, along with that length.
 6. Identify employees whose last name ends in the letter 'r'.
 7. Show each department's location alongside its employee count and average
    tenure in years.
 8. Find employees who joined in the same quarter as the company's most
    recently hired employee.
 9. Display, for each employee, how their salary compares to their own
    department's average (above / below / equal) using a computed
    difference.
10. Find the two most recently hired employees in each department.
11. Show employees whose bonus amount (salary * bonus_pct / 100) is above
    the company-wide average bonus amount.
12. List employees who have NOT logged in within the last 30 days
    (including those who have never logged in at all).
13. Prepare a management-ready label for every employee that combines their
    display name, department location, and formatted hire date into one
    column.
14. Find the employee with the longest tenure in each department.
15. Display departments where every employee earns above ₹50,000 (hint:
    think about how NOT EXISTS / a subquery could help here).
*/


-- =============================================================================
-- SECTION 14 : INTERVIEW CHALLENGE (Unsolved — 25 Questions)
-- =============================================================================
-- No answers provided below. INTERVIEW TRAP callouts flag the questions
-- where candidates most commonly go wrong.

-- -----------------------------------------------------------------------------
-- CONCEPTUAL
-- -----------------------------------------------------------------------------
/*
 1. What is a scalar function? How is it different from an aggregate function?
 2. LENGTH() vs CHAR_LENGTH() — what exactly is the difference, and when
    would they return different results?
    [INTERVIEW TRAP: candidates often say "they're the same" without
    knowing about multi-byte characters.]
 3. CONCAT() vs CONCAT_WS() — what happens differently when a NULL value is
    involved?
 4. SUBSTRING() vs LEFT()/RIGHT() — when would you deliberately choose one
    over the other?
 5. LOCATE() vs INSTR() — what is the one detail that trips people up?
    [INTERVIEW TRAP: argument order.]
 6. ROUND() vs TRUNCATE() — give a concrete example where they return
    different results.
 7. CEIL() vs FLOOR() — for a negative number like -15.4, what does each
    return? (Think carefully — it is not as obvious as the positive case.)
 8. MAX(column) vs GREATEST(value1, value2, ...) — explain the fundamental
    difference in what each one operates on.
    [INTERVIEW TRAP: this is one of the most common numeric-function mixups.]
 9. DATEDIFF() vs TIMESTAMPDIFF() — why is TIMESTAMPDIFF(YEAR, ...)
    preferred over dividing DATEDIFF's result by 365 when calculating age?
10. CURDATE() vs NOW() — what is the difference, and when would you use each?
11. DATE_FORMAT() vs STR_TO_DATE() — how are they exact opposites of each
    other?
12. IFNULL() vs COALESCE() — what can COALESCE() do that IFNULL() cannot?
13. Explain the difference between NULL, 0, and '' (empty string). Why is
    treating NULL as 0 a mistake?
    [INTERVIEW TRAP: this misunderstanding silently produces wrong totals.]
14. What is the difference between a DATE column and a DATETIME column?
15. What does LAST_DAY() return, and name one practical business use for it.
16. How does EXTRACT() differ in syntax from calling YEAR()/MONTH()/
    QUARTER() individually? Do they produce different results?
17. Why can wrapping an indexed column in a function inside a WHERE clause
    sometimes prevent that index from being used efficiently?
*/

-- -----------------------------------------------------------------------------
-- QUERY-WRITING
-- -----------------------------------------------------------------------------
/*
18. Write a query to find each employee's current age using birth_date.
19. Write a query to find each employee's completed years of service.
20. Write a query to extract just the domain portion of every employee's email.
21. Write a query that formats every hire_date as "Friday, 15 March 2019" style.
22. Write a query that categorizes every employee into a salary band using CASE.
23. Write a query to find employees who have never logged in.
24. Write a query to find employees hired in Quarter 4 of any year.
25. Write a query to find employees who have completed more than 7 years of
    service, ordered by tenure descending.
*/


-- =============================================================================
-- SECTION 15 : COMMON MISTAKES / INTERVIEW TRAPS
-- =============================================================================
/*
MISTAKE 1 — Using an aggregate function where a scalar function was needed
(or vice-versa):
  WRONG mental model: "MAX() will give me the bigger of these two columns
  per row." MAX() only works across ROWS in a GROUP, not across COLUMNS in
  one row — use GREATEST() for that instead.

MISTAKE 2 — Confusing LENGTH() and CHAR_LENGTH():
  Assuming they always return the same number. They only agree for pure
  ASCII text; multi-byte characters make LENGTH() (bytes) exceed
  CHAR_LENGTH() (characters).

MISTAKE 3 — Confusing ROUND() and TRUNCATE():
  Assuming TRUNCATE() rounds. It does not — it always cuts the extra
  digits off, even when the next digit would normally round up.

MISTAKE 4 — Confusing CEIL() and FLOOR():
  Assuming CEIL() always makes a number "bigger in magnitude." For a
  negative number, CEIL() actually moves it TOWARD zero (CEIL(-15.4) = -15),
  while FLOOR() moves it AWAY from zero (FLOOR(-15.4) = -16).

MISTAKE 5 — Treating NULL as 0 or as an empty string:
  Writing WHERE last_login = 0 or assuming an arithmetic expression with a
  NULL operand evaluates to 0. It evaluates to NULL, not 0.

MISTAKE 6 — Using "= NULL" instead of "IS NULL":
  WHERE last_login = NULL never matches any row, even rows that ARE NULL,
  because NULL is never "equal" to anything under standard SQL comparison
  rules. Always use IS NULL / IS NOT NULL.

MISTAKE 7 — Incorrect DATE_FORMAT() specifiers:
  Confusing %m (numeric month, 01-12) with %M (full month name), or %y
  (2-digit year) with %Y (4-digit year) — these are case-sensitive and
  produce very different output.

MISTAKE 8 — Confusing DATEDIFF() and TIMESTAMPDIFF():
  Assuming DATEDIFF() can return a difference "in years" or "in months" —
  it cannot. DATEDIFF() only ever returns whole DAYS. Use TIMESTAMPDIFF()
  when you need a different unit.

MISTAKE 9 — Mixing DATE and DATETIME incorrectly:
  Comparing a DATE column directly against a DATETIME literal that includes
  a time portion (e.g. WHERE hire_date = '2019-03-15 09:00:00') and being
  surprised when it never matches — a plain DATE column has no time
  component to compare against.

MISTAKE 10 — Forgetting that DATE_FORMAT() returns TEXT, not a DATE:
  Trying to do date arithmetic (DATE_ADD, DATEDIFF) on the OUTPUT of
  DATE_FORMAT(). Once formatted, the value is a display string — do all
  arithmetic BEFORE formatting, not after.

MISTAKE 11 — Reaching for a non-MySQL SPLIT() function:
  Calling SPLIT() or SPLIT_PART() in MySQL raises an error — these exist in
  other database systems (e.g. Snowflake, PostgreSQL), not in MySQL. Use
  SUBSTRING_INDEX() instead.

MISTAKE 12 — Incorrect SUBSTRING_INDEX() count sign:
  Mixing up positive vs negative count. A positive count counts delimiters
  FROM THE LEFT and returns everything BEFORE that point; a negative count
  counts FROM THE RIGHT and returns everything AFTER that point.

MISTAKE 13 — Incorrect use of functions inside WHERE/GROUP BY:
  Trying to reference a column ALIAS created in SELECT (e.g. "AS
  bonus_amount") inside the SAME query's WHERE clause. WHERE runs before
  SELECT's aliases exist — repeat the full expression in WHERE, or move the
  condition into HAVING after the alias has been computed via GROUP BY.

MISTAKE 14 — Applying a function to a column in WHERE without considering
performance:
  WHERE UPPER(last_name) = 'SHARMA' works correctly, but on very large,
  heavily-indexed tables it can prevent efficient index usage on
  last_name because MySQL must evaluate the function on every row first.
  Awareness point only — not a reason to avoid functions in WHERE for a
  training-sized table.
*/


-- =============================================================================
-- SECTION 16 : FINAL RECAP
-- =============================================================================
/*
DAY 10 RECAP:
  - SQL functions come in two families: SCALAR (one row in, one result per
    row) and AGGREGATE (many rows in, one result total) — you already knew
    aggregate functions from Day 3; Day 10 added the scalar family.
  - STRING functions clean, transform and extract text: UPPER/LOWER,
    CONCAT/CONCAT_WS, LENGTH/CHAR_LENGTH, TRIM/LTRIM/RTRIM,
    SUBSTRING/SUBSTR/LEFT/RIGHT, LOCATE/INSTR, REPLACE, SUBSTRING_INDEX,
    LPAD/RPAD, REVERSE, REPEAT/ASCII/CHAR.
  - NUMERIC functions calculate and format numbers: ROUND/TRUNCATE,
    CEIL/CEILING/FLOOR, ABS, MOD, POWER/SQRT, SIGN, GREATEST/LEAST (plus
    RAND/LOG/LOG10/EXP/PI as awareness).
  - DATE/TIME functions extract, calculate and format dates: the
    CURDATE/NOW family, part-extraction (YEAR/MONTH/DAYNAME/QUARTER/...),
    arithmetic (DATE_ADD/DATE_SUB), difference (DATEDIFF/TIMEDIFF/
    TIMESTAMPDIFF), formatting (DATE_FORMAT/TIME_FORMAT), conversion
    (STR_TO_DATE/CAST), and utilities (LAST_DAY/EXTRACT), plus UTC as
    awareness.
  - NULL is neither 0 nor '' — IS NULL/IS NOT NULL, IFNULL(), COALESCE()
    and NULLIF() handle it correctly.
  - CASE turns a calculated value into a business-meaningful category.
  - None of this is useful in isolation — Section 11 showed functions
    combined with WHERE, GROUP BY, HAVING, ORDER BY, JOIN and Subquery,
    which is exactly how they appear in real interview and business SQL.

WHAT'S NEXT — DAY 11 : VIEWS
Every query you wrote today has to be retyped from scratch the next time
someone needs it. Day 11 introduces the VIEW — a way to save a query
(including everything you learned today: functions, CASE, joins) under a
reusable name, so a report like "employee_summary" or "active_employees"
becomes a single, simple SELECT away.
*/

-- ====================== END OF FILE ==========================
