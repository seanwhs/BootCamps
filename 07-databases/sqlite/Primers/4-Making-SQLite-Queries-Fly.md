# Indexing and Performance Primer 4: Making SQLite Queries Fly

You've designed your schema, written your queries, and loaded your data. But as your database grows, queries start to slow down. This primer gives you the essential tools to **make SQLite fast**—without diving into every advanced detail.

The golden rule: **Indexes are to databases what alphabetical order is to a phone book.**

---

## 1. What Is an Index?

An **index** is a separate data structure (a B‑Tree) that stores the values of one or more columns in sorted order, along with pointers to the actual rows. When you query by an indexed column, SQLite can **jump directly** to the matching rows instead of scanning the entire table.

### Without an Index (Full Table Scan)
```
SELECT * FROM users WHERE last_name = 'Smith';
```
SQLite reads every row in the `users` table, checking if `last_name = 'Smith'`. For 1 million rows, that's a million checks.

### With an Index
```
CREATE INDEX idx_users_last_name ON users(last_name);
```
Now SQLite uses the index to find the exact rows where `last_name = 'Smith'` in **logarithmic time** (like flipping to the "S" section of a phone book).

---

## 2. When to Create an Index

| Situation | Recommendation |
|-----------|----------------|
| Queries frequently filter by a column (`WHERE`) | **Index it.** |
| Queries frequently join on a column (foreign keys) | **Index the foreign key.** |
| Queries frequently sort or group by a column (`ORDER BY`, `GROUP BY`) | **Index it.** |
| Column has **high selectivity** (many distinct values) | Very effective. |
| Column is **updated infrequently** | Low maintenance cost. |
| Table has **many rows** (>1000) | Indexes become beneficial. |

### When NOT to Index

| Situation | Reason |
|-----------|--------|
| Table is tiny (<100 rows) | Full scan is faster than index lookup. |
| Column has **low selectivity** (e.g., boolean, 50/50 split) | Index doesn't narrow search much. |
| Column is **frequently updated** | Each update requires index maintenance. |
| Query never uses the column in `WHERE`, `JOIN`, `ORDER BY`, or `GROUP BY` | Useless. |
| You have **too many indexes** on the same table | Slows inserts/updates; keep it minimal. |

---

## 3. Types of Indexes in SQLite

### Single‑Column Index
```sql
CREATE INDEX idx_last_name ON users(last_name);
```
Use for queries on a single column.

### Composite Index (Multiple Columns)
```sql
CREATE INDEX idx_last_name_first_name ON users(last_name, first_name);
```
This can be used for:
- `WHERE last_name = 'Smith'`
- `WHERE last_name = 'Smith' AND first_name = 'John'`
**But not** for:
- `WHERE first_name = 'John'` (the leftmost column `last_name` is missing).

**Rule:** Put the most selective columns first.

### Unique Index
```sql
CREATE UNIQUE INDEX idx_email ON users(email);
```
Enforces uniqueness and speeds up lookups. Often created automatically by a `UNIQUE` constraint.

### Partial Index (Index a Subset)
```sql
CREATE INDEX idx_active_users ON users(last_name) WHERE active = 1;
```
Saves space and speeds up queries that only target active users.

### Expression Index (Index a Function Result)
```sql
CREATE INDEX idx_upper_last_name ON users(UPPER(last_name));
```
Useful for case‑insensitive searches.

### Covering Index (All Columns in the Query)
```sql
CREATE INDEX idx_cover ON orders(customer_id, total, date);
```
If you query only those columns, SQLite can satisfy the query entirely from the index—**without reading the table at all**—which is extremely fast.

---

## 4. How to Check If an Index Is Used

Use `EXPLAIN QUERY PLAN` to see the execution plan.

```sql
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'Smith';
```
If you see:
```
SEARCH users USING INDEX idx_users_last_name
```
—great! The index is being used.

If you see:
```
SCAN users
```
—it's a full table scan. You need an index (or the planner thinks it's cheaper without one).

---

## 5. Essential PRAGMA Settings for Performance

PRAGMAs control SQLite's runtime behavior. Start with these:

```sql
-- Use Write‑Ahead Logging for better concurrency and speed
PRAGMA journal_mode = WAL;

-- Balanced safety vs. performance (FULL is safest, OFF is fastest)
PRAGMA synchronous = NORMAL;

-- Increase the page cache (more memory = fewer disk reads)
PRAGMA cache_size = 10000;   -- 10,000 pages (about 40 MB)

-- Wait up to 5 seconds if the database is locked
PRAGMA busy_timeout = 5000;

-- Enable memory‑mapped I/O for large databases (256 MB)
PRAGMA mmap_size = 268435456;
```

---

## 6. Query Optimization Tips

### Avoid Functions on Indexed Columns
```sql
-- Bad: won't use index if we have one on last_name
SELECT * FROM users WHERE UPPER(last_name) = 'SMITH';

-- Good: use an expression index
CREATE INDEX idx_upper_last_name ON users(UPPER(last_name));
```

### Use `EXISTS` Instead of `IN` for Subqueries
```sql
-- Often slower
SELECT * FROM users WHERE id IN (SELECT user_id FROM orders);

-- Usually faster
SELECT * FROM users WHERE EXISTS (SELECT 1 FROM orders WHERE user_id = users.id);
```

### Prefer `LIKE` Without Leading Wildcard
```sql
-- Can use index on 'name'
SELECT * FROM users WHERE name LIKE 'John%';

-- Cannot use index
SELECT * FROM users WHERE name LIKE '%Smith%';
```

### Limit the Result Set
```sql
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;
```

### Select Only Needed Columns
```sql
-- Avoid SELECT * unless you need all columns
SELECT id, name, email FROM users WHERE active = 1;
```

---

## 7. Performance Tuning Checklist

- [ ] Enable **WAL** mode.
- [ ] Set `synchronous = NORMAL`.
- [ ] Set a reasonable `cache_size`.
- [ ] Set `busy_timeout`.
- [ ] Create indexes on all foreign keys and frequently‑queried columns.
- [ ] Use **covering indexes** for hot queries.
- [ ] Run `ANALYZE` after bulk data changes (updates statistics).
- [ ] Use `EXPLAIN QUERY PLAN` to verify index usage.
- [ ] Avoid functions on indexed columns in `WHERE`.
- [ ] Batch writes in transactions.

---

## 8. Running `ANALYZE`

The query planner uses statistics to choose the best indexes. Run this after loading data or after major changes:

```sql
ANALYZE;
```

This populates `sqlite_stat1`‑`sqlite_stat4` tables.

---

## 9. When Queries Are Still Slow

If indexes and PRAGMAs don't solve it:

- **Re‑write the query** – use CTEs, break into steps, try different join orders.
- **Check for fragmentation** – run `VACUUM` to defragment.
- **Monitor disk I/O** – if the database is on a slow disk, consider moving it to SSD.
- **Consider denormalization** – for read‑heavy workloads, pre‑compute aggregates.
- **Upgrade hardware** – more RAM and faster storage help.

---

## 10. Quick Reference: Index Types

| Type | Syntax | Use Case |
|------|--------|----------|
| Single‑column | `CREATE INDEX idx_col ON table(col)` | Simple lookups. |
| Composite | `CREATE INDEX idx_col1_col2 ON table(col1, col2)` | Multi‑column filters. |
| Unique | `CREATE UNIQUE INDEX idx_col ON table(col)` | Uniqueness + lookups. |
| Partial | `CREATE INDEX idx_col ON table(col) WHERE condition` | Subset of rows. |
| Expression | `CREATE INDEX idx_expr ON table(expr)` | Function‑based lookups. |
| Covering | `CREATE INDEX idx_cover ON table(a, b, c)` | All columns in query. |

---

## 11. Real‑World Example

**Scenario:** A `orders` table with 1,000,000 rows. You frequently query by `customer_id` and `order_date`.

```sql
-- Slow (full table scan)
SELECT * FROM orders WHERE customer_id = 12345;

-- Solution: create an index on customer_id
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Now fast: index lookup

-- For queries with both columns:
SELECT * FROM orders WHERE customer_id = 12345 AND order_date > '2025-01-01';
-- Create a composite index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- For a weekly report that only needs customer_id, total, and date:
SELECT customer_id, total, order_date FROM orders WHERE order_date BETWEEN '2025-01-01' AND '2025-01-07';
-- A covering index avoids reading the table
CREATE INDEX idx_cover_orders ON orders(order_date, customer_id, total);
```

---

## Next Steps

- Learn **transaction management** to keep your data consistent.
- Explore **full‑text search (FTS5)** for searching text.
- Dive into **JSON support** for flexible data.
- Study **query planner** in depth.
- Apply these techniques in the **Master SQLite** series.

---

This primer gives you the 80% of indexing knowledge that you'll use 100% of the time. When in doubt: **measure first, index second, and always verify with `EXPLAIN QUERY PLAN`.**

Happy tuning!
