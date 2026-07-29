# Serverless Postgres with Neon: From Zero to Production
## Lab Book

### Overview

This lab book contains all hands-on exercises for the course. Each lab builds on the previous ones, guiding you through the complete process of building a production-ready e-commerce backend with Neon PostgreSQL.

---

## TABLE OF CONTENTS

1. [Lab 1.1: Neon Setup & First Connection](#lab11)
2. [Lab 1.2: Create Products Table](#lab12)
3. [Lab 1.3: CRUD Operations](#lab13)
4. [Lab 1.4: Filtering & Sorting](#lab14)
5. [Lab 2.1: Users Table with UUIDs](#lab21)
6. [Lab 2.2: Data Validation Constraints](#lab22)
7. [Lab 2.3: Soft Delete & Timestamps](#lab23)
8. [Lab 3.1: Neon Branching](#lab31)
9. [Lab 3.2: Addresses & Orders](#lab32)
10. [Lab 3.3: JOIN Queries](#lab33)
11. [Lab 4.1: Aggregations & Grouping](#lab41)
12. [Lab 4.2: Window Functions](#lab42)
13. [Lab 5.1: JSONB Data](#lab51)
14. [Lab 5.2: Search Implementation](#lab52)
15. [Lab 6.1: Performance Optimization](#lab61)
16. [Lab 6.2: Transactions & Inventory](#lab62)
17. [Lab 6.3: CI/CD with GitHub Actions](#lab63)
18. [Final Project: Complete E-Commerce Backend](#final-project)

---

## LAB 1.1: NEON SETUP & FIRST CONNECTION {#lab11}

### Objectives
- Create a Neon account and project
- Install psql and Neon CLI
- Connect to your Neon database
- Verify the connection

### Pre-Lab Setup

**1. Create Neon Account**
- Go to https://neon.tech
- Sign up with GitHub (recommended) or email
- Verify your email if required

**2. Create a Project**
- Click "Create a Project"
- Name: `ecommerce-workshop`
- Region: Choose closest to you
- Click "Create Project"

**3. Save Connection String**
- On the project dashboard, click "Connect"
- Copy the connection string (pooled recommended):
```
postgresql://username:password@ep-xyz-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&pool_mode=transaction
```
- Save this somewhere secure

### Step 1: Install psql

**macOS:**
```bash
brew install postgresql@16
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql-client
```

**Windows:**
Download from https://www.postgresql.org/download/windows/

**Verify Installation:**
```bash
psql --version
```

### Step 2: Install Neon CLI

```bash
npm install -g neonctl
neonctl auth
neonctl --version
```

### Step 3: Test Connection

**Using psql:**
```bash
psql "your-connection-string-here"
```

**Expected Output:**
```
psql (16.1)
SSL connection (protocol: TLSv1.3, cipher: ...)
Type "help" for help.

neondb=>
```

**Test Query:**
```sql
SELECT version();
SELECT current_database();
SELECT current_user;
```

### Step 4: Verify Neon CLI

```bash
neonctl projects list
```

**Expected Output:**
```
┌─────────────────────┬─────────────┬──────────────────────┐
│ Name                │ ID          │ Region               │
├─────────────────────┼─────────────┼──────────────────────┤
│ ecommerce-workshop  │ proj-xxx   │ aws-us-east-1        │
└─────────────────────┴─────────────┴──────────────────────┘
```

### Step 5: Connection Details

**Write your connection details:**
```
Project Name: _________________________________

Connection String:
_________________________________

Project ID: _________________________________
```

### Verification Checklist

- [ ] Neon account created
- [ ] Project created
- [ ] psql installed
- [ ] Neon CLI installed
- [ ] Connected successfully
- [ ] Ran test queries

### Troubleshooting

**Issue: psql not found**
```
Solution: Install PostgreSQL client or add to PATH
```

**Issue: Connection refused**
```
Solution: Check connection string, ensure SSL mode is require
```

**Issue: Authentication failed**
```
Solution: Verify username and password, copy exactly
```

---

## LAB 1.2: CREATE PRODUCTS TABLE {#lab12}

### Objectives
- Create a products table with proper data types
- Verify table structure
- Insert sample data

### Step 1: Connect to Database

```bash
psql "your-connection-string-here"
```

### Step 2: Create Products Table

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

**Check the table:**
```sql
\d products
```

### Step 3: Insert Sample Products

```sql
INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Premium Wireless Headphones', 
     'Studio-quality sound with active noise cancellation and 40-hour battery life', 
     149.99, 84),
    
    ('4K Action Camera Pro', 
     'Professional-grade action camera with 4K 60fps recording and stabilization', 
     349.99, 32),
    
    ('Smart Health Tracker', 
     'Advanced health monitoring with ECG, blood oxygen, and sleep tracking', 
     249.00, 56),
    
    ('Universal Laptop Docking Station', 
     '8-in-1 docking station with dual 4K HDMI and 100W power delivery', 
     169.50, 19),
    
    ('Mechanical Gaming Keyboard Pro', 
     'Wireless mechanical keyboard with hot-swappable switches and RGB backlight', 
     159.99, 48),
    
    ('Ergonomic Wireless Mouse', 
     'Sculpted ergonomic mouse with programmable buttons and Qi charging', 
     89.95, 107),
    
    ('Solar-Powered Power Bank', 
     '30000mAh solar power bank with wireless charging and built-in flashlight', 
     99.99, 41),
    
    ('Professional Studio Microphone', 
     'Cardioid condenser microphone with shock mount and pop filter', 
     199.00, 14);
```

### Step 4: Verify Data

```sql
-- Count products
SELECT COUNT(*) FROM products;

-- View all products
SELECT * FROM products;

-- View specific columns
SELECT id, name, price, stock_quantity FROM products;
```

### Lab Check

**Answer these questions:**

1. How many products did you insert? _______

2. What is the average price of your products?
   ```sql
   -- Write the query here:
   
   ```

3. Which product has the highest price?
   ```sql
   -- Write the query here:
   
   ```

---

## LAB 1.3: CRUD OPERATIONS {#lab13}

### Objectives
- Practice all CRUD operations
- Understand INSERT, SELECT, UPDATE, DELETE
- Work with different data types

### Step 1: INSERT (Create)

**Insert a single product:**
```sql
INSERT INTO products (name, description, price, stock_quantity)
VALUES (
    'Smart Home Display',
    '7-inch smart display with voice control and home automation',
    229.99, 55
);
```

**Insert multiple products:**
```sql
INSERT INTO products (name, price, stock_quantity) VALUES
    ('Noise Cancelling Earbuds', 149.99, 120),
    ('Ultra-HD Webcam', 129.99, 72),
    ('Portable External SSD', 219.99, 28);
```

### Step 2: SELECT (Read)

**Read all products:**
```sql
SELECT * FROM products;
```

**Read specific columns:**
```sql
SELECT id, name, price FROM products;
```

**Read with condition:**
```sql
SELECT * FROM products WHERE price > 100;
SELECT * FROM products WHERE stock_quantity < 30;
SELECT * FROM products WHERE name LIKE '%Wireless%';
```

**Read with sorting:**
```sql
SELECT * FROM products ORDER BY price DESC;
SELECT * FROM products ORDER BY name ASC;
```

**Read with limit:**
```sql
SELECT * FROM products LIMIT 5;
SELECT * FROM products ORDER BY price LIMIT 3;
```

### Step 3: UPDATE

**Update a single product:**
```sql
UPDATE products 
SET price = 159.99 
WHERE name = 'Premium Wireless Headphones';
```

**Update multiple fields:**
```sql
UPDATE products 
SET 
    price = 249.99,
    stock_quantity = 45
WHERE name = '4K Action Camera Pro';
```

**Update with calculation:**
```sql
UPDATE products 
SET price = price * 1.10 
WHERE price < 100;
```

### Step 4: DELETE

**Delete a specific product:**
```sql
-- First, check what you're deleting
SELECT * FROM products WHERE id = 5;

-- Then delete
DELETE FROM products WHERE id = 5;
```

**Safe deletion practice:**
```sql
-- Check
SELECT * FROM products WHERE stock_quantity = 0;

-- Delete if confirmed
-- DELETE FROM products WHERE stock_quantity = 0;
```

### Lab Check

**Complete these tasks:**

1. Insert a product you invented:
   ```sql
   
   ```

2. Update the price of the product you inserted:
   ```sql
   
   ```

3. Find all products with "Pro" in the name:
   ```sql
   
   ```

4. Delete the product you inserted:
   ```sql
   
   ```

---

## LAB 1.4: FILTERING & SORTING {#lab14}

### Objectives
- Master WHERE clause
- Use LIKE and ILIKE for pattern matching
- Practice ORDER BY and LIMIT

### Step 1: WHERE Clause Practice

**Equality:**
```sql
-- Products with exact price
SELECT * FROM products WHERE price = 199.00;

-- Products in stock
SELECT * FROM products WHERE stock_quantity > 0;
```

**Range:**
```sql
-- Products between $100 and $200
SELECT * FROM products WHERE price BETWEEN 100 AND 200;

-- Products with stock between 20 and 80
SELECT * FROM products WHERE stock_quantity BETWEEN 20 AND 80;
```

**Multiple conditions:**
```sql
-- Products with price > 100 AND in stock
SELECT * FROM products 
WHERE price > 100 AND stock_quantity > 0;

-- Products with price < 50 OR stock > 100
SELECT * FROM products 
WHERE price < 50 OR stock_quantity > 100;
```

### Step 2: Pattern Matching

**LIKE (case-sensitive):**
```sql
-- Starts with 'P'
SELECT * FROM products WHERE name LIKE 'P%';

-- Ends with 'r'
SELECT * FROM products WHERE name LIKE '%r';

-- Contains 'Pro'
SELECT * FROM products WHERE name LIKE '%Pro%';
```

**ILIKE (case-insensitive):**
```sql
-- Contains 'wireless' (any case)
SELECT * FROM products WHERE name ILIKE '%wireless%';

-- Starts with 's' (any case)
SELECT * FROM products WHERE name ILIKE 's%';
```

### Step 3: ORDER BY

```sql
-- Cheapest first
SELECT * FROM products ORDER BY price ASC;

-- Most expensive first
SELECT * FROM products ORDER BY price DESC;

-- Most stock first
SELECT * FROM products ORDER BY stock_quantity DESC;

-- Multiple sorting
SELECT * FROM products 
ORDER BY price DESC, name ASC;
```

### Step 4: LIMIT & Pagination

```sql
-- First 5 products
SELECT * FROM products LIMIT 5;

-- Top 5 cheapest
SELECT * FROM products ORDER BY price LIMIT 5;

-- Top 5 most expensive
SELECT * FROM products ORDER BY price DESC LIMIT 5;

-- Pagination: page 2 (rows 6-10)
SELECT * FROM products ORDER BY id LIMIT 5 OFFSET 5;

-- Page 3 (rows 11-15)
SELECT * FROM products ORDER BY id LIMIT 5 OFFSET 10;
```

### Step 5: Combined Query

```sql
-- Expensive products with low stock
SELECT 
    id, name, price, stock_quantity
FROM products
WHERE price > 100 
  AND stock_quantity < 30
ORDER BY price DESC
LIMIT 5;
```

### Lab Check

**Write queries for:**

1. Products that start with 'S':
   ```sql
   
   ```

2. Products with price between $50 and $150, sorted by price:
   ```sql
   
   ```

3. Products with 'wireless' in the description (case-insensitive):
   ```sql
   
   ```

4. The 3 cheapest products in stock:
   ```sql
   
   ```

---

## LAB 2.1: USERS TABLE WITH UUIDS {#lab21}

### Objectives
- Enable UUID extension
- Create users table with UUID primary key
- Understand UUID vs SERIAL

### Step 1: Enable UUID Extension

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Verify
SELECT * FROM pg_extension WHERE extname = 'uuid-ossp';

-- Test UUID generation
SELECT gen_random_uuid();
SELECT uuid_generate_v4();
```

### Step 2: Create Users Table

```sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    role VARCHAR(20) NOT NULL DEFAULT 'customer',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);
```

**Check the table:**
```sql
\d users
```

### Step 3: Insert Sample Users

```sql
INSERT INTO users (email, username, password_hash, full_name, phone, role, status) VALUES
    ('alice.admin@company.com', 'alice_admin', 'hash_placeholder', 'Alice Johnson', '+1-555-0101', 'admin', 'active'),
    ('bob.staff@company.com', 'bob_staff', 'hash_placeholder', 'Bob Smith', '+1-555-0102', 'staff', 'active'),
    ('carol.customer@example.com', 'carol_customer', 'hash_placeholder', 'Carol Williams', '+1-555-0103', 'customer', 'active'),
    ('david.customer@example.com', 'david_customer', 'hash_placeholder', 'David Brown', '+1-555-0104', 'customer', 'inactive'),
    ('eve.customer@example.com', 'eve_customer', 'hash_placeholder', 'Eve Davis', '+1-555-0105', 'customer', 'suspended');
```

### Step 4: Verify Data

```sql
-- View all users
SELECT id, email, username, full_name, role, status, created_at 
FROM users;

-- Count by role
SELECT role, COUNT(*) FROM users GROUP BY role;
```

### Lab Check

**Answer these questions:**

1. How many users did you create? _______

2. What is the format of the UUID? (Write one example)
   ```
   
   ```

3. Why use UUID instead of SERIAL for user IDs?
   ```
   
   ```

---

## LAB 2.2: DATA VALIDATION CONSTRAINTS {#lab22}

### Objectives
- Add CHECK constraints for validation
- Test constraints with invalid data
- Enforce business rules

### Step 1: Add Email Validation

```sql
ALTER TABLE users ADD CONSTRAINT valid_email 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

**Pattern Explanation:**
```
^               = Start of string
[A-Za-z0-9._%+-]+ = Local part (one or more)
@               = Literal @ symbol
[A-Za-z0-9.-]+  = Domain part
\.              = Literal dot
[A-Za-z]{2,}    = Top-level domain (2+ letters)
$               = End of string
```

### Step 2: Add Username Validation

```sql
ALTER TABLE users ADD CONSTRAINT valid_username 
CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$');
```

**Pattern Explanation:**
```
^               = Start of string
[A-Za-z]        = First character must be a letter
[A-Za-z0-9_]{2,49} = 2-49 letters, numbers, underscores
$               = End of string
```

### Step 3: Add Status and Role Validation

```sql
ALTER TABLE users ADD CONSTRAINT valid_status 
CHECK (status IN ('active', 'inactive', 'suspended'));

ALTER TABLE users ADD CONSTRAINT valid_role 
CHECK (role IN ('customer', 'staff', 'admin'));
```

### Step 4: Test Constraints

**Test 1: Invalid Email**
```sql
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('invalid-email', 'testuser', 'hash', 'Test User');
-- Should FAIL
```

**Test 2: Invalid Username**
```sql
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('test@example.com', '1test', 'hash', 'Test User');
-- Should FAIL
```

**Test 3: Valid User**
```sql
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('valid@example.com', 'valid_user', 'hash', 'Valid User');
-- Should SUCCEED
```

### Lab Check

**Record the error messages:**

1. Invalid email error:
   ```
   
   ```

2. Invalid username error:
   ```
   
   ```

3. What happens if you try to set status to 'invalid'?
   ```
   
   ```

---

## LAB 2.3: SOFT DELETE & TIMESTAMPS {#lab23}

### Objectives
- Implement automatic timestamp updates
- Implement soft delete pattern
- Create active users view

### Step 1: Automatic Timestamps

**Create the function:**
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';
```

**Create the trigger:**
```sql
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

**Test the trigger:**
```sql
UPDATE users SET full_name = 'Alice Johnson (Updated)' WHERE email = 'alice.admin@company.com';

SELECT email, full_name, created_at, updated_at 
FROM users WHERE email = 'alice.admin@company.com';
```

### Step 2: Soft Delete

**Soft delete a user:**
```sql
UPDATE users 
SET deleted_at = CURRENT_TIMESTAMP 
WHERE email = 'david.customer@example.com';
```

**Query active users:**
```sql
SELECT * FROM users WHERE deleted_at IS NULL;
```

**Query deleted users:**
```sql
SELECT * FROM users WHERE deleted_at IS NOT NULL;
```

### Step 3: Create Active Users View

```sql
CREATE VIEW active_users AS
SELECT 
    id, email, username, full_name, phone, 
    role, status, created_at, updated_at
FROM users
WHERE deleted_at IS NULL;
```

**Test the view:**
```sql
SELECT * FROM active_users;
SELECT COUNT(*) FROM active_users;
```

### Lab Check

**Answer these questions:**

1. How many active users are there? _______

2. What happens to updated_at when you update a user?
   ```
   
   ```

3. How does soft delete differ from actual deletion?
   ```
   
   ```

---

## LAB 3.1: NEON BRANCHING {#lab31}

### Objectives
- Create a Neon development branch
- Connect to the branch
- Make changes in isolation
- Merge changes back

### Step 1: Create a Branch

**Using CLI:**
```bash
neonctl branches create --name dev-branch --parent main --project-id YOUR_PROJECT_ID
```

**Using Console:**
1. Go to Neon Console
2. Click "Branches"
3. Click "Create Branch"
4. Name: `dev-branch`
5. Parent: `main`
6. Click "Create"

### Step 2: Get Branch Connection String

**Using CLI:**
```bash
neonctl branches get-connection-string dev-branch --project-id YOUR_PROJECT_ID
```

**Using Console:**
1. Go to Branches
2. Click on `dev-branch`
3. Copy connection string

### Step 3: Connect to Dev Branch

```bash
psql "your-dev-branch-connection-string"
```

**Verify:**
```sql
SELECT current_database();
SELECT current_user;
-- Check if your products table exists
SELECT COUNT(*) FROM products;
```

### Step 4: Make Changes on Dev Branch

```sql
-- Add a new table only on dev branch
CREATE TABLE wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_product UNIQUE (user_id, product_id)
);

-- Insert sample data
INSERT INTO wishlists (user_id, product_id)
SELECT id, 1 FROM users LIMIT 1;
```

### Step 5: Verify Branch Isolation

**On dev branch:**
```sql
SELECT * FROM wishlists;
-- Should show data
```

**Connect to main branch:**
```bash
psql "your-main-connection-string"
```

**Check main branch:**
```sql
SELECT * FROM wishlists;
-- Should show error: relation "wishlists" does not exist
```

### Step 6: Merge Branch

**Merge dev to main:**
```bash
neonctl branches merge dev-branch --target main --project-id YOUR_PROJECT_ID
```

**Verify on main:**
```bash
psql "your-main-connection-string"
```

```sql
SELECT * FROM wishlists;
-- Should now exist!
```

### Lab Check

**Answer these questions:**

1. How long did it take to create the branch? _______

2. What changes were isolated on dev branch?
   ```
   
   ```

3. Why is branching useful?
   ```
   
   ```

---

## LAB 3.2: ADDRESSES & ORDERS {#lab32}

### Objectives
- Create addresses table with foreign key
- Create orders table
- Create order_items table
- Understand foreign key relationships

### Step 1: Create Addresses Table

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
```

**Create indexes:**
```sql
CREATE INDEX idx_addresses_user_id ON addresses(user_id) WHERE deleted_at IS NULL;
```

### Step 2: Create Orders Table

```sql
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    shipping_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    billing_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
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
    CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    CONSTRAINT valid_payment_status CHECK (payment_status IN ('pending', 'authorized', 'paid', 'failed', 'refunded')),
    CONSTRAINT positive_total CHECK (total >= 0)
);
```

### Step 3: Create Order Items Table

```sql
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    line_subtotal NUMERIC(10,2) NOT NULL,
    line_tax NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    line_total NUMERIC(10,2) NOT NULL,
    product_attributes JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_unit_price CHECK (unit_price >= 0)
);
```

### Step 4: Insert Sample Data

**Insert addresses:**
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
WHERE email IN ('alice.admin@company.com', 'bob.staff@company.com', 'carol.customer@example.com');
```

**Insert orders:**
```sql
INSERT INTO orders (
    user_id, shipping_address_id, billing_address_id, order_number,
    subtotal, tax, shipping_cost, discount, total,
    payment_method, payment_status, status, shipping_method
)
SELECT 
    u.id,
    a.id,
    a.id,
    'ORD-2024-001',
    149.99, 12.00, 5.99, 0.00, 167.98,
    'credit_card', 'paid', 'completed', 'UPS Ground'
FROM users u
JOIN addresses a ON u.id = a.user_id
WHERE u.email = 'alice.admin@company.com'
LIMIT 1;
```

### Lab Check

**Answer these questions:**

1. What is the relationship between users and addresses?
   ```
   
   ```

2. What does ON DELETE RESTRICT mean?
   ```
   
   ```

3. Why does order_items store product_name and unit_price?
   ```
   
   ```

---

## LAB 3.3: JOIN QUERIES {#lab33}

### Objectives
- Write INNER JOIN queries
- Write LEFT JOIN queries
- Write complex multi-table JOINs

### Step 1: INNER JOIN

```sql
-- Orders with user names
SELECT 
    o.order_number,
    u.full_name AS customer,
    o.total,
    o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.id;
```

```sql
-- Orders with shipping addresses
SELECT 
    o.order_number,
    a.address_line1,
    a.city,
    a.state
FROM orders o
INNER JOIN addresses a ON o.shipping_address_id = a.id;
```

### Step 2: LEFT JOIN

```sql
-- All users with their orders (including users with no orders)
SELECT 
    u.full_name,
    o.order_number,
    o.total
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

```sql
-- Find users without orders
SELECT 
    u.full_name,
    u.email
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.id IS NULL;
```

### Step 3: Multiple JOINs

```sql
-- Complete order details
SELECT 
    o.order_number,
    u.full_name AS customer,
    a.address_line1 AS shipping_address,
    a.city AS shipping_city,
    oi.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN addresses a ON o.shipping_address_id = a.id
JOIN order_items oi ON o.id = oi.order_id;
```

### Step 4: Aggregations with Joins

```sql
-- Total spent per customer
SELECT 
    u.full_name,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent,
    AVG(o.total) AS avg_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC NULLS LAST;
```

### Lab Check

**Write these queries:**

1. Get all orders with customer names and order totals:
   ```sql
   
   ```

2. Find customers who haven't placed any orders:
   ```sql
   
   ```

3. Get order details with product names and quantities:
   ```sql
   
   ```

4. Find the top customer by total spending:
   ```sql
   
   ```

---

## LAB 4.1: AGGREGATIONS & GROUPING {#lab41}

### Objectives
- Use aggregate functions
- Group data with GROUP BY
- Filter groups with HAVING

### Step 1: Basic Aggregates

```sql
-- Count total products
SELECT COUNT(*) FROM products;

-- Average price
SELECT AVG(price) FROM products;

-- Total stock value
SELECT SUM(price * stock_quantity) FROM products;

-- Min and max prices
SELECT MIN(price), MAX(price) FROM products;
```

### Step 2: GROUP BY

```sql
-- Count by status
SELECT 
    status,
    COUNT(*) AS count
FROM orders
GROUP BY status;
```

```sql
-- Revenue by payment method
SELECT 
    payment_method,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order
FROM orders
GROUP BY payment_method
ORDER BY revenue DESC;
```

```sql
-- Monthly revenue
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;
```

### Step 3: HAVING

```sql
-- Customers with more than 1 order
SELECT 
    user_id,
    COUNT(*) AS order_count,
    SUM(total) AS total_spent
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 1;
```

```sql
-- Payment methods with average > $100
SELECT 
    payment_method,
    AVG(total) AS avg_order
FROM orders
GROUP BY payment_method
HAVING AVG(total) > 100;
```

### Lab Check

**Write these queries:**

1. Count of orders by status:
   ```sql
   
   ```

2. Total revenue by month:
   ```sql
   
   ```

3. Customers who have spent more than $200:
   ```sql
   
   ```

4. Products sold more than 5 times (using order_items):
   ```sql
   
   ```

---

## LAB 4.2: WINDOW FUNCTIONS {#lab42}

### Objectives
- Use ROW_NUMBER for ranking
- Use RANK and DENSE_RANK
- Use LAG for time series
- Calculate running totals

### Step 1: ROW_NUMBER

```sql
-- Rank products by price
SELECT 
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS price_rank
FROM products;
```

```sql
-- Rank by category (if we had category)
-- Instead, let's rank by price range
SELECT 
    name,
    price,
    CASE 
        WHEN price < 100 THEN 'Budget'
        WHEN price < 200 THEN 'Mid'
        ELSE 'Premium'
    END AS tier,
    ROW_NUMBER() OVER (PARTITION BY 
        CASE 
            WHEN price < 100 THEN 'Budget'
            WHEN price < 200 THEN 'Mid'
            ELSE 'Premium'
        END 
        ORDER BY price DESC) AS rank_in_tier
FROM products;
```

### Step 2: RANK and DENSE_RANK

```sql
-- Compare RANK vs DENSE_RANK
SELECT 
    name,
    price,
    RANK() OVER (ORDER BY price DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank
FROM products;
```

### Step 3: LAG for Time Series

```sql
-- Month-over-month comparison
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(total) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month) AS previous_month,
    revenue - LAG(revenue, 1) OVER (ORDER BY month) AS change,
    CASE 
        WHEN LAG(revenue, 1) OVER (ORDER BY month) IS NOT NULL 
        THEN ((revenue - LAG(revenue, 1) OVER (ORDER BY month)) / 
              LAG(revenue, 1) OVER (ORDER BY month)) * 100
        ELSE NULL 
    END AS growth_percent
FROM monthly_revenue
ORDER BY month;
```

### Step 4: Running Totals

```sql
-- Running total of orders
SELECT 
    order_date,
    total,
    SUM(total) OVER (ORDER BY order_date) AS running_total
FROM orders
ORDER BY order_date;
```

### Lab Check

**Write these queries:**

1. Rank products by price (most expensive first):
   ```sql
   
   ```

2. Show each order with total and customer running total:
   ```sql
   
   ```

3. Show month-over-month revenue growth:
   ```sql
   
   ```

---

## LAB 5.1: JSONB DATA {#lab51}

### Objectives
- Add JSONB columns
- Store JSONB data
- Query JSONB fields
- Index JSONB data

### Step 1: Add JSONB Columns

```sql
ALTER TABLE products 
ADD COLUMN attributes JSONB DEFAULT '{}'::jsonb,
ADD COLUMN variants JSONB DEFAULT '[]'::jsonb,
ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
```

### Step 2: Update Products with JSONB Data

```sql
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'color', 'Black',
        'connectivity', 'Bluetooth 5.3',
        'battery_life', '40 hours',
        'noise_cancellation', 'Active',
        'weight', '250g',
        'material', 'Memory foam, aluminum'
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
        'release_date', '2024-01-15',
        'category', 'Audio',
        'subcategory', 'Headphones',
        'tags', array['premium', 'wireless', 'noise-cancelling']
    )
WHERE name = 'Premium Wireless Headphones';
```

### Step 3: Update Multiple Products

**For each of 5 products, add JSONB data:**
```sql
UPDATE products 
SET 
    attributes = jsonb_build_object(...),
    variants = jsonb_build_array(...),
    metadata = jsonb_build_object(...)
WHERE name = 'Product Name';
```

### Step 4: Query JSONB Data

```sql
-- Get specific fields
SELECT 
    name,
    attributes->>'color' AS color,
    attributes->>'battery_life' AS battery_life,
    metadata->>'brand' AS brand
FROM products;
```

```sql
-- Filter by JSONB value
SELECT * FROM products 
WHERE attributes @> '{"noise_cancellation": "Active"}'::jsonb;
```

```sql
-- Filter by metadata
SELECT * FROM products 
WHERE metadata->>'brand' = 'AudioPro';
```

```sql
-- Check if key exists
SELECT * FROM products 
WHERE attributes ? 'noise_cancellation';
```

### Step 5: Unnest Variants

```sql
SELECT 
    name,
    v.value->>'color' AS variant_color,
    (v.value->>'price_adjustment')::numeric AS price_adjustment,
    (v.value->>'stock')::int AS stock
FROM products p,
     jsonb_array_elements(p.variants) AS v(value)
WHERE p.variants != '[]'::jsonb;
```

### Step 6: Index JSONB

```sql
-- Create GIN index
CREATE INDEX idx_products_attributes_gin ON products USING gin(attributes);
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- Path-specific indexes
CREATE INDEX idx_products_brand ON products ((metadata->>'brand'));
CREATE INDEX idx_products_category ON products ((metadata->>'category'));
```

### Lab Check

**Answer these questions:**

1. What JSONB data is stored in your products?
   ```
   
   ```

2. Query for products with a specific color:
   ```sql
   
   ```

3. Query for products by brand:
   ```sql
   
   ```

---

## LAB 5.2: SEARCH IMPLEMENTATION {#lab52}

### Objectives
- Enable pg_trgm extension
- Implement fuzzy search
- Implement full-text search
- Create hybrid search

### Step 1: Enable Extensions

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;
```

### Step 2: Create Trigram Indexes

```sql
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_description_trgm ON products USING gin(description gin_trgm_ops);
```

### Step 3: Fuzzy Search

```sql
-- Similarity scores
SELECT 
    name,
    similarity(name, 'wireless headphone') AS similarity_score
FROM products
ORDER BY similarity_score DESC;
```

```sql
-- Fuzzy search with threshold
SELECT * FROM products
WHERE similarity(name, 'wireless headphone') > 0.3
ORDER BY similarity(name, 'wireless headphone') DESC;
```

### Step 4: Full-Text Search

```sql
-- Add search vector
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Update search vectors
UPDATE products 
SET search_vector = 
    setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'brand', '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'category', '')), 'C');

-- Create GIN index
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);
```

```sql
-- Full-text search query
SELECT 
    name,
    ts_rank_cd(search_vector, plainto_tsquery('wireless headphones')) AS rank
FROM products
WHERE search_vector @@ plainto_tsquery('wireless headphones')
ORDER BY rank DESC;
```

### Step 5: Hybrid Search

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
    WITH full_text AS (
        SELECT 
            name, 
            price,
            ts_rank_cd(search_vector, plainto_tsquery(search_term)) AS score
        FROM products
        WHERE search_vector @@ plainto_tsquery(search_term)
    ),
    fuzzy_matches AS (
        SELECT 
            name, 
            price,
            GREATEST(
                similarity(name, search_term),
                similarity(description, search_term)
            ) AS score
        FROM products
        WHERE GREATEST(
            similarity(name, search_term),
            similarity(description, search_term)
        ) > 0.3
    )
    SELECT name, price, score, 'Full-Text' FROM full_text
    UNION ALL
    SELECT name, price, score, 'Fuzzy' FROM fuzzy_matches
    WHERE NOT EXISTS (SELECT 1 FROM full_text ft WHERE ft.name = fuzzy_matches.name)
    ORDER BY relevance_score DESC;
END;
$$ LANGUAGE plpgsql;
```

### Lab Check

**Test the search:**
```sql
SELECT * FROM hybrid_search('wireless headphone');
SELECT * FROM hybrid_search('bluetooth speaker');
SELECT * FROM hybrid_search('camera');
```

---

## LAB 6.1: PERFORMANCE OPTIMIZATION {#lab61}

### Objectives
- Use EXPLAIN ANALYZE
- Create and test indexes
- Identify slow queries

### Step 1: Analyze a Query

```sql
-- Check current performance
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

**Record the execution time:** _______

### Step 2: Create Performance Indexes

```sql
-- Index on status (frequently filtered)
CREATE INDEX idx_orders_status ON orders(status) 
WHERE status NOT IN ('cancelled', 'refunded');

-- Composite index on user_id and status
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Covering index for common query
CREATE INDEX idx_orders_covering ON orders(user_id, status) 
INCLUDE (total, order_date);
```

### Step 3: Re-analyze

```sql
-- Run EXPLAIN ANALYZE again
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

**New execution time:** _______

**Improvement:** _______%

### Step 4: Find Unused Indexes

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

### Step 5: Update Statistics

```sql
ANALYZE orders;
ANALYZE users;
ANALYZE products;
```

### Lab Check

**Answer these questions:**

1. What was the slowest part of the query?
   ```
   
   ```

2. How much did the index improve performance?
   ```
   
   ```

3. What other indexes might be useful?
   ```
   
   ```

---

## LAB 6.2: TRANSACTIONS & INVENTORY {#lab62}

### Objectives
- Implement transactions
- Create inventory reservation
- Handle errors with rollback

### Step 1: Create Inventory Table

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

-- Initialize inventory
INSERT INTO inventory (product_id, quantity, reorder_point)
SELECT id, stock_quantity, 10 FROM products;
```

### Step 2: Create Reservation Function

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
        RAISE EXCEPTION 'Insufficient stock for product % (available: %, requested: %)', 
            p_product_id, v_available, p_quantity;
    END IF;
    
    UPDATE inventory 
    SET reserved_quantity = reserved_quantity + p_quantity
    WHERE product_id = p_product_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

### Step 3: Test Reservation

```sql
-- Test valid reservation
SELECT reserve_inventory(1, 1);

-- Check inventory
SELECT * FROM inventory WHERE product_id = 1;

-- Test invalid reservation (should fail)
SELECT reserve_inventory(1, 9999);
```

### Step 4: Complete Checkout Transaction

```sql
CREATE OR REPLACE FUNCTION complete_checkout(
    p_user_id UUID,
    p_items JSONB  -- Array of {product_id, quantity}
)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
    v_item JSONB;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_subtotal NUMERIC := 0;
    v_total NUMERIC;
BEGIN
    BEGIN
        -- Reserve inventory
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;
            
            PERFORM reserve_inventory(v_product_id, v_quantity);
            
            -- Calculate subtotal
            SELECT price * v_quantity INTO v_subtotal
            FROM products
            WHERE id = v_product_id;
        END LOOP;
        
        -- Create order
        v_total := v_subtotal * 1.08 + 5.99;  -- 8% tax + shipping
        
        INSERT INTO orders (
            user_id, shipping_address_id, billing_address_id, order_number,
            subtotal, tax, shipping_cost, discount, total,
            payment_method, payment_status, status, shipping_method
        ) VALUES (
            p_user_id, NULL, NULL, 
            'ORD-' || EXTRACT(EPOCH FROM NOW())::text,
            v_subtotal, v_subtotal * 0.08, 5.99, 0, v_total,
            'credit_card', 'paid', 'pending', 'UPS Ground'
        )
        RETURNING id INTO v_order_id;
        
        -- Insert order items
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;
            
            INSERT INTO order_items (
                order_id, product_id, product_name, unit_price, quantity,
                line_subtotal, line_tax, line_total
            )
            SELECT 
                v_order_id,
                p.id,
                p.name,
                p.price,
                v_quantity,
                p.price * v_quantity,
                p.price * v_quantity * 0.08,
                p.price * v_quantity * 1.08
            FROM products p
            WHERE p.id = v_product_id;
        END LOOP;
        
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

### Lab Check

**Test the checkout:**
```sql
SELECT * FROM complete_checkout(
    (SELECT id FROM users WHERE email = 'carol.customer@example.com' LIMIT 1),
    '[{"product_id": 1, "quantity": 2}, {"product_id": 3, "quantity": 1}]'::jsonb
);
```

**Check results:**
```sql
SELECT * FROM orders ORDER BY created_at DESC LIMIT 1;
SELECT * FROM order_items WHERE order_id = '<order-id>';
SELECT * FROM inventory WHERE product_id IN (1, 3);
```

---

## LAB 6.3: CI/CD WITH GITHUB ACTIONS {#lab63}

### Objectives
- Create GitHub Actions workflow
- Automate Neon branch creation
- Run migrations in CI/CD

### Step 1: Create Workflow File

Create `.github/workflows/database-ci.yml`:

```yaml
name: Database CI/CD

on:
  pull_request:
    types: [opened, synchronize, reopened]
  push:
    branches: [main]

jobs:
  test-database:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Neon CLI
        run: npm install -g neonctl
      
      - name: Create Preview Branch
        if: github.event_name == 'pull_request'
        run: |
          BRANCH_NAME="preview-${{ github.event.pull_request.number }}"
          neonctl branches create \
            --name $BRANCH_NAME \
            --parent main \
            --project-id ${{ secrets.NEON_PROJECT_ID }}
          echo "BRANCH_NAME=$BRANCH_NAME" >> $GITHUB_ENV
      
      - name: Run Migrations on Preview
        if: github.event_name == 'pull_request'
        run: |
          CONN_STRING=$(neonctl branches get-connection-string $BRANCH_NAME --project-id ${{ secrets.NEON_PROJECT_ID }})
          psql "$CONN_STRING" -f migrations/001_create_users_table.sql
          psql "$CONN_STRING" -f migrations/002_create_ecommerce_tables.sql
      
      - name: Run Tests on Preview
        if: github.event_name == 'pull_request'
        run: |
          export DATABASE_URL=$(neonctl branches get-connection-string $BRANCH_NAME --project-id ${{ secrets.NEON_PROJECT_ID }})
          # Run your test suite here
          echo "Tests passed!"
      
      - name: Clean up Preview Branch
        if: github.event_name == 'pull_request' && (github.event.action == 'closed' || github.event.pull_request.merged == true)
        run: |
          neonctl branches delete $BRANCH_NAME --project-id ${{ secrets.NEON_PROJECT_ID }}
      
      - name: Run Migrations on Main
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          psql "${{ secrets.DATABASE_POOLED_URL }}" -f migrations/001_create_users_table.sql
          psql "${{ secrets.DATABASE_POOLED_URL }}" -f migrations/002_create_ecommerce_tables.sql
      
      - name: Create Production Backup
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        run: |
          BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
          neonctl branches create \
            --name $BACKUP_NAME \
            --parent main \
            --project-id ${{ secrets.NEON_PROJECT_ID }}
```

### Step 2: Set Up GitHub Secrets

Go to your GitHub repository settings → Secrets and variables → Actions:

```
NEON_PROJECT_ID: your-project-id
NEON_API_KEY: your-api-key
DATABASE_POOLED_URL: your-pooled-connection-string
```

### Step 3: Create Migration Files

**migrations/001_create_users_table.sql:**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    username VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT valid_username CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$'),
    password_hash TEXT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'suspended')),
    role VARCHAR(20) NOT NULL DEFAULT 'customer',
    CONSTRAINT valid_role CHECK (role IN ('customer', 'staff', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_username ON users(username) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
```

**migrations/002_create_ecommerce_tables.sql:**
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

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    shipping_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    billing_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
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
    CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    CONSTRAINT valid_payment_status CHECK (payment_status IN ('pending', 'authorized', 'paid', 'failed', 'refunded')),
    CONSTRAINT positive_total CHECK (total >= 0)
);

CREATE INDEX idx_orders_user ON orders(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_status ON orders(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_date ON orders(order_date DESC) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    line_subtotal NUMERIC(10,2) NOT NULL,
    line_tax NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    line_total NUMERIC(10,2) NOT NULL,
    product_attributes JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_unit_price CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order ON order_items(order_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_order_items_product ON order_items(product_id) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS inventory (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 0,
    reserved_quantity INTEGER NOT NULL DEFAULT 0,
    reorder_point INTEGER NOT NULL DEFAULT 10,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_quantity CHECK (quantity >= 0),
    CONSTRAINT sufficient_stock CHECK (quantity >= reserved_quantity)
);
```

### Step 4: Test the Workflow

1. Create a new branch
2. Make changes to migrations
3. Open a pull request
4. Watch the GitHub Actions workflow run
5. Verify the preview branch is created
6. Merge the PR
7. Verify changes are applied to main

### Lab Check

**Answer these questions:**

1. What happens when a PR is opened?
   ```
   
   ```

2. How are migrations tested before merging?
   ```
   
   ```

3. What is the purpose of the backup branch?
   ```
   
   ```

---

## FINAL PROJECT: COMPLETE E-COMMERCE BACKEND {#final-project}

### Project Overview

Build a complete e-commerce backend using everything you've learned in this course.

### Requirements

**1. Database Schema (25 points)**
- [ ] Users table with UUID, constraints, validation
- [ ] Products table with JSONB attributes
- [ ] Addresses table with foreign keys
- [ ] Orders table with foreign keys
- [ ] Order items table with denormalized data
- [ ] Inventory table with reservation
- [ ] Proper indexes on all tables
- [ ] Soft delete implemented
- [ ] Automatic timestamps with triggers

**2. Sample Data (15 points)**
- [ ] At least 20 sample products with JSONB data
- [ ] At least 10 sample users with different roles
- [ ] At least 20 sample orders
- [ ] At least 50 sample order items
- [ ] Realistic inventory data

**3. Queries & Analytics (20 points)**
- [ ] Product search with filters (category, price, text)
- [ ] Order history for a user
- [ ] Customer lifetime value report
- [ ] Monthly sales dashboard
- [ ] Inventory status report

**4. Performance (15 points)**
- [ ] All queries optimized with EXPLAIN ANALYZE
- [ ] Appropriate indexes for all common queries
- [ ] Query execution times documented

**5. CI/CD (15 points)**
- [ ] GitHub Actions workflow
- [ ] Preview branches for PRs
- [ ] Migration scripts
- [ ] Automated tests

**6. Documentation (10 points)**
- [ ] README with setup instructions
- [ ] Schema documentation
- [ ] Query examples
- [ ] Deployment guide

### Deliverables

1. All SQL scripts (schema, seed, migrations)
2. GitHub repository with CI/CD workflow
3. Documentation (README, schema diagram)
4. Query examples and EXPLAIN output

### Submission Checklist

- [ ] All tables created
- [ ] Sample data inserted
- [ ] Queries written and tested
- [ ] Performance optimized
- [ ] CI/CD configured
- [ ] Documentation complete

---

**[END OF LAB BOOK]**

*Complete all labs to build your production-ready e-commerce backend!* 🚀
