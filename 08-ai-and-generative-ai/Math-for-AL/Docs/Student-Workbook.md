# STUDENT WORKBOOK
## Mathematics for Machine Learning
### A Pragmatic Engineering Curriculum

---

# 📘 WORKBOOK INTRODUCTION

## How to Use This Workbook

This workbook is designed to accompany the "Mathematics for Machine Learning" series. It contains:

1. **Concept Review**: Summaries of key ideas
2. **Practice Problems**: Exercises to reinforce learning
3. **Code Exercises**: Hands-on coding challenges
4. **Project Sections**: Guided project development
5. **Self-Assessment**: Check your understanding

**For Each Module:**
1. Read the main tutorial content first
2. Complete the concept review questions
3. Work through practice problems
4. Write and test code for coding exercises
5. Build the project component
6. Self-assess using the answer keys

---

# 🧮 PART 1: LINEAR ALGEBRA — WORKBOOK

## Module 1.1: Vectors — Concept Review

### Key Concepts to Remember

```
VECTOR: An ordered list of numbers representing a data point
DIMENSION: Number of components in a vector
DOT PRODUCT: u·v = Σ u_i v_i (measures similarity)
NORM: Magnitude of a vector
L2 Norm: ||v||₂ = √(Σ v_i²)  (Euclidean distance)
L1 Norm: ||v||₁ = Σ|v_i|     (Manhattan distance)
NORMALIZATION: v̂ = v / ||v||₂ (unit vector)
```

### Fill-in-the-Blank Exercises

1. A vector with components [2000, 3, 2] has dimension _______.

2. The dot product of [1, 2, 3] and [4, 5, 6] is _______.

3. The L2 norm of [3, 4] is _______.

4. Normalizing a vector means dividing by its _______.

5. The distance between [1, 1] and [4, 5] is _______.

### True or False

___ 1. Vectors must always have positive components.
___ 2. The dot product of perpendicular vectors is 0.
___ 3. L1 norm is always greater than L2 norm.
___ 4. Normalization changes the direction of a vector.
___ 5. The zero vector has norm 0.

### Short Answer

6. Explain why vectors are important in machine learning.

_________________________________________________________
_________________________________________________________
_________________________________________________________

7. What is the difference between L1 and L2 norms?

_________________________________________________________
_________________________________________________________
_________________________________________________________

---

## Module 1.1: Vectors — Practice Problems

### Problem 1: Vector Operations

Given vectors u = [2, -1, 3] and v = [1, 4, -2]:

a) Compute u + v: _____________
b) Compute u - v: _____________
c) Compute 3u: _____________
d) Compute u · v (dot product): _____________
e) Compute ||u||₂: _____________
f) Compute ||v||₁: _____________

### Problem 2: Vector Similarity

Three documents are represented as vectors of word counts:
- Doc A: [5, 2, 1, 0] (sports, game, team, politics)
- Doc B: [0, 1, 0, 4] (sports, game, team, politics)
- Doc C: [4, 3, 2, 0] (sports, game, team, politics)

a) Which two documents are most similar? (Use dot product)
_________________________________________________________

b) Compute the cosine similarity between Doc A and Doc B.
_________________________________________________________

### Problem 3: Distance Calculation

Points in 3D space:
P₁ = [1, 2, 3]
P₂ = [4, 5, 6]
P₃ = [1, 1, 1]

a) Compute the Euclidean distance between P₁ and P₂: _____________
b) Compute the Euclidean distance between P₁ and P₃: _____________
c) Which points are closer together? _____________

---

## Module 1.2: Matrices — Practice Problems

### Problem 4: Matrix Basics

Given matrix A = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]:

a) Shape of A: _____________
b) Element A[1, 2]: _____________ (row 1, column 2)
c) A^T (transpose): _____________
d) Is A symmetric? _____________

### Problem 5: Matrix Multiplication

Compute:
A = [[1, 2], [3, 4]]
B = [[5, 6], [7, 8]]

a) A @ B = _____________
b) B @ A = _____________
c) Is A @ B = B @ A? _____________

### Problem 6: Special Matrices

a) Write a 3×3 identity matrix: _____________
b) Write a 3×3 diagonal matrix with diagonal [2, 4, 6]: _____________
c) Does a 2×3 matrix have an inverse? _____________

---

## Module 1.3: SVD and PCA — Practice Problems

### Problem 7: Understanding SVD

Given data matrix X = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]:

a) Center the data (subtract column means): _____________
b) What is the rank of X? _____________
c) In SVD, what do the singular values represent? _____________

### Problem 8: PCA

Consider data points: [1, 1], [2, 2], [3, 3], [4, 4]

a) What is the direction of maximum variance? _____________
b) After PCA with 1 component, what is the projected data? _____________
c) What is the explained variance ratio? _____________

---

# 📐 PART 2: CALCULUS — WORKBOOK

## Module 2.1: Derivatives — Concept Review

### Key Concepts to Remember

```
DERIVATIVE: Rate of change of a function
GRADIENT: Vector of partial derivatives
∂f/∂x_i: Partial derivative with respect to x_i
CHAIN RULE: d/dx(f(g(x))) = f'(g(x))·g'(x)
```

### Derivative Practice

Compute the derivatives:

1. d/dx(x⁴) = _____________

2. d/dx(e^(3x)) = _____________

3. d/dx(ln(x²)) = _____________

4. d/dx(sin(2x)) = _____________

5. d/dx(σ(x)) where σ(x) = 1/(1+e^(-x)) = _____________

### Gradient Practice

6. For f(x, y) = x² + y², ∇f = _____________

7. For f(x, y) = 3x + 4y, ∇f = _____________

8. For f(x, y) = xy, ∇f = _____________

---

## Module 2.2: Optimization — Practice Problems

### Problem 9: Gradient Descent

For f(w) = w² (with w₀ = 5, learning rate = 0.1):

a) What is the gradient at w₀? _____________
b) What is w₁ after one update? _____________
c) What is w₂ after two updates? _____________
d) What is the final value of w after enough iterations? _____________

### Problem 10: Learning Rate Effects

For f(w) = (w - 3)², starting at w₀ = 0:

a) If α = 0.1, what is w₁? _____________
b) If α = 1.0, what is w₁? _____________
c) If α = 2.0, what is w₁? _____________
d) Which learning rate causes divergence? _____________

### Problem 11: Optimizer Comparison

For f(w) = w², compare:

a) Batch GD (all data): update rule = _____________
b) SGD (one sample): update rule = _____________
c) Mini-batch GD: update rule = _____________

---

## Module 2.3: Backpropagation — Practice Problems

### Problem 12: Chain Rule

Given: y = f(g(x)) where f(z) = z² and g(x) = x + 2

a) Compute dy/dx using the chain rule: _____________

b) Evaluate at x = 3: _____________

### Problem 13: Simple Neural Network

Consider a network with:
- Input: x = [1, 1]
- Layer 1: W₁ = [[2, 3], [4, 5]], b₁ = [1, 1], activation = ReLU
- Output layer: W₂ = [[1, 2]], b₂ = [0], activation = linear

a) Forward pass: z₁ = _____________
a₁ = ReLU(z₁) = _____________
ŷ = W₂ @ a₁ + b₂ = _____________

b) If loss = (ŷ - y)² and y = 0, what is ∂L/∂ŷ? _____________

c) What is ∂L/∂W₂? _____________

---

### Problem 14: Backpropagation Step-by-Step

Layer 1: y₁ = W₁x + b₁, a₁ = σ(y₁)
Layer 2: y₂ = W₂a₁ + b₂, a₂ = σ(y₂)
Loss: L = (a₂ - y)²

Compute the gradients:
a) δ₂ = ∂L/∂y₂ = _____________
b) δ₁ = ∂L/∂y₁ = _____________
c) ∂L/∂W₂ = _____________
d) ∂L/∂W₁ = _____________

---

# 🎲 PART 3: PROBABILITY — WORKBOOK

## Module 3.1: Probability Theory — Practice Problems

### Problem 15: Basic Probability

A dataset has:
- 60% positive examples
- 40% negative examples
- 80% of positive examples are correctly classified
- 70% of negative examples are correctly classified

a) P(Positive) = _____________
b) P(Correct | Positive) = _____________
c) P(Correct and Positive) = _____________
d) P(Correct) = _____________
e) P(Positive | Correct) = _____________

### Problem 16: Bayes' Theorem

Medical test:
- Disease prevalence: 1% (P(Disease) = 0.01)
- Test sensitivity: 95% (P(Positive | Disease) = 0.95)
- Test specificity: 90% (P(Negative | No Disease) = 0.90)

a) P(Positive) = _____________

b) P(Disease | Positive) = _____________

c) If a patient tests positive, what is the probability they have the disease? _____________

### Problem 17: Distributions

a) A Bernoulli distribution with p=0.7 has mean _____________ and variance _____________

b) A Binomial distribution with n=10, p=0.3 has mean _____________ and variance _____________

c) A Gaussian distribution N(μ=5, σ=2) has:
   - Mean: _____________
   - Variance: _____________
   - 68% of data in range: _____________
   - 95% of data in range: _____________

---

## Module 3.2: Naive Bayes — Practice Problems

### Problem 18: Naive Bayes Classification

Classify a document using the following word probabilities:
- P(Spam) = 0.4, P(Ham) = 0.6
- P("free" | Spam) = 0.7, P("free" | Ham) = 0.1
- P("prize" | Spam) = 0.5, P("prize" | Ham) = 0.05

Document has words ["free", "prize"]:

a) P(Spam | "free", "prize") = _____________
b) P(Ham | "free", "prize") = _____________
c) Classification: _____________

### Problem 19: Gaussian Naive Bayes

Two classes:
Class 0: Feature ~ N(μ=0, σ=1)
Class 1: Feature ~ N(μ=5, σ=1)
Prior: P(Class 0) = P(Class 1) = 0.5

a) P(Class 0 | x=0) = _____________
b) P(Class 1 | x=0) = _____________
c) P(Class 0 | x=3) = _____________
d) P(Class 1 | x=3) = _____________

---

## Module 3.3: Model Evaluation — Practice Problems

### Problem 20: Confusion Matrix

Given predictions and actuals:
Actual: [1, 0, 1, 1, 0, 0, 1]
Predicted: [1, 0, 1, 0, 1, 0, 1]

a) TP = _____________
b) FP = _____________
c) FN = _____________
d) TN = _____________
e) Accuracy = _____________
f) Precision = _____________
g) Recall = _____________
h) F1 Score = _____________

### Problem 21: Regression Metrics

Predictions: [2, 4, 6, 8, 10]
Actuals: [1, 3, 5, 7, 9]

a) MSE = _____________
b) RMSE = _____________
c) MAE = _____________
d) R² = _____________

### Problem 22: Bias-Variance

A model has:
- Training error: 0.01
- Validation error: 0.30

a) Is this model overfitting or underfitting? _____________

b) What is the gap? _____________

c) What should you do to improve? _____________

---

# 💻 PART 4: NUMERICAL METHODS — WORKBOOK

## Module 4.1: Numerical Stability — Practice Problems

### Problem 23: Safe Operations

a) What is exp(1000) in Python? _____________
b) What is the problem with computing softmax with exp(1000)? _____________
c) How does the log-sum-exp trick solve this? _____________

### Problem 24: Stable Softmax

Compute stable softmax for:
x = [100, 101, 102, 103]

a) Unstable softmax (direct exp) would cause: _____________
b) Stable softmax steps:
   - max(x) = _____________
   - x - max = _____________
   - exp(x - max) = _____________
   - sum = _____________
   - softmax = _____________

### Problem 25: Gradient Clipping

Given gradient g = [100, 200, 300]:

a) L2 norm of g = _____________
b) If max_norm = 100, what is the clipped gradient? _____________
c) What is the L2 norm of the clipped gradient? _____________

---

## Module 4.2: Performance Optimization — Practice Problems

### Problem 26: Vectorization

a) Write Python code to compute the sum of squares of 1,000,000 numbers USING a loop:
_________________________________________________________

b) Write code using NumPy vectorization:
_________________________________________________________

c) Which is faster? _____________

### Problem 27: Memory Efficiency

Given a matrix X of shape (10000, 100):

a) How much memory does X require (float64)? _____________
b) If using float32, how much memory? _____________
c) Why use float32 instead of float64? _____________

---

# 🏗️ PROJECT WORKBOOK

## Project: Build a Complete ML System

### Phase 1: Linear Algebra Component

**Task: Implement Vector and Matrix Classes**

```python
# Write your Vector class here
class Vector:
    def __init__(self, data):
        # Initialize vector
        pass
    
    def dot(self, other):
        # Compute dot product
        pass
    
    def norm(self, p=2):
        # Compute p-norm
        pass
```

**Checkpoint Questions:**
1. Why did you choose this data structure? _____________
2. What edge cases did you handle? _____________
3. How did you test your implementation? _____________

### Phase 2: Calculus Component

**Task: Implement Gradient Descent**

```python
def gradient_descent(f, grad_f, initial_w, learning_rate=0.01, epochs=100):
    # Implement gradient descent
    pass
```

**Checkpoint Questions:**
1. What happens if learning rate is too high? _____________
2. What happens if learning rate is too low? _____________
3. How do you know when to stop? _____________

### Phase 3: Probability Component

**Task: Implement Gaussian Naive Bayes**

```python
class GaussianNaiveBayes:
    def fit(self, X, y):
        # Compute priors, means, and variances
        pass
    
    def predict(self, X):
        # Classify new data
        pass
```

**Checkpoint Questions:**
1. Why does Naive Bayes work despite independence assumption? _____________
2. How do you handle features with zero variance? _____________
3. How do you evaluate classifier performance? _____________

### Phase 4: Complete Pipeline

**Task: Build End-to-End Pipeline**

```python
class MLPipeline:
    def __init__(self, config):
        # Initialize pipeline
        pass
    
    def run(self, X, y):
        # Execute complete pipeline
        # 1. Preprocess data
        # 2. Split data
        # 3. Train model
        # 4. Evaluate model
        pass
```

**Checkpoint Questions:**
1. What are the main components of your pipeline? _____________
2. How do you handle missing data? _____________
3. How do you monitor model performance? _____________

---

# 📝 FINAL PROJECT CHECKLIST

## Project Requirements

### Data Processing
- [ ] Load data from CSV
- [ ] Handle missing values
- [ ] Scale features
- [ ] Split into train/validation/test
- [ ] Add bias term

### Model Implementation
- [ ] Linear regression (from scratch)
- [ ] Logistic regression (from scratch)
- [ ] Neural network with backpropagation
- [ ] Naive Bayes classifier
- [ ] PCA implementation

### Model Training
- [ ] Gradient descent (batch, SGD, mini-batch)
- [ ] Learning rate scheduling
- [ ] Momentum or Adam optimizer
- [ ] Early stopping
- [ ] Cross-validation

### Model Evaluation
- [ ] Accuracy
- [ ] Precision, Recall, F1
- [ ] MSE, RMSE, R²
- [ ] Confusion matrix
- [ ] Learning curves
- [ ] ROC curve and AUC

### Production Readiness
- [ ] Documentation (docstrings, comments)
- [ ] Unit tests
- [ ] Error handling
- [ ] Configuration management
- [ ] Logging
- [ ] API server
- [ ] Docker container
- [ ] README

### Project Documentation
- [ ] Problem statement
- [ ] Data description
- [ ] Model architecture
- [ ] Results and analysis
- [ ] Conclusions
- [ ] Future work

---

# 🧠 SELF-ASSESSMENT

## Check Your Understanding

### Linear Algebra
- [ ] Can you explain what a vector is and how it represents data?
- [ ] Can you compute dot products, norms, and distances?
- [ ] Can you multiply matrices and understand the dimensions?
- [ ] Can you explain what SVD does and why it's useful?
- [ ] Can you implement PCA from scratch?

### Calculus
- [ ] Can you compute derivatives of common functions?
- [ ] Can you compute gradients of multivariable functions?
- [ ] Can you explain gradient descent and implement it?
- [ ] Can you explain backpropagation and the chain rule?
- [ ] Can you train a neural network from scratch?

### Probability
- [ ] Can you explain Bayes' Theorem?
- [ ] Can you implement Naive Bayes?
- [ ] Can you compute MLE for Gaussian parameters?
- [ ] Can you explain the bias-variance tradeoff?
- [ ] Can you interpret confusion matrices and metrics?

### Numerical Methods
- [ ] Can you implement stable softmax?
- [ ] Can you handle numerical stability issues?
- [ ] Can you implement gradient clipping?
- [ ] Can you vectorize operations for performance?
- [ ] Can you build a complete ML pipeline?

---

# 🔑 ANSWER KEY — PRACTICE PROBLEMS

## Module 1.1 Answers

**Fill-in-the-Blank:**
1. 3
2. 32 (1×4 + 2×5 + 3×6 = 4+10+18 = 32)
3. 5 (√(9+16) = √25 = 5)
4. L2 norm
5. 5 (√((4-1)² + (5-1)²) = √(9+16) = 5)

**True/False:**
1. False
2. True
3. False
4. False
5. True

**Problem 1:**
a) [3, 3, 1]
b) [1, -5, 5]
c) [6, -3, 9]
d) 2×1 + (-1)×4 + 3×(-2) = 2-4-6 = -8
e) √(4+1+9) = √14 ≈ 3.742
f) |1|+|4|+|-2| = 7

**Problem 2:**
a) Doc A and Doc C (dot product: 5×4 + 2×3 + 1×2 = 20+6+2 = 28)
b) cos_sim = (5×0 + 2×1 + 1×0 + 0×4) / (||A||₂ × ||B||₂) = 2 / (√30 × √17) ≈ 0.089

**Problem 3:**
a) √((4-1)² + (5-2)² + (6-3)²) = √(9+9+9) = √27 ≈ 5.196
b) √((1-1)² + (1-2)² + (1-3)²) = √(0+1+4) = √5 ≈ 2.236
c) P₁ and P₃

---

## Module 1.2 Answers

**Problem 4:**
a) (3, 3)
b) A[1, 2] = 6
c) A^T = [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
d) No (A ≠ A^T)

**Problem 5:**
a) A @ B = [[19, 22], [43, 50]]
b) B @ A = [[23, 34], [31, 46]]
c) No

**Problem 6:**
a) [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
b) [[2, 0, 0], [0, 4, 0], [0, 0, 6]]
c) No (only square matrices can have inverses)

---

## Module 1.3 Answers

**Problem 7:**
a) Column means: [4, 5, 6], centered: [[-3, -3, -3], [0, 0, 0], [3, 3, 3]]
b) Rank = 1 (all columns are multiples of each other)
c) The importance of each component (variance explained)

**Problem 8:**
a) Direction (1, 1) (diagonal)
b) [√2, 2√2, 3√2, 4√2]
c) 100% (since all points lie on a line)

---

## Module 2.1 Answers

1. 4x³
2. 3e^(3x)
3. 2/x
4. 2cos(2x)
5. σ(x)(1-σ(x))
6. [2x, 2y]
7. [3, 4]
8. [y, x]

---

## Module 2.2 Answers

**Problem 9:**
a) ∇f = 10
b) w₁ = 5 - 0.1×10 = 4
c) w₂ = 4 - 0.1×8 = 3.2
d) w = 0

**Problem 10:**
a) w₁ = 0.3
b) w₁ = 3
c) w₁ = 6
d) α = 2.0 (overshoots the minimum)

**Problem 11:**
a) w = w - α(1/n)Σ∇L_i
b) w = w - α∇L_i
c) w = w - α(1/b)Σ_{i∈batch}∇L_i

---

## Module 2.3 Answers

**Problem 12:**
a) 2(x+2)
b) 10

**Problem 13:**
a) z₁ = [2×1 + 3×1 + 1, 4×1 + 5×1 + 1] = [6, 10]
a₁ = [6, 10] (ReLU)
ŷ = 1×6 + 2×10 + 0 = 26
b) ∂L/∂ŷ = 2(ŷ - y) = 2(26 - 0) = 52
c) ∂L/∂W₂ = ∂L/∂ŷ × a₁^T = 52 × [6, 10] = [312, 520]

**Problem 14:**
a) δ₂ = 2(a₂ - y)σ'(y₂)
b) δ₁ = W₂^T δ₂ σ'(y₁)
c) ∂L/∂W₂ = δ₂ a₁^T
d) ∂L/∂W₁ = δ₁ x^T

---

## Module 3.1 Answers

**Problem 15:**
a) 0.6
b) 0.8
c) 0.6 × 0.8 = 0.48
d) 0.48 + 0.4 × 0.7 = 0.48 + 0.28 = 0.76
e) 0.48 / 0.76 ≈ 0.632

**Problem 16:**
a) P(Positive) = 0.01×0.95 + 0.99×0.10 = 0.0095 + 0.099 = 0.1085
b) P(Disease|Positive) = 0.0095/0.1085 ≈ 0.0876
c) ≈8.76%

**Problem 17:**
a) mean=0.7, variance=0.21
b) mean=3, variance=2.1
c) mean=5, variance=4, range: (3, 7), range: (1, 9)

---

## Module 3.2 Answers

**Problem 18:**
a) P(Spam|words) ∝ 0.4×0.7×0.5 = 0.14
b) P(Ham|words) ∝ 0.6×0.1×0.05 = 0.003
c) P(Spam) = 0.14/(0.14+0.003) ≈ 0.979
   P(Ham) = 0.003/(0.14+0.003) ≈ 0.021
   Classification: SPAM

**Problem 19:**
a) P(C0|x=0) = 0.5 × f_N(0|0,1) / [0.5×f_N(0|0,1) + 0.5×f_N(0|5,1)]
   = 0.5×0.399 / [0.5×0.399 + 0.5×0.0008] ≈ 0.998
b) P(C1|x=0) ≈ 0.002
c) P(C0|x=3) ≈ 0.002
d) P(C1|x=3) ≈ 0.998

---

## Module 3.3 Answers

**Problem 20:**
a) TP = 3 (indices 0, 2, 6)
b) FP = 1 (index 3)
c) FN = 1 (index 4)
d) TN = 2 (indices 1, 5)
e) Accuracy = 5/7 ≈ 0.714
f) Precision = 3/4 = 0.75
g) Recall = 3/4 = 0.75
h) F1 = 2×0.75×0.75/(0.75+0.75) = 0.75

**Problem 21:**
a) MSE = ((2-1)² + (4-3)² + (6-5)² + (8-7)² + (10-9)²)/5 = 1
b) RMSE = 1
c) MAE = 1
d) R² = 1 - SSE/SST = 1 - 5/(10) = 0.5

**Problem 22:**
a) Overfitting (large gap between train and validation)
b) Gap = 0.29
c) Regularization, more data, simpler model, early stopping

---

## Module 4.1 Answers

**Problem 23:**
a) `inf` (overflow)
b) exp(1000) returns inf, leading to NaN
c) Subtract max(x) before exp: exp(x - max(x)) stays in safe range

**Problem 24:**
a) Overflow/NaN
b) max = 103, x-max = [-3, -2, -1, 0]
   exp = [0.0498, 0.1353, 0.3679, 1.0]
   sum = 1.553
   softmax = [0.032, 0.087, 0.237, 0.644]

**Problem 25:**
a) ||g||₂ = √(10000+40000+90000) = √140000 ≈ 374.17
b) clipped = g × 100/374.17 = [26.73, 53.45, 80.18]
c) ||clipped||₂ = 100

---

## Module 4.2 Answers

**Problem 26:**
a) ```python
sum = 0
for i in range(1000000):
    sum += i*i
```
b) ```python
sum_squares = np.sum(np.arange(1000000)**2)
```
c) Vectorized (NumPy) is much faster

**Problem 27:**
a) 10000×100×8 = 8,000,000 bytes ≈ 7.63 MB
b) 10000×100×4 = 4,000,000 bytes ≈ 3.81 MB
c) Saves memory, faster, sufficient precision for many tasks

---

**📚 END OF WORKBOOK**

---

*"Understanding mathematics is not about memorizing formulas — it's about understanding the patterns behind the numbers."*
