# Appendix E: SQLite Error Codes and Handling

This appendix provides a complete reference for SQLite's error codes, their meanings, common causes, and best practices for handling them in your applications. Understanding these errors is essential for building robust, production‑ready systems.

---

## 1. Error Code Categories

SQLite returns integer error codes that are divided into categories:

| Category | Range | Description |
|----------|-------|-------------|
| **Generic** | 1–99 | General SQLite errors. |
| **OS/IO** | 100–199 | Operating system and I/O errors. |
| **SQL** | 200–299 | SQL parsing or execution errors. |
| **Constraint** | 300–399 | Constraint violations. |
| **Schema** | 400–499 | Schema-related errors. |
| **Intermittent** | 500–599 | Transient errors (e.g., busy, locked). |
| **Miscellaneous** | 600+ | Other errors (e.g., not found, too big). |

---

## 2. Complete Error Code Reference

### Generic Errors

| Code | Name | Description |
|------|------|-------------|
| 0 | `SQLITE_OK` | Success. |
| 1 | `SQLITE_ERROR` | Generic error. Check the error message for details. |
| 2 | `SQLITE_INTERNAL` | Internal logic error (should not occur). |
| 3 | `SQLITE_PERM` | Access permission denied. |
| 4 | `SQLITE_ABORT` | Query aborted by callback or rollback. |
| 5 | `SQLITE_BUSY` | Database file is locked (see `SQLITE_BUSY` handling). |
| 6 | `SQLITE_LOCKED` | A table in the database is locked. |
| 7 | `SQLITE_NOMEM` | Memory allocation failed. |
| 8 | `SQLITE_READONLY` | Attempt to write to a read‑only database. |
| 9 | `SQLITE_INTERRUPT` | Operation interrupted by `sqlite3_interrupt()`. |
| 10 | `SQLITE_IOERR` | I/O error (see extended error codes for specifics). |
| 11 | `SQLITE_CORRUPT` | Database file is corrupt. |
| 12 | `SQLITE_NOTFOUND` | Table or object not found (extended error). |
| 13 | `SQLITE_FULL` | Database is full (disk full). |
| 14 | `SQLITE_CANTOPEN` | Unable to open the database file. |
| 15 | `SQLITE_PROTOCOL` | Protocol error (locking protocol violation). |
| 16 | `SQLITE_EMPTY` | Empty database (internal). |
| 17 | `SQLITE_SCHEMA` | Schema has changed (prepared statement must be re‑compiled). |
| 18 | `SQLITE_TOOBIG` | String or BLOB exceeds maximum size. |
| 19 | `SQLITE_CONSTRAINT` | Constraint violation (see sub‑codes). |
| 20 | `SQLITE_MISMATCH` | Data type mismatch. |
| 21 | `SQLITE_MISUSE` | Library used incorrectly (e.g., wrong API call order). |
| 22 | `SQLITE_NOLFS` | Large file support is not available on the platform. |
| 23 | `SQLITE_AUTH` | Authorization denied (e.g., access control). |
| 24 | `SQLITE_FORMAT` | Auxiliary database format error. |
| 25 | `SQLITE_RANGE` | Column index out of range. |
| 26 | `SQLITE_NOTADB` | File is not a valid SQLite database. |
| 27 | `SQLITE_NOTICE` | Notice (warnings, extended error). |
| 28 | `SQLITE_WARNING` | Warning (extended error). |

### Constraint Violation Sub‑Errors (SQLITE_CONSTRAINT)

| Code | Extended Code | Description |
|------|---------------|-------------|
| 19 | 787 | `SQLITE_CONSTRAINT_CHECK` – A `CHECK` constraint failed. |
| 19 | 787 | `SQLITE_CONSTRAINT_COMMITHOOK` – Commit hook failed. |
| 19 | 787 | `SQLITE_CONSTRAINT_FOREIGNKEY` – Foreign key violation. |
| 19 | 787 | `SQLITE_CONSTRAINT_FUNCTION` – Custom function constraint failed. |
| 19 | 787 | `SQLITE_CONSTRAINT_NOTNULL` – `NOT NULL` constraint violation. |
| 19 | 787 | `SQLITE_CONSTRAINT_PRIMARYKEY` – Primary key violation (duplicate). |
| 19 | 787 | `SQLITE_CONSTRAINT_TRIGGER` – Trigger aborted the operation. |
| 19 | 787 | `SQLITE_CONSTRAINT_UNIQUE` – Unique constraint violation (duplicate). |
| 19 | 787 | `SQLITE_CONSTRAINT_VTAB` – Virtual table constraint error. |

### OS/IO Extended Errors (SQLITE_IOERR)

| Code | Extended Code | Description |
|------|---------------|-------------|
| 10 | 522 | `SQLITE_IOERR_READ` – Read error. |
| 10 | 523 | `SQLITE_IOERR_SHORT_READ` – Read returned fewer bytes than expected. |
| 10 | 524 | `SQLITE_IOERR_WRITE` – Write error. |
| 10 | 525 | `SQLITE_IOERR_FSYNC` – Sync/fsync failed. |
| 10 | 526 | `SQLITE_IOERR_DIR_FSYNC` – Directory sync failed. |
| 10 | 527 | `SQLITE_IOERR_TRUNCATE` – Truncate failed. |
| 10 | 528 | `SQLITE_IOERR_FSTAT` – Stat failed. |
| 10 | 529 | `SQLITE_IOERR_UNLOCK` – Unlock failed. |
| 10 | 530 | `SQLITE_IOERR_RDLOCK` – Read lock failed. |
| 10 | 531 | `SQLITE_IOERR_DELETE` – Delete failed. |
| 10 | 532 | `SQLITE_IOERR_BLOCKED` – Blocked by lock. |
| 10 | 533 | `SQLITE_IOERR_NOMEM` – Memory allocation failed during I/O. |
| 10 | 534 | `SQLITE_IOERR_ACCESS` – Access denied. |
| 10 | 535 | `SQLITE_IOERR_CHECKRESERVEDLOCK` – Reserved lock check failed. |
| 10 | 536 | `SQLITE_IOERR_LOCK` – Lock operation failed. |
| 10 | 537 | `SQLITE_IOERR_CLOSE` – Close failed. |
| 10 | 538 | `SQLITE_IOERR_DIR_CLOSE` – Directory close failed. |
| 10 | 539 | `SQLITE_IOERR_SHMOPEN` – Shared memory open failed (WAL). |
| 10 | 540 | `SQLITE_IOERR_SHMSIZE` – Shared memory size error. |
| 10 | 541 | `SQLITE_IOERR_SHMLOCK` – Shared memory lock failed. |
| 10 | 542 | `SQLITE_IOERR_SHMMAP` – Shared memory map failed. |
| 10 | 543 | `SQLITE_IOERR_SEEK` – Seek failed. |
| 10 | 544 | `SQLITE_IOERR_DELETE_NOENT` – Delete failed because file does not exist. |
| 10 | 545 | `SQLITE_IOERR_MMAP` – Memory‑mapped I/O failed. |

### Busy and Lock Errors

| Code | Name | Description |
|------|------|-------------|
| 5 | `SQLITE_BUSY` | Database is locked by another writer. |
| 5 | `SQLITE_BUSY_RECOVERY` | Recovery process is running. |
| 5 | `SQLITE_BUSY_SNAPSHOT` | Snapshot is active (WAL). |
| 6 | `SQLITE_LOCKED` | A table is locked. |
| 6 | `SQLITE_LOCKED_SHAREDCACHE` | Shared cache lock. |

### Other Common Errors

| Code | Name | Description |
|------|------|-------------|
| 14 | `SQLITE_CANTOPEN` | Cannot open database. |
| 14 | `SQLITE_CANTOPEN_ISDIR` | Path is a directory, not a file. |
| 14 | `SQLITE_CANTOPEN_FULLPATH` | Full path cannot be resolved. |
| 21 | `SQLITE_MISUSE` | Library used incorrectly (e.g., `sqlite3_prepare` after `sqlite3_close`). |

---

## 3. Error Handling in Different Programming Languages

### Python (`sqlite3`)

**Catching exceptions:**

```python
import sqlite3

try:
    conn = sqlite3.connect('mydb.db')
    cursor = conn.execute("INSERT INTO users (name) VALUES (?)", ("Alice",))
    conn.commit()
except sqlite3.IntegrityError as e:
    print(f"Constraint violation: {e}")
except sqlite3.OperationalError as e:
    print(f"Operational error (e.g., locked, disk full): {e}")
except sqlite3.DatabaseError as e:
    print(f"General database error: {e}")
except sqlite3.Error as e:
    print(f"Other SQLite error: {e}")
finally:
    conn.close()
```

**Handling SQLITE_BUSY with busy_timeout:**

```python
conn = sqlite3.connect('mydb.db')
conn.execute("PRAGMA busy_timeout = 5000")
```

**Custom busy handler:**

```python
def busy_handler(attempts):
    print(f"Busy, retrying... attempt {attempts}")
    return True  # Return True to keep retrying, False to abort

conn.set_busy_handler(busy_handler)
```

---

### JavaScript (Node.js with `sqlite3`)

```javascript
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('mydb.db');

db.run("INSERT INTO users (name) VALUES (?)", "Alice", function(err) {
    if (err) {
        if (err.code === 'SQLITE_CONSTRAINT_UNIQUE') {
            console.log('Duplicate entry');
        } else if (err.code === 'SQLITE_BUSY') {
            console.log('Database is busy, retry later');
        } else {
            console.error('Error:', err.message);
        }
    } else {
        console.log(`Inserted row ID: ${this.lastID}`);
    }
});
```

**Busy timeout in Node.js:**

```javascript
db.configure('busyTimeout', 5000);  // 5 seconds
```

---

### Java (JDBC with SQLite)

```java
import java.sql.*;

try {
    Connection conn = DriverManager.getConnection("jdbc:sqlite:mydb.db");
    PreparedStatement pstmt = conn.prepareStatement("INSERT INTO users (name) VALUES (?)");
    pstmt.setString(1, "Alice");
    pstmt.executeUpdate();
} catch (SQLException e) {
    if (e.getErrorCode() == 19) {  // SQLITE_CONSTRAINT
        System.out.println("Constraint violation");
    } else if (e.getErrorCode() == 5) {  // SQLITE_BUSY
        System.out.println("Database busy");
    } else {
        System.out.println("Error: " + e.getMessage());
    }
}
```

**Busy timeout in JDBC:**

```java
Statement stmt = conn.createStatement();
stmt.execute("PRAGMA busy_timeout = 5000");
```

---

### C# (.NET with `Microsoft.Data.Sqlite`)

```csharp
using Microsoft.Data.Sqlite;

try {
    using var connection = new SqliteConnection("Data Source=mydb.db");
    connection.Open();
    var command = connection.CreateCommand();
    command.CommandText = "INSERT INTO users (name) VALUES (@name)";
    command.Parameters.AddWithValue("@name", "Alice");
    command.ExecuteNonQuery();
} catch (SqliteException ex) {
    if (ex.SqliteErrorCode == 19) {
        Console.WriteLine("Constraint violation");
    } else if (ex.SqliteErrorCode == 5) {
        Console.WriteLine("Database busy");
    } else {
        Console.WriteLine($"Error: {ex.Message}");
    }
}
```

**Busy timeout:**

```csharp
connection.Execute("PRAGMA busy_timeout = 5000");
```

---

## 4. Common Error Scenarios and Solutions

### Scenario 1: SQLITE_BUSY (Database Locked)

**Cause:** Another connection holds an exclusive lock (or WAL checkpoint is running).

**Solutions:**
- Set `PRAGMA busy_timeout` to a reasonable value (e.g., 5000 ms).
- Implement retry logic with exponential backoff.
- If using WAL, reduce `wal_autocheckpoint` to shorten locks.
- Avoid long‑running transactions; commit frequently.

**Retry pattern example (Python):**

```python
import time
import sqlite3

def execute_with_retry(cursor, sql, params, retries=5, delay=0.1):
    for attempt in range(retries):
        try:
            cursor.execute(sql, params)
            return
        except sqlite3.OperationalError as e:
            if "database is locked" in str(e) and attempt < retries - 1:
                time.sleep(delay * (2 ** attempt))  # exponential backoff
                continue
            raise
```

---

### Scenario 2: SQLITE_CONSTRAINT_UNIQUE (Duplicate Key)

**Cause:** Inserting a value that violates a `UNIQUE` constraint or primary key.

**Solutions:**
- Use `INSERT OR IGNORE` to skip duplicates silently.
- Use `INSERT OR REPLACE` to overwrite.
- Check for existence before inserting:

```sql
INSERT INTO users (email, name)
SELECT 'alice@example.com', 'Alice'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'alice@example.com');
```

---

### Scenario 3: SQLITE_CORRUPT

**Cause:** Database file is corrupted (hardware failure, incomplete write, etc.).

**Solutions:**
- Restore from backup.
- Try `.dump` and re‑import.
- Use the `recover` extension to salvage data.
- Enable `PRAGMA synchronous = FULL` and `journal_mode = WAL` to prevent future corruption.

**Recovery attempt:**

```bash
sqlite3 corrupt.db ".dump" > dump.sql
sqlite3 recovered.db < dump.sql
```

---

### Scenario 4: SQLITE_SCHEMA

**Cause:** The schema was altered after a prepared statement was created.

**Solutions:**
- SQLite automatically reprepares the statement on `sqlite3_step`, so this is usually transient.
- In code, catch the error and retry (it will succeed after re‑preparation).

---

### Scenario 5: SQLITE_FULL (Disk Full)

**Cause:** The disk where the database resides is full.

**Solutions:**
- Free disk space.
- Enable `auto_vacuum` to reclaim space.
- Use `VACUUM` to compact the database.
- Archive or delete old data.

---

## 5. Error Handling Best Practices

1. **Always check return codes** – In C/C++, check every `sqlite3_*` call.
2. **Use extended error codes** – For more detailed diagnostics, enable extended error codes:
   ```sql
   sqlite3_extended_result_codes(db, 1);
   ```
3. **Log errors** – Always log the error message (`sqlite3_errmsg()`) to aid debugging.
4. **Set a busy timeout** – Prevents `SQLITE_BUSY` from crashing your application.
5. **Retry transient errors** – `SQLITE_BUSY`, `SQLITE_LOCKED`, `SQLITE_SCHEMA` are transient; retry with backoff.
6. **Use transactions** – Wrap related operations in a transaction for atomicity and to reduce locks.
7. **Validate user input** – Prevent `SQLITE_CONSTRAINT` by sanitizing/validating data before insertion.
8. **Monitor disk space** – Prevent `SQLITE_FULL` by monitoring available space.

---

## 6. Quick Reference: Error Codes by Severity

| Severity | Codes |
|----------|-------|
| **Retryable** | `SQLITE_BUSY`, `SQLITE_LOCKED`, `SQLITE_SCHEMA`, `SQLITE_INTERRUPT` |
| **User‑fixable** | `SQLITE_CONSTRAINT_*`, `SQLITE_MISMATCH`, `SQLITE_READONLY`, `SQLITE_FULL`, `SQLITE_TOOBIG` |
| **Fatal** | `SQLITE_CORRUPT`, `SQLITE_CANTOPEN`, `SQLITE_NOMEM`, `SQLITE_IOERR_*` |

---

This appendix equips you to handle SQLite errors effectively across all programming environments. Proper error handling is the hallmark of robust, production‑grade applications.
