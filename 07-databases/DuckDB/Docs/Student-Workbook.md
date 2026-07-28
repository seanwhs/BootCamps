# Student Workbook: Embedded Analytics at Scale with DuckDB

---

## Welcome to the Workbook

This workbook is your companion guide for mastering **DuckDB**. Through structured labs, architecture diagrams, hands-on coding challenges, and verification checkpoints, you will transform theoretical concepts into practical engineering muscle memory.

---

## Module 1: Foundations & In-Process Architecture

### 1.1 Learning Objectives

* Understand the core architectural differences between OLTP (SQLite/PostgreSQL) and OLAP (DuckDB) engines.
* Initialize an in-process DuckDB connection via Python.
* Query raw file formats (`.csv`, `.json`, `.parquet`) directly from disk without manual schema creation.

### 1.2 Lab Exercises

#### Exercise 1.1: Establishing an In-Process Connection

Write a Python script named `lab_1_1.py` that initializes an ephemeral in-memory DuckDB connection, prints the active DuckDB version, and executes a basic scalar query (`SELECT 42;`).

```python
# Lab 1.1: In-Process Connection
import duckdb

def verify_connection():
    # TODO: Initialize an in-memory connection
    conn = duckdb.connect(database=":memory:")
    
    # TODO: Execute a test query
    result = conn.execute("SELECT 42 AS answer;").fetchone()
    print(f"DuckDB Connection Active. Answer: {result[0]}")
    
    conn.close()

if __name__ == "__main__":
    verify_connection()

```

#### Exercise 1.2: Direct Schema Inference on Raw CSVs

Using the `transactions.csv` dataset generated in our masterclass, write a script `lab_1_2.py` that uses DuckDB’s table-valued function `read_csv()` to inspect data types dynamically without staging the table.

```python
# Lab 1.2: Schema Inference
import duckdb

def inspect_schema():
    conn = duckdb.connect(":memory:")
    query = "DESCRIBE SELECT * FROM read_csv('data/transactions.csv');"
    df = conn.execute(query).fetchdf()
    print(df)
    conn.close()

if __name__ == "__main__":
    inspect_schema()

```

### 1.3 Knowledge Check

1. Why does DuckDB not require a separate server process or daemon to run?
2. What is the key advantage of a columnar storage layout over a row-oriented layout during analytical aggregations?

---

## Module 2: Zero-Copy Integration with Pandas and Arrow

### 2.1 Learning Objectives

* Execute high-performance SQL queries directly against active Pandas DataFrames in RAM.
* Understand Apache Arrow memory buffers and zero-copy data sharing.
* Benchmark performance disparities between native Pandas aggregations and DuckDB SQL vector execution.

### 2.2 Lab Exercises

#### Exercise 2.1: Querying Pandas In-Memory

Write a script `lab_2_1.py` that loads a CSV file into a Pandas DataFrame and uses DuckDB to group and aggregate the frame variable directly in SQL.

```python
# Lab 2.1: Zero-Copy Pandas Query
import duckdb
import pandas as pd

def query_pandas_frame():
    df = pd.read_csv("data/transactions.csv")
    conn = duckdb.connect(":memory:")
    
    query = """
        SELECT category, COUNT(*) AS count, SUM(amount) AS total 
        FROM df 
        GROUP BY category;
    """
    print(conn.execute(query).fetchdf())
    conn.close()

if __name__ == "__main__":
    query_pandas_frame()

```

### 2.3 Knowledge Check

1. Does DuckDB duplicate a Pandas DataFrame's memory buffers when executing a query against it? Explain why or why not.

---

## Module 3: Advanced SQL Analytics & Complex Data Types

### 3.1 Learning Objectives

* Implement time-series window functions, running totals, and moving averages.
* Work natively with nested data structures (Structs, Lists, and Arrays).
* Reshape datasets dynamically using `PIVOT` and `UNPIVOT` operators.

### 3.2 Lab Exercises

#### Exercise 3.1: Rolling Moving Averages with Window Frames

Write a script `lab_3_1.py` that creates a daily summary table and calculates a 7-day moving average using window frame specifications.

```python
# Lab 3.1: Window Functions
import duckdb

def calculate_moving_average():
    conn = duckdb.connect(":memory:")
    conn.execute("""
        CREATE TABLE daily AS 
        SELECT CAST(transaction_date AS DATE) AS d, SUM(amount) AS rev 
        FROM read_csv('data/transactions.csv') GROUP BY 1;
    """)
    
    query = """
        SELECT d, rev, 
               AVG(rev) OVER (ORDER BY d ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ma_7d 
        FROM daily LIMIT 10;
    """
    print(conn.execute(query).fetchdf())
    conn.close()

if __name__ == "__main__":
    calculate_moving_average()

```

---

## Module 4: Production Pipelines & Lakehouse Orchestration

### 4.1 Learning Objectives

* Export data into partitioned Parquet file structures for lakehouse architectures.
* Leverage partition pruning when querying glob-patterned files.
* Write automated unit tests for data pipelines using `pytest` and in-memory DuckDB fixtures.

### 4.2 Lab Exercises

#### Exercise 4.1: Pipeline Unit Testing with Pytest

Write a test suite `test_workbook_pipeline.py` using `pytest` to validate that category aggregations compute accurately against mock data.

```python
# Lab 4.1: Pipeline Unit Testing
import duckdb
import pytest

@pytest.fixture
def memory_db():
    conn = duckdb.connect(":memory:")
    conn.execute("CREATE TABLE metrics (val INT); INSERT INTO metrics VALUES (10), (20), (30);")
    yield conn
    conn.close()

def test_sum_aggregation(memory_db):
    res = memory_db.execute("SELECT SUM(val) FROM metrics;").fetchone()[0]
    assert res == 60

```

---

## Workbook Completion Certificate Checklist

* [ ] Completed Module 1 Setup & Raw Ingestion Verification
* [ ] Executed Zero-Copy Pandas Benchmarks in Module 2
* [ ] Implemented Window Functions and Structs in Module 3
* [ ] Deployed Partitioned Parquet Lakehouse and Ran Pytest Suite in Module 4
