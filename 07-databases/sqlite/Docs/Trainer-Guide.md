# Trainer Guide: Master SQLite — From Fundamentals to Production Systems

---

## About This Guide

This **Trainer Guide** is designed for instructors, workshop leaders, and corporate trainers delivering the **Master SQLite** course. It provides:

- **Detailed session plans** with timing and pacing
- **Teaching strategies** for different learning styles
- **Common pitfalls** and how to address them
- **Discussion questions** for each module
- **Assessment strategies** and grading rubrics
- **Classroom management tips**
- **Adaptations** for various audience levels

Use this guide alongside the **Slide Outline**, **Student Workbook**, **Student Notes**, and **Quiz/Test Bank** to deliver a world‑class training experience.

---

## Part 1: Course Overview

### Course Metadata

| Attribute | Details |
|-----------|---------|
| **Full Title** | Master SQLite: From Fundamentals to Production Systems |
| **Duration** | 9‑12 days (or 18‑24 half‑day sessions) |
| **Target Audience** | Developers, data engineers, architects, students |
| **Prerequisites** | Basic programming; command‑line familiarity |
| **Delivery Format** | Lecture + Live Demos + Hands‑on Labs + Projects |
| **Assessment** | Quizzes, lab completion, capstone project |
| **Certification** | Certificate of Completion based on capstone evaluation |

### Course Flow Overview

```
Part 0: Introduction (0.5 day)
Part 1: Foundations & Architecture (1 day)
Part 2: SQL Programming (1 day)
Part 3: Database Design (1 day)
Part 4: Indexing & Optimization (1 day)
Part 5: Transactions & Concurrency (1 day)
Part 6: Advanced Features (1.5‑2 days)
Part 7: Programming with SQLite (1.5‑2 days)
Part 8: Security & Production (1 day)
Part 9: Projects & Capstone (1‑2 days)
```

---

## Part 2: Trainer Preparation Checklist

### Before the Course

| Task | Details | Status |
|------|---------|--------|
| **Environment Setup** | Ensure all students have SQLite installed, DB Browser, Python 3.8+ |
| **Sample Data** | Prepare all sample CSV files, seed databases |
| **Slide Deck** | Review all slides; adjust for audience level |
| **Workbook Distribution** | Print or share digital Student Workbook and Notes |
| **Test Environment** | Verify all lab scripts work on target OSes |
| **Backup Plans** | Prepare alternative exercises for technology failures |
| **Communication** | Send pre‑course email with setup instructions |
| **Office Hours** | Schedule availability for extra help |

### Day‑by‑Day Preparation

| Day | Morning Prep | Afternoon Prep |
|-----|--------------|----------------|
| 1 | Verify SQLite install; prepare `first.db` demo | Prepare type affinity examples; schema scripts |
| 2 | Prepare sample data for CRUD labs | Prepare join and aggregation queries |
| 3 | Prepare denormalized table for normalization lab | Prepare capstone schema requirements |
| 4 | Prepare indexing benchmark script (1M rows) | Prepare PRAGMA tuning examples |
| 5 | Prepare two‑terminal concurrency demos | Prepare corruption simulation (safely) |
| 6 | Prepare JSON, FTS, trigger examples | Prepare CSV virtual table demo |
| 7 | Prepare Python script skeletons | Prepare Flask/FastAPI starter code |
| 8 | Prepare SQLCipher installation (if used) | Prepare Dockerfile and deployment scripts |
| 9‑10 | Capstone: ensure all requirements are clear | Prepare evaluation rubrics |

---

## Part 3: Teaching Strategies

### General Pedagogy

1. **Show, Don't Just Tell** – Every concept should have a live demo.
2. **Code Along** – Students should type every query themselves.
3. **Verification First** – Always teach how to verify a step before moving on.
4. **Error as Learning** – Deliberately show common errors and how to fix them.
5. **Pair Programming** – Encourage students to work in pairs for labs.
6. **Retrieval Practice** – Start each day with a quick recap quiz.

### Pacing Guide

| Segment | Duration | Activity |
|---------|----------|----------|
| Opening | 5 min | Recap, objectives, agenda |
| Lecture | 20‑30 min | New concepts with analogies |
| Live Demo | 15‑20 min | Walk through code with commentary |
| Lab | 30‑45 min | Students work independently or in pairs |
| Verification | 10 min | Review solutions, discuss challenges |
| Debrief | 10 min | Q&A, key takeaways, preview next |

### Handling Common Student Challenges

| Challenge | Strategy |
|-----------|----------|
| **"My query doesn't work"** | Teach systematic debugging: check syntax, table names, column names, quotes; use `EXPLAIN`. |
| **"SQL injection? I just use f‑strings"** | Show a live injection demo to make the danger real. |
| **"Why not just use PostgreSQL?"** | Use the decision matrix; emphasize simplicity and embedded use cases. |
| **"Indexes are confusing"** | Use the phone book analogy; show `EXPLAIN QUERY PLAN` before and after. |
| **"My database is slow"** | Teach systematic tuning: query → EXPLAIN → indexes → PRAGMAs → VACUUM. |
| **"I don't understand normalization"** | Start with a bad design (spreadsheet) and incrementally improve it. |
| **"Transactions are boring"** | Show the money transfer example with a simulated crash. |
| **"FTS5 seems complicated"** | Start with the simplest search and add ranking/snippets incrementally. |

### Active Learning Techniques

1. **Think‑Pair‑Share** – For conceptual questions, have students think individually, discuss with a partner, then share with the class.
2. **Live Polling** – Use tools like Slido or Mentimeter to assess understanding.
3. **Bug‑Hunt** – Show a broken query and have students find and fix it.
4. **Concept Mapping** – Have students draw ER diagrams on whiteboards.
5. **Peer Review** – Students review each other's capstone schemas.

---

## Part 4: Detailed Day‑by‑Day Session Plans

---

### Day 1: Part 0 & Part 1 (Modules 1‑2)

**Theme:** Getting Started & How SQLite Works

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Welcome & Course Intro | Overview, syllabus, introductions | Set expectations |
| 9:15‑9:45 | Part 0: What is SQLite? | Lecture: history, philosophy, use cases | Use the "filing cabinet" analogy |
| 9:45‑10:15 | Lab 1.1: Install & Verify | Students install SQLite, verify version | Walk around; help with PATH issues |
| 10:15‑10:45 | Lab 1.2: First Database | Create `first.db`; `.databases`; first queries | Emphasize the single‑file concept |
| 10:45‑11:00 | Break | | |
| 11:00‑11:30 | Module 1: CLI Essentials | `.tables`, `.schema`, `.dump`, `.backup` | Live demo |
| 11:30‑12:15 | Module 2: Architecture | The pipeline: Parser → Code Gen → VDBE → B‑Tree → Pager | Use the restaurant kitchen analogy |
| 12:15‑12:30 | Lab 2.1: EXPLAIN & EXPLAIN QUERY PLAN | Students run EXPLAIN; discuss output | Key: `SCAN` vs `SEARCH` |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:00 | Module 2: B‑Tree, Page Cache, Locking | Deeper dive; `.dbinfo` | Show page layout if possible |
| 14:00‑14:30 | Lab 2.2: Explore Database Internals | `.dbinfo`; DB Browser for SQLite | Walk students through GUI |
| 14:30‑15:00 | Lab 2.3: Locking Demo | Two terminals; observe `SQLITE_BUSY` | Dramatic demonstration |
| 15:00‑15:15 | Break | | |
| 15:15‑15:45 | Module 3: Data Types | Storage classes, type affinity | Show `typeof()` experiments |
| 15:45‑16:30 | Lab 3.1: Type Affinity | Insert mismatched values; observe conversions | Key insight: SQLite is flexible |
| 16:30‑17:00 | Wrap‑up & Q&A | Recap; preview Day 2; answer questions | Homework: read Module 3 notes |

**Key Teaching Points for Day 1:**
- Emphasize the "single file" concept – it's what makes SQLite unique.
- The VDBE is the heart of SQLite; explain it's like a bytecode interpreter.
- Type affinity is a feature, not a bug – embrace it.

**Common Pitfalls:**
- Students may struggle with PATH setup (Windows).
- `EXPLAIN` output can be intimidating – focus on `EXPLAIN QUERY PLAN` first.

---

### Day 2: Part 1 (Modules 3‑4) & Part 2 (Module 5)

**Theme:** Data Types, Tables, and CRUD

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 1 | Quick quiz: storage classes, architecture | Retrieval practice |
| 9:15‑9:45 | Module 3: ROWID vs. WITHOUT ROWID | Comparisons; performance implications | Show with large dataset |
| 9:45‑10:30 | Lab 3.2: ROWID Experiment | Create both table types; compare performance | Use `generate_series` |
| 10:30‑11:00 | Module 4: CREATE TABLE | Columns, constraints, foreign keys, CHECK | Walk through each constraint |
| 11:00‑11:15 | Break | | |
| 11:15‑12:00 | Lab 4.1: Library Schema | Students create a complete normalized library schema | Provide requirements; check constraints |
| 12:00‑12:30 | Module 4: ALTER TABLE, DROP TABLE, Generated Columns | Live demos | Show `ALTER TABLE RENAME COLUMN` |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:00 | Module 5: CRUD Overview | `INSERT`, `SELECT`, `UPDATE`, `DELETE` | Review each command |
| 14:00‑14:45 | Lab 5.1: Customer Database | Build and query | Use `.timer on` to show performance |
| 14:45‑15:15 | Module 5: ORDER BY, LIMIT, DISTINCT | Sorting, pagination, duplicates | |
| 15:15‑15:30 | Break | | |
| 15:30‑16:15 | Lab 5.2: Product Inventory | Complete CRUD with sorting and pagination | |
| 16:15‑16:45 | Module 6: Filtering Intro | `WHERE`, `AND`/`OR`, `BETWEEN`, `IN` | |
| 16:45‑17:00 | Wrap‑up & Q&A | Recap; preview Day 3 | |

**Key Teaching Points for Day 2:**
- Spend time on foreign keys – they're critical for data integrity.
- Generated columns are an underrated feature; show both `STORED` and `VIRTUAL`.
- Always use `WHERE` in `UPDATE` and `DELETE` – demonstrate the danger of forgetting.

**Common Pitfalls:**
- Students forget to enable `PRAGMA foreign_keys = ON`.
- `ALTER TABLE` limitations (can't drop columns, can't rename columns in older versions).
- Students accidentally run `UPDATE` or `DELETE` without `WHERE`.

---

### Day 3: Part 2 (Modules 6‑8)

**Theme:** Filtering, Joins, and Aggregation

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 2 | Quick quiz: constraints, CRUD | Retrieval practice |
| 9:15‑9:45 | Module 6: Advanced Filtering | `LIKE`, `GLOB`, `CASE`, `NULL` handling | Show `CASE` in `ORDER BY` |
| 9:45‑10:30 | Lab 6.1: Advanced Filtering | Multiple complex `WHERE` conditions | |
| 10:30‑11:00 | Module 7: JOINs | `INNER`, `LEFT`, `CROSS`, `SELF` | Use Venn diagrams |
| 11:00‑11:15 | Break | | |
| 11:15‑12:00 | Lab 7.1: University Database | Implement M:N with junction table | |
| 12:00‑12:30 | Module 7: Many‑to‑Many | Junction tables; composite keys | |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:00 | Lab 7.2: Sales Database | Complex joins across multiple tables | |
| 14:00‑14:30 | Module 8: Aggregates | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` | |
| 14:30‑15:00 | Lab 8.1: GROUP BY & HAVING | Grouping and filtering groups | |
| 15:00‑15:15 | Break | | |
| 15:15‑15:45 | Module 8: CTEs | `WITH` clauses; recursive CTEs | Show tree traversal |
| 15:45‑16:15 | Module 8: Window Functions | `ROW_NUMBER`, `RANK`, `LAG`, `LEAD`, `SUM OVER` | Use `PARTITION BY` |
| 16:15‑16:45 | Lab 8.2: Financial Summaries | Use window functions for running totals | |
| 16:45‑17:00 | Wrap‑up & Q&A | Recap; preview Day 4 | |

**Key Teaching Points for Day 3:**
- Left joins are the most common source of confusion – emphasise `NULL` handling.
- CTEs are underused; show how they improve readability.
- Window functions are a game‑changer for analytics – spend extra time here.

**Common Pitfalls:**
- Students forget to `GROUP BY` when using aggregate functions.
- Missing rows in `LEFT JOIN` due to incorrect join condition.
- Window functions without `PARTITION BY` (or thinking they are required).

---

### Day 4: Part 3 (Modules 9‑10)

**Theme:** Database Design & Normalization

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 3 | Quick quiz: joins, aggregates, window functions | |
| 9:15‑10:00 | Module 9: ER Modeling | Entities, attributes, relationships, cardinalities | Draw ER diagram on whiteboard |
| 10:00‑10:45 | Module 9: Normalization | 1NF, 2NF, 3NF | Start with a bad spreadsheet; improve step‑by‑step |
| 10:45‑11:00 | Break | | |
| 11:00‑11:45 | Lab 9.1: Normalize a Denormalized Table | Students fix a bad design; decompose to 3NF | |
| 11:45‑12:30 | Module 9: Keys & Naming | Natural vs. surrogate; FK references; conventions | |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:15 | Module 10: E‑Commerce Schema | Design walkthrough | |
| 14:15‑15:00 | Module 10: Hospital Management Schema | Design walkthrough | |
| 15:00‑15:15 | Break | | |
| 15:15‑16:00 | Module 10: Student Information Schema | Design walkthrough | |
| 16:00‑17:00 | Lab 10.1: Library Management Capstone | Complete schema from requirements | Main capstone – allow sufficient time |

**Key Teaching Points for Day 4:**
- Normalization is learned by doing; it's harder than it looks.
- Emphasise that denormalization is *sometimes* appropriate (performance).
- The Library Management Lab is the capstone – allow students to work in pairs.

**Common Pitfalls:**
- Students over‑normalize (splitting every possible attribute into separate tables).
- Missing foreign keys.
- Forgetting indexes on foreign keys.

---

### Day 5: Part 4 (Modules 11‑13)

**Theme:** Indexing & Query Optimization

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 4 | Quick quiz: normalization | |
| 9:15‑10:00 | Module 11: Indexes | Types: B‑Tree, composite, partial, covering, expression | Use phone book analogy |
| 10:00‑10:45 | Lab 11.1: Create and Measure Indexes | 1M row experiment; measure before/after | Critical lab – stay close to students |
| 10:45‑11:00 | Break | | |
| 11:00‑11:30 | Module 11: When to Index | Decision matrix; tradeoffs | |
| 11:30‑12:15 | Lab 11.2: Composite & Covering Indexes | Test left‑most prefix; covering index | |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:00 | Module 12: Query Planner | `EXPLAIN QUERY PLAN`; cost estimation; `ANALYZE` | |
| 14:00‑14:30 | Lab 12.1: Reading Plans | Interpret `SCAN` vs `SEARCH`; detect inefficient queries | |
| 14:30‑15:00 | Lab 12.2: ANALYZE | Update stats; observe plan changes | |
| 15:00‑15:15 | Break | | |
| 15:15‑15:45 | Module 13: PRAGMA Tuning | `cache_size`, `mmap_size`, `temp_store` | |
| 15:45‑16:15 | Module 13: Bulk Loading | Transactions; `synchronous=OFF`; `journal_mode=OFF` | |
| 16:15‑16:45 | Lab 13.1: Bulk Loading Experiment | Compare with/without transaction | |
| 16:45‑17:00 | Wrap‑up & Q&A | | |

**Key Teaching Points for Day 5:**
- The index lab (1M rows) is the "Aha!" moment – it makes the value of indexes tangible.
- Covering indexes are often overlooked; emphasise their power.
- `EXPLAIN QUERY PLAN` is the most important tuning tool.

**Common Pitfalls:**
- Students create indexes on every column (over‑indexing).
- Forgetting to run `ANALYZE`.
- Not understanding the left‑most prefix rule.

---

### Day 6: Part 5 (Modules 14‑16)

**Theme:** Transactions & Concurrency

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 5 | Quick quiz: indexes | |
| 9:15‑10:00 | Module 14: ACID Transactions | Atomicity, Consistency, Isolation, Durability | Money transfer example |
| 10:00‑10:45 | Lab 14.1: Basic Transactions | Transfer money; test rollback | |
| 10:45‑11:00 | Break | | |
| 11:00‑11:30 | Module 14: Savepoints | Nested transactions; partial rollback | |
| 11:30‑12:00 | Lab 14.2: Savepoints | Use savepoints; release them | |
| 12:00‑12:30 | Module 15: Rollback Journal | How it works; journal file creation | Show `-journal` file |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:15 | Module 15: WAL Mode | Write‑Ahead Logging; checkpoints; concurrency | Key: readers don't block writers |
| 14:15‑15:00 | Lab 15.1: Compare Rollback vs. WAL | Measure performance; test concurrent access | |
| 15:00‑15:15 | Break | | |
| 15:15‑15:45 | Module 16: Reliability | `integrity_check`, `foreign_key_check`, `quick_check` | |
| 15:45‑16:15 | Module 16: Recovery | Backup restore; `.dump`; `recover` extension | |
| 16:15‑16:45 | Lab 16.1: Simulate Corruption | Demonstrate corruption and recovery | **Warning:** students may break their DB – have backups! |
| 16:45‑17:00 | Wrap‑up & Q&A | | |

**Key Teaching Points for Day 6:**
- WAL mode is the single most important PRAGMA for production.
- `integrity_check` should be part of every maintenance routine.
- `SQLITE_BUSY` is not an error – it's a signal to retry.

**Common Pitfalls:**
- Students forget to enable WAL.
- Not handling `SQLITE_BUSY` with `busy_timeout`.
- Running `VACUUM` without enough free disk space.

---

### Day 7: Part 6 (Modules 17‑18)

**Theme:** Advanced Features – JSON & FTS5

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 6 | Quick quiz: transactions, WAL | |
| 9:15‑10:00 | Module 17: JSON1 | `json_extract`, `json_set`, `json_array`, aggregation | |
| 10:00‑10:45 | Lab 17.1: Store and Query JSON | Products with attributes; extract fields | |
| 10:45‑11:00 | Break | | |
| 11:00‑11:30 | Module 17: Indexing JSON | Generated columns + indexes | |
| 11:30‑12:15 | Lab 17.2: Build Document Store | Blog posts with metadata | |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:15 | Module 18: FTS5 | Creating virtual tables; `MATCH` queries | |
| 14:15‑15:00 | Lab 18.1: Build Search Engine | Index documents; run searches | |
| 15:00‑15:15 | Break | | |
| 15:15‑15:45 | Module 18: Ranking & Snippets | `bm25()`, `snippet()` | |
| 15:45‑16:30 | Lab 18.2: Search with Ranking | Sort by relevance; highlight matches | |
| 16:30‑17:00 | Wrap‑up & Q&A | | |

**Key Teaching Points for Day 7:**
- JSON is a "relational plus document" hybrid – show both patterns.
- FTS5 is dramatically faster than `LIKE` – do a comparison if time permits.
- Generated columns are the key to indexing JSON fields.

**Common Pitfalls:**
- Students forget `->>` vs `->` (returns JSON vs TEXT).
- Not using `json_valid()` to check data before inserting.
- Forgetting to sync FTS with triggers.

---

### Day 8: Part 6 (Modules 19‑20) & Part 7 (Module 21)

**Theme:** Virtual Tables, Triggers, Views, and Python Integration

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 7 | Quick quiz: JSON, FTS | |
| 9:15‑9:45 | Module 19: Virtual Tables | CSV virtual table; `generate_series` | |
| 9:45‑10:15 | Lab 19.1: CSV Virtual Table | Load CSV; query | |
| 10:15‑10:30 | Module 19: Extensions | `.load`, loadable extensions | |
| 10:30‑11:00 | Module 20: Triggers | `BEFORE`, `AFTER`, `INSTEAD OF`; `OLD` and `NEW` | |
| 11:00‑11:15 | Break | | |
| 11:15‑12:00 | Lab 20.1: Audit Logging | Create audit table and triggers | |
| 12:00‑12:30 | Lab 20.2: Soft Delete | Implement with `INSTEAD OF` trigger | |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:00 | Module 20: Views | Create views; updatable views | |
| 14:00‑14:30 | Lab 20.3: FTS Sync | Triggers to keep FTS in sync | |
| 14:30‑15:00 | Module 21: Python `sqlite3` | Connection, cursor, parameterized queries | |
| 15:00‑15:15 | Break | | |
| 15:15‑16:00 | Lab 21.1: Contact Manager | Python CRUD functions | |
| 16:00‑16:30 | Module 21: Row Factory, Custom Functions | `sqlite3.Row`, `create_function()` | |
| 16:30‑17:00 | Wrap‑up & Q&A | | |

**Key Teaching Points for Day 8:**
- Triggers are powerful but can be performance killers – keep them simple.
- `INSTEAD OF` triggers on views are underappreciated.
- Parameterized queries are non‑negotiable.

**Common Pitfalls:**
- Trigger recursion (infinite loops).
- Forgetting to enable `foreign_keys`.
- Using f‑strings in Python (SQL injection).

---

### Day 9: Part 7 (Modules 22‑23) & Part 8 (Module 24)

**Theme:** Web, Mobile, and Security

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 8 | Quick quiz: triggers, views | |
| 9:15‑10:00 | Module 22: Web Development | Flask integration; connection per request | |
| 10:00‑10:45 | Lab 22.1: Flask REST API | Build contacts API; test with `curl` | |
| 10:45‑11:00 | Break | | |
| 11:00‑11:30 | Module 22: FastAPI | `aiosqlite`; async patterns | |
| 11:30‑12:00 | Module 22: Testing | `:memory:` databases for unit tests | |
| 12:00‑12:30 | Module 23: Mobile Overview | Android, React Native, Flutter | High‑level; not full labs |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:15 | Module 24: Security | SQL injection; parameterized queries; file permissions | |
| 14:15‑15:00 | Lab 24.1: SQL Injection Demo | Show vulnerable vs. safe code | |
| 15:00‑15:15 | Break | | |
| 15:15‑16:00 | Module 24: Encryption | SQLCipher installation; `PRAGMA key` | |
| 16:00‑16:30 | Lab 24.2: SQLCipher | Create encrypted database; use with Python | |
| 16:30‑17:00 | Wrap‑up & Q&A | | |

**Key Teaching Points for Day 9:**
- SQL injection demonstration is high‑impact – make it vivid.
- SQLCipher is easy to demonstrate but may require installation.
- Emphasise that `:memory:` databases are perfect for testing.

**Common Pitfalls:**
- SQLCipher installation may fail; have alternative demos.
- Students may not understand async patterns for FastAPI.
- Forgetting to set `PRAGMA foreign_keys = ON` in web apps.

---

### Day 10: Part 8 (Modules 25‑26)

**Theme:** Backup, Maintenance, Production

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| 9:00‑9:15 | Recap Day 9 | Quick quiz: security | |
| 9:15‑10:00 | Module 25: Backup | `.backup`; Python backup API; cold backups | |
| 10:00‑10:45 | Lab 25.1: Backup Automation | Script with timestamp, retention | |
| 10:45‑11:00 | Break | | |
| 11:00‑11:30 | Module 25: Maintenance | `VACUUM`, `ANALYZE`, `integrity_check` | |
| 11:30‑12:00 | Lab 25.2: Maintenance Script | Combine backup + integrity + VACUUM | |
| 12:00‑12:30 | Module 26: Production Settings | All PRAGMAs; deployment checklist | |
| 12:30‑13:30 | Lunch | | |
| 13:30‑14:15 | Module 26: Migration | Schema versioning; Alembic, Django migrations | |
| 14:15‑15:00 | Module 26: Monitoring & Observability | Logging; metrics; profiling | |
| 15:00‑15:15 | Break | | |
| 15:15‑16:00 | Module 26: Deployment | Docker; volumes; health checks | |
| 16:00‑16:45 | Lab 26.1: Dockerize App | Students containerize a Flask app | |
| 16:45‑17:00 | Wrap‑up & Q&A | Production checklist recap | |

**Key Teaching Points for Day 10:**
- `VACUUM` is essential but often forgotten.
- Migration strategies are critical in real projects.
- Docker deployment is the capstone of the production module.

**Common Pitfalls:**
- Students forget to test their backups (restore from backup).
- Not enough disk space for `VACUUM`.
- WAL file grows too large due to missing checkpoints.

---

### Days 11‑12: Part 9 — Real‑World Projects & Capstone

**Theme:** Build, Present, and Deploy

| Time | Topic | Activity | Notes |
|------|-------|----------|-------|
| Day 11 (AM) | Project 1: Finance Manager | Students build finance manager | |
| Day 11 (PM) | Project 2: POS System | Students build POS with triggers | |
| Day 11 (End) | Project 3: Notes with FTS | Students build knowledge base | |
| Day 12 (AM) | Capstone: Task Management | Students build full stack system | |
| Day 12 (PM) | Capstone: Finish & Present | Presentations; final code review | |

**Project 1: Finance Manager**
- Schema: Categories, Transactions
- Features: Add transactions, monthly reports, budget alerts
- Deliverables: SQL schema + Python CLI

**Project 2: POS System**
- Schema: Products, Customers, Sales, Sale_Items
- Features: Stock management, triggers, daily reports
- Deliverables: SQL schema + Python functions

**Project 3: Notes with FTS**
- Schema: Notes, Tags, Note_Tags, FTS5
- Features: Search, ranking, snippets
- Deliverables: SQL schema + Python search functions

**Capstone: Task Management System**
- Schema: Users, Projects, Tasks, Task_Tags, Comments, Audit_Log
- Features: CRUD, FTS5, JSON metadata, audit triggers, FastAPI
- Deliverables: Complete schema + FastAPI endpoints + Docker deployment

---

## Part 5: Assessment Strategies

### Formative Assessment (During Course)
| Technique | Frequency | Purpose |
|-----------|-----------|---------|
| **Quick Quizzes** | Start of each day | Check retention; low stakes |
| **Lab Completion** | After each lab | Practical skill verification |
| **Peer Review** | During capstone | Collaborative learning |
| **Code Walkthrough** | Random | Identify misconceptions |

### Summative Assessment (End of Course)
| Component | Weight | Description |
|-----------|--------|-------------|
| **Lab Completion** | 20% | All labs submitted |
| **Quizzes** | 20% | Scores from pre‑lab/post‑lab quizzes |
| **Projects (3)** | 30% | Each project contributes 10% |
| **Capstone** | 30% | Complete system + presentation |

### Capstone Grading Rubric
| Category | Excellent (90‑100%) | Good (70‑89%) | Satisfactory (50‑69%) | Needs Work (<50%) |
|----------|---------------------|---------------|-----------------------|-------------------|
| **Schema Design** | Normalized to 3NF; all constraints; appropriate indexes | Mostly normalized; some constraints | Some normalization issues; minimal constraints | Poor design; no normalization |
| **SQL Implementation** | Advanced queries (CTEs, windows, FTS); efficient joins | Good SQL; some advanced features | Basic SQL; misses some features | Poor or broken SQL |
| **Application Integration** | Full CRUD; parameterised queries; error handling | Most CRUD; some error handling | Basic CRUD; minimal error handling | Incomplete; no error handling |
| **Security & Settings** | WAL; encryption; busy_timeout; secure permissions | Most security features | Some security features | No security |
| **Backup & Maintenance** | Automated backup; integrity checks; VACUUM planned | Some automation | Manual backups | No backup strategy |
| **Deployment** | Docker; persistent volume; health checks | Containerised | Some deployment | None |
| **Presentation** | Clear; covers design, code, tests, deployment | Good coverage | Basic coverage | Incomplete |

---

## Part 6: Discussion Questions

### Part 1: Foundations
1. "Why does SQLite use dynamic typing instead of static typing? Is this a strength or a weakness?"
2. "What would happen if SQLite didn't have a page cache?"
3. "The VDBE is often compared to a virtual machine. What other database engines use similar architectures?"

### Part 2: SQL Programming
4. "When would you choose `LEFT JOIN` over `INNER JOIN`, and what are the performance implications?"
5. "How would you implement a `FULL OUTER JOIN` in SQLite using only `LEFT` and `RIGHT` joins?"
6. "What's the most surprising thing you learned about window functions?"

### Part 3: Database Design
7. "Can you think of a situation where denormalization would be justified?"
8. "How would you handle a many‑to‑many relationship with additional attributes on the relationship itself?"

### Part 4: Indexing & Optimization
9. "How would you decide whether to create a composite or separate single‑column indexes?"
10. "If you remove an index, will the query planner always be wrong? Why or why not?"

### Part 5: Transactions
11. "How would you design a system that must survive a power failure mid‑transaction?"
12. "Why would a developer choose rollback journal over WAL?"

### Part 6: Advanced Features
13. "What types of data are best stored as JSON versus relational tables?"
14. "How would you integrate FTS5 with an existing table without duplicating data?"

### Part 7: Programming
15. "Why is connection pooling not typically used with SQLite?"
16. "How would you handle offline‑first sync with SQLite on a mobile app?"

### Part 8: Security & Production
17. "What are the trade‑offs of encrypting the entire database versus only sensitive columns?"
18. "How would you design a zero‑downtime migration strategy?"

---

## Part 7: Common Pitfalls and How to Address Them

### General Pitfalls

| Pitfall | Symptoms | Solution |
|---------|----------|----------|
| **Forgotten `WHERE`** | Entire table updated/deleted | Always verify `WHERE`; use `SELECT` first |
| **Missing foreign key index** | Slow joins | Teach that FKs aren't auto‑indexed |
| **No backup** | Data loss | Make backup a ritual; automate from Day 1 |
| **Not using `EXPLAIN`** | Mysterious slowness | Make `EXPLAIN QUERY PLAN` mandatory after every new query |
| **Over‑indexing** | Slow writes | Teach the trade‑off; use `ANALYZE` |
| **Underspecifying columns** | Slow queries | Teach covering indexes; `SELECT *` is lazy |
| **Hard‑coded credentials** | Security breach | Teach environment variables from first Python lab |
| **Forgetting `COMMIT`** | Data not saved | Show context manager pattern |

### Module‑Specific Pitfalls

| Module | Pitfall | Solution |
|--------|---------|----------|
| **Type Affinity** | Mistaking affinity for enforcement | Show `typeof()` experiments |
| **Joins** | Forgetting `ON` clause | Show cross‑join by accident |
| **CTEs** | Using CTEs where subquery is simpler | Discuss trade‑offs |
| **Window Functions** | Missing `ORDER BY` | Show error message; explain |
| **WAL** | WAL file grows huge | Teach checkpoint monitoring |
| **JSON** | Invalid JSON insert | Use `json_valid()` in CHECK |
| **FTS5** | Not syncing FTS table | Teach triggers explicitly |
| **SQL injection** | Student uses f‑strings | Show live injection demo |
| **SQLCipher** | Key forgotten | Teach key management first |

---

## Part 8: Additional Trainer Tips

### Classroom Setup
- **Projector/Dual Monitor** – One for slides, one for terminal/code.
- **Internet** – Some students may need to download packages.
- **Backup Data** – Pre‑generate large datasets to avoid waiting during labs.
- **Chat Channel** – Slack/Discord for real‑time help during labs.

### Time Management
- **Use a Timer** – Keep labs on track with a visible timer.
- **Stretch Breaks** – Every 90 minutes, take a 5‑minute break.
- **"Fist to Five"** – Check understanding: students show fingers (5 = understand well).
- **Parking Lot** – Write off‑topic questions on a board; answer later.

### Remote Teaching Adaptations
- **Screen Sharing** – Use a dedicated "live coding" screen.
- **Breakout Rooms** – For pair programming in remote labs.
- **Shared Code Repo** – Provide starter code and lab solutions.
- **Record Sessions** – Allow students to review later.

---

## Part 9: Quick Reference for Trainers

### Essential PRAGMAs to Emphasise
```sql
PRAGMA journal_mode = WAL;        -- #1 for production
PRAGMA synchronous = NORMAL;      -- Balance
PRAGMA foreign_keys = ON;         -- Always
PRAGMA busy_timeout = 5000;       -- Prevents SQLITE_BUSY
PRAGMA cache_size = 20000;        -- Performance
```

### Key Commands for Live Demos
```bash
sqlite3 mydb.db ".tables"
sqlite3 mydb.db ".schema users"
sqlite3 mydb.db "EXPLAIN QUERY PLAN SELECT * FROM users"
sqlite3 mydb.db ".backup backup.db"
sqlite3 mydb.db "PRAGMA integrity_check"
sqlite3 mydb.db "VACUUM"
```

### Key Python Patterns
```python
# Connection with context manager
with sqlite3.connect('mydb.db') as conn:
    cursor = conn.execute('SELECT * FROM users')

# Row factory
conn.row_factory = sqlite3.Row

# Parameterised query
cursor.execute('SELECT * FROM users WHERE name = ?', (name,))
```

---

## Part 10: Trainer Resources

### Essential References
1. **Official SQLite Documentation** – https://www.sqlite.org/docs.html
2. **SQLite Forum** – https://sqlite.org/forum
3. **SQLCipher Docs** – https://www.zetetic.net/sqlcipher/
4. **FTS5 Reference** – https://www.sqlite.org/fts5.html
5. **JSON1 Reference** – https://www.sqlite.org/json1.html

### Equipment Checklist
- [ ] Instructor laptop with SQLite, Python, Docker
- [ ] Projector / large screen
- [ ] Whiteboard / flip chart
- [ ] Power strips / extension cables
- [ ] Printed Student Workbooks
- [ ] Printed Student Notes
- [ ] Printed Quiz/Test Bank
- [ ] USB sticks with sample data (backup)
- [ ] Internet access for SQLCipher install (if needed)

### Sample Data Files
- `customers.csv`, `orders.csv` – for CRUD labs
- `employees.csv` – for self‑join demo
- `products.json` – for JSON labs
- `blog_posts.csv` – for FTS5 labs

---

## Part 11: Course Evaluation Template

**Student Feedback Form**

| Question | Rating (1‑5) | Comments |
|----------|--------------|----------|
| Clarity of instruction | | |
| Quality of lab materials | | |
| Pacing of course | | |
| Relevance to my work | | |
| Overall satisfaction | | |

**Open‑Ended:**
1. What was the most valuable part of this course?
2. What was the least valuable?
3. What topics need more depth?
4. What topics need less depth?
5. Any additional feedback?

---

## Part 12: Final Trainer Notes

- **Be enthusiastic** – Your energy sets the tone for the entire course.
- **Be patient** – Everyone learns at a different pace; encourage questions.
- **Be practical** – Relate every concept to a real‑world use case.
- **Be available** – Students will have questions long after the course ends; create a community.
- **Keep learning** – SQLite evolves; review the release notes before each course.

---

**Thank you for delivering the Master SQLite course. Your students will leave with skills that will serve them for years.**

---

*End of Trainer Guide*
