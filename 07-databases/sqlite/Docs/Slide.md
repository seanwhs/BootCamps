# Comprehensive Slide Outline: Master SQLite — From Fundamentals to Production Systems

## Course Overview

**Target Audience:** Beginner to intermediate developers, data engineers, and software architects
**Total Duration:** 9–12 days (or 18–24 half-day sessions)
**Delivery Format:** Lecture + Live Demos + Hands-on Labs
**Prerequisites:** Basic programming knowledge, familiarity with command line

---

## Part 0: Introduction — Setting the Stage

### Session 0.1: Welcome & Course Orientation (30 min)

| Slide # | Topic | Key Points |
|---------|-------|------------|
| 0.1.1 | Course Title & Instructor Intro | "Master SQLite: From Fundamentals to Production Systems" |
| 0.1.2 | What This Course Covers | Full spectrum: architecture → SQL → design → optimization → security → deployment |
| 0.1.3 | What You'll Build | Complete production‑ready application; portfolio of real‑world projects |
| 0.1.4 | Target Audience & Prerequisites | Who should take this; what you need to know beforehand |
| 0.1.5 | Course Format | Lectures + live demos + hands‑on labs + capstone project |
| 0.1.6 | Materials & Resources | Course repository, cheat sheets, reference appendices |

### Session 0.2: Why SQLite? (30 min)

| Slide # | Topic | Key Points |
|---------|-------|------------|
| 0.2.1 | What Is SQLite? | Serverless, self‑contained, zero‑configuration, embedded RDBMS |
| 0.2.2 | The SQLite Philosophy | "Small. Fast. Reliable. Choose any three." |
| 0.2.3 | SQLite by the Numbers | Most deployed database; billions of devices; ~600KB library |
| 0.2.4 | Use Cases | Mobile apps, desktop apps, IoT, edge computing, embedded systems, web browsers |
| 0.2.5 | SQLite vs. Client‑Server Databases | No network, no admin, no authentication; single file |
| 0.2.6 | When to Use SQLite vs. PostgreSQL/MySQL | Decision matrix for choosing the right database |
| 0.2.7 | SQLite Ecosystem Overview | CLI, GUI tools, extensions, programming language bindings |

### Session 0.3: Course Roadmap & Ultimate Architecture (30 min)

| Slide # | Topic | Key Points |
|---------|-------|------------|
| 0.3.1 | The 9‑Part Journey | Foundations → SQL → Design → Optimization → Transactions → Advanced → Programming → Security → Projects |
| 0.3.2 | The Ultimate Architecture | What you'll build by the end: full‑stack application with schema, indexes, FTS, JSON, encryption, backup |
| 0.3.3 | Learning Outcomes | 15+ concrete skills you'll master |
| 0.3.4 | How to Succeed in This Course | Code along, experiment, don't skip verification steps |
| 0.3.5 | Setup Checklist | SQLite CLI, DB Browser, Python 3.8+, VS Code, Git |

---

## Part 1: SQLite Foundations & Internal Architecture (Day 1)

### Module 1: Introduction to SQLite (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 1.1.1 | History of SQLite | Created by D. Richard Hipp in 2000; public domain |
| 1.1.2 | Design Goals | Embedded, zero‑configuration, portable, reliable |
| 1.1.3 | Serverless Architecture | In‑process library; no separate server process |
| 1.1.4 | Database File Structure | Single ordinary file; portable across platforms |
| 1.1.5 | Installing SQLite | Linux: `apt install sqlite3`; macOS: `brew install sqlite`; Windows: download binaries |
| 1.1.6 | **LAB: Verify Installation** | `sqlite3 --version` | **Hands‑on:** Run version check |
| 1.1.7 | SQLite CLI Overview | Interactive shell, dot‑commands, `.help` |
| 1.1.8 | DB Browser for SQLite | GUI tool for visual exploration |
| 1.1.9 | **LAB: Create First Database** | `sqlite3 first.db` | **Hands‑on:** Create `first.db`, run `.databases` |
| 1.1.10 | **LAB: First Table & Query** | `CREATE TABLE`, `INSERT`, `SELECT` | **Hands‑on:** Create `greetings` table, insert row, query |
| 1.1.11 | CLI Dot‑Commands Reference | `.tables`, `.schema`, `.dump`, `.backup`, `.exit` |
| 1.1.12 | Database File Header | Magic string, page size, format version |

### Module 2: SQLite Architecture (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 1.2.1 | The Big Picture | Parser → Code Generator → VDBE → B‑Tree → Pager → OS Interface |
| 1.2.2 | SQL Parser | Tokenizes and parses SQL into AST |
| 1.2.3 | Code Generator | Transforms AST into VDBE bytecode |
| 1.2.4 | VDBE (Virtual Database Engine) | Executes bytecode instructions; heart of SQLite |
| 1.2.5 | B‑Tree Storage Engine | Balanced tree; O(log N) lookups; tables and indexes |
| 1.2.6 | Page Cache | LRU cache; reduces disk I/O |
| 1.2.7 | Pager Subsystem | Manages reading/writing pages; journaling; crash recovery |
| 1.2.8 | OS Interface | Platform‑specific file I/O and locking |
| 1.2.9 | **LAB: EXPLAIN Bytecode** | `EXPLAIN SELECT * FROM greetings` | **Hands‑on:** View VDBE instructions |
| 1.2.10 | **LAB: EXPLAIN QUERY PLAN** | `EXPLAIN QUERY PLAN` | **Hands‑on:** See query execution strategy |
| 1.2.11 | Locking Overview | Five states: UNLOCKED, SHARED, RESERVED, PENDING, EXCLUSIVE |
| 1.2.12 | Journaling Overview | Rollback journal; crash recovery |
| 1.2.13 | **LAB: .dbinfo** | Inspect database metadata | **Hands‑on:** Run `.dbinfo` and interpret output |

### Module 3: Data Types & Storage (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 1.3.1 | Dynamic Typing Overview | Values have types, not columns |
| 1.3.2 | The Five Storage Classes | NULL, INTEGER, REAL, TEXT, BLOB |
| 1.3.3 | Storage Class Details | Size, encoding, representation |
| 1.3.4 | Type Affinity | Column's recommended type; conversion rules |
| 1.3.5 | Affinity Determination Rules | INT → INTEGER; CHAR/TEXT → TEXT; BLOB → BLOB; REAL → REAL; default → NUMERIC |
| 1.3.6 | Manifest Typing | Type stored with each value |
| 1.3.7 | **LAB: Type Affinity Experiments** | Insert varied types | **Hands‑on:** Create `test` table with different affinities; insert mismatched values |
| 1.3.8 | Boolean Handling | Store as 0/1 INTEGER with CHECK constraint |
| 1.3.9 | Date/Time Handling | TEXT (ISO8601), INTEGER (Unix epoch), REAL (Julian day) |
| 1.3.10 | Date Functions | `date()`, `time()`, `datetime()`, `strftime()`, `julianday()` |
| 1.3.11 | ROWID Tables | Implicit 64‑bit integer primary key |
| 1.3.12 | WITHOUT ROWID Tables | Primary key is B‑Tree key; no extra index |
| 1.3.13 | **LAB: ROWID vs. WITHOUT ROWID** | Compare performance and size | **Hands‑on:** Create both table types; insert data; compare |

### Module 4: Creating and Managing Tables (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 1.4.1 | CREATE TABLE Syntax | Columns, constraints, options |
| 1.4.2 | PRIMARY KEY | Uniquely identifies each row |
| 1.4.3 | FOREIGN KEY | Referential integrity; `ON DELETE` / `ON UPDATE` actions |
| 1.4.4 | UNIQUE Constraint | No duplicate values |
| 1.4.5 | CHECK Constraint | Custom validation condition |
| 1.4.6 | DEFAULT Values | Automatic values on insert |
| 1.4.7 | NOT NULL Constraint | Prevents NULL values |
| 1.4.8 | Generated Columns | `STORED` vs. `VIRTUAL`; computed from other columns |
| 1.4.9 | **LAB: Design a Library Schema** | Authors, Books, Book_Authors | **Hands‑on:** Create normalized schema with all constraint types |
| 1.4.10 | ALTER TABLE | Add column, rename table, rename column |
| 1.4.11 | DROP TABLE | Remove table and data |
| 1.4.12 | Schema Inspection | `PRAGMA table_info()`, `.schema`, `PRAGMA foreign_key_list()` |
| 1.4.13 | **LAB: Schema Operations** | ALTER, DROP, inspect | **Hands‑on:** Modify schema; inspect with PRAGMAs |
| 1.4.14 | Naming Conventions | Tables: plural; PK: `tablename_id`; FK: same as referenced |

---

## Part 2: SQL Programming Essentials (Day 2)

### Module 5: CRUD Operations (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 2.1.1 | CRUD Overview | Create, Read, Update, Delete |
| 2.1.2 | INSERT Syntax | Single row, multiple rows, with `DEFAULT` |
| 2.1.3 | INSERT with SELECT | Copy data from another table |
| 2.1.4 | SELECT Basics | `SELECT *`, `SELECT column1, column2` |
| 2.1.5 | Column Aliases | `AS` keyword for readable output |
| 2.1.6 | ORDER BY | Ascending (`ASC`), descending (`DESC`); multiple columns |
| 2.1.7 | LIMIT & OFFSET | Pagination; top‑N queries |
| 2.1.8 | DISTINCT | Remove duplicate rows |
| 2.1.9 | UPDATE Syntax | Set columns; always use WHERE |
| 2.1.10 | DELETE Syntax | Remove rows; always use WHERE |
| 2.1.11 | **LAB: Customer Database** | Build and query | **Hands‑on:** Insert, update, delete, select with sorting and pagination |
| 2.1.12 | **LAB: Product Inventory** | CRUD operations | **Hands‑on:** Manage inventory with all CRUD operations |

### Module 6: Filtering and Expressions (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 2.2.1 | WHERE Clause | Filters rows based on conditions |
| 2.2.2 | Comparison Operators | `=`, `<>`, `<`, `>`, `<=`, `>=` |
| 2.2.3 | Logical Operators | `AND`, `OR`, `NOT` |
| 2.2.4 | BETWEEN | Range checks (inclusive) |
| 2.2.5 | IN Operator | Match against a list |
| 2.2.6 | LIKE Pattern Matching | `%` (any), `_` (single); case‑insensitive |
| 2.2.7 | GLOB Pattern Matching | Unix‑style wildcards; case‑sensitive |
| 2.2.8 | CASE Expression | Conditional logic in SQL |
| 2.2.9 | NULL Handling | `IS NULL`, `IS NOT NULL`; `COALESCE()` |
| 2.2.10 | **LAB: Advanced Filtering** | Complex WHERE conditions | **Hands‑on:** Use `BETWEEN`, `IN`, `LIKE`, `CASE` |
| 2.2.11 | **LAB: Pattern Matching** | `LIKE` vs. `GLOB` | **Hands‑on:** Compare pattern matching operators |
| 2.2.12 | **LAB: NULL Handling** | `IS NULL`, `COALESCE` | **Hands‑on:** Handle NULLs in queries |

### Module 7: Joins & Relationships (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 2.3.1 | Why Joins? | Combine data from multiple tables |
| 2.3.2 | INNER JOIN | Only matching rows |
| 2.3.3 | LEFT JOIN | All rows from left; NULL for non‑matching right |
| 2.3.4 | RIGHT JOIN | Not supported in SQLite (use LEFT JOIN) |
| 2.3.5 | CROSS JOIN | Cartesian product (all combinations) |
| 2.3.6 | SELF JOIN | Join a table to itself; hierarchical data |
| 2.3.7 | Many‑to‑Many Relationships | Junction table with composite primary key |
| 2.3.8 | **LAB: University Database** | Students, Courses, Enrollments | **Hands‑on:** Implement M:N with junction table |
| 2.3.9 | **LAB: Sales Database** | Customers, Orders, Products | **Hands‑on:** Complex joins with multiple tables |
| 2.3.10 | Join Performance | Index foreign keys for speed |

### Module 8: Aggregation & Reporting (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 2.4.1 | Aggregate Functions | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` |
| 2.4.2 | GROUP BY | Group rows for aggregation |
| 2.4.3 | HAVING | Filter groups (like WHERE for groups) |
| 2.4.4 | Common Table Expressions (CTEs) | `WITH` clause; temporary result sets |
| 2.4.5 | Recursive CTEs | Hierarchical data; graph traversal |
| 2.4.6 | Window Functions Overview | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `SUM OVER` |
| 2.4.7 | PARTITION BY | Divide rows into windows |
| 2.4.8 | ORDER BY in Window | Ordering within partitions |
| 2.4.9 | **LAB: Business Analytics Reports** | Monthly summaries | **Hands‑on:** Build reports with GROUP BY and HAVING |
| 2.4.10 | **LAB: Financial Summaries** | Running totals, rankings | **Hands‑on:** Use window functions for financial analysis |
| 2.4.11 | **LAB: Recursive CTE** | Generate series, tree traversal | **Hands‑on:** Use recursive CTE for hierarchical data |

---

## Part 3: Database Design (Day 3)

### Module 9: Relational Database Design (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 3.1.1 | What Is Database Design? | Blueprint for your data |
| 3.1.2 | Entity‑Relationship (ER) Modeling | Entities, attributes, relationships |
| 3.1.3 | Entities & Attributes | Nouns and their properties |
| 3.1.4 | Relationships & Cardinalities | 1:1, 1:N, M:N |
| 3.1.5 | Primary Keys & Foreign Keys | Uniquely identify; link tables |
| 3.1.6 | Normalization Overview | Reduce redundancy; avoid anomalies |
| 3.1.7 | First Normal Form (1NF) | Atomic values; no repeating groups |
| 3.1.8 | Second Normal Form (2NF) | No partial dependencies |
| 3.1.9 | Third Normal Form (3NF) | No transitive dependencies |
| 3.1.10 | Denormalization | When and why to add redundancy for performance |
| 3.1.11 | Naming Conventions | Tables: plural; columns: lowercase underscores |
| 3.1.12 | **LAB: Normalize a Denormalized Table** | Fix a bad design | **Hands‑on:** Take a denormalized table; normalize to 3NF |

### Module 10: Practical Schema Design (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 3.2.1 | E‑Commerce Schema Design | Categories, Products, Customers, Orders, Order_Items, Payments |
| 3.2.2 | Hospital Management Schema | Patients, Staff, Treatments, Patient_Treatments |
| 3.2.3 | Library Tracking Schema | Books, Authors, Members, Loans, Branches, Copies |
| 3.2.4 | HR Management Schema | Employees, Departments, Payroll, Attendance |
| 3.2.5 | Student Information Schema | Students, Courses, Professors, Enrollments, Grades |
| 3.2.6 | **CAPSTONE LAB: Design from Scratch** | Complex business requirements | **Hands‑on:** Design complete schema for a Library Management System |
| 3.2.7 | Capstone: Entities & Relationships | Identify all entities and relationships |
| 3.2.8 | Capstone: Attributes & Keys | Define attributes and choose primary keys |
| 3.2.9 | Capstone: Constraints & Indexes | Add CHECK, UNIQUE, FOREIGN KEY, indexes |
| 3.2.10 | Capstone: Triggers for Business Rules | Borrow limit, auto‑return date, fine calculation |
| 3.2.11 | **LAB: Implement Capstone Schema** | Execute full schema | **Hands‑on:** Implement complete Library Management System |
| 3.2.12 | **LAB: Test Capstone** | Insert data; verify constraints and triggers | **Hands‑on:** Test all business rules |

---

## Part 4: Indexing & Query Optimization (Day 4)

### Module 11: SQLite Indexes (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 4.1.1 | What Is an Index? | B‑Tree data structure; sorted values with row pointers |
| 4.1.2 | How Indexes Speed Up Queries | O(log N) vs. O(N) full table scan |
| 4.1.3 | B‑Tree Indexes | Default index type |
| 4.1.4 | Composite Indexes | Multiple columns; left‑most prefix rule |
| 4.1.5 | Unique Indexes | Enforce uniqueness; speed up lookups |
| 4.1.6 | Partial Indexes | Index subset of rows with WHERE clause |
| 4.1.7 | Covering Indexes | Contains all columns needed by query |
| 4.1.8 | Expression Indexes | Index on function result (e.g., `UPPER(name)`) |
| 4.1.9 | Automatic Indexes | SQLite creates temporary indexes for joins |
| 4.1.10 | When to Use Indexes | High selectivity, frequent filters, foreign keys |
| 4.1.11 | When NOT to Use Indexes | Small tables, low selectivity, frequent updates |
| 4.1.12 | **LAB: Create and Measure Indexes** | Performance comparison | **Hands‑on:** Generate 1M rows; measure query time with/without index |
| 4.1.13 | **LAB: Composite Index Order** | Left‑most prefix rule | **Hands‑on:** Test which queries use composite index |
| 4.1.14 | **LAB: Covering Index** | Index‑only scan | **Hands‑on:** Create covering index and verify with EXPLAIN |

### Module 12: Query Planner (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 4.2.1 | Query Optimizer Overview | Chooses the cheapest execution plan |
| 4.2.2 | EXPLAIN QUERY PLAN | See the execution strategy |
| 4.2.3 | Scan Types | SCAN (full table), SEARCH (index), COVERING INDEX |
| 4.2.4 | Cost Estimation | Based on statistics from ANALYZE |
| 4.2.5 | Join Optimization | Nested loops; index selection |
| 4.2.6 | ANALYZE | Update statistics for the planner |
| 4.2.7 | sqlite_stat1–stat4 | Internal statistics tables |
| 4.2.8 | Query Rewriting | Rewrite queries to guide the planner |
| 4.2.9 | Forcing Indexes | `INDEXED BY` (rarely needed) |
| 4.2.10 | **LAB: EXPLAIN QUERY PLAN** | Read and interpret plans | **Hands‑on:** Analyze plans for different queries |
| 4.2.11 | **LAB: ANALYZE** | Update statistics | **Hands‑on:** Run ANALYZE; observe plan changes |
| 4.2.12 | **LAB: Eliminating Table Scans** | Add indexes to remove scans | **Hands‑on:** Identify and fix full table scans |

### Module 13: Performance Engineering (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 4.3.1 | PRAGMA Optimization | `cache_size`, `mmap_size`, `temp_store` |
| 4.3.2 | Cache Sizing | More cache = less disk I/O |
| 4.3.3 | Memory‑Mapped I/O | `mmap_size` for large databases |
| 4.3.4 | Temporary Storage | `temp_store = MEMORY` for speed |
| 4.3.5 | Bulk Loading | Transactions; `synchronous=OFF`; `journal_mode=OFF` |
| 4.3.6 | Batch Updates | Group operations in transactions |
| 4.3.7 | VACUUM | Defragment; reclaim space |
| 4.3.8 | auto_vacuum | Automatic space reclamation |
| 4.3.9 | ANALYZE | Keep statistics fresh |
| 4.3.10 | **LAB: Bulk Loading Optimization** | Compare with/without transaction | **Hands‑on:** Insert 100K rows with and without transaction |
| 4.3.11 | **LAB: PRAGMA Tuning** | cache_size, mmap_size | **Hands‑on:** Measure performance with different settings |
| 4.3.12 | **LAB: VACUUM** | Compact database | **Hands‑on:** Run VACUUM; observe size reduction |
| 4.3.13 | Performance Monitoring | `.timer`, `PRAGMA cache_used`, `PRAGMA cache_hit` |

---

## Part 5: Transactions & Concurrency (Day 5)

### Module 14: ACID Transactions (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 5.1.1 | What Is a Transaction? | Group of statements; all or nothing |
| 5.1.2 | ACID Properties | Atomicity, Consistency, Isolation, Durability |
| 5.1.3 | BEGIN, COMMIT, ROLLBACK | Start, save, cancel |
| 5.1.4 | Autocommit Mode | Each statement is its own transaction |
| 5.1.5 | Savepoints | Nested transactions; partial rollback |
| 5.1.6 | Atomic Commit | Journal ensures all or nothing |
| 5.1.7 | **LAB: Basic Transactions** | Transfer money | **Hands‑on:** Simulate bank transfer; test rollback |
| 5.1.8 | **LAB: Savepoints** | Partial rollback | **Hands‑on:** Use savepoints for nested logic |
| 5.1.9 | **LAB: Simulate Crash** | Observe journal file | **Hands‑on:** Start transaction; check for -journal file |

### Module 15: Journaling & WAL (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 5.2.1 | Rollback Journal | Default mode; writes original pages to journal |
| 5.2.2 | Write‑Ahead Logging (WAL) | Append‑only log; better concurrency |
| 5.2.3 | WAL vs. Rollback | Readers don't block writers; writers don't block readers |
| 5.2.4 | Enabling WAL | `PRAGMA journal_mode = WAL` |
| 5.2.5 | Checkpoints | Transfer WAL frames to main database |
| 5.2.6 | wal_autocheckpoint | Automatic checkpoint threshold |
| 5.2.7 | Manual Checkpoints | `PRAGMA wal_checkpoint(FULL/TRUNCATE/PASSIVE)` |
| 5.2.8 | Locking in WAL | Shared locks; writers append; checkpoints block writes |
| 5.2.9 | SQLITE_BUSY | Database locked; use `busy_timeout` |
| 5.2.10 | **LAB: Compare Rollback vs. WAL** | Performance and concurrency | **Hands‑on:** Measure insert speed; test concurrent reads/writes |
| 5.2.11 | **LAB: Checkpoint Management** | Monitor and tune | **Hands‑on:** Watch WAL file grow and shrink with checkpoints |
| 5.2.12 | **LAB: busy_timeout** | Handle SQLITE_BUSY | **Hands‑on:** Set timeout; observe retry behavior |

### Module 16: Reliability & Recovery (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 5.3.1 | Database Corruption | Causes and prevention |
| 5.3.2 | PRAGMA integrity_check | Scan for corruption |
| 5.3.3 | PRAGMA foreign_key_check | Check referential integrity |
| 5.3.4 | PRAGMA quick_check | Faster, less thorough scan |
| 5.3.5 | synchronous Modes | OFF, NORMAL, FULL |
| 5.3.6 | Recovery Strategies | Restore from backup; `.dump`; `recover` extension |
| 5.3.7 | The recover Extension | Salvage data from corrupt database |
| 5.3.8 | **LAB: Simulate Corruption** | Break a database | **Hands‑on:** Corrupt a database; attempt recovery |
| 5.3.9 | **LAB: integrity_check** | Verify health | **Hands‑on:** Run integrity checks on healthy and corrupt DBs |
| 5.3.10 | **LAB: foreign_key_check** | Find violations | **Hands‑on:** Create FK violation; detect with check |

---

## Part 6: Advanced SQLite Features (Days 6–7)

### Module 17: JSON1 Extension (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 6.1.1 | JSON1 Extension Overview | Store and query JSON in SQLite |
| 6.1.2 | JSON Storage | Store as TEXT; validate with `json_valid()` |
| 6.1.3 | JSON Extraction | `json_extract()`, `->`, `->>` |
| 6.1.4 | JSON Modification | `json_set()`, `json_insert()`, `json_replace()`, `json_remove()` |
| 6.1.5 | JSON Aggregation | `json_group_array()`, `json_group_object()` |
| 6.1.6 | JSON Table Functions | `json_each()`, `json_tree()` |
| 6.1.7 | Indexing JSON Fields | Generated columns + indexes |
| 6.1.8 | Hybrid Models | Relational + document store in one schema |
| 6.1.9 | **LAB: Store and Query JSON** | Blog posts with metadata | **Hands‑on:** Insert JSON; extract fields; filter |
| 6.1.10 | **LAB: Modify JSON** | Add/update/remove fields | **Hands‑on:** Use `json_set`, `json_remove` |
| 6.1.11 | **LAB: Index JSON** | Generated columns | **Hands‑on:** Create generated column; index; query |

### Module 18: Full‑Text Search (FTS5) (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 6.2.1 | What Is FTS5? | Virtual table for full‑text search |
| 6.2.2 | FTS5 Architecture | Inverted index; tokenizers |
| 6.2.3 | Creating FTS5 Tables | `CREATE VIRTUAL TABLE ... USING fts5` |
| 6.2.4 | Inserting Data | Insert into FTS table; external content option |
| 6.2.5 | MATCH Queries | `WHERE table MATCH 'search terms'` |
| 6.2.6 | Query Syntax | Single word, phrase, prefix, AND, OR, NOT, NEAR |
| 6.2.7 | Ranking with bm25() | Relevance scoring |
| 6.2.8 | Snippets and Highlighting | `snippet()` function |
| 6.2.9 | Custom Tokenizers | Porter stemmer, unicode61 |
| 6.2.10 | External Content Tables | Link to existing table; avoid duplication |
| 6.2.11 | **LAB: Build Search Engine** | Search millions of documents | **Hands‑on:** Create FTS table; index documents; run searches |
| 6.2.12 | **LAB: Ranking** | bm25() for relevance | **Hands‑on:** Order results by relevance |
| 6.2.13 | **LAB: Snippets** | Highlight matches | **Hands‑on:** Use snippet() for excerpts |

### Module 19: Virtual Tables & Extensions (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 6.3.1 | Virtual Table Architecture | Make external data look like tables |
| 6.3.2 | CSV Virtual Table | Read CSV files as tables |
| 6.3.3 | generate_series | Built‑in virtual table for number sequences |
| 6.3.4 | spellfix1 Extension | Spelling correction |
| 6.3.5 | Custom Virtual Tables | Write in C; or Python with `sqlite3_create_module` |
| 6.3.6 | Loadable Extensions | `.load` command; `sqlite3_load_extension()` |
| 6.3.7 | Spatial Extensions | SpatiaLite for GIS |
| 6.3.8 | **LAB: CSV Virtual Table** | Query CSV directly | **Hands‑on:** Load CSV; run SELECT queries |
| 6.3.9 | **LAB: generate_series** | Generate test data | **Hands‑on:** Use generate_series for bulk inserts |

### Module 20: Triggers & Views (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 6.4.1 | What Are Triggers? | Automated actions on INSERT/UPDATE/DELETE |
| 6.4.2 | Trigger Syntax | BEFORE/AFTER/INSTEAD OF; INSERT/UPDATE/DELETE |
| 6.4.3 | OLD and NEW | Access old and new row values |
| 6.4.4 | Audit Logging | Track changes to tables |
| 6.4.5 | Data Validation | Enforce business rules |
| 6.4.6 | Soft Deletes | Mark as deleted instead of removing |
| 6.4.7 | Syncing FTS Tables | Keep FTS in sync with triggers |
| 6.4.8 | Views Overview | Saved queries that act like tables |
| 6.4.9 | Updatable Views | With `INSTEAD OF` triggers |
| 6.4.10 | Materialized Views | Emulate with tables + triggers |
| 6.4.11 | **LAB: Audit Logging** | Track all changes | **Hands‑on:** Create audit table and triggers |
| 6.4.12 | **LAB: Soft Delete** | Mark not delete | **Hands‑on:** Implement soft delete with view |
| 6.4.13 | **LAB: FTS Sync** | Keep FTS up to date | **Hands‑on:** Create triggers to sync FTS |

---

## Part 7: Programming with SQLite (Days 8–9)

### Module 21: Python Integration (2.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 7.1.1 | Python sqlite3 Module | Standard library; DB‑API 2.0 compliant |
| 7.1.2 | Connection Management | `sqlite3.connect()`; context managers |
| 7.1.3 | Cursors | Execute statements; fetch results |
| 7.1.4 | Parameterized Queries | Prevent SQL injection with `?` placeholders |
| 7.1.5 | Transactions in Python | `commit()`, `rollback()`; context manager auto‑commit |
| 7.1.6 | Row Factories | `sqlite3.Row`; custom dict factory |
| 7.1.7 | User‑Defined Functions | `create_function()`; call Python from SQL |
| 7.1.8 | Custom Aggregates | `create_aggregate()`; Python‑powered aggregations |
| 7.1.9 | Thread Safety | One connection per thread; use locks |
| 7.1.10 | Async SQLite | `aiosqlite` for async/await |
| 7.1.11 | **PROJECT: Contact Manager** | Full desktop application | **Hands‑on:** Build CLI contact manager with all CRUD |
| 7.1.12 | **LAB: Parameterized Queries** | SQL injection demo | **Hands‑on:** Show vulnerable code; fix with parameters |
| 7.1.13 | **LAB: Row Factories** | Access by name | **Hands‑on:** Use `sqlite3.Row` and custom factory |
| 7.1.14 | **LAB: Custom Functions** | Python functions in SQL | **Hands‑on:** Register and use custom functions |

### Module 22: Web Development (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 7.2.1 | Flask Integration | Connection per request; `teardown_appcontext` |
| 7.2.2 | FastAPI Integration | `aiosqlite` for async endpoints |
| 7.2.3 | Django Integration | Default database; ORM models; migrations |
| 7.2.4 | Connection Lifecycles | Open per request; close after |
| 7.2.5 | Repository Pattern | Decouple business logic from database |
| 7.2.6 | ORM vs. Raw SQL | When to use each; performance considerations |
| 7.2.7 | Testing with SQLite | `:memory:` databases for unit tests |
| 7.2.8 | **PROJECT: REST API** | Flask/FastAPI contacts API | **Hands‑on:** Build REST API with CRUD endpoints |
| 7.2.9 | **LAB: Flask Integration** | Build and test API | **Hands‑on:** Implement Flask app; test with curl |
| 7.2.10 | **LAB: FastAPI Integration** | Async endpoints | **Hands‑on:** Implement FastAPI with aiosqlite |
| 7.2.11 | **LAB: Testing** | In‑memory database | **Hands‑on:** Write unit tests with :memory: |

### Module 23: Mobile Development (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 7.3.1 | Android SQLite | `SQLiteOpenHelper`; raw SQL |
| 7.3.2 | Android Room | Type‑safe ORM; migrations; compile‑time verification |
| 7.3.3 | React Native with expo‑sqlite | Simple SQLite API |
| 7.3.4 | React Native Quick SQLite | High‑performance; separate thread |
| 7.3.5 | Flutter with sqflite | Plugin for SQLite |
| 7.3.6 | Flutter with Drift | Reactive ORM; type‑safe queries |
| 7.3.7 | Offline‑First Architecture | Local cache; sync with remote |
| 7.3.8 | Data Synchronization | Sync strategies; conflict resolution |
| 7.3.9 | Conflict Resolution | Last‑write‑wins; version vectors; merge |
| 7.3.10 | **PROJECT: Offline‑First Mobile App** | Expense tracker | **Hands‑on:** Build mobile app with local storage and sync |
| 7.3.11 | **LAB: Room Setup** | Android | **Hands‑on:** Create Room database; define entities and DAOs |
| 7.3.12 | **LAB: expo‑sqlite** | React Native | **Hands‑on:** Create and query database in React Native |
| 7.3.13 | **LAB: sqflite** | Flutter | **Hands‑on:** Use sqflite in Flutter app |

---

## Part 8: Security & Production Deployment (Day 10)

### Module 24: SQLite Security (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 8.1.1 | SQL Injection | The #1 threat; how it works |
| 8.1.2 | Parameterized Queries | Prevention; placeholders |
| 8.1.3 | File Permissions | `chmod 600`; restrict access |
| 8.1.4 | SQLCipher Overview | Transparent AES‑256 encryption |
| 8.1.5 | Installing SQLCipher | `apt install sqlcipher`; `brew install sqlcipher` |
| 8.1.6 | Creating Encrypted Databases | `PRAGMA key = 'password'` |
| 8.1.7 | SQLCipher in Python | `pysqlcipher3` |
| 8.1.8 | Key Management | Environment variables; secrets manager; secure storage |
| 8.1.9 | Column‑Level Encryption | Encrypt sensitive fields in application |
| 8.1.10 | PRAGMA secure_delete | Overwrite deleted data |
| 8.1.11 | Auditing | Track who accessed what |
| 8.1.12 | **LAB: SQLCipher** | Create and use encrypted database | **Hands‑on:** Create encrypted DB; open with password |
| 8.1.13 | **LAB: SQL Injection Demo** | Vulnerable vs. safe code | **Hands‑on:** Show injection; fix with parameters |
| 8.1.14 | **LAB: File Permissions** | Restrict access | **Hands‑on:** Set permissions; test access |

### Module 25: Backup & Maintenance (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 8.2.1 | Online Backup API | Hot backup while database is in use |
| 8.2.2 | .backup Command | CLI backup |
| 8.2.3 | Python Backup | `src.backup(dst)` |
| 8.2.4 | Database Snapshots | Copy file in WAL mode after checkpoint |
| 8.2.5 | Incremental Backups | WAL archiving; point‑in‑time recovery |
| 8.2.6 | Restore Strategies | Full restore; partial restore |
| 8.2.7 | VACUUM | Defragment; reclaim space |
| 8.2.8 | auto_vacuum | Automatic space reclamation |
| 8.2.9 | Integrity Monitoring | Scheduled `integrity_check` |
| 8.2.10 | Scheduled Maintenance | Daily backup; weekly ANALYZE; monthly VACUUM |
| 8.2.11 | **LAB: Automated Backup** | Script with retention | **Hands‑on:** Write backup script; schedule with cron |
| 8.2.12 | **LAB: Restore from Backup** | Test restore | **Hands‑on:** Restore from backup; verify integrity |

### Module 26: Production Best Practices (1.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 8.3.1 | Database Migrations | Schema versioning; Alembic, Django migrations |
| 8.3.2 | Migration Best Practices | Test in staging; have rollback plan |
| 8.3.3 | Logging | Slow query logging; error logging |
| 8.3.4 | Monitoring | Database size; WAL growth; lock contention |
| 8.3.5 | Error Handling | Retry logic for SQLITE_BUSY; exponential backoff |
| 8.3.6 | Observability | Metrics; tracing; profiling |
| 8.3.7 | Scaling Embedded Databases | Sharding; read‑only replicas |
| 8.3.8 | Embedded Analytics | OLAP with SQLite |
| 8.3.9 | Packaging SQLite Apps | Docker; static compilation; PyInstaller |
| 8.3.10 | Production Deployment Patterns | Single‑tenant; multi‑tenant; edge |
| 8.3.11 | **PRODUCTION CHECKLIST** | All settings and practices | **Hands‑on:** Review and apply production checklist |
| 8.3.12 | **LAB: Deployment** | Docker + persistent volume | **Hands‑on:** Containerize app with SQLite |

---

## Part 9: Real‑World Projects & Capstone (Days 11–12)

### Module 27: Real‑World Projects (2.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 9.1.1 | Project 1: Personal Finance Manager | Track income/expenses; budgets; reports |
| 9.1.2 | Finance: Schema Design | Categories, Transactions; views for reports |
| 9.1.3 | Finance: Implementation | CRUD; budget alerts; monthly summaries |
| 9.1.4 | **PROJECT LAB: Finance Manager** | Build and run | **Hands‑on:** Implement complete finance manager |
| 9.1.5 | Project 2: Point of Sale (POS) | Products, customers, sales, inventory |
| 9.1.6 | POS: Schema Design | Products, Customers, Sales, Sale_Items; triggers |
| 9.1.7 | POS: Implementation | Stock management; transactions; daily reports |
| 9.1.8 | **PROJECT LAB: POS System** | Build and run | **Hands‑on:** Implement POS with stock control |
| 9.1.9 | Project 3: Offline CRM | Contacts, activities, notes, sync |
| 9.1.10 | CRM: Schema Design | Contacts, Activities, Sync_Status |
| 9.1.11 | CRM: Implementation | Offline‑first; sync with remote |
| 9.1.12 | **PROJECT LAB: CRM** | Build and run | **Hands‑on:** Implement offline‑first CRM |
| 9.1.13 | Project 4: Notes with FTS | Tags, attachments, full‑text search |
| 9.1.14 | Notes: Schema Design | Notes, Tags, Note_Tags, FTS5 |
| 9.1.15 | Notes: Implementation | FTS search; snippets; ranking |
| 9.1.16 | **PROJECT LAB: Notes** | Build and run | **Hands‑on:** Implement knowledge base with FTS |

### Module 28: Capstone Project (2.5 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 9.2.1 | Capstone Overview | Task Management System |
| 9.2.2 | Requirements Analysis | Users, projects, tasks, subtasks, tags, comments |
| 9.2.3 | Database Modeling | Complete ER diagram |
| 9.2.4 | Schema Implementation | All tables, constraints, indexes |
| 9.2.5 | Advanced SQL Development | CTEs, window functions, FTS5, JSON |
| 9.2.6 | Query Optimization | Indexes; EXPLAIN QUERY PLAN; eliminate scans |
| 9.2.7 | Transaction Management | ACID; WAL mode; savepoints |
| 9.2.8 | FTS5 and JSON | Search tasks; flexible metadata |
| 9.2.9 | Triggers for Auditing | Track changes; soft delete |
| 9.2.10 | SQLCipher Security | Encrypt sensitive data |
| 9.2.11 | **PROJECT LAB: Build Capstone** | Full implementation | **Hands‑on:** Complete task management system |
| 9.2.12 | **PROJECT LAB: Test Capstone** | Verify all features | **Hands‑on:** Test constraints, triggers, FTS, JSON |

### Module 29: Capstone Finalization & Deployment (2 hours)

| Slide # | Topic | Key Points | Code/Lab |
|---------|-------|------------|----------|
| 9.3.1 | FastAPI Backend | REST API for task management |
| 9.3.2 | Authentication | JWT; password hashing |
| 9.3.3 | CRUD Endpoints | Projects, tasks, comments, tags |
| 9.3.4 | Search Endpoint | FTS5 with ranking |
| 9.3.5 | Report Endpoints | Task summary; user load |
| 9.3.6 | Backup Automation | Daily backups; retention |
| 9.3.7 | Maintenance Scripts | Integrity checks; VACUUM; ANALYZE |
| 9.3.8 | Performance Benchmarking | Measure and tune |
| 9.3.9 | Deployment | Docker; persistent volume |
| 9.3.10 | **CAPSTONE LAB: Full Deployment** | Containerize and deploy | **Hands‑on:** Deploy complete system |
| 9.3.11 | **CAPSTONE LAB: Performance Test** | Benchmark | **Hands‑on:** Run benchmarks; optimize |
| 9.3.12 | Capstone Presentation | Showcase your work | **Hands‑on:** Present your completed system |

---

## Course Wrap‑Up

### Session 9.4: Conclusion & Next Steps (30 min)

| Slide # | Topic | Key Points |
|---------|-------|------------|
| 9.4.1 | Summary of Learning | All 9 parts recapped |
| 9.4.2 | Skills Mastered | 15+ concrete skills |
| 9.4.3 | Portfolio of Projects | Finance Manager, POS, Notes, CRM, Task Management |
| 9.4.4 | SQLite Philosophy Recap | Small, fast, reliable |
| 9.4.5 | Resources for Continued Learning | Official docs, SQLCipher, DB Browser, forums |
| 9.4.6 | Community and Support | SQLite Forum, Stack Overflow, Reddit |
| 9.4.7 | Next Steps | Advanced topics, contributions, extensions |
| 9.4.8 | Final Q&A | Open floor for questions |
| 9.4.9 | Course Evaluation | Feedback form |

---

## Appendices (Reference Slides)

### Appendix A: SQLite CLI Cheat Sheet

| Command | Description |
|---------|-------------|
| `.tables` | List all tables |
| `.schema [table]` | Show CREATE statement |
| `.dump [table]` | Export data as SQL |
| `.backup file` | Create hot backup |
| `.import file table` | Import CSV |
| `.mode [mode]` | Set output mode |
| `.headers on|off` | Toggle column headers |
| `.exit` | Quit shell |

### Appendix B: Essential PRAGMAs

| PRAGMA | Recommended Value |
|--------|-------------------|
| `journal_mode` | `WAL` |
| `synchronous` | `NORMAL` |
| `cache_size` | `10000`–`100000` |
| `busy_timeout` | `5000` |
| `foreign_keys` | `ON` |
| `mmap_size` | `268435456` |

### Appendix C: SQLite Error Codes

| Code | Name | Description |
|------|------|-------------|
| 0 | SQLITE_OK | Success |
| 5 | SQLITE_BUSY | Database locked |
| 19 | SQLITE_CONSTRAINT | Constraint violation |
| 10 | SQLITE_IOERR | I/O error |
| 11 | SQLITE_CORRUPT | Database corrupt |
| 14 | SQLITE_CANTOPEN | Cannot open file |

### Appendix D: SQLite Ecosystem Tools

| Tool | Purpose |
|------|---------|
| **DB Browser for SQLite** | GUI administration |
| **SQLiteStudio** | Advanced GUI |
| **sqlite3_analyzer** | Storage analysis |
| **sqldiff** | Schema/data diff |
| **SQLCipher** | Encryption |
| **SpatiaLite** | Spatial/GIS |
| **Datasette** | Web exploration |

---

## Summary

This comprehensive slide outline provides **over 200 slides** across **9 parts** and **29 modules**, covering the entire journey from SQLite fundamentals to production deployment. Each module includes:
- **Conceptual slides** with clear explanations and analogies
- **Code examples** with complete, copy‑pasteable syntax
- **Hands‑on labs** with verification steps
- **Real‑world projects** that build toward the capstone

The course is designed for **9–12 days** of instruction (or 18–24 half‑day sessions) and is suitable for both self‑paced learning and instructor‑led training.
