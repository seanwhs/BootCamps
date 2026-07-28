# Trainer Guide: Data Wrangling at Scale — Facilitator Manual

---

## Module 1: Course Overview & Delivery Objectives

This intensive technical training equips professional software engineers, data analysts, and data engineers with the skills required to transition from slow, iterative Python data processing to high-performance, vectorized, memory-optimized execution using **Pandas 2.x**, **PyArrow**, and **DuckDB**.

> **Core Trainer Philosophy:** Emphasize *hardware physics* over syntax memorization. When students understand why Python object pointer chasing causes CPU cache misses, they naturally adopt vectorized C-level operations and PyArrow extension dtypes.

---

## Module 2: Suggested Module Time Allocation (1-Day Intensive / 8 Hours)

| Module / Section | Recommended Time | Primary Focus Areas |
| --- | --- | --- |
| **Module 0 & 1:** Hardware Physics & Architectural Primers | 1.5 Hours | Memory hierarchy, row vs. column storage, SIMD vectorization, Medallion Architecture. |
| **Module 2:** High-Performance Ingestion & Schemas | 1.5 Hours | PyArrow engine, explicit schema contracts, deep memory auditing (`memory_usage(deep=True)`). |
| **Module 3:** Slicing, Cleaning & Vectorized Strings | 1.25 Hours | Explicit indexing (`.loc`), boolean masking rules, vectorized `.str` string methods. |
| **Module 4:** Groupings, Pivots & Reshaping | 1.25 Hours | Split-Apply-Combine, named aggregations, MultiIndex handling, `pivot_table` vs `melt`. |
| **Module 5:** Relational Joins & Time-Series | 1.25 Hours | Join cardinality validation (`validate=`), temporal accessors (`.dt`), rolling/expanding windows. |
| **Module 6 & Appendices:** Memory Opt & DuckDB | 1.25 Hours | Categorical encoding, eliminating `.apply()` via `np.select()`, embedded SQL with DuckDB, testing & orchestration. |

---

## Module 3: Detailed Session Facilitation Notes

### Module 1: Architectural Foundations (Primers A – C)

* **Discussion Hook:** Ask the class why a 1GB CSV file takes 4GB of RAM when loaded via default Pandas settings. (Leads directly into Python object boxing and pointer overhead).
* **Whiteboard Exercise:** Draw the CPU cache hierarchy (L1/L2 vs. System RAM) and map pointer chasing versus contiguous array prefetching.
* **Key Takeaway:** Data engineering pipelines are bottlenecked by data movement, not CPU cycle compute limits.

### Module 2: Ingestion & Schema Enforcement (Phase 1)

* **Live Coding Demo:** Compare load times and memory footprints between default `pd.read_csv()` and `pd.read_csv(..., engine="pyarrow")` with an explicit dictionary schema.
* **Common Pitfall to Highlight:** Silent type coercion when integer columns contain unexpected null values (pre-Pandas 2.x behavior forcing float64 conversion). Show how nullable extension dtypes (`Int64[pyarrow]`) solve this.

### Module 3: Slicing, Cleaning & Vectorized Strings (Phase 2)

* **Warning:** Explicitly demonstrate the dreaded `SettingWithCopyWarning`. Show students how chained bracket assignment (`df[mask]['col'] = val`) breaks data integrity, and enforce `.loc[mask, 'col'] = val` as the mandatory standard.
* **Vectorization Showcase:** Benchmark `.str.lower()` and `.str.extract()` against a custom `.apply(lambda x: x.lower(), axis=1)` loop to prove C-level speedups.

### Module 4: Groupings, Pivots & Reshaping (Phase 3)

* **Best Practice:** Enforce *Named Aggregations* (`.agg(total=('rev', 'sum'))`) over legacy positional tuple syntax to maintain readable, production-grade output schemas.
* **Mental Model:** Use physical grid props to explain `pivot_table()` (long-to-wide matrix transformation) versus `melt()` (wide-to-long normalization).

### Module 5: Relational Joins & Time-Series (Phase 4)

* **Safety Check:** Emphasize the `validate` parameter in `.merge()`. Show an example where an unvalidated many-to-many join silently duplicates sales figures and corrupts downstream revenue reports.
* **Time-Series Lab:** Walk through setting a DatetimeIndex before executing `.resample('ME').mean()` and moving averages.

### Module 6: Memory Optimization & DuckDB (Phase 5)

* **Refactoring Exercise:** Take a slow row-wise `.apply(lambda row: ..., axis=1)` grading/discount script and refactor it live with students into a blistering fast `np.select()` implementation.
* **DuckDB Integration:** Demonstrate executing zero-copy analytical SQL queries directly against an active Pandas DataFrame without exporting to disk.

---

## Module 4: Trainer Assessment & Troubleshooting Guide

> **Common Student Roadblocks & Solutions**
> * **Roadblock:** Students confusing `.loc[]` and `.iloc[]`.
> 
> 
> 
> 
> **Fix:** Remind them: *L*oc is for *L*abels (names), *I*loc is for *I*nteger positions.
> * **Roadblock:** `SettingWithCopyWarning` ignored by students.
> 
> 
> 
> 
> **Fix:** Treat it as an immediate pipeline error during code reviews. Emphasize that views vs. copies cause unpredictable state corruption in large applications.
> * **Roadblock:** Confusion over PyArrow vs. standard NumPy dtypes.
> 
> 
> 
> 
> **Fix:** Reiterate that capitalized dtypes (`Int64`, `boolean`) are extension types supporting native missing values (`<NA>`).
> 
> 

---

## Module 5: Lab Checkpoint Validation Checklist

Ensure students successfully complete the following checkpoints during practical lab sessions:

* [ ] Verified memory footprint reduction of >70% after enforcing PyArrow schemas and categorical dtypes.
* [ ] Successfully replaced a slow `.apply()` row loop with vectorized `np.select()`.
* [ ] Executed a validated relational join that caught an unintended duplicate key error.
* [ ] Wrote and passed a `pytest` unit test asserting a financial calculation within a tolerance threshold (`pytest.approx`).
