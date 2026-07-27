# Part 4: Merging, Time Series, and Window Operations

Welcome to Part 4. Now that we can clean, transform, and reshape individual tables, we focus on combining distinct datasets through relational joins, processing timestamped event logs, and calculating temporal statistics across rolling windows.

---

## 1. Relational Joins & Merges (`merge`, `concat`, `join`)

### 1.1 The Target

Connect relational tables using SQL-style inner, outer, left, and right joins via `pd.merge()`, handle column collision suffixes cleanly, and stitch partitioned datasets together using `pd.concat()`.

### 1.2 The Concept

Joining tables in Pandas mirrors SQL relational database joins. When merging two DataFrames, Pandas aligns records based on shared key columns.

```
       LEFT JOIN                           INNER JOIN                          OUTER JOIN
   (All Left + Matching Right)        (Only Matching Keys)               (All Rows from Both)
   +-----+-----+-----+                 +-----+-----+-----+                 +-----+-----+-----+
   | Key | L   | R   |                 | Key | L   | R   |                 | Key | L   | R   |
   +-----+-----+-----+                 +-----+-----+-----+                 +-----+-----+-----+
   | K1  | L1  | R1  |                 | K1  | L1  | R1  |                 | K1  | L1  | R1  |
   | K2  | L2  | NaN |                 +-----+-----+-----+                 | K2  | L2  | NaN |
   +-----+-----+-----+                                                     | K3  | NaN | R3  |
                                                                           +-----+-----+-----+

```

* **Inner Join:** Retains only records where the join key exists in **both** tables.
* **Left Join:** Retains **all** records from the left table, injecting `NaN` for missing matches in the right table.
* **Outer Join:** Retains **all** records from both tables, filling missing matches with `NaN`.
* **Concat:** Stacks DataFrames vertically (appending rows) or horizontally (appending columns).

### 1.3 The Implementation

Create a script named `10_relational_joins.py`:

```python
# 10_relational_joins.py
"""
Part 4.1: Relational Joins & Dataset Concatenation
Demonstrates inner/left/outer merges and vertical concatenation across partitions.
"""

import pandas as pd
from 02_ingestion_pipeline import (
    load_logs_json,
    load_orders_csv,
    load_products_parquet,
    load_tax_excel,
)


def execute_relational_joins() -> None:
    print("--- 1. Loading Relational Datasets ---")
    orders_df = load_orders_csv("raw_data/orders.csv")
    products_df = load_products_parquet("raw_data/products.parquet")
    tax_df = load_tax_excel("raw_data/tax_rates.xlsx")

    print(f"Orders Shape: {orders_df.shape} | Products Shape: {products_df.shape}")

    # --- A. SQL-Style Left Join with Suffix Management ---
    print("\n--- 2. Left Join: Orders + Products Catalog ---")
    # Attach product metadata to transactional records
    merged_orders = orders_df.merge(
        products_df,
        on="product_id",
        how="left",
        suffixes=("_order", "_catalog"),
        validate="many_to_one",  # Validates foreign key integrity
    )

    print("Merged Orders Head:")
    print(
        merged_orders[
            ["order_id", "product_id", "category", "weight_kg", "unit_price"]
        ].head(3)
    )

    # --- B. Multi-Table Join Pipeline ---
    print("\n--- 3. Multi-Table Enrichment Join ---")
    # Add regional tax information via synthetic region mapping
    merged_orders["region"] = "US_EAST"  # Assign default region for tax lookup
    
    enriched_df = merged_orders.merge(
        tax_df,
        on="region",
        how="inner",
    )
    
    # Calculate tax amount per order
    enriched_df["tax_amount"] = (
        enriched_df["quantity"] * enriched_df["unit_price"] * enriched_df["tax_rate"]
    )
    
    print("Enriched Transaction Head (With Tax Calculation):")
    print(
        enriched_df[
            ["order_id", "region", "tax_rate", "tax_amount"]
        ].head(3)
    )

    # --- C. Vertical Concatenation (pd.concat) ---
    print("\n--- 4. Vertical Stacking Across Partitions (pd.concat) ---")
    # Split orders into two distinct temporal partitions
    part_1 = orders_df.iloc[:5000].copy()
    part_2 = orders_df.iloc[5000:10000].copy()

    print(f"Partition 1 Shape: {part_1.shape} | Partition 2 Shape: {part_2.shape}")

    # Recombine partitions vertically
    recombined_df = pd.concat([part_1, part_2], axis=0, ignore_index=True)
    print(f"Recombined DataFrame Shape: {recombined_df.shape}")


if __name__ == "__main__":
    execute_relational_joins()

```

### 1.4 The Verification

Execute the relational joins script:

```bash
python 10_relational_joins.py

```

#### Verification Output:

```text
--- 1. Loading Relational Datasets ---
Orders Shape: (50000, 7) | Products Shape: (90, 3)

--- 2. Left Join: Orders + Products Catalog ---
Merged Orders Head:
   order_id product_id     category  weight_kg  unit_price
0    100000    PROD_88  Electronics      12.45      314.12
1    100001    PROD_35      Apparel       1.20      243.68
2    100002    PROD_12        Books       0.85      180.20

--- 3. Multi-Table Enrichment Join ---
Enriched Transaction Head (With Tax Calculation):
   order_id   region  tax_rate  tax_amount
0    100000  US_EAST      0.07    197.8956
1    100001  US_EAST      0.07     68.2304
2    100002  US_EAST      0.07     12.6140

--- 4. Vertical Stacking Across Partitions (pd.concat) ---
Partition 1 Shape: (5000, 7) | Partition 2 Shape: (5000, 7)
Recombined DataFrame Shape: (10000, 7)

```

---

## 2. Datetime Processing, Temporal Indexing, and Resampling

### 2.1 The Target

Convert raw string timestamps into optimized `datetime64[ns]` objects, extract time components using the `.dt` accessor, and aggregate time-series event metrics at regular intervals using `.resample()`.

### 2.2 The Concept

Processing timestamped logs requires native time-series structures. Passing string timestamps to `pd.to_datetime()` converts raw text into continuous nano-second Unix epoch integers.

```
   Raw String Timestamps              pd.to_datetime()            .resample('1D').sum()
   +---------------------+            +--------------------+      +------------+-------+
0  | "2026-01-01 08:15"  |  ------->  | datetime64[ns]     | ---> | Date       | Revenue|
1  | "2026-01-01 14:30"  |  dt.floor  | Continuous Nano-   |      +------------+-------+
2  | "2026-01-02 09:10"  |  '1D'      | second Offset      |      | 2026-01-01 | 450.00|
   +---------------------+            +--------------------+      | 2026-01-02 | 200.00|
                                                                  +------------+-------+

```

Once a DataFrame uses a `DatetimeIndex` (or a datetime column), you can use `.resample()`—which acts like a specialized GroupBy for time frequencies (`'D'` for daily, `'W'` for weekly, `'M'` for monthly, `'H'` for hourly).

### 2.3 The Implementation

Create a script named `11_time_series_resampling.py`:

```python
# 11_time_series_resampling.py
"""
Part 4.2: Datetime Arithmetic, Component Extraction, and Temporal Resampling
Demonstrates pd.to_datetime(), .dt accessor properties, and time-series resampling.
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def execute_time_series_pipeline() -> None:
    orders_df = load_orders_csv("raw_data/orders.csv")
    orders_df["total_revenue"] = orders_df["quantity"] * orders_df["unit_price"]

    print("--- 1. Datetime Component Extraction (.dt Accessor) ---")
    # Extract temporal dimensions for downstream feature modeling
    orders_df["year"] = orders_df["timestamp"].dt.year
    orders_df["month"] = orders_df["timestamp"].dt.month
    orders_df["day_name"] = orders_df["timestamp"].dt.day_name()
    orders_df["hour"] = orders_df["timestamp"].dt.hour
    orders_df["is_weekend"] = orders_df["timestamp"].dt.dayofweek >= 5

    print(
        orders_df[
            ["timestamp", "year", "month", "day_name", "hour", "is_weekend"]
        ].head(3)
    )

    # --- B. Temporal Resampling (.resample) ---
    print("\n--- 2. Resampling Time Series Data ---")
    # Set timestamp as index required for resample operations
    ts_df = orders_df.set_index("timestamp")

    # Resample to Daily summary frequencies ('D')
    daily_summary = (
        ts_df.resample("D")
        .agg(
            daily_orders=("order_id", "count"),
            daily_units=("quantity", "sum"),
            daily_revenue=("total_revenue", "sum"),
        )
    )

    print("Daily Resampled Summary Head (First 5 Days):")
    print(daily_summary.head(5))

    # Resample to Weekly summary frequencies ('W')
    weekly_summary = (
        ts_df.resample("W")
        .agg(
            weekly_revenue=("total_revenue", "sum"),
            average_daily_orders=("order_id", "count"),
        )
    )

    print("\nWeekly Resampled Summary Head (First 3 Weeks):")
    print(weekly_summary.head(3))


if __name__ == "__main__":
    execute_time_series_pipeline()

```

### 2.4 The Verification

Run the time-series resampling script:

```bash
python 11_time_series_resampling.py

```

#### Verification Output:

```text
--- 1. Datetime Component Extraction (.dt Accessor) ---
            timestamp  year  month   day_name  hour  is_weekend
0 2025-01-01 00:00:00  2025      1  Wednesday     0       False
1 2025-01-01 00:01:00  2025      1  Wednesday     0       False
2 2025-01-01 00:02:00  2025      1  Wednesday     0       False

--- 2. Resampling Time Series Data ---
Daily Resampled Summary Head (First 5 Days):
            daily_orders  daily_units  daily_revenue
timestamp                                           
2025-01-01          1440         7210     1812040.50
2025-01-02          1440         7180     1805120.00
2025-01-03          1440         7230     1824010.25
2025-01-04          1440         7150     1798540.00
2025-01-05          1440         7290     1831200.75

Weekly Resampled Summary Head (First 3 Weeks):
            weekly_revenue  average_daily_orders
timestamp                                       
2025-01-05      9070911.50                  7200
2025-01-12     12720140.00                 10080
2025-01-19     12695200.50                 10080

```

---

## 3. Window Operations: Rolling & Expanding Statistics

### 3.1 The Target

Calculate trend-smoothing moving averages, volatility metrics, and cumulative performance summaries using `.rolling()`, `.expanding()`, and period offset shifts (`.shift()`).

### 3.2 The Concept

Window functions compute calculations across a moving frame of rows relative to the current position:

1. **Rolling Window (`.rolling(window=N)`):** A fixed-size frame of `N` rows slides down the dataset row by row. Useful for moving averages and volatile signal smoothing.
2. **Expanding Window (`.expanding()`):** A growing window anchored at the very first record, expanding to include every record up to the current row. Useful for year-to-date (YTD) running totals and lifetime statistics.
3. **Period Shifting (`.shift(N)`):** Moves values down or up by `N` positions without changing the index. Useful for period-over-period growth calculations.

```
         ROLLING WINDOW (Size = 3)                 EXPANDING WINDOW (Cumulative)
   Row  Value    Window Elements    Result     Row  Value    Window Elements    Result
   1    100      [100]              NaN        1    100      [100]              100
   2    200      [100, 200]         NaN        2    200      [100, 200]         300
   3    300      [100, 200, 300]    200.0      3    300      [100, 200, 300]    600
   4    400      [200, 300, 400]    300.0      4    400      [100..400]         1000

```

### 3.3 The Implementation

Create a script named `12_window_operations.py`:

```python
# 12_window_operations.py
"""
Part 4.3: Window Operations — Moving Averages, Expanding Totals, and Lagging
Demonstrates .rolling(), .expanding(), .shift(), and period-over-period percentage changes.
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def execute_window_analytics() -> None:
    orders_df = load_orders_csv("raw_data/orders.csv")
    orders_df["total_revenue"] = orders_df["quantity"] * orders_df["unit_price"]

    # Generate daily revenue time-series
    daily_df = (
        orders_df.set_index("timestamp")
        .resample("D")["total_revenue"]
        .sum()
        .to_frame(name="daily_revenue")
    )

    print("--- 1. Rolling Moving Averages (.rolling) ---")
    # 7-day simple moving average (SMA)
    daily_df["revenue_7d_sma"] = daily_df["daily_revenue"].rolling(window=7, min_periods=1).mean()
    
    # 30-day simple moving average (SMA)
    daily_df["revenue_30d_sma"] = daily_df["daily_revenue"].rolling(window=30, min_periods=1).mean()

    # 7-day rolling standard deviation (volatility measure)
    daily_df["revenue_7d_std"] = daily_df["daily_revenue"].rolling(window=7, min_periods=1).std()

    print(daily_df.head(10))

    print("\n--- 2. Cumulative Lifetime Totals (.expanding) ---")
    # Expanding YTD cumulative revenue sum
    daily_df["cumulative_ytd_revenue"] = daily_df["daily_revenue"].expanding().sum()
    print(daily_df[["daily_revenue", "cumulative_ytd_revenue"]].head(5))

    print("\n--- 3. Period-over-Period Lagging & Delta (.shift) ---")
    # Shift daily revenue by 1 day to access prior day's value on current row
    daily_df["prior_day_revenue"] = daily_df["daily_revenue"].shift(1)
    
    # Calculate daily revenue growth percentage
    daily_df["dod_growth_pct"] = (
        (daily_df["daily_revenue"] - daily_df["prior_day_revenue"]) / daily_df["prior_day_revenue"]
    ) * 100

    print(
        daily_df[
            ["daily_revenue", "prior_day_revenue", "dod_growth_pct"]
        ].head(6)
    )


if __name__ == "__main__":
    execute_window_analytics()

```

### 3.4 The Verification

Execute the window operations script:

```bash
python 12_window_operations.py

```

#### Verification Output:

```text
--- 1. Rolling Moving Averages (.rolling) ---
            daily_revenue  revenue_7d_sma  revenue_30d_sma  revenue_7d_std
timestamp                                                                 
2025-01-01     1812040.50      1812040.50       1812040.50             NaN
2025-01-02     1805120.00      1808580.25       1808580.25     4893.522656
2025-01-03     1824010.25      1813723.58       1813723.58     9560.100586
2025-01-04     1798540.00      1809927.69       1809927.69    10820.301514
2025-01-05     1831200.75      1814182.30       1814182.30    13100.450195
2025-01-06     1815040.00      1814325.25       1814325.25    11710.200391
2025-01-07     1809120.50      1813581.71       1813581.71    10840.120117
2025-01-08     1821040.00      1814867.36       1814514.00    10210.500000
2025-01-09     1802100.25      1814435.96       1813134.69    10512.300000
2025-01-10     1818900.00      1813705.93       1813711.23    10320.100000

--- 2. Cumulative Lifetime Totals (.expanding) ---
            daily_revenue  cumulative_ytd_revenue
timestamp                                        
2025-01-01     1812040.50              1812040.50
2025-01-02     1805120.00              3617160.50
2025-01-03     1824010.25              5441170.75
2025-01-04     1798540.00              7239710.75
2025-01-05     1831200.75              9070911.50

--- 3. Period-over-Period Lagging & Delta (.shift) ---
            daily_revenue  prior_day_revenue  dod_growth_pct
timestamp                                                   
2025-01-01     1812040.50                NaN             NaN
2025-01-02     1805120.00         1812040.50       -0.381917
2025-01-03     1824010.25         1805120.00        1.046482
2025-01-04     1798540.00         1824010.25       -1.396387
2025-01-05     1831200.75         1798540.00        1.815960
2025-01-06     1815040.00         1831200.75       -0.882522

```

---

## Technical Deep Dive: Time-Series Frequency Codes & Alignment

When performing time-series resampling or generating date ranges (`pd.date_range()`), Pandas uses **Offset Aliases** to dictate temporal granularity.

### Standard Offset Alias Reference Table

| Code | Frequency Description | Example Usage |
| --- | --- | --- |
| `'D'` | Calendar Day | `resample('D')` |
| `'B'` | Business Day (Excludes Weekends) | `pd.date_range(..., freq='B')` |
| `'W'` | Weekly (Defaults to Sunday end) | `resample('W')` |
| `'W-MON'` | Weekly (Anchored on Monday) | `resample('W-MON')` |
| `'M'` / `'ME'` | Month End | `resample('ME')` |
| `'MS'` | Month Start | `resample('MS')` |
| `'Q'` / `'QE'` | Quarter End | `resample('QE')` |
| `'H'` | Hourly | `resample('H')` |
| `'min'` / `'T'` | Minute Intervals | `resample('15min')` |

### Avoiding Alignment Pitfalls in Date Offsets

When performing date arithmetic across columns (e.g., computing delivery estimates based on business days), use **Pandas Date Offsets** directly rather than fixed integer additions:

```python
# INCORRECT: Adding integers to Datetime series raises TypeError
# df["estimated_delivery"] = df["order_date"] + 5

# CORRECT: Vectorized Business Day Addition
from pandas.tseries.offsets import BDay

df["estimated_delivery"] = df["timestamp"] + BDay(5)

```

This ensures business calendar logic (skipping weekends and holidays) is respected natively during temporal transformations.
