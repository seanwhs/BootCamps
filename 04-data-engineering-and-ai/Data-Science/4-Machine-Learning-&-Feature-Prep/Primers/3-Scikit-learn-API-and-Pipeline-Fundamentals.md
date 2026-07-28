# Primer 3: Scikit-learn API and Pipeline Fundamentals

## Overview

This primer provides a deep dive into scikit-learn's API design and pipeline architecture. Understanding these concepts is crucial for building maintainable, production-ready machine learning systems. This primer covers the estimator API, transformers, pipelines, and column transformers—the building blocks of our main series.

---

## 1. The Scikit-learn API

### The Estimator API

Scikit-learn's API is built around a few simple interfaces:

```
┌─────────────────────────────────────────────────────────────────┐
│                     SCIKIT-LEARN API                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Estimator (Base Interface)                                    │
│  ├── fit(X, y)              # Learn from data                 │
│  ├── get_params()           # Get parameters                   │
│  └── set_params(**params)   # Set parameters                   │
│                                                                 │
│  Predictor (Estimator + Prediction)                            │
│  ├── predict(X)             # Make predictions                 │
│  ├── predict_proba(X)       # Get probabilities                │
│  └── score(X, y)            # Calculate score                  │
│                                                                 │
│  Transformer (Estimator + Transform)                           │
│  ├── transform(X)           # Transform data                   │
│  └── fit_transform(X, y)    # Fit and transform                │
│                                                                 │
│  Model (Predictor + Transformer)                               │
│  ├── All of the above                                         │
│  └── (Some models also implement transform)                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Methods Explained

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler

# Estimator: fit
model = RandomForestClassifier()
model.fit(X_train, y_train)  # Learns from training data

# Predictor: predict
y_pred = model.predict(X_test)  # Makes predictions

# Predictor: predict_proba
y_proba = model.predict_proba(X_test)  # Returns probabilities

# Predictor: score
score = model.score(X_test, y_test)  # Calculates accuracy

# Transformer: fit_transform
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # Fits and transforms in one step

# Transformer: transform
X_test_scaled = scaler.transform(X_test)  # Only transforms (uses fitted parameters)

# Get/set parameters
params = model.get_params()
model.set_params(n_estimators=200)
```

### The Fit-Transform Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE FIT-TRANSFORM PATTERN                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  TRAINING:                                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │  X_train        │───▶│  scaler.fit()   │───▶│  scaler     │ │
│  │                 │    │                 │    │  (fitted)   │ │
│  └─────────────────┘    └─────────────────┘    └─────────────┘ │
│                                    │                           │
│                                    ▼                           │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │  X_train        │───▶│  scaler.transform() │───▶ X_train_scaled│
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  TESTING (Inference):                                          │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │  X_test         │───▶│  scaler.transform()│───▶ X_test_scaled│
│  └─────────────────┘    └─────────────────┘    └─────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Pattern Matters

1. **No Data Leakage**: Fit parameters only on training data
2. **Reproducibility**: Same transformations applied consistently
3. **Production Readiness**: Store fitted transformers for inference

---

## 2. Transformers

### What is a Transformer?

A transformer is an object that transforms data from one representation to another.

```python
from sklearn.base import TransformerMixin, BaseEstimator

class CustomTransformer(BaseEstimator, TransformerMixin):
    """Custom transformer example."""
    
    def __init__(self, param1=1):
        self.param1 = param1
    
    def fit(self, X, y=None):
        # Learn transformation parameters
        # Store them as attributes
        self.mean_ = X.mean(axis=0)
        self.std_ = X.std(axis=0)
        return self
    
    def transform(self, X):
        # Apply transformation using fitted parameters
        return (X - self.mean_) / self.std_
    
    def fit_transform(self, X, y=None):
        # Default implementation: fit then transform
        return self.fit(X, y).transform(X)
```

### Built-in Transformers

#### Preprocessing Transformers

```python
from sklearn.preprocessing import (
    StandardScaler,      # Standardize (mean=0, std=1)
    MinMaxScaler,        # Scale to [0, 1]
    RobustScaler,        # Scale using median and IQR
    OneHotEncoder,       # One-hot encode categories
    OrdinalEncoder,      # Encode categories as integers
    LabelEncoder,        # Encode target labels
    PowerTransformer,    # Box-Cox/Yeo-Johnson transform
    QuantileTransformer  # Quantile-based transform
)

# Examples
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

encoder = OneHotEncoder(sparse_output=False)
X_encoded = encoder.fit_transform(X_categorical)

# Handle unknown categories
encoder = OneHotEncoder(handle_unknown='ignore')
```

#### Feature Selection Transformers

```python
from sklearn.feature_selection import (
    VarianceThreshold,    # Remove low-variance features
    SelectKBest,          # Select top K features
    SelectPercentile,     # Select top percentile
    RFE,                  # Recursive feature elimination
    SelectFromModel       # Select based on model importance
)

# Variance threshold
selector = VarianceThreshold(threshold=0.01)
X_selected = selector.fit_transform(X)

# Select K best
selector = SelectKBest(k=10)
X_selected = selector.fit_transform(X, y)

# Select from model
selector = SelectFromModel(RandomForestClassifier())
X_selected = selector.fit_transform(X, y)
```

#### Imputation Transformers

```python
from sklearn.impute import (
    SimpleImputer,        # Simple strategies
    KNNImputer,           # K-Nearest Neighbors imputation
    IterativeImputer      # Multiple imputation
)

# Simple imputation
imputer = SimpleImputer(strategy='median')
X_imputed = imputer.fit_transform(X)

# KNN imputation
imputer = KNNImputer(n_neighbors=5)
X_imputed = imputer.fit_transform(X)

# Iterative imputation
from sklearn.experimental import enable_iterative_imputer
imputer = IterativeImputer(max_iter=10)
X_imputed = imputer.fit_transform(X)
```

#### Decomposition Transformers

```python
from sklearn.decomposition import PCA, TruncatedSVD
from sklearn.manifold import TSNE

# PCA
pca = PCA(n_components=0.95)  # Keep 95% variance
X_pca = pca.fit_transform(X)

# t-SNE (visualization)
tsne = TSNE(n_components=2)
X_tsne = tsne.fit_transform(X)
```

### Creating Custom Transformers

```python
from sklearn.base import BaseEstimator, TransformerMixin

class ColumnSelector(BaseEstimator, TransformerMixin):
    """Select specific columns."""
    
    def __init__(self, columns):
        self.columns = columns
    
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        return X[self.columns]

class FeatureCreator(BaseEstimator, TransformerMixin):
    """Create new features."""
    
    def __init__(self, add_polynomial=False):
        self.add_polynomial = add_polynomial
    
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        X_new = X.copy()
        
        # Add interaction features
        if self.add_polynomial:
            X_new['x1_x2'] = X_new['feature1'] * X_new['feature2']
            X_new['x1_sq'] = X_new['feature1'] ** 2
        
        return X_new
```

---

## 3. Pipelines

### What is a Pipeline?

A pipeline chains multiple transformers together and ends with an estimator. It ensures that all transformations are applied consistently.

```
┌─────────────────────────────────────────────────────────────────┐
│                        PIPELINE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Input ──▶ Transformer 1 ──▶ Transformer 2 ──▶ Model ──▶ Output│
│                                                                 │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    │
│  │  X_raw  │───▶│ Scaler  │───▶│  PCA    │───▶│ XGBoost │───▶│
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Building a Pipeline

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier

# Basic pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('pca', PCA(n_components=10)),
    ('classifier', RandomForestClassifier())
])

# Fit and predict
pipeline.fit(X_train, y_train)
y_pred = pipeline.predict(X_test)

# Access pipeline steps
pipeline.named_steps['scaler']  # Access scaler
pipeline.steps[1]               # Access by index

# Get parameters
pipeline.get_params()  # All parameters
pipeline.get_params()['classifier__n_estimators']

# Set parameters
pipeline.set_params(classifier__n_estimators=200)

# Grid search over pipeline parameters
from sklearn.model_selection import GridSearchCV

param_grid = {
    'scaler__with_mean': [True, False],
    'pca__n_components': [5, 10, 15],
    'classifier__n_estimators': [50, 100]
}

grid = GridSearchCV(pipeline, param_grid, cv=5)
grid.fit(X_train, y_train)
```

### Pipeline Methods

```python
# All pipeline methods
pipeline.fit(X, y)           # Fit all steps
pipeline.transform(X)        # Transform through all transformers
pipeline.fit_transform(X, y) # Fit and transform
pipeline.predict(X)          # Predict using final estimator
pipeline.predict_proba(X)    # Get probabilities
pipeline.score(X, y)         # Calculate score

# Accessing intermediate steps
pipeline.named_steps['scaler']  # Access by name
pipeline[:-1]                   # Get pipeline without final estimator
pipeline[-1]                    # Get final estimator
```

---

## 4. Column Transformers

### What is a Column Transformer?

A column transformer applies different transformations to different columns.

```
┌─────────────────────────────────────────────────────────────────┐
│                   COLUMN TRANSFORMER                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Input DataFrame                                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  age  │  income  │  gender  │  city    │  target        │  │
│  ├───────┼─────────┼──────────┼──────────┼────────────────┤  │
│  │  25   │  50000  │  Male    │  NYC     │  0             │  │
│  │  30   │  60000  │  Female  │  LA      │  1             │  │
│  └───────┴─────────┴──────────┴──────────┴────────────────┘  │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Numeric         │  │  Categorical    │  │  Target         │ │
│  │  age, income     │  │  gender, city   │  │  (excluded)     │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│         │                    │                    │             │
│         ▼                    ▼                    │             │
│  ┌──────────────┐  ┌─────────────────┐          │             │
│  │   Scale      │  │   One-Hot       │          │             │
│  │   Impute     │  │   Encode        │          │             │
│  └──────────────┘  └─────────────────┘          │             │
│         │                    │                    │             │
│         └────────┬───────────┘                    │             │
│                  ▼                                │             │
│  ┌─────────────────────────────────────┐          │             │
│  │         Combined Features           │          │             │
│  └─────────────────────────────────────┘          │             │
│                                                    │             │
└─────────────────────────────────────────────────────────────────┘
```

### Building a Column Transformer

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

# Define column groups
numeric_features = ['age', 'income', 'tenure']
categorical_features = ['gender', 'city', 'contract_type']

# Create transformers
numeric_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

categorical_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
    ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
])

# Create column transformer
preprocessor = ColumnTransformer([
    ('numeric', numeric_transformer, numeric_features),
    ('categorical', categorical_transformer, categorical_features)
])

# Use in pipeline
pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier())
])

# Fit and predict
pipeline.fit(X_train, y_train)
y_pred = pipeline.predict(X_test)
```

### Column Transformer Advanced Features

```python
# Using remainder parameter
preprocessor = ColumnTransformer([
    ('numeric', numeric_transformer, numeric_features),
    ('categorical', categorical_transformer, categorical_features)
], remainder='drop')  # Drop unselected columns

# Using passthrough
preprocessor = ColumnTransformer([
    ('numeric', numeric_transformer, numeric_features),
    ('categorical', categorical_transformer, categorical_features)
], remainder='passthrough')  # Keep unselected columns

# Multiple transformations on same columns
preprocessor = ColumnTransformer([
    ('scale', StandardScaler(), numeric_features),
    ('poly', PolynomialFeatures(degree=2), numeric_features)
])

# Dropping first category to avoid multicollinearity
encoder = OneHotEncoder(drop='first')
```

---

## 5. Feature Union

### What is Feature Union?

Feature union combines multiple feature extraction methods.

```
┌─────────────────────────────────────────────────────────────────┐
│                      FEATURE UNION                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Input ──┬─── Transformer 1 ──▶ Feature Set 1 ─┐              │
│          │                                        │              │
│          ├─── Transformer 2 ──▶ Feature Set 2 ──┤              │
│          │                                        │              │
│          └─── Transformer 3 ──▶ Feature Set 3 ──┘              │
│                                                               │
│                                               │              │
│                                               ▼              │
│                                     Combined Features        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Using Feature Union

```python
from sklearn.pipeline import FeatureUnion
from sklearn.decomposition import PCA
from sklearn.feature_selection import SelectKBest

# Create feature union
feature_union = FeatureUnion([
    ('pca', PCA(n_components=10)),
    ('select', SelectKBest(k=10))
])

# Use in pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('features', feature_union),
    ('classifier', RandomForestClassifier())
])
```

---

## 6. Advanced Pipeline Patterns

### Pipeline with ColumnTransformer and FeatureUnion

```python
# Complex pipeline combining all concepts
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import FeatureUnion, Pipeline

# Feature extraction
feature_extraction = FeatureUnion([
    ('pca', PCA(n_components=10)),
    ('select', SelectKBest(k=10))
])

# Preprocessing
preprocessor = ColumnTransformer([
    ('numeric', StandardScaler(), numeric_features),
    ('categorical', OneHotEncoder(), categorical_features)
])

# Full pipeline
pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('feature_extraction', feature_extraction),
    ('classifier', RandomForestClassifier())
])
```

### Pipeline with Custom Transformers

```python
# Custom transformer in pipeline
class OutlierRemover(BaseEstimator, TransformerMixin):
    def __init__(self, threshold=3):
        self.threshold = threshold
    
    def fit(self, X, y=None):
        self.means_ = X.mean(axis=0)
        self.stds_ = X.std(axis=0)
        return self
    
    def transform(self, X):
        # Cap outliers
        X_clipped = X.copy()
        for i in range(X.shape[1]):
            upper = self.means_[i] + self.threshold * self.stds_[i]
            lower = self.means_[i] - self.threshold * self.stds_[i]
            X_clipped[:, i] = np.clip(X[:, i], lower, upper)
        return X_clipped

# Use in pipeline
pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('outlier_remover', OutlierRemover(threshold=3)),
    ('scaler', StandardScaler()),
    ('classifier', RandomForestClassifier())
])
```

### Pipeline with Metadata

```python
from sklearn.pipeline import make_pipeline

# Shorter syntax
pipeline = make_pipeline(
    StandardScaler(),
    PCA(n_components=10),
    RandomForestClassifier()
)

# Access steps (automatically named)
pipeline.steps[0]  # ('standardscaler', StandardScaler())
pipeline.steps[1]  # ('pca', PCA())

# Get feature names from pipeline
def get_feature_names(pipeline):
    """Get feature names after transformation."""
    names = []
    for name, transformer in pipeline.steps[:-1]:
        if hasattr(transformer, 'get_feature_names_out'):
            names = transformer.get_feature_names_out(names)
        elif hasattr(transformer, 'get_feature_names'):
            names = transformer.get_feature_names(names)
    return names
```

---

## 7. Saving and Loading Pipelines

### Using Joblib

```python
import joblib

# Save pipeline
joblib.dump(pipeline, 'pipeline.joblib')

# Load pipeline
pipeline = joblib.load('pipeline.joblib')

# Use loaded pipeline
y_pred = pipeline.predict(X_test)
```

### Using Pickle

```python
import pickle

# Save pipeline
with open('pipeline.pkl', 'wb') as f:
    pickle.dump(pipeline, f)

# Load pipeline
with open('pipeline.pkl', 'rb') as f:
    pipeline = pickle.load(f)
```

### Best Practices

```python
# Save with metadata
def save_pipeline(pipeline, path, metadata=None):
    """Save pipeline with metadata."""
    data = {
        'pipeline': pipeline,
        'metadata': metadata or {},
        'timestamp': pd.Timestamp.now().isoformat()
    }
    joblib.dump(data, path)

# Load with metadata
def load_pipeline(path):
    """Load pipeline with metadata."""
    data = joblib.load(path)
    return data['pipeline'], data.get('metadata', {})
```

---

## 8. Pipeline Debugging

### Inspecting Pipeline Steps

```python
# Get all parameters
pipeline.get_params()

# Get specific parameter
pipeline.get_params()['classifier__n_estimators']

# Check step output
X_transformed = pipeline[:-1].transform(X_test)

# Check feature names
if hasattr(pipeline[:-1], 'get_feature_names_out'):
    feature_names = pipeline[:-1].get_feature_names_out()
    print(feature_names)
```

### Common Pipeline Issues

```python
# Issue: Pipeline not fitted
try:
    y_pred = pipeline.predict(X_test)
except NotFittedError as e:
    print(f"Pipeline not fitted: {e}")
    pipeline.fit(X_train, y_train)

# Issue: Feature mismatch
try:
    pipeline.transform(X_test)
except ValueError as e:
    print(f"Feature mismatch: {e}")
    # Check feature names
    if hasattr(pipeline[:-1], 'feature_names_in_'):
        required = pipeline[:-1].feature_names_in_
        missing = set(required) - set(X_test.columns)
        print(f"Missing features: {missing}")

# Issue: Unknown categories
try:
    pipeline.predict(X_test)
except ValueError as e:
    if 'unknown categories' in str(e):
        # Handle unknown categories in encoder
        pipeline.named_steps['preprocessor'].named_transformers_['categorical']\
                .set_params(handle_unknown='ignore')
```

---

## 9. Quick Reference

### Common Pipeline Patterns

```python
# Basic Pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model', RandomForestClassifier())
])

# Pipeline with ColumnTransformer
pipeline = Pipeline([
    ('preprocessor', ColumnTransformer([
        ('numeric', StandardScaler(), numeric_cols),
        ('categorical', OneHotEncoder(), cat_cols)
    ])),
    ('model', RandomForestClassifier())
])

# Pipeline with FeatureUnion
pipeline = Pipeline([
    ('features', FeatureUnion([
        ('pca', PCA()),
        ('select', SelectKBest())
    ])),
    ('model', RandomForestClassifier())
])

# Nested Pipeline
pipeline = Pipeline([
    ('preprocessor', ColumnTransformer([
        ('numeric', Pipeline([
            ('imputer', SimpleImputer()),
            ('scaler', StandardScaler())
        ]), numeric_cols)
    ])),
    ('model', RandomForestClassifier())
])
```

### Pipeline Checklist

```
□ 1. Split data first (X_train, X_test)
□ 2. Fit pipeline on training data only
□ 3. Transform test data using fitted pipeline
□ 4. Use ColumnTransformer for heterogeneous data
□ 5. Chain transformers in logical order
□ 6. Handle unknown categories in production
□ 7. Save pipeline for inference
□ 8. Document feature transformations
□ 9. Test pipeline on sample data
□ 10. Monitor for data drift
```

---

## Conclusion

This primer covers the fundamentals of scikit-learn's API and pipeline architecture. Understanding these concepts is essential for:

1. **Building reproducible workflows**: Pipelines ensure consistent transformations
2. **Preventing data leakage**: Fit on train, transform on test
3. **Production readiness**: Save and load pipelines easily
4. **Hyperparameter tuning**: Grid search over pipeline parameters
5. **Code organization**: Clean, maintainable code

**Next Steps:**
1. Practice building pipelines with different transformers
2. Experiment with ColumnTransformer
3. Use GridSearchCV with pipelines
4. Proceed to Part 1 of the series

---

*End of Primer 3*
