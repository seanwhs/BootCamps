# Primer 3: Database Design Fundamentals

Welcome to the third primer! This primer is designed for readers who want to understand how to design databases properly. While you can create tables without a plan, proper database design ensures your data is organized, efficient, and free from errors. Think of this as learning architectural principles before building a house—you want a solid foundation that won't collapse.

---

## P3.1 Why Database Design Matters

### The Target
Understand why good database design is critical for application success.

### The Concept
Poorly designed databases are like poorly built houses—they work initially but become problematic over time. Common issues include duplicate data, inconsistent information, slow queries, and difficulty adding new features. Good design prevents these problems.

### The Implementation

**Signs of a Poorly Designed Database:**

```
BAD DESIGN EXAMPLE: One giant table with everything

┌─────────────────────────────────────────────────────────────────────┐
│                        orders_all_in_one                           │
├─────────┬──────────┬──────────┬───────────┬──────────┬───────────┤
│ order_id│ user_name│ user_email│ product_name│ product_price│ quantity│
├─────────┼──────────┼──────────┼────────────┼──────────────┼─────────┤
│ 1       │ John     │ john@e.. │ Headphones  │ 79.99       │ 1       │
│ 1       │ John     │ john@e.. │ USB Cable   │ 12.99       │ 2       │
│ 2       │ Jane     │ jane@e.. │ Laptop      │ 999.99      │ 1       │
│ 3       │ John     │ john@e.. │ Mouse       │ 29.99       │ 1       │
├─────────┴──────────┴──────────┴────────────┴──────────────┴─────────┤
│ PROBLEMS:                                                           │
│ - John's name appears multiple times (duplicate)                    │
│ - If John's email changes, we must update many rows                 │
│ - Can't easily count how many orders John has                       │
│ - Can't track product details without repeating them                │
│ - Adding a new product requires duplicating order info              │
└─────────────────────────────────────────────────────────────────────┘
```

```sql
-- Example of a poorly designed table
CREATE TABLE bad_orders (
    order_id INTEGER,
    user_name TEXT,
    user_email TEXT,
    product_name TEXT,
    product_price DECIMAL(10,2),
    quantity INTEGER,
    order_date DATE
);

-- Inserting data creates duplicates
INSERT INTO bad_orders VALUES 
    (1, 'John Doe', 'john@email.com', 'Headphones', 79.99, 1, '2024-01-01'),
    (1, 'John Doe', 'john@email.com', 'USB Cable', 12.99, 2, '2024-01-01'),
    (2, 'Jane Smith', 'jane@email.com', 'Laptop', 999.99, 1, '2024-01-02'),
    (3, 'John Doe', 'john@email.com', 'Mouse', 29.99, 1, '2024-01-03');

-- Problems in action:
-- 1. Updating John's email requires updating multiple rows
UPDATE bad_orders SET user_email = 'john.new@email.com' WHERE user_name = 'John Doe';

-- 2. Counting John's orders requires looking at many rows
SELECT COUNT(DISTINCT order_id) FROM bad_orders WHERE user_name = 'John Doe';

-- 3. Adding a new product to an existing order is complicated
-- You need to duplicate all the order info
```

### The Verification

```bash
# No code to run, but let's discuss:
# 1. What's wrong with the bad_orders table design?
# 2. How would you fix it?
# 3. What problems would you run into as the database grows?
```

---

## P3.2 The Entity-Relationship Model

### The Target
Understand entities, attributes, and relationships—the building blocks of database design.

### The Concept
An Entity is a "thing" you want to track (e.g., Customer, Order, Product). Attributes are details about that thing (e.g., Customer name, Order date). Relationships describe how entities connect (e.g., a Customer places Orders).

### The Implementation

**Entities and Attributes:**

```
┌─────────────────────────────────────────────────────────────────┐
│                        ENTITY RELATIONSHIP DIAGRAM             │
│                                                                 │
│  ┌──────────────┐          ┌──────────────┐                   │
│  │   CUSTOMER   │          │    ORDER     │                   │
│  │──────────────│          │──────────────│                   │
│  │ id (PK)      │◄─────────│ id (PK)      │                   │
│  │ first_name   │   places  │ customer_id  │                   │
│  │ last_name    │          │ order_date   │                   │
│  │ email        │          │ total        │                   │
│  └──────────────┘          └──────┬───────┘                   │
│                                    │                           │
│                                    │ contains                  │
│                                    ▼                           │
│                            ┌──────────────┐                   │
│                            │  ORDER_ITEM  │                   │
│                            │──────────────│                   │
│                            │ id (PK)      │                   │
│                            │ order_id (FK)│                   │
│                            │ product_id   │                   │
│                            │ quantity     │                   │
│                            │ price        │                   │
│                            └──────┬───────┘                   │
│                                   │                           │
│                                   │ includes                  │
│                                   ▼                           │
│                            ┌──────────────┐                   │
│                            │   PRODUCT    │                   │
│                            │──────────────│                   │
│                            │ id (PK)      │                   │
│                            │ name         │                   │
│                            │ price        │                   │
│                            │ stock        │                   │
│                            └──────────────┘                   │
└─────────────────────────────────────────────────────────────────┘

LEGEND:
PK = Primary Key (unique identifier for this table)
FK = Foreign Key (reference to another table's primary key)
◄──────── = One-to-Many relationship
```

**Entity Definitions:**

```sql
-- Each entity becomes a table

-- Entity: Customer
CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    created_at TIMESTAMP
);

-- Entity: Order (relates to Customer)
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),  -- FK to Customer
    order_date TIMESTAMP,
    total DECIMAL(10,2)
);

-- Entity: Product
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price DECIMAL(10,2),
    stock INTEGER
);

-- Entity: Order_Item (relates Order and Product)
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),      -- FK to Order
    product_id INTEGER REFERENCES products(id),  -- FK to Product
    quantity INTEGER,
    price DECIMAL(10,2)  -- Price at time of order
);
```

### The Verification

```bash
# Identify entities and their relationships
# For an e-commerce store:
# 1. What entities would you need?
# 2. What attributes would each entity have?
# 3. What are the relationships between them?
```

---

## P3.3 Understanding Relationships

### The Target
Understand the three types of relationships and when to use each.

### The Concept
Relationships define how entities connect. There are three main types: One-to-One, One-to-Many, and Many-to-Many. Understanding these helps you properly connect your tables.

### The Implementation

**Relationship Types with Examples:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    1. ONE-TO-MANY (1:N)                        │
│                                                                 │
│  ┌──────────┐              ┌──────────┐                       │
│  │ Customer │ 1           N │  Order   │                       │
│  │          │──────────────►│          │                       │
│  └──────────┘              └──────────┘                       │
│                                                                 │
│  "One customer can have many orders"                            │
│  "Each order belongs to exactly one customer"                  │
│                                                                 │
│  Implementation: Foreign key in the "many" side (Orders)      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    2. MANY-TO-MANY (M:N)                       │
│                                                                 │
│  ┌──────────┐              ┌──────────┐                       │
│  │ Product  │ M           N │ Order    │                       │
│  │          │──────────────►│          │                       │
│  └──────────┘              └──────────┘                       │
│                                                                 │
│  "One product can be in many orders"                           │
│  "One order can contain many products"                         │
│                                                                 │
│  Implementation: Junction table (Order_Items)                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    3. ONE-TO-ONE (1:1)                          │
│                                                                 │
│  ┌──────────┐              ┌──────────┐                       │
│  │  User    │ 1           1 │ Profile  │                       │
│  │          │──────────────►│          │                       │
│  └──────────┘              └──────────┘                       │
│                                                                 │
│  "One user has one profile"                                    │
│  "One profile belongs to one user"                             │
│                                                                 │
│  Implementation: Foreign key in either table (usually one)    │
└─────────────────────────────────────────────────────────────────┘
```

```sql
-- 1. ONE-TO-MANY: Customer → Orders
CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),  -- FK on the many side
    order_date DATE
);

-- Query: Find all orders for a customer
SELECT o.* 
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE c.id = 1;

-- 2. MANY-TO-MANY: Products ↔ Orders (via Order_Items)
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price DECIMAL(10,2)
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    -- Primary key is the combination
    UNIQUE(order_id, product_id)
);

-- Query: Find all products in an order
SELECT p.name, oi.quantity
FROM products p
JOIN order_items oi ON oi.product_id = p.id
WHERE oi.order_id = 1;

-- Query: Find all orders containing a product
SELECT o.id, oi.quantity
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE oi.product_id = 1;

-- 3. ONE-TO-ONE: User → Profile (rarely needed)
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT
);

CREATE TABLE profiles (
    id INTEGER PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id),  -- UNIQUE makes it one-to-one
    bio TEXT,
    avatar_url TEXT
);

-- Query: Get a user with their profile
SELECT u.username, p.bio, p.avatar_url
FROM users u
JOIN profiles p ON p.user_id = u.id
WHERE u.id = 1;
```

### The Verification

```bash
# Test your understanding:
# 1. What relationship type is: Students and Classes?
#    Answer: Many-to-Many (students take many classes, classes have many students)

# 2. What relationship type is: Department and Manager?
#    Answer: One-to-One (each department has one manager)

# 3. What relationship type is: Author and Books?
#    Answer: One-to-Many (one author writes many books)
```

---

## P3.4 Normalization: The Art of Clean Design

### The Target
Understand normalization and how to apply it to design clean, efficient databases.

### The Concept
Normalization is the process of organizing data to reduce redundancy and improve integrity. Think of it as decluttering a room—you store things in logical places and avoid duplicates. There are several "normal forms," each addressing a specific type of problem.

### The Implementation

**The Normalization Journey:**

```
UNORMALIZED (Ugly)
┌──────────────────────────────────────────────────────────────┐
│ orders: order_id, customer_name, customer_address,          │
│          product1_name, product1_price, product2_name, ...  │
│                                                              │
│ PROBLEMS:                                                    │
│ - Can't have variable number of products                    │
│ - Wasted space for NULL values                              │
│ - Hard to query                                             │
└──────────────────────────────────────────────────────────────┘

1ST NORMAL FORM (1NF)
┌──────────────────────────────────────────────────────────────┐
│ orders: order_id, customer_name, customer_address,          │
│          product_name, product_price                        │
│                                                              │
│ FIXED: Each cell has one value (no arrays)                  │
│ PROBLEM: Still has duplicates (customer info repeated)      │
└──────────────────────────────────────────────────────────────┘

2ND NORMAL FORM (2NF)
┌──────────────────────────────────────────────────────────────┐
│ customers: customer_id, customer_name, customer_address     │
│ orders: order_id, customer_id, order_date                   │
│ order_items: order_id, product_name, product_price, quantity│
│                                                              │
│ FIXED: No more customer info duplicates                     │
│ PROBLEM: product info still repeated in order_items         │
└──────────────────────────────────────────────────────────────┘

3RD NORMAL FORM (3NF)
┌──────────────────────────────────────────────────────────────┐
│ customers: customer_id, customer_name, customer_address     │
│ orders: order_id, customer_id, order_date                   │
│ products: product_id, product_name, product_price           │
│ order_items: order_id, product_id, quantity                 │
│                                                              │
│ FIXED: No dependencies outside primary key                  │
│ ✅ This is the sweet spot for most applications             │
└──────────────────────────────────────────────────────────────┘
```

```sql
-- EXAMPLE: Converting from UNNORMALIZED to 3NF

-- 1. UNNORMALIZED (BAD)
-- One table with repeating groups
CREATE TABLE bad_order (
    order_id INTEGER PRIMARY KEY,
    customer_name TEXT,
    customer_address TEXT,
    product_1_name TEXT,
    product_1_price DECIMAL,
    product_2_name TEXT,
    product_2_price DECIMAL,
    product_3_name TEXT,
    product_3_price DECIMAL
);
-- Problem: Can only have up to 3 products, wastes space, hard to query

-- 2. 1NF (Better but still flawed)
-- Removed repeating groups, but now have duplicate customer data
CREATE TABLE order_1nf (
    order_id INTEGER,
    customer_name TEXT,
    customer_address TEXT,
    product_name TEXT,
    product_price DECIMAL,
    quantity INTEGER
);
-- Problem: Customer info repeated for each product in an order

-- 3. 2NF (Much better)
-- Separated customer data
CREATE TABLE customers_2nf (
    id INTEGER PRIMARY KEY,
    name TEXT,
    address TEXT
);

CREATE TABLE orders_2nf (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers_2nf(id),
    order_date DATE
);

CREATE TABLE order_items_2nf (
    id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders_2nf(id),
    product_name TEXT,
    product_price DECIMAL,
    quantity INTEGER
);
-- Problem: Product info repeated across orders

-- 4. 3NF (The sweet spot)
-- Fully normalized
CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name TEXT,
    address TEXT
);

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    order_date DATE
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    unit_price DECIMAL(10,2)  -- Price at time of order (historical snapshot)
);

-- This is the design used in the main tutorial series!
```

### The Verification

```bash
# No code to run, but identify normalization issues:

# Scenario: You have a table: employees (emp_id, emp_name, dept_name, dept_location)
# Is this normalized? What's the problem?

# Answer: Not normalized. Department information is repeated.
# Solution: Separate into employees and departments tables.

# Scenario: You have a table: orders (order_id, product_ids, quantities)
# Is this normalized? What's the problem?

# Answer: Not in 1NF. Product_ids and quantities are arrays.
# Solution: Use a junction table (order_items) with one product per row.
```

---

## P3.5 The Rules of Normalization

### The Target
Understand the specific rules for each normal form.

### The Concept
Each normal form has specific rules that define it. Understanding these rules helps you identify when your design is fully normalized and when you need to restructure.

### The Implementation

**Normal Form Rules:**

```
┌─────────────────────────────────────────────────────────────────┐
│ 1NF (First Normal Form)                                       │
│ Rules:                                                        │
│ - Each cell has a single value (no arrays)                    │
│ - Each row is unique                                          │
│ - Each column has a unique name                               │
│                                                               │
│ Example violation: orders (id, product1, product2, product3) │
│ Fix: Create separate rows for each product                   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 2NF (Second Normal Form)                                      │
│ Rules:                                                        │
│ - Must be in 1NF                                              │
│ - All non-key columns depend on the ENTIRE primary key       │
│                                                               │
│ Example violation: order_items (order_id, product_id,        │
│                     product_name, quantity)                   │
│ product_name depends only on product_id, not the full PK     │
│ Fix: Separate into products table                            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 3NF (Third Normal Form)                                       │
│ Rules:                                                        │
│ - Must be in 2NF                                              │
│ - No transitive dependencies (non-key depends on another     │
│   non-key column)                                             │
│                                                               │
│ Example violation: orders (id, customer_id, customer_name,   │
│                     customer_address)                         │
│ customer_name depends on customer_id, not the PK             │
│ Fix: Separate into customers table                           │
└─────────────────────────────────────────────────────────────────┘
```

```sql
-- DEMONSTRATING NORMALIZATION RULES

-- 1NF Violation: Table with array/relation in a cell
CREATE TABLE orders_1nf_violation (
    order_id INTEGER PRIMARY KEY,
    customer_name TEXT,
    products INTEGER[]  -- Array of product IDs
);
-- This violates 1NF

-- Fix: Separate into orders and order_items
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_name TEXT
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER
);
-- Now in 1NF

-- 2NF Violation: Partial dependency
-- Table: order_items (order_id, product_id, product_name, quantity)
-- Primary Key: (order_id, product_id)
-- product_name depends only on product_id (partial dependency)
CREATE TABLE order_items_2nf_violation (
    order_id INTEGER,
    product_id INTEGER,
    product_name TEXT,  -- Depends only on product_id
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);
-- This violates 2NF

-- Fix: Extract product_name into products table
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE order_items_fixed (
    order_id INTEGER,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);
-- Now in 2NF

-- 3NF Violation: Transitive dependency
-- Table: orders (id, customer_id, customer_name, customer_address)
-- customer_name and customer_address depend on customer_id, not the PK (id)
CREATE TABLE orders_3nf_violation (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    customer_name TEXT,    -- Depends on customer_id
    customer_address TEXT  -- Depends on customer_id
);
-- This violates 3NF

-- Fix: Extract into customers table
CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name TEXT,
    address TEXT
);

CREATE TABLE orders_fixed (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id)
);
-- Now in 3NF
```

### The Verification

```bash
# Check your understanding:
# For each table, identify what normal form it's in:

# Table A: employees (id, name, department, department_head)
# Answer: 2NF (department_head depends on department, not the PK)
# Fix: Separate into employees and departments

# Table B: student_courses (student_id, student_name, course_id, course_name)
# Answer: 2NF (student_name depends on student_id, course_name depends on course_id)
# Fix: Separate into students, courses, and enrollment

# Table C: addresses (id, street, city, state, country, country_code)
# Answer: 3NF (country_code depends on country, not the PK)
# Fix: Separate into addresses and countries
```

---

## P3.6 Denormalization: When to Break the Rules

### The Target
Understand when denormalization is appropriate and how to use it safely.

### The Concept
Denormalization is intentionally adding redundancy for performance reasons. Sometimes, the performance cost of joins outweighs the storage cost of duplication. Think of it as trading space for speed—like keeping a copy of your friend's phone number instead of looking it up every time.

### The Implementation

**When to Denormalize:**

```
┌─────────────────────────────────────────────────────────────────┐
│              PERFORMANCE vs NORMALIZATION                      │
│                                                                 │
│  High ────┐                                                   │
│           │  ┌──────────────────────────────────────┐          │
│           │  │    DENORMALIZED                      │          │
│           │  │  (Fast reads, slower writes)        │          │
│  Performance │                                      │          │
│           │  │         NORMALIZED                  │          │
│           │  │  (Clean design, slower reads)       │          │
│           │  └──────────────────────────────────────┘          │
│  Low ─────┴────────────────────────────────────────────────────│
│           Low                                   High           │
│           └───── Write Frequency ──────────────►               │
│                                                                 │
│  Use denormalization when:                                     │
│  - Reads heavily outnumber writes                              │
│  - Joins are too slow                                          │
│  - You need to cache frequently accessed data                  │
│  - You're building reporting or data warehouse systems         │
└─────────────────────────────────────────────────────────────────┘
```

```sql
-- 1. Common Denormalization Example: Order Summary
-- Normalized query (requires joins)
SELECT 
    o.id AS order_id,
    c.name AS customer_name,
    c.email AS customer_email,
    COUNT(oi.id) AS item_count,
    SUM(oi.quantity * oi.unit_price) AS total
FROM orders o
JOIN customers c ON c.id = o.customer_id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, c.name, c.email;

-- Denormalized approach: Add summary columns to orders
ALTER TABLE orders ADD COLUMN customer_name TEXT;
ALTER TABLE orders ADD COLUMN customer_email TEXT;
ALTER TABLE orders ADD COLUMN item_count INTEGER DEFAULT 0;
ALTER TABLE orders ADD COLUMN total DECIMAL(10,2) DEFAULT 0;

-- Now query is much simpler and faster
SELECT order_id, customer_name, customer_email, item_count, total
FROM orders;
-- But now customer info is duplicated!
-- If customer updates their email, we must update all their orders

-- 2. Denormalization with Trigger Maintenance
-- Keep denormalized columns updated automatically
CREATE OR REPLACE FUNCTION update_order_summary()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Update customer info from customers table
        UPDATE orders 
        SET customer_name = c.name,
            customer_email = c.email
        FROM customers c
        WHERE orders.id = NEW.order_id
          AND c.id = orders.customer_id;
        
        -- Update totals and counts
        UPDATE orders 
        SET item_count = (
            SELECT COUNT(*) 
            FROM order_items 
            WHERE order_id = NEW.order_id
        ),
        total = (
            SELECT COALESCE(SUM(quantity * unit_price), 0)
            FROM order_items 
            WHERE order_id = NEW.order_id
        )
        WHERE id = NEW.order_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER maintain_order_summary
AFTER INSERT OR UPDATE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_summary();

-- 3. Reporting Denormalization: Materialized Views
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    DATE(created_at) AS sale_date,
    COUNT(*) AS order_count,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_order_value
FROM orders
GROUP BY DATE(created_at);

-- Query the materialized view (very fast)
SELECT * FROM daily_sales_summary;

-- Refresh daily (or as needed)
REFRESH MATERIALIZED VIEW daily_sales_summary;

-- 4. Denormalization Example: Cache Popular Data
-- Create a product summary table (denormalized)
CREATE TABLE product_summary (
    product_id INTEGER PRIMARY KEY REFERENCES products(id),
    product_name TEXT,
    current_price DECIMAL(10,2),
    total_orders INTEGER,
    total_revenue DECIMAL(10,2),
    last_sold_date DATE,
    avg_rating DECIMAL(3,2)
);

-- Populate from normalized data
INSERT INTO product_summary (product_id, product_name, current_price,
    total_orders, total_revenue, last_sold_date)
SELECT 
    p.id,
    p.name,
    p.price,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    MAX(o.created_at) AS last_sold_date
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id
GROUP BY p.id, p.name, p.price;

-- Query is much faster for dashboard
SELECT product_name, total_orders, total_revenue
FROM product_summary
ORDER BY total_revenue DESC
LIMIT 10;
```

### The Verification

```bash
# When should you denormalize?
# Answer: When you have performance problems with joins and have high read volumes

# Trade-offs to consider:
# 1. Storage space (denormalized uses more)
# 2. Write performance (denormalized is slower)
# 3. Data consistency (risk of stale data)
# 4. Maintenance complexity (more complex code)

# Real-world example: Many e-commerce sites denormalize order totals
# because they're read frequently and rarely change after creation.
```

---

## P3.7 Keys and Constraints

### The Target
Understand the different types of keys and constraints in database design.

### The Concept
Keys and constraints enforce rules about your data. Think of them as the rulebook for your database—they prevent bad data from entering and ensure relationships are maintained.

### The Implementation

**Key Types:**

```
┌─────────────────────────────────────────────────────────────────┐
│                      KEY TYPES                                 │
├─────────────────────────────────────────────────────────────────┤
│ PRIMARY KEY (PK)                                              │
│ - Uniquely identifies each row                                │
│ - Cannot be NULL                                              │
│ - Only one per table                                          │
│ - Example: customer_id, order_id                              │
├─────────────────────────────────────────────────────────────────┤
│ FOREIGN KEY (FK)                                              │
│ - References a primary key in another table                   │
│ - Maintains referential integrity                             │
│ - Can be NULL                                                 │
│ - Example: order.customer_id references customers.id          │
├─────────────────────────────────────────────────────────────────┤
│ UNIQUE KEY                                                    │
│ - Ensures all values are unique                               │
│ - Can be NULL (multiple NULLs allowed)                        │
│ - Can have multiple per table                                 │
│ - Example: email, username                                    │
├─────────────────────────────────────────────────────────────────┤
│ CANDIDATE KEY                                                 │
│ - Any column that could be a primary key                      │
│ - Must be unique and NOT NULL                                 │
│ - Example: email (could be PK instead of id)                  │
├─────────────────────────────────────────────────────────────────┤
│ SURROGATE KEY                                                 │
│ - Artificial key (like SERIAL or UUID)                        │
│ - No business meaning                                         │
│ - Good for primary keys                                       │
│ - Example: auto-incrementing id                               │
├─────────────────────────────────────────────────────────────────┤
│ NATURAL KEY                                                   │
│ - Key with business meaning                                   │
│ - Example: email, SSN                                         │
│ - Can change over time (bad for PK)                           │
└─────────────────────────────────────────────────────────────────┘
```

```sql
-- 1. PRIMARY KEY
-- Surrogate key (recommended)
CREATE TABLE customers (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name TEXT,
    last_name TEXT,
    email TEXT UNIQUE  -- Natural key as UNIQUE constraint
);

-- Composite primary key (multiple columns)
CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);

-- 2. FOREIGN KEY
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Foreign key with ON DELETE CASCADE
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id)
);
-- If an order is deleted, all its items are automatically deleted

-- Foreign key with ON DELETE SET NULL
ALTER TABLE orders 
ADD COLUMN shipping_address_id INTEGER REFERENCES addresses(id) ON DELETE SET NULL;

-- 3. UNIQUE Constraint
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL
);

-- Unique constraint on multiple columns
CREATE TABLE product_attributes (
    product_id INTEGER,
    attribute_name TEXT,
    attribute_value TEXT,
    UNIQUE(product_id, attribute_name)
);

-- 4. CHECK Constraint
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    price DECIMAL(10,2) CHECK (price >= 0),
    stock_quantity INTEGER CHECK (stock_quantity >= 0)
);

-- Complex CHECK constraint
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    status TEXT,
    discount DECIMAL(5,2),
    total DECIMAL(10,2),
    CHECK (
        (status = 'cancelled' AND discount = 0) OR
        (status != 'cancelled')
    )
);

-- 5. NOT NULL Constraint
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department TEXT,  -- Can be NULL
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0)
);

-- 6. DEFAULT Constraint
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    order_date TIMESTAMP DEFAULT NOW(),
    status TEXT DEFAULT 'pending',
    is_active BOOLEAN DEFAULT TRUE
);
```

### The Verification

```bash
# Practice: Design a table with all constraint types

# Problem: Create a bookings table with:
# - Primary key: id
# - Foreign key: customer_id references customers
# - Not Null: customer_id, start_time
# - Unique: customer_id, start_time (one booking per customer per time)
# - Check: end_time > start_time
# - Default: created_at = NOW()

# Solution:
CREATE TABLE bookings (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(customer_id, start_time),
    CHECK (end_time > start_time)
);
```

---

## P3.8 Design Patterns for E-Commerce

### The Target
Learn common design patterns specifically for e-commerce applications.

### The Concept
E-commerce databases have well-established patterns. Learning these patterns saves you from reinventing the wheel and helps you avoid common pitfalls.

### The Implementation

```
┌─────────────────────────────────────────────────────────────────┐
│              E-COMMERCE DESIGN PATTERNS                        │
├─────────────────────────────────────────────────────────────────┤
│  PATTERN 1: Customer Account Pattern                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   CUSTOMERS  │    │   ADDRESSES  │    │    ORDERS    │   │
│  │──────────────│    │──────────────│    │──────────────│   │
│  │ id (PK)      │1──N│ id (PK)      │1──N│ id (PK)      │   │
│  │ email        │    │ customer_id  │    │ customer_id  │   │
│  │ first_name   │    │ address_type │    │ address_id   │   │
│  │ last_name    │    │ line1        │    │ order_date   │   │
│  │ password_hash│    │ city         │    │ status       │   │
│  └──────────────┘    │ state        │    │ total        │   │
│                      │ postal_code  │    └──────────────┘   │
│                      │ country      │                        │
│                      └──────────────┘                        │
├─────────────────────────────────────────────────────────────────┤
│  PATTERN 2: Shopping Cart Pattern                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   CARTS      │    │  CART_ITEMS  │    │   PRODUCTS   │   │
│  │──────────────│    │──────────────│    │──────────────│   │
│  │ id (PK)      │1──N│ id (PK)      │N──1│ id (PK)      │   │
│  │ user_id      │    │ cart_id (FK) │    │ name         │   │
│  │ session_id   │    │ product_id   │    │ price        │   │
│  │ expires_at   │    │ quantity     │    │ stock        │   │
│  └──────────────┘    │ price_snapshot│   └──────────────┘   │
│                      └──────────────┘                        │
├─────────────────────────────────────────────────────────────────┤
│  PATTERN 3: Order with Items Pattern                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   ORDERS     │    │ ORDER_ITEMS  │    │   PRODUCTS   │   │
│  │──────────────│    │──────────────│    │──────────────│   │
│  │ id (PK)      │1──N│ id (PK)      │N──1│ id (PK)      │   │
│  │ customer_id  │    │ order_id     │    │ name         │   │
│  │ order_date   │    │ product_id   │    │ current_price│   │
│  │ status       │    │ quantity     │    │ stock        │   │
│  │ total        │    │ unit_price   │    └──────────────┘   │
│  └──────────────┘    │ total_price  │                        │
│                      └──────────────┘                        │
├─────────────────────────────────────────────────────────────────┤
│  PATTERN 4: Inventory Management Pattern                     │
│  ┌──────────────┐    ┌─────────────────────────┐            │
│  │   PRODUCTS   │    │  INVENTORY_TRANSACTIONS │            │
│  │──────────────│    │─────────────────────────│            │
│  │ id (PK)      │1──N│ id (PK)                 │            │
│  │ name         │    │ product_id (FK)         │            │
│  │ stock        │    │ transaction_type        │            │
│  └──────────────┘    │ quantity                │            │
│                      │ previous_stock          │            │
│                      │ new_stock               │            │
│                      │ reference_id            │            │
│                      │ created_at              │            │
│                      └─────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

```sql
-- IMPLEMENTATION: Complete E-Commerce Schema

-- 1. Customers (with account pattern)
CREATE TABLE customers (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Addresses (with account pattern)
CREATE TABLE addresses (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_type TEXT DEFAULT 'shipping',  -- shipping, billing, both
    line1 TEXT NOT NULL,
    line2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Products (catalog)
CREATE TABLE products (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    cost DECIMAL(10,2) CHECK (cost >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB,  -- Flexible product attributes
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. Categories (many-to-many with products)
CREATE TABLE categories (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL UNIQUE,
    slug TEXT UNIQUE NOT NULL,
    parent_id INTEGER REFERENCES categories(id),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE product_categories (
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);

-- 5. Shopping Carts (cart pattern)
CREATE TABLE carts (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id INTEGER UNIQUE REFERENCES customers(id) ON DELETE CASCADE,
    session_id TEXT UNIQUE,
    status TEXT DEFAULT 'active',
    expires_at TIMESTAMP DEFAULT NOW() + INTERVAL '7 days',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CHECK (
        (customer_id IS NOT NULL AND session_id IS NULL) OR
        (customer_id IS NULL AND session_id IS NOT NULL)
    )
);

CREATE TABLE cart_items (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    cart_id INTEGER NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_snapshot DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(cart_id, product_id)
);

-- 6. Orders (order with items pattern)
CREATE TABLE orders (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    status TEXT DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    shipping_cost DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    shipping_address_id INTEGER REFERENCES addresses(id),
    billing_address_id INTEGER REFERENCES addresses(id),
    payment_method TEXT,
    payment_status TEXT DEFAULT 'pending',
    payment_transaction_id TEXT,
    tracking_number TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    product_name TEXT NOT NULL,  -- Snapshot at order time
    product_sku TEXT,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total_price DECIMAL(10,2) NOT NULL,
    product_options JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(order_id, product_id)
);

-- 7. Inventory Transactions (inventory pattern)
CREATE TABLE inventory_transactions (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    transaction_type TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    previous_stock INTEGER NOT NULL,
    new_stock INTEGER NOT NULL,
    reference_id INTEGER,
    reference_type TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    CHECK (transaction_type IN ('stock_in', 'stock_out', 'adjustment', 'return', 'reserve'))
);
```

### The Verification

```bash
# Check the complete schema
psql -d ecommerce -c "\dt"  # List all tables

# Test the patterns:
# 1. Create a customer
# 2. Add an address
# 3. Create a product
# 4. Start a cart
# 5. Add items to cart
# 6. Convert cart to order
# 7. Process inventory
```

---

## P3.9 Summary

### What You've Learned

✅ Why database design matters and common problems to avoid  
✅ Entities, attributes, and relationships  
✅ The three relationship types: One-to-One, One-to-Many, Many-to-Many  
✅ Normalization: 1NF, 2NF, and 3NF  
✅ Denormalization and when to use it  
✅ Keys and constraints (PK, FK, UNIQUE, CHECK, DEFAULT)  
✅ E-commerce design patterns  

### Design Principles to Remember

1. **Don't Repeat Yourself**: Normalize to avoid duplicate data
2. **One Thing, One Place**: Each fact should be stored in exactly one place
3. **Use Surrogate Keys**: Auto-incrementing IDs are easier to manage
4. **Add Foreign Keys**: They maintain data integrity
5. **Consider Performance**: Sometimes denormalize for speed
6. **Plan for Growth**: Design for future features

### Next Steps

You now have a solid understanding of database design fundamentals. This knowledge will help you follow along with the main tutorial series, where we build an e-commerce database step by step.

**Continue to Part 1 of the main series** to start building your database!

---

*You've completed all three primers! You now have a strong foundation to tackle the main tutorial series. The primers covered:*

- *Primer 1: SQL Fundamentals - Basic SQL syntax and operations*
- *Primer 2: PostgreSQL Architecture - How PostgreSQL works under the hood*
- *Primer 3: Database Design - Designing clean, efficient databases*

*You're ready to start building your e-commerce database in Part 1 of the main series!*
