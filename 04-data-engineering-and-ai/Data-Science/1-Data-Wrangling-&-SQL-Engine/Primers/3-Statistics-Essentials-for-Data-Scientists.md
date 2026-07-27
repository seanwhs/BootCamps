# PRIMER 3: Statistics Essentials for Data Scientists

## A Complete Statistics Refresher for the Data Engineering Series

---

## Introduction

This primer provides a comprehensive foundation in the statistical concepts used throughout the data engineering series. While the main series covers statistics in depth (especially Phase 3), this primer ensures you have the essential knowledge before diving into hypothesis testing, experimental design, and statistical modeling.

**What This Primer Covers:**
- Descriptive statistics (mean, median, variance, etc.)
- Probability theory basics
- Key probability distributions
- Statistical inference foundations
- Hypothesis testing fundamentals
- Correlation and regression basics

**What This Primer Does NOT Cover:**
- Advanced Bayesian statistics
- Multivariate analysis
- Time series analysis
- Machine learning algorithms

---

## P3.1: Descriptive Statistics

### Measures of Central Tendency

| Measure | Definition | When to Use | Formula |
|---------|-------------|-------------|---------|
| **Mean** | Average value | Symmetric distributions | μ = Σx / n |
| **Median** | Middle value | Skewed distributions | 50th percentile |
| **Mode** | Most frequent value | Categorical data | Most common value |

```python
import numpy as np
from scipy import stats

# Sample data
data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]  # Has outlier

mean = np.mean(data)        # 14.5 (affected by outlier)
median = np.median(data)    # 5.5 (robust to outlier)
mode = stats.mode(data)     # No mode (all values unique)

print(f"Mean: {mean:.2f}")
print(f"Median: {median:.2f}")
print(f"Mode: {mode}")
```

### Measures of Spread

| Measure | Definition | Formula |
|---------|-------------|---------|
| **Variance** | Average squared deviation | σ² = Σ(x - μ)² / n |
| **Standard Deviation** | Square root of variance | σ = √σ² |
| **Range** | Max - Min | Max - Min |
| **IQR** | Q3 - Q1 | 75th percentile - 25th percentile |

```python
data = np.random.normal(100, 15, 1000)

variance = np.var(data)           # ~225
std_dev = np.std(data)            # ~15
range_val = np.max(data) - np.min(data)
q1 = np.percentile(data, 25)
q3 = np.percentile(data, 75)
iqr = q3 - q1

print(f"Variance: {variance:.2f}")
print(f"Std Dev: {std_dev:.2f}")
print(f"IQR: {iqr:.2f}")
```

### Shape of Distribution

```python
from scipy.stats import skew, kurtosis

data = np.random.exponential(10, 1000)

skewness = skew(data)      # Positive = right-skewed
kurtosis_val = kurtosis(data)  # Positive = heavy tails

print(f"Skewness: {skewness:.2f}")
print(f"Kurtosis: {kurtosis_val:.2f}")

# Interpretation
# Skewness > 0: Right-skewed (long right tail)
# Skewness < 0: Left-skewed (long left tail)
# Kurtosis > 0: Heavy tails (more outliers)
# Kurtosis < 0: Light tails (fewer outliers)
```

---

## P3.2: Probability Theory

### Basic Probability Rules

```
P(A or B) = P(A) + P(B) - P(A and B)    [Addition Rule]
P(A and B) = P(A) × P(B|A)               [Multiplication Rule]
P(A and B) = P(A) × P(B)                 [If independent]
P(A|B) = P(A and B) / P(B)               [Conditional Probability]
Bayes: P(A|B) = P(B|A) × P(A) / P(B)     [Bayes' Theorem]
```

```python
# Example: Probability calculations
# Suppose we have a deck of cards

# Probability of drawing a heart
p_heart = 13/52  # 0.25

# Probability of drawing a face card
p_face = 12/52   # 0.2308

# Probability of drawing a heart OR a face card
p_heart_or_face = p_heart + p_face - (3/52)  # 0.3077

# Conditional probability: Probability of heart given face card
p_heart_given_face = (3/52) / (12/52)  # 0.25
```

### Random Variables

```python
# Discrete random variable: Number of heads in 3 coin flips
import numpy as np
from scipy.stats import binom

n = 3      # Number of trials
p = 0.5    # Probability of success

# Probability of exactly 2 heads
prob_2_heads = binom.pmf(2, n, p)  # 0.375

# Probability of 2 or more heads
prob_2_or_more = 1 - binom.cdf(1, n, p)  # 0.5

# Expected value = n * p = 1.5
# Variance = n * p * (1-p) = 0.75

# Continuous random variable: Normal distribution
from scipy.stats import norm

# P(X < 110) for X ~ N(100, 15)
prob_less_110 = norm.cdf(110, 100, 15)  # 0.7486

# P(X > 90)
prob_greater_90 = 1 - norm.cdf(90, 100, 15)  # 0.7475

# P(90 < X < 110)
prob_between = norm.cdf(110, 100, 15) - norm.cdf(90, 100, 15)  # 0.4950
```

---

## P3.3: Key Probability Distributions

### Normal Distribution

```python
from scipy.stats import norm
import matplotlib.pyplot as plt
import numpy as np

# Normal distribution parameters
mu = 100      # Mean
sigma = 15    # Standard deviation

# PDF, CDF, quantiles
x = np.linspace(40, 160, 1000)
pdf = norm.pdf(x, mu, sigma)
cdf = norm.cdf(x, mu, sigma)
quantile_95 = norm.ppf(0.95, mu, sigma)  # 124.67

# Generate random samples
samples = norm.rvs(mu, sigma, size=1000)

# Key properties
# 68% of data within μ ± 1σ
# 95% of data within μ ± 2σ
# 99.7% of data within μ ± 3σ

# Standard normal (Z-score)
z = (x - mu) / sigma
# z-scores: N(0, 1)
```

### t-Distribution

```python
from scipy.stats import t

# t-distribution: heavier tails than normal
df = 10  # Degrees of freedom

# Comparison with normal
x = np.linspace(-4, 4, 1000)
t_pdf = t.pdf(x, df)
norm_pdf = norm.pdf(x)

# t-critical value (95% CI)
t_critical = t.ppf(0.975, df)  # 2.228
z_critical = norm.ppf(0.975)    # 1.96

# As df increases, t → normal
```

### Chi-Square Distribution

```python
from scipy.stats import chi2

# Chi-square distribution: sum of squared normals
df = 3  # Degrees of freedom

# PDF, CDF, quantiles
x = np.linspace(0, 15, 1000)
pdf = chi2.pdf(x, df)
chi2_95 = chi2.ppf(0.95, df)  # 7.815

# Used in:
# - Variance tests
# - Goodness of fit tests
# - Contingency table tests
```

### F-Distribution

```python
from scipy.stats import f

# F-distribution: ratio of two chi-squares
dfn = 3   # Numerator df
dfd = 10  # Denominator df

# Used in:
# - ANOVA
# - Comparing variances
# - Regression model comparison

f_critical = f.ppf(0.95, dfn, dfd)  # 3.708
```

### Discrete Distributions

```python
from scipy.stats import binom, poisson

# Binomial: number of successes in n trials
n, p = 10, 0.3
k = 3
prob = binom.pmf(k, n, p)  # 0.2668

# Poisson: count of rare events
lambda_val = 2.5  # Expected count
k = 3
prob = poisson.pmf(k, lambda_val)  # 0.2138
```

---

## P3.4: Sampling and Estimation

### Sampling Methods

```python
import pandas as pd
import numpy as np

# Create population
population = pd.DataFrame({
    'id': range(10000),
    'value': np.random.normal(100, 20, 10000),
    'group': np.random.choice(['A', 'B', 'C', 'D'], 10000)
})

# 1. Simple Random Sampling
sample_srs = population.sample(100)

# 2. Stratified Sampling
sample_stratified = population.groupby('group', group_keys=False).apply(
    lambda x: x.sample(frac=0.1)
)

# 3. Systematic Sampling
step = len(population) // 100
indices = np.arange(0, len(population), step)[:100]
sample_systematic = population.iloc[indices]
```

### Central Limit Theorem

```python
"""
The Central Limit Theorem states:
The sampling distribution of the mean approaches a normal distribution
as sample size increases, regardless of the underlying distribution.
"""

import numpy as np
import matplotlib.pyplot as plt

# Underlying distribution: Exponential (non-normal)
population = np.random.exponential(10, 100000)

# Draw many samples and compute means
sample_means = []
sample_sizes = [5, 10, 30, 50, 100]

fig, axes = plt.subplots(1, len(sample_sizes), figsize=(15, 3))

for idx, n in enumerate(sample_sizes):
    means = [np.mean(np.random.choice(population, n)) 
             for _ in range(1000)]
    
    axes[idx].hist(means, bins=30, density=True)
    axes[idx].set_title(f'n={n}')
    axes[idx].set_xlabel('Sample Mean')
    
    # As n increases, distribution approaches normal
```

### Confidence Intervals

```python
from scipy.stats import t, norm
import numpy as np

# Sample data
sample = np.random.normal(100, 15, 50)
n = len(sample)
mean = np.mean(sample)
std = np.std(sample, ddof=1)  # Sample standard deviation
se = std / np.sqrt(n)         # Standard error

# 95% Confidence Interval (t-distribution)
t_critical = t.ppf(0.975, df=n-1)
ci_t = (mean - t_critical * se, mean + t_critical * se)

# 95% Confidence Interval (normal approximation)
z_critical = norm.ppf(0.975)
ci_z = (mean - z_critical * se, mean + z_critical * se)

print(f"Sample Mean: {mean:.2f}")
print(f"95% CI (t): ({ci_t[0]:.2f}, {ci_t[1]:.2f})")
print(f"95% CI (z): ({ci_z[0]:.2f}, {ci_z[1]:.2f})")
```

### Standard Error

```python
# Standard error = standard deviation of the sampling distribution
se = std / np.sqrt(n)  # For the mean

# Interpretations:
# - Larger sample → smaller SE
# - Smaller variance → smaller SE
# - SE decreases with √n

# Margin of Error = critical_value * SE
# ME = 1.96 * (std / √n) for 95% CI
```

---

## P3.5: Hypothesis Testing

### Key Concepts

```
Null Hypothesis (H₀): No effect, no difference
Alternative Hypothesis (H₁): There is an effect or difference

Type I Error (α): Rejecting H₀ when it's true (False Positive)
Type II Error (β): Failing to reject H₀ when it's false (False Negative)

Power = 1 - β: Probability of detecting a true effect

P-value: Probability of observing data as extreme as observed,
         assuming H₀ is true

Significance Level (α): Threshold for rejecting H₀ (typically 0.05)
```

### One-Sample t-test

```python
from scipy.stats import ttest_1samp

# Test if sample mean differs from hypothesized value
sample = np.random.normal(105, 15, 50)
hypothesized_mean = 100

t_stat, p_value = ttest_1samp(sample, hypothesized_mean)

print(f"Sample mean: {np.mean(sample):.2f}")
print(f"t-statistic: {t_stat:.4f}")
print(f"p-value: {p_value:.4f}")

if p_value < 0.05:
    print("✓ Reject H₀: Significant difference")
else:
    print("✗ Fail to reject H₀: No significant difference")
```

### Two-Sample t-test

```python
from scipy.stats import ttest_ind

# Compare two independent groups
group1 = np.random.normal(100, 15, 50)
group2 = np.random.normal(108, 15, 50)

t_stat, p_value = ttest_ind(group1, group2)

print(f"Group 1 mean: {np.mean(group1):.2f}")
print(f"Group 2 mean: {np.mean(group2):.2f}")
print(f"t-statistic: {t_stat:.4f}")
print(f"p-value: {p_value:.4f}")
```

### Paired t-test

```python
from scipy.stats import ttest_rel

# Before and after measurements
before = np.random.normal(50, 10, 30)
after = before + np.random.normal(5, 3, 30)

t_stat, p_value = ttest_rel(before, after)

print(f"Before: {np.mean(before):.2f}")
print(f"After: {np.mean(after):.2f}")
print(f"Change: {np.mean(after) - np.mean(before):.2f}")
print(f"t-statistic: {t_stat:.4f}")
print(f"p-value: {p_value:.4f}")
```

### ANOVA (Multiple Groups)

```python
from scipy.stats import f_oneway

# Three groups
group_a = np.random.normal(100, 15, 30)
group_b = np.random.normal(108, 15, 30)
group_c = np.random.normal(115, 15, 30)

f_stat, p_value = f_oneway(group_a, group_b, group_c)

print(f"F-statistic: {f_stat:.4f}")
print(f"p-value: {p_value:.4f}")
```

### Chi-Square Test

```python
from scipy.stats import chi2_contingency
import pandas as pd

# Contingency table
data = pd.DataFrame({
    'Category': np.random.choice(['A', 'B', 'C'], 200),
    'Result': np.random.choice(['Success', 'Failure'], 200)
})

contingency = pd.crosstab(data['Category'], data['Result'])

chi2, p_value, dof, expected = chi2_contingency(contingency)

print("Contingency Table:")
print(contingency)
print(f"\nChi-square: {chi2:.4f}")
print(f"p-value: {p_value:.4f}")
```

### Non-Parametric Tests

```python
from scipy.stats import mannwhitneyu, wilcoxon, kruskal

# Mann-Whitney U (independent, non-normal)
group1 = np.random.exponential(10, 50)
group2 = np.random.exponential(12, 50)
u_stat, p_value = mannwhitneyu(group1, group2)

# Wilcoxon signed-rank (paired, non-normal)
before = np.random.exponential(10, 30)
after = before + np.random.exponential(2, 30)
w_stat, p_value = wilcoxon(before, after)

# Kruskal-Wallis (multiple groups, non-normal)
group_a = np.random.exponential(10, 30)
group_b = np.random.exponential(13, 30)
group_c = np.random.exponential(16, 30)
h_stat, p_value = kruskal(group_a, group_b, group_c)
```

---

## P3.6: Effect Size and Power

### Effect Size (Cohen's d)

```python
def cohens_d(group1, group2):
    """Calculate Cohen's d effect size."""
    n1, n2 = len(group1), len(group2)
    mean1, mean2 = np.mean(group1), np.mean(group2)
    var1, var2 = np.var(group1, ddof=1), np.var(group2, ddof=1)
    
    pooled_std = np.sqrt(((n1 - 1) * var1 + (n2 - 1) * var2) / (n1 + n2 - 2))
    d = (mean1 - mean2) / pooled_std
    return abs(d)

# Interpretations
# d = 0.2: Small effect
# d = 0.5: Medium effect
# d = 0.8: Large effect

group1 = np.random.normal(100, 15, 50)
group2 = np.random.normal(108, 15, 50)

d = cohens_d(group1, group2)
print(f"Cohen's d: {d:.2f}")
```

### Power Analysis

```python
from statsmodels.stats.power import TTestIndPower

# Parameters
effect_size = 0.5  # Medium effect
alpha = 0.05       # Significance level
power = 0.80       # Desired power

# Calculate required sample size
power_analysis = TTestIndPower()
n = power_analysis.solve_power(
    effect_size=effect_size,
    alpha=alpha,
    power=power,
    alternative='two-sided'
)

print(f"Required sample size per group: {int(np.ceil(n))}")

# Sample size vs effect size
effect_sizes = [0.1, 0.2, 0.3, 0.5, 0.8]
for es in effect_sizes:
    n = power_analysis.solve_power(
        effect_size=es,
        alpha=alpha,
        power=power,
        alternative='two-sided'
    )
    print(f"Effect size {es:.1f}: {int(np.ceil(n))} per group")
```

---

## P3.7: Correlation

### Pearson Correlation

```python
from scipy.stats import pearsonr

# Linear relationship
x = np.random.normal(50, 10, 100)
y = 2 * x + np.random.normal(0, 5, 100)

r, p_value = pearsonr(x, y)

print(f"Pearson correlation: {r:.4f}")
print(f"p-value: {p_value:.4f}")

# Interpretation:
# r = 1: Perfect positive correlation
# r = -1: Perfect negative correlation
# r = 0: No correlation
```

### Spearman Correlation

```python
from scipy.stats import spearmanr

# Monotonic but non-linear relationship
x = np.random.uniform(0, 10, 100)
y = x**2 + np.random.normal(0, 5, 100)

rho, p_value = spearmanr(x, y)

print(f"Spearman correlation: {rho:.4f}")
print(f"p-value: {p_value:.4f}")
```

### Correlation Matrix

```python
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Create data with relationships
df = pd.DataFrame({
    'feature1': np.random.normal(0, 1, 100),
    'feature2': np.random.normal(0, 1, 100),
    'feature3': np.random.normal(0, 1, 100),
    'feature4': np.random.normal(0, 1, 100)
})

# Add relationships
df['feature2'] = df['feature1'] * 2 + np.random.normal(0, 0.5, 100)
df['feature3'] = -df['feature1'] * 1.5 + np.random.normal(0, 0.5, 100)

# Correlation matrix
corr = df.corr()
print(corr)

# Visualize
sns.heatmap(corr, annot=True, cmap='RdBu', center=0)
plt.show()
```

---

## P3.8: Simple Linear Regression

### Understanding OLS Regression

```python
import statsmodels.api as sm
import numpy as np

# Generate data
x = np.random.normal(50, 10, 100)
y = 2 * x + 30 + np.random.normal(0, 5, 100)

# Add constant term (intercept)
X = sm.add_constant(x)

# Fit model
model = sm.OLS(y, X).fit()

print(model.summary())

# Interpret results
# y = 2*x + 30 + ε
# R² = proportion of variance explained
# p-values test if coefficients are significantly different from 0
```

### Coefficients Interpretation

```python
# For a simple linear regression: y = β₀ + β₁x

# β₀ (intercept): expected y when x = 0
# β₁ (slope): expected change in y for a 1-unit increase in x

# Example: y = 30 + 2*x
# For each 1-unit increase in x, y increases by 2

# Confidence intervals
conf_int = model.conf_int()
print("95% Confidence Intervals:")
print(f"Intercept: ({conf_int[0][0]:.2f}, {conf_int[0][1]:.2f})")
print(f"Slope: ({conf_int[1][0]:.2f}, {conf_int[1][1]:.2f})")

# If confidence interval does not contain 0, the effect is significant
```

---

## P3.9: Common Statistical Tests Summary

### Test Selection Guide

| Research Question | Test | When to Use |
|-------------------|------|-------------|
| Sample mean vs hypothesized value | One-sample t-test | Normal data, 1 group |
| Two independent groups | Independent t-test | Normal data, 2 groups |
| Two paired groups | Paired t-test | Normal data, paired observations |
| Three+ groups | ANOVA | Normal data, 3+ groups |
| Two independent groups (non-normal) | Mann-Whitney U | Non-normal data, 2 groups |
| Two paired groups (non-normal) | Wilcoxon signed-rank | Non-normal data, paired |
| Three+ groups (non-normal) | Kruskal-Wallis | Non-normal data, 3+ groups |
| Categorical variables | Chi-square | Count data, proportions |
| Linear relationship | Pearson correlation | Normal data, linear |
| Monotonic relationship | Spearman correlation | Non-normal data, monotonic |

### Assumptions Checklist

```python
# For t-tests and ANOVA:
# 1. Normality
from scipy.stats import shapiro
stat, p = shapiro(data)
# p > 0.05 = normal

# 2. Homogeneity of variance
from scipy.stats import levene
stat, p = levene(group1, group2)
# p > 0.05 = equal variances

# 3. Independence
# Check study design (randomized, not paired if independent t-test)
```

---

## P3.10: Practice Exercises

### Exercise 1: Descriptive Statistics

```python
"""
Exercise: Analyze a dataset and report key statistics.
"""

import numpy as np
import pandas as pd

# Load data
data = pd.read_csv('customer_data.csv')

# Calculate:
# 1. Mean, median, mode of age
# 2. Standard deviation of income
# 3. IQR of spending
# 4. Skewness and kurtosis of all numeric columns
```

### Exercise 2: Hypothesis Testing

```python
"""
Exercise: Test if there is a significant difference between two groups.
"""

import numpy as np
from scipy.stats import ttest_ind

# Group A: Control group (no treatment)
group_a = np.random.normal(50, 10, 100)

# Group B: Treatment group
group_b = np.random.normal(55, 10, 100)  # Slight increase

# Task:
# 1. Check normality of both groups
# 2. Choose appropriate statistical test
# 3. Report effect size and confidence interval
# 4. Interpret the results
```

### Exercise 3: Correlation Analysis

```python
"""
Exercise: Analyze correlations between multiple variables.
"""

import pandas as pd
import seaborn as sns

# Data with relationships
df = pd.DataFrame({
    'sales': np.random.normal(1000, 200, 100),
    'advertising': np.random.normal(100, 20, 100),
    'price': np.random.normal(50, 10, 100),
    'satisfaction': np.random.uniform(1, 5, 100)
})

# Add relationships
df['sales'] = df['sales'] + df['advertising'] * 2
df['sales'] = df['sales'] - df['price'] * 3
df['satisfaction'] = df['satisfaction'] + np.random.normal(0, 0.5, 100)

# Task:
# 1. Calculate correlation matrix
# 2. Identify strongest correlations
# 3. Create a heatmap
# 4. Test if correlations are significant
```

---

## P3.11: Quick Reference

### Distribution Properties

| Distribution | Parameters | Use Case |
|--------------|------------|----------|
| Normal | μ, σ | Natural processes, CLT |
| t | df | Small samples, unknown variance |
| Chi-Square | df | Variance tests, goodness of fit |
| F | dfn, dfd | ANOVA, comparing variances |
| Binomial | n, p | Success/failure counts |
| Poisson | λ | Rare events counts |
| Exponential | λ | Time between events |

### Key Formulas

```
Standard Error: SE = s / √n
Confidence Interval: estimate ± critical_value × SE
Effect Size (Cohen's d): d = (mean₁ - mean₂) / pooled_sd
Sample Size: n = (Z² × p × (1-p)) / ME²
Power: 1 - β
```

### Hypothesis Testing Steps

1. State H₀ and H₁
2. Choose α (significance level)
3. Choose appropriate test
4. Collect data
5. Calculate test statistic
6. Compute p-value
7. Make decision (reject/fail to reject H₀)
8. Report results (effect size, CI)

---

**[PRIMER 3 COMPLETE]**  
