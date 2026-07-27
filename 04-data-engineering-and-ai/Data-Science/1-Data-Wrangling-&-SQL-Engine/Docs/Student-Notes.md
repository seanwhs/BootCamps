# STUDENT NOTES: Complete Reference Companion

## Your Go-To Guide for the Data Engineering & Data Science Series

---

## Introduction

These Student Notes are designed to be your constant companion throughout the series and beyond. Unlike the detailed tutorials or the exercise-heavy workbook, these notes are **concise, reference-focused, and organized for quick lookup**.

**How to Use These Notes:**

1. **Before a module:** Skim the notes to preview key concepts
2. **During a module:** Refer to notes for quick syntax reminders
3. **After a module:** Use notes as a study guide for review
4. **On the job:** Keep these notes open as a reference

**Notation Legend:**
- 📘 = Key Concept
- ⚡ = Performance Tip
- ⚠️ = Warning / Pitfall
- ✅ = Best Practice
- 🔍 = Deep Dive Link
- 💡 = Pro Tip

---

## N1: Python Core Concepts

### 📘 Data Types Quick Reference

| Type | Mutable | Example | Use Case |
|------|---------|---------|----------|
| `int` | No | `42` | Whole numbers |
| `float` | No | `3.14` | Decimal numbers |
| `str` | No | `"hello"` | Text |
| `bool` | No | `True` | Boolean logic |
| `list` | Yes | `[1,2,3]` | Ordered sequences |
| `tuple` | No | `(1,2,3)` | Fixed data |
| `dict` | Yes | `{'a':1}` | Key-value pairs |
| `set` | Yes | `{1,2,3}` | Unique values |

### 📘 Control Flow Patterns

```python
# If-elif-else
if condition:
    # do something
elif other_condition:
    # do something else
else:
    # fallback

# For loop
for item in iterable:
    # process item

# While loop
while condition:
    # repeat until condition is False

# List comprehension
squares = [x**2 for x in range(10)]
evens = [x for x in range(20) if x % 2 == 0]

# Dictionary comprehension
squares_dict = {x: x**2 for x in range(10)}
```

### ⚡ Performance Tips

```python
# ❌ SLOW - Python loop
total = 0
for x in data:
    total += x**2

# ✅ FAST - Vectorized
import numpy as np
total = np.sum(data**2)

# ❌ SLOW - appending in loop
result = []
for x in data:
    result.append(process(x))

# ✅ FAST - list comprehension
result = [process(x) for x in data]

# ✅ FASTER - generator (memory efficient)
result = (process(x) for x in data)
```

### 📘 Common Built-in Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `len()` | Get length | `len([1,2,3])` → `3` |
| `type()` | Get type | `type(42)` → `<class 'int'>` |
| `isinstance()` | Check type | `isinstance(42, int)` → `True` |
| `sorted()` | Sort iterable | `sorted([3,1,2])` → `[1,2,3]` |
| `sum()` | Sum iterable | `sum([1,2,3])` → `6` |
| `max()`/`min()` | Max/Min | `max([1,2,3])` → `3` |
| `zip()` | Pair iterables | `zip([1,2], ['a','b'])` |
| `enumerate()` | Index + value | `enumerate(['a','b'])` |

### ⚠️ Common Pitfalls

```python
# 1. Mutable default arguments
# ❌ BAD
def add_item(item, my_list=[]):
    my_list.append(item)
    return my_list

# ✅ GOOD
def add_item(item, my_list=None):
    if my_list is None:
        my_list = []
    my_list.append(item)
    return my_list

# 2. Modifying while iterating
# ❌ BAD
for x in my_list:
    if condition:
        my_list.remove(x)

# ✅ GOOD
my_list = [x for x in my_list if not condition]

# 3. Shallow copy vs deep copy
import copy
# Shallow: list2 = list1.copy()
# Deep: list2 = copy.deepcopy(list1)
```

---

## N2: NumPy Essentials

### 📘 Array Creation

```python
import numpy as np

# From list
arr = np.array([1, 2, 3, 4, 5])

# Common arrays
zeros = np.zeros((3, 4))       # 3x4 zeros
ones = np.ones((2, 3))         # 2x3 ones
eye = np.eye(4)                # 4x4 identity
full = np.full((3, 3), 7)      # 3x3 filled with 7

# Ranges
arange = np.arange(0, 10, 2)   # [0, 2, 4, 6, 8]
linspace = np.linspace(0, 1, 5) # [0, 0.25, 0.5, 0.75, 1]

# Random
np.random.seed(42)             # Set seed for reproducibility
random = np.random.randn(3, 4) # Standard normal
uniform = np.random.uniform(0, 1, (2, 3))
integers = np.random.randint(0, 10, (3, 3))
```

### 📘 Array Properties

```python
arr.shape      # Dimensions → (3, 4)
arr.size       # Total elements → 12
arr.ndim       # Number of dimensions → 2
arr.dtype      # Data type → dtype('float64')
arr.nbytes     # Total bytes → 96
arr.T          # Transpose
```

### 📘 Indexing & Slicing

```python
arr = np.arange(12).reshape(3, 4)

arr[1, 2]          # Single element → 6
arr[1]             # Row 1 → [4, 5, 6, 7]
arr[:, 2]          # Column 2 → [2, 6, 10]
arr[1:3, 1:3]      # Submatrix → [[5, 6], [9, 10]]
arr[arr > 5]       # Boolean indexing → [6, 7, 8, 9, 10, 11]
```

### 📘 Universal Functions (Ufuncs)

```python
# Arithmetic
arr + 10
arr * 2
arr ** 2
np.sqrt(arr)
np.exp(arr)
np.log(arr)

# Comparisons
arr > 5
arr == 3
np.where(arr > 5, 1, 0)  # Conditional

# Aggregations
arr.sum()
arr.mean()
arr.std()
arr.min()
arr.max()
```

### ⚡ Broadcasting Rules

```
If arrays have different dimensions:
1. Pad with 1s on the left
2. Arrays can be broadcast if dimensions are equal or one is 1
3. Result has maximum dimension along each axis

Examples:
(3, 4) + (4,)  → (4,) broadcasts to (1, 4) → (3, 4)
(3, 4) + (3, 1) → (3, 1) broadcasts to (3, 4)
(3, 4) + (5,)  → ERROR (incompatible)
```

---

## N3: Pandas Core Operations

### 📘 Series & DataFrame Creation

```python
import pandas as pd

# Series
s = pd.Series([1, 2, 3, 4, 5], index=['a', 'b', 'c', 'd', 'e'])

# DataFrame
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35],
    'city': ['NYC', 'LA', 'Chicago']
})

# From list of dicts
df = pd.DataFrame([
    {'name': 'Alice', 'age': 25},
    {'name': 'Bob', 'age': 30}
])

# From CSV
df = pd.read_csv('data.csv')
df = pd.read_parquet('data.parquet')
df = pd.read_excel('data.xlsx')
```

### 📘 Data Inspection

```python
df.head()         # First 5 rows
df.tail()         # Last 5 rows
df.sample(10)     # Random sample
df.info()         # Column info
df.describe()     # Summary statistics
df.shape          # (rows, columns)
df.columns        # Column names
df.dtypes         # Data types
df.isna().sum()   # Missing values
```

### 📘 Selection & Filtering

```python
# Column selection
df['name']
df[['name', 'age']]

# Row selection
df.iloc[0]           # First row (integer)
df.loc[0]            # First row (label)
df.loc[0:5, 'name']  # Rows 0-5, column name

# Filtering
df[df['age'] > 30]
df.query('age > 30 and city == "NYC"')
df.loc[df['age'] > 30, ['name', 'age']]

# Boolean indexing
df[df['age'].between(25, 35)]
df[df['name'].str.contains('A')]
df[df['city'].isin(['NYC', 'LA'])]
```

### 📘 Data Manipulation

```python
# Add/update columns
df['new_col'] = df['age'] * 2
df = df.assign(age_doubled=df['age']*2)

# Rename
df.rename(columns={'name': 'full_name'}, inplace=True)

# Sort
df.sort_values('age', ascending=False)

# Group by
df.groupby('city')['age'].mean()
df.groupby('city').agg({
    'age': ['mean', 'std', 'count'],
    'name': 'count'
})

# Merge
pd.merge(df1, df2, on='id', how='left')
pd.concat([df1, df2], axis=0)  # Rows
pd.concat([df1, df2], axis=1)  # Columns
```

### ⚡ Performance Tips

```python
# ❌ SLOW - iterrows()
for idx, row in df.iterrows():
    # process row

# ✅ FAST - vectorized
df['new'] = df['col1'] + df['col2']

# ❌ SLOW - apply with simple operations
df['new'] = df.apply(lambda x: x['a'] + x['b'], axis=1)

# ✅ FAST - vectorized or eval
df['new'] = df['a'] + df['b']
df['new'] = df.eval('a + b')

# ✅ Data type optimization
df['category'] = df['category'].astype('category')
df['int_col'] = pd.to_numeric(df['int_col'], downcast='integer')
```

### ⚠️ Common Pitfalls

```python
# 1. Chained indexing - use .loc
# ❌ BAD
df[df['age'] > 30]['income'] = 0  # May not work!

# ✅ GOOD
df.loc[df['age'] > 30, 'income'] = 0

# 2. View vs Copy - use .copy()
df_filtered = df[df['age'] > 30]  # View
df_filtered = df[df['age'] > 30].copy()  # Copy

# 3. Inplace operations - be careful
df.drop(columns=['col'], inplace=True)  # Changes original
df = df.drop(columns=['col'])  # Returns new DataFrame
```

---

## N4: Polars Quick Reference

### 📘 DataFrame Creation

```python
import polars as pl

# From dict
df = pl.DataFrame({
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35]
})

# From list of dicts
df = pl.DataFrame([
    {'name': 'Alice', 'age': 25},
    {'name': 'Bob', 'age': 30}
])

# From Pandas
df = pl.from_pandas(pd_df)

# Read files
df = pl.read_csv('data.csv')
df = pl.read_parquet('data.parquet')
df = pl.scan_csv('large_file.csv')  # Lazy
```

### 📘 Core Operations

```python
# Selection
df.select('name')
df.select(['name', 'age'])
df.select(pl.col('name'), pl.col('age'))

# Filtering
df.filter(pl.col('age') > 30)
df.filter((pl.col('age') > 30) & (pl.col('city') == 'NYC'))

# Add columns
df.with_columns((pl.col('age') * 2).alias('age_doubled'))

# Group by
df.group_by('city').agg([
    pl.col('age').mean().alias('avg_age'),
    pl.col('age').count().alias('count')
])

# Sort
df.sort('age', descending=True)

# Unique
df.unique(subset=['city'])
```

### 📘 Expression Syntax

```python
# Column operations
pl.col('age')
pl.col('age').mean()
pl.col('age').std()
pl.col('age').sum()
pl.col('age').min()
pl.col('age').max()

# String operations
pl.col('name').str.to_uppercase()
pl.col('name').str.len()
pl.col('name').str.contains('A')

# DateTime operations
pl.col('date').dt.year()
pl.col('date').dt.month()
pl.col('date').dt.day()

# Conditional
pl.when(pl.col('age') > 30)
  .then(pl.lit('Old'))
  .otherwise(pl.lit('Young'))

# Casting
pl.col('age').cast(pl.Float64)
```

### ⚡ Lazy Evaluation

```python
# Build query plan (not executed)
query = (pl.scan_csv('large_file.csv')
    .filter(pl.col('value') > 0)
    .group_by('category')
    .agg([
        pl.col('value').mean().alias('mean'),
        pl.col('value').count().alias('count')
    ])
    .sort('mean', descending=True)
)

# Execute
result = query.collect()

# Fetch first n rows (partial execution)
preview = query.fetch(100)

# Streaming (process > RAM)
result = query.collect(streaming=True)
```

---

## N5: SQL Quick Reference

### 📘 Query Structure

```sql
SELECT column1, column2, aggregate_function(column3)
FROM table1
JOIN table2 ON table1.key = table2.key
WHERE condition
GROUP BY column1
HAVING aggregate_condition
ORDER BY column1 DESC
LIMIT 10;
```

### 📘 Common Clauses

| Clause | Purpose | Example |
|--------|---------|---------|
| `SELECT` | Choose columns | `SELECT name, age` |
| `DISTINCT` | Unique values | `SELECT DISTINCT category` |
| `WHERE` | Filter rows | `WHERE age > 30` |
| `IN` | Multiple values | `WHERE region IN ('A','B')` |
| `BETWEEN` | Range | `WHERE age BETWEEN 18 AND 65` |
| `LIKE` | Pattern | `WHERE name LIKE 'J%'` |
| `ORDER BY` | Sort | `ORDER BY age DESC` |
| `GROUP BY` | Group rows | `GROUP BY category` |
| `HAVING` | Filter groups | `HAVING COUNT(*) > 5` |
| `LIMIT` | Row limit | `LIMIT 100` |

### 📘 Joins

```sql
-- INNER: Matching rows only
SELECT * FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;

-- LEFT: All left + matching right
SELECT * FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id;

-- RIGHT: All right + matching left
SELECT * FROM customers c
RIGHT JOIN orders o ON c.id = o.customer_id;

-- FULL: All rows from both
SELECT * FROM customers c
FULL JOIN orders o ON c.id = o.customer_id;

-- SELF: Join table to itself
SELECT e.name, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### 📘 Window Functions

```sql
-- Ranking
ROW_NUMBER() OVER (PARTITION BY category ORDER BY value)
RANK() OVER (PARTITION BY category ORDER BY value)
DENSE_RANK() OVER (PARTITION BY category ORDER BY value)

-- Lag/Lead
LAG(value, 1) OVER (ORDER BY date)
LEAD(value, 1) OVER (ORDER BY date)

-- Running totals
SUM(value) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)

-- Moving averages
AVG(value) OVER (
    ORDER BY date
    ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
)

-- Percentiles
NTILE(4) OVER (ORDER BY value)  -- Quartiles
```

### 📘 CTEs (Common Table Expressions)

```sql
WITH cte_name AS (
    SELECT column1, column2
    FROM table1
    WHERE condition
)
SELECT *
FROM cte_name
JOIN table2 ON cte_name.column1 = table2.column1;

-- Recursive CTE
WITH RECURSIVE date_series AS (
    SELECT '2025-01-01'::DATE as date
    UNION ALL
    SELECT date + INTERVAL '1 day'
    FROM date_series
    WHERE date < '2025-01-31'
)
SELECT * FROM date_series;
```

### ⚡ Performance Tips

```sql
-- 1. SELECT only needed columns
-- BAD: SELECT *
-- GOOD: SELECT id, name, age

-- 2. Use WHERE early (filter before join)
-- BAD: Join then filter
-- GOOD: Filter then join

-- 3. Use EXISTS instead of IN for subqueries
-- GOOD: EXISTS (SELECT 1 FROM orders WHERE customer_id = c.id)
-- OK: customer_id IN (SELECT customer_id FROM orders)

-- 4. Use EXPLAIN ANALYZE to understand query plans
EXPLAIN ANALYZE SELECT * FROM orders WHERE order_date > '2025-01-01';

-- 5. Create appropriate indexes
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
```

---

## N6: DuckDB Quick Reference

### 📘 Basic Usage

```python
import duckdb

# Connect (in-memory)
conn = duckdb.connect(':memory:')

# Connect to file
conn = duckdb.connect('database.duckdb')

# Register DataFrame as view
conn.register('my_data', df)

# Execute query
result = conn.execute("SELECT * FROM my_data").fetchdf()

# Query CSV directly
result = conn.execute("""
    SELECT * FROM 'data.csv' 
    WHERE value > 0
""").fetchdf()

# Query Parquet directly
result = conn.execute("""
    SELECT * FROM 'data.parquet'
    WHERE category = 'A'
""").fetchdf()
```

### 📘 File Querying

```python
# CSV
conn.execute("SELECT * FROM 'file.csv'")

# Parquet
conn.execute("SELECT * FROM 'file.parquet'")

# JSON
conn.execute("SELECT * FROM 'file.json'")

# Multiple files
conn.execute("SELECT * FROM 'data/*.parquet'")
```

---

## N7: Data Quality & Validation

### 📘 Pydantic Schema

```python
from pydantic import BaseModel, Field, validator

class CustomerRecord(BaseModel):
    customer_id: int = Field(gt=0)
    first_name: str = Field(min_length=1, max_length=50)
    last_name: str = Field(min_length=1, max_length=50)
    email: str = Field(regex=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    age: int = Field(ge=18, le=120)
    income: float = Field(ge=0)
    
    @validator('email')
    def validate_email(cls, v):
        return v.lower()
```

### 📘 Pandera Schema

```python
import pandera as pa
from pandera.typing import Series

class SalesSchema(pa.SchemaModel):
    transaction_id: Series[str] = pa.Field(nullable=False)
    customer_id: Series[int] = pa.Field(gt=0, nullable=False)
    quantity: Series[int] = pa.Field(ge=1, le=100, nullable=False)
    price: Series[float] = pa.Field(ge=0, le=10000, nullable=False)
    
    @pa.dataframe_check
    def validate_total(cls, df: pd.DataFrame) -> Series[bool]:
        return df['total'] == df['quantity'] * df['price']

# Validate
try:
    validated_df = SalesSchema.validate(df)
except pa.errors.SchemaErrors as e:
    print(f"Validation failed: {e}")
```

### 📘 Quality Checks

```python
class DataQualityChecker:
    def __init__(self, df):
        self.df = df
        self.results = {}
    
    def check_missing(self, threshold=0.1):
        missing = self.df.isna().mean()
        high_missing = missing[missing > threshold]
        return {'columns': list(high_missing.index)}
    
    def check_duplicates(self):
        dupes = self.df.duplicated().sum()
        return {'count': dupes, 'rate': dupes / len(self.df)}
    
    def check_outliers(self, method='iqr', threshold=1.5):
        numeric = self.df.select_dtypes(include=[np.number])
        outliers = {}
        for col in numeric.columns:
            q1 = numeric[col].quantile(0.25)
            q3 = numeric[col].quantile(0.75)
            iqr = q3 - q1
            lower = q1 - threshold * iqr
            upper = q3 + threshold * iqr
            count = ((numeric[col] < lower) | (numeric[col] > upper)).sum()
            if count > 0:
                outliers[col] = count
        return outliers
```

---

## N8: Visualization Quick Reference

### 📘 Matplotlib

```python
import matplotlib.pyplot as plt

# Basic plots
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(x, y)           # Line plot
ax.scatter(x, y)        # Scatter plot
ax.bar(x, y)            # Bar chart
ax.hist(data, bins=30)  # Histogram
ax.boxplot(data)        # Box plot
ax.imshow(matrix)       # Heatmap

# Customization
ax.set_title('Title')
ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.legend()
ax.grid(True, alpha=0.3)

# Save
plt.savefig('figure.png', dpi=300, bbox_inches='tight')
```

### 📘 Seaborn

```python
import seaborn as sns

# Distribution
sns.histplot(data, kde=True)
sns.kdeplot(data, fill=True)
sns.boxplot(x='cat', y='value', data=df)
sns.violinplot(x='cat', y='value', data=df)

# Relationships
sns.scatterplot(x='x', y='y', data=df)
sns.regplot(x='x', y='y', data=df)
sns.pairplot(df)

# Categorical
sns.countplot(x='category', data=df)
sns.barplot(x='category', y='value', data=df)

# Faceting
g = sns.FacetGrid(df, col='category')
g.map(sns.scatterplot, 'x', 'y')

# Heatmap
sns.heatmap(corr, annot=True, cmap='RdBu')
```

### 📘 Plotly (Interactive)

```python
import plotly.express as px

# Basic charts
fig = px.scatter(df, x='x', y='y', color='category')
fig = px.histogram(df, x='age', color='category')
fig = px.box(df, x='category', y='value')
fig = px.bar(df, x='category', y='value')
fig = px.line(df, x='date', y='value')

# 3D
fig = px.scatter_3d(df, x='x', y='y', z='z')

# Dashboard
from plotly.subplots import make_subplots
fig = make_subplots(rows=2, cols=2)
fig.add_trace(go.Scatter(...), row=1, col=1)
fig.update_layout(height=800, width=1200)

# Save
fig.write_html('chart.html')
```

### 📘 Altair (Declarative)

```python
import altair as alt

chart = alt.Chart(df).mark_circle().encode(
    x='x:Q',
    y='y:Q',
    color='category:N',
    tooltip=['x', 'y', 'category']
).properties(
    title='Chart Title',
    width=600,
    height=400
)

chart.save('chart.html')
```

---

## N9: Statistics Quick Reference

### 📘 Descriptive Statistics

```python
import numpy as np
from scipy import stats

data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]

mean = np.mean(data)           # 14.5
median = np.median(data)       # 5.5
std = np.std(data)             # 29.0
var = np.var(data)             # 841.0
skew = stats.skew(data)        # 2.85 (right-skewed)
kurt = stats.kurtosis(data)    # 7.56 (heavy tails)
q1 = np.percentile(data, 25)   # 3.25
q3 = np.percentile(data, 75)   # 7.75
iqr = q3 - q1                  # 4.5
```

### 📘 Hypothesis Tests

```python
from scipy.stats import ttest_1samp, ttest_ind, ttest_rel
from scipy.stats import f_oneway, mannwhitneyu, wilcoxon
from scipy.stats import kruskal, chi2_contingency

# One-sample t-test
t_stat, p = ttest_1samp(sample, hypothesized_mean)

# Independent t-test
t_stat, p = ttest_ind(group1, group2)

# Paired t-test
t_stat, p = ttest_rel(before, after)

# ANOVA
f_stat, p = f_oneway(group1, group2, group3)

# Mann-Whitney (non-parametric)
u_stat, p = mannwhitneyu(group1, group2)

# Wilcoxon (non-parametric paired)
w_stat, p = wilcoxon(before, after)

# Kruskal-Wallis (non-parametric ANOVA)
h_stat, p = kruskal(group1, group2, group3)

# Chi-square
chi2, p, dof, expected = chi2_contingency(contingency)

# Correlation
r, p = stats.pearsonr(x, y)
rho, p = stats.spearmanr(x, y)
```

### 📘 Power Analysis

```python
from statsmodels.stats.power import TTestIndPower

power_analysis = TTestIndPower()

# Calculate sample size
n = power_analysis.solve_power(
    effect_size=0.5,   # Medium effect
    alpha=0.05,
    power=0.80,
    alternative='two-sided'
)

# Calculate power
power = power_analysis.power(
    effect_size=0.5,
    nobs1=100,
    alpha=0.05,
    alternative='two-sided'
)
```

### 📘 Multiple Testing Correction

```python
from statsmodels.stats.multitest import multipletests

p_values = [...]  # List of p-values

# Bonferroni
bonferroni_p = np.array(p_values) * len(p_values)
bonferroni_p = np.clip(bonferroni_p, 0, 1)

# FDR (Benjamini-Hochberg)
rejected, p_adjusted, _, _ = multipletests(
    p_values, 
    alpha=0.05, 
    method='fdr_bh'
)
```

---

## N10: Statistical Modeling

### 📘 Linear Regression

```python
import statsmodels.api as sm

# Prepare data
X = df[['x1', 'x2', 'x3']]
X = sm.add_constant(X)  # Add intercept
y = df['y']

# Fit model
model = sm.OLS(y, X).fit()

# Results
model.summary()          # Full summary
model.params             # Coefficients
model.pvalues            # P-values
model.conf_int()         # Confidence intervals
model.rsquared           # R-squared
model.rsquared_adj       # Adjusted R-squared
model.fvalue             # F-statistic
model.resid              # Residuals
model.fittedvalues       # Fitted values
```

### 📘 Logistic Regression

```python
import statsmodels.api as sm

# Prepare data
X = df[['x1', 'x2', 'x3']]
X = sm.add_constant(X)
y = df['y']  # Binary (0/1)

# Fit model
model = sm.Logit(y, X).fit(disp=0)

# Results
model.summary()
model.params                # Coefficients
np.exp(model.params)        # Odds ratios
model.predict(X)           # Probabilities
```

### 📘 Model Diagnostics

```python
# VIF (multicollinearity)
from statsmodels.stats.outliers_influence import variance_inflation_factor

X = df[['x1', 'x2', 'x3']]
vif = [variance_inflation_factor(X.values, i) 
       for i in range(X.shape[1])]

# Breusch-Pagan (heteroscedasticity)
from statsmodels.stats.diagnostic import het_breuschpagan
bp_stat, bp_p, _, _ = het_breuschpagan(model.resid, model.model.exog)

# Normality (Shapiro-Wilk)
from scipy.stats import shapiro
shapiro_stat, shapiro_p = shapiro(model.resid)

# Cook's Distance (influential points)
influence = model.get_influence()
cooks_d = influence.cooks_distance[0]
```

---

## N11: Git Quick Reference

### 📘 Essential Commands

```bash
# Setup
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Start
git init                    # Initialize repository
git clone URL               # Clone remote repository

# Basic workflow
git status                  # Check status
git add file.py            # Stage file
git add .                  # Stage all
git commit -m "Message"    # Commit
git commit -am "Message"   # Add + commit (tracked files only)

# Remote
git remote add origin URL  # Add remote
git push origin main       # Push to remote
git pull origin main       # Pull from remote

# Branching
git branch                 # List branches
git checkout -b feature    # Create + switch to new branch
git checkout main          # Switch to main
git merge feature          # Merge feature into current branch
git branch -d feature      # Delete branch

# History
git log                    # Full history
git log --oneline          # Compact
git log --graph --oneline  # Visual

# Undo
git reset HEAD file.py     # Unstage
git checkout -- file.py    # Discard changes
git reset --soft HEAD~1    # Undo last commit (keep changes)
git reset --hard HEAD~1    # Undo last commit (discard changes)

# Stashing
git stash                  # Save changes
git stash pop              # Apply + remove from stash
git stash list             # List stashes

# Tags
git tag -a v1.0 -m "Message"  # Create tag
git push origin --tags        # Push tags
```

### 📘 Common Workflows

```bash
# Feature branch workflow
git checkout -b feature/new-feature
# ... make changes ...
git add .
git commit -m "Implemented new feature"
git push -u origin feature/new-feature
# Create PR on GitHub
# After approval:
git checkout main
git pull origin main
git merge --no-ff feature/new-feature
git push origin main
git branch -d feature/new-feature

# Daily workflow
git checkout main
git pull origin main
git checkout -b feature/update
# ... work ...
git add .
git commit -m "Updates"
git push -u origin feature/update

# Hotfix
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug
# ... fix bug ...
git add .
git commit -m "Fixed critical bug"
git checkout main
git merge --no-ff hotfix/critical-bug
git push origin main
git branch -d hotfix/critical-bug
```

---

## N12: Data Engineering Project Structure

### 📘 Standard Project Layout

```
project-name/
├── README.md                     # Project documentation
├── requirements.txt              # Python dependencies
├── .env                          # Environment variables (gitignored)
├── .gitignore                    # Git ignore file
├── Makefile                      # Build automation
│
├── data/                         # Data directory
│   ├── raw/                      # Raw, immutable data
│   ├── processed/                # Cleaned, processed data
│   └── external/                 # External reference data
│
├── notebooks/                    # Jupyter notebooks
│   ├── 01_data_exploration.ipynb
│   ├── 02_feature_engineering.ipynb
│   └── 03_modeling.ipynb
│
├── src/                          # Source code
│   ├── __init__.py
│   ├── data/                     # Data processing
│   │   ├── __init__.py
│   │   ├── loader.py
│   │   ├── cleaner.py
│   │   └── transformer.py
│   ├── features/                 # Feature engineering
│   │   ├── __init__.py
│   │   └── builder.py
│   ├── models/                   # Model code
│   │   ├── __init__.py
│   │   ├── train.py
│   │   └── predict.py
│   └── utils/                    # Utilities
│       ├── __init__.py
│       ├── logger.py
│       ├── config.py
│       └── metrics.py
│
├── tests/                        # Unit tests
│   ├── __init__.py
│   ├── test_data.py
│   ├── test_features.py
│   └── test_models.py
│
└── config/                       # Configuration files
    ├── config.yaml
    └── logging.yaml
```

### 📘 Common .gitignore Entries

```gitignore
# Python
__pycache__/
*.py[cod]
*.so

# Virtual Environments
venv/
env/
.env/
.venv/

# Data
data/raw/
data/processed/
*.csv
*.parquet

# Models
models/
*.pkl
*.joblib

# Jupyter
.ipynb_checkpoints/

# IDE
.vscode/
.idea/

# Logs
logs/
*.log

# OS
.DS_Store
Thumbs.db
```

---

## N13: Environment Setup

### 📘 Virtual Environment

```bash
# Create
python3 -m venv venv

# Activate
# Linux/macOS
source venv/bin/activate

# Windows
venv\Scripts\activate

# Deactivate
deactivate

# Requirements
pip freeze > requirements.txt
pip install -r requirements.txt
```

### 📘 Essential Packages

```txt
# Core data processing
numpy==1.24.3
pandas==2.0.3
polars==0.18.15

# SQL and databases
duckdb==0.8.1
psycopg2-binary==2.9.6

# Data validation
pandera==0.16.1
pydantic==2.0.3

# Visualization
matplotlib==3.7.2
seaborn==0.12.2
plotly==5.15.0
altair==5.0.1

# Statistics
scipy==1.11.1
statsmodels==0.14.0
scikit-learn==1.3.0

# Utilities
python-dotenv==1.0.0
jupyter==1.0.0
pytest==7.4.0
black==23.7.0
```

### 📘 PostgreSQL Setup

```bash
# Docker (easiest)
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=data_engineering \
  -p 5432:5432 \
  postgres:15

# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo -u postgres psql -c "CREATE DATABASE data_engineering;"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# macOS (Homebrew)
brew install postgresql@15
brew services start postgresql@15
createdb data_engineering
```

---

## N14: Jupyter Notebook Tips

### 📘 Magic Commands

```python
# Timing
%time code                # Time single run
%timeit code              # Time multiple runs

# Memory
%load_ext memory_profiler # Load memory profiler
%memit code               # Measure memory usage

# System
%cd /path                # Change directory
%ls                      # List files
%pwd                     # Print working directory

# Variables
%who                     # List variables
%reset                   # Reset namespace

# Scripts
%run script.py           # Run Python script

# Display
%%capture                # Capture output
```

### 📘 Jupyter Extensions

```bash
# Install
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user

# Enable useful extensions
jupyter nbextension enable codefolding/main
jupyter nbextension enable toc2/main
jupyter nbextension enable collapsible_headings/main
```

---

## N15: Common Data Formats

### 📘 File Format Comparison

| Format | Best For | Pros | Cons |
|--------|----------|------|------|
| CSV | Small data, human-readable | Universal support | Slow, large |
| Parquet | Large datasets | Fast, compressed | Less universal |
| JSON | Nested data | Human-readable | Large, slow |
| Pickle | Python objects | Fast | Python-only |
| Feather | Fast I/O | Very fast | Limited support |

### 📘 Reading/Writing Examples

```python
import pandas as pd

# CSV
df = pd.read_csv('file.csv')
df.to_csv('output.csv', index=False)

# Parquet
df = pd.read_parquet('file.parquet')
df.to_parquet('output.parquet')

# Excel
df = pd.read_excel('file.xlsx')
df.to_excel('output.xlsx', index=False)

# JSON
df = pd.read_json('file.json')
df.to_json('output.json')

# Feather
df = pd.read_feather('file.feather')
df.to_feather('output.feather')

# Pickle
df = pd.read_pickle('file.pkl')
df.to_pickle('output.pkl')
```

---

## N16: Quick Reference: Common Patterns

### 📘 ETL Pipeline Pattern

```python
class ETLPipeline:
    def __init__(self, config):
        self.config = config
    
    def extract(self):
        # Load data from source
        pass
    
    def transform(self, data):
        # Clean and transform
        pass
    
    def load(self, data):
        # Save to destination
        pass
    
    def run(self):
        data = self.extract()
        data = self.transform(data)
        self.load(data)
        return data
```

### 📘 Data Validation Pattern

```python
def validate_data(df):
    # 1. Check schema
    # 2. Check missing values
    # 3. Check duplicates
    # 4. Check outliers
    # 5. Return validation report
    pass
```

### 📘 Hypothesis Testing Pattern

```python
def run_hypothesis_test(group1, group2):
    # 1. Check assumptions
    # 2. Choose appropriate test
    # 3. Calculate test statistic
    # 4. Compute p-value
    # 5. Make decision
    # 6. Report effect size
    pass
```

### 📘 Visualization Pattern

```python
def create_visualization(df):
    # 1. Set up figure
    # 2. Create plots
    # 3. Add labels and titles
    # 4. Customize style
    # 5. Save or display
    pass
```

---

## N17: Cheat Sheet: Test Selection

### Which Statistical Test to Use?

| Research Question | Test | When to Use |
|-------------------|------|-------------|
| Sample mean vs hypothesized | One-sample t-test | Normal data |
| Two independent groups | Independent t-test | Normal data |
| Two paired groups | Paired t-test | Normal data, paired |
| Three+ groups | ANOVA | Normal data |
| Two groups (non-normal) | Mann-Whitney U | Non-normal |
| Two paired (non-normal) | Wilcoxon signed-rank | Non-normal, paired |
| Three+ groups (non-normal) | Kruskal-Wallis | Non-normal |
| Categorical association | Chi-square | Count data |
| Linear relationship | Pearson | Normal, linear |
| Monotonic relationship | Spearman | Non-normal, monotonic |

### Effect Size Interpretation (Cohen's d)

| Effect Size | Interpretation |
|-------------|----------------|
| d = 0.2 | Small effect |
| d = 0.5 | Medium effect |
| d = 0.8 | Large effect |

---

## N18: Quick Reference: Common Errors

### 📘 Python Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `ModuleNotFoundError` | Package not installed | `pip install package` |
| `ImportError` | Can't import module | Check import path |
| `KeyError` | Key not in dict | Use `.get()` or check key |
| `IndexError` | Index out of range | Check list length |
| `ValueError` | Wrong value | Check input format |
| `TypeError` | Wrong type | Check data types |
| `MemoryError` | Out of memory | Use chunking, reduce data |

### 📘 Database Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `Connection refused` | DB not running | Start PostgreSQL/DuckDB |
| `Authentication failed` | Wrong credentials | Check .env file |
| `Relation does not exist` | Table missing | Create table first |
| `Unique violation` | Duplicate key | Check unique constraint |

### 📘 Git Errors

| Error | Meaning | Solution |
|-------|---------|----------|
| `Updates were rejected` | Remote has changes | `git pull` first |
| `Cannot delete branch` | Not merged | `git branch -D` (force) |
| `Detached HEAD` | Not on branch | `git checkout main` |
| `Merge conflict` | Conflicting changes | Resolve conflicts manually |

---

## N19: Quick Reference: Keyboard Shortcuts

### 📘 Jupyter Notebook

| Shortcut | Action |
|----------|--------|
| `Shift + Enter` | Run cell, select below |
| `Ctrl + Enter` | Run cell |
| `Alt + Enter` | Run cell, insert below |
| `Esc` | Enter command mode |
| `Enter` | Enter edit mode |
| `A` | Insert cell above |
| `B` | Insert cell below |
| `D + D` | Delete cell |
| `Z` | Undo cell deletion |
| `M` | Change to Markdown |
| `Y` | Change to Code |
| `Shift + Tab` | Documentation |

### 📘 VS Code

| Shortcut | Action |
|----------|--------|
| `Ctrl + P` | Quick open file |
| `Ctrl + Shift + P` | Command palette |
| `Ctrl + /` | Toggle comment |
| `Shift + Alt + Down` | Copy line down |
| `Ctrl + D` | Select next occurrence |
| `Ctrl + Shift + F` | Find in files |
| `F5` | Run debugging |
| `Ctrl + '` | Open terminal |

---

## N20: Final Checklist

### Before Starting a Project
- [ ] Define the problem clearly
- [ ] Identify data sources
- [ ] Plan the analysis approach
- [ ] Set up environment (venv, packages)
- [ ] Initialize Git repository

### During Development
- [ ] Write clean, documented code
- [ ] Use meaningful variable names
- [ ] Handle errors gracefully
- [ ] Test as you go
- [ ] Commit regularly with descriptive messages

### Before Finishing
- [ ] Run all tests
- [ ] Document the project (README)
- [ ] Clean up notebooks
- [ ] Export requirements
- [ ] Push to remote repository

---

## Quick Reference: Most Used Commands

### Python
```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import statsmodels.api as sm
```

### Pandas
```python
df = pd.read_csv('file.csv')
df.head()
df.info()
df.describe()
df.groupby('col').mean()
df.isna().sum()
df.fillna(0)
```

### Plotting
```python
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(x, y)
ax.scatter(x, y)
sns.histplot(data)
plt.savefig('figure.png')
```

### Git
```bash
git status
git add .
git commit -m "message"
git push origin main
git pull origin main
```

---

**[STUDENT NOTES COMPLETE]**  
**[END OF ALL STUDENT MATERIALS]**

---

## 🎓 Summary of Student Materials

| Material | Purpose | Status |
|----------|---------|--------|
| Student Workbook | Hands-on exercises | ✅ Complete |
| Student Notes | Quick reference | ✅ Complete |

---

**You now have a complete set of learning materials:**

1. **Main Series** - Comprehensive tutorials (3 Phases, 9 Modules, 3 Capstones)
2. **Primers** - Foundational knowledge (SQL, Python, Statistics, Git)
3. **Appendices** - Reference material (API docs, pitfalls, setup, glossary)
4. **Student Workbook** - 70+ practice exercises with solutions
5. **Student Notes** - Quick reference companion
