# SQL Primer 2: Writing Queries in SQLite

This primer is your **crash course** in SQL (Structured Query Language) as used in SQLite. You'll learn how to retrieve, filter, combine, and summarize data—the essential skills you'll use in 90% of your work.

---

## What Is SQL?

SQL is the language we use to talk to relational databases. It's declarative: you tell the database *what* you want, and it figures out *how* to get it. Think of it as asking a librarian for "all books by J.R.R. Tolkien" rather than manually browsing every shelf.

---

## Your Sample Data

We'll use a small library database for our examples. You can create it by running these commands in the SQLite shell:

```sql
-- Create tables
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    author_id INTEGER,
    year INTEGER,
    pages INTEGER,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- Insert sample data
INSERT INTO authors (name) VALUES
    ('J.R.R. Tolkien'),
    ('George Orwell'),
    ('Aldous Huxley'),
    ('Isaac Asimov'),
    ('Arthur C. Clarke');

INSERT INTO books (title, author_id, year, pages) VALUES
    ('The Hobbit', 1, 1937, 310),
    ('The Lord of the Rings', 1, 1954, 1178),
    ('1984', 2, 1949, 328),
    ('Animal Farm', 2, 1945, 112),
    ('Brave New World', 3, 1932, 288),
    ('Foundation', 4, 1951, 244),
    ('2001: A Space Odyssey', 5, 1968, 256);
```

---

## 1. SELECT Basics

### Retrieve All Columns
```sql
SELECT * FROM books;
```

### Retrieve Specific Columns
```sql
SELECT title, year FROM books;
```

### Use Aliases (Rename in Output)
```sql
SELECT title AS "Book Title", year AS "Publication Year" FROM books;
```

### Remove Duplicates with `DISTINCT`
```sql
SELECT DISTINCT author_id FROM books;
```

---

## 2. Filtering with `WHERE`

The `WHERE` clause filters rows based on a condition.

### Equality
```sql
SELECT * FROM books WHERE author_id = 1;
```

### Comparison
```sql
SELECT * FROM books WHERE year > 1950;
```

### Multiple Conditions (`AND`, `OR`, `NOT`)
```sql
SELECT * FROM books WHERE year > 1940 AND author_id = 2;
```

### Range (`BETWEEN`)
```sql
SELECT * FROM books WHERE year BETWEEN 1940 AND 1960;
```

### List (`IN`)
```sql
SELECT * FROM books WHERE author_id IN (1, 3, 5);
```

### Pattern Matching (`LIKE`)
- `%` = any sequence of characters
- `_` = single character

```sql
SELECT * FROM books WHERE title LIKE '%Lord%';
```

### NULL Values (special handling)
```sql
SELECT * FROM books WHERE pages IS NOT NULL;
```

---

## 3. Sorting with `ORDER BY`

```sql
-- Ascending (default)
SELECT title, year FROM books ORDER BY year;

-- Descending
SELECT title, year FROM books ORDER BY year DESC;

-- Multiple columns
SELECT title, year FROM books ORDER BY author_id, year DESC;
```

---

## 4. Limiting Results

### Top N rows
```sql
SELECT * FROM books ORDER BY pages DESC LIMIT 3;
```

### Pagination with `OFFSET`
```sql
SELECT * FROM books LIMIT 3 OFFSET 3;  -- skip 3, take next 3
```

---

## 5. Aggregations (Summarising Data)

Aggregate functions compute a single value from a group of rows.

### Common Functions
| Function | Description |
|----------|-------------|
| `COUNT(*)` | Number of rows |
| `COUNT(column)` | Number of non‑NULL values |
| `SUM(column)` | Sum of values |
| `AVG(column)` | Average |
| `MIN(column)` | Minimum |
| `MAX(column)` | Maximum |

### Examples
```sql
SELECT COUNT(*) AS total_books FROM books;
SELECT AVG(pages) AS avg_pages FROM books;
SELECT MAX(year) AS latest_book FROM books;
```

### Using `GROUP BY`
Groups rows that share a value in a column, then applies aggregations per group.

```sql
SELECT author_id, COUNT(*) AS book_count
FROM books
GROUP BY author_id;
```

### Filtering Groups with `HAVING`
`HAVING` is like `WHERE` but for groups (after `GROUP BY`).

```sql
SELECT author_id, COUNT(*) AS book_count
FROM books
GROUP BY author_id
HAVING COUNT(*) > 1;   -- authors with more than one book
```

---

## 6. Joins (Combining Tables)

### `INNER JOIN`
Returns rows when there is a match in both tables.

```sql
SELECT books.title, authors.name
FROM books
JOIN authors ON books.author_id = authors.author_id;
```

### `LEFT JOIN`
Returns all rows from the left table, even if no match in the right table. Missing values are `NULL`.

```sql
-- Add a book with no author (to demonstrate)
INSERT INTO books (title, author_id, year) VALUES ('Unknown Book', NULL, 2020);

SELECT books.title, authors.name
FROM books
LEFT JOIN authors ON books.author_id = authors.author_id;
```

### Joining Multiple Tables
If you have a junction table for many‑to‑many relationships (e.g., books and authors, but we have one author per book), you can chain joins.

---

## 7. Subqueries (Nested Queries)

A query inside another query.

### Subquery in `WHERE`
Find books written by authors born after 1900 (assume we had a `birth_year` column).
But with our data, we can find books from authors who have a book with more than 300 pages:

```sql
SELECT title FROM books
WHERE author_id IN (
    SELECT author_id FROM books WHERE pages > 300
);
```

### Subquery in `SELECT` (Scalar)
```sql
SELECT title, (SELECT COUNT(*) FROM books) AS total_books FROM books LIMIT 1;
```

---

## 8. Common Table Expressions (CTEs)

CTEs make complex queries more readable. They're like temporary named result sets.

```sql
WITH long_books AS (
    SELECT * FROM books WHERE pages > 300
)
SELECT title, year FROM long_books;
```

### Recursive CTE (Advanced)
Useful for hierarchical data (e.g., tree structures).

```sql
WITH RECURSIVE numbers(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 5
)
SELECT n FROM numbers;
```

---

## 9. Window Functions (Powerful Analytics)

Window functions perform calculations across a set of rows related to the current row, without collapsing them.

### Ranking
```sql
SELECT title, pages,
    RANK() OVER (ORDER BY pages DESC) AS page_rank
FROM books;
```

### Running Total
```sql
SELECT title, pages,
    SUM(pages) OVER (ORDER BY title) AS running_total
FROM books;
```

### Partitioned Windows
```sql
SELECT title, author_id, pages,
    ROW_NUMBER() OVER (PARTITION BY author_id ORDER BY pages DESC) AS rank_in_author
FROM books;
```

---

## 10. Changing Data (CRUD)

### Insert
```sql
INSERT INTO books (title, author_id, year, pages) VALUES ('New Book', 1, 2025, 200);
```

### Update
```sql
UPDATE books SET pages = 350 WHERE book_id = 1;
```
**Always** include a `WHERE` clause, or you'll update every row.

### Delete
```sql
DELETE FROM books WHERE book_id = 10;
```

---

## Quick Reference: SQL Clauses Order

When writing a full `SELECT` query, clauses must appear in this order:

1. `WITH` (CTEs)
2. `SELECT`
3. `FROM`
4. `JOIN` / `ON`
5. `WHERE`
6. `GROUP BY`
7. `HAVING`
8. `ORDER BY`
9. `LIMIT` / `OFFSET`

---

## Practice Exercises

1. List all books published before 1950, sorted by title.
   ```sql
   SELECT title, year FROM books WHERE year < 1950 ORDER BY title;
   ```

2. Find the number of books by each author, showing the author's name.
   ```sql
   SELECT authors.name, COUNT(books.book_id) AS book_count
   FROM authors
   LEFT JOIN books ON authors.author_id = books.author_id
   GROUP BY authors.author_id;
   ```

3. Find the oldest and newest book in the library.
   ```sql
   SELECT MIN(year) AS oldest, MAX(year) AS newest FROM books;
   ```

4. Get a list of authors who have written more than one book (using `HAVING`).
   ```sql
   SELECT author_id, COUNT(*) FROM books GROUP BY author_id HAVING COUNT(*) > 1;
   ```

5. Using a CTE, find the book with the most pages.
   ```sql
   WITH max_pages AS (SELECT MAX(pages) AS max FROM books)
   SELECT title, pages FROM books WHERE pages = (SELECT max FROM max_pages);
   ```

---

## Next Steps

You now know the essential SQL toolkit. To go further:

- Learn about **database design** (normalization, ER modeling)
- Master **indexes** and query optimization
- Explore **transactions** and concurrency
- Integrate SQLite into your favourite programming language
- Dive into **JSON** and **full‑text search** (FTS5)

Check out the **Master SQLite** series for the complete journey.

---

Happy querying!
