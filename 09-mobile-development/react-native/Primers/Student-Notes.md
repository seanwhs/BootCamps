# Serverless Postgres with Neon: From Zero to Production
## Student Notes & Reference Guide

This comprehensive notes document serves as your personal reference for the entire course. It contains key concepts, code snippets, definitions, and space for your own annotations. Use this alongside the workbook and slide deck to reinforce your learning.

---

## TABLE OF CONTENTS

1. [Course Introduction & Architecture](#section-1)
2. [Neon Setup & Fundamentals](#section-2)
3. [PostgreSQL Core Concepts](#section-3)
4. [Data Integrity & Constraints](#section-4)
5. [Relational Database Design](#section-5)
6. [JOINs & Complex Queries](#section-6)
7. [Aggregations & Analytics](#section-7)
8. [JSONB & Semi-Structured Data](#section-8)
9. [Performance Optimization](#section-9)
10. [Transactions & ACID](#section-10)
11. [CI/CD with Neon Branches](#section-11)
12. [Security Best Practices](#section-12)
13. [Deployment & Operations](#section-13)
14. [SQL Quick Reference](#section-14)
15. [Glossary of Terms](#section-15)
16. [Personal Notes & Code Snippets](#section-16)

---

## SECTION 1: COURSE INTRODUCTION & ARCHITECTURE

### What is Neon?
- **Serverless PostgreSQL platform** that separates compute from storage
- **Scale-to-zero** capability (no paying for idle)
- **Instant database branching** (Git-like workflows)
- **Built-in connection pooling** for serverless environments
- **Free tier**: 0.5GB storage, 100 compute hours/month

### Architecture Overview

```
┌─────────────────────────────────────┐
│      Frontend Application           │
│  (React, Next.js, or any client)    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         API Layer (Your Code)       │
│  - Express.js / Fastify             │
│  - Business Logic & Validation       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│        Neon PostgreSQL              │
│  ┌───────────────────────────────┐ │
│  │        Main Branch            │ │
│  │  ┌──────────┐ ┌──────────┐  │ │
│  │  │ products │ │  users   │  │ │
│  │  │ orders   │ │ address  │  │ │
│  │  └──────────┘ └──────────┘  │ │
│  └───────────────────────────────┘ │
│              │                      │
│              ▼                      │
│  ┌───────────────────────────────┐ │
│  │   Development Branch           │ │
│  │  (Instant copy for testing)   │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Course Roadmap

| Part | Topic | Focus |
|------|-------|-------|
| 1 | Setup & Cloud SQL Fundamentals | CRUD, Basic Queries |
| 2 | Bulletproof Schemas & Data Integrity | Constraints, UUIDs, Pooling |
| 3 | Database Branching & Relational Architecture | Foreign Keys, Joins, Branches |
| 4 | Analytical Power | Aggregations, Window Functions |
| 5 | JSONB & Extensions | Semi-structured data, Search |
| 6 | Performance, Transactions & CI/CD | Optimization, Deployment |

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 2: NEON SETUP & FUNDAMENTALS

### Connection Strings

**Standard (Direct) Connection:**
```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**Pooled Connection (for Serverless):**
```
postgresql://username:password@ep-xyz-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&pool_mode=transaction
```

### Neon CLI Commands

```bash
# Authentication
neonctl auth

# Project Management
neonctl projects list
neonctl projects create --name project-name

# Branch Management
neonctl branches list --project-id PROJECT_ID
neonctl branches create --name branch-name --parent main --project-id PROJECT_ID
neonctl branches get-connection-string branch-name --project-id PROJECT_ID
neonctl branches merge branch-name --target main --project-id PROJECT_ID
neonctl branches delete branch-name --project-id PROJECT_ID

# Database Management
neonctl databases list --project-id PROJECT_ID
```

### psql Quick Commands

| Command | Description |
|---------|-------------|
| `\l` | List databases |
| `\c database` | Connect to database |
| `\dt` | List tables |
| `\d table` | Describe table |
| `\q` | Quit psql |
| `\h` | Help on SQL commands |

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 3: POSTGRESQL CORE CONCEPTS

### Data Types Reference

| Category | Type | Use Case |
|----------|------|----------|
| **Numeric** | `SERIAL` | Auto-incrementing IDs |
| | `INTEGER` | Whole numbers (-2.1B to 2.1B) |
| | `BIGINT` | Large whole numbers |
| | `NUMERIC(10,2)` | **Money (exact decimals)** |
| **Text** | `VARCHAR(255)` | Short text (names, emails) |
| | `TEXT` | Unlimited text (descriptions) |
| **Date/Time** | `TIMESTAMPTZ` | **Always use this!** |
| | `DATE` | Just the date |
| **Other** | `BOOLEAN` | True/False flags |
| | `UUID` | Universal identifiers |
| | `JSONB` | Semi-structured data |

### CRUD Operations

```sql
-- CREATE (INSERT)
INSERT INTO products (name, price) VALUES ('Widget', 19.99);

-- READ (SELECT)
SELECT * FROM products WHERE price > 10;

-- UPDATE
UPDATE products SET price = 24.99 WHERE id = 1;

-- DELETE
DELETE FROM products WHERE id = 1;
```

### Filtering Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equal | `price = 19.99` |
| `!=` | Not equal | `price != 19.99` |
| `>` | Greater than | `price > 19.99` |
| `<` | Less than | `price < 19.99` |
| `>=` | Greater or equal | `price >= 19.99` |
| `<=` | Less or equal | `price <= 19.99` |
| `IN` | In a list | `status IN ('active', 'pending')` |
| `BETWEEN` | Range | `price BETWEEN 10 AND 50` |
| `LIKE` | Pattern (case-sensitive) | `name LIKE 'W%'` |
| `ILIKE` | Pattern (case-insensitive) | `name ILIKE 'w%'` |
| `IS NULL` | Check for NULL | `description IS NULL` |

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 4: DATA INTEGRITY & CONSTRAINTS

### Constraint Types

```sql
-- NOT NULL: Value required
name VARCHAR(255) NOT NULL

-- UNIQUE: No duplicates
email VARCHAR(255) UNIQUE

-- PRIMARY KEY: Unique identifier
id UUID PRIMARY KEY

-- FOREIGN KEY: References another table
user_id UUID REFERENCES users(id)

-- CHECK: Custom validation
price NUMERIC(10,2) CHECK (price >= 0)

-- DEFAULT: Fallback value
status VARCHAR(20) DEFAULT 'active'
```

### UUID Primary Keys

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Use UUID as primary key
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT
);
```

**SERIAL vs UUID Decision:**
| Use SERIAL When | Use UUID When |
|-----------------|---------------|
| Simple internal apps | Public-facing APIs |
| No database merging | Distributed systems |
| Performance critical | Security matters |

### Email Validation Pattern
```sql
CONSTRAINT valid_email 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

### Username Validation Pattern
```sql
CONSTRAINT valid_username 
CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$')
```

### Automatic Timestamps

```sql
-- Function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

### Soft Delete Pattern

```sql
-- Soft delete
UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = 'user-id';

-- View for active users
CREATE VIEW active_users AS
SELECT * FROM users WHERE deleted_at IS NULL;
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 5: RELATIONAL DATABASE DESIGN

### Relationship Types

| Type | Description | Example |
|------|-------------|---------|
| **1:1** | One to One | User ↔ Profile |
| **1:M** | One to Many | User → Orders |
| **M:N** | Many to Many | Products ↔ Orders (via OrderItems) |

### Foreign Key Options

```sql
-- CASCADE: Delete child records
user_id UUID REFERENCES users(id) ON DELETE CASCADE

-- RESTRICT: Prevent deletion if children exist
user_id UUID REFERENCES users(id) ON DELETE RESTRICT

-- SET NULL: Set FK to NULL on deletion
user_id UUID REFERENCES users(id) ON DELETE SET NULL
```

### Complete Relational Schema Example

```sql
-- Users (1 side of 1:M with Orders)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL
);

-- Orders (M side of 1:M with Users)
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    total NUMERIC(10,2) NOT NULL
);

-- OrderItems (M:N junction between Orders and Products)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);
```

### Normalization Summary

| Normal Form | Rule | When to Apply |
|-------------|------|---------------|
| 1NF | No repeating groups | Always |
| 2NF | No partial dependencies | Always |
| 3NF | No transitive dependencies | Usually |
| BCNF | All determinants are keys | For complex rules |

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 6: JOINS & COMPLEX QUERIES

### JOIN Types

```sql
-- INNER JOIN: Only matching rows
SELECT * FROM orders o
INNER JOIN users u ON o.user_id = u.id;

-- LEFT JOIN: All from left, matches from right
SELECT * FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- RIGHT JOIN: All from right, matches from left
SELECT * FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;

-- FULL JOIN: All from both tables
SELECT * FROM users u
FULL JOIN orders o ON u.id = o.user_id;
```

### Multiple Joins

```sql
SELECT 
    o.order_number,
    u.full_name AS customer,
    sa.address_line1 AS shipping_address,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN addresses sa ON o.shipping_address_id = sa.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

### Self Join

```sql
-- Categories with parent names
SELECT 
    c1.name AS category,
    c2.name AS parent_category
FROM categories c1
LEFT JOIN categories c2 ON c1.parent_id = c2.id;
```

### Subqueries

```sql
-- In WHERE
SELECT * FROM products 
WHERE price > (SELECT AVG(price) FROM products);

-- In FROM (as derived table)
SELECT * FROM (
    SELECT * FROM products WHERE price > 100
) AS expensive_products;

-- In SELECT
SELECT 
    name,
    price,
    (SELECT AVG(price) FROM products) AS avg_price
FROM products;
```

### Common Table Expressions (CTEs)

```sql
WITH expensive_products AS (
    SELECT * FROM products WHERE price > 100
),
high_stock AS (
    SELECT * FROM products WHERE stock_quantity > 50
)
SELECT * FROM expensive_products
UNION
SELECT * FROM high_stock;
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 7: AGGREGATIONS & ANALYTICS

### Aggregate Functions

```sql
-- COUNT: Number of rows
SELECT COUNT(*) FROM orders;

-- SUM: Total values
SELECT SUM(total) FROM orders;

-- AVG: Average
SELECT AVG(total) FROM orders;

-- MIN/MAX: Minimum/Maximum
SELECT MIN(total), MAX(total) FROM orders;

-- STDDEV: Standard deviation
SELECT STDDEV(price) FROM products;
```

### GROUP BY

```sql
-- Single column
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total) AS revenue
FROM orders
GROUP BY status;

-- Multiple columns
SELECT 
    payment_method,
    status,
    COUNT(*) AS count
FROM orders
GROUP BY payment_method, status;
```

### HAVING (Filter Groups)

```sql
SELECT 
    user_id,
    COUNT(*) AS order_count,
    SUM(total) AS total_spent
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 3;
```

### Window Functions

```sql
-- ROW_NUMBER: Sequential numbering
SELECT 
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS rank
FROM products;

-- RANK with PARTITION BY
SELECT 
    name,
    price,
    category,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rank_in_category
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
```

### CASE WHEN

```sql
SELECT 
    order_number,
    total,
    CASE 
        WHEN total < 100 THEN 'Small'
        WHEN total >= 100 AND total < 500 THEN 'Medium'
        WHEN total >= 500 THEN 'Large'
    END AS order_size
FROM orders;
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 8: JSONB & SEMI-STRUCTURED DATA

### JSONB Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `->` | Get JSON field (JSON) | `attributes->'color'` |
| `->>` | Get JSON field (text) | `attributes->>'color'` |
| `#>` | Get nested (JSON) | `attributes#>>'{ports,hdmi}'` |
| `@>` | Contains | `attributes @> '{"color":"Black"}'` |
| `?` | Key exists | `attributes ? 'color'` |
| `?|` | Any key exists | `attributes ?| array['color','size']` |

### Adding JSONB Columns

```sql
ALTER TABLE products 
ADD COLUMN attributes JSONB DEFAULT '{}'::jsonb,
ADD COLUMN variants JSONB DEFAULT '[]'::jsonb,
ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
```

### Inserting JSONB Data

```sql
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'color', 'Black',
        'connectivity', 'Bluetooth 5.3',
        'battery_life', '40 hours'
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'color', 'Black',
            'price_adjustment', 0,
            'sku', 'HP-BLK-001'
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'AudioPro',
        'category', 'Audio',
        'tags', array['premium', 'wireless']
    )
WHERE name = 'Premium Headphones';
```

### Querying JSONB

```sql
-- Get specific attributes
SELECT 
    name,
    attributes->>'color' AS color,
    attributes->>'battery_life' AS battery
FROM products
WHERE attributes @> '{"noise_cancellation": "Active"}'::jsonb;

-- Query variants
SELECT 
    name,
    variants
FROM products
WHERE variants @> '[{"color": "Silver"}]'::jsonb;
```

### JSONB Indexes

```sql
-- GIN index for JSONB
CREATE INDEX idx_products_attributes_gin ON products USING gin(attributes);

-- Path-specific indexes
CREATE INDEX idx_products_brand ON products ((metadata->>'brand'));
CREATE INDEX idx_products_category ON products ((metadata->>'category'));
```

### PostgreSQL Extensions

```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- List available extensions
SELECT * FROM pg_available_extensions ORDER BY name;
```

### Fuzzy Search (pg_trgm)

```sql
-- Create trigram indexes
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);

-- Fuzzy search
SELECT * FROM products
WHERE similarity(name, 'wireless headphone') > 0.3
ORDER BY similarity(name, 'wireless headphone') DESC;
```

### Full-Text Search

```sql
-- Add search vector
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Update search vector
UPDATE products 
SET search_vector = 
    setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B');

-- Create GIN index
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);

-- Full-text search
SELECT 
    name,
    ts_rank_cd(search_vector, plainto_tsquery('wireless headphones')) AS rank
FROM products
WHERE search_vector @@ plainto_tsquery('wireless headphones')
ORDER BY rank DESC;
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 9: PERFORMANCE OPTIMIZATION

### EXPLAIN ANALYZE

```sql
-- Basic EXPLAIN (shows plan)
EXPLAIN SELECT * FROM products WHERE price > 100;

-- EXPLAIN ANALYZE (executes and shows real numbers)
EXPLAIN ANALYZE SELECT * FROM products WHERE price > 100;

-- Detailed EXPLAIN
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) 
SELECT * FROM products WHERE price > 100;
```

### Reading EXPLAIN Output

```
Seq Scan on products (cost=0.00..245.00 rows=1000 width=100)
  Filter: (price > 100)
  Rows Removed by Filter: 9000
  Buffers: shared hit=123 read=456

Key Indicators:
- "Seq Scan" → Full table scan (bad for large tables)
- "Rows Removed by Filter" → Poor selectivity
- "Buffers" → Cache hits vs disk reads
```

### Index Types

| Type | Best For | Example |
|------|----------|---------|
| B-Tree (default) | Equality, range | `WHERE price > 100` |
| GIN | JSONB, arrays, full-text | `WHERE attributes @> '{"color":"Black"}'` |
| BRIN | Very large ordered tables | `WHERE created_at > '2024-01-01'` |
| Partial | Frequent subset | `WHERE deleted_at IS NULL` |
| Covering | Index-only scans | `INCLUDE (total, status)` |

### Creating Indexes

```sql
-- B-Tree: Range queries
CREATE INDEX idx_orders_date ON orders(order_date DESC);

-- Composite: Multiple conditions
CREATE INDEX idx_orders_user_status_date ON orders(user_id, status, order_date);

-- Partial: Specific use case
CREATE INDEX idx_orders_active ON orders(order_date) 
WHERE status NOT IN ('cancelled', 'refunded');

-- Covering: Index-only scans
CREATE INDEX idx_orders_covering ON orders(user_id, order_date) 
INCLUDE (total, status);
```

### Finding Unused Indexes

```sql
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS scans,
    pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;
```

### VACUUM and ANALYZE

```sql
-- Update statistics (improves query plans)
ANALYZE orders;

-- Reclaim storage
VACUUM orders;

-- Combined
VACUUM ANALYZE orders;

-- Full vacuum (locks table)
VACUUM FULL orders;

-- Rebuild indexes
REINDEX INDEX idx_orders_date;
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 10: TRANSACTIONS & ACID

### ACID Properties

| Property | Meaning |
|----------|---------|
| **Atomicity** | All or nothing |
| **Consistency** | Data remains valid |
| **Isolation** | Transactions don't interfere |
| **Durability** | Committed data survives failures |

### Transaction Commands

```sql
BEGIN;                    -- Start transaction
SAVEPOINT savepoint_name; -- Create savepoint
ROLLBACK TO SAVEPOINT savepoint_name; -- Partial rollback
COMMIT;                   -- Save changes
ROLLBACK;                 -- Discard all changes
```

### Transaction Example

```sql
BEGIN;

-- Create order
INSERT INTO orders (user_id, total) VALUES ('user-uuid', 99.99)
RETURNING id INTO order_id;

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (order_id, 1, 2, 49.99);

-- Update inventory
UPDATE products 
SET stock_quantity = stock_quantity - 2
WHERE id = 1 AND stock_quantity >= 2;

-- If everything worked
COMMIT;

-- If something went wrong
ROLLBACK;
```

### Row-Level Locking

```sql
BEGIN;
-- Lock rows to prevent concurrent modifications
SELECT * FROM inventory 
WHERE product_id = 1 
FOR UPDATE;

-- Check availability
IF available >= requested THEN
    UPDATE inventory 
    SET reserved_quantity = reserved_quantity + requested
    WHERE product_id = 1;
    COMMIT;
ELSE
    ROLLBACK;
    RAISE EXCEPTION 'Insufficient stock';
END IF;
```

### Isolation Levels

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- Default
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Prevent non-repeatable reads
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;    -- Prevent all concurrency issues
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 11: CI/CD WITH NEON BRANCHES

### Branch Workflow

```
Production (main)
    │
    ├── development (long-lived)
    │       │
    │       ├── feature-payments (temporary)
    │       └── feature-auth (temporary)
    │
    └── staging (pre-production)
            │
            └── preview-pr-123 (auto-deleted)
```

### Branch Commands

```bash
# Create a branch
neonctl branches create --name dev-branch --parent main --project-id PROJECT_ID

# List branches
neonctl branches list --project-id PROJECT_ID

# Get connection string
neonctl branches get-connection-string dev-branch --project-id PROJECT_ID

# Merge to main
neonctl branches merge dev-branch --target main --project-id PROJECT_ID

# Delete branch
neonctl branches delete dev-branch --project-id PROJECT_ID
```

### GitHub Actions Example

```yaml
name: Database CI/CD
on: pull_request

jobs:
  test-database:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Neon CLI
        run: npm install -g neonctl
      
      - name: Create Preview Branch
        run: |
          BRANCH_NAME="preview-${{ github.event.pull_request.number }}"
          neonctl branches create \
            --name $BRANCH_NAME \
            --parent main \
            --project-id ${{ secrets.PROJECT_ID }}
      
      - name: Run Migrations
        run: |
          CONN_STRING=$(neonctl branches get-connection-string $BRANCH_NAME)
          psql "$CONN_STRING" -f migrations/*.sql
      
      - name: Run Tests
        run: |
          export DATABASE_URL=$(neonctl branches get-connection-string $BRANCH_NAME)
          npm test
```

### Migration Specialist Agent

```
1. Create test branch with 4-hour TTL
2. Run migrations on test branch
3. Validate changes thoroughly
4. Delete test branch
5. Create migration files and open PR
6. User or CI/CD applies to main
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 12: SECURITY BEST PRACTICES

### User Management

```sql
-- Create users with strong passwords
CREATE USER app_user WITH PASSWORD 'StrongPassword123!';

-- Grant minimal permissions
GRANT CONNECT ON DATABASE mydb TO app_user;
GRANT SELECT, INSERT, UPDATE ON products TO app_user;
GRANT SELECT ON orders TO app_user;

-- Create read-only user
CREATE USER read_only_user WITH PASSWORD 'readonly123';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only_user;
```

### Row-Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Policy: Users see only their orders
CREATE POLICY user_orders_policy ON orders
    FOR ALL
    USING (user_id = current_user_id())
    WITH CHECK (user_id = current_user_id());
```

### SQL Injection Prevention

```javascript
// ❌ BAD: SQL Injection vulnerable
const result = await pool.query(`SELECT * FROM users WHERE id = ${userId}`);

// ✅ GOOD: Parameterized query
const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);

// ✅ GOOD: Multiple parameters
const result = await pool.query(
    'SELECT * FROM users WHERE email = $1 AND status = $2',
    [email, status]
);
```

### Connection Security

```javascript
// Secure connection configuration
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: true,
        ca: process.env.DB_CA_CERT,
    },
    max: 20,
    statement_timeout: 30000,
    idle_in_transaction_session_timeout: 30000,
});
```

### Audit Logging

```sql
-- Create audit table
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL,
    record_id TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    user_id UUID,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create audit trigger
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, old_data, new_data)
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(OLD.id::text, NEW.id::text),
        CASE WHEN TG_OP IN ('DELETE', 'UPDATE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 13: DEPLOYMENT & OPERATIONS

### Deployment Checklist

- [ ] All migrations applied
- [ ] Backups created
- [ ] Monitoring configured
- [ ] SSL enabled
- [ ] Connection pooling configured
- [ ] Indexes created for all foreign keys
- [ ] Soft delete implemented
- [ ] RLS policies tested
- [ ] Audit logging enabled

### Health Check View

```sql
CREATE VIEW database_health AS
SELECT 
    CURRENT_TIMESTAMP AS checked_at,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT pg_database_size(current_database()) / 1024 / 1024) AS database_size_mb,
    (SELECT 
        ROUND((sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100), 2)
     FROM pg_statio_user_tables) AS cache_hit_ratio,
    (SELECT COUNT(*) FROM orders WHERE status = 'pending' AND order_date < CURRENT_DATE - INTERVAL '1 hour') AS stuck_orders,
    (SELECT COUNT(*) FROM products WHERE stock_quantity < 10) AS low_stock_items;
```

### Key Metrics to Monitor

- Connection utilization (>80% = warning)
- Cache hit ratio (<95% = warning)
- Database size growth
- Slow queries (>5 seconds)
- Long-running transactions (>5 minutes)
- Table bloat (>30%)

### Backup Commands

```bash
# Create SQL dump
pg_dump "$DATABASE_URL" > backup.sql

# Create custom format dump
pg_dump "$DATABASE_URL" --format=custom > backup.dump

# Create schema-only dump
pg_dump "$DATABASE_URL" --schema-only > schema.sql

# Restore from dump
psql "$DATABASE_URL" < backup.sql

# Restore from custom dump
pg_restore -d "$DATABASE_URL" backup.dump
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 14: SQL QUICK REFERENCE

### SELECT Syntax

```sql
SELECT [DISTINCT] columns
FROM tables
[JOIN table ON condition]
[WHERE condition]
[GROUP BY columns]
[HAVING group_condition]
[ORDER BY columns [ASC|DESC]]
[LIMIT n]
[OFFSET m];
```

### INSERT Syntax

```sql
INSERT INTO table (columns)
VALUES (values)
[RETURNING *];

INSERT INTO table (columns)
SELECT columns FROM other_table;
```

### UPDATE Syntax

```sql
UPDATE table
SET column = value, column2 = value2
WHERE condition
[RETURNING *];
```

### DELETE Syntax

```sql
DELETE FROM table
WHERE condition
[RETURNING *];
```

### Common Query Patterns

```sql
-- Pagination
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 40;

-- Upsert (Insert or Update)
INSERT INTO users (id, name) VALUES (1, 'Alice')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- Bulk Insert
INSERT INTO products (name, price) VALUES 
    ('Product A', 19.99),
    ('Product B', 29.99),
    ('Product C', 39.99);
```

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 15: GLOSSARY OF TERMS

| Term | Definition |
|------|------------|
| **ACID** | Atomicity, Consistency, Isolation, Durability |
| **Branch** | A copy of a database in Neon that can be modified independently |
| **CRUD** | Create, Read, Update, Delete |
| **CTE** | Common Table Expression (WITH clause) |
| **Foreign Key** | A column that references a primary key in another table |
| **GIN** | Generalized Inverted Index (for JSONB, arrays, full-text) |
| **JSONB** | Binary JSON - PostgreSQL's efficient JSON storage format |
| **Migration** | A script that changes database schema |
| **Normalization** | Organizing data to reduce redundancy |
| **Pooled Connection** | Connection through Neon's connection pooler |
| **RLS** | Row Level Security - controls which rows a user can see |
| **Schema** | The structure of a database (tables, columns, constraints) |
| **Soft Delete** | Marking a record as deleted without physically removing it |
| **Trigram** | A group of three consecutive characters used for fuzzy search |
| **UUID** | Universally Unique Identifier - a 128-bit unique identifier |
| **View** | A stored query that acts like a virtual table |
| **Window Function** | Calculation across rows related to current row |

### My Notes:
```
_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________
```

---

## SECTION 16: PERSONAL NOTES & CODE SNIPPETS

### Useful Code Snippets

```sql
-- Add your favorite code snippets here:

_______________________________________________________________________
_______________________________________________________________________
_______________________________________________________________________

```

### Common Errors & Solutions

| Error | Solution |
|-------|----------|
| duplicate key value violates unique constraint | Use ON CONFLICT or check for existing data |
| null value violates not-null constraint | Provide default value or ensure column isn't NULL |
| permission denied for relation | Grant necessary permissions |
| relation "table_name" does not exist | Check schema or create table |
| transaction is aborted, commands ignored | ROLLBACK; BEGIN; retry |

### Course Resources

- Neon Documentation: https://neon.tech/docs
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- GitHub Repository: (Add your repo link)
- Discord Community: https://discord.gg/neon

### Key Takeaways

1. _______________________________________________________________________
2. _______________________________________________________________________
3. _______________________________________________________________________
4. _______________________________________________________________________
5. _______________________________________________________________________

---

## CONCLUSION

Congratulations on completing the Serverless Postgres with Neon course!

**You've learned:**
- ✅ How to provision and connect to a Neon database
- ✅ SQL fundamentals and CRUD operations
- ✅ Data integrity with constraints and UUIDs
- ✅ Relational database design and JOINs
- ✅ Analytics with aggregations and window functions
- ✅ JSONB for flexible data and fuzzy search
- ✅ Performance optimization and indexing
- ✅ ACID transactions and inventory management
- ✅ CI/CD with Neon branches
- ✅ Security best practices
- ✅ Production deployment and monitoring

**Next Steps:**
1. Build your frontend (React, Next.js, Vue, etc.)
2. Add authentication with Neon Auth or your preferred solution
3. Deploy to your preferred cloud provider
4. Continue learning with the Neon community
5. Build something amazing!

---

**[END OF NOTES]**

*These notes are your companion to the course. Review them regularly, add your own notes, and keep building!* 🚀
