# Primer 2: Machine Learning Fundamentals

## Overview

This primer provides a crash course in the fundamental concepts of machine learning. It covers the types of machine learning, the core workflow, evaluation concepts, and key terminology. If you're already familiar with ML basics, you can skip this primer. If you're new to ML or need a refresher, this primer will get you up to speed.

---

## 1. What is Machine Learning?

### Definition

Machine Learning is a subset of artificial intelligence that enables systems to learn and improve from experience without being explicitly programmed.

**Formal Definition**: A computer program is said to learn from experience E with respect to some task T and performance measure P, if its performance at T, as measured by P, improves with experience E. — Tom Mitchell

### The Three Types of Learning

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPES OF MACHINE LEARNING                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗  ╔══════════════╗ │
│  ║   SUPERVISED      ║  ║  UNSUPERVISED     ║  ║ REINFORCEMENT║ │
│  ║   LEARNING        ║  ║  LEARNING         ║  ║  LEARNING    ║ │
│  ╚═══════════════════╝  ╚═══════════════════╝  ╚══════════════╝ │
│                                                                 │
│  Labeled data        │  Unlabeled data        │  Agent learns   │
│  Predict labels      │  Find patterns        │  through actions │
│  Classification      │  Clustering           │  and rewards     │
│  Regression          │  Dimensionality       │  Trial and error │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Supervised Learning

| Type | Goal | Examples |
|------|------|----------|
| **Classification** | Predict a category | Spam detection, Image recognition |
| **Regression** | Predict a continuous value | House prices, Stock prices |
| **Multi-class** | Predict among >2 categories | Digit recognition |
| **Multi-label** | Predict multiple categories | Tagging images |

### Unsupervised Learning

| Type | Goal | Examples |
|------|------|----------|
| **Clustering** | Group similar items | Customer segmentation |
| **Dimensionality Reduction** | Reduce features | Visualization, Compression |
| **Anomaly Detection** | Find unusual items | Fraud detection |

### Reinforcement Learning

| Concept | Description |
|---------|-------------|
| **Agent** | The learner/decision maker |
| **Environment** | What the agent interacts with |
| **Action** | What the agent can do |
| **State** | Current situation |
| **Reward** | Feedback signal |
| **Policy** | Strategy for choosing actions |

---

## 2. The Machine Learning Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    ML WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. PROBLEM DEFINITION                                         │
│     └── Define the business problem and success metrics        │
│                                                                 │
│  2. DATA COLLECTION                                            │
│     └── Gather relevant data from various sources              │
│                                                                 │
│  3. DATA PREPARATION                                           │
│     └── Clean, preprocess, and format the data                 │
│                                                                 │
│  4. EXPLORATORY DATA ANALYSIS (EDA)                            │
│     └── Understand data patterns and relationships             │
│                                                                 │
│  5. FEATURE ENGINEERING                                        │
│     └── Create and select informative features                 │
│                                                                 │
│  6. MODEL SELECTION                                            │
│     └── Choose appropriate algorithms                          │
│                                                                 │
│  7. TRAINING                                                   │
│     └── Train the model on training data                       │
│                                                                 │
│  8. EVALUATION                                                 │
│     └── Assess model performance on test data                  │
│                                                                 │
│  9. HYPERPARAMETER TUNING                                      │
│     └── Optimize model parameters                              │
│                                                                 │
│  10. DEPLOYMENT                                                │
│     └── Deploy model to production                             │
│                                                                 │
│  11. MONITORING                                                │
│     └── Track performance and detect drift                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Key ML Concepts

### Data Concepts

| Concept | Definition | Example |
|---------|------------|---------|
| **Instance** | A single data point | A customer record |
| **Feature** | An attribute/property of an instance | Age, Income |
| **Label/Target** | The value to predict | Churn (Yes/No) |
| **Sample** | The entire dataset | All customer records |
| **Training Set** | Data used to train the model | 80% of data |
| **Test Set** | Data used to evaluate the model | 20% of data |
| **Validation Set** | Data used to tune hyperparameters | 10% of data |

### Model Concepts

| Concept | Definition | Example |
|---------|------------|---------|
| **Parameters** | Learned from data during training | Weights in regression |
| **Hyperparameters** | Set before training | Learning rate, tree depth |
| **Overfitting** | Model fits training data too well | High train accuracy, low test accuracy |
| **Underfitting** | Model fails to capture patterns | Low train accuracy, low test accuracy |
| **Bias** | Error from simplifying assumptions | Underfitting |
| **Variance** | Error from sensitivity to data | Overfitting |

### The Bias-Variance Tradeoff

```
┌─────────────────────────────────────────────────────────────────┐
│                   BIAS-VARIANCE TRADEOFF                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Error                                                         │
│    ▲                                                           │
│    │                                   Total Error             │
│    │                              ╭────────╮                   │
│    │                         ╭───╱          ╲───╮             │
│    │                    ╭───╱                 ╲───╮         │
│    │               ╭───╱                         ╲───╮     │
│    │          ╭────╱    Variance                    ╲────╮ │
│    │    ╭─────╱                                        ╲───│
│    │───╱───────────────────────────────────────────────────╲│
│    │  Bias                                              │ │
│    │                                                   │ │
│    └───────────────────────────────────────────────────────→  │
│         Simple ←─────────────────────→ Complex             │
│                                                                 │
│  Underfitting ←────────────────────────────────→ Overfitting   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Model Evaluation

#### Classification Metrics

| Metric | Formula | Best For |
|--------|---------|----------|
| **Accuracy** | (TP+TN)/(TP+TN+FP+FN) | Balanced classes |
| **Precision** | TP/(TP+FP) | Minimize false positives |
| **Recall** | TP/(TP+FN) | Minimize false negatives |
| **F1 Score** | 2*P*R/(P+R) | Imbalanced classes |
| **ROC-AUC** | Area under ROC curve | Overall performance |
| **Log Loss** | -Σ y*log(ŷ) | Probability calibration |

#### Regression Metrics

| Metric | Formula | Best For |
|--------|---------|----------|
| **MSE** | Σ(y-ŷ)²/n | Penalizing large errors |
| **RMSE** | √MSE | Interpretable errors |
| **MAE** | Σ|y-ŷ|/n | Robust to outliers |
| **R²** | 1 - SS_res/SS_tot | Variance explained |
| **MAPE** | Σ|(y-ŷ)/y|/n | Relative errors |

---

## 4. Essential Algorithms

### Classification Algorithms

#### Logistic Regression

```python
from sklearn.linear_model import LogisticRegression

model = LogisticRegression()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)
```

**When to use**: Linear relationships, interpretability needed, baseline model

#### Decision Tree

```python
from sklearn.tree import DecisionTreeClassifier

model = DecisionTreeClassifier(max_depth=5)
model.fit(X_train, y_train)
```

**When to use**: Interpretability, non-linear relationships, small datasets

#### Random Forest

```python
from sklearn.ensemble import RandomForestClassifier

model = RandomForestClassifier(n_estimators=100)
model.fit(X_train, y_train)
```

**When to use**: Good default, handles non-linearity, feature importance

#### XGBoost

```python
import xgboost as xgb

model = xgb.XGBClassifier(n_estimators=100)
model.fit(X_train, y_train)
```

**When to use**: Best performance, large datasets, competitions

#### SVM

```python
from sklearn.svm import SVC

model = SVC(kernel='rbf')
model.fit(X_train, y_train)
```

**When to use**: High-dimensional data, clear margins, smaller datasets

### Regression Algorithms

#### Linear Regression

```python
from sklearn.linear_model import LinearRegression

model = LinearRegression()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
```

#### Ridge Regression

```python
from sklearn.linear_model import Ridge

model = Ridge(alpha=1.0)
model.fit(X_train, y_train)
```

#### Lasso Regression

```python
from sklearn.linear_model import Lasso

model = Lasso(alpha=0.01)
model.fit(X_train, y_train)
```

### Clustering Algorithms

#### K-Means

```python
from sklearn.cluster import KMeans

kmeans = KMeans(n_clusters=3)
labels = kmeans.fit_predict(X)
```

#### DBSCAN

```python
from sklearn.cluster import DBSCAN

dbscan = DBSCAN(eps=0.5, min_samples=5)
labels = dbscan.fit_predict(X)
```

---

## 5. Feature Engineering

### Feature Types

| Type | Description | Examples |
|------|-------------|----------|
| **Numerical** | Continuous values | Age, Income |
| **Categorical** | Discrete categories | Gender, Country |
| **Ordinal** | Ordered categories | Education level |
| **Text** | Unstructured text | Reviews, Comments |
| **Time** | Temporal data | Date, Timestamp |
| **Image** | Pixel data | Photos, Scans |

### Common Transformations

```python
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, MinMaxScaler, OneHotEncoder
from sklearn.feature_extraction.text import TfidfVectorizer

# Scaling
scaler = StandardScaler()        # Mean=0, Std=1
scaler = MinMaxScaler()          # Range [0,1]

# Encoding
encoder = OneHotEncoder()        # Binary columns for categories

# Text features
vectorizer = TfidfVectorizer()   # Convert text to TF-IDF vectors

# Missing values
from sklearn.impute import SimpleImputer
imputer = SimpleImputer(strategy='median')

# Polynomial features
from sklearn.preprocessing import PolynomialFeatures
poly = PolynomialFeatures(degree=2)
```

### Feature Selection Methods

| Method | Description | Example |
|--------|-------------|---------|
| **Filter** | Statistical measures | Correlation, Chi-square |
| **Wrapper** | Use model to select | RFE, Forward selection |
| **Embedded** | Feature importance from model | Lasso, Random Forest |
| **Hybrid** | Combination of methods | AutoFeatureSelector |

---

## 6. Validation

### Cross-Validation

```python
from sklearn.model_selection import cross_val_score, KFold, StratifiedKFold

# K-Fold CV
kf = KFold(n_splits=5, shuffle=True)
scores = cross_val_score(model, X, y, cv=kf)

# Stratified K-Fold (classification)
skf = StratifiedKFold(n_splits=5, shuffle=True)
scores = cross_val_score(model, X, y, cv=skf)
```

### Train-Test-Validation Split

```python
from sklearn.model_selection import train_test_split

# 80% train, 10% validation, 10% test
X_temp, X_test, y_temp, y_test = train_test_split(X, y, test_size=0.1)
X_train, X_val, y_train, y_val = train_test_split(X_temp, y_temp, test_size=0.111)  # 10% of original
```

---

## 7. Hyperparameter Tuning

### Grid Search

```python
from sklearn.model_selection import GridSearchCV

param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [3, 5, 7],
    'learning_rate': [0.01, 0.1, 0.3]
}

grid = GridSearchCV(
    model,
    param_grid,
    cv=5,
    scoring='accuracy'
)
grid.fit(X_train, y_train)

print(grid.best_params_)
print(grid.best_score_)
```

### Random Search

```python
from sklearn.model_selection import RandomizedSearchCV

param_dist = {
    'n_estimators': range(50, 300, 10),
    'max_depth': range(3, 11),
    'learning_rate': [0.01, 0.05, 0.1, 0.3]
}

random = RandomizedSearchCV(
    model,
    param_dist,
    n_iter=50,
    cv=5,
    random_state=42
)
random.fit(X_train, y_train)
```

### Bayesian Optimization (Optuna)

```python
import optuna

def objective(trial):
    params = {
        'n_estimators': trial.suggest_int('n_estimators', 50, 300),
        'max_depth': trial.suggest_int('max_depth', 3, 10),
        'learning_rate': trial.suggest_float('learning_rate', 0.01, 0.3)
    }
    model = XGBClassifier(**params)
    score = cross_val_score(model, X_train, y_train, cv=5, scoring='accuracy').mean()
    return score

study = optuna.create_study(direction='maximize')
study.optimize(objective, n_trials=100)
print(study.best_params)
```

---

## 8. Common Pitfalls

### 1. Data Leakage

**Problem**: Information from test set influences training

**Solution**:
- Split data BEFORE preprocessing
- Fit transformers on train only
- Use appropriate CV strategies
- Never use future data

```python
# ❌ WRONG
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # Uses all data!
X_train, X_test = train_test_split(X_scaled)

# ✅ CORRECT
X_train, X_test = train_test_split(X)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)  # Fit on train only
X_test_scaled = scaler.transform(X_test)
```

### 2. Overfitting

**Signs**:
- Training accuracy > 90%, test accuracy < 70%
- Very complex models
- High variance

**Solutions**:
- More training data
- Simpler models
- Regularization
- Cross-validation
- Feature selection
- Early stopping

### 3. Imbalanced Data

**Problem**: One class dominates the dataset

**Solutions**:
- Oversampling (SMOTE)
- Undersampling
- Class weights
- Ensemble methods
- Appropriate metrics (F1, PR-AUC)

```python
# Class weights
model = RandomForestClassifier(class_weight='balanced')

# SMOTE
from imblearn.over_sampling import SMOTE
smote = SMOTE()
X_resampled, y_resampled = smote.fit_resample(X, y)
```

---

## 9. Quick Reference

### Algorithm Selection Guide

```
┌─────────────────────────────────────────────────────────────────┐
│  PROBLEM TYPE          RECOMMENDED ALGORITHMS                  │
├─────────────────────────────────────────────────────────────────┤
│  Binary Classification │ Logistic Regression, XGBoost, RF      │
│  Multi-class           │ XGBoost, RF, SVM                     │
│  Regression            │ Linear Regression, XGBoost, RF       │
│  Clustering            │ K-Means, DBSCAN, Hierarchical        │
│  Dimensionality        │ PCA, t-SNE, UMAP                    │
│  Anomaly Detection     │ Isolation Forest, DBSCAN             │
└─────────────────────────────────────────────────────────────────┘
```

### Common Scikit-learn Methods

```python
# Every sklearn model has these methods:
model.fit(X_train, y_train)          # Train the model
model.predict(X_test)                # Make predictions
model.predict_proba(X_test)          # Get probabilities
model.score(X_test, y_test)          # Calculate score
model.get_params()                   # Get parameters
model.set_params(**params)           # Set parameters
```

### Python ML Checklist

```python
# 1. Import libraries
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

# 2. Load data
df = pd.read_csv('data.csv')

# 3. Prepare data
X = df.drop('target', axis=1)
y = df['target']

# 4. Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# 5. Preprocess
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)

# 6. Train model
model = RandomForestClassifier()
model.fit(X_train_scaled, y_train)

# 7. Evaluate
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
```

---

## Conclusion

This primer covers the fundamental concepts of machine learning. If you understand these concepts, you're ready to dive into the main series. Key takeaways:

1. **Understand your problem**: Classification vs Regression vs Clustering
2. **Prepare your data**: Clean, preprocess, and engineer features
3. **Choose appropriate models**: Start simple, then complex
4. **Validate properly**: Use cross-validation, avoid leakage
5. **Evaluate with metrics**: Choose metrics that match your business objective
6. **Avoid common pitfalls**: Overfitting, data leakage, imbalance

**Next Steps:**
1. Practice with simple datasets (Iris, Titanic)
2. Experiment with different algorithms
3. Learn about feature engineering
4. Proceed to Part 1 of the series

---

*End of Primer 2*
