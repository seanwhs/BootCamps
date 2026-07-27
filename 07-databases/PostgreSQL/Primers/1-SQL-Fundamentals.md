# Primer 1: SQL Fundamentals for Absolute Beginners

Welcome to the first primer! This primer is designed for readers who are completely new to SQL or databases. Think of this as your "SQL Boot Camp"—we'll cover the absolute fundamentals you need to understand before diving into the main tutorial series.

**Why this primer exists:** The main tutorial series assumes you have basic SQL knowledge. If you've never written a SQL query before, or if you're still confused about what a "table" or "query" actually means, this primer is for you. We'll cover everything from the ground up using simple analogies and plenty of examples.

---

## P1.1 What is a Database?

### The Target
Understand what a database is and why we use them.

### The Concept
Imagine a library. Instead of books scattered on the floor, they're organized on shelves with a catalog system telling you exactly where each book is located. A database is like that library—it's a structured way to store, organize, and retrieve information.

### The Implementation

**In the real world:**
- A phone book is a database of names and phone numbers
- A recipe box is a database of ingredients and instructions
- An Excel spreadsheet with customer information is a simple database

**In the computer world:**
- A database stores data in tables (like spreadsheets)
- Each table has columns (fields) and rows (records)
- You can search, update, and analyze this data using SQL

```sql
-- This is what a simple database table looks like in SQL
-- Imagine this as a spreadsheet with 3 columns and 2 rows

/*
+------------+----------+-------+
|    name    |  country |  age  |
+------------+----------+-------+
| Alice      | USA      | 25    |
| Bob        | UK       | 30    |
+------------+----------+-------+
*/

-- In SQL, we would create this table and insert data
-- Don't worry about understanding all the details yet!
```

### The Verification

```bash
# No code to run here, just understanding the concept
# Ask yourself: Can you name 3 databases you use in everyday life?
```

---

## P1.2 What is SQL?

### The Target
Understand SQL and its role in databases.

### The Concept
SQL (Structured Query Language) is like a translator between you and the database. You ask questions in SQL, and the database gives you answers. It's the universal language for talking to relational databases.

### The Implementation

**Analogy:** Think of SQL as a restaurant order. You don't go into the kitchen and cook the food yourself. Instead, you tell the waiter (SQL) what you want, and they bring it to you.

**Common SQL commands:** 

| Command | What it does | Real-world analogy |
|---------|--------------|-------------------|
| `SELECT` | Gets data from the database | "Show me what's on the menu" |
| `INSERT` | Adds new data | "Add this to my order" |
| `UPDATE` | Changes existing data | "Change my order to..." |
| `DELETE` | Removes data | "Cancel my order" |

```sql
-- BASIC SQL EXAMPLES (just to see what SQL looks like)

-- SELECT: Get all customers
SELECT * FROM customers;

-- INSERT: Add a new customer
INSERT INTO customers (name, email) VALUES ('John', 'john@email.com');

-- UPDATE: Change a customer's email
UPDATE customers SET email = 'new@email.com' WHERE name = 'John';

-- DELETE: Remove a customer
DELETE FROM customers WHERE name = 'John';
```

### The Verification

```bash
# No code to run, but you should be able to answer:
# 1. What does SQL stand for?
# 2. What are the 4 main SQL commands called (hint: CRUD)?
# 3. What's the difference between SELECT and INSERT?
```

**Answers:**
1. Structured Query Language
2. Create (INSERT), Read (SELECT), Update (UPDATE), Delete (DELETE)
3. SELECT reads data, INSERT adds new data

---

## P1.3 Understanding Databases, Tables, and Columns

### The Target
Understand the structure of a database and how data is organized.

### The Concept
Think of a database as a file cabinet. The database is the entire cabinet. Each drawer is a table. Each folder in the drawer is a row. Each piece of information on the folder is a column.

### The Implementation

**Real-world example: A customer database**

```
DATABASE: MyBusiness
    |
    +-- TABLE: customers
    |       |
    |       +-- COLUMNS: id, first_name, last_name, email
    |       |
    |       +-- ROW 1: 1, John, Doe, john@email.com
    |       +-- ROW 2: 2, Jane, Smith, jane@email.com
    |
    +-- TABLE: orders
    |       |
    |       +-- COLUMNS: id, customer_id, total, date
    |       |
    |       +-- ROW 1: 101, 1, 29.99, 2024-01-01
    |       +-- ROW 2: 102, 2, 49.99, 2024-01-02
    |
    +-- TABLE: products
            |
            +-- COLUMNS: id, name, price, stock
            |
            +-- ROW 1: 1, Phone, 599.99, 50
            +-- ROW 2: 2, Cable, 19.99, 200
```

```sql
-- In SQL, creating a table looks like this
CREATE TABLE customers (
    id INTEGER,           -- Column: id, type: whole number
    first_name TEXT,      -- Column: first_name, type: text
    last_name TEXT,       -- Column: last_name, type: text
    email TEXT            -- Column: email, type: text
);

-- Looking at the data
-- This is what a SELECT query returns
SELECT * FROM customers;

-- Result:
--  id | first_name | last_name | email
-- ----+------------+-----------+------------------
--   1 | John       | Doe       | john@email.com
--   2 | Jane       | Smith     | jane@email.com
```

### The Verification

**Quick quiz:**
1. What's the difference between a table and a database?
2. What's a row? What's a column?
3. Why do we use columns instead of just putting everything in one big list?

**Answers:**
1. A database contains many tables; a table is one part of a database
2. A row is one complete record; a column is a single piece of data (like email or name)
3. Columns help us organize and find specific pieces of information quickly

---

## P1.4 Data Types: The Building Blocks

### The Target
Understand the most common data types used in databases.

### The Concept
Data types define what kind of information can go in each column. They're like different containers: you wouldn't put a fish in a birdcage, and you shouldn't put text in a number column.

### The Implementation

**Common Data Types (Simplified):**

| Data Type | What it stores | Example |
|-----------|---------------|---------|
| `INT` or `INTEGER` | Whole numbers | 1, 42, -5 |
| `TEXT` or `VARCHAR` | Words and sentences | "Hello", "John" |
| `DECIMAL` or `NUMERIC` | Numbers with decimals | 19.99, 3.14 |
| `BOOLEAN` | True/False | true, false |
| `DATE` | Calendar dates | '2024-01-01' |
| `TIMESTAMP` | Date and time | '2024-01-01 14:30:00' |

```sql
-- Example table with different data types
CREATE TABLE products (
    id INTEGER,                    -- Whole number
    name TEXT,                     -- Text
    price DECIMAL(10,2),           -- Number with 2 decimal places
    is_available BOOLEAN,          -- True/False
    created_at TIMESTAMP           -- Date and time
);

-- Inserting data with different types
INSERT INTO products (id, name, price, is_available, created_at)
VALUES 
    (1, 'Laptop', 999.99, true, '2024-01-01 10:00:00'),
    (2, 'Mouse', 29.99, true, '2024-01-01 11:00:00'),
    (3, 'Paper', 5.99, false, '2024-01-02 09:00:00');

-- Querying shows the data
SELECT * FROM products;

-- Result:
--  id |  name  | price  | is_available |     created_at
-- ----+--------+--------+--------------+---------------------
--   1 | Laptop | 999.99 | t            | 2024-01-01 10:00:00
--   2 | Mouse  |  29.99 | t            | 2024-01-01 11:00:00
--   3 | Paper  |   5.99 | f            | 2024-01-02 09:00:00
```

### The Verification

```bash
# No code to run, but try to answer:
# 1. Why can't we store text in an INTEGER column?
# 2. What data type would you use for a person's age?
# 3. What data type would you use for a product description?
```

**Answers:**
1. The database would give an error because the types don't match
2. `INTEGER` (since age is a whole number)
3. `TEXT` (since descriptions contain words)

---

## P1.5 Primary Keys: Unique Identifiers

### The Target
Understand primary keys and why every table needs one.

### The Concept
A primary key is like a social security number for each row—it uniquely identifies that specific row. No two rows can have the same primary key. This ensures you can always find exactly the right record.

### The Implementation

**Analogy:** Imagine a university with 100 students named "John Smith." Without student IDs, it's impossible to know which John Smith you're talking about. Student IDs are like primary keys.

```sql
-- Table WITHOUT a primary key (bad)
CREATE TABLE students_no_pk (
    first_name TEXT,
    last_name TEXT,
    grade TEXT
);

-- Problem: Two different students can't be distinguished
INSERT INTO students_no_pk (first_name, last_name, grade) 
VALUES ('John', 'Smith', 'A');

INSERT INTO students_no_pk (first_name, last_name, grade) 
VALUES ('John', 'Smith', 'B');

-- Now we have two identical-looking rows!
SELECT * FROM students_no_pk;

-- Table WITH a primary key (good)
CREATE TABLE students_with_pk (
    id INTEGER PRIMARY KEY,    -- This uniquely identifies each student
    first_name TEXT,
    last_name TEXT,
    grade TEXT
);

-- Insert data with unique IDs
INSERT INTO students_with_pk (id, first_name, last_name, grade) 
VALUES (1, 'John', 'Smith', 'A');

INSERT INTO students_with_pk (id, first_name, last_name, grade) 
VALUES (2, 'John', 'Smith', 'B');

-- Now we can tell them apart
SELECT * FROM students_with_pk WHERE id = 1;

-- Result:
--  id | first_name | last_name | grade
-- ----+------------+-----------+-------
--   1 | John       | Smith     | A
```

### The Verification

**Quick quiz:**
1. Why can't two rows have the same primary key?
2. What's the difference between a primary key and a regular column?
3. Why is it important to have a primary key?

**Answers:**
1. Primary keys must be unique by definition
2. Primary keys are unique and identify rows; regular columns can contain duplicate values
3. Primary keys ensure we can always find exactly the right row, even if other data is duplicated

---

## P1.6 The SELECT Statement: Reading Data

### The Target
Write basic SELECT queries to read data from a database.

### The Concept
`SELECT` is the most common SQL command. It's how you ask the database for information. Think of it as saying, "I want to see data from this table, and I want specific columns."

### The Implementation

**Anatomy of a SELECT statement:**

```
SELECT column1, column2 FROM table_name WHERE condition ORDER BY column;
```

```sql
-- Let's create a sample table to practice with
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    department TEXT,
    salary DECIMAL(10,2),
    start_date DATE
);

INSERT INTO employees VALUES
    (1, 'Alice', 'Johnson', 'Engineering', 75000.00, '2020-01-15'),
    (2, 'Bob', 'Smith', 'Marketing', 65000.00, '2021-03-01'),
    (3, 'Carol', 'Davis', 'Engineering', 80000.00, '2019-06-10'),
    (4, 'Dave', 'Wilson', 'Sales', 70000.00, '2022-09-20'),
    (5, 'Eve', 'Brown', 'Marketing', 68000.00, '2021-11-01');

-- 1. SELECT * (all columns)
SELECT * FROM employees;

-- 2. SELECT specific columns
SELECT first_name, last_name FROM employees;

-- 3. SELECT with alias (renaming column in results)
SELECT first_name AS "First", last_name AS "Last" FROM employees;

-- 4. WHERE clause (filtering)
-- Get only engineering employees
SELECT * FROM employees WHERE department = 'Engineering';

-- Get employees with salary > 70000
SELECT * FROM employees WHERE salary > 70000;

-- 5. ORDER BY (sorting)
-- Sort by salary (highest first)
SELECT * FROM employees ORDER BY salary DESC;

-- Sort by department, then by name
SELECT * FROM employees ORDER BY department, last_name;

-- 6. Combining conditions
-- Engineering employees with salary > 75000
SELECT * FROM employees 
WHERE department = 'Engineering' 
  AND salary > 75000;

-- 7. LIMIT (get only top results)
-- Top 3 highest paid employees
SELECT * FROM employees 
ORDER BY salary DESC 
LIMIT 3;
```

### The Verification

```bash
# Try these queries yourself:
# 1. Get all employees from Marketing
# 2. Get employees with salary between 65000 and 75000
# 3. Get the employee with the highest salary
# 4. Get employees sorted by start_date (most recent first)
```

**Solutions:**
```sql
-- 1
SELECT * FROM employees WHERE department = 'Marketing';

-- 2
SELECT * FROM employees WHERE salary BETWEEN 65000 AND 75000;

-- 3
SELECT * FROM employees ORDER BY salary DESC LIMIT 1;

-- 4
SELECT * FROM employees ORDER BY start_date DESC;
```

---

## P1.7 The INSERT Statement: Adding Data

### The Target
Write INSERT statements to add new data to a database.

### The Concept
`INSERT` adds new rows to a table. Think of it as filling out a form and submitting it to be added to the database. You need to provide values for all required columns.

### The Implementation

**INSERT syntax:**
```sql
INSERT INTO table_name (column1, column2, ...) VALUES (value1, value2, ...);
```

```sql
-- Using our employees table

-- 1. Basic INSERT (specifying columns)
INSERT INTO employees (id, first_name, last_name, department, salary, start_date)
VALUES (6, 'Frank', 'Chen', 'Engineering', 72000.00, '2023-01-10');

-- 2. Insert without specifying all columns (uses defaults or NULL)
-- id is required, everything else is optional
INSERT INTO employees (id, first_name, last_name)
VALUES (7, 'Grace', 'Lee');

-- Grace will have NULL for department, salary, and start_date
SELECT * FROM employees WHERE id = 7;

-- 3. Insert multiple rows at once
INSERT INTO employees (id, first_name, last_name, department, salary, start_date)
VALUES 
    (8, 'Henry', 'Kim', 'Sales', 68000.00, '2023-02-15'),
    (9, 'Irene', 'Martinez', 'Marketing', 72000.00, '2023-03-01'),
    (10, 'Jack', 'Nelson', 'Engineering', 85000.00, '2023-04-01');

-- 4. INSERT with RETURNING (get back the inserted data)
INSERT INTO employees (id, first_name, last_name, department, salary, start_date)
VALUES (11, 'Karen', 'O''Brien', 'Sales', 71000.00, '2023-05-01')
RETURNING *;

-- 5. Insert from another table (if you have one)
-- INSERT INTO new_employees SELECT * FROM employees WHERE department = 'Engineering';
```

### The Verification

```bash
# Try these exercises:
# 1. Add a new employee with your own name
# 2. Add two employees in one statement
# 3. What happens if you try to insert a row with a duplicate primary key?
```

**Solutions:**
```sql
-- 1
INSERT INTO employees (id, first_name, last_name, department, salary, start_date)
VALUES (12, 'YourFirstName', 'YourLastName', 'Engineering', 100000.00, '2024-01-01');

-- 2
INSERT INTO employees (id, first_name, last_name, department, salary, start_date)
VALUES 
    (13, 'Tom', 'Adams', 'Sales', 62000.00, '2024-01-15'),
    (14, 'Uma', 'Patel', 'Engineering', 95000.00, '2024-01-16');

-- 3
-- This will fail with an error
INSERT INTO employees (id, first_name, last_name) 
VALUES (1, 'Duplicate', 'ID');
-- ERROR: duplicate key value violates unique constraint
```

---

## P1.8 The UPDATE Statement: Changing Data

### The Target
Write UPDATE statements to modify existing data.

### The Concept
`UPDATE` changes existing rows. Think of it as editing information in a form. You specify which rows to update with a `WHERE` clause, and what new values to set.

### The Implementation

**WARNING:** Always use a WHERE clause! Without it, you'll update EVERY row in the table.

```sql
-- Using our employees table

-- 1. Update a single employee
UPDATE employees 
SET department = 'Engineering' 
WHERE id = 7;

-- 2. Update multiple columns
UPDATE employees 
SET salary = 74000.00, 
    department = 'Sales' 
WHERE id = 1;

-- 3. Update multiple rows (using a condition)
-- Give everyone in Marketing a 5% raise
UPDATE employees 
SET salary = salary * 1.05 
WHERE department = 'Marketing';

-- 4. UPDATE with calculation
-- Add 1000 to everyone making under 70000
UPDATE employees 
SET salary = salary + 1000 
WHERE salary < 70000;

-- 5. UPDATE with RETURNING (see what changed)
UPDATE employees 
SET department = 'Executive' 
WHERE id = 12 
RETURNING *;

-- 6. Conditional UPDATE with CASE
-- Different raises for different departments
UPDATE employees 
SET salary = CASE 
    WHEN department = 'Engineering' THEN salary * 1.10  -- 10% raise
    WHEN department = 'Sales' THEN salary * 1.08        -- 8% raise
    ELSE salary * 1.05                                   -- 5% raise
END;

-- Check the results
SELECT department, AVG(salary) FROM employees GROUP BY department;
```

### The Verification

```bash
# Try these exercises:
# 1. Update a specific employee's department
# 2. Give all employees a 5% raise
# 3. Change the department for all Sales employees to 'Sales & Marketing'
```

**Solutions:**
```sql
-- 1
UPDATE employees SET department = 'Management' WHERE id = 5;

-- 2 (DANGER: this updates ALL employees)
-- Always use WHERE!
UPDATE employees SET salary = salary * 1.05 WHERE id > 0;

-- 3
UPDATE employees SET department = 'Sales & Marketing' WHERE department = 'Sales';
```

---

## P1.9 The DELETE Statement: Removing Data

### The Target
Write DELETE statements to remove data from a database.

### The Concept
`DELETE` removes entire rows from a table. Think of it as throwing away a file. Once deleted, the data is gone (unless you have a backup). Use with extreme caution!

### The Implementation

**WARNING:** Always use a WHERE clause! Without it, you'll delete EVERY row in the table.

```sql
-- Using our employees table

-- 1. Delete a specific employee
DELETE FROM employees WHERE id = 7;

-- 2. Delete multiple rows
DELETE FROM employees WHERE department = 'Marketing';

-- 3. Delete with RETURNING (see what was deleted)
DELETE FROM employees WHERE id = 13 RETURNING *;

-- 4. Delete based on a condition
DELETE FROM employees WHERE salary < 50000;

-- 5. Delete all rows from a table (use with extreme caution!)
-- DELETE FROM employees;  -- DON'T RUN THIS UNLESS YOU'RE SURE!

-- 6. TRUNCATE (faster way to delete all rows)
-- TRUNCATE TABLE employees;  -- Even more dangerous than DELETE!

-- Let's see what's left
SELECT * FROM employees;
```

### The Verification

```bash
# Try these exercises:
# 1. Delete the employee with id = 14
# 2. Delete all employees in Sales (careful!)
# 3. What happens if you DELETE without a WHERE clause?
```

**Solutions:**
```sql
-- 1
DELETE FROM employees WHERE id = 14;

-- 2 (Make sure you mean it!)
DELETE FROM employees WHERE department = 'Sales';

-- 3
-- DELETE FROM employees; -- This would delete EVERYTHING!
-- Always double-check your WHERE clause before running DELETE
```

---

## P1.10 Putting It All Together: CRUD Operations

### The Target
Understand CRUD operations and practice all four commands.

### The Concept
CRUD stands for Create, Read, Update, Delete. These are the four basic operations on any data:

- **Create** (INSERT): Add new data
- **Read** (SELECT): View existing data
- **Update** (UPDATE): Modify existing data
- **Delete** (DELETE): Remove data

### The Implementation

```sql
-- Let's build a small example from scratch

-- 1. CREATE: Build the table
CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT,
    author TEXT,
    year_published INTEGER,
    is_available BOOLEAN
);

-- 2. CREATE: Add some data (INSERT)
INSERT INTO books (id, title, author, year_published, is_available) VALUES
    (1, 'The Great Gatsby', 'F. Scott Fitzgerald', 1925, true),
    (2, '1984', 'George Orwell', 1949, true),
    (3, 'To Kill a Mockingbird', 'Harper Lee', 1960, false),
    (4, 'The Catcher in the Rye', 'J.D. Salinger', 1951, true);

-- 3. READ: See all books (SELECT)
SELECT * FROM books;

-- 4. READ: Find specific books
SELECT * FROM books WHERE author = 'George Orwell';

-- 5. UPDATE: Change a book's availability
UPDATE books SET is_available = true WHERE id = 3;

-- 6. READ: See the change
SELECT * FROM books WHERE id = 3;

-- 7. DELETE: Remove a book
DELETE FROM books WHERE id = 4;

-- 8. READ: See final state
SELECT * FROM books;

-- 9. READ: Count how many books are available
SELECT COUNT(*) AS available_books FROM books WHERE is_available = true;

-- 10. READ: Find books after a certain year
SELECT * FROM books WHERE year_published > 1950;
```

### The Verification

```bash
# Try building your own example:
# 1. Create a table for your favorite movies
# 2. Insert 3-5 movies
# 3. Query all movies from a specific year
# 4. Update a movie's rating
# 5. Delete a movie you didn't like
```

**Solution example:**
```sql
-- 1
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT,
    director TEXT,
    release_year INTEGER,
    rating DECIMAL(3,1)
);

-- 2
INSERT INTO movies (id, title, director, release_year, rating) VALUES
    (1, 'Inception', 'Christopher Nolan', 2010, 8.8),
    (2, 'The Matrix', 'Lana Wachowski', 1999, 8.7),
    (3, 'Interstellar', 'Christopher Nolan', 2014, 8.6);

-- 3
SELECT * FROM movies WHERE release_year > 2000;

-- 4
UPDATE movies SET rating = 9.0 WHERE title = 'Inception';

-- 5
DELETE FROM movies WHERE title = 'The Matrix';

-- Check final state
SELECT * FROM movies ORDER BY rating DESC;
```

---

## P1.11 Common Mistakes and How to Avoid Them

### Target
Learn from the most common beginner mistakes and how to avoid them.

### Concept
Everyone makes mistakes when learning SQL. This section highlights the most common ones and shows you how to prevent them.

---

### Mistake 1: Forgetting the WHERE Clause

```sql
-- DANGER: This updates EVERY row!
UPDATE employees SET salary = 100000;

-- CORRECT: Always include a WHERE clause
UPDATE employees SET salary = 100000 WHERE id = 1;
```

### Mistake 2: Mismatched Data Types

```sql
-- ERROR: Can't compare text and numbers
SELECT * FROM employees WHERE salary = 'hello';

-- CORRECT: Match the types
SELECT * FROM employees WHERE salary = 75000;
```

### Mistake 3: Duplicate Primary Keys

```sql
-- ERROR: Primary key must be unique
INSERT INTO employees (id, first_name) VALUES (1, 'Alice');

-- CORRECT: Use a different ID
INSERT INTO employees (id, first_name) VALUES (5, 'Alice');
```

### Mistake 4: Not Using Quotation Marks

```sql
-- ERROR: Text must be in quotes
SELECT * FROM employees WHERE department = Engineering;

-- CORRECT: Text in quotes
SELECT * FROM employees WHERE department = 'Engineering';

-- Single quotes for text, no quotes for numbers
SELECT * FROM employees WHERE salary = 75000;  -- Correct
SELECT * FROM employees WHERE salary = '75000'; -- Works but converts
```

### Mistake 5: Confusing AND/OR

```sql
-- WRONG: This gets employees in Engineering OR with salary > 70000
SELECT * FROM employees 
WHERE department = 'Engineering' 
  OR salary > 70000;

-- CORRECT: This gets employees in Engineering AND with salary > 70000
SELECT * FROM employees 
WHERE department = 'Engineering' 
  AND salary > 70000;
```

### Mistake 6: Forgetting Semicolons

```sql
-- ERROR: No semicolon
SELECT * FROM employees

-- CORRECT: End with semicolon
SELECT * FROM employees;
```

---

## P1.12 Summary

### What You've Learned

✅ What a database is and why we use them  
✅ What SQL is and its role in databases  
✅ Database structure: databases → tables → columns → rows  
✅ Common data types: INTEGER, TEXT, DECIMAL, BOOLEAN  
✅ Primary keys and why they're important  
✅ CRUD operations: SELECT, INSERT, UPDATE, DELETE  
✅ How to write basic SQL queries  
✅ Common mistakes and how to avoid them  

### Practice Exercises

Try these exercises to reinforce your learning:

1. **Create a table** for a store inventory with columns for product ID (primary key), product name, price, quantity, and category

2. **Insert at least 5 products** into your inventory table

3. **Query all products** in a specific category

4. **Update the price** of a specific product

5. **Delete a product** that's out of stock

6. **Find all products** priced between $10 and $50

7. **Sort products** by price from highest to lowest

8. **Find the most expensive product** using ORDER BY and LIMIT

### Ready for the Main Series?

You've completed the SQL Fundamentals primer! You now have enough knowledge to start the main tutorial series with confidence.

The main series will build on these concepts, adding:
- More advanced SQL
- Database design
- Relationships between tables
- Complex queries with joins
- Performance optimization

**Go to Part 1: First Steps & The SQL Foundation** to begin your journey!
