-- =============================================================================
-- SQL Day 10 Dataset : Employee / HR Analytics Database
-- Author : Shalinee Priya
-- Module : SQL STRING + NUMERIC + DATE/TIME FUNCTIONS
-- Description : Single source of truth for Day 10. A dedicated Employee/HR
--               dataset (separate from the Day 8 joins_db e-commerce dataset)
--               because this module needs DATE, DATETIME, DECIMAL salary and
--               email/text fields that the Day 8 tables do not carry.
--
-- This script is fully rerunnable: it drops and recreates the database every
-- time it is run, so re-running it never duplicates data.
-- =============================================================================

DROP DATABASE IF EXISTS hr_analytics;
CREATE DATABASE hr_analytics;
USE hr_analytics;

-- -----------------------------------------------------------------------------
-- Table 1 : departments
-- A small reference table so Section 11 can demonstrate a JOIN combined with
-- string functions (e.g. UPPER(d.location)) without pulling in the Day 8
-- e-commerce tables. Kept intentionally simple — this module's focus is
-- functions, not JOIN mechanics (already covered in Day 8).
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
-- Built from the supplied employee dataset, extended for richer variation
-- (more departments, a wider salary range, hire dates spanning 10 years and
-- multiple weekdays/quarters, two December hires, one intentionally
-- whitespace-padded name for TRIM practice, and one NULL last_login).
-- -----------------------------------------------------------------------------
CREATE TABLE employees (
    emp_id        INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    email         VARCHAR(100),
    department    VARCHAR(50),
    salary        DECIMAL(10,2),
    bonus_pct     DECIMAL(5,2),
    hire_date     DATE,
    birth_date    DATE,
    last_login    DATETIME,
    FOREIGN KEY (department) REFERENCES departments(dept_name)
);

-- NOTE (emp_id 11 — Farhan Khan): first_name is stored WITH leading/trailing
-- spaces on purpose ('  Farhan  '). Real HR extracts routinely contain dirty
-- text like this, and it is what makes the TRIM() / cleaning examples in
-- Section 3 meaningful instead of cosmetic.
-- NOTE (emp_id 6 — Neha Gupta): last_login is NULL on purpose, to drive the
-- NULL-handling examples in Section 9 (IS NULL, IFNULL, COALESCE).
INSERT INTO employees
(first_name, last_name, email, department, salary, bonus_pct, hire_date, birth_date, last_login)
VALUES
('Amit',      'Sharma',   'amit.sharma@company.com',    'Sales',      55000.756, 8.50,  '2019-03-15', '1990-06-12', '2026-07-01 09:15:00'),
('Priya',     'Verma',    'priya.verma@company.com',    'Marketing',  62000.333, 10.25, '2020-07-22', '1988-11-25', '2026-07-05 14:42:00'),
('Rahul',     'Nair',     'rahul.nair@company.com',     'IT',         78500.999, 12.00, '2018-01-10', '1992-02-18', '2026-07-10 08:05:00'),
('Sneha',     'Iyer',     'sneha.iyer@company.com',     'Finance',    49500.125, 6.75,  '2021-11-05', '1995-09-30', '2026-06-28 17:30:00'),
('Karan',     'Malhotra', 'karan.malhotra@company.com', 'IT',         91000.50,  15.00, '2016-05-19', '1985-04-02', '2026-07-11 11:20:00'),
('Neha',      'Gupta',    'neha.gupta@company.com',     'Sales',      53000.00,  9.40,  '2022-02-28', '1998-01-15', NULL),
('Vikram',    'Singh',    'vikram.singh@company.com',   'HR',         47000.45,  5.50,  '2023-08-14', '1993-07-08', '2026-07-12 19:10:00'),
('Ananya',    'Das',      'ananya.das@company.com',     'Marketing',  58000.876, 7.20,  '2017-09-01', '1991-12-20', '2026-07-09 10:00:00'),
('Rohan',     'Kapoor',   'rohan.kapoor@company.com',   'Finance',    67000.654, 11.10, '2019-12-12', '1989-03-27', '2026-07-02 13:55:00'),
('Ishita',    'Joshi',    'ishita.joshi@company.com',   'HR',         51000.20,  8.00,  '2020-04-04', '1996-10-10', '2026-07-07 16:25:00'),
('  Farhan  ','Khan',     'farhan.khan@company.com',    'IT',         72000.40,  9.00,  '2015-12-01', '1987-08-22', '2026-07-13 07:45:00'),
('Meera',     'Pillai',   'meera.pillai@company.com',   'Operations', 39500.60,  4.25,  '2024-01-08', '2000-05-14', '2026-07-14 21:05:00'),
('Devansh',   'Rao',      'devansh.rao@company.com',    'Sales',      84999.999, 13.50, '2014-06-30', '1983-01-05', '2026-06-30 12:00:00'),
('Kavya',     'Reddy',    'kavya.reddy@company.com',    'Operations', 45000.10,  6.00,  '2021-12-25', '1994-04-19', '2026-07-08 23:58:00');

-- Verification
SELECT * FROM departments;
SELECT * FROM employees;
