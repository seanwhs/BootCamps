Welcome to Part 4. You have learned how to design clean schemas and write powerful queries. Now we tackle the most critical aspect of database engineering: **speed**. A well-indexed database can be hundreds of times faster than an unindexed one. This part demystifies indexes, the query planner, and performance tuning. You will learn not just *how* to create indexes, but *when* and *why* they work—and when they don't.

**Part 4** is divided into three modules:

- **Module 11:** SQLite Indexes – B‑Tree, composite, partial, covering, expression, and unique indexes.
- **Module 12:** Query Planner – Using `EXPLAIN` and `EXPLAIN QUERY PLAN` to understand and tune queries.
- **Module 13:** Performance Engineering – PRAGMA tuning, memory settings, bulk operations, `VACUUM`, and `ANALYZE`.

Let’s get started.

---

# Part 4: Indexing & Query Optimization

## Module 11: SQLite Indexes

### The Target

By the end of this module, you will know how to create and use various types of indexes to dramatically speed up `SELECT`, `UPDATE`, and `DELETE` operations. You will also understand the trade‑offs: indexes speed up reads but slow down writes and consume disk space.

### The Concept

Imagine you have a huge phone book with names and phone numbers, but the names are *not* sorted—they are in random order. To find "John Smith", you would have to scan every single page until you find him. That's a **full table scan**. Now imagine the phone book is sorted alphabetically—you can flip directly to the "S" section and find John instantly. That's an **index**.

An index is a separate data structure (a B‑Tree) that stores the values of one or more columns in sorted order, along with pointers to the actual rows. When you query by an indexed column, SQLite can use the index to quickly locate the rows without scanning the entire table.

### Types of Indexes in SQLite

1. **B‑Tree Index** – The default, balanced tree.
2. **Composite Index** – On multiple columns.
3. **Unique Index** – Enforces uniqueness; can be part of `UNIQUE` constraint.
4. **Partial Index** – Only indexes a subset of rows (using a `WHERE` clause).
5. **Covering Index** – An index that contains all the columns needed by a query, so the table itself doesn't need to be accessed (very fast).
6. **Expression Index** – Index on the result of an expression (e.g., `UPPER(name)`).

### Hands‑on Lab 11.1: Creating and Measuring Indexes

We'll use a test database with a large table to see the effect of indexes. We'll generate a million rows.

#### Setup

Create a new database `perf.db`:

```bash
sqlite3 perf.db
```

Create a table `users` with several columns:

```sql
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    age INTEGER,
    city TEXT,
    registered_date TEXT
);
```

Now, insert 1,000,000 rows. To avoid a slow loop, we'll use the `generate_series` virtual table (available in SQLite 3.40+). If your version doesn't have it, you can use a recursive CTE.

```sql
-- Enable the generate_series extension (if available)
-- If not, you can use a recursive CTE as shown later

-- Insert 1 million rows using generate_series (fast)
INSERT INTO users (first_name, last_name, email, age, city, registered_date)
SELECT 
    'FirstName' || value,
    'LastName' || value,
    'user' || value || '@example.com',
    (value % 80) + 18, -- ages 18-97
    CASE (value % 5)
        WHEN 0 THEN 'New York'
        WHEN 1 THEN 'Los Angeles'
        WHEN 2 THEN 'Chicago'
        WHEN 3 THEN 'Houston'
        WHEN 4 THEN 'Phoenix'
    END,
    datetime('now', '-' || (value % 1000) || ' days')
FROM generate_series(1, 1000000);

-- If generate_series is not available, use a recursive CTE (slower but works)
-- WITH RECURSIVE cnt(x) AS (SELECT 1 UNION ALL SELECT x+1 FROM cnt WHERE x < 1000000)
-- INSERT INTO users (first_name, last_name, email, age, city, registered_date)
-- SELECT ... FROM cnt;
```

#### Verification

Check the row count:

```sql
SELECT COUNT(*) FROM users;
-- Should return 1000000
```

Check the query time using `.timer on`:

```sql
.timer on
SELECT * FROM users WHERE last_name = 'LastName500000';
```

This will likely take ~0.2-0.5 seconds (or more) because it's scanning 1M rows. Note the time.

Now, create an index on `last_name`:

```sql
CREATE INDEX idx_users_last_name ON users(last_name);
```

Now run the same query again:

```sql
SELECT * FROM users WHERE last_name = 'LastName500000';
```

You should see a dramatic speed improvement (maybe 10-100x faster). That's the power of an index.

#### Measuring Performance with EXPLAIN QUERY PLAN

```sql
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'LastName500000';
```

You should see `SEARCH users USING INDEX idx_users_last_name` instead of `SCAN users`. This confirms the index is used.

---

### Composite Indexes

A composite index is on multiple columns. It is useful for queries that filter on several columns.

**Example:** Find users with a given last name in a given city.

```sql
-- Without index, full scan
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'Smith' AND city = 'New York';

-- Create composite index
CREATE INDEX idx_users_lastname_city ON users(last_name, city);

-- Now the query will use the index
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'Smith' AND city = 'New York';
```

**Order matters:** The index can be used for queries that filter on the leftmost columns. For example, `idx_users_lastname_city` can be used for:
- `WHERE last_name = ?`
- `WHERE last_name = ? AND city = ?`
But not for:
- `WHERE city = ?` (because last_name is not specified).

---

### Partial Indexes

Index only a subset of rows. This saves space and speeds up queries that target that subset.

**Example:** Index only users who are above 60, because we often query for seniors.

```sql
CREATE INDEX idx_users_age_gt_60 ON users(age) WHERE age > 60;
```

Query:

```sql
SELECT * FROM users WHERE age > 60 AND city = 'New York';
-- The index will be used for the age filter, but it only includes rows with age > 60.
```

---

### Covering Index

If an index contains all the columns needed by a query, SQLite can satisfy the query entirely from the index without reading the table. This is extremely fast.

**Example:** We frequently query for `last_name` and `email` but don't need other columns.

```sql
CREATE INDEX idx_users_lastname_email ON users(last_name, email);
```

Now query:

```sql
SELECT last_name, email FROM users WHERE last_name = 'LastName500000';
```

`EXPLAIN QUERY PLAN` will show `USING COVERING INDEX idx_users_lastname_email`. The table is not touched.

---

### Expression Indexes

Index on the result of an expression. Useful for case‑insensitive searches.

```sql
CREATE INDEX idx_users_upper_lastname ON users(UPPER(last_name));
```

Query:

```sql
SELECT * FROM users WHERE UPPER(last_name) = 'SMITH';
```

---

### Unique Indexes

Create a unique index to enforce uniqueness and speed up lookups on that column. The `UNIQUE` constraint automatically creates a unique index.

```sql
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

---

### Automatic Indexes

SQLite may create a temporary index automatically during query execution if it thinks it will help. This is usually for joins. You can't control them directly, but they indicate that you might want to create a permanent index.

---

### When to Use Indexes (and When Not to)

**Use indexes when:**
- Queries filter on the column frequently.
- The column has high selectivity (many distinct values).
- You need to enforce uniqueness.
- You have covering indexes for common queries.

**Avoid indexes when:**
- The table is small (scanning is cheaper).
- The column is frequently updated (index maintenance cost).
- The index has low selectivity (e.g., a boolean column).
- You have too many indexes (each one slows down writes).

---

### Hands‑on Lab 11.2: Index Tuning Experiment

We will measure the performance difference with and without indexes on various query patterns.

1. **Scenario:** Query by `age` and `city`. Create a composite index and compare.

   ```sql
   -- Without index
   .timer on
   SELECT * FROM users WHERE age = 30 AND city = 'Chicago';
   -- Note time

   -- Create index
   CREATE INDEX idx_users_age_city ON users(age, city);

   -- Again
   SELECT * FROM users WHERE age = 30 AND city = 'Chicago';
   ```

2. **Scenario:** Query by `city` only. The composite index won't help (since `age` is not specified). We need a separate index on `city`.

   ```sql
   CREATE INDEX idx_users_city ON users(city);
   SELECT * FROM users WHERE city = 'Houston';
   ```

3. **Scenario:** Query with a `LIKE` pattern. If the pattern starts with a wildcard (`%`), the index cannot be used effectively. If it does not start with `%`, the index can be used.

   ```sql
   -- Index can be used
   SELECT * FROM users WHERE last_name LIKE 'Smith%';

   -- Index cannot be used effectively
   SELECT * FROM users WHERE last_name LIKE '%Smith%';
   ```

4. **Scenario:** Use `EXPLAIN QUERY PLAN` to see if the index is used.

---

### Verification Checklist

- Run `EXPLAIN QUERY PLAN` for all queries and confirm the scan type.
- Use `.timer on` to measure actual execution time.
- Check the size of the database before and after creating indexes: `ls -l perf.db`. Indexes take space; you may see the file grow.

---

**[GENERATED: Part 4, Module 11: SQLite Indexes]**

---

## Module 12: Query Planner

### The Target

Learn how SQLite decides which indexes to use and how to read the output of `EXPLAIN` and `EXPLAIN QUERY PLAN`. Understand cost estimation, join order, and how to rewrite queries to guide the planner.

### The Concept

The query planner is like a GPS navigation system for your database. It evaluates multiple routes (indexes, scan types, join orders) and chooses the one with the lowest estimated cost. The estimates are based on statistics collected by `ANALYZE`.

We will use `EXPLAIN QUERY PLAN` to see the planner's decision. For deeper insight, `EXPLAIN` gives the bytecode.

### Understanding EXPLAIN QUERY PLAN Output

The output shows a tree of operations. Common operations:

- **SCAN table** – full table scan.
- **SEARCH table USING INDEX** – index lookup.
- **SEARCH table USING COVERING INDEX** – index-only scan.
- **USE TEMP B-TREE** – temporary index for sorting/grouping.
- **JOIN** – nested loops.

**Example:**

```
QUERY PLAN
|--SEARCH users USING INDEX idx_users_last_name (last_name=?)
`--JOIN (no join here)
```

### Cost Estimation

SQLite estimates the cost of a query as the number of disk pages it expects to read. The cost of a table scan is proportional to the number of rows. An index search cost is roughly the depth of the B‑Tree plus the number of rows retrieved.

`ANALYZE` collects statistics about the distribution of values in each column. The planner uses these to estimate selectivity.

### Hands‑on Lab 12.1: Analyzing Query Plans

We'll use the `perf.db` database from Module 11.

**1. Basic Query with Index**

```sql
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'LastName500000';
```

**2. Query with a Composite Index**

Ensure we have `idx_users_lastname_city` and run:

```sql
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'LastName500000' AND city = 'New York';
```

**3. Query that forces a table scan**

```sql
-- Use an expression that prevents index use
EXPLAIN QUERY PLAN SELECT * FROM users WHERE UPPER(last_name) = 'SMITH';
-- If we have an expression index, it would be used, but otherwise table scan.
```

**4. Query with sorting**

```sql
EXPLAIN QUERY PLAN SELECT * FROM users ORDER BY last_name LIMIT 10;
```

If there is no index on `last_name`, the planner will do a table scan and sort (using a temp B‑Tree). If we have an index, it may use it to avoid sorting.

**5. Query with JOIN**

Let's add a second table `orders` and see the join plan.

```sql
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    order_date TEXT,
    amount REAL,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Insert some sample orders (say 100k)
INSERT INTO orders (user_id, order_date, amount)
SELECT 
    (abs(random()) % 1000000) + 1,  -- random user_id between 1 and 1e6
    datetime('now', '-' || (abs(random()) % 365) || ' days'),
    (abs(random()) % 10000) / 100.0
FROM generate_series(1, 100000);

CREATE INDEX idx_orders_user ON orders(user_id);

-- Now query to join users and orders
EXPLAIN QUERY PLAN
SELECT u.first_name, u.last_name, o.order_date, o.amount
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE u.last_name = 'LastName500000';
```

You will see an execution plan that likely uses the index on `last_name` for users, then loops over orders using the index on `user_id`.

### Forcing the Planner (Hinting)

SQLite does not have index hints like other databases. However, you can influence the planner by:
- Using `CROSS JOIN` to force a join order (but be careful).
- Using `INDEXED BY` to force a specific index.

Example:

```sql
SELECT * FROM users INDEXED BY idx_users_last_name WHERE last_name = 'Smith';
```

But this is rarely needed; the planner does a good job.

### When the Planner Gets It Wrong

Sometimes the statistics are stale. Run `ANALYZE;` to update them. If the planner still makes a poor choice, you can restructure your query or create better indexes.

### Hands‑on Lab 12.2: Using ANALYZE

```sql
ANALYZE;
```

Then re-run `EXPLAIN QUERY PLAN` for a query and see if the plan changes. If you have a lot of data, `ANALYZE` will populate the `sqlite_stat1` table, which the planner reads.

---

### Reference: EXPLAIN Bytecode (Advanced)

For deep debugging, use `EXPLAIN` (not `EXPLAIN QUERY PLAN`). It shows the VDBE instructions. You won't need this often, but it's useful to understand the low‑level operations.

```sql
EXPLAIN SELECT * FROM users WHERE last_name = 'Smith';
```

You'll see opcodes like `OpenRead`, `SeekGe`, `IdxGT`, etc. This is for advanced tuning.

---

**[GENERATED: Part 4, Module 12: Query Planner]**

---

## Module 13: Performance Engineering

### The Target

Go beyond indexes and learn how to tune SQLite's runtime parameters, manage memory, handle bulk operations, and perform maintenance tasks like `VACUUM` and `ANALYZE`. You will also learn benchmarking techniques.

### The Concept

Even with perfect indexes, SQLite's performance can be affected by configuration settings (PRAGMAs), cache size, journal mode, and how you structure your transactions. This module covers the most impactful tunables and best practices for high‑performance scenarios.

### PRAGMA Statements for Performance

PRAGMAs are special commands to query or modify the database's behavior.

**1. Cache Size** – How much memory to allocate for the page cache (in pages). Larger cache reduces disk I/O.

```sql
-- Show current cache size (number of pages)
PRAGMA cache_size;

-- Set to 10000 pages (roughly 40MB if page size is 4096)
PRAGMA cache_size = 10000;
```

**2. Page Size** – The size of each page in bytes. Set when the database is created.

```sql
PRAGMA page_size;  -- default 4096
-- Can only be changed with VACUUM if the database is empty
```

**3. Journal Mode** – Controls how transactions are logged. `WAL` (Write‑Ahead Logging) is recommended for most applications because it improves concurrency and performance.

```sql
PRAGMA journal_mode = WAL;
```

We will cover WAL in depth in Part 5, but for now know that it enables concurrent reads and writes and reduces disk I/O.

**4. Synchronous** – Controls how aggressively SQLite syncs to disk. Options: `OFF`, `NORMAL`, `FULL`. `FULL` is safest but slower; `OFF` is fastest but may lead to corruption on crash.

```sql
PRAGMA synchronous = NORMAL;  -- good balance
```

**5. Temp Store** – Where to store temporary tables and indices. `MEMORY` is fastest.

```sql
PRAGMA temp_store = MEMORY;
```

**6. Memory Mapping** – Enable memory‑mapped I/O for large databases.

```sql
PRAGMA mmap_size = 30000000000;  -- 30GB, if your system supports it
```

### Bulk Loading Optimization

When inserting millions of rows, you can speed things up dramatically:

- Wrap inserts in a transaction (fewer disk syncs).
- Use `PRAGMA synchronous = OFF` and `PRAGMA journal_mode = OFF` temporarily (but be careful).
- Use prepared statements (in programming languages) with parameter binding.
- If you have to insert many rows, use `INSERT INTO ... VALUES (...), (...), ...` multi‑row inserts.

**Hands‑on:**

```sql
-- Turn off synchronization for speed (use with caution)
PRAGMA synchronous = OFF;
PRAGMA journal_mode = OFF;

BEGIN TRANSACTION;
-- Insert many rows here...
COMMIT;

-- Re-enable safe settings
PRAGMA synchronous = NORMAL;
PRAGMA journal_mode = WAL;
```

### VACUUM and Auto‑Vacuum

`VACUUM` rebuilds the database file, defragmenting it and reclaiming unused space. It can reduce file size and improve performance.

```sql
VACUUM;
```

`auto_vacuum` can be enabled to automatically shrink the database when pages are freed.

```sql
PRAGMA auto_vacuum = FULL;  -- or INCREMENTAL
```

Note: `VACUUM` requires free disk space equal to the database size (it creates a new file).

### ANALYZE for Statistics

We covered `ANALYZE` in Module 12. Run it regularly after bulk data changes to keep statistics fresh.

```sql
ANALYZE;
```

### Benchmarking with .timer and .echo

Use `.timer on` to measure execution time. Use `.echo on` to show commands.

**Example:**

```sql
.timer on
SELECT COUNT(*) FROM users WHERE age = 30;
```

You can also use the `time()` function to measure within queries, but `.timer` is easier.

### Hands‑on Lab 13.1: Tuning for a Bulk Insert

Create a new database `bulk.db` and test the impact of transaction wrapping and PRAGMA settings.

```sql
-- Without transaction
.timer on
CREATE TABLE test (id INTEGER, name TEXT);
INSERT INTO test (id, name) SELECT value, 'name' || value FROM generate_series(1, 100000);
-- Note the time (maybe 1-2 seconds)

-- With transaction
BEGIN;
INSERT INTO test (id, name) SELECT value, 'name' || value FROM generate_series(100001, 200000);
COMMIT;
-- Much faster (maybe <0.5 sec)

-- Now with PRAGMA synchronous=OFF, journal_mode=OFF
PRAGMA synchronous = OFF;
PRAGMA journal_mode = OFF;
BEGIN;
INSERT INTO test (id, name) SELECT value, 'name' || value FROM generate_series(200001, 300000);
COMMIT;
-- Even faster, but risk of corruption if crash occurs
```

### Hands‑on Lab 13.2: Memory Tuning

Test the effect of cache size on a query that repeatedly scans.

```sql
-- Set cache small
PRAGMA cache_size = 100;
.timer on
SELECT COUNT(*) FROM users WHERE city = 'New York'; -- slow

-- Increase cache
PRAGMA cache_size = 100000;
SELECT COUNT(*) FROM users WHERE city = 'New York'; -- faster (if repeated)
```

### Production Checklist

For a production system:

- Use `WAL` journal mode.
- Set `synchronous = NORMAL` (or `FULL` if data safety is paramount).
- Set an appropriate cache size (e.g., 10-20% of available RAM).
- Run `ANALYZE` periodically.
- Enable `mmap_size` for large databases.
- Use transactions for batches.
- Consider `auto_vacuum = INCREMENTAL` to avoid large VACUUM pauses.
- Regularly monitor performance with `EXPLAIN QUERY PLAN`.

---

### Verification for Part 4

Run the following to confirm you have mastered the content:

1. Create an index on `age` and `city`; run `EXPLAIN QUERY PLAN` on a query filtering on both.
2. Measure the speed difference before and after.
3. Set `PRAGMA cache_size` to a high value and re‑run a query to see improvement.
4. Use `VACUUM` on `perf.db` and check file size reduction.
5. Demonstrate a composite index that is used for a query on the first column only, and not for the second column alone.

All these exercises should work as described.

## End of Part 4

You have now learned the core performance toolkit for SQLite. You can create indexes of various types, read execution plans, and tune runtime parameters. These skills are essential for any production system.

In **Part 5: Transactions & Concurrency**, we will dive deep into ACID, journaling, WAL, and recovery mechanisms. You will learn how to build robust, concurrent applications that handle failures gracefully.

