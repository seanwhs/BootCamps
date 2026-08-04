# STUDENT NOTES
## Mathematics for Machine Learning
### Complete Course Notes — All Parts

---

# 📓 PART 1: LINEAR ALGEBRA — THE LANGUAGE OF DATA

## Module 1.1: Vectors — The Atoms of Data

### 📌 Key Definitions

**Vector**: An ordered list of numbers representing a point in space or a data point
- **Dimension**: Number of components in a vector
- **Notation**: `v = [v₁, v₂, v₃, ..., vₙ]` or `v ∈ ℝⁿ`

**Vector Space**: A set of vectors closed under addition and scalar multiplication

**Basis**: A set of linearly independent vectors that span the space

---

### 📐 Vector Operations

| Operation | Formula | Python Code | ML Use |
|-----------|---------|-------------|--------|
| Addition | `(u+v)_i = u_i + v_i` | `u + v` | Combining features |
| Subtraction | `(u-v)_i = u_i - v_i` | `u - v` | Computing differences |
| Scalar Multiplication | `(c·v)_i = c·v_i` | `c * v` | Scaling data |
| Dot Product | `u·v = Σ u_i v_i` | `u.dot(v)` | Similarity, weighted sums |
| L2 Norm | `||v||₂ = √(Σ v_i²)` | `v.norm(2)` | Euclidean distance |
| L1 Norm | `||v||₁ = Σ|v_i|` | `v.norm(1)` | Lasso regularization |
| Normalization | `v̂ = v/||v||₂` | `v.normalize()` | Unit direction |

---

### 💡 Key Insights

1. **Dot Product Measures Similarity**
   - Large positive → similar vectors
   - Zero → orthogonal (unrelated)
   - Large negative → opposite directions

2. **Norm Measures Magnitude**
   - L2: Euclidean (standard distance)
   - L1: Manhattan (robust to outliers)
   - L∞: Maximum component

3. **Normalization Creates Unit Vectors**
   - Preserves direction
   - Magnitude becomes 1
   - Used in cosine similarity

---

### 📝 Code Template

```python
class Vector:
    def __init__(self, data):
        self._data = [float(x) for x in data]
        self.size = len(self._data)
    
    def __add__(self, other):
        return Vector([a + b for a, b in zip(self._data, other._data)])
    
    def dot(self, other):
        return sum(a * b for a, b in zip(self._data, other._data))
    
    def norm(self, p=2):
        if p == 1:
            return sum(abs(x) for x in self._data)
        elif p == 2:
            return sum(x**2 for x in self._data) ** 0.5
        elif p == float('inf'):
            return max(abs(x) for x in self._data)
    
    def normalize(self):
        norm = self.norm(2)
        return Vector([x / norm for x in self._data])
```

---

## Module 1.2: Matrices — Datasets in 2D

### 📌 Key Definitions

**Matrix**: A 2D array of numbers
- **Shape**: (rows, columns) = (m, n)
- **Element**: `A[i, j]` or `A_{ij}`

**Transpose**: `(A^T)_ij = A_ji` — swaps rows and columns

---

### 📐 Matrix Operations

| Operation | Formula | Result Shape | Python Code |
|-----------|---------|--------------|-------------|
| Addition | `(A+B)_ij = A_ij + B_ij` | Same as input | `A + B` |
| Transpose | `(A^T)_ij = A_ji` | (n, m) | `A.T` |
| Matrix Multiplication | `(AB)_ij = Σ_k A_ik B_kj` | (m, p) | `A @ B` |
| Matrix-Vector | `(Av)_i = Σ_j A_ij v_j` | (m,) | `A.vector_dot(v)` |
| Inverse | `AA^{-1} = A^{-1}A = I` | (n, n) | `A.inverse()` |

---

### 💡 Special Matrices

| Type | Definition | Properties | ML Use |
|------|------------|------------|--------|
| Identity | `I_ij = 1 if i=j else 0` | AI = IA = A | Starting point |
| Diagonal | `D_ij = 0 if i≠j` | Only diagonal non-zero | Scaling |
| Symmetric | `A = A^T` | Covariance matrices | PCA, Hessian |
| Orthogonal | `Q^T Q = QQ^T = I` | Preserves norms | Rotations |

---

### 📝 Code Template

```python
class Matrix:
    def __init__(self, data):
        self._data = [[float(x) for x in row] for row in data]
        self.rows = len(self._data)
        self.cols = len(self._data[0])
        self.shape = (self.rows, self.cols)
    
    def __getitem__(self, indices):
        i, j = indices
        return self._data[i][j]
    
    def T(self):
        """Transpose"""
        transposed = [[self._data[i][j] for i in range(self.rows)] 
                      for j in range(self.cols)]
        return Matrix(transposed)
    
    def __matmul__(self, other):
        """Matrix multiplication"""
        result = [[0] * other.cols for _ in range(self.rows)]
        for i in range(self.rows):
            for j in range(other.cols):
                total = 0
                for k in range(self.cols):
                    total += self._data[i][k] * other._data[k][j]
                result[i][j] = total
        return Matrix(result)
```

---

## Module 1.3: SVD and PCA

### 📌 Key Definitions

**Eigenvalue/Eigenvector**: `Av = λv`
- v: Direction that doesn't change
- λ: Stretching factor

**SVD (Singular Value Decomposition)**: `A = UΣV^T`
- U: Left singular vectors (m × m)
- Σ: Singular values (m × n, diagonal)
- V: Right singular vectors (n × n)

**PCA (Principal Component Analysis)**:
1. Center data: `X_c = X - μ`
2. SVD: `X_c = UΣV^T`
3. Components: `V` (right singular vectors)
4. Projection: `T = X_c V_k`

---

### 💡 Key Insights

**SVD Insights:**
- Works on ANY matrix (not just square)
- Singular values = importance of each component
- Larger σ = more important component
- Truncated SVD = optimal low-rank approximation

**PCA Insights:**
- Finds directions of maximum variance
- Explained variance ratio = σ_i² / Σσ_j²
- Use elbow plot to choose k components
- Preserves as much information as possible

---

### 📝 Code Template

```python
def pca(X, n_components):
    """PCA implementation using SVD"""
    # Center data
    mean = np.mean(X, axis=0)
    X_centered = X - mean
    
    # SVD
    U, S, Vt = np.linalg.svd(X_centered)
    
    # Components
    components = Vt[:n_components]
    
    # Projection
    projected = X_centered @ components.T
    
    # Explained variance
    explained_variance = S[:n_components]**2 / np.sum(S**2)
    
    return projected, components, explained_variance
```

---

# 📓 PART 2: CALCULUS — THE ENGINE OF OPTIMIZATION

## Module 2.1: Derivatives — Measuring Change

### 📌 Key Definitions

**Derivative**: Rate of change of a function at a point
- `f'(x) = lim_{h→0} (f(x+h) - f(x))/h`
- Slope of tangent line

**Partial Derivative**: Derivative w.r.t. one variable
- `∂f/∂x_i` (hold others constant)
- Gradient: `∇f = [∂f/∂x₁, ∂f/∂x₂, ...]`

---

### 📐 Derivative Rules

| Rule | Formula |
|------|---------|
| Power | `d/dx(x^n) = n·x^{n-1}` |
| Exponential | `d/dx(e^x) = e^x` |
| Natural Log | `d/dx(ln(x)) = 1/x` |
| Chain | `d/dx(f(g(x))) = f'(g(x))·g'(x)` |
| Product | `d/dx(f·g) = f'g + fg'` |
| Sigmoid | `d/dx(σ(x)) = σ(x)(1-σ(x))` |
| Tanh | `d/dx(tanh(x)) = 1 - tanh²(x)` |
| ReLU | `d/dx(ReLU(x)) = 1 if x>0 else 0` |

---

### 💡 Key Insights

**Gradient:**
- Vector of partial derivatives
- Points in direction of steepest ascent
- Negative gradient = steepest descent

**Numerical Derivatives:**
- Central difference: `f'(x) ≈ (f(x+h) - f(x-h))/(2h)`
- More stable than forward difference
- Used for gradient checking

---

### 📝 Code Template

```python
def numerical_gradient(f, x, h=1e-7):
    """Compute gradient numerically"""
    gradient = np.zeros_like(x)
    for i in range(len(x)):
        x_plus = x.copy()
        x_minus = x.copy()
        x_plus[i] += h
        x_minus[i] -= h
        gradient[i] = (f(x_plus) - f(x_minus)) / (2*h)
    return gradient
```

---

## Module 2.2: Gradient Descent — The Learning Algorithm

### 📌 Key Definitions

**Gradient Descent**: `w_{t+1} = w_t - α∇L(w_t)`

**Learning Rate (α)**: Step size in gradient descent

**Convergence**: When weight changes are very small

---

### 📐 Optimization Variants

| Algorithm | Update Rule | Characteristics |
|-----------|-------------|-----------------|
| Batch GD | `w = w - α(1/n)Σ∇L_i` | Accurate, slow |
| SGD | `w = w - α∇L_i` | Fast, noisy |
| Mini-batch GD | `w = w - α(1/b)Σ_{i∈batch}∇L_i` | Balance |
| Momentum | `v = βv + α∇L; w = w - v` | Acceleration |
| Adam | `m = β₁m + (1-β₁)g; v = β₂v + (1-β₂)g²` | Adaptive |

---

### 💡 Key Insights

**Learning Rate Effects:**
- Too large: Oscillates/diverges
- Too small: Slow convergence
- Just right: Steady descent

**Learning Rate Schedules:**
- Step decay: `α_t = α₀γ^{⌊t/T⌋}`
- Exponential: `α_t = α₀e^{-kt}`
- Cosine: `α_t = α₀/2(1 + cos(πt/T))`

**Stopping Criteria:**
- Max iterations reached
- Weight change < tolerance
- Loss change < tolerance

---

### 📝 Code Template

```python
def gradient_descent(f, grad_f, w0, learning_rate=0.01, epochs=100):
    """Batch gradient descent"""
    w = w0.copy()
    history = []
    
    for _ in range(epochs):
        loss = f(w)
        history.append(loss)
        gradient = grad_f(w)
        w = w - learning_rate * gradient
    
    return w, history

def gradient_descent_with_momentum(f, grad_f, w0, learning_rate=0.01, 
                                   beta=0.9, epochs=100):
    """GD with momentum"""
    w = w0.copy()
    v = np.zeros_like(w)
    history = []
    
    for _ in range(epochs):
        loss = f(w)
        history.append(loss)
        gradient = grad_f(w)
        v = beta * v + learning_rate * gradient
        w = w - v
    
    return w, history
```

---

## Module 2.3: Backpropagation — The Chain Rule in Action

### 📌 Key Definitions

**Chain Rule**: `d/dx(f(g(x))) = f'(g(x))·g'(x)`

**Backpropagation**: Applying chain rule backwards through network

**δ (Delta)**: Gradient with respect to pre-activation: `δ^(l) = ∂L/∂z^(l)`

---

### 📐 Backpropagation Formulas

**Forward Pass:**
```
a⁰ = x
zˡ = Wˡa^{l-1} + bˡ
aˡ = gˡ(zˡ)
ŷ = aᴸ
```

**Backward Pass:**
```
δᴸ = ∇ₐL ⊙ g'ᴸ(zᴸ)
δˡ = (W^{l+1})^T δ^{l+1} ⊙ g'ˡ(zˡ)
∂L/∂Wˡ = δˡ(a^{l-1})^T
∂L/∂bˡ = δˡ
```

---

### 💡 Key Insights

**Computational Graphs:**
- Nodes = operations
- Edges = data flow
- Forward: left → right (compute outputs)
- Backward: right → left (compute gradients)

**Common Issues:**
- Vanishing gradients: Gradients too small (use ReLU, BN)
- Exploding gradients: Gradients too large (use clipping)
- Dead ReLU: Neurons never activate (use Leaky ReLU)

---

### 📝 Code Template

```python
class DenseLayer:
    def __init__(self, input_size, output_size):
        self.W = np.random.randn(output_size, input_size) * 0.01
        self.b = np.zeros((output_size, 1))
        self.input = None
        self.z = None
        self.a = None
    
    def forward(self, X):
        """Forward pass: a = g(WX + b)"""
        self.input = X
        self.z = self.W @ X + self.b
        self.a = self._activation(self.z)
        return self.a
    
    def backward(self, grad_output, learning_rate):
        """Backward pass: compute gradients and update weights"""
        # Gradient through activation
        grad_z = grad_output * self._activation_grad(self.z)
        
        # Gradients for weights and bias
        grad_W = grad_z @ self.input.T
        grad_b = grad_z.sum(axis=1, keepdims=True)
        
        # Gradient for input (to pass backward)
        grad_input = self.W.T @ grad_z
        
        # Update weights
        self.W -= learning_rate * grad_W
        self.b -= learning_rate * grad_b
        
        return grad_input
```

---

# 📓 PART 3: PROBABILITY & STATISTICS — HANDLING UNCERTAINTY

## Module 3.1: Probability Theory & Distributions

### 📌 Key Definitions

**Probability**: Measure of likelihood (0 to 1)

**Conditional Probability**: `P(A|B) = P(A∩B)/P(B)`

**Independence**: `P(A|B) = P(A)`, so `P(A∩B) = P(A)P(B)`

**Bayes' Theorem**: `P(A|B) = P(B|A)P(A)/P(B)`

---

### 📐 Common Distributions

| Distribution | Parameters | PMF/PDF | Mean | Variance | Use |
|--------------|------------|---------|------|----------|-----|
| Bernoulli | `p` | `p^x(1-p)^{1-x}` | `p` | `p(1-p)` | Binary |
| Binomial | `n, p` | `C(n,k)p^k(1-p)^{n-k}` | `np` | `np(1-p)` | Counts |
| Gaussian | `μ, σ²` | `(1/(σ√2π))e^{-(x-μ)²/(2σ²)}` | `μ` | `σ²` | Most common |
| Poisson | `λ` | `e^{-λ}λ^k/k!` | `λ` | `λ` | Rare events |

---

### 💡 Key Insights

**Bayes' Theorem Forms:**
- Standard: `P(A|B) = P(B|A)P(A)/P(B)`
- Odds: `Odds(A|B) = LR × Odds(A)`
- Log-odds: `logit(P) = log(P/(1-P))`

**68-95-99.7 Rule (Gaussian):**
- 68% within μ ± 1σ
- 95% within μ ± 2σ
- 99.7% within μ ± 3σ

---

### 📝 Code Template

```python
class GaussianDistribution:
    def __init__(self, mean=0, std=1):
        self.mean = mean
        self.std = std
    
    def pdf(self, x):
        """Probability density function"""
        z = (x - self.mean) / self.std
        return 1/(self.std * np.sqrt(2*np.pi)) * np.exp(-0.5*z*z)
    
    def sample(self, n=1):
        """Generate random samples"""
        return np.random.normal(self.mean, self.std, n)

class BernoulliDistribution:
    def __init__(self, p=0.5):
        self.p = p
    
    def pmf(self, x):
        """Probability mass function"""
        return self.p**x * (1-self.p)**(1-x)
    
    def sample(self, n=1):
        """Generate random samples"""
        return np.random.binomial(1, self.p, n)
```

---

## Module 3.2: Naive Bayes & Bayesian Inference

### 📌 Key Definitions

**Naive Bayes Classifier**: Assumes features are independent given class
- `P(y|x₁,...,xₙ) ∝ P(y)ΠP(x_i|y)`
- Simple but effective!

**MLE (Maximum Likelihood Estimation)**: `θ̂ = argmax_θ P(data|θ)`

**MAP (Maximum A Posteriori)**: `θ̂ = argmax_θ P(θ|data) = argmax_θ P(data|θ)P(θ)`

---

### 📐 Naive Bayes Formulas

**Gaussian Naive Bayes:**
- `P(x_j|y=c) = N(x_j | μ_jc, σ_jc²)`
- Where `μ_jc` and `σ_jc²` are estimated from data

**Training:**
1. `P(c) = n_c/n`
2. `μ_jc = (1/n_c)Σ_{i:y_i=c} x_ij`
3. `σ_jc² = (1/n_c)Σ_{i:y_i=c} (x_ij - μ_jc)²`

**Prediction:**
- `P(c|x) ∝ P(c)Π_j (1/(σ_jc√2π))exp(-(x_j-μ_jc)²/(2σ_jc²))`

---

### 💡 Key Insights

**Why Naive Bayes Works:**
- Independence assumption is often wrong but useful
- Works well for high-dimensional data
- Very fast to train and predict
- Good baseline for classification

**MLE vs MAP:**
- MLE: No prior, uses only data
- MAP: Includes prior knowledge
- MAP = Regularization (like L2)

---

### 📝 Code Template

```python
class GaussianNaiveBayes:
    def __init__(self):
        self.priors = {}
        self.means = {}
        self.stds = {}
    
    def fit(self, X, y):
        """Train Naive Bayes classifier"""
        classes = np.unique(y)
        n_samples = len(y)
        
        for c in classes:
            X_c = X[y == c]
            self.priors[c] = len(X_c) / n_samples
            self.means[c] = X_c.mean(axis=0)
            self.stds[c] = X_c.std(axis=0) + 1e-6
    
    def predict(self, X):
        """Predict class labels"""
        log_probs = []
        for c in self.priors:
            log_prob = np.log(self.priors[c])
            for j in range(X.shape[1]):
                z = (X[:, j] - self.means[c][j]) / self.stds[c][j]
                log_prob += (-0.5 * z**2 - np.log(self.stds[c][j]) 
                            - 0.5*np.log(2*np.pi))
            log_probs.append(log_prob)
        
        return np.argmax(np.array(log_probs), axis=0)
```

---

## Module 3.3: Model Evaluation

### 📌 Key Definitions

**Bias-Variance Tradeoff:**
- `Error = Bias² + Variance + Noise`
- Bias: Systematic error (underfitting)
- Variance: Random error (overfitting)

**Confusion Matrix:**
```
            Predicted
           P     N
Actual P  TP    FN
       N  FP    TN
```

---

### 📐 Evaluation Metrics

**Classification Metrics:**
| Metric | Formula | Interpretation |
|--------|---------|----------------|
| Accuracy | `(TP+TN)/Total` | Overall correctness |
| Precision | `TP/(TP+FP)` | "Of predicted positive, how many correct?" |
| Recall | `TP/(TP+FN)` | "Of actual positive, how many found?" |
| F1 | `2·P·R/(P+R)` | Harmonic mean of P and R |

**Regression Metrics:**
| Metric | Formula |
|--------|---------|
| MSE | `(1/n)Σ(y_i-ŷ_i)²` |
| RMSE | `√(MSE)` |
| MAE | `(1/n)Σ|y_i-ŷ_i|` |
| R² | `1 - SSE/SST` |

---

### 💡 Key Insights

**Cross-Validation (k-fold):**
1. Split data into k equal parts
2. For each fold: train on k-1, test on 1
3. Average results
- k=5 or k=10 common choices

**Learning Curves:**
- High bias: Both errors high, gap small
- High variance: Train low, test high, gap large
- Good fit: Both low, gap small

---

### 📝 Code Template

```python
def confusion_matrix(y_true, y_pred):
    """Compute confusion matrix: TP, FP, FN, TN"""
    tp = fp = fn = tn = 0
    for t, p in zip(y_true, y_pred):
        if t == 1 and p == 1: tp += 1
        elif t == 0 and p == 1: fp += 1
        elif t == 1 and p == 0: fn += 1
        else: tn += 1
    return tp, fp, fn, tn

def cross_validate(model, X, y, k=5):
    """k-fold cross-validation"""
    n_samples = len(X)
    fold_size = n_samples // k
    scores = []
    
    indices = np.random.permutation(n_samples)
    
    for fold in range(k):
        test_start = fold * fold_size
        test_end = min((fold + 1) * fold_size, n_samples)
        
        test_idx = indices[test_start:test_end]
        train_idx = np.concatenate([indices[:test_start], 
                                   indices[test_end:]])
        
        X_train = X[train_idx]
        y_train = y[train_idx]
        X_test = X[test_idx]
        y_test = y[test_idx]
        
        model.fit(X_train, y_train)
        score = model.score(X_test, y_test)
        scores.append(score)
    
    return scores
```

---

# 📓 PART 4: APPLIED NUMERICAL METHODS

## Module 4.1: Numerical Stability

### 📌 Key Definitions

**Floating Point Issues:**
- Overflow: Number too large (`exp(1000) → inf`)
- Underflow: Number too small (`exp(-1000) → 0`)
- Catastrophic cancellation: Subtracting nearly equal numbers

**Condition Number**: Measures matrix stability
- Low (< 10): Well-conditioned
- High (> 1000): Ill-conditioned

---

### 📐 Stable Operations

**Log-Sum-Exp Trick:**
```
log(Σ exp(v_i)) = max(v) + log(Σ exp(v_i - max(v)))
```
- Prevents overflow in softmax
- Used in log-likelihood, cross-entropy

**Stable Softmax:**
```python
def stable_softmax(x):
    max_val = max(x)
    exp_x = [np.exp(v - max_val) for v in x]
    return exp_x / sum(exp_x)
```

**Gradient Clipping:**
```python
def clip_gradient(g, max_norm):
    norm = np.sqrt(np.sum(g**2))
    if norm > max_norm:
        return g * (max_norm / norm)
    return g
```

---

### 💡 Key Insights

**Numerical Stability Tips:**
1. Always use `log-sum-exp` for softmax
2. Clip gradients to prevent explosion
3. Add small epsilon to denominators
4. Use `np.clip` for safety
5. Check for NaN/Inf values

**Common Stability Issues:**
- Softmax with large values → NaN
- Log(0) → -Inf → NaN
- Division by zero → Inf/NaN
- Matrix inversion of singular matrix

---

### 📝 Code Template

```python
class SafeMath:
    @staticmethod
    def safe_exp(x, max_val=700):
        if x > max_val:
            return np.exp(max_val)
        if x < -max_val:
            return 0.0
        return np.exp(x)
    
    @staticmethod
    def safe_log(x, eps=1e-12):
        return np.log(max(x, eps))
    
    @staticmethod
    def log_sum_exp(values):
        max_val = max(values)
        exp_vals = [np.exp(v - max_val) for v in values]
        return max_val + np.log(sum(exp_vals))
    
    @staticmethod
    def stable_softmax(logits):
        max_val = max(logits)
        exp_vals = [np.exp(v - max_val) for v in logits]
        total = sum(exp_vals)
        return [v / total for v in exp_vals]
```

---

## Module 4.2: Performance Optimization

### 📌 Key Definitions

**Vectorization**: Using array operations instead of loops
- NumPy operations are C-optimized
- Much faster than Python loops

**View vs Copy:**
- View: References original data (fast)
- Copy: Creates new array (uses more memory)

---

### 💡 Performance Tips

**Vectorization:**
```python
# BAD (loop)
for i in range(n):
    arr[i] = arr[i] * 2

# GOOD (vectorized)
arr = arr * 2
```

**Memory Efficiency:**
- Use `float32` instead of `float64`
- Process data in batches
- Delete large arrays when done
- Use views instead of copies

**Batch Processing:**
```python
def process_in_batches(data, batch_size=32):
    n_samples = len(data)
    for i in range(0, n_samples, batch_size):
        batch = data[i:min(i+batch_size, n_samples)]
        yield batch
```

---

### 📝 Code Template

```python
def vectorized_distance(X1, X2):
    """Efficient pairwise distance computation"""
    # ||a - b||² = ||a||² + ||b||² - 2·a·b^T
    n1 = X1.shape[0]
    n2 = X2.shape[0]
    
    norms1 = np.sum(X1**2, axis=1).reshape(n1, 1)
    norms2 = np.sum(X2**2, axis=1).reshape(1, n2)
    
    distances = norms1 + norms2 - 2 * X1 @ X2.T
    return np.maximum(distances, 0)  # Remove numerical negatives
```

---

# 📋 QUICK REFERENCE CARDS

## Linear Algebra Reference Card

### Vector Operations
```
Dot Product:    u·v = Σ u_i v_i
L2 Norm:       ||v||₂ = √(Σ v_i²)
L1 Norm:       ||v||₁ = Σ|v_i|
Normalization: v̂ = v/||v||₂
Distance:      ||u-v||₂
```

### Matrix Operations
```
Transpose:     (A^T)_ij = A_ji
Multiply:      (AB)_ij = Σ_k A_ik B_kj
Inverse:       AA^{-1} = I
Determinant:   det(A)
```

### Special Matrices
```
Identity:      I_ij = 1 if i=j else 0
Diagonal:      D_ij = 0 if i≠j
Symmetric:     A = A^T
Orthogonal:    Q^T Q = I
```

## Calculus Reference Card

### Derivatives
```
Power:         d/dx(x^n) = nx^{n-1}
Exponential:   d/dx(e^x) = e^x
Log:           d/dx(ln(x)) = 1/x
Chain Rule:    d/dx(f(g(x))) = f'(g(x))g'(x)
```

### Activation Derivatives
```
Sigmoid:       σ'(x) = σ(x)(1-σ(x))
Tanh:          tanh'(x) = 1-tanh²(x)
ReLU:          ReLU'(x) = 1 if x>0 else 0
```

### Gradient Descent
```
Update:        w = w - α∇L(w)
Momentum:      v = βv + α∇L(w); w = w - v
Adam:          m = β₁m + (1-β₁)g; v = β₂v + (1-β₂)g²
               w = w - α m̂/(√v̂ + ε)
```

## Probability Reference Card

### Bayes' Theorem
```
P(A|B) = P(B|A)P(A)/P(B)
Posterior = Likelihood × Prior / Evidence
```

### Key Distributions
```
Bernoulli:     P(X=x) = p^x(1-p)^{1-x}, mean=p
Gaussian:      f(x) = (1/(σ√2π))exp(-(x-μ)²/(2σ²)), mean=μ
```

### MLE Estimators
```
Gaussian μ:    μ̂ = (1/n)Σx_i
Gaussian σ²:   σ̂² = (1/n)Σ(x_i-μ̂)²
Bernoulli p:   p̂ = (1/n)Σx_i
```

## Numerical Methods Reference Card

### Stable Operations
```
Stable Softmax: exp(x-max(x)) / sum(exp(x-max(x)))
Log-Sum-Exp:    max(x) + log(sum(exp(x-max(x))))
Safe Exp:       exp(min(x, 700))
Safe Log:       log(max(x, eps))
```

### Gradient Clipping
```
By Norm:       if ||g|| > threshold: g = g * threshold / ||g||
By Value:      g = clip(g, -threshold, threshold)
```

### Performance Tips
```
Vectorize:     Array ops > Loops
Batch:         Process data in chunks
View:          Reference data (no copy)
Copy:          Use when modifications needed
```

---

# 📝 NOTES TEMPLATE

Use this template for each module:

```
## Module [Number]: [Title]

### Key Concepts
-

### Important Formulas
-

### Code Snippets
-

### Common Pitfalls
-

### Questions I Have
-

### Things to Review
-
```

---

**📚 END OF STUDENT NOTES**

---

*"The beautiful thing about learning is that nobody can take it away from you." — B.B. King*
