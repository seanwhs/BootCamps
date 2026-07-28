# Student Notes: Embedded Analytics at Scale with DuckDB

---

## Module 1: Foundations & In-Process Architecture

### Core Concepts

* **OLTP vs. OLAP:**
* **OLTP (Online Transaction Processing):** Databases like PostgreSQL, MySQL, and SQLite. Optimized for fast individual row inserts, updates, and transactional safety (ACID). Store data **row by row** on disk.
* **OLAP (Online Analytical Processing):** DuckDB. Optimized for heavy read aggregations over large datasets. Store data **column by column** (columnar storage). Reading only required columns drastically reduces disk I/O.


* **In-Process Architecture:** DuckDB has no server daemon, background service, or network socket. It runs directly inside the Python application's memory space as a compiled C++ library, communicating via direct function calls.
* **Vectorized Execution:** Processes data in **vectors** (contiguous chunks of 2,048 values) that fit neatly into CPU L1/L2 caches, enabling SIMD parallel processing and eliminating cache misses.

### Key Syntax & Commands

```python
import duckdb

# Initialize ephemeral in-memory connection
conn = duckdb.connect(database=":memory:")

# Initialize persistent on-disk connection
conn = duckdb.connect(database="warehouse.duckdb")

# Query raw files directly without explicit staging tables or schema definitions
df = conn.execute("SELECT * FROM read_csv('data/transactions.csv');").fetchdf()

```

---

## Module 2: Zero-Copy Integration with Pandas and Arrow

### Core Concepts

* **The Apache Arrow Standard:** A language-agnostic in-memory columnar data format that standardizes memory layouts across programming languages and runtime engines.
* **Zero-Copy Memory Sharing:** DuckDB accepts reference pointers to existing memory buffers allocated by Pandas or PyArrow, reading them in place without data duplication or serialization overhead.
* **Resource Governance:** Controlling concurrent execution threads (`PRAGMA threads=N`) and memory ceilings (`PRAGMA memory_limit='XGB'`) to prevent resource starvation in shared environments.

### Key Syntax & Commands

```python
import duckdb
import pandas as pd

df = pd.read_csv("data/transactions.csv")
conn = duckdb.connect(":memory:")

# Query Pandas DataFrame directly in SQL scope
result_df = conn.execute("SELECT category, SUM(amount) FROM df GROUP BY category;").fetchdf()

# Configure resource limits
conn.execute("PRAGMA threads=4;")
conn.execute("PRAGMA memory_limit='4GB';")

```

---

## Module 3: Advanced SQL Analytics & Complex Data Types

### Core Concepts

* **Window Functions:** Compute calculations across related row partitions without collapsing row granularity (unlike `GROUP BY`). Essential for moving averages and running totals.
* **Nested Data Types:** Native support for hierarchical data structures:
* **Arrays / Lists:** Ordered sequences of elements of the same type.
* **Structs:** Fixed collections of named fields (resembling dictionaries or JSON objects).


* **Dynamic Reshaping:** Native `PIVOT` and `UNPIVOT` operators transform row-based categories into column matrices efficiently during execution.

### Key Syntax & Commands

```sql
-- Running total window calculation
SELECT 
    sale_date,
    category,
    SUM(daily_revenue) OVER (
        PARTITION BY category 
        ORDER BY sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM daily_sales;

-- Unnesting lists
SELECT transaction_id, UNNEST(tags) FROM tagged_transactions;

-- Dynamic Pivoting
PIVOT transactions ON category USING SUM(amount) GROUP BY txn_month;

```

---

## Module 4: Production Pipelines & Lakehouse Orchestration

### Core Concepts

* **Lakehouse Architecture:** Combines cheap object storage with open columnar file formats (Parquet) and structured directory partitioning.
* **Partition Pruning:** When queries include filters matching partition directories (e.g., `year=2025/month=01`), DuckDB skips entire directory trees on disk without opening individual files.
* **Out-of-Core Processing:** If intermediate execution states exceed system RAM, DuckDB's buffer manager transparently spills blocks to temporary disk storage.
* **Pipeline Testing:** Utilizing `pytest` with ephemeral in-memory DuckDB fixtures to validate data integrity and schema contracts.

### Key Syntax & Commands

```python
# Exporting partitioned Parquet files
conn.execute("""
    COPY (SELECT * FROM raw_data) 
    TO 'data/lakehouse' 
    (FORMAT PARQUET, PARTITION_BY (year, month));
""")

# Querying partitioned parquet with partition pruning
df = conn.execute("""
    SELECT * FROM read_parquet('data/lakehouse/**/*.parquet')
    WHERE year = 2025 AND month = 1;
""").fetchdf()

```
