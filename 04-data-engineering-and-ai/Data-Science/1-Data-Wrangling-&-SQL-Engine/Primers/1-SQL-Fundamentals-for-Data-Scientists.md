# PRIMER 1: SQL Fundamentals for Data Scientists

## A Complete SQL Refresher for the Data Engineering Series

---

## Introduction

This primer is designed for readers who need a refresher on SQL fundamentals before diving into the series' data engineering content. While the main series assumes basic SQL knowledge, this primer provides a comprehensive foundation that will ensure you're ready for the analytical SQL and database engine modules in Phase 1.

**What This Primer Covers:**
- Core SQL concepts and syntax
- Data definition and manipulation
- Query optimization basics
- Window functions and advanced patterns

**What This Primer Does NOT Cover:**
- Database administration
- Query tuning beyond basics
- NoSQL or non-relational databases

---

## P.1: SQL Fundamentals

### What is SQL?

SQL (Structured Query Language) is the standard language for interacting with relational databases. Think of it as the language you use to ask questions of a database and get answers back.

**The Mental Model:**
- **Tables** = Spreadsheets (rows and columns)
- **Rows** = Records or observations
- **Columns** = Fields or attributes
- **Queries** = Questions you ask the data

### Core SQL Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `SELECT` | Retrieve data | `SELECT * FROM customers` |
| `INSERT` | Add new data | `INSERT INTO customers VALUES (1, 'John')` |
| `UPDATE` | Modify existing data | `UPDATE customers SET name = 'Jane' WHERE id = 1` |
| `DELETE` | Remove data | `DELETE FROM customers WHERE id = 1` |
| `CREATE` | Create new objects | `CREATE TABLE orders (id INT)` |
| `DROP` | Remove objects | `DROP TABLE customers` |
| `ALTER` | Modify objects | `ALTER TABLE customers ADD COLUMN email VARCHAR` |

---

## P.2: The SELECT Statement

### Basic SELECT

```sql
-- Select all columns from a table
SELECT * FROM customers;

-- Select specific columns
SELECT 
    customer_id,
    first_name,
    last_name,
    email
FROM customers;

-- Select with alias (renaming)
SELECT 
    customer_id AS id,
    first_name || ' ' || last_name AS full_name
FROM customers;

-- Limit results
SELECT * FROM orders LIMIT 10;

-- Distinct values (remove duplicates)
SELECT DISTINCT country FROM customers;
```

### Filtering with WHERE

```sql
-- Basic condition
SELECT * FROM customers 
WHERE age > 30;

-- Multiple conditions (AND/OR)
SELECT * FROM customers 
WHERE age > 30 
  AND country = 'USA'
  AND status = 'active';

-- IN operator (multiple values)
SELECT * FROM customers 
WHERE country IN ('USA', 'Canada', 'UK');

-- BETWEEN operator (range)
SELECT * FROM orders 
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31';

-- LIKE operator (pattern matching)
SELECT * FROM customers 
WHERE email LIKE '%@gmail.com';
-- % = any characters, _ = single character

-- IS NULL / IS NOT NULL
SELECT * FROM customers 
WHERE phone IS NOT NULL;
```

### Sorting with ORDER BY

```sql
-- Ascending order (default)
SELECT * FROM customers 
ORDER BY last_name;

-- Descending order
SELECT * FROM customers 
ORDER BY last_name DESC;

-- Multiple columns
SELECT * FROM customers 
ORDER BY country ASC, last_name DESC;
```

---

## P.3: Joins - Combining Tables

### Understanding Joins

**The Mental Model:**

Think of joins like combining two tables by matching keys—like merging two spreadsheets on a common column.

```
Customers Table          Orders Table
+----+--------+          +----+-------------+
| id | name   |          | id | customer_id |
+----+--------+          +----+-------------+
| 1  | Alice  |          | 1  | 1           |
| 2  | Bob    |          | 2  | 1           |
| 3  | Carol  |          | 3  | 2           |
+----+--------+          +----+-------------+
```

### JOIN Types

```sql
-- INNER JOIN: Only matching rows in both tables
SELECT 
    c.name,
    o.order_id
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;
-- Returns: Alice (orders 1,2), Bob (order 3)
-- Carol excluded (no orders)

-- LEFT JOIN: All rows from left table, matching from right
SELECT 
    c.name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;
-- Returns: Alice (1,2), Bob (3), Carol (NULL)

-- RIGHT JOIN: All rows from right table, matching from left
SELECT 
    c.name,
    o.order_id
FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;
-- Returns: Alice (1,2), Bob (3), all orders

-- FULL OUTER JOIN: All rows from both tables
SELECT 
    c.name,
    o.order_id
FROM customers c
FULL OUTER JOIN orders o ON c.id = o.customer_id;
-- Returns: All customers and all orders

-- CROSS JOIN: Cartesian product (every combination)
SELECT 
    c.name,
    o.order_id
FROM customers c
CROSS JOIN orders o;
-- Returns: Every customer with every order
```

### Self-Join (Joining a Table to Itself)

```sql
-- Find employees and their managers
SELECT 
    e.name AS employee,
    m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

---

## P.4: Aggregations

### Aggregate Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `COUNT()` | Count rows | `COUNT(*)` |
| `SUM()` | Sum values | `SUM(sales)` |
| `AVG()` | Average | `AVG(price)` |
| `MIN()` | Minimum | `MIN(order_date)` |
| `MAX()` | Maximum | `MAX(amount)` |
| `COUNT(DISTINCT)` | Unique values | `COUNT(DISTINCT customer_id)` |

### GROUP BY

```sql
-- Basic grouping
SELECT 
    category,
    COUNT(*) AS product_count,
    AVG(price) AS avg_price
FROM products
GROUP BY category;

-- Multiple columns
SELECT 
    category,
    region,
    SUM(sales) AS total_sales
FROM orders
GROUP BY category, region;

-- HAVING clause (filtering groups)
SELECT 
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category
HAVING COUNT(*) > 5;
-- HAVING filters after grouping, WHERE filters before

-- Difference: WHERE vs HAVING
SELECT 
    category,
    AVG(price) AS avg_price
FROM products
WHERE price > 10              -- Filters rows before grouping
GROUP BY category
HAVING AVG(price) > 20;       -- Filters groups after aggregation
```

---

## P.5: Subqueries

### Types of Subqueries

```sql
-- 1. Subquery in WHERE (scalar subquery)
SELECT * FROM orders 
WHERE total_amount > (
    SELECT AVG(total_amount) 
    FROM orders
);

-- 2. Subquery with IN
SELECT * FROM customers 
WHERE customer_id IN (
    SELECT customer_id 
    FROM orders 
    WHERE status = 'high_value'
);

-- 3. Subquery with EXISTS (check existence)
SELECT * FROM customers c
WHERE EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);

-- 4. Subquery in FROM (derived table)
SELECT 
    category,
    avg_price
FROM (
    SELECT 
        category,
        AVG(price) AS avg_price
    FROM products
    GROUP BY category
) AS category_stats
WHERE avg_price > 100;

-- 5. Correlated subquery (references outer query)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    (SELECT COUNT(*) 
     FROM orders o 
     WHERE o.customer_id = c.customer_id) AS order_count
FROM customers c;
```

---

## P.6: Window Functions

### Introduction to Window Functions

Window functions perform calculations across a set of rows that are related to the current row—without collapsing them into a single group like GROUP BY does.

**The Mental Model:**

Think of window functions as adding a column to your result that shows a calculation based on a "window" of rows around each row.

### ROW_NUMBER

```sql
-- Assign a sequential number to each row within a group
SELECT 
    customer_id,
    order_date,
    total_amount,
    ROW_NUMBER() OVER (ORDER BY total_amount DESC) AS rank_by_sales
FROM orders;

-- Number rows within categories (partition)
SELECT 
    category,
    product_name,
    price,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rank_in_category
FROM products;

-- Find the top 3 products in each category
WITH ranked_products AS (
    SELECT 
        category,
        product_name,
        price,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rank
    FROM products
)
SELECT * FROM ranked_products 
WHERE rank <= 3;
```

### RANK and DENSE_RANK

```sql
-- RANK: Gaps in ranking when ties
SELECT 
    product_name,
    price,
    RANK() OVER (ORDER BY price DESC) AS rank
FROM products;
-- If tie: 1, 2, 2, 4 (gap after tie)

-- DENSE_RANK: No gaps
SELECT 
    product_name,
    price,
    DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank
FROM products;
-- If tie: 1, 2, 2, 3 (no gap)
```

### LAG and LEAD

```sql
-- LAG: Previous row's value
SELECT 
    order_date,
    total_amount,
    LAG(total_amount, 1) OVER (ORDER BY order_date) AS previous_amount,
    total_amount - LAG(total_amount, 1) OVER (ORDER BY order_date) AS daily_change
FROM orders;

-- LEAD: Next row's value
SELECT 
    customer_id,
    order_date,
    total_amount,
    LEAD(order_date, 1) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date
FROM orders;
```

### Window Frames

```sql
-- Moving average (3-day window)
SELECT 
    order_date,
    total_amount,
    AVG(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) AS moving_avg_5day
FROM orders;

-- Cumulative sum
SELECT 
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date
        ROWS UNBOUNDED PRECEDING
    ) AS running_total
FROM orders;
```

### NTILE (Percentile Buckets)

```sql
-- Divide rows into 4 equal groups (quartiles)
SELECT 
    customer_id,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile
FROM customer_spending;
```

---

## P.7: Common Table Expressions (CTEs)

### Basic CTE

```sql
-- CTE is like a temporary named query
WITH high_value_customers AS (
    SELECT 
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total_amount) > 1000
)
SELECT 
    c.first_name,
    c.last_name,
    h.total_spent
FROM customers c
JOIN high_value_customers h ON c.customer_id = h.customer_id;
```

### Multiple CTEs

```sql
WITH 
-- First CTE: Customer spending
customer_spending AS (
    SELECT 
        customer_id,
        SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
-- Second CTE: Customer demographics
customer_demographics AS (
    SELECT 
        customer_id,
        first_name,
        last_name,
        country
    FROM customers
),
-- Combine them
final AS (
    SELECT 
        d.first_name,
        d.last_name,
        d.country,
        s.total_spent
    FROM customer_demographics d
    JOIN customer_spending s ON d.customer_id = s.customer_id
)
SELECT * FROM final
ORDER BY total_spent DESC;
```

### Recursive CTE

```sql
-- Generate a date series
WITH RECURSIVE date_series AS (
    SELECT '2025-01-01'::DATE AS date
    UNION ALL
    SELECT date + INTERVAL '1 day'
    FROM date_series
    WHERE date < '2025-01-31'
)
SELECT * FROM date_series;

-- Organization hierarchy
WITH RECURSIVE org_chart AS (
    -- Base: CEO
    SELECT 
        id,
        name,
        manager_id,
        1 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive: Reports
    SELECT 
        e.id,
        e.name,
        e.manager_id,
        oc.level + 1
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT * FROM org_chart;
```

---

## P.8: Query Optimization Basics

### Understanding Execution Plans

```sql
-- EXPLAIN: Shows query plan without executing
EXPLAIN 
SELECT * FROM orders WHERE order_date > '2025-01-01';

-- EXPLAIN ANALYZE: Shows plan AND executes
EXPLAIN ANALYZE 
SELECT * FROM orders WHERE order_date > '2025-01-01';
```

### Key Plan Types

| Plan Type | Description | Good/Bad |
|-----------|-------------|----------|
| **Seq Scan** | Scans entire table | Bad for large tables |
| **Index Scan** | Uses index to find rows | Good |
| **Index Only Scan** | Reads only index, no table | Best |
| **Nested Loop** | Loops through tables | Bad for large datasets |
| **Hash Join** | Builds hash table | Good for large joins |
| **Merge Join** | Sorts and merges | Good for sorted data |

### Indexing Basics

```sql
-- Create a B-Tree index (default)
CREATE INDEX idx_customers_last_name ON customers(last_name);

-- Create composite index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Create unique index
CREATE UNIQUE INDEX idx_customers_email ON customers(email);

-- Create partial index (only for specific rows)
CREATE INDEX idx_recent_orders ON orders(order_date)
WHERE order_date > '2025-01-01';

-- Drop index
DROP INDEX idx_customers_last_name;
```

### Query Writing Tips

```sql
-- 1. SELECT only needed columns
-- Bad: SELECT * FROM customers
-- Good: SELECT customer_id, first_name, last_name FROM customers

-- 2. Use WHERE filters early
-- Bad: Join then filter
-- Good: Filter then join

-- 3. Avoid functions in WHERE on indexed columns
-- Bad: WHERE DATE(order_date) = '2025-01-01'
-- Good: WHERE order_date >= '2025-01-01' AND order_date < '2025-01-02'

-- 4. Use EXISTS instead of IN for subqueries
-- Better: EXISTS (SELECT 1 FROM orders WHERE customer_id = c.id)
-- Worse: customer_id IN (SELECT customer_id FROM orders)

-- 5. Use CTEs for complex queries
-- Cleaner and often more efficient

-- 6. Consider materialized views for expensive aggregations
CREATE MATERIALIZED VIEW daily_sales AS
SELECT 
    DATE(order_date) AS sale_date,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY DATE(order_date);
```

---

## P.9: Data Types & Schema Design

### Common Data Types

| Type | Description | Example |
|------|-------------|---------|
| **INTEGER** | Whole numbers | 42, -5, 1000 |
| **DECIMAL(p,s)** | Fixed precision decimal | 99.99 |
| **FLOAT** | Approximate numeric | 3.14159 |
| **VARCHAR(n)** | Variable length string | 'Hello World' |
| **TEXT** | Unlimited string | 'Long text...' |
| **BOOLEAN** | True/False | TRUE, FALSE |
| **DATE** | Date (no time) | '2025-01-01' |
| **TIMESTAMP** | Date and time | '2025-01-01 14:30:00' |
| **JSON** | JSON data | '{"key": "value"}' |
| **UUID** | Universal identifier | 'abc123-def456' |

### Constraints

```sql
CREATE TABLE customers (
    -- Primary key constraint
    customer_id SERIAL PRIMARY KEY,
    
    -- Not null constraint
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    
    -- Unique constraint
    email VARCHAR(100) UNIQUE NOT NULL,
    
    -- Check constraint
    age INTEGER CHECK (age >= 18 AND age <= 120),
    
    -- Default value
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    
    -- Foreign key constraint
    customer_id INTEGER REFERENCES customers(customer_id),
    
    -- Multiple constraints
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    
    status VARCHAR(20) DEFAULT 'pending'
);
```

---

## P.10: Practice Problems

### Exercise 1: Customer Analysis

```sql
/*
Problem: Find the top 5 customers by total spending,
including their name, total spent, and number of orders.
*/

-- Your solution here
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;
```

### Exercise 2: Running Total

```sql
/*
Problem: Calculate a running total of sales by date.
*/

-- Your solution here
SELECT 
    order_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY order_date) AS running_total
FROM orders
ORDER BY order_date;
```

### Exercise 3: Customer Retention

```sql
/*
Problem: Find customers who have made more than one purchase
and the time between their first and second purchase.
*/

-- Your solution here
WITH customer_orders AS (
    SELECT 
        customer_id,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_num
    FROM orders
),
first_second AS (
    SELECT 
        customer_id,
        MIN(CASE WHEN order_num = 1 THEN order_date END) AS first_order,
        MIN(CASE WHEN order_num = 2 THEN order_date END) AS second_order
    FROM customer_orders
    GROUP BY customer_id
    HAVING COUNT(*) >= 2
)
SELECT 
    c.first_name,
    c.last_name,
    f.first_order,
    f.second_order,
    f.second_order - f.first_order AS days_between
FROM first_second f
JOIN customers c ON f.customer_id = c.customer_id;
```

### Exercise 4: Monthly Growth

```sql
/*
Problem: Calculate month-over-month sales growth.
*/

-- Your solution here
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    total_sales,
    LAG(total_sales, 1) OVER (ORDER BY month) AS previous_month,
    ((total_sales - LAG(total_sales, 1) OVER (ORDER BY month)) / 
     LAG(total_sales, 1) OVER (ORDER BY month) * 100) AS growth_pct
FROM monthly_sales
ORDER BY month;
```

---

## P.11: Key Takeaways

### Summary Checklist

✅ **Core SELECT:** Filter (WHERE), sort (ORDER BY), limit (LIMIT)

✅ **Joins:** INNER, LEFT, RIGHT, FULL, CROSS, SELF

✅ **Aggregations:** COUNT, SUM, AVG, MIN, MAX with GROUP BY

✅ **Subqueries:** Scalar, IN, EXISTS, derived tables, correlated

✅ **Window Functions:** ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, NTILE

✅ **CTEs:** Named queries, recursive CTEs

✅ **Indexing:** B-Tree, composite, partial, unique

✅ **Query Planning:** EXPLAIN, EXPLAIN ANALYZE

### Common Pitfalls to Avoid

| Pitfall | Solution |
|---------|----------|
| `SELECT *` | Select only needed columns |
| Missing indexes | Add indexes on WHERE/JOIN columns |
| Functions on indexed columns | Avoid functions in WHERE |
| Cartesian joins | Always use explicit JOIN conditions |
| Nested queries vs CTEs | Use CTEs for readability |
| Not using EXPLAIN | Always check query plans |

---

**[PRIMER 1 COMPLETE]**  
