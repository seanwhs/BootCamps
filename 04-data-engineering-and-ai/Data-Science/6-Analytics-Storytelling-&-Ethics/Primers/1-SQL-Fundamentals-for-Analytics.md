# Primer 1: SQL Fundamentals for Analytics

## Introduction to This Primer

### Why This Primer Exists

Throughout this tutorial series, we assume you have basic SQL knowledge. But "basic" can mean different things to different people. This primer ensures we're all on the same page - it's your **"SQL boot camp"** that covers everything you need to follow along with the series.

Think of this as your **"language dictionary"** for the series. When you encounter a SQL concept you're unsure about, come back here for a clear, practical explanation.

### What This Primer Covers

1. **Core SQL Concepts** - SELECT, WHERE, JOIN, GROUP BY
2. **Advanced SQL for Analytics** - Window functions, CTEs, aggregations
3. **PostgreSQL Specifics** - What's different about our database
4. **dbt SQL Patterns** - How we write SQL in dbt
5. **Performance Tips** - Writing fast queries
6. **Common Mistakes** - And how to avoid them

### How to Use This Primer
- **As a reference:** Look up specific concepts when you need them
- **As a tutorial:** Work through the examples in order
- **As a cheat sheet:** Keep it open while writing queries

---

## Chapter 1: Core SQL Concepts

### 1.1 The SELECT Statement

**The Concept:** SELECT is how you ask the database for data. Think of it as telling a librarian, "I want to see these specific books from this specific shelf."

**The Syntax:**
```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

**Our Examples:**

```sql
-- Select everything from a table
SELECT * FROM analytics.customers;

-- Select specific columns
SELECT customer_id, email, first_name, last_name
FROM analytics.customers;

-- Select with a condition
SELECT customer_id, email, registration_date
FROM analytics.customers
WHERE is_active = true;

-- Select with calculated columns
SELECT 
    customer_id,
    email,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) AS age
FROM analytics.customers;
```

**Key Points:**
- `*` means "all columns" (use sparingly in production)
- Column aliases use `AS` (makes results more readable)
- Use `DISTINCT` to remove duplicates: `SELECT DISTINCT category_id FROM analytics.products`

---

### 1.2 Filtering with WHERE

**The Concept:** WHERE is your filter - it decides which rows to include. Like saying, "Only show me customers who live in California."

**The Syntax:**
```sql
SELECT columns
FROM table
WHERE condition1 AND/OR condition2;
```

**Our Examples:**

```sql
-- Simple comparison
SELECT * FROM analytics.orders
WHERE total_amount > 100;

-- Multiple conditions
SELECT * FROM analytics.orders
WHERE total_amount > 100 
  AND status = 'completed'
  AND order_date >= '2024-01-01';

-- Text matching
SELECT * FROM analytics.customers
WHERE email LIKE '%@gmail.com';

-- IN operator
SELECT * FROM analytics.products
WHERE category_id IN (
    '123e4567-e89b-12d3-a456-426614174000',
    '123e4567-e89b-12d3-a456-426614174001'
);

-- BETWEEN operator
SELECT * FROM analytics.orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- IS NULL (checking for missing data)
SELECT * FROM analytics.customers
WHERE phone IS NULL;

-- NOT operator
SELECT * FROM analytics.customers
WHERE is_active = true 
  AND NOT is_verified = false;
```

**Key Points:**
- `=` for exact matches, `LIKE` for pattern matching
- `%` in LIKE means "any characters" (`LIKE 'John%'` finds John, Johnny, Johnson)
- `IN` is cleaner than multiple OR conditions
- Always handle NULLs explicitly

---

### 1.3 Sorting with ORDER BY

**The Concept:** ORDER BY puts your results in a specific sequence. Like alphabetizing a list of names.

**The Syntax:**
```sql
SELECT columns
FROM table
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC];
```

**Our Examples:**

```sql
-- Ascending order (default)
SELECT customer_id, email, registration_date
FROM analytics.customers
ORDER BY registration_date;

-- Descending order
SELECT customer_id, email, registration_date
FROM analytics.customers
ORDER BY registration_date DESC;

-- Multiple columns
SELECT customer_id, total_amount, order_date
FROM analytics.orders
ORDER BY total_amount DESC, order_date DESC;

-- ORDER BY with calculated field
SELECT 
    customer_id,
    total_amount,
    total_amount * 0.08 AS tax
FROM analytics.orders
ORDER BY tax DESC;
```

**Key Points:**
- ASC is ascending (A-Z, 1-10), DESC is descending (Z-A, 10-1)
- NULLs come first in ASC order, last in DESC order
- You can ORDER BY column position: `ORDER BY 2, 3` (but this is confusing - avoid it)

---

### 1.4 Limiting Results with LIMIT

**The Concept:** LIMIT restricts how many rows you get back. Like taking only the first 10 items from a shelf.

**The Syntax:**
```sql
SELECT columns
FROM table
LIMIT number;
```

**Our Examples:**

```sql
-- Get the first 10 rows
SELECT * FROM analytics.customers
LIMIT 10;

-- Get top 5 highest spenders
SELECT customer_id, total_amount
FROM analytics.orders
ORDER BY total_amount DESC
LIMIT 5;

-- Offset (skip first 10, then get 5)
SELECT * FROM analytics.customers
ORDER BY registration_date
LIMIT 5 OFFSET 10;
```

**Key Points:**
- Use LIMIT with ORDER BY for meaningful results
- Without ORDER BY, LIMIT returns arbitrary rows
- `OFFSET` is for pagination (skip N rows)
- In PostgreSQL, `LIMIT` can also be written as `FETCH FIRST number ROWS ONLY`

---

### 1.5 Aggregations with GROUP BY

**The Concept:** GROUP BY groups rows that have the same values, then you can calculate summaries (counts, sums, averages) for each group. Like grouping customers by city and counting how many are in each city.

**The Syntax:**
```sql
SELECT 
    group_column,
    AGGREGATE_FUNCTION(column)
FROM table
GROUP BY group_column;
```

**Common Aggregate Functions:**
| Function | What It Does |
|----------|--------------|
| `COUNT(*)` | Number of rows |
| `COUNT(column)` | Number of non-null values |
| `SUM(column)` | Sum of values |
| `AVG(column)` | Average of values |
| `MIN(column)` | Minimum value |
| `MAX(column)` | Maximum value |

**Our Examples:**

```sql
-- Count customers by tier
SELECT 
    customer_tier,
    COUNT(*) AS customer_count
FROM analytics_dbt.dm_customer_360
GROUP BY customer_tier
ORDER BY customer_count DESC;

-- Sum revenue by month
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS total_revenue,
    COUNT(*) AS order_count,
    AVG(total_amount) AS avg_order_value
FROM analytics.orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

-- Multiple grouping columns
SELECT 
    status,
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS count,
    SUM(total_amount) AS revenue
FROM analytics.orders
GROUP BY status, DATE_TRUNC('month', order_date)
ORDER BY month DESC, status;

-- Filtering groups with HAVING
SELECT 
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM analytics.orders
GROUP BY customer_id
HAVING COUNT(*) > 5
ORDER BY total_spent DESC;
```

**Key Points:**
- Every column in SELECT must be in GROUP BY or be an aggregate
- HAVING filters groups (WHERE filters individual rows)
- Always use meaningful aliases for aggregate columns

---

### 1.6 Joining Tables with JOIN

**The Concept:** JOIN is how you combine data from multiple tables. Like putting together pieces of a puzzle - you connect tables using a common key.

**Types of JOINs:**
```
┌─────────────────────────────────────────────────────────────┐
│ INNER JOIN: Only matching rows from both tables            │
├─────────────────────────────────────────────────────────────┤
│ LEFT JOIN: All rows from left table + matching right       │
├─────────────────────────────────────────────────────────────┤
│ RIGHT JOIN: All rows from right table + matching left      │
├─────────────────────────────────────────────────────────────┤
│ FULL OUTER JOIN: All rows from both tables                 │
├─────────────────────────────────────────────────────────────┤
│ CROSS JOIN: Every combination of rows                      │
└─────────────────────────────────────────────────────────────┘
```

**The Syntax:**
```sql
SELECT columns
FROM table1
[INNER|LEFT|RIGHT|FULL] JOIN table2
    ON table1.key = table2.key;
```

**Our Examples:**

```sql
-- INNER JOIN: Orders with customer details
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    c.first_name,
    c.last_name,
    c.email
FROM analytics.orders o
INNER JOIN analytics.customers c 
    ON o.customer_id = c.customer_id
WHERE o.status = 'completed'
ORDER BY o.order_date DESC
LIMIT 10;

-- LEFT JOIN: All customers with their orders (including those with no orders)
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM analytics.customers c
LEFT JOIN analytics.orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.email, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Multiple JOINs: Orders with customer and product information
SELECT 
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    p.name AS product_name,
    oi.quantity,
    oi.total_price
FROM analytics.orders o
INNER JOIN analytics.customers c 
    ON o.customer_id = c.customer_id
INNER JOIN analytics.order_items oi 
    ON o.order_id = oi.order_id
INNER JOIN analytics.products p 
    ON oi.product_id = p.product_id
WHERE o.status = 'completed'
ORDER BY o.order_date DESC
LIMIT 20;

-- Self JOIN: Find categories and their parent categories
SELECT 
    child.name AS child_category,
    parent.name AS parent_category
FROM analytics.categories child
LEFT JOIN analytics.categories parent 
    ON child.parent_category_id = parent.category_id
WHERE child.parent_category_id IS NOT NULL;
```

**Key Points:**
- Always use table aliases (`o`, `c`, `p`) to make queries readable
- `ON` specifies the join condition (usually matching IDs)
- `USING` is shorthand when column names match: `JOIN table USING (id)`
- `LEFT JOIN` is more common than `RIGHT JOIN` (LEFT is more intuitive)

---

## Chapter 2: Advanced SQL for Analytics

### 2.1 Window Functions

**The Concept:** Window functions perform calculations across a set of rows that are related to the current row. Think of them as "running calculations" - like giving each row a rank or calculating a running total.

**The Syntax:**
```sql
function() OVER (
    PARTITION BY column  -- Defines groups
    ORDER BY column      -- Defines order within groups
    ROWS BETWEEN X AND Y -- Defines the window frame
)
```

**Common Window Functions:**
| Function | Purpose |
|----------|---------|
| `ROW_NUMBER()` | Row number within partition |
| `RANK()` | Rank with gaps |
| `DENSE_RANK()` | Rank without gaps |
| `LAG()` | Previous row value |
| `LEAD()` | Next row value |
| `SUM() OVER` | Running total |

**Our Examples:**

```sql
-- ROW_NUMBER: Rank customers by spending within each tier
SELECT 
    customer_id,
    email,
    customer_tier,
    total_spent,
    ROW_NUMBER() OVER (PARTITION BY customer_tier ORDER BY total_spent DESC) AS rank_in_tier
FROM analytics_dbt.dm_customer_360
WHERE customer_tier IS NOT NULL
ORDER BY customer_tier, rank_in_tier
LIMIT 20;

-- LAG: Compare to previous month
SELECT 
    sales_month,
    total_revenue,
    LAG(total_revenue, 1) OVER (ORDER BY sales_month) AS previous_month,
    ROUND(((total_revenue - LAG(total_revenue, 1) OVER (ORDER BY sales_month)) / 
           LAG(total_revenue, 1) OVER (ORDER BY sales_month)) * 100, 2) AS growth_percent
FROM analytics_dbt.dm_sales_summary
ORDER BY sales_month DESC;

-- Running total (cumulative sum)
SELECT 
    sales_month,
    total_revenue,
    SUM(total_revenue) OVER (ORDER BY sales_month) AS cumulative_revenue
FROM analytics_dbt.dm_sales_summary
ORDER BY sales_month;

-- Moving average (3-month)
SELECT 
    sales_month,
    total_revenue,
    AVG(total_revenue) OVER (
        ORDER BY sales_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_avg
FROM analytics_dbt.dm_sales_summary
ORDER BY sales_month;

-- Percentage of total
SELECT 
    product_id,
    name,
    total_revenue,
    ROUND(
        100.0 * total_revenue / SUM(total_revenue) OVER (),
        2
    ) AS revenue_percentage
FROM analytics_dbt.dm_product_performance
WHERE is_active = true
ORDER BY total_revenue DESC
LIMIT 10;
```

**Key Points:**
- `PARTITION BY` divides data into groups (like GROUP BY without collapsing rows)
- `ORDER BY` determines the order within each partition
- Window functions can use both `PARTITION BY` and `ORDER BY`
- Running totals need `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`

---

### 2.2 Common Table Expressions (CTEs)

**The Concept:** CTEs are temporary named result sets that you can reference within a query. Think of them as "temporary views" that exist only for your query.

**The Syntax:**
```sql
WITH cte_name AS (
    -- Your query here
)
SELECT * FROM cte_name;
```

**Our Examples:**

```sql
-- Simple CTE
WITH high_value_orders AS (
    SELECT 
        order_id,
        customer_id,
        total_amount
    FROM analytics.orders
    WHERE total_amount > 500
)
SELECT 
    hvo.*,
    c.email
FROM high_value_orders hvo
INNER JOIN analytics.customers c ON hvo.customer_id = c.customer_id
ORDER BY hvo.total_amount DESC;

-- Multiple CTEs (chained)
WITH 
customer_spending AS (
    SELECT 
        customer_id,
        COUNT(*) AS order_count,
        SUM(total_amount) AS total_spent
    FROM analytics.orders
    WHERE status = 'completed'
    GROUP BY customer_id
),
customer_segments AS (
    SELECT 
        customer_id,
        order_count,
        total_spent,
        CASE 
            WHEN total_spent >= 5000 THEN 'platinum'
            WHEN total_spent >= 2000 THEN 'gold'
            WHEN total_spent >= 500 THEN 'silver'
            ELSE 'bronze'
        END AS tier
    FROM customer_spending
)
SELECT 
    tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_spent,
    ROUND(SUM(total_spent), 2) AS total_revenue
FROM customer_segments
GROUP BY tier
ORDER BY tier;

-- CTE with window functions
WITH monthly_ranked AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        customer_id,
        SUM(total_amount) AS monthly_spend,
        RANK() OVER (PARTITION BY DATE_TRUNC('month', order_date) ORDER BY SUM(total_amount) DESC) AS monthly_rank
    FROM analytics.orders
    WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date), customer_id
)
SELECT 
    month,
    customer_id,
    monthly_spend,
    monthly_rank
FROM monthly_ranked
WHERE monthly_rank <= 5
ORDER BY month DESC, monthly_rank;
```

**Key Points:**
- CTEs make complex queries more readable
- You can reference one CTE from another
- CTEs can be materialized (stored temporarily) for performance
- Use CTEs instead of subqueries for better readability

---

### 2.3 Subqueries

**The Concept:** Subqueries are queries inside other queries. They're like "nested questions" - you ask one question based on the answer to another.

**The Syntax:**
```sql
SELECT columns
FROM table
WHERE column IN (SELECT ...)  -- Subquery in WHERE
-- OR
SELECT * FROM (SELECT ...)  -- Subquery in FROM
```

**Our Examples:**

```sql
-- Subquery in WHERE (finding customers with above-average spending)
SELECT 
    customer_id,
    email,
    total_spent
FROM analytics_dbt.dm_customer_360
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM analytics_dbt.dm_customer_360
)
ORDER BY total_spent DESC;

-- Subquery in FROM (using as a derived table)
SELECT 
    avg_order_metrics.month,
    avg_order_metrics.avg_order_value
FROM (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        AVG(total_amount) AS avg_order_value
    FROM analytics.orders
    WHERE status = 'completed'
    GROUP BY DATE_TRUNC('month', order_date)
) avg_order_metrics
WHERE avg_order_metrics.avg_order_value > 100
ORDER BY avg_order_metrics.month;

-- Correlated subquery (references outer query)
SELECT 
    c.customer_id,
    c.email,
    c.registration_date,
    (
        SELECT COUNT(*)
        FROM analytics.orders o
        WHERE o.customer_id = c.customer_id
    ) AS order_count
FROM analytics.customers c
WHERE (
    SELECT COUNT(*)
    FROM analytics.orders o
    WHERE o.customer_id = c.customer_id
) > 0
ORDER BY order_count DESC
LIMIT 10;
```

**Key Points:**
- Subqueries in WHERE use `IN`, `EXISTS`, or comparison operators
- Subqueries in FROM are called "derived tables"
- Correlated subqueries reference the outer query (can be slow)
- In most cases, CTEs are cleaner than derived tables

---

## Chapter 3: PostgreSQL Specifics

### 3.1 PostgreSQL Data Types

| PostgreSQL Type | Description | Example |
|-----------------|-------------|---------|
| `UUID` | Universally unique identifier | `123e4567-e89b-12d3-a456-426614174000` |
| `TIMESTAMP` | Date and time | `2024-07-29 14:30:00` |
| `TIMESTAMP WITH TIME ZONE` | Date/time with timezone | `2024-07-29 14:30:00+01` |
| `DECIMAL(10,2)` | Fixed precision | `123.45` |
| `JSONB` | JSON with indexing | `{"name": "John", "age": 30}` |
| `TEXT` | Variable-length string | `"Hello World"` |
| `BOOLEAN` | True/False | `true` or `false` |

**Our Examples:**

```sql
-- Working with UUID (using the extension)
SELECT uuid_generate_v4() AS random_uuid;

-- Working with TIMESTAMP
SELECT 
    order_id,
    order_date,
    order_date::DATE AS order_date_only,  -- Cast to date
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    EXTRACT(DOW FROM order_date) AS day_of_week
FROM analytics.orders
LIMIT 5;

-- Working with JSONB
CREATE TABLE IF NOT EXISTS analytics.user_preferences (
    user_id UUID PRIMARY KEY,
    preferences JSONB
);

-- Insert JSON data
INSERT INTO analytics.user_preferences 
VALUES (
    '123e4567-e89b-12d3-a456-426614174000',
    '{"theme": "dark", "notifications": true, "language": "en"}'
);

-- Query JSON
SELECT 
    user_id,
    preferences->>'theme' AS theme,
    preferences->>'language' AS language
FROM analytics.user_preferences;
```

### 3.2 PostgreSQL Functions

**Common Functions:**

| Function | Purpose | Example |
|----------|---------|---------|
| `DATE_TRUNC()` | Truncate to specified precision | `DATE_TRUNC('month', order_date)` |
| `AGE()` | Calculate age between dates | `AGE(CURRENT_DATE, date_of_birth)` |
| `EXTRACT()` | Extract part of date | `EXTRACT(YEAR FROM order_date)` |
| `COALESCE()` | Return first non-null value | `COALESCE(null_column, 'default')` |
| `NULLIF()` | Return NULL if values equal | `NULLIF(column, '')` |
| `CONCAT()` | Concatenate strings | `CONCAT(first_name, ' ', last_name)` |
| `ILIKE()` | Case-insensitive LIKE | `name ILIKE '%john%'` |

**Our Examples:**

```sql
-- Date functions
SELECT 
    customer_id,
    registration_date,
    DATE_TRUNC('month', registration_date) AS registration_month,
    EXTRACT(YEAR FROM registration_date) AS reg_year,
    AGE(CURRENT_DATE, date_of_birth) AS age_interval,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) AS age
FROM analytics.customers
LIMIT 10;

-- String functions
SELECT 
    customer_id,
    email,
    LOWER(email) AS email_lower,
    UPPER(email) AS email_upper,
    LEFT(email, POSITION('@' IN email) - 1) AS username,
    RIGHT(email, LENGTH(email) - POSITION('@' IN email)) AS domain
FROM analytics.customers
LIMIT 5;

-- COALESCE example
SELECT 
    customer_id,
    COALESCE(phone, 'No phone number') AS phone_display,
    COALESCE(discount_amount, 0) AS discount_clean
FROM analytics.customers
LEFT JOIN analytics.orders ON customers.customer_id = orders.customer_id
LIMIT 10;
```

### 3.3 PostgreSQL Specific Features

```sql
-- Upsert (INSERT ON CONFLICT)
INSERT INTO analytics.products (
    product_id, sku, name, unit_price
) VALUES (
    '123e4567-e89b-12d3-a456-426614174000',
    'SKU-ABC123',
    'Example Product',
    99.99
)
ON CONFLICT (sku) DO UPDATE SET
    name = EXCLUDED.name,
    unit_price = EXCLUDED.unit_price,
    updated_at = CURRENT_TIMESTAMP
RETURNING *;

-- Full-text search
CREATE INDEX idx_customers_name_search 
ON analytics.customers 
USING GIN (to_tsvector('english', first_name || ' ' || last_name));

SELECT 
    customer_id,
    first_name,
    last_name
FROM analytics.customers
WHERE to_tsvector('english', first_name || ' ' || last_name) @@ to_tsquery('John')
LIMIT 10;

-- Arrays
CREATE TABLE analytics.order_tags (
    order_id UUID PRIMARY KEY,
    tags TEXT[] DEFAULT '{}'
);

INSERT INTO analytics.order_tags 
VALUES ('123e4567-e89b-12d3-a456-426614174000', ARRAY['urgent', 'international']);

SELECT 
    order_id,
    tags,
    'urgent' = ANY(tags) AS is_urgent,
    array_length(tags, 1) AS tag_count
FROM analytics.order_tags;
```

---

## Chapter 4: dbt SQL Patterns

### 4.1 dbt Specific Syntax

```sql
-- dbt ref function
SELECT * FROM {{ ref('stg_customers') }}

-- dbt source function
SELECT * FROM {{ source('analytics', 'customers') }}

-- dbt config
{{
    config(
        materialized='view',
        tags=['staging'],
        schema='staging'
    )
}}

-- dbt variables
SELECT * FROM {{ ref('stg_customers') }}
WHERE registration_date >= '{{ var('start_date', '2024-01-01') }}'

-- dbt macros
SELECT 
    customer_id,
    {{ macro_name('column_name') }} AS calculated_value
FROM {{ ref('stg_customers') }}
```

### 4.2 dbt Model Patterns

```sql
-- Staging model pattern
{{ config(
    materialized='view'
) }}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'table_name') }}
),

renamed AS (
    SELECT
        -- Primary key
        id_column AS primary_key,
        
        -- Business columns with consistent naming
        column1 AS column1_clean,
        column2 AS column2_clean,
        
        -- Derived calculations
        CASE 
            WHEN condition THEN 'value1'
            ELSE 'value2'
        END AS derived_column,
        
        -- Metadata
        created_at,
        updated_at
        
    FROM source
)

SELECT * FROM renamed

-- Intermediate model pattern
{{ config(
    materialized='view',
    tags=['intermediate']
) }}

WITH staging_model AS (
    SELECT * FROM {{ ref('stg_table') }}
),

another_staging AS (
    SELECT * FROM {{ ref('stg_another_table') }}
),

joined AS (
    SELECT 
        sm.*,
        at.additional_column
    FROM staging_model sm
    LEFT JOIN another_staging at 
        ON sm.key = at.key
),

aggregated AS (
    SELECT
        key_column,
        COUNT(*) AS count_value,
        SUM(numeric_column) AS sum_value,
        AVG(numeric_column) AS avg_value
    FROM joined
    GROUP BY key_column
)

SELECT * FROM aggregated

-- Mart model pattern (with tests)
{{ config(
    materialized='table',
    tests=['unique', 'not_null']
) }}

WITH 
intermediate_1 AS (SELECT * FROM {{ ref('int_model_1') }}),
intermediate_2 AS (SELECT * FROM {{ ref('int_model_2') }})

SELECT 
    -- Business-friendly column names
    column1 AS business_name_1,
    column2 AS business_name_2,
    
    -- Pre-calculated metrics
    metric1,
    metric2,
    
    -- Date/time dimensions
    DATE_TRUNC('day', event_date) AS event_day,
    DATE_TRUNC('month', event_date) AS event_month,
    
    -- Metadata
    CURRENT_TIMESTAMP AS dbt_loaded_at
    
FROM intermediate_1
LEFT JOIN intermediate_2 USING (key_column)
```

---

## Chapter 5: Performance Tips

### 5.1 Query Optimization Checklist

```markdown
# SQL Performance Checklist

## Before Writing Your Query
- [ ] **Understand the data:** Know what's in the tables
- [ ] **Define your output:** Know exactly what you need
- [ ] **Check existing solutions:** Has this been done before?

## Writing Your Query
- [ ] **Use specific columns:** Avoid SELECT *
- [ ] **Filter early:** WHERE before JOIN if possible
- [ ] **Join on indexed columns:** Ensures fast lookups
- [ ] **Use appropriate JOIN type:** INNER vs. LEFT vs. CROSS
- [ ] **Aggregate only what you need:** GROUP BY minimal columns
- [ ] **Use LIMIT for testing:** Don't query all rows during development

## After Writing Your Query
- [ ] **EXPLAIN ANALYZE:** Check the execution plan
- [ ] **Check for full table scans:** Should be avoided
- [ ] **Verify indexes are used:** Check the plan
- [ ] **Test with realistic data:** Not just a few rows

## Index Usage
- [ ] **Primary keys:** Automatically indexed
- [ ] **Foreign keys:** Should be indexed
- [ ] **WHERE clause columns:** Consider indexing
- [ ] **JOIN columns:** Should be indexed
- [ ] **ORDER BY columns:** Consider indexing
```

### 5.2 EXPLAIN ANALYZE Examples

```sql
-- Check query execution plan
EXPLAIN ANALYZE
SELECT 
    c.email,
    COUNT(o.order_id) AS order_count
FROM analytics.customers c
LEFT JOIN analytics.orders o ON c.customer_id = o.customer_id
WHERE c.registration_date >= '2024-01-01'
GROUP BY c.customer_id, c.email
HAVING COUNT(o.order_id) > 0
ORDER BY order_count DESC;

-- What to look for:
-- 1. "Seq Scan" = full table scan (bad for large tables)
-- 2. "Index Scan" = using index (good)
-- 3. "Hash Join" = building hash table (okay)
-- 4. "Nested Loop" = joining row by row (can be slow)
-- 5. "Cost" = estimate of query cost (lower is better)
-- 6. "Actual time" = actual execution time

-- Creating indexes for performance
CREATE INDEX idx_orders_customer_date 
ON analytics.orders (customer_id, order_date DESC);

CREATE INDEX idx_orders_status_date 
ON analytics.orders (status, order_date DESC);

CREATE INDEX idx_customers_registration_date 
ON analytics.customers (registration_date DESC);
```

### 5.3 Common Performance Issues and Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| Full table scans | EXPLAIN shows Seq Scan | Add index on WHERE columns |
| Slow joins | Nested Loop on large tables | Ensure join columns are indexed |
| Too much data returned | Query runs long but LIMIT is fast | Add more WHERE filters |
| Complex subqueries | Subquery runs for each row | Rewrite as JOIN or CTE |
| Missing indexes | No Index Scan in EXPLAIN | Create appropriate indexes |
| Too many columns | SELECT * returns unnecessary data | Specify only needed columns |

**Our Examples:**
```sql
-- BEFORE: Slow query (full table scan)
SELECT * FROM analytics.orders
WHERE total_amount > 1000;

-- AFTER: Fast query (with index)
-- First create the index
CREATE INDEX idx_orders_amount ON analytics.orders(total_amount DESC);

-- Then the query uses the index
SELECT * FROM analytics.orders
WHERE total_amount > 1000
ORDER BY total_amount DESC;

-- BEFORE: Slow subquery
SELECT 
    customer_id,
    (SELECT COUNT(*) FROM analytics.orders WHERE customer_id = c.customer_id) AS order_count
FROM analytics.customers c;

-- AFTER: Fast join
SELECT 
    c.customer_id,
    COUNT(o.order_id) AS order_count
FROM analytics.customers c
LEFT JOIN analytics.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
```

---

## Chapter 6: Common Mistakes and Solutions

### 6.1 Top 10 SQL Mistakes

```markdown
# Top 10 SQL Mistakes

## 1. Using SELECT *
**Problem:** Pulls unnecessary columns, wastes resources
**Solution:** Always specify needed columns

## 2. Forgetting to handle NULLs
**Problem:** Queries produce unexpected results
**Solution:** Use COALESCE, IS NULL, or IS NOT NULL

## 3. Wrong JOIN type
**Problem:** Missing or duplicate rows
**Solution:** Understand INNER vs. LEFT JOIN

## 4. Not using indexes
**Problem:** Slow queries on large tables
**Solution:** Index WHERE, JOIN, and ORDER BY columns

## 5. WHERE vs. HAVING confusion
**Problem:** Aggregates filtered incorrectly
**Solution:** WHERE = row filtering, HAVING = group filtering

## 6. Performance issues with correlated subqueries
**Problem:** Subquery runs for each row
**Solution:** Rewrite as JOIN or CTE when possible

## 7. Missing GROUP BY columns
**Problem:** Error: "column must appear in GROUP BY"
**Solution:** Every non-aggregate column must be in GROUP BY

## 8. Using the wrong data types
**Problem:** Implicit conversions, data loss
**Solution:** Use appropriate types (UUID, TIMESTAMP, DECIMAL)

## 9. Not using LIMIT during development
**Problem:** Slow development queries
**Solution:** Always add LIMIT when testing

## 10. No indexes on foreign keys
**Problem:** Slow JOIN queries
**Solution:** Index foreign key columns
```

### 6.2 Debugging SQL Queries

```sql
-- Debugging pattern: Check each CTE separately
WITH 
step1 AS (
    SELECT * FROM analytics.customers 
    WHERE registration_date >= '2024-01-01'
),
step2 AS (
    SELECT 
        step1.*,
        COUNT(o.order_id) AS order_count
    FROM step1
    LEFT JOIN analytics.orders o ON step1.customer_id = o.customer_id
    GROUP BY step1.customer_id, step1.email
)
SELECT * FROM step2
WHERE order_count > 0
ORDER BY order_count DESC
LIMIT 10;

-- Check row counts at each step
SELECT 'Step 1' AS step, COUNT(*) AS row_count 
FROM (SELECT * FROM analytics.customers WHERE registration_date >= '2024-01-01') t

UNION ALL

SELECT 'Step 2' AS step, COUNT(*) AS row_count 
FROM (
    SELECT 
        step1.*,
        COUNT(o.order_id) AS order_count
    FROM (SELECT * FROM analytics.customers WHERE registration_date >= '2024-01-01') step1
    LEFT JOIN analytics.orders o ON step1.customer_id = o.customer_id
    GROUP BY step1.customer_id, step1.email
) t;
```

---

## Quick Reference Card

### SQL Command Priority Order
1. `FROM` and `JOIN` - Determine data source
2. `WHERE` - Filter rows
3. `GROUP BY` - Group rows
4. `HAVING` - Filter groups
5. `SELECT` - Choose columns
6. `ORDER BY` - Sort results
7. `LIMIT` - Limit results

### Common Patterns

```sql
-- Daily/Monthly/Yearly aggregations
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS count,
    SUM(total_amount) AS total
FROM table
GROUP BY DATE_TRUNC('month', order_date);

-- Top N per group
WITH ranked AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY group_column ORDER BY value_column DESC) AS rank
    FROM table
)
SELECT * FROM ranked WHERE rank <= 10;

-- Running total
SELECT 
    date,
    value,
    SUM(value) OVER (ORDER BY date) AS running_total
FROM table;

-- Year-over-Year comparison
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS current_year,
    LAG(SUM(total_amount), 12) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS previous_year
FROM table
GROUP BY DATE_TRUNC('month', order_date);
```

---

**[END OF PRIMER 1]**
