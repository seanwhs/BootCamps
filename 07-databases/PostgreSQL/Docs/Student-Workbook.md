# HANDS-ON POSTGRESQL: FROM ZERO TO SCHEMA HERO
## STUDENT WORKBOOK

### Complete Exercise Guide with Solutions

---

# WORKBOOK INTRODUCTION

## How to Use This Workbook

This workbook accompanies the six-part tutorial series. Each section contains:

1. **Key Concepts Review** - Quick reference of what you learned
2. **Practice Exercises** - Hands-on challenges to reinforce learning
3. **Challenge Problems** - More complex problems for deeper understanding
4. **Solutions** - Complete, working code for every exercise

**Before You Begin:**
- Ensure PostgreSQL is installed and running
- Have your database connection ready
- Keep the main tutorial series open for reference

**Format:**
- Write your SQL answers in the spaces provided
- Test each query as you write it
- Check solutions only after attempting the exercise
- Use the verification steps to confirm your work

---

# PART 1: FIRST STEPS & THE SQL FOUNDATION

## Section 1.1: Key Concepts Review

### Fill in the Blanks

1. The command to connect to PostgreSQL from the terminal is: ________

2. CRUD stands for: ________, ________, ________, ________

3. The SQL command to retrieve data is: ________

4. To filter results, you use the ________ clause

5. To sort results, you use the ________ clause

### True or False

1. [ ] DELETE without a WHERE clause deletes all rows in a table
2. [ ] UPDATE can modify multiple columns at once
3. [ ] LIKE is case-sensitive in PostgreSQL by default
4. [ ] ORDER BY can sort by multiple columns
5. [ ] LIMIT and OFFSET are used for pagination

---

## Section 1.2: Practice Exercises

### Exercise 1.2.1: Create a Products Table

**Instructions:** Create a `products` table with the following columns:
- id (SERIAL PRIMARY KEY)
- name (TEXT, NOT NULL)
- price (NUMERIC(10,2), NOT NULL)
- stock (INTEGER, NOT NULL DEFAULT 0)
- category (TEXT)
- created_at (TIMESTAMP, DEFAULT NOW())

**Your Code:**
```sql
-- Write your CREATE TABLE statement here



```

**Verification:**
```bash
psql -d ecommerce -c "\d products"
```
Expected: Shows the table structure with all columns and constraints.

---

### Exercise 1.2.2: Insert Products

**Instructions:** Insert at least 5 products into your products table. Include products from different categories and price ranges.

**Your Code:**
```sql
-- Write your INSERT statements here



```

**Verification:**
```bash
psql -d ecommerce -c "SELECT COUNT(*) FROM products;"
```
Expected: Returns the number of products you inserted (should be ≥ 5).

---

### Exercise 1.2.3: Basic SELECT Queries

**Instructions:** Write queries to:
1. Select all products
2. Select products with price greater than $50
3. Select products from the 'Electronics' category
4. Select products sorted by price (highest first)
5. Select the 3 most expensive products

**Your Code:**
```sql
-- Query 1: All products



-- Query 2: Price > 50



-- Query 3: Electronics category



-- Query 4: Sorted by price (highest first)



-- Query 5: Top 3 most expensive



```

**Verification:**
```bash
# Run each query and verify the results make sense
psql -d ecommerce -c "SELECT * FROM products;"
```

---

### Exercise 1.2.4: Filtering with WHERE

**Instructions:** Write queries using the following filters:
1. Products with price BETWEEN 20 AND 50
2. Products with price IN (19.99, 29.99, 49.99)
3. Products with name containing 'wireless'
4. Products with name starting with 'S'
5. Products with stock = 0

**Your Code:**
```sql
-- Query 1: Price BETWEEN 20 AND 50



-- Query 2: Price IN list



-- Query 3: Name contains 'wireless'



-- Query 4: Name starts with 'S'



-- Query 5: Stock = 0



```

---

### Exercise 1.2.5: UPDATE and DELETE

**Instructions:**
1. Update the price of a product by 10%
2. Increase stock by 50 for a specific product
3. Delete a product that is out of stock
4. Update a product's category
5. Set stock to 0 for discontinued products

**Your Code:**
```sql
-- Update 1: Increase price by 10%



-- Update 2: Increase stock by 50



-- Delete 1: Delete out-of-stock product



-- Update 3: Change category



-- Update 4: Set stock to 0 for discontinued



```

**Verification:**
```bash
# Verify each change by selecting the affected rows
psql -d ecommerce -c "SELECT * FROM products WHERE id = 1;"
```

---

## Section 1.3: Challenge Problems

### Challenge 1: Product Search System

**Problem:** Build a search query that combines multiple filters. The search should:
- Search for products containing a keyword in the name
- Filter by price range (min and max)
- Filter by category
- Filter by minimum stock
- Sort by price
- Limit results to 10

**Write a single query that accepts parameters for each filter:**

```sql
-- Your search query:





```

---

### Challenge 2: Product Inventory Report

**Problem:** Create a report that shows:
- Total number of products
- Average price
- Most expensive product
- Cheapest product
- Number of products out of stock
- Number of products by category

**Write a query (or multiple queries) that generates this report:**

```sql
-- Your report queries:





```

---

### Challenge 3: Bulk Price Update

**Problem:** Write a single UPDATE statement that:
- Increases prices by 15% for products under $20
- Increases prices by 10% for products between $20 and $50
- Increases prices by 5% for products over $50
- Only applies to active products
- Updates the updated_at timestamp

**Write your query:**

```sql
-- Your bulk update query:





```

---

## Section 1.4: Solutions

### Solutions to Practice Exercises

**Solution 1.2.1: Create Products Table**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    category TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Solution 1.2.2: Insert Products**
```sql
INSERT INTO products (name, price, stock, category) VALUES
    ('Wireless Headphones', 79.99, 100, 'Electronics'),
    ('USB-C Cable', 12.99, 500, 'Electronics'),
    ('Water Bottle', 24.95, 200, 'Home'),
    ('Laptop Stand', 39.99, 150, 'Office'),
    ('Wireless Mouse', 29.99, 75, 'Electronics'),
    ('Mechanical Keyboard', 89.99, 0, 'Electronics'),
    ('Webcam', 49.99, 30, 'Electronics'),
    ('Cleaning Cloth', 8.99, 1000, 'Home'),
    ('External Hard Drive', 59.99, 45, 'Electronics');
```

**Solution 1.2.3: Basic SELECT Queries**
```sql
-- All products
SELECT * FROM products;

-- Price > 50
SELECT * FROM products WHERE price > 50;

-- Electronics category
SELECT * FROM products WHERE category = 'Electronics';

-- Sorted by price (highest first)
SELECT * FROM products ORDER BY price DESC;

-- Top 3 most expensive
SELECT * FROM products ORDER BY price DESC LIMIT 3;
```

**Solution 1.2.4: Filtering with WHERE**
```sql
-- Price BETWEEN 20 AND 50
SELECT * FROM products WHERE price BETWEEN 20 AND 50;

-- Price IN list
SELECT * FROM products WHERE price IN (19.99, 29.99, 49.99);

-- Name contains 'wireless'
SELECT * FROM products WHERE name ILIKE '%wireless%';

-- Name starts with 'S'
SELECT * FROM products WHERE name LIKE 'S%';

-- Stock = 0
SELECT * FROM products WHERE stock = 0;
```

**Solution 1.2.5: UPDATE and DELETE**
```sql
-- Increase price by 10%
UPDATE products SET price = price * 1.10 WHERE id = 1;

-- Increase stock by 50
UPDATE products SET stock = stock + 50 WHERE id = 2;

-- Delete out-of-stock product
DELETE FROM products WHERE id = 6;

-- Change category
UPDATE products SET category = 'Accessories' WHERE id = 8;

-- Set stock to 0 for discontinued
UPDATE products SET stock = 0 WHERE id = 9;
```

### Solutions to Challenge Problems

**Solution Challenge 1: Product Search System**
```sql
SELECT *
FROM products
WHERE 
    name ILIKE '%wireless%'
    AND price BETWEEN 20 AND 50
    AND category = 'Electronics'
    AND stock > 0
ORDER BY price
LIMIT 10;
```

**Solution Challenge 2: Product Inventory Report**
```sql
SELECT 
    COUNT(*) AS total_products,
    ROUND(AVG(price)::NUMERIC, 2) AS average_price,
    MAX(price) AS most_expensive,
    MIN(price) AS cheapest,
    COUNT(*) FILTER (WHERE stock = 0) AS out_of_stock,
    category,
    COUNT(*) AS products_in_category
FROM products
GROUP BY category
ORDER BY products_in_category DESC;
```

**Solution Challenge 3: Bulk Price Update**
```sql
UPDATE products 
SET 
    price = CASE 
        WHEN price < 20 THEN price * 1.15
        WHEN price < 50 THEN price * 1.10
        ELSE price * 1.05
    END,
    updated_at = NOW()
WHERE stock > 0;
```

---

# PART 2: DATA TYPES & CONSTRAINTS

## Section 2.1: Key Concepts Review

### Fill in the Blanks

1. The data type for storing exact decimal values is: ________

2. The constraint that prevents duplicate values is: ________

3. A UUID is a ________-character hexadecimal identifier

4. JSONB data is stored in a ________ format

5. The constraint used to validate data against a condition is: ________

### Match the Data Type

| Column Data | Best Data Type |
|-------------|----------------|
| Product price | ________ |
| User's age | ________ |
| Product description | ________ |
| Created timestamp | ________ |
| True/False flag | ________ |
| Email address | ________ |
| Flexible attributes | ________ |

### Data Types: TEXT, INTEGER, NUMERIC, BOOLEAN, TIMESTAMPTZ, UUID, JSONB

---

## Section 2.2: Practice Exercises

### Exercise 2.2.1: Create Users Table

**Instructions:** Create a `users` table with:
- id: UUID primary key with default generation
- email: TEXT, unique, not null
- username: VARCHAR(50), unique, not null
- first_name: TEXT, not null
- last_name: TEXT, not null
- age: INTEGER, check age >= 0
- is_active: BOOLEAN, default true
- preferences: JSONB, default empty object
- created_at: TIMESTAMPTZ, default now
- updated_at: TIMESTAMPTZ, default now

**Your Code:**
```sql
-- Write your CREATE TABLE statement here





```

**Verification:**
```bash
psql -d ecommerce -c "\d users"
```

---

### Exercise 2.2.2: Add Constraints

**Instructions:** Add the following constraints to your users table (or create the table with them):
1. Email must be valid format (contains @ and .)
2. Username must be at least 3 characters
3. Age must be between 0 and 120
4. Preferences must be valid JSON

**Your Code:**
```sql
-- Write your ALTER TABLE or CREATE TABLE with constraints here






```

---

### Exercise 2.2.3: Insert Valid Users

**Instructions:** Insert 5 valid users with different:
- Names
- Ages
- Email addresses
- Preferences (different themes, notification settings)

**Your Code:**
```sql
-- Write your INSERT statements here






```

**Verification:**
```bash
psql -d ecommerce -c "SELECT COUNT(*) FROM users;"
psql -d ecommerce -c "SELECT email, username, age, preferences FROM users;"
```

---

### Exercise 2.2.4: Test Constraints

**Instructions:** Write INSERT statements that should FAIL due to constraints:

1. Duplicate email
2. Invalid email format
3. Age negative
4. Age > 120
5. Username too short

**Your Code:**
```sql
-- Attempt each invalid insert (they should error)






```

---

### Exercise 2.2.5: JSONB Operations

**Instructions:**
1. Update a user's preferences to include a theme preference
2. Query users who have a specific theme preference
3. Add a new preference field without overwriting existing preferences
4. Remove a preference field
5. Query users with a specific key in their preferences

**Your Code:**
```sql
-- Update preferences (add theme)



-- Query users with dark theme



-- Add new preference (language)



-- Remove notification preference



-- Query users with language preference



```

---

## Section 2.3: Challenge Problems

### Challenge 1: Complete User Setup Script

**Problem:** Write a complete setup script that:
1. Creates the users table with ALL constraints
2. Creates necessary indexes
3. Creates a trigger for auto-updating updated_at
4. Creates a view for active users
5. Creates a function for soft-deleting users

**Your Code:**
```sql
-- Complete setup script








```

---

### Challenge 2: User Validation System

**Problem:** Create a validation system that:
1. Checks email format using a CHECK constraint
2. Checks phone number format (optional, must be valid if provided)
3. Checks country against a list of allowed countries
4. Checks password hash length (minimum 60 characters)
5. Creates a view showing only active, verified users

**Your Code:**
```sql
-- Create validation constraints






```

---

### Challenge 3: User Preferences Analytics

**Problem:** Write queries to analyze user preferences:
1. Count users by theme preference
2. Find users with the most preferences set
3. Count users with notification preferences
4. Find users who prefer dark theme and have notifications enabled
5. Get the most common language preference

**Your Code:**
```sql
-- Theme counts



-- Most preferences



-- Notification preferences



-- Dark theme + notifications



-- Most common language



```

---

## Section 2.4: Solutions

### Solutions to Practice Exercises

**Solution 2.2.1: Create Users Table**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER CHECK (age >= 0),
    is_active BOOLEAN DEFAULT true,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Solution 2.2.2: Add Constraints**
```sql
-- Add constraints (or include in CREATE TABLE)
ALTER TABLE users ADD CONSTRAINT email_format_check 
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE users ADD CONSTRAINT username_length_check 
    CHECK (LENGTH(username) >= 3);

ALTER TABLE users ADD CONSTRAINT age_range_check 
    CHECK (age >= 0 AND age <= 120);
```

**Solution 2.2.3: Insert Valid Users**
```sql
INSERT INTO users (email, username, first_name, last_name, age, preferences) VALUES
    ('john@example.com', 'john_doe', 'John', 'Doe', 25, '{"theme": "dark", "notifications": true}'::jsonb),
    ('jane@example.com', 'jane_smith', 'Jane', 'Smith', 30, '{"theme": "light", "notifications": false}'::jsonb),
    ('bob@example.com', 'bob_wilson', 'Bob', 'Wilson', 45, '{"theme": "dark", "notifications": true, "language": "en"}'::jsonb),
    ('alice@example.com', 'alice_chen', 'Alice', 'Chen', 28, '{"theme": "light", "notifications": true}'::jsonb),
    ('admin@example.com', 'admin_user', 'Admin', 'User', 35, '{"theme": "dark", "notifications": true, "is_admin": true}'::jsonb);
```

**Solution 2.2.4: Test Constraints**
```sql
-- Duplicate email (should fail)
INSERT INTO users (email, username, first_name, last_name) 
VALUES ('john@example.com', 'john_dup', 'John', 'Dup');

-- Invalid email (should fail)
INSERT INTO users (email, username, first_name, last_name) 
VALUES ('invalid-email', 'invalid_user', 'Invalid', 'User');

-- Negative age (should fail)
INSERT INTO users (email, username, first_name, last_name, age) 
VALUES ('test@example.com', 'test_user', 'Test', 'User', -5);

-- Age > 120 (should fail)
INSERT INTO users (email, username, first_name, last_name, age) 
VALUES ('old@example.com', 'old_user', 'Old', 'User', 150);

-- Username too short (should fail)
INSERT INTO users (email, username, first_name, last_name) 
VALUES ('short@example.com', 'ab', 'Short', 'User');
```

**Solution 2.2.5: JSONB Operations**
```sql
-- Update preferences (add theme)
UPDATE users 
SET preferences = preferences || '{"theme": "dark"}'::jsonb
WHERE username = 'john_doe';

-- Query users with dark theme
SELECT email, username, preferences->>'theme' AS theme
FROM users
WHERE preferences->>'theme' = 'dark';

-- Add new preference (language)
UPDATE users 
SET preferences = preferences || '{"language": "es"}'::jsonb
WHERE username = 'jane_smith';

-- Remove notification preference
UPDATE users 
SET preferences = preferences - 'notifications'
WHERE username = 'bob_wilson';

-- Query users with language preference
SELECT email, username, preferences
FROM users
WHERE preferences ? 'language';
```

### Solutions to Challenge Problems

**Solution Challenge 1: Complete User Setup Script**
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER CHECK (age >= 0 AND age <= 120),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Create active users view
CREATE VIEW active_users AS
SELECT * FROM users WHERE is_active = true;

-- Create soft delete function
CREATE OR REPLACE FUNCTION soft_delete_user(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users SET is_active = false, updated_at = NOW()
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;
```

**Solution Challenge 2: User Validation System**
```sql
-- Create table with all validations
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL CHECK (
        email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    phone VARCHAR(20) CHECK (
        phone IS NULL OR phone ~ '^\+?[0-9\-\(\)\s]{10,20}$'
    ),
    country VARCHAR(100) DEFAULT 'US' CHECK (
        country IN ('US', 'CA', 'UK', 'DE', 'FR', 'JP', 'AU', 'BR', 'IN', 'CN')
    ),
    password_hash VARCHAR(60) NOT NULL CHECK (LENGTH(password_hash) >= 60),
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create active verified users view
CREATE VIEW active_verified_users AS
SELECT * FROM users WHERE is_active = true AND is_verified = true;
```

**Solution Challenge 3: User Preferences Analytics**
```sql
-- Count users by theme
SELECT 
    preferences->>'theme' AS theme,
    COUNT(*) AS user_count
FROM users
WHERE preferences ? 'theme'
GROUP BY preferences->>'theme';

-- Users with most preferences
SELECT 
    email,
    jsonb_object_keys(preferences) AS preference_keys
FROM users
WHERE preferences != '{}'::jsonb;

-- Notification preferences
SELECT 
    email,
    preferences->>'notifications' AS notifications
FROM users
WHERE preferences ? 'notifications';

-- Dark theme + notifications
SELECT email, preferences
FROM users
WHERE preferences->>'theme' = 'dark'
  AND preferences->>'notifications' = 'true';

-- Most common language
SELECT 
    preferences->>'language' AS language,
    COUNT(*) AS user_count
FROM users
WHERE preferences ? 'language'
GROUP BY preferences->>'language'
ORDER BY user_count DESC;
```

---

# PART 3: RELATIONSHIPS & RELATIONAL QUERIES

## Section 3.1: Key Concepts Review

### Fill in the Blanks

1. A foreign key references a ________ in another table

2. A junction table is used for ________ relationships

3. INNER JOIN returns only ________ rows

4. LEFT JOIN returns ________ from the left table and matching rows from the right

5. ON DELETE CASCADE means ________

### Relationship Types

Match the relationship to the example:

| Relationship | Example |
|--------------|---------|
| One-to-Many | ________ |
| Many-to-Many | ________ |
| One-to-One | ________ |

Examples:
- Person has one passport
- Customer has many orders
- Products belong to many categories

---

## Section 3.2: Practice Exercises

### Exercise 3.2.1: Create Orders Table

**Instructions:** Create an `orders` table with:
- id: UUID primary key
- user_id: UUID foreign key to users(id)
- status: VARCHAR(20), default 'pending'
- total: NUMERIC(10,2), default 0
- shipping_address: TEXT
- created_at: TIMESTAMPTZ, default now
- updated_at: TIMESTAMPTZ, default now

**Your Code:**
```sql
-- Write your CREATE TABLE statement here



```

**Verification:**
```bash
psql -d ecommerce -c "\d orders"
```

---

### Exercise 3.2.2: Create Order Items Table

**Instructions:** Create an `order_items` table with:
- id: UUID primary key
- order_id: UUID foreign key to orders(id) with CASCADE
- product_id: INTEGER foreign key to products(id) with RESTRICT
- quantity: INTEGER, > 0
- unit_price: NUMERIC(10,2), >= 0
- total_price: NUMERIC(10,2), >= 0

**Your Code:**
```sql
-- Write your CREATE TABLE statement here



```

---

### Exercise 3.2.3: Create Categories

**Instructions:**
1. Create a `categories` table with id, name, slug, description
2. Create a `product_categories` junction table
3. Insert at least 5 categories
4. Assign products to categories

**Your Code:**
```sql
-- Create categories table



-- Create junction table



-- Insert categories



-- Assign products to categories



```

---

### Exercise 3.2.4: JOINS Practice

**Instructions:** Write queries using each JOIN type:
1. INNER JOIN: Orders with user info
2. LEFT JOIN: All users with their orders
3. INNER JOIN: Order items with product details
4. COMPLEX JOIN: Orders with user, items, and products
5. Self JOIN: Categories with parent categories

**Your Code:**
```sql
-- INNER JOIN: Orders with user info



-- LEFT JOIN: All users with orders



-- INNER JOIN: Order items with products



-- COMPLEX JOIN: Orders with all details



-- Self JOIN: Categories hierarchy



```

---

### Exercise 3.2.5: Create Complete Order

**Instructions:** Write SQL to:
1. Create an order for a user
2. Add 3 items to the order
3. Calculate and update the order total
4. Show the complete order with all details

**Your Code:**
```sql
-- Step 1: Create order



-- Step 2: Add items



-- Step 3: Update total



-- Step 4: View complete order



```

---

## Section 3.3: Challenge Problems

### Challenge 1: Order History Query

**Problem:** Write a query that shows a complete customer order history including:
- Customer name and email
- Order ID, date, status, total
- List of items (product names, quantities, prices)
- Order subtotal, tax, shipping, grand total

**Your Code:**
```sql
-- Complete order history query






```

---

### Challenge 2: Product Popularity Report

**Problem:** Write a query that shows:
- Product name
- Number of times ordered
- Total quantity sold
- Total revenue generated
- Average price sold at
- Category of the product
- Rank by revenue

**Your Code:**
```sql
-- Product popularity report






```

---

### Challenge 3: Category Sales Analysis

**Problem:** Write a query that analyzes sales by category:
- Category name
- Number of products in category
- Total units sold
- Total revenue
- Average price per product
- Revenue percentage of total sales
- Rank by revenue

**Your Code:**
```sql
-- Category sales analysis






```

---

## Section 3.4: Solutions

### Solutions to Practice Exercises

**Solution 3.2.1: Create Orders Table**
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending',
    total NUMERIC(10,2) DEFAULT 0,
    shipping_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Solution 3.2.2: Create Order Items Table**
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price NUMERIC(10,2) NOT NULL CHECK (total_price >= 0)
);
```

**Solution 3.2.3: Create Categories**
```sql
-- Create categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Create junction table
CREATE TABLE product_categories (
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);

-- Insert categories
INSERT INTO categories (name, slug, description) VALUES
    ('Electronics', 'electronics', 'Electronic devices'),
    ('Home', 'home', 'Home goods'),
    ('Office', 'office', 'Office supplies'),
    ('Accessories', 'accessories', 'Product accessories'),
    ('Audio', 'audio', 'Audio equipment');

-- Assign products to categories
INSERT INTO product_categories (product_id, category_id)
SELECT p.id, c.id
FROM products p, categories c
WHERE 
    (p.name ILIKE '%headphone%' AND c.slug = 'audio') OR
    (p.name ILIKE '%cable%' AND c.slug = 'electronics') OR
    (p.name ILIKE '%bottle%' AND c.slug = 'home') OR
    (p.name ILIKE '%stand%' AND c.slug = 'office') OR
    (p.name ILIKE '%mouse%' AND c.slug = 'electronics');
```

**Solution 3.2.4: JOINS Practice**
```sql
-- INNER JOIN: Orders with user info
SELECT o.id, u.email, u.first_name, o.total, o.status
FROM orders o
INNER JOIN users u ON u.id = o.user_id;

-- LEFT JOIN: All users with orders
SELECT u.email, COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.email;

-- INNER JOIN: Order items with product details
SELECT oi.*, p.name, p.price
FROM order_items oi
INNER JOIN products p ON p.id = oi.product_id;

-- COMPLEX JOIN: Orders with all details
SELECT o.id, u.email, oi.product_id, p.name, oi.quantity, oi.unit_price
FROM orders o
INNER JOIN users u ON u.id = o.user_id
INNER JOIN order_items oi ON oi.order_id = o.id
INNER JOIN products p ON p.id = oi.product_id;

-- Self JOIN: Categories hierarchy
SELECT c1.name AS category, c2.name AS parent
FROM categories c1
LEFT JOIN categories c2 ON c2.id = c1.parent_id;
```

**Solution 3.2.5: Create Complete Order**
```sql
-- Step 1: Create order
INSERT INTO orders (user_id, shipping_address)
VALUES ((SELECT id FROM users LIMIT 1), '123 Main St');

-- Step 2: Add items
WITH current_order AS (SELECT id FROM orders ORDER BY created_at DESC LIMIT 1)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
SELECT 
    co.id,
    p.id,
    2,
    p.price,
    p.price * 2
FROM current_order co, products p
WHERE p.id = 1;

-- Step 3: Update total
UPDATE orders 
SET total = (
    SELECT SUM(total_price) 
    FROM order_items 
    WHERE order_id = orders.id
)
WHERE id = (SELECT id FROM orders ORDER BY created_at DESC LIMIT 1);

-- Step 4: View complete order
SELECT o.*, oi.*, p.name
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id
WHERE o.id = (SELECT id FROM orders ORDER BY created_at DESC LIMIT 1);
```

### Solutions to Challenge Problems

**Solution Challenge 1: Order History Query**
```sql
SELECT 
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email,
    o.id AS order_id,
    o.created_at AS order_date,
    o.status,
    o.total,
    (SELECT json_agg(json_build_object(
        'product', p.name,
        'quantity', oi.quantity,
        'price', oi.unit_price,
        'total', oi.total_price
    )) FROM order_items oi 
     JOIN products p ON p.id = oi.product_id 
     WHERE oi.order_id = o.id) AS items,
    o.total AS subtotal,
    o.total * 0.08 AS tax,
    CASE WHEN o.total > 100 THEN 0 ELSE 5.99 END AS shipping,
    o.total + (o.total * 0.08) + CASE WHEN o.total > 100 THEN 0 ELSE 5.99 END AS grand_total
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE u.id = (SELECT id FROM users LIMIT 1)
ORDER BY o.created_at DESC;
```

**Solution Challenge 2: Product Popularity Report**
```sql
SELECT 
    p.name AS product_name,
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.total_price) AS total_revenue,
    AVG(oi.unit_price) AS avg_price,
    (SELECT name FROM categories c 
     JOIN product_categories pc ON pc.category_id = c.id 
     WHERE pc.product_id = p.id LIMIT 1) AS category,
    RANK() OVER (ORDER BY SUM(oi.total_price) DESC) AS revenue_rank
FROM products p
JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.id
ORDER BY revenue_rank;
```

**Solution Challenge 3: Category Sales Analysis**
```sql
WITH category_sales AS (
    SELECT 
        c.id,
        c.name AS category_name,
        COUNT(DISTINCT p.id) AS product_count,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.total_price) AS revenue,
        AVG(p.price) AS avg_product_price
    FROM categories c
    JOIN product_categories pc ON pc.category_id = c.id
    JOIN products p ON p.id = pc.product_id
    LEFT JOIN order_items oi ON oi.product_id = p.id
    GROUP BY c.id, c.name
)
SELECT 
    category_name,
    product_count,
    COALESCE(units_sold, 0) AS units_sold,
    COALESCE(revenue, 0) AS revenue,
    COALESCE(avg_product_price, 0) AS avg_product_price,
    ROUND(100 * revenue / NULLIF(SUM(revenue) OVER (), 0), 2) AS revenue_pct,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM category_sales
ORDER BY revenue_rank;
```

---

# PART 4: AGGREGATIONS, GROUPING & SUBQUERIES

## Section 4.1: Key Concepts Review

### Fill in the Blanks

1. COUNT() counts ________

2. SUM() adds up ________

3. AVG() calculates the ________

4. GROUP BY groups rows with ________ values

5. HAVING filters groups, WHERE filters ________

### Aggregate Functions

| Function | Description |
|----------|-------------|
| COUNT(*) | ________ |
| SUM(column) | ________ |
| AVG(column) | ________ |
| MIN(column) | ________ |
| MAX(column) | ________ |

---

## Section 4.2: Practice Exercises

### Exercise 4.2.1: Basic Aggregations

**Instructions:** Write queries to find:
1. Total number of orders
2. Total revenue from all orders
3. Average order value
4. Minimum order total
5. Maximum order total

**Your Code:**
```sql
-- Total orders



-- Total revenue



-- Average order value



-- Minimum order



-- Maximum order



```

---

### Exercise 4.2.2: GROUP BY Practice

**Instructions:** Write queries to:
1. Count orders by status
2. Total revenue by month
3. Average order value by user
4. Count orders by user
5. Sum total by status

**Your Code:**
```sql
-- Orders by status



-- Revenue by month



-- Average order by user



-- Order count by user



-- Total by status



```

---

### Exercise 4.2.3: HAVING Clause

**Instructions:** Write queries using HAVING:
1. Users with more than 3 orders
2. Products with revenue > $100
3. Months with more than 10 orders
4. Categories with average price > $50
5. Users with total spend > $500

**Your Code:**
```sql
-- Users with > 3 orders



-- Products with > $100 revenue



-- Months with > 10 orders



-- Categories with avg price > $50



-- Users with > $500 spend



```

---

### Exercise 4.2.4: Subqueries

**Instructions:** Write queries using subqueries:
1. Products priced above average
2. Users who have never ordered
3. Orders above average total
4. Products never ordered
5. Users with orders in the last 30 days

**Your Code:**
```sql
-- Products above average price



-- Users who never ordered



-- Orders above average total



-- Products never ordered



-- Users with recent orders



```

---

### Exercise 4.2.5: CASE WHEN

**Instructions:** Write queries using CASE:
1. Categorize orders by size (small, medium, large)
2. Categorize products by price tier
3. Convert status codes to user-friendly labels
4. Calculate discount based on order total
5. Categorize customers by spending tier

**Your Code:**
```sql
-- Order size categories



-- Product price tiers



-- Status labels



-- Discount calculation



-- Customer spending tiers



```

---

## Section 4.3: Challenge Problems

### Challenge 1: Monthly Revenue Report

**Problem:** Create a comprehensive monthly revenue report showing:
- Year and month
- Number of orders
- Total revenue
- Average order value
- Revenue growth from previous month
- Percentage of total revenue

**Your Code:**
```sql
-- Monthly revenue report






```

---

### Challenge 2: Customer Segmentation

**Problem:** Segment customers by their purchasing behavior:
- Customer name and email
- Number of orders
- Total spent
- Average order value
- Days since last order
- Segment: New, Regular, Loyal, VIP
- Activity status: Active, Recent, Inactive

**Your Code:**
```sql
-- Customer segmentation






```

---

### Challenge 3: Sales Funnel Analysis

**Problem:** Analyze the sales funnel showing:
- Total visitors (use users table)
- Customers who added to cart
- Customers who placed orders
- Customers who completed payment
- Conversion rates between each stage

**Your Code:**
```sql
-- Sales funnel analysis






```

---

## Section 4.4: Solutions

### Solutions to Practice Exercises

**Solution 4.2.1: Basic Aggregations**
```sql
-- Total orders
SELECT COUNT(*) FROM orders;

-- Total revenue
SELECT SUM(total) FROM orders;

-- Average order value
SELECT AVG(total) FROM orders;

-- Minimum order
SELECT MIN(total) FROM orders;

-- Maximum order
SELECT MAX(total) FROM orders;
```

**Solution 4.2.2: GROUP BY Practice**
```sql
-- Orders by status
SELECT status, COUNT(*) FROM orders GROUP BY status;

-- Revenue by month
SELECT DATE_TRUNC('month', created_at) AS month, SUM(total) 
FROM orders 
GROUP BY month 
ORDER BY month;

-- Average order by user
SELECT user_id, AVG(total) FROM orders GROUP BY user_id;

-- Order count by user
SELECT user_id, COUNT(*) FROM orders GROUP BY user_id;

-- Total by status
SELECT status, SUM(total) FROM orders GROUP BY status;
```

**Solution 4.2.3: HAVING Clause**
```sql
-- Users with > 3 orders
SELECT user_id, COUNT(*) 
FROM orders 
GROUP BY user_id 
HAVING COUNT(*) > 3;

-- Products with > $100 revenue
SELECT product_id, SUM(total_price) 
FROM order_items 
GROUP BY product_id 
HAVING SUM(total_price) > 100;

-- Months with > 10 orders
SELECT DATE_TRUNC('month', created_at), COUNT(*) 
FROM orders 
GROUP BY month 
HAVING COUNT(*) > 10;

-- Categories with avg price > $50
SELECT c.name, AVG(p.price)
FROM categories c
JOIN product_categories pc ON pc.category_id = c.id
JOIN products p ON p.id = pc.product_id
GROUP BY c.name
HAVING AVG(p.price) > 50;

-- Users with > $500 spend
SELECT user_id, SUM(total)
FROM orders
GROUP BY user_id
HAVING SUM(total) > 500;
```

**Solution 4.2.4: Subqueries**
```sql
-- Products above average price
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);

-- Users who never ordered
SELECT * FROM users WHERE id NOT IN (SELECT DISTINCT user_id FROM orders);

-- Orders above average total
SELECT * FROM orders WHERE total > (SELECT AVG(total) FROM orders);

-- Products never ordered
SELECT * FROM products WHERE id NOT IN (SELECT DISTINCT product_id FROM order_items);

-- Users with recent orders
SELECT * FROM users WHERE id IN (
    SELECT user_id FROM orders 
    WHERE created_at > NOW() - INTERVAL '30 days'
);
```

**Solution 4.2.5: CASE WHEN**
```sql
-- Order size categories
SELECT 
    id, total,
    CASE 
        WHEN total < 50 THEN 'Small'
        WHEN total < 200 THEN 'Medium'
        ELSE 'Large'
    END AS size
FROM orders;

-- Product price tiers
SELECT 
    name, price,
    CASE 
        WHEN price < 20 THEN 'Budget'
        WHEN price < 50 THEN 'Economy'
        WHEN price < 100 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS tier
FROM products;

-- Status labels
SELECT 
    status,
    CASE status
        WHEN 'pending' THEN 'Awaiting Payment'
        WHEN 'paid' THEN 'Payment Confirmed'
        WHEN 'shipped' THEN 'On the Way'
        WHEN 'delivered' THEN 'Delivered'
        WHEN 'cancelled' THEN 'Cancelled'
    END AS label
FROM orders;

-- Discount calculation
SELECT 
    id, total,
    CASE 
        WHEN total > 100 THEN total * 0.1
        WHEN total > 50 THEN total * 0.05
        ELSE 0
    END AS discount
FROM orders;

-- Customer spending tiers
SELECT 
    user_id, SUM(total),
    CASE 
        WHEN SUM(total) > 1000 THEN 'VIP'
        WHEN SUM(total) > 500 THEN 'Gold'
        WHEN SUM(total) > 100 THEN 'Silver'
        ELSE 'Bronze'
    END AS tier
FROM orders
GROUP BY user_id;
```

### Solutions to Challenge Problems

**Solution Challenge 1: Monthly Revenue Report**
```sql
WITH monthly_data AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        COUNT(*) AS order_count,
        SUM(total) AS revenue,
        AVG(total) AS avg_order,
        SUM(total) OVER (ORDER BY DATE_TRUNC('month', created_at)) AS running_total
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)
)
SELECT 
    month,
    order_count,
    revenue,
    avg_order,
    ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2) AS growth_pct,
    ROUND(100 * revenue / NULLIF(SUM(revenue) OVER (), 0), 2) AS revenue_pct
FROM monthly_data
ORDER BY month;
```

**Solution Challenge 2: Customer Segmentation**
```sql
SELECT 
    u.email,
    COUNT(o.id) AS order_count,
    COALESCE(SUM(o.total), 0) AS total_spent,
    COALESCE(AVG(o.total), 0) AS avg_order,
    MAX(o.created_at) AS last_order,
    EXTRACT(DAY FROM NOW() - MAX(o.created_at)) AS days_since_last,
    CASE 
        WHEN COUNT(o.id) = 0 THEN 'New'
        WHEN SUM(o.total) > 1000 THEN 'VIP'
        WHEN SUM(o.total) > 500 THEN 'Loyal'
        WHEN COUNT(o.id) > 3 THEN 'Regular'
        ELSE 'Occasional'
    END AS segment,
    CASE 
        WHEN MAX(o.created_at) > NOW() - INTERVAL '30 days' THEN 'Active'
        WHEN MAX(o.created_at) > NOW() - INTERVAL '90 days' THEN 'Recent'
        ELSE 'Inactive'
    END AS activity_status
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.email
ORDER BY total_spent DESC;
```

**Solution Challenge 3: Sales Funnel Analysis**
```sql
WITH funnel AS (
    SELECT 
        (SELECT COUNT(*) FROM users) AS total_visitors,
        (SELECT COUNT(DISTINCT user_id) FROM orders) AS placed_order,
        (SELECT COUNT(DISTINCT user_id) FROM orders WHERE status != 'pending') AS completed_order,
        (SELECT COUNT(DISTINCT user_id) FROM orders WHERE status = 'delivered') AS delivered_order
)
SELECT 
    total_visitors,
    placed_order,
    completed_order,
    delivered_order,
    ROUND(100 * placed_order::NUMERIC / total_visitors, 2) AS visitor_to_order_rate,
    ROUND(100 * completed_order::NUMERIC / placed_order, 2) AS order_to_completion_rate,
    ROUND(100 * delivered_order::NUMERIC / completed_order, 2) AS completion_to_delivery_rate,
    ROUND(100 * delivered_order::NUMERIC / total_visitors, 2) AS overall_conversion
FROM funnel;
```

---

# PART 5: MODERN POSTGRES POWER TOOLS

## Section 5.1: Key Concepts Review

### Fill in the Blanks

1. JSONB stores JSON data in ________ format

2. The -> operator returns JSON as a ________

3. The ->> operator returns JSON as ________

4. ROW_NUMBER() assigns a unique ________ to each row

5. RANK() assigns ranks with ________

### JSONB Operators

| Operator | Description |
|----------|-------------|
| -> | ________ |
| ->> | ________ |
| ? | ________ |
| @> | ________ |

---

## Section 5.2: Practice Exercises

### Exercise 5.2.1: JSONB Setup

**Instructions:**
1. Add a metadata column to products (JSONB)
2. Add sample metadata (brand, warranty, eco-friendly, material)
3. Add variants column (JSONB array) with different options

**Your Code:**
```sql
-- Add metadata column



-- Update with metadata



-- Add variants column



-- Update with variants



```

---

### Exercise 5.2.2: JSONB Queries

**Instructions:** Write queries to:
1. Get products by brand
2. Find products with warranty > 12 months
3. Get products with eco-friendly true
4. Extract variant information
5. Find products with specific variant option

**Your Code:**
```sql
-- Products by brand



-- Warranty > 12 months



-- Eco-friendly products



-- Extract variants



-- Variant options



```

---

### Exercise 5.2.3: Window Functions - Basic

**Instructions:** Write queries using:
1. ROW_NUMBER() for sequential numbering
2. RANK() for ranking products by price
3. LAG() to compare with previous order
4. LEAD() to compare with next order
5. Running total of orders

**Your Code:**
```sql
-- ROW_NUMBER: Number products by price



-- RANK: Rank products by price



-- LAG: Compare with previous order



-- LEAD: Compare with next order



-- Running total



```

---

### Exercise 5.2.4: Window Functions - Advanced

**Instructions:** Write queries using:
1. Moving average (3-order average)
2. Percentage of total revenue
3. Customer purchase progression
4. NTILE(4) quartiles
5. FIRST_VALUE and LAST_VALUE

**Your Code:**
```sql
-- Moving average



-- Percentage of total



-- Customer progression



-- NTILE quartiles



-- FIRST_VALUE / LAST_VALUE



```

---

### Exercise 5.2.5: JSONB + Window Functions

**Instructions:** Combine JSONB and window functions:
1. Rank products by brand with revenue
2. Calculate percentage of brand revenue
3. Compare product price to brand average
4. Rank variant options by stock
5. Customer preferences analysis

**Your Code:**
```sql
-- Brand rankings



-- Brand revenue percentage



-- Price vs brand average



-- Variant stock ranking



-- Preferences analysis



```

---

## Section 5.3: Challenge Problems

### Challenge 1: Customer Ranking System

**Problem:** Build a comprehensive customer ranking system with:
- Composite score based on spending, frequency, recency
- Customer tier classification
- Percentile rankings
- Loyalty points calculation
- Rank by multiple dimensions

**Your Code:**
```sql
-- Customer ranking system






```

---

### Challenge 2: Product Recommendation Engine

**Problem:** Create a product recommendation query that:
- Finds similar products by category
- Ranks by popularity and rating
- Includes JSONB metadata matching
- Uses window functions for ranking
- Returns top recommendations per product

**Your Code:**
```sql
-- Product recommendations






```

---

### Challenge 3: Sales Dashboard with Trends

**Problem:** Build a sales dashboard that:
- Shows daily sales with 7-day moving average
- Week-over-week growth
- Running total for the year
- Customer acquisition trends
- Product category performance over time

**Your Code:**
```sql
-- Sales dashboard with trends






```

---

## Section 5.4: Solutions

### Solutions to Practice Exercises

**Solution 5.2.1: JSONB Setup**
```sql
-- Add metadata column
ALTER TABLE products ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;

-- Update with metadata
UPDATE products SET metadata = jsonb_build_object(
    'brand', 'AudioTech',
    'warranty_months', 24,
    'eco_friendly', true,
    'material', 'aluminum'
) WHERE name ILIKE '%headphone%';

-- Add variants column
ALTER TABLE products ADD COLUMN variants JSONB DEFAULT '[]'::jsonb;

-- Update with variants
UPDATE products SET variants = '[
    {"color": "Black", "sku": "HD-BLK", "stock": 50},
    {"color": "White", "sku": "HD-WHT", "stock": 30}
]'::jsonb WHERE name ILIKE '%headphone%';
```

**Solution 5.2.2: JSONB Queries**
```sql
-- Products by brand
SELECT * FROM products WHERE metadata->>'brand' = 'AudioTech';

-- Warranty > 12 months
SELECT * FROM products WHERE (metadata->>'warranty_months')::int > 12;

-- Eco-friendly products
SELECT * FROM products WHERE metadata @> '{"eco_friendly": true}'::jsonb;

-- Extract variants
SELECT 
    name,
    jsonb_array_elements(variants)->>'color' AS color,
    jsonb_array_elements(variants)->>'stock' AS stock
FROM products
WHERE variants != '[]'::jsonb;

-- Variant options
SELECT name, variants
FROM products
WHERE variants @> '[{"color": "Black"}]'::jsonb;
```

**Solution 5.2.3: Window Functions - Basic**
```sql
-- ROW_NUMBER: Number products by price
SELECT name, price, ROW_NUMBER() OVER (ORDER BY price DESC) AS rank
FROM products;

-- RANK: Rank products by price
SELECT name, price, RANK() OVER (ORDER BY price DESC) AS rank
FROM products;

-- LAG: Compare with previous order
SELECT 
    id, total, created_at,
    LAG(total) OVER (ORDER BY created_at) AS prev_order
FROM orders;

-- LEAD: Compare with next order
SELECT 
    id, total, created_at,
    LEAD(total) OVER (ORDER BY created_at) AS next_order
FROM orders;

-- Running total
SELECT 
    created_at, total,
    SUM(total) OVER (ORDER BY created_at) AS running_total
FROM orders;
```

**Solution 5.2.4: Window Functions - Advanced**
```sql
-- Moving average
SELECT 
    created_at, total,
    AVG(total) OVER (ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM orders;

-- Percentage of total
SELECT 
    id, total,
    total / SUM(total) OVER () * 100 AS pct_of_total
FROM orders;

-- Customer progression
SELECT 
    user_id, created_at, total,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_num
FROM orders;

-- NTILE quartiles
SELECT 
    id, total,
    NTILE(4) OVER (ORDER BY total) AS quartile
FROM orders;

-- FIRST_VALUE / LAST_VALUE
SELECT 
    user_id, created_at, total,
    FIRST_VALUE(total) OVER (PARTITION BY user_id ORDER BY created_at) AS first_order,
    LAST_VALUE(total) OVER (PARTITION BY user_id ORDER BY created_at 
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order
FROM orders;
```

**Solution 5.2.5: JSONB + Window Functions**
```sql
-- Brand rankings
WITH brand_metrics AS (
    SELECT 
        metadata->>'brand' AS brand,
        name,
        price,
        RANK() OVER (PARTITION BY metadata->>'brand' ORDER BY price DESC) AS brand_rank
    FROM products
    WHERE metadata ? 'brand'
)
SELECT * FROM brand_metrics WHERE brand_rank <= 3;

-- Brand revenue percentage
WITH brand_revenue AS (
    SELECT 
        p.metadata->>'brand' AS brand,
        SUM(oi.total_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.id
    WHERE p.metadata ? 'brand'
    GROUP BY p.metadata->>'brand'
)
SELECT 
    brand,
    revenue,
    ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total
FROM brand_revenue;

-- Price vs brand average
WITH brand_avg AS (
    SELECT 
        metadata->>'brand' AS brand,
        AVG(price) AS avg_price
    FROM products
    WHERE metadata ? 'brand'
    GROUP BY metadata->>'brand'
)
SELECT 
    p.name,
    p.price,
    ba.avg_price,
    p.price - ba.avg_price AS diff_from_avg
FROM products p
JOIN brand_avg ba ON ba.brand = p.metadata->>'brand';

-- Variant stock ranking
SELECT 
    name,
    variant.value->>'color' AS color,
    (variant.value->>'stock')::int AS stock,
    RANK() OVER (PARTITION BY name ORDER BY (variant.value->>'stock')::int DESC) AS stock_rank
FROM products p,
LATERAL jsonb_array_elements(p.variants) AS variant(value)
WHERE variants != '[]'::jsonb;

-- Preferences analysis
SELECT 
    preferences->>'theme' AS theme,
    COUNT(*) AS user_count,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS popularity_rank
FROM users
WHERE preferences ? 'theme'
GROUP BY preferences->>'theme';
```

### Solutions to Challenge Problems

**Solution Challenge 1: Customer Ranking System**
```sql
WITH customer_metrics AS (
    SELECT 
        u.id,
        u.email,
        COUNT(o.id) AS order_count,
        COALESCE(SUM(o.total), 0) AS total_spent,
        MAX(o.created_at) AS last_order,
        EXTRACT(DAY FROM NOW() - MAX(o.created_at)) AS days_since_last
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id
    GROUP BY u.id, u.email
),
ranked AS (
    SELECT 
        id,
        email,
        order_count,
        total_spent,
        days_since_last,
        RANK() OVER (ORDER BY total_spent DESC) AS spend_rank,
        RANK() OVER (ORDER BY order_count DESC) AS frequency_rank,
        ROUND(100 * total_spent / NULLIF(SUM(total_spent) OVER (), 0), 2) AS spend_pct,
        CASE 
            WHEN days_since_last IS NULL THEN 1.0
            ELSE 1.0 - (days_since_last / 365.0)
        END AS recency_score,
        CASE 
            WHEN total_spent > 1000 THEN 'VIP'
            WHEN total_spent > 500 THEN 'Gold'
            WHEN total_spent > 100 THEN 'Silver'
            WHEN order_count > 0 THEN 'Bronze'
            ELSE 'New'
        END AS tier,
        FLOOR(total_spent / 10) AS loyalty_points
    FROM customer_metrics
)
SELECT 
    email,
    tier,
    total_spent,
    order_count,
    spend_rank,
    frequency_rank,
    loyalty_points,
    ROUND((spend_pct * 40 + (1 - ((spend_rank - 1)::NUMERIC / COUNT(*) OVER ())) * 30 + recency_score * 20 + (CASE WHEN order_count > 0 THEN 10 ELSE 0 END)), 2) AS composite_score
FROM ranked
WHERE id IS NOT NULL
ORDER BY composite_score DESC;
```

**Solution Challenge 2: Product Recommendation Engine**
```sql
WITH similar_products AS (
    SELECT 
        p1.id AS source_product_id,
        p2.id AS recommended_product_id,
        p2.name AS recommended_name,
        p2.price AS recommended_price,
        COUNT(DISTINCT pc1.category_id) AS shared_categories,
        COALESCE(SUM(oi.quantity), 0) AS popularity
    FROM products p1
    JOIN product_categories pc1 ON pc1.product_id = p1.id
    JOIN product_categories pc2 ON pc2.category_id = pc1.category_id
    JOIN products p2 ON p2.id = pc2.product_id AND p2.id != p1.id
    LEFT JOIN order_items oi ON oi.product_id = p2.id
    GROUP BY p1.id, p2.id, p2.name, p2.price
)
SELECT 
    source_product_id,
    recommended_name,
    recommended_price,
    shared_categories,
    popularity,
    RANK() OVER (PARTITION BY source_product_id ORDER BY shared_categories DESC, popularity DESC) AS recommendation_rank
FROM similar_products
WHERE source_product_id = 1
ORDER BY recommendation_rank
LIMIT 5;
```

**Solution Challenge 3: Sales Dashboard with Trends**
```sql
WITH daily_sales AS (
    SELECT 
        DATE(created_at) AS sale_date,
        COUNT(*) AS orders,
        SUM(total) AS revenue
    FROM orders
    GROUP BY DATE(created_at)
),
trends AS (
    SELECT 
        sale_date,
        orders,
        revenue,
        AVG(revenue) OVER (ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7d,
        LAG(revenue, 7) OVER (ORDER BY sale_date) AS revenue_7d_ago,
        SUM(revenue) OVER (ORDER BY sale_date) AS running_total,
        RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
    FROM daily_sales
    WHERE sale_date > CURRENT_DATE - INTERVAL '90 days'
)
SELECT 
    sale_date,
    orders,
    revenue,
    ROUND(moving_avg_7d, 2) AS moving_avg,
    ROUND(100 * (revenue - revenue_7d_ago) / NULLIF(revenue_7d_ago, 0), 2) AS wow_growth_pct,
    ROUND(running_total, 2) AS running_total,
    revenue_rank
FROM trends
ORDER BY sale_date DESC;
```

---

# PART 6: PERFORMANCE, INDEXES & TRANSACTIONS

## Section 6.1: Key Concepts Review

### Fill in the Blanks

1. EXPLAIN ANALYZE shows the ________ of a query

2. An index speeds up ________ operations but slows ________ operations

3. A B-Tree index is best for ________ and ________ queries

4. BEGIN starts a ________

5. COMMIT saves changes, ROLLBACK ________ changes

### Index Types

| Index Type | Best For | Use Case |
|------------|----------|----------|
| B-Tree | ________ | Most queries |
| GIN | ________ | JSONB, arrays |
| Partial | ________ | Filtered queries |
| Unique | ________ | Enforce uniqueness |
| Expression | ________ | Computed values |

---

## Section 6.2: Practice Exercises

### Exercise 6.2.1: EXPLAIN ANALYZE

**Instructions:** Run EXPLAIN ANALYZE on each query and identify:
1. The execution time
2. The type of scan used
3. Whether an index was used
4. The number of rows examined

```sql
-- Query 1: Simple SELECT
EXPLAIN ANALYZE SELECT * FROM products WHERE price > 50;

-- Query 2: Join
EXPLAIN ANALYZE SELECT * FROM orders o JOIN users u ON u.id = o.user_id;

-- Query 3: Aggregation
EXPLAIN ANALYZE SELECT user_id, COUNT(*) FROM orders GROUP BY user_id;

-- Query 4: Search
EXPLAIN ANALYZE SELECT * FROM products WHERE name ILIKE '%wireless%';
```

**Your Observations:**
```
Query 1 Execution Time: _______
Query 1 Scan Type: _______
Query 1 Index Used: _______

Query 2 Execution Time: _______
Query 2 Scan Type: _______
Query 2 Index Used: _______

Query 3 Execution Time: _______
Query 3 Scan Type: _______
Query 3 Index Used: _______

Query 4 Execution Time: _______
Query 4 Scan Type: _______
Query 4 Index Used: _______
```

---

### Exercise 6.2.2: Create Indexes

**Instructions:** Create indexes for:
1. products.name for search queries
2. orders.user_id for joins
3. orders.created_at for date filtering
4. products.metadata for JSONB queries
5. orders.status for filtering

**Your Code:**
```sql
-- Index 1: products.name



-- Index 2: orders.user_id



-- Index 3: orders.created_at



-- Index 4: products.metadata GIN



-- Index 5: orders.status



```

**Verification:**
```bash
psql -d ecommerce -c "\di"
```

---

### Exercise 6.2.3: Transaction Basics

**Instructions:** Write transactions for:
1. Transfer stock between two products
2. Create an order with multiple items
3. Update a user's email with verification
4. Bulk update with rollback on error
5. With savepoints for partial rollback

**Your Code:**
```sql
-- Transaction 1: Stock transfer



-- Transaction 2: Create order with items



-- Transaction 3: Update email with verification



-- Transaction 4: Bulk update with rollback



-- Transaction 5: Savepoints for partial rollback



```

---

### Exercise 6.2.4: Locking

**Instructions:** Practice different locking strategies:
1. SELECT ... FOR UPDATE (row lock)
2. SELECT ... FOR UPDATE NOWAIT
3. Table-level lock
4. Advisory lock
5. Deadlock detection

**Your Code:**
```sql
-- SELECT FOR UPDATE



-- SELECT FOR UPDATE NOWAIT



-- Table-level lock



-- Advisory lock



```

---

### Exercise 6.2.5: Complete Checkout Process

**Instructions:** Write a complete checkout transaction that:
1. Validates user and cart
2. Checks inventory for all items
3. Reserves inventory (reduces stock)
4. Creates order
5. Adds order items
6. Calculates totals
7. Processes payment
8. Commits or rolls back

**Your Code:**
```sql
-- Complete checkout transaction








```

---

## Section 6.3: Challenge Problems

### Challenge 1: Inventory System with Concurrency

**Problem:** Build an inventory management system that:
- Handles concurrent reservations
- Prevents overselling
- Uses pessimistic locking
- Returns clear success/failure messages
- Logs all transactions

**Your Code:**
```sql
-- Inventory system with concurrency






```

---

### Challenge 2: Performance Optimization

**Problem:** Optimize a slow query by:
1. Adding appropriate indexes
2. Rewriting the query for better performance
3. Using EXPLAIN ANALYZE to verify improvement
4. Creating a covering index
5. Using query hints if needed

**Your Code:**
```sql
-- Original slow query



-- Optimized query with indexes



-- EXPLAIN ANALYZE comparison



```

---

### Challenge 3: Distributed Transaction Pattern

**Problem:** Implement a two-phase commit pattern for distributed transactions:
1. Prepare phase: Validate all operations
2. Commit phase: Execute all operations
3. Rollback phase: Revert on any failure
4. Use savepoints for nested operations
5. Include logging for debugging

**Your Code:**
```sql
-- Distributed transaction pattern






```

---

## Section 6.4: Solutions

### Solutions to Practice Exercises

**Solution 6.2.2: Create Indexes**
```sql
-- Index 1: products.name (for search)
CREATE INDEX idx_products_name ON products(name);

-- Index 2: orders.user_id (for joins)
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Index 3: orders.created_at (for date filtering)
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Index 4: products.metadata (for JSONB queries)
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- Index 5: orders.status (for filtering)
CREATE INDEX idx_orders_status ON orders(status);
```

**Solution 6.2.3: Transaction Basics**
```sql
-- Transaction 1: Stock transfer
BEGIN;
UPDATE products SET stock = stock - 5 WHERE id = 1;
UPDATE products SET stock = stock + 5 WHERE id = 2;
COMMIT;

-- Transaction 2: Create order with items
BEGIN;
INSERT INTO orders (user_id, total) VALUES (1, 0) RETURNING id;
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
VALUES (1, 1, 2, 19.99, 39.98);
UPDATE orders SET total = (SELECT SUM(total_price) FROM order_items WHERE order_id = 1);
COMMIT;

-- Transaction 3: Update email with verification
BEGIN;
UPDATE users SET email = 'new@email.com', is_verified = false WHERE id = 1;
-- Send verification email (application logic)
COMMIT;

-- Transaction 4: Bulk update with rollback
BEGIN;
UPDATE products SET price = price * 1.1 WHERE stock > 0;
-- If something fails:
ROLLBACK;

-- Transaction 5: Savepoints for partial rollback
BEGIN;
UPDATE products SET stock = stock - 10 WHERE id = 1;
SAVEPOINT after_first_update;
UPDATE products SET stock = stock - 20 WHERE id = 2;
-- If second update fails:
ROLLBACK TO SAVEPOINT after_first_update;
UPDATE products SET stock = stock - 15 WHERE id = 3;
COMMIT;
```

**Solution 6.2.4: Locking**
```sql
-- SELECT FOR UPDATE
BEGIN;
SELECT stock FROM products WHERE id = 1 FOR UPDATE;
UPDATE products SET stock = stock - 1 WHERE id = 1;
COMMIT;

-- SELECT FOR UPDATE NOWAIT
BEGIN;
SELECT stock FROM products WHERE id = 1 FOR UPDATE NOWAIT;
-- Continues immediately (or throws error if locked)
COMMIT;

-- Table-level lock
BEGIN;
LOCK TABLE products IN EXCLUSIVE MODE;
UPDATE products SET stock = stock - 10 WHERE id = 1;
COMMIT;

-- Advisory lock
SELECT pg_advisory_lock(12345);
UPDATE products SET stock = stock - 1 WHERE id = 1;
SELECT pg_advisory_unlock(12345);
```

**Solution 6.2.5: Complete Checkout Process**
```sql
CREATE OR REPLACE FUNCTION checkout(
    p_user_id UUID,
    p_items JSONB
)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
    v_item JSONB;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_price NUMERIC;
    v_stock INTEGER;
    v_subtotal NUMERIC := 0;
BEGIN
    BEGIN
        -- 1. Create order
        INSERT INTO orders (user_id, status)
        VALUES (p_user_id, 'pending')
        RETURNING id INTO v_order_id;
        
        -- 2. Process each item
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;
            
            -- 3. Lock product and get current stock
            SELECT price, stock_quantity INTO v_price, v_stock
            FROM products
            WHERE id = v_product_id
            FOR UPDATE;
            
            -- 4. Check inventory
            IF v_stock < v_quantity THEN
                RAISE EXCEPTION 'Insufficient stock for product %', v_product_id;
            END IF;
            
            -- 5. Reduce stock
            UPDATE products 
            SET stock_quantity = stock_quantity - v_quantity
            WHERE id = v_product_id;
            
            -- 6. Add order item
            INSERT INTO order_items (
                order_id,
                product_id,
                quantity,
                unit_price,
                total_price
            ) VALUES (
                v_order_id,
                v_product_id,
                v_quantity,
                v_price,
                v_price * v_quantity
            );
            
            v_subtotal := v_subtotal + (v_price * v_quantity);
        END LOOP;
        
        -- 7. Update order totals
        UPDATE orders 
        SET 
            total = v_subtotal + (v_subtotal * 0.08),
            status = 'paid'
        WHERE id = v_order_id;
        
        -- 8. Commit
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

### Solutions to Challenge Problems

**Solution Challenge 1: Inventory System with Concurrency**
```sql
CREATE OR REPLACE FUNCTION reserve_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_order_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_stock INTEGER;
BEGIN
    BEGIN
        -- Lock product row
        SELECT stock_quantity INTO v_current_stock
        FROM products
        WHERE id = p_product_id
        FOR UPDATE NOWAIT;
        
        -- Check stock
        IF v_current_stock < p_quantity THEN
            RETURN FALSE;
        END IF;
        
        -- Update stock
        UPDATE products 
        SET stock_quantity = stock_quantity - p_quantity
        WHERE id = p_product_id;
        
        -- Log transaction
        INSERT INTO inventory_transactions (
            product_id,
            transaction_type,
            quantity,
            previous_stock,
            new_stock,
            reference_id,
            reference_type
        ) VALUES (
            p_product_id,
            'reserve',
            -p_quantity,
            v_current_stock,
            v_current_stock - p_quantity,
            p_order_id,
            'order'
        );
        
        COMMIT;
        RETURN TRUE;
        
    EXCEPTION
        WHEN lock_not_available THEN
            ROLLBACK;
            RETURN FALSE;
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;
```

**Solution Challenge 2: Performance Optimization**
```sql
-- Original slow query
EXPLAIN ANALYZE
SELECT o.id, u.email, SUM(oi.total_price) AS revenue
FROM orders o
JOIN users u ON u.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
WHERE o.created_at > '2024-01-01'
GROUP BY o.id, u.email
ORDER BY revenue DESC;

-- Add indexes
CREATE INDEX idx_orders_created_at_user ON orders(created_at, user_id);
CREATE INDEX idx_order_items_order_price ON order_items(order_id, total_price);
CREATE INDEX idx_users_email ON users(email);

-- Optimized query with covering index
EXPLAIN ANALYZE
SELECT o.id, u.email, COALESCE(SUM(oi.total_price), 0) AS revenue
FROM orders o
JOIN users u ON u.id = o.user_id
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE o.created_at > '2024-01-01'
GROUP BY o.id, u.email
ORDER BY revenue DESC;
```

**Solution Challenge 3: Distributed Transaction Pattern**
```sql
CREATE OR REPLACE FUNCTION distributed_transaction(
    p_operations JSONB
)
RETURNS BOOLEAN AS $$
DECLARE
    v_op JSONB;
    v_step INTEGER := 0;
BEGIN
    BEGIN
        -- Phase 1: Prepare (validate)
        FOR v_op IN SELECT * FROM jsonb_array_elements(p_operations)
        LOOP
            v_step := v_step + 1;
            
            -- Validate each operation
            IF v_op->>'type' = 'stock_transfer' THEN
                PERFORM 1 FROM products WHERE id = (v_op->>'product_id')::INTEGER AND stock_quantity >= (v_op->>'quantity')::INTEGER;
                IF NOT FOUND THEN
                    RAISE EXCEPTION 'Validation failed at step %', v_step;
                END IF;
            END IF;
            
            -- Save checkpoint
            SAVEPOINT op_checkpoint;
        END LOOP;
        
        -- Phase 2: Execute
        FOR v_op IN SELECT * FROM jsonb_array_elements(p_operations)
        LOOP
            SAVEPOINT execute_checkpoint;
            
            CASE v_op->>'type'
                WHEN 'stock_transfer' THEN
                    UPDATE products 
                    SET stock_quantity = stock_quantity - (v_op->>'quantity')::INTEGER
                    WHERE id = (v_op->>'product_id')::INTEGER;
                    
                WHEN 'order_create' THEN
                    INSERT INTO orders (user_id, total) 
                    VALUES ((v_op->>'user_id')::UUID, (v_op->>'total')::NUMERIC);
                    
                ELSE
                    RAISE EXCEPTION 'Unknown operation type';
            END CASE;
            
            -- Log success
            INSERT INTO transaction_log (operation, details, status)
            VALUES (v_op->>'type', v_op::TEXT, 'success');
            
            RELEASE SAVEPOINT execute_checkpoint;
        END LOOP;
        
        COMMIT;
        RETURN TRUE;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback to last savepoint or full rollback
            ROLLBACK;
            
            -- Log failure
            INSERT INTO transaction_log (operation, details, status, error)
            VALUES ('rollback', p_operations::TEXT, 'failed', SQLERRM);
            
            RETURN FALSE;
    END;
END;
$$ LANGUAGE plpgsql;
```

---

# WORKBOOK CONCLUSION

## Final Assessment

### Self-Evaluation

Rate your confidence level (1-5) for each skill:

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Writing SELECT queries | | | | | |
| Using WHERE filters | | | | | |
| INSERT, UPDATE, DELETE | | | | | |
| Creating tables with constraints | | | | | |
| Working with JSONB | | | | | |
| Writing JOIN queries | | | | | |
| Using window functions | | | | | |
| Creating indexes | | | | | |
| Using transactions | | | | | |
| Analyzing query performance | | | | | |

### Next Steps

**Review Weak Areas:**
- Re-read the relevant tutorial sections
- Complete additional practice exercises
- Build a small project using the skill

**Build Your Own Project:**
- Create a database for a different domain
- Add real-world data
- Build a simple application on top

**Continue Learning:**
- PostgreSQL official documentation
- Online courses and tutorials
- Community forums and discussion groups

---

**Congratulations on completing the Hands-On PostgreSQL Student Workbook!**

You've built a complete e-commerce database and mastered PostgreSQL fundamentals. Keep practicing and building!
