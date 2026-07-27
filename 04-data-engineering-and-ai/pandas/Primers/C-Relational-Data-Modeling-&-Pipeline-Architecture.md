# Primer C: Relational Data Modeling & Pipeline Architecture

Welcome to **Primer C**. Having examined hardware physics in Primer A and memory layout in Primer B, we now turn our focus to relational data modeling and architectural patterns. This final primer explores how transactional boundaries, star schemas, and modular pipelines govern robust data systems.

---

## 1. Relational Paradigms: Normalization vs. Denormalization

### 1.1 The Concept

When designing data pipelines, data engineers must balance structural integrity with analytical query performance.

* **Normalized Models (OLTP):** Designed to eliminate data redundancy and ensure transactional integrity (ACID). Tables are split into narrow entities connected by foreign keys. While efficient for inserts and updates, joining normalized tables for analytical queries introduces heavy CPU overhead.
* **Denormalized Models (OLAP / Star Schema):** Designed for analytical speed. Data is consolidated into central **fact tables** (containing quantitative measurements and foreign keys) surrounded by **dimension tables** (containing descriptive attributes like category names or customer regions).

```
       STAR SCHEMA ARCHITECTURE (OLAP)
            [ Dimension: Products ]
                       |
                       v
    [ Dimension: Customers ] <---> [ Fact Table: Orders ] <---> [ Dimension: Geography ]
                       ^
                       |
              [ Dimension: Time ]

```

---

## 2. Pipeline Architecture: The Medallion Pattern

Modern data lakes typically adopt a layered architectural pattern known as the **Medallion Architecture**:

1. **Bronze Layer (Raw / Ingestion):** Immutable, raw storage matching source systems exactly (CSV, JSON, APIs). Strict schema enforcement begins here.
2. **Silver Layer (Cleaned / Conformed):** Filtered, type-cast, and deduplicated records with enriched metadata and relational joins applied.
3. **Gold Layer (Aggregated / Business-Level):** Highly summarized, denormalized data ready for BI dashboards, machine learning models, or executive reporting.

---

## 3. Practical Demonstration: Star Schema Fact-Dimension Simulation

Let's look at a conceptual demonstration modeling a denormalized enrichment pipeline that merges transaction logs with a product catalog.

Create a script named `primer_03_relational_architecture.py`:

```python
# primer_03_relational_architecture.py
"""
Primer C.1: Relational Fact-Dimension Modeling
Demonstrates star schema enrichment by joining raw transaction facts with product dimensions.
"""

import pandas as pd


def execute_relational_model() -> None:
    print("--- Initializing Relational Architecture Simulation ---")

    # 1. Mock Fact Table (Transactions)
    fact_orders = pd.DataFrame({
        "order_id": [101, 102, 103],
        "product_id": ["P_A", "P_B", "P_A"],
        "quantity": [2, 1, 4],
    })

    # 2. Mock Dimension Table (Product Catalog)
    dim_products = pd.DataFrame({
        "product_id": ["P_A", "P_B", "P_C"],
        "category": ["Electronics", "Apparel", "Books"],
        "unit_price": [250.0, 75.0, 30.0],
    })

    print("Fact Orders Shape: (3, 3) | Dim Products Shape: (3, 3)")

    # 3. Execute Star Schema Left Join (Enrichment)
    denormalized_df = fact_orders.merge(
        dim_products,
        on="product_id",
        how="left",
        validate="many_to_one",
    )

    # Calculate gross revenue metric
    denormalized_df["gross_revenue"] = denormalized_df["quantity"] * denormalized_df["unit_price"]

    print("\nDenormalized Result (Gold/Silver Tier Simulation):")
    print(denormalized_df[["order_id", "category", "quantity", "unit_price", "gross_revenue"]])


if __name__ == "__main__":
    execute_relational_model()

```

### Execution & Verification

Run the primer script:

```bash
python primer_03_relational_architecture.py

```

#### Expected Output:

```text
--- Initializing Relational Architecture Simulation ---
Fact Orders Shape: (3, 3) | Dim Products Shape: (3, 3)

Denormalized Result (Gold/Silver Tier Simulation):
   order_id     category  quantity  unit_price  gross_revenue
0       101  Electronics         2       250.0          500.0
1       102      Apparel         1        75.0           75.0
2       103  Electronics         4       250.0         1000.0

```
