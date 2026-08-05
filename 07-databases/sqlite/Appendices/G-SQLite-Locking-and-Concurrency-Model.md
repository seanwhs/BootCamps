# Appendix G: SQLite Locking and Concurrency Model

SQLite uses a fine‑grained locking protocol to manage concurrent access to the database file. Understanding these locks is essential for building applications that scale, avoid deadlocks, and handle `SQLITE_BUSY` errors gracefully.

This appendix covers the locking states, transaction semantics, differences between rollback journal and WAL modes, and best practices for high‑concurrency scenarios.

---

## 1. The Five Locking States (Rollback Journal Mode)

In the default rollback journal mode (`DELETE`, `TRUNCATE`, `PERSIST`, `MEMORY`), SQLite uses a **five‑state locking protocol** that progressively escalates as a transaction progresses.

| State | Description | Held By | Compatibility |
|-------|-------------|---------|---------------|
| **UNLOCKED** | No lock is held. | Any connection initially. | All operations allowed. |
| **SHARED** | Read lock. Multiple readers can hold this simultaneously. | Any connection reading data. | Multiple SHARED locks can coexist. |
| **RESERVED** | Intention to write. The connection has read the database and will modify it later. | The connection that intends to write. | Only one RESERVED lock at a time; SHARED locks can still be acquired. |
| **PENDING** | Writer is waiting to upgrade to EXCLUSIVE. New SHARED locks are blocked, but existing SHARED locks can continue. | The writer that wants to commit. | No new SHARED locks allowed; existing SHARED locks remain. |
| **EXCLUSIVE** | Exclusive write lock. No other connections can read or write. | The writer during the commit phase. | No other locks allowed. |

### Lock Progression

1. **Read Transaction (SELECT)**: Acquires a **SHARED** lock. Multiple readers can hold SHARED locks.
2. **Write Transaction (INSERT/UPDATE/DELETE)**: 
   - Initially acquires a **SHARED** lock to read the data.
   - Upgrades to **RESERVED** when the first modification is made (this prevents other writers, but still allows readers).
   - Upgrades to **PENDING** when it is ready to commit (blocks new readers).
   - Upgrades to **EXCLUSIVE** to finalize the changes to disk (blocks all others).
3. **Commit**: During commit, the lock escalates from RESERVED → PENDING → EXCLUSIVE, writes changes, then drops back to UNLOCKED.

### Lock Duration

- **SHARED** locks are held for the duration of a read transaction (or until the statement completes if autocommit).
- **RESERVED** locks are held from the first write until the transaction commits or rolls back.
- **EXCLUSIVE** locks are held only for the final sync and file updates (microseconds, but can be longer if the disk is slow).

---

## 2. Write‑Ahead Logging (WAL) Mode

In WAL mode, the locking model is **different** and significantly more concurrent.

- **Readers and writers do not block each other.**
- Writers append to the WAL file; readers read from both the main database and the WAL.
- The only blocking occurs during **checkpoints**.

### WAL Locking States (Simplified)

- **Shared locks** are still used for reads, but they do not block writers.
- A writer acquires a **reserved** lock (similar to rollback) but does not block readers.
- When the writer commits, it does not need an EXCLUSIVE lock; it only waits for readers to finish reading the WAL frames.
- The main blocking point is the **checkpoint** (when WAL frames are transferred to the main database). During a checkpoint, a writer may be blocked if a reader is still using the WAL.

### WAL Advantages

- Better concurrency: multiple readers and one writer can operate simultaneously.
- Faster writes (append‑only to WAL).
- Safer crash recovery (WAL is append‑only, less likely to corrupt).

### WAL Disadvantages

- Requires an extra file (`-wal`) and occasional checkpoints.
- May be slower for databases with many small writes (due to checkpoint overhead).

---

## 3. Transaction Isolation Levels

SQLite implements **serializable isolation** by default (the highest level). Transactions are fully isolated from each other; effects become visible only on commit. In rollback journal mode, this is achieved via locking (writers block readers during commit). In WAL mode, isolation is achieved via the WAL file (readers see a consistent snapshot of the database from when they started reading).

### Autocommit Mode

By default, each SQL statement is its own transaction (autocommit). You can wrap multiple statements in `BEGIN` and `COMMIT` to group them.

---

## 4. Deadlocks

SQLite does not use the standard two‑phase locking, but deadlocks can still occur in **shared cache mode** (when multiple connections share the same in‑memory cache). In normal mode (no shared cache), deadlocks are extremely rare because:
- Writers block readers only during commit (briefly).
- The lock escalation is predictable.
- There is no wait‑for graph with multiple resources.

However, if you use `ATTACH` with multiple databases, or use `SAVEPOINT` with complex nesting, you may encounter deadlocks. Best practice:
- Avoid shared cache mode.
- Keep transactions short.
- Use WAL mode to reduce lock contention.

---

## 5. `SQLITE_BUSY` and `SQLITE_LOCKED`

### `SQLITE_BUSY`

Occurs when a connection attempts to acquire a lock that is held by another connection. Common causes:
- Another connection has an EXCLUSIVE lock (writing).
- Another connection is in the middle of a checkpoint (WAL mode).
- The database is in the PENDING state (writer waiting for readers to finish).

**Solutions:**
- Set `PRAGMA busy_timeout` to a reasonable value (e.g., 5000 ms). SQLite will retry for that duration before returning `SQLITE_BUSY`.
- Implement application‑level retry logic with exponential backoff.
- Use WAL mode to reduce `SQLITE_BUSY` because readers don't block writers.

### `SQLITE_LOCKED`

Occurs when a specific table is locked (usually in shared cache mode). In normal mode, you are more likely to get `SQLITE_BUSY`.

**Solutions:**
- Upgrade to WAL mode.
- Use `PRAGMA locking_mode = EXCLUSIVE` to keep the database locked for the entire connection (reduces lock contention in some cases).
- Restructure transactions to be shorter.

---

## 6. Shared Cache Mode

SQLite can be compiled with shared‑cache mode (the default in many builds). When enabled, multiple connections to the same database share the page cache and locking structures. This can improve performance but also increases lock contention. If you encounter excessive `SQLITE_LOCKED`, you can disable shared cache by:
- Compiling with `-DSQLITE_THREADSAFE=1` and using `sqlite3_open_v2()` with `SQLITE_OPEN_NOMUTEX`.
- Or setting the environment variable `SQLITE_DEFAULT_CACHE_SIZE` to something else (not recommended).

---

## 7. WAL Checkpoints and Concurrency

Checkpoints are the bottleneck in WAL mode. They transfer frames from the WAL to the main database. During a checkpoint:
- The checkpoint operation may block new writers until it completes (if using `FULL` mode).
- Readers can continue reading.

**Tuning:**
- Set `PRAGMA wal_autocheckpoint = N` to control checkpoint frequency. Lower values = more frequent checkpoints (less WAL growth, more blocking). Higher values = less frequent checkpoints (faster writes, but larger WAL).
- Use `PRAGMA wal_checkpoint(PASSIVE)` to run a checkpoint that does not block writes.
- Use `PRAGMA wal_checkpoint(RESTART)` to checkpoint and restart the WAL (new readers will see the checkpoint).

---

## 8. Concurrency Best Practices

| Scenario | Recommendation |
|----------|----------------|
| **High read volume, few writes** | Use WAL mode; readers will never block writers. |
| **High write volume** | Use WAL mode; batch writes in transactions; tune `wal_autocheckpoint`. |
| **Multiple connections in different threads/processes** | Use WAL mode; set busy timeout; avoid long transactions. |
| **Need to read while writing** | WAL mode is essential; in rollback mode, writers block readers during commit. |
| **Heavy contention on a single table** | Consider partitioning (separate tables) or using `WITHOUT ROWID` to optimize. |
| **Deadlocks** | Use WAL mode; avoid shared cache; keep transactions short. |

---

## 9. Monitoring Locking State

You can inspect the current locking state using `PRAGMA` commands (but they may not be available on all builds).

- `PRAGMA locking_mode` – returns `NORMAL` or `EXCLUSIVE`.
- `PRAGMA journal_mode` – tells you which journaling mode is in use.
- In WAL mode, you can check the WAL status:
  ```sql
  PRAGMA wal_checkpoint;
  ```
  Returns the number of frames in the WAL, the number of frames checkpointed, and the current status.

For a live view of locks, you can use the `.schema` and `.dump` in the CLI, but there is no built‑in lock monitoring tool. Use the operating system's file locking tools (e.g., `lsof` on Linux) to see who has the database file open.

---

## 10. Summary Table: Rollback vs. WAL Concurrency

| Aspect | Rollback Journal | WAL |
|--------|------------------|-----|
| Readers block writers? | No (readers acquire SHARED, writer can hold RESERVED) | No |
| Writers block readers? | Yes (during EXCLUSIVE lock at commit) | No (readers read from WAL) |
| Multiple writers? | No (only one writer at a time) | No (only one writer at a time) |
| Checkpoint blocking | N/A | Yes, during checkpoint |
| Best for | Low concurrency, or where writes are rare | High concurrency, or mixed read/write |

---

This appendix gives you a solid foundation for building highly concurrent applications with SQLite. Remember: when in doubt, choose WAL mode, set `busy_timeout`, and keep transactions short.
