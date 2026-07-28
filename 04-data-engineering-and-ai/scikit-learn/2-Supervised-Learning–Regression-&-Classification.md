## Part 2: Supervised Learning – Regression & Classification

Welcome to Part 2. Now that you can ingest data, handle messy values, and construct robust pipelines, we will step into **Supervised Learning**.

Supervised learning is like teaching a child with flashcards that have both the question and the correct answer. In this part, we will explore both **Regression** (predicting continuous numerical targets, like house prices) and **Classification** (predicting categorical buckets, like spam vs. non-spam), building robust evaluation practices along the way.

---

### Step 2.1: Linear & Logistic Regression with Regularization

#### The Target

Write a script (`supervised_regression.py`) that implements Linear Regression for continuous target prediction and Logistic Regression with L2 regularization for binary classification, evaluating their coefficients.

#### The Concept

* **Linear Regression** tries to draw a straight line of best fit through data points. Think of it like predicting a used car's resale price based on its mileage: every additional mile drops the price by a fixed dollar amount (the coefficient).
* **Regularization (L2 / Ridge)** is like installing a speed governor on a race car. It prevents the model's coefficients from growing wildly large, stopping the model from memorizing the training noise (**overfitting**) and helping it generalize better to unseen data.

#### The Implementation

Create a file named `supervised_regression.py` with the following code:

```python
# supervised_regression.py
import numpy as np
import pandas as pd
from sklearn.datasets import make_regression, make_classification
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression, Ridge, LogisticRegression
from sklearn.metrics import mean_squared_error, accuracy_score, classification_report

def run_supervised_models():
    print("--- 1. Linear Regression & Ridge Regularization ---")
    # Generate synthetic regression data (Predicting continuous house prices)
    X_reg, y_reg = make_regression(n_samples=500, n_features=5, noise=0.1, random_state=42)
    X_reg_train, X_reg_test, y_reg_train, y_reg_test = train_test_split(X_reg, y_reg, test_size=0.2, random_state=42)

    # Standard Linear Regression
    lin_reg = LinearRegression()
    lin_reg.fit(X_reg_train, y_reg_train)
    lin_pred = lin_reg.predict(X_reg_test)
    lin_mse = mean_squared_error(y_reg_test, lin_pred)

    # Ridge Regression (L2 Regularization)
    ridge_reg = Ridge(alpha=1.0)
    ridge_reg.fit(X_reg_train, y_reg_train)
    ridge_pred = ridge_reg.predict(X_reg_test)
    ridge_mse = mean_squared_error(y_reg_test, ridge_pred)

    print(f"Standard Linear Regression MSE: {lin_mse:.4f}")
    print(f"Ridge Regularized Regression MSE: {ridge_mse:.4f}")

    print("\n--- 2. Logistic Regression & Classification ---")
    # Generate synthetic classification data (Predicting churn: 0 or 1)
    X_clf, y_clf = make_classification(n_samples=500, n_features=4, n_classes=2, random_state=42)
    X_clf_train, X_clf_test, y_clf_train, y_clf_test = train_test_split(X_clf, y_clf, test_size=0.2, random_state=42)

    # Logistic Regression with L2 penalty
    log_reg = LogisticRegression(penalty='l2', C=1.0, random_state=42)
    log_reg.fit(X_clf_train, y_clf_train)
    log_pred = log_reg.predict(X_clf_test)

    acc = accuracy_score(y_clf_test, log_pred)
    print(f"Logistic Regression Accuracy: {acc * 100:.2f}%")
    print("\nClassification Report:")
    print(classification_report(y_clf_test, log_pred))

if __name__ == '__main__':
    run_supervised_models()

```

#### The Verification

Execute the script in your terminal:

```bash
python supervised_regression.py

```

You should see evaluation metrics printed out, including the Mean Squared Error for both regression models and a detailed classification report (Precision, Recall, F1-Score) for the logistic regression model.

---

### Step 2.2: Tree-Based Models – Decision Trees, Random Forests, & Gradient Boosting

#### The Target

Build and compare non-linear predictive power using a single Decision Tree, a Random Forest ensemble, and a Gradient Boosting classifier in a script named `tree_ensembles.py`.

#### The Concept

* A **Decision Tree** makes predictions by asking a series of hierarchical yes/no questions (e.g., *Is income > $50k?* $\rightarrow$ *Is age < 30?*). While easy to visualize, a single tree is prone to snap judgments (**overfitting**).
* A **Random Forest** is like a corporate panel of experts. Instead of trusting one overly opinionated tree, it aggregates hundreds of randomized decision trees and takes a majority vote, neutralizing individual errors.
* **Gradient Boosting** is like a relay team where each runner focuses strictly on correcting the mistakes made by the previous runner, progressively shrinking error margins.

#### The Implementation

Create a file named `tree_ensembles.py` with the following code:

```python
# tree_ensembles.py
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import accuracy_score

def evaluate_trees():
    # Load a classic classification dataset
    data = load_breast_cancer()
    X, y = data.data, data.target

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Initialize models
    models = {
        "Decision Tree": DecisionTreeClassifier(random_state=42),
        "Random Forest": RandomForestClassifier(n_estimators=100, random_state=42),
        "Gradient Boosting": GradientBoostingClassifier(n_estimators=100, random_state=42)
    }

    print("--- Model Performance Comparison ---")
    for name, model in models.items():
        model.fit(X_train, y_train)
        predictions = model.predict(X_test)
        acc = accuracy_score(y_test, predictions)
        print(f"{name} Accuracy: {acc * 100:.2f}%")

if __name__ == '__main__':
    evaluate_trees()

```

#### The Verification

Run the script via your terminal:

```bash
python tree_ensembles.py

```

You should see comparative accuracy percentages for all three models, demonstrating how ensemble models generally outperform single decision trees.

---

### Step 2.3: Rigorous Evaluation & Cross-Validation

#### The Target

Implement k-fold cross-validation and compute advanced classification metrics (ROC-AUC) in a script named `cross_validation.py`.

#### The Concept

Evaluating a model on a single random train/test split is risky—you might have accidentally gotten an unusually easy or hard test batch. **K-Fold Cross-Validation** is like grading a student through five separate midterms covering different parts of the curriculum, then averaging their grades for a true measure of capability.

#### The Implementation

Create a file named `cross_validation.py` with the following code:

```python
# cross_validation.py
from sklearn.datasets import load_breast_cancer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score, StratifiedKFold
from sklearn.metrics import roc_auc_score, roc_curve
import numpy as np

def run_cross_validation():
    data = load_breast_cancer()
    X, y = data.data, data.target

    model = RandomForestClassifier(n_estimators=100, random_state=42)
    
    # Define stratified k-fold cross-validation to maintain class balance
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

    # Calculate cross-validated accuracy scores
    cv_scores = cross_val_score(model, X, y, cv=cv, scoring='accuracy')

    print("--- Cross-Validation Results ---")
    print(f"Fold-by-fold Accuracies: {[f'{score*100:.2f}%' for score in cv_scores]}")
    print(f"Mean Cross-Validation Accuracy: {cv_scores.mean() * 100:.2f}% (+/- {cv_scores.std() * 2 * 100:.2f}%)")

if __name__ == '__main__':
    run_cross_validation()

```

#### The Verification

Execute the cross-validation script:

```bash
python cross_validation.py

```

You should see individual fold accuracies alongside a statistically sound mean accuracy score and confidence margin.

---

### Reference Section: Supervised Metrics Explained

* **Mean Squared Error (MSE):** Measures the average squared difference between estimated values and actual value. Heavily penalizes large outlier errors.
* **Accuracy:** Total correct predictions divided by total predictions. Misleading when classes are heavily imbalanced.
* **Precision vs. Recall:**
* *Precision:* Out of all predicted positives, how many were actually positive? (Minimizes false positives).
* *Recall:* Out of all actual positives, how many did we find? (Minimizes false negatives).


* **ROC-AUC:** Evaluates the trade-off between true positive rate and false positive rate across classification thresholds. An AUC of 1.0 represents a perfect model; 0.5 represents random guessing.
