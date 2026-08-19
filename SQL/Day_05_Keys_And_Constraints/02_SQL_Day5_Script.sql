-- ============================================================================
-- SQL DAY 5 - KEYS & CONSTRAINTS
-- ============================================================================
-- Author               : Shalinee Priya (Data Analyst | SQL Trainer)
-- Module               : B.Tech SQL Training - Day 5 of the SQL series
-- Prerequisite         : SQL Day 1-4 (SELECT, filtering, GROUP BY & HAVING)
-- Prepared             : August 19, 2026
--
-- Learning Objectives  :
--   1. Understand why data integrity matters in relational databases
--   2. Implement PRIMARY KEY to guarantee unique row identity
--   3. Apply UNIQUE and NOT NULL to guard against duplicate / missing data
--   4. Use DEFAULT to auto-fill values and AUTO_INCREMENT to auto-generate IDs
--   5. Implement FOREIGN KEY to enforce referential integrity between tables
--   6. Recognize and debug the most common constraint-violation errors
--
-- Execution Instructions:
--   1. Open this file in MySQL Workbench (MySQL 8.0+).
--   2. Select the entire script and run it (Execute All / Ctrl+Shift+Enter).
--      The script is written to run top-to-bottom without any errors.
--   3. Every statement that is DESIGNED to fail is written as a commented-out
--      block tagged "-- FAILS:". Uncomment ONE such block at a time and
--      re-run just that block to see the real MySQL error message.
--   4. Section 2 always rebuilds the database from scratch, so you can
--      re-run this whole script any time to reset to a clean state.
-- ============================================================================


-- ============================================================================
-- SECTION 2: CREATE FRESH DATABASE
-- ============================================================================
-- Reason: Day 5 focuses on table DESIGN concepts (keys & constraints), so we
-- use a brand-new database instead of college_db from Day 1-4. This keeps
-- our constraint experiments -- including the failing ones -- completely
-- isolated from the query data used in previous sessions.
-- ============================================================================

DROP DATABASE IF EXISTS college_constraints_db;
CREATE DATABASE college_constraints_db;
USE college_constraints_db;


-- ============================================================================
-- SECTION 3: PRIMARY KEY
-- ============================================================================
-- A PRIMARY KEY uniquely identifies every row in a table. It can never be
-- NULL, and a table can declare only ONE PRIMARY KEY.
-- ============================================================================

CREATE TABLE students (
    student_id  INT PRIMARY KEY,
    name        VARCHAR(50),
    branch      VARCHAR(30),
    cgpa        DECIMAL(3,2)
) ENGINE = InnoDB;

-- Verify table structure
DESC students;

-- ---------------------------------------------------------------------------
-- 3.1  Successful insert -- each student_id is unique, so both rows succeed
-- ---------------------------------------------------------------------------
INSERT INTO students (student_id, name, branch, cgpa) VALUES
    (101, 'Aarav',  'CSE', 8.70),
    (102, 'Diya',   'ECE', 9.10);

SELECT * FROM students;

-- ---------------------------------------------------------------------------
-- 3.2  Duplicate PRIMARY KEY error (kept commented so the script keeps
--      running top-to-bottom). Uncomment the block below and run it on its
--      own to see MySQL reject the duplicate student_id.
-- ---------------------------------------------------------------------------
-- FAILS: student_id 101 already exists in the table
-- INSERT INTO students (student_id, name, branch, cgpa)
-- VALUES (101, 'Aman', 'ME', 7.80);
--
-- Expected error:
--   ERROR 1062 (23000): Duplicate entry '101' for key 'students.PRIMARY'


-- ============================================================================
-- SECTION 4: NOT NULL & UNIQUE
-- ============================================================================
-- UNIQUE   -> no two rows may share the same value in that column
-- NOT NULL -> the column can never be left empty
-- Both can be applied to more than one column, unlike PRIMARY KEY.
-- ============================================================================

CREATE TABLE users (
    user_id  INT PRIMARY KEY,
    email    VARCHAR(100) UNIQUE,
    name     VARCHAR(50) NOT NULL,
    phone    VARCHAR(15) UNIQUE
) ENGINE = InnoDB;

-- Verify table structure
DESC users;

-- ---------------------------------------------------------------------------
-- 4.1  Successful inserts -- distinct email, distinct phone, name provided
-- ---------------------------------------------------------------------------
INSERT INTO users (user_id, email, name, phone) VALUES
    (1, 'aarav@college.edu', 'Aarav', '9990001111'),
    (2, 'diya@college.edu',  'Diya',  '9990002222');

SELECT * FROM users;

-- ---------------------------------------------------------------------------
-- 4.2  Duplicate email -- violates the UNIQUE constraint on email
--      This will fail. Uncomment to observe the error, then re-comment it.
-- ---------------------------------------------------------------------------
-- FAILS: 'aarav@college.edu' already exists in the email column
-- INSERT INTO users (user_id, email, name, phone)
-- VALUES (3, 'aarav@college.edu', 'Aman', '9990003333');
--
-- Expected error:
--   ERROR 1062 (23000): Duplicate entry 'aarav@college.edu' for key 'users.email'

-- ---------------------------------------------------------------------------
-- 4.3  NULL name -- violates the NOT NULL constraint on name
--      This will fail. Uncomment to observe the error, then re-comment it.
-- ---------------------------------------------------------------------------
-- FAILS: name cannot be NULL
-- INSERT INTO users (user_id, email, name, phone)
-- VALUES (3, 'kabir@college.edu', NULL, '9990004444');
--
-- Expected error:
--   ERROR 1048 (23000): Column 'name' cannot be null


-- ============================================================================
-- SECTION 5: DEFAULT
-- ============================================================================
-- DEFAULT supplies an automatic value when a column is left out of an
-- INSERT statement. It does NOT apply if the column is explicitly given a
-- value (even if that value happens to be different from the default).
-- ============================================================================

CREATE TABLE attendance (
    attendance_id  INT PRIMARY KEY,
    student_name   VARCHAR(50) NOT NULL,
    attendance_pct INT DEFAULT 75
) ENGINE = InnoDB;

-- Verify table structure
DESC attendance;

-- ---------------------------------------------------------------------------
-- 5.1  Insert WITH attendance specified -- the given value overrides DEFAULT
-- ---------------------------------------------------------------------------
INSERT INTO attendance (attendance_id, student_name, attendance_pct)
VALUES (1, 'Aarav', 92);

-- ---------------------------------------------------------------------------
-- 5.2  Insert WITHOUT attendance -- MySQL fills it in with the DEFAULT (75)
-- ---------------------------------------------------------------------------
INSERT INTO attendance (attendance_id, student_name)
VALUES (2, 'Diya');

-- ---------------------------------------------------------------------------
-- 5.3  Verify -- attendance_id 2 should show attendance_pct = 75
-- ---------------------------------------------------------------------------
SELECT * FROM attendance;


-- ============================================================================
-- SECTION 6: AUTO_INCREMENT
-- ============================================================================
-- AUTO_INCREMENT lets MySQL generate the next primary-key value for you.
-- Leave the column out of the INSERT (or pass NULL) and MySQL assigns the
-- next available integer automatically.
-- ============================================================================

CREATE TABLE employees (
    emp_id      INT AUTO_INCREMENT PRIMARY KEY,
    emp_name    VARCHAR(50) NOT NULL,
    department  VARCHAR(30)
) ENGINE = InnoDB;

-- Verify table structure
DESC employees;

-- ---------------------------------------------------------------------------
-- 6.1  Insert 5 employees WITHOUT specifying emp_id
-- ---------------------------------------------------------------------------
INSERT INTO employees (emp_name, department) VALUES
    ('Rohan',  'HR'),
    ('Meera',  'Finance'),
    ('Karan',  'IT'),
    ('Ishita', 'Operations'),
    ('Vikram', 'Sales');

-- ---------------------------------------------------------------------------
-- 6.2  Show the generated IDs -- emp_id should read 1, 2, 3, 4, 5
-- ---------------------------------------------------------------------------
SELECT * FROM employees;


-- ============================================================================
-- SECTION 7: FOREIGN KEY
-- ============================================================================
-- A FOREIGN KEY links a column in one table (the child) to the PRIMARY KEY
-- of another table (the parent). MySQL then enforces Referential Integrity:
-- it will not allow a child row to reference a parent row that does not
-- exist, and it protects the parent row from being orphaned.
--
-- NOTE: We rebuild the "students" table here so it can carry a dept_id
-- column for this section's Foreign Key demonstration. This does not
-- affect anything already covered in Section 3.
-- ============================================================================

CREATE TABLE departments (
    dept_id    INT PRIMARY KEY,
    dept_name  VARCHAR(50) NOT NULL
) ENGINE = InnoDB;

-- Verify table structure
DESC departments;

DROP TABLE IF EXISTS students;

CREATE TABLE students (
    student_id  INT PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    dept_id     INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- 7.1  Insert parent rows first -- a department must exist before a
--      student can reference it
-- ---------------------------------------------------------------------------
INSERT INTO departments (dept_id, dept_name) VALUES
    (1, 'Computer Science'),
    (2, 'Electronics');

-- ---------------------------------------------------------------------------
-- 7.2  Insert valid student records -- each dept_id exists in departments
-- ---------------------------------------------------------------------------
INSERT INTO students (student_id, name, dept_id) VALUES
    (101, 'Aarav', 1),
    (102, 'Diya',  2);

SELECT * FROM students;

-- ---------------------------------------------------------------------------
-- 7.3  Invalid Foreign Key -- dept_id 9 does not exist in departments
--      This will fail. Uncomment to observe the error, then re-comment it.
-- ---------------------------------------------------------------------------
-- FAILS: there is no department with dept_id = 9
-- INSERT INTO students (student_id, name, dept_id)
-- VALUES (103, 'Kabir', 9);
--
-- Expected error:
--   ERROR 1452 (23000): Cannot add or update a child row: a foreign key
--   constraint fails (`college_constraints_db`.`students`,
--   CONSTRAINT `students_ibfk_1` FOREIGN KEY (`dept_id`)
--   REFERENCES `departments` (`dept_id`))


-- ============================================================================
-- SECTION 8: CONSTRAINT SUMMARY TABLE (comments only, no query output)
-- ============================================================================
-- ----------------------------------------------------------------------------
-- | Constraint     | Purpose                                                |
-- ----------------------------------------------------------------------------
-- | PRIMARY KEY    | Unique identity for every row                         |
-- | FOREIGN KEY    | Relationship / referential integrity between tables   |
-- | UNIQUE         | Prevent duplicate values in a column                  |
-- | NOT NULL       | Make a value mandatory                                |
-- | DEFAULT        | Automatic value when none is supplied                 |
-- | AUTO_INCREMENT | Sequential, system-generated IDs                      |
-- ----------------------------------------------------------------------------


-- ============================================================================
-- SECTION 9: COMMON INTERVIEW MISTAKES
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 9.1  Two PRIMARY KEYs on one table
--      A table can declare only ONE PRIMARY KEY. To make several columns
--      unique together, use a COMPOSITE PRIMARY KEY -- PRIMARY KEY(col1, col2)
--      -- not two separate PRIMARY KEY clauses.
-- ---------------------------------------------------------------------------
-- FAILS: a table cannot have two PRIMARY KEY constraints
-- CREATE TABLE bad_example_1 (
--     id_1 INT PRIMARY KEY,
--     id_2 INT PRIMARY KEY
-- );
--
-- Expected error:
--   ERROR 1068 (42000): Multiple primary key defined

-- ---------------------------------------------------------------------------
-- 9.2  Duplicate value in a UNIQUE column
--      Every value in a UNIQUE column must be distinct, exactly like a
--      Primary Key -- the only difference is a table may have many UNIQUE
--      columns, but only one PRIMARY KEY.
-- ---------------------------------------------------------------------------
-- FAILS: 'diya@college.edu' already exists in users.email
-- INSERT INTO users (user_id, email, name, phone)
-- VALUES (4, 'diya@college.edu', 'Rehan', '9990005555');
--
-- Expected error:
--   ERROR 1062 (23000): Duplicate entry 'diya@college.edu' for key 'users.email'

-- ---------------------------------------------------------------------------
-- 9.3  Invalid Foreign Key value
--      A child row can never reference a parent row that does not exist.
--      (Same idea as 7.3 above.)
-- ---------------------------------------------------------------------------
-- FAILS: dept_id 50 is not present in departments
-- INSERT INTO students (student_id, name, dept_id)
-- VALUES (104, 'Zara', 50);
--
-- Expected error:
--   ERROR 1452 (23000): Cannot add or update a child row: a foreign key
--   constraint fails

-- ---------------------------------------------------------------------------
-- 9.4  Inserting NULL into a NOT NULL column
--      A mandatory column rejects NULL even if every other column is valid.
--      (Same idea as 4.3 above.)
-- ---------------------------------------------------------------------------
-- FAILS: dept_name cannot be NULL
-- INSERT INTO departments (dept_id, dept_name)
-- VALUES (3, NULL);
--
-- Expected error:
--   ERROR 1048 (23000): Column 'dept_name' cannot be null

-- ---------------------------------------------------------------------------
-- 9.5  Manually inserting a duplicate AUTO_INCREMENT value
--      AUTO_INCREMENT does not stop you from supplying your own value --
--      but if that value has already been used, it is still a duplicate
--      PRIMARY KEY and MySQL rejects it exactly like Section 3.2.
-- ---------------------------------------------------------------------------
-- FAILS: emp_id 1 was already generated for 'Rohan' in Section 6
-- INSERT INTO employees (emp_id, emp_name, department)
-- VALUES (1, 'Fake Employee', 'IT');
--
-- Expected error:
--   ERROR 1062 (23000): Duplicate entry '1' for key 'employees.PRIMARY'


-- ============================================================================
-- SECTION 10: INTERVIEW PRACTICE (20 questions -- comments only, no answers)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- FOUNDATION
-- ---------------------------------------------------------------------------
-- 1.  Define Primary Key.
-- 2.  What is the difference between UNIQUE and Primary Key?
-- 3.  Why do we use NOT NULL?
-- 4.  What is the purpose of DEFAULT?
-- 5.  What does AUTO_INCREMENT mean?

-- ---------------------------------------------------------------------------
-- MEDIUM
-- ---------------------------------------------------------------------------
-- 6.  Can a Foreign Key contain duplicate values?
-- 7.  Can a Foreign Key contain NULL?
-- 8.  Why should an email column be declared UNIQUE?
-- 9.  Why can a table have only one Primary Key?
-- 10. What does a Composite Primary Key mean? (concept only)

-- ---------------------------------------------------------------------------
-- PLACEMENT LEVEL
-- ---------------------------------------------------------------------------
-- 11. What is the difference between a Primary Key and a Candidate Key?
-- 12. Can a UNIQUE column contain NULL?
-- 13. What is Referential Integrity?
-- 14. What is the difference between a Parent table and a Child table?
-- 15. What does ON DELETE CASCADE do? (concept only)
-- 16. What does ON UPDATE CASCADE do? (concept only)
-- 17. Which constraints improve overall data quality?
-- 18. Why do constraints matter before performing JOINS?
-- 19. Design a banking database scenario using appropriate keys and constraints.
-- 20. Design a student placement scenario using appropriate keys and constraints.

-- No solutions are provided above -- work through each question before the
-- next session.


-- ============================================================================
-- END OF SQL DAY 5 SCRIPT
-- ============================================================================
