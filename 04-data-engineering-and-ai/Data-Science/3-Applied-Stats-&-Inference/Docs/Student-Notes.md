# PHASE 3: APPLIED STATISTICS & HYPOTHESIS TESTING
## STUDENT NOTES

These notes are designed to accompany the lectures and slides. They provide structured, concise summaries of each topic with key definitions, formulas, and memory aids. Use these for study, review, and exam preparation.

---

## NOTE SET 1: DESCRIPTIVE STATISTICS

---

### 1.1 Variables and Data Types

**Key Definition:** A variable is any characteristic that can change or vary.

**Types of Variables:**

```
Variables
├── Quantitative (Numerical)
│   ├── Continuous (can be any number)
│   │   └── Examples: Height, Temperature, Time
│   └── Discrete (whole numbers only)
│       └── Examples: Number of children, Count of events
│
└── Categorical (Qualitative)
    ├── Nominal (no natural order)
    │   └── Examples: Eye color, Gender, Country
    └── Ordinal (has natural order)
        └── Examples: Education level, Satisfaction rating
```

**Memory Aid:** Think of "Quantitative" as "Quantity" (numbers) and "Categorical" as "Categories" (labels).

---

### 1.2 Measures of Central Tendency

**Mean (Average):** $\bar{x} = \frac{\sum x_i}{n}$
- Most common measure
- Sensitive to outliers
- Best for symmetric distributions

**Median:** Middle value when sorted
- Robust to outliers
- Best for skewed distributions
- For even n: average of two middle values

**Mode:** Most frequent value
- Only measure for categorical data
- Can be multiple modes (multimodal)
- Good for identifying typical values

**Memory Aid:** "Mean" = Mathematical average, "Median" = Middle, "Mode" = Most frequent.

---

### 1.3 Measures of Dispersion

**Range = Max - Min**
- Simplest measure
- Very sensitive to outliers

**Variance (Sample):** $s^2 = \frac{\sum (x_i - \bar{x})^2}{n-1}$
- Average squared deviation from mean
- Units are squared

**Standard Deviation (Sample):** $s = \sqrt{s^2}$
- Most common measure of spread
- Same units as original data
- Interpret as "typical distance from mean"

**Interquartile Range (IQR) = Q3 - Q1**
- Middle 50% of data
- Robust to outliers
- Used for box plots

**MAD (Median Absolute Deviation):** $MAD = median(|x_i - median|)$
- Very robust
- Good when outliers are present

**Memory Aid:** "Range" = Max-Min, "Variance" = Average squared deviation, "Standard Deviation" = √Variance.

---

### 1.4 The Normal Distribution

**Key Properties:**
1. Symmetric bell shape
2. Mean = Median = Mode
3. 68-95-99.7 Rule
4. Described by μ and σ

**68-95-99.7 Rule:**
```
68% within ±1σ
95% within ±2σ
99.7% within ±3σ
```

**Z-Score:** $z = \frac{x - \mu}{\sigma}$
- Number of standard deviations from mean
- Standardizes values
- Allows comparison across different scales

**Standard Normal Distribution:**
- μ = 0, σ = 1
- Tables available for probabilities
- Used for probability calculations

**Memory Aid:** "Normal" = Bell-shaped, Symmetric, 68-95-99.7.

---

### 1.5 The Central Limit Theorem

**Statement:** The distribution of sample means approaches a normal distribution as sample size increases, regardless of the population distribution.

**Key Implications:**

```
Population Distribution → Sample Means Distribution
(Skewed)                  (Normal, if n ≥ 30)

Mean: μ                  → Mean: μ
Std: σ                   → SE: σ/√n
```

**Sample Size Rules:**
- n ≥ 30: CLT applies for most distributions
- n ≥ 50: Safe for skewed distributions
- n ≥ 100: Near perfect normality

**Why it Matters:**
- Enables inference without normality
- Justifies t-tests and CIs
- Foundation of modern statistics

**Memory Aid:** "CLT = Many samples of size n, plot the means, get normal."

---

### 1.6 Confidence Intervals

**Definition:** A range of values likely to contain the true population parameter.

**General Formula:** Point Estimate ± Margin of Error

**For Mean (σ known):** $\bar{x} \pm z_{\alpha/2} \times \frac{\sigma}{\sqrt{n}}$

**For Mean (σ unknown):** $\bar{x} \pm t_{\alpha/2, n-1} \times \frac{s}{\sqrt{n}}$

**For Proportion:** $\hat{p} \pm z_{\alpha/2} \times \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$

**Common z-values:**
- 90%: 1.645
- 95%: 1.960
- 99%: 2.576

**Interpretation:**
- "95% confident" ≠ "95% probability"
- Correct: 95% of intervals contain true parameter
- Not: Parameter has 95% chance of being in interval

**Memory Aid:** "CI = Point Estimate ± Margin of Error."

---

### 1.7 Sample Size Determination

**For Mean:** $n = \left(\frac{z \cdot \sigma}{MOE}\right)^2$

**For Proportion:** $n = \frac{z^2 \cdot p(1-p)}{MOE^2}$

**Key Relationships:**
- Larger MOE → Smaller n
- Larger σ → Larger n
- Higher confidence → Larger n
- p=0.5 → Largest n (most conservative)

**Rules of Thumb:**
- For mean: n ≥ 30 minimum
- For proportion: n ≥ 5 successes and failures
- 80% power standard

**Memory Aid:** "Smaller MOE = Larger n; Higher confidence = Larger n."

---

### 1.8 Bootstrap Resampling

**Definition:** Resampling with replacement from the original data.

**Steps:**
1. Draw B bootstrap samples (size n, with replacement)
2. Calculate statistic for each
3. Distribution approximates sampling distribution
4. Use percentiles for CI

**Advantages:**
- No distribution assumptions
- Works for any statistic
- Handles complex situations

**Disadvantages:**
- Computationally intensive
- Requires random seed for reproducibility

**Memory Aid:** "Bootstrap = Sample with replacement, many times."

---

## NOTE SET 2: HYPOTHESIS TESTING

---

### 2.1 The Hypothesis Testing Framework

**The Five Steps:**

```
Step 1: State Hypotheses
    H₀: No effect (innocent)
    H₁: Effect exists (guilty)

Step 2: Choose α
    α = 0.05 (standard)

Step 3: Collect Data
    Run experiment
    Calculate test statistic

Step 4: Calculate p-value
    Probability if H₀ is true

Step 5: Make Decision
    p < α → Reject H₀
    p ≥ α → Fail to Reject H₀
```

**Courtroom Analogy:**

| Court | Statistics |
|-------|------------|
| Innocent | H₀ |
| Guilty | H₁ |
| Evidence | Data |
| Beyond reasonable doubt | α |

**Memory Aid:** "H₀ = Null = Nothing (no effect)."

---

### 2.2 Errors in Hypothesis Testing

**Type I Error (α):**
- False positive
- Reject H₀ when true
- "Fire alarm when no fire"
- Probability = α

**Type II Error (β):**
- False negative
- Fail to reject H₀ when false
- "Fire when no alarm"
- Probability = β

**Power (1-β):**
- Detect real effect
- "Catching the bad guy"
- Target: 0.80

**Summary Table:**

| | H₀ True | H₀ False |
|---|---------|----------|
| **Reject H₀** | Type I Error (α) | Correct (Power) |
| **Fail to Reject** | Correct | Type II Error (β) |

**Memory Aid:** "Type I = α = False Alarm; Type II = β = Missed Opportunity."

---

### 2.3 P-Values

**Definition:** Probability of observing results as extreme as those obtained, assuming H₀ is true.

**Interpretation Guide:**

| p-value | Evidence Against H₀ |
|---------|---------------------|
| < 0.001 | Very strong (★★★) |
| 0.001-0.01 | Strong (★★) |
| 0.01-0.05 | Moderate (★) |
| 0.05-0.10 | Weak/Marginal |
| > 0.10 | None |

**Common Misinterpretations:**

| Wrong | Right |
|-------|-------|
| "p = probability H₀ is true" | "p = probability of data if H₀ is true" |
| "p > 0.05 means no effect" | "Insufficient evidence for effect" |
| "p < 0.05 means large effect" | "Statistically significant, could be tiny" |

**Memory Aid:** "p = Probability of data, not probability of null."

---

### 2.4 T-Tests

**One-Sample t-Test:**
- Compare sample mean to known value
- $t = \frac{\bar{x} - \mu_0}{s/\sqrt{n}}$
- df = n-1

**Two-Sample t-Test:**
- Compare two independent groups
- $t = \frac{\bar{x}_1 - \bar{x}_2}{\sqrt{s_1^2/n_1 + s_2^2/n_2}}$ (Welch's)
- df = Welch-Satterthwaite (or n₁+n₂-2 for pooled)

**Paired t-Test:**
- Compare two related groups
- $t = \frac{\bar{d}}{s_d/\sqrt{n}}$
- df = n-1

**When to Use:**

| Test | When |
|------|------|
| One-sample | Compare to known value |
| Two-sample | Independent groups |
| Paired | Before/after |

**Memory Aid:** "t-test = small samples, σ unknown."

---

### 2.5 ANOVA (Analysis of Variance)

**Purpose:** Compare means of 3+ groups

**Hypotheses:**
- H₀: All means equal
- H₁: At least one differs

**Test Statistic:** $F = \frac{MS_{between}}{MS_{within}}$

**Assumptions:**
1. Normality within groups
2. Equal variances (homoscedasticity)
3. Independence

**Post-Hoc Tests:**
- Tukey's HSD (most common)
- Conducted if ANOVA significant
- Identify which groups differ

**Memory Aid:** "ANOVA = Compare 3+ means at once."

---

### 2.6 Non-Parametric Tests

**When to Use Non-Parametric:**

1. Data not normal
2. Small samples (n < 30)
3. Ordinal data
4. Outliers present
5. Safety first

**Tests and Their Parametric Equivalents:**

| Parametric | Non-Parametric |
|------------|----------------|
| Two-sample t-test | Mann-Whitney U |
| Paired t-test | Wilcoxon |
| ANOVA | Kruskal-Wallis |
| Pearson correlation | Spearman correlation |

**Mann-Whitney U:**
- Ranks all data
- U-statistic
- Example: "Does group A have larger values than group B?"

**Wilcoxon Signed-Rank:**
- Ranks differences
- For paired data
- Example: "Is before different from after?"

**Kruskal-Wallis:**
- ANOVA alternative
- Ranks all data
- Example: "Do 3+ groups differ?"

**Memory Aid:** "Non-parametric = No normality assumption, use ranks."

---

### 2.7 Chi-Square Tests

**Test of Independence:**
- Two categorical variables
- H₀: Variables independent
- $\chi^2 = \sum \frac{(O-E)^2}{E}$

**Goodness-of-Fit Test:**
- One categorical variable
- H₀: Observed = Expected
- $\chi^2 = \sum \frac{(O-E)^2}{E}$

**Conditions:**
- Expected frequencies ≥ 5
- Independent observations
- Categorical data

**Fisher's Exact Test:**
- 2x2 tables only
- Exact p-value
- Small samples
- No expected frequency requirement

**Memory Aid:** "Chi-square = Categorical data, compare observed vs expected."

---

### 2.8 Multiple Testing Corrections

**The Problem:** If you run 100 tests at α=0.05, ~5 are significant by chance.

**Bonferroni Correction:**
- α' = α / m
- Most conservative
- Controls FWER
- Low power

**Holm-Bonferroni:**
- Step-down procedure
- Less conservative
- Still controls FWER
- More power

**Benjamini-Hochberg (FDR):**
- Controls FDR
- Most power
- For many tests
- Exploratory research

**Comparison:**

| Method | Controls | Power | Best For |
|--------|----------|-------|----------|
| Bonferroni | FWER | Low | Few tests |
| Holm | FWER | Medium | Medium tests |
| BH | FDR | High | Many tests |

**Memory Aid:** "Bonferroni = Divide α by m; BH = Sort, step-up."

---

### 2.9 Effect Sizes

**Cohen's d (for t-tests):**
$d = \frac{\bar{x}_1 - \bar{x}_2}{s_{pooled}}$

| d | Interpretation |
|---|----------------|
| 0.2 | Small |
| 0.5 | Medium |
| 0.8 | Large |

**Cramer's V (for Chi-square):**
$V = \sqrt{\frac{\chi^2}{n \cdot \min(r-1, c-1)}}$

**Pearson's r (correlation):**

| r | Interpretation |
|---|----------------|
| 0.1 | Weak |
| 0.3 | Moderate |
| 0.5 | Strong |

**Why Effect Size Matters:**
- Statistical significance ≠ Practical significance
- Quantifies magnitude
- Allows comparison across studies

**Memory Aid:** "Effect Size = How big the difference is, not just if it exists."

---

## NOTE SET 3: REGRESSION & DIAGNOSTICS

---

### 3.1 Simple Linear Regression

**Equation:**
$Y = \beta_0 + \beta_1 X + \varepsilon$

**Components:**
- Y = Dependent variable (response)
- X = Independent variable (predictor)
- β₀ = Intercept (Y when X=0)
- β₁ = Slope (change in Y per unit X)
- ε = Error term

**Interpretation:**
- β₁: "For each 1-unit increase in X, Y changes by β₁ units"
- β₀: "The expected Y when X is 0"

**Example:**
Price = 50 + 0.15 × SqFt
- β₀ = 50: base price (thousands)
- β₁ = 0.15: each sq ft adds $150

**Memory Aid:** "Y = mX + b (intercept, slope)."

---

### 3.2 Multiple Linear Regression

**Equation:**
$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + ... + \beta_k X_k + \varepsilon$

**Key Concept:** "Holding other variables constant"

**Interpretation:**
- Each βᵢ: effect of Xᵢ while controlling for other variables
- Isolates the pure effect
- Removes confounding

**Example:**
Price = 50 + 0.15(SqFt) + 20(Bedrooms) - 0.5(Age) + 15(Location)

| Variable | Effect (holding others constant) |
|----------|----------------------------------|
| SqFt | +$150 per sq ft |
| Bedrooms | +$20,000 per bedroom |
| Age | -$500 per year |
| Location | +$15,000 per unit |

**Memory Aid:** "Multiple = More than one X, holding others constant."

---

### 3.3 OLS Estimation

**OLS = Ordinary Least Squares**

**Goal:** Minimize sum of squared residuals

**Normal Equation:**
$\hat{\beta} = (X'X)^{-1}X'Y$

**Key Statistics:**

**R² (Coefficient of Determination):**
$R^2 = \frac{SSR}{SST} = 1 - \frac{SSE}{SST}$
- Proportion of variance explained
- 0 = none, 1 = all

**Adjusted R²:**
$R^2_{adj} = 1 - \frac{SSE/(n-k-1)}{SST/(n-1)}$
- Penalizes extra variables
- Use for model comparison

**F-Statistic:**
$F = \frac{SSR/k}{SSE/(n-k-1)}$
- Overall model significance
- p < α → model is significant

**Memory Aid:** "R² = How much Y is explained by X's."

---

### 3.4 Regression Assumptions (LINE)

**L - Linearity:**
- Relationship is linear
- Check: Residual vs Fitted plot
- No pattern = good

**I - Independence:**
- Observations independent
- Check: Durbin-Watson
- d ≈ 2 = good

**N - Normality (of residuals):**
- Residuals normally distributed
- Check: Q-Q plot, Shapiro-Wilk
- p > 0.05 = good

**E - Equal Variance (Homoscedasticity):**
- Constant variance
- Check: Residual vs Fitted plot
- No fanning = good

**Consequences of Violations:**

| Violation | Consequence | Solution |
|-----------|-------------|----------|
| Non-linearity | Biased estimates | Transform |
| Non-independence | Wrong SE | Time series |
| Non-normality | Wrong p-values | Robust methods |
| Heteroscedasticity | Wrong p-values | Robust SE |

**Memory Aid:** "LINE = L: Linear, I: Independent, N: Normal, E: Equal variance."

---

### 3.5 Multicollinearity

**Definition:** High correlation between predictor variables.

**Problems:**
- Unstable coefficients
- Difficult to interpret
- Large standard errors

**VIF (Variance Inflation Factor):**
$VIF_j = \frac{1}{1 - R^2_j}$

**Interpretation:**
- VIF = 1: No correlation
- 1-5: Moderate, acceptable
- 5-10: Concerning
- > 10: Severe, problematic

**Solutions:**
1. Remove one of the variables
2. Combine variables (PCA)
3. Regularization (Ridge, Lasso)
4. Collect more data

**Memory Aid:** "VIF > 10 = Problem; VIF > 5 = Concern."

---

### 3.6 Influential Points

**Outlier:** Extreme Y value
- Check: Studentized residual
- |t| > 2 = potential, > 3 = probable

**Leverage:** Extreme X value
- $h_{ii} = X_i(X'X)^{-1}X_i'$
- Average = (k+1)/n
- > 2(k+1)/n = high leverage

**Cook's Distance:**
$D_i = \frac{e_i^2}{(k+1)MSE} \cdot \frac{h_{ii}}{(1-h_{ii})^2}$
- D > 1: Influential
- Investigate these points
- Consider removal after investigation

**DFFITS:**
$DFFITS_i = r_i^* \sqrt{\frac{h_{ii}}{1-h_{ii}}}$
- > 2√((k+1)/n): Influential

**Memory Aid:** "Cook's D > 1 = Influential point, investigate."

---

### 3.7 Logistic Regression

**Purpose:** Binary outcomes (0/1)

**Logistic Function:**
$P(Y=1) = \frac{1}{1 + e^{-(\beta_0 + \beta_1X_1 + ... + \beta_kX_k)}}$

**Logit Transformation:**
$ln\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1X_1 + ... + \beta_kX_k$

**Odds Ratio (OR):**
$OR = e^{\beta_i}$

**Interpretation:**
- OR > 1: Increases odds
- OR < 1: Decreases odds
- OR = 1: No effect

**Example:**
If β = 0.69 for Treatment:
OR = e^0.69 = 2.0
→ Treatment doubles odds of outcome

**Memory Aid:** "Logistic = Binary outcome, odds ratios."

---

### 3.8 Model Selection

**Forward Selection:**
1. Start with no variables
2. Add best variable
3. Continue until no improvement

**Backward Elimination:**
1. Start with all variables
2. Remove worst variable
3. Continue until all significant

**Stepwise:**
- Combination of forward/backward
- Can add and remove

**Regularization:**

| Method | Penalty | Effect |
|--------|---------|--------|
| Ridge | L₂ | Shrinks coefficients |
| Lasso | L₁ | Variable selection |
| Elastic Net | Both | Combination |

**Memory Aid:** "Forward = Add; Backward = Remove; Stepwise = Both."

---

### 3.9 Model Diagnostics Checklist

**Before accepting a model, check:**

1. **Linearity** → Residual vs Fitted plot (no pattern)
2. **Normality** → Q-Q plot, Shapiro-Wilk (p > 0.05)
3. **Homoscedasticity** → Residual vs Fitted plot (constant spread)
4. **Independence** → Durbin-Watson (d ≈ 2)
5. **Multicollinearity** → VIF (< 5 good, < 10 ok)
6. **Influential points** → Cook's D (< 1)
7. **Outliers** → Studentized residuals (|t| < 2)
8. **Overall fit** → R², Adjusted R²

**Memory Aid:** "Check all assumptions before trusting results."

---

## NOTE SET 4: A/B TESTING FOR PRACTITIONERS

---

### 4.1 The A/B Testing Process

**Step-by-Step:**

```
1. Define Goal
   └── What metric matters?

2. Design Experiment
   └── Sample size, duration, segments

3. Randomize
   └── Assign users to groups

4. Run Test
   └── Monitor guardrails, no peeking

5. Analyze Results
   └── Hypothesis tests, effect sizes

6. Make Decision
   └── Business impact, cost-benefit

7. Communicate
   └── Clear summary, recommendations
```

**Memory Aid:** "Goals, Design, Randomize, Run, Analyze, Decide, Communicate."

---

### 4.2 Sample Size Rules of Thumb

**Factors that Increase Sample Size:**

- Smaller effect size
- Higher power
- Lower α
- Higher variability
- Unequal group sizes

**Quick Estimates:**

| Desired Effect | Baseline | Sample Size (per group) |
|----------------|----------|------------------------|
| 2% lift | 10% | ~5,000 |
| 5% lift | 10% | ~1,000 |
| 10% lift | 10% | ~300 |
| 20% lift | 50% | ~200 |

**Minimum Duration:**
- At least 1-2 weeks
- Accounts for daily patterns
- Captures full user cycle

**Memory Aid:** "Larger effect = Fewer users; Smaller effect = More users."

---

### 4.3 Metrics Selection

**Primary Metric:**
- The most important outcome
- Single metric, pre-registered
- Business goal aligned

**Secondary Metrics:**
- Supporting evidence
- Explain primary results
- Hypothesis generation

**Guardrail Metrics:**
- Shouldn't get worse
- Performance, reliability
- Long-term health

**Example:**
| Type | Metric |
|------|--------|
| Primary | Conversion rate |
| Secondary | Revenue per user, Time on site |
| Guardrail | Page load time, Error rate |

**Memory Aid:** "Primary = Main, Secondary = Supporting, Guardrail = Protect."

---

### 4.4 Interpreting Results

**Confidence Interval:**
- "We're 95% confident the true effect is between X and Y"
- Width = precision
- If contains 0 = not significant

**P-Value:**
- p < 0.05 = Statistically significant
- p > 0.05 = Not enough evidence

**Effect Size:**
- How big is the effect?
- Practically significant?

**Business Impact:**
- Effect × Number of users × Value per user
- Example: 2% lift × 100K users × $10 = $20,000

**Decision Matrix:**
| Significant? | Important? | Decision |
|--------------|------------|----------|
| Yes | Yes | ✅ Roll out |
| Yes | No | ❌ Reject |
| No | Yes | 🔄 More data |
| No | No | ❌ Stop |

**Memory Aid:** "Significant vs Important = Real vs Matters."

---

### 4.5 Common Pitfalls

**Peeking:**
- Checking results early
- Increases false positives
- Wait until full duration

**Stopping Early:**
- Stopping when "good enough"
- Inflates Type I error
- Stick to plan

**Multiple Testing:**
- Testing many metrics
- False positives
- Use corrections

**Over-Optimization:**
- Testing too many variants
- Winner by chance
- Limit variants

**Ignore Segments:**
- Overall effect masks segments
- Check subgroups
- Segment analysis

**Memory Aid:** "Don't peek, don't stop early, don't test too many things."

---

### 4.6 Communicating Results

**The Pyramid Principle:**

```
┌─────────────────────────────────┐
│ "New button increased conversion │  ← Bottom Line
│  by 2% (10% → 12%)"             │
├─────────────────────────────────┤
│ "95% CI: [1.5%, 2.5%]           │  ← Evidence
│ p = 0.03, n = 10,000"           │
├─────────────────────────────────┤
│ "Recommendation: Roll out       │  ← Action
│ Monitor for 2 weeks"            │
└─────────────────────────────────┘
```

**Translating for Non-Technical:**

| Technical | Plain English |
|-----------|---------------|
| p = 0.03 | 3% chance this happened by chance |
| 95% CI | We're 95% sure the true effect is... |
| Statistical significance | Confident it's real |
| Effect size | Actual business impact |

**Memory Aid:** "Bottom Line → Evidence → Action."

---

## QUICK REFERENCE CARDS

---

### CARD 1: Formulas

**Descriptive Statistics:**
```
Mean:       x̄ = Σx/n
Variance:   s² = Σ(x-x̄)²/(n-1)
SD:         s = √s²
Z-score:    z = (x-μ)/σ
```

**Confidence Intervals:**
```
Mean (σ known):    x̄ ± z(α/2) × σ/√n
Mean (σ unknown):  x̄ ± t(α/2, n-1) × s/√n
Proportion:        p̂ ± z(α/2) × √(p̂(1-p̂)/n)
```

**Sample Size:**
```
Mean:    n = (zσ/MOE)²
Proportion: n = z²p(1-p)/MOE²
```

**Test Statistics:**
```
One-sample t:  t = (x̄-μ₀)/(s/√n)
Two-sample t:  t = (x̄₁-x̄₂)/√(s₁²/n₁+s₂²/n₂)
Paired t:      t = d̄/(sd/√n)
ANOVA:         F = MSbetween/MSwithin
Chi-square:    χ² = Σ(O-E)²/E
```

---

### CARD 2: Test Selection

| Scenario | Parametric | Non-Parametric |
|----------|------------|----------------|
| 1 vs known | One-sample t | Sign test |
| 2 groups | t-test | Mann-Whitney U |
| 2 paired | Paired t | Wilcoxon |
| 3+ groups | ANOVA | Kruskal-Wallis |
| 2 categories | Chi-square | Fisher's exact |
| Correlation | Pearson | Spearman |

---

### CARD 3: Assumptions

**LINE Check:**
```
L: Linearity    → Residual vs Fitted plot
I: Independence → Durbin-Watson (d≈2)
N: Normality    → Q-Q plot, Shapiro-Wilk
E: Equal Var    → Residual vs Fitted plot
```

---

### CARD 4: Critical Values

**z-values:**
| Confidence | z (two-sided) |
|------------|---------------|
| 90% | 1.645 |
| 95% | 1.960 |
| 99% | 2.576 |

**t-values (approximate):**
| df | 95% | 99% |
|----|-----|-----|
| 10 | 2.228 | 3.169 |
| 20 | 2.086 | 2.845 |
| 30 | 2.042 | 2.750 |
| ∞ | 1.960 | 2.576 |

---

### CARD 5: Effect Sizes

| Test | Small | Medium | Large |
|------|-------|--------|-------|
| Cohen's d | 0.2 | 0.5 | 0.8 |
| Cramer's V | 0.1 | 0.3 | 0.5 |
| Pearson r | 0.1 | 0.3 | 0.5 |
| Odds Ratio | 1.5 | 2.5 | 4.0 |

---

### CARD 6: VIF Interpretation

| VIF | Interpretation | Action |
|-----|----------------|--------|
| 1 | None | No action |
| 1-5 | Moderate | Acceptable |
| 5-10 | High | Concern |
| >10 | Severe | Remove |

---

### CARD 7: Cook's D

- D > 1 = Influential point
- Investigate
- Consider removal
- Document decision

---

### CARD 8: P-Value Guide

| p | Evidence | Strength |
|---|----------|----------|
| <0.001 | Very strong | ★★★ |
| 0.001-0.01 | Strong | ★★ |
| 0.01-0.05 | Moderate | ★ |
| 0.05-0.10 | Weak | - |
| >0.10 | None | - |

---

**[END OF STUDENT NOTES]**

---

## HOW TO USE THESE NOTES

1. **Before Lecture:** Review the notes to preview key concepts
2. **During Lecture:** Add your own examples and explanations
3. **After Lecture:** Use for study and exam preparation
4. **Quick Reference:** Use the cards at the end for fast lookup

---

**Good luck with your studies!** 📚
