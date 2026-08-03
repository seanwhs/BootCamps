# Appendix D: Probability and Statistics Cheat Sheet

## Quick Reference for Distributions, Inference, and Evaluation

### The Target

This appendix provides a comprehensive, quick-reference cheat sheet for all probability and statistics concepts used in machine learning. It's designed to be a practical reference for understanding uncertainty, implementing Bayesian methods, and evaluating models.

### The Concept

Probability and statistics are how we handle uncertainty in machine learning. This cheat sheet puts all the essential distributions, inference methods, and evaluation metrics in one place.

**Why this matters**: When you're building classifiers, evaluating models, or understanding predictions, you need quick access to these concepts. This reference helps you:
- Choose the right distribution for your data
- Implement Bayesian inference correctly
- Evaluate model performance properly
- Understand uncertainty in predictions

### Probability Fundamentals

#### Basic Probability Rules

| Rule | Formula | Example |
|------|---------|---------|
| Complement | `P(A^c) = 1 - P(A)` | `P(not rain) = 1 - P(rain)` |
| Union | `P(A ∪ B) = P(A) + P(B) - P(A ∩ B)` | `P(A or B)` |
| Intersection | `P(A ∩ B) = P(A|B)P(B)` | `P(A and B)` |
| Conditional | `P(A|B) = P(A ∩ B)/P(B)` | `P(rain | cloudy)` |
| Independence | `P(A ∩ B) = P(A)P(B)` | No influence |
| Total Probability | `P(B) = Σ_i P(B|A_i)P(A_i)` | Law of total probability |
| Bayes' Theorem | `P(A|B) = P(B|A)P(A)/P(B)` | Update beliefs |

#### Bayes' Theorem Forms

| Form | Formula | Use |
|------|---------|-----|
| Standard | `P(A|B) = P(B|A)P(A)/P(B)` | General |
| Expanded | `P(A|B) = P(B|A)P(A)/(Σ_i P(B|A_i)P(A_i))` | Multiple hypotheses |
| Odds | `Odds(A|B) = LR × Odds(A)` | Binary classification |
| Log-odds | `log(P(A|B)/(1-P(A|B))) = log(LR) + log(Odds(A))` | Logistic regression |

### Probability Distributions

#### Discrete Distributions

| Distribution | Parameters | PMF | Mean | Variance | Use Case |
|--------------|------------|-----|------|----------|----------|
| Bernoulli | `p ∈ [0,1]` | `P(X=x) = p^x(1-p)^{1-x}` | `p` | `p(1-p)` | Binary outcomes |
| Binomial | `n ∈ ℕ, p ∈ [0,1]` | `P(X=k) = C(n,k)p^k(1-p)^{n-k}` | `np` | `np(1-p)` | Count of successes |
| Poisson | `λ > 0` | `P(X=k) = e^{-λ}λ^k/k!` | `λ` | `λ` | Rare events count |
| Geometric | `p ∈ [0,1]` | `P(X=k) = (1-p)^{k-1}p` | `1/p` | `(1-p)/p²` | Waiting time |
| Multinomial | `n, p₁,...,pₖ` | `n!/(x₁!...xₖ!) Π p_i^{x_i}` | `n p_i` | `n p_i(1-p_i)` | Multi-class counts |

#### Continuous Distributions

| Distribution | Parameters | PDF | Mean | Variance | Use Case |
|--------------|------------|-----|------|----------|----------|
| Gaussian (Normal) | `μ, σ²` | `(1/(σ√(2π)))exp(-(x-μ)²/(2σ²))` | `μ` | `σ²` | Most common |
| Uniform | `a, b` | `1/(b-a)` | `(a+b)/2` | `(b-a)²/12` | No prior info |
| Exponential | `λ > 0` | `λe^{-λx}` | `1/λ` | `1/λ²` | Time between events |
| Gamma | `α, β` | `(β^α/Γ(α))x^{α-1}e^{-βx}` | `α/β` | `α/β²` | Waiting times |
| Beta | `α, β` | `x^{α-1}(1-x)^{β-1}/B(α,β)` | `α/(α+β)` | `αβ/((α+β)²(α+β+1))` | Probabilities |
| Laplace | `μ, b` | `(1/(2b))exp(-|x-μ|/b)` | `μ` | `2b²` | Robust modeling |
| Student-t | `ν, μ, σ` | Complex | `μ (ν>1)` | `νσ²/(ν-2) (ν>2)` | Heavy tails |

### Statistical Inference

#### Point Estimation

| Method | Description | Example |
|--------|-------------|---------|
| MLE | Maximize likelihood | `μ̂ = (1/n)Σx_i` |
| MAP | Maximize posterior | `μ̂ = (τ²/(τ²+σ²/n))x̄ + (σ²/n/(τ²+σ²/n))μ₀` |
| Method of Moments | Match sample moments | Equate E[X] = x̄ |
| Unbiased Estimator | E[θ̂] = θ | Sample variance with n-1 |

#### Confidence Intervals

| Parameter | Formula | Distribution |
|-----------|---------|--------------|
| Mean (known σ) | `x̄ ± z_{α/2}·σ/√n` | Normal |
| Mean (unknown σ) | `x̄ ± t_{α/2,n-1}·s/√n` | t-distribution |
| Proportion | `p̂ ± z_{α/2}·√(p̂(1-p̂)/n)` | Normal approx |
| Variance | `((n-1)s²/χ²_{α/2,n-1}, (n-1)s²/χ²_{1-α/2,n-1})` | Chi-square |

#### Hypothesis Testing

| Test | Use | Statistic |
|------|-----|-----------|
| Z-test | Mean (known σ) | `Z = (x̄ - μ₀)/(σ/√n)` |
| T-test | Mean (unknown σ) | `T = (x̄ - μ₀)/(s/√n)` |
| Chi-square | Categorical | `χ² = Σ (O-E)²/E` |
| F-test | Variances | `F = s₁²/s₂²` |
| Kolmogorov-Smirnov | Goodness-of-fit | `D = sup|F_n(x) - F(x)|` |

### Maximum Likelihood Estimation (MLE)

#### Common MLE Results

| Distribution | MLE Estimates |
|--------------|---------------|
| Gaussian | `μ̂ = x̄`, `σ̂² = (1/n)Σ(x_i - x̄)²` |
| Bernoulli | `p̂ = x̄` |
| Binomial | `p̂ = x̄/n` |
| Poisson | `λ̂ = x̄` |
| Exponential | `λ̂ = 1/x̄` |
| Uniform | `â = min(x_i)`, `b̂ = max(x_i)` |

#### MLE Properties

| Property | Description | Formula |
|----------|-------------|---------|
| Consistency | Converges to truth | `θ̂_n → θ` as n→∞ |
| Asymptotic Normality | Normally distributed | `√n(θ̂ - θ) → N(0, I(θ)^{-1})` |
| Efficiency | Minimal variance | Var(θ̂) = 1/nI(θ) |
| Invariance | Function of MLE | If τ = g(θ), then τ̂ = g(θ̂) |
| Score Function | Derivative of log-likelihood | `s(θ) = ∂ℓ(θ)/∂θ` |

### Model Evaluation Metrics

#### Classification Metrics

| Metric | Formula | Use Case |
|--------|---------|----------|
| Accuracy | `(TP+TN)/(TP+FP+FN+TN)` | General |
| Precision | `TP/(TP+FP)` | Minimize false positives |
| Recall (Sensitivity) | `TP/(TP+FN)` | Minimize false negatives |
| F1 Score | `2·P·R/(P+R)` | Balance P and R |
| Specificity | `TN/(TN+FP)` | Negatives correct |
| AUC-ROC | Area under ROC curve | Overall performance |
| Log Loss | `-(1/n)Σ[y_i log(p_i) + (1-y_i)log(1-p_i)]` | Probabilistic |
| Brier Score | `(1/n)Σ(p_i - y_i)²` | Calibration |

#### Confusion Matrix

```
                 Predicted
                Positive  Negative
Actual Positive    TP       FN
       Negative    FP       TN

Metrics:
Accuracy = (TP + TN) / Total
Precision = TP / (TP + FP)  # "Of predicted positive, how many were correct?"
Recall = TP / (TP + FN)     # "Of actual positive, how many did we find?"
F1 = 2 * P * R / (P + R)
```

#### Regression Metrics

| Metric | Formula | Use Case |
|--------|---------|----------|
| MSE | `(1/n)Σ(y_i - ŷ_i)²` | Standard |
| RMSE | `√(MSE)` | Interpretable units |
| MAE | `(1/n)Σ|y_i - ŷ_i|` | Robust |
| MAPE | `(1/n)Σ|(y_i-ŷ_i)/y_i|` | Relative error |
| R² | `1 - SSE/SST` | Variance explained |
| Adjusted R² | `1 - (1-R²)(n-1)/(n-p-1)` | Penalize complexity |
| Log-Likelihood | `Σ log(p(y_i|ŷ_i))` | Model comparison |

### Model Selection

#### Information Criteria

| Criterion | Formula | Penalty | Use |
|-----------|---------|---------|-----|
| AIC | `-2·ℓ + 2·k` | 2k | Model comparison |
| BIC | `-2·ℓ + k·ln(n)` | k·ln(n) | Heavier penalty |
| HQIC | `-2·ℓ + 2·k·ln(ln(n))` | Moderate | Alternative |

#### Cross-Validation

| Method | Description | Use Case |
|--------|-------------|----------|
| k-Fold CV | Split data into k folds | Standard |
| Leave-One-Out | k = n (each sample is test) | Small data |
| Stratified k-Fold | Preserve class proportions | Imbalanced |
| Time Series CV | Respect temporal order | Time series |
| Nested CV | Outer CV for test, inner for hyperparams | Hyperparameter tuning |

### Bias-Variance Tradeoff

#### Decomposition

```
Expected Test Error = Bias² + Variance + Irreducible Error

Bias = E[f̂(x)] - f(x)      # Systematic error
Variance = E[(f̂(x) - E[f̂(x)])²]  # Random error
Irreducible = σ²            # Noise in data
```

#### Learning Curve Patterns

```
High Bias (Underfitting):
- Train error high, test error high
- Gap small
→ Add complexity, more features

High Variance (Overfitting):
- Train error low, test error high
- Gap large
→ Regularize, more data, simpler model

Good Fit:
- Train error low, test error low
- Gap small
→ Ideal

Just Right:
- Train and test converge to low error
→ Perfect
```

### Bayesian Inference

#### Bayesian Updating

```
Prior:     P(θ)
Likelihood: P(D|θ)
Posterior: P(θ|D) ∝ P(D|θ)P(θ)
Evidence:  P(D) = ∫ P(D|θ)P(θ)dθ

Bayesian Prediction:
P(x_new|D) = ∫ P(x_new|θ)P(θ|D)dθ
```

#### Conjugate Priors

| Likelihood | Conjugate Prior | Posterior Parameters |
|------------|-----------------|---------------------|
| Bernoulli | Beta | `α' = α + Σx_i, β' = β + n - Σx_i` |
| Binomial | Beta | Same as Bernoulli |
| Poisson | Gamma | `α' = α + Σx_i, β' = β + n` |
| Exponential | Gamma | `α' = α + n, β' = β + Σx_i` |
| Gaussian (known σ) | Gaussian | `μ' = (τ₀²/(τ₀²+σ²/n))μ₀ + (σ²/n/(τ₀²+σ²/n))x̄` |
| Multinomial | Dirichlet | `α'_j = α_j + Σ_i I(y_i=j)` |

### Common Statistical Tests in ML

| Test | Use | Null Hypothesis |
|------|-----|-----------------|
| T-test | Compare means | Means are equal |
| Chi-square | Categorical association | Variables are independent |
| F-test | Compare variances | Variances are equal |
| ANOVA | Compare multiple means | All means equal |
| KS test | Compare distributions | Distributions are the same |
| Friedman | Compare multiple models | Models perform equally |
| McNemar | Compare classifiers | Classifiers have same accuracy |

### Quick Reference: Key Formulas

```
Central Limit Theorem:
x̄ ~ N(μ, σ²/n) as n → ∞

Law of Large Numbers:
(1/n)Σx_i → E[X] as n → ∞

Chebyshev Inequality:
P(|X - μ| ≥ kσ) ≤ 1/k²

Markov Inequality:
P(X ≥ a) ≤ E[X]/a for X ≥ 0

Bayes Factor:
BF = P(D|M₁)/P(D|M₂)

BIC Approximation:
BIC = -2·ln(L) + k·ln(n)

AIC Approximation:
AIC = -2·ln(L) + 2·k

R²:
R² = 1 - Σ(y_i - ŷ_i)²/Σ(y_i - ȳ)²
```

---

**[END OF APPENDIX D]**
