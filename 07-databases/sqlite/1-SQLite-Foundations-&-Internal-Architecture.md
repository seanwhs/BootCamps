# Part 1: SQLite Foundations & Internal Architecture

Welcome to the first technical phase of our journey. In Part 0, we set the stage. Now we roll up our sleeves and get our hands dirty. This part is the bedrock of everything that follows—if you understand how SQLite *works* internally, every optimisation, transaction, and indexing decision will feel intuitive rather than magical.

**Part 1** is divided into four modules. We will cover them in sequence:

- **Module 1:** Introduction to SQLite – installation, first database, and tooling.
- **Module 2:** SQLite Architecture – the engine internals, B‑Tree, and execution pipeline.
- **Module 3:** Data Types & Storage – dynamic typing, storage classes, and `ROWID` vs. `WITHOUT ROWID`.
- **Module 4:** Creating and Managing Tables – schema definition, constraints, and generated columns.

Let’s begin.

---

## Module 1: Introduction to SQLite

### The Target

By the end of this module, you will have SQLite installed on your machine, you will have created your first database file, and you will be comfortable using both the command‑line shell and a graphical browser to interact with it.

### The Concept

Think of SQLite as a **digital filing cabinet** that lives right inside your application. Instead of having a separate database server (a “librarian”) that you must ask for data over a network, SQLite is more like a **notebook** that your application holds in its own hands. Your app reads and writes to that notebook directly, with no middleman.

This “serverless” design has profound implications:
- **Zero configuration** – no user accounts, no network ports, no startup scripts.
- **Single file** – the entire database (tables, indexes, schema) is stored in one ordinary file on your disk. You can copy, move, or email that file.
- **Self‑contained** – the SQLite library is about 600KB; it includes everything.

Because it lives in‑process, SQLite is incredibly fast for local operations—often faster than talking to a remote database over a network. However, it’s not designed for very high‑write concurrency from many simultaneous writers (though we will address that with WAL mode later).

### Hands‑on Lab 1.1: Installing SQLite

We will install the SQLite command‑line shell (CLI) and the GUI tool.

#### 1.1.1 Installation on Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install sqlite3 sqlite3-doc
```

#### 1.1.2 Installation on macOS (using Homebrew)

```bash
brew install sqlite
```

#### 1.1.3 Installation on Windows

Download the precompiled binaries from the official SQLite website:
- Go to https://www.sqlite.org/download.html
- Download the **sqlite‑tools‑win32‑*.zip** (or 64‑bit) package.
- Unzip and place `sqlite3.exe` in a folder (e.g., `C:\sqlite`).
- Add that folder to your `PATH` environment variable.

#### 1.1.4 Verify the Installation

Open a terminal and run:

```bash
sqlite3 --version
```

You should see output like:

```
3.42.0 2023-05-16 12:36:15 ...
```

If you see a version number, you are ready.

#### 1.1.5 Install DB Browser for SQLite (GUI)

This is optional but highly recommended for visual exploration.

- Download from https://sqlitebrowser.org/
- Install the version for your operating system.

**Verification Step:** Run `sqlite3 --version` and confirm no errors. Launch DB Browser to ensure it opens.

---

### Hands‑on Lab 1.2: Creating Your First Database

#### The Target
Create a database file named `first.db` and verify that SQLite can open it.

#### The Concept
A SQLite database is simply a **file**. You do not need to explicitly create it; when you open a connection to a file that does not exist, SQLite creates it for you (unless you use the special `:memory:` mode, which we will see later).

#### Implementation

Open your terminal and navigate to a directory where you want to keep your projects (e.g., `~/sqlite_series`). Then run:

```bash
# Create the directory if needed
mkdir -p ~/sqlite_series
cd ~/sqlite_series

# Start the SQLite CLI and attach to a new database file
sqlite3 first.db
```

You will see a prompt that looks like:

```
SQLite version 3.42.0 2023-05-16 12:36:15
Enter ".help" for usage hints.
sqlite>
```

Now that you are inside the CLI, run a command to verify the database is ready:

```sql
-- Display the current database file path
.databases
```

You should see:

```
main: /home/yourname/sqlite_series/first.db
```

Next, create a simple table and insert a row to prove we are working with a persistent file:

```sql
CREATE TABLE greetings (message TEXT);
INSERT INTO greetings (message) VALUES ('Hello, SQLite!');
SELECT * FROM greetings;
```

You should see:

```
Hello, SQLite!
```

Now exit the CLI:

```sql
.exit
```

If you list the directory, you will see a file named `first.db`. This file contains everything we just did.

```bash
ls -l first.db
```

#### Verification

Run the following command to query the database without entering the interactive shell:

```bash
sqlite3 first.db "SELECT * FROM greetings;"
```

Expected output:

```
Hello, SQLite!
```

**Congratulations!** You have created your first SQLite database.

---

### Hands‑on Lab 1.3: Using DB Browser for SQLite

#### The Target
Open the `first.db` file in the GUI to visually inspect the schema and data.

#### The Concept
Sometimes it’s easier to understand database structure when you can see tables, columns, and indexes laid out graphically. DB Browser provides a spreadsheet‑like view and an “Execute SQL” tab for running queries.

#### Implementation

1. Launch DB Browser for SQLite.
2. Click **“Open Database”** and navigate to `~/sqlite_series/first.db`.
3. You should see the `greetings` table listed in the “Database Structure” tab.
4. Click on the **“Browse Data”** tab. You will see your single row.
5. Switch to the **“Execute SQL”** tab and type:

```sql
SELECT message, length(message) AS len FROM greetings;
```

6. Click the play button (▶) to run it. The result shows `Hello, SQLite!` and its length.

#### Verification
Take a screenshot or note that the GUI reflects exactly what you created in the CLI. This confirms that both tools interact with the same underlying file.

---

### Deep Dive: The Database File Structure (Conceptual)

Before we move on, let’s peek under the hood. When you create a SQLite database file, SQLite writes a **header** at the very beginning of the file (first 100 bytes). This header contains:
- The magic string: `SQLite format 3\000`
- The page size (usually 4096 bytes)
- The file format version
- The number of pages used, etc.

The rest of the file is divided into **pages**. Each page is a fixed‑size block (default 4096 bytes). Pages are organised into a **B‑Tree** (balanced tree) for tables and indexes. We will dissect this in Module 2.

For now, know that everything—tables, indexes, triggers, views—is stored in this single file, making it extremely portable. You can back it up by simply copying the file.

---

### Reference: SQLite CLI Essential Commands

Here is a quick cheat sheet of the most useful “dot‑commands” (commands that start with a dot) inside the SQLite shell:

| Command | Description |
|---------|-------------|
| `.databases` | List attached databases and their file paths. |
| `.tables` | Show all tables in the current database. |
| `.schema [table]` | Show the `CREATE` statement for a table (or all tables). |
| `.dump [table]` | Output SQL statements to recreate the table and its data. |
| `.headers on` | Show column headers in query output. |
| `.mode column` | Display results in a column‑aligned table. |
| `.exit` or `.quit` | Exit the shell. |

Try them now:

```bash
sqlite3 first.db
.headers on
.mode column
SELECT * FROM greetings;
.tables
.schema greetings
```

You will see a nicely formatted output and the exact `CREATE TABLE` statement.

---

**[GENERATED: Part 1, Module 1: Introduction to SQLite]**

---

## Module 2: SQLite Architecture

Now that you have a working SQLite installation and have created your first database, it is time to understand the machinery inside the engine. This module demystifies the internal components that turn your SQL statements into disk operations.

### The Target

Understand the process‑local architecture of SQLite, the role of the B‑Tree, the page cache, the Virtual Database Engine (VDBE), and the locking/journaling subsystems. By the end, you will be able to explain what happens when you run a `SELECT` query, from typing it to seeing results.

### The Concept

Imagine SQLite as a **restaurant kitchen**. Your SQL query is the order ticket. The **Parser** is the waiter who reads the ticket. The **Code Generator** is the chef who translates the order into a recipe. The **VDBE** (Virtual Database Engine) is the cook who executes each step of the recipe. The **B‑Tree** and **Pager** are the pantry and refrigerator—they store and retrieve ingredients (data pages). The **OS Interface** is the delivery boy who physically brings ingredients from the storage room (disk) to the kitchen.

This layered design makes SQLite robust and fast.

### Engine Internals: The Big Picture

Let’s walk through a simple query: `SELECT name FROM users WHERE id = 42;`

1. **SQL Parser** – The text of your query is tokenised and parsed into an abstract syntax tree (AST). It checks syntax and builds a parse tree.
2. **Code Generator** – The parse tree is transformed into a **bytecode** program for the VDBE. This bytecode is a set of low‑level operations (like `OpenRead`, `Column`, `ResultRow`).
3. **VDBE (Virtual Database Engine)** – This is the heart of SQLite. It executes the bytecode instructions one by one. Each instruction manipulates the **B‑Tree** or the **page cache**.
4. **B‑Tree** – This manages the database file as a collection of pages. It provides ordered storage and efficient key‑based lookups. The `users` table is stored in a B‑Tree structure.
5. **Pager** – This subsystem handles reading and writing pages to disk. It manages the page cache (LRU), transaction control, and journaling for crash recovery.
6. **OS Interface** – The platform‑specific layer that does the actual file I/O, locking, and memory mapping.

All of this runs inside your application’s process—there is no separate server process.

### Hands‑on Lab 2.1: Seeing the VDBE Bytecode

We can use the `EXPLAIN` command to show the bytecode program that SQLite generates for any SQL statement.

#### Implementation

In your terminal, open `first.db`:

```bash
sqlite3 first.db
```

Now run:

```sql
EXPLAIN SELECT message FROM greetings;
```

You will see a table with columns `addr`, `opcode`, `p1`, `p2`, `p3`, `p4`, and `p5`. This is the raw VDBE program. Don’t worry about the details yet—just notice that your simple `SELECT` is transformed into about a dozen instructions.

For a human‑readable version, use:

```sql
EXPLAIN QUERY PLAN SELECT message FROM greetings;
```

This shows the *strategy* the query planner uses (e.g., scanning the table).

#### Verification

You should see output like:

```
QUERY PLAN
`--SCAN greetings
```

This tells us that SQLite will perform a full table scan (since we have no index yet). We will fix that in Part 4.

---

### The B‑Tree Storage Engine

The B‑Tree is the fundamental data structure behind SQLite tables and indexes. Think of it as a **multi‑level filing system**:

- The root page contains pointers to child pages.
- Each child page contains a sorted list of keys (and values).
- Searching for a key takes O(log N) disk operations because the tree is balanced.

SQLite uses two variants:
- **B‑Tree** – for tables and indexes.
- **B+‑Tree** – for indexes that point to the row (but SQLite’s implementation is a hybrid).

For now, know that every table you create is stored as a B‑Tree, and every index is a separate B‑Tree that maps key values to row IDs.

### Hands‑on Lab 2.2: Exploring Database Internals

We can inspect the page layout using the `DB Browser for SQLite` and the `.dbinfo` command.

#### Implementation

Open `first.db` in DB Browser. Click on **“Database Structure”** – you will see the `greetings` table. Right‑click and select **“Show DB Info”** (or similar, depending on version). You will see the database page size and number of pages.

Alternatively, in the CLI:

```bash
sqlite3 first.db ".dbinfo"
```

This prints:

```
database page size:  4096
write format:        1
read format:         1
...
number of tables:    2
```

#### Verification

You should see a page size of 4096 and a small number of total pages. This confirms that the database file is divided into pages.

---

### Reliability & Concurrency: Locking and Journaling Overview

SQLite provides **ACID** (Atomicity, Consistency, Isolation, Durability) transactions. How does it do that with a single file?

- **Locking** – SQLite uses a five‑state locking protocol: UNLOCKED, SHARED, RESERVED, PENDING, and EXCLUSIVE.
  - Multiple readers can hold a SHARED lock simultaneously.
  - Only one writer can hold an EXCLUSIVE lock at a time.

- **Journaling** – Before a writer modifies a page, it writes the original content to a **rollback journal** (or to the WAL file if using WAL mode). If the system crashes, the journal is used to restore the database to a consistent state.

We will dive deep into transactions and WAL in Part 5. For now, understand that this design ensures that even if your application crashes in the middle of an update, the database will not become corrupt.

### Hands‑on Lab 2.3: Viewing the Locking State

In the CLI, you can use the `PRAGMA` statement to check the current locking state. Open two terminal windows:

- **Terminal 1**: Start a read transaction with `BEGIN; SELECT * FROM greetings;` (do not commit).
- **Terminal 2**: Try to write to the table.

In Terminal 1:

```sql
BEGIN;
SELECT * FROM greetings;
```

In Terminal 2:

```bash
sqlite3 first.db
UPDATE greetings SET message = 'Hello again' WHERE message = 'Hello, SQLite!';
```

Notice that Terminal 2 waits because Terminal 1 holds a SHARED lock. If you commit in Terminal 1 (`COMMIT;`), Terminal 2’s update proceeds.

#### Verification

Run `PRAGMA locking_mode;` in either terminal (default is NORMAL). This shows the locking behaviour. We will use this later for tuning.

---

**[GENERATED: Part 1, Module 2: SQLite Architecture]**

---

## Module 3: Data Types & Storage

SQLite has a famously flexible typing system. Unlike strict databases that enforce column types, SQLite uses **dynamic typing** and **type affinity**. This module explains the storage classes, affinities, and how to use them to your advantage.

### The Target

By the end of this module, you will know the five storage classes, understand type affinity, and be able to design columns that store what you intend. You will also understand the difference between `ROWID` and `WITHOUT ROWID` tables.

### The Concept

Think of a SQLite column like a **labelled drawer** in a workshop. The label says “Screws” (the column type), but you can put nails, bolts, or even marshmallows in it—SQLite won’t stop you. However, it will try to *interpret* what you put in based on the label. This is **type affinity**.

- **Storage Classes** – These are the actual formats used to store data on disk: `NULL`, `INTEGER`, `REAL`, `TEXT`, and `BLOB`.
- **Type Affinity** – A column’s recommended type. It influences how values are converted when inserted, but does not enforce the type.

### Storage Classes Explained

| Class | Description |
|-------|-------------|
| **NULL** | A missing value. Takes 0 bytes (other than the record header). |
| **INTEGER** | A signed integer, stored in 1, 2, 3, 4, 6, or 8 bytes depending on magnitude. |
| **REAL** | A floating‑point number (8‑byte IEEE 754). |
| **TEXT** | A string, stored using UTF‑8, UTF‑16BE, or UTF‑16LE. |
| **BLOB** | Binary Large Object – raw bytes, stored exactly as provided. |

### Type Affinity

When you define a column as `INTEGER`, `TEXT`, etc., SQLite assigns an **affinity**. The rules are:

- If the declared type contains `INT` → `INTEGER` affinity.
- If it contains `CHAR`, `CLOB`, or `TEXT` → `TEXT` affinity.
- If it contains `BLOB` → `BLOB` affinity.
- If it contains `REAL`, `FLOA`, or `DOUB` → `REAL` affinity.
- Otherwise → `NUMERIC` affinity.

Affinity determines how values are *converted* when inserted (e.g., inserting `'123'` into an INTEGER column will store it as `123`). But you can still insert `'hello'` into an INTEGER column; it will be stored as TEXT.

### Hands‑on Lab 3.1: Type Affinity Experiments

#### Implementation

Create a new database `types.db` to play with:

```bash
sqlite3 types.db
```

Create a table with different affinities:

```sql
CREATE TABLE test (
    id INTEGER PRIMARY KEY,
    a_int INTEGER,
    a_text TEXT,
    a_real REAL,
    a_blob BLOB,
    a_numeric NUMERIC
);
```

Now insert some values that “break” the affinities:

```sql
INSERT INTO test (a_int, a_text, a_real, a_blob, a_numeric)
VALUES ('123', 456, '78.9', 'binary data', '99.9');
```

Now query the table:

```sql
SELECT * FROM test;
```

Notice that:
- `a_int` stored `'123'` as an integer `123` (because affinity converted it).
- `a_text` stored `456` as the string `'456'`.
- `a_real` stored `'78.9'` as a real number `78.9`.
- `a_blob` stored `'binary data'` as a BLOB (no conversion).
- `a_numeric` stored `'99.9'` as a numeric type (likely REAL).

Now, let’s try inserting a text into an integer column:

```sql
INSERT INTO test (a_int) VALUES ('hello');
```

Query again:

```sql
SELECT a_int, typeof(a_int) FROM test;
```

You will see that `typeof(a_int)` returns `text` for the second row. This proves that affinity does not enforce types—it only *prefers* them.

#### Verification

Run:

```sql
SELECT id, a_int, typeof(a_int), a_text, typeof(a_text) FROM test;
```

You should see a mix of integer and text types in the `a_int` column. This verifies dynamic typing.

---

### Boolean and Date Handling

SQLite does not have native Boolean or date/time types. Instead:

- **Booleans** – Store as `INTEGER` with 0 (false) and 1 (true). You can use `CHECK` constraints to enforce.
- **Dates** – Store as `TEXT` (ISO8601 strings: `'2025-01-15 14:30:00'`), `INTEGER` (Unix epoch seconds), or `REAL` (Julian day numbers). Use the built‑in date functions to manipulate them.

Example:

```sql
CREATE TABLE events (
    id INTEGER PRIMARY KEY,
    name TEXT,
    is_active INTEGER CHECK (is_active IN (0,1)),
    created_at TEXT DEFAULT (datetime('now', 'localtime'))
);

INSERT INTO events (name, is_active) VALUES ('Meeting', 1);
SELECT * FROM events;
```

#### Verification

Run `SELECT datetime('now');` to see the current timestamp in ISO format.

---

### ROWID Tables vs. WITHOUT ROWID Tables

Every table in SQLite has a **ROWID** – a 64‑bit signed integer that uniquely identifies a row. When you create a table with `INTEGER PRIMARY KEY`, that column becomes an alias for `ROWID`. This is very efficient because the B‑Tree uses the ROWID as the key.

However, if you want a table that uses a different primary key as the B‑Tree key (to avoid an extra index), you can declare `WITHOUT ROWID`. This is useful for tables where the primary key is not an integer or when you want to cluster data by a natural key.

**Example:**

```sql
-- ROWID table (default)
CREATE TABLE users (
    id INTEGER PRIMARY KEY,  -- alias for ROWID
    name TEXT
);

-- WITHOUT ROWID table
CREATE TABLE products (
    sku TEXT PRIMARY KEY,    -- B-Tree key is the SKU
    description TEXT
) WITHOUT ROWID;
```

#### Hands‑on Lab 3.2: Comparing ROWID and WITHOUT ROWID

Create both tables and insert 1000 rows. Then compare the database size using `.dbinfo` or `ls -l`.

```sql
-- Insert into users
INSERT INTO users (name) SELECT 'user' || generate_series FROM generate_series(1,1000);

-- Insert into products
INSERT INTO products (sku, description) 
SELECT 'SKU-' || printf('%04d', generate_series), 'Product ' || generate_series 
FROM generate_series(1,1000);
```

Then check the file size:

```bash
ls -l types.db
```

You will notice that the `WITHOUT ROWID` table may be slightly larger because it stores the primary key with each row, but it avoids an extra index lookup when querying by SKU.

#### Verification

Run:

```sql
SELECT rowid, id FROM users LIMIT 1;
```

You will see that `rowid` and `id` are identical. For `products`, `rowid` is not available.

---

**[GENERATED: Part 1, Module 3: Data Types & Storage]**

---

## Module 4: Creating and Managing Tables

Now that we understand types and storage, we can build robust schemas. This module covers `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`, and all constraint types. We also introduce generated columns.

### The Target

By the end of this module, you will be able to design a normalized relational schema with primary keys, foreign keys, unique constraints, check constraints, and generated columns.

### The Concept

A **table** is like a **spreadsheet** – rows are records, columns are attributes. But a database table is smarter: it has rules (constraints) that keep data clean. Constraints are like the **bouncers** at a club – they ensure only valid data gets in.

- **PRIMARY KEY** – Uniquely identifies each row.
- **FOREIGN KEY** – Links to a primary key in another table (referential integrity).
- **UNIQUE** – No duplicate values in this column (or set of columns).
- **CHECK** – A custom condition that each row must satisfy.
- **DEFAULT** – A value inserted automatically if you don’t provide one.
- **GENERATED COLUMN** – A column whose value is computed from other columns.

### Hands‑on Lab 4.1: Designing a Simple Relational Schema

We will create a small library database with three tables: `authors`, `books`, and `book_authors` (many‑to‑many).

#### Implementation

Create a new database:

```bash
sqlite3 library.db
```

Now, write the schema. We will use `PRAGMA foreign_keys = ON;` to enforce referential integrity (off by default for backward compatibility).

```sql
-- Enable foreign key enforcement
PRAGMA foreign_keys = ON;

-- Authors table
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_year INTEGER CHECK (birth_year > 1000 AND birth_year <= strftime('%Y', 'now')),
    UNIQUE (first_name, last_name)  -- no two authors with same full name
);

-- Books table
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    isbn TEXT UNIQUE NOT NULL,  -- ISBN must be unique
    publication_year INTEGER CHECK (publication_year BETWEEN 1450 AND strftime('%Y', 'now')),
    genre TEXT DEFAULT 'Unknown',
    -- A generated column: full title with year
    full_title TEXT GENERATED ALWAYS AS (title || ' (' || publication_year || ')') STORED
);

-- Junction table for many‑to‑many relationship
CREATE TABLE book_authors (
    book_id INTEGER NOT NULL,
    author_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Create an index on the foreign key columns for performance (we'll cover indexes in Part 4)
CREATE INDEX idx_book_authors_author ON book_authors(author_id);
```

#### Verification

Insert some data to test constraints:

```sql
-- Insert authors
INSERT INTO authors (first_name, last_name, birth_year) VALUES ('George', 'Orwell', 1903);
INSERT INTO authors (first_name, last_name, birth_year) VALUES ('Aldous', 'Huxley', 1894);

-- Insert books
INSERT INTO books (title, isbn, publication_year, genre) 
VALUES ('1984', '978-0-452-28423-4', 1949, 'Dystopian');

INSERT INTO books (title, isbn, publication_year, genre) 
VALUES ('Brave New World', '978-0-06-085052-4', 1932, 'Science Fiction');

-- Link authors to books
INSERT INTO book_authors (book_id, author_id) VALUES (1, 1);  -- 1984 by Orwell
INSERT INTO book_authors (book_id, author_id) VALUES (2, 2);  -- Brave New World by Huxley
```

Now test constraints:

```sql
-- This should fail: duplicate ISBN
INSERT INTO books (title, isbn, publication_year) VALUES ('Animal Farm', '978-0-452-28423-4', 1945);
-- Error: UNIQUE constraint failed: books.isbn

-- This should fail: birth_year > 1000
INSERT INTO authors (first_name, last_name, birth_year) VALUES ('Jane', 'Austen', 775);
-- Error: CHECK constraint failed: authors

-- This should succeed because we used ON DELETE CASCADE
DELETE FROM authors WHERE author_id = 1;
-- Now check book_authors: the row with book_id=1, author_id=1 should be gone
SELECT * FROM book_authors;
```

#### Verification

Run:

```sql
-- Check the generated column
SELECT book_id, title, full_title FROM books;
```

You should see:

```
1|1984|1984 (1949)
2|Brave New World|Brave New World (1932)
```

This confirms the generated column works.

---

### ALTER TABLE Operations

SQLite supports a limited set of `ALTER TABLE` operations:
- Rename table: `ALTER TABLE old_name RENAME TO new_name;`
- Rename column: `ALTER TABLE table_name RENAME COLUMN old_col TO new_col;` (as of SQLite 3.25+)
- Add column: `ALTER TABLE table_name ADD COLUMN col_name type constraints;` (with restrictions – you cannot add a column with `PRIMARY KEY` or `UNIQUE` unless it has a `DEFAULT` and is `NOT NULL`).

**Hands‑on:**

```sql
-- Add a new column with a default value
ALTER TABLE books ADD COLUMN pages INTEGER DEFAULT 0;

-- Rename a column
ALTER TABLE books RENAME COLUMN genre TO category;

-- Verify
PRAGMA table_info(books);
```

---

### DROP TABLE

Simply:

```sql
DROP TABLE book_authors;  -- but be careful with foreign keys
```

---

### Advanced: Generated Columns

We already used a `STORED` generated column. There is also `VIRTUAL` – computed on the fly (not stored on disk). `STORED` takes disk space but can be indexed; `VIRTUAL` saves space but costs CPU on every query.

**Example:**

```sql
CREATE TABLE sales (
    id INTEGER PRIMARY KEY,
    quantity INTEGER,
    price REAL,
    total REAL GENERATED ALWAYS AS (quantity * price) VIRTUAL
);

INSERT INTO sales (quantity, price) VALUES (3, 19.99);
SELECT * FROM sales;  -- total shows 59.97 automatically
```

---

### Schema Inspection Commands

To inspect the structure of your tables:

```sql
-- Show all tables
.tables

-- Show the CREATE statement for a specific table
.schema books

-- Show column information
PRAGMA table_info(books);

-- Show foreign key references
PRAGMA foreign_key_list(book_authors);

-- Show all indexes
.indexes
```

---

### Reference: Constraint Types Summary

| Constraint | Purpose | Example |
|------------|---------|---------|
| `PRIMARY KEY` | Unique row identifier; implies `UNIQUE` and `NOT NULL`. | `id INTEGER PRIMARY KEY` |
| `FOREIGN KEY` | References a key in another table. | `FOREIGN KEY (author_id) REFERENCES authors(author_id)` |
| `UNIQUE` | Ensures all values in a column (or group) are distinct. | `email TEXT UNIQUE` |
| `CHECK` | Enforces a Boolean condition. | `CHECK (age >= 18)` |
| `DEFAULT` | Provides a value when none is supplied. | `created_at TEXT DEFAULT (datetime('now'))` |
| `NOT NULL` | Prevents `NULL` values. | `name TEXT NOT NULL` |
| `AUTOINCREMENT` | Ensures `ROWID` strictly increases (for `INTEGER PRIMARY KEY`). | `id INTEGER PRIMARY KEY AUTOINCREMENT` – adds a separate `sqlite_sequence` table to track. |

---

### Final Verification for Part 1

Let's run a comprehensive check that all our modules work together.

Open the `library.db` database and run:

```sql
-- Show schema
.schema

-- Show all data with joins
SELECT 
    b.title,
    b.publication_year,
    b.full_title,
    a.first_name || ' ' || a.last_name AS author_name
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id;

-- Check database integrity
PRAGMA integrity_check;
```

Expected output of `PRAGMA integrity_check;` is `ok`. This verifies that all constraints and data are consistent.

## End of Part 1

You have now completed the first major part of the series. You have:

- Installed SQLite and its tools.
- Created persistent databases and queried them.
- Understood the internal architecture (parser, VDBE, B‑Tree, pager).
- Explored dynamic typing and type affinity.
- Designed normalized schemas with primary, foreign, unique, check, and generated columns.
- Used `ALTER TABLE` and `DROP TABLE`.

This foundation prepares you for **Part 2: SQL Programming Essentials**, where we will write complex queries, joins, aggregations, and window functions.
