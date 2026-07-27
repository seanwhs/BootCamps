# Primer B: Memory Architecture, Type Systems, and Storage Formats

Welcome to **Primer B**. Building on Primer A's exploration of hardware physics and vectorization, this second primer dives deep into how data is represented in computer memory and why choosing the correct type system and storage format is vital for building scalable data pipelines.

---

## 1. The Anatomy of Memory: Pointers vs. Contiguous Arrays

### 1.1 The Concept

At the heart of performance optimization lies memory layout. Computers access memory through cache lines. If data is stored contiguously, the CPU can prefetch subsequent values into cache, resulting in blazing-fast execution.

* **The Python Object Model (`object` dtypes):** Python is built on boxed objects. A standard Python list or Pandas `object` column does not store raw numbers or strings directly; instead, it stores an array of *pointers* (memory addresses) that point to scattered objects across system RAM. Following these pointers causes constant **cache misses**, destroying CPU efficiency.
* **The NumPy/Arrow Model:** Typed arrays store primitive values contiguously in memory (e.g., a raw block of 64-bit integers). The CPU reads these values in a single sequential sweep.

```
       PYTHON OBJECT POINTERS (Scattered RAM)
   +-----------+     +-----------+     +-----------+
   | Pointer 1 | --> | Object A  |     | Object B  |
   +-----------+     +-----------+     +-----------+
   | Pointer 2 | ----------------------->     |     
   +-----------+                              v     
                                         [Scattered RAM]

       CONTIGUOUS PRIMITIVE ARRAY (NumPy / Arrow)
   +-----------+-----------+-----------+-----------+
   |  Val 1    |  Val 2    |  Val 3    |  Val 4    |
   +-----------+-----------+-----------+-----------+
   <------------ Single CPU Cache Sweep ------------>

```

---

## 2. Type Systems: Standard NumPy vs. PyArrow vs. Extension Dtypes

Understanding type boundaries prevents silent performance degradation and data corruption:

* **Standard Pandas (`int64`, `float64`, `object`):** The legacy baseline. Prone to casting integers to floats when `NaN` is introduced.
* **NumPy Dtypes:** Highly optimized primitive types (`int32`, `float32`), but historically lacked native support for missing values or categorical string encodings.
* **PyArrow & Nullable Extension Dtypes (`Int64`, `string`):** The modern standard. PyArrow brings zero-copy memory sharing across languages (Python, R, C++) and supports native missing values (`<NA>`) without defaulting to floating-point representation.

---

## 3. Storage Formats Compared

| Format | Structure | Best Used For | Trade-offs |
| --- | --- | --- | --- |
| **CSV** | Row-oriented text | Human readability, universal interchange | Slow parsing, large file size, zero type safety |
| **JSON** | Hierarchical text / lines | API payloads, nested event logs | Verbose, expensive to parse at scale |
| **Parquet** | Columnar binary | Analytical queries, cloud storage lakes | Unoptimized for single-row point lookups |
| **Arrow (IPC/Feather)** | In-memory columnar | Inter-process communication, zero-copy reads | Storage format optimized for speed over compression |

---

## 4. Practical Demonstration: Memory Footprint & Type Inspection

Let's examine how choice of dtypes directly impacts memory consumption and structural integrity.

Create a script named `primer_02_memory_types.py`:

```python
# primer_02_memory_types.py
"""
Primer B.1: Memory Footprint & Type Analysis
Demonstrates memory allocation differences between object dtypes and downcasted extension types.
"""

import numpy as np
import pandas as pd


def inspect_memory_footprint() -> None:
    print("--- Initializing Memory Footprint Analysis ---")
    size = 200_000

    # Simulate unoptimized DataFrame
    raw_df = pd.DataFrame({
        "id": range(size),
        "category": ["Electronics"] * (size // 2) + ["Apparel"] * (size // 2),
        "score": [4.5] * size,
    })

    initial_mem = raw_df.memory_usage(deep=True).sum() / (1024 ** 2)
    print(f"Unoptimized Memory Footprint: {initial_mem:.2f} MB")
    print(raw_df.dtypes)

    print("\n--- Applying Optimization Strategy ---")
    
    # Optimize types
    optimized_df = pd.DataFrame({
        "id": pd.Series(range(size), dtype="int32"),
        "category": pd.Series(["Electronics"] * (size // 2) + ["Apparel"] * (size // 2), dtype="category"),
        "score": pd.Series([4.5] * size, dtype="float32"),
    })

    optimized_mem = optimized_df.memory_usage(deep=True).sum() / (1024 ** 2)
    savings = ((initial_mem - optimized_mem) / initial_mem) * 100

    print(f"Optimized Memory Footprint  : {optimized_mem:.2f} MB")
    print(f"Memory Savings Achieved     : {savings:.1f}%")
    print(optimized_df.dtypes)


if __name__ == "__main__":
    inspect_memory_footprint()

```

### Execution & Verification

Run the primer script:

```bash
python primer_02_memory_types.py

```

#### Expected Output:

```text
--- Initializing Memory Footprint Analysis ---
Unoptimized Memory Footprint: 26.71 MB
id             int64
category      object
score        float64
dtype: object

--- Applying Optimization Strategy ---
Optimized Memory Footprint  : 1.14 MB
Memory Savings Achieved     : 95.7%
id              int32
category     category
score         float32
dtype: object

```
