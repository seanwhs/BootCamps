# Mastering Machine Learning & Predictive Modeling
## Student Notes

### Complete Reference Notes for the End-to-End Pipeline Series

---

# PART 0: INTRODUCTION

## Key Concepts

### What is Machine Learning?
- **Definition**: Systems that learn and improve from experience without being explicitly programmed
- **Formal**: A program learns from experience E with respect to task T and performance measure P

### The Three Types of Learning

| Type | Description | Examples |
|------|-------------|----------|
| Supervised | Labeled data, predict labels | Classification, Regression |
| Unsupervised | Unlabeled data, find patterns | Clustering, Dimensionality Reduction |
| Reinforcement | Agent learns through actions | Gaming, Robotics |

### The ML Workflow
1. Problem Definition
2. Data Collection
3. Data Preparation
4. EDA
5. Feature Engineering
6. Model Selection
7. Training
8. Evaluation
9. Hyperparameter Tuning
10. Deployment
11. Monitoring

### Key Terms
- **Instance**: A single data point
- **Feature**: An attribute/property
- **Label/Target**: The value to predict
- **Training Set**: Data used to train
- **Test Set**: Data used to evaluate
- **Validation Set**: Data used to tune

---

# PART 1: PROJECT SETUP

## Directory Structure

```
ml-pipeline-project/
├── data/
│   ├── raw/          # Unmodified source data
│   ├── processed/    # Cleaned, engineered data
│   └── external/     # External reference data
├── src/
│   ├── data/         # Data ingestion and validation
│   ├── features/     # Feature engineering
│   ├── models/       # Model definitions
│   ├── validation/   # Validation and evaluation
│   └── pipeline/     # Pipeline orchestration
├── tests/            # Test suite
├── notebooks/        # Jupyter notebooks
├── configs/          # YAML/JSON configuration
├── models/           # Saved model artifacts
├── logs/             # Application logs
└── reports/          # Performance reports
```

### Key Files

| File | Purpose |
|------|---------|
| `pyproject.toml` | Project configuration |
| `requirements.txt` | Pinned dependencies |
| `.env.example` | Environment variables template |
| `Makefile` | Automation commands |
| `README.md` | Project documentation |

### Virtual Environment Commands

```bash
# Create
python -m venv venv

# Activate (Linux/Mac)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install in development mode
pip install -e .
```

### DataIngestor Methods

| Method | Description |
|--------|-------------|
| `load_csv()` | Load CSV with error handling |
| `load_json()` | Load JSON/NDJSON files |
| `load_parquet()` | Load Parquet files |
| `load_sql()` | Load from SQL database |
| `save_data()` | Save in various formats |
| `get_dataset_info()` | Get dataset statistics |
| `preview_data()` | Generate data preview |

---

# PART 2: DATA VALIDATION

## Data Quality Dimensions

| Dimension | Definition |
|-----------|------------|
| Completeness | No missing values |
| Accuracy | Correct values |
| Consistency | Same format |
| Timeliness | Up-to-date |
| Validity | Within range |
| Uniqueness | No duplicates |

### Missing Data Mechanisms

| Type | Description | Handling |
|------|-------------|----------|
| MCAR | Missing Completely At Random | Least problematic |
| MAR | Missing At Random | Depends on observed variables |
| MNAR | Missing Not At Random | Most problematic |

### Outlier Detection Methods

| Method | Formula | When to Use |
|--------|---------|-------------|
| IQR | Q1 - 1.5*IQR, Q3 + 1.5*IQR | Robust to outliers |
| Z-Score | |z| > 3 | Assumes normal distribution |
| Modified Z-Score | 0.6745 * (x - median) / MAD | Robust, any distribution |

### Schema Validation

```python
class ColumnType(str, Enum):
    INTEGER = "int"
    FLOAT = "float"
    STRING = "object"
    CATEGORICAL = "category"
    DATETIME = "datetime"
    BOOLEAN = "bool"
    TEXT = "text"
```

### Quality Scoring

| Component | Weight | Calculation |
|-----------|--------|-------------|
| Completeness | 30% | 100 - missing% |
| Consistency | 25% | Based on schema violations |
| Uniqueness | 20% | 100 - duplicate% * 2 |
| Integrity | 25% | 100 - outlier% * 0.5 |

### Quality Grade Scale

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent |
| 80-89 | B | Good |
| 70-79 | C | Fair |
| 60-69 | D | Poor |
| <60 | F | Critical |

---

# PART 3: EXPLORATORY DATA ANALYSIS

## Column Types

| Type | Detection | Examples |
|------|-----------|----------|
| Numeric | `pd.api.types.is_numeric_dtype()` | Age, Income |
| Categorical | `df[col].nunique() <= threshold` | Gender, City |
| High Cardinality | `df[col].nunique() > threshold` | IDs, Text |
| Datetime | `pd.api.types.is_datetime64_any_dtype()` | Dates |
| Text | `df[col].astype(str).str.len().mean() > 50` | Reviews |

### Univariate Statistics

**Numeric:**
- Mean, Median, Mode
- Min, Max
- Standard Deviation, Variance
- Skewness, Kurtosis
- Q1, Q3, IQR

**Categorical:**
- Unique values count
- Frequency distribution
- Most frequent value
- Class balance ratio

### Correlation Metrics

| Metric | Range | Interpretation |
|--------|-------|----------------|
| Pearson | [-1, 1] | Linear relationship |
| Spearman | [-1, 1] | Monotonic relationship |
| Cramér's V | [0, 1] | Categorical association |

### Skewness Interpretation

| Value | Interpretation |
|-------|----------------|
| 0 | Symmetric |
| > 0 | Right-skewed |
| < 0 | Left-skewed |
| > 1 | Highly skewed |

### Target Analysis Checklist

- [ ] Distribution (histogram, box plot)
- [ ] Class balance (classification)
- [ ] Skewness (regression)
- [ ] Feature-target correlations
- [ ] Feature-target visualizations

---

# PART 4: IMPUTATION & SCALING

## Imputation Strategies

| Strategy | Best For | When to Use |
|----------|----------|-------------|
| Mean | Symmetric data | No outliers |
| Median | Skewed data | Outliers present |
| Mode | Categorical | Most common value |
| Constant | Specific cases | Known default |
| KNN | Local patterns | Moderate missingness |
| MICE | Complex patterns | Multiple correlated features |
| Random Forest | Non-linear | Complex relationships |
| Interpolate | Time series | Sequential data |

### Scaling Strategies

| Strategy | Formula | Best For |
|----------|---------|----------|
| Standard | (x - μ) / σ | Normal distributions |
| Robust | (x - median) / IQR | Outliers present |
| MinMax | (x - min) / (max - min) | Bounded data [0,1] |
| MaxAbs | x / max(abs) | Sparse data |
| Power | Box-Cox/Yeo-Johnson | Skewed data |
| Quantile | Rank-based | Arbitrary distributions |

### Preprocessing Pipeline Steps

1. Handle missing values
2. Scale numeric features
3. Encode categorical features
4. Create new features
5. Select features
6. Transform for model

### Smart Scaling Rules

| Condition | Strategy |
|-----------|----------|
| Outlier % > 5% | Robust |
| Skewness > 1 | Power |
| Bounded [0,1] | None |
| Normal distribution | Standard |

---

# PART 5: CATEGORICAL ENCODING

## Encoding Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| One-Hot | Binary columns for each category | Low cardinality (<10) |
| Target | Replace with target mean | High cardinality + target |
| Frequency | Replace with frequency | High cardinality |
| Hashing | Fixed-length hash vector | Very high cardinality (>1000) |
| Ordinal | Integer mapping | Ordered categories |

### Target Encoding Formula

```
encoded = prior * (1 - weight) + category_mean * weight
weight = 1 / (1 + exp(-(count - min_samples_leaf) / smoothing))
```

### Auto-Strategy Selection

| Cardinality | Target Available | Strategy |
|-------------|------------------|----------|
| <= 10 | Any | One-Hot |
| 10-100 | Yes | Target |
| 10-100 | No | Frequency |
| > 100 | Any | Hashing |

### Encoding Best Practices

1. Always encode after train/test split
2. Use cross-validation for target encoding
3. Handle unseen categories
4. Store encoders for inference
5. Consider business requirements

---

# PART 6: FEATURE CREATION & SELECTION

## Feature Creation Types

| Type | Examples | Purpose |
|------|----------|---------|
| Polynomial | x², x³ | Capture non-linearity |
| Interaction | x1*x2 | Capture combined effects |
| Ratio | x1/x2 | Capture relative importance |
| Difference | x1-x2 | Capture change |
| Aggregation | mean, max, min | Group statistics |
| Domain-specific | Domain knowledge | Business insights |

### Feature Selection Methods

| Method | Type | Description |
|--------|------|-------------|
| Variance | Filter | Remove constant features |
| Correlation | Filter | Keep features correlated with target |
| Mutual Info | Filter | Capture non-linear relationships |
| RFE | Wrapper | Recursive elimination |
| Lasso | Embedded | L1 regularization |
| Random Forest | Embedded | Tree-based importance |

### Feature Importance Types

| Method | Source | Interpretation |
|--------|--------|----------------|
| Gini | Random Forest | Impurity reduction |
| Gain | XGBoost | Performance improvement |
| Coefficient | Linear | Linear effect |
| Permutation | Model-agnostic | Drop in performance |

---

# PART 7: DIMENSIONALITY REDUCTION & IMBALANCE

## Dimensionality Reduction

| Method | Type | Best For |
|--------|------|----------|
| PCA | Linear | Variance preservation |
| LDA | Linear | Class separation |
| t-SNE | Non-linear | Visualization (2D/3D) |
| UMAP | Non-linear | Visualization, clustering |

### The Curse of Dimensionality
- More dimensions = more data needed
- Sparse data in high dimensions
- Distances become meaningless
- Overfitting easier
- Computation expensive

### Imbalance Handling

| Method | Type | Best For |
|--------|------|----------|
| SMOTE | Over-sampling | Moderate imbalance |
| ADASYN | Over-sampling | Hard examples |
| Random Over | Over-sampling | Simple, fast |
| Random Under | Under-sampling | Large dataset |
| SMOTE-ENN | Hybrid | Clean noisy data |
| SMOTE-Tomek | Hybrid | Remove borderline |
| Class Weight | Cost-sensitive | Can't resample |
| Balanced Ensemble | Ensemble | Robust performance |

### Imbalanced Data Metrics

| Metric | Why |
|--------|-----|
| ROC-AUC | Overall performance |
| PR-AUC | Highly imbalanced |
| F1 Score | Balance precision/recall |
| Balanced Accuracy | Average per class |
| MCC | Robust metric |

---

# PART 8: TREE-BASED MODELS

## Decision Tree

**Splitting Criteria:**
- Gini Impurity: 1 - Σ pᵢ²
- Entropy: -Σ pᵢ * log₂(pᵢ)
- Information Gain: Entropy(parent) - Σ(weight * Entropy(child))

**Pros:** Interpretable, non-linear, no scaling
**Cons:** Prone to overfitting, unstable

## Random Forest

- Bootstrap samples
- Random feature subsets
- Aggregate predictions

**Pros:** Robust to overfitting, handles many features
**Cons:** Less interpretable, memory intensive

## XGBoost

**Key Features:**
- L1 (reg_alpha) and L2 (reg_lambda) regularization
- Early stopping
- Monotonic constraints
- Custom objectives
- GPU acceleration

**Learning Rate:** 0.01-0.3 (lower = better but slower)

## LightGBM

- Histogram-based (faster, memory efficient)
- Leaf-wise growth (better accuracy)
- Native categorical support
- GPU support

## CatBoost

- Native categorical support
- Ordered boosting (prevents overfitting)
- Symmetric trees (faster prediction)

### Parameter Ranges

| Model | Parameter | Range |
|-------|-----------|-------|
| Random Forest | n_estimators | 50-500 |
| Random Forest | max_depth | 3-15 |
| XGBoost | learning_rate | 0.01-0.3 |
| XGBoost | subsample | 0.6-1.0 |
| LightGBM | num_leaves | 10-50 |
| CatBoost | depth | 4-10 |

---

# PART 9: UNSUPERVISED LEARNING

## K-Means

- K centroids initialized
- Assign points to nearest centroid
- Update centroids
- Repeat until convergence

**Pros:** Fast, simple, scalable
**Cons:** Spherical clusters, requires K

**Elbow Method:** Find where inertia decrease flattens

## DBSCAN

- Core points: have >= min_samples neighbors within eps
- Border points: within eps of core point
- Noise points: not core or border

**Pros:** Arbitrary shapes, handles noise, no K required
**Cons:** Sensitive to parameters

## Hierarchical Clustering

- Start with each point as its own cluster
- Merge closest clusters
- Build dendrogram

**Methods:** Ward, Complete, Average, Single

## Clustering Validation

| Metric | Range | Higher/Lower |
|--------|-------|--------------|
| Silhouette | [-1, 1] | Higher better |
| Davies-Bouldin | [0, ∞) | Lower better |
| Calinski-Harabasz | [0, ∞) | Higher better |

---

# PART 10: DEEP LEARNING

## Neural Network Components

| Component | Purpose |
|-----------|---------|
| Neurons | Basic unit, applies weights and activation |
| Layers | Collections of neurons |
| Activation | Non-linear transformation |
| Loss | Measure of error |
| Optimizer | Update weights |

## Activation Functions

| Function | Formula | Range | Use Case |
|----------|---------|-------|----------|
| ReLU | max(0, x) | [0, ∞) | Hidden layers |
| Sigmoid | 1/(1+e⁻ˣ) | (0, 1) | Binary output |
| Tanh | (eˣ-e⁻ˣ)/(eˣ+e⁻ˣ) | (-1, 1) | Hidden layers |
| Softmax | eˣⁱ/Σeˣʲ | (0, 1), sums to 1 | Multi-class output |
| Leaky ReLU | max(0.01x, x) | (-∞, ∞) | Hidden layers |

## Loss Functions

| Type | Function | Use Case |
|------|----------|----------|
| MSE | Σ(y-ŷ)²/n | Regression |
| MAE | Σ|y-ŷ|/n | Robust regression |
| Cross-Entropy | -Σ y*log(ŷ) | Classification |
| Binary CE | -[y*log(ŷ) + (1-y)*log(1-ŷ)] | Binary classification |

## Optimizers

| Optimizer | Best For | Characteristics |
|-----------|----------|-----------------|
| SGD | Simple | Slow convergence |
| Adam | General | Fast, adaptive |
| RMSprop | RNNs | Adaptive |
| AdamW | General | Adam with weight decay |

## Training Best Practices

1. Shuffle data
2. Normalize inputs
3. Use mini-batches
4. Monitor overfitting
5. Use early stopping
6. Save checkpoints
7. Use GPU when available

---

# PART 11: CROSS-VALIDATION & EVALUATION

## Cross-Validation Types

| Method | Best For |
|--------|----------|
| K-Fold | General ML problems |
| Stratified K-Fold | Classification with imbalanced data |
| Group K-Fold | Data with natural groups |
| Time Series Split | Temporal data |
| Leave-One-Out | Very small datasets |

## Classification Metrics

| Metric | Formula | Best For |
|--------|---------|----------|
| Accuracy | (TP+TN)/(TP+TN+FP+FN) | Balanced classes |
| Precision | TP/(TP+FP) | Minimize false positives |
| Recall | TP/(TP+FN) | Minimize false negatives |
| F1 | 2*P*R/(P+R) | Balance P and R |
| ROC-AUC | Area under ROC curve | Overall performance |
| PR-AUC | Area under PR curve | Imbalanced data |

## Regression Metrics

| Metric | Formula | Best For |
|--------|---------|----------|
| MSE | Σ(y-ŷ)²/n | Large errors penalized |
| RMSE | √MSE | Interpretable |
| MAE | Σ|y-ŷ|/n | Robust to outliers |
| MAPE | Σ|(y-ŷ)/y|/n | Relative errors |
| R² | 1 - SS_res/SS_tot | Variance explained |

## Confusion Matrix Components

```
              Predicted
              Positive  Negative
Actual Positive   TP      FN
     Negative     FP      TN
```

---

# PART 12: HYPERPARAMETER OPTIMIZATION

## Search Methods

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| Grid Search | Small spaces | Exhaustive | Slow |
| Random Search | Medium spaces | Efficient | Less systematic |
| Bayesian | Large spaces | Most efficient | Complex |

## Parameter Types

- **Integer**: n_estimators, max_depth
- **Float**: learning_rate, subsample
- **Categorical**: max_features, loss

## Optuna Features

- TPE sampler (intelligent search)
- Median pruner (early stopping)
- Visualization (history, importance)
- Parallel execution
- Study persistence

## Parameter Space Examples

### Random Forest
```python
{
    'n_estimators': (50, 200),
    'max_depth': (3, 10),
    'min_samples_split': (2, 10)
}
```

### XGBoost
```python
{
    'n_estimators': (50, 200),
    'max_depth': (3, 10),
    'learning_rate': (0.01, 0.3),
    'subsample': (0.6, 1.0)
}
```

---

# PART 13: PIPELINE CONSTRUCTION

## Pipeline Components

1. **Data Layer**: Ingestion, validation
2. **Feature Layer**: Preprocessing, encoding, creation, selection
3. **Model Layer**: Model training
4. **Validation Layer**: CV, metrics, tuning
5. **Deployment Layer**: Persistence, API, monitoring

## Leak-Free Pipeline Rules

1. Split data before preprocessing
2. Fit transformers on training only
3. Transform test with training parameters
4. Use cross-validation for feature selection
5. Apply same transformations in production

## Pipeline Methods

| Method | Description |
|--------|-------------|
| `train()` | Train the complete pipeline |
| `predict()` | Make predictions |
| `save()` | Save pipeline to disk |
| `load()` | Load saved pipeline |
| `get_summary()` | Get pipeline summary |

## Configuration-Driven Design

```yaml
model_type: random_forest
task: classification
target_col: target
imputation:
  numeric: median
  categorical: mode
scaling:
  method: standard
encoding:
  strategy: auto
tuning:
  method: bayesian
  n_trials: 50
  cv: 5
```

---

# PART 14: CAPSTONE PROJECT

## Problem Formulation

- **Business Problem**: Customer churn prediction
- **Objective**: Identify at-risk customers for retention
- **Success Metric**: ROC-AUC, Business savings

## Feature Importance (Key Insights)

1. **Tenure**: Strongest predictor
2. **Contract Type**: Month-to-month highest churn
3. **Service Usage**: More services = lower churn
4. **Premium Services**: Reduce churn

## Business Impact Calculation

```
Savings = TP * (Cost per churn prevented)
Potential Savings = Predicted churners * 500 (estimated)
```

## Model Performance (Example)

| Metric | Value |
|--------|-------|
| ROC-AUC | 0.85 |
| Precision | 0.68 |
| Recall | 0.60 |
| F1 | 0.64 |
| Accuracy | 0.82 |

---

# PART 15: DEPLOYMENT & MONITORING

## FastAPI Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API information |
| `/api/health` | GET | Health check |
| `/api/model/info` | GET | Model information |
| `/api/predict` | POST | Single prediction |
| `/api/predict/batch` | POST | Batch predictions |

## Docker Commands

```bash
# Build
docker build -t ml-pipeline:latest .

# Run
docker run -p 8000:8000 ml-pipeline:latest

# Compose
docker-compose up -d
docker-compose down
```

## Monitoring Components

| Component | What to Monitor |
|-----------|-----------------|
| System | CPU, Memory, Disk, Network |
| Application | Requests, Errors, Response Time |
| Model | Predictions, Distribution, Performance |
| Data | Quality, Schema, Distribution |

## Drift Detection

| Type | Detection Method |
|------|------------------|
| Data Drift | KS test, Chi-square test |
| Concept Drift | Performance monitoring |
| Quality Drift | Schema validation, missing values |

## Alerting Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Error Rate | > 1% | > 5% |
| Latency (p95) | > 100ms | > 500ms |
| Performance Drop | > 5% | > 10% |
| Data Drift | p < 0.05 | p < 0.01 |

---

# QUICK REFERENCE CARDS

## Python for ML Quick Reference

```python
# Essential imports
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier

# Data operations
df = pd.read_csv('data.csv')
df.head()
df.info()
df.describe()
df.isnull().sum()

# Train-test split
X = df.drop('target', axis=1)
y = df['target']
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Scaling
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Model training
model = RandomForestClassifier()
model.fit(X_train_scaled, y_train)

# Prediction
y_pred = model.predict(X_test_scaled)
accuracy = (y_pred == y_test).mean()
```

## Scikit-learn Pipeline Quick Reference

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.ensemble import RandomForestClassifier

numeric_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

categorical_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
    ('encoder', OneHotEncoder(handle_unknown='ignore'))
])

preprocessor = ColumnTransformer([
    ('numeric', numeric_transformer, numeric_features),
    ('categorical', categorical_transformer, categorical_features)
])

pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier())
])

pipeline.fit(X_train, y_train)
```

## Model Selection Quick Reference

| Problem Type | Recommended Models |
|--------------|-------------------|
| Binary Classification | Logistic Regression, XGBoost, Random Forest |
| Multi-class | XGBoost, Random Forest, SVM |
| Regression | Linear Regression, XGBoost, Random Forest |
| Clustering | K-Means, DBSCAN, Hierarchical |
| Dimensionality | PCA, t-SNE, UMAP |

## Evaluation Metrics Quick Reference

| Scenario | Primary Metric | Secondary |
|----------|----------------|-----------|
| Balanced Classification | Accuracy | F1 |
| Imbalanced Classification | PR-AUC | F1 |
| Spam Detection | Precision | Accuracy |
| Disease Detection | Recall | F1 |
| Ranking | ROC-AUC | PR-AUC |
| Regression | MAE | R² |
| Business Impact | Custom Cost | Profit |

---

*End of Student Notes*
