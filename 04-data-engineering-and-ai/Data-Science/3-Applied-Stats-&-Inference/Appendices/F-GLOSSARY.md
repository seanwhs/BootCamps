# APPENDIX F: GLOSSARY OF STATISTICAL TERMS

## F.1 A

**A/B Testing**
A controlled experiment where two versions (A and B) are compared to determine which performs better. Users are randomly assigned to one of two groups, and their outcomes are measured.

**Adjusted R-squared**
A modified version of R-squared that accounts for the number of predictors in a model. It penalizes adding unnecessary variables, helping prevent overfitting.

**AIC (Akaike Information Criterion)**
A measure of model quality that balances goodness-of-fit with model complexity. Lower AIC values indicate better models.

**Alternative Hypothesis (H₁)**
The hypothesis that there is an effect or difference. It's what you're trying to prove with your test (e.g., "the treatment increases conversion").

**ANOVA (Analysis of Variance)**
A statistical test used to compare means across three or more groups. It determines whether at least one group mean is significantly different from the others.

---

## F.2 B

**BIC (Bayesian Information Criterion)**
Similar to AIC but with a stronger penalty for complexity. Lower BIC values indicate better models, and it's often used for model selection.

**Binomial Distribution**
A discrete probability distribution that models the number of successes in a fixed number of independent trials (e.g., number of heads in 10 coin flips).

**Bonferroni Correction**
A method for controlling the family-wise error rate when performing multiple hypothesis tests. It adjusts the significance level by dividing α by the number of tests.

**Bootstrap**
A resampling method that involves repeatedly drawing samples (with replacement) from the original data to estimate the sampling distribution of a statistic.

**Box-Cox Transformation**
A family of power transformations that can make data more normally distributed. The optimal λ is found by maximizing the likelihood.

**Breusch-Pagan Test**
A statistical test for heteroscedasticity (non-constant variance) in regression residuals. A significant result suggests the variance is not constant.

---

## F.3 C

**Central Limit Theorem (CLT)**
The fundamental theorem stating that the distribution of sample means approaches a normal distribution as sample size increases, regardless of the population distribution (provided it has finite variance).

**Chi-Square Test**
A statistical test used for categorical data. Two common types:
- **Test of Independence**: Determines if two categorical variables are associated
- **Goodness-of-Fit Test**: Determines if observed frequencies match expected frequencies

**Coefficient**
In regression, a number that quantifies the relationship between a predictor variable and the response variable. It represents the change in Y for a one-unit change in X.

**Cohen's d**
A measure of effect size for t-tests. It's the difference between two means divided by the pooled standard deviation.

**Confidence Interval (CI)**
A range of values that is likely to contain the true population parameter with a certain level of confidence (e.g., 95% CI). It quantifies uncertainty in estimates.

**Confounding Variable**
A variable that influences both the independent and dependent variables, potentially creating a spurious association.

**Cook's Distance**
A measure of the influence of each observation in regression. Large values (>1) indicate observations that strongly influence the model.

**Correlation**
A measure of the strength and direction of the linear relationship between two variables. Ranges from -1 (perfect negative) to +1 (perfect positive), with 0 indicating no linear relationship.

**Cramer's V**
A measure of effect size for chi-square tests. It ranges from 0 to 1, with larger values indicating stronger associations.

**Cross-Validation**
A technique for assessing model performance by splitting data into training and validation sets multiple times. Common types include k-fold cross-validation.

---

## F.4 D

**Degrees of Freedom (df)**
The number of independent pieces of information available to estimate a parameter. In t-tests, df = n-1; in regression, df = n-k-1.

**Descriptive Statistics**
Statistics that summarize and describe the main features of a dataset (e.g., mean, median, standard deviation).

**Deviance**
A measure of model fit, especially in logistic regression. It's analogous to the sum of squared errors in linear regression.

**DFFITS**
A measure of the influence of each observation on the fitted values in regression. Large absolute values indicate influential points.

**Durbin-Watson Test**
A test for autocorrelation in regression residuals. Values near 2 indicate no autocorrelation.

---

## F.5 E

**Effect Size**
A quantitative measure of the magnitude of an effect or difference. It tells you how practically significant a result is, regardless of sample size.

**Error Term (ε)**
In regression, the random variation that is not explained by the model. It represents the "noise" in the data.

**Eta-squared (η²)**
A measure of effect size for ANOVA. It represents the proportion of variance in the dependent variable that is explained by the independent variable.

**Exponential Distribution**
A continuous probability distribution that models the time between events in a Poisson process. It has the memoryless property.

**Exposure**
In experimental design, the duration or amount of treatment a subject receives.

---

## F.6 F

**F-statistic**
The test statistic used in ANOVA and regression F-tests. It compares the variance explained by the model to the unexplained variance.

**Family-Wise Error Rate (FWER)**
The probability of making at least one Type I error when performing multiple hypothesis tests. Controlled by methods like Bonferroni.

**Fisher's Exact Test**
A test for independence in 2x2 contingency tables, especially useful when sample sizes are small and expected frequencies are less than 5.

**False Discovery Rate (FDR)**
The expected proportion of false positives among all rejected hypotheses. Controlled by methods like Benjamini-Hochberg.

**Forward Selection**
A variable selection method that starts with no predictors and adds them one by one based on statistical significance.

---

## F.7 G

**Goodness-of-Fit**
A measure of how well a statistical model fits the observed data. Often assessed using R², AIC, or deviance.

**Group**
In experimental design, a set of subjects that receive the same treatment. Control and treatment groups are the most common.

---

## F.8 H

**Heteroscedasticity**
The condition where the variance of the errors is not constant across all levels of the independent variables. It violates the homoscedasticity assumption.

**Holm-Bonferroni Correction**
A step-down procedure for controlling the family-wise error rate that is less conservative than Bonferroni while still controlling FWER.

**Homoscedasticity**
The assumption that the variance of the errors is constant across all levels of the independent variables. Required for valid OLS regression.

**Hosmer-Lemeshow Test**
A goodness-of-fit test for logistic regression. A non-significant result indicates good fit.

**Hypothesis**
A statement or claim about a population parameter that can be tested statistically. Usually expressed as a null and alternative hypothesis.

---

## F.9 I

**Independence**
The assumption that observations are independent of each other. Violated when there is clustering or time series correlation.

**Inference**
The process of drawing conclusions about a population based on a sample. Includes estimation and hypothesis testing.

**Influential Point**
An observation that has a large effect on the regression model. Often identified by high Cook's distance or DFFITS.

**Intercept (β₀)**
In regression, the expected value of Y when all predictor variables are zero. It's the point where the regression line crosses the Y-axis.

**Interquartile Range (IQR)**
The range between the 25th and 75th percentiles. A robust measure of spread that is not affected by outliers.

---

## F.10 K

**Kruskal-Wallis Test**
The non-parametric alternative to one-way ANOVA. Used to compare three or more independent groups when the normality assumption is violated.

**Kurtosis**
A measure of the "tailedness" of a distribution. Higher kurtosis indicates heavier tails (more outliers). Excess kurtosis is measured relative to the normal distribution (which has kurtosis = 0).

---

## F.11 L

**Lasso Regression**
A regression method that uses L₁ regularization to perform variable selection. It shrinks some coefficients to zero.

**Leverage**
A measure of how far an observation's predictor values are from the mean. High leverage points can strongly influence the regression.

**Likelihood**
The probability of observing the data given the model parameters. Used in maximum likelihood estimation.

**Linearity**
The assumption that the relationship between the predictor variables and the response variable is linear.

**Logistic Regression**
A regression model used for binary outcomes (0/1). It models the probability of the outcome using the logit function.

**Log Transformation**
Applying the natural logarithm to data to reduce skewness and make the data more normally distributed.

---

## F.12 M

**Mann-Whitney U Test**
The non-parametric alternative to the two-sample t-test. Used when the normality assumption is violated or for ordinal data.

**Margin of Error**
Half the width of a confidence interval. It represents the maximum expected difference between the sample estimate and the population parameter.

**Mean**
The arithmetic average of a set of values. Calculated by summing all values and dividing by the number of values.

**Median**
The middle value of a sorted dataset. It's robust to outliers and used when data is skewed.

**MLE (Maximum Likelihood Estimation)**
A method for estimating the parameters of a statistical model by maximizing the likelihood function.

**Mode**
The most frequently occurring value in a dataset. Used for categorical data.

**Multicollinearity**
The condition where predictor variables are highly correlated with each other. Causes unstable coefficient estimates.

**Multiple Testing Correction**
Methods for adjusting p-values when multiple hypothesis tests are performed to control the false positive rate.

---

## F.13 N

**Non-Parametric Tests**
Statistical tests that do not assume a specific distribution for the data. They are more robust and work with ordinal or non-normal data.

**Normal Distribution**
A continuous probability distribution characterized by a bell-shaped curve. The most important distribution in statistics, described by its mean and standard deviation.

**Null Hypothesis (H₀)**
The hypothesis that there is no effect or difference. It's the default assumption that you're trying to disprove.

---

## F.14 O

**Odds Ratio**
In logistic regression, the ratio of the odds of the outcome in one group to the odds in another group. OR > 1 indicates higher odds.

**OLS (Ordinary Least Squares)**
The standard method for estimating the coefficients in a linear regression model by minimizing the sum of squared residuals.

**Outlier**
An observation that differs significantly from other observations. Outliers can have a large influence on statistical results.

**Overfitting**
When a model fits the training data too closely, capturing noise rather than the underlying pattern. Results in poor performance on new data.

---

## F.15 P

**p-value**
The probability of observing results as extreme as those observed, assuming the null hypothesis is true. A small p-value (< α) suggests evidence against H₀.

**Paired t-Test**
A t-test used for comparing two related groups (e.g., before/after). It tests whether the mean difference is zero.

**Parametric Tests**
Statistical tests that assume a specific distribution for the data (usually normal). They are more powerful when assumptions are met.

**Pearson Correlation**
A measure of the linear correlation between two continuous variables. Ranges from -1 to +1.

**Poisson Distribution**
A discrete probability distribution that models the number of events occurring in a fixed interval of time or space.

**Population**
The entire set of individuals or items of interest in a study. The goal of inferential statistics is to make conclusions about the population from a sample.

**Post-Hoc Test**
A test performed after a significant ANOVA to determine which specific groups differ from each other. Example: Tukey's HSD.

**Power**
The probability of correctly rejecting the null hypothesis when it is false (1 - β). Typically set at 0.80.

**Power Analysis**
The process of determining the sample size needed to detect an effect of a given size with a given power.

**Proportion**
The fraction of observations in a category. For binary data, it's the probability of a "success."

---

## F.16 Q

**Q-Q Plot (Quantile-Quantile Plot)**
A graphical tool for assessing normality. It plots the quantiles of the data against the quantiles of a theoretical distribution.

**Quantile**
A value that divides a dataset into equal-sized groups. The median is the 50th percentile (quantile = 0.5).

---

## F.17 R

**R-squared (R²)**
The proportion of variance in the dependent variable that is explained by the independent variables. Ranges from 0 to 1.

**Regression**
A statistical method for modeling the relationship between a dependent variable and one or more independent variables.

**Regularization**
A technique for preventing overfitting by adding a penalty term to the loss function. Examples include Ridge and Lasso.

**Residual**
The difference between the observed value and the predicted value from a model. Residual = Y - Ŷ.

**Ridge Regression**
A regression method that uses L₂ regularization to shrink coefficients. It reduces overfitting but keeps all variables.

**Robust Standard Errors**
Standard errors that are valid even when assumptions like homoscedasticity are violated. Also called Huber-White standard errors.

---

## F.18 S

**Sample**
A subset of the population that is actually observed. Used to make inferences about the population.

**Sample Size**
The number of observations in a sample. Larger samples provide more precise estimates.

**Sampling Distribution**
The distribution of a statistic (e.g., mean) across repeated samples from the same population.

**Shapiro-Wilk Test**
A statistical test for normality. A small p-value indicates the data is not normally distributed.

**Skewness**
A measure of the asymmetry of a distribution. Positive skew = right tail is longer; negative skew = left tail is longer.

**Spearman Correlation**
A non-parametric measure of correlation based on ranks. Used when the relationship is monotonic but not linear.

**Standard Deviation (SD)**
The square root of the variance. Measures the spread of data around the mean.

**Standard Error (SE)**
The standard deviation of a sampling distribution. Measures the precision of an estimate.

**Standardized Residual**
A residual divided by its standard error. Used to identify outliers.

**Statistically Significant**
A result where the p-value is less than the significance level (α), leading to rejection of the null hypothesis.

**Stepwise Selection**
A variable selection method that combines forward selection and backward elimination.

**Studentized Residual**
A residual divided by its estimated standard error with that observation removed. Used to identify outliers.

---

## F.19 T

**t-Distribution**
A distribution used for small sample inference. It is similar to the normal but has heavier tails. Approaches the normal as df increases.

**t-Test**
A family of tests for comparing means. Types include one-sample, two-sample (independent), and paired.

**Test Statistic**
A numerical value calculated from the data that is compared to a theoretical distribution to determine statistical significance.

**Transformations**
Mathematical functions applied to data to make it more suitable for analysis (e.g., log, square root, Box-Cox).

**Treatment**
The intervention or change being tested in an experiment.

**Tukey's HSD**
A post-hoc test for ANOVA that identifies which specific group means are significantly different.

**Type I Error (α)**
False positive — rejecting the null hypothesis when it is actually true. Controlled by the significance level.

**Type II Error (β)**
False negative — failing to reject the null hypothesis when it is actually false. Related to statistical power (1-β).

---

## F.20 U

**Uniform Distribution**
A distribution where all values in the range are equally likely. The simplest continuous distribution.

**Unbiased Estimator**
An estimator whose expected value equals the true population parameter. Sample mean is an unbiased estimator of population mean.

---

## F.21 V

**Variance**
The average squared deviation from the mean. Measures the spread of data. Square root gives standard deviation.

**Variance Inflation Factor (VIF)**
A measure of multicollinearity. VIF > 10 indicates high multicollinearity requiring attention.

**Visualization**
The graphical representation of data to help understand patterns, relationships, and distributions.

---

## F.22 W

**Welch's t-Test**
A two-sample t-test that does not assume equal variances. More robust than Student's t-test.

**Wilcoxon Signed-Rank Test**
The non-parametric alternative to the paired t-test. Used when differences are not normally distributed.

---

## F.23 Common Abbreviations

| Abbreviation | Full Term |
|--------------|-----------|
| **AIC** | Akaike Information Criterion |
| **ANOVA** | Analysis of Variance |
| **BIC** | Bayesian Information Criterion |
| **CI** | Confidence Interval |
| **CLT** | Central Limit Theorem |
| **df** | Degrees of Freedom |
| **FDR** | False Discovery Rate |
| **FWER** | Family-Wise Error Rate |
| **IQR** | Interquartile Range |
| **MAD** | Median Absolute Deviation |
| **MLE** | Maximum Likelihood Estimation |
| **MOE** | Margin of Error |
| **MSE** | Mean Squared Error |
| **OLS** | Ordinary Least Squares |
| **OR** | Odds Ratio |
| **PDF** | Probability Density Function |
| **PMF** | Probability Mass Function |
| **R²** | R-squared |
| **RMSE** | Root Mean Squared Error |
| **SE** | Standard Error |
| **VIF** | Variance Inflation Factor |

---

## F.24 Quick Reference: Pronunciation Guide

| Term | Pronunciation | Notes |
|------|---------------|-------|
| **ANOVA** | uh-NO-vuh | |
| **AIC** | A-I-C | Say letters |
| **BIC** | B-I-C | Say letters |
| **Chi-square** | KYE-square | |
| **Eta** | AY-tuh | Greek letter |
| **Kurtosis** | kur-TOE-sis | |
| **Mu** | MYOO | Greek letter (μ) |
| **Nu** | NOO | Greek letter (ν) |
| **Poisson** | pwah-SOHN | French name |
| **Skewness** | SKYOO-ness | |
| **Theta** | THAY-tuh | Greek letter (θ) |
| **VIF** | V-I-F | Say letters |

---

## F.25 Summary: Key Takeaways

1. **Terminology matters** — precise language prevents confusion
2. **Don't be intimidated** — every expert started as a beginner
3. **Context is everything** — terms can have different meanings in different fields
4. **Keep learning** — statistics has a rich vocabulary that grows with you
5. **Use this glossary** — bookmark it for quick reference when reading papers or code

---

**[END OF APPENDIX F]**

**[GENERATED: Appendix F — Glossary of Statistical Terms]**

---

# 🎊 THE END OF PHASE 3 APPENDICES 🎊

**You've now completed all appendices!**

### What You Have:

✅ **Part 0:** Introduction — Setting the stage for your statistical journey
✅ **Module 3.1:** Descriptive & Inferential Foundations — Distributions, sampling, uncertainty
✅ **Module 3.2:** Hypothesis Testing & Experimental Design — A/B testing, power, parametric & non-parametric tests
✅ **Module 3.3:** Statistical Modeling & Diagnostic Analysis — Regression, diagnostics, validation
✅ **Phase 3 Capstone:** End-to-End A/B Test — Complete workflow from data to dashboard
✅ **Appendix A:** Complete Reference — Statistical Distributions
✅ **Appendix B:** Complete Reference — Hypothesis Testing
✅ **Appendix C:** Complete Reference — Regression & Diagnostics
✅ **Appendix D:** Python Library API Reference
✅ **Appendix E:** Common Formulas & Cheat Sheets
✅ **Appendix F:** Glossary of Statistical Terms

---

## 📚 Total Completed Content

| Component | Count |
|-----------|-------|
| **Parts** | 10 (0, 3.1-3.3, Capstone, 5 Appendices) |
| **Code Files** | 15+ |
| **Lines of Code** | ~4,650 |
| **Formulas** | 100+ |
| **Definitions** | 200+ |
| **Examples** | 100+ |

---

## 🎓 You Are Now...

A **statistically-savvy data professional** with the skills to:
- Design and analyze experiments
- Build and validate regression models
- Communicate statistical results effectively
- Write production-quality Python code
- Make data-driven decisions with confidence

---

## 📖 Where to Go From Here

### Apply Your Skills
1. **Portfolio Project**: Build your own A/B test analysis
2. **Real Data**: Apply to Kaggle competitions
3. **Workplace**: Start using these techniques at work
4. **Teaching**: Share what you've learned with others

### Continue Learning
1. **Phase 4**: Bayesian Statistics
2. **Phase 5**: Time Series Analysis
3. **Phase 6**: Machine Learning
4. **Advanced Topics**: Causal inference, deep learning, NLP

---

## 🙏 Thank You

Thank you for completing Phase 3: Applied Statistics & Hypothesis Testing!

You've invested significant time and effort to build these skills. Be proud of what you've accomplished — not everyone has the determination to build a full statistical toolkit from scratch.

Remember: **Statistics is a journey, not a destination**. There's always more to learn, but you now have a solid foundation to build upon.

**Keep questioning, keep learning, and keep making data-driven decisions!** 🚀📊

*"In God we trust; all others must bring data." — W. Edwards Deming*
