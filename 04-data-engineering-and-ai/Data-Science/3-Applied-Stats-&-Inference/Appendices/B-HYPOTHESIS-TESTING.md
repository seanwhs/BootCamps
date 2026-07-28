# APPENDIX B: COMPLETE REFERENCE — HYPOTHESIS TESTING

Welcome to the second appendix! This reference provides a comprehensive guide to hypothesis testing — the backbone of statistical decision-making. Think of this as your **hypothesis testing handbook** — everything you need to know about when, why, and how to use each test.

---

## B.1 The Hypothesis Testing Framework

### The Five Steps of Hypothesis Testing

1. **State the hypotheses**
   - **Null hypothesis (H₀)**: No effect or no difference
   - **Alternative hypothesis (H₁)**: An effect or difference exists

2. **Choose the significance level (α)**
   - Typically 0.05, 0.01, or 0.10
   - α = probability of Type I error (false positive)

3. **Select the appropriate test and calculate the test statistic**

4. **Determine the p-value**
   - Probability of observing results as extreme as those observed, assuming H₀ is true

5. **Make a decision**
   - If p < α: Reject H₀ (statistically significant)
   - If p ≥ α: Fail to reject H₀ (not statistically significant)

### Types of Errors

| | H₀ is True | H₀ is False |
|---|---|---|
| **Reject H₀** | **Type I Error (α)** | Correct Decision (Power = 1-β) |
| **Fail to Reject H₀** | Correct Decision | **Type II Error (β)** |

- **Type I Error (α)**: False positive — saying there's an effect when there isn't
- **Type II Error (β)**: False negative — saying there's no effect when there is
- **Power (1-β)**: Probability of detecting a real effect

---

## B.2 Parametric Tests Reference

### One-Sample t-Test

**Purpose:** Compare a sample mean to a known population mean

**Assumptions:**
- Data is continuous
- Data is approximately normally distributed
- Observations are independent

**Hypotheses:**
- H₀: μ = μ₀ (sample mean equals population mean)
- H₁: μ ≠ μ₀ (two-sided) or μ > μ₀ (one-sided)

**Test Statistic:**
$$t = \frac{\bar{x} - \mu_0}{s/\sqrt{n}}$$

**Degrees of Freedom:** $df = n - 1$

**When to Use:**
- Testing if a sample comes from a population with a specific mean
- Example: "Is the average height of our students different from the national average?"

**Implementation:**
```python
from scipy.stats import ttest_1samp

# Sample data
data = [72, 68, 70, 71, 69, 73, 72, 68, 70, 71]
population_mean = 70

# One-sample t-test
t_stat, p_value = ttest_1samp(data, population_mean)
# For one-sided: p_value/2 or use alternative parameter
```

---

### Two-Sample t-Test (Independent)

**Purpose:** Compare means of two independent groups

**Assumptions:**
- Data is continuous
- Both groups are approximately normally distributed
- Observations are independent
- Variances are approximately equal (for Student's t-test)
- Variances can differ (for Welch's t-test)

**Hypotheses:**
- H₀: μ₁ = μ₂ (group means are equal)
- H₁: μ₁ ≠ μ₂ (two-sided) or μ₁ > μ₂ (one-sided)

**Test Statistic (Welch's t-test):**
$$t = \frac{\bar{x}_1 - \bar{x}_2}{\sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}}$$

**Degrees of Freedom (Welch-Satterthwaite):**
$$df = \frac{(\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2})^2}{\frac{(s_1^2/n_1)^2}{n_1-1} + \frac{(s_2^2/n_2)^2}{n_2-1}}$$

**When to Use:**
- Comparing two groups (e.g., treatment vs control)
- Example: "Does the new drug lower blood pressure compared to placebo?"

**Implementation:**
```python
from scipy.stats import ttest_ind

# Control and treatment groups
control = [10, 12, 11, 9, 13, 10, 11, 12, 9, 10]
treatment = [14, 15, 13, 16, 12, 14, 15, 13, 16, 14]

# Welch's t-test (default, doesn't assume equal variances)
t_stat, p_value = ttest_ind(control, treatment, equal_var=False)

# Student's t-test (assumes equal variances)
t_stat, p_value = ttest_ind(control, treatment, equal_var=True)
```

---

### Paired t-Test

**Purpose:** Compare means of two related groups (before/after)

**Assumptions:**
- Differences are continuous
- Differences are approximately normally distributed
- Observations are paired

**Hypotheses:**
- H₀: μ_d = 0 (mean difference is zero)
- H₁: μ_d ≠ 0 (two-sided)

**Test Statistic:**
$$t = \frac{\bar{d}}{s_d/\sqrt{n}}$$

**Degrees of Freedom:** $df = n - 1$

**When to Use:**
- Before/after studies
- Same subjects measured twice
- Example: "Does the training program improve test scores?"

**Implementation:**
```python
from scipy.stats import ttest_rel

# Before and after measurements
before = [72, 68, 70, 71, 69, 73, 72, 68, 70, 71]
after = [78, 75, 76, 77, 74, 79, 76, 74, 75, 76]

t_stat, p_value = ttest_rel(before, after)
```

---

### One-Way ANOVA

**Purpose:** Compare means of three or more independent groups

**Assumptions:**
- Data is continuous
- Each group is approximately normally distributed
- Equal variances across groups (homoscedasticity)
- Observations are independent

**Hypotheses:**
- H₀: μ₁ = μ₂ = ... = μₖ (all group means are equal)
- H₁: At least one group mean differs

**Test Statistic:**
$$F = \frac{MS_{between}}{MS_{within}}$$

**Degrees of Freedom:**
- $df_{between} = k - 1$ (k = number of groups)
- $df_{within} = N - k$ (N = total sample size)

**When to Use:**
- Comparing multiple groups
- Example: "Do students from four different schools have different average test scores?"

**Implementation:**
```python
from scipy.stats import f_oneway

# Three groups
group1 = [10, 12, 11, 9, 13, 10]
group2 = [14, 15, 13, 16, 12, 14]
group3 = [18, 17, 19, 16, 20, 18]

f_stat, p_value = f_oneway(group1, group2, group3)

# If significant, perform post-hoc tests
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import numpy as np

all_data = np.concatenate([group1, group2, group3])
groups = np.concatenate([
    np.repeat('A', len(group1)),
    np.repeat('B', len(group2)),
    np.repeat('C', len(group3))
])

tukey = pairwise_tukeyhsd(all_data, groups, alpha=0.05)
print(tukey)
```

---

## B.3 Non-Parametric Tests Reference

### Mann-Whitney U Test

**Purpose:** Compare two independent groups (alternative to two-sample t-test)

**Assumptions:**
- Data is ordinal or continuous
- Independent observations
- No normality assumption required

**Hypotheses:**
- H₀: The distributions are identical
- H₁: One distribution tends to have larger values

**Test Statistic:**
$$U = n_1n_2 + \frac{n_1(n_1+1)}{2} - R_1$$

Where $R_1$ is the sum of ranks in group 1.

**Effect Size:**
$$r = \frac{Z}{\sqrt{N}}$$

**When to Use:**
- Data is not normally distributed
- Data is ordinal (ranked)
- Outliers are present

**Implementation:**
```python
from scipy.stats import mannwhitneyu

control = [10, 12, 11, 9, 13, 10, 11]
treatment = [14, 15, 13, 16, 12, 14, 15]

u_stat, p_value = mannwhitneyu(control, treatment, alternative='two-sided')
```

---

### Wilcoxon Signed-Rank Test

**Purpose:** Compare two related groups (alternative to paired t-test)

**Assumptions:**
- Data is ordinal or continuous
- Paired observations
- Differences are symmetric

**Hypotheses:**
- H₀: The median difference is zero
- H₁: The median difference is not zero

**Test Statistic:**
$$W = \sum_{i=1}^{n} \text{sign}(d_i) \cdot \text{rank}(|d_i|)$$

**When to Use:**
- Before/after studies with non-normal data
- Example: "Does the training program improve test scores (non-normal data)?"

**Implementation:**
```python
from scipy.stats import wilcoxon

before = [72, 68, 70, 71, 69, 73, 72]
after = [78, 75, 76, 77, 74, 79, 76]

w_stat, p_value = wilcoxon(before, after, alternative='two-sided')
```

---

### Kruskal-Wallis Test

**Purpose:** Compare three or more independent groups (alternative to ANOVA)

**Assumptions:**
- Data is ordinal or continuous
- Independent observations
- No normality assumption required

**Hypotheses:**
- H₀: All groups have the same distribution
- H₁: At least one group differs

**Test Statistic:**
$$H = \frac{12}{N(N+1)}\sum_{i=1}^{k} \frac{R_i^2}{n_i} - 3(N+1)$$

**Effect Size:**
$$\eta^2 = \frac{H - k + 1}{N - k}$$

**When to Use:**
- Data is not normally distributed
- Comparing multiple groups

**Implementation:**
```python
from scipy.stats import kruskal

group1 = [10, 12, 11, 9, 13, 10]
group2 = [14, 15, 13, 16, 12, 14]
group3 = [18, 17, 19, 16, 20, 18]

h_stat, p_value = kruskal(group1, group2, group3)

# For post-hoc, use pairwise Mann-Whitney U with Bonferroni correction
```

---

### Chi-Square Test of Independence

**Purpose:** Test if two categorical variables are independent

**Assumptions:**
- Data is categorical
- Expected frequencies ≥ 5 (for each cell)
- Observations are independent

**Hypotheses:**
- H₀: Variables are independent
- H₁: Variables are associated

**Test Statistic:**
$$\chi^2 = \sum \frac{(O - E)^2}{E}$$

**Degrees of Freedom:** $df = (r-1)(c-1)$

**Effect Size (Cramer's V):**
$$V = \sqrt{\frac{\chi^2}{n \cdot \min(r-1, c-1)}}$$

**When to Use:**
- Analyzing contingency tables
- Example: "Is there an association between gender and product preference?"

**Implementation:**
```python
from scipy.stats import chi2_contingency
import numpy as np

# Contingency table: [Gender] x [Product Preference]
table = np.array([
    [30, 20, 10],  # Male preferences
    [25, 25, 30]   # Female preferences
])

chi2, p_value, dof, expected = chi2_contingency(table)
```

---

### Fisher's Exact Test

**Purpose:** Test independence in 2x2 contingency tables (especially small samples)

**Assumptions:**
- Data is categorical
- 2x2 table only
- No minimum expected frequency requirement

**Hypotheses:**
- H₀: Variables are independent
- H₁: Variables are associated

**Test Statistic:** Probability of observing the exact table (or more extreme)

**When to Use:**
- Small sample sizes
- Expected frequencies < 5

**Implementation:**
```python
from scipy.stats import fisher_exact

# 2x2 contingency table
table = np.array([[10, 5], [3, 12]])  # [treatment, control] x [success, failure]

odds_ratio, p_value = fisher_exact(table, alternative='two-sided')
```

---

## B.4 Multiple Testing Corrections

### Why Multiple Testing Corrections Matter

**The Problem:** If you run 100 independent tests at α = 0.05, you'd expect ~5 false positives by chance alone!

### Family-Wise Error Rate (FWER) Methods

**Bonferroni Correction**
- Most conservative
- Adjusts α: α' = α / m (m = number of tests)
- Guarantees FWER ≤ α
- Can be too conservative (low power)

**Holm-Bonferroni Correction**
- Step-down procedure
- Less conservative than Bonferroni
- Still controls FWER
- More powerful than Bonferroni

### False Discovery Rate (FDR) Methods

**Benjamini-Hochberg**
- Controls expected proportion of false positives
- Less conservative than FWER methods
- More power for large-scale testing
- Good for exploratory research

### Comparison of Methods

| Method | Controls | Power | Best Used For |
|--------|----------|-------|---------------|
| Bonferroni | FWER | Low | Confirmatory studies, few tests |
| Holm-Bonferroni | FWER | Medium | Confirmatory studies, medium tests |
| Benjamini-Hochberg | FDR | High | Exploratory studies, many tests |

**Implementation:**
```python
# Raw p-values from multiple tests
p_values = [0.001, 0.01, 0.03, 0.05, 0.10, 0.20, 0.50]

# Bonferroni
adjusted_bonf = np.minimum(p_values * len(p_values), 1.0)

# Benjamini-Hochberg
from statsmodels.stats.multitest import multipletests
rejected, adjusted_fdr, _, _ = multipletests(p_values, alpha=0.05, method='fdr_bh')
```

---

## B.5 Effect Sizes Reference

### For t-Tests

**Cohen's d:**
$$d = \frac{\bar{x}_1 - \bar{x}_2}{s_{pooled}}$$

**Interpretation:**
- d = 0.2: Small effect
- d = 0.5: Medium effect
- d = 0.8: Large effect

**Implementation:**
```python
def cohens_d(group1, group2):
    n1, n2 = len(group1), len(group2)
    mean1, mean2 = np.mean(group1), np.mean(group2)
    var1, var2 = np.var(group1, ddof=1), np.var(group2, ddof=1)
    pooled_std = np.sqrt(((n1-1)*var1 + (n2-1)*var2) / (n1+n2-2))
    return (mean1 - mean2) / pooled_std
```

### For ANOVA

**Eta-Squared (η²):**
$$\eta^2 = \frac{SS_{between}}{SS_{total}}$$

**Interpretation:**
- η² = 0.01: Small effect
- η² = 0.06: Medium effect
- η² = 0.14: Large effect

### For Chi-Square

**Cramer's V:**
$$V = \sqrt{\frac{\chi^2}{n \cdot \min(r-1, c-1)}}$$

**Interpretation:**
- V = 0.1: Small effect
- V = 0.3: Medium effect
- V = 0.5: Large effect

### For Mann-Whitney U

**Rank-biserial Correlation (r):**
$$r = \frac{Z}{\sqrt{N}}$$

**Interpretation:**
- r = 0.1: Small effect
- r = 0.3: Medium effect
- r = 0.5: Large effect

---

## B.6 Power Analysis Reference

### Key Concepts

- **Power** = Probability of detecting a real effect
- **Target power** typically 0.80 (80%)
- **Alpha** typically 0.05 (5%)

### Sample Size Calculations

**For Two-Sample t-Test (equal n):**
$$n = \frac{2(z_{1-\alpha/2} + z_{1-\beta})^2}{d^2}$$

**For Two-Proportion Test (equal n):**
$$n = \frac{(z_{1-\alpha/2} + z_{1-\beta})^2[p_1(1-p_1) + p_2(1-p_2)]}{(p_2 - p_1)^2}$$

### Power Curves

Power curves show how power changes with sample size and effect size:

```
Power
 1.0 |                    ____----
     |                 __/
 0.8 |              __/
     |            _/
 0.6 |          _/
     |        _/
 0.4 |      _/
     |    _/
 0.2 |  _/
     |_/
 0.0 |_________________________________
      0    100   200   300   400   500
                  Sample Size (n)
```

---

## B.7 Quick Reference: Test Selection

### Comparing Two Groups

| Data Type | Independent | Paired |
|-----------|-------------|--------|
| **Normal** | t-test (equal variance) or Welch's t-test | Paired t-test |
| **Non-normal** | Mann-Whitney U | Wilcoxon signed-rank |
| **Binary** | Chi-square or Fisher's exact | McNemar's test |

### Comparing Three+ Groups

| Data Type | Test |
|-----------|------|
| **Normal** | One-way ANOVA |
| **Non-normal** | Kruskal-Wallis |
| **Categorical** | Chi-square |

### Association Between Variables

| Variable Types | Test |
|----------------|------|
| **Continuous + Continuous** | Pearson correlation (normal) or Spearman (non-normal) |
| **Continuous + Categorical** | t-test or ANOVA |
| **Categorical + Categorical** | Chi-square or Fisher's exact |

### Decision Tree

```
What is the dependent variable?
│
├── Continuous
│   │
│   ├── How many groups?
│   │   ├── 1 group → One-sample t-test
│   │   ├── 2 groups
│   │   │   ├── Independent → t-test or Mann-Whitney U
│   │   │   └── Paired → Paired t-test or Wilcoxon
│   │   └── 3+ groups
│   │       ├── Independent → ANOVA or Kruskal-Wallis
│   │       └── Paired → Repeated measures ANOVA
│   │
│   └── Relationship → Correlation (Pearson/Spearman)
│
└── Categorical
    │
    └── Relationship → Chi-square or Fisher's exact
```

---

## B.8 Common Pitfalls and Solutions

| Pitfall | Solution |
|---------|----------|
| **P-hacking** | Pre-register analysis plan, use corrections |
| **Ignoring assumptions** | Always check assumptions before testing |
| **Multiple testing without correction** | Apply Bonferroni or FDR corrections |
| **Focusing only on p-values** | Report effect sizes and confidence intervals |
| **Sample size too small** | Use power analysis before collecting data |
| **Interpreting non-significance as no effect** | Not significant ≠ no effect (could be underpowered) |
| **Using parametric tests on non-normal data** | Use non-parametric alternatives or transform data |

---

## B.9 Reporting Standards

### What to Include in Your Report

1. **Effect Size**: Cohen's d, η², Cramer's V, etc.
2. **Confidence Intervals**: 95% CI for effect size
3. **Test Statistic**: t, F, χ², U, etc. with degrees of freedom
4. **P-value**: Exact p-value (e.g., p = 0.023)
5. **Sample Size**: n for each group
6. **Assumption Checks**: Normality tests, variance tests, etc.

### Example Report

> A two-sample t-test was conducted to compare conversion rates between the control (M = 0.10, SD = 0.30) and treatment (M = 0.12, SD = 0.32) groups. The test was statistically significant (t(1998) = 2.45, p = 0.014, Cohen's d = 0.11, 95% CI [0.02, 0.20]), indicating that the treatment group had significantly higher conversion rates. The effect size was small according to Cohen's conventions.

---

## B.10 Summary: Key Takeaways

1. **Always check assumptions** before choosing a test
2. **Parametric tests** are more powerful but require normality
3. **Non-parametric tests** are robust and assumption-free
4. **Effect sizes** matter more than p-values
5. **Multiple testing corrections** prevent false positives
6. **Power analysis** ensures you have enough data
7. **Report everything** — effect sizes, CIs, and test statistics

---

**Next Appendix: C — Complete Reference: Regression & Diagnostics**
