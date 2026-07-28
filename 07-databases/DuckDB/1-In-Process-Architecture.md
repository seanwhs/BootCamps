## Part 1: Foundations & In-Process Architecture

### Module Overview

In this module, we lay the foundational understanding of how DuckDB operates differently from traditional databases. We will set up our local Python development environment, initialize an in-process DuckDB connection, and query raw files directly from disk without writing explicit schema definitions or data loading scripts.

---

### Conceptual Deep Dive: OLTP vs. OLAP and Vectorized Execution

Before writing code, it is vital to understand *why* DuckDB performs orders of magnitude faster than traditional tools for analytical tasks.

#### 1. OLTP vs. OLAP Databases

* **OLTP (Online Transaction Processing):** Databases like PostgreSQL, MySQL, and SQLite are optimized for fast individual row inserts, updates, and lookups (e.g., recording an e-commerce checkout). They store data **row by row** on disk. If you want to calculate the average price of all items sold, the database must read entire rows—including columns you do not care about (like shipping addresses and customer names)—into memory.
* **OLAP (Online Analytical Processing):** DuckDB is an OLAP database. It is optimized for complex read-heavy queries over massive datasets (e.g., "What is the total revenue grouped by product category for the last five years?"). It stores data **column by column** (columnar storage). If you only need two columns out of fifty, DuckDB reads *only* those two columns from disk, drastically reducing I/O overhead.

#### 2. In-Process Architecture

Unlike PostgreSQL or MySQL, DuckDB has **no server process**. It runs directly inside your Python application's process space, communicating via function calls rather than network sockets. This eliminates network latency, serialization overhead, and connection pooling complexity.

#### 3. Vectorized Execution

Traditional databases process tuples one by one. DuckDB processes data in **vectors** (chunks of data, typically 2048 values) that fit neatly into modern CPU L1/L2 caches. This allows the CPU to execute pipeline operations using SIMD (Single Instruction, Multiple Data) instructions.

---

### Step-by-Step Implementation

#### Step 1: Project Setup & Dependency Installation

##### 1. The Target

Initialize our project directory structure and install the required Python packages (`duckdb` and `pandas`).

##### 2. The Concept

Setting up an isolated workspace ensures our environment remains clean and reproducible. We use `venv` to isolate dependencies so that package versions do not conflict with system-wide python installations.

##### 3. The Implementation

Open your terminal and run the following commands to create the directory structure and install dependencies:

```bash
mkdir -p duckdb_masterclass/data
cd duckdb_masterclass
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install duckdb==1.1.0 pandas==2.2.3 pyarrow==17.0.0

```

Verify your `requirements.txt` file is documented by running:

```bash
pip freeze > requirements.txt

```

##### 4. The Verification

Run the following Python one-liner in your terminal to verify that DuckDB imports successfully and reports its version:

```bash
python -c "import duckdb; print('DuckDB Version:', duckdb.__version__)"

```

*Expected Output:* `DuckDB Version: 1.1.0` (or newer).

---

#### Step 2: Generating Sample Raw Data

##### 1. The Target

Create a realistic raw CSV file (`data/transactions.csv`) containing 100,000 rows of transactional records to simulate an ingestion source.

##### 2. The Concept

Before we query raw files, we need a dataset. We will write a lightweight Python script to generate synthetic retail transaction data featuring timestamps, product categories, customer IDs, and transaction amounts.

##### 3. The Implementation

Create a file named `generate_data.py`:

```python
# File: generate_data.py
import csv
import random
from datetime import datetime, timedelta

def generate_transactions(num_rows: int = 100000, output_path: str = "data/transactions.csv") -> None:
    """Generates synthetic transaction data for in-process analytical querying."""
    categories = ["Electronics", "Apparel", "Home & Garden", "Groceries", "Books"]
    start_date = datetime(2025, 1, 1)
    
    print(f"Generating {num_rows:,} rows of transaction data...")
    
    with open(output_path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        # Write header
        writer.writerow(["transaction_id", "customer_id", "category", "amount", "quantity", "transaction_date"])
        
        for i in range(1, num_rows + 1):
            tx_id = f"TXN-{i:08d}"
            cust_id = random.randint(1000, 5000)
            category = random.choice(categories)
            amount = round(random.uniform(5.0, 1500.0), 2)
            quantity = random.randint(1, 5)
            delta_days = random.randint(0, 500)
            tx_date = (start_date + timedelta(days=delta_days)).strftime("%Y-%m-%d %H:%M:%S")
            
            writer.writerow([tx_id, cust_id, category, amount, quantity, tx_date])
            
    print(f"Successfully generated {output_path}")

if __name__ == "__main__":
    generate_transactions()

```

##### 4. The Verification

Run the generation script:

```bash
python generate_data.py

```

*Expected Output:*

```text
Generating 100,000 rows of transaction data...
Successfully generated data/transactions.csv

```

Verify the file exists and check its size:

```bash
ls -lh data/transactions.csv

```

---

#### Step 3: Initializing DuckDB and Querying Raw Files Directly

##### 1. The Target

Write a Python script (`query_raw.py`) that initializes an in-process DuckDB connection and queries the raw CSV file on disk **without** explicitly loading it into a staging table or defining an explicit schema.

##### 2. The Concept

DuckDB features a suite of table-valued functions (such as `read_csv()`, `read_json()`, and `read_parquet()`). When you query these functions, DuckDB automatically sniffs the file schema (column names and data types) on the fly and streams data through its vectorized execution engine.

##### 3. The Implementation

Create a file named `query_raw.py`:

```python
# File: query_raw.py
import duckdb

def run_in_process_queries() -> None:
    # Initialize an in-process DuckDB connection (use ':memory:' for transient execution)
    # To persist data to disk, you can pass a file path like 'analytics.duckdb'
    conn = duckdb.connect(database=":memory:", read_only=False)
    
    print("--- 1. Schema Inference via read_csv ---")
    # DuckDB infers data types and headers automatically from the file stream
    schema_query = """
        DESCRIBE SELECT * FROM read_csv('data/transactions.csv');
    """
    schema_df = conn.execute(schema_query.strip()).fetchdf()
    print(schema_df)
    
    print("\n--- 2. Aggregating Raw CSV Directly ---")
    # Executing an analytical aggregation directly on the raw file on disk
    agg_query = """
        SELECT 
            category,
            COUNT(*) AS total_transactions,
            SUM(amount * quantity) AS gross_revenue,
            AVG(amount) as avg_unit_price
        FROM read_csv('data/transactions.csv')
        GROUP BY category
        ORDER BY gross_revenue DESC;
    """
    result_df = conn.execute(agg_query.strip()).fetchdf()
    print(result_df)
    
    # Clean up connection
    conn.close()

if __name__ == "__main__":
    run_in_process_queries()

```

##### 4. The Verification

Run the query script:

```bash
python query_raw.py

```

*Expected Output:* You should see the automatically inferred schema table followed by an aggregation table summarizing transactions across categories—executed entirely in-process in a fraction of a second.

---

### Phase 1 Reference Section: Core API & Configuration Options

To wrap up Phase 1, here is a quick-reference guide for configuring your DuckDB runtime environment in Python:

| Configuration Parameter | Description | Example Usage |
| --- | --- | --- |
| `database=':memory:'` | Creates an ephemeral database stored purely in RAM. Ideal for fast pipelines and testing. | `duckdb.connect(':memory:')` |
| `database='path.duckdb'` | Creates or connects to a persistent, on-disk ACID-compliant DuckDB file. | `duckdb.connect('warehouse.duckdb')` |
| `read_only=True` | Opens the database in read-only mode, allowing concurrent read connections from multiple processes. | `duckdb.connect('warehouse.duckdb', read_only=True)` |
| `threads=N` | Limits or expands the number of CPU threads DuckDB utilizes for parallel execution. | `conn.execute("PRAGMA threads=4;")` |
| `memory_limit='XGB'` | Restricts the maximum RAM DuckDB can consume before spilling data to disk. | `conn.execute("PRAGMA memory_limit='4GB';")` |
