-- =============================================================================
-- SQL Day 11 Dataset : Employee / HR Analytics Database
-- Author  : Shalinee Priya
-- Module  : SQL VIEWS
-- Continuity : This is the SAME hr_analytics schema used in Day 10
--              (String, Numeric & Date/Time Functions), extended with two
--              columns — city and phone — that Day 11's View lessons need
--              (e.g. exposing/hiding contact details, filtering by city).
--              All Day 10 rows, values, departments and quirks (the padded
--              '  Farhan  ' name, the NULL last_login for Neha Gupta) are
--              kept unchanged so students see Day 10 -> Day 11 continuity
--              directly in the data, not just in the concepts.
--
-- This script is fully rerunnable: it drops and recreates the database every
-- time it is run, so re-running it never duplicates data.
-- =============================================================================

DROP DATABASE IF EXISTS hr_analytics;
CREATE DATABASE hr_analytics;
USE hr_analytics;

-- -----------------------------------------------------------------------------
-- Table 1 : departments
-- Small reference table. Carried over from Day 10 unchanged so that a Day 11
-- view built with a JOIN (Section 6 / Section 19) reuses a table students
-- already recognise instead of a new, unfamiliar one.
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    dept_name  VARCHAR(50) PRIMARY KEY,
    dept_head  VARCHAR(50),
    location   VARCHAR(50)
);

INSERT INTO departments VALUES
('Sales',       'Meenal Kulkarni', 'Mumbai'),
('Marketing',   'Arvind Rao',      'Bangalore'),
('IT',          'Sunita Menon',    'Hyderabad'),
('Finance',     'Deepak Chawla',   'Delhi'),
('HR',          'Ritu Bhatia',     'Delhi'),
('Operations',  'Vivek Ahluwalia', 'Pune');

-- -----------------------------------------------------------------------------
-- Table 2 : employees
-- Same 14 employees, same salaries, bonus_pct, hire_date, birth_date and
-- last_login as Day 10. Two columns are ADDED for Day 11's View examples:
--   city  -> most employees sit at their department's home location, but a
--            few (Karan, Ananya, Kavya) work from a different city on
--            purpose, so "city" is a genuinely independent filter column
--            and not just a copy of department -> location.
--   phone -> lets Day 11 demonstrate hiding a sensitive contact column via
--            a view (Section 3 / Section 14), which Day 10 could not show
--            because the column did not exist yet.
-- -----------------------------------------------------------------------------
CREATE TABLE employees (
    emp_id        INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    email         VARCHAR(100),
    phone         VARCHAR(15),
    department    VARCHAR(50),
    city          VARCHAR(50),
    salary        DECIMAL(10,2),
    bonus_pct     DECIMAL(5,2),
    hire_date     DATE,
    birth_date    DATE,
    last_login    DATETIME,
    FOREIGN KEY (department) REFERENCES departments(dept_name)
);

-- NOTE (emp_id 11 — Farhan Khan): first_name is stored WITH leading/trailing
-- spaces on purpose ('  Farhan  '), carried over from Day 10.
-- NOTE (emp_id 6 — Neha Gupta): last_login is NULL on purpose, carried over
-- from Day 10.
INSERT INTO employees
(first_name, last_name, email, phone, department, city, salary, bonus_pct, hire_date, birth_date, last_login)
VALUES
('Amit',      'Sharma',   'amit.sharma@company.com',    '9000000001', 'Sales',      'Mumbai',    55000.76, 8.50,  '2019-03-15', '1990-06-12', '2026-07-01 09:15:00'),
('Priya',     'Verma',    'priya.verma@company.com',    '9000000002', 'Marketing',  'Bangalore', 62000.33, 10.25, '2020-07-22', '1988-11-25', '2026-07-05 14:42:00'),
('Rahul',     'Nair',     'rahul.nair@company.com',     '9000000003', 'IT',         'Hyderabad', 78501.00, 12.00, '2018-01-10', '1992-02-18', '2026-07-10 08:05:00'),
('Sneha',     'Iyer',     'sneha.iyer@company.com',     '9000000004', 'Finance',    'Delhi',     49500.13, 6.75,  '2021-11-05', '1995-09-30', '2026-06-28 17:30:00'),
('Karan',     'Malhotra', 'karan.malhotra@company.com', '9000000005', 'IT',         'Chennai',   91000.50, 15.00, '2016-05-19', '1985-04-02', '2026-07-11 11:20:00'),
('Neha',      'Gupta',    'neha.gupta@company.com',     '9000000006', 'Sales',      'Mumbai',    53000.00, 9.40,  '2022-02-28', '1998-01-15', NULL),
('Vikram',    'Singh',    'vikram.singh@company.com',   '9000000007', 'HR',         'Delhi',     47000.45, 5.50,  '2023-08-14', '1993-07-08', '2026-07-12 19:10:00'),
('Ananya',    'Das',      'ananya.das@company.com',     '9000000008', 'Marketing',  'Pune',      58000.88, 7.20,  '2017-09-01', '1991-12-20', '2026-07-09 10:00:00'),
('Rohan',     'Kapoor',   'rohan.kapoor@company.com',   '9000000009', 'Finance',    'Delhi',     67000.65, 11.10, '2019-12-12', '1989-03-27', '2026-07-02 13:55:00'),
('Ishita',    'Joshi',    'ishita.joshi@company.com',   '9000000010', 'HR',         'Delhi',     51000.20, 8.00,  '2020-04-04', '1996-10-10', '2026-07-07 16:25:00'),
('  Farhan  ','Khan',     'farhan.khan@company.com',    '9000000011', 'IT',         'Hyderabad', 72000.40, 9.00,  '2015-12-01', '1987-08-22', '2026-07-13 07:45:00'),
('Meera',     'Pillai',   'meera.pillai@company.com',   '9000000012', 'Operations', 'Pune',      39500.60, 4.25,  '2024-01-08', '2000-05-14', '2026-07-14 21:05:00'),
('Devansh',   'Rao',      'devansh.rao@company.com',    '9000000013', 'Sales',      'Mumbai',    84999.99, 13.50, '2014-06-30', '1983-01-05', '2026-06-30 12:00:00'),
('Kavya',     'Reddy',    'kavya.reddy@company.com',    '9000000014', 'Operations', 'Chennai',   45000.10, 6.00,  '2021-12-25', '1994-04-19', '2026-07-08 23:58:00');

-- Verification
SELECT * FROM departments;
SELECT * FROM employees;
