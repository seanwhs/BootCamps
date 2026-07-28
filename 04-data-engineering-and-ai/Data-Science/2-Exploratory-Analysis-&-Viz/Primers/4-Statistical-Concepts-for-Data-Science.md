# Primer 4: Statistical Concepts for Data Science

## Essential Statistical Knowledge for Data Analysis and Modeling

---

#### Purpose of This Primer

This primer covers the statistical concepts you'll encounter throughout the series. While the main tutorials focus on implementation, this primer explains the "why" behind the methods—the mathematical foundations, assumptions, and interpretations that make your analysis robust and defensible.

---

## P4.1 Descriptive Statistics

### P4.1.1 Measures of Central Tendency

#### Mean (Arithmetic Average)

The sum of all values divided by the number of values.

$$\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$$

**When to use:** Symmetric distributions, when you need a single representative value.

**Weaknesses:** Highly sensitive to outliers.

```python
import numpy as np
import pandas as pd

# Example
data = [2, 4, 6, 8, 10, 100]  # Contains outlier
mean = np.mean(data)  # 21.67 (pulled up by outlier)
median = np.median(data)  # 7.0 (more representative)
```

#### Median

The middle value when data is sorted (50th percentile).

**When to use:** Skewed distributions, ordinal data, when outliers are present.

```python
median = np.median(data)  # 7.0
```

#### Mode

The most frequently occurring value(s).

**When to use:** Categorical data, understanding the "typical" member.

```python
from scipy import stats
mode = stats.mode(data)
```

### P4.1.2 Measures of Dispersion

#### Variance

Average of squared deviations from the mean.

$$\sigma^2 = \frac{1}{n}\sum_{i=1}^{n} (x_i - \bar{x})^2$$

**Population vs. Sample:**
- Population variance: divide by n
- Sample variance: divide by (n-1) (Bessel's correction)

```python
variance_pop = np.var(data)  # Population variance
variance_sample = np.var(data, ddof=1)  # Sample variance
```

#### Standard Deviation

Square root of variance (returns to original units).

$$\sigma = \sqrt{\sigma^2}$$

**Interpretation (Normal Distribution):**
- 68% of data within ±1σ of mean
- 95% within ±2σ
- 99.7% within ±3σ

```python
std = np.std(data, ddof=1)  # Sample standard deviation
```

#### Interquartile Range (IQR)

Q3 - Q1 (75th percentile - 25th percentile).

**Use:** Describing spread without outlier influence, detecting outliers.

```python
q1 = np.percentile(data, 25)
q3 = np.percentile(data, 75)
iqr = q3 - q1

# Outlier detection
lower_bound = q1 - 1.5 * iqr
upper_bound = q3 + 1.5 * iqr
outliers = [x for x in data if x < lower_bound or x > upper_bound]
```

### P4.1.3 Shape Statistics

#### Skewness

Measure of asymmetry.

$$\text{Skewness} = \frac{1}{n}\sum_{i=1}^{n} \left(\frac{x_i - \bar{x}}{\sigma}\right)^3$$

**Interpretation:**
- Skewness = 0: Symmetric
- Skewness > 0: Right-skewed (positive)
- Skewness < 0: Left-skewed (negative)

```python
skewness = pd.Series(data).skew()
```

#### Kurtosis

Measure of "tailedness."

$$\text{Kurtosis} = \frac{1}{n}\sum_{i=1}^{n} \left(\frac{x_i - \bar{x}}{\sigma}\right)^4 - 3$$

**Interpretation:**
- Kurtosis = 0: Normal (mesokurtic)
- Kurtosis > 0: Heavy tails (leptokurtic)
- Kurtosis < 0: Light tails (platykurtic)

```python
kurtosis = pd.Series(data).kurtosis()
```

---

## P4.2 Probability Distributions

### P4.2.1 Normal Distribution (Gaussian)

The "Bell Curve." Most important distribution in statistics.

**PDF Formula:**
$$f(x) = \frac{1}{\sigma\sqrt{2\pi}} e^{-\frac{(x-\mu)^2}{2\sigma^2}}$$

**Properties:**
- Symmetric around mean
- Mean = Median = Mode
- 68-95-99.7 rule
- Described by μ (mean) and σ (standard deviation)

```python
from scipy import stats
import numpy as np

# Generate normal data
data = np.random.normal(loc=0, scale=1, size=1000)

# Test for normality
stat, p = stats.shapiro(data)
if p > 0.05:
    print("Data appears normal")

# Q-Q plot
import matplotlib.pyplot as plt
stats.probplot(data, dist="norm", plot=plt)
plt.show()
```

### P4.2.2 Common Distributions

| Distribution | Uses | Parameters |
|--------------|------|------------|
| **Normal** | Natural phenomena, errors | μ (mean), σ (std) |
| **Log-Normal** | Income, reaction times | μ, σ (of log) |
| **Uniform** | Random numbers | a (min), b (max) |
| **Binomial** | Number of successes | n (trials), p (prob) |
| **Poisson** | Count events over time | λ (rate) |
| **Exponential** | Time between events | λ (rate) |
| **Beta** | Proportions, probabilities | α, β |

```python
# Generate from distributions
uniform = np.random.uniform(0, 1, 1000)
binomial = np.random.binomial(10, 0.5, 1000)
poisson = np.random.poisson(5, 1000)
exponential = np.random.exponential(2, 1000)
beta = np.random.beta(2, 5, 1000)
```

---

## P4.3 Correlation and Association

### P4.3.1 Pearson Correlation

Measures linear relationship between two continuous variables.

$$r = \frac{\sum (x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum (x_i - \bar{x})^2 \sum (y_i - \bar{y})^2}}$$

**Range:** -1 to +1

**Interpretation:**

| r value | Strength |
|---------|----------|
| 0.00 - 0.19 | Very weak |
| 0.20 - 0.39 | Weak |
| 0.40 - 0.59 | Moderate |
| 0.60 - 0.79 | Strong |
| 0.80 - 1.00 | Very strong |

**Assumptions:**
1. Linear relationship
2. Normal distribution
3. No outliers
4. Homoscedasticity (constant variance)

```python
from scipy.stats import pearsonr
r, p_value = pearsonr(x, y)
```

### P4.3.2 Spearman Rank Correlation

Measures monotonic relationship (not necessarily linear).

$$\rho = 1 - \frac{6\sum d_i^2}{n(n^2 - 1)}$$

**When to use:**
- Non-linear relationships
- Ordinal data
- Non-normal distributions

```python
from scipy.stats import spearmanr
rho, p_value = spearmanr(x, y)
```

### P4.3.3 Cramér's V

Measures association between categorical variables.

$$V = \sqrt{\frac{\chi^2}{n \times \min(k-1, r-1)}}$$

**Range:** 0 to 1

```python
def cramers_v(confusion_matrix):
    chi2 = stats.chi2_contingency(confusion_matrix)[0]
    n = confusion_matrix.sum().sum()
    min_dim = min(confusion_matrix.shape) - 1
    return np.sqrt(chi2 / (n * min_dim))

# Example
confusion = pd.crosstab(df['gender'], df['category'])
v = cramers_v(confusion)
```

---

## P4.4 Hypothesis Testing

### P4.4.1 Understanding p-values

**Definition:** Probability of observing your data (or more extreme) if the null hypothesis is true.

**Interpretation:**
- p < 0.05: Statistically significant (reject null)
- p > 0.05: Not statistically significant (fail to reject)

**Common Misconceptions:**
- ❌ p < 0.05 means the result is important or meaningful
- ❌ p > 0.05 means there is no effect
- ✅ p < 0.05 means the result is unlikely due to chance alone

```python
from scipy.stats import ttest_ind
t_stat, p_value = ttest_ind(group1, group2)
```

### P4.4.2 T-Test

**Purpose:** Compare means of two groups.

**Types:**
1. Independent t-test: Two different groups
2. Paired t-test: Same group at two time points
3. One-sample t-test: Compare mean to known value

**Assumptions:**
1. Independent observations
2. Normal distribution
3. Homogeneity of variance

```python
# Independent t-test
from scipy.stats import ttest_ind
t_stat, p_value = ttest_ind(group1, group2)

# Paired t-test
from scipy.stats import ttest_rel
t_stat, p_value = ttest_rel(before, after)

# One-sample t-test
from scipy.stats import ttest_1samp
t_stat, p_value = ttest_1samp(data, popmean=0)
```

### P4.4.3 ANOVA

**Purpose:** Compare means of three or more groups.

$$F = \frac{\text{Between-group variance}}{\text{Within-group variance}}$$

```python
from scipy.stats import f_oneway
f_stat, p_value = f_oneway(group1, group2, group3)

# Post-hoc: Tukey HSD
from statsmodels.stats.multicomp import pairwise_tukeyhsd
tukey = pairwise_tukeyhsd(df['value'], df['group'])
```

### P4.4.4 Chi-Square Test

**Purpose:** Test association between two categorical variables.

$$\chi^2 = \sum \frac{(O - E)^2}{E}$$

```python
from scipy.stats import chi2_contingency
contingency = pd.crosstab(df['var1'], df['var2'])
chi2, p_value, dof, expected = chi2_contingency(contingency)
```

### P4.4.5 Non-Parametric Tests (When Assumptions Fail)

| Parametric | Non-Parametric | Use Case |
|------------|----------------|----------|
| T-test | Mann-Whitney U | Compare 2 groups |
| ANOVA | Kruskal-Wallis | Compare >2 groups |
| Pearson | Spearman | Correlation |
| T-test (paired) | Wilcoxon | Paired comparison |

```python
# Mann-Whitney U
from scipy.stats import mannwhitneyu
u_stat, p_value = mannwhitneyu(group1, group2)

# Kruskal-Wallis
from scipy.stats import kruskal
h_stat, p_value = kruskal(group1, group2, group3)

# Wilcoxon signed-rank
from scipy.stats import wilcoxon
w_stat, p_value = wilcoxon(before, after)
```

---

## P4.5 Confidence Intervals

**Definition:** Range of values that likely contains the true population parameter.

**Formula (for mean):**
$$CI = \bar{x} \pm z \times \frac{\sigma}{\sqrt{n}}$$

**Common z-values:**
- 90% CI: z = 1.645
- 95% CI: z = 1.96
- 99% CI: z = 2.576

```python
def confidence_interval(data, confidence=0.95):
    n = len(data)
    mean = np.mean(data)
    se = stats.sem(data)  # Standard error of the mean
    ci = stats.t.interval(confidence, n-1, loc=mean, scale=se)
    return ci

ci_lower, ci_upper = confidence_interval(df['value'])
print(f"95% CI: [{ci_lower:.2f}, {ci_upper:.2f}]")
```

---

## P4.6 Regression Analysis

### P4.6.1 Simple Linear Regression

$$y = \beta_0 + \beta_1 x + \varepsilon$$

Where:
- β₀ = Intercept
- β₁ = Slope
- ε = Error term

```python
from scipy.stats import linregress
slope, intercept, r, p_value, std_err = linregress(x, y)

# Using statsmodels
import statsmodels.api as sm
X = sm.add_constant(x)
model = sm.OLS(y, X).fit()
print(model.summary())
```

### P4.6.2 Multiple Linear Regression

$$y = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + ... + \beta_k x_k + \varepsilon$$

```python
import statsmodels.api as sm
X = sm.add_constant(df[['x1', 'x2', 'x3']])
model = sm.OLS(df['y'], X).fit()
print(model.summary())
```

### P4.6.3 Interpreting Regression Output

| Metric | Meaning | Good Value |
|--------|---------|------------|
| **R²** | Proportion of variance explained | ≥ 0.7 for strong |
| **Adjusted R²** | R² penalized for number of predictors | Similar to R² |
| **p-value** | Significance of coefficient | < 0.05 |
| **F-statistic** | Overall model significance | p < 0.05 |
| **Coefficient** | Change in y per unit change in x | Interpret based on domain |

---

## P4.7 Central Limit Theorem

**The Most Important Theorem in Statistics**

**Statement:** The distribution of sample means approaches a normal distribution as sample size increases, regardless of the population distribution.

**Practical implication:**
Even if your data is not normal, the mean of your data will be approximately normal if you have a large enough sample.

**Rule of thumb:** n ≥ 30 is usually sufficient.

```python
# Demonstration
population = np.random.exponential(scale=2, size=100000)
sample_means = [np.mean(np.random.choice(population, size=30)) for _ in range(1000)]

# Sample means will be approximately normal
plt.hist(sample_means, bins=30, density=True)
plt.show()
```

---

## P4.8 Outlier Detection

### P4.8.1 Z-Score Method

$$z = \frac{x - \mu}{\sigma}$$

**Rule of thumb:** |z| > 3 indicates outlier.

```python
z_scores = np.abs((data - np.mean(data)) / np.std(data))
outliers = data[z_scores > 3]
```

### P4.8.2 IQR Method

$$IQR = Q_3 - Q_1$$

Outliers: values below Q1 - 1.5×IQR or above Q3 + 1.5×IQR.

```python
q1 = np.percentile(data, 25)
q3 = np.percentile(data, 75)
iqr = q3 - q1
lower = q1 - 1.5 * iqr
upper = q3 + 1.5 * iqr
outliers = data[(data < lower) | (data > upper)]
```

### P4.8.3 Modified Z-Score (Robust)

$$M = 0.6745 \times \frac{x - \text{median}}{\text{MAD}}$$

Where MAD = Median Absolute Deviation.

**Rule of thumb:** |M| > 3.5 indicates outlier.

```python
from scipy.stats import median_abs_deviation
median = np.median(data)
mad = median_abs_deviation(data)
modified_z = 0.6745 * (data - median) / mad
outliers = data[np.abs(modified_z) > 3.5]
```

---

## P4.9 Transformations

### P4.9.1 When to Transform

1. **Skewness:** Distribution is highly skewed
2. **Heteroscedasticity:** Variance is not constant
3. **Non-linearity:** Relationship is curved
4. **Normality assumption:** Needed for parametric tests

### P4.9.2 Common Transformations

| Transformation | Formula | Use Case |
|----------------|---------|----------|
| **Log** | log(x) | Right-skewed |
| **Square Root** | sqrt(x) | Count data |
| **Reciprocal** | 1/x | Right-skewed |
| **Square** | x² | Left-skewed |
| **Box-Cox** | (x^λ - 1)/λ | General-purpose |

```python
# Log transformation
df['log_value'] = np.log(df['value'] + 1)  # +1 for zeros

# Square root
df['sqrt_value'] = np.sqrt(df['value'])

# Box-Cox
from scipy.stats import boxcox
df['bc_value'], lambda_ = boxcox(df['value'] + 1)
print(f"Optimal lambda: {lambda_}")
```

---

## P4.10 Statistical Power and Sample Size

### P4.10.1 Statistical Power

**Definition:** Probability of detecting an effect when it truly exists.

**Components:**
1. Effect size: How large is the effect?
2. Sample size: How many observations?
3. Alpha (α): Significance level (typically 0.05)
4. Power: 1 - β (typically 0.80)

**Interpretation:**
- Power = 0.80 means 80% chance of detecting a true effect
- Low power = high chance of Type II error (false negative)

### P4.10.2 Sample Size Estimation

```python
# Using statsmodels for power analysis
from statsmodels.stats.power import TTestIndPower

# Estimate sample size for t-test
analysis = TTestIndPower()
effect_size = 0.5  # Medium effect
power = 0.8
alpha = 0.05

sample_size = analysis.solve_power(
    effect_size=effect_size,
    power=power,
    alpha=alpha,
    ratio=1
)
print(f"Required sample size: {sample_size:.0f}")
```

**Rule of thumb:**
- For correlations: n > 30 + 5k
- For t-tests: n > 30 per group
- For regression: n > 10 per predictor

---

## P4.11 Common Statistical Tests Quick Reference

| Test | Purpose | Data Type | Assumptions |
|------|---------|-----------|-------------|
| **T-test** | Compare 2 group means | Numeric, 2 groups | Normal, equal variance |
| **ANOVA** | Compare >2 group means | Numeric, >2 groups | Normal, equal variance |
| **Mann-Whitney U** | Compare 2 groups (non-parametric) | Numeric/Ordinal | Independent, not normal |
| **Kruskal-Wallis** | Compare >2 groups (non-parametric) | Numeric/Ordinal | Independent, not normal |
| **Chi-Square** | Association between categories | Categorical | Expected counts >5 |
| **Pearson** | Linear correlation | Numeric | Normal, linear |
| **Spearman** | Monotonic correlation | Numeric/Ordinal | Monotonic |
| **Shapiro-Wilk** | Test normality | Numeric | - |
| **Levene's** | Test equal variance | Numeric | - |

---

## P4.12 Key Takeaways

1. **Know your data** - Understand distributions, central tendency, and spread
2. **Choose appropriate tests** - Match test to data type and assumptions
3. **Check assumptions** - Normality, equal variance, independence
4. **Transform when needed** - Log, sqrt, or Box-Cox for skewed data
5. **Interpret with context** - Statistical significance ≠ practical significance
6. **Use confidence intervals** - More informative than p-values alone
7. **Consider sample size** - Small samples lack power
8. **Be wary of outliers** - Detect and handle appropriately

This primer covers the essential statistical concepts you'll encounter throughout the series. Keep it handy as a reference when you need to understand the mathematical foundations behind your analysis.
