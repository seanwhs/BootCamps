# Appendix F: SQLite System Tables and Metadata

SQLite stores schema information, statistics, and internal state in a set of system tables. These tables are read‑only (with a few exceptions) and provide valuable insight into your database's structure and performance. This appendix covers the most important system tables, their columns, and practical queries to extract useful information.

---

## 1. The `sqlite_master` Table

Every SQLite database has a `sqlite_master` table (or `sqlite_temp_master` for temporary tables). It is the **schema table**—it stores the SQL `CREATE` statements for all objects (tables, indexes, views, triggers) in the database.

### Schema

| Column | Type | Description |
|--------|------|-------------|
| `type` | TEXT | Object type: `'table'`, `'index'`, `'view'`, `'trigger'`. |
| `name` | TEXT | Name of the object. |
| `tbl_name` | TEXT | Name of the table the object belongs to (for indexes/triggers) or the object name itself for tables/views. |
| `rootpage` | INTEGER | The root page number of the object's B‑Tree (0 for views/triggers). |
| `sql` | TEXT | The full `CREATE` statement used to create the object. |

### Example Queries

**List all tables:**
```sql
SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;
```

**List all indexes:**
```sql
SELECT name, tbl_name FROM sqlite_master WHERE type = 'index' ORDER BY name;
```

**Get the schema of a specific table:**
```sql
SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'users';
```

**List all views:**
```sql
SELECT name, sql FROM sqlite_master WHERE type = 'view';
```

**List all triggers and their associated tables:**
```sql
SELECT name, tbl_name FROM sqlite_master WHERE type = 'trigger';
```

**Find tables that have a specific column (using string search on the schema):**
```sql
SELECT name FROM sqlite_master 
WHERE type = 'table' AND sql LIKE '%email%';
```

**Check if a table exists:**
```sql
SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = 'users';
```

### Temporary Objects

Temporary tables and indexes are stored in `sqlite_temp_master` (same structure).

```sql
SELECT * FROM sqlite_temp_master;
```

---

## 2. The `sqlite_stat1`, `sqlite_stat2`, `sqlite_stat3`, `sqlite_stat4` Tables

These tables store statistics collected by `ANALYZE`. The query planner uses them to estimate the selectivity of indexes and choose optimal query plans.

### `sqlite_stat1`

Contains per‑index statistics: the number of rows and the approximate number of distinct values per column.

| Column | Type | Description |
|--------|------|-------------|
| `tbl` | TEXT | Table name. |
| `idx` | TEXT | Index name (or `'*'` for table statistics). |
| `stat` | TEXT | A string of integers: `nRow` (number of rows in the table) followed by `nDistinct` for each index column. |

**Example query:**
```sql
SELECT * FROM sqlite_stat1;
```

**Interpretation:** For an index on `(last_name, first_name)`, the `stat` column might look like `100000 500 2000`, meaning the table has 100,000 rows, the first column has about 500 distinct values, and the second column has about 2000 distinct values.

### `sqlite_stat2`, `sqlite_stat3`, `sqlite_stat4`

These tables store more detailed histogram data (available in SQLite 3.8.1+). They are used by the planner for more accurate estimates, especially for `WHERE` clauses with ranges. You generally don't need to query them directly; they are internal.

**To refresh statistics:**
```sql
ANALYZE;
```

**To delete statistics:**
```sql
ANALYZE;  -- with no arguments on an empty database? Better:
DELETE FROM sqlite_stat1;
-- Then VACUUM if needed
```

---

## 3. The `sqlite_sequence` Table

When you use `INTEGER PRIMARY KEY AUTOINCREMENT`, SQLite creates a `sqlite_sequence` table to track the next value for each auto‑increment column.

### Schema

| Column | Type | Description |
|--------|------|-------------|
| `name` | TEXT | The table name with the auto‑increment column. |
| `seq` | INTEGER | The last used value (the next value will be `seq + 1`). |

**Example query:**
```sql
SELECT * FROM sqlite_sequence;
```

**Reset the auto‑increment counter (set to 0):**
```sql
UPDATE sqlite_sequence SET seq = 0 WHERE name = 'users';
```

**Note:** You can also reset by deleting the row:
```sql
DELETE FROM sqlite_sequence WHERE name = 'users';
```
Then the next inserted row will receive `ROWID = 1` (if no other rows exist) or the maximum `ROWID + 1`.

---

## 4. The `sqlite_analysis` Table (Deprecated)

In older versions, `sqlite_analysis` was used, but modern SQLite uses `sqlite_stat1`–`sqlite_stat4`. It is not present in new databases.

---

## 5. Virtual Table Auxiliary Tables

Some extensions create their own system tables. For example, **FTS5** creates internal tables for the inverted index. These are named with the pattern `[table_name]_[suffix]`, e.g., `docs_fts_data`, `docs_fts_idx`, `docs_fts_docsize`, `docs_fts_config`. You generally should not modify them directly.

---

## 6. The `sqlite_schema` Alias

In SQLite 3.33+, `sqlite_schema` is an alias for `sqlite_master`. Use either.

---

## 7. Querying All System Tables

To see all tables (including system tables) in the database:
```sql
SELECT name FROM sqlite_master WHERE type = 'table'
UNION ALL
SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE 'sqlite_%';
```

---

## 8. Practical Metadata Queries

### Find All Foreign Key Constraints

```sql
SELECT 
    m.name AS table_name,
    p.table_name AS child_table,
    p."from" AS child_column,
    p."to" AS parent_column
FROM sqlite_master m
JOIN pragma_foreign_key_list(m.name) p
WHERE m.type = 'table' AND m.name NOT LIKE 'sqlite_%';
```

### Find All Indexes and Their Columns

```sql
SELECT 
    i.name AS index_name,
    i.tbl_name AS table_name,
    ii.name AS column_name,
    ii.seqno AS column_position
FROM sqlite_master i
JOIN pragma_index_info(i.name) ii
WHERE i.type = 'index'
ORDER BY i.tbl_name, i.name, ii.seqno;
```

### Find Unused Indexes

You can find indexes that are not used by the query planner. This requires checking `sqlite_stat1`—if an index has a very low cardinality (distinct values close to row count) or is never referenced in `EXPLAIN QUERY PLAN`, it may be a candidate for removal. However, this is more of an art; a simple check is to see if the index name appears in any `EXPLAIN QUERY PLAN` output under `SEARCH USING INDEX`.

### Find Tables Without Primary Keys

```sql
SELECT name 
FROM sqlite_master 
WHERE type = 'table' 
  AND name NOT LIKE 'sqlite_%' 
  AND name NOT IN (
    SELECT tbl_name FROM sqlite_master 
    WHERE type = 'table' AND sql LIKE '%PRIMARY KEY%'
  );
```

---

## 9. Inspecting the Schema of Attached Databases

If you have attached databases (e.g., `ATTACH 'other.db' AS other`), you can query their schema using the database name prefix:

```sql
SELECT * FROM other.sqlite_master;
```

---

## 10. Summary of System Tables

| Table | Purpose |
|-------|---------|
| `sqlite_master` | Schema of all objects in the main database. |
| `sqlite_temp_master` | Schema of temporary objects. |
| `sqlite_schema` | Alias for `sqlite_master` (3.33+). |
| `sqlite_sequence` | Tracks auto‑increment values. |
| `sqlite_stat1` | Statistics for indexes (column cardinality). |
| `sqlite_stat2` | Histogram statistics (optional). |
| `sqlite_stat3` | More detailed statistics. |
| `sqlite_stat4` | Even more detailed statistics. |

---

## 11. Important Notes

- **Do not modify** `sqlite_master` directly. Use `CREATE`, `ALTER`, `DROP` statements.
- `sqlite_stat1`–`sqlite_stat4` are created by `ANALYZE`; you can delete them to reset statistics (but the planner will use defaults).
- `sqlite_sequence` is only present if you have used `AUTOINCREMENT`.
- Many of these tables are read‑only; you can update `sqlite_sequence` but with caution.

---

This appendix provides you with the knowledge to inspect and understand your database's internal metadata. Use it to audit schemas, tune performance, and debug issues.
