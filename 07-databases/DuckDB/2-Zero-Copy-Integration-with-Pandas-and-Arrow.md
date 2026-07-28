## Part 2: Zero-Copy Integration with Pandas and Arrow

### Module Overview

In this module, we bridge the gap between Python data frames and DuckDB. We will explore how DuckDB executes high-performance SQL queries directly against active Pandas DataFrames in memory—without data copying—and how Apache Arrow and PyArrow power this zero-copy memory sharing. We will also benchmark execution times and examine memory management in resource-constrained environments.

---

### Conceptual Deep Dive: Zero-Copy Architecture & Memory Sharing

#### 1. The Cost of Data Serialization

In traditional workflows, passing data between Python (Pandas) and a database engine requires serializing data into an intermediate format, copying it across process or memory boundaries, and deserializing it on the other side. For millions of rows, this serialization bottleneck consumes significant CPU cycles and inflates RAM usage.

#### 2. The Apache Arrow Standard

Apache Arrow defines a language-independent **columnar memory format** for flat and hierarchical data. Because both DuckDB and Pandas (via PyArrow backends or direct arrow structures) understand the Arrow memory layout, DuckDB can inspect Pandas DataFrames directly in RAM.

#### 3. Zero-Copy Execution

When you pass a Pandas DataFrame to DuckDB, DuckDB does not duplicate the underlying data buffers. Instead, it reads the memory pointers directly. This is known as **zero-copy integration**. You get the expressiveness of Pandas combined with the vectorized speed of SQL instantly, without memory bloat.

---

### Step-by-Step Implementation

#### Step 1: Zero-Copy Querying of Pandas DataFrames

##### 1. The Target

Create a script (`pandas_integration.py`) that loads our transaction data into a Pandas DataFrame and queries it directly using DuckDB SQL without duplicating memory.

##### 2. The Concept

DuckDB automatically registers local Python variables (including Pandas DataFrames and PyArrow Tables) in its scope when executing queries. You can reference a Pandas variable inside your SQL statement just like a standard table.

##### 3. The Implementation

Create a file named `pandas_integration.py`:

```python
# File: pandas_integration.py
import duckdb
import pandas as pd

def run_pandas_integration() -> None:
    print("--- 1. Loading Data into Pandas DataFrame ---")
    # Load our previously generated CSV into Pandas
    df = pd.read_csv("data/transactions.csv")
    print(f"Loaded DataFrame with shape: {df.shape}")
    
    # Initialize DuckDB connection
    conn = duckdb.connect(":memory:")
    
    print("\n--- 2. Executing SQL Directly Against Pandas DataFrame ---")
    # Notice we reference the python variable 'df' directly inside the SQL FROM clause
    query = """
        SELECT 
            category,
            COUNT(*) AS tx_count,
            ROUND(SUM(amount * quantity), 2) as total_revenue,
            ROUND(AVG(amount), 2) AS avg_amount
        FROM df
        WHERE quantity >= 3
        GROUP BY category
        ORDER BY total_revenue DESC;
    """
    
    result_df = conn.execute(query).fetchdf()
    print(result_df)
    
    conn.close()

if __name__ == "__main__":
    run_pandas_integration()

```

##### 4. The Verification

Run the script:

```bash
python pandas_integration.py

```

*Expected Output:* A summarized Pandas DataFrame showing transaction counts, total revenues, and average amounts filtered where quantity is 3 or greater—computed directly from the in-memory Pandas frame via DuckDB SQL.

---

#### Step 2: Benchmarking Pandas vs. DuckDB Grouping Performance

##### 1. The Target

Write a benchmark script (`benchmark_comparison.py`) to compare native Pandas grouping/aggregation performance against DuckDB SQL execution on our dataset.

##### 2. The Concept

While Pandas is exceptional for data manipulation, its single-threaded grouping overhead on larger datasets can lag behind DuckDB's multi-threaded, vectorized vector execution engine. Benchmarking quantifies this speedup.

##### 3. The Implementation

Create a file named `benchmark_comparison.py`:

```python
# File: benchmark_comparison.py
import time
import duckdb
import pandas as pd

def benchmark_performance() -> None:
    print("Loading dataset into memory...")
    df = pd.read_csv("data/transactions.csv")
    
    conn = duckdb.connect(":memory:")
    
    # --- Benchmark 1: Native Pandas Groupby ---
    print("\nRunning Native Pandas Aggregation...")
    start_time = time.perf_counter()
    
    pandas_result = (
        df.groupby("category")
        .agg(
            total_revenue=("amount", lambda x: (x * df.loc[x.index, "quantity"]).sum()),
            avg_price=("amount", "mean"),
            count=("transaction_id", "count")
        )
        .reset_index()
    )
    
    pandas_duration = time.perf_counter() - start_time
    print(f"Pandas Execution Time: {pandas_duration:.4f} seconds")
    
    # --- Benchmark 2: DuckDB SQL over Pandas ---
    print("\nRunning DuckDB SQL Aggregation over Pandas...")
    start_time = time.perf_counter()
    
    duckdb_result = conn.execute("""
        SELECT 
            category,
            SUM(amount * quantity) AS total_revenue,
            AVG(amount) AS avg_price,
            COUNT(transaction_id) AS count
        FROM df
        GROUP BY category;
    """).fetchdf()
    
    duckdb_duration = time.perf_counter() - start_time
    print(f"DuckDB Execution Time: {duckdb_duration:.4f} seconds")
    
    speedup = pandas_duration / duckdb_duration if duckdb_duration > 0 else 0
    print(f"\nDuckDB was approximately {speedup:.2f}x faster than native Pandas for this aggregation.")
    
    conn.close()

if __name__ == "__main__":
    benchmark_performance()

```

##### 4. The Verification

Run the benchmark script:

```bash
python benchmark_comparison.py

```

*Expected Output:* Execution time comparison metrics showing how fast DuckDB processed the aggregation relative to native Pandas.

---

#### Step 3: Managing Memory Limits and Execution Threads

##### 1. The Target

Configure DuckDB thread allocation and memory boundaries inside a script (`resource_control.py`) to prevent resource starvation in production environments.

##### 2. The Concept

By default, DuckDB scales to utilize all available CPU cores and physical RAM. In shared containers or microservices, you must explicitly govern resource limits using `PRAGMA` statements.

##### 3. The Implementation

Create a file named `resource_control.py`:

```python
# File: resource_control.py
import duckdb

def configure_resources() -> None:
    conn = duckdb.connect(":memory:")
    
    print("--- Configuring Execution Threads & Memory Limits ---")
    
    # Limit DuckDB to use exactly 2 CPU threads
    conn.execute("PRAGMA threads=2;")
    
    # Restrict maximum memory consumption to 2 Gigabytes
    conn.execute("PRAGMA memory_limit='2GB';")
    
    # Verify current settings
    threads_val = conn.execute("PRAGMA threads;").fetchone()
    memory_val = conn.execute("PRAGMA memory_limit;").fetchone()
    
    print(f"Configured Threads: {threads_val}")
    print(f"Configured Memory Limit: {memory_val}")
    
    conn.close()

if __name__ == "__main__":
    configure_resources()

```

##### 4. The Verification

Run the resource control script:

```bash
python resource_control.py

```

*Expected Output:* Confirmation of the applied thread count and memory ceiling pragmas.

---

### Phase 2 Reference Section: Interoperability Methods Cheat Sheet

| Python Object | DuckDB Ingestion Method | Return Method from DuckDB |
| --- | --- | --- |
| **Pandas DataFrame** | Reference variable name directly in SQL (`FROM df`) | `conn.execute("...").fetchdf()` |
| **PyArrow Table** | Reference table variable directly in SQL (`FROM arrow_table`) | `conn.execute("...").fetcharrow_table()` |
| **Python Dictionary / List** | Register view or query via parameters | `conn.execute("SELECT * FROM?", [data_list])` |
