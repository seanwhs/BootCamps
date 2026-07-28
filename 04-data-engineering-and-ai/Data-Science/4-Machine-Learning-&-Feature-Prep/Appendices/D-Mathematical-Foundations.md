# Appendix D: Mathematical Foundations

## 1. Linear Algebra

### Vectors and Matrices

**Vector**: A one-dimensional array of numbers.
```
v = [v₁, v₂, ..., vₙ]
```

**Matrix**: A two-dimensional array of numbers.
```
A = [[a₁₁, a₁₂, ..., a₁ₙ],
     [a₂₁, a₂₂, ..., a₂ₙ],
     ...
     [aₘ₁, aₘ₂, ..., aₘₙ]]
```

**Key Operations**:

| Operation | Formula | Description |
|-----------|---------|-------------|
| Vector Addition | u + v = [u₁+v₁, u₂+v₂, ...] | Element-wise addition |
| Scalar Multiplication | c·v = [c·v₁, c·v₂, ...] | Multiply each element |
| Dot Product | u·v = Σᵢ uᵢ·vᵢ | Sum of products |
| Matrix Multiplication | (AB)ᵢⱼ = Σₖ Aᵢₖ·Bₖⱼ | Row-column product |
| Transpose | (Aᵀ)ᵢⱼ = Aⱼᵢ | Swap rows and columns |

### Eigenvalues and Eigenvectors

**Definition**: For a square matrix A, λ is an eigenvalue and v is an eigenvector if:
```
A·v = λ·v
```

**Applications**:
- PCA: Eigenvectors of covariance matrix
- Dimensionality reduction
- Matrix decomposition
- Stability analysis

### Singular Value Decomposition (SVD)

**Definition**: Any matrix A can be decomposed as:
```
A = U·Σ·Vᵀ
```

Where:
- U: Left singular vectors (orthogonal)
- Σ: Diagonal matrix of singular values
- V: Right singular vectors (orthogonal)

**Applications**:
- PCA (via SVD)
- Matrix approximation
- Dimensionality reduction
- Collaborative filtering

---

## 2. Calculus

### Derivatives

**Basic Derivatives**:
| Function | Derivative |
|----------|------------|
| f(x) = xⁿ | f'(x) = n·xⁿ⁻¹ |
| f(x) = eˣ | f'(x) = eˣ |
| f(x) = ln(x) | f'(x) = 1/x |
| f(x) = sin(x) | f'(x) = cos(x) |
| f(x) = cos(x) | f'(x) = -sin(x) |

**Chain Rule**: If y = f(g(x)), then:
```
dy/dx = f'(g(x)) · g'(x)
```

**Applications**:
- Gradient descent
- Backpropagation
- Optimization
- Model training

### Gradients

**Definition**: The gradient of a function f(x₁, x₂, ..., xₙ) is:
```
∇f = [∂f/∂x₁, ∂f/∂x₂, ..., ∂f/∂xₙ]
```

**Applications**:
- Optimizing loss functions
- Training neural networks
- Finding minima/maxima
- Gradient descent algorithms

### Partial Derivatives

**Definition**: Derivative of a function with respect to one variable, holding others constant.

**Applications**:
- Multi-variable optimization
- Backpropagation in neural networks
- Gradient calculation

---

## 3. Probability and Statistics

### Probability Fundamentals

**Basic Probability**:
- **P(A)**: Probability of event A
- **P(A|B)**: Conditional probability of A given B
- **P(A∩B)**: Joint probability of A and B

**Bayes' Theorem**:
```
P(A|B) = P(B|A)·P(A) / P(B)
```

**Key Distributions**:

| Distribution | Parameters | Support | Use Case |
|--------------|------------|---------|----------|
| Normal (Gaussian) | μ, σ | (-∞, ∞) | Many natural phenomena |
| Bernoulli | p | {0, 1} | Binary classification |
| Binomial | n, p | {0, 1, ..., n} | Counting successes |
| Poisson | λ | {0, 1, 2, ...} | Count events |
| Exponential | λ | [0, ∞) | Waiting times |

### Statistical Measures

**Central Tendency**:
| Measure | Formula | Use Case |
|---------|---------|----------|
| Mean | μ = (1/n)Σᵢ xᵢ | Symmetric distributions |
| Median | Middle value | Skewed distributions |
| Mode | Most frequent | Categorical data |

**Dispersion**:
| Measure | Formula | Use Case |
|---------|---------|----------|
| Variance | σ² = (1/n)Σᵢ (xᵢ - μ)² | Spread of data |
| Standard Deviation | σ = √σ² | Interpretable spread |
| IQR | Q₃ - Q₁ | Robust spread |

### Hypothesis Testing

**Null Hypothesis (H₀)**: Default assumption (no effect)
**Alternative Hypothesis (H₁)**: What we're testing for

**Common Tests**:

| Test | Use | Distribution |
|------|-----|--------------|
| t-test | Comparing means | t-distribution |
| Chi-square | Categorical association | χ²-distribution |
| ANOVA | Comparing multiple means | F-distribution |
| Mann-Whitney | Non-parametric comparison | Rank-based |

**p-value**: Probability of observing results as extreme as observed, assuming H₀ is true.
- p < 0.05: Statistically significant
- p < 0.01: Highly significant

---

## 4. Machine Learning Mathematics

### Loss Functions

**Classification**:

| Loss | Formula | Use Case |
|------|---------|----------|
| Cross-Entropy | L = -Σᵢ yᵢ·log(ŷᵢ) | Multi-class classification |
| Binary Cross-Entropy | L = -[y·log(ŷ) + (1-y)·log(1-ŷ)] | Binary classification |
| Hinge | L = max(0, 1 - y·ŷ) | SVM |
| Focal | L = -α·(1-ŷ)ʸ·log(ŷ) | Imbalanced classification |

**Regression**:

| Loss | Formula | Use Case |
|------|---------|----------|
| MSE | L = (1/n)Σᵢ (yᵢ - ŷᵢ)² | Standard regression |
| MAE | L = (1/n)Σᵢ |yᵢ - ŷᵢ| | Robust regression |
| Huber | L = Σᵢ { (1/2)(yᵢ-ŷᵢ)² if |...| ≤ δ; δ·(|...| - δ/2) else } | Robust regression |
| Log-cosh | L = Σᵢ log(cosh(yᵢ-ŷᵢ)) | Smooth robust regression |

### Regularization

**L1 Regularization (Lasso)**:
```
L = Loss + λ·Σᵢ |wᵢ|
```

**L2 Regularization (Ridge)**:
```
L = Loss + λ·Σᵢ wᵢ²
```

**Elastic Net**:
```
L = Loss + λ₁·Σᵢ |wᵢ| + λ₂·Σᵢ wᵢ²
```

**Purpose**: Prevent overfitting by penalizing large weights.

### Gradient Descent

**Update Rule**:
```
θ_{t+1} = θ_t - η·∇L(θ_t)
```

Where:
- θ: Parameters
- η: Learning rate
- ∇L: Gradient of loss

**Variants**:

| Method | Formula | Pros | Cons |
|--------|---------|------|------|
| SGD | θₜ₊₁ = θₜ - η·∇L(θₜ) | Simple | Noisy |
| Momentum | vₜ = β·vₜ₋₁ + (1-β)·∇L(θₜ); θₜ₊₁ = θₜ - η·vₜ | Faster convergence | More parameters |
| Adam | Adaptive learning rates | Good default | More complex |
| RMSprop | θₜ₊₁ = θₜ - η/√E[g²]·g | Handles sparse gradients | Less common |

### Principal Component Analysis (PCA)

**Goal**: Find directions of maximum variance.

**Steps**:
1. Center the data (subtract mean)
2. Compute covariance matrix: C = (1/n)·XᵀX
3. Find eigenvectors of C
4. Project data onto top k eigenvectors

**Mathematical Formulation**:
```
Y = X·W
```

Where:
- X: Original data (n × p)
- W: Eigenvectors (p × k)
- Y: Transformed data (n × k)

### Support Vector Machines (SVM)

**Objective**: Maximize margin between classes.

**Primal Formulation**:
```
minimize  ½||w||²
subject to yᵢ(w·xᵢ + b) ≥ 1, ∀i
```

**Dual Formulation**:
```
maximize  Σᵢ αᵢ - ½ΣᵢΣⱼ αᵢαⱼyᵢyⱼ(xᵢ·xⱼ)
subject to Σᵢ αᵢyᵢ = 0, αᵢ ≥ 0
```

**Kernel Trick**:
Replace xᵢ·xⱼ with K(xᵢ, xⱼ), where K is a kernel function.
- Linear: K(x,z) = x·z
- Polynomial: K(x,z) = (1 + x·z)ᵈ
- RBF: K(x,z) = exp(-||x-z||²/(2σ²))

### Decision Trees

**Splitting Criteria**:

**Gini Impurity**:
```
Gini(S) = 1 - Σᵢ pᵢ²
```

**Entropy**:
```
Entropy(S) = -Σᵢ pᵢ·log₂(pᵢ)
```

**Information Gain**:
```
IG(S, A) = Entropy(S) - Σᵥ |Sᵥ|/|S| · Entropy(Sᵥ)
```

### Neural Networks

**Forward Propagation**:
```
z^(l) = W^(l)·a^(l-1) + b^(l)
a^(l) = σ(z^(l))
```

**Backpropagation**:
```
δ^(L) = ∇a·σ'(z^(L))
δ^(l) = (W^(l+1))ᵀ·δ^(l+1)·σ'(z^(l))
∂L/∂W^(l) = δ^(l)·(a^(l-1))ᵀ
```

**Activation Functions**:

| Function | Formula | Range |
|----------|---------|-------|
| ReLU | max(0, x) | [0, ∞) |
| Sigmoid | 1/(1+e⁻ˣ) | (0, 1) |
| Tanh | (eˣ-e⁻ˣ)/(eˣ+e⁻ˣ) | (-1, 1) |
| Softmax | eˣⁱ/Σⱼ eˣʲ | (0, 1), sums to 1 |
| Leaky ReLU | max(0.01x, x) | (-∞, ∞) |
| ELU | x if x>0; α(eˣ-1) if x≤0 | (-α, ∞) |

---

## 5. Information Theory

### Entropy

**Definition**: Measure of uncertainty or information content.
```
H(X) = -Σᵢ P(xᵢ)·log₂(P(xᵢ))
```

**Properties**:
- H(X) ≥ 0 (non-negative)
- Maximum when uniform distribution
- Minimum when deterministic

### Cross-Entropy

**Definition**: Measure of difference between two probability distributions.
```
H(P, Q) = -Σᵢ P(xᵢ)·log(Q(xᵢ))
```

**Applications**:
- Classification loss
- KL divergence
- Model training

### KL Divergence

**Definition**: Measure of difference between two distributions.
```
KL(P||Q) = Σᵢ P(xᵢ)·log(P(xᵢ)/Q(xᵢ))
```

**Properties**:
- KL(P||Q) ≥ 0 (non-negative)
- KL(P||Q) = 0 if P = Q
- Not symmetric: KL(P||Q) ≠ KL(Q||P)

### Mutual Information

**Definition**: Measure of mutual dependence between variables.
```
I(X;Y) = H(X) + H(Y) - H(X,Y)
```

**Applications**:
- Feature selection
- Dimensionality reduction
- Unsupervised learning

---

## 6. Optimization Theory

### Convex Optimization

**Definition**: Minimizing convex functions over convex sets.

**Properties**:
- Local minimum = global minimum
- Efficient algorithms exist
- Well-understood theory

**Convex Functions**:
- f(x) = x² (quadratic)
- f(x) = eˣ (exponential)
- f(x) = -log(x) (negative log)

### Non-Convex Optimization

**Definition**: Optimization with non-convex functions.

**Challenges**:
- Local minima
- Saddle points
- Flat regions

**Techniques**:
- Gradient descent
- Momentum
- Adaptive learning rates
- Second-order methods

### Constrained Optimization

**General Form**:
```
minimize f(x)
subject to gᵢ(x) ≤ 0, hⱼ(x) = 0
```

**Lagrangian**:
```
L(x, λ, μ) = f(x) + Σᵢ λᵢ·gᵢ(x) + Σⱼ μⱼ·hⱼ(x)
```

**KKT Conditions**:
1. Stationarity: ∇f(x*) + Σᵢ λᵢ·∇gᵢ(x*) + Σⱼ μⱼ·∇hⱼ(x*) = 0
2. Primal feasibility: gᵢ(x*) ≤ 0, hⱼ(x*) = 0
3. Dual feasibility: λᵢ ≥ 0
4. Complementary slackness: λᵢ·gᵢ(x*) = 0

---

## 7. Distance Metrics

### Euclidean Distance
```
d(x,y) = √(Σᵢ (xᵢ - yᵢ)²)
```

### Manhattan Distance
```
d(x,y) = Σᵢ |xᵢ - yᵢ|
```

### Cosine Similarity
```
cos(θ) = (x·y) / (||x||·||y||)
```

### Mahalanobis Distance
```
d(x,y) = √((x-y)ᵀ·S⁻¹·(x-y))
```

### Minkowski Distance
```
d(x,y) = (Σᵢ |xᵢ - yᵢ|ᵖ)^(1/p)
```

### Hamming Distance
```
d(x,y) = Σᵢ (xᵢ ≠ yᵢ)
```
(Number of positions where values differ)

---

## 8. Model-Specific Mathematics

### Logistic Regression

**Probability**:
```
P(y=1|x) = 1 / (1 + e^-(w·x + b))
```

**Log-odds**:
```
log(P/(1-P)) = w·x + b
```

### Linear Regression

**Model**:
```
y = w·x + b + ε
```

**Least Squares Solution**:
```
w = (XᵀX)⁻¹·Xᵀy
```

### Naive Bayes

**Classification**:
```
P(y|x) ∝ P(y)·∏ᵢ P(xᵢ|y)
```

### K-Means

**Objective**:
```
minimize Σᵢ ||xᵢ - μ_{c(i)}||²
```

**Update**:
```
μₖ = (1/nₖ)·Σ_{i:c(i)=k} xᵢ
```

### Random Forest

**Bagging**: Bootstrap aggregating
```
f̂₊(x) = (1/B)·Σᵦ f̂ᵦ(x)
```

**Feature Randomization**: Random subset of features at each split

### XGBoost

**Objective**:
```
L = Σᵢ l(yᵢ, ŷᵢ) + Σₖ Ω(fₖ)
```

**Regularization**:
```
Ω(f) = γ·T + (1/2)·λ·||w||²
```

**Gradient Boosting**:
```
ŷᵢ⁽ᵗ⁾ = ŷᵢ⁽ᵗ⁻¹⁾ - η·∂L/∂ŷᵢ⁽ᵗ⁻¹⁾
```

---

## 9. Evaluation Metrics Mathematics

### Classification Metrics

**Confusion Matrix**:
```
[[TP, FP],
 [FN, TN]]
```

**Accuracy**:
```
Accuracy = (TP + TN) / (TP + TN + FP + FN)
```

**Precision**:
```
Precision = TP / (TP + FP)
```

**Recall (Sensitivity)**:
```
Recall = TP / (TP + FN)
```

**F1 Score**:
```
F1 = 2·(Precision·Recall) / (Precision + Recall)
```

**ROC-AUC**: Area under ROC curve
```
ROC: TPR vs FPR for all thresholds
```

**PR-AUC**: Area under Precision-Recall curve

### Regression Metrics

**MSE**:
```
MSE = (1/n)·Σᵢ (yᵢ - ŷᵢ)²
```

**RMSE**:
```
RMSE = √MSE
```

**MAE**:
```
MAE = (1/n)·Σᵢ |yᵢ - ŷᵢ|
```

**MAPE**:
```
MAPE = (100/n)·Σᵢ |(yᵢ - ŷᵢ)/yᵢ|
```

**R²**:
```
R² = 1 - Σᵢ(yᵢ - ŷᵢ)² / Σᵢ(yᵢ - ȳ)²
```

**Adjusted R²**:
```
Adj·R² = 1 - (1-R²)·(n-1)/(n-k-1)
```

---

## 10. Ensemble Methods Mathematics

### Bagging

**Basic Idea**: 
```
f̂₊(x) = (1/B)·Σᵦ f̂ᵦ(x)
```

**Variance Reduction**:
```
Var(f̂₊(x)) = ρ·σ² + (1-ρ)/B·σ²
```
Where ρ is the correlation between predictions.

### Boosting

**AdaBoost**:
```
wᵢ⁽ᵗ⁺¹⁾ = wᵢ⁽ᵗ⁾·exp(-α·yᵢ·fᵗ(xᵢ))
```

**Gradient Boosting**:
```
fₜ(x) = fₜ₋₁(x) - η·∇L(fₜ₋₁(x))
```

**Stacking**:
```
f̂(x) = g(f̂₁(x), f̂₂(x), ..., f̂ₖ(x))
```
Where g is a meta-model.

### Voting

**Hard Voting**:
```
f̂(x) = mode(f̂₁(x), f̂₂(x), ..., f̂ₖ(x))
```

**Soft Voting**:
```
f̂(x) = argmax Σᵢ Pᵢ(c|x)
```

---

This appendix provides the mathematical foundation underlying the algorithms and techniques used throughout the series. Understanding these concepts will help you make informed decisions about which algorithms to use and how to interpret their results.
