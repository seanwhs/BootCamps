# Quiz Bank: Data Wrangling at Scale — The Definitive Pandas Guide

Welcome to the **Quiz Bank**. This question bank covers all concepts from the primers, core curriculum phases, and advanced appendices. Use this resource to test your mastery of Pandas engineering, memory optimization, and pipeline architecture. Answer keys are provided at the end of each section.

---

## Part 1: Architectural Primers & Hardware Physics (Questions 1 – 15)

### Q1. Which component in the memory hierarchy typically exhibits the lowest latency access time?

* A) System RAM (DDR5)
* B) NVMe SSD Storage
* C) L1/L2 CPU Cache
* D) Cloud Blob Storage

### Q2. What is the primary architectural advantage of a column-oriented storage format (like Parquet) over a row-oriented format (like CSV) for analytical workloads (OLAP)?

* A) Faster row insertion speeds
* B) Projection pruning (skipping irrelevant columns entirely)
* C) Human readability and plain-text debugging
* D) Native support for nested JSON objects without schema declaration

### Q3. Why do standard Python loops (`.iterrows()`, `.apply()`) perform poorly on large DataFrames?

* A) They rely on multi-threaded CPU task graphs that cause race conditions.
* B) They incur severe dynamic typing, object boxing, and interpreter overhead per row.
* C) They automatically convert all primitive integers into floating-point numbers.
* D) They require exclusive file locks that block system memory allocation.

### Q4. What does SIMD stand for in the context of vectorized C-level operations?

* A) Single Instruction, Multiple Data
* B) Sequential Indexing, Memory Distribution
* C) Synchronous Inter-Process Management Division
* D) Standardized Ingestion & Metadata Declaration

### Q5. In Python, what causes high cache miss rates when iterating over standard object-dtype arrays?

* A) Continuous memory layout storing raw primitive values back-to-back
* B) Pointer chasing (following memory addresses scattered across the heap)
* C) Automatic garbage collection clearing active index labels
* D) Thread synchronization locks in the global interpreter lock (GIL)

### Q6. True or False: Standard NumPy arrays natively support missing values (`NaN`) inside integer dtypes without converting the array to float64.

* A) True
* B) False

### Q7. Which file format stores data using an in-memory columnar layout that allows zero-copy deserialization across different programming languages?

* A) CSV
* B) JSON
* C) Apache Parquet
* D) Apache Arrow (IPC / Feather)

### Q8. What is the primary characteristic of a normalized relational model (OLTP 3NF)?

* A) Denormalized wide tables optimized for summary reporting
* B) Fact tables surrounded by descriptive dimension tables
* C) Split tables designed to eliminate data redundancy and ensure transactional integrity
* D) Immutable storage layers residing in cloud blob buckets

### Q9. In the Medallion Architecture, which tier represents the raw, immutable ingestion layer matching source systems exactly?

* A) Bronze Layer
* B) Silver Layer
* C) Gold Layer
* D) Platinum Layer

### Q10. What is the main risk of failing to enforce explicit schema contracts at pipeline ingestion boundaries?

* A) Faster file parsing speeds due to automatic type inference
* B) Silent type coercion, memory bloat, and downstream pipeline failures from schema drift
* C) Automatic creation of missing indexes and primary keys
* D) Elimination of all null values in categorical columns

### Q11. Which storage layout is optimized for transactional database writes and rapid single-row updates (OLTP)?

* A) Column-oriented storage
* B) Row-oriented storage
* C) Key-value cache storage
* D) Graph database storage

### Q12. What performance impact does hardware memory bandwidth have on data engineering pipelines?

* A) None; CPU clock speed is the sole bottleneck for data frame operations.
* B) High impact; pipelines are frequently bound by how fast data can be moved from system RAM to CPU registers.
* C) It only affects network streaming throughput, not local dataframe transformations.
* D) It prevents multi-threaded file parsing.

### Q13. Why are Python objects boxed?

* A) To wrap primitive values with type metadata and reference counts required by the dynamic interpreter
* B) To compress data into secure cryptographic containers
* C) To serialize tables directly into Apache Parquet format
* D) To enable zero-copy memory sharing across processes

### Q14. What is a star schema composed of?

* A) A single flat table containing all transactional and descriptive attributes
* B) A central fact table surrounded by multiple dimension tables
* C) Hierarchical JSON trees nested within relational foreign keys
* D) Asynchronous event queues streaming logs to disk

### Q15. What is the purpose of pipeline validation checks at ingestion boundaries?

* A) To pause pipeline execution for human code reviews
* B) To verify row counts, schemas, and non-null constraints before downstream processing
* C) To compress raw files into ZIP archives
* D) To generate executive PDF dashboards automatically

---

**Part 1 Answer Key:**

1. **C** | 2. **B** | 3. **B** | 4. **A** | 5. **B** | 6. **B** | 7. **D** | 8. **C** | 9. **A** | 10. **B** | 11. **B** | 12. **B** | 13. **A** | 14. **B** | 15. **B**

---

## Part 2: Core Curriculum — Phases 1 to 3 (Questions 16 – 35)

### Q16. Which parameter in `pd.read_csv()` enables PyArrow-backed acceleration and parallel file parsing?

* A) `engine="python"`
* B) `engine="pyarrow"`
* C) `low_memory=True`
* D) `memory_map=False`

### Q17. Why does standard `df.info()` sometimes underreport true memory usage?

* A) It ignores float64 columns entirely.
* B) It excludes object pointer overhead and referenced string objects residing on the heap.
* C) It only measures memory consumed after saving to disk.
* D) It calculates memory usage in bits instead of megabytes.

### Q18. How do you correctly invoke deep memory auditing on a Pandas DataFrame?

* A) `df.memory_usage()`
* B) `df.info(verbose=True)`
* C) `df.memory_usage(deep=True).sum()`
* D) `df.deep_memory()`

### Q19. What is the primary danger of using bracket indexing (`df[col]`) for conditional data mutation in production code?

* A) It throws an immediate SyntaxError.
* B) It triggers undefined behavior related to chained assignment and `SettingWithCopyWarning`.
* C) It automatically converts strings to datetime objects.
* D) It deletes the DataFrame index.

### Q20. Which method should be used to select rows and columns strictly by integer positional coordinates?

* A) `df.loc[]`
* B) `df.iloc[]`
* C) `df.ix[]`
* D) `df.at[]`

### Q21. When constructing a complex boolean filter mask in Pandas, why must individual conditions be wrapped in parentheses?

* A) To satisfy Python operator precedence rules for bitwise operators (`&`, `|`, `~`)
* B) To convert boolean arrays into string categories
* C) To prevent memory leaks during slicing
* D) To enable multi-threaded execution across CPU cores

### Q22. What is the function of the `.str` accessor namespace on a Pandas Series?

* A) It converts numerical columns into string representations.
* B) It exposes vectorized string manipulation methods executed at C-level across all elements simultaneously.
* C) It extracts the index labels of a DataFrame.
* D) It compresses text columns into binary Parquet files.

### Q23. How do you handle malformed records during high-performance CSV ingestion without breaking the batch?

* A) Use `errors='coerce'` or quarantine bad rows into an isolated error log using try-except blocks.
* B) Halt the program immediately upon encountering any parse error.
* C) Replace all missing values with random floating-point numbers.
* D) Disable schema validation entirely.

### Q24. What happens when you execute `df['col'].fillna(method='ffill')`?

* A) Missing values are filled with the global mean of the column.
* B) Missing values are filled using the last valid observation carried forward (forward fill).
* C) Missing values are dropped from the DataFrame.
* D) Missing values are replaced with zeros.

### Q25. What are the three conceptual stages of the Split-Apply-Combine grouping pattern?

* A) Load, Transform, Write
* B) Split, Apply, Combine
* C) Map, Reduce, Shuffle
* D) Ingest, Validate, Pivot

### Q26. Which syntax demonstrates correct named aggregation inside `.groupby().agg()`?

* A) `df.groupby('cat').agg(total=('price', 'sum'))`
* B) `df.groupby('cat').agg('sum', col='price')`
* C) `df.groupby('cat').aggregate(sum(['price']))`
* D) `df.groupby('cat').sum(name='total')`

### Q27. What data structure is generated when you group a DataFrame by multiple columns without resetting the index?

* A) A flattened single-level DataFrame
* B) A MultiIndex (hierarchical index) DataFrame
* C) A pivot matrix
* D) A NumPy 3D tensor

### Q28. Which method is used to flatten or reset a hierarchical MultiIndex back into standard columns?

* A) `df.flatten()`
* B) `df.reset_index()`
* C) `df.unstack_all()`
* D) `df.stack()`

### Q29. What is the primary purpose of `pd.pivot_table()`?

* A) To convert wide tables into long-format event logs
* B) To reshape tall transactional records into a summary matrix across multiple index and column dimensions
* C) To merge two dataframes on a shared foreign key
* D) To sort rows alphabetically by index

### Q30. Which Pandas function performs the inverse operation of `pivot_table()`, transforming wide tables into long format?

* A) `pd.melt()`
* B) `pd.concat()`
* C) `pd.stack()`
* D) `pd.merge()`

### Q31. In `pd.melt()`, what does the `id_vars` parameter specify?

* A) The metric columns to be unpivoted into key-value rows
* B) The identifier columns that remain preserved as primary reference keys during unpivoting
* C) The index levels of a MultiIndex series
* D) The output column names for aggregated sums

### Q32. True or False: Named aggregations allow you to explicitly define output column names while applying multiple aggregation functions to different columns simultaneously.

* A) True
* B) False

### Q33. What is the result of calling `.dropna(subset=['order_id'])`?

* A) Drops all rows where `order_id` contains a null value
* B) Drops the `order_id` column entirely from the DataFrame
* C) Fills missing `order_id` values with zeros
* D) Sorts the DataFrame by `order_id`

### Q34. How does `.loc[]` differ from `.iloc[]`?

* A) `.loc[]` indexes by explicit labels, while `.iloc[]` indexes by integer positional coordinates.
* B) `.loc[]` only works on Series, while `.iloc[]` works on DataFrames.
* C) `.loc[]` is slower because it uses Python loops.
* D) There is no difference; they are interchangeable aliases.

### Q35. What is the effect of passing `fill_value=0` into a pivot table operation?

* A) It replaces all numerical data in the DataFrame with zeros.
* B) It fills missing intersections resulting from the pivot with the value 0 instead of NaN.
* C) It drops rows containing zero values.
* D) It converts integer columns to float64.

---

**Part 2 Answer Key:**
16. **B** | 17. **B** | 18. **C** | 19. **B** | 20. **B** | 21. **A** | 22. **B** | 23. **A** | 24. **B** | 25. **B** | 26. **A** | 27. **B** | 28. **B** | 29. **B** | 30. **A** | 31. **B** | 32. **A** | 33. **A** | 34. **A** | 35. **B**

---

## Part 3: Core Curriculum — Phases 4 & 5 (Questions 36 – 55)

### Q36. What is the purpose of the `validate` parameter in `pd.merge()`?

* A) To check if the output file path exists on disk
* B) To enforce relational cardinality constraints (e.g., `many_to_one`) and raise an error if violated
* C) To validate datetime string formats automatically
* D) To compress the merged DataFrame using PyArrow

### Q37. What happens when you execute `pd.concat([df1, df2], axis=0, ignore_index=True)`?

* A) DataFrames are joined side-by-side along their columns, resetting the index.
* B) DataFrames are stacked vertically, and a fresh continuous integer index is generated.
* C) DataFrames are merged on matching primary keys.
* D) The operation fails if column names do not match identically.

### Q38. Which accessor namespace is required to extract temporal components (like year, month, or day) from a datetime column?

* A) `.str`
* B) `.dt`
* C) `.cat`
* D) `.meta`

### Q39. What is required before calling `.resample()` on a time-series DataFrame?

* A) The DataFrame must be sorted in descending order.
* B) The target datetime column must be set as the active DataFrame index.
* C) All categorical columns must be dropped.
* D) The DataFrame must be exported to Parquet format.

### Q40. What does a 7-day rolling window calculation (`.rolling(window=7).mean()`) compute?

* A) The cumulative sum of the entire dataset from inception
* B) The moving average across the current row and the preceding 6 rows
* C) The difference between current and future values shifted by 7 periods
* D) The annual compound growth rate

### Q41. How does `.expanding()` differ from `.rolling()`?

* A) `.expanding()` uses a fixed window size that moves forward, while `.expanding()` grows dynamically to include all prior rows from the start of the series.
* B) `.expanding()` only works on numeric columns, while `.rolling()` works on strings.
* C) `.expanding()` requires a datetime index, while `.rolling()` does not.
* D) There is no difference; they are aliases.

### Q42. What is the purpose of `.shift(1)` on a time-series Series?

* A) It shifts all values upward by one position (leading indicator).
* B) It shifts all values downward by one position, exposing prior values as a lag.
* C) It sorts the series in reverse chronological order.
* D) It deletes the first row of the dataset.

### Q43. What is the memory reduction benefit of converting a low-cardinality string column to a `category` dtype?

* A) Zero reduction; category dtypes consume more memory than strings.
* B) Up to 90% memory reduction by storing underlying data as integer codes mapped to a dictionary of unique labels.
* C) Automatic conversion of strings into floating-point numbers.
* D) Elimination of all null values in the column.

### Q44. How does downcasting numeric types (`pd.to_numeric(..., downcast='integer')`) optimize memory?

* A) It converts integers to strings.
* B) It compresses oversized bit-widths (e.g., downcasting int64 to int8, int16, or int32 based on min/max values).
* C) It replaces missing values with negative numbers.
* D) It converts integers to floats.

### Q45. Why is `np.select()` preferred over `df.apply(lambda row: ..., axis=1)` for complex conditional column logic?

* A) `np.select()` executes vectorized conditional evaluations in compiled C code, avoiding slow Python interpreter row loops.
* B) `np.select()` automatically handles missing values without raising errors.
* C) `np.apply()` is deprecated in Pandas 2.x and will raise a SyntaxError.
* D) `np.select()` requires fewer lines of code to write.

### Q46. What does the `SettingWithCopyWarning` in Pandas signify?

* A) Your script is running out of system RAM.
* B) You are performing chained assignment, and Pandas cannot guarantee whether your modification updates a view or a copy.
* C) Your DataFrame schema violates PyArrow contracts.
* D) Your merge operation resulted in duplicate keys.

### Q47. How do you correctly resolve a `SettingWithCopyWarning` when updating a filtered subset?

* A) Use chained brackets: `df[mask]['col'] = value`
* B) Use explicit `.loc` assignment: `df.loc[mask, 'col'] = value`
* C) Disable warnings globally using `pd.set_option('mode.chained_assignment', None)` without fixing the code.
* D) Convert the DataFrame to a NumPy array before mutating.

### Q48. What is the primary architectural advantage of using **DuckDB** alongside Pandas?

* A) It replaces Python with C++ for all file ingestion tasks.
* B) It executes zero-copy SQL analytical queries directly against active Pandas DataFrames in memory at native speed.
* C) It automatically uploads local CSV files to cloud blob storage.
* D) It converts Pandas DataFrames into immutable CSV files.

### Q49. What frequency code represents a Monthly end frequency in Pandas resampling?

* A) `'D'`
* B) `'W'`
* C) `'ME'` (or `'M'`)
* D) `'Y'`

### Q50. What is the result of executing `df['revenue'].pct_change()`?

* A) It calculates the cumulative sum of revenue over time.
* B) It calculates the fractional percentage change between current and prior elements in the series.
* C) It replaces missing revenue values with percentage averages.
* D) It scales revenue values between 0 and 1.

### Q51. When performing a join, what does `validate="one_to_many"` enforce?

* A) That keys are unique in both left and right DataFrames
* B) That keys are unique in the left DataFrame and non-unique in the right DataFrame
* C) That keys are non-unique in both DataFrames
* D) That no missing values exist in the join key columns

### Q52. True or False: Converting string columns to categorical dtypes can significantly accelerate grouping and sorting operations.

* A) True
* B) False

### Q53. What does `min_periods=1` ensure in a rolling window calculation (`.rolling(window=7, min_periods=1).mean()`)?

* A) That the calculation requires at least 7 observations to return a result.
* B) That windows with fewer than 7 rows still return calculated results as long as at least 1 observation is present.
* C) That missing values are filled with the number 1.
* D) That the calculation is executed on a single CPU core.

### Q54. How do you extract the hour component from a datetime series named `ts`?

* A) `ts.hour`
* B) `ts.dt.hour`
* C) `ts.str.extract('hour')`
* D) `ts.dt.component('hour')`

### Q55. What is the primary benefit of using `pd.to_datetime()` during ingestion?

* A) It converts strings into optimized `datetime64[ns]` temporal arrays, enabling fast `.dt` accessors and resampling.
* B) It deletes corrupted timestamp strings.
* C) It automatically shifts timestamps to UTC timezone.
* D) It compresses file size on disk by 50%.

---

**Part 3 Answer Key:**
36. **B** | 37. **B** | 38. **B** | 39. **B** | 40. **B** | 41. **A** | 42. **B** | 43. **B** | 44. **B** | 45. **A** | 46. **B** | 47. **B** | 48. **B** | 49. **C** | 50. **B** | 51. **B** | 52. **A** | 53. **B** | 54. **B** | 55. **A**

---

## Part 4: Advanced Appendices & Production Engineering (Questions 56 – 75)

### Q56. How do you register a custom DataFrame accessor in Pandas?

* A) `@pd.register_accessor("name")`
* B) `@pd.api.extensions.register_dataframe_accessor("name")`
* C) `pd.DataFrame.extend_namespace("name", MyClass)`
* D) `pd.set_option('accessor', MyClass)`

### Q57. What is the benefit of nullable extension dtypes like `Int64` (capitalized) over standard `int64`?

* A) They allow integer columns to contain missing values (`<NA>`) without coercing the entire column into `float64`.
* B) They execute mathematical operations twice as fast as NumPy floats.
* C) They automatically encrypt numerical data for secure storage.
* D) They compress file sizes on disk by 95%.

### Q58. Which Python module is used to trace exact memory allocation spikes and line-level memory footprints?

* A) `cProfile`
* B) `tracemalloc`
* C) `asyncio`
* D) `pytest`

### Q59. What is the primary function of `cProfile` in Python?

* A) Profiling memory allocation and tracking heap object counts
* B) Profiling CPU execution time, function call frequencies, and performance bottlenecks
* C) Executing asynchronous event stream batches
* D) Validating PyArrow schema contracts

### Q60. How can you process a massive CSV file that exceeds your system RAM without throwing an Out-Of-Memory error?

* A) Load the file into a standard DataFrame using default settings.
* B) Use `pd.read_csv(file_path, chunksize=N)` to iterate through the file sequentially in memory-safe batches.
* C) Increase CPU clock speed via environment variables.
* D) Convert the CSV file into an uncompressed JSON string.

### Q61. What is the core execution mechanism of **Dask DataFrames**?

* A) Eager execution that loads all partitions into RAM simultaneously
* B) Lazy evaluation that builds task graphs, executed in parallel across multi-core CPU pools when `.compute()` is called
* C) Sequential single-thread file parsing
* D) In-browser JavaScript rendering

### Q62. Which library is standard for writing automated unit tests for data transformation logic in Python?

* A) `unittest` only
* B) `pytest`
* C) `pandas.testing` exclusively
* D) `tracemalloc`

### Q63. What is the purpose of using logging decorators around pipeline stages in production orchestration?

* A) To print colorful text to the console
* B) To automatically audit stage execution durations, log record counts, and catch/propagate stage exceptions cleanly
* C) To slow down pipeline execution for debugging
* D) To encrypt pipeline logs before writing to disk

### Q64. Which Python library enables concurrent non-blocking execution of real-time event stream batches?

* A) `multiprocessing`
* B) `asyncio`
* C) `sqlite3`
* D) `cProfile`

### Q65. How do you persist a processed Pandas DataFrame into a relational database table using SQLAlchemy with multi-row insert optimization?

* A) `df.to_sql(..., method='multi', chunksize=2000)`
* B) `df.to_csv(..., sql=True)`
* C) `df.to_database(..., fast_inserts=True)`
* D) `df.to_parquet(..., sql_sink=True)`

### Q66. What is the physical directory structure created when exporting a dataset via `df.to_parquet(..., partition_cols=['year', 'month'])`?

* A) A single monolithic binary file containing all data
* B) A nested directory tree structured as `year=YYYY/month=MM/` containing partitioned parquet files
* C) A compressed ZIP archive of CSV files
* D) An in-memory SQLite database dump

### Q67. What analytical performance benefit does partitioned Parquet storage provide?

* A) Partition pruning allows query engines to read only relevant subdirectories, skipping massive blocks of irrelevant data entirely.
* B) It eliminates the need for primary keys.
* C) It forces all queries to execute on a single CPU core.
* D) It converts categorical strings into float64 types.

### Q68. What does `pytest.approx()` assert in a unit test?

* A) That two values are exact string matches.
* B) That floating-point calculation results match expected values within an acceptable numerical tolerance threshold.
* C) That execution duration is under 1 second.
* D) That a DataFrame contains zero null values.

### Q69. What is the purpose of `asyncio.gather(*tasks)` in an asynchronous data pipeline?

* A) To execute multiple asynchronous tasks concurrently and collect their results when all complete
* B) To run tasks sequentially in a blocking loop
* C) To terminate all active thread pools immediately
* D) To serialize DataFrames into JSON strings

### Q70. True or False: Dask DataFrames share the same API design as Pandas, allowing developers to scale workflows across CPU cores with minimal code modification.

* A) True
* B) False

### Q71. What does `if_exists='replace'` accomplish in `df.to_sql()`?

* A) It appends new rows to an existing database table.
* B) It drops the target table if it already exists and creates a fresh table with the new DataFrame schema.
* C) It raises an error if the table already exists.
* D) It overwrites matching rows based on primary key IDs.

### Q72. How do you initialize a `tracemalloc` memory trace session in Python?

* A) `tracemalloc.start()`
* B) `tracemalloc.begin_trace()`
* C) `tracemalloc.enable_memory_profiler()`
* D) `tracemalloc.init()`

### Q73. What metric does `snapshot.compare_to(baseline, 'lineno')` output in `tracemalloc`?

* A) CPU execution time deltas per function
* B) Memory allocation size deltas grouped by source code line number
* C) Number of database rows inserted per second
* D) PyArrow schema validation errors

### Q74. Why is chunked file iteration (`chunksize=N`) less performant than reading a full file into RAM (when RAM permits)?

* A) Chunking disables multi-threaded parsing and incurs overhead from repeated file I/O operations and incremental accumulation.
* B) Chunking forces all integers to convert to float64.
* C) Chunking prevents the use of `.loc[]` indexing.
* D) Chunking requires DuckDB to be installed.

### Q75. What is the ultimate goal of mastering **Data Wrangling at Scale — The Definitive Pandas Guide**?

* A) Writing slow, iterative Python scripts for small hobby projects
* B) Building deterministic, high-performance, memory-optimized, and thoroughly tested data pipelines capable of handling massive datasets reliably
* C) Avoiding SQL databases entirely in favor of CSV files
* D) Eliminating the need for version control and automated unit testing

---

**Part 4 Answer Key:**
56. **B** | 57. **A** | 58. **B** | 59. **B** | 60. **B** | 61. **B** | 62. **B** | 63. **B** | 64. **B** | 65. **A** | 66. **B** | 67. **A** | 68. **B** | 69. **A** | 70. **A** | 71. **B** | 72. **A** | 73. **B** | 74. **A** | 75. **B**
