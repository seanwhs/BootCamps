# Appendix I: Performance Tuning and Optimization Guide

This appendix consolidates all the performance tuning principles, PRAGMA settings, index strategies, and best practices from the series. Use it as a checklist when optimizing your SQLite databases for speed, scalability, and resource efficiency.

---

## 1. Index Selection Guidelines

Choosing the right index is the single most important performance decision. Use this decision tree:

### When to Create an Index

| Condition | Recommendation |
|-----------|----------------|
| Queries frequently filter on a column (WHERE clause) | Create an index on that column. |
| Queries frequently join on a column (foreign keys) | Create an index on the foreign key column. |
| Queries frequently sort or group by a column (ORDER BY, GROUP BY) | Create an index on that column. |
| Column has high selectivity (many distinct values) | Index is highly effective. |
| Column is updated infrequently | Low maintenance cost; good candidate. |
| Column is used in a covering index (all columns in query are in the index) | Create a covering index for frequent queries. |
| Table is large (thousands of rows or more) | Indexes become beneficial. |
| Queries use range conditions (BETWEEN, >, <) | B‑Tree index works well. |

### When NOT to Create an Index

| Condition | Reason |
|-----------|--------|
| Table is very small (< 100 rows) | Full table scan is cheaper than index lookup. |
| Column has low selectivity (e.g., boolean) | Index will not reduce search space much; overhead is high. |
| Column is frequently updated | Each update requires index maintenance; slows writes. |
| Queries never use the column in WHERE, JOIN, ORDER BY, or GROUP BY | Index is never used; wasted space and maintenance. |
| Disk space is limited | Indexes take additional space (approx. 30‑50% of data size). |
| You have too many indexes on the same table | Each index slows INSERT/UPDATE/DELETE; keep it minimal. |

### Choosing the Right Index Type

| Index Type | Use Case | Example |
|------------|----------|---------|
| **B‑Tree (default)** | Most queries, equality and range filters. | `CREATE INDEX idx_name ON users(name)` |
| **Composite** | Queries that filter on multiple columns. | `CREATE INDEX idx_name_age ON users(name, age)` |
| **Unique** | Enforce uniqueness and speed up lookups on that column. | `CREATE UNIQUE INDEX idx_email ON users(email)` |
| **Partial** | Index only a subset of rows (e.g., active users). | `CREATE INDEX idx_active ON users(active) WHERE active = 1` |
| **Expression** | Queries that use expressions (UPPER, etc.). | `CREATE INDEX idx_upper_name ON users(UPPER(name))` |
| **Covering** | Include all columns needed by a query to avoid reading the table. | `CREATE INDEX idx_cover ON orders(customer_id, total, date)` |
| **WITHOUT ROWID** | When you want the primary key to be the B‑Tree key (avoid extra index). | `CREATE TABLE ... WITHOUT ROWID` |

### Composite Index Column Order

For a composite index `(a, b, c)`, the index can be used for:
- `WHERE a = ?`
- `WHERE a = ? AND b = ?`
- `WHERE a = ? AND b = ? AND c = ?`
But **not** for:
- `WHERE b = ?` (without `a`)
- `WHERE c = ?` (without `a` and `b`)

**Rule:** Put the most selective columns first, and columns used in equality comparisons before those used in range conditions.

---

## 2. PRAGMA Tuning Summary

| PRAGMA | Recommended Production Value | Impact |
|--------|------------------------------|--------|
| `journal_mode` | `WAL` | Best concurrency and performance. |
| `synchronous` | `NORMAL` (or `FULL` for critical data) | Balance speed vs. safety. |
| `cache_size` | `10000` – `100000` (pages) | Reduces disk I/O; set to 10‑20% of available RAM. |
| `busy_timeout` | `5000` (ms) | Prevents `SQLITE_BUSY`; retry before failing. |
| `mmap_size` | `268435456` (256 MB) or larger | Improves read performance for large databases. |
| `temp_store` | `MEMORY` | Faster temporary tables. |
| `wal_autocheckpoint` | `500` – `2000` (pages) | Control WAL growth and checkpoint frequency. |
| `auto_vacuum` | `INCREMENTAL` or `FULL` | Reclaims disk space; `INCREMENTAL` reduces vacuum pauses. |
| `foreign_keys` | `ON` | Enforces referential integrity (safety). |
| `secure_delete` | `OFF` (default) | Faster deletes; disable unless you need secure deletion. |
| `locking_mode` | `NORMAL` | Default is fine; use `EXCLUSIVE` for performance if only one writer. |

---

## 3. Query Optimization Checklist

### Before Writing a Query

- [ ] Do I really need all columns? `SELECT *` can be costly; list only needed columns.
- [ ] Can I limit the result set with `LIMIT` and `OFFSET`?
- [ ] Am I using `WHERE` clauses that are selective (narrow down many rows)?
- [ ] Are my `WHERE` clauses sargable (able to use indexes)? Avoid functions on indexed columns (e.g., `WHERE UPPER(name) = 'ALICE'` unless you have an expression index).
- [ ] Have I run `ANALYZE` recently to update statistics?
- [ ] Can I use `EXPLAIN QUERY PLAN` to check the execution plan?

### During Query Tuning

- [ ] Add indexes for all `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY` columns (after testing).
- [ ] Consider covering indexes for frequent queries.
- [ ] Rewrite `OR` conditions as `UNION` if they use different indexes.
- [ ] Use `IN` instead of multiple `OR` conditions (if values are few).
- [ ] Use `EXISTS` instead of `IN` with a subquery for better performance in many cases.
- [ ] Prefer `LEFT JOIN` over `NOT IN` subqueries.
- [ ] Use `WITH` (CTE) to break complex queries into steps and improve readability (and sometimes performance).

### After Query Tuning

- [ ] Measure performance with `.timer on` or application logging.
- [ ] Compare `EXPLAIN QUERY PLAN` output before and after adding indexes.
- [ ] Test with realistic data volumes (production‑like).
- [ ] Monitor query execution time in production over time.

---

## 4. Common Performance Pitfalls

| Pitfall | Impact | Solution |
|---------|--------|----------|
| **Full table scans** | Slow queries on large tables. | Add appropriate indexes. |
| **Missing foreign key indexes** | Slow joins. | Index foreign key columns. |
| **Using `SELECT *`** | Returns unnecessary data; more I/O. | Select only needed columns. |
| **Not using `EXPLAIN QUERY PLAN`** | Blind optimization. | Always check the plan. |
| **Outdated statistics** | Planner makes poor choices. | Run `ANALYZE` regularly. |
| **Many small transactions** | High overhead; lock contention. | Batch operations in transactions. |
| **Default cache size** | May be too small for large databases. | Increase `cache_size`. |
| **Not using WAL mode** | Readers block writers; poor concurrency. | Enable WAL. |
| **Not using `busy_timeout`** | Applications crash on `SQLITE_BUSY`. | Set a reasonable timeout. |
| **Disk space issues** | `SQLITE_FULL` errors. | Monitor disk space; enable `auto_vacuum`. |
| **Large BLOB storage inline** | Pages become large; slow access. | Store large blobs in separate files; use `sqlar` or external storage. |
| **Many indexes on write‑heavy tables** | Slow inserts/updates. | Drop unnecessary indexes; batch writes. |

---

## 5. Benchmarking Methodology

To properly tune performance, you need a repeatable benchmarking process.

### Steps

1. **Define the workload** – Identify the most critical queries (e.g., 80% of your traffic).
2. **Establish a baseline** – Measure query performance with default settings and no indexes.
3. **Apply one change at a time** – Add an index, change a PRAGMA, rewrite a query. Measure the impact.
4. **Use realistic data** – Test with a dataset that matches production in size and distribution.
5. **Run multiple iterations** – Warm up the cache; run queries several times; average the results.
6. **Monitor resource usage** – CPU, I/O, memory, disk space.

### Benchmarking Tools

| Tool | Description |
|------|-------------|
| `.timer on` in CLI | Simple timing of queries. |
| `time` shell command | Measure total execution time for a script. |
| `sqlite3_analyzer` | Storage efficiency and fragmentation. |
| `PRAGMA cache_used`, `cache_hit` | Page cache effectiveness. |
| `PRAGMA memory_used` | Memory usage. |
| Custom scripts (Python, etc.) | Programmatic timing with multiple runs, statistics. |

---

## 6. Real‑World Tuning Examples

### Example 1: Slow `SELECT` with `WHERE last_name = ?`

**Problem:** Query takes 2 seconds on a 1M row table.

**Solution:** Create an index on `last_name`.
```sql
CREATE INDEX idx_users_last_name ON users(last_name);
```
**Result:** Query now runs in < 10 ms.

---

### Example 2: `JOIN` on `orders` and `customers` is slow

**Problem:** `SELECT * FROM orders JOIN customers ON orders.customer_id = customers.id` is slow.

**Solution:** Ensure `orders.customer_id` is indexed (foreign key should have an index).
```sql
CREATE INDEX idx_orders_customer ON orders(customer_id);
```
**Result:** Join is now fast (nested loop uses index).

---

### Example 3: Query with `LIKE '%keyword%'` is slow

**Problem:** `SELECT * FROM articles WHERE content LIKE '%sqlite%'` – full table scan.

**Solution:** Use FTS5 full‑text search.
```sql
CREATE VIRTUAL TABLE articles_fts USING fts5(content);
INSERT INTO articles_fts(rowid, content) SELECT id, content FROM articles;
SELECT * FROM articles_fts WHERE content MATCH 'sqlite';
```
**Result:** Search is now sub‑second even on millions of rows.

---

### Example 4: Bulk insert of 1 million rows is slow

**Problem:** 1M inserts take 60 seconds.

**Solution:** Use a transaction, drop indexes temporarily, set PRAGMA synchronous=OFF.
```sql
BEGIN;
PRAGMA synchronous = OFF;
PRAGMA journal_mode = OFF;
-- Insert all rows here
COMMIT;
-- Then re-enable safe settings
PRAGMA synchronous = NORMAL;
PRAGMA journal_mode = WAL;
```
**Result:** Inserts complete in < 10 seconds.

---

### Example 5: Database grows large, performance degrades

**Problem:** Database size is 2 GB, but queries are slower than before.

**Solution:** Run `VACUUM` to compact and defragment.
```sql
VACUUM;
```
**Result:** File size may shrink 20‑50%, queries become faster due to contiguous pages.

---

## 7. Monitoring Query Performance in Production

| Metric | How to Measure | Tool |
|--------|----------------|------|
| Query execution time | Set up logging with `set_trace_callback` or profile. | Python, application logs. |
| Number of full table scans | `EXPLAIN QUERY PLAN` for slow queries; use logging. | Custom monitoring. |
| Page cache hit rate | `PRAGMA cache_hit` (if available). | SQLite CLI. |
| WAL checkpoint frequency | Monitor WAL file size; `PRAGMA wal_checkpoint`. | Custom script. |
| Database file size growth | Track size over time. | `ls -lh` or monitoring tools. |
| `SQLITE_BUSY` frequency | Count errors in application logs. | Logging. |

**Proactive Monitoring:**
- Schedule regular `ANALYZE` to keep stats fresh.
- Run `PRAGMA integrity_check` regularly (e.g., daily).
- Set up alerts for disk space, corruption, or excessive `BUSY` errors.

---

## 8. Summary: Performance Tuning Checklist

Use this checklist when deploying a new SQLite‑powered application:

- [ ] Use WAL mode (`PRAGMA journal_mode = WAL`).
- [ ] Set `synchronous = NORMAL` (or FULL if safety is paramount).
- [ ] Set `busy_timeout = 5000`.
- [ ] Set `cache_size` to a reasonable value (e.g., 10000 pages).
- [ ] Enable `mmap_size` for large databases.
- [ ] Run `ANALYZE` after initial data load and after major data changes.
- [ ] Create indexes on all foreign keys and frequently queried columns.
- [ ] Use covering indexes for critical queries.
- [ ] Test with `EXPLAIN QUERY PLAN` and eliminate full table scans.
- [ ] Use parameterized queries for all user‑input SQL.
- [ ] Batch operations in transactions.
- [ ] Implement backup and integrity check automation.
- [ ] Monitor performance over time and adjust as needed.

---

This appendix provides a comprehensive toolkit for optimizing SQLite performance. Refer back to it whenever you encounter slow queries or need to scale your application. Remember: the most effective optimization is often the simplest—adding the right index or changing a PRAGMA. Always measure before and after to confirm improvements.
