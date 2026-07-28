## Appendix B: Out-of-Core Memory Management & Spill-to-Disk Architecture

### Module Overview

In this appendix, we examine how DuckDB handles workloads that exceed physical system RAM. We will explore the mechanics of out-of-core processing, how DuckDB's buffer manager tracks and evicts memory pages, and how to configure settings to prevent out-of-memory (OOM) failures on massive datasets.

---

### Conceptual Deep Dive: Streaming and Buffer Management

#### 1. The Out-of-Core Challenge

When executing blocking operations—such as large-scale hash joins, sorting (`ORDER BY`), or heavy `GROUP BY` aggregations—an engine typically needs to hold intermediate states in memory. If your dataset is 50GB and your machine has 16GB of RAM, a standard in-memory framework will throw a fatal `MemoryError` or be terminated by the operating system’s OOM killer.

DuckDB avoids this limitation through an **out-of-core architecture**.

#### 2. The Buffer Manager & Block Allocation

DuckDB manages all memory allocations via an internal **Buffer Manager**:

* Memory is divided into fixed-size blocks (typically 256KB).
* The Buffer Manager tracks every block currently active in RAM.
* When queries demand more memory than permitted by the `memory_limit` configuration, the Buffer Manager identifies inactive or cold memory blocks (such as intermediate hash tables or sort runs) and **spills them to temporary files on disk**.
* Once downstream operators need those blocks again, DuckDB reads them back into memory transparently.

#### 3. Streaming and Chunk Pipelines

Unlike tools that materialize entire tables during intermediate steps, DuckDB utilizes a **push-based pipeline model**. Vectors flow continuously through operator nodes. Data is materialized only when required by blocking operators (like sorting or global aggregation), and even then, spilling mechanisms protect overall stability.

---

### Practical Demonstration: Simulating Spill-to-Disk Controls

To configure and observe memory thresholds in Python, we can explicitly set memory boundaries and monitor execution behavior.

#### 1. The Implementation

Create a script named `memory_tuning.py` to configure aggressive memory caps and test engine stability under constrained conditions:

```python
# File: memory_tuning.py
import duckdb

def configure_spill_behavior() -> None:
    # Initialize connection
    conn = duckdb.connect(":memory:")
    
    print("--- Configuring Out-of-Core Memory Thresholds ---")
    
    # Set a strict memory limit to force early spilling on moderate datasets
    conn.execute("SET memory_limit = '50MB';")
    
    # Optimize temporary directory for spilling
    conn.execute("SET temp_directory = 'data/duckdb_temp';")
    
    # Verify settings
    limit = conn.execute("SELECT current_setting('memory_limit');").fetchone()[0]
    temp_dir = conn.execute("SELECT current_setting('temp_directory');").fetchone()[0]
    
    print(f"Active Memory Limit: {limit}")
    print(f"Spill Directory: {temp_dir}")
    
    # Run a memory-intensive grouping operation under the constraint
    spill_test_query = """
        SELECT 
            customer_id,
            category,
            SUM(amount * quantity) AS total_spend,
            COUNT(*) as tx_count
        FROM read_csv('data/transactions.csv')
        GROUP BY customer_id, category
        ORDER BY total_spend DESC
        LIMIT 10;
    """
    
    result_df = conn.execute(spill_test_query).fetchdf()
    print("\nQuery executed successfully under constrained memory:")
    print(result_df)
    
    conn.close()

if __name__ == "__main__":
    configure_spill_behavior()

```

#### 2. The Verification

Run the script:

```bash
python memory_tuning.py

```

*Expected Output:* Successful execution confirmation and query results, proving that DuckDB successfully managed intermediate state aggregation by utilizing its buffer manager and spill-to-disk logic under a strict 50MB ceiling.
