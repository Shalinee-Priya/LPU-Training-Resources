-- =============================================================================
-- SQL DAY 6 -- ER MODEL & DATABASE DESIGN
-- =============================================================================
-- Author         : Shalinee Priya  |  Data Analyst & SQL Trainer
-- Module         : Day 6 of the B.Tech SQL Training Series
-- Continuation   : Direct continuation of Day 5 (Keys & Constraints)
-- Database       : MySQL 8.0+
--
-- -----------------------------------------------------------------------------
-- LEARNING OBJECTIVES
-- -----------------------------------------------------------------------------
--   1. Understand WHY database design must happen before SQL is written
--   2. Learn the building blocks of an ER Model: Entity, Attribute,
--      Relationship, Cardinality
--   3. Convert an ER Model into relational tables using PRIMARY KEY and
--      FOREIGN KEY constraints
--   4. Build a working College database (Departments, Students, Courses,
--      Instructors, Enrollments) and observe 1:1, 1:M, M:1 and M:N
--      relationships in real data
--   5. Practice identifying ER components on real-world business case
--      studies (Library, Hospital, Amazon Orders)
--   6. Prepare for ER Model interview questions asked at placement level
--
-- -----------------------------------------------------------------------------
-- EXECUTION INSTRUCTIONS
-- -----------------------------------------------------------------------------
--   1. Run this script top-to-bottom in MySQL Workbench / MySQL CLI (v8.0+)
--   2. The script DROPS and recreates its own database (college_er_db), so
--      it is completely safe to re-run any number of times
--   3. Sections 3, 7, 8, 9 and 10 are teaching commentary written as SQL
--      comments (no executable statements) -- this is intentional, keeps
--      the classroom discussion inline with the code, and does not break
--      top-to-bottom execution
--   4. Total run time: under 2 seconds
--
-- -----------------------------------------------------------------------------
-- TABLE OF CONTENTS
-- -----------------------------------------------------------------------------
--   SECTION 1  : Professional Header                         (this section)
--   SECTION 2  : Create Fresh Database
--   SECTION 3  : Visual Reference -- The ER Diagram
--   SECTION 4  : Create Entities (Tables)
--   SECTION 5  : Insert Sample Data
--   SECTION 6  : Understand Relationships (Verification Queries)
--   SECTION 7  : Cardinality Demonstration (1:1, 1:M, M:1, M:N)
--   SECTION 8  : Convert ER Model into Relational Tables (Concept Map)
--   SECTION 9  : Business Design Activity (Library / Hospital / Amazon)
--   SECTION 10 : Common Interview Questions (20)
--   SECTION 11 : End Summary
-- =============================================================================


-- =============================================================================
-- SECTION 2 : CREATE FRESH DATABASE
-- -----------------------------------------------------------------------------
-- Reason: Keep the ER Model schema independent from Day 1-5 modules so this
-- demo can be built, broken, and rebuilt live in class without touching or
-- risking any earlier database.
-- =============================================================================
DROP DATABASE IF EXISTS college_er_db;
CREATE DATABASE college_er_db;
USE college_er_db;


-- =============================================================================
-- SECTION 3 : VISUAL REFERENCE -- THE ER DIAGRAM
-- -----------------------------------------------------------------------------
-- Before a single CREATE TABLE statement is written, pull up the College ER
-- Diagram on-screen (Slide 8 of 01_SQL_Day6_Slides.pptx). That diagram --
-- with its Departments, Students, Courses, Enrollments and Instructors
-- entities, their Primary/Foreign Keys, and the relationship diamonds
-- connecting them -- IS the blueprint that Section 4 below is built from.
-- Nothing in Section 4 is invented at the keyboard; every table, column,
-- and constraint is traced directly off that picture.
--
-- How to read the diagram while following this script:
--   * Each green ENTITY box on the diagram    -> becomes one CREATE TABLE
--   * Each orange ATTRIBUTE oval               -> becomes one column
--   * An underlined attribute (Key Attribute)  -> becomes the PRIMARY KEY
--   * Each relationship diamond connecting
--     two entities                              -> becomes a FOREIGN KEY
--   * The M:N relationship (Students <-> Courses, via "enrolls in")
--                                                -> is exactly why the
--                                                   Enrollments junction
--                                                   table exists
--
-- Keep the diagram visible for Section 4 -- every CREATE TABLE statement
-- below is called out entity by entity, in the same order it appears on
-- the diagram (Departments first, since every other entity points back to
-- it, down to Enrollments last, since it points to two parents at once).
-- =============================================================================


-- =============================================================================
-- SECTION 4 : CREATE ENTITIES (TABLES)
-- -----------------------------------------------------------------------------
-- Creation order matters: a table can only reference a PRIMARY KEY that
-- already exists, so parent entities (Departments) are created first, then
-- the entities that reference them (Students, Courses, Instructors), and
-- finally the junction table (Enrollments) that references two parents at
-- once.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Entity: Departments  (parent entity -- referenced by Students, Courses,
--                        Instructors)
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    department_id      INT AUTO_INCREMENT PRIMARY KEY,
    department_name     VARCHAR(100) NOT NULL,
    office_location     VARCHAR(100)
);

-- Verify the schema MySQL actually created against the ER diagram above.
DESC departments;

-- -----------------------------------------------------------------------------
-- Entity: Students
-- Relationship: Department (1) ----------- (M) Students
--   -> department_id is a FOREIGN KEY referencing departments(department_id)
-- -----------------------------------------------------------------------------
CREATE TABLE students (
    student_id          INT AUTO_INCREMENT PRIMARY KEY,
    student_name         VARCHAR(100) NOT NULL,
    email                VARCHAR(100) UNIQUE,
    phone                VARCHAR(15),
    department_id        INT,
    CONSTRAINT fk_students_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Verify the schema MySQL actually created against the ER diagram above.
DESC students;

-- -----------------------------------------------------------------------------
-- Entity: Courses
-- Relationship: Department (1) ----------- (M) Courses
--   -> department_id is a FOREIGN KEY referencing departments(department_id)
-- -----------------------------------------------------------------------------
CREATE TABLE courses (
    course_id            INT AUTO_INCREMENT PRIMARY KEY,
    course_name           VARCHAR(100) NOT NULL,
    credits               INT,
    department_id         INT,
    CONSTRAINT fk_courses_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Verify the schema MySQL actually created against the ER diagram above.
DESC courses;

-- -----------------------------------------------------------------------------
-- Entity: Instructors
-- Relationship: Department (1) ----------- (M) Instructors
--   -> department_id is a FOREIGN KEY referencing departments(department_id)
-- -----------------------------------------------------------------------------
CREATE TABLE instructors (
    instructor_id         INT AUTO_INCREMENT PRIMARY KEY,
    instructor_name        VARCHAR(100) NOT NULL,
    department_id          INT,
    CONSTRAINT fk_instructors_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Verify the schema MySQL actually created against the ER diagram above.
DESC instructors;

-- -----------------------------------------------------------------------------
-- REVISION -- ER MODEL -> SQL MAPPING
-- -----------------------------------------------------------------------------
--   One last table to go. Before building it, recap how every ER concept
--   on the diagram becomes a SQL concept in this script -- this is exactly
--   what makes the Enrollments table below make sense:
--
--     Entity            -> Table            (Enrollment -> enrollments)
--     Attribute          -> Column            (enrollment_date, status)
--     Key Attribute        -> PRIMARY KEY       (enrollment_id)
--     Relationship            -> FOREIGN KEY      (student_id, course_id)
--     Many-to-Many              -> Junction Table   (enrollments itself)
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Junction Table: Enrollments
-- Relationship: Students (M) ----------- (N) Courses
--   A Student can enroll in MANY Courses, and a Course can have MANY
--   Students. A plain FOREIGN KEY cannot express a many-to-many link on its
--   own, so Enrollments exists purely to resolve that M:N relationship into
--   two clean one-to-many relationships:
--     Students (1) --- (M) Enrollments (M) --- (1) Courses
-- -----------------------------------------------------------------------------
CREATE TABLE enrollments (
    enrollment_id         INT AUTO_INCREMENT PRIMARY KEY,
    student_id             INT,
    course_id              INT,
    enrollment_date        DATE,
    status                 VARCHAR(20) DEFAULT 'Active',
    CONSTRAINT fk_enrollments_student
        FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_enrollments_course
        FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Verify the schema MySQL actually created against the ER diagram above.
DESC enrollments;


-- =============================================================================
-- SECTION 5 : INSERT SAMPLE DATA
-- -----------------------------------------------------------------------------
-- 3 Departments | 6 Students | 4 Courses | 3 Instructors | 8 Enrollments
-- Data is written so the class can visibly trace every relationship type.
-- =============================================================================

-- ---- Departments (3) --------------------------------------------------------
INSERT INTO departments (department_name, office_location) VALUES
('Computer Science',        'Block A - Room 201'),
('Information Technology',  'Block B - Room 105'),
('Mechanical Engineering',  'Block C - Room 310');

-- ---- Students (6) -- 2 students per department ------------------------------
INSERT INTO students (student_name, email, phone, department_id) VALUES
('Aarav Sharma',  'aarav.sharma@college.edu',  '9876543210', 1),
('Priya Nair',    'priya.nair@college.edu',    '9876543211', 1),
('Rohan Mehta',   'rohan.mehta@college.edu',   '9876543212', 2),
('Sneha Iyer',    'sneha.iyer@college.edu',    '9876543213', 2),
('Kabir Singh',   'kabir.singh@college.edu',   '9876543214', 3),
('Ananya Gupta',  'ananya.gupta@college.edu',  '9876543215', 3);

-- ---- Courses (4) --------------------------------------------------------
INSERT INTO courses (course_name, credits, department_id) VALUES
('Database Management Systems', 4, 1),
('Data Structures',              4, 1),
('Computer Networks',            3, 2),
('Thermodynamics',               3, 3);

-- ---- Instructors (3) -- 1 per department -------------------------------
INSERT INTO instructors (instructor_name, department_id) VALUES
('Dr. Neha Kapoor',   1),
('Prof. Arjun Verma', 2),
('Dr. Meera Joshi',   3);

-- ---- Enrollments (8) -- the M:N link between Students and Courses -------
-- NOTE: Aarav and Priya are both enrolled in BOTH "Database Management
-- Systems" AND "Data Structures" -- this is the clearest possible live
-- demonstration of a many-to-many relationship.
INSERT INTO enrollments (student_id, course_id, enrollment_date, status) VALUES
(1, 1, '2026-01-10', 'Active'),     -- Aarav      -> DBMS
(1, 2, '2026-01-10', 'Active'),     -- Aarav      -> Data Structures
(2, 1, '2026-01-11', 'Active'),     -- Priya      -> DBMS
(2, 2, '2026-01-11', 'Completed'),  -- Priya      -> Data Structures
(3, 3, '2026-01-12', 'Active'),     -- Rohan      -> Computer Networks
(4, 3, '2026-01-12', 'Active'),     -- Sneha      -> Computer Networks
(5, 4, '2026-01-13', 'Active'),     -- Kabir      -> Thermodynamics
(6, 4, '2026-01-13', 'Dropped');    -- Ananya     -> Thermodynamics


-- =============================================================================
-- SECTION 6 : UNDERSTAND RELATIONSHIPS (VERIFICATION QUERIES)
-- -----------------------------------------------------------------------------
-- Run each SELECT below one at a time in class and ask: "which table is the
-- (1) side, and which is the (N) side?"
-- =============================================================================

-- Relationship check: every department should show up once here, but many
-- times as a department_id inside students/courses/instructors -- that
-- repetition on the "many" side is exactly what 1:M looks like in real data.
SELECT * FROM departments;

-- Relationship check: department_id here is the FOREIGN KEY -- Students (M)
-- is the "many" side pointing back to Departments (1).
SELECT * FROM students;

-- Relationship check: same 1:M pattern as students, this time
-- Department (1) --- (M) Courses.
SELECT * FROM courses;

-- Relationship check: this is the junction table in action. Each row is one
-- Student-Course pairing. Notice student_id 1 and 2 each appear twice --
-- that is the M:N relationship between Students and Courses, resolved.
SELECT * FROM enrollments;

-- -----------------------------------------------------------------------------
-- BONUS LIVE DEMO (optional) -- join all four tables together so the class
-- can see the resolved M:N relationship read like a sentence: which student,
-- took which course, in which department, taught by which instructor.
-- -----------------------------------------------------------------------------
SELECT
    s.student_name,
    c.course_name,
    d.department_name,
    e.status
FROM enrollments e
JOIN students s     ON e.student_id = s.student_id
JOIN courses c      ON e.course_id = c.course_id
JOIN departments d  ON s.department_id = d.department_id
ORDER BY s.student_name, c.course_name;


-- =============================================================================
-- SECTION 7 : CARDINALITY DEMONSTRATION
-- -----------------------------------------------------------------------------
-- Cardinality answers one question: "how many records on ONE side can
-- connect to how many records on the OTHER side?"
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1 : 1   (concept only -- not modelled in this schema)
-- -----------------------------------------------------------------------------
--   Person (1)
--     │
--     │  has exactly one
--     ▼
--   Passport (1)
--
--   Example: one Person has exactly one Passport, and one Passport belongs
--   to exactly one Person. In our college schema this pattern would appear
--   if we split Students into students + student_profile (one row each,
--   e.g. storing a scanned ID photo) -- not needed here, so it stays a
--   concept-only example.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- 1 : M   (modelled by departments -> students)
-- -----------------------------------------------------------------------------
--   Departments (1)
--     │
--     │
--     ▼
--   Students (N)
--
--   One Department has MANY Students, but each Student belongs to exactly
--   ONE Department. Proof: run
--       SELECT department_id, COUNT(*) FROM students GROUP BY department_id;
--   and see more than one student per department_id.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- M : 1   (the same relationship, read from the "many" side)
-- -----------------------------------------------------------------------------
--   Students (N)
--     │
--     │
--     ▼
--   Departments (1)
--
--   1:M and M:1 are the SAME relationship -- only the direction you read it
--   from changes. "A Department has many Students" (1:M) is identical to
--   "Many Students belong to one Department" (M:1).
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- M : N   (modelled by students <-> enrollments <-> courses)
-- -----------------------------------------------------------------------------
--   Students (M)  ─────┐              ┌───── Courses (N)
--                       ▼              ▼
--                     Enrollments (junction table)
--
--   One Student can enroll in MANY Courses, AND one Course can have MANY
--   Students. Neither side can hold a single FOREIGN KEY to the other, so
--   the Enrollments junction table breaks the M:N link into two clean 1:M
--   relationships:
--       Students (1) --- (M) Enrollments (M) --- (1) Courses
--   Proof: run
--       SELECT student_id, COUNT(*) FROM enrollments GROUP BY student_id;
--   Aarav (1) and Priya (2) each show a count of 2.
-- -----------------------------------------------------------------------------


-- =============================================================================
-- SECTION 8 : CONVERT ER MODEL INTO RELATIONAL TABLES (CONCEPT MAP)
-- -----------------------------------------------------------------------------
-- This section is conceptual -- no new SQL is needed. Every ER concept maps
-- to exactly one relational (SQL) concept, and Sections 4-5 above are the
-- worked example of every row in this table.
--
--   ER CONCEPT              SQL EQUIVALENT
--   ----------------------  ----------------------------------------------
--   Entity                  Table               (e.g. Student -> students)
--   Attribute                Column              (e.g. Name -> student_name)
--   Key Attribute             PRIMARY KEY         (e.g. student_id)
--   Relationship               FOREIGN KEY         (e.g. department_id in
--                                                    students references
--                                                    departments)
--   M:N Relationship             Junction Table      (e.g. enrollments,
--                                                       resolving Students
--                                                       <-> Courses)
--
-- Rule of thumb for the class: if you can draw it on an ER diagram, you can
-- build it with just these four SQL ideas -- CREATE TABLE, PRIMARY KEY,
-- FOREIGN KEY, and (when needed) a junction table.
-- =============================================================================


-- =============================================================================
-- SECTION 9 : BUSINESS DESIGN ACTIVITY (NO SOLUTIONS)
-- -----------------------------------------------------------------------------
-- Classroom exercise. For EACH business requirement below, students must
-- identify, on paper or a whiteboard:
--     (a) Entities        (b) Attributes        (c) Relationships
--     (d) Cardinality for every relationship (1:1, 1:M, M:1, or M:N)
-- Do NOT write SQL yet -- this is a pure design exercise. No solutions are
-- provided here on purpose.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ACTIVITY 1 : Design a Library System
-- -----------------------------------------------------------------------------
--   A library issues books to members. Each book has an ISBN, title,
--   author, and number of copies. Each member has a membership ID, name,
--   and contact number. A member can borrow many books over time, and a
--   book can be borrowed by many different members over time. The library
--   also employs librarians, each assigned to one section (Fiction,
--   Science, History, etc.).
--
--   Identify: Entities | Attributes | Relationships | Cardinality
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- ACTIVITY 2 : Design a Hospital System
-- -----------------------------------------------------------------------------
--   A hospital has doctors and patients. A doctor can treat many patients,
--   and a patient can be treated by many doctors (across different
--   appointments). Each appointment has a date, time, and diagnosis. Every
--   doctor belongs to exactly one department (Cardiology, Orthopedics,
--   etc.), and every patient is assigned exactly one primary bed in exactly
--   one ward during their stay.
--
--   Identify: Entities | Attributes | Relationships | Cardinality
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- ACTIVITY 3 : Design an Amazon-style Orders System
-- -----------------------------------------------------------------------------
--   A customer can place many orders, but each order belongs to exactly one
--   customer. Each order can contain many products, and each product can
--   appear in many different orders (over time). Each product belongs to
--   exactly one category (Electronics, Books, Grocery, etc.), and every
--   order has exactly one delivery address.
--
--   Identify: Entities | Attributes | Relationships | Cardinality
-- -----------------------------------------------------------------------------


-- =============================================================================
-- SECTION 10 : COMMON INTERVIEW QUESTIONS (NO SOLUTIONS)
-- -----------------------------------------------------------------------------
-- 20 questions, grouped by difficulty. Answer out loud / on a whiteboard --
-- no solutions are written here on purpose.
-- =============================================================================

-- ---- FOUNDATION ---------------------------------------------------------
--   1. What is an ER Model, and why is it created before writing any SQL?
--   2. What is the difference between an Entity and an Attribute?
--   3. What is the difference between a Strong Entity and a Weak Entity?
--   4. What is Cardinality? Name its four types.
--   5. What is Participation (total vs. partial) in an ER relationship?
--   6. What is a Composite Attribute? Give a real-world example.
--   7. What is a Derived Attribute? Give a real-world example.

-- ---- MEDIUM ---------------------------------------------------------------
--   8. Why do we use a Foreign Key? What problem does it prevent?
--   9. Why is an Enrollment (junction) table required between Students and
--      Courses instead of a direct link?
--  10. What is the difference between a 1:M relationship and an M:N
--      relationship?
--  11. What is a Junction table, and how do you recognize when you need
--      one while designing an ER Model?
--  12. What is a Key Attribute, and how is it different from a Candidate
--      Key?
--  13. What is Referential Integrity, and how does a Foreign Key enforce
--      it?
--  14. Can a single table have more than one Foreign Key? Give an example
--      from this script.

-- ---- PLACEMENT --------------------------------------------------------
--  15. Convert a Hospital ER Model (Patients, Doctors, Appointments) into
--      relational tables.
--  16. Convert a Swiggy / Zomato-style food delivery ER Model into
--      relational tables -- where does the M:N relationship appear?
--  17. Design a Banking ER Model -- identify the entities, attributes, and
--      relationships between Customers and Accounts.
--  18. Why must database design happen BEFORE SQL is written?
--  19. What is the difference between a Conceptual Model and a Relational
--      (Logical) Model?
--  20. During requirement gathering, how do you decide whether a
--      relationship is 1:M or M:N?


-- =============================================================================
-- SECTION 11 : END SUMMARY
-- =============================================================================
-- SKILLS MASTERED
--
-- ✔ Database Design
-- ✔ ER Model
-- ✔ Entity
-- ✔ Attribute
-- ✔ Relationship
-- ✔ Cardinality
-- ✔ Foreign Keys
-- ✔ Junction Table
--
-- Next Module : SQL Normalization (1NF, 2NF, 3NF)
-- =============================================================================
