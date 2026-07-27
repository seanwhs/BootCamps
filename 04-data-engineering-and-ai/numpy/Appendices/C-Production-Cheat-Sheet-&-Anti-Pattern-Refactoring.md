# Appendix C: Production Cheat Sheet & Anti-Pattern Refactoring

While previous appendices detailed memory internals and SIMD mechanics, this final appendix serves as a practical engineering reference. It contains a production cheat sheet for high-frequency operations, diagnostic recipes for memory bugs, and direct code refactorings for common performance anti-patterns.

---

## C.1 High-Frequency Production Cheat Sheet

| Intent | Optimal NumPy Expression | Memory Impact | Notes |
| --- | --- | --- | --- |
| **In-place addition** | `np.add(a, b, out=a)` | 0 Bytes allocated | Reuses buffer `a`. Avoids `a = a + b` temp allocation. |
| **Conditional assignment** | `np.where(mask, value, a)` | New Array | For in-place mutation, use `a[mask] = value`. |
| **Clip values** | `np.clip(a, min_val, max_val, out=a)` | 0 Bytes allocated | Mutates `a` in-place within hardware bounds. |
| **Matrix Multiply** | `a @ b` or `np.matmul(a, b)` | New Array | Uses BLAS/LAPACK (OpenBLAS/MKL) thread pools. |
| **Batched Matrix Multiply** | `np.einsum('bij,bjk->bik', A, B)` | New Array | Clearer and often faster than looped `matmul`. |
| **Find nonzero indices** | `np.flatnonzero(mask)` | New Array (1D) | Faster alternative to `np.where(mask)[0]`. |
| **Sliding Window View** | `np.lib.stride_tricks.sliding_window_view` | **View** (0 Copy) | Creates windowed views without duplicating memory. |
| **Add Dimension** | `a[:, np.newaxis]` or `a[:, None]` | **View** (0 Copy) | Inserts an axis of length 1 for broadcasting. |

---

## C.2 Diagnostic Recipes for Memory Leak & Performance Bugs

### 1. Detecting Unexpected Memory Copies

To verify whether an operation created a copy or returned a view in production or test suites, check the `.base` attribute:

```python
def assert_is_view(original: np.ndarray, derived: np.ndarray) -> None:
    """Raises AssertionError if derived array is a memory copy instead of a view."""
    assert derived.base is not None, "Target array owns its memory (it is a copy!)."
    assert (derived.base is original) or (derived.base is original.base), \
        "Target array does not share memory with the original array."

```

### 2. Identifying Unintentional Memory Retention

When slicing a tiny sub-array from a giant array, the small slice holds a reference to the **entire parent memory block via `.base**`, preventing Python's garbage collector from freeing the large array.

```python
# BUG: Holds reference to full 1 GB array in memory
giant_array = np.ones((10000, 10000), dtype=np.float64)  # ~800 MB
small_slice = giant_array[:2, :2]  # Sub-slice
del giant_array  # Memory IS NOT FREED because small_slice.base still points to it!

# FIX: Explicitly copy small slice to detach from large buffer, then free original
small_slice_detached = giant_array[:2, :2].copy()
del giant_array  # ~800 MB is successfully garbage-collected!

```

---

## C.3 Refactoring Anti-Patterns to High-Performance Code

### Anti-Pattern 1: Appending in a Loop (`np.append` / `np.concatenate`)

* **Bad Practice:** Calling `np.append()` inside a loop reallocates and copies the entire array on every iteration ($O(N^2)$ time complexity).

```python
# BAD (O(N^2) allocations)
data = np.empty((0, 10))
for row in stream:
    data = np.append(data, row, axis=0)  # Reallocates whole array every time!

```

* **Production Solution:** Pre-allocate a fixed buffer or accumulate in a standard Python list and convert once.

```python
# GOOD (O(N) single allocation)
buffer = []
for row in stream:
    buffer.append(row)
data = np.array(buffer)  # Single memory allocation at the end

```

---

### Anti-Pattern 2: Slow Python Loops Over Array Rows

* **Bad Practice:** Iterating over `ndarray` rows using Python `for` loops strips away C-speed vectorization and adds massive Python interpreter overhead.

```python
# BAD (Slow Python loop execution)
N = len(data)
results = np.empty(N)
for i in range(N):
    results[i] = np.sin(data[i]) + np.cos(data[i])

```

* **Production Solution:** Express operations using vectorized ufuncs or compile custom loops with Numba JIT.

```python
# GOOD (Vectorized C ufunc pass)
results = np.sin(data) + np.cos(data)

# ALTERNATIVE GOOD (In-place zero-allocation pipeline)
results = np.sin(data)
results += np.cos(data, out=results)

```

---

### Anti-Pattern 3: Intermediate Chained Array Expressions

* **Bad Practice:** Chaining standard operators creates temporary arrays for every intermediate operation.

```python
# BAD (Creates 3 hidden temporary arrays)
# Temp 1: (a * 2.5)
# Temp 2: Temp 1 + b
# Temp 3: Temp 2 - c
result = (a * 2.5) + b - c

```

* **Production Solution:** Use `numexpr` or in-place ufuncs with `out=` parameters to calculate expressions in a single cache-friendly pass.

```python
import numexpr as ne

# GOOD (Evaluated in C/C++ multithreaded chunked loops with zero intermediate copies)
result = ne.evaluate("(a * 2.5) + b - c")

```
