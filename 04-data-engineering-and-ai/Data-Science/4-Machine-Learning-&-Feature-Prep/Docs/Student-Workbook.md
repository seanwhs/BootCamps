# Mastering Machine Learning & Predictive Modeling
## Student Workbook

### Complete Exercise Book for the End-to-End Pipeline Series

---

## Table of Contents

1. **Part 0: Introduction** - Self-Assessment & Goals
2. **Part 1: Project Setup** - Environment & Structure Exercises
3. **Part 2: Data Validation** - Schema & Quality Exercises
4. **Part 3: EDA** - Analysis & Visualization Exercises
5. **Part 4: Imputation & Scaling** - Preprocessing Exercises
6. **Part 5: Categorical Encoding** - Encoding Exercises
7. **Part 6: Feature Creation & Selection** - Engineering Exercises
8. **Part 7: Dimensionality Reduction & Imbalance** - Advanced Exercises
9. **Part 8: Tree-Based Models** - Modeling Exercises
10. **Part 9: Unsupervised Learning** - Clustering Exercises
11. **Part 10: Deep Learning** - Neural Network Exercises
12. **Part 11: Cross-Validation & Evaluation** - Validation Exercises
13. **Part 12: Hyperparameter Optimization** - Tuning Exercises
14. **Part 13: Pipeline Construction** - Integration Exercises
15. **Part 14: Capstone Project** - End-to-End Exercises
16. **Part 15: Deployment & Monitoring** - Production Exercises

---

# PART 0: INTRODUCTION

## Self-Assessment

### Pre-Course Survey

Rate your comfort level with each topic (1 = Never used, 5 = Expert):

| Topic | Rating |
|-------|--------|
| Python programming | ___ |
| NumPy / Pandas | ___ |
| Scikit-learn | ___ |
| Machine Learning concepts | ___ |
| Feature engineering | ___ |
| Model evaluation | ___ |
| Git / Version Control | ___ |
| Command line / Terminal | ___ |
| Jupyter notebooks | ___ |

### Learning Goals

1. What do you hope to learn from this series?
   _________________________________________________________________

2. What specific skills do you want to develop?
   _________________________________________________________________

3. What type of projects do you want to build?
   _________________________________________________________________

4. How much time can you dedicate per week?
   _________________________________________________________________

5. Have you used any ML frameworks before? Which ones?
   _________________________________________________________________

---

### Knowledge Check

**True or False:**

1. ___ Machine learning models can be deployed directly from Jupyter notebooks.
2. ___ Data leakage occurs when information from outside the training dataset is used.
3. ___ All missing values should be dropped from the dataset.
4. ___ Feature scaling is always required for tree-based models.
5. ___ Cross-validation helps estimate model performance on unseen data.

**Short Answer:**

6. What is the difference between supervised and unsupervised learning?
   _________________________________________________________________

7. Why is data quality more important than model quality?
   _________________________________________________________________

8. What is the purpose of a pipeline in machine learning?
   _________________________________________________________________

---

# PART 1: PROJECT SETUP

## Exercise 1.1: Creating the Project Structure

**Objective:** Create the complete project directory structure.

**Instructions:**

Create the following directories:

```
ml-pipeline-project/
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── src/
│   ├── data/
│   ├── features/
│   ├── models/
│   ├── validation/
│   └── pipeline/
├── tests/
├── notebooks/
├── configs/
├── models/
├── logs/
└── reports/
```

**Commands to run (fill in):**
```bash
mkdir -p ml-pipeline-project
cd ml-pipeline-project
# Your code here
```

---

## Exercise 1.2: Virtual Environment Setup

**Objective:** Set up a Python virtual environment.

**Instructions:**

1. Create a virtual environment named `venv`:
   ```bash
   # Your code here
   ```

2. Activate the virtual environment:
   ```bash
   # Windows:
   # Your code here
   
   # Mac/Linux:
   # Your code here
   ```

3. Verify the environment is active:
   ```bash
   # Your code here
   ```

4. Create a `requirements.txt` file with the following core dependencies:
   ```text
   # Your code here
   ```

5. Install the dependencies:
   ```bash
   # Your code here
   ```

---

## Exercise 1.3: DataIngestor Class

**Objective:** Implement a DataIngestor class.

**Code Template:**

```python
import pandas as pd
import numpy as np
from pathlib import Path
from loguru import logger

class DataIngestor:
    def __init__(self, raw_data_path=None, processed_data_path=None):
        # Your code here
        pass
    
    def load_csv(self, file_path, **read_csv_kwargs):
        # Your code here
        pass
    
    def get_dataset_info(self, df):
        # Your code here
        pass
    
    def save_data(self, df, file_path, format="csv", **save_kwargs):
        # Your code here
        pass
```

**Test Your Code:**

```python
# Create test data
df = pd.DataFrame({
    'id': [1, 2, 3],
    'name': ['Alice', 'Bob', 'Charlie'],
    'age': [25, 30, 35]
})

# Save and load using your DataIngestor
ingestor = DataIngestor()
ingestor.save_data(df, "test.csv")
loaded = ingestor.load_csv("test.csv")
print(loaded)
```

---

## Exercise 1.4: Makefile Commands

**Objective:** Create a Makefile with useful commands.

**Instructions:**

Complete the following Makefile:

```makefile
.PHONY: help install test lint format clean

help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

install: ## Install dependencies
	# Your code here

test: ## Run tests
	# Your code here

lint: ## Lint code
	# Your code here

format: ## Format code
	# Your code here

clean: ## Clean up temporary files
	# Your code here

train: ## Train the model
	# Your code here

serve: ## Start the API server
	# Your code here
```

---

### Part 1 Checkpoint

- [ ] Project structure created
- [ ] Virtual environment set up
- [ ] DataIngestor class implemented
- [ ] DataIngestor tests pass
- [ ] Makefile commands work

---

# PART 2: DATA VALIDATION

## Exercise 2.1: Schema Definition

**Objective:** Define a schema for a dataset.

**Instructions:**

Create a schema for the Titanic dataset using Pydantic:

```python
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from enum import Enum

class ColumnType(str, Enum):
    INTEGER = "int"
    FLOAT = "float"
    STRING = "object"
    CATEGORICAL = "category"

class ColumnConstraint(BaseModel):
    # Your code here
    pass

class ColumnSchema(BaseModel):
    # Your code here
    pass

class DataSchema(BaseModel):
    # Your code here
    pass

# Create a Titanic schema
titanic_schema = DataSchema(
    name="titanic",
    version="1.0.0",
    columns=[
        # Your code here
    ]
)
```

**Titanic Dataset Columns:**
- passenger_id (int, unique)
- survived (int, allowed: 0, 1)
- pclass (int, allowed: 1, 2, 3)
- name (string, not null)
- sex (categorical, allowed: male, female)
- age (float, min: 0, max: 120)
- sibsp (int, min: 0)
- parch (int, min: 0)
- ticket (string)
- fare (float, min: 0)
- cabin (string, nullable)
- embarked (categorical, allowed: C, Q, S)

---

## Exercise 2.2: Missing Value Detection

**Objective:** Implement missing value detection.

**Code Template:**

```python
class MissingValueAnalyzer:
    def __init__(self, threshold=0.5):
        self.threshold = threshold
        self.results = {}
    
    def analyze(self, df):
        # Your code here
        # Calculate:
        # 1. Total missing values
        # 2. Missing by column
        # 3. Missing percentage by column
        # 4. Columns above threshold
        # 5. Rows with missing values
        return results
    
    def generate_report(self):
        # Your code here
        # Create a readable report of missing values
        pass
```

**Test:**

```python
# Create test data with missing values
df = pd.DataFrame({
    'A': [1, 2, np.nan, 4, 5],
    'B': [np.nan, 2, 3, 4, np.nan],
    'C': [1, 2, 3, 4, 5]
})

analyzer = MissingValueAnalyzer()
results = analyzer.analyze(df)
print(results)
```

---

## Exercise 2.3: Outlier Detection

**Objective:** Implement outlier detection using IQR and Z-score methods.

**Code Template:**

```python
class OutlierDetector:
    def __init__(self, method='iqr', threshold=3.0):
        self.method = method
        self.threshold = threshold
        self.outliers = {}
    
    def detect(self, df, columns=None):
        # Your code here
        # For IQR: use 1.5 * IQR
        # For Z-score: use threshold (default 3)
        pass
    
    def get_outlier_summary(self):
        # Your code here
        pass
    
    def remove_outliers(self, df):
        # Your code here
        pass
```

**Test:**

```python
# Create test data with outliers
df = pd.DataFrame({
    'normal': np.random.normal(100, 10, 100),
    'outliers': np.append(np.random.normal(100, 10, 95), [500, 600, 700, 800, 900])
})

detector = OutlierDetector(method='iqr')
outliers = detector.detect(df)
print(detector.get_outlier_summary())
```

---

## Exercise 2.4: Data Quality Report

**Objective:** Generate a comprehensive data quality report.

**Instructions:**

Create a function that generates a quality report for any dataset:

```python
def generate_quality_report(df, schema=None):
    # Your code here
    # Include:
    # 1. Dataset overview
    # 2. Missing value analysis
    # 3. Outlier analysis
    # 4. Duplicate analysis
    # 5. Schema validation
    # 6. Quality score
    # 7. Recommendations
    return report
```

**Expected Output:**

```
DATA QUALITY REPORT
===================
Dataset: example_data
Rows: 1,000
Columns: 5
Missing Values: 45 (0.9%)
Columns with Missing: 2

MISSING ANALYSIS
----------------
Column 'age': 25 missing (2.5%)
Column 'income': 20 missing (2.0%)

OUTLIER ANALYSIS
----------------
Column 'age': 5 outliers (0.5%)
Column 'income': 3 outliers (0.3%)

DUPLICATES
----------
Duplicate rows: 10 (1.0%)

QUALITY SCORE: 87.5%
GRADE: B

RECOMMENDATIONS
---------------
1. Impute missing values in 'age' and 'income'
2. Remove duplicate rows
3. Investigate outliers in 'age' and 'income'
```

---

### Part 2 Checkpoint

- [ ] Schema defined for Titanic dataset
- [ ] Missing value detection implemented
- [ ] Outlier detection implemented
- [ ] Data quality report generated

---

# PART 3: EXPLORATORY DATA ANALYSIS

## Exercise 3.1: Univariate Analysis

**Objective:** Perform univariate analysis on each feature.

**Instructions:**

For each column in a dataset, compute:
1. Data type
2. Missing values
3. Unique values
4. Summary statistics (for numeric)
5. Frequency distribution (for categorical)

**Code Template:**

```python
class UnivariateAnalyzer:
    def __init__(self, categorical_threshold=10):
        self.categorical_threshold = categorical_threshold
    
    def analyze(self, df):
        # Your code here
        pass
    
    def analyze_numeric(self, series):
        # Your code here
        # Return: count, mean, std, min, q1, median, q3, max, skew, kurtosis
        pass
    
    def analyze_categorical(self, series):
        # Your code here
        # Return: unique values, most frequent, frequency distribution
        pass
```

**Test Dataset:**

```python
df = pd.DataFrame({
    'age': np.random.normal(35, 10, 1000),
    'income': np.random.exponential(50000, 1000),
    'gender': np.random.choice(['M', 'F'], 1000),
    'city': np.random.choice(['NYC', 'LA', 'CHI', 'HOU'], 1000),
    'target': np.random.choice([0, 1], 1000)
})

analyzer = UnivariateAnalyzer()
results = analyzer.analyze(df)
print(results)
```

---

## Exercise 3.2: Correlation Analysis

**Objective:** Analyze correlations between features.

**Code Template:**

```python
class CorrelationAnalyzer:
    def __init__(self, threshold=0.7):
        self.threshold = threshold
        self.correlation_matrix = None
    
    def analyze(self, df, method='pearson'):
        # Your code here
        # Compute correlation matrix
        # Find high correlations
        # Find perfect correlations
        pass
    
    def get_high_correlations(self):
        # Your code here
        pass
    
    def plot_heatmap(self):
        # Your code here
        pass
```

**Test:**

```python
df = pd.DataFrame({
    'x1': np.random.normal(0, 1, 100),
    'x2': np.random.normal(0, 1, 100),
    'x3': np.random.normal(0, 1, 100),
    'x4': np.random.normal(0, 1, 100),
})

# Add some correlations
df['x5'] = df['x1'] * 2 + np.random.normal(0, 0.1, 100)
df['x6'] = df['x2'] * 3 + np.random.normal(0, 0.1, 100)

analyzer = CorrelationAnalyzer()
analyzer.analyze(df)
print(analyzer.get_high_correlations())
```

---

## Exercise 3.3: Target Analysis

**Objective:** Analyze the target variable and its relationship with features.

**Code Template:**

```python
class TargetAnalyzer:
    def __init__(self, target_col):
        self.target_col = target_col
    
    def analyze(self, df):
        # Your code here
        # For classification:
        # - Class distribution
        # - Balance ratio
        # - Feature-target relationships
        # For regression:
        # - Distribution
        # - Skewness
        # - Feature-target correlations
        pass
    
    def plot_target_distribution(self):
        # Your code here
        pass
    
    def plot_feature_target_relationships(self, features):
        # Your code here
        pass
```

**Test:**

```python
# Create dataset with target
df = pd.DataFrame({
    'age': np.random.normal(35, 10, 1000),
    'income': np.random.exponential(50000, 1000),
    'churn': np.random.choice([0, 1], 1000, p=[0.7, 0.3])
})

analyzer = TargetAnalyzer('churn')
results = analyzer.analyze(df)
print(results)
```

---

## Exercise 3.4: EDA Report

**Objective:** Generate a comprehensive EDA report.

**Instructions:**

Create a report that includes:
1. Dataset overview
2. Univariate analysis
3. Correlation analysis
4. Target analysis
5. Key insights
6. Recommendations

```python
class EDAReporter:
    def __init__(self, df, target_col=None):
        self.df = df
        self.target_col = target_col
    
    def generate_report(self):
        # Your code here
        # Combine all analyses into one report
        pass
    
    def generate_insights(self):
        # Your code here
        # Extract 5-10 key insights
        pass
    
    def generate_recommendations(self):
        # Your code here
        # Generate actionable recommendations
        pass
```

**Test:**

```python
reporter = EDAReporter(df, target_col='churn')
report = reporter.generate_report()
print(report)
```

---

### Part 3 Checkpoint

- [ ] Univariate analysis completed
- [ ] Correlation analysis completed
- [ ] Target analysis completed
- [ ] EDA report generated

---

# PART 4: IMPUTATION & SCALING

## Exercise 4.1: Imputation Strategies

**Objective:** Implement different imputation strategies.

**Code Template:**

```python
class Imputer:
    def __init__(self, strategy='median'):
        self.strategy = strategy
        self.fill_value = None
    
    def fit(self, X):
        # Your code here
        # Calculate statistics for each column
        pass
    
    def transform(self, X):
        # Your code here
        # Apply imputation
        pass
    
    def fit_transform(self, X):
        # Your code here
        pass
```

**Supported Strategies:**
- mean
- median
- mode
- constant
- knn (bonus)

**Test:**

```python
# Create data with missing values
df = pd.DataFrame({
    'age': [25, 30, np.nan, 40, 45],
    'income': [50000, 60000, 70000, np.nan, 90000],
    'gender': ['M', 'F', 'M', 'F', np.nan]
})

imputer = Imputer(strategy='median')
df_imputed = imputer.fit_transform(df)
print(df_imputed)
```

---

## Exercise 4.2: KNN Imputation

**Objective:** Implement KNN-based imputation.

**Code Template:**

```python
class KNNImputer:
    def __init__(self, n_neighbors=5):
        self.n_neighbors = n_neighbors
        self.data = None
    
    def fit(self, X):
        # Your code here
        pass
    
    def transform(self, X):
        # Your code here
        # Use nearest neighbors to impute missing values
        pass
```

**Test:**

```python
from sklearn.datasets import make_classification

X, y = make_classification(n_samples=100, n_features=5)
X = pd.DataFrame(X)
# Introduce missing values
X.iloc[0:10, 0] = np.nan
X.iloc[5:15, 1] = np.nan

imputer = KNNImputer(n_neighbors=3)
X_imputed = imputer.fit_transform(X)
print(f"Missing values after imputation: {X_imputed.isnull().sum().sum()}")
```

---

## Exercise 4.3: Scaling Strategies

**Objective:** Implement different scaling strategies.

**Code Template:**

```python
class Scaler:
    def __init__(self, method='standard'):
        self.method = method
        self.params = {}
    
    def fit(self, X):
        # Your code here
        # Calculate scaling parameters
        pass
    
    def transform(self, X):
        # Your code here
        # Apply scaling
        pass
```

**Supported Methods:**
- standard: (x - mean) / std
- robust: (x - median) / IQR
- minmax: (x - min) / (max - min)
- maxabs: x / max(abs)

**Test:**

```python
df = pd.DataFrame({
    'age': np.random.normal(35, 10, 100),
    'income': np.random.exponential(50000, 100)
})

# Test each scaling method
for method in ['standard', 'robust', 'minmax']:
    scaler = Scaler(method=method)
    scaled = scaler.fit_transform(df)
    print(f"{method}: mean={scaled.mean():.2f}, std={scaled.std():.2f}")
```

---

## Exercise 4.4: Preprocessing Pipeline

**Objective:** Combine imputation and scaling into a pipeline.

**Code Template:**

```python
class PreprocessingPipeline:
    def __init__(self, imputation_strategy='median', scaling_strategy='standard'):
        self.imputation_strategy = imputation_strategy
        self.scaling_strategy = scaling_strategy
        self.imputer = None
        self.scaler = None
    
    def fit(self, X):
        # Your code here
        pass
    
    def transform(self, X):
        # Your code here
        pass
    
    def fit_transform(self, X):
        # Your code here
        pass
```

**Test:**

```python
# Create data with missing values
df = pd.DataFrame({
    'age': np.append(np.random.normal(35, 10, 95), [np.nan]*5),
    'income': np.append(np.random.exponential(50000, 98), [np.nan]*2),
    'value': np.random.normal(100, 20, 100)
})

pipeline = PreprocessingPipeline()
X_transformed = pipeline.fit_transform(df)
print(f"Missing after: {X_transformed.isnull().sum().sum()}")
print(f"Mean: {X_transformed.mean():.2f}")
print(f"Std: {X_transformed.std():.2f}")
```

---

### Part 4 Checkpoint

- [ ] Imputation strategies implemented
- [ ] KNN imputation implemented
- [ ] Scaling strategies implemented
- [ ] Preprocessing pipeline built

---

# PART 5: CATEGORICAL ENCODING

## Exercise 5.1: One-Hot Encoding

**Objective:** Implement one-hot encoding with rare category handling.

**Code Template:**

```python
class OneHotEncoder:
    def __init__(self, min_frequency=0.01, handle_unknown='ignore'):
        self.min_frequency = min_frequency
        self.handle_unknown = handle_unknown
        self.categories = {}
    
    def fit(self, X, columns=None):
        # Your code here
        # Identify categories
        # Handle rare categories
        pass
    
    def transform(self, X):
        # Your code here
        # Create binary columns
        pass
```

**Test:**

```python
df = pd.DataFrame({
    'city': ['NYC']*80 + ['LA']*10 + ['CHI']*5 + ['HOU']*3 + ['PHX']*2,
    'category': np.random.choice(['A', 'B', 'C', 'D'], 100)
})

encoder = OneHotEncoder(min_frequency=0.05)
X_encoded = encoder.fit_transform(df)
print(f"Original columns: {df.shape[1]}")
print(f"Encoded columns: {X_encoded.shape[1]}")
```

---

## Exercise 5.2: Target Encoding

**Objective:** Implement target encoding with smoothing.

**Code Template:**

```python
class TargetEncoder:
    def __init__(self, smoothing=1.0, min_samples_leaf=10):
        self.smoothing = smoothing
        self.min_samples_leaf = min_samples_leaf
        self.encoding = {}
        self.prior = None
    
    def fit(self, X, y, column):
        # Your code here
        # Calculate global mean
        # Calculate category means
        # Apply smoothing
        pass
    
    def transform(self, X, column):
        # Your code here
        # Map categories to encoded values
        pass
    
    def fit_transform(self, X, y, column):
        # Your code here
        pass
```

**Test:**

```python
df = pd.DataFrame({
    'city': ['NYC']*100 + ['LA']*50 + ['CHI']*30 + ['HOU']*20,
    'target': np.random.normal(50, 15, 200)
})

encoder = TargetEncoder(smoothing=1.0)
encoded = encoder.fit_transform(df, df['target'], 'city')
print(encoder.encoding)
```

---

## Exercise 5.3: Frequency Encoding

**Objective:** Implement frequency encoding.

**Code Template:**

```python
class FrequencyEncoder:
    def __init__(self, normalize=True):
        self.normalize = normalize
        self.frequencies = {}
    
    def fit(self, X, column):
        # Your code here
        pass
    
    def transform(self, X, column):
        # Your code here
        pass
    
    def fit_transform(self, X, column):
        # Your code here
        pass
```

**Test:**

```python
df = pd.DataFrame({
    'city': ['NYC']*80 + ['LA']*10 + ['CHI']*5 + ['HOU']*3 + ['PHX']*2
})

encoder = FrequencyEncoder()
encoded = encoder.fit_transform(df, 'city')
print(encoded.value_counts())
```

---

## Exercise 5.4: Auto Encoder Selection

**Objective:** Implement automatic strategy selection.

**Code Template:**

```python
class AutoEncoder:
    def __init__(self, target_col=None):
        self.target_col = target_col
        self.strategy = None
        self.encoder = None
    
    def fit(self, X, y=None, column=None):
        # Your code here
        # Analyze cardinality
        # Select best strategy
        # Fit encoder
        pass
    
    def transform(self, X, column):
        # Your code here
        pass
    
    def fit_transform(self, X, y=None, column=None):
        # Your code here
        pass
```

**Decision Rules:**
- Cardinality <= 10: One-hot
- 10 < cardinality <= 50: Target if target available
- 50 < cardinality <= 100: Frequency
- > 100: Hashing (bonus)

**Test:**

```python
df = pd.DataFrame({
    'city_low': np.random.choice(['A', 'B', 'C', 'D'], 100),
    'city_med': np.random.choice([f'city_{i}' for i in range(30)], 100),
    'city_high': np.random.choice([f'city_{i}' for i in range(200)], 100),
    'target': np.random.normal(50, 15, 100)
})

encoder = AutoEncoder(target_col='target')
for col in ['city_low', 'city_med', 'city_high']:
    encoded = encoder.fit_transform(df, df['target'], col)
    print(f"{col}: {encoder.strategy}")
```

---

### Part 5 Checkpoint

- [ ] One-hot encoding implemented
- [ ] Target encoding implemented
- [ ] Frequency encoding implemented
- [ ] Auto encoder selection implemented

---

# PART 6: FEATURE CREATION & SELECTION

## Exercise 6.1: Polynomial Features

**Objective:** Create polynomial and interaction features.

**Code Template:**

```python
class PolynomialFeatures:
    def __init__(self, degree=2, interaction_only=False):
        self.degree = degree
        self.interaction_only = interaction_only
        self.feature_names = []
    
    def fit(self, X):
        # Your code here
        pass
    
    def transform(self, X):
        # Your code here
        pass
```

**Test:**

```python
X = pd.DataFrame({
    'x1': np.random.normal(0, 1, 100),
    'x2': np.random.normal(0, 1, 100)
})

poly = PolynomialFeatures(degree=2)
X_poly = poly.fit_transform(X)
print(f"Original: {X.shape[1]}, Polynomial: {X_poly.shape[1]}")
```

---

## Exercise 6.2: Ratio Features

**Objective:** Create ratio and difference features.

**Code Template:**

```python
class RatioFeatures:
    def __init__(self, columns):
        self.columns = columns
    
    def transform(self, X):
        # Your code here
        # Create: ratio, difference, product
        pass
```

**Test:**

```python
X = pd.DataFrame({
    'income': np.random.exponential(50000, 100),
    'spend': np.random.exponential(10000, 100)
})

ratio = RatioFeatures(['income', 'spend'])
X_new = ratio.transform(X)
print(X_new.columns.tolist())
```

---

## Exercise 6.3: Correlation-Based Selection

**Objective:** Select features based on correlation with target.

**Code Template:**

```python
class CorrelationSelector:
    def __init__(self, threshold=0.1):
        self.threshold = threshold
        self.selected_features = []
    
    def fit(self, X, y):
        # Your code here
        pass
    
    def transform(self, X):
        # Your code here
        pass
```

**Test:**

```python
X = pd.DataFrame({
    'f1': np.random.normal(0, 1, 100),
    'f2': np.random.normal(0, 1, 100),
    'f3': np.random.normal(0, 1, 100),
    'f4': np.random.normal(0, 1, 100)
})
y = X['f1'] * 2 + X['f2'] * 3 + np.random.normal(0, 0.5, 100)

selector = CorrelationSelector(threshold=0.3)
X_selected = selector.fit_transform(X, y)
print(f"Selected features: {selector.selected_features}")
```

---

## Exercise 6.4: Model-Based Feature Selection

**Objective:** Select features using model importance.

**Code Template:**

```python
class ModelSelector:
    def __init__(self, estimator=None, n_features=None):
        self.estimator = estimator
        self.n_features = n_features
        self.selected_features = []
    
    def fit(self, X, y):
        # Your code here
        pass
    
    def transform(self, X):
        # Your code here
        pass
```

**Test:**

```python
from sklearn.ensemble import RandomForestClassifier

X, y = make_classification(n_samples=100, n_features=10, n_informative=5)
X = pd.DataFrame(X, columns=[f'f{i}' for i in range(10)])

selector = ModelSelector(n_features=5)
X_selected = selector.fit_transform(X, y)
print(f"Selected: {selector.selected_features}")
```

---

### Part 6 Checkpoint

- [ ] Polynomial features created
- [ ] Ratio features created
- [ ] Correlation-based selection implemented
- [ ] Model-based selection implemented

---

# PART 7: DIMENSIONALITY REDUCTION & IMBALANCE

## Exercise 7.1: PCA Implementation

**Objective:** Implement PCA from scratch.

**Code Template:**

```python
class PCA:
    def __init__(self, n_components=None):
        self.n_components = n_components
        self.components = None
        self.mean = None
        self.explained_variance = None
    
    def fit(self, X):
        # Your code here
        # Center data
        # Compute covariance
        # Get eigenvectors
        pass
    
    def transform(self, X):
        # Your code here
        pass
    
    def get_explained_variance_ratio(self):
        # Your code here
        pass
```

**Test:**

```python
X, _ = make_classification(n_samples=100, n_features=10)
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)
print(f"Original: {X.shape[1]}, Reduced: {X_pca.shape[1]}")
print(f"Explained variance: {pca.get_explained_variance_ratio()}")
```

---

## Exercise 7.2: t-SNE Visualization

**Objective:** Use t-SNE for visualization.

**Instructions:**

1. Load the digits dataset from sklearn
2. Apply PCA to reduce to 50 dimensions
3. Apply t-SNE to reduce to 2 dimensions
4. Plot the results colored by digit

```python
from sklearn.datasets import load_digits
from sklearn.manifold import TSNE
import matplotlib.pyplot as plt

# Your code here
```

---

## Exercise 7.3: SMOTE Implementation

**Objective:** Implement SMOTE from scratch.

**Code Template:**

```python
class SMOTE:
    def __init__(self, k_neighbors=5, sampling_strategy='auto'):
        self.k_neighbors = k_neighbors
        self.sampling_strategy = sampling_strategy
    
    def fit_resample(self, X, y):
        # Your code here
        # Find minority class
        # For each minority sample:
        #  - Find k nearest neighbors
        #  - Choose random neighbor
        #  - Create synthetic sample
        pass
```

**Test:**

```python
from sklearn.datasets import make_classification

X, y = make_classification(n_samples=1000, n_features=10, weights=[0.9, 0.1])
print(f"Before: {np.bincount(y)}")

smote = SMOTE()
X_resampled, y_resampled = smote.fit_resample(X, y)
print(f"After: {np.bincount(y_resampled)}")
```

---

## Exercise 7.4: Class Weights

**Objective:** Implement class weight calculation.

**Code Template:**

```python
def compute_class_weights(y, method='balanced'):
    # Your code here
    # For 'balanced': weight = n_samples / (n_classes * n_samples_class)
    # For 'inverse': weight = 1 / frequency
    pass
```

**Test:**

```python
y = np.array([0]*900 + [1]*100)
weights = compute_class_weights(y, method='balanced')
print(f"Class weights: {weights}")
```

---

### Part 7 Checkpoint

- [ ] PCA implemented from scratch
- [ ] t-SNE visualization created
- [ ] SMOTE implemented
- [ ] Class weights calculated

---

# PART 8: TREE-BASED MODELS

## Exercise 8.1: Decision Tree from Scratch

**Objective:** Implement a decision tree classifier from scratch.

**Code Template:**

```python
class DecisionTree:
    def __init__(self, max_depth=None, min_samples_split=2):
        self.max_depth = max_depth
        self.min_samples_split = min_samples_split
        self.tree = None
    
    def fit(self, X, y):
        # Your code here
        pass
    
    def predict(self, X):
        # Your code here
        pass
    
    def predict_proba(self, X):
        # Your code here
        pass
```

**Hints:**
- Implement Gini impurity or entropy
- Recursive splitting
- Leaf node prediction

**Test:**

```python
from sklearn.datasets import load_iris

X, y = load_iris(return_X_y=True)
tree = DecisionTree(max_depth=3)
tree.fit(X, y)
predictions = tree.predict(X)
print(f"Accuracy: {np.mean(predictions == y):.4f}")
```

---

## Exercise 8.2: Random Forest from Scratch

**Objective:** Implement a random forest classifier.

**Code Template:**

```python
class RandomForest:
    def __init__(self, n_estimators=100, max_depth=None, max_features='sqrt'):
        self.n_estimators = n_estimators
        self.max_depth = max_depth
        self.max_features = max_features
        self.trees = []
    
    def fit(self, X, y):
        # Your code here
        # Bootstrap samples
        # Random feature subsets
        # Train decision trees
        pass
    
    def predict(self, X):
        # Your code here
        pass
    
    def predict_proba(self, X):
        # Your code here
        pass
```

**Test:**

```python
from sklearn.datasets import make_classification

X, y = make_classification(n_samples=500, n_features=10, n_informative=5)
rf = RandomForest(n_estimators=10)
rf.fit(X, y)
predictions = rf.predict(X)
print(f"Accuracy: {np.mean(predictions == y):.4f}")
```

---

## Exercise 8.3: XGBoost Custom Evaluation

**Objective:** Create a custom evaluation function for XGBoost.

**Code Template:**

```python
def custom_eval(y_pred, y_true):
    # Your code here
    # Calculate custom metric
    # Example: Profit-based metric
    # Return: (metric_name, metric_value, is_greater_better)
    pass
```

**Test:**

```python
import xgboost as xgb

model = xgb.XGBClassifier(eval_metric=custom_eval)
model.fit(X_train, y_train, eval_set=[(X_val, y_val)], verbose=False)
```

---

## Exercise 8.4: Model Comparison

**Objective:** Compare multiple tree-based models.

**Instructions:**

Compare at least 3 models on the same dataset:
1. Decision Tree
2. Random Forest
3. XGBoost (or LightGBM)

Report:
- Accuracy on test set
- Training time
- Inference time
- Feature importance
- Key differences

```python
# Your code here
```

---

### Part 8 Checkpoint

- [ ] Decision Tree implemented from scratch
- [ ] Random Forest implemented from scratch
- [ ] XGBoost custom evaluation created
- [ ] Model comparison completed

---

# PART 9: UNSUPERVISED LEARNING

## Exercise 9.1: K-Means from Scratch

**Objective:** Implement K-Means clustering from scratch.

**Code Template:**

```python
class KMeans:
    def __init__(self, n_clusters=3, max_iter=100, random_state=42):
        self.n_clusters = n_clusters
        self.max_iter = max_iter
        self.random_state = random_state
        self.centroids = None
        self.labels = None
    
    def fit(self, X):
        # Your code here
        # Initialize centroids
        # Iterate: assign points, update centroids
        pass
    
    def predict(self, X):
        # Your code here
        pass
    
    def inertia(self):
        # Your code here
        pass
```

**Test:**

```python
from sklearn.datasets import make_blobs

X, _ = make_blobs(n_samples=500, centers=4, cluster_std=0.8)
kmeans = KMeans(n_clusters=4)
kmeans.fit(X)
print(f"Inertia: {kmeans.inertia():.2f}")
```

---

## Exercise 9.2: Elbow Method

**Objective:** Implement the elbow method to find optimal K.

**Code Template:**

```python
def elbow_method(X, max_k=10):
    # Your code here
    # Calculate inertia for each k
    # Return: list of k values, list of inertias
    pass
```

**Test:**

```python
from sklearn.datasets import make_blobs

X, _ = make_blobs(n_samples=500, centers=4, cluster_std=0.8)
k_values, inertias = elbow_method(X)
print(k_values, inertias)
```

---

## Exercise 9.3: DBSCAN Parameter Tuning

**Objective:** Tune DBSCAN parameters.

**Instructions:**

1. Load the moons dataset
2. Try different eps and min_samples values
3. Find optimal parameters
4. Visualize the clusters

```python
from sklearn.datasets import make_moons

X, y = make_moons(n_samples=500, noise=0.1)

# Your code here
```

---

## Exercise 9.4: Silhouette Analysis

**Objective:** Evaluate clustering using silhouette score.

**Code Template:**

```python
def silhouette_analysis(X, k_values):
    # Your code here
    # For each k:
    #  - Fit K-Means
    #  - Calculate silhouette score
    # Return: k_values, scores
    pass
```

**Test:**

```python
from sklearn.datasets import make_blobs

X, _ = make_blobs(n_samples=500, centers=4, cluster_std=0.8)
k_values, scores = silhouette_analysis(X, range(2, 11))
print(scores)
```

---

### Part 9 Checkpoint

- [ ] K-Means implemented from scratch
- [ ] Elbow method implemented
- [ ] DBSCAN parameters tuned
- [ ] Silhouette analysis completed

---

# PART 10: DEEP LEARNING

## Exercise 10.1: Tensor Operations

**Objective:** Practice PyTorch tensor operations.

**Instructions:**

1. Create a tensor of shape (3, 4) with random values
2. Compute the mean, std, sum
3. Create a second tensor and compute matrix multiplication
4. Move tensor to GPU (if available)

```python
import torch

# Your code here
```

---

## Exercise 10.2: Build a Neural Network

**Objective:** Build a neural network for MNIST classification.

**Code Template:**

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class MNISTClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        # Your code here
        pass
    
    def forward(self, x):
        # Your code here
        pass
```

**Test:**

```python
# Train the model on MNIST
from torchvision import datasets, transforms
# Your code here
```

---

## Exercise 10.3: Training Loop

**Objective:** Write a complete training loop.

**Code Template:**

```python
def train_epoch(model, dataloader, optimizer, criterion):
    # Your code here
    # Forward pass
    # Backward pass
    # Update weights
    # Return average loss
    pass

def validate(model, dataloader, criterion):
    # Your code here
    # Evaluate on validation set
    # Return accuracy
    pass
```

**Test:**

```python
# Train for 10 epochs
for epoch in range(10):
    train_loss = train_epoch(model, train_loader, optimizer, criterion)
    val_acc = validate(model, val_loader, criterion)
    print(f"Epoch {epoch+1}: Loss={train_loss:.4f}, Val Acc={val_acc:.4f}")
```

---

## Exercise 10.4: Early Stopping

**Objective:** Implement early stopping.

**Code Template:**

```python
class EarlyStopping:
    def __init__(self, patience=5, min_delta=1e-4):
        # Your code here
        pass
    
    def __call__(self, val_loss, model):
        # Your code here
        # Return True if training should stop
        pass
```

**Test:**

```python
early_stop = EarlyStopping(patience=3)
for epoch in range(50):
    val_loss = validate(model, val_loader, criterion)
    if early_stop(val_loss, model):
        print(f"Early stopping at epoch {epoch+1}")
        break
```

---

### Part 10 Checkpoint

- [ ] Tensor operations practiced
- [ ] Neural network built for MNIST
- [ ] Training loop implemented
- [ ] Early stopping implemented

---

# PART 11: CROSS-VALIDATION & EVALUATION

## Exercise 11.1: Cross-Validation Implementation

**Objective:** Implement cross-validation from scratch.

**Code Template:**

```python
def cross_validate(model, X, y, cv=5, scoring='accuracy'):
    # Your code here
    # Split data into k folds
    # Train on k-1 folds
    # Test on 1 fold
    # Return scores
    pass
```

**Test:**

```python
from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeClassifier

X, y = load_iris(return_X_y=True)
model = DecisionTreeClassifier()
scores = cross_validate(model, X, y, cv=5)
print(f"Scores: {scores}")
print(f"Mean: {np.mean(scores):.4f}")
```

---

## Exercise 11.2: Custom Scoring Functions

**Objective:** Create custom scoring functions.

**Code Template:**

```python
def profit_score(y_true, y_pred):
    # Your code here
    # Assume profit = 100 for TP, cost = 10 for FP
    pass

def balanced_accuracy_score(y_true, y_pred):
    # Your code here
    pass
```

**Test:**

```python
from sklearn.metrics import make_scorer

profit_scorer = make_scorer(profit_score, greater_is_better=True)
scores = cross_validate(model, X, y, scoring=profit_scorer)
```

---

## Exercise 11.3: Confusion Matrix Analysis

**Objective:** Analyze a confusion matrix in detail.

**Instructions:**

Given the following confusion matrix, calculate all metrics:

```
                Predicted
              Positive   Negative
Actual Positive    120         30
       Negative     20        230
```

Calculate:
1. Accuracy
2. Precision
3. Recall
4. F1 Score
5. Specificity
6. Sensitivity

---

## Exercise 11.4: ROC Curve Implementation

**Objective:** Implement ROC curve calculation.

**Code Template:**

```python
def roc_curve(y_true, y_scores):
    # Your code here
    # Calculate false positive rate and true positive rate
    # For each threshold
    pass
```

**Test:**

```python
from sklearn.datasets import make_classification

X, y = make_classification(n_samples=1000, n_features=10)
model = LogisticRegression()
model.fit(X[:800], y[:800])
y_scores = model.predict_proba(X[800:])[:, 1]

fpr, tpr = roc_curve(y[800:], y_scores)
print(f"Shape: {fpr.shape}")
```

---

### Part 11 Checkpoint

- [ ] Cross-validation implemented
- [ ] Custom scoring functions created
- [ ] Confusion matrix analyzed
- [ ] ROC curve implemented

---

# PART 12: HYPERPARAMETER OPTIMIZATION

## Exercise 12.1: Grid Search from Scratch

**Objective:** Implement grid search from scratch.

**Code Template:**

```python
def grid_search(model, param_grid, X, y, cv=5):
    # Your code here
    # For each parameter combination
    #  - Perform cross-validation
    #  - Store results
    # Return best parameters and best score
    pass
```

**Test:**

```python
param_grid = {
    'max_depth': [3, 5, 7],
    'n_estimators': [50, 100, 150]
}
model = RandomForestClassifier(random_state=42)
best_params, best_score = grid_search(model, param_grid, X, y)
print(f"Best: {best_params} -> {best_score:.4f}")
```

---

## Exercise 12.2: Random Search

**Objective:** Implement random search.

**Code Template:**

```python
def random_search(model, param_dist, X, y, n_iter=50, cv=5):
    # Your code here
    # Randomly sample parameter combinations
    # Perform cross-validation
    # Track best
    pass
```

**Test:**

```python
param_dist = {
    'max_depth': [3, 5, 7, 9, 11],
    'n_estimators': [50, 100, 150, 200, 250],
    'min_samples_split': [2, 5, 10, 20]
}
best_params, best_score = random_search(model, param_dist, X, y, n_iter=20)
```

---

## Exercise 12.3: Optuna Objective Function

**Objective:** Create an Optuna objective function.

**Code Template:**

```python
def objective(trial):
    # Your code here
    # Suggest parameters
    # Train model
    # Return validation score
    pass
```

**Test:**

```python
study = optuna.create_study(direction='maximize')
study.optimize(objective, n_trials=50)
print(study.best_params)
```

---

## Exercise 12.4: Tuning Visualization

**Objective:** Visualize tuning results.

**Instructions:**

Create a function that plots:
1. Optimization history
2. Parameter importance
3. Parallel coordinate plot

```python
def plot_tuning_results(study):
    # Your code here
    pass
```

---

### Part 12 Checkpoint

- [ ] Grid search implemented
- [ ] Random search implemented
- [ ] Optuna objective created
- [ ] Tuning visualization created

---

# PART 13: PIPELINE CONSTRUCTION

## Exercise 13.1: Pipeline Building

**Objective:** Build a complete preprocessing and modeling pipeline.

**Instructions:**

Create a pipeline that:
1. Imputes missing values
2. Scales numeric features
3. Encodes categorical features
4. Trains a model

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.ensemble import RandomForestClassifier

# Your code here
```

---

## Exercise 13.2: Cross-Validation Pipeline

**Objective:** Add cross-validation to the pipeline.

**Code Template:**

```python
def cross_val_pipeline(pipeline, X, y, cv=5):
    # Your code here
    # Perform cross-validation on the pipeline
    # Return scores
    pass
```

---

## Exercise 13.3: Hyperparameter Tuning with Pipeline

**Objective:** Tune hyperparameters of a pipeline.

**Instructions:**

Use GridSearchCV or RandomizedSearchCV with a pipeline:

```python
from sklearn.model_selection import GridSearchCV

# Your code here
```

---

## Exercise 13.4: Feature Importance Pipeline

**Objective:** Extract feature importance from a pipeline.

**Code Template:**

```python
def get_pipeline_importance(pipeline, X, feature_names):
    # Your code here
    # Extract model from pipeline
    # Get feature importance
    # Map to feature names
    pass
```

---

### Part 13 Checkpoint

- [ ] Pipeline built
- [ ] Cross-validation pipeline implemented
- [ ] Hyperparameter tuning integrated
- [ ] Feature importance extracted

---

# PART 14: CAPSTONE PROJECT

## Exercise 14.1: Problem Definition

**Objective:** Define the business problem and success metrics.

**Instructions:**

For your chosen dataset, define:

1. Problem statement
2. Business impact
3. Success metrics
4. Constraints
5. Risks

**Template:**

```
Problem Statement:
_________________________________________________

Business Impact:
_________________________________________________

Success Metrics:
_________________________________________________

Constraints:
_________________________________________________

Risks:
_________________________________________________
```

---

## Exercise 14.2: Data Preparation

**Objective:** Prepare the data for modeling.

**Instructions:**

1. Load the data
2. Clean the data
3. Handle missing values
4. Explore the data
5. Create visualizations

```python
# Your code here
```

---

## Exercise 14.3: Model Selection

**Objective:** Select the best model for the problem.

**Instructions:**

Try at least 3 different models:
1. Baseline model
2. Tree-based model
3. Another model

Compare results:

| Model | Accuracy | F1 | ROC-AUC | Training Time | Inference Time |
|-------|----------|----|---------|---------------|----------------|
|       |          |    |         |               |                |
|       |          |    |         |               |                |
|       |          |    |         |               |                |

---

## Exercise 14.4: Feature Interpretation

**Objective:** Interpret the model's predictions.

**Instructions:**

1. Get feature importance
2. Identify top 5 features
3. Explain why they matter
4. Create SHAP or LIME explanations

```python
# Your code here
```

---

## Exercise 14.5: Business Impact Analysis

**Objective:** Quantify the business impact.

**Instructions:**

1. Calculate potential savings
2. Estimate ROI
3. Recommend actions
4. Identify risks

---

### Part 14 Checkpoint

- [ ] Problem defined
- [ ] Data prepared
- [ ] Models compared
- [ ] Features interpreted
- [ ] Business impact analyzed

---

# PART 15: DEPLOYMENT & MONITORING

## Exercise 15.1: API Endpoint

**Objective:** Create a FastAPI endpoint for predictions.

**Code Template:**

```python
from fastapi import FastAPI
from pydantic import BaseModel
import joblib

app = FastAPI()

class PredictRequest(BaseModel):
    # Your code here
    pass

class PredictResponse(BaseModel):
    # Your code here
    pass

@app.post("/predict")
def predict(request: PredictRequest):
    # Your code here
    pass
```

---

## Exercise 15.2: Docker Container

**Objective:** Create a Dockerfile for the API.

**Instructions:**

Write a Dockerfile that:
1. Uses Python 3.9 slim
2. Installs dependencies
3. Copies the code
4. Exposes port 8000
5. Runs the API

```dockerfile
# Your code here
```

---

## Exercise 15.3: Health Check

**Objective:** Add health check endpoint.

**Code Template:**

```python
@app.get("/health")
def health():
    # Your code here
    # Check model loaded
    # Return status
    pass
```

---

## Exercise 15.4: Model Monitoring

**Objective:** Set up basic monitoring.

**Instructions:**

Track:
1. Number of predictions
2. Prediction distribution
3. Response time
4. Errors

```python
class Monitor:
    def __init__(self):
        # Your code here
        pass
    
    def log_prediction(self, features, prediction, latency):
        # Your code here
        pass
    
    def get_metrics(self):
        # Your code here
        pass
```

---

### Part 15 Checkpoint

- [ ] API endpoint created
- [ ] Docker container built
- [ ] Health check added
- [ ] Monitoring implemented

---

# FINAL REVIEW

## Knowledge Check

Answer the following questions:

1. What is the most important step in the ML pipeline?
   _________________________________________________________________

2. How do you prevent data leakage?
   _________________________________________________________________

3. What are three types of missing data?
   _________________________________________________________________

4. When would you use target encoding vs one-hot encoding?
   _________________________________________________________________

5. Why is cross-validation important?
   _________________________________________________________________

6. What is the difference between grid search and random search?
   _________________________________________________________________

7. How do you deploy a model in production?
   _________________________________________________________________

8. What should you monitor in production?
   _________________________________________________________________

## Project Reflection

1. What was the most challenging part of the series?
   _________________________________________________________________

2. What was the most valuable skill you learned?
   _________________________________________________________________

3. What would you do differently next time?
   _________________________________________________________________

4. What will you build next?
   _________________________________________________________________

## Certificates of Completion

Congratulations on completing the workbook! You have developed skills in:

- [ ] Python programming for ML
- [ ] Data validation and quality
- [ ] Exploratory data analysis
- [ ] Feature engineering
- [ ] Model training and evaluation
- [ ] Hyperparameter optimization
- [ ] Pipeline construction
- [ ] Model deployment
- [ ] Production monitoring

---

*End of Student Workbook*
