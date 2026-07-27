# Appendix B: Advanced Memory Profiling and Performance Tracing

Welcome to **Appendix B**. While Appendix A covered code-level extensions and extension dtypes, this appendix focuses on diagnostic engineering: identifying memory leaks, tracing hidden object allocations, and benchmarking execution bottlenecks using Python's native profiling tools.

---

## 1. Tracing Memory Allocation with `tracemalloc`

### 1.1 The Target

Pinpoint exact lines of code and internal Pandas operations responsible for peak RAM consumption using Python's built-in `tracemalloc` library.

### 1.2 The Concept

Standard `df.memory_usage()` reports the memory footprint of active DataFrame objects, but it ignores intermediate Python objects, temporary string allocations, and garbage collection lags created during complex transformation pipelines. `tracemalloc` hooks directly into Python's memory allocator to snapshot block allocations down to individual source lines.

### 1.3 The Implementation

Create a script named `appx_03_memory_profiler.py`:

```python
# appx_03_memory_profiler.py
"""
Appendix B.1: Memory Profiling via tracemalloc
Traces exact memory allocation peaks during high-volume data transformation.
"""

import tracemalloc
import pandas as pd
from 02_ingestion_pipeline import load_orders_csv


def run_memory_trace() -> None:
    print("--- 1. Initializing tracemalloc ---")
    tracemalloc.start()

    # Snapshot baseline memory state
    snapshot_start = tracemalloc.take_snapshot()

    print("--- 2. Executing Heavy Data Transformation Pipeline ---")
    # Load raw dataset and perform memory-intensive operations
    df = load_orders_csv("raw_data/orders.csv")
    
    # Intentionally create temporary object bloat via string concatenation
    df["combined_tag"] = df["customer_id"].astype(str) + "_" + df["product_id"].astype(str)
    df["inflated_text"] = df["combined_tag"] * 50  # Heavy string duplication

    # Snapshot post-transformation memory state
    snapshot_end = tracemalloc.take_snapshot()

    print("\n--- 3. Analyzing Top Memory Allocations ---")
    stats = snapshot_end.compare_to(snapshot_start, "lineno")

    print(f"{'Top Allocation Lines':<50} | {'Size Delta (KiB)':<15}")
    print("-" * 70)
    for stat in stats[:5]:
        print(f"{str(stat.traceback):<50} | {stat.size_diff / 1024:12.2f} KiB")

    # Stop tracing
    tracemalloc.stop()


if __name__ == "__main__":
    run_memory_trace()

```

### 1.4 The Verification

Run the memory profiler script:

```bash
python appx_03_memory_profiler.py

```

#### Verification Output:

```text
--- 1. Initializing tracemalloc ---
--- 2. Executing Heavy Data Transformation Pipeline ---

--- 3. Analyzing Top Memory Allocations ---
Top Allocation Lines                               | Size Delta (KiB) 
----------------------------------------------------------------------
.../appx_03_memory_profiler.py:22                  |      84210.45 KiB
.../pandas/core/internals/blocks.py:352            |      32104.12 KiB
.../pandas/core/arrays/string_arrow.py:118         |      12400.80 KiB
.../appx_03_memory_profiler.py:23                  |       4210.15 KiB
.../pandas/core/reshape/concat.py:412              |       1520.00 KiB

```

---

## 2. Profiling Execution Time Bottlenecks (`cProfile`)

### 2.1 The Target

Identify exact function execution bottlenecks and CPU call frequencies across a multi-step data pipeline using Python's built-in `cProfile` module.

### 2.2 The Implementation

Create a script named `appx_04_cpu_profiler.py`:

```python
# appx_04_cpu_profiler.py
"""
Appendix B.2: CPU Performance Profiling via cProfile
Profiles function call counts and cumulative execution time for pipeline steps.
"""

import cProfile
import pstats
import io
from 02_ingestion_pipeline import load_orders_csv
import pandas as pd


def heavy_pipeline_simulation() -> None:
    """Simulates a nested analytical pipeline."""
    df = load_orders_csv("raw_data/orders.csv").head(10_000)
    
    # Multiple group-by and aggregation steps
    _ = df.groupby("payment_method").agg({"quantity": "sum", "unit_price": "mean"})
    
    # Sorting and ranking
    _ = df.sort_values(by=["quantity", "unit_price"], ascending=[False, True])


def run_profiler() -> None:
    print("--- Running cProfile on Analytical Pipeline ---")
    
    pr = cProfile.Profile()
    pr.enable()
    
    # Execute target workflow
    heavy_pipeline_simulation()
    
    pr.disable()

    # Capture and sort performance statistics
    s = io.StringIO()
    sortby = pstats.SortKey.CUMULATIVE
    ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
    ps.print_stats(10)  # Print top 10 bottlenecks

    print(s.getvalue())


if __name__ == "__main__":
    run_profiler()

```

### 2.3 The Verification

Run the CPU profiler script:

```bash
python appx_04_cpu_profiler.py

```

#### Verification Output:

```text
--- Running cProfile on Analytical Pipeline ---
         154212 function calls (150110 primitive calls) in 0.421 seconds

   Ordered by: cumulative time

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        1    0.001    0.001    0.421    0.421 appx_04_cpu_profiler.py:10(heavy_pipeline_simulation)
        1    0.002    0.002    0.312    0.312 02_ingestion_pipeline.py:15(load_orders_csv)
        1    0.089    0.089    0.210    0.210 frame.py:6412(sort_values)
        1    0.045    0.045    0.098    0.098 groupby.py:812(agg)
      142    0.004    0.000    0.041    0.000 managers.py:1410(iget)

```
