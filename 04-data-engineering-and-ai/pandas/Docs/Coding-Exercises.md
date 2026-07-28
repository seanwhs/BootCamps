# Coding Exercises & Solutions: Data Wrangling at Scale — The Definitive Pandas Guide

Welcome to the **Coding Exercises & Solutions** workbook. This lab manual contains hands-on data engineering problems, complete with step-by-step solutions, designed to reinforce high-performance Pandas 2.x patterns, PyArrow schema enforcement, vectorization, and memory optimization.

---

## Exercise 1: High-Performance Ingestion & Explicit Schema Enforcement

### Problem Statement

You are given a raw CSV file path (`"transactions.csv"`) containing 100,000 retail records. Default Pandas ingestion causes memory bloat and converts integer columns with nulls into floats.

Write a function `ingest_and_optimize(file_path: str)` that:

1. Loads the CSV using the PyArrow engine (`engine="pyarrow"`).
2. Enforces an explicit PyArrow-backed schema dictionary (`order_id` as `int64[pyarrow]`, `quantity` as `int32[pyarrow]`, `unit_price` as `float32[pyarrow]`, `payment_method` as `category`).
3. Computes and returns both the cleaned DataFrame and its true memory footprint in megabytes (`memory_usage(deep=True).sum() / (1024 ** 2)`).

### Solution Code

```python
import pandas as pd

def ingest_and_optimize(file_path: str):
    # 1. Define explicit PyArrow-backed schema contracts
    schema = {
        "order_id": "int64[pyarrow]",
        "quantity": "int32[pyarrow]",
        "unit_price": "float32[pyarrow]",
        "payment_method": "category"
    }
    
    # 2. Ingest via PyArrow engine with schema enforcement
    df = pd.read_csv(
        file_path, 
        dtype=schema, 
        engine="pyarrow"
    )
    
    # 3. Audit true memory consumption in MB
    memory_mb = df.memory_usage(deep=True).sum() / (1024 ** 2)
    
    return df, memory_mb

```

---

## Exercise 2: Eliminating `.apply()` via Vectorization (`np.select`)

### Problem Statement

A legacy data pipeline calculates customer discount tiers using a slow row-wise `.apply(lambda row: ..., axis=1)` loop.

Refactor the following snippet using vectorized `np.select()` to operate at C-level speed:

* If `tier == "Gold"` and `order_total >= 500`, apply multiplier `0.80`.
* If `tier == "Silver"` or `order_total >= 250`, apply multiplier `0.90`.
* Default multiplier is `1.0`.

### Solution Code

```python
import numpy as np
import pandas as pd

def apply_vectorized_discounts(df: pd.DataFrame) -> pd.DataFrame:
    # Define conditions using bitwise operators and vectorized comparisons
    conditions = [
        (df["tier"] == "Gold") & (df["order_total"] >= 500),
        (df["tier"] == "Silver") | (df["order_total"] >= 250)
    ]
    
    # Define corresponding multipliers
    choices = [0.80, 0.90]
    
    # Vectorized conditional assignment
    multiplier = np.select(conditions, choices, default=1.0)
    
    # Compute final discounted price column
    df["discounted_total"] = df["order_total"] * multiplier
    
    return df

```

---

## Exercise 3: Relational Joins with Cardinality Validation

### Problem Statement

You need to join an orders fact table (`orders_df`) with a product catalog dimension table (`products_df`) on `product_id`.

Write a function `enrich_orders(orders_df, products_df)` that:

1. Performs a left merge.
2. Explicitly enforces a `many_to_one` join cardinality check (`validate="many_to_one"`) to guarantee data integrity and catch unexpected key duplications.
3. Drops any rows missing essential product categories after the join.

### Solution Code

```python
import pandas as pd

def enrich_orders(orders_df: pd.DataFrame, products_df: pd.DataFrame) -> pd.DataFrame:
    # 1. Merge with built-in cardinality validation
    merged_df = orders_df.merge(
        products_df,
        on="product_id",
        how="left",
        validate="many_to_one"
    )
    
    # 2. Clean up unmapped records safely
    cleaned_df = merged_df.dropna(subset=["category"])
    
    return cleaned_df

```

---

## Exercise 4: Unit Testing Data Logic with `pytest`

### Problem Statement

Write a `pytest` unit test function named `test_revenue_calculation` that verifies a net revenue calculation function (`calculate_net_revenue(df)`) computes totals correctly within an acceptable numerical tolerance threshold (`pytest.approx`).

### Solution Code

```python
import pandas as pd
import pytest

# Target function to test
def calculate_net_revenue(df: pd.DataFrame) -> float:
    return (df["quantity"] * df["unit_price"] * (1.0 - df["discount"])).sum()

# Pytest unit test
def test_revenue_calculation():
    # Setup mock data frame
    mock_data = pd.DataFrame({
        "quantity": [2, 5, 1],
        "unit_price": [100.0, 50.0, 200.0],
        "discount": [0.10, 0.20, 0.00]
    })
    
    # Expected calculation: (2*100*0.9) + (5*50*0.8) + (1*200*1.0) = 180 + 200 + 200 = 580.0
    expected_revenue = 580.0
    
    calculated_revenue = calculate_net_revenue(mock_data)
    
    # Assert result matches within floating-point tolerance
    assert calculated_revenue == pytest.approx(expected_revenue, rel=1e-5)

```
