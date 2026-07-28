# Scikit-Learn: Student Workbook

Welcome to the **Student Workbook** for the *Scikit-Learn* series. This companion workbook transforms the core tutorial modules, primers, and appendices into an active, hands-on learning lab.

Designed for structured self-study or classroom implementation, this workbook contains five detailed modules corresponding to the series phases. Each module features **Conceptual Checkpoints**, **Coding Labs & Practical Exercises**, **Debugging & Refactoring Challenges**, and **Architectural Review Questions**.

---

## Module 1: Foundations & The Scikit-Learn API

### Part A: Conceptual Checkpoints

1. **The Estimator Interface:** Explain the precise functional difference between `.fit()`, `.transform()`, and `.predict()`. Why does Scikit-Learn separate fitting from transformation?
2. **Data Leakage:** Define data leakage in your own words. Why does computing a dataset-wide `StandardScaler` mean before splitting into train and test sets invalidate your evaluation metrics?
3. **Pipelines:** How does encapsulating preprocessing steps inside a Scikit-Learn `Pipeline` prevent data leakage during cross-validation?

### Part B: Hands-On Coding Lab – Building a Leak-Free Pipeline

**Exercise:** Write a self-contained Python script named `lab_module1.py` that fulfills the following requirements:

* Generates a synthetic DataFrame with 200 rows containing numerical features (`age`, `income`), a categorical feature (`region` with values `North`, `South`, `East`, `West`, and some `NaN` values), and a binary target (`purchased`: `0` or `1`).
* Injects missing values randomly into 10% of the numerical and categorical columns.
* Splits the data into an 80/20 train/test split using a fixed random state.
* Builds a `ColumnTransformer` that handles numerical imputation/scaling and categorical imputation/one-hot encoding.
* Combines the preprocessor and a `LogisticRegression` model into a single `Pipeline`.
* Fits the pipeline on the training set, predicts on the test set, and prints out the classification report.

```python
# lab_module1.py (Starter Template / Solution Reference)
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report

def run_lab():
    np.random.seed(42)
    n = 200
    df = pd.DataFrame({
        'age': np.random.randint(18, 70, size=n),
        'income': np.random.choice([30000, 60000, 90000, np.nan], size=n),
        'region': np.random.choice(['North', 'South', 'East', 'West', None], size=n),
        'purchased': np.random.choice([0, 1], size=n)
    })

    X = df.drop(columns=['purchased'])
    y = df['purchased']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    numeric_features = ['age', 'income']
    categorical_features = ['region']

    numeric_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler())
    ])

    categorical_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='constant', fill_value='Missing')),
        ('onehot', OneHotEncoder(handle_unknown='ignore'))
    ])

    preprocessor = ColumnTransformer(
        transformers=[
            ('num', numeric_transformer, numeric_features),
            ('cat', categorical_transformer, categorical_features)
        ]
    )

    pipeline = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('classifier', LogisticRegression(random_state=42))
    ])

    pipeline.fit(X_train, y_train)
    preds = pipeline.predict(X_test)

    print("--- Module 1 Lab Classification Report ---")
    print(classification_report(y_test, preds))

if __name__ == '__main__':
    run_lab()

```

### Part C: Debugging Challenge

**Scenario:** A junior developer writes the following preprocessing snippet:

```python
scaler = StandardScaler()
X_scaled = scaler.fit_transform(df[['age', 'income']])
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)

```

* **Question:** Identify the structural flaw in this code snippet. What exception or silent statistical failure will occur? Rewrite it correctly.

### Part D: Architectural Review Questions

* Why must categorical one-hot encoders be configured with `handle_unknown='ignore'` when building robust production pipelines?

---

## Module 2: Supervised Learning – Regression & Classification

### Part A: Conceptual Checkpoints

1. **Bias vs. Variance:** What happens to model bias and model variance when you increase the depth of a Decision Tree to maximum capacity?
2. **Regularization:** How does L2 regularization (Ridge) prevent coefficient explosion in linear models?
3. **Evaluation Metrics:** When should you prioritize Recall over Precision, and vice-versa? Give real-world examples for each.

### Part B: Hands-On Coding Lab – Comparative Supervised Modeling

**Exercise:** Write a Python script (`lab_module2.py`) that loads the built-in breast cancer dataset, splits it into train/test sets, and trains three separate models: Logistic Regression, Random Forest, and Gradient Boosting. Compute and print their respective accuracy scores and ROC-AUC metrics.

```python
# lab_module2.py
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import accuracy_score, roc_auc_score

def run_lab():
    data = load_breast_cancer()
    X, y = data.data, data.target
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    models = {
        "Logistic Regression": LogisticRegression(max_iter=5000, random_state=42),
        "Random Forest": RandomForestClassifier(n_estimators=100, random_state=42),
        "Gradient Boosting": GradientBoostingClassifier(n_estimators=100, random_state=42)
    }

    print("--- Module 2 Model Comparison ---")
    for name, model in models.items():
        model.fit(X_train, y_train)
        preds = model.predict(X_test)
        probs = model.predict_proba(X_test)[:, 1]
        
        acc = accuracy_score(y_test, preds)
        auc = roc_auc_score(y_test, probs)
        print(f"{name} -> Accuracy: {acc*100:.2f}% | ROC-AUC: {auc:.4f}")

if __name__ == '__main__':
    run_lab()

```

### Part C: Debugging Challenge

* Your classification model achieves 99.2% accuracy on an imbalanced fraud detection dataset (where 99.2% of transactions are legitimate). Your manager celebrates, but you remain suspicious. Explain why accuracy is failing here, and specify which two metrics you should inspect instead.

### Part D: Architectural Review Questions

* Why is Stratified K-Fold Cross-Validation preferred over standard K-Fold cross-validation when evaluating classification models on skewed datasets?

---

## Module 3: Unsupervised Learning & Dimensionality Reduction

### Part A: Conceptual Checkpoints

1. **Clustering Assumptions:** What structural shape does K-Means assume data clusters possess? When does K-Means fail?
2. **DBSCAN vs. K-Means:** How does DBSCAN handle noise and outliers compared to K-Means? Why is specifying $K$ not required in DBSCAN?
3. **PCA Variance:** What does "explained variance ratio" represent when performing Principal Component Analysis?

### Part B: Hands-On Coding Lab – Dimensionality Reduction & Anomaly Detection

**Exercise:** Write a script (`lab_module3.py`) that generates synthetic data with outliers, applies PCA to reduce dimensions to 2 components, and uses an Isolation Forest to flag anomalies.

```python
# lab_module3.py
import numpy as np
from sklearn.datasets import make_blobs
from sklearn.decomposition import PCA
from sklearn.ensemble import IsolationForest

def run_lab():
    np.random.seed(42)
    X_normal, _ = make_blobs(n_samples=300, centers=2, cluster_std=0.8, random_state=42)
    X_outliers = np.random.uniform(low=-6.0, high=6.0, size=(10, 2))
    X = np.vstack([X_normal, X_outliers])

    # PCA Compression
    pca = PCA(n_components=2)
    X_reduced = pca.fit_transform(X)
    print(f"PCA Reduced Shape: {X_reduced.shape}")
    print(f"Explained Variance: {sum(pca.explained_variance_ratio_)*100:.2f}%")

    # Anomaly Detection
    iso = IsolationForest(contamination=0.03, random_state=42)
    preds = iso.fit_predict(X)
    print(f"Outliers Flagged: {list(preds).count(-1)}")

if __name__ == '__main__':
    run_lab()

```

### Part C: Debugging Challenge

* You run K-Means clustering with $K=5$ on a dataset where silhouette scores indicate poor cluster separation. You notice that features have vastly different scales (e.g., feature A ranges from 0 to 1, while feature B ranges from 0 to 1,000,000). How do differing feature scales distort distance-based clustering algorithms like K-Means? How do you fix it?

### Part D: Architectural Review Questions

* Why is dimensionality reduction via PCA often placed as a preprocessing step inside a machine learning pipeline before feeding continuous features into regression models?

---

## Module 4: Advanced Tuning & Model Optimization

### Part A: Conceptual Checkpoints

1. **Hyperparameter Search:** Contrast `GridSearchCV` and `RandomizedSearchCV`. When would you choose one over the other?
2. **Custom Transformers:** What two core methods must every custom Scikit-Learn transformer implement to remain fully compatible with `Pipeline` objects?
3. **Ensemble Voting:** Explain the difference between "hard voting" and "soft voting" in a Voting Classifier.

### Part B: Hands-On Coding Lab – Custom Transformer & Grid Search

**Exercise:** Write a script (`lab_module4.py`) that implements a custom transformer calculating a financial debt ratio, wraps it in a pipeline alongside a Random Forest, and executes a randomized hyperparameter search.

```python
# lab_module4.py
import pandas as pd
import numpy as np
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import RandomizedSearchCV, train_test_split
from scipy.stats import randint

class DebtRatioTransformer(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        return self
    def transform(self, X):
        X_ = X.copy()
        X_['debt_ratio'] = X_['debt'] / (X_['income'] + 1)
        return X_

def run_lab():
    np.random.seed(42)
    n = 300
    df = pd.DataFrame({
        'age': np.random.randint(20, 65, size=n),
        'income': np.random.randint(30000, 150000, size=n),
        'debt': np.random.randint(5000, 50000, size=n),
        'default': np.random.choice([0, 1], size=n)
    })

    X = df.drop(columns=['default'])
    y = df['default']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    pipeline = Pipeline([
        ('engineer', DebtRatioTransformer()),
        ('model', RandomForestClassifier(random_state=42))
    ])

    param_dist = {
        'model__n_estimators': randint(50, 150),
        'model__max_depth': [None, 5, 10, 20]
    }

    search = RandomizedSearchCV(pipeline, param_distributions=param_dist, n_iter=3, cv=3, random_state=42)
    search.fit(X_train, y_train)

    print(f"Best Hyperparameters: {search.best_params_}")
    print(f"Best CV Score: {search.best_score_*100:.2f}%")

if __name__ == '__main__':
    run_lab()

```

### Part C: Debugging Challenge

* When defining hyperparameters for a pipeline inside a `GridSearchCV`, a developer passes `param_grid = {'n_estimators': [50, 100]}` but encounters a `ValueError: Invalid parameter` because the estimator is nested inside a pipeline step named `'model'`. How must dictionary keys be formatted when tuning estimators within a named pipeline?

### Part D: Architectural Review Questions

* Why does stacking heterogeneous models (e.g., Logistic Regression + Random Forest + Gradient Boosting) often yield higher generalization performance than any single model alone?

---

## Module 5: Production, Serialization, & MLOps

### Part A: Conceptual Checkpoints

1. **Serialization:** Why is `joblib` preferred over Python's native `pickle` module when serializing Scikit-Learn models containing large NumPy arrays?
2. **Training vs. Inference:** Why is dynamic model retraining inside an online web server request cycle considered an architectural anti-pattern?
3. **Data Drift:** Define data drift. Why does a model experience accuracy degradation over time even when its code remains completely unchanged?

### Part B: Hands-On Coding Lab – Persistence & Inference Wrapper

**Exercise:** Write a script (`lab_module5.py`) that trains a pipeline, serializes it to disk via `joblib`, reloads it in a separate function simulating an inference server, and evaluates an incoming payload.

```python
# lab_module5.py
import joblib
import pandas as pd
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

def serialize_and_deploy():
    # 1. Training Phase
    X_train = pd.DataFrame({'age': [25, 35, 45, 55], 'income': [40000, 80000, 120000, 160000]})
    y_train = [0, 0, 1, 1]

    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('model', LogisticRegression())
    ])
    pipeline.fit(X_train, y_train)

    artifact_name = 'prod_model.joblib'
    joblib.dump(pipeline, artifact_name)
    print(f"[INFO] Model serialized to {artifact_name}")

    # 2. Inference Server Simulation Phase
    loaded_pipeline = joblib.load(artifact_name)
    incoming_payload = pd.DataFrame({'age': [30, 50], 'income': [65000, 135000]})
    
    preds = loaded_pipeline.predict(incoming_payload)
    print("--- Production Inference Results ---")
    for i, row in incoming_payload.iterrows():
        print(f"Record {i+1} (Age: {row['age']}, Income: ${row['income']}) -> Prediction: {preds[i]}")

if __name__ == '__main__':
    serialize_and_deploy()

```

### Part C: Debugging Challenge

* An inference server receives an incoming JSON request with keys `{'Age': 32, 'Income': 72000}` (capitalized keys), but throws a feature name mismatch error because the training dataframe used lowercase column names (`'age'`, `'income'`). How do you bulletproof your production inference wrapper against casing and schema discrepancies?

### Part D: Architectural Review Questions

* What is the role of an API validation framework (like Pydantic) when placed upstream of a Scikit-Learn inference pipeline in a production web application?
