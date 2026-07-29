# Serverless Postgres with Neon: From Zero to Production

## Appendix A: Complete SQL Reference & Cheat Sheet

### Overview

This comprehensive reference guide serves as your go-to resource for all SQL commands, patterns, and best practices covered throughout the series. Whether you're building queries, designing schemas, or troubleshooting performance issues, this appendix has you covered with practical examples and quick lookup tables.

---

### A.1 Database Setup & Connection

#### Connection Strings

```sql
-- Standard Direct Connection
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require

-- Pooled Connection (Recommended for Serverless)
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require&pool_mode=transaction

-- Connection with SSL and Timeout
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require&connect_timeout=10

-- Connection with Application Name
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require&application_name=my_app
```

#### Basic Connection Commands (psql)

```sql
-- Connect to database
\c database_name

-- List databases
\l

-- List tables
\dt

-- Describe table structure
\d table_name

-- List all schemas
\dn

-- List users/roles
\du

-- Show current database
SELECT current_database();

-- Show current user
SELECT current_user;

-- Show PostgreSQL version
SELECT version();

-- Show connection info
SELECT inet_server_addr(), inet_server_port();

-- Quit psql
\q
```

---

### A.2 Data Types Reference

#### Numeric Types

| Type | Storage | Range | Use Case |
|------|---------|-------|----------|
| `SMALLINT` | 2 bytes | -32,768 to 32,767 | Ages, small counts |
| `INTEGER` | 4 bytes | -2.1B to 2.1B | Standard counts |
| `BIGINT` | 8 bytes | -9.2e18 to 9.2e18 | Large IDs, timestamps |
| `NUMERIC(p,s)` | Variable | Up to 131,072 digits | **Money, exact decimals** |
| `REAL` | 4 bytes | 6 decimal digits precision | Scientific calculations |
| `DOUBLE PRECISION` | 8 bytes | 15 decimal digits precision | High-precision floats |
| `SERIAL` | 4 bytes | 1 to 2.1B | Auto-incrementing IDs |
| `BIGSERIAL` | 8 bytes | 1 to 9.2e18 | Large auto-incrementing IDs |

#### Character Types

| Type | Storage | Description | Use Case |
|------|---------|-------------|----------|
| `VARCHAR(n)` | Variable | Max length n | **Names, emails, titles** |
| `CHAR(n)` | Fixed, n bytes | Fixed length with padding | Codes, flags (rarely used) |
| `TEXT` | Variable | Unlimited length | **Descriptions, content** |

#### Date/Time Types

| Type | Storage | Description | Use Case |
|------|---------|-------------|----------|
| `DATE` | 4 bytes | Date only (no time) | Birthdays, events |
| `TIME` | 8 bytes | Time only (no date) | Business hours |
| `TIMESTAMP` | 8 bytes | Date and time (no timezone) | Local timestamps |
| `TIMESTAMPTZ` | 8 bytes | **Date and time WITH timezone** | **Application timestamps** |
| `INTERVAL` | 16 bytes | Duration between timestamps | Age calculations, time differences |

#### Other Types

| Type | Description | Use Case |
|------|-------------|----------|
| `BOOLEAN` | true/false | Flags, statuses, toggles |
| `UUID` | 16-byte universal identifier | **Primary keys in distributed systems** |
| `JSONB` | Binary JSON | **Flexible schemas, semi-structured data** |
| `ARRAY` | Array of any type | Lists of values |
| `BYTEA` | Binary data | Files, images (use external storage) |
| `INET` | IPv4/IPv6 address | IP addresses for logging |
| `MACADDR` | MAC address | Network hardware addresses |

---

### A.3 DDL (Data Definition Language)

#### CREATE Table

```sql
-- Basic Table Creation
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    column3 datatype constraints,
    CONSTRAINT constraint_name CHECK (condition)
);

-- Complete Example with All Features
CREATE TABLE IF NOT EXISTS products (
    -- Primary Key with UUID
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Columns with Constraints
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    
    -- Enum-like Status
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'draft')),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    
    -- Foreign Key
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    
    -- JSONB for Flexible Data
    attributes JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Full-Text Search
    search_vector TSVECTOR,
    
    -- Complex Constraints
    CONSTRAINT unique_name UNIQUE (name),
    CONSTRAINT positive_price CHECK (price >= 0),
    CONSTRAINT sufficient_stock CHECK (stock_quantity >= 0 OR deleted_at IS NOT NULL)
);

-- Create Indexes
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);
CREATE INDEX idx_products_attributes_gin ON products USING gin(attributes);

-- Create Partial Index
CREATE INDEX idx_products_active ON products(price) WHERE deleted_at IS NULL;

-- Create Covering Index
CREATE INDEX idx_products_covering ON products(category_id, price) INCLUDE (name, stock_quantity);

-- Create View
CREATE VIEW active_products AS
SELECT * FROM products WHERE deleted_at IS NULL AND status = 'active';

-- Create Materialized View
CREATE MATERIALIZED VIEW product_sales_summary AS
SELECT 
    p.id,
    p.name,
    COUNT(oi.id) AS times_ordered,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.line_total) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status != 'cancelled'
WHERE p.deleted_at IS NULL
GROUP BY p.id, p.name;
```

#### ALTER Table

```sql
-- Add Column
ALTER TABLE table_name ADD COLUMN new_column datatype DEFAULT default_value;

-- Add Column with Constraint
ALTER TABLE table_name 
ADD COLUMN new_column datatype NOT NULL DEFAULT default_value;

-- Drop Column
ALTER TABLE table_name DROP COLUMN column_name CASCADE;

-- Rename Column
ALTER TABLE table_name RENAME COLUMN old_name TO new_name;

-- Change Column Type
ALTER TABLE table_name ALTER COLUMN column_name TYPE new_type;

-- Add Constraint
ALTER TABLE table_name 
ADD CONSTRAINT constraint_name CHECK (condition);

-- Add Foreign Key
ALTER TABLE child_table 
ADD CONSTRAINT fk_name 
FOREIGN KEY (child_column) REFERENCES parent_table(parent_column);

-- Add Unique Constraint
ALTER TABLE table_name 
ADD CONSTRAINT unique_name UNIQUE (column1, column2);

-- Drop Constraint
ALTER TABLE table_name DROP CONSTRAINT constraint_name;

-- Set Default Value
ALTER TABLE table_name ALTER COLUMN column_name SET DEFAULT default_value;

-- Drop Default
ALTER TABLE table_name ALTER COLUMN column_name DROP DEFAULT;
```

#### DROP Table

```sql
-- Drop Table (with CASCADE to drop dependent objects)
DROP TABLE IF EXISTS table_name CASCADE;

-- Drop View
DROP VIEW IF EXISTS view_name CASCADE;

-- Drop Materialized View
DROP MATERIALIZED VIEW IF EXISTS materialized_view_name CASCADE;

-- Drop Index
DROP INDEX IF EXISTS index_name CASCADE;
```

---

### A.4 DML (Data Manipulation Language)

#### INSERT

```sql
-- Insert Single Row
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);

-- Insert with RETURNING
INSERT INTO table_name (name, price) 
VALUES ('Product', 99.99) 
RETURNING id, created_at;

-- Insert Multiple Rows
INSERT INTO table_name (name, price, stock_quantity) VALUES
    ('Product 1', 99.99, 100),
    ('Product 2', 149.99, 50),
    ('Product 3', 79.99, 75);

-- Insert from SELECT
INSERT INTO table_name (column1, column2)
SELECT column1, column2 FROM other_table WHERE condition;

-- Insert with ON CONFLICT (Upsert)
INSERT INTO users (email, username, full_name)
VALUES ('john@example.com', 'john_doe', 'John Doe')
ON CONFLICT (email) DO UPDATE SET
    username = EXCLUDED.username,
    full_name = EXCLUDED.full_name,
    updated_at = CURRENT_TIMESTAMP;

-- Insert with ON CONFLICT (Do Nothing)
INSERT INTO users (email, username, full_name)
VALUES ('john@example.com', 'john_doe', 'John Doe')
ON CONFLICT (email) DO NOTHING;
```

#### SELECT

```sql
-- Basic SELECT
SELECT column1, column2 FROM table_name;

-- SELECT with WHERE
SELECT * FROM table_name WHERE condition;

-- SELECT with ORDER BY
SELECT * FROM table_name ORDER BY column1 ASC, column2 DESC;

-- SELECT with LIMIT and OFFSET (Pagination)
SELECT * FROM table_name ORDER BY id LIMIT 10 OFFSET 20;

-- SELECT with DISTINCT
SELECT DISTINCT column1 FROM table_name;

-- SELECT with Aggregates
SELECT 
    COUNT(*) as total,
    SUM(price) as total_price,
    AVG(price) as average_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM table_name;

-- SELECT with GROUP BY
SELECT 
    category_id,
    COUNT(*) as count,
    AVG(price) as avg_price
FROM products
GROUP BY category_id
HAVING COUNT(*) > 5;

-- SELECT with JOINs
SELECT 
    o.id,
    o.order_number,
    u.full_name,
    o.total
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE o.status = 'completed';

-- SELECT with Subquery
SELECT * FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- SELECT with EXISTS
SELECT * FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.user_id = u.id AND o.total > 1000
);

-- SELECT with JSONB
SELECT 
    name,
    attributes->>'color' AS color,
    attributes->>'battery_life' AS battery_life
FROM products
WHERE attributes @> '{"noise_cancellation": "Active"}'::jsonb;

-- SELECT with Full-Text Search
SELECT 
    name,
    ts_rank_cd(search_vector, plainto_tsquery('wireless headphones')) AS rank
FROM products
WHERE search_vector @@ plainto_tsquery('wireless headphones')
ORDER BY rank DESC;
```

#### UPDATE

```sql
-- Basic UPDATE
UPDATE table_name 
SET column1 = value1, column2 = value2 
WHERE condition;

-- UPDATE with RETURNING
UPDATE products 
SET price = price * 1.10 
WHERE category_id = 'electronics' 
RETURNING id, name, price;

-- UPDATE with Subquery
UPDATE products 
SET price = price * 1.10 
WHERE price < (SELECT AVG(price) FROM products);

-- UPDATE with JSONB
UPDATE products 
SET attributes = attributes || '{"in_stock": true}'::jsonb
WHERE category_id = 'electronics';

-- UPDATE with JSONB Path
UPDATE products 
SET attributes = jsonb_set(attributes, '{battery_life}', '"45 hours"'::jsonb)
WHERE name = 'Premium Headphones';

-- UPDATE with FROM Clause
UPDATE products 
SET stock_quantity = stock_quantity - oi.quantity
FROM order_items oi
WHERE products.id = oi.product_id 
  AND oi.order_id = 'order-uuid';

-- UPDATE with CASE
UPDATE products 
SET price = CASE 
    WHEN category_id = 'electronics' THEN price * 0.90
    WHEN category_id = 'clothing' THEN price * 0.85
    ELSE price
END;
```

#### DELETE

```sql
-- Basic DELETE
DELETE FROM table_name WHERE condition;

-- DELETE with RETURNING
DELETE FROM users 
WHERE id = 'user-uuid' 
RETURNING email, username;

-- DELETE with USING Clause
DELETE FROM products 
USING order_items oi
WHERE products.id = oi.product_id 
  AND oi.quantity = 0;

-- DELETE with Subquery
DELETE FROM products 
WHERE category_id IN (
    SELECT id FROM categories WHERE status = 'inactive'
);

-- DELETE (Soft Delete)
UPDATE products 
SET deleted_at = CURRENT_TIMESTAMP 
WHERE id = 'product-uuid';
```

---

### A.5 Joins Reference

#### INNER JOIN
Returns only rows with matching values in both tables.

```sql
SELECT 
    o.order_number,
    u.full_name,
    o.total
FROM orders o
INNER JOIN users u ON o.user_id = u.id;
```

**Use when**: You need data that exists in both tables (e.g., orders with user details).

#### LEFT JOIN (LEFT OUTER JOIN)
Returns all rows from left table, even if no matches in right table.

```sql
SELECT 
    u.full_name,
    o.order_number,
    o.total
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

**Use when**: You want all users, including those with no orders.

#### RIGHT JOIN (RIGHT OUTER JOIN)
Returns all rows from right table, even if no matches in left table.

```sql
SELECT 
    u.full_name,
    o.order_number
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;
```

**Use when**: You want all orders, including those without users (orphan records).

#### FULL OUTER JOIN
Returns all rows from both tables, matching where possible.

```sql
SELECT 
    u.full_name,
    o.order_number
FROM users u
FULL OUTER JOIN orders o ON u.id = o.user_id;
```

**Use when**: You need to find mismatches or missing data in either table.

#### CROSS JOIN
Returns Cartesian product of both tables (every row × every row).

```sql
SELECT u.full_name, p.name
FROM users u
CROSS JOIN products p;
```

**Use when**: You need to combine all rows from two tables (rare, use carefully).

#### Self Join
Join a table to itself.

```sql
SELECT 
    e1.name AS employee,
    e2.name AS manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;
```

#### Multiple Joins

```sql
SELECT 
    o.order_number,
    u.full_name,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
INNER JOIN users u ON o.user_id = u.id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
WHERE o.status = 'completed';
```

---

### A.6 Aggregate Functions

#### Basic Aggregates

```sql
-- COUNT: Count rows
SELECT 
    COUNT(*) AS total_rows,
    COUNT(column) AS non_null_values,
    COUNT(DISTINCT column) AS unique_values
FROM table_name;

-- SUM: Sum values
SELECT SUM(price) AS total_price FROM products;

-- AVG: Average value
SELECT AVG(price) AS average_price FROM products;

-- MIN/MAX: Minimum and maximum
SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM products;

-- STDDEV: Standard deviation
SELECT STDDEV(price) AS price_stddev FROM products;

-- VARIANCE: Variance
SELECT VARIANCE(price) AS price_variance FROM products;
```

#### GROUP BY

```sql
-- Single Column Group
SELECT 
    category_id,
    COUNT(*) AS product_count,
    AVG(price) AS avg_price
FROM products
GROUP BY category_id;

-- Multiple Columns Group
SELECT 
    category_id,
    status,
    COUNT(*) AS count,
    AVG(price) AS avg_price
FROM products
GROUP BY category_id, status;

-- GROUP BY with HAVING
SELECT 
    category_id,
    COUNT(*) AS product_count,
    AVG(price) AS avg_price
FROM products
GROUP BY category_id
HAVING COUNT(*) > 10 AND AVG(price) > 100;

-- GROUP BY with ROLLUP
SELECT 
    category_id,
    status,
    COUNT(*) AS count
FROM products
GROUP BY ROLLUP(category_id, status);

-- GROUP BY with CUBE
SELECT 
    category_id,
    status,
    COUNT(*) AS count
FROM products
GROUP BY CUBE(category_id, status);
```

#### Window Functions

```sql
-- ROW_NUMBER: Sequential numbering
SELECT 
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS rank
FROM products;

-- RANK with PARTITION BY
SELECT 
    category_id,
    name,
    price,
    RANK() OVER (PARTITION BY category_id ORDER BY price DESC) AS rank_in_category
FROM products;

-- LAG/LEAD: Previous/Next values
SELECT 
    order_date,
    total,
    LAG(total) OVER (ORDER BY order_date) AS previous_total,
    LEAD(total) OVER (ORDER BY order_date) AS next_total
FROM orders;

-- Running Total
SELECT 
    order_date,
    total,
    SUM(total) OVER (ORDER BY order_date) AS running_total
FROM orders;

-- Moving Average (last 5 rows)
SELECT 
    order_date,
    total,
    AVG(total) OVER (ORDER BY order_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_avg
FROM orders;

-- Percentile
SELECT 
    total,
    NTILE(4) OVER (ORDER BY total) AS quartile,
    PERCENT_RANK() OVER (ORDER BY total) AS percent_rank
FROM orders;

-- FIRST_VALUE/LAST_VALUE
SELECT 
    customer_id,
    order_date,
    total,
    FIRST_VALUE(total) OVER (PARTITION BY customer_id ORDER BY order_date) AS first_order_value,
    LAST_VALUE(total) OVER (PARTITION BY customer_id ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order_value
FROM orders;
```

---

### A.7 JSONB Operations Reference

#### JSONB Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `->` | Get JSON field (returns JSON) | `attributes->'color'` |
| `->>` | Get JSON field (returns text) | `attributes->>'color'` |
| `#>` | Get nested field (returns JSON) | `attributes#>>'{ports,hdmi}'` |
| `#>>` | Get nested field (returns text) | `attributes#>>'{ports,hdmi}'` |
| `@>` | Contains | `attributes @> '{"color": "Black"}'::jsonb` |
| `?` | Key exists | `attributes ? 'color'` |
| `?|` | Any key exists | `attributes ?| array['color', 'size']` |
| `?&` | All keys exist | `attributes ?& array['color', 'size']` |
| `||` | Concatenate | `attributes || '{"new": "value"}'::jsonb` |
| `-` | Delete key | `attributes - 'color'` |
| `#-` | Delete nested key | `attributes #- '{ports,hdmi}'` |

#### JSONB Functions

```sql
-- Create JSONB Object
SELECT jsonb_build_object(
    'name', 'Product',
    'price', 99.99,
    'attributes', jsonb_build_object('color', 'Black')
);

-- Create JSONB Array
SELECT jsonb_build_array('item1', 'item2', 'item3');

-- Get JSONB Type
SELECT jsonb_typeof(attributes->'color') FROM products;

-- Check if key exists
SELECT jsonb_exists(attributes, 'color') FROM products;

-- Get all keys
SELECT jsonb_object_keys(attributes) FROM products;

-- Get all values
SELECT jsonb_each(attributes) FROM products;

-- Extract array elements
SELECT jsonb_array_elements(variants) FROM products;

-- Convert to text
SELECT jsonb_to_json(attributes) FROM products;

-- Pretty print JSONB
SELECT jsonb_pretty(attributes) FROM products;

-- Update JSONB
UPDATE products 
SET attributes = jsonb_set(attributes, '{color}', '"Blue"'::jsonb)
WHERE id = 'product-uuid';

-- Deep merge JSONB
UPDATE products 
SET attributes = attributes || '{"new_field": "value"}'::jsonb;

-- Remove key from JSONB
UPDATE products 
SET attributes = attributes - 'old_field';

-- Remove nested key
UPDATE products 
SET attributes = attributes #- '{nested,old_field}';
```

---

### A.8 Transactions & Locking

#### Transaction Commands

```sql
-- Start Transaction
BEGIN;
-- or
START TRANSACTION;

-- Set Isolation Level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Commit Transaction
COMMIT;

-- Rollback Transaction
ROLLBACK;

-- Savepoint
SAVEPOINT savepoint_name;
ROLLBACK TO SAVEPOINT savepoint_name;
RELEASE SAVEPOINT savepoint_name;
```

#### Row-Level Locking

```sql
-- FOR UPDATE: Lock rows for update
SELECT * FROM inventory 
WHERE product_id = 1 
FOR UPDATE;

-- FOR UPDATE with SKIP LOCKED
SELECT * FROM inventory 
WHERE product_id = 1 
FOR UPDATE SKIP LOCKED;

-- FOR UPDATE with NOWAIT
SELECT * FROM inventory 
WHERE product_id = 1 
FOR UPDATE NOWAIT;

-- FOR SHARE: Share lock (read only)
SELECT * FROM inventory 
WHERE product_id = 1 
FOR SHARE;

-- Advisory Locks
SELECT pg_advisory_lock(12345);
SELECT pg_advisory_unlock(12345);
SELECT pg_try_advisory_lock(12345);
```

#### Complete Transaction Example

```sql
-- Inventory Reservation Transaction
BEGIN;

-- Lock inventory row
SELECT quantity, reserved_quantity 
FROM inventory 
WHERE product_id = 1 
FOR UPDATE;

-- Check availability
IF available_quantity >= requested_quantity THEN
    -- Update inventory
    UPDATE inventory 
    SET reserved_quantity = reserved_quantity + requested_quantity
    WHERE product_id = 1;
    
    -- Insert order
    INSERT INTO orders (...);
    
    -- Insert order items
    INSERT INTO order_items (...);
    
    COMMIT;
ELSE
    ROLLBACK;
    RAISE EXCEPTION 'Insufficient stock';
END IF;
```

---

### A.9 Index Types Reference

#### B-Tree Index (Default)
Best for equality and range queries.

```sql
-- Single Column
CREATE INDEX idx_name ON table_name(column);

-- Composite (Multi-column)
CREATE INDEX idx_name ON table_name(column1, column2);

-- Descending Order
CREATE INDEX idx_name ON table_name(column DESC);

-- Unique Index
CREATE UNIQUE INDEX idx_name ON table_name(column);

-- Partial Index
CREATE INDEX idx_name ON table_name(column) WHERE condition;
```

#### GIN Index
Best for full-text search, JSONB, arrays.

```sql
-- JSONB GIN Index
CREATE INDEX idx_name ON table_name USING gin(jsonb_column);

-- Full-Text Search GIN Index
CREATE INDEX idx_name ON table_name USING gin(search_vector);

-- Trigram GIN Index
CREATE INDEX idx_name ON table_name USING gin(column gin_trgm_ops);

-- Array GIN Index
CREATE INDEX idx_name ON table_name USING gin(array_column);

-- JSONB Path GIN Index
CREATE INDEX idx_name ON table_name USING gin((jsonb_column->'path'));
```

#### BRIN Index
Best for very large tables with natural ordering.

```sql
-- BRIN Index
CREATE INDEX idx_name ON table_name USING brin(column);

-- BRIN with Pages
CREATE INDEX idx_name ON table_name USING brin(column) WITH (pages_per_range = 128);
```

#### Hash Index
Best for equality comparisons only.

```sql
-- Hash Index
CREATE INDEX idx_name ON table_name USING hash(column);
```

#### Index Management

```sql
-- List all indexes on a table
SELECT * FROM pg_indexes WHERE tablename = 'table_name';

-- Show index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public';

-- Identify unused indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS scans
FROM pg_stat_user_indexes
WHERE idx_scan = 0 
  AND schemaname = 'public';

-- Rebuild Index
REINDEX INDEX index_name;
REINDEX TABLE table_name;

-- Analyze Table (update statistics)
ANALYZE table_name;

-- Vacuum Table (reclaim storage)
VACUUM table_name;
VACUUM ANALYZE table_name;
```

---

### A.10 Performance Analysis

#### EXPLAIN Commands

```sql
-- Basic EXPLAIN
EXPLAIN SELECT * FROM products WHERE price > 100;

-- EXPLAIN ANALYZE (executes query)
EXPLAIN ANALYZE SELECT * FROM products WHERE price > 100;

-- EXPLAIN with Verbose
EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM products WHERE price > 100;

-- EXPLAIN with Buffers
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM products WHERE price > 100;

-- EXPLAIN with Format
EXPLAIN (ANALYZE, FORMAT JSON) SELECT * FROM products WHERE price > 100;

-- EXPLAIN with Costs
EXPLAIN (ANALYZE, COSTS) SELECT * FROM products WHERE price > 100;

-- EXPLAIN with Timing
EXPLAIN (ANALYZE, TIMING) SELECT * FROM products WHERE price > 100;
```

#### Reading EXPLAIN Output

```
Seq Scan on products (cost=0.00..245.00 rows=1000 width=100)
  Filter: (price > 100)
  Rows Removed by Filter: 9000
  
- cost=0.00..245.00: Estimated cost (start..total)
- rows=1000: Estimated number of rows
- width=100: Estimated average row size
- Filter: The condition being applied
- Rows Removed by Filter: Rows that didn't match
```

#### Query Performance Metrics

```sql
-- Enable pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top 10 Slowest Queries
SELECT 
    queryid,
    query,
    calls,
    mean_exec_time,
    total_exec_time,
    min_exec_time,
    max_exec_time,
    stddev_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Most Frequent Queries
SELECT 
    queryid,
    query,
    calls,
    mean_exec_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- Queries with Most I/O
SELECT 
    queryid,
    query,
    shared_blks_hit,
    shared_blks_read
FROM pg_stat_statements
ORDER BY shared_blks_read DESC
LIMIT 10;
```

---

### A.11 Monitoring Queries

#### Database Health

```sql
-- Database Size
SELECT 
    pg_database_size(current_database()) AS size_bytes,
    pg_size_pretty(pg_database_size(current_database())) AS size_human;

-- Table Sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) AS index_size,
    (pg_total_relation_size(schemaname||'.'||tablename) / 1024 / 1024) AS size_mb
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index Size
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    idx_scan AS scans
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Active Connections
SELECT 
    pid,
    usename AS username,
    application_name,
    client_addr,
    state,
    query,
    state_change,
    wait_event_type,
    wait_event
FROM pg_stat_activity
WHERE state = 'active'
  AND pid != pg_backend_pid()
ORDER BY state_change;

-- Connection Count
SELECT 
    usename,
    application_name,
    COUNT(*) AS connections
FROM pg_stat_activity
GROUP BY usename, application_name
ORDER BY connections DESC;
```

#### Performance Monitoring

```sql
-- Cache Hit Ratio
SELECT 
    'cache hit ratio' AS name,
    (sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read))) * 100 AS ratio
FROM pg_statio_user_tables;

-- Index Hit Ratio
SELECT 
    'index hit ratio' AS name,
    (sum(idx_blks_hit) / (sum(idx_blks_hit) + sum(idx_blks_read))) * 100 AS ratio
FROM pg_statio_user_indexes;

-- Table Scans vs Index Scans
SELECT 
    schemaname,
    tablename,
    seq_scan AS sequential_scans,
    seq_tup_read AS sequential_tuples_read,
    idx_scan AS index_scans,
    idx_tup_fetch AS index_tuples_fetched
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_scan DESC;

-- Transaction Rates
SELECT 
    xact_commit AS commits,
    xact_rollback AS rollbacks,
    (xact_commit + xact_rollback) AS total_transactions
FROM pg_stat_database
WHERE datname = current_database();

-- Bloat Detection
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - 
                    pg_relation_size(schemaname||'.'||tablename)) AS bloat_size,
    ROUND(
        (pg_total_relation_size(schemaname||'.'||tablename) - 
         pg_relation_size(schemaname||'.'||tablename))::NUMERIC / 
        pg_total_relation_size(schemaname||'.'||tablename)::NUMERIC * 100, 2
    ) AS bloat_percentage
FROM pg_tables
WHERE schemaname = 'public'
  AND pg_total_relation_size(schemaname||'.'||tablename) > 10000000
ORDER BY bloat_size DESC;
```

---

### A.12 Security & Permissions

#### User Management

```sql
-- Create User
CREATE USER username WITH PASSWORD 'password';

-- Create User with Specific Permissions
CREATE USER app_user WITH PASSWORD 'secure_password' 
    CONNECTION LIMIT 20;

-- Grant Permissions
-- Grant all on database
GRANT ALL PRIVILEGES ON DATABASE database_name TO username;

-- Grant all on schema
GRANT ALL PRIVILEGES ON SCHEMA schema_name TO username;

-- Grant all on specific table
GRANT ALL PRIVILEGES ON TABLE table_name TO username;

-- Grant specific permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON table_name TO username;

-- Grant on all tables in schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA schema_name TO username;

-- Grant on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA schema_name TO username;

-- Grant execute on functions
GRANT EXECUTE ON FUNCTION function_name TO username;

-- Revoke permissions
REVOKE ALL PRIVILEGES ON TABLE table_name FROM username;

-- Drop User
DROP USER IF EXISTS username;
```

#### Row-Level Security (RLS)

```sql
-- Enable RLS on table
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Create Policy
CREATE POLICY policy_name ON table_name
    FOR SELECT
    USING (user_id = current_user_id());

-- Create Policy for Multiple Operations
CREATE POLICY policy_name ON table_name
    FOR ALL
    USING (user_id = current_user_id())
    WITH CHECK (user_id = current_user_id());

-- Drop Policy
DROP POLICY policy_name ON table_name;

-- Disable RLS
ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
```

#### Audit Triggers

```sql
-- Create Audit Table
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL,
    record_id TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    user_id UUID,
    user_ip TEXT,
    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create Audit Function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (
        table_name, operation, record_id, old_data, new_data, user_id
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(OLD.id::text, NEW.id::text),
        CASE WHEN TG_OP IN ('DELETE', 'UPDATE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        current_user_id()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add Audit Trigger
CREATE TRIGGER audit_table_name
    BEFORE INSERT OR UPDATE OR DELETE ON table_name
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();
```

---

### A.13 Useful Extensions

#### Enable Extensions in Neon

```sql
-- UUID Generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Full-Text Search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Additional Index Types
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- Cryptography
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- JSON Operations
CREATE EXTENSION IF NOT EXISTS "jsonb";

-- IP Address Handling
CREATE EXTENSION IF NOT EXISTS "ip4r";

-- Array Operations
CREATE EXTENSION IF NOT EXISTS "intarray";

-- List All Extensions
SELECT * FROM pg_available_extensions ORDER BY name;

-- Check Installed Extensions
SELECT * FROM pg_extension ORDER BY extname;
```

---

### A.14 Common Patterns & Best Practices

#### Soft Delete Pattern

```sql
-- Table with Soft Delete
CREATE TABLE table_name (
    id UUID PRIMARY KEY,
    -- ... other columns ...
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- View for Active Records
CREATE VIEW active_records AS
SELECT * FROM table_name WHERE deleted_at IS NULL;

-- Soft Delete
UPDATE table_name 
SET deleted_at = CURRENT_TIMESTAMP 
WHERE id = 'record-id';

-- Query Active Records
SELECT * FROM active_records WHERE condition;

-- Include Deleted When Needed
SELECT * FROM table_name WHERE condition;
```

#### Audit Trail Pattern

```sql
-- Table with Audit Trail
CREATE TABLE table_name (
    id UUID PRIMARY KEY,
    -- ... other columns ...
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create Audit Trigger
CREATE OR REPLACE FUNCTION set_audit_fields()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.created_by = current_user_id();
        NEW.created_at = CURRENT_TIMESTAMP;
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.updated_by = current_user_id();
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_table_name
    BEFORE INSERT OR UPDATE ON table_name
    FOR EACH ROW
    EXECUTE FUNCTION set_audit_fields();
```

#### Pagination Pattern

```sql
-- Offset Pagination (Traditional)
SELECT * FROM products
ORDER BY id
LIMIT 20 OFFSET 40;

-- Cursor Pagination (Better for Large Datasets)
SELECT * FROM products
WHERE id > last_cursor_id
ORDER BY id
LIMIT 20;

-- Keyset Pagination
SELECT * FROM products
WHERE (created_at, id) > ('2024-01-01 00:00:00', last_id)
ORDER BY created_at, id
LIMIT 20;
```

#### API Response Pattern

```sql
-- Standard API Response Format
SELECT jsonb_build_object(
    'success', true,
    'data', jsonb_agg(jsonb_build_object(
        'id', id,
        'name', name,
        'price', price,
        'attributes', attributes
    )),
    'pagination', jsonb_build_object(
        'total', COUNT(*) OVER(),
        'limit', 20,
        'offset', 0
    )
)
FROM products
WHERE deleted_at IS NULL
LIMIT 20;
```

---

### A.15 Quick Troubleshooting

#### Common Errors & Solutions

```sql
-- Error: duplicate key value violates unique constraint
-- Solution: Use ON CONFLICT or check for existing data
INSERT INTO users (email, username) VALUES ('test@example.com', 'test_user')
ON CONFLICT (email) DO NOTHING;

-- Error: null value in column violates not-null constraint
-- Solution: Provide default value or ensure column isn't NULL
ALTER TABLE table_name ALTER COLUMN column_name SET DEFAULT default_value;

-- Error: permission denied for relation table_name
-- Solution: Grant necessary permissions
GRANT SELECT, INSERT, UPDATE ON table_name TO username;

-- Error: relation "table_name" does not exist
-- Solution: Check schema or create table
SELECT * FROM information_schema.tables WHERE table_name = 'table_name';

-- Error: could not open relation with OID
-- Solution: Table is corrupted; try REINDEX or restore from backup
REINDEX TABLE table_name;

-- Error: transaction is aborted, commands ignored
-- Solution: Rollback and retry
ROLLBACK;
BEGIN;
-- Retry transaction

-- Error: deadlock detected
-- Solution: Retry transaction or change order of operations
SET statement_timeout = '10s';
BEGIN;
-- Operations
COMMIT;
```

---

### A.16 Neon-Specific Commands

#### Neon CLI Reference

```bash
# Project Management
neonctl projects create --name project-name
neonctl projects list
neonctl projects info --id project-id

# Branch Management
neonctl branches create --name branch-name --parent main --project-id id
neonctl branches list --project-id id
neonctl branches info --name branch-name --project-id id
neonctl branches delete --name branch-name --project-id id
neonctl branches merge branch-name --target main --project-id id

# Connection Strings
neonctl branches get-connection-string branch-name --project-id id
neonctl branches get-connection-string --pooled branch-name --project-id id

# Database Management
neonctl databases create --name db-name --project-id id
neonctl databases list --project-id id

# Authentication
neonctl auth

# Version
neonctl --version
```

---

This appendix serves as your comprehensive reference for all SQL operations, Neon-specific features, and best practices covered throughout the series. Bookmark it for quick lookup during your development journey!
