# Part 2 — SQL Performance & Advanced Database Optimization

## Understand What the Database Engine Is Really Doing

---

### Introduction to Part 2

Welcome to the performance phase of our journey. In Part 1, we built a clean, normalized schema for ScaleCart that enforces data integrity. Now we need to make it **fast**—fast enough to handle millions of products, thousands of concurrent users, and complex analytical queries.

In this part, we will:

1. **Peek inside the query optimizer** – Understand how PostgreSQL decides to execute your SQL.
2. **Master advanced indexing strategies** – Go beyond basic B‑Trees to GiST, GIN, BRIN, and full‑text indexes.
3. **Balance read and write performance** – Learn the hidden costs of indexes and how to design for mixed workloads.
4. **Scale large datasets** – Implement table partitioning, sharding strategies, and data archiving.

By the end, your ScaleCart database will handle **100 million records** with sub‑second response times for critical queries.

**Estimated time:** 6‑8 hours.

Let's begin.

---

## Section 2.1 – Inside the Query Optimizer

### 2.1.1 The Target

We will learn how PostgreSQL's query planner works, how to read execution plans using `EXPLAIN ANALYZE`, and how to identify performance bottlenecks.

### 2.1.2 The Concept – The Database's Decision Engine

**Analogy:** Think of the query optimizer as a GPS navigation system. You give it a destination (your SQL query), and it considers multiple routes (execution plans). It estimates traffic, road conditions, and distance (statistics and costs) to pick the fastest route. Sometimes it makes mistakes if its maps are outdated (stale statistics).

**Terminology:**
- **Execution plan** – The step‑by‑step sequence of operations the database performs to return your query results.
- **Cost** – A unitless number representing estimated I/O and CPU resources. Lower cost = faster plan.
- **Seq Scan** – Reading every row of a table sequentially. Good for small tables, bad for large ones.
- **Index Scan** – Using an index to find rows quickly. Good for selective queries.
- **Bitmap Heap Scan** – A combination: reads index to build a bitmap of matching pages, then fetches those pages.
- **Nested Loop Join** – For each row in the outer table, scan the inner table for matches. Good for small outer sets.
- **Hash Join** – Builds a hash table of one table, then probes it. Good for larger joins.
- **Merge Join** – Sorts both tables and merges. Good for pre‑sorted data.

### 2.1.3 Generating Realistic Test Data

Before we can analyze performance, we need data. We'll write a Python script to generate millions of rows.

**File:** `src/scripts/generate_test_data.py`

```python
# File: src/scripts/generate_test_data.py
"""
Generates synthetic data for performance testing.
Run after schema is created.
"""

import os
import random
import psycopg2
from psycopg2 import sql
from faker import Faker  # pip install faker
import time
from datetime import datetime, timedelta

fake = Faker()

# Configuration
NUM_PRODUCTS = 1000000      # 1 million products
NUM_CUSTOMERS = 500000      # 500k customers
NUM_ORDERS = 2000000        # 2 million orders
NUM_ORDER_ITEMS = 5000000   # 5 million order items
NUM_REVIEWS = 3000000       # 3 million reviews

BATCH_SIZE = 10000

def generate_categories(conn):
    """Create a hierarchy of 100 categories."""
    cur = conn.cursor()
    categories = []
    # Top-level categories
    for i in range(10):
        name = fake.word().capitalize() + " Category"
        cur.execute(
            "INSERT INTO categories (name) VALUES (%s) RETURNING id",
            (name,)
        )
        parent_id = cur.fetchone()[0]
        categories.append(parent_id)
        # Sub-categories
        for j in range(10):
            sub_name = fake.word().capitalize() + " Subcategory"
            cur.execute(
                "INSERT INTO categories (name, parent_category_id) VALUES (%s, %s) RETURNING id",
                (sub_name, parent_id)
            )
            categories.append(cur.fetchone()[0])
    conn.commit()
    cur.close()
    return categories

def generate_products(conn, category_ids):
    """Insert NUM_PRODUCTS products."""
    cur = conn.cursor()
    print(f"Generating {NUM_PRODUCTS} products...")
    start = time.time()
    
    for i in range(0, NUM_PRODUCTS, BATCH_SIZE):
        batch = []
        for _ in range(min(BATCH_SIZE, NUM_PRODUCTS - i)):
            name = fake.catch_phrase()
            description = fake.text(max_nb_chars=200)
            price = round(random.uniform(5.0, 5000.0), 2)
            category_id = random.choice(category_ids)
            batch.append((name, description, price, category_id))
        
        cur.executemany(
            "INSERT INTO products (name, description, price, category_id) VALUES (%s, %s, %s, %s)",
            batch
        )
        conn.commit()
        print(f"  Inserted {min(i + BATCH_SIZE, NUM_PRODUCTS)} products")
    
    cur.close()
    print(f"Products generated in {time.time() - start:.2f} seconds")

def generate_suppliers(conn):
    """Insert 1000 suppliers."""
    cur = conn.cursor()
    suppliers = []
    for _ in range(1000):
        name = fake.company()
        email = fake.email()
        phone = fake.phone_number()
        address = fake.address().replace("\n", ", ")
        cur.execute(
            "INSERT INTO suppliers (name, contact_email, phone, address) VALUES (%s, %s, %s, %s) RETURNING id",
            (name, email, phone, address)
        )
        suppliers.append(cur.fetchone()[0])
    conn.commit()
    cur.close()
    return suppliers

def generate_supplier_products(conn, supplier_ids, product_count):
    """Link each product to 1-3 suppliers."""
    cur = conn.cursor()
    print("Generating supplier-product links...")
    start = time.time()
    
    # Get all product IDs
    cur.execute("SELECT id FROM products")
    product_ids = [row[0] for row in cur.fetchall()]
    
    for product_id in product_ids:
        # Choose 1-3 random suppliers
        num_suppliers = random.randint(1, 3)
        chosen = random.sample(supplier_ids, min(num_suppliers, len(supplier_ids)))
        for supplier_id in chosen:
            supply_price = round(random.uniform(5.0, 4000.0), 2)
            cur.execute(
                "INSERT INTO supplier_products (supplier_id, product_id, supply_price) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING",
                (supplier_id, product_id, supply_price)
            )
    conn.commit()
    cur.close()
    print(f"Supplier links generated in {time.time() - start:.2f} seconds")

def generate_customers(conn):
    """Insert NUM_CUSTOMERS customers."""
    cur = conn.cursor()
    print(f"Generating {NUM_CUSTOMERS} customers...")
    start = time.time()
    
    for i in range(0, NUM_CUSTOMERS, BATCH_SIZE):
        batch = []
        for _ in range(min(BATCH_SIZE, NUM_CUSTOMERS - i)):
            email = fake.email()
            password = fake.password()
            name = fake.name()
            batch.append((email, password, name))
        
        cur.executemany(
            "INSERT INTO customers (email, password_hash, full_name) VALUES (%s, %s, %s)",
            batch
        )
        conn.commit()
        print(f"  Inserted {min(i + BATCH_SIZE, NUM_CUSTOMERS)} customers")
    
    cur.close()
    print(f"Customers generated in {time.time() - start:.2f} seconds")

def generate_addresses(conn, customer_count):
    """Generate 1-3 addresses per customer."""
    cur = conn.cursor()
    print("Generating addresses...")
    start = time.time()
    
    cur.execute("SELECT id FROM customers")
    customer_ids = [row[0] for row in cur.fetchall()]
    
    for customer_id in customer_ids:
        num_addresses = random.randint(1, 3)
        for i in range(num_addresses):
            street = fake.street_address()
            city = fake.city()
            state = fake.state_abbr()
            postal = fake.zipcode()
            country = "USA"
            is_default = (i == 0)  # First address is default
            cur.execute(
                "INSERT INTO addresses (customer_id, street, city, state, postal_code, country, is_default_shipping) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (customer_id, street, city, state, postal, country, is_default)
            )
    conn.commit()
    cur.close()
    print(f"Addresses generated in {time.time() - start:.2f} seconds")

def generate_orders_and_items(conn, product_ids, customer_ids):
    """Generate orders and items."""
    cur = conn.cursor()
    print(f"Generating {NUM_ORDERS} orders...")
    start = time.time()
    
    statuses = ['pending', 'paid', 'shipped', 'delivered', 'cancelled']
    
    for i in range(0, NUM_ORDERS, BATCH_SIZE):
        order_batch = []
        item_batch = []
        
        for _ in range(min(BATCH_SIZE, NUM_ORDERS - i)):
            customer_id = random.choice(customer_ids)
            status = random.choices(statuses, weights=[0.1, 0.3, 0.3, 0.25, 0.05])[0]
            order_date = fake.date_time_between(start_date='-1y', end_date='now')
            
            # Generate 1-5 items per order
            num_items = random.randint(1, 5)
            items = []
            total = 0.0
            for _ in range(num_items):
                product_id = random.choice(product_ids)
                quantity = random.randint(1, 3)
                # Get a random price (we'll just use a random value for demo)
                unit_price = round(random.uniform(5.0, 2000.0), 2)
                subtotal = quantity * unit_price
                total += subtotal
                items.append((product_id, quantity, unit_price, subtotal))
            
            # Insert order
            cur.execute(
                "INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES (%s, %s, %s, %s) RETURNING id",
                (customer_id, order_date, status, round(total, 2))
            )
            order_id = cur.fetchone()[0]
            
            # Insert items (we'll batch them later)
            for product_id, qty, unit_price, subtotal in items:
                item_batch.append((order_id, product_id, qty, unit_price))
        
        # Batch insert items
        if item_batch:
            cur.executemany(
                "INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (%s, %s, %s, %s)",
                item_batch
            )
        
        conn.commit()
        print(f"  Inserted {min(i + BATCH_SIZE, NUM_ORDERS)} orders")
    
    cur.close()
    print(f"Orders generated in {time.time() - start:.2f} seconds")

def generate_inventory(conn, product_ids):
    """Insert inventory for all products."""
    cur = conn.cursor()
    print("Generating inventory...")
    start = time.time()
    
    for product_id in product_ids:
        stock = random.randint(0, 1000)
        threshold = random.randint(5, 100)
        cur.execute(
            "INSERT INTO inventory (product_id, stock_quantity, reorder_threshold) VALUES (%s, %s, %s)",
            (product_id, stock, threshold)
        )
    conn.commit()
    cur.close()
    print(f"Inventory generated in {time.time() - start:.2f} seconds")

def main():
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        user="scalecart",
        password="scalecart_password",
        dbname="scalecart"
    )
    conn.autocommit = False
    
    # 1. Categories
    print("1. Generating categories...")
    category_ids = generate_categories(conn)
    
    # 2. Products
    print("2. Generating products...")
    generate_products(conn, category_ids)
    
    # 3. Get product IDs for later
    cur = conn.cursor()
    cur.execute("SELECT id FROM products")
    product_ids = [row[0] for row in cur.fetchall()]
    cur.close()
    
    # 4. Suppliers
    print("3. Generating suppliers...")
    supplier_ids = generate_suppliers(conn)
    
    # 5. Supplier products
    print("4. Generating supplier-product links...")
    generate_supplier_products(conn, supplier_ids, len(product_ids))
    
    # 6. Customers
    print("5. Generating customers...")
    generate_customers(conn)
    
    # 7. Get customer IDs
    cur = conn.cursor()
    cur.execute("SELECT id FROM customers")
    customer_ids = [row[0] for row in cur.fetchall()]
    cur.close()
    
    # 8. Addresses
    print("6. Generating addresses...")
    generate_addresses(conn, len(customer_ids))
    
    # 9. Orders and items
    print("7. Generating orders and items...")
    generate_orders_and_items(conn, product_ids, customer_ids)
    
    # 10. Inventory
    print("8. Generating inventory...")
    generate_inventory(conn, product_ids)
    
    conn.close()
    print("Data generation complete!")

if __name__ == "__main__":
    main()
```

**Run the generator:**

```bash
pip install faker psycopg2-binary
python src/scripts/generate_test_data.py
```

**Note:** This will take time (possibly hours) for 100 million records. You can adjust the constants to generate smaller datasets for learning (e.g., 100k products).

### 2.1.4 Reading Execution Plans with EXPLAIN ANALYZE

Now we have data. Let's analyze a query.

**Query:** Find all orders for customer #42 with their total amount and status.

```sql
EXPLAIN ANALYZE
SELECT id, order_date, status, total_amount
FROM orders
WHERE customer_id = 42;
```

**Execute and observe output:**

```
Seq Scan on orders  (cost=0.00..50000.00 rows=1000 width=48) (actual time=0.123..123.456 rows=150 loops=1)
  Filter: (customer_id = 42)
  Rows Removed by Filter: 1999850
Planning Time: 0.234 ms
Execution Time: 123.789 ms
```

**Interpretation:**
- **Seq Scan** – Reading all 2 million rows. Cost: 0..50000 (estimated). Actual time: 123 ms.
- **Filter** – Checking each row for customer_id = 42.
- **Rows Removed** – 1,999,850 rows didn't match.

**Problem:** This scans the entire table. We need an index on `customer_id`.

### 2.1.5 Adding an Index and Re‑analyzing

```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
ANALYZE orders;  -- Update statistics
```

Now run `EXPLAIN ANALYZE` again:

```
Bitmap Heap Scan on orders  (cost=4.50..100.00 rows=50 width=48) (actual time=0.123..0.234 rows=150 loops=1)
  Recheck Cond: (customer_id = 42)
  ->  Bitmap Index Scan on idx_orders_customer_id  (cost=0.00..4.50 rows=50 width=0) (actual time=0.100..0.100 rows=150 loops=1)
        Index Cond: (customer_id = 42)
Planning Time: 0.156 ms
Execution Time: 0.289 ms
```

**Improvement:** Execution time dropped from 123ms to 0.3ms – a 400x speedup.

### 2.1.6 Understanding Cost Estimates

PostgreSQL uses statistics to estimate:
- **Rows** – Estimated rows returned (based on `n_distinct` and `most_common_vals`).
- **Cost** – Units: sequential page read = 1.0, random page read = 4.0, CPU cost = 0.01 per row.

You can view statistics:

```sql
SELECT relname, reltuples, relpages FROM pg_class WHERE relname = 'orders';
```

Update statistics with `ANALYZE` after large data changes.

### 2.1.7 Common Plan Types

**Nested Loop Join:** Good when outer table is small.

```sql
EXPLAIN ANALYZE
SELECT c.full_name, o.id
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE c.id = 42;
```

**Hash Join:** Good for larger tables.

```sql
EXPLAIN ANALYZE
SELECT c.full_name, SUM(o.total_amount)
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id;
```

**Merge Join:** Used when both inputs are sorted (e.g., on indexed columns).

### 2.1.8 Verification – Your Turn

Run `EXPLAIN ANALYZE` on these queries and interpret the plans:

```sql
-- Query 1
SELECT * FROM products WHERE price < 100 AND price > 50;

-- Query 2
SELECT p.name, AVG(r.rating)
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id
HAVING AVG(r.rating) > 4.0;

-- Query 3
SELECT * FROM orders WHERE order_date > '2025-01-01';
```

Note the plan types, costs, and identify missing indexes.

---

## Section 2.2 – Advanced Indexing Strategies

### 2.2.1 The Target

We'll go beyond simple B‑Tree indexes to implement specialized indexes for different workloads: full‑text search, geospatial, array operations, and partial indexes.

### 2.2.2 The Concept – Index Types as Tools

**Analogy:** If a B‑Tree index is like a book's index (alphabetical), other index types are like specialized reference tools:
- **GiST (Generalized Search Tree)** – For geometric data, full‑text search, and nearest‑neighbor queries.
- **GIN (Generalized Inverted Index)** – For arrays, JSONB, and full‑text search (inverted index).
- **BRIN (Block Range INdex)** – For very large tables with natural ordering (e.g., timestamp columns).
- **Hash** – For equality comparisons only (faster than B‑Tree for exact matches).

**PostgreSQL supports:**
- B‑Tree (default) – equality and range.
- Hash – equality only.
- GiST – geometric, full‑text, nearest neighbor.
- GIN – arrays, JSONB, full‑text (inverted).
- BRIN – block‑range indexes for large, ordered tables.
- Full‑Text – specialized for natural language search.

### 2.2.3 Implementing Full‑Text Search

We want users to search products by name and description.

**Step 1:** Create a `tsvector` column for pre‑computed search tokens.

```sql
ALTER TABLE products ADD COLUMN search_vector TSVECTOR;
UPDATE products SET search_vector = 
    setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'B');

CREATE INDEX idx_products_search ON products USING GIN (search_vector);
```

**Step 2:** Query using `tsquery`.

```sql
EXPLAIN ANALYZE
SELECT name, description
FROM products
WHERE search_vector @@ to_tsquery('english', 'laptop & high-performance');
```

**Step 3:** Auto‑update with a trigger.

```sql
CREATE OR REPLACE FUNCTION products_search_update() RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_products_search_update BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION products_search_update();
```

### 2.2.4 GiST for Geospatial (Not Used in ScaleCart, But Example)

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geom GEOMETRY(Point, 4326)
);

CREATE INDEX idx_locations_geom ON locations USING GiST (geom);

-- Query: Find points within 10km of (lat, lon)
SELECT name FROM locations
WHERE ST_DWithin(geom, ST_SetSRID(ST_MakePoint(-122.4, 37.8), 4326), 10000);
```

### 2.2.5 BRIN for Time‑Series Data

If we had billions of orders and frequently filtered by `order_date`, BRIN can be efficient.

```sql
CREATE INDEX idx_orders_order_date_brin ON orders USING BRIN (order_date);

-- Works well when order_date is correlated with physical storage
-- Use with large tables where scans over ranges are common.
```

### 2.2.6 Partial Indexes

Index only a subset of rows to save space.

```sql
-- Index only "active" orders (not cancelled)
CREATE INDEX idx_orders_active ON orders (customer_id)
WHERE status != 'cancelled';

-- This index is smaller and faster for queries that include this condition.
SELECT * FROM orders WHERE status != 'cancelled' AND customer_id = 42;
```

### 2.2.7 Expression Indexes

Index the result of an expression.

```sql
-- Index on lowercased email for case‑insensitive search
CREATE INDEX idx_customers_email_lower ON customers (LOWER(email));

SELECT * FROM customers WHERE LOWER(email) = LOWER('Alice@example.com');
```

### 2.2.8 Composite and Covering Indexes

**Composite Index:** Index multiple columns together.

```sql
CREATE INDEX idx_orders_customer_status ON orders (customer_id, status);

-- This supports:
WHERE customer_id = 42 AND status = 'paid';
WHERE customer_id = 42;  -- also uses first column
```

**Covering Index (INCLUDE):** Include extra columns to avoid reading table.

```sql
CREATE INDEX idx_orders_covering ON orders (customer_id) INCLUDE (total_amount, status);

-- Query can use index‑only scan:
SELECT customer_id, total_amount, status FROM orders WHERE customer_id = 42;
-- No heap access needed.
```

### 2.2.9 Index Maintenance

Indexes add overhead on `INSERT`, `UPDATE`, `DELETE`. Monitor:

```sql
-- Index size
SELECT relname, pg_size_pretty(pg_relation_size(relid)) as size
FROM pg_stat_user_indexes
WHERE relname = 'orders';

-- Index usage
SELECT relname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE relname = 'orders';
```

**When to drop indexes:**
- Low usage (idx_scan = 0)
- High write load and index not critical

### 2.2.10 Verification – Experiment with Indexes

1. Create a full‑text index on products and test search performance.
2. Create a composite index on `order_items (order_id, product_id)` and compare query plans.
3. Create a partial index on `orders` for active orders and test.
4. Measure index sizes and usage.

---

## Section 2.3 – Balancing Read and Write Performance

### 2.3.1 The Target

We'll understand the cost of indexes on writes and learn to design for mixed OLTP workloads where reads and writes are balanced.

### 2.3.2 The Concept – The Index Tax

Every index you add speeds up reads but slows down writes. Each `INSERT` must update every index; each `UPDATE` may cause index modifications. This is called **write amplification**.

**Trade‑off:**
- Read‑heavy: add many indexes (catalog, search).
- Write‑heavy: minimize indexes (logging, event ingestion).

**Strategies:**
- Create indexes only on queried columns.
- Use partial indexes to reduce index size.
- Use BRIN for very large, append‑only tables.
- Use covering indexes to avoid heap access.

### 2.3.3 Measuring Write Overhead

**Test:** Insert 100,000 rows with and without indexes.

**Without indexes (only primary key):**

```sql
-- Dropping indexes except PK
DROP INDEX idx_orders_customer_id;
DROP INDEX idx_orders_order_date;

-- Measure insert time
INSERT INTO orders (customer_id, status, total_amount)
SELECT 
    random() * 500000,
    'pending',
    random() * 1000
FROM generate_series(1, 100000);
```

**With all indexes:** Compare time.

### 2.3.4 Bulk Loading Techniques

**For large imports:**
- Drop indexes, load data, re‑create indexes (faster than maintaining indexes row‑by‑row).
- Use `COPY` instead of `INSERT`.
- Increase `maintenance_work_mem` for index creation.
- Use `UNLOGGED` tables (no WAL) for staging data.

### 2.3.5 Vacuum and Autovacuum

PostgreSQL doesn't reclaim space immediately after updates/deletes. `VACUUM` reclaims dead tuples.

**Monitor table bloat:**

```sql
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
       n_dead_tup, n_live_tup
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000;
```

**Tune autovacuum:**
- Set `autovacuum_vacuum_scale_factor = 0.1` (default 0.2) for aggressive cleanup.
- Set `autovacuum_analyze_threshold` lower for frequently updated tables.

### 2.3.6 Verification – Write Performance Test

1. Create a test table with 1 million rows and a few indexes.
2. Measure time for 10,000 updates.
3. Drop an index and measure again.
4. Observe the difference.

---

## Section 2.4 – Scaling Large Datasets

### 2.4.1 The Target

We'll implement **table partitioning** for orders and products, and discuss **sharding** and **archiving**.

### 2.4.2 The Concept – Divide and Conquer

When tables grow beyond tens of millions, partitioning splits them into smaller, more manageable pieces.

**Types:**
- **Range Partitioning** – By date or numeric range.
- **List Partitioning** – By discrete values (e.g., region).
- **Hash Partitioning** – Even distribution (for sharding).

**Benefits:**
- Faster queries (partition pruning).
- Easier data lifecycle management (drop old partitions).
- Parallel scans (multiple partitions scanned concurrently).

### 2.4.3 Partitioning Orders by Date

We'll partition `orders` by `order_date` monthly.

**Step 1:** Create a partitioned table.

```sql
-- Drop existing order_items FK first (cascade)
-- We need to recreate orders as partitioned, so we'll migrate.
-- For production, we'd use a migration strategy.

CREATE TABLE orders_partitioned (
    id SERIAL,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id, order_date)  -- partition key must be part of PK
) PARTITION BY RANGE (order_date);

-- Create partitions for 2024 and 2025
CREATE TABLE orders_2024 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Add FK to customers (can't have FK from partitioned table to non‑partitioned easily)
-- We'll handle this in application logic.
```

**Step 2:** Migrate data (carefully).

```sql
INSERT INTO orders_partitioned (id, customer_id, order_date, status, total_amount)
SELECT id, customer_id, order_date, status, total_amount
FROM orders;
```

**Step 3:** Create indexes on each partition.

```sql
CREATE INDEX idx_orders_2024_customer_id ON orders_2024(customer_id);
CREATE INDEX idx_orders_2025_customer_id ON orders_2025(customer_id);
```

### 2.4.4 Partitioning Products by ID Range (Hash)

For `products`, we might partition by `id` modulo to distribute load.

```sql
CREATE TABLE products_partitioned (
    id SERIAL,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    category_id INTEGER NOT NULL,
    PRIMARY KEY (id)
) PARTITION BY HASH (id);

CREATE TABLE products_0 PARTITION OF products_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE products_1 PARTITION OF products_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE products_2 PARTITION OF products_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE products_3 PARTITION OF products_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

### 2.4.5 Sharding vs. Partitioning

- **Partitioning** – Within one database instance. Good for manageability, not scaling writes beyond single server capacity.
- **Sharding** – Distribute data across multiple database servers. Complex but horizontal scaling.

**Sharding strategies:**
- **Range sharding** – By user ID range.
- **Hash sharding** – Even distribution (consistency hashing for resilience).

**ScaleCart could shard by `customer_id`** to keep all orders for a customer on one shard.

### 2.4.6 Archiving Historical Data

**Move old orders to a cold storage table or separate database.**

```sql
-- Create archive table (same structure but without indexes for speed)
CREATE TABLE orders_archive (LIKE orders INCLUDING ALL);

-- Move orders older than 2 years
INSERT INTO orders_archive
SELECT * FROM orders WHERE order_date < '2023-01-01';

DELETE FROM orders WHERE order_date < '2023-01-01';
```

**Automate with partitioning:** Drop old partitions.

```sql
DROP TABLE orders_2023;  -- Will drop all data quickly
```

### 2.4.7 Verification – Partitioning Tests

1. Create partitions for orders and products.
2. Insert test data and observe partition pruning:

```sql
EXPLAIN SELECT * FROM orders_partitioned WHERE order_date BETWEEN '2024-06-01' AND '2024-06-30';
```

3. Check that only the relevant partition is scanned.
4. Measure performance difference for large range queries.

---

## Section 2.5 – Summary and Exercises

### 2.5.1 What We Accomplished

- Explored the query optimizer and learned to read execution plans.
- Implemented advanced indexes: B‑Tree, GIN (full‑text), GiST, BRIN, partial, expression, and covering.
- Understood index maintenance costs and wrote balanced designs.
- Scaled with table partitioning, sharding concepts, and archiving strategies.

Your ScaleCart database can now handle **100 million+ records** with efficient query performance.

### 2.5.2 Exercises

1. **Design indexes for the following queries:**
   - Find products by name (partial match).
   - Find orders for a customer in a date range.
   - Top 10 best‑selling products this month.
   - Average rating per category.

2. **Set up partitioning for `order_items`** by order date (since order_id is sequential). Show the DDL.

3. **Write a script** that generates 10 million orders and uses `EXPLAIN ANALYZE` to measure query performance before and after indexing.

4. **Implement a materialized view** that stores daily sales totals and refresh it nightly.

5. **Simulate a write‑heavy workload** (e.g., logging) and compare performance with and without indexes. Decide when to drop indexes.

### 2.5.3 Next Steps

In **Part 3 – Transactions, Concurrency & Data Integrity**, we will:
- Implement ACID transactions with proper isolation levels.
- Prevent dirty reads, non‑repeatable reads, and phantom reads.
- Use optimistic and pessimistic locking.
- Detect and avoid deadlocks.
- Perform zero‑downtime schema migrations.

**We are ready for Part 3.**
