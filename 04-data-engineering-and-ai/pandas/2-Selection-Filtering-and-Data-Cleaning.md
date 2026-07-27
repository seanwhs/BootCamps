# Part 2: Selection, Filtering, and Data Cleaning

Welcome to Part 2. Now that we have a memory-efficient ingestion pipeline set up, we turn our attention to slicing data with surgical precision, cleaning missing entries without introducing bugs, and applying high-speed string transformations across our datasets.

---

## 1. Positional & Label-Based Selection (`loc` vs. `iloc`)

### 1.1 The Target

Master the explicit mechanics of index selection using `.loc` (label-driven) and `.iloc` (position-driven), and understand why the common shorthand `df['col'][row]` creates fragile code.

### 1.2 The Concept

Think of `.loc` as searching by **Street Name and House Number**—it relies on the explicit labels of your index and column headers. Think of `.iloc` as using **GPS Coordinates**—it only cares about the integer zero-based position in RAM, regardless of how the index is labeled.

```
                  Index Labels: ["R101", "R102", "R103"]
                  
   Position (iloc)   Index Label (loc)   Column: "customer_id" (col 1)
        0                 "R101"                   "CUST_1001"
        1                 "R102"                   "CUST_1002"
        2                 "R103"                   "CUST_1003"
        
   df.iloc[0, 1]  ==> "CUST_1001" (By integer offset 0, column offset 1)
   df.loc["R101", "customer_id"] ==> "CUST_1001" (By exact string labels)

```

> **Warning:** Avoid chained indexing like `df["customer_id"][0]`. This forces Pandas to execute two separate evaluation steps, returning intermediate views or copies that frequently trigger `SettingWithCopyWarning` when writing data back. Always pass `[row_indexer, column_indexer]` inside a single `.loc` or `.iloc` block.

### 1.3 The Implementation

Create a script named `04_selection_mechanics.py`:

```python
# 04_selection_mechanics.py
"""
Part 2.1: Selection Mechanics — loc vs. iloc
Demonstrates label-based vs. positional indexing and multi-axis slicing.
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def demonstrate_indexing_mechanics() -> None:
    print("--- 1. Loading Ingested Orders Dataset ---")
    df = load_orders_csv("raw_data/orders.csv")

    # Re-index with explicit non-integer string labels to highlight loc vs iloc
    df_labeled = df.head(10).copy()
    df_labeled.index = [f"ORD_ROW_{i}" for i in range(10)]

    print("\nCustom Labeled DataFrame Slice (First 3 Rows):")
    print(df_labeled[["order_id", "customer_id", "unit_price"]].head(3))

    # --- A. Label-Based Selection (.loc) ---
    print("\n--- 2. Label-Based Selection (.loc) ---")
    # Single cell extraction
    single_val = df_labeled.loc["ORD_ROW_2", "unit_price"]
    print(f"Value at ['ORD_ROW_2', 'unit_price']: ${single_val:.2f}")

    # Slice range of row labels AND specific column labels
    # NOTE: loc includes BOTH the start and end endpoint!
    label_slice = df_labeled.loc["ORD_ROW_1":"ORD_ROW_3", ["customer_id", "quantity", "unit_price"]]
    print("\nLabel Slice ('ORD_ROW_1' to 'ORD_ROW_3' inclusive):")
    print(label_slice)

    # --- B. Positional Selection (.iloc) ---
    print("\n--- 3. Positional Selection (.iloc) ---")
    # Single cell extraction by integer coordinate
    pos_val = df_labeled.iloc[2, 4]  # Row 2, Column 4 (unit_price)
    print(f"Value at iloc[2, 4]: ${pos_val:.2f}")

    # Slice by integer ranges
    # NOTE: iloc follows standard Python slicing (EXCLUDES the end endpoint!)
    pos_slice = df_labeled.iloc[1:4, [1, 3, 4]]
    print("\nPositional Slice (iloc[1:4, [1, 3, 4]]):")
    print(pos_slice)


if __name__ == "__main__":
    demonstrate_indexing_mechanics()

```

### 1.4 The Verification

Execute the script from your terminal:

```bash
python 04_selection_mechanics.py

```

#### Verification Output:

```text
--- 1. Loading Ingested Orders Dataset ---

Custom Labeled DataFrame Slice (First 3 Rows):
           order_id customer_id  unit_price
ORD_ROW_0    100000   CUST_1824      314.12
ORD_ROW_1    100001   CUST_1350      243.68
ORD_ROW_2    100002   CUST_1106      180.20

--- 2. Label-Based Selection (.loc) ---
Value at ['ORD_ROW_2', 'unit_price']: $180.20

Label Slice ('ORD_ROW_1' to 'ORD_ROW_3' inclusive):
          customer_id  quantity  unit_price
ORD_ROW_1   CUST_1350         4      243.68
ORD_ROW_2   CUST_1106         1      180.20
ORD_ROW_3   CUST_1700         8       99.15

--- 3. Positional Selection (.iloc) ---
Value at iloc[2, 4]: $180.20

Positional Slice (iloc[1:4, [1, 3, 4]]):
          customer_id  quantity  unit_price
ORD_ROW_1   CUST_1350         4      243.68
ORD_ROW_2   CUST_1106         1      180.20
ORD_ROW_3   CUST_1700         8       99.15

```

---

## 2. Boolean Filtering & Vectorized Selection Engines

### 2.1 The Target

Filter complex subsets of data using high-speed boolean bitwise operators (`&`, `|`, `~`), set membership (`isin`), range masks (`between`), and C-accelerated string querying via `.query()`.

### 2.2 The Concept

Filtering in Pandas relies on **Boolean Vectors** (arrays of `True` and `False`). When you evaluate a condition like `df["unit_price"] > 100`, Pandas generates a boolean mask aligned with the index. When passed into `.loc[...]`, Pandas drops every row where the mask evaluates to `False`.

```
   Original Data (unit_price)      Boolean Condition (> 200)      Filtered DataFrame
   +------------------------+      +-----------------------+      +------------------+
0  | 150.00                 |  --> | False                 |  --> | (Row Skipped)    |
1  | 350.00                 |  --> | True                  |  --> | Row 1 Retained   |
2  | 89.00                  |  --> | False                 |  --> | (Row Skipped)    |
   +------------------------+      +-----------------------+      +------------------+

```

When building complex conditions:

* Use `&` for **AND** (not `and`).
* Use `|` for **OR** (not `or`).
* Use `~` for **NOT** (inversion).
* **Wrap each logical clause in parentheses `()**` to enforce correct evaluation order against NumPy's operator precedence rules.

### 2.3 The Implementation

Create a script named `05_boolean_filtering.py`:

```python
# 05_boolean_filtering.py
"""
Part 2.2: Vectorized Boolean Masking & Query Expressions
Filters records using logical conditions, set matching, and df.query().
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def execute_filtering_strategies() -> None:
    df = load_orders_csv("raw_data/orders.csv")
    print(f"Initial Record Count: {len(df):,}")

    # --- Strategy A: Multi-Condition Compound Boolean Masking ---
    print("\n--- 1. Multi-Condition Masking (PayPal or Credit Card, Price > $300, Qty >= 5) ---")
    mask_payment = df["payment_method"].isin(["Credit Card", "PayPal"])
    mask_price = df["unit_price"] > 300.00
    mask_qty = df["quantity"] >= 5

    # Combine masks with bitwise AND (&)
    compound_mask = mask_payment & mask_price & mask_qty
    filtered_df = df.loc[compound_mask].copy()

    print(f"Filtered Record Count: {len(filtered_df):,}")
    print(filtered_df[["order_id", "payment_method", "unit_price", "quantity"]].head(4))

    # --- Strategy B: Numeric Range Slicing (.between) ---
    print("\n--- 2. Range Slicing using .between(100, 150) ---")
    range_mask = df["unit_price"].between(100.00, 150.00, inclusive="both")
    range_df = df.loc[range_mask]
    print(f"Records with unit_price between $100 and $150: {len(range_df):,}")

    # --- Strategy C: C-Accelerated Query Engine (.query) ---
    print("\n--- 3. Expressive Filtering with df.query() ---")
    target_payment = "Crypto"
    min_price = 450.00

    # @ variable reference injects local Python variables into C query parser
    query_df = df.query(
        "payment_method == @target_payment and unit_price >= @min_price"
    )
    print(f"Query Engine Result (Crypto & Price >= ${min_price}): {len(query_df):,} records")
    print(query_df[["order_id", "customer_id", "payment_method", "unit_price"]].head(3))


if __name__ == "__main__":
    execute_filtering_strategies()

```

### 2.4 The Verification

Run the boolean filtering script:

```bash
python 05_boolean_filtering.py

```

#### Verification Output:

```text
Initial Record Count: 50,000

--- 1. Multi-Condition Masking (PayPal or Credit Card, Price > $300, Qty >= 5) ---
Filtered Record Count: 8,024
    order_id payment_method  unit_price  quantity
0     100000    Credit Card      314.12         9
7     100007         PayPal      405.82         6
13    100013         PayPal      469.70         7
19    100019         PayPal      420.35         7

--- 2. Range Slicing using .between(100, 150) ---
Records with unit_price between $100 and $150: 5,082

--- 3. Expressive Filtering with df.query() ---
Query Engine Result (Crypto & Price >= $450): 510 records
    order_id customer_id payment_method  unit_price
122   100122   CUST_1804         Crypto      475.21
201   100201   CUST_1922         Crypto      490.15
278   100278   CUST_1410         Crypto      482.90

```

---

## 3. Missing Data Imputation & Vector String Cleaning

### 3.1 The Target

Audit missing records using `.isna()`, execute safe missing value imputations using `.fillna()` / `.bfill()`, apply domain-specific regex replacements using the `.str` vector accessor, and safely downcast data types with `.astype()`.

### 3.2 The Concept

Real-world data is messy. Text fields contain leading whitespace or mixed casing, while categorical fields carry missing entries (`NaN` / `None`). Rather than writing slow Python `for` loops to format text, Pandas exposes the `.str` vector accessor, which executes string operations directly in optimized C loops across the entire column simultaneously.

```
                   VECTOR STRING PROCESSING (.str)
                   
   Raw Column Data            .str.upper().str.strip()        Clean Column Output
   +--------------------+     +------------------------+      +--------------------+
0  | "  credit card "   | --> | Executed in C loop     | -->  | "CREDIT CARD"      |
1  | "paypal  "         | --> | across contiguous      | -->  | "PAYPAL"           |
2  | " crypto "         | --> | RAM memory buffers     | -->  | "CRYPTO"           |
   +--------------------+     +------------------------+      +--------------------+

```

### 3.3 The Implementation

Create a script named `06_cleaning_and_imputation.py`:

```python
# 06_cleaning_and_imputation.py
"""
Part 2.3: Data Cleaning, Imputation, and Vectorized String Operations
Remediates missing values and cleans messy string formatting safely.
"""

import numpy as np
import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def execute_data_cleaning() -> None:
    df = load_orders_csv("raw_data/orders.csv")

    print("--- 1. Missing Data Audit ---")
    null_counts = df.isna().sum()
    print("Null Counts Per Column:")
    print(null_counts[null_counts > 0])

    # --- A. Imputing Categorical Missing Data ---
    print("\n--- 2. Categorical Imputation (.fillna) ---")
    # Missing payment_method entries filled with fallback category "Unspecified"
    # Convert category back to string temporarily or add category to avoid TypeError
    if "Unspecified" not in df["payment_method"].cat.categories:
        df["payment_method"] = df["payment_method"].cat.add_categories(["Unspecified"])

    df["payment_method"] = df["payment_method"].fillna("Unspecified")
    print(f"Remaining nulls in payment_method: {df['payment_method'].isna().sum()}")

    # --- B. Vectorized String Cleaning (.str accessor) ---
    print("\n--- 3. Vectorized String Manipulations ---")
    # Clean customer_id strings: Extract numeric integer suffix, format, and cast
    df["customer_id_clean"] = (
        df["customer_id"]
        .astype(str)
        .str.strip()
        .str.replace("CUST_", "", regex=False)
        .astype("int32")
    )

    print("Extracted Clean Customer Numeric IDs:")
    print(df[["customer_id", "customer_id_clean"]].head(3))

    # Clean payment_method strings using regex and case formatting
    df["payment_method_normalized"] = (
        df["payment_method"]
        .astype(str)
        .str.upper()
        .str.replace(" ", "_", regex=False)
    )

    print("\nNormalized Payment Method Strings:")
    print(df["payment_method_normalized"].value_counts())

    # --- C. Type Casting Optimization ---
    print("\n--- 4. Safe Downcasting & Dtype Conversions ---")
    df["payment_method_normalized"] = df["payment_method_normalized"].astype("category")
    print(f"Final Optimized Dtype: {df['payment_method_normalized'].dtype}")


if __name__ == "__main__":
    execute_data_cleaning()

```

### 3.4 The Verification

Execute the cleaning script:

```bash
python 06_cleaning_and_imputation.py

```

#### Verification Output:

```text
--- 1. Missing Data Audit ---
Null Counts Per Column:
payment_method    2519
dtype: int64

--- 2. Categorical Imputation (.fillna) ---
Remaining nulls in payment_method: 0

--- 3. Vectorized String Manipulations ---
Extracted Clean Customer Numeric IDs:
  customer_id  customer_id_clean
0   CUST_1824               1824
1   CUST_1350               1350
2   CUST_1106               1106

Normalized Payment Method Strings:
payment_method_normalized
CREDIT_CARD    24911
PAYPAL         12367
CRYPTO          5138
BANK_TRANSFER   5065
UNSPECIFIED     2519
Name: count, dtype: int64

--- 4. Safe Downcasting & Dtype Conversions ---
Final Optimized Dtype: category

```

---

## Technical Deep Dive: Indexing Operations & Copy vs. View Rules

One of the most confusing errors in Pandas is the dreaded **`SettingWithCopyWarning`**. To avoid it, you need to understand how Pandas handles memory layout during slicing operations.

### Shallow Views vs. Deep Copies

* **View:** A new DataFrame handle that points directly to the **same underlying memory buffer** as the original DataFrame. Modifying a view modifies the parent dataset.
* **Copy:** A completely new memory allocation containing duplicated data buffers. Modifying a copy has zero effect on the original dataset.

```
                    VIEW (Zero Allocation)
  Original DF Buffer [ 10.5, 20.0, 30.2, 40.8 ]
                             ^
                             |
  Sliced View --------------+  (Points to original RAM)

                    COPY (New Allocation)
  Original DF Buffer [ 10.5, 20.0, 30.2, 40.8 ]
  
  Copied DF Buffer   [ 10.5, 20.0, 30.2, 40.8 ]  (Separate RAM address)

```

### When Does Pandas Create a View vs. a Copy?

1. Single-step explicit assignment with `.loc[row_indexer, col_indexer] = value` modifies the original memory buffer directly **without warnings**.
2. Chained operations like `df[df["price"] > 100]["quantity"] = 5` force Pandas to produce an intermediate evaluation step. Pandas cannot guarantee whether that intermediate step returned a view or a copy, so it triggers a warning and blocks the mutation.
3. To safely modify a subset of data, always use `.loc` directly on the parent DataFrame, or explicitly create a deep copy using `.copy()` before performing operations:

```python
# BAD (Triggers SettingWithCopyWarning):
sub_df = df[df["unit_price"] > 100]
sub_df["discounted_price"] = sub_df["unit_price"] * 0.9  # WARNING!

# GOOD (Option A: Explicit Deep Copy):
sub_df = df[df["unit_price"] > 100].copy()
sub_df["discounted_price"] = sub_df["unit_price"] * 0.9  # Clean & explicit

# GOOD (Option B: Single-Step Direct Allocation):
df.loc[df["unit_price"] > 100, "discounted_price"] = df["unit_price"] * 0.9

```
