# APPENDIX A: COMPLETE REFERENCE - STATISTICAL DISTRIBUTIONS

Welcome to the first appendix! This reference section provides deep dives into the mathematical foundations, properties, and practical applications of every distribution we've covered. Think of this as your **statistical cheat sheet** — everything you need to know about distributions in one place.

---

## A.1 The Normal (Gaussian) Distribution

### Mathematical Definition

The Normal distribution is the most important distribution in statistics. Its probability density function (PDF) is:

$$f(x) = \frac{1}{\sigma\sqrt{2\pi}} e^{-\frac{(x-\mu)^2}{2\sigma^2}}$$

**Parameters:**
- $\mu$ (mu): Mean (location parameter)
- $\sigma$ (sigma): Standard deviation (scale parameter)

**Properties:**
- **Mean:** $\mu$
- **Variance:** $\sigma^2$
- **Skewness:** 0 (perfectly symmetric)
- **Kurtosis:** 0 (excess kurtosis)

### The 68-95-99.7 Rule

| Range | % of Data |
|-------|-----------|
| $\mu \pm 1\sigma$ | 68.27% |
| $\mu \pm 2\sigma$ | 95.45% |
| $\mu \pm 3\sigma$ | 99.73% |

### Standard Normal Distribution ($Z$-distribution)

When $\mu = 0$ and $\sigma = 1$:

$$Z = \frac{X - \mu}{\sigma}$$

**Key Z-scores:**

| Confidence Level | Z-score (two-sided) | Z-score (one-sided) |
|------------------|---------------------|---------------------|
| 90% | 1.645 | 1.282 |
| 95% | 1.960 | 1.645 |
| 99% | 2.576 | 2.326 |
| 99.9% | 3.291 | 3.090 |

### When to Use

✅ **Appropriate when:**
- Data is continuous and symmetric
- Measurement errors
- Natural phenomena (heights, weights, etc.)
- Sampling distributions (CLT)

❌ **Not appropriate when:**
- Data is skewed
- Data is bounded (e.g., [0, 1])
- Data has many outliers

### Implementation Example

```python
from scipy.stats import norm
import numpy as np

# Generate data
data = np.random.normal(loc=50, scale=10, size=1000)

# Calculate probabilities
# P(X < 60)
prob_less = norm.cdf(60, loc=50, scale=10)

# P(X > 40)
prob_greater = 1 - norm.cdf(40, loc=50, scale=10)

# P(40 < X < 60)
prob_between = norm.cdf(60, loc=50, scale=10) - norm.cdf(40, loc=50, scale=10)

# Quantiles
q25 = norm.ppf(0.25, loc=50, scale=10)  # 25th percentile
q75 = norm.ppf(0.75, loc=50, scale=10)  # 75th percentile
```

---

## A.2 The Binomial Distribution

### Mathematical Definition

Models the number of successes in a fixed number of independent trials.

$$P(X = k) = \binom{n}{k} p^k (1-p)^{n-k}$$

Where:
- $\binom{n}{k} = \frac{n!}{k!(n-k)!}$ (binomial coefficient)

**Parameters:**
- $n$: Number of trials
- $p$: Probability of success per trial

**Properties:**
- **Mean:** $np$
- **Variance:** $np(1-p)$
- **Skewness:** $\frac{1-2p}{\sqrt{np(1-p)}}$
- **Kurtosis:** $\frac{1-6p(1-p)}{np(1-p)}$

### When to Use

✅ **Appropriate when:**
- Fixed number of trials
- Independent trials
- Binary outcome (success/failure)
- Constant probability of success

📝 **Example:** Number of heads in 10 coin flips, number of customers who convert out of 100 visitors

### Approximation to Normal

For large $n$ and $p$ not near 0 or 1:

$$X \approx \mathcal{N}(np, np(1-p))$$

**Rule of thumb:** $np \geq 5$ and $n(1-p) \geq 5$

### Implementation Example

```python
from scipy.stats import binom
import numpy as np

# 10 trials, 30% success rate
n, p = 10, 0.3

# Probability of exactly 3 successes
prob_3 = binom.pmf(3, n, p)

# Probability of at most 3 successes
prob_at_most_3 = binom.cdf(3, n, p)

# Probability of at least 3 successes
prob_at_least_3 = 1 - binom.cdf(2, n, p)

# Generate data
data = np.random.binomial(n, p, size=1000)

# Mean and variance
mean = n * p
variance = n * p * (1 - p)
```

---

## A.3 The Poisson Distribution

### Mathematical Definition

Models the number of events occurring in a fixed interval of time or space.

$$P(X = k) = \frac{e^{-\lambda}\lambda^k}{k!}$$

**Parameter:**
- $\lambda$ (lambda): Average rate of events

**Properties:**
- **Mean:** $\lambda$
- **Variance:** $\lambda$ (equidispersion)
- **Skewness:** $\lambda^{-1/2}$
- **Kurtosis:** $\lambda^{-1}$

### When to Use

✅ **Appropriate when:**
- Events occur independently
- Events occur at a constant rate
- The probability of an event is proportional to the interval length
- Two events cannot occur at exactly the same time

📝 **Example:** Number of customers arriving per hour, number of accidents per day, number of defects per item

### Relationship to Binomial

The Poisson distribution is the limiting case of the Binomial distribution when:
- $n \to \infty$ (large number of trials)
- $p \to 0$ (small probability)
- $np = \lambda$ (constant)

### Implementation Example

```python
from scipy.stats import poisson
import numpy as np

# Average rate of 5 events per interval
lambda_rate = 5

# Probability of exactly 3 events
prob_3 = poisson.pmf(3, lambda_rate)

# Probability of at most 3 events
prob_at_most_3 = poisson.cdf(3, lambda_rate)

# Generate data
data = np.random.poisson(lam=lambda_rate, size=1000)

# Mean and variance
mean = lambda_rate
variance = lambda_rate
```

---

## A.4 The Exponential Distribution

### Mathematical Definition

Models the time between events in a Poisson process.

$$f(x) = \lambda e^{-\lambda x} \quad \text{for } x \geq 0$$

**Parameter:**
- $\lambda$ (lambda): Rate parameter

**Properties:**
- **Mean:** $1/\lambda$
- **Variance:** $1/\lambda^2$
- **Skewness:** 2 (highly right-skewed)
- **Kurtosis:** 6 (heavy tails)

### Memoryless Property

The Exponential distribution is memoryless:

$$P(X > s + t \mid X > s) = P(X > t)$$

**Interpretation:** The probability of waiting another $t$ units, given you've already waited $s$ units, is the same as the initial probability of waiting $t$ units.

### When to Use

✅ **Appropriate when:**
- Modeling time until an event occurs
- Constant failure rate
- Memoryless property is reasonable

📝 **Example:** Time between customer arrivals, equipment lifespan (with constant failure rate), waiting times

### Relationship to Poisson

The time between events in a Poisson process follows an Exponential distribution.

### Implementation Example

```python
from scipy.stats import expon
import numpy as np

# Rate parameter (average of 2 events per unit time)
rate = 2
scale = 1 / rate  # Mean waiting time

# Probability of waiting less than 0.5 units
prob_less_than_half = expon.cdf(0.5, scale=scale)

# Probability of waiting more than 1 unit
prob_more_than_1 = 1 - expon.cdf(1, scale=scale)

# Generate data
data = np.random.exponential(scale=scale, size=1000)

# Mean and variance
mean = scale
variance = scale**2
```

---

## A.5 The Uniform Distribution

### Mathematical Definition

The simplest continuous distribution — all values in the range are equally likely.

$$f(x) = \frac{1}{b-a} \quad \text{for } a \leq x \leq b$$

**Parameters:**
- $a$: Lower bound (minimum)
- $b$: Upper bound (maximum)

**Properties:**
- **Mean:** $(a+b)/2$
- **Variance:** $(b-a)^2/12$
- **Skewness:** 0 (symmetric)
- **Kurtosis:** -1.2 (platykurtic, lighter tails than normal)

### When to Use

✅ **Appropriate when:**
- No information about the distribution (maximum entropy prior)
- Random number generation
- Simulating perfect randomness

📝 **Example:** Random number generators, simulation of discrete categories, Bayesian priors

### Implementation Example

```python
from scipy.stats import uniform
import numpy as np

# Range from 0 to 10
a, b = 0, 10

# Probability of value less than 4
prob_less_4 = uniform.cdf(4, loc=a, scale=b-a)

# Probability of value between 3 and 7
prob_between = uniform.cdf(7, loc=a, scale=b-a) - uniform.cdf(3, loc=a, scale=b-a)

# Generate data
data = np.random.uniform(a, b, size=1000)

# Mean and variance
mean = (a + b) / 2
variance = (b - a)**2 / 12
```

---

## A.6 The Chi-Square Distribution

### Mathematical Definition

The distribution of the sum of squared standard normal variables.

$$f(x) = \frac{x^{k/2-1} e^{-x/2}}{2^{k/2} \Gamma(k/2)} \quad \text{for } x \geq 0$$

**Parameter:**
- $k$: Degrees of freedom

**Properties:**
- **Mean:** $k$
- **Variance:** $2k$
- **Skewness:** $\sqrt{8/k}$
- **Kurtosis:** $12/k$

### When to Use

✅ **Appropriate when:**
- Testing goodness of fit
- Testing independence in contingency tables
- ANOVA (F-tests)
- Confidence intervals for variance

📝 **Example:** Chi-square test of independence, goodness-of-fit test, model comparison

### Implementation Example

```python
from scipy.stats import chi2
import numpy as np

# 5 degrees of freedom
df = 5

# Critical value for 95% confidence
crit_val = chi2.ppf(0.95, df)

# Probability of chi-square < 10
prob_less_10 = chi2.cdf(10, df)

# Generate data
data = np.random.chisquare(df=df, size=1000)

# Mean and variance
mean = df
variance = 2 * df
```

---

## A.7 The t-Distribution

### Mathematical Definition

Similar to normal but with heavier tails. Used when estimating a population mean from a small sample.

$$f(t) = \frac{\Gamma(\frac{\nu+1}{2})}{\sqrt{\nu\pi}\Gamma(\frac{\nu}{2})} \left(1 + \frac{t^2}{\nu}\right)^{-\frac{\nu+1}{2}}$$

**Parameter:**
- $\nu$ (nu): Degrees of freedom

**Properties:**
- **Mean:** 0 (for $\nu > 1$)
- **Variance:** $\nu/(\nu-2)$ (for $\nu > 2$)
- **Skewness:** 0 (symmetric)
- **Kurtosis:** $6/(\nu-4)$ (for $\nu > 4$)

### When to Use

✅ **Appropriate when:**
- Small sample size ($n < 30$)
- Population standard deviation is unknown
- Estimating population mean from sample

### Relationship to Normal

As $\nu \to \infty$, the t-distribution approaches the Normal distribution.

### Implementation Example

```python
from scipy.stats import t
import numpy as np

# 9 degrees of freedom (n-1 for sample size 10)
df = 9

# Critical value for 95% confidence (two-sided)
crit_val = t.ppf(0.975, df)  # 0.975 because two-sided

# Probability of t < 2.5
prob_less = t.cdf(2.5, df)

# Generate data
data = np.random.standard_t(df=df, size=1000)

# Mean and variance
mean = 0 if df > 1 else np.nan
variance = df / (df - 2) if df > 2 else np.nan
```

---

## A.8 The F-Distribution

### Mathematical Definition

The ratio of two independent chi-square variables divided by their degrees of freedom.

**Parameters:**
- $d_1$: Numerator degrees of freedom
- $d_2$: Denominator degrees of freedom

**Properties:**
- **Mean:** $d_2/(d_2-2)$ (for $d_2 > 2$)
- **Variance:** $\frac{2d_2^2(d_1+d_2-2)}{d_1(d_2-2)^2(d_2-4)}$ (for $d_2 > 4$)

### When to Use

✅ **Appropriate when:**
- Comparing variances (F-test)
- ANOVA (Analysis of Variance)
- Testing nested models

📝 **Example:** ANOVA, variance ratio tests, model comparison

### Implementation Example

```python
from scipy.stats import f
import numpy as np

# Degrees of freedom
dfn, dfd = 5, 10

# Critical value for 95% confidence
crit_val = f.ppf(0.95, dfn, dfd)

# Probability of F < 3
prob_less = f.cdf(3, dfn, dfd)

# Generate data
data = np.random.f(dfn, dfd, size=1000)

# Mean and variance
mean = dfd / (dfd - 2) if dfd > 2 else np.nan
variance = (2 * dfd**2 * (dfn + dfd - 2)) / (dfn * (dfd - 2)**2 * (dfd - 4)) if dfd > 4 else np.nan
```

---

## A.9 Distribution Decision Tree

Use this flowchart to choose the right distribution:

```
Is the data discrete or continuous?
│
├── Discrete
│   │
│   ├── Fixed number of trials?
│   │   ├── Yes → Binomial
│   │   └── No → Poisson (count data)
│   │
│   └── Events occurring in intervals?
│       └── Yes → Poisson
│
└── Continuous
    │
    ├── Is it symmetric (bell-shaped)?
    │   ├── Yes → Normal (or t for small samples)
    │   └── No → Skewed?
    │       │
    │       ├── Yes → Exponential (right-skewed)
    │       └── No → Uniform (if no info)
    │
    └── Bound between [0, 1]?
        └── Yes → Beta (not covered in Phase 3)
```

---

## A.10 Quick Reference: Distribution Comparison

| Distribution | Parameters | Mean | Variance | Use Case |
|--------------|------------|------|----------|----------|
| **Normal** | $\mu, \sigma$ | $\mu$ | $\sigma^2$ | Continuous, symmetric |
| **Binomial** | $n, p$ | $np$ | $np(1-p)$ | Number of successes |
| **Poisson** | $\lambda$ | $\lambda$ | $\lambda$ | Count of rare events |
| **Exponential** | $\lambda$ | $1/\lambda$ | $1/\lambda^2$ | Time between events |
| **Uniform** | $a, b$ | $(a+b)/2$ | $(b-a)^2/12$ | Equal probabilities |
| **t** | $\nu$ | 0 | $\nu/(\nu-2)$ | Small samples |
| **Chi-square** | $k$ | $k$ | $2k$ | Goodness-of-fit |
| **F** | $d_1, d_2$ | $d_2/(d_2-2)$ | ... | Variance ratios |

---

## A.11 Common Distribution Transformations

### Box-Cox Transformation

For stabilizing variance and making data more normal:

$$y(\lambda) = \begin{cases}
\frac{x^\lambda - 1}{\lambda} & \text{if } \lambda \neq 0 \\
\ln(x) & \text{if } \lambda = 0
\end{cases}$$

**Common $\lambda$ values:**
- $\lambda = 1$: No transformation
- $\lambda = 0.5$: Square root
- $\lambda = 0$: Log transformation (most common for right-skewed data)
- $\lambda = -1$: Inverse

### When to Transform

| Original Distribution | Suggested Transformation |
|----------------------|--------------------------|
| Right-skewed (positive) | Log or square root |
| Left-skewed (negative) | Square or power |
| Count data | Square root or log |
| Proportions | Logit (log-odds) |

### Implementation Example

```python
from scipy.stats import boxcox
import numpy as np

# Generate right-skewed data
data = np.random.exponential(scale=5, size=1000)

# Apply Box-Cox transformation
transformed, best_lambda = boxcox(data + 1)  # Add 1 if data contains zeros

print(f"Best lambda: {best_lambda:.3f}")

# Check normality
from scipy.stats import shapiro
_, p_original = shapiro(data)
_, p_transformed = shapiro(transformed)

print(f"Original p-value: {p_original:.4f}")
print(f"Transformed p-value: {p_transformed:.4f}")
```

---

## A.12 Choosing Between Distributions

### Distribution Selection Criteria

| Aspect | What to Consider |
|--------|------------------|
| **Domain** | Is data discrete or continuous? Is it bounded? |
| **Shape** | Is it symmetric? Skewed left or right? |
| **Process** | How was the data generated? Random? Time-based? |
| **Purpose** | Are you modeling, testing, or simulating? |

### Common Mistakes

| Mistake | Better Approach |
|---------|-----------------|
| Assuming normality | Check with Q-Q plots and Shapiro-Wilk |
| Ignoring skewness | Use non-parametric tests or transformations |
| Using normal for count data | Use Poisson or binomial |
| Using Poisson for overdispersed data | Use negative binomial |

---

## A.13 Summary: Key Takeaways

1. **The Normal distribution** is the most important — it appears everywhere through the CLT
2. **Binomial and Poisson** are for count data (successes and rare events)
3. **Exponential** is for waiting times and time-between-events
4. **Uniform** is for when you have no information
5. **t, Chi-square, and F** are derived distributions for hypothesis testing
6. **Always check assumptions** — don't blindly use a distribution
7. **Transformations can help** when data doesn't fit the assumed distribution
