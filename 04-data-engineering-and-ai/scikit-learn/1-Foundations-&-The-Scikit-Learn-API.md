## Part 1: Foundations & The Scikit-Learn API

Welcome to the technical core of the series. In this part, we explore the foundational philosophies that make Scikit-Learn the industry standard for machine learning in Python: **consistency**, **composition**, and **encapsulation**.

Before we write any modeling code, we establish a clean, self-contained working environment. Every concept is demonstrated with a standalone Python script that you can run, inspect, and modify.

---

### Step 1.1: Environment Setup & Dataset Initialization

#### The Target

Create the project foundation and write an initialization script (`setup_environment.py`) that verifies core dependencies and generates a realistic, messy dataset containing missing values, categorical features, and continuous numerical features.

#### The Concept

Imagine you are onboarding a new data analyst. Before they can analyze company records, they need raw spreadsheets that may contain coffee stains (missing values), inconsistent job titles (categorical text), and numbers expressed in different units or scales. Here we programmatically manufacture that imperfect spreadsheet so we have a reliable, reproducible playground for the rest of the series.

#### The Implementation

Create a file named `setup_environment.py` with the following code:

```python
# setup_environment.py
import sys
import pandas as pd
import numpy as np

def verify_and_generate():
    print(f"Python Version: {sys.version.split()[0]}")

    # Verify core dependencies
    try:
        import sklearn
        import pandas
        import numpy
        print(f"Scikit-Learn version: {sklearn.__version__}")
        print(f"Pandas version: {pandas.__version__}")
        print(f"NumPy version: {numpy.__version__}")
    except ImportError as e:
        print(f"Missing dependency: {e}")
        print("Please install requirements: pip install scikit-learn pandas numpy")
        sys.exit(1)

    # Generate a messy mock dataset simulating real-world data
    np.random.seed(42)
    n_samples = 100

    data = {
        'age': np.random.randint(18, 70, size=n_samples),
        'income': np.random.choice([30000, 50000, 80000, 120000, np.nan], size=n_samples),
        'department': np.random.choice(['Engineering', 'Marketing', 'Sales', None], size=n_samples),
        'promoted': np.random.choice([0, 1], size=n_samples)  # Target: 0 = No, 1 = Yes
    }

    df = pd.DataFrame(data)
    df.to_csv('messy_employee_data.csv', index=False)
    print("\n[SUCCESS] Environment verified and 'messy_employee_data.csv' generated successfully!")
    print(f"Dataset shape: {df.shape}")
    print(f"Missing values:\n{df.isnull().sum()}")

if __name__ == '__main__':
    verify_and_generate()
```

#### The Verification

Run the setup script in your terminal:

```bash
python setup_environment.py
```

You should see confirmation of your library versions, a success message, and a brief summary of the generated dataset (including missing-value counts). The file `messy_employee_data.csv` will appear in your working directory.

---

### Step 1.2: The Estimator API

#### The Target

Write a script (`estimator_primer.py`) that demonstrates the core Scikit-Learn Estimator interface: `.fit()`, `.predict()`, and `.predict_proba()`.

#### The Concept

Think of a Scikit-Learn estimator as a specialized training coach.

* `.fit()` is the training phase — the coach studies historical examples and internalizes patterns (for example, how age and experience relate to promotion likelihood).
* `.predict()` is the decision phase — the coach applies those learned patterns to new, unseen candidates and issues a clear yes/no judgment.
* `.predict_proba()` goes one step further and reports the coach’s confidence in each possible outcome.

This consistent interface is one of Scikit-Learn’s greatest strengths: almost every model, whether a simple linear classifier or a complex ensemble, speaks the same language.

#### The Implementation

Create a file named `estimator_primer.py` with the following code:

```python
# estimator_primer.py
import numpy as np
from sklearn.linear_model import LogisticRegression

def demonstrate_estimator():
    # 1. Create simple, clean numerical training data
    # Features: [Age, Years of Experience], Target: [Promoted]
    X_train = np.array([
        [25, 1],
        [32, 5],
        [47, 15],
        [51, 20]
    ])
    y_train = np.array([0, 0, 1, 1])

    # 2. Instantiate the Estimator
    model = LogisticRegression()

    # 3. .fit() — Training the model on historical data
    model.fit(X_train, y_train)
    print("[INFO] Model successfully fitted (trained) on data.")

    # 4. New incoming candidate data to evaluate
    X_new = np.array([
        [29, 2],
        [45, 12]
    ])

    # 5. .predict() and .predict_proba()
    predictions = model.predict(X_new)
    probabilities = model.predict_proba(X_new)

    print("\n--- Model Predictions ---")
    for i, pred in enumerate(predictions):
        confidence = probabilities[i][pred] * 100
        label = 'Promoted' if pred == 1 else 'Not Promoted'
        print(f"Candidate {i+1}: {label} (Confidence: {confidence:.1f}%)")

if __name__ == '__main__':
    demonstrate_estimator()
```

#### The Verification

Execute the script:

```bash
python estimator_primer.py
```

You should see confirmation that the model was fitted, followed by clear promotion predictions and confidence scores for the two mock candidates.

---

### Step 1.3: Data Preparation with Imputers, Encoders, and Scalers

#### The Target

Write a preprocessing script (`data_prep.py`) that uses `SimpleImputer` to fill missing values, `OneHotEncoder` to handle categorical columns, and `StandardScaler` to normalize numerical ranges.

#### The Concept

Machine learning models are strict mathematical functions. They cannot digest missing values (`NaN`), words such as `"Engineering"`, or features measured on wildly different scales (age in years versus salary in tens of thousands of dollars).

* **Imputation** fills missing questionnaire blanks with an educated guess (commonly the median or a constant).
* **One-Hot Encoding** translates multi-choice categories into distinct binary (0/1) columns.
* **Scaling** places every numerical feature on a comparable footing so that no single variable dominates simply because its raw numbers are larger.

Performing these steps correctly is essential before any model can learn meaningful patterns.

#### The Implementation

Create a file named `data_prep.py` with the following code:

```python
# data_prep.py
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, StandardScaler

def prepare_data():
    # Load the messy dataset created in Step 1.1
    df = pd.read_csv('messy_employee_data.csv')

    # Separate features (X) and target (y)
    X = df.drop(columns=['promoted'])
    y = df['promoted']

    print("--- Before Preprocessing ---")
    print(X.head(3))
    print(f"\nMissing values:\n{X.isnull().sum()}")

    # Define feature subsets
    numeric_features = ['age', 'income']
    categorical_features = ['department']

    # 1. Numerical pipeline: Impute → Scale
    num_imputer = SimpleImputer(strategy='median')
    scaler = StandardScaler()

    X_num_imputed = num_imputer.fit_transform(X[numeric_features])
    X_scaled = scaler.fit_transform(X_num_imputed)

    # 2. Categorical pipeline: Impute → One-Hot Encode
    cat_imputer = SimpleImputer(strategy='constant', fill_value='Missing')
    encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')

    X_cat_imputed = cat_imputer.fit_transform(X[categorical_features])
    X_encoded = encoder.fit_transform(X_cat_imputed)

    # Combine processed features
    X_processed = pd.concat([
        pd.DataFrame(X_scaled, columns=numeric_features),
        pd.DataFrame(X_encoded, columns=encoder.get_feature_names_out(categorical_features))
    ], axis=1)

    print("\n--- After Preprocessing ---")
    print(X_processed.head(3))
    print(f"\n[SUCCESS] Preprocessed shape: {X_processed.shape}")
    print(f"Missing values remaining: {X_processed.isnull().sum().sum()}")

if __name__ == '__main__':
    prepare_data()
```

#### The Verification

Run the data preparation script:

```bash
python data_prep.py
```

Confirm that the output shows clean numerical data with zero missing values, standardized numeric columns, and binary category columns. No exceptions should be raised.

---

### Step 1.4: Pipelines & ColumnTransformer (Leak-Free Architecture)

#### The Target

Build a production-grade, encapsulated machine learning pipeline using `Pipeline` and `ColumnTransformer` in a script named `production_pipeline.py`.

#### The Concept

Writing manual preprocessing steps (as we did in Step 1.3) separately for training and test data is dangerous. It invites **data leakage** — a cardinal sin in machine learning where statistics from the validation or test set accidentally influence the training process, producing falsely optimistic performance numbers.

A Scikit-Learn **Pipeline** acts like a factory assembly line. Raw materials (messy data) enter one end, pass through automated cleaning and transformation stations, and emerge as finished predictions at the other end. Crucially, every transformer learns its parameters (means, categories, scaling factors, etc.) *only* from the training data. This guarantees that information from the held-out set never leaks into the model.

#### The Implementation

Create a file named `production_pipeline.py` with the following code:

```python
# production_pipeline.py
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

def run_pipeline():
    # 1. Load data
    df = pd.read_csv('messy_employee_data.csv')
    X = df.drop(columns=['promoted'])
    y = df['promoted']

    # 2. Split *before* any fitting to prevent data leakage
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # 3. Define preprocessing for numerical and categorical columns
    numeric_features = ['age', 'income']
    categorical_features = ['department']

    numeric_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler())
    ])

    categorical_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='constant', fill_value='Missing')),
        ('onehot', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
    ])

    # 4. Combine preprocessing steps with ColumnTransformer
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', numeric_transformer, numeric_features),
            ('cat', categorical_transformer, categorical_features)
        ]
    )

    # 5. Assemble the full end-to-end pipeline
    full_pipeline = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('classifier', RandomForestClassifier(random_state=42))
    ])

    # 6. Fit the entire pipeline with a single call
    full_pipeline.fit(X_train, y_train)
    print("[INFO] Pipeline successfully trained end-to-end.")

    # 7. Evaluate on the held-out test set
    y_pred = full_pipeline.predict(X_test)
    acc = accuracy_score(y_test, y_pred)

    print(f"\n--- Model Evaluation ---")
    print(f"Test Accuracy: {acc * 100:.2f}%")

if __name__ == '__main__':
    run_pipeline()
```

#### The Verification

Execute the production pipeline script:

```bash
python production_pipeline.py
```

You should see confirmation that the end-to-end pipeline trained successfully and a final test accuracy figure, with no missing-value errors or shape mismatches.

---

### Reference Section: Deep Dive into the Scikit-Learn API & Transformers

**The Estimator Lifecycle**

| Method              | Purpose                                      | Returns          |
|---------------------|----------------------------------------------|------------------|
| `fit(X, y)`         | Learn parameters from training data          | `self`           |
| `transform(X)`      | Apply learned transformations                | Transformed data |
| `predict(X)`        | Generate predictions                         | Labels / values  |
| `predict_proba(X)`  | Generate class probabilities                 | Probability array|
| `fit_transform(X, y)` | Convenience method (fit + transform)       | Transformed data |

**Why Pipelines Matter**

Without pipelines, developers frequently call `StandardScaler().fit_transform()` on the *entire* dataset before splitting. This means the mean and variance of the test set influence the normalization applied to the training set, contaminating evaluation metrics. A properly constructed `Pipeline` ensures that every transformer calculates its statistics exclusively on training folds, even during cross-validation.

**Key Best Practices**

* Always split data *before* fitting any transformer or model.
* Prefer `ColumnTransformer` + nested `Pipeline` objects for mixed-type data.
* Use `handle_unknown='ignore'` (or a similar strategy) so the pipeline does not crash on unseen categories at inference time.
* Keep the final estimator as the last step of the pipeline so that the whole object can be treated as a single, serializable unit later.
