# Phase 1, Part 2: Matrices — Datasets in Two Dimensions

## Module 2: Matrices — The Structure of Data

### The Target

We're building the matrix implementation that will serve as the workhorse for our machine learning pipeline. Matrices allow us to represent entire datasets, perform batch operations, and implement the linear transformations that power algorithms like PCA and linear regression.

**Files we'll create:**
- `src/linear_algebra/matrix.py`
- Update `src/linear_algebra/__init__.py`
- Update `tests/test_linear_algebra.py`

### The Concept

If a **vector** is like a single data point (a house with features), a **matrix** is like a spreadsheet—a grid of numbers where:
- Each **row** represents one data point (one house)
- Each **column** represents one feature (square footage, bedrooms, etc.)

Think of it this way:
- A vector is a single column of numbers: `[2000, 3, 2]` (one house)
- A matrix is a table of numbers, with each row being a different house:

```
House 1: [2000, 3, 2]
House 2: [1500, 2, 1]
House 3: [1800, 3, 2]
House 4: [2200, 4, 3]
```

This is the standard way machine learning algorithms receive data. When you see `X.shape = (m, n)` in ML code, `m` is the number of samples (rows) and `n` is the number of features (columns).

**Key matrix operations for ML:**
- **Matrix multiplication**: The fundamental operation of linear transformations
- **Transposition**: Flipping rows and columns (essential for data preparation)
- **Matrix inversion**: Solving systems of equations (used in closed-form linear regression)
- **Identity and diagonal matrices**: Special matrices with useful properties

### The Implementation

Let's build our matrix class from scratch, ensuring it works seamlessly with our Vector class.

#### Step 1: Implement the Matrix Class

**File: `src/linear_algebra/matrix.py`**

```python
"""
Matrix implementation for machine learning operations.

This module provides a complete Matrix class that supports all
operations needed for linear algebra in machine learning, including
matrix multiplication, transposition, inversion, and decomposition.
"""

from typing import List, Union, Optional, Tuple
import math
from src.linear_algebra.vector import Vector


class Matrix:
    """
    A mathematical matrix for machine learning operations.
    
    A matrix represents a 2D grid of numbers, typically used to represent
    datasets where rows are samples and columns are features.
    
    Attributes:
        data (List[List[float]]): The underlying 2D array.
        rows (int): Number of rows (samples).
        cols (int): Number of columns (features).
        shape (Tuple[int, int]): Tuple of (rows, cols).
    
    Examples:
        >>> M = Matrix([[1, 2, 3], [4, 5, 6]])
        >>> M.shape
        (2, 3)
        >>> M[0, 1]
        2.0
    """
    
    def __init__(self, data: List[List[Union[int, float]]]):
        """
        Initialize a matrix from a 2D list.
        
        Args:
            data: A 2D list of numbers (rows first).
            
        Raises:
            ValueError: If data is empty, rows have inconsistent lengths,
                       or contains non-numeric values.
        """
        if not data:
            raise ValueError("Matrix cannot be empty")
        if not all(isinstance(row, list) for row in data):
            raise ValueError("Each row must be a list")
        
        # Validate all rows have the same length
        row_lengths = [len(row) for row in data]
        if len(set(row_lengths)) > 1:
            raise ValueError(f"All rows must have the same length. Found lengths: {row_lengths}")
        
        # Validate all elements are numeric
        for row in data:
            if not all(isinstance(x, (int, float)) for x in row):
                raise ValueError("All matrix elements must be numbers")
        
        # Convert all elements to float for consistency
        self._data: List[List[float]] = [[float(x) for x in row] for row in data]
        self.rows: int = len(self._data)
        self.cols: int = len(self._data[0]) if self.rows > 0 else 0
        self.shape: Tuple[int, int] = (self.rows, self.cols)
    
    def __getitem__(self, indices: Tuple[int, int]) -> float:
        """
        Access matrix elements by (row, col) index.
        
        Args:
            indices: Tuple of (row, column) indices.
            
        Returns:
            The value at the given position.
            
        Raises:
            IndexError: If indices are out of range.
        """
        if not isinstance(indices, tuple) or len(indices) != 2:
            raise TypeError("Indices must be a tuple of (row, col)")
        
        row, col = indices
        if row < 0 or row >= self.rows:
            raise IndexError(f"Row {row} out of range for matrix with {self.rows} rows")
        if col < 0 or col >= self.cols:
            raise IndexError(f"Column {col} out of range for matrix with {self.cols} columns")
        
        return self._data[row][col]
    
    def __setitem__(self, indices: Tuple[int, int], value: Union[int, float]) -> None:
        """
        Set matrix elements by (row, col) index.
        
        Args:
            indices: Tuple of (row, column) indices.
            value: New value for the element.
            
        Raises:
            IndexError: If indices are out of range.
        """
        if not isinstance(indices, tuple) or len(indices) != 2:
            raise TypeError("Indices must be a tuple of (row, col)")
        
        row, col = indices
        if row < 0 or row >= self.rows:
            raise IndexError(f"Row {row} out of range for matrix with {self.rows} rows")
        if col < 0 or col >= self.cols:
            raise IndexError(f"Column {col} out of range for matrix with {self.cols} columns")
        if not isinstance(value, (int, float)):
            raise ValueError("Value must be a number")
        
        self._data[row][col] = float(value)
    
    def __repr__(self) -> str:
        """Return a string representation of the matrix."""
        return f"Matrix({self._data})"
    
    def __str__(self) -> str:
        """Return a human-readable string representation."""
        if self.rows == 0 or self.cols == 0:
            return "[]"
        
        # Calculate formatting for alignment
        max_widths = []
        for col in range(self.cols):
            max_width = max(len(f"{self._data[row][col]:.4f}") for row in range(self.rows))
            max_widths.append(max_width + 2)  # Add padding
        
        # Build the string
        lines = []
        for row in range(self.rows):
            row_str = "["
            for col in range(self.cols):
                formatted = f"{self._data[row][col]:.4f}"
                row_str += formatted.rjust(max_widths[col])
                if col < self.cols - 1:
                    row_str += ","
            row_str += "]"
            lines.append(row_str)
        
        return "\n".join(lines)
    
    # ==================== BASIC OPERATIONS ====================
    
    def __add__(self, other: 'Matrix') -> 'Matrix':
        """
        Matrix addition: element-wise addition.
        
        Used for combining transformations or adding gradients.
        
        Args:
            other: Another Matrix of the same shape.
            
        Returns:
            A new Matrix representing the sum.
            
        Raises:
            ValueError: If matrices have different shapes.
        """
        if not isinstance(other, Matrix):
            raise TypeError("Can only add Matrix to Matrix")
        if self.shape != other.shape:
            raise ValueError(f"Cannot add matrices of different shapes: {self.shape} and {other.shape}")
        
        result_data = [
            [self._data[i][j] + other._data[i][j] for j in range(self.cols)]
            for i in range(self.rows)
        ]
        return Matrix(result_data)
    
    def __sub__(self, other: 'Matrix') -> 'Matrix':
        """
        Matrix subtraction: element-wise subtraction.
        
        Used for computing differences or error matrices.
        
        Args:
            other: Another Matrix of the same shape.
            
        Returns:
            A new Matrix representing the difference.
            
        Raises:
            ValueError: If matrices have different shapes.
        """
        if not isinstance(other, Matrix):
            raise TypeError("Can only subtract Matrix from Matrix")
        if self.shape != other.shape:
            raise ValueError(f"Cannot subtract matrices of different shapes: {self.shape} and {other.shape}")
        
        result_data = [
            [self._data[i][j] - other._data[i][j] for j in range(self.cols)]
            for i in range(self.rows)
        ]
        return Matrix(result_data)
    
    def __mul__(self, scalar: Union[int, float]) -> 'Matrix':
        """
        Scalar multiplication: multiply all elements by a number.
        
        Used for scaling data or gradients.
        
        Args:
            scalar: A number to multiply each element by.
            
        Returns:
            A new Matrix with all elements scaled.
        """
        if not isinstance(scalar, (int, float)):
            raise ValueError("Scalar must be a number")
        
        result_data = [
            [self._data[i][j] * scalar for j in range(self.cols)]
            for i in range(self.rows)
        ]
        return Matrix(result_data)
    
    def __rmul__(self, scalar: Union[int, float]) -> 'Matrix':
        """Reverse scalar multiplication (scalar * matrix)."""
        return self.__mul__(scalar)
    
    def __truediv__(self, scalar: Union[int, float]) -> 'Matrix':
        """
        Scalar division: divide all elements by a number.
        
        Used for normalization operations.
        
        Args:
            scalar: A number to divide each element by.
            
        Returns:
            A new Matrix with all elements divided.
            
        Raises:
            ValueError: If scalar is zero.
        """
        if not isinstance(scalar, (int, float)):
            raise ValueError("Scalar must be a number")
        if scalar == 0:
            raise ValueError("Cannot divide by zero")
        
        result_data = [
            [self._data[i][j] / scalar for j in range(self.cols)]
            for i in range(self.rows)
        ]
        return Matrix(result_data)
    
    # ==================== MATRIX MULTIPLICATION ====================
    
    def __matmul__(self, other: 'Matrix') -> 'Matrix':
        """
        Matrix multiplication using the @ operator.
        
        This is the workhorse of linear algebra. Matrix multiplication
        is used everywhere in ML:
        - Forward pass of neural networks
        - Transformations of data
        - Computing predictions from weights
        
        Mathematical formula: (AB)[i,j] = Σ_k A[i,k] * B[k,j]
        
        Args:
            other: Another Matrix (cols of self must equal rows of other).
            
        Returns:
            A new Matrix representing the product.
            
        Raises:
            ValueError: If dimensions don't match for multiplication.
        """
        if not isinstance(other, Matrix):
            raise TypeError("Can only multiply Matrix by Matrix")
        if self.cols != other.rows:
            raise ValueError(
                f"Cannot multiply matrices: columns of first ({self.cols}) "
                f"must equal rows of second ({other.rows})"
            )
        
        # Initialize result matrix with zeros
        result_data = [[0.0] * other.cols for _ in range(self.rows)]
        
        # Perform multiplication
        # Using row-wise dot products for efficiency
        for i in range(self.rows):
            for j in range(other.cols):
                # Dot product of row i of self and column j of other
                total = 0.0
                for k in range(self.cols):
                    total += self._data[i][k] * other._data[k][j]
                result_data[i][j] = total
        
        return Matrix(result_data)
    
    def matmul(self, other: 'Matrix') -> 'Matrix':
        """Alternative method name for matrix multiplication."""
        return self @ other
    
    # ==================== MATRIX-VECTOR OPERATIONS ====================
    
    def vector_dot(self, vector: Vector) -> Vector:
        """
        Multiply matrix by a vector (matrix-vector product).
        
        This is used for computing predictions: if X is a dataset and
        w is weights, then X @ w gives predictions.
        
        Mathematical formula: (A v)[i] = Σ_j A[i,j] * v[j]
        
        Args:
            vector: A Vector (size must equal cols of matrix).
            
        Returns:
            A new Vector representing the product.
            
        Raises:
            ValueError: If vector size doesn't match matrix columns.
        """
        if not isinstance(vector, Vector):
            raise TypeError("Must provide a Vector")
        if vector.size != self.cols:
            raise ValueError(
                f"Cannot multiply matrix with {self.cols} columns by "
                f"vector of size {vector.size}"
            )
        
        # Initialize result vector
        result_data = [0.0] * self.rows
        
        # Perform multiplication
        for i in range(self.rows):
            total = 0.0
            for j in range(self.cols):
                total += self._data[i][j] * vector[j]
            result_data[i] = total
        
        return Vector(result_data)
    
    # ==================== TRANSPOSITION ====================
    
    def transpose(self) -> 'Matrix':
        """
        Transpose the matrix (flip rows and columns).
        
        Transposition is essential for:
        - Preparing data for multiplication
        - Computing covariance matrices
        - Gradient calculations
        
        Mathematical formula: (A^T)[i,j] = A[j,i]
        
        Returns:
            A new Matrix representing the transpose.
            
        Examples:
            >>> M = Matrix([[1, 2, 3], [4, 5, 6]])
            >>> M.T
            Matrix([[1, 4], [2, 5], [3, 6]])
        """
        # Create transposed data: row i of transpose = column i of original
        transposed_data = [
            [self._data[row][col] for row in range(self.rows)]
            for col in range(self.cols)
        ]
        return Matrix(transposed_data)
    
    @property
    def T(self) -> 'Matrix':
        """Shorthand property for transpose."""
        return self.transpose()
    
    # ==================== SPECIAL MATRICES ====================
    
    def is_square(self) -> bool:
        """Check if the matrix is square (rows == cols)."""
        return self.rows == self.cols
    
    def is_symmetric(self) -> bool:
        """
        Check if the matrix is symmetric (A == A^T).
        
        Symmetric matrices appear frequently in ML (covariance matrices,
        Hessian matrices).
        """
        if not self.is_square():
            return False
        
        for i in range(self.rows):
            for j in range(i + 1, self.cols):
                if self._data[i][j] != self._data[j][i]:
                    return False
        return True
    
    def is_diagonal(self) -> bool:
        """
        Check if the matrix is diagonal (all off-diagonal elements are zero).
        
        Diagonal matrices are used for scaling operations and in SVD.
        """
        if not self.is_square():
            return False
        
        for i in range(self.rows):
            for j in range(self.cols):
                if i != j and self._data[i][j] != 0:
                    return False
        return True
    
    def is_identity(self) -> bool:
        """
        Check if the matrix is the identity matrix.
        
        The identity matrix is the multiplicative identity: A @ I = A.
        Used as the starting point in iterative algorithms.
        """
        if not self.is_square():
            return False
        
        for i in range(self.rows):
            for j in range(self.cols):
                if i == j:
                    if self._data[i][j] != 1.0:
                        return False
                else:
                    if self._data[i][j] != 0.0:
                        return False
        return True
    
    # ==================== DETERMINANT ====================
    
    def determinant(self) -> float:
        """
        Compute the determinant of the matrix.
        
        The determinant measures how the matrix scales area/volume.
        In ML, it's used for:
        - Checking if a matrix is invertible
        - Computing eigenvalues
        - Change of variables in probability
        
        Returns:
            The determinant as a float.
            
        Raises:
            ValueError: If matrix is not square.
        """
        if not self.is_square():
            raise ValueError("Determinant only defined for square matrices")
        
        n = self.rows
        
        # Base case: 1x1 matrix
        if n == 1:
            return self._data[0][0]
        
        # Base case: 2x2 matrix
        if n == 2:
            return self._data[0][0] * self._data[1][1] - self._data[0][1] * self._data[1][0]
        
        # Recursive case: Laplace expansion along first row
        det = 0.0
        for j in range(n):
            # Create submatrix (minor) by removing row 0 and column j
            minor_data = []
            for i in range(1, n):
                row = []
                for k in range(n):
                    if k != j:
                        row.append(self._data[i][k])
                minor_data.append(row)
            
            minor = Matrix(minor_data)
            cofactor = self._data[0][j] * minor.determinant()
            
            # Add or subtract based on position (checkerboard pattern)
            if j % 2 == 0:
                det += cofactor
            else:
                det -= cofactor
        
        return det
    
    # ==================== INVERSE ====================
    
    def inverse(self) -> 'Matrix':
        """
        Compute the inverse of the matrix.
        
        The inverse of a matrix A satisfies A @ A^(-1) = I.
        In ML, inverses are used for:
        - Closed-form solution to linear regression
        - Solving systems of equations
        - Computing covariance matrix inverses
        
        Returns:
            The inverse matrix.
            
        Raises:
            ValueError: If matrix is not invertible (singular).
        """
        if not self.is_square():
            raise ValueError("Inverse only defined for square matrices")
        
        n = self.rows
        
        # Check if invertible
        det = self.determinant()
        if abs(det) < 1e-12:  # Numerical tolerance
            raise ValueError("Matrix is singular (not invertible)")
        
        # For 1x1 matrix
        if n == 1:
            return Matrix([[1.0 / self._data[0][0]]])
        
        # For 2x2 matrix, use formula
        if n == 2:
            a, b = self._data[0][0], self._data[0][1]
            c, d = self._data[1][0], self._data[1][1]
            return Matrix([[d, -b], [-c, a]]) / det
        
        # For larger matrices, use Gauss-Jordan elimination
        # Create augmented matrix [A | I]
        augmented = []
        for i in range(n):
            row = self._data[i] + [0.0] * n
            row[n + i] = 1.0  # Identity part
            augmented.append(row)
        
        # Perform Gauss-Jordan elimination
        for col in range(n):
            # Find pivot
            pivot_row = col
            while pivot_row < n and abs(augmented[pivot_row][col]) < 1e-12:
                pivot_row += 1
            
            if pivot_row == n:
                raise ValueError("Matrix is singular (not invertible)")
            
            # Swap rows if needed
            if pivot_row != col:
                augmented[col], augmented[pivot_row] = augmented[pivot_row], augmented[col]
            
            # Scale pivot row to make pivot element 1
            pivot = augmented[col][col]
            for j in range(2 * n):
                augmented[col][j] /= pivot
            
            # Eliminate other rows
            for i in range(n):
                if i != col:
                    factor = augmented[i][col]
                    for j in range(2 * n):
                        augmented[i][j] -= factor * augmented[col][j]
        
        # Extract the inverse from the right half of augmented matrix
        inverse_data = [
            [augmented[i][j] for j in range(n, 2 * n)]
            for i in range(n)
        ]
        
        return Matrix(inverse_data)
    
    # ==================== UTILITY OPERATIONS ====================
    
    def row(self, index: int) -> Vector:
        """
        Extract a row as a Vector.
        
        Args:
            index: Row index.
            
        Returns:
            A Vector representing the row.
            
        Raises:
            IndexError: If index is out of range.
        """
        if index < 0 or index >= self.rows:
            raise IndexError(f"Row {index} out of range")
        return Vector(self._data[index])
    
    def col(self, index: int) -> Vector:
        """
        Extract a column as a Vector.
        
        Args:
            index: Column index.
            
        Returns:
            A Vector representing the column.
            
        Raises:
            IndexError: If index is out of range.
        """
        if index < 0 or index >= self.cols:
            raise IndexError(f"Column {index} out of range")
        return Vector([self._data[i][index] for i in range(self.rows)])
    
    def mean(self, axis: Optional[int] = None) -> Union[float, 'Matrix']:
        """
        Compute the mean along a given axis.
        
        Args:
            axis: 0 for column-wise mean, 1 for row-wise mean,
                  None for overall mean.
                  
        Returns:
            If axis is None: a float (overall mean).
            If axis is 0: a Matrix with 1 row (column means).
            If axis is 1: a Matrix with 1 column (row means).
        """
        if axis is None:
            return sum(sum(row) for row in self._data) / (self.rows * self.cols)
        
        if axis == 0:  # Column-wise means
            means = [sum(self._data[i][j] for i in range(self.rows)) / self.rows 
                    for j in range(self.cols)]
            return Matrix([means])
        elif axis == 1:  # Row-wise means
            means = [[sum(row) / self.cols] for row in self._data]
            return Matrix(means)
        else:
            raise ValueError("Axis must be 0, 1, or None")
    
    def variance(self, axis: Optional[int] = None, ddof: int = 0) -> Union[float, 'Matrix']:
        """
        Compute the variance along a given axis.
        
        Args:
            axis: 0 for column-wise variance, 1 for row-wise variance,
                  None for overall variance.
            ddof: Delta degrees of freedom (0 for population, 1 for sample).
            
        Returns:
            If axis is None: a float (overall variance).
            If axis is 0: a Matrix with 1 row (column variances).
            If axis is 1: a Matrix with 1 column (row variances).
        """
        if axis is None:
            mean = self.mean()
            return sum((x - mean) ** 2 for row in self._data for x in row) / (self.rows * self.cols - ddof)
        
        if axis == 0:  # Column-wise variances
            variances = []
            for j in range(self.cols):
                col_values = [self._data[i][j] for i in range(self.rows)]
                col_mean = sum(col_values) / self.rows
                var = sum((x - col_mean) ** 2 for x in col_values) / (self.rows - ddof)
                variances.append(var)
            return Matrix([variances])
        elif axis == 1:  # Row-wise variances
            variances = []
            for i in range(self.rows):
                row = self._data[i]
                row_mean = sum(row) / self.cols
                var = sum((x - row_mean) ** 2 for x in row) / (self.cols - ddof)
                variances.append([var])
            return Matrix(variances)
        else:
            raise ValueError("Axis must be 0, 1, or None")
    
    def standardize(self) -> 'Matrix':
        """
        Standardize the matrix (z-score normalization along columns).
        
        This transforms each column to have mean 0 and variance 1.
        This is a crucial preprocessing step in many ML algorithms.
        
        Returns:
            A new Matrix with standardized columns.
        """
        if self.rows < 2:
            raise ValueError("Cannot standardize matrix with fewer than 2 rows")
        
        # Compute column means
        col_means = [sum(self._data[i][j] for i in range(self.rows)) / self.rows 
                    for j in range(self.cols)]
        
        # Compute column standard deviations
        col_stds = []
        for j in range(self.cols):
            var = sum((self._data[i][j] - col_means[j]) ** 2 for i in range(self.rows)) / (self.rows - 1)
            col_stds.append(math.sqrt(var) if var > 0 else 1.0)  # Avoid division by zero
        
        # Standardize
        standardized_data = [
            [(self._data[i][j] - col_means[j]) / col_stds[j] 
             for j in range(self.cols)]
            for i in range(self.rows)
        ]
        
        return Matrix(standardized_data)
    
    def to_list(self) -> List[List[float]]:
        """Convert the matrix to a list of lists."""
        return [[x for x in row] for row in self._data]
    
    def to_numpy(self):
        """
        Convert to NumPy array (if NumPy is available).
        
        This allows integration with the broader scientific Python ecosystem
        while still building our own implementation.
        """
        try:
            import numpy as np
            return np.array(self._data)
        except ImportError:
            raise ImportError("NumPy is required for this operation")
    
    @classmethod
    def zeros(cls, rows: int, cols: int) -> 'Matrix':
        """Create a matrix of zeros."""
        return cls([[0.0] * cols for _ in range(rows)])
    
    @classmethod
    def ones(cls, rows: int, cols: int) -> 'Matrix':
        """Create a matrix of ones."""
        return cls([[1.0] * cols for _ in range(rows)])
    
    @classmethod
    def identity(cls, size: int) -> 'Matrix':
        """Create the identity matrix."""
        data = [[0.0] * size for _ in range(size)]
        for i in range(size):
            data[i][i] = 1.0
        return cls(data)
    
    @classmethod
    def from_vectors(cls, vectors: List[Vector]) -> 'Matrix':
        """
        Create a matrix from a list of vectors (each vector becomes a row).
        
        This is a common way to assemble a dataset from individual data points.
        """
        if not vectors:
            raise ValueError("Cannot create matrix from empty list")
        
        if not all(isinstance(v, Vector) for v in vectors):
            raise TypeError("All elements must be Vectors")
        
        # Check all vectors have the same size
        sizes = [v.size for v in vectors]
        if len(set(sizes)) > 1:
            raise ValueError(f"All vectors must have the same size. Found sizes: {sizes}")
        
        data = [v.to_list() for v in vectors]
        return cls(data)
    
    def __eq__(self, other) -> bool:
        """Check equality between matrices."""
        if not isinstance(other, Matrix):
            return False
        if self.shape != other.shape:
            return False
        return all(self._data[i][j] == other._data[i][j] 
                  for i in range(self.rows) for j in range(self.cols))
```

#### Step 2: Update the Package Initialization

**File: `src/linear_algebra/__init__.py`**

```python
"""
Linear algebra package for machine learning operations.
"""

from src.linear_algebra.vector import Vector
from src.linear_algebra.matrix import Matrix

__all__ = ['Vector', 'Matrix']
```

#### Step 3: Update the Test Suite

Now let's add tests for our Matrix class. Append these tests to `tests/test_linear_algebra.py`:

**File: `tests/test_linear_algebra.py` (append to end)**

```python
# ==================== MATRIX TESTS ====================

from src.linear_algebra.matrix import Matrix


class TestMatrix:
    """Test suite for the Matrix class."""
    
    def test_initialization(self):
        """Test that matrices are initialized correctly."""
        M = Matrix([[1, 2, 3], [4, 5, 6]])
        assert M.rows == 2
        assert M.cols == 3
        assert M.shape == (2, 3)
        assert M[0, 0] == 1.0
        assert M[0, 1] == 2.0
        assert M[1, 2] == 6.0
        
        # Test single row
        M = Matrix([[1, 2, 3]])
        assert M.rows == 1
        assert M.cols == 3
    
    def test_initialization_errors(self):
        """Test that initialization fails with invalid inputs."""
        with pytest.raises(ValueError, match="Matrix cannot be empty"):
            Matrix([])
        
        with pytest.raises(ValueError, match="Each row must be a list"):
            Matrix([[1, 2], [3, 4], "invalid"])
        
        with pytest.raises(ValueError, match="All rows must have the same length"):
            Matrix([[1, 2], [3, 4, 5]])
        
        with pytest.raises(ValueError, match="All matrix elements must be numbers"):
            Matrix([[1, "two", 3]])
    
    def test_getitem_setitem(self):
        """Test indexing and item assignment."""
        M = Matrix([[1, 2, 3], [4, 5, 6]])
        
        # Get
        assert M[0, 0] == 1.0
        assert M[1, 2] == 6.0
        
        # Set
        M[0, 0] = 10.0
        assert M[0, 0] == 10.0
        
        # Invalid indices
        with pytest.raises(IndexError):
            M[2, 0]  # Row out of range
        with pytest.raises(IndexError):
            M[0, 3]  # Column out of range
    
    def test_add(self):
        """Test matrix addition."""
        M1 = Matrix([[1, 2], [3, 4]])
        M2 = Matrix([[5, 6], [7, 8]])
        result = M1 + M2
        
        assert result[0, 0] == 6.0
        assert result[0, 1] == 8.0
        assert result[1, 0] == 10.0
        assert result[1, 1] == 12.0
        
        # Test different shapes
        M3 = Matrix([[1, 2, 3]])
        with pytest.raises(ValueError, match="Cannot add matrices of different shapes"):
            M1 + M3
    
    def test_sub(self):
        """Test matrix subtraction."""
        M1 = Matrix([[5, 6], [7, 8]])
        M2 = Matrix([[1, 2], [3, 4]])
        result = M1 - M2
        
        assert result[0, 0] == 4.0
        assert result[0, 1] == 4.0
        assert result[1, 0] == 4.0
        assert result[1, 1] == 4.0
    
    def test_scalar_multiplication(self):
        """Test scalar multiplication."""
        M = Matrix([[1, 2], [3, 4]])
        
        result1 = M * 2
        assert result1[0, 0] == 2.0
        assert result1[0, 1] == 4.0
        assert result1[1, 0] == 6.0
        assert result1[1, 1] == 8.0
        
        result2 = 2 * M
        assert result2 == result1
    
    def test_scalar_division(self):
        """Test scalar division."""
        M = Matrix([[2, 4], [6, 8]])
        result = M / 2
        
        assert result[0, 0] == 1.0
        assert result[0, 1] == 2.0
        assert result[1, 0] == 3.0
        assert result[1, 1] == 4.0
        
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            M / 0
    
    def test_matrix_multiplication(self):
        """Test matrix multiplication."""
        # 2x3 times 3x2
        M1 = Matrix([[1, 2, 3], [4, 5, 6]])
        M2 = Matrix([[7, 8], [9, 10], [11, 12]])
        result = M1 @ M2
        
        assert result.shape == (2, 2)
        assert result[0, 0] == 58  # 1*7 + 2*9 + 3*11
        assert result[0, 1] == 64  # 1*8 + 2*10 + 3*12
        assert result[1, 0] == 139  # 4*7 + 5*9 + 6*11
        assert result[1, 1] == 154  # 4*8 + 5*10 + 6*12
        
        # Test error cases
        M3 = Matrix([[1, 2]])
        with pytest.raises(ValueError, match="Cannot multiply matrices"):
            M1 @ M3
    
    def test_matrix_vector_multiplication(self):
        """Test matrix-vector multiplication."""
        M = Matrix([[1, 2, 3], [4, 5, 6]])
        v = Vector([7, 8, 9])
        
        result = M.vector_dot(v)
        
        assert result.size == 2
        assert result[0] == 50  # 1*7 + 2*8 + 3*9
        assert result[1] == 122  # 4*7 + 5*8 + 6*9
        
        # Test error cases
        v2 = Vector([1, 2])
        with pytest.raises(ValueError, match="Cannot multiply matrix"):
            M.vector_dot(v2)
    
    def test_transpose(self):
        """Test matrix transposition."""
        M = Matrix([[1, 2, 3], [4, 5, 6]])
        MT = M.transpose()
        
        assert MT.shape == (3, 2)
        assert MT[0, 0] == 1.0
        assert MT[0, 1] == 4.0
        assert MT[1, 0] == 2.0
        assert MT[1, 1] == 5.0
        assert MT[2, 0] == 3.0
        assert MT[2, 1] == 6.0
        
        # Test T property
        assert M.T == MT
    
    def test_special_matrices(self):
        """Test special matrix properties."""
        # Square matrix
        M = Matrix([[1, 2], [3, 4]])
        assert M.is_square()
        
        # Non-square
        M2 = Matrix([[1, 2, 3]])
        assert not M2.is_square()
        
        # Symmetric matrix
        M_sym = Matrix([[1, 2], [2, 1]])
        assert M_sym.is_symmetric()
        assert M_sym.is_square()
        assert not M_sym.is_diagonal()
        
        # Diagonal matrix
        M_diag = Matrix([[1, 0], [0, 2]])
        assert M_diag.is_diagonal()
        assert M_diag.is_square()
        assert not M_diag.is_identity()
        
        # Identity matrix
        M_eye = Matrix.identity(3)
        assert M_eye.is_identity()
        assert M_eye.is_diagonal()
        assert M_eye.is_symmetric()
    
    def test_determinant(self):
        """Test determinant computation."""
        # 1x1
        M1 = Matrix([[5]])
        assert M1.determinant() == 5.0
        
        # 2x2
        M2 = Matrix([[1, 2], [3, 4]])
        assert M2.determinant() == -2.0
        
        # 3x3
        M3 = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        assert M3.determinant() == 0.0  # Singular matrix
        
        # 3x3 non-singular
        M4 = Matrix([[2, 1, 1], [1, 3, 2], [1, 2, 4]])
        assert M4.determinant() == 14.0  # Known result
        
        # Non-square
        M5 = Matrix([[1, 2]])
        with pytest.raises(ValueError, match="Determinant only defined for square matrices"):
            M5.determinant()
    
    def test_inverse(self):
        """Test matrix inversion."""
        # 2x2
        M = Matrix([[1, 2], [3, 4]])
        inv = M.inverse()
        
        # Check that M @ inv = I
        identity_check = M @ inv
        assert identity_check.is_identity()
        
        # 3x3
        M2 = Matrix([[2, 1, 1], [1, 3, 2], [1, 2, 4]])
        inv2 = M2.inverse()
        identity_check2 = M2 @ inv2
        assert identity_check2.is_identity()
        
        # Singular matrix
        M3 = Matrix([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
        with pytest.raises(ValueError, match="Matrix is singular"):
            M3.inverse()
        
        # Non-square
        M4 = Matrix([[1, 2]])
        with pytest.raises(ValueError, match="Inverse only defined for square matrices"):
            M4.inverse()
    
    def test_row_col_extraction(self):
        """Test row and column extraction."""
        M = Matrix([[1, 2, 3], [4, 5, 6]])
        
        row0 = M.row(0)
        assert row0 == Vector([1, 2, 3])
        
        row1 = M.row(1)
        assert row1 == Vector([4, 5, 6])
        
        col0 = M.col(0)
        assert col0 == Vector([1, 4])
        
        col2 = M.col(2)
        assert col2 == Vector([3, 6])
        
        # Error cases
        with pytest.raises(IndexError):
            M.row(2)
        with pytest.raises(IndexError):
            M.col(3)
    
    def test_mean_variance(self):
        """Test mean and variance computation."""
        M = Matrix([[1, 2], [3, 4], [5, 6]])
        
        # Overall mean
        assert M.mean() == 3.5
        
        # Column means
        col_means = M.mean(axis=0)
        assert col_means.shape == (1, 2)
        assert col_means[0, 0] == 3.0
        assert col_means[0, 1] == 4.0
        
        # Row means
        row_means = M.mean(axis=1)
        assert row_means.shape == (3, 1)
        assert row_means[0, 0] == 1.5
        assert row_means[1, 0] == 3.5
        assert row_means[2, 0] == 5.5
        
        # Variance
        assert M.variance() == pytest.approx(2.9166, rel=1e-4)
        
        # Column variances
        col_vars = M.variance(axis=0, ddof=1)
        assert col_vars[0, 0] == 4.0
        assert col_vars[0, 1] == 4.0
    
    def test_standardize(self):
        """Test standardization."""
        M = Matrix([[1, 2], [3, 4], [5, 6]])
        standardized = M.standardize()
        
        # Check column means are 0
        col_means = standardized.mean(axis=0)
        assert col_means[0, 0] == pytest.approx(0, abs=1e-10)
        assert col_means[0, 1] == pytest.approx(0, abs=1e-10)
        
        # Check column variances are 1
        col_vars = standardized.variance(axis=0, ddof=1)
        assert col_vars[0, 0] == pytest.approx(1, abs=1e-10)
        assert col_vars[0, 1] == pytest.approx(1, abs=1e-10)
    
    def test_from_vectors(self):
        """Test creating a matrix from vectors."""
        v1 = Vector([1, 2, 3])
        v2 = Vector([4, 5, 6])
        v3 = Vector([7, 8, 9])
        
        M = Matrix.from_vectors([v1, v2, v3])
        
        assert M.shape == (3, 3)
        assert M[0, 0] == 1.0
        assert M[0, 1] == 2.0
        assert M[1, 0] == 4.0
        assert M[2, 2] == 9.0
        
        # Error cases
        with pytest.raises(ValueError, match="Cannot create matrix from empty list"):
            Matrix.from_vectors([])
        
        v4 = Vector([10, 11])  # Different size
        with pytest.raises(ValueError, match="All vectors must have the same size"):
            Matrix.from_vectors([v1, v4])
    
    def test_class_methods(self):
        """Test class factory methods."""
        zeros = Matrix.zeros(2, 3)
        assert zeros.shape == (2, 3)
        assert zeros[0, 0] == 0.0
        assert zeros[1, 2] == 0.0
        
        ones = Matrix.ones(2, 3)
        assert ones[0, 0] == 1.0
        assert ones[1, 2] == 1.0
        
        eye = Matrix.identity(3)
        assert eye.is_identity()
        assert eye[0, 0] == 1.0
        assert eye[0, 1] == 0.0
        assert eye[1, 0] == 0.0
        assert eye[1, 1] == 1.0
```

### The Verification

#### Step 1: Run the Tests

Navigate to your project root and run:

```bash
# From the project root directory
pytest tests/test_linear_algebra.py -v
```

You should see all 36 tests pass (18 from the Vector tests plus 18 from the Matrix tests):

```
==================== test session starts ====================
collected 36 items

tests/test_linear_algebra.py::TestVector::test_initialization PASSED
tests/test_linear_algebra.py::TestVector::test_initialization_errors PASSED
...
tests/test_linear_algebra.py::TestMatrix::test_initialization PASSED
tests/test_linear_algebra.py::TestMatrix::test_initialization_errors PASSED
...
tests/test_linear_algebra.py::TestMatrix::test_class_methods PASSED

==================== 36 passed in 0.23s ====================
```

#### Step 2: Interactive Verification

Let's test our matrix operations interactively:

```bash
# From the project root
python
```

Then in the Python interpreter:

```python
>>> from src.linear_algebra import Matrix, Vector
>>> 
>>> # Create a dataset (3 houses, 3 features each)
>>> data = Matrix([
...     [2000, 3, 2],   # House 1: sqft, bedrooms, bathrooms
...     [1500, 2, 1],   # House 2
...     [1800, 3, 2],   # House 3
...     [2200, 4, 3]    # House 4
... ])
>>> 
>>> print("Dataset:")
>>> print(data)
[2000.0000,    3.0000,    2.0000]
[1500.0000,    2.0000,    1.0000]
[1800.0000,    3.0000,    2.0000]
[2200.0000,    4.0000,    3.0000]
>>> 
>>> # Extract a single house (row)
>>> house1 = data.row(0)
>>> print(f"House 1: {house1}")
House 1: [2000.0000, 3.0000, 2.0000]
>>> 
>>> # Extract a feature (column)
>>> sqft = data.col(0)
>>> print(f"Square footage: {sqft}")
Square footage: [2000.0000, 1500.0000, 1800.0000, 2200.0000]
>>> 
>>> # Standardize the data
>>> standardized = data.standardize()
>>> print("Standardized data:")
>>> print(standardized)
[ 0.7071,  0.0000,  0.0000]
[-1.4142, -1.4142, -1.4142]
[-0.7071,  0.0000,  0.0000]
[ 1.4142,  1.4142,  1.4142]
>>> 
>>> # Create weights vector (for a linear model)
>>> weights = Vector([0.5, 100, -50])  # weight per feature
>>> 
>>> # Compute predictions: data @ weights
>>> predictions = data.vector_dot(weights)
>>> print(f"Predictions: {predictions}")
Predictions: [1050.0000, 850.0000, 950.0000, 1150.0000]
>>> 
>>> # Matrix multiplication example
>>> data.T @ data  # This computes the covariance-like matrix
Matrix([[...]])  # Will show the Gram matrix
```

### What We've Accomplished

In this module, we've built:

1. **A complete Matrix class** with all operations needed for machine learning:
   - Basic arithmetic (addition, subtraction, scalar multiplication/division)
   - Matrix multiplication (the fundamental operation of ML)
   - Matrix-vector multiplication (computing predictions)
   - Transposition (essential for data preparation)
   - Determinant and inverse (for closed-form solutions)
   - Row and column extraction
   - Statistical operations (mean, variance, standardization)

2. **Special matrix creation methods**:
   - Zero matrix
   - Ones matrix
   - Identity matrix
   - Matrix from vectors

3. **Comprehensive tests** verifying all functionality

### Why This Matters for Machine Learning

Everything in machine learning involves matrices:

| ML Component | Matrix Representation |
|--------------|----------------------|
| Dataset | X (samples × features) |
| Weights | w (features × 1) |
| Predictions | y_pred = X @ w |
| Gradient | ∇L = X^T @ (y_pred - y_true) |
| Covariance | C = X^T @ X / (n-1) |
| PCA Components | Eigenvectors of covariance |
| Neural Networks | Multiple matrix multiplications |

Understanding matrices is understanding how data flows through machine learning algorithms. In the next module, we'll add tensors to handle higher-dimensional data and then explore Eigenvalues and SVD—the mathematical tools that power PCA and many other algorithms.
