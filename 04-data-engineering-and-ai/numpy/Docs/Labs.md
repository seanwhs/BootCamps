# Laboratory Manual: High-Performance NumPy & Memory Engineering

Welcome to the **High-Performance NumPy Laboratory Manual**. This manual contains hands-on lab experiments, performance benchmarking exercises, and diagnostic routines.

Work through these experiments in a Linux, macOS, or Windows environment equipped with Python 3.10+ and NumPy.

---

## 🧪 Experiment 1: Memory Layout & Stride Mechanics Diagnostic

### Objective

Investigate how memory strides, transposition, and C vs. Fortran memory contiguity impact CPU cache efficiency and operational throughput.

### Setup & Code

Create a file named `lab1_strides.py`:

```python
import time
import numpy as np


def measure_traversal_speed():
    # Allocate a 10,000 x 10,000 float64 matrix (~800 MB)
    shape = (10000, 10000)
    print(f"Allocating {shape[0]}x{shape[1]} C-Contiguous matrix (~800 MB)...")
    A = np.ones(shape, dtype=np.float64)

    print(f"Shape            : {A.shape}")
    print(f"Strides (Bytes)  : {A.strides}")
    print(f"C-Contiguous     : {A.flags['C_CONTIGUOUS']}")
    print(f"Fortran-Contiguous: {A.flags['F_CONTIGUOUS']}\n")

    # Experiment A: Row-wise summation (Traversing contiguous memory)
    start = time.perf_counter()
    row_sum = A.sum(axis=1)
    row_time = time.perf_counter() - start
    print(f"[Row-wise Sum (Axis 1)]   Time: {row_time:.5f} sec")

    # Experiment B: Column-wise summation (Jumping across stride boundaries)
    start = time.perf_counter()
    col_sum = A.sum(axis=0)
    col_time = time.perf_counter() - start
    print(f"[Col-wise Sum (Axis 0)]   Time: {col_time:.5f} sec")

    slowdown = col_time / row_time
    print(f"\nResult: Column-wise sum is {slowdown:.2f}x SLOWER due to L1/L2 cache misses.")

    # Experiment C: Restoring Contiguity via np.ascontiguousarray
    print("\nRe-aligning memory layout with np.ascontiguousarray()...")
    A_F = np.asfortranarray(A)
    print(f"New Strides (Fortran) : {A_F.strides}")

    start = time.perf_counter()
    col_sum_fast = A_F.sum(axis=0)
    col_time_fast = time.perf_counter() - start
    print(f"[Col-wise Sum on Fortran Layout] Time: {col_time_fast:.5f} sec")


if __name__ == "__main__":
    measure_traversal_speed()

```

### Lab Procedure

1. Run `python lab1_strides.py`.
2. Record the row-wise vs. column-wise execution times.
3. **Analysis Question:** Why does column-wise iteration over a C-contiguous array cause cache misses?

In a C-contiguous array, consecutive elements along a row are placed adjacent to each other in physical RAM. When the CPU fetches a float64 element into the L1 cache, it loads an entire 64-byte cache line (8 contiguous floats). Row-wise iteration uses all 8 cached floats immediately (spatial locality). Column-wise iteration skips $10,000 \times 8 = 80,000$ bytes per step, discarding the rest of the cache line and forcing a main RAM fetch on every single access.

---

## 🧪 Experiment 2: Memory Footprint & In-Place Allocation Audit

### Objective

Quantify intermediate memory allocation spikes using line-by-line memory profiling, and demonstrate zero-allocation in-place arithmetic routines.

### Setup & Code

Install requirements:

```bash
pip install memory_profiler psutil

```

Create `lab2_memory.py`:

```python
from memory_profiler import profile
import numpy as np


@profile
def naive_compounding(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    # Generates multiple temporary arrays in RAM
    # Equation: res = (a * 3.5 + b ** 2) - 10.0
    t1 = a * 3.5
    t2 = b ** 2
    t3 = t1 + t2
    res = t3 - 10.0
    return res


@profile
def optimized_in_place(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    # Uses a single pre-allocated output buffer
    res = np.empty_like(a)

    # In-place evaluation
    np.multiply(a, 3.5, out=res)
    
    # Temporary buffer for b^2 evaluated directly into a second operation
    temp_b = np.empty_like(b)
    np.square(b, out=temp_b)
    
    np.add(res, temp_b, out=res)
    np.subtract(res, 10.0, out=res)
    return res


if __name__ == "__main__":
    # 20,000,000 float64 elements = ~160 MB per array
    N = 20_000_000
    print(f"Initializing 2 input arrays ({N * 8 / 1e6:.1f} MB each)...")
    x = np.ones(N, dtype=np.float64)
    y = np.ones(N, dtype=np.float64) * 2.0

    print("\n--- Profiling Naive Arithmetic ---")
    res_naive = naive_compounding(x, y)

    print("\n--- Profiling In-Place Arithmetic ---")
    res_opt = optimized_in_place(x, y)

    assert np.allclose(res_naive, res_opt)
    print("\nValidation: Results are identical.")

```

### Lab Procedure

1. Run `python -m memory_profiler lab2_memory.py`.
2. Inspect the **Increment** column in the profiler output.
3. Compare total peak memory allocated during `naive_compounding` vs. `optimized_in_place`.

---

## 🧪 Experiment 3: High-Dimensional Einstein Summation vs. Standard BLAS

### Objective

Profile execution speed and code clarity when computing tensor contractions using `np.einsum` vs. standard transpose and reshape matrix multiplications.

### Setup & Code

Create `lab3_einsum.py`:

```python
import time
import numpy as np


def benchmark_tensor_contractions():
    # Batch of 64 images/features, each 100x100
    B, M, N, P = 64, 100, 100, 100
    A = np.random.randn(B, M, N)
    B_mat = np.random.randn(B, N, P)

    print(f"Benchmarking Batched Tensor Multiplication: ({B}, {M}, {N}) x ({B}, {N}, {P})")

    # Method 1: Python Loop over Batch Dimension
    start = time.perf_counter()
    res_loop = np.empty((B, M, P))
    for i in range(B):
        res_loop[i] = A[i] @ B_mat[i]
    t_loop = time.perf_counter() - start
    print(f"1. Explicit Python Loop + MatMul (@) : {t_loop:.5f} sec")

    # Method 2: Einstein Summation Notation
    start = time.perf_counter()
    res_einsum = np.einsum("bij,bjk->bik", A, B_mat)
    t_einsum = time.perf_counter() - start
    print(f"2. Einstein Summation (np.einsum)    : {t_einsum:.5f} sec")

    # Method 3: Optimized Einsum (BLAS path search)
    start = time.perf_counter()
    res_einsum_opt = np.einsum("bij,bjk->bik", A, B_mat, optimize="optimal")
    t_einsum_opt = time.perf_counter() - start
    print(f"3. Optimized Einsum (optimize='optimal'): {t_einsum_opt:.5f} sec")

    assert np.allclose(res_loop, res_einsum)
    assert np.allclose(res_loop, res_einsum_opt)
    print("\nValidation: All tensor outputs match perfectly.")


if __name__ == "__main__":
    benchmark_tensor_contractions()

```

### Lab Procedure

1. Run `python lab3_einsum.py`.
2. Compare the execution times across all three methods.
3. Observe how `optimize="optimal"` rewrites tensor contraction paths to leverage underlying Level 3 BLAS GEMM calls.

---

## 🧪 Experiment 4: Out-of-Core Processing with Binary Memory Maps

### Objective

Simulate a production scenario where a 1 GB dataset exceeds physical RAM constraints, and process it in chunks using `np.memmap`.

### Setup & Code

Create `lab4_out_of_core.py`:

```python
import os
import time
import numpy as np


def run_out_of_core_lab():
    filename = "lab_large_file.dat"
    # 12,500,000 rows x 10 columns float64 = 1,000,000,000 bytes (~1 GB)
    n_rows, n_cols = 12_500_000, 10
    file_bytes = n_rows * n_cols * 8
    print(f"Target dataset size: {file_bytes / (1024**3):.2f} GB on disk.")

    # Step 1: Create Memory-Mapped File on Disk
    print("\nCreating on-disk binary storage...")
    start = time.perf_counter()
    mmap_writer = np.memmap(filename, dtype=np.float64, mode="w+", shape=(n_rows, n_cols))

    # Populate data in 1,000,000-row chunks
    chunk_size = 1_000_000
    rng = np.random.default_rng(12345)
    for i in range(0, n_rows, chunk_size):
        end = min(i + chunk_size, n_rows)
        mmap_writer[i:end] = rng.standard_normal((end - i, n_cols))

    mmap_writer.flush()
    del mmap_writer  # Close writer handle
    print(f"Disk file populated in {time.perf_counter() - start:.2f} seconds.")

    # Step 2: Out-of-Core Processing (Read-Only Memory Map)
    print("\nProcessing 1 GB dataset in 100,000-row chunks...")
    mmap_reader = np.memmap(filename, dtype=np.float64, mode="r", shape=(n_rows, n_cols))

    running_sum = np.zeros(n_cols, dtype=np.float64)
    read_chunk_size = 100_000

    start = time.perf_counter()
    for i in range(0, n_rows, read_chunk_size):
        chunk = mmap_reader[i : i + read_chunk_size]
        running_sum += chunk.sum(axis=0)

    column_means = running_sum / n_rows
    proc_time = time.perf_counter() - start

    print(f"Processing Complete in {proc_time:.2f} seconds!")
    print(f"Computed Column Means:\n{np.round(column_means, 5)}")

    # Cleanup
    del mmap_reader
    if os.path.exists(filename):
        os.remove(filename)
        print("\nTemporary memory-mapped file cleaned up successfully.")


if __name__ == "__main__":
    run_out_of_core_lab()

```

### Lab Procedure

1. Run `python lab4_out_of_core.py`.
2. Monitor system RAM usage in Task Manager / Activity Monitor / `htop` during execution.
3. Verify that RAM consumption stays flat (under 50 MB) while computing statistics across 1 GB of data on disk.

---

## 📊 Summary of Diagnostic Metrics

| Experiment | Focus Area | Key Diagnostic Indicator | Target Optimization |
| --- | --- | --- | --- |
| **Lab 1** | Memory Strides | Axis Traversal Throughput | Maintain contiguous cache line access (`C_CONTIGUOUS`) |
| **Lab 2** | Memory Profiling | RAM Increment (MiB) | Zero intermediate array buffers using `out=` |
| **Lab 3** | Tensor Contractions | Execution Time (Sec) | Express multi-axis contractions via `np.einsum` |
| **Lab 4** | Out-of-Core Data | Peak System RAM | Process streaming disk files using `np.memmap` chunks |
