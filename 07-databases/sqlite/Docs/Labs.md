# Lab Book: Master SQLite — From Fundamentals to Production Systems

---

## Introduction

Welcome to the **Master SQLite Lab Book**! This book contains **all hands‑on exercises** for the entire course. Each lab is designed to reinforce the concepts taught in the lectures and to give you practical experience with SQLite.

**How to use this lab book:**
- Read the **Objective** and **Setup** before starting.
- Follow the **Step‑by‑Step Instructions** in order.
- Complete the **Verification** checks at the end of each lab.
- Record your observations, errors, and solutions in the space provided (or in your student workbook).

**Prerequisites:** You must have SQLite installed, a terminal/command prompt, and (for later labs) Python 3.8+ and DB Browser for SQLite.

---

## Table of Contents

### Part 0: Introduction
- Lab 0.1: Verify Installation and First Database

### Part 1: Foundations & Architecture
- Lab 1.1: CLI Essentials and Dot‑Commands
- Lab 1.2: EXPLAIN and EXPLAIN QUERY PLAN
- Lab 1.3: Database Internals with .dbinfo
- Lab 1.4: Locking Demo with Two Terminals
- Lab 1.5: Type Affinity Experiments
- Lab 1.6: ROWID vs. WITHOUT ROWID
- Lab 1.7: Create a Library Schema with Constraints

### Part 2: SQL Programming
- Lab 2.1: Customer Database CRUD
- Lab 2.2: Advanced Filtering with CASE and LIKE
- Lab 2.3: Joins – University Database
- Lab 2.4: Aggregations and Grouping
- Lab 2.5: Common Table Expressions (CTEs)
- Lab 2.6: Window Functions for Financial Reporting

### Part 3: Database Design
- Lab 3.1: Normalize a Denormalized Table
- Lab 3.2: Design a Complete Library Management System

### Part 4: Indexing & Optimization
- Lab 4.1: Create and Measure Indexes on 1M Rows
- Lab 4.2: Composite and Covering Indexes
- Lab 4.3: Query Planner – EXPLAIN QUERY PLAN
- Lab 4.4: PRAGMA Tuning and Bulk Loading

### Part 5: Transactions & Concurrency
- Lab 5.1: ACID Transactions – Bank Transfer
- Lab 5.2: Savepoints – Nested Transactions
- Lab 5.3: Rollback Journal vs. WAL
- Lab 5.4: Integrity Checks and Corruption Simulation

### Part 6: Advanced Features
- Lab 6.1: JSON Storage and Querying
- Lab 6.2: Indexing JSON with Generated Columns
- Lab 6.3: FTS5 – Build a Search Engine
- Lab 6.4: FTS5 Ranking and Snippets
- Lab 6.5: CSV Virtual Table
- Lab 6.6: Triggers – Audit Logging
- Lab 6.7: Soft Delete with INSTEAD OF Trigger
- Lab 6.8: FTS Sync Triggers

### Part 7: Programming with SQLite
- Lab 7.1: Python Contact Manager (CLI)
- Lab 7.2: Python – Row Factories and Custom Functions
- Lab 7.3: Flask REST API for Contacts
- Lab 7.4: FastAPI Async API
- Lab 7.5: Testing with :memory: Database

### Part 8: Security & Production
- Lab 8.1: SQL Injection Demo
- Lab 8.2: SQLCipher – Encrypted Database
- Lab 8.3: Backup Automation Script
- Lab 8.4: Maintenance Script (VACUUM, ANALYZE, Integrity)
- Lab 8.5: Dockerize a FastAPI App with SQLite

### Part 9: Real‑World Projects
- Project 1: Personal Finance Manager
- Project 2: Point of Sale (POS) System
- Project 3: Notes with Full‑Text Search
- Capstone: Task Management System

---

## Part 0: Introduction

### Lab 0.1: Verify Installation and First Database

**Objective:** Confirm SQLite is installed, create your first database, and run a basic query.

**Setup:** Open a terminal or command prompt.

**Step 1: Check version**
```bash
sqlite3 --version
```
Expected output: Version number (e.g., `3.42.0 2023-05-16 12:36:15`). If not found, follow installation instructions from Module 1.

**Step 2: Create a database file and start the shell**
```bash
sqlite3 first.db
```
You should see the SQLite prompt: `sqlite>`.

**Step 3: Create a table and insert a row**
```sql
CREATE TABLE greetings (message TEXT);
INSERT INTO greetings (message) VALUES ('Hello, SQLite!');
SELECT * FROM greetings;
```
Expected output: `Hello, SQLite!`

**Step 4: Exit the shell**
```sql
.exit
```

**Verification:** Run a query directly from the command line:
```bash
sqlite3 first.db "SELECT * FROM greetings"
```
Expected output: `Hello, SQLite!`

---

## Part 1: Foundations & Architecture

### Lab 1.1: CLI Essentials and Dot‑Commands

**Objective:** Practice essential dot‑commands for inspecting databases.

**Setup:** Open `first.db` from the previous lab.

**Step 1: Open the database**
```bash
sqlite3 first.db
```

**Step 2: Show all tables**
```sql
.tables
```
Expected: `greetings`

**Step 3: Show schema**
```sql
.schema greetings
```
Expected: `CREATE TABLE greetings (message TEXT);`

**Step 4: Dump the table**
```sql
.dump greetings
```
Expected: SQL statements to recreate the table and its data.

**Step 5: Turn on headers and column mode**
```sql
.headers on
.mode column
SELECT * FROM greetings;
```
Now output is formatted with a header.

**Step 6: Change output to CSV and save**
```sql
.mode csv
.once output.csv
SELECT * FROM greetings;
```
Then exit and check `output.csv` in your file system.

**Step 7: Import a CSV**
Create a file `data.csv` with:
```csv
id,name
1,Alice
2,Bob
```
Then in SQLite:
```sql
.mode csv
.import data.csv test
SELECT * FROM test;
```

**Verification:** All commands executed without errors; `output.csv` contains the query results.

---

### Lab 1.2: EXPLAIN and EXPLAIN QUERY PLAN

**Objective:** Understand the VDBE bytecode and query execution plan.

**Setup:** Use `first.db` or create a new database with a simple table.

**Step 1: Create sample table and insert data**
```sql
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER);
INSERT INTO users (name, age) VALUES ('Alice', 30), ('Bob', 25), ('Carol', 28);
```

**Step 2: Run EXPLAIN**
```sql
EXPLAIN SELECT * FROM users WHERE age = 25;
```
Observe the bytecode instructions (opcodes like `OpenRead`, `SeekLE`, `Column`, `ResultRow`). Don't worry about understanding every instruction; note that the query is transformed into low‑level operations.

**Step 3: Run EXPLAIN QUERY PLAN**
```sql
EXPLAIN QUERY PLAN SELECT * FROM users WHERE age = 25;
```
Expected: `SCAN users` (since there is no index on `age`). This indicates a full table scan.

**Step 4: Create an index on `age`**
```sql
CREATE INDEX idx_users_age ON users(age);
```
Re‑run `EXPLAIN QUERY PLAN`; now you should see `SEARCH users USING INDEX idx_users_age`.

**Step 5: Add a covering index**
```sql
CREATE INDEX idx_users_age_name ON users(age, name);
EXPLAIN QUERY PLAN SELECT name FROM users WHERE age = 25;
```
You should see `USING COVERING INDEX idx_users_age_name`.

**Verification:** The query plan changes from `SCAN` to `SEARCH` after indexing.

---

### Lab 1.3: Database Internals with .dbinfo

**Objective:** Explore the database file header and page layout.

**Setup:** Use any database file (e.g., `first.db`).

**Step 1: Open the database and run `.dbinfo`**
```sql
.dbinfo
```
You'll see information like:
```
database page size:  4096
write format:        1
read format:         1
number of tables:    2
```
Record the page size and number of tables.

**Step 2: Use DB Browser for SQLite (GUI)**
Open `first.db` in DB Browser. Go to **Database Structure** → right‑click on a table → select **Show DB Info**. Compare with the CLI output.

**Step 3: Check page count**
```sql
PRAGMA page_count;
PRAGMA freelist_count;
```
These show the total pages and free pages.

**Verification:** The page size is typically 4096; the total page count grows with data.

---

### Lab 1.4: Locking Demo with Two Terminals

**Objective:** Observe SQLite's locking behaviour in rollback mode.

**Setup:** Open two terminal windows, both in the same directory.

**Step 1: In Terminal 1, start a transaction and hold a SHARED lock**
```bash
sqlite3 first.db
BEGIN;
SELECT * FROM greetings;
```

**Step 2: In Terminal 2, try to write**
```bash
sqlite3 first.db
UPDATE greetings SET message = 'Hello again';
```
You will notice the command hangs (it's waiting for the lock to be released). This demonstrates that writers are blocked while a reader holds a SHARED lock (though actually in rollback mode, readers can hold SHARED, and a writer needs an EXCLUSIVE lock, so it waits).

**Step 3: In Terminal 1, commit**
```sql
COMMIT;
```
Now Terminal 2's update proceeds.

**Step 4: Repeat the experiment after enabling WAL**
In both terminals, enable WAL:
```sql
PRAGMA journal_mode = WAL;
```
Repeat the same steps: in Terminal 1 start a transaction and `SELECT`, in Terminal 2 try to `UPDATE`. This time the update should **not** block (WAL allows concurrent reads/writes).

**Verification:** In rollback mode, writers block readers; in WAL mode, they do not.

---

### Lab 1.5: Type Affinity Experiments

**Objective:** See how SQLite converts values based on column affinity.

**Setup:** Create a new database `types.db`.

**Step 1: Create a table with different affinities**
```sql
CREATE TABLE test (
    id INTEGER PRIMARY KEY,
    a_int INTEGER,
    a_text TEXT,
    a_real REAL,
    a_blob BLOB,
    a_numeric NUMERIC
);
```

**Step 2: Insert values that "break" affinities**
```sql
INSERT INTO test (a_int, a_text, a_real, a_blob, a_numeric)
VALUES ('123', 456, '78.9', 'binary data', '99.9');
```

**Step 3: Query and check types**
```sql
SELECT typeof(a_int), typeof(a_text), typeof(a_real), typeof(a_blob), typeof(a_numeric) FROM test;
```
Expected: `integer`, `text`, `real`, `blob`, `real` (or `numeric` possibly stored as real).

**Step 4: Insert a text into an integer column**
```sql
INSERT INTO test (a_int) VALUES ('hello');
SELECT typeof(a_int) FROM test WHERE a_int = 'hello';
```
Result: `text`. Affinity did not enforce the type.

**Step 5: Use `CAST` to force conversion**
```sql
SELECT CAST('123' AS INTEGER) + 1;  -- returns 124
```
**Verification:** The `typeof()` results show that SQLite stores values according to their actual type, not the column's declared affinity.

---

### Lab 1.6: ROWID vs. WITHOUT ROWID

**Objective:** Compare storage and performance of `ROWID` and `WITHOUT ROWID` tables.

**Setup:** Create a new database `rowid_test.db`.

**Step 1: Create two tables**
```sql
CREATE TABLE t1 (id INTEGER PRIMARY KEY, name TEXT);          -- default ROWID
CREATE TABLE t2 (id TEXT PRIMARY KEY, name TEXT) WITHOUT ROWID;
```

**Step 2: Insert 10,000 rows into each**
```sql
-- For t1
INSERT INTO t1 (name) SELECT 'name' || value FROM generate_series(1, 10000);
-- For t2
INSERT INTO t2 (id, name) SELECT printf('id%05d', value), 'name' || value FROM generate_series(1, 10000);
```

**Step 3: Query by primary key**
```sql
-- Using ROWID alias (t1)
SELECT * FROM t1 WHERE id = 5000;
-- Using explicit primary key (t2)
SELECT * FROM t2 WHERE id = 'id05000';
```
Both should be fast.

**Step 4: Check file size**
Run `.dbinfo` or check the file size with `ls -l`. `t2` may be larger because the primary key is stored as part of the B‑Tree key (string).

**Step 5: Query by non‑key column**
If you add an index on `name` and then query, the performance difference is negligible. The key difference is when the primary key is not an integer; `WITHOUT ROWID` avoids an extra index.

**Verification:** Both tables work correctly; `WITHOUT ROWID` is useful for string or composite primary keys.

---

### Lab 1.7: Create a Library Schema with Constraints

**Objective:** Design and implement a normalized library schema with all constraint types.

**Setup:** New database `library.db`.

**Step 1: Enable foreign keys**
```sql
PRAGMA foreign_keys = ON;
```

**Step 2: Create tables**
Write the complete schema:
- `categories` (category_id, name)
- `books` (book_id, title, isbn UNIQUE, year, category_id FK)
- `authors` (author_id, first_name, last_name, birth_year CHECK)
- `book_authors` (book_id, author_id, PRIMARY KEY composite, FKs)
- `members` (member_id, first_name, last_name, email UNIQUE, membership_date DEFAULT)
- `loans` (loan_id, member_id FK, copy_id FK, loan_date, due_date, return_date)

Add `CHECK` constraints (e.g., year > 0, birth_year > 1900).

**Step 3: Insert sample data**
Add at least 2 categories, 5 books, 3 authors, 3 members, and some loans.

**Step 4: Test constraints**
Try inserting a book with a duplicate ISBN; it should fail.
Try inserting a loan with a non‑existent member; it should fail due to foreign key.
Try inserting an author with birth_year < 1900; CHECK should fail.

**Step 5: Query with joins**
List all books with their authors and categories.
List all active loans (return_date IS NULL) with member names and book titles.

**Verification:** All INSERT and SELECT statements work; constraints are enforced.

---

## Part 2: SQL Programming Essentials

### Lab 2.1: Customer Database CRUD

**Objective:** Implement full CRUD on a customer‑order schema.

**Setup:** Use the schema from Module 5.

**Step 1: Create tables**
```sql
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    order_date TEXT DEFAULT (date('now')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

**Step 2: Insert customers**
```sql
INSERT INTO customers (name, email) VALUES ('Alice', 'alice@e.com'), ('Bob', 'bob@e.com');
```

**Step 3: Insert orders**
```sql
INSERT INTO orders (customer_id, amount) VALUES (1, 100), (1, 200), (2, 150);
```

**Step 4: SELECT with sorting and limit**
```sql
SELECT * FROM orders ORDER BY amount DESC LIMIT 2;
```

**Step 5: UPDATE a customer's email**
```sql
UPDATE customers SET email = 'alice@example.com' WHERE customer_id = 1;
```

**Step 6: DELETE an order**
```sql
DELETE FROM orders WHERE order_id = 2;
```

**Step 7: Verify using SELECT**
Check that data is as expected.

---

### Lab 2.2: Advanced Filtering with CASE and LIKE

**Objective:** Use `CASE`, `LIKE`, `GLOB`, `BETWEEN`, `IN`.

**Setup:** Use the `customers` and `orders` tables.

**Step 1: Use `LIKE` to find customers whose name starts with 'A'**
```sql
SELECT * FROM customers WHERE name LIKE 'A%';
```

**Step 2: Use `GLOB` for case‑sensitive pattern**
```sql
SELECT * FROM customers WHERE name GLOB 'a*';  -- may return none if case mismatch
```

**Step 3: Use `BETWEEN` for amount range**
```sql
SELECT * FROM orders WHERE amount BETWEEN 100 AND 200;
```

**Step 4: Use `IN` for specific amounts**
```sql
SELECT * FROM orders WHERE amount IN (100, 150);
```

**Step 5: Use `CASE` to label orders**
```sql
SELECT order_id, amount,
       CASE
           WHEN amount < 150 THEN 'Low'
           WHEN amount BETWEEN 150 AND 300 THEN 'Medium'
           ELSE 'High'
       END AS category
FROM orders;
```

**Step 6: Handle NULL**
Add a column `customer_id` that can be NULL and test `IS NULL` and `IS NOT NULL`.

---

### Lab 2.3: Joins – University Database

**Objective:** Implement joins for a university database.

**Setup:**
```sql
CREATE TABLE students (student_id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE courses (course_id INTEGER PRIMARY KEY, title TEXT, credits INTEGER);
CREATE TABLE enrollments (student_id INTEGER, course_id INTEGER, grade TEXT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students,
    FOREIGN KEY (course_id) REFERENCES courses);
```

**Step 1: Insert sample data**
- 3 students, 4 courses, 6 enrollments.

**Step 2: INNER JOIN to list enrollments with student and course names**
```sql
SELECT s.name, c.title, e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;
```

**Step 3: LEFT JOIN to show all students and their enrollments (including those with none)**
```sql
SELECT s.name, c.title
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id;
```

**Step 4: Self‑join example (if you add a "prerequisite" column to courses)**
If you add a `prereq_id` field, write a self‑join to list courses and their prerequisites.

---

### Lab 2.4: Aggregations and Grouping

**Objective:** Use aggregate functions, GROUP BY, HAVING.

**Step 1: Count all students**
```sql
SELECT COUNT(*) FROM students;
```

**Step 2: Average credits per course**
```sql
SELECT AVG(credits) FROM courses;
```

**Step 3: Count enrollments per course, with HAVING to show only courses with > 1 enrollment**
```sql
SELECT c.title, COUNT(e.student_id) AS enrolled
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id
HAVING COUNT(e.student_id) > 1;
```

---

### Lab 2.5: Common Table Expressions (CTEs)

**Objective:** Use `WITH` to simplify complex queries.

**Step 1: Create a CTE that calculates the average order amount per customer**
```sql
WITH avg_orders AS (
    SELECT customer_id, AVG(amount) AS avg_amt
    FROM orders
    GROUP BY customer_id
)
SELECT c.name, a.avg_amt
FROM customers c
JOIN avg_orders a ON c.customer_id = a.customer_id;
```

**Step 2: Recursive CTE – generate numbers 1 to 10**
```sql
WITH RECURSIVE nums(n) AS (
    SELECT 1
    UNION ALL
    SELECT n+1 FROM nums WHERE n < 10
)
SELECT n FROM nums;
```

---

### Lab 2.6: Window Functions for Financial Reporting

**Objective:** Use `ROW_NUMBER`, `RANK`, `SUM OVER`.

**Step 1: Rank orders by amount**
```sql
SELECT order_id, amount,
       RANK() OVER (ORDER BY amount DESC) AS rank
FROM orders;
```

**Step 2: Running total of orders by date**
```sql
SELECT order_id, amount, order_date,
       SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM orders;
```

**Step 3: Partition by customer – show each customer's order rank**
```sql
SELECT customer_id, order_id, amount,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY amount DESC) AS rank_in_customer
FROM orders;
```

---

## Part 3: Database Design

### Lab 3.1: Normalize a Denormalized Table

**Objective:** Take a denormalized order table and decompose it into 3NF.

**Given table:** `order_details` (order_id, customer_name, customer_email, order_date, product_id, product_name, product_price, quantity)

**Step 1:** Identify functional dependencies:
- order_id → customer_name, customer_email, order_date
- product_id → product_name, product_price
- order_id, product_id → quantity

**Step 2:** Decompose into:
- `orders` (order_id, customer_id, order_date)
- `customers` (customer_id, customer_name, customer_email)
- `products` (product_id, product_name, product_price)
- `order_items` (order_id, product_id, quantity)

Write the CREATE TABLE statements and insert sample data.

**Step 3:** Write a query to reconstruct the original report using joins.
```sql
SELECT o.order_id, c.customer_name, c.customer_email, o.order_date,
       p.product_name, p.product_price, oi.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
```

---

### Lab 3.2: Design a Complete Library Management System

**Objective:** Design and implement a full library schema from requirements.

**Requirements:**
- Books have title, ISBN (unique), year, category.
- Authors have name.
- Books can have multiple authors (M:N).
- Members have name, email (unique).
- Branches have name, address.
- Copies belong to a book and a branch; each copy has a copy number (unique per branch) and status (available, loaned, damaged, lost).
- Loans link a copy, a member, loan_date, expected_return_date (14 days later), actual_return_date.
- A member cannot have more than 5 loans at a time.
- When a book is loaned, copy status changes to 'loaned'; when returned, status changes back.
- Fine: $0.50 per day overdue.

**Step 1:** Write all CREATE TABLE statements with constraints, foreign keys, and indexes.

**Step 2:** Write triggers:
- `limit_borrows` – before insert on loans, check count of active loans for that member, abort if ≥5.
- `update_copy_status_on_loan` – after insert on loans, set copy status to 'loaned'.
- `update_return` – after update of actual_return_date, set copy status to 'available' and calculate fine.

**Step 3:** Insert sample data and test the triggers.

**Step 4:** Write queries:
- List all currently loaned books with member and due date.
- List overdue books.
- Most popular books (by loan count).

**Verification:** All triggers work; constraints are enforced.

---

## Part 4: Indexing & Optimization

### Lab 4.1: Create and Measure Indexes on 1M Rows

**Objective:** Experience the performance impact of indexes.

**Setup:** New database `perf.db`. Enable `.timer on` in the CLI.

**Step 1: Create a users table**
```sql
CREATE TABLE users (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, age INTEGER, city TEXT);
```

**Step 2: Insert 1,000,000 rows**
Use `generate_series` (or recursive CTE):
```sql
INSERT INTO users (first_name, last_name, age, city)
SELECT 'fn' || value, 'ln' || value, (value % 80) + 18,
       CASE (value % 5) WHEN 0 THEN 'NY' WHEN 1 THEN 'LA' WHEN 2 THEN 'CHI' WHEN 3 THEN 'HOU' ELSE 'PHX' END
FROM generate_series(1, 1000000);
```
*(If `generate_series` not available, use `WITH RECURSIVE cnt(x) AS (SELECT 1 UNION ALL SELECT x+1 FROM cnt WHERE x<1000000)` and insert from that.)*

**Step 3: Measure a query without index**
```sql
SELECT * FROM users WHERE last_name = 'ln500000';
```
Note the time.

**Step 4: Create an index on last_name**
```sql
CREATE INDEX idx_users_last_name ON users(last_name);
```

**Step 5: Re‑run the query and note the time.**
It should be dramatically faster.

**Step 6: Use EXPLAIN QUERY PLAN to confirm index usage.**
```sql
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'ln500000';
```
Expected: `SEARCH users USING INDEX idx_users_last_name`.

---

### Lab 4.2: Composite and Covering Indexes

**Objective:** Understand composite index ordering and covering indexes.

**Step 1: Create a composite index on `(last_name, first_name)`**
```sql
CREATE INDEX idx_last_first ON users(last_name, first_name);
```

**Step 2: Test queries that use the index**
- `WHERE last_name = 'ln500000'` – uses the index.
- `WHERE last_name = 'ln500000' AND first_name = 'fn500000'` – uses index.
- `WHERE first_name = 'fn500000'` – **does not use index** (left‑most prefix rule).

**Step 3: Create a covering index**
```sql
CREATE INDEX idx_cover ON users(last_name, first_name, age);
```

**Step 4: Query that only selects columns from the index**
```sql
SELECT last_name, first_name, age FROM users WHERE last_name = 'ln500000';
```
Check `EXPLAIN QUERY PLAN` – it should say `USING COVERING INDEX idx_cover`.

---

### Lab 4.3: Query Planner – EXPLAIN QUERY PLAN

**Objective:** Read and interpret execution plans.

**Step 1: Run EXPLAIN QUERY PLAN on various queries and identify scan types.**
- `SELECT * FROM users WHERE age = 30;` – may scan (if no index on age).
- `SELECT * FROM users WHERE last_name LIKE 'ln5%';` – index may be used if pattern not leading wildcard.
- `SELECT * FROM users WHERE city = 'NY';` – unless indexed, full scan.

**Step 2: Run ANALYZE**
```sql
ANALYZE;
```
Then re‑run some `EXPLAIN QUERY PLAN` statements; the planner might change choices.

**Step 3: Force an index with `INDEXED BY`**
```sql
SELECT * FROM users INDEXED BY idx_users_last_name WHERE last_name = 'ln500000';
```

---

### Lab 4.4: PRAGMA Tuning and Bulk Loading

**Objective:** Tune performance with PRAGMAs and measure bulk insert speed.

**Step 1: Check current settings**
```sql
PRAGMA cache_size;
PRAGMA journal_mode;
PRAGMA synchronous;
```

**Step 2: Set cache size to 20000**
```sql
PRAGMA cache_size = 20000;
```

**Step 3: Insert 100,000 rows with and without a transaction**
- **Without transaction:** insert 100k rows individually (measure time).
- **With transaction:** wrap the inserts in `BEGIN;` and `COMMIT;` (measure time). Compare.

**Step 4: Temporarily set `synchronous = OFF` and `journal_mode = OFF`**
Then run the bulk insert again; it will be faster but less safe.

**Step 5: Restore safe settings**
```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
```

---

## Part 5: Transactions & Concurrency

### Lab 5.1: ACID Transactions – Bank Transfer

**Objective:** Demonstrate atomicity with a money transfer.

**Setup:** Create an `accounts` table with CHECK balance >=0.

```sql
CREATE TABLE accounts (id INTEGER PRIMARY KEY, owner TEXT, balance REAL CHECK (balance >=0));
INSERT INTO accounts (owner, balance) VALUES ('Alice', 1000), ('Bob', 500);
```

**Step 1: Transfer $200 from Alice to Bob without transaction**
```sql
UPDATE accounts SET balance = balance - 200 WHERE id = 1;
UPDATE accounts SET balance = balance + 200 WHERE id = 2;
```
If the second update fails (e.g., constraint violation), money is lost.

**Step 2: Transfer using transaction**
```sql
BEGIN;
UPDATE accounts SET balance = balance - 200 WHERE id = 1;
UPDATE accounts SET balance = balance + 200 WHERE id = 2;
COMMIT;
```
If any error occurs, you can `ROLLBACK`.

**Step 3: Test rollback**
```sql
BEGIN;
UPDATE accounts SET balance = balance - 1000 WHERE id = 1;  -- violates CHECK
ROLLBACK;
```
Balance remains unchanged.

**Step 4: Use savepoints**
```sql
BEGIN;
UPDATE accounts SET balance = balance + 50 WHERE id = 1;
SAVEPOINT sp1;
UPDATE accounts SET balance = balance - 200 WHERE id = 2; -- error if insufficient
ROLLBACK TO sp1;
-- now continue
COMMIT;
```

---

### Lab 5.2: Savepoints – Nested Transactions

**Objective:** Practice savepoint usage.

**Step 1:** Create a table `logs` (id, message). Insert a few rows.

**Step 2:** Start a transaction, insert a row, set a savepoint, insert another row, then rollback to the savepoint.
Check that only the first insert remains.

**Step 3:** Release the savepoint and commit.

---

### Lab 5.3: Rollback Journal vs. WAL

**Objective:** Compare performance and concurrency.

**Step 1:** Enable rollback journal (DELETE mode) by default.
```sql
PRAGMA journal_mode = DELETE;
```

**Step 2:** Insert 50,000 rows and time it.
```sql
.timer on
BEGIN;
INSERT INTO t (data) SELECT 'data' FROM generate_series(1,50000);
COMMIT;
```

**Step 3:** Enable WAL and repeat.
```sql
PRAGMA journal_mode = WAL;
BEGIN;
INSERT INTO t (data) SELECT 'data' FROM generate_series(50001,100000);
COMMIT;
```

**Step 4:** Concurrency test: in two terminals, start a write in one, and a read in the other.
In WAL, the read should not block.

---

### Lab 5.4: Integrity Checks and Corruption Simulation

**Objective:** Use integrity checks and simulate recovery.

**Step 1:** Run `PRAGMA integrity_check;` on a healthy database – should return 'ok'.

**Step 2:** Create a foreign key violation (insert a child row without parent) and run `PRAGMA foreign_key_check;` to list violations.

**Step 3:** Simulate corruption:
- Exit SQLite.
- Append garbage to the database file: `echo "garbage" >> mydb.db`
- Open the database and run `PRAGMA integrity_check;` – expect errors.
- Try to recover using `.dump` and import into a new database.

---

## Part 6: Advanced Features

### Lab 6.1: JSON Storage and Querying

**Objective:** Use JSON1 functions.

**Setup:**
```sql
CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, attributes TEXT);
INSERT INTO products (name, attributes) VALUES
    ('Laptop', '{"brand":"Dell","specs":{"ram":16,"ssd":512},"in_stock":true}'),
    ('Phone', '{"brand":"Apple","specs":{"storage":128},"in_stock":false}');
```

**Step 1:** Extract brand for all products.
```sql
SELECT name, json_extract(attributes, '$.brand') AS brand FROM products;
```

**Step 2:** Use `->>` shorthand.
```sql
SELECT name, attributes->>'$.brand' FROM products;
```

**Step 3:** Filter by in_stock.
```sql
SELECT name FROM products WHERE attributes->>'$.in_stock' = 'true';
```

**Step 4:** Update JSON – add a warranty field.
```sql
UPDATE products SET attributes = json_set(attributes, '$.warranty', '2 years') WHERE id = 1;
```

**Step 5:** Remove a field.
```sql
UPDATE products SET attributes = json_remove(attributes, '$.in_stock') WHERE id = 2;
```

**Step 6:** Use `json_group_array` to aggregate.
```sql
SELECT json_group_array(name) FROM products;
```

---

### Lab 6.2: Indexing JSON with Generated Columns

**Objective:** Index JSON fields for performance.

**Step 1:** Add a generated column for `brand`.
```sql
ALTER TABLE products ADD COLUMN brand TEXT GENERATED ALWAYS AS (attributes->>'$.brand') STORED;
```

**Step 2:** Create an index on that column.
```sql
CREATE INDEX idx_products_brand ON products(brand);
```

**Step 3:** Run a query filtering by brand and verify index usage with EXPLAIN QUERY PLAN.
```sql
EXPLAIN QUERY PLAN SELECT * FROM products WHERE brand = 'Dell';
```

---

### Lab 6.3: FTS5 – Build a Search Engine

**Objective:** Create an FTS5 table and run basic searches.

**Setup:**
```sql
CREATE VIRTUAL TABLE docs_fts USING fts5(title, content);
INSERT INTO docs_fts (title, content) VALUES
    ('SQLite Tutorial', 'SQLite is a lightweight database.'),
    ('Advanced SQLite', 'Learn about JSON, FTS, and virtual tables.'),
    ('Performance Tuning', 'Indexing and query optimization make SQLite fast.');
```

**Step 1:** Search for "SQLite".
```sql
SELECT * FROM docs_fts WHERE docs_fts MATCH 'SQLite';
```

**Step 2:** Phrase search.
```sql
SELECT * FROM docs_fts WHERE docs_fts MATCH '"virtual tables"';
```

**Step 3:** Prefix search.
```sql
SELECT * FROM docs_fts WHERE docs_fts MATCH 'opti*';
```

**Step 4:** Boolean AND.
```sql
SELECT * FROM docs_fts WHERE docs_fts MATCH 'SQLite AND FTS';
```

**Step 5:** NEAR.
```sql
SELECT * FROM docs_fts WHERE docs_fts MATCH 'SQLite NEAR/5 database';
```

---

### Lab 6.4: FTS5 Ranking and Snippets

**Objective:** Use `bm25()` and `snippet()`.

**Step 1:** Rank results by relevance.
```sql
SELECT title, bm25(docs_fts) AS rank
FROM docs_fts
WHERE docs_fts MATCH 'SQLite'
ORDER BY rank;
```

**Step 2:** Display snippets with highlighting.
```sql
SELECT title, snippet(docs_fts, 1, '<b>', '</b>', '...', 30) AS excerpt
FROM docs_fts
WHERE docs_fts MATCH 'SQLite';
```

---

### Lab 6.5: CSV Virtual Table

**Objective:** Query a CSV file as a table.

**Prerequisite:** CSV extension loaded. If not, use the CLI's `.import` as fallback.

**Step 1:** Create a CSV file `employees.csv` with:
```
id,name,department
1,Alice,Engineering
2,Bob,Marketing
```

**Step 2:** In SQLite, load the CSV extension (if available) and create a virtual table:
```sql
.load /path/to/csv
CREATE VIRTUAL TABLE emp_csv USING csv(filename='employees.csv');
SELECT * FROM emp_csv;
```
If the extension is not available, use:
```sql
.mode csv
.import employees.csv employees
```
and then query the `employees` table.

---

### Lab 6.6: Triggers – Audit Logging

**Objective:** Log changes to a table.

**Setup:**
```sql
CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, price REAL);
CREATE TABLE audit_log (id INTEGER PRIMARY KEY, table_name TEXT, action TEXT, row_id INTEGER, old_data TEXT, new_data TEXT, changed_at TEXT);
```

**Step 1:** Create an AFTER UPDATE trigger.
```sql
CREATE TRIGGER products_audit_update
AFTER UPDATE ON products
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, old_data, new_data)
    VALUES ('products', 'UPDATE', OLD.id,
            json_object('name', OLD.name, 'price', OLD.price),
            json_object('name', NEW.name, 'price', NEW.price));
END;
```

**Step 2:** Test by updating a product and checking the audit log.

---

### Lab 6.7: Soft Delete with INSTEAD OF Trigger

**Objective:** Implement soft delete.

**Step 1:** Add a `deleted` column to `products`.
```sql
ALTER TABLE products ADD COLUMN deleted INTEGER DEFAULT 0;
```

**Step 2:** Create a view that excludes deleted rows.
```sql
CREATE VIEW active_products AS SELECT * FROM products WHERE deleted = 0;
```

**Step 3:** Create an `INSTEAD OF DELETE` trigger on the view.
```sql
CREATE TRIGGER soft_delete
INSTEAD OF DELETE ON active_products
BEGIN
    UPDATE products SET deleted = 1 WHERE id = OLD.id;
END;
```

**Step 4:** Delete from the view and verify the row is marked deleted.

---

### Lab 6.8: FTS Sync Triggers

**Objective:** Keep an FTS table in sync with a base table.

**Setup:** Create a `docs` table and an FTS table `docs_fts` with `content=docs`.

```sql
CREATE TABLE docs (id INTEGER PRIMARY KEY, title TEXT, content TEXT);
CREATE VIRTUAL TABLE docs_fts USING fts5(title, content, content=docs);
```

**Step 1:** Create triggers for INSERT, UPDATE, DELETE.
```sql
CREATE TRIGGER docs_ai AFTER INSERT ON docs
BEGIN
    INSERT INTO docs_fts(rowid, title, content) VALUES (NEW.id, NEW.title, NEW.content);
END;

CREATE TRIGGER docs_au AFTER UPDATE ON docs
BEGIN
    UPDATE docs_fts SET title = NEW.title, content = NEW.content WHERE rowid = NEW.id;
END;

CREATE TRIGGER docs_ad AFTER DELETE ON docs
BEGIN
    DELETE FROM docs_fts WHERE rowid = OLD.id;
END;
```

**Step 2:** Insert a row into `docs` and verify it appears in `docs_fts`.

---

## Part 7: Programming with SQLite

### Lab 7.1: Python Contact Manager (CLI)

**Objective:** Write a full Python CLI for contacts.

**Step 1:** Write functions to:
- `init_db()` – create `contacts` table (id, name, email, phone)
- `add_contact(name, email, phone)`
- `list_contacts()` – returns list of dicts
- `search_contacts(query)` – search across name/email
- `update_contact(id, name, email, phone)`
- `delete_contact(id)`

**Step 2:** Use `contextlib.contextmanager` for connection.
**Step 3:** Use `row_factory = sqlite3.Row`.
**Step 4:** Implement a simple CLI menu.

*Sample code structure:*
```python
import sqlite3
from contextlib import contextmanager

DB = 'contacts.db'

@contextmanager
def get_conn():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    with get_conn() as conn:
        conn.execute('CREATE TABLE IF NOT EXISTS contacts ...')
        conn.commit()

# ... other functions

if __name__ == '__main__':
    init_db()
    while True:
        print('1. Add\n2. List\n...')
        # handle input
```

---

### Lab 7.2: Python – Row Factories and Custom Functions

**Objective:** Use `row_factory` and register a custom function.

**Step 1:** Set `row_factory = sqlite3.Row` and query; access columns by name.

**Step 2:** Register a function that uppercases a string:
```python
conn.create_function('myupper', 1, lambda s: s.upper())
```
Then use it in SQL: `SELECT myupper(name) FROM contacts;`

**Step 3:** Register a custom aggregate to concatenate names:
```python
class Concat:
    def __init__(self):
        self.values = []
    def step(self, value):
        self.values.append(value)
    def finalize(self):
        return ','.join(self.values)

conn.create_aggregate('concat_names', 1, Concat)
```

---

### Lab 7.3: Flask REST API for Contacts

**Objective:** Build a Flask API with SQLite.

**Step 1:** Create a Flask app with endpoints:
- `GET /contacts` – list all
- `POST /contacts` – add (JSON body)
- `GET /contacts/<id>` – get one
- `PUT /contacts/<id>` – update
- `DELETE /contacts/<id>` – delete

**Step 2:** Use `@app.teardown_appcontext` to close the connection.
**Step 3:** Use parameterized queries.

---

### Lab 7.4: FastAPI Async API

**Objective:** Use `aiosqlite` for async FastAPI.

**Step 1:** Install `fastapi`, `uvicorn`, `aiosqlite`.
**Step 2:** Write endpoints similar to Flask but with `async def` and `aiosqlite.connect`.

**Step 3:** Add a health check that queries the database.

---

### Lab 7.5: Testing with :memory: Database

**Objective:** Write unit tests using an in‑memory database.

**Step 1:** Write a test that creates a temporary database in memory.
```python
import sqlite3
def test_add_contact():
    conn = sqlite3.connect(':memory:')
    conn.execute('CREATE TABLE contacts (id INTEGER PRIMARY KEY, name TEXT)')
    # test your functions
```
**Step 2:** Use pytest to run tests.

---

## Part 8: Security & Production

### Lab 8.1: SQL Injection Demo

**Objective:** Demonstrate SQL injection vulnerability.

**Step 1:** Write a Python script that takes user input and builds a query via f‑string:
```python
name = input("Enter name: ")
cursor.execute(f"SELECT * FROM users WHERE name = '{name}'")
```
**Step 2:** Input `' OR '1'='1` and see all rows.

**Step 3:** Fix by using parameterized queries.

---

### Lab 8.2: SQLCipher – Encrypted Database

**Objective:** Create and use an encrypted database.

**Prerequisite:** SQLCipher installed.

**Step 1:** In CLI, create encrypted database:
```bash
sqlcipher encrypted.db
PRAGMA key = 'mysecret';
CREATE TABLE users (id INTEGER, name TEXT);
INSERT INTO users VALUES (1, 'Alice');
.exit
```
**Step 2:** Try to open with standard `sqlite3` – it should fail.

**Step 3:** Open with SQLCipher and correct key.

**Step 4:** In Python, install `pysqlcipher3` and write code to open with key from environment variable.

---

### Lab 8.3: Backup Automation Script

**Objective:** Write a Python backup script.

**Step 1:** Use `src.backup(dst)` to create a backup with timestamp.
**Step 2:** Keep only last 7 backups.

**Step 3:** Schedule with `cron` (Linux) or Task Scheduler (Windows).

---

### Lab 8.4: Maintenance Script (VACUUM, ANALYZE, Integrity)

**Objective:** Automate maintenance.

**Step 1:** Write a script that:
- Runs `PRAGMA integrity_check` and logs result.
- Runs `ANALYZE`.
- If database size > 100 MB, runs `VACUUM`.

**Step 2:** Add email alert on integrity failure.

---

### Lab 8.5: Dockerize a FastAPI App with SQLite

**Objective:** Create a Docker container for a FastAPI app with SQLite.

**Step 1:** Write `Dockerfile` with Python 3.10, copy app, install dependencies.
**Step 2:** Set environment variable for database path.
**Step 3:** Create a volume for persistent data.
**Step 4:** Build and run:
```bash
docker build -t myapp .
docker run -v /host/data:/data -p 8000:8000 myapp
```

---

## Part 9: Real‑World Projects

### Project 1: Personal Finance Manager

**Deliverables:** Schema, Python CLI, reports.

**Requirements:**
- Categories (income/expense), Transactions.
- Add transactions, monthly summary, budget alerts.
- Use views and aggregate functions.

---

### Project 2: Point of Sale (POS) System

**Deliverables:** Schema, triggers, Python functions.

**Requirements:**
- Products (stock), Customers, Sales, Sale_Items.
- Triggers for stock reduction and check.
- Daily sales report view.

---

### Project 3: Notes with Full‑Text Search

**Deliverables:** Schema, FTS5, Python search functions.

**Requirements:**
- Notes, Tags, Note_Tags.
- FTS5 table synced with triggers.
- Search with ranking and snippets.

---

### Capstone: Task Management System

**Deliverables:** Complete full‑stack application.

**Requirements:**
- Users, Projects, Tasks, Subtasks, Tags, Comments.
- JSON metadata, FTS5 on task title/description.
- Triggers for audit logging and FTS sync.
- FastAPI REST API with JWT authentication.
- Backup and maintenance automation.
- Docker deployment.

---

**End of Lab Book**
