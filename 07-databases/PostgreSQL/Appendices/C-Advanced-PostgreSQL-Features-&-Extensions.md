# Appendix C: Advanced PostgreSQL Features & Extensions

Beyond the core features we've covered, PostgreSQL offers a rich ecosystem of advanced capabilities. This appendix explores powerful features like full-text search, table partitioning, advanced indexing, and essential extensions that can supercharge your e-commerce application.

## C.1 Full-Text Search (FTS)

### Target
Implement powerful, production-grade search capabilities using PostgreSQL's built-in full-text search.

### Concept
Full-text search transforms your database into a search engine. Instead of simple `LIKE` patterns, FTS understands language, handles word stemming, ranks results by relevance, and supports complex queries. Think of it as giving your e-commerce site Google-like search capabilities.

---

## C.1.1 Setting Up Full-Text Search

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Check available text search configurations
SELECT cfgname, cfgparser 
FROM pg_ts_config 
ORDER BY cfgname;

-- 2. Create a text search configuration for English (if not exists)
-- English is usually default, but we'll be explicit
CREATE TEXT SEARCH CONFIGURATION IF NOT EXISTS english_fts (
    COPY = english
);

-- 3. Add columns for search vectors to products table
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS search_vector TSVECTOR;

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS search_rank FLOAT;

-- 4. Create a GIN index for fast full-text search
CREATE INDEX IF NOT EXISTS idx_products_search_vector 
ON products USING GIN(search_vector);

-- 5. Create a trigger to automatically update search_vector
CREATE OR REPLACE FUNCTION products_search_vector_update() 
RETURNS TRIGGER AS $$
BEGIN
    -- Combine name and description, remove stop words, apply stemming
    NEW.search_vector = 
        SETWEIGHT(TO_TSVECTOR('english', COALESCE(NEW.name, '')), 'A') ||
        SETWEIGHT(TO_TSVECTOR('english', COALESCE(NEW.description, '')), 'B') ||
        SETWEIGHT(TO_TSVECTOR('english', COALESCE(NEW.metadata->>'brand', '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS products_search_vector_trigger ON products;

CREATE TRIGGER products_search_vector_trigger
    BEFORE INSERT OR UPDATE OF name, description, metadata ON products
    FOR EACH ROW
    EXECUTE FUNCTION products_search_vector_update();

-- 6. Update existing products
UPDATE products SET name = name; -- Trigger update

-- 7. Check the search vectors
SELECT id, name, search_vector 
FROM products 
WHERE search_vector IS NOT NULL 
LIMIT 5;

-- 8. Basic full-text search
SELECT 
    id,
    name,
    description,
    TS_RANK(search_vector, TO_TSQUERY('english', 'wireless & headphones')) AS relevance
FROM products
WHERE search_vector @@ TO_TSQUERY('english', 'wireless & headphones')
ORDER BY relevance DESC
LIMIT 10;

-- 9. Search with ranking and highlighting
SELECT 
    id,
    name,
    TS_RANK(search_vector, query) AS relevance,
    TS_HEADLINE('english', description, query, 'MaxWords=30, MinWords=15, StartSel=<mark>, StopSel=</mark>') AS highlighted_description
FROM products,
TO_TSQUERY('english', 'wireless & headphones') AS query
WHERE search_vector @@ query
ORDER BY relevance DESC
LIMIT 10;
```

### The Verification

```bash
# Test full-text search
psql -d ecommerce -c "
SELECT 
    name,
    TS_RANK(search_vector, TO_TSQUERY('english', 'wireless')) AS relevance
FROM products
WHERE search_vector @@ TO_TSQUERY('english', 'wireless')
ORDER BY relevance DESC
LIMIT 5;"

# Check the search index
psql -d ecommerce -c "EXPLAIN ANALYZE
SELECT name FROM products 
WHERE search_vector @@ TO_TSQUERY('english', 'wireless');"
```

---

## C.1.2 Advanced Full-Text Search Queries

```sql
-- 1. Phrase search (exact phrase matching)
SELECT 
    id, name,
    TS_RANK(search_vector, TO_TSQUERY('english', 'bluetooth <-> headphones')) AS relevance
FROM products
WHERE search_vector @@ TO_TSQUERY('english', 'bluetooth <-> headphones')
ORDER BY relevance DESC;

-- 2. Prefix matching (partial word search)
SELECT id, name
FROM products
WHERE search_vector @@ TO_TSQUERY('english', 'wire:*');

-- 3. Search with synonyms (thesaurus)
-- Create a thesaurus dictionary
CREATE TEXT SEARCH DICTIONARY my_thesaurus (
    TEMPLATE = thesaurus,
    DictFile = 'my_thesaurus',
    Dictionary = 'english_stem'
);

-- Thesaurus file example (in $PGDATA/tsearch_data/my_thesaurus.ths):
-- wireless : bluetooth, wifi, airpods
-- headphones : headset, earbuds, earphones

-- 4. Search with multiple fields weighted
-- Weights: A=5, B=4, C=3, D=1
SELECT 
    id,
    name,
    TS_RANK(search_vector, TO_TSQUERY('english', 'bluetooth & headphones')) AS relevance
FROM products
WHERE search_vector @@ TO_TSQUERY('english', 'bluetooth & headphones')
ORDER BY relevance DESC;

-- 5. Full-text search with JSONB metadata
SELECT 
    id,
    name,
    metadata->>'brand' AS brand,
    TS_RANK(search_vector, query) AS relevance
FROM products,
TO_TSQUERY('english', 'audio & pro') AS query
WHERE search_vector @@ query
  AND metadata->>'brand' ILIKE '%audio%'
ORDER BY relevance DESC;

-- 6. Search with filters (price, stock, etc.)
SELECT 
    id,
    name,
    price,
    stock_quantity,
    TS_RANK(search_vector, TO_TSQUERY('english', 'laptop & stand')) AS relevance
FROM products
WHERE search_vector @@ TO_TSQUERY('english', 'laptop & stand')
  AND price BETWEEN 20 AND 100
  AND stock_quantity > 0
ORDER BY relevance DESC, price;

-- 7. Search suggestion (auto-complete)
SELECT 
    word,
    ndoc
FROM ts_stat('SELECT search_vector FROM products')
WHERE word ILIKE 'wireless%'
  OR word ILIKE 'bluetooth%'
ORDER BY ndoc DESC
LIMIT 10;
```

---

## C.2 Table Partitioning

### Target
Implement table partitioning to handle large datasets and improve performance.

### Concept
Partitioning splits a large table into smaller, more manageable pieces. Think of it like organizing a filing cabinet—instead of one giant drawer, you have multiple drawers organized by date. This improves query performance and makes maintenance easier.

---

## C.2.1 Range Partitioning by Date

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Create partitioned orders table
-- First, drop old orders table if we're migrating
-- BACKUP YOUR DATA FIRST!

-- Create the partitioned table
CREATE TABLE orders_partitioned (
    LIKE orders INCLUDING ALL,
    created_at TIMESTAMPTZ NOT NULL
) PARTITION BY RANGE (created_at);

-- 2. Create monthly partitions
-- We'll create partitions for the next 12 months
DO $$
DECLARE
    v_start_date DATE := '2024-01-01';
    v_end_date DATE := '2025-01-01';
    v_current_date DATE;
    v_partition_name TEXT;
    v_start_str TEXT;
    v_end_str TEXT;
BEGIN
    v_current_date := v_start_date;
    
    WHILE v_current_date < v_end_date LOOP
        v_partition_name := 'orders_' || TO_CHAR(v_current_date, 'YYYY_MM');
        v_start_str := TO_CHAR(v_current_date, 'YYYY-MM-DD');
        v_end_str := TO_CHAR(v_current_date + INTERVAL '1 month', 'YYYY-MM-DD');
        
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS %I PARTITION OF orders_partitioned
            FOR VALUES FROM (%L) TO (%L)',
            v_partition_name, v_start_str, v_end_str
        );
        
        v_current_date := v_current_date + INTERVAL '1 month';
    END LOOP;
END $$;

-- 3. Migrate data from old orders table
-- Check the date range
SELECT MIN(created_at), MAX(created_at) FROM orders;

-- Insert data into partitioned table
INSERT INTO orders_partitioned (
    id, user_id, status, subtotal, tax, shipping_cost, total,
    shipping_address_line1, shipping_address_line2, shipping_city,
    shipping_state, shipping_postal_code, shipping_country,
    payment_method, payment_status, payment_transaction_id,
    tracking_number, shipped_at, delivered_at, notes,
    created_at, updated_at
)
SELECT 
    id, user_id, status, subtotal, tax, shipping_cost, total,
    shipping_address_line1, shipping_address_line2, shipping_city,
    shipping_state, shipping_postal_code, shipping_country,
    payment_method, payment_status, payment_transaction_id,
    tracking_number, shipped_at, delivered_at, notes,
    created_at, updated_at
FROM orders
WHERE created_at IS NOT NULL;

-- 4. Verify data migration
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM orders_partitioned;

-- 5. Create indexes on partitions
CREATE INDEX idx_orders_partitioned_user_id ON orders_partitioned(user_id);
CREATE INDEX idx_orders_partitioned_status ON orders_partitioned(status);

-- 6. Query the partitioned table
-- This automatically uses the correct partition
SELECT * FROM orders_partitioned 
WHERE created_at BETWEEN '2024-01-01' AND '2024-02-01';

-- 7. Show partition structure
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE tablename LIKE 'orders_%'
ORDER BY tablename;

-- 8. Attach a new partition
CREATE TABLE orders_2025_01 PARTITION OF orders_partitioned
FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

-- 9. Detach and drop old partition
ALTER TABLE orders_partitioned DETACH PARTITION orders_2024_01;
DROP TABLE orders_2024_01;

-- 10. Automatic partition creation
-- Use pg_cron or a scheduled job to create partitions monthly
CREATE OR REPLACE FUNCTION create_next_month_partition()
RETURNS VOID AS $$
DECLARE
    v_next_month DATE := DATE_TRUNC('month', NOW()) + INTERVAL '1 month';
    v_partition_name TEXT;
BEGIN
    v_partition_name := 'orders_' || TO_CHAR(v_next_month, 'YYYY_MM');
    
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS %I PARTITION OF orders_partitioned
        FOR VALUES FROM (%L) TO (%L)',
        v_partition_name,
        v_next_month,
        v_next_month + INTERVAL '1 month'
    );
    
    RAISE NOTICE 'Created partition %', v_partition_name;
END;
$$ LANGUAGE plpgsql;

-- Run monthly
-- SELECT create_next_month_partition();
```

### The Verification

```bash
# Check partition structure
psql -d ecommerce -c "\d+ orders_partitioned"

# Check partition sizes
psql -d ecommerce -c "
SELECT 
    inhrelid::regclass AS partition,
    pg_size_pretty(pg_total_relation_size(inhrelid)) AS size
FROM pg_inherits
WHERE inhparent = 'orders_partitioned'::regclass
ORDER BY partition;"

# Test partition pruning
psql -d ecommerce -c "EXPLAIN ANALYZE
SELECT * FROM orders_partitioned 
WHERE created_at >= '2024-01-01' AND created_at < '2024-02-01';"
```

---

## C.2.2 List Partitioning by Status

```sql
-- Partition orders by status
CREATE TABLE orders_by_status (
    LIKE orders INCLUDING ALL
) PARTITION BY LIST (status);

-- Create partitions for each status
CREATE TABLE orders_status_pending PARTITION OF orders_by_status
    FOR VALUES IN ('pending');

CREATE TABLE orders_status_paid PARTITION OF orders_by_status
    FOR VALUES IN ('paid');

CREATE TABLE orders_status_shipped PARTITION OF orders_by_status
    FOR VALUES IN ('shipped');

CREATE TABLE orders_status_delivered PARTITION OF orders_by_status
    FOR VALUES IN ('delivered');

CREATE TABLE orders_status_cancelled PARTITION OF orders_by_status
    FOR VALUES IN ('cancelled');

CREATE TABLE orders_status_default PARTITION OF orders_by_status
    DEFAULT;

-- Query specific status (uses correct partition)
SELECT * FROM orders_by_status WHERE status = 'pending';
```

---

## C.3 Advanced Indexing Techniques

### Target
Master advanced indexing strategies for complex query patterns.

### Concept
Beyond basic B-tree indexes, PostgreSQL offers specialized index types for specific use cases. Choosing the right index can dramatically improve query performance.

---

## C.3.1 Partial Indexes

```sql
-- Index only active users (common query pattern)
CREATE INDEX idx_users_active_email ON users(email) 
WHERE is_active = true;

-- Query using the partial index
SELECT * FROM users WHERE is_active = true AND email = 'user@example.com';

-- Index only expensive products (> $100)
CREATE INDEX idx_products_expensive ON products(price) 
WHERE price > 100;

-- Index only low stock products
CREATE INDEX idx_products_low_stock ON products(stock_quantity) 
WHERE stock_quantity < 10;

-- Show index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes 
WHERE indexname LIKE 'idx_products_%';
```

---

## C.3.2 Expression Indexes

```sql
-- Index on computed value
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- Query uses index
SELECT * FROM users WHERE LOWER(email) = 'admin@example.com';

-- Index on date part (faster date queries)
CREATE INDEX idx_orders_created_date ON orders(DATE(created_at));

-- Index on JSONB expression
CREATE INDEX idx_products_metadata_eco_friendly 
ON products ((metadata->>'eco_friendly')) 
WHERE (metadata->>'eco_friendly')::boolean = true;

-- Index on concatenated fields (for search)
CREATE INDEX idx_products_name_description 
ON products ((name || ' ' || COALESCE(description, '')));

-- Index on extracted JSONB array
CREATE INDEX idx_products_variant_colors 
ON products USING GIN ((variants::TEXT));

-- Query uses expression index
SELECT * FROM products 
WHERE metadata->>'eco_friendly' = 'true';
```

---

## C.3.3 Covering Indexes (Index-Only Scans)

```sql
-- Include additional columns in index
CREATE INDEX idx_orders_user_amount 
ON orders(user_id) 
INCLUDE (total, status, created_at);

-- Query can use index-only scan
-- All data needed is in the index
EXPLAIN ANALYZE
SELECT user_id, total, status, created_at
FROM orders
WHERE user_id = 'some-uuid';

-- Include columns for JOIN elimination
CREATE INDEX idx_order_items_order_product 
ON order_items(order_id, product_id) 
INCLUDE (quantity, unit_price, total_price);

-- Query can avoid accessing the table
EXPLAIN ANALYZE
SELECT order_id, product_id, quantity, unit_price
FROM order_items
WHERE order_id = 'some-uuid';
```

---

## C.3.4 BRIN Indexes (Block Range Indexes)

```sql
-- BRIN index for large, naturally ordered tables
CREATE INDEX idx_orders_created_at_brin 
ON orders USING brin(created_at);

-- BRIN is smaller and faster to maintain
SELECT 
    pg_size_pretty(pg_relation_size('idx_orders_created_at_brin')) AS brin_size,
    pg_size_pretty(pg_relation_size('idx_orders_created_at')) AS btree_size;

-- Best for tables with natural ordering
CREATE INDEX idx_products_id_brin ON products USING brin(id);

-- BRIN with pages per range
CREATE INDEX idx_orders_created_at_brin_pages 
ON orders USING brin(created_at) WITH (pages_per_range = 128);
```

---

## C.3.5 GIN Indexes (Generalized Inverted Index)

```sql
-- GIN index for JSONB
CREATE INDEX idx_products_metadata_gin 
ON products USING gin(metadata);

-- GIN index for arrays
ALTER TABLE products ADD COLUMN tags TEXT[];
CREATE INDEX idx_products_tags ON products USING gin(tags);

-- GIN index for full-text search
CREATE INDEX idx_products_search_vector_gin 
ON products USING gin(search_vector);

-- GIN index for trigram search
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_products_name_trgm 
ON products USING gin(name gin_trgm_ops);

-- Fast ILIKE queries
SELECT * FROM products WHERE name ILIKE '%wireless%';
```

---

## C.4 Essential Extensions

### Target
Explore and install essential PostgreSQL extensions for production applications.

### Concept
Extensions add powerful capabilities to PostgreSQL. This section covers the most useful extensions for e-commerce applications.

---

## C.4.1 pg_trgm (Trigram Search)

```sql
-- Install extension
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create trigram indexes
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_description_trgm ON products USING gin(description gin_trgm_ops);

-- Similarity search (fuzzy matching)
SELECT 
    name,
    SIMILARITY(name, 'wireless headphone') AS similarity
FROM products
WHERE name % 'wireless headphone'  -- 70% or more similar
ORDER BY similarity DESC;

-- Word similarity
SELECT 
    name,
    WORD_SIMILARITY(name, 'wireless headphone') AS word_similarity
FROM products
WHERE name <% 'wireless headphone'  -- 70% or more similar
ORDER BY word_similarity DESC;

-- Combined with full-text search
SELECT 
    name,
    SIMILARITY(name, 'wireless headphones') AS similarity,
    TS_RANK(search_vector, TO_TSQUERY('english', 'wireless & headphones')) AS relevance
FROM products
WHERE name % 'wireless headphones'
   OR search_vector @@ TO_TSQUERY('english', 'wireless & headphones')
ORDER BY similarity DESC, relevance DESC
LIMIT 10;
```

---

## C.4.2 pgcrypto (Cryptographic Functions)

```sql
-- Install extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Password hashing (bcrypt)
CREATE OR REPLACE FUNCTION hash_password(p_password TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN crypt(p_password, gen_salt('bf', 10));
END;
$$ LANGUAGE plpgsql;

-- 2. Hash comparison
CREATE OR REPLACE FUNCTION check_password(
    p_password TEXT,
    p_hash TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN p_hash = crypt(p_password, p_hash);
END;
$$ LANGUAGE plpgsql;

-- 3. Encrypt sensitive data
-- Add encrypted columns
ALTER TABLE users ADD COLUMN ssn_encrypted BYTEA;

-- Encrypt with symmetric key
UPDATE users 
SET ssn_encrypted = pgp_sym_encrypt('123-45-6789', 'my_secret_key');

-- Decrypt
SELECT 
    id,
    email,
    pgp_sym_decrypt(ssn_encrypted, 'my_secret_key') AS ssn
FROM users
WHERE ssn_encrypted IS NOT NULL;

-- 4. Generate random values
SELECT 
    gen_random_uuid() AS random_uuid,
    gen_random_bytes(16) AS random_bytes;

-- 5. Password verification function
CREATE OR REPLACE FUNCTION verify_user_password(
    p_email TEXT,
    p_password TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_hash TEXT;
BEGIN
    SELECT password_hash INTO v_hash
    FROM users
    WHERE email = p_email;
    
    IF v_hash IS NULL THEN
        RETURN FALSE;
    END IF;
    
    RETURN check_password(p_password, v_hash);
END;
$$ LANGUAGE plpgsql;

-- Test password verification
SELECT verify_user_password('admin@example.com', 'password123');
```

---

## C.4.3 pg_stat_statements (Query Monitoring)

```sql
-- Install extension
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top queries by total time
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time,
    rows,
    100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0) AS cache_hit_ratio
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Most frequently called queries
SELECT 
    query,
    calls,
    total_time,
    mean_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- Queries with high average execution time
SELECT 
    query,
    calls,
    mean_time,
    total_time,
    rows
FROM pg_stat_statements
WHERE mean_time > 100  -- > 100ms
ORDER BY mean_time DESC
LIMIT 10;

-- Queries with low cache hit ratio (I/O intensive)
SELECT 
    query,
    calls,
    100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0) AS cache_hit_pct,
    total_time
FROM pg_stat_statements
WHERE 100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0) < 50
ORDER BY total_time DESC
LIMIT 10;

-- Reset statistics
SELECT pg_stat_statements_reset();

-- Create a view for easy monitoring
CREATE VIEW query_performance_view AS
SELECT 
    query,
    calls,
    ROUND(total_time / NULLIF(calls, 0)::NUMERIC, 2) AS avg_time_ms,
    ROUND(total_time::NUMERIC, 2) AS total_time_ms,
    rows,
    ROUND(100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0), 2) AS cache_hit_pct
FROM pg_stat_statements
WHERE calls > 10  -- Filter out infrequent queries
ORDER BY total_time DESC;
```

---

## C.4.4 pg_repack (Table Reorganization)

```sql
-- Install pg_repack (requires superuser or installation)
-- apt install postgresql-16-repack (on Ubuntu)
-- brew install pg_repack (on macOS)

-- Reorganize table without exclusive lock
-- pg_repack -d ecommerce -t orders

-- Reorganize all tables
-- pg_repack -d ecommerce

-- Show bloat before repack
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## C.4.5 btree_gist (Exclusion Constraints)

```sql
-- Install extension
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Create table with exclusion constraint (prevent overlapping intervals)
CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    EXCLUDE USING gist (
        product_id WITH =,
        tstzrange(start_time, end_time) WITH &&
    )
);

-- This prevents double-booking
INSERT INTO reservations (user_id, product_id, start_time, end_time)
VALUES (
    (SELECT id FROM users LIMIT 1),
    1,
    '2024-01-01 10:00:00',
    '2024-01-01 12:00:00'
);

-- This will fail (overlapping reservation)
INSERT INTO reservations (user_id, product_id, start_time, end_time)
VALUES (
    (SELECT id FROM users LIMIT 1),
    1,
    '2024-01-01 11:00:00',
    '2024-01-01 13:00:00'
);

-- Exclusion constraint for inventory
CREATE TABLE inventory_reservations (
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    reserved_until TIMESTAMPTZ,
    EXCLUDE USING gist (
        product_id WITH =,
        tstzrange(NOW(), reserved_until) WITH &&
    )
);
```

---

## C.5 Advanced Monitoring Queries

### Target
Build comprehensive monitoring dashboards for your PostgreSQL database.

### Concept
Monitoring is essential for maintaining a healthy database. This section provides advanced queries to monitor performance, health, and usage.

---

## C.5.1 Database Health Check

```sql
-- 1. Database health dashboard
SELECT 
    'Database Health' AS dashboard,
    NOW() AS checked_at,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction') AS idle_in_transaction,
    (SELECT ROUND(AVG(EXTRACT(EPOCH FROM (NOW() - query_start)))::NUMERIC, 2) 
     FROM pg_stat_activity WHERE state = 'active') AS avg_query_seconds,
    (SELECT COUNT(*) FROM pg_locks WHERE NOT granted) AS blocked_queries;

-- 2. Table bloat report
WITH bloat AS (
    SELECT 
        schemaname,
        tablename,
        pg_total_relation_size(schemaname||'.'||tablename) AS total_bytes,
        pg_relation_size(schemaname||'.'||tablename) AS table_bytes,
        pg_total_relation_size(schemaname||'.'||tablename) - 
        pg_relation_size(schemaname||'.'||tablename) AS index_bytes,
        ROUND(100 * (pg_total_relation_size(schemaname||'.'||tablename) - 
              pg_relation_size(schemaname||'.'||tablename)) / 
              NULLIF(pg_total_relation_size(schemaname||'.'||tablename), 0), 2) AS bloat_pct
    FROM pg_tables
    WHERE schemaname = 'public'
)
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(total_bytes) AS total_size,
    pg_size_pretty(table_bytes) AS table_size,
    pg_size_pretty(index_bytes) AS index_size,
    bloat_pct
FROM bloat
WHERE bloat_pct > 20  -- Significant bloat
ORDER BY total_bytes DESC;

-- 3. Index usage report
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched,
    CASE 
        WHEN idx_scan = 0 THEN 'Never Used'
        WHEN idx_scan < 100 THEN 'Rarely Used'
        ELSE 'Used'
    END AS usage_status
FROM pg_stat_user_indexes
ORDER BY idx_scan;

-- 4. Cache hit ratio
SELECT 
    'Cache Hit Ratio' AS metric,
    ROUND(100 * SUM(heap_blks_hit) / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0), 2) AS hit_ratio_pct,
    SUM(heap_blks_hit) AS cache_hits,
    SUM(heap_blks_read) AS cache_misses,
    SUM(heap_blks_hit) + SUM(heap_blks_read) AS total_reads
FROM pg_statio_user_tables;

-- 5. Long-running queries
SELECT 
    pid,
    usename AS user,
    application_name,
    client_addr,
    state,
    NOW() - query_start AS duration,
    query
FROM pg_stat_activity
WHERE state != 'idle'
  AND (NOW() - query_start) > INTERVAL '5 minutes'
ORDER BY duration DESC;
```

---

## C.6 Troubleshooting Advanced Issues

### Target
Diagnose and resolve advanced PostgreSQL issues.

### Concept
When things go wrong, systematic troubleshooting is essential. This section covers advanced diagnostics and solutions.

---

## C.6.1 Deadlocks

```sql
-- 1. Detect deadlocks
SELECT 
    pid,
    usename,
    state,
    query,
    NOW() - query_start AS duration
FROM pg_stat_activity
WHERE state = 'active'
  AND query LIKE '%deadlock%';

-- 2. Check lock conflicts
SELECT 
    blocked.pid AS blocked_pid,
    blocked.usename AS blocked_user,
    blocked.query AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking.usename AS blocking_user,
    blocking.query AS blocking_query
FROM pg_stat_activity blocked
JOIN pg_locks blocked_locks ON blocked_locks.pid = blocked.pid
JOIN pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
  AND blocking_locks.relation = blocked_locks.relation
  AND blocking_locks.pid != blocked_locks.pid
JOIN pg_stat_activity blocking ON blocking.pid = blocking_locks.pid
WHERE blocked_locks.granted = false
  AND blocked_locks.locktype = 'relation';

-- 3. Cancel a blocking query
SELECT pg_cancel_backend(pid)
FROM pg_stat_activity
WHERE pid = <blocking_pid>;

-- 4. Terminate a blocking query (more aggressive)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE pid = <blocking_pid>;

-- 5. Set deadlock timeout
SET deadlock_timeout = '1s';  -- 1 second
-- In postgresql.conf:
-- deadlock_timeout = 1s
```

---

## C.6.2 Transaction ID Wraparound

```sql
-- 1. Check transaction ID status
SELECT 
    datname,
    age(datfrozenxid) AS age,
    datfrozenxid,
    (SELECT setting FROM pg_settings WHERE name = 'autovacuum_freeze_max_age') AS freeze_max_age
FROM pg_database
WHERE datname = current_database();

-- 2. Check for wraparound risk
SELECT 
    datname,
    age(datfrozenxid) AS txid_age,
    age(datfrozenxid) / (SELECT setting::int FROM pg_settings WHERE name = 'autovacuum_freeze_max_age') AS pct_towards_freeze
FROM pg_database
WHERE age(datfrozenxid) > (SELECT setting::int * 0.8 FROM pg_settings WHERE name = 'autovacuum_freeze_max_age')
ORDER BY age DESC;

-- 3. Force vacuum freeze
VACUUM FREEZE;

-- 4. Configure auto-vacuum for freeze
ALTER TABLE orders SET (autovacuum_freeze_min_age = 50000000);
ALTER TABLE orders SET (autovacuum_freeze_table_age = 100000000);
```

---

## C.6.3 Recovery from Corruption

```sql
-- 1. Check for corruption
SELECT * FROM pg_verify_checksums();

-- 2. Rebuild indexes
REINDEX DATABASE ecommerce;

-- 3. Rebuild specific index
REINDEX INDEX idx_products_search_vector;

-- 4. Rebuild table (requires exclusive lock)
-- VACUUM FULL orders;

-- 5. Data recovery from WAL
-- Use pg_waldump to inspect WAL
-- pg_waldump /var/lib/postgresql/16/pg_wal/000000010000000000000001

-- 6. Recovery with pg_resetwal (DANGEROUS!)
-- Only use as last resort
-- pg_resetwal -f /var/lib/postgresql/16/main
```

---

## C.7 Summary

You've explored advanced PostgreSQL features that can take your e-commerce application to the next level:

✅ Full-text search with ranking and highlighting  
✅ Table partitioning for large datasets  
✅ Advanced indexing (partial, expression, covering, BRIN, GIN)  
✅ Essential extensions (pg_trgm, pgcrypto, pg_stat_statements, pg_repack)  
✅ Advanced monitoring and troubleshooting  
✅ Deadlock detection and resolution  
✅ Transaction ID wraparound prevention  

These advanced features will help you build scalable, high-performance, and maintainable database applications.
