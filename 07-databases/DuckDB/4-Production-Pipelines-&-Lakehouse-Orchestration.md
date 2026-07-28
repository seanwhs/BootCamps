## Part 4: Production Pipelines & Lakehouse Orchestration

### Module Overview

In this final module, we transition from ad-hoc analysis to robust, production-grade data engineering. We will export results efficiently into partitioned Parquet file structures, integrate DuckDB into modular data workflows with PyArrow, implement automated testing and query validation using `pytest`, and apply performance tuning and memory profiling best practices for out-of-core datasets.

---

### Conceptual Deep Dive: Production Engineering & Lakehouse Design

#### 1. Partitioned Parquet & Lakehouse Architecture

A modern data lakehouse combines the ACID reliability and structure of data warehouses with the cheap, scalable storage of object stores. By exporting data into **partitioned Parquet files** (e.g., `data/partitioned_transactions/year=2025/month=01/data.parquet`), queries can leverage **partition pruning**. When a query filters by date, DuckDB skips entire directory branches that do not match the criteria without opening individual files.

#### 2. Out-of-Core Processing

When datasets exceed available RAM, traditional tools crash with `MemoryError`. DuckDB features an **out-of-core execution engine**. If an aggregation, join, or sort operation exceeds the configured `memory_limit`, DuckDB transparently spills intermediate execution states to high-speed temporary disk storage and stitches the results back together seamlessly.

#### 3. Automated Testing with Pytest

Data pipelines are notoriously susceptible to silent failures (e.g., schema drift, null injections, data type mutations). Wrapping your DuckDB transformation layers in an automated testing suite ensures strict contract enforcement before data reaches downstream consumers.

---

### Step-by-Step Implementation

#### Step 1: Exporting Partitioned Parquet Files

##### 1. The Target

Create a script (`pipeline_export.py`) that reads our raw transaction data and exports it into a partitioned Parquet directory structure on disk.

##### 2. The Concept

Writing out partitioned Parquet files optimizes future read performance. DuckDB handles partitioning natively via the `COPY ... TO ... (FORMAT PARQUET, PARTITION_BY (...))` clause.

##### 3. The Implementation

Create a file named `pipeline_export.py`:

```python
# File: pipeline_export.py
import os
import duckdb

def export_partitioned_parquet() -> None:
    conn = duckdb.connect(":memory:")
    
    output_dir = "data/partitioned_transactions"
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"Exporting raw CSV data into partitioned Parquet lakehouse structure at '{output_dir}'...")
    
    # DuckDB copies and partitions data directly on disk in a single optimized pass
    export_query = f"""
        COPY (
            SELECT 
                transaction_id,
                customer_id,
                category,
                amount,
                quantity,
                amount * quantity AS total_price,
                CAST(SUBSTR(transaction_date, 1, 4) AS INTEGER) AS txn_year,
                CAST(SUBSTR(transaction_date, 6, 2) AS INTEGER) AS txn_month,
                transaction_date
            FROM read_csv('data/transactions.csv')
        ) TO '{output_dir}' 
        (FORMAT PARQUET, PARTITION_BY (txn_year, txn_month), OVERWRITE_OR_IGNORE 1);
    """
    
    conn.execute(export_query)
    print("Successfully exported partitioned Parquet dataset.")
    
    conn.close()

if __name__ == "__main__":
    export_partitioned_parquet()

```

##### 4. The Verification

Run the export script:

```bash
python pipeline_export.py

```

*Expected Output:* Successful completion log. Verify the directory structure created on disk:

```bash
find data/partitioned_transactions -type f | head -n 10

```

---

#### Step 2: Querying Partitioned Parquet with Glob Patterns

##### 1. The Target

Write a script (`pipeline_query.py`) that queries the partitioned Parquet lakehouse efficiently using wildcard glob patterns and partition pruning.

##### 2. The Concept

DuckDB's `read_parquet()` function supports globbing (e.g., `data/**/*.parquet`). When filtering criteria match partition directories, DuckDB automatically prunes unneeded partitions from the execution plan.

##### 3. The Implementation

Create a file named `pipeline_query.py`:

```python
# File: pipeline_query.py
import duckdb

def query_lakehouse() -> None:
    conn = duckdb.connect(":memory:")
    
    print("--- Querying Partitioned Lakehouse with Partition Pruning ---")
    
    query = """
        SELECT 
            category,
            COUNT(*) AS total_txns,
            SUM(total_price) AS category_revenue
        FROM read_parquet('data/partitioned_transactions/**/*.parquet')
        WHERE txn_year = 2025 AND txn_month <= 3
        GROUP BY category
        ORDER BY category_revenue DESC;
    """
    
    result_df = conn.execute(query).fetchdf()
    print(result_df)
    
    conn.close()

if __name__ == "__main__":
    query_lakehouse()

```

##### 4. The Verification

Run the query script:

```bash
python pipeline_query.py

```

*Expected Output:* Aggregated metrics filtered specifically for the first quarter of 2025, read directly from the partitioned Parquet files.

---

#### Step 3: Automated Testing with Pytest and Query Validation

##### 1. The Target

Create an automated test suite (`test_pipeline.py`) using `pytest` to validate data integrity, enforce non-null constraints, and verify pipeline aggregation logic.

##### 2. The Concept

Production pipelines require automated test coverage. By embedding DuckDB in-memory inside test fixtures, we can spin up isolated test databases instantly, ingest mock data or small partitions, and assert structural and business invariants.

##### 3. The Implementation

First, install `pytest` if not already installed:

```bash
pip install pytest==8.3.3

```

Create a file named `test_pipeline.py`:

```python
# File: test_pipeline.py
import duckdb
import pytest

@pytest.fixture
def db_connection():
    """Fixture providing an ephemeral DuckDB connection with sample data loaded."""
    conn = duckdb.connect(":memory:")
    # Create an inline test table
    conn.execute("""
        CREATE TABLE test_txns (
            transaction_id VARCHAR,
            category VARCHAR,
            amount DECIMAL(10,2),
            quantity INTEGER
        );
        INSERT INTO test_txns VALUES 
        ('TXN-001', 'Electronics', 100.00, 2),
        ('TXN-002', 'Groceries', 50.00, 1),
        ('TXN-003', 'Electronics', 200.00, 1);
    """)
    yield conn
    conn.close()

def test_category_aggregation(db_connection):
    """Test that category revenue aggregation calculates correctly."""
    result = db_connection.execute("""
        SELECT category, SUM(amount * quantity) AS rev
        FROM test_txns
        GROUP BY category
        ORDER BY category DESC;
    %""").fetchdf() # Note: closing string literal fix below

```

Let's write `test_pipeline.py` correctly without syntax typos:

```python
# File: test_pipeline.py
import duckdb
import pytest

@pytest.fixture
def db_connection():
    conn = duckdb.connect(":memory:")
    conn.execute("""
        CREATE TABLE test_txns (
            transaction_id VARCHAR,
            category VARCHAR,
            amount DECIMAL(10,2),
            quantity INTEGER
        );
        INSERT INTO test_txns VALUES 
        ('TXN-001', 'Electronics', 100.00, 2),
        ('TXN-002', 'Groceries', 50.00, 1),
        ('TXN-003', 'Electronics', 200.00, 1);
    """)
    yield conn
    conn.close()

def test_category_aggregation(db_connection):
    result = db_connection.execute("""
        SELECT category, SUM(amount * quantity) AS rev
        FROM test_txns
        GROUP BY category
        ORDER BY category;
    """).fetchdf()
    
    # Assert row count
    assert len(result) == 2
    
    electronics_rev = result.loc[result['category'] == 'Electronics', 'rev'].values[0]
    # Electronics: (100.00 * 2) + (200.00 * 1) = 400.00
    assert electronics_rev == 400.00

def test_no_null_transactions(db_connection):
    """Ensure no transaction ID is null."""
    null_count = db_connection.execute("""
        SELECT COUNT(*) FROM test_txns WHERE transaction_id IS NULL;
    """).fetchone()[0]
    
    assert null_count == 0

```

##### 4. The Verification

Run `pytest` in your terminal:

```bash
pytest test_pipeline.py -v

```

*Expected Output:* Pytest runner output confirming that all tests passed successfully.

---

### Phase 4 Reference Section: Production Tuning & Performance Best Practices

| Tuning Parameter / Practice | Purpose | Recommended Usage |
| --- | --- | --- |
| `PRAGMA max_memory='X'` | Sets hard memory caps to force spilling on out-of-core datasets. | Set to 70-80% of container RAM limit. |
| **Partition Pruning** | Filters directory paths before reading files into memory. | Always partition large datasets by high-cardinality time dimensions (`year`, `month`). |
| **Projection Pushdown** | Only reads requested columns from disk rather than full rows. | Leverage Columnar storage layouts (Parquet) and select explicit columns. |
| `EXPLAIN` statement | Inspects the physical query execution plan and vector operators. | Run `EXPLAIN SELECT ...` to audit query efficiency before deploying to production. |

---

[GENERATED: Part 4: Production Pipelines & Lakehouse Orchestration]

---

### Series Conclusion

Congratulations! You have completed the comprehensive masterclass on **Embedded Analytics at Scale: Mastering DuckDB for Python Engineers**. You have traversed the entire architectural journey—from foundational in-process connections and zero-copy Pandas integration to advanced window functions, nested data types, and production-grade partitioned lakehouse pipelines. You are now fully equipped to build lightning-fast analytical applications without heavy database infrastructure.
