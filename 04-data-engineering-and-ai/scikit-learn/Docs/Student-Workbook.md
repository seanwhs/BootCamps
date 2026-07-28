# Scikit-Learn: Student Workbook & Master Execution Lab

Welcome to the ultimate **Student Workbook and Advanced Engineering Laboratory** for the *Scikit-Learn* series. This comprehensive companion manual transforms the core tutorial modules, theoretical primers, and architectural appendices into an active, hands-on master class in production machine learning engineering.

Designed for rigorous self-study, corporate training programs, or advanced academic implementation, this workbook contains five expanded modules covering every phase of the engineering lifecycle. Each module features exhaustive **Conceptual Checkpoints**, **Production Coding Labs**, **Debugging & Refactoring Challenges**, and **Architectural Review Questions**.

---

## Module 1: Foundations & The Scikit-Learn API

### Part A: Conceptual Checkpoints

1. **The Estimator Interface:** Explain the precise functional difference between `.fit()`, `.transform()`, and `.predict()`. Why does Scikit-Learn separate fitting from transformation?
* *Answer:* `.fit()` inspects raw data, computes empirical parameters (such as means, standard deviations, vocabulary mappings, or regression coefficients), and stores them as internal attributes (suffixed with a trailing underscore `_`). `.transform()` applies these learned parameters to modify or project the input dataset into a new representation. `.predict()` uses fitted parameters to generate discrete class labels or continuous targets. Separating fitting from transformation is critical to prevent data leakage and ensure that test sets are transformed strictly using parameters learned from training folds.




2. **Data Leakage:** Define data leakage in your own words. Why does computing a dataset-wide `StandardScaler` mean before splitting into train and test sets invalidate your evaluation metrics?
* *Answer:* Data leakage occurs when information from outside the training data set is improperly used to create a model, leading to overly optimistic performance during evaluation. Computing a dataset-wide `StandardScaler` calculates the mean and variance across the *entire* dataset (including the test set). Consequently, the test set's statistical properties bleed into the training data, invalidating the independence of your test evaluation.




3. **Pipelines:** How does encapsulating preprocessing steps inside a Scikit-Learn `Pipeline` prevent data leakage during cross-validation?
* *Answer:* A Scikit-Learn `Pipeline` ensures that preprocessing steps (like imputation, scaling, or encoding) are executed dynamically within each individual cross-validation fold or train/test split. The transformer's `.fit()` method is called strictly on the training subset of that fold, completely shielding validation and test subsets from structural leakage.



---

### Part B: Hands-On Coding Lab – Building a Leak-Free Pipeline

**Exercise:** Write a self-contained Python script named `lab_module1.py` that implements a complete, leak-free preprocessing and classification pipeline.

```python
# lab_module1.py
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

---

### Part C: Debugging Challenge

**Scenario:** A junior developer writes the following preprocessing snippet:

```python
scaler = StandardScaler()
X_scaled = scaler.fit_transform(df[['age', 'income']])
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)

```

* **Flaw Identification:** This code suffers from severe data leakage. By calling `fit_transform` on the entire dataframe before splitting, the scaler incorporates the mean and variance of the test split into the training scaling parameters.


* **Corrected Implementation:**
```python
X_train, X_test, y_train, y_test = train_test_split(df[['age', 'income']], y, test_size=0.2, random_state=42)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

```



---

### Part D: Architectural Review Questions

* Why must categorical one-hot encoders be configured with `handle_unknown='ignore'` when building robust production pipelines?
* *Answer:* Production environments are dynamic. If an incoming inference request introduces a categorical label that was never present during historical training (e.g., a new region code), default encoders throw a `ValueError`. Configuring `handle_unknown='ignore'` maps unknown categories to all-zero indicator columns, preventing application crashes.





---

## Module 2: Supervised Learning – Regression & Classification

### Part A: Conceptual Checkpoints

1. **Bias vs. Variance:** What happens to model bias and model variance when you increase the depth of a Decision Tree to maximum capacity?
* *Answer:* Increasing tree depth to maximum capacity drastically reduces training bias (the tree can perfectly memorize complex decision boundaries) but massively increases variance. The model becomes hypersensitive to noise in the training set, resulting in severe overfitting and poor generalization on unseen test data.


2. **Regularization:** How does L2 regularization (Ridge) prevent coefficient explosion in linear models?
* *Answer:* L2 regularization adds a penalty proportional to the sum of the squared coefficients ($\lambda \sum \beta_j^2$) to the loss function. This penalizes excessively large coefficients, forcing the optimization algorithm to distribute weights more evenly across correlated features and preventing numerical instability.


3. **Evaluation Metrics:** When should you prioritize Recall over Precision, and vice-versa? Give real-world examples for each.
* *Answer:* Prioritize **Recall** when false negatives are catastrophic, such as in cancer detection or airport security screening, where missing a positive case carries severe consequences. Prioritize **Precision** when false positives are costly, such as in financial spam filtering or legal e-discovery, where misclassifying a legitimate item as positive causes significant disruption.



---

### Part B: Hands-On Coding Lab – Comparative Supervised Modeling

**Exercise:** Write a Python script (`lab_module2.py`) that loads the breast cancer dataset and compares Logistic Regression, Random Forest, and Gradient Boosting models.

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

---

### Part C: Debugging Challenge

* Your classification model achieves 99.2% accuracy on an imbalanced fraud dataset (99.2% legitimate transactions). Explain why accuracy fails here, and specify which metrics to inspect.


* *Answer:* A naive baseline model that blindly predicts "Legitimate" 100% of the time achieves 99.2% accuracy while catching zero fraudulent transactions. Accuracy is completely uninformative under severe class imbalance. You must inspect **Precision, Recall, F1-Score, and ROC-AUC** to measure true predictive power across minority classes.





---

### Part D: Architectural Review Questions

* Why is Stratified K-Fold Cross-Validation preferred over standard K-Fold cross-validation when evaluating classification models on skewed datasets?
* *Answer:* Standard K-Fold randomly partitions data without regard to target label distributions, which can result in training folds that completely miss minority class instances. Stratified K-Fold guarantees that each fold maintains the exact same percentage of target classes as the complete dataset, ensuring robust and unbiased evaluation.



---

## Module 3: Unsupervised Learning & Dimensionality Reduction

### Part A: Conceptual Checkpoints

1. **Clustering Assumptions:** What structural shape does K-Means assume data clusters possess? When does K-Means fail?
* *Answer:* K-Means assumes spherical, isotropic, and equally sized clusters. It fails catastrophically when data exhibits non-linear geometries, complex interlocking shapes, or widely varying cluster densities and variances.


2. **DBSCAN vs. K-Means:** How does DBSCAN handle noise and outliers compared to K-Means? Why is specifying $K$ not required in DBSCAN?
* *Answer:* DBSCAN explicitly designates low-density data points as noise (labeled as `-1`), whereas K-Means forces every point into one of $K$ centroids. DBSCAN does not require $K$ because it groups points based on core sample density connectivity (`eps` distance and `min_samples`), discovering clusters of arbitrary shapes organically.


3. **PCA Variance:** What does "explained variance ratio" represent when performing Principal Component Analysis?
* *Answer:* It represents the proportion of total variance accounted for by each orthogonal principal component, allowing engineers to determine how many dimensions to retain while preserving maximum information.



---

### Part B: Hands-On Coding Lab – Dimensionality Reduction & Anomaly Detection

**Exercise:** Write a script (`lab_module3.py`) that applies PCA compression and Isolation Forest anomaly detection.

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

    pca = PCA(n_components=2)
    X_reduced = pca.fit_transform(X)
    print(f"PCA Reduced Shape: {X_reduced.shape}")
    print(f"Explained Variance: {sum(pca.explained_variance_ratio_)*100:.2f}%")

    iso = IsolationForest(contamination=0.03, random_state=42)
    preds = iso.fit_predict(X)
    print(f"Outliers Flagged: {list(preds).count(-1)}")

if __name__ == '__main__':
    run_lab()

```

---

### Part C: Debugging Challenge

* You run K-Means with $K=5$ on unscaled features (Feature A ranges 0–1; Feature B ranges 0–1,000,000) and obtain poor silhouette scores. Explain the distortion and provide the fix.
* *Answer:* Distance-based algorithms like K-Means are dominated by features with larger numerical magnitudes. Feature B completely overwhelms Feature A in Euclidean distance calculations. **Fix:** Scale all features using `StandardScaler` or `MinMaxScaler` within a preprocessing pipeline before clustering.



---

### Part D: Architectural Review Questions

* Why is dimensionality reduction via PCA often placed as a preprocessing step inside a machine learning pipeline before feeding continuous features into regression models?
* *Answer:* PCA removes multicollinearity by projecting correlated features onto orthogonal axes, reduces computational overhead, and mitigates overfitting in high-dimensional regression tasks.



---

## Module 4: Advanced Tuning & Model Optimization

### Part A: Conceptual Checkpoints

1. **Hyperparameter Search:** Contrast `GridSearchCV` and `RandomizedSearchCV`. When would you choose one over the other?
* *Answer:* `GridSearchCV` performs an exhaustive search over every specified parameter combination, which is ideal for small search spaces. `RandomizedSearchCV` samples a fixed number of random parameter combinations from specified distributions, making it vastly more efficient for large, continuous, or high-dimensional hyperparameter spaces.


2. **Custom Transformers:** What two core methods must every custom Scikit-Learn transformer implement to remain fully compatible with `Pipeline` objects?
* *Answer:* `.fit(X, y=None)` and `.transform(X)` (alongside inheriting from `BaseEstimator` and `TransformerMixin`).


3. **Ensemble Voting:** Explain the difference between "hard voting" and "soft voting" in a Voting Classifier.
* *Answer:* Hard voting aggregates predicted class labels via majority rule. Soft voting averages the predicted class probabilities across all base estimators and selects the class with the highest average probability.



---

### Part B: Hands-On Coding Lab – Custom Transformer & Grid Search

**Exercise:** Write a script (`lab_module4.py`) that implements a custom debt-ratio transformer and runs a randomized hyperparameter search.

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

---

### Part C: Debugging Challenge

* Passing `param_grid = {'n_estimators': [50, 100]}` to a pipeline raises a `ValueError` because the estimator is inside a step named `'model'`. How must dictionary keys be formatted?
* *Answer:* Dictionary keys must use double-underscore syntax prefixed by the pipeline step name: `param_grid = {'model__n_estimators': [50, 100]}`.



---

### Part D: Architectural Review Questions

* Why does stacking heterogeneous models often yield higher generalization performance than any single model alone?
* *Answer:* Different algorithms possess distinct inductive biases. Stacking leverages complementary strengths, allowing a meta-model to correct individual base model errors and capture complex patterns that single architectures miss.



---

## Module 5: Production, Serialization, & MLOps

### Part A: Conceptual Checkpoints

1. **Serialization:** Why is `joblib` preferred over Python's native `pickle` module when serializing Scikit-Learn models containing large NumPy arrays?
* *Answer:* `joblib` is specifically optimized to serialize Python objects carrying large NumPy arrays (common in Scikit-Learn estimators) with significantly higher speed and disk-space efficiency.


2. **Training vs. Inference:** Why is dynamic model retraining inside an online web server request cycle considered an architectural anti-pattern?
* *Answer:* It introduces unpredictable, multi-second latency spikes, risks thread safety, and bypasses offline evaluation governance, risking severe production regressions.


3. **Data Drift:** Define data drift. Why does a model experience accuracy degradation over time even when its code remains completely unchanged?
* *Answer:* Data drift is the silent shift in production input data distributions relative to historical training distributions over time, causing learned decision boundaries to become obsolete.





---

### Part B: Hands-On Coding Lab – Persistence & Inference Wrapper

**Exercise:** Write a script (`lab_module5.py`) that serializes a trained pipeline and simulates an inference server.

```python
# lab_module5.py
import joblib
import pandas as pd
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

def serialize_and_deploy():
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

    loaded_pipeline = joblib.load(artifact_name)
    incoming_payload = pd.DataFrame({'age': [30, 50], 'income': [65000, 135000]})
    
    preds = loaded_pipeline.predict(incoming_payload)
    print("--- Production Inference Results ---")
    for i, row in incoming_payload.iterrows():
        print(f"Record {i+1} (Age: {row['age']}, Income: ${row['income']}) -> Prediction: {preds[i]}")

if __name__ == '__main__':
    serialize_and_deploy()

```

---

### Part C: Debugging Challenge

* An inference server receives uppercase keys `{'Age': 32, 'Income': 72000}`, but training data used lowercase (`'age'`, `'income'`). How do you bulletproof your wrapper?
* *Answer:* Normalize incoming payload column names to lowercase at the API boundary before passing them to the pipeline: `payload.columns = [c.lower() for c in payload.columns]`.



---

### Part D: Architectural Review Questions

* What is the role of an API validation framework (like Pydantic) when placed upstream of a Scikit-Learn inference pipeline in a production web application?
* *Answer:* Pydantic enforces strict type checking, range validation, and schema compliance at the network boundary, rejecting malformed or out-of-bounds payloads *before* they can trigger unhandled exceptions in the downstream machine learning pipeline.
