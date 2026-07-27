# Part 5: Advanced Optimization & Memory Efficiency

In this final phase, we transition from foundational NumPy usage to writing production-grade, highly optimized code built for large-scale performance.

When working with massive datasets, standard NumPy patterns can hit hidden performance walls: repeated temporary array allocations trigger garbage collection spikes, multi-gigabyte datasets exceed system RAM, and complex tensor contractions slow down when expressed using chains of basic transpositions.

In this section, we will build our final core module: `05_advanced_optimization.py`. It implements four high-performance optimization techniques:

1. **In-place operations** (`out` parameters) to eliminate memory churn.
2. **Memory-mapped files** (`np.memmap`) for out-of-core computing on datasets larger than RAM.
3. **Einstein summation** (`np.einsum`) for concise, hyper-optimized tensor contractions.
4. **Numba Just-In-Time (JIT) compilation** to run custom loops at C speed.

---

## Step 5.1: In-Place Operations & Memory Reuse (`out` Parameter)

### 1. The Target

We will construct a memory management module demonstrating how to reuse existing memory buffers via the `out` parameter available in NumPy ufuncs, preventing unnecessary memory allocation and garbage collection overhead.

### 2. The Concept

Think of memory allocation like renting a new moving box every single time you pack an item.

* **Standard Binary Operation (`c = a + b`)**: NumPy allocates a brand-new memory buffer for the array `c`, populates it with the sum, and leaves the old memory for Python's garbage collector to clean up. In a tight loop with large matrices, this creates severe memory fragmentation and slowdowns.
* **In-Place Allocation (`np.add(a, b, out=destination)`)**: You bring a pre-allocated box (`destination`) and write the results straight into it. No new memory is allocated, and zero garbage collection overhead is incurred.

### 3. The Implementation

Create the file `05_advanced_optimization.py` in your project root.

```python
# 05_advanced_optimization.py
import gc
import os
import time
from typing import Tuple
import numpy as np


def demonstrate_inplace_memory_reuse(size: int = 50_000_000) -> None:
    """Demonstrates memory allocation savings using the ufunc 'out' parameter."""
    print(f"\n================ 1. IN-PLACE OPERATIONS & 'OUT' PARAMETER ({size:,} ELEMENTS) ================")

    # Allocate initial memory blocks
    x = np.ones(size, dtype=np.float64)
    y = np.ones(size, dtype=np.float64)
    
    # Pre-allocate output buffer
    result_buffer = np.empty(size, dtype=np.float64)

    print(f"Allocated 3 buffers of {x.nbytes / (1024**2):.2f} MB each.")
    
    # Memory address of pre-allocated result buffer
    buffer_address = result_buffer.ctypes.data

    # --- Standard Arithmetic Allocation (c = x + y) ---
    start_time = time.perf_counter()
    standard_result = x + y
    standard_duration = time.perf_counter() - start_time
    
    print(f"\nStandard Expression (x + y):")
    print(f"  Execution Time : {standard_duration:.6f} seconds")
    print(f"  Allocated New Pointer? : {standard_result.ctypes.data != buffer_address}")

    # --- Optimized In-Place Allocation using 'out' parameter ---
    start_time = time.perf_counter()
    np.add(x, y, out=result_buffer)
    inplace_duration = time.perf_counter() - start_time

    print(f"\nIn-Place Ufunc (np.add(x, y, out=result_buffer)):")
    print(f"  Execution Time : {inplace_duration:.6f} seconds")
    print(f"  Reused Target Buffer Pointer? : {result_buffer.ctypes.data == buffer_address}")
    
    if inplace_duration > 0:
        speedup = standard_duration / inplace_duration
        print(f"  Performance Advantage       : {speedup:.2f}x faster / zero allocation")

    print("=========================================================================================\n")


if __name__ == "__main__":
    demonstrate_inplace_memory_reuse(size=50_000_000)

```

### 4. The Verification

Execute the module from your terminal:

```bash
python 05_advanced_optimization.py

```

**Expected Verification Output:**

```text
================ 1. IN-PLACE OPERATIONS & 'OUT' PARAMETER (50,000,000 ELEMENTS) ================
Allocated 3 buffers of 381.47 MB each.

Standard Expression (x + y):
  Execution Time : 0.045000 to 0.080000 seconds
  Allocated New Pointer? : True

In-Place Ufunc (np.add(x, y, out=result_buffer)):
  Execution Time : 0.020000 to 0.040000 seconds
  Reused Target Buffer Pointer? : True
  Performance Advantage       : 1.50x to 2.20x faster / zero allocation
=========================================================================================

```

---

## Step 5.2: Out-of-Core Processing with Memory-Mapped Files (`np.memmap`)

### 1. The Target

Append a memory-mapping routine to `05_advanced_optimization.py` using `np.memmap` to read, slice, and mutate disk-backed binary datasets without loading the full file into system RAM.

### 2. The Concept

Imagine you have a giant dictionary book with 100,000 pages, but your small desk can only hold 2 pages at a time.

* **Standard Load (`np.load`)**: Tries to dump all 100,000 pages onto your tiny desk at once, crashing your desk (Out-Of-Memory / OOM Crash).
* **Memory Mapping (`np.memmap`)**: Leaves the book on the shelf. When you ask to read page 452, your operating system virtual memory manager swaps *only* page 452 onto your desk, lets you modify it, writes it back to disk, and frees up your desk space automatically.

### 3. The Implementation

Append the memory-mapped file function to `05_advanced_optimization.py`:

```python
# Append to 05_advanced_optimization.py


def demonstrate_memory_mapped_files(filename: str = "large_dataset.dat") -> None:
    """Demonstrates out-of-core matrix operations using disk-backed memory maps."""
    print("\n================ 2. OUT-OF-CORE PROCESSING (NP.MEMMAP) ================")

    shape = (10_000, 10_000)  # 100 million float64 elements = ~800 MB on disk
    dtype = np.float64

    # 1. CREATE DISK-BACKED ARRAY: Write binary file without loading everything into RAM
    print(f"Creating a disk-backed binary matrix of shape {shape} (~800 MB)...")
    mmap_array = np.memmap(
        filename, dtype=dtype, mode="w+", shape=shape
    )

    # Populate a slice of the array on disk
    mmap_array[0, :5] = [10.5, 20.5, 30.5, 40.5, 50.5]
    
    # Flush changes to disk
    mmap_array.flush()
    print("Flushed initial writes to disk successfully.")

    # Delete reference to close file handle
    del mmap_array

    # 2. READ & SLICE DISK ARRAY: Open existing binary file in read/write mode
    # Operating system loads ONLY requested slices into RAM on demand!
    mmap_read = np.memmap(filename, dtype=dtype, mode="r+", shape=shape)

    print(f"\nReading slice from disk-backed memmap (mmap_read[0, :5]):")
    print(f"  Values: {mmap_read[0, :5]}")
    print(f"  Is array backed by memory map? : {isinstance(mmap_read, np.memmap)}")

    # Modify slice directly on disk
    mmap_read[0, 0] = 999.999
    mmap_read.flush()

    # Clean up disk file after verification
    del mmap_read
    if os.path.exists(filename):
        os.remove(filename)
        print(f"Cleaned up temporary disk file '{filename}'.")

    print("========================================================================\n")


if __name__ == "__main__":
    demonstrate_memory_mapped_files()

```

### 4. The Verification

Run the updated file:

```bash
python 05_advanced_optimization.py

```

**Expected Verification Output:**

```text
================ 2. OUT-OF-CORE PROCESSING (NP.MEMMAP) ================
Creating a disk-backed binary matrix of shape (10000, 10000) (~800 MB)...
Flushed initial writes to disk successfully.

Reading slice from disk-backed memmap (mmap_read[0, :5]):
  Values: [10.5 20.5 30.5 40.5 50.5]
  Is array backed by memory map? : True
Cleaned up temporary disk file 'large_dataset.dat'.
========================================================================

```

---

## Step 5.3: Concise Tensor Contractions with Einstein Summation (`np.einsum`)

### 1. The Target

Append Einstein summation routines to `05_advanced_optimization.py` using `np.einsum` to express matrix transpositions, trace calculations, matrix multiplications, and high-dimensional batch tensor contractions cleanly.

### 2. The Concept

In advanced numerical pipelines, combining multiple tensor operations (transposing, multiplying specific axes, and summing over others) often requires chaining functions like `np.diagonal()`, `np.sum()`, `np.transpose()`, and `np.matmul()`. This creates intermediate array copies and hard-to-read code.

`np.einsum` uses Einstein notation—a compact string notation specifying subscript indices for input and output dimensions. It executes complex tensor contractions in a single, hyper-optimized loop pass.

### 3. The Implementation

Append the `np.einsum` suite to `05_advanced_optimization.py`:

```python
# Append to 05_advanced_optimization.py


def demonstrate_einsum_operations() -> None:
    """Demonstrates hyper-optimized tensor operations using Einstein summation notation."""
    print("\n================ 3. EINSTEIN SUMMATION (NP.EINSUM) ================")

    A = np.array([[1, 2], [3, 4]], dtype=np.int32)
    B = np.array([[5, 6], [7, 8]], dtype=np.int32)

    # 1. Matrix Transpose: 'ij->ji'
    transpose_A = np.einsum("ij->ji", A)
    print(f"Matrix A:\n{A}")
    print(f"Transpose ('ij->ji'):\n{transpose_A}")

    # 2. Matrix Trace (Sum of diagonal elements): 'ii->'
    trace_A = np.einsum("ii->", A)
    print(f"\nTrace of A ('ii->'): {trace_A} (Expected: 1+4 = 5)")

    # 3. Matrix Multiplication: 'ij,jk->ik'
    # Repeated index 'j' is summed over (contracted)
    matmul_result = np.einsum("ij,jk->ik", A, B)
    print(f"\nMatrix Multiplication A @ B ('ij,jk->ik'):\n{matmul_result}")

    # 4. Batch Tensor Matrix Multiplication:
    # Batch of 2 matrices, each of shape (3, 4) multiplied by (4, 5) -> Output (2, 3, 5)
    batch_A = np.ones((2, 3, 4), dtype=np.int32)
    batch_B = np.ones((2, 4, 5), dtype=np.int32)

    # Batch index 'b' remains untouched; 'k' is contracted
    batch_result = np.einsum("bik,bkj->bij", batch_A, batch_B)
    print(f"\nBatch Tensor Multiplication Shape ('bik,bkj->bij'): {batch_result.shape}")

    print("===================================================================\n")


if __name__ == "__main__":
    demonstrate_einsum_operations()

```

### 4. The Verification

Run the updated script:

```bash
python 05_advanced_optimization.py

```

**Expected Verification Output:**

```text
================ 3. EINSTEIN SUMMATION (NP.EINSUM) ================
Matrix A:
[[1 2]
 [3 4]]
Transpose ('ij->ji'):
[[1 3]
 [2 4]]

Trace of A ('ii->'): 5 (Expected: 1+4 = 5)

Matrix Multiplication A @ B ('ij,jk->ik'):
[[19 22]
 [43 50]]

Batch Tensor Multiplication Shape ('bik,bkj->bij'): (2, 3, 5)
===================================================================

```

---

## Step 5.4: Accelerating Custom Loops with Numba JIT Compilation

### 1. The Target

Add a comparison benchmark between pure Python loops, vectorized NumPy operations, and Numba JIT (Just-In-Time) compiled C-speed functions to `05_advanced_optimization.py`.

### 2. The Concept

Vectorization works best when your operation can be expressed using existing NumPy functions. But what if you need to run a complex custom loop, such as a cellular automaton simulation or iterative distance calculation, that cannot be vectorized easily?

**Numba** solves this by using LLVM to compile pure Python `for` loops directly into native machine code at runtime. Adding the `@jit(nopython=True)` decorator transforms a slow Python loop into execution speeds matching compiled C code.

### 3. The Implementation

First, ensure `numba` is installed in your environment:

```bash
pip install numba

```

Append the Numba benchmark suite to `05_advanced_optimization.py`:

```python
# Append to 05_advanced_optimization.py
try:
    from numba import jit
    HAS_NUMBA = True
except ImportError:
    HAS_NUMBA = False


def pure_python_pairwise_distance(X: np.ndarray) -> np.ndarray:
    """Computes pairwise squared Euclidean distances using raw Python loops."""
    N, D = X.shape
    result = np.zeros((N, N), dtype=np.float64)
    for i in range(N):
        for j in range(N):
            dist = 0.0
            for k in range(D):
                diff = X[i, k] - X[j, k]
                dist += diff * diff
            result[i, j] = dist
    return result


if HAS_NUMBA:
    # Numba JIT compilation converts Python loop directly to native C machine code
    @jit(nopython=True, fastmath=True)
    def numba_pairwise_distance(X: np.ndarray) -> np.ndarray:
        """Computes pairwise squared Euclidean distances using Numba JIT acceleration."""
        N, D = X.shape
        result = np.zeros((N, N), dtype=np.float64)
        for i in range(N):
            for j in range(N):
                dist = 0.0
                for k in range(D):
                    diff = X[i, k] - X[j, k]
                    dist += diff * diff
                result[i, j] = dist
        return result


def demonstrate_numba_acceleration(N: int = 500, D: int = 10) -> None:
    """Benchmarks pure Python, NumPy vectorization, and Numba JIT execution speed."""
    print(f"\n================ 4. NUMBA JIT ACCELERATION ({N} SAMPLES, {D} FEATURES) ================")

    rng = np.random.default_rng(seed=42)
    X = rng.standard_normal((N, D))

    # 1. Pure Python Loop Execution
    start = time.perf_counter()
    res_py = pure_python_pairwise_distance(X)
    dur_py = time.perf_counter() - start
    print(f"Pure Python Loop Execution Time  : {dur_py:.6f} seconds")

    # 2. Vectorized NumPy Execution
    start = time.perf_counter()
    # (X[:, None, :] - X[None, :, :]) uses broadcasting across 3 dimensions
    res_np = np.sum((X[:, np.newaxis, :] - X[np.newaxis, :, :]) ** 2, axis=-1)
    dur_np = time.perf_counter() - start
    print(f"NumPy Vectorized Execution Time  : {dur_np:.6f} seconds")

    # 3. Numba JIT Execution
    if HAS_NUMBA:
        # Warmup compilation run
        _ = numba_pairwise_distance(X)

        start = time.perf_counter()
        res_numba = numba_pairwise_distance(X)
        dur_numba = time.perf_counter() - start
        
        print(f"Numba JIT Compiled Execution Time: {dur_numba:.6f} seconds")
        print(f"Speedup Numba vs Pure Python    : {dur_py / dur_numba:.2f}x faster")
        print(f"Results Match NumPy Vectorization? : {np.allclose(res_np, res_numba)}")
    else:
        print("Numba not installed. Run 'pip install numba' to enable JIT benchmarks.")

    print("=======================================================================================\n")


if __name__ == "__main__":
    demonstrate_numba_acceleration()

```

### 4. The Verification

Run the full optimization suite:

```bash
python 05_advanced_optimization.py

```

**Expected Verification Output:**

```text
================ 4. NUMBA JIT ACCELERATION (500 SAMPLES, 10 FEATURES) ================
Pure Python Loop Execution Time  : 1.200000 to 1.800000 seconds
NumPy Vectorized Execution Time  : 0.015000 to 0.030000 seconds
Numba JIT Compiled Execution Time: 0.001500 to 0.003000 seconds
Speedup Numba vs Pure Python    : 400.00x to 800.00x faster
Results Match NumPy Vectorization? : True
=======================================================================================

```

---

## Technical Reference: Einstein Summation (`np.einsum`) Index Syntax Cheat Sheet

`np.einsum` uses subscript letters to define dimensions. Any subscript letter that appears in the input specs but is **omitted from the output spec** is summed over (contracted).

| Mathematical Operation | Standard NumPy Syntax | Equivalent `np.einsum` Syntax | Description |
| --- | --- | --- | --- |
| **Sum All Elements** | `np.sum(A)` | `np.einsum('ij->', A)` | Omits all indices from output -> reduces to scalar. |
| **Row Sums** | `np.sum(A, axis=1)` | `np.einsum('ij->i', A)` | Retains row index `i`, sums over column index `j`. |
| **Column Sums** | `np.sum(A, axis=0)` | `np.einsum('ij->j', A)` | Retains column index `j`, sums over row index `i`. |
| **Matrix Transpose** | `A.T` | `np.einsum('ij->ji', A)` | Reverses subscript index order. |
| **Matrix Diagonal** | `np.diag(A)` | `np.einsum('ii->i', A)` | Selects matching row and column indices. |
| **Matrix Trace** | `np.trace(A)` | `np.einsum('ii->', A)` | Selects diagonal indices and sums them to scalar. |
| **Dot Product** | `np.dot(vec1, vec2)` | `np.einsum('i,i->', v1, v2)` | Multiplies matching elements and contracts `i`. |
| **Matrix Multiplication** | `A @ B` | `np.einsum('ij,jk->ik', A, B)` | Contracts shared index `j`. |
| **Batch Matrix Multiplication** | `A @ B` across batch | `np.einsum('bij,bjk->bik', A, B)` | Retains batch index `b` untouched, contracts `j`. |

---

## Series Summary & Complete Project Architecture

Congratulations! You have completed the **Mastering NumPy** series. You have progressed from basic array creation to writing production-ready, memory-mapped, and JIT-accelerated numerical software.

### What You Have Built

Here is a summary of the complete toolkit you constructed across all 5 modules:

```text
numpy_mastery_series/
├── env_check.py                 # Diagnostic environment verification script
├── 01_foundation.py             # Part 1: ndarray memory inspection, strides, & views
├── 02_reshaping_and_masking.py  # Part 2: Reshaping, zero-copy transposes, & boolean masks
├── 03_broadcasting_and_math.py  # Part 3: Universal Functions (ufuncs) & broadcasting rules
├── 04_numerical_powerhouse.py   # Part 4: Multi-axis reductions, linear algebra, & stochastic sampling
└── 05_advanced_optimization.py  # Part 5: In-place memory reuse, memmap, einsum, & Numba JIT

```

### Key Takeaways

1. **Memory Continuity Matters:** NumPy achieves its performance advantage by storing homogeneous data types in contiguous memory blocks, enabling hardware-level SIMD operations and high CPU cache hit rates.
2. **Prefer Views Over Copies:** Slicing, reshaping, and transposing manipulate metadata (strides and shapes) without duplicating memory. Boolean masking and fancy indexing require copying memory.
3. **Broadcasting Eliminates Allocations:** Mismatched tensor shapes can be operated on seamlessly by leveraging NumPy's broadcasting rules, avoiding memory expansion.
4. **Optimize for RAM Limits:** Use the `out=` parameter in ufuncs to minimize garbage collection overhead, and use `np.memmap` for out-of-core processing when handling datasets that exceed physical system RAM.
5. **Contract with Einsum & Accelerate with Numba:** Use `np.einsum` to simplify complex tensor transformations, and apply Numba JIT compilation (`@jit`) to custom Python loops to achieve native C speed.
