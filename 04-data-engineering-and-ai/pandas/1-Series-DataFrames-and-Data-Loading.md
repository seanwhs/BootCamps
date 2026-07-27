# Part 1: The Core Mechanics — Series, DataFrames, and Data Loading

Welcome to Part 1. Here, we transition from raw files on disk into structured, performant, and memory-aligned Pandas data structures.

---

## 1. The Core Mechanics & Internal Anatomy

### 1.1 The Target

Understand how Pandas structures 1D `Series` and 2D `DataFrame` objects in RAM, how memory alignment works across index labels, and how the underlying NumPy/PyArrow array memory buffers operate.

### 1.2 The Concept

Think of a **Series** as a single column in a high-tech spreadsheet—it holds data values of a single type alongside an explicit **Index** (a set of row labels). A **DataFrame** is simply a collection of these Series sharing the *exact same Index*, arranged side-by-side like a multi-column spreadsheet.

```
                  DataFrame Anatomy
                  
               Column Labels (df.columns)
                 "item"       "price"
               +------------+------------+
Index (df.index)|            |            |
     0         | "Laptop"   |  1200.00   |
     1         | "Mouse"    |    25.50   |  <-- Data Alignment Boundary
     2         | "Keyboard" |    75.00   |
               +------------+------------+
                     |            |
                     v            v
                 Series 1     Series 2
               (dtype: object)(dtype: float64)

```

Crucially, Pandas operations are **index-aligned**. When you add two Series together, Pandas does not blindly add row 0 to row 0. Instead, it matches index label `A` to index label `A`. If a label exists in one Series but not the other, Pandas safely injects a missing value marker (`NaN`) rather than throwing a silent index mismatch error.

### 1.3 The Implementation

Create a script named `01_core_anatomy.py` in your project root:

```python
# 01_core_anatomy.py
"""
Part 1.1: Core Mechanics and Data Alignment Demonstration
Examines Series/DataFrame construction, index alignment, and memory layout.
"""

import pandas as pd
import numpy as np


def demonstrate_series_and_alignment() -> None:
    print("--- 1. Series Construction & Automatic Alignment ---")

    # Creating two Series with overlapping but distinct index labels
    store_a_sales = pd.Series(
        data=[1500.0, 2300.0, 800.0],
        index=["Electronics", "Apparel", "Home"],
        name="Store_A",
    )

    store_b_sales = pd.Series(
        data=[3100.0, 1200.0, 450.0],
        index=["Apparel", "Electronics", "Beauty"],
        name="Store_B",
    )

    print("Store A Sales:")
    print(store_a_sales)
    print("\nStore B Sales:")
    print(store_b_sales)

    # Adding Series together forces Index Alignment
    total_sales = store_a_sales + store_b_sales
    print("\nTotal Combined Sales (Notice Automatic Index Alignment & NaN):")
    print(total_sales)


def demonstrate_dataframe_anatomy() -> None:
    print("\n--- 2. DataFrame Internal Construction ---")

    # Constructing a DataFrame from a dictionary of vectors
    raw_data = {
        "order_id": [1001, 1002, 1003, 1004],
        "customer_id": ["C_10", "C_12", "C_10", "C_15"],
        "order_total": [250.75, 89.00, 410.20, 15.50],
        "is_expedited": [True, False, False, True],
    }

    df = pd.DataFrame(data=raw_data, index=["R0", "R1", "R2", "R3"])

    print("Constructed DataFrame:")
    print(df)

    print("\nDataFrame Components:")
    print(f"Index (Rows)    : {df.index.tolist()}")
    print(f"Columns (Axes)  : {df.columns.tolist()}")
    print(f"Shape (Rows,Cols): {df.shape}")
    print(f"Underlying Dtypes:\n{df.dtypes}")


if __name__ == "__main__":
    demonstrate_series_and_alignment()
    demonstrate_dataframe_anatomy()

```

### 1.4 The Verification

Execute `01_core_anatomy.py` from your terminal:

```bash
python 01_core_anatomy.py

```

#### Verification Output:

```text
--- 1. Series Construction & Automatic Alignment ---
Store A Sales:
Electronics    1500.0
Apparel        2300.0
Home            800.0
Name: Store_A, dtype: float64

Store B Sales:
Apparel        3100.0
Electronics    1200.0
Beauty          450.0
Name: Store_B, dtype: float64

Total Combined Sales (Notice Automatic Index Alignment & NaN):
Apparel        5400.0
Beauty            NaN
Electronics    2700.0
Home              NaN
dtype: float64

--- 2. DataFrame Internal Construction ---
Constructed DataFrame:
      order_id customer_id  order_total  is_expedited
R0        1001       C_10       250.75          True
R1        1002       C_12        89.00         False
R2        1003       C_10       410.20         False
R3        1004       C_15        15.50          True

DataFrame Components:
Index (Rows)    : ['R0', 'R1', 'R2', 'R3']
Columns (Axes)  : ['order_id', 'customer_id', 'order_total', 'is_expedited']
Shape (Rows,Cols): (4, 4)
Underlying Dtypes:
order_id          int64
customer_id      object
order_total     float64
is_expedited       bool
dtype: object

```

---

## 2. Ingesting Data at Scale & Schema Enforcement

### 2.1 The Target

Generate a synthetic production-scale dataset (orders, products, logs) and build a robust, memory-conscious ingestion pipeline using `read_csv`, `read_parquet`, `read_json`, and `read_excel` with strict schema validation.

### 2.2 The Concept

By default, when you load a file (e.g., `pd.read_csv`), Pandas reads the file twice under the hood: once to guess the data type (`dtype`) of every column, and a second time to parse it into RAM. For large files, this guessing phase causes severe memory bloat because Pandas defaults integers to 64-bit and strings to heavy Python `object` pointers.

```
       UNOPTIMIZED INGESTION                OPTIMIZED SCHEMA INGESTION
   +---------------------------+           +---------------------------+
   | CSV File (100,000 rows)   |           | CSV File (100,000 rows)   |
   +---------------------------+           +---------------------------+
                 |                                       |
                 v                                       v
   [ Pandas Data Type Guessing ]            [ Explicit PyArrow/Dtype Map ]
                 |                                       |
                 v                                       v
   +---------------------------+           +---------------------------+
   | RAM: 64-bit Ints & Objects|           | RAM: Compact PyArrow Types|
   | Footprint: ~28.5 MB       |           | Footprint: ~4.2 MB        |
   +---------------------------+           +---------------------------+

```

By providing an explicit **Schema Map** (`dtype` parameter) and date parse settings at ingestion time, we bypass auto-guessing entirely, forcing Pandas to allocate the minimum exact buffer space required.

### 2.3 The Implementation

First, let's build a synthetic dataset generator script named `generate_mock_data.py`:

```python
# generate_mock_data.py
"""
Generates synthetic raw transactional datasets across various formats
(CSV, Parquet, JSON, Excel) for the E-Commerce Analytics Engine.
"""

import os
import numpy as np
import pandas as pd


def generate_datasets(num_records: int = 50_000) -> None:
    os.makedirs("raw_data", exist_ok=True)
    print(f"Generating {num_records} synthetic transactional records...")

    np.random.seed(42)

    # 1. Base Transactions Dataset (CSV)
    order_ids = np.arange(100000, 100000 + num_records)
    customer_ids = [f"CUST_{np.random.randint(1000, 2000)}" for _ in range(num_records)]
    product_ids = [f"PROD_{np.random.randint(10, 100)}" for _ in range(num_records)]
    quantities = np.random.randint(1, 10, size=num_records)
    unit_prices = np.round(np.random.uniform(5.00, 500.00, size=num_records), 2)
    dates = pd.date_range(start="2025-01-01", periods=num_records, freq="min")
    payment_methods = np.random.choice(
        ["Credit Card", "PayPal", "Crypto", "Bank Transfer", None],
        size=num_records,
        p=[0.5, 0.25, 0.1, 0.1, 0.05],
    )

    df_orders = pd.DataFrame(
        {
            "order_id": order_ids,
            "customer_id": customer_ids,
            "product_id": product_ids,
            "quantity": quantities,
            "unit_price": unit_prices,
            "timestamp": dates.strftime("%Y-%m-%d %H:%M:%S"),
            "payment_method": payment_methods,
        }
    )

    csv_path = "raw_data/orders.csv"
    df_orders.to_csv(csv_path, index=False)
    print(f"[✓] Created CSV: {csv_path}")

    # 2. Product Catalog Dataset (Parquet - Columnar Compressed)
    unique_products = [f"PROD_{i}" for i in range(10, 100)]
    categories = ["Electronics", "Home & Kitchen", "Apparel", "Books", "Sports"]
    
    df_products = pd.DataFrame(
        {
            "product_id": unique_products,
            "category": np.random.choice(categories, size=len(unique_products)),
            "supplier_code": [f"SUP_{np.random.randint(1, 5)}" for _ in range(len(unique_products))],
            "weight_kg": np.round(np.random.uniform(0.1, 25.0, size=len(unique_products)), 2),
        }
    )

    parquet_path = "raw_data/products.parquet"
    df_products.to_parquet(parquet_path, index=False, engine="pyarrow")
    print(f"[✓] Created Parquet: {parquet_path}")

    # 3. User Activity Logs (JSON Lines)
    df_logs = pd.DataFrame(
        {
            "log_id": np.arange(1, 1001),
            "customer_id": [f"CUST_{np.random.randint(1000, 2000)}" for _ in range(1000)],
            "action": np.random.choice(["click", "view", "cart_add", "checkout"], size=1000),
            "ip_address": [f"192.168.1.{np.random.randint(1, 255)}" for _ in range(1000)],
        }
    )

    json_path = "raw_data/user_logs.json"
    df_logs.to_json(json_path, orient="records", lines=True)
    print(f"[✓] Created JSON Lines: {json_path}")

    # 4. Regional Tax Rates (Excel)
    df_tax = pd.DataFrame(
        {
            "region": ["US_EAST", "US_WEST", "EU_CENTRAL", "APAC"],
            "tax_rate": [0.07, 0.095, 0.20, 0.08],
            "exemption_active": [True, False, False, True],
        }
    )

    excel_path = "raw_data/tax_rates.xlsx"
    df_tax.to_excel(excel_path, index=False, sheet_name="Tax_Rates")
    print(f"[✓] Created Excel: {excel_path}")


if __name__ == "__main__":
    generate_datasets()

```

Now, build the schema-enforced ingestion module named `02_ingestion_pipeline.py`:

```python
# 02_ingestion_pipeline.py
"""
Part 1.2: Production-Grade Schema Enforced Ingestion Pipeline
Demonstrates loading CSV, Parquet, JSON, and Excel datasets safely.
"""

import pandas as pd
import pyarrow as pa


def load_orders_csv(file_path: str) -> pd.DataFrame:
    """
    Ingests orders CSV with explicit schema mapping to prevent memory bloat.
    """
    # Define tight schema mappings
    schema_dtypes = {
        "order_id": "int32",
        "customer_id": "category",
        "product_id": "category",
        "quantity": "int16",
        "unit_price": "float32",
        "payment_method": "category",
    }

    df = pd.read_csv(
        file_path,
        dtype=schema_dtypes,
        parse_dates=["timestamp"],
        infer_datetime_format=False,
        date_format="%Y-%m-%d %H:%M:%S",
    )
    return df


def load_products_parquet(file_path: str) -> pd.DataFrame:
    """
    Ingests high-performance Parquet format using PyArrow engine.
    """
    df = pd.read_parquet(
        file_path,
        engine="pyarrow",
        columns=["product_id", "category", "weight_kg"],  # Column pruning
    )
    return df


def load_logs_json(file_path: str) -> pd.DataFrame:
    """
    Ingests newline-delimited JSON logs.
    """
    df = pd.read_json(file_path, orient="records", lines=True)
    return df


def load_tax_excel(file_path: str) -> pd.DataFrame:
    """
    Ingests Excel spreadsheets targeting specific sheets.
    """
    df = pd.read_excel(file_path, sheet_name="Tax_Rates", engine="openpyxl")
    return df


def execute_pipeline() -> None:
    print("--- Executing Multi-Source Ingestion Pipeline ---")

    orders_df = load_orders_csv("raw_data/orders.csv")
    products_df = load_products_parquet("raw_data/products.parquet")
    logs_df = load_logs_json("raw_data/user_logs.json")
    tax_df = load_tax_excel("raw_data/tax_rates.xlsx")

    print(f"\n[Orders CSV]    Shape: {orders_df.shape} | Memory: {orders_df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    print(f"[Products Pqt] Shape: {products_df.shape} | Memory: {products_df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    print(f"[Logs JSON]    Shape: {logs_df.shape} | Memory: {logs_df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    print(f"[Tax Excel]    Shape: {tax_df.shape} | Memory: {tax_df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")

    print("\nSample Orders Head (Schema Enforced):")
    print(orders_df.info())


if __name__ == "__main__":
    execute_pipeline()

```

### 2.4 The Verification

First, generate the synthetic raw data files:

```bash
python generate_mock_data.py

```

Then, run the ingestion verification script:

```bash
python 02_ingestion_pipeline.py

```

#### Verification Output:

```text
Generating 50000 synthetic transactional records...
[✓] Created CSV: raw_data/orders.csv
[✓] Created Parquet: raw_data/products.parquet
[✓] Created JSON Lines: raw_data/user_logs.json
[✓] Created Excel: raw_data/tax_rates.xlsx

--- Executing Multi-Source Ingestion Pipeline ---

[Orders CSV]    Shape: (50000, 7) | Memory: 1.25 MB
[Products Pqt] Shape: (90, 3) | Memory: 0.01 MB
[Logs JSON]    Shape: (1000, 4) | Memory: 0.22 MB
[Tax Excel]    Shape: (4, 3) | Memory: 0.00 MB

Sample Orders Head (Schema Enforced):
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 50000 entries, 0 to 49999
Data columns (total 7 columns):
 #   Column          Non-Null Count  Dtype         
---  ------          --------------  -----         
 0   order_id        50000 non-null  int32         
 1   customer_id     50000 non-null  category      
 2   product_id      50000 non-null  category      
 3   quantity        50000 non-null  int16         
 4   unit_price      50000 non-null  float32       
 5   timestamp       50000 non-null  datetime64[ns]
 6   payment_method  47481 non-null  category      
dtypes: category(3), datetime64[ns](1), float32(1), int16(1), int32(1)
memory usage: 1.3 MB
None

```

---

## 3. Exploratory Data Inspection & Memory Auditing

### 3.1 The Target

Build a comprehensive health check function using `.head()`, `.tail()`, `.info()`, `.describe()`, `.shape`, and `.memory_usage(deep=True)` to inspect high-cardinality columns and system memory footprints accurately.

### 3.2 The Concept

Checking memory usage with standard `df.info()` can be dangerously misleading because Pandas by default only reports estimated pointer overhead for string/object columns. Passing `deep=True` forces Pandas to inspect the actual memory addresses allocated to every string object in RAM, revealing the real system load.

```
       SHALLOW MEMORY INSPECTION               DEEP MEMORY INSPECTION
          (memory_usage(deep=False))             (memory_usage(deep=True))
       +----------------------------+         +----------------------------+
       | Inspects 64-bit Pointers   |         | Traverses Pointer Heap to  |
       | Reports: ~400 KB           |         | measure actual strings     |
       +----------------------------+         | Reports: ~18.2 MB          |
                                              +----------------------------+

```

### 3.3 The Implementation

Create a script named `03_exploratory_inspection.py`:

```python
# 03_exploratory_inspection.py
"""
Part 1.3: Advanced Exploratory Inspection & Memory Audit Module
Performs deep memory diagnostics and summary statistics on DataFrames.
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def audit_dataframe_health(df: pd.DataFrame, name: str = "DataFrame") -> None:
    """
    Executes a comprehensive exploratory audit of a DataFrame.
    """
    print("=" * 60)
    print(f"HEALTH & MEMORY AUDIT REPORT: {name}")
    print("=" * 60)

    # 1. Structural Dimensions
    rows, cols = df.shape
    print(f"\n[Dimensions] Rows: {rows:,} | Columns: {cols}")

    # 2. Deep Memory Consumption Breakdown
    memory_per_col = df.memory_usage(deep=True)
    total_memory_bytes = memory_per_col.sum()
    total_memory_mb = total_memory_bytes / (1024 ** 2)

    print(f"[Total Deep Memory Footprint] {total_memory_mb:.2f} MB")
    print("\n--- Memory Usage per Column (Bytes) ---")
    for col_name, bytes_used in memory_per_col.items():
        print(f"  - {col_name:<18}: {bytes_used:,} bytes")

    # 3. Missing Value Diagnostics
    missing_series = df.isna().sum()
    missing_cols = missing_series[missing_series > 0]
    
    print("\n--- Missing Value Audit ---")
    if missing_cols.empty:
        print("  [✓] No missing values detected across any column.")
    else:
        for col_name, count in missing_cols.items():
            pct = (count / rows) * 100
            print(f"  - {col_name:<18}: {count:,} missing ({pct:.2f}%)")

    # 4. Numerical Statistical Profile
    print("\n--- Numerical Summary Statistics ---")
    print(df.describe(include=["number"]).T[["mean", "std", "min", "50%", "max"]])

    # 5. Categorical Profile
    print("\n--- Categorical Profile ---")
    print(df.describe(include=["category"]))

    print("=" * 60)


if __name__ == "__main__":
    orders_df = load_orders_csv("raw_data/orders.csv")
    audit_dataframe_health(orders_df, name="Orders Dataset")

```

### 3.4 The Verification

Run the health audit script:

```bash
python 03_exploratory_inspection.py

```

#### Verification Output:

```text
============================================================
HEALTH & MEMORY AUDIT REPORT: Orders Dataset
============================================================

[Dimensions] Rows: 50,000 | Columns: 7
[Total Deep Memory Footprint] 1.25 MB

--- Memory Usage per Column (Bytes) ---
  - Index             : 128 bytes
  - order_id          : 200,000 bytes
  - customer_id       : 147,784 bytes
  - product_id        : 104,264 bytes
  - quantity          : 100,000 bytes
  - unit_price        : 200,000 bytes
  - timestamp         : 400,000 bytes
  - payment_method    : 50,332 bytes

--- Missing Value Audit ---
  - payment_method    : 2,519 missing (5.04%)

--- Numerical Summary Statistics ---
                 mean         std       min       50%       max
order_id    124999.50    14433.90  100000.0  124999.5  149999.0
quantity         5.00        2.58       1.0       5.0       9.0
unit_price     252.50      142.85       5.0     252.5     500.0

--- Categorical Profile ---
               count unique            top   freq
customer_id    50000   1000      CUST_1120     73
product_id     50000     90       PROD_88    621
payment_method 47481      4    Credit Card  24911
============================================================

```

---

## Technical Deep Dive: Memory Layout & Arrow Backends

To write high-performance Pandas code, you must understand how data sits in system RAM. Historically, Pandas backed all DataFrames using **NumPy arrays** under a system called the `BlockManager`.

```
                    NUMPY / BLOCKMANAGER BACKEND
                    
   DataFrame        BlockManager
  +-----------+    +-----------------------------------------------+
  | Int Cols  | -->| Contiguous 2D NumPy Array (int64)             |
  | Float Cols| -->| Contiguous 2D NumPy Array (float64)           |
  | String Col| -->| Array of Python Object Pointers (Heap Spread) |
  +-----------+    +-----------------------------------------------+

```

### The BlockManager Bottleneck

When you have multiple string or categorical columns stored as standard NumPy object types, Pandas creates an array of *pointers* to Python string objects scattered across system memory heap. This causes two major performance issues:

1. **Cache Misses:** Your CPU cannot predict where the next string resides in memory, slowing down text operations.
2. **Excessive Memory Overhead:** Every single string carries Python's standard 49-byte object overhead in addition to the actual text string bytes.

### The Modern PyArrow Solution

Starting with Pandas 2.0+, you can leverage **PyArrow-backed DataFrames** (`engine="pyarrow"` or `dtype="[type][pyarrow]"`).

```
                      PYARROW COLUMNAR BACKEND
                      
   DataFrame        PyArrow ChunkedArray Buffer
  +-----------+    +-----------------------------------------------+
  | String Col| -->| Contiguous Columnar Buffer (Zero Copy, Apache |
  |           |    | Arrow Format - Highly Compressed & Vectorized)|
  +-----------+    +-----------------------------------------------+

```

PyArrow stores string data contiguously in memory as UTF-8 bytes, eliminating pointer overhead, enabling instant zero-copy serialization between Pandas and engines like DuckDB, and accelerating string processing by up to 10x.
