# Part 1: The Foundation — Arrays, Memory, and Vectorization

In standard Python, a list is not a contiguous block of data; it is a array of pointers pointing to scattered objects in memory. When you iterate through a Python list, your CPU is forced to chase these pointers across system memory, invalidating CPU caches and executing dynamic type checks at every step.

NumPy's core object, the `ndarray` (N-dimensional array), solves this bottleneck. It stores data in a **single, contiguous block of RAM** with a fixed data type. This allows your CPU to load data directly into high-speed L1/L2 caches and process multiple data points simultaneously using SIMD (Single Instruction, Multiple Data) vector instructions.

In this section, we will build the core foundational module of our library: `01_foundation.py`.

---

## Step 1.1: Constructing the Memory Inspector & Array Factory

### 1. The Target

We will build a module that exposes helper functions to inspect the underlying memory metadata of any NumPy array (data pointer, shape, strides, data type, item size, and total byte footprint) and factory routines for creating structured arrays.

### 2. The Concept

Think of a standard Python list as a box containing slip pieces of paper, where each paper has an address pointing to a house somewhere else in town. Finding a value requires walking to that specific house.

A NumPy `ndarray` is like a continuous row of identical apartment units built right next to each other along a single street. The "Memory Inspector" function reads the blueprints of this apartment complex:

* **`shape`**: How many floors and units per floor exist.
* **`dtype`**: The standard size and layout of every apartment.
* **`strides`**: Exactly how many steps down the hallway you must take to get from one unit to the next.

### 3. The Implementation

Create the file `01_foundation.py` in your project root.

```python
# 01_foundation.py
import sys
import time
from typing import Any, Dict, Tuple
import numpy as np


def inspect_array_memory(arr: np.ndarray, label: str = "Array") -> Dict[str, Any]:
    """Inspects and returns the low-level memory metadata of a NumPy ndarray.

    Args:
        arr: The NumPy array to inspect.
        label: A human-readable label for debugging output.

    Returns:
        A dictionary containing critical memory layout parameters.
    """
    metadata = {
        "label": label,
        "shape": arr.shape,
        "ndim": arr.ndim,
        "dtype": arr.dtype,
        "itemsize_bytes": arr.itemsize,
        "total_bytes": arr.nbytes,
        "strides_bytes": arr.strides,
        "is_c_contiguous": arr.flags["C_CONTIGUOUS"],
        "is_f_contiguous": arr.flags["F_CONTIGUOUS"],
        "data_pointer_address": hex(arr.ctypes.data),
    }

    print(f"\n--- MEMORY INSPECTION: {label} ---")
    print(f"Shape               : {metadata['shape']}")
    print(f"Dimensions (ndim)   : {metadata['ndim']}")
    print(f"Data Type (dtype)   : {metadata['dtype']}")
    print(f"Item Size           : {metadata['itemsize_bytes']} bytes")
    print(f"Total Footprint     : {metadata['total_bytes']} bytes")
    print(f"Strides             : {metadata['strides_bytes']}")
    print(f"C-Contiguous        : {metadata['is_c_contiguous']}")
    print(f"Fortran-Contiguous  : {metadata['is_f_contiguous']}")
    print(f"Data Pointer        : {metadata['data_pointer_address']}")
    print("-" * 40)

    return metadata


def create_array_zoo() -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Demonstrates standard array instantiation factory functions.

    Returns:
        Tuple containing zero_arr, ones_arr, range_arr, linspace_arr.
    """
    # np.zeros: Allocates memory filled with 64-bit float zeros
    zero_arr = np.zeros(shape=(3, 4), dtype=np.float64)

    # np.ones: Allocates memory filled with 32-bit signed integer ones
    ones_arr = np.ones(shape=(2, 5), dtype=np.int32)

    # np.arange: Generates start-stop sequence with a fixed step size
    range_arr = np.arange(start=0, stop=10, step=2, dtype=np.int64)

    # np.linspace: Generates N evenly spaced numbers over a specified interval [start, stop]
    linspace_arr = np.linspace(start=0.0, stop=1.0, num=5, endpoint=True)

    return zero_arr, ones_arr, range_arr, linspace_arr


if __name__ == "__main__":
    z, o, r, l = create_array_zoo()
    inspect_array_memory(z, label="Zeros (3x4 float64)")
    inspect_array_memory(o, label="Ones (2x5 int32)")
    inspect_array_memory(r, label="Arange (0..10 step 2 int64)")
    inspect_array_memory(l, label="Linspace (0..1 num 5 float64)")

```

### 4. The Verification

Execute the script from your command line:

```bash
python 01_foundation.py

```

**Expected Verification Output:**

```text
--- MEMORY INSPECTION: Zeros (3x4 float64) ---
Shape               : (3, 4)
Dimensions (ndim)   : 2
Data Type (dtype)   : float64
Item Size           : 8 bytes
Total Footprint     : 96 bytes
Strides             : (32, 8)
C-Contiguous        : True
Fortran-Contiguous  : False
Data Pointer        : 0x...
----------------------------------------

--- MEMORY INSPECTION: Ones (2x5 int32) ---
Shape               : (2, 5)
Dimensions (ndim)   : 2
Data Type (dtype)   : int32
Item Size           : 4 bytes
Total Footprint     : 40 bytes
Strides             : (20, 4)
C-Contiguous        : True
Fortran-Contiguous  : False
Data Pointer        : 0x...
----------------------------------------
...

```

Notice how `strides` works in `Zeros (3x4 float64)`: each `float64` takes 8 bytes. A row has 4 elements, so moving down 1 row requires jumping $4 \times 8 = 32$ bytes in RAM, while moving across 1 column requires jumping 8 bytes. Thus, strides are `(32, 8)`.

---

## Step 1.2: Benchmarking Vectorization vs. Standard Python Loops

### 1. The Target

Append a performance benchmarking suite to `01_foundation.py` that computes element-wise mathematical operations across 10 million floating-point numbers using both standard Python `for` loops/list comprehensions and NumPy vectorized operations.

### 2. The Concept

Imagine you have a stack of 10 million physical letters that need a rubber stamp.

* **Python Loop:** A single worker picks up a letter, opens the envelope, checks what kind of paper it is, stamps it, puts it down, and repeats this process 10 million times.
* **Vectorized NumPy:** A industrial machine loads 1,000 letters per conveyor belt cycle and stamps them all in a single sweep using automated hardware parallelism.

### 3. The Implementation

Append the following benchmark function and execution block to `01_foundation.py`:

```python
# Append to 01_foundation.py


def benchmark_vectorization_vs_python(num_elements: int = 10_000_000) -> None:
    """Compares execution time and performance of standard Python lists vs. NumPy arrays.

    Performs the operation: y = 2.5 * x + 1.0 on N elements.
    """
    print(
        f"\n================ BENCHMARK: {num_elements:,} ELEMENTS ================"
    )

    # --- Standard Python List Setup ---
    python_list_x = [float(i) for i in range(num_elements)]

    # Time Python List loop execution
    start_time = time.perf_counter()
    python_list_y = [2.5 * x + 1.0 for x in python_list_x]
    python_duration = time.perf_counter() - start_time

    # --- NumPy Vectorized Array Setup ---
    numpy_arr_x = np.arange(num_elements, dtype=np.float64)

    # Time NumPy Vectorized execution
    start_time = time.perf_counter()
    numpy_arr_y = 2.5 * numpy_arr_x + 1.0
    numpy_duration = time.perf_counter() - start_time

    # --- Calculate Speedup ---
    speedup = python_duration / numpy_duration if numpy_duration > 0 else 0.0

    print(f"Python List Loop Execution Time : {python_duration:.6f} seconds")
    print(f"NumPy Vectorized Execution Time  : {numpy_duration:.6f} seconds")
    print(f"Performance Speedup Factor      : {speedup:.2f}x faster")
    print("=================================================================\n")


# Add execution to main block if running directly
if __name__ == "__main__":
    benchmark_vectorization_vs_python(num_elements=10_000_000)

```

### 4. The Verification

Run the updated file:

```bash
python 01_foundation.py

```

**Expected Verification Output:**

```text
================ BENCHMARK: 10,000,000 ELEMENTS ================
Python List Loop Execution Time : 0.650000 to 1.100000 seconds
NumPy Vectorized Execution Time  : 0.010000 to 0.025000 seconds
Performance Speedup Factor      : 40.00x to 70.00x faster
=================================================================

```

---

## Step 1.3: Slicing Mechanics — Views vs. Deep Copies

### 1. The Target

Add a core utility to `01_foundation.py` demonstrating the critical memory difference between slicing an array (which creates a zero-copy **View**) and using explicit `.copy()` or boolean selections (which create a **Deep Copy**).

### 2. The Concept

* **A View (`slice`)**: Think of a slice as a pair of special color-tinted glasses pointing at a specific section of a painting on the wall. If someone paints over that section of the canvas, anyone wearing the glasses sees the change immediately because no new canvas was created.
* **A Copy (`.copy()`)**: Think of a copy as taking a physical photograph of the painting, putting it on a separate desk, and drawing on the photograph. The original painting on the wall remains unchanged.

In NumPy, slicing `arr[0:5]` creates a view with **zero memory overhead**. Modifying a view mutates the original parent array!

### 3. The Implementation

Append the following function to `01_foundation.py`:

```python
# Append to 01_foundation.py


def demonstrate_views_vs_copies() -> None:
    """Demonstrates the mutation behavior of NumPy views vs. explicit deep copies."""
    print("\n================ VIEWS VS DEEP COPIES ================")

    # Create base array
    original = np.array([10, 20, 30, 40, 50], dtype=np.int32)
    print(f"Original Array Initial       : {original}")

    # --- SLICING CREATES A VIEW ---
    view_slice = original[1:4]  # Elements 20, 30, 40
    print(f"Slice View Initial           : {view_slice}")

    # Verify memory sharing using base attribute
    print(
        f"Does view_slice share memory?: {view_slice.base is original}"
    )  # Should be True

    # Mutate the view slice
    view_slice[0] = 999
    print(f"Slice View After Mutation    : {view_slice}")
    print(
        f"Original Array After View Mod: {original}"
    )  # Original array changed!

    # --- EXPLICIT .copy() CREATES A DEEP COPY ---
    deep_copy = original[1:4].copy()
    print(f"\nDeep Copy Initial            : {deep_copy}")
    print(
        f"Does deep_copy share memory? : {deep_copy.base is original}"
    )  # Should be False

    # Mutate the deep copy
    deep_copy[0] = -777
    print(f"Deep Copy After Mutation     : {deep_copy}")
    print(
        f"Original Array After Copy Mod: {original}"
    )  # Original array UNCHANGED!

    print("=====================================================\n")


if __name__ == "__main__":
    demonstrate_views_vs_copies()

```

### 4. The Verification

Run the combined executable script:

```bash
python 01_foundation.py

```

**Expected Verification Output:**

```text
================ VIEWS VS DEEP COPIES ================
Original Array Initial       : [10 20 30 40 50]
Slice View Initial           : [20 30 40]
Does view_slice share memory?: True
Slice View After Mutation    : [999  30  40]
Original Array After View Mod: [10 999  30  40  50]

Deep Copy Initial            : [999  30  40]
Does deep_copy share memory? : False
Deep Copy After Mutation     : [-777   30   40]
Original Array After Copy Mod: [10 999  30  40  50]
=====================================================

```

---

## Technical Deep Dive: Strides and C vs. Fortran Memory Ordering

To write high-performance numerical routines, you must understand how multi-dimensional structures map to 1D physical RAM.

Memory in computer hardware is addressed sequentially from byte $0$ to byte $N$. An $M \times N$ matrix cannot exist as a physical grid in RAM; it must be flattened into a linear sequence.

```
Logical 2D Grid (2 rows, 3 columns):
  [[A, B, C],
   [D, E, F]]

Physical 1D RAM Allocation Options:

1. Row-Major Order (C-Style, Default in NumPy):
   [ A ][ B ][ C ][ D ][ E ][ F ]
   Byte 0                        Byte 24

2. Column-Major Order (Fortran-Style):
   [ A ][ D ][ B ][ E ][ C ][ F ]
   Byte 0                        Byte 24

```

### The Stride Calculation Formula

The `strides` tuple dictates how many bytes the memory pointer must skip to advance by 1 element along axis $k$.

For a 2D array of shape $(R, C)$ with element itemsize $S$ bytes:

* **C-Contiguous (Row-Major):**

$$\text{Strides} = (C \times S, S)$$



To advance down 1 row, you must skip past $C$ items, each taking $S$ bytes.
* **Fortran-Contiguous (Column-Major):**

$$\text{Strides} = (S, R \times S)$$



To advance down 1 column, you skip 1 element ($S$ bytes). To advance across 1 row, you skip past an entire column of $R$ items ($R \times S$ bytes).

### Memory Contiguity Performance Impact

When processing an array along a specific axis, traversing along contiguous memory addresses allows CPU hardware prefetchers to load entire cache lines (typically 64 bytes) ahead of time. Iterating across non-contiguous strides causes cache misses, reducing execution speed.
