# Student Workbook: Master SQLite — From Fundamentals to Production Systems

---

## About This Workbook

Welcome to your **Master SQLite Student Workbook**! This workbook is designed to accompany the lecture series and hands‑on labs. It contains:

- **Pre‑lab Questions** – Test your understanding before starting each module.
- **Hands‑on Exercises** – Step‑by‑step coding activities with space to write your answers.
- **Post‑lab Questions** – Reinforce key concepts after completing the lab.
- **Reflection Notes** – Space for your own observations and questions.

You will use this workbook throughout the course. **Fill it out as you go** – it will become your personal reference guide.

---

## How to Use This Workbook

1. **Before each module**, read the learning objectives and answer the pre‑lab questions.
2. **During the lab**, follow the instructions and write your code/answers in the provided spaces.
3. **After the lab**, answer the post‑lab questions to solidify your understanding.
4. **Use the notes section** to jot down insights, errors, and tips for future reference.

---

# Part 0: Introduction — Setting the Stage

## Pre‑lab Questions

1. What is the primary architectural difference between SQLite and client‑server databases?  
   _________________________________________________________________________

2. List three real‑world use cases for SQLite.  
   _________________________________________________________________________

3. What does it mean that SQLite is "serverless" and "zero‑configuration"?  
   _________________________________________________________________________

## Lab Activity: Setup & First Database

**Objective:** Install SQLite, create your first database, and run a simple query.

1. Open your terminal and run `sqlite3 --version`. Write the output here:  
   _________________________________________________________________________

2. Create a new database called `first.db`. Start the SQLite shell.
   *Command:* ________________________________________________________________

3. Run the `.databases` command. What do you see?  
   _________________________________________________________________________

4. Create a table `greetings` with a column `message TEXT`.  
   *SQL:* ________________________________________________________________

5. Insert a row with `'Hello, SQLite!'`.  
   *SQL:* ________________________________________________________________

6. Query the table. What is the output?  
   _________________________________________________________________________

7. Exit the shell. What command did you use?  
   _________________________________________________________________________

## Post‑lab Questions

1. What is the purpose of the `.tables` dot‑command?  
   _________________________________________________________________________

2. How would you export the schema of your database to a file?  
   _________________________________________________________________________

---

# Part 1: SQLite Foundations & Internal Architecture

## Module 1: Installation & CLI

### Pre‑lab Questions

1. How do you check if SQLite is installed on your system?  
   _________________________________________________________________________

2. What is the difference between `.schema` and `.dump`?  
   _________________________________________________________________________

### Lab: CLI Essentials

1. Open `first.db` and turn on headers and column mode:
   ```sql
   .headers on
   .mode column
   ```
2. Run `SELECT * FROM greetings;` – what does it display now?  
   _________________________________________________________________________

3. Use `.schema greetings` to see the table's definition. Write it here:  
   _________________________________________________________________________

4. Use `.tables` to list all tables. You should see `greetings`.  
   _________________________________________________________________________

5. **Challenge:** Use `.output` to redirect a query result to a file. Write the commands:  
   _________________________________________________________________________

---

## Module 2: Architecture

### Pre‑lab Questions

1. Name the six main components of SQLite's execution pipeline.  
   _________________________________________________________________________

2. What is the role of the VDBE?  
   _________________________________________________________________________

### Lab: EXPLAIN and EXPLAIN QUERY PLAN

1. Run `EXPLAIN SELECT * FROM greetings;` – what does the output look like?  
   _________________________________________________________________________

2. Run `EXPLAIN QUERY PLAN SELECT * FROM greetings;` – what is the plan?  
   _________________________________________________________________________

3. What does `SCAN greetings` tell you?  
   _________________________________________________________________________

### Post‑lab

1. Why is the B‑Tree important for performance?  
   _________________________________________________________________________

---

## Module 3: Data Types

### Pre‑lab

1. What are the five storage classes?  
   _________________________________________________________________________

2. What is type affinity?  
   _________________________________________________________________________

### Lab: Type Affinity Experiments

Create a table `test` with columns: `a_int INTEGER`, `a_text TEXT`, `a_real REAL`, `a_blob BLOB`, `a_numeric NUMERIC`.

1. Insert the following row: `('123', 456, '78.9', 'binary', '99.9')`. Write the INSERT statement:  
   _________________________________________________________________________

2. Now query the table and use `typeof()` on each column. Write the query and results:  
   _________________________________________________________________________

3. Insert a row where you put a text into the integer column, e.g., `a_int = 'hello'`.  
   Query again and check `typeof(a_int)` – what do you see?  
   _________________________________________________________________________

### Post‑lab

1. Why might storing a date as TEXT be preferable to INTEGER?  
   _________________________________________________________________________

---

## Module 4: Creating Tables

### Pre‑lab

1. What is the difference between `PRIMARY KEY` and `UNIQUE`?  
   _________________________________________________________________________

2. What does `ON DELETE CASCADE` do?  
   _________________________________________________________________________

### Lab: Build a Library Schema

Write the complete SQL to create the following tables:

- **authors** (`author_id` primary key, `first_name`, `last_name`, `birth_year` CHECK > 1000)
- **books** (`book_id` primary key, `title`, `isbn` UNIQUE, `year`, `author_id` foreign key)
- **book_authors** (junction table for many‑to‑many, with composite primary key)

Write your schema here:
```
```

Now insert at least two authors and three books, linking them. Write the INSERT statements:
```
```

Finally, join the tables to show book titles and author names. Write the query:
```
```

### Post‑lab

1. What would happen if you deleted an author with `ON DELETE CASCADE`?  
  _________________________________________________________________________

2. Why do we need a junction table for many‑to‑many?  
  _________________________________________________________________________

---

# Part 2: SQL Programming Essentials

## Module 5: CRUD Operations

### Pre‑lab

1. What are the four CRUD operations and their SQL commands?  
  _________________________________________________________________________

2. How do you limit the number of rows returned?  
  _________________________________________________________________________

### Lab: Customer & Orders

Create a table `customers` (`id`, `name`, `email`) and `orders` (`id`, `customer_id`, `amount`, `order_date`).

1. Insert 3 customers and 5 orders (some with same customer). Write the INSERT statements:
```
```

2. Write a query to list all customers and their total order amounts (use `SUM` and `GROUP BY`).  
```
```

3. Write a query to find the customer with the highest total spend (use `ORDER BY` and `LIMIT`).  
```
```

4. Update the email of a specific customer. Write the UPDATE statement:
```
```

5. Delete an order with a specific `id`. Write the DELETE statement:
```
```

### Post‑lab

1. Why is it important to use a `WHERE` clause in `UPDATE` and `DELETE`?  
  _________________________________________________________________________

---

## Module 6: Filtering & Expressions

### Pre‑lab

1. What is the difference between `LIKE` and `GLOB`?  
  _________________________________________________________________________

2. When would you use a `CASE` expression?  
  _________________________________________________________________________

### Lab: Advanced Filtering

Using the `orders` table, write queries for:

1. Orders with amount between 50 and 100 (inclusive) – use `BETWEEN`.  
   ________________________________________________________________

2. Orders placed in January 2025 (use `strftime`).  
   ________________________________________________________________

3. Customers whose name starts with 'A' (use `LIKE`).  
   ________________________________________________________________

4. Use a `CASE` expression to label orders as 'Low' (<50), 'Medium' (50‑200), or 'High' (>200).  
   ________________________________________________________________

### Post‑lab

1. What is the result of `NULL = NULL`? Why?  
  _________________________________________________________________________

---

## Module 7: Joins

### Pre‑lab

1. Explain the difference between `INNER JOIN` and `LEFT JOIN`.  
  _________________________________________________________________________

2. What is a self‑join? Give an example.  
  _________________________________________________________________________

### Lab: Joining Tables

Using the `customers` and `orders` tables:

1. Write an `INNER JOIN` to list all orders with customer names.  
   ________________________________________________________________

2. Write a `LEFT JOIN` to list all customers, even those with no orders.  
   ________________________________________________________________

3. Find customers who have placed at least one order (use `DISTINCT`).  
   ________________________________________________________________

4. **Challenge:** Use a self‑join on `employees` (if you have a manager_id column) to find employees and their managers. Write the query:  
   ________________________________________________________________

### Post‑lab

1. Why do we typically index foreign key columns?  
  _________________________________________________________________________

---

## Module 8: Aggregation & Reporting

### Pre‑lab

1. What is the difference between `WHERE` and `HAVING`?  
  _________________________________________________________________________

2. What is a window function? Give an example use case.  
  _________________________________________________________________________

### Lab: Reports & Analytics

1. Write a query using `GROUP BY` to count the number of orders per customer.  
   ________________________________________________________________

2. Use `HAVING` to find customers with more than 2 orders.  
   ________________________________________________________________

3. Write a CTE that calculates the average order amount per customer, then list customers above the average.  
   ________________________________________________________________

4. Use a window function to rank customers by total spend (use `RANK()` over `ORDER BY total_spend DESC`).  
   ________________________________________________________________

5. Write a query using `SUM() OVER()` to show a running total of orders by date.  
   ________________________________________________________________

### Post‑lab

1. What is the benefit of using CTEs over subqueries?  
  _________________________________________________________________________

---

# Part 3: Database Design

## Module 9: Normalization

### Pre‑lab

1. What is the purpose of normalization?  
  _________________________________________________________________________

2. Explain 2NF and 3NF.  
  _________________________________________________________________________

### Lab: Normalize a Denormalized Table

You are given a denormalized table `order_details` with columns: `order_id`, `customer_name`, `customer_email`, `order_date`, `product_id`, `product_name`, `product_price`, `quantity`.

1. Identify the functional dependencies.
   _________________________________________________________________________

2. Decompose this into tables in 3NF. Write the CREATE TABLE statements:
   ```
   ```

3. Insert sample data and write a query to reconstruct the original report using joins.  
   ________________________________________________________________

### Post‑lab

1. When might you choose to denormalize intentionally?  
  _________________________________________________________________________

---

## Module 10: Practical Schema Design

### Lab: Library Management System

Design a complete schema for a library with:
- Books (title, ISBN, year, category)
- Authors (name)
- Members (name, email)
- Loans (member, copy, loan_date, due_date, return_date)
- Branches (name, address)
- Copies (book, branch, status)

Write all CREATE TABLE statements including constraints and foreign keys.
```
```

Now, implement a trigger that prevents a member from borrowing more than 5 books at a time. Write the trigger code:
```
```

### Post‑lab

1. What indexes would you create on this schema? Why?  
  _________________________________________________________________________

---

# Part 4: Indexing & Query Optimization

## Module 11: Indexes

### Pre‑lab

1. What is a covering index?  
  _________________________________________________________________________

2. When should you avoid creating an index?  
  _________________________________________________________________________

### Lab: Measure Index Performance

1. Create a table `users` with columns `id`, `last_name`, `first_name`, `email`, `city`. Insert 100,000 rows (use `generate_series` or a loop). Write the script:
```
```

2. Run `SELECT * FROM users WHERE last_name = 'Smith';` with `.timer on`. Record the time: ____ ms.

3. Create an index on `last_name`. Write the command:
```
```

4. Re‑run the query and record the new time: ____ ms.

5. Create a composite index on `(last_name, city)` and test a query that filters on both. Write the query and note the plan with `EXPLAIN QUERY PLAN`.
   _________________________________________________________________________

### Post‑lab

1. What does `SCAN` vs. `SEARCH` mean in the query plan?  
  _________________________________________________________________________

---

## Module 12: Query Planner

### Lab: Analyze Query Plans

1. Run `ANALYZE;` on your database. What does it do?  
   _________________________________________________________________________

2. Write a query that uses a `LIKE` pattern with a leading wildcard. Does it use an index? Check with `EXPLAIN QUERY PLAN`.  
   _________________________________________________________________________

3. Experiment with `INDEXED BY` to force an index. Write a query using it.
   _________________________________________________________________________

### Post‑lab

1. Why is it important to run `ANALYZE` after bulk data changes?  
  _________________________________________________________________________

---

## Module 13: Performance Engineering

### Lab: PRAGMA Tuning

1. Check current `cache_size` and `journal_mode`. Write the PRAGMA commands and their outputs:
   _________________________________________________________________________

2. Switch to WAL mode. Write the command:
   _________________________________________________________________________

3. Set `cache_size` to 20000. Write the command:
   _________________________________________________________________________

4. Bulk insert 10,000 rows with and without a transaction. Compare times. Write your observations:
   _________________________________________________________________________

### Post‑lab

1. What is the trade‑off with `synchronous = OFF`?  
  _________________________________________________________________________

---

# Part 5: Transactions & Concurrency

## Module 14: ACID Transactions

### Pre‑lab

1. Define Atomicity, Consistency, Isolation, Durability.  
  _________________________________________________________________________

2. What is a savepoint?  
  _________________________________________________________________________

### Lab: Bank Transfer

Create an `accounts` table with `id`, `owner`, `balance` (CHECK >=0). Insert two accounts with $1000 each.

1. Write a transaction that transfers $200 from account 1 to account 2.
   ```
   ```

2. Test the transaction by committing and rolling back. Write the commands:
   _________________________________________________________________________

3. Use a savepoint to partially rollback an update. Write the code:
   _________________________________________________________________________

### Post‑lab

1. Why is `BEGIN` important for data consistency?  
  _________________________________________________________________________

---

## Module 15: WAL & Concurrency

### Lab: WAL Mode

1. Enable WAL on your database. Write the PRAGMA:
   _________________________________________________________________________

2. Open two terminal connections to the same database. In one, start a long transaction (e.g., insert many rows). In the other, run a SELECT. Does it block? Record your observation.
   _________________________________________________________________________

3. Monitor the WAL file size (`-wal`). Run a checkpoint and note the size change.
   _________________________________________________________________________

4. Set `busy_timeout = 5000`. Simulate a `SQLITE_BUSY` and observe the wait.
   _________________________________________________________________________

### Post‑lab

1. What is the advantage of WAL over rollback journal for web applications?  
  _________________________________________________________________________

---

## Module 16: Reliability

### Lab: Integrity Check

1. Run `PRAGMA integrity_check;` on a healthy database. What is the result?  
   _________________________________________________________________________

2. Create a foreign key violation (by inserting a child row without a parent) and run `PRAGMA foreign_key_check;`. What does it report?
   _________________________________________________________________________

3. **Simulate corruption:** Append garbage to your database file (use `echo "garbage" >> mydb.db` – be careful!). Run `PRAGMA integrity_check;` and observe the error. Then try to recover with `.dump`. Write your recovery steps.
   _________________________________________________________________________

### Post‑lab

1. What is the role of `synchronous` in preventing corruption?  
  _________________________________________________________________________

---

# Part 6: Advanced Features

## Module 17: JSON1

### Pre‑lab

1. How do you extract a value from a JSON field?  
  _________________________________________________________________________

2. How do you index a JSON field?  
  _________________________________________________________________________

### Lab: JSON in Products

Create a `products` table with `id`, `name`, `attributes` (JSON). Insert products with different attributes (e.g., brand, specs, in_stock).

1. Extract `brand` for all products. Write the query:
   ________________________________________________________________

2. Find all products where `in_stock` is true.  
   ________________________________________________________________

3. Add a generated column `brand` and index it. Write the ALTER and CREATE INDEX statements:
   ________________________________________________________________

4. Use `json_set` to add a new field `warranty` to one product. Write the UPDATE:
   ________________________________________________________________

### Post‑lab

1. When would you choose JSON over a relational design?  
  _________________________________________________________________________

---

## Module 18: FTS5

### Pre‑lab

1. What is the `MATCH` operator used for?  
  _________________________________________________________________________

2. What is the purpose of `bm25()`?  
  _________________________________________________________________________

### Lab: Search Engine

Create an FTS5 table `docs_fts` with columns `title` and `body`. Insert several documents (e.g., blog posts).

1. Search for documents containing "SQLite". Write the query:
   ________________________________________________________________

2. Use a phrase search: `"full-text search"`.  
   ________________________________________________________________

3. Use `bm25()` to rank results. Write the query:
   ________________________________________________________________

4. Display snippets using `snippet()`. Write the query:
   ________________________________________________________________

5. Link FTS to an external content table and set up triggers to keep it in sync. Write the triggers:
   ________________________________________________________________

### Post‑lab

1. How does FTS5 compare to `LIKE` for searching large text columns?  
  _________________________________________________________________________

---

## Module 19: Virtual Tables & Extensions

### Lab: CSV Virtual Table

1. Create a CSV file `sample.csv` with columns `id`, `name`, `value`.  
2. Load the CSV virtual table (if available) and query it. Write the commands:
   ```
   ```

3. Use `generate_series` to create test data. Write a query that generates numbers 1 to 100.
   ________________________________________________________________

### Post‑lab

1. What are the benefits of virtual tables?  
  _________________________________________________________________________

---

## Module 20: Triggers & Views

### Pre‑lab

1. What is the difference between `BEFORE` and `AFTER` triggers?  
  _________________________________________________________________________

2. What is an `INSTEAD OF` trigger?  
  _________________________________________________________________________

### Lab: Audit & Soft Delete

1. Create an audit table `audit_log` with columns `id`, `table_name`, `action`, `row_id`, `old_data`, `new_data`, `changed_at`.
2. Write a trigger that logs all `UPDATE` operations on the `products` table.
   ```
   ```

3. Implement soft delete on `products` by adding a `deleted` column and a view `active_products` that filters out deleted rows. Write the ALTER, VIEW, and `INSTEAD OF DELETE` trigger.
   ________________________________________________________________

### Post‑lab

1. Why might you use a view for security?  
  _________________________________________________________________________

---

# Part 7: Programming with SQLite

## Module 21: Python Integration

### Pre‑lab

1. What is the standard Python library for SQLite?  
  _________________________________________________________________________

2. How do you prevent SQL injection in Python?  
  _________________________________________________________________________

### Lab: Contact Manager

Write a Python script that:

1. Connects to `contacts.db`.
2. Creates a `contacts` table (id, name, email, phone).
3. Implements functions:
   - `add_contact(name, email, phone)`
   - `list_contacts()`
   - `search_contacts(query)`
   - `update_contact(id, name, email, phone)`
   - `delete_contact(id)`
4. Use a context manager for connection handling.
5. Use parameterized queries.
6. Use `sqlite3.Row` to return dictionaries.

Write the complete code in the space below:
```
```

### Post‑lab

1. What is the advantage of using `row_factory = sqlite3.Row`?  
  _________________________________________________________________________

---

## Module 22: Web Development

### Lab: Flask API

1. Create a Flask app with endpoints:
   - `GET /contacts` – list all
   - `POST /contacts` – add a new contact (JSON body)
   - `GET /contacts/<id>` – get one
   - `PUT /contacts/<id>` – update
   - `DELETE /contacts/<id>` – delete
2. Use a connection per request.
3. Write the complete Flask code:
```
```

### Post‑lab

1. How would you test this API with an in‑memory database?  
  _________________________________________________________________________

---

## Module 23: Mobile Development

### Lab: React Native expo‑sqlite

Write the code to:
1. Open a SQLite database.
2. Create an `expenses` table.
3. Insert an expense.
4. Query all expenses.

Write the JavaScript code:
```
```

### Post‑lab

1. How does offline‑first architecture rely on SQLite?  
  _________________________________________________________________________

---

# Part 8: Security & Production

## Module 24: Security

### Pre‑lab

1. What is SQL injection and how do you prevent it?  
  _________________________________________________________________________

2. What is SQLCipher?  
  _________________________________________________________________________

### Lab: SQLCipher

1. Create an encrypted database with SQLCipher and set a key.
2. From Python, open the database using `pysqlcipher3` and the key.
3. Insert and retrieve data.

Write the Python code:
```
```

### Post‑lab

1. Where should you store encryption keys?  
  _________________________________________________________________________

---

## Module 25: Backup & Maintenance

### Lab: Backup Script

Write a Python script that:
1. Performs an online backup of `mydb.db` to a timestamped file in a `backups/` folder.
2. Keeps only the last 7 backups.
3. Runs `PRAGMA integrity_check` and logs the result.
4. If the database size exceeds 100 MB, runs `VACUUM`.

Write the complete script:
```
```

### Post‑lab

1. Why is `VACUUM` not suitable for frequent execution?  
  _________________________________________________________________________

---

## Module 26: Production Deployment

### Lab: Dockerization

1. Write a `Dockerfile` for a FastAPI app using SQLite.
2. Ensure the database file is stored on a persistent volume.
3. Include a health check endpoint that queries the database.

Write the Dockerfile and the health check endpoint code:
```
```

### Post‑lab

1. What environment variables would you use to configure the database path and secrets?  
  _________________________________________________________________________

---

# Part 9: Real‑World Projects & Capstone

## Project 1: Finance Manager

1. Design the schema for the finance manager (categories, transactions).
2. Write a Python CLI that:
   - Adds a transaction with category and amount.
   - Shows monthly summary.
   - Alerts if a budget is exceeded.
3. Write the complete code:
```
```

## Project 2: POS System

1. Design schema for products, customers, sales, sale_items.
2. Implement triggers for stock reduction and stock validation.
3. Write a Python function that processes a sale in a transaction.
4. Write the complete code:
```
```

## Project 3: Notes with FTS

1. Design schema for notes, tags, note_tags.
2. Create FTS5 table and sync triggers.
3. Write a search function that returns ranked results with snippets.
4. Write the complete code:
```
```

## Capstone: Task Management System

1. Write the complete schema (users, projects, tasks, task_tags, comments, audit_log, FTS5).
2. Implement triggers for audit and FTS sync.
3. Write FastAPI endpoints for task CRUD, search, and reporting.
4. Write backup and maintenance scripts.
5. Containerize the app.
6. Write the full implementation code (you can outline major parts):
```
```

---

# Final Reflection

After completing the course, reflect on the following:

1. What concept was most challenging for you? Why?
   _________________________________________________________________________

2. Which tool or technique will you apply first in your own projects?
   _________________________________________________________________________

3. What additional areas do you want to learn more about?
   _________________________________________________________________________

---

**Congratulations on completing the Master SQLite Student Workbook!** Keep this as your reference as you continue your journey.

---

## Appendix: Answer Key (For Instructor Use)

*Due to the length of this workbook, an answer key is provided separately to the instructor. All answers are based on the concepts covered in the lecture series and lab solutions.*

---
*End of Workbook*
