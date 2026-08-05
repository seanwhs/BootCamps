# Comprehensive Quiz and Test Bank: Master SQLite — From Fundamentals to Production Systems

This document provides a complete bank of questions for assessing knowledge across the entire course. It includes:

- **Multiple Choice Questions (MCQs)** – Test conceptual understanding
- **True/False Questions** – Test factual accuracy
- **Fill‑in‑the‑Blank** – Test recall of key terms
- **Short Answer Questions** – Test explanation and reasoning
- **Hands‑On Exercises (Code & SQL)** – Test practical skills

Each question is tagged with the relevant **Part** and **Module** for easy reference. An **Answer Key** is provided at the end of each section.

---

## Part 0: Introduction — Setting the Stage

### MCQ
1. **What is the primary architectural characteristic of SQLite?**
   - A) Client‑server model with a dedicated database server
   - B) Embedded library that runs in‑process with the application
   - C) Cloud‑native database with automatic scaling
   - D) Distributed database with sharding
   *Answer: B*

2. **Which of the following is NOT a typical use case for SQLite?**
   - A) Mobile applications
   - B) High‑throughput OLTP systems with millions of concurrent writes
   - C) Desktop applications
   - D) Embedded IoT devices
   *Answer: B*

### True/False
3. **SQLite requires a separate server process to handle database operations.**  
   *Answer: False*

4. **A SQLite database is stored as a single ordinary file on disk.**  
   *Answer: True*

### Fill‑in‑the‑Blank
5. The SQLite library is approximately ______ in size, making it extremely lightweight.  
   *Answer: 600 KB*

### Short Answer
6. List three reasons why SQLite is the most widely deployed database engine in the world.  
   *Answer:* (1) Zero‑configuration, no setup required; (2) Serverless, no network overhead; (3) Portable, self‑contained single file; (4) Reliable, ACID compliant; (5) Extremely lightweight (~600KB).

---

## Part 1: SQLite Foundations & Internal Architecture

### Module 1: Introduction to SQLite

**MCQ**
7. **Which command is used to start the SQLite command‑line shell and open a database file named `mydb.db`?**
   - A) `sqlite open mydb.db`
   - B) `sqlite3 mydb.db`
   - C) `start sqlite mydb.db`
   - D) `sqlite --open mydb.db`
   *Answer: B*

8. **What does the `.databases` dot‑command display?**
   - A) All tables in the current database
   - B) The file paths of all attached databases
   - C) The schema of the main database
   - D) The current PRAGMA settings
   *Answer: B*

**Fill‑in‑the‑Blank**
9. The special mode that creates a temporary database that exists only in memory is accessed by using the filename ______.  
   *Answer: `:memory:`*

### Module 2: SQLite Architecture

**MCQ**
10. **Which component of SQLite is responsible for executing bytecode instructions generated from SQL?**
    - A) Parser
    - B) Code Generator
    - C) VDBE (Virtual Database Engine)
    - D) Pager
    *Answer: C*

11. **The B‑Tree storage engine in SQLite provides which complexity for key lookups?**
    - A) O(1)
    - B) O(n)
    - C) O(log n)
    - D) O(n²)
    *Answer: C*

**True/False**
12. **SQLite uses a five‑state locking protocol to manage concurrency.**  
    *Answer: True*

**Short Answer**
13. Explain the role of the Pager subsystem in SQLite's architecture.  
    *Answer:* The Pager manages reading and writing pages to disk, maintains the page cache, and handles transaction journaling (rollback or WAL) for crash recovery.

### Module 3: Data Types & Storage

**MCQ**
14. **Which of the following is NOT a SQLite storage class?**
    - A) INTEGER
    - B) REAL
    - C) DECIMAL
    - D) TEXT
    *Answer: C*

15. **If a column is declared as `VARCHAR(255)`, what type affinity is assigned?**
    - A) INTEGER
    - B) TEXT
    - C) REAL
    - D) NUMERIC
    *Answer: B*

**True/False**
16. **SQLite enforces strict type checking on columns; you cannot insert a TEXT value into an INTEGER column.**  
    *Answer: False*

**Hands‑On (SQL)**
17. Write a SQL statement to create a table `test` with columns `id INTEGER PRIMARY KEY`, `a TEXT`, `b INTEGER`. Then insert a row with `a = '123'` and `b = '456'`. Write a query to show the `typeof(a)` and `typeof(b)`.  
    *Expected code:*
    ```sql
    CREATE TABLE test (id INTEGER PRIMARY KEY, a TEXT, b INTEGER);
    INSERT INTO test (a, b) VALUES ('123', '456');
    SELECT typeof(a), typeof(b) FROM test;
    ```
    *Answer: `typeof(a)` returns `'text'`; `typeof(b)` returns `'integer'` (converted from `'456'`).*

### Module 4: Creating and Managing Tables

**MCQ**
18. **Which constraint ensures that a column's value must be unique across the table and cannot be NULL?**
    - A) UNIQUE
    - B) PRIMARY KEY
    - C) FOREIGN KEY
    - D) CHECK
    *Answer: B*

19. **What is the purpose of a generated column?**
    - A) To automatically increment the primary key
    - B) To store a value computed from other columns
    - C) To enforce a foreign key relationship
    - D) To create an index on a column
    *Answer: B*

**Fill‑in‑the‑Blank**
20. To enable foreign key constraint enforcement, you must execute the PRAGMA statement: ______.  
    *Answer: `PRAGMA foreign_keys = ON;`*

**Hands‑On**
21. Write a `CREATE TABLE` statement for a `books` table with columns: `book_id` (primary key, auto‑increment), `title` (not null), `isbn` (unique, not null), `year` (check > 0), and a generated column `full_title` that concatenates title and year in parentheses.  
    *Answer:*
    ```sql
    CREATE TABLE books (
        book_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isbn TEXT UNIQUE NOT NULL,
        year INTEGER CHECK (year > 0),
        full_title TEXT GENERATED ALWAYS AS (title || ' (' || year || ')') STORED
    );
    ```

---

## Part 2: SQL Programming Essentials

### Module 5: CRUD Operations

**MCQ**
22. **Which SQL statement is used to retrieve data from a database?**
    - A) INSERT
    - B) UPDATE
    - C) SELECT
    - D) DELETE
    *Answer: C*

23. **To retrieve only the top 10 rows from a query, you would use:**
    - A) `TOP 10`
    - B) `LIMIT 10`
    - C) `ROWNUM <= 10`
    - D) `FETCH FIRST 10 ROWS ONLY`
    *Answer: B*

**True/False**
24. **Without a `WHERE` clause, an `UPDATE` statement will update all rows in the table.**  
    *Answer: True*

**Hands‑On**
25. Write a SQL query that selects `name` and `email` from a `customers` table, orders by `name` descending, and shows only the second page of results (assuming 10 results per page).  
    *Answer:* `SELECT name, email FROM customers ORDER BY name DESC LIMIT 10 OFFSET 10;`

### Module 6: Filtering and Expressions

**MCQ**
26. **Which operator is used for pattern matching with wildcards in SQLite?**
    - A) `LIKE`
    - B) `MATCH`
    - C) `REGEXP`
    - D) `SIMILAR`
    *Answer: A*

27. **What does the `CASE` expression do?**
    - A) Replaces NULL values
    - B) Implements conditional logic in SQL
    - C) Concatenates strings
    - D) Converts data types
    *Answer: B*

**Short Answer**
28. Explain the difference between `LIKE` and `GLOB` in SQLite.  
    *Answer:* `LIKE` is case‑insensitive for ASCII characters and uses `%` and `_` wildcards. `GLOB` is case‑sensitive and uses Unix‑style `*` and `?` wildcards.

### Module 7: Joins & Relationships

**MCQ**
29. **Which join returns all rows from the left table and matching rows from the right table, with NULLs for non‑matching right rows?**
    - A) INNER JOIN
    - B) LEFT JOIN
    - C) CROSS JOIN
    - D) FULL OUTER JOIN
    *Answer: B*

30. **To implement a many‑to‑many relationship, you typically use:**
    - A) A foreign key in one of the tables
    - B) A junction table with two foreign keys
    - C) A self‑referencing table
    - D) A UNIQUE constraint
    *Answer: B*

**Hands‑On**
31. Write a query to join `books` (with columns `book_id`, `title`, `author_id`) and `authors` (`author_id`, `name`) to display the book title and author name for all books, including those without an author (using LEFT JOIN).  
    *Answer:* `SELECT b.title, a.name FROM books b LEFT JOIN authors a ON b.author_id = a.author_id;`

### Module 8: Aggregation & Reporting

**MCQ**
32. **Which clause is used to filter groups created by `GROUP BY`?**
    - A) WHERE
    - B) HAVING
    - C) FILTER
    - D) ORDER BY
    *Answer: B*

33. **Which window function assigns a unique sequential integer to each row within a partition?**
    - A) `RANK()`
    - B) `DENSE_RANK()`
    - C) `ROW_NUMBER()`
    - D) `LAG()`
    *Answer: C*

**Fill‑in‑the‑Blank**
34. A Common Table Expression is defined using the ______ clause.  
    *Answer: `WITH`*

**Hands‑On**
35. Write a query using a CTE to find the total number of orders per customer in a `orders` table (with columns `order_id`, `customer_id`), then select customers with more than 5 orders.  
    *Answer:*
    ```sql
    WITH order_counts AS (
        SELECT customer_id, COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    )
    SELECT customer_id, order_count
    FROM order_counts
    WHERE order_count > 5;
    ```

---

## Part 3: Database Design

### Module 9: Relational Database Design

**MCQ**
36. **Normalization is primarily used to:**
    - A) Increase query performance by adding redundant data
    - B) Eliminate data redundancy and avoid update anomalies
    - C) Ensure all tables have a primary key
    - D) Compress the database file
    *Answer: B*

37. **Third Normal Form (3NF) requires that:**
    - A) Every table has a primary key
    - B) No non‑key attribute is functionally dependent on another non‑key attribute
    - C) All columns are atomic
    - D) Foreign keys are indexed
    *Answer: B*

**True/False**
38. **Denormalization is always bad and should never be used.**  
    *Answer: False*

**Short Answer**
39. Explain the difference between a natural key and a surrogate key. Give an example of each.  
    *Answer:* A natural key is a column (or set of columns) that naturally identifies a row, e.g., `email` in a users table. A surrogate key is an artificial key, often an auto‑incrementing integer, created for convenience, e.g., `user_id` in a users table.

### Module 10: Practical Schema Design

**MCQ**
40. **In a library management system, the relationship between `Books` and `Authors` is typically:**
    - A) One‑to‑One
    - B) One‑to‑Many
    - C) Many‑to‑Many
    - D) Recursive
    *Answer: C*

**Hands‑On**
41. Design a schema for a **hospital management system** with the following entities: Patients, Doctors, Appointments. Include proper primary keys, foreign keys, and at least one CHECK constraint. Write the complete `CREATE TABLE` statements.  
    *Expected answer:*
    ```sql
    CREATE TABLE patients (
        patient_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT,
        phone TEXT
    );
    CREATE TABLE doctors (
        doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialty TEXT
    );
    CREATE TABLE appointments (
        appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT CHECK (status IN ('scheduled', 'completed', 'cancelled')),
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
        FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
    );
    ```

---

## Part 4: Indexing & Query Optimization

### Module 11: SQLite Indexes

**MCQ**
42. **Which type of index contains all columns needed by a query, so the table itself does not need to be accessed?**
    - A) Partial index
    - B) Covering index
    - C) Composite index
    - D) Expression index
    *Answer: B*

43. **For a composite index on columns `(a, b, c)`, which queries can use the index?**
    - A) `WHERE b = ?` (only b)
    - B) `WHERE a = ? AND c = ?` (a and c)
    - C) `WHERE a = ? AND b = ?` (a and b)
    - D) `WHERE c = ?` (only c)
    *Answer: C*

**True/False**
44. **Creating an index always improves query performance, regardless of the query pattern.**  
    *Answer: False*

### Module 12: Query Planner

**MCQ**
45. **The `EXPLAIN QUERY PLAN` command shows:**
    - A) The bytecode instructions executed by the VDBE
    - B) The execution strategy chosen by the query optimizer
    - C) The actual data returned by the query
    - D) The list of all indexes on a table
    *Answer: B*

46. **Which command updates statistics used by the query planner?**
    - A) `VACUUM`
    - B) `ANALYZE`
    - C) `REINDEX`
    - D) `PRAGMA optimize`
    *Answer: B*

**Short Answer**
47. What does the output `SCAN users` mean in `EXPLAIN QUERY PLAN`?  
    *Answer:* It means SQLite will perform a full table scan of the `users` table, reading every row. This is typically inefficient for large tables.

### Module 13: Performance Engineering

**MCQ**
48. **Which PRAGMA controls the maximum number of database pages kept in memory?**
    - A) `journal_mode`
    - B) `synchronous`
    - C) `cache_size`
    - D) `mmap_size`
    *Answer: C*

49. **The `VACUUM` command is used to:**
    - A) Create a backup of the database
    - B) Defragment and reclaim unused space
    - C) Update statistics for the query planner
    - D) Enable WAL mode
    *Answer: B*

**Hands‑On**
50. Write a sequence of PRAGMA statements to enable WAL mode, set synchronous to NORMAL, and increase cache size to 20000 pages.  
    *Answer:*
    ```sql
    PRAGMA journal_mode = WAL;
    PRAGMA synchronous = NORMAL;
    PRAGMA cache_size = 20000;
    ```

---

## Part 5: Transactions & Concurrency

### Module 14: ACID Transactions

**MCQ**
51. **Which ACID property ensures that a transaction either fully completes or fully rolls back?**
    - A) Atomicity
    - B) Consistency
    - C) Isolation
    - D) Durability
    *Answer: A*

52. **Which SQL command is used to undo a transaction?**
    - A) `COMMIT`
    - B) `ROLLBACK`
    - C) `SAVEPOINT`
    - D) `RELEASE`
    *Answer: B*

**True/False**
53. **In SQLite, each SQL statement is automatically a transaction unless you explicitly use `BEGIN`.**  
    *Answer: True*

### Module 15: Journaling & WAL

**MCQ**
54. **Which journaling mode allows readers and writers to operate concurrently without blocking?**
    - A) DELETE
    - B) TRUNCATE
    - C) PERSIST
    - D) WAL
    *Answer: D*

55. **What is a checkpoint in WAL mode?**
    - A) A point where the WAL file is deleted
    - B) A transfer of WAL frames to the main database file
    - C) A temporary table created for sorting
    - D) A backup of the database
    *Answer: B*

**Short Answer**
56. Explain the difference between rollback journal and WAL mode in terms of concurrency and crash recovery.  
    *Answer:* In rollback journal mode, writers block readers during commit (EXCLUSIVE lock). In WAL mode, readers and writers do not block each other; changes are appended to a separate WAL file, and readers read from both the main database and the WAL. Crash recovery is done by replaying the WAL.

### Module 16: Reliability & Recovery

**MCQ**
57. **Which command checks the integrity of a SQLite database and reports structural corruption?**
    - A) `PRAGMA foreign_key_check`
    - B) `PRAGMA quick_check`
    - C) `PRAGMA integrity_check`
    - D) `PRAGMA schema_version`
    *Answer: C*

58. **Setting `PRAGMA synchronous = FULL` provides:**
    - A) The highest performance
    - B) The highest safety against data loss on crash
    - C) The smallest database file size
    - D) The best concurrency
    *Answer: B*

**Fill‑in‑the‑Blank**
59. The `SQLITE_BUSY` error occurs when a transaction attempts to acquire a lock that is held by another connection. To handle this gracefully, you can set a timeout using `PRAGMA ______`.  
    *Answer: `busy_timeout`*

---

## Part 6: Advanced SQLite Features

### Module 17: JSON1 Extension

**MCQ**
60. **Which JSON1 function extracts a value from a JSON document?**
    - A) `json_extract()`
    - B) `json_set()`
    - C) `json_remove()`
    - D) `json_insert()`
    *Answer: A*

61. **To index a JSON field, you typically:**
    - A) Create an index directly on the JSON column
    - B) Create a generated column that extracts the JSON field, then index that column
    - C) Use `json_each()` table function
    - D) This is not possible in SQLite
    *Answer: B*

**Hands‑On**
62. Write a query that extracts the `brand` from a JSON column `attributes` in a table `products`. Use the `->>` operator.  
    *Answer:* `SELECT attributes->>'$.brand' FROM products;`

### Module 18: Full‑Text Search (FTS5)

**MCQ**
63. **Which statement creates an FTS5 virtual table?**
    - A) `CREATE TABLE ... USING fts5`
    - B) `CREATE VIRTUAL TABLE ... USING fts5`
    - C) `CREATE INDEX ... USING fts5`
    - D) `CREATE FTS TABLE ...`
    *Answer: B*

64. **The `bm25()` function in FTS5 is used to:**
    - A) Highlight search terms in results
    - B) Rank search results by relevance
    - C) Count the number of matches
    - D) Tokenize the search query
    *Answer: B*

**Short Answer**
65. Explain the advantage of using FTS5 over `LIKE '%keyword%'` for text search.  
    *Answer:* FTS5 uses inverted indexes for O(log n) search, supports ranking, phrase/prefix/Boolean queries, and is much faster on large datasets. `LIKE` with leading wildcard cannot use an index and requires full table scan.

### Module 19: Virtual Tables & Extensions

**MCQ**
66. **Which virtual table allows reading CSV files directly as SQL tables?**
    - A) `csv`
    - B) `file`
    - C) `external`
    - D) `import`
    *Answer: A*

67. **To load a custom extension, you use the _____ command in the SQLite CLI.**
    - A) `.load`
    - B) `.ext`
    - C) `.include`
    - D) `.add`
    *Answer: A*

### Module 20: Triggers & Views

**MCQ**
68. **A trigger that fires instead of a DELETE operation is called:**
    - A) `BEFORE DELETE`
    - B) `AFTER DELETE`
    - C) `INSTEAD OF DELETE`
    - D) `ON DELETE`
    *Answer: C*

69. **A view is:**
    - A) A physical table that stores data
    - B) A virtual table based on the result of a SELECT query
    - C) An index on multiple columns
    - D) A trigger that updates a table
    *Answer: B*

**Hands‑On**
70. Write a trigger that logs an `INSERT` operation on a `users` table into an `audit` table with the new user's name and timestamp.  
    *Answer:*
    ```sql
    CREATE TRIGGER users_insert_audit
    AFTER INSERT ON users
    BEGIN
        INSERT INTO audit (action, user_name, changed_at)
        VALUES ('INSERT', NEW.name, datetime('now'));
    END;
    ```

---

## Part 7: Programming with SQLite

### Module 21: Python Integration

**MCQ**
71. **Which Python module provides SQLite support in the standard library?**
    - A) `sqlalchemy`
    - B) `sqlite`
    - C) `sqlite3`
    - D) `dbapi`
    *Answer: C*

72. **To prevent SQL injection in Python's `sqlite3`, you should:**
    - A) Use f‑strings to build queries
    - B) Escape special characters manually
    - C) Use parameterized queries with `?` placeholders
    - D) Use the `quote()` function on all inputs
    *Answer: C*

**Hands‑On**
73. Write a Python function that connects to a SQLite database, creates a table `contacts` with columns `id`, `name`, `email`, and inserts a new contact using a parameterized query.  
    *Answer:*
    ```python
    import sqlite3

    def add_contact(name, email):
        conn = sqlite3.connect('mydb.db')
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                email TEXT
            )
        ''')
        cursor.execute('INSERT INTO contacts (name, email) VALUES (?, ?)', (name, email))
        conn.commit()
        conn.close()
    ```

### Module 22: Web Development

**MCQ**
74. **In a Flask application, the recommended practice for managing a SQLite connection is to:**
    - A) Open one global connection for the entire app
    - B) Open a connection per request and close it after the request
    - C) Use a connection pool like for other databases
    - D) Let SQLite manage connections automatically
    *Answer: B*

75. **Which library is used for asynchronous SQLite operations in FastAPI?**
    - A) `sqlite3`
    - B) `aiosqlite`
    - C) `asyncpg`
    - D) `sqlite_async`
    *Answer: B*

**Short Answer**
76. Explain why `:memory:` databases are useful for testing.  
    *Answer:* They are ephemeral (disappear after connection closes), fast, isolated, and allow test databases to be created and destroyed without affecting a persistent file, making unit tests repeatable and independent.

### Module 23: Mobile Development

**MCQ**
77. **Which Android library provides a type‑safe ORM for SQLite?**
    - A) SQLiteOpenHelper
    - B) Room
    - C) ContentProvider
    - D) SQLiteDatabase
    *Answer: B*

78. **In React Native, which package is commonly used for SQLite integration?**
    - A) `react-native-sqlite`
    - B) `expo-sqlite`
    - C) `react-native-db`
    - D) `sqlite-react`
    *Answer: B*

**Short Answer**
79. What is an "offline‑first" architecture in mobile development, and how does SQLite support it?  
    *Answer:* Offline‑first means the app works without an internet connection by storing data locally. SQLite provides a fast, ACID‑compliant local database that can be used to cache remote data and queue sync operations, enabling offline usage.

---

## Part 8: Security & Production Deployment

### Module 24: SQLite Security

**MCQ**
80. **Which extension provides transparent AES‑256 encryption for SQLite databases?**
    - A) SQLCipher
    - B) FTS5
    - C) JSON1
    - D) SpatiaLite
    *Answer: A*

81. **To set a password on a SQLCipher‑encrypted database, you use the PRAGMA:**
    - A) `PRAGMA key = 'password'`
    - B) `PRAGMA encrypt = 'password'`
    - C) `PRAGMA password = 'password'`
    - D) `PRAGMA set_key = 'password'`
    *Answer: A*

**True/False**
82. **Parameterized queries are the primary defense against SQL injection.**  
    *Answer: True*

### Module 25: Backup & Maintenance

**MCQ**
83. **Which command creates a hot backup of a SQLite database while it is in use?**
    - A) `COPY`
    - B) `.backup`
    - C) `.dump`
    - D) `VACUUM`
    *Answer: B*

84. **The `VACUUM` command can be run while other connections are reading from the database.**  
    - A) True
    - B) False (it requires an exclusive lock and may block readers)
    *Answer: B*

**Short Answer**
85. What is the purpose of the `ANALYZE` command, and when should you run it?  
    *Answer:* `ANALYZE` updates statistics used by the query planner to choose optimal indexes. Run it after bulk data loads or significant changes to data distribution.

### Module 26: Production Best Practices

**MCQ**
86. **Which PRAGMA setting is recommended for production deployments to balance performance and safety?**
    - A) `synchronous = OFF`
    - B) `synchronous = FULL`
    - C) `synchronous = NORMAL`
    - D) `synchronous = EXTRA`
    *Answer: C*

87. **When deploying SQLite in a Docker container, the database file should be stored:**
    - A) Inside the container image
    - B) On a persistent volume mounted from the host
    - C) In the container's temporary filesystem
    - D) In a network‑attached storage with no local cache
    *Answer: B*

**Fill‑in‑the‑Blank**
88. To keep the WAL file from growing indefinitely, you should monitor the `wal_autocheckpoint` setting and possibly run manual ______.  
    *Answer:* `wal_checkpoint`

---

## Part 9: Real‑World Projects & Capstone

*Questions in this part are more integrative.*

**MCQ**
89. **In the Personal Finance Manager project, to ensure that a user cannot spend more than their budget for a category, you could use:**
    - A) A CHECK constraint on the transactions table
    - B) A trigger that aborts insert if the sum exceeds budget
    - C) A view that calculates the remaining budget
    - D) An application‑side validation only
    *Answer: B*

90. **In the Task Management capstone, which feature best demonstrates the integration of JSON, FTS, and triggers?**
    - A) Task status workflow
    - B) Task search with snippets and custom metadata
    - C) User authentication
    - D) Project reporting
    *Answer: B*

**Short Answer**
91. Describe the steps you would take to ensure a SQLite‑based application is ready for production, including schema, settings, and maintenance.  
    *Expected answer:* (1) Enable WAL and set `synchronous=NORMAL`, `busy_timeout=5000`; (2) Create indexes on all foreign keys and frequently queried columns; (3) Run `ANALYZE`; (4) Set up automated daily backups with `.backup`; (5) Schedule weekly `VACUUM` and integrity checks; (6) Use parameterized queries; (7) Encrypt sensitive data with SQLCipher; (8) Implement logging and monitoring; (9) Have a migration strategy.

---

## Comprehensive Final Exam (Mixed Format)

*This section is a sample of 20 questions covering the entire course.*

**1. (MCQ)** Which of the following is a storage class in SQLite?  
A) VARCHAR  
B) CHAR  
C) INTEGER  
D) DECIMAL  
**Answer: C**

**2. (True/False)** SQLite supports stored procedures in the same way as PostgreSQL.  
**Answer: False**

**3. (Fill‑in‑the‑Blank)** The `______` command displays the SQL used to create a table.  
**Answer: `.schema`**

**4. (Short Answer)** Explain the difference between `INNER JOIN` and `LEFT JOIN`.  
**Answer:** `INNER JOIN` returns only rows with matches in both tables. `LEFT JOIN` returns all rows from the left table, with NULLs for non‑matching right rows.

**5. (MCQ)** Which window function provides a ranking with gaps?  
A) `ROW_NUMBER()`  
B) `RANK()`  
C) `DENSE_RANK()`  
D) `NTILE()`  
**Answer: B**

**6. (True/False)** A `UNIQUE` constraint automatically creates an index on the column(s).  
**Answer: True**

**7. (Hands‑On)** Write a SQL query that counts the number of orders per customer and returns only customers with more than 5 orders.  
**Answer:**
```sql
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 5;
```

**8. (MCQ)** Which PRAGMA enables Write‑Ahead Logging?  
A) `PRAGMA journal_mode = WAL`  
B) `PRAGMA wal_mode = ON`  
C) `PRAGMA log_mode = WAL`  
D) `PRAGMA journal = WAL`  
**Answer: A**

**9. (Short Answer)** What is the purpose of `VACUUM`?  
**Answer:** To defragment and reclaim unused space in the database file.

**10. (Fill‑in‑the‑Blank)** The `______` function is used to extract a value from a JSON document in SQLite.  
**Answer:** `json_extract`

**11. (MCQ)** Which extension provides full‑text search in SQLite?  
A) JSON1  
B) FTS5  
C) SQLCipher  
D) SpatiaLite  
**Answer: B**

**12. (True/False)** In Python, you must use `commit()` to save changes after an `INSERT`.  
**Answer: True**

**13. (Hands‑On)** Write a Python function that uses a context manager to open a SQLite connection, executes a `SELECT` query, and returns the results as a list of dictionaries.  
**Answer:**
```python
import sqlite3
from contextlib import contextmanager

@contextmanager
def get_db():
    conn = sqlite3.connect('mydb.db')
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

def fetch_users():
    with get_db() as conn:
        cursor = conn.execute('SELECT * FROM users')
        return [dict(row) for row in cursor]
```

**14. (MCQ)** Which of the following is NOT a valid mitigation against SQL injection?  
A) Using parameterized queries  
B) Escaping user input with `quote()`  
C) Validating input against a whitelist for table/column names  
D) Storing all user input in BLOB columns  
**Answer: D**

**15. (Short Answer)** How can you encrypt a SQLite database?  
**Answer:** Use SQLCipher, a fork of SQLite that provides AES‑256 encryption. Set a key using `PRAGMA key = 'password'` when opening the database.

**16. (True/False)** FTS5 indexes are automatically kept in sync with the base table if you use the `content` option and triggers.  
**Answer: True** (if triggers are set up correctly)

**17. (MCQ)** Which command creates a backup of a currently open database in the SQLite CLI?  
A) `.dump`  
B) `.backup`  
C) `.save`  
D) `.copy`  
**Answer: B**

**18. (Fill‑in‑the‑Blank)** The `busy_timeout` PRAGMA is set to ______ milliseconds to avoid immediate `SQLITE_BUSY` errors.  
**Answer:** 5000 (or any positive integer)

**19. (Hands‑On)** Design a table for a blog post with tags (many‑to‑many). Write the `CREATE TABLE` statements for posts, tags, and the junction table.  
**Answer:**
```sql
CREATE TABLE posts (post_id INTEGER PRIMARY KEY, title TEXT, content TEXT);
CREATE TABLE tags (tag_id INTEGER PRIMARY KEY, name TEXT UNIQUE);
CREATE TABLE post_tags (
    post_id INTEGER,
    tag_id INTEGER,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);
```

**20. (Short Answer)** Describe the steps you would take to migrate a SQLite schema from version 1 to version 2 without losing data.  
**Answer:** (1) Create a backup. (2) Create a new schema with `CREATE TABLE new_table ...`. (3) Copy data using `INSERT INTO new_table SELECT ... FROM old_table`. (4) Drop old tables and rename new ones. (5) Apply any new indexes, triggers, etc. (6) Update a schema version table. Use `BEGIN`/`COMMIT` to make the migration atomic. For complex migrations, use a migration tool like Alembic.

---

## Answer Keys Summary

All answers are provided immediately after each question in the sections above.

---

This test bank is designed to be modular; instructors can pick questions per module or use the comprehensive final exam. The variety of formats assesses both theoretical understanding and practical coding skills.
