# SQL Day 3: Aggregate Functions

**Author:** Shalinee Priya  
**Role:** Data Analyst | SQL Trainer  
**Module:** B.Tech SQL Training

---

## Overview

Welcome to **Day 3** of the SQL learning series.

In this module, you'll move beyond retrieving records and learn how to **summarize data** using SQL Aggregate Functions. These functions are widely used in business reporting, analytics, dashboards, and placement interviews.

---

## Learning Objectives

After completing this module, you will be able to:

- Understand the purpose of Aggregate Functions
- Use `COUNT()`, `SUM()`, `AVG()`, `MIN()`, and `MAX()`
- Differentiate `COUNT(*)` and `COUNT(column)`
- Apply Aggregate Functions with `WHERE`
- Handle `NULL` values during aggregation
- Solve business-oriented SQL problems confidently

---

## Topics Covered

- Why Aggregate Functions?
- COUNT()
- SUM()
- AVG()
- MIN()
- MAX()
- COUNT(*) vs COUNT(column)
- Aggregate Functions with WHERE
- Business Case Studies
- Mini Interview Challenge

---

## Repository Structure

```text
Day_03_Aggregate_Functions/
│
├── 01_SQL_Day3_Slides.pptx
├── 02_SQL_Day3_Script.sql
└── README.md
```

---

## Prerequisites

Before starting Day 3, you should already know:

- SELECT
- DISTINCT
- WHERE
- AND, OR, NOT
- BETWEEN
- IN
- LIKE
- IS NULL
- ORDER BY
- LIMIT

---

## Dataset Enhancement

This module continues the existing **college_db** database and extends the `students` table with four additional columns:

| Column | Description |
|---------|-------------|
| `fees` | Student fee amount |
| `attendance` | Attendance percentage |
| `email` | Used for NULL handling examples |
| `phone_no` | Used for availability checks |

> **Note:** The original student records from Day 1 and Day 2 remain unchanged. Day 3 only extends the dataset using `ALTER TABLE`.

---

## Software Required

- MySQL Server 8.0+
- MySQL Workbench
- `college_db` database from Day 1 & Day 2

---

## How to Use

1. Open MySQL Workbench.
2. Execute `02_SQL_Day3_Script.sql` from top to bottom.
3. Verify the extended dataset.
4. Practice each Aggregate Function.
5. Attempt the interview questions without viewing solutions.

---

## Interview Focus

This module prepares students for frequently asked SQL interview questions:

- Difference between `COUNT(*)` and `COUNT(column)`
- Aggregation with `WHERE`
- `NULL` behavior in Aggregate Functions
- Numeric vs Text aggregation
- Business reporting queries using summarized data

---

## Connect

**Shalinee Priya**  
*Data Analyst | SQL Trainer*

⭐ If this repository helps you learn SQL, consider starring the repository.
