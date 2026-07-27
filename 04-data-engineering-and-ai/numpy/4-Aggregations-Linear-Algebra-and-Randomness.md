# Part 4: Numerical Powerhouse — Aggregations, Linear Algebra, and Randomness

With array memory, indexing, and vector broadcasting mastered, we can now tap into NumPy’s analytical and mathematical engine.

In real-world data pipelines, raw multi-dimensional data must be summarized across specific dimensions, transformed using matrix algebra, and modeled using stochastic (random) simulations. Performing these operations in pure Python using nested loops quickly becomes a major performance bottleneck. NumPy offloads these computations directly to compiled C routines and high-performance C-BLAS/LAPACK linear algebra libraries (such as OpenBLAS or MKL).

In this section, we will build our fourth core module: `04_numerical_powerhouse.py`.

---

## Step 4.1: Multi-Axis Aggregations and Handling Missing Data (NaNs)

### 1. The Target

We will construct a statistical reduction pipeline that computes summary statistics (`mean`, `std`, `sum`, `argmin`/`argmax`) across specified axes while gracefully handling missing numerical values (`NaN`s).

### 2. The Concept

Think of a 2D matrix as a printed table where rows represent individual students and columns represent exam subjects:

* **Axis 0 (Collapse Rows / Run Down Columns):** You move vertically down each column to calculate the *average score for each subject*.
* **Axis 1 (Collapse Columns / Run Across Rows):** You move horizontally across each row to calculate the *overall average for each individual student*.
* **`NaN` (Not a Number):** Represents a missing test score. Standard statistical ufuncs like `np.mean()` fail and return `NaN` if even a single value is missing. NaN-safe ufuncs like `np.nanmean()` automatically mask out missing values to calculate accurate statistics.

```
Visualizing Axis Reductions on a 2D Grid:

              Axis 1 ───► (Across Columns)
             ┌───────────┬───────────┬───────────┐
             │ Math (90) │ Sci (80)  │ Eng (70)  │ ──► Student 1 Mean (80.0) [Axis 1]
 Axis 0      ├───────────┼───────────┼───────────┤
   │         │ Math (100)│ Sci (NaN) │ Eng (80)  │ ──► Student 2 Mean (90.0) [nanmean Axis 1]
   ▼         └───────────┴───────────┴───────────┘
(Down Rows)        │           │           │
                   ▼           ▼           ▼
            Math Mean   Sci Mean    Eng Mean
             (95.0)      (80.0)      (75.0)   [nanmean Axis 0]

```

### 3. The Implementation

Create the file `04_numerical_powerhouse.py` in your project root.

```python
# 04_numerical_powerhouse.py
from typing import Tuple
import numpy as np


def demonstrate_axis_aggregations() -> Tuple[np.ndarray, np.ndarray]:
    """Demonstrates multi-axis reductions and NaN-safe statistical operations."""
    print("\n================ 1. MULTI-AXIS AGGREGATIONS & NAN HANDLING ================")

    # 2D Matrix (3 students, 4 quarterly tests) containing missing data (np.nan)
    scores = np.array([
        [85.0, 90.0, np.nan, 95.0],
        [70.0, np.nan, 80.0, 75.0],
        [60.0, 65.0, 70.0, np.nan]
    ], dtype=np.float64)

    print(f"Raw Student Scores Matrix (3x4):\n{scores}")

    # Standard np.mean fails when NaNs are present:
    standard_mean = np.mean(scores, axis=0)
    print(f"\nStandard np.mean(axis=0) [Contains NaNs]: {standard_mean}")

    # NaN-safe aggregation: np.nanmean ignores NaN entries
    subject_means = np.nanmean(scores, axis=0)  # Collapse rows -> 4 subject averages
    student_means = np.nanmean(scores, axis=1)  # Collapse cols -> 3 student averages

    print(f"NaN-Safe Subject Averages (Axis 0): {subject_means}")
    print(f"NaN-Safe Student Averages (Axis 1): {student_means}")

    # Finding indices of peak scores using argmax
    # Fill NaNs with -inf temporarily to find valid maximum indices
    clean_scores = np.nan_to_num(scores, nan=-np.inf)
    top_student_per_subject = np.argmax(clean_scores, axis=0)
    print(f"Row Index of Highest Score per Subject (Axis 0): {top_student_per_subject}")

    print("===========================================================================\n")
    return subject_means, student_means


if __name__ == "__main__":
    demonstrate_axis_aggregations()

```

### 4. The Verification

Execute the module from your command line:

```bash
python 04_numerical_powerhouse.py

```

**Expected Verification Output:**

```text
================ 1. MULTI-AXIS AGGREGATIONS & NAN HANDLING ================
Raw Student Scores Matrix (3x4):
[[85. 90. nan 95.]
 [70. nan 80. 75.]
 [60. 65. 70. nan]]

Standard np.mean(axis=0) [Contains NaNs]: [71.66666667        nan        nan        nan]
NaN-Safe Subject Averages (Axis 0): [71.66666667 77.5        75.         85.        ]
NaN-Safe Student Averages (Axis 1): [90.         75.         65.        ]
Row Index of Highest Score per Subject (Axis 0): [0 0 1 0]
===========================================================================

```

---

## Step 4.2: Linear Algebra Fundamentals & Tensor Decompositions

### 1. The Target

Append linear algebra routines to `04_numerical_powerhouse.py` utilizing `np.linalg` for high-performance matrix multiplication (`@` / `matmul`), matrix inversion, determinant calculation, and Singular Value Decomposition (SVD).

### 2. The Concept

* **Matrix Multiplication (`@` / `np.matmul`)**: Unlike element-wise multiplication (`*`), matrix multiplication combines linear transformations. A matrix $A$ of shape $(M, K)$ multiplied by $B$ of shape $(K, N)$ yields a matrix $C$ of shape $(M, N)$.
* **Singular Value Decomposition (SVD)**: Deconstructs any $M \times N$ matrix $A$ into three distinct components: $A = U \cdot \Sigma \cdot V^T$. SVD is the mathematical engine behind principal component analysis (PCA), dimensionality reduction, and image compression.

### 3. The Implementation

Append the linear algebra suite to `04_numerical_powerhouse.py`:

```python
# Append to 04_numerical_powerhouse.py


def demonstrate_linear_algebra() -> None:
    """Demonstrates high-performance linear algebra routines using np.linalg."""
    print("\n================ 2. LINEAR ALGEBRA & DECOMPOSITIONS ================")

    # 1. Matrix Multiplication (@ operator calls BLAS dgemm under the hood)
    matrix_a = np.array([[1.0, 2.0], [3.0, 4.0]], dtype=np.float64)
    matrix_b = np.array([[5.0, 6.0], [7.0, 8.0]], dtype=np.float64)

    product = matrix_a @ matrix_b  # Equivalent to np.matmul(matrix_a, matrix_b)
    print(f"Matrix A (2x2):\n{matrix_a}")
    print(f"Matrix B (2x2):\n{matrix_b}")
    print(f"Matrix Product A @ B (2x2):\n{product}")

    # 2. Matrix Inversion and Determinant
    det_a = np.linalg.det(matrix_a)
    inv_a = np.linalg.inv(matrix_a)
    print(f"\nDeterminant of A : {det_a:.4f}")
    print(f"Inverse of A (A^-1):\n{inv_a}")

    # Verify identity matrix: A @ A^-1 = I
    identity_check = np.allclose(matrix_a @ inv_a, np.eye(2))
    print(f"Does A @ A^-1 equal Identity Matrix I? : {identity_check}")

    # 3. Singular Value Decomposition (SVD)
    data_matrix = np.array([
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0]
    ], dtype=np.float64)

    U, S, Vt = np.linalg.svd(data_matrix, full_matrices=False)
    print(f"\nSVD Decomposition of Data Matrix (2x3):")
    print(f"U  Shape (Left Singular Vectors)  : {U.shape}")
    print(f"S  Shape (Singular Values)        : {S.shape} -> Values: {S}")
    print(f"Vt Shape (Right Singular Vectors) : {Vt.shape}")

    print("===================================================================\n")


if __name__ == "__main__":
    demonstrate_linear_algebra()

```

### 4. The Verification

Run the updated file:

```bash
python 04_numerical_powerhouse.py

```

**Expected Verification Output:**

```text
================ 2. LINEAR ALGEBRA & DECOMPOSITIONS ================
Matrix A (2x2):
[[1. 2.]
 [3. 4.]]
Matrix B (2x2):
[[5. 6.]
 [7. 8.]]
Matrix Product A @ B (2x2):
[[19. 22.]
 [43. 50.]]

Determinant of A : -2.0000
Inverse of A (A^-1):
[[-2.   1. ]
 [ 1.5 -0.5]]
Does A @ A^-1 equal Identity Matrix I? : True

SVD Decomposition of Data Matrix (2x3):
U  Shape (Left Singular Vectors)  : (2, 2)
S  Shape (Singular Values)        : (2,) -> Values: [9.508032   0.77286964]
Vt Shape (Right Singular Vectors) : (2, 3)
===================================================================

```

---

## Step 4.3: Stochastic Simulations using the NumPy Generator API

### 1. The Target

Add a reproducible, thread-safe random sampling and distribution generator to `04_numerical_powerhouse.py` utilizing the modern `numpy.random.Generator` interface (PCG64 bit generator).

### 2. The Concept

In older NumPy code, random numbers were generated using global state (`np.random.seed()`). This global approach is not thread-safe and leads to non-reproducible results in concurrent applications.

The modern NumPy standard uses explicit instances of `np.random.default_rng()`. This instantiates a self-contained PCG64 statistical engine that can be passed safely across multi-threaded applications.

### 3. The Implementation

Append the stochastic simulation suite to `04_numerical_powerhouse.py`:

```python
# Append to 04_numerical_powerhouse.py


def demonstrate_stochastic_simulation(num_samples: int = 1_000_000) -> None:
    """Demonstrates high-speed random distribution sampling using the modern Generator API."""
    print(f"\n================ 3. STOCHASTIC SIMULATOR ({num_samples:,} SAMPLES) ================")

    # Initialize explicit BitGenerator instance with a fixed seed for exact reproducibility
    seed = 42
    rng = np.random.default_rng(seed=seed)

    # 1. Gaussian / Normal Distribution: Mean = 100.0, Standard Deviation = 15.0
    normal_samples = rng.normal(loc=100.0, scale=15.0, size=num_samples)

    # 2. Uniform Distribution: Interval [0.0, 1.0)
    uniform_samples = rng.random(size=num_samples)

    # 3. Discrete Uniform Integers: Simulate rolling a 6-sided die
    dice_rolls = rng.integers(low=1, high=7, size=num_samples)

    # Calculate simulated statistics to verify theoretical convergence
    simulated_mean = np.mean(normal_samples)
    simulated_std = np.std(normal_samples)

    print(f"Generated Normal Samples Shape : {normal_samples.shape}")
    print(f"Theoretical Normal Params      : Mean = 100.0, Std = 15.0")
    print(f"Empirical Simulated Results    : Mean = {simulated_mean:.4f}, Std = {simulated_std:.4f}")
    print(f"First 5 Simulated Dice Rolls   : {dice_rolls[:5]}")

    print("===================================================================================\n")


if __name__ == "__main__":
    demonstrate_stochastic_simulation(num_samples=1_000_000)

```

### 4. The Verification

Run the entire pipeline script:

```bash
python 04_numerical_powerhouse.py

```

**Expected Verification Output:**

```text
================ 3. STOCHASTIC SIMULATOR (1,000,000 SAMPLES) ================
Generated Normal Samples Shape : (1000000,)
Theoretical Normal Params      : Mean = 100.0, Std = 15.0
Empirical Simulated Results    : Mean = 100.0039, Std = 15.0084
First 5 Simulated Dice Rolls   : [1 5 4 4 1]
===================================================================================

```

---

## Technical Reference: Axis Reduction Rule of Thumb

When specifying `axis` parameters in multi-dimensional reduction functions (`np.sum`, `np.mean`, `np.argmax`), remember this rule:

> **The specified axis is the dimension that gets collapsed (eliminated).**

For a 3D tensor of shape $(A, B, C) = (2, 3, 4)$:

* `np.sum(tensor, axis=0)`: Collapses axis 0 (size 2). Resulting shape is **$(3, 4)$**.
* `np.sum(tensor, axis=1)`: Collapses axis 1 (size 3). Resulting shape is **$(2, 4)$**.
* `np.sum(tensor, axis=2)`: Collapses axis 2 (size 4). Resulting shape is **$(2, 3)$**.
* `np.sum(tensor, axis=(0, 2))`: Collapses axes 0 and 2 simultaneously. Resulting shape is **$(3,)$**.
