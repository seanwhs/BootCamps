# SQLite Primer 1: Getting Started with SQLite

Welcome to the **SQLite Primer**—the fastest way to get up and running with the world's most widely deployed database. This guide assumes you know nothing about databases; we'll start from absolute zero and have you creating tables and running queries within minutes.

---

## What Is SQLite?

**SQLite** is a lightweight, serverless, self‑contained relational database engine. Unlike traditional databases (like PostgreSQL or MySQL), SQLite does not run as a separate process that your application talks to over a network. Instead, it's a **C library** that your application links directly, and it stores everything in a **single ordinary disk file**.

Think of it as a **digital filing cabinet** that lives right inside your app. You don't need to install a server, create a user account, or configure network ports. You just open a file, write some SQL, and you're done.

### Why Use SQLite?

- **Zero setup** – No installation, no configuration, no admin.
- **Portable** – A database is just a file; you can copy, move, or email it.
- **Reliable** – ACID compliant and crash‑resistant.
- **Fast** – Extremely fast for most workloads, especially when tuned.
- **Everywhere** – It's the default database on Android, iOS, macOS, and many browsers.

---

## Installation

SQLite comes pre‑installed on macOS and most Linux distributions. On Windows, you need to download a single executable.

### On Linux (Debian/Ubuntu)
```bash
sudo apt update
sudo apt install sqlite3
```

### On macOS (with Homebrew)
```bash
brew install sqlite
```

### On Windows
1. Go to https://www.sqlite.org/download.html
2. Download the **sqlite‑tools‑win32‑*.zip** (or 64‑bit) package.
3. Unzip and place `sqlite3.exe` in a folder (e.g., `C:\sqlite`).
4. Add that folder to your `PATH`.

### Verify Installation
```bash
sqlite3 --version
```
You should see a version number (e.g., `3.42.0`).

---

## Your First Database

A SQLite database is simply a file. To create one, open a terminal and run:

```bash
sqlite3 myfirst.db
```

This opens the interactive shell. You'll see a prompt like:
```
SQLite version 3.42.0
Enter ".help" for usage hints.
sqlite>
```

Now, create a table and insert a row:

```sql
CREATE TABLE greetings (message TEXT);
INSERT INTO greetings (message) VALUES ('Hello, world!');
SELECT * FROM greetings;
```

You should see:
```
Hello, world!
```

Exit the shell:
```sql
.exit
```

You now have a file named `myfirst.db` that contains your database.

---

## Running SQL Without the Interactive Shell

You can run a single SQL statement directly from the command line:

```bash
sqlite3 myfirst.db "SELECT * FROM greetings;"
```

Or run a script file:
```bash
sqlite3 myfirst.db < myscript.sql
```

---

## Essential SQL Commands (CRUD)

### CREATE TABLE
Define the structure of your data.
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    age INTEGER,
    created_at TEXT DEFAULT (datetime('now'))
);
```

### INSERT
Add new rows.
```sql
INSERT INTO users (name, email, age) VALUES ('Alice', 'alice@example.com', 30);
```

You can insert multiple rows at once:
```sql
INSERT INTO users (name, email, age) VALUES
    ('Bob', 'bob@example.com', 25),
    ('Carol', 'carol@example.com', 28);
```

### SELECT
Retrieve data.
```sql
-- All columns
SELECT * FROM users;

-- Specific columns
SELECT name, email FROM users;

-- With sorting
SELECT * FROM users ORDER BY age DESC;

-- Limit results
SELECT * FROM users LIMIT 2;

-- With a condition
SELECT * FROM users WHERE age > 27;
```

### UPDATE
Modify existing rows.
```sql
UPDATE users SET age = 31 WHERE name = 'Alice';
```
**Warning:** Always include a `WHERE` clause; otherwise you'll update every row.

### DELETE
Remove rows.
```sql
DELETE FROM users WHERE name = 'Bob';
```

---

## Filtering and Sorting (A Quick Overview)

### The WHERE Clause
```sql
SELECT * FROM users WHERE age BETWEEN 25 AND 30;
SELECT * FROM users WHERE email LIKE '%gmail%';
SELECT * FROM users WHERE age IN (25, 28, 31);
```

### ORDER BY
```sql
SELECT * FROM users ORDER BY name ASC, age DESC;
```

### DISTINCT
Remove duplicates.
```sql
SELECT DISTINCT age FROM users;
```

---

## Working with Multiple Tables (JOINs)

Often your data lives in separate tables. For example, a `posts` table that references a `users` table via a `user_id`.

```sql
CREATE TABLE posts (
    post_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO posts (title, content, user_id) VALUES
    ('First Post', 'Hello everyone!', 1),
    ('Second Post', 'SQLite is great.', 1);
```

Now, retrieve posts with the author's name using an **INNER JOIN**:
```sql
SELECT posts.title, users.name
FROM posts
JOIN users ON posts.user_id = users.id;
```

---

## Indexes (Speed Up Your Queries)

If you frequently filter by a column, create an **index**. It's like an alphabetical index at the back of a book.

```sql
CREATE INDEX idx_users_email ON users(email);
```

Now queries like `WHERE email = '...'` will be much faster.

---

## Transactions (Grouping Changes)

Transactions let you group multiple SQL statements so they succeed or fail together. This is essential for data consistency.

```sql
BEGIN;
UPDATE users SET age = 32 WHERE name = 'Alice';
UPDATE users SET age = 26 WHERE name = 'Carol';
COMMIT;   -- or ROLLBACK to cancel
```

---

## Backup Your Database

You can make a copy of the database file while it's in use:

```bash
sqlite3 myfirst.db ".backup backup.db"
```

Or inside the shell:
```sql
.backup backup.db
```

---

## Essential PRAGMA Settings

PRAGMAs control SQLite's behavior. For a new project, start with these:

```sql
PRAGMA journal_mode = WAL;          -- Better concurrency
PRAGMA synchronous = NORMAL;        -- Good balance of safety and speed
PRAGMA foreign_keys = ON;           -- Enforce referential integrity
PRAGMA busy_timeout = 5000;         -- Wait 5 seconds if database is locked
```

---

## Next Steps

You now have the absolute basics. To go deeper, explore the **Master SQLite** series, which covers:

- Advanced SQL (window functions, CTEs, recursive queries)
- Database design and normalization
- Performance tuning (EXPLAIN QUERY PLAN, covering indexes)
- Transactions and concurrency (WAL, locking)
- JSON and full‑text search (FTS5)
- Programming with SQLite (Python, web, mobile)
- Security (encryption, SQL injection)
- Production deployment and maintenance

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Open a database | `sqlite3 mydb.db` |
| Show tables | `.tables` |
| Show schema | `.schema tablename` |
| Exit shell | `.exit` |
| Run SQL | `sqlite3 mydb.db "SELECT * FROM users"` |
| Backup | `.backup backup.db` |
| Import CSV | `.mode csv; .import data.csv mytable` |
| Export CSV | `.mode csv; .output out.csv; SELECT * FROM mytable;` |
| Enable WAL | `PRAGMA journal_mode = WAL;` |
| Check integrity | `PRAGMA integrity_check;` |

---

**This primer gives you the 20% of SQLite that you'll use 80% of the time.** Now open your terminal, create a database, and start experimenting. The best way to learn is by doing. Happy coding!
