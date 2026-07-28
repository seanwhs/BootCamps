# Appendix E: Performance Optimization for Large Datasets

## Handling Big Data Efficiently with Python

---

#### Purpose of This Appendix

As you work with larger datasets, performance becomes critical. Operations that run instantly on 5,000 rows might take minutes or crash entirely on 5 million rows. This appendix equips you with practical strategies to:

- Process and analyze large datasets efficiently
- Optimize pandas operations for speed and memory
- Use out-of-core processing for data that doesn't fit in memory
- Accelerate computations with vectorization and parallel processing
- Implement efficient data storage and retrieval

---

## E.1 Understanding the Performance Bottlenecks

### E.1.1 Common Performance Issues

| Issue | Cause | Impact |
|-------|-------|--------|
| **Memory overload** | Loading entire dataset into RAM | Crashes, swapping |
| **Slow iterations** | Using Python loops instead of vectorization | 10-100x slower |
| **Inefficient joins** | Unindexed merges | O(n²) complexity |
| **Duplicate computations** | Recalculating the same thing repeatedly | Wasted CPU time |
| **Large intermediate objects** | Creating copies instead of views | Memory bloat |
| **Inefficient data types** | Using objects instead of categorical | 10x memory usage |

### E.1.2 Profiling Your Code

```python
import time
import memory_profiler
import cProfile
import pstats

def profile_function(func):
    """Decorator to profile function performance."""
    def wrapper(*args, **kwargs):
        # Time profiling
        start_time = time.time()
        
        # Memory profiling
        memory_before = memory_profiler.memory_usage()[0]
        
        result = func(*args, **kwargs)
        
        memory_after = memory_profiler.memory_usage()[0]
        elapsed_time = time.time() - start_time
        
        print(f"\n📊 Performance Report for {func.__name__}:")
        print(f"  Time: {elapsed_time:.2f} seconds")
        print(f"  Memory: {memory_after - memory_before:.2f} MB")
        print(f"  Peak Memory: {max(memory_after, memory_before):.2f} MB")
        
        return result
    return wrapper

# Usage
@profile_function
def expensive_operation():
    df = pd.read_csv('large_dataset.csv')
    result = df.groupby('category').agg('sum')
    return result

# Profiling with cProfile
def run_profiler():
    profiler = cProfile.Profile()
    profiler.enable()
    
    # Run your function
    result = expensive_operation()
    
    profiler.disable()
    
    # Save stats
    stats = pstats.Stats(profiler)
    stats.sort_stats('cumtime')
    stats.print_stats(10)  # Top 10 slowest functions

# Memory profiling line by line
# Run: mprof run script.py
# Then: mprof plot
```

---

## E.2 Optimizing Pandas Performance

### E.2.1 Efficient Data Loading

```python
import pandas as pd
import numpy as np

def load_data_optimized(filepath, **kwargs):
    """
    Load data with optimized parameters.
    """
    # Specify dtypes to save memory
    dtypes = {
        'customer_id': 'category',
        'age': 'uint8',  # 0-255 fits in 1 byte
        'gender': 'category',
        'income_bracket': 'category',
        'country': 'category',
        'region': 'category',
        'city_tier': 'uint8',
        'time_on_site': 'float32',  # Less precision, half memory
        'pages_viewed': 'uint16',   # 0-65535
        'email_open_rate': 'float32',
        'order_frequency': 'float32',
        'avg_order_value': 'float32',
        'favorite_category': 'category',
        'customer_rating': 'float32',
        'return_rate': 'float32'
    }
    
    # Load only necessary columns
    usecols = kwargs.get('usecols', list(dtypes.keys()))
    
    # Chunk large files
    if kwargs.get('chunksize'):
        chunks = pd.read_csv(
            filepath,
            dtype=dtypes,
            usecols=usecols,
            chunksize=kwargs['chunksize'],
            low_memory=False  # Avoid mixed type inference
        )
        return pd.concat(chunks, ignore_index=True)
    
    # Single load with optimizations
    df = pd.read_csv(
        filepath,
        dtype=dtypes,
        usecols=usecols,
        low_memory=False
    )
    
    print(f"✅ Loaded {len(df):,} rows, {len(df.columns)} columns")
    print(f"Memory usage: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    
    return df

# Usage
df = load_data_optimized('large_dataset.csv', chunksize=100000)
```

### E.2.2 Memory-Optimized Data Types

```python
def optimize_dtypes(df):
    """
    Optimize DataFrame dtypes for minimal memory usage.
    """
    df_optimized = df.copy()
    
    for col in df_optimized.columns:
        col_type = df_optimized[col].dtype
        
        # Skip object columns (strings)
        if col_type == 'object':
            # Check if can be categorical
            if df_optimized[col].nunique() / len(df_optimized) < 0.5:
                df_optimized[col] = df_optimized[col].astype('category')
            continue
        
        # Integer optimization
        if 'int' in str(col_type):
            c_min = df_optimized[col].min()
            c_max = df_optimized[col].max()
            
            if c_min >= 0:
                if c_max <= 255:
                    df_optimized[col] = df_optimized[col].astype('uint8')
                elif c_max <= 65535:
                    df_optimized[col] = df_optimized[col].astype('uint16')
                elif c_max <= 4294967295:
                    df_optimized[col] = df_optimized[col].astype('uint32')
            else:
                if c_min >= -128 and c_max <= 127:
                    df_optimized[col] = df_optimized[col].astype('int8')
                elif c_min >= -32768 and c_max <= 32767:
                    df_optimized[col] = df_optimized[col].astype('int16')
                elif c_min >= -2147483648 and c_max <= 2147483647:
                    df_optimized[col] = df_optimized[col].astype('int32')
        
        # Float optimization
        elif 'float' in str(col_type):
            df_optimized[col] = df_optimized[col].astype('float32')
    
    # Memory usage comparison
    original_memory = df.memory_usage(deep=True).sum() / 1024**2
    optimized_memory = df_optimized.memory_usage(deep=True).sum() / 1024**2
    
    print(f"Memory: {original_memory:.2f} MB → {optimized_memory:.2f} MB")
    print(f"Reduction: {(1 - optimized_memory/original_memory) * 100:.1f}%")
    
    return df_optimized

# Usage
df_optimized = optimize_dtypes(df)
```

### E.2.3 Vectorization vs. Loops

```python
# ❌ BAD: Python loops (slow)
def calculate_with_loop(df):
    result = []
    for i, row in df.iterrows():
        if row['age'] > 30 and row['order_frequency'] > 1:
            result.append(row['avg_order_value'] * 1.1)
        else:
            result.append(row['avg_order_value'])
    return result

# ✅ GOOD: Vectorization (fast)
def calculate_with_vectorization(df):
    return np.where(
        (df['age'] > 30) & (df['order_frequency'] > 1),
        df['avg_order_value'] * 1.1,
        df['avg_order_value']
    )

# ✅ BETTER: Using loc for conditional updates
def calculate_with_loc(df):
    df_result = df.copy()
    mask = (df['age'] > 30) & (df['order_frequency'] > 1)
    df_result.loc[mask, 'avg_order_value'] *= 1.1
    return df_result['avg_order_value']

# Performance comparison
def compare_performance(df):
    import time
    
    # Loop method
    start = time.time()
    result1 = calculate_with_loop(df)
    time1 = time.time() - start
    
    # Vectorization
    start = time.time()
    result2 = calculate_with_vectorization(df)
    time2 = time.time() - start
    
    # loc method
    start = time.time()
    result3 = calculate_with_loc(df)
    time3 = time.time() - start
    
    print(f"Loop: {time1:.4f}s")
    print(f"Vectorization: {time2:.4f}s ({(time1/time2):.0f}x faster)")
    print(f"loc: {time3:.4f}s ({(time1/time3):.0f}x faster)")
```

### E.2.4 Efficient GroupBy Operations

```python
# ❌ BAD: Multiple groupby operations
def multiple_groupby(df):
    result1 = df.groupby('category')['value'].sum()
    result2 = df.groupby('category')['value'].mean()
    result3 = df.groupby('category')['value'].std()
    return pd.DataFrame({
        'sum': result1,
        'mean': result2,
        'std': result3
    })

# ✅ GOOD: Single groupby with multiple aggregations
def single_groupby(df):
    return df.groupby('category')['value'].agg(['sum', 'mean', 'std'])

# ✅ BETTER: Using dict for different columns
def multiple_columns_groupby(df):
    return df.groupby('category').agg({
        'value1': ['sum', 'mean'],
        'value2': ['min', 'max'],
        'value3': 'std'
    })

# ✅ BEST: Using named aggregations (pandas 0.25+)
def named_aggregations(df):
    return df.groupby('category').agg(
        total_value=('value1', 'sum'),
        avg_value=('value1', 'mean'),
        max_value=('value2', 'max'),
        std_value=('value3', 'std')
    )
```

### E.2.5 Efficient Merges and Joins

```python
def efficient_merges(df1, df2):
    """
    Tips for efficient merges.
    """
    
    # 1. Set index before merging
    df1_indexed = df1.set_index('key')
    df2_indexed = df2.set_index('key')
    result1 = df1_indexed.join(df2_indexed)
    
    # 2. Use categorical for join keys
    df1['key'] = df1['key'].astype('category')
    df2['key'] = df2['key'].astype('category')
    result2 = pd.merge(df1, df2, on='key')
    
    # 3. Filter before merging (reduce size)
    df1_filtered = df1[df1['value'] > threshold]
    result3 = pd.merge(df1_filtered, df2, on='key')
    
    # 4. Use appropriate join type
    # - inner: only matching keys (fastest)
    # - left: all keys from left (slower)
    # - outer: all keys from both (slowest)
    
    return result1, result2, result3
```

---

## E.3 Out-of-Core Processing

### E.3.1 Chunked Processing with Pandas

```python
def process_large_file_chunked(filepath, chunk_size=100000):
    """
    Process a large file in chunks.
    """
    results = []
    
    # Read in chunks
    for chunk in pd.read_csv(filepath, chunksize=chunk_size):
        # Process each chunk
        chunk_processed = process_chunk(chunk)
        results.append(chunk_processed)
    
    # Combine results
    return pd.concat(results, ignore_index=True)

def process_chunk(chunk):
    """
    Process a single chunk of data.
    """
    # Example: Calculate statistics per group
    return chunk.groupby('category').agg({
        'value': ['sum', 'mean', 'count']
    })

# With progress bar
from tqdm import tqdm

def process_with_progress(filepath, chunk_size=100000):
    """
    Process with progress bar.
    """
    # Get total rows (fast)
    total_rows = sum(1 for _ in open(filepath)) - 1  # minus header
    
    results = []
    pbar = tqdm(total=total_rows, desc="Processing")
    
    for chunk in pd.read_csv(filepath, chunksize=chunk_size):
        processed = process_chunk(chunk)
        results.append(processed)
        pbar.update(len(chunk))
    
    pbar.close()
    return pd.concat(results, ignore_index=True)
```

### E.3.2 Using Dask for Parallel Processing

```python
import dask.dataframe as dd

def process_with_dask(filepath):
    """
    Process large files with Dask (distributed).
    """
    # Load as Dask DataFrame
    df = dd.read_csv(filepath)
    
    # Operations are lazy (not executed yet)
    result = df.groupby('category')['value'].mean().compute()
    
    # For large computations
    result = df.groupby('category').agg({
        'value1': 'sum',
        'value2': 'mean',
        'value3': 'std'
    }).compute()
    
    return result

# Using Dask with custom functions
def complex_dask_operation(filepath):
    df = dd.read_csv(filepath)
    
    # Define custom aggregation
    def custom_agg(group):
        return pd.Series({
            'total': group['value'].sum(),
            'avg': group['value'].mean(),
            'count': len(group)
        })
    
    result = df.groupby('category').apply(
        custom_agg, 
        meta={'total': 'float64', 'avg': 'float64', 'count': 'int64'}
    ).compute()
    
    return result

# Dask with multiple workers
from dask.distributed import Client

def dask_with_cluster(filepath):
    # Start local cluster
    client = Client(n_workers=4, threads_per_worker=2)
    
    df = dd.read_csv(filepath)
    result = df.groupby('category')['value'].mean().compute()
    
    client.close()
    return result
```

### E.3.3 Using Vaex for Large Datasets

```python
import vaex

def process_with_vaex(filepath):
    """
    Process large files with Vaex (out-of-core, fast).
    """
    # Load as Vaex DataFrame (lazy, no memory)
    df = vaex.from_csv(filepath)
    
    # Operations are lazy
    result = df.groupby(df.category, agg={'mean_value': vaex.agg.mean('value')})
    
    # Execute and convert to pandas
    result_pandas = result.to_pandas_df()
    
    # Virtual columns (no memory)
    df['log_value'] = np.log(df['value'])
    df['value_ratio'] = df['value1'] / df['value2']
    
    # Fast filtering
    filtered = df[df.value > 100]
    
    return result_pandas
```

---

## E.4 Efficient Data Storage

### E.4.1 Comparing File Formats

```python
import pandas as pd
import numpy as np
from pathlib import Path
import time

def compare_storage_formats(df):
    """
    Compare different storage formats.
    """
    formats = {
        'csv': {'ext': '.csv', 'method': 'to_csv'},
        'parquet': {'ext': '.parquet', 'method': 'to_parquet'},
        'feather': {'ext': '.feather', 'method': 'to_feather'},
        'hdf5': {'ext': '.h5', 'method': 'to_hdf'},
        'pickle': {'ext': '.pkl', 'method': 'to_pickle'}
    }
    
    results = []
    
    for name, config in formats.items():
        filename = f'test_data{config["ext"]}'
        
        # Write
        start = time.time()
        if name == 'hdf5':
            getattr(df, config['method'])(filename, key='data')
        else:
            getattr(df, config['method'])(filename)
        write_time = time.time() - start
        
        # Read
        start = time.time()
        if name == 'hdf5':
            df_read = pd.read_hdf(filename, 'data')
        elif name == 'csv':
            df_read = pd.read_csv(filename)
        else:
            read_func = getattr(pd, f'read_{name}')
            df_read = read_func(filename)
        read_time = time.time() - start
        
        # Size
        size = Path(filename).stat().st_size / 1024**2
        
        results.append({
            'Format': name,
            'Write Time (s)': write_time,
            'Read Time (s)': read_time,
            'Size (MB)': size
        })
        
        # Clean up
        Path(filename).unlink()
    
    return pd.DataFrame(results)

# Usage
df = pd.DataFrame({
    'col1': np.random.randint(0, 100, 1000000),
    'col2': np.random.randn(1000000),
    'col3': np.random.choice(['A', 'B', 'C'], 1000000)
})
comparison = compare_storage_formats(df)
print(comparison)
```

### E.4.2 Recommended File Formats

| Format | Use Case | Pros | Cons |
|--------|----------|------|------|
| **Parquet** | Large datasets, production | Compressed, fast, schema-aware | Slower writes |
| **Feather** | Intermediate storage | Very fast I/O | Limited compression |
| **HDF5** | Complex data structures | Hierarchical, flexible | Complex API |
| **CSV** | Interoperability, small data | Universal | Slow, no types |
| **Pickle** | Quick local saving | Fast, preserves objects | Python-only, security risk |

---

## E.5 Parallel Processing

### E.5.1 Using joblib

```python
from joblib import Parallel, delayed
import multiprocessing

def parallel_apply(df, func, n_jobs=-1):
    """
    Apply function in parallel.
    """
    # Split DataFrame into chunks
    n_jobs = n_jobs if n_jobs > 0 else multiprocessing.cpu_count()
    chunks = np.array_split(df, n_jobs)
    
    # Process chunks in parallel
    results = Parallel(n_jobs=n_jobs)(
        delayed(func)(chunk) for chunk in chunks
    )
    
    # Combine results
    return pd.concat(results, ignore_index=True)

# Example usage
def process_chunk(chunk):
    return chunk.groupby('category')['value'].sum()

df_result = parallel_apply(df, process_chunk)
```

### E.5.2 Using Multiprocessing

```python
from multiprocessing import Pool, cpu_count
import multiprocessing as mp

def process_chunk(args):
    """Process a chunk of data."""
    chunk, threshold = args
    return chunk[chunk['value'] > threshold]

def parallel_processing(df, threshold, n_cores=None):
    """
    Process DataFrame in parallel.
    """
    if n_cores is None:
        n_cores = cpu_count()
    
    # Split into chunks
    chunks = np.array_split(df, n_cores)
    
    # Prepare arguments
    args = [(chunk, threshold) for chunk in chunks]
    
    # Process in parallel
    with Pool(n_cores) as pool:
        results = pool.map(process_chunk, args)
    
    # Combine results
    return pd.concat(results, ignore_index=True)

# Shared memory for large data
def shared_memory_processing(df, threshold):
    """Use shared memory to avoid copying."""
    # Create shared array
    shape = df.shape
    dtype = df.dtypes.to_dict()
    
    # Process using shared memory
    # ... (see official Python docs for full implementation)
    
    return result
```

### E.5.3 Using Modin for Automatic Parallelization

```python
# Install: pip install modin[ray]

import modin.pandas as mpd

def process_with_modin():
    """
    Use Modin for automatic parallelization.
    """
    # Same API as pandas, but parallel
    df = mpd.read_csv('large_dataset.csv')
    
    # Operations are automatically parallelized
    result = df.groupby('category')['value'].sum()
    
    # Convert back to pandas if needed
    result_pandas = result.to_pandas()
    
    return result_pandas

# Modin with Ray backend
import ray
ray.init()
df = mpd.read_csv('large_dataset.csv')
```

---

## E.6 SQL for Data Processing

### E.6.1 Using SQLite for Large Data

```python
import sqlite3
import pandas as pd

def process_with_sqlite(filepath):
    """
    Use SQLite for data processing (good for >1GB).
    """
    # Connect to database (in-memory for speed)
    conn = sqlite3.connect(':memory:')
    
    # Load data into SQLite
    df = pd.read_csv(filepath)
    df.to_sql('customers', conn, if_exists='replace', index=False)
    
    # Perform SQL queries
    query = """
    SELECT 
        income_bracket,
        AVG(avg_order_value) as avg_order,
        COUNT(*) as count,
        SUM(avg_order_value) as total_value
    FROM customers
    WHERE age > 25
    GROUP BY income_bracket
    HAVING count > 100
    ORDER BY total_value DESC
    """
    
    result = pd.read_sql_query(query, conn)
    conn.close()
    
    return result

# Indexing for faster queries
def indexed_sqlite(filepath):
    conn = sqlite3.connect('customer_data.db')
    
    df = pd.read_csv(filepath)
    df.to_sql('customers', conn, if_exists='replace', index=False)
    
    # Create indices
    conn.execute('CREATE INDEX idx_income ON customers(income_bracket)')
    conn.execute('CREATE INDEX idx_age ON customers(age)')
    conn.execute('CREATE INDEX idx_category ON customers(favorite_category)')
    
    # Faster queries
    query = """
    SELECT * FROM customers 
    WHERE income_bracket = '>$100K' 
    AND age BETWEEN 30 AND 50
    """
    
    result = pd.read_sql_query(query, conn)
    conn.close()
    
    return result
```

### E.6.2 Using DuckDB (Fast Analytics)

```python
# Install: pip install duckdb

import duckdb

def process_with_duckdb(filepath):
    """
    Use DuckDB for fast analytical queries.
    """
    # Connect to DuckDB
    conn = duckdb.connect(':memory:')
    
    # Query CSV directly (no loading needed)
    result = conn.execute("""
        SELECT 
            income_bracket,
            AVG(avg_order_value) as avg_order,
            COUNT(*) as count,
            STDDEV(avg_order_value) as std_order
        FROM read_csv_auto('large_dataset.csv')
        WHERE age > 25
        GROUP BY income_bracket
        HAVING count > 100
        ORDER BY avg_order DESC
    """).df()
    
    conn.close()
    return result

# Complex analysis with DuckDB
def complex_duckdb_analysis(filepath):
    conn = duckdb.connect(':memory:')
    
    # Register DataFrame if already loaded
    df = pd.read_csv(filepath)
    conn.register('customers', df)
    
    # Window functions
    result = conn.execute("""
        WITH ranked AS (
            SELECT 
                *,
                ROW_NUMBER() OVER (PARTITION BY income_bracket ORDER BY avg_order_value DESC) as rank
            FROM customers
        )
        SELECT *
        FROM ranked
        WHERE rank <= 10
    """).df()
    
    conn.close()
    return result
```

---

## E.7 Memory Profiling and Optimization

### E.7.1 Memory Profiling

```python
def memory_usage_report(df):
    """
    Generate detailed memory usage report.
    """
    memory_usage = df.memory_usage(deep=True)
    
    report = pd.DataFrame({
        'Column': memory_usage.index,
        'Memory (MB)': memory_usage.values / 1024**2,
        'Dtype': df.dtypes.values,
        'Nulls': df.isnull().sum().values,
        'Unique': df.nunique().values
    })
    
    report = report.sort_values('Memory (MB)', ascending=False)
    report['Memory %'] = (report['Memory (MB)'] / report['Memory (MB)'].sum()) * 100
    
    total_memory = report['Memory (MB)'].sum()
    
    print(f"\n📊 Memory Report:")
    print(f"Total: {total_memory:.2f} MB")
    print(f"\nTop 5 memory consumers:")
    print(report.head(5).to_string())
    
    return report

# Track memory usage over time
def track_memory_usage():
    import psutil
    import os
    
    process = psutil.Process(os.getpid())
    memory_before = process.memory_info().rss / 1024**2
    
    # Your code here
    df = pd.read_csv('large_dataset.csv')
    result = df.groupby('category')['value'].sum()
    
    memory_after = process.memory_info().rss / 1024**2
    
    print(f"Memory before: {memory_before:.2f} MB")
    print(f"Memory after: {memory_after:.2f} MB")
    print(f"Difference: {memory_after - memory_before:.2f} MB")
```

### E.7.2 Memory-Saving Techniques

```python
def memory_saving_techniques():
    """
    Collection of memory-saving techniques.
    """
    
    # 1. Use smaller dtypes
    df['age'] = df['age'].astype('uint8')
    df['order_frequency'] = df['order_frequency'].astype('float32')
    
    # 2. Use categorical for text
    df['country'] = df['country'].astype('category')
    df['income_bracket'] = df['income_bracket'].astype('category')
    
    # 3. Use SparseDataFrame for sparse data
    from pandas.arrays import SparseArray
    df['sparse_col'] = SparseArray(df['value'], fill_value=0)
    
    # 4. Delete intermediate objects
    result = df.groupby('category')['value'].sum()
    del df  # Free memory
    
    # 5. Use inplace operations
    df['value'] = df['value'] * 2  # Creates new Series
    df['value'] *= 2               # In-place (more memory efficient)
    
    # 6. Use chunking for processing
    for chunk in pd.read_csv('large.csv', chunksize=100000):
        process(chunk)
    
    # 7. Use generator expressions
    total = sum(x for x in df['values'])  # Memory efficient
    total = df['values'].sum()            # Faster but uses more memory
```

---

## E.8 Performance Checklist

**Before Writing Code:**
- [ ] Understand the data size and structure
- [ ] Plan memory usage strategy
- [ ] Choose appropriate data types
- [ ] Consider out-of-core processing if needed

**During Development:**
- [ ] Use vectorized operations instead of loops
- [ ] Avoid copying DataFrames unnecessarily
- [ ] Use appropriate join/merge strategies
- [ ] Filter data early in the pipeline
- [ ] Use efficient file formats (Parquet, Feather)

**For Large Datasets:**
- [ ] Consider Dask for distributed processing
- [ ] Use SQL/DuckDB for complex queries
- [ ] Implement chunked processing
- [ ] Use parallel processing where possible
- [ ] Profile memory usage regularly

**Testing:**
- [ ] Test with subset of data during development
- [ ] Profile with cProfile to find bottlenecks
- [ ] Monitor memory usage
- [ ] Validate results against small dataset

---

## E.9 Quick Reference: Performance Commands

```python
# Memory optimization
df = pd.read_csv('file.csv', dtype={'col': 'category'})
df = df.memory_usage(deep=True).sum()  # Check memory
df = df.astype({'col': 'float32'})

# Chunked processing
for chunk in pd.read_csv('file.csv', chunksize=100000):
    process(chunk)

# Dask
import dask.dataframe as dd
df = dd.read_csv('file.csv')
result = df.groupby('col').sum().compute()

# Parallel processing
from joblib import Parallel, delayed
results = Parallel(n_jobs=-1)(delayed(func)(chunk) for chunk in chunks)

# Efficient merges
df1 = df1.set_index('key')
df2 = df2.set_index('key')
result = df1.join(df2)

# Drop intermediate objects
del df_temp
import gc; gc.collect()

# Vectorization
df['new'] = np.where(df['condition'], df['true'], df['false'])

# SQL processing
conn = sqlite3.connect(':memory:')
df.to_sql('data', conn, index=False)
result = pd.read_sql_query("SELECT * FROM data WHERE col > 100", conn)
```

---

## E.10 Key Takeaways

1. **Always profile first** - Know where your bottlenecks are
2. **Vectorize everything** - Avoid Python loops
3. **Choose efficient dtypes** - Save memory and speed
4. **Process in chunks** - Don't load everything at once
5. **Use appropriate tools** - Dask, SQL, or pandas based on data size
6. **Monitor memory** - Prevent out-of-memory crashes
7. **Test with small data** - Develop on subsets, scale up gradually

This appendix provides a comprehensive guide to handling large datasets efficiently. The techniques here will help you scale your analysis from thousands to millions of records without running into performance issues.
