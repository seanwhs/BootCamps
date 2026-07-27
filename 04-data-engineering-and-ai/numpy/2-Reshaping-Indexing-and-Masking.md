# Part 2: Reshaping, Indexing, and Masking

Once data is loaded into contiguous memory, the next step in any high-performance data processing pipeline is controlling tensor dimensions and isolating specific subsets of information.

In standard Python, reshaping a nested list requires instantiating new lists and copying values item by item. Filtering a list requires creating a new list via loops or filter functions. In NumPy, you can transform tensor dimensions instantly by modifying array **strides** and metadata without duplicating memory. You can also execute high-speed conditional filtering across millions of records simultaneously using **Boolean masking**.

In this section, we will build our second core module: `02_reshaping_and_masking.py`.

---

## Step 2.1: Zero-Copy Reshaping and Transposition Operations

### 1. The Target

We will construct a set of transformation tools that alter array shapes, flatten multi-dimensional structures, and swap axes using zero-copy metadata operations (`reshape`, `ravel`, `flatten`, `T`, and `swapaxes`).

### 2. The Concept

Think of a row of $12$ storage lockers along a hallway.

* **`reshape(3, 4)`**: You place visual markers dividing the single row of $12$ lockers into $3$ virtual sections with $4$ lockers each. The physical lockers do not move; only your mapping grid changes.
* **`ravel()` vs. `flatten()**`: `ravel()` gives you a simplified 1D map pointing directly back to the original lockers (**View**). `flatten()` physically duplicates every item from the lockers into $12$ brand-new individual boxes on another floor (**Deep Copy**).
* **Transposition (`.T` / `swapaxes`)**: Reverses how you walk through the building—instead of reading floor-by-floor (row-major), you read column-by-column across floors by swapping the stride values.

### 3. The Implementation

Create the file `02_reshaping_and_masking.py` in your project root.

```python
# 02_reshaping_and_masking.py
from typing import Tuple
import numpy as np


def demonstrate_reshaping_mechanics() -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Demonstrates tensor shape manipulation and memory view preservation.

    Returns:
        Tuple containing (reshaped_2d, flattened_view, flattened_copy)
    """
    print("\n================ 1. RESHAPING & FLATTENING MECHANICS ================")

    # 1D Array of 12 elements
    arr_1d = np.arange(12, dtype=np.int32)
    print(f"Original 1D Array (Shape: {arr_1d.shape}):\n{arr_1d}")

    # Reshape to 2D matrix (3 rows, 4 columns) without memory allocation
    # The '-1' dimension tells NumPy to infer the dimension automatically
    reshaped_2d = arr_1d.reshape(3, -1)
    print(f"\nReshaped 2D Matrix (3x4) (Shares memory? {reshaped_2d.base is arr_1d}):\n{reshaped_2d}")

    # np.ravel() creates a 1D VIEW pointing back to original memory
    flattened_view = reshaped_2d.ravel()
    
    # arr.flatten() creates a 1D DEEP COPY allocating new memory
    flattened_copy = reshaped_2d.flatten()

    # Verify view vs copy memory allocation
    print(f"\nravel() Base points to original?   : {flattened_view.base is arr_1d}")
    print(f"flatten() Base points to original? : {flattened_copy.base is arr_1d}")

    # Mutate original to demonstrate view coupling
    arr_1d[0] = 999
    print(f"\nAfter modifying arr_1d[0] = 999:")
    print(f"reshaped_2d[0,0]      : {reshaped_2d[0, 0]} (Updated!)")
    print(f"flattened_view[0]     : {flattened_view[0]} (Updated!)")
    print(f"flattened_copy[0]     : {flattened_copy[0]} (Unchanged)")

    print("====================================================================\n")
    return reshaped_2d, flattened_view, flattened_copy


def demonstrate_transposition_and_axes() -> None:
    """Demonstrates matrix transposition (.T) and arbitrary axis swapping."""
    print("\n================ 2. TRANSPOSITION & AXIS SWAPPING ================")

    # Create a 3D Tensor with shape (2, 3, 4) -> (Depth, Rows, Cols)
    tensor_3d = np.arange(24, dtype=np.int32).reshape(2, 3, 4)
    print(f"Original 3D Tensor Shape : {tensor_3d.shape}")
    print(f"Original Strides         : {tensor_3d.strides}")

    # Transpose matrix (.T reverses the shape and strides axes)
    transposed = tensor_3d.T
    print(f"\nTransposed (.T) Shape    : {transposed.shape}")
    print(f"Transposed Strides       : {transposed.strides}")
    print(f"Shares memory with base? : {transposed.base is tensor_3d}")

    # Explicit axis swapping: Swap Axis 0 (Depth) and Axis 2 (Columns)
    swapped = np.swapaxes(tensor_3d, axis1=0, axis2=2)
    print(f"\nSwapped Axes (0, 2) Shape: {swapped.shape}")
    print(f"Swapped Strides          : {swapped.strides}")

    print("==================================================================\n")


if __name__ == "__main__":
    demonstrate_reshaping_mechanics()
    demonstrate_transposition_and_axes()

```

### 4. The Verification

Execute the module from your terminal:

```bash
python 02_reshaping_and_masking.py

```

**Expected Verification Output:**

```text
================ 1. RESHAPING & FLATTENING MECHANICS ================
Original 1D Array (Shape: (12,)):
[ 0  1  2  3  4  5  6  7  8  9 10 11]

Reshaped 2D Matrix (3x4) (Shares memory? True):
[[ 0  1  2  3]
 [ 4  5  6  7]
 [ 8  9 10 11]]

ravel() Base points to original?   : True
flatten() Base points to original? : False

After modifying arr_1d[0] = 999:
reshaped_2d[0,0]      : 999 (Updated!)
flattened_view[0]     : 999 (Updated!)
flattened_copy[0]     : 0 (Unchanged)
====================================================================


================ 2. TRANSPOSITION & AXIS SWAPPING ================
Original 3D Tensor Shape : (2, 3, 4)
Original Strides         : (48, 16, 4)

Transposed (.T) Shape    : (4, 3, 2)
Transposed Strides       : (4, 16, 48)
Shares memory with base? : True

Swapped Axes (0, 2) Shape: (4, 3, 2)
Swapped Strides          : (4, 16, 48)
==================================================================

```

Notice how `.T` transforms strides from `(48, 16, 4)` to `(4, 16, 48)` instantly without copying or reordering any underlying byte data in RAM!

---

## Step 2.2: Stacking and Splitting Multi-Dimensional Arrays

### 1. The Target

Append utilities to `02_reshaping_and_masking.py` for combining multiple sub-arrays into a single consolidated tensor (`concatenate`, `vstack`, `hstack`) and dividing arrays into multiple chunks (`split`, `vsplit`, `hsplit`).

### 2. The Concept

* **Stacking (`vstack` / `hstack`)**: Think of stacking physical spreadsheets. `vstack` (vertical stack) stacks pages on top of each other like adding more rows to a table. `hstack` (horizontal stack) tapes pages side-by-side to add more columns.
* **Splitting (`vsplit` / `hsplit`)**: Taking a long paper report and using scissors to cut it horizontally into multi-page sections or vertically into isolated column strips.

### 3. The Implementation

Append the following combination functions to `02_reshaping_and_masking.py`:

```python
# Append to 02_reshaping_and_masking.py


def demonstrate_array_combining_and_splitting() -> None:
    """Demonstrates joining and dividing arrays across vertical and horizontal axes."""
    print("\n================ 3. COMBINING & SPLITTING ARRAYS ================")

    matrix_a = np.array([[1, 2, 3], [4, 5, 6]], dtype=np.int32)
    matrix_b = np.array([[7, 8, 9], [10, 11, 12]], dtype=np.int32)

    print(f"Matrix A (2x3):\n{matrix_a}")
    print(f"Matrix B (2x3):\n{matrix_b}")

    # Vertical Stack (Row-wise concatenation along axis 0) -> Output shape (4, 3)
    v_stacked = np.vstack((matrix_a, matrix_b))
    print(f"\nnp.vstack (Rows Concatenated) Shape {v_stacked.shape}:\n{v_stacked}")

    # Horizontal Stack (Column-wise concatenation along axis 1) -> Output shape (2, 6)
    h_stacked = np.hstack((matrix_a, matrix_b))
    print(f"\nnp.hstack (Columns Concatenated) Shape {h_stacked.shape}:\n{h_stacked}")

    # Splitting arrays back into chunks
    # vsplit divides a matrix into N sub-arrays along axis 0
    top_half, bottom_half = np.vsplit(v_stacked, 2)
    print(f"\nnp.vsplit Top Half:\n{top_half}")
    print(f"np.vsplit Bottom Half:\n{bottom_half}")

    print("=================================================================\n")


if __name__ == "__main__":
    demonstrate_array_combining_and_splitting()

```

### 4. The Verification

Run the updated file:

```bash
python 02_reshaping_and_masking.py

```

**Expected Verification Output:**

```text
================ 3. COMBINING & SPLITTING ARRAYS ================
Matrix A (2x3):
[[1 2 3]
 [4 5 6]]
Matrix B (2x3):
[[ 7  8  9]
 [10 11 12]]

np.vstack (Rows Concatenated) Shape (4, 3):
[[ 1  2  3]
 [ 4  5  6]
 [ 7  8  9]
 [10 11 12]]

np.hstack (Columns Concatenated) Shape (2, 6):
[[ 1  2  3  7  8  9]
 [ 4  5  6 10 11 12]]

np.vsplit Top Half:
[[1 2 3]
 [4 5 6]]
np.vsplit Bottom Half:
[[ 7  8  9]
 [10 11 12]]
=================================================================

```

---

## Step 2.3: High-Speed Boolean Masking and Fancy Indexing

### 1. The Target

Implement advanced conditional filtering pipeline operations in `02_reshaping_and_masking.py` utilizing **Boolean Masking** (bitwise conditions) and **Fancy Indexing** (selecting non-contiguous elements via integer coordinate arrays).

### 2. The Concept

* **Boolean Masking**: Imagine laying a perforated metal stencil over a grid of numbers. If an element meets a condition (e.g., $x > 50$), the stencil hole stays open (`True`); otherwise, it remains closed (`False`). Pouring paint over the stencil exposes only the matching values.
> **Crucial Rule:** Standard Python logical operators (`and`, `or`, `not`) evaluate the truthiness of an entire object as a single boolean value. In NumPy, you MUST use bitwise operators (`&`, `|`, `~`) to perform element-wise logical operations across boolean arrays, wrapping each conditional clause in parentheses `()`.


* **Fancy Indexing**: Passing an array of explicit row and column coordinate indices to extract arbitrary elements. Unlike slicing, fancy indexing **always returns a deep copy** of the data because extracted elements are non-contiguous in memory.

### 3. The Implementation

Append the masking and indexing suite to `02_reshaping_and_masking.py`:

```python
# Append to 02_reshaping_and_masking.py


def demonstrate_boolean_masking_and_fancy_indexing() -> None:
    """Demonstrates vectorized conditional filtering and integer array selection."""
    print("\n================ 4. BOOLEAN MASKING & FANCY INDEXING ================")

    # Synthetic Dataset: 10 synthetic temperature readings
    temperatures = np.array([18.5, 22.0, 35.4, 14.1, 29.8, 41.2, 26.5, 12.0, 38.0, 21.3])
    print(f"Temperatures (°C): {temperatures}")

    # 1. Create a Boolean Mask: Identify extreme heat (>30°C) AND moderate warmth (>20°C)
    # MUST use bitwise operators & and wrap conditions in parentheses ()
    heat_mask = (temperatures > 20.0) & (temperatures < 40.0)
    print(f"\nBoolean Mask (20 < T < 40) dtype={heat_mask.dtype}:\n{heat_mask}")

    # Extract elements matching True condition
    filtered_temps = temperatures[heat_mask]
    print(f"Filtered Values: {filtered_temps}")

    # Conditional Mutation using mask: Cap all values > 35.0 to 35.0 in-place
    temperatures[temperatures > 35.0] = 35.0
    print(f"Temperatures after Capping (>35.0 = 35.0):\n{temperatures}")

    # 2. Fancy Indexing (Selecting specific non-contiguous elements)
    data_grid = np.array([
        [10, 20, 30],
        [40, 50, 60],
        [70, 80, 90]
    ], dtype=np.int32)

    # Coordinates to extract: (row 0, col 2), (row 1, col 0), (row 2, col 1)
    row_indices = np.array([0, 1, 2])
    col_indices = np.array([2, 0, 1])

    fancy_extracted = data_grid[row_indices, col_indices]
    print(f"\nData Grid:\n{data_grid}")
    print(f"Fancy Indexing Extracted Elements [ (0,2), (1,0), (2,1) ]: {fancy_extracted}")
    print(f"Does fancy indexing share memory? : {fancy_extracted.base is data_grid}")

    print("=====================================================================\n")


if __name__ == "__main__":
    demonstrate_boolean_masking_and_fancy_indexing()

```

### 4. The Verification

Run the entire pipeline:

```bash
python 02_reshaping_and_masking.py

```

**Expected Verification Output:**

```text
================ 4. BOOLEAN MASKING & FANCY INDEXING ================
Temperatures (°C): [18.5 22.  35.4 14.1 29.8 41.2 26.5 12.  38.  21.3]

Boolean Mask (20 < T < 40) dtype=bool:
[False  True  True False  True False  True False  True  True]
Filtered Values: [22.  35.4 29.8 26.5 38.  21.3]
Temperatures after Capping (>35.0 = 35.0):
[18.5 22.  35.  14.1 29.8 35.  26.5 12.  35.  21.3]

Data Grid:
[[10 20 30]
 [40 50 60]
 [70 80 90]]
Fancy Indexing Extracted Elements [ (0,2), (1,0), (2,1) ]: [30 40 80]
Does fancy indexing share memory? : False
=====================================================================

```

---

## Technical Reference: Views vs. Copies in Indexing Operations

Understanding when NumPy returns a zero-copy **View** versus a memory-allocated **Copy** is essential to preventing unexpected bugs and optimizing memory footprint in large applications.

| Indexing Operation | Syntax Example | Return Type | Shares Parent Memory? | Modifying Mutates Original? |
| --- | --- | --- | --- | --- |
| **Basic Slice** | `arr[1:5]` | **View** | Yes (`arr[1:5].base is arr`) | **Yes** |
| **Multi-Dim Slice** | `arr[0:2, 1:3]` | **View** | Yes | **Yes** |
| **Reshaped View** | `arr.reshape(2, 3)` | **View** | Yes | **Yes** |
| **Transposed View** | `arr.T` | **View** | Yes | **Yes** |
| **Boolean Masking** | `arr[arr > 5]` | **Deep Copy** | No (`base is None`) | **No** |
| **Fancy Indexing** | `arr[[0, 2], [1, 3]]` | **Deep Copy** | No | **No** |
| **Explicit `.copy()**` | `arr[1:5].copy()` | **Deep Copy** | No | **No** |

### Why Fancy Indexing and Masking Require Deep Copies

Slicing works by adjusting stride values and starting byte offsets across regular memory intervals.

However, when you perform Boolean masking or pass arbitrary integer coordinate arrays, the matching elements are often scattered non-contiguously throughout RAM. Because a single `ndarray` view can only exist if elements follow a uniform stride pattern across memory, NumPy must copy the non-contiguous values into a brand-new contiguous memory buffer.
