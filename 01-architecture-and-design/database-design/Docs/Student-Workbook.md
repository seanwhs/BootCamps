# Mastering Modern Database Design — Complete Student Workbook

## Hands-On Exercises, Labs & Projects

---

## WORKBOOK OVERVIEW

This workbook contains all hands-on exercises, labs, and projects for the "Mastering Modern Database Design" series. Each exercise builds on previous knowledge and reinforces key concepts.

**How to Use This Workbook:**
1. Read the corresponding lecture material first
2. Complete the exercises in order
3. Verify your work using the provided solutions
4. Challenge yourself with the advanced sections

**Estimated Time:** 20-25 hours total

---

## WORKBOOK NAVIGATION

| Section | Topic | Exercises | Time |
|---------|-------|-----------|------|
| 1 | ER Modeling | 5 | 2 hours |
| 2 | Schema Design | 6 | 3 hours |
| 3 | Normalization | 5 | 2 hours |
| 4 | Indexing | 6 | 3 hours |
| 5 | Query Optimization | 5 | 2 hours |
| 6 | Transactions | 5 | 2 hours |
| 7 | Concurrency | 4 | 2 hours |
| 8 | NoSQL | 4 | 2 hours |
| 9 | Final Project | 1 | 4+ hours |

---

## SECTION 1: ENTITY-RELATIONSHIP MODELING

### Exercise 1.1: Identifying Entities & Attributes

**Scenario:** You are designing a database for a library management system.

**Tasks:**
1. Identify at least 5 entities
2. List 3-5 attributes for each entity
3. Identify which attributes could be primary keys

**Space for your answers:**

Entity 1: _______________
Attributes:
- ______________________
- ______________________
- ______________________
- ______________________
Primary Key: _______________

Entity 2: _______________
Attributes:
- ______________________
- ______________________
- ______________________
- ______________________
Primary Key: _______________

Entity 3: _______________
Attributes:
- ______________________
- ______________________
- ______________________
- ______________________
Primary Key: _______________

Entity 4: _______________
Attributes:
- ______________________
- ______________________
- ______________________
- ______________________
Primary Key: _______________

Entity 5: _______________
Attributes:
- ______________________
- ______________________
- ______________________
- ______________________
Primary Key: _______________

---

### Exercise 1.2: Identifying Relationships

**Scenario:** Using the library entities you identified above, determine the relationships.

**Tasks:**
1. Identify all relationships between entities
2. Determine cardinality (1:1, 1:N, N:M)
3. Identify which relationships need junction tables

**Space for your answers:**

Relationship 1: _______________ to _______________
Cardinality: _______________
Junction Table Needed? _______________

Relationship 2: _______________ to _______________
Cardinality: _______________
Junction Table Needed? _______________

Relationship 3: _______________ to _______________
Cardinality: _______________
Junction Table Needed? _______________

Relationship 4: _______________ to _______________
Cardinality: _______________
Junction Table Needed? _______________

Relationship 5: _______________ to _______________
Cardinality: _______________
Junction Table Needed? _______________

---

### Exercise 1.3: Drawing an ERD

**Scenario:** A school wants to track students, courses, and instructors.

**Business Rules:**
- Each student has a name, email, and enrollment date
- Each course has a name, code, and credit hours
- Each instructor has a name, email, and department
- A student can enroll in multiple courses
- A course can have multiple students
- Each course is taught by one instructor
- An instructor can teach multiple courses

**Tasks:**
1. Draw an ERD (text diagram)
2. Identify all primary keys and foreign keys
3. Determine which table would be the junction table

**Space for your ERD:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR ERD HERE                              │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Primary Keys:**
- Students: _______________
- Courses: _______________
- Instructors: _______________
- Junction: _______________

**Foreign Keys:**
- In Courses: _______________
- In Junction: _______________

---

### Exercise 1.4: ERD to Relational Mapping

**Scenario:** Convert the following ERD to relational tables.

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│  CUSTOMER    │1       N│    ORDER     │1       N│  ORDER_ITEM  │
├──────────────┤─────────├──────────────┤─────────├──────────────┤
│ id (PK)      │         │ id (PK)      │         │ order_id (FK)│
│ name         │         │ customer_id  │         │ product_id   │
│ email        │         │ order_date   │         │ quantity     │
│ address      │         │ total        │         │ unit_price   │
└──────────────┘         └──────────────┘         └──────────────┘
                                                           │
                                                           │ N
                                                      ┌────┴────┐
                                                      │ PRODUCT │
                                                      ├─────────┤
                                                      │ id (PK) │
                                                      │ name    │
                                                      │ price   │
                                                      │ sku     │
                                                      └─────────┘
```

**Tasks:**
1. Write the CREATE TABLE statements
2. Define all primary keys and foreign keys
3. Add appropriate data types

**Space for your SQL:**

```sql
-- CREATE TABLE CUSTOMER


-- CREATE TABLE PRODUCT


-- CREATE TABLE ORDER


-- CREATE TABLE ORDER_ITEM
```

---

### Exercise 1.5: Complex ERD Challenge

**Scenario:** An e-commerce platform with the following requirements:

**Business Rules:**
- Products have: id, name, description, price, weight
- Categories have: id, name, parent_category (subcategories)
- Suppliers have: id, name, contact, address
- Products can belong to multiple categories
- Products can be supplied by multiple suppliers (with different supply prices)
- Customers have: id, name, email, password, addresses (multiple per customer)
- Orders have: id, customer, date, status, shipping address, billing address
- Orders contain multiple products with quantities
- Payments are made per order (can be partial)
- Customers can review products (rating 1-5, comment)

**Tasks:**
1. Identify all entities (minimum 6)
2. Identify all relationships with cardinalities
3. Draw an ERD
4. List all junction tables

**Space for your answers:**

**Entities:**
1. _______________________
2. _______________________
3. _______________________
4. _______________________
5. _______________________
6. _______________________

**Relationships:**
1. ________________ to ________________ : Cardinality: ______
2. ________________ to ________________ : Cardinality: ______
3. ________________ to ________________ : Cardinality: ______
4. ________________ to ________________ : Cardinality: ______
5. ________________ to ________________ : Cardinality: ______
6. ________________ to ________________ : Cardinality: ______

**Junction Tables:**
1. _______________________
2. _______________________

---

## SECTION 2: SCHEMA DESIGN

### Exercise 2.1: Creating Tables

**Scenario:** You have designed the following entities for a blog system:

**Entities:**
- Blog (id, title, content, author_id, created_at, updated_at)
- Author (id, name, email, bio)
- Comment (id, blog_id, author_name, content, created_at)
- Category (id, name, description)
- Blog_Category (blog_id, category_id)

**Tasks:**
1. Write the CREATE TABLE statements
2. Add appropriate constraints (NOT NULL, UNIQUE, CHECK)
3. Define foreign keys with appropriate ON DELETE actions

**Space for your SQL:**

```sql
-- CREATE TABLE AUTHOR


-- CREATE TABLE CATEGORY


-- CREATE TABLE BLOG


-- CREATE TABLE COMMENT


-- CREATE TABLE BLOG_CATEGORY
```

---

### Exercise 2.2: Choosing Data Types

**Scenario:** You are designing a table for a product catalog.

**Fields needed:**
- Product ID (unique identifier)
- Product Name
- Description (could be long)
- Price (with 2 decimal places)
- Weight (in kg, with 2 decimal places)
- In Stock (yes/no)
- SKU (unique code)
- Category ID (references category table)
- Created Date (with timezone)
- Last Updated (with timezone)

**Tasks:**
1. Choose appropriate data types for each field
2. Determine which fields should be NOT NULL
3. Identify which fields need indexes

**Space for your answers:**

| Field | Data Type | NOT NULL? | Indexed? |
|-------|-----------|-----------|----------|
| product_id | | | |
| name | | | |
| description | | | |
| price | | | |
| weight | | | |
| in_stock | | | |
| sku | | | |
| category_id | | | |
| created_date | | | |
| updated_date | | | |

**Your CREATE TABLE statement:**

```sql

```

---

### Exercise 2.3: Adding Constraints

**Scenario:** The following table definition is incomplete:

```sql
CREATE TABLE orders (
    id SERIAL,
    customer_id INTEGER,
    order_date TIMESTAMPTZ,
    status VARCHAR(20),
    total_amount NUMERIC(10,2),
    shipping_address TEXT,
    billing_address TEXT
);
```

**Tasks:**
1. Add a primary key
2. Add NOT NULL constraints where appropriate
3. Add a CHECK constraint for status (pending, paid, shipped, delivered, cancelled)
4. Add a CHECK constraint for total_amount (>= 0)
5. Add a foreign key to customers table

**Space for your completed SQL:**

```sql
CREATE TABLE orders (
    id SERIAL,
    customer_id INTEGER,
    order_date TIMESTAMPTZ,
    status VARCHAR(20),
    total_amount NUMERIC(10,2),
    shipping_address TEXT,
    billing_address TEXT,
    -- Add constraints here

);
```

---

### Exercise 2.4: Foreign Key Actions

**Scenario:** You have the following tables:

```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INTEGER REFERENCES categories(id)
);
```

**Tasks:**
1. What happens when you try to delete a category that has products? (with current design)
2. Modify the foreign key to ON DELETE RESTRICT
3. Modify the foreign key to ON DELETE CASCADE
4. Modify the foreign key to ON DELETE SET NULL
5. Which option is best for this scenario? Why?

**Space for your answers:**

1. ____________________________________________________________________

2. ON DELETE RESTRICT:
```sql

```

3. ON DELETE CASCADE:
```sql

```

4. ON DELETE SET NULL:
```sql

```

5. Best option: _______________
Why? ____________________________________________________________________

---

### Exercise 2.5: Adding Indexes

**Scenario:** You have the following query that is frequently run:

```sql
SELECT * FROM orders 
WHERE customer_id = 42 
  AND status = 'pending' 
  AND order_date > '2026-01-01'
ORDER BY order_date DESC;
```

**Tasks:**
1. What indexes would you create to optimize this query?
2. Explain why each index helps
3. What type of index (single, composite, partial) would be most efficient?

**Space for your answers:**

1. Index 1:
```sql

```
Why? ____________________________________________________________________

Index 2:
```sql

```
Why? ____________________________________________________________________

2. Most efficient type: _______________
Why? ____________________________________________________________________

**Your final index recommendations:**

```sql

```

---

### Exercise 2.6: Full Schema Design

**Scenario:** Design a complete schema for a ride-sharing application (like Uber/Lyft).

**Business Requirements:**
- Drivers sign up with name, license plate, car model, location
- Riders sign up with name, credit card, location
- Rides have: rider, driver, pickup location, dropoff location, status, fare, duration
- Riders can rate drivers (1-5 stars) after each ride
- Drivers can rate riders (1-5 stars) after each ride
- Each ride has a payment (amount, method, status)

**Tasks:**
1. Create a complete ERD
2. Write all CREATE TABLE statements
3. Add appropriate constraints and indexes
4. Identify which tables need partitioning

**Space for your schema:**

**ERD:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR ERD HERE                              │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**CREATE TABLE statements:**

```sql

```

---

## SECTION 3: NORMALIZATION

### Exercise 3.1: Identify Normal Form

**Scenario:** Evaluate each table design and identify which normal form it violates.

**Table A:** Library Books
| BookID | Title | Author1 | Author2 | Publisher | Year |
|--------|-------|---------|---------|-----------|------|
| 1 | Book A | Smith | Johnson | Pub A | 2020 |
| 2 | Book B | Smith | - | Pub B | 2021 |

**Tasks:**
1. What normal form is violated? _______________
2. Why? ____________________________________________________________________
3. How would you fix it? ____________________________________________________________________

---

**Table B:** Order Details
| OrderID | ProductID | ProductName | Quantity | UnitPrice | Discount |
|---------|-----------|-------------|----------|-----------|----------|
| 1 | 101 | Laptop | 2 | 999.99 | 0.05 |
| 1 | 102 | Mouse | 1 | 29.99 | 0.00 |
| 2 | 101 | Laptop | 1 | 999.99 | 0.00 |

Primary Key: (OrderID, ProductID)

**Tasks:**
1. What normal form is violated? _______________
2. Why? ____________________________________________________________________
3. How would you fix it? ____________________________________________________________________

---

**Table C:** Employees
| EmployeeID | Name | DepartmentID | DepartmentName | Manager |
|------------|------|--------------|----------------|---------|
| 1 | Alice | 10 | Sales | Bob |
| 2 | Bob | 10 | Sales | Carol |
| 3 | Carol | 20 | Marketing | Dave |

**Tasks:**
1. What normal form is violated? _______________
2. Why? ____________________________________________________________________
3. How would you fix it? ____________________________________________________________________

---

### Exercise 3.2: Normalize a Table

**Scenario:** The following table is denormalized:

**Order Table:**
| OrderID | CustomerName | CustomerAddress | Product1 | Qty1 | Price1 | Product2 | Qty2 | Price2 | Total |
|---------|--------------|-----------------|----------|------|--------|----------|------|--------|-------|
| 1001 | John | 123 Main | Laptop | 1 | 999 | Mouse | 2 | 29 | 1057 |
| 1002 | Jane | 456 Oak | Phone | 1 | 599 | - | - | - | 599 |

**Tasks:**
1. Normalize this table to 3NF
2. Show all resulting tables
3. Identify primary and foreign keys

**Space for your normalized design:**

**Table 1:**
Table Name: _______________
Columns: ____________________________________________________________________
PK: _______________

**Table 2:**
Table Name: _______________
Columns: ____________________________________________________________________
PK: _______________
FK: _______________

**Table 3:**
Table Name: _______________
Columns: ____________________________________________________________________
PK: _______________
FK: _______________

**Table 4:**
Table Name: _______________
Columns: ____________________________________________________________________
PK: _______________
FK: _______________

---

### Exercise 3.3: 1NF to 3NF Transformation

**Scenario:** A university wants to track course enrollments:

**Current Table (Unnormalized):**
| StudentID | StudentName | Courses |
|-----------|-------------|---------|
| 101 | Alice | CS101, CS102, MATH101 |
| 102 | Bob | CS101, PHYS101 |
| 103 | Carol | CS102, MATH101, ENGL101 |

**Tasks:**
1. Convert to 1NF
2. Convert to 2NF
3. Convert to 3NF

**Space for your answers:**

**1NF Table:**

| StudentID | StudentName | Course |
|-----------|-------------|--------|
|           |             |        |
|           |             |        |
|           |             |        |
|           |             |        |
|           |             |        |

**2NF Tables:**

Table 1: _______________
| Column | Column | Column |
|--------|--------|--------|
|        |        |        |
|        |        |        |

Table 2: _______________
| Column | Column |
|--------|--------|
|        |        |
|        |        |

**3NF Tables:**

Table 1: _______________
| Column | Column |
|--------|--------|
|        |        |
|        |        |

Table 2: _______________
| Column | Column |
|--------|--------|
|        |        |
|        |        |

Table 3: _______________
| Column | Column |
|--------|--------|
|        |        |
|        |        |

---

### Exercise 3.4: Denormalization Decision

**Scenario:** An e-commerce site has the following tables:
- Products (id, name, price, description)
- Reviews (id, product_id, rating, comment)
- The site displays average rating on product pages

**Tasks:**
1. What query would calculate average rating?
2. What is the performance implication for a product with 10,000 reviews?
3. Would you consider denormalizing? If so, how?
4. What are the trade-offs?

**Space for your answers:**

1. Query:

```sql

```

2. Performance implication: ____________________________________________________________________

3. Denormalization approach: ____________________________________________________________________

4. Trade-offs:

Pros:
- ____________________________________________________________________
- ____________________________________________________________________

Cons:
- ____________________________________________________________________
- ____________________________________________________________________

---

### Exercise 3.5: Complex Normalization Challenge

**Scenario:** The following table tracks projects and employees:

| ProjectID | ProjectName | EmployeeID | EmployeeName | Role | Hours | EmployeeDepartment |
|-----------|-------------|------------|--------------|------|-------|-------------------|
| P1 | Website | E1 | Alice | Developer | 40 | IT |
| P1 | Website | E2 | Bob | Designer | 20 | Design |
| P2 | App | E1 | Alice | Lead | 20 | IT |
| P2 | App | E3 | Carol | Developer | 30 | IT |
| P2 | App | E4 | Dave | Tester | 10 | QA |

**Tasks:**
1. What is the primary key? _______________
2. Identify functional dependencies
3. Is the table in 2NF? Why or why not?
4. Normalize to 3NF showing all tables

**Space for your answers:**

1. Primary Key: _______________

2. Functional Dependencies:
- ____________________________________________________________________
- ____________________________________________________________________
- ____________________________________________________________________
- ____________________________________________________________________

3. 2NF? _______________
Why? ____________________________________________________________________

4. Normalized Tables:

Table 1: _______________
| Column | Column | Column |
|--------|--------|--------|
|        |        |        |
|        |        |        |

Table 2: _______________
| Column | Column |
|--------|--------|
|        |        |
|        |        |

Table 3: _______________
| Column | Column |
|--------|--------|
|        |        |
|        |        |

Table 4: _______________
| Column | Column |
|--------|--------|
|        |        |
|        |        |

---

## SECTION 4: INDEXING

### Exercise 4.1: EXPLAIN ANALYZE Practice

**Scenario:** You have a products table with the following query:

```sql
EXPLAIN ANALYZE
SELECT * FROM products WHERE category_id = 5;
```

**Output:**
```
Seq Scan on products  (cost=0.00..25000.00 rows=1000 width=100)
  (actual time=0.123..123.456 rows=150 loops=1)
  Filter: (category_id = 5)
  Rows Removed by Filter: 1999850
Planning Time: 0.234 ms
Execution Time: 123.789 ms
```

**Tasks:**
1. What type of scan is being used? _______________
2. How many rows were scanned? _______________
3. How many rows matched the condition? _______________
4. What is the estimated vs actual rows? _______________
5. What index would you recommend? _______________

---

### Exercise 4.2: Index Type Selection

**Scenario:** For each query below, recommend the best index type.

**Query 1:** Equality lookup on email
```sql
SELECT * FROM users WHERE email = 'john@example.com';
```
Index Type: _______________
Why: ____________________________________________________________________

---

**Query 2:** Full-text search on product descriptions
```sql
SELECT * FROM products WHERE search_vector @@ to_tsquery('laptop & high-performance');
```
Index Type: _______________
Why: ____________________________________________________________________

---

**Query 3:** Range query on order date
```sql
SELECT * FROM orders WHERE order_date BETWEEN '2026-01-01' AND '2026-01-31';
```
Index Type: _______________
Why: ____________________________________________________________________

---

**Query 4:** Filter on status (only 3 possible values)
```sql
SELECT * FROM orders WHERE status = 'pending' AND order_date > '2026-01-01';
```
Index Type: _______________
Why: ____________________________________________________________________

---

**Query 5:** Geospatial nearest neighbor
```sql
SELECT * FROM stores WHERE ST_DWithin(location, ST_MakePoint(-122.4, 37.8), 10000);
```
Index Type: _______________
Why: ____________________________________________________________________

---

### Exercise 4.3: Composite Index Order

**Scenario:** You have the following queries:

```sql
-- Query A
SELECT * FROM orders WHERE customer_id = 42;

-- Query B
SELECT * FROM orders WHERE customer_id = 42 AND status = 'paid';

-- Query C
SELECT * FROM orders WHERE status = 'pending';
```

**Tasks:**
1. Design a composite index that works for all three queries
2. Explain the column order
3. What if you only had Query A and Query B? Would you design differently?

**Space for your answers:**

1. Composite Index:
```sql

```

2. Column order reasoning: ____________________________________________________________________

3. For Query A and Query B only:
```sql

```
Why: ____________________________________________________________________

---

### Exercise 4.4: Partial Index Design

**Scenario:** A system has millions of orders. Most queries filter on `status = 'pending'`.

**Tasks:**
1. Design a partial index to optimize pending order queries
2. Show how this index would be smaller than a full index
3. Write a query that would use this index

**Space for your answers:**

1. Partial Index:
```sql

```

2. Size comparison:
- Full index would index: _______________
- Partial index only indexes: _______________
- Estimated size reduction: _______________

3. Query using this index:
```sql

```

---

### Exercise 4.5: Index Maintenance

**Scenario:** A table has the following indexes:

```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
```

**Analysis:**
| Index | Size | Scans | Inserts/Updates per minute |
|-------|------|-------|----------------------------|
| idx_orders_customer_id | 500MB | 1000 | 1000 |
| idx_orders_status | 200MB | 100 | 1000 |
| idx_orders_order_date | 600MB | 50 | 1000 |
| idx_orders_customer_status | 700MB | 800 | 1000 |

**Tasks:**
1. Which index is the most valuable? _______________
Why? ____________________________________________________________________

2. Which index is the least valuable? _______________
Why? ____________________________________________________________________

3. Which index could be dropped? _______________
Why? ____________________________________________________________________

4. What is the cost of keeping all 4 indexes? _______________

---

### Exercise 4.6: Advanced Indexing Strategy

**Scenario:** An e-commerce catalog has these common queries:

```sql
-- Q1: Search products by name (partial matches)
SELECT * FROM products WHERE name LIKE '%laptop%';

-- Q2: Search products by name and description
SELECT * FROM products WHERE search_vector @@ to_tsquery('laptop');

-- Q3: Products in a category with price range
SELECT * FROM products WHERE category_id = 5 AND price BETWEEN 100 AND 500;

-- Q4: Products sorted by price
SELECT * FROM products WHERE category_id = 5 ORDER BY price DESC;
```

**Tasks:**
1. Design an indexing strategy for each query
2. Consider if any indexes can be combined
3. Write the CREATE INDEX statements

**Space for your answers:**

1. Q1:
```sql

```
Why: ____________________________________________________________________

2. Q2:
```sql

```
Why: ____________________________________________________________________

3. Q3:
```sql

```
Why: ____________________________________________________________________

4. Q4:
```sql

```
Why: ____________________________________________________________________

5. Combined strategy:
```sql

```
Why: ____________________________________________________________________

---

## SECTION 5: QUERY OPTIMIZATION

### Exercise 5.1: Optimizing SELECT

**Scenario:** The following query is slow:

```sql
SELECT * FROM orders 
WHERE customer_id = 42 
  AND status = 'paid' 
  AND order_date > '2025-01-01';
```

**Tasks:**
1. Run EXPLAIN ANALYZE (conceptually)
2. What index would help?
3. Rewrite the query to be more efficient

**Space for your answers:**

1. EXPLAIN ANALYZE expected output: ____________________________________________________________________

2. Index:
```sql

```

3. Optimized query:
```sql

```

---

### Exercise 5.2: Join Optimization

**Scenario:** The following query joins three tables:

```sql
SELECT 
    c.full_name,
    o.id AS order_id,
    o.total_amount,
    p.name AS product_name,
    oi.quantity
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE c.id = 42
  AND o.status = 'paid';
```

**Tasks:**
1. What indexes would help this query?
2. Rewrite to filter before joining
3. Consider using a subquery instead

**Space for your answers:**

1. Indexes needed:
```sql

```

2. Filter before joining:
```sql

```

3. Subquery approach:
```sql

```

---

### Exercise 5.3: Subquery Optimization

**Scenario:** The following query uses a correlated subquery:

```sql
SELECT 
    id,
    name,
    (SELECT AVG(rating) FROM reviews WHERE product_id = p.id) AS avg_rating
FROM products p
WHERE price > 100;
```

**Tasks:**
1. Explain why this query might be slow
2. Rewrite using a JOIN
3. Rewrite using a CTE
4. Consider a materialized view approach

**Space for your answers:**

1. Why slow: ____________________________________________________________________

2. JOIN approach:
```sql

```

3. CTE approach:
```sql

```

4. Materialized view:
```sql

```

---

### Exercise 5.4: Bulk Operations

**Scenario:** You need to update 100,000 products in a single operation.

```sql
UPDATE products 
SET price = price * 1.10 
WHERE category_id = 5;
```

**Tasks:**
1. What is the problem with this query?
2. How would you optimize it?
3. Write a batch update approach

**Space for your answers:**

1. Problem: ____________________________________________________________________

2. Optimized approach:
```sql

```

3. Batch update:
```sql

```

---

### Exercise 5.5: Query Plan Analysis

**Scenario:** Analyze the following EXPLAIN output:

```
Nested Loop  (cost=100.00..50000.00 rows=1000)
  Join Filter: (o.customer_id = c.id)
  ->  Seq Scan on customers c  (cost=0.00..1000.00 rows=1000)
        Filter: (is_active = true)
  ->  Index Scan using idx_orders_customer on orders o  (cost=0.50..50.00 rows=100)
        Index Cond: (customer_id = c.id)
```

**Tasks:**
1. What is the total estimated cost? _______________
2. What type of join is being used? _______________
3. Is the query using indexes? _______________
4. What could be improved? _______________
5. Rewrite to improve performance

**Space for your answers:**

1. Total cost: _______________

2. Join type: _______________

3. Index usage: ____________________________________________________________________

4. Improvements: ____________________________________________________________________

5. Optimized query:
```sql

```

---

## SECTION 6: TRANSACTIONS

### Exercise 6.1: Transaction Basics

**Scenario:** Write a transaction that transfers money between accounts.

**Tables:**
```sql
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    balance NUMERIC(10,2) NOT NULL CHECK (balance >= 0)
);
```

**Tasks:**
1. Write a transaction that transfers $100 from account 1 to account 2
2. Include error handling (check if account exists, check sufficient balance)
3. Show COMMIT and ROLLBACK scenarios

**Space for your SQL:**

```sql
-- Transfer transaction

```

**Error handling:**

```sql

```

**ROLLBACK scenario:**

```sql

```

---

### Exercise 6.2: Order Placement Transaction

**Scenario:** An e-commerce order placement must:
1. Check inventory
2. Reserve items
3. Create order
4. Create order items
5. Process payment

**Tables:**
```sql
CREATE TABLE inventory (
    product_id INTEGER PRIMARY KEY,
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    reserved_quantity INTEGER DEFAULT 0
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    status VARCHAR(20),
    total_amount NUMERIC(10,2)
);

CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price NUMERIC(10,2),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER,
    amount NUMERIC(10,2),
    status VARCHAR(20)
);
```

**Tasks:**
1. Write a complete transaction for placing an order
2. Ensure all steps are atomic
3. Include stock check and reservation
4. Calculate total from items

**Space for your SQL:**

```sql
-- Order placement transaction

```

---

### Exercise 6.3: Transaction Isolation

**Scenario:** Two transactions are running simultaneously.

**Transaction A:**
```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- Delay here
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

**Transaction B:**
```sql
SELECT balance FROM accounts WHERE id = 1;
```

**Tasks:**
1. What isolation level should Transaction A use to prevent dirty reads?
2. What isolation level should Transaction B use to get consistent reads?
3. If Transaction B is a report that should see the state at transaction start, what should it use?

**Space for your answers:**

1. Transaction A: _______________
Why: ____________________________________________________________________

2. Transaction B: _______________
Why: ____________________________________________________________________

3. Report transaction: _______________
Why: ____________________________________________________________________

---

### Exercise 6.4: Transaction Deadlock

**Scenario:** Two transactions try to update the same two rows in different orders.

**Tasks:**
1. Write two transactions that will deadlock
2. Show what the deadlock looks like
3. Show how to prevent it

**Space for your answers:**

1. Transaction A:
```sql
BEGIN;
-- Update row 1 first

```

Transaction B:
```sql
BEGIN;
-- Update row 2 first

```

2. Deadlock description: ____________________________________________________________________

3. Prevent deadlock (consistent ordering):
```sql

```

---

### Exercise 6.5: Savepoints and Partial Rollback

**Scenario:** A complex transaction with multiple steps where some steps are optional.

**Tasks:**
1. Write a transaction using savepoints
2. Show how to rollback to a savepoint
3. Show partial commit

**Space for your SQL:**

```sql
-- Transaction with savepoints

```

---

## SECTION 7: CONCURRENCY

### Exercise 7.1: Locking Strategies

**Scenario:** A high-traffic inventory system.

**Tasks:**
1. Implement pessimistic locking for inventory update
2. Implement optimistic locking for the same operation
3. Compare the two approaches

**Space for your answers:**

1. Pessimistic locking:
```sql

```

2. Optimistic locking:
```sql

```

3. Comparison:

| Aspect | Pessimistic | Optimistic |
|--------|-------------|------------|
| Locking | | |
| Performance | | |
| When to use | | |
| Retry needed | | |

---

### Exercise 7.2: Concurrency Anomalies

**Scenario:** Two users are accessing the same data.

**Tasks:**
1. Create a scenario that shows a dirty read
2. Create a scenario that shows a non-repeatable read
3. Create a scenario that shows a phantom read
4. Show how to prevent each

**Space for your answers:**

1. Dirty Read:
Transaction A:
```sql

```
Transaction B:
```sql

```
Prevention:
```sql

```

2. Non-Repeatable Read:
Transaction A:
```sql

```
Transaction B:
```sql

```
Prevention:
```sql

```

3. Phantom Read:
Transaction A:
```sql

```
Transaction B:
```sql

```
Prevention:
```sql

```

---

### Exercise 7.3: Queue Processing

**Scenario:** A system processes pending orders from a queue.

**Tasks:**
1. Write a query to select 10 pending orders for processing
2. Use SKIP LOCKED to avoid conflicts
3. Process the orders with a transaction

**Space for your SQL:**

```sql
-- Select pending orders with SKIP LOCKED

-- Process selected orders

```

---

### Exercise 7.4: Read Consistency

**Scenario:** A reporting system and an OLTP system access the same data.

**Tasks:**
1. What isolation level should reports use?
2. How can you ensure consistent reports without blocking transactions?
3. Write a query that uses an appropriate isolation level

**Space for your answers:**

1. Isolation level: _______________
Why: ____________________________________________________________________

2. Approach: ____________________________________________________________________

3. Query:
```sql

```

---

## SECTION 8: NOSQL

### Exercise 8.1: Document Database Design

**Scenario:** Design a product catalog for a document database (MongoDB).

**Tasks:**
1. Design the document structure for a product
2. Include: name, description, price, categories (multiple), variants (size, color, price)
3. Show how to query for products in a specific category
4. Show how to update product price

**Space for your answers:**

1. Document structure:
```json

```

2. Query for products in a category:
```javascript

```

3. Update product price:
```javascript

```

---

### Exercise 8.2: Key-Value Store Use Case

**Scenario:** Design a session store using Redis.

**Tasks:**
1. Design the key structure for user sessions
2. Include: user_id, session_id, expiration time, cart data
3. Show how to set and get session data
4. Show how to set TTL

**Space for your answers:**

1. Key structure: _______________

2. Set session:
```redis

```

3. Get session:
```redis

```

4. With TTL:
```redis

```

---

### Exercise 8.3: Graph Database Design

**Scenario:** Design a recommendation engine using Neo4j.

**Tasks:**
1. Create nodes for users and products
2. Create BOUGHT relationships
3. Write a Cypher query to recommend products to a user
4. Write a Cypher query to find users who bought similar products

**Space for your answers:**

1. Node creation:
```cypher

```

2. Relationship creation:
```cypher

```

3. Recommendations query:
```cypher

```

4. Similar users query:
```cypher

```

---

### Exercise 8.4: Polyglot Architecture Design

**Scenario:** Design an e-commerce architecture using multiple databases.

**Components:**
- Product catalog (read-heavy)
- Inventory (write-heavy, consistency required)
- User sessions (TTL needed)
- Recommendations (relationship-based)

**Tasks:**
1. Choose the best database for each component
2. Justify your choices
3. Show data flow between components

**Space for your answers:**

| Component | Database | Justification |
|-----------|----------|---------------|
| Product catalog | | |
| Inventory | | |
| User sessions | | |
| Recommendations | | |

Data flow diagram:

```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR DATA FLOW DIAGRAM                     │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## SECTION 9: FINAL PROJECT

### Exercise 9.1: Complete ScaleCart Implementation

**Objective:** Build a complete e-commerce database system from scratch.

**Requirements:**
1. Design a complete ERD (minimum 8 entities)
2. Write all CREATE TABLE statements
3. Add all appropriate constraints and indexes
4. Write at least 10 sample queries
5. Demonstrate a transaction (e.g., placing an order)
6. Design an indexing strategy for the most common queries
7. Implement a caching strategy
8. Write a simple report

**Deliverables:**

**1. Complete ERD**

```
┌─────────────────────────────────────────────────────────────────┐
│                    YOUR COMPLETE ERD                          │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**2. CREATE TABLE Statements**

```sql

```

**3. Sample Queries**

Query 1 (Product listing):
```sql

```

Query 2 (Customer orders):
```sql

```

Query 3 (Inventory report):
```sql

```

Query 4 (Sales analytics):
```sql

```

Query 5 (Search):
```sql

```

**4. Transaction (Order Placement)**

```sql

```

**5. Indexing Strategy**

```sql

```

**6. Caching Strategy**

Description: ____________________________________________________________________

**7. Report (Monthly Sales)**

```sql

```

---

## ANSWER KEY

### Section 1: ER Modeling

**Exercise 1.1: Library Entities**

Entities:
1. **Book** - id, title, ISBN, publisher_id, publication_year, copies
2. **Author** - id, name, birth_date, nationality
3. **Patron** - id, name, email, phone, membership_date
4. **Loan** - id, book_id, patron_id, loan_date, due_date, return_date
5. **Publisher** - id, name, address, phone

Primary Keys:
- Book: id
- Author: id
- Patron: id
- Loan: id
- Publisher: id

---

**Exercise 1.2: Library Relationships**

1. Book → Author (N:M) - Junction table: Book_Author
2. Book → Publisher (N:1) - Publisher has many books, book has one publisher
3. Patron → Loan (1:N) - One patron can have many loans
4. Book → Loan (1:N) - One book can be loaned many times
5. Author → Book (N:M) - Many-to-many via Book_Author

---

**Exercise 1.3: School ERD**

Entities:
- Student (id, name, email, enrollment_date)
- Course (id, name, code, credits)
- Instructor (id, name, email, department)

Relationships:
- Student → Course (N:M) via Enrollment junction
- Instructor → Course (1:N) - One instructor teaches many courses

Primary Keys:
- Student: id
- Course: id
- Instructor: id
- Enrollment: (student_id, course_id)

Foreign Keys:
- Course: instructor_id → Instructor(id)
- Enrollment: student_id → Student(id), course_id → Course(id)

---

**Exercise 1.4: ERD to Relational Mapping**

```sql
CREATE TABLE customer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    address TEXT
);

CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    sku VARCHAR(50) UNIQUE
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(id) ON DELETE RESTRICT,
    order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    total NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE order_item (
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES product(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);
```

---

**Exercise 1.5: Complex ERD Challenge**

Entities:
1. Product (id, name, description, price, weight)
2. Category (id, name, parent_category_id)
3. Supplier (id, name, contact, address)
4. Customer (id, name, email, password)
5. Address (id, customer_id, street, city, state, zip, country, type)
6. Order (id, customer_id, order_date, status, shipping_address_id, billing_address_id)
7. Order_Item (order_id, product_id, quantity, price)
8. Payment (id, order_id, amount, method, status, date)
9. Review (id, product_id, customer_id, rating, comment, date)

Relationships:
- Product → Category (N:1) - Many products in one category, category self-reference
- Product → Supplier (N:M) - Junction: Supplier_Product
- Customer → Address (1:N) - One customer, many addresses
- Customer → Order (1:N) - One customer, many orders
- Order → Order_Item (1:N) - One order, many items
- Product → Order_Item (1:N) - One product in many orders
- Order → Payment (1:N) - One order, many payments
- Product → Review (1:N) - One product, many reviews
- Customer → Review (1:N) - One customer, many reviews

Junction Tables:
- Supplier_Product (supplier_id, product_id, supply_price)
- Product_Category (product_id, category_id)

---

### Section 2: Schema Design

**Exercise 2.1: Blog Schema**

```sql
CREATE TABLE author (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    bio TEXT
);

CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE blog (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id INTEGER NOT NULL REFERENCES author(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comment (
    id SERIAL PRIMARY KEY,
    blog_id INTEGER NOT NULL REFERENCES blog(id) ON DELETE CASCADE,
    author_name VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE blog_category (
    blog_id INTEGER NOT NULL REFERENCES blog(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES category(id) ON DELETE CASCADE,
    PRIMARY KEY (blog_id, category_id)
);
```

---

**Exercise 2.2: Product Data Types**

| Field | Data Type | NOT NULL? | Indexed? |
|-------|-----------|-----------|----------|
| product_id | SERIAL | Yes | Yes (PK) |
| name | VARCHAR(255) | Yes | Yes |
| description | TEXT | No | No |
| price | NUMERIC(10,2) | Yes | Yes |
| weight | NUMERIC(8,2) | No | No |
| in_stock | BOOLEAN | Yes | Yes |
| sku | VARCHAR(50) | Yes | Yes (UNIQUE) |
| category_id | INTEGER | Yes | Yes (FK) |
| created_date | TIMESTAMPTZ | Yes | No |
| updated_date | TIMESTAMPTZ | Yes | No |

```sql
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    weight NUMERIC(8,2),
    in_stock BOOLEAN DEFAULT TRUE,
    sku VARCHAR(50) UNIQUE NOT NULL,
    category_id INTEGER NOT NULL REFERENCES category(id),
    created_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_name ON product(name);
CREATE INDEX idx_product_category_id ON product(category_id);
```

---

**Exercise 2.3: Orders Table with Constraints**

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
    shipping_address TEXT NOT NULL,
    billing_address TEXT NOT NULL,
    CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled'))
);
```

---

**Exercise 2.4: Foreign Key Actions**

1. With current design, you cannot delete a category that has products (RESTRICT is default)

2. ON DELETE RESTRICT:
```sql
category_id INTEGER REFERENCES categories(id) ON DELETE RESTRICT
```

3. ON DELETE CASCADE:
```sql
category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE
```

4. ON DELETE SET NULL:
```sql
category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL
```

5. Best option: RESTRICT
Why: You shouldn't be able to delete a category that still has products. This protects data integrity.

---

**Exercise 2.5: Order Query Indexes**

1. Index 1:
```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```
Why: Used for equality filter on customer_id

Index 2:
```sql
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
```
Why: Covers both customer_id and status filters

2. Most efficient type: Composite + Partial
```sql
CREATE INDEX idx_orders_pending ON orders(customer_id, order_date DESC)
WHERE status = 'pending';
```
Why: Only indexes pending orders, smaller and faster

---

**Exercise 2.6: Ride-Sharing Schema**

ERD includes:
- Driver (id, name, license_plate, car_model, location)
- Rider (id, name, credit_card, location)
- Ride (id, rider_id, driver_id, pickup, dropoff, status, fare, duration)
- Rating (id, ride_id, reviewer_type, rating, comment)
- Payment (id, ride_id, amount, method, status)

```sql
CREATE TABLE driver (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    car_model VARCHAR(50) NOT NULL,
    location GEOMETRY(Point, 4326)
);

CREATE TABLE rider (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    credit_card VARCHAR(20) NOT NULL,
    location GEOMETRY(Point, 4326)
);

CREATE TABLE ride (
    id SERIAL PRIMARY KEY,
    rider_id INTEGER NOT NULL REFERENCES rider(id),
    driver_id INTEGER NOT NULL REFERENCES driver(id),
    pickup GEOMETRY(Point, 4326) NOT NULL,
    dropoff GEOMETRY(Point, 4326) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'requested',
    fare NUMERIC(10,2),
    duration INTERVAL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CHECK (status IN ('requested', 'accepted', 'started', 'completed', 'cancelled'))
);

CREATE TABLE rating (
    id SERIAL PRIMARY KEY,
    ride_id INTEGER NOT NULL REFERENCES ride(id),
    reviewer_type VARCHAR(10) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    CHECK (reviewer_type IN ('rider', 'driver'))
);

CREATE TABLE payment (
    id SERIAL PRIMARY KEY,
    ride_id INTEGER NOT NULL REFERENCES ride(id),
    amount NUMERIC(10,2) NOT NULL,
    method VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    CHECK (method IN ('credit_card', 'cash', 'apple_pay')),
    CHECK (status IN ('pending', 'completed', 'failed'))
);

-- Partition ride table by date
CREATE TABLE ride_partitioned (
    LIKE ride INCLUDING ALL
) PARTITION BY RANGE (created_at);
```

---

### Section 3: Normalization

**Exercise 3.1: Identify Normal Form**

**Table A:** Violates 1NF (multiple authors in a single column)
Fix: Create separate Author table and Book_Author junction table

**Table B:** Violates 2NF (ProductName depends on ProductID, not the full composite key)
Fix: Create separate Product table

**Table C:** Violates 3NF (DepartmentName and Manager depend on DepartmentID)
Fix: Create separate Department table

---

**Exercise 3.2: Normalize Order Table**

1NF:
Order (OrderID, Product, Quantity, Price, Total) - no repeating groups
Customer (CustomerID, CustomerName, CustomerAddress)
OrderID is PK for Order table, CustomerID FK

2NF:
Order (OrderID, CustomerID, Total)
Customer (CustomerID, CustomerName, CustomerAddress)
OrderItem (OrderID, Product, Quantity, Price)
OrderID and Product as composite PK

3NF:
Order (OrderID, CustomerID, Total)
Customer (CustomerID, CustomerName, CustomerAddress)
Product (ProductID, ProductName, Price)
OrderItem (OrderID, ProductID, Quantity)

---

**Exercise 3.3: 1NF to 3NF Transformation**

1NF:
Enrollment (StudentID, StudentName, Course) - one row per course

2NF:
Student (StudentID, StudentName)
Enrollment (StudentID, Course) - all columns depend on both?

3NF:
Student (StudentID, StudentName)
Course (CourseID, CourseName)
Enrollment (StudentID, CourseID)

---

**Exercise 3.4: Denormalization Decision**

1. Query:
```sql
SELECT AVG(rating) FROM reviews WHERE product_id = 1;
```

2. For 10,000 reviews, this query may take 10-20ms, fine for most cases, but for a popular product with 100K+ reviews, it could take 100ms+

3. Denormalize: Add `avg_rating` and `review_count` columns to Products table

4. Trade-offs:
Pros: Faster product page loads
Cons: Must update rating columns when new reviews are added, potential inconsistency

---

**Exercise 3.5: Complex Normalization**

1. Primary Key: (ProjectID, EmployeeID)

2. Functional Dependencies:
- ProjectID → ProjectName
- EmployeeID → EmployeeName, EmployeeDepartment
- ProjectID, EmployeeID → Role, Hours

3. 2NF? No. EmployeeName and EmployeeDepartment depend on EmployeeID only (partial dependency)

4. Normalized Tables:
Project (ProjectID, ProjectName)
Employee (EmployeeID, EmployeeName, EmployeeDepartment)
Assignment (ProjectID, EmployeeID, Role, Hours)

---

### Section 4: Indexing

**Exercise 4.1: EXPLAIN ANALYZE**

1. Sequential Scan
2. 2,000,000 rows
3. 150 rows
4. Estimated: 1000, Actual: 150 (skewed)
5. CREATE INDEX idx_products_category_id ON products(category_id);

---

**Exercise 4.2: Index Types**

1. B-Tree - Equality lookups
2. GIN - Full-text search
3. B-Tree - Range queries on ordered data
4. Partial B-Tree - Filter on status, index on date
5. GiST - Geospatial queries

---

**Exercise 4.3: Composite Index Order**

1. CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
2. Put customer_id first because it's used in all queries and has higher cardinality
3. For only A and B, same index works

---

**Exercise 4.4: Partial Index**

1. CREATE INDEX idx_orders_pending ON orders(order_date) WHERE status = 'pending';

2. Full index: indexes all rows; Partial index: indexes only pending rows
Size reduction: Pending orders are typically < 1% of total, so index is 99% smaller

3. SELECT * FROM orders WHERE status = 'pending' AND order_date > '2026-01-01';

---

**Exercise 4.5: Index Maintenance**

1. Most valuable: idx_orders_customer_id (high scans, good size)
2. Least valuable: idx_orders_order_date (low scans, large size)
3. Could drop: idx_orders_status (low selectivity, low usage)
4. Cost: 2GB storage + write overhead on every insert/update

---

**Exercise 4.6: Advanced Indexing**

Q1: CREATE INDEX idx_products_name_trgm ON products USING GIN(name gin_trgm_ops);
Q2: CREATE INDEX idx_products_search ON products USING GIN(search_vector);
Q3: CREATE INDEX idx_products_category_price ON products(category_id, price);
Q4: Same as Q3 (covers ordering)

---

### Section 5: Query Optimization

**Exercise 5.1: SELECT Optimization**

1. Full table scan, then filter
2. CREATE INDEX idx_orders_customer_status_date ON orders(customer_id, status, order_date DESC);
3. Optimized query:
```sql
SELECT id, customer_id, status, total_amount, order_date
FROM orders 
WHERE customer_id = 42 
  AND status = 'paid' 
  AND order_date > '2025-01-01'
ORDER BY order_date DESC;
```

---

**Exercise 5.2: Join Optimization**

1. Indexes needed:
```sql
CREATE INDEX idx_customers_id ON customers(id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_products_id ON products(id);
```

2. Filter before joining:
```sql
WITH filtered_customer AS (
    SELECT id, full_name FROM customers WHERE id = 42
),
filtered_orders AS (
    SELECT id, customer_id, total_amount FROM orders 
    WHERE customer_id = 42 AND status = 'paid'
)
SELECT fc.full_name, fo.id AS order_id, fo.total_amount, p.name AS product_name, oi.quantity
FROM filtered_customer fc
JOIN filtered_orders fo ON fc.id = fo.customer_id
JOIN order_items oi ON fo.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

3. Subquery approach - not recommended here as JOIN is more efficient.

---

**Exercise 5.3: Subquery Optimization**

1. Correlated subquery runs once per product, slow for many products

2. JOIN approach:
```sql
SELECT p.id, p.name, AVG(r.rating) AS avg_rating
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
WHERE p.price > 100
GROUP BY p.id, p.name;
```

3. CTE approach:
```sql
WITH rating_avg AS (
    SELECT product_id, AVG(rating) AS avg_rating
    FROM reviews
    GROUP BY product_id
)
SELECT p.id, p.name, COALESCE(ra.avg_rating, 0) AS avg_rating
FROM products p
LEFT JOIN rating_avg ra ON p.id = ra.product_id
WHERE p.price > 100;
```

4. Materialized view:
```sql
CREATE MATERIALIZED VIEW product_ratings AS
SELECT product_id, AVG(rating) AS avg_rating, COUNT(*) AS review_count
FROM reviews
GROUP BY product_id;
```

---

**Exercise 5.4: Bulk Operations**

1. Problem: Single UPDATE locks the entire table, may cause downtime

2. Use batch updates with pagination

3. Batch update:
```sql
DO $$
DECLARE
    batch_size INT := 10000;
    total_updated INT := 0;
BEGIN
    LOOP
        UPDATE products 
        SET price = price * 1.10 
        WHERE category_id = 5 
        AND id IN (
            SELECT id FROM products 
            WHERE category_id = 5 
            LIMIT batch_size
        );
        GET DIAGNOSTICS total_updated = ROW_COUNT;
        COMMIT;
        EXIT WHEN total_updated = 0;
    END LOOP;
END $$;
```

---

**Exercise 5.5: Query Plan Analysis**

1. Total cost: 50,000 (worst case)
2. Nested Loop
3. Yes, using index on orders
4. Sequential scan on customers is slow; add index on is_active or filter differently
5. Optimized:
```sql
CREATE INDEX idx_customers_active ON customers(id) WHERE is_active = true;

SELECT c.*, o.*
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE c.is_active = true
  AND o.customer_id IN (SELECT id FROM customers WHERE is_active = true);
```

---

### Section 6: Transactions

**Exercise 6.1: Transfer Transaction**

```sql
BEGIN;

-- Check balances
SELECT balance FROM accounts WHERE id = 1 FOR UPDATE;
SELECT balance FROM accounts WHERE id = 2 FOR UPDATE;

-- Transfer
UPDATE accounts SET balance = balance - 100 WHERE id = 1 AND balance >= 100;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- Check if update worked
IF NOT FOUND THEN
    ROLLBACK;
    RAISE EXCEPTION 'Insufficient funds';
END IF;

COMMIT;
```

---

**Exercise 6.2: Order Placement Transaction**

```sql
BEGIN;

-- Check inventory
SELECT product_id, stock_quantity, reserved_quantity 
FROM inventory 
WHERE product_id = 1 FOR UPDATE;

-- Insert order
INSERT INTO orders (customer_id, status) VALUES (42, 'pending') RETURNING id;

-- Insert items and update inventory
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 2, 999.99);

UPDATE inventory 
SET reserved_quantity = reserved_quantity + 2 
WHERE product_id = 1;

-- Calculate total
UPDATE orders 
SET total_amount = (SELECT SUM(quantity * unit_price) FROM order_items WHERE order_id = 1)
WHERE id = 1;

-- Process payment
INSERT INTO payments (order_id, amount, status) 
VALUES (1, (SELECT total_amount FROM orders WHERE id = 1), 'pending');

COMMIT;
```

---

**Exercise 6.3: Isolation Levels**

1. Transaction A: SERIALIZABLE - prevents dirty reads
2. Transaction B: READ COMMITTED or REPEATABLE READ
3. REPEATABLE READ - consistent snapshot at transaction start

---

**Exercise 6.4: Deadlock Prevention**

1. Transaction A:
```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

2. Transaction B:
```sql
BEGIN;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;
```

3. Prevent by always updating in the same order (lowest ID first).

---

**Exercise 6.5: Savepoints**

```sql
BEGIN;

-- Main operation
SAVEPOINT before_optional;

-- Optional operation
UPDATE orders SET status = 'processed' WHERE id = 1;

-- If optional fails
ROLLBACK TO SAVEPOINT before_optional;

-- Continue with other operations

COMMIT;
```

---

### Section 7: Concurrency

**Exercise 7.1: Locking Strategies**

1. Pessimistic:
```sql
BEGIN;
SELECT * FROM inventory WHERE product_id = 1 FOR UPDATE;
UPDATE inventory SET stock_quantity = stock_quantity - 2 WHERE product_id = 1;
COMMIT;
```

2. Optimistic:
```sql
BEGIN;
SELECT version FROM inventory WHERE product_id = 1;
-- In application: check version, update
UPDATE inventory 
SET stock_quantity = stock_quantity - 2, version = version + 1 
WHERE product_id = 1 AND version = current_version;
COMMIT;
```

3. Compare:
| Aspect | Pessimistic | Optimistic |
|--------|-------------|------------|
| Locking | Locks rows | No locks |
| Performance | Higher overhead | Lower overhead |
| When to use | High conflict | Low conflict |
| Retry needed | No | Yes |

---

**Exercise 7.2: Concurrency Anomalies**

Dirty Read prevention: Use READ COMMITTED or higher

Non-Repeatable Read prevention: Use REPEATABLE READ

Phantom Read prevention: Use REPEATABLE READ (PostgreSQL) or SERIALIZABLE

---

**Exercise 7.3: Queue Processing**

```sql
BEGIN;

WITH pending_orders AS (
    SELECT id 
    FROM orders 
    WHERE status = 'pending' 
    ORDER BY created_at 
    LIMIT 10 
    FOR UPDATE SKIP LOCKED
)
UPDATE orders 
SET status = 'processing' 
WHERE id IN (SELECT id FROM pending_orders)
RETURNING id;

COMMIT;
```

---

**Exercise 7.4: Read Consistency**

1. REPEATABLE READ - provides consistent snapshot
2. Use a read replica or run reports during low-traffic periods
3. `SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;`

---

### Section 8: NoSQL

**Exercise 8.1: Document Database**

1. MongoDB document:
```json
{
    "_id": ObjectId("..."),
    "name": "Product Name",
    "description": "Product description",
    "price": 99.99,
    "categories": ["Electronics", "Laptops"],
    "variants": [
        {"size": "S", "price": 99.99, "stock": 10},
        {"size": "M", "price": 109.99, "stock": 15}
    ],
    "created_at": ISODate("2026-01-01T00:00:00Z")
}
```

2. Query category:
```javascript
db.products.find({ categories: "Electronics" })
```

3. Update price:
```javascript
db.products.updateOne(
    { _id: ObjectId("...") },
    { $set: { price: 109.99 } }
)
```

---

**Exercise 8.2: Redis Session**

1. Key: `session:{session_id}`
2. Set: `HSET session:abc123 user_id 42 cart "{\"items\": [...]}"`
3. Get: `HGETALL session:abc123`
4. Set TTL: `EXPIRE session:abc123 3600`

---

**Exercise 8.3: Neo4j Recommendations**

1. Create nodes:
```cypher
CREATE (u:User {id: 1, name: "John"})
CREATE (p:Product {id: 1, name: "Laptop"})
```

2. Create relationship:
```cypher
MATCH (u:User {id: 1}), (p:Product {id: 1})
CREATE (u)-[:BOUGHT]->(p)
```

3. Recommendations:
```cypher
MATCH (u:User {id: 1})-[:BOUGHT]->(p:Product)<-[:BOUGHT]-(other:User)-[:BOUGHT]->(rec:Product)
WHERE NOT (u)-[:BOUGHT]->(rec)
RETURN rec.name, COUNT(*) AS frequency
ORDER BY frequency DESC
LIMIT 10
```

4. Similar users:
```cypher
MATCH (u:User {id: 1})-[:BOUGHT]->(p:Product)<-[:BOUGHT]-(similar:User)
RETURN similar.id, COUNT(*) AS common_products
ORDER BY common_products DESC
```

---

**Exercise 8.4: Polyglot Architecture**

| Component | Database | Justification |
|-----------|----------|---------------|
| Product catalog | MongoDB | Flexible schema, fast reads |
| Inventory | PostgreSQL | ACID transactions, consistency |
| User sessions | Redis | TTL, fast lookups |
| Recommendations | Neo4j | Relationship traversal, Cypher |

Data flow: User views product → MongoDB (fast) → User adds to cart → Redis (temporary) → User checks out → PostgreSQL (transaction) → Recommendation → Neo4j (async)

---

### Section 9: Final Project

The final project evaluation is based on completeness, correctness, and reasoning.

**Rubric:**

| Criteria | Weight | Points |
|----------|--------|--------|
| ERD Completeness | 15% | /15 |
| Schema Design | 15% | /15 |
| Normalization | 10% | /10 |
| Indexes | 15% | /15 |
| Queries | 15% | /15 |
| Transactions | 10% | /10 |
| Caching Strategy | 10% | /10 |
| Report | 10% | /10 |
| **Total** | **100%** | **/100** |

---

## CERTIFICATE OF COMPLETION

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                    MASTERING MODERN DATABASE DESIGN                │
│                                                                     │
│              STUDENT WORKBOOK COMPLETION                          │
│                                                                     │
│   This certifies that                                               │
│                                                                     │
│                    _______________________________                 │
│                                                                     │
│   Has successfully completed all exercises in the                  │
│   Mastering Modern Database Design Student Workbook               │
│                                                                     │
│   Date: _______________________________                           │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────┐      │
│   │                                                         │      │
│   │    Grade: _______________                              │      │
│   │    Instructor: _______________                         │      │
│   │                                                         │      │
│   └─────────────────────────────────────────────────────────┘      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

**[END OF STUDENT WORKBOOK]**

*This workbook contains all exercises needed to master modern database design. Complete each exercise in order and verify your answers against the answer key.*
