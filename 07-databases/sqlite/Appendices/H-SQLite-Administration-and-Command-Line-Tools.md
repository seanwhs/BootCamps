# Appendix H: SQLite Administration and Command-Line Tools

SQLite comes with a suite of command-line tools that go beyond the interactive shell. These utilities are essential for database administration, backup, recovery, performance analysis, and development workflows. This appendix covers the most important tools and their usage patterns.

---

## 1. The SQLite Command-Line Shell (`sqlite3`)

We've already covered the interactive shell extensively, but it's worth summarizing its administrative capabilities.

### Key Administrative Features

| Feature | Command | Example |
|---------|---------|---------|
| **Non-interactive execution** | `sqlite3 db.db "SQL"` | `sqlite3 mydb.db "SELECT * FROM users"` |
| **Execute script file** | `sqlite3 db.db < script.sql` | `sqlite3 mydb.db < migration.sql` |
| **Backup** | `.backup` | `.backup backup.db` |
| **Restore** | `.restore` | `.restore backup.db` |
| **Dump** | `.dump` | `.dump users > users.sql` |
| **Import CSV** | `.import` | `.import data.csv mytable` |
| **Export CSV** | `.mode csv` + `.once` | `.mode csv; .once out.csv; SELECT * FROM mytable` |
| **Batch mode** | `.mode batch` | For script output with no formatting. |
| **Quiet mode** | `-quiet` flag | `sqlite3 -quiet mydb.db < script.sql` |

### Administrative Use Cases

**Checking database integrity:**
```bash
sqlite3 mydb.db "PRAGMA integrity_check;"
```

**Checking foreign keys:**
```bash
sqlite3 mydb.db "PRAGMA foreign_key_check;"
```

**Getting database info:**
```bash
sqlite3 mydb.db ".dbinfo"
```

**Vacuuming (compacting) the database:**
```bash
sqlite3 mydb.db "VACUUM;"
```

**Analyzing (updating statistics):**
```bash
sqlite3 mydb.db "ANALYZE;"
```

**Running a transaction from the command line:**
```bash
sqlite3 mydb.db "BEGIN; INSERT INTO users (name) VALUES ('Alice'); COMMIT;"
```

---

## 2. Backup Tools

### Online Backup via `.backup`

The `.backup` command uses the Online Backup API to create a consistent backup while the database is in use.

```bash
sqlite3 mydb.db ".backup backup.db"
```

**Restoring:**
```bash
sqlite3 mydb.db ".restore backup.db"
```

**Backup with a timestamp:**
```bash
timestamp=$(date +%Y%m%d_%H%M%S)
sqlite3 mydb.db ".backup backups/mydb_$timestamp.db"
```

### Using the Backup API Programmatically

In Python:
```python
import sqlite3

def backup_db(source, target):
    with sqlite3.connect(source) as src:
        with sqlite3.connect(target) as dst:
            src.backup(dst)
```

---

## 3. SQLite Archiver (`sqlar`)

SQLite includes a **SQLite Archiver** (`sqlar`) that uses SQLite as a file archive. You can store and retrieve files within a SQLite database using a virtual table.

**Create an archive:**
```bash
sqlite3 archive.db "CREATE VIRTUAL TABLE files USING sqlar"
```

**Add files to archive:**
```bash
sqlite3 archive.db "INSERT INTO files(name, data) VALUES('myfile.txt', readfile('myfile.txt'))"
```

**Extract a file:**
```bash
sqlite3 archive.db "SELECT writefile('myfile.txt', data) FROM files WHERE name='myfile.txt'"
```

**Note:** The `sqlar` extension may not be built into all SQLite distributions.

---

## 4. Performance Analysis Tools

### `sqlite3_analyzer` (Linux/macOS)

`sqlite3_analyzer` is a separate utility that provides detailed statistics about a database's storage efficiency, fragmentation, and page utilization.

**Usage:**
```bash
sqlite3_analyzer mydb.db
```

**Output example:**
```
Pages by type:
  Total pages: 1234
  Table B-Tree pages: 800
  Index B-Tree pages: 400
  Overflow pages: 34

Space usage:
  Total bytes: 5,054,464
  Unused bytes: 1,200,123 (23.7%)
  Unused bytes in free list: 500,000 (9.9%)
```

### `sqlite3_status` (Built-in)

You can query various runtime statistics using `PRAGMA status`.

```sql
-- Memory usage
PRAGMA memory_used;
PRAGMA memory_highwater;

-- Page cache hits/misses
PRAGMA cache_used;
PRAGMA cache_hit;

-- WAL statistics (if in WAL mode)
PRAGMA wal_checkpoint;
```

---

## 5. Database Schema Diff Tools

### Schema Dump and Diff

You can compare two database schemas by dumping them and using `diff`.

```bash
sqlite3 old.db ".schema" > old_schema.sql
sqlite3 new.db ".schema" > new_schema.sql
diff -u old_schema.sql new_schema.sql
```

For a more sophisticated diff, use the `sqldiff` utility (if available).

---

## 6. `sqldiff` – Database Diff Tool

`sqldiff` is a utility that compares two SQLite databases and shows the differences in schema and data.

**Usage:**
```bash
sqldiff old.db new.db
```

**Output example:**
```
--- /path/to/old.db
+++ /path/to/new.db
-
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
+ALTER TABLE users ADD COLUMN email TEXT;
-
-INSERT INTO users VALUES (1, 'Alice');
+INSERT INTO users VALUES (1, 'Alice', 'alice@example.com');
```

`sqldiff` is included with some SQLite distributions or can be compiled from source.

---

## 7. `sqlite3_analyzer` Storage Analysis

We already covered this, but it deserves a detailed example:

```bash
sqlite3_analyzer mydb.db
```

Look for:
- **Fragmentation:** High unused bytes percentage indicates fragmentation.
- **Page utilization:** Low utilization (e.g., pages half‑full) suggests you can reduce page size or run `VACUUM`.
- **Free list:** A large free list indicates that `VACUUM` is needed.

---

## 8. `SQLITE_DEBUG` and Tracing

When you compile SQLite with `-DSQLITE_DEBUG`, you can enable extra diagnostics.

### Enable SQL Tracing

```bash
sqlite3 mydb.db ".trace stdout"
```

Or programmatically:
```python
conn = sqlite3.connect('mydb.db')
conn.set_trace_callback(lambda sql: print(f"SQL: {sql}"))
```

### Enable Profiling

```python
def profile_callback(query, elapsed):
    print(f"{query} took {elapsed:.3f}s")

conn.set_profile(profile_callback)
```

---

## 9. `sqlite3` CLI as an ETL Tool

You can use the CLI for Extract‑Transform‑Load operations.

**Export data to CSV:**
```bash
sqlite3 mydb.db <<EOF
.headers on
.mode csv
.output data.csv
SELECT * FROM mytable;
EOF
```

**Import data from CSV:**
```bash
sqlite3 mydb.db <<EOF
.mode csv
.import data.csv mytable
EOF
```

**Export to JSON:**
```bash
sqlite3 mydb.db <<EOF
.mode json
.output data.json
SELECT * FROM mytable;
EOF
```

**Export to HTML:**
```bash
sqlite3 mydb.db <<EOF
.mode html
.output data.html
SELECT * FROM mytable;
EOF
```

---

## 10. Database File Utilities

### `sqlite3` File Check

Check if a file is a valid SQLite database:
```bash
sqlite3 mydb.db "PRAGMA integrity_check;"
```

If it returns `ok`, the file is a valid database (or at least not corrupt).

### File Size Management

Check file size and growth:
```bash
ls -lh mydb.db
du -h mydb.db
```

Monitor WAL file growth:
```bash
watch -n 60 "ls -lh mydb.db*"
```

---

## 11. Creating a New Database from a Schema Script

```bash
sqlite3 new.db < schema.sql
```

Where `schema.sql` contains `CREATE TABLE`, `CREATE INDEX`, etc.

### Seeding the Database from a Dump

```bash
sqlite3 new.db < dump.sql
```

---

## 12. Automated Maintenance Scripts

### Shell Script for Daily Backups

```bash
#!/bin/bash
# daily_backup.sh
DB_PATH="/data/mydb.db"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/mydb_$DATE.db"

sqlite3 $DB_PATH ".backup $BACKUP_FILE"

# Keep last 7 backups
ls -t $BACKUP_DIR/mydb_*.db | tail -n +8 | xargs -r rm

echo "Backup completed: $BACKUP_FILE"
```

### Shell Script for Integrity Check

```bash
#!/bin/bash
# check_integrity.sh
DB_PATH="/data/mydb.db"
LOG_FILE="/var/log/db_integrity.log"

RESULT=$(sqlite3 $DB_PATH "PRAGMA integrity_check;")
if [ "$RESULT" != "ok" ]; then
    echo "$(date): INTEGRITY CHECK FAILED: $RESULT" >> $LOG_FILE
    # Send alert
    echo "Database integrity check failed!" | mail -s "DB Alert" admin@example.com
else
    echo "$(date): Integrity check passed." >> $LOG_FILE
fi
```

### Shell Script for VACUUM

```bash
#!/bin/bash
# vacuum.sh
DB_PATH="/data/mydb.db"
LOG_FILE="/var/log/db_vacuum.log"

SIZE_BEFORE=$(stat -c%s $DB_PATH)
sqlite3 $DB_PATH "VACUUM;"
SIZE_AFTER=$(stat -c%s $DB_PATH)

echo "$(date): VACUUM completed. Size: $SIZE_BEFORE -> $SIZE_AFTER bytes" >> $LOG_FILE
```

---

## 13. `cron` Schedule Example

```cron
# Daily backup at 2:00 AM
0 2 * * * /scripts/daily_backup.sh

# Integrity check every hour
0 * * * * /scripts/check_integrity.sh

# Weekly VACUUM on Sunday at 3:00 AM
0 3 * * 0 /scripts/vacuum.sh
```

---

## 14. Quick Reference: Top Administrative Commands

| Task | Command |
|------|---------|
| **Open database** | `sqlite3 mydb.db` |
| **Run SQL** | `sqlite3 mydb.db "SELECT * FROM users"` |
| **Backup** | `sqlite3 mydb.db ".backup backup.db"` |
| **Restore** | `sqlite3 mydb.db ".restore backup.db"` |
| **Dump schema** | `sqlite3 mydb.db ".schema" > schema.sql` |
| **Dump data** | `sqlite3 mydb.db ".dump" > dump.sql` |
| **Import CSV** | `sqlite3 mydb.db ".mode csv" ".import data.csv mytable"` |
| **Export CSV** | `sqlite3 mydb.db ".mode csv" ".output out.csv" "SELECT * FROM mytable"` |
| **Integrity check** | `sqlite3 mydb.db "PRAGMA integrity_check"` |
| **Vacuum** | `sqlite3 mydb.db "VACUUM"` |
| **Analyze** | `sqlite3 mydb.db "ANALYZE"` |
| **Get DB info** | `sqlite3 mydb.db ".dbinfo"` |
| **List tables** | `sqlite3 mydb.db ".tables"` |
| **Schema of a table** | `sqlite3 mydb.db ".schema mytable"` |

---

This appendix equips you with the essential command-line tools and scripts for maintaining SQLite databases in production. Use these utilities to automate backups, monitor integrity, optimize performance, and manage your data effectively.
