# Primer 2: NumPy Fundamentals for Data Analysis

## Essential NumPy Concepts for Data Science and Visualization

---

#### Purpose of This Primer

NumPy (Numerical Python) is the foundation of the Python data science ecosystem. Pandas, Matplotlib, Scikit-learn, and many other libraries are built on NumPy. Understanding NumPy is essential for:

- Efficient numerical computations
- Understanding how pandas and other libraries work under the hood
- Optimizing performance-critical code
- Working with multi-dimensional data

This primer covers the NumPy concepts you'll encounter throughout the series.

---

## P2.1 NumPy Basics

### P2.1.1 Why NumPy?

```python
import numpy as np
import time

# Python lists vs NumPy arrays
python_list = list(range(1000000))
numpy_array = np.arange(1000000)

# Memory comparison
import sys
print(f"Python list: {sys.getsizeof(python_list) / 1024**2:.2f} MB")
print(f"NumPy array: {numpy_array.nbytes / 1024**2:.2f} MB")

# Speed comparison
start = time.time()
result = [x**2 for x in python_list]
print(f"List comprehension: {time.time() - start:.4f}s")

start = time.time()
result = numpy_array ** 2
print(f"NumPy vectorization: {time.time() - start:.4f}s")
```

### P2.1.2 Creating Arrays

```python
import numpy as np

# From Python lists
arr = np.array([1, 2, 3, 4, 5])

# From ranges
arr_range = np.arange(10)           # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
arr_range_step = np.arange(0, 10, 2)  # [0, 2, 4, 6, 8]

# Linearly spaced
arr_linspace = np.linspace(0, 1, 5)  # [0.0, 0.25, 0.5, 0.75, 1.0]

# Zeros, ones, and constants
zeros = np.zeros((3, 4))              # 3x4 array of zeros
ones = np.ones((2, 3))                # 2x3 array of ones
eye = np.eye(4)                       # 4x4 identity matrix
constant = np.full((3, 3), 5)         # 3x3 array filled with 5

# Random arrays
np.random.seed(42)                    # For reproducibility
random_uniform = np.random.rand(3, 4)  # Uniform [0, 1)
random_normal = np.random.randn(3, 4)  # Standard normal
random_integers = np.random.randint(0, 10, (3, 4))  # Integers [0, 10)

# Empty arrays (uninitialized)
empty = np.empty((2, 3))  # Contains whatever is in memory
```

### P2.1.3 Array Attributes

```python
arr = np.array([[1, 2, 3, 4],
                [5, 6, 7, 8],
                [9, 10, 11, 12]])

print(f"Shape: {arr.shape}")          # (3, 4)
print(f"Dimensions: {arr.ndim}")      # 2
print(f"Size: {arr.size}")            # 12
print(f"Dtype: {arr.dtype}")          # int64
print(f"Itemsize: {arr.itemsize}")    # 8 (bytes per element)
print(f"Nbytes: {arr.nbytes}")        # 96 (total bytes)
```

---

## P2.2 Array Operations

### P2.2.1 Element-wise Operations (Broadcasting)

```python
arr = np.array([1, 2, 3, 4, 5])

# Arithmetic operations
arr + 10           # [11, 12, 13, 14, 15]
arr * 2            # [2, 4, 6, 8, 10]
arr ** 2           # [1, 4, 9, 16, 25]
1 / arr            # [1.0, 0.5, 0.333, 0.25, 0.2]

# Universal functions (ufuncs)
np.sqrt(arr)       # [1.0, 1.414, 1.732, 2.0, 2.236]
np.exp(arr)        # [2.718, 7.389, 20.085, 54.598, 148.413]
np.log(arr)        # [0.0, 0.693, 1.099, 1.386, 1.609]
np.sin(arr)        # Sine of each element

# Comparison operations
arr > 3            # [False, False, False, True, True]
arr == 3           # [False, False, True, False, False]
np.where(arr > 3, 'High', 'Low')  # ['Low', 'Low', 'Low', 'High', 'High']
```

### P2.2.2 Matrix Operations

```python
# Dot product (matrix multiplication)
a = np.array([[1, 2],
              [3, 4]])
b = np.array([[5, 6],
              [7, 8]])

a @ b              # Matrix multiplication (Python 3.5+)
np.dot(a, b)       # Same as above

# Matrix transpose
a.T                # [[1, 3], [2, 4]]

# Matrix inverse (requires square matrix)
np.linalg.inv(a)   # Inverse of a

# Determinant
np.linalg.det(a)   # Determinant

# Eigenvalues and eigenvectors
eigenvalues, eigenvectors = np.linalg.eig(a)

# Solving linear equations
x = np.linalg.solve(a, np.array([1, 2]))  # Solve a*x = b
```

### P2.2.3 Broadcasting Rules

```python
# Broadcasting: operations on arrays of different shapes
a = np.array([[1, 2, 3],
              [4, 5, 6]])  # shape (2, 3)

b = np.array([10, 20, 30])  # shape (3,)

a + b  # [[11, 22, 33], [14, 25, 36]]
# b is broadcast to shape (2, 3) automatically

# Broadcasting with scalar
a + 10  # [[11, 12, 13], [14, 15, 16]]

# Broadcasting dimensions must be compatible
# Rule: When comparing shapes, dimensions must be equal or one must be 1
c = np.array([[1], [2], [3]])  # shape (3, 1)
d = np.array([4, 5, 6])         # shape (3,)
c + d  # [[5, 6, 7], [6, 7, 8], [7, 8, 9]]
```

---

## P2.3 Indexing and Slicing

### P2.3.1 Basic Indexing

```python
# 1D arrays
arr = np.array([10, 20, 30, 40, 50])
arr[0]       # 10
arr[-1]      # 50
arr[1:4]     # [20, 30, 40] (index 1 to 3)
arr[:3]      # [10, 20, 30]
arr[3:]      # [40, 50]
arr[::2]     # [10, 30, 50] (every other)

# 2D arrays
arr2d = np.array([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]])

arr2d[0, 0]      # 1
arr2d[1, :]      # [4, 5, 6] (row 1, all columns)
arr2d[:, 1]      # [2, 5, 8] (all rows, column 1)
arr2d[0:2, 1:3]  # [[2, 3], [5, 6]] (rows 0-1, columns 1-2)
```

### P2.3.2 Fancy Indexing

```python
arr = np.array([10, 20, 30, 40, 50])

# Integer array indexing
indices = [0, 2, 4]
arr[indices]       # [10, 30, 50]

# Boolean indexing
mask = arr > 30
arr[mask]          # [40, 50]

# Combined conditions
mask = (arr > 20) & (arr < 50)
arr[mask]          # [30, 40]

# np.where for conditional selection
arr[np.where(arr > 30)]  # [40, 50]

# Complex 2D indexing
arr2d = np.array([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]])

# Get diagonal
arr2d[[0, 1, 2], [0, 1, 2]]  # [1, 5, 9]

# Arbitrary selection
row_indices = [0, 1, 2]
col_indices = [1, 0, 2]
arr2d[row_indices, col_indices]  # [2, 4, 9]
```

### P2.3.3 Views vs Copies

```python
arr = np.array([1, 2, 3, 4, 5])

# Slicing creates a view (not a copy)
slice_view = arr[1:4]
slice_view[0] = 100  # Modifies original arr!
print(arr)           # [1, 100, 3, 4, 5]

# Fancy indexing creates a copy
fancy_copy = arr[[1, 2, 3]]
fancy_copy[0] = 200  # Does NOT modify original arr
print(arr)           # [1, 100, 3, 4, 5] (unchanged)

# Explicit copy
explicit_copy = arr.copy()
explicit_copy[0] = 999  # Does NOT modify original
```

---

## P2.4 Array Manipulation

### P2.4.1 Reshaping and Resizing

```python
# Reshape (must have same number of elements)
arr = np.arange(12)
arr.reshape(3, 4)       # 3x4
arr.reshape(4, 3)       # 4x3
arr.reshape(2, -1)      # -1 auto-calculates: 2x6

# Flatten
arr2d = np.array([[1, 2, 3],
                  [4, 5, 6]])
arr2d.ravel()            # [1, 2, 3, 4, 5, 6] (view)
arr2d.flatten()          # [1, 2, 3, 4, 5, 6] (copy)

# Resize (changes shape, can add/remove elements)
arr.resize(2, 6)         # Changes array in-place to 2x6

# Newaxis to add dimension
arr = np.array([1, 2, 3])
arr[:, np.newaxis]       # [[1], [2], [3]] (column vector)
arr[np.newaxis, :]       # [[1, 2, 3]] (row vector)
```

### P2.4.2 Concatenation and Splitting

```python
# Concatenation
a = np.array([[1, 2], [3, 4]])
b = np.array([[5, 6], [7, 8]])

np.concatenate((a, b), axis=0)  # Vertical stack
np.concatenate((a, b), axis=1)  # Horizontal stack

# Stacking
np.vstack((a, b))         # Stack vertically
np.hstack((a, b))         # Stack horizontally
np.dstack((a, b))         # Stack depth-wise

# Splitting
arr = np.arange(12)
np.split(arr, 3)          # [0-3], [4-7], [8-11]
np.split(arr, [3, 6])     # [0-2], [3-5], [6-11]
np.vsplit(arr2d, 2)       # Split rows
np.hsplit(arr2d, 2)       # Split columns
```

### P2.4.3 Transposing and Swapping Axes

```python
arr2d = np.array([[1, 2, 3],
                  [4, 5, 6]])

arr2d.T                   # Transpose: [[1, 4], [2, 5], [3, 6]]
arr2d.transpose()         # Same

# For multi-dimensional arrays
arr3d = np.arange(24).reshape(2, 3, 4)
arr3d.transpose(1, 0, 2)  # New axis order: (rows, depth, cols)
arr3d.swapaxes(0, 1)      # Swap axis 0 and 1
```

---

## P2.5 Statistical Operations

### P2.5.1 Basic Statistics

```python
arr = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

# Summary statistics
np.mean(arr)          # 5.5
np.median(arr)        # 5.5
np.std(arr)           # 2.87 (population std)
np.var(arr)           # 8.25 (population variance)
np.min(arr)           # 1
np.max(arr)           # 10
np.ptp(arr)           # 9 (range: max - min)
np.percentile(arr, 25)  # 3.25 (25th percentile)
np.percentile(arr, 75)  # 7.75 (75th percentile)

# Mean with axis (for 2D)
arr2d = np.array([[1, 2, 3],
                  [4, 5, 6],
                  [7, 8, 9]])
np.mean(arr2d, axis=0)  # [4, 5, 6] (mean of each column)
np.mean(arr2d, axis=1)  # [2, 5, 8] (mean of each row)

# Weighted average
np.average(arr, weights=np.array([1, 1, 1, 1, 1, 2, 2, 2, 2, 2]))
```

### P2.5.2 Advanced Statistics

```python
# Covariance and correlation
arr1 = np.array([1, 2, 3, 4, 5])
arr2 = np.array([2, 4, 6, 8, 10])

np.cov(arr1, arr2)       # Covariance matrix
np.corrcoef(arr1, arr2)  # Correlation matrix

# Histogram
hist, bin_edges = np.histogram(arr, bins=5)
# hist: [2, 2, 2, 2, 2] (counts per bin)
# bin_edges: [1.0, 2.8, 4.6, 6.4, 8.2, 10.0]

# Unique values
np.unique([1, 2, 2, 3, 3, 3])  # [1, 2, 3]
values, counts = np.unique([1, 2, 2, 3, 3, 3], return_counts=True)
```

### P2.5.3 Random Number Generation

```python
# Set seed for reproducibility
np.random.seed(42)

# Common distributions
np.random.uniform(0, 1, 100)       # Uniform [0, 1)
np.random.normal(0, 1, 100)        # Normal (mean=0, std=1)
np.random.exponential(1, 100)      # Exponential (scale=1)
np.random.poisson(5, 100)          # Poisson (lambda=5)
np.random.binomial(10, 0.5, 100)   # Binomial (n=10, p=0.5)
np.random.beta(2, 5, 100)          # Beta (alpha=2, beta=5)

# Random sampling
np.random.choice([1, 2, 3, 4, 5], size=3, replace=True)
np.random.choice([1, 2, 3, 4, 5], size=3, replace=False)
np.random.shuffle(arr)              # Shuffle in-place
np.random.permutation(arr)          # New array with shuffled order
```

---

## P2.6 Broadcasting in Depth

### P2.6.1 Broadcasting Rules Explained

```python
# Broadcasting rule: Two arrays are compatible if their dimensions
# are equal or one of them is 1, starting from the trailing dimension

# Example 1: Shape (2, 3) + shape (3,)
a = np.array([[1, 2, 3],
              [4, 5, 6]])  # shape (2, 3)
b = np.array([10, 20, 30])   # shape (3,)

# b is broadcast to: [[10, 20, 30], [10, 20, 30]]
result = a + b
# [[11, 22, 33], [14, 25, 36]]

# Example 2: Shape (3, 2) + shape (3, 1)
a = np.array([[1, 2],
              [3, 4],
              [5, 6]])  # shape (3, 2)
b = np.array([[10],
              [20],
              [30]])    # shape (3, 1)

# b is broadcast to: [[10, 10], [20, 20], [30, 30]]
result = a + b
# [[11, 12], [23, 24], [35, 36]]

# Example 3: Incompatible shapes
a = np.array([[1, 2, 3],
              [4, 5, 6]])  # shape (2, 3)
b = np.array([10, 20])      # shape (2,)
# ValueError: operands could not be broadcast together
```

### P2.6.2 Broadcasting with np.newaxis

```python
# Use np.newaxis to add dimensions for broadcasting
a = np.array([1, 2, 3])  # shape (3,)

# Column vector (3, 1)
col_vector = a[:, np.newaxis]
# [[1], [2], [3]]

# Row vector (1, 3)
row_vector = a[np.newaxis, :]
# [[1, 2, 3]]

# Broadcasting with newaxis
a = np.array([1, 2, 3, 4, 5])  # shape (5,)
b = np.array([10, 20, 30])      # shape (3,)

# Outer product using broadcasting
outer = a[:, np.newaxis] * b[np.newaxis, :]
# shape (5, 3)
```

---

## P2.7 Advanced Array Operations

### P2.7.1 Universal Functions (ufuncs)

```python
# Mathematical functions
np.add(arr, 10)          # Addition
np.subtract(arr, 10)     # Subtraction
np.multiply(arr, 2)      # Multiplication
np.divide(arr, 2)        # Division
np.power(arr, 2)         # Power

# Trigonometry
np.sin(arr)
np.cos(arr)
np.tan(arr)
np.arcsin(arr)
np.arccos(arr)
np.arctan(arr)

# Exponential and logarithmic
np.exp(arr)
np.expm1(arr)            # exp(x) - 1 (more accurate for small x)
np.log(arr)
np.log1p(arr)            # log(1 + x) (more accurate for small x)
np.log10(arr)
np.log2(arr)

# Special functions
np.sinc(arr)
np.gamma(arr)
np.erf(arr)              # Error function

# Reduce operations
np.add.reduce(arr)       # Sum (equivalent to np.sum)
np.multiply.reduce(arr)  # Product

# Accumulate (running operation)
np.add.accumulate(arr)   # Cumulative sum

# Outer product
np.multiply.outer(arr, arr)  # Outer product matrix
```

### P2.7.2 Sorting and Searching

```python
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6, 5, 3])

# Sorting
np.sort(arr)              # Returns sorted copy
arr.sort()                # Sorts in-place

# Sorting along axis (2D)
arr2d = np.array([[3, 1, 4],
                  [1, 5, 9],
                  [2, 6, 5]])
np.sort(arr2d, axis=0)    # Sort columns
np.sort(arr2d, axis=1)    # Sort rows

# Argmax/argmin (index of max/min)
np.argmax(arr)            # Index of maximum
np.argmin(arr)            # Index of minimum
np.argmax(arr2d, axis=0)  # Index of max per column
np.argmax(arr2d, axis=1)  # Index of max per row

# Argsort (sort indices)
np.argsort(arr)           # Indices that would sort array

# Search
np.where(arr > 5)         # Indices where condition is True
np.searchsorted(np.sort(arr), 5)  # Find position to insert 5
```

### P2.7.3 Set Operations

```python
a = np.array([1, 2, 3, 4, 5])
b = np.array([4, 5, 6, 7, 8])

# Unique
np.unique(a)              # [1, 2, 3, 4, 5]

# Intersection
np.intersect1d(a, b)      # [4, 5]

# Union
np.union1d(a, b)          # [1, 2, 3, 4, 5, 6, 7, 8]

# Difference
np.setdiff1d(a, b)        # [1, 2, 3]
np.setdiff1d(b, a)        # [6, 7, 8]

# Symmetric difference
np.setxor1d(a, b)         # [1, 2, 3, 6, 7, 8]

# Check membership
np.isin(a, [2, 3, 4])     # [False, True, True, True, False]
```

---

## P2.8 Performance Optimization

### P2.8.1 Vectorization vs. Loops

```python
import numpy as np
import time

# ❌ SLOW: Python loops
def loop_operation(data):
    result = np.zeros(len(data))
    for i in range(len(data)):
        result[i] = data[i] ** 2 + np.sin(data[i])
    return result

# ✅ FAST: Vectorization
def vectorized_operation(data):
    return data ** 2 + np.sin(data)

# Performance comparison
data = np.random.rand(1000000)

start = time.time()
result1 = loop_operation(data)
print(f"Loop: {time.time() - start:.4f}s")

start = time.time()
result2 = vectorized_operation(data)
print(f"Vectorized: {time.time() - start:.4f}s")

# Difference is typically 100-1000x faster
```

### P2.8.2 Memory Efficiency

```python
# Use appropriate dtypes
arr = np.array([1, 2, 3], dtype=np.float64)   # 8 bytes each
arr_float32 = arr.astype(np.float32)          # 4 bytes each
arr_int32 = arr.astype(np.int32)              # 4 bytes each

# In-place operations (avoid copying)
arr = np.array([1, 2, 3, 4, 5])
arr += 10          # In-place addition (modifies arr)
arr = arr + 10     # Creates new array (more memory)

# Use views instead of copies
arr = np.arange(1000000)
slice_view = arr[::2]    # View (no copy)
slice_copy = arr[::2].copy()  # Copy (more memory)

# Memory mapping for large files
# mmap = np.memmap('large_data.dat', dtype='float32', mode='r', shape=(1000000, 100))
```

---

## P2.9 NumPy in Pandas

### P2.9.1 Converting Between NumPy and Pandas

```python
import pandas as pd
import numpy as np

# Pandas to NumPy
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})
numpy_array = df.to_numpy()  # Best method
numpy_array = df.values      # Legacy method (still works)

# NumPy to Pandas
arr = np.array([[1, 2, 3], [4, 5, 6]])
df = pd.DataFrame(arr, columns=['A', 'B', 'C'])

# Series to NumPy
series = pd.Series([1, 2, 3, 4, 5])
np_array = series.to_numpy()
```

### P2.9.2 Using NumPy Functions on Pandas

```python
# Most NumPy functions work on pandas Series/DataFrames
df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})

np.sqrt(df)           # Square root of all elements
np.mean(df)           # Mean of all elements
np.median(df)         # Median of all elements
np.exp(df)            # Exponential

# Boolean indexing with NumPy
mask = df['A'] > 1
df[mask]              # Equivalent to pandas filtering

# Applying NumPy functions with apply
df.apply(np.sqrt)     # Apply sqrt to each element
df.apply(np.mean, axis=1)  # Row-wise mean
```

---

## P2.10 Common NumPy Patterns in Data Science

### P2.10.1 One-Hot Encoding

```python
def one_hot_encode(labels, num_classes=None):
    """One-hot encode labels."""
    labels = np.array(labels)
    if num_classes is None:
        num_classes = len(np.unique(labels))
    return np.eye(num_classes)[labels]

# Example
labels = np.array([0, 1, 2, 1, 0, 2])
one_hot = one_hot_encode(labels)
# [[1, 0, 0],
#  [0, 1, 0],
#  [0, 0, 1],
#  [0, 1, 0],
#  [1, 0, 0],
#  [0, 0, 1]]
```

### P2.10.2 Train-Test Split

```python
def train_test_split_manual(X, y, test_size=0.2, random_state=42):
    """Manual train-test split."""
    np.random.seed(random_state)
    indices = np.random.permutation(len(X))
    split_idx = int(len(X) * (1 - test_size))
    
    train_indices = indices[:split_idx]
    test_indices = indices[split_idx:]
    
    return (X[train_indices], X[test_indices],
            y[train_indices], y[test_indices])

# Usage
X = np.random.rand(100, 10)
y = np.random.randint(0, 2, 100)
X_train, X_test, y_train, y_test = train_test_split_manual(X, y)
```

### P2.10.3 Normalization and Standardization

```python
def standardize(X):
    """Standardize data (mean=0, std=1)."""
    return (X - np.mean(X, axis=0)) / np.std(X, axis=0)

def normalize(X):
    """Normalize data to [0, 1]."""
    return (X - np.min(X, axis=0)) / (np.max(X, axis=0) - np.min(X, axis=0))

# Usage
data = np.random.rand(100, 5)
standardized = standardize(data)
normalized = normalize(data)
```

---

## P2.11 Key Differences: NumPy vs Python Lists

| Feature | NumPy Array | Python List |
|---------|-------------|-------------|
| **Speed** | Fast (C implementation) | Slow (Python objects) |
| **Memory** | Compact, efficient | Overhead for each element |
| **Operations** | Vectorized | Loops required |
| **Data Types** | Single, homogeneous | Mixed, flexible |
| **Slicing** | Returns view (no copy) | Returns new list |
| **Broadcasting** | Yes | No |
| **Math Functions** | Built-in ufuncs | Need to import |

---

## P2.12 Key Takeaways

1. **NumPy is the foundation** of the Python data science ecosystem
2. **Vectorization is essential** - Always prefer vectorized operations over loops
3. **Broadcasting is powerful** - Understand how arrays of different shapes work together
4. **Views vs. Copies** - Slicing creates views (no copy), fancy indexing creates copies
5. **Use appropriate dtypes** - Save memory with float32, int32 when possible
6. **Set random seeds** - For reproducibility in your analysis
7. **NumPy + Pandas** - Most pandas operations use NumPy under the hood

This primer covers the essential NumPy concepts you'll encounter throughout the series. NumPy's vectorization and broadcasting capabilities are fundamental to efficient data analysis in Python.
