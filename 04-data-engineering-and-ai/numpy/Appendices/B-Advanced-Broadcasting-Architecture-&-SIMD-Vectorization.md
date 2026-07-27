# Appendix B: Advanced Broadcasting Architecture & SIMD Vectorization

While Appendix A examined how NumPy structures memory in contiguous blocks and strides, this appendix explores **how CPUs process that memory at hardware speeds**.

We will unpack the theoretical rules and lower-level C implementation of NumPy's broadcasting engine, explore how modern compilers utilize CPU vectorization instruction sets (AVX-512, AVX2, NEON), and analyze cache locality micro-benchmarks to illustrate why memory access patterns dictate performance.

---

## B.1 The C-Level Algorithm of Broadcasting

Broadcasting is often explained as "stretching" or "copying" a smaller array across a larger one. In practice, **zero memory copying takes place**.

Instead, NumPy's C-level iterator (`NpyIter`) matches array dimensions by dynamically manipulating stride metadata. When an axis has a length of 1, NumPy sets its stride to **0 bytes**.

### The 4 Rules of Broadcasting

When operating on two arrays, $A$ and $B$, NumPy compares their shapes element-wise from **right to left** (trailing dimensions first):

1. **Alignment:** If the arrays differ in rank (number of dimensions), left-pad the shape of the smaller array with `1`s until both shapes have equal length.
2. **Compatibility Check:** Two dimensions are compatible if:
* They are equal ($S_A == S_B$), OR
* One of them is $1$ ($S_A == 1$ or $S_B == 1$).


3. **Incompatibility Error:** If neither condition is met, NumPy raises a `ValueError: operands could not be broadcast together`.
4. **Stride Manipulation:** For any dimension where shape length is $1$, NumPy sets the inner stride for that axis to **0 bytes**.

```text
Array A (2D):   Shape (3, 4)  ---> Strides (32, 8)   [float64 = 8 bytes]
Array B (1D):   Shape (   4) 

Step 1 (Pad):   Array B Shape becomes (1, 4)
Step 2 (Check): Axis 0: (3 vs 1) -> Compatible!
                Axis 1: (4 vs 4) -> Compatible!
Step 3 (Stride):Array B virtual strides become (0, 8)

Resulting Virtual Computation:
Moving along Axis 0 advances Array A by 32 bytes, but Array B advances by 0 bytes!
Array B re-reads the exact same memory address without duplicating memory.

```

---

## B.2 SIMD Vectorization & CPU Cache Alignment

Modern CPUs achieve performance via **SIMD (Single Instruction, Multiple Data)** instructions. Rather than processing one 64-bit float per clock cycle, specialized CPU vector registers perform parallel operations on entire chunks of memory.

```text
Standard Scalar Loop (1 operation per cycle):
  Cycle 1:  [a0] + [b0] -> [c0]
  Cycle 2:  [a1] + [b1] -> [c1]

AVX2 Vector Register (256-bit) (4 x 64-bit floats per cycle):
  Cycle 1:  [a0, a1, a2, a3] + [b0, b1, b2, b3] -> [c0, c1, c2, c3]

AVX-512 Vector Register (512-bit) (8 x 64-bit floats per cycle):
  Cycle 1:  [a0, a1, a2, a3, a4, a5, a6, a7] + [b0, ... b7] -> [c0, ... c7]

```

### CPU Cache Hierarchy & Cache Line Alignment

SIMD registers rely heavily on the CPU L1/L2 data cache. CPUs fetch memory in discrete chunks called **Cache Lines** (typically 64 bytes).

```text
+-------------------------------------------------------------------+
| L1 Data Cache Line (64 Bytes)                                     |
| [Float 0] [Float 1] [Float 2] [Float 3] [Float 4] ... [Float 7]    |
+-------------------------------------------------------------------+

```

* **C-Contiguous Access (Sequential):** Sweeping through continuous memory allows the hardware prefetcher to load entire 64-byte cache lines into L1 cache before the CPU requests them. Vector units achieve ~100% register saturation.
* **Non-Contiguous Access (Strided / Fortran on C):** Stepping across large strides skips memory addresses, causing **cache misses**. The CPU stalls waiting for RAM transfers (a ~100x latency penalty compared to L1 cache).

---

## B.3 Micro-Benchmark: Cache Locality Impact

To visualize how memory layout directly impacts SIMD vectorization and cache hits, consider this micro-benchmark comparing row-wise vs. column-wise reductions on C-contiguous vs. Fortran-contiguous matrices.

### Benchmark Script

```python
import time
import numpy as np

# Create a large 2D matrix (10,000 x 10,000 float64 = 800 MB)
shape = (10_000, 10_000)

# C-Contiguous Matrix (Row-major)
c_array = np.ones(shape, dtype=np.float64, order="C")

# Fortran-Contiguous Matrix (Column-major)
f_array = np.ones(shape, dtype=np.float64, order="F")

# -------------------------------------------------------------
# Test 1: Sum along Axis 1 (Row-wise sum)
# -------------------------------------------------------------
# C-Array: Reading along rows = Contiguous in memory (FAST)
t0 = time.perf_counter()
_ = c_array.sum(axis=1)
dur_c_axis1 = time.perf_counter() - t0

# F-Array: Reading along rows = Strided jump across columns (SLOW)
t0 = time.perf_counter()
_ = f_array.sum(axis=1)
dur_f_axis1 = time.perf_counter() - t0

# -------------------------------------------------------------
# Test 2: Sum along Axis 0 (Column-wise sum)
# -------------------------------------------------------------
# C-Array: Reading along columns = Strided jump across rows (SLOW)
t0 = time.perf_counter()
_ = c_array.sum(axis=0)
dur_c_axis0 = time.perf_counter() - t0

# F-Array: Reading along columns = Contiguous in memory (FAST)
t0 = time.perf_counter()
_ = f_array.sum(axis=0)
dur_f_axis0 = time.perf_counter() - t0

print(f"C-Array  | Row Sum (Axis 1 - Contiguous)  : {dur_c_axis1:.4f} sec")
print(f"C-Array  | Col Sum (Axis 0 - Strided)     : {dur_c_axis0:.4f} sec  <-- {dur_c_axis0/dur_c_axis1:.2f}x slower!")
print("-" * 65)
print(f"F-Array  | Row Sum (Axis 1 - Strided)     : {dur_f_axis1:.4f} sec  <-- {dur_f_axis1/dur_f_axis0:.2f}x slower!")
print(f"F-Array  | Col Sum (Axis 0 - Contiguous)  : {dur_f_axis0:.4f} sec")

```

### Typical Output Analysis

```text
C-Array  | Row Sum (Axis 1 - Contiguous)  : 0.0421 sec
C-Array  | Col Sum (Axis 0 - Strided)     : 0.1853 sec  <-- 4.40x slower!
-----------------------------------------------------------------
F-Array  | Row Sum (Axis 1 - Strided)     : 0.1798 sec  <-- 4.27x slower!
F-Array  | Col Sum (Axis 0 - Contiguous)  : 0.0421 sec

```

**Key Takeaway:** The exact same numerical operation (`.sum()`) runs **4x to 5x faster** simply by ensuring the direction of your reduction matches the contiguous memory layout of your array.
