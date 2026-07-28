## Part 2: Supervised Learning – Regression & Classification

Welcome to Part 2. Now that you can ingest data, handle missing values, and construct robust pipelines, we step into **Supervised Learning**.

Supervised learning is analogous to teaching a student with flashcards that contain both the question and the correct answer. In this part we explore both **Regression** (predicting continuous numerical targets such as house prices) and **Classification** (predicting discrete categories such as spam vs. non-spam), while building solid evaluation practices along the way.

---

### Step 2.1: Linear & Logistic Regression with Regularization

#### The Target

Write a script (`supervised_regression.py`) that implements Linear Regression for continuous target prediction and Logistic Regression with L2 regularization for binary classification, then evaluates both models.

#### The Concept

* **Linear Regression** draws a straight line of best fit through data points. Imagine predicting a used car’s resale price from its mileage: every additional mile reduces the predicted price by a fixed amount (the learned coefficient).
* **Regularization (L2 / Ridge)** acts like a speed governor on a race car. It prevents coefficients from growing excessively large, which reduces the model’s tendency to memorize training noise (overfitting) and improves generalization to unseen data.
* **Logistic Regression** extends the same linear idea to classification by applying a sigmoid (logistic) function, producing probabilities between 0 and 1 that can be thresholded into class labels.

#### The Implementation

Create a file named `supervised_regression.py` with the following code:

```python
# supervised_regression.py
import numpy as np
from sklearn.datasets import make_regression, make_classification
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression, Ridge, LogisticRegression
from sklearn.metrics import mean_squared_error, accuracy_score, classification_report

def run_supervised_models():
    print("--- 1. Linear Regression & Ridge Regularization ---")
    # Synthetic regression data (continuous target)
    X_reg, y_reg = make_regression(
        n_samples=500, n_features=5, noise=0.1, random_state=42
    )
    X_reg_train, X_reg_test, y_reg_train, y_reg_test = train_test_split(
        X_reg, y_reg, test_size=0.2, random_state=42
    )

    # Ordinary Linear Regression
    lin_reg = LinearRegression()
    lin_reg.fit(X_reg_train, y_reg_train)
    lin_pred = lin_reg.predict(X_reg_test)
    lin_mse = mean_squared_error(y_reg_test, lin_pred)

    # Ridge Regression (L2 regularization)
    ridge_reg = Ridge(alpha=1.0)
    ridge_reg.fit(X_reg_train, y_reg_train)
    ridge_pred = ridge_reg.predict(X_reg_test)
    ridge_mse = mean_squared_error(y_reg_test, ridge_pred)

    print(f"Standard Linear Regression MSE: {lin_mse:.4f}")
    print(f"Ridge Regularized Regression MSE: {ridge_mse:.4f}")

    print("\n--- 2. Logistic Regression & Classification ---")
    # Synthetic classification data (binary target)
    X_clf, y_clf = make_classification(
        n_samples=500, n_features=4, n_classes=2, random_state=42
    )
    X_clf_train, X_clf_test, y_clf_train, y_clf_test = train_test_split(
        X_clf, y_clf, test_size=0.2, random_state=42
    )

    # Logistic Regression with L2 penalty
    log_reg = LogisticRegression(penalty='l2', C=1.0, random_state=42, max_iter=1000)
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

Execute the script:

```bash
python supervised_regression.py
```

You should see Mean Squared Error values for both regression models and a detailed classification report (precision, recall, F1-score) for the logistic regression model.

---

### Step 2.2: Tree-Based Models – Decision Trees, Random Forests & Gradient Boosting

#### The Target

Build and compare non-linear predictive power using a single Decision Tree, a Random Forest ensemble, and a Gradient Boosting classifier in a script named `tree_ensembles.py`.

#### The Concept

* A **Decision Tree** makes predictions by asking a series of hierarchical yes/no questions (e.g., “Is income > $50 k?” → “Is age < 30?”). While highly interpretable, a single tree is prone to overfitting.
* A **Random Forest** is like a panel of diverse experts. Hundreds of randomized trees vote, and the majority decision is taken. Individual tree errors tend to cancel out.
* **Gradient Boosting** works like a relay team: each new tree focuses on correcting the residual errors of the previous trees, progressively reducing overall error.

Ensemble methods almost always outperform single decision trees on tabular data.

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
    # Load a classic binary classification dataset
    data = load_breast_cancer()
    X, y = data.data, data.target

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

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
        print(f"{name:20s} Accuracy: {acc * 100:.2f}%")

if __name__ == '__main__':
    evaluate_trees()
```

#### The Verification

Run the script:

```bash
python tree_ensembles.py
```

You should see comparative accuracy percentages. In most runs the ensemble models (Random Forest and Gradient Boosting) outperform the single Decision Tree.

---

### Step 2.3: Rigorous Evaluation & Cross-Validation

#### The Target

Implement stratified k-fold cross-validation and obtain a statistically robust accuracy estimate in a script named `cross_validation.py`.

#### The Concept

Evaluating a model on a single random train/test split is risky — you may have been lucky (or unlucky) with the particular partition. **K-Fold Cross-Validation** is like giving a student five different midterms that cover different parts of the curriculum and then averaging the scores. Stratified k-fold additionally preserves the original class distribution in every fold, which is especially important for imbalanced classification problems.

#### The Implementation

Create a file named `cross_validation.py` with the following code:

```python
# cross_validation.py
from sklearn.datasets import load_breast_cancer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score, StratifiedKFold
import numpy as np

def run_cross_validation():
    data = load_breast_cancer()
    X, y = data.data, data.target

    model = RandomForestClassifier(n_estimators=100, random_state=42)

    # Stratified k-fold preserves class balance in each fold
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)

    cv_scores = cross_val_score(model, X, y, cv=cv, scoring='accuracy')

    print("--- Cross-Validation Results ---")
    print(f"Fold-by-fold Accuracies: {[f'{s*100:.2f}%' for s in cv_scores]}")
    print(f"Mean CV Accuracy: {cv_scores.mean() * 100:.2f}% "
          f"(± {cv_scores.std() * 2 * 100:.2f}%)")

if __name__ == '__main__':
    run_cross_validation()
```

#### The Verification

Execute the script:

```bash
python cross_validation.py
```

You should see the individual fold accuracies together with a mean accuracy and a simple confidence margin (approximately two standard deviations).

---

### Reference Section: Supervised Metrics Explained

* **Mean Squared Error (MSE)** — Average of the squared differences between predicted and true values. Heavily penalizes large errors; lower is better.
* **Accuracy** — Proportion of correct predictions. Can be misleading when classes are heavily imbalanced.
* **Precision** — Of all instances predicted as positive, what fraction were actually positive? (Focuses on minimizing false positives.)
* **Recall (Sensitivity)** — Of all actual positive instances, what fraction did the model find? (Focuses on minimizing false negatives.)
* **F1-Score** — Harmonic mean of precision and recall; useful when you need a single balanced metric.
* **ROC-AUC** — Area under the Receiver Operating Characteristic curve. Measures the trade-off between true-positive rate and false-positive rate across thresholds. An AUC of 1.0 is perfect; 0.5 is random guessing.

**Practical Tips**

* Prefer stratified splits and stratified cross-validation for classification tasks.
* Always examine the full classification report (precision / recall / F1) rather than relying solely on accuracy.
* When class imbalance is severe, consider alternative metrics such as average precision or balanced accuracy, and explore techniques such as class weighting or resampling.
