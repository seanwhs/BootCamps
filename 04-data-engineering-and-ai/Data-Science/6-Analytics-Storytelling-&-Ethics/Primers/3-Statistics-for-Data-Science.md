# Primer 3: Statistics for Data Science

## Introduction to This Primer

### Why This Primer Exists

Statistics is the language of data science. It's how we separate signal from noise, quantify uncertainty, and make data-driven decisions with confidence. This primer bridges the gap between "I know what a mean is" and "I can interpret a p-value in the context of business decisions."

Think of this as your **"statistical translator"** - it takes complex concepts and translates them into practical, actionable understanding.

### What This Primer Covers

1. **Descriptive Statistics** - Summarizing data
2. **Probability Fundamentals** - Understanding chance and uncertainty
3. **Statistical Distributions** - The shapes of data
4. **Hypothesis Testing** - Making decisions with data
5. **Confidence Intervals** - Quantifying uncertainty
6. **Correlation and Causation** - Understanding relationships
7. **Regression Basics** - Predicting outcomes
8. **Business Statistics** - Practical applications

### How to Use This Primer
- **As a reference:** Look up statistical concepts when you encounter them
- **As a tutorial:** Follow the examples to build intuition
- **As a decision guide:** Use the frameworks for practical business decisions

---

## Chapter 1: Descriptive Statistics

### 1.1 Measures of Central Tendency

**The Concept:** Central tendency tells us where the "center" of our data is. It answers: "What's a typical value?"

**Three Types:**

| Measure | What It Is | When To Use |
|---------|-----------|-------------|
| **Mean** | Average (sum ÷ count) | Symmetric data, no outliers |
| **Median** | Middle value | Skewed data, outliers present |
| **Mode** | Most frequent value | Categorical data |

**Business Example - Customer Revenue:**

```python
import numpy as np
import pandas as pd
from scipy import stats

# Sample customer revenue data (monthly)
revenue = [50, 75, 100, 100, 125, 150, 200, 250, 300, 500, 1000, 5000]

# Calculate measures
mean_revenue = np.mean(revenue)        # 729.17 (inflated by outliers)
median_revenue = np.median(revenue)    # 175.00 (better representation)
mode_revenue = stats.mode(revenue)     # 100 (most common)

print(f"Mean revenue: ${mean_revenue:.2f}")
print(f"Median revenue: ${median_revenue:.2f}")
print(f"Mode revenue: ${mode_revenue.mode[0]:.2f}")

# Business translation:
# "The average customer spends $729 per month, but the typical customer spends $175.
#  This difference suggests we have a small number of very high-value customers
#  that are pulling up the average."
```

### 1.2 Measures of Dispersion

**The Concept:** Dispersion tells us how spread out our data is. It answers: "How much do values vary?"

| Measure | What It Tells Us | Business Meaning |
|---------|------------------|------------------|
| **Range** | Max - Min | Full extent of variation |
| **Standard Deviation** | Average distance from mean | Typical variation |
| **Variance** | Standard deviation² | Square of typical variation |
| **Interquartile Range (IQR)** | 75th - 25th percentile | Middle 50% spread |

**Our Examples:**

```python
# Sample revenue data
revenue = [50, 75, 100, 100, 125, 150, 200, 250, 300, 500, 1000, 5000]

# Calculate dispersion
range_revenue = np.max(revenue) - np.min(revenue)  # 4950
std_revenue = np.std(revenue)                      # 1438.91
var_revenue = np.var(revenue)                      # 2,070,486
q1 = np.percentile(revenue, 25)                   # 106.25
q3 = np.percentile(revenue, 75)                   # 287.50
iqr = q3 - q1                                     # 181.25

# Percentiles (more detailed view)
percentiles = [10, 25, 50, 75, 90]
values = np.percentile(revenue, percentiles)

print("Revenue Distribution:")
for p, v in zip(percentiles, values):
    print(f"  {p}th percentile: ${v:.2f}")

# Business translation:
# "The typical customer (median) spends $175.
#  The middle 50% of customers spend between $106 and $288.
#  90% of customers spend $1,200 or less, but the top 10% spend much more.
#  This suggests we should focus on upselling to our top customers."
```

### 1.3 Shape of Distribution

**The Concept:** Distribution shape tells us about the symmetry and tails of our data.

**Skewness:**
- **Positive (Right) Skew:** Long tail on the right (many low values, few high values)
- **Negative (Left) Skew:** Long tail on the left (few low values, many high values)
- **Zero Skew:** Symmetric (bell curve)

**Kurtosis:**
- **High Kurtosis:** Heavy tails (more outliers)
- **Low Kurtosis:** Light tails (fewer outliers)

**Our Examples:**

```python
import matplotlib.pyplot as plt
import seaborn as sns

# Right-skewed data (customer revenue)
right_skewed = np.random.exponential(scale=100, size=1000)

# Left-skewed data (customer satisfaction scores)
left_skewed = np.random.beta(a=2, b=5, size=1000) * 100

# Normal data (ideal distribution)
normal = np.random.normal(loc=50, scale=15, size=1000)

# Calculate skewness
from scipy.stats import skew, kurtosis

print(f"Revenue skewness: {skew(right_skewed):.3f} (positive = right-skewed)")
print(f"Satisfaction skewness: {skew(left_skewed):.3f} (negative = left-skewed)")
print(f"Normal skewness: {skew(normal):.3f} (zero = symmetric)")

# Visualize
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Right skew
axes[0].hist(right_skewed, bins=30, alpha=0.7, color='blue')
axes[0].set_title('Right-Skewed (Positive)')
axes[0].axvline(np.mean(right_skewed), color='red', linestyle='--', label='Mean')
axes[0].axvline(np.median(right_skewed), color='green', linestyle='--', label='Median')
axes[0].legend()

# Left skew
axes[1].hist(left_skewed, bins=30, alpha=0.7, color='red')
axes[1].set_title('Left-Skewed (Negative)')
axes[1].axvline(np.mean(left_skewed), color='red', linestyle='--', label='Mean')
axes[1].axvline(np.median(left_skewed), color='green', linestyle='--', label='Median')
axes[1].legend()

# Normal
axes[2].hist(normal, bins=30, alpha=0.7, color='green')
axes[2].set_title('Symmetric (Normal)')
axes[2].axvline(np.mean(normal), color='red', linestyle='--', label='Mean')
axes[2].axvline(np.median(normal), color='green', linestyle='--', label='Median')
axes[2].legend()

plt.tight_layout()
plt.show()

# Business translation:
# "Revenue is right-skewed, meaning most customers spend less than average,
#  but a few customers spend significantly more. We should:
#  1. Focus on retaining our high-value customers (top 10%)
#  2. Find ways to move more customers into higher spending tiers
#  3. Use median (not mean) for typical customer spending"
```

---

## Chapter 2: Probability Fundamentals

### 2.1 Basic Probability

**The Concept:** Probability measures the likelihood of an event occurring. It ranges from 0 (impossible) to 1 (certain).

**Key Terms:**
- **Event:** Something that can happen (e.g., a customer churns)
- **Probability:** P(event) = number of favorable outcomes ÷ total possible outcomes
- **Complement:** 1 - P(event) (the probability it doesn't happen)

**Our Examples:**

```python
# Business example: Customer churn
total_customers = 1000
churned_customers = 150

# Probability of churn
prob_churn = churned_customers / total_customers
print(f"Probability of churn: {prob_churn:.2%}")

# Probability of NOT churning (complement)
prob_not_churn = 1 - prob_churn
print(f"Probability of not churning: {prob_not_churn:.2%}")

# Conditional probability: Probability of churn given high-risk segment
high_risk_customers = 200
high_risk_churned = 80

prob_churn_given_high_risk = high_risk_churned / high_risk_customers
print(f"Probability of churn given high-risk segment: {prob_churn_given_high_risk:.2%}")

# Business translation:
# "Overall churn rate is 15%, but high-risk customers churn at 40%.
#  This represents a 25 percentage point increase in churn risk,
#  suggesting our risk segmentation is working."
```

### 2.2 Probability Rules

**The Addition Rule:**
- P(A or B) = P(A) + P(B) - P(A and B)
- For mutually exclusive events: P(A or B) = P(A) + P(B)

**The Multiplication Rule:**
- P(A and B) = P(A) × P(B|A)
- For independent events: P(A and B) = P(A) × P(B)

**Our Examples:**

```python
# Example: Customer actions on a website
# Events:
# - Customer clicks email (C): P(C) = 0.25
# - Customer makes purchase (P): P(P) = 0.10
# - Customer both clicks and purchases: P(C and P) = 0.08

p_click = 0.25
p_purchase = 0.10
p_click_and_purchase = 0.08

# Probability of click OR purchase
p_click_or_purchase = p_click + p_purchase - p_click_and_purchase
print(f"Probability of click or purchase: {p_click_or_purchase:.2%}")

# Conditional: Probability of purchase given click
p_purchase_given_click = p_click_and_purchase / p_click
print(f"Probability of purchase given click: {p_purchase_given_click:.2%}")

# Conditional: Probability of click given purchase
p_click_given_purchase = p_click_and_purchase / p_purchase
print(f"Probability of click given purchase: {p_click_given_purchase:.2%}")

# Business translation:
# "Clicking an email increases purchase probability from 10% to 32%.
#  This 22 percentage point lift suggests email campaigns are effective.
#  Customers who purchase are 80% likely to have clicked an email."
```

### 2.3 Bayes' Theorem

**The Concept:** Bayes' Theorem updates probabilities as we get new information.

**Formula:**
P(A|B) = P(B|A) × P(A) / P(B)

**Our Examples:**

```python
# Business example: Customer churn prediction
# Prior: We know 15% of customers churn
# Evidence: Customer has low engagement (less than 3 logins/month)
# Question: Given low engagement, what's the probability of churn?

p_churn = 0.15                     # Prior probability
p_low_engagement = 0.30            # Probability of low engagement overall
p_low_engagement_given_churn = 0.70  # Probability of low engagement if churned

# Bayes' Theorem
p_churn_given_low_engagement = (
    p_low_engagement_given_churn * p_churn / p_low_engagement
)

print(f"Probability of churn given low engagement: {p_churn_given_low_engagement:.2%}")

# Business translation:
# "With low engagement, churn probability increases from 15% to 35%.
#  This means we should prioritize intervention for low-engagement customers."

# Example 2: Marketing campaign effectiveness
# Probability of conversion overall = 5%
# Probability of being in email campaign = 20%
# Probability of conversion given email campaign = 15%

p_conversion = 0.05
p_campaign = 0.20
p_conversion_given_campaign = 0.15

# Probability of campaign given conversion
p_campaign_given_conversion = p_conversion_given_campaign * p_campaign / p_conversion
print(f"Probability of being in campaign given conversion: {p_campaign_given_conversion:.2%}")

# Business translation:
# "60% of converters came from the email campaign.
#  The campaign is driving 60% of our conversions, despite only 20% of customers being in it.
#  This is a highly effective channel."
```

---

## Chapter 3: Statistical Distributions

### 3.1 Normal Distribution

**The Concept:** The normal distribution is the "bell curve." Many natural phenomena follow it.

**Key Properties:**
- Symmetric around the mean
- 68% of data within ±1 standard deviation
- 95% within ±2 standard deviations
- 99.7% within ±3 standard deviations

**Our Examples:**

```python
import numpy as np
from scipy.stats import norm
import matplotlib.pyplot as plt

# Normal distribution parameters
mean = 100  # Average customer value
std = 15    # Standard deviation

# Generate normal data
x = np.linspace(mean - 4*std, mean + 4*std, 1000)
y = norm.pdf(x, mean, std)

# Plot
plt.figure(figsize=(10, 6))
plt.plot(x, y, 'b-', linewidth=2)
plt.axvline(mean, color='red', linestyle='--', label='Mean')
plt.axvline(mean - std, color='green', linestyle='--', alpha=0.5, label='±1 σ')
plt.axvline(mean + std, color='green', linestyle='--', alpha=0.5)
plt.axvline(mean - 2*std, color='orange', linestyle='--', alpha=0.5, label='±2 σ')
plt.axvline(mean + 2*std, color='orange', linestyle='--', alpha=0.5)
plt.xlabel('Customer Value ($)')
plt.ylabel('Probability Density')
plt.title('Normal Distribution of Customer Value')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

# Calculations
# Probability customer value > 130
prob_above_130 = 1 - norm.cdf(130, mean, std)
print(f"Probability of customer value > $130: {prob_above_130:.2%}")

# Probability customer value between 85 and 115
prob_between = norm.cdf(115, mean, std) - norm.cdf(85, mean, std)
print(f"Probability of customer value between $85 and $115: {prob_between:.2%}")

# Z-score (standardization)
z_score = (130 - mean) / std
print(f"Z-score for $130: {z_score:.2f} (2 standard deviations above mean)")

# Business translation:
# "Customer value is normally distributed with a mean of $100 and std of $15.
#  Only 2.5% of customers have value over $130 (the top 2.5%).
#  These high-value customers should be our focus for retention efforts."
```

### 3.2 Binomial Distribution

**The Concept:** Binomial distribution models the number of successes in a fixed number of independent trials.

**Our Examples:**

```python
from scipy.stats import binom
import matplotlib.pyplot as plt
import numpy as np

# Example: Abandoned cart recovery emails
# Each customer who abandons has 20% chance of returning to purchase
# We send recovery emails to 100 customers

n = 100  # Number of trials (customers)
p = 0.20  # Probability of success (returning to purchase)

# Probability of exactly 20 customers returning
prob_20 = binom.pmf(20, n, p)
print(f"Probability exactly 20 customers return: {prob_20:.2%}")

# Probability of at most 25 customers returning
prob_at_most_25 = binom.cdf(25, n, p)
print(f"Probability ≤25 customers return: {prob_at_most_25:.2%}")

# Probability of at least 25 customers returning
prob_at_least_25 = 1 - binom.cdf(24, n, p)
print(f"Probability ≥25 customers return: {prob_at_least_25:.2%}")

# Expected number of returns
expected = n * p
print(f"Expected returns: {expected}")

# Visualize
x = range(0, 41)
y = binom.pmf(x, n, p)

plt.figure(figsize=(10, 6))
plt.bar(x, y, alpha=0.7)
plt.axvline(expected, color='red', linestyle='--', label=f'Expected ({expected})')
plt.xlabel('Number of Customers Returning')
plt.ylabel('Probability')
plt.title(f'Binomial Distribution (n={n}, p={p:.0%})')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

# Business translation:
# "If we send recovery emails to 100 customers with a 20% return rate:
#  - Expected returns: 20 customers
#  - 86% chance of getting between 14 and 26 returns
#  - We can be 95% confident we'll get between 12 and 28 returns
#  This helps us budget and forecast recovery revenue."
```

---

## Chapter 4: Hypothesis Testing

### 4.1 The Framework

**The Concept:** Hypothesis testing is how we make decisions with data. It answers: "Is this difference real or just random chance?"

**The Process:**
1. **Null Hypothesis (H₀):** No effect or difference
2. **Alternative Hypothesis (H₁):** There IS an effect or difference
3. **Significance Level (α):** Usually 0.05 (5% risk of false positive)
4. **P-value:** Probability of seeing results this extreme if H₀ is true
5. **Decision:** Reject H₀ if p-value < α

**Our Examples:**

```python
from scipy import stats
import numpy as np
import matplotlib.pyplot as plt

# Example: A/B Test for website conversion
# Control group: Existing design
# Treatment group: New design

# Generate sample data
np.random.seed(42)
control_conversions = np.random.binomial(1, 0.10, 1000)  # 10% conversion
treatment_conversions = np.random.binomial(1, 0.13, 1000)  # 13% conversion

# Calculate conversion rates
control_rate = np.mean(control_conversions)
treatment_rate = np.mean(treatment_conversions)

print(f"Control conversion rate: {control_rate:.2%}")
print(f"Treatment conversion rate: {treatment_rate:.2%}")
print(f"Difference: {(treatment_rate - control_rate):.2%}")

# T-test for difference in proportions
from statsmodels.stats.proportion import proportions_ztest

count = [np.sum(treatment_conversions), np.sum(control_conversions)]
nobs = [len(treatment_conversions), len(control_conversions)]

z_stat, p_value = proportions_ztest(count, nobs)

print(f"\nHypothesis Test Results:")
print(f"Z-statistic: {z_stat:.3f}")
print(f"P-value: {p_value:.4f}")

if p_value < 0.05:
    print("✅ Reject null hypothesis: Difference is statistically significant")
else:
    print("❌ Fail to reject null hypothesis: Difference is NOT statistically significant")

# Business translation:
# "The new design shows a 3 percentage point improvement in conversion.
#  With a p-value of 0.023 (less than 0.05), this is statistically significant.
#  We can be 97.7% confident the improvement is real, not random chance.
#  Recommendation: Roll out the new design."

# Visualize
fig, axes = plt.subplots(1, 2, figsize=(12, 4))

# Bar chart
axes[0].bar(['Control', 'Treatment'], [control_rate, treatment_rate])
axes[0].set_ylabel('Conversion Rate')
axes[0].set_title('A/B Test Results')
axes[0].axhline(y=control_rate, color='blue', linestyle='--', alpha=0.5)

# Confidence intervals
import statsmodels.stats.proportion as smprop
ci_control = smprop.proportion_confint(np.sum(control_conversions), len(control_conversions))
ci_treatment = smprop.proportion_confint(np.sum(treatment_conversions), len(treatment_conversions))

axes[1].errorbar(['Control', 'Treatment'], [control_rate, treatment_rate], 
                 yerr=[[control_rate - ci_control[0]], [ci_treatment[1] - treatment_rate]],
                 fmt='o', capsize=10)
axes[1].set_ylabel('Conversion Rate')
axes[1].set_title('95% Confidence Intervals')
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

### 4.2 Types of Errors

**The Concept:** Understanding the risks of incorrect decisions.

| Decision | Reality (No Effect) | Reality (Effect Exists) |
|----------|---------------------|------------------------|
| **Reject H₀** | **Type I Error (α)** | ✅ Correct |
| **Fail to Reject H₀** | ✅ Correct | **Type II Error (β)** |

**Our Examples:**

```python
# Business example: Fraud detection
# H₀: Transaction is legitimate
# H₁: Transaction is fraudulent

# We need to balance:
# Type I Error: Flagging legitimate transaction as fraud (customer anger)
# Type II Error: Missing fraudulent transaction (financial loss)

def calculate_decision_metrics(threshold=0.5):
    """Calculate false positive and false negative rates."""
    # Simulate model predictions
    np.random.seed(42)
    legit_scores = np.random.normal(0.2, 0.15, 1000)  # Legitimate transactions
    fraud_scores = np.random.normal(0.8, 0.15, 100)   # Fraudulent transactions
    
    # Combine
    true_labels = np.concatenate([np.zeros(1000), np.ones(100)])
    scores = np.concatenate([legit_scores, fraud_scores])
    
    # Apply threshold
    predictions = (scores > threshold).astype(int)
    
    # Calculate metrics
    fp = np.sum((predictions == 1) & (true_labels == 0))  # False positives
    fn = np.sum((predictions == 0) & (true_labels == 1))  # False negatives
    
    fp_rate = fp / np.sum(true_labels == 0)
    fn_rate = fn / np.sum(true_labels == 1)
    
    return fp_rate, fn_rate

# Explore different thresholds
thresholds = [0.3, 0.4, 0.5, 0.6, 0.7]
for t in thresholds:
    fp_rate, fn_rate = calculate_decision_metrics(t)
    print(f"Threshold {t:.1f}:")
    print(f"  False Positive Rate: {fp_rate:.2%} (Type I Error)")
    print(f"  False Negative Rate: {fn_rate:.2%} (Type II Error)")
    print(f"  Customer Impact: {fp_rate:.2%} of good customers flagged")
    print(f"  Financial Impact: {fn_rate:.2%} of fraud missed")
    print()

# Business translation:
# "As we lower the threshold to catch more fraud (lower Type II error):
#  - We catch more fraudulent transactions (good)
#  - But we also flag more legitimate transactions as fraud (bad)
#  
#  Business decision: For a high-volume business with loyal customers,
#  we might prefer a higher threshold to minimize customer friction.
#  For a high-risk business, we might prefer a lower threshold."
```

---

## Chapter 5: Confidence Intervals

### 5.1 Understanding Confidence Intervals

**The Concept:** Confidence intervals quantify uncertainty around our estimates. They tell us the range of values where the true value likely falls.

**Key Points:**
- 95% CI: We're 95% confident the true value lies in this interval
- Width of CI: Uncertainty (narrower = more precise)
- Wider CI = More uncertainty

**Our Examples:**

```python
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

def calculate_confidence_interval(data, confidence=0.95):
    """Calculate confidence interval for mean."""
    n = len(data)
    mean = np.mean(data)
    sem = stats.sem(data)  # Standard error of mean
    
    # Calculate margin of error
    t_critical = stats.t.ppf((1 + confidence) / 2, n - 1)
    margin_error = t_critical * sem
    
    return mean, mean - margin_error, mean + margin_error

# Example: Average order value
orders = [
    45, 52, 67, 34, 89, 73, 56, 48, 62, 71,
    55, 49, 68, 44, 59, 63, 51, 47, 58, 72,
    43, 66, 54, 61, 46, 50, 57, 70, 42, 65
]

mean, lower, upper = calculate_confidence_interval(orders)

print(f"Average Order Value: ${mean:.2f}")
print(f"95% Confidence Interval: [${lower:.2f}, ${upper:.2f}]")
print(f"Margin of Error: ±${(upper - lower) / 2:.2f}")

# Business translation:
# "We estimate the average order value is $56.87.
#  We're 95% confident the true average is between $51.45 and $62.29.
#  This 10% margin of error should be considered when making decisions."

# Visualize confidence intervals
np.random.seed(42)
# Simulate 20 different samples
samples = [np.random.normal(100, 15, 30) for _ in range(20)]

plt.figure(figsize=(12, 6))
for i, sample in enumerate(samples):
    mean, lower, upper = calculate_confidence_interval(sample)
    plt.errorbar(mean, i, xerr=[[mean - lower], [upper - mean]], 
                 fmt='o', capsize=5, alpha=0.7)
    
plt.axvline(100, color='red', linestyle='--', label='True Mean')
plt.xlabel('Value')
plt.ylabel('Sample Number')
plt.title('Confidence Intervals from 20 Samples')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

---

## Chapter 6: Correlation and Causation

### 6.1 Understanding Correlation

**The Concept:** Correlation measures the strength and direction of a linear relationship between two variables.

**Pearson Correlation (r):**
- r = 1: Perfect positive correlation
- r = -1: Perfect negative correlation
- r = 0: No correlation

| r Value | Strength |
|---------|----------|
| 0.00 - 0.19 | Very weak |
| 0.20 - 0.39 | Weak |
| 0.40 - 0.59 | Moderate |
| 0.60 - 0.79 | Strong |
| 0.80 - 1.00 | Very strong |

**Our Examples:**

```python
import pandas as pd
import numpy as np
from scipy.stats import pearsonr, spearmanr
import matplotlib.pyplot as plt
import seaborn as sns

# Example: Customer engagement and revenue
np.random.seed(42)
n = 200

# Create correlated data
engagement = np.random.normal(50, 20, n)
revenue = 100 + 2 * engagement + np.random.normal(0, 30, n)

# Add some non-linear patterns
non_linear_revenue = 100 + 0.5 * engagement**2 / 20 + np.random.normal(0, 30, n)

# Calculate correlation
pearson_r, pearson_p = pearsonr(engagement, revenue)
spearman_r, spearman_p = spearmanr(engagement, revenue)

print("Linear Relationship:")
print(f"  Pearson r: {pearson_r:.3f}")
print(f"  P-value: {pearson_p:.4f}")
print(f"  R-squared: {pearson_r**2:.3f} (explained variance)")

# Visualize
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Scatter plot with regression line
axes[0].scatter(engagement, revenue, alpha=0.5)
z = np.polyfit(engagement, revenue, 1)
p = np.poly1d(z)
axes[0].plot(engagement, p(engagement), 'r-', label=f'Linear (r={pearson_r:.3f})')
axes[0].set_xlabel('Engagement Score')
axes[0].set_ylabel('Revenue ($)')
axes[0].set_title('Linear Correlation')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Heatmap for multiple variables
data = pd.DataFrame({
    'engagement': engagement,
    'revenue': revenue,
    'purchases': np.random.poisson(5, n) + 10,
    'satisfaction': np.random.normal(8, 1, n),
    'churn_risk': 1 / (1 + np.exp(-(engagement - 50) / 20))  # Logistic function
})

corr_matrix = data.corr()
sns.heatmap(corr_matrix, annot=True, cmap='coolwarm', center=0, 
            ax=axes[1], vmin=-1, vmax=1)
axes[1].set_title('Correlation Matrix')

plt.tight_layout()
plt.show()

# Business translation:
# "Customer engagement and revenue have a strong positive correlation (r=0.72).
#  This means 52% of revenue variation can be explained by engagement.
#  But correlation DOES NOT mean causation:
#   - High engagement might cause high revenue
#   - High revenue might cause high engagement
#   - Some third factor (e.g., product quality) might cause both

#  For business decisions, we need to run controlled experiments
#  to establish causation."
```

### 6.2 When Correlation ≠ Causation

**Our Examples:**

```python
# Classic example: Ice cream sales and drowning incidents
# They are correlated but NOT causally related
# (Both are caused by hot weather)

# Business example: Customer satisfaction and revenue
# They might be correlated, but:
# - Satisfied customers might spend more (causation)
# - High-spending customers might be more satisfied (reverse causation)
# - Better product quality drives both (third variable)

def generate_confounded_data(n=500):
    """Generate data with a confounding variable."""
    np.random.seed(42)
    
    # Confounding variable: Product quality
    product_quality = np.random.normal(50, 10, n)
    
    # Causally related to both satisfaction and revenue
    satisfaction = product_quality + np.random.normal(0, 5, n)
    revenue = 50 + 2 * product_quality + np.random.normal(0, 15, n)
    
    return satisfaction, revenue

satisfaction, revenue = generate_confounded_data()

# Calculate correlation
r, p = pearsonr(satisfaction, revenue)
print(f"Correlation between satisfaction and revenue: {r:.3f}")
print(f"P-value: {p:.4f}")

# Business translation:
# "We see a strong correlation between satisfaction and revenue (r=0.85).
#  But if we only looked at this, we might conclude:
#   'We should invest in satisfaction to increase revenue'
#  
#  The actual driver might be product quality, which increases BOTH.
#  The correct intervention might be:
#   'We should invest in product quality to increase both satisfaction and revenue'
#
#  This is why we need controlled experiments, not just observational data."
```

---

## Chapter 7: Regression Basics

### 7.1 Simple Linear Regression

**The Concept:** Regression helps us predict one variable based on another. It quantifies the relationship mathematically.

**Formula:**
y = mx + b
- y: Dependent variable (what we're predicting)
- x: Independent variable (what we're using to predict)
- m: Slope (how much y changes when x changes by 1)
- b: Intercept (y when x = 0)

**Our Examples:**

```python
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score, mean_squared_error

# Example: Predicting revenue from engagement
engagement = np.random.normal(50, 20, 200).reshape(-1, 1)
revenue = 100 + 2.5 * engagement.flatten() + np.random.normal(0, 30, 200)

# Split data
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(
    engagement, revenue, test_size=0.2, random_state=42
)

# Train model
model = LinearRegression()
model.fit(X_train, y_train)

# Make predictions
y_pred = model.predict(X_test)

# Evaluate
r2 = r2_score(y_test, y_pred)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))

print(f"Model: Revenue = {model.intercept_:.2f} + {model.coef_[0]:.3f} × Engagement")
print(f"R-squared: {r2:.3f} (explains {r2*100:.1f}% of variance)")
print(f"RMSE: ${rmse:.2f}")

# Interpret the model
print(f"\nInterpretation:")
print(f"For each 1 point increase in engagement score:")
print(f"  Revenue increases by ${model.coef_[0]:.2f}")
print(f"  (Assuming other factors remain constant)")

# Example prediction
engagement_example = 60
predicted_revenue = model.intercept_ + model.coef_[0] * engagement_example
print(f"\nCustomer with engagement score of {engagement_example}:")
print(f"  Predicted revenue: ${predicted_revenue:.2f}")

# Business translation:
# "The model suggests each 1 point increase in engagement score
#  is associated with $2.50 more revenue per month.
#  If we can increase engagement by 10 points (e.g., through better onboarding),
#  we expect to increase revenue by $25 per customer per month."

# Visualize
plt.figure(figsize=(10, 6))
plt.scatter(X_test, y_test, alpha=0.5, label='Actual')
plt.plot(X_test, y_pred, 'r-', label='Predicted')
plt.xlabel('Engagement Score')
plt.ylabel('Revenue ($)')
plt.title('Linear Regression: Revenue vs Engagement')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

### 7.2 Multiple Linear Regression

**The Concept:** Multiple regression uses multiple predictors to improve predictions.

**Our Examples:**

```python
# Create multiple features
np.random.seed(42)
n = 500

engagement = np.random.normal(50, 20, n)
purchases = np.random.poisson(3, n) + 5
age = np.random.normal(35, 10, n)
satisfaction = np.random.normal(8, 1, n)

# Create revenue with known relationships
revenue = (
    50 +                    # Base
    2.5 * engagement +      # Engagement effect
    10 * purchases +        # Purchase frequency effect
    -0.5 * age +            # Age effect (younger customers spend more)
    5 * satisfaction +      # Satisfaction effect
    np.random.normal(0, 20, n)  # Noise
)

# Create feature matrix
X = np.column_stack([engagement, purchases, age, satisfaction])
feature_names = ['Engagement', 'Purchases', 'Age', 'Satisfaction']

# Train model
model = LinearRegression()
model.fit(X, revenue)

# Display coefficients
print("Multiple Linear Regression Results:")
print("=" * 50)
print(f"R-squared: {model.score(X, revenue):.3f}")
print("\nCoefficients:")
for name, coef in zip(feature_names, model.coef_):
    print(f"  {name:15s}: {coef:8.3f}")
print(f"  {'Intercept':15s}: {model.intercept_:8.3f}")

# Interpret
print("\nInterpretation (holding other variables constant):")
for name, coef in zip(feature_names, model.coef_):
    print(f"  For each 1 unit increase in {name}:")
    print(f"    Revenue {'increases' if coef > 0 else 'decreases'} by ${abs(coef):.2f}")

# Feature importance (normalized)
importance = np.abs(model.coef_ / np.std(model.coef_, ddof=1))
importance = importance / importance.sum()

print("\nRelative Feature Importance:")
for name, imp in zip(feature_names, importance):
    print(f"  {name:15s}: {imp:.2%}")

# Business translation:
# "The most important factors predicting revenue are:
#  1. Purchase frequency (29% of predictive power)
#  2. Engagement score (28%)
#  3. Satisfaction (23%)
#  4. Age (20%)
# 
#  This suggests we should prioritize:
#  1. Getting customers to make more purchases (highest impact)
#  2. Increasing engagement through better content/features
#  3. Improving satisfaction through better support
#  4. Targeting younger customers with marketing"
```

---

## Chapter 8: Business Statistics

### 8.1 Business Metrics

**Our Examples:**

```python
# Customer Lifetime Value (CLV)
def calculate_clv(avg_order_value, purchase_frequency, customer_lifespan):
    """Calculate Customer Lifetime Value."""
    return avg_order_value * purchase_frequency * customer_lifespan

# Example
avg_order = 85
purchase_freq = 4  # times per year
lifespan = 5  # years

clv = calculate_clv(avg_order, purchase_freq, lifespan)
print(f"CLV: ${clv:,.2f}")

# Customer Acquisition Cost (CAC)
def calculate_cac(marketing_spend, sales_spend, new_customers):
    """Calculate Customer Acquisition Cost."""
    return (marketing_spend + sales_spend) / new_customers

# Example
marketing = 50000
sales = 30000
new_customers = 1000

cac = calculate_cac(marketing, sales, new_customers)
print(f"CAC: ${cac:,.2f}")

# CLV:CAC Ratio
clv_cac_ratio = clv / cac
print(f"CLV:CAC Ratio: {clv_cac_ratio:.2f}")
if clv_cac_ratio > 3:
    print("✅ Excellent: Business is scaling profitably")
elif clv_cac_ratio > 1:
    print("⚠️ Acceptable: Need to optimize acquisition")
else:
    print("❌ Poor: Customer acquisition is not profitable")

# Business translation:
# "CLV:CAC ratio of 5.7 means we're generating $5.70 in customer value
#  for every $1 spent on acquisition. This is excellent.
#  We should consider increasing marketing spend to acquire more customers."

# Customer Churn Rate
def calculate_churn_rate(start_customers, end_customers, new_customers):
    """Calculate customer churn rate."""
    lost_customers = start_customers - (end_customers - new_customers)
    return lost_customers / start_customers

# Example
start = 1000
end = 950
new = 50

churn = calculate_churn_rate(start, end, new)
print(f"Churn Rate: {churn:.2%}")

# Net Revenue Retention (NRR)
def calculate_nrr(starting_revenue, expansion_revenue, churned_revenue):
    """Calculate Net Revenue Retention."""
    return (starting_revenue + expansion_revenue - churned_revenue) / starting_revenue

# Example
start_rev = 100000
expansion = 15000
churned_rev = 5000

nrr = calculate_nrr(start_rev, expansion, churned_rev)
print(f"NRR: {nrr:.2%}")
if nrr > 1:
    print("✅ Growing revenue from existing customers")
elif nrr == 1:
    print("⚠️ Maintaining revenue from existing customers")
else:
    print("❌ Losing revenue from existing customers")
```

### 8.2 Statistical Decision Matrix

```markdown
# Statistical Decision Matrix

## When to Use Different Statistical Methods

| Business Question | Statistical Method | Metric |
|-------------------|-------------------|--------|
| Is there a difference between groups? | T-test, ANOVA | P-value |
| What's the relationship between variables? | Correlation | R-value |
| How much does X predict Y? | Regression | R-squared |
| What's the likely range of values? | Confidence Interval | Lower/Upper bounds |
| How often will something happen? | Probability | Percentage |
| Is data different from expectation? | Chi-square test | P-value |

## Statistical Significance Thresholds

| Field | α (Alpha) | Confidence Level |
|-------|-----------|------------------|
| Academic Research | 0.05 | 95% |
| Business Decisions | 0.05 - 0.10 | 90-95% |
| Quality Control | 0.01 | 99% |
| Medical Trials | 0.01 | 99% |

## Sample Size Guidelines

| Desired Precision | Population Size | Sample Size (95% CI) |
|-------------------|-----------------|---------------------|
| ±5% | 1,000 | 278 |
| ±5% | 10,000 | 370 |
| ±5% | 100,000 | 383 |
| ±3% | 1,000 | 516 |
| ±3% | 10,000 | 964 |
| ±3% | 100,000 | 1,056 |
| ±1% | 1,000 | 906 |
| ±1% | 10,000 | 4,899 |
| ±1% | 100,000 | 6,354 |
```

---

## Quick Reference Card

### Statistical Tests and Their Uses

| Test | Use Case | Example |
|------|----------|---------|
| **T-test** | Compare means of two groups | A/B test results |
| **ANOVA** | Compare means of 3+ groups | Multiple variants |
| **Chi-square** | Compare categorical data | Customer segments |
| **Correlation** | Linear relationship | Engagement vs revenue |
| **Regression** | Predict outcomes | Customer value prediction |

### Key Statistical Terms

| Term | Definition | Business Translation |
|------|------------|---------------------|
| **P-value** | Probability of results if H₀ true | "We're X% confident this is real" |
| **R-squared** | Variance explained | "This explains X% of what we see" |
| **Standard Deviation** | Average distance from mean | "Typical variation is X units" |
| **Confidence Interval** | Range of likely values | "We're 95% sure it's between A and B" |
| **Effect Size** | Magnitude of difference | "The practical impact is X%" |

### Common Probability Distributions

| Distribution | Use Case | Example |
|--------------|----------|---------|
| **Normal** | Natural phenomena | Customer spending |
| **Binomial** | Success/failure | Customer conversion |
| **Poisson** | Count of events | Support tickets |
| **Exponential** | Time between events | Customer churn time |

---

**[END OF PRIMER 3]**
