# Primer 8: Feature Engineering Mastery

## Overview

This primer provides a comprehensive deep dive into feature engineering—the art and science of creating informative features from raw data. Feature engineering is often cited as the most important factor in model performance. This primer covers techniques for handling different data types, creating interaction features, and designing features that capture domain knowledge.

---

## 1. The Feature Engineering Process

### The Feature Engineering Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│              FEATURE ENGINEERING WORKFLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Raw Data                                                      │
│      │                                                          │
│      ▼                                                          │
│  1. Data Understanding                                         │
│     └── Explore distributions, relationships                  │
│                                                                 │
│  2. Data Cleaning                                              │
│     └── Handle missing, outliers, duplicates                  │
│                                                                 │
│  3. Feature Creation                                           │
│     ├── Transformations                                       │
│     ├── Interactions                                          │
│     ├── Aggregations                                          │
│     └── Domain-specific                                       │
│                                                                 │
│  4. Feature Selection                                          │
│     └── Keep most informative features                        │
│                                                                 │
│  5. Feature Transformation                                     │
│     └── Scale, encode for model                               │
│                                                                 │
│  Model-Ready Features                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The Golden Rules

```
┌─────────────────────────────────────────────────────────────────┐
│                    GOLDEN RULES OF FEATURE ENGINEERING         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Understand Your Domain                                     │
│     └── Domain knowledge is the secret sauce                  │
│                                                                 │
│  2. Start Simple                                               │
│     └── Begin with basic features, add complexity gradually   │
│                                                                 │
│  3. Create Features with Your Model in Mind                   │
│     └── Linear models need transformations, trees don't       │
│                                                                 │
│  4. Avoid Leakage                                              │
│     └── Never use future information                          │
│                                                                 │
│  5. Iterate and Validate                                       │
│     └── Test feature impact on model performance              │
│                                                                 │
│  6. Document Everything                                        │
│     └── Keep track of feature definitions and rationale       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Numeric Feature Engineering

### Transformations

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def demonstrate_transformations():
    """Demonstrate numeric transformations."""
    
    # Create skewed data
    np.random.seed(42)
    skewed_data = np.random.exponential(scale=2, size=1000)
    
    # Apply transformations
    transformations = {
        'original': skewed_data,
        'log': np.log1p(skewed_data),
        'sqrt': np.sqrt(skewed_data),
        'square': skewed_data ** 2,
        'cube': skewed_data ** 3,
        'box_cox': stats.boxcox(skewed_data + 1)[0],
        'yeo_johnson': stats.yeojohnson(skewed_data)[0]
    }
    
    # Plot
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    axes = axes.flatten()
    
    for idx, (name, data) in enumerate(transformations.items()):
        ax = axes[idx]
        ax.hist(data, bins=30, alpha=0.7, edgecolor='black')
        ax.set_title(f'{name.capitalize()}\nSkew: {stats.skew(data):.2f}')
        ax.set_xlabel('Value')
        ax.set_ylabel('Frequency')
    
    plt.tight_layout()
    plt.show()
    
    return transformations

from scipy import stats
transformations = demonstrate_transformations()
```

### Binning (Discretization)

```python
def create_binned_features(df, column, bins=10):
    """Create binned features from continuous variable."""
    df = df.copy()
    
    # Equal-width bins
    df[f'{column}_bin_equal'] = pd.cut(
        df[column],
        bins=bins,
        labels=[f'bin_{i}' for i in range(bins)]
    )
    
    # Equal-frequency bins
    df[f'{column}_bin_quantile'] = pd.qcut(
        df[column],
        q=bins,
        labels=[f'q_{i}' for i in range(bins)]
    )
    
    return df

# Example
df['age_bin'] = pd.cut(df['age'], bins=[0, 18, 30, 50, 65, 100], 
                       labels=['child', 'young', 'adult', 'middle', 'senior'])
```

### Polynomial Features

```python
from sklearn.preprocessing import PolynomialFeatures

def create_polynomial_features(X, degree=2, interaction_only=False):
    """
    Create polynomial and interaction features.
    
    Args:
        X: Input features
        degree: Polynomial degree
        interaction_only: Only interaction terms (no powers)
    
    Returns:
        DataFrame: Features with polynomial terms
    """
    poly = PolynomialFeatures(
        degree=degree,
        interaction_only=interaction_only,
        include_bias=False
    )
    
    X_poly = poly.fit_transform(X)
    
    # Get feature names
    feature_names = poly.get_feature_names_out(X.columns)
    
    return pd.DataFrame(X_poly, columns=feature_names, index=X.index)

# Example
X = df[['age', 'income', 'tenure']]
X_poly = create_polynomial_features(X, degree=2)
print(f"Original features: {X.shape[1]}")
print(f"Polynomial features: {X_poly.shape[1]}")
print(f"Feature names: {X_poly.columns.tolist()}")
```

### Interaction Features

```python
def create_interaction_features(df, columns):
    """Create interaction features between columns."""
    df = df.copy()
    
    for i in range(len(columns)):
        for j in range(i+1, len(columns)):
            col1 = columns[i]
            col2 = columns[j]
            
            # Multiplication
            df[f'{col1}_x_{col2}'] = df[col1] * df[col2]
            
            # Division (handle zeros)
            df[f'{col1}_div_{col2}'] = df[col1] / df[col2].replace(0, np.nan)
            
            # Difference
            df[f'{col1}_minus_{col2}'] = df[col1] - df[col2]
            
            # Ratio of sums
            df[f'{col1}_ratio_{col2}'] = df[col1] / (df[col1] + df[col2] + 1)
    
    return df
```

### Domain-Specific Numeric Features

```python
def create_domain_features(df):
    """Create domain-specific numeric features."""
    df = df.copy()
    
    # Financial features
    if 'income' in df.columns and 'spend' in df.columns:
        df['spend_to_income_ratio'] = df['spend'] / df['income']
        df['disposable_income'] = df['income'] - df['spend']
    
    # Customer features
    if 'tenure' in df.columns:
        df['tenure_years'] = df['tenure'] / 12
        df['tenure_group'] = pd.cut(df['tenure'], 
                                    bins=[0, 6, 12, 24, 48, 120],
                                    labels=['0-6m', '6-12m', '1-2y', '2-4y', '4y+'])
    
    # Age features
    if 'age' in df.columns:
        df['age_group'] = pd.cut(df['age'], 
                                 bins=[0, 18, 30, 50, 65, 100],
                                 labels=['<18', '18-30', '30-50', '50-65', '65+'])
        df['age_squared'] = df['age'] ** 2
    
    return df
```

---

## 3. Categorical Feature Engineering

### Encoding Strategies

```python
from sklearn.preprocessing import OneHotEncoder, OrdinalEncoder
from sklearn.compose import ColumnTransformer

def create_encoding_pipeline(categorical_cols, strategy='one_hot'):
    """Create encoding pipeline for categorical features."""
    
    if strategy == 'one_hot':
        encoder = OneHotEncoder(
            handle_unknown='ignore',
            sparse_output=False,
            drop='first'  # Avoid multicollinearity
        )
    elif strategy == 'ordinal':
        encoder = OrdinalEncoder(
            handle_unknown='use_encoded_value',
            unknown_value=-1
        )
    else:
        raise ValueError(f"Unknown strategy: {strategy}")
    
    return ColumnTransformer([
        ('encoder', encoder, categorical_cols)
    ])

# Example
cat_cols = ['gender', 'city', 'contract_type']
encoder = create_encoding_pipeline(cat_cols)
X_encoded = encoder.fit_transform(df)
```

### Target Encoding

```python
def target_encode(df, categorical_col, target_col, smoothing=1.0, min_samples=10):
    """
    Apply target encoding to a categorical column.
    
    Args:
        df: DataFrame
        categorical_col: Column to encode
        target_col: Target column
        smoothing: Smoothing factor
        min_samples: Minimum samples for regularization
    
    Returns:
        Series: Target encoded values
    """
    # Calculate global mean
    global_mean = df[target_col].mean()
    
    # Calculate group means
    group_stats = df.groupby(categorical_col).agg({
        target_col: ['mean', 'count']
    })
    group_stats.columns = ['mean', 'count']
    
    # Apply smoothing
    def smooth_mean(row):
        weight = row['count'] / (row['count'] + min_samples)
        return global_mean * (1 - weight) + row['mean'] * weight
    
    group_stats['encoded'] = group_stats.apply(smooth_mean, axis=1)
    
    # Map back to original data
    return df[categorical_col].map(group_stats['encoded'])

# Example
df['city_target_encoded'] = target_encode(df, 'city', 'churn')
```

### Frequency Encoding

```python
def frequency_encode(df, categorical_col):
    """Apply frequency encoding to a categorical column."""
    freq_map = df[categorical_col].value_counts(normalize=True)
    return df[categorical_col].map(freq_map)

# Example
df['city_freq_encoded'] = frequency_encode(df, 'city')
```

### High-Cardinality Handling

```python
def handle_high_cardinality(df, categorical_col, threshold=0.01):
    """
    Handle high-cardinality categorical variables.
    
    Args:
        df: DataFrame
        categorical_col: Column to process
        threshold: Minimum frequency threshold
    
    Returns:
        Series: Processed column with rare categories grouped
    """
    # Calculate frequencies
    freq = df[categorical_col].value_counts(normalize=True)
    
    # Identify rare categories
    rare_categories = freq[freq < threshold].index.tolist()
    
    # Group rare categories
    return df[categorical_col].apply(
        lambda x: 'other' if x in rare_categories else x
    )
```

---

## 4. Text Feature Engineering

### Basic Text Features

```python
def create_text_features(df, text_col):
    """Create basic text features."""
    df = df.copy()
    
    # Length features
    df[f'{text_col}_length'] = df[text_col].str.len()
    df[f'{text_col}_word_count'] = df[text_col].str.split().str.len()
    df[f'{text_col}_char_count'] = df[text_col].str.len()
    
    # Special character features
    df[f'{text_col}_punct_count'] = df[text_col].str.count(r'[!,.?;:]')
    df[f'{text_col}_uppercase_count'] = df[text_col].str.count(r'[A-Z]')
    df[f'{text_col}_digit_count'] = df[text_col].str.count(r'\d')
    
    # Ratio features
    df[f'{text_col}_avg_word_length'] = df[f'{text_col}_char_count'] / (df[f'{text_col}_word_count'] + 1)
    df[f'{text_col}_punct_ratio'] = df[f'{text_col}_punct_count'] / (df[f'{text_col}_length'] + 1)
    
    return df
```

### TF-IDF Features

```python
from sklearn.feature_extraction.text import TfidfVectorizer

def create_tfidf_features(text_series, max_features=100):
    """Create TF-IDF features from text."""
    vectorizer = TfidfVectorizer(
        max_features=max_features,
        stop_words='english',
        max_df=0.8,
        min_df=2
    )
    
    X_tfidf = vectorizer.fit_transform(text_series)
    
    # Get feature names
    feature_names = vectorizer.get_feature_names_out()
    
    # Convert to DataFrame
    return pd.DataFrame(X_tfidf.toarray(), columns=feature_names)

# Example
tfidf_features = create_tfidf_features(df['review_text'], max_features=50)
```

### Word Embeddings (Simplified)

```python
from sklearn.feature_extraction.text import CountVectorizer

def create_word_embedding_features(text_series, n_components=10):
    """Create word embedding-like features using SVD."""
    from sklearn.decomposition import TruncatedSVD
    
    # Create document-term matrix
    vectorizer = CountVectorizer(max_features=1000)
    X_counts = vectorizer.fit_transform(text_series)
    
    # Apply SVD
    svd = TruncatedSVD(n_components=n_components)
    X_embed = svd.fit_transform(X_counts)
    
    return pd.DataFrame(X_embed, columns=[f'text_comp_{i}' for i in range(n_components)])
```

---

## 5. Date and Time Features

### Extracting Date Features

```python
def create_datetime_features(df, datetime_col):
    """Create features from datetime column."""
    df = df.copy()
    dt = df[datetime_col]
    
    # Basic components
    df['year'] = dt.dt.year
    df['month'] = dt.dt.month
    df['day'] = dt.dt.day
    df['dayofweek'] = dt.dt.dayofweek
    df['quarter'] = dt.dt.quarter
    df['hour'] = dt.dt.hour
    df['minute'] = dt.dt.minute
    
    # Cyclical features (for seasonality)
    df['month_sin'] = np.sin(2 * np.pi * df['month'] / 12)
    df['month_cos'] = np.cos(2 * np.pi * df['month'] / 12)
    df['dayofweek_sin'] = np.sin(2 * np.pi * df['dayofweek'] / 7)
    df['dayofweek_cos'] = np.cos(2 * np.pi * df['dayofweek'] / 7)
    df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
    df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)
    
    # Boolean features
    df['is_weekend'] = df['dayofweek'].isin([5, 6]).astype(int)
    df['is_month_start'] = dt.dt.is_month_start.astype(int)
    df['is_month_end'] = dt.dt.is_month_end.astype(int)
    
    # Derived features
    df['dayofyear'] = dt.dt.dayofyear
    df['weekofyear'] = dt.dt.isocalendar().week.astype(int)
    
    return df
```

### Time Difference Features

```python
def create_time_difference_features(df, datetime_cols):
    """Create features based on time differences."""
    df = df.copy()
    
    for i in range(len(datetime_cols)):
        for j in range(i+1, len(datetime_cols)):
            col1 = datetime_cols[i]
            col2 = datetime_cols[j]
            
            # Difference in days
            df[f'{col1}_minus_{col2}_days'] = (df[col1] - df[col2]).dt.days
            
            # Difference in hours
            df[f'{col1}_minus_{col2}_hours'] = (df[col1] - df[col2]).dt.total_seconds() / 3600
    
    return df
```

---

## 6. Missing Value Engineering

### Missing Value Indicators

```python
def create_missing_indicators(df, columns=None):
    """Create indicator features for missing values."""
    df = df.copy()
    
    if columns is None:
        columns = df.columns
    
    for col in columns:
        if df[col].isnull().any():
            df[f'{col}_is_missing'] = df[col].isnull().astype(int)
    
    return df
```

### Imputation with Domain Knowledge

```python
def domain_knowledge_imputation(df):
    """Impute missing values using domain knowledge."""
    df = df.copy()
    
    # Example: Age imputation based on other features
    if 'age' in df.columns and 'income' in df.columns:
        # Group by income bracket
        income_groups = df.groupby(pd.cut(df['income'], bins=5))['age'].median()
        df['age'] = df.apply(
            lambda row: row['age'] if pd.notna(row['age']) 
            else income_groups.get(pd.cut([row['income']], bins=5)[0], row['age']),
            axis=1
        )
    
    # Example: Income imputation based on occupation
    if 'income' in df.columns and 'occupation' in df.columns:
        median_by_occupation = df.groupby('occupation')['income'].median()
        df['income'] = df.apply(
            lambda row: row['income'] if pd.notna(row['income'])
            else median_by_occupation.get(row['occupation'], row['income']),
            axis=1
        )
    
    return df
```

---

## 7. Feature Selection

### Correlation-Based Selection

```python
def select_features_by_correlation(df, target_col, threshold=0.1):
    """
    Select features based on correlation with target.
    
    Args:
        df: DataFrame
        target_col: Target column
        threshold: Minimum correlation threshold
    
    Returns:
        List: Selected feature names
    """
    # Calculate correlations
    correlations = df.corr()[target_col].drop(target_col)
    
    # Select features above threshold
    selected = correlations[abs(correlations) >= threshold].index.tolist()
    
    return selected
```

### Model-Based Feature Importance

```python
from sklearn.ensemble import RandomForestClassifier

def select_features_by_importance(X, y, threshold=0.01):
    """
    Select features using Random Forest importance.
    
    Args:
        X: Feature matrix
        y: Target vector
        threshold: Minimum importance threshold
    
    Returns:
        List: Selected feature names
    """
    # Train Random Forest
    rf = RandomForestClassifier(n_estimators=100, random_state=42)
    rf.fit(X, y)
    
    # Get importance
    importance = pd.DataFrame({
        'feature': X.columns,
        'importance': rf.feature_importances_
    }).sort_values('importance', ascending=False)
    
    # Select features above threshold
    selected = importance[importance['importance'] >= threshold]['feature'].tolist()
    
    return selected
```

---

## 8. Quick Reference: Feature Engineering

### Feature Type Matrix

| Feature Type | Techniques | When to Use |
|--------------|------------|-------------|
| **Numeric** | Scaling, transformations, binning | Linear models, distance-based models |
| **Categorical** | One-hot, target encoding, frequency | Tree models, linear models with encoding |
| **Text** | TF-IDF, embeddings, length features | NLP tasks, unstructured data |
| **DateTime** | Cyclical encoding, difference features | Time series, event prediction |
| **Missing** | Indicators, domain imputation | Real-world data |

### Feature Engineering Checklist

```
□ 1. Understand data types
□ 2. Handle missing values
□ 3. Remove duplicates
□ 4. Detect and handle outliers
□ 5. Create transformations (log, sqrt, box-cox)
□ 6. Create interaction features
□ 7. Encode categorical variables
□ 8. Create date/time features
□ 9. Extract text features
□ 10. Select most informative features
□ 11. Validate feature impact
□ 12. Document feature definitions
```

---

## Conclusion

This primer covers the essential techniques of feature engineering. You now understand:

1. **Numeric features**: Transformations, binning, polynomial, interactions
2. **Categorical features**: One-hot, target encoding, frequency
3. **Text features**: Length, TF-IDF, embeddings
4. **Date features**: Cyclical encoding, differences
5. **Missing values**: Indicators, domain imputation
6. **Feature selection**: Correlation, model importance

**Next Steps:**
1. Practice with real datasets
2. Experiment with different feature types
3. Validate feature impact on performance
4. Build a feature engineering pipeline
5. Proceed to Part 1 of the series

---

*End of Primer 8*
