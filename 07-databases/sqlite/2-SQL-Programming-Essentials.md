Welcome to Part 2. Now that you understand the foundations—installation, architecture, data types, and schema design—it’s time to put SQLite to work. This part is all about **writing SQL** to interact with your data. We will cover everything from basic CRUD (Create, Read, Update, Delete) to advanced filtering, joins, aggregations, and window functions. By the end, you will be able to write complex analytical queries that extract meaningful insights from your database.

**Part 2** is divided into four modules:

- **Module 5:** CRUD Operations – inserting, updating, deleting, and basic querying.
- **Module 6:** Filtering and Expressions – `WHERE`, `LIKE`, `GLOB`, `CASE`, and handling `NULL`.
- **Module 7:** Joins & Relationships – `INNER`, `LEFT`, `CROSS`, `SELF` joins, and many‑to‑many relationships.
- **Module 8:** Aggregation & Reporting – `GROUP BY`, `HAVING`, aggregate functions, CTEs, and window functions.

We will use the `library.db` database we created in Part 1, and we will build on it with new sample data. Let's jump in.

---

# Part 2: SQL Programming Essentials

## Module 5: CRUD Operations

### The Target

By the end of this module, you will be able to insert, update, delete, and retrieve data using the four basic SQL verbs: `INSERT`, `SELECT`, `UPDATE`, and `DELETE`. You will also master `ORDER BY`, `LIMIT`, `OFFSET`, and `DISTINCT` to shape your result sets.

### The Concept

Think of your database tables as **digital filing cabinets** with drawers (tables) and folders (rows). CRUD operations are the actions you perform on these folders:

- **Create** – you add a new folder (row) using `INSERT`.
- **Read** – you open a drawer and look at folders using `SELECT`.
- **Update** – you modify the contents of a folder using `UPDATE`.
- **Delete** – you remove a folder using `DELETE`.

We will also learn how to sort, paginate, and remove duplicates from your output.

### Hands‑on Lab 5.1: Setting Up Sample Data

We'll populate the `library.db` with more data to work with.

Open your terminal and start the SQLite CLI with `library.db`:

```bash
cd ~/sqlite_series
sqlite3 library.db
```

If you don't have the library schema from Part 1, recreate it using the following script (or just ensure your tables exist). We will also add a new `borrowers` table and a `loans` table to simulate a real library system.

Execute this full setup:

```sql
-- Enable foreign keys
PRAGMA foreign_keys = ON;

-- Drop existing tables if they exist (clean slate)
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS borrowers;

-- Authors table
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_year INTEGER CHECK (birth_year > 1000 AND birth_year <= strftime('%Y', 'now')),
    UNIQUE (first_name, last_name)
);

-- Books table
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    isbn TEXT UNIQUE NOT NULL,
    publication_year INTEGER CHECK (publication_year BETWEEN 1450 AND strftime('%Y', 'now')),
    genre TEXT DEFAULT 'Unknown',
    pages INTEGER DEFAULT 0,
    full_title TEXT GENERATED ALWAYS AS (title || ' (' || publication_year || ')') STORED
);

-- Junction table: many-to-many
CREATE TABLE book_authors (
    book_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);
CREATE INDEX idx_book_authors_author ON book_authors(author_id);

-- Borrowers table
CREATE TABLE borrowers (
    borrower_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    registered_date TEXT DEFAULT (datetime('now', 'localtime'))
);

-- Loans table
CREATE TABLE loans (
    loan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    borrower_id INTEGER NOT NULL,
    loan_date TEXT DEFAULT (datetime('now', 'localtime')),
    return_date TEXT,  -- NULL means not returned yet
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id) ON DELETE CASCADE
);
CREATE INDEX idx_loans_borrower ON loans(borrower_id);
CREATE INDEX idx_loans_book ON loans(book_id);
```

Now insert sample data:

```sql
-- Authors
INSERT INTO authors (first_name, last_name, birth_year) VALUES
    ('George', 'Orwell', 1903),
    ('Aldous', 'Huxley', 1894),
    ('J.R.R.', 'Tolkien', 1892),
    ('Isaac', 'Asimov', 1920),
    ('Arthur C.', 'Clarke', 1917);

-- Books
INSERT INTO books (title, isbn, publication_year, genre, pages) VALUES
    ('1984', '978-0-452-28423-4', 1949, 'Dystopian', 328),
    ('Brave New World', '978-0-06-085052-4', 1932, 'Science Fiction', 288),
    ('The Hobbit', '978-0-547-92822-7', 1937, 'Fantasy', 310),
    ('The Lord of the Rings', '978-0-618-00222-8', 1954, 'Fantasy', 1178),
    ('Foundation', '978-0-553-80371-5', 1951, 'Science Fiction', 244),
    ('2001: A Space Odyssey', '978-0-451-45799-4', 1968, 'Science Fiction', 256);

-- Link authors to books (book_authors)
INSERT INTO book_authors (book_id, author_id) VALUES
    (1, 1),  -- 1984 by Orwell
    (2, 2),  -- Brave New World by Huxley
    (3, 3),  -- The Hobbit by Tolkien
    (4, 3),  -- Lord of the Rings by Tolkien
    (5, 4),  -- Foundation by Asimov
    (6, 5);  -- 2001 by Clarke

-- Borrowers
INSERT INTO borrowers (first_name, last_name, email) VALUES
    ('Alice', 'Smith', 'alice@example.com'),
    ('Bob', 'Johnson', 'bob@example.com'),
    ('Carol', 'Williams', 'carol@example.com');

-- Loans (some returned, some active)
INSERT INTO loans (book_id, borrower_id, loan_date, return_date) VALUES
    (1, 1, '2025-01-10 10:00:00', '2025-01-20 14:30:00'), -- returned
    (2, 2, '2025-01-15 09:30:00', NULL),                  -- not returned
    (3, 3, '2025-02-01 11:00:00', NULL),                  -- not returned
    (4, 1, '2025-02-05 13:00:00', '2025-02-15 16:45:00'), -- returned
    (5, 2, '2025-02-10 08:00:00', NULL);                  -- not returned
```

#### Verification

Run `SELECT COUNT(*) FROM books;` – you should get 6. `SELECT COUNT(*) FROM authors;` – 5. `SELECT COUNT(*) FROM borrowers;` – 3. `SELECT COUNT(*) FROM loans;` – 5.

---

### The SELECT Statement

`SELECT` is the workhorse for reading data. Its basic structure is:

```sql
SELECT column1, column2, ... FROM table_name [WHERE condition] [ORDER BY ...] [LIMIT ...] [OFFSET ...];
```

**Hands‑on:**

```sql
-- Select all columns from books
SELECT * FROM books;

-- Select specific columns
SELECT title, publication_year FROM books;

-- Use aliases for columns
SELECT title AS "Book Title", publication_year AS "Year" FROM books;

-- Use DISTINCT to get unique genres
SELECT DISTINCT genre FROM books;

-- Order by publication year descending
SELECT title, publication_year FROM books ORDER BY publication_year DESC;

-- Limit results to 3 rows
SELECT title FROM books LIMIT 3;

-- Pagination: skip 2 rows, then take 3 (OFFSET 2)
SELECT title FROM books ORDER BY title LIMIT 3 OFFSET 2;
```

#### Verification

Run each query and check that the results match your expectations. For `DISTINCT genre`, you should see three genres: Dystopian, Science Fiction, Fantasy.

---

### The INSERT Statement

Insert one row or multiple rows at once.

```sql
-- Insert single row
INSERT INTO borrowers (first_name, last_name, email) 
VALUES ('David', 'Brown', 'david@example.com');

-- Insert multiple rows
INSERT INTO books (title, isbn, publication_year, genre, pages) VALUES
    ('Dune', '978-0-441-17271-9', 1965, 'Science Fiction', 412),
    ('Neuromancer', '978-0-441-56959-5', 1984, 'Cyberpunk', 271);

-- Insert with default values (e.g., registered_date uses DEFAULT)
INSERT INTO borrowers (first_name, last_name, email) 
VALUES ('Eve', 'Davis', 'eve@example.com');
-- registered_date will be current datetime
```

#### Verification

Run `SELECT * FROM borrowers;` – you should now have 5 borrowers.

---

### The UPDATE Statement

Update existing rows. Always use a `WHERE` clause unless you intend to update every row.

```sql
-- Update a specific book's pages
UPDATE books SET pages = 350 WHERE book_id = 1;

-- Update multiple columns
UPDATE books SET genre = 'Sci-Fi' WHERE genre = 'Science Fiction';

-- Update with a subquery (advanced, we'll cover later)
UPDATE books SET pages = pages + 10 WHERE publication_year < 1950;
```

#### Verification

Run `SELECT book_id, title, pages, genre FROM books;` and confirm the changes.

---

### The DELETE Statement

Remove rows. Again, use `WHERE` to avoid deleting everything.

```sql
-- Delete a specific book
DELETE FROM books WHERE book_id = 7;  -- assuming Dune is book_id 7 if you inserted it

-- Delete all books with no authors? (none in our data)
-- But be careful with foreign keys: ON DELETE CASCADE will remove related rows.
```

#### Verification

After deletion, try `SELECT * FROM books WHERE book_id = 7;` – it should return nothing. Also check that related rows in `book_authors` are automatically deleted due to `CASCADE`.

---

### Summary of CRUD Commands

| Operation | SQL Command |
|-----------|-------------|
| Create (insert) | `INSERT INTO table (cols) VALUES (values);` |
| Read (select) | `SELECT cols FROM table WHERE ... ORDER BY ... LIMIT ...;` |
| Update | `UPDATE table SET col = value WHERE condition;` |
| Delete | `DELETE FROM table WHERE condition;` |

---

**[GENERATED: Part 2, Module 5: CRUD Operations]**

---

## Module 6: Filtering and Expressions

### The Target

Learn to refine your queries using the `WHERE` clause, pattern matching with `LIKE` and `GLOB`, range checks with `BETWEEN` and `IN`, conditional logic with `CASE`, and robust handling of `NULL`.

### The Concept

Filtering is like using a **sieve** to separate what you want from what you don’t. The `WHERE` clause defines the criteria that each row must meet. We’ll explore operators, pattern matching, and how to deal with missing values (`NULL`).

### Comparison and Logical Operators

| Operator | Meaning |
|----------|---------|
| `=` | Equal |
| `<>` or `!=` | Not equal |
| `<`, `<=`, `>`, `>=` | Less than, etc. |
| `AND`, `OR`, `NOT` | Logical combinations |
| `IS NULL`, `IS NOT NULL` | Check for null |

**Hands‑on:**

```sql
-- Books published after 1950
SELECT title, publication_year FROM books WHERE publication_year > 1950;

-- Books with genre 'Fantasy' or 'Dystopian'
SELECT title, genre FROM books WHERE genre = 'Fantasy' OR genre = 'Dystopian';

-- Books with pages between 250 and 400
SELECT title, pages FROM books WHERE pages BETWEEN 250 AND 400;

-- Borrowers whose last name starts with 'S' (pattern matching using LIKE)
SELECT first_name, last_name FROM borrowers WHERE last_name LIKE 'S%';

-- Books where genre is not NULL (all have genre, but just for illustration)
SELECT title, genre FROM books WHERE genre IS NOT NULL;

-- Books with title containing 'Lord'
SELECT title FROM books WHERE title LIKE '%Lord%';
```

### Pattern Matching: LIKE vs. GLOB

- `LIKE` is case‑insensitive by default (for ASCII) and uses `%` (any sequence) and `_` (single character).
- `GLOB` is case‑sensitive and uses Unix‑style wildcards: `*` and `?`.

```sql
-- LIKE: case-insensitive
SELECT title FROM books WHERE title LIKE '%ring%';  -- matches "The Lord of the Rings"

-- GLOB: case-sensitive
SELECT title FROM books WHERE title GLOB '*Ring*';  -- might not match if case differs
```

### The IN Operator

Checks if a value is in a list.

```sql
SELECT title, genre FROM books WHERE genre IN ('Fantasy', 'Science Fiction');
```

### The CASE Expression

`CASE` is like an if‑else statement in SQL. It can be used in `SELECT`, `WHERE`, `ORDER BY`, etc.

**Example:**

```sql
SELECT 
    title,
    pages,
    CASE 
        WHEN pages < 300 THEN 'Short'
        WHEN pages BETWEEN 300 AND 500 THEN 'Medium'
        ELSE 'Long'
    END AS length_category
FROM books;
```

### Handling NULL

`NULL` represents missing or unknown data. Comparisons with `NULL` yield `NULL`, not true/false. Use `IS NULL` or `IS NOT NULL`.

```sql
-- Find loans that are not returned yet (return_date IS NULL)
SELECT loan_id, book_id, borrower_id, loan_date 
FROM loans 
WHERE return_date IS NULL;

-- Find loans that have been returned
SELECT loan_id, book_id, borrower_id, loan_date, return_date
FROM loans 
WHERE return_date IS NOT NULL;
```

### Hands‑on Lab 6.1: Advanced Filtering

1. Find all books that were published between 1930 and 1960, and are either Fantasy or Science Fiction, ordered by year.

```sql
SELECT title, publication_year, genre
FROM books
WHERE publication_year BETWEEN 1930 AND 1960
  AND genre IN ('Fantasy', 'Science Fiction')
ORDER BY publication_year;
```

2. Use `CASE` to create a readability score based on pages: if pages < 250 → 'Short', 250–500 → 'Medium', > 500 → 'Long'.

```sql
SELECT title, pages,
    CASE 
        WHEN pages < 250 THEN 'Short'
        WHEN pages <= 500 THEN 'Medium'
        ELSE 'Long'
    END AS length
FROM books;
```

3. Find borrowers whose email domain is 'example.com' (use `LIKE`).

```sql
SELECT first_name, last_name, email
FROM borrowers
WHERE email LIKE '%@example.com';
```

4. Find books that do not have a genre set (though all have defaults, test with `IS NULL`).

```sql
SELECT title, genre FROM books WHERE genre IS NULL;
-- Should return none.
```

#### Verification

Run each query and verify the output.

---

**[GENERATED: Part 2, Module 6: Filtering and Expressions]**

---

## Module 7: Joins & Relationships

### The Target

Master the art of combining data from multiple tables using `JOIN`s. We will cover `INNER JOIN`, `LEFT JOIN`, `CROSS JOIN`, and `SELF JOIN`. You will also learn to model and query many‑to‑many relationships.

### The Concept

Relational databases store different facts in different tables to avoid duplication. To answer questions that need data from multiple tables, we **join** them together. Think of a join as **connecting the dots**—you take rows from one table and match them to rows in another based on a common column (the foreign key).

### Inner Join

`INNER JOIN` returns rows only when there is a match in both tables.

**Example:** Get the title of each book and its author(s).

```sql
SELECT b.title, a.first_name || ' ' || a.last_name AS author
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id;
```

Because we use `INNER JOIN`, only books with at least one author appear. All our books have authors, so we see all.

### Left Join (Outer Join)

`LEFT JOIN` returns all rows from the left table, even if there is no match in the right table. Missing values appear as `NULL`.

**Example:** Find all books and their loan status (if any). Some books may not be loaned.

First, we need a `books` table and a `loans` table. Let's add a book that has never been loaned.

```sql
INSERT INTO books (title, isbn, publication_year, genre, pages) 
VALUES ('The Left Hand of Darkness', '978-0-441-00731-8', 1969, 'Science Fiction', 304);
-- Link to an author (we'll add Ursula K. Le Guin)
INSERT INTO authors (first_name, last_name, birth_year) VALUES ('Ursula K.', 'Le Guin', 1929);
INSERT INTO book_authors (book_id, author_id) VALUES ((SELECT book_id FROM books WHERE isbn = '978-0-441-00731-8'), (SELECT author_id FROM authors WHERE last_name = 'Le Guin'));
```

Now, left join books with loans:

```sql
SELECT b.title, l.loan_id, l.loan_date, l.return_date
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id;
```

You will see the new book with `NULL` for loan columns, because it has no loans.

### Cross Join

`CROSS JOIN` produces the Cartesian product of two tables—every row from the first paired with every row from the second. Rarely used, but can be useful for generating test data.

```sql
SELECT b.title, br.first_name
FROM books b
CROSS JOIN borrowers br
LIMIT 10;  -- will produce many rows, so limit for sanity
```

### Self Join

A self join is when you join a table to itself. Useful for hierarchical data (e.g., employees with managers).

We don't have such a table, but we can demonstrate by finding pairs of authors who were born in the same year. We'll need to join the `authors` table with itself.

```sql
SELECT a1.first_name || ' ' || a1.last_name AS author1,
       a2.first_name || ' ' || a2.last_name AS author2,
       a1.birth_year
FROM authors a1
JOIN authors a2 ON a1.birth_year = a2.birth_year 
               AND a1.author_id < a2.author_id;  -- avoid duplicates and self
```

Since our authors have unique birth years, this may return nothing. You could add a duplicate birth year for demo.

### Hands‑on Lab 7.1: Complex Join Queries

**1. List all borrowers and the titles of books they currently have (return_date IS NULL).**

```sql
SELECT br.first_name, br.last_name, b.title, l.loan_date
FROM borrowers br
JOIN loans l ON br.borrower_id = l.borrower_id
JOIN books b ON l.book_id = b.book_id
WHERE l.return_date IS NULL;
```

**2. List all books and the number of borrowers who have ever borrowed them (including those returned). Use `LEFT JOIN` and aggregation (we'll cover `GROUP BY` later, but for now we can use a subquery).**

We'll do a simple count with a subquery:

```sql
SELECT b.title,
       (SELECT COUNT(*) FROM loans l WHERE l.book_id = b.book_id) AS borrow_count
FROM books b;
```

**3. Find authors who have written more than one book.**

We need to group by author and count. We'll use a subquery with `GROUP BY`:

```sql
SELECT a.first_name, a.last_name, 
       (SELECT COUNT(*) FROM book_authors ba WHERE ba.author_id = a.author_id) AS book_count
FROM authors a
WHERE (SELECT COUNT(*) FROM book_authors ba WHERE ba.author_id = a.author_id) > 1;
```

Tolkien should appear with 2 books.

**4. List all books with their authors (including those with multiple authors, if any).**

We already did that. To see if any book has multiple authors, we can check:

```sql
SELECT book_id, COUNT(*) AS author_count 
FROM book_authors 
GROUP BY book_id 
HAVING COUNT(*) > 1;
```

If none, you can insert a second author for a book to test.

#### Verification

Run each query and check the results.

---

**[GENERATED: Part 2, Module 7: Joins & Relationships]**

---

## Module 8: Aggregation & Reporting

### The Target

Learn to summarize data using aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`), group rows with `GROUP BY`, filter groups with `HAVING`, and perform advanced analysis with Common Table Expressions (CTEs) and window functions.

### The Concept

Aggregation is like **taking a step back** to see the big picture. Instead of looking at individual rows, you ask questions like:

- How many books do we have?
- What is the average number of pages?
- Which author has the most books?

`GROUP BY` groups rows that share a common value, and aggregate functions compute a single result per group. `HAVING` filters those groups (like `WHERE` for groups).

Window functions perform calculations across a set of rows related to the current row, without collapsing rows—perfect for running totals, rankings, and moving averages.

### Aggregate Functions

| Function | Description |
|----------|-------------|
| `COUNT(*)` | Number of rows |
| `COUNT(column)` | Number of non‑NULL values |
| `SUM(column)` | Sum of values |
| `AVG(column)` | Average (mean) |
| `MIN(column)` | Minimum value |
| `MAX(column)` | Maximum value |

**Hands‑on:**

```sql
-- Total number of books
SELECT COUNT(*) AS total_books FROM books;

-- Average pages
SELECT AVG(pages) AS avg_pages FROM books;

-- Minimum and maximum publication year
SELECT MIN(publication_year) AS earliest, MAX(publication_year) AS latest FROM books;

-- Count of distinct genres
SELECT COUNT(DISTINCT genre) AS genre_count FROM books;
```

### GROUP BY

Group by a column to get per‑group aggregates.

```sql
-- Number of books per genre
SELECT genre, COUNT(*) AS book_count
FROM books
GROUP BY genre;

-- Average pages per genre
SELECT genre, AVG(pages) AS avg_pages
FROM books
GROUP BY genre;
```

### HAVING

Filter groups after grouping.

```sql
-- Genres with more than 2 books
SELECT genre, COUNT(*) AS book_count
FROM books
GROUP BY genre
HAVING COUNT(*) > 2;
```

### Common Table Expressions (CTEs)

CTEs are temporary named result sets that you can reference within a query. They make complex queries more readable.

```sql
-- CTE: get books published after 1950
WITH recent_books AS (
    SELECT * FROM books WHERE publication_year > 1950
)
SELECT title, publication_year FROM recent_books ORDER BY publication_year;
```

### Recursive CTEs

SQLite supports recursive CTEs, which are essential for hierarchical data (like tree structures). Example: generate a sequence of numbers.

```sql
WITH RECURSIVE numbers(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT n FROM numbers;
```

We will use recursive CTEs in Part 6 for graph traversal.

### Window Functions

Window functions perform calculations across a set of rows related to the current row, without collapsing them into a single group. They are powerful for ranking, running totals, and moving averages.

Basic syntax: `function() OVER (PARTITION BY col ORDER BY col ROWS/RANGE BETWEEN ...)`

Common window functions:
- `ROW_NUMBER()` – assigns a unique sequential integer to each row within a partition.
- `RANK()`, `DENSE_RANK()` – ranking with gaps or without.
- `LAG()`, `LEAD()` – access previous or next row.
- `SUM() OVER()` – running total.

**Hands‑on:**

```sql
-- Rank books by publication year (within each genre)
SELECT 
    title,
    genre,
    publication_year,
    ROW_NUMBER() OVER (PARTITION BY genre ORDER BY publication_year) AS rank_in_genre
FROM books;

-- Running total of pages for books ordered by title (cumulative sum)
SELECT 
    title,
    pages,
    SUM(pages) OVER (ORDER BY title ROWS UNBOUNDED PRECEDING) AS cumulative_pages
FROM books;
```

### Hands‑on Lab 8.1: Building Business Analytics Reports

**1. Report: Number of books per author, sorted descending.**

```sql
SELECT a.first_name || ' ' || a.last_name AS author,
       COUNT(ba.book_id) AS book_count
FROM authors a
LEFT JOIN book_authors ba ON a.author_id = ba.author_id
GROUP BY a.author_id
ORDER BY book_count DESC;
```

**2. Report: Total loans per borrower, including those who have never borrowed (use LEFT JOIN).**

```sql
SELECT br.first_name || ' ' || br.last_name AS borrower,
       COUNT(l.loan_id) AS loan_count
FROM borrowers br
LEFT JOIN loans l ON br.borrower_id = l.borrower_id
GROUP BY br.borrower_id
ORDER BY loan_count DESC;
```

**3. Report: Books that have never been borrowed.**

Using a CTE or subquery:

```sql
SELECT b.title
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
WHERE l.loan_id IS NULL;
```

**4. Report: Monthly borrowing trend (using window functions).**

First, we need to extract month from loan_date. We'll group by month, then use window functions to compute running total.

```sql
-- CTE to get count per month
WITH monthly_loans AS (
    SELECT strftime('%Y-%m', loan_date) AS month,
           COUNT(*) AS loan_count
    FROM loans
    GROUP BY month
)
SELECT month,
       loan_count,
       SUM(loan_count) OVER (ORDER BY month) AS cumulative_loans
FROM monthly_loans
ORDER BY month;
```

**5. Report: Top 2 longest books (by pages) in each genre.**

This uses window function with ranking:

```sql
WITH ranked_books AS (
    SELECT 
        title,
        genre,
        pages,
        ROW_NUMBER() OVER (PARTITION BY genre ORDER BY pages DESC) AS rn
    FROM books
)
SELECT title, genre, pages
FROM ranked_books
WHERE rn <= 2;
```

### Verification

Run each query and verify output against your data.

---

### Reference: Aggregate Functions and Window Functions Cheat Sheet

| Function | Use |
|----------|-----|
| `COUNT()` | Count rows |
| `SUM()` | Sum values |
| `AVG()` | Average |
| `MIN()`, `MAX()` | Extremes |
| `GROUP BY` | Group rows for aggregation |
| `HAVING` | Filter groups |
| `WITH ... AS` | CTE |
| `WITH RECURSIVE` | Recursive CTE |
| `ROW_NUMBER()` | Sequential row number |
| `RANK()`, `DENSE_RANK()` | Ranking |
| `LAG()`, `LEAD()` | Access previous/next row |
| `SUM() OVER()` | Running total |
| `PARTITION BY` | Divide rows into groups |
| `ORDER BY` within `OVER` | Ordering for window |

## End of Part 2

You have now completed Part 2 of the series. You have learned:

- CRUD operations: `INSERT`, `SELECT`, `UPDATE`, `DELETE` with sorting, limiting, and deduplication.
- Advanced filtering with `WHERE`, `LIKE`, `GLOB`, `BETWEEN`, `IN`, `CASE`, and `NULL` handling.
- Joins: `INNER`, `LEFT`, `CROSS`, and `SELF` to combine data from multiple tables.
- Aggregations: `GROUP BY`, `HAVING`, aggregate functions, CTEs, and window functions.

With these skills, you can already build powerful queries for reporting and analytics. In **Part 3: Database Design**, we will focus on designing efficient schemas, normalization, and modeling real‑world domains.
