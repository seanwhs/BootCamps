# Appendix B: Linear Algebra Cheat Sheet

## Quick Reference for Vectors, Matrices, and Operations

### The Target

This appendix provides a comprehensive, quick-reference cheat sheet for all linear algebra concepts used in machine learning. It's designed to be a practical reference you can keep open while coding or reading ML papers.

### The Concept

Linear algebra is the language of machine learning. This cheat sheet puts all the essential formulas, operations, and concepts in one place—think of it as your "pocket reference" for the math behind ML.

**Why this matters**: When you're implementing algorithms, debugging models, or reading papers, you need quick access to these concepts. This reference helps you:
- Recall formulas quickly
- Check dimensions before implementing
- Understand matrix operations in code
- Debug dimension mismatches

### Vector Operations

#### Vector Basics

| Concept | Notation | Code (Our Library) |
|---------|----------|-------------------|
| Vector | `v ∈ ℝⁿ` | `Vector([1, 2, 3])` |
| Component | `v_i` | `v[i]` |
| Size | `n` | `v.size` |
| Zero vector | `0 = [0, 0, ..., 0]` | `Vector.zeros(n)` |
| Ones vector | `1 = [1, 1, ..., 1]` | `Vector.ones(n)` |

#### Vector Arithmetic

| Operation | Formula | Code |
|-----------|---------|------|
| Addition | `(u + v)_i = u_i + v_i` | `u + v` |
| Subtraction | `(u - v)_i = u_i - v_i` | `u - v` |
| Scalar multiply | `(c·v)_i = c·v_i` | `c * v` or `v * c` |
| Scalar divide | `(v/c)_i = v_i/c` | `v / c` |
| Negative | `(-v)_i = -v_i` | `-v` |

#### Vector Products

| Operation | Formula | Code | Use Case |
|-----------|---------|------|----------|
| Dot product | `u·v = Σ u_i v_i` | `u.dot(v)` | Similarity, weighted sum |
| L1 norm | `||v||₁ = Σ |v_i|` | `v.norm(1)` | Lasso regularization |
| L2 norm | `||v||₂ = √(Σ v_i²)` | `v.norm(2)` | Euclidean distance |
| Infinity norm | `||v||∞ = max |v_i|` | `v.norm(float('inf'))` | Maximum deviation |
| Distance | `||u-v||₂` | `u.distance(v, 2)` | Measuring difference |
| Normalization | `v̂ = v / ||v||₂` | `v.normalize()` | Unit direction |
| Standardization | `z = (v - μ)/σ` | `v.standardize()` | Feature scaling |

#### Vector Properties

| Property | Formula |
|----------|---------|
| Cauchy-Schwarz | `|u·v| ≤ ||u||₂ ||v||₂` |
| Triangle Inequality | `||u+v||₂ ≤ ||u||₂ + ||v||₂` |
| Dot Product Symmetry | `u·v = v·u` |
| Dot Product Bilinearity | `(αu+βv)·w = α(u·w) + β(v·w)` |
| L2 Norm from Dot Product | `||v||₂² = v·v` |

### Matrix Operations

#### Matrix Basics

| Concept | Notation | Code (Our Library) |
|---------|----------|-------------------|
| Matrix | `A ∈ ℝ^{m×n}` | `Matrix([[1,2],[3,4]])` |
| Element | `A_{ij}` | `A[i, j]` |
| Shape | `(m, n)` | `A.shape` |
| Rows | `m` | `A.rows` |
| Columns | `n` | `A.cols` |
| Transpose | `A^T ∈ ℝ^{n×m}` | `A.T` |
| Identity | `I ∈ ℝ^{n×n}` | `Matrix.identity(n)` |
| Zero Matrix | `0_{m×n}` | `Matrix.zeros(m, n)` |
| Ones Matrix | `1_{m×n}` | `Matrix.ones(m, n)` |

#### Matrix Arithmetic

| Operation | Formula | Code | Condition |
|-----------|---------|------|-----------|
| Addition | `(A+B)_{ij} = A_{ij} + B_{ij}` | `A + B` | Same shape |
| Subtraction | `(A-B)_{ij} = A_{ij} - B_{ij}` | `A - B` | Same shape |
| Scalar multiply | `(c·A)_{ij} = c·A_{ij}` | `c * A` | Any |
| Scalar divide | `(A/c)_{ij} = A_{ij}/c` | `A / c` | c ≠ 0 |
| Element-wise multiply | `(A⊙B)_{ij} = A_{ij}·B_{ij}` | Hadamard product | Same shape |

#### Matrix Multiplication

| Operation | Formula | Code | Result Shape |
|-----------|---------|------|--------------|
| Matrix-Matrix | `(AB)_{ij} = Σ_k A_{ik}B_{kj}` | `A @ B` | `(m, p)` if A∈ℝ^{m×n}, B∈ℝ^{n×p} |
| Matrix-Vector | `(Av)_i = Σ_j A_{ij}v_j` | `A.vector_dot(v)` | `(m,)` if A∈ℝ^{m×n} |
| Vector-Matrix | `(v^T A)_j = Σ_i v_i A_{ij}` | `v^T A` | `(n,)` if A∈ℝ^{m×n} |
| Outer Product | `(uv^T)_{ij} = u_i v_j` | `u * v.T` | `(m, n)` |
| Hadamard Product | `(A⊙B)_{ij} = A_{ij}B_{ij}` | Element-wise | Same shape |

#### Matrix Properties

| Property | Formula | Condition |
|----------|---------|-----------|
| Associative | `(AB)C = A(BC)` | Compatible dimensions |
| Distributive | `A(B+C) = AB + AC` | Compatible |
| Transpose of Product | `(AB)^T = B^T A^T` | Compatible |
| Inverse of Product | `(AB)^{-1} = B^{-1}A^{-1}` | Both invertible |
| Trace | `tr(A) = Σ_i A_{ii}` | Square |
| Determinant of Product | `det(AB) = det(A)det(B)` | Square |

### Special Matrices

| Type | Definition | Properties | ML Use |
|------|------------|------------|--------|
| **Identity** | `I_{ij} = 1 if i=j else 0` | `AI = IA = A` | Starting point, residuals |
| **Diagonal** | `D_{ij} = 0 if i≠j` | `D = diag(d₁, d₂, ...)` | Scaling, regularization |
| **Symmetric** | `A = A^T` | `A_{ij} = A_{ji}` | Covariance, Hessian |
| **Orthogonal** | `Q^T Q = QQ^T = I` | `||Qx||₂ = ||x||₂` | Rotations, PCA |
| **Triangular** | `L` or `U` | Lower/Upper triangular | Solving systems |
| **Positive Definite** | `x^T A x > 0` | All eigenvalues > 0 | Covariance, Hessian |
| **Positive Semidefinite** | `x^T A x ≥ 0` | All eigenvalues ≥ 0 | Kernel matrices |
| **Idempotent** | `A² = A` | Projection | Linear regression |
| **Involutory** | `A² = I` | Self-inverse | Reflection |

### Matrix Decompositions

#### Eigenvalue Decomposition

| Concept | Formula | Code |
|---------|---------|------|
| Eigenvalue Equation | `Av = λv` | `Decomposition.power_iteration(A)` |
| Eigendecomposition | `A = QΛQ^{-1}` | `Decomposition.all_eigenvalues(A)` |
| Diagonalization | `Λ = Q^{-1}AQ` | |
| Spectral Theorem | `A = QΛQ^T` (symmetric) | |

#### Singular Value Decomposition (SVD)

| Concept | Formula | Code |
|---------|---------|------|
| SVD | `A = UΣV^T` | `Decomposition.svd(A)` |
| Left Singular Vectors | `U ∈ ℝ^{m×m}` | Orthonormal columns |
| Singular Values | `Σ ∈ ℝ^{m×n}` | Diagonal, non-negative |
| Right Singular Vectors | `V ∈ ℝ^{n×n}` | Orthonormal columns |
| Low-rank Approximation | `A ≈ U_k Σ_k V_k^T` | Truncated SVD |

#### PCA (Principal Component Analysis)

| Step | Formula | Code |
|------|---------|------|
| Center Data | `X_c = X - μ` | `X - X.mean(axis=0)` |
| Covariance | `C = (1/(n-1))X_c^T X_c` | `Decomposition.compute_covariance(X)` |
| SVD | `X_c = UΣV^T` | `Decomposition.svd(X_c)` |
| Components | `V` (right singular vectors) | |
| Projection | `T = X_c V` | `Decomposition.pca(X, k)` |

### Matrix Norms

| Norm | Formula | Code | Use Case |
|------|---------|------|----------|
| Frobenius | `||A||_F = √(Σ_{ij} A_{ij}²)` | Frobenius norm | Matrix magnitude |
| L2,∞ | `||A||_{2,∞} = max_j ||column_j||₂` | | Column max |
| Nuclear | `||A||_* = Σ σ_i` | Sum of singular values | Low-rank |
| Spectral | `||A||_2 = σ_max` | Largest singular value | Operator norm |
| Entrywise L1 | `||A||_1 = Σ |A_{ij}|` | Sum of abs | Lasso |
| Max | `||A||_∞ = max |A_{ij}|` | Max element | |

### Common ML Equations in Matrix Form

#### Linear Models

| Model | Matrix Equation | Notes |
|-------|-----------------|-------|
| Linear Regression | `ŷ = Xw + b` | `w ∈ ℝ^d, b ∈ ℝ` |
| Multiple Outputs | `Ŷ = XW + b` | `W ∈ ℝ^{d×k}` |
| Ridge Regression | `w = (X^T X + λI)^{-1}X^T y` | Closed form |
| Lasso | `min ||Xw - y||₂² + λ||w||₁` | Not closed form |
| Logistic Regression | `P(y=1|x) = σ(w^T x + b)` | σ = sigmoid |

#### Neural Networks

| Layer Type | Forward Pass | Backward Pass |
|------------|--------------|---------------|
| Dense Layer | `z = W^T a + b` | `∂L/∂W = a(∂L/∂z)^T` |
| Activation | `a = g(z)` | `∂L/∂z = g'(z) ∂L/∂a` |
| Softmax | `a_i = e^{z_i}/Σ e^{z_j}` | `∂L/∂z = a - y` (with CE) |
| Batch Norm | `z̄ = (z-μ)/σ` | Involves more gradients |

#### Optimization

| Algorithm | Update Rule |
|-----------|-------------|
| Gradient Descent | `w = w - α∇L(w)` |
| SGD | `w = w - α∇L(w_i)` (single sample) |
| Mini-batch | `w = w - α(1/b)Σ∇L(w_i)` |
| Momentum | `v = βv + α∇L(w)`; `w = w - v` |
| Adam | `m = β₁m + (1-β₁)g`; `v = β₂v + (1-β₂)g²`; `w = w - α m̂/(√v̂ + ε)` |

### Vector Calculus in ML

#### Gradients of Common Functions

| Function f(w) | Gradient ∇f(w) |
|---------------|----------------|
| `w^T a` | `a` |
| `w^T A w` (A symmetric) | `2Aw` |
| `w^T A w` (A general) | `(A + A^T)w` |
| `||w||₂²` | `2w` |
| `||w||₁` | `sign(w)` |
| `log(w)` | `1/w` (element-wise) |
| `exp(w)` | `exp(w)` (element-wise) |
| `σ(w)` (sigmoid) | `σ(w)⊙(1-σ(w))` |
| `ReLU(w)` | `1 if w>0 else 0` |

#### Jacobian and Hessian

| Concept | Formula | Shape |
|---------|---------|-------|
| Jacobian | `J = [∂f_i/∂x_j]` | `(m, n)` for f: ℝⁿ→ℝᵐ |
| Hessian | `H = [∂²f/∂x_i∂x_j]` | `(n, n)` for f: ℝⁿ→ℝ |
| Gradient | `∇f = [∂f/∂x_i]` | `(n,)` for f: ℝⁿ→ℝ |

### Common Dimensions in ML

| Variable | Shape | Description |
|----------|-------|-------------|
| `X` | `(m, d)` | m samples, d features |
| `y` | `(m,)` or `(m, 1)` | m targets |
| `w` | `(d,)` or `(d, 1)` | Weights |
| `b` | `(1,)` or `(1,)` | Bias |
| `Xw` | `(m,)` | Predictions |
| `X^T X` | `(d, d)` | Gram matrix |
| `X^T y` | `(d,)` | Correlations |
| `C` | `(d, d)` | Covariance matrix |
| `Ŷ` | `(m, k)` | k predictions |
| `W` | `(d, k)` | k weight vectors |

### Quick Debugging Tips

#### Dimension Checks

```
Always check shapes:
X: (m, d)
w: (d, 1)
Xw: (m, 1)  ✓

X: (m, d)
w: (d, 1)
wT XT: Error! (should be X w)
```

#### Common Errors and Fixes

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| `Cannot multiply` | Dimension mismatch | Check shapes, transpose |
| `Singular matrix` | Matrix not invertible | Use SVD, add λI |
| `NaN values` | Division by zero | Add epsilon |
| `Inf values` | exp overflow | Use log-sum-exp |

#### Code Pattern: Matrix-Vector Product

```python
# Correct
result = X @ w  # X: (m, n), w: (n,)

# Also correct
result = X.vector_dot(w)

# Wrong (if w is (n, 1))
result = X @ w  # w must be (n,)
```

---

**[END OF APPENDIX B]**
