# Primer 3: NumPy Deep Dive — The Foundation of ML in Python

## Complete Guide to NumPy for Machine Learning

### The Target

This primer provides a comprehensive guide to NumPy, the fundamental library for scientific computing in Python. It covers everything from basic array operations to advanced techniques used throughout the series.

### The Concept

NumPy is the foundation of the Python data science ecosystem. Think of it as the "math engine" that powers everything else—Pandas, Scikit-learn, PyTorch, and TensorFlow all build on NumPy.

**Why this matters**: Understanding NumPy is essential for machine learning. It's how we represent data, perform computations, and implement algorithms efficiently.

### NumPy Basics

#### Importing NumPy

```python
import numpy as np

# Check version
print(np.__version__)  # 1.24.3 or higher
```

#### Creating Arrays

```python
# From Python lists
arr1d = np.array([1, 2, 3, 4, 5])
arr2d = np.array([[1, 2, 3], [4, 5, 6]])
arr3d = np.array([[[1, 2], [3, 4]], [[5, 6], [7, 8]]])

# Special arrays
zeros = np.zeros((3, 4))           # 3x4 array of zeros
ones = np.ones((2, 3))             # 2x3 array of ones
eye = np.eye(4)                    # 4x4 identity matrix
diag = np.diag([1, 2, 3, 4])       # Diagonal matrix
full = np.full((3, 3), 7)          # 3x3 array filled with 7

# Random arrays
uniform = np.random.rand(3, 3)     # Uniform [0, 1)
normal = np.random.randn(3, 3)     # Standard normal
integers = np.random.randint(0, 10, size=(3, 3))  # Integers [0, 10)
random_seed = np.random.seed(42)   # For reproducibility

# Ranges
range1 = np.arange(10)             # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
range2 = np.arange(0, 10, 2)       # [0, 2, 4, 6, 8]
linspace = np.linspace(0, 1, 5)    # [0, 0.25, 0.5, 0.75, 1.0]
```

### Array Properties

```python
arr = np.array([[1, 2, 3, 4], 
                [5, 6, 7, 8], 
                [9, 10, 11, 12]])

# Shape and size
print(arr.shape)        # (3, 4) - 3 rows, 4 columns
print(arr.ndim)         # 2 - number of dimensions
print(arr.size)         # 12 - total number of elements
print(arr.dtype)        # int64 - data type
print(arr.nbytes)       # 96 - memory usage in bytes

# Reshaping
reshaped = arr.reshape(4, 3)  # (4, 3)
flattened = arr.flatten()      # 1D array
raveled = arr.ravel()          # 1D view (faster, no copy)

# Transpose
transposed = arr.T              # (4, 3)
```

### Array Indexing and Slicing

#### Basic Indexing

```python
arr = np.array([[1, 2, 3, 4],
                [5, 6, 7, 8],
                [9, 10, 11, 12]])

# Single element
arr[0, 0]    # 1 (row 0, col 0)
arr[2, 3]    # 12 (row 2, col 3)

# Row or column
arr[0]       # [1, 2, 3, 4] (row 0)
arr[:, 0]    # [1, 5, 9] (column 0)
arr[:, 1:3]  # Columns 1 and 2

# Slicing
arr[0:2, 0:2]  # [[1, 2], [5, 6]] (rows 0-1, cols 0-1)
arr[1:, :]     # All rows except first, all columns
arr[:, 1:]     # All rows, columns except first
```

#### Advanced Indexing

```python
# Fancy indexing (integer arrays)
arr = np.array([10, 20, 30, 40, 50])
indices = np.array([0, 2, 4])
arr[indices]  # [10, 30, 50]

# Boolean indexing
arr = np.array([1, 2, 3, 4, 5])
mask = arr > 3
arr[mask]  # [4, 5]

# In 2D
arr = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
mask = arr > 5
arr[mask]  # [6, 7, 8, 9] (flattened)

# Where function
indices = np.where(arr > 5)  # Returns indices where condition is True
arr[indices]  # Values where condition is True

# Filtering with where
arr_conditional = np.where(arr > 5, arr, 0)  # Keep >5, set others to 0
```

### Array Operations

#### Arithmetic Operations

```python
a = np.array([1, 2, 3, 4])
b = np.array([5, 6, 7, 8])

# Element-wise operations
a + b    # [6, 8, 10, 12]
a - b    # [-4, -4, -4, -4]
a * b    # [5, 12, 21, 32]
a / b    # [0.2, 0.333, 0.429, 0.5]
a ** 2   # [1, 4, 9, 16]

# Comparison
a > 2    # [False, False, True, True]
a == b   # [False, False, False, False]

# Logical operations
np.logical_and(a > 2, a < 4)  # [False, False, True, False]
np.logical_or(a < 2, a > 3)   # [True, False, False, True]
```

#### Universal Functions (ufuncs)

```python
arr = np.array([1, 2, 3, 4, 5])

# Math functions
np.sqrt(arr)      # [1, 1.414, 1.732, 2, 2.236]
np.exp(arr)       # [2.718, 7.389, 20.085, 54.598, 148.413]
np.log(arr)       # [0, 0.693, 1.099, 1.386, 1.609]
np.log10(arr)     # [0, 0.301, 0.477, 0.602, 0.699]

# Trig functions
np.sin(arr)       # [0.841, 0.909, 0.141, -0.757, -0.959]
np.cos(arr)       # [0.540, -0.416, -0.990, -0.654, 0.284]
np.tan(arr)       # [1.557, -2.185, -0.143, 1.158, -3.381]

# Rounding
np.round(arr)     # Round to nearest
np.floor(arr)     # Round down
np.ceil(arr)      # Round up

# Special functions
np.sign(arr)      # Sign of each element
np.abs(arr)       # Absolute value
np.clip(arr, 2, 4)  # Clip values between 2 and 4
```

### Linear Algebra with NumPy

#### Matrix Operations

```python
A = np.array([[1, 2], [3, 4]])
B = np.array([[5, 6], [7, 8]])

# Matrix multiplication
C = A @ B          # [[19, 22], [43, 50]]
C = np.matmul(A, B)  # Same as @

# Dot product
v1 = np.array([1, 2, 3])
v2 = np.array([4, 5, 6])
dot = np.dot(v1, v2)  # 32

# Vector norm
norm = np.linalg.norm(v1)  # sqrt(1^2 + 2^2 + 3^2) = 3.742

# Matrix inverse
A_inv = np.linalg.inv(A)  # [[-2, 1], [1.5, -0.5]]

# Determinant
det = np.linalg.det(A)  # -2.0

# Eigendecomposition
eigenvalues, eigenvectors = np.linalg.eig(A)

# SVD
U, S, Vt = np.linalg.svd(A)

# Solve linear system Ax = b
b = np.array([5, 7])
x = np.linalg.solve(A, b)  # [1, 2]
```

#### Common Matrix Types

```python
# Identity matrix
I = np.eye(3)

# Diagonal matrix
D = np.diag([1, 2, 3])

# Symmetric matrix
S = A @ A.T  # Always symmetric

# Orthogonal matrix
Q, R = np.linalg.qr(A)  # QR decomposition

# Positive definite matrix
PD = A.T @ A + np.eye(2)  # Add identity to ensure positive definite
```

### Broadcasting

#### Understanding Broadcasting

Broadcasting allows NumPy to perform operations on arrays of different shapes.

```python
# Adding scalar to array
arr = np.array([1, 2, 3, 4])
arr + 10  # [11, 12, 13, 14]

# Adding row to matrix
matrix = np.array([[1, 2, 3], [4, 5, 6]])
row = np.array([10, 20, 30])
matrix + row  # [[11, 22, 33], [14, 25, 36]]

# Adding column to matrix
col = np.array([[10], [20]])
matrix + col  # [[11, 12, 13], [24, 25, 26]]

# Adding matrix to vector (with broadcasting)
arr = np.array([1, 2, 3, 4])
matrix = np.array([[1, 2, 3, 4], [5, 6, 7, 8]])
arr + matrix  # [[2, 4, 6, 8], [6, 8, 10, 12]]
```

#### Broadcasting Rules

```
Rule 1: If arrays have different dimensions, prepend 1s
Rule 2: If shapes differ, arrays are broadcast if they are compatible
Rule 3: Arrays are compatible if dimensions are equal or one is 1

Example:
A.shape = (3, 4)    B.shape = (4,)  -> Compatible (4 == 4)
A.shape = (3, 4)    B.shape = (3, 1) -> Compatible (3 == 3, 4 == 1)
A.shape = (3, 4)    B.shape = (1, 4) -> Compatible (3 == 1, 4 == 4)
```

### Statistical Operations

```python
arr = np.array([[1, 2, 3, 4], 
                [5, 6, 7, 8],
                [9, 10, 11, 12]])

# Basic statistics
mean = np.mean(arr)           # 6.5 (overall mean)
mean_rows = np.mean(arr, axis=1)  # [2.5, 6.5, 10.5]
mean_cols = np.mean(arr, axis=0)  # [5, 6, 7, 8]

# Other statistics
std = np.std(arr, axis=0)     # Standard deviation
var = np.var(arr, axis=0)     # Variance
min_val = np.min(arr, axis=0)  # Minimum
max_val = np.max(arr, axis=0)  # Maximum
sum_arr = np.sum(arr, axis=0)  # Sum

# Percentiles
percentiles = np.percentile(arr, [25, 50, 75])  # [3.25, 6.5, 9.75]

# Correlation
corr = np.corrcoef(arr)       # Correlation matrix

# Covariance
cov = np.cov(arr)             # Covariance matrix

# Histogram
hist, bins = np.histogram(arr, bins=5)
```

### Advanced Array Manipulation

#### Stacking and Splitting

```python
a = np.array([1, 2, 3])
b = np.array([4, 5, 6])

# Stacking
vertical = np.vstack([a, b])  # [[1, 2, 3], [4, 5, 6]]
horizontal = np.hstack([a, b])  # [1, 2, 3, 4, 5, 6]

# Splitting
arr = np.array([1, 2, 3, 4, 5, 6])
split1 = np.split(arr, 3)  # [1, 2], [3, 4], [5, 6]
split2 = np.split(arr, [2, 4])  # [1, 2], [3, 4], [5, 6]

# Concatenation
concat = np.concatenate([a, b])  # [1, 2, 3, 4, 5, 6]
```

#### Reshaping and Flattening

```python
arr = np.array([[1, 2, 3], [4, 5, 6]])

# Reshape
reshaped = arr.reshape(3, 2)  # [[1, 2], [3, 4], [5, 6]]

# Flatten (copy)
flattened = arr.flatten()  # [1, 2, 3, 4, 5, 6]

# Ravel (view)
raveled = arr.ravel()  # [1, 2, 3, 4, 5, 6]

# Transpose
transposed = arr.T  # [[1, 4], [2, 5], [3, 6]]

# Swap axes
swapped = np.swapaxes(arr, 0, 1)  # Same as transpose
```

### Memory and Performance

#### View vs Copy

```python
arr = np.array([1, 2, 3, 4, 5])

# View (no copy)
view = arr.view()
view[0] = 100  # Also changes arr

# Copy (new array)
copy = arr.copy()
copy[0] = 100  # Does not change arr

# Slicing creates views
slice_view = arr[1:4]  # View, not copy
```

#### Performance Tips

```python
# Use vectorized operations instead of loops
# BAD:
for i in range(1000000):
    arr[i] = arr[i] * 2

# GOOD:
arr = arr * 2  # Much faster

# Use in-place operations when possible
arr *= 2  # Faster than arr = arr * 2

# Pre-allocate arrays
arr = np.empty(1000000)  # Faster than appending

# Use views instead of copies
# Avoid arr.copy() when not needed

# Use memory-efficient types
arr_float32 = np.array([1, 2, 3], dtype=np.float32)  # Half memory of float64
arr_int8 = np.array([1, 2, 3], dtype=np.int8)  # Very memory efficient
```

### Common ML Patterns with NumPy

#### Data Normalization

```python
def normalize_data(X):
    """Normalize data to mean 0, std 1."""
    mean = np.mean(X, axis=0)
    std = np.std(X, axis=0)
    return (X - mean) / std

def minmax_scale(X):
    """Scale data to [0, 1]."""
    min_val = np.min(X, axis=0)
    max_val = np.max(X, axis=0)
    return (X - min_val) / (max_val - min_val)

def pca(X, n_components):
    """PCA implementation."""
    # Center data
    X_centered = X - np.mean(X, axis=0)
    
    # SVD
    U, S, Vt = np.linalg.svd(X_centered)
    
    # Project
    components = Vt[:n_components]
    return X_centered @ components.T
```

#### Batch Processing

```python
def batch_process(X, batch_size=32):
    """Process data in batches."""
    n_samples = X.shape[0]
    
    for i in range(0, n_samples, batch_size):
        batch = X[i:min(i+batch_size, n_samples)]
        yield batch

# Usage
for batch in batch_process(X):
    # Process batch
    pass
```

#### Gradient Descent

```python
def gradient_descent(X, y, learning_rate=0.01, epochs=100):
    """Simple gradient descent implementation."""
    n_samples, n_features = X.shape
    weights = np.zeros(n_features)
    bias = 0
    
    for epoch in range(epochs):
        # Forward pass
        predictions = X @ weights + bias
        
        # Compute gradient
        gradient_weights = (2/n_samples) * X.T @ (predictions - y)
        gradient_bias = (2/n_samples) * np.sum(predictions - y)
        
        # Update
        weights -= learning_rate * gradient_weights
        bias -= learning_rate * gradient_bias
        
    return weights, bias
```

### Common Pitfalls and Solutions

#### Pitfall 1: Copy vs View

```python
# This creates a view
arr = np.array([1, 2, 3, 4, 5])
slice_view = arr[1:4]
slice_view[0] = 100
print(arr)  # [1, 100, 3, 4, 5] - Original changed!

# Use copy() to avoid
arr = np.array([1, 2, 3, 4, 5])
slice_copy = arr[1:4].copy()
slice_copy[0] = 100
print(arr)  # [1, 2, 3, 4, 5] - Original unchanged
```

#### Pitfall 2: Broadcasting Ambiguity

```python
# This might not do what you expect
arr1 = np.array([[1, 2, 3], [4, 5, 6]])
arr2 = np.array([1, 2])
# arr1 + arr2  # ValueError: operands could not be broadcast together

# Correct way
arr2_reshaped = arr2.reshape(2, 1)
arr1 + arr2_reshaped  # Works
```

#### Pitfall 3: Integer vs Float Division

```python
# Integer division
arr = np.array([1, 2, 3, 4])
arr / 2  # [0.5, 1.0, 1.5, 2.0] - In NumPy, this is always float

# But integer arrays with operations
arr_int = np.array([1, 2, 3, 4], dtype=int)
# arr_int += 0.5  # Warning: cast to int
```

### NumPy Cheat Sheet

#### Creation
```python
np.array([1, 2, 3])          # Array from list
np.zeros((2, 3))             # Zeros
np.ones((2, 3))              # Ones
np.eye(3)                    # Identity
np.arange(10)                # Range
np.linspace(0, 1, 5)         # Linear space
np.random.randn(2, 3)        # Random normal
```

#### Properties
```python
arr.shape                    # Shape
arr.ndim                     # Dimensions
arr.size                     # Total elements
arr.dtype                    # Data type
arr.T                        # Transpose
```

#### Operations
```python
arr + scalar                 # Addition
arr * scalar                 # Multiplication
arr1 + arr2                  # Element-wise addition
arr1 @ arr2                  # Matrix multiplication
np.dot(arr1, arr2)           # Dot product
np.sum(arr, axis=0)          # Sum along axis
np.mean(arr, axis=0)         # Mean along axis
np.std(arr, axis=0)          # Standard deviation
```

#### Indexing
```python
arr[0]                       # First element
arr[1:4]                     # Slicing
arr[[0, 2, 4]]               # Fancy indexing
arr[arr > 5]                 # Boolean indexing
arr[:, 0]                    # Column
```

#### Useful Functions
```python
np.reshape(arr, (2, 3))      # Reshape
np.flatten(arr)              # Flatten
np.concatenate([a, b])       # Concatenate
np.where(condition)          # Find indices
np.clip(arr, min, max)       # Clip values
np.linalg.inv(arr)           # Inverse
np.linalg.det(arr)           # Determinant
np.linalg.solve(A, b)        # Solve linear system
```

---

**[END OF PRIMER 3]**
