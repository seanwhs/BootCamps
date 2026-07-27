# Appendix C: Out-of-Core Processing with Dask & Chunked Readers

Welcome to **Appendix C**. When datasets exceed your system RAM, standard Pandas fails with memory errors. This appendix covers strategies for scaling beyond single-node memory limits using two primary approaches:

1. **Chunked Iteration:** Processing massive CSV/Parquet files sequentially in memory-safe batches (`chunksize`).
2. **Out-of-Core Distributed Processing:** Using **Dask** to execute lazy, parallelized Pandas operations across multiple CPU cores.

---

## 1. Chunked File Processing (`pd.read_csv(chunksize=N)`)

### 1.1 The Target

Process a massive CSV file that exceeds available RAM by reading and aggregating it sequentially in configurable row batches.

### 1.2 The Concept

Instead of loading a 10 GB file into memory all at once, `pd.read_csv()` accepts a `chunksize` parameter which returns an iterable `TextFileReader` object. You can iterate through chunks, perform localized aggregations or cleaning steps, and accumulate only the final summary results.

### 1.3 The Implementation

Create a script named `appx_05_chunked_processing.py`:

```python
# appx_05_chunked_processing.py
"""
Appendix C.1: Memory-Safe Chunked Processing
Demonstrates sequential file iteration and aggregation using chunksize.
"""

import pandas as pd


def process_file_in_chunks(file_path: str, chunk_size: int = 10_000) -> None:
    print(f"--- 1. Initializing Chunked Reader (Chunk Size: {chunk_size:,}) ---")
    
    total_rows = 0
    total_gross_revenue = 0.0
    payment_method_counts = pd.Series(dtype="int64")

    # Iterate through file chunks sequentially
    for chunk_idx, chunk in enumerate(pd.read_csv(file_path, chunksize=chunk_size)):
        total_rows += len(chunk)
        
        # Calculate revenue for current chunk
        chunk_revenue = (chunk["quantity"] * chunk["unit_price"]).sum()
        total_gross_revenue += chunk_revenue

        # Aggregate categorical distribution locally
        chunk_counts = chunk["payment_method"].value_counts()
        payment_method_counts = payment_method_counts.add(chunk_counts, fill_value=0)

        print(f"Processed Chunk {chunk_idx + 1} | Rows: {len(chunk):,} | Running Revenue: ${total_gross_revenue:,.2f}")

    print("\n--- 2. Final Aggregated Results ---")
    print(f"Total Rows Processed : {total_rows:,}")
    print(f"Total Gross Revenue  : ${total_gross_revenue:,.2f}")
    print("\nPayment Method Breakdown:")
    print(payment_method_counts.astype(int))


if __name__ == "__main__":
    process_file_in_chunks("raw_data/orders.csv", chunk_size=15_000)

```

### 1.4 The Verification

Run the chunked processing script:

```bash
python appx_05_chunked_processing.py

```

#### Verification Output:

```text
--- 1. Initializing Chunked Reader (Chunk Size: 15,000) ---
Processed Chunk 1 | Rows: 15,000 | Running Revenue: $9,384,102.50
Processed Chunk 2 | Rows: 15,000 | Running Revenue: $18,745,210.00
Processed Chunk 3 | Rows: 15,000 | Running Revenue: $28,110,405.25
Processed Chunk 4 | Rows: 5,000 | Running Revenue: $31,241,500.00

--- 2. Final Aggregated Results ---
Total Rows Processed : 50,000
Total Gross Revenue  : $31,241,500.00

Payment Method Breakdown:
Credit Card    16750
PayPal         12500
Crypto         10450
Cash            10300
dtype: int64

```

---

## 2. Distributed Scaling with Dask DataFrames

### 2.1 The Target

Scale Pandas-compatible workflows across all available local CPU cores using **Dask** for lazy evaluation and parallel out-of-core computation.

### 2.2 The Concept

Dask provides a parallel computing library that mimics the Pandas API. Instead of executing code immediately, Dask builds a **task graph** of operations lazily. When you call `.compute()`, Dask optimizes the graph and schedules task execution across multi-core thread pools or worker processes simultaneously.

```
       DASK LAZY TASK GRAPH                    PARALLEL EXECUTION (Multi-Core)
   +--------------------------+             +----------------------------------+
   | Read CSV (Partition 1)   | -------->   | Core 1: Filter & Aggregate Part 1|
   | Read CSV (Partition 2)   | -------->   | Core 2: Filter & Aggregate Part 2|
   | Read CSV (Partition 3)   | -------->   | Core 3: Filter & Aggregate Part 3|
   +--------------------------+             +----------------------------------+
   Lazy Evaluation Pipeline                   Concurrent Multi-Core Compute

```

### 2.3 The Implementation

Create a script named `appx_06_dask_scaling.py`:

```python
# appx_06_dask_scaling.py
"""
Appendix C.2: Out-of-Core Processing via Dask
Demonstrates lazy evaluation and multi-core parallel DataFrame operations.
"""

import dask.dataframe as dd


def execute_dask_pipeline() -> None:
    print("--- 1. Initializing Lazy Dask DataFrame ---")
    # Read CSV using Dask (automatically partitions file across blocks)
    ddf = dd.read_csv("raw_data/orders.csv")

    print(f"Dask Partition Count: {ddf.npartitions}")
    print(f"Lazy Schema Definition:\n{ddf.dtypes}")

    print("\n--- 2. Building Lazy Transformation Graph ---")
    # Define operations (executed lazily without holding full data in RAM yet)
    ddf["total_revenue"] = ddf["quantity"] * ddf["unit_price"]
    
    # Groupby aggregation across lazy partitions
    summary_ddf = (
        ddf.groupby("payment_method")
        .agg({"total_revenue": "sum", "order_id": "count"})
        .rename(columns={"order_id": "order_count"})
    )

    print("Task Graph Built Successfully. Triggering Parallel Compute...")

    print("\n--- 3. Executing .compute() ---")
    # Triggers parallel multi-core execution
    result_df = summary_ddf.compute()

    print("\nComputed Dask Results:")
    print(result_df)


if __name__ == "__main__":
    execute_dask_pipeline()

```

### 2.4 The Verification

Run the Dask scaling script:

```bash
python appx_06_dask_scaling.py

```

#### Verification Output:

```text
--- 1. Initializing Lazy Dask DataFrame ---
Dask Partition Count: 1
Lazy Schema Definition:
order_id            int64
customer_id        object
product_id         object
quantity            int64
unit_price        float64
timestamp          object
payment_method     object
dtype: object

--- 2. Building Lazy Transformation Graph ---
Task Graph Built Successfully. Triggering Parallel Compute...

--- 3. Executing .compute() ---

Computed Dask Results:
                total_revenue  order_count
payment_method                            
Cash               6420102.00        10300
Credit Card       10450120.50        16750
Crypto             6512040.25        10450
PayPal             7859237.25        12500

```
