# Phase 1, Part 1: Linear Algebra — The Language of Data

## Module 1: Vectors — The Atoms of Data

### The Target

We're building the foundation of our machine learning pipeline: a complete vector implementation that can represent data points, perform operations, and serve as the building block for matrices and tensors.

**Files we'll create:**
- `src/linear_algebra/__init__.py`
- `src/linear_algebra/vector.py`
- `tests/test_linear_algebra.py`

### The Concept

Imagine you're describing a house you want to buy. You might say it has 2,000 square feet, 3 bedrooms, and 2 bathrooms. In machine learning, we represent this as a **vector**—an ordered list of numbers where each number represents a **feature** (or dimension) of the data point.

Why "vector"? Think of it like an arrow in space:
- A 2D vector `[x, y]` is like a point on a map
- A 3D vector `[x, y, z]` is like a point in a room
- A 100D vector is like a point in a "100-dimensional space" (which we can't visualize, but the math works the same!)

In machine learning, every **data point** is a vector. A dataset is a collection of vectors. This is why linear algebra is called "the language of data"—because it gives us the vocabulary to describe and manipulate data mathematically.

**Key operations we'll implement:**
- Vector addition and subtraction (combining data points)
- Scalar multiplication (scaling data)
- Dot product (measuring similarity between data points)
- Norm (measuring the "length" or magnitude of a data point)
- Distance (measuring how different two data points are)

### The Implementation

Let's start by creating the project structure and our first vector implementation.

#### Step 1: Set Up Project Structure

Create the following directory structure:

```bash
# From your project root
mkdir -p src/linear_algebra
mkdir -p tests
touch src/__init__.py
touch src/linear_algebra/__init__.py
touch tests/__init__.py
```

#### Step 2: Implement the Vector Class

Now let's create our vector implementation. We'll build it from scratch using Python lists for storage, but we'll make it behave like a mathematical vector.

**File: `src/linear_algebra/vector.py`**

```python
"""
Vector implementation for machine learning operations.

This module provides a complete Vector class that supports all
operations needed for linear algebra in machine learning, including
addition, scalar multiplication, dot products, and norms.
"""

from typing import List, Union, Optional
import math
import numbers


class Vector:
    """
    A mathematical vector with operations for machine learning.
    
    A vector represents a point in n-dimensional space, typically
    used to represent a data point with n features.
    
    Attributes:
        data (List[float]): The underlying array of numbers.
        size (int): The dimensionality of the vector.
    
    Examples:
        >>> v = Vector([1.0, 2.0, 3.0])
        >>> v.size
        3
        >>> v[0]
        1.0
    """
    
    def __init__(self, data: List[Union[int, float]]):
        """
        Initialize a vector from a list of numbers.
        
        Args:
            data: List of numbers representing the vector components.
            
        Raises:
            ValueError: If data is empty or contains non-numeric values.
        """
        if not data:
            raise ValueError("Vector cannot be empty")
        if not all(isinstance(x, (int, float)) for x in data):
            raise ValueError("All vector elements must be numbers")
        
        # Convert all elements to float for consistency
        self._data: List[float] = [float(x) for x in data]
        self.size: int = len(self._data)
    
    def __len__(self) -> int:
        """Return the dimension (size) of the vector."""
        return self.size
    
    def __getitem__(self, index: int) -> float:
        """
        Access vector components by index.
        
        Args:
            index: Integer index (0-based).
            
        Returns:
            The component at the given index.
            
        Raises:
            IndexError: If index is out of range.
        """
        if index < 0 or index >= self.size:
            raise IndexError(f"Index {index} out of range for vector of size {self.size}")
        return self._data[index]
    
    def __setitem__(self, index: int, value: Union[int, float]) -> None:
        """
        Set vector components by index.
        
        Args:
            index: Integer index (0-based).
            value: New value for the component.
            
        Raises:
            IndexError: If index is out of range.
            ValueError: If value is not numeric.
        """
        if index < 0 or index >= self.size:
            raise IndexError(f"Index {index} out of range for vector of size {self.size}")
        if not isinstance(value, (int, float)):
            raise ValueError("Value must be a number")
        self._data[index] = float(value)
    
    def __repr__(self) -> str:
        """Return a string representation of the vector."""
        return f"Vector({self._data})"
    
    def __str__(self) -> str:
        """Return a human-readable string representation."""
        return f"[{', '.join(f'{x:.4f}' for x in self._data)}]"
    
    # ==================== BASIC OPERATIONS ====================
    
    def __add__(self, other: 'Vector') -> 'Vector':
        """
        Vector addition: element-wise addition of two vectors.
        
        This is used for combining data points or adding updates
        during optimization.
        
        Args:
            other: Another Vector of the same size.
            
        Returns:
            A new Vector representing the sum.
            
        Raises:
            ValueError: If vectors have different sizes.
            
        Examples:
            >>> v1 = Vector([1, 2, 3])
            >>> v2 = Vector([4, 5, 6])
            >>> v1 + v2
            Vector([5.0, 7.0, 9.0])
        """
        if not isinstance(other, Vector):
            raise TypeError("Can only add Vector to Vector")
        if self.size != other.size:
            raise ValueError(f"Cannot add vectors of different sizes: {self.size} and {other.size}")
        
        return Vector([a + b for a, b in zip(self._data, other._data)])
    
    def __sub__(self, other: 'Vector') -> 'Vector':
        """
        Vector subtraction: element-wise subtraction of two vectors.
        
        Used to compute differences between data points (e.g., for
        computing distances or error terms).
        
        Args:
            other: Another Vector of the same size.
            
        Returns:
            A new Vector representing the difference.
            
        Raises:
            ValueError: If vectors have different sizes.
            
        Examples:
            >>> v1 = Vector([1, 2, 3])
            >>> v2 = Vector([4, 5, 6])
            >>> v1 - v2
            Vector([-3.0, -3.0, -3.0])
        """
        if not isinstance(other, Vector):
            raise TypeError("Can only subtract Vector from Vector")
        if self.size != other.size:
            raise ValueError(f"Cannot subtract vectors of different sizes: {self.size} and {other.size}")
        
        return Vector([a - b for a, b in zip(self._data, other._data)])
    
    def __mul__(self, scalar: Union[int, float]) -> 'Vector':
        """
        Scalar multiplication: multiply all components by a number.
        
        Used for scaling data (e.g., normalizing features or adjusting
        learning rates).
        
        Args:
            scalar: A number to multiply each component by.
            
        Returns:
            A new Vector with all components scaled.
            
        Raises:
            ValueError: If scalar is not numeric.
            
        Examples:
            >>> v = Vector([1, 2, 3])
            >>> v * 2
            Vector([2.0, 4.0, 6.0])
        """
        if not isinstance(scalar, (int, float)):
            raise ValueError("Scalar must be a number")
        
        return Vector([x * scalar for x in self._data])
    
    def __rmul__(self, scalar: Union[int, float]) -> 'Vector':
        """
        Reverse scalar multiplication (for scalar * vector notation).
        
        Args:
            scalar: A number to multiply each component by.
            
        Returns:
            A new Vector with all components scaled.
            
        Examples:
            >>> v = Vector([1, 2, 3])
            >>> 2 * v
            Vector([2.0, 4.0, 6.0])
        """
        return self.__mul__(scalar)
    
    def __truediv__(self, scalar: Union[int, float]) -> 'Vector':
        """
        Scalar division: divide all components by a number.
        
        Used for normalization and averaging operations.
        
        Args:
            scalar: A number to divide each component by.
            
        Returns:
            A new Vector with all components divided.
            
        Raises:
            ValueError: If scalar is zero or not numeric.
            
        Examples:
            >>> v = Vector([2, 4, 6])
            >>> v / 2
            Vector([1.0, 2.0, 3.0])
        """
        if not isinstance(scalar, (int, float)):
            raise ValueError("Scalar must be a number")
        if scalar == 0:
            raise ValueError("Cannot divide by zero")
        
        return Vector([x / scalar for x in self._data])
    
    # ==================== DOT PRODUCT AND SIMILARITY ====================
    
    def dot(self, other: 'Vector') -> float:
        """
        Compute the dot product (inner product) of two vectors.
        
        The dot product measures similarity between vectors. In machine
        learning, it's used for:
        - Computing weighted sums (e.g., linear regression predictions)
        - Measuring similarity between feature vectors
        - Computing projections
        
        Mathematical formula: dot(a,b) = Σ(a_i * b_i)
        
        Args:
            other: Another Vector of the same size.
            
        Returns:
            A scalar representing the dot product.
            
        Raises:
            ValueError: If vectors have different sizes.
            
        Examples:
            >>> v1 = Vector([1, 2, 3])
            >>> v2 = Vector([4, 5, 6])
            >>> v1.dot(v2)
            32.0  # (1*4 + 2*5 + 3*6 = 32)
        """
        if not isinstance(other, Vector):
            raise TypeError("Can only compute dot product with another Vector")
        if self.size != other.size:
            raise ValueError(f"Cannot compute dot product of vectors of different sizes: {self.size} and {other.size}")
        
        return sum(a * b for a, b in zip(self._data, other._data))
    
    # ==================== NORMS AND DISTANCES ====================
    
    def norm(self, p: int = 2) -> float:
        """
        Compute the p-norm of the vector.
        
        The norm measures the "length" or magnitude of a vector.
        Different norms are useful for different purposes:
        - L1 (p=1): Sum of absolute values, good for sparse features
        - L2 (p=2): Euclidean distance, most common in ML
        - L∞ (p=infinity): Maximum absolute value
        
        In machine learning, norms are used for:
        - Regularization (L1 and L2 regularization)
        - Measuring vector magnitude
        - Gradient clipping in deep learning
        
        Mathematical formula: ||v||_p = (Σ|v_i|^p)^(1/p)
        
        Args:
            p: The degree of the norm (1, 2, or float('inf')).
            
        Returns:
            The p-norm value.
            
        Examples:
            >>> v = Vector([3, 4])
            >>> v.norm(2)  # Euclidean norm
            5.0  # sqrt(3^2 + 4^2) = 5
            >>> v.norm(1)  # L1 norm
            7.0  # |3| + |4| = 7
        """
        if p == float('inf'):
            return max(abs(x) for x in self._data)
        if p == 1:
            return sum(abs(x) for x in self._data)
        if p == 2:
            return math.sqrt(sum(x * x for x in self._data))
        
        # General p-norm
        return sum(abs(x) ** p for x in self._data) ** (1.0 / p)
    
    def distance(self, other: 'Vector', p: int = 2) -> float:
        """
        Compute the distance between two vectors using the p-norm.
        
        This is useful for measuring how different two data points are.
        In machine learning, it's used in:
        - K-Nearest Neighbors (KNN) algorithms
        - Clustering (k-means)
        - Anomaly detection
        
        Args:
            other: Another Vector of the same size.
            p: The degree of the norm (1, 2, or float('inf')).
            
        Returns:
            The distance between the vectors.
            
        Examples:
            >>> v1 = Vector([0, 0])
            >>> v2 = Vector([3, 4])
            >>> v1.distance(v2, 2)
            5.0  # Euclidean distance
        """
        if not isinstance(other, Vector):
            raise TypeError("Can only compute distance with another Vector")
        if self.size != other.size:
            raise ValueError(f"Cannot compute distance between vectors of different sizes: {self.size} and {other.size}")
        
        diff = self - other
        return diff.norm(p)
    
    # ==================== UTILITY OPERATIONS ====================
    
    def mean(self) -> float:
        """
        Compute the mean (average) of all components.
        
        Used for centering data during preprocessing.
        
        Returns:
            The mean value.
            
        Examples:
            >>> v = Vector([1, 2, 3, 4])
            >>> v.mean()
            2.5
        """
        return sum(self._data) / self.size
    
    def variance(self, ddof: int = 0) -> float:
        """
        Compute the variance of the components.
        
        Used for understanding feature spread and for normalization.
        
        Args:
            ddof: Delta degrees of freedom (0 for population, 1 for sample).
            
        Returns:
            The variance value.
            
        Examples:
            >>> v = Vector([1, 2, 3, 4])
            >>> v.variance()
            1.25  # population variance
            >>> v.variance(ddof=1)
            1.666...  # sample variance
        """
        if self.size <= ddof:
            raise ValueError("Not enough data points to compute variance")
        
        m = self.mean()
        squared_deviations = sum((x - m) ** 2 for x in self._data)
        return squared_deviations / (self.size - ddof)
    
    def standardize(self) -> 'Vector':
        """
        Standardize the vector (z-score normalization).
        
        Transforms the data so that mean = 0 and standard deviation = 1.
        This is a crucial preprocessing step in many ML algorithms.
        
        Returns:
            A new Vector with standardized components.
            
        Examples:
            >>> v = Vector([1, 2, 3, 4])
            >>> v.standardize()
            Vector([-1.3416, -0.4472, 0.4472, 1.3416])  # approximate
        """
        if self.size < 2:
            raise ValueError("Cannot standardize vector with fewer than 2 elements")
        
        mean = self.mean()
        std = math.sqrt(self.variance(ddof=1))  # sample standard deviation
        
        if std == 0:
            raise ValueError("Cannot standardize vector with zero variance")
        
        return Vector([(x - mean) / std for x in self._data])
    
    def normalize(self) -> 'Vector':
        """
        Normalize the vector to unit length (L2 normalization).
        
        This preserves direction but scales the magnitude to 1.
        Used in many ML algorithms where only direction matters
        (e.g., cosine similarity).
        
        Returns:
            A new Vector with unit L2 norm.
            
        Raises:
            ValueError: If the vector is a zero vector.
            
        Examples:
            >>> v = Vector([3, 4])
            >>> v.normalize()
            Vector([0.6, 0.8])  # unit vector in same direction
        """
        norm = self.norm(2)
        if norm == 0:
            raise ValueError("Cannot normalize zero vector")
        return self / norm
    
    def to_list(self) -> List[float]:
        """
        Convert the vector to a Python list.
        
        Returns:
            A list of the vector components.
        """
        return self._data.copy()
    
    def zeros(self, size: int) -> 'Vector':
        """
        Create a zero vector of the given size (class method).
        
        Args:
            size: The dimensionality of the vector.
            
        Returns:
            A Vector of the given size with all components zero.
        """
        return Vector([0.0] * size)
    
    @classmethod
    def zeros(cls, size: int) -> 'Vector':
        """
        Create a zero vector of the given size.
        
        Args:
            size: The dimensionality of the vector.
            
        Returns:
            A Vector of the given size with all components zero.
        """
        return cls([0.0] * size)
    
    @classmethod
    def ones(cls, size: int) -> 'Vector':
        """
        Create a vector of ones of the given size.
        
        Args:
            size: The dimensionality of the vector.
            
        Returns:
            A Vector of the given size with all components one.
        """
        return cls([1.0] * size)
    
    def __eq__(self, other) -> bool:
        """
        Check equality between two vectors.
        
        Args:
            other: Another Vector.
            
        Returns:
            True if vectors have the same components, False otherwise.
        """
        if not isinstance(other, Vector):
            return False
        if self.size != other.size:
            return False
        return all(a == b for a, b in zip(self._data, other._data))
```

#### Step 3: Create the Test Suite

Now let's create a comprehensive test suite to verify our vector implementation works correctly.

**File: `tests/test_linear_algebra.py`**

```python
"""
Unit tests for the linear algebra module.
"""

import pytest
import math
from src.linear_algebra.vector import Vector


class TestVector:
    """Test suite for the Vector class."""
    
    def test_initialization(self):
        """Test that vectors are initialized correctly."""
        v = Vector([1, 2, 3])
        assert v.size == 3
        assert v[0] == 1.0
        assert v[1] == 2.0
        assert v[2] == 3.0
        
        # Test with floats
        v = Vector([1.0, 2.5, 3.7])
        assert v[1] == 2.5
    
    def test_initialization_errors(self):
        """Test that initialization fails with invalid inputs."""
        with pytest.raises(ValueError, match="Vector cannot be empty"):
            Vector([])
        
        with pytest.raises(ValueError, match="All vector elements must be numbers"):
            Vector([1, "two", 3])
    
    def test_len(self):
        """Test the __len__ method."""
        v = Vector([1, 2, 3])
        assert len(v) == 3
    
    def test_getitem_setitem(self):
        """Test indexing and item assignment."""
        v = Vector([1, 2, 3])
        
        # Get
        assert v[0] == 1.0
        
        # Set
        v[0] = 10.0
        assert v[0] == 10.0
        
        # Invalid indices
        with pytest.raises(IndexError):
            v[3]  # Out of range
        
        with pytest.raises(IndexError):
            v[-4]  # Out of range
    
    def test_add(self):
        """Test vector addition."""
        v1 = Vector([1, 2, 3])
        v2 = Vector([4, 5, 6])
        result = v1 + v2
        
        assert result.size == 3
        assert result[0] == 5.0
        assert result[1] == 7.0
        assert result[2] == 9.0
        
        # Test different sizes
        v3 = Vector([1, 2])
        with pytest.raises(ValueError, match="Cannot add vectors of different sizes"):
            v1 + v3
    
    def test_sub(self):
        """Test vector subtraction."""
        v1 = Vector([4, 5, 6])
        v2 = Vector([1, 2, 3])
        result = v1 - v2
        
        assert result[0] == 3.0
        assert result[1] == 3.0
        assert result[2] == 3.0
        
        # Test different sizes
        v3 = Vector([1, 2])
        with pytest.raises(ValueError, match="Cannot subtract vectors of different sizes"):
            v1 - v3
    
    def test_scalar_multiplication(self):
        """Test scalar multiplication."""
        v = Vector([1, 2, 3])
        
        result1 = v * 2
        assert result1[0] == 2.0
        assert result1[1] == 4.0
        assert result1[2] == 6.0
        
        result2 = 2 * v
        assert result2 == result1
        
        result3 = v * 0.5
        assert result3[0] == 0.5
        assert result3[1] == 1.0
        assert result3[2] == 1.5
    
    def test_scalar_division(self):
        """Test scalar division."""
        v = Vector([2, 4, 6])
        result = v / 2
        
        assert result[0] == 1.0
        assert result[1] == 2.0
        assert result[2] == 3.0
        
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            v / 0
    
    def test_dot_product(self):
        """Test dot product computation."""
        v1 = Vector([1, 2, 3])
        v2 = Vector([4, 5, 6])
        
        dot = v1.dot(v2)
        assert dot == 32.0  # 1*4 + 2*5 + 3*6 = 32
        
        # Test with negative numbers
        v3 = Vector([-1, 2, -3])
        v4 = Vector([4, -5, 6])
        dot = v3.dot(v4)
        assert dot == -32.0  # -1*4 + 2*(-5) + (-3)*6 = -4 -10 -18 = -32
        
        # Test different sizes
        v5 = Vector([1, 2])
        with pytest.raises(ValueError, match="Cannot compute dot product of vectors of different sizes"):
            v1.dot(v5)
    
    def test_norm(self):
        """Test norm computation."""
        v = Vector([3, 4])
        
        # L2 norm (Euclidean)
        assert v.norm(2) == 5.0
        
        # L1 norm
        assert v.norm(1) == 7.0
        
        # L∞ norm (max norm)
        assert v.norm(float('inf')) == 4.0
        
        # Test with complex vector
        v2 = Vector([1, -2, 3, -4])
        assert v2.norm(2) == math.sqrt(30)  # 1 + 4 + 9 + 16 = 30
        assert v2.norm(1) == 10  # 1 + 2 + 3 + 4 = 10
        assert v2.norm(float('inf')) == 4
    
    def test_distance(self):
        """Test distance computation."""
        v1 = Vector([0, 0])
        v2 = Vector([3, 4])
        
        # Euclidean distance
        assert v1.distance(v2, 2) == 5.0
        
        # L1 distance (Manhattan)
        assert v1.distance(v2, 1) == 7.0
        
        # Test same point
        v3 = Vector([1, 2])
        assert v3.distance(v3, 2) == 0.0
    
    def test_mean(self):
        """Test mean computation."""
        v = Vector([1, 2, 3, 4])
        assert v.mean() == 2.5
        
        v2 = Vector([-1, 0, 1])
        assert v2.mean() == 0.0
    
    def test_variance(self):
        """Test variance computation."""
        v = Vector([1, 2, 3, 4])
        
        # Population variance
        assert v.variance() == 1.25
        
        # Sample variance
        assert v.variance(ddof=1) == pytest.approx(1.666666, rel=1e-6)
        
        # Test with single value
        v2 = Vector([5])
        with pytest.raises(ValueError, match="Not enough data points"):
            v2.variance()
    
    def test_standardize(self):
        """Test standardization."""
        v = Vector([1, 2, 3, 4])
        standardized = v.standardize()
        
        # Mean should be approximately 0
        assert standardized.mean() == pytest.approx(0, abs=1e-10)
        
        # Variance should be approximately 1
        assert standardized.variance(ddof=1) == pytest.approx(1, abs=1e-10)
        
        # Test with zero variance
        v2 = Vector([1, 1, 1])
        with pytest.raises(ValueError, match="zero variance"):
            v2.standardize()
    
    def test_normalize(self):
        """Test vector normalization."""
        v = Vector([3, 4])
        normalized = v.normalize()
        
        # Norm should be 1
        assert normalized.norm(2) == pytest.approx(1.0)
        
        # Direction should be preserved
        assert normalized[0] == 0.6
        assert normalized[1] == 0.8
        
        # Test with zero vector
        v2 = Vector([0, 0])
        with pytest.raises(ValueError, match="Cannot normalize zero vector"):
            v2.normalize()
    
    def test_to_list(self):
        """Test conversion to list."""
        v = Vector([1, 2, 3])
        lst = v.to_list()
        
        assert lst == [1.0, 2.0, 3.0]
        
        # Should be a copy
        lst[0] = 100
        assert v[0] == 1.0  # Original unchanged
    
    def test_class_methods(self):
        """Test class factory methods."""
        zeros = Vector.zeros(3)
        assert zeros.size == 3
        assert zeros[0] == 0.0
        assert zeros[1] == 0.0
        assert zeros[2] == 0.0
        
        ones = Vector.ones(3)
        assert ones[0] == 1.0
        assert ones[1] == 1.0
        assert ones[2] == 1.0
    
    def test_equality(self):
        """Test vector equality."""
        v1 = Vector([1, 2, 3])
        v2 = Vector([1, 2, 3])
        v3 = Vector([4, 5, 6])
        
        assert v1 == v2
        assert v1 != v3
        assert v1 != "not a vector"
    
    def test_repr_str(self):
        """Test string representations."""
        v = Vector([1.0, 2.0, 3.0])
        
        repr_str = repr(v)
        assert "Vector" in repr_str
        
        str_str = str(v)
        assert "1.0000" in str_str
        assert "2.0000" in str_str
        assert "3.0000" in str_str
```

### The Verification

Now let's verify our implementation works correctly.

#### Step 1: Run the Tests

Navigate to your project root and run:

```bash
# From the project root directory
pytest tests/test_linear_algebra.py -v
```

You should see output similar to:

```
==================== test session starts ====================
collected 15 items

tests/test_linear_algebra.py::TestVector::test_initialization PASSED
tests/test_linear_algebra.py::TestVector::test_initialization_errors PASSED
tests/test_linear_algebra.py::TestVector::test_len PASSED
tests/test_linear_algebra.py::TestVector::test_getitem_setitem PASSED
tests/test_linear_algebra.py::TestVector::test_add PASSED
tests/test_linear_algebra.py::TestVector::test_sub PASSED
tests/test_linear_algebra.py::TestVector::test_scalar_multiplication PASSED
tests/test_linear_algebra.py::TestVector::test_scalar_division PASSED
tests/test_linear_algebra.py::TestVector::test_dot_product PASSED
tests/test_linear_algebra.py::TestVector::test_norm PASSED
tests/test_linear_algebra.py::TestVector::test_distance PASSED
tests/test_linear_algebra.py::TestVector::test_mean PASSED
tests/test_linear_algebra.py::TestVector::test_variance PASSED
tests/test_linear_algebra.py::TestVector::test_standardize PASSED
tests/test_linear_algebra.py::TestVector::test_normalize PASSED
tests/test_linear_algebra.py::TestVector::test_to_list PASSED
tests/test_linear_algebra.py::TestVector::test_class_methods PASSED
tests/test_linear_algebra.py::TestVector::test_equality PASSED
tests/test_linear_algebra.py::TestVector::test_repr_str PASSED

==================== 18 passed in 0.12s ====================
```

If all tests pass, congratulations! Your vector implementation is working correctly.

#### Step 2: Interactive Verification

Let's also test the vector operations interactively:

```bash
# From the project root
python
```

Then in the Python interpreter:

```python
>>> from src.linear_algebra.vector import Vector
>>> 
>>> # Create vectors representing two houses
>>> house1 = Vector([2000, 3, 2])   # [sqft, bedrooms, bathrooms]
>>> house2 = Vector([1500, 2, 1])
>>> 
>>> # Add them (combining features)
>>> combined = house1 + house2
>>> print(combined)
[3500.0000, 5.0000, 3.0000]
>>> 
>>> # Find the difference
>>> diff = house1 - house2
>>> print(diff)
[500.0000, 1.0000, 1.0000]
>>> 
>>> # Compute similarity (dot product)
>>> similarity = house1.dot(house2)
>>> print(f"Similarity score: {similarity}")
Similarity score: 3008000.0
>>> 
>>> # Compute Euclidean distance
>>> distance = house1.distance(house2)
>>> print(f"Distance: {distance:.2f}")
Distance: 500.00
>>> 
>>> # Normalize the features
>>> house1_normalized = house1.normalize()
>>> print(house1_normalized)
[0.9999, 0.0015, 0.0010]
```

### What We've Accomplished

In this module, we've built:

1. **A complete Vector class** with all operations needed for machine learning:
   - Basic arithmetic (addition, subtraction, scalar multiplication, scalar division)
   - Dot product for similarity measurement
   - Norms for measuring magnitude
   - Distance functions for measuring differences
   - Utility functions (mean, variance, standardization, normalization)

2. **A comprehensive test suite** that verifies our implementation works correctly

3. **Real-world examples** showing how vectors represent data points

### Why This Matters for Machine Learning

Every machine learning model you'll ever use operates on vectors:

- **Data points** are vectors (e.g., a house with features)
- **Labels/targets** are vectors (for multi-output problems)
- **Weights** in models are vectors (e.g., coefficients in linear regression)
- **Gradients** are vectors (direction and magnitude of updates)
- **Representations** (embeddings) are vectors (word embeddings, image features)

Understanding how vectors work is the first step toward understanding how machine learning works. In the next module, we'll build on this foundation to create matrices—the structure for representing entire datasets.
