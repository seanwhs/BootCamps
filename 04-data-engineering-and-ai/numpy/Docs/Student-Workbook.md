# Student Workbook: Mastering High-Performance NumPy

Welcome to the **Mastering High-Performance NumPy Student Workbook**. This companion workbook is designed to solidify your understanding of array computing, stride mechanics, memory efficiency, and advanced execution models.

Use this workbook alongside the core modules, primers, and appendices. Work through the challenges using your Python terminal or a Jupyter notebook.

---

## Module 1: Memory Architecture & Stride Mechanics

### 💡 Core Review

A NumPy `ndarray` separates array metadata (`shape`, `strides`, `dtype`) from its contiguous raw binary payload in RAM. Modifying strides or shape creates a **view** (0 bytes allocated), while fancy indexing or non-uniform slicing forces a **copy**.

### ✏️ Exercise 1.1: Stride Calculations by Hand

Given an array `A` created with `np.arange(24, dtype=np.int32).reshape(2, 3, 4)`:

1. What is the `itemsize` in bytes for `int32`?
2. What are the `shape` and `strides` of `A` under a C-contiguous layout?
3. Calculate the byte offset from the base memory address for element `A[1, 2, 3]`.

> **Your Answer:**
> * `itemsize`: `______` bytes
> * `shape`: `(______, ______, ______)`
> * `strides`: `(______, ______, ______)`
> * Byte Offset Formula & Result: `____________________________________`
> 
> 

* **`itemsize`**: 4 bytes (32 bits / 8 bits per byte).
* **`shape`**: `(2, 3, 4)`
* **`strides`**: `(48, 16, 4)`
* $T_2 = 4\text{ bytes}$
* $T_1 = 4 \times 4 = 16\text{ bytes}$
* $T_0 = 3 \times 16 = 48\text{ bytes}$


* **Byte Offset for `A[1, 2, 3]**`:

$$\text{Offset} = (1 \times 48) + (2 \times 16) + (3 \times 4) = 48 + 32 + 12 = 92\text{ bytes}$$



---

### 💻 Exercise 1.2: View vs. Copy Audit

Analyze the four array operations below. Predict whether each variable is a **View** (shares memory) or a **Copy** (allocates new memory), then write a diagnostic assertion using `.base` or `ctypes.data` to verify your prediction in Python.

```python
import numpy as np

X = np.random.randn(100, 100)

# Predict View or Copy:
a = X[::2, ::2]       # Operation 1: _______
b = X[[0, 1, 2], :]   # Operation 2: _______
c = X.T               # Operation 3: _______
d = X.reshape(50, 200)# Operation 4: _______

```

```python
# Verification Code
assert a.base is X  # Operation 1: VIEW (Strides multiplied by 2)
assert b.base is None  # Operation 2: COPY (Fancy integer indexing)
assert c.base is X  # Operation 3: VIEW (Strides reversed)
assert d.base is X  # Operation 4: VIEW (Contiguous layout preserved)

print("All memory assertions passed successfully!")

```

---

## Module 2: Broadcasting Mechanics & Vectorization

### 💡 Core Review

Broadcasting operates from **right to left** (trailing dimensions first). Two dimensions are compatible if they are equal or if one of them is $1$. When a dimension is $1$, NumPy sets its stride along that axis to **0 bytes**, virtually duplicating data without memory allocation.

### ✏️ Exercise 2.1: Shape Compatibility Check

Determine if the following array shapes can broadcast together. If valid, state the resulting output shape. If invalid, explain why.

| Array A Shape | Array B Shape | Valid? (Yes/No) | Output Shape / Error Reason |
| --- | --- | --- | --- |
| `(8, 1, 6, 1)` | `(7, 1, 5)` | `________` | `________________________` |
| `(5, 4)` | `(1, 4)` | `________` | `________________________` |
| `(15, 3, 5)` | `(15, 1, 2)` | `________` | `________________________` |
| `(10,)` | `(2, 10)` | `________` | `________________________` |

| Array A Shape | Array B Shape | Valid? | Output Shape / Error Reason |
| --- | --- | --- | --- |
| `(8, 1, 6, 1)` | `(7, 1, 5)` | **Yes** | `(8, 7, 6, 5)` (B left-padded to `(1, 7, 1, 5)`) |
| `(5, 4)` | `(1, 4)` | **Yes** | `(5, 4)` |
| `(15, 3, 5)` | `(15, 1, 2)` | **No** | Incompatible at Axis 2 (5 vs 2) |
| `(10,)` | `(2, 10)` | **Yes** | `(2, 10)` (A left-padded to `(1, 10)`) |

---

### 💻 Exercise 2.2: Implement Pairwise Distance Matrix Without Loops

Given a dataset $X$ of shape $(N, D)$ containing $N$ feature vectors of size $D$, write a vectorized NumPy expression to calculate the $(N, N)$ matrix of squared Euclidean distances $S_{i,j} = \Vert{}X_i - X_j\Vert{}^2$ using broadcasting.

```python
import numpy as np

N, D = 500, 10
rng = np.random.default_rng(42)
X = rng.standard_normal((N, D))

# TODO: Compute pairwise squared distance matrix 'S' of shape (N, N)
# Constraint: Do not use python loops or scipy.
S = ... # Your expression here

```

```python
# Solution 1: 3D Expansion with Broadcasting (Memory Intensive for large N)
S = np.sum((X[:, np.newaxis, :] - X[np.newaxis, :, :]) ** 2, axis=-1)

# Solution 2: Algebraic Expansion ||a - b||^2 = ||a||^2 + ||b||^2 - 2(a . b) (Memory Efficient)
G = X @ X.T
sq_norms = np.diag(G)
S_algebraic = sq_norms[:, np.newaxis] + sq_norms[np.newaxis, :] - 2 * G

# Verify both produce identical outputs
assert np.allclose(S, S_algebraic)
print("Pairwise distance matrix computed successfully!")

```

---

## Module 3: Advanced Optimization, `einsum`, and Numba

### 💡 Core Review

* **`np.einsum`**: Expresses tensor transformations using subscript letters. Indices omitted from output are contracted (summed over).
* **In-place ufuncs**: Using `out=destination` eliminates intermediate buffer allocations.
* **Numba JIT**: Converts pure Python loops operating on NumPy arrays into compiled C machine code via LLVM.

### ✏️ Exercise 3.1: Einstein Summation Translation

Translate the following standard NumPy routines into their equivalent `np.einsum` string representation:

1. Row sums of a 2D matrix $A$: `np.sum(A, axis=1)` $\rightarrow$ `np.einsum("________", A)`
2. Matrix trace of $A$: `np.trace(A)` $\rightarrow$ `np.einsum("________", A)`
3. Batched Matrix Multiplication: $A$ shape `(B, N, M)`, $B$ shape `(B, M, P)` $\rightarrow$ `np.einsum("________", A, B)`

1. Row sums: `np.einsum("ij->i", A)`
2. Matrix trace: `np.einsum("ii->", A)`
3. Batched MatMul: `np.einsum("bij,bmp->bip", A, B)` (or `"bij,bjk->bik"`)

---

### 💻 Exercise 3.2: Refactoring Anti-Patterns (Hands-On Lab)

Refactor the unoptimized code block below. Eliminate temporary buffer allocations and apply in-place ufuncs to maximize speed and memory efficiency.

```python
import numpy as np

def unoptimized_pipeline(a: np.ndarray, b: np.ndarray, c: np.ndarray) -> np.ndarray:
    """Calculates: result = (a * 2.5 + b) - c  (Creates 3 temporary arrays)"""
    temp1 = a * 2.5
    temp2 = temp1 + b
    result = temp2 - c
    return result

# TODO: Refactor using zero-allocation in-place ufuncs (or numexpr)
def optimized_pipeline(a: np.ndarray, b: np.ndarray, c: np.ndarray) -> np.ndarray:
    # Your optimized implementation here
    pass

```

```python
def optimized_pipeline(a: np.ndarray, b: np.ndarray, c: np.ndarray) -> np.ndarray:
    # Option 1: Pre-allocated buffer with in-place ufuncs
    result = np.empty_like(a)
    np.multiply(a, 2.5, out=result)
    np.add(result, b, out=result)
    np.subtract(result, c, out=result)
    return result

# Verification
a = np.ones((1000, 1000))
b = np.ones((1000, 1000)) * 2
c = np.ones((1000, 1000)) * 0.5

res_unopt = unoptimized_pipeline(a, b, c)
res_opt = optimized_pipeline(a, b, c)

assert np.allclose(res_unopt, res_opt)
print("Pipeline refactored successfully with zero intermediate allocations!")

```

---

## 🛠️ Capstone Mini-Project: Building a Memory-Mapped Out-of-Core Batch Processor

**Goal:** Create a script that generates a 1 GB binary file on disk representing a dataset of $10,000,000$ rows and $10$ features (`float64`). Then, write an out-of-core batch processor using `np.memmap` that computes column-wise means and standard deviations in chunks of $100,000$ rows without ever loading more than 10 MB into RAM at a time.

```python
# capstone_solution.py
import os
import numpy as np

def run_capstone():
    filename = "large_dataset.dat"
    n_rows, n_cols = 10_000_000, 10
    dtype = np.float64
    chunk_size = 100_000

    # 1. Create memmap on disk
    print(f"Creating ~{(n_rows * n_cols * 8) / (1024**2):.2f} MB binary file on disk...")
    fp = np.memmap(filename, dtype=dtype, mode="w+", shape=(n_rows, n_cols))
    
    # Populate dummy data chunk by chunk
    rng = np.random.default_rng(42)
    for i in range(0, n_rows, chunk_size):
        fp[i:i+chunk_size] = rng.standard_normal((chunk_size, n_cols))
    fp.flush()
    del fp

    # 2. Process out-of-core using chunked memmap reads
    mmap = np.memmap(filename, dtype=dtype, mode="r", shape=(n_rows, n_cols))
    
    col_sum = np.zeros(n_cols, dtype=np.float64)
    col_sq_sum = np.zeros(n_cols, dtype=np.float64)

    print("Processing dataset in out-of-core chunks...")
    for i in range(0, n_rows, chunk_size):
        chunk = mmap[i:i+chunk_size]
        col_sum += chunk.sum(axis=0)
        col_sq_sum += (chunk ** 2).sum(axis=0)

    col_mean = col_sum / n_rows
    col_var = (col_sq_sum / n_rows) - (col_mean ** 2)
    col_std = np.sqrt(col_var)

    print("\nOut-of-Core Dataset Summary:")
    print(f"Column Means : {np.round(col_mean, 4)}")
    print(f"Column Stds  : {np.round(col_std, 4)}")

    # Clean up file
    del mmap
    if os.path.exists(filename):
        os.remove(filename)
        print("Cleaned up temporary disk file.")

if __name__ == "__main__":
    run_capstone()

```

---

> **Workbook Complete!** You now possess the practical tools, mental models, and code patterns to build production-ready numerical systems.
