# Advanced Scikit-Learn Exercises & Engineering Lab

---

## Module 1: Foundations & The Scikit-Learn API

### Advanced Exercise 1.2: Custom Estimator API Compliance & Meta-Estimator Inspection

* **Objective:** Build a fully compliant custom Scikit-Learn estimator adhering to duck-typing requirements, implementing `get_params()` and `set_params()`, and integrating seamlessly inside standard pipelines.
* **Task:** Implement a custom outlier-capping transformer `Winsorizer` that learns quantile thresholds during `.fit()` and clips extreme values during `.transform()`. Validate its API compliance using `check_estimator`.

#### Solution 1.2

```python
import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.utils.validation import check_is_fitted
from sklearn.pipeline import Pipeline
from sklearn.linear_model import Ridge

class Winsorizer(BaseEstimator, TransformerMixin):
    def __init__(self, lower_quantile=0.01, upper_quantile=0.99):
        self.lower_quantile = lower_quantile
        self.upper_quantile = upper_quantile

    def fit(self, X, y=None):
        X_arr = np.asarray(X, dtype=float)
        self.lower_bounds_ = np.quantile(X_arr, self.lower_quantile, axis=0)
        self.upper_bounds_ = np.quantile(X_arr, self.upper_quantile, axis=0)
        self.n_features_in_ = X_arr.shape[1]
        return self

    def transform(self, X):
        check_is_fitted(self, attributes=['lower_bounds_', 'upper_bounds_'])
        X_arr = np.asarray(X, dtype=float)
        if X_arr.shape[1] != self.n_features_in_:
            raise ValueError(f"Feature count mismatch: expected {self.n_features_in_}, got {X_arr.shape[1]}")
        return np.clip(X_arr, self.lower_bounds_, self.upper_bounds_)

def run_advanced_exercise_1_2():
    np.random.seed(42)
    X = np.random.normal(loc=0.0, scale=1.0, size=(200, 3))
    # Inject extreme outliers
    X[0, 0] = 50.0
    X[1, 1] = -75.0
    y = X[:, 0] * 2 + X[:, 1] * 1.5 + np.random.normal(0, 0.1, size=200)

    pipeline = Pipeline([
        ('winsorizer', Winsorizer(lower_quantile=0.02, upper_quantile=0.98)),
        ('regressor', Ridge())
    ])

    pipeline.fit(X, y)
    reg = pipeline.named_steps['regressor']
    
    print("--- Custom Estimator Pipeline Execution ---")
    print(f"Fitted Successfully! Number of Features In: {pipeline.named_steps['winsorizer'].n_features_in_}")
    print(f"Learned Coefficients (.coef_): {reg.coef_}")
    print(f"Learned Intercept (.intercept_): {reg.intercept_:.4f}")

if __name__ == '__main__':
    run_advanced_exercise_1_2()

```

---

## Module 2: Data Preprocessing & Feature Engineering

### Advanced Exercise 2.2: Ordinal Frequency Encoding & Custom DateTime Decomposition Transformer

* **Objective:** Design an enterprise-grade feature engineering pipeline that handles cyclical temporal variables (extracting sine/cosine encodings from timestamps) and robust frequency-based categorical mapping without data leakage.
* **Task:** Write a custom timestamp transformer that expands date strings into cyclical components (`month_sin`, `month_cos`, `day_of_week_sin`, `day_of_week_cos`), and integrate it alongside numeric scalers via a `ColumnTransformer`.

#### Solution 2.2

```python
import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.utils.validation import check_is_fitted
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import GradientBoostingRegressor

class CyclicalDateTimeTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, date_column):
        self.date_column = date_column

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        X_ = X.copy()
        dt = pd.to_datetime(X_[self.date_column])
        
        # Month cyclical encoding (1-12)
        month = dt.dt.month.astype(float)
        X_['month_sin'] = np.sin(2 * np.pi * month / 12.0)
        X_['month_cos'] = np.cos(2 * np.pi * month / 12.0)
        
        # Day of week cyclical encoding (0-6)
        dow = dt.dt.dayofweek.astype(float)
        X_['dow_sin'] = np.sin(2 * np.pi * dow / 7.0)
        X_['dow_cos'] = np.cos(2 * np.pi * dow / 7.0)
        
        return X_.drop(columns=[self.date_column])

def run_advanced_exercise_2_2():
    np.random.seed(42)
    n = 300
    
    dates = pd.date_range(start='2025-01-01', periods=n, freq='D')
    df = pd.DataFrame({
        'transaction_date': np.random.choice(dates, size=n),
        'transaction_amount': np.random.exponential(scale=150, size=n),
        'customer_age': np.random.randint(18, 75, size=n)
    })
    
    # Target value influenced by month seasonality
    y = df['transaction_amount'] * 1.2 + np.sin(2 * np.pi * df['transaction_date'].dt.month / 12.0) * 50 + np.random.normal(0, 5, size=n)
    X = df.drop(columns=[])

    preprocessor = ColumnTransformer([
        ('time_features', CyclicalDateTimeTransformer(date_column='transaction_date'), ['transaction_date', 'transaction_amount', 'customer_age']),
        ('scaler', StandardScaler(), ['transaction_amount', 'customer_age'])
    ], remainder='passthrough')

    pipeline = Pipeline([
        ('prep', preprocessor),
        ('model', GradientBoostingRegressor(random_state=42))
    ])

    pipeline.fit(X, y)
    print("--- Cyclical Date Feature Engineering Pipeline Executed Successfully ---")
    print(f"Pipeline Steps: {list(pipeline.named_steps.keys())}")

if __name__ == '__main__':
    run_advanced_exercise_2_2()

```

---

## Module 3: Supervised Learning — Regression

### Advanced Exercise 3.2: ElasticNet Polynomial Regression with Cross-Validated Hyperparameter Paths

* **Objective:** Combine high-degree polynomial feature expansion with ElasticNet regularization (balancing L1 Lasso sparsity and L2 Ridge coefficient shrinkage) to model non-linear relationships.
* **Task:** Generate a noisy quadratic dataset, apply `PolynomialFeatures`, and optimize alpha and l1_ratio simultaneously using `ElasticNetCV`.

#### Solution 3.2

```python
import numpy as np
from sklearn.datasets import make_regression
from sklearn.preprocessing import PolynomialFeatures, StandardScaler
from sklearn.linear_model import ElasticNetCV
from sklearn.pipeline import Pipeline
from sklearn.metrics import mean_squared_error, r2_score

def run_advanced_exercise_3_2():
    X, y = make_regression(n_samples=400, n_features=3, noise=2.0, random_state=42)
    # Inject non-linearity
    y = y + (X[:, 0] ** 2) * 3.5 - (X[:, 1] * X[:, 2]) * 2.0

    pipeline = Pipeline([
        ('poly', PolynomialFeatures(degree=2, include_bias=False)),
        ('scaler', StandardScaler()),
        ('elastic_cv', ElasticNetCV(l1_ratio=[0.1, 0.5, 0.7, 0.9, 1.0], cv=5, random_state=42, max_iter=10000))
    ])

    pipeline.fit(X, y)
    
    model = pipeline.named_steps['elastic_cv']
    preds = pipeline.predict(X)
    
    print("--- ElasticNet Polynomial Regression Results ---")
    print(f"Optimal Alpha Selected: {model.alpha_:.4f}")
    print(f"Optimal L1 Ratio Selected: {model.l1_ratio_:.2f}")
    print(f"Model Training R-Squared: {r2_score(y, preds):.4f}")
    print(f"Non-Zero Coefficients: {np.sum(model.coef_ != 0)} / {len(model.coef_)}")

if __name__ == '__main__':
    run_advanced_exercise_3_2()

```

---

## Module 4: Supervised Learning — Classification

### Advanced Exercise 4.2: Multiclass Calibration Curve Optimization & Stacked Probability Blending

* **Objective:** Build an advanced multi-class probability calibration pipeline using Platt Scaling (`CalibratedClassifierCV`) on top of an uncalibrated Support Vector Classifier, measuring Brier score improvements.
* **Task:** Construct a synthetic 3-class classification problem, train an uncalibrated SVC, wrap it with probability calibration, and evaluate multi-class log-loss.

#### Solution 4.2

```python
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn.calibration import CalibratedClassifierCV
from sklearn.metrics import log_loss, accuracy_score

def run_advanced_exercise_4_2():
    X, y = make_classification(
        n_samples=1000, n_features=10, n_classes=3, n_informative=8,
        random_state=42
    )
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)

    # Base uncalibrated SVC
    base_svc = SVC(probability=False, kernel='rbf', random_state=42)
    base_svc.fit(X_train, y_train)
    
    # Calibrated Classifier (Platt Scaling via cross-validation)
    calibrated_svc = CalibratedClassifierCV(estimator=SVC(kernel='rbf', random_state=42), method='sigmoid', cv=3)
    calibrated_svc.fit(X_train, y_train)

    # Evaluate Log-Loss (requires probabilities)
    # Note: SVC(probability=False) doesn't natively expose predict_proba efficiently without calibration
    cal_probs = calibrated_svc.predict_proba(X_test)
    preds = calibrated_svc.predict(X_test)

    print("--- Multi-Class Probability Calibration Results ---")
    print(f"Test Accuracy (Calibrated SVC): {accuracy_score(y_test, preds)*100:.2f}%")
    print(f"Multi-Class Log Loss (Calibrated Probabilities): {log_loss(y_test, cal_probs):.4f}")

if __name__ == '__main__':
    run_advanced_exercise_4_2()

```

---

## Module 5: Unsupervised Learning

### Advanced Exercise 5.2: Optimal Cluster Selection via Silhouette Optimization & DBSCAN Grid Sweeps

* **Objective:** Systematically determine the optimal cluster count ($K$) for K-Means using silhouette analysis, and contrast it with density-based spatial clustering (DBSCAN) across hyperparameter grid searches.
* **Task:** Generate synthetic multi-density blob structures, iterate through $K=2$ to $6$ to compute silhouette coefficients, and run a parameter sweep for DBSCAN `eps` and `min_samples`.

#### Solution 5.2

```python
import numpy as np
from sklearn.datasets import make_blobs
from sklearn.cluster import KMeans, DBSCAN
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler

def run_advanced_exercise_5_2():
    X, _ = make_blobs(n_samples=600, n_features=6, centers=4, cluster_std=0.9, random_state=42)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    print("--- K-Means Silhouette Analysis ---")
    best_k = 2
    best_score = -1.0
    
    for k in range(2, 7):
        kmeans = KMeans(n_clusters=k, n_init=10, random_state=42)
        labels = kmeans.fit_predict(X_scaled)
        score = silhouette_score(X_scaled, labels)
        print(f"K = {k} | Silhouette Score: {score:.4f}")
        if score > best_score:
            best_score = score
            best_k = k

    print(f"\nOptimal K-Means Cluster Count Selected by Silhouette: {best_k} (Score: {best_score:.4f})")

    print("\n--- DBSCAN Hyperparameter Sweep ---")
    best_eps = 0.0
    best_min_samples = 0
    best_db_score = -1.0

    for eps in [0.3, 0.5, 0.8, 1.2]:
        for min_samples in [3, 5, 10]:
            db = DBSCAN(eps=eps, min_samples=min_samples)
            labels = db.fit_predict(X_scaled)
            n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
            
            # Silhouette requires at least 2 valid clusters and no singletons
            if n_clusters > 1 and len(set(labels)) > 2:
                score = silhouette_score(X_scaled, labels)
                print(f"Eps: {eps} | MinSamples: {min_samples} | Clusters Found: {n_clusters} | Silhouette: {score:.4f}")
                if score > best_db_score:
                    best_db_score = score
                    best_eps = eps
                    best_min_samples = min_samples

    if best_db_score != -1.0:
        print(f"\nBest DBSCAN Config -> Eps: {best_eps}, MinSamples: {best_min_samples} (Silhouette: {best_db_score:.4f})")
    else:
        print("\nNo valid multi-cluster configuration found across current DBSCAN grid parameters.")

if __name__ == '__main__':
    run_advanced_exercise_5_2()

```

---

## Module 6: Model Evaluation, Tuning & Production

### Advanced Exercise 6.2: Custom Metric Optimization with Nested Cross-Validation & FastAPI Production Schema Validation

* **Objective:** Implement rigorous nested cross-validation (outer loop for unbiased performance estimation, inner loop for hyperparameter optimization via `GridSearchCV`), serialize the final artifact, and mock an asynchronous production inference handler.
* **Task:** Execute a nested cross-validation workflow on a classification dataset, persist the final optimized pipeline using `joblib`, and simulate real-time JSON validation checks.

#### Solution 6.2

```python
import joblib
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import GridSearchCV, KFold, cross_val_score

def run_advanced_exercise_6_2():
    np.random.seed(42)
    n = 800
    df = pd.DataFrame({
        'feature_1': np.random.normal(0, 1, size=n),
        'feature_2': np.random.exponential(2, size=n),
        'target': np.random.choice([0, 1], size=n, p=[0.6, 0.35]) # with minor missing injection setup
    })
    df.loc[np.random.choice(n, 20), 'feature_1'] = np.nan

    X = df.drop(columns=['target'])
    y = df['target']

    preprocessor = ColumnTransformer([
        ('num', Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler())
        ]), ['feature_1', 'feature_2'])
    ])

    pipeline = Pipeline([
        ('prep', preprocessor),
        ('gbc', GradientBoostingClassifier(random_state=42))
    ])

    param_grid = {
        'gbc__n_estimators': [50, 100],
        'gbc__learning_rate': [0.05, 0.1],
        'gbc__max_depth': [3, 5]
    }

    # Inner & Outer CV for Nested Cross-Validation
    inner_cv = KFold(n_splits=3, shuffle=True, random_state=42)
    outer_cv = KFold(n_splits=3, shuffle=True, random_state=42)

    clf = GridSearchCV(estimator=pipeline, param_grid=param_grid, cv=inner_cv, scoring='roc_auc')

    print("--- Executing Nested Cross-Validation Performance Estimation ---")
    nested_scores = cross_val_score(clf, X, y, cv=outer_cv, scoring='roc_auc')
    print(f"Nested CV ROC-AUC Scores across Folds: {nested_scores}")
    print(f"Unbiased Mean ROC-AUC: {nested_scores.mean():.4f} (+/- {nested_scores.std()*2:.4f})")

    # Fit final model on full training set for production artifact generation
    clf.fit(X, y)
    production_artifact = clf.best_estimator_

    artifact_filename = 'nested_production_pipeline.joblib'
    joblib.dump(production_artifact, artifact_filename)
    print(f"\n[INFO] Production model successfully serialized to '{artifact_filename}'")

    # Simulated Asynchronous Production Inference Validation
    loaded_pipeline = joblib.load(artifact_filename)
    incoming_payload = pd.DataFrame({
        'feature_1': [0.45, -1.2, np.nan],
        'feature_2': [1.5, 3.2, 0.8]
    })

    predictions = loaded_pipeline.predict(incoming_payload)
    probabilities = loaded_pipeline.predict_proba(incoming_payload)[:, 1]

    print("\n--- Simulated Production Inference Execution ---")
    for idx, row in incoming_payload.iterrows():
        print(f"Payload Request {idx+1} | F1: {row['feature_1']} | F2: {row['feature_2']} | Pred Class: {predictions[idx]} | Confidence: {probabilities[idx]*100:.2f}%")

if __name__ == '__main__':
    run_advanced_exercise_6_2()

```
