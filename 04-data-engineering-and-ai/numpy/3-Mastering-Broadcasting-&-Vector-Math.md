# Part 3: Mastering Broadcasting & Vector Math

In the previous parts, we explored how NumPy stores arrays in contiguous memory and how to manipulate their shapes and extract subsets. Now, we arrive at NumPy's most powerful—and frequently misunderstood—feature: **Broadcasting**.

In standard algebra, you cannot add a 1D vector of length $3$ to a 2D matrix of shape $(3, 3)$ without explicitly writing nested loops to repeat the vector across the matrix rows. Broadcasting solves this mathematically and computationally: it allows NumPy to perform element-wise arithmetic operations on arrays of **mismatched shapes** without physically copying data in memory.

In this section, we will build our third core module: `03_broadcasting_and_math.py`.

---

## Step 3.1: Universal Functions (ufuncs) and Element-Wise Arithmetic

### 1. The Target

We will construct a module demonstrating fast element-wise operations using NumPy Universal Functions (**ufuncs**), comparing their speed and memory efficiency against standard scalar operators.

### 2. The Concept

Think of a **ufunc** as an industrial processing unit built directly into C code. When you apply `np.sin(arr)` or `arr1 + arr2`, NumPy bypasses the Python interpreter's bytecode dispatch loop entirely. It dispatches the work directly to optimized compiled C loops running over contiguous memory blocks.

### 3. The Implementation

Create the file `03_broadcasting_and_math.py` in your project root.

```python
# 03_broadcasting_and_math.py
import time
from typing import Tuple
import numpy as np


def demonstrate_ufuncs() -> Tuple[np.ndarray, np.ndarray]:
    """Demonstrates vectorized Universal Functions (ufuncs) for high-speed computation."""
    print("\n================ 1. UNIVERSAL FUNCTIONS (UFUNCS) ================")

    # Create input array
    angles_deg = np.array([0.0, 30.0, 45.0, 60.0, 90.0], dtype=np.float64)
    print(f"Angles (Degrees): {angles_deg}")

    # Convert degrees to radians using ufunc multiplication
    angles_rad = angles_deg * (np.pi / 180.0)
    print(f"Angles (Radians): {angles_rad}")

    # Apply trigonometric ufunc np.sin()
    sines = np.sin(angles_rad)
    print(f"Sine Values     : {sines}")

    # Apply exponential ufunc np.exp() and logarithmic np.log()
    base_vals = np.array([1.0, 2.0, 4.0, 8.0], dtype=np.float64)
    exponentials = np.exp(base_vals)
    logarithms = np.log(base_vals)

    print(f"\nBase Values     : {base_vals}")
    print(f"Exponentials    : {exponentials}")
    print(f"Natural Logs    : {logarithms}")

    print("=================================================================\n")
    return sines, exponentials


if __name__ == "__main__":
    demonstrate_ufuncs()

```

### 4. The Verification

Execute the module from your terminal:

```bash
python 03_broadcasting_and_math.py

```

**Expected Verification Output:**

```text
================ 1. UNIVERSAL FUNCTIONS (UFUNCS) ================
Angles (Degrees): [ 0. 30. 45. 60. 90.]
Angles (Radians): [0.         0.52359878 0.78539816 1.04719755 1.57079633]
Sine Values     : [0.         0.5        0.70710678 0.8660254  1.        ]

Base Values     : [1. 2. 4. 8.]
Exponentials    : [  2.71828183   7.3890561  +54.59815003 2980.95798704]
Logarithms      : [0.         0.69314718 1.38629436 2.07944154]
=================================================================

```

---

## Step 3.2: The Two Rules of Broadcasting

### 1. The Target

Append a comprehensive broadcasting demonstration to `03_broadcasting_and_math.py` that scales a 1D vector across a 2D matrix without duplicating memory.

### 2. The Concept

How does NumPy decide whether two arrays of different shapes can be operated on together? It applies **The Two Rules of Broadcasting**:

1. **Compare dimensions from right to left:** Align the shape tuples of both arrays starting from the trailing (rightmost) dimension.
2. **Compatibility condition:** Two dimensions are compatible if:
* They are **equal**, OR
* One of them is **1** (the singleton dimension, which stretches to match the other).



If dimensions do not match and neither is 1, NumPy raises a `ValueError: operands could not be broadcast together`.

```
Example: Subtracting a 1D column mean vector from a 2D matrix

Matrix A (Data)     : Shape (3, 3) -> 3 rows, 3 columns
Vector B (Means)    : Shape (3,)   -> Interpreted right-to-left as (1, 3)

Step 1: Align shapes from right to left
  Matrix A: ( 3, 3 )
  Vector B: (    3 )   <-- Missing leading dimension treated as 1 -> (1, 3)

Step 2: Check compatibility rule
  Axis 1: 3 matches 3 (Compatible!)
  Axis 0: 3 matches 1 (Singleton stretches from 1 to 3!)

Resulting Broadcast Shape: (3, 3) [No physical memory duplicated for vector B]

```

### 3. The Implementation

Append the broadcasting function and execution block to `03_broadcasting_and_math.py`:

```python
# Append to 03_broadcasting_and_math.py


def demonstrate_broadcasting_rules() -> None:
    """Demonstrates matrix-vector arithmetic using NumPy broadcasting rules."""
    print("\n================ 2. THE TWO RULES OF BROADCASTING ================")

    # 2D Matrix representing 3 samples (rows) and 3 features (columns)
    data_matrix = np.array([
        [10.0, 20.0, 30.0],
        [40.0, 50.0, 60.0],
        [70.0, 80.0, 90.0]
    ], dtype=np.float64)

    # 1D Vector representing mean values for each of the 3 columns (features)
    feature_means = np.array([40.0, 50.0, 60.0], dtype=np.float64)

    print(f"Data Matrix Shape ({data_matrix.shape}):\n{data_matrix}")
    print(f"Feature Means Shape ({feature_means.shape}): {feature_means}")

    # BROADCASTING OPERATION: Subtract column means from data_matrix
    # feature_means (shape 3,) is virtually stretched across rows to match (3, 3)
    centered_matrix = data_matrix - feature_means

    print(f"\nCentered Matrix (After Broadcasting subtraction):\n{centered_matrix}")

    # Verify that feature_means did not change shape or require memory duplication
    print(f"Feature Means shape remains : {feature_means.shape}")

    print("===================================================================\n")


if __name__ == "__main__":
    demonstrate_broadcasting_rules()

```

### 4. The Verification

Run the updated file:

```bash
python 03_broadcasting_and_math.py

```

**Expected Verification Output:**

```text
================ 2. THE TWO RULES OF BROADCASTING ================
Data Matrix Shape ((3, 3)):
[[10. 20. 30.]
 [40. 50. 60.]
 [70. 80. 90.]]
Feature Means Shape ((3,)): [40. 50. 60.]

Centered Matrix (After Broadcasting subtraction):
[[-30. -30. -30.]
 [  0.   0.   0.]
 [ 30.  30.  30.]]
Feature Means shape remains : (3,)
===================================================================

```

---

## Step 3.3: Dimensional Expansion with `np.newaxis`

### 1. The Target

Add a demonstration of explicit dimensional expansion using `np.newaxis` (an alias for `None`) to `03_broadcasting_and_math.py` to handle ambiguous vector orientations.

### 2. The Concept

Sometimes a 1D array of shape `(N,)` is ambiguous—is it a row vector or a column vector?

When broadcasting requires a specific orientation (for example, subtracting a row vector across columns rather than a column vector across rows), you use `np.newaxis` to explicitly insert a new axis of size $1$, transforming a 1D vector into a 2D column vector of shape `(N, 1)`.

### 3. The Implementation

Append the `np.newaxis` demonstration function to `03_broadcasting_and_math.py`:

```python
# Append to 03_broadcasting_and_math.py


def demonstrate_newaxis_expansion() -> None:
    """Demonstrates explicit dimension insertion using np.newaxis."""
    print("\n================ 3. DIMENSIONAL EXPANSION (NP.NEWAXIS) ================")

    # 1D Vector of 3 row offsets
    row_offsets = np.array([100, 200, 300], dtype=np.int32)
    print(f"Original 1D Row Offsets Shape : {row_offsets.shape} -> {row_offsets}")

    # Convert 1D vector (3,) into a 2D Column Vector (3, 1) using np.newaxis
    column_vector = row_offsets[:, np.newaxis]
    print(f"Expanded Column Vector Shape  : {column_vector.shape}\n{column_vector}")

    # Base 2D Matrix (2 columns)
    base_matrix = np.array([
        [1, 2],
        [3, 4],
        [5, 6]
    ], dtype=np.int32)
    print(f"Base Matrix Shape ({base_matrix.shape}):\n{base_matrix}")

    # Broadcast column vector (3, 1) against base matrix (3, 2)
    # Shape matching: (3, 1) and (3, 2) -> Column stretches across columns!
    result_matrix = base_matrix + column_vector
    print(f"\nResulting Broadcast Matrix Shape ({result_matrix.shape}):\n{result_matrix}")

    print("=======================================================================\n")


if __name__ == "__main__":
    demonstrate_newaxis_expansion()

```

### 4. The Verification

Run the complete executable script:

```bash
python 03_broadcasting_and_math.py

```

**Expected Verification Output:**

```text
================ 3. DIMENSIONAL EXPANSION (NP.NEWAXIS) ================
Original 1D Row Offsets Shape : (3,) -> [100 200 300]
Expanded Column Vector Shape  : (3, 1)
[[100]
 [200]
 [300]]
Base Matrix Shape ((3, 2)):
[[1 2]
 [3 4]
 [5 6]]

Resulting Broadcast Matrix Shape ((3, 2)):
[[101 102]
 [203 204]
 [305 306]]
======================================================================

```

---

## Technical Reference: Broadcasting Dimension Rules Table

When designing broadcasting operations across tensors, keep this exact dimensional alignment guide in mind:

| Array A Shape | Array B Shape | Compatible? | Resultant Broadcast Shape | Reason / Action |
| --- | --- | --- | --- | --- |
| `(3, 3)` | `(3,)` | **Yes** | `(3, 3)` | Array B prepended with virtual leading `1` -> `(1, 3)` becomes `(3, 3)`. |
| `(2, 3, 4)` | `(4,)` | **Yes** | `(2, 3, 4)` | Array B aligned to trailing dimensions `(4,)` matches `4`. |
| `(3, 1)` | `(1, 4)` | **Yes** | `(3, 4)` | Both singleton dimensions stretch: `1` becomes `4` on axis 0, `1` becomes `3` on axis 1. |
| `(3, 3)` | `(2,)` | **No** | *ValueError* | Trailing dimensions `3` and `2` do not match and neither is `1`. |
