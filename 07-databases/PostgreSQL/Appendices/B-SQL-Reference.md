# Appendix B: SQL Reference & Quick Guide

This appendix serves as your comprehensive SQL reference for PostgreSQL. Think of it as your cheat sheet—a quick lookup for syntax, patterns, and best practices covered throughout the series. Keep this handy as you continue building your e-commerce application.

## B.1 PostgreSQL Data Types Quick Reference

### Target
Provide a complete reference of PostgreSQL data types with usage examples.

### Concept
Data types are the building blocks of your tables. Choosing the right type affects storage, performance, and data integrity. This reference helps you make the right choice every time.

---

## B.1.1 Numeric Types

| Type | Description | Range | Use Case | Example |
|------|-------------|-------|----------|---------|
| `SMALLINT` | Small integer | -32,768 to 32,767 | Small counters, ages | `age SMALLINT` |
| `INTEGER` | Standard integer | -2.1B to 2.1B | IDs, quantities | `quantity INTEGER` |
| `BIGINT` | Large integer | -9.2e18 to 9.2e18 | Large counters, timestamps | `timestamp_ms BIGINT` |
| `DECIMAL(p,s)` | Exact decimal | Variable | Financial values | `price DECIMAL(10,2)` |
| `NUMERIC(p,s)` | Exact decimal | Variable | Financial values (preferred) | `tax NUMERIC(10,2)` |
| `REAL` | Approximate float | 6 decimal digits | Scientific measurements | `temperature REAL` |
| `DOUBLE PRECISION` | Approximate double | 15 decimal digits | Scientific calculations | `latitude DOUBLE PRECISION` |
| `SERIAL` | Auto-incrementing integer | 1 to 2.1B | Primary keys (legacy) | `id SERIAL PRIMARY KEY` |
| `BIGSERIAL` | Auto-incrementing bigint | 1 to 9.2e18 | Large primary keys | `id BIGSERIAL PRIMARY KEY` |

### Usage Examples

```sql
-- Creating a table with numeric types
CREATE TABLE products (
    id SERIAL PRIMARY KEY,                    -- Auto-incrementing ID
    price NUMERIC(10,2) NOT NULL,             -- Price with 2 decimal places
    stock_quantity INTEGER NOT NULL DEFAULT 0, -- Integer quantity
    weight_kg DOUBLE PRECISION,               -- Approximate weight
    popularity_score REAL                     -- Approximate score
);

-- Numeric operations
SELECT 
    price,
    ROUND(price, 2) AS rounded_price,         -- Round to 2 decimals
    CEIL(price) AS ceil_price,                -- Round up
    FLOOR(price) AS floor_price,              -- Round down
    TRUNC(price, 1) AS truncated_price        -- Truncate decimals
FROM products;

-- Type casting
SELECT 
    '123'::INTEGER AS string_to_int,
    123::TEXT AS int_to_string,
    123.45::INTEGER AS float_to_int,          -- Truncates
    123.45::NUMERIC(10,2) AS float_to_numeric;
```

---

## B.1.2 Character Types

| Type | Description | Max Length | Use Case | Example |
|------|-------------|------------|----------|---------|
| `CHAR(n)` | Fixed-length string | 1 to 10,485,760 | Fixed codes, country codes | `country_code CHAR(2)` |
| `VARCHAR(n)` | Variable-length with limit | 1 to 10,485,760 | Usernames, emails | `email VARCHAR(255)` |
| `TEXT` | Unlimited variable-length | Unlimited | Descriptions, content | `description TEXT` |
| `CITEXT` | Case-insensitive text | Unlimited | Case-insensitive searches | `username CITEXT` |

### Usage Examples

```sql
-- Creating a table with character types
CREATE TABLE users (
    username VARCHAR(50) NOT NULL UNIQUE,      -- Limited username
    email VARCHAR(255) NOT NULL UNIQUE,        -- Limited email
    bio TEXT,                                  -- Unlimited bio
    country_code CHAR(2) DEFAULT 'US'          -- Fixed length code
);

-- String operations
SELECT 
    LENGTH(name) AS name_length,
    UPPER(email) AS email_upper,
    LOWER(email) AS email_lower,
    INITCAP(name) AS title_case,
    TRIM(email) AS trimmed_email,
    SUBSTRING(email, 1, POSITION('@' IN email) - 1) AS username_part,
    REPLACE(description, 'old', 'new') AS updated_desc
FROM users;

-- Pattern matching
SELECT * FROM users WHERE email LIKE '%@gmail.com';
SELECT * FROM users WHERE username ILIKE '%john%';  -- Case-insensitive
SELECT * FROM users WHERE username ~ '^[A-Z]{3}-';   -- Regex
```

---

## B.1.3 Date/Time Types

| Type | Description | Range | Use Case | Example |
|------|-------------|-------|----------|---------|
| `DATE` | Date only | 4713 BC to 5874897 AD | Birthdays, shipment dates | `birth_date DATE` |
| `TIME` | Time only (no timezone) | 00:00:00 to 24:00:00 | Store opening times | `open_time TIME` |
| `TIMETZ` | Time with timezone | 00:00:00+1559 to 24:00:00-1559 | International events | `event_time TIMETZ` |
| `TIMESTAMP` | Date and time (no tz) | 4713 BC to 294276 AD | Local timestamps | `created_at TIMESTAMP` |
| `TIMESTAMPTZ` | Date and time with tz | 4713 BC to 294276 AD | Global timestamps (preferred) | `updated_at TIMESTAMPTZ` |
| `INTERVAL` | Time span | -178000000 to 178000000 years | Durations | `duration INTERVAL` |

### Usage Examples

```sql
-- Creating a table with date/time types
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    shipped_at TIMESTAMPTZ,
    estimated_delivery DATE,
    delivery_time_window INTERVAL
);

-- Date/time operations
SELECT 
    NOW() AS current_timestamp,
    CURRENT_DATE AS today,
    CURRENT_TIME AS current_time,
    NOW() - INTERVAL '30 days' AS thirty_days_ago,
    NOW() + INTERVAL '2 hours' AS two_hours_from_now;

-- Extracting parts
SELECT 
    EXTRACT(YEAR FROM created_at) AS year,
    EXTRACT(MONTH FROM created_at) AS month,
    EXTRACT(DAY FROM created_at) AS day,
    EXTRACT(HOUR FROM created_at) AS hour,
    EXTRACT(DOW FROM created_at) AS day_of_week,  -- 0=Sunday
    EXTRACT(DOY FROM created_at) AS day_of_year
FROM orders;

-- Date formatting
SELECT 
    TO_CHAR(created_at, 'YYYY-MM-DD') AS iso_date,
    TO_CHAR(created_at, 'Month DD, YYYY') AS formatted_date,
    TO_CHAR(created_at, 'HH24:MI:SS') AS time_only,
    TO_CHAR(created_at, 'Day') AS day_name;

-- Date intervals
SELECT 
    created_at,
    shipped_at,
    shipped_at - created_at AS processing_time,
    AGE(shipped_at, created_at) AS processing_age
FROM orders
WHERE shipped_at IS NOT NULL;

-- Date comparisons
SELECT * FROM orders 
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days';
```

---

## B.1.4 Boolean and Other Types

| Type | Description | Values | Use Case | Example |
|------|-------------|--------|----------|---------|
| `BOOLEAN` | True/False | TRUE, FALSE, NULL | Flags, status | `is_active BOOLEAN` |
| `UUID` | Universally unique identifier | 128-bit hex | Primary keys | `id UUID PRIMARY KEY` |
| `JSON` | JSON data (stored as text) | JSON objects | Flexible data | `metadata JSON` |
| `JSONB` | Binary JSON | JSON objects | Flexible data (preferred) | `preferences JSONB` |
| `INET` | IPv4/IPv6 address | IP addresses | Network tracking | `ip_address INET` |
| `HSTORE` | Key-value store | Key-value pairs | Simple attributes | `attributes HSTORE` |

### Usage Examples

```sql
-- Creating a table with special types
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    ip_address INET,
    preferences JSONB NOT NULL DEFAULT '{}'::jsonb
);

-- UUID operations
SELECT 
    uuid_generate_v4() AS new_uuid,
    gen_random_uuid() AS random_uuid,
    id::TEXT AS uuid_to_string
FROM users;

-- INET operations
SELECT 
    ip_address,
    host(ip_address) AS host_part,
    masklen(ip_address) AS netmask_length
FROM users
WHERE ip_address << '192.168.1.0/24';  -- Check if in subnet
```

---

## B.2 SQL Statement Quick Reference

### Target
Provide complete syntax for all major SQL statements with examples.

### Concept
SQL statements are the verbs of database interaction. This reference covers the most common statements with their full syntax and variations.

---

## B.2.1 Data Definition Language (DDL)

### CREATE TABLE

```sql
-- Complete CREATE TABLE syntax
CREATE TABLE table_name (
    column1 datatype [constraints],
    column2 datatype [constraints],
    ...
    [table_constraints]
) [WITH (options)];

-- Example with all features
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Table constraints
    CONSTRAINT unique_name_slug UNIQUE (name, slug),
    CONSTRAINT valid_price CHECK (price >= 0)
);

-- Inherited table
CREATE TABLE premium_products (temperature_range INTERVAL) INHERITS (products);
```

### ALTER TABLE

```sql
-- Add column
ALTER TABLE products ADD COLUMN brand VARCHAR(100);

-- Drop column
ALTER TABLE products DROP COLUMN brand;

-- Rename column
ALTER TABLE products RENAME COLUMN is_active TO active;

-- Change column type
ALTER TABLE products ALTER COLUMN price TYPE NUMERIC(12,2);

-- Add constraint
ALTER TABLE products ADD CONSTRAINT unique_brand CHECK (brand IS NOT NULL);

-- Drop constraint
ALTER TABLE products DROP CONSTRAINT unique_brand;

-- Set default value
ALTER TABLE products ALTER COLUMN active SET DEFAULT TRUE;

-- Drop default
ALTER TABLE products ALTER COLUMN active DROP DEFAULT;

-- Rename table
ALTER TABLE products RENAME TO product_catalog;

-- Multiple operations in one statement
ALTER TABLE products 
    ADD COLUMN weight DECIMAL(8,2),
    ALTER COLUMN price SET NOT NULL,
    ADD CHECK (weight >= 0);
```

### DROP TABLE

```sql
-- Drop table (cascade dependencies)
DROP TABLE IF EXISTS products CASCADE;

-- Drop multiple tables
DROP TABLE products, categories, product_categories;

-- Restrict (fail if dependencies exist)
DROP TABLE products RESTRICT;
```

### CREATE INDEX

```sql
-- Basic index
CREATE INDEX idx_products_name ON products(name);

-- Unique index
CREATE UNIQUE INDEX idx_products_slug_unique ON products(slug);

-- Composite index
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Partial index
CREATE INDEX idx_orders_active ON orders(user_id) WHERE status != 'cancelled';

-- Expression index
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- GIN index for JSONB
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);

-- GIST index for range queries
CREATE INDEX idx_products_price_gist ON products USING gist(price);

-- Hash index (equality only)
CREATE INDEX idx_products_slug_hash ON products USING hash(slug);

-- BRIN index (large, naturally ordered tables)
CREATE INDEX idx_orders_created_at_brin ON orders USING brin(created_at);

-- Include additional columns (covering index)
CREATE INDEX idx_orders_user_amount ON orders(user_id) INCLUDE (total, status);

-- Drop index
DROP INDEX IF EXISTS idx_products_name;
```

---

## B.2.2 Data Manipulation Language (DML)

### INSERT

```sql
-- Basic insert
INSERT INTO products (name, slug, price) 
VALUES ('Product Name', 'product-slug', 29.99);

-- Insert with all columns
INSERT INTO products VALUES (
    1, 'Product Name', 'product-slug', 'Description', 
    29.99, 100, TRUE, NOW(), NOW()
);

-- Insert multiple rows
INSERT INTO products (name, slug, price) VALUES 
    ('Product 1', 'product-1', 19.99),
    ('Product 2', 'product-2', 29.99),
    ('Product 3', 'product-3', 39.99);

-- Insert from SELECT
INSERT INTO products (name, slug, price)
SELECT name, slug, price FROM old_products WHERE active = TRUE;

-- Insert with ON CONFLICT (UPSERT)
INSERT INTO products (name, slug, price) 
VALUES ('New Name', 'new-slug', 49.99)
ON CONFLICT (slug) 
DO UPDATE SET 
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    updated_at = NOW();

-- Return inserted data
INSERT INTO products (name, slug, price) 
VALUES ('Returning Product', 'returning-product', 59.99)
RETURNING id, name, created_at;
```

### SELECT

```sql
-- Basic SELECT
SELECT * FROM products;

-- Select specific columns
SELECT id, name, price FROM products;

-- Select with alias
SELECT name AS product_name, price AS product_price FROM products;

-- Distinct values
SELECT DISTINCT category_id FROM products;

-- Distinct on multiple columns
SELECT DISTINCT category_id, status FROM products;

-- WHERE clause
SELECT * FROM products 
WHERE price > 20.00 
  AND stock_quantity > 0 
  AND is_active = TRUE;

-- LIKE / ILIKE
SELECT * FROM products WHERE name LIKE '%wireless%';
SELECT * FROM products WHERE name ILIKE '%BLUETOOTH%';

-- IN operator
SELECT * FROM products WHERE price IN (19.99, 29.99, 39.99);

-- BETWEEN
SELECT * FROM products WHERE price BETWEEN 20 AND 50;

-- IS NULL / IS NOT NULL
SELECT * FROM products WHERE description IS NULL;
SELECT * FROM products WHERE description IS NOT NULL;

-- ORDER BY
SELECT * FROM products ORDER BY price DESC;
SELECT * FROM products ORDER BY category_id, price;

-- LIMIT / OFFSET
SELECT * FROM products ORDER BY price LIMIT 10 OFFSET 20;

-- GROUP BY
SELECT 
    category_id,
    COUNT(*) AS count,
    AVG(price) AS avg_price
FROM products
GROUP BY category_id;

-- HAVING
SELECT 
    category_id,
    COUNT(*) AS count
FROM products
GROUP BY category_id
HAVING COUNT(*) > 5;

-- JOIN variants
-- INNER JOIN
SELECT u.email, o.total
FROM users u
JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN
SELECT u.email, COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.email;

-- RIGHT JOIN (less common)
SELECT p.name, oi.quantity
FROM order_items oi
RIGHT JOIN products p ON p.id = oi.product_id;

-- FULL OUTER JOIN
SELECT u.email, o.id
FROM users u
FULL JOIN orders o ON u.id = o.user_id;

-- CROSS JOIN (Cartesian product)
SELECT u.email, p.name
FROM users u
CROSS JOIN products p;

-- Self JOIN
SELECT c1.name AS category, c2.name AS parent_category
FROM categories c1
LEFT JOIN categories c2 ON c1.parent_id = c2.id;

-- Subqueries
SELECT * FROM products 
WHERE price > (SELECT AVG(price) FROM products);

SELECT * FROM products 
WHERE id IN (SELECT product_id FROM order_items GROUP BY product_id);

-- Window functions
SELECT 
    name,
    price,
    RANK() OVER (ORDER BY price DESC) AS rank,
    AVG(price) OVER () AS overall_avg,
    price - AVG(price) OVER () AS diff_from_avg
FROM products;

-- Common Table Expressions (CTE)
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        SUM(total) AS revenue
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY month
)
SELECT 
    month,
    revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS growth
FROM monthly_revenue;

-- UNION
SELECT name FROM products
UNION
SELECT name FROM old_products;

-- UNION ALL (includes duplicates)
SELECT name FROM products
UNION ALL
SELECT name FROM old_products;

-- EXCEPT
SELECT name FROM products
EXCEPT
SELECT name FROM archived_products;

-- INTERSECT
SELECT name FROM products
INTERSECT
SELECT name FROM current_catalog;
```

### UPDATE

```sql
-- Basic UPDATE
UPDATE products SET price = 29.99 WHERE id = 1;

-- Update multiple columns
UPDATE products 
SET price = 29.99, 
    stock_quantity = 150 
WHERE id = 1;

-- Update with expression
UPDATE products 
SET price = price * 1.10 
WHERE price < 20;

-- Update with subquery
UPDATE products 
SET price = (
    SELECT AVG(price) 
    FROM product_categories pc 
    WHERE pc.product_id = products.id
)
WHERE id = 1;

-- Update with JOIN (using FROM)
UPDATE products p
SET stock_quantity = stock_quantity + oi.quantity
FROM order_items oi
WHERE p.id = oi.product_id 
  AND oi.order_id = 1;

-- Update with RETURNING
UPDATE products 
SET stock_quantity = stock_quantity - 1 
WHERE id = 1 AND stock_quantity > 0
RETURNING id, name, stock_quantity;

-- Conditional UPDATE with CASE
UPDATE products 
SET price = CASE 
    WHEN price < 20 THEN price * 1.15
    WHEN price < 50 THEN price * 1.10
    ELSE price * 1.05
END
WHERE is_active = true;
```

### DELETE

```sql
-- Basic DELETE
DELETE FROM products WHERE id = 1;

-- Delete with JOIN
DELETE FROM products p
USING order_items oi
WHERE p.id = oi.product_id 
  AND oi.order_id = 1;

-- Delete with RETURNING
DELETE FROM products 
WHERE is_active = false 
AND stock_quantity = 0
RETURNING id, name;

-- Truncate (faster, resets sequences)
TRUNCATE TABLE products;
TRUNCATE TABLE products, categories RESTART IDENTITY;
```

---

## B.2.3 Transaction Control

### Transaction Commands

```sql
-- Start transaction
BEGIN;
-- or
START TRANSACTION;

-- Transaction with isolation level
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- or
START TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Savepoint
SAVEPOINT my_savepoint;

-- Rollback to savepoint
ROLLBACK TO SAVEPOINT my_savepoint;

-- Release savepoint
RELEASE SAVEPOINT my_savepoint;

-- Commit transaction
COMMIT;

-- Rollback transaction
ROLLBACK;

-- Set transaction settings
SET TRANSACTION READ ONLY;
SET TRANSACTION READ WRITE;
SET TRANSACTION DEFERRABLE;
```

### Locking Commands

```sql
-- Row-level locking (pessimistic)
SELECT * FROM products WHERE id = 1 FOR UPDATE;
SELECT * FROM products WHERE id = 1 FOR UPDATE NOWAIT;
SELECT * FROM products WHERE id = 1 FOR UPDATE SKIP LOCKED;

SELECT * FROM products WHERE id = 1 FOR SHARE;
SELECT * FROM products WHERE id = 1 FOR KEY SHARE;

-- Table-level locks
LOCK TABLE products IN ACCESS SHARE MODE;
LOCK TABLE products IN ROW EXCLUSIVE MODE;
LOCK TABLE products IN SHARE UPDATE EXCLUSIVE MODE;
LOCK TABLE products IN SHARE MODE;
LOCK TABLE products IN SHARE ROW EXCLUSIVE MODE;
LOCK TABLE products IN EXCLUSIVE MODE;
LOCK TABLE products IN ACCESS EXCLUSIVE MODE;

-- Advisory locks
SELECT pg_advisory_lock(12345);
SELECT pg_advisory_unlock(12345);
SELECT pg_advisory_lock_shared(12345);
SELECT pg_advisory_unlock_shared(12345);
```

---

## B.3 PostgreSQL Functions Reference

### Target
Complete reference of PostgreSQL built-in functions used in the series.

### Concept
Functions extend SQL's power. This reference covers the most useful built-in functions with examples.

---

## B.3.1 String Functions

```sql
-- Concatenation
SELECT 'Hello' || ' ' || 'World';
SELECT CONCAT('Hello', ' ', 'World');
SELECT CONCAT_WS('-', '2024', '01', '01');

-- Length
SELECT LENGTH('Hello World');
SELECT CHAR_LENGTH('Hello World');

-- Case conversion
SELECT UPPER('Hello World');
SELECT LOWER('Hello World');
SELECT INITCAP('hello world');  -- Title Case

-- Trimming
SELECT TRIM('  Hello  ');
SELECT LTRIM('  Hello');
SELECT RTRIM('Hello  ');
SELECT TRIM('x' FROM 'xxxHelloxxx');

-- Substring
SELECT SUBSTRING('Hello World', 7, 5);
SELECT SUBSTRING('Hello World', 7);  -- 'World'
SELECT SUBSTRING('Hello World' FROM 7 FOR 5);

-- Position
SELECT POSITION('World' IN 'Hello World');
SELECT STRPOS('Hello World', 'World');

-- Replace
SELECT REPLACE('Hello World', 'World', 'PostgreSQL');
SELECT TRANSLATE('12345', '123', 'abc');

-- Split
SELECT SPLIT_PART('a,b,c', ',', 2);  -- 'b'
SELECT UNNEST(string_to_array('a,b,c', ','));

-- Pattern matching
SELECT 'Hello World' LIKE 'Hello%';
SELECT 'Hello World' ILIKE '%WORLD%';
SELECT 'Hello World' ~ '^Hello.*';
SELECT 'Hello World' ~* '^hello.*';  -- Case-insensitive regex

-- Formatting
SELECT FORMAT('Hello %s, you have %s messages', 'John', 5);
SELECT QUOTE_LITERAL('Don''t stop');
SELECT QUOTE_IDENT('column-name');

-- Other
SELECT LEFT('Hello World', 5);
SELECT RIGHT('Hello World', 5);
SELECT LPAD('123', 5, '0');   -- '00123'
SELECT RPAD('123', 5, '0');   -- '12300'
SELECT REVERSE('Hello');
SELECT REPEAT('Ha', 3);       -- 'HaHaHa'
```

---

## B.3.2 Numeric Functions

```sql
-- Basic arithmetic
SELECT 5 + 3, 5 - 3, 5 * 3, 5 / 3, 5 % 3;
SELECT 5 ^ 3 AS power, |/ 9 AS sqrt, ||/ 27 AS cube_root;

-- Rounding
SELECT ROUND(123.456, 2);    -- 123.46
SELECT ROUND(123.456);       -- 123
SELECT CEIL(123.456);        -- 124
SELECT FLOOR(123.456);       -- 123
SELECT TRUNC(123.456, 2);    -- 123.45

-- Absolute and sign
SELECT ABS(-123);
SELECT SIGN(-123);           -- -1

-- Random
SELECT RANDOM();
SELECT RANDOM() * 100;       -- Random between 0 and 100
SELECT FLOOR(RANDOM() * 100) + 1;  -- Random integer 1-100

-- Trigonometric
SELECT SIN(1), COS(1), TAN(1);
SELECT ASIN(0.5), ACOS(0.5), ATAN(1);

-- Other
SELECT SQRT(16);
SELECT CBRT(27);
SELECT POWER(2, 10);
SELECT EXP(1);               -- e^1
SELECT LN(2.71828);          -- Natural log
SELECT LOG(10, 100);         -- Log base 10

-- Generate series (arrays of numbers)
SELECT GENERATE_SERIES(1, 10);          -- 1,2,3,...,10
SELECT GENERATE_SERIES(1, 10, 2);        -- 1,3,5,7,9
```

---

## B.3.3 Date/Time Functions

```sql
-- Current date/time
SELECT NOW();
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
SELECT CURRENT_TIMESTAMP;
SELECT LOCALTIMESTAMP;

-- Date arithmetic
SELECT NOW() + INTERVAL '1 day';
SELECT NOW() - INTERVAL '2 hours';
SELECT NOW() + '2 days'::INTERVAL;

-- Date difference
SELECT AGE('2024-01-01'::DATE, '2020-01-01'::DATE);
SELECT EXTRACT(DAY FROM NOW() - '2020-01-01'::DATE);

-- Extract parts
SELECT EXTRACT(YEAR FROM NOW());
SELECT EXTRACT(MONTH FROM NOW());
SELECT EXTRACT(DAY FROM NOW());
SELECT EXTRACT(HOUR FROM NOW());
SELECT EXTRACT(DOW FROM NOW());  -- Day of week (0=Sunday)
SELECT EXTRACT(DOY FROM NOW());  -- Day of year

-- Date truncation
SELECT DATE_TRUNC('year', NOW());
SELECT DATE_TRUNC('month', NOW());
SELECT DATE_TRUNC('day', NOW());
SELECT DATE_TRUNC('hour', NOW());

-- Date formatting
SELECT TO_CHAR(NOW(), 'YYYY-MM-DD');
SELECT TO_CHAR(NOW(), 'Month DD, YYYY');
SELECT TO_CHAR(NOW(), 'HH24:MI:SS');
SELECT TO_CHAR(NOW(), 'Day, Month DD, YYYY at HH12:MI AM');

-- Date parsing
SELECT TO_DATE('2024-01-01', 'YYYY-MM-DD');
SELECT TO_TIMESTAMP('2024-01-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS');

-- Date comparison
SELECT * FROM orders 
WHERE created_at >= DATE_TRUNC('month', NOW());

-- Date ranges
SELECT * FROM orders 
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';
```

---

## B.3.4 Aggregate Functions

```sql
-- Basic aggregates
SELECT 
    COUNT(*) AS total_count,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_order,
    MIN(total) AS min_order,
    MAX(total) AS max_order
FROM orders;

-- Statistical aggregates
SELECT 
    STDDEV(total) AS stddev,
    VARIANCE(total) AS variance,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) AS median,
    MODE() WITHIN GROUP (ORDER BY total) AS mode
FROM orders;

-- Array aggregates
SELECT 
    ARRAY_AGG(name) AS product_names,
    STRING_AGG(name, ', ') AS product_list
FROM products;

-- Other aggregates
SELECT 
    BOOL_AND(is_active) AS all_active,
    BOOL_OR(is_active) AS any_active,
    EVERY(is_active) AS every_active
FROM products;

-- Custom aggregate functions
CREATE AGGREGATE my_avg (NUMERIC) (
    STYPE = NUMERIC,
    SFUNC = numeric_avg_accum,
    FINALFUNC = numeric_avg
);
```

---

## B.3.5 Window Functions

```sql
-- Ranking
SELECT 
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price) AS row_num,
    RANK() OVER (ORDER BY price) AS rank,
    DENSE_RANK() OVER (ORDER BY price) AS dense_rank,
    NTILE(4) OVER (ORDER BY price) AS quartile
FROM products;

-- Percentiles
SELECT 
    name,
    price,
    CUME_DIST() OVER (ORDER BY price) AS cumulative_dist,
    PERCENT_RANK() OVER (ORDER BY price) AS percent_rank
FROM products;

-- Lead/Lag
SELECT 
    created_at,
    total,
    LAG(total, 1) OVER (ORDER BY created_at) AS previous_order,
    LEAD(total, 1) OVER (ORDER BY created_at) AS next_order,
    total - LAG(total) OVER (ORDER BY created_at) AS difference
FROM orders;

-- First/Last
SELECT 
    user_id,
    created_at,
    total,
    FIRST_VALUE(total) OVER (PARTITION BY user_id ORDER BY created_at) AS first_order,
    LAST_VALUE(total) OVER (PARTITION BY user_id ORDER BY created_at 
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order
FROM orders;

-- Running totals
SELECT 
    created_at,
    total,
    SUM(total) OVER (ORDER BY created_at) AS running_total,
    AVG(total) OVER (ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM orders;

-- Partitioned windows
SELECT 
    user_id,
    created_at,
    total,
    RANK() OVER (PARTITION BY user_id ORDER BY total DESC) AS user_rank
FROM orders;
```

---

## B.4 JSONB Functions Reference

### Target
Complete reference of JSONB operators and functions.

### Concept
JSONB functions allow you to work with JSON data seamlessly within PostgreSQL. This reference covers all JSONB operations used in the series.

---

## B.4.1 JSONB Operators

```sql
-- Create test JSON
WITH test AS (
    SELECT '{"name": "John", "age": 30, "address": {"city": "NYC"}, "tags": ["tag1", "tag2"]}'::jsonb AS data
)
-- -> (Get JSON object field)
SELECT data->'name' FROM test;           -- "John"
SELECT data->'address' FROM test;        -- {"city": "NYC"}

-- ->> (Get text field)
SELECT data->>'name' FROM test;          -- John
SELECT data->>'age' FROM test;           -- 30

-- #> (Get nested JSON object)
SELECT data#>'{address,city}' FROM test; -- "NYC"

-- #>> (Get nested text)
SELECT data#>>'{address,city}' FROM test; -- NYC

-- ? (Check if key exists)
SELECT data ? 'age' FROM test;           -- true

-- ?| (Check if any keys exist)
SELECT data ?| ARRAY['age', 'phone'] FROM test;  -- true

-- ?& (Check if all keys exist)
SELECT data ?& ARRAY['name', 'age'] FROM test;   -- true

-- @> (Contains left JSON)
SELECT data @> '{"name": "John"}'::jsonb FROM test;  -- true

-- <@ (Is contained in left JSON)
SELECT '{"name": "John"}'::jsonb <@ data FROM test;  -- true

-- || (Concatenate)
SELECT data || '{"email": "john@example.com"}'::jsonb FROM test;

-- - (Delete key)
SELECT data - 'age' FROM test;

-- - (Delete array element)
SELECT '["a", "b"]'::jsonb - 1;          -- ["a"]

-- #- (Delete nested)
SELECT data #- '{address,city}' FROM test;
```

---

## B.4.2 JSONB Functions

```sql
-- Creating JSON
SELECT TO_JSONB('Hello'::TEXT);
SELECT JSONB_BUILD_OBJECT('name', 'John', 'age', 30);
SELECT JSONB_BUILD_ARRAY('a', 'b', 'c');
SELECT JSONB_OBJECT('{a,1,b,2,c,3}');

-- Querying JSON
SELECT 
    JSONB_TYPEOF('{"a": "b"}'::jsonb),    -- object
    JSONB_TYPEOF('["a", "b"]'::jsonb),    -- array
    JSONB_TYPEOF('"text"'::jsonb),        -- string
    JSONB_TYPEOF('true'::jsonb),          -- boolean
    JSONB_TYPEOF('123'::jsonb);           -- number

-- Array operations
SELECT JSONB_ARRAY_LENGTH('[1,2,3]'::jsonb);
SELECT JSONB_ARRAY_ELEMENTS('[1,2,3]'::jsonb);
SELECT JSONB_ARRAY_ELEMENTS_TEXT('["a","b","c"]'::jsonb);

-- Set operations
SELECT JSONB_SET('{"a": 1}'::jsonb, '{b}', '2');
SELECT JSONB_INSERT('{"a": 1}'::jsonb, '{b}', '2', false);
SELECT JSONB_PRETTY('{"a": 1, "b": 2}'::jsonb);

-- Other operations
SELECT JSONB_AGG(name) FROM products;
SELECT JSONB_OBJECT_AGG(id, name) FROM products;

-- Validate JSON
SELECT JSONB_VALID('{"valid": "json"}');
SELECT JSONB_VALID('invalid json');
```

---

## B.5 Common Patterns and Recipes

### Target
Provide reusable SQL patterns for common tasks.

### Concept
Some problems appear repeatedly. This section provides battle-tested patterns for common scenarios.

---

## B.5.1 Pagination

```sql
-- Method 1: LIMIT/OFFSET (simple but inefficient for large offsets)
SELECT * FROM products 
ORDER BY id 
LIMIT 20 OFFSET 100;

-- Method 2: Keyset pagination (better for large datasets)
SELECT * FROM products 
WHERE id > 100 
ORDER BY id 
LIMIT 20;

-- Method 3: Window function pagination
WITH numbered AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY id) AS rn
    FROM products
)
SELECT * FROM numbered 
WHERE rn BETWEEN 101 AND 120;

-- Method 4: Search-based pagination
SELECT * FROM products 
WHERE name ILIKE '%search%' 
  AND id > 100 
ORDER BY id 
LIMIT 20;
```

---

## B.5.2 UPSERT (Insert or Update)

```sql
-- Method 1: ON CONFLICT (PostgreSQL 9.5+)
INSERT INTO products (slug, name, price) 
VALUES ('product-123', 'New Name', 29.99)
ON CONFLICT (slug) 
DO UPDATE SET 
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    updated_at = NOW()
RETURNING *;

-- Method 2: DO NOTHING on conflict
INSERT INTO products (slug, name, price) 
VALUES ('product-123', 'New Name', 29.99)
ON CONFLICT (slug) 
DO NOTHING;

-- Method 3: Transaction-based (older PostgreSQL)
BEGIN;
UPDATE products SET name = 'New Name', price = 29.99 WHERE slug = 'product-123';
INSERT INTO products (slug, name, price) 
SELECT 'product-123', 'New Name', 29.99 
WHERE NOT EXISTS (SELECT 1 FROM products WHERE slug = 'product-123');
COMMIT;
```

---

## B.5.3 Soft Delete Pattern

```sql
-- Table with soft delete
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,
    -- other columns
);

-- View for active users
CREATE VIEW active_users AS
SELECT * FROM users WHERE is_deleted = FALSE;

-- Soft delete function
CREATE OR REPLACE FUNCTION soft_delete_user(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users 
    SET is_deleted = TRUE, deleted_at = NOW() 
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Soft delete trigger to prevent hard deletes
CREATE OR REPLACE FUNCTION prevent_hard_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        UPDATE users SET is_deleted = TRUE, deleted_at = NOW() WHERE id = OLD.id;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_soft_delete_trigger
INSTEAD OF DELETE ON users
FOR EACH ROW EXECUTE FUNCTION prevent_hard_delete();
```

---

## B.5.4 Audit Logging Pattern

```sql
-- Create audit table
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    operation VARCHAR(10),
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    changed_by VARCHAR(255),
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (
        table_name,
        operation,
        record_id,
        old_data,
        new_data,
        changed_by
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(NEW.id, OLD.id),
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
        CURRENT_USER
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to tables
CREATE TRIGGER users_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

---

## B.5.5 Hierarchical Queries (Tree Structure)

```sql
-- Table with self-reference
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    parent_id INTEGER REFERENCES categories(id)
);

-- Recursive CTE for full tree
WITH RECURSIVE category_tree AS (
    -- Anchor: root categories
    SELECT id, name, parent_id, 0 AS level, ARRAY[id] AS path
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive: child categories
    SELECT c.id, c.name, c.parent_id, ct.level + 1, ct.path || c.id
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY path;

-- Get category hierarchy as JSON
WITH RECURSIVE category_tree AS (
    SELECT id, name, parent_id, 0 AS depth
    FROM categories WHERE parent_id IS NULL
    UNION ALL
    SELECT c.id, c.name, c.parent_id, ct.depth + 1
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT JSONB_AGG(jsonb_build_object(
    'id', id,
    'name', name,
    'depth', depth,
    'children', (
        SELECT JSONB_AGG(jsonb_build_object('id', c2.id, 'name', c2.name))
        FROM categories c2
        WHERE c2.parent_id = c.id
    )
)) FROM category_tree WHERE parent_id IS NULL;
```

---

## B.6 Performance Optimization Checklist

### Target
Provide a quick checklist for optimizing query performance.

### Concept
Performance optimization is systematic. Use this checklist when you encounter slow queries.

---

## B.6.1 Quick Optimization Checklist

### 1. Check Query Execution Plan

```sql
-- Run EXPLAIN ANALYZE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) 
SELECT * FROM orders WHERE user_id = 'some-uuid';

-- Look for:
-- - Sequential scans on large tables
-- - High cost values
-- - Large row estimates
-- - Nested loops on large datasets
-- - Hash joins on very small datasets
```

### 2. Review Index Usage

```sql
-- Check if indexes are used
SELECT 
    tablename, indexname, idx_scan, idx_tup_read
FROM pg_stat_user_indexes 
WHERE idx_scan = 0;

-- Check missing indexes
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    seq_scan / NULLIF(seq_tup_read, 0) AS scan_efficiency
FROM pg_stat_user_tables 
WHERE seq_scan > 100 
ORDER BY seq_scan DESC;
```

### 3. Optimize WHERE Clauses

```sql
-- Avoid functions in WHERE
-- Bad
SELECT * FROM orders WHERE DATE(created_at) = '2024-01-01';

-- Good
SELECT * FROM orders 
WHERE created_at >= '2024-01-01' 
  AND created_at < '2024-01-02';

-- Use indexed columns on left side
-- Bad
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- Good (with expression index)
SELECT * FROM users WHERE email = 'User@Example.com';
-- OR create index: CREATE INDEX idx_users_email_lower ON users(LOWER(email));
```

### 4. Optimize JOINs

```sql
-- Ensure foreign key columns are indexed
SELECT 
    conname, conrelid::regclass AS table_name
FROM pg_constraint 
WHERE contype = 'f' 
  AND conrelid NOT IN (
      SELECT indrelid FROM pg_index WHERE indisprimary = false
  );

-- Use INNER JOIN when possible
-- Avoid LEFT JOIN if not needed
-- Keep join order optimal (smallest first)
```

### 5. Optimize Aggregations

```sql
-- Filter before grouping
-- Bad
SELECT user_id, COUNT(*), AVG(total)
FROM orders
GROUP BY user_id
HAVING user_id IN (SELECT id FROM users WHERE is_active = true);

-- Good
SELECT o.user_id, COUNT(*), AVG(o.total)
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE u.is_active = true
GROUP BY o.user_id;

-- Use covering indexes for aggregations
CREATE INDEX idx_orders_user_total ON orders(user_id) INCLUDE (total);
```

### 6. Optimize LIMIT/ORDER BY

```sql
-- Ensure ORDER BY columns are indexed
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

-- Use keyset pagination for large offsets
-- Bad
SELECT * FROM orders ORDER BY id LIMIT 20 OFFSET 10000;

-- Good
SELECT * FROM orders 
WHERE id > 10000 
ORDER BY id 
LIMIT 20;
```

### 7. Optimize Subqueries

```sql
-- Use EXISTS instead of IN for large datasets
-- Bad
SELECT * FROM users WHERE id IN (SELECT user_id FROM orders);

-- Good
SELECT * FROM users u 
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

-- Use CTEs for multiple subqueries
WITH order_stats AS (
    SELECT user_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY user_id
)
SELECT u.*, os.order_count
FROM users u
JOIN order_stats os ON os.user_id = u.id;
```

### 8. Monitor and Maintain

```sql
-- Update statistics
ANALYZE;

-- Vacuum frequently updated tables
VACUUM ANALYZE orders;

-- Check table bloat
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    ROUND(100 * (pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) / pg_total_relation_size(schemaname||'.'||tablename)::numeric, 2) AS bloat_pct
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY bloat_pct DESC;
```

---

## B.7 Summary

You now have a comprehensive SQL reference covering:

✅ All PostgreSQL data types with usage examples  
✅ Complete SQL statement syntax (DDL, DML, DCL)  
✅ All built-in functions (string, numeric, date/time, aggregate, window)  
✅ JSONB operators and functions reference  
✅ Common patterns and recipes (pagination, upsert, soft delete, audit)  
✅ Performance optimization checklist  

This reference guide will save you time and help you write better SQL as you continue building your applications.
