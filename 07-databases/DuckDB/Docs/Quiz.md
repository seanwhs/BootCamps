# Test Bank 

This test bank contains multiple-choice questions, scenario-based debugging challenges, and architectural design prompts designed to evaluate mastery of embedded analytics, columnar execution, zero-copy memory architectures, advanced analytical SQL, and production lakehouse patterns using DuckDB.

---

## Part 1: Multiple-Choice Questions (Foundations & Architecture)

### Q1: What is the primary architectural difference between an OLTP database (like SQLite or PostgreSQL) and DuckDB?

* A) DuckDB supports concurrent writes across distributed network sockets, whereas SQLite is strictly local.
* B) DuckDB utilizes a columnar storage engine and vectorized execution designed for analytical read aggregations, whereas OLTP databases use row-oriented layouts optimized for transactional inserts and lookups.
* C) DuckDB stores data exclusively in volatile RAM without disk persistence capabilities.
* D) OLTP engines run entirely in-process, whereas DuckDB requires a dedicated background daemon process.

### Q2: How does DuckDB achieve high performance without a client-server daemon or network socket?

* A) By serializing all queries into JSON payloads before transmitting them over local loopback TCP ports.
* B) By compiling as a C++ library linked directly into the host application process space, allowing direct function calls and memory pointer sharing.
* C) By utilizing a Python-to-C interpreter bridge that translates SQL statements into bytecode.
* D) By restricting execution to a single CPU thread to avoid multi-threading synchronization overhead.

### Q3: What is a "vector" in DuckDB's vectorized execution model?

* A) A single row of relational data represented as a Python dictionary.
* B) A fixed-size contiguous chunk of values (typically 2,048 values) for a single column, designed to fit into CPU L1/L2 caches.
* C) An independent network socket connection handling asynchronous storage reads.
* D) A temporary table written to disk during an out-of-core spill operation.

### Q4: When executing `SELECT AVG(salary) FROM employees;` on a columnar database, what happens to the unrequested columns (e.g., `first_name`, `address`)?

* A) They are loaded into RAM but ignored by the CPU arithmetic logic unit.
* B) They are read from disk into temporary cache buffers and discarded later.
* C) They are completely ignored at the storage layer; only the `salary` data blocks are read from disk into memory.
* D) They trigger a schema mismatch exception unless explicitly projected.

---

## Part 2: Multiple-Choice Questions (Zero-Copy Interoperability & Memory)

### Q5: What role does Apache Arrow play when DuckDB interacts with a Pandas DataFrame?

* A) It converts Pandas DataFrames into CSV text streams over network sockets.
* B) It provides an independent, standardized in-memory columnar data format that enables zero-copy memory sharing without data duplication.
* C) It acts as an ORM mapper translating relational tables into Python classes.
* D) It compresses Pandas data frames using gzip compression before query execution.

### Q6: What happens when an analytical query requires more memory than the configured `memory_limit` in DuckDB?

* A) DuckDB throws a fatal `MemoryError` and terminates the Python interpreter.
* B) The operating system automatically allocates swap space to expand physical RAM.
* C) DuckDB's internal buffer manager identifies inactive memory blocks and transparently spills them to temporary files on disk.
* D) The query automatically pauses until other background threads release their memory allocations.

### Q7: Which configuration command sets an explicit memory ceiling of 2GB for a DuckDB connection in Python?

* A) `conn.execute("SET memory_limit = '2GB';")`
* B) `conn.execute("PRAGMA max_ram = 2048;")`
* C) `conn.execute("CONFIG memory_cap 2000;")`
* D) `conn.execute("ALTER SYSTEM SET RAM = 2;");`

---

## Part 3: Multiple-Choice Questions (Advanced SQL & Lakehouse Architecture)

### Q8: What is the fundamental difference between `GROUP BY` and window functions in analytical SQL?

* A) Window functions execute faster because they bypass the storage layer entirely.
* B) `GROUP BY` collapses multiple rows into a single summary row, whereas window functions compute aggregate values across partitions while preserving individual row granularity.
* C) Window functions can only be used with nested list data types, whereas `GROUP BY` is restricted to scalar columns.
* D) There is no functional difference; window functions are merely syntactic sugar for subqueries.

### Q9: What is "partition pruning" when querying a partitioned Parquet lakehouse directory?

* A) Deleting old partition folders automatically after a retention period expires.
* B) The engine evaluating query filters against directory metadata to skip entire folder trees on disk that do not match the criteria, avoiding unnecessary file reads.
* C) Compressing individual columns within a Parquet file to reduce storage footprint.
* D) Splitting large single-threaded queries across multiple CPU cores.

### Q10: How do you unnest an array or list column in DuckDB into individual expanded rows?

* A) Using the `FLATTEN()` aggregate function.
* B) Using the `UNNEST()` table function inside the SQL query.
* C) Using a recursive self-join on the parent table ID.
* D) Converting the list to a string and splitting by comma delimiters.

---

## Part 4: Scenario-Based Debugging & Code Analysis

### Scenario A: The Memory Spike

An engineer writes a Python script to process a 40GB transaction log on a cloud container with 8GB of RAM. The script crashes with an out-of-memory error during a complex multi-column group-by operation.

**Question:** What two configurations or architectural features should the engineer inspect or implement to resolve this crash without upgrading container hardware?

* *Analysis/Solution:*
1. Set an aggressive memory limit using `conn.execute("SET memory_limit = '4GB';")` to trigger DuckDB's buffer manager spill-to-disk logic early before OOM exhaustion occurs.
2. Ensure the temporary directory is properly configured (`SET temp_directory = '/path/to/fast_disk/temp';`) to handle intermediate spill blocks efficiently.



### Scenario B: Inefficient Pandas Bridge

A junior developer writes the following code to filter a massive Pandas DataFrame before aggregation:

```python
import duckdb
import pandas as pd

df = pd.read_csv("huge_dataset.csv") # 15GB CSV file
conn = duckdb.connect(":memory:")
result = conn.execute("SELECT * FROM df WHERE amount > 1000").fetchdf()

```

**Question:** Why is this anti-pattern dangerous for system stability, and how should it be refactored?

* *Analysis/Solution:* Loading a 15GB CSV file directly into Pandas via `pd.read_csv` materializes the entire dataset into Pandas internal memory structures before DuckDB even touches it, causing a massive memory spike. It should be refactored to query the file directly using DuckDB's zero-copy table-valued function: `conn.execute("SELECT * FROM read_csv('huge_dataset.csv') WHERE amount > 1000").fetchdf()`.

---

## Answer Key

### Part 1: Multiple-Choice (Foundations)

* **Q1:** **B** (Columnar vs. row-oriented storage physics)
* **Q2:** **B** (In-process C++ library linking and direct function calls)
* **Q3:** **B** (Fixed-size contiguous chunk of 2,048 values fitting CPU caches)
* **Q4:** **C** (Storage layer skips unrequested columns entirely)

### Part 2: Multiple-Choice (Zero-Copy & Memory)

* **Q5:** **B** (Standardized in-memory columnar format enabling zero-copy sharing)
* **Q6:** **C** (Buffer manager transparently spills cold memory blocks to temporary disk files)
* **Q7:** **A** (`SET memory_limit = '2GB';`)

### Part 3: Multiple-Choice (Advanced SQL & Lakehouse)

* **Q8:** **B** (`GROUP BY` collapses rows; window functions preserve row granularity)
* **Q9:** **B** (Skipping non-matching directory trees based on filter metadata)
* **Q10:** **B** (Using the `UNNEST()` table function)
