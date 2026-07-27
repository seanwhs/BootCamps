# APPENDIX B: Common Pitfalls & How to Avoid Them

This appendix catalogs the most frequent mistakes data scientists and engineers make—and more importantly, how to avoid them. Each pitfall includes a real-world example, the underlying cause, and practical solutions.

---

## B.1 Data Processing Pitfalls

### Pitfall 1: Using `iterrows()` in Pandas

**The Problem:**
```python
# ❌ SLOW - This will kill performance for large datasets
total = 0
for idx, row in df.iterrows():
    total += row['value'] * row['weight']
```

**Why It's Bad:**
- `iterrows()` creates a new Series object for each row
- Each iteration involves Python-level overhead
- 100x-1000x slower than vectorized operations

**The Fix:**
```python
# ✅ FAST - Vectorized operation
total = (df['value'] * df['weight']).sum()

# Or if you need a more complex operation:
total = df.apply(lambda x: x['value'] * x['weight'], axis=1).sum()
# Still slower than pure vectorization, but better than iterrows()
```

**Memory Impact:**
- `iterrows()` uses ~10x more memory during iteration
- Vectorized operations use contiguous memory blocks

---

### Pitfall 2: Chained Indexing in Pandas

**The Problem:**
```python
# ❌ BAD - This creates a view and may not work
df[df['age'] > 30]['income'] = df[df['age'] > 30]['income'] * 1.1

# This raises a SettingWithCopyWarning
```

**Why It's Bad:**
- Chained indexing creates intermediate copies
- Pandas can't determine if you're modifying a view or a copy
- The assignment may silently fail

**The Fix:**
```python
# ✅ GOOD - Use .loc for assignments
df.loc[df['age'] > 30, 'income'] = df.loc[df['age'] > 30, 'income'] * 1.1

# ✅ GOOD - Use .copy() if you need an independent copy
df_filtered = df[df['age'] > 30].copy()
df_filtered['income'] = df_filtered['income'] * 1.1
```

**Detection:**
```python
# Check if something is a view or a copy
df.is_copy  # Returns None if not a copy
```

---

### Pitfall 3: Not Optimizing Data Types

**The Problem:**
```python
# ❌ BAD - Using object dtype unnecessarily
df = pd.DataFrame({
    'category': ['A', 'B', 'C'] * 100000,  # object dtype
    'value': np.random.randn(300000)        # float64
})
# Memory usage: ~25 MB for the category column
```

**Why It's Bad:**
- Object dtypes store pointers to Python objects
- Each string is a separate Python object
- Uses 8x more memory than categorical

**The Fix:**
```python
# ✅ GOOD - Use categorical dtype
df['category'] = df['category'].astype('category')
# Memory usage: ~3 MB for the category column

# ✅ GOOD - Use smaller integer types
df['small_int'] = df['small_int'].astype('int32')  # instead of int64
df['small_float'] = df['small_float'].astype('float32')  # instead of float64
```

**Memory Savings:**
- Category: 70-90% reduction for high-cardinality strings
- int32: 50% reduction from int64
- float32: 50% reduction from float64

---

### Pitfall 4: Loading Entire Datasets into Memory

**The Problem:**
```python
# ❌ BAD - Loading a 10GB file into memory
df = pd.read_csv('huge_file.csv')  # This will crash if memory < 10GB
```

**Why It's Bad:**
- Pandas loads everything into memory at once
- Can cause memory errors or system crashes
- Wastes memory on data you might not need

**The Fix:**
```python
# ✅ GOOD - Use chunking
chunk_size = 100000
for chunk in pd.read_csv('huge_file.csv', chunksize=chunk_size):
    # Process each chunk
    process_chunk(chunk)

# ✅ GOOD - Use Polars lazy evaluation
df = pl.scan_csv('huge_file.csv')
result = df.filter(pl.col('value') > 0).collect()

# ✅ GOOD - Use DuckDB querying files directly
conn = duckdb.connect(':memory:')
result = conn.execute("""
    SELECT *
    FROM 'huge_file.csv'
    WHERE value > 0
""").fetchdf()

# ✅ GOOD - Use dtypes and only needed columns
df = pd.read_csv('huge_file.csv',
                 usecols=['id', 'value', 'date'],
                 dtype={'id': 'int32', 'value': 'float32'})
```

---

## B.2 SQL Pitfalls

### Pitfall 5: SELECT *

**The Problem:**
```sql
-- ❌ BAD - Selecting all columns
SELECT * FROM orders 
JOIN customers ON orders.customer_id = customers.customer_id
WHERE order_date > '2025-01-01'
```

**Why It's Bad:**
- Returns unnecessary columns (wastes bandwidth and memory)
- Prevents index-only scans
- Makes query plans less efficient

**The Fix:**
```sql
-- ✅ GOOD - Select only needed columns
SELECT 
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date > '2025-01-01'
```

---

### Pitfall 6: Missing Indexes

**The Problem:**
```sql
-- ❌ BAD - No indexes on frequently queried columns
-- Query: Find orders from last 7 days
SELECT * FROM orders 
WHERE order_date > CURRENT_DATE - INTERVAL '7 days'
-- This will scan the entire table (full table scan)
```

**Why It's Bad:**
- Full table scans for large tables are extremely slow
- Indexes can reduce query time from seconds to milliseconds

**The Fix:**
```sql
-- ✅ GOOD - Create appropriate indexes
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- ✅ GOOD - Composite index for multi-column filters
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);

-- ✅ GOOD - Partial index for specific queries
CREATE INDEX idx_orders_recent ON orders(order_date)
WHERE order_date > CURRENT_DATE - INTERVAL '30 days';
```

**Index Selection Guidelines:**
- B-Tree: Equality and range queries (<, >, BETWEEN)
- GIN: Full-text search, array operations
- BRIN: Very large tables with linear data (like dates)

---

### Pitfall 7: Not Using EXPLAIN ANALYZE

**The Problem:**
```sql
-- ❌ BAD - Running queries without understanding execution plan
SELECT * FROM orders JOIN customers ON orders.customer_id = customers.customer_id;
```

**Why It's Bad:**
- You don't know if indexes are being used
- You don't know where the bottleneck is
- You're optimizing blindly

**The Fix:**
```sql
-- ✅ GOOD - Use EXPLAIN ANALYZE to understand
EXPLAIN ANALYZE
SELECT * FROM orders 
JOIN customers ON orders.customer_id = customers.customer_id;

-- Look for:
-- 1. "Seq Scan" → needs an index
-- 2. "Index Scan" → good, using index
-- 3. "Nested Loop" → may be inefficient for large datasets
-- 4. "Hash Join" → usually efficient
```

---

## B.3 Visualization Pitfalls

### Pitfall 8: Misleading Axes

**The Problem:**
```python
# ❌ BAD - Truncated y-axis exaggerates differences
plt.bar(['A', 'B', 'C'], [50, 52, 55])
plt.ylim(45, 60)  # This exaggerates the differences
```

**Why It's Bad:**
- Truncated axes distort visual perception
- Small differences appear large
- Misleads viewers about the magnitude of effects

**The Fix:**
```python
# ✅ GOOD - Start y-axis at 0
plt.bar(['A', 'B', 'C'], [50, 52, 55])
plt.ylim(0, 60)

# ✅ GOOD - Or clearly indicate the truncation
plt.bar(['A', 'B', 'C'], [50, 52, 55])
plt.ylim(45, 60)
plt.axhline(y=45, color='black', linestyle='--', label='Truncated axis')
```

**Guidelines:**
- Always start bar charts at 0
- For line charts, consider using appropriate scales
- If you must truncate, clearly indicate it

---

### Pitfall 9: Too Many Colors

**The Problem:**
```python
# ❌ BAD - Too many colors = unreadable
sns.scatterplot(x='x', y='y', hue='id', data=df)  # 1000 unique IDs → 1000 colors
```

**Why It's Bad:**
- More than 7-10 colors becomes unreadable
- Color vision deficiency (CVD) makes some colors indistinguishable
- Creates visual noise

**The Fix:**
```python
# ✅ GOOD - Use categorical or continuous
sns.scatterplot(x='x', y='y', hue='category', data=df)  # Few categories

# ✅ GOOD - Use size instead of color
sns.scatterplot(x='x', y='y', size='value', data=df)

# ✅ GOOD - Use colorblind-friendly palettes
sns.color_palette("colorblind")
sns.color_palette("viridis")

# ✅ GOOD - Limit categories
top_categories = df['category'].value_counts().head(8).index
df_filtered = df[df['category'].isin(top_categories)]
```

---

### Pitfall 10: Overplotting

**The Problem:**
```python
# ❌ BAD - 100,000 points plotted on top of each other
plt.scatter(x, y, alpha=1.0)  # All points opaque
```

**Why It's Bad:**
- Dense data becomes a black blob
- You can't see density or patterns
- Wastes ink/pixels

**The Fix:**
```python
# ✅ GOOD - Use transparency (alpha)
plt.scatter(x, y, alpha=0.2)

# ✅ GOOD - Use 2D histogram
plt.hist2d(x, y, bins=50, cmap='Blues')
plt.colorbar()

# ✅ GOOD - Sample the data
plt.scatter(x_sample, y_sample, alpha=0.5)

# ✅ GOOD - Use hexbin
plt.hexbin(x, y, gridsize=30, cmap='Blues')
```

---

## B.4 Statistical Pitfalls

### Pitfall 11: P-Hacking (Multiple Testing)

**The Problem:**
```python
# ❌ BAD - Testing many hypotheses without correction
# Testing 100 features for correlation with target
p_values = []
for col in features:
    _, p = stats.pearsonr(df[col], df['target'])
    p_values.append(p)

# Finding "significant" results
significant = sum(p < 0.05 for p in p_values)
# ~5 features will be significant by chance alone (Type I errors)
```

**Why It's Bad:**
- Type I error rate inflates with each test
- With 100 tests, expected false positives = 5
- Results are not reproducible

**The Fix:**
```python
# ✅ GOOD - Bonferroni correction
alpha = 0.05 / len(features)  # Very conservative
significant = [p < alpha for p in p_values]

# ✅ GOOD - False Discovery Rate (FDR)
from statsmodels.stats.multitest import multipletests
rejected, p_adjusted, _, _ = multipletests(p_values, alpha=0.05, method='fdr_bh')

# ✅ GOOD - Pre-register hypotheses
# Only test what you planned to test
```

---

### Pitfall 12: Ignoring Assumptions

**The Problem:**
```python
# ❌ BAD - Running a t-test on non-normal data
# Data is exponentially distributed (skewed)
data = np.random.exponential(10, 100)
t_stat, p = stats.ttest_1samp(data, 10)  # Wrong!
```

**Why It's Bad:**
- Parametric tests assume normality
- Violating assumptions gives unreliable p-values
- May miss real effects or find false effects

**The Fix:**
```python
# ✅ GOOD - Check assumptions first
# 1. Visual check
plt.hist(data)
plt.show()

# 2. Statistical test
shapiro_stat, shapiro_p = stats.shapiro(data)

# 3. Use appropriate test
if shapiro_p > 0.05:
    # Normal → use parametric test
    t_stat, p = stats.ttest_1samp(data, 10)
else:
    # Non-normal → use non-parametric test
    # (Wilcoxon signed-rank test for one sample)
    w_stat, p = stats.wilcoxon(data - 10)
```

**Assumption Cheat Sheet:**

| Test | Assumptions | What to Check |
|------|-------------|---------------|
| t-test | Normality | Shapiro-Wilk, Q-Q plot |
| ANOVA | Normality, Homogeneity | Shapiro-Wilk, Levene's test |
| Linear Regression | Normality, Homoscedasticity | Shapiro-Wilk, Breusch-Pagan |
| Chi-square | Expected counts > 5 | Check contingency table |

---

### Pitfall 13: Confusing Correlation with Causation

**The Problem:**
```python
# ❌ BAD - Finding a correlation and claiming causation
corr, p = stats.pearsonr(df['ice_cream_sales'], df['shark_attacks'])
# corr = 0.80, p < 0.001
print("Ice cream causes shark attacks!")  # WRONG!
```

**Why It's Bad:**
- Correlation only measures association
- Confounding variables often explain the relationship
- Leads to incorrect business decisions

**The Fix:**
```python
# ✅ GOOD - Consider the "why" (domain knowledge)
# Ice cream sales and shark attacks are correlated because both
# increase in summer (confounding variable: temperature)

# ✅ GOOD - Use causal inference methods
# 1. A/B testing: Randomize treatment
# 2. Difference-in-differences: Compare before/after
# 3. Instrumental variables: Use natural experiments

# ✅ GOOD - Be explicit about limitations
print("Correlation does not imply causation.")
print(f"Correlation: {corr:.3f}")
print("This is likely due to a confounding variable.")
```

**Evidence Hierarchy:**
1. **Randomized Controlled Trial** (Strongest evidence)
2. **Quasi-Experiment** (Natural experiment)
3. **Longitudinal Study** (Over time)
4. **Cross-Sectional Study** (Snapshot)
5. **Anecdote** (Weakest evidence)

---

### Pitfall 14: Reporting Only P-Values

**The Problem:**
```python
# ❌ BAD - Only reporting p-value
t_stat, p = stats.ttest_ind(group1, group2)
print(f"p = {p:.4f}")  # What does this mean in practice?
```

**Why It's Bad:**
- P-values don't tell you about practical significance
- A statistically significant result may be trivial
- You need effect size and confidence intervals

**The Fix:**
```python
# ✅ GOOD - Report effect size and confidence intervals
t_stat, p = stats.ttest_ind(group1, group2)

# Effect size (Cohen's d)
pooled_std = np.sqrt((np.std(group1, ddof=1)**2 + np.std(group2, ddof=1)**2) / 2)
cohens_d = (np.mean(group1) - np.mean(group2)) / pooled_std

# Confidence interval
ci_lower = np.mean(group1) - np.mean(group2) - 1.96 * np.sqrt(np.var(group1)/len(group1) + np.var(group2)/len(group2))
ci_upper = np.mean(group1) - np.mean(group2) + 1.96 * np.sqrt(np.var(group1)/len(group1) + np.var(group2)/len(group2))

print(f"""
Results:
  p-value: {p:.4f}
  Effect size (Cohen's d): {cohens_d:.3f}
  Mean difference: {np.mean(group1) - np.mean(group2):.2f}
  95% CI: [{ci_lower:.2f}, {ci_upper:.2f}]
""")

# Guidelines for Cohen's d:
# d = 0.2: Small effect
# d = 0.5: Medium effect
# d = 0.8: Large effect
```

**What to Report:**
1. Effect size (Cohen's d, odds ratio, correlation)
2. Confidence intervals (95% CI)
3. Sample size (N)
4. P-value (with interpretation)

---

## B.5 Modeling Pitfalls

### Pitfall 15: Overfitting

**The Problem:**
```python
# ❌ BAD - Including too many features
X = df[all_100_features]  # Including everything
model = sm.OLS(y, X).fit()
# R² = 0.99 on training data (great!)
# R² = 0.30 on test data (terrible!)
```

**Why It's Bad:**
- Model learns noise, not signal
- Won't generalize to new data
- Complex, uninterpretable

**The Fix:**
```python
# ✅ GOOD - Use train-test split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)

# ✅ GOOD - Use cross-validation
from sklearn.model_selection import cross_val_score
scores = cross_val_score(model, X, y, cv=5)

# ✅ GOOD - Use regularization
# Ridge: L2 regularization (shrinks coefficients)
# Lasso: L1 regularization (feature selection)

# ✅ GOOD - Use AIC/BIC for model selection
# Lower AIC/BIC indicates better model

# ✅ GOOD - Limit model complexity
# Rule of thumb: 10-20 samples per predictor
# or use feature selection
```

---

### Pitfall 16: Multicollinearity

**The Problem:**
```python
# ❌ BAD - Highly correlated features
df = pd.DataFrame({
    'income': income,
    'wealth': income * 10 + noise,  # Highly correlated with income
    'spending': spending
})
model = sm.OLS(y, df[['income', 'wealth', 'spending']]).fit()
# Coefficients become unstable and uninterpretable
```

**Why It's Bad:**
- Coefficients become unstable
- Small changes in data cause large coefficient changes
- Interpretation is meaningless

**The Fix:**
```python
# ✅ GOOD - Check VIF before modeling
from statsmodels.stats.outliers_influence import variance_inflation_factor

X = df[['income', 'wealth', 'spending']]
vif_data = pd.DataFrame()
vif_data['Feature'] = X.columns
vif_data['VIF'] = [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]

# VIF > 5-10 indicates multicollinearity

# ✅ GOOD - Remove or combine correlated features
# Remove one of the correlated features
df_model = df[['income', 'spending']]  # Wealth removed

# Or combine them
df['wealth_income_ratio'] = df['wealth'] / df['income']
```

---

### Pitfall 17: Not Checking Residuals

**The Problem:**
```python
# ❌ BAD - Fitting a model and never checking residuals
model = sm.OLS(y, X).fit()
print(model.summary())  # That's it!
```

**Why It's Bad:**
- Residuals reveal model violations
- Patterned residuals indicate missing relationships
- May lead to incorrect conclusions

**The Fix:**
```python
# ✅ GOOD - Always check residuals
residuals = model.resid
fitted = model.fittedvalues

# 1. Residuals vs Fitted (heteroscedasticity)
plt.scatter(fitted, residuals)
plt.axhline(y=0, color='red', linestyle='--')

# 2. Q-Q Plot (normality)
stats.probplot(residuals, dist="norm", plot=plt)

# 3. Scale-Location plot
plt.scatter(fitted, np.sqrt(np.abs(residuals)))

# 4. Residuals vs Order (independence)
plt.scatter(range(len(residuals)), residuals)

# What to look for:
# - Random scatter → good
# - Patterns or trends → problem
# - Heteroscedasticity → need robust SE or transformation
```

---

## B.6 Production Pitfalls

### Pitfall 18: Hardcoding Configuration

**The Problem:**
```python
# ❌ BAD - Hardcoded values
DATABASE = 'postgresql://user:password@localhost:5432/mydb'
CSV_PATH = '/home/user/data/input.csv'
OUTPUT_PATH = '/home/user/data/output.parquet'
THRESHOLD = 0.95
```

**Why It's Bad:**
- Can't change without modifying code
- Secrets exposed in code
- Different environments require different configs

**The Fix:**
```python
# ✅ GOOD - Use environment variables
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE = os.getenv('DATABASE_URL')
CSV_PATH = os.getenv('INPUT_PATH', 'data/input.csv')  # Default
THRESHOLD = float(os.getenv('THRESHOLD', '0.95'))  # Default

# ✅ GOOD - Use config files
import yaml
with open('config.yaml', 'r') as f:
    config = yaml.safe_load(f)
    
DATABASE = config['database']['url']
CSV_PATH = config['paths']['input']

# ✅ GOOD - Use command line arguments
import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--input', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args()
```

---

### Pitfall 19: No Error Handling

**The Problem:**
```python
# ❌ BAD - No error handling
df = pd.read_csv('data.csv')  # What if file doesn't exist?
result = process(df)           # What if processing fails?
save(result)                   # What if saving fails?
```

**Why It's Bad:**
- Pipeline fails without clear message
- Data may be partially processed (inconsistent state)
- Hard to debug in production

**The Fix:**
```python
# ✅ GOOD - Use try/except
import logging
import traceback

logger = logging.getLogger(__name__)

try:
    df = pd.read_csv('data.csv')
    logger.info(f"Loaded {len(df)} rows")
except FileNotFoundError as e:
    logger.error(f"File not found: {e}")
    raise
except Exception as e:
    logger.error(f"Error loading data: {e}")
    logger.error(traceback.format_exc())
    raise

try:
    result = process(df)
    logger.info("Processing successful")
except Exception as e:
    logger.error(f"Processing failed: {e}")
    logger.error(traceback.format_exc())
    raise

try:
    save(result)
    logger.info("Data saved successfully")
except Exception as e:
    logger.error(f"Save failed: {e}")
    logger.error(traceback.format_exc())
    raise
```

---

### Pitfall 20: Ignoring Data Quality

**The Problem:**
```python
# ❌ BAD - Processing data without validation
df = pd.read_csv('data.csv')
df_clean = df.dropna()  # Silently drops rows
model.fit(df_clean)  # May be training on 50% of data
```

**Why It's Bad:**
- Data quality issues go unnoticed
- Results may be biased
- Harder to debug issues

**The Fix:**
```python
# ✅ GOOD - Always validate data
import pandera as pa

# Define schema
class DataSchema(pa.SchemaModel):
    id: Series[int] = pa.Field(gt=0)
    value: Series[float] = pa.Field(ge=0, le=100)
    category: Series[str] = pa.Field(isin=['A', 'B', 'C'])

# Validate
try:
    DataSchema.validate(df)
    logger.info("Data validation passed")
except pa.errors.SchemaError as e:
    logger.error(f"Data validation failed: {e}")
    
    # Log failures
    failure_cases = e.failure_cases
    logger.error(f"Failure cases:\n{failure_cases}")
    
    # Handle failures
    df_clean = DataSchema.validate(df, lazy=True)
    
# Log data quality metrics
logger.info(f"""
Data Quality Report:
  Total rows: {len(df)}
  Missing values: {df.isna().sum().sum()}
  Duplicates: {df.duplicated().sum()}
  Outliers: {len(df_clean) - len(df_filtered)} 
""")
```

---

## Summary: Your Pitfall Checklist

### Before Starting
- [ ] Understand the business problem
- [ ] Check data quality
- [ ] Plan analysis approach
- [ ] Determine sample size (power analysis)

### During Processing
- [ ] Use vectorized operations (no `iterrows()`)
- [ ] Optimize data types (category, int32)
- [ ] Use chunking for large datasets
- [ ] Handle missing data appropriately
- [ ] Validate data schema

### During Visualization
- [ ] Start axes at 0 (for bars)
- [ ] Use colorblind-friendly palettes
- [ ] Avoid overplotting (use alpha, sampling)
- [ ] Label axes and add titles
- [ ] Avoid 3D charts (they distort perception)

### During Analysis
- [ ] Check assumptions before tests
- [ ] Report effect sizes and CI, not just p-values
- [ ] Correct for multiple testing
- [ ] Use train-test split for models
- [ ] Check residuals and diagnostics

### In Production
- [ ] Use environment variables for config
- [ ] Add comprehensive error handling
- [ ] Log everything
- [ ] Validate data at every step
- [ ] Monitor for data drift

---

**[APPENDIX B COMPLETE]**  
