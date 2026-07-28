## Appendix B: Common Pitfalls & Anti-Patterns in Machine Learning Engineering

Even experienced software engineers can introduce subtle bugs when transitioning into machine learning development. Because machine learning models learn statistical patterns rather than explicit logic, errors often manifest not as hard application crashes, but as silent performance degradation, falsely inflated accuracy metrics, or production runtime failures.

This reference manual outlines the most common machine learning anti-patterns and how to avoid them using idiomatic Scikit-Learn patterns.

---

### 1. The Preprocessing Data Leakage Anti-Pattern

#### The Mistake

Computing normalization statistics (like mean and standard deviation) or imputing missing values across the *entire* dataset before splitting it into training and testing sets.

```python
# [ANTI-PATTERN] - DO NOT DO THIS
from sklearn.preprocessing import StandardScaler
import numpy as np

X = np.array([[10, 2], [20, 4], [30, 6], [1000, 200]]) # Last row is an outlier

# Scaling the entire dataset before train/test split leaks test statistics into training data
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X) 

```

#### Why It Fails

The training model inadvertently learns information from the validation/test distribution (e.g., the mean and variance incorporate test data points). This leads to overly optimistic evaluation metrics during cross-validation that plummet drastically when the model encounters truly unseen production data.

#### The Correct Fix

Always split your data first, then encapsulate your preprocessing steps inside a Scikit-Learn `Pipeline` or fit transformers exclusively on the training fold:

```python
# [CORRECT PATTERN]
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model', SomeEstimator())
])
pipeline.fit(X_train, y_train) # Scaler learns parameters ONLY from X_train folds

```

---

### 2. Unhandled Categorical Vocabulary ("Unknown Category" Crashes)

#### The Mistake

Using standard categorical encoding without accounting for new categories introduced after training.

```python
# [ANTI-PATTERN]
from sklearn.preprocessing import OneHotEncoder

# Training data contains departments: Engineering, Marketing
encoder = OneHotEncoder(sparse_output=False)
encoder.fit([['Engineering'], ['Marketing']])

# Production data introduces a brand new department: 'Sales' -> Throws ValueError!
encoder.transform([['Sales']]) 

```

#### Why It Fails

Production environments are dynamic. When a user inputs a category that was never present in your historical training logs, default encoders throw a runtime exception, breaking your inference pipeline.

#### The Correct Fix

Always configure your `OneHotEncoder` to gracefully handle unknown values by mapping them to all-zero indicator columns:

```python
# [CORRECT PATTERN]
encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')
encoder.fit([['Engineering'], ['Marketing']])

# Safely ignored/mapped to zero vector instead of crashing
safe_transform = encoder.transform([['Sales']])

```

---

### 3. Relying Solely on Accuracy for Imbalanced Classes

#### The Mistake

Evaluating a classification model using only accuracy when the target variable is severely skewed (e.g., 99% legitimate transactions, 1% fraudulent transactions).

#### Why It Fails

A naive model that predicts "Legitimate" 100% of the time achieves **99% accuracy**, making it look exceptional while completely failing at its core objective (detecting the 1% fraud cases).

#### The Correct Fix

Always pair accuracy with precision, recall, F1-score, and ROC-AUC metrics, or utilize stratified cross-validation to maintain class balance proportions across evaluation folds.
