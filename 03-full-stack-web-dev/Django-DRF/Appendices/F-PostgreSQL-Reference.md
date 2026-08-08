# Appendix F: PostgreSQL Reference

## Complete PostgreSQL Reference Guide

Welcome to **Appendix F** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for PostgreSQL, covering everything from basic commands to advanced optimization techniques used throughout the masterclass.

---

## Section 1: PostgreSQL Commands

### 1.1 Connection Commands

```bash
# Connect to database
psql -U username -d database_name -h hostname

# Connect with password prompt
psql -U taskflow_user -h localhost taskflow_db

# Connect to default database
psql -U postgres

# Connect and execute query
psql -U taskflow_user -d taskflow_db -c "SELECT * FROM users_user;"

# Connect with connection string
psql "postgresql://taskflow_user:password@localhost:5432/taskflow_db"
```

### 1.2 Database Management

```sql
-- List databases
\l

-- Create database
CREATE DATABASE taskflow_db;

-- Create database with encoding
CREATE DATABASE taskflow_db ENCODING 'UTF8';

-- Drop database
DROP DATABASE taskflow_db;

-- Rename database
ALTER DATABASE taskflow_db RENAME TO taskflow_db_new;

-- List tablespaces
\db

-- Create tablespace
CREATE TABLESPACE fast_space LOCATION '/data/fast';

-- Set default tablespace
SET default_tablespace = fast_space;
```

### 1.3 User Management

```sql
-- List users
\du

-- Create user
CREATE USER taskflow_user WITH PASSWORD 'secure_password';

-- Create user with privileges
CREATE USER taskflow_user WITH PASSWORD 'secure_password' CREATEDB;

-- Alter user
ALTER USER taskflow_user WITH PASSWORD 'new_password';

-- Grant database privileges
GRANT ALL PRIVILEGES ON DATABASE taskflow_db TO taskflow_user;

-- Grant schema privileges
GRANT ALL PRIVILEGES ON SCHEMA public TO taskflow_user;

-- Grant table privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO taskflow_user;

-- Grant sequence privileges
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO taskflow_user;

-- Revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE taskflow_db FROM taskflow_user;

-- Drop user
DROP USER taskflow_user;
```

---

## Section 2: Table Operations

### 2.1 Table Management

```sql
-- List tables
\dt

-- Describe table
\d table_name

-- Show table details
\d+ table_name

-- Show table size
SELECT pg_size_pretty(pg_total_relation_size('table_name'));

-- Show all table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Show table row count
SELECT COUNT(*) FROM table_name;

-- Show table structure
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'table_name';

-- Create table with constraints
CREATE TABLE projects_project (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_by_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_created_by 
        FOREIGN KEY (created_by_id) 
        REFERENCES users_user(id) 
        ON DELETE CASCADE
);

-- Add column
ALTER TABLE table_name ADD COLUMN new_column VARCHAR(255);

-- Add column with default
ALTER TABLE table_name ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- Drop column
ALTER TABLE table_name DROP COLUMN column_name;

-- Rename column
ALTER TABLE table_name RENAME COLUMN old_name TO new_name;

-- Rename table
ALTER TABLE old_name RENAME TO new_name;
```

### 2.2 Data Manipulation

```sql
-- Insert data
INSERT INTO table_name (column1, column2) VALUES ('value1', 'value2');

-- Insert multiple rows
INSERT INTO table_name (column1, column2) VALUES 
    ('value1', 'value2'),
    ('value3', 'value4'),
    ('value5', 'value6');

-- Insert with returning
INSERT INTO table_name (column1) VALUES ('value') RETURNING id;

-- Update data
UPDATE table_name SET column1 = 'new_value' WHERE condition;

-- Update multiple columns
UPDATE table_name 
SET column1 = 'value1', column2 = 'value2' 
WHERE condition;

-- Delete data
DELETE FROM table_name WHERE condition;

-- Delete all rows (fast)
TRUNCATE table_name;
```

---

## Section 3: Query Optimization

### 3.1 Index Management

```sql
-- Create B-tree index
CREATE INDEX idx_table_column ON table_name (column);

-- Create composite index
CREATE INDEX idx_table_col1_col2 ON table_name (col1, col2);

-- Create unique index
CREATE UNIQUE INDEX idx_table_unique ON table_name (column);

-- Create partial index
CREATE INDEX idx_table_active ON table_name (column) WHERE status = 'active';

-- Create functional index
CREATE INDEX idx_table_lower ON table_name (LOWER(column));

-- Create index with CONCURRENTLY (no lock)
CREATE INDEX CONCURRENTLY idx_table_column ON table_name (column);

-- Drop index
DROP INDEX idx_table_column;

-- Drop index CONCURRENTLY
DROP INDEX CONCURRENTLY idx_table_column;

-- Show indexes
\di

-- Show indexes on table
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'table_name';
```

### 3.2 Query Analysis

```sql
-- Explain query
EXPLAIN SELECT * FROM table_name WHERE column = 'value';

-- Explain with more detail
EXPLAIN ANALYZE SELECT * FROM table_name WHERE column = 'value';

-- Explain with buffers
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM table_name WHERE column = 'value';

-- Explain with JSON output
EXPLAIN (FORMAT JSON) SELECT * FROM table_name WHERE column = 'value';

-- Show query plan
EXPLAIN (ANALYZE, COSTS, VERBOSE) SELECT * FROM table_name;

-- Show active queries
SELECT 
    pid,
    usename,
    application_name,
    state,
    query,
    query_start
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY query_start;

-- Kill a query
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid = 12345;
```

### 3.3 Query Performance Tips

```sql
-- Use EXPLAIN to check queries
EXPLAIN ANALYZE
SELECT t.*, p.name 
FROM tasks_task t
JOIN projects_project p ON t.project_id = p.id
WHERE t.status = 'todo' 
AND t.created_at > NOW() - INTERVAL '7 days'
ORDER BY t.created_at DESC;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Check table scan efficiency
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

-- Analyze table
ANALYZE table_name;

-- Vacuum table
VACUUM table_name;

-- Vacuum analyze
VACUUM ANALYZE table_name;

-- Full vacuum (not recommended in production)
VACUUM FULL table_name;
```

---

## Section 4: Advanced PostgreSQL

### 4.1 JSON Operations

```sql
-- Create table with JSON column
CREATE TABLE json_data (
    id BIGSERIAL PRIMARY KEY,
    data JSONB NOT NULL
);

-- Insert JSON data
INSERT INTO json_data (data) VALUES 
    ('{"name": "John", "age": 30, "city": "New York"}');

-- Query JSON field
SELECT data->'name' as name FROM json_data;
SELECT data->>'name' as name FROM json_data;

-- Query nested JSON
SELECT data->'address'->>'city' as city FROM json_data;

-- JSON operators
-- ->  : Get JSON object field (as JSON)
-- ->> : Get JSON object field (as text)
-- #>  : Get JSON object at path (as JSON)
-- #>> : Get JSON object at path (as text)

-- Filter by JSON field
SELECT * FROM json_data WHERE data->>'name' = 'John';

-- Update JSON field
UPDATE json_data SET data = jsonb_set(data, '{age}', '31') WHERE id = 1;

-- Add JSON field
UPDATE json_data SET data = data || '{"status": "active"}' WHERE id = 1;

-- Remove JSON field
UPDATE json_data SET data = data - 'status' WHERE id = 1;

-- JSON aggregation
SELECT 
    task_id,
    json_agg(comment) as comments
FROM comments
GROUP BY task_id;

-- JSON array operations
SELECT * FROM json_data WHERE data->'tags' ? 'important';
```

### 4.2 Full-Text Search

```sql
-- Create full-text search column
ALTER TABLE tasks_task ADD COLUMN search_vector TSVECTOR;

-- Update search vector
UPDATE tasks_task SET search_vector = 
    setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B');

-- Create GIN index
CREATE INDEX idx_task_search ON tasks_task USING GIN (search_vector);

-- Search query
SELECT * FROM tasks_task 
WHERE search_vector @@ to_tsquery('english', 'documentation & api');

-- Rank search results
SELECT 
    *,
    ts_rank(search_vector, to_tsquery('english', 'documentation')) as rank
FROM tasks_task 
WHERE search_vector @@ to_tsquery('english', 'documentation')
ORDER BY rank DESC;

-- Update trigger for search vector
CREATE TRIGGER task_search_update
BEFORE INSERT OR UPDATE ON tasks_task
FOR EACH ROW
EXECUTE FUNCTION tsvector_update_trigger(
    search_vector, 'pg_catalog.english', title, description
);
```

### 4.3 Window Functions

```sql
-- Row number
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY created_at) as row_num
FROM tasks_task;

-- Rank by priority
SELECT 
    *,
    RANK() OVER (PARTITION BY project_id ORDER BY priority DESC) as rank
FROM tasks_task;

-- Running total
SELECT 
    *,
    SUM(priority) OVER (ORDER BY created_at) as running_priority
FROM tasks_task;

-- Moving average
SELECT 
    *,
    AVG(priority) OVER (ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg
FROM tasks_task;

-- Percentile
SELECT 
    *,
    PERCENT_RANK() OVER (ORDER BY due_date) as due_percentile
FROM tasks_task;

-- Lead/Lag
SELECT 
    *,
    LAG(title, 1) OVER (ORDER BY created_at) as previous_task,
    LEAD(title, 1) OVER (ORDER BY created_at) as next_task
FROM tasks_task;
```

### 4.4 Performance Monitoring

```sql
-- Database size
SELECT pg_database_size('taskflow_db')/1024/1024 as size_mb;

-- Table sizes
SELECT 
    tablename,
    pg_table_size(tablename)/1024/1024 as size_mb
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY size_mb DESC;

-- Index sizes
SELECT 
    indexname,
    pg_indexes_size(indexname)/1024/1024 as size_mb
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY size_mb DESC;

-- Cache hit ratio
SELECT 
    'cache hit ratio' as name,
    (sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read))) * 100 as value
FROM pg_statio_user_tables;

-- Transaction statistics
SELECT 
    xact_commit,
    xact_rollback,
    (xact_rollback::float / (xact_commit + xact_rollback) * 100) as rollback_percent
FROM pg_stat_database
WHERE datname = 'taskflow_db';

-- Lock monitoring
SELECT 
    relation::regclass,
    locktype,
    mode,
    granted
FROM pg_locks
WHERE NOT granted;

-- Connection usage
SELECT 
    COUNT(*) as connections,
    state
FROM pg_stat_activity
GROUP BY state;
```

---

## Section 5: Backup and Recovery

### 5.1 Backup Commands

```bash
# Full database backup
pg_dump -U taskflow_user -h localhost taskflow_db > backup.sql

# Compressed backup
pg_dump -U taskflow_user -h localhost taskflow_db | gzip > backup.sql.gz

# Backup with schema only
pg_dump -U taskflow_user -h localhost -s taskflow_db > schema.sql

# Backup with data only
pg_dump -U taskflow_user -h localhost -a taskflow_db > data.sql

# Backup specific tables
pg_dump -U taskflow_user -h localhost -t users_user -t projects_project taskflow_db > tables.sql

# Custom format (binary)
pg_dump -Fc -U taskflow_user -h localhost taskflow_db > backup.dump

# Directory format
pg_dump -Fd -U taskflow_user -h localhost -f backup_dir taskflow_db

# Parallel backup
pg_dump -j 4 -Fd -U taskflow_user -h localhost -f backup_dir taskflow_db
```

### 5.2 Recovery Commands

```bash
# Restore SQL backup
psql -U taskflow_user -h localhost taskflow_db < backup.sql

# Restore compressed backup
gunzip -c backup.sql.gz | psql -U taskflow_user -h localhost taskflow_db

# Restore custom format
pg_restore -U taskflow_user -h localhost -d taskflow_db backup.dump

# Restore directory format
pg_restore -U taskflow_user -h localhost -d taskflow_db backup_dir

# Restore with schema only
psql -U taskflow_user -h localhost taskflow_db < schema.sql

# Restore to different database
pg_restore -U taskflow_user -h localhost -d new_db backup.dump
```

### 5.3 Point-in-Time Recovery

```sql
-- Enable archive mode (postgresql.conf)
wal_level = replica
archive_mode = on
archive_command = 'cp %p /archive/%f'

-- Base backup
SELECT pg_start_backup('base_backup', true);
-- Backup data directory
SELECT pg_stop_backup();

-- Restore point
SELECT pg_create_restore_point('before_migration');

-- Show restore points
SELECT * FROM pg_restore_points;

-- Recover to specific time
RECOVER DATABASE taskflow_db TO '2026-01-15 12:00:00';
```

---

## Section 6: Configuration Tuning

### 6.1 postgresql.conf Settings

```ini
# Connection Settings
listen_addresses = '*'                # Listen on all interfaces
port = 5432                           # Default port
max_connections = 100                 # Maximum connections
superuser_reserved_connections = 3    # Reserved for superuser

# Memory Settings
shared_buffers = 256MB                # 25% of RAM
work_mem = 4MB                        # Per-operation memory
maintenance_work_mem = 64MB           # Maintenance operations
effective_cache_size = 2GB            # OS cache size

# WAL Settings
wal_level = replica
wal_buffers = 16MB
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
max_wal_size = 1GB
min_wal_size = 80MB

# Query Planning
random_page_cost = 1.1                # SSDs
cpu_tuple_cost = 0.01
cpu_index_tuple_cost = 0.005
effective_io_concurrency = 200        # SSDs

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB

# Advanced
max_worker_processes = 8
max_parallel_workers = 8
max_parallel_workers_per_gather = 2
```

### 6.2 Connection Pooling (PgBouncer)

```ini
[databases]
taskflow_db = host=localhost port=5432 dbname=taskflow_db

[pgbouncer]
listen_addr = *
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 200
default_pool_size = 20
reserve_pool_size = 5
reserve_pool_timeout = 3
```

---

## Quick Reference Cards

### psql Meta-Commands

| Command | Description |
|---------|-------------|
| `\l` | List databases |
| `\c dbname` | Connect to database |
| `\dt` | List tables |
| `\d table` | Describe table |
| `\di` | List indexes |
| `\du` | List users |
| `\conninfo` | Show connection info |
| `\copy` | Copy data |
| `\x` | Toggle expanded display |
| `\q` | Quit psql |

### Common Functions

| Function | Purpose |
|----------|---------|
| `NOW()` | Current timestamp |
| `CURRENT_DATE` | Current date |
| `CURRENT_TIME` | Current time |
| `COUNT(*)` | Count rows |
| `SUM(column)` | Sum values |
| `AVG(column)` | Average |
| `MAX(column)` | Maximum |
| `MIN(column)` | Minimum |
| `LOWER(string)` | Lowercase |
| `UPPER(string)` | Uppercase |
| `TRIM(string)` | Remove spaces |
| `LENGTH(string)` | String length |
| `CONCAT(a,b)` | Concatenate |

---

*This concludes Appendix F. Use this PostgreSQL reference throughout your development journey.*
