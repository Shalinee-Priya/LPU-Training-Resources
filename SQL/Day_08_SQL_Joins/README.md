# SQL Day 8: SQL JOINS (INNER, LEFT, RIGHT, FULL & CROSS)

**Structured Query Language · B.Tech SQL Training**

**Shalinee Priya** · *Data Analyst | SQL Trainer*

---

## Module Overview

Day 7 introduced **Database Normalization**, where data was divided into multiple related tables to eliminate redundancy. While normalization improves data integrity, real business questions can no longer be answered from a single table.

**SQL JOINs** solve this problem by reconnecting normalized tables using **Primary Keys** and **Foreign Keys**, allowing us to generate meaningful business reports without duplicating data.

This module uses a complete **E-commerce relational database** consisting of Customers, Orders, Products, Suppliers, and OrderDetails to demonstrate real-world reporting scenarios.

---

## Learning Objectives

After completing this module, you will be able to:

- Understand why normalized databases require SQL JOINs.
- Write **INNER JOIN**, **LEFT JOIN**, **RIGHT JOIN**, **FULL OUTER JOIN (MySQL workaround)** and **CROSS JOIN** queries.
- Combine multiple related tables using Primary & Foreign Keys.
- Build invoice, warehouse, supplier and sales reports using JOINs.
- Understand the difference between `ON` and `WHERE`.
- Identify missing relationships using LEFT JOIN.
- Avoid common JOIN mistakes and Cartesian Products.
- Solve interview-oriented SQL JOIN problems confidently.

---

## Topics Covered

| # | Topic | Focus |
|---|---|---|
| 1 | Why SQL JOINs | Normalization → Reporting |
| 2 | INNER JOIN | Matching records only |
| 3 | LEFT JOIN | All left + matching right |
| 4 | RIGHT JOIN | All right + matching left |
| 5 | FULL OUTER JOIN | MySQL `LEFT UNION RIGHT` |
| 6 | CROSS JOIN | Cartesian Product |
| 7 | JOIN Execution Flow | `ON` vs `WHERE` |
| 8 | Business Reports | Multi-table reporting |
| 9 | Common Errors | Missing `ON`, NULLs, ambiguity |
| 10 | Interview Preparation | 20 interview questions |

---

## Repository Structure

```text
Day_08_SQL_Joins/
│
├── 01_SQL_Day8_Slides.pptx
├── 02_SQL_Day8_Script.sql
└── README.md
```

---

## Learning Path (Day 1 → Day 8)

| Day | Module |
|------|--------|
| Day 1 | SQL Introduction |
| Day 2 | Data Retrieval & Filtering |
| Day 3 | Aggregate Functions |
| Day 4 | GROUP BY & HAVING |
| Day 5 | Keys & Constraints |
| Day 6 | ER Model & Database Design |
| Day 7 | Database Normalization |
| **Day 8** | **SQL JOINS (INNER, LEFT, RIGHT, FULL & CROSS)** |
| Day 9 | SQL Subqueries *(Next)* |

---

## Business Dataset

This module is built on a normalized **E-commerce database** containing five related tables:

- **Customers** — Customer information
- **Orders** — Customer orders
- **OrderDetails** — Products within each order
- **Products** — Product catalog
- **Suppliers** — Product suppliers

Relationship flow:

```text
Customers (1)
      │
      ▼
Orders (N)
      │
      ▼
OrderDetails
      │
      ▼
Products
      │
      ▼
Suppliers
```

Using SQL JOINs, these normalized tables are combined to generate complete business reports similar to those used in real e-commerce platforms.

---

## Practical Learning

The SQL script includes:

- Progressive JOIN demonstrations
- Schema verification (`DESC`)
- Relationship verification
- INNER, LEFT, RIGHT, FULL & CROSS JOIN examples
- Business-first reporting scenarios
- 50 practice questions (Easy → Advanced)
- Common debugging mistakes
- 20 interview questions

---

## Interview Focus

Frequently asked interview topics covered in this module:

- INNER JOIN vs LEFT JOIN
- RIGHT JOIN usage
- FULL OUTER JOIN in MySQL
- CROSS JOIN & Cartesian Product
- `ON` vs `WHERE`
- Primary Key & Foreign Key relationships
- NULL handling in JOINs
- Multi-table business reporting

---

## Connect

**Shalinee Priya**

*Data Analyst | SQL Trainer*

---

⭐ If this SQL training series helps you learn, consider **starring the repository** to support more free, high-quality learning content.

**Next Module → Day 9: SQL Subqueries**
