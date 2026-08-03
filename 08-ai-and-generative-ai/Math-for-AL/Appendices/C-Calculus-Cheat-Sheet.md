# Appendix C: Calculus Cheat Sheet

## Quick Reference for Derivatives, Gradients, and Optimization

### The Target

This appendix provides a comprehensive, quick-reference cheat sheet for all calculus concepts used in machine learning. It's designed to be a practical reference for understanding gradients, implementing optimization algorithms, and debugging neural networks.

### The Concept

Calculus is the engine of machine learning—it tells us how to improve our models. This cheat sheet puts all the essential derivatives, gradients, and optimization rules in one place.

**Why this matters**: When you're implementing backpropagation, debugging gradient descent, or reading optimization papers, you need quick access to these formulas. This reference helps you:
- Compute gradients correctly
- Understand optimization algorithms
- Debug vanishing/exploding gradients
- Implement custom loss functions

### Differentiation Rules

#### Basic Rules

| Rule | Formula | Example |
|------|---------|---------|
| Constant | `d/dx(c) = 0` | `d/dx(5) = 0` |
| Power | `d/dx(x^n) = n·x^{n-1}` | `d/dx(x³) = 3x²` |
| Exponential | `d/dx(e^x) = e^x` | `d/dx(e^{2x}) = 2e^{2x}` |
| Natural Log | `d/dx(ln(x)) = 1/x` | `d/dx(ln(x²)) = 2/x` |
| Log base a | `d/dx(log_a(x)) = 1/(x·ln(a))` | `d/dx(log₂(x)) = 1/(x·ln(2))` |
| Sine | `d/dx(sin(x)) = cos(x)` | |
| Cosine | `d/dx(cos(x)) = -sin(x)` | |
| Tangent | `d/dx(tan(x)) = sec²(x)` | |

#### Chain Rule

| Rule | Formula | Example |
|------|---------|---------|
| Chain Rule | `dy/dx = dy/du · du/dx` | `d/dx(sin(x²)) = cos(x²)·2x` |
| Power Chain | `d/dx(f(x)^n) = n·f(x)^{n-1}·f'(x)` | `d/dx((x²+1)³) = 3(x²+1)²·2x` |
| Exponential Chain | `d/dx(e^{f(x)}) = e^{f(x)}·f'(x)` | `d/dx(e^{x²}) = e^{x²}·2x` |
| Log Chain | `d/dx(ln(f(x))) = f'(x)/f(x)` | `d/dx(ln(x²+1)) = 2x/(x²+1)` |

#### Product and Quotient Rules

| Rule | Formula |
|------|---------|
| Product | `d/dx(f·g) = f'·g + f·g'` |
| Quotient | `d/dx(f/g) = (f'·g - f·g')/g²` |

### Multivariable Calculus

#### Partial Derivatives

| Concept | Notation | Formula |
|---------|----------|---------|
| Partial derivative | `∂f/∂x_i` | Derivative w.r.t one variable, holding others constant |
| Gradient | `∇f = [∂f/∂x₁, ∂f/∂x₂, ..., ∂f/∂x_n]` | Vector of all partial derivatives |
| Directional derivative | `∇f · v` | Rate of change in direction v |
| Jacobian | `J = [∂f_i/∂x_j]` | Matrix of all first derivatives |
| Hessian | `H_{ij} = ∂²f/∂x_i∂x_j` | Matrix of second derivatives |

#### Common Multivariable Gradients

| Function f(x) | Gradient ∇f(x) |
|---------------|----------------|
| `a^T x` | `a` |
| `x^T a` | `a` |
| `x^T x` | `2x` |
| `x^T A x` (A symmetric) | `2Ax` |
| `x^T A x` (A general) | `(A + A^T)x` |
| `(Ax - b)^T(Ax - b)` | `2A^T(Ax - b)` |
| `a^T x + b` | `a` |
| `(1/2)||x||²` | `x` |
| `||x||₂` | `x/||x||₂` (x ≠ 0) |
| `||x||₁` | `sign(x)` |
| `exp(x)` (element-wise) | `exp(x)` |
| `log(x)` (element-wise) | `1/x` |

### Gradient Descent

#### Basic Gradient Descent

| Algorithm | Update Rule | Notes |
|-----------|-------------|-------|
| Batch GD | `θ = θ - α∇L(θ)` | Uses all data |
| SGD | `θ = θ - α∇L_i(θ)` | Uses one sample |
| Mini-batch GD | `θ = θ - α(1/b)Σ∇L_i(θ)` | Uses batch of size b |

#### Advanced Optimizers

| Algorithm | Update Rule | Key Idea |
|-----------|-------------|----------|
| Momentum | `v = βv + α∇L`; `θ = θ - v` | Accelerates through flat regions |
| Nesterov | `v = βv + α∇L(θ-βv)`; `θ = θ - v` | Look-ahead momentum |
| AdaGrad | `g = Σ∇L²`; `θ = θ - α/√(g+ε)∇L` | Adaptive per-parameter |
| RMSProp | `g = βg + (1-β)∇L²`; `θ = θ - α/√(g+ε)∇L` | Like AdaGrad with decay |
| Adam | `m = β₁m + (1-β₁)g`; `v = β₂v + (1-β₂)g²`; `m̂=m/(1-β₁^t)`, `v̂=v/(1-β₂^t)`; `θ = θ - α m̂/(√v̂+ε)` | Momentum + RMSProp |

#### Learning Rate Schedules

| Schedule | Formula | Use Case |
|----------|---------|----------|
| Constant | `α_t = α₀` | Simple tasks |
| Exponential decay | `α_t = α₀·e^{-kt}` | General purpose |
| Step decay | `α_t = α₀·γ^{⌊t/T⌋}` | Drop at intervals |
| Inverse decay | `α_t = α₀/(1 + k·t)` | Gradual decay |
| Cosine decay | `α_t = α₀/2(1 + cos(πt/T))` | Cyclical |
| Warmup | `α_t = α₀·min(1, t/T_w)` | Start small |

### Backpropagation

#### Chain Rule for Neural Networks

For a network with layers:
```
a⁽¹⁾ = g₁(z⁽¹⁾), z⁽¹⁾ = W⁽¹⁾x + b⁽¹⁾
a⁽²⁾ = g₂(z⁽²⁾), z⁽²⁾ = W⁽²⁾a⁽¹⁾ + b⁽²⁾
...
ŷ = a⁽ᴸ⁾
```

Backpropagation computes:
```
δ⁽ᴸ⁾ = ∂L/∂z⁽ᴸ⁾ = ∂L/∂a⁽ᴸ⁾ · g'_L(z⁽ᴸ⁾)
δ⁽ˡ⁾ = (W⁽ˡ⁺¹⁾)ᵀδ⁽ˡ⁺¹⁾ · g'_l(z⁽ˡ⁾)
∂L/∂W⁽ˡ⁾ = δ⁽ˡ⁾(a⁽ˡ⁻¹⁾)ᵀ
∂L/∂b⁽ˡ⁾ = δ⁽ˡ⁾
```

#### Activation Function Derivatives

| Function | f(x) | f'(x) | ML Use |
|----------|------|-------|--------|
| Sigmoid | `1/(1+e^{-x})` | `f(x)·(1-f(x))` | Binary classification |
| Tanh | `(e^x-e^{-x})/(e^x+e^{-x})` | `1-f(x)²` | Hidden layers |
| ReLU | `max(0, x)` | `1 if x>0 else 0` | Deep networks |
| Leaky ReLU | `max(αx, x)` | `1 if x>0 else α` | Fix dying ReLU |
| ELU | `x if x>0 else α(e^x-1)` | `1 if x>0 else f(x)+α` | Smooth ReLU |
| Swish | `x·sigmoid(βx)` | `f(x) + β·sigmoid(βx)·(1 - sigmoid(βx))` | Modern activations |
| Softmax | `e^{x_i}/Σe^{x_j}` | `f_i(δ_{ij}-f_j)` | Multi-class |

### Loss Functions and Derivatives

#### Regression Losses

| Loss | Formula | Derivative | Use Case |
|------|---------|------------|----------|
| MSE | `(1/n)Σ(y_i - ŷ_i)²` | `(2/n)(ŷ_i - y_i)` | Standard regression |
| MAE | `(1/n)Σ|y_i - ŷ_i|` | `(1/n)sign(ŷ_i - y_i)` | Robust regression |
| Huber | `(1/2)(y-ŷ)² if |d|<δ else δ(|d|-δ/2)` | Mixed MSE/MAE | Robust regression |
| Log-Cosh | `Σ log(cosh(y_i - ŷ_i))` | `tanh(y_i - ŷ_i)` | Smooth MAE |

#### Classification Losses

| Loss | Formula | Derivative | Use Case |
|------|---------|------------|----------|
| BCE | `-Σ[y_i log(ŷ_i) + (1-y_i)log(1-ŷ_i)]` | `ŷ_i - y_i` | Binary classification |
| Cross-Entropy | `-Σ y_i log(ŷ_i)` | `ŷ_i - y_i` (with softmax) | Multi-class |
| Hinge | `Σ max(0, 1 - y_iŷ_i)` | `-y_i if y_iŷ_i < 1 else 0` | SVM |
| Focal | `-Σ (1-ŷ_i)^γ y_i log(ŷ_i)` | Complex | Imbalanced data |
| KLD | `Σ y_i log(y_i/ŷ_i)` | `-y_i/ŷ_i` | Distribution matching |

### Numerical Differentiation

#### Finite Difference Methods

| Method | Formula | Accuracy |
|--------|---------|----------|
| Forward | `f'(x) ≈ (f(x+h) - f(x))/h` | O(h) |
| Backward | `f'(x) ≈ (f(x) - f(x-h))/h` | O(h) |
| Central | `f'(x) ≈ (f(x+h) - f(x-h))/(2h)` | O(h²) |
| Second derivative | `f''(x) ≈ (f(x+h) - 2f(x) + f(x-h))/h²` | O(h²) |
| Gradients | `∂f/∂x_i ≈ (f(x+he_i) - f(x-he_i))/(2h)` | O(h²) |

#### Choosing Step Size

| Scenario | Recommended h |
|----------|---------------|
| Double precision | `1e-7` |
| Single precision | `1e-5` |
| Noisy functions | `1e-3` to `1e-2` |
| Well-behaved | `1e-8` to `1e-6` |

### Common ML Gradient Patterns

#### Linear Regression

```
Forward:  ŷ = Xw + b
Loss:     L = (1/2n)||ŷ - y||²
Gradient: ∂L/∂w = (1/n)X^T(ŷ - y)
         ∂L/∂b = (1/n)Σ(ŷ_i - y_i)
```

#### Logistic Regression

```
Forward:  p = σ(Xw + b)
Loss:     L = -[y log(p) + (1-y)log(1-p)]
Gradient: ∂L/∂w = X^T(p - y)
         ∂L/∂b = Σ(p_i - y_i)
```

#### Neural Network Backpropagation (Dense Layer)

```
Forward:  z = W^T a + b
          a_out = g(z)

Backward: δ = ∂L/∂z = g'(z) ⊙ ∂L/∂a_out
          ∂L/∂W = a δ^T
          ∂L/∂b = δ
          ∂L/∂a = W δ
```

### Optimization Diagnostics

#### Convergence Signs

| Sign | Meaning | Action |
|------|---------|--------|
| Loss decreasing | Good | Continue |
| Loss oscillating | Learning rate too high | Reduce α |
| Loss flat | Learning rate too low | Increase α |
| Loss increasing | Diverging | Reduce α significantly |
| NaN loss | Numerical issue | Reduce α, check data |

#### Gradient Diagnostics

| Issue | Symptom | Fix |
|-------|---------|-----|
| Vanishing gradients | Loss not decreasing | Use ReLU, batch norm |
| Exploding gradients | Loss NaN, weight growth | Gradient clipping |
| Saturated neurons | Gradients near 0 | Use different activation |
| Dead ReLU | Neurons never activate | Leaky ReLU, lower lr |

### Quick Reference: Common Derivatives in ML

```
d/dx(σ(x)) = σ(x)(1-σ(x))           # Sigmoid
d/dx(tanh(x)) = 1 - tanh²(x)        # Tanh
d/dx(ReLU(x)) = 1 if x>0 else 0     # ReLU
d/dx(softmax_i) = softmax_i(δ_ij - softmax_j)  # Softmax

# Vector derivatives
∇_x(a^T x) = a                       # Linear
∇_x(x^T A x) = (A + A^T)x            # Quadratic
∇_x(||x||₂²) = 2x                    # Squared norm
∇_x(||Ax - b||₂²) = 2A^T(Ax - b)    # Least squares

# Neural network layer
∂L/∂W = a_prev @ δ^T                 # Weights
∂L/∂b = δ                            # Bias
∂L/∂a_prev = W^T @ δ                 # Previous layer
```

---

**[END OF APPENDIX C]**
