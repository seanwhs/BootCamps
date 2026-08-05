# Mastering Modern Database Design — Complete Quiz & Question Bank

## Comprehensive Assessment Database with Answer Keys

---

## QUIZ BANK OVERVIEW

This document contains a complete question bank organized by module, with questions ranging from basic recall to complex application scenarios.

**Question Types:**
- Multiple Choice (MC)
- True/False (TF)
- Fill in the Blank (FB)
- Short Answer (SA)
- Scenario-Based (SB)
- Code Analysis (CA)

**Difficulty Levels:**
- ★ (Basic Recall)
- ★★ (Understanding)
- ★★★ (Application)
- ★★★★ (Analysis)
- ★★★★★ (Synthesis)

---

## PART 0: INTRODUCTION & FUNDAMENTALS

### Module 0.1: Database Concepts

**Q001: What is a database?** ★
- A) A collection of spreadsheets
- B) A structured collection of data stored electronically
- C) A programming language
- D) A type of computer memory

**Answer: B**

---

**Q002: Which of the following is NOT a type of database?** ★
- A) Relational
- B) NoSQL
- C) Hierarchical
- D) Distributed (Actually D is a type)

**Answer: D**

---

**Q003: What does SQL stand for?** ★
- A) Standard Query Language
- B) Structured Query Language
- C) Simple Query Language
- D) Systematic Query Language

**Answer: B**

---

**Q004: The three-tier architecture consists of:** ★
- A) Client, Server, Database
- B) Presentation, Application, Data
- C) Frontend, Backend, Middleware
- D) UI, API, DB

**Answer: B**

---

**Q005: Which of the following is a characteristic of a relational database?** ★★
- A) Data is stored in JSON documents
- B) Data is organized in tables with rows and columns
- C) Data is stored as key-value pairs
- D) Data is stored as graphs

**Answer: B**

---

**Q006: What is a primary key?** ★
- A) The first column in a table
- B) A unique identifier for each row in a table
- C) A key that opens the database
- D) The most important column

**Answer: B**

---

**Q007: What is a foreign key?** ★
- A) A key from another country
- B) A reference to a primary key in another table
- C) A key that can be NULL
- D) A key that is not unique

**Answer: B**

---

**Q008: What does ACID stand for?** ★
- A) Atomicity, Consistency, Isolation, Durability
- B) Availability, Consistency, Integrity, Durability
- C) Atomicity, Clarity, Integrity, Durability
- D) Availability, Clarity, Isolation, Durability

**Answer: A**

---

**Q009: What is normalization?** ★★
- A) Making all tables the same size
- B) Organizing data to reduce redundancy
- C) Adding indexes to improve performance
- D) Creating foreign keys

**Answer: B**

---

**Q010: Which of the following is a NoSQL database type?** ★
- A) PostgreSQL
- B) MongoDB
- C) Oracle
- D) MySQL

**Answer: B**

---

### Module 0.2: ScaleCart Requirements

**Q011: ScaleCart is designed to handle how many product records?** ★
- A) 100,000
- B) 1,000,000
- C) 100,000,000
- D) 1,000,000,000

**Answer: C**

---

**Q012: Which of the following is NOT a core entity in ScaleCart?** ★
- A) Customer
- B) Product
- C) Inventory
- D) Shopping Cart (Cart is stored in Redis, not PostgreSQL)

**Answer: D**

---

**Q013: The ScaleCart platform is built with which primary programming language?** ★
- A) Java
- B) Python
- C) JavaScript
- D) C#

**Answer: B**

---

## PART 1: FOUNDATIONS OF RELATIONAL DATABASE DESIGN

### Module 1.1: ER Modeling

**Q101: What is an entity in ER modeling?** ★
- A) A property of a relationship
- B) A real-world object or concept with independent existence
- C) A type of relationship
- D) A constraint on data

**Answer: B**

---

**Q102: Which of the following is an example of an attribute?** ★
- A) Customer
- B) Order
- C) Email address
- D) Places Order (relationship)

**Answer: C**

---

**Q103: What is cardinality?** ★
- A) The number of attributes in an entity
- B) The number of relationships between entities
- C) The size of the database
- D) The number of tables

**Answer: B**

---

**Q104: A one-to-many relationship is represented in an ERD by:** ★★
- A) A line with a crow's foot on the "many" side
- B) A line with a crow's foot on both sides
- C) A line with no symbols
- D) A diamond

**Answer: A**

---

**Q105: Which of the following is a valid relationship cardinality?** ★
- A) One-to-One (1:1)
- B) One-to-Many (1:N)
- C) Many-to-Many (N:M)
- D) All of the above

**Answer: D**

---

**Q106: In a customer-order relationship, what is the cardinality?** ★★
- A) One customer can have many orders
- B) One order can have many customers
- C) Many customers can have many orders
- D) One customer has one order

**Answer: A**

---

**Q107: What is a weak entity?** ★★
- A) An entity without a primary key
- B) An entity that cannot exist without its parent entity
- C) An entity with no attributes
- D) An entity with only one attribute

**Answer: B**

---

**Q108: What does the "N" in "1:N" represent?** ★
- A) Any number (including zero)
- B) Only one
- C) No relationships
- D) Negative relationship

**Answer: A**

---

**Q109: A many-to-many relationship requires:** ★★
- A) A foreign key in one table
- B) A junction table (associative entity)
- C) A primary key change
- D) A view

**Answer: B**

---

**Q110: In a product-category relationship, if a product can belong to only one category, but a category can have many products, the relationship is:** ★
- A) One-to-One
- B) One-to-Many
- C) Many-to-Many
- D) Unrelated

**Answer: B**

---

**Q111: What is a derived attribute?** ★★
- A) An attribute that is stored in the database
- B) An attribute that is calculated from other attributes
- C) An attribute that is always NULL
- D) An attribute that is a primary key

**Answer: B**

---

**Q112: Which notation is most commonly used for ER diagrams in this course?** ★★
- A) Chen notation
- B) Crow's Foot notation
- C) UML notation
- D) IDEF1X notation

**Answer: B**

---

**Q113: What is a composite attribute?** ★★
- A) An attribute that has multiple values
- B) An attribute made up of multiple smaller attributes
- C) An attribute that is also a primary key
- D) An attribute that is calculated

**Answer: B**

---

**Q114: [Scenario] A library database stores books, authors, and borrowers. A book can have multiple authors. An author can write multiple books. A borrower can borrow multiple books. Which tables would be needed?** ★★★
- A) Books, Authors, Borrowers
- B) Books, Authors, Borrowers, Book_Authors
- C) Books, Authors, Borrowers, Loans
- D) Books, Authors, Borrowers, Book_Authors, Loans

**Answer: D**

---

**Q115: [Scenario] In an e-commerce system, what is the relationship between Products and Categories?** ★★
- A) One-to-Many (One category has many products)
- B) Many-to-One (Many products have one category)
- C) Both A and B are correct
- D) Many-to-Many

**Answer: C**

---

### Module 1.2: Normalization

**Q201: What is the main purpose of normalization?** ★
- A) To make queries faster
- B) To reduce data redundancy
- C) To increase data security
- D) To create more tables

**Answer: B**

---

**Q202: First Normal Form (1NF) requires:** ★
- A) No duplicate rows
- B) Atomic values and no repeating groups
- C) No partial dependencies
- D) No transitive dependencies

**Answer: B**

---

**Q203: Second Normal Form (2NF) requires:** ★★
- A) 1NF plus no partial dependencies
- B) 1NF plus no transitive dependencies
- C) No duplicate data
- D) All columns are primary keys

**Answer: A**

---

**Q204: Third Normal Form (3NF) requires:** ★★
- A) 1NF plus 2NF plus no transitive dependencies
- B) 2NF plus no partial dependencies
- C) 1NF plus no duplicate data
- D) All tables have a primary key

**Answer: A**

---

**Q205: What is a transitive dependency?** ★★
- A) When A depends on B, which depends on C
- B) When A depends on B and B depends on A
- C) When a column depends on part of a composite key
- D) When a column depends on another non-key column

**Answer: D**

---

**Q206: Which normal form eliminates transitive dependencies?** ★
- A) 1NF
- B) 2NF
- C) 3NF
- D) BCNF

**Answer: C**

---

**Q207: BCNF (Boyce-Codd Normal Form) is stricter than 3NF and addresses:** ★★
- A) Composite keys
- B) Overlapping candidate keys
- C) Multi-valued dependencies
- D) All of the above

**Answer: B**

---

**Q208: [Scenario] A table has columns: OrderID, ProductID, Quantity, ProductName, ProductPrice. The primary key is (OrderID, ProductID). Which normal form violation exists?** ★★★
- A) 1NF violation
- B) 2NF violation (ProductName depends only on ProductID)
- C) 3NF violation
- D) BCNF violation

**Answer: B**

---

**Q209: [Scenario] A table has columns: EmployeeID, DepartmentID, DepartmentName. Which normal form violation exists?** ★★★
- A) 1NF violation
- B) 2NF violation
- C) 3NF violation (DepartmentName depends on DepartmentID, not EmployeeID)
- D) BCNF violation

**Answer: C**

---

**Q210: Which of the following is NOT a benefit of normalization?** ★
- A) Reduced data redundancy
- B) Improved data integrity
- C) Faster queries for all cases
- D) Easier maintenance

**Answer: C**

---

**Q211: When would you consider denormalization?** ★★★
- A) When the database is too small
- B) When read performance is critical and writes are less frequent
- C) When you want to reduce storage space
- D) When you want to simplify the schema

**Answer: B**

---

**Q212: What is a functional dependency?** ★★
- A) A relationship between two tables
- B) A relationship where one attribute determines another
- C) A relationship between two databases
- D) A type of index

**Answer: B**

---

**Q213: [Scenario] A table has columns: StudentID, CourseID, InstructorName, InstructorOffice. The PK is (StudentID, CourseID). Which normal form violation exists?** ★★★
- A) 1NF
- B) 2NF (InstructorName depends on CourseID only)
- C) 3NF
- D) BCNF

**Answer: B**

---

**Q214: [Scenario] A table has columns: OrderID, CustomerID, CustomerName, CustomerAddress. Which normal form violation exists?** ★★★
- A) 1NF violation
- B) 2NF violation
- C) 3NF violation
- D) No violation

**Answer: C**

---

**Q215: What is a candidate key?** ★★
- A) A key that is not yet selected as primary key
- B) A column or set of columns that can uniquely identify a row
- C) A foreign key
- D) A key used for indexing

**Answer: B**

---

### Module 1.3: Table Design

**Q301: Which data type is best for storing currency values?** ★
- A) FLOAT
- B) DOUBLE
- C) DECIMAL/NUMERIC
- D) INTEGER

**Answer: C**

---

**Q302: Which data type is best for storing a person's name?** ★
- A) INTEGER
- B) VARCHAR(255)
- C) TEXT
- D) BOOLEAN

**Answer: B**

---

**Q303: What does VARCHAR(50) mean?** ★
- A) The column can store up to 50 characters
- B) The column stores exactly 50 characters
- C) The column stores 50 bits
- D) The column stores 50 different values

**Answer: A**

---

**Q304: Which data type is appropriate for storing a date with timezone?** ★
- A) DATE
- B) TIME
- C) TIMESTAMPTZ
- D) TIMESTAMP

**Answer: C**

---

**Q305: What is the purpose of a CHECK constraint?** ★
- A) To check if a table exists
- B) To validate data against a condition
- C) To check foreign key references
- D) To check indexes

**Answer: B**

---

**Q306: Which constraint enforces that a column cannot contain NULL values?** ★
- A) UNIQUE
- B) PRIMARY KEY
- C) NOT NULL
- D) FOREIGN KEY

**Answer: C**

---

**Q307: A UNIQUE constraint ensures:** ★
- A) All values in the column are the same
- B) All values in the column are different
- C) All values are NOT NULL
- D) The column is a foreign key

**Answer: B**

---

**Q308: What is the difference between VARCHAR and TEXT?** ★★
- A) TEXT is faster
- B) VARCHAR has a length limit, TEXT does not
- C) TEXT is always uppercase
- D) They are exactly the same

**Answer: B**

---

**Q309: Which data type is best for a YES/NO flag?** ★
- A) INTEGER
- B) VARCHAR(1)
- C) BOOLEAN
- D) BIT

**Answer: C**

---

**Q310: What is the default value for a column if not specified?** ★★
- A) 0
- B) NULL
- C) Empty string
- D) Depends on the data type

**Answer: B**

---

**Q311: [Scenario] You need to store product prices with 2 decimal places. Which data type should you use?** ★
- A) FLOAT
- B) DOUBLE
- C) NUMERIC(10,2)
- D) INTEGER

**Answer: C**

---

**Q312: Which data type is appropriate for storing a product description of varying length?** ★
- A) VARCHAR(20)
- B) VARCHAR(255)
- C) TEXT
- D) CHAR

**Answer: C**

---

**Q313: The ON DELETE CASCADE option means:** ★
- A) The foreign key is deleted
- B) When a parent row is deleted, child rows are also deleted
- C) The table is deleted
- D) The database is deleted

**Answer: B**

---

**Q314: [Scenario] In a customer-order relationship, which ON DELETE action should be used?** ★★
- A) CASCADE (if you want orders deleted when customer deleted)
- B) RESTRICT (prevent deletion of customer with orders)
- C) SET NULL
- D) SET DEFAULT

**Answer: B**

---

**Q315: What is a generated column?** ★★
- A) A column that is automatically numbered
- B) A column whose value is computed from other columns
- C) A column that is always NULL
- D) A column that cannot be updated

**Answer: B**

---

**Q316: [Scenario] You have a column 'weight' in pounds and need to display it in kilograms. Which approach is best?** ★★
- A) Store both values
- B) Store pounds and calculate kilograms in queries
- C) Use a generated column
- D) None of the above

**Answer: C**

---

**Q317: Which of the following is NOT a valid constraint?** ★
- A) PRIMARY KEY
- B) FOREIGN KEY
- C) CHECK
- D) SORT

**Answer: D**

---

**Q318: What is the purpose of a DEFAULT constraint?** ★
- A) To provide a default value when none is specified
- B) To set the column to NULL
- C) To create a primary key
- D) To enforce uniqueness

**Answer: A**

---

**Q319: In ScaleCart, the 'products' table uses which data type for 'price'?** ★
- A) FLOAT
- B) DECIMAL(10,2)
- C) INTEGER
- D) REAL

**Answer: B**

---

**Q320: In ScaleCart, the 'customers' table uses which column for optimistic locking?** ★
- A) id
- B) email
- C) version
- D) created_at

**Answer: C**

---

### Module 1.4: Indexes

**Q401: What is a database index?** ★
- A) A list of all tables
- B) A data structure that speeds up data retrieval
- C) A list of all rows
- D) A backup of the database

**Answer: B**

---

**Q402: Which analogy best describes an index?** ★
- A) A filing cabinet
- B) A phone book
- C) A spreadsheet
- D) A calculator

**Answer: B**

---

**Q403: The most common type of index is:** ★
- A) GIN
- B) B-Tree
- C) GiST
- D) Hash

**Answer: B**

---

**Q404: A B-Tree index is best for:** ★★
- A) Full-text search
- B) Equality and range queries
- C) Geospatial data
- D) Array operations

**Answer: B**

---

**Q405: Which index type is best for full-text search?** ★
- A) B-Tree
- B) GIN
- C) GiST
- D) BRIN

**Answer: B**

---

**Q406: What is a composite index?** ★
- A) An index on a composite key
- B) An index on multiple columns
- C) An index that combines two databases
- D) An index with multiple values

**Answer: B**

---

**Q407: What is a partial index?** ★★
- A) An index on part of a table
- B) An index on a subset of rows
- C) An index on part of a column
- D) An index that is not complete

**Answer: B**

---

**Q408: What is a covering index?** ★★
- A) An index that covers all columns in a table
- B) An index that includes all columns needed for a query
- C) An index that covers the entire database
- D) An index that is always used

**Answer: B**

---

**Q409: Which of the following is NOT a benefit of indexes?** ★
- A) Faster SELECT queries
- B) Faster INSERT operations
- C) Faster JOIN operations
- D) Faster ORDER BY

**Answer: B**

---

**Q410: What is the cost of having too many indexes?** ★
- A) Slower SELECT queries
- B) Slower INSERT/UPDATE/DELETE operations
- C) No cost
- D) Reduced storage

**Answer: B**

---

**Q411: [Scenario] A table with 10 million rows needs to be queried by a non-primary key column. The column has high selectivity. What should you do?** ★★★
- A) Create an index on that column
- B) Do nothing, it will be fine
- C) Create a composite index
- D) Partition the table

**Answer: A**

---

**Q412: [Scenario] A table with 10 million rows needs to be queried by a column with only 3 possible values (low selectivity). What should you do?** ★★★
- A) Create an index
- B) Do not create an index
- C) Create a composite index
- D) Use a bitmap index

**Answer: B**

---

**Q413: What is the purpose of VACUUM in PostgreSQL?** ★★
- A) To delete data
- B) To reclaim storage and update statistics
- C) To create indexes
- D) To backup the database

**Answer: B**

---

**Q414: What is pg_stat_statements?** ★★
- A) A monitoring tool for queries
- B) A backup tool
- C) A migration tool
- D) A data type

**Answer: A**

---

**Q415: [Scenario] A query is taking 5 seconds. EXPLAIN ANALYZE shows a sequential scan. What is the likely solution?** ★★★
- A) Add an index
- B) Add more memory
- C) Restart the database
- D) Delete some rows

**Answer: A**

---

**Q416: What is the GIN index type best for?** ★
- A) Equality queries
- B) Full-text search and array queries
- C) Geospatial queries
- D) Range queries

**Answer: B**

---

**Q417: What is the GiST index type best for?** ★
- A) Equality queries
- B) Full-text search
- C) Geospatial and nearest-neighbor queries
- D) Primary key lookups

**Answer: C**

---

**Q418: BRIN indexes are most effective on:** ★★
- A) Small tables
- B) Large tables with natural ordering
- C) Tables with random data
- D) Join tables

**Answer: B**

---

**Q419: The INCLUDE clause in a CREATE INDEX statement is used to:** ★★
- A) Include only specific rows
- B) Include extra columns in the index
- C) Include foreign keys
- D) Include constraints

**Answer: B**

---

**Q420: What is a partial index?** ★★
- A) CREATE INDEX ... WHERE condition
- B) CREATE INDEX ... INCLUDE column
- C) CREATE INDEX ... PARTIAL
- D) CREATE INDEX ... LIMIT

**Answer: A**

---

## PART 2: SQL PERFORMANCE & OPTIMIZATION

### Module 2.1: Query Execution

**Q501: What is a sequential scan?** ★
- A) Reading all rows of a table
- B) Reading rows using an index
- C) Reading rows in order
- D) Reading rows in parallel

**Answer: A**

---

**Q502: What is an index scan?** ★
- A) Reading all rows of a table
- B) Reading rows using an index
- C) Scanning the index structure
- D) Scanning the database

**Answer: B**

---

**Q503: Which is generally faster for a large table?** ★
- A) Sequential scan
- B) Index scan
- C) Both are the same
- D) Depends on the table

**Answer: B**

---

**Q504: What does the "cost" in EXPLAIN output represent?** ★★
- A) Actual execution time in seconds
- B) Estimated resource usage (in arbitrary units)
- C) The number of rows returned
- D) The cost in dollars

**Answer: B**

---

**Q505: In EXPLAIN ANALYZE output, what does "actual time" represent?** ★★
- A) Estimated time
- B) Actual execution time in milliseconds
- C) Time to first row
- D) Total query time

**Answer: B**

---

**Q506: What is a bitmap scan?** ★★
- A) A scan using a bitmap image
- B) A scan that combines multiple index scans
- C) A scan of bitmap indexes
- D) A visual scan

**Answer: B**

---

**Q507: Which join method builds a hash table of one table?** ★
- A) Nested Loop Join
- B) Hash Join
- C) Merge Join
- D) Sort Merge Join

**Answer: B**

---

**Q508: Which join method is best for small outer tables?** ★★
- A) Nested Loop Join
- B) Hash Join
- C) Merge Join
- D) Cross Join

**Answer: A**

---

**Q509: What is the purpose of ANALYZE in PostgreSQL?** ★
- A) To optimize queries
- B) To update statistics for the query planner
- C) To vacuum tables
- D) To reindex tables

**Answer: B**

---

**Q510: How do you view the execution plan of a query in PostgreSQL?** ★
- A) EXECUTE PLAN
- B) EXPLAIN
- C) ANALYZE PLAN
- D) VIEW PLAN

**Answer: B**

---

**Q511: [Scenario] A query is slow but EXPLAIN shows an index scan. What could be the issue?** ★★★
- A) The index is corrupted
- B) The query returns many rows
- C) The table is too small
- D) The database is too large

**Answer: B**

---

**Q512: What does "Rows Removed by Filter" indicate?** ★★
- A) Rows that were deleted
- B) Rows that didn't match the WHERE condition
- C) Rows that were indexed
- D) Rows that were updated

**Answer: B**

---

**Q513: What is a covering index scan?** ★★
- A) An index scan that also updates the table
- B) An index scan that reads only from the index
- C) An index scan that covers all tables
- D) An index scan that is hidden

**Answer: B**

---

**Q514: [Scenario] A query returns 100 rows from a table with 1 million rows. The EXPLAIN shows a sequential scan taking 500ms. What is the likely solution?** ★★★
- A) Add an index
- B) Use a different query
- C) Partition the table
- D) Increase memory

**Answer: A**

---

**Q515: What is the difference between EXPLAIN and EXPLAIN ANALYZE?** ★★
- A) No difference
- B) EXPLAIN ANALYZE actually executes the query
- C) EXPLAIN is for indexes only
- D) ANALYZE is for vacuum

**Answer: B**

---

### Module 2.2: Performance Optimization

**Q601: Which of the following can make a query slow?** ★
- A) No indexes
- B) Large result sets
- C) Complex joins
- D) All of the above

**Answer: D**

---

**Q602: What is a correlated subquery?** ★★
- A) A subquery that is independent
- B) A subquery that references columns from the outer query
- C) A subquery that is always fast
- D) A subquery that uses indexes

**Answer: B**

---

**Q603: Why are correlated subqueries often slow?** ★★
- A) They can't use indexes
- B) They run once for each row in the outer query
- C) They are always complex
- D) They use too much memory

**Answer: B**

---

**Q604: How can you optimize a query with a correlated subquery?** ★★
- A) Use a JOIN instead
- B) Use a window function
- C) Use a materialized view
- D) All of the above

**Answer: D**

---

**Q605: Why is "SELECT *" generally not recommended?** ★
- A) It's slower to write
- B) It returns all columns, including unnecessary ones
- C) It can't use indexes
- D) It's not standard SQL

**Answer: B**

---

**Q606: Why does "LIKE '%text'" not use an index?** ★★
- A) The leading wildcard prevents index usage
- B) It's too complex
- C) Indexes only work on equals
- D) It's not a valid query

**Answer: A**

---

**Q607: What is a materialized view?** ★★
- A) A view that stores data physically
- B) A view that is always up-to-date
- C) A view that is only for reporting
- D) A view that uses materialized data

**Answer: A**

---

**Q608: When should you use a materialized view?** ★★
- A) For frequently used aggregations
- B) For real-time data
- C) For small tables
- D) For all views

**Answer: A**

---

**Q609: What is the purpose of query caching?** ★
- A) To store query results for reuse
- B) To store query text
- C) To store execution plans
- D) To store database backups

**Answer: A**

---

**Q610: Which of the following can improve query performance?** ★
- A) Using indexes
- B) Limiting result sets
- C) Optimizing joins
- D) All of the above

**Answer: D**

---

**Q611: [Scenario] A query joins 5 tables and is slow. How can it be optimized?** ★★★
- A) Index all foreign keys
- B) Use materialized views
- C) Reduce the number of joins if possible
- D) All of the above

**Answer: D**

---

**Q612: What is query plan caching?** ★★
- A) Storing query results
- B) Storing query execution plans
- C) Storing query text
- D) Storing database schema

**Answer: B**

---

**Q613: How can you force a query to use a specific index?** ★★
- A) USE INDEX
- B) HINT
- C) FORCE INDEX
- D) It's not recommended

**Answer: D**

---

**Q614: [Scenario] A query with ORDER BY is slow. What is the likely solution?** ★★★
- A) Add an index on the ORDER BY column
- B) Remove the ORDER BY
- C) Use a different query
- D) Increase memory

**Answer: A**

---

**Q615: What is the "N+1" query problem?** ★★
- A) One query plus N more
- B) An ORM pattern causing many queries
- C) A slow query pattern
- D) All of the above

**Answer: D**

---

### Module 2.3: Scaling & Partitioning

**Q701: What is table partitioning?** ★
- A) Splitting a table into multiple tables
- B) Dividing a table into smaller pieces
- C) Creating multiple databases
- D) Adding more indexes

**Answer: B**

---

**Q702: Which partition method is best for time-series data?** ★
- A) Range partitioning
- B) List partitioning
- C) Hash partitioning
- D) Round-robin

**Answer: A**

---

**Q703: What is partition pruning?** ★★
- A) Removing partitions
- B) The query optimizer only scanning relevant partitions
- C) Deleting old partitions
- D) Compressing partitions

**Answer: B**

---

**Q704: How does partitioning improve query performance?** ★
- A) By reducing the amount of data scanned
- B) By adding indexes
- C) By compressing data
- D) By caching data

**Answer: A**

---

**Q705: What is the difference between partitioning and sharding?** ★★
- A) Partitioning is within one database, sharding is across multiple
- B) Partitioning is for small data, sharding is for large data
- C) They are the same
- D) Partitioning is faster

**Answer: A**

---

**Q706: What is a read replica?** ★
- A) A copy of the database for reads
- B) A backup database
- C) A database for writes
- D) A test database

**Answer: A**

---

**Q707: Read replicas are useful for:** ★
- A) Improving read performance
- B) Improving write performance
- C) Backup and recovery
- D) All of the above

**Answer: A**

---

**Q708: What is the CAP theorem?** ★★
- A) Consistency, Availability, Partition tolerance
- B) Cost, Access, Performance
- C) Capacity, Availability, Performance
- D) Consistency, Access, Partition

**Answer: A**

---

**Q709: In the CAP theorem, what does "Availability" mean?** ★
- A) The system is always on
- B) Every request receives a response
- C) The system has backups
- D) The system is fast

**Answer: B**

---

**Q710: A CP system prioritizes:** ★★
- A) Consistency and Partition tolerance
- B) Availability and Partition tolerance
- C) Consistency and Availability
- D) Performance and Scalability

**Answer: A**

---

**Q711: Which systems are typically AP?** ★★
- A) NoSQL systems like Cassandra
- B) Relational databases like PostgreSQL
- C) Both
- D) Neither

**Answer: A**

---

**Q712: What is eventual consistency?** ★
- A) The system is always consistent
- B) The system becomes consistent over time
- C) The system is never consistent
- D) The system is only partially consistent

**Answer: B**

---

**Q713: [Scenario] An e-commerce system needs to handle 100 million orders. What approach is best?** ★★★
- A) Partition orders by date
- B) Use a read replica
- C) Shard by customer ID
- D) All of the above

**Answer: D**

---

**Q714: What is a hot spot in sharding?** ★★
- A) A shard that is overheating
- B) A shard with disproportionate traffic
- C) A shard that is too large
- D) A shard that has failed

**Answer: B**

---

**Q715: How can you avoid hot spots in sharding?** ★★★
- A) Use consistent hashing
- B) Use range-based sharding
- C) Use a single shard
- D) Random assignment

**Answer: A**

---

## PART 3: TRANSACTIONS & CONCURRENCY

### Module 3.1: ACID Transactions

**Q801: What does the "A" in ACID stand for?** ★
- A) Availability
- B) Atomicity
- C) Automation
- D) Accuracy

**Answer: B**

---

**Q802: What does the "C" in ACID stand for?** ★
- A) Consistency
- B) Concurrency
- C) Correctness
- D) Completeness

**Answer: A**

---

**Q803: What does the "I" in ACID stand for?** ★
- A) Isolation
- B) Integrity
- C) Independence
- D) Idempotence

**Answer: A**

---

**Q804: What does the "D" in ACID stand for?** ★
- A) Durability
- B) Data
- C) Density
- D) Double

**Answer: A**

---

**Q805: What happens when you COMMIT a transaction?** ★
- A) All changes are undone
- B) All changes are made permanent
- C) The transaction pauses
- D) The database restarts

**Answer: B**

---

**Q806: What happens when you ROLLBACK a transaction?** ★
- A) All changes are saved
- B) All changes are undone
- C) The transaction pauses
- D) The database restarts

**Answer: B**

---

**Q807: What is the WAL (Write-Ahead Log)?** ★★
- A) A log that records changes before they are written to disk
- B) A log that records all queries
- C) A log that records backups
- D) A log that records errors

**Answer: A**

---

**Q808: Why is WAL important for durability?** ★★
- A) It makes queries faster
- B) It allows recovery after crashes
- C) It reduces storage
- D) It improves concurrency

**Answer: B**

---

**Q809: [Scenario] A transaction transfers $100 from Account A to Account B. After the first UPDATE but before the second, the system crashes. What happens?** ★★★
- A) Money is lost
- B) Money is duplicated
- C) Money is not transferred
- D) Account B gets the money

**Answer: C**

---

**Q810: [Scenario] In a banking system, what is the consequence of not using transactions?** ★★★
- A) Money can be lost or duplicated
- B) The system is faster
- C) The system is simpler
- D) No consequence

**Answer: A**

---

**Q811: A SAVEPOINT allows:** ★★
- A) Rolling back part of a transaction
- B) Saving the entire transaction
- C) Saving the database
- D) Saving the query

**Answer: A**

---

**Q812: Which statement is true about transactions?** ★
- A) Transactions should be as long as possible
- B) Transactions should be as short as possible
- C) Transactions should be exactly 5 operations
- D) Transactions should be avoided

**Answer: B**

---

**Q813: What is a distributed transaction?** ★★
- A) A transaction across multiple databases
- B) A transaction across multiple tables
- C) A transaction with multiple steps
- D) A transaction with multiple users

**Answer: A**

---

**Q814: What is the Saga pattern?** ★★
- A) A pattern for distributed transactions
- B) A pattern for data modeling
- C) A pattern for indexing
- D) A pattern for caching

**Answer: A**

---

**Q815: In the Saga pattern, what is a compensating transaction?** ★★
- A) A transaction that compensates for failure
- B) A transaction that runs faster
- C) A transaction that uses less memory
- D) A transaction that is smaller

**Answer: A**

---

### Module 3.2: Concurrency Control

**Q901: What is a dirty read?** ★
- A) Reading data from a dirty table
- B) Reading uncommitted data from another transaction
- C) Reading data that has been deleted
- D) Reading data from the wrong database

**Answer: B**

---

**Q902: What is a non-repeatable read?** ★
- A) Reading the same data multiple times with different results
- B) Reading data that doesn't exist
- C) Reading data that is corrupted
- D) Reading data from multiple tables

**Answer: A**

---

**Q903: What is a phantom read?** ★
- A) Reading data that appears and disappears
- B) Reading data from ghosts
- C) Reading data that is corrupted
- D) Reading data that is encrypted

**Answer: A**

---

**Q904: Which isolation level prevents dirty reads?** ★★
- A) READ UNCOMMITTED
- B) READ COMMITTED
- C) Both
- D) Neither

**Answer: B**

---

**Q905: Which isolation level is the default in PostgreSQL?** ★
- A) READ UNCOMMITTED
- B) READ COMMITTED
- C) REPEATABLE READ
- D) SERIALIZABLE

**Answer: B**

---

**Q906: Which isolation level provides the strongest consistency?** ★
- A) READ UNCOMMITTED
- B) READ COMMITTED
- C) REPEATABLE READ
- D) SERIALIZABLE

**Answer: D**

---

**Q907: What is optimistic locking?** ★
- A) Locking data before accessing it
- B) Checking for conflicts before committing
- C) Assuming no conflicts
- D) Locking the entire table

**Answer: B**

---

**Q908: What is pessimistic locking?** ★
- A) Locking data before accessing it
- B) Checking for conflicts after committing
- C) Assuming conflicts will happen
- D) Both A and C

**Answer: D**

---

**Q909: What is a deadlock?** ★
- A) Two transactions waiting for each other
- B) A transaction that never completes
- C) A database that has crashed
- D) A lock that cannot be released

**Answer: A**

---

**Q910: How can you avoid deadlocks?** ★★
- A) Always lock in the same order
- B) Keep transactions short
- C) Use appropriate isolation levels
- D) All of the above

**Answer: D**

---

**Q911: What does SELECT FOR UPDATE do?** ★★
- A) Reads data for later update
- B) Locks rows for update
- C) Updates rows immediately
- D) Selects rows for deletion

**Answer: B**

---

**Q912: What is the difference between FOR UPDATE and FOR SHARE?** ★★
- A) FOR UPDATE locks for writes, FOR SHARE locks for reads
- B) FOR UPDATE is faster
- C) FOR SHARE locks for writes
- D) No difference

**Answer: A**

---

**Q913: [Scenario] Two transactions try to update the same inventory row simultaneously. What is the best approach?** ★★★
- A) Use FOR UPDATE
- B) Use optimistic locking
- C) Use SERIALIZABLE isolation
- D) Any of the above

**Answer: D**

---

**Q914: What is the purpose of SKIP LOCKED?** ★★
- A) To skip locked rows
- B) To skip all rows
- C) To skip errors
- D) To skip transactions

**Answer: A**

---

**Q915: [Scenario] A queue processing system needs to process pending orders. What locking strategy should be used?** ★★★
- A) FOR UPDATE SKIP LOCKED
- B) FOR SHARE
- C) No locking
- D) Table locks

**Answer: A**

---

### Module 3.3: Zero-Downtime Changes

**Q1001: What is a zero-downtime migration?** ★
- A) A migration that doesn't take any time
- B) A migration that doesn't cause downtime
- C) A migration that is fast
- D) A migration that doesn't change data

**Answer: B**

---

**Q1002: Why are database migrations challenging?** ★
- A) They can lock tables
- B) They can affect performance
- C) They can fail
- D) All of the above

**Answer: D**

---

**Q1003: CREATE INDEX CONCURRENTLY does what?** ★★
- A) Creates an index without locking
- B) Creates an index quickly
- C) Creates an index on all tables
- D) Creates an index concurrently with other operations

**Answer: A**

---

**Q1004: What is a backward-compatible change?** ★★
- A) A change that works with old code
- B) A change that is rolled back
- C) A change that is backward-looking
- D) A change that is slow

**Answer: A**

---

**Q1005: In a blue-green deployment, what is the "blue" environment?** ★★
- A) The new environment
- B) The old environment
- C) The test environment
- D) The production environment

**Answer: B**

---

**Q1006: In a blue-green deployment, what is the "green" environment?** ★★
- A) The new environment
- B) The old environment
- C) The test environment
- D) The production environment

**Answer: A**

---

**Q1007: What is a canary deployment?** ★★
- A) Deploying to all users at once
- B) Gradual deployment to a small subset first
- C) Deploying to test environment only
- D) No deployment

**Answer: B**

---

**Q1008: What is the purpose of feature flags?** ★
- A) To enable/disable features without code changes
- B) To add new features
- C) To remove features
- D) To test features

**Answer: A**

---

**Q1009: [Scenario] You need to add a NOT NULL column to a table with 10 million rows. What is the best approach?** ★★★
- A) Add the column with a DEFAULT
- B) Add the column without DEFAULT, then update in batches
- C) Create a new table with the column
- D) Use a different approach

**Answer: B**

---

**Q1010: When dropping a column, what is the recommended process?** ★★
- A) Drop it immediately
- B) First ensure no code uses it
- C) Drop it during low traffic
- D) Always keep it

**Answer: B**

---

**Q1011: What is the purpose of a migration rollback plan?** ★
- A) To revert changes if needed
- B) To make migrations faster
- C) To test migrations
- D) To document changes

**Answer: A**

---

**Q1012: In Zero-Downtime migrations, what is the "expand and contract" pattern?** ★★★
- A) Add then remove
- B) Add columns, update code, remove old columns
- C) Expand the table, then contract it
- D) Add indexes, then remove them

**Answer: B**

---

**Q1013: [Scenario] You need to rename a column used by a live application. What is the safest approach?** ★★★
- A) Rename the column
- B) Add a new column, update code, drop old column
- C) Drop the column
- D) Do nothing

**Answer: B**

---

**Q1014: What is the risk of long-running migrations?** ★
- A) They can cause downtime
- B) They are slower
- C) They are harder to test
- D) All of the above

**Answer: A**

---

**Q1015: What is the purpose of staging environment testing?** ★
- A) To test changes before production
- B) To show stakeholders
- C) To make changes faster
- D) To backup data

**Answer: A**

---

## PART 4: MODERN DATA ARCHITECTURES

### Module 4.1: NoSQL

**Q1101: What does NoSQL stand for?** ★
- A) No SQL
- B) Not Only SQL
- C) New SQL
- D) Network SQL

**Answer: B**

---

**Q1102: Which of the following is a document database?** ★
- A) Redis
- B) MongoDB
- C) Neo4j
- D) Cassandra

**Answer: B**

---

**Q1103: Which of the following is a key-value store?** ★
- A) MongoDB
- B) PostgreSQL
- C) Redis
- D) Neo4j

**Answer: C**

---

**Q1104: Which of the following is a graph database?** ★
- A) MongoDB
- B) PostgreSQL
- C) Redis
- D) Neo4j

**Answer: D**

---

**Q1105: Which of the following is a wide-column store?** ★
- A) Cassandra
- B) MongoDB
- C) Redis
- D) Neo4j

**Answer: A**

---

**Q1106: When should you use a document database?** ★★
- A) For structured, consistent data
- B) For flexible, semi-structured data
- C) For simple key-value lookups
- D) For complex relationships

**Answer: B**

---

**Q1107: When should you use a key-value store?** ★★
- A) For complex queries
- B) For caching and session storage
- C) For relationships
- D) For document storage

**Answer: B**

---

**Q1108: When should you use a graph database?** ★★
- A) For document storage
- B) For highly connected data
- C) For key-value lookups
- D) For columnar data

**Answer: B**

---

**Q1109: What is polyglot persistence?** ★★
- A) Using multiple programming languages
- B) Using multiple database technologies
- C) Using multiple servers
- D) Using multiple storage formats

**Answer: B**

---

**Q1110: In ScaleCart, Redis is used for:** ★
- A) Primary data storage
- B) Caching and sessions
- C) Graph relationships
- D) Document storage

**Answer: B**

---

**Q1111: In ScaleCart, Neo4j is used for:** ★
- A) Primary data storage
- B) Caching
- C) Graph relationships and recommendations
- D) Document storage

**Answer: C**

---

**Q1112: What is a JSON document in MongoDB?** ★
- A) A table row
- B) A collection of key-value pairs
- C) An index
- D) A database

**Answer: B**

---

**Q1113: What is a collection in MongoDB?** ★
- A) A database
- B) A table equivalent
- C) An index
- D) A document

**Answer: B**

---

**Q1114: What is the advantage of document databases over relational?** ★★
- A) Stronger consistency
- B) Flexible schema
- C) Better joins
- D) ACID transactions

**Answer: B**

---

**Q1115: What is the advantage of key-value stores?** ★
- A) Complex queries
- B) Very fast lookups
- C) Relationships
- D) ACID transactions

**Answer: B**

---

**Q1116: What is the advantage of graph databases?** ★
- A) Fast document retrieval
- B) Efficient relationship traversal
- C) Simple key-value lookups
- D) Columnar storage

**Answer: B**

---

**Q1117: [Scenario] You need to build a recommendation engine. Which database type is best?** ★★★
- A) Document database
- B) Graph database
- C) Key-value store
- D) Relational database

**Answer: B**

---

**Q1118: [Scenario] You need to store user session data that expires after 1 hour. Which database type is best?** ★★★
- A) Document database
- B) Graph database
- C) Key-value store with TTL
- D) Relational database

**Answer: C**

---

**Q1119: [Scenario] You need to store a product catalog with varying attributes per product. Which database type is best?** ★★★
- A) Document database
- B) Relational database
- C) Graph database
- D) Key-value store

**Answer: A**

---

**Q1120: What is a time-series database best for?** ★
- A) Storing unstructured data
- B) Storing time-stamped data
- C) Storing relationships
- D) Storing documents

**Answer: B**

---

### Module 4.2: Distributed Systems

**Q1201: The CAP theorem states that you can have:** ★
- A) Consistency, Availability, Partition tolerance
- B) Any two of the three
- C) All three
- D) Only one

**Answer: B**

---

**Q1202: In the CAP theorem, what is Partition tolerance?** ★
- A) The system handles network partitions
- B) The system partitions data
- C) The system has backups
- D) The system is fast

**Answer: A**

---

**Q1203: A CA system prioritizes:** ★★
- A) Consistency and Availability
- B) Availability and Partition tolerance
- C) Consistency and Partition tolerance
- D) Performance and Scalability

**Answer: A**

---

**Q1204: Which type of system is typically CP?** ★★
- A) Key-value stores
- B) Relational databases with strong consistency
- C) Document databases
- D) Cache systems

**Answer: B**

---

**Q1205: What is the Transactional Outbox pattern?** ★★
- A) A pattern for storing transactions
- B) A pattern for reliable event publishing
- C) A pattern for data modeling
- D) A pattern for indexing

**Answer: B**

---

**Q1206: The outbox pattern solves:** ★★
- A) Data storage issues
- B) Reliable event delivery
- C) Query performance
- D) Data modeling

**Answer: B**

---

**Q1207: In the outbox pattern, events are stored:** ★
- A) In a separate database
- B) In the same transaction as the business operation
- C) In memory
- D) In a file

**Answer: B**

---

**Q1208: What is event-driven architecture?** ★
- A) Architecture driven by events
- B) Architecture where events are the primary means of communication
- C) Architecture with event handlers
- D) All of the above

**Answer: D**

---

**Q1209: What is eventual consistency?** ★
- A) The system is always consistent
- B) The system becomes consistent over time
- C) The system is never consistent
- D) The system is only partially consistent

**Answer: B**

---

**Q1210: [Scenario] A distributed system has high availability but may have stale data. This is an example of:** ★★
- A) Strong consistency
- B) Eventual consistency
- C) No consistency
- D) Immediate consistency

**Answer: B**

---

**Q1211: What is the difference between event choreography and orchestration?** ★★
- A) Choreography is decentralized, orchestration is centralized
- B) Orchestration is decentralized, choreography is centralized
- C) They are the same
- D) Both are centralized

**Answer: A**

---

**Q1212: What is a compensating transaction in the Saga pattern?** ★★
- A) A transaction that undoes a previous transaction
- B) A transaction that pays for the operation
- C) A transaction that is faster
- D) A transaction that is smaller

**Answer: A**

---

**Q1213: [Scenario] In a distributed order system, what is the best way to handle failures?** ★★★
- A) Use a Saga pattern
- B) Use a two-phase commit
- C) Use a single transaction
- D) Use no transaction

**Answer: A**

---

**Q1214: What is the purpose of idempotency in distributed systems?** ★★
- A) To handle duplicate operations
- B) To make operations faster
- C) To reduce storage
- D) To improve security

**Answer: A**

---

**Q1215: What is a message broker?** ★
- A) A system that handles messages between services
- B) A database for messages
- C) A type of cache
- D) A type of index

**Answer: A**

---

## ANSWER KEY — COMPLETE SUMMARY

| Question | Answer | Question | Answer | Question | Answer |
|----------|--------|----------|--------|----------|--------|
| Q001 | B | Q101 | B | Q201 | B |
| Q002 | D | Q102 | C | Q202 | B |
| Q003 | B | Q103 | B | Q203 | A |
| Q004 | B | Q104 | A | Q204 | A |
| Q005 | B | Q105 | D | Q205 | D |
| Q006 | B | Q106 | A | Q206 | C |
| Q007 | B | Q107 | B | Q207 | B |
| Q008 | A | Q108 | A | Q208 | B |
| Q009 | B | Q109 | B | Q209 | C |
| Q010 | B | Q110 | B | Q210 | C |
| Q011 | C | Q111 | B | Q211 | B |
| Q012 | D | Q112 | B | Q212 | B |
| Q013 | B | Q113 | B | Q213 | B |
|      |   | Q114 | D | Q214 | C |
|      |   | Q115 | C | Q215 | B |

| Question | Answer | Question | Answer | Question | Answer |
|----------|--------|----------|--------|----------|--------|
| Q301 | C | Q401 | B | Q501 | A |
| Q302 | B | Q402 | B | Q502 | B |
| Q303 | A | Q403 | B | Q503 | B |
| Q304 | C | Q404 | B | Q504 | B |
| Q305 | B | Q405 | B | Q505 | B |
| Q306 | C | Q406 | B | Q506 | B |
| Q307 | B | Q407 | B | Q507 | B |
| Q308 | B | Q408 | B | Q508 | A |
| Q309 | C | Q409 | B | Q509 | B |
| Q310 | B | Q410 | B | Q510 | B |
| Q311 | C | Q411 | A | Q511 | B |
| Q312 | C | Q412 | B | Q512 | B |
| Q313 | B | Q413 | B | Q513 | B |
| Q314 | B | Q414 | A | Q514 | A |
| Q315 | B | Q415 | A | Q515 | B |
| Q316 | C | Q416 | B |      |   |
| Q317 | D | Q417 | C |      |   |
| Q318 | A | Q418 | B |      |   |
| Q319 | B | Q419 | B |      |   |
| Q320 | C | Q420 | A |      |   |

| Question | Answer | Question | Answer | Question | Answer |
|----------|--------|----------|--------|----------|--------|
| Q601 | D | Q701 | B | Q801 | B |
| Q602 | B | Q702 | A | Q802 | A |
| Q603 | B | Q703 | B | Q803 | A |
| Q604 | D | Q704 | A | Q804 | A |
| Q605 | B | Q705 | A | Q805 | B |
| Q606 | A | Q706 | A | Q806 | B |
| Q607 | A | Q707 | D | Q807 | A |
| Q608 | A | Q708 | A | Q808 | B |
| Q609 | A | Q709 | B | Q809 | C |
| Q610 | D | Q710 | A | Q810 | A |
| Q611 | D | Q711 | A | Q811 | A |
| Q612 | B | Q712 | B | Q812 | B |
| Q613 | D | Q713 | D | Q813 | A |
| Q614 | A | Q714 | B | Q814 | A |
| Q615 | D | Q715 | A | Q815 | A |

| Question | Answer | Question | Answer | Question | Answer |
|----------|--------|----------|--------|----------|--------|
| Q901 | B | Q1001 | B | Q1101 | B |
| Q902 | A | Q1002 | D | Q1102 | B |
| Q903 | A | Q1003 | A | Q1103 | C |
| Q904 | B | Q1004 | A | Q1104 | D |
| Q905 | B | Q1005 | B | Q1105 | A |
| Q906 | D | Q1006 | A | Q1106 | B |
| Q907 | B | Q1007 | B | Q1107 | B |
| Q908 | D | Q1008 | A | Q1108 | B |
| Q909 | A | Q1009 | B | Q1109 | B |
| Q910 | D | Q1010 | B | Q1110 | B |
| Q911 | B | Q1011 | A | Q1111 | C |
| Q912 | A | Q1012 | B | Q1112 | B |
| Q913 | D | Q1013 | B | Q1113 | B |
| Q914 | A | Q1014 | A | Q1114 | B |
| Q915 | A | Q1015 | A | Q1115 | B |
|      |   |      |   | Q1116 | B |
|      |   |      |   | Q1117 | B |
|      |   |      |   | Q1118 | C |
|      |   |      |   | Q1119 | A |
|      |   |      |   | Q1120 | B |

| Question | Answer |
|----------|--------|
| Q1201 | B |
| Q1202 | A |
| Q1203 | A |
| Q1204 | B |
| Q1205 | B |
| Q1206 | B |
| Q1207 | B |
| Q1208 | D |
| Q1209 | B |
| Q1210 | B |
| Q1211 | A |
| Q1212 | A |
| Q1213 | A |
| Q1214 | A |
| Q1215 | A |

---

## EXAMINATION TIPS

### For Students:
1. **Understand concepts, not just memorize** – The best answers come from understanding the "why" behind each concept.

2. **Practice with the code** – The most challenging questions often involve scenario-based problems. Run the queries yourself!

3. **Connect the dots** – Many questions across modules are connected. Normalization affects performance, which affects indexing, which affects transactions, etc.

4. **Use the ScaleCart examples** – Most scenario questions are based on the ScaleCart application. Understanding the application makes these questions easier.

5. **Draw diagrams** – For ERD and normalization questions, drawing out the tables helps visualize the relationships.

### For Instructors:
1. **Mix difficulty levels** – Include both basic recall and complex scenario questions.

2. **Group questions by topic** – This helps identify weak areas.

3. **Use open-ended questions** – Multiple choice is good for knowledge, but scenario questions test true understanding.

4. **Code-along with students** – The best learning happens when students actually write SQL.

5. **Encourage discussion** – Many database design questions don't have a single "right" answer. Discuss the trade-offs.

---

**[END OF QUIZ & QUESTION BANK]**

*This comprehensive question bank covers all modules of the Mastering Modern Database Design series. Use it for self-assessment, classroom teaching, or certification preparation.*
