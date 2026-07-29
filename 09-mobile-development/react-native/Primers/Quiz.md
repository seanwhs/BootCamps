# Serverless Postgres with Neon: From Zero to Production
## Quiz & Test Bank with Answer Keys

### Overview

This test bank contains over 200 questions across all course modules, including multiple choice, true/false, fill-in-the-blank, and practical coding exercises. Use these for self-assessment, instructor-led quizzes, or final examinations.

---

## TABLE OF CONTENTS

1. [Part 0: Introduction](#quiz-part0)
2. [Part 1: Setup & Cloud SQL Fundamentals](#quiz-part1)
3. [Part 2: Bulletproof Schemas & Data Integrity](#quiz-part2)
4. [Part 3: Database Branching & Relational Architecture](#quiz-part3)
5. [Part 4: Analytical Power](#quiz-part4)
6. [Part 5: JSONB & Extensions](#quiz-part5)
7. [Part 6: Performance, Transactions & CI/CD](#quiz-part6)
8. [Primers Assessment](#quiz-primers)
9. [Final Comprehensive Exam](#quiz-final)
10. [Answer Keys](#answer-keys)

---

## QUIZ 1: PART 0 - INTRODUCTION {#quiz-part0}

### Multiple Choice (5 Questions)

**1. What is Neon?**
- A) A traditional on-premise database
- B) A serverless PostgreSQL platform
- C) A NoSQL document database
- D) A frontend framework

**2. Which of the following is a key feature of Neon?**
- A) Manual backup management
- B) Instant database branching
- C) On-premise installation
- D) Fixed pricing tiers

**3. What does "scale-to-zero" mean in the context of Neon?**
- A) The database always has zero users
- B) The database automatically scales compute resources down to zero when not in use
- C) The database can never scale up
- D) The database has zero storage

**4. How long does it typically take to create a Neon database branch?**
- A) Hours
- B) Minutes
- C) Seconds
- D) Days

**5. What is the primary architecture component that separates compute from storage in Neon?**
- A) PostgreSQL engine
- B) Control plane
- C) S3-backed storage layer
- D) Connection pooler

### True/False (5 Questions)

**6.** Neon requires manual server maintenance and patching. (T/F)

**7.** The Neon free tier includes 10GB of storage. (T/F)

**8.** Database branching in Neon copies all data physically. (T/F)

**9.** Neon can be used with standard PostgreSQL tools like psql. (T/F)

**10.** Connection pooling is a built-in feature of Neon. (T/F)

### Fill in the Blank (5 Questions)

**11.** Neon's branching is often compared to __________ branching in Git.

**12.** The free tier of Neon includes __________ compute hours per month.

**13.** The __________ layer in Neon manages your database instances and handles autoscaling.

**14.** In Neon, you create a new database instance by creating a new __________.

**15.** The __________ account type is recommended for signing up to Neon as it enables easier integration later.

---

## QUIZ 2: PART 1 - SETUP & CLOUD SQL FUNDAMENTALS {#quiz-part1}

### Multiple Choice (10 Questions)

**16. What is the correct syntax to connect to a Neon database using psql?**
- A) `psql --host ep-xyz --port 5432 -U username database`
- B) `psql "postgresql://username:password@ep-xyz/database?sslmode=require"`
- C) `psql -h ep-xyz -d database -u username`
- D) `psql --url postgresql://username:password@ep-xyz/database`

**17. Which data type is best for storing monetary values?**
- A) REAL
- B) DOUBLE PRECISION
- C) NUMERIC(10,2)
- D) FLOAT

**18. What does the SERIAL data type do?**
- A) Creates a random UUID
- B) Creates an auto-incrementing integer
- C) Creates a fixed-length string
- D) Creates a JSON object

**19. Which SQL statement is used to retrieve data from a table?**
- A) INSERT
- B) UPDATE
- C) SELECT
- D) DELETE

**20. What will the following query return? `SELECT * FROM products WHERE price BETWEEN 50 AND 100`**
- A) Products with price equal to 50 or 100
- B) Products with price between 50 and 100 (inclusive)
- C) Products with price greater than 50 and less than 100
- D) Products with price less than 50 or greater than 100

**21. Which pattern will match names starting with 'W'?**
- A) `LIKE '%W'`
- B) `LIKE 'W%'`
- C) `LIKE '_W'`
- D) `LIKE 'W_'`

**22. What does `ILIKE` do that `LIKE` does not?**
- A) It's faster
- B) It's case-insensitive
- C) It works with numbers
- D) It supports regular expressions

**23. What is the purpose of `LIMIT` in a SELECT statement?**
- A) To update a limited number of rows
- B) To return a limited number of rows
- C) To delete a limited number of rows
- D) To count a limited number of rows

**24. Which command is used to describe the structure of a table in psql?**
- A) `\d table_name`
- B) `\dt table_name`
- C) `\l table_name`
- D) `\c table_name`

**25. What will `SELECT COUNT(*) FROM products` return?**
- A) The number of unique product names
- B) The total number of rows in the products table
- C) The sum of all product prices
- D) The average product price

### True/False (5 Questions)

**26.** `DELETE FROM products` without a WHERE clause deletes a specific product. (T/F)

**27.** `UPDATE products SET price = 0` updates all rows in the products table. (T/F)

**28.** The `TEXT` data type in PostgreSQL has a maximum length of 255 characters. (T/F)

**29.** `WHERE` clauses can be used with `INSERT` statements. (T/F)

**30.** `ORDER BY price DESC` sorts products from most expensive to cheapest. (T/F)

### Fill in the Blank (5 Questions)

**31.** The four basic database operations are known as __________.

**32.** To check if a value is NULL in SQL, you use the __________ operator.

**33.** The __________ clause is used to filter rows in a SELECT statement.

**34.** The __________ command is used to exit the psql environment.

**35.** A __________ is a file containing SQL statements that populate a database with sample data.

### Practical Coding (3 Questions)

**36. Write a SQL query to create a table called `customers` with the following columns:**
- id (auto-incrementing integer, primary key)
- name (text, not null)
- email (text, unique)
- created_at (timestamp with timezone, default to current timestamp)

```sql
-- Your answer:
```

**37. Write a SQL query to insert three sample customers into the customers table.**

```sql
-- Your answer:
```

**38. Write a SQL query to find all customers whose names start with 'J' and whose emails are not null.**

```sql
-- Your answer:
```

---

## QUIZ 3: PART 2 - BULLETPROOF SCHEMAS & DATA INTEGRITY {#quiz-part2}

### Multiple Choice (10 Questions)

**39. Which of the following is NOT a valid PostgreSQL constraint?**
- A) NOT NULL
- B) UNIQUE
- C) REQUIRED
- D) CHECK

**40. What does the following constraint do? `CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')`**
- A) Ensures email is not null
- B) Ensures email is unique
- C) Validates email format using a regular expression
- D) Checks if email is a valid domain

**41. What is a UUID?**
- A) A 32-bit integer
- B) A 128-bit universally unique identifier
- C) A text string of any length
- D) A binary large object

**42. Which function generates a random UUID in PostgreSQL?**
- A) `random_uuid()`
- B) `generate_uuid()`
- C) `uuid_generate_v4()`
- D) `create_uuid()`

**43. What is the difference between `ON DELETE CASCADE` and `ON DELETE RESTRICT`?**
- A) CASCADE prevents deletion, RESTRICT allows it
- B) CASCADE allows deletion, RESTRICT prevents it
- C) They are the same
- D) CASCADE deletes the parent, RESTRICT deletes the child

**44. What is a soft delete?**
- A) Deleting data permanently
- B) Marking data as deleted without physically removing it
- C) Deleting data with a confirmation prompt
- D) Deleting data in a transaction

**45. Which connection type is recommended for serverless functions?**
- A) Direct connection
- B) Pooled connection with session mode
- C) Pooled connection with transaction mode
- D) Any connection is fine

**46. What is the purpose of the `updated_at` column pattern?**
- A) To track when a record was created
- B) To track when a record was last modified
- C) To track when a record was deleted
- D) To track who modified a record

**47. Which of the following is true about CHECK constraints?**
- A) They can only be applied to integer columns
- B) They can enforce custom business rules
- C) They automatically create indexes
- D) They are optional and don't affect data integrity

**48. What does the `DEFAULT` constraint do?**
- A) Prevents null values
- B) Provides a fallback value if none is specified
- C) Ensures values are unique
- D) References another table

### True/False (5 Questions)

**49.** UUID primary keys are always faster than SERIAL primary keys. (T/F)

**50.** A table can have multiple primary keys. (T/F)

**51.** `TIMESTAMPTZ` stores timezone information. (T/F)

**52.** Connection pooling in Neon can reduce connection overhead for serverless applications. (T/F)

**53.** CHECK constraints can be used to validate email formats. (T/F)

### Fill in the Blank (5 Questions)

**54.** To enable UUID generation in PostgreSQL, you must first create the __________ extension.

**55.** The __________ pattern of primary key generation uses auto-incrementing integers.

**56.** A __________ is a stored procedure that automatically executes in response to certain events on a table.

**57.** The __________ function is used to hash passwords in PostgreSQL.

**58.** __________ connections are recommended for serverless environments because they reuse connections between requests.

### Practical Coding (3 Questions)

**59. Write a SQL statement to create a users table with:**
- UUID primary key
- Email with validation
- Username with validation (must start with letter, contain only letters, numbers, underscores)
- Status with valid values ('active', 'inactive', 'suspended')

```sql
-- Your answer:
```

**60. Write a trigger function that automatically updates the `updated_at` column when a row is modified.**

```sql
-- Your answer:
```

**61. Write a query to soft delete a user with a specific email address.**

```sql
-- Your answer:
```

---

## QUIZ 4: PART 3 - DATABASE BRANCHING & RELATIONAL ARCHITECTURE {#quiz-part3}

### Multiple Choice (10 Questions)

**62. What is the command to create a new branch in Neon using the CLI?**
- A) `neonctl branch create`
- B) `neonctl branches create`
- C) `neonctl new-branch`
- D) `neonctl create branch`

**63. Which of the following is a valid relationship type in database design?**
- A) One-to-One (1:1)
- B) One-to-Many (1:M)
- C) Many-to-Many (M:N)
- D) All of the above

**64. What is a junction table used for?**
- A) Connecting two tables in a Many-to-Many relationship
- B) Storing user passwords
- C) Creating indexes
- D) Storing JSON data

**65. Which JOIN returns only rows where there is a match in both tables?**
- A) LEFT JOIN
- B) RIGHT JOIN
- C) INNER JOIN
- D) FULL JOIN

**66. Which JOIN returns all rows from the left table, even if there's no match in the right table?**
- A) INNER JOIN
- B) LEFT JOIN
- C) RIGHT JOIN
- D) FULL JOIN

**67. What is a foreign key?**
- A) A key that is unique across all tables
- B) A column that references a primary key in another table
- C) A key that is never indexed
- D) A key that automatically increments

**68. What does `ON DELETE CASCADE` do?**
- A) Deletes the parent record only
- B) Deletes child records when parent is deleted
- C) Prevents deletion if children exist
- D) Sets foreign key to NULL on deletion

**69. Which of the following is NOT a valid foreign key ON DELETE option?**
- A) CASCADE
- B) RESTRICT
- C) SET NULL
- D) IGNORE

**70. In the context of Neon, what is a branch?**
- A) A copy of the database schema only
- B) An instant copy of the entire database
- C) A backup that takes hours to create
- D) A read-only replica

**71. What is the purpose of denormalizing order items (storing product name and price)?**
- A) To reduce storage space
- B) To preserve product information even if the product changes
- C) To make queries slower
- D) To break normalization rules

### True/False (5 Questions)

**72.** LEFT JOIN and LEFT OUTER JOIN are the same. (T/F)

**73.** A self-join joins a table to itself. (T/F)

**74.** Neon branches share the same underlying storage until changes are made. (T/F)

**75.** Foreign keys are automatically indexed in PostgreSQL. (T/F)

**76.** ON DELETE CASCADE should be used for all foreign keys. (T/F)

### Fill in the Blank (5 Questions)

**77.** A __________ is a column that establishes a link between two tables.

**78.** The __________ JOIN returns all rows from both tables, matching where possible.

**79.** A __________ is a table that resolves a Many-to-Many relationship.

**80.** When a user is deleted and their orders should also be deleted, you would use __________ constraint.

**81.** Neon branches can be merged to the __________ branch to deploy changes.

### Practical Coding (3 Questions)

**82. Write a SQL query to create a junction table for a Many-to-Many relationship between products and orders.**

```sql
-- Your answer:
```

**83. Write a SQL query to get all orders with customer names and shipping addresses.**

```sql
-- Your answer:
```

**84. Write the Neon CLI commands to: create a development branch, get its connection string, and merge it to main.**

```bash
# Your answer:
```

---

## QUIZ 5: PART 4 - ANALYTICAL POWER {#quiz-part4}

### Multiple Choice (10 Questions)

**85. Which aggregate function is used to count rows?**
- A) SUM()
- B) AVG()
- C) COUNT()
- D) MAX()

**86. What does `GROUP BY` do?**
- A) Sorts the result set
- B) Filters rows before grouping
- C) Groups rows with the same values for aggregation
- D) Limits the number of rows returned

**87. What is the difference between `WHERE` and `HAVING`?**
- A) WHERE filters rows, HAVING filters groups
- B) WHERE filters groups, HAVING filters rows
- C) They are interchangeable
- D) WHERE is for aggregations, HAVING is for columns

**88. What does the following query return? `SELECT status, COUNT(*) FROM orders GROUP BY status`**
- A) The number of orders, grouped by status
- B) The total revenue, grouped by status
- C) The average order value, grouped by status
- D) The maximum order value, grouped by status

**89. What is a window function?**
- A) A function that performs calculations across a set of rows without collapsing them
- B) A function that only works with JSONB data
- C) A function that creates a new window in the database
- D) A function that is used only in JOIN operations

**90. What does `ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date)` do?**
- A) Assigns a sequential number to each order, starting over for each user
- B) Assigns a sequential number to each order globally
- C) Ranks users by their order count
- D) Calculates the running total for each user

**91. What is the difference between `RANK()` and `DENSE_RANK()`?**
- A) RANK skips ranks on ties, DENSE_RANK doesn't
- B) DENSE_RANK skips ranks on ties, RANK doesn't
- C) They are the same
- D) RANK works only on numerical data

**92. What does `LAG(column, 1)` do?**
- A) Gets the value from the next row
- B) Gets the value from the previous row
- C) Gets the running total
- D) Gets the rank of the row

**93. Which of the following is a valid use of `CASE WHEN`?**
- A) `CASE WHEN total > 100 THEN 'Large' ELSE 'Small' END`
- B) `CASE total WHEN > 100 THEN 'Large' ELSE 'Small' END`
- C) `WHEN total > 100 THEN 'Large' ELSE 'Small' END`
- D) `CASE total > 100 'Large' ELSE 'Small'`

**94. What does `NTILE(4) OVER (ORDER BY total)` do?**
- A) Splits the result into 4 groups (quartiles)
- B) Ranks the result in 4 categories
- C) Calculates the moving average
- D) Finds the median value

### True/False (5 Questions)

**95.** `HAVING` is used before `GROUP BY`. (T/F)

**96.** Window functions can be used without an `ORDER BY` clause. (T/F)

**97.** `SUM(column) OVER (PARTITION BY category)` calculates a running total per category. (T/F)

**98.** `CASE WHEN` can only be used in `SELECT` statements. (T/F)

**99.** `PERCENTILE_CONT(0.5)` calculates the median value. (T/F)

### Fill in the Blank (5 Questions)

**100.** The __________ function returns the total sum of a numeric column.

**101.** __________ filters groups after aggregation, while __________ filters rows before aggregation.

**102.** A __________ function performs calculations across a set of rows related to the current row.

**103.** The __________ function allows you to look at a value from a previous row.

**104.** __________ is used for conditional logic in SQL.

### Practical Coding (3 Questions)

**105. Write a SQL query to show monthly revenue and order count for the last 6 months.**

```sql
-- Your answer:
```

**106. Write a SQL query to rank customers by their total spending.**

```sql
-- Your answer:
```

**107. Write a SQL query to categorize products into price tiers (Budget: < 50, Mid: 50-200, Premium: > 200) and count products in each tier.**

```sql
-- Your answer:
```

---

## QUIZ 6: PART 5 - JSONB & EXTENSIONS {#quiz-part5}

### Multiple Choice (10 Questions)

**108. What does JSONB stand for?**
- A) JavaScript Object Notation Binary
- B) JSON Binary
- C) JavaScript Object Notation with Binary storage
- D) JSON Binary storage format

**109. Which operator is used to get a JSONB field as text?**
- A) `->`
- B) `->>`
- C) `#>`
- D) `#>>`

**110. What does the `@>` operator do in JSONB?**
- A) Checks if a key exists
- B) Checks if the left JSON contains the right JSON
- C) Concatenates two JSON objects
- D) Removes a key from JSON

**111. What is the `pg_trgm` extension used for?**
- A) JSONB validation
- B) Fuzzy text search
- C) UUID generation
- D) Encryption

**112. What is a trigram?**
- A) Three words in a search query
- B) Three consecutive characters
- C) Three database tables
- D) Three indexes on a table

**113. Which of the following is a valid GIN index for JSONB?**
- A) `CREATE INDEX idx ON products USING gin(attributes)`
- B) `CREATE INDEX idx ON products USING btree(attributes)`
- C) `CREATE INDEX idx ON products USING hash(attributes)`
- D) `CREATE INDEX idx ON products USING brin(attributes)`

**114. What does `tsvector` represent in PostgreSQL?**
- A) A timestamp vector
- B) A full-text search document
- C) A JSONB document
- D) A transaction status vector

**115. Which function ranks full-text search results?**
- A) `ts_rank_cd()`
- B) `to_tsvector()`
- C) `plainto_tsquery()`
- D) `jsonb_rank()`

**116. What is the purpose of `setweight()` in full-text search?**
- A) To set the weight of search terms
- B) To assign importance levels to different text fields
- C) To measure the weight of a JSONB object
- D) To calculate the weight of an index

**117. When would you use JSONB instead of a relational table?**
- A) When data is highly structured
- B) When data varies per row and schema is flexible
- C) When you need strict data validation
- D) When you need to join data frequently

### True/False (5 Questions)

**118.** JSONB stores data in plain text format. (T/F)

**119.** GIN indexes can be used to speed up JSONB queries. (T/F)

**120.** The `pg_trgm` extension is automatically available in Neon. (T/F)

**121.** Full-text search and trigram search serve the same purpose. (T/F)

**122.** JSONB fields cannot be indexed. (T/F)

### Fill in the Blank (5 Questions)

**123.** The `->>` operator returns JSONB values as __________.

**124.** The __________ extension enables fuzzy text search in PostgreSQL.

**125.** A __________ is a group of three consecutive characters used for text comparison.

**126.** The __________ function creates a tsvector for full-text search.

**127.** A __________ index is used to speed up JSONB and full-text queries.

### Practical Coding (3 Questions)

**128. Write a SQL statement to add a JSONB column called `attributes` to a products table.**

```sql
-- Your answer:
```

**129. Write a SQL query to find products where the brand (in metadata JSONB) is 'AudioPro'.**

```sql
-- Your answer:
```

**130. Write a SQL query that uses trigram similarity to search for products with name similar to 'wireless headphone'.**

```sql
-- Your answer:
```

---

## QUIZ 7: PART 6 - PERFORMANCE, TRANSACTIONS & CI/CD {#quiz-part6}

### Multiple Choice (10 Questions)

**131. What does `EXPLAIN ANALYZE` do?**
- A) Only shows the query plan without executing
- B) Shows the query plan AND executes the query with timing
- C) Deletes the query plan cache
- D) Optimizes the query automatically

**132. What does "Seq Scan" indicate in an EXPLAIN plan?**
- A) The query is using an index
- B) The query is scanning the entire table
- C) The query is using a sequential index
- D) The query is sorting the results

**133. Which is a sign of a missing index?**
- A) "Index Scan" in EXPLAIN
- B) "Seq Scan" on a large table
- C) "Bitmap Heap Scan" in EXPLAIN
- D) "Nested Loop" on small tables

**134. What does ACID stand for?**
- A) Atomicity, Consistency, Isolation, Durability
- B) Atomic, Consecutive, Integrated, Durable
- C) Access, Control, Integrity, Data
- D) Advanced, Combined, Integrated, Distributed

**135. What is a transaction?**
- A) A single SQL statement
- B) A sequence of SQL statements that are treated as a single unit
- C) A backup of the database
- D) A data migration

**136. What does `COMMIT` do in a transaction?**
- A) Undoes all changes in the transaction
- B) Saves all changes in the transaction permanently
- C) Creates a savepoint
- D) Starts a new transaction

**137. What does `FOR UPDATE` do in a SELECT query?**
- A) Locks the selected rows for update
- B) Updates the selected rows automatically
- C) Deletes the selected rows after update
- D) Creates a backup of the selected rows

**138. What is the purpose of `SAVEPOINT` in a transaction?**
- A) To commit the transaction
- B) To mark a point for partial rollback
- C) To start a new transaction
- D) To lock all tables

**139. In a GitHub Actions workflow, when should you create a preview branch in Neon?**
- A) When pushing to main
- B) When a pull request is opened
- C) When a release is created
- D) When a user registers

**140. What is the benefit of using Neon branches in CI/CD?**
- A) They are slower than traditional databases
- B) They provide isolated database environments for testing
- C) They automatically deploy to production
- D) They require no setup

### True/False (5 Questions)

**141.** `EXPLAIN` executes the query and shows the actual results. (T/F)

**142.** A transaction can be rolled back at any point. (T/F)

**143.** `FOR UPDATE` locks rows to prevent concurrent modifications. (T/F)

**144.** Neon branches are not useful for CI/CD workflows. (T/F)

**145.** Partial indexes only apply to a subset of rows. (T/F)

### Fill in the Blank (5 Questions)

**146.** The __________ command in PostgreSQL shows the query execution plan.

**147.** The __________ isolation level prevents dirty reads in PostgreSQL.

**148.** The __________ command saves all changes in a transaction.

**149.** Neon branches can be merged to main using the __________ command.

**150.** A __________ index only indexes rows that meet a specific condition.

### Practical Coding (3 Questions)

**151. Write a transaction that creates an order, inserts order items, and updates inventory.**

```sql
-- Your answer:
```

**152. Write a function that reserves inventory with row-level locking.**

```sql
-- Your answer:
```

**153. Write a GitHub Actions workflow step that creates a Neon preview branch for a pull request.**

```yaml
# Your answer:
```

---

## QUIZ 8: PRIMERS ASSESSMENT {#quiz-primers}

### Multiple Choice (10 Questions)

**154. What is normalization?**
- A) Reversing database changes
- B) Organizing data to reduce redundancy
- C) Increasing data redundancy
- D) Creating indexes

**155. What is 1NF (First Normal Form)?**
- A) No transitive dependencies
- B) No repeating groups
- C) No partial dependencies
- D) All attributes are atomic

**156. What is the main purpose of a primary key?**
- A) To uniquely identify each row in a table
- B) To reference another table
- C) To store JSON data
- D) To create indexes

**157. What is a connection pooler?**
- A) A tool that creates database branches
- B) A tool that manages database connections
- C) A tool that optimizes queries
- D) A tool that backs up databases

**158. Which isolation level is the default in PostgreSQL?**
- A) SERIALIZABLE
- B) REPEATABLE READ
- C) READ COMMITTED
- D) READ UNCOMMITTED

**159. What is the purpose of `pg_stat_statements`?**
- A) To track query performance
- B) To create backups
- C) To manage connections
- D) To create branches

**160. What is a materialized view?**
- A) A view that stores query results physically
- B) A view that is created on demand
- C) A view that is only used for debugging
- D) A view that cannot be queried

**161. What is the primary benefit of connection pooling in Neon?**
- A) It increases query speed
- B) It reduces connection overhead for serverless functions
- C) It creates automatic backups
- D) It provides read replicas

**162. What is the difference between a view and a materialized view?**
- A) Views are faster
- B) Materialized views store data physically
- C) Views cannot be used in JOINs
- D) Materialized views cannot be indexed

**163. What is the purpose of `VACUUM` in PostgreSQL?**
- A) To create backups
- B) To reclaim storage and update statistics
- C) To create indexes
- D) To optimize queries

### True/False (5 Questions)

**164.** 3NF is stricter than BCNF. (T/F)

**165.** A connection pool can reduce the number of database connections. (T/F)

**166.** SQL injection can be prevented with parameterized queries. (T/F)

**167.** RLS (Row Level Security) is a feature in MySQL. (T/F)

**168.** All PostgreSQL extensions are automatically available in Neon. (T/F)

### Fill in the Blank (5 Questions)

**169.** __________ is the process of organizing data to reduce redundancy.

**170.** The __________ form of normalization eliminates transitive dependencies.

**171.** A __________ is a pool of database connections that can be reused.

**172.** __________ is a security feature that limits which rows a user can access.

**173.** The __________ command updates table statistics in PostgreSQL.

---

## FINAL COMPREHENSIVE EXAM {#quiz-final}

### Part A: Multiple Choice (20 Questions)

**174. Which command creates a new database branch in Neon?**
- A) `neonctl branch create`
- B) `neonctl branches create`
- C) `neonctl new branch`
- D) `neonctl create branch`

**175. What is the purpose of a CHECK constraint?**
- A) To ensure a column is not null
- B) To enforce custom validation rules
- C) To create a foreign key relationship
- D) To create an index

**176. Which JOIN type is used to find products that have been ordered?**
- A) LEFT JOIN
- B) RIGHT JOIN
- C) INNER JOIN
- D) FULL JOIN

**177. What does the following query do? `SELECT user_id, COUNT(*) FROM orders GROUP BY user_id HAVING COUNT(*) > 2`**
- A) Counts total orders
- B) Finds users with more than 2 orders
- C) Finds orders with more than 2 items
- D) Counts users with orders

**178. What is a window function?**
- A) A function that creates a new window
- B) A function that performs calculations across a set of rows
- C) A function that only works with JSONB
- D) A function that creates indexes

**179. What is the best data type for storing product prices?**
- A) REAL
- B) DOUBLE PRECISION
- C) NUMERIC(10,2)
- D) TEXT

**180. What does the `ILIKE` operator do?**
- A) Case-sensitive pattern matching
- B) Case-insensitive pattern matching
- C) Exact equality comparison
- D) Range comparison

**181. What is the main advantage of using UUID over SERIAL?**
- A) Better performance
- B) Global uniqueness across systems
- C) Smaller storage size
- D) Simpler to implement

**182. What does `ON DELETE RESTRICT` do?**
- A) Deletes child records when parent is deleted
- B) Prevents deletion if child records exist
- C) Sets foreign key to NULL
- D) Cascades deletion to all tables

**183. What is a junction table?**
- A) A table that connects two tables in a Many-to-Many relationship
- B) A table that stores JSON data
- C) A table that creates indexes
- D) A temporary table

**184. What is the purpose of `EXPLAIN ANALYZE`?**
- A) To analyze and execute a query with timing
- B) To create a query plan
- C) To optimize a query automatically
- D) To delete a query plan

**185. Which of the following is a valid JSONB containment query?**
- A) `WHERE attributes->'color' = 'Black'`
- B) `WHERE attributes @> '{"color": "Black"}'::jsonb`
- C) `WHERE attributes ? 'color'`
- D) `WHERE attributes->>'color' = 'Black'`

**186. What does `ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC)` do?**
- A) Assigns a rank to products within their category
- B) Assigns a global rank to all products
- C) Groups products by category
- D) Sorts products by price

**187. What is the difference between `LAG()` and `LEAD()`?**
- A) LAG looks at previous rows, LEAD looks at following rows
- B) LAG looks at following rows, LEAD looks at previous rows
- C) They are the same
- D) LAG works with strings, LEAD works with numbers

**188. What is the main benefit of using JSONB in PostgreSQL?**
- A) It's faster than relational data
- B) It provides flexible, semi-structured data storage
- C) It's smaller than TEXT
- D) It automatically creates indexes

**189. What does `COMMIT` do in a transaction?**
- A) Undoes all changes
- B) Saves all changes permanently
- C) Starts a new transaction
- D) Creates a savepoint

**190. What is a connection pooler?**
- A) A tool that creates database branches
- B) A tool that manages and reuses database connections
- C) A tool that optimizes queries
- D) A tool that creates backups

**191. What is the purpose of a soft delete?**
- A) To permanently remove data
- B) To mark data as deleted without removing it
- C) To delete data from a backup
- D) To delete data in a transaction

**192. Which extension is used for fuzzy text search?**
- A) `uuid-ossp`
- B) `pg_trgm`
- C) `btree_gin`
- D) `pgcrypto`

**193. What is the first normal form (1NF)?**
- A) No transitive dependencies
- B) No repeating groups
- C) No partial dependencies
- D) All attributes are atomic

### Part B: True/False (10 Questions)

**194.** A table can have multiple primary keys. (T/F)

**195.** `TIMESTAMPTZ` stores timezone information. (T/F)

**196.** LEFT JOIN and LEFT OUTER JOIN are different. (T/F)

**197.** `HAVING` is used to filter groups after GROUP BY. (T/F)

**198.** JSONB fields can be indexed. (T/F)

**199.** Neon branches are not useful for CI/CD workflows. (T/F)

**200.** A transaction cannot be rolled back after COMMIT. (T/F)

**201.** `EXPLAIN` executes the query and shows the results. (T/F)

**202.** `pg_trgm` is automatically available in all Neon projects. (T/F)

**203.** Row Level Security (RLS) can be used to limit which rows users can see. (T/F)

### Part C: Fill in the Blank (10 Questions)

**204.** The four basic database operations are __________, __________, __________, and __________.

**205.** The __________ operator is used for case-insensitive pattern matching in PostgreSQL.

**206.** A __________ is a column that references a primary key in another table.

**207.** The __________ function generates a random UUID in PostgreSQL.

**208.** The __________ command shows the query execution plan.

**209.** A __________ is a group of three consecutive characters used for fuzzy search.

**210.** The __________ isolation level is the default in PostgreSQL.

**211.** The __________ command is used to merge a Neon branch to main.

**212.** A __________ is a stored procedure that automatically executes on certain events.

**213.** The __________ extension enables full-text search capabilities in PostgreSQL.

### Part D: Practical Coding (10 Questions)

**214. Write a SQL query to create a products table with UUID primary key, name, price, and stock quantity.**

```sql
-- Your answer:
```

**215. Write a SQL query to insert 5 sample products.**

```sql
-- Your answer:
```

**216. Write a SQL query to find all products with price between 50 and 200.**

```sql
-- Your answer:
```

**217. Write a SQL query to update product prices by 10% for products with stock < 20.**

```sql
-- Your answer:
```

**218. Write a SQL query to get total revenue by month for the last 3 months.**

```sql
-- Your answer:
```

**219. Write a SQL query to find the top 5 customers by total spending.**

```sql
-- Your answer:
```

**220. Write a SQL query to create a junction table for a Many-to-Many relationship.**

```sql
-- Your answer:
```

**221. Write a SQL query that uses JSONB to store product attributes.**

```sql
-- Your answer:
```

**222. Write a transaction that creates an order and reserves inventory.**

```sql
-- Your answer:
```

**223. Write the Neon CLI command to create a preview branch for a pull request.**

```bash
# Your answer:
```

---

## ANSWER KEYS {#answer-keys}

### Quiz 1: Part 0 - Introduction

**Multiple Choice:**
1. B) A serverless PostgreSQL platform
2. B) Instant database branching
3. B) The database automatically scales compute resources down to zero when not in use
4. C) Seconds
5. C) S3-backed storage layer

**True/False:**
6. False
7. False (10GB storage, 20 compute hours)
8. False (Uses copy-on-write, shares storage)
9. True
10. True

**Fill in the Blank:**
11. Git
12. 20
13. Control Plane
14. Project
15. GitHub

---

### Quiz 2: Part 1 - Setup & Cloud SQL Fundamentals

**Multiple Choice:**
16. B) `psql "postgresql://username:password@ep-xyz/database?sslmode=require"`
17. C) NUMERIC(10,2)
18. B) Creates an auto-incrementing integer
19. C) SELECT
20. B) Products with price between 50 and 100 (inclusive)
21. B) `LIKE 'W%'`
22. B) It's case-insensitive
23. B) To return a limited number of rows
24. A) `\d table_name`
25. B) The total number of rows in the products table

**True/False:**
26. False
27. True
28. False
29. False
30. True

**Fill in the Blank:**
31. CRUD (Create, Read, Update, Delete)
32. IS NULL
33. WHERE
34. \q
35. seed script

**Practical Coding:**
36.
```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

37.
```sql
INSERT INTO customers (name, email) VALUES
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Bob Johnson', 'bob@example.com');
```

38.
```sql
SELECT * FROM customers 
WHERE name LIKE 'J%' AND email IS NOT NULL;
```

---

### Quiz 3: Part 2 - Bulletproof Schemas & Data Integrity

**Multiple Choice:**
39. C) REQUIRED
40. C) Validates email format using a regular expression
41. B) A 128-bit universally unique identifier
42. C) `uuid_generate_v4()`
43. B) CASCADE allows deletion, RESTRICT prevents it
44. B) Marking data as deleted without physically removing it
45. C) Pooled connection with transaction mode
46. B) To track when a record was last modified
47. B) They can enforce custom business rules
48. B) Provides a fallback value if none is specified

**True/False:**
49. False
50. False
51. True
52. True
53. True

**Fill in the Blank:**
54. uuid-ossp
55. SERIAL
56. trigger
57. crypt()
58. Pooled

**Practical Coding:**
59.
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    username VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT valid_username CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$'),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'suspended'))
);
```

60.
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';
```

61.
```sql
UPDATE users SET deleted_at = CURRENT_TIMESTAMP 
WHERE email = 'user@example.com';
```

---

### Quiz 4: Part 3 - Database Branching & Relational Architecture

**Multiple Choice:**
62. B) `neonctl branches create`
63. D) All of the above
64. A) Connecting two tables in a Many-to-Many relationship
65. C) INNER JOIN
66. B) LEFT JOIN
67. B) A column that references a primary key in another table
68. B) Deletes child records when parent is deleted
69. D) IGNORE
70. B) An instant copy of the entire database
71. B) To preserve product information even if the product changes

**True/False:**
72. True
73. True
74. True
75. False
76. False

**Fill in the Blank:**
77. foreign key
78. FULL OUTER
79. junction table
80. ON DELETE CASCADE
81. main

**Practical Coding:**
82.
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);
```

83.
```sql
SELECT 
    o.order_number,
    u.full_name,
    a.address_line1,
    a.city,
    a.state
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN addresses a ON o.shipping_address_id = a.id;
```

84.
```bash
neonctl branches create --name dev-branch --parent main --project-id YOUR_PROJECT_ID
neonctl branches get-connection-string dev-branch --project-id YOUR_PROJECT_ID
neonctl branches merge dev-branch --target main --project-id YOUR_PROJECT_ID
```

---

### Quiz 5: Part 4 - Analytical Power

**Multiple Choice:**
85. C) COUNT()
86. C) Groups rows with the same values for aggregation
87. A) WHERE filters rows, HAVING filters groups
88. A) The number of orders, grouped by status
89. A) A function that performs calculations across a set of rows without collapsing them
90. A) Assigns a sequential number to each order, starting over for each user
91. A) RANK skips ranks on ties, DENSE_RANK doesn't
92. B) Gets the value from the previous row
93. A) `CASE WHEN total > 100 THEN 'Large' ELSE 'Small' END`
94. A) Splits the result into 4 groups (quartiles)

**True/False:**
95. False
96. True
97. True
98. False
99. True

**Fill in the Blank:**
100. SUM()
101. HAVING, WHERE
102. window
103. LAG()
104. CASE WHEN

**Practical Coding:**
105.
```sql
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS order_count,
    SUM(total) AS revenue
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;
```

106.
```sql
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total) DESC) AS rank
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```

107.
```sql
SELECT 
    CASE 
        WHEN price < 50 THEN 'Budget'
        WHEN price >= 50 AND price < 200 THEN 'Mid'
        ELSE 'Premium'
    END AS price_tier,
    COUNT(*) AS product_count
FROM products
GROUP BY price_tier;
```

---

### Quiz 6: Part 5 - JSONB & Extensions

**Multiple Choice:**
108. A) JavaScript Object Notation Binary
109. B) `->>`
110. B) Checks if the left JSON contains the right JSON
111. B) Fuzzy text search
112. B) Three consecutive characters
113. A) `CREATE INDEX idx ON products USING gin(attributes)`
114. B) A full-text search document
115. A) `ts_rank_cd()`
116. B) To assign importance levels to different text fields
117. B) When data varies per row and schema is flexible

**True/False:**
118. False
119. True
120. True
121. False
122. False

**Fill in the Blank:**
123. text
124. pg_trgm
125. trigram
126. to_tsvector()
127. GIN

**Practical Coding:**
128.
```sql
ALTER TABLE products ADD COLUMN attributes JSONB DEFAULT '{}'::jsonb;
```

129.
```sql
SELECT * FROM products 
WHERE metadata->>'brand' = 'AudioPro';
```

130.
```sql
SELECT * FROM products
WHERE similarity(name, 'wireless headphone') > 0.3
ORDER BY similarity(name, 'wireless headphone') DESC;
```

---

### Quiz 7: Part 6 - Performance, Transactions & CI/CD

**Multiple Choice:**
131. B) Shows the query plan AND executes the query with timing
132. B) The query is scanning the entire table
133. B) "Seq Scan" on a large table
134. A) Atomicity, Consistency, Isolation, Durability
135. B) A sequence of SQL statements that are treated as a single unit
136. B) Saves all changes in the transaction permanently
137. A) Locks the selected rows for update
138. B) To mark a point for partial rollback
139. B) When a pull request is opened
140. B) They provide isolated database environments for testing

**True/False:**
141. False
142. True
143. True
144. False
145. True

**Fill in the Blank:**
146. EXPLAIN
147. READ COMMITTED
148. COMMIT
149. merge
150. partial

**Practical Coding:**
151.
```sql
BEGIN;
INSERT INTO orders (user_id, total) VALUES (user_id, 99.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (order_id, 1, 2, 49.99);
UPDATE products SET stock_quantity = stock_quantity - 2 WHERE id = 1 AND stock_quantity >= 2;
COMMIT;
```

152.
```sql
CREATE OR REPLACE FUNCTION reserve_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER
)
RETURNS BOOLEAN AS $$
DECLARE
    v_available INTEGER;
BEGIN
    SELECT stock_quantity INTO v_available
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    IF v_available < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock';
    END IF;
    
    UPDATE inventory 
    SET reserved_quantity = reserved_quantity + p_quantity
    WHERE product_id = p_product_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

153.
```yaml
- name: Create Preview Branch
  run: |
    BRANCH_NAME="preview-${{ github.event.pull_request.number }}"
    neonctl branches create \
      --name $BRANCH_NAME \
      --parent main \
      --project-id ${{ secrets.PROJECT_ID }}
    echo "BRANCH_NAME=$BRANCH_NAME" >> $GITHUB_ENV
```

---

### Quiz 8: Primers Assessment

**Multiple Choice:**
154. B) Organizing data to reduce redundancy
155. B) No repeating groups
156. A) To uniquely identify each row in a table
157. B) A tool that manages database connections
158. C) READ COMMITTED
159. A) To track query performance
160. A) A view that stores query results physically
161. B) It reduces connection overhead for serverless functions
162. B) Materialized views store data physically
163. B) To reclaim storage and update statistics

**True/False:**
164. False
165. True
166. True
167. False
168. False

**Fill in the Blank:**
169. Normalization
170. Third Normal Form (3NF)
171. connection pool
172. Row Level Security (RLS)
173. ANALYZE

---

### Final Comprehensive Exam - Answer Key

**Part A: Multiple Choice**
174. B) `neonctl branches create`
175. B) To enforce custom validation rules
176. C) INNER JOIN
177. B) Finds users with more than 2 orders
178. B) A function that performs calculations across a set of rows
179. C) NUMERIC(10,2)
180. B) Case-insensitive pattern matching
181. B) Global uniqueness across systems
182. B) Prevents deletion if child records exist
183. A) A table that connects two tables in a Many-to-Many relationship
184. A) To analyze and execute a query with timing
185. B) `WHERE attributes @> '{"color": "Black"}'::jsonb`
186. A) Assigns a rank to products within their category
187. A) LAG looks at previous rows, LEAD looks at following rows
188. B) It provides flexible, semi-structured data storage
189. B) Saves all changes permanently
190. B) A tool that manages and reuses database connections
191. B) To mark data as deleted without removing it
192. B) `pg_trgm`
193. B) No repeating groups

**Part B: True/False**
194. False
195. True
196. False
197. True
198. True
199. False
200. True
201. False
202. False (must be enabled)
203. True

**Part C: Fill in the Blank**
204. CREATE, READ, UPDATE, DELETE
205. ILIKE
206. foreign key
207. `gen_random_uuid()`
208. EXPLAIN
209. trigram
210. READ COMMITTED
211. merge
212. trigger
213. `pg_trgm`

**Part D: Practical Coding**
214.
```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0
);
```

215.
```sql
INSERT INTO products (name, price, stock_quantity) VALUES
    ('Product A', 99.99, 100),
    ('Product B', 149.99, 50),
    ('Product C', 49.99, 75),
    ('Product D', 299.99, 25),
    ('Product E', 19.99, 200);
```

216.
```sql
SELECT * FROM products WHERE price BETWEEN 50 AND 200;
```

217.
```sql
UPDATE products 
SET price = price * 1.10 
WHERE stock_quantity < 20;
```

218.
```sql
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(total) AS revenue
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;
```

219.
```sql
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC
LIMIT 5;
```

220.
```sql
CREATE TABLE order_items (
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```

221.
```sql
ALTER TABLE products ADD COLUMN attributes JSONB DEFAULT '{}'::jsonb;

UPDATE products 
SET attributes = jsonb_build_object(
    'color', 'Black',
    'connectivity', 'Bluetooth 5.3',
    'battery_life', '40 hours'
)
WHERE name = 'Wireless Headphones';
```

222.
```sql
BEGIN;
INSERT INTO orders (user_id, total) VALUES (user_id, 99.99);
-- Reserve inventory
UPDATE inventory SET reserved_quantity = reserved_quantity + 1 
WHERE product_id = 1 AND quantity > 0;
INSERT INTO order_items (order_id, product_id, quantity, unit_price) 
VALUES (order_id, 1, 1, 99.99);
COMMIT;
```

223.
```bash
neonctl branches create \
  --name preview-${{ github.event.pull_request.number }} \
  --parent main \
  --project-id ${{ secrets.PROJECT_ID }}
```

---

## Grading Rubric

### Scoring Guide

| Score | Grade | Description |
|-------|-------|-------------|
| 90-100% | A | Excellent understanding |
| 80-89% | B | Good understanding |
| 70-79% | C | Satisfactory understanding |
| 60-69% | D | Needs improvement |
| Below 60% | F | Needs significant review |

### Quiz Weighting (if used for final grade)

| Component | Weight |
|-----------|--------|
| Quizzes 1-7 | 50% |
| Primers Assessment | 10% |
| Final Comprehensive Exam | 40% |

---

## Additional Resources

**For Review:**
- Course slide deck
- Student workbook
- Student notes
- SQL cheat sheet
- Appendix materials

**For Practice:**
- Sample data generation scripts
- Query exercises
- Project assignments
- Code sandbox environment

---

**[END OF TEST BANK]**

*Use these questions to assess understanding and reinforce learning throughout the course. Good luck!* 🍀
