# PHASE 3: APPLIED STATISTICS & HYPOTHESIS TESTING
## STUDENT WORKBOOK

This workbook contains exercises, practice problems, and hands-on activities for each module of Phase 3. Each section includes learning objectives, key concepts, practice problems, and reflection questions.

---

## WORKBOOK STRUCTURE

| Section | Topic | Exercises |
|---------|-------|-----------|
| 1 | Module 3.1: Descriptive Foundations | 12 exercises |
| 2 | Module 3.2: Hypothesis Testing | 12 exercises |
| 3 | Module 3.3: Regression Modeling | 12 exercises |
| 4 | Capstone Project | 6 exercises |
| 5 | Self-Assessment Quiz | 30 questions |

---

# SECTION 1: MODULE 3.1 — DESCRIPTIVE FOUNDATIONS

## LEARNING OBJECTIVES

By completing this section, you will be able to:
- Identify different probability distributions
- Calculate descriptive statistics manually
- Construct and interpret confidence intervals
- Explain the Central Limit Theorem
- Perform bootstrap resampling

---

## EXERCISE 1.1: DISTRIBUTION IDENTIFICATION

### Part A: Identify the Distribution

For each scenario, identify the most appropriate probability distribution.

**1.** Number of heads in 10 coin flips
- [ ] Normal
- [ ] Binomial
- [ ] Poisson
- [ ] Exponential
- [ ] Uniform

**2.** Time between customer arrivals at a store
- [ ] Normal
- [ ] Binomial
- [ ] Poisson
- [ ] Exponential
- [ ] Uniform

**3.** Number of customers arriving per hour (average = 5)
- [ ] Normal
- [ ] Binomial
- [ ] Poisson
- [ ] Exponential
- [ ] Uniform

**4.** Heights of adult males (mean = 175cm, σ = 7cm)
- [ ] Normal
- [ ] Binomial
- [ ] Poisson
- [ ] Exponential
- [ ] Uniform

**5.** Random number between 0 and 1
- [ ] Normal
- [ ] Binomial
- [ ] Poisson
- [ ] Exponential
- [ ] Uniform

### Part B: Distribution Properties

Complete the table:

| Distribution | Parameters | Mean | Variance |
|--------------|------------|------|----------|
| Normal | μ, σ | ___ | ___ |
| Binomial | n, p | ___ | ___ |
| Poisson | λ | ___ | ___ |
| Exponential | λ | ___ | ___ |
| Uniform | a, b | ___ | ___ |

---

## EXERCISE 1.2: DESCRIPTIVE STATISTICS CALCULATIONS

### Part A: Calculate by Hand

Given the dataset: [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

**1.** Calculate the mean: _______

**2.** Calculate the median: _______

**3.** Calculate the range: _______

**4.** Calculate the variance (population): _______

**5.** Calculate the standard deviation: _______

### Part B: With Outliers

Dataset: [2, 4, 6, 8, 10, 12, 14, 16, 18, 200]

**1.** Mean: _______
**2.** Median: _______
**3.** Which is more representative? _______

### Part C: Interpret Results

You survey 100 people and find:
- Mean age = 35.2 years
- Median age = 32.0 years
- Standard deviation = 12.5 years

**1.** Is the data skewed? How can you tell? _______

**2.** What does the standard deviation tell you? _______

**3.** What's a better measure of central tendency? _______

---

## EXERCISE 1.3: STANDARD DEVIATION AND VARIANCE

### Part A: Calculate Step by Step

Dataset: [5, 7, 9, 11, 13]

**Step 1:** Calculate the mean: _______

**Step 2:** Calculate deviations from mean:

| Value | Deviation | Squared Deviation |
|-------|-----------|-------------------|
| 5     | ___       | ___               |
| 7     | ___       | ___               |
| 9     | ___       | ___               |
| 11    | ___       | ___               |
| 13    | ___       | ___               |

**Step 3:** Sum of squared deviations: _______

**Step 4:** Variance (population): _______

**Step 5:** Standard deviation: _______

### Part B: Interpret

Dataset A: [1, 2, 3, 4, 5]
Dataset B: [1, 10, 20, 30, 100]

**1.** Calculate standard deviation of Dataset A: _______

**2.** Calculate standard deviation of Dataset B: _______

**3.** What does the difference tell you? _______

---

## EXERCISE 1.4: THE NORMAL DISTRIBUTION

### Part A: Z-Score Calculations

Given: μ = 100, σ = 15

**1.** Calculate z-score for X = 115: _______
**2.** Calculate z-score for X = 85: _______
**3.** Calculate z-score for X = 130: _______

### Part B: Probability Calculations

**1.** What percentage of data is between μ - σ and μ + σ? _______

**2.** What percentage is between μ - 2σ and μ + 2σ? _______

**3.** What percentage is greater than μ + σ? _______

### Part C: Real-World Application

IQ scores: μ = 100, σ = 15

**1.** What IQ corresponds to the 95th percentile? _______

**2.** What percentage of people have IQ > 130? _______

**3.** What percentage have IQ between 85 and 115? _______

---

## EXERCISE 1.5: CONFIDENCE INTERVALS

### Part A: CI for Mean (σ Known)

Data: n = 100, x̄ = 50, σ = 10, 95% confidence

**1.** z-critical value: _______

**2.** Standard Error: _______

**3.** Margin of Error: _______

**4.** 95% CI: [_______, _______]

**5.** Interpretation: ___________________________________________

### Part B: CI for Mean (σ Unknown)

Data: n = 25, x̄ = 50, s = 10, 95% confidence

**1.** t-critical value (df=24): _______

**2.** Standard Error: _______

**3.** Margin of Error: _______

**4.** 95% CI: [_______, _______]

**5.** Compare to Part A: Which is wider? Why? _______

### Part C: CI for Proportion

Data: 45 successes out of 100, 95% confidence

**1.** Sample proportion: _______

**2.** Standard Error: _______

**3.** z-critical: _______

**4.** Margin of Error: _______

**5.** 95% CI: [_______, _______]

---

## EXERCISE 1.6: SAMPLE SIZE DETERMINATION

### Part A: Sample Size for Mean

You want to estimate the mean with:
- 95% confidence
- MOE = 2
- Estimated σ = 10

**1.** z-critical: _______

**2.** Required n: _______

**3.** If MOE increases to 3, how does n change? _______

### Part B: Sample Size for Proportion

You want to estimate a proportion with:
- 95% confidence
- MOE = 0.03
- p = 0.5 (conservative)

**1.** z-critical: _______

**2.** Required n: _______

**3.** If p = 0.3 instead, how does n change? _______

### Part C: Trade-offs

**1.** How does increasing confidence level affect sample size? _______

**2.** How does decreasing MOE affect sample size? _______

**3.** What happens if you use p=0.5 vs p=0.1? _______

---

## EXERCISE 1.7: CENTRAL LIMIT THEOREM

### Part A: Concept Questions

**1.** What does the CLT say about sample means? _______

**2.** What sample size is generally sufficient for CLT? _______

**3.** Does the CLT work for all distributions? Explain. _______

### Part B: Calculations

Population: μ = 50, σ = 20

**1.** If n = 30, what is the distribution of sample means? _______

**2.** Mean of sample means: _______

**3.** Standard error: _______

**4.** 95% CI for sample mean: _______

### Part C: Interpretation

You take a sample of 100 from a skewed population and get mean = 45. The population mean is 50.

**1.** Is this surprising? Why or why not? _______

**2.** Calculate the standard error if σ = 15: _______

**3.** What is the probability of getting mean < 45? _______

---

## EXERCISE 1.8: BOOTSTRAP RESAMPLING

### Part A: Concept

**1.** What is bootstrap resampling? _______

**2.** Why is it useful? _______

**3.** How is it different from the CLT? _______

### Part B: Bootstrap Steps

Given data: [2, 4, 6, 8, 10]

**1.** Draw 3 bootstrap samples (n=5) with replacement:

Sample 1: _______
Sample 2: _______
Sample 3: _______

**2.** Calculate the mean of each sample:
Mean 1: _______
Mean 2: _______
Mean 3: _______

**3.** What is the bootstrap distribution? _______

### Part C: Bootstrap CI

Bootstrap means: [5.2, 5.8, 6.0, 6.2, 6.8, 7.0, 7.2, 7.8, 8.0, 8.2]

**1.** 2.5th percentile: _______
**2.** 97.5th percentile: _______
**3.** 95% Bootstrap CI: [_______, _______]

---

## EXERCISE 1.9: DISTRIBUTION VISUALIZATION

### Part A: Interpret Plots

You see a Q-Q plot where points bend downward at both ends.

**1.** What does this suggest about normality? _______

**2.** What should you do? _______

### Part B: Create a Hypothesis

For a dataset with:
- Mean = 100, Median = 95
- Skewness = 0.8, Kurtosis = 1.5

**1.** Is the distribution symmetric? _______

**2.** Which direction is it skewed? _______

**3.** Is kurtosis normal? _______

### Part C: Practical Check

You have data: [1, 2, 3, 4, 5, 6, 100]

**1.** Does this look normal? _______

**2.** What's the mean? _______

**3.** What's the median? _______

**4.** Which is more appropriate to use? _______

---

## EXERCISE 1.10: UNCERTAINTY QUANTIFICATION

### Part A: Standard Error

Data: [10, 12, 14, 16, 18, 20, 22, 24, 26, 28]

**1.** n: _______

**2.** Mean: _______

**3.** Standard deviation (sample): _______

**4.** Standard Error: _______

**5.** 95% CI (use t, df=9): _______

### Part B: Margin of Error

**1.** Calculate MOE for Part A: _______

**2.** If n doubles, how does MOE change? _______

**3.** What does MOE represent? _______

### Part C: Reporting

You report: "We are 95% confident the true mean is between 45 and 55."

**1.** What does "95% confident" mean? _______

**2.** What is the point estimate? _______

**3.** What is the MOE? _______

---

## EXERCISE 1.11: CODING EXERCISES

### Exercise: Generate Distributions

```python
# Write code to:
# 1. Generate 1000 samples from Normal(0,1)
# 2. Generate 1000 samples from Binomial(10, 0.3)
# 3. Generate 1000 samples from Poisson(5)
# 4. Calculate mean, std for each

# YOUR CODE HERE:

```

### Exercise: Calculate Descriptive Statistics

```python
# Write code to:
# 1. Create a dataset
# 2. Calculate mean, median, mode, variance, std
# 3. Calculate quartiles and IQR
# 4. Detect outliers using IQR method

# YOUR CODE HERE:

```

### Exercise: Confidence Intervals

```python
# Write code to:
# 1. Generate sample from Normal(100, 15, 50)
# 2. Calculate 95% CI for the mean
# 3. Calculate 99% CI for the mean
# 4. Interpret the results

# YOUR CODE HERE:

```

---

## EXERCISE 1.12: REFLECTION QUESTIONS

**1.** Why is the Normal distribution so important in statistics?

___________________________________________

**2.** When would you use the median instead of the mean?

___________________________________________

**3.** What's the difference between standard deviation and standard error?

___________________________________________

**4.** Why do we use sample statistics to estimate population parameters?

___________________________________________

**5.** Explain the Central Limit Theorem in your own words.

___________________________________________

**6.** When is bootstrap resampling preferred over parametric methods?

___________________________________________

**7.** What does a 95% confidence interval actually mean?

___________________________________________

---

# SECTION 2: MODULE 3.2 — HYPOTHESIS TESTING

## LEARNING OBJECTIVES

By completing this section, you will be able to:
- Formulate null and alternative hypotheses
- Calculate and interpret p-values
- Perform t-tests and ANOVA
- Apply non-parametric alternatives
- Use multiple testing corrections

---

## EXERCISE 2.1: HYPOTHESIS FORMULATION

### Part A: State the Hypotheses

For each scenario, write H₀ and H₁.

**1.** Testing if a new drug lowers blood pressure.
- H₀: ___________
- H₁: ___________

**2.** Testing if a new website design increases conversion rate.
- H₀: ___________
- H₁: ___________

**3.** Testing if the average height of students is different from 170cm.
- H₀: ___________
- H₁: ___________

**4.** Testing if there's an association between gender and product preference.
- H₀: ___________
- H₁: ___________

### Part B: One-Tailed vs Two-Tailed

**1.** "The new drug reduces blood pressure." Which tail? ________

**2.** "The new design changes conversion rate." Which tail? ________

**3.** "Male students are taller than female students." Which tail? ________

**4.** "The mean is equal to 50." Which tail? ________

### Part C: Identify Errors

You conduct a drug trial and find a significant effect (p < 0.05).

**1.** What conclusion do you draw? ___________

**2.** If the drug actually doesn't work, what error did you make? ___________

**3.** What is the probability of this error? ___________

**4.** If the drug works but you didn't detect it, what error? ___________

**5.** What is the probability of this error? ___________

---

## EXERCISE 2.2: P-VALUE INTERPRETATION

### Part A: Interpret P-Values

For each p-value, state:
- Is it significant at α=0.05?
- What is the strength of evidence?

**1.** p = 0.001
- Significant? _____
- Evidence: ___________

**2.** p = 0.045
- Significant? _____
- Evidence: ___________

**3.** p = 0.07
- Significant? _____
- Evidence: ___________

**4.** p = 0.50
- Significant? _____
- Evidence: ___________

### Part B: Decision Making

**1.** p = 0.03, α = 0.05
- Decision: ___________

**2.** p = 0.06, α = 0.05
- Decision: ___________

**3.** p = 0.001, α = 0.01
- Decision: ___________

**4.** p = 0.02, α = 0.01
- Decision: ___________

### Part C: Misinterpretations

Correct the following misinterpretations:

**1.** "p = 0.03 means there's a 3% chance the null is true."
Correct: ___________

**2.** "p = 0.08 means there's no effect."
Correct: ___________

**3.** "p < 0.05 means the effect is large."
Correct: ___________

---

## EXERCISE 2.3: T-TESTS

### Part A: One-Sample t-Test

Data: [72, 68, 70, 71, 69, 73, 72, 68, 70, 71]
H₀: μ = 70, α = 0.05

**1.** n: _______

**2.** Mean: _______

**3.** Standard deviation: _______

**4.** t-statistic: _______

**5.** df: _______

**6.** Critical t (two-tailed): _______

**7.** Decision: ___________

**8.** Interpretation: ___________

### Part B: Two-Sample t-Test (Independent)

Group A: [10, 12, 11, 9, 13, 10, 11]
Group B: [14, 15, 13, 16, 12, 14, 15]
α = 0.05

**1.** Mean A: _______, Mean B: _______

**2.** Difference: _______

**3.** Pooled SD: _______

**4.** t-statistic: _______

**5.** df: _______

**6.** p-value (approx): _______

**7.** Decision: ___________

**8.** Interpretation: ___________

### Part C: Paired t-Test

Before: [72, 68, 70, 71, 69, 73]
After: [78, 75, 76, 77, 74, 79]
α = 0.05

**1.** Differences: _______

**2.** Mean difference: _______

**3.** SD of differences: _______

**4.** t-statistic: _______

**5.** df: _______

**6.** Decision: ___________

**7.** Interpretation: ___________

---

## EXERCISE 2.4: ANOVA

### Part A: Calculate ANOVA

Group A: [10, 12, 11, 9, 13]
Group B: [14, 15, 13, 16, 12]
Group C: [18, 17, 19, 16, 20]
α = 0.05

**1.** Grand mean: _______

**2.** Between-groups SS: _______

**3.** Within-groups SS: _______

**4.** MS_between: _______

**5.** MS_within: _______

**6.** F-statistic: _______

**7.** Critical F (df=2,12): _______

**8.** Decision: ___________

**9.** Interpretation: ___________

### Part B: Post-Hoc

If ANOVA is significant, which groups differ?

**1.** A vs B: _______
**2.** A vs C: _______
**3.** B vs C: _______

### Part C: Interpret Output

ANOVA Results:
- F(2, 27) = 4.56, p = 0.02

**1.** How many groups? _______

**2.** Total sample size? _______

**3.** Is it significant? _______

**4.** What's the conclusion? _______

---

## EXERCISE 2.5: NON-PARAMETRIC TESTS

### Part A: When to Use

For each scenario, choose parametric or non-parametric:

**1.** Normal data, no outliers → _______

**2.** Skewed data, large outliers → _______

**3.** Ordinal data (rankings) → _______

**4.** Small sample (n=10) → _______

**5.** Large sample (n=100) → _______

### Part B: Mann-Whitney U

Group A: [5, 7, 6, 8, 7]
Group B: [9, 10, 8, 11, 10]

**1.** Rank all data combined:

| Value | Rank |
|-------|------|
| ___   | ___  |
| ___   | ___  |
| ...   | ...  |

**2.** Sum of ranks for Group A: _______

**3.** Sum of ranks for Group B: _______

**4.** U-statistic: _______

**5.** Decision: ___________

### Part C: Chi-Square

|       | Success | Failure | Total |
|-------|---------|---------|-------|
| Group A | 45      | 55      | 100   |
| Group B | 60      | 40      | 100   |
| Total  | 105     | 95      | 200   |

**1.** Expected frequencies:

|       | Success | Failure |
|-------|---------|---------|
| Group A | ___     | ___     |
| Group B | ___     | ___     |

**2.** χ² statistic: _______

**3.** df: _______

**4.** Critical χ² (α=0.05): _______

**5.** Decision: ___________

**6.** Interpretation: ___________

---

## EXERCISE 2.6: EFFECT SIZE

### Part A: Calculate Cohen's d

Group A: mean=50, sd=10, n=30
Group B: mean=55, sd=10, n=30

**1.** Difference in means: _______

**2.** Pooled SD: _______

**3.** Cohen's d: _______

**4.** Interpretation: ___________

### Part B: Interpret Effect Sizes

**1.** d = 0.8 → ___________

**2.** d = 0.3 → ___________

**3.** d = 0.1 → ___________

**4.** r = 0.7 → ___________

**5.** Cramer's V = 0.4 → ___________

### Part C: Practical Significance

**1.** p < 0.001, d = 0.05. Is this practically significant? Why? _______

**2.** p = 0.06, d = 0.8. Is this practically significant? Why? _______

**3.** If you had more data, what would change about these results? _______

---

## EXERCISE 2.7: POWER ANALYSIS

### Part A: Calculate Power

Given: d = 0.5, n = 30 per group, α = 0.05

**1.** What is the power? (Use table/calculator) _______

**2.** Is this sufficient? _______

**3.** What should you do if power is too low? _______

### Part B: Sample Size for Power

Given: d = 0.5, power = 0.80, α = 0.05

**1.** Required n per group: _______

**2.** If d = 0.3, required n: _______

**3.** If d = 0.8, required n: _______

### Part C: Trade-offs

**1.** How does larger effect size affect power? _______

**2.** How does larger sample size affect power? _______

**3.** How does lower α affect power? _______

**4.** What's the relationship between power and Type II error? _______

---

## EXERCISE 2.8: MULTIPLE TESTING CORRECTIONS

### Part A: Bonferroni Correction

You perform 20 tests at α = 0.05.

**1.** Bonferroni α: _______

**2.** Tests significant at α=0.05: 3. Which survive correction? _______

**3.** Advantage of Bonferroni: _______

**4.** Disadvantage of Bonferroni: _______

### Part B: Benjamini-Hochberg

P-values: [0.001, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09]
α = 0.05

**1.** Number of tests: _______

**2.** Sort p-values: _______

**3.** BH thresholds: _______

**4.** Significant tests: _______

**5.** Why choose BH over Bonferroni? _______

### Part C: Compare Methods

| Method | Controls | Conservatism | Best for |
|--------|----------|--------------|----------|
| Bonferroni | _____ | _____ | _____ |
| Holm | _____ | _____ | _____ |
| BH | _____ | _____ | _____ |

---

## EXERCISE 2.9: EXPERIMENTAL DESIGN

### Part A: Design an A/B Test

You're testing a new email subject line.

**1.** What's the primary metric? _______

**2.** What's the null hypothesis? _______

**3.** What's the alternative? _______

**4.** How many users do you need? (estimate) _______

**5.** How long should the test run? _______

**6.** What are potential confounders? _______

### Part B: Power Analysis for A/B Test

Baseline conversion = 10%, expected improvement = 2%, power = 0.80, α = 0.05

**1.** Required sample size: _______

**2.** Total users needed: _______

**3.** Test duration (1000 users/day): _______

### Part C: Design Considerations

**1.** Why is randomization important? _______

**2.** What's a guardrail metric? _______

**3.** Why shouldn't you stop the test early? _______

---

## EXERCISE 2.10: CODING EXERCISES

### Exercise: Power Analysis

```python
# Write code to:
# 1. Calculate sample size for two-sample t-test
# 2. Calculate power for proportions test
# 3. Plot power curve

# YOUR CODE HERE:

```

### Exercise: Hypothesis Testing

```python
# Write code to:
# 1. Generate two groups of data
# 2. Perform t-test
# 3. Perform Mann-Whitney U test
# 4. Compare results

# YOUR CODE HERE:

```

### Exercise: Multiple Testing

```python
# Write code to:
# 1. Generate 100 p-values (some significant)
# 2. Apply Bonferroni correction
# 3. Apply BH correction
# 4. Compare results

# YOUR CODE HERE:

```

---

## EXERCISE 2.11: CASE STUDIES

### Case Study 1: Drug Trial

A pharmaceutical company tests a new drug on 100 patients. Results show mean improvement of 5 points (s=3) vs placebo mean of 2 points (s=2).

**1.** What test should you use? _______

**2.** Calculate the test statistic: _______

**3.** Calculate the p-value: _______

**4.** What do you conclude? _______

**5.** What's the effect size? _______

### Case Study 2: Website Redesign

You run an A/B test with 1000 users per group. Control conversion = 10%, Treatment conversion = 11.5%.

**1.** Is this significant? _______

**2.** What's the effect size? _______

**3.** Is it practically significant? _______

**4.** Should you roll out the change? _______

### Case Study 3: Multiple Metrics

You test 10 metrics and find 2 significant at α=0.05.

**1.** How many would you expect by chance? _______

**2.** What correction should you use? _______

**3.** After correction, are they still significant? _______

---

## EXERCISE 2.12: REFLECTION QUESTIONS

**1.** Why do we set α = 0.05 as the standard?

___________________________________________

**2.** What's the difference between significance and importance?

___________________________________________

**3.** When should you use a non-parametric test?

___________________________________________

**4.** Why is power analysis important?

___________________________________________

**5.** What's the problem with multiple testing?

___________________________________________

**6.** How do you decide which test to use?

___________________________________________

**7.** Explain p-value in your own words.

___________________________________________

---

# SECTION 3: MODULE 3.3 — REGRESSION & DIAGNOSTICS

## LEARNING OBJECTIVES

By completing this section, you will be able to:
- Fit and interpret regression models
- Check model assumptions
- Calculate and interpret VIF
- Detect influential points
- Build logistic regression models

---

## EXERCISE 3.1: SIMPLE LINEAR REGRESSION

### Part A: Calculate by Hand

Data: X = [1, 2, 3, 4, 5], Y = [2, 4, 5, 4, 5]

**1.** x̄: _______, ȳ: _______

**2.** Σ(x-x̄)(y-ȳ): _______

**3.** Σ(x-x̄)²: _______

**4.** β₁ = ___________

**5.** β₀ = ___________

**6.** Regression equation: _______

**7.** Predict Y when X = 6: _______

### Part B: Interpret Results

Regression equation: Y = 2.5 + 0.8X

**1.** What is the intercept? _______

**2.** What is the slope? _______

**3.** Interpret the slope: ___________

**4.** Predict Y when X = 10: _______

**5.** If X increases by 5, what happens to Y? _______

### Part C: Residuals

For the equation Y = 2.5 + 0.8X, data points: (1,3), (2,4), (3,5), (4,6)

**1.** Predictions:

| X | Y | Ŷ | Residual |
|---|----|----|----------|
| 1 | 3 | __ | __ |
| 2 | 4 | __ | __ |
| 3 | 5 | __ | __ |
| 4 | 6 | __ | __ |

**2.** SSE: _______

**3.** R²: _______

**4.** What does R² mean? _______

---

## EXERCISE 3.2: MULTIPLE REGRESSION

### Part A: Interpret Coefficients

Model: Price = 50 + 0.15(SqFt) + 20(Bedrooms) - 0.5(Age) + 15(Location)

**1.** Price prediction for 2000 sq ft, 3 bedrooms, 10 years old, location=5:

_______

**2.** Interpret β for SqFt: ___________

**3.** Interpret β for Age: ___________

**4.** Interpret β for Location: ___________

**5.** What happens if Bedrooms increases by 1? _______

### Part B: Holding Constant

**1.** What does "holding other variables constant" mean? _______

**2.** Why is this important? _______

**3.** Compare two houses identical except SqFt (1000 vs 2000):

Difference in price: _______

### Part C: Confounding

You find that houses with more bedrooms also have more square feet.

**1.** Why is this a problem? _______

**2.** How does multiple regression help? _______

**3.** What would happen if you only included Bedrooms? _______

---

## EXERCISE 3.3: R-SQUARED AND ADJUSTED R²

### Part A: Calculate R²

SSE = 100, SST = 400

**1.** R² = _______

**2.** Interpretation: ___________

### Part B: Adjusted R²

Model 1: R² = 0.80, k=2, n=50
Model 2: R² = 0.82, k=5, n=50

**1.** Adjusted R² for Model 1: _______

**2.** Adjusted R² for Model 2: _______

**3.** Which model is better? _______

### Part C: Interpretation

**1.** R² = 0.90 but k=20, n=30. Is this trustworthy? _______

**2.** R² = 0.30 but k=2, n=100. Is this okay? _______

**3.** What's a good R² in your field? _______

---

## EXERCISE 3.4: MODEL DIAGNOSTICS

### Part A: Identify Problems

For each plot pattern, identify the violation:

**1.** Residual vs Fitted shows a U-shape → _______

**2.** Q-Q plot points deviate from line → _______

**3.** Residual vs Fitted fans out → _______

**4.** High correlation between predictors → _______

### Part B: Linearity Check

Data shows that Y increases rapidly for low X, then plateaus.

**1.** Is the relationship linear? _______

**2.** What transformation might help? _______

**3.** How would you check for linearity? _______

### Part C: Normality Check

Shapiro-Wilk test p = 0.02 on residuals.

**1.** Are residuals normal? _______

**2.** What should you do? _______

**3.** When is normality critical? _______

---

## EXERCISE 3.5: MULTICOLLINEARITY

### Part A: VIF Calculation

Predictors: X₁ (VIF=1.2), X₂ (VIF=3.5), X₃ (VIF=12.0)

**1.** Which has multicollinearity? _______

**2.** What should you do with X₃? _______

**3.** What's the threshold for concern? _______

### Part B: Correlation Matrix

|       | X₁ | X₂ | X₃ |
|-------|----|----|----|
| X₁    | 1.0| 0.9| 0.2|
| X₂    | 0.9| 1.0| 0.1|
| X₃    | 0.2| 0.1| 1.0|

**1.** Which variables are correlated? _______

**2.** Which should be removed? _______

**3.** Why? _______

### Part C: Solutions

**1.** Name three ways to address multicollinearity:

a. ________
b. ________
c. ________

**2.** When is multicollinearity acceptable? _______

---

## EXERCISE 3.6: INFLUENTIAL POINTS

### Part A: Cook's Distance

Dataset has 5 observations with Cook's D > 1.

**1.** What does this mean? _______

**2.** What should you do? _______

**3.** When would you remove them? _______

### Part B: Leverage

n=100, k=4, leverage values: 0.01, 0.02, 0.05, 0.12, 0.30

**1.** What's the average leverage? _______

**2.** What's the threshold for high leverage? _______

**3.** Which point has high leverage? _______

### Part C: Combined Influence

**1.** What's the difference between outlier and leverage? _______

**2.** What's Cook's D measuring? _______

**3.** If a point has high leverage but small residual, is it influential? _______

---

## EXERCISE 3.7: HOMOSCEDASTICITY

### Part A: Detect Heteroscedasticity

**1.** What does a fan-shaped residual plot indicate? _______

**2.** What's the Breusch-Pagan test? _______

**3.** If p < 0.05, what do you conclude? _______

### Part B: Solutions

**1.** What transformation can help? _______

**2.** What's weighted least squares? _______

**3.** When would you use robust SE? _______

### Part C: Consequences

**1.** What happens if you ignore heteroscedasticity? _______

**2.** How does it affect p-values? _______

**3.** How does it affect predictions? _______

---

## EXERCISE 3.8: LOGISTIC REGRESSION

### Part A: Interpret Odds Ratios

Logistic regression output:
- Treatment OR = 2.5
- Age OR = 0.95
- Gender (Male) OR = 1.2

**1.** What does OR=2.5 mean? _______

**2.** What does OR=0.95 mean? _______

**3.** Which variable has the largest effect? _______

### Part B: Calculate Probability

Model: logit(p) = -2 + 0.5X

**1.** When X=0, p = _______

**2.** When X=2, p = _______

**3.** When X=4, p = _______

### Part C: Compare Models

**1.** What's the difference between linear and logistic regression? _______

**2.** When do you use logistic regression? _______

**3.** What's the logit function? _______

---

## EXERCISE 3.9: VARIABLE SELECTION### Part A: Forward Selection

Variables: X₁ (p=0.01), X₂ (p=0.08), X₃ (p=0.20)

**1.** Which is added first? _______

**2.** What's the next step? _______

**3.** When do you stop? _______

### Part B: Backward Elimination

Variables: X₁ (p=0.02), X₂ (p=0.04), X₃ (p=0.60)

**1.** Which is removed first? _______

**2.** What's the next step? _______

**3.** When do you stop? _______

### Part C: Stepwise

**1.** How is stepwise different from forward/backward? _______

**2.** What's a disadvantage of stepwise? _______

**3.** What's a better alternative? _______

---

## EXERCISE 3.10: CODING EXERCISES

### Exercise: OLS Regression

```python
# Write code to:
# 1. Generate regression data
# 2. Fit OLS model
# 3. Print summary
# 4. Make predictions

# YOUR CODE HERE:

```

### Exercise: Model Diagnostics

```python
# Write code to:
# 1. Fit regression model
# 2. Check normality (Shapiro-Wilk)
# 3. Check VIF
# 4. Plot residuals

# YOUR CODE HERE:

```

### Exercise: Logistic Regression

```python
# Write code to:
# 1. Generate binary outcome data
# 2. Fit logistic regression
# 3. Interpret coefficients
# 4. Calculate predictions

# YOUR CODE HERE:

```

---

## EXERCISE 3.11: CASE STUDIES

### Case Study 1: House Prices

Model: Price = 100 + 0.2(SqFt) + 30(Bedrooms) - 0.5(Age) + 10(Location)
R² = 0.75, n=100

**1.** What does R²=0.75 mean? _______

**2.** How much does each bedroom add? _______

**3.** What's the price of a 2000 sq ft, 3 BR, 10 yr old, location=8 house? _______

**4.** What's the effect of age? _______

### Case Study 2: Customer Churn

Logistic model: logit(p) = -3 + 0.1(Age) - 0.5(Usage) + 1.2(Complaints)

**1.** What's the effect of complaints? _______

**2.** What's the effect of usage? _______

**3.** What's the probability of churn for Age=30, Usage=5, Complaints=1? _______

### Case Study 3: Model Comparison

Model A: R²=0.80, k=3
Model B: R²=0.82, k=6

**1.** Which is better? Why? _______

**2.** What additional information do you need? _______

---

## EXERCISE 3.12: REFLECTION QUESTIONS

**1.** Why do we need to check regression assumptions?

___________________________________________

**2.** What's the most important regression assumption?

___________________________________________

**3.** When would you use logistic regression instead of linear?

___________________________________________

**4.** What's the problem with multicollinearity?

___________________________________________

**5.** How do you know if a model is good?

___________________________________________

**6.** What's the difference between R² and Adjusted R²?

___________________________________________

**7.** Why are diagnostics important?

___________________________________________

---

# SECTION 4: CAPSTONE PROJECT WORKBOOK

## PROJECT OVERVIEW

You will complete an end-to-end A/B test analysis including:
- Experiment design
- Data generation
- Hypothesis testing
- Regression modeling
- Model diagnostics
- Dashboard creation

---

## EXERCISE C.1: EXPERIMENT DESIGN

### Part A: Define the Experiment

You're testing a new checkout flow.

**1.** What's the business goal? _______

**2.** What's the primary metric? _______

**3.** What's the null hypothesis? _______

**4.** What's the alternative? _______

**5.** What's the expected effect size? _______

**6.** How many users do you need? _______

**7.** How long will the test run? _______

### Part B: Sample Size Calculation

Baseline conversion = 12%, expected improvement = 2%, power = 0.80, α = 0.05

**1.** Required n per group: _______

**2.** Total users: _______

**3.** If daily traffic = 500, how many days? _______

### Part C: Test Plan

**1.** How will you randomize? _______

**2.** What are your guardrail metrics? _______

**3.** What segments will you analyze? _______

**4.** How will you handle weekends? _______

---

## EXERCISE C.2: DATA GENERATION

### Part A: Design Data Structure

**1.** What columns will your dataset have? _______

**2.** What's the data type of each? _______

**3.** How many rows? _______

**4.** What's the ground truth? _______

### Part B: Generate Data

```python
# Write code to:
# 1. Generate user IDs
# 2. Assign groups
# 3. Generate conversion outcomes
# 4. Add demographics
# 5. Add timestamps

# YOUR CODE HERE:

```

### Part C: Validate Data

**1.** Check group balance: _______

**2.** Check conversion rates: _______

**3.** Check demographics: _______

**4.** Check for missing values: _______

---

## EXERCISE C.3: HYPOTHESIS TESTING

### Part A: Descriptive Statistics

**1.** Calculate conversion rate by group: _______

**2.** Calculate revenue by group: _______

**3.** Calculate engagement by group: _______

**4.** Visualize distributions: _______

### Part B: Hypothesis Tests

**1.** What test for conversion rate? _______

**2.** What's the p-value? _______

**3.** Is it significant? _______

**4.** What's the effect size? _______

**5.** What test for revenue? _______

**6.** What's the p-value? _______

### Part C: Multiple Testing

You test 3 metrics: conversion, revenue, engagement.

**1.** Should you correct for multiple testing? _______

**2.** What correction would you use? _______

**3.** Are results still significant after correction? _______

---

## EXERCISE C.4: REGRESSION MODELING

### Part A: Build the Model

**1.** What are your predictors? _______

**2.** What's your outcome? _______

**3.** Fit the model: _______

**4.** What's R²? _______

**5.** What's the coefficient for treatment? _______

**6.** What's the p-value for treatment? _______

### Part B: Interpret Results

**1.** What's the effect of treatment holding others constant? _______

**2.** What other variables are significant? _______

**3.** What's the direction of each effect? _______

**4.** What does this tell you? _______

### Part C: Logistic vs Linear

**1.** Which model is appropriate? _______

**2.** Why? _______

**3.** Compare results: _______

---

## EXERCISE C.5: MODEL DIAGNOSTICS

### Part A: Check Assumptions

**1.** Check linearity: _______

**2.** Check normality: _______

**3.** Check homoscedasticity: _______

**4.** Check VIF: _______

### Part B: Influential Points

**1.** Check Cook's D: _______

**2.** Identify influential points: _______

**3.** Investigate outliers: _______

**4.** Should you remove any? _______

### Part C: Report Diagnostics

**1.** What issues did you find? _______

**2.** How severe are they? _______

**3.** How would you fix them? _______

**4.** Are the results still valid? _______

---

## EXERCISE C.6: FINAL REPORT

### Part A: Executive Summary

**1.** What did you test? _______

**2.** What were the results? _______

**3.** Are they significant? _______

**4.** What's the effect size? _______

**5.** What's your recommendation? _______

### Part B: Detailed Findings

**1.** Describe the experiment: _______

**2.** Present results: _______

**3.** Show confidence intervals: _______

**4.** Discuss model results: _______

**5.** Mention limitations: _______

### Part C: Recommendations

**1.** What's your recommendation? _______

**2.** What are the risks? _______

**3.** What should be monitored? _______

**4.** What's the next experiment? _______

---

# SECTION 5: SELF-ASSESSMENT QUIZ

## 30 QUESTIONS — TEST YOUR KNOWLEDGE

### Questions 1-10: Multiple Choice

**1.** The 68-95-99.7 rule applies to which distribution?
- A. Binomial
- B. Poisson
- C. Normal
- D. Exponential

**2.** What does the p-value measure?
- A. Probability H₀ is true
- B. Probability of data if H₀ is true
- C. Probability H₁ is true
- D. Effect size

**3.** What is the standard target for statistical power?
- A. 0.50
- B. 0.80
- C. 0.95
- D. 0.99

**4.** Which is NOT a type of error?
- A. Type I
- B. Type II
- C. Type III
- D. Alpha

**5.** What does VIF measure?
- A. Normality
- B. Homoscedasticity
- C. Multicollinearity
- D. Independence

**6.** Which test is non-parametric?
- A. t-test
- B. ANOVA
- C. Mann-Whitney U
- D. F-test

**7.** What does R² measure?
- A. Correlation
- B. Explained variance
- C. P-value
- D. Sample size

**8.** What is the median of [1, 2, 3, 4, 100]?
- A. 3
- B. 22
- C. 4
- D. 2.5

**9.** Which distribution has the memoryless property?
- A. Normal
- B. Exponential
- C. Binomial
- D. Poisson

**10.** What does Cook's D measure?
- A. Outliers
- B. Influence
- C. Leverage
- D. Normality

### Questions 11-20: True/False

**11.** Correlation implies causation. T/F

**12.** The median is robust to outliers. T/F

**13.** Type I error is controlled by α. T/F

**14.** Non-parametric tests assume normality. T/F

**15.** Bonferroni is more conservative than BH. T/F

**16.** The CLT applies to all distributions. T/F

**17.** Logistic regression is for continuous outcomes. T/F

**18.** R² always increases with more variables. T/F

**19.** Standard error decreases with larger n. T/F

**20.** The mode is always unique. T/F

### Questions 21-30: Short Answer

**21.** What's the difference between standard deviation and standard error?

**22.** When would you use a one-tailed test?

**23.** What's the Central Limit Theorem?

**24.** What are the four LINE assumptions?

**25.** What's the difference between FWER and FDR?

**26.** When should you use a non-parametric test?

**27.** What's the interpretation of VIF > 10?

**28.** What's the difference between interpolation and extrapolation?

**29.** What's the purpose of model diagnostics?

**30.** How do you choose between linear and logistic regression?

---

## ANSWER KEY

### Multiple Choice
1. C
2. B
3. B
4. C
5. C
6. C
7. B
8. A
9. B
10. B

### True/False
11. False
12. True
13. True
14. False
15. True
16. True
17. False
18. True
19. True
20. False

### Short Answer (Model Answers)

**21.** Standard deviation measures spread of data; standard error measures precision of sample statistic.

**22.** When you have a specific directional hypothesis (e.g., treatment increases conversion).

**23.** Sample means approach normality as sample size increases, regardless of population distribution.

**24.** Linearity, Independence, Normality (of residuals), Equal variance.

**25.** FWER controls probability of any false positive; FDR controls expected proportion of false positives.

**26.** When data is not normal, ordinal, or has outliers.

**27.** Severe multicollinearity - consider removing variables.

**28.** Interpolation = predicting within data range; Extrapolation = predicting outside data range.

**29.** To verify assumptions and ensure model is valid.

**30.** Linear for continuous outcome; Logistic for binary outcome.

---

## SCORING GUIDE

| Score | Rating |
|-------|--------|
| 25-30 | Excellent |
| 20-24 | Good |
| 15-19 | Satisfactory |
| <15 | Needs Review |

---

## STUDENT FEEDBACK FORM

**Name:** ______________________

**Date:** ______________________

**Which section was most helpful?** ______________________

**Which section was most challenging?** ______________________

**What would you change?** ______________________

**Additional comments:** ______________________

---

**[END OF STUDENT WORKBOOK]**

**[TOTAL EXERCISES: 42]**
**[TOTAL QUESTIONS: 100+]**

---

## Teacher's Notes

### Suggested Use

1. **Module sections:** Complete after each lecture/lesson
2. **Coding exercises:** For lab sessions
3. **Case studies:** For group work
4. **Self-assessment quiz:** For exam preparation

### Answer Keys

Create separate answer key file for instructors.

### Additional Resources

- Companion PowerPoint (200+ slides)
- Code solutions repository
- Data files for exercises
