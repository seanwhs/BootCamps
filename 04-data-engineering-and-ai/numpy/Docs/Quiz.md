# High-Performance NumPy & Memory Engineering: Quiz & Test Bank

This test bank contains 15 technical questions divided into three difficulty tiers, complete with complete code explanations, diagnostic breakdowns, and official answer keys.

---

## Section 1: Beginner to Intermediate Mechanics

### Question 1

**Topic:** Array Slicing vs. Fancy Indexing

Consider the following Python code snippet:

```python
import numpy as np

A = np.arange(12).reshape(3, 4)
slice_view = A[0:2, 0:2]
fancy_copy = A[[0, 1], [0, 1]]

slice_view[0, 0] = 99
fancy_copy[1, 1] = 888

```

What are the values of `A[0, 0]` and `A[1, 1]` after executing this code?

* A) `A[0, 0] == 0` and `A[1, 1] == 5`
* B) `A[0, 0] == 99` and `A[1, 1] == 5`
* C) `A[0, 0] == 99` and `A[1, 1] == 888`
* D) `A[0, 0] == 0` and `A[1, 1] == 888`

---

### Question 2

**Topic:** Strides & Memory Layout

An array `X` is instantiated with shape `(4, 5, 6)` using `dtype=np.float64` (8 bytes per element) in standard C-contiguous order. What are the memory `strides` of `X` in bytes?

* A) `(240, 48, 8)`
* B) `(8, 48, 240)`
* C) `(30, 6, 1)`
* D) `(1920, 384, 64)`

---

### Question 3

**Topic:** Broadcasting Rules

Which of the following array shape pairs will **FAIL** to broadcast together without raising a `ValueError`?

* A) `(3, 1, 5)` and `(4, 5)`
* B) `(8, 1, 6, 1)` and `(7, 1, 5)`
* C) `(5, 4)` and `(4,)`
* D) `(2, 3, 4)` and `(2, 3)`

---

### Question 4

**Topic:** Data Types & Upcasting

What is the resulting `dtype` of evaluating `np.array([1, 2, 3], dtype=np.int32) + np.array([1.0, 2.0, 3.0], dtype=np.float32)`?

* A) `np.int32`
* B) `np.float32`
* C) `np.float64`
* D) `np.int64`

---

### Question 5

**Topic:** Universal Functions (Ufuncs)

To compute the sum of all elements in an array `arr` in-place into an existing scalar variable or array without allocating new heap memory, which parameter/pattern is required?

* A) `arr.sum(inplace=True)`
* B) `np.sum(arr, out=buffer)`
* C) `np.add.reduce(arr, memory='in_place')`
* D) `arr.sum(copy=False)`

---

## Section 2: Advanced Memory Architecture & Performance

### Question 6

**Topic:** Cache Locality & Memory Traversal

You have a C-contiguous array `A` of shape `(10000, 10000)` and `dtype=float64`. Operation 1 computes `A.sum(axis=1)`, while Operation 2 computes `A.sum(axis=0)`. Which statement accurately describes their relative performance?

* A) Operation 2 is significantly faster because axis 0 represents rows in memory.
* B) Operation 1 is significantly faster because it traverses contiguous memory along rows, maximizing CPU L1 cache line hits.
* C) Both operations run at identical speeds because NumPy automatically parallelizes all reduction operations across CPU threads.
* D) Operation 2 is faster because Fortran ordering is the native default for array reductions.

---

### Question 7

**Topic:** Transposition & Contiguity Flags

Executing `B = A.T` on a 2D C-contiguous array `A`:

* A) Reallocates memory and swaps the rows and columns physically in RAM.
* B) Leaves `strides` unchanged but reverses the `shape` tuple.
* C) Reverses the `strides` tuple without copying memory, converting `C_CONTIGUOUS` to `False` and `F_CONTIGUOUS` to `True`.
* D) Creates a full deep copy with modified data pointers.

---

### Question 8

**Topic:** Einstein Summation Notation

Given a batch of matrices $A$ with shape `(Batch, M, N)` and $B$ with shape `(Batch, N, P)`, which `einsum` expression performs batched matrix multiplication to yield shape `(Batch, M, P)`?

* A) `np.einsum("bmn,bnp->bmp", A, B)`
* B) `np.einsum("mn,np->mp", A, B)`
* C) `np.einsum("bmn,bpn->bmp", A, B)`
* D) `np.einsum("ijk,klm->ilm", A, B)`

---

### Question 9

**Topic:** Virtual Memory & Zero-Stride Broadcasting

When broadcasting a vector of shape `(3, 1)` to shape `(3, 4)`, how does NumPy modify the internal `strides` attribute corresponding to axis 1?

* A) It doubles the byte stride.
* B) It sets the stride value for axis 1 to `0`.
* C) It converts the stride to a negative integer.
* D) It allocates 4 copies of the pointer.

---

### Question 10

**Topic:** Memory-Mapped Arrays (`np.memmap`)

Which parameter mode should be used when initializing an `np.memmap` array to ensure changes made in memory are flushed to disk without discarding pre-existing disk data?

* A) `mode='w+'`
* B) `mode='r+'`
* C) `mode='c'`
* D) `mode='w'`

---

## Section 3: Engineering Scenarios & Diagnostic Analysis

### Question 11

**Topic:** In-Place Memory Allocation Leak

*Scenario:* A real-time feature extraction pipeline is running out of memory (OOM) after processing several million records. The core loop contains:

```python
def process_batch(X_batch, weights, bias):
    # X_batch shape: (10000, 500), float64
    temp = X_batch @ weights
    temp = temp + bias
    out = np.sin(temp)
    return out

```

Which refactored code block eliminates intermediate buffer allocations?

* A)
```python
def process_batch(X_batch, weights, bias, out_buf):
    np.dot(X_batch, weights, out=out_buf)
    out_buf += bias
    np.sin(out_buf, out=out_buf)
    return out_buf

```


* B)
```python
def process_batch(X_batch, weights, bias):
    return np.sin((X_batch @ weights) + bias)

```


* C)
```python
def process_batch(X_batch, weights, bias):
    out = np.empty_like(X_batch)
    out = X_batch @ weights + bias
    return np.sin(out)

```


* D)
```python
def process_batch(X_batch, weights, bias):
    return np.sin(np.add(np.matmul(X_batch, weights), bias))

```



---

### Question 12

**Topic:** Strided Slicing Overhead

You slice an array using a non-unit step: `sub_arr = A[::2, ::2]`. Later in the pipeline, pass `sub_arr` into a low-level C library via C-Types or a heavily vectorized C-extension function. The extension function executes 5x slower than expected. Why?

* A) `sub_arr` is no longer a contiguous block of memory, breaking the SIMD vectorization paths (AVX-512) expected by the low-level library.
* B) Strided slicing converts float64 values to float32 implicitly.
* C) Non-unit strides force Python to execute GIL-locked fallback loops.
* D) `sub_arr` automatically converts into a Python list of lists.

---

### Question 13

**Topic:** Structural Byte Alignment

Which command creates a structured array containing a 4-byte integer ID and an 8-byte double-precision scalar with explicit memory alignment padding matching standard C struct packing (`#pragma pack`)?

* A) `np.dtype([('id', 'i4'), ('val', 'f8')], align=True)`
* B) `np.dtype([('id', 'int32'), ('val', 'float64')], pack=True)`
* C) `np.dtype({'names': ['id', 'val'], 'formats': ['i4', 'f8']}, byteorder='native')`
* D) `np.dtype([('id', '>i4'), ('val', '<f8')])`

---

### Question 14

**Topic:** Out-of-Core Processing Mechanics

When using `np.memmap` to read a 50 GB dataset on a system with 8 GB of RAM, what prevents the system from crashing with an Out-of-Memory (OOM) error?

* A) `np.memmap` compresses the file on disk using LZ4 before reading.
* B) The OS kernel manages virtual memory paging, mapping disk blocks into RAM on demand via page faults and evicting clean pages.
* C) NumPy loads only the array header into RAM and skips all data validation steps.
* D) Python automatically downgrades `float64` elements to `float16`.

---

### Question 15

**Topic:** Reductions over Non-Contiguous Axes

Consider a 3D array `arr` with shape `(100, 200, 300)`. Which reduction axis order is most cache-efficient when iterating sequentially over a C-contiguous array?

* A) Summing along `axis=2` first, followed by `axis=1`, then `axis=0`.
* B) Summing along `axis=0` first, followed by `axis=1`, then `axis=2`.
* C) Axis order has zero mathematical or physical effect on cache performance.
* D) Summing along `axis=1` first, followed by `axis=0`, then `axis=2`.

---

## 🔑 Official Answer Keys & Code Explanations

### 1. B

* **Explanation:** Basic slicing (`A[0:2, 0:2]`) returns a **view** of the parent array. Modifying `slice_view[0, 0]` mutates `A[0, 0]`. Fancy indexing (`A[[0, 1], [0, 1]]`) extracts elements via integer arrays, which forces a **copy**. Modifying `fancy_copy[1, 1]` alters only the detached array copy, leaving `A[1, 1]` unchanged (`5`).

### 2. A

* **Explanation:** For shape `(d0, d1, d2)` = `(4, 5, 6)` and `itemsize = 8` bytes:
* Stride along axis 2 = `itemsize` = $8$ bytes.
* Stride along axis 1 = $d2 \times 8 = 6 \times 8 = 48$ bytes.
* Stride along axis 0 = $d1 \times d2 \times 8 = 5 \times 6 \times 8 = 240$ bytes.
Hence, `strides = (240, 48, 8)`.



### 3. D

* **Explanation:** By NumPy broadcasting rules, shapes are aligned right-to-left:
* Option D: `(2, 3, 4)` vs `(2, 3)` -> Align right: `4` vs `3` (Mismatch! Neither is 1). Throws `ValueError`.
* Option B: `(8, 1, 6, 1)` vs `(7, 1, 5)` -> Aligns right as `(1 vs 5)`, `(6 vs 1)`, `(1 vs 7)`, `(8 vs 1)`. Valid!



### 4. B

* **Explanation:** According to NumPy type promotion rules, combining integer types (`int32`) with floating-point types (`float32`) upcasts to the floating-point precision that covers the float input (`float32`).

### 5. B

* **Explanation:** The `out=` parameter supported by ufuncs (and high-level reductions like `np.sum`) directs NumPy to write output bytes straight into an existing target memory allocation, avoiding heap allocations.

### 6. B

* **Explanation:** C-contiguous order stores contiguous elements along the last axis (rows) sequentially in RAM. When traversing row-wise (`axis=1`), cache lines loaded by the CPU are fully utilized. Column-wise traversal (`axis=0`) skips $10000 \times 8$ bytes per step, causing frequent L1 cache misses.

### 7. C

* **Explanation:** Transposition on a 2D array reverses the `strides` tuple (`strides[::-1]`) and `shape` tuple without moving any bytes in physical RAM. This changes the contiguity flags from C-contiguous to Fortran-contiguous zero-copy.

### 8. A

* **Explanation:** In `np.einsum("bmn,bnp->bmp", A, B)`: `b` is the shared batch index, `m` and `p` are output spatial dimensions, and `n` is the contracted summation index ($A$'s columns multiplied by $B$'s rows).

### 9. B

* **Explanation:** To expand dimensions virtually without duplicating memory, NumPy sets the stride length for the expanded broadcast axis to `0`. Every step along that dimension reads the exact same memory address.

### 10. B

* **Explanation:** `mode='r+'` opens an existing binary file for reading and writing without truncation, allowing updates to be flushed directly back to disk storage. `w+` overwrites/erases the existing file upon opening.

### 11. A

* **Explanation:** Option A uses a pre-allocated output buffer (`out_buf`) along with in-place ufunc execution (`out=out_buf`) and in-place addition (`+=`). This completely avoids allocating temporary arrays on the heap inside the loop.

### 12. A

* **Explanation:** Non-unit strided slicing creates non-contiguous memory blocks. C-extensions or BLAS kernels optimizing for contiguous arrays lose vectorization features (e.g., AVX/SIMD auto-vectorization) when forced to fetch non-adjacent memory addresses across large stride gaps.

### 13. A

* **Explanation:** Passing `align=True` instructs `np.dtype` to pad field offsets automatically to replicate C-struct alignment rules (e.g., aligning an 8-byte double on an 8-byte boundary following a 4-byte int).

### 14. B

* **Explanation:** `np.memmap` maps the on-disk file into virtual memory addresses using OS-level system calls (`mmap`). The operating system's virtual memory manager streams pages to and from disk as required by page faults.

### 15. A

* **Explanation:** Summing along the inner/last axis (`axis=2`) processes adjacent memory sequentially, fully using cached lines before stepping to higher stride dimensions (`axis=1`, then `axis=0`).
