# Mastering Modern Database Design — Complete Lab Book

## Hands-On Laboratory Exercises with Step-by-Step Instructions

---

## LAB BOOK OVERVIEW

This lab book contains all practical laboratory exercises for the "Mastering Modern Database Design" series. Each lab is self-contained with clear objectives, step-by-step instructions, and verification steps.

**Lab Structure:**
1. **Objective** – What you will learn
2. **Prerequisites** – What you need before starting
3. **Setup** – Preparing your environment
4. **Step-by-Step Instructions** – Detailed lab steps
5. **Verification** – How to confirm success
6. **Cleanup** – Reset the environment

**Estimated Time:** 15-20 hours total

---

## LAB 1: Setting Up Your Database Environment

**Objective:** Set up PostgreSQL and verify your environment is ready for the labs.

**Prerequisites:** Docker installed, Docker Compose installed, Terminal/Command Line access

**Duration:** 30 minutes

---

### 1.1 Setup Instructions

**Step 1: Create Project Directory**

```bash
mkdir ~/scalecart-labs
cd ~/scalecart-labs
```

**Step 2: Create Docker Compose File**

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: scalecart_postgres
    environment:
      POSTGRES_USER: scalecart
      POSTGRES_PASSWORD: scalecart_password
      POSTGRES_DB: scalecart
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U scalecart"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: scalecart_redis
    command: redis-server --requirepass scalecart_password
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

**Step 3: Start Services**

```bash
docker compose up -d
```

**Step 4: Verify Services**

```bash
# Check PostgreSQL
docker compose exec postgres pg_isready -U scalecart

# Check Redis
docker compose exec redis redis-cli -a scalecart_password ping
```

**Expected Output:**
```
postgres:5432 - accepting connections
PONG
```

---

### 1.2 Lab Verification

✅ Docker Compose services are running
✅ PostgreSQL is accepting connections
✅ Redis is responding to ping

---

## LAB 2: Creating Your First Tables

**Objective:** Create a simple database schema using PostgreSQL.

**Prerequisites:** Lab 1 completed

**Duration:** 45 minutes

---

### 2.1 Setup Instructions

**Step 1: Connect to PostgreSQL**

```bash
docker compose exec postgres psql -U scalecart -d scalecart
```

**Step 2: Create Tables**

```sql
-- Create customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    sku VARCHAR(50) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount NUMERIC(10,2) DEFAULT 0,
    CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled'))
);

-- Create order_items table
CREATE TABLE order_items (
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

-- Create inventory table
CREATE TABLE inventory (
    product_id INTEGER PRIMARY KEY REFERENCES products(id),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_threshold INTEGER DEFAULT 10
);
```

**Step 3: Verify Tables**

```sql
\dt

-- Expected output:
--              List of relations
--  Schema |     Name     | Type  |  Owner
-- --------+--------------+-------+----------
--  public | customers    | table | scalecart
--  public | inventory    | table | scalecart
--  public | order_items  | table | scalecart
--  public | orders       | table | scalecart
--  public | products     | table | scalecart
```

**Step 4: Insert Sample Data**

```sql
-- Insert customers
INSERT INTO customers (first_name, last_name, email)
VALUES 
    ('John', 'Doe', 'john@example.com'),
    ('Jane', 'Smith', 'jane@example.com'),
    ('Bob', 'Johnson', 'bob@example.com');

-- Insert products
INSERT INTO products (name, description, price, sku)
VALUES 
    ('Laptop Pro', 'High-performance laptop', 1499.99, 'LP-001'),
    ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 'WM-001'),
    ('USB-C Cable', 'Fast charging cable', 19.99, 'UC-001');

-- Insert inventory
INSERT INTO inventory (product_id, stock_quantity, reorder_threshold)
VALUES
    (1, 50, 10),
    (2, 100, 20),
    (3, 200, 30);

-- Insert orders
INSERT INTO orders (customer_id, status, total_amount)
VALUES 
    (1, 'paid', 1529.98),
    (2, 'pending', 49.98);

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 1, 1499.99),
    (1, 2, 1, 29.99),
    (2, 2, 1, 29.99),
    (2, 3, 1, 19.99);
```

---

### 2.2 Lab Verification

Run these queries to verify your data:

```sql
-- Count customers
SELECT COUNT(*) FROM customers;  -- Should be 3

-- Count products
SELECT COUNT(*) FROM products;   -- Should be 3

-- Count orders
SELECT COUNT(*) FROM orders;     -- Should be 2

-- Get order details
SELECT 
    c.first_name,
    c.last_name,
    o.id AS order_id,
    o.status,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- Get order items
SELECT 
    o.id AS order_id,
    p.name AS product,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

---

## LAB 3: Querying Data

**Objective:** Practice writing SELECT queries with filters, joins, and aggregations.

**Prerequisites:** Lab 2 completed

**Duration:** 45 minutes

---

### 3.1 Setup Instructions

**Step 1: Connect to PostgreSQL**

```bash
docker compose exec postgres psql -U scalecart -d scalecart
```

**Step 2: Basic SELECT Queries**

```sql
-- Select all customers
SELECT * FROM customers;

-- Select specific columns
SELECT first_name, last_name, email FROM customers;

-- Select with condition
SELECT * FROM products WHERE price > 50;

-- Select with ORDER BY
SELECT * FROM products ORDER BY price DESC;

-- Select with LIMIT
SELECT * FROM products LIMIT 2;

-- Select with LIKE
SELECT * FROM customers WHERE last_name LIKE 'S%';
```

**Step 3: JOIN Queries**

```sql
-- Inner Join: Orders with customers
SELECT 
    o.id AS order_id,
    c.first_name,
    c.last_name,
    o.status,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;

-- Join multiple tables
SELECT 
    c.first_name,
    c.last_name,
    o.id AS order_id,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

**Step 4: Aggregation Queries**

```sql
-- Count orders per customer
SELECT 
    c.first_name,
    c.last_name,
    COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.first_name, c.last_name
ORDER BY order_count DESC;

-- Total revenue per customer
SELECT 
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Average order value
SELECT 
    AVG(total_amount) AS avg_order_value
FROM orders;

-- Total sales by product
SELECT 
    p.name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY total_revenue DESC;
```

**Step 5: Subqueries**

```sql
-- Customers with orders
SELECT * FROM customers 
WHERE id IN (SELECT DISTINCT customer_id FROM orders);

-- Products never ordered
SELECT * FROM products 
WHERE id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- Customers who spent more than average
SELECT 
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > (SELECT AVG(total_amount) FROM orders);
```

---

### 3.2 Lab Verification

✅ All SELECT queries execute without errors
✅ JOIN queries return correct data
✅ Aggregation queries produce expected results
✅ Subqueries work correctly

---

## LAB 4: Indexing for Performance

**Objective:** Learn how indexes improve query performance.

**Prerequisites:** Lab 2 completed

**Duration:** 1 hour

---

### 4.1 Setup Instructions

**Step 1: Generate Test Data**

```sql
-- Generate 10,000 customers (if not already done)
INSERT INTO customers (first_name, last_name, email)
SELECT 
    'User' || generate_series,
    'Test' || generate_series,
    'user' || generate_series || '@test.com'
FROM generate_series(1, 10000);

-- Verify data
SELECT COUNT(*) FROM customers;  -- Should be 10003

-- Generate 50,000 orders
INSERT INTO orders (customer_id, status, total_amount)
SELECT 
    (random() * 10000 + 1)::int,
    CASE 
        WHEN random() < 0.3 THEN 'pending'
        WHEN random() < 0.6 THEN 'paid'
        WHEN random() < 0.8 THEN 'shipped'
        ELSE 'delivered'
    END,
    (random() * 500 + 10)::numeric(10,2)
FROM generate_series(1, 50000);
```

**Step 2: Analyze Query Performance**

```sql
-- Enable timing
\timing

-- Query without index
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 42;

-- Time it
SELECT * FROM orders WHERE customer_id = 42;
```

**Expected Output:**
```
Seq Scan on orders  (cost=0.00..... rows=...)
Execution Time: XX.XXX ms
```

**Step 3: Create Indexes**

```sql
-- Create index on customer_id
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Create composite index
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);

-- Create partial index
CREATE INDEX idx_orders_pending ON orders(order_date) 
WHERE status = 'pending';

-- Create covering index
CREATE INDEX idx_orders_covering ON orders(customer_id) 
INCLUDE (total_amount, status);
```

**Step 4: Re-analyze Performance**

```sql
-- Query with index
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 42;

-- Composite index query
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 42 AND status = 'paid';

-- Partial index query
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'pending' AND order_date > '2026-01-01';

-- Covering index query
EXPLAIN ANALYZE
SELECT customer_id, total_amount, status 
FROM orders WHERE customer_id = 42;
```

---

### 4.2 Lab Verification

✅ Sequential scan replaced with index scan
✅ Query execution time decreased significantly
✅ Covering index shows "Index Only Scan"
✅ Partial index shows smaller scan

---

## LAB 5: Transactions

**Objective:** Learn to write and manage database transactions.

**Prerequisites:** Lab 2 completed

**Duration:** 45 minutes

---

### 5.1 Setup Instructions

**Step 1: Prepare Inventory**

```sql
-- Check initial inventory
SELECT * FROM inventory WHERE product_id = 1;

-- Should show: stock_quantity = 50
```

**Step 2: Simple Transaction**

```sql
-- Begin transaction
BEGIN;

-- Check inventory
SELECT stock_quantity FROM inventory WHERE product_id = 1 FOR UPDATE;

-- Update inventory
UPDATE inventory SET stock_quantity = stock_quantity - 2 WHERE product_id = 1;

-- Verify update
SELECT stock_quantity FROM inventory WHERE product_id = 1;

-- Commit
COMMIT;
```

**Step 3: Transaction with ROLLBACK**

```sql
-- Begin transaction
BEGIN;

-- Try to place an order with insufficient stock
INSERT INTO orders (customer_id, status, total_amount)
VALUES (1, 'pending', 999.99);

-- Try to update inventory (insufficient stock)
UPDATE inventory SET stock_quantity = stock_quantity - 100 WHERE product_id = 2;

-- Check if update succeeded
-- If not (stock < 100), ROLLBACK
ROLLBACK;

-- Verify order was not created
SELECT * FROM orders WHERE customer_id = 1 ORDER BY id DESC LIMIT 1;
```

**Step 4: Complete Order Transaction**

```sql
-- Complete order placement transaction
BEGIN;

-- 1. Create order
INSERT INTO orders (customer_id, status, total_amount)
VALUES (1, 'pending', 0) RETURNING id;

-- 2. Add items and update inventory
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES 
    (1, 1, 2, 1499.99),
    (1, 2, 1, 29.99);

-- 3. Update inventory (with check)
UPDATE inventory SET stock_quantity = stock_quantity - 2 
WHERE product_id = 1 AND stock_quantity >= 2;

UPDATE inventory SET stock_quantity = stock_quantity - 1 
WHERE product_id = 2 AND stock_quantity >= 1;

-- 4. Calculate and update total
UPDATE orders 
SET total_amount = (
    SELECT SUM(quantity * unit_price) 
    FROM order_items 
    WHERE order_id = 1
)
WHERE id = 1;

-- 5. Process payment
INSERT INTO payments (order_id, amount, status)
VALUES (1, 3029.97, 'completed');

-- 6. Update order status
UPDATE orders SET status = 'paid' WHERE id = 1;

-- Commit if all succeeded
COMMIT;

-- Verify order
SELECT * FROM orders WHERE id = 1;
```

---

### 5.2 Lab Verification

✅ Inventory stock is updated correctly
✅ Order and order items are created
✅ Payment record exists
✅ Order status is 'paid'
✅ Transaction rolls back on failure

---

## LAB 6: Concurrency Control

**Objective:** Understand and implement concurrency control.

**Prerequisites:** Lab 5 completed

**Duration:** 1 hour

---

### 6.1 Setup Instructions

**Step 1: Create Test Data**

```sql
-- Reset inventory for testing
UPDATE inventory SET stock_quantity = 10 WHERE product_id = 1;
```

**Step 2: Optimistic Locking Setup**

```sql
-- Add version column
ALTER TABLE customers ADD COLUMN version INTEGER DEFAULT 1;

-- Update some customers with version
UPDATE customers SET version = 1 WHERE version IS NULL;
```

**Step 3: Optimistic Locking Example**

```sql
-- Open two terminal sessions (Session A and Session B)

-- Session A: Read customer with version
BEGIN;
SELECT id, email, version FROM customers WHERE id = 1;

-- Session B: Update customer (successful)
UPDATE customers 
SET email = 'john.new@example.com', version = version + 1 
WHERE id = 1 AND version = 1;

-- Session A: Try update with stale version (will fail)
UPDATE customers 
SET email = 'john.updated@example.com', version = version + 1 
WHERE id = 1 AND version = 1;
-- 0 rows updated!
```

**Step 4: Pessimistic Locking Example**

```sql
-- Session A: Lock inventory
BEGIN;
SELECT * FROM inventory WHERE product_id = 1 FOR UPDATE;

-- Session B: Try to update (will wait)
BEGIN;
UPDATE inventory SET stock_quantity = 5 WHERE product_id = 1;

-- Session A: Update and commit
UPDATE inventory SET stock_quantity = 5 WHERE product_id = 1;
COMMIT;

-- Session B: Update now succeeds (after lock released)
```

**Step 5: Deadlock Demonstration**

```sql
-- Session A
BEGIN;
UPDATE inventory SET stock_quantity = 5 WHERE product_id = 1;
-- Wait a moment
UPDATE inventory SET stock_quantity = 5 WHERE product_id = 2;

-- Session B
BEGIN;
UPDATE inventory SET stock_quantity = 5 WHERE product_id = 2;
-- Wait a moment
UPDATE inventory SET stock_quantity = 5 WHERE product_id = 1;

-- One transaction will be aborted due to deadlock
```

**Step 6: Queue Processing with SKIP LOCKED**

```sql
-- Create queue table
CREATE TABLE order_queue (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO order_queue (order_id)
SELECT id FROM orders LIMIT 10;

-- Process queue with SKIP LOCKED
BEGIN;
WITH pending_orders AS (
    SELECT id 
    FROM order_queue 
    WHERE status = 'pending' 
    ORDER BY created_at 
    LIMIT 5 
    FOR UPDATE SKIP LOCKED
)
UPDATE order_queue 
SET status = 'processing' 
WHERE id IN (SELECT id FROM pending_orders)
RETURNING *;
COMMIT;
```

---

### 6.2 Lab Verification

✅ Optimistic locking prevents stale updates
✅ Pessimistic locking blocks concurrent updates
✅ Deadlock is detected and resolved
✅ SKIP LOCKED processes available rows only

---

## LAB 7: Database Partitioning

**Objective:** Implement table partitioning for large datasets.

**Prerequisites:** Lab 2 completed

**Duration:** 45 minutes

---

### 7.1 Setup Instructions

**Step 1: Create Partitioned Table**

```sql
-- Create partitioned orders table
CREATE TABLE orders_partitioned (
    id SERIAL,
    customer_id INTEGER NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id, order_date)
) PARTITION BY RANGE (order_date);

-- Create partitions
CREATE TABLE orders_2024 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE orders_2025 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE orders_2026 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Create indexes
CREATE INDEX idx_orders_2024_customer ON orders_2024(customer_id);
CREATE INDEX idx_orders_2025_customer ON orders_2025(customer_id);
CREATE INDEX idx_orders_2026_customer ON orders_2026(customer_id);
```

**Step 2: Migrate Data**

```sql
-- Insert data into partitioned table
INSERT INTO orders_partitioned (id, customer_id, order_date, status, total_amount)
SELECT id, customer_id, order_date, status, total_amount
FROM orders;
```

**Step 3: Query Partitioned Table**

```sql
-- Query with partition pruning
EXPLAIN ANALYZE
SELECT * FROM orders_partitioned 
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';

-- Query across multiple partitions
EXPLAIN ANALYZE
SELECT * FROM orders_partitioned 
WHERE order_date BETWEEN '2024-06-01' AND '2025-06-30';
```

**Step 4: Add New Partition**

```sql
-- Create partition for next year
CREATE TABLE orders_2027 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');

-- Add indexes
CREATE INDEX idx_orders_2027_customer ON orders_2027(customer_id);
```

**Step 5: Drop Old Partition**

```sql
-- Drop old partition
DROP TABLE orders_2024;

-- Or detach for archiving
ALTER TABLE orders_partitioned DETACH PARTITION orders_2024;
```

---

### 7.2 Lab Verification

✅ Partitioned table contains all data
✅ Queries show partition pruning
✅ Query performance improves
✅ New partitions can be added
✅ Old partitions can be dropped

---

## LAB 8: NoSQL with Redis

**Objective:** Work with Redis for caching and session management.

**Prerequisites:** Lab 1 completed

**Duration:** 1 hour

---

### 8.1 Setup Instructions

**Step 1: Connect to Redis**

```bash
docker compose exec redis redis-cli -a scalecart_password
```

**Step 2: Basic Key-Value Operations**

```redis
# Set values
SET user:1:name "John Doe"
SET user:1:email "john@example.com"

# Get values
GET user:1:name
GET user:1:email

# Check existence
EXISTS user:1:name

# Set with expiration (TTL)
SETEX session:abc123 3600 "{\"user_id\": 1}"

# Get TTL
TTL session:abc123

# Delete key
DEL user:1:email

# List all keys
KEYS *
```

**Step 3: Hashes**

```redis
# Set hash fields
HSET user:1 name "John Doe" email "john@example.com" age 30

# Get hash fields
HGET user:1 name
HGETALL user:1

# Get all field names
HKEYS user:1

# Get all values
HVALS user:1

# Increment numeric field
HINCRBY user:1 age 1
```

**Step 4: Lists**

```redis
# Push to list
LPUSH cart:1 "product:1"
LPUSH cart:1 "product:2"
LPUSH cart:1 "product:3"

# Get list
LRANGE cart:1 0 -1

# Pop from list
LPOP cart:1

# Get list length
LLEN cart:1
```

**Step 5: Sets**

```redis
# Add to set
SADD user:1:orders 101 102 103

# Get set members
SMEMBERS user:1:orders

# Check membership
SISMEMBER user:1:orders 101

# Get set size
SCARD user:1:orders
```

**Step 6: Sorted Sets**

```redis
# Add to sorted set (score = order date)
ZADD user:1:orders_by_date 2026-01-01 101
ZADD user:1:orders_by_date 2026-01-02 102
ZADD user:1:orders_by_date 2026-01-03 103

# Get sorted by score
ZRANGE user:1:orders_by_date 0 -1 WITHSCORES

# Reverse order
ZREVRANGE user:1:orders_by_date 0 -1

# Get by score range
ZRANGEBYSCORE user:1:orders_by_date 2026-01-01 2026-01-02
```

---

### 8.2 Lab Verification

✅ All Redis commands execute successfully
✅ Different data types work correctly
✅ TTL expires keys after specified time
✅ Sets and sorted sets maintain uniqueness and ordering

---

## LAB 9: NoSQL with MongoDB

**Objective:** Work with MongoDB for document storage.

**Prerequisites:** Lab 1 completed

**Duration:** 1 hour

---

### 9.1 Setup Instructions

**Step 1: Connect to MongoDB**

```bash
docker compose exec mongodb mongosh -u scalecart -p scalecart_password
```

**Step 2: Insert Documents**

```javascript
// Switch to database
use scalecart

// Insert single document
db.products.insertOne({
    name: "MacBook Pro",
    price: 2499.99,
    category: "Laptops",
    specs: {
        cpu: "M2 Pro",
        ram: "16GB",
        storage: "512GB"
    },
    tags: ["apple", "laptop", "premium"],
    created_at: new Date()
})

// Insert multiple documents
db.products.insertMany([
    {
        name: "iPhone 15",
        price: 1099.99,
        category: "Smartphones",
        specs: { model: "iPhone 15", storage: "256GB" }
    },
    {
        name: "AirPods Pro",
        price: 249.99,
        category: "Accessories",
        specs: { type: "wireless", active_noise_cancelling: true }
    }
])
```

**Step 3: Query Documents**

```javascript
// Find all
db.products.find()

// Find with filter
db.products.find({ category: "Laptops" })

// Find with nested field
db.products.find({ "specs.storage": "512GB" })

// Find with conditions
db.products.find({ price: { $gt: 500 } })
db.products.find({ price: { $lt: 1000 } })

// Find with regex
db.products.find({ name: { $regex: /Pro/ } })

// Sort
db.products.find().sort({ price: -1 })

// Limit
db.products.find().limit(2)

// Project
db.products.find({}, { name: 1, price: 1 })
```

**Step 4: Update Documents**

```javascript
// Update one
db.products.updateOne(
    { name: "MacBook Pro" },
    { $set: { price: 2599.99 } }
)

// Update multiple
db.products.updateMany(
    { category: "Accessories" },
    { $set: { discount: 0.1 } }
)

// Add to array
db.products.updateOne(
    { name: "MacBook Pro" },
    { $push: { tags: "new" } }
)

// Remove from array
db.products.updateOne(
    { name: "MacBook Pro" },
    { $pull: { tags: "new" } }
)

// Upsert (insert if not exists)
db.products.updateOne(
    { name: "iPad" },
    { $set: { price: 799.99, category: "Tablets" } },
    { upsert: true }
)
```

**Step 5: Delete Documents**

```javascript
// Delete one
db.products.deleteOne({ name: "iPad" })

// Delete multiple
db.products.deleteMany({ price: { $lt: 100 } })
```

**Step 6: Aggregation Pipeline**

```javascript
// Group by category
db.products.aggregate([
    { $group: { _id: "$category", count: { $sum: 1 } } }
])

// Group with average price
db.products.aggregate([
    { $group: { 
        _id: "$category", 
        count: { $sum: 1 },
        avg_price: { $avg: "$price" }
    } }
])

// Pipeline with stages
db.products.aggregate([
    { $match: { price: { $gt: 500 } } },
    { $group: { _id: "$category", avg_price: { $avg: "$price" } } },
    { $sort: { avg_price: -1 } }
])
```

**Step 7: Indexes**

```javascript
// Create index
db.products.createIndex({ name: 1 })
db.products.createIndex({ category: 1, price: -1 })

// List indexes
db.products.getIndexes()

// Drop index
db.products.dropIndex("name_1")
```

---

### 9.2 Lab Verification

✅ Documents inserted and queried successfully
✅ Updates work correctly
✅ Aggregation pipeline returns expected results
✅ Indexes improve query performance

---

## LAB 10: Graph Database with Neo4j

**Objective:** Work with Neo4j for graph-based recommendations.

**Prerequisites:** Lab 1 completed

**Duration:** 1 hour

---

### 10.1 Setup Instructions

**Step 1: Connect to Neo4j**

```bash
docker compose exec neo4j cypher-shell -u neo4j -p scalecart_neo4j_password
```

**Step 2: Create Nodes**

```cypher
// Create customers
CREATE (c1:Customer {id: 1, name: "Alice"})
CREATE (c2:Customer {id: 2, name: "Bob"})
CREATE (c3:Customer {id: 3, name: "Carol"})

// Create products
CREATE (p1:Product {id: 1, name: "Laptop", price: 1499.99})
CREATE (p2:Product {id: 2, name: "Mouse", price: 29.99})
CREATE (p3:Product {id: 3, name: "Keyboard", price: 89.99})
CREATE (p4:Product {id: 4, name: "Monitor", price: 399.99})

// Create categories
CREATE (cat1:Category {id: 1, name: "Electronics"})
CREATE (cat2:Category {id: 2, name: "Accessories"})
```

**Step 3: Create Relationships**

```cypher
// Category to Product
MATCH (cat:Category {name: "Electronics"})
MATCH (p:Product {name: "Laptop"})
CREATE (p)-[:BELONGS_TO]->(cat)

MATCH (cat:Category {name: "Accessories"})
MATCH (p:Product {name: "Mouse"})
CREATE (p)-[:BELONGS_TO]->(cat)

// Customer to Product (BOUGHT)
MATCH (c:Customer {name: "Alice"})
MATCH (p:Product {name: "Laptop"})
CREATE (c)-[:BOUGHT {quantity: 1, date: "2026-01-01"}]->(p)

MATCH (c:Customer {name: "Alice"})
MATCH (p:Product {name: "Mouse"})
CREATE (c)-[:BOUGHT {quantity: 2, date: "2026-01-02"}]->(p)

MATCH (c:Customer {name: "Bob"})
MATCH (p:Product {name: "Keyboard"})
CREATE (c)-[:BOUGHT {quantity: 1, date: "2026-01-03"}]->(p)

MATCH (c:Customer {name: "Carol"})
MATCH (p:Product {name: "Monitor"})
CREATE (c)-[:BOUGHT {quantity: 1, date: "2026-01-04"}]->(p)
```

**Step 4: Query Nodes and Relationships**

```cypher
// Find all customers
MATCH (c:Customer) RETURN c

// Find all products
MATCH (p:Product) RETURN p

// Find products in category
MATCH (p:Product)-[:BELONGS_TO]->(cat:Category {name: "Electronics"})
RETURN p

// Find customers who bought a product
MATCH (c:Customer)-[:BOUGHT]->(p:Product {name: "Laptop"})
RETURN c
```

**Step 5: Recommendations**

```cypher
// Collaborative filtering
MATCH (c:Customer {name: "Alice"})-[:BOUGHT]->(p:Product)<-[:BOUGHT]-(other:Customer)-[:BOUGHT]->(rec:Product)
WHERE NOT (c)-[:BOUGHT]->(rec)
RETURN rec.name, COUNT(*) AS frequency
ORDER BY frequency DESC

// Products in same category
MATCH (c:Customer {name: "Alice"})-[:BOUGHT]->(p:Product)-[:BELONGS_TO]->(cat:Category)<-[:BELONGS_TO]-(rec:Product)
WHERE NOT (c)-[:BOUGHT]->(rec)
RETURN rec.name, rec.price

// Path traversal
MATCH path = (c:Customer {name: "Alice"})-[:BOUGHT*1..3]->(p:Product)
RETURN path

// Friends of friends
MATCH (c:Customer {name: "Alice"})-[r:FRIEND_OF]-(f:Customer)-[:BOUGHT]->(p:Product)
WHERE NOT (c)-[:BOUGHT]->(p)
RETURN f.name AS friend, p.name AS product
```

---

### 10.2 Lab Verification

✅ Nodes and relationships created successfully
✅ Cypher queries return expected results
✅ Recommendations work correctly
✅ Path traversal shows graph connections

---

## LAB 11: Complete E-Commerce Application

**Objective:** Build a complete e-commerce application with the ScaleCart database.

**Prerequisites:** All previous labs completed

**Duration:** 3-4 hours

---

### 11.1 Setup Instructions

**Step 1: Create Complete Schema**

Run the full schema from Appendix A of the main documentation.

**Step 2: Load Data**

```sql
-- Load sample data (see Appendix A for complete data)
-- Load at least:
-- 1000+ customers
-- 1000+ products
-- 10,000+ orders
-- 50,000+ order items
```

**Step 3: Implement Features**

```sql
-- Feature 1: Product Search with Full-Text
CREATE OR REPLACE FUNCTION search_products(search_term TEXT)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    description TEXT,
    price NUMERIC,
    relevance REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.description,
        p.price,
        ts_rank(p.search_vector, to_tsquery('english', search_term)) AS relevance
    FROM products p
    WHERE p.search_vector @@ to_tsquery('english', search_term)
    ORDER BY relevance DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- Feature 2: Inventory Report
CREATE OR REPLACE VIEW inventory_report AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    p.sku,
    i.stock_quantity,
    i.reserved_quantity,
    i.stock_quantity - i.reserved_quantity AS available_quantity,
    i.reorder_threshold,
    CASE 
        WHEN (i.stock_quantity - i.reserved_quantity) <= i.reorder_threshold THEN 'LOW'
        WHEN (i.stock_quantity - i.reserved_quantity) <= i.reorder_threshold * 2 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS stock_status
FROM products p
JOIN inventory i ON p.id = i.product_id;

-- Feature 3: Sales Analytics
CREATE OR REPLACE FUNCTION get_sales_analytics(start_date DATE, end_date DATE)
RETURNS TABLE(
    sale_date DATE,
    order_count BIGINT,
    total_revenue NUMERIC,
    avg_order_value NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        DATE(o.order_date) AS sale_date,
        COUNT(*) AS order_count,
        SUM(o.total_amount) AS total_revenue,
        AVG(o.total_amount) AS avg_order_value
    FROM orders o
    WHERE o.status IN ('paid', 'shipped', 'delivered')
      AND DATE(o.order_date) BETWEEN start_date AND end_date
    GROUP BY DATE(o.order_date)
    ORDER BY sale_date DESC;
END;
$$ LANGUAGE plpgsql;
```

**Step 4: Optimize Queries**

```sql
-- Create indexes for common queries
CREATE INDEX idx_products_price_category ON products(price, category_id);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date DESC);
CREATE INDEX idx_order_items_product_quantity ON order_items(product_id, quantity);
```

**Step 5: Write Complex Reports**

```sql
-- Report 1: Top selling products
SELECT 
    p.id,
    p.name,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status IN ('paid', 'shipped', 'delivered')
  AND o.order_date > CURRENT_DATE - INTERVAL '90 days'
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 10;

-- Report 2: Customer lifetime value
SELECT 
    c.id,
    c.full_name,
    c.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order,
    MAX(o.order_date) AS last_order,
    EXTRACT(DAY FROM (CURRENT_DATE - MAX(o.order_date))) AS days_since_last
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status IN ('paid', 'shipped', 'delivered')
GROUP BY c.id, c.full_name, c.email
HAVING COUNT(o.id) > 0
ORDER BY total_spent DESC;

-- Report 3: Monthly sales summary
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS orders,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_order
FROM orders
WHERE status IN ('paid', 'shipped', 'delivered')
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;
```

---

### 11.2 Lab Verification

✅ Complete schema is created
✅ Data is loaded successfully
✅ Full-text search works
✅ Inventory report shows correct stock levels
✅ Sales analytics function returns correct data
✅ Reports execute quickly with indexes

---

## LAB CLEANUP COMMANDS

```bash
# Stop all services
docker compose down

# Remove volumes (delete all data)
docker compose down -v

# Remove containers
docker rm -f scalecart_postgres scalecart_redis scalecart_mongodb scalecart_neo4j

# Delete project directory
cd ~
rm -rf ~/scalecart-labs
```

---

## TROUBLESHOOTING GUIDE

### Common Issues and Solutions

**Issue:** PostgreSQL won't start
```bash
# Check logs
docker compose logs postgres

# If port 5432 is in use
sudo lsof -i :5432
# Kill the process or change port in docker-compose.yml
```

**Issue:** Redis connection refused
```bash
# Check Redis is running
docker compose ps redis

# Check logs
docker compose logs redis

# Reset Redis
docker compose restart redis
```

**Issue:** Cannot connect to MongoDB
```bash
# Check MongoDB is running
docker compose ps mongodb

# Check logs
docker compose logs mongodb

# Reset MongoDB
docker compose restart mongodb
```

**Issue:** Neo4j authentication fails
```bash
# Check credentials
NEO4J_AUTH: neo4j/scalecart_neo4j_password

# Reset Neo4j
docker compose down neo4j
docker compose up -d neo4j
```

**Issue:** Permission denied when running docker compose
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Re-login or run:
newgrp docker
```

---

## LAB COMPLETION CHECKLIST

```
□ Lab 1: Setting Up Your Database Environment
□ Lab 2: Creating Your First Tables
□ Lab 3: Querying Data
□ Lab 4: Indexing for Performance
□ Lab 5: Transactions
□ Lab 6: Concurrency Control
□ Lab 7: Database Partitioning
□ Lab 8: NoSQL with Redis
□ Lab 9: NoSQL with MongoDB
□ Lab 10: Graph Database with Neo4j
□ Lab 11: Complete E-Commerce Application
```

---

## LAB GRADING RUBRIC

| Criteria | Weight | Points |
|----------|--------|--------|
| Database Setup & Configuration | 10% | /10 |
| Schema Design | 15% | /15 |
| Query Writing | 15% | /15 |
| Indexing & Performance | 15% | /15 |
| Transaction Implementation | 10% | /10 |
| Concurrency Control | 10% | /10 |
| NoSQL Implementation | 15% | /15 |
| Final Project | 10% | /10 |
| **Total** | **100%** | **/100** |

---

**[END OF LAB BOOK]**

*This lab book contains all hands-on exercises for the Mastering Modern Database Design series. Complete each lab in order, verifying your work at each step.*
