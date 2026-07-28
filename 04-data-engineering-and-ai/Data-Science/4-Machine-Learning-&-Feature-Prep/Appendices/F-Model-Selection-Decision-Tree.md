# Appendix F: Model Selection Decision Tree

## Overview

Choosing the right model for your machine learning problem is one of the most critical decisions you'll make. This appendix provides a systematic decision tree to guide your model selection process based on your data characteristics, problem type, and requirements.

---

## Model Selection Flowchart

```
Start
  │
  ▼
┌─────────────────────────────────┐
│  What is your problem type?     │
└─────────────────────────────────┘
  │
  ├─── Classification ────┬─── Regression ────┐
  │                       │                   │
  ▼                       ▼                   ▼
┌──────────────────┐ ┌────────────────┐ ┌──────────────┐
│ Is it binary?    │ │ Is it binary?  │ │ Is it linear?│
└──────────────────┘ └────────────────┘ └──────────────┘
  │        │          │        │          │        │
 Yes      No         Yes      No         Yes      No
  │        │          │        │          │        │
  ▼        ▼          ▼        ▼          ▼        ▼
┌──┐    ┌──┐       ┌──┐    ┌──┐       ┌──┐    ┌──┐
│  │    │  │       │  │    │  │       │  │    │  │
│  │    │  │       │  │    │  │       │  │    │  │
```

---

## Detailed Decision Tree

### Step 1: Determine Problem Type

```
┌─────────────────────────────────────────────────────────────┐
│                    WHAT IS YOUR PROBLEM?                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ╔═══════════════════╗  ╔═══════════════════╗             │
│  ║  CLASSIFICATION   ║  ║   REGRESSION      ║             │
│  ║  Predict a label  ║  ║  Predict a value  ║             │
│  ╚═══════════════════╝  ╚═══════════════════╝             │
│         │                        │                         │
│         ▼                        ▼                         │
│  Binary or Multi-class?    Linear or Non-linear?           │
│                                                             │
│  ╔═══════════════════╗  ╔═══════════════════╗             │
│  ║  CLUSTERING       ║  ║   OTHER           ║             │
│  ║  No labels        ║  ║  Anomaly, etc.    ║             │
│  ╚═══════════════════╝  ╚═══════════════════╝             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Step 2: Classification Decision Tree

```
START: Classification
  │
  ▼
┌─────────────────────────────────────────────────────────────┐
│             IS IT BINARY OR MULTI-CLASS?                    │
└─────────────────────────────────────────────────────────────┘
  │                    │
  BINARY               MULTI-CLASS
  │                    │
  ▼                    ▼
┌──────────────────┐  ┌──────────────────────────────────────┐
│  IS IT IMBALANCED?│  │  HOW MANY CLASSES?                   │
└──────────────────┘  └──────────────────────────────────────┘
  │        │           │           │
  Yes      No          Few         Many
  │        │           │           │
  ▼        ▼           ▼           ▼
┌──────┐ ┌──────┐  ┌──────────┐ ┌──────────┐
│SMOTE │ │ Train│  │One-vs-Rest│ │Linear    │
│RUS   │ │      │  │           │ │SVM       │
│Cost  │ │      │  │           │ │          │
└──────┘ └──────┘  └──────────┘ └──────────┘
  │        │           │           │
  ▼        ▼           ▼           ▼
┌──────────────────────────────────────────────────────────────┐
│         WHAT'S MOST IMPORTANT?                              │
├──────────────┬──────────────┬──────────────┬───────────────┤
│  Accuracy    │Interpretable │  Probability │   Speed       │
└──────────────┴──────────────┴──────────────┴───────────────┘
```

### Detailed Classification Paths

#### Path A: Binary Classification, Imbalanced

```
┌─────────────────────────────────────────────────────────────────┐
│  RECOMMENDED MODELS (in order of preference)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Balanced Random Forest                                      │
│     └── Best overall for imbalanced data                       │
│                                                                 │
│  2. XGBoost with scale_pos_weight                              │
│     └── Good performance with class weights                    │
│                                                                 │
│  3. LightGBM with is_unbalance=True                             │
│     └── Fast, good for large datasets                          │
│                                                                 │
│  4. Logistic Regression with class_weight='balanced'            │
│     └── Interpretable, good baseline                           │
│                                                                 │
│  5. SMOTE + Any Classifier                                      │
│     └── Oversample minority class                              │
│                                                                 │
│  ──── EVALUATION METRICS ────                                   │
│  • ROC-AUC (primary)                                           │
│  • PR-AUC (especially for highly imbalanced)                   │
│  • F1 Score                                                    │
│  • Precision/Recall (business-dependent)                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Path B: Binary Classification, Balanced

```
┌─────────────────────────────────────────────────────────────────┐
│  RECOMMENDED MODELS (in order of preference)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  IF YOU NEED INTERPRETABILITY:                                 │
│  1. Logistic Regression                                        │
│     └── Most interpretable, good baseline                      │
│                                                                 │
│  2. Decision Tree (max_depth=3-5)                              │
│     └── Visual and explainable                                 │
│                                                                 │
│  IF YOU NEED BEST PERFORMANCE:                                 │
│  1. XGBoost / LightGBM / CatBoost                              │
│     └── State-of-the-art performance                           │
│                                                                 │
│  2. Random Forest                                              │
│     └── Good default choice                                    │
│                                                                 │
│  3. SVM with RBF kernel                                        │
│     └── Excellent for complex boundaries                       │
│                                                                 │
│  IF YOU NEED FAST TRAINING:                                    │
│  1. Logistic Regression                                        │
│  2. Decision Tree                                              │
│  3. Naive Bayes                                                │
│                                                                 │
│  ──── EVALUATION METRICS ────                                   │
│  • Accuracy                                                    │
│  • ROC-AUC                                                     │
│  • F1 Score                                                    │
│  • Log Loss                                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Path C: Multi-Class Classification

```
┌─────────────────────────────────────────────────────────────────┐
│  RECOMMENDED MODELS (in order of preference)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  FEW CLASSES (2-10):                                           │
│  1. XGBoost / LightGBM / CatBoost                              │
│     └── Great performance                                      │
│                                                                 │
│  2. Random Forest                                              │
│     └── Good default choice                                    │
│                                                                 │
│  3. Logistic Regression (One-vs-Rest)                          │
│     └── Interpretable                                          │
│                                                                 │
│  4. Linear SVM (One-vs-Rest)                                   │
│     └── Good for linear boundaries                             │
│                                                                 │
│  MANY CLASSES (10+):                                           │
│  1. Linear SVM (One-vs-Rest)                                   │
│     └── Scales well to many classes                            │
│                                                                 │
│  2. Logistic Regression (One-vs-Rest)                          │
│     └── Fast training                                          │
│                                                                 │
│  3. XGBoost (multi:softmax)                                    │
│     └── Handles many classes well                              │
│                                                                 │
│  ──── EVALUATION METRICS ────                                   │
│  • Macro F1 Score                                              │
│  • Weighted F1 Score                                           │
│  • Accuracy                                                    │
│  • Confusion Matrix                                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 3: Regression Decision Tree

```
START: Regression
  │
  ▼
┌─────────────────────────────────────────────────────────────────┐
│                  IS IT LINEAR OR NON-LINEAR?                    │
└─────────────────────────────────────────────────────────────────┘
  │                    │
  LINEAR               NON-LINEAR
  │                    │
  ▼                    ▼
┌──────────────────┐  ┌──────────────────────────────────────────┐
│  ARE THERE       │  │  IS INTERPRETABILITY IMPORTANT?          │
│  OUTLIERS?       │  └──────────────────────────────────────────┘
└──────────────────┘   │                    │
  │        │           Yes                  No
  Yes      No           │                    │
  │        │           ▼                    ▼
  ▼        ▼       ┌──────────┐        ┌──────────┐
┌──────┐  ┌──────┐  │ Decision │        │ XGBoost  │
│Huber │  │Linear │  │ Tree     │        │ LightGBM │
│Ridge │  │Ridge  │  │          │        │ CatBoost │
└──────┘  └──────┘  └──────────┘        └──────────┘
  │        │           │                    │
  ▼        ▼           ▼                    ▼
┌─────────────────────────────────────────────────────────────────┐
│         WHAT'S MOST IMPORTANT?                                  │
├──────────────┬──────────────┬──────────────┬───────────────────┤
│  Accuracy    │Interpretable │  Robustness  │     Speed         │
└──────────────┴──────────────┴──────────────┴───────────────────┘
```

### Detailed Regression Paths

#### Path D: Linear Regression

```
┌─────────────────────────────────────────────────────────────────┐
│  RECOMMENDED MODELS (in order of preference)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  STANDARD LINEAR:                                              │
│  1. Linear Regression                                           │
│     └── Simplest, interpretable                                │
│                                                                 │
│  2. Ridge Regression (L2)                                      │
│     └── Prevents overfitting                                   │
│                                                                 │
│  3. Lasso Regression (L1)                                      │
│     └── Feature selection + regularization                     │
│                                                                 │
│  4. Elastic Net                                                │
│     └── Combines L1 and L2                                     │
│                                                                 │
│  WITH OUTLIERS:                                                │
│  1. Huber Regression                                           │
│     └── Robust to outliers                                     │
│                                                                 │
│  2. Quantile Regression                                        │
│     └── Models quantiles, not mean                             │
│                                                                 │
│  ──── EVALUATION METRICS ────                                   │
│  • R² Score (primary)                                          │
│  • RMSE                                                        │
│  • MAE                                                         │
│  • MAPE (for business metrics)                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Path E: Non-Linear Regression

```
┌─────────────────────────────────────────────────────────────────┐
│  RECOMMENDED MODELS (in order of preference)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  NEED INTERPRETABILITY:                                        │
│  1. Decision Tree Regressor                                    │
│     └── Visual and explainable                                 │
│                                                                 │
│  2. Random Forest Regressor                                    │
│     └── Feature importance available                           │
│                                                                 │
│  NEED BEST PERFORMANCE:                                        │
│  1. XGBoost Regressor                                          │
│     └── State-of-the-art                                       │
│                                                                 │
│  2. LightGBM Regressor                                         │
│     └── Fast, memory efficient                                 │
│                                                                 │
│  3. CatBoost Regressor                                         │
│     └── Handles categoricals well                              │
│                                                                 │
│  4. Gradient Boosting Regressor                                │
│     └── Good default                                           │
│                                                                 │
│  NEED FAST TRAINING:                                           │
│  1. Decision Tree Regressor                                    │
│  2. Random Forest (with few trees)                             │
│                                                                 │
│  ──── EVALUATION METRICS ────                                   │
│  • R² Score (primary)                                          │
│  • RMSE                                                        │
│  • MAE                                                         │
│  • MAPE                                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 4: Unsupervised Learning Decision Tree

```
START: Unsupervised
  │
  ▼
┌─────────────────────────────────────────────────────────────────┐
│              WHAT ARE YOU TRYING TO DISCOVER?                   │
└─────────────────────────────────────────────────────────────────┘
  │                    │                    │
  Clusters            Anomalies            Reduce Dimensions
  │                    │                    │
  ▼                    ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  KNOWN NUMBER    │  │  ISOLATION      │  │  LINEAR?         │
│  OF CLUSTERS?    │  │  FOREST         │  └──────────────────┘
└──────────────────┘  │  LOF            │   │        │
  │        │          │  One-Class SVM  │   Yes      No
  Yes      No         └──────────────────┘   │        │
  │        │                                 ▼        ▼
  ▼        ▼                              ┌──────┐  ┌──────┐
┌──────┐  ┌──────────┐                    │ PCA  │  │t-SNE │
│K-Means│  │DBSCAN    │                    │ LDA  │  │UMAP  │
│GMM    │  │Hierarch. │                    └──────┘  └──────┘
└──────┘  └──────────┘
```

### Detailed Unsupervised Paths

#### Path F: Clustering

```
┌─────────────────────────────────────────────────────────────────┐
│  RECOMMENDED MODELS (in order of preference)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  KNOWN NUMBER OF CLUSTERS:                                     │
│  1. K-Means                                                    │
│     └── Fast, works well for spherical clusters                │
│                                                                 │
│  2. Gaussian Mixture Models (GMM)                              │
│     └── Soft assignments, ellipsoidal clusters                 │
│                                                                 │
│  3. Spectral Clustering                                        │
│     └── Good for non-convex clusters                           │
│                                                                 │
│  UNKNOWN NUMBER OF CLUSTERS:                                   │
│  1. DBSCAN                                                     │
│     └── Finds arbitrary shapes, handles noise                  │
│                                                                 │
│  2. Hierarchical Clustering                                    │
│     └── Provides dendrogram, choose K visually                │
│                                                                 │
│  3. HDBSCAN                                                    │
│     └── Variable density clusters                              │
│                                                                 │
│  ──── EVALUATION METRICS ────                                   │
│  • Silhouette Score                                            │
│  • Davies-Bouldin Index                                        │
│  • Calinski-Harabasz Index                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Model Selection by Data Size

### Small Datasets (n < 1,000)

| Problem | Recommended Models | Why |
|---------|-------------------|-----|
| Classification | Logistic Regression, Naive Bayes | Simple, low variance, interpretable |
| Regression | Linear Regression, Ridge | Stable, interpretable |
| Clustering | K-Means, Hierarchical | Simple, effective |

### Medium Datasets (1,000 < n < 100,000)

| Problem | Recommended Models | Why |
|---------|-------------------|-----|
| Classification | Random Forest, XGBoost | Strong performance, handles interactions |
| Regression | XGBoost, Random Forest | Good default choices |
| Clustering | DBSCAN, K-Means | Flexible, works well |

### Large Datasets (n > 100,000)

| Problem | Recommended Models | Why |
|---------|-------------------|-----|
| Classification | LightGBM, Logistic Regression | Fast training, scalable |
| Regression | LightGBM, Linear Regression | Fast, memory efficient |
| Clustering | Mini-Batch K-Means, HDBSCAN | Scalable implementations |

---

## Model Selection by Feature Type

### All Numeric Features

| Problem | Recommended Models | Why |
|---------|-------------------|-----|
| Classification | SVM, XGBoost | Works well with numeric data |
| Regression | Linear Regression, XGBoost | Handles numeric relationships |

### Categorical Features

| Problem | Recommended Models | Why |
|---------|-------------------|-----|
| Classification | CatBoost, One-Hot + XGBoost | Native categorical support |
| Regression | CatBoost, One-Hot + LightGBM | Handles categoricals well |

### Mixed Types

| Problem | Recommended Models | Why |
|---------|-------------------|-----|
| Classification | Random Forest, XGBoost | Handles mixed types well |
| Regression | Random Forest, XGBoost | Flexible with data types |

### High Dimensional (p > 1,000)

| Problem | Recommended Models | Why |
|---------|-------------------|-----|
| Classification | Linear SVM, Logistic Regression | Scale well |
| Regression | Lasso, Ridge | Feature selection + regularization |
| Clustering | PCA + K-Means | Reduce dimensions first |

---

## Model Selection by Performance Requirements

### Interpretability Priority

| Priority | Model | Interpretability Level |
|----------|-------|----------------------|
| Highest | Linear/Logistic Regression | ⭐⭐⭐⭐⭐ |
| High | Decision Tree (shallow) | ⭐⭐⭐⭐ |
| Medium | Random Forest | ⭐⭐⭐ |
| Low | XGBoost, Neural Networks | ⭐⭐ |

### Accuracy Priority

| Priority | Model | Accuracy Level |
|----------|-------|---------------|
| Highest | XGBoost, LightGBM, CatBoost | ⭐⭐⭐⭐⭐ |
| High | Random Forest, SVM | ⭐⭐⭐⭐ |
| Medium | Logistic Regression, Decision Tree | ⭐⭐⭐ |
| Low | Naive Bayes | ⭐⭐ |

### Speed Priority

| Priority | Training Speed | Prediction Speed |
|----------|---------------|------------------|
| Fastest | Naive Bayes | ⭐⭐⭐⭐⭐ |
| Fast | Linear Regression, Logistic Regression | ⭐⭐⭐⭐⭐ |
| Medium | Random Forest, XGBoost | ⭐⭐⭐⭐ |
| Slow | SVM (with kernel), Neural Networks | ⭐⭐⭐ |

---

## Quick Reference Card

### Classification Quick Reference

| Scenario | Recommended Model | Key Parameter |
|----------|------------------|---------------|
| Binary, balanced | XGBoost | n_estimators=100 |
| Binary, imbalanced | Balanced RF | class_weight='balanced' |
| Multi-class, few | XGBoost | objective='multi:softmax' |
| Multi-class, many | Linear SVM | multi_class='ovr' |
| Need probabilities | Logistic Regression | - |
| Need interpretability | Decision Tree | max_depth=3-5 |
| Small dataset | Logistic Regression | - |
| Large dataset | LightGBM | - |

### Regression Quick Reference

| Scenario | Recommended Model | Key Parameter |
|----------|------------------|---------------|
| Linear, no outliers | Linear Regression | - |
| Linear, outliers | Huber Regression | epsilon=1.35 |
| Non-linear, interpretable | Random Forest | max_depth=10 |
| Non-linear, best performance | XGBoost | objective='reg:squarederror' |
| Many features | Lasso | alpha=0.01 |
| Feature selection needed | Lasso | alpha=0.01 |
| Large dataset | LightGBM | objective='regression' |

### Clustering Quick Reference

| Scenario | Recommended Model | Key Parameter |
|----------|------------------|---------------|
| Known K, spherical | K-Means | n_clusters=K |
| Known K, ellipsoidal | GMM | n_components=K |
| Unknown K, arbitrary shape | DBSCAN | eps=0.5, min_samples=5 |
| Unknown K, hierarchical | Hierarchical | method='ward' |
| Large dataset | Mini-Batch K-Means | batch_size=100 |

### Dimensionality Reduction Quick Reference

| Scenario | Recommended Model | Key Parameter |
|----------|------------------|---------------|
| Linear reduction | PCA | n_components=0.95 |
| Visualization | t-SNE | perplexity=30 |
| Large data, visualization | UMAP | n_neighbors=15 |
| Class separation | LDA | n_components=n_classes-1 |

---

## Decision Tree Implementation

```python
def select_model(problem_type, data_info):
    """
    Automatically select a model based on problem characteristics.
    
    Args:
        problem_type: 'classification', 'regression', 'clustering'
        data_info: dict with data characteristics
    
    Returns:
        dict: Recommended model and parameters
    """
    recommendations = {
        'classification': {
            'balanced_binary': {
                'models': ['XGBoost', 'RandomForest', 'LogisticRegression'],
                'primary': 'XGBoost',
                'params': {'n_estimators': 100}
            },
            'imbalanced_binary': {
                'models': ['BalancedRandomForest', 'XGBoost', 'SMOTE+RFC'],
                'primary': 'BalancedRandomForest',
                'params': {'class_weight': 'balanced'}
            },
            'multi_class_few': {
                'models': ['XGBoost', 'RandomForest', 'LogisticRegression'],
                'primary': 'XGBoost',
                'params': {'objective': 'multi:softmax'}
            },
            'multi_class_many': {
                'models': ['LinearSVM', 'LogisticRegression'],
                'primary': 'LinearSVM',
                'params': {'multi_class': 'ovr'}
            }
        },
        'regression': {
            'linear_no_outliers': {
                'models': ['LinearRegression', 'Ridge'],
                'primary': 'LinearRegression',
                'params': {}
            },
            'linear_with_outliers': {
                'models': ['HuberRegressor', 'Ridge'],
                'primary': 'HuberRegressor',
                'params': {'epsilon': 1.35}
            },
            'non_linear': {
                'models': ['XGBoost', 'RandomForest', 'LightGBM'],
                'primary': 'XGBoost',
                'params': {'objective': 'reg:squarederror'}
            }
        },
        'clustering': {
            'known_k': {
                'models': ['KMeans', 'GMM'],
                'primary': 'KMeans',
                'params': {'n_clusters': data_info.get('n_clusters', 5)}
            },
            'unknown_k': {
                'models': ['DBSCAN', 'Hierarchical'],
                'primary': 'DBSCAN',
                'params': {'eps': 0.5, 'min_samples': 5}
            }
        }
    }
    
    # Determine subcategory based on data info
    if problem_type == 'classification':
        n_classes = data_info.get('n_classes', 2)
        class_balance = data_info.get('class_balance', {})
        
        if n_classes == 2:
            if max(class_balance.values()) / min(class_balance.values()) > 3:
                subcategory = 'imbalanced_binary'
            else:
                subcategory = 'balanced_binary'
        else:
            if n_classes <= 10:
                subcategory = 'multi_class_few'
            else:
                subcategory = 'multi_class_many'
    
    elif problem_type == 'regression':
        linear = data_info.get('linear', True)
        outliers = data_info.get('outliers', False)
        
        if linear:
            if outliers:
                subcategory = 'linear_with_outliers'
            else:
                subcategory = 'linear_no_outliers'
        else:
            subcategory = 'non_linear'
    
    elif problem_type == 'clustering':
        known_k = data_info.get('known_k', False)
        
        if known_k:
            subcategory = 'known_k'
        else:
            subcategory = 'unknown_k'
    
    return recommendations[problem_type][subcategory]
```

---

This appendix provides a systematic framework for selecting the right model for your problem. Use the decision trees, quick reference cards, and implementation code to guide your model selection process.
