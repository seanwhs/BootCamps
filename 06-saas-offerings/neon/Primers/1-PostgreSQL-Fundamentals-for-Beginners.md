# Serverless Postgres with Neon: From Zero to Production

## Primer 1: PostgreSQL Fundamentals for Beginners

### Overview

This primer is designed for developers who are new to PostgreSQL or relational databases in general. Before diving into the main series, this primer will give you a solid foundation in PostgreSQL concepts, terminology, and basic operations. Think of this as your "PostgreSQL 101" course that will make the rest of the series much more approachable.

---

### P1.1 What is PostgreSQL?

**PostgreSQL** (often called "Postgres") is a powerful, open-source object-relational database system. It's been actively developed for over 30 years and is known for its reliability, feature completeness, and performance.

#### Why PostgreSQL?

- **ACID Compliant**: Guarantees data integrity
- **Extensible**: Add custom functions, data types, and languages
- **Standards Compliant**: Follows SQL standards closely
- **Active Community**: Extensive documentation and support
- **Advanced Features**: JSON support, full-text search, GIS capabilities
- **Free and Open Source**: No licensing costs

#### PostgreSQL vs. Other Databases

| Feature | PostgreSQL | MySQL | MongoDB | Oracle |
|---------|-----------|-------|---------|--------|
| Type | Relational | Relational | Document | Relational |
| ACID Compliance | ✅ Full | Partial | Partial | Full |
| JSON Support | ✅ Excellent | Limited | Native | Limited |
| Cost | Free | Free | Free/Paid | Expensive |
| Performance | High | High | High | High |
| Scalability | Vertical | Vertical | Horizontal | Vertical |

---

### P1.2 Core Database Concepts

#### Databases, Tables, and Schemas

Think of a database like a filing cabinet:

```
Database (Filing Cabinet)
├── Schema (Drawer)
│   ├── Table (Folder)
│   │   ├── Columns (Form Fields)
│   │   │   ├── id (Number)
│   │   │   ├── name (Text)
│   │   │   └── price (Money)
│   │   └── Rows (Individual Forms)
│   │       ├── Row 1: (1, "Product A", 19.99)
│   │       └── Row 2: (2, "Product B", 29.99)
│   └── Table (Folder)
│       └── ...
└── Another Schema (Drawer)
    └── ...
```

**Key Terms**:

- **Database**: A collection of related data
- **Schema**: A logical container for database objects (like a folder)
- **Table**: A structured collection of data (like a spreadsheet)
- **Column**: A specific field in a table (like a column in a spreadsheet)
- **Row**: A single record in a table (like a row in a spreadsheet)
- **Primary Key**: A unique identifier for each row
- **Foreign Key**: A reference to a primary key in another table

#### Data Types

Just like programming languages, PostgreSQL has different data types for different kinds of data:

```sql
-- Common Data Types

-- Text Types
VARCHAR(255)    -- Variable length text, max 255 characters
TEXT            -- Unlimited length text
CHAR(10)        -- Fixed length text (always 10 characters)

-- Numeric Types
INTEGER         -- Whole numbers (-2.1B to 2.1B)
BIGINT          -- Large whole numbers
NUMERIC(10,2)   -- Exact decimal (10 digits total, 2 after decimal)
REAL            -- Approximate floating point (4 bytes)
DOUBLE          -- Approximate floating point (8 bytes)

-- Date/Time Types
DATE            -- Just the date (no time)
TIME            -- Just the time (no date)
TIMESTAMP       -- Date and time (no timezone)
TIMESTAMPTZ     -- Date and time WITH timezone (recommended)

-- Other Types
BOOLEAN         -- true/false
UUID            -- Universally unique identifier
JSONB           -- Binary JSON (for flexible data)
ARRAY           -- Array of values
```

#### Constraints

Constraints are rules that ensure data integrity. Think of them as "traffic rules" for your data:

```sql
-- NOT NULL: Column must have a value
name VARCHAR(255) NOT NULL

-- UNIQUE: All values must be different
email VARCHAR(255) UNIQUE

-- PRIMARY KEY: Unique identifier for each row
id SERIAL PRIMARY KEY

-- FOREIGN KEY: References another table's primary key
user_id INTEGER REFERENCES users(id)

-- CHECK: Custom validation rule
price NUMERIC(10,2) CHECK (price >= 0)
age INTEGER CHECK (age >= 0 AND age <= 150)

-- DEFAULT: Value if none provided
created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
```

---

### P1.3 Basic SQL Operations (CRUD)

SQL (Structured Query Language) is how you communicate with the database. Let's learn the four basic operations:

#### CREATE (INSERT)

Add new data to a table:

```sql
-- Insert a single row
INSERT INTO products (name, description, price, stock_quantity)
VALUES ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 100);

-- Insert multiple rows
INSERT INTO products (name, price, stock_quantity) VALUES
    ('Keyboard', 49.99, 50),
    ('Monitor', 299.99, 25),
    ('Webcam', 79.99, 75);

-- Insert and get the new ID back
INSERT INTO products (name, price) 
VALUES ('Speakers', 89.99) 
RETURNING id;
```

#### READ (SELECT)

Retrieve data from a table:

```sql
-- Get all columns for all rows
SELECT * FROM products;

-- Get specific columns
SELECT name, price FROM products;

-- Filter rows
SELECT * FROM products WHERE price > 100;

-- Filter with multiple conditions
SELECT * FROM products 
WHERE price > 50 AND stock_quantity > 0;

-- Order results
SELECT * FROM products ORDER BY price DESC;

-- Limit results
SELECT * FROM products LIMIT 5;

-- Page through results
SELECT * FROM products LIMIT 10 OFFSET 20;
```

#### UPDATE

Modify existing data:

```sql
-- Update a single column
UPDATE products 
SET price = 39.99 
WHERE name = 'Wireless Mouse';

-- Update multiple columns
UPDATE products 
SET price = 54.99, stock_quantity = 25 
WHERE name = 'Keyboard';

-- Update with calculations
UPDATE products 
SET price = price * 1.10 
WHERE price < 50;

-- Always use WHERE, or you'll update ALL rows!
```

#### DELETE

Remove data:

```sql
-- Delete specific rows
DELETE FROM products WHERE id = 5;

-- Delete with conditions
DELETE FROM products WHERE stock_quantity = 0;

-- Delete all rows (be careful!)
DELETE FROM products;  -- Removes all data!

-- Better: Soft delete (mark as deleted)
UPDATE products SET deleted_at = CURRENT_TIMESTAMP WHERE id = 5;
```

---

### P1.4 Filtering and Searching

#### WHERE Clause Basics

```sql
-- Comparison Operators
=   -- Equal
!=  -- Not equal
>   -- Greater than
<   -- Less than
>=  -- Greater than or equal
<=  -- Less than or equal

-- Examples
SELECT * FROM products WHERE price = 29.99;
SELECT * FROM products WHERE stock_quantity > 50;
SELECT * FROM products WHERE name != 'Keyboard';
```

#### Logical Operators

```sql
-- AND: Both conditions must be true
SELECT * FROM products 
WHERE price > 50 AND stock_quantity > 0;

-- OR: At least one condition must be true
SELECT * FROM products 
WHERE price < 10 OR price > 100;

-- NOT: Reverse the condition
SELECT * FROM products 
WHERE NOT (price > 100);
```

#### Pattern Matching

```sql
-- LIKE: Case-sensitive pattern matching
SELECT * FROM products WHERE name LIKE 'K%';  -- Starts with 'K'
SELECT * FROM products WHERE name LIKE '%er';  -- Ends with 'er'
SELECT * FROM products WHERE name LIKE '%om%';  -- Contains 'om'

-- ILIKE: Case-insensitive pattern matching
SELECT * FROM products WHERE name ILIKE '%keyboard%';

-- Pattern symbols
% -- Any number of characters
_ -- Exactly one character
[abc] -- Any character in the set (not in standard PostgreSQL)

-- Regular expressions
SELECT * FROM products 
WHERE name ~* '^[a-z]+';  -- Starts with a letter
```

#### NULL Handling

```sql
-- NULL means "unknown" or "no value"
-- IS NULL: Check for NULL
SELECT * FROM products WHERE description IS NULL;

-- IS NOT NULL: Check for non-NULL
SELECT * FROM products WHERE description IS NOT NULL;

-- COALESCE: Replace NULL with a default value
SELECT COALESCE(description, 'No description') FROM products;
```

---

### P1.5 Joining Tables

Joins combine data from multiple tables. Imagine you have a customers table and an orders table:

```sql
-- customers table
-- id | name    | email
-- 1  | Alice   | alice@email.com
-- 2  | Bob     | bob@email.com

-- orders table
-- id | customer_id | total
-- 1  | 1           | 99.99
-- 2  | 1           | 49.99
-- 3  | 2           | 149.99
```

#### INNER JOIN

Returns only rows where both tables have a match:

```sql
SELECT 
    customers.name,
    orders.total
FROM customers
INNER JOIN orders ON customers.id = orders.customer_id;

-- Result:
-- name  | total
-- Alice | 99.99
-- Alice | 49.99
-- Bob   | 149.99
```

#### LEFT JOIN

Returns all rows from the left table, even if no match:

```sql
SELECT 
    customers.name,
    orders.total
FROM customers
LEFT JOIN orders ON customers.id = orders.customer_id;

-- Result:
-- name  | total
-- Alice | 99.99
-- Alice | 49.99
-- Bob   | 149.99
-- Carol | NULL    (Carol has no orders)
```

#### RIGHT JOIN

Returns all rows from the right table:

```sql
SELECT 
    customers.name,
    orders.total
FROM customers
RIGHT JOIN orders ON customers.id = orders.customer_id;

-- Same as INNER JOIN in this example
```

#### Multiple Joins

```sql
SELECT 
    customers.name,
    orders.total,
    order_items.product_name
FROM customers
INNER JOIN orders ON customers.id = orders.customer_id
INNER JOIN order_items ON orders.id = order_items.order_id;
```

#### Self Join

Joining a table to itself (e.g., employees with managers):

```sql
SELECT 
    e1.name AS employee,
    e2.name AS manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;
```

---

### P1.6 Aggregations and Grouping

#### Aggregate Functions

Aggregate functions perform calculations on a set of rows:

```sql
-- COUNT: Number of rows
SELECT COUNT(*) FROM products;  -- Total products
SELECT COUNT(DISTINCT category) FROM products;  -- Unique categories

-- SUM: Add up values
SELECT SUM(price) FROM products;  -- Total value of all products

-- AVG: Average value
SELECT AVG(price) FROM products;  -- Average product price

-- MIN/MAX: Minimum/Maximum
SELECT MIN(price), MAX(price) FROM products;
```

#### GROUP BY

Groups rows with the same values:

```sql
-- Count products by category
SELECT 
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category;

-- Average price by category
SELECT 
    category,
    AVG(price) AS avg_price
FROM products
GROUP BY category
ORDER BY avg_price DESC;

-- Multiple columns
SELECT 
    category,
    status,
    COUNT(*)
FROM products
GROUP BY category, status;
```

#### HAVING

Filters groups (like WHERE for groups):

```sql
-- Categories with more than 5 products
SELECT 
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category
HAVING COUNT(*) > 5;

-- Categories with average price > 100
SELECT 
    category,
    AVG(price) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 100;
```

---

### P1.7 Subqueries

A query inside another query:

```sql
-- Subquery in WHERE
SELECT * FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Subquery with IN
SELECT * FROM users
WHERE id IN (
    SELECT DISTINCT user_id FROM orders
);

-- Subquery with EXISTS
SELECT * FROM users
WHERE EXISTS (
    SELECT 1 FROM orders WHERE user_id = users.id
);

-- Subquery in SELECT
SELECT 
    name,
    price,
    (SELECT AVG(price) FROM products) AS avg_price
FROM products;
```

---

### P1.8 Common Table Expressions (CTEs)

CTEs make complex queries more readable:

```sql
-- Basic CTE
WITH expensive_products AS (
    SELECT * FROM products WHERE price > 100
)
SELECT name, price FROM expensive_products;

-- Multiple CTEs
WITH 
    expensive_products AS (
        SELECT * FROM products WHERE price > 100
    ),
    high_stock AS (
        SELECT * FROM products WHERE stock_quantity > 50
    )
SELECT * FROM expensive_products
UNION
SELECT * FROM high_stock;

-- Recursive CTE (for hierarchical data)
WITH RECURSIVE category_tree AS (
    -- Base case: root categories
    SELECT id, name, parent_id, 0 AS level
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case: child categories
    SELECT c.id, c.name, c.parent_id, ct.level + 1
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree;
```

---

### P1.9 Indexes

Indexes speed up data retrieval (like a book index):

```sql
-- Create an index
CREATE INDEX idx_products_name ON products(name);

-- Create a unique index
CREATE UNIQUE INDEX idx_products_sku ON products(sku);

-- Create a composite index
CREATE INDEX idx_products_category_price ON products(category, price);

-- Create a partial index
CREATE INDEX idx_products_active ON products(name) WHERE deleted_at IS NULL;

-- Check if indexes are being used
EXPLAIN SELECT * FROM products WHERE name = 'Keyboard';

-- List indexes
SELECT * FROM pg_indexes WHERE tablename = 'products';
```

**When to use indexes**:
- Columns used in WHERE clauses frequently
- Foreign key columns
- Columns used in ORDER BY
- Columns used in JOIN conditions

**When NOT to use indexes**:
- Small tables (< 100 rows)
- Columns with very few unique values
- Columns that are updated frequently
- Tables that are mostly read-only

---

### P1.10 Transactions

Transactions ensure data consistency:

```sql
-- Start a transaction
BEGIN;

-- Perform multiple operations
INSERT INTO orders (user_id, total) VALUES (1, 99.99);
INSERT INTO order_items (order_id, product_id, quantity) 
VALUES (LASTVAL(), 1, 1);
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE id = 1;

-- If everything is correct, commit
COMMIT;

-- If something went wrong, rollback
ROLLBACK;

-- Savepoints (partial rollbacks)
BEGIN;
INSERT INTO orders (user_id, total) VALUES (1, 99.99);
SAVEPOINT order_created;
INSERT INTO order_items (order_id, product_id, quantity) VALUES (LASTVAL(), 1, 1);
-- Oops, something went wrong!
ROLLBACK TO SAVEPOINT order_created;
-- Continue with other operations
COMMIT;
```

**ACID Properties**:
- **Atomicity**: All or nothing
- **Consistency**: Data remains valid
- **Isolation**: Transactions don't interfere
- **Durability**: Committed data survives failures

---

### P1.11 Views

Views are virtual tables (saved queries):

```sql
-- Create a view
CREATE VIEW active_products AS
SELECT * FROM products WHERE deleted_at IS NULL;

-- Use the view like a table
SELECT * FROM active_products WHERE price > 100;

-- Create a view with joins
CREATE VIEW order_summary AS
SELECT 
    o.id,
    o.order_date,
    u.name AS customer_name,
    o.total
FROM orders o
JOIN users u ON o.user_id = u.id;

-- Create a materialized view (stored physically)
CREATE MATERIALIZED VIEW daily_sales AS
SELECT 
    DATE(order_date) AS sale_date,
    SUM(total) AS daily_total
FROM orders
GROUP BY DATE(order_date);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW daily_sales;
```

---

### P1.12 Functions and Stored Procedures

Custom functions for reusable logic:

```sql
-- Simple function
CREATE OR REPLACE FUNCTION calculate_discount(price NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN price * 0.10;  -- 10% discount
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT calculate_discount(100.00);  -- Returns 10.00

-- Function with parameters
CREATE OR REPLACE FUNCTION get_products_by_category(p_category VARCHAR)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    price NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.name, p.price
    FROM products p
    WHERE p.category = p_category;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM get_products_by_category('Electronics');

-- Function with validation
CREATE OR REPLACE FUNCTION add_product(
    p_name VARCHAR,
    p_price NUMERIC,
    p_stock INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    v_product_id INTEGER;
BEGIN
    -- Validate inputs
    IF p_price <= 0 THEN
        RAISE EXCEPTION 'Price must be greater than 0';
    END IF;
    
    IF p_stock < 0 THEN
        RAISE EXCEPTION 'Stock cannot be negative';
    END IF;
    
    -- Insert product
    INSERT INTO products (name, price, stock_quantity)
    VALUES (p_name, p_price, p_stock)
    RETURNING id INTO v_product_id;
    
    RETURN v_product_id;
END;
$$ LANGUAGE plpgsql;
```

---

### P1.13 Triggers

Triggers automatically run code on certain events:

```sql
-- Create a trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Now updated_at automatically updates on any change
UPDATE products SET price = 29.99 WHERE id = 1;
-- updated_at automatically set to current timestamp
```

---

### P1.14 JSON Support

PostgreSQL has excellent JSON support:

```sql
-- Create a table with JSONB column
CREATE TABLE product_attributes (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    attributes JSONB
);

-- Insert JSON data
INSERT INTO product_attributes (product_id, attributes) VALUES 
(1, '{"color": "Black", "size": "Medium", "material": "Cotton"}'::jsonb),
(2, '{"color": "White", "features": ["waterproof", "wireless"], "weight": "150g"}'::jsonb);

-- Query JSON data
SELECT 
    product_id,
    attributes->>'color' AS color,
    attributes->'features' AS features
FROM product_attributes;

-- Query nested JSON
SELECT 
    product_id,
    attributes#>>'{features,0}' AS first_feature
FROM product_attributes;

-- JSON containment query
SELECT * FROM product_attributes
WHERE attributes @> '{"color": "Black"}'::jsonb;

-- Update JSON data
UPDATE product_attributes
SET attributes = attributes || '{"in_stock": true}'::jsonb
WHERE product_id = 1;
```

---

### P1.15 Common Mistakes & Best Practices

#### Mistakes to Avoid

```sql
-- 1. Forgetting WHERE in UPDATE/DELETE
UPDATE products SET price = 0;  -- Updates ALL rows!

-- 2. Not handling NULL
SELECT * FROM products WHERE price = NULL;  -- No results! Use IS NULL
SELECT * FROM products WHERE price IS NULL;  -- Correct

-- 3. Using OR incorrectly
SELECT * FROM products WHERE price > 100 OR category = 'Electronics';
-- Use parentheses for complex conditions
SELECT * FROM products WHERE (price > 100) OR (category = 'Electronics');

-- 4. Not using indexes
-- Without index: slow
SELECT * FROM products WHERE name = 'Keyboard';
-- With index: fast
CREATE INDEX idx_products_name ON products(name);
```

#### Best Practices

```sql
-- 1. Use meaningful names
CREATE TABLE product_categories (  -- Clear name
    category_id SERIAL PRIMARY KEY,  -- Descriptive column
    category_name VARCHAR(100) NOT NULL
);

-- 2. Always specify columns in INSERT
-- Bad
INSERT INTO products VALUES (1, 'Product', 19.99);
-- Good
INSERT INTO products (id, name, price) VALUES (1, 'Product', 19.99);

-- 3. Use transactions for related operations
BEGIN;
INSERT INTO orders (...);
INSERT INTO order_items (...);
COMMIT;

-- 4. Use LIMIT for large result sets
SELECT * FROM orders WHERE user_id = 1 LIMIT 10;

-- 5. Use EXPLAIN to analyze queries
EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'pending';

-- 6. Use CTEs for complex queries instead of nested subqueries
WITH active_users AS (
    SELECT * FROM users WHERE status = 'active'
)
SELECT * FROM active_users WHERE id IN (SELECT user_id FROM orders);
```

---

### P1.16 Practice Exercises

Try these exercises to reinforce your learning:

```sql
-- Exercise 1: Create a simple product table
-- 1. Create a table called "products" with columns: id (SERIAL PRIMARY KEY), 
--    name (TEXT NOT NULL), price (NUMERIC(10,2) NOT NULL), and 
--    stock_quantity (INTEGER DEFAULT 0)
-- 2. Insert 5 products
-- 3. Query products with price > 50
-- 4. Update the price of one product
-- 5. Delete a product with stock_quantity = 0

-- Solution:
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0
);

INSERT INTO products (name, price, stock_quantity) VALUES
    ('Laptop', 999.99, 10),
    ('Mouse', 29.99, 50),
    ('Keyboard', 49.99, 25),
    ('Monitor', 299.99, 15),
    ('Printer', 199.99, 0);

SELECT * FROM products WHERE price > 50;

UPDATE products SET price = 999.00 WHERE name = 'Laptop';

DELETE FROM products WHERE stock_quantity = 0;

-- Exercise 2: Create a users and orders relationship
-- 1. Create a "users" table with id, name, email
-- 2. Create an "orders" table with id, user_id, total, order_date
-- 3. Insert some users and orders
-- 4. Write a query to get all orders with user names
-- 5. Write a query to get total spent by each user

-- Solution:
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total NUMERIC(10,2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES 
    ('Alice', 'alice@email.com'),
    ('Bob', 'bob@email.com');

INSERT INTO orders (user_id, total) VALUES 
    (1, 99.99),
    (1, 149.99),
    (2, 249.99);

SELECT 
    u.name,
    o.id,
    o.total,
    o.order_date
FROM users u
JOIN orders o ON u.id = o.user_id;

SELECT 
    u.name,
    SUM(o.total) AS total_spent,
    COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;
```

---

### Summary

Congratulations! You've completed the PostgreSQL fundamentals primer. You now understand:

- **Core concepts**: Databases, tables, columns, rows, schemas
- **CRUD operations**: INSERT, SELECT, UPDATE, DELETE
- **Filtering**: WHERE, LIKE, NULL handling
- **Joins**: INNER, LEFT, RIGHT, SELF joins
- **Aggregations**: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
- **Subqueries and CTEs**: Nested queries and common table expressions
- **Indexes**: Speeding up queries
- **Transactions**: Ensuring data consistency
- **Views**: Saved queries
- **Functions and Triggers**: Custom logic
- **JSONB**: Flexible data storage

You're now ready to dive into the main series and build your e-commerce application with Neon PostgreSQL!
