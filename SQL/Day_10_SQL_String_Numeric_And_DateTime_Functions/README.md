# SQL Day 10: String, Numeric & Date/Time Functions

**Author:** Shalinee Priya
**Role:** Data Analyst | SQL Trainer
**Module:** B.Tech SQL Training

---

## Overview

Welcome to **Day 10** of the SQL learning series.

This module focuses on **String, Numeric, and Date/Time Functions in MySQL**. Students learn how to clean, transform, calculate, format, and analyze individual values using SQL scalar functions.

The module builds directly on the SQL concepts covered in the previous days, including:

* Data Retrieval
* Filtering
* Aggregate Functions
* GROUP BY & HAVING
* JOINs
* Subqueries

The emphasis is on **conceptual clarity, hands-on SQL practice, business-oriented problem solving, and interview readiness**.

---

## Learning Objectives

After completing this module, you will be able to:

* Understand SQL scalar functions and how they differ from aggregate functions
* Clean and transform text using String Functions
* Perform calculations using Numeric Functions
* Work with DATE, TIME, and DATETIME values
* Extract date and time components
* Perform date arithmetic and date-difference calculations
* Format dates and times for reporting
* Handle NULL values using `IFNULL()`, `COALESCE()`, and `NULLIF()`
* Apply conditional logic using `CASE`
* Combine functions with `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, JOINs, and Subqueries
* Solve practical business problems using SQL functions
* Identify common SQL function-related interview traps

---

## Topics Covered

### String Functions

* `UPPER()`
* `LOWER()`
* `CONCAT()`
* `CONCAT_WS()`
* `LENGTH()`
* `CHAR_LENGTH()`
* `TRIM()`
* `LTRIM()`
* `RTRIM()`
* `SUBSTRING()`
* `SUBSTR()`
* `LEFT()`
* `RIGHT()`
* `LOCATE()`
* `INSTR()`
* `REPLACE()`
* `SUBSTRING_INDEX()`
* `LPAD()`
* `RPAD()`
* `REVERSE()`
* `REPEAT()`
* `ASCII()`
* `CHAR()`

### Numeric Functions

* `ROUND()`
* `TRUNCATE()`
* `CEIL()` / `CEILING()`
* `FLOOR()`
* `ABS()`
* `MOD()`
* `POWER()`
* `SQRT()`
* `SIGN()`
* `GREATEST()`
* `LEAST()`
* Awareness of `RAND()`, `LOG()`, `LOG10()`, `EXP()`, and `PI()`

### Date & Time Functions

* `CURDATE()`
* `CURRENT_DATE()`
* `CURTIME()`
* `CURRENT_TIME()`
* `NOW()`
* `CURRENT_TIMESTAMP()`
* `UTC_DATE()`
* `UTC_TIME()`
* `UTC_TIMESTAMP()`
* `DATE()`
* `TIME()`
* `YEAR()`
* `MONTH()`
* `MONTHNAME()`
* `DAY()`
* `DAYOFMONTH()`
* `DAYNAME()`
* `DAYOFWEEK()`
* `WEEKDAY()`
* `DAYOFYEAR()`
* `QUARTER()`
* `WEEK()`
* `HOUR()`
* `MINUTE()`
* `SECOND()`
* `DATE_ADD()`
* `DATE_SUB()`
* `DATEDIFF()`
* `TIMEDIFF()`
* `TIMESTAMPDIFF()`
* `DATE_FORMAT()`
* `TIME_FORMAT()`
* `STR_TO_DATE()`
* `LAST_DAY()`
* `EXTRACT()`

### NULL Handling & Conditional Logic

* `IS NULL`
* `IS NOT NULL`
* `IFNULL()`
* `COALESCE()`
* `NULLIF()`
* `CASE`

---

## Dataset

This module uses a dedicated **Employee / HR Analytics dataset**.

The dataset contains fields such as:

* Employee ID
* First Name
* Last Name
* Email
* Department
* Salary
* Bonus Percentage
* Hire Date
* Birth Date
* Last Login

The dataset is designed to provide realistic variation for:

* String manipulation
* Salary calculations
* Bonus calculations
* Employee age
* Years of service
* Hiring trends
* Date and time analysis
* NULL handling
* Business classification

---

## Repository Structure

```text
Day_10_SQL_String_Numeric_And_DateTime_Functions/
│
├── 01_SQL_Day10_Slides.pptx
├── 02_SQL_Day10_Script.sql
├── 03_SQL_Day10_Dataset.sql
└── README.md
```

---

## Learning Path

```text
Day 1  → SQL Introduction
Day 2  → Data Retrieval & Filtering
Day 3  → Aggregate Functions
Day 4  → GROUP BY & HAVING
Day 5  → Keys & Constraints
Day 6  → ER Model & Database Design
Day 7  → Database Normalization
Day 8  → SQL JOINs
Day 9  → SQL Subqueries
Day 10 → String, Numeric & Date/Time Functions
Day 11 → SQL Views
```

---

## Practical Business Case Study

The module uses an **Employee / HR Analytics** scenario to demonstrate how SQL functions can transform raw database values into meaningful business information.

Examples include:

* Creating employee display names
* Cleaning and standardizing text
* Extracting email usernames and domains
* Calculating bonus amounts
* Calculating annual salary
* Categorizing employees into salary bands
* Calculating employee age
* Calculating years of service
* Identifying employees with missing login information
* Analyzing hiring trends by year, month, and quarter
* Formatting dates for business reports
* Combining String, Numeric, Date/Time, NULL, and CASE logic

---

## Practical Learning

Practice is organized into multiple levels.

### Level 1 — Guided Practice

Build confidence by applying individual functions with instructor guidance.

### Level 2 — Independent Practice

Solve problems independently without being told which function to use.

### Level 3 — Mixed Business Problems

Combine multiple SQL concepts to solve realistic business requirements.

---

## Interview Challenge

Apply SQL functions to common technical interview scenarios and identify potential SQL pitfalls.

---

## Interview Focus

Important interview concepts include:

* Scalar vs Aggregate Functions
* `LENGTH()` vs `CHAR_LENGTH()`
* `CONCAT()` vs `CONCAT_WS()`
* `SUBSTRING()` vs `LEFT()` / `RIGHT()`
* `LOCATE()` vs `INSTR()`
* `SUBSTRING_INDEX()` for delimiter-based extraction
* `ROUND()` vs `TRUNCATE()`
* `CEIL()` vs `FLOOR()`
* `MAX()` vs `GREATEST()`
* `DATEDIFF()` vs `TIMEDIFF()` vs `TIMESTAMPDIFF()`
* `CURDATE()` vs `NOW()`
* `DATE()` / `TIME()` vs formatting functions
* `DATE_FORMAT()` and its return type
* `DAYOFWEEK()` vs `WEEKDAY()`
* `DATE_ADD()` vs `DATE_SUB()`
* `IFNULL()` vs `COALESCE()`
* NULL vs 0 vs empty string
* `IS NULL` vs `= NULL`
* `CASE` with SQL functions
* Function usage with `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, JOINs, and Subqueries

---

## Key Interview & Practical Insights

### Calculate First, Format Last

For date/time analysis, perform calculations using the original `DATE` / `DATETIME` values before formatting the final result for presentation.

```text
Calculate
   ↓
Analyze
   ↓
Format for Presentation
```

For example, perform calculations using functions such as:

* `DATEDIFF()`
* `TIMESTAMPDIFF()`
* `DATE_ADD()`
* `DATE_SUB()`

before using formatting functions such as:

* `DATE_FORMAT()`
* `TIME_FORMAT()`

`DATE_FORMAT()` returns formatted text, so the formatted result should generally be treated as presentation output rather than as the working date value.

---

### Function Behavior with NULL

NULL does not always behave the same way across SQL functions.

Always understand the specific function's NULL behavior instead of assuming NULL is equivalent to 0 or an empty string.

For example:

* `CONCAT()` returns `NULL` when an argument is `NULL`
* `CONCAT_WS()` skips `NULL` arguments
* Many arithmetic expressions involving `NULL` evaluate to `NULL`

---

### MySQL-Specific Syntax

This module uses **MySQL 8+ syntax**.

Functions from other SQL dialects should not be assumed to work in MySQL.

For delimiter-based string extraction, MySQL's `SUBSTRING_INDEX()` is used instead of functions such as `SPLIT()` or `SPLIT_PART()`.

---

## Practice Philosophy

The practice problems are designed around **business requirements** rather than simply naming a function.

Instead of:

> "Use `ROUND()` to solve this."

students are expected to understand the requirement and determine which SQL function or combination of functions is appropriate.

This encourages:

* Problem-solving
* Query design
* Function selection
* Interview readiness
* Real-world SQL thinking

---

## Prerequisites

Before starting Day 10, students should be comfortable with:

* `SELECT`
* `WHERE`
* `ORDER BY`
* Aggregate Functions
* `GROUP BY`
* `HAVING`
* JOINs
* Subqueries
* Basic relational database concepts

---

## Tools Used

* MySQL 8+
* MySQL Workbench

---

## Key Takeaway

SQL Functions are not meant to be memorized as isolated commands.

The goal is to learn how to use them to transform raw data into meaningful business information.

```text
Raw Database Data
        ↓
      Clean
        ↓
    Transform
        ↓
    Calculate
        ↓
     Analyze
        ↓
      Format
        ↓
Business Insight
```

By the end of Day 10, students should be able to take raw employee data and transform it into meaningful, business-ready information using SQL.

---

## Next Module

### Day 11 → SQL Views

After learning how to build increasingly complex queries using functions, JOINs, aggregates, and subqueries, the next step is to learn how to create reusable virtual tables using SQL Views.

---

**Author:** Shalinee Priya  
**Role:** Data Analyst | SQL Trainer  
**Module:** B.Tech SQL Training

If this repository helps you learn SQL, consider starring the repository.
