# APPENDIX D: PYTHON LIBRARY API REFERENCE

Welcome to the fourth appendix! This reference provides a comprehensive guide to the Python libraries used throughout Phase 3, with detailed API documentation, usage examples, and best practices. Think of this as your **Python data science cheat sheet** — everything you need to know about the libraries you've been using.

---

## D.1 NumPy (Numerical Python)

### Core Array Operations

```python
import numpy as np

# Create arrays
arr = np.array([1, 2, 3, 4, 5])
zeros = np.zeros((3, 4))          # 3x4 array of zeros
ones = np.ones((2, 3))            # 2x3 array of ones
empty = np.empty((3, 3))          # Uninitialized (fast)
eye = np.eye(4)                   # 4x4 identity matrix

# Create arrays with ranges
range_arr = np.arange(0, 10, 2)   # [0, 2, 4, 6, 8]
linspace_arr = np.linspace(0, 1, 5) # [0, 0.25, 0.5, 0.75, 1]

# Random arrays
random_arr = np.random.random((3, 3))
normal_arr = np.random.normal(0, 1, (100, 2))
uniform_arr = np.random.uniform(0, 1, 50)
```

### Array Manipulation

```python
# Reshape
reshaped = arr.reshape((5, 1))    # Column vector
flattened = reshaped.flatten()    # Back to 1D
transposed = arr.T                # Transpose

# Slicing
subarray = arr[1:4]               # Elements 1-3
rows = array[0:2, :]              # First two rows
columns = array[:, 1:3]           # Columns 1-2

# Concatenation
vstacked = np.vstack([arr1, arr2])  # Stack vertically
hstacked = np.hstack([arr1, arr2])  # Stack horizontally

# Broadcasting
arr + 5                           # Add 5 to each element
arr * 2                           # Multiply each element by 2
```

### Statistical Functions

```python
# Basic statistics
mean = np.mean(data)
median = np.median(data)
std = np.std(data, ddof=1)        # Sample standard deviation
var = np.var(data, ddof=1)        # Sample variance

# Quantiles
q25 = np.percentile(data, 25)
q75 = np.percentile(data, 75)
quantiles = np.quantile(data, [0.25, 0.5, 0.75])

# Aggregate functions
sum_arr = np.sum(data, axis=0)    # Sum along rows
mean_arr = np.mean(data, axis=1)  # Mean along columns

# Random sampling
sample = np.random.choice(data, size=100, replace=True)
```

---

## D.2 Pandas (Data Manipulation)

### Creating DataFrames

```python
import pandas as pd

# From dictionary
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35],
    'salary': [50000, 60000, 70000]
})

# From CSV
df = pd.read_csv('data.csv')

# From Excel
df = pd.read_excel('data.xlsx')

# Basic info
df.head()                         # First 5 rows
df.info()                         # Column info
df.describe()                     # Summary statistics
df.shape                          # (rows, columns)
df.columns                        # Column names
```

### Data Selection

```python
# Column selection
column = df['age']                # Single column
columns = df[['age', 'salary']]   # Multiple columns

# Row selection (loc - by label)
row = df.loc[0]                   # First row
rows = df.loc[0:2]                # Rows 0-2

# Row selection (iloc - by position)
row = df.iloc[0]                  # First row
rows = df.iloc[0:3]               # Rows 0-2

# Boolean indexing
mask = df['age'] > 30
filtered = df[mask]

# Query method
filtered = df.query('age > 30 and salary > 50000')
```

### Data Transformation

```python
# Apply functions
df['age_squared'] = df['age'].apply(lambda x: x**2)

# Map values
df['age_group'] = df['age'].map({25: 'young', 30: 'middle', 35: 'old'})

# Create new column
df['new_column'] = df['age'] * 2

# Drop columns/rows
df.drop('column_name', axis=1, inplace=True)  # Drop column
df.drop(0, axis=0, inplace=True)              # Drop row

# Rename columns
df.rename(columns={'old_name': 'new_name'}, inplace=True)
```

### Group Operations

```python
# Group by
grouped = df.groupby('category')

# Aggregations
grouped.mean()                    # Mean of each group
grouped.agg(['mean', 'std'])      # Multiple statistics
grouped['column'].agg(['mean', 'std'])  # Specific column

# Transform
df['normalized'] = df.groupby('category')['value'].transform('mean')

# Pivot tables
pivot = df.pivot_table(
    values='value',
    index='category',
    columns='date',
    aggfunc='mean'
)
```

### Missing Data

```python
# Detect missing
df.isnull()
df.isnull().sum()

# Handle missing
df.dropna()                       # Drop rows with missing
df.dropna(axis=1)                 # Drop columns with missing
df.fillna(0)                      # Fill with 0
df.fillna(df.mean())              # Fill with mean
df.fillna(method='ffill')         # Forward fill

# Check for duplicates
df.duplicated()
df.drop_duplicates()
```

### Merge and Join

```python
# Merge DataFrames
merged = pd.merge(
    df1, df2,
    on='key_column',
    how='inner'                    # inner, outer, left, right
)

# Concatenate
concatenated = pd.concat([df1, df2], axis=0)  # Vertical
concatenated = pd.concat([df1, df2], axis=1)  # Horizontal

# Join
joined = df1.join(df2, on='key_column')
```

---

## D.3 SciPy (Scientific Computing)

### Statistical Distributions

```python
from scipy import stats

# Normal distribution
normal = stats.norm(loc=0, scale=1)
pdf = normal.pdf(0)               # Probability density at 0
cdf = normal.cdf(0.5)             # Cumulative probability
ppf = normal.ppf(0.975)           # Percent point function (inverse CDF)
rvs = normal.rvs(size=100)        # Random samples

# Similar for other distributions
stats.binom(n=10, p=0.5)
stats.poisson(mu=5)
stats.expon(scale=1)
stats.uniform(loc=0, scale=1)
```

### Hypothesis Tests

```python
# t-tests
t_stat, p_value = stats.ttest_1samp(data, popmean=0)
t_stat, p_value = stats.ttest_ind(group1, group2, equal_var=False)
t_stat, p_value = stats.ttest_rel(before, after)

# Non-parametric tests
u_stat, p_value = stats.mannwhitneyu(group1, group2)
w_stat, p_value = stats.wilcoxon(before, after)
h_stat, p_value = stats.kruskal(group1, group2, group3)

# Correlation
corr, p_value = stats.pearsonr(x, y)
corr, p_value = stats.spearmanr(x, y)

# Categorical tests
chi2, p_value, dof, expected = stats.chi2_contingency(table)
odds_ratio, p_value = stats.fisher_exact(table)
```

### Regression and Model Diagnostics

```python
# Linear regression
slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)

# ANOVA
f_stat, p_value = stats.f_oneway(group1, group2, group3)

# Normality tests
stat, p_value = stats.shapiro(data)
stat, p_value = stats.normaltest(data)
stat, p_value = stats.anderson(data)

# Variance tests
stat, p_value = stats.levene(group1, group2)
stat, p_value = stats.bartlett(group1, group2)
```

---

## D.4 Statsmodels (Statistical Models)

### Linear Regression (OLS)

```python
import statsmodels.api as sm
import statsmodels.formula.api as smf

# Method 1: Using arrays
X = df[['x1', 'x2']]
X = sm.add_constant(X)           # Add intercept
y = df['y']
model = sm.OLS(y, X)
results = model.fit()
print(results.summary())

# Method 2: Using formula
model = smf.ols('y ~ x1 + x2', data=df)
results = model.fit()
print(results.summary())

# Extract results
results.params                    # Coefficients
results.pvalues                   # p-values
results.conf_int()                # Confidence intervals
results.rsquared                  # R-squared
results.rsquared_adj              # Adjusted R-squared
results.fvalue                    # F-statistic
results.f_pvalue                  # F p-value
results.resid                     # Residuals
results.fittedvalues              # Predicted values
```

### Logistic Regression

```python
# Logistic regression
model = smf.logit('binary ~ x1 + x2', data=df)
results = model.fit()
print(results.summary())

# Get odds ratios
odds_ratios = np.exp(results.params)

# Predict probabilities
pred_probs = results.predict(df_test)

# Classification
pred_class = (pred_probs > 0.5).astype(int)
```

### ANOVA

```python
# One-way ANOVA
from statsmodels.stats.anova import anova_lm
model = smf.ols('y ~ group', data=df).fit()
anova_results = anova_lm(model)
print(anova_results)

# Two-way ANOVA
model = smf.ols('y ~ group1 + group2 + group1:group2', data=df).fit()
anova_results = anova_lm(model)
```

### Post-hoc Tests

```python
from statsmodels.stats.multicomp import pairwise_tukeyhsd

# Tukey HSD
tukey = pairwise_tukeyhsd(df['y'], df['group'], alpha=0.05)
print(tukey)

# Multiple testing corrections
from statsmodels.stats.multitest import multipletests
rejected, adjusted, _, _ = multipletests(p_values, alpha=0.05, method='fdr_bh')
```

---

## D.5 Matplotlib (Plotting)

### Basic Plots

```python
import matplotlib.pyplot as plt

# Line plot
plt.plot(x, y)
plt.xlabel('X label')
plt.ylabel('Y label')
plt.title('Title')
plt.legend()
plt.show()

# Scatter plot
plt.scatter(x, y, alpha=0.5)

# Histogram
plt.hist(data, bins=30, alpha=0.7)

# Bar plot
plt.bar(categories, values)

# Box plot
plt.boxplot([group1, group2, group3], labels=['G1', 'G2', 'G3'])

# Multiple subplots
fig, axes = plt.subplots(2, 2, figsize=(12, 8))
axes[0,0].plot(x1, y1)
axes[0,1].scatter(x2, y2)
# ... etc
```

### Advanced Plotting

```python
# Q-Q plot
from scipy import stats
stats.probplot(data, dist="norm", plot=plt)
plt.show()

# Residual plots
plt.scatter(fitted, residuals)
plt.axhline(y=0, color='red', linestyle='--')
plt.xlabel('Fitted Values')
plt.ylabel('Residuals')

# Density plot
plt.hist(data, bins=30, density=True, alpha=0.6)
plt.axvline(mean, color='red', label='Mean')
plt.axvline(median, color='blue', linestyle='--', label='Median')

# Saving figures
plt.savefig('figure.png', dpi=300, bbox_inches='tight')
```

### Customization

```python
# Style
plt.style.use('seaborn-v0_8-whitegrid')
plt.rcParams['figure.figsize'] = (10, 6)
plt.rcParams['font.size'] = 12

# Colors
colors = plt.cm.Set1(np.linspace(0, 1, n_groups))

# Legend
plt.legend(loc='best', framealpha=0.7)

# Annotations
plt.annotate('Important point', xy=(x, y), xytext=(x+0.5, y+0.5),
             arrowprops=dict(arrowstyle='->'))
```

---

## D.6 Seaborn (Statistical Visualization)

```python
import seaborn as sns

# Set style
sns.set_style('whitegrid')
sns.set_palette('husl')

# Distribution plots
sns.histplot(data, kde=True)
sns.kdeplot(data, fill=True)
sns.rugplot(data)

# Categorical plots
sns.boxplot(x='group', y='value', data=df)
sns.violinplot(x='group', y='value', data=df)
sns.swarmplot(x='group', y='value', data=df)
sns.barplot(x='group', y='value', data=df)

# Relationship plots
sns.scatterplot(x='x', y='y', data=df)
sns.lineplot(x='x', y='y', data=df)
sns.regplot(x='x', y='y', data=df)
sns.lmplot(x='x', y='y', hue='group', data=df)

# Matrix plots
sns.heatmap(correlation_matrix, annot=True)
sns.clustermap(data)

# Pair plots
sns.pairplot(df, hue='group')
```

---

## D.7 Scikit-learn (Machine Learning Utilities)

### Preprocessing

```python
from sklearn.preprocessing import StandardScaler, MinMaxScaler, LabelEncoder

# Standardization
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Normalization
scaler = MinMaxScaler()
X_norm = scaler.fit_transform(X)

# Label encoding
encoder = LabelEncoder()
y_encoded = encoder.fit_transform(y)
```

### Model Selection

```python
from sklearn.model_selection import train_test_split, cross_val_score

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Cross-validation
from sklearn.linear_model import LinearRegression
model = LinearRegression()
scores = cross_val_score(model, X, y, cv=5)
```

### Metrics

```python
from sklearn.metrics import mean_squared_error, r2_score, accuracy_score

# Regression metrics
mse = mean_squared_error(y_true, y_pred)
rmse = np.sqrt(mse)
r2 = r2_score(y_true, y_pred)

# Classification metrics
accuracy = accuracy_score(y_true, y_pred)
```

---

## D.8 Streamlit (Interactive Dashboards)

### Basic App

```python
import streamlit as st

# Title
st.title("My Dashboard")
st.header("Section Header")
st.subheader("Subheader")
st.markdown("**Bold text** and *italic*")

# Data display
st.dataframe(df)
st.table(df.head())
st.json(json_data)

# Charts
st.line_chart(df)
st.bar_chart(df)
st.area_chart(df)
st.pyplot(matplotlib_fig)

# Interactive elements
value = st.slider("Select value", 0, 100, 50)
option = st.selectbox("Choose option", ["A", "B", "C"])
checkbox = st.checkbox("Show details")
button = st.button("Run analysis")

# Layout
col1, col2 = st.columns(2)
with col1:
    st.write("Column 1")
with col2:
    st.write("Column 2")

# Caching
@st.cache_data
def load_data():
    return pd.read_csv("data.csv")
```

---

## D.9 Quick Reference: Common Patterns

### Data Loading

```python
# CSV
df = pd.read_csv('file.csv', index_col=0)
df.to_csv('file.csv')

# Excel
df = pd.read_excel('file.xlsx', sheet_name='Sheet1')
df.to_excel('file.xlsx')

# JSON
df = pd.read_json('file.json')
df.to_json('file.json')
```

### Data Cleaning

```python
# Remove duplicates
df.drop_duplicates(inplace=True)

# Fill missing
df.fillna(df.mean(), inplace=True)
df.fillna(method='ffill', inplace=True)

# Convert types
df['column'] = df['column'].astype('int')
df['date'] = pd.to_datetime(df['date'])
```

### Common Analysis

```python
# Group by aggregation
summary = df.groupby('category').agg({
    'numeric': ['mean', 'std', 'median'],
    'categorical': 'count'
})

# Correlation matrix
corr = df.corr()
sns.heatmap(corr, annot=True, cmap='coolwarm')

# Summary statistics
summary = df.describe(percentiles=[0.25, 0.5, 0.75])
summary.loc['n'] = df.count()
```

---

## D.10 Version Compatibility

### Recommended Versions

| Library | Version | Description |
|---------|---------|-------------|
| **numpy** | 1.24.3 | Core numerical computing |
| **pandas** | 2.0.3 | Data manipulation |
| **scipy** | 1.10.1 | Scientific computing |
| **statsmodels** | 0.14.0 | Statistical models |
| **matplotlib** | 3.7.1 | Plotting |
| **seaborn** | 0.12.2 | Statistical visualization |
| **streamlit** | 1.25.0 | Interactive dashboards |
| **scikit-learn** | 1.3.0 | Machine learning utilities |

### Installation

```bash
# All at once
pip install numpy==1.24.3 pandas==2.0.3 scipy==1.10.1 statsmodels==0.14.0 matplotlib==3.7.1 seaborn==0.12.2 streamlit==1.25.0 scikit-learn==1.3.0

# Individual
pip install numpy pandas scipy statsmodels matplotlib seaborn streamlit scikit-learn
```

---

## D.11 Summary: Key Takeaways

1. **NumPy** is the foundation — master arrays and broadcasting
2. **Pandas** is for data manipulation — learn groupby and merge
3. **SciPy** has all the statistical functions you need
4. **Statsmodels** is for regression and statistical modeling
5. **Matplotlib** and **Seaborn** for visualization
6. **Streamlit** for sharing your work interactively
7. **Always check versions** — compatibility matters!

**Next Appendix: E — Common Formulas & Cheat Sheets**
