# Primer 2: Understanding PostgreSQL Architecture

Welcome to the second primer! This primer is designed for readers who want to understand how PostgreSQL works under the hood. While you can use PostgreSQL effectively without knowing its internals, understanding its architecture helps you write better queries, optimize performance, and troubleshoot issues more effectively.

Think of this as looking under the hood of a car—you don't need to know how an engine works to drive, but knowing the basics helps you maintain the car and fix problems when they arise.

---

## P2.1 PostgreSQL Architecture Overview

### The Target
Understand the high-level architecture of PostgreSQL and how its components work together.

### The Concept
PostgreSQL follows a client-server architecture. When you run a SQL query, it travels through several layers before returning results. Understanding this flow helps you diagnose performance issues and understand why certain operations behave the way they do.

### The Implementation

**PostgreSQL Architecture at a Glance:**

```
                    ┌─────────────────────────────────────────┐
                    │            CLIENT APPLICATIONS          │
                    │  (psql, pgAdmin, Application Servers)   │
                    └───────────────┬─────────────────────────┘
                                    │ Network Connection
                                    ▼
                    ┌─────────────────────────────────────────┐
                    │           POSTGRESQL SERVER             │
                    │                                        │
                    │  ┌──────────────────────────────────┐   │
                    │  │         Connection Manager       │   │
                    │  │    (Accepts client connections)  │   │
                    │  └───────────────┬──────────────────┘   │
                    │                  │                       │
                    │  ┌───────────────▼──────────────────┐   │
                    │  │        Process/Thread Pool       │   │
                    │  │   (One process per connection)   │   │
                    │  └───────────────┬──────────────────┘   │
                    │                  │                       │
                    │  ┌───────────────▼──────────────────┐   │
                    │  │        Query Parser & Planner    │   │
                    │  │   (Parses and optimizes queries) │   │
                    │  └───────────────┬──────────────────┘   │
                    │                  │                       │
                    │  ┌───────────────▼──────────────────┐   │
                    │  │        Executor & Cache          │   │
                    │  │  (Executes queries, caches data) │   │
                    │  └───────────────┬──────────────────┘   │
                    │                  │                       │
                    │  ┌───────────────▼──────────────────┐   │
                    │  │          Storage System          │   │
                    │  │     (Data files, WAL, indexes)   │   │
                    │  └──────────────────────────────────┘   │
                    └─────────────────────────────────────────┘
```

**The Journey of a SQL Query:**

1. **Client sends query**: Your application or tool sends SQL to PostgreSQL
2. **Connection Manager**: Accepts the connection and assigns a process
3. **Query Parser**: Checks the SQL syntax and converts it to an internal format
4. **Query Planner**: Determines the most efficient way to execute the query
5. **Executor**: Runs the plan and retrieves data from storage
6. **Cache**: Keeps frequently used data in memory for speed
7. **Storage**: Reads from or writes to disk
8. **Results**: Return the data to the client

```sql
-- You can see the query plan in action
-- This shows you how PostgreSQL plans to execute your query

-- Turn on query planning display
EXPLAIN SELECT * FROM employees WHERE department = 'Engineering';

-- This shows the execution plan without running it
-- Result will look something like:
-- Seq Scan on employees  (cost=0.00..23.10 rows=3 width=72)
--   Filter: (department = 'Engineering'::text)

-- To actually run the query and show the plan:
EXPLAIN ANALYZE SELECT * FROM employees WHERE department = 'Engineering';
-- This runs the query and shows you the actual execution statistics
```

### The Verification

```bash
# Check PostgreSQL version and architecture
psql -d ecommerce -c "SELECT version();"

# See active connections
psql -d ecommerce -c "SELECT pid, usename, application_name, client_addr, state FROM pg_stat_activity;"

# Check if PostgreSQL is using processes or threads (Linux)
ps aux | grep postgres
# Should show multiple postgres processes
```

---

## P2.2 The PostgreSQL Process Model

### The Target
Understand how PostgreSQL uses processes to handle connections and queries.

### The Concept
PostgreSQL uses a process-per-connection model (fork-based). Each client connection gets its own operating system process. This is different from thread-based databases like MySQL. The process model provides better isolation but uses more memory.

### The Implementation

**PostgreSQL Process Types:**

```
┌────────────────────────────────────────────────────────────┐
│                    POSTGRESQL PROCESSES                    │
├────────────────────────────────────────────────────────────┤
│  Postmaster (Main Process)                                │
│  ├─ Background Writer                                     │
│  ├─ WAL Writer                                            │
│  ├─ Autovacuum Workers                                    │
│  ├─ Statistics Collector                                  │
│  ├─ Logging Process                                       │
│  ├─ Checkpointer                                          │
│  └─ Client Processes (One per connection)                 │
│      ├─ Connection 1 (User: alice, Query: SELECT...)     │
│      ├─ Connection 2 (User: bob, Query: INSERT...)       │
│      ├─ Connection 3 (User: charlie, Query: UPDATE...)   │
│      └─ ...                                               │
└────────────────────────────────────────────────────────────┘
```

```sql
-- See all PostgreSQL processes
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    backend_type,
    state,
    query
FROM pg_stat_activity
ORDER BY pid;

-- Explanation of key columns:
-- pid: Process ID on the operating system
-- usename: User who initiated the connection
-- backend_type: Type of process (client backend, autovacuum, etc.)
-- state: What the process is doing (active, idle, idle in transaction)

-- Monitor memory usage per process
SELECT 
    pid,
    usename,
    state,
    pg_size_pretty(pg_backend_memory_contexts()::TEXT) AS memory_usage
FROM pg_stat_activity
WHERE state = 'active';

-- See which queries are taking the most time
SELECT 
    pid,
    usename,
    now() - query_start AS duration,
    query
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY duration DESC;
```

### The Verification

```bash
# View PostgreSQL processes from the OS
ps aux | grep postgres | grep -v grep

# On Linux, you might see output like:
# postgres  1234  0.1  2.5  /usr/lib/postgresql/16/bin/postgres
# postgres  5678  0.0  1.2  postgres: alice ecommerce 127.0.0.1 idle
# postgres  9012  0.5  1.8  postgres: bob ecommerce 127.0.0.1 active SELECT

# Count connections to your database
psql -d ecommerce -c "SELECT COUNT(*) FROM pg_stat_activity WHERE datname = 'ecommerce';"
```

---

## P2.3 Memory Architecture

### The Target
Understand how PostgreSQL uses memory for caching and query processing.

### The Concept
PostgreSQL uses several memory areas to improve performance. The most important are shared buffers (cached data pages), work memory (sorting and joins), and maintenance work memory (VACUUM, indexes). Think of these as different types of workspace in a kitchen.

### The Implementation

**PostgreSQL Memory Areas:**

```
┌─────────────────────────────────────────────────────────────┐
│                    POSTGRESQL MEMORY                       │
├─────────────────────────────────────────────────────────────┤
│  Shared Memory (Shared by all processes)                  │
│  ├─ Shared Buffers (cached data pages)                    │
│  │   └─ 25% of RAM default, stores frequently used data   │
│  ├─ WAL Buffers (transaction log cache)                   │
│  │   └─ 16MB default, buffers WAL writes                 │
│  └─ Commit Log (transaction status)                       │
│                                                           │
│  Local Memory (Per process)                               │
│  ├─ Work Mem (sorting, hash joins, aggregations)         │
│  │   └─ 4MB default per operation                         │
│  ├─ Maintenance Work Mem (VACUUM, CREATE INDEX)          │
│  │   └─ 64MB default                                      │
│  └─ Temp Buffers (temporary tables)                       │
└─────────────────────────────────────────────────────────────┘
```

```sql
-- Check current memory settings
SELECT name, setting, unit 
FROM pg_settings 
WHERE name IN (
    'shared_buffers',
    'work_mem',
    'maintenance_work_mem',
    'wal_buffers',
    'temp_buffers'
)
ORDER BY name;

-- Explanation of settings:
-- shared_buffers: Main data cache, typically 25% of total RAM
-- work_mem: Memory per sort/hash operation (can be multiplied by concurrent operations)
-- maintenance_work_mem: Memory for maintenance operations (VACUUM, index creation)
-- wal_buffers: Memory for transaction log buffering

-- View current memory usage
SELECT 
    pid,
    usename,
    state,
    pg_size_pretty(pg_shared_memory_size() / 1024) AS shared_memory_usage
FROM pg_stat_activity
WHERE state = 'active';

-- See cache hit ratio (how often data is found in memory vs needing disk)
SELECT 
    'cache_hit_ratio' AS metric,
    ROUND(100 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0), 2) AS hit_ratio_pct
FROM pg_statio_user_tables;

-- A hit ratio above 95% is considered good
-- Below 90% suggests you need more memory or better indexes
```

### The Verification

```bash
# Check cache hit ratio
psql -d ecommerce -c "
SELECT 
    ROUND(100 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0), 2) AS cache_hit_ratio
FROM pg_statio_user_tables;"

# Check memory settings
psql -d ecommerce -c "
SELECT 
    name,
    setting,
    CASE 
        WHEN name = 'shared_buffers' THEN pg_size_pretty(setting::int * 8192)
        ELSE setting || ' ' || unit
    END AS human_readable
FROM pg_settings 
WHERE name IN ('shared_buffers', 'work_mem', 'maintenance_work_mem');"

# Monitor memory usage over time
psql -d ecommerce -c "
SELECT 
    current_setting('shared_buffers') AS shared_buffers,
    (SELECT pg_size_pretty(SUM(shared_blks_hit * 8192)::bigint) FROM pg_stat_user_tables) AS data_in_cache;"
```

---

## P2.4 The Storage System

### The Target
Understand how PostgreSQL stores data on disk.

### The Concept
PostgreSQL stores data in files on the filesystem. Each table is split into 8KB pages (blocks). Understanding this storage model helps you understand why certain operations are expensive and how to optimize storage.

### The Implementation

**Storage Hierarchy:**

```
DATABASE CLUSTER (/var/lib/postgresql/16/main/)
│
├── base/                    # Database files
│   ├── 12345/               # Database OID (Object ID)
│   │   ├── 12345.1          # Table file (relfilenode)
│   │   ├── 12345.2          # Index file
│   │   ├── 12345.3          # TOAST file (large data)
│   │   └── 12345_fsm        # Free space map
│   └── 12346/               # Another database
│
├── global/                   # Global system tables
│   ├── pg_database
│   ├── pg_authid
│   └── ...
│
├── pg_wal/                   # Write-Ahead Log (transaction log)
│   ├── 000000010000000000000001
│   └── 000000010000000000000002
│
└── pg_xact/                  # Transaction commit status
```

```sql
-- See database file locations
SELECT 
    datname,
    pg_database_size(datname) AS size_bytes,
    pg_size_pretty(pg_database_size(datname)) AS size_pretty
FROM pg_database
ORDER BY pg_database_size(datname) DESC;

-- See table file sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- See which table has the most bloat (wasted space)
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    ROUND(100 * (pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) / NULLIF(pg_total_relation_size(schemaname||'.'||tablename), 0), 2) AS bloat_pct
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY bloat_pct DESC;

-- See TOAST table usage (for large data)
-- PostgreSQL uses TOAST for large fields (like TEXT with large content)
SELECT 
    relname,
    reltoastrelid::regclass AS toast_table,
    pg_size_pretty(pg_total_relation_size(reltoastrelid)) AS toast_size
FROM pg_class
WHERE relkind = 'r'
  AND reltoastrelid != 0
ORDER BY pg_total_relation_size(reltoastrelid) DESC;
```

### The Verification

```bash
# Find the actual database files on disk
# This command shows you where PostgreSQL stores your data

# On Ubuntu/Debian
sudo ls -la /var/lib/postgresql/*/main/base/

# On macOS (Homebrew)
ls -la /opt/homebrew/var/postgresql@16/postgresql_data/base/

# Check WAL (transaction log) usage
psql -d ecommerce -c "
SELECT 
    pg_wal_lsn_diff(pg_current_wal_flush_lsn(), '0/0') AS wal_total_bytes,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_flush_lsn(), '0/0')) AS wal_total_pretty;"
```

---

## P2.5 The Query Processing Pipeline

### The Target
Understand how PostgreSQL processes a SQL query from start to finish.

### The Concept
When you submit a query, it goes through several stages: parsing, rewriting, planning, and execution. Each stage transforms the query until it becomes an executable plan. Understanding this pipeline helps you write better queries and understand performance issues.

### The Implementation

**Query Processing Pipeline:**

```
1. PARSING
   ┌──────────────────────────────────────────────────────────┐
   │ SQL: SELECT * FROM users WHERE age > 18                │
   └────────────┬─────────────────────────────────────────────┘
                ▼
   ┌──────────────────────────────────────────────────────────┐
   │ Syntax Check: "Is this valid SQL?"                      │
   │ Yes → Continue                                           │
   │ No → Return error                                        │
   └────────────┬─────────────────────────────────────────────┘
                ▼
   ┌──────────────────────────────────────────────────────────┐
   │ Parse Tree: Internal representation of the query        │
   │ (SELECT (all columns) FROM (users) WHERE (age > 18))   │
   └────────────┬─────────────────────────────────────────────┘

2. REWRITING
   ┌──────────────────────────────────────────────────────────┐
   │ Rule System: Apply any rules or views                   │
   │ (If "users" is a view, expand it)                       │
   └────────────┬─────────────────────────────────────────────┘
                ▼

3. PLANNING
   ┌──────────────────────────────────────────────────────────┐
   │ Query Planner: "What's the fastest way?"               │
   │ Options:                                                │
   │ - Seq Scan on users (all rows)                         │
   │ - Index Scan on users_age_idx (filtered)               │
   └────────────┬─────────────────────────────────────────────┘
                ▼
   ┌──────────────────────────────────────────────────────────┐
   │ Plan: Choose the most efficient option                  │
   │ "Index Scan on users_age_idx (cost=0.28..8.30)"        │
   └────────────┬─────────────────────────────────────────────┘

4. EXECUTION
   ┌──────────────────────────────────────────────────────────┐
   │ Executor: Run the plan and return results              │
   │ 1. Open index                                           │
   │ 2. Read matching rows                                   │
   │ 3. Return to client                                     │
   └──────────────────────────────────────────────────────────┘
```

```sql
-- See the full query plan with EXPLAIN
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM employees WHERE salary > 70000;

-- Explanation of the output:
-- Seq Scan on employees: Table scan (no index used)
-- Filter: (salary > 70000): Condition applied
-- Rows Removed by Filter: 5: Rows that didn't match
-- Buffers: shared hit=1: Data found in cache
-- Planning Time: 0.123 ms: Time to plan the query
-- Execution Time: 0.456 ms: Time to execute

-- See the plan in different formats
-- JSON format (easier to parse programmatically)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM employees WHERE salary > 70000;

-- YAML format
EXPLAIN (ANALYZE, BUFFERS, FORMAT YAML)
SELECT * FROM employees WHERE salary > 70000;

-- See the plan without actual execution
EXPLAIN (BUFFERS, FORMAT TEXT)
SELECT * FROM employees WHERE salary > 70000;

-- See query cost estimates
EXPLAIN (COSTS, FORMAT TEXT)
SELECT * FROM employees WHERE salary > 70000;
```

### The Verification

```bash
# Run EXPLAIN ANALYZE on a query
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 70000;"

# Look for:
# - Seq Scan (indicates no index)
# - Index Scan (indicates index used)
# - Execution Time (aim for < 100ms)
# - Buffers: shared hits (cached data)

# Compare different query patterns
# With index
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM employees WHERE id = 1;"

# Without index
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM employees WHERE first_name = 'Alice';"
```

---

## P2.6 The Write-Ahead Log (WAL)

### The Target
Understand the Write-Ahead Log and its role in durability and replication.

### The Concept
WAL (Write-Ahead Log) is PostgreSQL's transaction log. Think of it as a journal that records every change before it's written to the main data files. This ensures durability—if the system crashes, PostgreSQL can replay the WAL to recover.

### The Implementation

**How WAL Works:**

1. **Write**: When you update data, PostgreSQL first writes the change to the WAL
2. **Flush**: The WAL is flushed to disk (ensuring durability)
3. **Commit**: Transaction is marked as committed
4. **Background**: Later, changes are written to the main data files
5. **Checkpoint**: Point where all changes are written to data files

```
    Transaction              WAL                    Data Files
    ┌─────────┐           ┌───────────┐          ┌─────────────┐
    │ UPDATE  │──────────▶│  Record   │──────────▶│    OLD      │
    │ users   │           │  Change   │          │             │
    │ SET ... │           │           │          │    NEW      │
    └─────────┘           └───────────┘          └─────────────┘
         │                      │                        │
         │                      │                        │
         ▼                      ▼                        ▼
    COMMIT                 FLUSHED TO                CHECKPOINT
                           DISK                      WRITES TO
                                                     DISK
```

```sql
-- Check WAL settings
SELECT name, setting, unit 
FROM pg_settings 
WHERE name LIKE 'wal%' OR name LIKE '%checkpoint%'
ORDER BY name;

-- Key WAL settings:
-- wal_level: How much WAL data is written (replica, logical, minimal)
-- wal_buffers: Memory used for WAL buffering
-- wal_sync_method: How WAL is synced to disk (fdatasync, fsync, etc.)
-- checkpoint_timeout: How often checkpoints occur
-- max_wal_size: Maximum WAL size before checkpoint forced

-- View WAL statistics
SELECT 
    pg_wal_lsn_diff(pg_current_wal_insert_lsn(), '0/0') AS wal_insert_bytes,
    pg_wal_lsn_diff(pg_current_wal_flush_lsn(), '0/0') AS wal_flush_bytes,
    pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0') AS wal_read_bytes;

-- See WAL files in the pg_wal directory
SELECT 
    pg_ls_waldir() AS wal_files;

-- Checkpoint statistics
SELECT 
    checkpoints_timed,
    checkpoints_req,
    checkpoint_write_time,
    checkpoint_sync_time,
    buffers_checkpoint,
    buffers_clean,
    buffers_backend
FROM pg_stat_bgwriter;

-- See which WAL files are archived (if archiving is enabled)
-- SELECT * FROM pg_stat_archiver;
```

### The Verification

```bash
# Check WAL settings
psql -d ecommerce -c "
SELECT 
    name,
    setting,
    CASE 
        WHEN name = 'max_wal_size' THEN pg_size_pretty(setting::int * 1024 * 1024)
        ELSE setting
    END AS human_readable
FROM pg_settings 
WHERE name IN ('wal_level', 'wal_buffers', 'checkpoint_timeout', 'max_wal_size', 'wal_sync_method');"

# See WAL file count
psql -d ecommerce -c "SELECT COUNT(*) AS wal_files FROM pg_ls_waldir();"

# Check checkpoint activity
psql -d ecommerce -c "
SELECT 
    checkpoints_timed AS scheduled_checkpoints,
    checkpoints_req AS requested_checkpoints,
    checkpoint_write_time / 1000 AS checkpoint_write_sec,
    checkpoint_sync_time / 1000 AS checkpoint_sync_sec
FROM pg_stat_bgwriter;"
```

---

## P2.7 The Autovacuum Process

### The Target
Understand autovacuum and its role in maintaining database health.

### The Concept
PostgreSQL uses Multi-Version Concurrency Control (MVCC), which means old row versions stay in the table until cleaned up. Autovacuum automatically removes dead rows and updates statistics. Think of it as garbage collection for your database.

### The Implementation

**How Autovacuum Works:**

1. **Monitor**: PostgreSQL tracks how many dead tuples (old row versions) exist
2. **Trigger**: When a threshold is reached, autovacuum runs
3. **Cleanup**: Dead tuples are removed, space is freed
4. **Update**: Table statistics are updated for the query planner
5. **Prevent**: This prevents transaction ID wraparound

```sql
-- Check autovacuum settings
SELECT name, setting 
FROM pg_settings 
WHERE name LIKE 'autovacuum%'
ORDER BY name;

-- Key autovacuum settings:
-- autovacuum: On/off switch (should always be on)
-- autovacuum_naptime: How often autovacuum checks for work
-- autovacuum_vacuum_threshold: Number of dead tuples before vacuuming
-- autovacuum_vacuum_scale_factor: Percentage of table that must be dead

-- See autovacuum activity
SELECT 
    schemaname,
    tablename,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    n_dead_tup,
    n_live_tup,
    ROUND(100 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0)::NUMERIC, 2) AS dead_tuple_pct
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY dead_tuple_pct DESC;

-- Tables that haven't been vacuumed recently
SELECT 
    schemaname,
    tablename,
    last_autovacuum,
    n_dead_tup,
    n_live_tup,
    NOW() - last_autovacuum AS since_last_vacuum
FROM pg_stat_user_tables
WHERE last_autovacuum < NOW() - INTERVAL '1 day'
  AND n_dead_tup > 100
ORDER BY since_last_vacuum DESC;

-- Force a vacuum manually
VACUUM employees;  -- Removes dead tuples
ANALYZE employees;  -- Updates statistics

-- Force a full vacuum (locks table, use with caution)
-- VACUUM FULL employees;

-- Check vacuum progress
SELECT 
    pid,
    query,
    state,
    backend_type
FROM pg_stat_activity
WHERE query LIKE '%VACUUM%';
```

### The Verification

```bash
# Check autovacuum status
psql -d ecommerce -c "SELECT name, setting FROM pg_settings WHERE name = 'autovacuum';"

# See tables needing vacuum
psql -d ecommerce -c "
SELECT tablename, n_dead_tup, n_live_tup
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;"

# Check vacuum history
psql -d ecommerce -c "
SELECT 
    schemaname,
    tablename,
    last_vacuum,
    last_autovacuum,
    age(now(), last_autovacuum) AS autovacuum_age
FROM pg_stat_user_tables
WHERE last_autovacuum IS NOT NULL
ORDER BY autovacuum_age DESC;"
```

---

## P2.8 Concurrency Control (MVCC)

### The Target
Understand Multi-Version Concurrency Control and how it enables consistent reads.

### The Concept
MVCC (Multi-Version Concurrency Control) allows multiple users to read and write simultaneously without conflicts. Instead of locking rows, PostgreSQL creates new versions of rows when they're updated. Readers see a snapshot of the data at the start of their transaction.

### The Implementation

**How MVCC Works:**

```
Time ─────────────────────────────────────────────────────────►

Version 1:  |  INSERT (visible to everyone)
Version 2:  |  UPDATE (creates new version, old version still exists)
Version 3:  |  UPDATE (creates another version)
            |
            ▼
Reader 1:   |  Sees version 1 (started before updates)
Reader 2:   |  Sees version 2 (started after first update)
Reader 3:   |  Sees version 3 (started after second update)

```sql
-- Check transaction isolation levels
SHOW transaction_isolation;
-- Default is 'read committed'

-- See current transactions
SELECT 
    pid,
    usename,
    state,
    xact_start,
    query_start,
    state_change,
    wait_event_type,
    wait_event,
    query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY xact_start;

-- See transaction IDs and their ages
SELECT 
    datname,
    age(datfrozenxid) AS txid_age,
    datfrozenxid
FROM pg_database
WHERE datname = current_database();

-- Check for long-running transactions
SELECT 
    pid,
    usename,
    age(backend_xmin) AS transaction_age,
    age(backend_xid) AS current_txid_age,
    query
FROM pg_stat_activity
WHERE backend_xmin IS NOT NULL
  AND age(backend_xmin) > 1000000  -- 1 million transactions old
ORDER BY age(backend_xmin) DESC;

-- See row-level locks
SELECT 
    locktype,
    relation::regclass AS table_name,
    page,
    tuple,
    virtualxid,
    transactionid,
    mode,
    granted
FROM pg_locks
WHERE locktype IN ('relation', 'tuple')
  AND relation IS NOT NULL;
```

### The Verification

```bash
# Check transaction isolation level
psql -d ecommerce -c "SHOW transaction_isolation;"

# See active transactions
psql -d ecommerce -c "
SELECT 
    pid,
    usename,
    EXTRACT(EPOCH FROM (NOW() - xact_start)) AS seconds_since_start,
    state,
    query
FROM pg_stat_activity
WHERE state = 'idle in transaction' OR state = 'active'
ORDER BY xact_start;"

# Test MVCC behavior
# Open two psql sessions and run:
# Session 1: BEGIN; SELECT * FROM employees WHERE id = 1;  -- sees current data
# Session 2: UPDATE employees SET salary = 100000 WHERE id = 1; COMMIT;
# Session 1: SELECT * FROM employees WHERE id = 1;  -- still sees old data!
# Session 1: COMMIT; SELECT * FROM employees WHERE id = 1;  -- now sees new data
```

---

## P2.9 Summary

### What You've Learned

✅ PostgreSQL client-server architecture  
✅ Process model (process-per-connection)  
✅ Memory architecture (shared buffers, work_mem, maintenance_work_mem)  
✅ Storage system (pages, files, WAL)  
✅ Query processing pipeline (parse, rewrite, plan, execute)  
✅ Write-Ahead Log (WAL) for durability  
✅ Autovacuum and its importance  
✅ MVCC and concurrency control  

### Why This Matters

Understanding PostgreSQL architecture helps you:
- **Write better queries**: Knowing how the planner works helps you optimize
- **Tune performance**: Understanding memory settings helps you configure PostgreSQL
- **Troubleshoot issues**: Knowing the internals helps you diagnose problems
- **Plan capacity**: Understanding storage helps you plan for growth

### Next Steps

Now that you understand PostgreSQL architecture, you're ready to apply this knowledge in the main tutorial series. You'll understand why certain optimizations work and how to diagnose performance issues.

**Continue to Part 1 of the main series** to start building your e-commerce database!
