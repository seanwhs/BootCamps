## Appendix D: Extending DuckDB with Python UDFs (User-Defined Functions)

### Module Overview

In this appendix, we explore how to extend DuckDB's native SQL capabilities by writing custom **User-Defined Functions (UDFs)** in Python. While SQL handles relational filtering, joins, and aggregations exceptionally well, you often need custom business logic, external API calls, or specialized string manipulation that standard SQL operators cannot express. We will learn how to register Python functions so they execute seamlessly and at scale directly within DuckDB query pipelines.

---

### Conceptual Deep Dive: Python UDF Execution & Vectorization

#### 1. The UDF Performance Challenge

In traditional database engines, calling a Python UDF inside a SQL query requires row-by-row iteration (scalar execution). The database engine passes a single value across the Python-database language boundary, executes the Python function, returns the scalar result, and repeats this millions of times. This introduces severe inter-process communication overhead, often destroying query performance.

#### 2. Vectorized Python UDFs (Arrow-backed UDFs)

DuckDB solves this bottleneck by supporting **vectorized Python UDFs** (powered by Apache Arrow):

* Instead of passing single scalar rows, DuckDB passes entire **Arrow vectors** (or Pandas Series / PyArrow arrays) to your Python function in a single batch.
* Your Python function operates on the entire batch at once, enabling vectorized operations (such as NumPy or vectorized Pandas string methods).
* This minimizes boundary-crossing overhead, allowing custom Python logic to run at speeds approaching native C++ extensions.

---

### Practical Demonstration: Registering and Executing Custom Python UDFs

Let us implement a script that registers a custom Python UDF to categorize transaction risk levels based on custom business rules, executing it directly inside a DuckDB SQL statement.

#### 1. The Implementation

Create a script named `python_udf_demo.py`:

```python
# File: python_udf_demo.py
import duckdb
import pandas as pd

def calculate_risk_score(amount: float, quantity: int) -> str:
    """Custom business logic function to determine transaction risk."""
    total_value = amount * quantity
    if total_value > 3000:
        return "HIGH_RISK"
    elif total_value > 1000:
        return "MEDIUM_RISK"
    else:
        return "LOW_RISK"

def run_udf_pipeline() -> None:
    conn = duckdb.connect(":memory:")
    
    print("--- 1. Registering Python UDF in DuckDB ---")
    # Register the Python function with DuckDB, specifying input types and return type
    conn.create_function(
        "calc_risk",
        calculate_risk_score,
        parameters=[duckdb.typing.DOUBLE, duckdb.typing.INTEGER],
        return_type=duckdb.typing.VARCHAR
    )
    
    print("--- 2. Executing SQL Query Utilizing the Custom UDF ---")
    udf_query = """
        SELECT 
            transaction_id,
            category,
            amount,
            quantity,
            amount * quantity AS total_value,
            calc_risk(amount, quantity) AS risk_level
        FROM read_csv('data/transactions.csv')
        WHERE calc_risk(amount, quantity) != 'LOW_RISK'
        ORDER BY total_value DESC
        LIMIT 10;
    """
    
    result_df = conn.execute(udf_query).fetchdf()
    print(result_df)
    
    conn.close()

if __name__ == "__main__":
    run_udf_pipeline()

```

#### 2. The Verification

Run the script:

```bash
python python_udf_demo.py

```

*Expected Output:* A filtered Pandas DataFrame displaying transactions evaluated and tagged by our custom Python business logic function directly inside the SQL execution stream.
