# Student Workbook: Data Wrangling at Scale — The Definitive Pandas Guide

Welcome to the **Student Workbook**. This companion text is structured to accompany the master presentation deck and codebases. Use this workbook for taking notes during lectures, completing hands-on exercises, and serving as a quick-reference architectural cheat sheet for your production data engineering projects.

---

## Module 0: Course Overview & Technical Stack

### 0.1 Key Objectives

* Master single-node high-performance data processing using **Pandas 2.x**, **PyArrow**, and **NumPy**.
* Transition from iterative, slow Python code (`.iterrows`, `.apply`) to vectorized C-level execution.
* Build resilient, modular data pipelines incorporating schema validation, unit tests (`pytest`), and architectural logging.

### 0.2 Recommended Lab Environment

* Python 3.11+
* `pandas >= 2.0`
* `pyarrow`
* `numpy`
* `duckdb`
* `pytest`
* `dask`
* `sqlalchemy`

---

## Module 1: Architectural Primers (Primers A – C)

### 1.1 Primer A: Hardware Physics & Vectorization

* **The Memory Hierarchy:** L1/L2 cache accesses occur in nanoseconds, system RAM in hundreds of nanoseconds, NVMe storage in microseconds, and network blobs in milliseconds. Pipelines are bounded by data movement.
* **Storage Layouts:**
* *Row-Oriented (CSV, RDBMS):* Ideal for transactional writes (OLTP).
* *Column-Oriented (Parquet, Arrow):* Ideal for analytical queries (OLAP) via projection pruning.


* **Vectorization:** Bypasses the Python interpreter loop by pushing execution to compiled C routines via SIMD (Single Instruction, Multiple Data) arrays.

### 1.2 Primer B: Memory Architecture & Type Systems

* **Pointers vs. Contiguous Arrays:** Python object dtypes store scattered memory addresses (pointer chasing), causing high CPU cache miss rates. Primitive dtypes store values contiguously for optimal cache sweeps.
* **PyArrow & Nullable Extension Types:** Capitalized dtypes (`Int64`, `boolean`) support missing values (`<NA>`) natively without forcing integer series into `float64`.

### 1.3 Primer C: Relational Data Modeling & Medallion Architecture

* **Star Schemas:** Denormalized analytical models featuring central *fact tables* surrounded by descriptive *dimension tables*.
* **Medallion Architecture:** The structured data lake progression through **Bronze** (Raw), **Silver** (Cleaned & Conformed), and **Gold** (Aggregated) tiers.

---

## Module 2: Core Curriculum (Phases 1 – 5)

### Phase 1: High-Performance Ingestion & Schema Enforcement

* **Key Technique:** Always declare explicit schemas at load time and leverage `engine="pyarrow"`.
* **Memory Auditing:** Use `df.memory_usage(deep=True)` to track true RAM consumption, including object pointer headers.

### Phase 2: Slicing, Cleaning, and Vectorized Strings

* **Explicit Selection:** Prefer `.loc[]` (label-based) and `.iloc[]` (positional) over ambiguous bracket indexing.
* **String Accessor:** Clean text rapidly using vectorized `.str` methods (`.str.strip()`, `.str.lower()`, `.str.extract()`).

### Phase 3: Split-Apply-Combine Groupings & Reshaping

* **Named Aggregations:** Generate clean output schemas in `.agg()`:
```python
df.groupby("category").agg(total_rev=("revenue", "sum"))

```


* **Reshaping:** Use `pivot_table()` for wide summary matrices and `melt()` for long-format normalization.

### Phase 4: Relational Joins, Datetime Processing & Rolling Windows

* **Cardinality Validation:** Always use `validate="many_to_one"` or similar arguments in `.merge()` to catch unexpected data duplication.
* **Temporal Windows:** Leverage `.dt` accessors, `.resample()`, and `.rolling(window=N).mean()` for time-series feature engineering.

### Phase 5: Memory Optimization & DuckDB Integration

* **Categorical Encoding:** Convert low-cardinality string columns to `category` dtypes to save up to 90% RAM.
* **Eliminating `.apply()`:** Replace row-wise loops with vectorized `np.select()` or `np.where()`.
* **DuckDB:** Execute zero-copy SQL directly against active Pandas DataFrames.

---

## Module 3: Expanded Appendices (Appendices A – F)

### Appendix A: Custom Accessors & Extension Dtypes

* Register custom namespaces on DataFrames using `@pd.api.extensions.register_dataframe_accessor()`.

### Appendix B: Profiling Memory & CPU

* Use `tracemalloc` to track memory allocation spikes line-by-line and `cProfile` to isolate slow Python function calls.

### Appendix C: Out-of-Core Processing

* Process massive files exceeding RAM using `pd.read_csv(chunksize=N)` or scale horizontally via **Dask DataFrames** and lazy task graphs.

### Appendix D: Pipeline Testing & Orchestration

* Write unit tests for data logic using `pytest` and construct structured DAG execution wrappers with custom decorators and logging.

### Appendix E: Asynchronous Stream Ingestion

* Use `asyncio` and `asyncio.gather()` to concurrently fetch non-blocking real-time event stream batches.

### Appendix F: Database Sinks & Partitioned Parquet

* Persist cleaned dataframes via `df.to_sql()` with chunked inserts, or write partition directory trees using `df.to_parquet(partition_cols=[...])`.

---

## Module 4: Student Exercises & Checkpoints

### Exercise 1: Ingestion & Schema Enforcement

* *Task:* Write an ingestion function that reads a 50,000-row CSV file, enforces an explicit PyArrow schema, and prints the deep memory footprint.
* *Checkpoint:* Did the memory footprint drop significantly compared to default object dtypes?

### Exercise 2: Replacing `.apply()` with Vectorization

* *Task:* Take a slow `.apply(lambda row: ..., axis=1)` function that calculates a tiered discount and rewrite it using `np.select()`.
* *Checkpoint:* Measure the execution time difference. (Expect a 100x+ speedup).

### Exercise 3: Star Schema Enrichment & Aggregation

* *Task:* Merge a fact table of orders with a dimension table of products using a validated left join, then group by category with named aggregations.
* *Checkpoint:* Verify that row counts match expectations and no duplicate keys were introduced.

### Exercise 4: Unit Testing Core Logic

* *Task:* Write a `pytest` test function that asserts a net revenue calculation function handles mock data correctly within a tolerance threshold (`pytest.approx`).
* *Checkpoint:* Run `pytest -v` and confirm all test suites pass successfully.
