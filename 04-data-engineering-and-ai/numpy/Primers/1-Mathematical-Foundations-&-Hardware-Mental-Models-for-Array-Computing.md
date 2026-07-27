# Primer 1: Mathematical Foundations & Hardware Mental Models for Array Computing

Before writing high-performance numerical code, you need two things: a solid grasp of linear algebra mechanics and a clear mental model of how computer hardware executes array operations.

This primer bridges abstract linear algebra concepts with physical system architecture, setting the baseline for everything built in the core modules.

---

## P1.1 The Hardware Gap: Why Python Lists Fail at Scale

To understand why array libraries like NumPy exist, we first need to look at how CPython handles standard lists in memory.

### The Dynamic Pointer Array Problem

A standard Python `list` is a dynamic array of **pointers** (`PyObject*`). When you create a list like `[1.0, 2.0, 3.0]`, the list does not store numbers directly; it stores memory addresses that point to floating-point objects scattered across the heap:

```text
Python List Memory Layout (Pointer Chasing):
  [ List Object ] 
   |-> Pointer 0 ---> [ PyFloatObject: 1.0 ] (24+ bytes, address 0x04A)
   |-> Pointer 1 ---> [ PyFloatObject: 2.0 ] (24+ bytes, address 0x8F1)
   |-> Pointer 2 ---> [ PyFloatObject: 3.0 ] (24+ bytes, address 0x12B)

```

This design introduces two severe performance bottlenecks:

1. **Memory Overhead:** A raw 64-bit float requires **8 bytes** of RAM. A Python `PyFloatObject` requires **24 bytes** or more (for reference counts, type objects, and value payloads), plus **8 bytes** for the pointer itself—a 400%+ memory overhead.
2. **Cache Miss Invalidation:** Because the `PyFloatObject` items are scattered randomly across heap memory, the CPU cannot predict which memory location to fetch next. It constantly incurs **L1/L2 cache misses**, forcing the CPU pipeline to stall while fetching data from slow main RAM.

### The Contiguous Array Solution

An `ndarray` eliminates pointers entirely by storing unboxed, raw binary numbers in a single, unbroken block of memory:

```text
Contiguous Array Memory Layout (Cache Friendly):
  [ NumPy Array Header ]
   |-> Base Pointer ---> [ 1.0 ][ 2.0 ][ 3.0 ][ 4.0 ][ 5.0 ]
                         | 8B  || 8B  || 8B  || 8B  || 8B  |
                         0x000   0x008   0x010   0x018   0x020

```

Because the memory addresses are strictly sequential, the CPU's hardware prefetcher loads entire blocks of data into L1/L2 caches ahead of time, allowing SIMD (Single Instruction, Multiple Data) vector units to execute operations at maximum memory bandwidth.

---

## P1.2 Core Linear Algebra Concepts for Code

Numerical pipelines translate mathematical operations on vectors, matrices, and tensors into code. Here are the four core structures you will work with:

```text
  Scalar (Rank 0)         Vector (Rank 1)            Matrix (Rank 2)               Tensor (Rank 3+)
    [ 5.0 ]                [ 1.0, 2.0, 3.0 ]         [[ 1.0, 2.0 ],               [[[ 1.0, 2.0 ]],
                                                       [ 3.0, 4.0 ]]                [[ 3.0, 4.0 ]]]
   Shape: ()               Shape: (3,)               Shape: (2, 2)                Shape: (2, 1, 2)

```

### 1. Vector Spaces & Dot Products

A 1D array represents a vector $\mathbf{v} \in \mathbb{R}^n$. The inner product (dot product) of two vectors $\mathbf{a}$ and $\mathbf{b}$ condenses two sequences of numbers into a single scalar:

$$\mathbf{a} \cdot \mathbf{b} = \sum_{i=1}^{n} a_i b_i = a_1 b_1 + a_2 b_2 + \dots + a_n b_n$$

* **Geometric Intuition:** The dot product measures directional alignment. If $\mathbf{a} \cdot \mathbf{b} = 0$, the vectors are orthogonal ($90^\circ$ perpendicular).
* **Code Translation:** In code, this powers weighted sums, matrix multiplication, and similarity metrics (like cosine similarity).

### 2. Matrix Multiplication Mechanics

When multiplying matrix $A$ of shape $(m \times n)$ by matrix $B$ of shape $(n \times p)$, the resulting matrix $C$ has shape $(m \times p)$.

Each element $C_{i,j}$ is calculated as the dot product of row $i$ from matrix $A$ and column $j$ from matrix $B$:

$$C_{i,j} = \sum_{k=1}^{n} A_{i,k} B_{k,j}$$

```text
Matrix Multiplication Alignment:
  A (m x n)  x  B (n x p)  =  C (m x p)
        ^           ^
        +--- MUST ---+
            MATCH

```

> **Rule:** Matrix multiplication is non-commutative ($A B \neq B A$).

---

## P1.3 Coordinate Systems, Axes, and Dimensions

The word **"dimension"** can mean two different things in engineering discussions:

1. **Vector Dimension:** The length of a 1D vector (e.g., a 128-dimensional embedding vector has shape `(128,)`).
2. **Array Rank / Axis Index:** The number of indices required to select a single scalar from an array (e.g., a 3D tensor has 3 axes: `axis 0`, `axis 1`, `axis 2`).

### Visualizing Axis Directions in Multi-Dimensional Arrays

To prevent spatial orientation confusion during reductions (like `.sum(axis=k)`), use this mental model:

* **2D Matrix `shape = (rows, cols)`:**
* `axis 0`: Operates **vertically** down the rows (collapsing rows to leave a single row).
* `axis 1`: Operates **horizontally** across the columns (collapsing columns to leave a single column).



```text
                  axis 1 --->
             +-----------------+
             |  Col 0   Col 1  |
  axis 0     | [1.0]   [2.0]   |  ---> .sum(axis=1) sums across columns
    |        | [3.0]   [4.0]   |       Returns shape (2,)
    v        +-----------------+
              .sum(axis=0) sums down rows
              Returns shape (2,)

```

* **3D Tensor `shape = (batch, rows, cols)`:**
* `axis 0`: The batch or depth dimension.
* `axis 1`: The rows within each matrix.
* `axis 2`: The columns within each matrix.



---

## P1.4 Numerical Precision, Floats, and Underflow

Numerical computing requires handling floating-point arithmetic carefully. Computers represent real numbers using IEEE 754 standard binary floats, which can introduce rounding nuances.

### Floating-Point Data Types at a Glance

| Precision | Data Type | Bits (Sign + Exponent + Mantissa) | Significant Digits | Range | Typical Use Case |
| --- | --- | --- | --- | --- | --- |
| **Half** | `float16` | $1 + 5 + 10$ | ~3–4 digits | $\pm 6.5 \times 10^4$ | Deep learning weights (GPU memory constrained) |
| **Single** | `float32` | $1 + 8 + 23$ | ~6–7 digits | $\pm 3.4 \times 10^{38}$ | Computer vision, general AI inference |
| **Double** | `float64` | $1 + 11 + 52$ | ~15–17 digits | $\pm 1.7 \times 10^{308}$ | Scientific simulations, financial modeling, high-precision physics |

### Common Numerical Pitfalls

#### 1. Representation Errors

Certain base-10 decimals cannot be represented exactly in base-2 binary floating point:

```python
# Direct comparison failure
0.1 + 0.2 == 0.3  # Returns False! (0.1 + 0.2 evaluated to 0.30000000000000004)

# Correct Production Practice: Use absolute/relative tolerances
import numpy as np
np.isclose(0.1 + 0.2, 0.3)  # Returns True

```

#### 2. Catastrophic Cancellation

Subtracting two nearly equal, large numbers causes the most significant digits to cancel out, leaving only the noisy, imprecise low-order bits:

$$\text{If } a = 1.000000000000001 \text{ and } b = 1.000000000000000\text{:}$$

$$a - b = 0.000000000000001 \quad (\text{Precision degrades rapidly})$$

To mitigate this in numerical algorithms (like softmax or variance calculations), algorithms subtract the maximum value first (a technique known as the **Log-Sum-Exp trick**).
