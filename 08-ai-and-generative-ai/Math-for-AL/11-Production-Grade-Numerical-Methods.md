# Phase 4, Part 1: Numerical Stability and Production ML

## Module 1: Production-Grade Numerical Methods

### The Target

We're building the production foundation for our machine learning system. This module covers numerical stability, performance optimization, error handling, and the integration of all previous components into a cohesive, production-ready ML pipeline.

**Files we'll create:**
- `src/numerical/__init__.py`
- `src/numerical/stability.py`
- `src/numerical/performance.py`
- `src/pipeline/__init__.py`
- `src/pipeline/data_pipeline.py`
- `src/pipeline/model_pipeline.py`
- `tests/test_numerical.py`

### The Concept

Imagine you're building a bridge. You can't just throw materials together and hope it stands. You need to account for:
- **Structural integrity**: Will it handle the load?
- **Safety margins**: What if conditions are worse than expected?
- **Maintenance**: How will it perform over time?

**Numerical stability** is the engineering of mathematical computation. It's about ensuring your code:
1. **Produces correct results** (accuracy)
2. **Handles edge cases gracefully** (robustness)
3. **Runs efficiently** (performance)
4. **Works in production** (reliability)

**Key numerical issues in ML:**

| Issue | Example | Impact |
|-------|---------|--------|
| **Floating-point precision** | Adding very large and very small numbers | Cancellation errors |
| **Overflow/underflow** | Computing exp(1000) | NaN or Inf |
| **Ill-conditioning** | Near-singular matrices | Unstable solutions |
| **Catastrophic cancellation** | Subtracting nearly equal numbers | Loss of precision |

**Why this matters**: In research, you can ignore these issues. In production, they'll break your system.

### The Implementation

#### Step 1: Implement Numerical Stability Utilities

**File: `src/numerical/__init__.py`**

```python
"""
Numerical methods for production machine learning.

This package provides:
- Numerical stability utilities
- Performance optimization
- Production-ready algorithms
"""

from src.numerical.stability import NumericalStability, SafeMath
from src.numerical.performance import PerformanceOptimizer

__all__ = ['NumericalStability', 'SafeMath', 'PerformanceOptimizer']
```

**File: `src/numerical/stability.py`**

```python
"""
Numerical stability utilities for production ML.

This module provides tools to ensure numerical stability in
machine learning computations, including:
- Safe mathematical operations
- Log-sum-exp trick
- Stable softmax
- Gradient clipping
- Parameter regularization
"""

import math
from typing import List, Tuple, Optional, Union
from src.linear_algebra import Vector, Matrix


class SafeMath:
    """
    Safe mathematical operations with numerical stability.
    
    Provides stable implementations of common operations that
    are prone to numerical issues.
    """
    
    @staticmethod
    def safe_exp(x: float, max_val: float = 700.0) -> float:
        """
        Safe exponential function with overflow protection.
        
        exp(x) overflows for x > ~709. This caps the input.
        
        Args:
            x: Input value.
            max_val: Maximum value before saturation.
            
        Returns:
            exp(x) capped to avoid overflow.
        """
        if x > max_val:
            return math.exp(max_val)
        if x < -max_val:
            return 0.0
        return math.exp(x)
    
    @staticmethod
    def safe_log(x: float, epsilon: float = 1e-12) -> float:
        """
        Safe logarithm with protection against non-positive inputs.
        
        Args:
            x: Input value (must be > 0).
            epsilon: Small constant for numerical safety.
            
        Returns:
            log(max(x, epsilon))
        """
        return math.log(max(x, epsilon))
    
    @staticmethod
    def safe_sqrt(x: float, epsilon: float = 1e-12) -> float:
        """
        Safe square root with protection against negative inputs.
        
        Args:
            x: Input value.
            epsilon: Small constant for numerical safety.
            
        Returns:
            sqrt(max(x, 0))
        """
        return math.sqrt(max(x, epsilon))
    
    @staticmethod
    def safe_division(numerator: float, denominator: float, 
                     epsilon: float = 1e-12) -> float:
        """
        Safe division with protection against division by zero.
        
        Args:
            numerator: Numerator.
            denominator: Denominator.
            epsilon: Small constant for numerical safety.
            
        Returns:
            numerator / max(abs(denominator), epsilon) * sign(denominator)
        """
        if abs(denominator) < epsilon:
            return numerator * (1.0 / epsilon) if numerator > 0 else -numerator * (1.0 / epsilon)
        return numerator / denominator
    
    @staticmethod
    def log_sum_exp(values: Vector) -> float:
        """
        Log-sum-exp trick for numerical stability.
        
        log(sum(exp(v_i))) = max(v) + log(sum(exp(v_i - max(v))))
        
        This avoids overflow when computing the log of a sum of exponentials.
        Used in: softmax, log-likelihood, probability normalization.
        
        Args:
            values: Vector of values.
            
        Returns:
            log(sum(exp(values)))
        """
        max_val = max(values[i] for i in range(values.size))
        
        # Compute exp(v_i - max_val)
        exp_vals = [math.exp(values[i] - max_val) for i in range(values.size)]
        
        return max_val + math.log(sum(exp_vals))
    
    @staticmethod
    def stable_softmax(logits: Vector) -> Vector:
        """
        Stable softmax using the log-sum-exp trick.
        
        softmax(x)_i = exp(x_i) / sum(exp(x_j))
        
        This version subtracts the maximum for numerical stability.
        
        Args:
            logits: Input logits.
            
        Returns:
            Softmax probabilities.
        """
        max_val = max(logits[i] for i in range(logits.size))
        
        # Compute exp(x_i - max)
        exp_vals = [math.exp(logits[i] - max_val) for i in range(logits.size)]
        sum_exp = sum(exp_vals)
        
        # Normalize
        return Vector([exp_vals[i] / sum_exp for i in range(len(exp_vals))])
    
    @staticmethod
    def stable_sigmoid(x: float) -> float:
        """
        Stable sigmoid function.
        
        sigmoid(x) = 1 / (1 + exp(-x))
        
        This version avoids overflow for large negative values.
        """
        if x >= 0:
            # For positive x, use: sigmoid = 1 / (1 + exp(-x))
            # This is stable for large positive x
            z = math.exp(-x)
            return 1.0 / (1.0 + z)
        else:
            # For negative x, use: sigmoid = exp(x) / (1 + exp(x))
            # This is stable for large negative x
            z = math.exp(x)
            return z / (1.0 + z)


class NumericalStability:
    """
    Complete numerical stability utilities for production ML.
    
    Provides:
    - Gradient clipping
    - Parameter regularization
    - Matrix conditioning
    - Log-likelihood computation
    - Loss stabilization
    """
    
    @staticmethod
    def clip_gradient(gradient: Vector, max_norm: float = 1.0) -> Vector:
        """
        Clip gradient to prevent exploding gradients.
        
        Gradient clipping is essential for training deep networks
        where gradients can become extremely large.
        
        Args:
            gradient: Gradient vector.
            max_norm: Maximum allowed L2 norm.
            
        Returns:
            Clipped gradient.
        """
        norm = gradient.norm(2)
        
        if norm <= max_norm or norm == 0:
            return gradient
        
        # Scale to max_norm
        scale = max_norm / norm
        return gradient * scale
    
    @staticmethod
    def clip_gradient_matrix(gradient: Matrix, max_norm: float = 1.0) -> Matrix:
        """Clip gradient matrix."""
        norm = 0.0
        for i in range(gradient.rows):
            for j in range(gradient.cols):
                norm += gradient[i, j] ** 2
        norm = math.sqrt(norm)
        
        if norm <= max_norm or norm == 0:
            return gradient
        
        scale = max_norm / norm
        data = [[gradient[i, j] * scale for j in range(gradient.cols)] 
                for i in range(gradient.rows)]
        return Matrix(data)
    
    @staticmethod
    def add_l2_regularization(weights: Vector, lambda_reg: float) -> float:
        """
        Compute L2 regularization penalty.
        
        L2 penalty = (lambda / 2) * ||w||²
        
        Args:
            weights: Weight vector.
            lambda_reg: Regularization strength.
            
        Returns:
            Regularization penalty.
        """
        return (lambda_reg / 2) * weights.norm(2) ** 2
    
    @staticmethod
    def add_l1_regularization(weights: Vector, lambda_reg: float) -> float:
        """
        Compute L1 regularization penalty.
        
        L1 penalty = lambda * ||w||_1
        
        Args:
            weights: Weight vector.
            lambda_reg: Regularization strength.
            
        Returns:
            Regularization penalty.
        """
        return lambda_reg * weights.norm(1)
    
    @staticmethod
    def condition_number(matrix: Matrix) -> float:
        """
        Compute the condition number of a matrix.
        
        The condition number measures how sensitive the matrix is
        to small changes. High condition number = ill-conditioned.
        
        Args:
            matrix: Square matrix.
            
        Returns:
            Condition number.
        """
        if not matrix.is_square():
            raise ValueError("Condition number only defined for square matrices")
        
        # Use SVD to compute singular values
        from src.linear_algebra.decomposition import Decomposition
        U, S, Vt = Decomposition.svd(matrix)
        
        # Extract singular values (diagonal of S)
        singular_values = [S[i, i] for i in range(min(S.rows, S.cols))]
        singular_values = [s for s in singular_values if s > 1e-10]
        
        if not singular_values:
            return float('inf')
        
        max_s = max(singular_values)
        min_s = min(singular_values)
        
        return max_s / min_s if min_s > 0 else float('inf')
    
    @staticmethod
    def stable_log_likelihood(probabilities: Vector, targets: Vector) -> float:
        """
        Compute log-likelihood with numerical stability.
        
        Log-likelihood = sum(target_i * log(prob_i))
        
        Args:
            probabilities: Predicted probabilities.
            targets: One-hot encoded targets.
            
        Returns:
            Log-likelihood.
        """
        epsilon = 1e-10
        log_likelihood = 0.0
        
        for i in range(probabilities.size):
            if targets[i] > 0.5:
                log_likelihood += SafeMath.safe_log(probabilities[i], epsilon)
        
        return log_likelihood
    
    @staticmethod
    def stable_cross_entropy(predictions: Vector, targets: Vector) -> float:
        """
        Compute cross-entropy loss with numerical stability.
        
        Cross-entropy = -sum(target_i * log(pred_i))
        
        Args:
            predictions: Predicted probabilities (from softmax).
            targets: One-hot encoded targets.
            
        Returns:
            Cross-entropy loss.
        """
        epsilon = 1e-10
        
        # Clip predictions to avoid log(0)
        clipped_preds = Vector([max(min(predictions[i], 1 - epsilon), epsilon) 
                              for i in range(predictions.size)])
        
        loss = -SafeMath.log_sum_exp(clipped_preds * targets)
        return loss / predictions.size
    
    @staticmethod
    def stable_mse(predictions: Vector, targets: Vector) -> float:
        """
        Compute MSE with numerical stability.
        
        This version handles large values that could cause overflow.
        """
        # Scale inputs to prevent overflow
        max_pred = max(abs(predictions[i]) for i in range(predictions.size))
        max_target = max(abs(targets[i]) for i in range(targets.size))
        
        if max_pred > 1e10 or max_target > 1e10:
            # Scale down, compute MSE, scale back
            scale_pred = 1.0 / max_pred if max_pred > 0 else 1.0
            scale_target = 1.0 / max_target if max_target > 0 else 1.0
            
            scaled_preds = predictions * scale_pred
            scaled_targets = targets * scale_target
            
            mse_scaled = sum((scaled_preds[i] - scaled_targets[i]) ** 2 
                           for i in range(predictions.size)) / predictions.size
            
            # Unscale: (pred/scale_pred - target/scale_target)^2
            # For equal scaling, this simplifies
            if max_pred == max_target:
                return mse_scaled * (max_pred ** 2)
        
        # Normal computation
        return sum((predictions[i] - targets[i]) ** 2 
                  for i in range(predictions.size)) / predictions.size
    
    @staticmethod
    def is_stable(matrix: Matrix, threshold: float = 1e-12) -> bool:
        """
        Check if a matrix is numerically stable.
        
        Checks:
        - No NaN or Inf values
        - Not ill-conditioned
        - Not singular
        """
        # Check for NaN/Inf
        for i in range(matrix.rows):
            for j in range(matrix.cols):
                if not math.isfinite(matrix[i, j]):
                    return False
        
        # If square, check condition number
        if matrix.is_square():
            try:
                cond = NumericalStability.condition_number(matrix)
                if cond > 1e12:
                    return False
            except:
                return False
        
        return True
    
    @staticmethod
    def make_stable(matrix: Matrix, epsilon: float = 1e-10) -> Matrix:
        """
        Make a matrix numerically stable.
        
        - Replace NaN/Inf with epsilon
        - Add small epsilon to diagonal for singular matrices
        """
        data = [[matrix[i, j] for j in range(matrix.cols)] 
                for i in range(matrix.rows)]
        
        for i in range(matrix.rows):
            for j in range(matrix.cols):
                if not math.isfinite(data[i][j]):
                    data[i][j] = epsilon
                elif abs(data[i][j]) < 1e-15:
                    # Very small values can cause issues
                    data[i][j] = epsilon if data[i][j] >= 0 else -epsilon
        
        # For square matrices, add epsilon to diagonal if needed
        if matrix.is_square():
            # Check if singular
            try:
                from src.linear_algebra.decomposition import Decomposition
                U, S, Vt = Decomposition.svd(matrix)
                min_s = min([S[i, i] for i in range(min(S.rows, S.cols)) if S[i, i] > 0])
                if min_s < 1e-10:
                    # Add epsilon to diagonal for stability
                    for i in range(matrix.rows):
                        data[i][i] += epsilon
            except:
                for i in range(matrix.rows):
                    data[i][i] += epsilon
        
        return Matrix(data)
```

#### Step 2: Implement Performance Optimization

**File: `src/numerical/performance.py`**

```python
"""
Performance optimization for production ML.

This module provides:
- Vectorization utilities
- Memory optimization
- Caching
- Efficient operations
"""

from typing import List, Tuple, Optional, Dict, Any
import time
import functools
from src.linear_algebra import Matrix, Vector


class PerformanceOptimizer:
    """
    Performance optimization utilities for ML computations.
    """
    
    @staticmethod
    def profile(func):
        """
        Decorator to profile function execution time.
        
        Example:
            @PerformanceOptimizer.profile
            def my_function():
                pass
        """
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            result = func(*args, **kwargs)
            elapsed = time.time() - start_time
            print(f"{func.__name__} took {elapsed:.4f} seconds")
            return result
        return wrapper
    
    @staticmethod
    def cache_result(func):
        """
        Decorator to cache function results.
        
        Caches results based on input arguments.
        Useful for expensive computations that are repeated.
        """
        cache = {}
        
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Create cache key from arguments
            key = str(args) + str(kwargs)
            if key not in cache:
                cache[key] = func(*args, **kwargs)
            return cache[key]
        
        wrapper.cache = cache
        return wrapper
    
    @staticmethod
    def batch_operation(operation, items, batch_size: int = 1000):
        """
        Process items in batches to manage memory.
        
        Args:
            operation: Function to apply to each batch.
            items: Iterable of items.
            batch_size: Size of each batch.
            
        Returns:
            Combined results from all batches.
        """
        results = []
        current_batch = []
        
        for item in items:
            current_batch.append(item)
            if len(current_batch) >= batch_size:
                batch_result = operation(current_batch)
                results.append(batch_result)
                current_batch = []
        
        if current_batch:
            batch_result = operation(current_batch)
            results.append(batch_result)
        
        return results
    
    @staticmethod
    def memory_efficient_dot(X: Matrix, y: Vector) -> Vector:
        """
        Compute X^T @ y efficiently (memory-wise).
        
        This avoids creating intermediate large matrices.
        """
        result_data = [0.0] * X.cols
        
        for j in range(X.cols):
            # Compute dot product without creating temporary vectors
            total = 0.0
            for i in range(X.rows):
                total += X[i, j] * y[i]
            result_data[j] = total
        
        return Vector(result_data)
    
    @staticmethod
    def vectorized_distance(X1: Matrix, X2: Matrix) -> Matrix:
        """
        Compute pairwise distances between all samples in X1 and X2.
        
        Uses the identity:
        ||a - b||² = ||a||² + ||b||² - 2 * a^T * b
        
        This is much faster than looping.
        """
        n1 = X1.rows
        n2 = X2.rows
        
        # Compute squared norms
        norms1_data = [sum(X1[i, j] ** 2 for j in range(X1.cols)) for i in range(n1)]
        norms2_data = [sum(X2[i, j] ** 2 for j in range(X2.cols)) for i in range(n2)]
        
        norms1 = Matrix([[n] for n in norms1_data])
        norms2 = Matrix([[n] for n in norms2_data])
        
        # Compute squared distances
        distances_data = []
        for i in range(n1):
            row = []
            for j in range(n2):
                # ||x_i||² + ||x_j||² - 2 * x_i^T * x_j
                dot = sum(X1[i, k] * X2[j, k] for k in range(X1.cols))
                dist = norms1_data[i] + norms2_data[j] - 2 * dot
                row.append(max(0, dist))  # Numerical stability
            distances_data.append(row)
        
        return Matrix(distances_data)
    
    @staticmethod
    def efficient_matrix_inverse(matrix: Matrix, eps: float = 1e-10) -> Matrix:
        """
        Efficient matrix inverse with numerical stability.
        
        For large matrices, this uses the adjugate method for 2x2,
        and SVD-based pseudo-inverse for larger matrices.
        """
        n = matrix.rows
        
        if n == 1:
            return Matrix([[1.0 / (matrix[0, 0] + eps)]])
        
        if n == 2:
            # Fast 2x2 inverse
            a, b = matrix[0, 0], matrix[0, 1]
            c, d = matrix[1, 0], matrix[1, 1]
            det = a * d - b * c
            if abs(det) < eps:
                # Use pseudo-inverse
                return PerformanceOptimizer.pseudo_inverse(matrix)
            return Matrix([[d, -b], [-c, a]]) / det
        
        # For larger matrices, use LU decomposition or SVD
        try:
            return matrix.inverse()
        except:
            return PerformanceOptimizer.pseudo_inverse(matrix)
    
    @staticmethod
    def pseudo_inverse(matrix: Matrix, eps: float = 1e-10) -> Matrix:
        """
        Compute pseudo-inverse using SVD.
        
        The pseudo-inverse always exists and is numerically stable.
        """
        from src.linear_algebra.decomposition import Decomposition
        
        U, S, Vt = Decomposition.svd(matrix)
        
        # Compute S_inv (inverse of singular values)
        S_inv_data = [[0.0] * S.cols for _ in range(S.rows)]
        for i in range(min(S.rows, S.cols)):
            if S[i, i] > eps:
                S_inv_data[i][i] = 1.0 / S[i, i]
        S_inv = Matrix(S_inv_data)
        
        # Pseudo-inverse: V * S_inv * U^T
        return Vt.T @ S_inv @ U.T
    
    @staticmethod
    def cache_matrix_inverse():
        """
        Decorator for caching matrix inverses.
        
        Matrix inverses are expensive; this caches them.
        """
        cache = {}
        
        def decorator(func):
            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                # Find the matrix argument
                matrix = None
                for arg in args:
                    if isinstance(arg, Matrix):
                        matrix = arg
                        break
                
                if matrix is None:
                    return func(*args, **kwargs)
                
                # Create cache key
                key = (matrix.rows, matrix.cols, hash(str(matrix)))
                
                if key not in cache:
                    cache[key] = func(*args, **kwargs)
                return cache[key]
            return wrapper
        
        return decorator
```

#### Step 3: Create Production Pipeline

**File: `src/pipeline/__init__.py`**

```python
"""
Production ML pipeline.

This package provides end-to-end ML pipelines with:
- Data preprocessing
- Model training
- Evaluation
- Deployment support
"""

from src.pipeline.data_pipeline import DataPipeline
from src.pipeline.model_pipeline import ModelPipeline

__all__ = ['DataPipeline', 'ModelPipeline']
```

**File: `src/pipeline/data_pipeline.py`**

```python
"""
Data preprocessing pipeline for production ML.

This module provides:
- Data loading and validation
- Preprocessing steps (scaling, encoding)
- Feature engineering
- Data splitting
"""

from typing import List, Tuple, Dict, Optional, Any, Callable
import random
import math
from src.linear_algebra import Matrix, Vector
from src.probability.stats import Statistics
from src.probability import ModelSelection


class DataPipeline:
    """
    End-to-end data preprocessing pipeline.
    
    Handles:
    - Data validation
    - Missing value handling
    - Feature scaling
    - Train/validation/test splitting
    - Feature engineering
    """
    
    def __init__(self, random_seed: Optional[int] = 42):
        """
        Initialize data pipeline.
        
        Args:
            random_seed: Seed for reproducibility.
        """
        self.random_seed = random_seed
        self.scalers = {}  # Store scaling parameters
        self.feature_names = None
        self.n_features = None
    
    def load_data(self, data: Matrix, labels: Optional[Matrix] = None):
        """
        Load and validate data.
        
        Args:
            data: Feature matrix.
            labels: Optional target labels.
        """
        if data.rows == 0:
            raise ValueError("Data cannot be empty")
        
        self.n_features = data.cols
        
        # Check for NaN/Inf
        for i in range(data.rows):
            for j in range(data.cols):
                if not math.isfinite(data[i, j]):
                    raise ValueError(f"Non-finite value at ({i}, {j})")
        
        return data, labels
    
    def handle_missing_values(self, data: Matrix, strategy: str = 'mean') -> Matrix:
        """
        Handle missing values in data.
        
        Strategies:
        - 'mean': Replace with column mean
        - 'median': Replace with column median
        - 'mode': Replace with column mode
        - 'zero': Replace with 0
        """
        # Check for missing values (assume NaN represents missing)
        # This is a simplified version; in practice, missing values are marked
        missing_indices = []
        for i in range(data.rows):
            for j in range(data.cols):
                if math.isnan(data[i, j]):
                    missing_indices.append((i, j))
        
        if not missing_indices:
            return data
        
        # Fill missing values based on strategy
        if strategy == 'mean':
            for j in range(data.cols):
                # Compute mean ignoring missing values
                col_values = [data[i, j] for i in range(data.rows) 
                            if not math.isnan(data[i, j])]
                if col_values:
                    mean = sum(col_values) / len(col_values)
                    for i in range(data.rows):
                        if math.isnan(data[i, j]):
                            data[i, j] = mean
        
        elif strategy == 'zero':
            for i, j in missing_indices:
                data[i, j] = 0.0
        
        return data
    
    def scale_data(self, data: Matrix, method: str = 'standardize') -> Matrix:
        """
        Scale features to similar ranges.
        
        Methods:
        - 'standardize': (x - mean) / std
        - 'minmax': (x - min) / (max - min)
        - 'normalize': x / ||x||₂
        """
        if method == 'standardize':
            return self._standardize(data)
        elif method == 'minmax':
            return self._minmax_scale(data)
        elif method == 'normalize':
            return self._normalize(data)
        else:
            raise ValueError(f"Unknown scaling method: {method}")
    
    def _standardize(self, data: Matrix) -> Matrix:
        """Standardize to mean 0, std 1."""
        if self.scalers.get('standardize'):
            # Use stored parameters
            means = self.scalers['standardize']['means']
            stds = self.scalers['standardize']['stds']
        else:
            # Compute parameters
            means = []
            stds = []
            for j in range(data.cols):
                col = data.col(j)
                means.append(Statistics.mean(col))
                std = Statistics.standard_deviation(col, ddof=1)
                stds.append(max(std, 1e-10))  # Avoid division by zero
            
            self.scalers['standardize'] = {'means': means, 'stds': stds}
        
        # Scale data
        scaled_data = [[(data[i, j] - means[j]) / stds[j] 
                       for j in range(data.cols)] 
                      for i in range(data.rows)]
        return Matrix(scaled_data)
    
    def _minmax_scale(self, data: Matrix) -> Matrix:
        """Scale to [0, 1] range."""
        if self.scalers.get('minmax'):
            mins = self.scalers['minmax']['mins']
            maxs = self.scalers['minmax']['maxs']
        else:
            mins = []
            maxs = []
            for j in range(data.cols):
                col = data.col(j)
                mins.append(min(col[i] for i in range(col.size)))
                maxs.append(max(col[i] for i in range(col.size)))
            
            self.scalers['minmax'] = {'mins': mins, 'maxs': maxs}
        
        scaled_data = []
        for i in range(data.rows):
            row = []
            for j in range(data.cols):
                if maxs[j] - mins[j] > 1e-10:
                    scaled = (data[i, j] - mins[j]) / (maxs[j] - mins[j])
                else:
                    scaled = 0.5
                row.append(scaled)
            scaled_data.append(row)
        
        return Matrix(scaled_data)
    
    def _normalize(self, data: Matrix) -> Matrix:
        """Normalize rows to unit L2 norm."""
        from src.linear_algebra import Vector
        
        normalized_data = []
        for i in range(data.rows):
            row = Vector([data[i, j] for j in range(data.cols)])
            norm = row.norm(2)
            if norm > 0:
                row = row / norm
            normalized_data.append([row[j] for j in range(row.size)])
        
        return Matrix(normalized_data)
    
    def split_data(self, X: Matrix, y: Matrix,
                   train_ratio: float = 0.7,
                   val_ratio: float = 0.15,
                   test_ratio: float = 0.15) -> Tuple:
        """
        Split data into train/validation/test sets.
        """
        return ModelSelection.train_validate_test_split(
            X, y, train_ratio, val_ratio, test_ratio, self.random_seed
        )
    
    def add_polynomial_features(self, X: Matrix, degree: int = 2) -> Matrix:
        """
        Add polynomial features for non-linear relationships.
        """
        from itertools import combinations_with_replacement
        
        new_data = []
        for i in range(X.rows):
            row = [X[i, j] for j in range(X.cols)]  # Original features
            
            for d in range(2, degree + 1):
                for combo in combinations_with_replacement(range(X.cols), d):
                    value = 1.0
                    for idx in combo:
                        value *= X[i, idx]
                    row.append(value)
            
            new_data.append(row)
        
        return Matrix(new_data)
    
    def get_feature_names(self) -> List[str]:
        """Get feature names (if available)."""
        return self.feature_names or [f"feature_{i}" for i in range(self.n_features)]
```

**File: `src/pipeline/model_pipeline.py`**

```python
"""
Complete ML pipeline for production.

This module provides:
- End-to-end model training
- Hyperparameter tuning
- Model evaluation
- Model persistence
- Prediction pipeline
"""

from typing import List, Tuple, Dict, Optional, Any
import json
import pickle
import random
from src.linear_algebra import Matrix, Vector
from src.probability import ModelMetrics, BiasVarianceAnalysis
from src.models.base import BaseModel


class ModelPipeline:
    """
    Complete production ML pipeline.
    
    Handles:
    - Model selection
    - Hyperparameter tuning
    - Cross-validation
    - Model persistence
    - Prediction
    """
    
    def __init__(self, model: BaseModel, random_seed: Optional[int] = 42):
        """
        Initialize model pipeline.
        
        Args:
            model: ML model to use.
            random_seed: Seed for reproducibility.
        """
        self.model = model
        self.random_seed = random_seed
        self.best_params = None
        self.best_score = None
        self.training_history = None
    
    def train(self, X: Matrix, y: Vector) -> Dict[str, Any]:
        """
        Train the model on data.
        
        Returns:
            Training history and metrics.
        """
        # Check data
        if X.rows == 0:
            raise ValueError("Training data cannot be empty")
        
        # Train model
        if hasattr(self.model, 'fit'):
            if hasattr(self.model, 'num_epochs') and self.model.num_epochs > 0:
                # Neural network with history
                self.training_history = self.model.fit(X, y)
            else:
                self.model.fit(X, y)
        else:
            raise ValueError("Model must have fit() method")
        
        # Evaluate on training data
        predictions = self.predict(X)
        
        if hasattr(self.model, '_compute_metrics'):
            metrics = self.model._compute_metrics(predictions, y)
        else:
            # Compute basic metrics
            metrics = {
                'mse': ModelMetrics.mse(predictions.col(0), y.col(0)),
                'rmse': ModelMetrics.rmse(predictions.col(0), y.col(0)),
                'r2': ModelMetrics.r2_score(predictions.col(0), y.col(0))
            }
        
        return metrics
    
    def validate(self, X_val: Matrix, y_val: Vector) -> Dict[str, float]:
        """
        Validate model on validation data.
        """
        predictions = self.predict(X_val)
        
        metrics = {
            'mse': ModelMetrics.mse(predictions.col(0), y_val.col(0)),
            'rmse': ModelMetrics.rmse(predictions.col(0), y_val.col(0)),
            'r2': ModelMetrics.r2_score(predictions.col(0), y_val.col(0))
        }
        
        return metrics
    
    def cross_validate(self, X: Matrix, y: Vector, 
                       k: int = 5) -> Dict[str, float]:
        """
        Perform k-fold cross-validation.
        """
        n = X.rows
        fold_size = n // k
        scores = []
        
        # Shuffle data
        indices = list(range(n))
        if self.random_seed is not None:
            random.seed(self.random_seed)
            random.shuffle(indices)
        
        for fold in range(k):
            # Split
            test_start = fold * fold_size
            test_end = min((fold + 1) * fold_size, n)
            
            test_indices = indices[test_start:test_end]
            train_indices = indices[:test_start] + indices[test_end:]
            
            # Create train/test sets
            X_train = Matrix([[X[i, j] for j in range(X.cols)] for i in train_indices])
            X_test = Matrix([[X[i, j] for j in range(X.cols)] for i in test_indices])
            
            y_train = Matrix([[y[i, 0] for _ in range(y.cols)] for i in train_indices])
            y_test = Matrix([[y[i, 0] for _ in range(y.cols)] for i in test_indices])
            
            # Train and evaluate
            self.model.fit(X_train, y_train)
            predictions = self.predict(X_test)
            
            score = ModelMetrics.mse(predictions.col(0), y_test.col(0))
            scores.append(score)
        
        return {
            'mean_score': sum(scores) / len(scores),
            'std_score': (sum((s - sum(scores)/len(scores)) ** 2 
                            for s in scores) / len(scores)) ** 0.5,
            'scores': scores
        }
    
    def hyperparameter_tune(self, X: Matrix, y: Vector,
                           param_grid: Dict[str, List[Any]],
                           n_folds: int = 3) -> Dict[str, Any]:
        """
        Simple grid search for hyperparameter tuning.
        
        Args:
            X: Training data.
            y: Labels.
            param_grid: Dictionary of parameter names to values.
            n_folds: Number of folds for validation.
            
        Returns:
            Best parameters and score.
        """
        import itertools
        
        # Generate all combinations
        param_names = list(param_grid.keys())
        param_values = list(param_grid.values())
        param_combinations = list(itertools.product(*param_values))
        
        best_score = float('inf')
        best_params = {}
        
        for combo in param_combinations:
            # Set parameters
            params = dict(zip(param_names, combo))
            for name, value in params.items():
                setattr(self.model, name, value)
            
            # Cross-validation
            cv_scores = self.cross_validate(X, y, k=n_folds)
            mean_score = cv_scores['mean_score']
            
            if mean_score < best_score:
                best_score = mean_score
                best_params = params
        
        self.best_params = best_params
        self.best_score = best_score
        
        # Set best parameters
        for name, value in best_params.items():
            setattr(self.model, name, value)
        
        return {
            'best_params': best_params,
            'best_score': best_score
        }
    
    def predict(self, X: Matrix) -> Matrix:
        """
        Make predictions using the trained model.
        """
        if not hasattr(self.model, 'predict'):
            raise ValueError("Model must have predict() method")
        
        predictions = self.model.predict(X)
        
        # Ensure Matrix output
        if isinstance(predictions, Vector):
            predictions = Matrix([[predictions[i]] for i in range(predictions.size)])
        elif isinstance(predictions, list):
            predictions = Matrix([[p] for p in predictions])
        
        return predictions
    
    def save_model(self, filepath: str) -> None:
        """
        Save model to file.
        """
        with open(filepath, 'wb') as f:
            pickle.dump({
                'model': self.model,
                'best_params': self.best_params,
                'best_score': self.best_score,
                'training_history': self.training_history
            }, f)
    
    def load_model(self, filepath: str) -> None:
        """
        Load model from file.
        """
        with open(filepath, 'rb') as f:
            data = pickle.load(f)
            self.model = data['model']
            self.best_params = data.get('best_params')
            self.best_score = data.get('best_score')
            self.training_history = data.get('training_history')
    
    def summary(self) -> str:
        """
        Get pipeline summary.
        """
        lines = ["Model Pipeline Summary"]
        lines.append("=" * 40)
        lines.append(f"Model: {self.model.__class__.__name__}")
        
        if self.training_history:
            if 'loss' in self.training_history:
                loss_history = self.training_history['loss']
                lines.append(f"Final loss: {loss_history[-1]:.6f}")
                lines.append(f"Epochs: {len(loss_history)}")
        
        if self.best_params:
            lines.append("Best parameters:")
            for name, value in self.best_params.items():
                lines.append(f"  {name}: {value}")
        
        if self.best_score:
            lines.append(f"Best cross-validation score: {self.best_score:.4f}")
        
        lines.append("=" * 40)
        return "\n".join(lines)
```

### The Verification

#### Step 1: Test Numerical Stability

**File: `tests/test_numerical.py`**

```python
"""
Unit tests for numerical stability and performance.
"""

import pytest
import math
from src.numerical import SafeMath, NumericalStability
from src.linear_algebra import Vector, Matrix


class TestSafeMath:
    """Test safe mathematical operations."""
    
    def test_safe_exp(self):
        """Test safe exponential."""
        assert SafeMath.safe_exp(0) == 1.0
        assert SafeMath.safe_exp(1) == math.exp(1)
        
        # Should not overflow
        large = SafeMath.safe_exp(1000)
        assert math.isfinite(large)
        
        # Should not underflow
        small = SafeMath.safe_exp(-1000)
        assert small == 0.0
    
    def test_safe_log(self):
        """Test safe logarithm."""
        assert SafeMath.safe_log(1) == 0.0
        assert SafeMath.safe_log(math.e) == 1.0
        
        # Should not fail on non-positive inputs
        assert SafeMath.safe_log(0) == math.log(1e-12)
        assert SafeMath.safe_log(-1) == math.log(1e-12)
    
    def test_safe_sqrt(self):
        """Test safe square root."""
        assert SafeMath.safe_sqrt(4) == 2.0
        assert SafeMath.safe_sqrt(0) == 0.0
        
        # Should not fail on negative inputs
        assert SafeMath.safe_sqrt(-1) == 0.0
    
    def test_log_sum_exp(self):
        """Test log-sum-exp trick."""
        v = Vector([1.0, 2.0, 3.0])
        result = SafeMath.log_sum_exp(v)
        
        # Direct computation: log(exp(1) + exp(2) + exp(3))
        direct = math.log(math.exp(1) + math.exp(2) + math.exp(3))
        assert result == pytest.approx(direct, abs=1e-10)
        
        # Large values should not overflow
        v_large = Vector([100.0, 101.0, 102.0])
        result_large = SafeMath.log_sum_exp(v_large)
        assert math.isfinite(result_large)
    
    def test_stable_softmax(self):
        """Test stable softmax."""
        v = Vector([1.0, 2.0, 3.0])
        soft = SafeMath.stable_softmax(v)
        
        # Should sum to 1
        assert abs(sum(soft[i] for i in range(soft.size)) - 1.0) < 1e-10
        
        # Should be in [0, 1]
        for i in range(soft.size):
            assert 0 <= soft[i] <= 1
    
    def test_stable_sigmoid(self):
        """Test stable sigmoid."""
        assert SafeMath.stable_sigmoid(0) == 0.5
        assert SafeMath.stable_sigmoid(1000) == 1.0
        assert SafeMath.stable_sigmoid(-1000) == 0.0
        
        # Should be strictly increasing
        assert SafeMath.stable_sigmoid(1) > SafeMath.stable_sigmoid(0)


class TestNumericalStability:
    """Test numerical stability utilities."""
    
    def test_clip_gradient(self):
        """Test gradient clipping."""
        g = Vector([10.0, 10.0, 10.0])
        clipped = NumericalStability.clip_gradient(g, max_norm=1.0)
        
        # Should have norm 1.0
        assert clipped.norm(2) == pytest.approx(1.0, abs=1e-10)
        
        # Should preserve direction
        assert clipped[0] == clipped[1] == clipped[2]
    
    def test_regularization(self):
        """Test regularization penalties."""
        w = Vector([1.0, 2.0, 3.0])
        
        l2 = NumericalStability.add_l2_regularization(w, 0.1)
        assert l2 == pytest.approx(0.1 * (1 + 4 + 9) / 2, abs=1e-10)
        
        l1 = NumericalStability.add_l1_regularization(w, 0.1)
        assert l1 == 0.1 * 6.0
    
    def test_condition_number(self):
        """Test condition number computation."""
        # Well-conditioned matrix
        M1 = Matrix([[2.0, 0.0], [0.0, 2.0]])
        cond1 = NumericalStability.condition_number(M1)
        assert cond1 == pytest.approx(1.0, abs=1e-10)
        
        # Ill-conditioned matrix
        M2 = Matrix([[1.0, 1.0], [1.0, 1.001]])
        cond2 = NumericalStability.condition_number(M2)
        assert cond2 > 1000
    
    def test_is_stable(self):
        """Test stability check."""
        # Stable matrix
        stable = Matrix([[1.0, 2.0], [3.0, 4.0]])
        assert NumericalStability.is_stable(stable) == True
        
        # Unstable matrix with NaN
        unstable_data = [[1.0, float('nan')], [3.0, 4.0]]
        unstable = Matrix(unstable_data)
        assert NumericalStability.is_stable(unstable) == False
        
        # Unstable matrix with Inf
        unstable_data2 = [[1.0, float('inf')], [3.0, 4.0]]
        unstable2 = Matrix(unstable_data2)
        assert NumericalStability.is_stable(unstable2) == False
```

#### Step 2: Run All Tests

```bash
# From the project root
pytest tests/ -v
```

#### Step 3: Interactive Verification

```python
>>> from src.numerical import SafeMath, NumericalStability
>>> from src.pipeline import DataPipeline, ModelPipeline
>>> from src.models import NeuralNetwork
>>> from src.linear_algebra import Matrix, Vector
>>> import random
>>> 
>>> # Demonstrate numerical stability
>>> print("=== Numerical Stability Demo ===")
>>> 
>>> # Log-sum-exp trick
>>> values = Vector([100, 101, 102])
>>> result = SafeMath.log_sum_exp(values)
>>> print(f"log_sum_exp({values}) = {result:.6f}")
>>> 
>>> # Stable softmax
>>> soft = SafeMath.stable_softmax(values)
>>> print(f"softmax({values}) = {soft}")
>>> 
>>> # Gradient clipping
>>> gradient = Vector([100, 100, 100])
>>> clipped = NumericalStability.clip_gradient(gradient, max_norm=1.0)
>>> print(f"Clipped norm: {clipped.norm(2):.6f}")
>>> 
>>> # End-to-end pipeline demo
>>> print("\n=== End-to-end ML Pipeline ===")
>>> 
>>> # Generate data
>>> X_data = [[random.random() * 10 for _ in range(5)] for _ in range(200)]
>>> y_data = [[2 * sum(x) + random.gauss(0, 0.5)] for x in X_data]
>>> 
>>> X = Matrix(X_data)
>>> y = Matrix(y_data)
>>> 
>>> # Create pipeline
>>> data_pipeline = DataPipeline(random_seed=42)
>>> 
>>> # Preprocess
>>> X_scaled = data_pipeline.scale_data(X, method='standardize')
>>> 
>>> # Split
>>> X_train, X_val, X_test, y_train, y_val, y_test = \
...     data_pipeline.split_data(X_scaled, y, 0.7, 0.15, 0.15)
>>> 
>>> # Create model
>>> model = NeuralNetwork([X_train.cols, 10, 1],
...                       learning_rate=0.01,
...                       num_epochs=50,
...                       random_seed=42)
>>> 
>>> # Create model pipeline
>>> model_pipeline = ModelPipeline(model, random_seed=42)
>>> 
>>> # Train
>>> train_metrics = model_pipeline.train(X_train, y_train)
>>> print(f"Train MSE: {train_metrics['mse']:.4f}")
>>> 
>>> # Validate
>>> val_metrics = model_pipeline.validate(X_val, y_val)
>>> print(f"Validation MSE: {val_metrics['mse']:.4f}")
>>> 
>>> # Test
>>> test_metrics = model_pipeline.validate(X_test, y_test)
>>> print(f"Test MSE: {test_metrics['mse']:.4f}")
>>> 
>>> print("\nPipeline Summary:")
>>> print(model_pipeline.summary())
```

---

*Next: We'll build a complete, production-ready machine learning system that integrates all components—linear algebra, calculus, probability, and numerical methods—into a cohesive end-to-end pipeline.*
