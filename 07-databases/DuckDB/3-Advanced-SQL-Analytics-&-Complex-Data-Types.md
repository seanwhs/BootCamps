## Part 3: Advanced SQL Analytics & Complex Data Types

### Module Overview

In this module, we move beyond basic aggregations and explore DuckDB's advanced SQL dialect. We will harness window functions for time-series analysis, work natively with complex nested data structures (Arrays, Structs, and Maps), execute multi-table relational joins, and utilize `PIVOT`/`UNPIVOT` operators to reshape analytical datasets.

---

### Conceptual Deep Dive: Advanced SQL Mechanics in OLAP

#### 1. Window Functions & Frame Specifications

Window functions allow you to perform calculations across sets of rows related to the current row without collapsing the result set (unlike `GROUP BY`). DuckDB optimizes window calculations by sorting and streaming partitions through memory efficiently, making moving averages, running totals, and lag/lead calculations lightning fast even on millions of rows.

#### 2. Nested Data Types in Columnar Engines

Traditional relational databases force data into strict first normal form (1NF) tables, requiring complex foreign key joins to handle lists or key-value attributes. DuckDB natively supports **complex data types**:

* **ARRAYS / LISTS:** Ordered sequences of elements of the same type.
* **STRUCTS:** Fixed collections of named fields (similar to dictionaries or JSON objects).
* **MAPS:** Key-value data structures.

Because DuckDB stores data columnarly, nested types are stored efficiently in contiguous blocks of memory, allowing you to query interior fields without unpacking the entire row.

#### 3. Reshaping with PIVOT and UNPIVOT

Data analysis frequently requires pivoting long-format data into wide-format summary tables (or vice versa). DuckDB provides native, highly optimized SQL operators (`PIVOT` and `UNPIVOT`) that handle aggregation and transformation dynamically during query execution.

---

### Step-by-Step Implementation

#### Step 1: Time-Series Window Functions & Moving Averages

##### 1. The Target

Create a script (`advanced_analytics.py`) that utilizes DuckDB window functions to calculate 7-day moving averages and running totals of daily sales revenue.

##### 2. The Concept

To analyze trends over time, we often need to smooth out daily volatility. A window function with a moving frame specification (`ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`) computes aggregates over a rolling window of rows without losing individual daily granularity.

##### 3. The Implementation

Create a file named `advanced_analytics.py`:

```python
# File: advanced_analytics.py
import duckdb

def run_window_analytics() -> None:
    conn = duckdb.connect(":memory:")
    
    print("--- 1. Setting up Daily Aggregated View ---")
    # First, aggregate transactions by date
    conn.execute("""
        CREATE TABLE daily_sales AS
        SELECT 
            CAST(transaction_date AS DATE) AS sale_date,
            category,
            SUM(amount * quantity) AS daily_revenue,
            COUNT(transaction_id) AS transaction_count
        FROM read_csv('data/transactions.csv')
        GROUP BY 1, 2;
    """)
    
    print("\n--- 2. Executing Window Functions (Running Totals & Moving Averages) ---")
    window_query = """
        SELECT 
            sale_date,
            category,
            daily_revenue,
            -- Running total revenue per category over time
            SUM(daily_revenue) OVER (
                PARTITION BY category 
                ORDER BY sale_date 
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS running_total_revenue,
            -- 7-day moving average of daily revenue per category
            AVG(daily_revenue) OVER (
                PARTITION BY category 
                ORDER BY sale_date 
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ) AS moving_avg_7d
        FROM daily_sales
        ORDER BY category, sale_date
        LIMIT 15;
    """
    
    result_df = conn.execute(window_query).fetchdf()
    print(result_df)
    
    conn.close()

if __name__ == "__main__":
    run_window_analytics()

```

##### 4. The Verification

Run the script:

```bash
python advanced_analytics.py

```

*Expected Output:* You will see a structured Pandas DataFrame showing the daily revenue alongside calculated running totals and 7-day moving averages partitioned by product category.

---

#### Step 2: Working with Nested Data Structures (Structs and Lists)

##### 1. The Target

Extend `advanced_analytics.py` to demonstrate DuckDB's native handling of Structs and Lists, constructing nested records directly from relational data.

##### 2. The Concept

Real-world APIs and modern data stores often pass nested JSON payloads. DuckDB allows you to construct and query nested data structures using dot notation (`struct_column.field`) and list comprehension or unnesting functions (`UNNEST()`) without leaving SQL.

##### 3. The Implementation

Append the following function to `advanced_analytics.py`:

```python
def run_nested_data_queries() -> None:
    conn = duckdb.connect(":memory:")
    
    print("\n--- 3. Constructing and Querying Nested Structs and Lists ---")
    nested_query = """
        WITH nested_tx AS (
            SELECT 
                transaction_id,
                category,
                -- Create a Struct representing item financial details
                {'unit_price': amount, 'qty': quantity, 'total': amount * quantity} AS financial_metrics,
                -- Create a List of tags based on amount size
                CASE 
                    WHEN amount > 1000 THEN ['High-Value', 'Priority']
                    WHEN amount > 500 THEN ['Medium-Value']
                    ELSE ['Standard']
                END AS transaction_tags
            FROM read_csv('data/transactions.csv')
            LIMIT 5
        )
        SELECT 
            transaction_id,
            category,
            financial_metrics.total AS calculated_total,
            transaction_tags
        FROM nested_tx;
    """
    
    result_df = conn.execute(nested_query).fetchdf()
    print(result_df)
    
    print("\n--- 4. Unnesting List Elements ---")
    unnest_query = """
        WITH tagged_tx AS (
            SELECT 
                transaction_id,
                CASE 
                    WHEN amount > 1000 THEN ['High-Value', 'Priority']
                    ELSE ['Standard']
                END AS tags
            FROM read_csv('data/transactions.csv')
            LIMIT 3
        )
        SELECT 
            transaction_id,
            UNNEST(tags) AS individual_tag
        FROM tagged_tx;
    """
    print(conn.execute(unnest_query).fetchdf())
    
    conn.close()

if __name__ == "__main__":
    run_window_analytics()
    run_nested_data_queries()

```

##### 4. The Verification

Run the updated script:

```bash
python advanced_analytics.py

```

*Expected Output:* You will see extracted fields from the Struct (`financial_metrics.total`) and expanded rows resulting from the `UNNEST()` function on the list of tags.

---

#### Step 3: Dynamic PIVOT Operations

##### 1. The Target

Use DuckDB's native `PIVOT` operator to transform row-based categories into column-based metrics by month.

##### 2. The Concept

Pivoting data traditionally requires complex conditional aggregation (`SUM(CASE WHEN category = 'X' THEN ...)`). DuckDB's native `PIVOT` syntax automates this transformation natively and efficiently inside the execution engine.

##### 3. The Implementation

Add the following pivot function to `advanced_analytics.py`:

```python
def run_pivot_analysis() -> None:
    conn = duckdb.connect(":memory:")
    
    print("\n--- 5. Dynamic PIVOT: Monthly Revenue by Category ---")
    pivot_query = """
        PIVOT (
            SELECT 
                EXTRACT(YEAR FROM CAST(transaction_date AS DATE)) AS txn_year,
                EXTRACT(MONTH FROM CAST(transaction_date AS DATE)) AS txn_month,
                category,
                amount * quantity AS revenue
            FROM read_csv('data/transactions.csv')
        )
        ON category
        USING SUM(revenue)
        GROUP BY txn_year, txn_month
        ORDER BY txn_year, txn_month;
    """
    
    result_df = conn.execute(pivot_query).fetchdf()
    print(result_df)
    
    conn.close()

if __name__ == "__main__":
    run_window_analytics()
    run_nested_data_queries()
    run_pivot_analysis()

```

##### 4. The Verification

Run the complete script:

```bash
python advanced_analytics.py

```

*Expected Output:* A wide-format matrix displaying columns for each product category containing summed monthly revenues.

---

### Phase 3 Reference Section: Advanced SQL Operators Cheat Sheet

| Operator / Clause | Purpose | Example Syntax |
| --- | --- | --- |
| `WINDOW` alias | Defines reusable window specifications. | `WINDOW w AS (PARTITION BY category ORDER BY date)` |
| `STRUCT` `{...}` | Groups related fields into a single named record. | `{'name': col1, 'val': col2}` |
| `UNNEST()` | Flattens an array or list into multiple rows. | `SELECT UNNEST(tags) FROM table` |
| `PIVOT ... ON ...` | Transposes rows into columns based on aggregate functions. | `PIVOT (SELECT ...) ON category USING SUM(rev)` |
| `COLUMNS(*)` | Applies lambda expressions across multiple matching columns. | `SELECT SUM(COLUMNS(*)) FROM df` |
