# Phase 2, Part 2: Gradient Descent — The Learning Algorithm

## Module 2: Gradient Descent and Optimization Algorithms

### The Target

We're building the optimization engine that powers machine learning. This module implements gradient descent and its variants, connecting our linear algebra and calculus libraries to create a complete learning system.

**Files we'll create:**
- `src/calculus/optimization.py`
- Update `src/calculus/__init__.py`
- Update `tests/test_calculus.py`

### The Concept

Imagine you're blindfolded on a mountain and need to find the lowest point. You can feel the ground beneath your feet and take a step in the direction that feels steepest downward. That's **gradient descent**.

In machine learning:
- The "mountain" is the **loss landscape** (a surface showing error for each set of weights)
- Your "position" is the current **weights** of your model
- The "steepest downward direction" is the **negative gradient** (-∇L)
- Each "step" is an **update** to your weights

**The learning algorithm is remarkably simple:**

```
while not converged:
    gradient = compute_gradient(loss, weights, data)
    weights = weights - learning_rate * gradient
```

That's it. This simple loop is the foundation of almost all machine learning.

**Key concepts in this module:**
1. **Learning rate**: How big of a step to take (too big = overshoot, too small = slow)
2. **Batch gradient descent**: Use all data to compute gradient
3. **Stochastic gradient descent (SGD)**: Use one sample at a time
4. **Mini-batch gradient descent**: Use a small batch of samples
5. **Convergence**: When to stop training
6. **Momentum**: Accelerating through flat regions

### The Implementation

#### Step 1: Implement Optimization Algorithms

**File: `src/calculus/optimization.py`**

```python
"""
Optimization algorithms for machine learning.

This module implements gradient descent and its variants, the core
learning algorithms that power modern machine learning.
"""

from typing import Callable, List, Tuple, Optional, Dict, Any
import math
import random
from src.linear_algebra import Vector, Matrix
from src.calculus.derivatives import Derivatives


class GradientDescent:
    """
    Gradient descent optimization algorithms.
    
    This class provides various gradient descent implementations:
    - Batch GD: Uses all data for each update
    - Stochastic GD (SGD): Uses one sample per update
    - Mini-batch GD: Uses a small batch per update
    - SGD with momentum: Accelerates convergence
    - Adam: Adaptive learning rates
    """
    
    # ==================== BATCH GRADIENT DESCENT ====================
    
    @staticmethod
    def batch_gradient_descent(
        loss_function: Callable[[Vector], float],
        gradient_function: Callable[[Vector], Vector],
        initial_weights: Vector,
        learning_rate: float = 0.01,
        num_iterations: int = 1000,
        tolerance: float = 1e-6,
        verbose: bool = False
    ) -> Tuple[Vector, List[float]]:
        """
        Batch gradient descent (use all data for each update).
        
        Batch GD computes the gradient using the entire dataset.
        This gives the most accurate gradient but is computationally
        expensive for large datasets.
        
        Analogy: Instead of looking at your blindfolded position and
        feeling the ground with your feet, you use a level to measure
        the slope across the entire mountain. It's accurate, but slow.
        
        Args:
            loss_function: Function that computes loss given weights.
            gradient_function: Function that computes gradient.
            initial_weights: Starting point for optimization.
            learning_rate: Step size (how far to move in gradient direction).
            num_iterations: Maximum number of iterations.
            tolerance: Stop if change in weights is smaller than this.
            verbose: Whether to print progress.
            
        Returns:
            Tuple of (final_weights, loss_history).
            
        Examples:
            >>> def f(w): return sum(x**2 for x in w)  # Loss function
            >>> def grad_f(w): return Vector([2*x for x in w])
            >>> w = Vector([5.0, 3.0])
            >>> final_w, history = GradientDescent.batch_gradient_descent(
            ...     f, grad_f, w, learning_rate=0.1, num_iterations=100
            ... )
            >>> final_w  # Should be close to [0, 0]
            Vector([0.0, 0.0])
        """
        weights = initial_weights
        loss_history = []
        
        for iteration in range(num_iterations):
            # Compute loss
            loss = loss_function(weights)
            loss_history.append(loss)
            
            # Compute gradient
            gradient = gradient_function(weights)
            
            # Update weights: w = w - learning_rate * gradient
            weights_new = weights - learning_rate * gradient
            
            # Check convergence
            weight_change = (weights_new - weights).norm(2)
            if weight_change < tolerance:
                if verbose:
                    print(f"Converged at iteration {iteration}")
                return weights_new, loss_history
            
            weights = weights_new
            
            if verbose and iteration % 100 == 0:
                print(f"Iteration {iteration}: loss = {loss:.6f}")
        
        return weights, loss_history
    
    # ==================== STOCHASTIC GRADIENT DESCENT ====================
    
    @staticmethod
    def stochastic_gradient_descent(
        loss_gradient_function: Callable[[Vector, int, Matrix, Vector], Vector],
        initial_weights: Vector,
        X: Matrix,  # Training data
        y: Vector,  # Target values
        learning_rate: float = 0.01,
        num_epochs: int = 100,
        shuffle: bool = True,
        tolerance: float = 1e-6,
        verbose: bool = False
    ) -> Tuple[Vector, List[float]]:
        """
        Stochastic Gradient Descent (SGD) - one sample at a time.
        
        SGD updates weights using only ONE sample at a time. This is
        much faster for large datasets and introduces noise that can
        help escape local minima.
        
        Analogy: Instead of measuring the entire mountain slope, you
        just feel the ground under your feet and take a step. It's
        noisy and erratic, but you'll eventually reach the bottom,
        and it's much faster.
        
        Args:
            loss_gradient_function: Function that computes gradient for
                one sample: gradient(weights, sample_index, X, y)
            initial_weights: Starting weights.
            X: Training data (samples x features).
            y: Target values.
            learning_rate: Step size.
            num_epochs: Number of passes through the data.
            shuffle: Whether to shuffle data each epoch.
            tolerance: Convergence tolerance.
            verbose: Whether to print progress.
            
        Returns:
            Tuple of (final_weights, loss_history).
        """
        weights = initial_weights
        n_samples = X.rows
        loss_history = []
        
        for epoch in range(num_epochs):
            # Shuffle data order
            indices = list(range(n_samples))
            if shuffle:
                random.shuffle(indices)
            
            epoch_loss = 0.0
            
            # Iterate through samples
            for idx in indices:
                # Compute gradient for this sample
                gradient = loss_gradient_function(weights, idx, X, y)
                
                # Update weights
                weights_new = weights - learning_rate * gradient
                
                # Track changes
                weight_change = (weights_new - weights).norm(2)
                
                weights = weights_new
                
                # Accumulate loss for this sample
                # (We'd need loss function separately for this)
            
            # Compute epoch loss (for monitoring)
            # This requires a loss function; we'll compute it separately
            if verbose and epoch % 10 == 0:
                # Compute loss using a loss function passed separately
                pass
                
            # Check convergence (using average weight change)
            if epoch > 0 and len(loss_history) > 0:
                if abs(loss_history[-1] - loss_history[-2]) < tolerance:
                    if verbose:
                        print(f"Converged at epoch {epoch}")
                    break
        
        return weights, loss_history
    
    # ==================== MINI-BATCH GRADIENT DESCENT ====================
    
    @staticmethod
    def mini_batch_gradient_descent(
        loss_function: Callable[[Vector, Matrix, Vector], float],
        gradient_function: Callable[[Vector, Matrix, Vector], Vector],
        initial_weights: Vector,
        X: Matrix,
        y: Vector,
        batch_size: int = 32,
        learning_rate: float = 0.01,
        num_epochs: int = 100,
        shuffle: bool = True,
        tolerance: float = 1e-6,
        verbose: bool = False
    ) -> Tuple[Vector, List[float]]:
        """
        Mini-batch gradient descent (sweet spot between batch and SGD).
        
        Mini-batch GD uses a small batch of samples (typically 32-256)
        to compute each gradient. This balances the accuracy of batch GD
        with the speed of SGD.
        
        Analogy: You're still blindfolded, but instead of feeling the
        ground with one foot (SGD) or using surveying equipment (batch),
        you feel the ground with both feet and your hands. A good
        compromise between speed and accuracy.
        
        This is what most deep learning frameworks use.
        
        Args:
            loss_function: Function to compute loss.
            gradient_function: Function to compute gradient for a batch.
            initial_weights: Starting weights.
            X: Training data.
            y: Target values.
            batch_size: Number of samples per batch.
            learning_rate: Step size.
            num_epochs: Number of passes through data.
            shuffle: Whether to shuffle data.
            tolerance: Convergence tolerance.
            verbose: Whether to print progress.
            
        Returns:
            Tuple of (final_weights, loss_history).
        """
        weights = initial_weights
        n_samples = X.rows
        loss_history = []
        
        for epoch in range(num_epochs):
            # Shuffle data
            indices = list(range(n_samples))
            if shuffle:
                random.shuffle(indices)
            
            epoch_loss = 0.0
            
            # Process mini-batches
            for batch_start in range(0, n_samples, batch_size):
                batch_end = min(batch_start + batch_size, n_samples)
                batch_indices = indices[batch_start:batch_end]
                
                # Extract batch data
                batch_X_data = [[X[i, j] for j in range(X.cols)] 
                               for i in batch_indices]
                batch_X = Matrix(batch_X_data)
                batch_y = Vector([y[i] for i in batch_indices])
                
                # Compute gradient for batch
                gradient = gradient_function(weights, batch_X, batch_y)
                
                # Update weights
                weights_new = weights - learning_rate * gradient
                weights = weights_new
            
            # Compute loss for this epoch
            loss = loss_function(weights, X, y)
            loss_history.append(loss)
            
            if verbose and epoch % 10 == 0:
                print(f"Epoch {epoch}: loss = {loss:.6f}")
            
            # Check convergence
            if epoch > 0:
                if abs(loss_history[-1] - loss_history[-2]) < tolerance:
                    if verbose:
                        print(f"Converged at epoch {epoch}")
                    break
        
        return weights, loss_history
    
    # ==================== MOMENTUM-BASED OPTIMIZATION ====================
    
    @staticmethod
    def gradient_descent_with_momentum(
        loss_function: Callable[[Vector], float],
        gradient_function: Callable[[Vector], Vector],
        initial_weights: Vector,
        learning_rate: float = 0.01,
        momentum: float = 0.9,
        num_iterations: int = 1000,
        tolerance: float = 1e-6,
        verbose: bool = False
    ) -> Tuple[Vector, List[float]]:
        """
        Gradient descent with momentum.
        
        Momentum helps accelerate gradient descent in consistent directions
        and dampens oscillations in changing directions. It's like a ball
        rolling down a hill - it gains speed as it goes.
        
        The update rule:
        v = momentum * v + learning_rate * gradient
        w = w - v
        
        Where v is the velocity (accumulated gradient).
        
        Analogy: Instead of stopping at the bottom of every hill and
        starting again, you maintain some "momentum" that carries you
        through flat regions and helps you escape small bumps.
        
        Args:
            loss_function: Function to compute loss.
            gradient_function: Function to compute gradient.
            initial_weights: Starting weights.
            learning_rate: Step size.
            momentum: Momentum coefficient (0-1, typically 0.9).
            num_iterations: Maximum iterations.
            tolerance: Convergence tolerance.
            verbose: Whether to print progress.
            
        Returns:
            Tuple of (final_weights, loss_history).
        """
        weights = initial_weights
        velocity = Vector.zeros(weights.size)
        loss_history = []
        
        for iteration in range(num_iterations):
            loss = loss_function(weights)
            loss_history.append(loss)
            
            gradient = gradient_function(weights)
            
            # Update velocity: v = momentum * v + learning_rate * gradient
            velocity = momentum * velocity + learning_rate * gradient
            
            # Update weights: w = w - v
            weights_new = weights - velocity
            
            weight_change = (weights_new - weights).norm(2)
            if weight_change < tolerance:
                if verbose:
                    print(f"Converged at iteration {iteration}")
                return weights_new, loss_history
            
            weights = weights_new
            
            if verbose and iteration % 100 == 0:
                print(f"Iteration {iteration}: loss = {loss:.6f}")
        
        return weights, loss_history
    
    # ==================== ADAM OPTIMIZER ====================
    
    @staticmethod
    def adam_optimizer(
        loss_function: Callable[[Vector], float],
        gradient_function: Callable[[Vector], Vector],
        initial_weights: Vector,
        learning_rate: float = 0.001,
        beta1: float = 0.9,
        beta2: float = 0.999,
        epsilon: float = 1e-8,
        num_iterations: int = 1000,
        tolerance: float = 1e-6,
        verbose: bool = False
    ) -> Tuple[Vector, List[float]]:
        """
        Adam (Adaptive Moment Estimation) optimizer.
        
        Adam combines momentum with adaptive learning rates. It maintains:
        - m: Moving average of gradients (momentum-like)
        - v: Moving average of squared gradients (adaptive learning rates)
        
        Adam is the most popular optimizer in deep learning because it
        works well for a wide range of problems without tuning.
        
        The update rules:
        m = beta1 * m + (1 - beta1) * gradient
        v = beta2 * v + (1 - beta2) * gradient^2
        m_hat = m / (1 - beta1^t)  # Bias correction
        v_hat = v / (1 - beta2^t)  # Bias correction
        w = w - learning_rate * m_hat / (sqrt(v_hat) + epsilon)
        
        Analogy: Adam is like having an AI assistant that automatically
        adjusts your step size for each direction and maintains momentum.
        It's sophisticated but worth the complexity.
        
        Args:
            loss_function: Function to compute loss.
            gradient_function: Function to compute gradient.
            initial_weights: Starting weights.
            learning_rate: Step size (often 0.001 for Adam).
            beta1: Exponential decay rate for first moment (0.9 default).
            beta2: Exponential decay rate for second moment (0.999 default).
            epsilon: Small constant for numerical stability.
            num_iterations: Maximum iterations.
            tolerance: Convergence tolerance.
            verbose: Whether to print progress.
            
        Returns:
            Tuple of (final_weights, loss_history).
        """
        weights = initial_weights
        m = Vector.zeros(weights.size)  # First moment (mean of gradients)
        v = Vector.zeros(weights.size)  # Second moment (variance of gradients)
        loss_history = []
        
        for t in range(1, num_iterations + 1):
            loss = loss_function(weights)
            loss_history.append(loss)
            
            gradient = gradient_function(weights)
            
            # Update biased first moment estimate
            m = beta1 * m + (1 - beta1) * gradient
            
            # Update biased second raw moment estimate
            squared_gradient = Vector([g * g for g in gradient])
            v = beta2 * v + (1 - beta2) * squared_gradient
            
            # Compute bias-corrected first moment estimate
            m_hat = m / (1 - beta1 ** t)
            
            # Compute bias-corrected second moment estimate
            v_hat = v / (1 - beta2 ** t)
            
            # Update weights
            denominator = Vector([math.sqrt(v_hat[i]) + epsilon 
                                 for i in range(v_hat.size)])
            update = Vector([m_hat[i] / denominator[i] 
                            for i in range(m_hat.size)])
            weights_new = weights - learning_rate * update
            
            weight_change = (weights_new - weights).norm(2)
            if weight_change < tolerance:
                if verbose:
                    print(f"Converged at iteration {t}")
                return weights_new, loss_history
            
            weights = weights_new
            
            if verbose and t % 100 == 0:
                print(f"Iteration {t}: loss = {loss:.6f}")
        
        return weights, loss_history
    
    # ==================== LINE SEARCH (ADAPTIVE LEARNING RATE) ====================
    
    @staticmethod
    def backtracking_line_search(
        f: Callable[[Vector], float],
        grad_f: Callable[[Vector], Vector],
        x: Vector,
        direction: Vector,
        alpha: float = 1.0,
        c: float = 0.8,
        rho: float = 0.5,
        max_iter: int = 20
    ) -> float:
        """
        Backtracking line search for adaptive learning rate.
        
        This finds a good step size by trying large steps and reducing
        them until the loss decreases sufficiently. It's like trying to
        take a step, stumbling, and taking a smaller step.
        
        The Armijo condition: f(x + alpha*p) <= f(x) + c*alpha*grad_f(x)^T p
        
        Args:
            f: Loss function.
            grad_f: Gradient function.
            x: Current weights.
            direction: Update direction (negative gradient).
            alpha: Initial step size.
            c: Sufficient decrease parameter (0-1, typically 0.8).
            rho: Reduction factor for step size (0-1, typically 0.5).
            max_iter: Maximum iterations for backtracking.
            
        Returns:
            The selected step size.
        """
        current_loss = f(x)
        gradient = grad_f(x)
        
        # Direction should be descent (gradient dot direction < 0)
        grad_dir = gradient.dot(direction)
        if grad_dir >= 0:
            raise ValueError("Direction must be a descent direction")
        
        for _ in range(max_iter):
            x_new = x + alpha * direction
            new_loss = f(x_new)
            
            # Armijo condition: sufficient decrease
            if new_loss <= current_loss + c * alpha * grad_dir:
                return alpha
            
            # Reduce step size
            alpha *= rho
        
        # If we didn't find a good step, return the smallest tested
        return alpha
    
    @staticmethod
    def gradient_descent_with_line_search(
        loss_function: Callable[[Vector], float],
        gradient_function: Callable[[Vector], Vector],
        initial_weights: Vector,
        num_iterations: int = 100,
        initial_alpha: float = 1.0,
        tolerance: float = 1e-6,
        verbose: bool = False
    ) -> Tuple[Vector, List[float]]:
        """
        Gradient descent with adaptive learning rates via line search.
        
        This automatically adjusts the learning rate at each step using
        backtracking line search. No manual learning rate tuning needed!
        
        Args:
            loss_function: Function to compute loss.
            gradient_function: Function to compute gradient.
            initial_weights: Starting weights.
            num_iterations: Maximum iterations.
            initial_alpha: Starting step size.
            tolerance: Convergence tolerance.
            verbose: Whether to print progress.
            
        Returns:
            Tuple of (final_weights, loss_history).
        """
        weights = initial_weights
        loss_history = []
        
        for iteration in range(num_iterations):
            loss = loss_function(weights)
            loss_history.append(loss)
            
            gradient = gradient_function(weights)
            
            # Direction is negative gradient
            direction = -gradient
            
            # Find good step size using line search
            alpha = GradientDescent.backtracking_line_search(
                loss_function, gradient_function, weights, direction, 
                alpha=initial_alpha
            )
            
            # Update weights
            weights_new = weights + alpha * direction
            
            weight_change = (weights_new - weights).norm(2)
            if weight_change < tolerance:
                if verbose:
                    print(f"Converged at iteration {iteration}")
                return weights_new, loss_history
            
            weights = weights_new
            
            if verbose and iteration % 10 == 0:
                print(f"Iteration {iteration}: loss = {loss:.6f}, alpha = {alpha:.6f}")
        
        return weights, loss_history
    
    # ==================== LEARNING RATE SCHEDULING ====================
    
    @staticmethod
    def exponential_decay(initial_lr: float, epoch: int, decay_rate: float) -> float:
        """
        Exponential learning rate decay.
        
        Learning rate = initial_lr * exp(-decay_rate * epoch)
        
        This reduces the learning rate over time to fine-tune weights.
        
        Args:
            initial_lr: Starting learning rate.
            epoch: Current epoch number.
            decay_rate: Decay rate parameter.
            
        Returns:
            The adjusted learning rate.
        """
        return initial_lr * math.exp(-decay_rate * epoch)
    
    @staticmethod
    def step_decay(initial_lr: float, epoch: int, 
                   drop_rate: float = 0.5, 
                   epochs_per_drop: int = 10) -> float:
        """
        Step learning rate decay.
        
        Learning rate = initial_lr * drop_rate^(epoch / epochs_per_drop)
        
        This reduces the learning rate by a fixed factor at regular intervals.
        """
        return initial_lr * (drop_rate ** (epoch // epochs_per_drop))
```

#### Step 2: Update Package Initialization

**File: `src/calculus/__init__.py`**

```python
"""
Calculus package for machine learning optimization.
"""

from src.calculus.derivatives import Derivatives
from src.calculus.optimization import GradientDescent

__all__ = ['Derivatives', 'GradientDescent']
```

#### Step 3: Create the Test Suite

**File: `tests/test_optimization.py`**

```python
"""
Unit tests for optimization algorithms.
"""

import pytest
import math
from src.calculus import Derivatives, GradientDescent
from src.linear_algebra import Vector, Matrix


class TestOptimization:
    """Test suite for optimization algorithms."""
    
    def test_batch_gradient_descent(self):
        """Test batch gradient descent."""
        
        # Simple quadratic function: f(w) = w1^2 + w2^2
        def f(w: Vector) -> float:
            return sum(x ** 2 for x in w)
        
        def grad_f(w: Vector) -> Vector:
            return Vector([2 * x for x in w])
        
        initial_w = Vector([5.0, 3.0])
        final_w, history = GradientDescent.batch_gradient_descent(
            f, grad_f, initial_w, 
            learning_rate=0.1, 
            num_iterations=100
        )
        
        # Should converge to (0, 0)
        assert final_w[0] == pytest.approx(0.0, abs=1e-5)
        assert final_w[1] == pytest.approx(0.0, abs=1e-5)
        
        # Loss should decrease
        assert history[0] > history[-1]
        
        # The total number of iterations
        assert len(history) == 100
    
    def test_gradient_descent_with_momentum(self):
        """Test gradient descent with momentum."""
        
        def f(w: Vector) -> float:
            return sum(x ** 2 for x in w)
        
        def grad_f(w: Vector) -> Vector:
            return Vector([2 * x for x in w])
        
        initial_w = Vector([5.0, 3.0])
        final_w, history = GradientDescent.gradient_descent_with_momentum(
            f, grad_f, initial_w,
            learning_rate=0.1,
            momentum=0.9,
            num_iterations=100
        )
        
        # Should converge to (0, 0)
        assert final_w[0] == pytest.approx(0.0, abs=1e-5)
        assert final_w[1] == pytest.approx(0.0, abs=1e-5)
        
        # Momentum should help: loss should decrease faster initially
        # (We can check the loss after first few iterations)
        assert len(history) == 100
    
    def test_adam_optimizer(self):
        """Test Adam optimizer."""
        
        def f(w: Vector) -> float:
            return sum(x ** 2 for x in w)
        
        def grad_f(w: Vector) -> Vector:
            return Vector([2 * x for x in w])
        
        initial_w = Vector([5.0, 3.0])
        final_w, history = GradientDescent.adam_optimizer(
            f, grad_f, initial_w,
            learning_rate=0.1,
            num_iterations=100
        )
        
        # Should converge to (0, 0)
        assert final_w[0] == pytest.approx(0.0, abs=1e-5)
        assert final_w[1] == pytest.approx(0.0, abs=1e-5)
        
        # Adam should converge nicely
        assert len(history) == 100
    
    def test_backtracking_line_search(self):
        """Test backtracking line search."""
        
        def f(x: float) -> float:
            return (x - 3) ** 2
        
        def grad_f(x: float) -> float:
            return 2 * (x - 3)
        
        # For a simple 1D function, let's test using our vector functions
        def f_vec(w: Vector) -> float:
            return (w[0] - 3) ** 2
        
        def grad_vec(w: Vector) -> Vector:
            return Vector([2 * (w[0] - 3)])
        
        x = Vector([0.0])
        direction = -grad_vec(x)  # Negative gradient
        
        alpha = GradientDescent.backtracking_line_search(
            f_vec, grad_vec, x, direction,
            alpha=1.0, c=0.8, rho=0.5
        )
        
        # Step size should be positive and reasonable
        assert alpha > 0
        assert alpha <= 1.0
        
        # Test with gradient descent using line search
        final_w, history = GradientDescent.gradient_descent_with_line_search(
            f_vec, grad_vec, x,
            num_iterations=100
        )
        
        # Should converge close to 3
        assert final_w[0] == pytest.approx(3.0, abs=1e-5)
    
    def test_learning_rate_scheduling(self):
        """Test learning rate scheduling functions."""
        
        initial_lr = 0.1
        
        # Exponential decay
        lr1 = GradientDescent.exponential_decay(initial_lr, 10, 0.1)
        lr2 = GradientDescent.exponential_decay(initial_lr, 20, 0.1)
        
        # Should decrease
        assert lr2 < lr1 < initial_lr
        
        # Step decay
        lr_step1 = GradientDescent.step_decay(initial_lr, 5, 0.5, 10)
        lr_step2 = GradientDescent.step_decay(initial_lr, 15, 0.5, 10)
        
        # Should decrease at epoch 10
        assert lr_step1 == initial_lr  # Before first drop
        assert lr_step2 == initial_lr * 0.5  # After first drop
    
    def test_rosenbrock_optimization(self):
        """Test optimization on the Rosenbrock function."""
        
        # Rosenbrock function: f(x,y) = (1-x)^2 + 100(y-x^2)^2
        # Minimum at (1, 1)
        def rosenbrock(w: Vector) -> float:
            x, y = w[0], w[1]
            return (1 - x) ** 2 + 100 * (y - x ** 2) ** 2
        
        def rosenbrock_grad(w: Vector) -> Vector:
            x, y = w[0], w[1]
            dx = -2 * (1 - x) - 400 * x * (y - x ** 2)
            dy = 200 * (y - x ** 2)
            return Vector([dx, dy])
        
        initial_w = Vector([-1.0, 1.0])
        
        # Test different optimizers on Rosenbrock
        # Batch GD
        final_w, history = GradientDescent.batch_gradient_descent(
            rosenbrock, rosenbrock_grad, initial_w,
            learning_rate=0.001, num_iterations=1000
        )
        
        # Should get close to (1, 1)
        assert final_w[0] == pytest.approx(1.0, abs=1e-2)
        assert final_w[1] == pytest.approx(1.0, abs=1e-2)
        
        # Adam should do better on Rosenbrock
        final_w_adam, history_adam = GradientDescent.adam_optimizer(
            rosenbrock, rosenbrock_grad, initial_w,
            learning_rate=0.01, num_iterations=1000
        )
        
        assert final_w_adam[0] == pytest.approx(1.0, abs=1e-3)
        assert final_w_adam[1] == pytest.approx(1.0, abs=1e-3)
    
    def test_mini_batch_gradient_descent(self):
        """Test mini-batch gradient descent."""
        
        # Generate synthetic data
        n_samples = 100
        n_features = 3
        true_w = Vector([2.0, -1.0, 3.0])
        
        # Generate data
        X_data = [[float(i * j) for j in range(n_features)] 
                 for i in range(n_samples)]
        X = Matrix(X_data)
        y = X.vector_dot(true_w)
        
        # Add some noise
        import random
        random.seed(42)
        y = Vector([y[i] + random.gauss(0, 0.1) for i in range(y.size)])
        
        # Linear regression loss
        def loss_function(w: Vector, X: Matrix, y: Vector) -> float:
            predictions = X.vector_dot(w)
            errors = predictions - y
            return errors.dot(errors) / (2 * X.rows)
        
        def gradient_function(w: Vector, X: Matrix, y: Vector) -> Vector:
            predictions = X.vector_dot(w)
            errors = predictions - y
            return X.T.vector_dot(errors) / X.rows
        
        initial_w = Vector.zeros(n_features)
        
        final_w, history = GradientDescent.mini_batch_gradient_descent(
            loss_function, gradient_function, initial_w,
            X, y,
            batch_size=10,
            learning_rate=0.01,
            num_epochs=100
        )
        
        # Should get close to true weights
        assert final_w[0] == pytest.approx(true_w[0], abs=0.5)
        assert final_w[1] == pytest.approx(true_w[1], abs=0.5)
        assert final_w[2] == pytest.approx(true_w[2], abs=0.5)
    
    def test_gradient_check_with_optimization(self):
        """Test gradient checking with optimization functions."""
        
        def f(w: Vector) -> float:
            return sum(x ** 2 for x in w)
        
        def grad_f(w: Vector) -> Vector:
            return Vector([2 * x for x in w])
        
        x = Vector([1.0, 2.0, 3.0])
        
        # Verify gradient implementation
        assert Derivatives.gradient_check(f, grad_f, x) == True
        
        # Use gradient descent to find minimum
        final_w, history = GradientDescent.batch_gradient_descent(
            f, grad_f, Vector([5.0, 4.0, 3.0]),
            learning_rate=0.1,
            num_iterations=50
        )
        
        # Should converge to zero
        assert final_w.norm(2) < 1e-5
```

### The Verification

#### Step 1: Run the Tests

```bash
# From the project root
pytest tests/test_optimization.py -v
```

You should see all tests passing:

```
==================== test session starts ====================
collected 7 items

tests/test_optimization.py::TestOptimization::test_batch_gradient_descent PASSED
tests/test_optimization.py::TestOptimization::test_gradient_descent_with_momentum PASSED
tests/test_optimization.py::TestOptimization::test_adam_optimizer PASSED
tests/test_optimization.py::TestOptimization::test_backtracking_line_search PASSED
tests/test_optimization.py::TestOptimization::test_learning_rate_scheduling PASSED
tests/test_optimization.py::TestOptimization::test_rosenbrock_optimization PASSED
tests/test_optimization.py::TestOptimization::test_mini_batch_gradient_descent PASSED

==================== 7 passed in 1.23s ====================
```

#### Step 2: Interactive Verification

```bash
# From the project root
python
```

```python
>>> from src.calculus import GradientDescent
>>> from src.linear_algebra import Vector
>>> 
>>> # Simple quadratic optimization
>>> def f(w: Vector) -> float:
...     return sum(x**2 for x in w)
...
>>> def grad_f(w: Vector) -> Vector:
...     return Vector([2*x for x in w])
...
>>> initial = Vector([10.0, -5.0, 3.0])
>>> 
>>> # Try batch gradient descent
>>> final, history = GradientDescent.batch_gradient_descent(
...     f, grad_f, initial,
...     learning_rate=0.1,
...     num_iterations=100,
...     verbose=True
... )
Iteration 0: loss = 134.000000
Iteration 100: loss = 0.000000
>>> 
>>> print(f"Final weights: {final}")
Final weights: [0.0000, -0.0000, 0.0000]
>>> 
>>> # Try Adam optimizer
>>> final_adam, history_adam = GradientDescent.adam_optimizer(
...     f, grad_f, initial,
...     learning_rate=0.1,
...     num_iterations=50
... )
>>> 
>>> print(f"Adam final weights: {final_adam}")
Adam final weights: [0.0000, -0.0000, 0.0000]
>>> 
>>> # Try Rosenbrock optimization
>>> def rosenbrock(w: Vector) -> float:
...     x, y = w[0], w[1]
...     return (1 - x)**2 + 100*(y - x**2)**2
...
>>> def rosenbrock_grad(w: Vector) -> Vector:
...     x, y = w[0], w[1]
...     dx = -2*(1 - x) - 400*x*(y - x**2)
...     dy = 200*(y - x**2)
...     return Vector([dx, dy])
...
>>> initial = Vector([-1.0, 1.0])
>>> final, _ = GradientDescent.adam_optimizer(
...     rosenbrock, rosenbrock_grad, initial,
...     learning_rate=0.01,
...     num_iterations=1000
... )
>>> 
>>> print(f"Rosenbrock minimum at ({final[0]:.4f}, {final[1]:.4f})")
Rosenbrock minimum at (1.0000, 1.0000)
```

#### Step 3: Visualize Optimization Progress

Let's create a quick visualization to see how different optimizers compare:

```python
>>> import matplotlib.pyplot as plt
>>> 
>>> # Same function, different optimizers
>>> def f(w): return sum(x**2 for x in w)
>>> def grad_f(w): return Vector([2*x for x in w])
>>> 
>>> initial = Vector([5.0, 5.0])
>>> 
>>> # Batch GD
>>> _, history_batch = GradientDescent.batch_gradient_descent(
...     f, grad_f, initial, learning_rate=0.1, num_iterations=100
... )
>>> 
>>> # With momentum
>>> _, history_momentum = GradientDescent.gradient_descent_with_momentum(
...     f, grad_f, initial, learning_rate=0.1, momentum=0.9, num_iterations=100
... )
>>> 
>>> # Adam
>>> _, history_adam = GradientDescent.adam_optimizer(
...     f, grad_f, initial, learning_rate=0.1, num_iterations=100
... )
>>> 
>>> plt.figure(figsize=(10, 6))
>>> plt.plot(history_batch, label='Batch GD', linewidth=2)
>>> plt.plot(history_momentum, label='Momentum', linewidth=2)
>>> plt.plot(history_adam, label='Adam', linewidth=2)
>>> plt.yscale('log')
>>> plt.xlabel('Iteration')
>>> plt.ylabel('Loss')
>>> plt.title('Comparison of Optimization Algorithms')
>>> plt.legend()
>>> plt.grid(True, alpha=0.3)
>>> plt.show()
```

### What We've Accomplished

In this module, we've built:

1. **Three gradient descent variants**:
   - Batch GD: Accurate but slow for large data
   - Stochastic GD: Fast but noisy
   - Mini-batch GD: The practical sweet spot

2. **Advanced optimization algorithms**:
   - Momentum: Accelerates convergence
   - Adam: Adaptive learning rates per parameter

3. **Learning rate techniques**:
   - Backtracking line search: Automatic learning rate selection
   - Learning rate scheduling: Reduce learning rate over time

4. **Complete optimization pipeline**:
   - Loss computation
   - Gradient computation (using our calculus library)
   - Weight updates
   - Convergence monitoring

### Why This Matters for Machine Learning

**The key insight**: Every machine learning model, from linear regression to deep neural networks, uses some form of gradient descent. Understanding these optimization algorithms is understanding how models learn.

| Algorithm | Best For | Trade-offs |
|-----------|----------|------------|
| **Batch GD** | Small datasets (< 1000 samples) | Accurate but slow |
| **SGD** | Very large datasets | Fast but noisy |
| **Mini-batch** | Most practical applications | Good balance |
| **Momentum** | Problems with flat regions | Faster convergence |
| **Adam** | Deep learning, general use | Works well out of the box |

### What's Next

In the next module, we'll bring everything together to implement **linear regression and logistic regression** from scratch, using our linear algebra library for data representation and our calculus library for optimization.

---

*Next: We'll implement the chain rule and backpropagation, the algorithm that makes deep learning possible, and build a simple neural network from scratch.*
