# Appendix D: SQLite PRAGMA Statements Reference

PRAGMA statements are special SQL commands that control the behavior of the SQLite library, adjust performance parameters, and inspect internal state. They are essential for production tuning, debugging, and understanding your database.

This appendix categorizes all commonly used PRAGMAs by purpose, provides syntax, default values, and practical examples.

---

## 1. Database Settings

### `PRAGMA journal_mode = MODE`

Controls the transaction journaling mode. Affects durability, concurrency, and performance.

| Mode | Description |
|------|-------------|
| `DELETE` | Default. The rollback journal is deleted after each transaction commit. |
| `TRUNCATE` | Journal is truncated to zero length instead of deleted (slightly faster on some systems). |
| `PERSIST` | Journal header is overwritten, but file remains (avoids delete/recreate overhead). |
| `MEMORY` | Journal is stored in memory (fastest, but data is lost on crash). |
| `WAL` | **Write‑Ahead Logging**. Recommended for most applications. Better concurrency and performance. |
| `OFF` | No journaling (extremely fast, but no crash recovery). |

**Example:**
```sql
PRAGMA journal_mode = WAL;
-- Returns 'wal' if successful.
```

**Verification:**
```sql
PRAGMA journal_mode;  -- Returns current mode.
```

---

### `PRAGMA synchronous = MODE`

Controls how aggressively SQLite synchronizes data to disk. Affects durability and speed.

| Mode | Description |
|------|-------------|
| `OFF` | No sync calls. Fastest, but risk of corruption on crash. |
| `NORMAL` | Sync at critical moments. Good balance. Recommended for WAL mode. |
| `FULL` | Sync at every critical point. Safest, but slowest. |

**Example:**
```sql
PRAGMA synchronous = NORMAL;
```

**Verification:**
```sql
PRAGMA synchronous;
```

---

### `PRAGMA cache_size = PAGES`

Sets the maximum number of database pages that SQLite will hold in memory cache. Larger cache reduces disk I/O.

- Default: 2000 pages (or `-2000` for kilobytes).
- Set to a higher value (e.g., `10000`) for performance.

**Example:**
```sql
PRAGMA cache_size = 10000;  -- 10,000 pages (about 40 MB if page size is 4096)
```

**Verification:**
```sql
PRAGMA cache_size;
```

---

### `PRAGMA page_size = BYTES`

Sets the page size of the database in bytes. Must be set **before** creating any tables (or use `VACUUM` to change).

- Common values: 1024, 2048, 4096 (default), 8192, 16384.
- Larger pages can improve performance for large records, but waste space for small ones.

**Example:**
```sql
PRAGMA page_size = 8192;
```

**Verification:**
```sql
PRAGMA page_size;
```

---

### `PRAGMA mmap_size = BYTES`

Enables memory‑mapped I/O. SQLite will map the database file into the process address space, which can dramatically speed up reads.

- Set to a large value (e.g., `30000000000` for 30 GB) to enable.
- Default is `0` (disabled).

**Example:**
```sql
PRAGMA mmap_size = 268435456;  -- 256 MB
```

**Verification:**
```sql
PRAGMA mmap_size;
```

---

### `PRAGMA foreign_keys = ON|OFF`

Enables or disables foreign key constraints enforcement. **Always enable for production** (except during bulk operations).

**Example:**
```sql
PRAGMA foreign_keys = ON;
```

**Verification:**
```sql
PRAGMA foreign_keys;
```

---

### `PRAGMA auto_vacuum = MODE`

Controls automatic reclaim of unused space.

| Mode | Description |
|------|-------------|
| `NONE` | Disabled. Space is not reclaimed. |
| `FULL` | Database is compacted automatically when pages are freed (similar to VACUUM). |
| `INCREMENTAL` | Free pages are stored in a freelist; you must manually call `PRAGMA incremental_vacuum(N)` to reclaim them. |

**Example:**
```sql
PRAGMA auto_vacuum = FULL;
```

**Verification:**
```sql
PRAGMA auto_vacuum;
```

---

## 2. Performance and Query Tuning

### `PRAGMA busy_timeout = MILLISECONDS`

Sets a timeout for waiting on a locked database. If a lock is held, SQLite will retry for the specified milliseconds before returning `SQLITE_BUSY`.

- Default: 0 (immediate busy).
- Recommended: 5000 (5 seconds) for most applications.

**Example:**
```sql
PRAGMA busy_timeout = 5000;
```

---

### `PRAGMA temp_store = MODE`

Controls where temporary tables and indices are stored.

| Mode | Description |
|------|-------------|
| `DEFAULT` | Use the compile‑time default (usually file). |
| `FILE` | Store in temporary file. |
| `MEMORY` | Store in memory (fastest). |

**Example:**
```sql
PRAGMA temp_store = MEMORY;
```

**Verification:**
```sql
PRAGMA temp_store;
```

---

### `PRAGMA journal_size_limit = BYTES`

Limits the size of the rollback journal or WAL file. Prevents excessive disk usage.

- Default: `-1` (no limit).
- Set to a positive value (e.g., `1048576` for 1 MB).

**Example:**
```sql
PRAGMA journal_size_limit = 1048576;
```

---

### `PRAGMA wal_autocheckpoint = N`

Sets the threshold of WAL pages after which an automatic checkpoint occurs.

- Default: 1000 pages.
- Set to a lower value to keep the WAL small (more frequent checkpoints) or higher for better write performance.

**Example:**
```sql
PRAGMA wal_autocheckpoint = 500;
```

**Verification:**
```sql
PRAGMA wal_autocheckpoint;
```

---

### `PRAGMA wal_checkpoint [MODE]`

Manually triggers a checkpoint, moving WAL frames to the main database file.

| Mode | Description |
|------|-------------|
| `PASSIVE` | Checkpoint as much as possible without blocking readers/writers. |
| `FULL` | Checkpoint all frames, blocking writers if needed. |
| `RESTART` | After checkpoint, restart the WAL (new readers see the checkpoint). |
| `TRUNCATE` | After checkpoint, truncate the WAL file. |

**Example:**
```sql
PRAGMA wal_checkpoint(FULL);
```

---

## 3. Debugging and Inspection

### `PRAGMA integrity_check`

Scans the entire database for structural corruption. Returns `'ok'` if healthy, otherwise lists errors.

**Example:**
```sql
PRAGMA integrity_check;
```

**Verification:** Should return a single row with `'ok'`.

---

### `PRAGMA foreign_key_check`

Checks all foreign key constraints. Returns rows with violations (missing parent records).

**Example:**
```sql
PRAGMA foreign_key_check;
```

---

### `PRAGMA quick_check`

A faster, less thorough version of `integrity_check`.

**Example:**
```sql
PRAGMA quick_check;
```

---

### `PRAGMA schema_version`

Returns the current schema version (an integer that changes when the schema is modified).

**Example:**
```sql
PRAGMA schema_version;
```

---

### `PRAGMA data_version`

Returns the version of the data (changes on every write). Useful for detecting changes.

**Example:**
```sql
PRAGMA data_version;
```

---

### `PRAGMA database_list`

Lists all attached databases with their file paths (same as `.databases` in CLI).

**Example:**
```sql
PRAGMA database_list;
```

---

### `PRAGMA table_info(TABLE_NAME)`

Returns column metadata for a table (name, type, notnull, default, pk).

**Example:**
```sql
PRAGMA table_info(users);
```

---

### `PRAGMA index_info(INDEX_NAME)`

Returns column information for an index.

**Example:**
```sql
PRAGMA index_info(idx_users_last_name);
```

---

### `PRAGMA index_list(TABLE_NAME)`

Lists all indexes on a table.

**Example:**
```sql
PRAGMA index_list(users);
```

---

### `PRAGMA foreign_key_list(TABLE_NAME)`

Lists foreign key constraints on a table.

**Example:**
```sql
PRAGMA foreign_key_list(books);
```

---

## 4. Memory and Resource Usage

### `PRAGMA memory_used`

Returns the amount of heap memory currently allocated by SQLite (in bytes). Useful for profiling.

**Example:**
```sql
PRAGMA memory_used;
```

---

### `PRAGMA memory_highwater`

Returns the maximum amount of heap memory ever allocated since the connection was opened (or since reset).

**Example:**
```sql
PRAGMA memory_highwater;
```

---

### `PRAGMA soft_heap_limit = BYTES`

Sets a soft limit on heap memory usage. If exceeded, SQLite will attempt to free memory. Set to `0` to disable.

**Example:**
```sql
PRAGMA soft_heap_limit = 67108864;  -- 64 MB
```

---

## 5. Security and Encryption

### `PRAGMA key = 'password'`

Used with SQLCipher to set the encryption key for an encrypted database. Must be called immediately after opening the connection.

**Example:**
```sql
PRAGMA key = 'my_secure_password';
```

---

### `PRAGMA cipher_page_size = BYTES`

Sets the page size for SQLCipher encryption. Must match the database's page size.

**Example:**
```sql
PRAGMA cipher_page_size = 4096;
```

---

### `PRAGMA kdf_iter = N`

Sets the number of iterations for key derivation function (PBKDF2) in SQLCipher. Higher values increase security but slow down opening.

- Default: 64000.

**Example:**
```sql
PRAGMA kdf_iter = 100000;
```

---

## 6. Other Useful PRAGMAs

### `PRAGMA locking_mode = MODE`

Controls locking behavior.

| Mode | Description |
|------|-------------|
| `NORMAL` | Default; locks are released after transaction. |
| `EXCLUSIVE` | Database remains locked until connection closes. |

**Example:**
```sql
PRAGMA locking_mode = EXCLUSIVE;
```

---

### `PRAGMA case_sensitive_like = ON|OFF`

Controls whether the `LIKE` operator is case‑sensitive. Default is `OFF` (case‑insensitive for ASCII).

**Example:**
```sql
PRAGMA case_sensitive_like = ON;
```

---

### `PRAGMA threads = N`

Sets the maximum number of threads used by SQLite for parallel operations (if compiled with threading support).

**Example:**
```sql
PRAGMA threads = 4;
```

---

### `PRAGMA secure_delete = ON|OFF`

When ON, SQLite overwrites deleted data with zeros to prevent recovery. Slightly slower.

**Example:**
```sql
PRAGMA secure_delete = ON;
```

---

## 7. PRAGMA Quick Reference by Category

| Category | Pragmas |
|----------|---------|
| **Journaling** | `journal_mode`, `synchronous`, `wal_autocheckpoint`, `wal_checkpoint` |
| **Memory** | `cache_size`, `mmap_size`, `temp_store`, `memory_used`, `memory_highwater`, `soft_heap_limit` |
| **Performance** | `busy_timeout`, `journal_size_limit`, `threads` |
| **Integrity** | `integrity_check`, `quick_check`, `foreign_key_check` |
| **Schema** | `schema_version`, `data_version`, `table_info`, `index_info`, `index_list`, `foreign_key_list` |
| **Security** | `key`, `cipher_page_size`, `kdf_iter`, `secure_delete`, `foreign_keys` |
| **Locking** | `locking_mode` |

---

## 8. Important Notes

- Many PRAGMAs are **connection‑specific**; changes apply only to the current connection.
- Some PRAGMAs (like `auto_vacuum`, `page_size`) are **permanent** and stored in the database header.
- Always test PRAGMA changes thoroughly in a staging environment before applying to production.
- Use the `PRAGMA` statement without arguments to query the current value (e.g., `PRAGMA journal_mode;`).

---

This appendix serves as your go‑to reference for controlling SQLite's behavior in production. Bookmark it and refer back whenever you need to tune performance, enforce constraints, or debug issues.
