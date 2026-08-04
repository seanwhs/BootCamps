# Comprehensive Quiz and Test Bank
## Mathematics for Machine Learning — Complete Assessment Package

---

# PART 1: LINEAR ALGEBRA — QUIZ AND TEST BANK

## Section 1.1: Vectors — Multiple Choice Questions

### Question 1
**What is the dimensionality of a vector that represents a house with 2000 square feet, 3 bedrooms, and 2 bathrooms?**

A) 2
B) 3
C) 4
D) 1

**Answer: B) 3** — The vector has three components: sqft, bedrooms, bathrooms.

---

### Question 2
**Given vectors u = [1, 2, 3] and v = [4, 5, 6], what is the dot product u · v?**

A) 30
B) 32
C) 34
D) 36

**Answer: B) 32** — 1×4 + 2×5 + 3×6 = 4 + 10 + 18 = 32.

---

### Question 3
**What is the L2 norm of vector v = [3, 4]?**

A) 3
B) 4
C) 5
D) 7

**Answer: C) 5** — √(3² + 4²) = √(9 + 16) = √25 = 5.

---

### Question 4
**Normalizing a vector to unit length means:**

A) Making all components equal to 1
B) Dividing by the L2 norm
C) Subtracting the mean
D) Adding 1 to all components

**Answer: B) Dividing by the L2 norm** — Normalization creates a unit vector with L2 norm = 1.

---

### Question 5
**The dot product of two vectors measures:**

A) Their difference
B) Their similarity
C) Their sum
D) Their product

**Answer: B) Their similarity** — Dot product measures how similar two vectors are.

---

### Question 6
**What is the L1 norm of vector v = [-2, 3, -1]?**

A) 4
B) 5
C) 6
D) 7

**Answer: C) 6** — |−2| + |3| + |−1| = 2 + 3 + 1 = 6.

---

### Question 7
**Which of the following is NOT a valid vector operation?**

A) Addition
B) Multiplication by scalar
C) Division by vector
D) Subtraction

**Answer: C) Division by vector** — Vector division is not defined.

---

### Question 8
**A vector of all zeros is called:**

A) Null vector
B) Unit vector
C) Basis vector
D) Identity vector

**Answer: A) Null vector** — The zero vector is also called the null vector.

---

### Question 9
**What is the distance between vectors [1, 1] and [4, 5] using L2 norm?**

A) 3
B) 4
C) 5
D) 7

**Answer: C) 5** — √((4−1)² + (5−1)²) = √(9 + 16) = √25 = 5.

---

### Question 10
**In machine learning, each row of a dataset matrix typically represents:**

A) A feature
B) A sample
C) A weight
D) A label

**Answer: B) A sample** — Rows = samples, columns = features.

---

### Question 11
**The L∞ norm of a vector returns:**

A) The sum of absolute values
B) The square root of sum of squares
C) The maximum absolute value
D) The minimum absolute value

**Answer: C) The maximum absolute value** — L∞ norm = max |v_i|.

---

### Question 12
**Two vectors u and v are orthogonal if:**

A) Their dot product is 0
B) Their dot product is 1
C) They have the same length
D) They are identical

**Answer: A) Their dot product is 0** — Orthogonal vectors are perpendicular.

---

## Section 1.2: Matrices — Multiple Choice Questions

### Question 13
**A matrix with shape (m, n) has:**

A) m rows and n columns
B) n rows and m columns
C) m × n elements
D) Both A and C

**Answer: D) Both A and C** — Shape (m, n) means m rows, n columns, and m×n elements.

---

### Question 14
**What is the transpose of matrix A = [[1, 2, 3], [4, 5, 6]]?**

A) [[1, 4], [2, 5], [3, 6]]
B) [[1, 2], [3, 4], [5, 6]]
C) [[1, 2, 3], [4, 5, 6]]
D) [[4, 5, 6], [1, 2, 3]]

**Answer: A) [[1, 4], [2, 5], [3, 6]]** — Transpose swaps rows and columns.

---

### Question 15
**Matrix multiplication A @ B is defined when:**

A) A rows = B rows
B) A columns = B rows
C) A columns = B columns
D) A rows = B columns

**Answer: B) A columns = B rows** — Inner dimensions must match.

---

### Question 16
**The identity matrix I has the property that:**

A) AI = 0
B) IA = 0
C) AI = IA = A
D) AI = IA = I

**Answer: C) AI = IA = A** — Identity matrix is the multiplicative identity.

---

### Question 17
**A matrix is symmetric if:**

A) A = A^T
B) A = -A^T
C) A × A = I
D) A^T = -A

**Answer: A) A = A^T** — Symmetric matrices equal their transpose.

---

### Question 18
**What is the determinant of matrix A = [[1, 2], [3, 4]]?**

A) -2
B) 2
C) -4
D) 4

**Answer: A) -2** — det = 1×4 − 2×3 = 4 − 6 = -2.

---

### Question 19
**A matrix is invertible if:**

A) Its determinant is 0
B) Its determinant is non-zero
C) It is symmetric
D) It is diagonal

**Answer: B) Its determinant is non-zero** — Non-zero determinant means invertible.

---

### Question 20
**What is the shape of the product A @ B if A is (3, 4) and B is (4, 5)?**

A) (3, 4)
B) (4, 5)
C) (3, 5)
D) (4, 4)

**Answer: C) (3, 5)** — Result shape is (rows of A, cols of B).

---

### Question 21
**Matrix addition requires that matrices have:**

A) Same number of rows
B) Same number of columns
C) Same shape
D) Same determinant

**Answer: C) Same shape** — Matrices must have identical dimensions for addition.

---

### Question 22
**A diagonal matrix has:**

A) Only non-zero diagonal elements
B) Only zero diagonal elements
C) All elements non-zero
D) All elements equal

**Answer: A) Only non-zero diagonal elements** — Off-diagonal elements are zero.

---

## Section 1.3: Decompositions — Multiple Choice Questions

### Question 23
**Eigenvalue decomposition is defined for:**

A) Any matrix
B) Square matrices
C) Symmetric matrices
D) Orthogonal matrices

**Answer: B) Square matrices** — Only square matrices have eigenvalues.

---

### Question 24
**SVD (Singular Value Decomposition) can be computed for:**

A) Only square matrices
B) Only symmetric matrices
C) Any matrix
D) Only invertible matrices

**Answer: C) Any matrix** — SVD works for any matrix, even rectangular ones.

---

### Question 25
**The singular values in SVD are:**

A) Always positive
B) Always negative
C) Non-negative
D) Complex numbers

**Answer: C) Non-negative** — Singular values are always ≥ 0.

---

### Question 26
**Principal Component Analysis (PCA) is primarily used for:**

A) Classification
B) Dimensionality reduction
C) Clustering
D) Regression

**Answer: B) Dimensionality reduction** — PCA reduces the number of features.

---

### Question 27
**In PCA, the principal components are:**

A) The left singular vectors (U)
B) The singular values (Σ)
C) The right singular vectors (V)
D) The data matrix

**Answer: C) The right singular vectors (V)** — V contains the principal components.

---

### Question 28
**The explained variance ratio tells us:**

A) How much variance each component captures
B) How many components to use
C) The accuracy of the model
D) The error of the model

**Answer: A) How much variance each component captures** — Explained variance = σ_i² / Σσ_j².

---

### Question 29
**A high singular value indicates:**

A) A component with high variance
B) A component with low variance
C) An error in the data
D) A feature with no variance

**Answer: A) A component with high variance** — Larger singular values = more important components.

---

### Question 30
**The low-rank approximation using SVD:**

A) Keeps all singular values
B) Keeps only the largest singular values
C) Keeps only the smallest singular values
D) Discards all singular values

**Answer: B) Keeps only the largest singular values** — Truncated SVD for dimensionality reduction.

---

### Question 31
**PCA requires the data to be:**

A) Centered (subtract mean)
B) Scaled to [0, 1]
C) Normalized to unit vectors
D) Sorted

**Answer: A) Centered (subtract mean)** — PCA requires zero-mean data.

---

### Question 32
**The condition number of a matrix measures:**

A) Its size
B) Its numerical stability
C) Its determinant
D) Its rank

**Answer: B) Its numerical stability** — High condition number = ill-conditioned.

---

## Section 1.4: Linear Algebra — Short Answer Questions

### Question 33
**Define a vector and give a real-world example in ML.**

**Answer:**
A vector is an ordered list of numbers. In ML, a vector represents a data point (e.g., [2000, 3, 2] for a house with sqft, bedrooms, bathrooms).

---

### Question 34
**Explain the dot product and its significance in machine learning.**

**Answer:**
The dot product is u·v = Σu_i v_i. It measures similarity between vectors. It's used in:
- Linear regression: y = w·x + b
- Neural networks: z = w·x + b
- Attention mechanisms
- Similarity metrics

---

### Question 35
**What is a matrix transpose and why is it important?**

**Answer:**
Transpose (A^T) swaps rows and columns: (A^T)_ij = A_ji. It's important for:
- Data preparation
- Computing covariance: X^T X
- Gradient computation: X^T error
- PCA projections

---

### Question 36
**Describe the relationship between SVD and PCA.**

**Answer:**
PCA uses SVD of centered data. The right singular vectors (V) are the principal components. The singular values (σ) indicate the variance explained by each component.

---

### Question 37
**What does the "rank" of a matrix tell you?**

**Answer:**
The rank is the number of linearly independent rows or columns. It indicates the intrinsic dimensionality of the data (e.g., rank 1 means all data lies on a line).

---

### Question 38
**What is the main advantage of SVD over eigenvalue decomposition?**

**Answer:**
SVD works on any matrix (not just square matrices), is numerically stable, and directly provides the principal components needed for dimensionality reduction.

---

### Question 39
**Explain the difference between L1 and L2 norms.**

**Answer:**
- L1 norm = Σ|v_i|, robust to outliers, used in Lasso
- L2 norm = √(Σv_i²), sensitive to outliers, used in Ridge

---

## Section 1.5: Linear Algebra — Coding Questions

### Question 40
**Write a function to compute the dot product of two vectors.**

**Answer:**
```python
def dot_product(u, v):
    """Compute dot product of two vectors."""
    if len(u) != len(v):
        raise ValueError("Vectors must have same length")
    return sum(u_i * v_i for u_i, v_i in zip(u, v))

# Test
u = [1, 2, 3]
v = [4, 5, 6]
print(dot_product(u, v))  # 32
```

---

### Question 41
**Write a function to standardize a vector to mean 0, std 1.**

**Answer:**
```python
def standardize(v):
    """Standardize vector to mean 0, std 1."""
    mean = sum(v) / len(v)
    variance = sum((x - mean)**2 for x in v) / len(v)
    std = variance ** 0.5
    if std == 0:
        return [0.0] * len(v)
    return [(x - mean) / std for x in v]

# Test
v = [1, 2, 3, 4, 5]
print(standardize(v))  # [-1.41, -0.707, 0, 0.707, 1.41]
```

---

### Question 42
**Implement matrix multiplication from scratch.**

**Answer:**
```python
def matrix_multiply(A, B):
    """Multiply two matrices."""
    m, n = len(A), len(A[0])
    p, q = len(B), len(B[0])
    
    if n != p:
        raise ValueError("Matrix dimensions incompatible")
    
    result = [[0] * q for _ in range(m)]
    for i in range(m):
        for j in range(q):
            total = 0
            for k in range(n):
                total += A[i][k] * B[k][j]
            result[i][j] = total
    return result

# Test
A = [[1, 2], [3, 4]]
B = [[5, 6], [7, 8]]
print(matrix_multiply(A, B))  # [[19, 22], [43, 50]]
```

---

### Question 43
**Write a function to compute the covariance matrix from data.**

**Answer:**
```python
def covariance_matrix(X):
    """Compute covariance matrix from data (samples × features)."""
    m = len(X)  # samples
    n = len(X[0])  # features
    
    # Center data
    means = [sum(X[i][j] for i in range(m)) / m for j in range(n)]
    centered = [[X[i][j] - means[j] for j in range(n)] for i in range(m)]
    
    # Compute covariance: (1/(m-1)) * X^T X
    cov = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            total = sum(centered[k][i] * centered[k][j] for k in range(m))
            cov[i][j] = total / (m - 1)
    return cov

# Test
X = [[1, 2], [2, 4], [3, 6]]
print(covariance_matrix(X))
```

---

# PART 2: CALCULUS — QUIZ AND TEST BANK

## Section 2.1: Derivatives — Multiple Choice Questions

### Question 44
**The derivative of f(x) = x³ at x = 2 is:**

A) 4
B) 8
C) 12
D) 16

**Answer: C) 12** — f'(x) = 3x², f'(2) = 3×4 = 12.

---

### Question 45
**The derivative of f(x) = e^(2x) is:**

A) e^(2x)
B) 2e^(2x)
C) e^(x)
D) 2e^(x)

**Answer: B) 2e^(2x)** — Chain rule: d/dx e^(2x) = 2e^(2x).

---

### Question 46
**The derivative of f(x) = ln(x) at x = e is:**

A) 0
B) 1/e
C) e
D) 1

**Answer: B) 1/e** — d/dx ln(x) = 1/x, at x=e, 1/e.

---

### Question 47
**A gradient is:**

A) A single number
B) A vector of partial derivatives
C) The second derivative
D) The integral

**Answer: B) A vector of partial derivatives** — ∇f = [∂f/∂x₁, ∂f/∂x₂, ...].

---

### Question 48
**The chain rule states that:**

A) d/dx(f·g) = f'g + fg'
B) d/dx(f(g(x))) = f'(g(x))·g'(x)
C) d/dx(f/g) = (f'g - fg')/g²
D) d/dx(f+g) = f' + g'

**Answer: B) d/dx(f(g(x))) = f'(g(x))·g'(x)**

---

### Question 49
**The derivative of the sigmoid function σ(x) at x = 0 is:**

A) 0
B) 0.25
C) 0.5
D) 1

**Answer: B) 0.25** — σ'(x) = σ(x)(1-σ(x)), at x=0, σ=0.5, so 0.5×0.5=0.25.

---

### Question 50
**The derivative of tanh(x) at x = 0 is:**

A) 0
B) 0.5
C) 1
D) 2

**Answer: C) 1** — tanh'(x) = 1 - tanh²(x), at x=0, tanh=0, so 1.

---

### Question 51
**The derivative of ReLU(x) at x = -5 is:**

A) 0
B) 1
C) 5
D) -5

**Answer: A) 0** — ReLU'(x) = 1 if x>0 else 0.

---

### Question 52
**In gradient descent, the gradient tells us:**

A) The value of the loss
B) The direction of steepest ascent
C) The direction to reduce loss
D) The optimal parameters

**Answer: B) The direction of steepest ascent** — Negative gradient points to steepest descent.

---

### Question 53
**The Hessian matrix contains:**

A) First derivatives
B) Second derivatives
C) Third derivatives
D) Integrals

**Answer: B) Second derivatives** — H_ij = ∂²f/∂x_i∂x_j.

---

## Section 2.2: Optimization — Multiple Choice Questions

### Question 54
**The gradient descent update rule is:**

A) w = w + α∇L(w)
B) w = w - α∇L(w)
C) w = α∇L(w)
D) w = ∇L(w)/α

**Answer: B) w = w - α∇L(w)** — Move opposite to gradient.

---

### Question 55
**If the learning rate is too large, gradient descent:**

A) Converges quickly
B) Oscillates or diverges
C) Stops immediately
D) Becomes exact

**Answer: B) Oscillates or diverges** — Large learning rates cause instability.

---

### Question 56
**Stochastic Gradient Descent (SGD) uses:**

A) All data for each update
B) One sample for each update
C) No data for updates
D) Only training data

**Answer: B) One sample for each update** — SGD uses a single sample per update.

---

### Question 57
**Mini-batch gradient descent is preferred over SGD because:**

A) It's more accurate
B) It's faster and more stable
C) It uses less memory
D) It doesn't need a learning rate

**Answer: B) It's faster and more stable** — Balances speed and stability.

---

### Question 58
**Momentum in gradient descent:**

A) Increases learning rate
B) Accelerates in consistent directions
C) Stops updates
D) Adds noise

**Answer: B) Accelerates in consistent directions** — Momentum carries velocity through flat regions.

---

### Question 59
**Adam optimizer combines:**

A) Momentum and AdaGrad
B) SGD and RMSProp
C) Momentum and RMSProp
D) Batch and SGD

**Answer: C) Momentum and RMSProp** — Adam = adaptive moment estimation.

---

### Question 60
**The purpose of gradient clipping is to:**

A) Speed up training
B) Prevent exploding gradients
C) Reduce overfitting
D) Increase accuracy

**Answer: B) Prevent exploding gradients** — Clipping limits gradient magnitude.

---

### Question 61
**Batch gradient descent's main disadvantage is:**

A) Inaccurate gradients
B) Slow for large datasets
C) No convergence guarantee
D) High variance

**Answer: B) Slow for large datasets** — Requires iterating over all data for each update.

---

### Question 62
**A learning rate schedule:**

A) Keeps learning rate constant
B) Changes learning rate over time
C) Removes learning rate
D) Sets learning rate to zero

**Answer: B) Changes learning rate over time** — Schedules adjust learning rate during training.

---

### Question 63
**In Adam, β₁ and β₂ control:**

A) Learning rate and batch size
B) Momentum and adaptive learning rate
C) Gradient and loss
D) Data and labels

**Answer: B) Momentum and adaptive learning rate** — β₁ for momentum, β₂ for variance.

---

## Section 2.3: Backpropagation — Multiple Choice Questions

### Question 64
**Backpropagation computes gradients by:**

A) Forward pass only
B) Applying the chain rule backwards
C) Random search
D) Brute force

**Answer: B) Applying the chain rule backwards** — Gradients flow from output to input.

---

### Question 65
**In backpropagation, δ^(l) represents:**

A) The loss at layer l
B) The gradient with respect to pre-activation z^(l)
C) The activation at layer l
D) The weights at layer l

**Answer: B) The gradient with respect to pre-activation z^(l)** — δ^(l) = ∂L/∂z^(l).

---

### Question 66
**The gradient with respect to weights is:**

A) ∂L/∂W^(l) = δ^(l)(a^(l-1))^T
B) ∂L/∂W^(l) = (a^(l-1))^T δ^(l)
C) ∂L/∂W^(l) = δ^(l) + a^(l-1)
D) ∂L/∂W^(l) = δ^(l) - a^(l-1)

**Answer: A) ∂L/∂W^(l) = δ^(l)(a^(l-1))^T** — This is the standard backprop formula.

---

### Question 67
**The chain rule is used in backpropagation to:**

A) Compute forward pass
B) Compute gradients through layers
C) Initialize weights
D) Update learning rate

**Answer: B) Compute gradients through layers** — Chain rule propagates gradients backward.

---

### Question 68
**In a computational graph, the forward pass:**

A) Computes gradients
B) Computes outputs
C) Updates weights
D) Initializes parameters

**Answer: B) Computes outputs** — Forward pass computes predictions from input.

---

### Question 69
**The backward pass in a computational graph:**

A) Starts from the input
B) Starts from the loss
C) Starts from the middle
D) Starts from the output

**Answer: B) Starts from the loss** — Gradients flow from loss backward.

---

### Question 70
**Automatic differentiation:**

A) Automatically computes gradients
B) Automatically creates data
C) Automatically updates weights
D) Automatically selects models

**Answer: A) Automatically computes gradients** — AutoDiff builds computational graphs.

---

### Question 71
**For a neural network with L layers, the depth is:**

A) L
B) L-1
C) L+1
D) 2L

**Answer: A) L** — Depth is the number of layers.

---

### Question 72
**The vanishing gradient problem occurs when:**

A) Gradients are too large
B) Gradients are too small
C) Gradients are zero
D) Gradients are infinite

**Answer: B) Gradients are too small** — Vanishing gradients stop learning in early layers.

---

## Section 2.4: Calculus — Short Answer Questions

### Question 73
**What is a derivative and why is it important in ML?**

**Answer:**
A derivative measures the rate of change of a function. In ML, derivatives tell us how the loss changes when we adjust weights. The gradient (vector of derivatives) tells us which direction to move to reduce loss.

---

### Question 74
**Explain the chain rule and its role in backpropagation.**

**Answer:**
The chain rule states: d/dx(f(g(x))) = f'(g(x))·g'(x). In backpropagation, it allows us to compute gradients through each layer of a neural network by multiplying local gradients.

---

### Question 75
**What is the difference between batch GD, SGD, and mini-batch GD?**

**Answer:**
- Batch GD: Uses all data for each update (accurate but slow)
- SGD: Uses one sample per update (fast but noisy)
- Mini-batch GD: Uses a small batch (balance of accuracy and speed)

---

### Question 76
**Explain the vanishing gradient problem and how to address it.**

**Answer:**
Vanishing gradients occur when gradients become very small in deep networks, preventing learning in early layers. Solutions include:
- Using ReLU activations instead of sigmoid/tanh
- Batch normalization
- Residual connections (skip connections)
- Proper weight initialization

---

### Question 77
**What is the purpose of the learning rate in gradient descent?**

**Answer:**
The learning rate controls the step size in gradient descent. Too large → overshoot/divergence. Too small → slow convergence. It balances speed and stability of training.

---

## Section 2.5: Calculus — Coding Questions

### Question 78
**Implement numerical gradient for a 1D function.**

**Answer:**
```python
def numerical_gradient_1d(f, x, h=1e-7):
    """Compute numerical gradient using central difference."""
    return (f(x + h) - f(x - h)) / (2 * h)

# Test
def square(x): return x ** 2
print(numerical_gradient_1d(square, 3))  # 6.0
```

---

### Question 79
**Implement gradient descent for a simple function.**

**Answer:**
```python
def gradient_descent(f, grad_f, initial_w, learning_rate=0.01, iterations=100):
    """Simple gradient descent."""
    w = initial_w.copy()
    history = []
    
    for i in range(iterations):
        loss = f(w)
        history.append(loss)
        gradient = grad_f(w)
        w = w - learning_rate * gradient
    
    return w, history

# Test: f(w) = w², gradient = 2w
def f(w): return w[0]**2
def grad_f(w): return [2*w[0]]

w, hist = gradient_descent(f, grad_f, [5.0], 0.1, 50)
print(f"Final weight: {w[0]:.4f}")  # ~0
```

---

### Question 80
**Implement a simple neural network layer forward and backward pass.**

**Answer:**
```python
def dense_layer_forward(X, W, b):
    """Forward pass: y = X @ W + b."""
    return X @ W + b

def dense_layer_backward(grad_output, X, W):
    """Backward pass for dense layer."""
    grad_X = grad_output @ W.T
    grad_W = X.T @ grad_output
    grad_b = grad_output.sum(axis=0)
    return grad_X, grad_W, grad_b

# Test
import numpy as np
X = np.array([[1, 2], [3, 4]])
W = np.array([[0.1, 0.2], [0.3, 0.4]])
b = np.array([0.1, 0.2])
Z = dense_layer_forward(X, W, b)
grad_out = np.array([[1, 1], [1, 1]])
grad_X, grad_W, grad_b = dense_layer_backward(grad_out, X, W)
```

---

# PART 3: PROBABILITY & STATISTICS — QUIZ AND TEST BANK

## Section 3.1: Probability Theory — Multiple Choice Questions

### Question 81
**P(A|B) = 0.3, P(B) = 0.4, P(A∩B) is:**

A) 0.12
B) 0.7
C) 0.1
D) 0.3

**Answer: A) 0.12** — P(A∩B) = P(A|B)P(B) = 0.3 × 0.4 = 0.12.

---

### Question 82
**Two events are independent if:**

A) P(A|B) = P(A)
B) P(A|B) = P(B)
C) P(A∩B) = P(A) + P(B)
D) P(A|B) = 0

**Answer: A) P(A|B) = P(A)** — Independence means B doesn't change probability of A.

---

### Question 83
**Bayes' Theorem is used to:**

A) Compute probability of data
B) Update beliefs based on evidence
C) Compute mean and variance
D) Generate random samples

**Answer: B) Update beliefs based on evidence** — P(A|B) = P(B|A)P(A)/P(B).

---

### Question 84
**The Gaussian distribution is also known as:**

A) Uniform distribution
B) Normal distribution
C) Exponential distribution
D) Binomial distribution

**Answer: B) Normal distribution** — Also called the bell curve.

---

### Question 85
**A Bernoulli distribution models:**

A) Continuous variables
B) Binary outcomes
C) Count data
D) Time between events

**Answer: B) Binary outcomes** — Bernoulli is for binary (0/1) variables.

---

### Question 86
**The mean of the binomial distribution Bin(n, p) is:**

A) np
B) np(1-p)
C) n
D) p

**Answer: A) np** — Mean = n × p.

---

### Question 87
**The variance of a Bernoulli distribution Ber(p) is:**

A) p
B) 1-p
C) p(1-p)
D) p²

**Answer: C) p(1-p)** — Variance = p(1-p).

---

### Question 88
**The probability density function (PDF) gives:**

A) The probability of a specific value
B) The relative likelihood of values
C) The cumulative probability
D) The expected value

**Answer: B) The relative likelihood of values** — PDF is a density, not a probability.

---

### Question 89
**The cumulative distribution function (CDF) gives:**

A) P(X = x)
B) P(X ≤ x)
C) P(X ≥ x)
D) E[X]

**Answer: B) P(X ≤ x)** — CDF is cumulative probability up to x.

---

### Question 90
**The expected value of a Gaussian distribution N(μ, σ²) is:**

A) σ
B) σ²
C) μ
D) μ + σ

**Answer: C) μ** — Mean of Gaussian = μ.

---

## Section 3.2: Bayesian Inference — Multiple Choice Questions

### Question 91
**In Bayesian inference, the prior represents:**

A) The probability of data
B) Initial belief before seeing data
C) The likelihood of the model
D) The evidence

**Answer: B) Initial belief before seeing data** — Prior encodes prior knowledge.

---

### Question 92
**MLE stands for:**

A) Maximum Likelihood Estimation
B) Mean Likelihood Error
C) Multiple Linear Error
D) Maximum Linear Estimation

**Answer: A) Maximum Likelihood Estimation** — Finds parameters maximizing data likelihood.

---

### Question 93
**MAP stands for:**

A) Maximum A Posteriori
B) Mean Absolute Posterior
C) Multiple A Priori
D) Maximum Average Probability

**Answer: A) Maximum A Posteriori** — MAP = MLE × Prior.

---

### Question 94
**MLE is equivalent to MAP when:**

A) Prior is uniform
B) Prior is Gaussian
C) Prior is 0
D) Prior is 1

**Answer: A) Prior is uniform** — Uniform prior gives no preference.

---

### Question 95
**The likelihood in Bayes' Theorem is:**

A) P(A|B)
B) P(B|A)
C) P(A)
D) P(B)

**Answer: B) P(B|A)** — Likelihood = P(data|parameters).

---

### Question 96
**The evidence term in Bayes' Theorem is:**

A) P(A|B)
B) P(B|A)
C) P(A)
D) P(B)

**Answer: D) P(B)** — Evidence normalizes the posterior.

---

### Question 97
**Naive Bayes assumes:**

A) Features are dependent
B) Features are independent given class
C) Features are Gaussian
D) Classes are independent

**Answer: B) Features are independent given class** — This is the "naive" assumption.

---

### Question 98
**Gaussian Naive Bayes assumes features are:**

A) Bernoulli
B) Gaussian
C) Poisson
D) Exponential

**Answer: B) Gaussian** — Continuous features modeled with Gaussian distribution.

---

### Question 99
**The bias-variance tradeoff states:**

A) Higher bias = higher variance
B) Lower bias = higher variance
C) Bias and variance are independent
D) Bias + variance = constant

**Answer: B) Lower bias = higher variance** — Simple models have high bias, low variance; complex models have low bias, high variance.

---

### Question 100
**Overfitting is characterized by:**

A) Low bias, low variance
B) Low bias, high variance
C) High bias, low variance
D) High bias, high variance

**Answer: B) Low bias, high variance** — Model fits training data well but generalizes poorly.

---

## Section 3.3: Model Evaluation — Multiple Choice Questions

### Question 101
**The F1 score is the harmonic mean of:**

A) Accuracy and precision
B) Precision and recall
C) Recall and accuracy
D) MSE and MAE

**Answer: B) Precision and recall** — F1 = 2PR/(P+R).

---

### Question 102
**R² score of 1.0 means:**

A) Perfect fit
B) No relationship
C) Negative relationship
D) Random predictions

**Answer: A) Perfect fit** — R² = 1 means all variance explained.

---

### Question 103
**RMSE stands for:**

A) Root Mean Squared Error
B) Random Mean Squared Error
C) Regression Mean Squared Error
D) Residual Mean Squared Error

**Answer: A) Root Mean Squared Error** — RMSE = √MSE.

---

### Question 104
**Cross-validation helps to:**

A) Reduce training time
B) Estimate model performance on unseen data
C) Increase training data
D) Simplify the model

**Answer: B) Estimate model performance on unseen data** — Validates generalization.

---

### Question 105
**In k-fold cross-validation, k=5 means:**

A) 5% of data for training
B) 5% of data for testing
C) 5 folds, each used for testing once
D) 5 total samples

**Answer: C) 5 folds, each used for testing once** — Each fold gets one test turn.

---

### Question 106
**AIC and BIC are used for:**

A) Model selection
B) Data preprocessing
C) Feature engineering
D) Hyperparameter tuning

**Answer: A) Model selection** — AIC/BIC compare models with different complexities.

---

### Question 107
**AIC penalizes complexity with:**

A) 2 × number of parameters
B) k × log(n)
C) Number of parameters
D) log(number of parameters)

**Answer: A) 2 × number of parameters** — AIC = -2LL + 2k.

---

### Question 108
**BIC penalizes complexity with:**

A) 2 × number of parameters
B) k × log(n)
C) Number of parameters
D) log(number of parameters)

**Answer: B) k × log(n)** — BIC = -2LL + k×log(n).

---

### Question 109
**The confusion matrix shows:**

A) TP, FP, FN, TN
B) Precision, recall, F1
C) MSE, RMSE, R²
D) Mean, variance, std

**Answer: A) TP, FP, FN, TN** — True Positive, False Positive, False Negative, True Negative.

---

### Question 110
**Specificity is also known as:**

A) True Positive Rate
B) True Negative Rate
C) False Positive Rate
D) Precision

**Answer: B) True Negative Rate** — Specificity = TN/(TN+FP).

---

## Section 3.4: Probability — Short Answer Questions

### Question 111
**State Bayes' Theorem and explain each term.**

**Answer:**
P(A|B) = P(B|A)P(A)/P(B)
- P(A|B): Posterior — probability of A given B
- P(B|A): Likelihood — probability of B given A
- P(A): Prior — initial probability of A
- P(B): Evidence — total probability of B

---

### Question 112
**Explain the bias-variance tradeoff with an example.**

**Answer:**
- Bias: Error from over-simplification (underfitting)
- Variance: Error from over-sensitivity (overfitting)
Example: Linear regression on a nonlinear problem → high bias. High-degree polynomial → high variance.

---

### Question 113
**What is the difference between MLE and MAP?**

**Answer:**
- MLE: θ̂ = argmax_θ P(data|θ) (no prior)
- MAP: θ̂ = argmax_θ P(θ|data) = argmax_θ P(data|θ)P(θ) (includes prior)
MAP is MLE with a prior.

---

### Question 114
**Explain cross-validation and why it's important.**

**Answer:**
Cross-validation splits data into k folds, trains on k-1 folds, validates on the held-out fold, and repeats. It gives a reliable estimate of model performance on unseen data.

---

### Question 115
**What is the difference between precision and recall?**

**Answer:**
Precision = TP/(TP+FP) — "Of predicted positives, how many are correct?"
Recall = TP/(TP+FN) — "Of actual positives, how many did we find?"

---

## Section 3.5: Probability — Coding Questions

### Question 116
**Implement Gaussian Naive Bayes from scratch.**

**Answer:**
```python
class GaussianNaiveBayes:
    def fit(self, X, y):
        """Train Naive Bayes classifier."""
        self.classes = list(set(y))
        self.priors = {}
        self.means = {}
        self.stds = {}
        
        for c in self.classes:
            X_c = [X[i] for i in range(len(X)) if y[i] == c]
            self.priors[c] = len(X_c) / len(X)
            self.means[c] = [sum(row[j] for row in X_c) / len(X_c) 
                            for j in range(len(X_c[0]))]
            self.stds[c] = [((sum((row[j] - self.means[c][j])**2 
                           for row in X_c) / len(X_c)) ** 0.5 + 1e-6)
                           for j in range(len(X_c[0]))]
    
    def predict(self, X):
        """Predict classes for new data."""
        import math
        predictions = []
        for row in X:
            probs = []
            for c in self.classes:
                log_prob = math.log(self.priors[c])
                for j in range(len(row)):
                    z = (row[j] - self.means[c][j]) / self.stds[c][j]
                    log_prob += -0.5 * z**2 - 0.5 * math.log(2*math.pi) - math.log(self.stds[c][j])
                probs.append(log_prob)
            predictions.append(self.classes[probs.index(max(probs))])
        return predictions
```

---

### Question 117
**Implement MLE for Gaussian distribution parameters.**

**Answer:**
```python
def mle_gaussian(data):
    """MLE for Gaussian distribution: return mean and variance."""
    n = len(data)
    mean = sum(data) / n
    variance = sum((x - mean)**2 for x in data) / n
    return mean, variance

# Test
data = [1, 2, 3, 4, 5]
mu, var = mle_gaussian(data)
print(f"Mean: {mu}, Variance: {var}")
```

---

### Question 118
**Compute confusion matrix and derive precision/recall.**

**Answer:**
```python
def confusion_matrix(y_true, y_pred):
    """Compute confusion matrix: TP, FP, FN, TN."""
    tp = fp = fn = tn = 0
    for t, p in zip(y_true, y_pred):
        if t == 1 and p == 1: tp += 1
        elif t == 0 and p == 1: fp += 1
        elif t == 1 and p == 0: fn += 1
        else: tn += 1
    return tp, fp, fn, tn

def precision(tp, fp): return tp / (tp + fp) if (tp + fp) > 0 else 0
def recall(tp, fn): return tp / (tp + fn) if (tp + fn) > 0 else 0

y_true = [1, 0, 1, 1, 0, 0, 1]
y_pred = [1, 0, 1, 0, 1, 0, 1]
tp, fp, fn, tn = confusion_matrix(y_true, y_pred)
print(f"Precision: {precision(tp, fp):.2f}")  # 0.75
print(f"Recall: {recall(tp, fn):.2f}")        # 0.75
```

---

# PART 4: APPLIED NUMERICAL METHODS — QUIZ AND TEST BANK

## Section 4.1: Numerical Stability — Multiple Choice Questions

### Question 119
**The log-sum-exp trick prevents:**

A) Underflow
B) Overflow
C) Both underflow and overflow
D) Neither

**Answer: C) Both underflow and overflow** — Shifts values to prevent extremes.

---

### Question 120
**Gradient clipping prevents:**

A) Underfitting
B) Overfitting
C) Exploding gradients
D) Vanishing gradients

**Answer: C) Exploding gradients** — Clipping limits gradient magnitude.

---

### Question 121
**Catastrophic cancellation occurs when:**

A) Adding large and small numbers
B) Subtracting nearly equal numbers
C) Multiplying large numbers
D) Dividing by zero

**Answer: B) Subtracting nearly equal numbers** — Results in loss of precision.

---

### Question 122
**The condition number of a matrix indicates:**

A) Its size
B) Its numerical stability
C) Its determinant
D) Its rank

**Answer: B) Its numerical stability** — High condition number = unstable.

---

### Question 123
**A matrix with condition number 1 is:**

A) Singular
B) Perfectly conditioned
C) Ill-conditioned
D) Undefined

**Answer: B) Perfectly conditioned** — Condition number 1 means optimal stability.

---

### Question 124
**Numerical underflow occurs when:**

A) A value is too large to represent
B) A value is too small to represent
C) A value is negative
D) A value is complex

**Answer: B) A value is too small to represent** — Underflow rounds to zero.

---

### Question 125
**Numerical overflow occurs when:**

A) A value is too large to represent
B) A value is too small to represent
C) A value is negative
D) A value is complex

**Answer: A) A value is too large to represent** — Overflow becomes Inf.

---

### Question 126
**The stable softmax uses:**

A) exp(x - max(x))
B) exp(x + max(x))
C) exp(x / max(x))
D) exp(x * max(x))

**Answer: A) exp(x - max(x))** — Subtracting max prevents overflow.

---

### Question 127
**SVD is preferred over eigendecomposition because:**

A) It's faster
B) It's more stable
C) It works on any matrix
D) Both B and C

**Answer: D) Both B and C** — SVD is more stable and more general.

---

### Question 128
**A pseudo-inverse is used when:**

A) Matrix is invertible
B) Matrix is singular
C) Matrix is symmetric
D) Matrix is diagonal

**Answer: B) Matrix is singular** — Pseudo-inverse handles non-invertible matrices.

---

## Section 4.2: Performance Optimization — Multiple Choice Questions

### Question 129
**Vectorization in NumPy:**

A) Replaces loops with array operations
B) Uses Python loops for speed
C) Slows down computation
D) Uses more memory

**Answer: A) Replaces loops with array operations** — Vectorized operations are faster.

---

### Question 130
**A view in NumPy:**

A) Copies data
B) References data
C) Both copies and references
D) Neither

**Answer: B) References data** — Views share data with original array.

---

### Question 131
**Batch processing is used to:**

A) Increase accuracy
B) Reduce memory usage
C) Increase complexity
D) Reduce speed

**Answer: B) Reduce memory usage** — Processing in batches manages memory.

---

### Question 132
**When using NumPy, which is faster?**

A) Python for loops
B) Vectorized operations
C) Both are equal
D) Depends on the data

**Answer: B) Vectorized operations** — NumPy vectorized operations are much faster.

---

### Question 133
**Caching results is useful for:**

A) Expensive repeated computations
B) Simple computations
C) All computations
D) None

**Answer: A) Expensive repeated computations** — Caching avoids recomputation.

---

### Question 134
**The pseudo-inverse is computed using:**

A) Eigendecomposition
B) SVD
C) LU decomposition
D) QR decomposition

**Answer: B) SVD** — Pseudo-inverse = V Σ^+ U^T.

---

### Question 135
**Early stopping helps prevent:**

A) Underfitting
B) Overfitting
C) Exploding gradients
D) Vanishing gradients

**Answer: B) Overfitting** — Stops training when validation performance degrades.

---

### Question 136
**Regularization (L2) helps prevent:**

A) Underfitting
B) Overfitting
C) Exploding gradients
D) Vanishing gradients

**Answer: B) Overfitting** — Regularization penalizes large weights.

---

### Question 137
**A good rule of thumb for learning rate is:**

A) Always 0.01
B) Start at 0.001 and adjust
C) Always 0.1
D) Randomly choose

**Answer: B) Start at 0.001 and adjust** — Common starting point for Adam.

---

## Section 4.3: Numerical Methods — Short Answer Questions

### Question 138
**Explain the log-sum-exp trick and why it's important.**

**Answer:**
The log-sum-exp trick computes log(Σ exp(v_i)) as max(v) + log(Σ exp(v_i - max(v))). It prevents overflow/underflow by shifting values so they're in a safe numerical range. Used in softmax, log-likelihood, and cross-entropy.

---

### Question 139
**What is gradient clipping and when should it be used?**

**Answer:**
Gradient clipping limits gradient magnitude: g = g·min(1, threshold/||g||). Used to prevent exploding gradients in deep networks, especially RNNs and transformers.

---

### Question 140
**Explain why SVD is more stable than matrix inversion.**

**Answer:**
SVD handles singular matrices gracefully by allowing pseudo-inverse. Matrix inversion fails when determinant approaches zero. SVD's singular values tell us about stability.

---

### Question 141
**What is the difference between a view and a copy in NumPy?**

**Answer:**
A view shares data with the original array (changes affect original). A copy creates a new array (changes don't affect original). Views are faster but can cause unexpected side effects.

---

### Question 142
**Why is numerical stability important in production ML?**

**Answer:**
Production models must handle real-world data with varying scales and extreme values. Unstable code can produce NaN, Inf, or incorrect results, causing system failures and poor predictions.

---

## Section 4.4: Numerical Methods — Coding Questions

### Question 143
**Implement stable softmax using log-sum-exp trick.**

**Answer:**
```python
def stable_softmax(x):
    """Stable softmax using log-sum-exp trick."""
    import math
    
    max_val = max(x)
    exp_vals = [math.exp(v - max_val) for v in x]
    sum_exp = sum(exp_vals)
    return [e / sum_exp for e in exp_vals]

# Test
x = [100, 101, 102]
soft = stable_softmax(x)
print(sum(soft))  # 1.0
```

---

### Question 144
**Implement gradient clipping by norm.**

**Answer:**
```python
def clip_gradient(grad, max_norm):
    """Clip gradient to maximum L2 norm."""
    import math
    
    norm = math.sqrt(sum(g**2 for g in grad))
    if norm > max_norm:
        scale = max_norm / norm
        return [g * scale for g in grad]
    return grad

# Test
grad = [100, 100, 100]
clipped = clip_gradient(grad, 1.0)
print(sum(g**2 for g in clipped) ** 0.5)  # 1.0
```

---

### Question 145
**Compute the condition number of a 2x2 matrix.**

**Answer:**
```python
def condition_number_2x2(A):
    """Compute condition number for 2x2 matrix."""
    # Compute singular values using SVD formula for 2x2
    import math
    
    a, b = A[0]
    c, d = A[1]
    
    # Compute A^T A
    e = a*a + c*c
    f = a*b + c*d
    g = b*b + d*d
    
    # Eigenvalues of A^T A
    trace = e + g
    det = e*g - f*f
    lambda1 = (trace + math.sqrt(trace*trace - 4*det)) / 2
    lambda2 = (trace - math.sqrt(trace*trace - 4*det)) / 2
    
    # Singular values
    s1 = math.sqrt(max(lambda1, lambda2))
    s2 = math.sqrt(min(lambda1, lambda2))
    
    return s1 / s2 if s2 > 0 else float('inf')

# Test
A = [[1, 0], [0, 1]]
print(condition_number_2x2(A))  # 1.0
```

---

# PART 5: COMPREHENSIVE FINAL EXAM

## Section 5.1: Mixed Topics — Multiple Choice

### Question 146
**Which algorithm is used for dimensionality reduction?**

A) Linear Regression
B) PCA
C) Logistic Regression
D) SVM

**Answer: B) PCA** — Principal Component Analysis reduces dimensions.

---

### Question 147
**Gradient descent is used to:**

A) Reduce dimensionality
B) Optimize parameters
C) Split data
D) Evaluate models

**Answer: B) Optimize parameters** — Gradient descent finds optimal weights.

---

### Question 148
**Softmax converts logits to:**

A) Binary labels
B) Probabilities
C) Features
D) Gradients

**Answer: B) Probabilities** — Softmax outputs probability distribution.

---

### Question 149
**ReLU stands for:**

A) Rectified Linear Unit
B) Recursive Linear Unit
C) Regularized Linear Unit
D) Reduced Linear Unit

**Answer: A) Rectified Linear Unit** — ReLU = max(0, x).

---

### Question 150
**The sigmoid function outputs values between:**

A) -1 and 1
B) 0 and 1
C) -∞ and ∞
D) 0 and ∞

**Answer: B) 0 and 1** — Sigmoid squashes to [0, 1].

---

## Section 5.2: Mixed Topics — Short Answer

### Question 151
**Explain how a neural network learns, from input to weight update.**

**Answer:**
1. Forward pass: Input → hidden layers → output (predictions)
2. Compute loss: Compare predictions to targets
3. Backward pass: Use chain rule to compute gradients
4. Weight update: w = w - α∇L(w)
5. Repeat steps 1-4 until convergence

---

### Question 152
**Compare and contrast linear regression and logistic regression.**

**Answer:**
- Linear: Predicts continuous values, uses MSE loss, closed-form solution
- Logistic: Predicts binary classification, uses cross-entropy loss, uses sigmoid activation
Both are linear models but with different outputs and loss functions.

---

### Question 153
**What are the main challenges in deploying ML models to production?**

**Answer:**
- Performance: Latency, throughput requirements
- Reliability: Error handling, numerical stability
- Monitoring: Drift detection, performance degradation
- Scalability: Handling increasing load
- Maintenance: Regular retraining, versioning
- Security: Data privacy, model protection

---

### Question 154
**Explain the relationship between eigenvalues, eigenvectors, SVD, and PCA.**

**Answer:**
Eigenvalues/eigenvectors apply to square matrices, revealing directions of stretching. SVD generalizes this to any matrix: A = UΣV^T. PCA uses SVD on centered data: the right singular vectors (V) are principal components, and singular values squared (σ²) give explained variance.

---

### Question 155
**What is the connection between numerical stability and production ML?**

**Answer:**
Production models handle real-world data with extreme values and edge cases. Numerical instability causes NaN, Inf, and incorrect predictions, leading to system failures. Stable implementations (safe exp/log, stable softmax, gradient clipping) ensure reliable operation.

---

### Question 156
**What is regularization and why is it important?**

**Answer:**
Regularization adds a penalty term to the loss function (e.g., L2: λ||w||²). It prevents overfitting by discouraging large weights. It's essential for:
- Model generalization
- Handling multicollinearity
- Improving numerical stability

---

## Section 5.3: Comprehensive Coding — Final Questions

### Question 157
**Implement a complete logistic regression model from scratch.**

**Answer:**
```python
import math
import numpy as np

class LogisticRegressionFromScratch:
    def __init__(self, learning_rate=0.01, epochs=1000):
        self.lr = learning_rate
        self.epochs = epochs
        self.weights = None
        self.bias = None
    
    def _sigmoid(self, z):
        """Sigmoid activation."""
        z = np.clip(z, -500, 500)  # Numerical stability
        return 1 / (1 + np.exp(-z))
    
    def fit(self, X, y):
        """Train logistic regression."""
        n_samples, n_features = X.shape
        self.weights = np.zeros(n_features)
        self.bias = 0
        
        for _ in range(self.epochs):
            # Linear model
            linear_model = np.dot(X, self.weights) + self.bias
            
            # Predictions
            predictions = self._sigmoid(linear_model)
            
            # Compute gradients
            dw = (1/n_samples) * np.dot(X.T, (predictions - y))
            db = (1/n_samples) * np.sum(predictions - y)
            
            # Update parameters
            self.weights -= self.lr * dw
            self.bias -= self.lr * db
    
    def predict_proba(self, X):
        """Get probability predictions."""
        linear_model = np.dot(X, self.weights) + self.bias
        return self._sigmoid(linear_model)
    
    def predict(self, X, threshold=0.5):
        """Get binary predictions."""
        probabilities = self.predict_proba(X)
        return (probabilities >= threshold).astype(int)
    
    def score(self, X, y):
        """Calculate accuracy."""
        predictions = self.predict(X)
        return np.mean(predictions == y)

# Test
X = np.random.randn(100, 2)
y = (X[:, 0] + X[:, 1] > 0).astype(int)
model = LogisticRegressionFromScratch(learning_rate=0.1, epochs=1000)
model.fit(X, y)
print(f"Accuracy: {model.score(X, y):.4f}")
```

---

### Question 158
**Implement PCA from scratch using SVD.**

**Answer:**
```python
def pca_from_scratch(X, n_components):
    """
    PCA implementation using SVD.
    
    Args:
        X: Data matrix (samples × features)
        n_components: Number of principal components to keep
    """
    # 1. Center the data
    mean = np.mean(X, axis=0)
    X_centered = X - mean
    
    # 2. Compute SVD
    U, S, Vt = np.linalg.svd(X_centered, full_matrices=False)
    
    # 3. Components are right singular vectors (V)
    components = Vt[:n_components]
    
    # 4. Project the data
    projected = X_centered @ components.T
    
    # 5. Compute explained variance
    total_variance = np.sum(S**2)
    explained_variance = S[:n_components]**2 / total_variance
    
    return projected, components, explained_variance

# Test
X = np.random.randn(100, 5)
proj, comps, exp_var = pca_from_scratch(X, 2)
print(f"Projected shape: {proj.shape}")
print(f"Explained variance: {exp_var}")
```

---

### Question 159
**Implement batch gradient descent for linear regression.**

**Answer:**
```python
def linear_regression_gd(X, y, learning_rate=0.01, epochs=100):
    """
    Linear regression using batch gradient descent.
    
    Returns:
        weights: Optimal weights
        bias: Optimal bias
        history: Loss history
    """
    n_samples, n_features = X.shape
    weights = np.zeros(n_features)
    bias = 0
    history = []
    
    for epoch in range(epochs):
        # Forward pass
        predictions = X @ weights + bias
        
        # Compute loss (MSE)
        loss = np.mean((predictions - y)**2)
        history.append(loss)
        
        # Compute gradients
        dw = (2/n_samples) * X.T @ (predictions - y)
        db = (2/n_samples) * np.sum(predictions - y)
        
        # Update
        weights -= learning_rate * dw
        bias -= learning_rate * db
        
        if epoch % 10 == 0:
            print(f"Epoch {epoch}: Loss = {loss:.6f}")
    
    return weights, bias, history

# Test with synthetic data
X = np.random.randn(100, 3)
true_w = np.array([2, -1, 3])
y = X @ true_w + np.random.randn(100) * 0.1

w, b, hist = linear_regression_gd(X, y, learning_rate=0.01, epochs=100)
print(f"Weights: {w}")
print(f"True weights: {true_w}")
```

---

### Question 160
**Implement cross-validation for model evaluation.**

**Answer:**
```python
def cross_validate(model, X, y, k=5, random_seed=42):
    """
    Perform k-fold cross-validation.
    
    Args:
        model: ML model with fit() and score() methods
        X: Features
        y: Labels
        k: Number of folds
        
    Returns:
        scores: List of scores for each fold
    """
    n_samples = X.shape[0]
    indices = np.arange(n_samples)
    
    # Shuffle
    np.random.seed(random_seed)
    np.random.shuffle(indices)
    
    fold_size = n_samples // k
    scores = []
    
    for fold in range(k):
        # Split
        test_start = fold * fold_size
        test_end = (fold + 1) * fold_size if fold < k-1 else n_samples
        
        test_indices = indices[test_start:test_end]
        train_indices = np.concatenate([indices[:test_start], indices[test_end:]])
        
        # Create train/test sets
        X_train = X[train_indices]
        y_train = y[train_indices]
        X_test = X[test_indices]
        y_test = y[test_indices]
        
        # Train and evaluate
        model_copy = model.__class__(**model.__dict__)
        model_copy.fit(X_train, y_train)
        score = model_copy.score(X_test, y_test)
        scores.append(score)
    
    return scores

# Test
from sklearn.linear_model import LogisticRegression
X = np.random.randn(200, 5)
y = (X[:, 0] + X[:, 1] > 0).astype(int)
model = LogisticRegression()
scores = cross_validate(model, X, y, k=5)
print(f"Scores: {scores}")
print(f"Mean: {np.mean(scores):.4f}, Std: {np.std(scores):.4f}")
```

---

# ANSWER KEY SUMMARY

## Part 1: Linear Algebra
| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 1 | B | 9 | C | 17 | A | 25 | C |
| 2 | B | 10 | B | 18 | A | 26 | B |
| 3 | C | 11 | C | 19 | B | 27 | C |
| 4 | B | 12 | A | 20 | C | 28 | A |
| 5 | B | 13 | D | 21 | C | 29 | A |
| 6 | C | 14 | A | 22 | A | 30 | B |
| 7 | C | 15 | B | 23 | B | 31 | A |
| 8 | A | 16 | C | 24 | C | 32 | B |

## Part 2: Calculus
| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 44 | C | 53 | B | 62 | B | 71 | A |
| 45 | B | 54 | B | 63 | B | 72 | B |
| 46 | B | 55 | B | 64 | B | | |
| 47 | B | 56 | B | 65 | B | | |
| 48 | B | 57 | B | 66 | A | | |
| 49 | B | 58 | B | 67 | B | | |
| 50 | C | 59 | C | 68 | B | | |
| 51 | A | 60 | B | 69 | B | | |
| 52 | B | 61 | B | 70 | A | | |

## Part 3: Probability
| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 81 | A | 91 | B | 101 | B | 111 | See |
| 82 | A | 92 | A | 102 | A | 112 | See |
| 83 | B | 93 | A | 103 | A | 113 | See |
| 84 | B | 94 | A | 104 | B | 114 | See |
| 85 | B | 95 | B | 105 | C | 115 | See |
| 86 | A | 96 | D | 106 | A | | |
| 87 | C | 97 | B | 107 | A | | |
| 88 | B | 98 | B | 108 | B | | |
| 89 | B | 99 | B | 109 | A | | |
| 90 | C | 100 | B | 110 | B | | |

## Part 4: Numerical Methods
| Q# | Answer | Q# | Answer | Q# | Answer | Q# | Answer |
|----|--------|----|--------|----|--------|----|--------|
| 119 | C | 124 | B | 129 | A | 134 | B |
| 120 | C | 125 | A | 130 | B | 135 | B |
| 121 | B | 126 | A | 131 | B | 136 | B |
| 122 | B | 127 | D | 132 | B | 137 | B |
| 123 | B | 128 | B | 133 | A | | |

## Part 5: Final Exam
| Q# | Answer | Q# | Answer |
|----|--------|----|--------|
| 146 | B | 151 | See |
| 147 | B | 152 | See |
| 148 | B | 153 | See |
| 149 | A | 154 | See |
| 150 | B | 155 | See |
| | | 156 | See |

---

**[END OF QUIZ AND TEST BANK]**
