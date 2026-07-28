# APPENDIX C: COMPLETE REFERENCE — REGRESSION & DIAGNOSTICS

Welcome to the third appendix! This reference provides a comprehensive guide to regression modeling and model diagnostics. Think of this as your **regression handbook** — everything you need to know about building, interpreting, and validating regression models.

---

## C.1 Linear Regression Fundamentals

### The Regression Equation

**Simple Linear Regression:**
$$Y = \beta_0 + \beta_1 X + \varepsilon$$

**Multiple Linear Regression:**
$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + ... + \beta_k X_k + \varepsilon$$

**In Matrix Notation:**
$$\mathbf{Y} = \mathbf{X}\boldsymbol{\beta} + \boldsymbol{\varepsilon}$$

### Components

| Component | Description |
|-----------|-------------|
| **Y** | Dependent variable (response, outcome) |
| **X** | Independent variables (predictors, features) |
| **β₀** | Intercept (value of Y when all X = 0) |
| **βᵢ** | Coefficient for predictor i (change in Y per unit change in Xᵢ) |
| **ε** | Error term (unexplained variation) |

### Interpretation of Coefficients

| Coefficient Type | Interpretation |
|------------------|----------------|
| **β₀ (Intercept)** | Expected Y when all predictors are 0 |
| **βᵢ (Numerical)** | For a 1-unit increase in Xᵢ, Y changes by βᵢ units (holding other variables constant) |
| **βᵢ (Binary 0/1)** | The difference in Y between the two categories |
| **βᵢ (Standardized)** | For a 1-standard-deviation increase in Xᵢ, Y changes by βᵢ standard deviations |

---

## C.2 Ordinary Least Squares (OLS) Estimation

### The Normal Equations

The OLS solution minimizes the sum of squared residuals:

$$\hat{\boldsymbol{\beta}} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{Y}$$

### Key Statistics

**Sum of Squares:**
- **Total (SST):** $\sum (Y_i - \bar{Y})^2$
- **Regression (SSR):** $\sum (\hat{Y}_i - \bar{Y})^2$
- **Error (SSE):** $\sum (Y_i - \hat{Y}_i)^2$

**R-squared:**
$$R^2 = \frac{SSR}{SST} = 1 - \frac{SSE}{SST}$$

**Adjusted R-squared:**
$$R^2_{adj} = 1 - \frac{SSE/(n-k-1)}{SST/(n-1)}$$

### Standard Errors

**For Coefficients:**
$$SE(\hat{\beta}_j) = \sqrt{MSE \cdot (\mathbf{X}^T\mathbf{X})^{-1}_{jj}}$$

Where $MSE = \frac{SSE}{n-k-1}$ (Mean Squared Error)

### Confidence Intervals

**For Coefficients:**
$$\hat{\beta}_j \pm t_{\alpha/2, n-k-1} \cdot SE(\hat{\beta}_j)$$

**For Predictions:**
- **Mean response:** $\hat{Y}_h \pm t_{\alpha/2, n-k-1} \cdot \sqrt{MSE \cdot \mathbf{X}_h^T(\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}_h}$
- **Individual prediction:** $\hat{Y}_h \pm t_{\alpha/2, n-k-1} \cdot \sqrt{MSE \cdot [1 + \mathbf{X}_h^T(\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}_h]}$

---

## C.3 Model Assumptions (LINE)

### The Four Key Assumptions

| Assumption | Description | Why It Matters | How to Check |
|------------|-------------|----------------|--------------|
| **Linearity** | Relationship between X and Y is linear | Non-linearity leads to biased estimates | Residual vs fitted plot, added variable plots |
| **Independence** | Observations are independent | Violations affect standard errors | Durbin-Watson test, residual time series plots |
| **Normality** | Residuals are normally distributed | Affects p-values and confidence intervals | Q-Q plot, Shapiro-Wilk test |
| **Equal Variance (Homoscedasticity)** | Constant variance of residuals | Affects standard errors and p-values | Residual vs fitted plot, Breusch-Pagan test |

### Consequences of Violating Assumptions

| Violation | Consequence | Solution |
|-----------|-------------|----------|
| **Non-linearity** | Biased coefficients | Transform variables, add polynomial terms |
| **Non-independence** | Inflated Type I error | Use time series models, mixed models |
| **Non-normality** | Invalid p-values | Use robust standard errors, bootstrap |
| **Heteroscedasticity** | Inefficient estimates | Use robust standard errors, weighted least squares |
| **Multicollinearity** | Unstable coefficients | Remove variables, use regularization |

---

## C.4 Multicollinearity

### Definition

High correlation between predictor variables, making it difficult to estimate individual effects.

### Variance Inflation Factor (VIF)

$$VIF_j = \frac{1}{1 - R^2_j}$$

Where $R^2_j$ is the R-squared from regressing Xⱼ on all other predictors.

**Interpretation:**
- **VIF = 1:** No correlation
- **1 < VIF < 5:** Moderate correlation (acceptable)
- **5 < VIF < 10:** High correlation (concerning)
- **VIF > 10:** Severe correlation (problematic)

### Detection

1. **Correlation matrix:** Check pairwise correlations
2. **VIF:** Calculate for each variable
3. **Condition number:** κ = sqrt(λ_max/λ_min)

### Solutions

| Solution | When to Use |
|----------|-------------|
| **Remove variables** | When variables are redundant |
| **Combine variables** | PCA, factor analysis |
| **Regularization** | Ridge, Lasso regression |
| **Collect more data** | Reduce sampling variance |

---

## C.5 Model Diagnostics

### Residual Analysis

**Standardized Residuals:**
$$r_i = \frac{e_i}{MSE \cdot (1 - h_{ii})}$$

Where $h_{ii}$ is the leverage (diagonal of the hat matrix)

**Studentized Residuals:**
$$r_i^* = \frac{e_i}{\sqrt{MSE_{(i)} \cdot (1 - h_{ii})}}$$

Where $MSE_{(i)}$ is MSE without observation i

### Leverage

$$h_{ii} = \mathbf{X}_i^T(\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}_i$$

**Rule of thumb:** Values > $2(k+1)/n$ are high leverage

### Cook's Distance

$$D_i = \frac{e_i^2}{(k+1)MSE} \cdot \frac{h_{ii}}{(1-h_{ii})^2}$$

**Rule of thumb:** $D_i > 1$ indicates influential points

### DFFITS

$$DFFITS_i = r_i^* \sqrt{\frac{h_{ii}}{1-h_{ii}}}$$

**Rule of thumb:** $|DFFITS| > 2\sqrt{(k+1)/n}$ indicates influential points

---

## C.6 Goodness-of-Fit Measures

### For Linear Regression

| Measure | Range | Interpretation |
|---------|-------|----------------|
| **R²** | [0, 1] | Proportion of variance explained |
| **Adjusted R²** | [0, 1] | R² penalized for number of predictors |
| **AIC** | Lower is better | Akaike Information Criterion |
| **BIC** | Lower is better | Bayesian Information Criterion |
| **MSE** | [0, ∞) | Mean squared error (lower is better) |
| **RMSE** | [0, ∞) | Root mean squared error (lower is better) |
| **MAE** | [0, ∞) | Mean absolute error (lower is better) |

### Information Criteria

**AIC:**
$$AIC = -2\ln(L) + 2k$$

**BIC:**
$$BIC = -2\ln(L) + k\ln(n)$$

Where $L$ is the maximum likelihood, $k$ is number of parameters, $n$ is sample size.

---

## C.7 Variable Selection Methods

### Forward Selection

1. Start with no variables
2. Add the variable with the smallest p-value
3. Continue until no variable has p-value < α

### Backward Elimination

1. Start with all variables
2. Remove the variable with the largest p-value
3. Continue until all variables have p-value < α

### Stepwise Selection

1. Combine forward and backward
2. Add variables with small p-values, remove variables with large p-values
3. Continue until no changes

### Regularization Methods

| Method | Penalty | Effect |
|--------|---------|--------|
| **Ridge** | L₂ penalty | Shrinks coefficients, keeps all variables |
| **Lasso** | L₁ penalty | Performs variable selection |
| **Elastic Net** | Both L₁ and L₂ | Combines both methods |

---

## C.8 Logistic Regression

### The Logistic Function

$$P(Y=1) = \frac{1}{1 + e^{-(\beta_0 + \beta_1X_1 + ... + \beta_kX_k)}}$$

### Logit Transformation

$$\log\left(\frac{P(Y=1)}{1-P(Y=1)}\right) = \beta_0 + \beta_1X_1 + ... + \beta_kX_k$$

### Interpreting Coefficients

**Odds Ratios (OR):**
$$OR = e^{\beta_i}$$

**Interpretation:**
- OR > 1: Increased odds of outcome
- OR < 1: Decreased odds of outcome
- OR = 1: No effect

### Goodness-of-Fit

| Measure | Interpretation |
|---------|----------------|
| **Deviance** | -2 log-likelihood |
| **AIC** | Deviance + 2k |
| **McFadden R²** | 1 - (LL(model) / LL(null)) |
| **Hosmer-Lemeshow** | Goodness-of-fit test (p > 0.05 = good fit) |
| **Classification Accuracy** | % correctly classified |

---

## C.9 Model Comparison

### Nested Models

**F-test for nested models:**
$$F = \frac{(SSE_{reduced} - SSE_{full})/(df_{reduced} - df_{full})}{SSE_{full}/df_{full}}$$

### Non-Nested Models

- **AIC/BIC:** Lower is better
- **Cross-validation:** Compare predictive accuracy
- **Likelihood ratio test:** For nested models only

---

## C.10 Regression Diagnostics: Decision Tree

```
Have you checked for linearity?
│
├── No → Check residual vs fitted plot
│
└── Yes → Check for multicollinearity?
    │
    ├── VIF > 10 → Remove variables, use regularization
    │
    └── VIF < 5 → Check normality of residuals?
        │
        ├── Shapiro-Wilk p < 0.05 → Consider transformation
        │
        └── p ≥ 0.05 → Check homoscedasticity?
            │
            ├── Breusch-Pagan p < 0.05 → Use robust SE, weighted LS
            │
            └── p ≥ 0.05 → Check for outliers?
                │
                ├── Cook's D > 1 → Investigate influential points
                │
                └── No issues → Model is valid!
```

---

## C.11 Common Transformations

### For Predictor Variables

| Transformation | Formula | When to Use |
|----------------|---------|-------------|
| **Log** | ln(X) | Right-skewed data |
| **Square root** | √X | Count data |
| **Square** | X² | Left-skewed data |
| **Inverse** | 1/X | Strong right-skew |
| **Box-Cox** | (X^λ - 1)/λ | General purpose |

### For Response Variable

| Transformation | Formula | When to Use |
|----------------|---------|-------------|
| **Log** | ln(Y) | Right-skewed, multiplicative effects |
| **Square root** | √Y | Count data, Poisson |
| **Logit** | ln(p/(1-p)) | Proportions (0,1) |
| **Box-Cox** | (Y^λ - 1)/λ | General purpose |

---

## C.12 Quick Reference: Regression Jargon

| Term | Definition |
|------|------------|
| **Coefficient** | Effect size for a predictor |
| **Standard Error** | Uncertainty in coefficient estimate |
| **p-value** | Significance of coefficient |
| **R-squared** | Proportion of variance explained |
| **Adjusted R-squared** | R-squared penalized for variables |
| **F-statistic** | Overall model significance |
| **Residuals** | Prediction errors |
| **Leverage** | Influence of X values |
| **Influence** | Impact of observation on model |
| **Multicollinearity** | Correlation between predictors |
| **Heteroscedasticity** | Non-constant variance |
| **Autocorrelation** | Correlation of residuals |

---

## C.13 Regression Reporting Standards

### What to Include

1. **Sample size** (n)
2. **R-squared** and adjusted R-squared
3. **F-statistic** and p-value
4. **All coefficients** with standard errors
5. **p-values** for each coefficient
6. **Confidence intervals** (95%)
7. **Assumption checks** (normality, homoscedasticity, etc.)
8. **Multicollinearity check** (VIF values)

### Example Report

> A multiple linear regression was conducted to predict house prices using square footage, number of bedrooms, age, and location score. The model was statistically significant (F(4, 95) = 12.45, p < 0.001, R² = 0.34). Square footage was the strongest predictor (β = 0.32, SE = 0.08, p < 0.001, 95% CI [0.16, 0.48]), with each additional square foot associated with a $120 increase in price. Model diagnostics showed no violations of linearity, normality, or homoscedasticity (all VIF < 5, Shapiro-Wilk p = 0.23, Breusch-Pagan p = 0.18).

---

## C.14 Model Comparison Checklist

| Criteria | Description |
|----------|-------------|
| **Theoretical justification** | Does the model make sense? |
| **Statistical significance** | Are the coefficients significant? |
| **Goodness-of-fit** | Is R² appropriate for the field? |
| **Model diagnostics** | Are assumptions met? |
| **Predictive accuracy** | Does it predict well? |
| **Parsimony** | Are all variables necessary? |
| **Interpretability** | Can you explain the results? |
| **Generalizability** | Will it work on new data? |

---

## C.15 Common Pitfalls and Solutions

| Pitfall | Solution |
|---------|----------|
| **Overfitting** | Use cross-validation, regularization |
| **Ignoring multicollinearity** | Check VIF, remove redundant variables |
| **Not checking residuals** | Always run diagnostics |
| **Extrapolating beyond data** | Stay within the range of your data |
| **Ignoring influential points** | Identify and understand outliers |
| **Confusing correlation with causation** | Experiments, not observational data |
| **Not accounting for interactions** | Include interaction terms |
| **Using too many variables** | Use variable selection methods |

---

## C.16 Summary: Key Takeaways

1. **Always check assumptions** — models are only valid if assumptions are met
2. **Linearity is key** — if relationship is non-linear, transform or use different model
3. **Multicollinearity can hide effects** — check VIF
4. **Outliers can change results** — identify and understand them
5. **R-squared is not everything** — diagnostics matter more
6. **Coefficients tell the story** — interpret them carefully
7. **Report everything** — coefficients, SEs, p-values, diagnostics
8. **Keep it simple** — the simplest adequate model is best

---

**Next Appendix: D — Python Library API Reference**
