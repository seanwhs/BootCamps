# Transactions and Concurrency Primer 5: Keeping Your Data Safe

You've built your database and optimized your queries. Now imagine this: you're transferring $100 from Alice's account to Bob's. You subtract $100 from Alice, then—before you can add it to Bob—the power goes out. You've lost $100. This is why we need **transactions**.

This primer covers the essentials of SQLite transactions: what they are, how to use them, how concurrency works, and how to avoid common pitfalls like `SQLITE_BUSY`. By the end, your data will be safe, consistent, and resilient.

---

## 1. What Is a Transaction?

A **transaction** is a group of SQL statements that must succeed or fail as a single unit. It has four properties, known as **ACID**:

- **Atomicity** – All changes are applied, or none are.
- **Consistency** – The database remains in a valid state (constraints are enforced).
- **Isolation** – Transactions do not interfere with each other.
- **Durability** – Once committed, changes survive a crash.

Think of a transaction as a **bank teller**: they either complete your entire withdrawal and deposit, or they cancel everything and leave your account untouched.

---

## 2. Basic Transaction Commands

### Start a Transaction
```sql
BEGIN;          -- or BEGIN TRANSACTION;
```

### Commit (Save Changes)
```sql
COMMIT;         -- or END;
```

### Rollback (Cancel Changes)
```sql
ROLLBACK;
```

### Example: Safe Money Transfer
```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
COMMIT;
```
If either update fails (e.g., insufficient funds), you can issue `ROLLBACK` and both changes are undone.

---

## 3. Autocommit Mode

By default, SQLite **automatically commits** each statement immediately. If you want to group multiple statements, you must explicitly use `BEGIN`.

```sql
-- Each INSERT is committed immediately
INSERT INTO logs (message) VALUES ('Step 1');
INSERT INTO logs (message) VALUES ('Step 2');
```
This is fine for simple operations, but it's slower for bulk inserts and unsafe for dependent changes.

---

## 4. Savepoints (Nested Transactions)

SQLite doesn't support true nested transactions, but you can use **savepoints** to create partial rollback points.

```sql
BEGIN;
UPDATE accounts SET balance = balance + 50 WHERE account_id = 1;

SAVEPOINT sp1;          -- bookmark

UPDATE accounts SET balance = balance - 200 WHERE account_id = 2;  -- risky!

ROLLBACK TO sp1;        -- undo only the last update

-- Continue...
RELEASE sp1;            -- remove the savepoint
COMMIT;
```

---

## 5. Locking and Concurrency

SQLite uses locks to manage simultaneous access. In the default **rollback journal** mode, there are five locking states:

| State | Who Can Hold It | Effect |
|-------|-----------------|--------|
| **UNLOCKED** | None | No lock. |
| **SHARED** | Multiple readers | Allows reads, blocks writes. |
| **RESERVED** | One writer | Allows reads, prevents other writers. |
| **PENDING** | One writer waiting to commit | Blocks new readers, waits for existing readers to finish. |
| **EXCLUSIVE** | One writer | Blocks everything (during commit). |

### Rollback Journal Mode (Default)
- Readers can read while writers hold `RESERVED` locks.
- Writers block readers only during the final commit phase (`EXCLUSIVE`).
- Only one writer at a time.

### Write‑Ahead Logging (WAL) Mode (Recommended)
```sql
PRAGMA journal_mode = WAL;
```
- **Readers never block writers, and writers never block readers.**
- Changes are appended to a separate `-wal` file.
- Only one writer at a time, but readers can continue reading.
- The only blocking occurs during **checkpoints** (when WAL frames are transferred to the main database).

**Switch to WAL mode for almost all production applications.**

---

## 6. Handling `SQLITE_BUSY`

When a transaction tries to acquire a lock that's held by another connection, you get `SQLITE_BUSY`. This can happen if:
- Another connection is writing (EXCLUSIVE lock).
- A checkpoint is running (in WAL mode).

### Solutions:

**1. Set a busy timeout**
```sql
PRAGMA busy_timeout = 5000;   -- wait up to 5 seconds
```
SQLite will retry the operation for that duration before giving up.

**2. Implement retry logic**
In your application, catch `SQLITE_BUSY` and retry with exponential backoff.

**Python example:**
```python
import time
import sqlite3

def execute_with_retry(cursor, sql, params, retries=5):
    for attempt in range(retries):
        try:
            cursor.execute(sql, params)
            return
        except sqlite3.OperationalError as e:
            if "database is locked" in str(e) and attempt < retries-1:
                time.sleep(0.1 * (2 ** attempt))
                continue
            raise
```

**3. Use WAL mode** – it significantly reduces `SQLITE_BUSY` because readers don't block writers.

---

## 7. WAL Mode Tuning

### Enable WAL
```sql
PRAGMA journal_mode = WAL;
```

### Checkpoint Management
Checkpoints transfer WAL frames to the main database. You can control when they happen:

```sql
-- Auto‑checkpoint after 1000 pages (default)
PRAGMA wal_autocheckpoint = 1000;

-- Manual checkpoint
PRAGMA wal_checkpoint(FULL);

-- Passive checkpoint (doesn't block writes)
PRAGMA wal_checkpoint(PASSIVE);
```

**Best practice:** Leave `wal_autocheckpoint` at 1000 unless you have specific performance needs (e.g., lower for frequent small writes, higher for bulk operations).

---

## 8. Transaction Best Practices

- **Keep transactions short** – long transactions hold locks and increase contention.
- **Use WAL mode** for better concurrency.
- **Set `busy_timeout`** to avoid crashing on `SQLITE_BUSY`.
- **Batch writes** – group many inserts in one transaction for speed.
- **Use `BEGIN IMMEDIATE`** if you know you'll write (reduces lock escalation overhead).
  ```sql
  BEGIN IMMEDIATE;
  ```
- **Rollback on error** – always handle exceptions and rollback if needed.
- **Test concurrency** – simulate multiple users to catch locking issues early.

---

## 9. Common Concurrency Scenarios

### Multiple Readers, One Writer (WAL Mode)
- Perfect: readers never block, writer appends to WAL.
- No `SQLITE_BUSY` for readers.

### Two Writers (Always One at a Time)
- The second writer will wait (or get `SQLITE_BUSY`) until the first commits.
- Use `busy_timeout` to wait.

### Long‑Running Write Transaction
- Blocks other writers, and in rollback mode blocks new readers during commit.
- **Solution:** Keep writes short; use WAL mode; consider splitting large operations into batches.

### Checkpoint Blocking
- A `FULL` checkpoint blocks writers briefly.
- Use `PASSIVE` checkpoints if you need to avoid blocking.

---

## 10. Transactions and Performance

Wrapping multiple statements in a transaction **dramatically speeds up** bulk operations because SQLite doesn't sync the journal after every single insert.

```sql
-- Slow (autocommit for each row)
INSERT INTO t VALUES (1);
INSERT INTO t VALUES (2);
-- ... thousands more

-- Fast (one commit)
BEGIN;
INSERT INTO t VALUES (1);
INSERT INTO t VALUES (2);
-- ... thousands more
COMMIT;
```

**Measurement:** Without a transaction, 100,000 inserts might take 5 seconds; with a transaction, it can take 0.2 seconds.

---

## 11. Quick Reference: Transaction Commands

| Command | Description |
|---------|-------------|
| `BEGIN;` | Start a transaction. |
| `BEGIN IMMEDIATE;` | Start and acquire a RESERVED lock immediately. |
| `BEGIN EXCLUSIVE;` | Start and acquire an EXCLUSIVE lock immediately (rare). |
| `COMMIT;` | Save all changes. |
| `ROLLBACK;` | Undo all changes. |
| `SAVEPOINT name;` | Create a bookmark. |
| `ROLLBACK TO name;` | Rollback to a savepoint. |
| `RELEASE name;` | Remove a savepoint. |

---

## 12. What to Monitor

- **Journal mode**: `PRAGMA journal_mode;` – should be `wal`.
- **Lock status**: `PRAGMA locking_mode;` (usually `NORMAL`).
- **Busy timeout**: `PRAGMA busy_timeout;` – ensure it's set.
- **WAL file size**: Monitor `-wal` file; if it grows too large, check checkpoints.

---

## 13. Real‑World Example: Order Processing

```sql
-- Enable WAL and set timeout
PRAGMA journal_mode = WAL;
PRAGMA busy_timeout = 5000;

BEGIN IMMEDIATE;  -- get the write lock early

-- Check stock
SELECT stock FROM products WHERE product_id = 101;
-- If stock < quantity: ROLLBACK and exit

-- Reduce stock
UPDATE products SET stock = stock - 5 WHERE product_id = 101;

-- Record order
INSERT INTO orders (customer_id, total) VALUES (123, 499.95);
INSERT INTO order_items (order_id, product_id, quantity, price) 
VALUES (last_insert_rowid(), 101, 5, 99.99);

COMMIT;
```

If any step fails (e.g., stock insufficient), you can `ROLLBACK` and everything is undone.

---

## Next Steps

- Understand **locking in detail** (rollback vs. WAL).
- Learn about **crash recovery** and journaling.
- Dive into **error handling** in your programming language.
- Explore **backup and recovery** strategies.
- Apply these concepts in the **Master SQLite** series.

---

**Transactions are your safety net.** Use them wisely, keep them short, and always test with realistic concurrency. Now go forth and build reliable, crash‑resistant applications!

Happy transacting!
