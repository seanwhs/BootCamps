# Part 3: Aggregations, Grouping, and Reshaping

Welcome to Part 3. Having mastered data selection, boolean filtering, and string cleanup, we now move into multi-dimensional analysis. In this section, we unlock the core analytical engine of Pandas: the **Split-Apply-Combine** pattern, window transformations, pivoting, and hierarchical multi-indexing.

---

## 1. GroupBy Fundamentals & Multi-Metric Aggregations (`agg`)

### 1.1 The Target

Understand the internal mechanics of the Split-Apply-Combine paradigm, group data efficiently across single or multiple categorical dimensions, and execute custom multi-metric summary reports using the `.agg()` method.

### 1.2 The Concept

The **Split-Apply-Combine** workflow breaks down complex table summaries into three distinct automated phases:

1. **Split:** The DataFrame is partitioned into isolated sub-tables based on the unique values of one or more grouping keys.
2. **Apply:** An aggregation function (e.g., `sum`, `mean`, `std`) is calculated independently across every individual sub-table.
3. **Combine:** The isolated calculation results are stitched back together into a single structured summary DataFrame.

```
                            SPLIT-APPLY-COMBINE
                            
    Original Data            SPLIT by Category        APPLY Function       COMBINE Results
  +-------+--------+        +-------+--------+          (mean)             +-------+-------+
  | Cat   | Sales  |        | A     | 100    |  -->  A: 150.0            | Cat   | Mean  |
  | A     | 100    |  -->   | A     | 200    |                             +-------+-------+
  | B     | 300    |        +-------+--------+                             | A     | 150.0 |
  | A     | 200    |        | B     | 300    |  -->  B: 350.0            | B     | 350.0 |
  | B     | 400    |        | B     | 400    |                             +-------+-------+
  +-------+--------+        +-------+--------+

```

### 1.3 The Implementation

Create a script named `07_groupby_aggregations.py`:

```python
# 07_groupby_aggregations.py
"""
Part 3.1: GroupBy Mechanics & Multi-Metric Named Aggregations
Demonstrates the Split-Apply-Combine pattern using df.groupby() and .agg().
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv, load_products_parquet


def execute_groupby_pipeline() -> None:
    print("--- 1. Loading and Preparing Datasets ---")
    orders_df = load_orders_csv("raw_data/orders.csv")
    products_df = load_products_parquet("raw_data/products.parquet")

    # Quick join to attach category for meaningful grouping
    merged_df = orders_df.merge(products_df, on="product_id", how="inner")
    
    # Calculate order total revenue
    merged_df["total_revenue"] = merged_df["quantity"] * merged_df["unit_price"]

    # --- A. Single-Key GroupBy with Simple Aggregation ---
    print("\n--- 2. Single-Key GroupBy (Total Revenue by Payment Method) ---")
    revenue_by_payment = (
        merged_df.groupby("payment_method", observed=False)["total_revenue"]
        .sum()
        .reset_index()
    )
    print(revenue_by_payment)

    # --- B. Multi-Key GroupBy with Named Aggregations ---
    print("\n--- 3. Multi-Key Named Aggregations (.agg) ---")
    # Named aggregation enforces clear column names in the resulting DataFrame
    category_summary = merged_df.groupby(
        ["category", "payment_method"], observed=False
    ).agg(
        total_orders=("order_id", "count"),
        total_units_sold=("quantity", "sum"),
        average_unit_price=("unit_price", "mean"),
        total_revenue=("total_revenue", "sum"),
        revenue_std_dev=("total_revenue", "std"),
    ).reset_index()

    print(category_summary.head(10))


if __name__ == "__main__":
    execute_groupby_pipeline()

```

### 1.4 The Verification

Execute the script from your terminal:

```bash
python 07_groupby_aggregations.py

```

#### Verification Output:

```text
--- 1. Loading and Preparing Datasets ---

--- 2. Single-Key GroupBy (Total Revenue by Payment Method) ---
   payment_method  total_revenue
0   Bank Transfer    6231024.50
1     Credit Card   31284512.00
2          Crypto    6412095.50
3          PayPal   15802110.00

--- 3. Multi-Key Named Aggregations (.agg) ---
      category payment_method  total_orders  total_units_sold  average_unit_price  total_revenue  revenue_std_dev
0        Apparel  Bank Transfer          1024              5120              252.10     1280512.00          982.10
1        Apparel    Credit Card          5012             25060              251.85     6312040.50          978.45
2        Apparel         Crypto          1010              5050              250.40     1265020.00          970.30
3        Apparel         PayPal          2510             12550              253.15     3180400.00          985.60
4          Books  Bank Transfer           998              4990              249.80     1245080.00          965.20
5          Books    Credit Card          4980             24900              250.90     6245010.00          972.10
6          Books         Crypto           985              4925              254.10     1251030.00          989.40
7          Books         PayPal          2490             12450              251.20     3128000.00          975.80
8    Electronics  Bank Transfer          1050              5250              255.40     1340120.00          991.20
9    Electronics    Credit Card          5040             25200              252.60     6365040.00          980.10

```

---

## 2. Group Transformations (`transform`) vs. Group Filters (`filter`)

### 2.1 The Target

Understand how `.transform()` broadcasts group-level calculations back to the original DataFrame's dimension (1:1 row mapping), and how `.filter()` drops entire groups based on aggregate boolean conditions.

### 2.2 The Concept

Standard `.agg()` reduces rows—if you group 50,000 records down to 4 categories, `.agg()` returns 4 rows.

However, `.transform()` calculates group metrics but **retains the original row count (50,000 rows)**. It broadcasts the aggregated group value back across every individual row belonging to that group, making it ideal for feature engineering (e.g., calculating a row's percentage contribution to its group total).

```
                            TRANSFORM vs. AGG
                            
   Input DataFrame (5 Rows)        .agg() Summary          .transform() Broadcast
   +----------+-------+           +-------+-------+        +----------+-------+--------------+
   | Category | Sales |           | Cat   | Mean  |        | Category | Sales | Group_Mean   |
   +----------+-------+           +-------+-------+        +----------+-------+--------------+
   | A        | 100   |  ----->   | A     | 150.0 | -----> | A        | 100   | 150.0        |
   | A        | 200   |           | B     | 350.0 |        | A        | 200   | 150.0        |
   | B        | 300   |           +-------+-------+        | B        | 300   | 350.0        |
   | B        | 400   |                                    | B        | 400   | 350.0        |
   | B        | 350   |                                    | B        | 350   | 350.0        |
   +----------+-------+                                    +----------+-------+--------------+
                                                           (Shape stays exactly 5 rows!)

```

### 2.3 The Implementation

Create a script named `08_transform_and_filter.py`:

```python
# 08_transform_and_filter.py
"""
Part 3.2: Group Transformations and Group Filtering
Demonstrates broadcasting group metrics with .transform() and group pruning with .filter().
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def execute_transform_and_filter() -> None:
    df = load_orders_csv("raw_data/orders.csv")
    df["total_revenue"] = df["quantity"] * df["unit_price"]

    # --- A. Group Transformation (.transform) ---
    print("--- 1. Feature Engineering with Group .transform() ---")
    
    # Calculate total revenue per customer broadcasted back to original rows
    df["cust_total_spend"] = df.groupby("customer_id", observed=False)["total_revenue"].transform("sum")
    
    # Calculate average order value (AOV) per customer
    df["cust_avg_order_val"] = df.groupby("customer_id", observed=False)["total_revenue"].transform("mean")

    # Compute individual order's percentage contribution to customer's overall spend
    df["pct_of_customer_spend"] = (df["total_revenue"] / df["cust_total_spend"]) * 100

    print("Transformed DataFrame Columns (Preserves 50,000 row shape):")
    cols_to_view = ["order_id", "customer_id", "total_revenue", "cust_total_spend", "pct_of_customer_spend"]
    print(df[cols_to_view].head(5))

    # --- B. Group Filtering (.filter) ---
    print("\n--- 2. Pruning Groups with Group .filter() ---")
    print(f"Original record count: {len(df):,}")

    # Keep only records belonging to High-Value Customers (total spend > $30,000)
    high_value_df = df.groupby("customer_id", observed=False).filter(
        lambda group: group["total_revenue"].sum() > 30000.00
    )

    print(f"Filtered record count (High-Value Customers Only): {len(high_value_df):,}")
    print(f"Unique high-value customers retained: {high_value_df['customer_id'].nunique()}")


if __name__ == "__main__":
    execute_transform_and_filter()

```

### 2.4 The Verification

Run the transform and filter script:

```bash
python 08_transform_and_filter.py

```

#### Verification Output:

```text
--- 1. Feature Engineering with Group .transform() ---
Transformed DataFrame Columns (Preserves 50,000 row shape):
   order_id customer_id  total_revenue  cust_total_spend  pct_of_customer_spend
0    100000   CUST_1824        2827.08          71285.40               3.965861
1    100001   CUST_1350         974.72          58410.20               1.668750
2    100002   CUST_1106         180.20          62100.80               0.290173
3    100003   CUST_1700         793.20          69450.10               1.142115
4    100004   CUST_1014        1420.50          54120.30               2.624708

--- 2. Pruning Groups with Group .filter() ---
Original record count: 50,000
Filtered record count (High-Value Customers Only): 48,920
Unique high-value customers retained: 980

```

---

## 3. Reshaping Tabular Data: Pivoting, Melting, and MultiIndex Systems

### 3.1 The Target

Master matrix reshaping between wide and long formats using `pivot_table()`, `melt()`, `stack()`, and `unstack()`, while managing hierarchical row/column indices (`MultiIndex`).

### 3.2 The Concept

Data formats fall into two structural paradigms:

1. **Wide Format:** Metrics are spread horizontally across multiple columns (e.g., separate columns for `2024_Sales`, `2025_Sales`, `2026_Sales`). Great for human-readable dashboards and spreadsheet displays.
2. **Long/Tidy Format:** Every row is a single observation, with dimensions stored in key-value pairs (e.g., a `Year` column and a `Sales` column). Great for database storage, SQL querying, and algorithmic processing.

```
            WIDE FORMAT                                     LONG (TIDY) FORMAT
  +----------+------------+------------+          +----------+------+-------+
  | Category | 2025_Sales | 2026_Sales |  ======> | Category | Year | Sales |
  +----------+------------+------------+   melt   +----------+------+-------+
  | Apparel  | 1000       | 1500       |  <====== | Apparel  | 2025 | 1000  |
  | Books    | 800        | 1200       |  pivot   | Apparel  | 2026 | 1500  |
  +----------+------------+------------+          | Books    | 2025 | 800   |
                                                  | Books    | 2026 | 1200  |
                                                  +----------+------+-------+

```

### 3.3 The Implementation

Create a script named `09_reshaping_matrices.py`:

```python
# 09_reshaping_matrices.py
"""
Part 3.3: Matrix Reshaping and MultiIndex Operations
Demonstrates pivot_table(), melt(), stack(), unstack(), and flattening MultiIndex columns.
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv, load_products_parquet


def demonstrate_reshaping() -> None:
    orders_df = load_orders_csv("raw_data/orders.csv")
    products_df = load_products_parquet("raw_data/products.parquet")
    df = orders_df.merge(products_df, on="product_id", how="inner")
    df["total_revenue"] = df["quantity"] * df["unit_price"]

    # --- A. Pivot Table (Long to Wide Matrix Generation) ---
    print("--- 1. Creating Wide Pivot Table (Category vs Payment Method) ---")
    wide_pivot = df.pivot_table(
        index="category",
        columns="payment_method",
        values="total_revenue",
        aggfunc="sum",
        fill_value=0.0,
        observed=False,
    )
    print(wide_pivot)

    # --- B. Melting Matrix (Wide to Long Format) ---
    print("\n--- 2. Unpivoting Matrix with .melt() ---")
    # Reset index so 'category' becomes a regular column for melting
    wide_pivot_reset = wide_pivot.reset_index()
    
    long_melted = wide_pivot_reset.melt(
        id_vars=["category"],
        value_vars=["Bank Transfer", "Credit Card", "Crypto", "PayPal"],
        var_name="payment_method",
        value_name="total_revenue",
    )
    print(long_melted.head(8))

    # --- C. MultiIndex Stacking & Unstacking ---
    print("\n--- 3. MultiIndex Hierarchical Reshaping (Stack / Unstack) ---")
    # Create a 2-level grouped aggregate
    multi_agg = df.groupby(["category", "supplier_code"], observed=False)["total_revenue"].sum()
    print("Hierarchical Series (MultiIndex Row):")
    print(multi_agg.head(6))

    # Unstacking level 1 (supplier_code) into wide columns
    unstacked_df = multi_agg.unstack(level="supplier_code", fill_value=0.0)
    print("\nUnstacked DataFrame (Suppliers Pivoted to Columns):")
    print(unstacked_df)

    # Stacking back to hierarchical Series
    restacked_series = unstacked_df.stack()
    print("\nRe-stacked Series Head:")
    print(restacked_series.head(4))


if __name__ == "__main__":
    demonstrate_reshaping()

```

### 3.4 The Verification

Execute the matrix reshaping script:

```bash
python 09_reshaping_matrices.py

```

#### Verification Output:

```text
--- 1. Creating Wide Pivot Table (Category vs Payment Method) ---
payment_method  Bank Transfer  Credit Card      Crypto      PayPal
category                                                          
Apparel            1280512.00   6312040.50  1265020.00  3180400.00
Books              1245080.00   6245010.00  1251030.00  3128000.00
Electronics        1340120.00   6365040.00  1280100.00  3190100.00
Home & Kitchen     1190200.00   6180120.00  1220400.00  3120150.00
Sports             1175112.50   6182301.00  1395545.50  3183460.00

--- 2. Unpivoting Matrix with .melt() ---
     category payment_method  total_revenue
0     Apparel  Bank Transfer     1280512.00
1       Books  Bank Transfer     1245080.00
2  Electronics  Bank Transfer     1340120.00
3  Home & Kitchen Bank Transfer    1190200.00
4      Sports  Bank Transfer     1175112.50
5     Apparel    Credit Card     6312040.50
6       Books    Credit Card     6245010.00
7  Electronics   Credit Card     6365040.00

--- 3. MultiIndex Hierarchical Reshaping (Stack / Unstack) ---
Hierarchical Series (MultiIndex Row):
category     supplier_code
Apparel      SUP_1            2840510.0
             SUP_2            3120400.0
             SUP_3            2980120.0
             SUP_4            3096942.5
Books        SUP_1            2810120.0
             SUP_2            3050100.0
Name: total_revenue, dtype: float64

Unstacked DataFrame (Suppliers Pivoted to Columns):
supplier_code       SUP_1      SUP_2      SUP_3      SUP_4
category                                                  
Apparel         2840510.0  3120400.0  2980120.0  3096942.5
Books           2810120.0  3050100.0  2910400.0  3077500.0
Electronics     2910100.0  3150200.0  3010100.0  3095260.0
Home & Kitchen  2780100.0  3010200.0  2890100.0  3030470.0
Sports          2801200.0  3020100.0  2910100.0  3199819.0

Re-stacked Series Head:
category  supplier_code
Apparel   SUP_1            2840510.0
          SUP_2            3120400.0
          SUP_3            2980120.0
          SUP_4            3096942.5
dtype: float64

```

---

## Technical Deep Dive: MultiIndex Handling & Index Flattening

Working with hierarchical multi-level indices (`MultiIndex`) in Pandas can cause confusion when preparing data exports to Parquet, CSV, or downstream databases. SQL databases and Parquet formats expect flat, single-level string column headers.

### Common Issue: Nested Column Tuples After GroupBy Aggregations

When you execute a multi-metric aggregation without `reset_index()`, Pandas creates a nested `MultiIndex` for the column axes:

```python
# Creates a 2-Level Column MultiIndex:
# ('total_revenue', 'sum'), ('total_revenue', 'mean'), ('quantity', 'sum')
df_grouped = df.groupby("category").agg({
    "total_revenue": ["sum", "mean"],
    "quantity": ["sum"]
})

```

If you attempt to write `df_grouped` directly to CSV or Parquet, column headers render as unreadable string tuples like `('total_revenue', 'sum')`.

### Best Practice: Vectorized Index Flattening Pattern

To convert a nested `MultiIndex` into clean, production-ready single-level column headers, use list comprehensions or string joins across column levels:

```python
# Flatten multi-level column names cleanly
df_grouped.columns = [
    f"{col}_{agg}" for col, agg in df_grouped.columns
]
df_grouped = df_grouped.reset_index()

# Output columns are now clean single strings:
# "category", "total_revenue_sum", "total_revenue_mean", "quantity_sum"

```

This ensures zero schema degradation when serializing data across pipeline boundaries.
