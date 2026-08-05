# Backup, Maintenance, and Production Deployment Primer 8: Keeping Your Database Safe in the Wild

You've built your database, secured it, and written your application. Now it's time to put it into production. But production isn't just about deploying—it's about **ongoing care**. This primer covers the essentials of backing up your data, performing routine maintenance, and deploying SQLite in production environments.

---

## 1. Why Backup and Maintenance Matter

Databases are precious. Hardware fails, disks fill up, and humans make mistakes. Without a backup strategy, you're one accident away from disaster.

**Maintenance** keeps your database fast and healthy: compacting fragmented files, updating statistics, and checking for corruption. Think of it as taking your car in for regular service.

---

## 2. Backup Strategies

### Hot Backup (Online Backup)
You can back up SQLite while it's running. The `.backup` command uses the **Online Backup API** to create a consistent copy without locking other users.

```bash
sqlite3 mydb.db ".backup backup.db"
```

In Python:
```python
import sqlite3

def backup_db(source, target):
    with sqlite3.connect(source) as src:
        with sqlite3.connect(target) as dst:
            src.backup(dst)
```

### Cold Backup (Offline)
If your application isn't using the database (or if you can afford a brief downtime), you can simply copy the file.

```bash
cp mydb.db backup.db
```

**Pros:** Simple, fast. **Cons:** The application must be stopped (or at least not writing).

### Dump and Restore
Export your database as SQL statements, then recreate it later.

```bash
sqlite3 mydb.db ".dump" > dump.sql
sqlite3 restored.db < dump.sql
```

**Pros:** Portable; can be edited; human‑readable. **Cons:** Slow for large databases; doesn't preserve file‑level settings (like WAL mode).

### Incremental Backup
SQLite doesn't have built‑in incremental backup, but you can implement it by:
1. Taking a full backup daily.
2. Saving the WAL file (if in WAL mode) and replaying it later.

### Backup Frequency

| Type | Frequency | Retention |
|------|-----------|-----------|
| Full backup | Daily (or hourly for critical apps) | 7‑30 days |
| Dump | Weekly (for version control) | 1‑3 months |
| WAL archiving | Continuous (if using WAL) | Until next full backup |

---

## 3. Backup Automation Script (Python)

```python
# backup.py
import sqlite3
import os
import shutil
from datetime import datetime

DB_PATH = "mydb.db"
BACKUP_DIR = "backups"

def backup():
    os.makedirs(BACKUP_DIR, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = os.path.join(BACKUP_DIR, f"mydb_{timestamp}.db")
    
    # Online backup
    with sqlite3.connect(DB_PATH) as src:
        with sqlite3.connect(backup_file) as dst:
            src.backup(dst)
    
    print(f"Backup created: {backup_file}")
    
    # Keep only last 7 backups
    backups = sorted([f for f in os.listdir(BACKUP_DIR) if f.startswith("mydb_")])
    while len(backups) > 7:
        os.remove(os.path.join(BACKUP_DIR, backups.pop(0)))
        print(f"Removed old backup: {backups[-1]}")

if __name__ == "__main__":
    backup()
```

Schedule this with `cron` (Linux) or Task Scheduler (Windows).

---

## 4. Restore Strategies

### Restore from Backup File
```bash
# Stop application, then copy backup over live file
cp backup.db mydb.db
```

### Restore from Dump
```bash
sqlite3 mydb.db < dump.sql
```

### Partial Restore (using `.import`)
If only one table is corrupted:
```bash
sqlite3 backup.db ".dump users" > users.sql
sqlite3 mydb.db < users.sql
```

**Always test your restore** in a staging environment. A backup is only as good as your ability to restore it.

---

## 5. Maintenance Tasks

### VACUUM (Compacting)
`VACUUM` rebuilds the database file, defragmenting it and reclaiming unused space.

```sql
VACUUM;
```

- **When to run:** After large deletes or when the file size is much larger than the data.
- **Warning:** Requires free disk space equal to the current database size. Can be slow; run during maintenance windows.

### Auto‑Vacuum
Enable `auto_vacuum` to reclaim space automatically.

```sql
PRAGMA auto_vacuum = FULL;   -- or INCREMENTAL
```

`INCREMENTAL` spreads the work over time; `FULL` is more aggressive.

### ANALYZE (Update Statistics)
The query planner uses statistics. Update them after bulk changes.

```sql
ANALYZE;
```

### Integrity Check
Check for corruption.

```sql
PRAGMA integrity_check;
```

Should return `ok`. Anything else needs investigation.

### Foreign Key Check
```sql
PRAGMA foreign_key_check;
```

### WAL Checkpoint (if in WAL mode)
Manage WAL file growth.

```sql
PRAGMA wal_checkpoint(TRUNCATE);
```

---

## 6. Scheduled Maintenance Script

```bash
#!/bin/bash
# maintenance.sh

DB_PATH="/data/mydb.db"
LOG_FILE="/var/log/db_maintenance.log"

echo "=== Maintenance started at $(date) ===" >> $LOG_FILE

# 1. Backup
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
sqlite3 $DB_PATH ".backup $BACKUP_DIR/mydb_$TIMESTAMP.db"
echo "Backup created: mydb_$TIMESTAMP.db" >> $LOG_FILE

# 2. Integrity check
RESULT=$(sqlite3 $DB_PATH "PRAGMA integrity_check;")
if [ "$RESULT" != "ok" ]; then
    echo "ERROR: Integrity check failed: $RESULT" >> $LOG_FILE
    # Send alert
else
    echo "Integrity check passed." >> $LOG_FILE
fi

# 3. Analyze
sqlite3 $DB_PATH "ANALYZE;"
echo "ANALYZE completed." >> $LOG_FILE

# 4. Checkpoint (if WAL)
JOURNAL_MODE=$(sqlite3 $DB_PATH "PRAGMA journal_mode;")
if [ "$JOURNAL_MODE" = "wal" ]; then
    sqlite3 $DB_PATH "PRAGMA wal_checkpoint(TRUNCATE);"
    echo "WAL checkpoint completed." >> $LOG_FILE
fi

# 5. Vacuum (weekly)
DAY=$(date +%u)  # 1=Monday ... 7=Sunday
if [ $DAY -eq 7 ]; then
    sqlite3 $DB_PATH "VACUUM;"
    echo "VACUUM completed." >> $LOG_FILE
fi

echo "=== Maintenance ended at $(date) ===" >> $LOG_FILE
```

---

## 7. Monitoring in Production

### Key Metrics to Watch

| Metric | Why | How to Check |
|--------|-----|--------------|
| **Database file size** | Growth indicates space needs | `ls -lh` or `PRAGMA page_count` |
| **WAL file size** | If > 100 MB, tune checkpoints | `ls -lh *.wal` |
| **Integrity** | Detect corruption early | `PRAGMA integrity_check` |
| **Number of rows** | Know your scale | `SELECT COUNT(*)` |
| **Query performance** | Detect slow queries | Application‑level monitoring |
| **Disk space** | Avoid `SQLITE_FULL` | System monitoring |

### Logging

Enable slow query logging in your application:

```python
import sqlite3
import logging
import time

logging.basicConfig(level=logging.INFO)

class SlowQueryLogger:
    def __call__(self, sql):
        logging.info(f"Slow query: {sql}")

conn = sqlite3.connect('mydb.db')
conn.set_profile(SlowQueryLogger())
```

---

## 8. Deployment Patterns

### Embedded Database (Most Common)
SQLite runs inside your application process.

- **Pros:** Simple, fast, no network.
- **Cons:** Cannot scale to high write concurrency (but WAL helps).
- **Use cases:** Mobile apps, desktop apps, small to medium web apps.

### Read‑Only Replicas
For analytics, you can have multiple read‑only copies of the database.

- **Setup:** Copy the database file to replica servers periodically.
- **Pros:** Scales reads infinitely.
- **Cons:** Stale data; not real‑time.

### Sharding
If your data is huge, split across multiple databases (e.g., per‑tenant).

- **Setup:** Each tenant gets their own `.db` file.
- **Pros:** Scales writes and reads; no single large file.
- **Cons:** More complex; cross‑shard queries are tricky.

### Containerization (Docker)

```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
ENV DB_PATH=/data/mydb.db
RUN mkdir -p /data
VOLUME /data
CMD ["python", "app.py"]
```

Run with persistent volume:
```bash
docker run -v /host/data:/data myapp
```

---

## 9. Production Checklist

Before going to production:

- [ ] **WAL mode enabled**: `PRAGMA journal_mode = WAL`
- [ ] **Synchronous set**: `PRAGMA synchronous = NORMAL` (or FULL)
- [ ] **Busy timeout set**: `PRAGMA busy_timeout = 5000`
- [ ] **Cache size tuned**: `PRAGMA cache_size = 20000` (or higher)
- [ ] **Foreign keys enabled**: `PRAGMA foreign_keys = ON`
- [ ] **Indexes added**: All foreign keys and frequent query columns
- [ ] **ANALYZE run**: After data loads
- [ ] **Backup strategy implemented**: Automated daily backups
- [ ] **Integrity checks scheduled**: Regularly monitor
- [ ] **VACUUM planned**: Weekly or monthly
- [ ] **Parameterized queries**: Everywhere (SQL injection prevention)
- [ ] **Encryption**: If sensitive data, use SQLCipher
- [ ] **Logging**: Enabled and monitored
- [ ] **Monitoring**: Database size, WAL growth, busy events
- [ ] **Migration strategy**: Versioned schema changes
- [ ] **Restore tested**: Restore from backup in a test environment
- [ ] **Disk space**: Adequate free space for VACUUM and growth

---

## 10. Quick Reference: Maintenance Commands

| Task | Command |
|------|---------|
| Full backup | `sqlite3 mydb.db ".backup backup.db"` |
| Dump | `sqlite3 mydb.db ".dump" > dump.sql` |
| Restore | `sqlite3 mydb.db < dump.sql` |
| Integrity check | `PRAGMA integrity_check;` |
| VACUUM | `VACUUM;` |
| ANALYZE | `ANALYZE;` |
| WAL checkpoint | `PRAGMA wal_checkpoint(TRUNCATE);` |
| Auto‑vacuum | `PRAGMA auto_vacuum = FULL;` |
| Secure delete | `PRAGMA secure_delete = ON;` |
| Set busy timeout | `PRAGMA busy_timeout = 5000;` |

---

## 11. Disaster Recovery Plan (DRP)

1. **Identify the incident** – corruption, disk failure, accidental delete.
2. **Stop the application** – prevent further writes.
3. **Restore from the latest backup** – follow restore procedure.
4. **Test the restored database** – `PRAGMA integrity_check`
5. **Restart the application** – monitor logs for errors.
6. **Investigate root cause** – prevent recurrence.
7. **Document the incident** – improve procedures.

---

## 12. Common Pitfalls and How to Avoid Them

| Pitfall | Solution |
|---------|----------|
| **Running VACUUM during peak hours** | Schedule during maintenance windows. |
| **Not testing backups** | Regularly restore to a test environment. |
| **Forgetting to set busy_timeout** | Application crashes on lock. |
| **Disk full** | Monitor disk space; set `auto_vacuum`. |
| **WAL file grows huge** | Tune `wal_autocheckpoint`; run checkpoints. |
| **Outdated statistics** | Run `ANALYZE` after bulk changes. |
| **No integrity checks** | Corruption goes undetected. |
| **Single point of failure** | Have backups and a restore plan. |

---

## Next Steps

- Learn about **schema migrations** (versioning your database).
- Explore **observability** (monitoring, logging, alerting).
- Dive into **scaling patterns** (sharding, replicas).
- Apply these concepts in the **Master SQLite** series.

---

**Your database is a critical asset. Treat it like one.** Backup regularly, maintain diligently, monitor constantly, and always have a recovery plan. With these practices, you'll sleep better knowing your data is safe.

Stay operational!
