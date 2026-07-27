# Student Notes: Mastering High-Performance NumPy

These notes serve as a quick-reference field guide summarizing core concepts, internal memory mechanics, optimization rules, and high-performance code patterns.

---

## 1. Memory Architecture & Stride Mechanics

### The Dual-Layer Anatomy of an `ndarray`

A NumPy array consists of two primary components:

1. **Raw Data Buffer (Payload):** A contiguous or semi-contiguous block of sequential memory storing the raw bytes.
2. **Array Header (Metadata):** Light metadata object storing `shape`, `strides`, `dtype`, `itemsize`, and `flags`.

```
========================= ARRAY HEADER (Metadata) =========================
Shape    : (2, 3)
Strides  : (24, 8)   --> (Step in bytes to move 1 element along each axis)
Dtype    : float64   --> (itemsize = 8 bytes)
Data Pointer -----> [ 0x7f88a0 ]
===========================================================================
                                |
                                v
======================== RAW DATA BUFFER (In RAM) =========================
[ 0x7f88a0 ] : Element (0,0) | 8 bytes
[ 0x7f88a8 ] : Element (0,1) | 8 bytes
[ 0x7f88b0 ] : Element (0,2) | 8 bytes
[ 0x7f88b8 ] : Element (1,0) | 8 bytes
[ 0x7f88c0 ] : Element (1,1) | 8 bytes
[ 0x7f88c8 ] : Element (1,2) | 8 bytes
===========================================================================

```

### Stride Math Equation

For an array element index $(i_0, i_1, \dots, i_k)$ with strides $(S_0, S_1, \dots, S_k)$, the exact memory offset in bytes from the base pointer is computed as:

$$\text{Byte Offset} = \sum_{j=0}^{k} i_j \times S_j$$

### Views vs. Copies Rulebook

* **View (0 Bytes Allocated):** Modifies metadata (`shape`, `strides`) while sharing the underlying data buffer.
* Slicing with strides: `arr[::2, :]`
* Reshaping: `arr.reshape(...)` (when layout allows)
* Transposing: `arr.T` or `arr.transpose()`


* **Copy (Memory Allocation):** Creates a brand new data buffer in RAM.
* Fancy indexing (integer or boolean arrays): `arr[[0, 2], :]`, `arr[arr > 0]`
* Explicit copy: `arr.copy()`
* Non-contiguous reshape operations.



---

## 2. Broadcasting Rules & Memory Tricks

### Broadcasting Algorithm (Right-to-Left Matching)

When operating on two arrays, NumPy compares their shapes dimension-by-dimension **starting from the right (trailing dimensions)**:

1. Two dimensions are compatible if **they are equal**, OR **one of them is $1$**.
2. If a dimension is missing in one array, it is left-padded with $1$.
3. When a dimension has size $1$, NumPy sets its stride along that axis to **$0$ bytes**, repeating data logically without copying physical bytes in memory.

```
Array A (3D):  8  x  1  x  6
Array B (2D):        7  x  6  --> Left-padded to (1, 7, 6)
----------------------------
Result (3D):   8  x  7  x  6  (Valid Broadcasting)

```

---

## 3. High-Performance Optimization Cheat Sheet

### 1. In-Place Operations & Ufuncs

Avoid intermediate array allocations during arithmetic operations by using the `out=` parameter.

```python
import numpy as np

# BAD: Creates 2 temporary arrays in memory
result = (A * 2.0) + B

# GOOD: Zero extra memory allocation
result = np.empty_like(A)
np.multiply(A, 2.0, out=result)
np.add(result, B, out=result)

```

### 2. Contiguity Matters (C vs. Fortran Layout)

Iteration over contiguous memory blocks takes advantage of CPU L1/L2 cache prefetching and SIMD vectorization.

* **C-Contiguous (Row-Major):** Trailing index changes fastest (`axis=-1`). Fastest for row-wise operations.
* **Fortran-Contiguous (Column-Major):** Leading index changes fastest (`axis=0`). Fastest for column-wise operations.

```python
# Check contiguity flags
print(arr.flags['C_CONTIGUOUS'])
print(arr.flags['F_CONTIGUOUS'])

# Fix broken contiguity after slicing/transposing
arr_contiguous = np.ascontiguousarray(arr_non_contiguous)

```

### 3. Einstein Summation (`np.einsum`)

Combines transpose, summation, multiplication, and contraction into an expressive subscript notation:

| Operation | Standard NumPy | `np.einsum` Equivalent |
| --- | --- | --- |
| **Matrix Multiply** | `A @ B` | `np.einsum('ij,jk->ik', A, B)` |
| **Batch MatMul** | `A @ B` (3D) | `np.einsum('bij,bjk->bik', A, B)` |
| **Trace** | `np.trace(A)` | `np.einsum('ii->', A)` |
| **Column Sum** | `np.sum(A, axis=0)` | `np.einsum('ij->j', A)` |

---

## 4. Diagnostic & Profiling Reference

### Environment Diagnostic Snippet

```python
import numpy as np

# 1. Audit BLAS Backend
np.show_config()

# 2. Inspect Memory Data Pointer & Strides
print(f"Data Pointer Address: {hex(arr.ctypes.data)}")
print(f"Strides in Bytes    : {arr.strides}")
print(f"Owning Base         : {arr.base}")

```

### Memory & Execution Profiling CLI Commands

```bash
# 1. Profile Execution Time via cProfile (Sorted by Cumulative Time)
python -m cProfile -s cumulative your_script.py

# 2. Profile Line-by-Line RAM Allocations (Requires @profile decorator)
python -m memory_profiler your_script.py

```

---

> **Tip:** Keep this cheat sheet handy while working through complex numerical pipelines, spatial computations, or large data transformations!
