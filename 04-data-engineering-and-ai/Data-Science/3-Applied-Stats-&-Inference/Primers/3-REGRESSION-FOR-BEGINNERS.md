# PRIMER 3: REGRESSION FOR BEGINNERS

Welcome to the third primer! Building on our foundations, this primer will help you understand **regression analysis** — the tool that helps us understand relationships between variables and make predictions. Think of regression as the "how much does X affect Y?" question-answerer.

---

## P3.1 What is Regression?

### The Core Question

Imagine you're a real estate agent trying to predict house prices. You know:

- Bigger houses cost more
- Better neighborhoods cost more
- Newer houses cost more

**Regression answers:** "Exactly how much does each square foot add to the price? How much does a good neighborhood add?"

### The Simple Analogy

Think of regression like finding the **line of best fit** through a scatter plot:

```
Price
  │
  │     ●
  │   ●   ●                    ●
  │ ●   ●   ●                ●
  │●   ●   ●   ●          ●
  │  ●   ●   ●   ●      ●
  │ ●   ●   ●   ●   ●  ●
  │    ●   ●   ●   ● ●
  │        ●   ● ●
  │            ●
  └────────────────────────────────
              Size
```

The line through the middle represents the **relationship** between size and price.

### Key Insight

**Regression quantifies relationships.** It tells you:
1. **Direction:** Do they go up together or opposite?
2. **Strength:** How strong is the relationship?
3. **Magnitude:** How much does Y change when X changes by 1 unit?
4. **Uncertainty:** How confident are we in these estimates?

---

## P3.2 Simple Linear Regression: One Predictor

### The Equation

The simplest form of regression has one predictor:

$$Y = \beta_0 + \beta_1 X + \varepsilon$$

| Symbol | Meaning | Example |
|--------|---------|---------|
| **Y** | What we're predicting (price) | House price in thousands |
| **X** | What we're using to predict (size) | Square footage |
| **β₀** | Intercept (price when X=0) | Base price |
| **β₁** | Slope (change in Y per unit X) | Price per square foot |
| **ε** | Error (unexplained variation) | Everything else that affects price |

### The Intercept (β₀)

**What it is:** The value of Y when X = 0

**Example:** The base price of a house with 0 square feet (which doesn't make sense, but it's mathematically useful)

**In practice:** The intercept is often meaningless on its own. It just helps position the line.

### The Slope (β₁)

**What it is:** How much Y changes when X increases by 1 unit

**Example:** If β₁ = 0.15, then each additional square foot adds $150 to the price (0.15 × $1,000)

**Interpretation:** "For every 1-unit increase in X, Y changes by β₁ units"

### Real-World Example

**Scenario:** Predicting house prices from square footage

**Data:**
- House 1: 1,000 sq ft, $150,000
- House 2: 2,000 sq ft, $250,000
- House 3: 3,000 sq ft, $350,000

**Regression equation:** Price = $50,000 + $100 × Square feet

**Interpretation:**
- Intercept ($50,000): Base price
- Slope ($100): Each additional square foot adds $100
- Prediction: A 1,500 sq ft house would cost $50,000 + $100 × 1,500 = $200,000

---

## P3.3 Multiple Linear Regression: Many Predictors

### The Equation

When you have multiple predictors:

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + ... + \beta_k X_k + \varepsilon$$

### Example: House Price Model

$$Price = \beta_0 + \beta_1(SqFt) + \beta_2(Bedrooms) + \beta_3(Age) + \beta_4(Location) + \varepsilon$$

### Interpretation of Coefficients

Each coefficient represents the effect of that variable **while holding all other variables constant**.

| Variable | Coefficient | Interpretation (holding others constant) |
|----------|-------------|------------------------------------------|
| **SqFt** | 0.15 | Each extra sq ft adds $150 |
| **Bedrooms** | 20 | Each extra bedroom adds $20,000 |
| **Age** | -0.5 | Each year older reduces price by $500 |
| **Location** | 15 | Each point better location adds $15,000 |

### Why Multiple Regression Matters

**Confounding:** Variables can influence each other.

**Example:** Larger houses tend to be newer. If you only look at size, you might think newer houses are cheaper (because they're smaller). Multiple regression separates these effects.

### The "Holding Constant" Concept

Think of it like this:

1. Compare two houses that are identical in all ways EXCEPT X₁
2. The difference in Y is β₁
3. This isolates the pure effect of X₁

---

## P3.4 R-Squared: How Good is Your Model?

### What is R²?

**R-squared** measures how much of the variation in Y is explained by your model.

- **R² = 0:** Model explains nothing
- **R² = 1:** Model explains everything
- **R² = 0.75:** Model explains 75% of the variation

### Visualizing R²

```
Variation in Y
┌─────────────────────────────────┐
│ ████████████████████░░░░░░░░░░ │
│ ████████████████████░░░░░░░░░░ │
│ ████████████████████░░░░░░░░░░ │
│ ████████████████████░░░░░░░░░░ │
└─────────────────────────────────┘
  Explained      Unexplained
  by model       (error)
  (R² = 75%)
```

### Interpreting R²

| R² | Interpretation |
|----|----------------|
| **0.00 - 0.09** | Negligible predictive power |
| **0.10 - 0.29** | Weak predictive power |
| **0.30 - 0.49** | Moderate predictive power |
| **0.50 - 0.69** | Strong predictive power |
| **0.70 - 0.89** | Very strong predictive power |
| **0.90 - 1.00** | Excellent predictive power |

### R² in Different Fields

| Field | Typical R² | Why? |
|-------|-----------|------|
| **Physics** | 0.95+ | Very controlled experiments |
| **Economics** | 0.30-0.50 | Many complex factors |
| **Social Sciences** | 0.10-0.30 | Human behavior is complex |
| **Marketing** | 0.10-0.40 | Many external factors |

### Adjusted R²

Regular R² always increases when you add more variables (even if they're useless). Adjusted R² penalizes complexity.

**When to use:** Use adjusted R² when comparing models with different numbers of variables.

---

## P3.5 Making Predictions

### How to Predict

Once you have your model, you can predict Y for any X.

**Example Model:** Price = 50 + 0.15 × SqFt

**Predictions:**
- 1,000 sq ft → 50 + 0.15 × 1,000 = $200,000
- 2,000 sq ft → 50 + 0.15 × 2,000 = $350,000
- 3,000 sq ft → 50 + 0.15 × 3,000 = $500,000

### Prediction vs. Reality

**Predictions are estimates, not certainties.**

```
Actual Price
  │
  │●
  │      ●
  │      │
  │   ●  │  ●
  │      │
  │  ●   └──●  ← Prediction
  │      │
  │ ●    │   ●
  │      │
  │●     │    ●
  └────────────────────────────
              Size

The vertical distance between ● and ─ is the prediction error (residual)
```

### Prediction Intervals

**Prediction interval:** Range where a new observation is likely to fall (wide)

**Confidence interval:** Range where the true line is likely to be (narrow)

```
Prediction Interval (wide)
┌─────────────────────────────────────┐
│         ┌─────────────────────┐     │
│    ─────│─────   ●   ───────────── │
│         └─────────────────────┘     │
└─────────────────────────────────────┘

Confidence Interval (narrow)
┌─────────────────────────────────────┐
│              ┌───┐                  │
│    ──────────│───│───●──────────── │
│              └───┘                  │
└─────────────────────────────────────┘
```

---

## P3.6 Assumptions: When Regression Works

### The Four Key Assumptions

#### 1. Linearity

**What it is:** The relationship between X and Y is a straight line.

**Check:** Residual vs fitted plot should show no pattern.

```
Good (No Pattern)       Bad (Curved Pattern)
     │                      │
   ● ● ●                  ● ● ●
 ●   ●   ●              ●     ●
●   ●   ●              ●       ●
   ● ● ●                  ● ● ●
     │                      │
```

#### 2. Independence

**What it is:** Observations don't influence each other.

**Violation:** Time series data (today's value depends on yesterday's)

#### 3. Homoscedasticity

**What it is:** The spread of residuals is constant across all X values.

```
Good (Constant Spread)  Bad (Increasing Spread)
     │                      │
  ● ● ● ●                ●       ●
●   ●   ●              ●   ●   ●
●   ●   ●            ●   ●   ●
  ● ● ● ●          ●   ●   ●
     │                      │
```

#### 4. Normality

**What it is:** Residuals follow a normal distribution.

**Check:** Q-Q plot should show points on the diagonal line.

```
Good (Normal)          Bad (Not Normal)
   │                      │
    \                    ●
     \                 ●
      \              ●
       \           ●
        \        ●
         \     ●
          \●●●
           │                      │
```

### What Happens When Assumptions are Violated?

| Violation | Consequence | Solution |
|-----------|-------------|----------|
| **Non-linearity** | Biased predictions | Transform variables |
| **Non-independence** | Wrong standard errors | Time series models |
| **Heteroscedasticity** | Wrong p-values | Robust standard errors |
| **Non-normality** | Wrong p-values | Non-parametric methods |

---

## P3.7 Interpreting a Regression Output

### A Typical Output

```
==================================================================
                            OLS Regression Results
==================================================================
Dep. Variable:                   Price   R-squared:                   0.753
Model:                            OLS   Adj. R-squared:              0.742
Method:                 Least Squares   F-statistic:                 68.42
Date:                Wed, 01 Jan 2025   Prob (F-statistic):         2.34e-12
Time:                        12:00:00   Log-Likelihood:            -234.56
==================================================================
                coef    std err          t      P>|t|      [0.025      0.975]
------------------------------------------------------------------
Intercept     50.2344     12.345      4.069      0.001     25.678     74.791
SqFt           0.1523      0.023      6.622      0.000      0.107      0.198
Bedrooms      18.5678      5.678      3.270      0.002      7.234     29.901
Age           -0.4567      0.234     -1.952      0.053     -0.923      0.010
Location      14.8901      4.567      3.260      0.002      5.778     24.002
==================================================================
```

### Reading the Output

| Column | What it means |
|--------|---------------|
| **coef** | Coefficient (effect size) |
| **std err** | Standard error (uncertainty) |
| **t** | t-statistic (coef / std err) |
| **P>|t|** | p-value (significance) |
| **[0.025 0.975]** | 95% confidence interval |

### Making Sense of It

**SqFt:** β = 0.152, p < 0.001 → Highly significant! Each extra sq ft adds $152 to price.

**Bedrooms:** β = 18.57, p = 0.002 → Significant! Each extra bedroom adds $18,570.

**Age:** β = -0.457, p = 0.053 → Not significant at 0.05 (p > 0.05) → Age may not matter.

**Location:** β = 14.89, p = 0.002 → Significant! Better location adds value.

### R² and Adjusted R²

- **R² = 0.753:** The model explains 75.3% of price variation
- **Adj R² = 0.742:** After penalizing for 4 predictors, still 74.2%

---

## P3.8 Logistic Regression: When Y is Binary

### The Difference

**Linear regression:** Y is continuous (price, height, temperature)

**Logistic regression:** Y is binary (yes/no, convert/not, success/failure)

### The Logistic Function

Linear regression would give predictions like -50 or 200% for probabilities — which doesn't make sense.

Logistic regression transforms predictions to be between 0 and 1.

```
Probability
    1.0 │              ┌──────────
        │            ┌─┘
    0.5 │          ┌─┘
        │        ┌─┘
    0.0 │───────┘
        └────────────────────────────
                   X
```

### Interpreting Odds Ratios

**Odds ratio (OR):** How the odds of the outcome change with a 1-unit increase in X.

| OR | Interpretation |
|----|----------------|
| **OR = 1** | No effect |
| **OR = 1.5** | 50% increase in odds |
| **OR = 2** | Doubles the odds |
| **OR = 0.5** | Half the odds |

### Example: Predicting Conversion

**Model:** Probability of conversion = logistic(β₀ + β₁ × Age + β₂ × Treatment)

**Results:**
- Treatment OR = 2.5 → Treatment increases odds of conversion by 150%
- Age OR = 0.98 → Each year older slightly decreases odds of conversion

---

## P3.9 Model Selection: Which Variables to Include?

### The Goal

Find the simplest model that adequately explains the data.

### Methods

#### Forward Selection
1. Start with no variables
2. Add the variable with the smallest p-value
3. Continue until no variable has p < 0.05

#### Backward Elimination
1. Start with all variables
2. Remove the variable with the largest p-value
3. Continue until all variables have p < 0.05

#### Stepwise Selection
1. Combine forward and backward
2. Can add and remove variables at each step

### The Danger of Overfitting

**Overfitting:** A model that fits the training data perfectly but fails on new data.

**Analogy:** It's like memorizing the answers to a test instead of learning the material.

**Signs of overfitting:**
- R² is very high (> 0.90)
- Model performs poorly on new data
- Many variables are included

### Preventing Overfitting

1. **Cross-validation:** Test model on held-out data
2. **AIC/BIC:** Penalize complexity
3. **Regularization:** Shrink coefficients to avoid overfitting
4. **Domain knowledge:** Don't just include everything

---

## P3.10 Common Mistakes and How to Avoid Them

### Mistake 1: Overinterpreting the Intercept

**Problem:** "The intercept says X=0 would be $50,000, but that doesn't make sense!"

**Solution:** The intercept is often meaningless on its own. Focus on the coefficients of variables that are in your data range.

### Mistake 2: Extrapolating Beyond the Data

**Problem:** Predicting a 10,000 sq ft house when your data only goes up to 3,000 sq ft.

**Solution:** Stay within the range of your data.

### Mistake 3: Ignoring Multicollinearity

**Problem:** Variables are highly correlated with each other.

**Example:** Bedrooms and square feet are correlated. The model can't tell which is driving the effect.

**Solution:** Check VIF (should be < 10). Remove one variable or combine them.

### Mistake 4: Confusing Correlation with Causation

**Problem:** "The model shows X predicts Y, so X must cause Y."

**Solution:** Regression shows association, not causation. Experiments are needed for causation.

### Mistake 5: Not Checking Assumptions

**Problem:** Running regression without checking if the assumptions are met.

**Solution:** Always check diagnostic plots and tests.

---

## P3.11 Quick Reference: Regression in Plain English

| Term | Plain English Definition |
|------|-------------------------|
| **Regression** | Finding the relationship between variables |
| **Coefficient** | "How much Y changes when X changes by 1" |
| **Intercept** | The value of Y when all X's are 0 |
| **R-squared** | "How much of Y is explained by the model" |
| **Residual** | "How far off our prediction was" |
| **P-value** | "How confident are we that this coefficient isn't just noise?" |
| **Prediction** | "What we think Y will be for new X values" |
| **Linearity** | "The relationship is a straight line" |
| **Homoscedasticity** | "The spread is the same everywhere" |
| **Multicollinearity** | "When predictors are too similar to each other" |

---

## P3.12 Quick Self-Check Quiz

### Question 1
What does the slope (β₁) represent in a regression?

**Answer:** The change in Y for a 1-unit increase in X.

### Question 2
What's the difference between R² and Adjusted R²?

**Answer:** Adjusted R² penalizes adding unnecessary variables.

### Question 3
When would you use logistic regression instead of linear regression?

**Answer:** When the outcome (Y) is binary (yes/no, success/failure).

### Question 4
What are the four main assumptions of regression?

**Answer:** Linearity, Independence, Homoscedasticity, Normality.

### Question 5
Why is it important not to extrapolate beyond your data range?

**Answer:** The relationship might change outside the range where you have data.

---

## P3.13 Next Steps

With these foundations, you're ready to:

1. **Tackle Module 3.3:** Build regression models with code
2. **Apply regression:** Use it on your own data
3. **Understand research papers:** Interpret regression results in papers

### Key Takeaways

1. **Regression quantifies relationships** between variables
2. **Coefficients** tell you the size and direction of effects
3. **R-squared** tells you how much your model explains
4. **Multiple regression** separates the effects of different variables
5. **Logistic regression** is for binary outcomes
6. **Always check assumptions** — violations invalidate your results
7. **Don't overfit** — keep models simple and validated
8. **Correlation ≠ causation** — regression doesn't prove causation
