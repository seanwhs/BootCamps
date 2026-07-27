# HANDS-ON POSTGRESQL: FROM ZERO TO SCHEMA HERO
## TRAINER GUIDE

### Comprehensive Instructor Manual for Teaching the Series

---

# TRAINER GUIDE INTRODUCTION

## Purpose of This Guide

This trainer guide provides everything you need to teach the Hands-On PostgreSQL series effectively. Whether you're teaching a classroom course, leading a workshop, or conducting one-on-one training, this guide will help you deliver engaging, effective instruction.

## How to Use This Guide

**Before Each Session:**
- Review the session objectives
- Prepare the environment
- Set up example data
- Run through the exercises

**During Each Session:**
- Follow the session outline
- Use the talking points
- Demonstrate the concepts
- Guide students through exercises

**After Each Session:**
- Review common issues
- Assign homework
- Prepare for next session

## Series Structure

| Part | Duration | Key Topics |
|------|----------|------------|
| Part 0 | 30 min | Introduction, Setup, Architecture |
| Part 1 | 2 hours | SQL Basics, CRUD, Filtering |
| Part 2 | 1.5 hours | Data Types, Constraints, JSONB |
| Part 3 | 2 hours | Relationships, Joins |
| Part 4 | 2 hours | Aggregations, Grouping, Subqueries |
| Part 5 | 1.5 hours | JSONB, Window Functions |
| Part 6 | 1.5 hours | Performance, Indexes, Transactions |

**Total Training Time:** 10-12 hours (including exercises)

---

# GENERAL TEACHING STRATEGIES

## Teaching Philosophy

**1. Learn by Doing**
- Every concept has a hands-on exercise
- Students write code from the first session
- Real-world e-commerce context throughout

**2. Progressive Complexity**
- Start with simple concepts
- Build on previous knowledge
- Gradually introduce advanced topics

**3. Immediate Feedback**
- Each exercise has verification steps
- Students see results immediately
- Common mistakes are addressed proactively

## Classroom Setup Checklist

**Before the First Session:**
- [ ] PostgreSQL installed on all student machines
- [ ] psql accessible from command line
- [ ] Database created (ecommerce)
- [ ] Sample data loaded
- [ ] Network connectivity for remote students
- [ ] Screen sharing/projection ready
- [ ] Student workbooks printed or distributed

## Common Technical Issues

| Issue | Solution |
|-------|----------|
| PostgreSQL not starting | Check services, restart PostgreSQL |
| Connection refused | Check port 5432, verify host |
| Permission denied | Check user permissions, run as admin |
| Database not found | Create database, verify name |
| Syntax errors | Check SQL syntax, missing semicolons |

---

# PART 0: INTRODUCTION & SETUP

## Session Overview

**Duration:** 30-45 minutes

**Objectives:**
- Understand the course structure
- Set up PostgreSQL
- Connect to the database
- Verify the environment

## Detailed Session Plan

### 1. Introduction (5 minutes)

**Talking Points:**
- Welcome students to the course
- Explain the series structure
- Show the final architecture
- Set expectations

**Key Message:** "By the end of this series, you'll build a complete e-commerce database and be comfortable writing complex SQL queries."

### 2. Installation Walkthrough (15 minutes)

**Talking Points:**
- Show installation steps for each OS
- Explain common pitfalls
- Verify installation with version check

**Demonstration:**
```bash
# Show installation verification
postgres --version
psql --version
```

### 3. First Connection (10 minutes)

**Talking Points:**
- Connect to PostgreSQL
- Create the database
- Create the user
- Test the connection

**Demonstration:**
```sql
CREATE DATABASE ecommerce;
CREATE USER ecommerce_user WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE ecommerce TO ecommerce_user;
\c ecommerce
```

### 4. Environment Verification (5 minutes)

**Checklist for Students:**
- [ ] PostgreSQL is running
- [ ] psql connects successfully
- [ ] ecommerce database exists
- [ ] Can run a simple SELECT

---

## Teaching Tips

**For Installation:**
- Have students help each other
- Be patient with platform differences
- Have a backup plan (Docker)

**For First Connection:**
- Walk through each step slowly
- Show the connection string
- Explain each command

## Common Student Questions

**Q: "Why can't I connect?"**
A: Check if PostgreSQL is running, verify port 5432, check user credentials.

**Q: "What if I'm on Windows?"**
A: Use the installer, run as Administrator, use psql from the start menu.

**Q: "Can I use pgAdmin instead?"**
A: Yes, but we'll use psql for the course to focus on SQL.

---

# PART 1: FIRST STEPS & THE SQL FOUNDATION

## Session Overview

**Duration:** 2 hours

**Objectives:**
- Understand basic SQL syntax
- Perform CRUD operations
- Filter and sort data
- Write complex WHERE clauses

## Detailed Session Plan

### 1. SQL Basics Review (15 minutes)

**Talking Points:**
- What is SQL?
- CRUD operations
- Database structure: databases → tables → rows → columns

**Key Syntax:**
```sql
SELECT column1, column2
FROM table_name
WHERE condition
ORDER BY column
LIMIT number;
```

### 2. CREATE TABLE (15 minutes)

**Talking Points:**
- Table creation syntax
- Column definition
- Common data types
- Constraints basics

**Demo Table:**
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    category TEXT
);
```

### 3. INSERT Operations (15 minutes)

**Talking Points:**
- Inserting single rows
- Inserting multiple rows
- Inserting with default values
- Returning inserted data

**Demo:**
```sql
INSERT INTO products (name, price, stock, category) VALUES
    ('Wireless Headphones', 79.99, 100, 'Electronics'),
    ('USB-C Cable', 12.99, 500, 'Electronics');
```

### 4. SELECT Operations (20 minutes)

**Talking Points:**
- Selecting all columns
- Selecting specific columns
- Using aliases
- Filtering with WHERE

**Demo Queries:**
```sql
SELECT * FROM products;
SELECT name, price FROM products WHERE price > 50;
SELECT name, price FROM products ORDER BY price DESC;
```

### 5. WHERE Clause Deep Dive (20 minutes)

**Talking Points:**
- Comparison operators
- LIKE and ILIKE
- IN and BETWEEN
- IS NULL and IS NOT NULL

**Demo:**
```sql
SELECT * FROM products WHERE price BETWEEN 20 AND 50;
SELECT * FROM products WHERE name ILIKE '%wireless%';
SELECT * FROM products WHERE stock = 0;
```

### 6. UPDATE and DELETE (15 minutes)

**Talking Points:**
- UPDATE syntax
- DELETE syntax
- The importance of WHERE
- RETURNING clause

**Demo:**
```sql
UPDATE products SET price = price * 1.10 WHERE category = 'Electronics';
DELETE FROM products WHERE stock = 0;
```

### 7. Student Exercises (20 minutes)

**Exercise 1:** Create a table for employees
**Exercise 2:** Insert 5 employees
**Exercise 3:** Query employees by department
**Exercise 4:** Update salaries by percentage
**Exercise 5:** Delete inactive employees

---

## Teaching Tips

**Key Concepts to Emphasize:**
- Always use WHERE with UPDATE/DELETE
- Test SELECT before UPDATE/DELETE
- Understand the order of execution

**Common Mistakes:**
- Forgetting semicolons
- Using single quotes incorrectly
- Misunderstanding LIKE patterns

## Troubleshooting Guide

| Error | Solution |
|-------|----------|
| `relation does not exist` | Check table name spelling |
| `syntax error` | Check SQL syntax, missing parentheses |
| `duplicate key` | Check for duplicate primary key |
| `null value` | Provide value or allow NULL |

---

# PART 2: DATA TYPES & CONSTRAINTS

## Session Overview

**Duration:** 1.5 hours

**Objectives:**
- Understand PostgreSQL data types
- Apply constraints correctly
- Use UUID and JSONB
- Implement validation rules

## Detailed Session Plan

### 1. Data Types Review (15 minutes)

**Talking Points:**
- Numeric types
- Character types
- Date/time types
- Special types (UUID, JSONB)

**Key Comparison:**
| Type | Use Case |
|------|----------|
| TEXT | Unlimited text |
| VARCHAR(255) | Limited text |
| NUMERIC(10,2) | Exact decimals |
| INTEGER | Whole numbers |
| TIMESTAMPTZ | Dates with timezone |
| UUID | Globally unique IDs |
| JSONB | Flexible data |

### 2. Creating the Users Table (15 minutes)

**Talking Points:**
- Table design considerations
- Choosing appropriate data types
- Adding constraints

**Demo:**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER CHECK (age >= 0),
    preferences JSONB DEFAULT '{}'::jsonb
);
```

### 3. Constraints Deep Dive (20 minutes)

**Talking Points:**
- NOT NULL
- UNIQUE
- CHECK
- DEFAULT
- PRIMARY KEY
- FOREIGN KEY

**Demo:**
```sql
ALTER TABLE users ADD CONSTRAINT email_format_check 
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

### 4. UUID and JSONB (15 minutes)

**Talking Points:**
- Enabling UUID extension
- Generating UUID values
- JSONB storage
- JSONB operators and functions

**Demo:**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SELECT uuid_generate_v4();

UPDATE users SET preferences = preferences || '{"theme": "dark"}'::jsonb;
SELECT * FROM users WHERE preferences ? 'theme';
```

### 5. Student Exercises (25 minutes)

**Exercise 1:** Create a table with all constraint types
**Exercise 2:** Insert valid data
**Exercise 3:** Test constraint violations
**Exercise 4:** Implement JSONB operations
**Exercise 5:** Create a view for active users

---

## Teaching Tips

**Key Concepts to Emphasize:**
- Choose the right data type for your data
- Use constraints to prevent bad data
- JSONB for flexible schemas

**Common Questions:**
- "When should I use TEXT vs VARCHAR?"
  - TEXT for unlimited, VARCHAR(n) for specific limits
- "When should I use JSONB?"
  - When the schema is flexible or frequently changes

---

# PART 3: RELATIONSHIPS & RELATIONAL QUERIES

## Session Overview

**Duration:** 2 hours

**Objectives:**
- Understand database relationships
- Implement foreign keys
- Write JOIN queries
- Use junction tables

## Detailed Session Plan

### 1. Relationships Overview (15 minutes)

**Talking Points:**
- One-to-Many
- Many-to-Many
- One-to-One
- Foreign keys

**Visual Diagrams:**
```
One-to-Many: Customer → Orders
Many-to-Many: Products ↔ Orders
One-to-One: User → Profile
```

### 2. Creating Orders Table (15 minutes)

**Talking Points:**
- Foreign key constraints
- ON DELETE options
- Relationship mapping

**Demo:**
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    total NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3. Creating Order Items (15 minutes)

**Talking Points:**
- Junction tables
- Composite primary keys
- Foreign key relationships

**Demo:**
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL
);
```

### 4. Categories and Junction Table (20 minutes)

**Talking Points:**
- Many-to-Many implementation
- Junction table design
- Querying junction tables

**Demo:**
```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE product_categories (
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, category_id)
);
```

### 5. JOIN Operations (25 minutes)

**Talking Points:**
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- FULL OUTER JOIN
- Self JOIN

**Demo Queries:**
```sql
SELECT u.email, o.id, o.total
FROM users u
JOIN orders o ON o.user_id = u.id;

SELECT u.email, COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.email;

SELECT p.name, c.name AS category
FROM products p
JOIN product_categories pc ON pc.product_id = p.id
JOIN categories c ON c.id = pc.category_id;
```

### 6. Student Exercises (30 minutes)

**Exercise 1:** Create the complete orders schema
**Exercise 2:** Insert sample data
**Exercise 3:** Write JOIN queries
**Exercise 4:** Query order history
**Exercise 5:** Find products by category

---

## Teaching Tips

**Key Concepts to Emphasize:**
- Foreign keys maintain data integrity
- JOINs combine data from multiple tables
- Junction tables enable Many-to-Many

**Common Mistakes:**
- Forgetting foreign key indexes
- Using wrong JOIN type
- Not handling NULL values in LEFT JOIN

---

# PART 4: AGGREGATIONS, GROUPING & SUBQUERIES

## Session Overview

**Duration:** 2 hours

**Objectives:**
- Use aggregate functions
- Group data with GROUP BY
- Filter groups with HAVING
- Write subqueries
- Use CASE statements

## Detailed Session Plan

### 1. Aggregate Functions (15 minutes)

**Talking Points:**
- COUNT
- SUM
- AVG
- MIN
- MAX

**Demo:**
```sql
SELECT 
    COUNT(*) AS total_orders,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_order,
    MIN(total) AS min_order,
    MAX(total) AS max_order
FROM orders;
```

### 2. GROUP BY (20 minutes)

**Talking Points:**
- Grouping by columns
- Grouping by expressions
- GROUP BY with multiple columns

**Demo:**
```sql
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total) AS revenue
FROM orders
GROUP BY status;

SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
GROUP BY DATE_TRUNC('month', created_at);
```

### 3. HAVING Clause (15 minutes)

**Talking Points:**
- Difference between WHERE and HAVING
- Filtering groups
- Combining with WHERE

**Demo:**
```sql
SELECT user_id, COUNT(*) AS order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 5;

SELECT user_id, SUM(total) AS total_spent
FROM orders
WHERE status != 'cancelled'
GROUP BY user_id
HAVING SUM(total) > 1000;
```

### 4. Subqueries (25 minutes)

**Talking Points:**
- Scalar subqueries
- Column subqueries
- Table subqueries
- Correlated subqueries

**Demo:**
```sql
-- Scalar: Products above average price
SELECT * FROM products 
WHERE price > (SELECT AVG(price) FROM products);

-- Column: Users who have placed orders
SELECT * FROM users 
WHERE id IN (SELECT DISTINCT user_id FROM orders);

-- Correlated: Orders with user email
SELECT 
    o.id,
    o.total,
    (SELECT u.email FROM users u WHERE u.id = o.user_id) AS user_email
FROM orders o;
```

### 5. CASE Statements (15 minutes)

**Talking Points:**
- Simple CASE
- Searched CASE
- CASE in SELECT, WHERE, ORDER BY

**Demo:**
```sql
SELECT 
    name,
    price,
    CASE 
        WHEN price < 20 THEN 'Budget'
        WHEN price < 50 THEN 'Economy'
        WHEN price < 100 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_tier
FROM products;
```

### 6. Student Exercises (30 minutes)

**Exercise 1:** Monthly revenue report
**Exercise 2:** Customer segmentation
**Exercise 3:** Top products analysis
**Exercise 4:** Sales funnel analysis
**Exercise 5:** Category performance

---

## Teaching Tips

**Key Concepts to Emphasize:**
- GROUP BY before SELECT
- WHERE filters rows, HAVING filters groups
- Subqueries can be used in SELECT, FROM, WHERE

---

# PART 5: MODERN POSTGRES POWER TOOLS

## Session Overview

**Duration:** 1.5 hours

**Objectives:**
- Use JSONB effectively
- Write window functions
- Combine JSONB with window functions
- Build customer ranking systems

## Detailed Session Plan

### 1. JSONB Review (20 minutes)

**Talking Points:**
- JSONB vs JSON
- JSONB operators
- JSONB functions
- Indexing JSONB

**Demo:**
```sql
-- Adding JSONB column
ALTER TABLE products ADD COLUMN metadata JSONB;

-- Updating JSONB
UPDATE products 
SET metadata = jsonb_build_object(
    'brand', 'AudioTech',
    'warranty_months', 24
);

-- Querying JSONB
SELECT * FROM products WHERE metadata->>'brand' = 'AudioTech';
SELECT * FROM products WHERE metadata @> '{"warranty_months": 24}'::jsonb;
```

### 2. Window Functions Fundamentals (25 minutes)

**Talking Points:**
- What are window functions?
- ROW_NUMBER, RANK, DENSE_RANK
- PARTITION BY and ORDER BY
- Window frames

**Demo:**
```sql
-- ROW_NUMBER: Number products by price
SELECT name, price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS rank
FROM products;

-- RANK: Rank with gaps
SELECT name, price,
    RANK() OVER (ORDER BY price DESC) AS rank
FROM products;

-- Partition by category
SELECT name, category, price,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rank_in_category
FROM products;
```

### 3. Advanced Window Functions (20 minutes)

**Talking Points:**
- LAG and LEAD
- Running totals
- Moving averages
- NTILE

**Demo:**
```sql
-- Running total
SELECT created_at, total,
    SUM(total) OVER (ORDER BY created_at) AS running_total
FROM orders;

-- Moving average
SELECT created_at, total,
    AVG(total) OVER (ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM orders;

-- Customer order progression
SELECT user_id, created_at, total,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_number,
    LAG(total) OVER (PARTITION BY user_id ORDER BY created_at) AS previous_total
FROM orders;
```

### 4. JSONB + Window Functions (15 minutes)

**Talking Points:**
- Combining flexible data with analytics
- Extracting JSONB values
- Partitioning by JSONB fields

**Demo:**
```sql
-- Rank products by brand
SELECT 
    metadata->>'brand' AS brand,
    name,
    price,
    RANK() OVER (PARTITION BY metadata->>'brand' ORDER BY price DESC) AS brand_rank
FROM products
WHERE metadata ? 'brand';

-- Brand revenue percentage
WITH brand_revenue AS (
    SELECT 
        metadata->>'brand' AS brand,
        SUM(total) AS revenue
    FROM orders o
    JOIN products p ON p.id = o.product_id
    WHERE metadata ? 'brand'
    GROUP BY metadata->>'brand'
)
SELECT 
    brand,
    revenue,
    revenue / SUM(revenue) OVER () * 100 AS pct_of_total
FROM brand_revenue;
```

### 5. Student Exercises (25 minutes)

**Exercise 1:** Add JSONB metadata to products
**Exercise 2:** Query JSONB data
**Exercise 3:** Rank products by price within category
**Exercise 4:** Calculate running total of orders
**Exercise 5:** Build customer ranking system

---

## Teaching Tips

**Key Concepts to Emphasize:**
- JSONB is queryable and indexable
- Window functions don't collapse rows
- Window functions are powerful for analytics

---

# PART 6: PERFORMANCE, INDEXES & TRANSACTIONS

## Session Overview

**Duration:** 1.5 hours

**Objectives:**
- Use EXPLAIN ANALYZE
- Create and manage indexes
- Use transactions
- Implement ACID compliance

## Detailed Session Plan

### 1. EXPLAIN ANALYZE (20 minutes)

**Talking Points:**
- What is query planning?
- Reading EXPLAIN ANALYZE output
- Identifying performance issues
- Cost and row estimates

**Demo:**
```sql
EXPLAIN ANALYZE
SELECT * FROM orders WHERE user_id = 'some-uuid';

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 'some-uuid';

-- Compare with and without index
EXPLAIN ANALYZE
SELECT * FROM products WHERE name ILIKE '%wireless%';
```

**Reading EXPLAIN Output:**
```
Seq Scan on products (cost=0.00..23.10 rows=3 width=72)
  Filter: (name ~~* '%wireless%'::text)
  Rows Removed by Filter: 97
  Buffers: shared hit=5
  Planning Time: 0.123 ms
  Execution Time: 0.456 ms
```

### 2. Index Types and Strategies (25 minutes)

**Talking Points:**
- B-Tree indexes
- GIN indexes
- Partial indexes
- Composite indexes
- Covering indexes

**Demo:**
```sql
-- Basic B-Tree
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- GIN for JSONB
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- Partial index (active orders only)
CREATE INDEX idx_orders_active ON orders(user_id) WHERE status != 'cancelled';

-- Composite index
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Covering index
CREATE INDEX idx_orders_user_amount ON orders(user_id) INCLUDE (total, status);
```

### 3. Transactions (20 minutes)

**Talking Points:**
- BEGIN, COMMIT, ROLLBACK
- SAVEPOINT
- Isolation levels
- ACID properties

**Demo:**
```sql
-- Basic transaction
BEGIN;
UPDATE products SET stock = stock - 1 WHERE id = 1;
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1, 1, 1);
COMMIT;

-- With rollback
BEGIN;
UPDATE products SET stock = stock - 100 WHERE id = 1;
-- If stock was insufficient:
ROLLBACK;

-- With savepoints
BEGIN;
UPDATE products SET stock = stock - 5 WHERE id = 1;
SAVEPOINT before_second;
UPDATE products SET stock = stock - 10 WHERE id = 2;
ROLLBACK TO SAVEPOINT before_second;
UPDATE products SET stock = stock - 3 WHERE id = 3;
COMMIT;
```

### 4. Complete Checkout Transaction (20 minutes)

**Talking Points:**
- Planning the transaction
- Inventory checks
- Atomic operations
- Error handling

**Demo:**
```sql
CREATE FUNCTION process_order(p_user_id UUID, p_items JSONB)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
BEGIN
    BEGIN
        INSERT INTO orders (user_id) VALUES (p_user_id) RETURNING id INTO v_order_id;
        
        FOR item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            PERFORM 1 FROM products 
            WHERE id = (item->>'product_id')::INTEGER 
              AND stock_quantity >= (item->>'quantity')::INTEGER
            FOR UPDATE;
            
            UPDATE products 
            SET stock_quantity = stock_quantity - (item->>'quantity')::INTEGER
            WHERE id = (item->>'product_id')::INTEGER;
            
            INSERT INTO order_items (order_id, product_id, quantity, unit_price)
            SELECT 
                v_order_id,
                p.id,
                (item->>'quantity')::INTEGER,
                p.price
            FROM products p
            WHERE p.id = (item->>'product_id')::INTEGER;
        END LOOP;
        
        UPDATE orders 
        SET total = (SELECT SUM(unit_price * quantity) FROM order_items WHERE order_id = v_order_id)
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

### 5. Student Exercises (25 minutes)

**Exercise 1:** Run EXPLAIN ANALYZE on queries
**Exercise 2:** Create appropriate indexes
**Exercise 3:** Implement a transfer transaction
**Exercise 4:** Build checkout transaction
**Exercise 5:** Practice rollback scenarios

---

## Teaching Tips

**Key Concepts to Emphasize:**
- Indexes trade write performance for read performance
- Always test queries with EXPLAIN ANALYZE
- Transactions ensure data integrity
- Use the right isolation level

---

# TEACHING RESOURCES

## Sample Session Schedule

### Day 1 (Full Day - 6 hours)
| Time | Session |
|------|---------|
| 9:00 - 9:30 | Part 0: Introduction & Setup |
| 9:30 - 11:30 | Part 1: SQL Foundation |
| 11:30 - 11:45 | Break |
| 11:45 - 1:15 | Part 2: Data Types & Constraints |
| 1:15 - 2:00 | Lunch |
| 2:00 - 4:00 | Part 3: Relationships & Joins |

### Day 2 (Half Day - 4 hours)
| Time | Session |
|------|---------|
| 9:00 - 11:00 | Part 4: Aggregations & Subqueries |
| 11:00 - 11:15 | Break |
| 11:15 - 12:45 | Part 5: JSONB & Window Functions |
| 12:45 - 1:30 | Lunch |
| 1:30 - 3:00 | Part 6: Performance & Transactions |

## Assessment Tools

### Daily Quizzes
- Part 1: 10 multiple choice, 5 fill-in-blank
- Part 2: 10 multiple choice, 5 fill-in-blank
- Part 3: 10 multiple choice, 5 fill-in-blank
- Part 4: 10 multiple choice, 5 fill-in-blank
- Part 5: 10 multiple choice, 5 fill-in-blank
- Part 6: 10 multiple choice, 5 fill-in-blank

### Final Exam
- 25 multiple choice
- 15 fill-in-blank
- 10 SQL queries
- 10 true/false

## Homework Assignments

### Assignment 1 (After Part 1)
Create a simple customer database with CRUD operations.

### Assignment 2 (After Part 2)
Design a complete schema with constraints.

### Assignment 3 (After Part 3)
Build an order system with relationships.

### Assignment 4 (After Part 4)
Create business reports using aggregations.

### Assignment 5 (After Part 5)
Implement JSONB and window functions.

### Assignment 6 (After Part 6)
Optimize queries and implement transactions.

---

# APPENDIX: TEACHING SCRIPTS

## Day 1 Opening Script

"Welcome to 'Hands-On PostgreSQL: From Zero to Schema Hero.' My name is [Name], and I'll be your instructor for this course.

By the end of this training, you will have built a complete, production-ready e-commerce database. You will be comfortable writing SQL queries, designing database schemas, and optimizing database performance.

This course is hands-on. We'll be writing code from the very first session. Please follow along, ask questions, and don't hesitate to help your fellow students.

Let's begin."

## Part 1 Introduction Script

"We're going to start with the fundamentals of SQL. If you've never written SQL before, don't worry—we'll start from the very beginning.

SQL stands for Structured Query Language. It's how we talk to databases. We'll learn the four basic operations: INSERT, SELECT, UPDATE, and DELETE.

By the end of this session, you'll be able to create tables, add data, query data, and modify data. Let's start with our first table."

---

## Continuous Improvement

**After Each Session:**
- Note what worked well
- Identify challenging concepts
- Adjust pace as needed
- Collect student feedback

**Student Feedback Questions:**
1. What was most clear today?
2. What was most confusing?
3. What would you like to review?
4. What topic are you most excited about?
