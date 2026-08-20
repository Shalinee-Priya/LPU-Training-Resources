# SQL Day 12: SQL Indexes

**Author:** Shalinee Priya  
**Role:** Data Analyst | SQL Trainer  
**Module:** B.Tech SQL Training

---

## Overview

Welcome to **Day 12** of the SQL learning series.

This module focuses on **SQL Indexes**, one of the most important concepts for database performance and query optimization. Students learn why indexes exist, how MySQL retrieves data efficiently, and how to design indexes for real-world business scenarios using MySQL 8+.

This module continues directly from:

- Day 8 → SQL JOINs
- Day 9 → SQL Subqueries
- Day 10 → String, Numeric & Date/Time Functions
- Day 11 → SQL Views

---

## Learning Objectives

After completing this module, you will be able to:

- Explain what an SQL Index is and why it improves performance
- Understand the conceptual working of B-Tree indexes
- Differentiate Primary, Secondary, Unique, and Composite indexes
- Apply the Leftmost Prefix Rule correctly
- Create, inspect, and remove indexes in MySQL
- Read basic `EXPLAIN` execution plans
- Evaluate index selectivity and indexing candidates
- Understand when indexes improve or reduce performance
- Solve real-world query optimization problems
- Answer common SQL Index interview questions

---

## Topics Covered

### Index Fundamentals

- What is an Index?
- Why databases need indexes
- Table Scan vs Index Lookup
- B-Tree (Conceptual)

### Types of Indexes

- Primary Key Index
- Secondary Index
- Unique Index
- Composite Index

### Index Design

- Leftmost Prefix Rule
- Index Naming Standards
- Index Selectivity
- Covering Index (Interview Awareness)

### Index Management

- `CREATE INDEX`
- `CREATE UNIQUE INDEX`
- `SHOW INDEX`
- `DROP INDEX`

### Query Optimization

- `EXPLAIN`
- Reading execution plans
- `type`
- `possible_keys`
- `key`
- `rows`
- `Extra`

### Performance

- When indexes help
- When indexes hurt
- Read vs Write trade-offs
- Storage considerations

---

## Dataset

This module uses the **HR Analytics** dataset from previous modules.

The dataset contains:

- Employee ID
- First Name
- Last Name
- Email
- Department
- City
- Salary
- Hire Date
- Phone
- Bonus Percentage

A large employee dataset is used to demonstrate realistic indexing and `EXPLAIN` examples.

---

## Repository Structure

```text
Day_12_SQL_Indexes/
│
├── 01_SQL_Day12_Slides.pptx
├── 02_SQL_Day12_Script.sql
├── 03_SQL_Day12_Dataset.sql
└── README.md
```

---

## Learning Path

```text
Day 08 → SQL JOINs
Day 09 → SQL Subqueries
Day 10 → String, Numeric & Date/Time Functions
Day 11 → SQL Views
Day 12 → SQL Indexes
```

---

## Business Case Study

Students optimize common HR Analytics queries such as:

- Find employee by email
- Employees in a department
- Department + Salary filtering
- Sort employees by hire date
- City-wise employee search
- Recent hires
- High salary employee lookup

Each problem demonstrates how proper indexing changes query execution and improves efficiency.

---

## Practical Learning

### Level 1 — Guided Practice (10)

Create and inspect different types of indexes with instructor guidance.

### Level 2 — Independent Practice (10)

Choose appropriate indexes without provided solutions.

### Level 3 — Business Optimization (10)

Design indexes for realistic HR reporting and filtering scenarios.

### Interview Challenge (15)

Performance, selectivity, composite indexes, `EXPLAIN`, and optimization questions without solutions.

---

## Interview Focus

Frequently asked concepts include:

- Primary Key vs Index
- Unique Index vs Primary Key
- Composite Index
- Leftmost Prefix Rule
- Clustered vs Secondary Index (Conceptual)
- Index Selectivity
- Covering Index
- Table Scan vs Index Lookup
- `EXPLAIN`
- `SHOW INDEX`
- When indexes improve performance
- Why too many indexes are harmful

---

## Key Interview & Practical Insights

### How MySQL Finds Data

```text
Query
   ↓
Optimizer
   ↓
Index (B-Tree)
   ↓
Matching Row
```

Indexes allow MySQL to **skip unnecessary rows** instead of scanning the entire table.

### Leftmost Prefix Rule

For a composite index:

```sql
(department, city, salary)
```

Efficient searches include:

- department
- department + city
- department + city + salary

But **not**:

- city
- salary
- city + salary

### Performance Trade-off

Indexes are designed for **faster reads**, but they introduce additional work during:

- INSERT
- UPDATE
- DELETE

A well-designed database balances read performance with write cost.

---

## Practice Philosophy

Students are expected to justify **why** an index should exist—not simply create one.

Every indexing decision should answer:

- What query is being optimized?
- Which columns are filtered?
- What is the selectivity?
- Does `EXPLAIN` support the decision?

---

## Prerequisites

Before starting Day 12, students should know:

- SELECT
- WHERE
- ORDER BY
- GROUP BY
- HAVING
- JOINs
- Subqueries
- SQL Functions
- Views

---

## Tools Used

- **MySQL 8+**
- **MySQL Workbench**

---

## Key Takeaway

Indexes are one of the most powerful tools for improving database performance.

```text
Business Query
      ↓
   EXPLAIN
      ↓
 Index Design
      ↓
 Faster Lookup
      ↓
Better Performance
```

By the end of Day 12, students should be able to design efficient indexes, analyze execution plans, and make informed optimization decisions in MySQL.

---

## Next Module

### Day 13 → SQL Stored Procedures

Learn how to encapsulate reusable business logic using parameters, variables, conditional statements, and procedural SQL in MySQL.

---

## Author

**Shalinee Priya**  
*Data Analyst | SQL Trainer*

If this repository helps you learn SQL, consider starring the repository.
