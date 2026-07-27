# HANDS-ON POSTGRESQL: FROM ZERO TO SCHEMA HERO
## QUIZ & TEST BANK

### Comprehensive Assessment with Answer Keys

---

# PART 1: FIRST STEPS & THE SQL FOUNDATION

## Quiz 1.1: Basic Concepts (10 Questions)

### Multiple Choice

**1. What does SQL stand for?**
- A) Structured Query Language
- B) Standard Query Language
- C) Sequential Query Language
- D) Simple Query Language

**Answer: A**

---

**2. Which SQL command is used to retrieve data from a database?**
- A) INSERT
- B) UPDATE
- C) SELECT
- D) DELETE

**Answer: C**

---

**3. What does CRUD stand for?**
- A) Create, Read, Update, Delete
- B) Create, Retrieve, Update, Destroy
- C) Copy, Read, Update, Delete
- D) Create, Read, Upload, Delete

**Answer: A**

---

**4. Which operator is used for pattern matching in SQL?**
- A) =
- B) LIKE
- C) IN
- D) BETWEEN

**Answer: B**

---

**5. What is the default sort order in ORDER BY?**
- A) Descending
- B) Ascending
- C) Random
- D) No default

**Answer: B**

---

**6. Which clause is used to filter rows before grouping?**
- A) HAVING
- B) WHERE
- C) GROUP BY
- D) FILTER

**Answer: B**

---

**7. What happens if you run DELETE without a WHERE clause?**
- A) Deletes the first row
- B) Deletes all rows
- C) Returns an error
- D) Does nothing

**Answer: B**

---

**8. Which wildcard matches any sequence of characters in LIKE?**
- A) *
- B) ?
- C) %
- D) _

**Answer: C**

---

**9. Which command shows all tables in the current database?**
- A) SHOW TABLES
- B) LIST TABLES
- C) \dt
- D) \l

**Answer: C**

---

**10. What is the purpose of LIMIT in a SELECT statement?**
- A) Limit the number of columns
- B) Limit the number of rows returned
- C) Limit the table size
- D) Limit the database size

**Answer: B**

---

## Quiz 1.2: SQL Syntax (10 Questions)

### Fill in the Blanks

**1. The command to connect to a database in psql is: ________**

**Answer:** `\c database_name`

---

**2. To filter results, you use the ________ clause.**

**Answer:** WHERE

---

**3. The wildcard that matches a single character in LIKE is: ________**

**Answer:** `_` (underscore)

---

**4. INSERT INTO table (column1, column2) ________ (value1, value2);**

**Answer:** VALUES

---

**5. To sort results, you use the ________ clause.**

**Answer:** ORDER BY

---

**6. The command to describe a table in psql is: ________**

**Answer:** `\d table_name`

---

**7. UPDATE table SET column = value ________ condition;**

**Answer:** WHERE

---

**8. SELECT * FROM table ________ 10;**

**Answer:** LIMIT

---

**9. To check if a value is NULL, use: ________**

**Answer:** IS NULL

---

**10. The command to exit psql is: ________**

**Answer:** `\q`

---

### True or False

**1. DELETE without a WHERE clause is safe because it only deletes one row.**

**Answer:** False (It deletes ALL rows)

---

**2. LIKE is case-sensitive in PostgreSQL by default.**

**Answer:** True

---

**3. UPDATE can modify multiple columns in a single statement.**

**Answer:** True

---

**4. ORDER BY can sort by multiple columns.**

**Answer:** True

---

**5. LIMIT and OFFSET are used for pagination.**

**Answer:** True

---

## Quiz 1.3: Writing Queries (5 Questions)

### Write the SQL Query

**1. Write a query to select all columns from a table called "products".**

**Answer:**
```sql
SELECT * FROM products;
```

---

**2. Write a query to select only the name and price from products where price is greater than 50.**

**Answer:**
```sql
SELECT name, price FROM products WHERE price > 50;
```

---

**3. Write a query to find all products with "wireless" anywhere in the name.**

**Answer:**
```sql
SELECT * FROM products WHERE name ILIKE '%wireless%';
```

---

**4. Write a query to update the price of product with id 1 to 99.99.**

**Answer:**
```sql
UPDATE products SET price = 99.99 WHERE id = 1;
```

---

**5. Write a query to delete all products with zero stock.**

**Answer:**
```sql
DELETE FROM products WHERE stock = 0;
```

---

---

# PART 2: DATA TYPES & CONSTRAINTS

## Quiz 2.1: Data Types (10 Questions)

### Multiple Choice

**1. Which data type is best for storing prices?**
- A) INTEGER
- B) NUMERIC(10,2)
- C) REAL
- D) TEXT

**Answer: B**

---

**2. Which data type stores true/false values?**
- A) TEXT
- B) INTEGER
- C) BOOLEAN
- D) VARCHAR

**Answer: C**

---

**3. What is the maximum length of a VARCHAR(255) column?**
- A) 255 characters
- B) 255 bytes
- C) Unlimited
- D) 255 words

**Answer: A**

---

**4. Which data type is best for storing flexible, semi-structured data?**
- A) TEXT
- B) JSONB
- C) ARRAY
- D) HSTORE

**Answer: B**

---

**5. What does UUID stand for?**
- A) Unique User ID
- B) Universally Unique Identifier
- C) Unified Unique ID
- D) Universal User ID

**Answer: B**

---

**6. Which data type automatically generates unique values?**
- A) INTEGER
- B) SERIAL
- C) NUMERIC
- D) TEXT

**Answer: B**

---

**7. Which data type includes timezone information?**
- A) TIMESTAMP
- B) TIMESTAMPTZ
- C) DATE
- D) TIME

**Answer: B**

---

**8. Which constraint prevents NULL values?**
- A) UNIQUE
- B) NOT NULL
- C) CHECK
- D) DEFAULT

**Answer: B**

---

**9. Which constraint ensures a column has unique values?**
- A) NOT NULL
- B) CHECK
- C) UNIQUE
- D) DEFAULT

**Answer: C**

---

**10. How do you enable UUID generation in PostgreSQL?**
- A) CREATE EXTENSION uuid-ossp
- B) ENABLE UUID
- C) CREATE UUID
- D) INSTALL UUID

**Answer: A**

---

## Quiz 2.2: Constraints (10 Questions)

### Fill in the Blanks

**1. The constraint that validates data against a condition is: ________**

**Answer:** CHECK

---

**2. A ________ key uniquely identifies each row in a table.**

**Answer:** PRIMARY

---

**3. A ________ key references a primary key in another table.**

**Answer:** FOREIGN

---

**4. The ________ constraint provides a default value when none is specified.**

**Answer:** DEFAULT

---

**5. To prevent duplicate emails, use the ________ constraint.**

**Answer:** UNIQUE

---

**6. The syntax for CHECK constraint is: CHECK (________)**

**Answer:** condition

---

**7. A PRIMARY KEY cannot be ________.**

**Answer:** NULL

---

**8. A FOREIGN KEY can be ________ (allowed).**

**Answer:** NULL

---

**9. The constraint that prevents negative prices is: CHECK (price ________ 0)**

**Answer:** >=

---

**10. Multiple columns can be combined in a ________ primary key.**

**Answer:** composite

---

## Quiz 2.3: JSONB Operations (5 Questions)

### Write the Queries

**1. Write a query to get all products where the brand (in metadata JSONB) is 'AudioTech'.**

**Answer:**
```sql
SELECT * FROM products WHERE metadata->>'brand' = 'AudioTech';
```

---

**2. Write a query to find products with eco_friendly set to true in metadata.**

**Answer:**
```sql
SELECT * FROM products WHERE metadata @> '{"eco_friendly": true}'::jsonb;
```

---

**3. Write a query to add a 'warranty_months' field to a product's metadata.**

**Answer:**
```sql
UPDATE products 
SET metadata = metadata || '{"warranty_months": 24}'::jsonb
WHERE id = 1;
```

---

**4. Write a query to get the brand and warranty_months from metadata.**

**Answer:**
```sql
SELECT 
    metadata->>'brand' AS brand,
    metadata->>'warranty_months' AS warranty
FROM products;
```

---

**5. Write a query to find products that have a 'brand' key in metadata.**

**Answer:**
```sql
SELECT * FROM products WHERE metadata ? 'brand';
```

---

---

# PART 3: RELATIONSHIPS & RELATIONAL QUERIES

## Quiz 3.1: Relationships (10 Questions)

### Multiple Choice

**1. Which relationship type is used for Customer → Orders?**
- A) One-to-One
- B) One-to-Many
- C) Many-to-Many
- D) Zero-to-Many

**Answer: B**

---

**2. Which relationship type requires a junction table?**
- A) One-to-One
- B) One-to-Many
- C) Many-to-Many
- D) Zero-to-One

**Answer: C**

---

**3. A foreign key is placed on which side of a One-to-Many relationship?**
- A) The one side
- B) The many side
- C) Both sides
- D) Neither side

**Answer: B**

---

**4. ON DELETE CASCADE means:**
- A) Delete the parent, keep the children
- B) Delete the parent, delete the children
- C) Delete the children, keep the parent
- D) Don't allow deletion

**Answer: B**

---

**5. A junction table contains:**
- A) Foreign keys to both related tables
- B) Only one foreign key
- C) No foreign keys
- D) Primary keys only

**Answer: A**

---

**6. Which JOIN returns only matching rows?**
- A) LEFT JOIN
- B) RIGHT JOIN
- C) INNER JOIN
- D) FULL JOIN

**Answer: C**

---

**7. Which JOIN returns all rows from the left table?**
- A) LEFT JOIN
- B) RIGHT JOIN
- C) INNER JOIN
- D) FULL JOIN

**Answer: A**

---

**8. A self-join is used to:**
- A) Join a table to itself
- B) Join two different tables
- C) Join a table to a view
- D) Join columns within a table

**Answer: A**

---

**9. What is a composite primary key?**
- A) A primary key with multiple columns
- B) A primary key with one column
- C) A primary key with JSON data
- D) A primary key with no columns

**Answer: A**

---

**10. Which constraint maintains referential integrity?**
- A) CHECK
- B) FOREIGN KEY
- C) UNIQUE
- D) DEFAULT

**Answer: B**

---

## Quiz 3.2: JOINs (10 Questions)

### Fill in the Blanks

**1. ________ JOIN returns only rows that match in both tables.**

**Answer:** INNER

---

**2. ________ JOIN returns all rows from the left table, even if no match exists.**

**Answer:** LEFT

---

**3. ________ JOIN returns all rows from the right table, even if no match exists.**

**Answer:** RIGHT

---

**4. ________ JOIN returns all rows from both tables.**

**Answer:** FULL

---

**5. The syntax for joining tables is: SELECT * FROM table1 ________ table2 ON condition;**

**Answer:** JOIN

---

**6. A ________ is a table that connects two other tables in a Many-to-Many relationship.**

**Answer:** junction

---

**7. The ON clause specifies the ________ condition.**

**Answer:** join

---

**8. A foreign key constraint with ________ deletes child records when parent is deleted.**

**Answer:** CASCADE

---

**9. A foreign key constraint with ________ prevents parent deletion if children exist.**

**Answer:** RESTRICT

---

**10. A foreign key constraint with ________ sets the foreign key to NULL when parent is deleted.**

**Answer:** SET NULL

---

## Quiz 3.3: Writing Joins (5 Questions)

### Write the SQL Query

**1. Write a query to get all orders with the customer email (only orders that have a customer).**

**Answer:**
```sql
SELECT o.id, o.total, u.email
FROM orders o
JOIN users u ON u.id = o.user_id;
```

---

**2. Write a query to get all customers and their orders (including customers with no orders).**

**Answer:**
```sql
SELECT u.email, o.id, o.total
FROM users u
LEFT JOIN orders o ON o.user_id = u.id;
```

---

**3. Write a query to get all products with their categories (using product_categories junction).**

**Answer:**
```sql
SELECT p.name, c.name AS category
FROM products p
JOIN product_categories pc ON pc.product_id = p.id
JOIN categories c ON c.id = pc.category_id;
```

---

**4. Write a query to get all categories with their parent category (self-join).**

**Answer:**
```sql
SELECT c1.name AS category, c2.name AS parent
FROM categories c1
LEFT JOIN categories c2 ON c2.id = c1.parent_id;
```

---

**5. Write a query to get order details with product names and quantities.**

**Answer:**
```sql
SELECT o.id, p.name, oi.quantity, oi.unit_price
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id;
```

---

---

# PART 4: AGGREGATIONS, GROUPING & SUBQUERIES

## Quiz 4.1: Aggregations (10 Questions)

### Multiple Choice

**1. Which function counts the number of rows?**
- A) SUM
- B) COUNT
- C) AVG
- D) MAX

**Answer: B**

---

**2. Which function adds up values in a column?**
- A) COUNT
- B) SUM
- C) AVG
- D) MIN

**Answer: B**

---

**3. Which function calculates the average?**
- A) SUM
- B) COUNT
- C) AVG
- D) MAX

**Answer: C**

---

**4. Which clause groups rows with the same values?**
- A) WHERE
- B) GROUP BY
- C) ORDER BY
- D) HAVING

**Answer: B**

---

**5. Which clause filters groups after aggregation?**
- A) WHERE
- B) GROUP BY
- C) ORDER BY
- D) HAVING

**Answer: D**

---

**6. The difference between WHERE and HAVING is:**
- A) WHERE filters rows, HAVING filters groups
- B) WHERE filters groups, HAVING filters rows
- C) They are the same
- D) WHERE is for SELECT, HAVING for DELETE

**Answer: A**

---

**7. Which function returns the smallest value?**
- A) MIN
- B) MAX
- C) SUM
- D) AVG

**Answer: A**

---

**8. Which function returns the largest value?**
- A) MIN
- B) MAX
- C) SUM
- D) AVG

**Answer: B**

---

**9. COUNT(DISTINCT column) returns:**
- A) Number of rows
- B) Number of unique values
- C) Number of null values
- D) Number of duplicates

**Answer: B**

---

**10. GROUP BY can be used with:**
- A) Only one column
- B) Multiple columns
- C) Only aggregations
- D) Only numeric columns

**Answer: B**

---

## Quiz 4.2: Subqueries (10 Questions)

### Fill in the Blanks

**1. A ________ returns a single value and can be used in SELECT or WHERE.**

**Answer:** scalar subquery

---

**2. A ________ subquery returns a single column of values for use with IN.**

**Answer:** column

---

**3. A ________ subquery is evaluated once for each row in the outer query.**

**Answer:** correlated

---

**4. The IN operator is used with a subquery that returns ________.**

**Answer:** a list of values

---

**5. EXISTS returns ________ if the subquery returns at least one row.**

**Answer:** true

---

**6. A subquery in the FROM clause is called a ________ table.**

**Answer:** derived

---

**7. The ________ clause is used with aggregate functions to filter groups.**

**Answer:** HAVING

---

**8. CASE WHEN implements ________ logic in SQL.**

**Answer:** conditional

---

**9. The ________ function can categorize data based on conditions.**

**Answer:** CASE

---

**10. A ________ query is a query within another query.**

**Answer:** subquery

---

## Quiz 4.3: Writing Aggregations (5 Questions)

### Write the SQL Query

**1. Write a query to count the number of orders by status.**

**Answer:**
```sql
SELECT status, COUNT(*) FROM orders GROUP BY status;
```

---

**2. Write a query to find the total revenue by month.**

**Answer:**
```sql
SELECT DATE_TRUNC('month', created_at) AS month, SUM(total)
FROM orders
GROUP BY month
ORDER BY month;
```

---

**3. Write a query to find customers with more than 5 orders.**

**Answer:**
```sql
SELECT user_id, COUNT(*)
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 5;
```

---

**4. Write a query to find products priced above average.**

**Answer:**
```sql
SELECT * FROM products WHERE price > (SELECT AVG(price) FROM products);
```

---

**5. Write a query to categorize products by price tier using CASE.**

**Answer:**
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

---

---

# PART 5: MODERN POSTGRES POWER TOOLS

## Quiz 5.1: JSONB (10 Questions)

### Multiple Choice

**1. Which operator returns JSON field as text?**
- A) ->
- B) ->>
- C) ?
- D) @>

**Answer: B**

---

**2. Which operator checks if a JSONB key exists?**
- A) ->
- B) ->>
- C) ?
- D) @>

**Answer: C**

---

**3. Which operator checks if one JSON contains another?**
- A) ->
- B) ->>
- C) ?
- D) @>

**Answer: D**

---

**4. Which operator returns JSON as a JSON object?**
- A) ->
- B) ->>
- C) ?
- D) @>

**Answer: A**

---

**5. JSONB stores data in what format?**
- A) Text
- B) Binary
- C) XML
- D) CSV

**Answer: B**

---

**6. What is the advantage of JSONB over JSON?**
- A) Faster queries, indexing support
- B) Smaller storage
- C) Easier to read
- D) More compatible

**Answer: A**

---

**7. Which function creates a JSON object from key-value pairs?**
- A) jsonb_build_object
- B) jsonb_create_object
- C) jsonb_make_object
- D) jsonb_new_object

**Answer: A**

---

**8. Which function creates a JSON array?**
- A) jsonb_build_array
- B) jsonb_create_array
- C) jsonb_make_array
- D) jsonb_new_array

**Answer: A**

---

**9. How do you add a new key-value pair to a JSONB column?**
- A) jsonb_set
- B) jsonb_add
- C) jsonb_insert
- D) jsonb_append

**Answer: A**

---

**10. Which index type is best for JSONB?**
- A) B-Tree
- B) GIN
- C) GiST
- D) BRIN

**Answer: B**

---

## Quiz 5.2: Window Functions (10 Questions)

### Fill in the Blanks

**1. ROW_NUMBER() assigns a unique ________ to each row.**

**Answer:** number

---

**2. RANK() assigns ranks with ________ on ties.**

**Answer:** gaps

---

**3. DENSE_RANK() assigns ranks without ________.**

**Answer:** gaps

---

**4. LAG(column, n) returns the value from ________ rows before.**

**Answer:** n

---

**5. LEAD(column, n) returns the value from ________ rows after.**

**Answer:** n

---

**6. The ________ clause in a window function defines the partition.**

**Answer:** PARTITION BY

---

**7. The ________ clause in a window function defines the sorting.**

**Answer:** ORDER BY

---

**8. NTILE(n) divides the result set into ________ groups.**

**Answer:** n

---

**9. A window frame defines the ________ of rows relative to the current row.**

**Answer:** range

---

**10. Window functions do NOT ________ rows like GROUP BY does.**

**Answer:** collapse

---

## Quiz 5.3: Writing Window Functions (5 Questions)

### Write the SQL Query

**1. Write a query to rank products by price (highest first).**

**Answer:**
```sql
SELECT name, price, RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;
```

---

**2. Write a query to get the running total of orders by date.**

**Answer:**
```sql
SELECT created_at, total,
    SUM(total) OVER (ORDER BY created_at) AS running_total
FROM orders;
```

---

**3. Write a query to number orders for each customer (first order, second order, etc.).**

**Answer:**
```sql
SELECT user_id, id, created_at,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_number
FROM orders;
```

---

**4. Write a query to get the previous order total for each order.**

**Answer:**
```sql
SELECT id, total,
    LAG(total) OVER (ORDER BY created_at) AS previous_total
FROM orders;
```

---

**5. Write a query to calculate a 3-day moving average of order totals.**

**Answer:**
```sql
SELECT created_at, total,
    AVG(total) OVER (ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM orders;
```

---

---

# PART 6: PERFORMANCE, INDEXES & TRANSACTIONS

## Quiz 6.1: Performance & Indexes (10 Questions)

### Multiple Choice

**1. Which command shows how PostgreSQL executes a query?**
- A) SHOW PLAN
- B) DESCRIBE QUERY
- C) EXPLAIN
- D) ANALYZE

**Answer: C**

---

**2. Which scan type is fastest?**
- A) Seq Scan
- B) Index Scan
- C) Index Only Scan
- D) Bitmap Scan

**Answer: C**

---

**3. A B-Tree index is best for:**
- A) Equality and range queries
- B) Full-text search
- C) JSONB queries
- D) Pattern matching

**Answer: A**

---

**4. Which index type is best for JSONB?**
- A) B-Tree
- B) GIN
- C) GiST
- D) BRIN

**Answer: B**

---

**5. A partial index indexes:**
- A) All rows
- B) A subset of rows
- C) Only numeric columns
- D) Only text columns

**Answer: B**

---

**6. A covering index:**
- A) Covers multiple tables
- B) Includes additional columns in the index
- C) Covers the entire table
- D) Covers all indexes

**Answer: B**

---

**7. Index-only scans are possible when:**
- A) All needed data is in the index
- B) The table is small
- C) The index is unique
- D) The query uses LIKE

**Answer: A**

---

**8. Which factor indicates a need for more memory?**
- A) Low cache hit ratio
- B) High cache hit ratio
- C) Many indexes
- D) Large tables

**Answer: A**

---

**9. EXPLAIN ANALYZE should be used:**
- A) On production
- B) In development
- C) To debug performance
- D) All of the above

**Answer: C**

---

**10. A good cache hit ratio is:**
- A) < 50%
- B) 50-70%
- C) 70-90%
- D) > 95%

**Answer: D**

---

## Quiz 6.2: Transactions (10 Questions)

### Fill in the Blanks

**1. The command to start a transaction is: ________**

**Answer:** BEGIN

---

**2. The command to save changes is: ________**

**Answer:** COMMIT

---

**3. The command to discard changes is: ________**

**Answer:** ROLLBACK

---

**4. A ________ allows partial rollback within a transaction.**

**Answer:** SAVEPOINT

---

**5. ACID stands for Atomicity, ________, Isolation, Durability.**

**Answer:** Consistency

---

**6. The default isolation level is ________.**

**Answer:** READ COMMITTED

---

**7. ________ isolation level provides the strictest consistency.**

**Answer:** SERIALIZABLE

---

**8. SELECT ________ locks rows for writing.**

**Answer:** FOR UPDATE

---

**9. A ________ occurs when two transactions wait for each other.**

**Answer:** deadlock

---

**10. The ________ isolation level provides a consistent snapshot.**

**Answer:** REPEATABLE READ

---

## Quiz 6.3: Writing Transactions (5 Questions)

### Write the SQL Code

**1. Write a transaction that transfers 10 units of stock from product 1 to product 2.**

**Answer:**
```sql
BEGIN;
UPDATE products SET stock = stock - 10 WHERE id = 1;
UPDATE products SET stock = stock + 10 WHERE id = 2;
COMMIT;
```

---

**2. Write a transaction with a savepoint and rollback to the savepoint.**

**Answer:**
```sql
BEGIN;
UPDATE products SET stock = stock - 5 WHERE id = 1;
SAVEPOINT before_second;
UPDATE products SET stock = stock - 10 WHERE id = 2;
ROLLBACK TO SAVEPOINT before_second;
UPDATE products SET stock = stock - 3 WHERE id = 3;
COMMIT;
```

---

**3. Write a query that uses SELECT FOR UPDATE to lock a row.**

**Answer:**
```sql
BEGIN;
SELECT stock FROM products WHERE id = 1 FOR UPDATE;
UPDATE products SET stock = stock - 1 WHERE id = 1;
COMMIT;
```

---

**4. Write a transaction that creates an order and adds items, with rollback on error.**

**Answer:**
```sql
BEGIN;
INSERT INTO orders (user_id, total) VALUES (1, 0) RETURNING id;
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
VALUES (1, 1, 2, 19.99, 39.98);
UPDATE orders SET total = (SELECT SUM(total_price) FROM order_items WHERE order_id = 1)
WHERE id = 1;
COMMIT;
```

---

**5. Write a transaction that updates a user's email with verification.**

**Answer:**
```sql
BEGIN;
UPDATE users SET email = 'new@email.com', is_verified = false WHERE id = 1;
-- Send verification email (application code here)
-- Wait for verification
UPDATE users SET is_verified = true WHERE id = 1;
COMMIT;
```

---

---

# COMPREHENSIVE EXAMINATION

## Part A: Multiple Choice (25 Questions)

**1. Which SQL command retrieves data from a database?**
- A) INSERT
- B) UPDATE
- C) SELECT
- D) DELETE

**Answer: C**

---

**2. What does the LIKE operator do?**
- A) Checks equality
- B) Checks if a value is NULL
- C) Pattern matching
- D) Checks if a value is in a list

**Answer: C**

---

**3. Which data type is best for storing exact decimal values?**
- A) REAL
- B) DOUBLE
- C) NUMERIC
- D) INTEGER

**Answer: C**

---

**4. Which constraint prevents duplicate values?**
- A) NOT NULL
- B) CHECK
- C) UNIQUE
- D) DEFAULT

**Answer: C**

---

**5. A foreign key is used to:**
- A) Create a unique identifier
- B) Reference a primary key in another table
- C) Validate data
- D) Set a default value

**Answer: B**

---

**6. Which JOIN returns only matching rows?**
- A) LEFT JOIN
- B) INNER JOIN
- C) RIGHT JOIN
- D) FULL JOIN

**Answer: B**

---

**7. Which aggregate function counts rows?**
- A) SUM
- B) AVG
- C) COUNT
- D) MAX

**Answer: C**

---

**8. Which clause filters groups after aggregation?**
- A) WHERE
- B) GROUP BY
- C) HAVING
- D) ORDER BY

**Answer: C**

---

**9. Which JSONB operator returns a field as text?**
- A) ->
- B) ->>
- C) ?
- D) @>

**Answer: B**

---

**10. Which window function assigns a unique number to each row?**
- A) RANK()
- B) DENSE_RANK()
- C) ROW_NUMBER()
- D) NTILE()

**Answer: C**

---

**11. Which command shows query execution plan?**
- A) SHOW PLAN
- B) EXPLAIN
- C) ANALYZE
- D) DESCRIBE

**Answer: B**

---

**12. Which index type is best for JSONB?**
- A) B-Tree
- B) GIN
- C) GiST
- D) BRIN

**Answer: B**

---

**13. What does BEGIN do?**
- A) Starts a transaction
- B) Commits changes
- C) Rolls back changes
- D) Creates a savepoint

**Answer: A**

---

**14. Which isolation level is the strictest?**
- A) READ COMMITTED
- B) REPEATABLE READ
- C) SERIALIZABLE
- D) READ UNCOMMITTED

**Answer: C**

---

**15. What does ON DELETE CASCADE do?**
- A) Keeps child records
- B) Deletes child records
- C) Sets child records to NULL
- D) Prevents deletion

**Answer: B**

---

**16. Which function returns the largest value?**
- A) MIN
- B) MAX
- C) SUM
- D) AVG

**Answer: B**

---

**17. A subquery in the FROM clause is called a:**
- A) Scalar subquery
- B) Correlated subquery
- C) Derived table
- D) Column subquery

**Answer: C**

---

**18. Which pattern matches any sequence of characters in LIKE?**
- A) *
- B) ?
- C) %
- D) _

**Answer: C**

---

**19. Which constraint validates data against a condition?**
- A) NOT NULL
- B) UNIQUE
- C) CHECK
- D) DEFAULT

**Answer: C**

---

**20. Which window function returns previous row value?**
- A) LEAD()
- B) LAG()
- C) FIRST_VALUE()
- D) LAST_VALUE()

**Answer: B**

---

**21. A covering index includes:**
- A) Only the indexed column
- B) Additional columns in the index
- C) All table columns
- D) Foreign keys

**Answer: B**

---

**22. Which command discards transaction changes?**
- A) COMMIT
- B) SAVEPOINT
- C) ROLLBACK
- D) BEGIN

**Answer: C**

---

**23. GROUP BY is used with:**
- A) WHERE
- B) HAVING
- C) Both A and B
- D) Neither

**Answer: C**

---

**24. Which function checks if a JSONB key exists?**
- A) ->
- B) ->>
- C) ?
- D) @>

**Answer: C**

---

**25. What is a good cache hit ratio target?**
- A) > 50%
- B) > 70%
- C) > 90%
- D) > 95%

**Answer: D**

---

## Part B: Fill in the Blanks (15 Questions)

**1. The command to connect to a database in psql is: ________**

**Answer:** `\c`

---

**2. CRUD stands for: ________**

**Answer:** Create, Read, Update, Delete

---

**3. A ________ key uniquely identifies each row.**

**Answer:** PRIMARY

---

**4. A ________ key references a primary key in another table.**

**Answer:** FOREIGN

---

**5. A Many-to-Many relationship uses a ________ table.**

**Answer:** junction

---

**6. INNER JOIN returns only ________ rows.**

**Answer:** matching

---

**7. LEFT JOIN returns all rows from the ________ table.**

**Answer:** left

---

**8. HAVING filters groups, ________ filters rows.**

**Answer:** WHERE

---

**9. The -> operator returns JSON as a ________.**

**Answer:** JSON object

---

**10. RANK() assigns ranks with ________ on ties.**

**Answer:** gaps

---

**11. EXPLAIN ANALYZE shows the ________ of a query.**

**Answer:** execution plan

---

**12. A partial index indexes a ________ of rows.**

**Answer:** subset

---

**13. BEGIN starts a ________.**

**Answer:** transaction

---

**14. COMMIT saves changes, ROLLBACK ________ changes.**

**Answer:** discards

---

**15. ACID stands for: ________**

**Answer:** Atomicity, Consistency, Isolation, Durability

---

## Part C: Write SQL Queries (10 Questions)

**1. Write a query to create a table called "customers" with id, name, email (unique), and created_at (default now).**

**Answer:**
```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

**2. Write a query to insert three customers into the customers table.**

**Answer:**
```sql
INSERT INTO customers (name, email) VALUES
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Bob Wilson', 'bob@example.com');
```

---

**3. Write a query to select all customers sorted by name.**

**Answer:**
```sql
SELECT * FROM customers ORDER BY name;
```

---

**4. Write a query to update a customer's email.**

**Answer:**
```sql
UPDATE customers SET email = 'new@email.com' WHERE id = 1;
```

---

**5. Write a query to get all customers with their orders (using a join).**

**Answer:**
```sql
SELECT c.name, o.id, o.total
FROM customers c
JOIN orders o ON o.customer_id = c.id;
```

---

**6. Write a query to count orders by customer.**

**Answer:**
```sql
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id;
```

---

**7. Write a query to find customers with more than 3 orders.**

**Answer:**
```sql
SELECT customer_id, COUNT(*)
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 3;
```

---

**8. Write a query to rank products by price.**

**Answer:**
```sql
SELECT name, price, RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;
```

---

**9. Write a transaction that updates stock for two products.**

**Answer:**
```sql
BEGIN;
UPDATE products SET stock = stock - 5 WHERE id = 1;
UPDATE products SET stock = stock + 5 WHERE id = 2;
COMMIT;
```

---

**10. Write a query that creates an index on the orders table for customer_id.**

**Answer:**
```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

---

## Part D: True or False (10 Questions)

**1. DELETE without a WHERE clause deletes all rows in a table.**

**Answer:** True

---

**2. LIKE is case-insensitive by default in PostgreSQL.**

**Answer:** False (LIKE is case-sensitive, ILIKE is case-insensitive)

---

**3. A primary key can contain NULL values.**

**Answer:** False

---

**4. A foreign key can reference a column that is not a primary key.**

**Answer:** False (Foreign keys must reference a unique key, usually a primary key)

---

**5. INNER JOIN returns all rows from both tables.**

**Answer:** False (INNER JOIN returns only matching rows, FULL JOIN returns all rows)

---

**6. HAVING is used to filter rows before grouping.**

**Answer:** False (HAVING filters groups after grouping, WHERE filters rows)

---

**7. JSONB is stored in binary format.**

**Answer:** True

---

**8. Window functions collapse rows like GROUP BY.**

**Answer:** False (Window functions preserve individual rows)

---

**9. An index always improves query performance.**

**Answer:** False (Indexes have overhead and can slow down writes)

---

**10. Transactions ensure data integrity by allowing rollback on failure.**

**Answer:** True

---

---

# ANSWER KEYS SUMMARY

## Quick Reference Answer Key

### Part 1: First Steps
| Q | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1.1 | A | C | A | B | B | B | B | C | C | B |
| 1.2 | \c | WHERE | _ | VALUES | ORDER BY | \d | WHERE | LIMIT | IS NULL | \q |
| 1.3 | T | F | T | T | T | | | | | |

### Part 2: Data Types
| Q | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| 2.1 | B | C | A | B | B | B | B | B | C | A |
| 2.2 | CHECK | PRIMARY | FOREIGN | DEFAULT | UNIQUE | condition | NULL | NULL | >= | composite |

### Part 3: Relationships
| Q | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| 3.1 | B | C | B | B | A | C | A | A | A | B |
| 3.2 | INNER | LEFT | RIGHT | FULL | JOIN | junction | join | CASCADE | RESTRICT | SET NULL |

### Part 4: Aggregations
| Q | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| 4.1 | B | B | C | B | D | A | A | B | B | B |
| 4.2 | scalar | column | correlated | a list | true | derived | HAVING | conditional | CASE | subquery |

### Part 5: Modern Features
| Q | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| 5.1 | B | C | D | A | B | A | A | A | A | B |
| 5.2 | number | gaps | gaps | n | n | PARTITION | ORDER | n | range | collapse |

### Part 6: Performance
| Q | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| 6.1 | C | C | A | B | B | B | A | A | C | D |
| 6.2 | BEGIN | COMMIT | ROLLBACK | SAVEPOINT | Consistency | READ COMMITTED | SERIALIZABLE | FOR UPDATE | deadlock | REPEATABLE READ |

---

# EXAMINATION SCORING GUIDE

## Part A: Multiple Choice (25 questions, 2 points each = 50 points)

**Score:** ___ / 50

## Part B: Fill in the Blanks (15 questions, 2 points each = 30 points)

**Score:** ___ / 30

## Part C: Write SQL Queries (10 questions, 4 points each = 40 points)

**Scoring Rubric for Part C:**
- Correct syntax and logic: 4 points
- Minor syntax error: 3 points
- Logic correct but major syntax issue: 2 points
- Attempted but incorrect: 1 point
- No attempt: 0 points

**Score:** ___ / 40

## Part D: True or False (10 questions, 1 point each = 10 points)

**Score:** ___ / 10

## Total Score: ___ / 130

### Grade Scale
| Score | Grade |
|-------|-------|
| 117-130 | A (90-100%) |
| 104-116 | B (80-89%) |
| 91-103 | C (70-79%) |
| 78-90 | D (60-69%) |
| 0-77 | F (Below 60%) |
