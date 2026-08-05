Welcome to Part 5. You now understand how to make queries fast. But speed means nothing if data is inconsistent or lost. This part is about **reliability**—ensuring that your database remains correct, even in the face of concurrent users, system crashes, or power failures. We will dissect ACID transactions, the two journaling modes (rollback and WAL), locking behavior, and recovery strategies. By the end, you will be able to build applications that are both high‑performance and bulletproof.

**Part 5** is divided into three modules:

- **Module 14:** ACID Transactions – `BEGIN`, `COMMIT`, `ROLLBACK`, savepoints, and atomic commits.
- **Module 15:** Journaling & WAL – Rollback journal vs. Write‑Ahead Logging, checkpoints, and tuning.
- **Module 16:** Reliability & Recovery – Corruption detection, integrity checks, and recovery strategies.

Let’s begin.

---

# Part 5: Transactions & Concurrency

## Module 14: ACID Transactions

### The Target

Understand the four properties of transactions (Atomicity, Consistency, Isolation, Durability). Learn how to use `BEGIN`, `COMMIT`, `ROLLBACK`, and `SAVEPOINT` to group SQL statements into logical units of work. Implement nested transactions and see how SQLite handles them.

### The Concept

Imagine you are transferring money from your checking account to your savings account. This involves two steps:
1. Subtract $100 from checking.
2. Add $100 to savings.

If the system crashes after step 1 but before step 2, you have lost $100. You need **atomicity**: either both steps happen, or neither does.

A **transaction** is a group of SQL statements that must succeed or fail as a single unit. SQLite provides full ACID guarantees:

- **Atomicity** – All changes in the transaction are applied or none.
- **Consistency** – The database remains in a valid state (constraints are enforced).
- **Isolation** – Transactions do not interfere with each other (serializable by default).
- **Durability** – Once committed, changes survive a crash.

SQLite implements transactions using a **rollback journal** or **write‑ahead log** (WAL). We'll cover both in Module 15.

### Hands‑on Lab 14.1: Basic Transactions

We'll create a simple `accounts` table for the money transfer scenario.

```bash
sqlite3 trans.db
```

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    owner TEXT NOT NULL,
    balance REAL NOT NULL CHECK (balance >= 0)
);

INSERT INTO accounts (owner, balance) VALUES ('Alice', 1000.00), ('Bob', 500.00);
```

Now, execute a transfer from Alice to Bob ($100). Without a transaction, we might have a partial update.

```sql
-- Start a transaction
BEGIN TRANSACTION;

-- Deduct from Alice
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;

-- Add to Bob
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;

-- Check that balances are correct before committing
SELECT * FROM accounts;

-- If everything looks good, commit
COMMIT;
```

If you want to abort, use `ROLLBACK` instead of `COMMIT`.

```sql
BEGIN;
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1; -- would violate CHECK
ROLLBACK; -- all changes undone
```

#### Verification

After commit, query `SELECT * FROM accounts;` – Alice should have 900, Bob 600. If you rolled back, no changes occurred.

### Savepoints (Nested Transactions)

SQLite does not support true nested transactions, but you can use **savepoints** to create partial rollback points.

```sql
BEGIN;

-- Do some work
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;

-- Set a savepoint
SAVEPOINT sp1;

-- Do more work (maybe risky)
UPDATE accounts SET balance = balance - 200 WHERE account_id = 2;

-- Oops, we don't like that change; rollback to sp1
ROLLBACK TO sp1;

-- Now Bob's balance is unchanged, but Alice's +50 remains
-- Continue...

RELEASE sp1;  -- or ROLLBACK TO sp1; then RELEASE

COMMIT;
```

**Important:** Savepoints are not fully nested; they are like bookmarks. You can have multiple named savepoints.

#### Verification

Test by trying to rollback to a savepoint and confirm that only changes after the savepoint are undone.

---

### Atomic Commit and the Journal

When you issue `COMMIT`, SQLite performs an **atomic commit**:
1. It writes all changes to the journal (or WAL).
2. It ensures the journal is safely on disk (durability).
3. It then updates the database file.
4. It deletes the journal (or marks the WAL frame as committed).

This process ensures that if the system crashes during commit, the database can be recovered.

### Hands‑on Lab 14.2: Simulating a Crash

We can simulate a crash by killing the SQLite process in the middle of a transaction. While we can't easily do that from the CLI, we can observe the journal file.

Start a transaction that writes a lot of data, and while it's running, check the filesystem for a `-journal` file.

```sql
BEGIN;
-- Insert a million rows into a temp table
CREATE TEMP TABLE t AS SELECT * FROM generate_series(1, 1000000);
-- While this runs, in another terminal, check for the journal file: ls -l trans.db-journal
COMMIT;
```

You'll see that during the transaction, a journal file exists. After commit, it disappears. This is the rollback journal.

---

**[GENERATED: Part 5, Module 14: ACID Transactions]**

---

## Module 15: Journaling & WAL

### The Target

Understand the two transaction logging mechanisms in SQLite: the **rollback journal** and the **Write‑Ahead Log (WAL)**. Learn how to switch to WAL mode, tune checkpoints, and handle concurrency with `SQLITE_BUSY`.

### The Concept

SQLite ensures durability by writing changes to a separate log before modifying the main database. This log can be either:

- **Rollback Journal** – The default. Before modifying a page, SQLite writes the original page content to a `-journal` file. If a crash occurs, the journal is used to roll back to the state before the transaction.
- **Write‑Ahead Log (WAL)** – An alternative where changes are appended to a `-wal` file. The main database file is only updated during checkpoints. WAL offers better concurrency (readers and writers can coexist) and usually better performance for write‑heavy workloads.

### Rollback Journal

- **How it works:** When you start a transaction, SQLite creates a journal file. For each page modified, the original page is written to the journal. On commit, the journal is deleted (or zeroed). On rollback, the original pages are copied back from the journal.
- **Locking:** Writers hold an exclusive lock during commit.
- **Concurrency:** Readers can read during a write only if they started before the write lock was acquired (via shared locks). But writers block readers during commit.

### WAL Mode

- **How it works:** Changes are written to a separate `-wal` file as "frames". Each frame contains the modified page and a sequence number. Readers can read from both the main database and the WAL file (following a pointer). Writers append to the WAL without blocking readers.
- **Checkpoint:** Periodically, WAL frames are transferred to the main database file. This is a checkpoint. It can be automatic or manually triggered.
- **Locking:** Writers use a shared lock for most of the operation; only the final commit requires a short exclusive lock.
- **Concurrency:** Multiple readers and one writer can operate simultaneously. This is much more scalable.

### Enabling WAL Mode

```sql
PRAGMA journal_mode = WAL;
```

You can check the current mode:

```sql
PRAGMA journal_mode;
```

### WAL Tuning: Checkpoints

Checkpoints are crucial for performance. By default, SQLite does a checkpoint when the WAL file reaches 1000 pages. You can change this threshold:

```sql
PRAGMA wal_autocheckpoint = 500;  -- checkpoint when WAL has 500 pages
```

You can also manually checkpoint:

```sql
PRAGMA wal_checkpoint;
-- Or with options: PASSIVE (don't block), FULL, RESTART, TRUNCATE
```

### Concurrency and SQLITE_BUSY

In WAL mode, readers never block writers, and writers never block readers. However, if a writer is in the middle of a checkpoint, a new writer might get `SQLITE_BUSY`. You can set a timeout:

```sql
PRAGMA busy_timeout = 5000;  -- wait up to 5 seconds before returning BUSY
```

Or you can use a busy handler in your application code.

### Hands‑on Lab 15.1: Comparing Rollback vs. WAL

We'll measure the performance and observe the concurrency behaviour.

1. **Create a test database with rollback (default).**

   ```bash
   sqlite3 wal_test.db
   ```

   ```sql
   -- Default is DELETE journal mode
   PRAGMA journal_mode;  -- should be 'delete'
   CREATE TABLE test (id INTEGER, data TEXT);
   ```

   Insert many rows and measure time:

   ```sql
   .timer on
   BEGIN;
   INSERT INTO test (id, data) SELECT value, 'data' || value FROM generate_series(1, 100000);
   COMMIT;
   ```

2. **Switch to WAL mode.**

   ```sql
   PRAGMA journal_mode = WAL;
   -- Now insert another batch
   BEGIN;
   INSERT INTO test (id, data) SELECT value, 'data' || value FROM generate_series(100001, 200000);
   COMMIT;
   ```

   You may notice WAL is faster, especially for concurrent reads.

3. **Simulate concurrent access.**

   Open two terminals both connected to `wal_test.db`. In terminal 1, start a long write transaction:

   ```sql
   BEGIN;
   INSERT INTO test (id, data) SELECT value, 'data' || value FROM generate_series(200001, 300000);
   -- do not commit yet
   ```

   In terminal 2, run a read query:

   ```sql
   SELECT COUNT(*) FROM test;
   ```

   In rollback mode, this would block. In WAL mode, it will return immediately (reading from the main database and WAL).

4. **Checkpoint manually and observe file sizes.**

   ```sql
   PRAGMA wal_checkpoint;
   ```

   After a full checkpoint, the `-wal` file shrinks (or is truncated).

### Verification

- Confirm that `PRAGMA journal_mode` returns `wal` after setting.
- Confirm that readers are not blocked in WAL mode by performing the simultaneous test.
- Use `ls -lh` to see the `-wal` file grow and shrink with checkpoints.

---

**[GENERATED: Part 5, Module 15: Journaling & WAL]**

---

## Module 16: Reliability & Recovery

### The Target

Learn how to detect and recover from database corruption. Understand integrity checks (`PRAGMA integrity_check`, `foreign_key_check`), how to handle `SQLITE_BUSY`, and configure synchronous modes. Develop strategies for backup and recovery.

### The Concept

Even with WAL and transactions, things can go wrong: power outage, disk full, hardware failure. SQLite provides tools to verify the integrity of your database and to recover from corruption. The first line of defense is preventing corruption in the first place (proper sync settings, reliable hardware), but you also need to know how to detect and fix issues.

### Integrity Checks

**1. `PRAGMA integrity_check;`**

Scans the entire database and reports any internal inconsistencies (e.g., missing pages, incorrect B‑Tree structure). If it returns `ok`, the database is structurally sound.

```sql
PRAGMA integrity_check;
```

If corruption exists, it will list the specific issues (e.g., "rowid 123 missing from index").

**2. `PRAGMA foreign_key_check;`**

Checks for foreign key violations (rows that reference a non‑existent parent). This can happen if foreign keys were disabled during an operation.

```sql
PRAGMA foreign_key_check;
```

**3. `PRAGMA quick_check;`**

A faster, less thorough version of `integrity_check`.

### Recovery Strategies

If `integrity_check` finds errors, you have a few options:

- **Restore from backup** – The best solution.
- **Export data and rebuild** – Use `.dump` to export the schema and data, then create a fresh database and import. This may work if corruption is limited.
- **Use the `recover` extension** – SQLite has a `recover` virtual table (available as a loadable extension) that attempts to salvage data from a corrupt database.

```sql
-- If the recover extension is available
CREATE VIRTUAL TABLE temp.recover USING recover;
SELECT * FROM temp.recover;
```

But the easiest recovery is a good backup.

### Synchronous Modes

The `synchronous` PRAGMA controls how aggressively SQLite syncs data to disk. It directly affects durability and performance.

- **FULL** – At each critical point, SQLite calls `fsync()` to ensure data is written to the physical disk. Safe but slow.
- **NORMAL** – Syncs at less critical points; still safe for most systems. Recommended for WAL mode.
- **OFF** – No sync; fastest but if the OS crashes, the database may become corrupt. Only use for temporary data or when you can tolerate data loss.

```sql
PRAGMA synchronous = FULL;   -- safest
PRAGMA synchronous = NORMAL; -- good balance
PRAGMA synchronous = OFF;    -- risk
```

### Handling SQLITE_BUSY

When you get a `SQLITE_BUSY` error (database is locked), you can:

- Set a busy timeout: `PRAGMA busy_timeout = milliseconds;`
- Use a busy handler in your application code (we'll see in Part 7).
- Retry the operation.

In WAL mode, `SQLITE_BUSY` is much less common because readers don't block writers, but you may still encounter it during a checkpoint or when the WAL is full.

### Hands‑on Lab 16.1: Simulating Corruption and Recovery

We'll intentionally corrupt a database (carefully) and then try to recover it.

1. **Create a clean database.**

   ```bash
   sqlite3 corrupt.db
   CREATE TABLE data (id INTEGER PRIMARY KEY, value TEXT);
   INSERT INTO data (value) SELECT 'row' || value FROM generate_series(1, 100);
   ```

2. **Corrupt the file (simulate a partial write).**

   Exit SQLite. Use a hex editor or simply append garbage bytes to the end of the file.

   ```bash
   echo "garbage" >> corrupt.db
   ```

3. **Try to open the database.**

   ```bash
   sqlite3 corrupt.db
   PRAGMA integrity_check;
   ```

   You'll likely see errors like "database disk image is malformed".

4. **Attempt recovery using `.dump`.**

   ```bash
   sqlite3 corrupt.db ".dump" > dump.sql
   ```

   If the corruption is not in metadata, this might succeed. Then create a new database and import:

   ```bash
   sqlite3 recovered.db < dump.sql
   ```

5. **If that fails, try the recover extension.**

   (This may not be built‑in; you may need to compile it.) For this exercise, note that the process is possible.

### Backup Strategies

SQLite provides an **Online Backup API** (we'll cover programmatic backup in Part 7). But you can also back up by simply copying the database file while it's not in use. However, to back up while the database is active, you can use the backup API or the `sqlite3_backup` C function.

For command‑line, you can use:

```bash
sqlite3 source.db ".backup main target.db"
```

This creates a hot backup (copies the database while it's in use, using the backup API).

### Maintenance Checklist

- Run `PRAGMA integrity_check` periodically.
- Run `PRAGMA wal_checkpoint` in WAL mode to keep the WAL file small.
- Use `VACUUM` to reclaim space and defragment (though this can be expensive).
- Keep regular backups.
- Monitor for `SQLITE_BUSY` and set appropriate timeouts.

### Hands‑on Lab 16.2: Integrity and Foreign Key Checks

```sql
-- Check integrity
PRAGMA integrity_check;

-- Check foreign keys
PRAGMA foreign_key_check;

-- If you suspect a table issue, you can check a specific table
SELECT * FROM sqlite_master WHERE type='table';
```

### Verification

- Run `PRAGMA integrity_check` on a healthy database and confirm it returns `ok`.
- Create a foreign key violation and run `PRAGMA foreign_key_check` to see the error.
- Test the busy timeout by starting a long transaction in one terminal and attempting a query in another; set `busy_timeout` to 3000 ms and observe the wait.

You have now mastered transactions, concurrency, and reliability. You can choose the right journal mode, tune checkpoints, handle locks, and detect/correct corruption. These skills are essential for building robust, production‑grade applications.

In **Part 6: Advanced SQLite Features**, we will explore JSON1 for document storage, FTS5 for full‑text search, virtual tables, extensions, triggers, and views. These features extend SQLite beyond a traditional relational database into a multi‑paradigm data platform.
