# Appendix E: Data Leakage Prevention Checklist

## What is Data Leakage?

Data leakage occurs when information from outside the training dataset is used to create the model, leading to overly optimistic performance estimates that don't generalize to new data. It's one of the most common and dangerous mistakes in machine learning.

### Types of Data Leakage

| Type | Description | Example |
|------|-------------|---------|
| **Target Leakage** | Target information leaks into features | Using future data to predict the past |
| **Feature Leakage** | Features contain information not available at prediction time | Using customer churn reason to predict churn |
| **Train-Test Leakage** | Information from test set influences training | Scaling before splitting |
| **Temporal Leakage** | Using future data to predict past events | Predicting stock prices with future data |
| **Group Leakage** | Related samples appear in both train and test sets | Same customer in both sets |
| **Preprocessing Leakage** | Transformations use information from both sets | Imputing with global mean |

---

## Preprocessing Leakage Checklist

### Data Splitting

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Split data BEFORE any preprocessing | Always split before scaling, imputing, or encoding |
| ✅ | Use stratification for classification | Maintains class distribution in both sets |
| ✅ | Use GroupKFold for grouped data | Prevents same group in train and test |
| ✅ | Use TimeSeriesSplit for temporal data | Maintains temporal order |
| ✅ | Set a random seed for reproducibility | Ensures consistent splits |

**Correct Approach**:
```python
from sklearn.model_selection import train_test_split

# ✅ CORRECT: Split first
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Then preprocess
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)  # Fit on training only
X_test_scaled = scaler.transform(X_test)        # Transform test with training parameters
```

**Incorrect Approach**:
```python
# ❌ WRONG: Scale before splitting
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # Uses entire dataset for scaling

# Then split - test data influenced training scaling
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)
```

### Imputation

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Fit imputers on training data only | Use training statistics for all imputation |
| ✅ | Use cross-validation for imputation parameters | Prevents leakage in CV |
| ✅ | Store imputation parameters for inference | Must use same parameters in production |
| ✅ | Consider missingness mechanism | MCAR, MAR, MNAR require different handling |
| ✅ | Track imputation values | For reproducibility and debugging |

**Correct Approach**:
```python
from sklearn.impute import SimpleImputer

# ✅ CORRECT: Fit on training only
imputer = SimpleImputer(strategy='median')
X_train_imputed = imputer.fit_transform(X_train)  # Fit on training
X_test_imputed = imputer.transform(X_test)        # Transform test with training median
```

### Scaling

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Fit scalers on training data only | Use training statistics for scaling |
| ✅ | Store scaler parameters for inference | Must use same parameters in production |
| ✅ | Consider robust scaling for outliers | Prevents outliers from skewing scaling |
| ✅ | Apply scaling after categorical encoding | Ensures consistent transformation |

**Correct Approach**:
```python
from sklearn.preprocessing import StandardScaler

# ✅ CORRECT: Fit on training only
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)  # Fit on training
X_test_scaled = scaler.transform(X_test)        # Transform test with training mean/std
```

### Encoding

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Fit encoders on training data only | Use training categories for encoding |
| ✅ | Handle unseen categories in test | Use handle_unknown='ignore' |
| ✅ | Store encoders for inference | Must use same encoding in production |
| ✅ | Consider target encoding carefully | Prone to leakage; use cross-validation |
| ✅ | Use out-of-fold encoding for target encoding | Prevents target leakage |

**Correct Approach**:
```python
from sklearn.preprocessing import OneHotEncoder

# ✅ CORRECT: Fit on training only
encoder = OneHotEncoder(handle_unknown='ignore')
X_train_encoded = encoder.fit_transform(X_train[['category']])
X_test_encoded = encoder.transform(X_test[['category']])
```

**Target Encoding with Cross-Validation**:
```python
# ✅ CORRECT: Use out-of-fold encoding
from sklearn.model_selection import StratifiedKFold

def target_encoding(X, y, column):
    """Target encode with cross-validation to prevent leakage."""
    kf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    encoded = np.zeros(len(X))
    
    for train_idx, val_idx in kf.split(X, y):
        # Compute target mean on training fold
        train_mean = y.iloc[train_idx].groupby(X.iloc[train_idx][column]).mean()
        # Apply to validation fold
        encoded[val_idx] = X.iloc[val_idx][column].map(train_mean)
    
    return encoded
```

---

## Feature Engineering Leakage Checklist

### Feature Creation

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Create features using training data only | Use training statistics for feature creation |
| ✅ | Store feature creation parameters | Must use same parameters in production |
| ✅ | Consider temporal dependencies | Avoid using future information |
| ✅ | Use cross-validation for feature selection | Prevents selection bias |
| ✅ | Document feature creation logic | For reproducibility |

**Correct Approach**:
```python
# ✅ CORRECT: Fit on training only
def create_features(X_train, X_test=None):
    # Use training data for statistics
    train_mean = X_train['feature'].mean()
    train_std = X_train['feature'].std()
    
    # Transform training
    X_train['feature_scaled'] = (X_train['feature'] - train_mean) / train_std
    
    # Transform test
    if X_test is not None:
        X_test['feature_scaled'] = (X_test['feature'] - train_mean) / train_std
    
    return X_train, X_test
```

### Feature Selection

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Perform feature selection inside cross-validation | Prevents selection bias |
| ✅ | Use training data only for feature selection | Test data should never influence selection |
| ✅ | Document feature selection criteria | For reproducibility |
| ✅ | Validate selected features on held-out data | Ensures generalization |

**Correct Approach**:
```python
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.model_selection import cross_val_score

# ✅ CORRECT: Feature selection inside CV
selector = SelectKBest(f_classif, k=10)
scores = cross_val_score(model, X, y, cv=5)  # Selection happens inside each fold
```

---

## Model Training Leakage Checklist

### Cross-Validation

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Use appropriate CV strategy | Stratified for classification, TimeSeries for temporal |
| ✅ | Ensure no leakage in CV folds | Same group not in both train and test |
| ✅ | Use group-aware splitting | For grouped data (patients, stores, etc.) |
| ✅ | Evaluate on held-out test set | Final evaluation after all tuning |
| ✅ | Document CV strategy | For reproducibility |

**Correct Approach**:
```python
from sklearn.model_selection import StratifiedKFold, cross_val_score

# ✅ CORRECT: Stratified for classification
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model, X, y, cv=cv)
```

### Hyperparameter Tuning

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Use nested cross-validation | Outer CV for evaluation, inner CV for tuning |
| ✅ | Tune on training data only | Never use test data for tuning |
| ✅ | Use validation set for tuning | Separate from test data |
| ✅ | Document tuning process | For reproducibility |

**Correct Approach**:
```python
from sklearn.model_selection import GridSearchCV, cross_val_score

# ✅ CORRECT: Nested CV
inner_cv = StratifiedKFold(n_splits=3, shuffle=True, random_state=42)
outer_cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

grid = GridSearchCV(model, param_grid, cv=inner_cv)
scores = cross_val_score(grid, X, y, cv=outer_cv)  # Outer CV for evaluation
```

---

## Temporal Leakage Checklist

### Time-Based Data

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Split data chronologically | Never use future data to predict past |
| ✅ | Use TimeSeriesSplit for CV | Maintains temporal order |
| ✅ | Consider time-based features carefully | Avoid features that leak future information |
| ✅ | Use walk-forward validation | Simulates real-world prediction |
| ✅ | Document temporal assumptions | For business context |

**Correct Approach**:
```python
from sklearn.model_selection import TimeSeriesSplit

# ✅ CORRECT: Time-based split
tscv = TimeSeriesSplit(n_splits=5)
scores = cross_val_score(model, X, y, cv=tscv)  # Maintains temporal order

# Or manual chronological split
split_idx = int(len(X) * 0.8)
X_train, X_test = X[:split_idx], X[split_idx:]
y_train, y_test = y[:split_idx], y[split_idx:]
```

---

## Production Leakage Checklist

### Inference Pipeline

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Use same preprocessing as training | Must match exactly |
| ✅ | Store all transformers | For consistent application |
| ✅ | Use same feature engineering | Must match training |
| ✅ | Handle missing values in production | Must be consistent with training |
| ✅ | Log predictions for monitoring | Detect drift and issues |

**Correct Approach**:
```python
# ✅ CORRECT: Save entire pipeline
from sklearn.pipeline import Pipeline
import joblib

pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler()),
    ('encoder', OneHotEncoder(handle_unknown='ignore')),
    ('model', RandomForestClassifier())
])

# Save pipeline
joblib.dump(pipeline, 'model_pipeline.joblib')

# In production: load and use
pipeline = joblib.load('model_pipeline.joblib')
predictions = pipeline.predict(new_data)
```

### Monitoring

| Check | Status | Notes |
|-------|--------|-------|
| ✅ | Monitor feature distributions | Detect data drift |
| ✅ | Monitor predictions | Detect prediction drift |
| ✅ | Monitor model performance | Detect performance degradation |
| ✅ | Set up alerts | For abnormal patterns |
| ✅ | Plan for model retraining | Based on drift detection |

---

## Common Leakage Scenarios and Solutions

### Scenario 1: Customer Churn Prediction

**Problem**: Using customer satisfaction survey data collected after churn decision.

**Solution**: 
- Only use features available before churn decision
- Establish clear timestamp boundaries
- Document feature availability timeline

### Scenario 2: Credit Default Prediction

**Problem**: Using post-loan default information as features.

**Solution**:
- Only use features available at loan application time
- Exclude any information from after loan origination
- Use strict temporal splits

### Scenario 3: Recommendation Systems

**Problem**: Using user-item interactions that occur after prediction time.

**Solution**:
- Use temporal splits in recommendation models
- Only use historical interactions for training
- Use time-based cross-validation

### Scenario 4: Time Series Forecasting

**Problem**: Using future values to predict current values.

**Solution**:
- Never use future values as features
- Use lag features appropriately
- Maintain temporal order in splits

---

## Quick Leakage Detection Checklist

### Ask These Questions:

1. **Is any information from the future used?**
   - ✅ If no → Good
   - ❌ If yes → Leakage!

2. **Are test set statistics used in training?**
   - ✅ If no → Good
   - ❌ If yes → Leakage!

3. **Could the target be inferred from features?**
   - ✅ If no → Good
   - ❌ If yes → Leakage!

4. **Are transformations fitted on test data?**
   - ✅ If no → Good
   - ❌ If yes → Leakage!

5. **Is the same group in both train and test?**
   - ✅ If no → Good
   - ❌ If yes → Leakage!

6. **Are features available at prediction time?**
   - ✅ If yes → Good
   - ❌ If no → Leakage!

### Warning Signs:

- **🚨 Model performance is too good** (e.g., >95% accuracy on complex problem)
- **🚨 Performance gap between train and test is small**
- **🚨 Feature importance shows highly predictive but suspicious features**
- **🚨 Model fails to generalize in production**
- **🚨 Some features are correlated with target in suspicious ways**

---

## Pipeline Validation Checklist

### Data Validation

```python
def validate_pipeline(X_train, X_test, y_train, y_test):
    """Validate pipeline for leakage."""
    # Check for target leakage
    target_corr = X_train.corrwith(y_train)
    suspicious_features = target_corr[abs(target_corr) > 0.9].index.tolist()
    if suspicious_features:
        print(f"⚠️ Suspicious features with target correlation >0.9: {suspicious_features}")
    
    # Check for data drift
    from scipy import stats
    for col in X_train.columns:
        if X_train[col].dtype in ['float64', 'int64']:
            ks_stat, p_value = stats.ks_2samp(X_train[col], X_test[col])
            if p_value < 0.05:
                print(f"⚠️ Potential drift in feature {col}: p={p_value:.4f}")
    
    # Check for feature overlap
    train_features = set(X_train.columns)
    test_features = set(X_test.columns)
    if train_features != test_features:
        print("⚠️ Feature mismatch between train and test")
    
    return True
```

### Cross-Validation Validation

```python
def validate_cv_approach(X, y, groups=None):
    """Validate CV strategy for leakage."""
    from sklearn.model_selection import StratifiedKFold, GroupKFold, TimeSeriesSplit
    
    if groups is not None:
        # Check for group leakage
        cv = GroupKFold(n_splits=5)
        for train_idx, test_idx in cv.split(X, y, groups):
            train_groups = set(groups[train_idx])
            test_groups = set(groups[test_idx])
            if train_groups & test_groups:
                print("⚠️ Same group in train and test! Use GroupKFold correctly.")
    
    # Check for temporal leakage
    if isinstance(X.index, pd.DatetimeIndex):
        cv = TimeSeriesSplit(n_splits=5)
        for train_idx, test_idx in cv.split(X):
            train_dates = X.index[train_idx]
            test_dates = X.index[test_idx]
            if (test_dates < train_dates).any():
                print("⚠️ Future data used for training! Use TimeSeriesSplit correctly.")
```

---

## Leakage-Free Pipeline Template

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier

def build_leakage_free_pipeline():
    """Build a pipeline with built-in leakage prevention."""
    
    # Define transformers
    numeric_transformer = Pipeline([
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler())
    ])
    
    categorical_transformer = Pipeline([
        ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
        ('encoder', OneHotEncoder(handle_unknown='ignore'))
    ])
    
    # Column transformer
    preprocessor = ColumnTransformer([
        ('numeric', numeric_transformer, numeric_features),
        ('categorical', categorical_transformer, categorical_features)
    ])
    
    # Full pipeline
    pipeline = Pipeline([
        ('preprocessor', preprocessor),
        ('model', RandomForestClassifier(random_state=42))
    ])
    
    return pipeline

# Usage
pipeline = build_leakage_free_pipeline()

# Split first
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train and evaluate
pipeline.fit(X_train, y_train)
score = pipeline.score(X_test, y_test)  # No leakage!
```

---

## Summary: The Golden Rules

1. **🔒 Split first, preprocess second**
2. **🔒 Fit on train, transform on test**
3. **🔒 Never use test data for decisions**
4. **🔒 Use appropriate CV for your data type**
5. **🔒 Save all transformers for production**
6. **🔒 Monitor for drift in production**
7. **🔒 Document all assumptions**
8. **🔒 Test for leakage regularly**

---

This appendix serves as a comprehensive reference for preventing data leakage throughout your ML pipeline. Use this checklist during development and review to catch potential issues before they reach production.
