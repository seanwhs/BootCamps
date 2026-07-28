# Appendix B: Statistical Concepts Deep Dive

## Understanding the Mathematics Behind Exploratory Data Analysis

---

#### Purpose of This Appendix

This appendix provides a comprehensive deep dive into the statistical concepts we used throughout the series. While the main tutorials focused on practical implementation, this appendix explains the *why* behind the methods—the mathematical foundations, assumptions, and interpretations that make your analysis robust and defensible.

Think of this as your statistical reference manual. When you encounter a concept in the wild or need to explain your analysis to stakeholders, you'll find clear, accessible explanations here.

---

## B.1 Descriptive Statistics

### B.1.1 Measures of Central Tendency

#### Mean (Arithmetic Average)

**Definition:** The sum of all values divided by the number of values.

**Formula:**
$$\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$$

**When to use:**
- Symmetric distributions (normal-like)
- When you need a single representative value
- When subsequent calculations require a mathematical average

**Example:**
```python
import numpy as np
data = [2, 4, 6, 8, 10]
mean = np.mean(data)  # 6.0
```

**Weaknesses:**
- Highly sensitive to outliers (skewed distributions)
- Not robust for ordinal data
- May not represent the "typical" value in skewed data

#### Median

**Definition:** The middle value when data is sorted (50th percentile).

**Formula:**
- If n is odd: Median = value at position (n+1)/2
- If n is even: Median = average of values at positions n/2 and (n/2)+1

**When to use:**
- Skewed distributions
- When outliers are present
- Ordinal data
- When you want the "typical" value

**Example:**
```python
data = [2, 4, 6, 8, 100]  # Contains outlier
median = np.median(data)  # 6.0 (not pulled by 100)
mean = np.mean(data)      # 24.0 (pulled up by outlier)
```

**Why it matters:**
In our customer data, order_frequency is right-skewed (most customers order infrequently, a few order very often). The median better represents the "typical" customer's behavior than the mean.

#### Mode

**Definition:** The most frequently occurring value(s).

**When to use:**
- Categorical data
- When you need the most common category
- Understanding the "typical" member of a population

**Example:**
```python
from scipy import stats
data = ['A', 'B', 'A', 'C', 'A', 'B']
mode = stats.mode(data)  # 'A'
```

### B.1.2 Measures of Dispersion (Spread)

#### Variance

**Definition:** Average of squared deviations from the mean.

**Formula:**
$$\sigma^2 = \frac{1}{n}\sum_{i=1}^{n} (x_i - \bar{x})^2$$

**Population vs. Sample:**
- Population variance: divide by n
- Sample variance: divide by (n-1) (Bessel's correction)

**Why squared?**
Squaring ensures all deviations are positive and penalizes larger deviations more heavily.

**Example:**
```python
data = [2, 4, 6, 8, 10]
variance = np.var(data, ddof=1)  # Sample variance: 10.0
```

#### Standard Deviation

**Definition:** Square root of variance (returns to original units).

**Formula:**
$$\sigma = \sqrt{\sigma^2}$$

**Interpretation:**
- 68% of data falls within ±1σ of mean (normal distribution)
- 95% within ±2σ
- 99.7% within ±3σ

**Example:**
```python
std_dev = np.std(data, ddof=1)  # 3.16
```

#### Range and Interquartile Range (IQR)

**Range:** Max - Min (sensitive to outliers)

**IQR:** Q3 - Q1 (75th percentile - 25th percentile)

**Formula:**
$$IQR = Q_3 - Q_1$$

**When to use:**
- Describing spread without outlier influence
- Identifying outliers (values beyond Q1 - 1.5*IQR or Q3 + 1.5*IQR)

**Example:**
```python
q1 = np.percentile(data, 25)
q3 = np.percentile(data, 75)
iqr = q3 - q1

# Outlier detection
lower_bound = q1 - 1.5 * iqr
upper_bound = q3 + 1.5 * iqr
outliers = [x for x in data if x < lower_bound or x > upper_bound]
```

### B.1.3 Shape Statistics

#### Skewness

**Definition:** Measure of asymmetry in a distribution.

**Formula:**
$$\text{Skewness} = \frac{1}{n}\sum_{i=1}^{n} \left(\frac{x_i - \bar{x}}{\sigma}\right)^3$$

**Interpretation:**
- **Skewness = 0:** Symmetric distribution
- **Skewness > 0:** Right-skewed (positive skew, long tail on right)
- **Skewness < 0:** Left-skewed (negative skew, long tail on left)

**Practical meaning:**
- Right-skewed (positive): Mean > Median (e.g., income, order frequency)
- Left-skewed (negative): Mean < Median (e.g., exam scores, customer ratings)

**Example from our data:**
```python
# In our customer data, order_frequency is right-skewed
skewness = df['order_frequency'].skew()  # ~1.2 (moderately right-skewed)
```

**Why it matters:**
Many statistical tests assume normality. Skewed data may need transformation (log, square root, Box-Cox) before modeling.

#### Kurtosis

**Definition:** Measure of "tailedness" of a distribution.

**Formula:**
$$\text{Kurtosis} = \frac{1}{n}\sum_{i=1}^{n} \left(\frac{x_i - \bar{x}}{\sigma}\right)^4 - 3$$

**Interpretation:**
- **Kurtosis = 0:** Normal distribution (mesokurtic)
- **Kurtosis > 0:** Heavy tails, sharp peak (leptokurtic)
- **Kurtosis < 0:** Light tails, flat peak (platykurtic)

**Practical meaning:**
- High kurtosis (leptokurtic): More extreme outliers than normal distribution
- Low kurtosis (platykurtic): Fewer extreme outliers, more uniform-like

**Example:**
```python
kurtosis = df['customer_rating'].kurtosis()  # Negative = platykurtic
```

**Why it matters:**
High kurtosis indicates risk of extreme values. In customer data, this might indicate high-value customers or extreme dissatisfaction.

---

## B.2 Correlation and Association

### B.2.1 Pearson Correlation Coefficient

**Definition:** Measures linear relationship between two continuous variables.

**Formula:**
$$r = \frac{\sum_{i=1}^{n} (x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum_{i=1}^{n} (x_i - \bar{x})^2 \sum_{i=1}^{n} (y_i - \bar{y})^2}}$$

**Range:** -1 to +1

**Interpretation:**

| r value | Strength | Direction |
|---------|----------|-----------|
| 0.00 - 0.19 | Very weak | Negligible |
| 0.20 - 0.39 | Weak | Small effect |
| 0.40 - 0.59 | Moderate | Medium effect |
| 0.60 - 0.79 | Strong | Large effect |
| 0.80 - 1.00 | Very strong | Very large effect |

**Assumptions:**
1. Linear relationship
2. Normal distribution (or at least not heavily skewed)
3. No outliers
4. Homoscedasticity (constant variance)

**Example:**
```python
from scipy.stats import pearsonr
r, p_value = pearsonr(df['time_on_site'], df['pages_viewed'])
# r ≈ 0.72 (strong positive correlation)
```

**Caveat: Correlation ≠ Causation!**

Just because two variables are correlated doesn't mean one causes the other. There could be:
- **Reverse causation:** Y causes X instead of X causing Y
- **Third variable:** Z causes both X and Y (confounding)
- **Coincidence:** Spurious correlation

### B.2.2 Spearman Rank Correlation

**Definition:** Measures monotonic relationship (not necessarily linear) between variables.

**How it works:**
1. Rank all values (convert to ranks)
2. Apply Pearson correlation to ranks

**Formula:**
$$\rho = 1 - \frac{6\sum d_i^2}{n(n^2 - 1)}$$

Where d_i is the difference between ranks.

**When to use:**
- Non-linear relationships
- Ordinal data
- Non-normal distributions
- When Pearson assumptions are violated

**Example:**
```python
from scipy.stats import spearmanr
rho, p_value = spearmanr(df['income_numeric'], df['avg_order_value'])
```

**Comparison:**
- Pearson: Captures linear relationships (straight line)
- Spearman: Captures monotonic relationships (always increasing or decreasing, but not necessarily at a constant rate)

### B.2.3 Cramér's V

**Definition:** Measures association between two categorical variables.

**Formula:**
$$V = \sqrt{\frac{\chi^2}{n \times \min(k-1, r-1)}}$$

Where:
- χ² = Chi-square statistic
- n = Total sample size
- k = Number of columns
- r = Number of rows

**Range:** 0 to 1

**Interpretation:**

| V value | Interpretation |
|---------|----------------|
| 0.00 - 0.10 | Very weak association |
| 0.10 - 0.25 | Moderate association |
| 0.25 - 0.40 | Strong association |
| > 0.40 | Very strong association |

**Example:**
```python
def cramers_v(confusion_matrix):
    chi2 = stats.chi2_contingency(confusion_matrix)[0]
    n = confusion_matrix.sum().sum()
    min_dim = min(confusion_matrix.shape) - 1
    return np.sqrt(chi2 / (n * min_dim))

# Example: Gender vs Favorite Category
confusion = pd.crosstab(df['gender'], df['favorite_category'])
v = cramers_v(confusion)  # ≈ 0.25 (moderate association)
```

---

## B.3 Hypothesis Testing

### B.3.1 Understanding p-values

**Definition:** The probability of observing your data (or more extreme) if the null hypothesis is true.

**Interpretation:**
- p < 0.05: Statistically significant (reject null hypothesis)
- p > 0.05: Not statistically significant (fail to reject null)

**Common Misconceptions:**
- ❌ p < 0.05 means your result is important or meaningful
- ❌ p > 0.05 means there is no effect
- ✅ p < 0.05 means the result is unlikely due to chance alone

**Example:**
```python
from scipy.stats import ttest_ind
t_stat, p_value = ttest_ind(group1, group2)
if p_value < 0.05:
    print("Significant difference between groups")
else:
    print("No significant difference")
```

### B.3.2 T-Test

**Purpose:** Compare means of two groups.

**Types:**
1. **Independent t-test:** Compare two different groups
2. **Paired t-test:** Compare same group at two time points
3. **One-sample t-test:** Compare mean to a known value

**Assumptions:**
1. Independent observations
2. Normal distribution (or large sample size)
3. Homogeneity of variance (equal variance between groups)

**Example (Independent t-test):**
```python
# Compare male vs female order frequency
male_orders = df[df['gender'] == 'Male']['order_frequency']
female_orders = df[df['gender'] == 'Female']['order_frequency']
t_stat, p_value = ttest_ind(male_orders, female_orders)
```

### B.3.3 ANOVA (Analysis of Variance)

**Purpose:** Compare means of three or more groups.

**Formula:**
$$F = \frac{\text{Between-group variance}}{\text{Within-group variance}}$$

**Interpretation:**
- F > 1: Some groups differ
- F ≈ 1: Groups are similar

**Example:**
```python
from scipy.stats import f_oneway

# Compare order frequency across income brackets
groups = []
for bracket in df['income_bracket'].unique():
    groups.append(df[df['income_bracket'] == bracket]['order_frequency'])
    
f_stat, p_value = f_oneway(*groups)
if p_value < 0.05:
    print("Significant differences between income groups")
```

**Post-hoc tests:** If ANOVA is significant, use Tukey's HSD to find which specific groups differ.

### B.3.4 Chi-Square Test

**Purpose:** Test association between two categorical variables.

**Formula:**
$$\chi^2 = \sum \frac{(O - E)^2}{E}$$

Where O = Observed frequency, E = Expected frequency (under independence)

**Example:**
```python
from scipy.stats import chi2_contingency

contingency = pd.crosstab(df['gender'], df['favorite_category'])
chi2, p_value, dof, expected = chi2_contingency(contingency)
```

---

## B.4 Distribution Theory

### B.4.1 Normal Distribution (Gaussian)

**The "Bell Curve"**

**PDF Formula:**
$$f(x) = \frac{1}{\sigma\sqrt{2\pi}} e^{-\frac{(x-\mu)^2}{2\sigma^2}}$$

**Properties:**
- Symmetric around mean
- Mean = Median = Mode
- 68-95-99.7 rule
- Described by μ (mean) and σ (standard deviation)

**When it appears:**
- Heights, weights, test scores
- Many natural phenomena
- Sample means (Central Limit Theorem)

**Check for normality:**
```python
from scipy.stats import shapiro, normaltest

# Shapiro-Wilk test
stat, p = shapiro(data)
if p > 0.05:
    print("Data appears normal")

# Q-Q plot
import scipy.stats as stats
stats.probplot(data, dist="norm", plot=plt)
plt.show()
```

### B.4.2 Log-Normal Distribution

**Definition:** Distribution whose logarithm is normally distributed.

**Properties:**
- Right-skewed
- Mean > Median
- Only positive values

**Real-world examples:**
- Income
- Order frequency
- Time on site
- Stock prices

**Transformation:**
```python
# Log transform to approximate normality
log_data = np.log(data)
```

### B.4.3 Uniform Distribution

**Properties:**
- All values equally likely
- Flat PDF (probability density function)

**Real-world examples:**
- Random number generation
- Customer arrival times (if no pattern)

### B.4.4 Poisson Distribution

**Definition:** Number of events in a fixed interval.

**PMF Formula:**
$$P(X = k) = \frac{e^{-\lambda}\lambda^k}{k!}$$

**Properties:**
- λ = mean = variance
- Models count data
- Right-skewed

**Real-world examples:**
- Number of orders per day
- Number of website visitors per hour

### B.4.5 Binomial Distribution

**Definition:** Number of successes in n trials.

**PMF Formula:**
$$P(X = k) = \binom{n}{k}p^k(1-p)^{n-k}$$

**Properties:**
- n = number of trials
- p = probability of success
- Discrete distribution

**Real-world examples:**
- Customer conversion (purchase or not)
- Email open rate (opened or not)

### B.4.6 Exponential Distribution

**Definition:** Time between events in a Poisson process.

**PDF Formula:**
$$f(x) = \lambda e^{-\lambda x}$$

**Properties:**
- Memoryless
- Right-skewed
- Models waiting times

**Real-world examples:**
- Time between customer visits
- Time until customer churns

---

## B.5 Central Limit Theorem

**The Most Important Theorem in Statistics**

**Statement:** The distribution of sample means approaches a normal distribution as sample size increases, regardless of the population distribution.

**Practical implication:**
Even if your data is not normal, the mean of your data will be approximately normal if you have a large enough sample.

**Rule of thumb:**
- n ≥ 30 is usually sufficient
- The theorem holds regardless of the underlying distribution

**Example:**
```python
import numpy as np
import matplotlib.pyplot as plt

# Generate 10,000 samples from non-normal distribution
population = np.random.exponential(scale=2, size=100000)

# Take 1000 samples of size 30
sample_means = []
for _ in range(1000):
    sample = np.random.choice(population, size=30)
    sample_means.append(sample.mean())

# Plot sample means - they will be approximately normal
plt.hist(sample_means, bins=30, density=True)
plt.show()
```

---

## B.6 Confidence Intervals

**Definition:** Range of values that likely contains the true population parameter.

**Formula (for mean):**
$$CI = \bar{x} \pm z \times \frac{\sigma}{\sqrt{n}}$$

Where z is the critical value:
- 90% CI: z = 1.645
- 95% CI: z = 1.96
- 99% CI: z = 2.576

**Interpretation:** If you repeated the experiment 100 times, 95% of the confidence intervals would contain the true mean.

**Example:**
```python
import scipy.stats as stats

def confidence_interval(data, confidence=0.95):
    n = len(data)
    mean = np.mean(data)
    se = stats.sem(data)  # Standard error of the mean
    ci = stats.t.interval(confidence, n-1, loc=mean, scale=se)
    return ci

ci_lower, ci_upper = confidence_interval(df['avg_order_value'])
print(f"95% CI: ${ci_lower:.2f} - ${ci_upper:.2f}")
```

---

## B.7 Outlier Detection Methods

### B.7.1 Z-Score Method

**Definition:** Number of standard deviations from the mean.

**Formula:**
$$z = \frac{x - \mu}{\sigma}$$

**Rule of thumb:**
- |z| > 3: Outlier
- |z| > 2: Potential outlier

**Limitations:**
- Assumes normal distribution
- Sensitive to extremes

**Example:**
```python
z_scores = np.abs((data - np.mean(data)) / np.std(data))
outliers = data[z_scores > 3]
```

### B.7.2 IQR Method

**Definition:** Values beyond Q1 - 1.5×IQR or Q3 + 1.5×IQR.

**Formula:**
- Lower bound: Q1 - 1.5 × IQR
- Upper bound: Q3 + 1.5 × IQR

**Advantages:**
- Robust to skewness
- No distribution assumption

**Example:**
```python
q1 = np.percentile(data, 25)
q3 = np.percentile(data, 75)
iqr = q3 - q1
lower = q1 - 1.5 * iqr
upper = q3 + 1.5 * iqr
outliers = data[(data < lower) | (data > upper)]
```

### B.7.3 Modified Z-Score

**Definition:** Uses median and MAD instead of mean and SD (robust to outliers).

**Formula:**
$$M = 0.6745 \times \frac{x - \text{median}}{\text{MAD}}$$

Where MAD = Median Absolute Deviation.

**Rule of thumb:** |M| > 3.5 indicates outlier.

**Advantages:**
- Robust to outliers
- Works with non-normal data

---

## B.8 Transformations

### B.8.1 When to Transform

Transform data when:
1. **Skewness:** Distribution is highly skewed
2. **Heteroscedasticity:** Variance is not constant
3. **Non-linearity:** Relationship is curved
4. **Normality assumption:** Needed for parametric tests

### B.8.2 Common Transformations

| Transformation | Formula | Use Case |
|----------------|---------|----------|
| **Log** | log(x) | Right-skewed, multiplicative effects |
| **Square Root** | sqrt(x) | Count data, Poisson-like |
| **Reciprocal** | 1/x | Right-skewed, rates |
| **Square** | x² | Left-skewed |
| **Box-Cox** | (x^λ - 1)/λ | General-purpose, finds best λ |

### B.8.3 Box-Cox Transformation

**Definition:** Family of power transformations that finds the best λ.

**Formula:**
$$T(x) = \begin{cases} 
\frac{x^\lambda - 1}{\lambda} & \text{if } \lambda \neq 0 \\
\ln(x) & \text{if } \lambda = 0 
\end{cases}$$

**Example:**
```python
from scipy.stats import boxcox

# Find optimal lambda and transform
transformed, lambda_ = boxcox(data + 1)  # +1 to handle zeros
print(f"Optimal lambda: {lambda_}")
```

---

## B.9 Statistical Power and Sample Size

### B.9.1 Statistical Power

**Definition:** Probability of detecting an effect when it truly exists.

**Components:**
1. **Effect size:** How large is the effect?
2. **Sample size:** How many observations?
3. **Alpha (α):** Significance level (typically 0.05)
4. **Power:** 1 - β (typically 0.80)

**Interpretation:**
- Power = 0.80 means 80% chance of detecting a true effect
- Low power = high chance of Type II error (false negative)

### B.9.2 Sample Size Determination

**Factors affecting required sample size:**
1. Smaller effect size → larger sample needed
2. Higher power → larger sample needed
3. Lower alpha → larger sample needed
4. Higher variability → larger sample needed

**Rule of thumb:**
- For correlations: n > 30 + 5k (where k = number of predictors)
- For t-tests: n > 30 per group
- For regression: n > 10 per predictor

---

## B.10 Common Statistical Tests Quick Reference

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

## B.11 Practical Examples from Our Dataset

### Example 1: Testing if Income Affects Order Value

```python
# ANOVA to test income effect
income_groups = [df[df['income_bracket'] == bracket]['avg_order_value'] 
                 for bracket in df['income_bracket'].unique()]
f_stat, p_val = f_oneway(*income_groups)
print(f"ANOVA: F={f_stat:.3f}, p={p_val:.4f}")

# Post-hoc: Pairwise t-tests with Bonferroni correction
from statsmodels.stats.multicomp import pairwise_tukeyhsd
tukey = pairwise_tukeyhsd(df['avg_order_value'], df['income_bracket'])
print(tukey)
```

### Example 2: Testing Correlation Between Engagement and Loyalty

```python
# Test if time_on_site correlates with order_frequency
pearson_r, p_pearson = pearsonr(df['time_on_site'], df['order_frequency'])
spearman_r, p_spearman = spearmanr(df['time_on_site'], df['order_frequency'])

print(f"Pearson: r={pearson_r:.3f}, p={p_pearson:.4f}")
print(f"Spearman: ρ={spearman_r:.3f}, p={p_spearman:.4f}")
```

### Example 3: Testing Segment Differences

```python
# Compare ratings between city tiers
city_groups = [df[df['city_tier'] == tier]['customer_rating'] 
               for tier in [1, 2, 3]]
h_stat, p_val = stats.kruskal(*city_groups)
print(f"Kruskal-Wallis: H={h_stat:.3f}, p={p_val:.4f}")
```

---

## B.12 Key Takeaways

1. **Descriptive statistics** provide the foundation for understanding your data
2. **Correlation does not imply causation** - always consider confounding variables
3. **Statistical tests** help you make data-driven decisions
4. **Confidence intervals** are more informative than p-values alone
5. **Transformations** can help meet statistical assumptions
6. **Sample size** affects your ability to detect effects
7. **Know your assumptions** - choose appropriate tests for your data

---

## B.13 Further Reading

**Books:**
- "Statistical Methods for the Social Sciences" by Alan Agresti
- "The Art of Statistics" by David Spiegelhalter
- "Naked Statistics" by Charles Wheelan

**Online Resources:**
- [OpenIntro Statistics](https://www.openintro.org/book/os/)
- [Khan Academy Statistics](https://www.khanacademy.org/math/statistics-probability)
- [StatQuest with Josh Starmer](https://statquest.org/) (YouTube)

**Python Libraries:**
- `scipy.stats`: Comprehensive statistical tests
- `statsmodels`: Statistical modeling and testing
- `pingouin`: User-friendly statistical tests

---

[END OF APPENDIX B]
