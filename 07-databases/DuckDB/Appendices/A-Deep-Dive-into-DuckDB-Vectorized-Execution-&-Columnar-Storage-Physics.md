## Appendix A: Deep Dive into DuckDB Vectorized Execution & Columnar Storage Physics

### Module Overview

In this appendix, we peel back the abstraction layers of DuckDB to examine the low-level computer science principles that make its performance possible. We will explore how vectorized execution interacts with modern CPU hardware, why columnar storage minimizes disk I/O, and how the underlying query executor avoids the CPU bottlenecks typical of traditional databases.

---

### Conceptual Deep Dive: Hardware Architecture & Vectorization

#### 1. The Von Neumann Bottleneck and CPU Caches

To understand why DuckDB is fast, you must understand where modern computing time is spent. The CPU core itself executes instructions in nanoseconds, but fetching data from system RAM takes tens of nanoseconds, and fetching from disk takes millions.

To bridge this gap, modern CPUs rely on hierarchical cache memory:

* **L1 Cache:** ~1-4 ns latency (very small, ~32KB–64KB)
* **L2 Cache:** ~3-10 ns latency (moderate, ~512KB)
* **L3 Cache:** ~10-30 ns latency (shared across cores, ~MBs)

Traditional row-oriented databases process data **tuple-by-tuple** (one row at a time). When evaluating a query across millions of rows, the CPU constantly thrashes through memory, cache misses occur frequently, and the CPU pipeline stalls waiting for data to arrive from RAM.

#### 2. Vectorized (Chunk-Based) Execution

DuckDB abandons traditional tuple-at-a-time execution in favor of **vectorized execution** (also known as vector-at-a-time or chunk-based execution).

* Instead of processing one row, DuckDB processes **vectors**—contiguous arrays of values (typically 2,048 values) of a single data type.
* A batch of 2,048 integers or floating-point values fits neatly into the CPU’s L1 or L2 cache.
* The execution engine evaluates operators (like filters, projections, and aggregations) in tight, loops over these vectors. This enables **SIMD (Single Instruction, Multiple Data)** parallel processing, where a single CPU instruction operates on multiple data points simultaneously.

#### 3. Columnar Layout Physics

Combined with vectorization, DuckDB stores data column-by-column on disk and in memory.

Consider a table with 50 columns. In a row-oriented store (like SQLite or PostgreSQL), querying just `SELECT AVG(amount) FROM transactions` forces the storage engine to read entire rows into memory—loading customer names, timestamps, and metadata that are immediately discarded.

In DuckDB's columnar layout:

* The `amount` column is stored contiguously on disk.
* DuckDB reads *only* the bytes corresponding to the `amount` column into memory.
* Disk I/O is reduced by an order of magnitude, and memory bandwidth is preserved exclusively for relevant data.

---

### Practical Demonstration: Inspecting Physical Query Plans

To see vectorization and columnar execution in action, we can inspect DuckDB's internal query planner using the `EXPLAIN` statement with visualization parameters.

#### 1. The Implementation

Create a script named `inspect_plan.py` to examine how DuckDB structures its execution tree:

```python
# File: inspect_plan.py
import duckdb

def inspect_query_plan() -> None:
    conn = duckdb.connect(":memory:")
    
    print("--- Generating Physical Execution Plan ---")
    
    # We use EXPLAIN ANALYZE to view the physical operators and vector chunk flow
    plan_query = """
        EXPLAIN ANALYZE 
        SELECT 
            category,
            SUM(amount * quantity) AS total_revenue
        FROM read_csv('data/transactions.csv')
        WHERE amount > 100.0
        GROUP BY category;
    """
    
    plan_df = conn.execute(plan_query).fetchdf()
    for _, row in plan_df.iterrows():
        print(row['query_plan'])
        
    conn.close()

if __name__ == "__main__":
    inspect_query_plan()

```

#### 2. The Verification

Run the script:

```python
python inspect_plan.py

```

*Expected Output:* A detailed ASCII-based execution tree showing physical operators such as `SEQ_SCAN` (sequential columnar scan), `FILTER`, `HASH_GROUP_BY`, and vector batch chunk sizes flowing upward through the execution pipeline.
