# Mastering Scikit-Learn: Massively Expanded Practical Exercises & Solution Lab

Welcome to the **Massively Expanded Exercises and Solutions Lab**. This workbook is designed for hands-on technical immersion, bridging the gap between theoretical modeling and production-grade machine learning engineering.

Each of the six modules features multiple deep-dive programming exercises accompanied by fully annotated, production-ready Python solutions.

---

## Module 1: Foundations & The Scikit-Learn API

### Exercise 1.1: Multi-Type Synthetic Dataset Generation & Custom Inspection

* **Objective:** Programmatically construct a synthetic dataset containing mixed data types (continuous, discrete, categorical, and missing values), enforce strict dimensional standards, and inspect learned model attributes.
* **Task:** Write a Python script that generates a DataFrame of 1,000 samples. Include features for `tenure` (continuous), `support_tickets` (discrete), `tier` (categorical: `Basic`, `Pro`, `Enterprise`), and random `NaN` values. Fit a baseline model and extract internal attributes following Scikit-Learn naming conventions.

#### Solution 1.1

```python
import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

def run_exercise_1_1():
    np.random.seed(42)
    n = 1000
    
    # 1. Generate Raw Tabular Data
    df = pd.DataFrame({
        'tenure': np.random.exponential(scale=24, size=n),
        'support_tickets': np.random.poisson(lam=2, size=n),
        'tier': np.random.choice(['Basic', 'Pro', 'Enterprise', None], size=n, p=[0.5, 0.3, 0.15, 0.05]),
        'churned': np.random.choice([0, 1], size=n, p=[0.75, 0.25])
    })
    
    X = df.drop(columns=['churned'])
    y = df['churned']
    
    print(f"Feature Matrix Shape (X): {X.shape}")
    print(f"Target Vector Shape (y): {y.shape}")
    
    # 2. Construct Preprocessing & Modeling Pipeline
    preprocessor = ColumnTransformer(transformers=[
        ('num', Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
        ]), ['tenure', 'support_tickets']),
        ('cat', Pipeline([
            ('imputer', SimpleImputer(strategy='constant', fill_value='Missing')),
            ('onehot', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
        ]), ['tier'])
    ])
    
    pipeline = Pipeline([
        ('prep', preprocessor),
        ('clf', LogisticRegression(random_state=42))
    ])
    
    # 3. Fit Pipeline & Inspect Attributes
    pipeline.fit(X, y)
    
    classifier = pipeline.named_steps['clf']
    print(f"\n--- Model Inspection (Scikit-Learn Convention) ---")
    print(f"Learned Coefficients (.coef_): {classifier.coef_}")
    print(f"Learned Intercept (.intercept_): {classifier.intercept_}")
    print(f"Classes Discovered (.classes_): {classifier.classes_}")

if __name__ == '__main__':
    run_exercise_1_1()

```

---

## Module 2: Data Preprocessing & Feature Engineering

### Exercise 2.1: Custom Financial Feature Engineering Transformer & Leak-Free Pipeline

* **Objective:** Build a custom stateful transformer that calculates complex interaction metrics, integrates it into a `ColumnTransformer`, and guarantees zero data leakage across cross-validation folds.
* **Task:** Implement a custom transformer `LiquidityRatioTransformer` that calculates liquid assets over liabilities. Wrap it with numeric scalers and categorical encoders inside a unified pipeline and evaluate via `cross_val_score`.

#### Solution 2.1

```python
import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score

class LiquidityRatioTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, asset_col='liquid_assets', liability_col='liabilities'):
        self.asset_col = asset_col
        self.liability_col = liability_col

    def fit(self, X, y=None):
        return self  # Stateless transformation

    def transform(self, X):
        X_ = X.copy()
        # Prevent division by zero with small epsilon
        X_['liquidity_ratio'] = X_[self.asset_col] / (X_[self.liability_col] + 1e-5)
        return X_

def run_exercise_2_1():
    np.random.seed(42)
    n = 500
    
    df = pd.DataFrame({
        'liquid_assets': np.random.uniform(5000, 100000, size=n),
        'liabilities': np.random.uniform(1000, 80000, size=n),
        'region': np.random.choice(['APAC', 'EMEA', 'AMER'], size=n),
        'default': np.random.choice([0, 1], size=n, p=[0.8, 0.2])
    })
    
    X = df.drop(columns=['default'])
    y = df['default']
    
    numeric_features = ['liquid_assets', 'liabilities']
    categorical_features = ['region']
    
    numeric_transformer = Pipeline([
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler())
    ])
    
    categorical_transformer = Pipeline([
        ('imputer', SimpleImputer(strategy='constant', fill_value='Unknown')),
        ('onehot', OneHotEncoder(handle_unknown='ignore'))
    ])
    
    preprocessor = ColumnTransformer([
        ('num', numeric_transformer, numeric_features),
        ('cat', categorical_transformer, categorical_features)
    ])
    
    full_pipeline = Pipeline([
        ('feature_engineering', LiquidityRatioTransformer()),
        ('preprocessor', preprocessor),
        ('model', RandomForestClassifier(random_state=42))
    ])
    
    scores = cross_val_score(full_pipeline, X, y, cv=5, scoring='roc_auc')
    print(f"Cross-Validation ROC-AUC Scores: {scores}")
    print(f"Mean ROC-AUC: {scores.mean():.4f} (+/- {scores.std() * 2:.4f})")

if __name__ == '__main__':
    run_exercise_2_1()

```

---

## Module 3: Supervised Learning — Regression

### Exercise 3.1: Comparative Regularized Regression & Hyperparameter Curve Analysis

* **Objective:** Compare Ordinary Least Squares, Ridge, and Lasso regression across varying regularization strengths ($\alpha$), plotting performance degradation and coefficient shrinkage.
* **Task:** Generate a high-dimensional dataset with strong multicollinearity, iterate over logarithmic alpha values, and track coefficient trajectories.

#### Solution 3.1

```python
import numpy as np
import pandas as pd
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
from sklearn.linear_model import Ridge, Lasso, LinearRegression
from sklearn.metrics import mean_squared_error

def run_exercise_3_1():
    X, y = make_regression(n_samples=500, n_features=20, noise=0.5, random_state=42)
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Baseline OLS
    ols = LinearRegression()
    ols.fit(X_train, y_train)
    ols_mse = mean_squared_error(y_test, ols.predict(X_test))
    print(f"Baseline OLS Test MSE: {ols_mse:.4f}")
    
    # Ridge Alpha Sweep
    alphas = [0.01, 0.1, 1.0, 10.0, 100.0]
    print("\n--- Ridge Regularization Sweep ---")
    for a in alphas:
        ridge = Ridge(alpha=a)
        ridge.fit(X_train, y_train)
        mse = mean_squared_error(y_test, ridge.predict(X_test))
        non_zero = np.sum(ridge.coef_ != 0)
        print(f"Alpha: {a:6.2f} | MSE: {mse:.4f} | Non-zero Coeffs: {non_zero}")

    # Lasso Alpha Sweep (Sparsity Check)
    print("\n--- Lasso Regularization Sweep (Feature Selection) ---")
    for a in alphas:
        lasso = Lasso(alpha=a, max_iter=10000)
        lasso.fit(X_train, y_train)
        mse = mean_squared_error(y_test, lasso.predict(X_test))
        zero_coeffs = np.sum(lasso.coef_ == 0)
        print(f"Alpha: {a:6.2f} | MSE: {mse:.4f} | Zeroed Coeffs (Eliminated): {zero_coeffs}/20")

if __name__ == '__main__':
    run_exercise_3_1()

```

---

## Module 4: Supervised Learning — Classification

### Exercise 4.1: Cost-Sensitive Classification & Threshold Tuning on Skewed Data

* **Objective:** Train a classifier on a highly imbalanced dataset, generate predicted probabilities, and manually adjust the decision threshold to optimize F1-score rather than default accuracy.
* **Task:** Simulate a fraud detection dataset (1% positive class), train a Random Forest with class balancing, extract probabilities, and iterate through decision thresholds.

#### Solution 4.1

```python
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score, precision_score, recall_score, classification_report

def run_exercise_4_1():
    X, y = make_classification(
        n_samples=5000, n_features=15, weights=[0.99, 0.01], 
        random_state=42
    )
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    
    # Train model with balanced class weights
    rf = RandomForestClassifier(class_weight='balanced', random_state=42)
    rf.fit(X_train, y_train)
    
    probs = rf.predict_proba(X_test)[:, 1]
    
    # Default threshold (0.5)
    default_preds = (probs >= 0.5).astype(int)
    print("--- Default Threshold (0.5) ---")
    print(classification_report(y_test, default_preds, zero_division=0))
    
    # Threshold Tuning for Optimal F1
    best_threshold = 0.5
    best_f1 = 0.0
    
    thresholds = np.linspace(0.1, 0.9, 81)
    for t in thresholds:
        preds = (probs >= t).astype(int)
        score = f1_score(y_test, preds, zero_division=0)
        if score > best_f1:
            best_f1 = score
            best_threshold = t
            
    print(f"\nOptimal Threshold found: {best_threshold:.2f} yielding F1-Score: {best_f1:.4f}")
    
    tuned_preds = (probs >= best_threshold).astype(int)
    print("--- Tuned Threshold Classification Report ---")
    print(classification_report(y_test, tuned_preds, zero_division=0))

if __name__ == '__main__':
    run_exercise_4_1()

```

---

## Module 5: Unsupervised Learning

### Exercise 5.1: Dual Clustering & Anomaly Detection Pipeline

* **Objective:** Combine PCA dimensionality reduction, K-Means clustering, and Isolation Forest anomaly detection into an exploratory unsupervised data analysis pipeline.
* **Task:** Generate multidimensional cluster data with injected random noise, reduce dimensions via PCA, cluster via K-Means, and isolate anomalies.

#### Solution 5.1

```python
import numpy as np
from sklearn.datasets import make_blobs
from sklearn.decomposition import PCA
from sklearn.cluster import KMeans
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler

def run_exercise_5_1():
    np.random.seed(42)
    # Generate clean clusters
    X_clean, y_true = make_blobs(n_samples=400, n_features=10, centers=3, cluster_std=1.2, random_state=42)
    # Inject noise/anomalies
    X_noise = np.random.uniform(low=-15.0, high=15.0, size=(20, 10))
    X = np.vstack([X_clean, X_noise])
    
    # 1. Scale Features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # 2. PCA Dimensionality Reduction
    pca = PCA(n_components=2, random_state=42)
    X_reduced = pca.fit_transform(X_scaled)
    print(f"Reduced shape via PCA: {X_reduced.shape}")
    print(f"Total Explained Variance: {sum(pca.explained_variance_ratio_)*100:.2f}%")
    
    # 3. Anomaly Detection via Isolation Forest
    iso = IsolationForest(contamination=0.05, random_state=42)
    outlier_preds = iso.fit_predict(X_scaled) # -1 = anomaly, 1 = normal
    n_outliers = np.sum(outlier_preds == -1)
    print(f"Anomalies detected: {n_outliers}")
    
    # Filter out anomalies for clean clustering
    X_filtered = X_scaled[outlier_preds == 1]
    
    # 4. K-Means Clustering on Cleaned Data
    kmeans = KMeans(n_clusters=3, n_init=10, random_state=42)
    cluster_labels = kmeans.fit_predict(X_filtered)
    print(f"Cluster centroids shape: {kmeans.cluster_centers_.shape}")
    print(f"Inertia of clusters: {kmeans.inertia_:.2f}")

if __name__ == '__main__':
    run_exercise_5_1()

```

---

## Module 6: Model Evaluation, Tuning & Production

### Exercise 6.1: End-to-End Randomized Search Pipeline Serialization & Inference Simulation

* **Objective:** Build a complete hyperparameter tuning pipeline, serialize the winning model artifact to disk using `joblib`, load it in a separate simulated runtime, and validate incoming payload schemas.
* **Task:** Create a classification pipeline, execute `RandomizedSearchCV`, dump the best estimator to `model.joblib`, reload it, and run real-time predictions.

#### Solution 6.1

```python
import joblib
import pandas as pd
import numpy as np
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import RandomizedSearchCV, train_test_split
from scipy.stats import randint

def run_exercise_6_1():
    np.random.seed(42)
    n = 600
    
    df = pd.DataFrame({
        'age': np.random.randint(18, 70, size=n),
        'income': np.random.randint(25000, 120000, size=n),
        'employment': np.random.choice(['Full-Time', 'Part-Time', 'Unemployed'], size=n),
        'approved': np.random.choice([0, 1], size=n, p=[0.4, 0.6])
    })
    
    X = df.drop(columns=['approved'])
    y = df['approved']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Build Pipeline
    preprocessor = ColumnTransformer([
        ('num', Pipeline([('imputer', SimpleImputer(strategy='median')), ('scaler', StandardScaler())]), ['age', 'income']),
        ('cat', Pipeline([('imputer', SimpleImputer(strategy='constant', fill_value='Missing')), ('onehot', OneHotEncoder(handle_unknown='ignore'))]), ['employment'])
    ])
    
    pipeline = Pipeline([
        ('prep', preprocessor),
        ('model', RandomForestClassifier(random_state=42))
    ])
    
    # Randomized Search
    param_dist = {
        'model__n_estimators': randint(50, 200),
        'model__max_depth': [None, 5, 10, 20]
    }
    
    search = RandomizedSearchCV(pipeline, param_distributions=param_dist, n_iter=3, cv=3, random_state=42, scoring='accuracy')
    search.fit(X_train, y_train)
    
    best_model = search.best_estimator_
    print(f"Best Hyperparameters Found: {search.best_params_}")
    print(f"Cross-Validation Accuracy: {search.best_score_*100:.2f}%")
    
    # 1. Serialization (Persistence)
    artifact_path = 'production_model.joblib'
    joblib.dump(best_model, artifact_path)
    print(f"[INFO] Model artifact successfully serialized to {artifact_path}")
    
    # 2. Simulated Inference Server Load & Prediction
    loaded_model = joblib.load(artifact_path)
    
    incoming_payload = pd.DataFrame({
        'age': [29, 52],
        'income': [55000, 95000],
        'employment': ['Full-Time', 'Part-Time']
    })
    
    predictions = loaded_model.predict(incoming_payload)
    probabilities = loaded_model.predict_proba(incoming_payload)[:, 1]
    
    print("\n--- Simulated Production Inference Execution ---")
    for idx, row in incoming_payload.iterrows():
        print(f"Record {idx+1} | Age: {row['age']} | Income: ${row['income']} | Predicted Class: {predictions[idx]} | Confidence: {probabilities[idx]*100:.2f}%")

if __name__ == '__main__':
    run_exercise_6_1()

```
