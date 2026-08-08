# Primer 6: SQL & Database Fundamentals

## Essential SQL and Database Knowledge for the Masterclass

Welcome to **Primer 6** of the Django REST Framework & Next.js 16 masterclass. This primer is designed for developers who need a quick refresh or introduction to SQL and database fundamentals before diving into the main series.

---

## Section 1: Database Fundamentals

### 1.1 What is a Database?

A database is an organized collection of structured information, or data, typically stored electronically in a computer system.

**Types of Databases:**
- **Relational (SQL)**: PostgreSQL, MySQL, SQLite
- **NoSQL**: MongoDB, Redis, Elasticsearch
- **Graph**: Neo4j
- **Document**: MongoDB, CouchDB

**Why PostgreSQL?**
- ACID compliant
- Advanced features (JSON, full-text search)
- Excellent performance
- Active community
- Open source

### 1.2 Relational Database Concepts

**Tables:** Collections of related data (like a spreadsheet)
**Rows:** Individual records in a table
**Columns:** Attributes/fields of the data
**Primary Key:** Unique identifier for each row
**Foreign Key:** Reference to another table's primary key
**Index:** Structure to speed up queries
**Relationships:** How tables connect to each other

### 1.3 Database Relationships

**One-to-One (1:1):**
```
User ─── Profile
1       1
```
Each user has one profile, each profile belongs to one user.

**One-to-Many (1:N):**
```
User ─── Task
1       N
```
One user can have many tasks, each task belongs to one user.

**Many-to-Many (N:N):**
```
Task ─── Tag
N       N
```
Many tasks can have many tags, many tags can belong to many tasks.

---

## Section 2: PostgreSQL Commands

### 2.1 Basic psql Commands

```bash
# Connect to database
psql -U username -d database_name -h hostname

# Connect to default database
psql -U postgres

# Connect with password
psql -U taskflow_user -h localhost taskflow_db

# Execute single query
psql -U taskflow_user -d taskflow_db -c "SELECT * FROM tasks_task;"
```

### 2.2 PostgreSQL Meta-Commands

```sql
-- List databases
\l

-- Connect to database
\c database_name

-- List tables
\dt

-- Describe table
\d table_name

-- Show detailed table info
\d+ table_name

-- List users
\du

-- List indexes
\di

-- Quit psql
\q

-- Show connection info
\conninfo

-- Toggle expanded display
\x

-- Show execution time
\timing

-- List schemas
\dn

-- List functions
\df
```

---

## Section 3: SQL Fundamentals

### 3.1 Database Operations

```sql
-- Create database
CREATE DATABASE taskflow_db;

-- Create database with encoding
CREATE DATABASE taskflow_db ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';

-- Drop database
DROP DATABASE taskflow_db;

-- Rename database
ALTER DATABASE taskflow_db RENAME TO taskflow_db_new;

-- Create user
CREATE USER taskflow_user WITH PASSWORD 'secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE taskflow_db TO taskflow_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO taskflow_user;

-- Grant table privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO taskflow_user;

-- Revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE taskflow_db FROM taskflow_user;

-- Drop user
DROP USER taskflow_user;
```

### 3.2 Table Operations

```sql
-- Create table
CREATE TABLE tasks_task (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'todo',
    priority VARCHAR(20) DEFAULT 'medium',
    due_date TIMESTAMP WITH TIME ZONE,
    project_id BIGINT NOT NULL,
    created_by_id BIGINT NOT NULL,
    assigned_to_id BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add constraint
ALTER TABLE tasks_task ADD CONSTRAINT fk_project 
    FOREIGN KEY (project_id) REFERENCES projects_project(id) ON DELETE CASCADE;

-- Add index
CREATE INDEX idx_task_status ON tasks_task (status);
CREATE INDEX idx_task_project ON tasks_task (project_id);
CREATE INDEX idx_task_created_at ON tasks_task (created_at DESC);

-- Add column
ALTER TABLE tasks_task ADD COLUMN urgency VARCHAR(20);

-- Drop column
ALTER TABLE tasks_task DROP COLUMN urgency;

-- Rename column
ALTER TABLE tasks_task RENAME COLUMN urgency TO priority;

-- Drop table
DROP TABLE tasks_task;

-- Truncate table (delete all rows)
TRUNCATE TABLE tasks_task;
```

### 3.3 INSERT (Create)

```sql
-- Insert single row
INSERT INTO tasks_task (title, description, status, project_id, created_by_id)
VALUES ('Complete API documentation', 'Write comprehensive docs', 'in_progress', 1, 1);

-- Insert multiple rows
INSERT INTO tasks_task (title, project_id, created_by_id) VALUES
    ('Task 1', 1, 1),
    ('Task 2', 1, 1),
    ('Task 3', 2, 1);

-- Insert with returning
INSERT INTO tasks_task (title, project_id, created_by_id)
VALUES ('New Task', 1, 1) RETURNING id;

-- Insert from select
INSERT INTO tasks_task (title, project_id, created_by_id)
SELECT title || ' (copied)', project_id, created_by_id
FROM tasks_task WHERE status = 'done';
```

### 3.4 SELECT (Read)

```sql
-- Basic select
SELECT * FROM tasks_task;
SELECT id, title, status FROM tasks_task;

-- WHERE clause
SELECT * FROM tasks_task WHERE status = 'in_progress';
SELECT * FROM tasks_task WHERE priority = 'high' AND status != 'done';

-- LIKE (pattern matching)
SELECT * FROM tasks_task WHERE title LIKE '%API%';
SELECT * FROM tasks_task WHERE title ILIKE '%api%';  -- Case-insensitive

-- IN
SELECT * FROM tasks_task WHERE status IN ('todo', 'in_progress');

-- BETWEEN
SELECT * FROM tasks_task WHERE created_at BETWEEN '2026-01-01' AND '2026-01-31';

-- IS NULL / IS NOT NULL
SELECT * FROM tasks_task WHERE due_date IS NULL;
SELECT * FROM tasks_task WHERE assigned_to_id IS NOT NULL;

-- ORDER BY
SELECT * FROM tasks_task ORDER BY created_at DESC;
SELECT * FROM tasks_task ORDER BY priority DESC, created_at ASC;

-- LIMIT / OFFSET
SELECT * FROM tasks_task LIMIT 20;
SELECT * FROM tasks_task LIMIT 20 OFFSET 40;

-- DISTINCT
SELECT DISTINCT status FROM tasks_task;

-- COUNT
SELECT COUNT(*) FROM tasks_task;
SELECT COUNT(DISTINCT status) FROM tasks_task;

-- GROUP BY
SELECT status, COUNT(*) FROM tasks_task GROUP BY status;
SELECT project_id, COUNT(*) FROM tasks_task GROUP BY project_id;

-- HAVING (filter groups)
SELECT project_id, COUNT(*) 
FROM tasks_task 
GROUP BY project_id 
HAVING COUNT(*) > 5;

-- JOIN
SELECT t.*, p.name as project_name 
FROM tasks_task t
INNER JOIN projects_project p ON t.project_id = p.id;

-- LEFT JOIN
SELECT t.*, u.username as assigned_name
FROM tasks_task t
LEFT JOIN users_user u ON t.assigned_to_id = u.id;

-- Subquery
SELECT * FROM tasks_task 
WHERE project_id IN (SELECT id FROM projects_project WHERE created_by_id = 1);

-- EXISTS
SELECT * FROM projects_project p
WHERE EXISTS (SELECT 1 FROM tasks_task t WHERE t.project_id = p.id);

-- UNION
SELECT title FROM tasks_task WHERE status = 'done'
UNION
SELECT title FROM tasks_task WHERE priority = 'urgent';
```

### 3.5 UPDATE (Update)

```sql
-- Update single column
UPDATE tasks_task SET status = 'done' WHERE id = 1;

-- Update multiple columns
UPDATE tasks_task 
SET status = 'in_progress', priority = 'high' 
WHERE id = 1;

-- Update with calculations
UPDATE tasks_task SET priority = priority || ' (updated)';

-- Update with subquery
UPDATE tasks_task 
SET assigned_to_id = (SELECT id FROM users_user WHERE username = 'admin')
WHERE project_id = 1;

-- Update with returning
UPDATE tasks_task SET status = 'done' 
WHERE id = 1 RETURNING *;
```

### 3.6 DELETE (Delete)

```sql
-- Delete specific rows
DELETE FROM tasks_task WHERE id = 1;

-- Delete with condition
DELETE FROM tasks_task WHERE status = 'archived';

-- Delete all rows
DELETE FROM tasks_task;

-- Delete with returning
DELETE FROM tasks_task WHERE id = 1 RETURNING *;

-- Truncate (faster, no conditions)
TRUNCATE TABLE tasks_task;
```

---

## Section 4: Advanced SQL

### 4.1 Aggregations

```sql
-- Count
SELECT COUNT(*) FROM tasks_task;
SELECT COUNT(DISTINCT project_id) FROM tasks_task;

-- Sum
SELECT SUM(priority) FROM tasks_task WHERE status = 'done';

-- Average
SELECT AVG(priority) FROM tasks_task;

-- Min/Max
SELECT MIN(created_at), MAX(created_at) FROM tasks_task;

-- Multiple aggregations
SELECT 
    COUNT(*) as total,
    AVG(priority) as avg_priority,
    MAX(created_at) as latest
FROM tasks_task;
```

### 4.2 Window Functions

```sql
-- Row number
SELECT 
    id, title, created_at,
    ROW_NUMBER() OVER (ORDER BY created_at) as row_num
FROM tasks_task;

-- Rank
SELECT 
    id, title, priority,
    RANK() OVER (PARTITION BY project_id ORDER BY priority DESC) as rank
FROM tasks_task;

-- Running total
SELECT 
    id, title,
    SUM(priority) OVER (ORDER BY created_at) as running_total
FROM tasks_task;

-- Moving average
SELECT 
    id, title, created_at,
    AVG(priority) OVER (ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg
FROM tasks_task;

-- Lead/Lag
SELECT 
    id, title,
    LAG(title, 1) OVER (ORDER BY created_at) as previous_task,
    LEAD(title, 1) OVER (ORDER BY created_at) as next_task
FROM tasks_task;
```

### 4.3 JSON Operations (PostgreSQL)

```sql
-- Create table with JSON column
CREATE TABLE json_data (
    id BIGSERIAL PRIMARY KEY,
    data JSONB NOT NULL
);

-- Insert JSON
INSERT INTO json_data (data) VALUES 
    ('{"name": "John", "age": 30, "city": "New York"}');

-- Query JSON field
SELECT data->'name' as name FROM json_data;
SELECT data->>'name' as name FROM json_data;

-- Query nested JSON
SELECT data->'address'->>'city' as city FROM json_data;

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
    project_id,
    json_agg(title) as task_titles
FROM tasks_task
GROUP BY project_id;
```

### 4.4 Full-Text Search (PostgreSQL)

```sql
-- Create search vector
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

-- Rank results
SELECT 
    *,
    ts_rank(search_vector, to_tsquery('english', 'documentation')) as rank
FROM tasks_task 
WHERE search_vector @@ to_tsquery('english', 'documentation')
ORDER BY rank DESC;

-- Auto-update trigger
CREATE TRIGGER task_search_update
BEFORE INSERT OR UPDATE ON tasks_task
FOR EACH ROW
EXECUTE FUNCTION tsvector_update_trigger(
    search_vector, 'pg_catalog.english', title, description
);
```

### 4.5 Views

```sql
-- Create view
CREATE VIEW active_tasks AS
SELECT t.*, p.name as project_name, u.username as assigned_name
FROM tasks_task t
JOIN projects_project p ON t.project_id = p.id
LEFT JOIN users_user u ON t.assigned_to_id = u.id
WHERE t.status IN ('todo', 'in_progress', 'review');

-- Query view
SELECT * FROM active_tasks;

-- Drop view
DROP VIEW active_tasks;
```

### 4.6 Transactions

```sql
-- Start transaction
BEGIN;

-- Perform operations
UPDATE tasks_task SET status = 'done' WHERE id = 1;
UPDATE projects_project SET task_count = task_count - 1 WHERE id = 1;

-- Commit (save changes)
COMMIT;

-- Rollback (discard changes)
ROLLBACK;

-- Savepoint
BEGIN;
UPDATE tasks_task SET status = 'done' WHERE id = 1;
SAVEPOINT sp1;
UPDATE tasks_task SET status = 'archived' WHERE id = 1;
ROLLBACK TO SAVEPOINT sp1;
COMMIT;
```

---

## Section 5: Performance Optimization

### 5.1 Index Types

```sql
-- B-tree index (default)
CREATE INDEX idx_task_status ON tasks_task (status);

-- Composite index
CREATE INDEX idx_task_status_priority ON tasks_task (status, priority);

-- Unique index
CREATE UNIQUE INDEX idx_task_unique_title ON tasks_task (title, project_id);

-- Partial index
CREATE INDEX idx_task_active ON tasks_task (created_at) 
WHERE status IN ('todo', 'in_progress');

-- Functional index
CREATE INDEX idx_task_lower_title ON tasks_task (LOWER(title));

-- GIN index (for full-text search)
CREATE INDEX idx_task_search ON tasks_task USING GIN (search_vector);

-- GIST index (for geospatial)
CREATE INDEX idx_location ON locations USING GIST (coordinates);
```

### 5.2 Query Analysis

```sql
-- Explain query
EXPLAIN SELECT * FROM tasks_task WHERE status = 'todo';

-- Explain with analyze
EXPLAIN ANALYZE SELECT * FROM tasks_task WHERE status = 'todo';

-- Explain with buffers
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM tasks_task WHERE status = 'todo';

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Check table statistics
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY seq_scan DESC;

-- Analyze table
ANALYZE tasks_task;

-- Vacuum table
VACUUM tasks_task;

-- Vacuum analyze
VACUUM ANALYZE tasks_task;
```

### 5.3 Connection Management

```sql
-- Show active connections
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

-- Show connection count
SELECT COUNT(*) FROM pg_stat_activity;

-- Kill a connection
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid = 12345;

-- Show database size
SELECT pg_database_size('taskflow_db')/1024/1024 as size_mb;

-- Show table sizes
SELECT 
    tablename,
    pg_table_size(tablename)/1024/1024 as size_mb
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY size_mb DESC;
```

---

## Section 6: Database Design Best Practices

### 6.1 Table Design

```sql
-- Use appropriate data types
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(150),
    last_name VARCHAR(150),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Use indexes for foreign keys
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Use constraints for data integrity
ALTER TABLE tasks_task ADD CONSTRAINT chk_status 
    CHECK (status IN ('todo', 'in_progress', 'review', 'done'));

-- Use not null for required fields
ALTER TABLE tasks_task ALTER COLUMN title SET NOT NULL;
```

### 6.2 Naming Conventions

```sql
-- Table names: plural, lowercase, underscore
CREATE TABLE tasks_task (...);
CREATE TABLE users_user (...);

-- Column names: lowercase, underscore
id, created_at, updated_at

-- Primary keys: singular
id, user_id, task_id

-- Foreign keys: referenced_table + _id
project_id, created_by_id

-- Index names: idx_table_column
idx_task_status
idx_task_project_id

-- Constraints: fk_table_column
fk_task_project_id
```

---

## Quick Reference Cards

### SQL Keywords

| Category | Keywords |
|----------|----------|
| **DDL** | CREATE, ALTER, DROP, TRUNCATE |
| **DML** | SELECT, INSERT, UPDATE, DELETE |
| **DCL** | GRANT, REVOKE |
| **TCL** | COMMIT, ROLLBACK, SAVEPOINT |
| **Operators** | =, !=, >, <, >=, <=, LIKE, IN, BETWEEN, IS NULL |
| **Logical** | AND, OR, NOT |
| **Aggregate** | COUNT, SUM, AVG, MIN, MAX |
| **Window** | ROW_NUMBER, RANK, LEAD, LAG |
| **Joins** | INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN, CROSS JOIN |

### Common PostgreSQL Data Types

| Type | Description | Example |
|------|-------------|---------|
| `BIGSERIAL` | Auto-increment integer | `id BIGSERIAL PRIMARY KEY` |
| `BIGINT` | Large integer | `count BIGINT` |
| `VARCHAR(n)` | Variable string | `title VARCHAR(255)` |
| `TEXT` | Unlimited text | `description TEXT` |
| `BOOLEAN` | True/False | `is_active BOOLEAN DEFAULT TRUE` |
| `DATE` | Date only | `birth_date DATE` |
| `TIMESTAMP` | Date and time | `created_at TIMESTAMP` |
| `JSONB` | JSON data | `data JSONB` |
| `UUID` | UUID | `id UUID PRIMARY KEY` |
| `ARRAY` | Array | `tags TEXT[]` |

---

*This concludes Primer 6. You now have the essential SQL and database knowledge needed for the masterclass.*
