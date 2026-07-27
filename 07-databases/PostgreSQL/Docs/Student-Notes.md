# HANDS-ON POSTGRESQL: FROM ZERO TO SCHEMA HERO
## STUDENT NOTES

### Complete Lecture Notes with Key Takeaways

---

# PART 1: FIRST STEPS & THE SQL FOUNDATION

## 1.1 What is PostgreSQL?

**Key Definition:** PostgreSQL is a powerful, open-source relational database management system (RDBMS). It's like a highly organized digital filing system where you can store, retrieve, and manipulate data.

**Why PostgreSQL?**
- Industry-standard for production applications
- Supports advanced features (JSONB, full-text search)
- ACID compliant (Atomicity, Consistency, Isolation, Durability)
- Open-source and free
- Excellent performance and reliability

---

## 1.2 Connecting to PostgreSQL

**Connect with psql:**
```bash
psql -d database_name -U username -h hostname
```

**Common psql Commands:**
```
\l          - List all databases
\c dbname   - Connect to a database
\dt         - List all tables
\d tablename - Describe a table
\q          - Quit psql
```

**Connection String Format:**
```
postgresql://username:password@host:port/database
```

---

## 1.3 The Four SQL Operations (CRUD)

| Operation | SQL Command | Description |
|-----------|-------------|-------------|
| Create | INSERT | Add new data |
| Read | SELECT | Retrieve data |
| Update | UPDATE | Modify existing data |
| Delete | DELETE | Remove data |

**The Golden Rule:** Always use a WHERE clause with UPDATE and DELETE unless you intend to affect EVERY row.

---

## 1.4 SELECT Syntax

```sql
SELECT column1, column2
FROM table_name
WHERE condition
ORDER BY column ASC/DESC
LIMIT number
OFFSET number;
```

**SELECT Order of Execution:**
1. FROM (which tables)
2. WHERE (filter rows)
3. GROUP BY (group rows)
4. HAVING (filter groups)
5. SELECT (choose columns)
6. ORDER BY (sort)
7. LIMIT / OFFSET (paginate)

---

## 1.5 Common WHERE Operators

| Operator | Description | Example |
|----------|-------------|---------|
| = | Equal | `price = 19.99` |
| != or <> | Not equal | `price != 19.99` |
| > | Greater than | `price > 20` |
| < | Less than | `price < 20` |
| >= | Greater than or equal | `price >= 20` |
| <= | Less than or equal | `price <= 20` |
| LIKE | Pattern match (case-sensitive) | `name LIKE 'S%'` |
| ILIKE | Pattern match (case-insensitive) | `name ILIKE '%wireless%'` |
| IN | In a list | `price IN (10, 20, 30)` |
| BETWEEN | Within a range | `price BETWEEN 10 AND 20` |
| IS NULL | Is null | `description IS NULL` |
| IS NOT NULL | Is not null | `description IS NOT NULL` |

---

## 1.6 Pattern Matching

**LIKE Wildcards:**
- `%` - Any sequence of characters
- `_` - A single character

**Examples:**
```sql
'Smith%'   -- Starts with 'Smith'
'%son'     -- Ends with 'son'
'%mith%'   -- Contains 'mith'
'_ohn'     -- Any character followed by 'ohn'
'[SJ]%'    -- Starts with 'S' or 'J'
```

---

## 1.7 Quick Reference: CRUD Examples

```sql
-- INSERT: Multiple rows
INSERT INTO products (name, price) VALUES
    ('Product A', 19.99),
    ('Product B', 29.99);

-- SELECT: With conditions
SELECT name, price FROM products
WHERE price > 20 AND stock > 0
ORDER BY price DESC
LIMIT 10;

-- UPDATE: With calculation
UPDATE products
SET price = price * 1.10
WHERE category = 'Electronics';

-- DELETE: With safety check
DELETE FROM products
WHERE stock = 0 AND is_active = false
RETURNING id, name;
```

---

# PART 2: DATA TYPES & CONSTRAINTS

## 2.1 Common PostgreSQL Data Types

### Numeric Types
| Type | Use Case |
|------|----------|
| `SMALLINT` | Small numbers (-32k to 32k) |
| `INTEGER` | Standard whole numbers |
| `BIGINT` | Very large whole numbers |
| `DECIMAL(10,2)` | Exact decimals (money) |
| `NUMERIC(10,2)` | Same as DECIMAL |
| `REAL` | Approximate float (6 digits) |
| `DOUBLE PRECISION` | Approximate double (15 digits) |

### Character Types
| Type | Use Case |
|------|----------|
| `TEXT` | Unlimited text |
| `VARCHAR(255)` | Text with max length |
| `CHAR(10)` | Fixed length text |

### Date/Time Types
| Type | Use Case |
|------|----------|
| `DATE` | Just the date |
| `TIME` | Just the time |
| `TIMESTAMPTZ` | Date/time with timezone (recommended) |
| `INTERVAL` | Time duration |

### Special Types
| Type | Use Case |
|------|----------|
| `BOOLEAN` | True/false values |
| `UUID` | Globally unique identifiers |
| `JSONB` | Flexible, semi-structured data |

---

## 2.2 Constraints Quick Reference

| Constraint | Syntax | Purpose |
|------------|--------|---------|
| NOT NULL | `column_name TEXT NOT NULL` | Prevents empty values |
| UNIQUE | `column_name TEXT UNIQUE` | Prevents duplicates |
| CHECK | `CHECK (price >= 0)` | Validates data |
| DEFAULT | `DEFAULT 0` | Sets default value |
| PRIMARY KEY | `id UUID PRIMARY KEY` | Unique row identifier |
| FOREIGN KEY | `FOREIGN KEY (user_id) REFERENCES users(id)` | References another table |

**Check Constraint Pattern:**
```sql
CONSTRAINT email_format CHECK (
    email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
)
```

**Regex Pattern Memory Aid:**
```
^                 - Start of string
[A-Za-z0-9._%+-]+ - Local part (letters, numbers, dots, etc.)
@                 - At symbol
[A-Za-z0-9.-]+   - Domain name
\.                - Dot
[A-Za-z]{2,}     - TLD (at least 2 characters)
$                 - End of string
```

---

## 2.3 UUID Generation

```sql
-- Enable extension (once)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Generate UUID
SELECT uuid_generate_v4();  -- Random UUID
SELECT gen_random_uuid();   -- Alternative method

-- Use in table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
);
```

**UUID vs SERIAL:**
- UUID: Globally unique, better for distributed systems, larger storage
- SERIAL: Sequential, smaller storage, easier to read

---

## 2.4 JSONB Operations

**Key Operators:**
| Operator | Description | Example |
|----------|-------------|---------|
| `->` | Get JSON object field | `metadata->'brand'` |
| `->>` | Get field as text | `metadata->>'brand'` |
| `?` | Check if key exists | `metadata ? 'brand'` |
| `@>` | Check if contains | `metadata @> '{"eco": true}'` |

**JSONB Functions:**
```sql
-- Create JSON
jsonb_build_object('key', 'value')
jsonb_build_array('item1', 'item2')

-- Update JSON
jsonb_set(json, '{path}', 'new_value')
jsonb || '{"new_key": "value"}'::jsonb

-- Delete key
jsonb - 'key'
jsonb - ARRAY['key1', 'key2']
```

---

# PART 3: RELATIONSHIPS & RELATIONAL QUERIES

## 3.1 Relationship Types

| Type | Pattern | Example |
|------|---------|---------|
| One-to-Many | PK on 1 side, FK on many side | Customer → Orders |
| Many-to-Many | Junction table | Products ↔ Orders |
| One-to-One | PK on one side, FK with UNIQUE | User → Profile |

**Foreign Key Options:**
```sql
-- ON DELETE CASCADE: Delete child records when parent is deleted
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE

-- ON DELETE SET NULL: Set FK to NULL when parent is deleted
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL

-- ON DELETE RESTRICT: Prevent deletion of parent with children
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
```

---

## 3.2 JOIN Types Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│                        INNER JOIN                          │
│  ┌──────────┐         ┌──────────┐                       │
│  │  Table A │─────────│  Table B │  Returns only matching │
│  └──────────┘         └──────────┘  rows from both       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                        LEFT JOIN                           │
│  ┌──────────┐         ┌──────────┐                       │
│  │  Table A │─────────│  Table B │  Returns all rows from │
│  └──────────┘         └──────────┘  A, matches from B    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                       RIGHT JOIN                           │
│  ┌──────────┐         ┌──────────┐                       │
│  │  Table A │─────────│  Table B │  Returns all rows from │
│  └──────────┘         └──────────┘  B, matches from A    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      FULL OUTER JOIN                       │
│  ┌──────────┐         ┌──────────┐                       │
│  │  Table A │─────────│  Table B │  Returns all rows from │
│  └──────────┘         └──────────┘  both tables          │
└─────────────────────────────────────────────────────────────┘
```

**JOIN Memory Aid:**
- **INNER** = Only matches
- **LEFT** = Keep left table
- **RIGHT** = Keep right table
- **FULL** = Keep all rows

---

## 3.3 Sample JOIN Queries

```sql
-- One-to-Many: Get customers with their orders
SELECT u.email, o.id, o.total
FROM users u
LEFT JOIN orders o ON o.user_id = u.id;

-- Many-to-Many: Get products in categories
SELECT p.name, c.name AS category
FROM products p
JOIN product_categories pc ON pc.product_id = p.id
JOIN categories c ON c.id = pc.category_id;

-- Self Join: Hierarchical categories
SELECT c1.name AS category, c2.name AS parent
FROM categories c1
LEFT JOIN categories c2 ON c2.id = c1.parent_id;
```

---

# PART 4: AGGREGATIONS, GROUPING & SUBQUERIES

## 4.1 Aggregate Functions

| Function | Use | Example |
|----------|-----|---------|
| `COUNT(*)` | Count all rows | `SELECT COUNT(*) FROM orders` |
| `COUNT(DISTINCT col)` | Count unique values | `SELECT COUNT(DISTINCT user_id) FROM orders` |
| `SUM(col)` | Add values | `SELECT SUM(total) FROM orders` |
| `AVG(col)` | Average value | `SELECT AVG(total) FROM orders` |
| `MIN(col)` | Minimum value | `SELECT MIN(total) FROM orders` |
| `MAX(col)` | Maximum value | `SELECT MAX(total) FROM orders` |

**COUNT vs COUNT(DISTINCT):**
```sql
SELECT COUNT(*) FROM users;           -- Total users
SELECT COUNT(DISTINCT country) FROM users; -- Unique countries
```

---

## 4.2 GROUP BY Pattern

```sql
SELECT 
    column_to_group_by,
    AGGREGATE_FUNCTION(column_to_aggregate)
FROM table_name
WHERE row_filter_condition
GROUP BY column_to_group_by
HAVING group_filter_condition
ORDER BY column_to_group_by;
```

**Common GROUP BY Examples:**
```sql
-- Count by status
SELECT status, COUNT(*), SUM(total)
FROM orders
GROUP BY status;

-- Monthly revenue
SELECT DATE_TRUNC('month', created_at) AS month, SUM(total)
FROM orders
GROUP BY month
ORDER BY month;

-- Average order by customer
SELECT user_id, COUNT(*), AVG(total)
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 1;
```

---

## 4.3 Subquery Types

| Type | Returns | Used In | Example |
|------|---------|---------|---------|
| Scalar | Single value | SELECT, WHERE | `WHERE price > (SELECT AVG(price) FROM products)` |
| Column | One column | WHERE IN | `WHERE id IN (SELECT product_id FROM order_items)` |
| Table | Multiple columns | FROM | `FROM (SELECT * FROM orders WHERE status = 'paid')` |
| Correlated | Depends on outer query | WHERE EXISTS | `WHERE EXISTS (SELECT 1 FROM orders WHERE user_id = users.id)` |

**Correlated Subquery Pattern:**
```sql
SELECT 
    u.email,
    (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) AS order_count
FROM users u;
```

---

## 4.4 CASE WHEN Pattern

```sql
CASE 
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END
```

**Common Use Cases:**
```sql
-- Price categorization
CASE 
    WHEN price < 20 THEN 'Budget'
    WHEN price < 50 THEN 'Economy'
    WHEN price < 100 THEN 'Mid-Range'
    ELSE 'Premium'
END AS price_tier

-- Status mapping
CASE status
    WHEN 'pending' THEN 'Awaiting Payment'
    WHEN 'paid' THEN 'Payment Confirmed'
    WHEN 'shipped' THEN 'On the Way'
    ELSE 'Unknown'
END AS friendly_status

-- Conditional calculation
CASE 
    WHEN total > 100 THEN total * 0.10
    WHEN total > 50 THEN total * 0.05
    ELSE 0
END AS discount
```

---

# PART 5: MODERN POSTGRES POWER TOOLS

## 5.1 JSONB Summary

**When to Use JSONB:**
- Semi-structured data
- Evolving schemas
- Flexible attributes
- Nested data structures
- Data that varies significantly between rows

**When NOT to Use JSONB:**
- Well-defined, stable schema
- Data that needs to be referenced by foreign keys
- Data you need to join on
- Data you query frequently by specific fields

---

## 5.2 Window Functions Summary

**Common Window Functions:**

| Function | Description |
|----------|-------------|
| `ROW_NUMBER()` | Sequential number (no ties) |
| `RANK()` | Rank with gaps on ties |
| `DENSE_RANK()` | Rank without gaps |
| `NTILE(n)` | Divide into n groups |
| `LAG(column)` | Previous row value |
| `LEAD(column)` | Next row value |
| `FIRST_VALUE()` | First row in window |
| `LAST_VALUE()` | Last row in window |

**Window Function Syntax:**
```sql
function_name() OVER (
    [PARTITION BY column]
    [ORDER BY column]
    [ROWS BETWEEN frame_start AND frame_end]
)
```

**Window Frame Options:**
```
UNBOUNDED PRECEDING
n PRECEDING
CURRENT ROW
n FOLLOWING
UNBOUNDED FOLLOWING
```

---

## 5.3 Window Function Examples

```sql
-- Ranking (no ties)
ROW_NUMBER() OVER (ORDER BY total DESC)

-- Ranking with ties
RANK() OVER (ORDER BY total DESC)
DENSE_RANK() OVER (ORDER BY total DESC)

-- Per group ranking
ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC)

-- Previous/next values
LAG(total) OVER (ORDER BY created_at)
LEAD(total) OVER (ORDER BY created_at)

-- Running total
SUM(total) OVER (ORDER BY created_at)

-- Moving average
AVG(total) OVER (ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)

-- Percentiles
NTILE(4) OVER (ORDER BY total)  -- Quartiles
CUME_DIST() OVER (ORDER BY total)  -- Cumulative distribution
PERCENT_RANK() OVER (ORDER BY total)  -- Percent rank
```

---

# PART 6: PERFORMANCE, INDEXES & TRANSACTIONS

## 6.1 EXPLAIN ANALYZE Quick Guide

**What to Look For:**

1. **Scan Type:**
   - `Seq Scan` - Full table scan (slow on large tables)
   - `Index Scan` - Uses index (fast)
   - `Index Only Scan` - All data in index (fastest)
   - `Bitmap Scan` - Combines multiple indexes (good)

2. **Execution Time:**
   - `< 100ms` = Excellent
   - `100ms - 1s` = Good
   - `1s - 10s` = Needs optimization
   - `> 10s` = Critical issue

3. **Buffer Usage:**
   - `shared hit` = Data in cache (good)
   - `shared read` = Data from disk (slow)

**EXPLAIN Formats:**
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT ...
EXPLAIN (ANALYZE, BUFFERS, FORMAT YAML) SELECT ...
```

---

## 6.2 Index Quick Reference

**When to Create an Index:**
1. Columns used in WHERE clauses
2. Foreign key columns
3. Columns used in ORDER BY
4. Columns used in GROUP BY
5. Columns used in JOIN conditions

**When NOT to Create an Index:**
1. Very small tables (< 1000 rows)
2. Frequently updated columns
3. Columns with very few unique values
4. Columns rarely used in queries

**Index Types:**
| Type | Syntax | Use Case |
|------|--------|----------|
| B-Tree | `CREATE INDEX ON table(column)` | Default, equality and range |
| GIN | `CREATE INDEX ON table USING gin(column)` | JSONB, arrays, full-text |
| GiST | `CREATE INDEX ON table USING gist(column)` | Geometric, full-text |
| Partial | `CREATE INDEX ON table(column) WHERE condition` | Subset of rows |
| Unique | `CREATE UNIQUE INDEX ON table(column)` | Enforce uniqueness |
| Composite | `CREATE INDEX ON table(col1, col2)` | Multiple columns |
| Expression | `CREATE INDEX ON table(LOWER(column))` | Computed values |
| Covering | `CREATE INDEX ON table(column) INCLUDE (col2)` | Index-only scans |

---

## 6.3 Transaction Quick Reference

**Transaction Commands:**
```sql
BEGIN;                    -- Start transaction
SAVEPOINT name;          -- Create savepoint
ROLLBACK TO SAVEPOINT name; -- Rollback to savepoint
RELEASE SAVEPOINT name;  -- Release savepoint
COMMIT;                  -- Save changes
ROLLBACK;                -- Discard changes
```

**Isolation Levels:**
| Level | Description |
|-------|-------------|
| READ COMMITTED | Default, sees committed changes |
| REPEATABLE READ | Consistent snapshot |
| SERIALIZABLE | Strictest, prevents all anomalies |

**Lock Types:**
```sql
-- Row locks
SELECT ... FOR UPDATE;          -- Write lock
SELECT ... FOR UPDATE NOWAIT;   -- Don't wait if locked
SELECT ... FOR UPDATE SKIP LOCKED; -- Skip locked rows

-- Advisory locks
SELECT pg_advisory_lock(key);   -- Application-level lock
SELECT pg_advisory_unlock(key); -- Release lock
```

---

## 6.4 Performance Tuning Checklist

**1. Query Level:**
- [ ] Use EXPLAIN ANALYZE
- [ ] Add appropriate indexes
- [ ] Avoid SELECT *
- [ ] Use LIMIT for testing
- [ ] Filter before joining

**2. Schema Level:**
- [ ] Proper data types
- [ ] Normalized design
- [ ] Foreign key indexes
- [ ] Appropriate constraints

**3. Configuration Level:**
- [ ] shared_buffers = 25% of RAM
- [ ] work_mem = 16-64MB
- [ ] maintenance_work_mem = 1GB
- [ ] effective_cache_size = 75% of RAM
- [ ] max_connections = 200-500

**4. Maintenance Level:**
- [ ] Regular VACUUM ANALYZE
- [ ] Monitor index usage
- [ ] Check table bloat
- [ ] Review slow logs

---

# COMMON POSTGRESQL PITFALLS

## Pitfall 1: Missing Index on Foreign Key

**Problem:** Joins between tables are slow.
**Symptom:** Seq Scan on foreign key column.
**Solution:**
```sql
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

---

## Pitfall 2: Using LIKE on Unindexed Column

**Problem:** Text searches are slow.
**Symptom:** Seq Scan with filter on LIKE.
**Solution:**
```sql
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
-- Then use ILIKE or % on the right side only
```

---

## Pitfall 3: UPDATE/DELETE Without WHERE

**Problem:** All rows updated or deleted.
**Symptom:** Unintended data loss.
**Solution:**
```sql
-- Always test with SELECT first
SELECT * FROM table WHERE condition;
-- Then UPDATE/DELETE with same condition
UPDATE table SET column = value WHERE condition;
```

---

## Pitfall 4: Forgetting COMMIT in Transaction

**Problem:** Transactions left open, locking resources.
**Symptom:** Slow queries, blocked operations.
**Solution:**
```sql
BEGIN;
-- Do work
COMMIT;  -- Always commit or rollback
```

---

## Pitfall 5: Using NULL in Comparisons

**Problem:** NULL is not equal to anything, not even NULL.
**Symptom:** Missing rows in results.
**Solution:**
```sql
-- Wrong
SELECT * FROM users WHERE email = NULL;

-- Correct
SELECT * FROM users WHERE email IS NULL;
```

---

# QUICK COMMAND REFERENCE

## Most Common Commands

```sql
-- Create table
CREATE TABLE name (col type CONSTRAINTS);

-- Insert data
INSERT INTO name (col) VALUES (value);

-- Select data
SELECT * FROM name WHERE condition;

-- Update data
UPDATE name SET col = value WHERE condition;

-- Delete data
DELETE FROM name WHERE condition;

-- Add column
ALTER TABLE name ADD COLUMN col type;

-- Create index
CREATE INDEX idx_name ON name(col);

-- View table structure
\d table_name

-- List tables
\dt
```

---

## Error Message Quick Guide

| Error | Meaning | Solution |
|-------|---------|----------|
| `relation "x" does not exist` | Table doesn't exist | Check spelling, create table |
| `duplicate key value violates unique constraint` | Duplicate value | Use ON CONFLICT or check data |
| `syntax error at or near` | SQL syntax error | Check SQL syntax |
| `column "x" does not exist` | Column doesn't exist | Check column name |
| `null value in column "x" violates not-null` | Missing value | Provide value or allow NULL |
| `ERROR: operator does not exist` | Wrong data type | Cast or use correct type |

---

# USEFUL POSTGRESQL QUERIES

## Monitoring Queries

```sql
-- Active connections
SELECT pid, usename, state, query FROM pg_stat_activity;

-- Table sizes
SELECT tablename, pg_size_pretty(pg_total_relation_size(tablename))
FROM pg_tables WHERE schemaname = 'public';

-- Index usage
SELECT indexname, idx_scan FROM pg_stat_user_indexes;

-- Query performance
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY total_time DESC LIMIT 10;

-- Cache hit ratio
SELECT 
    ROUND(100 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0), 2) AS cache_hit_ratio
FROM pg_statio_user_tables;
```

---

## Data Quality Queries

```sql
-- Check for duplicates
SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;

-- Find orphans (records with broken FKs)
SELECT * FROM orders o LEFT JOIN users u ON u.id = o.user_id WHERE u.id IS NULL;

-- Check for NULLs in important columns
SELECT COUNT(*) FROM orders WHERE shipping_address IS NULL;

-- Find missing indexes
SELECT conname, conrelid::regclass
FROM pg_constraint
WHERE contype = 'f'
AND conrelid NOT IN (SELECT indrelid FROM pg_index);
```

---

# QUICK GLOSSARY

| Term | Definition |
|------|------------|
| ACID | Atomicity, Consistency, Isolation, Durability |
| B-Tree | Balanced tree index structure |
| CRUD | Create, Read, Update, Delete |
| CTE | Common Table Expression (WITH clause) |
| FK | Foreign Key - references another table |
| GIN | Generalized Inverted Index |
| MVCC | Multi-Version Concurrency Control |
| PK | Primary Key - unique row identifier |
| TOAST | The Oversized-Attribute Storage Technique |
| WAL | Write-Ahead Log - transaction log |
| JSONB | Binary JSON format |

---

# NOTES SPACE

Use this space for your own notes, code snippets, and questions:

```
═══════════════════════════════════════════════════════════════
PART 1 NOTES:
═══════════════════════════════════════════════════════════════



═══════════════════════════════════════════════════════════════
PART 2 NOTES:
═══════════════════════════════════════════════════════════════



═══════════════════════════════════════════════════════════════
PART 3 NOTES:
═══════════════════════════════════════════════════════════════



═══════════════════════════════════════════════════════════════
PART 4 NOTES:
═══════════════════════════════════════════════════════════════



═══════════════════════════════════════════════════════════════
PART 5 NOTES:
═══════════════════════════════════════════════════════════════



═══════════════════════════════════════════════════════════════
PART 6 NOTES:
═══════════════════════════════════════════════════════════════



═══════════════════════════════════════════════════════════════
FREQUENTLY USED QUERIES:
═══════════════════════════════════════════════════════════════



═══════════════════════════════════════════════════════════════
QUESTIONS TO RESEARCH:
═══════════════════════════════════════════════════════════════



```
