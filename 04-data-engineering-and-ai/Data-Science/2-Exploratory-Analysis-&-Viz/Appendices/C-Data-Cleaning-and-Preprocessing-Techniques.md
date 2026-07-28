# Appendix C: Data Cleaning and Preprocessing Techniques

## Preparing Raw Data for Analysis and Modeling

---

#### Purpose of This Appendix

This appendix provides a comprehensive guide to data cleaning and preprocessing—the essential steps that transform raw, messy data into analysis-ready datasets. While our synthetic dataset was intentionally "clean" with controlled messiness, real-world data is far messier. This appendix equips you with the tools and techniques to handle:

- Missing values
- Outliers and anomalies
- Inconsistent formatting
- Duplicate records
- Data type issues
- Feature engineering for better analysis

Think of this as your data preparation survival guide. These techniques will save you countless hours and prevent analytical mistakes.

---

## C.1 The Data Cleaning Workflow

### C.1.1 The Data Cleaning Pipeline

```
Raw Data
    ↓
1. Initial Inspection
    ↓
2. Handle Missing Values
    ↓
3. Handle Duplicates
    ↓
4. Fix Data Types
    ↓
5. Handle Outliers
    ↓
6. Standardize Formats
    ↓
7. Feature Engineering
    ↓
8. Validation
    ↓
Clean Data
```

### C.1.2 Initial Data Inspection

```python
import pandas as pd
import numpy as np

def inspect_data(df):
    """Quick data inspection function."""
    
    print("=" * 60)
    print("DATA INSPECTION REPORT")
    print("=" * 60)
    
    # Basic info
    print(f"\nShape: {df.shape[0]} rows, {df.shape[1]} columns")
    print(f"\nMemory usage: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    
    # Data types
    print("\nData types:")
    print(df.dtypes)
    
    # Missing values
    missing = df.isnull().sum()
    if missing.sum() > 0:
        print("\nMissing values:")
        print(missing[missing > 0])
    else:
        print("\n✅ No missing values found")
    
    # Duplicates
    duplicates = df.duplicated().sum()
    print(f"\nDuplicate rows: {duplicates}")
    
    # Summary statistics
    print("\nSummary statistics (numerical):")
    print(df.describe())
    
    # Sample
    print("\nSample (first 5 rows):")
    print(df.head())
    
    # Unique values for categorical
    cat_cols = df.select_dtypes(include=['object']).columns
    if len(cat_cols) > 0:
        print("\nCategorical columns:")
        for col in cat_cols:
            print(f"  {col}: {df[col].nunique()} unique values")
            if df[col].nunique() < 10:
                print(f"    Values: {df[col].unique().tolist()}")

# Usage
inspect_data(df)
```

---

## C.2 Handling Missing Values

### C.2.1 Understanding Missing Data Patterns

**Types of Missing Data:**

1. **MCAR (Missing Completely at Random):** Missingness is independent of everything
   - Example: A survey respondent skips a question by accident
   - Solution: Any method works; listwise deletion is safe

2. **MAR (Missing at Random):** Missingness depends on observed data
   - Example: Women are more likely to skip income questions
   - Solution: Need to account for the pattern; imputation methods can work

3. **MNAR (Missing Not at Random):** Missingness depends on the missing value itself
   - Example: High-income individuals are less likely to report income
   - Solution: Requires careful modeling; simple imputation may bias results

**Detecting Missing Patterns:**

```python
import seaborn as sns
import matplotlib.pyplot as plt

def analyze_missing_patterns(df):
    """Analyze missing data patterns."""
    
    # Missing counts
    missing = df.isnull().sum()
    missing_pct = (missing / len(df)) * 100
    
    missing_df = pd.DataFrame({
        'Column': missing.index,
        'Missing_Count': missing.values,
        'Missing_Percent': missing_pct.values
    }).sort_values('Missing_Percent', ascending=False)
    
    print("Missing values summary:")
    print(missing_df[missing_df['Missing_Count'] > 0])
    
    # Visualize missing patterns
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    
    # Bar chart of missing values
    ax = axes[0]
    missing_df[missing_df['Missing_Count'] > 0].plot(
        x='Column', y='Missing_Count', kind='bar', ax=ax,
        color='coral', edgecolor='black'
    )
    ax.set_title('Missing Values by Column', fontsize=14)
    ax.set_ylabel('Number of Missing Values')
    
    # Missingness heatmap (sample of rows)
    ax = axes[1]
    # Sample up to 100 rows to avoid overcrowding
    sample_size = min(100, len(df))
    sample = df.iloc[:sample_size]
    sns.heatmap(sample.isnull(), cbar=True, 
                yticklabels=False, ax=ax,
                cmap=['white', 'navy'])
    ax.set_title('Missingness Pattern (First 100 Rows)', fontsize=14)
    ax.set_xlabel('Columns')
    ax.set_ylabel('Row Index')
    
    plt.tight_layout()
    plt.show()
    
    return missing_df

# Usage
missing_info = analyze_missing_patterns(df)
```

### C.2.2 Handling Missing Values: Strategies

#### Strategy 1: Deletion

**Listwise Deletion (Drop all rows with any missing):**

```python
# Drop rows with any missing values
df_complete = df.dropna()

# Drop rows where specific columns have missing values
df_subset = df.dropna(subset=['age', 'customer_rating'])

# Drop columns with too many missing values (>50%)
threshold = 0.5
df_clean = df.dropna(thresh=int(len(df) * (1 - threshold)), axis=1)
```

**When to use:**
- MCAR data
- Small percentage of missing values (<5%)
- You have enough complete cases

**When NOT to use:**
- MAR or MNAR data (introduces bias)
- Large percentage of missing values
- Small sample size

#### Strategy 2: Imputation

**Mean/Median/Mode Imputation:**

```python
# Numerical columns - mean imputation
df['age_filled'] = df['age'].fillna(df['age'].mean())

# Numerical columns - median imputation (more robust to outliers)
df['age_filled'] = df['age'].fillna(df['age'].median())

# Categorical columns - mode imputation
df['gender_filled'] = df['gender'].fillna(df['gender'].mode()[0])
```

**When to use:**
- MAR data
- Small percentage of missing values
- When you need a quick solution

**When NOT to use:**
- MNAR data
- Large percentage of missing values
- When you need to preserve variance

**Regression Imputation:**

```python
from sklearn.linear_model import LinearRegression

def regression_impute(df, target_col, feature_cols):
    """
    Impute missing values in target_col using regression on feature_cols.
    """
    # Split data into complete and missing
    complete = df[df[target_col].notna()]
    missing = df[df[target_col].isna()]
    
    if len(missing) == 0:
        return df
    
    # Train model on complete cases
    X_train = complete[feature_cols]
    y_train = complete[target_col]
    
    model = LinearRegression()
    model.fit(X_train, y_train)
    
    # Predict missing values
    X_missing = missing[feature_cols]
    predicted = model.predict(X_missing)
    
    # Fill missing values
    df.loc[df[target_col].isna(), target_col] = predicted
    
    return df

# Usage
df_imputed = regression_impute(df, 'customer_rating', 
                               ['age', 'order_frequency', 'avg_order_value'])
```

**KNN Imputation:**

```python
from sklearn.impute import KNNImputer

def knn_impute(df, cols_to_impute, n_neighbors=5):
    """
    Impute missing values using K-Nearest Neighbors.
    """
    # Select columns to impute
    data_to_impute = df[cols_to_impute].copy()
    
    # Initialize KNN imputer
    imputer = KNNImputer(n_neighbors=n_neighbors, weights='distance')
    
    # Impute
    imputed_data = imputer.fit_transform(data_to_impute)
    
    # Update DataFrame
    df_imputed = df.copy()
    for i, col in enumerate(cols_to_impute):
        df_imputed[col] = imputed_data[:, i]
    
    return df_imputed

# Usage
cols_to_impute = ['age', 'customer_rating', 'email_open_rate']
df_imputed = knn_impute(df, cols_to_impute, n_neighbors=5)
```

**Multiple Imputation (Advanced):**

```python
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

def multiple_imputation(df, cols_to_impute):
    """
    Perform multiple imputation using iterative imputer.
    """
    data_to_impute = df[cols_to_impute].copy()
    
    imputer = IterativeImputer(
        max_iter=10,
        random_state=42,
        initial_strategy='mean'
    )
    
    imputed_data = imputer.fit_transform(data_to_impute)
    
    df_imputed = df.copy()
    for i, col in enumerate(cols_to_impute):
        df_imputed[col] = imputed_data[:, i]
    
    return df_imputed
```

#### Strategy 3: Missing Data Indicators

```python
def create_missing_indicators(df):
    """Create indicator columns for missing data."""
    df_with_indicators = df.copy()
    
    for col in df.columns:
        if df[col].isnull().sum() > 0:
            indicator_col = f"{col}_missing"
            df_with_indicators[indicator_col] = df[col].isnull().astype(int)
    
    return df_with_indicators

# Usage
df_indicators = create_missing_indicators(df)
```

**Why create indicators:**
- The fact that data is missing can be informative
- Helps models learn that missingness is correlated with outcomes
- Often improves predictive performance

### C.2.3 Choosing the Right Imputation Method

| Scenario | Best Method | Why |
|----------|-------------|-----|
| < 5% missing, MCAR | Listwise deletion | Simple, minimal bias |
| 5-15% missing, MAR | Mean/Median imputation | Quick, reasonable |
| 15-30% missing, MAR | Regression imputation | Uses relationships, preserves distribution |
| > 30% missing, MAR | Multiple imputation | Handles uncertainty, best estimates |
| MNAR | Model-based imputation | Need to model missingness mechanism |
| Time series data | Forward/Backward fill | Uses temporal patterns |

---

## C.3 Handling Duplicates

### C.3.1 Identifying Duplicates

```python
def identify_duplicates(df, subset=None):
    """
    Identify duplicate records.
    
    Parameters:
    -----------
    df : pd.DataFrame
        The dataset
    subset : list
        Columns to check for duplicates (if None, check all)
    """
    if subset:
        duplicate_mask = df.duplicated(subset=subset, keep=False)
    else:
        duplicate_mask = df.duplicated(keep=False)
    
    duplicate_count = duplicate_mask.sum()
    
    if duplicate_count > 0:
        print(f"Found {duplicate_count} duplicate records")
        print("\nDuplicate records:")
        print(df[duplicate_mask].sort_values(by=df.columns.tolist()))
        return duplicate_mask
    else:
        print("✅ No duplicates found")
        return None

# Usage
duplicate_mask = identify_duplicates(df, subset=['customer_id'])
```

### C.3.2 Removing Duplicates

```python
def remove_duplicates(df, subset=None, keep='first'):
    """
    Remove duplicate records.
    
    Parameters:
    -----------
    df : pd.DataFrame
        The dataset
    subset : list
        Columns to check for duplicates
    keep : str
        'first', 'last', or False (drop all)
    """
    df_clean = df.drop_duplicates(subset=subset, keep=keep)
    removed = len(df) - len(df_clean)
    
    if removed > 0:
        print(f"✅ Removed {removed} duplicate records")
    else:
        print("✅ No duplicates to remove")
    
    return df_clean

# Usage
df_clean = remove_duplicates(df, subset=['customer_id'])
```

### C.3.3 Handling Near-Duplicates

For fuzzy matching of near-duplicates:

```python
from difflib import SequenceMatcher

def find_near_duplicates(df, col, threshold=0.9):
    """
    Find near-duplicate values in a column.
    """
    values = df[col].unique()
    duplicates = []
    
    for i in range(len(values)):
        for j in range(i+1, len(values)):
            similarity = SequenceMatcher(None, values[i], values[j]).ratio()
            if similarity >= threshold:
                duplicates.append((values[i], values[j], similarity))
    
    if duplicates:
        print(f"Found {len(duplicates)} near-duplicate pairs:")
        for dup in duplicates:
            print(f"  '{dup[0]}' ↔ '{dup[1]}' (similarity: {dup[2]:.2f})")
    
    return duplicates
```

---

## C.4 Fixing Data Types

### C.4.1 Common Data Type Issues

```python
def diagnose_data_types(df):
    """Diagnose potential data type issues."""
    
    print("=" * 60)
    print("DATA TYPE DIAGNOSTIC")
    print("=" * 60)
    
    for col in df.columns:
        print(f"\n{col}:")
        print(f"  Current type: {df[col].dtype}")
        
        # Check if numeric column contains strings
        if df[col].dtype == 'object':
            # Try to convert to numeric
            numeric_test = pd.to_numeric(df[col], errors='coerce')
            if numeric_test.notna().sum() > 0:
                print(f"  ⚠️ Contains numeric values stored as strings")
                print(f"     Convertible to numeric: {numeric_test.notna().sum():,} values")
        
        # Check for dates stored as strings
        if df[col].dtype == 'object':
            date_test = pd.to_datetime(df[col], errors='coerce')
            if date_test.notna().sum() > 0:
                print(f"  ⚠️ Contains date values stored as strings")
                print(f"     Convertible to datetime: {date_test.notna().sum():,} values")
        
        # Check for categorical with many unique values
        if df[col].dtype == 'object':
            unique_count = df[col].nunique()
            if unique_count < 50:
                print(f"  💡 Could be categorical (unique: {unique_count})")
            else:
                print(f"  💡 High cardinality (unique: {unique_count})")

# Usage
diagnose_data_types(df)
```

### C.4.2 Converting Data Types

```python
def convert_data_types(df):
    """
    Safely convert columns to appropriate data types.
    """
    df_converted = df.copy()
    
    # Convert strings to numeric
    for col in df_converted.select_dtypes(include=['object']).columns:
        # Try to convert to numeric
        numeric_test = pd.to_numeric(df_converted[col], errors='coerce')
        if numeric_test.notna().sum() / len(df_converted) > 0.8:
            df_converted[col] = numeric_test
            print(f"  ✅ Converted {col} to numeric")
    
    # Convert to categorical where appropriate
    for col in df_converted.select_dtypes(include=['object']).columns:
        if df_converted[col].nunique() < 50:
            df_converted[col] = df_converted[col].astype('category')
            print(f"  ✅ Converted {col} to categorical")
    
    # Convert strings to dates
    for col in df_converted.select_dtypes(include=['object']).columns:
        date_test = pd.to_datetime(df_converted[col], errors='coerce')
        if date_test.notna().sum() / len(df_converted) > 0.8:
            df_converted[col] = date_test
            print(f"  ✅ Converted {col} to datetime")
    
    return df_converted

# Usage
df_converted = convert_data_types(df)
```

### C.4.3 Handling String Data

```python
def clean_strings(df, col):
    """
    Clean string data in a column.
    """
    cleaned = df[col].copy()
    
    # Strip whitespace
    cleaned = cleaned.str.strip()
    
    # Convert to lowercase
    cleaned = cleaned.str.lower()
    
    # Remove special characters
    cleaned = cleaned.str.replace(r'[^\w\s]', '', regex=True)
    
    # Replace multiple spaces with single
    cleaned = cleaned.str.replace(r'\s+', ' ', regex=True)
    
    return cleaned

# Usage
df['country_cleaned'] = clean_strings(df, 'country')
```

---

## C.5 Handling Outliers

### C.5.1 Detecting Outliers

#### Z-Score Method

```python
def detect_outliers_zscore(df, col, threshold=3):
    """
    Detect outliers using Z-score method.
    """
    data = df[col].dropna()
    z_scores = np.abs((data - data.mean()) / data.std())
    outlier_mask = z_scores > threshold
    
    outliers = data[outlier_mask]
    
    print(f"{col}: {len(outliers)} outliers detected")
    print(f"  Outliers: {outliers.tolist()}")
    
    return outlier_mask

# Usage
outlier_mask = detect_outliers_zscore(df, 'avg_order_value')
```

#### IQR Method

```python
def detect_outliers_iqr(df, col):
    """
    Detect outliers using IQR method.
    """
    data = df[col].dropna()
    q1 = data.quantile(0.25)
    q3 = data.quantile(0.75)
    iqr = q3 - q1
    lower = q1 - 1.5 * iqr
    upper = q3 + 1.5 * iqr
    
    outlier_mask = (data < lower) | (data > upper)
    outliers = data[outlier_mask]
    
    print(f"{col}: {len(outliers)} outliers detected")
    print(f"  Range: {lower:.2f} - {upper:.2f}")
    print(f"  Outliers: {outliers.tolist()}")
    
    return outlier_mask

# Usage
outlier_mask = detect_outliers_iqr(df, 'avg_order_value')
```

#### Visualization for Outlier Detection

```python
def visualize_outliers(df, col):
    """
    Visualize outliers in a column.
    """
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))
    
    # Boxplot
    ax = axes[0]
    ax.boxplot(df[col].dropna(), vert=True, patch_artist=True)
    ax.set_title(f'Boxplot of {col}', fontsize=14)
    ax.set_ylabel(col)
    
    # Histogram with outlier markers
    ax = axes[1]
    data = df[col].dropna()
    ax.hist(data, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
    
    # Mark outliers using IQR method
    q1 = data.quantile(0.25)
    q3 = data.quantile(0.75)
    iqr = q3 - q1
    lower = q1 - 1.5 * iqr
    upper = q3 + 1.5 * iqr
    
    outliers = data[(data < lower) | (data > upper)]
    ax.axvline(lower, color='red', linestyle='--', label=f'Lower bound: {lower:.2f}')
    ax.axvline(upper, color='red', linestyle='--', label=f'Upper bound: {upper:.2f}')
    ax.scatter(outliers, [0] * len(outliers), color='red', 
              s=50, marker='x', label=f'Outliers ({len(outliers)})')
    
    ax.set_title(f'Distribution of {col} with Outliers', fontsize=14)
    ax.set_xlabel(col)
    ax.set_ylabel('Count')
    ax.legend()
    
    plt.tight_layout()
    plt.show()

# Usage
visualize_outliers(df, 'avg_order_value')
```

### C.5.2 Handling Outliers

#### Option 1: Removal

```python
def remove_outliers(df, col, method='iqr', threshold=3):
    """
    Remove outliers from a column.
    """
    data = df[col].dropna()
    
    if method == 'iqr':
        q1 = data.quantile(0.25)
        q3 = data.quantile(0.75)
        iqr = q3 - q1
        lower = q1 - 1.5 * iqr
        upper = q3 + 1.5 * iqr
        mask = (df[col] >= lower) & (df[col] <= upper)
    elif method == 'zscore':
        z_scores = np.abs((data - data.mean()) / data.std())
        mask = z_scores <= threshold
        mask = mask.reindex(df.index, fill_value=True)
    
    removed = (~mask).sum()
    df_clean = df[mask].copy()
    
    print(f"✅ Removed {removed} outliers from {col}")
    
    return df_clean

# Usage
df_clean = remove_outliers(df, 'avg_order_value', method='iqr')
```

#### Option 2: Winsorization (Capping)

```python
from scipy.stats.mstats import winsorize

def winsorize_outliers(df, col, limits=(0.05, 0.05)):
    """
    Cap outliers using winsorization.
    """
    data = df[col].dropna()
    winsorized = winsorize(data, limits=limits)
    
    df_winsorized = df.copy()
    df_winsorized[col] = winsorized
    
    print(f"✅ Winsorized {col} with limits {limits}")
    
    return df_winsorized

# Usage
df_winsorized = winsorize_outliers(df, 'avg_order_value', limits=(0.01, 0.01))
```

#### Option 3: Transformation

```python
def transform_skewed_data(df, col, method='log'):
    """
    Transform skewed data to reduce outlier influence.
    """
    df_transformed = df.copy()
    data = df[col].dropna()
    
    if method == 'log':
        # Add 1 to handle zeros
        df_transformed[col] = np.log(df[col] + 1)
    elif method == 'sqrt':
        df_transformed[col] = np.sqrt(df[col])
    elif method == 'boxcox':
        from scipy.stats import boxcox
        df_transformed[col], _ = boxcox(df[col] + 1)
    
    print(f"✅ Applied {method} transformation to {col}")
    
    return df_transformed

# Usage
df_transformed = transform_skewed_data(df, 'order_frequency', method='log')
```

### C.5.3 Choosing the Right Outlier Strategy

| Scenario | Best Strategy | Why |
|----------|---------------|-----|
| Obvious data entry errors | Removal | Data is clearly wrong |
| Outliers represent rare but valid cases | Winsorization | Preserves information, reduces influence |
| Skewed distribution | Transformation | Makes distribution more normal |
| Modeling with tree-based models | Keep outliers | Trees handle outliers naturally |
| Modeling with linear models | Winsorization or Transformation | Outliers strongly affect linear models |
| Exploratory analysis | Keep with caution | Outliers may reveal important patterns |

---

## C.6 Feature Engineering

### C.6.1 Creating New Features

```python
def engineer_features(df):
    """
    Create new features from existing columns.
    """
    df_fe = df.copy()
    
    # Create age groups
    df_fe['age_group'] = pd.cut(df_fe['age'], 
                                bins=[0, 25, 35, 45, 55, 100],
                                labels=['Under 25', '25-35', '35-45', '45-55', '55+'])
    
    # Create engagement levels
    df_fe['engagement_level'] = pd.cut(df_fe['time_on_site'],
                                      bins=[0, 5, 15, 100],
                                      labels=['Low', 'Medium', 'High'])
    
    # Create customer value segments
    df_fe['value_segment'] = pd.cut(df_fe['avg_order_value'],
                                   bins=[0, 50, 100, 200, 500],
                                   labels=['Low', 'Medium', 'High', 'Premium'])
    
    # Create ratios
    df_fe['value_per_page'] = df_fe['avg_order_value'] / (df_fe['pages_viewed'] + 1)
    df_fe['time_per_page'] = df_fe['time_on_site'] / (df_fe['pages_viewed'] + 1)
    
    # Create interaction features
    df_fe['income_x_engagement'] = df_fe['engagement_level'].cat.codes * \
                                   df_fe['income_bracket'].factorize()[0]
    
    # Create composite score
    df_fe['customer_score'] = (
        df_fe['order_frequency'] * 0.3 +
        (df_fe['avg_order_value'] / df_fe['avg_order_value'].max()) * 0.3 +
        df_fe['customer_rating'] / 5 * 0.2 +
        (1 - df_fe['return_rate'] / 100) * 0.2
    )
    
    print(f"✅ Created {len(df_fe.columns) - len(df.columns)} new features")
    
    return df_fe

# Usage
df_fe = engineer_features(df)
```

### C.6.2 Encoding Categorical Variables

#### Label Encoding

```python
from sklearn.preprocessing import LabelEncoder

def label_encode(df, col):
    """
    Encode categorical variable with integers.
    """
    le = LabelEncoder()
    df_encoded = df.copy()
    df_encoded[f'{col}_encoded'] = le.fit_transform(df[col].astype(str))
    
    print(f"✅ Label encoded {col}")
    print(f"   Mapping: {dict(zip(le.classes_, le.transform(le.classes_)))}")
    
    return df_encoded

# Usage
df_encoded = label_encode(df, 'income_bracket')
```

#### One-Hot Encoding

```python
def one_hot_encode(df, col):
    """
    One-hot encode categorical variable.
    """
    dummies = pd.get_dummies(df[col], prefix=col, drop_first=False)
    df_encoded = pd.concat([df, dummies], axis=1)
    
    print(f"✅ One-hot encoded {col}")
    print(f"   Created {len(dummies.columns)} new columns")
    
    return df_encoded

# Usage
df_encoded = one_hot_encode(df, 'favorite_category')
```

#### Frequency Encoding

```python
def frequency_encode(df, col):
    """
    Encode categorical variable by frequency.
    """
    freq_map = df[col].value_counts(normalize=True).to_dict()
    df_encoded = df.copy()
    df_encoded[f'{col}_freq'] = df[col].map(freq_map)
    
    print(f"✅ Frequency encoded {col}")
    print(f"   Top: {max(freq_map.values()):.3f}")
    print(f"   Bottom: {min(freq_map.values()):.3f}")
    
    return df_encoded

# Usage
df_encoded = frequency_encode(df, 'country')
```

### C.6.3 Handling Dates

```python
def extract_date_features(df, date_col):
    """
    Extract features from datetime column.
    """
    df_fe = df.copy()
    df_fe[date_col] = pd.to_datetime(df_fe[date_col])
    
    # Basic components
    df_fe[f'{date_col}_year'] = df_fe[date_col].dt.year
    df_fe[f'{date_col}_month'] = df_fe[date_col].dt.month
    df_fe[f'{date_col}_day'] = df_fe[date_col].dt.day
    df_fe[f'{date_col}_dayofweek'] = df_fe[date_col].dt.dayofweek
    df_fe[f'{date_col}_quarter'] = df_fe[date_col].dt.quarter
    
    # Derived features
    df_fe[f'{date_col}_is_weekend'] = df_fe[date_col].dt.dayofweek.isin([5, 6]).astype(int)
    df_fe[f'{date_col}_is_month_end'] = df_fe[date_col].dt.is_month_end.astype(int)
    
    # Days since a reference date
    reference_date = pd.Timestamp('2020-01-01')
    df_fe[f'{date_col}_days_since_reference'] = (df_fe[date_col] - reference_date).dt.days
    
    print(f"✅ Extracted {len(df_fe.columns) - len(df.columns)} features from {date_col}")
    
    return df_fe

# Usage
df_fe = extract_date_features(df, 'account_created')
```

---

## C.7 Data Standardization and Normalization

### C.7.1 Standardization (Z-Score)

```python
from sklearn.preprocessing import StandardScaler

def standardize_data(df, cols):
    """
    Standardize numerical columns (mean=0, std=1).
    """
    scaler = StandardScaler()
    df_standardized = df.copy()
    df_standardized[cols] = scaler.fit_transform(df[cols])
    
    print(f"✅ Standardized {len(cols)} columns")
    
    return df_standardized, scaler

# Usage
cols_to_standardize = ['age', 'time_on_site', 'order_frequency', 'avg_order_value']
df_standardized, scaler = standardize_data(df, cols_to_standardize)
```

### C.7.2 Min-Max Normalization

```python
from sklearn.preprocessing import MinMaxScaler

def normalize_data(df, cols):
    """
    Normalize numerical columns to [0, 1].
    """
    scaler = MinMaxScaler()
    df_normalized = df.copy()
    df_normalized[cols] = scaler.fit_transform(df[cols])
    
    print(f"✅ Normalized {len(cols)} columns")
    
    return df_normalized, scaler

# Usage
df_normalized, scaler = normalize_data(df, cols_to_standardize)
```

### C.7.3 Robust Scaling

```python
from sklearn.preprocessing import RobustScaler

def robust_scale_data(df, cols):
    """
    Scale using median and IQR (robust to outliers).
    """
    scaler = RobustScaler()
    df_scaled = df.copy()
    df_scaled[cols] = scaler.fit_transform(df[cols])
    
    print(f"✅ Robust scaled {len(cols)} columns")
    
    return df_scaled, scaler

# Usage
df_scaled, scaler = robust_scale_data(df, cols_to_standardize)
```

### C.7.4 Choosing the Right Scaling Method

| Method | Best For | Characteristics |
|--------|----------|-----------------|
| **StandardScaler** | Normal distributions | Mean=0, Std=1 |
| **MinMaxScaler** | Known bounds, neural networks | [0, 1] range |
| **RobustScaler** | Outliers present | Median, IQR-based |
| **MaxAbsScaler** | Sparse data | [-1, 1] range |
| **Unit Vector** | Directional data | Length=1 |

---

## C.8 Data Validation

### C.8.1 Validation Checks

```python
def validate_data(df, validation_rules):
    """
    Validate data against business rules.
    """
    errors = []
    
    for rule in validation_rules:
        col = rule['column']
        condition = rule['condition']
        message = rule['message']
        
        if condition == 'not_null':
            invalid = df[col].isnull().sum()
            if invalid > 0:
                errors.append(f"{col}: {invalid} null values")
        
        elif condition == 'between':
            min_val = rule['min']
            max_val = rule['max']
            invalid = df[(df[col] < min_val) | (df[col] > max_val)].shape[0]
            if invalid > 0:
                errors.append(f"{col}: {invalid} values outside [{min_val}, {max_val}]")
        
        elif condition == 'in':
            allowed = rule['allowed']
            invalid = df[~df[col].isin(allowed)].shape[0]
            if invalid > 0:
                errors.append(f"{col}: {invalid} values not in {allowed}")
        
        elif condition == 'unique':
            duplicates = df[col].duplicated().sum()
            if duplicates > 0:
                errors.append(f"{col}: {duplicates} duplicate values")
    
    if errors:
        print("❌ Validation errors found:")
        for error in errors:
            print(f"  • {error}")
    else:
        print("✅ All validations passed")
    
    return errors

# Usage
validation_rules = [
    {'column': 'customer_id', 'condition': 'not_null', 'message': 'Customer ID required'},
    {'column': 'age', 'condition': 'between', 'min': 18, 'max': 100, 'message': 'Age must be 18-100'},
    {'column': 'gender', 'condition': 'in', 'allowed': ['Male', 'Female', 'Non-binary'], 'message': 'Invalid gender'},
    {'column': 'customer_rating', 'condition': 'between', 'min': 1, 'max': 5, 'message': 'Rating must be 1-5'}
]

errors = validate_data(df, validation_rules)
```

---

## C.9 Complete Data Cleaning Pipeline

```python
class DataCleaner:
    """
    Complete data cleaning pipeline.
    """
    
    def __init__(self, df, config=None):
        self.df = df.copy()
        self.config = config or {}
        self.report = {}
    
    def run_pipeline(self):
        """Run the complete cleaning pipeline."""
        
        print("=" * 60)
        print("DATA CLEANING PIPELINE")
        print("=" * 60)
        
        # Step 1: Initial inspection
        print("\n[Step 1] Initial Inspection")
        self._inspect_data()
        
        # Step 2: Handle duplicates
        print("\n[Step 2] Handling Duplicates")
        self._handle_duplicates()
        
        # Step 3: Fix data types
        print("\n[Step 3] Fixing Data Types")
        self._fix_data_types()
        
        # Step 4: Handle missing values
        print("\n[Step 4] Handling Missing Values")
        self._handle_missing()
        
        # Step 5: Handle outliers
        print("\n[Step 5] Handling Outliers")
        self._handle_outliers()
        
        # Step 6: Feature engineering
        print("\n[Step 6] Feature Engineering")
        self._engineer_features()
        
        # Step 7: Validate
        print("\n[Step 7] Validation")
        self._validate_data()
        
        print("\n" + "=" * 60)
        print("DATA CLEANING COMPLETE")
        print("=" * 60)
        
        return self.df, self.report
    
    def _inspect_data(self):
        """Initial inspection."""
        self.report['initial_shape'] = self.df.shape
        self.report['initial_missing'] = self.df.isnull().sum().sum()
        self.report['initial_duplicates'] = self.df.duplicated().sum()
    
    def _handle_duplicates(self):
        """Handle duplicates."""
        self.df = self.df.drop_duplicates()
        self.report['duplicates_removed'] = self.report['initial_duplicates'] - self.df.duplicated().sum()
    
    def _fix_data_types(self):
        """Fix data types."""
        # Convert to categorical for low cardinality
        for col in self.df.select_dtypes(include=['object']).columns:
            if self.df[col].nunique() < 50:
                self.df[col] = self.df[col].astype('category')
                self.report.setdefault('type_changes', []).append(f"{col} -> categorical")
    
    def _handle_missing(self):
        """Handle missing values."""
        self.report['missing_before'] = self.df.isnull().sum().sum()
        
        for col in self.df.columns:
            if self.df[col].isnull().sum() > 0:
                if self.df[col].dtype in ['float64', 'int64']:
                    self.df[col] = self.df[col].fillna(self.df[col].median())
                else:
                    self.df[col] = self.df[col].fillna(self.df[col].mode()[0])
        
        self.report['missing_after'] = self.df.isnull().sum().sum()
        self.report['missing_filled'] = self.report['missing_before'] - self.report['missing_after']
    
    def _handle_outliers(self):
        """Handle outliers using IQR method."""
        self.report['outliers_handled'] = {}
        
        for col in self.df.select_dtypes(include=['float64', 'int64']).columns:
            data = self.df[col].dropna()
            if len(data) > 0:
                q1 = data.quantile(0.25)
                q3 = data.quantile(0.75)
                iqr = q3 - q1
                if iqr > 0:
                    lower = q1 - 1.5 * iqr
                    upper = q3 + 1.5 * iqr
                    outliers = ((data < lower) | (data > upper)).sum()
                    if outliers > 0:
                        self.report['outliers_handled'][col] = outliers
                        # Winsorize
                        from scipy.stats.mstats import winsorize
                        self.df[col] = winsorize(self.df[col], limits=(0.01, 0.01))
    
    def _engineer_features(self):
        """Create new features."""
        new_features = []
        
        # Create engagement levels
        if 'time_on_site' in self.df.columns:
            self.df['engagement_level'] = pd.cut(self.df['time_on_site'],
                                                bins=[0, 5, 15, 100],
                                                labels=['Low', 'Medium', 'High'])
            new_features.append('engagement_level')
        
        # Create age groups
        if 'age' in self.df.columns:
            self.df['age_group'] = pd.cut(self.df['age'],
                                         bins=[0, 25, 35, 45, 55, 100],
                                         labels=['Under 25', '25-35', '35-45', '45-55', '55+'])
            new_features.append('age_group')
        
        self.report['new_features'] = new_features
    
    def _validate_data(self):
        """Validate cleaned data."""
        self.report['final_shape'] = self.df.shape
        self.report['final_missing'] = self.df.isnull().sum().sum()
        
        print("\n📊 Pipeline Summary:")
        print(f"  Initial rows: {self.report['initial_shape'][0]:,}")
        print(f"  Final rows: {self.report['final_shape'][0]:,}")
        print(f"  Duplicates removed: {self.report['duplicates_removed']}")
        print(f"  Missing values filled: {self.report['missing_filled']}")
        print(f"  New features created: {len(self.report['new_features'])}")

# Usage
cleaner = DataCleaner(df)
df_clean, report = cleaner.run_pipeline()
```

---

## C.10 Key Takeaways

1. **Always inspect your data first** - Know what you're working with before cleaning
2. **Document your cleaning steps** - Reproducibility is crucial
3. **Handle missing data thoughtfully** - The method matters for your analysis
4. **Detect outliers appropriately** - Not all outliers are errors
5. **Choose the right encoding** - Different models need different encodings
6. **Scale your data** - Many models assume scaled features
7. **Validate your work** - Check that cleaning didn't introduce errors

---

## C.11 Common Data Quality Issues and Solutions

| Issue | Detection | Solution |
|-------|-----------|----------|
| **Missing values** | `df.isnull().sum()` | Imputation, deletion, indicators |
| **Duplicates** | `df.duplicated().sum()` | Drop duplicates |
| **Inconsistent formats** | `df[col].unique()` | Standardize with regex |
| **Outliers** | Boxplots, Z-scores, IQR | Remove, cap, transform |
| **Wrong data types** | `df.dtypes` | Convert types appropriately |
| **Inconsistent categories** | `df[col].value_counts()` | Map to standard values |
| **Impossible values** | Business rules | Filter or correct |
| **Spelling errors** | String matching | Fuzzy matching, mapping |

This appendix provides a comprehensive guide to data cleaning and preprocessing. It covers everything from basic missing value handling to advanced feature engineering, with practical Python code examples throughout.

The techniques here will serve you well in real-world data science projects, where data is rarely as clean as our synthetic dataset.
