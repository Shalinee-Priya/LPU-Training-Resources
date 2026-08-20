-- =============================================================================
-- SQL DAY 11 : VIEWS
-- Author        : Shalinee Priya
-- Prerequisite  : Day 8 (JOINs), Day 9 (Subqueries), Day 10 (String / Numeric /
--                  Date-Time Functions). This module assumes SELECT, WHERE,
--                  ORDER BY, aggregate functions, GROUP BY, HAVING, JOINs,
--                  subqueries, string/numeric/date functions and CASE are
--                  already known. None of those are re-taught here — they are
--                  the building blocks that VIEWS wrap up into reusable
--                  business objects.
-- Environment   : MySQL 8+ / MySQL Workbench. Every statement in this script
--                  has been executed end-to-end against a live MySQL-family
--                  server against the dataset in 03_SQL_Day11_Dataset.sql to
--                  confirm it runs and to confirm the behaviour described in
--                  comments (including the two statements that are SUPPOSED
--                  to fail — see Section 12 and Section 13).
-- Scope         : Views only. Indexes are a separate, later module — see the
--                  note at the end of Section 24.
--
-- HOW TO RUN THIS SCRIPT
-- 1. Run 03_SQL_Day11_Dataset.sql first (creates hr_analytics + data).
-- 2. Run this script top to bottom in MySQL Workbench.
-- 3. The two statements marked "EXPECTED TO FAIL" are commented out so the
--    script runs cleanly start to finish. Uncomment and run them ONE AT A
--    TIME to show the class the actual error MySQL raises.
-- =============================================================================


-- #############################################################################
-- SECTION 0 : SETUP AND DATASET VERIFICATION
-- #############################################################################

USE hr_analytics;

SELECT COUNT(*) AS total_employees FROM employees;
SELECT DISTINCT department FROM employees ORDER BY department;
SELECT DISTINCT city FROM employees ORDER BY city;


-- #############################################################################
-- SECTION 1 : WHAT IS A VIEW?
-- #############################################################################

-- WHAT:
-- A VIEW is a stored SQL query, saved under a name in the database, that
-- behaves like a virtual table whenever it is queried.
--
--     Base Table(s)
--          |
--     Stored SELECT Query   <-- this is what CREATE VIEW actually saves
--          |
--        VIEW                <-- a named object you can SELECT FROM
--          |
--    SELECT * FROM view_name
--
-- WHY:
-- Instead of retyping a long, correct query every time (and risking typos
-- or logic drift), you save it once as a view and reuse it by name.
--
-- IMPORTANT — do not oversimplify this to "a view stores no data":
-- A normal MySQL view stores the QUERY DEFINITION, not a frozen copy of the
-- result. Every time you SELECT from a view, MySQL runs the underlying
-- query again (or merges it into your query) and returns a fresh result
-- from the CURRENT data in the base table(s). This is why updating the
-- base table immediately changes what the view shows the next time it is
-- queried — there is nothing "stale" to refresh.

-- EXAMPLE: the simplest possible view.
DROP VIEW IF EXISTS demo_all_employees;
CREATE VIEW demo_all_employees AS
SELECT * FROM employees;

-- OBSERVE: queried exactly like a table.
SELECT * FROM demo_all_employees;
DROP VIEW demo_all_employees;              -- cleanup; purposeful views are built in Section 4


-- #############################################################################
-- SECTION 2 : TABLE VS VIEW
-- #############################################################################

-- TABLE                                  | VIEW
-- ---------------------------------------|--------------------------------------
-- Stores actual data rows on disk        | Stores a SELECT query definition
-- Independent physical storage object    | Depends on its underlying table(s)
-- Data persists until explicitly changed | Result is derived fresh from base
--                                        |   tables at query time
-- DROP TABLE deletes the data            | DROP VIEW only removes the saved
--                                        |   query — base table data is untouched

-- PROOF: dropping a view never touches the underlying table's data.
SELECT COUNT(*) AS employees_before_drop FROM employees;

DROP VIEW IF EXISTS scratch_view_proof;
CREATE VIEW scratch_view_proof AS SELECT * FROM employees;
DROP VIEW scratch_view_proof;   -- the VIEW is gone...

SELECT COUNT(*) AS employees_after_view_dropped FROM employees;   -- ...the data is not.

-- IMPORTANT — a view's definition is FROZEN AT CREATION TIME:
-- A view's column list is fixed at the moment it is created. If the
-- underlying table later gains a new column, that column does NOT
-- automatically become part of an existing view's definition. Example:
--   CREATE VIEW employee_basic AS
--   SELECT emp_id, first_name, salary
--   FROM employees;
--   -- If employees later gains a new column (e.g. department), employee_basic
--   -- does NOT automatically expose it — the view still only returns
--   -- emp_id, first_name, salary until it is explicitly redefined
--   -- (CREATE OR REPLACE VIEW / ALTER VIEW, Sections 7-8).
-- The reverse is also true: if a referenced column or table is later
-- dropped or changed incompatibly, querying the view can fail. See
-- Section 10 (View Metadata / Inspection) for view dependency awareness.

-- PRACTICE:
-- Ask students: "If I DROP VIEW employee_basic later in this script, does
-- any employee record get deleted?" (Answer: no — same proof as above.)


-- #############################################################################
-- SECTION 3 : WHY VIEWS?
-- #############################################################################

-- WHY (business reasons):
-- 1. Simplicity        - hide a complex query behind a short, memorable name
-- 2. Reusability        - write the logic once, reuse it in many places
-- 3. Abstraction        - consumers of the view don't need to know the JOINs,
--                         CASE logic, or calculations underneath
-- 4. Controlled data exposure - a view can present only some columns/rows
-- 5. Consistent reporting logic - everyone who queries the view gets the
--                         same business rules (e.g. same salary_category
--                         boundaries) instead of copy-pasted, drifting SQL
-- 6. Hiding unnecessary columns
-- 7. Hiding complex SQL logic behind a simple SELECT * FROM view_name
--
-- BUSINESS EXAMPLE:
-- The employees table holds first_name, last_name, department, salary, city,
-- hire_date, email and phone. An HR dashboard needs employee name,
-- department, salary and city — but should not need to display phone or
-- email on that particular screen. A view can present exactly that subset.
--
-- IMPORTANT: a view narrowing the visible columns is a CONVENIENCE, not by
-- itself a SECURITY GUARANTEE. Anyone who also has privileges on the
-- underlying employees table can still query phone/email directly. Real
-- access control comes from GRANT/REVOKE privileges — see Section 14.

DROP VIEW IF EXISTS employee_dashboard_demo;
CREATE VIEW employee_dashboard_demo AS
SELECT CONCAT(TRIM(first_name), ' ', last_name) AS employee_name,
       department,
       salary,
       city
FROM employees;

SELECT * FROM employee_dashboard_demo;
DROP VIEW employee_dashboard_demo;   -- illustrative only; the real dashboard view is built in Section 4


-- #############################################################################
-- SECTION 4 : CREATE VIEW — COMPLETE FOUNDATION
-- #############################################################################

-- SYNTAX:
-- CREATE VIEW view_name AS
-- SELECT ...
-- FROM ...
-- [WHERE ...];

-- -----------------------------------------------------------------------------
-- 4.1  employee_basic  — simple view, selected columns
-- WHAT: exposes only the safe, everyday columns of employees.
-- WHY : this is the "safe subset" every other report starts from, and it
--       will double as our updatable-view example in Section 11.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS employee_basic;
CREATE VIEW employee_basic AS
SELECT emp_id, first_name, last_name, department, city, salary
FROM employees;

SELECT * FROM employee_basic;

-- -----------------------------------------------------------------------------
-- 4.2  employee_salary_report — aliases + a string function (Day 10 recap)
-- WHAT: combines first_name/last_name into one readable full_name column.
-- WHY : reporting tools almost always want "one name column", not two.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS employee_salary_report;
CREATE VIEW employee_salary_report AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       salary
FROM employees;

SELECT * FROM employee_salary_report ORDER BY salary DESC;

-- -----------------------------------------------------------------------------
-- 4.3  high_salary_employees — filtered view
-- BUSINESS CASE: Finance wants a standing list of high earners without
-- re-writing "WHERE salary > 70000" every time.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS high_salary_employees;
CREATE VIEW high_salary_employees AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       city,
       salary
FROM employees
WHERE salary > 70000;

SELECT * FROM high_salary_employees;

-- -----------------------------------------------------------------------------
-- 4.4  recent_hires — filtered view, ORDER BY awareness
-- NOTE: the cut-off is a fixed literal date, not CURDATE(), so this result
-- stays the same every time the script is run (contrast with Section 6C,
-- the one view in this module whose result DOES change with the run date).
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS recent_hires;
CREATE VIEW recent_hires AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       hire_date
FROM employees
WHERE hire_date > '2020-01-01';

-- OBSERVE: a view does not guarantee a final row order. Apply ORDER BY in
-- the query that reads the view when a specific result order is required.
-- MySQL permits ORDER BY inside a view definition, but an outer ORDER BY
-- can override it.
SELECT * FROM recent_hires ORDER BY hire_date;

-- -----------------------------------------------------------------------------
-- 4.5  employee_contact_summary — reusable internal-directory view
-- WHY : contrast this with employee_public_info in Section 14, which hides
-- email entirely — same base table, two different exposure levels.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS employee_contact_summary;
CREATE VIEW employee_contact_summary AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       email
FROM employees;

SELECT * FROM employee_contact_summary;

-- PRACTICE:
-- Create a view "employee_hr_view" showing emp_id, full name, department
-- and city only (no salary, no email, no phone).


-- #############################################################################
-- SECTION 5 : QUERYING A VIEW
-- #############################################################################

-- WHAT: once created, a view is queried exactly like a table — including
-- WHERE, ORDER BY, GROUP BY and HAVING layered on top of it.
-- WHY : this is the whole point of a view — it becomes a reusable query
-- layer that other queries build on.

SELECT * FROM high_salary_employees WHERE department = 'IT';
SELECT * FROM employee_salary_report ORDER BY salary DESC;
SELECT department, COUNT(*) AS employees_in_dept
FROM employee_basic
GROUP BY department
HAVING COUNT(*) >= 2;

-- PRACTICE:
-- Using employee_salary_report, write a query that returns only the
-- Marketing department, ordered by salary descending.


-- #############################################################################
-- SECTION 6 : VIEWS + EXISTING SQL CONCEPTS
-- #############################################################################

-- WHY THIS SECTION MATTERS:
-- Day 8-10 taught JOINs, subqueries and functions as one-off queries. A
-- VIEW is what turns each of those one-off queries into a permanent,
-- reusable business object.
--
--   Previous SQL concept  ->  Complex query  ->  VIEW  ->  Reusable object

-- -----------------------------------------------------------------------------
-- 6A. NUMERIC FUNCTIONS — annual_salary_view
-- WHAT: calculated column (salary * 12) plus ROUND().
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS annual_salary_view;
CREATE VIEW annual_salary_view AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       salary AS monthly_salary,
       ROUND(salary * 12, 2) AS annual_salary
FROM employees;

SELECT * FROM annual_salary_view ORDER BY annual_salary DESC;

-- -----------------------------------------------------------------------------
-- 6B. CASE — employee_report
-- WHAT: string function (full_name) + CASE (salary_category) in one view.
-- BUSINESS CASE: management wants every employee tagged High/Medium/Low
-- without re-deriving the logic in every report.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS employee_report;
CREATE VIEW employee_report AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       city,
       salary,
       CASE
           WHEN salary >= 70000 THEN 'High'
           WHEN salary >= 50000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employees;

SELECT * FROM employee_report ORDER BY salary DESC;
SELECT salary_category, COUNT(*) AS employee_count
FROM employee_report
GROUP BY salary_category;

-- -----------------------------------------------------------------------------
-- 6C. DATE FUNCTIONS — employee_tenure_view
-- WHAT: years of service using TIMESTAMPDIFF.
-- IMPORTANT: this view's result CHANGES depending on the date it is run,
-- because it compares hire_date to CURDATE(). Do not treat the
-- years_of_service values as fixed — recompute them on the day you teach.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS employee_tenure_view;
CREATE VIEW employee_tenure_view AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       hire_date,
       TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS years_of_service
FROM employees;

SELECT * FROM employee_tenure_view ORDER BY years_of_service DESC;

-- -----------------------------------------------------------------------------
-- 6D. AGGREGATE FUNCTIONS + GROUP BY — department_salary_summary
-- WHAT: COUNT, AVG, MAX, MIN per department.
-- This is also our main example of a NON-updatable view (Section 12).
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS department_salary_summary;
CREATE VIEW department_salary_summary AS
SELECT department,
       COUNT(*) AS total_employees,
       ROUND(AVG(salary), 2) AS avg_salary,
       MAX(salary) AS max_salary,
       MIN(salary) AS min_salary
FROM employees
GROUP BY department;

SELECT * FROM department_salary_summary ORDER BY avg_salary DESC;

-- -----------------------------------------------------------------------------
-- 6E. HAVING — high_paying_departments
-- WHAT: only departments whose average salary clears a threshold.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS high_paying_departments;
CREATE VIEW high_paying_departments AS
SELECT department,
       ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 55000;

SELECT * FROM high_paying_departments ORDER BY avg_salary DESC;

-- -----------------------------------------------------------------------------
-- 6F. JOIN — employee_department_view
-- WHAT: employees joined to departments for dept_head and location.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS employee_department_view;
CREATE VIEW employee_department_view AS
SELECT e.emp_id,
       CONCAT(TRIM(e.first_name), ' ', e.last_name) AS full_name,
       e.department,
       d.dept_head,
       d.location,
       e.salary
FROM employees e
JOIN departments d ON e.department = d.dept_name;

SELECT * FROM employee_department_view ORDER BY department;

-- -----------------------------------------------------------------------------
-- 6G. SUBQUERY (Day 9 recap) — above_average_salary
-- WHAT: employees earning more than the company-wide average.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS above_average_salary;
CREATE VIEW above_average_salary AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

SELECT * FROM above_average_salary ORDER BY salary DESC;

-- PRACTICE:
-- Create a view "below_average_salary" using the mirror-image subquery
-- (salary < the same company-wide average).


-- #############################################################################
-- SECTION 7 : CREATE OR REPLACE VIEW
-- #############################################################################

-- WHAT: redefines an existing view's query in one statement, without a
-- separate DROP first.
-- WHY : business requirements change — a report that used to show 3
-- columns now needs a 4th. CREATE OR REPLACE VIEW updates the definition
-- in place; every place that already references the view name keeps
-- working, now against the new definition.
--
-- SYNTAX:
-- CREATE OR REPLACE VIEW view_name AS
-- SELECT ...;

-- Version 1: basic fields only.
DROP VIEW IF EXISTS employee_summary;
CREATE VIEW employee_summary AS
SELECT first_name, last_name, salary
FROM employees;

SELECT * FROM employee_summary LIMIT 3;

-- Requirement changes: management also wants the department shown.
CREATE OR REPLACE VIEW employee_summary AS
SELECT first_name, last_name, department, salary
FROM employees;

-- OBSERVE: same view name, new column set, no error.
SELECT * FROM employee_summary LIMIT 3;

-- PRACTICE:
-- Replace employee_summary again so it also shows city. Confirm the change
-- with SELECT * FROM employee_summary LIMIT 3;


-- #############################################################################
-- SECTION 8 : ALTER VIEW
-- #############################################################################

-- WHAT: ALTER VIEW changes the definition of an existing view (the view
-- must already exist — unlike CREATE OR REPLACE VIEW, it will not create
-- one that doesn't exist).
--
-- SYNTAX:
-- ALTER VIEW view_name AS
-- SELECT ...;

ALTER VIEW employee_summary AS
SELECT first_name, last_name, department, city, salary
FROM employees;

SELECT * FROM employee_summary LIMIT 3;
SHOW CREATE VIEW employee_summary;

-- INTERVIEW-IMPORTANT COMPARISON:
-- CREATE VIEW            -> fails with an error if the view already exists
-- CREATE OR REPLACE VIEW -> creates it if missing, replaces it if present
-- ALTER VIEW              -> only works if the view already exists;
--                            functionally changes the definition much like
--                            CREATE OR REPLACE VIEW does
-- DROP VIEW                -> removes the view object entirely


-- #############################################################################
-- SECTION 9 : DROP VIEW
-- #############################################################################

-- WHAT: removes a view definition. The base table and its data are
-- completely unaffected (already proven in Section 2).
--
-- SYNTAX:
-- DROP VIEW view_name;
-- DROP VIEW IF EXISTS view_name;   -- safe in rerunnable scripts

CREATE VIEW temp_drop_demo_view AS
SELECT emp_id, first_name FROM employees;

SELECT * FROM temp_drop_demo_view LIMIT 2;

DROP VIEW temp_drop_demo_view;

-- WHY "IF EXISTS": running DROP VIEW temp_drop_demo_view a second time
-- (e.g. by re-running this script) would raise an "Unknown view" error.
-- Using IF EXISTS makes the statement safe to repeat.
DROP VIEW IF EXISTS temp_drop_demo_view;   -- no error even though it's already gone


-- #############################################################################
-- SECTION 10 : VIEW METADATA / INSPECTION
-- #############################################################################

-- WHAT: MySQL exposes view metadata through SHOW commands and
-- INFORMATION_SCHEMA.VIEWS.

-- List every view in the current database:
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- See the exact stored definition of one view:
SHOW CREATE VIEW employee_basic;

-- See the column structure of a view, same as for a table:
DESC employee_basic;

-- INFORMATION_SCHEMA.VIEWS — interview/awareness level detail:
SELECT TABLE_SCHEMA,
       TABLE_NAME,
       CHECK_OPTION,
       IS_UPDATABLE,
       SECURITY_TYPE
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'hr_analytics'
ORDER BY TABLE_NAME;

-- VIEW DEPENDENCY / MAINTENANCE (awareness):
-- A view depends on the exact tables/columns referenced in its SELECT. If
-- a referenced column or table is later renamed, altered incompatibly, or
-- dropped, the view can become invalid and fail when queried — even though
-- the view definition itself was never directly touched. This is why view
-- definitions need to be reviewed whenever the underlying schema changes,
-- especially once views are stacked on other views (see Section 19).
-- CHECK TABLE gives a basic status check and can flag such problems:
CHECK TABLE employee_basic;

-- PRACTICE:
-- Run SHOW CREATE VIEW on employee_report and identify the CASE expression
-- MySQL stored internally.


-- #############################################################################
-- SECTION 11 : UPDATABLE VIEWS
-- #############################################################################

-- WHAT: some views can be the target of UPDATE/DELETE, and the change is
-- applied to the underlying base table.
-- IMPORTANT: NOT every view is updatable — only certain view definitions
-- qualify (see Section 12). Do not teach "all views can be updated."

-- employee_basic (Section 4.1) is a simple, single-table, row-preserving
-- view, so it qualifies as updatable.
SELECT emp_id, salary FROM employee_basic WHERE emp_id = 1;

UPDATE employee_basic SET salary = 57000.00 WHERE emp_id = 1;

-- OBSERVE: the BASE TABLE changed, proving the view is just a window onto it.
SELECT emp_id, salary FROM employees WHERE emp_id = 1;

-- Reset back to the original value so the rest of this teaching script (and
-- the figures used in the accompanying slides) stay consistent.
UPDATE employee_basic SET salary = 55000.76 WHERE emp_id = 1;
SELECT emp_id, salary FROM employees WHERE emp_id = 1;

-- PRACTICE:
-- Using employee_basic, update Vikram Singh's (emp_id 7) city to 'Gurugram'
-- and confirm the change is visible in the employees table. Then reset it
-- back to 'Delhi'.


-- #############################################################################
-- SECTION 12 : NON-UPDATABLE VIEWS
-- #############################################################################

-- WHAT: a view generally becomes non-updatable once MySQL can no longer map
-- each view row back to exactly one base-table row. Common constructs that
-- cause this include:
--   - Aggregate functions (COUNT, AVG, SUM, MAX, MIN)
--   - GROUP BY
--   - HAVING
--   - DISTINCT
--   - UNION / UNION ALL
--   - Certain subqueries in the SELECT list
--   - Certain joins (see the important note below)
--   - Other constructs that break the one-to-one row relationship
--
-- department_salary_summary (Section 6D) is an aggregate + GROUP BY view —
-- a reporting/summary view, not a row-level view — so it is NOT updatable:

-- EXPECTED TO FAIL — uncomment to demonstrate the exact MySQL error:
-- UPDATE department_salary_summary SET avg_salary = 99999 WHERE department = 'IT';
-- Actual error observed when this statement is run:
--   ERROR 1288 (HY000): The target table department_salary_summary of the
--   UPDATE is not updatable

-- Confirm it programmatically instead, via IS_UPDATABLE:
SELECT TABLE_NAME, IS_UPDATABLE
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'hr_analytics'
  AND TABLE_NAME IN ('department_salary_summary', 'high_paying_departments', 'employee_basic', 'employee_department_view');

-- IMPORTANT NOTE ON JOINS:
-- employee_department_view (Section 6F) IS a JOIN, yet IS_UPDATABLE shows
-- YES above — because each employees row still maps to exactly one row in
-- the joined result (a plain employee-to-department lookup). Do NOT teach
-- "every JOIN view is non-updatable" — updatability depends on the SPECIFIC
-- view definition, not on the mere presence of a JOIN keyword.

-- INSERTABLE VS UPDATABLE (brief awareness):
-- Updatable and insertable are related but NOT identical. A view can allow
-- UPDATE/DELETE (because rows map one-to-one back to the base table) while
-- still not being a valid target for INSERT — for example, if the view
-- does not expose a NOT NULL column that the base table requires a value
-- for, an INSERT through that view can fail even though UPDATE succeeds.
-- Core idea to remember for interviews:
--   UPDATE/DELETE capability   -- about modifying existing mapped rows
--   INSERT capability           -- about the view supplying every value the
--                                   base table requires for a brand-new row
-- This module focuses on the UPDATE/DELETE side; deep insertability rules
-- are not needed at this stage.


-- #############################################################################
-- SECTION 13 : WITH CHECK OPTION
-- #############################################################################

-- WHAT: WITH CHECK OPTION on a filtered, updatable view blocks any
-- INSERT/UPDATE performed THROUGH the view that would produce a row no
-- longer matching the view's WHERE condition.
--
-- BUSINESS CASE: an IT-department-only view should not let someone use it
-- to quietly move an employee out of IT.

DROP VIEW IF EXISTS it_employees;
CREATE VIEW it_employees AS
SELECT emp_id, first_name, department, salary
FROM employees
WHERE department = 'IT'
WITH CHECK OPTION;

SELECT * FROM it_employees;

-- ALLOWED UPDATE: salary change, employee stays in IT -> still satisfies
-- the WHERE condition -> accepted.
UPDATE it_employees SET salary = 95000.00 WHERE emp_id = 5;
SELECT * FROM it_employees WHERE emp_id = 5;

-- Reset for consistency with later sections.
UPDATE it_employees SET salary = 91000.50 WHERE emp_id = 5;

-- INVALID UPDATE: moving an IT employee OUT of IT through this view would
-- make the row disappear from the view's own WHERE condition.
-- EXPECTED TO FAIL — uncomment to demonstrate:
-- UPDATE it_employees SET department = 'Finance' WHERE emp_id = 3;
-- Actual error observed when this statement is run:
--   ERROR 1369 (44000): CHECK OPTION failed `hr_analytics`.`it_employees`

-- LOCAL vs CASCADED (brief awareness only):
-- WITH CASCADED CHECK OPTION - also enforces the WHERE conditions of any
--   view THIS view was built on top of (checks cascade downward).
-- WITH LOCAL CHECK OPTION    - only enforces this view's own WHERE
--   condition, not conditions from underlying views it's stacked on.
-- If you write WITH CHECK OPTION without LOCAL or CASCADED, MySQL treats
-- it as CASCADED. Confirm this from metadata:
SELECT TABLE_NAME, CHECK_OPTION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'hr_analytics' AND TABLE_NAME = 'it_employees';

-- PRACTICE:
-- Create "sales_employees" filtered to department = 'Sales' WITH CHECK
-- OPTION. Try an allowed salary update, then try (and expect to fail) an
-- UPDATE that changes department to something other than 'Sales'.


-- #############################################################################
-- SECTION 14 : VIEW SECURITY + SQL SECURITY AWARENESS
-- #############################################################################

-- ---- 14A. VIEW SECURITY -------------------------------------------------
-- WHAT: a view can present only selected, non-sensitive columns/rows to a
-- consumer, instead of the full base table.

DROP VIEW IF EXISTS employee_public_info;
CREATE VIEW employee_public_info AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       city
FROM employees;

-- OBSERVE: salary, email and phone are simply not columns of this view.
SELECT * FROM employee_public_info;

-- IMPORTANT: this view narrows what a report SHOWS, but it is not
-- automatically a security boundary. A view only becomes an enforced
-- security control once combined with database privileges — e.g. granting
-- a role SELECT on employee_public_info while NOT granting SELECT on the
-- underlying employees table (or on its salary/email/phone columns). The
-- view existing by itself does not restrict anyone who already has direct
-- privileges on employees.

-- ---- 14B. SQL SECURITY — INTERVIEW AWARENESS -----------------------------
-- WHAT (high level, not a DBA deep-dive):
-- SQL SECURITY DEFINER (MySQL's default) - the view runs with the
--   privileges of the account that DEFINED (created) the view.
-- SQL SECURITY INVOKER - the view runs with the privileges of the account
--   currently QUERYING the view.
--
-- SYNTAX:
-- CREATE SQL SECURITY INVOKER VIEW view_name AS SELECT ...;

DROP VIEW IF EXISTS employee_public_info_invoker;
CREATE SQL SECURITY INVOKER VIEW employee_public_info_invoker AS
SELECT emp_id,
       CONCAT(TRIM(first_name), ' ', last_name) AS full_name,
       department,
       city
FROM employees;

SELECT * FROM employee_public_info_invoker LIMIT 3;
DROP VIEW employee_public_info_invoker;   -- awareness demo only

-- INTERVIEW NOTE: SECURITY_TYPE in INFORMATION_SCHEMA.VIEWS (Section 10)
-- reports which mode a view uses. If SQL SECURITY is not specified
-- explicitly, MySQL uses DEFINER.


-- #############################################################################
-- SECTION 15 : VIEW PROCESSING ALGORITHM — AWARENESS
-- #############################################################################

-- WHAT (conceptual only — not optimizer internals):
-- ALGORITHM = MERGE     - where possible, MySQL merges the view's stored
--   query into the outer query that references it.
-- ALGORITHM = TEMPTABLE  - MySQL materializes the view's result into an
--   internal temporary table first; this has updatability implications
--   (a TEMPTABLE-algorithm view is generally NOT updatable).
-- ALGORITHM = UNDEFINED  - MySQL chooses which approach to use. If ALGORITHM
--   is omitted, this is the default, and MySQL's processing choice is
--   influenced by optimizer settings.
--
-- SYNTAX:
-- CREATE ALGORITHM = MERGE VIEW view_name AS SELECT ...;

DROP VIEW IF EXISTS employee_basic_merge_demo;
CREATE ALGORITHM = MERGE VIEW employee_basic_merge_demo AS
SELECT emp_id, first_name, department, salary FROM employees;
SELECT * FROM employee_basic_merge_demo LIMIT 2;
DROP VIEW employee_basic_merge_demo;

DROP VIEW IF EXISTS employee_basic_temptable_demo;
CREATE ALGORITHM = TEMPTABLE VIEW employee_basic_temptable_demo AS
SELECT emp_id, first_name, department, salary FROM employees;
SELECT * FROM employee_basic_temptable_demo LIMIT 2;
DROP VIEW employee_basic_temptable_demo;


-- #############################################################################
-- SECTION 16 : VIEWS AND PERFORMANCE
-- #############################################################################

-- CORRECTING A COMMON MISCONCEPTION:
-- Views do NOT automatically make queries faster. A view is primarily
-- about abstraction, reuse, consistency and controlled data exposure —
-- NOT a performance feature.
--
-- Querying a view runs the underlying query (or a merged version of it)
-- against the base tables, so performance still depends on the query
-- logic, the data volume, and the indexes on the UNDERLYING TABLES.
--
-- AWARENESS: "Normal MySQL views do not have independent indexes. Query
-- performance depends on the underlying tables and their indexes." Index
-- design itself is covered in a later, dedicated module.


-- #############################################################################
-- SECTION 17 : VIEW VS SUBQUERY
-- #############################################################################

-- Day 9 taught this exact logic as a SUBQUERY:
SELECT emp_id, first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Day 11 shows the SAME logic saved as a reusable VIEW (built in Section 6G):
SELECT * FROM above_average_salary;

-- SUBQUERY                                | VIEW
-- -----------------------------------------|-------------------------------------
-- Written inline, inside one query          | A named, stored database object
-- Scoped to that single query's execution   | Persists until explicitly dropped
-- Must be rewritten each time it's needed   | Queried repeatedly by name
-- Good for one-off, throwaway logic         | Good for logic reused across many
--                                           |   reports/queries
--
-- RULE OF THUMB: if you find yourself writing the same subquery in more
-- than one place, that is usually the sign to promote it into a view.


-- #############################################################################
-- SECTION 18 : VIEW VS MATERIALIZED VIEW — INTERVIEW AWARENESS
-- #############################################################################

-- MySQL does NOT provide a native "materialized view" object the way some
-- other database systems (e.g. Oracle, PostgreSQL) do. A normal MySQL view,
-- as used throughout this module, is a stored query definition — it is
-- re-evaluated (or merged) against live data on every query, NOT a
-- permanently stored snapshot of a past result.
--
-- If a MySQL-based system needs materialized-view-like behaviour (a
-- physically stored, periodically refreshed result set), that is typically
-- built manually — e.g. a real table populated on a schedule — which is
-- outside the scope of a normal CREATE VIEW statement.


-- #############################################################################
-- SECTION 19 : BUSINESS CASE STUDY + LEVEL 3 PRACTICE
-- #############################################################################

-- By this point in the script, the following business views already exist
-- and together form the HR Analytics reporting layer for this module:
--   1. employee_basic              - safe/basic employee information
--   2. high_salary_employees        - salary > 70000
--   3. annual_salary_view           - monthly + annual salary
--   4. employee_report              - full name, department, city, salary,
--                                      salary category
--   5. department_salary_summary    - department, employee count, avg,
--                                      max salary
--   6. recent_hires                 - employees hired after 2020-01-01
--   7. above_average_salary         - employees above the overall average
--   8. it_employees                 - IT-only view with WITH CHECK OPTION

-- CASE STUDY QUERY: HR wants one combined report — full name, department,
-- salary category and years of service — for a quarterly review meeting.
-- This is exactly why employee_report and employee_tenure_view exist as
-- SEPARATE, reusable views: a third view can JOIN them together.
DROP VIEW IF EXISTS quarterly_review_report;
CREATE VIEW quarterly_review_report AS
SELECT r.emp_id,
       r.full_name,
       r.department,
       r.salary_category,
       t.years_of_service
FROM employee_report r
JOIN employee_tenure_view t ON r.emp_id = t.emp_id;

SELECT * FROM quarterly_review_report ORDER BY department;

-- OBSERVE: quarterly_review_report is a VIEW BUILT ON TWO OTHER VIEWS. This
-- is valid in MySQL and is a common interview question ("can a view be
-- created on another view?") — yes, though deeply stacked views can become
-- harder to maintain (Section 10) and may force ALGORITHM = TEMPTABLE.

-- -----------------------------------------------------------------------------
-- LEVEL 3 — BUSINESS / MIXED VIEW PROBLEMS (10 questions, UNSOLVED)
-- These describe a business need — decide the appropriate view design
-- (columns, filters, functions, updatability) yourself.
-- -----------------------------------------------------------------------------

-- L3-Q1. HR repeatedly needs a single report combining employee name,
--        department, city and salary category for the monthly leadership
--        meeting. Design the appropriate view.
-- L3-Q2. Finance wants a live list of employees whose ANNUAL salary
--        (not monthly) exceeds 900000, without recomputing it manually
--        each time.
-- L3-Q3. The IT department head wants a report of only IT employees who
--        have been with the company more than 8 years.
-- L3-Q4. Leadership wants to compare average salary across departments,
--        but only for departments with 2 or more employees, sorted from
--        highest average salary to lowest.
-- L3-Q5. The HR dashboard team wants a view exposing employee name,
--        department and city ONLY — this view must never allow a
--        column-level accident of exposing salary. Design it so the risk
--        cannot even arise, and explain why your design choice achieves
--        that.
-- L3-Q6. Payroll wants a self-service view where a payroll clerk can
--        UPDATE an employee's salary through the view, but the view must
--        reject any attempt (through the view) to reassign an employee out
--        of their current department.
-- L3-Q7. The recruitment team wants a live count of how many employees
--        were hired in each calendar year.
-- L3-Q8. Design a view that shows, for every employee, how their salary
--        compares to their OWN department's average salary (above/below/
--        equal) — think about what previously-covered concept (subquery or
--        join) this needs.
-- L3-Q9. Design a reusable view that could feed BOTH a "high performer"
--        report and a "flight-risk" report — i.e. a general-purpose salary
--        and tenure view other views could be layered on top of.
-- L3-Q10. A junior developer proposes updating department_salary_summary
--         directly to "correct" one department's avg_salary value. Explain
--         in writing why this will fail, and what they should update
--         instead.


-- #############################################################################
-- SECTION 20 : GUIDED PRACTICE — LEVEL 1 (10 questions)
-- #############################################################################
-- Trainer-led. Solutions are demonstrated live using the views/dataset
-- already built above.

-- L1-Q1. Create a view "employee_names" showing emp_id and a single
--         full_name column (first_name + last_name, trimmed and joined).
-- L1-Q2. Create a view "finance_employees" showing employees where
--         department = 'Finance'.
-- L1-Q3. Query high_salary_employees to show only rows where city = 'Mumbai'.
-- L1-Q4. Create a view "employee_email_directory" with full_name and email.
-- L1-Q5. Create a view "monthly_to_annual" showing full_name and
--         annual_salary only (reuse the logic from annual_salary_view).
-- L1-Q6. Query employee_report to list only employees in the 'Low' salary
--         category, ordered by salary ascending.
-- L1-Q7. Create a view "hr_department_view" restricted to department = 'HR'.
-- L1-Q8. Use SHOW CREATE VIEW on department_salary_summary and identify
--         which clause makes it non-updatable.
-- L1-Q9. Create a view "employee_city_view" showing full_name, department
--         and city, ordered by city when queried.
-- L1-Q10. Drop the view created in L1-Q1 using DROP VIEW IF EXISTS.


-- #############################################################################
-- SECTION 21 : INDEPENDENT PRACTICE — LEVEL 2 (10 questions, UNSOLVED)
-- #############################################################################

-- L2-Q1. Create a view "below_average_salary" for employees earning less
--         than the company-wide average salary (mirror of above_average_salary).
-- L2-Q2. Create a view "department_headcount" showing department and the
--         number of employees in it, using GROUP BY.
-- L2-Q3. Create a view "city_wise_employees" showing city and a count of
--         employees per city.
-- L2-Q4. Create a view "long_tenure_employees" showing employees with more
--         than 5 years of service (build on the TIMESTAMPDIFF logic from
--         Section 6C).
-- L2-Q5. Use CREATE OR REPLACE VIEW to modify "employee_names" (from L1-Q1)
--         so it also includes department.
-- L2-Q6. Create a view "salary_by_department_category" combining
--         department, salary_category and a COUNT of employees, using
--         employee_report as the source.
-- L2-Q7. Create a view "bonus_amount_view" showing full_name, salary,
--         bonus_pct and a calculated bonus_amount column
--         (salary * bonus_pct / 100).
-- L2-Q8. Determine (without running an UPDATE) whether
--         "salary_by_department_category" from L2-Q6 would be updatable.
--         Justify your answer, then confirm using INFORMATION_SCHEMA.VIEWS.
-- L2-Q9. Create a view "mumbai_it_employees" combining a city filter and a
--         department filter with WITH CHECK OPTION.
-- L2-Q10. ALTER the view "hr_department_view" (from L1-Q7) so it also
--         shows salary.


-- #############################################################################
-- SECTION 22 : INTERVIEW CHALLENGE (15 questions, UNSOLVED)
-- #############################################################################

-- CONCEPTUAL
-- IC-1.  What is a view, and why is it often described as a "virtual table"?
-- IC-2.  Does a normal MySQL view store data? Explain precisely what it
--        actually stores.
-- IC-3.  What is the difference between a view and a table?
-- IC-4.  What is the difference between a view and a subquery? When would
--        you choose one over the other?
-- IC-5.  Does MySQL support materialized views the way some other
--        databases do? What is the practical implication of your answer?

-- TECHNICAL
-- IC-6.  What is the difference between CREATE VIEW, CREATE OR REPLACE
--        VIEW and ALTER VIEW?
-- IC-7.  Why should DROP VIEW IF EXISTS be preferred over DROP VIEW in a
--        script meant to be run repeatedly?
-- IC-8.  Which INFORMATION_SCHEMA.VIEWS column tells you whether a view is
--        updatable? Which one tells you its CHECK OPTION setting?
-- IC-9.  What is the difference between SHOW CREATE VIEW and DESC on a view?

-- ADVANCED
-- IC-10. What generally makes a view non-updatable? Name at least four
--        constructs.
-- IC-11. Why is a view built with GROUP BY and aggregate functions
--        typically not updatable?
-- IC-12. What does WITH CHECK OPTION actually prevent? Give a concrete
--        example using department-filtered data.
-- IC-13. What is the difference between WITH LOCAL CHECK OPTION and WITH
--        CASCADED CHECK OPTION?
-- IC-14. Explain SQL SECURITY DEFINER vs SQL SECURITY INVOKER in your own
--        words.

-- SCENARIO
-- IC-15. Your manager says "just create a view — it'll make the report run
--        faster." Is this statement accurate? How would you respond, and
--        under what circumstances (if any) might a view indirectly help
--        performance?


-- #############################################################################
-- SECTION 23 : COMMON MISTAKES / INTERVIEW TRAPS
-- #############################################################################

-- COMMON MISTAKES:
--  1. Thinking a view is a physical table with its own storage.
--  2. Thinking a view stores a permanent, frozen copy of a past query result.
--  3. Assuming every view is automatically updatable.
--  4. Assuming every JOIN-based view is automatically non-updatable.
--  5. Attempting to UPDATE a non-updatable (aggregate/GROUP BY/DISTINCT)
--     view and being surprised by the error.
--  6. Forgetting WITH CHECK OPTION on a filtered view meant to be updated,
--     then being surprised rows can "leave" the filter silently.
--  7. Assuming views automatically make queries faster.
--  8. Assuming creating a view automatically makes data secure, without
--     configuring privileges.
--  9. Confusing CREATE OR REPLACE VIEW with just running a SELECT.
-- 10. Forgetting DROP VIEW IF EXISTS in rerunnable scripts, causing
--     "already exists" errors.
-- 11. Never inspecting a view's actual stored definition (SHOW CREATE VIEW)
--     before relying on it.
-- 12. Building overly complex, deeply-stacked views without a genuine
--     business need, making maintenance harder (Section 10).
-- 13. Treating views as a substitute for proper schema/database design.
-- 14. Assuming a normal MySQL view has its own indexes.

-- INTERVIEW TRAPS:
-- TRAP 1: "All views are updatable."                         -> FALSE.
-- TRAP 2: "A view stores a copy of the query result."         -> FALSE for
--          a normal MySQL view — it stores the query definition.
-- TRAP 3: "Views always improve performance."                 -> FALSE.
-- TRAP 4: "Creating a view automatically makes data secure."  -> FALSE;
--          privileges determine actual access control.
-- TRAP 5: "Every JOIN view is non-updatable."                 -> Oversimplified/
--          FALSE — updatability depends on the specific view definition
--          (see employee_department_view in Section 12).
-- TRAP 6: "A view has its own indexes."                        -> FALSE for
--          normal MySQL views.
-- TRAP 7: "CREATE OR REPLACE VIEW and ALTER VIEW are exactly the same."
--          -> Related but distinct: CREATE OR REPLACE VIEW works whether
--          or not the view already exists; ALTER VIEW requires it to
--          already exist. Both end up changing the stored definition.


-- #############################################################################
-- SECTION 24 : FINAL RECAP
-- #############################################################################

-- Today you learned to:
--  - Explain what a view actually stores and how it differs from a table
--  - Build views using every SQL concept from Day 8-10 (JOIN, subquery,
--    string/numeric/date functions, CASE, aggregates, GROUP BY, HAVING)
--  - CREATE, CREATE OR REPLACE, ALTER and DROP views safely and rerunnably
--  - Inspect views via SHOW CREATE VIEW, SHOW FULL TABLES and
--    INFORMATION_SCHEMA.VIEWS
--  - Distinguish updatable vs non-updatable views, and explain WHY
--  - Use WITH CHECK OPTION to protect a filtered, updatable view
--  - Describe view security, SQL SECURITY DEFINER/INVOKER, and the MERGE /
--    TEMPTABLE / UNDEFINED processing algorithms at an awareness level
--  - Compare views against subqueries, tables, and materialized views
--  - Avoid the classic interview traps around views
--
-- Day 10 -> Day 11 thread, made explicit:
--   Day 10: built a complex employee reporting query using string,
--           numeric, date and CASE logic, one query at a time.
--   Day 11: took that same reporting logic and saved it as a VIEW, turning
--           a one-off query into a reusable business object.
--
-- NEXT MODULE: Indexes will be covered separately in a later module. This
-- Day 11 script intentionally does NOT create, alter or drop any index —
-- that is out of scope here on purpose, not an oversight.
