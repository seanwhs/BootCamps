## Part 1: Foundations & The Scikit-Learn API

Welcome to the technical core of the series. In this part, we will explore the foundational philosophies that make Scikit-Learn the industry standard for machine learning in Python: consistency, composition, and encapsulation.

Before we write code, let's establish our working environment. We will use a clean, self-contained Python script to build, verify, and test every concept.

---

### Step 1.1: Environment Setup & Dataset Initialization

#### The Target

Create our project directory structure and write a python initialization script (`setup_environment.py`) that checks dependencies and generates a mock messy dataset containing missing values, categorical features, and continuous numerical features.

#### The Concept

Imagine you are hiring a new data analyst. Before they can analyze a company's sales records, they need raw spreadsheets that might have coffee stains (missing values), inconsistent job titles (categorical text), and different currencies (unscaled numbers). Here, we are manufacturing that raw, messy spreadsheet programmatically so we have a reliable playground.

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
        print(f"Missing dependency: {e}. Please install requirements via pip install scikit-learn pandas numpy")
        sys.exit(1)

    # Generate a messy mock dataset simulating real-world data
    np.random.seed(42)
    n_samples = 100

    data = {
        'age': np.random.randint(18, 70, size=n_samples),
        'income': np.random.choice([30000, 50000, 80000, 120000, np.nan], size=n_samples),
        'department': np.random.choice(['Engineering', 'Marketing', 'Sales', None], size=n_samples),
        'promoted': np.random.choice([0, 1], size=n_samples) # Target variable: 0 = No, 1 = Yes
    }

    df = pd.DataFrame(data)
    df.to_csv('messy_employee_data.csv', index=False)
    print("\n[SUCCESS] Environment verified and 'messy_employee_data.csv' generated successfully!")

if __name__ == '__main__':
    verify_and_generate()

```

#### The Verification

Run the setup script in your terminal:

```bash
python setup_environment.py

```

You should see confirmation of your library versions and a success message indicating that `messy_employee_data.csv` has been created in your working directory.

---

### Step 1.2: The Estimator API

#### The Target

Write a script (`estimator_primer.py`) that demonstrates the core Scikit-Learn Estimator interface using a simple model: `.fit()`, `.predict()`, and `.transform()`.

#### The Concept

Think of a Scikit-Learn estimator as a training coach.

* `.fit()` is the training phase where the coach studies historical data to learn patterns (e.g., learning how age correlates with promotion).
* `.predict()` is the testing phase where the coach applies those learned patterns to make a judgment call on new, unseen candidates.
* `.transform()` is the modification phase where the model alters the data itself based on learned parameters (e.g., standardizing heights so they are measured in standard deviations instead of centimeters).

#### The Implementation

Create a file named `estimator_primer.py` with the following code:

```python
# estimator_primer.py
import numpy as np
from sklearn.linear_model import LogisticRegression

def demonstrate_estimator():
    # 1. Create simple, clean numerical data (Features: [Age, Years Experience], Target: [Promoted])
    X_train = np.array([
        [25, 1],
        [32, 5],
        [47, 15],
        [51, 20]
    ])
    y_train = np.array([0, 0, 1, 1])

    # 2. Instantiate the Estimator (our machine learning model)
    model = LogisticRegression()

    # 3. The .fit() method: Training the model on data
    model.fit(X_train, y_train)
    print("[INFO] Model successfully fitted (trained) on data.")

    # 4. New incoming candidate data to evaluate
    X_new = np.array([
        [29, 2],
        [45, 12]
    ])

    # 5. The .predict() method: Generating categorical predictions
    predictions = model.predict(X_new)
    probabilities = model.predict_proba(X_new)

    print("\n--- Model Predictions ---")
    for i, pred in enumerate(predictions):
        prob = probabilities[i][pred] * 100
        print(f"Candidate {i+1} Prediction: {'Promoted' if pred == 1 else 'Not Promoted'} (Confidence: {prob:.1f}%)")

if __name__ == '__main__':
    demonstrate_estimator()

```

#### The Verification

Execute the script via your terminal:

```bash
python estimator_primer.py

```

You should see output confirming that the model was fitted, followed by clear promotion predictions and confidence scores for the mock candidates.

---

### Step 1.3: Data Preparation with Imputers, Encoders, and Scalers

#### The Target

Write a preprocessing script (`data_prep.py`) that uses `SimpleImputer` to fill missing values, `OneHotEncoder` to handle categorical text columns, and `StandardScaler` to normalize numerical ranges.

#### The Concept

Machine learning models are strict mathematical functions; they cannot digest missing values (`NaN`), words like `"Engineering"`, or vastly different numerical scales (like counting age in decades versus counting salary in hundreds of thousands).

* **Imputation** is like filling missing questionnaire blanks with an educated guess (the average value).
* **One-Hot Encoding** is like translating multiple-choice categories into distinct true/false binary checklist columns.
* **Scaling** is like converting different units of measurement (inches versus miles) onto a universal ruler so no single feature bullies the others simply because its numbers are larger.

#### The Implementation

Create a file named `data_prep.py` with the following code:

```python
# data_prep.py
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, StandardScaler

def prepare_data():
    # Load our messy dataset
    df = pd.read_csv('messy_employee_data.csv')
    
    # Separate features (X) and target (y)
    X = df.drop(columns=['promoted'])
    y = df['promoted']

    print("--- Before Preprocessing ---")
    print(X.head(3))

    # Define feature subsets
    numeric_features = ['age', 'income']
    categorical_features = ['department']

    # 1. Numerical Imputation & Scaling
    # Fill missing income values with the median
    num_imputer = SimpleImputer(strategy='median')
    scaler = StandardScaler()

    X_num_imputed = num_imputer.fit_transform(X[numeric_features])
    X_scaled = scaler.fit_transform(X_num_imputed)

    # 2. Categorical Imputation & One-Hot Encoding
    # Fill missing departments with a constant string 'Missing'
    cat_imputer = SimpleImputer(strategy='constant', fill_value='Missing')
    encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')

    X_cat_imputed = cat_imputer.fit_transform(X[[categorical_features[0]]])
    X_encoded = encoder.fit_transform(X_cat_imputed)

    # Combine processed features back together
    X_processed = pd.concat([
        pd.DataFrame(X_scaled, columns=numeric_features),
        pd.DataFrame(X_encoded, columns=encoder.get_feature_names_out(categorical_features))
    ], axis=1)

    print("\n--- After Preprocessing ---")
    print(X_processed.head(3))
    print(f"\n[SUCCESS] Preprocessed shape: {X_processed.shape}")

if __name__ == '__main__':
    prepare_data()

```

#### The Verification

Run the data preparation script:

```bash
python data_prep.py

```

Verify that the output displays clean numerical data with zero missing values, standardized numeric columns, and binary category columns without throwing errors.

---

### Step 1.4: Pipelines & ColumnTransformer (Leak-Free Architecture)

#### The Target

Build a production-grade, encapsulated machine learning pipeline using `Pipeline` and `ColumnTransformer` in a script named `production_pipeline.py`.

#### The Concept

Writing manual preprocessing steps (like we did in Step 1.3) separately for training data and test data invites **data leakage**—a cardinal sin in machine learning where information from your validation or test set accidentally leaks into your training process, leading to falsely inflated test accuracy.

A Scikit-Learn **Pipeline** is like a factory assembly line. Raw materials (messy data) enter one end, pass through automated cleaning stations (`ColumnTransformer`), and emerge as finished predictions at the other end. Crucially, the assembly line learns its parameters (like means and categories) *only* from the training batch, preventing leakage.

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

    # 2. Split data into train and test sets to prevent data leakage
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 3. Define preprocessing steps for numerical and categorical columns
    numeric_features = ['age', 'income']
    categorical_features = ['department']

    numeric_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler())
    ])

    categorical_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='constant', fill_value='Missing')),
        ('onehot', OneHotEncoder(handle_unknown='ignore'))
    ])

    # 4. Combine preprocessing steps using ColumnTransformer
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', numeric_transformer, numeric_features),
            ('cat', categorical_transformer, categorical_features)
        ]
    )

    # 5. Create the ultimate Pipeline binding preprocessing and model together
    full_pipeline = Pipeline(steps=[
        ('preprocessor', preprocessor),
        ('classifier', RandomForestClassifier(random_state=42))
    ])

    # 6. Fit the entire pipeline with a single command (No manual data leakage possible!)
    full_pipeline.fit(X_train, y_train)
    print("[INFO] Pipeline successfully trained end-to-end.")

    # 7. Evaluate on test data
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

You should see confirmation that the end-to-end pipeline was successfully trained and evaluated, printing out the final test accuracy percentage without crashing or encountering missing value exceptions.

---

### Reference Section: Deep Dive into Scikit-Learn API & Transformers

To solidify your engineering foundation, keep this reference guide handy when designing custom workflows:

* **The Estimator Lifecycle:**
* `fit(X, y)`: Computes internal parameters (e.g., means, standard deviations, regression weights). Returns `self`.
* `transform(X)`: Applies learned parameters to alter data (used in transformers/preprocessors).
* `predict(X)`: Applies learned rules to output class labels or regression values (used in models).
* `fit_transform(X, y)`: Optimized shorthand combining fitting and transforming in a single pass.


* **Why Pipelines Matter:**
Without pipelines, developers often calculate `StandardScaler().fit_transform()` on the *entire* dataset *before* splitting into train and test sets. This means the mean and variance of the test set influence the training set normalization, contaminating your evaluation metrics. `Pipeline` ensures transformers only calculate statistics on training folds during cross-validation.
