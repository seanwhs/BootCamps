# Part 6: Performance, Indexes, & Transactions

You've built a complete e-commerce database. Now it's time to make it production-ready. In this final part, we'll optimize performance with strategic indexing, understand how PostgreSQL executes queries, and ensure data integrity with transactions. Think of this as turning your prototype into a battle-tested system that can handle real-world traffic and prevent data corruption.

## Phase 6.1: Understanding EXPLAIN ANALYZE

### The Target
Learn to use `EXPLAIN ANALYZE` to understand and diagnose query performance.

### The Concept
`EXPLAIN ANALYZE` shows you exactly how PostgreSQL executes a query—like a GPS showing the route your query takes. It reveals which indexes are used, how many rows are scanned, and where the bottlenecks are. This is your primary tool for performance tuning.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Basic EXPLAIN ANALYZE
-- Simple query without indexes (sequential scan)
EXPLAIN ANALYZE
SELECT * FROM products WHERE name LIKE '%headphone%';

-- 2. EXPLAIN with different formats
-- Text format (default)
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 'some-user-id';

-- JSON format (useful for programmatic analysis)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM orders WHERE user_id = 'some-user-id';

-- 3. Analyze a join query
EXPLAIN ANALYZE
SELECT 
    o.id,
    u.email,
    o.total,
    o.created_at
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE o.status = 'paid'
  AND o.created_at > NOW() - INTERVAL '30 days';

-- 4. Analyze an aggregation query
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
WHERE status != 'cancelled'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- 5. Analyze a complex query with subqueries
EXPLAIN ANALYZE
SELECT 
    u.email,
    (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) AS order_count,
    (SELECT COALESCE(SUM(o.total), 0) FROM orders o WHERE o.user_id = u.id) AS total_spent
FROM users u
WHERE u.is_active = true;

-- 6. Understanding query plans
-- Sequential scan: reads entire table
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'pending';

-- Index scan: uses index for fast lookup
EXPLAIN ANALYZE
SELECT * FROM orders WHERE id = 'some-uuid';

-- Bitmap scan: combines multiple indexes
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE user_id = 'some-uuid' 
  AND status = 'paid';

-- 7. Analyzing expensive operations
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT 
    p.name,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(oi.quantity) AS total_units,
    SUM(oi.total_price) AS revenue
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
GROUP BY p.id, p.name
ORDER BY revenue DESC NULLS LAST
LIMIT 20;

-- 8. Use EXPLAIN to identify missing indexes
-- If you see a Seq Scan on a large table, consider adding an index
EXPLAIN ANALYZE
SELECT * FROM orders WHERE user_id = 'some-uuid' AND status = 'paid';
```

### The Verification

```bash
# Run an EXPLAIN ANALYZE and look for key metrics
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM products WHERE price < 50;"

# Look for:
# - Execution time (aim for < 100ms)
# - Planning time
# - Number of rows (actual vs estimated)
# - Scan type (Seq Scan vs Index Scan)
# - Buffer usage (hits vs reads)

# Compare two queries
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'paid';"
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM orders WHERE id = 'some-uuid';"
```

---

## Phase 6.2: Index Fundamentals

### The Target
Understand different index types and when to use them.

### The Concept
Indexes are like book indexes—they help PostgreSQL find data quickly without scanning the entire book (table). But indexes cost storage and slow down writes. We need to choose the right index for the right query pattern. Think of it as investing in speed: you trade storage and write performance for read performance.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Create B-Tree Indexes (default, best for equality and range)
-- Basic index on a single column
CREATE INDEX idx_orders_status ON orders(status);

-- Index on a timestamp (good for date ranges)
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- 2. Composite Index (multiple columns in order)
-- Order matters: put the most selective column first
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_orders_status_created ON orders(status, created_at);

-- 3. Partial Index (index only subset of rows)
-- Great for filtering on status
CREATE INDEX idx_orders_active ON orders(user_id) 
WHERE status IN ('paid', 'shipped', 'delivered');

-- Index only pending orders (common query)
CREATE INDEX idx_orders_pending ON orders(user_id) 
WHERE status = 'pending';

-- 4. Unique Index (enforces uniqueness and speeds lookups)
CREATE UNIQUE INDEX idx_products_slug_unique ON products(slug);

-- 5. Expression Index (index on computed value)
-- Index on lowercase email for case-insensitive search
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- Index on date part
CREATE INDEX idx_orders_created_date ON orders(DATE(created_at));

-- 6. Partial Unique Index (unique constraint with condition)
-- Ensure only one active user per email (soft delete handling)
CREATE UNIQUE INDEX idx_users_active_email 
ON users(email) 
WHERE is_active = true;

-- 7. Index for JSONB
-- GIN index for JSONB containment queries
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- Expression index on JSONB field
CREATE INDEX idx_products_metadata_brand ON products ((metadata->>'brand'));

-- 8. Index for LIKE/ILIKE queries
-- Use varchar_pattern_ops for LIKE 'text%' queries
CREATE INDEX idx_products_name_pattern ON products(name varchar_pattern_ops);

-- 9. Show existing indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 10. Drop unused indexes (example)
-- DROP INDEX idx_orders_status;
```

### The Verification

```bash
# View all indexes
psql -d ecommerce -c "\di"

# Check index usage
psql -d ecommerce -c "
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS index_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;"

# Test index effectiveness
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'pending';"
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 'some-uuid';"

# Compare with and without index (if possible)
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM products WHERE metadata->>'brand' = 'AudioTech';"
```

---

## Phase 6.3: Identifying and Optimizing Slow Queries

### The Target
Find and fix slow queries using EXPLAIN ANALYZE and indexes.

### The Concept
Slow queries kill application performance. We'll use systematic approach to identify bottlenecks and fix them. Think of it as medical diagnosis for your database—find the symptoms (slow queries), diagnose the cause (full table scans, missing indexes), and prescribe treatment (optimized queries, new indexes).

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Identify problematic queries
-- Query without index (sequential scan)
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE status = 'pending' 
  AND created_at > NOW() - INTERVAL '7 days';

-- Add an index to fix it
CREATE INDEX idx_orders_status_created ON orders(status, created_at);

-- Query again - should be faster
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE status = 'pending' 
  AND created_at > NOW() - INTERVAL '7 days';

-- 2. Optimize a slow join
-- Slow query: no indexes on foreign keys
EXPLAIN ANALYZE
SELECT 
    o.id,
    u.email,
    oi.product_name,
    oi.quantity
FROM orders o
JOIN users u ON u.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status = 'paid'
  AND o.created_at > NOW() - INTERVAL '30 days';

-- Add missing indexes
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Query should now use index scans

-- 3. Optimize aggregation queries
-- Slow aggregation without index
EXPLAIN ANALYZE
SELECT 
    user_id,
    COUNT(*) AS order_count,
    SUM(total) AS total_spent
FROM orders
WHERE status != 'cancelled'
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;

-- Add index on user_id with status
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Query should now use index

-- 4. Optimize text search
-- Slow LIKE/ILIKE query
EXPLAIN ANALYZE
SELECT * FROM products WHERE name ILIKE '%wireless%';

-- Use trigram index for ILIKE
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);

-- Query should now use index

-- 5. Optimize JSONB queries
EXPLAIN ANALYZE
SELECT * FROM products WHERE metadata @> '{"brand": "AudioTech"}'::jsonb;

-- GIN index for JSONB
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- 6. Optimize date range queries
EXPLAIN ANALYZE
SELECT * FROM orders WHERE DATE(created_at) = CURRENT_DATE;

-- Better approach with range
CREATE INDEX idx_orders_created_at ON orders(created_at);
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE created_at >= CURRENT_DATE 
  AND created_at < CURRENT_DATE + INTERVAL '1 day';

-- 7. Use covering indexes (include additional columns)
-- Index-only scan: all needed data in index
CREATE INDEX idx_orders_user_amount ON orders(user_id) 
INCLUDE (total, status, created_at);

-- Query can use index-only scan
EXPLAIN ANALYZE
SELECT user_id, total, status, created_at
FROM orders
WHERE user_id = 'some-uuid';

-- 8. Monitor query performance over time
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

### The Verification

```bash
# Enable pg_stat_statements if not already enabled
psql -d ecommerce -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"

# View slow queries
psql -d ecommerce -c "
SELECT 
    query,
    calls,
    total_time / calls AS avg_time_ms,
    rows / calls AS avg_rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;"

# Test optimized queries
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 'some-uuid';"
psql -d ecommerce -c "EXPLAIN ANALYZE SELECT * FROM products WHERE name ILIKE '%wireless%';"
```

---

## Phase 6.4: Transactions and ACID

### The Target
Master transactions for atomic operations and data integrity.

### The Concept
Transactions are like atomic operations—they either complete fully or not at all. Think of them as wrapping multiple operations in a protective bubble. If anything goes wrong, everything rolls back, ensuring data consistency. ACID (Atomicity, Consistency, Isolation, Durability) is the guarantee that transactions provide.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Basic Transaction
-- Start a transaction
BEGIN;

-- Check current stock
SELECT id, name, stock_quantity 
FROM products 
WHERE id = 1;

-- Attempt to update stock
UPDATE products 
SET stock_quantity = stock_quantity - 1 
WHERE id = 1 AND stock_quantity > 0;

-- Check if it worked
SELECT id, name, stock_quantity 
FROM products 
WHERE id = 1;

-- Rollback if something went wrong
ROLLBACK;

-- Or commit if successful
-- COMMIT;

-- 2. Transaction with savepoints
BEGIN;

-- First operation
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE id = 1;
SAVEPOINT first_update;

-- Second operation (might fail)
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE id = 2;
SAVEPOINT second_update;

-- If second update fails, rollback to savepoint
ROLLBACK TO SAVEPOINT first_update;

-- Continue with other operations
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE id = 3;

-- Commit all successful operations
COMMIT;

-- 3. Complete checkout transaction
CREATE OR REPLACE FUNCTION process_order(
    p_user_id UUID,
    p_shipping_address JSONB,
    p_payment_method VARCHAR,
    p_items JSONB  -- Array of {product_id, quantity}
)
RETURNS TABLE(order_id UUID, status VARCHAR, total NUMERIC) AS $$
DECLARE
    v_order_id UUID;
    v_subtotal NUMERIC := 0;
    v_tax NUMERIC;
    v_total NUMERIC;
    v_item JSONB;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_price NUMERIC;
    v_current_stock INTEGER;
BEGIN
    -- Start transaction
    BEGIN
        -- Create the order header
        INSERT INTO orders (
            user_id,
            status,
            shipping_address_line1,
            shipping_city,
            shipping_state,
            shipping_postal_code,
            shipping_country,
            payment_method,
            payment_status,
            created_at
        ) VALUES (
            p_user_id,
            'pending',
            p_shipping_address->>'line1',
            p_shipping_address->>'city',
            p_shipping_address->>'state',
            p_shipping_address->>'postal_code',
            p_shipping_address->>'country',
            p_payment_method,
            'pending',
            NOW()
        ) RETURNING id INTO v_order_id;

        -- Process each item
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;

            -- Lock the product row for update (prevent race conditions)
            SELECT price, stock_quantity 
            INTO v_price, v_current_stock
            FROM products 
            WHERE id = v_product_id
            FOR UPDATE;

            -- Check stock
            IF v_current_stock < v_quantity THEN
                RAISE EXCEPTION 'Insufficient stock for product %', v_product_id;
            END IF;

            -- Reduce stock
            UPDATE products 
            SET stock_quantity = stock_quantity - v_quantity,
                updated_at = NOW()
            WHERE id = v_product_id;

            -- Add order item
            INSERT INTO order_items (
                order_id,
                product_id,
                product_name,
                unit_price,
                quantity,
                total_price,
                product_options
            ) VALUES (
                v_order_id,
                v_product_id,
                (SELECT name FROM products WHERE id = v_product_id),
                v_price,
                v_quantity,
                v_price * v_quantity,
                v_item->'options'
            );

            -- Calculate subtotal
            v_subtotal := v_subtotal + (v_price * v_quantity);
        END LOOP;

        -- Calculate totals
        v_tax := v_subtotal * 0.08;
        v_total := v_subtotal + v_tax;

        -- Update order totals
        UPDATE orders 
        SET 
            subtotal = v_subtotal,
            tax = v_tax,
            total = v_total,
            status = 'paid',
            payment_status = 'completed',
            updated_at = NOW()
        WHERE id = v_order_id
        RETURNING id, status, total INTO order_id, status, total;

        -- Commit transaction
        COMMIT;

        -- Return success
        RETURN NEXT;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback on any error
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

-- 4. Use the transaction function
DO $$
DECLARE
    v_user_id UUID;
    v_order_record RECORD;
BEGIN
    -- Get a user
    SELECT id INTO v_user_id FROM users LIMIT 1;
    
    -- Process an order
    SELECT * INTO v_order_record FROM process_order(
        v_user_id,
        '{"line1": "123 Main St", "city": "New York", "state": "NY", "postal_code": "10001", "country": "US"}'::jsonb,
        'credit_card',
        '[
            {"product_id": 1, "quantity": 2},
            {"product_id": 2, "quantity": 1, "options": {"color": "black"}}
        ]'::jsonb
    );
    
    RAISE NOTICE 'Order created: % with total %', v_order_record.order_id, v_order_record.total;
END $$;

-- 5. Test transaction with rollback
-- This should fail and rollback (insufficient stock)
DO $$
DECLARE
    v_user_id UUID;
BEGIN
    SELECT id INTO v_user_id FROM users LIMIT 1;
    
    -- This will fail because product 1 might not have enough stock
    PERFORM process_order(
        v_user_id,
        '{"line1": "123 Main St", "city": "New York", "state": "NY", "postal_code": "10001", "country": "US"}'::jsonb,
        'credit_card',
        '[
            {"product_id": 1, "quantity": 99999}
        ]'::jsonb
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Transaction failed as expected: %', SQLERRM;
END $$;

-- 6. Check transaction isolation levels
-- Read Committed (default)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Repeatable Read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Serializable (strictest)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Demonstrate with a transaction
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM orders WHERE id = 'some-uuid';
-- Do some operations
COMMIT;
```

### The Verification

```bash
# Test the checkout function
psql -d ecommerce -c "
SELECT * FROM process_order(
    (SELECT id FROM users LIMIT 1),
    '{\"line1\": \"123 Main St\", \"city\": \"New York\", \"state\": \"NY\", \"postal_code\": \"10001\", \"country\": \"US\"}'::jsonb,
    'credit_card',
    '[{\"product_id\": 1, \"quantity\": 1}]'::jsonb
);"

# Check that stock was reduced
psql -d ecommerce -c "SELECT id, name, stock_quantity FROM products WHERE id = 1;"

# Check order was created
psql -d ecommerce -c "SELECT id, user_id, total, status FROM orders ORDER BY created_at DESC LIMIT 1;"

# Test a transaction that should fail
psql -d ecommerce -c "
BEGIN;
UPDATE products SET stock_quantity = stock_quantity - 1000 WHERE id = 1;
ROLLBACK;
-- Stock should be unchanged
SELECT stock_quantity FROM products WHERE id = 1;"
```

---

## Phase 6.5: Advanced Transaction Patterns

### The Target
Implement advanced transaction patterns for real-world scenarios.

### The Concept
Beyond basic transactions, we need patterns for common scenarios: optimistic locking, pessimistic locking, and handling deadlocks. These patterns ensure data consistency even under high concurrency.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Optimistic Locking (using version numbers)
-- Add version column to products
ALTER TABLE products ADD COLUMN IF NOT EXISTS version INTEGER DEFAULT 1;

-- Update with optimistic locking
CREATE OR REPLACE FUNCTION update_product_with_optimistic_lock(
    p_product_id INTEGER,
    p_new_price NUMERIC,
    p_expected_version INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_version INTEGER;
BEGIN
    -- Get current version
    SELECT version INTO v_current_version
    FROM products
    WHERE id = p_product_id;
    
    -- Check if version matches
    IF v_current_version != p_expected_version THEN
        RETURN FALSE;
    END IF;
    
    -- Perform update with version increment
    UPDATE products 
    SET price = p_new_price,
        version = version + 1,
        updated_at = NOW()
    WHERE id = p_product_id 
      AND version = p_expected_version;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Test optimistic locking
DO $$
DECLARE
    v_success BOOLEAN;
BEGIN
    -- First update should succeed
    v_success := update_product_with_optimistic_lock(1, 99.99, 1);
    RAISE NOTICE 'First update: %', v_success;
    
    -- Second update with same version should fail
    v_success := update_product_with_optimistic_lock(1, 89.99, 1);
    RAISE NOTICE 'Second update (stale version): %', v_success;
END $$;

-- 2. Pessimistic Locking with SELECT FOR UPDATE
CREATE OR REPLACE FUNCTION reserve_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_stock INTEGER;
BEGIN
    -- Lock the row
    SELECT stock_quantity INTO v_current_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE NOWAIT;  -- Don't wait if locked
    
    -- Check stock
    IF v_current_stock < p_quantity THEN
        RETURN FALSE;
    END IF;
    
    -- Reserve stock
    UPDATE products 
    SET stock_quantity = stock_quantity - p_quantity,
        updated_at = NOW()
    WHERE id = p_product_id;
    
    RETURN TRUE;
EXCEPTION
    WHEN lock_not_available THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 3. Handling Deadlocks
-- Example of a deadlock situation (run in two sessions)
-- Session 1:
BEGIN;
UPDATE products SET price = price * 1.1 WHERE id = 1;
UPDATE products SET price = price * 1.1 WHERE id = 2;
COMMIT;

-- Session 2 (different order):
BEGIN;
UPDATE products SET price = price * 0.9 WHERE id = 2;
UPDATE products SET price = price * 0.9 WHERE id = 1;
COMMIT;

-- Deadlock detection in PostgreSQL (automatic)
-- One session will be chosen as victim and rolled back

-- 4. Distributed Transaction Pattern
-- Two-phase commit with savepoints
CREATE OR REPLACE FUNCTION transfer_inventory(
    p_source_product_id INTEGER,
    p_target_product_id INTEGER,
    p_quantity INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_source_stock INTEGER;
    v_target_stock INTEGER;
BEGIN
    -- Start transaction
    BEGIN
        -- Lock both products in consistent order
        LOCK TABLE products IN ROW EXCLUSIVE MODE;
        
        -- Check source
        SELECT stock_quantity INTO v_source_stock
        FROM products
        WHERE id = p_source_product_id;
        
        IF v_source_stock < p_quantity THEN
            RETURN FALSE;
        END IF;
        
        -- Reduce source
        UPDATE products 
        SET stock_quantity = stock_quantity - p_quantity,
            updated_at = NOW()
        WHERE id = p_source_product_id;
        
        -- Increase target
        UPDATE products 
        SET stock_quantity = stock_quantity + p_quantity,
            updated_at = NOW()
        WHERE id = p_target_product_id;
        
        COMMIT;
        RETURN TRUE;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN FALSE;
    END;
END;
$$ LANGUAGE plpgsql;

-- 5. Bulk transaction with logging
CREATE TABLE IF NOT EXISTS transaction_log (
    id SERIAL PRIMARY KEY,
    operation VARCHAR(100),
    table_name VARCHAR(100),
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    performed_by VARCHAR(255),
    performed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION log_transaction()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO transaction_log (
        operation,
        table_name,
        record_id,
        old_data,
        new_data,
        performed_by
    ) VALUES (
        TG_OP,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        row_to_json(OLD),
        row_to_json(NEW),
        CURRENT_USER
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to log order changes
CREATE TRIGGER log_orders_transaction
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION log_transaction();

-- 6. Repeatable Read for reporting
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- This query won't see changes made during the transaction
SELECT 
    COUNT(*) AS total_orders,
    SUM(total) AS total_revenue
FROM orders
WHERE status != 'cancelled'
  AND created_at > NOW() - INTERVAL '30 days';

-- Even if other transactions update data, we see a consistent snapshot

COMMIT;
```

### The Verification

```bash
# Test optimistic locking
psql -d ecommerce -c "SELECT id, price, version FROM products WHERE id = 1;"
psql -d ecommerce -c "SELECT update_product_with_optimistic_lock(1, 100.00, 1);"
psql -d ecommerce -c "SELECT id, price, version FROM products WHERE id = 1;"

# Test inventory transfer
psql -d ecommerce -c "SELECT transfer_inventory(2, 1, 5);"
psql -d ecommerce -c "SELECT id, name, stock_quantity FROM products WHERE id IN (1, 2);"

# Check transaction log
psql -d ecommerce -c "SELECT * FROM transaction_log ORDER BY performed_at DESC LIMIT 5;"
```

---

## Phase 6.6: Monitoring and Maintenance

### The Target
Set up monitoring and maintenance for production readiness.

### The Concept
Production databases need ongoing care: vacuuming, analyzing statistics, and monitoring performance. Think of this as regular maintenance for your car—small tasks that prevent big problems.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Database Statistics
-- Show table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 2. Index Usage Statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS index_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched,
    CASE 
        WHEN idx_scan = 0 THEN 'Never Used'
        WHEN idx_scan < 100 THEN 'Rarely Used'
        ELSE 'Used'
    END AS usage_status
FROM pg_stat_user_indexes
ORDER BY idx_scan;

-- 3. Vacuum and Analyze
-- VACUUM: reclaims storage, updates statistics
VACUUM ANALYZE users;
VACUUM ANALYZE products;
VACUUM ANALYZE orders;
VACUUM ANALYZE order_items;

-- VACUUM FULL: reclaims storage and compacts (locks tables)
-- Use with caution!
-- VACUUM FULL;

-- 4. Monitor active connections
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query,
    state_change,
    backend_start
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY state_change DESC;

-- 5. Kill stuck queries
-- SELECT pg_cancel_backend(pid);
-- SELECT pg_terminate_backend(pid);

-- 6. Long-running queries
SELECT 
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > INTERVAL '5 minutes'
  AND state = 'active';

-- 7. Database maintenance function
CREATE OR REPLACE FUNCTION run_maintenance()
RETURNS TEXT AS $$
DECLARE
    v_tables TEXT[];
    v_table TEXT;
    v_result TEXT := '';
BEGIN
    -- Get all user tables
    SELECT array_agg(tablename)
    INTO v_tables
    FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename NOT LIKE 'pg_%';
    
    -- Vacuum and analyze each table
    FOREACH v_table IN ARRAY v_tables
    LOOP
        EXECUTE format('VACUUM ANALYZE %I', v_table);
        v_result := v_result || format('Analyzed %s table\n', v_table);
    END LOOP;
    
    -- Refresh statistics
    ANALYZE;
    
    -- Generate index usage report
    WITH index_stats AS (
        SELECT 
            indexname,
            idx_scan
        FROM pg_stat_user_indexes
        ORDER BY idx_scan
        LIMIT 5
    )
    SELECT 'Index usage statistics updated' INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Run maintenance
SELECT run_maintenance();

-- 8. Create maintenance schedule
-- Use pg_cron or external scheduling (cron, systemd timers)
-- Example: Run daily at 2 AM
-- 0 2 * * * psql -d ecommerce -c "SELECT run_maintenance();"
```

### The Verification

```bash
# Check table sizes
psql -d ecommerce -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"

# Check index usage
psql -d ecommerce -c "
SELECT 
    indexname,
    idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC
LIMIT 10;"

# Run maintenance
psql -d ecommerce -c "SELECT run_maintenance();"

# Check active connections
psql -d ecommerce -c "
SELECT COUNT(*) AS active_connections 
FROM pg_stat_activity 
WHERE state = 'active';"
```

---

## Phase 6.7: Production Readiness Checklist

### The Target
Create a production readiness script that validates everything.

### The Concept
Before going to production, run through a checklist to ensure your database is optimized and secure. This is like a pre-flight check before takeoff—catching issues before they cause problems.

### The Implementation

Create a file called `06_production_ready.sql`:

```sql
-- 06_production_ready.sql
-- Production Readiness Checklist

\c ecommerce

-- ============================================================
-- CHECK 1: Database Size and Growth
-- ============================================================
SELECT '=== DATABASE SIZE CHECK ===' AS check_name;

SELECT 
    pg_database_size(current_database()) AS total_bytes,
    pg_size_pretty(pg_database_size(current_database())) AS total_size,
    pg_database_size(current_database()) - 
    (SELECT SUM(pg_total_relation_size(schemaname||'.'||tablename)) 
     FROM pg_tables WHERE schemaname = 'public') AS overhead_size;

-- ============================================================
-- CHECK 2: Table Sizes
-- ============================================================
SELECT '=== TABLE SIZES ===' AS check_name;

SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS indexes,
    (SELECT COUNT(*) FROM (SELECT 1 FROM information_schema.columns WHERE table_name = tablename) t) AS columns
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ============================================================
-- CHECK 3: Missing Indexes
-- ============================================================
SELECT '=== MISSING INDEXES CHECK ===' AS check_name;

-- Check for sequential scans on large tables that might need indexes
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    CASE 
        WHEN seq_scan = 0 THEN 'No sequential scans'
        WHEN idx_scan = 0 THEN 'No index scans - consider indexing'
        WHEN seq_scan > idx_scan * 2 THEN 'Sequential scans dominate - check indexing'
        ELSE 'OK'
    END AS index_status
FROM pg_stat_user_tables
WHERE seq_scan > 100
ORDER BY seq_scan DESC;

-- ============================================================
-- CHECK 4: Unused Indexes
-- ============================================================
SELECT '=== UNUSED INDEXES ===' AS check_name;

SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexname NOT LIKE 'pg_%'
ORDER BY tablename;

-- ============================================================
-- CHECK 5: Foreign Key Indexes
-- ============================================================
SELECT '=== FOREIGN KEY INDEXES ===' AS check_name;

SELECT 
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    a.attname AS column_name,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_index i
            WHERE i.indrelid = conrelid
              AND i.indisprimary = false
              AND a.attnum = ANY(i.indkey)
        ) THEN 'Indexed'
        ELSE 'Missing Index'
    END AS index_status
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE contype = 'f'
  AND conrelid IN (SELECT oid FROM pg_class WHERE relnamespace = 'public'::regnamespace);

-- ============================================================
-- CHECK 6: Transaction Isolation and Locks
-- ============================================================
SELECT '=== LOCKS AND TRANSACTIONS ===' AS check_name;

SELECT 
    locktype,
    relation::regclass AS table_name,
    mode,
    granted,
    pid
FROM pg_locks
WHERE NOT granted
  AND relation IS NOT NULL;

-- ============================================================
-- CHECK 7: Configuration Settings
-- ============================================================
SELECT '=== CONFIGURATION SETTINGS ===' AS check_name;

SELECT 
    name,
    setting,
    unit,
    context,
    pending_restart
FROM pg_settings
WHERE name IN (
    'shared_buffers',
    'work_mem',
    'maintenance_work_mem',
    'effective_cache_size',
    'max_connections',
    'wal_buffers',
    'max_wal_size',
    'random_page_cost',
    'checkpoint_timeout'
)
ORDER BY name;

-- ============================================================
-- CHECK 8: Connections
-- ============================================================
SELECT '=== CONNECTION STATISTICS ===' AS check_name;

SELECT 
    COUNT(*) AS total_connections,
    COUNT(*) FILTER (WHERE state = 'active') AS active_connections,
    COUNT(*) FILTER (WHERE state = 'idle') AS idle_connections,
    COUNT(*) FILTER (WHERE state = 'idle in transaction') AS idle_in_transaction,
    MAX(now() - query_start) AS longest_running_query
FROM pg_stat_activity
WHERE datname = current_database();

-- ============================================================
-- CHECK 9: Vacuum Status
-- ============================================================
SELECT '=== VACUUM STATUS ===' AS check_name;

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

-- ============================================================
-- CHECK 10: Query Performance Summary
-- ============================================================
SELECT '=== QUERY PERFORMANCE SUMMARY ===' AS check_name;

-- Top 5 slowest queries
SELECT 
    query,
    calls,
    total_time,
    ROUND(total_time / NULLIF(calls, 0)::NUMERIC, 2) AS avg_time_ms,
    rows
FROM pg_stat_statements
WHERE calls > 0
ORDER BY total_time DESC
LIMIT 5;

-- ============================================================
-- FINAL VERDICT
-- ============================================================
SELECT '=== PRODUCTION READINESS VERDICT ===' AS check_name;

WITH issues AS (
    SELECT 
        COUNT(*) FILTER (WHERE idx_scan = 0 AND indexname NOT LIKE 'pg_%') AS unused_indexes,
        COUNT(*) FILTER (WHERE index_status = 'Missing Index') AS missing_foreign_key_indexes,
        COUNT(*) FILTER (WHERE dead_tuple_pct > 10) AS high_dead_tuples
    FROM (
        -- Unused indexes
        SELECT idx_scan, NULL AS index_status, NULL AS dead_tuple_pct
        FROM pg_stat_user_indexes
        WHERE schemaname = 'public'
        UNION ALL
        -- Missing foreign key indexes
        SELECT NULL, index_status, NULL
        FROM (
            SELECT 
                CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM pg_index i
                        WHERE i.indrelid = conrelid
                          AND i.indisprimary = false
                          AND a.attnum = ANY(i.indkey)
                    ) THEN 'Indexed'
                    ELSE 'Missing Index'
                END AS index_status
            FROM pg_constraint c
            JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
            WHERE contype = 'f'
              AND conrelid IN (SELECT oid FROM pg_class WHERE relnamespace = 'public'::regnamespace)
        ) fk
        UNION ALL
        -- Dead tuples
        SELECT NULL, NULL, ROUND(100 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0)::NUMERIC, 2)
        FROM pg_stat_user_tables
        WHERE n_dead_tup > 0
    ) t
)
SELECT 
    CASE 
        WHEN COALESCE(unused_indexes, 0) > 0 OR 
             COALESCE(missing_foreign_key_indexes, 0) > 0 OR 
             COALESCE(high_dead_tuples, 0) > 0 THEN 'REVIEW NEEDED'
        ELSE 'READY FOR PRODUCTION'
    END AS status,
    COALESCE(unused_indexes, 0) AS unused_indexes,
    COALESCE(missing_foreign_key_indexes, 0) AS missing_fk_indexes,
    COALESCE(high_dead_tuples, 0) AS tables_with_high_dead_tuples
FROM issues;

-- ============================================================
-- RECOMMENDATIONS
-- ============================================================
SELECT '=== RECOMMENDATIONS ===' AS check_name;

SELECT 
    '1. Run VACUUM ANALYZE regularly' AS recommendation
UNION ALL
SELECT 
    '2. Add missing foreign key indexes'
WHERE EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE contype = 'f' 
      AND conrelid IN (SELECT oid FROM pg_class WHERE relnamespace = 'public'::regnamespace)
)
UNION ALL
SELECT 
    '3. Drop unused indexes to improve write performance'
WHERE EXISTS (
    SELECT 1 FROM pg_stat_user_indexes 
    WHERE idx_scan = 0 AND indexname NOT LIKE 'pg_%'
)
UNION ALL
SELECT 
    '4. Consider partitioning large tables if needed'
UNION ALL
SELECT 
    '5. Set up monitoring and alerting for database health'
UNION ALL
SELECT 
    '6. Implement regular backup strategy'
UNION ALL
SELECT 
    '7. Use connection pooling for production applications';

SELECT '=== PRODUCTION READINESS CHECK COMPLETE ===' AS check_name;
```

Run the production readiness check:

```bash
# Run the complete checklist
psql -d ecommerce -U ecommerce_user -f 06_production_ready.sql

# Save to a file for review
psql -d ecommerce -U ecommerce_user -f 06_production_ready.sql > production_check_$(date +%Y%m%d).txt

# View critical issues
psql -d ecommerce -U ecommerce_user -f 06_production_ready.sql | grep -A 5 "Verdict"
```

### The Verification

```bash
# Check final verdict
psql -d ecommerce -c "
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_stat_user_indexes WHERE idx_scan = 0
        ) THEN 'Has unused indexes'
        ELSE 'No unused indexes'
    END AS index_status;"

# Check vacuum requirements
psql -d ecommerce -c "
SELECT 
    tablename,
    n_dead_tup,
    n_live_tup,
    ROUND(100 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0)::NUMERIC, 2) AS dead_pct
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY dead_pct DESC;"
```

---

## Summary: What You've Accomplished

You've completed the entire series and built a production-ready e-commerce database system:

✅ Used EXPLAIN ANALYZE to diagnose query performance  
✅ Created strategic indexes (B-Tree, GIN, Partial, Composite)  
✅ Identified and optimized slow queries  
✅ Implemented ACID-compliant transactions  
✅ Built atomic checkout with inventory management  
✅ Implemented optimistic and pessimistic locking  
✅ Handled deadlocks and concurrency  
✅ Created comprehensive monitoring and maintenance scripts  
✅ Built a production readiness checklist  

---

## Series Conclusion: You're Now a Schema Hero!

### What You've Built

Over six parts, you've built a complete, production-ready e-commerce database:

**Part 1**: Products table with CRUD operations  
**Part 2**: Users table with bulletproof constraints and JSONB preferences  
**Part 3**: Orders, order items, categories with foreign keys and JOINs  
**Part 4**: Sales reports, aggregations, and subqueries  
**Part 5**: JSONB for flexible data and window functions for analytics  
**Part 6**: Performance optimization, indexes, and transactions  

### Skills You've Mastered

✅ PostgreSQL installation and setup  
✅ Table design with appropriate data types  
✅ CRUD operations (INSERT, SELECT, UPDATE, DELETE)  
✅ Constraints (NOT NULL, UNIQUE, CHECK, FOREIGN KEY)  
✅ All JOIN types (INNER, LEFT, RIGHT, FULL)  
✅ Aggregations and GROUP BY  
✅ Subqueries and CTEs  
✅ CASE WHEN for conditional logic  
✅ JSONB for semi-structured data  
✅ Window functions for advanced analytics  
✅ EXPLAIN ANALYZE for performance tuning  
✅ Strategic indexing  
✅ Transactions and concurrency control  
✅ Production monitoring and maintenance  

### Your Production-Ready Database Schema

```sql
-- Final schema summary
-- You now have:

-- users: Customer accounts with UUID, validation, JSONB preferences
-- products: Product catalog with JSONB metadata and variants
-- categories: Hierarchical product categories
-- product_categories: Many-to-many junction table
-- orders: Purchase orders with status, totals, shipping
-- order_items: Line items with price snapshots
-- active_users: View for active customers
-- customer_ranking: View with composite scoring
-- process_order: Transaction function for atomic checkout
-- transaction_log: Audit trail for changes
```

### Next Steps

Your database is ready. Here's what to do next:

1. **Backup your database**: `pg_dump -d ecommerce > ecommerce_backup.sql`
2. **Document your schema**: Use the scripts we created
3. **Set up monitoring**: pgAdmin, Datadog, or Prometheus
4. **Build an API layer**: Use Node.js, Python, or Ruby to connect
5. **Create a frontend**: Build your e-commerce store
6. **Scale**: Consider read replicas for reporting queries
7. **Continue learning**: Explore PostGIS, full-text search, partitioning

### Resources for Continued Learning

- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Performance Tuning](https://www.postgresql.org/docs/current/performance-tips.html)
- [Use The Index, Luke](https://use-the-index-luke.com/)
- [PGAdmin Documentation](https://www.pgadmin.org/docs/)
- [PostgreSQL Weekly Newsletter](https://postgresweekly.com/)

---

**Congratulations, Schema Hero!** You've gone from zero to PostgreSQL expert. Your e-commerce database is production-ready, optimized, and secure. Go build something amazing!
