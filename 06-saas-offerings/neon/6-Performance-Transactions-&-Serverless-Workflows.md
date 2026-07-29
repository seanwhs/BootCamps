# Serverless Postgres with Neon: From Zero to Production

## Part 6: Performance, Transactions, & Serverless Workflows

### The Target

In this final part, we'll:
1. Analyze query performance with `EXPLAIN ANALYZE`
2. Create advanced indexing strategies (B-Tree, GIN, Partial, Covering)
3. Implement ACID transactions for bulletproof checkout flows
4. Build an inventory reservation system with row-level locking
5. Set up CI/CD with Neon branches and GitHub Actions
6. Create preview deployments using Neon branching
7. Implement production monitoring and alerting
8. Deploy your complete application with best practices

By the end of this part, you'll have a production-ready e-commerce backend with automated testing, deployment pipelines, and bulletproof data integrity.

---

### The Concept: Making Your Database Bulletproof

Imagine you're running a warehouse with millions of products. You need:
- **Speed**: Find any product instantly (indexing)
- **Accuracy**: Never sell the same item twice (transactions & locking)
- **Reliability**: If something goes wrong, undo everything (ACID)
- **Automation**: Deploy changes without breaking things (CI/CD)
- **Monitoring**: Know if something's wrong before customers notice (observability)

This part brings everything together—you'll build a system that can handle thousands of concurrent customers while maintaining absolute data integrity.

---

### Implementation Step 1: Query Performance Analysis

#### 1.1 Understanding EXPLAIN ANALYZE

`EXPLAIN ANALYZE` shows you how PostgreSQL executes your query:

```sql
-- Basic EXPLAIN (shows plan, doesn't execute)
EXPLAIN 
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;

-- EXPLAIN ANALYZE (executes query and shows actual performance)
EXPLAIN ANALYZE
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```

#### 1.2 Analyzing Execution Plans

```sql
-- Complex query with JOINs and aggregations
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT 
    p.name AS product_name,
    p.price,
    p.metadata->>'category' AS category,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.line_total) AS total_revenue,
    AVG(oi.unit_price) AS avg_selling_price,
    RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS revenue_rank
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
  AND p.deleted_at IS NULL
  AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY p.id, p.name, p.price, p.metadata
ORDER BY total_revenue DESC
LIMIT 20;

-- Analyze the output:
-- Look for: Seq Scan (bad for large tables), Index Scan (good)
-- Look for: Nested Loop (bad for large datasets), Hash Join, Merge Join (good)
-- Check: Actual time, Rows Removed by Filter, Buffers
```

#### 1.3 Common Performance Issues

```sql
-- Problem: Sequential scan on large table
-- Solution: Add appropriate index
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE status = 'pending' 
  AND order_date > CURRENT_DATE - INTERVAL '7 days';

-- Create index to fix
CREATE INDEX idx_orders_status_date ON orders(status, order_date DESC);

-- Verify improvement
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE status = 'pending' 
  AND order_date > CURRENT_DATE - INTERVAL '7 days';

-- Problem: Slow JOIN without index on foreign key
EXPLAIN ANALYZE
SELECT * FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE u.email ILIKE '%@company.com';

-- Solution: Create index on user_id (if not exists)
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Problem: Slow LIKE queries
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE name LIKE '%wireless%';

-- Solution: Use trigram index
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
```

---

### Implementation Step 2: Advanced Indexing Strategies

#### 2.1 B-Tree Indexes (Default)

```sql
-- Standard B-Tree index for equality and range queries
CREATE INDEX idx_orders_order_date ON orders(order_date DESC);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_users_email ON users(email);

-- Composite B-Tree index for multi-column queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_products_category_price ON products((metadata->>'category'), price);

-- Partial index (only for specific conditions)
CREATE INDEX idx_orders_pending ON orders(order_date) 
WHERE status = 'pending' AND deleted_at IS NULL;

-- Index with included columns (Covering index)
CREATE INDEX idx_orders_covering ON orders(user_id, order_date) 
INCLUDE (total, status, order_number);

-- Verify index usage
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
```

#### 2.2 GIN Indexes for JSONB and Full-Text

```sql
-- GIN index for JSONB queries
CREATE INDEX idx_products_attributes_gin ON products USING gin(attributes);
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- GIN index for full-text search
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);

-- GIN index for array operations
CREATE INDEX idx_products_tags_gin ON products USING gin((metadata->'tags'));

-- GIN index for trigram search
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_description_trgm ON products USING gin(description gin_trgm_ops);

-- GIN index for multiple JSON fields
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE INDEX idx_products_multi ON products 
USING gin(price, attributes, (metadata->'tags'));
```

#### 2.3 BRIN Indexes for Large Tables

BRIN (Block Range Index) is efficient for very large tables with natural ordering:

```sql
-- BRIN index for large time-series data
CREATE INDEX idx_orders_order_date_brin ON orders USING brin(order_date);

-- Compare performance
EXPLAIN ANALYZE
SELECT COUNT(*) FROM orders 
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days';

-- When to use BRIN:
-- - Very large tables (> 10 million rows)
-- - Data is naturally ordered (like timestamps)
-- - Queries are on ranges (between dates)
-- - You don't need exact matches
```

---

### Implementation Step 3: ACID Transactions

#### 3.1 Basic Transaction Flow

ACID stands for Atomicity, Consistency, Isolation, Durability:

```sql
-- Complete checkout transaction
BEGIN;  -- Start transaction

-- 1. Create order
INSERT INTO orders (
    user_id, shipping_address_id, billing_address_id, order_number,
    subtotal, tax, shipping_cost, discount, total,
    payment_method, payment_status, status,
    shipping_method, estimated_delivery_date
) VALUES (
    'user-uuid', 'shipping-addr-uuid', 'billing-addr-uuid', 'ORD-2024-0005',
    99.99, 8.00, 5.99, 0.00, 113.98,
    'credit_card', 'pending', 'pending',
    'UPS Ground', CURRENT_DATE + INTERVAL '5 days'
);

-- 2. Insert order items
INSERT INTO order_items (
    order_id, product_id, product_name, product_description,
    unit_price, quantity, line_subtotal, line_tax, line_total
) 
SELECT 
    currval('orders_id_seq'::regclass),  -- Get the order ID we just created
    p.id,
    p.name,
    p.description,
    p.price,
    1,
    p.price,
    p.price * 0.08,
    p.price * 1.08
FROM products p
WHERE p.id = 1 AND p.stock_quantity > 0;

-- 3. Update inventory (if we had an inventory table)
-- UPDATE inventory SET quantity = quantity - 1 WHERE product_id = 1;

-- 4. If everything succeeded, commit
COMMIT;

-- If something fails, rollback
-- ROLLBACK;
```

#### 3.2 Inventory Reservation System

```sql
-- Create inventory table
CREATE TABLE IF NOT EXISTS inventory (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 0,
    reserved_quantity INTEGER NOT NULL DEFAULT 0,
    reorder_point INTEGER NOT NULL DEFAULT 10,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT positive_quantity CHECK (quantity >= 0),
    CONSTRAINT positive_reserved CHECK (reserved_quantity >= 0),
    CONSTRAINT sufficient_stock CHECK (quantity >= reserved_quantity)
);

-- Insert initial inventory data (based on products)
INSERT INTO inventory (product_id, quantity, reorder_point)
SELECT id, stock_quantity, 10
FROM products
ON CONFLICT (product_id) DO NOTHING;

-- Create inventory transaction log
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    transaction_type VARCHAR(20) NOT NULL,
    quantity INTEGER NOT NULL,
    previous_quantity INTEGER NOT NULL,
    new_quantity INTEGER NOT NULL,
    order_id UUID REFERENCES orders(id),
    user_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_transaction_type CHECK (
        transaction_type IN ('reserve', 'release', 'sell', 'restock', 'adjust')
    )
);

-- Function to reserve inventory
CREATE OR REPLACE FUNCTION reserve_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_order_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_quantity INTEGER;
    v_available_quantity INTEGER;
BEGIN
    -- Lock the inventory row for update (prevents race conditions)
    SELECT quantity, quantity - reserved_quantity INTO v_current_quantity, v_available_quantity
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    -- Check if we have enough stock
    IF v_available_quantity < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product %. Available: %, Requested: %', 
            p_product_id, v_available_quantity, p_quantity;
    END IF;
    
    -- Update reserved quantity
    UPDATE inventory 
    SET 
        reserved_quantity = reserved_quantity + p_quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = p_product_id;
    
    -- Log the transaction
    INSERT INTO inventory_transactions (
        product_id, transaction_type, quantity,
        previous_quantity, new_quantity, order_id
    ) VALUES (
        p_product_id, 'reserve', p_quantity,
        v_current_quantity, v_current_quantity - p_quantity,
        p_order_id
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to release reserved inventory (for cancelled orders)
CREATE OR REPLACE FUNCTION release_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_order_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_quantity INTEGER;
BEGIN
    -- Lock the inventory row
    SELECT quantity INTO v_current_quantity
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    -- Update reserved quantity
    UPDATE inventory 
    SET 
        reserved_quantity = GREATEST(0, reserved_quantity - p_quantity),
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = p_product_id;
    
    -- Log the transaction
    INSERT INTO inventory_transactions (
        product_id, transaction_type, quantity,
        previous_quantity, new_quantity, order_id
    ) VALUES (
        p_product_id, 'release', -p_quantity,
        v_current_quantity, v_current_quantity + p_quantity,
        p_order_id
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to complete sale (sell reserved inventory)
CREATE OR REPLACE FUNCTION sell_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_order_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_quantity INTEGER;
BEGIN
    -- Lock the inventory row
    SELECT quantity INTO v_current_quantity
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    -- Update quantities
    UPDATE inventory 
    SET 
        quantity = quantity - p_quantity,
        reserved_quantity = GREATEST(0, reserved_quantity - p_quantity),
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = p_product_id;
    
    -- Log the transaction
    INSERT INTO inventory_transactions (
        product_id, transaction_type, quantity,
        previous_quantity, new_quantity, order_id
    ) VALUES (
        p_product_id, 'sell', -p_quantity,
        v_current_quantity, v_current_quantity - p_quantity,
        p_order_id
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

#### 3.3 Complete Checkout with Inventory

```sql
-- Complete checkout with inventory management
CREATE OR REPLACE FUNCTION checkout_order(
    p_user_id UUID,
    p_shipping_address_id UUID,
    p_billing_address_id UUID,
    p_payment_method VARCHAR,
    p_shipping_method VARCHAR,
    p_items JSONB,  -- Array of {product_id, quantity}
    p_discount NUMERIC DEFAULT 0
)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
    v_item JSONB;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_unit_price NUMERIC;
    v_line_subtotal NUMERIC;
    v_subtotal NUMERIC := 0;
    v_tax NUMERIC := 0;
    v_shipping_cost NUMERIC := 5.99;
    v_total NUMERIC;
    v_order_number VARCHAR;
BEGIN
    -- Generate order number
    v_order_number := 'ORD-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' || 
                      LPAD(nextval('orders_order_number_seq'::regclass)::TEXT, 4, '0');
    
    -- Start transaction
    BEGIN
        -- Calculate subtotal
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;
            
            -- Get current price
            SELECT price INTO v_unit_price
            FROM products
            WHERE id = v_product_id AND deleted_at IS NULL;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Product % not found', v_product_id;
            END IF;
            
            -- Reserve inventory
            PERFORM reserve_inventory(v_product_id, v_quantity, NULL);
            
            -- Calculate line subtotal
            v_line_subtotal := v_unit_price * v_quantity;
            v_subtotal := v_subtotal + v_line_subtotal;
        END LOOP;
        
        -- Calculate tax (8%)
        v_tax := v_subtotal * 0.08;
        
        -- Calculate total
        v_total := v_subtotal + v_tax + v_shipping_cost - p_discount;
        
        -- Create order
        INSERT INTO orders (
            user_id, shipping_address_id, billing_address_id, order_number,
            subtotal, tax, shipping_cost, discount, total,
            payment_method, payment_status, status,
            shipping_method, estimated_delivery_date
        ) VALUES (
            p_user_id, p_shipping_address_id, p_billing_address_id, v_order_number,
            v_subtotal, v_tax, v_shipping_cost, p_discount, v_total,
            p_payment_method, 'pending', 'pending',
            p_shipping_method, CURRENT_DATE + INTERVAL '5 days'
        )
        RETURNING id INTO v_order_id;
        
        -- Insert order items and commit inventory
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;
            
            SELECT price INTO v_unit_price
            FROM products
            WHERE id = v_product_id;
            
            -- Insert order item
            INSERT INTO order_items (
                order_id, product_id, product_name, product_description,
                unit_price, quantity, line_subtotal, line_tax, line_total
            )
            SELECT 
                v_order_id,
                p.id,
                p.name,
                p.description,
                v_unit_price,
                v_quantity,
                v_unit_price * v_quantity,
                v_unit_price * v_quantity * 0.08,
                v_unit_price * v_quantity * 1.08
            FROM products p
            WHERE p.id = v_product_id;
            
            -- Complete the sale (move from reserved to sold)
            PERFORM sell_inventory(v_product_id, v_quantity, v_order_id);
        END LOOP;
        
        -- Commit transaction
        COMMIT;
        
        RETURN v_order_id;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback everything on error
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

-- Create sequence for order numbers
CREATE SEQUENCE IF NOT EXISTS orders_order_number_seq START 1;

-- Test the checkout function
SELECT checkout_order(
    (SELECT id FROM users WHERE email = 'carol.customer@example.com' LIMIT 1),
    (SELECT id FROM addresses WHERE user_id = (SELECT id FROM users WHERE email = 'carol.customer@example.com' LIMIT 1) LIMIT 1),
    (SELECT id FROM addresses WHERE user_id = (SELECT id FROM users WHERE email = 'carol.customer@example.com' LIMIT 1) LIMIT 1),
    'credit_card',
    'UPS Ground',
    '[{"product_id": 1, "quantity": 2}, {"product_id": 3, "quantity": 1}]'::jsonb,
    10.00
);
```

---

### Implementation Step 4: CI/CD with Neon Branches

#### 4.1 GitHub Actions Workflow with Neon

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  NEON_API_KEY: ${{ secrets.NEON_API_KEY }}
  PROJECT_ID: ${{ secrets.NEON_PROJECT_ID }}
  DATABASE_URL: ${{ secrets.DATABASE_URL }}

jobs:
  test-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Neon CLI
        run: npm install -g neonctl
      
      - name: Create Preview Branch for PR
        if: github.event_name == 'pull_request'
        run: |
          BRANCH_NAME="pr-${{ github.event.pull_request.number }}"
          neonctl branches create \
            --name $BRANCH_NAME \
            --parent main \
            --project-id $PROJECT_ID
          echo "BRANCH_NAME=$BRANCH_NAME" >> $GITHUB_ENV
          echo "PR_NUMBER=${{ github.event.pull_request.number }}" >> $GITHUB_ENV
      
      - name: Run Migrations on Preview Branch
        if: github.event_name == 'pull_request'
        run: |
          CONN_STRING=$(neonctl branches get-connection-string $BRANCH_NAME --project-id $PROJECT_ID)
          psql "$CONN_STRING" -f migrations/001_create_users_table.sql
          psql "$CONN_STRING" -f migrations/002_create_ecommerce_tables.sql
          psql "$CONN_STRING" -f migrations/003_add_wishlists.sql
      
      - name: Run Tests on Preview Branch
        if: github.event_name == 'pull_request'
        run: |
          export DATABASE_URL=$(neonctl branches get-connection-string $BRANCH_NAME --project-id $PROJECT_ID)
          npm install
          npm test
      
      - name: Merge Preview Branch on PR Merge
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          # When PR is merged, merge the preview branch to main
          PR_NUMBER=$(echo ${{ github.event.head_commit.message }} | grep -o '#[0-9]*' | head -1 | tr -d '#')
          if [ ! -z "$PR_NUMBER" ]; then
            BRANCH_NAME="pr-$PR_NUMBER"
            neonctl branches merge $BRANCH_NAME --target main --project-id $PROJECT_ID
            neonctl branches delete $BRANCH_NAME --project-id $PROJECT_ID
          fi
      
      - name: Run Migrations on Production
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          psql "$DATABASE_URL" -f migrations/001_create_users_table.sql
          psql "$DATABASE_URL" -f migrations/002_create_ecommerce_tables.sql
          psql "$DATABASE_URL" -f migrations/003_add_wishlists.sql
      
      - name: Create Database Backup Before Deploy
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          TIMESTAMP=$(date +%Y%m%d_%H%M%S)
          neonctl branches create \
            --name "backup-$TIMESTAMP" \
            --parent main \
            --project-id $PROJECT_ID
      
      - name: Notify Deployment Status
        run: |
          if [ ${{ job.status }} == 'success' ]; then
            echo "✅ Deployment successful!"
          else
            echo "❌ Deployment failed!"
            exit 1
          fi
```

#### 4.2 Database Migration Scripts Structure

```sql
-- migrations/001_create_users_table.sql
-- Version: 1.0.0
-- Description: Create users table with constraints
-- Rollback: migrations/001_rollback_users_table.sql

-- migrations/002_create_ecommerce_tables.sql
-- Version: 1.1.0
-- Description: Create addresses, orders, order_items tables
-- Dependencies: 001_create_users_table.sql
-- Rollback: migrations/002_rollback_ecommerce_tables.sql

-- migrations/003_add_wishlists.sql
-- Version: 1.2.0
-- Description: Add wishlists table for user favorites
-- Dependencies: 001_create_users_table.sql, 002_create_ecommerce_tables.sql
-- Rollback: migrations/003_rollback_wishlists.sql

-- Create migration tracking table
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(50) PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT
);

-- Migration wrapper function
CREATE OR REPLACE FUNCTION apply_migration(
    p_version VARCHAR,
    p_sql TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if migration already applied
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = p_version) THEN
        RAISE NOTICE 'Migration % already applied, skipping...', p_version;
        RETURN FALSE;
    END IF;
    
    BEGIN
        -- Execute the migration SQL
        EXECUTE p_sql;
        
        -- Record successful migration
        INSERT INTO schema_migrations (version, success)
        VALUES (p_version, TRUE);
        
        RAISE NOTICE 'Migration % applied successfully', p_version;
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN
            -- Record failed migration
            INSERT INTO schema_migrations (version, success, error_message)
            VALUES (p_version, FALSE, SQLERRM);
            
            RAISE NOTICE 'Migration % failed: %', p_version, SQLERRM;
            RETURN FALSE;
    END;
END;
$$ LANGUAGE plpgsql;
```

---

### Implementation Step 5: Production Monitoring

#### 5.1 Database Monitoring Queries

```sql
-- Active connections monitoring
SELECT 
    pid,
    usename,
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

-- Query performance monitoring
SELECT 
    queryid,
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    min_exec_time,
    max_exec_time,
    stddev_exec_time,
    rows,
    shared_blks_hit,
    shared_blks_read
FROM pg_stat_statements
WHERE calls > 100
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Table size and growth
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

-- Index usage monitoring
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND idx_scan = 0  -- Unused indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Lock monitoring
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.query AS blocked_query,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.query AS blocking_query,
    blocked_locks.mode AS lock_mode,
    blocked_locks.granted AS is_granted,
    now() - blocked_activity.state_change AS blocked_duration
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_locks.pid = blocked_activity.pid
JOIN pg_catalog.pg_locks blocking_locks 
    ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_locks.pid = blocking_activity.pid
WHERE NOT blocked_locks.granted;
```

#### 5.2 Create Monitoring Views

```sql
-- Create view for daily health check
CREATE VIEW database_health_check AS
SELECT 
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS idle_connections,
    (SELECT count(*) FROM orders WHERE status = 'pending' AND order_date < CURRENT_DATE - INTERVAL '1 hour') AS stuck_orders,
    (SELECT count(*) FROM inventory WHERE quantity < reorder_point) AS low_stock_items,
    (SELECT count(*) FROM users WHERE deleted_at IS NULL AND created_at > CURRENT_DATE - INTERVAL '24 hours') AS new_users_today,
    (SELECT count(*) FROM orders WHERE deleted_at IS NULL AND order_date > CURRENT_DATE - INTERVAL '24 hours') AS orders_today,
    pg_size_pretty(pg_database_size(current_database())) AS database_size,
    CURRENT_TIMESTAMP AS checked_at;

-- Create alerting function
CREATE OR REPLACE FUNCTION check_health_and_alert()
RETURNS TABLE(
    alert_level TEXT,
    alert_message TEXT
) AS $$
BEGIN
    -- Check for stuck orders
    IF EXISTS (
        SELECT 1 FROM orders 
        WHERE status = 'pending' 
        AND order_date < CURRENT_DATE - INTERVAL '1 hour'
    ) THEN
        RETURN QUERY SELECT 'WARNING'::TEXT, 'Stuck pending orders found'::TEXT;
    END IF;
    
    -- Check for low stock
    IF EXISTS (
        SELECT 1 FROM inventory 
        WHERE quantity < reorder_point AND quantity > 0
    ) THEN
        RETURN QUERY SELECT 'WARNING'::TEXT, 'Low stock items need reordering'::TEXT;
    END IF;
    
    -- Check for out of stock
    IF EXISTS (
        SELECT 1 FROM inventory 
        WHERE quantity = 0
    ) THEN
        RETURN QUERY SELECT 'CRITICAL'::TEXT, 'Items are out of stock'::TEXT;
    END IF;
    
    -- Check for database size growth
    IF pg_database_size(current_database()) > 10 * 1024 * 1024 * 1024 THEN
        RETURN QUERY SELECT 'WARNING'::TEXT, 'Database size > 10GB, consider cleanup'::TEXT;
    END IF;
    
    -- No issues found
    RETURN QUERY SELECT 'OK'::TEXT, 'All systems healthy'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Health check
SELECT * FROM database_health_check;
SELECT * FROM check_health_and_alert();
```

---

### Implementation Step 6: Production Deployment Checklist

#### 6.1 Pre-Deployment Script

```sql
-- Pre-deployment validation script
-- Run this before deploying to production

-- 1. Check for pending migrations
SELECT * FROM schema_migrations WHERE success = FALSE ORDER BY applied_at DESC LIMIT 5;

-- 2. Verify foreign key constraints are valid
SELECT 
    conname,
    contype,
    pg_catalog.pg_get_constraintdef(r.oid, true) AS constraint_def
FROM pg_catalog.pg_constraint r
WHERE r.conrelid IN (
    SELECT oid FROM pg_class WHERE relname IN ('orders', 'order_items', 'addresses')
)
AND r.contype = 'f'
AND NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE contype = 'f' AND convalidated = false
);

-- 3. Check for duplicate data that might violate unique constraints
SELECT 
    email,
    COUNT(*) as duplicate_count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- 4. Check for orphaned records
SELECT 
    'addresses' as table_name,
    COUNT(*) as orphaned_records
FROM addresses a
LEFT JOIN users u ON a.user_id = u.id
WHERE u.id IS NULL
AND a.deleted_at IS NULL;

SELECT 
    'orders' as table_name,
    COUNT(*) as orphaned_records
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL
AND o.deleted_at IS NULL;

-- 5. Estimate time for migration
SELECT 
    COUNT(*) AS estimated_rows_to_update
FROM products
WHERE search_vector IS NULL OR length(search_vector::text) < 10;
```

#### 6.2 Production Configuration

Create `config/production.js`:

```javascript
// Production database configuration for Neon
module.exports = {
    database: {
        // Use pooled connection for serverless
        connectionString: process.env.DATABASE_POOLED_URL,
        
        // Connection pool configuration
        pool: {
            max: 20,                    // Maximum connections in pool
            idleTimeoutMillis: 30000,   // Close idle connections after 30s
            connectionTimeoutMillis: 2000,
            keepAlive: true,
        },
        
        // SSL configuration
        ssl: {
            rejectUnauthorized: true,
            ca: process.env.DB_CA_CERT,
        },
        
        // Query timeouts
        statement_timeout: 60000,      // 60 seconds
        idle_in_transaction_session_timeout: 30000, // 30 seconds
    },
    
    // Monitoring configuration
    monitoring: {
        slowQueryThreshold: 1000,      // Log queries > 1 second
        connectionTimeoutThreshold: 5000,
        healthCheckInterval: 30000,     // 30 seconds
    },
    
    // Backup configuration
    backup: {
        enabled: true,
        schedule: '0 2 * * *',          // Daily at 2 AM
        retentionDays: 30,
    },
};

// Health check middleware
async function healthCheck(req, res) {
    try {
        const client = await pool.connect();
        const result = await client.query('SELECT 1 as health_check');
        client.release();
        
        res.status(200).json({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            database: 'connected',
            version: process.version,
        });
    } catch (error) {
        res.status(500).json({
            status: 'unhealthy',
            error: error.message,
        });
    }
}

// Query logging middleware
function logQueries() {
    const originalQuery = pool.query.bind(pool);
    pool.query = function(text, params, callback) {
        const startTime = Date.now();
        const result = originalQuery(text, params, callback);
        
        if (typeof callback === 'function') {
            const endTime = Date.now();
            const duration = endTime - startTime;
            
            if (duration > 1000) {
                console.warn(`Slow Query (${duration}ms): ${text}`);
            }
        }
        
        return result;
    };
}
```

#### 6.3 Disaster Recovery Procedures

```sql
-- Create backup function
CREATE OR REPLACE FUNCTION create_database_backup()
RETURNS TEXT AS $$
DECLARE
    backup_name TEXT;
    backup_branch_name TEXT;
BEGIN
    -- Create a descriptive backup name
    backup_name := 'backup_' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS');
    backup_branch_name := 'manual_backup_' || backup_name;
    
    -- Create backup branch in Neon (using Neon CLI)
    -- This would be executed as a shell command in actual production
    -- neonctl branches create --name backup_branch_name --parent main
    
    -- Log the backup
    INSERT INTO backup_log (backup_name, created_at, status)
    VALUES (backup_name, CURRENT_TIMESTAMP, 'success');
    
    RETURN backup_name;
END;
$$ LANGUAGE plpgsql;

-- Create backup log table
CREATE TABLE IF NOT EXISTS backup_log (
    id SERIAL PRIMARY KEY,
    backup_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'success',
    restore_point TEXT,
    notes TEXT
);

-- Restore procedure
-- 1. Identify backup to restore
-- SELECT * FROM backup_log ORDER BY created_at DESC;

-- 2. Create restore branch in Neon
-- neonctl branches create --name restore-backup --parent backup_branch_name

-- 3. Test restore
-- psql "$(neonctl branches get-connection-string restore-backup)" -c "SELECT COUNT(*) FROM orders;"

-- 4. If successful, promote restore branch
-- neonctl branches merge restore-backup --target main
```

---

### Implementation Step 7: Final Application Architecture

#### 7.1 Complete Application Structure

```
project/
├── src/
│   ├── config/
│   │   ├── database.js          # Database configuration
│   │   └── neon.js              # Neon-specific configuration
│   ├── models/
│   │   ├── User.js
│   │   ├── Product.js
│   │   ├── Order.js
│   │   ├── Inventory.js
│   │   └── OrderItem.js
│   ├── services/
│   │   ├── CheckoutService.js   # Handles checkout transactions
│   │   ├── InventoryService.js  # Manages inventory
│   │   ├── SearchService.js     # Hybrid search implementation
│   │   └── AnalyticsService.js  # Reporting and analytics
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── errorHandler.js
│   │   └── requestLogger.js
│   ├── routes/
│   │   ├── products.js
│   │   ├── orders.js
│   │   ├── users.js
│   │   └── analytics.js
│   ├── migrations/
│   │   ├── 001_create_users_table.sql
│   │   ├── 001_rollback_users_table.sql
│   │   ├── 002_create_ecommerce_tables.sql
│   │   ├── 002_rollback_ecommerce_tables.sql
│   │   └── migration_runner.js
│   ├── tests/
│   │   ├── unit/
│   │   ├── integration/
│   │   └── e2e/
│   └── app.js                   # Main application file
├── scripts/
│   ├── seed.js                  # Database seeding
│   ├── backup.js               # Backup utilities
│   └── health-check.js         # Health check script
├── .github/
│   └── workflows/
│       ├── deploy.yml          # GitHub Actions workflow
│       └── test.yml
├── .env.example
├── docker-compose.yml
├── package.json
└── README.md
```

#### 7.2 Complete Checkout API Example

```javascript
// src/services/CheckoutService.js
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_POOLED_URL });

class CheckoutService {
    async checkout(userId, items, paymentInfo, shippingInfo) {
        const client = await pool.connect();
        
        try {
            await client.query('BEGIN');
            
            // 1. Validate inventory
            for (const item of items) {
                const result = await client.query(
                    `SELECT quantity, reserved_quantity 
                     FROM inventory 
                     WHERE product_id = $1 
                     FOR UPDATE`,
                    [item.productId]
                );
                
                const available = result.rows[0].quantity - result.rows[0].reserved_quantity;
                if (available < item.quantity) {
                    throw new Error(`Insufficient stock for product ${item.productId}`);
                }
            }
            
            // 2. Create order
            const orderResult = await client.query(
                `INSERT INTO orders (user_id, shipping_address_id, billing_address_id, 
                                   order_number, subtotal, tax, shipping_cost, discount, total,
                                   payment_method, payment_status, status, shipping_method)
                 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
                 RETURNING id, order_number`,
                [
                    userId,
                    shippingInfo.addressId,
                    billingInfo.addressId,
                    this.generateOrderNumber(),
                    items.reduce((sum, item) => sum + item.price * item.quantity, 0),
                    items.reduce((sum, item) => sum + item.price * item.quantity * 0.08, 0),
                    5.99,
                    0,
                    this.calculateTotal(items),
                    paymentInfo.method,
                    'pending',
                    'pending',
                    shippingInfo.method
                ]
            );
            
            const orderId = orderResult.rows[0].id;
            
            // 3. Insert order items and update inventory
            for (const item of items) {
                await client.query(
                    `INSERT INTO order_items (order_id, product_id, product_name, 
                                            product_description, unit_price, quantity,
                                            line_subtotal, line_tax, line_total)
                     SELECT $1, $2, name, description, $3, $4, $3 * $4, $3 * $4 * 0.08, $3 * $4 * 1.08
                     FROM products WHERE id = $2`,
                    [orderId, item.productId, item.price, item.quantity]
                );
                
                await client.query(
                    `UPDATE inventory 
                     SET quantity = quantity - $2,
                         reserved_quantity = GREATEST(0, reserved_quantity - $2)
                     WHERE product_id = $1`,
                    [item.productId, item.quantity]
                );
            }
            
            await client.query('COMMIT');
            
            return {
                orderId,
                orderNumber: orderResult.rows[0].order_number,
                status: 'success',
                message: 'Order placed successfully'
            };
            
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }
    
    generateOrderNumber() {
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
        return `ORD-${year}-${month}-${day}-${random}`;
    }
    
    calculateTotal(items) {
        const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
        const tax = subtotal * 0.08;
        const shipping = 5.99;
        return subtotal + tax + shipping;
    }
}

module.exports = CheckoutService;
```

---

### Implementation Step 8: Final Verification

#### 8.1 Complete System Health Check

```sql
-- Production readiness check
CREATE OR REPLACE FUNCTION production_readiness_check()
RETURNS TABLE(
    check_name TEXT,
    status TEXT,
    details TEXT
) AS $$
BEGIN
    -- Check 1: All extensions installed
    RETURN QUERY SELECT 
        'Extensions Check'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname IN ('uuid-ossp', 'pg_trgm'))
            THEN 'PASS' 
            ELSE 'FAIL' 
        END::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp')
            THEN 'uuid-ossp installed. '
            ELSE 'uuid-ossp missing. '
        END || 
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm')
            THEN 'pg_trgm installed.'
            ELSE 'pg_trgm missing.'
        END;
    
    -- Check 2: All indexes created
    RETURN QUERY SELECT 
        'Index Check'::TEXT,
        CASE 
            WHEN (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'orders') >= 5
            THEN 'PASS' 
            ELSE 'FAIL' 
        END::TEXT,
        'Orders table has ' || (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'orders') || ' indexes.';
    
    -- Check 3: Foreign keys exist
    RETURN QUERY SELECT 
        'Foreign Keys Check'::TEXT,
        CASE 
            WHEN (SELECT COUNT(*) FROM pg_constraint WHERE contype = 'f' AND conrelid = 'orders'::regclass) >= 2
            THEN 'PASS' 
            ELSE 'FAIL' 
        END::TEXT,
        'Orders has ' || (SELECT COUNT(*) FROM pg_constraint WHERE contype = 'f' AND conrelid = 'orders'::regclass) || ' foreign keys.';
    
    -- Check 4: Data exists
    RETURN QUERY SELECT 
        'Data Check'::TEXT,
        CASE 
            WHEN (SELECT COUNT(*) FROM products) > 0 
             AND (SELECT COUNT(*) FROM users) > 0
             AND (SELECT COUNT(*) FROM orders) > 0
            THEN 'PASS' 
            ELSE 'FAIL' 
        END::TEXT,
        'Products: ' || (SELECT COUNT(*) FROM products) || 
        ', Users: ' || (SELECT COUNT(*) FROM users) ||
        ', Orders: ' || (SELECT COUNT(*) FROM orders);
    
    -- Check 5: JSONB data exists
    RETURN QUERY SELECT 
        'JSONB Check'::TEXT,
        CASE 
            WHEN (SELECT COUNT(*) FROM products WHERE attributes <> '{}'::jsonb) > 0
            THEN 'PASS' 
            ELSE 'FAIL' 
        END::TEXT,
        'Products with attributes: ' || (SELECT COUNT(*) FROM products WHERE attributes <> '{}'::jsonb);
    
    -- Check 6: Search capabilities
    RETURN QUERY SELECT 
        'Search Check'::TEXT,
        CASE 
            WHEN (SELECT COUNT(*) FROM products WHERE search_vector IS NOT NULL) > 0
            THEN 'PASS' 
            ELSE 'FAIL' 
        END::TEXT,
        'Products indexed for search: ' || (SELECT COUNT(*) FROM products WHERE search_vector IS NOT NULL);
END;
$$ LANGUAGE plpgsql;

-- Run the production readiness check
SELECT * FROM production_readiness_check();
```

---

### Verification Checklist

Before deploying to production, confirm you can:

- [ ] Use EXPLAIN ANALYZE to identify slow queries
- [ ] Create and use various index types (B-Tree, GIN, BRIN)
- [ ] Implement transactions with BEGIN, COMMIT, ROLLBACK
- [ ] Build an inventory reservation system with row-level locking
- [ ] Set up CI/CD with Neon branches and GitHub Actions
- [ ] Implement monitoring and alerting queries
- [ ] Create backup and restore procedures
- [ ] Use connection pooling for serverless environments
- [ ] Pass all production readiness checks
- [ ] Deploy your application with zero downtime

---

### Deep Dive: Advanced Performance Tuning

**PostgreSQL Configuration for Neon**:

```sql
-- Show current settings
SHOW max_connections;
SHOW shared_buffers;
SHOW work_mem;
SHOW maintenance_work_mem;

-- Recommended settings for Neon (can be set in Neon console)
-- max_connections: Automatically managed by Neon
-- shared_buffers: 25% of available RAM
-- work_mem: 4MB-64MB depending on query complexity
-- maintenance_work_mem: 64MB-1GB for maintenance operations

-- Connection pooling settings
-- pool_mode=transaction: Best for serverless
-- pool_mode=session: Best for long-running applications

-- Query optimization tips
-- 1. Use LIMIT for large result sets
-- 2. Avoid SELECT * on large tables
-- 3. Use EXISTS instead of IN for large subqueries
-- 4. Index foreign keys
-- 5. Use UNIQUE constraints for natural keys
-- 6. Partition very large tables
-- 7. Use MATERIALIZED VIEWS for expensive queries
-- 8. Use VACUUM ANALYZE regularly
```

---

### Summary: What You've Built

Congratulations! You've built a complete, production-ready e-commerce backend with Neon PostgreSQL. Throughout this series, you've learned:

1. **Part 1**: Setup, CRUD operations, and basic querying
2. **Part 2**: Data integrity with constraints and UUIDs
3. **Part 3**: Relational architecture with branches and joins
4. **Part 4**: Analytics with aggregations and window functions
5. **Part 5**: JSONB flexibility and powerful search
6. **Part 6**: Performance, transactions, CI/CD, and production readiness

**Your Final Architecture** includes:
- ✅ Serverless PostgreSQL with automatic scaling
- ✅ Production-grade data integrity and validation
- ✅ Complex relational models with foreign keys
- ✅ Real-time analytics and reporting
- ✅ Flexible JSONB data with advanced search
- ✅ ACID transactions with inventory management
- ✅ CI/CD with Neon database branches
- ✅ Comprehensive monitoring and health checks

**Key Neon Features You've Used**:
- ✅ Instant database provisioning
- ✅ Database branching for development and testing
- ✅ Connection pooling for serverless applications
- ✅ Automatic backups and point-in-time recovery

---

### Next Steps

Now that you've built the backend, consider:

1. **Build a frontend**: React, Next.js, or any framework
2. **Implement caching**: Redis for frequently accessed data
3. **Add authentication**: JWT with the users table
4. **Implement payments**: Stripe or PayPal integration
5. **Add email notifications**: Order confirmations, shipping updates
6. **Build an admin dashboard**: Analytics, inventory management
7. **Scale**: Use Neon's branching for microservices
8. **Monitor**: Set up Datadog, New Relic, or similar

**Resources**:
- [Neon Documentation](https://neon.tech/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [GitHub Actions with Neon](https://neon.tech/docs/guides/github-actions)

You're now a Neon PostgreSQL expert! 🎉

---

## Series Recap

**Serverless Postgres with Neon: From Zero to Production** is complete! You've gone from zero to a production-ready e-commerce backend with:

### Part 0: Introduction
- Series scope and architecture overview
- Target audience and prerequisites

### Part 1: Instant Setup & Cloud SQL Fundamentals
- Neon account and database provisioning
- Basic CRUD operations on products table
- Filtering, sorting, and pagination

### Part 2: Bulletproof Schemas & Data Integrity
- Primary keys (SERIAL vs UUID)
- Comprehensive constraints and validation
- Neon connection pooling

### Part 3: Database Branching & Relational Architecture
- Neon branch creation and management
- Relational tables (addresses, orders, order_items)
- Foreign keys and complex JOIN queries

### Part 4: Analytical Power
- Aggregations (COUNT, SUM, AVG, MIN, MAX)
- Grouping with GROUP BY and HAVING
- Window functions (ROW_NUMBER, RANK, LAG, LEAD)

### Part 5: Semi-Structured Data with JSONB
- JSONB storage and querying
- PostgreSQL extensions (pg_trgm)
- Fuzzy search and hybrid search

### Part 6: Performance & Production Readiness
- Query optimization with EXPLAIN ANALYZE
- Advanced indexing strategies
- ACID transactions and inventory management
- CI/CD with Neon branches
- Production monitoring and deployment

**You're now equipped to build scalable, production-grade applications with Neon PostgreSQL!**
