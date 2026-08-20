# SQL Day 11: Views

**Author:** Shalinee Priya  
**Role:** Data Analyst | SQL Trainer  
**Module:** B.Tech SQL Training

---

## Overview

Welcome to **Day 11** of the SQL learning series.

This module introduces **SQL Views**—one of the most important database objects for creating reusable, simplified, and business-oriented query layers. Students learn how to convert complex SQL queries into virtual tables, manage the complete view lifecycle, and understand real-world concepts such as updatable views, `WITH CHECK OPTION`, metadata inspection, security awareness, and interview-level best practices.

This module continues directly from:

- Day 8 → SQL JOINs
- Day 9 → SQL Subqueries
- Day 10 → String, Numeric & Date/Time Functions

---

## Learning Objectives

After completing this module, you will be able to:

- Explain what a SQL View is and how it differs from a table
- Create reusable virtual tables using `CREATE VIEW`
- Build views using JOINs, Subqueries, Functions, and `CASE`
- Modify views using `CREATE OR REPLACE VIEW` and `ALTER VIEW`
- Remove views safely using `DROP VIEW IF EXISTS`
- Inspect view metadata using `SHOW CREATE VIEW` and `INFORMATION_SCHEMA.VIEWS`
- Distinguish updatable and non-updatable views
- Apply `WITH CHECK OPTION` correctly
- Understand SQL SECURITY at an interview-awareness level
- Compare Views with Subqueries, Tables, and Materialized Views
- Solve business reporting problems using reusable views

---

## Topics Covered

### View Fundamentals

- What is a View?
- Virtual Table concept
- Table vs View
- Why businesses use Views
- View abstraction architecture

### Creating & Managing Views

- `CREATE VIEW`
- `CREATE OR REPLACE VIEW`
- `ALTER VIEW`
- `DROP VIEW`
- `DROP VIEW IF EXISTS`

### Querying Views

- `SELECT` from a View
- `WHERE`
- `ORDER BY`
- `GROUP BY`
- `HAVING`

### Views with Previous SQL Concepts

- String Functions
- Numeric Functions
- Date/Time Functions
- `CASE`
- Aggregate Functions
- JOINs
- Subqueries

### Advanced View Concepts

- Updatable Views
- Non-Updatable Views
- `WITH CHECK OPTION`
- View Metadata
- `SHOW CREATE VIEW`
- `INFORMATION_SCHEMA.VIEWS`
- SQL SECURITY (`DEFINER` & `INVOKER`)
- View Processing Algorithms
- View Dependencies
- Performance Awareness

### Comparisons

- View vs Table
- View vs Subquery
- View vs Materialized View

---

## Dataset

This module uses the **HR Analytics** dataset introduced in Day 10.

The dataset contains realistic employee information, including:

- Employee ID
- First Name
- Last Name
- Department
- Salary
- City
- Hire Date
- Email
- Phone

The same business domain is intentionally reused to demonstrate how complex employee-reporting queries become reusable SQL Views.

---

## Repository Structure

```text
Day_11_SQL_Views/
│
├── 01_SQL_Day11_Slides.pptx
├── 02_SQL_Day11_Script.sql
├── 03_SQL_Day11_Dataset.sql
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
Day 12 → SQL Indexes
```

---

## Business Case Study

The module uses an **HR Analytics** scenario where complex employee reports are transformed into reusable database objects.

Business Views include:

- `employee_basic`
- `employee_salary_report`
- `high_salary_employees`
- `annual_salary_view`
- `employee_report`
- `department_salary_summary`
- `recent_hires`
- `above_average_salary`
- `it_employees`

Students learn how each view solves a real reporting requirement instead of repeatedly writing long SQL queries.

---

## Practical Learning

Practice is organized into four levels.

### Level 1 — Guided Practice (10)

Instructor-led creation of foundational views.

### Level 2 — Independent Practice (10)

Students design reusable views without provided solutions.

### Level 3 — Business Problems (10)

Real HR reporting scenarios requiring multiple SQL concepts.

### Interview Challenge (15)

Conceptual, technical, advanced, and scenario-based interview questions without solutions.

---

## Interview Focus

Important interview topics include:

- What is a View?
- Why is it called a virtual table?
- View vs Table
- View vs Subquery
- View vs Materialized View
- Advantages and limitations of Views
- Updatable vs Non-Updatable Views
- `WITH CHECK OPTION`
- `CREATE VIEW` vs `ALTER VIEW` vs `CREATE OR REPLACE VIEW`
- `SHOW CREATE VIEW`
- `INFORMATION_SCHEMA.VIEWS`
- SQL SECURITY (`DEFINER` vs `INVOKER`)
- View Processing Algorithms
- Performance misconceptions
- Dependency and maintenance of Views

---

## Key Interview & Practical Insights

### Complex Query → Reusable View

```text
Complex SQL Query
        ↓
JOIN + Functions + CASE + Subquery
        ↓
      CREATE VIEW
        ↓
Reusable Business Report
```

The primary purpose of a View is **reusability**, not replacing SQL itself.

---

### Updatable vs Non-Updatable Views

A View is generally updatable when each row maps directly to one row in the underlying table.

Common reasons a View becomes non-updatable include:

- Aggregate Functions
- `GROUP BY`
- `HAVING`
- `DISTINCT`
- `UNION`
- Definitions that break one-to-one row mapping

---

### WITH CHECK OPTION

`WITH CHECK OPTION` ensures that rows modified through a filtered View continue to satisfy the View's `WHERE` condition.

This prevents invalid updates from escaping the View's business rule.

---

### Performance Reality

Views primarily provide:

- Abstraction
- Reusability
- Consistent business logic
- Controlled data exposure

They **do not automatically improve query performance**. Performance depends on the underlying query and database execution plan.

---

## Practice Philosophy

Students are expected to solve **business requirements**, not memorize SQL syntax.

Instead of being told which View to create, they learn to identify:

- What information is needed
- Which columns should be exposed
- Which business rules belong inside the View
- When a View is preferable to repeatedly writing the same query

---

## Prerequisites

Before starting Day 11, students should be comfortable with:

- SELECT
- WHERE
- ORDER BY
- Aggregate Functions
- GROUP BY
- HAVING
- JOINs
- Subqueries
- String, Numeric & Date/Time Functions
- CASE

---

## Tools Used

- **MySQL 8+**
- **MySQL Workbench**

---

## Key Takeaway

A SQL View is best understood as a **reusable business query**.

```text
Business Requirement
        ↓
Complex SQL Query
        ↓
CREATE VIEW
        ↓
Reusable Virtual Table
        ↓
Simple Business Reporting
```

By the end of Day 11, students should be able to design, manage, inspect, and safely use Views in real-world reporting scenarios while understanding their practical limitations.

---

## Next Module

### Day 12 → SQL Indexes

After learning how to simplify and reuse complex SQL logic with Views, the next step is understanding how **Indexes** improve data retrieval performance and optimize query execution.

---

## Author

**Shalinee Priya**  
*Data Analyst | SQL Trainer*

If this repository helps you learn SQL, consider starring the repository.
