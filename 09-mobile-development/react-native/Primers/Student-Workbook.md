# Serverless Postgres with Neon: From Zero to Production
## Student Workbook

### Overview

This workbook is your companion to the "Serverless Postgres with Neon: From Zero to Production" course. It contains hands-on exercises, code challenges, and reflection questions for each part of the series. Complete these exercises to reinforce your learning and build your e-commerce backend step by step.

---

## How to Use This Workbook

1. **Before the Session**: Review the objectives and pre-work
2. **During the Session**: Follow along with the instructor, complete the exercises
3. **After the Session**: Finish any remaining exercises, review the reflection questions
4. **Track Your Progress**: Check off completed items in the progress tracker

---

## Progress Tracker

| Part | Topic | Status | Date Completed |
|------|-------|--------|----------------|
| 0 | Introduction | ⬜ | |
| 1 | Setup & Cloud SQL Fundamentals | ⬜ | |
| 2 | Bulletproof Schemas & Data Integrity | ⬜ | |
| 3 | Database Branching & Relational Architecture | ⬜ | |
| 4 | Analytical Power | ⬜ | |
| 5 | JSONB & Extensions | ⬜ | |
| 6 | Performance, Transactions & CI/CD | ⬜ | |
| Final Project | Complete E-Commerce Backend | ⬜ | |

---

# PART 0: INTRODUCTION

## Objectives
- Understand what you'll build in this course
- Set up your development environment
- Create your Neon account

## Pre-Work Checklist

- [ ] Create a Neon account at [neon.tech](https://neon.tech)
- [ ] Install psql (PostgreSQL client) on your machine
- [ ] Install Node.js (for API examples)
- [ ] Install Git
- [ ] Install a code editor (VS Code recommended)

## Reflection Questions

1. What is your experience with databases? (Check one)
   - [ ] No experience
   - [ ] Some experience with SQL
   - [ ] Experienced with PostgreSQL
   - [ ] Experienced with other databases

2. What are you most excited to learn in this course?
   ```
   _________________________________________________
   _________________________________________________
   ```

3. What do you want to build after this course?
   ```
   _________________________________________________
   _________________________________________________
   ```

---

# PART 1: INSTANT SETUP & CLOUD SQL FUNDAMENTALS

## Objectives
- Create a Neon project
- Connect to your database using psql
- Create a products table
- Perform CRUD operations
- Write basic filtering and sorting queries

## Exercise 1.1: Provision Your Neon Database

1. Log into your Neon account
2. Create a new project named `ecommerce-workshop`
3. Choose a region close to you
4. Copy your connection string and save it somewhere secure

**Connection String** (write yours here):
```
_________________________________________________
```

5. Test your connection using psql:
```bash
psql "your-connection-string-here"
```

**Screenshot/Verification**:
```
_________________________________________________
```

---

## Exercise 1.2: Install Neon CLI

Install the Neon CLI tool:
```bash
npm install -g neonctl
neonctl auth
neonctl --version
```

**Version Installed**: _______________

Run `neonctl projects list` and record your project ID:
```
_________________________________________________
```

---

## Exercise 1.3: Create Products Table

Connect to your database and create the products table:

```sql
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

✅ **Check**: Run `\d products` - you should see the table structure.

---

## Exercise 1.4: Insert Products

Insert at least 8 products into your products table with realistic data:

```sql
-- Write your INSERT statements here
INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Product 1', 'Description 1', 99.99, 100),
    -- Add more products...
```

**Your Products**:
```
1. _________________________________
2. _________________________________
3. _________________________________
4. _________________________________
5. _________________________________
6. _________________________________
7. _________________________________
8. _________________________________
```

---

## Exercise 1.5: CRUD Operations

### Read (SELECT)
Write queries for each of the following:

**1. Select all products**:
```sql
_________________________________
```

**2. Select products with price > 100**:
```sql
_________________________________
```

**3. Select products with stock_quantity > 0**:
```sql
_________________________________
```

**4. Select products sorted by price (highest first)**:
```sql
_________________________________
```

**5. Select the 3 cheapest products**:
```sql
_________________________________
```

### Update
**6. Increase the price of all products by 10%**:
```sql
_________________________________
```

**7. Update a specific product's stock quantity**:
```sql
_________________________________
```

### Delete
**8. Delete a product with stock_quantity = 0** (if you have one, or mark one as 0 first):
```sql
_________________________________
```

---

## Exercise 1.6: Filtering and Sorting

Write queries for each scenario:

**1. Products with 'wireless' in the name**:
```sql
_________________________________
```

**2. Products with price between 50 and 150**:
```sql
_________________________________
```

**3. Products sorted by stock_quantity (lowest first)**:
```sql
_________________________________
```

**4. Products with name starting with 'P'**:
```sql
_________________________________
```

**5. Products with description containing 'premium'**:
```sql
_________________________________
```

**6. The 3 most expensive products**:
```sql
_________________________________
```

**7. Products with stock_quantity > 50, sorted by price**:
```sql
_________________________________
```

---

## Challenge Exercise 1.7: Product Catalog Query

Write a query that:
- Shows only in-stock products
- Shows product name, price, and a shortened description (first 50 characters)
- Sorts by price (cheapest first)
- Shows 5 products per page (page 1)

```sql
_________________________________
_________________________________
_________________________________
_________________________________
_________________________________
```

---

## Exercise 1.8: Seed Script

Create a file called `seed.sql` with your product insert statements:

```sql
-- seed.sql
-- Your seed data here
```

Run it using:
```bash
psql "$DATABASE_URL" -f seed.sql
```

**Number of rows inserted**: _______________

---

## Reflection Questions

1. What was the most challenging part of this module?
   ```
   _________________________________________________
   _________________________________________________
   ```

2. What SQL concept is still unclear to you?
   ```
   _________________________________________________
   _________________________________________________
   ```

3. What real-world scenario could you apply these skills to?
   ```
   _________________________________________________
   _________________________________________________
   ```

---

# PART 2: BULLETPROOF SCHEMAS & DATA INTEGRITY

## Objectives
- Understand SERIAL vs UUID primary keys
- Create a users table with constraints
- Implement data validation with CHECK constraints
- Understand connection pooling

## Exercise 2.1: Enable UUID Extension

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Test UUID generation
SELECT uuid_generate_v4();
```

**Your UUID**: _________________________________

---

## Exercise 2.2: Create Users Table

Create a users table with the following features:
- UUID primary key
- Email with validation
- Username with validation
- Password hash (TEXT)
- Full name
- Status with valid values
- Role with valid values
- Created_at and updated_at timestamps
- Deleted_at for soft delete

```sql
CREATE TABLE IF NOT EXISTS users (
    -- Write your table definition here
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    _________________________________
    _________________________________
    _________________________________
    _________________________________
    _________________________________
    _________________________________
    _________________________________
    _________________________________
);
```

✅ **Check**: Run `\d users` - verify all columns and constraints.

---

## Exercise 2.3: Add Validation Constraints

Add CHECK constraints for:
1. Email format (must contain @ and .)
2. Username (starts with letter, letters/numbers/underscores only)
3. Status (active, inactive, suspended only)
4. Role (customer, staff, admin only)

```sql
ALTER TABLE users ADD CONSTRAINT valid_email 
    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE users ADD CONSTRAINT valid_username 
    CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$');

-- Add status and role constraints
_________________________________
_________________________________
```

---

## Exercise 2.4: Test Constraints

Test each constraint by trying to insert invalid data:

**1. Invalid email**:
```sql
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('invalid-email', 'testuser', 'hash', 'Test User');
-- This should FAIL
```

**2. Invalid username (starts with number)**:
```sql
_________________________________
-- This should FAIL
```

**3. Valid user (should succeed)**:
```sql
_________________________________
-- This should SUCCEED
```

**Record the error messages**:
```
1. _________________________________
2. _________________________________
3. _________________________________
```

---

## Exercise 2.5: Insert Sample Users

Insert 5 sample users with different roles and statuses:

```sql
INSERT INTO users (email, username, password_hash, full_name, phone, role, status) VALUES
    ('admin@example.com', 'admin', 'hash', 'Admin User', '+1-555-0000', 'admin', 'active'),
    -- Add more users
    _________________________________
    _________________________________
    _________________________________
    _________________________________;
```

**Your Users**:
```
1. _________________________________
2. _________________________________
3. _________________________________
4. _________________________________
5. _________________________________
```

---

## Exercise 2.6: Automatic Timestamps

Create a function and trigger to automatically update the `updated_at` column:

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

**Test the trigger**:
```sql
UPDATE users SET full_name = 'Updated Name' WHERE email = 'admin@example.com';

SELECT email, full_name, created_at, updated_at 
FROM users WHERE email = 'admin@example.com';
```

✅ **Check**: The updated_at should be later than created_at.

---

## Exercise 2.7: Soft Delete

**1. Soft delete a user**:
```sql
UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE email = 'testuser@example.com';
```

**2. Create a view for active users**:
```sql
CREATE VIEW active_users AS
SELECT * FROM users WHERE deleted_at IS NULL;
```

**3. Query active users**:
```sql
SELECT * FROM active_users;
```

**Number of active users**: _______________

---

## Exercise 2.8: Connection Pooling

**1. Direct Connection**:
```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**2. Pooled Connection** (get from Neon Console):
```
_________________________________________________
```

**3. What's the difference?**:
```
_________________________________________________
_________________________________________________
```

---

## Challenge Exercise 2.9: Migration Script

Write a complete migration script that:
- Creates the users table
- Adds all constraints
- Creates indexes
- Creates the update timestamp trigger
- Creates the active_users view
- Seeds initial users

```sql
-- migration.sql
_________________________________
_________________________________
_________________________________
_________________________________
_________________________________
```

---

## Reflection Questions

1. Why would you choose UUID over SERIAL for a primary key?
   ```
   _________________________________________________
   _________________________________________________
   ```

2. What are the benefits of soft delete?
   ```
   _________________________________________________
   _________________________________________________
   ```

3. When would you use a pooled connection vs a direct connection?
   ```
   _________________________________________________
   _________________________________________________
   ```

---

# PART 3: DATABASE BRANCHING & RELATIONAL ARCHITECTURE

## Objectives
- Create Neon database branches
- Design relational models
- Implement foreign keys
- Write complex JOIN queries

## Exercise 3.1: Create a Development Branch

**Using CLI**:
```bash
neonctl branches create --name dev-branch --project-id YOUR_PROJECT_ID
```

**Using Console**: Branches → Create Branch → Name: `dev-branch`

**Get connection string**:
```bash
neonctl branches get-connection-string dev-branch --project-id YOUR_PROJECT_ID
```

**Connection string for dev-branch**:
```
_________________________________________________
```

✅ **Check**: Connect to dev-branch and verify it has the same data as main.

---

## Exercise 3.2: Create Addresses Table

```sql
CREATE TABLE IF NOT EXISTS addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'USA',
    address_type VARCHAR(20) NOT NULL DEFAULT 'shipping',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT valid_address_type CHECK (address_type IN ('shipping', 'billing'))
);

CREATE INDEX idx_addresses_user_id ON addresses(user_id) WHERE deleted_at IS NULL;
```

✅ **Check**: Run `\d addresses` - verify table structure.

---

## Exercise 3.3: Create Orders Table

```sql
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    shipping_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    billing_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    subtotal NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    shipping_cost NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    discount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    total NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    shipping_method VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100),
    customer_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT positive_total CHECK (total >= 0)
);
```

✅ **Check**: Run `\d orders` - verify all columns and constraints.

---

## Exercise 3.4: Create Order Items Table

```sql
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_name VARCHAR(255) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    line_subtotal NUMERIC(10,2) NOT NULL,
    line_tax NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    line_total NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_unit_price CHECK (unit_price >= 0)
);
```

✅ **Check**: Run `\d order_items` - verify table structure.

---

## Exercise 3.5: Insert Sample Addresses

```sql
INSERT INTO addresses (user_id, address_line1, city, state, postal_code, address_type, is_default)
SELECT 
    id,
    '123 Main St',
    'Boston',
    'MA',
    '02101',
    'shipping',
    TRUE
FROM users
LIMIT 3;
```

Add more addresses for your users:
```
_________________________________
_________________________________
_________________________________
```

---

## Exercise 3.6: Insert Sample Orders

Insert 3 orders with realistic data:

```sql
INSERT INTO orders (
    user_id, shipping_address_id, billing_address_id, order_number,
    subtotal, tax, shipping_cost, discount, total,
    payment_method, payment_status, status, shipping_method,
    created_at
) VALUES (
    -- Order 1
    _________________________________
    -- Order 2
    _________________________________
    -- Order 3
    _________________________________
);
```

**Your Orders**:
```
1. _________________________________
2. _________________________________
3. _________________________________
```

---

## Exercise 3.7: Insert Order Items

For each order, insert 1-3 order items:

```sql
INSERT INTO order_items (
    order_id, product_id, product_name, unit_price, quantity,
    line_subtotal, line_tax, line_total
) VALUES (
    -- Order 1 items
    _________________________________
    -- Order 2 items
    _________________________________
    -- Order 3 items
    _________________________________
);
```

---

## Exercise 3.8: JOIN Queries

Write queries for each scenario:

**1. Get all orders with user names**:
```sql
SELECT 
    o.order_number,
    u.full_name AS customer,
    o.total,
    o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.id;
```

**2. Get orders with shipping address**:
```sql
_________________________________
_________________________________
```

**3. Get orders with all items**:
```sql
_________________________________
_________________________________
```

**4. Get total spent per customer**:
```sql
_________________________________
_________________________________
```

**5. Get products that have been ordered**:
```sql
_________________________________
_________________________________
```

---

## Exercise 3.9: Complex JOIN

Write a query that shows:
- Order number
- Customer name
- Customer email
- Shipping address
- All items in the order
- Total order amount

```sql
_________________________________
_________________________________
_________________________________
_________________________________
_________________________________
```

---

## Exercise 3.10: Merge Branch

1. Make changes in dev-branch
2. Test the changes
3. Merge to main when ready

**Merge command**:
```bash
neonctl branches merge dev-branch --target main --project-id YOUR_PROJECT_ID
```

✅ **Check**: Verify changes are reflected in main branch.

---

## Reflection Questions

1. How is Neon's branching different from traditional database copying?
   ```
   _________________________________________________
   _________________________________________________
   ```

2. When would you use ON DELETE CASCADE vs ON DELETE RESTRICT?
   ```
   _________________________________________________
   _________________________________________________
   ```

3. What are the benefits of denormalizing order items (storing product_name, unit_price)?
   ```
   _________________________________________________
   _________________________________________________
   ```

---

# PART 4: ANALYTICAL POWER - AGGREGATIONS & WINDOW FUNCTIONS

## Objectives
- Use aggregate functions (COUNT, SUM, AVG, MIN, MAX)
- Group data with GROUP BY
- Filter groups with HAVING
- Use window functions (ROW_NUMBER, RANK, LAG, LEAD)
- Write conditional logic with CASE WHEN

## Exercise 4.1: Basic Aggregates

Write queries for each:

**1. Total number of products**:
```sql
SELECT COUNT(*) FROM products;
```
**Result**: _______________

**2. Average product price**:
```sql
_________________________________
```
**Result**: _______________

**3. Total value of all products (price × stock_quantity)**:
```sql
_________________________________
```
**Result**: _______________

**4. Most expensive product**:
```sql
_________________________________
```
**Result**: _______________

**5. Total revenue from all orders**:
```sql
_________________________________
```
**Result**: _______________

---

## Exercise 4.2: GROUP BY

**1. Count orders by status**:
```sql
SELECT 
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status;
```

**2. Total revenue by payment method**:
```sql
_________________________________
_________________________________
```

**3. Average order value by status**:
```sql
_________________________________
_________________________________
```

**4. Monthly revenue summary**:
```sql
_________________________________
_________________________________
```

---

## Exercise 4.3: HAVING

**1. Customers with more than 2 orders**:
```sql
SELECT 
    user_id,
    COUNT(*) AS order_count,
    SUM(total) AS total_spent
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 2;
```

**2. Products ordered more than 5 times**:
```sql
_________________________________
_________________________________
```

---

## Exercise 4.4: Window Functions

**1. Number orders per customer**:
```sql
SELECT 
    u.full_name,
    o.order_number,
    o.total,
    ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY o.order_date) AS order_sequence
FROM users u
JOIN orders o ON u.id = o.user_id
ORDER BY u.full_name, o.order_date;
```

**2. Rank customers by spending**:
```sql
_________________________________
_________________________________
```

**3. Month-over-month revenue comparison**:
```sql
_________________________________
_________________________________
```

**4. Running total of orders**:
```sql
_________________________________
_________________________________
```

---

## Exercise 4.5: CASE WHEN

**1. Categorize orders by value**:
```sql
SELECT 
    order_number,
    total,
    CASE 
        WHEN total < 100 THEN 'Small'
        WHEN total >= 100 AND total < 500 THEN 'Medium'
        WHEN total >= 500 THEN 'Large'
    END AS order_size_category
FROM orders;
```

**2. Customer segmentation by total spend**:
```sql
_________________________________
_________________________________
```

**3. Product performance categories**:
```sql
_________________________________
_________________________________
```

---

## Exercise 4.6: Analytics Dashboard

Create a view that shows:
- Total orders
- Total revenue
- Average order value
- Unique customers
- Top selling product

```sql
CREATE VIEW analytics_dashboard AS
_________________________________
_________________________________
_________________________________
_________________________________
_________________________________
```

✅ **Check**: Query the view and verify the results.

---

## Reflection Questions

1. What is the difference between WHERE and HAVING?
   ```
   _________________________________________________
   _________________________________________________
   ```

2. How are window functions different from GROUP BY?
   ```
   _________________________________________________
   _________________________________________________
   ```

3. When would you use a materialized view vs a regular view?
   ```
   _________________________________________________
   _________________________________________________
   ```

---

# PART 5: SEMI-STRUCTURED DATA WITH JSONB & EXTENSIONS

## Objectives
- Add JSONB columns to products
- Query JSONB data
- Index JSONB fields
- Enable and use PostgreSQL extensions
- Implement fuzzy text search

## Exercise 5.1: Add JSONB Columns

```sql
ALTER TABLE products 
ADD COLUMN attributes JSONB DEFAULT '{}'::jsonb,
ADD COLUMN variants JSONB DEFAULT '[]'::jsonb,
ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
```

✅ **Check**: Run `\d products` - verify new columns.

---

## Exercise 5.2: Insert JSONB Data

Update products with realistic JSONB data:

```sql
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'color', 'Black',
        'connectivity', 'Bluetooth 5.3',
        'battery_life', '40 hours',
        'noise_cancellation', 'Active'
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'color', 'Black',
            'price_adjustment', 0,
            'sku', 'HP-BLK-001',
            'stock', 50
        ),
        jsonb_build_object(
            'color', 'Silver',
            'price_adjustment', 10.00,
            'sku', 'HP-SLV-001',
            'stock', 25
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'AudioPro',
        'warranty_months', 24,
        'category', 'Audio',
        'tags', array['premium', 'wireless']
    )
WHERE name = 'Premium Wireless Headphones';
```

Update 3 more products with JSONB data:
```
Product 1: _________________________________
Product 2: _________________________________
Product 3: _________________________________
```

---

## Exercise 5.3: Query JSONB Data

**1. Get products with specific attribute**:
```sql
SELECT 
    name,
    attributes->>'color' AS color,
    attributes->>'battery_life' AS battery
FROM products
WHERE attributes @> '{"noise_cancellation": "Active"}'::jsonb;
```

**2. Get products by brand**:
```sql
_________________________________
_________________________________
```

**3. Get products with specific tag**:
```sql
_________________________________
_________________________________
```

**4. Unnest variants**:
```sql
_________________________________
_________________________________
```

---

## Exercise 5.4: Index JSONB

**1. Create GIN index on attributes**:
```sql
CREATE INDEX idx_products_attributes_gin ON products USING gin(attributes);
```

**2. Create path-specific indexes**:
```sql
CREATE INDEX idx_products_brand ON products ((metadata->>'brand'));
CREATE INDEX idx_products_category ON products ((metadata->>'category'));
```

**3. Explain query to verify index usage**:
```sql
EXPLAIN ANALYZE
SELECT * FROM products WHERE metadata->>'brand' = 'AudioPro';
```

✅ **Check**: Verify the query uses the index.

---

## Exercise 5.5: Enable Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- Verify installation
SELECT * FROM pg_extension WHERE extname IN ('pg_trgm', 'btree_gin');
```

---

## Exercise 5.6: Fuzzy Search

**1. Create trigram indexes**:
```sql
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_description_trgm ON products USING gin(description gin_trgm_ops);
```

**2. Calculate similarity**:
```sql
SELECT 
    name,
    similarity(name, 'wireless headphone') AS similarity_score
FROM products
ORDER BY similarity_score DESC;
```

**3. Fuzzy search query**:
```sql
SELECT * FROM products
WHERE similarity(name, 'wireless headphone') > 0.3
ORDER BY similarity(name, 'wireless headphone') DESC;
```

---

## Exercise 5.7: Full-Text Search

**1. Add search vector column**:
```sql
ALTER TABLE products ADD COLUMN search_vector tsvector;
```

**2. Update search vectors**:
```sql
UPDATE products 
SET search_vector = 
    setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'brand', '')), 'C');
```

**3. Create GIN index**:
```sql
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);
```

**4. Full-text search query**:
```sql
SELECT 
    name,
    ts_rank_cd(search_vector, plainto_tsquery('wireless headphones')) AS rank
FROM products
WHERE search_vector @@ plainto_tsquery('wireless headphones')
ORDER BY rank DESC;
```

---

## Challenge Exercise 5.8: Hybrid Search

Create a hybrid search function that combines full-text and fuzzy search:

```sql
CREATE OR REPLACE FUNCTION hybrid_search(search_term TEXT)
RETURNS TABLE(
    name VARCHAR,
    price NUMERIC,
    relevance_score FLOAT,
    match_type TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Your implementation here
    _________________________________
    _________________________________
    _________________________________
END;
$$ LANGUAGE plpgsql;
```

---

## Reflection Questions

1. When would you use JSONB vs a relational table?
   ```
   _________________________________________________
   _________________________________________________
   ```

2. What are the performance implications of JSONB indexing?
   ```
   _________________________________________________
   _________________________________________________
   ```

3. How does fuzzy search differ from full-text search?
   ```
   _________________________________________________
   _________________________________________________
   ```

---

# PART 6: PERFORMANCE, TRANSACTIONS & SERVERLESS WORKFLOWS

## Objectives
- Analyze query performance with EXPLAIN ANALYZE
- Create advanced indexes
- Implement ACID transactions
- Build inventory reservation system
- Set up CI/CD with Neon branches

## Exercise 6.1: Analyze Query Performance

**1. Run EXPLAIN ANALYZE on a slow query**:
```sql
EXPLAIN ANALYZE
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```

**2. Identify the bottleneck**:
```
_________________________________
_________________________________
```

**3. Create an index to improve performance**:
```sql
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

**4. Re-run EXPLAIN ANALYZE and compare**:
```
_________________________________
_________________________________
```

---

## Exercise 6.2: Create Advanced Indexes

**1. Composite index**:
```sql
CREATE INDEX idx_orders_user_status_date ON orders(user_id, status, order_date DESC);
```

**2. Partial index**:
```sql
CREATE INDEX idx_orders_active ON orders(order_date) 
WHERE status NOT IN ('cancelled', 'refunded');
```

**3. Covering index**:
```sql
CREATE INDEX idx_orders_covering ON orders(user_id, order_date) 
INCLUDE (total, status);
```

---

## Exercise 6.3: Transaction Practice

**1. Simple transaction**:
```sql
BEGIN;
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE id = 1;
INSERT INTO order_items (order_id, product_id, quantity, unit_price) 
VALUES ('order-uuid', 1, 1, 99.99);
COMMIT;
```

**2. Transaction with rollback**:
```sql
BEGIN;
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE id = 1;
-- Simulate an error
-- ROLLBACK;
```

**3. Transaction with savepoint**:
```sql
BEGIN;
INSERT INTO orders (...) VALUES (...);
SAVEPOINT before_items;
INSERT INTO order_items (...) VALUES (...);
-- Oops, something went wrong
ROLLBACK TO SAVEPOINT before_items;
-- Continue with something else
COMMIT;
```

---

## Exercise 6.4: Inventory Reservation

**1. Create inventory table**:
```sql
CREATE TABLE IF NOT EXISTS inventory (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 0,
    reserved_quantity INTEGER NOT NULL DEFAULT 0,
    reorder_point INTEGER NOT NULL DEFAULT 10,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_quantity CHECK (quantity >= 0),
    CONSTRAINT sufficient_stock CHECK (quantity >= reserved_quantity)
);

-- Insert initial inventory
INSERT INTO inventory (product_id, quantity, reorder_point)
SELECT id, stock_quantity, 10 FROM products;
```

**2. Create reserve_inventory function**:
```sql
CREATE OR REPLACE FUNCTION reserve_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_available INTEGER;
BEGIN
    SELECT quantity - reserved_quantity INTO v_available
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    IF v_available < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock';
    END IF;
    
    UPDATE inventory 
    SET reserved_quantity = reserved_quantity + p_quantity
    WHERE product_id = p_product_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

**3. Test the function**:
```sql
SELECT reserve_inventory(1, 1);
```

---

## Exercise 6.5: Complete Checkout Function

Create a function that:
- Creates an order
- Reserves inventory for each item
- Inserts order items
- Commits or rolls back as needed

```sql
CREATE OR REPLACE FUNCTION checkout_order(
    p_user_id UUID,
    p_items JSONB
)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
BEGIN
    BEGIN
        -- Create order
        INSERT INTO orders (user_id, shipping_address_id, billing_address_id, order_number, total)
        VALUES (p_user_id, NULL, NULL, 'ORD-' || EXTRACT(EPOCH FROM NOW())::text, 0)
        RETURNING id INTO v_order_id;
        
        -- Process items
        FOR item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            PERFORM reserve_inventory(
                (item->>'product_id')::INTEGER,
                (item->>'quantity')::INTEGER
            );
            
            INSERT INTO order_items (
                order_id, product_id, product_name, unit_price, quantity, 
                line_subtotal, line_tax, line_total
            )
            SELECT 
                v_order_id,
                p.id,
                p.name,
                p.price,
                (item->>'quantity')::INTEGER,
                p.price * (item->>'quantity')::INTEGER,
                p.price * (item->>'quantity')::INTEGER * 0.08,
                p.price * (item->>'quantity')::INTEGER * 1.08
            FROM products p
            WHERE p.id = (item->>'product_id')::INTEGER;
        END LOOP;
        
        -- Update order total
        UPDATE orders 
        SET total = (
            SELECT SUM(line_total) FROM order_items WHERE order_id = v_order_id
        )
        WHERE id = v_order_id;
        
        COMMIT;
        RETURN v_order_id;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;
```

---

## Exercise 6.6: CI/CD Workflow Setup

**1. Create .github/workflows/deploy.yml**:
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
          echo "BRANCH_NAME=$BRANCH_NAME" >> $GITHUB_ENV
      
      - name: Run Migrations
        run: |
          CONN_STRING=$(neonctl branches get-connection-string $BRANCH_NAME)
          psql "$CONN_STRING" -f migrations/*.sql
      
      - name: Run Tests
        run: |
          export DATABASE_URL=$(neonctl branches get-connection-string $BRANCH_NAME)
          npm test
```

**2. Add GitHub secrets**:
- NEON_PROJECT_ID
- NEON_API_KEY
- DATABASE_URL

---

## Exercise 6.7: Monitoring Setup

**1. Create a health check view**:
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

**2. Query health check**:
```sql
SELECT * FROM database_health;
```

**3. Create alert for slow queries**:
```sql
-- Log slow queries (over 5 seconds)
CREATE TABLE slow_query_log (
    id BIGSERIAL PRIMARY KEY,
    pid INTEGER,
    username TEXT,
    query_text TEXT,
    duration_seconds INTEGER,
    logged_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

---

## Challenge Exercise 6.8: Production Readiness

Complete the production readiness check:

**1. Check all extensions are installed**:
```sql
SELECT extname FROM pg_extension WHERE extname IN ('uuid-ossp', 'pg_trgm', 'btree_gin');
```
✅ Complete? ⬜

**2. Check all indexes are created**:
```sql
SELECT indexname FROM pg_indexes WHERE tablename IN ('users', 'products', 'orders', 'order_items');
```
✅ Complete? ⬜

**3. Check foreign keys exist**:
```sql
SELECT conname FROM pg_constraint WHERE contype = 'f';
```
✅ Complete? ⬜

**4. Check sample data exists**:
```sql
SELECT 
    (SELECT COUNT(*) FROM users) AS users,
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM orders) AS orders;
```
✅ Complete? ⬜

**5. Check JSONB data exists**:
```sql
SELECT COUNT(*) FROM products WHERE attributes <> '{}'::jsonb;
```
✅ Complete? ⬜

**6. Check search capabilities**:
```sql
SELECT COUNT(*) FROM products WHERE search_vector IS NOT NULL;
```
✅ Complete? ⬜

---

## Reflection Questions

1. What is the most important factor in query performance?
   ```
   _________________________________________________
   _________________________________________________
   ```

2. Why is the inventory reservation function wrapped in a transaction?
   ```
   _________________________________________________
   _________________________________________________
   ```

3. How does Neon's branching change the CI/CD workflow?
   ```
   _________________________________________________
   _________________________________________________
   ```

4. What will you do differently in your next database project?
   ```
   _________________________________________________
   _________________________________________________
   ```

---

# FINAL PROJECT: COMPLETE E-COMMERCE BACKEND

## Project Overview

Build a complete e-commerce backend using all the skills you've learned. This project will be your portfolio piece demonstrating your ability to design, implement, and deploy a production-ready application with Neon PostgreSQL.

## Requirements

### Database Design (40 points)
- [ ] Users table with UUID, constraints, validation
- [ ] Products table with JSONB attributes
- [ ] Addresses table with foreign keys
- [ ] Orders table with foreign keys
- [ ] Order items table with denormalized data
- [ ] Inventory table with reservation
- [ ] Proper indexes on all tables
- [ ] Soft delete implemented
- [ ] Automatic timestamps with triggers
- [ ] RLS policies for data security

### Data (20 points)
- [ ] At least 20 sample products with JSONB data
- [ ] At least 5 sample users with different roles
- [ ] At least 10 sample orders
- [ ] At least 30 sample order items
- [ ] Realistic inventory data
- [ ] Seed script for all data

### Queries & Analytics (20 points)
- [ ] Product search with filters (category, price, text)
- [ ] Order history for a user
- [ ] Customer lifetime value report
- [ ] Monthly sales dashboard
- [ ] Inventory status report (low stock, out of stock)
- [ ] Top 5 selling products

### Performance & Operations (20 points)
- [ ] All queries optimized with EXPLAIN ANALYZE
- [ ] Appropriate indexes for all common queries
- [ ] Migration script for all tables
- [ ] Rollback script for migrations
- [ ] Health check view
- [ ] Documentation for deployment

## Submission Checklist

- [ ] All SQL scripts (schema, seed, migrations)
- [ ] Complete database design documentation
- [ ] Query examples for all requirements
- [ ] EXPLAIN ANALYZE output for optimized queries
- [ ] README with setup instructions
- [ ] Neon project exported (if possible)

## Submission Instructions

1. Create a GitHub repository
2. Add all your SQL scripts
3. Add a README with:
   - Project overview
   - Setup instructions
   - Query examples
   - Schema diagram
4. Submit the repository link

---

# APPENDIX: SQL CHEAT SHEET

## SELECT
```sql
SELECT columns FROM table WHERE condition GROUP BY columns HAVING condition ORDER BY columns LIMIT n OFFSET m;
```

## INSERT
```sql
INSERT INTO table (columns) VALUES (values);
INSERT INTO table (columns) VALUES (values), (values);
```

## UPDATE
```sql
UPDATE table SET column = value WHERE condition;
```

## DELETE
```sql
DELETE FROM table WHERE condition;
```

## JOINs
```sql
INNER JOIN table ON condition
LEFT JOIN table ON condition
RIGHT JOIN table ON condition
FULL JOIN table ON condition
```

## Aggregates
```sql
COUNT(), SUM(), AVG(), MIN(), MAX()
```

## Window Functions
```sql
ROW_NUMBER() OVER (PARTITION BY column ORDER BY column)
RANK() OVER (ORDER BY column)
LAG(column) OVER (ORDER BY column)
```

## JSONB Operators
```sql
-> (get JSON)
->> (get text)
@> (contains)
? (key exists)
```

## Transaction
```sql
BEGIN;
COMMIT;
ROLLBACK;
SAVEPOINT name;
ROLLBACK TO SAVEPOINT name;
```

---

# GLOSSARY

**ACID**: Atomicity, Consistency, Isolation, Durability - properties of reliable transactions

**Branch**: A copy of a database in Neon that can be modified independently

**CRUD**: Create, Read, Update, Delete - the four basic database operations

**Foreign Key**: A column that references a primary key in another table

**JSONB**: Binary JSON - PostgreSQL's efficient JSON storage format

**Migration**: A script that changes database schema

**Normalization**: Organizing data to reduce redundancy

**RLS**: Row Level Security - controls which rows a user can see

**Schema**: The structure of a database (tables, columns, constraints)

**Soft Delete**: Marking a record as deleted without physically removing it

**Trigram**: A group of three consecutive characters used for fuzzy search

**UUID**: Universally Unique Identifier - a 128-bit unique identifier

**View**: A stored query that acts like a virtual table

---

## Notes & Additional Space

Use this space for additional notes, questions, or code snippets:

```
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

**Congratulations!** You've completed the Serverless Postgres with Neon: From Zero to Production workbook. You now have a complete e-commerce backend and the skills to build production-ready applications with Neon PostgreSQL.

**Next Steps**:
- Build your frontend with React, Next.js, or your favorite framework
- Add authentication using Neon Auth or your preferred solution
- Deploy to your preferred cloud provider
- Continue learning with the Neon documentation and community

**Keep Building!** 🚀
