# Student Notes: Master SQLite — From Fundamentals to Production Systems

---

## About These Notes

These notes are a condensed, study‑friendly reference for the entire course. They cover every module with:
- **Key concepts** in bullet points
- **Essential syntax** and code patterns
- **Important definitions** and analogies
- **PRAGMA settings**, error codes, and best practices

Use these notes to review before exams, labs, or when building your own projects.

---

# Part 0: Introduction

## What Is SQLite?
- **Embedded, serverless, zero‑configuration** relational database.
- Stored as a **single ordinary file** on disk.
- **Self‑contained C library** (~600 KB).
- **ACID compliant** – transactions are atomic, consistent, isolated, durable.
- **Most deployed database** – billions of devices (Android, iOS, browsers, embedded).

## Use Cases
- Mobile apps, desktop apps, IoT devices, edge computing.
- Development/testing (default for Django, Ruby on Rails).
- Embedded analytics, browser storage (WebSQL, IndexedDB with SQLite).

## SQLite vs. Client‑Server
| SQLite | PostgreSQL/MySQL |
|--------|------------------|
| No network, no server | Needs server process |
| Single file | Multiple files |
| No authentication | User/password |
| Simple deployment | Complex admin |

## Course Roadmap
1. Foundations & Architecture
2. SQL Programming
3. Database Design
4. Indexing & Optimization
5. Transactions & Concurrency
6. Advanced Features (JSON, FTS, Triggers, Views)
7. Programming (Python, Web, Mobile)
8. Security & Production
9. Projects & Capstone

---

# Part 1: SQLite Foundations & Internal Architecture

## Module 1: Installation & CLI

### Installation Commands
- **Linux (Debian/Ubuntu):** `sudo apt install sqlite3`
- **macOS (Homebrew):** `brew install sqlite`
- **Windows:** Download `sqlite-tools` from sqlite.org, add to PATH.

### CLI Dot‑Commands (Essential)
| Command | Description |
|---------|-------------|
| `.tables` | List all tables |
| `.schema [table]` | Show CREATE statement |
| `.dump [table]` | Export data as SQL |
| `.backup file` | Create hot backup |
| `.import file table` | Import CSV |
| `.mode column` | Align output |
| `.headers on` | Show column names |
| `.exit` / `.quit` | Exit shell |

### First Database
```bash
sqlite3 myfirst.db
CREATE TABLE greetings (message TEXT);
INSERT INTO greetings VALUES ('Hello');
SELECT * FROM greetings;
.exit
```

---

## Module 2: SQLite Architecture (The Pipeline)

1. **SQL Parser** → Converts SQL text to parse tree (AST)
2. **Code Generator** → Translates parse tree to **VDBE bytecode**
3. **VDBE (Virtual Database Engine)** → Executes bytecode instructions
4. **B‑Tree** → Manages pages; stores tables/indexes; O(log n) lookups
5. **Pager** → Manages disk I/O, page cache, journaling (crash recovery)
6. **OS Interface** → Platform‑specific file operations and locking

### EXPLAIN QUERY PLAN
```sql
EXPLAIN QUERY PLAN SELECT * FROM users WHERE last_name = 'Smith';
```
- `SCAN table` = full table scan
- `SEARCH table USING INDEX` = index lookup
- `USING COVERING INDEX` = index‑only scan

---

## Module 3: Data Types

### Storage Classes (Actual Formats)
| Class | Description |
|-------|-------------|
| `NULL` | Missing value (0 bytes overhead) |
| `INTEGER` | Signed integer (1‑8 bytes) |
| `REAL` | 8‑byte IEEE 754 float |
| `TEXT` | UTF‑8/‑16 string |
| `BLOB` | Raw bytes |

### Type Affinity
- Columns have a **recommended type** (affinity), not a strict type.
- Affinity determined by declared type (e.g., `INT` → INTEGER, `CHAR/TEXT` → TEXT, `BLOB` → BLOB, `REAL/FLOA` → REAL, else NUMERIC).
- Values are **converted** if possible (e.g., `'123'` into INTEGER column → stored as integer).

### Boolean & Date
- Booleans: store as `0` (false) or `1` (true) with `CHECK (col IN (0,1))`.
- Dates: store as TEXT (`'YYYY‑MM‑DD HH:MM:SS'`), INTEGER (Unix epoch), or REAL (Julian day).
- Use built‑in functions: `date()`, `time()`, `datetime()`, `strftime()`.

### ROWID Tables vs. WITHOUT ROWID
- `ROWID` = implicit 64‑bit integer primary key; `INTEGER PRIMARY KEY` aliases it.
- `WITHOUT ROWID` = use a different primary key as B‑Tree key; avoids extra index, good for composite/string keys.

---

## Module 4: Creating Tables

### CREATE TABLE Syntax
```sql
CREATE TABLE [IF NOT EXISTS] table_name (
    column1 type constraints,
    column2 type constraints,
    ...
    CONSTRAINT ...
);
```

### Common Constraints
- `PRIMARY KEY` – unique, not null.
- `FOREIGN KEY` – referential integrity; `ON DELETE CASCADE/SET NULL/RESTRICT`.
- `UNIQUE` – no duplicates.
- `CHECK` – custom condition.
- `DEFAULT` – default value.
- `NOT NULL` – disallow NULL.

### Generated Columns
```sql
full_name TEXT GENERATED ALWAYS AS (first || ' ' || last) STORED
```
- `STORED` – saved on disk; can be indexed.
- `VIRTUAL` – computed on read; no disk space.

### ALTER TABLE
- Add column: `ALTER TABLE table ADD COLUMN col type constraints;`
- Rename table: `ALTER TABLE old RENAME TO new;`
- Rename column: `ALTER TABLE table RENAME COLUMN old TO new;`

### Schema Inspection
- `.schema` – show all CREATE statements
- `PRAGMA table_info(table);` – column details
- `PRAGMA foreign_key_list(table);` – foreign keys

---

# Part 2: SQL Programming Essentials

## Module 5: CRUD Operations

### INSERT
```sql
INSERT INTO table (col1, col2) VALUES (val1, val2);
INSERT INTO table (col1, col2) VALUES (v1,v2), (v3,v4);
INSERT INTO table SELECT ... FROM other_table;
```

### SELECT
```sql
SELECT col1, col2 FROM table WHERE condition ORDER BY col LIMIT n OFFSET m;
```
- `DISTINCT` – remove duplicates.
- `AS` – aliases.

### UPDATE
```sql
UPDATE table SET col = val WHERE condition;  -- always use WHERE!
```

### DELETE
```sql
DELETE FROM table WHERE condition;  -- always use WHERE!
```

---

## Module 6: Filtering & Expressions

### WHERE Operators
- Comparison: `=`, `<>`, `<`, `>`, `<=`, `>=`
- Logical: `AND`, `OR`, `NOT`
- Range: `BETWEEN x AND y`
- List: `IN (val1, val2, ...)`
- Pattern: `LIKE` (`%` any, `_` single), `GLOB` (Unix wildcards, case‑sensitive)
- NULL: `IS NULL`, `IS NOT NULL`

### CASE Expression
```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default
END
```

---

## Module 7: Joins

### INNER JOIN
Returns rows with matches in both tables.
```sql
SELECT * FROM a JOIN b ON a.id = b.a_id;
```

### LEFT JOIN
Returns all rows from left table; NULL for non‑matching right.
```sql
SELECT * FROM a LEFT JOIN b ON a.id = b.a_id;
```

### CROSS JOIN
Cartesian product (all combinations).
```sql
SELECT * FROM a CROSS JOIN b;
```

### SELF JOIN
Join a table to itself (e.g., employees with managers).
```sql
SELECT e.name, m.name FROM employees e JOIN employees m ON e.manager_id = m.id;
```

### Many‑to‑Many
Requires a junction table with composite primary key.
```sql
CREATE TABLE book_authors (
    book_id INTEGER,
    author_id INTEGER,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books,
    FOREIGN KEY (author_id) REFERENCES authors
);
```

---

## Module 8: Aggregation & Reporting

### Aggregate Functions
- `COUNT(*)`, `COUNT(column)`
- `SUM(column)`, `AVG(column)`
- `MIN(column)`, `MAX(column)`

### GROUP BY & HAVING
```sql
SELECT category, COUNT(*) FROM products GROUP BY category HAVING COUNT(*) > 10;
```

### CTEs (Common Table Expressions)
```sql
WITH cte AS (SELECT ... FROM ...)
SELECT * FROM cte;
```

### Recursive CTEs
```sql
WITH RECURSIVE cte(n) AS (
    SELECT 1
    UNION ALL
    SELECT n+1 FROM cte WHERE n < 10
)
SELECT n FROM cte;
```

### Window Functions
- `ROW_NUMBER()` – sequential number per partition
- `RANK()`, `DENSE_RANK()` – ranking with/without gaps
- `LAG()`, `LEAD()` – access previous/next rows
- `SUM(amount) OVER (ORDER BY date)` – running total
- Syntax: `function() OVER (PARTITION BY col ORDER BY col ROWS BETWEEN ... AND ...)`

---

# Part 3: Database Design

## Module 9: Relational Design & Normalization

### Entities, Attributes, Relationships
- **Entity** – real‑world object (Customer, Order)
- **Attribute** – property (name, date)
- **Relationship** – association (Customer places Order)
- **Cardinalities:** 1:1, 1:N, M:N

### Normalization
- **1NF** – atomic values, no repeating groups.
- **2NF** – in 1NF; no partial dependencies (non‑key depends on part of composite key).
- **3NF** – in 2NF; no transitive dependencies (non‑key depends on another non‑key).

### Keys
- **Primary Key** – unique row identifier.
- **Foreign Key** – references a primary key in another table.
- **Natural vs. Surrogate** – surrogate (auto‑increment) is often preferred for simplicity.

### Naming Conventions
- Tables: plural, lowercase, underscores (`customers`)
- Primary keys: `tablename_id` (`customer_id`)
- Foreign keys: same name as referenced PK.

---

## Module 10: Practical Schema Design

### Library System (Example)
Tables: Books, Authors, Book_Authors (M:N), Branches, Copies, Members, Loans.
Constraints: CHECK on year, UNIQUE on ISBN, FOREIGN KEYS with CASCADE.

### E‑Commerce
Tables: Customers, Products, Categories, Orders, Order_Items, Payments.
Indexes: foreign keys, frequently queried columns.

### Hospital
Tables: Patients, Staff (doctors/nurses), Treatments, Patient_Treatments.

---

# Part 4: Indexing & Query Optimization

## Module 11: Indexes

### Types
- **Single‑column** – `CREATE INDEX idx_col ON table(col);`
- **Composite** – `CREATE INDEX idx_col1_col2 ON table(col1, col2);` (left‑most prefix)
- **Unique** – `CREATE UNIQUE INDEX idx_col ON table(col);`
- **Partial** – `CREATE INDEX idx_col ON table(col) WHERE condition;`
- **Expression** – `CREATE INDEX idx_expr ON table(expression);`
- **Covering** – includes all query columns, avoids reading table.

### When to Index
- Frequent `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY`.
- High selectivity (many distinct values).
- Foreign keys (index automatically if declared? No, create explicitly).

### When NOT to Index
- Small tables (<100 rows).
- Low selectivity (e.g., boolean).
- Frequently updated columns (maintenance cost).
- Too many indexes (slows writes).

### Performance Measurement
- `.timer on` in CLI.
- `EXPLAIN QUERY PLAN` to see if index used.

---

## Module 12: Query Planner

- Uses statistics from `ANALYZE` to estimate costs.
- `EXPLAIN QUERY PLAN` – shows scan type.
- `SCAN` – full table scan (bad).
- `SEARCH` – uses index.
- `ANALYZE` – updates statistics; run after bulk changes.
- `INDEXED BY` – force specific index (rare).

---

## Module 13: Performance Engineering

### PRAGMA Settings
| PRAGMA | Recommended | Effect |
|--------|-------------|--------|
| `journal_mode` | `WAL` | Better concurrency |
| `synchronous` | `NORMAL` | Balance speed/safety |
| `cache_size` | `10000`+ | Reduce disk I/O |
| `busy_timeout` | `5000` | Avoid `SQLITE_BUSY` |
| `mmap_size` | `268435456` | Faster reads |
| `temp_store` | `MEMORY` | Faster temp tables |

### Bulk Loading
- Wrap in `BEGIN`/`COMMIT`.
- Set `synchronous = OFF` and `journal_mode = OFF` (temporarily) for speed.
- Use prepared statements with parameter binding.

### VACUUM
- Defragments and reclaims unused space.
- Requires free space equal to DB size.
- Can block; schedule during maintenance.
- `PRAGMA auto_vacuum = FULL|INCREMENTAL` to automate.

---

# Part 5: Transactions & Concurrency

## Module 14: ACID Transactions

### Transaction Commands
```sql
BEGIN;        -- start
COMMIT;       -- save
ROLLBACK;     -- undo
SAVEPOINT sp; -- mark point
ROLLBACK TO sp;
RELEASE sp;
```

### ACID Properties
- **Atomicity** – all or nothing.
- **Consistency** – constraints maintained.
- **Isolation** – transactions don't interfere.
- **Durability** – committed changes survive crash.

### Autocommit
Each statement is its own transaction unless `BEGIN` is used.

---

## Module 15: Journaling & WAL

### Rollback Journal
- Default: `DELETE` mode.
- Writes original pages to a `-journal` file.
- Writers block readers during commit (EXCLUSIVE lock).

### WAL (Write‑Ahead Logging)
- Append changes to a `-wal` file.
- **Readers never block writers; writers never block readers**.
- Only one writer at a time, but readers continue.
- Checkpoints transfer WAL frames to main database.
- Enable: `PRAGMA journal_mode = WAL;`
- Tune: `PRAGMA wal_autocheckpoint = 1000;`
- Manual checkpoint: `PRAGMA wal_checkpoint(FULL);`

### SQLITE_BUSY
- Occurs when lock can't be acquired.
- Mitigation: `PRAGMA busy_timeout = 5000;` and retry logic.

---

## Module 16: Reliability & Recovery

### Integrity Checks
- `PRAGMA integrity_check;` – full scan, returns `ok` if healthy.
- `PRAGMA foreign_key_check;` – finds FK violations.
- `PRAGMA quick_check;` – faster, less thorough.

### synchronous Modes
- `OFF` – fastest, unsafe.
- `NORMAL` – good balance.
- `FULL` – safest, slowest.

### Recovery
- Restore from backup (best).
- `.dump` and re‑import (may work if corruption limited).
- Use `recover` extension (salvage data).

---

# Part 6: Advanced SQLite Features

## Module 17: JSON1

### Key Functions
- `json_valid(json)` – check validity.
- `json_extract(json, '$.path')` – extract value (use `->` or `->>` for shorthand).
- `json_set(json, '$.path', value)` – add/update.
- `json_insert()` – add only if not exists.
- `json_remove()` – delete.
- `json_group_array(expr)` – aggregate into array.
- `json_group_object(key, value)` – aggregate into object.

### Indexing JSON
- Create a **generated column** that extracts the JSON field.
- Index that generated column.

### Example
```sql
ALTER TABLE products ADD COLUMN brand TEXT GENERATED ALWAYS AS (attributes->>'$.brand') STORED;
CREATE INDEX idx_brand ON products(brand);
```

---

## Module 18: Full‑Text Search (FTS5)

### Creating FTS5
```sql
CREATE VIRTUAL TABLE docs_fts USING fts5(title, content, content=docs);
```

### Search Queries
- `WHERE docs_fts MATCH 'sqlite'` – word.
- `MATCH '"full text"'` – phrase.
- `MATCH 'opti*'` – prefix.
- `MATCH 'sqlite AND FTS'` – Boolean.
- `MATCH 'sqlite NEAR/5 FTS'` – proximity.

### Ranking
```sql
SELECT title, bm25(docs_fts) AS rank
FROM docs_fts WHERE docs_fts MATCH 'sqlite'
ORDER BY rank;
```

### Snippets
```sql
SELECT snippet(docs_fts, 1, '<b>', '</b>', '...', 30) FROM docs_fts WHERE docs_fts MATCH 'sqlite';
```

### Syncing with Triggers
Use `AFTER INSERT/UPDATE/DELETE` triggers to update FTS table.

---

## Module 19: Virtual Tables & Extensions

### Virtual Tables
- Present external data (CSV, JSON, etc.) as SQL tables.
- `CREATE VIRTUAL TABLE table_name USING module(args);`

### Examples
- `csv` – read CSV files.
- `generate_series` – generate sequences.
- `spellfix1` – spelling correction.

### Loadable Extensions
- `.load /path/to/extension` in CLI.
- `sqlite3_load_extension()` in C.

---

## Module 20: Triggers & Views

### Triggers
```sql
CREATE TRIGGER name
BEFORE|AFTER|INSTEAD OF INSERT|UPDATE|DELETE ON table
[WHEN condition]
BEGIN
    -- SQL statements; can use OLD and NEW
END;
```
- **Audit logging** – insert into log table.
- **Soft delete** – `INSTEAD OF DELETE` on view, sets a `deleted` flag.
- **Sync FTS** – keep FTS table in sync.

### Views
- Saved queries; used like tables.
- `CREATE VIEW name AS SELECT ...;`
- Can be made updatable with `INSTEAD OF` triggers.

---

# Part 7: Programming with SQLite

## Module 21: Python Integration

### Connect
```python
import sqlite3
conn = sqlite3.connect('mydb.db')
```

### Context Manager
```python
with sqlite3.connect('mydb.db') as conn:
    cursor = conn.execute('SELECT * FROM users')
    for row in cursor:
        print(row)
```

### Parameterized Queries
```python
cursor.execute('SELECT * FROM users WHERE name = ?', (name,))
```
**Never** use string concatenation – SQL injection risk.

### Row Factory
```python
conn.row_factory = sqlite3.Row   # rows can be accessed by name
```

### Custom Functions
```python
conn.create_function('myfunc', 1, lambda x: x.upper())
```

### Async
Use `aiosqlite` for async/await.

---

## Module 22: Web Development

### Flask
- Open connection per request; close in `teardown_appcontext`.
- Use `row_factory` for JSON responses.

### FastAPI
- Use `aiosqlite` for async.
- Dependency injection for connection management.

### Testing
- Use `:memory:` databases for fast, isolated unit tests.

### ORM
- SQLAlchemy, Django ORM, Peewee – all support SQLite.

---

## Module 23: Mobile Development

### Android (Room)
- Define `@Entity`, `@Dao`, `@Database`.
- Migrations with `addMigrations()`.

### React Native (expo‑sqlite)
- `SQLite.openDatabase('mydb.db')`.
- Execute transactions with `executeSql()`.

### Flutter (sqflite)
- `openDatabase()` with `onCreate`.
- Use `db.insert()`, `db.query()`.

### Offline‑First
- Store data locally; sync with remote server.
- Use `sync_status` and `last_modified` columns for conflict resolution.

---

# Part 8: Security & Production Deployment

## Module 24: Security

### SQL Injection Prevention
- Always use parameterized queries.
- Validate dynamic table/column names against whitelist.

### File Permissions
```bash
chmod 600 mydb.db   # only owner
chmod 640 mydb.db   # owner + group
```

### Encryption (SQLCipher)
```bash
sqlcipher myencrypted.db
PRAGMA key = 'password';
```
- Use environment variables for keys, never hard‑code.
- Python: `pysqlcipher3`.

### Secure Delete
```sql
PRAGMA secure_delete = ON;   -- overwrite deleted data
```

---

## Module 25: Backup & Maintenance

### Backup
- `.backup` (hot backup using online backup API).
- Python: `src.backup(dst)`.
- Daily full backups; keep 7‑30 days.

### Maintenance
- `VACUUM` – defragment, reclaim space (weekly/monthly).
- `ANALYZE` – update statistics (after bulk changes).
- `PRAGMA integrity_check` – detect corruption (daily/ hourly).

### Automation
- Script with `cron` or Task Scheduler.

---

## Module 26: Production Best Practices

### Configuration
- WAL mode, `synchronous=NORMAL`, `busy_timeout=5000`, `cache_size` tuned.
- `foreign_keys=ON`, `mmap_size` for large DB.

### Monitoring
- Database file size, WAL size, lock contention.
- Slow query logging: `conn.set_profile()`.
- Integrity check alerts.

### Deployment
- Docker with persistent volume.
- Environment variables for secrets.
- Health check endpoint.

### Migration
- Use versioned migration scripts or tools (Alembic, Django migrations).
- Test in staging before production.

---

# Part 9: Real‑World Projects & Capstone

## Project 1: Personal Finance Manager
- Schema: Categories, Transactions.
- Features: CRUD, budgets, monthly reports, alerts.
- Use CTEs and views for reporting.

## Project 2: POS System
- Schema: Products, Customers, Sales, Sale_Items.
- Triggers: reduce stock, prevent oversell.
- Transactions: wrap sale in `BEGIN`/`COMMIT`.

## Project 3: Notes with FTS
- Schema: Notes, Tags, Note_Tags.
- FTS5 virtual table, sync triggers.
- Search with ranking and snippets.

## Capstone: Task Management System
- Schema: Users, Projects, Tasks, Subtasks, Tags, Comments, Audit_log.
- FTS5 on task title and description.
- JSON metadata for custom fields.
- Triggers for audit and FTS sync.
- FastAPI backend with JWT authentication.
- Backup and maintenance automation.
- Docker deployment.

---

# Final Quick Reference Cards

## Essential PRAGMAs
| PRAGMA | Value |
|--------|-------|
| `journal_mode` | `WAL` |
| `synchronous` | `NORMAL` |
| `cache_size` | `20000` |
| `busy_timeout` | `5000` |
| `foreign_keys` | `ON` |
| `mmap_size` | `268435456` |

## Common Error Codes
| Code | Name | Meaning |
|------|------|---------|
| 0 | `SQLITE_OK` | Success |
| 5 | `SQLITE_BUSY` | Database locked |
| 19 | `SQLITE_CONSTRAINT` | Constraint violation |
| 10 | `SQLITE_IOERR` | I/O error |
| 11 | `SQLITE_CORRUPT` | Database corrupt |
| 14 | `SQLITE_CANTOPEN` | Cannot open file |

## Backup & Maintenance
```bash
# Backup
sqlite3 mydb.db ".backup backup.db"

# Integrity
sqlite3 mydb.db "PRAGMA integrity_check"

# VACUUM
sqlite3 mydb.db "VACUUM"

# ANALYZE
sqlite3 mydb.db "ANALYZE"
```

## Python Skeleton
```python
import sqlite3
from contextlib import contextmanager

@contextmanager
def get_db():
    conn = sqlite3.connect('mydb.db')
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

# Use:
with get_db() as conn:
    cursor = conn.execute('SELECT * FROM users')
    rows = cursor.fetchall()
```

---

*These notes are a summary of the full course. Review them regularly and refer back to the detailed labs and appendixes for deeper dives.*
