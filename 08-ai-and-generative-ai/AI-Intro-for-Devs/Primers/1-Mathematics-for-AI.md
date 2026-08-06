# AI Tutorial Series: Developer Edition
# Primer 1: Mathematics for AI

**A gentle introduction to the mathematics you need to understand AI—from linear algebra to probability—without getting lost in theory.**

---

## Table of Contents

1. [Introduction](#introduction)
2. [Linear Algebra](#linear-algebra)
3. [Calculus](#calculus)
4. [Probability & Statistics](#probability--statistics)
5. [Information Theory](#information-theory)
6. [Optimization](#optimization)
7. [Practical Applications](#practical-applications)
8. [Quick Reference](#quick-reference)

---

## Introduction

### Why Math Matters for AI

You don't need to be a mathematician to build AI applications, but understanding the core concepts helps you:

- **Understand what models are doing** — Not just magic, but math
- **Debug issues** — Recognize when something is off
- **Choose the right approach** — Understand tradeoffs
- **Read research papers** — Stay current with the field
- **Build better systems** — Make informed engineering decisions

### What You Actually Need

| Topic | Do You Need It? | How Much? |
|-------|-----------------|-----------|
| **Linear Algebra** | ✅ Essential | Vectors, matrices, dot products |
| **Calculus** | ✅ Essential | Derivatives, gradients |
| **Probability** | ✅ Essential | Distributions, Bayes' theorem |
| **Statistics** | ✅ Essential | Mean, variance, correlations |
| **Information Theory** | 🟡 Helpful | Entropy, KL divergence |
| **Optimization** | 🟡 Helpful | Gradient descent |

---

## Linear Algebra

### Vectors: The Building Blocks

A **vector** is a list of numbers that represents something in space.

```python
# A vector in Python
vector = [0.1, 0.5, 0.8, -0.2, 0.3]

# In NumPy
import numpy as np
v = np.array([0.1, 0.5, 0.8, -0.2, 0.3])
```

#### Vector Operations

**1. Addition** — Add element-wise
```
[1, 2, 3] + [4, 5, 6] = [5, 7, 9]
```

**2. Scalar Multiplication** — Multiply every element
```
2 × [1, 2, 3] = [2, 4, 6]
```

**3. Dot Product** — Sum of element-wise products
```
[1, 2, 3] · [4, 5, 6] = 1×4 + 2×5 + 3×6 = 32
```

```python
# Dot product in Python
def dot_product(a, b):
    return sum(x * y for x, y in zip(a, b))

# Or using NumPy
import numpy as np
dot = np.dot(v1, v2)
```

**4. Norm (Length)** — How long the vector is
```
||v|| = sqrt(v₁² + v₂² + ... + vₙ²)
```

```python
# Euclidean norm
def norm(v):
    return np.sqrt(sum(x**2 for x in v))

# Using NumPy
norm = np.linalg.norm(v)
```

#### Why Vectors Matter in AI

| Concept | Vector Interpretation |
|---------|----------------------|
| **Embeddings** | Words/images represented as vectors |
| **Features** | Data points as vectors |
| **Weights** | Model parameters as vectors |
| **Gradients** | Direction of steepest ascent/descent |
| **Representations** | Learned features as vectors |

---

### Matrices: Tables of Numbers

A **matrix** is a grid of numbers with rows and columns.

```python
# A matrix in Python (list of lists)
matrix = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
]

# In NumPy
import numpy as np
M = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
```

#### Matrix Operations

**1. Addition** — Add element-wise
```
[1 2]   [5 6]   [6 8]
[3 4] + [7 8] = [10 12]
```

**2. Multiplication** — Row × Column
```
[1 2]   [5 6]   [1×5+2×7  1×6+2×8]   [19 22]
[3 4] × [7 8] = [3×5+4×7  3×6+4×8] = [43 50]
```

```python
# Matrix multiplication
import numpy as np
A = np.array([[1, 2], [3, 4]])
B = np.array([[5, 6], [7, 8]])
C = np.dot(A, B)
# Or using @ operator
C = A @ B
```

**3. Transpose** — Swap rows and columns
```
[1 2 3]ᵀ   [1 4]
[4 5 6]  = [2 5]
           [3 6]
```

```python
M_transpose = M.T
```

#### Why Matrices Matter in AI

| Concept | Matrix Interpretation |
|---------|----------------------|
| **Neural Networks** | Layers are matrix multiplications |
| **Transformers** | Attention is matrix multiplication |
| **Embeddings** | Matrix of all embeddings |
| **Covariance** | Relationships between features |
| **Linear Transformations** | Project input to output |

---

### Eigenvalues & Eigenvectors

**Eigenvectors** are special vectors that don't change direction when transformed by a matrix—they just get scaled.

```
A × v = λ × v

Where:
- A is a matrix
- v is an eigenvector
- λ is the eigenvalue (the scaling factor)
```

#### Why They Matter

- **Principal Component Analysis (PCA)** — Dimensionality reduction
- **Singular Value Decomposition (SVD)** — Matrix factorization
- **Stability** — Understanding system dynamics
- **Attention** — Finding important directions

---

## Calculus

### Derivatives: Rates of Change

A **derivative** measures how fast something changes.

```
f'(x) = lim[h→0] (f(x+h) - f(x)) / h
```

#### Common Derivatives

| Function | Derivative |
|----------|------------|
| f(x) = c (constant) | f'(x) = 0 |
| f(x) = xⁿ | f'(x) = n·xⁿ⁻¹ |
| f(x) = eˣ | f'(x) = eˣ |
| f(x) = ln(x) | f'(x) = 1/x |
| f(x) = sin(x) | f'(x) = cos(x) |
| f(x) = cos(x) | f'(x) = -sin(x) |

```python
# Numerical derivative
def derivative(f, x, h=1e-7):
    return (f(x + h) - f(x - h)) / (2 * h)

# Example
def square(x):
    return x ** 2

derivative(square, 3)  # ≈ 6
```

#### Why Derivatives Matter in AI

| Concept | Application |
|---------|-------------|
| **Gradient Descent** | Minimizing loss function |
| **Backpropagation** | Training neural networks |
| **Learning Rate** | How fast to update weights |
| **Optimization** | Finding best parameters |

---

### Gradients: Multidimensional Derivatives

A **gradient** is a vector of partial derivatives. It points in the direction of steepest ascent.

```
∇f = [∂f/∂x₁, ∂f/∂x₂, ..., ∂f/∂xₙ]
```

```python
# Numerical gradient
def gradient(f, x, h=1e-7):
    grad = np.zeros_like(x)
    for i in range(len(x)):
        x_plus = x.copy()
        x_plus[i] += h
        x_minus = x.copy()
        x_minus[i] -= h
        grad[i] = (f(x_plus) - f(x_minus)) / (2 * h)
    return grad
```

#### Why Gradients Matter

- **Training** — Updating model weights
- **Optimization** — Finding minima/maxima
- **Backpropagation** — Gradient computation in neural networks

---

### Chain Rule

The **chain rule** tells us how to differentiate composite functions.

```
(f(g(x)))' = f'(g(x)) × g'(x)
```

#### Why It Matters

- **Backpropagation** — Chain rule applied to neural networks
- **Composite Functions** — Most ML functions are compositions
- **Deep Learning** — Layers are compositions of functions

---

## Probability & Statistics

### Basic Probability

**Probability** measures how likely something is to happen.

```
P(Event) = 1 (certain) to 0 (impossible)
```

#### Key Concepts

**1. Conditional Probability** — P(A|B) = Probability of A given B

**2. Independence** — P(A and B) = P(A) × P(B)

**3. Bayes' Theorem**
```
P(A|B) = P(B|A) × P(A) / P(B)
```

#### Why Probability Matters

| Concept | Application |
|---------|-------------|
| **Next-Token Prediction** | Probability distribution over tokens |
| **Confidence** | Model's confidence in its answer |
| **Uncertainty** | When the model is unsure |
| **Sampling** | Temperature, Top-K, Top-P |

---

### Probability Distributions

#### Normal (Gaussian) Distribution

```
f(x) = (1/(σ√(2π))) × e^(-(x-μ)²/(2σ²))
```

```python
# Normal distribution
import numpy as np
from scipy.stats import norm

# Parameters
mu = 0       # Mean
sigma = 1    # Standard deviation

# Probability density function
x = np.linspace(-4, 4, 100)
pdf = norm.pdf(x, mu, sigma)
```

**Why it matters:** Many natural phenomena follow a normal distribution.

---

### Statistics

#### Mean (Average)

```
μ = (1/n) × Σ xᵢ
```

#### Variance & Standard Deviation

```
Variance = (1/n) × Σ (xᵢ - μ)²
Standard Deviation = √Variance
```

```python
import numpy as np
data = [1, 2, 3, 4, 5]
mean = np.mean(data)       # 3.0
variance = np.var(data)    # 2.0
std = np.std(data)         # 1.41
```

#### Correlation

Measures how strongly two variables are related.

```
Correlation ranges from -1 (perfect negative) to +1 (perfect positive)
```

```python
# Pearson correlation
import numpy as np
x = [1, 2, 3, 4, 5]
y = [2, 4, 6, 8, 10]
correlation = np.corrcoef(x, y)[0, 1]  # 1.0
```

---

## Information Theory

### Entropy

**Entropy** measures uncertainty or information content.

```
H(X) = -Σ P(x) × log₂(P(x))
```

```python
import numpy as np
def entropy(probs):
    return -sum(p * np.log2(p) for p in probs if p > 0)

# Example: Fair coin
probs = [0.5, 0.5]
entropy(probs)  # 1.0 bit
```

#### Why Entropy Matters

| Concept | Application |
|---------|-------------|
| **Cross-Entropy Loss** | Training classification models |
| **Information** | How surprising is an event? |
| **Uncertainty** | Measuring model uncertainty |

### KL Divergence

KL divergence measures how one probability distribution differs from another.

```
D_KL(P||Q) = Σ P(x) × log(P(x)/Q(x))
```

#### Why It Matters

- **Model Training** — Minimizing KL divergence = maximizing likelihood
- **Distillation** — Training smaller models
- **Regularization** — Keeping models close to prior

---

## Optimization

### Gradient Descent

Gradient descent is the workhorse of AI training.

```python
def gradient_descent(f, df, initial, learning_rate=0.01, iterations=100):
    x = initial
    for i in range(iterations):
        gradient = df(x)
        x = x - learning_rate * gradient
    return x
```

#### Variants

| Variant | Description | When to Use |
|---------|-------------|-------------|
| **Batch GD** | Use all data | Small datasets |
| **Stochastic GD** | Use one sample | Large datasets, online learning |
| **Mini-batch GD** | Use small batch | Most common |

### Loss Functions

**Loss functions** measure how wrong your model is.

| Loss | Formula | Use Case |
|------|---------|----------|
| **MSE** | (1/n)Σ(y - ŷ)² | Regression |
| **Cross-Entropy** | -Σ y log(ŷ) | Classification |
| **Hinge** | max(0, 1 - y·ŷ) | SVM |

```python
# Mean Squared Error
def mse(y_true, y_pred):
    return np.mean((y_true - y_pred) ** 2)

# Cross-Entropy
def cross_entropy(y_true, y_pred):
    return -np.sum(y_true * np.log(y_pred + 1e-10))
```

---

## Practical Applications

### Example 1: Embeddings are Vectors

```python
# Word embeddings are vectors
embeddings = {
    "king": [0.1, 0.5, 0.8, -0.2],
    "queen": [0.15, 0.45, 0.75, -0.15],
    "man": [0.2, 0.3, 0.1, 0.4],
    "woman": [0.25, 0.25, 0.05, 0.45]
}

# Vector arithmetic
king_embedding = np.array(embeddings["king"])
man_embedding = np.array(embeddings["man"])
woman_embedding = np.array(embeddings["woman"])

# king - man + woman ≈ queen
queen_approx = king_embedding - man_embedding + woman_embedding
```

### Example 2: Cosine Similarity

```python
def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

# Similarity between embeddings
similarity = cosine_similarity(
    embeddings["king"],
    embeddings["queen"]
)  # ≈ 0.8 (similar)
```

### Example 3: Softmax for Probabilities

```python
def softmax(logits):
    exp_logits = np.exp(logits - np.max(logits))
    return exp_logits / np.sum(exp_logits)

logits = [2.0, 1.0, 0.1]
probs = softmax(logits)
# [0.659, 0.242, 0.099] - probabilities sum to 1
```

---

## Quick Reference

### Linear Algebra

| Concept | Formula | Use in AI |
|---------|---------|-----------|
| **Dot Product** | a·b = Σ aᵢbᵢ | Attention, similarity |
| **Matrix Multiply** | Cᵢⱼ = Σ AᵢₖBₖⱼ | Neural network layers |
| **Euclidean Norm** | ||v|| = √(Σ vᵢ²) | Regularization |
| **Transpose** | (Aᵀ)ᵢⱼ = Aⱼᵢ | Shape changes |

### Calculus

| Concept | Formula | Use in AI |
|---------|---------|-----------|
| **Derivative** | f'(x) = lim Δx→0 (f(x+Δx)-f(x))/Δx | Gradient descent |
| **Gradient** | ∇f = [∂f/∂x₁, ..., ∂f/∂xₙ] | Backpropagation |
| **Chain Rule** | (f(g(x)))' = f'(g(x))g'(x) | Training networks |

### Probability

| Concept | Formula | Use in AI |
|---------|---------|-----------|
| **Bayes' Rule** | P(A|B) = P(B|A)P(A)/P(B) | Bayesian inference |
| **Expected Value** | E[X] = Σ x·P(x) | Loss functions |
| **Variance** | Var(X) = E[(X-μ)²] | Regularization |

---

**End of Primer 1**
