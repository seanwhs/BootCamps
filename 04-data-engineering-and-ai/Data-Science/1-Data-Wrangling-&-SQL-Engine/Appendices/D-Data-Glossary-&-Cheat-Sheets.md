# APPENDIX D: Data Glossary & Cheat Sheets

This appendix serves as your comprehensive reference for data science terminology, key formulas, and quick-reference cheat sheets for the most common operations. Keep this handy as you work through the series and beyond.

---

## D.1 Core Data Science Glossary

### Data Types & Structures

| Term | Definition | Example |
|------|------------|---------|
| **Structured Data** | Organized in rows and columns (tabular) | SQL databases, CSVs |
| **Unstructured Data** | No predefined format | Text, images, audio |
| **Semi-structured Data** | Has structure but not tabular | JSON, XML |
| **Categorical Data** | Represents categories or groups | "Red", "Blue", "Green" |
| **Ordinal Data** | Categories with meaningful order | "Small", "Medium", "Large" |
| **Numerical Data** | Quantitative measurements | 25, 3.14, -7.2 |
| **Discrete Data** | Countable, integer values | Number of purchases |
| **Continuous Data** | Infinite possible values | Temperature, time |
| **Time Series Data** | Sequential data points over time | Stock prices, daily sales |
| **Panel Data** | Multi-dimensional time series | Multiple countries over years |

### Statistical Terms

| Term | Definition | Formula |
|------|------------|---------|
| **Mean** | Average value | Σx / n |
| **Median** | Middle value | 50th percentile |
| **Mode** | Most frequent value | Value with highest frequency |
| **Variance** | Average squared deviation | Σ(x - μ)² / n |
| **Standard Deviation** | Square root of variance | √variance |
| **Skewness** | Asymmetry of distribution | E[(X-μ)/σ]³ |
| **Kurtosis** | Tailedness of distribution | E[(X-μ)/σ]⁴ - 3 |
| **Covariance** | How two variables change together | Σ(x - μx)(y - μy) / n |
| **Correlation** | Normalized covariance | Cov(X,Y) / (σx * σy) |
| **Percentile** | Value below which p% of data falls | Q1 = 25th percentile |
| **Interquartile Range (IQR)** | Q3 - Q1 | Spread of middle 50% |
| **Effect Size** | Magnitude of difference | Cohen's d, η² |

### Machine Learning Terms

| Term | Definition |
|------|------------|
| **Supervised Learning** | Learning from labeled data |
| **Unsupervised Learning** | Finding patterns in unlabeled data |
| **Reinforcement Learning** | Learning through trial and error |
| **Feature** | Input variable used for prediction |
| **Target** | Output variable to predict |
| **Training Set** | Data used to train model |
| **Test Set** | Data used to evaluate model |
| **Overfitting** | Model learns noise, not signal |
| **Underfitting** | Model too simple for data |
| **Bias** | Error from model assumptions |
| **Variance** | Error from model sensitivity |
| **Cross-Validation** | Repeated train/test splits |

### Database Terms

| Term | Definition |
|------|------------|
| **OLTP** | Online Transaction Processing (write-heavy) |
| **OLAP** | Online Analytical Processing (read-heavy) |
| **ACID** | Atomicity, Consistency, Isolation, Durability |
| **Normalization** | Organizing data to reduce redundancy |
| **Denormalization** | Combining data for performance |
| **Index** | Data structure for faster queries |
| **Primary Key** | Unique identifier for a row |
| **Foreign Key** | Reference to primary key in another table |
| **Join** | Combining tables based on keys |
| **View** | Virtual table from a query |
| **Materialized View** | Stored view results for performance |

### Data Quality Terms

| Term | Definition |
|------|------------|
| **MCAR** | Missing Completely at Random |
| **MAR** | Missing at Random |
| **MNAR** | Missing Not at Random |
| **Data Drift** | Change in data distribution over time |
| **Schema Drift** | Change in data structure over time |
| **Imputation** | Filling missing values |
| **Outlier** | Unusual data point far from others |
| **Duplicate** | Same record appearing multiple times |
| **Data Lineage** | Tracking data from source to use |

### Hypothesis Testing Terms

| Term | Definition |
|------|------------|
| **Null Hypothesis (H₀)** | No effect, default assumption |
| **Alternative Hypothesis (H₁)** | There is an effect |
| **Type I Error** | False positive (α) |
| **Type II Error** | False negative (β) |
| **Power** | 1 - β, probability of detecting effect |
| **P-value** | Probability under H₀ |
| **Significance Level (α)** | Threshold for rejection (0.05) |
| **Confidence Interval** | Range of plausible values |
| **Effect Size** | Practical significance |

---

## D.2 Key Formulas Cheat Sheet

### Descriptive Statistics

```
Mean: μ = Σx / n

Population Variance: σ² = Σ(x - μ)² / n
Sample Variance: s² = Σ(x - x̄)² / (n - 1)

Population Std: σ = √σ²
Sample Std: s = √s²

Skewness: Skew = E[(X-μ)/σ]³
Kurtosis: Kurt = E[(X-μ)/σ]⁴ - 3

Percentile: Value = (p/100) * (n + 1)th order statistic
IQR = Q3 - Q1

Outlier Bounds: Q1 - 1.5*IQR, Q3 + 1.5*IQR
```

### Probability

```
P(A or B) = P(A) + P(B) - P(A and B)
P(A and B) = P(A) * P(B)  [if independent]
P(A|B) = P(A and B) / P(B)  [conditional]
Bayes: P(A|B) = P(B|A) * P(A) / P(B)

Binomial: P(X=k) = C(n,k) * p^k * (1-p)^(n-k)
Poisson: P(X=k) = (λ^k * e^(-λ)) / k!
Normal: f(x) = (1/√(2πσ²)) * e^(-(x-μ)²/(2σ²))
```

### Statistical Tests

```
t-test (independent): t = (x̄₁ - x̄₂) / √(s₁²/n₁ + s₂²/n₂)
paired t-test: t = d̄ / (sd / √n)

Chi-square: χ² = Σ (O - E)² / E
ANOVA F-statistic: F = MS_between / MS_within

Cohen's d: d = (mean₁ - mean₂) / pooled_sd
Standard Error: SE = σ / √n
Margin of Error: ME = z * SE

Confidence Interval: estimate ± ME
```

### Power Analysis

```
Required sample size (t-test):
n = ( (z_α + z_β)² * (σ₁² + σ₂²) ) / (μ₁ - μ₂)²

Required sample size (proportions):
n = ( (z_α + z_β)² * (p₁(1-p₁) + p₂(1-p₂)) ) / (p₁ - p₂)²
```

### Linear Regression

```
Model: y = β₀ + β₁x₁ + β₂x₂ + ... + ε

OLS Solution: β = (X'X)⁻¹X'y

R² = 1 - SS_residual / SS_total
Adjusted R² = 1 - (1-R²)(n-1)/(n-k-1)

Standard Error of β: SE(β) = √(MSE * (X'X)⁻¹)
t-statistic: t = β / SE(β)
F-statistic: F = (SS_regression / k) / (SS_residual / (n-k-1))
```

### Logistic Regression

```
P(Y=1) = 1 / (1 + e^(-z))  where z = β₀ + β₁x₁ + ...

Log-odds: ln(P/(1-P)) = z

Odds = P/(1-P)
Odds Ratio = odds₁ / odds₂

MLE: Maximize Σ[ yᵢ*ln(pᵢ) + (1-yᵢ)*ln(1-pᵢ) ]
```

---

## D.3 SQL Quick Reference

### Basic Query Structure

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

### Common Clauses

| Clause | Purpose | Example |
|--------|---------|---------|
| `SELECT` | Choose columns | `SELECT name, age` |
| `DISTINCT` | Unique values | `SELECT DISTINCT category` |
| `WHERE` | Filter rows | `WHERE age > 30` |
| `IN` | Multiple values | `WHERE region IN ('A', 'B')` |
| `BETWEEN` | Range | `WHERE age BETWEEN 18 AND 65` |
| `LIKE` | Pattern matching | `WHERE name LIKE 'J%'` |
| `ORDER BY` | Sort results | `ORDER BY age DESC` |
| `GROUP BY` | Group rows | `GROUP BY category` |
| `HAVING` | Filter groups | `HAVING COUNT(*) > 5` |
| `LIMIT` | Row limit | `LIMIT 100` |
| `OFFSET` | Skip rows | `OFFSET 10` |

### Window Functions

```sql
-- Ranking
ROW_NUMBER() OVER (PARTITION BY category ORDER BY value)
RANK() OVER (PARTITION BY category ORDER BY value)
DENSE_RANK() OVER (PARTITION BY category ORDER BY value)

-- Aggregation
SUM(value) OVER (PARTITION BY category)
AVG(value) OVER (PARTITION BY category ORDER BY date ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING)

-- Lag/Lead
LAG(value, 1) OVER (ORDER BY date)
LEAD(value, 1) OVER (ORDER BY date)

-- Cumulative
SUM(value) OVER (ORDER BY date)
COUNT(*) OVER (ORDER BY date)
```

### CTEs (Common Table Expressions)

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
WITH RECURSIVE cte AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 10
)
SELECT * FROM cte;
```

---

## D.4 Python/Pandas Quick Reference

### Common Pandas Operations

```python
# Read data
df = pd.read_csv('file.csv')
df = pd.read_parquet('file.parquet')
df = pd.read_excel('file.xlsx')
df = pd.read_sql('SELECT * FROM table', conn)

# Write data
df.to_csv('file.csv', index=False)
df.to_parquet('file.parquet')
df.to_excel('file.xlsx', index=False)

# View data
df.head(5)
df.tail(5)
df.sample(10)
df.info()
df.describe()

# Select columns
df['column']
df[['col1', 'col2']]

# Filter rows
df[df['age'] > 30]
df.query('age > 30 and income > 50000')
df.loc[df['age'] > 30, ['name', 'age']]

# Add columns
df['new_col'] = df['col1'] + df['col2']
df = df.assign(new_col=df['col1'] * df['col2'])

# Aggregations
df.groupby('category')['value'].mean()
df.groupby('category').agg(['mean', 'std', 'count'])
df.pivot_table(values='value', index='category', columns='region', aggfunc='mean')

# Merge
pd.merge(df1, df2, on='key')
pd.merge(df1, df2, on='key', how='left')
pd.concat([df1, df2], axis=0)  # Rows
pd.concat([df1, df2], axis=1)  # Columns

# Handle missing values
df.isna().sum()
df.dropna()
df.fillna(0)
df.fillna(df.mean())

# Categorical
df['col'] = df['col'].astype('category')
df['col'].cat.codes
```

---

## D.5 Data Visualization Quick Reference

### Chart Selection Guide

| Goal | Chart Type | Library |
|------|------------|---------|
| Show distribution | Histogram, KDE | Seaborn/Plotly |
| Compare groups | Box plot, Violin | Seaborn/Plotly |
| Show relationships | Scatter plot | Matplotlib/Plotly |
| Show trend over time | Line chart | Matplotlib/Plotly |
| Show proportions | Pie chart, Bar | Matplotlib/Plotly |
| Show correlations | Heatmap | Seaborn/Plotly |
| Show multiple distributions | Pair plot | Seaborn |
| Explore interactively | All charts | Plotly |
| Simple web display | All charts | Altair |

### Common Color Palettes

```python
# Sequential (ordered data)
cmap = 'Blues'      # Single color, increasing intensity
cmap = 'viridis'    # Perceptually uniform

# Diverging (data with midpoint)
cmap = 'RdBu'       # Red to blue with white midpoint
cmap = 'coolwarm'   # Cool to warm colors

# Qualitative (categorical)
palette = 'husl'    # Distinct colors
palette = 'colorblind'  # Colorblind-safe
palette = 'Set1'    # Bright, distinct

# Custom
from matplotlib.colors import LinearSegmentedColormap
colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7']
cmap = LinearSegmentedColormap.from_list('custom', colors)
```

---

## D.6 Statistical Test Decision Tree

### Which Test Should I Use?

```
                    ┌─ CONTINUOUS TARGET ─┐
                    │                     │
              ┌─────▼──────┐        ┌────▼────┐
              │ PREDICTORS │        │  CHURN  │
              └─────┬──────┘        └────┬────┘
                    │                    │
        ┌───────────┼───────────┐       │
        ▼           ▼           ▼       ▼
    1 PREDICTOR  2 GROUPS    3+ GROUPS  (Logistic Regression)
        │           │           │
        ▼           ▼           ▼
   Correlation  t-test      ANOVA
   (Pearson)   (or Mann-    (or Kruskal-
                Whitney)     Wallis)
```

**Flowchart:**
```
Is target continuous?
├─ YES: Is it comparing groups?
│  ├─ 1 group vs hypothesized: → One-sample t-test
│  ├─ 2 independent groups: → Independent t-test
│  ├─ 2 paired groups: → Paired t-test
│  ├─ 3+ groups: → ANOVA
│  └─ Continuous predictors: → Correlation/Regression
├─ NO (categorical/binary):
│  ├─ 2 categories: → Chi-square test
│  ├─ 3+ categories: → Chi-square test
│  └─ With continuous predictors: → Logistic Regression
└─ Is data non-normal?
   ├─ 2 independent groups: → Mann-Whitney
   ├─ 2 paired groups: → Wilcoxon
   └─ 3+ groups: → Kruskal-Wallis
```

---

## D.7 Performance Optimization Cheat Sheet

### Processing Large Data

| Issue | Solution |
|-------|----------|
| Slow Python loops | Use vectorized operations |
| Pandas too slow | Use Polars |
| SQL too slow | Add indexes |
| Memory errors | Use chunking, lazy evaluation |
| Slow grouping | Use `.transform()` instead of `.apply()` |
| Slow joins | Use merge with indexes |
| Slow string ops | Use `.str.` methods |

### Memory Optimization

```python
# 1. Downcast numeric types
df['int_col'] = pd.to_numeric(df['int_col'], downcast='integer')
df['float_col'] = pd.to_numeric(df['float_col'], downcast='float')

# 2. Use categorical for strings
df['cat_col'] = df['cat_col'].astype('category')

# 3. Select only needed columns
df = pd.read_csv('file.csv', usecols=['col1', 'col2'])

# 4. Use sparse if many zeros
df_sparse = df.astype(pd.SparseDtype('float', 0))

# 5. Clear memory
del df
import gc
gc.collect()
```

---

## D.8 Command Quick Reference

### Terminal Commands

```bash
# Navigation
cd /path/to/directory    # Change directory
ls / dir                 # List files
pwd                      # Print working directory

# Virtual Environment
python3 -m venv venv     # Create venv
source venv/bin/activate # Activate (Linux/macOS)
venv\Scripts\activate    # Activate (Windows)
deactivate               # Deactivate

# Package Management
pip install package      # Install package
pip uninstall package    # Uninstall
pip list                 # List installed
pip freeze > req.txt     # Export requirements

# File Operations
cp source destination    # Copy
mv source destination    # Move
rm file                  # Remove file
rm -rf directory         # Remove directory
mkdir directory          # Create directory
touch file               # Create empty file

# Git
git init                 # Initialize repo
git add .                # Stage all changes
git commit -m "message"  # Commit
git push                 # Push to remote
git pull                 # Pull from remote
git status               # Check status
git log                  # View history
```

### Jupyter Commands

```python
# Magic commands
%run script.py          # Run Python script
%timeit code            # Time execution
%time code              # Time single run
%load_ext memory_profiler  # Load memory profiler
%memit code             # Measure memory
%cd /path               # Change directory
%ls                     # List files
%pwd                    # Print working directory
%who                    # List variables
%reset                  # Reset namespace

# Display
display(df)             # Display DataFrame
print()                 # Print to console
%%capture               # Capture output
```

### Database Commands (PostgreSQL)

```sql
-- Connect
psql -U postgres -d database_name

-- Meta commands
\l          -- List databases
\c dbname   -- Connect to database
\dt         -- List tables
\d table    -- Describe table
\q          -- Quit

-- Common queries
CREATE DATABASE dbname;
DROP TABLE tablename;
CREATE INDEX idx_name ON table (column);
EXPLAIN ANALYZE SELECT ...;
```

---

## D.9 Quick Reference: Common Data Formats

### File Formats Comparison

| Format | Best For | Pros | Cons |
|--------|----------|------|------|
| **CSV** | Small data, human-readable | Universal support | Slow, large |
| **Parquet** | Large datasets | Fast, compressed | Less universal |
| **JSON** | Nested data | Human-readable | Large, slow |
| **Pickle** | Python objects | Fast | Python-only |
| **Feather** | Fast I/O | Very fast | Limited support |
| **SQLite** | Small to medium DB | Relational | Single-threaded |

### File Size Estimates

```
CSV ~ 100 MB for 1M rows × 10 columns
Parquet ~ 20-30 MB (70-80% compression)
JSON ~ 150-200 MB (larger than CSV)
Feather ~ 30-40 MB (similar to Parquet)
```

---

## D.10 Common Regular Expressions

### Regex Patterns for Data Cleaning

```python
# Email validation
email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

# Phone (US)
phone_pattern = r'^\(?([0-9]{3})\)?[-.●]?([0-9]{3})[-.●]?([0-9]{4})$'

# Date (YYYY-MM-DD)
date_pattern = r'^\d{4}-\d{2}-\d{2}$'

# URL
url_pattern = r'^https?://[^\s]+$'

# ZIP code (US)
zip_pattern = r'^\d{5}(-\d{4})?$'

# SSN (US)
ssn_pattern = r'^\d{3}-\d{2}-\d{4}$'

# IP Address
ip_pattern = r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'
```

---

**[APPENDIX D COMPLETE]**  
