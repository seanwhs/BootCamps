# APPENDIX E: COMMON FORMULAS & CHEAT SHEETS

Welcome to the fifth appendix! This is your ultimate quick-reference guide — all the essential formulas, rules of thumb, and cheat sheets you need for applied statistics. Keep this handy for when you're working on real projects!

---

## E.1 Descriptive Statistics Formulas

### Measures of Central Tendency

| Measure | Formula | When to Use |
|---------|---------|-------------|
| **Mean** | $\bar{x} = \frac{\sum x_i}{n}$ | Symmetric data, no outliers |
| **Median** | Middle value when sorted | Skewed data, outliers present |
| **Mode** | Most frequent value | Categorical data, multimodal |
| **Trimmed Mean** | Mean after removing % from ends | Robust to outliers |

### Measures of Dispersion

| Measure | Formula | When to Use |
|---------|---------|-------------|
| **Range** | $max - min$ | Quick, rough estimate |
| **Variance** | $s^2 = \frac{\sum (x_i - \bar{x})^2}{n-1}$ | Population estimation |
| **Standard Deviation** | $s = \sqrt{s^2}$ | Most common spread measure |
| **IQR** | $Q_3 - Q_1$ | Robust spread measure |
| **MAD** | $median(|x_i - median|)$ | Very robust spread |
| **CV** | $s/\bar{x} \times 100\%$ | Relative variation |

### Measures of Shape

| Measure | Formula | Interpretation |
|---------|---------|----------------|
| **Skewness** | $\frac{1}{n}\sum (\frac{x_i-\bar{x}}{s})^3$ | 0=symmetric, >0=right-skewed, <0=left-skewed |
| **Kurtosis** | $\frac{1}{n}\sum (\frac{x_i-\bar{x}}{s})^4 - 3$ | 0=normal, >0=heavy tails, <0=light tails |

---

## E.2 Probability Distributions Cheat Sheet

### Discrete Distributions

| Distribution | PMF | Mean | Variance | Parameters |
|--------------|-----|------|----------|------------|
| **Binomial** | $\binom{n}{k}p^k(1-p)^{n-k}$ | $np$ | $np(1-p)$ | $n$, $p$ |
| **Poisson** | $\frac{e^{-\lambda}\lambda^k}{k!}$ | $\lambda$ | $\lambda$ | $\lambda$ |
| **Uniform (Discrete)** | $\frac{1}{n}$ | $\frac{n+1}{2}$ | $\frac{n^2-1}{12}$ | $n$ |

### Continuous Distributions

| Distribution | PDF | Mean | Variance | Parameters |
|--------------|-----|------|----------|------------|
| **Normal** | $\frac{1}{\sigma\sqrt{2\pi}}e^{-\frac{(x-\mu)^2}{2\sigma^2}}$ | $\mu$ | $\sigma^2$ | $\mu$, $\sigma$ |
| **Exponential** | $\lambda e^{-\lambda x}$ | $1/\lambda$ | $1/\lambda^2$ | $\lambda$ |
| **Uniform** | $\frac{1}{b-a}$ | $\frac{a+b}{2}$ | $\frac{(b-a)^2}{12}$ | $a$, $b$ |
| **t** | $\frac{\Gamma(\frac{\nu+1}{2})}{\sqrt{\nu\pi}\Gamma(\frac{\nu}{2})}(1+\frac{t^2}{\nu})^{-\frac{\nu+1}{2}}$ | 0 | $\frac{\nu}{\nu-2}$ | $\nu$ |
| **Chi-square** | $\frac{x^{k/2-1}e^{-x/2}}{2^{k/2}\Gamma(k/2)}$ | $k$ | $2k$ | $k$ |
| **F** | ... | $\frac{d_2}{d_2-2}$ | ... | $d_1$, $d_2$ |

---

## E.3 Hypothesis Testing Cheat Sheet

### Test Selection Guide

| Scenario | Parametric Test | Non-Parametric Test |
|----------|----------------|---------------------|
| 1 sample vs known mean | One-sample t-test | Sign test |
| 2 independent groups | Two-sample t-test | Mann-Whitney U |
| 2 paired groups | Paired t-test | Wilcoxon signed-rank |
| 3+ independent groups | One-way ANOVA | Kruskal-Wallis |
| 3+ paired groups | Repeated measures ANOVA | Friedman test |
| Association (2 continuous) | Pearson correlation | Spearman correlation |
| Association (categorical) | Chi-square test | Fisher's exact |

### Test Statistics

| Test | Statistic | Degrees of Freedom |
|------|-----------|-------------------|
| One-sample t | $t = \frac{\bar{x}-\mu_0}{s/\sqrt{n}}$ | $n-1$ |
| Two-sample t (pooled) | $t = \frac{\bar{x}_1-\bar{x}_2}{s_p\sqrt{1/n_1+1/n_2}}$ | $n_1+n_2-2$ |
| Two-sample t (Welch) | $t = \frac{\bar{x}_1-\bar{x}_2}{\sqrt{s_1^2/n_1+s_2^2/n_2}}$ | Welch-Satterthwaite |
| Paired t | $t = \frac{\bar{d}}{s_d/\sqrt{n}}$ | $n-1$ |
| ANOVA | $F = \frac{MS_{between}}{MS_{within}}$ | $k-1, N-k$ |
| Chi-square | $\chi^2 = \sum \frac{(O-E)^2}{E}$ | $(r-1)(c-1)$ |

---

## E.4 Effect Size Cheat Sheet

### For t-tests (Cohen's d)

| Effect Size | d | Interpretation |
|-------------|---|----------------|
| Small | 0.2 | 20% of standard deviation |
| Medium | 0.5 | 50% of standard deviation |
| Large | 0.8 | 80% of standard deviation |

**Formula:** $d = \frac{\bar{x}_1 - \bar{x}_2}{s_{pooled}}$

### For ANOVA (Eta-squared)

| Effect Size | η² | Interpretation |
|-------------|----|----------------|
| Small | 0.01 | 1% of variance explained |
| Medium | 0.06 | 6% of variance explained |
| Large | 0.14 | 14% of variance explained |

**Formula:** $\eta^2 = \frac{SS_{between}}{SS_{total}}$

### For Chi-square (Cramer's V)

| Effect Size | V | Interpretation |
|-------------|---|----------------|
| Small | 0.1 | Weak association |
| Medium | 0.3 | Moderate association |
| Large | 0.5 | Strong association |

**Formula:** $V = \sqrt{\frac{\chi^2}{n \cdot \min(r-1, c-1)}}$

### For Correlation (Pearson's r)

| Effect Size | r | Interpretation |
|-------------|---|----------------|
| Small | 0.1 | Weak correlation |
| Medium | 0.3 | Moderate correlation |
| Large | 0.5 | Strong correlation |

---

## E.5 Sample Size Formulas

### For Estimating a Mean

**Minimum sample size:**
$$n = \left(\frac{z_{1-\alpha/2} \cdot \sigma}{MOE}\right)^2$$

Where MOE = Margin of Error

**Example:** For 95% confidence, σ=10, MOE=2:
$$n = \left(\frac{1.96 \cdot 10}{2}\right)^2 = 96.04 \approx 97$$

### For Estimating a Proportion

**Minimum sample size:**
$$n = \frac{z_{1-\alpha/2}^2 \cdot p(1-p)}{MOE^2}$$

**Conservative estimate (p=0.5):**
$$n = \frac{z_{1-\alpha/2}^2 \cdot 0.25}{MOE^2}$$

**Example:** For 95% confidence, MOE=0.03:
$$n = \frac{1.96^2 \cdot 0.25}{0.03^2} = 1067.11 \approx 1068$$

### For Comparing Two Means

**Equal sample sizes:**
$$n = \frac{2(z_{1-\alpha/2} + z_{1-\beta})^2}{d^2}$$

Where d = effect size (Cohen's d)

**Example:** For 80% power, d=0.5:
$$n = \frac{2(1.96 + 0.84)^2}{0.5^2} = 62.72 \approx 63 \text{ per group}$$

### For Comparing Two Proportions

**Equal sample sizes:**
$$n = \frac{(z_{1-\alpha/2} + z_{1-\beta})^2[p_1(1-p_1) + p_2(1-p_2)]}{(p_2 - p_1)^2}$$

---

## E.6 Confidence Interval Cheat Sheet

### Common Confidence Intervals

| Parameter | CI Formula | Conditions |
|-----------|-----------|------------|
| **Mean (σ known)** | $\bar{x} \pm z_{1-\alpha/2} \cdot \frac{\sigma}{\sqrt{n}}$ | Normal distribution |
| **Mean (σ unknown)** | $\bar{x} \pm t_{1-\alpha/2, n-1} \cdot \frac{s}{\sqrt{n}}$ | t-distribution |
| **Proportion** | $\hat{p} \pm z_{1-\alpha/2} \cdot \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$ | Large n, np ≥ 5 |
| **Difference in means** | $(\bar{x}_1 - \bar{x}_2) \pm t \cdot \sqrt{\frac{s_1^2}{n_1} + \frac{s_2^2}{n_2}}$ | Two-sample |
| **Difference in proportions** | $(\hat{p}_1 - \hat{p}_2) \pm z \cdot \sqrt{\frac{\hat{p}_1(1-\hat{p}_1)}{n_1} + \frac{\hat{p}_2(1-\hat{p}_2)}{n_2}}$ | Two-sample |

### Critical Values

| Confidence Level | z (two-sided) | z (one-sided) | t (df=∞) |
|------------------|---------------|---------------|----------|
| 90% | 1.645 | 1.282 | 1.645 |
| 95% | 1.960 | 1.645 | 1.960 |
| 99% | 2.576 | 2.326 | 2.576 |
| 99.9% | 3.291 | 3.090 | 3.291 |

---

## E.7 Regression Cheat Sheet

### Key Formulas

| Concept | Formula | Interpretation |
|---------|---------|----------------|
| **Simple Regression** | $Y = \beta_0 + \beta_1X + \varepsilon$ | Linear relationship |
| **Multiple Regression** | $Y = \beta_0 + \beta_1X_1 + ... + \beta_kX_k + \varepsilon$ | Multiple predictors |
| **OLS Estimate** | $\hat{\beta} = (X'X)^{-1}X'Y$ | Best linear unbiased estimate |
| **R²** | $1 - \frac{SSE}{SST}$ | Explained variance |
| **Adjusted R²** | $1 - \frac{SSE/(n-k-1)}{SST/(n-1)}$ | Penalized for variables |
| **F-statistic** | $\frac{SSR/k}{SSE/(n-k-1)}$ | Overall model significance |

### Standard Errors

| Component | Formula |
|-----------|---------|
| **Coefficient** | $SE(\hat{\beta}_j) = \sqrt{MSE \cdot (X'X)^{-1}_{jj}}$ |
| **Prediction (mean)** | $SE(\hat{Y}_h) = \sqrt{MSE \cdot X_h'(X'X)^{-1}X_h}$ |
| **Prediction (individual)** | $SE(\hat{Y}_h) = \sqrt{MSE \cdot [1 + X_h'(X'X)^{-1}X_h]}$ |

### Diagnostic Thresholds

| Diagnostic | Threshold | Action |
|------------|-----------|--------|
| **VIF** | > 10 | Remove variable / regularization |
| **VIF** | > 5 | Consider removing |
| **Cook's D** | > 1 | Investigate observation |
| **Leverage** | > 2(k+1)/n | High leverage point |
| **Studentized Residual** | > 3 | Outlier |
| **DFFITS** | > 2√((k+1)/n) | Influential observation |

---

## E.8 Assumption Checks Quick Guide

### Normality Check

| Method | Test Statistic | H₀ Rejected If |
|--------|---------------|----------------|
| **Shapiro-Wilk** | W (≈1) | p < 0.05 |
| **Anderson-Darling** | A² | A² > critical |
| **Kolmogorov-Smirnov** | D | D > critical |
| **Q-Q Plot** | Visual | Points deviate from line |

### Homoscedasticity Check

| Method | Test Statistic | H₀ Rejected If |
|--------|---------------|----------------|
| **Breusch-Pagan** | LM ~ χ² | p < 0.05 |
| **Goldfeld-Quandt** | F | p < 0.05 |
| **Levene** | W | p < 0.05 |
| **Residual Plot** | Visual | Fanning pattern |

### Multicollinearity Check

| Method | Threshold | Action |
|--------|-----------|--------|
| **VIF** | > 10 | Remove variable |
| **Condition Number** | > 30 | Concern |
| **Correlation Matrix** | > 0.9 | Remove one variable |

### Independence Check

| Method | Test Statistic | H₀ Rejected If |
|--------|---------------|----------------|
| **Durbin-Watson** | d ≈ 2 | d < 1 or d > 3 |
| **ACF Plot** | Visual | Significant lags |

---

## E.9 Decision Trees

### Which Hypothesis Test to Use

```
Is the response variable continuous?
│
├── YES
│   │
│   ├── How many groups?
│   │   ├── 1 group → One-sample t-test
│   │   ├── 2 groups
│   │   │   ├── Independent → t-test or Mann-Whitney U
│   │   │   └── Paired → Paired t-test or Wilcoxon
│   │   └── 3+ groups
│   │       ├── Independent → ANOVA or Kruskal-Wallis
│   │       └── Paired → Repeated measures ANOVA or Friedman
│   │
│   └── Relationship with another continuous variable
│       └── Correlation (Pearson or Spearman)
│
└── NO (Categorical response)
    │
    └── How many predictors?
        ├── 1 categorical variable
        │   └── Chi-square goodness-of-fit
        ├── 2 categorical variables
        │   └── Chi-square independence or Fisher's exact
        └── 1+ continuous variables
            └── Logistic regression
```

### Which Transformation to Use

```
Is the data skewed?
│
├── YES (Right-skewed)
│   │
│   ├── Contains zeros?
│   │   ├── YES → Log(X+1)
│   │   └── NO → Log(X) or Square root(X)
│   │
│   └── Very heavy tail?
│       └── Inverse (1/X)
│
├── YES (Left-skewed)
│   └── Square (X²) or Cube (X³)
│
└── NO (Symmetric)
    └── No transformation needed

Is variance proportional to mean?
│
├── YES
│   └── Log transformation
│
└── NO
    └── Variance stabilizing transformation (Box-Cox)
```

---

## E.10 Quick Reference: Interpretation Guide

### P-Value Interpretation

| p-value | Evidence Against H₀ | Strength |
|---------|--------------------|----------|
| **p < 0.001** | Very strong | ★★★ |
| **0.001 < p < 0.01** | Strong | ★★ |
| **0.01 < p < 0.05** | Moderate | ★ |
| **0.05 < p < 0.10** | Weak/marginal | - |
| **p > 0.10** | None | - |

### Effect Size Interpretation

| Test | Small | Medium | Large |
|------|-------|--------|-------|
| **Cohen's d** | 0.2 | 0.5 | 0.8 |
| **Pearson's r** | 0.1 | 0.3 | 0.5 |
| **Cramer's V** | 0.1 | 0.3 | 0.5 |
| **Eta-squared** | 0.01 | 0.06 | 0.14 |
| **Odds Ratio** | 1.5 | 2.5 | 4.0 |

### R-Squared Interpretation

| R² | Interpretation |
|----|----------------|
| **0.00 - 0.09** | Negligible predictive power |
| **0.10 - 0.29** | Weak predictive power |
| **0.30 - 0.49** | Moderate predictive power |
| **0.50 - 0.69** | Strong predictive power |
| **0.70 - 0.89** | Very strong predictive power |
| **0.90 - 1.00** | Excellent predictive power |

---

## E.11 Common Rules of Thumb

### Sample Size Rules

| Scenario | Minimum | Recommendation |
|----------|---------|----------------|
| **CLT applies** | 30 per group | 50 per group |
| **Parametric tests** | 30 per group | 50 per group |
| **Non-parametric tests** | 15 per group | 25 per group |
| **Correlation** | 30 total | 100 total |
| **ANOVA** | 15 per group | 30 per group |
| **Regression** | 10-20 per predictor | 50+ total |
| **A/B testing** | 100 per group | 500+ per group |
| **Chi-square** | 5 per cell | 10 per cell |

### Statistical Significance Rules

| Rule | Condition |
|------|-----------|
| **Common α** | 0.05 |
| **Stringent α** | 0.01 |
| **Conservative α** | 0.001 |
| **Target power** | 0.80 |
| **High power** | 0.90 |
| **Minimum power** | 0.70 |

### Model Diagnostic Rules

| Diagnostic | Good | Concern | Problem |
|------------|------|---------|---------|
| **VIF** | < 5 | 5-10 | > 10 |
| **Cook's D** | < 4/n | 4/n - 1 | > 1 |
| **Studentized residual** | < 2 | 2-3 | > 3 |
| **Leverage** | < 2(k+1)/n | > 2(k+1)/n | - |
| **Durbin-Watson** | 1.5-2.5 | 1-1.5 or 2.5-3 | < 1 or > 3 |
| **Shapiro-Wilk p** | > 0.05 | 0.01-0.05 | < 0.01 |

---

## E.12 Common Pitfalls and Solutions (Cheat Sheet)

| Pitfall | Quick Fix |
|---------|-----------|
| **p < 0.05 but effect is tiny** | Report effect size, not just p-value |
| **Large effect but p > 0.05** | Increase sample size |
| **Non-normal data** | Use non-parametric tests or transform |
| **Heteroscedasticity** | Use robust standard errors |
| **Multicollinearity** | Remove redundant variables |
| **Influential point** | Investigate; consider robust regression |
| **Missing data** | Use multiple imputation |
| **Multiple testing** | Apply Bonferroni or FDR correction |
| **Overfitting** | Use cross-validation or regularization |
| **Confounding** | Include confounders in model |

---

## E.13 Summary: Key Takeaways

1. **Keep this reference handy** — it's your quick guide to everything
2. **Rules of thumb are guidelines** — use judgment, not just rules
3. **Context matters** — what's "good" depends on your field
4. **Always check assumptions** before trusting results
5. **Effect sizes tell the real story** — p-values only tell part
6. **When in doubt, use non-parametric** tests (they're safer)
7. **Sample size matters** — more is almost always better
8. **Multiple testing corrections** prevent false discoveries

**Final Appendix: F — Glossary of Statistical Terms**
