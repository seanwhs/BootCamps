## Part 4: Advanced Tuning & Model Optimization

Welcome to Part 4. By now, you can build end-to-end pipelines, train supervised models, and uncover hidden structures in unsupervised data. But default model parameters are rarely optimal for production performance.

In this part, we move beyond defaults to extract maximum predictive power through exhaustive hyperparameter searches, custom transformers, and powerful model ensembles.

---

### Step 4.1: Hyperparameter Tuning – GridSearchCV vs. RandomizedSearchCV

#### The Target

Write a script (`hyperparameter_tuning.py`) that uses `GridSearchCV` and `RandomizedSearchCV` to systematically discover the optimal hyperparameters for a Random Forest classifier.

#### The Concept

Hyperparameters are the settings you choose *before* training begins (like the maximum depth of a tree or the learning rate).

* **GridSearchCV** is like searching a city block by checking every single house on every single street in a strict grid order. It is exhaustive and guarantees you find the best house, but it can be painfully slow.
* **RandomizedSearchCV** is like parachuting into random neighborhoods across the city. It samples a fixed number of random configurations, finding a near-optimal solution in a fraction of the time.

#### The Implementation

Create a file named `hyperparameter_tuning.py` with the following code:

```python
# hyperparameter_tuning.py
from sklearn.datasets import load_breast_cancer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV, train_test_split
from scipy.stats import randint

def run_tuning():
    data = load_breast_cancer()
    X, y = data.data, data.target
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    rf = RandomForestClassifier(random_state=42)

    # 1. GridSearchCV: Exhaustive grid search
    param_grid = {
        'n_estimators': [50, 100],
        'max_depth': [None, 10, 20],
        'min_samples_split': [2, 5]
    }

    print("--- Running GridSearchCV ---")
    grid_search = GridSearchCV(estimator=rf, param_grid=param_grid, cv=3, scoring='accuracy', n_jobs=-1)
    grid_search.fit(X_train, y_train)

    print(f"Best Grid Parameters: {grid_search.best_params_}")
    print(f"Best Grid CV Accuracy: {grid_search.best_score_ * 100:.2f}%")

    # 2. RandomizedSearchCV: Stochastic sampling search
    param_dist = {
        'n_estimators': randint(50, 200),
        'max_depth': [None, 10, 20, 30],
        'min_samples_split': randint(2, 10)
    }

    print("\n--- Running RandomizedSearchCV ---")
    random_search = RandomizedSearchCV(estimator=rf, param_distributions=param_dist, n_iter=5, cv=3, scoring='accuracy', random_state=42, n_jobs=-1)
    random_search.fit(X_train, y_train)

    print(f"Best Random Parameters: {random_search.best_params_}")
    print(f"Best Random CV Accuracy: {random_search.best_score_ * 100:.2f}%")

if __name__ == '__main__':
    run_tuning()

```

#### The Verification

Execute the hyperparameter tuning script in your terminal:

```bash
python hyperparameter_tuning.py

```

You should see output detailing the execution of both searches, printing out the winning hyperparameter combinations and cross-validation accuracy scores.

---

### Step 4.2: Writing Custom Scikit-Learn Transformers

#### The Target

Create a custom Scikit-Learn compatible transformer (`custom_transformer.py`) using `FunctionTransformer` and a custom Python class to engineer custom feature interactions.

#### The Concept

Sometimes built-in scalers and encoders are not enough for domain-specific business logic (e.g., calculating debt-to-income ratios or extracting text length). Scikit-Learn allows you to write custom transformers that snap directly into pipelines using `.fit()` and `.transform()` methods, ensuring custom logic integrates seamlessly without breaking data flows.

#### The Implementation

Create a file named `custom_transformer.py` with the following code:

```python
# custom_transformer.py
import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression

# Custom Transformer class following Scikit-Learn interface conventions
class IncomePerAgeTransformer(BaseEstimator, TransformerMixin):
    def __init__(self):
        pass

    def fit(self, X, y=None):
        # Stateless transformer, nothing to learn from training data
        return self

    def transform(self, X):
        # Create a copy to prevent SettingWithCopy warnings
        X_ = X.copy()
        # Engineering a new financial ratio feature: income divided by age
        X_['income_per_age'] = X_['income'] / X_['age']
        return X_

def run_custom_transformer():
    # Mock data
    data = pd.DataFrame({
        'age': [25, 40, 55],
        'income': [40000, 90000, 130000]
    })

    transformer = IncomePerAgeTransformer()
    transformed_df = transformer.transform(data)

    print("--- Custom Transformer Output ---")
    print(transformed_df)

if __name__ == '__main__':
    run_custom_transformer()

```

#### The Verification

Run the custom transformer script:

```bash
python custom_transformer.py

```

You should see your mock dataframe output with the newly engineered `income_per_age` column successfully calculated and appended.

---

### Step 4.3: Ensemble Methods – Stacking & Voting Classifiers

#### The Target

Build an advanced ensemble script (`ensemble_stacking.py`) that combines multiple distinct models (Logistic Regression, Decision Tree, and Random Forest) using a Voting Classifier.

#### The Concept

Just as medical diagnoses are more reliable when reviewed by a panel of specialist doctors rather than a single general practitioner, a **Voting Classifier** aggregates predictions from multiple fundamentally different machine learning models, pooling their strengths to make a final consensus prediction.

#### The Implementation

Create a file named `ensemble_stacking.py` with the following code:

```python
# ensemble_stacking.py
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, VotingClassifier
from sklearn.metrics import accuracy_score

def run_voting_ensemble():
    data = load_breast_cancer()
    X, y = data.data, data.target
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Define diverse base estimators
    clf1 = LogisticRegression(max_iter=1000, random_state=42)
    clf2 = DecisionTreeClassifier(random_state=42)
    clf3 = RandomForestClassifier(n_estimators=100, random_state=42)

    # Combine into a Voting Classifier (majority rule)
    ensemble = VotingClassifier(
        estimators=[('lr', clf1), ('dt', clf2), ('rf', clf3)],
        voting='hard'
    )

    ensemble.fit(X_train, y_train)
    predictions = ensemble.predict(X_test)
    acc = accuracy_score(y_test, predictions)

    print("--- Voting Classifier Results ---")
    print(f"Ensemble Test Accuracy: {acc * 100:.2f}%")

if __name__ == '__main__':
    run_voting_ensemble()

```

#### The Verification

Execute the voting ensemble script:

```bash
python ensemble_stacking.py

```

You should see the test accuracy score printed for the combined ensemble model.

---

### Reference Section: Optimization Reference Guide

* **Grid Search Overhead:** As the number of hyperparameters and values grows, GridSearchCV scales exponentially ($O(N^k)$). Always pair grid searches with cross-validation splits carefully to prevent hardware lockups.
* **Custom Transformer Rules:** Any custom transformer inheriting from `BaseEstimator` and `TransformerMixin` must implement `fit()` (returning `self`) and `transform()` to be fully compatible with Scikit-Learn `Pipeline` objects.
