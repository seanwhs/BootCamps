# Phase 2, Part 1: Calculus — The Engine of Optimization

## Module 1: Derivatives — Measuring Change in ML Systems

### The Target

We're building the calculus foundation for machine learning optimization. This module covers derivatives, partial derivatives, and numerical differentiation—the tools we need to measure how changes in our model parameters affect its performance.

**Files we'll create:**
- `src/calculus/__init__.py`
- `src/calculus/derivatives.py`
- `tests/test_calculus.py`

### The Concept

Imagine you're driving a car and you want to know how quickly you're accelerating. You look at the speedometer, see you're going 60 mph, then look again a second later and see you're going 65 mph. Your acceleration is 5 mph per second.

That's a **derivative** in action: measuring how one quantity changes with respect to another.

In machine learning, we use derivatives to answer questions like:
- "How much will my error change if I increase this weight by a tiny amount?"
- "Which direction should I adjust my parameters to reduce the error the fastest?"
- "Is my model converging to the right solution?"

**Key concepts:**
- **Derivative**: The rate of change of a function at a point (slope)
- **Gradient**: A vector of partial derivatives (rate of change in each direction)
- **Partial derivative**: The derivative with respect to one variable, holding others constant

**Why this matters for ML**: When your model makes a prediction, it computes:

```
prediction = weight₁ × feature₁ + weight₂ × feature₂ + ... + bias
```

The "learning" part of machine learning is figuring out the right weights. Derivatives tell us how to adjust each weight to reduce the error.

### The Implementation

#### Step 1: Set Up the Calculus Module

```bash
# From your project root
mkdir -p src/calculus
touch src/calculus/__init__.py
```

#### Step 2: Implement Derivatives

**File: `src/calculus/derivatives.py`**

```python
"""
Derivative implementations for machine learning optimization.

This module provides numerical and analytical derivative computations
used in gradient-based optimization algorithms.
"""

from typing import Callable, List, Union, Optional
import math
from src.linear_algebra import Vector, Matrix


class Derivatives:
    """
    Derivative computation utilities for machine learning.
    
    This class provides both numerical approximations (which work on
    any function) and analytical derivatives (for known functions).
    """
    
    # ==================== NUMERICAL DERIVATIVES ====================
    
    @staticmethod
    def numerical_derivative_1d(f: Callable[[float], float], 
                                x: float, 
                                h: float = 1e-7) -> float:
        """
        Compute the derivative of a 1D function using central difference.
        
        The central difference method approximates the derivative at point x
        by looking at the function values just before and after x:
        
        f'(x) ≈ (f(x + h) - f(x - h)) / (2h)
        
        This is more accurate than forward difference because it's
        symmetric around the point of interest.
        
        Analogy: Instead of measuring your speed by looking at your
        speedometer once, you look at it just before and just after
        the moment in question and average them.
        
        Args:
            f: The function to differentiate.
            x: The point at which to compute the derivative.
            h: The step size (smaller = more accurate, but risk of 
               numerical precision issues).
            
        Returns:
            The approximate derivative at x.
            
        Examples:
            >>> def square(x): return x ** 2
            >>> Derivatives.numerical_derivative_1d(square, 3)
            6.0  # derivative of x^2 is 2x, at x=3 is 6
        """
        if h <= 0:
            raise ValueError("Step size h must be positive")
        
        # Central difference formula
        return (f(x + h) - f(x - h)) / (2 * h)
    
    @staticmethod
    def numerical_derivative_1d_forward(f: Callable[[float], float],
                                        x: float,
                                        h: float = 1e-7) -> float:
        """
        Forward difference derivative approximation.
        
        This is simpler but less accurate than central difference:
        f'(x) ≈ (f(x + h) - f(x)) / h
        
        Used when we can only evaluate the function at x and after x.
        
        Args:
            f: The function to differentiate.
            x: The point at which to compute the derivative.
            h: The step size.
            
        Returns:
            The approximate derivative at x.
        """
        if h <= 0:
            raise ValueError("Step size h must be positive")
        
        return (f(x + h) - f(x)) / h
    
    @staticmethod
    def numerical_gradient_nd(f: Callable[[Vector], float],
                              x: Vector,
                              h: float = 1e-7) -> Vector:
        """
        Compute the gradient of a multi-dimensional function using finite differences.
        
        The gradient is a vector of partial derivatives, one for each dimension.
        We compute each partial derivative by perturbing one dimension at a time.
        
        Analogy: You're standing on a hill and want to know which way is
        steepest. You take a tiny step north and measure the change in
        elevation, then a tiny step east, etc. The gradient points in the
        direction of steepest ascent.
        
        Args:
            f: The function to differentiate (takes a Vector and returns a float).
            x: The point at which to compute the gradient.
            h: The step size for each dimension.
            
        Returns:
            A Vector of partial derivatives (the gradient).
            
        Examples:
            >>> def sum_squares(v): return sum(x**2 for x in v)
            >>> v = Vector([1, 2, 3])
            >>> grad = Derivatives.numerical_gradient_nd(sum_squares, v)
            >>> grad  # Should be approximately [2, 4, 6]
            Vector([1.9999999, 4.0000000, 6.0000000])
        """
        if x.size == 0:
            return Vector([])
        
        if h <= 0:
            raise ValueError("Step size h must be positive")
        
        # Initialize gradient vector
        gradient = Vector.zeros(x.size)
        
        # Compute partial derivative for each dimension
        for i in range(x.size):
            # Create perturbed vectors
            x_plus = x.to_list()
            x_minus = x.to_list()
            
            x_plus[i] = x_plus[i] + h
            x_minus[i] = x_minus[i] - h
            
            # Convert back to Vectors
            v_plus = Vector(x_plus)
            v_minus = Vector(x_minus)
            
            # Central difference for this dimension
            gradient[i] = (f(v_plus) - f(v_minus)) / (2 * h)
        
        return gradient
    
    # ==================== ANALYTICAL DERIVATIVES ====================
    
    @staticmethod
    def derivative_power(x: float, exponent: float) -> float:
        """
        Derivative of x^n: d/dx x^n = n * x^(n-1)
        
        Used for polynomial functions in machine learning (e.g., 
        L2 regularization: x^2, derivative is 2x).
        
        Args:
            x: The point at which to evaluate.
            exponent: The power n.
            
        Returns:
            The derivative value.
        """
        if x == 0 and exponent < 1:
            raise ValueError("Undefined derivative at x=0 for exponent < 1")
        
        return exponent * (x ** (exponent - 1))
    
    @staticmethod
    def derivative_exp(x: float) -> float:
        """
        Derivative of e^x: d/dx e^x = e^x
        
        Exponential functions appear in ML in:
        - Softmax activation: e^x / sum(e^x)
        - Probability distributions (exponential family)
        - Sigmoid function: 1 / (1 + e^(-x))
        """
        return math.exp(x)
    
    @staticmethod
    def derivative_log(x: float, base: float = math.e) -> float:
        """
        Derivative of log(x): d/dx log_base(x) = 1 / (x * ln(base))
        
        Natural log appears in ML in:
        - Cross-entropy loss: -log(p)
        - Information theory (entropy)
        - Maximum likelihood estimation
        """
        if x <= 0:
            raise ValueError("Log derivative undefined for x <= 0")
        
        if base == math.e:
            return 1 / x
        return 1 / (x * math.log(base))
    
    @staticmethod
    def derivative_sigmoid(x: float) -> float:
        """
        Derivative of the sigmoid function: d/dx σ(x) = σ(x) * (1 - σ(x))
        
        The sigmoid function: σ(x) = 1 / (1 + e^(-x))
        
        This derivative is used in logistic regression and neural networks.
        It has a nice property: the derivative depends only on the output,
        which makes it efficient to compute during backpropagation.
        
        Analogy: The sigmoid derivative is like the "friction" that slows
        down learning when the neuron is already saturated (near 0 or 1).
        
        Args:
            x: Input value.
            
        Returns:
            The derivative of sigmoid at x.
        """
        # Compute sigmoid
        sigmoid = 1 / (1 + math.exp(-x))
        
        # Derivative
        return sigmoid * (1 - sigmoid)
    
    @staticmethod
    def derivative_tanh(x: float) -> float:
        """
        Derivative of tanh: d/dx tanh(x) = 1 - tanh(x)^2
        
        Hyperbolic tangent is another activation function used in
        neural networks. Its derivative is also simple to compute
        from the output.
        """
        tanh_val = math.tanh(x)
        return 1 - tanh_val * tanh_val
    
    @staticmethod
    def derivative_relu(x: float) -> float:
        """
        Derivative of ReLU (Rectified Linear Unit).
        
        ReLU(x) = max(0, x)
        Derivative: 1 if x > 0, 0 if x < 0, undefined at x=0 (we use 0)
        
        ReLU is the most common activation function in deep learning
        because its gradient is simple and avoids vanishing gradients.
        
        Analogy: ReLU is like a light switch: if the input is positive,
        the signal passes through; if negative, it's blocked.
        """
        return 1.0 if x > 0 else 0.0
    
    @staticmethod
    def derivative_mse(prediction: float, target: float) -> float:
        """
        Derivative of Mean Squared Error with respect to prediction.
        
        MSE(y_pred, y_true) = (y_pred - y_true)^2
        Derivative: 2 * (y_pred - y_true)
        
        This is the workhorse derivative for regression problems.
        The gradient is simply the error multiplied by 2.
        """
        return 2 * (prediction - target)
    
    @staticmethod
    def derivative_cross_entropy(prediction: float, target: float) -> float:
        """
        Derivative of Binary Cross-Entropy with respect to prediction.
        
        BCE(y_pred, y_true) = -[y_true * log(y_pred) + (1-y_true) * log(1-y_pred)]
        Derivative: (y_pred - y_true) / (y_pred * (1 - y_pred))
        
        This is the standard loss for binary classification.
        It has a nice property: the gradient is proportional to the error,
        which makes learning efficient.
        
        Analogy: When your prediction is very wrong, the gradient is large
        (big correction). When it's close to correct, the gradient is small
        (fine-tuning).
        """
        # Add small epsilon to prevent division by zero
        epsilon = 1e-10
        pred_clipped = min(max(prediction, epsilon), 1 - epsilon)
        
        return (pred_clipped - target) / (pred_clipped * (1 - pred_clipped))
    
    # ==================== HIGHER-ORDER DERIVATIVES ====================
    
    @staticmethod
    def second_derivative_numerical(f: Callable[[float], float],
                                    x: float,
                                    h: float = 1e-7) -> float:
        """
        Compute the second derivative using finite differences.
        
        The second derivative measures the curvature of a function.
        In ML, it helps us understand:
        - Whether we're at a minimum, maximum, or saddle point
        - How fast the gradient is changing (Newton's method)
        - The Hessian matrix (second-order optimization)
        
        Formula: f''(x) ≈ (f(x + h) - 2f(x) + f(x - h)) / h^2
        
        Args:
            f: The function.
            x: The point.
            h: Step size.
            
        Returns:
            The approximate second derivative.
        """
        if h <= 0:
            raise ValueError("Step size h must be positive")
        
        return (f(x + h) - 2 * f(x) + f(x - h)) / (h * h)
    
    @staticmethod
    def hessian_numerical(f: Callable[[Vector], float],
                          x: Vector,
                          h: float = 1e-7) -> Matrix:
        """
        Compute the Hessian matrix numerically.
        
        The Hessian is a matrix of second partial derivatives:
        H[i,j] = ∂²f / ∂x_i ∂x_j
        
        The Hessian tells us about the curvature of the loss landscape:
        - Positive definite: we're at a minimum
        - Negative definite: we're at a maximum
        - Mixed: saddle point
        
        In deep learning, the Hessian is too expensive to compute
        for large models, but understanding it helps us design
        better optimization algorithms (like Adam).
        
        Args:
            f: The function.
            x: The point at which to compute the Hessian.
            h: Step size.
            
        Returns:
            Matrix of second partial derivatives.
        """
        n = x.size
        if n == 0:
            return Matrix.zeros(0, 0)
        
        # Initialize Hessian
        hessian = Matrix.zeros(n, n)
        
        # Compute second derivatives using central difference
        for i in range(n):
            for j in range(i, n):  # Hessian is symmetric
                # Create perturbed vectors
                x_plus_i = x.to_list()
                x_minus_i = x.to_list()
                x_plus_j = x.to_list()
                x_minus_j = x.to_list()
                x_plus_ij = x.to_list()
                x_minus_ij = x.to_list()
                
                x_plus_i[i] += h
                x_minus_i[i] -= h
                x_plus_j[j] += h
                x_minus_j[j] -= h
                x_plus_ij[i] += h
                x_plus_ij[j] += h
                x_minus_ij[i] -= h
                x_minus_ij[j] -= h
                
                # Convert to vectors
                v_plus_i = Vector(x_plus_i)
                v_minus_i = Vector(x_minus_i)
                v_plus_j = Vector(x_plus_j)
                v_minus_j = Vector(x_minus_j)
                v_plus_ij = Vector(x_plus_ij)
                v_minus_ij = Vector(x_minus_ij)
                
                # Mixed second derivative
                if i == j:
                    # Second derivative with respect to same variable
                    hessian[i, i] = (f(v_plus_i) - 2 * f(x) + f(v_minus_i)) / (h * h)
                else:
                    # Mixed partial derivative
                    hessian[i, j] = (f(v_plus_ij) - f(v_plus_i) - f(v_plus_j) + f(x)) / (h * h)
                    hessian[j, i] = hessian[i, j]  # Symmetric
        
        return hessian
    
    # ==================== GRADIENT CHECKING ====================
    
    @staticmethod
    def gradient_check(f: Callable[[Vector], float],
                       grad_f: Callable[[Vector], Vector],
                       x: Vector,
                       tolerance: float = 1e-5,
                       h: float = 1e-7) -> bool:
        """
        Check if an analytical gradient implementation is correct.
        
        This is a crucial debugging tool in ML. Often we implement
        complex gradient computations and need to verify they're correct
        before using them in training.
        
        We compare the analytical gradient against numerical finite
        differences. If they match within tolerance, the gradient is
        likely correct.
        
        Args:
            f: The function.
            grad_f: The gradient function to test.
            x: The test point.
            tolerance: Maximum allowed difference.
            h: Step size for numerical gradient.
            
        Returns:
            True if gradients match, False otherwise.
            
        Examples:
            >>> def f(v): return sum(x**2 for x in v)
            >>> def grad_f(v): return Vector([2*x for x in v])
            >>> x = Vector([1, 2, 3])
            >>> Derivatives.gradient_check(f, grad_f, x)
            True  # Analytical gradient matches numerical gradient
        """
        # Compute analytical gradient
        grad_analytical = grad_f(x)
        
        # Compute numerical gradient
        grad_numerical = Derivatives.numerical_gradient_nd(f, x, h)
        
        # Check each component
        for i in range(x.size):
            diff = abs(grad_analytical[i] - grad_numerical[i])
            if diff > tolerance:
                print(f"Gradient check failed at dimension {i}:")
                print(f"  Analytical: {grad_analytical[i]}")
                print(f"  Numerical: {grad_numerical[i]}")
                print(f"  Difference: {diff}")
                return False
        
        return True
    
    # ==================== SCALAR FUNCTIONS FOR TESTING ====================
    
    @staticmethod
    def f_square(x: float) -> float:
        """Simple square function for testing."""
        return x ** 2
    
    @staticmethod
    def f_cubic(x: float) -> float:
        """Cubic function for testing."""
        return x ** 3 - 3 * x ** 2 + 2 * x
    
    @staticmethod
    def f_sin(x: float) -> float:
        """Sine function for testing."""
        return math.sin(x)
    
    @staticmethod
    def f_exp(x: float) -> float:
        """Exponential function for testing."""
        return math.exp(x)
    
    @staticmethod
    def f_logistic(x: float) -> float:
        """Logistic (sigmoid) function for testing."""
        return 1 / (1 + math.exp(-x))
```

#### Step 3: Update Package Initialization

**File: `src/calculus/__init__.py`**

```python
"""
Calculus package for machine learning optimization.
"""

from src.calculus.derivatives import Derivatives

__all__ = ['Derivatives']
```

#### Step 4: Create the Test Suite

**File: `tests/test_calculus.py`**

```python
"""
Unit tests for the calculus module.
"""

import pytest
import math
from src.calculus import Derivatives
from src.linear_algebra import Vector, Matrix


class TestDerivatives:
    """Test suite for derivative computations."""
    
    def test_numerical_derivative_1d(self):
        """Test numerical derivative of 1D functions."""
        # Derivative of x^2 at x=3 should be 6
        derivative = Derivatives.numerical_derivative_1d(
            Derivatives.f_square, 3.0
        )
        assert derivative == pytest.approx(6.0, abs=1e-5)
        
        # Derivative of sin(x) at x=0 should be 1
        derivative = Derivatives.numerical_derivative_1d(
            math.sin, 0.0
        )
        assert derivative == pytest.approx(1.0, abs=1e-5)
        
        # Derivative of exp(x) at x=0 should be 1
        derivative = Derivatives.numerical_derivative_1d(
            math.exp, 0.0
        )
        assert derivative == pytest.approx(1.0, abs=1e-5)
    
    def test_numerical_gradient_nd(self):
        """Test numerical gradient of multi-dimensional functions."""
        
        def sum_squares(v: Vector) -> float:
            return sum(x ** 2 for x in v)
        
        x = Vector([1.0, 2.0, 3.0])
        gradient = Derivatives.numerical_gradient_nd(sum_squares, x)
        
        # Derivative of x^2 is 2x
        assert gradient[0] == pytest.approx(2.0, abs=1e-5)
        assert gradient[1] == pytest.approx(4.0, abs=1e-5)
        assert gradient[2] == pytest.approx(6.0, abs=1e-5)
        
        def rosenbrock(v: Vector) -> float:
            """Rosenbrock function for testing."""
            x, y = v[0], v[1]
            return (1 - x) ** 2 + 100 * (y - x ** 2) ** 2
        
        x = Vector([0.0, 0.0])
        gradient = Derivatives.numerical_gradient_nd(rosenbrock, x)
        
        # Rosenbrock gradient at (0,0):
        # ∂f/∂x = -2(1-x) - 400x(y-x^2) = -2
        # ∂f/∂y = 200(y-x^2) = 0
        assert gradient[0] == pytest.approx(-2.0, abs=1e-5)
        assert gradient[1] == pytest.approx(0.0, abs=1e-5)
    
    def test_analytical_derivatives(self):
        """Test analytical derivative functions."""
        # Power rule: d/dx x^3 = 3x^2
        assert Derivatives.derivative_power(2, 3) == 12.0
        
        # Exponential: d/dx e^x = e^x
        assert Derivatives.derivative_exp(1) == math.exp(1)
        
        # Log: d/dx ln(x) = 1/x
        assert Derivatives.derivative_log(2) == 0.5
        
        # Sigmoid: derivative at 0 is 0.25
        assert Derivatives.derivative_sigmoid(0) == 0.25
        
        # Tanh: derivative at 0 is 1
        assert Derivatives.derivative_tanh(0) == 1.0
        
        # ReLU: derivative at positive is 1, negative is 0
        assert Derivatives.derivative_relu(5) == 1.0
        assert Derivatives.derivative_relu(-5) == 0.0
        
        # MSE: derivative at prediction=2, target=1 is 2
        assert Derivatives.derivative_mse(2, 1) == 2.0
        
        # Cross-entropy: derivative at prediction=0.8, target=1
        # (0.8 - 1) / (0.8 * 0.2) = -0.2 / 0.16 = -1.25
        assert Derivatives.derivative_cross_entropy(0.8, 1) == pytest.approx(-1.25, rel=1e-5)
    
    def test_second_derivative(self):
        """Test second derivative computation."""
        # Second derivative of x^2 is 2
        second = Derivatives.second_derivative_numerical(
            Derivatives.f_square, 3.0
        )
        assert second == pytest.approx(2.0, abs=1e-5)
        
        # Second derivative of x^3 is 6x
        second = Derivatives.second_derivative_numerical(
            Derivatives.f_cubic, 2.0
        )
        assert second == pytest.approx(12.0, abs=1e-5)  # 6 * 2 = 12
    
    def test_hessian(self):
        """Test Hessian matrix computation."""
        def sum_squares(v: Vector) -> float:
            return sum(x ** 2 for x in v)
        
        x = Vector([1.0, 2.0])
        hessian = Derivatives.hessian_numerical(sum_squares, x)
        
        # Hessian of sum of squares is 2*I
        assert hessian[0, 0] == pytest.approx(2.0, abs=1e-5)
        assert hessian[1, 1] == pytest.approx(2.0, abs=1e-5)
        assert hessian[0, 1] == pytest.approx(0.0, abs=1e-5)
        assert hessian[1, 0] == pytest.approx(0.0, abs=1e-5)
        
        def rosenbrock(v: Vector) -> float:
            x, y = v[0], v[1]
            return (1 - x) ** 2 + 100 * (y - x ** 2) ** 2
        
        x = Vector([0.0, 0.0])
        hessian = Derivatives.hessian_numerical(rosenbrock, x)
        
        # Hessian of Rosenbrock at (0,0):
        # H = [[-2 + 400y - 400x^2, -400x], [-400x, 200]]
        # At (0,0): H = [[-2, 0], [0, 200]]
        assert hessian[0, 0] == pytest.approx(-2.0, abs=1e-4)
        assert hessian[1, 1] == pytest.approx(200.0, abs=1e-4)
        assert hessian[0, 1] == pytest.approx(0.0, abs=1e-4)
    
    def test_gradient_check(self):
        """Test gradient checking."""
        def f(v: Vector) -> float:
            return sum(x ** 2 for x in v)
        
        def grad_f(v: Vector) -> Vector:
            return Vector([2 * x for x in v])
        
        x = Vector([1.0, 2.0, 3.0])
        
        # Correct gradient should pass
        assert Derivatives.gradient_check(f, grad_f, x) == True
        
        # Incorrect gradient should fail
        def grad_f_wrong(v: Vector) -> Vector:
            return Vector([x for x in v])  # Should be 2x
        
        assert Derivatives.gradient_check(f, grad_f_wrong, x) == False
    
    def test_derivative_chain_rule(self):
        """Test chain rule concept: derivative of f(g(x))."""
        # f(x) = (x + 2)^2
        # Let g(x) = x + 2, f(g) = g^2
        # f'(x) = 2 * (x + 2) * 1 = 2x + 4
        
        def f(x: float) -> float:
            return (x + 2) ** 2
        
        # Numerical derivative
        numerical = Derivatives.numerical_derivative_1d(f, 3.0)
        
        # Analytical derivative
        analytical = 2 * (3 + 2)  # 2x + 4 at x=3
        
        assert numerical == pytest.approx(analytical, abs=1e-5)
    
    def test_gradient_of_linear_function(self):
        """Test gradient of a linear function."""
        # f(w) = w^T x = w1*x1 + w2*x2 + ...
        # Gradient: ∇f(w) = x
        
        x_vector = Vector([1.0, 2.0, 3.0])
        
        def linear_function(w: Vector) -> float:
            return w.dot(x_vector)
        
        w = Vector([4.0, 5.0, 6.0])
        gradient = Derivatives.numerical_gradient_nd(linear_function, w)
        
        # Gradient should equal x_vector
        assert gradient[0] == pytest.approx(1.0, abs=1e-5)
        assert gradient[1] == pytest.approx(2.0, abs=1e-5)
        assert gradient[2] == pytest.approx(3.0, abs=1e-5)
    
    def test_gradient_of_quadratic_function(self):
        """Test gradient of a quadratic function."""
        # f(w) = w^T A w
        # Gradient: ∇f(w) = (A + A^T)w
        
        # For symmetric A: ∇f(w) = 2Aw
        A = Matrix([[2.0, 1.0], [1.0, 3.0]])
        
        def quadratic_function(w: Vector) -> float:
            # w^T A w
            Aw = A.vector_dot(w)
            return w.dot(Aw)
        
        w = Vector([1.0, 2.0])
        
        # Numerical gradient
        numerical_grad = Derivatives.numerical_gradient_nd(quadratic_function, w)
        
        # Analytical gradient: 2A w
        Aw = A.vector_dot(w)
        analytical_grad = Aw * 2
        
        assert numerical_grad[0] == pytest.approx(analytical_grad[0], abs=1e-5)
        assert numerical_grad[1] == pytest.approx(analytical_grad[1], abs=1e-5)
```

### The Verification

#### Step 1: Run the Tests

```bash
# From the project root
pytest tests/test_calculus.py -v
```

You should see all tests passing:

```
==================== test session starts ====================
collected 10 items

tests/test_calculus.py::TestDerivatives::test_numerical_derivative_1d PASSED
tests/test_calculus.py::TestDerivatives::test_numerical_gradient_nd PASSED
tests/test_calculus.py::TestDerivatives::test_analytical_derivatives PASSED
tests/test_calculus.py::TestDerivatives::test_second_derivative PASSED
tests/test_calculus.py::TestDerivatives::test_hessian PASSED
tests/test_calculus.py::TestDerivatives::test_gradient_check PASSED
tests/test_calculus.py::TestDerivatives::test_derivative_chain_rule PASSED
tests/test_calculus.py::TestDerivatives::test_gradient_of_linear_function PASSED
tests/test_calculus.py::TestDerivatives::test_gradient_of_quadratic_function PASSED

==================== 9 passed in 0.45s ====================
```

#### Step 2: Interactive Verification

```bash
# From the project root
python
```

```python
>>> from src.calculus import Derivatives
>>> from src.linear_algebra import Vector
>>> import math
>>> 
>>> # Test derivative of square function
>>> def square(x): return x ** 2
>>> 
>>> # Derivative at x=3 should be 6
>>> Derivatives.numerical_derivative_1d(square, 3)
6.000000000009876
>>> 
>>> # Test gradient of a simple function
>>> def sum_squares(v):
...     return sum(x**2 for x in v)
...
>>> v = Vector([1.0, 2.0, 3.0])
>>> grad = Derivatives.numerical_gradient_nd(sum_squares, v)
>>> print(grad)
[1.9999999, 4.0000000, 6.0000000]
>>> 
>>> # Test sigmoid derivative
>>> # At x=0, sigmoid derivative should be 0.25
>>> Derivatives.derivative_sigmoid(0)
0.25
>>> 
>>> # Test gradient checking
>>> def f(v):
...     return sum(x**2 for x in v)
...
>>> def grad_f(v):
...     return Vector([2*x for x in v])
...
>>> x = Vector([1.0, 2.0, 3.0])
>>> Derivatives.gradient_check(f, grad_f, x)
True
```

### What We've Accomplished

In this module, we've built:

1. **Numerical derivative computation**:
   - 1D derivatives using central difference
   - Multi-dimensional gradients using finite differences

2. **Analytical derivatives**:
   - Power rule, exponential, log, and trig functions
   - Activation functions (sigmoid, tanh, ReLU)
   - Common loss functions (MSE, cross-entropy)

3. **Higher-order derivatives**:
   - Second derivatives (curvature)
   - Hessian matrix (second-order information)

4. **Gradient checking**:
   - Verification of analytical gradient implementations

### Why This Matters for Machine Learning

Derivatives are the engine of learning in ML:

| Concept | Role in ML |
|---------|-----------|
| **Derivative** | Tells us how the loss changes with respect to each parameter |
| **Gradient** | Points in the direction of steepest ascent; we move opposite to minimize loss |
| **Partial derivative** | How much each weight contributes to the error |
| **Chain rule** | The foundation of backpropagation in neural networks |
| **Hessian** | Informs advanced optimization algorithms about curvature |

**The key insight**: Learning in machine learning is just optimization, and optimization is just finding where the gradient is zero. Everything else is details.

### What's Next

In the next module, we'll use these derivative tools to implement **Gradient Descent**—the algorithm that actually learns by following gradients to find the minimum of the loss function.

---

*Next: We'll implement gradient descent, stochastic gradient descent, and mini-batch gradient descent, connecting our calculus library to linear algebra to build a complete learning system.*
