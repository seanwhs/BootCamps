## Part 4: Advanced Tuning & Model Optimization

Welcome to Part 4. By now you can build end-to-end pipelines, train supervised models, and discover structure in unlabeled data. Default model hyperparameters, however, are rarely optimal for production performance.

In this part we move beyond defaults to extract maximum predictive power through systematic hyperparameter search, custom transformers, and model ensembles.

---

### Step 4.1: Hyperparameter Tuning – GridSearchCV vs. RandomizedSearchCV

#### The Target

Write a script (`hyperparameter_tuning.py`) that uses both `GridSearchCV` and `RandomizedSearchCV` to discover strong hyperparameter configurations for a Random Forest classifier.

#### The Concept

Hyperparameters are the settings you choose *before* training begins (maximum tree depth, number of trees, minimum samples required to split a node, etc.).

* **GridSearchCV** evaluates every combination in a predefined grid. It is exhaustive and guarantees that the best combination inside the grid will be found, but the computational cost grows exponentially with the number of parameters and candidate values.
* **RandomizedSearchCV** samples a fixed number of random combinations from (possibly continuous) distributions. It usually finds a near-optimal configuration in a fraction of the time and scales far more gracefully.

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
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    rf = RandomForestClassifier(random_state=42)

    # 1. GridSearchCV – exhaustive search over a small grid
    param_grid = {
        'n_estimators': [50, 100],
        'max_depth': [None, 10, 20],
        'min_samples_split': [2, 5]
    }

    print("--- Running GridSearchCV ---")
    grid_search = GridSearchCV(
        estimator=rf,
        param_grid=param_grid,
        cv=3,
        scoring='accuracy',
        n_jobs=-1,
        verbose=0
    )
    grid_search.fit(X_train, y_train)

    print(f"Best Grid Parameters: {grid_search.best_params_}")
    print(f"Best Grid CV Accuracy: {grid_search.best_score_ * 100:.2f}%")

    # 2. RandomizedSearchCV – stochastic sampling
    param_dist = {
        'n_estimators': randint(50, 200),
        'max_depth': [None, 10, 20, 30],
        'min_samples_split': randint(2, 10)
    }

    print("\n--- Running RandomizedSearchCV ---")
    random_search = RandomizedSearchCV(
        estimator=rf,
        param_distributions=param_dist,
        n_iter=10,
        cv=3,
        scoring='accuracy',
        random_state=42,
        n_jobs=-1,
        verbose=0
    )
    random_search.fit(X_train, y_train)

    print(f"Best Random Parameters: {random_search.best_params_}")
    print(f"Best Random CV Accuracy: {random_search.best_score_ * 100:.2f}%")

if __name__ == '__main__':
    run_tuning()
```

#### The Verification

Execute the hyperparameter-tuning script:

```bash
python hyperparameter_tuning.py
```

You should see the best parameter combinations and cross-validation accuracy scores for both search strategies.

---

### Step 4.2: Writing Custom Scikit-Learn Transformers

#### The Target

Create a custom Scikit-Learn-compatible transformer (`custom_transformer.py`) that engineers a domain-specific feature (income per age) while remaining fully compatible with pipelines.

#### The Concept

Built-in scalers and encoders are often insufficient for business-specific logic (debt-to-income ratios, text length features, interaction terms, etc.). Scikit-Learn lets you write custom transformers that implement the familiar `.fit()` / `.transform()` interface. When these transformers inherit from `BaseEstimator` and `TransformerMixin`, they integrate seamlessly into `Pipeline` and `ColumnTransformer` objects.

#### The Implementation

Create a file named `custom_transformer.py` with the following code:

```python
# custom_transformer.py
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin

class IncomePerAgeTransformer(BaseEstimator, TransformerMixin):
    """Stateless transformer that creates an income / age ratio feature."""

    def fit(self, X, y=None):
        # Nothing to learn; simply return self for pipeline compatibility
        return self

    def transform(self, X):
        # Work on a copy to avoid SettingWithCopy warnings
        X_ = X.copy()
        X_['income_per_age'] = X_['income'] / X_['age']
        return X_

def run_custom_transformer():
    data = pd.DataFrame({
        'age': [25, 40, 55],
        'income': [40000, 90000, 130000]
    })

    transformer = IncomePerAgeTransformer()
    transformed = transformer.transform(data)

    print("--- Custom Transformer Output ---")
    print(transformed)

if __name__ == '__main__':
    run_custom_transformer()
```

#### The Verification

Run the custom-transformer script:

```bash
python custom_transformer.py
```

You should see the original DataFrame with a new `income_per_age` column correctly calculated.

---

### Step 4.3: Ensemble Methods – Voting Classifiers

#### The Target

Build an ensemble script (`ensemble_stacking.py`) that combines Logistic Regression, a Decision Tree, and a Random Forest using a hard-voting classifier.

#### The Concept

A single model can have blind spots. A **Voting Classifier** aggregates the predictions of several heterogeneous models and decides by majority vote (hard voting) or by averaging predicted probabilities (soft voting). The diversity of the base learners is the key source of the ensemble’s strength.

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
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # Diverse base estimators
    clf1 = LogisticRegression(max_iter=1000, random_state=42)
    clf2 = DecisionTreeClassifier(random_state=42)
    clf3 = RandomForestClassifier(n_estimators=100, random_state=42)

    # Hard-voting ensemble (majority rule)
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

Execute the ensemble script:

```bash
python ensemble_stacking.py
```

You should see the test accuracy of the combined voting model.

---

### Reference Section: Optimization Guidance

* **Grid Search Cost** — Computational complexity grows as \(O(N^k)\) where \(k\) is the number of hyperparameters. Keep grids modest or prefer randomized search for larger spaces.
* **Custom Transformer Contract** — Any transformer intended for use inside a `Pipeline` must:
  * inherit from `BaseEstimator` and `TransformerMixin`,
  * implement `fit(self, X, y=None)` that returns `self`,
  * implement `transform(self, X)` that returns the transformed data,
  * avoid modifying the input `X` in place (work on a copy).
* **Ensemble Diversity** — The biggest gains come from combining models that make different kinds of errors (linear vs. tree-based, bagging vs. boosting, etc.).
* **Practical Workflow** — Start with a simple baseline, then apply randomized search (or Bayesian optimization) on the most promising model family, and finally consider a voting or stacking ensemble of the top candidates.
