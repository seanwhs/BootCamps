# Appendix A: Custom Accessors, Extension Dtypes, and Memory Profiling Internals

Welcome to **Appendix A**. In this appendix, we move beyond standard Pandas usage to explore three advanced architectural patterns:

1. **Custom Pandas Accessors:** Extending the `.dt` or `.str` namespace with domain-specific business logic.
2. **Nullable Integer & Extension Dtypes:** Handling missing numerical data safely without coercing integers into floats.
3. **Advanced Memory Profiling & Tracing:** Using `tracemalloc` to pinpoint hidden object allocations.

---

## 1. Building Custom Extension Accessors (`@pd.api.extensions.register_dataframe_accessor`)

### 1.1 The Target

Create a custom dataframe or series accessor (e.g., `df.ecommerce`) to encapsulate proprietary business transformation pipelines directly into the Pandas namespace.

### 1.2 The Implementation

Create a script named `appx_01_custom_accessors.py`:

```python
# appx_01_custom_accessors.py
"""
Appendix A.1: Custom Pandas DataFrame Accessor
Registers a custom .ecommerce namespace for domain-specific metrics.
"""

import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


@pd.api.extensions.register_dataframe_accessor("ecommerce")
class ECommerceAccessor:
    def __init__(self, pandas_obj):
        self._obj = pandas_obj

    def calculate_net_revenue(self, tax_rate: float = 0.08) -> pd.Series:
        """Vectorized calculation of net revenue after tax and baseline discounts."""
        gross = self._obj["quantity"] * self._obj["unit_price"]
        return gross * (1.0 - tax_rate)

    def flag_high_value_orders(self, threshold: float = 1000.0) -> pd.Series:
        """Returns boolean mask flagging orders exceeding monetary threshold."""
        return (self._obj["quantity"] * self._obj["unit_price"]) > threshold


def execute_custom_accessor() -> None:
    print("--- 1. Loading Dataset for Accessor Test ---")
    df = load_orders_csv("raw_data/orders.csv").head(5)

    print("\n--- 2. Invoking Custom .ecommerce Namespace ---")
    
    # Using the registered custom accessor methods directly on the DataFrame
    df["net_revenue"] = df.ecommerce.calculate_net_revenue(tax_rate=0.07)
    df["is_high_value"] = df.ecommerce.flag_high_value_orders(threshold=500.0)

    print(
        df[
            ["order_id", "quantity", "unit_price", "net_revenue", "is_high_value"]
        ]
    )


if __name__ == "__main__":
    execute_custom_accessor()

```

### 1.3 The Verification

Run the custom accessor script:

```bash
python appx_01_custom_accessors.py

```

#### Verification Output:

```text
--- 1. Loading Dataset for Accessor Test ---

--- 2. Invoking Custom .ecommerce Namespace ---
   order_id  quantity  unit_price  net_revenue  is_high_value
0    100000         5      314.12    1460.6580           True
1    100001         1      243.68     226.6224          False
2    100002         1      180.20     167.5860          False
3    100003         3       45.50     125.5800          False
4    100004         2       92.10     171.3060          False

```

---

## 2. Handling Missing Data with Nullable Extension Dtypes (`Int64`, `boolean`)

### 2.1 The Target

Prevent standard Pandas integer columns from forcing silent conversions to `float64` when `NaN` (missing values) are introduced, using PyArrow-backed extension dtypes.

### 2.2 The Concept

Historically, standard NumPy integer arrays (`int64`) cannot store `NaN` because `NaN` is a floating-point concept. If a single missing value appeared in an integer column, Pandas automatically cast the entire column to `float64`, losing precision and breaking strict type validation schemas.

Modern Pandas (and PyArrow integration) supports **Nullable Extension Dtypes** (capitalized like `Int64`, `Int32`, `boolean`) which handle missing values natively while keeping data strictly integral.

### 2.3 The Implementation

Create a script named `appx_02_nullable_dtypes.py`:

```python
# appx_02_nullable_dtypes.py
"""
Appendix A.2: Nullable Extension Dtypes
Demonstrates how capitalized dtypes (Int64, boolean) preserve integer types with NaN.
"""

import pandas as pd


def demonstrate_nullable_dtypes() -> None:
    raw_data = {
        "order_id": [1, 2, 3],
        # Contains missing value representation
        "rating_score": [5, None, 4], 
    }

    print("--- A. Legacy Behavior (Casts to Float) ---")
    legacy_df = pd.DataFrame(raw_data)
    print(legacy_df.dtypes)
    print(legacy_df)

    print("\n--- B. Modern Extension Dtype Behavior (Preserves Int & NaN) ---")
    modern_df = pd.DataFrame(raw_data)
    # Explicitly cast to nullable extension integer dtype
    modern_df["rating_score"] = modern_df["rating_score"].astype("Int64")
    
    print(modern_df.dtypes)
    print(modern_df)


if __name__ == "__main__":
    demonstrate_nullable_dtypes()

```

### 2.4 The Verification

Run the nullable dtypes script:

```bash
python appx_02_nullable_dtypes.py

```

#### Verification Output:

```text
--- A. Legacy Behavior (Casts to Float) ---
order_id          int64
rating_score    float64
dtype: object
   order_id  rating_score
0         1           5.0
1         2           NaN
2         3           4.0

--- B. Modern Extension Dtype Behavior (Preserves Int & NaN) ---
order_id         int64
rating_score     Int64
dtype: object
   order_id  rating_score
0         1             5
1         2          <NA>
2         3             4

```
