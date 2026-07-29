# Serverless Postgres with Neon: From Zero to Production

## Primer 4: SQL Optimization & Performance Tuning

### Overview

This primer is your guide to making PostgreSQL queries fast and efficient. Think of it as learning how to drive your database for maximum performance—when to accelerate, when to brake, and how to maintain your engine. Whether you're dealing with a few thousand rows or millions, these optimization techniques will help you get the most out of your database.

---

### P4.1 Understanding Query Performance

#### Why Queries Become Slow

```
Slow Query Causes:
┌─────────────────────────────────────────────────────────────┐
│ 1. Missing Indexes       → Full table scans               │
│ 2. Poorly Written SQL    → Inefficient joins              │
│ 3. Data Growth           → More data to process           │
│ 4. Locking Contention    → Queries waiting for locks      │
│ 5. Outdated Statistics   → Bad query plans               │
│ 6. Network Latency       → Slow data transfer            │
│ 7. Hardware Limits       → CPU, memory, I/O bottlenecks  │
└─────────────────────────────────────────────────────────────┘
```

#### The Query Execution Process

```
1. Parser       → Check syntax, build parse tree
2. Rewriter     → Apply rules, expand views
3. Planner      → Generate possible plans
4. Optimizer    → Choose cheapest plan
5. Executor     → Execute plan, return results
```

**The Optimizer is key**—it chooses the best way to execute your query based on table statistics.

---

### P4.2 EXPLAIN and EXPLAIN ANALYZE

#### Reading Execution Plans

```sql
-- Simple EXPLAIN (shows plan, doesn't execute)
EXPLAIN SELECT * FROM products WHERE price > 100;

-- EXPLAIN ANALYZE (executes and shows real numbers)
EXPLAIN ANALYZE SELECT * FROM products WHERE price > 100;

-- EXPLAIN with more detail
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) 
SELECT * FROM products WHERE price > 100;

-- EXPLAIN with JSON format (for tools)
EXPLAIN (ANALYZE, FORMAT JSON) 
SELECT * FROM products WHERE price > 100;
```

#### Understanding the Output

```
Seq Scan on products (cost=0.00..245.00 rows=1000 width=100)
  Filter: (price > 100)
  Rows Removed by Filter: 9000
  Buffers: shared hit=123 read=456

Breakdown:
- "Seq Scan": Scanning the entire table
- "cost=0.00..245.00": Estimated cost (start..total)
- "rows=1000": Estimated rows returned
- "width=100": Average row size in bytes
- "Filter": The condition being applied
- "Rows Removed": Rows that didn't match
- "Buffers": Disk reads and cache hits
```

#### What to Look For

| Indicator | Problem | Solution |
|-----------|---------|----------|
| "Seq Scan" on large table | Missing index | Add index on filtered column |
| "Nested Loop" on huge tables | Inefficient join | Add indexes or use different join type |
| "Sort" without index | No index on ORDER BY | Add index on ORDER BY column |
| "Rows Removed" high | Poor selectivity | Add composite index |
| "Buffer hits" low | Cache miss | Increase shared_buffers |

---

### P4.3 Indexing Strategies

#### Types of Indexes

**1. B-Tree Index (Default)**
```sql
-- Best for: Equality, range queries, sorting
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_orders_date_status ON orders(order_date, status);

-- Usage
SELECT * FROM products WHERE price BETWEEN 100 AND 200;
SELECT * FROM orders ORDER BY order_date;
```

**2. Hash Index**
```sql
-- Best for: Equality comparisons only
CREATE INDEX idx_products_sku_hash ON products USING hash(sku);

-- Usage (only = operator)
SELECT * FROM products WHERE sku = 'ABC-123';
```

**3. GIN Index**
```sql
-- Best for: JSONB, arrays, full-text search
CREATE INDEX idx_products_attributes ON products USING gin(attributes);
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);
CREATE INDEX idx_products_tags ON products USING gin(metadata->'tags');

-- Usage
SELECT * FROM products WHERE attributes @> '{"color": "Black"}'::jsonb;
SELECT * FROM products WHERE metadata->'tags' @> '["wireless"]';
```

**4. BRIN Index**
```sql
-- Best for: Very large tables with natural ordering
CREATE INDEX idx_orders_date_brin ON orders USING brin(created_at);

-- Usage (range queries on ordered data)
SELECT * FROM orders WHERE created_at >= '2024-01-01';
```

**5. Partial Index**
```sql
-- Best for: Frequently queried subset of data
CREATE INDEX idx_products_active ON products(name) WHERE deleted_at IS NULL;

-- Usage (only queries with the WHERE condition)
SELECT * FROM products WHERE name LIKE 'A%' AND deleted_at IS NULL;
```

**6. Covering Index**
```sql
-- Best for: Queries that only need specific columns
CREATE INDEX idx_orders_covering ON orders(user_id) INCLUDE (total, status);

-- Usage (index-only scan)
SELECT user_id, total, status FROM orders WHERE user_id = 123;
```

#### Choosing the Right Index

```sql
-- Analyze query patterns
SELECT 
    schemaname,
    tablename,
    seq_scan AS full_scans,
    seq_tup_read AS tuples_read,
    idx_scan AS index_scans,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_scan DESC;

-- Find missing indexes
SELECT 
    relname AS table_name,
    seq_scan AS full_scans,
    seq_tup_read / seq_scan AS avg_tuples_per_scan
FROM pg_stat_user_tables
WHERE seq_scan > 1000
ORDER BY seq_scan DESC;
```

#### Index Best Practices

```sql
-- 1. Index columns used in WHERE, JOIN, ORDER BY
-- Good
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_products_category ON products(category_id);

-- 2. Create composite indexes for multiple conditions
-- Good (order matters: place most selective column first)
CREATE INDEX idx_orders_user_status_date ON orders(user_id, status, order_date);

-- 3. Use partial indexes for common filters
-- Good
CREATE INDEX idx_orders_active ON orders(order_date) WHERE status = 'active';

-- 4. Use covering indexes for common queries
-- Good
CREATE INDEX idx_orders_covering ON orders(user_id) INCLUDE (total, status);

-- 5. Monitor index usage and remove unused
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS scans
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY schemaname, tablename;
```

---

### P4.4 Query Optimization Techniques

#### 1. Use SELECT Wisely

```sql
-- Bad: Selecting all columns
SELECT * FROM products WHERE category = 'Electronics';

-- Good: Only needed columns
SELECT id, name, price FROM products WHERE category = 'Electronics';

-- Best: Using covering index
SELECT id, name, price FROM products 
WHERE category = 'Electronics' AND price > 100;
-- Ensure index includes (category, price, id, name)
```

#### 2. Use WHERE Effectively

```sql
-- Bad: Function in WHERE (can't use index)
SELECT * FROM products WHERE UPPER(name) = 'KEYBOARD';

-- Good: Match index
SELECT * FROM products WHERE name = 'Keyboard';

-- Good: Use expression index if needed
CREATE INDEX idx_products_name_upper ON products(UPPER(name));
SELECT * FROM products WHERE UPPER(name) = 'KEYBOARD';

-- Bad: Using OR
SELECT * FROM products WHERE category = 'Electronics' OR category = 'Audio';

-- Good: Use IN
SELECT * FROM products WHERE category IN ('Electronics', 'Audio');

-- Bad: Using NOT IN with subquery
SELECT * FROM products WHERE category_id NOT IN (SELECT id FROM categories WHERE active = false);

-- Good: Use NOT EXISTS
SELECT * FROM products p 
WHERE NOT EXISTS (SELECT 1 FROM categories c WHERE c.id = p.category_id AND c.active = false);
```

#### 3. Optimize JOINs

```sql
-- Bad: Joining without filtering first
SELECT 
    o.order_number,
    u.full_name,
    p.name
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

-- Good: Filter before joining
WITH recent_orders AS (
    SELECT * FROM orders 
    WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT 
    o.order_number,
    u.full_name,
    p.name
FROM recent_orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

-- Best: Use proper indexes
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

#### 4. Use EXISTS vs IN

```sql
-- Bad: IN with large subquery
SELECT * FROM users 
WHERE id IN (SELECT user_id FROM orders WHERE total > 1000);

-- Good: EXISTS (stops at first match)
SELECT * FROM users u 
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id AND o.total > 1000);

-- Bad: NOT IN with NULLs (dangerous!)
SELECT * FROM users WHERE id NOT IN (SELECT user_id FROM orders);

-- Good: NOT EXISTS (handles NULLs safely)
SELECT * FROM users u 
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);
```

#### 5. Use CTEs for Complex Queries

```sql
-- Bad: Nested subqueries (hard to read and maintain)
SELECT * FROM orders 
WHERE user_id IN (
    SELECT id FROM users 
    WHERE status = 'active' 
    AND id IN (
        SELECT user_id FROM addresses WHERE state = 'CA'
    )
);

-- Good: CTEs (readable and sometimes faster)
WITH active_users AS (
    SELECT id FROM users WHERE status = 'active'
),
ca_users AS (
    SELECT user_id FROM addresses WHERE state = 'CA'
)
SELECT o.* 
FROM orders o
WHERE o.user_id IN (SELECT id FROM active_users)
  AND o.user_id IN (SELECT user_id FROM ca_users);

-- Better: Combined with EXISTS
WITH active_users AS (
    SELECT id FROM users WHERE status = 'active'
),
ca_users AS (
    SELECT user_id FROM addresses WHERE state = 'CA'
)
SELECT o.* 
FROM orders o
WHERE EXISTS (SELECT 1 FROM active_users au WHERE au.id = o.user_id)
  AND EXISTS (SELECT 1 FROM ca_users cu WHERE cu.user_id = o.user_id);
```

#### 6. Use Aggregate Functions Efficiently

```sql
-- Bad: Counting with subquery
SELECT 
    u.*,
    (SELECT COUNT(*) FROM orders WHERE user_id = u.id) AS order_count
FROM users u;

-- Good: Use window functions or joins
SELECT 
    u.*,
    COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id;

-- Bad: Multiple aggregations with subqueries
SELECT 
    u.*,
    (SELECT COUNT(*) FROM orders WHERE user_id = u.id) AS order_count,
    (SELECT SUM(total) FROM orders WHERE user_id = u.id) AS total_spent
FROM users u;

-- Good: Single pass with CTE
WITH user_stats AS (
    SELECT 
        user_id,
        COUNT(*) AS order_count,
        SUM(total) AS total_spent
    FROM orders
    GROUP BY user_id
)
SELECT 
    u.*,
    COALESCE(us.order_count, 0) AS order_count,
    COALESCE(us.total_spent, 0) AS total_spent
FROM users u
LEFT JOIN user_stats us ON u.id = us.user_id;
```

---

### P4.5 Advanced Optimization Techniques

#### 1. Partitioning

For very large tables, partitioning can dramatically improve performance:

```sql
-- Create partitioned table
CREATE TABLE orders_partitioned (
    id SERIAL,
    user_id INTEGER,
    total NUMERIC,
    order_date DATE NOT NULL
) PARTITION BY RANGE (order_date);

-- Create partitions by year
CREATE TABLE orders_2024 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
    
CREATE TABLE orders_2023 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- Queries automatically use correct partition
SELECT * FROM orders_partitioned 
WHERE order_date >= '2024-01-01' AND order_date < '2024-02-01';
-- Only scans orders_2024 partition
```

#### 2. Materialized Views

For expensive, frequently-used queries:

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    DATE(order_date) AS sale_date,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order_value
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY DATE(order_date);

-- Add index for performance
CREATE UNIQUE INDEX idx_daily_sales_summary_date 
ON daily_sales_summary(sale_date);

-- Refresh (weekly or daily)
REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_summary;

-- Query is fast
SELECT * FROM daily_sales_summary 
WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days';
```

#### 3. Query Hints (Optimizer Hints)

PostgreSQL doesn't use hints like MySQL or Oracle, but you can influence the optimizer:

```sql
-- Force sequential scan (rarely needed)
SET enable_seqscan = off;
SELECT * FROM products WHERE price > 100;
SET enable_seqscan = on;

-- Use specific join type
SET enable_nestloop = off;
SELECT * FROM orders o JOIN users u ON o.user_id = u.id;
SET enable_nestloop = on;
```

#### 4. Statistics Management

Keep statistics up to date:

```sql
-- Analyze a specific table
ANALYZE orders;

-- Analyze all tables
ANALYZE;

-- Increase statistics for better plans
ALTER TABLE orders ALTER COLUMN status SET STATISTICS 1000;
ANALYZE orders;

-- Check current stats
SELECT 
    tablename,
    attname,
    n_distinct,
    most_common_vals
FROM pg_stats
WHERE tablename = 'orders';
```

---

### P4.6 Common Performance Anti-Patterns

#### Anti-Pattern 1: N+1 Queries

```sql
-- Bad: N+1 queries
SELECT * FROM users;  -- 100 users
-- For each user:
SELECT * FROM orders WHERE user_id = ?;  -- 100 queries

-- Good: Single query with JOIN
SELECT 
    u.*,
    o.*
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- Better: Aggregated in single query
SELECT 
    u.*,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id;
```

#### Anti-Pattern 2: SELECT *

```sql
-- Bad: Fetching all columns
SELECT * FROM users WHERE id = 123;

-- Good: Only needed columns
SELECT id, email, full_name FROM users WHERE id = 123;

-- Best: Covering index
CREATE INDEX idx_users_covering ON users(id) INCLUDE (email, full_name);
SELECT id, email, full_name FROM users WHERE id = 123;
-- Index-only scan!
```

#### Anti-Pattern 3: Large OFFSET Pagination

```sql
-- Bad: Large offset (scan many rows)
SELECT * FROM products ORDER BY id LIMIT 10 OFFSET 10000;

-- Good: Keyset pagination (seek method)
SELECT * FROM products 
WHERE id > last_seen_id 
ORDER BY id 
LIMIT 10;

-- Good: Using timestamp
SELECT * FROM products 
WHERE created_at > last_seen_timestamp 
ORDER BY created_at 
LIMIT 10;
```

#### Anti-Pattern 4: Too Many Indexes

```sql
-- Bad: Every column indexed
CREATE INDEX idx1 ON table(col1);
CREATE INDEX idx2 ON table(col2);
CREATE INDEX idx3 ON table(col3);
-- Each INSERT/UPDATE has to maintain all indexes

-- Good: Composite indexes
CREATE INDEX idx_composite ON table(col1, col2, col3);

-- Good: Only indexes needed for common queries
CREATE INDEX idx_where ON table(most_used_column);
CREATE INDEX idx_join ON table(foreign_key);
```

#### Anti-Pattern 5: Over-Normalization

```sql
-- Bad: Excessive normalization
-- addresses table with one row per order
-- order_id, address_type, street, city, state, zip

-- Good: Denormalize for performance
ALTER TABLE orders ADD COLUMN shipping_address_json JSONB;
UPDATE orders 
SET shipping_address_json = jsonb_build_object(
    'street', a.street,
    'city', a.city,
    'state', a.state,
    'zip', a.zip
)
FROM addresses a
WHERE orders.shipping_address_id = a.id;
```

---

### P4.7 Monitoring Performance

#### Key Performance Metrics

```sql
-- 1. Database size and growth
SELECT 
    pg_database_size(current_database()) / 1024 / 1024 AS size_mb,
    pg_database_size(current_database()) / 1024 / 1024 / 1024 AS size_gb;

-- 2. Table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 3. Cache hit ratio (should be > 95%)
SELECT 
    'cache hit ratio' AS name,
    round((sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read))) * 100, 2) AS ratio
FROM pg_statio_user_tables;

-- 4. Active connections
SELECT 
    usename,
    application_name,
    client_addr,
    state,
    count(*) AS connection_count
FROM pg_stat_activity
GROUP BY usename, application_name, client_addr, state
ORDER BY connection_count DESC;

-- 5. Query performance (requires pg_stat_statements)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT 
    queryid,
    query,
    calls,
    mean_exec_time,
    total_exec_time,
    rows,
    shared_blks_hit,
    shared_blks_read
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- 6. Long-running queries
SELECT 
    pid,
    usename,
    query,
    state,
    now() - query_start AS duration,
    wait_event_type,
    wait_event
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 seconds'
ORDER BY duration DESC;
```

---

### P4.8 Performance Tuning Checklist

**Before Writing Queries:**
- [ ] Understand the data volume
- [ ] Know the access patterns
- [ ] Define performance requirements

**During Development:**
- [ ] Use EXPLAIN ANALYZE for all new queries
- [ ] Index columns used in WHERE, JOIN, ORDER BY
- [ ] Use appropriate data types (NUMERIC for money)
- [ ] Avoid SELECT *
- [ ] Use LIMIT for large result sets

**Before Production:**
- [ ] Run with production-like data volume
- [ ] Test with concurrent users
- [ ] Review all queries with EXPLAIN
- [ ] Set up monitoring
- [ ] Configure alerts

**In Production:**
- [ ] Monitor query performance regularly
- [ ] VACUUM ANALYZE regularly
- [ ] Review slow query logs
- [ ] Update statistics
- [ ] Remove unused indexes

**When Troubleshooting:**
1. Identify the slow query
2. Run EXPLAIN (ANALYZE, BUFFERS)
3. Check for missing indexes
4. Check for outdated statistics
5. Consider rewriting query
6. Consider architectural changes

---

### Summary

You now understand how to optimize SQL performance:

- **EXPLAIN ANALYZE**: Read and understand execution plans
- **Indexing**: Choose the right index type for each use case
- **Query Optimization**: Write efficient queries
- **Advanced Techniques**: Partitioning, materialized views
- **Anti-Patterns**: What to avoid
- **Monitoring**: Track and measure performance
- **Checklist**: Ensure production readiness

With these optimization skills, your PostgreSQL queries will be fast and efficient—even as your data grows!
