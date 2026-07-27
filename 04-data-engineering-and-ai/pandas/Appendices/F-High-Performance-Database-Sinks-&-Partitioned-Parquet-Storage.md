# Appendix F: High-Performance Database Sinks & Partitioned Parquet Storage

Welcome to **Appendix F**. Having covered ingestion, transformation, optimization, profiling, and asynchronous streaming, this final appendix focuses on persistence: writing high-throughput processed DataFrames directly to relational databases using SQLAlchemy and partitioning large datasets to disk via Apache Arrow.

---

## 1. High-Speed Relational Database Sinks (`to_sql`)

### 1.1 The Target

Persist cleaned Pandas DataFrames efficiently into a relational database (SQLite/PostgreSQL) using chunked database insertion via SQLAlchemy.

### 1.2 The Implementation

Create a script named `appx_10_db_sink.py`:

```python
# appx_10_db_sink.py
"""
Appendix F.1: Relational Database Persistence
Demonstrates high-throughput batch insertion of Pandas DataFrames via SQLAlchemy.
"""

import pandas as pd
from sqlalchemy import create_engine
from 02_ingestion_pipeline import load_orders_csv


def persist_dataframe_to_sql() -> None:
    print("--- 1. Loading Processed Dataset ---")
    df = load_orders_csv("raw_data/orders.csv").head(10_000)

    print("--- 2. Initializing SQLAlchemy SQLite Engine ---")
    # In-memory or local SQLite database engine
    engine = create_engine("sqlite:///warehouse.db", echo=False)

    print("--- 3. Executing Chunked Database Insert ---")
    # Write dataframe to table in batches to optimize memory and connection stability
    df.to_sql(
        name="fact_orders",
        con=engine,
        if_exists="replace",
        index=False,
        chunksize=2_000,
        method="multi",  # Enables multi-row INSERT optimization
    )

    print("Successfully persisted 10,000 records to SQLite table 'fact_orders'.")

    # Verify write via a quick query
    verification_df = pd.read_sql("SELECT COUNT(*) AS row_count FROM fact_orders;", con=engine)
    print(f"Database Verification Row Count: {verification_df['row_count'].iloc[0]:,}")


if __name__ == "__main__":
    persist_dataframe_to_sql()

```

### 1.3 The Verification

Run the database sink script:

```bash
python appx_10_db_sink.py

```

#### Verification Output:

```text
--- 1. Loading Processed Dataset ---
--- 2. Initializing SQLAlchemy SQLite Engine ---
--- 3. Executing Chunked Database Insert ---
Successfully persisted 10,000 records to SQLite table 'fact_orders'.
Database Verification Row Count: 10,000

```

---

## 2. Partitioned Parquet Storage (`to_parquet(partition_cols=...)`)

### 1.1 The Target

Partition large datasets physically on disk by categorical dimensions (e.g., year, region) to enable blazing-fast partition pruning during subsequent reads.

### 1.2 The Implementation

Create a script named `appx_11_parquet_partitioning.py`:

```python
# appx_11_parquet_partitioning.py
"""
Appendix F.2: Partitioned Parquet Storage
Demonstrates writing partitioned columnar datasets for high-performance retrieval.
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def write_partitioned_parquet() -> None:
    print("--- 1. Loading and Enriching Dataset ---")
    df = load_orders_csv("raw_data/orders.csv").head(20_000)
    
    # Extract partition column
    df["order_year"] = df["timestamp"].dt.year
    df["order_month"] = df["timestamp"].dt.month

    print("--- 2. Writing Partitioned Parquet Dataset to Disk ---")
    # Writes directory tree structured as order_year=YYYY/order_month=MM/
    df.to_parquet(
        "partitioned_warehouse/",
        partition_cols=["order_year", "order_month"],
        engine="pyarrow",
        index=False,
    )

    print("Successfully wrote partitioned Parquet dataset to 'partitioned_warehouse/'.")


if __name__ == "__main__":
    write_partitioned_parquet()

```

### 1.3 The Verification

Run the partitioning script:

```bash
python appx_11_parquet_partitioning.py

```

#### Verification Output:

```text
--- 1. Loading and Enriching Dataset ---
--- 2. Writing Partitioned Parquet Dataset to Disk ---
Successfully wrote partitioned Parquet dataset to 'partitioned_warehouse/'.

```
