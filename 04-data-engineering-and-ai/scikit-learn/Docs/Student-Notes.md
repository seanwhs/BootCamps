## Module 1: Introduction & Ecosystem

### 1.1 The Scikit-Learn Philosophy

Scikit-Learn stands as the industry-standard library for classical machine learning in Python. Its architecture is built upon three core design principles:

* **Consistency:** All objects share a uniform interface. Objects that learn from data are called *estimators*, and their methods follow strict naming conventions.
* **Inspection:** All learned model attributes (such as coefficients or splitting thresholds) are exposed as public attributes ending with a trailing underscore (e.g., `.coef_`, `.classes_`).
* **Composition:** Algorithms are expressed as sequences of transformations and estimators, allowing complex workflows to be strung together cleanly via pipelines.

### 1.2 The Python Data Science Stack

Understanding where Scikit-Learn fits in the broader ecosystem prevents architectural overlap:

* **Pandas:** Used for tabular data ingestion, cleaning, and manipulation (`pd.DataFrame`, `pd.Series`).
* **NumPy:** The underlying mathematical engine providing high-performance multidimensional arrays (`np.ndarray`) and vectorized matrix operations.
* **Matplotlib / Seaborn:** Visualization libraries used for exploratory data analysis (EDA) and plotting evaluation curves.
* **Scikit-Learn:** Consumes Pandas DataFrames or NumPy arrays to execute statistical modeling, preprocessing, and evaluation.

### 1.3 The Universal API Design

Every Scikit-Learn object relies on a consistent method signature:

* `.fit(X, y)`: Trains the estimator or transformer using feature matrix $X$ and target vector $y$. For unsupervised learning, $y$ is omitted (`.fit(X)`).
* `.transform(X)`: Applies learned parameters (like means, scalers, or PCA projections) to transform $X$ into a new representation.
* `.fit_transform(X, y)`: An optimized shortcut that runs `.fit()` and `.transform()` sequentially on the same dataset.
* `.predict(X)`: Generates target predictions ($\hat{y}$) for unseen feature matrices.
* `.predict_proba(X)`: Returns class probabilities for classification models.

### 1.4 Tabular Data Layout ($X$ and $y$)

Scikit-Learn enforces strict dimensional standards:

* **Feature Matrix ($X$):** Must be a 2D array of shape `(n_samples, n_features)`. Rows represent individual observations; columns represent measurable attributes.
* **Target Vector ($y$):** Must be a 1D array or series of shape `(n_samples,)` containing supervisory labels or continuous target values.

---

## Module 2: Data Preprocessing & Feature Engineering

### 2.1 The Principle of Leakage Prevention

Feature engineering transforms raw domain data into clean mathematical inputs. However, transformations must never incorporate information from validation or test splits.

* **The Rule:** Always partition your dataset into train and test splits *before* fitting any transformer (scaler, imputer, or encoder). Fit transformers exclusively on the training fold, then apply them via `.transform()` to the test fold.

### 2.2 Imputation and Encoding

* **Missing Values (`SimpleImputer`):** Replaces `NaN` entries with statistical estimates (mean, median, most frequent) or constant strings.
* **Categorical Encoding (`OneHotEncoder`):** Converts string or categorical categories into sparse binary indicator columns. Setting `handle_unknown='ignore'` prevents runtime crashes if production inference payloads introduce unseen categories.

### 2.3 Feature Scaling

* **Standardization (`StandardScaler`):** Centers features to a mean ($\mu = 0$) and standard deviation ($\sigma = 1$). Essential for distance-based algorithms (KNN, K-Means) and gradient-based models (Logistic Regression, Neural Networks).
* **Normalization (`MinMaxScaler`):** Bounds features to a fixed range, typically $[0, 1]$.

### 2.4 The `ColumnTransformer` Blueprint

Complex datasets contain mixed data types. The `ColumnTransformer` routes distinct columns to specialized transformation pipelines simultaneously:

```python
preprocessor = ColumnTransformer([
    ('num', numeric_pipeline, ['age', 'income']),
    ('cat', categorical_pipeline, ['region', 'department'])
])

```

---

## Module 3: Supervised Learning — Regression

### 3.1 Linear Models & Ordinary Least Squares

Linear regression models target variables as a weighted linear combination of input features:


$$\hat{y} = w_0 + w_1x_1 + w_2x_2 + \dots + w_nx_n$$


Optimization minimizes the Mean Squared Error (MSE) via closed-form matrix math or gradient descent.

### 3.2 Regularization Strategies

When features are collinear or prone to overfitting, penalty terms are added to the loss function:

* **Ridge (L2 Penalty):** Adds a penalty proportional to the *squared magnitude* of coefficients ($\sum w_j^2$), shrinking weights smoothly toward zero.
* **Lasso (L1 Penalty):** Adds a penalty proportional to the *absolute magnitude* of coefficients ($\sum \vert{}w_j\vert{}$), driving irrelevant feature weights precisely to zero for built-in feature selection.

### 3.3 Tree-Based Ensembles

* **Decision Trees:** Make predictions by recursively splitting feature spaces based on impurity thresholds (MSE or Gini). Deep trees suffer from high variance and overfitting.
* **Random Forest Regressor:** Combines an ensemble of randomized decision trees via *bagging* (bootstrap aggregating), averaging their predictions to drastically reduce variance.

---

## Module 4: Supervised Learning — Classification

### 4.1 Logistic Regression & Probability Calibration

Despite its name, Logistic Regression is a classification algorithm. It passes linear outputs through the Sigmoid function to squash continuous values into calibrated probabilities bounded between $0$ and $1$:


$$P(y=1\vert{}X) = \frac{1}{1 + e^{-z}}$$

### 4.2 Support Vector Machines (SVM) & Kernels

SVMs find the optimal hyperplane that maximizes the geometric margin between classes. Non-linear classification boundaries are achieved by projecting low-dimensional data into higher-dimensional spaces using **kernels** (e.g., Radial Basis Function / RBF kernel).

### 4.3 Evaluating Classifiers

* **Confusion Matrix:** Breaks predictions into True Positives (TP), True Negatives (TN), False Positives (FP), and False Negatives (FN).
* **Precision vs. Recall:**
* *Precision* ($TP / (TP + FP)$): Minimizes false positives.
* *Recall* ($TP / (TP + FN)$): Minimizes false negatives.


* **ROC-AUC:** Plots True Positive Rate against False Positive Rate across all classification thresholds, summarizing ranking capability into a single metric.

---

## Module 5: Unsupervised Learning

### 5.1 K-Means Clustering

An iterative partitioning algorithm that groups data into $K$ clusters by minimizing within-cluster variance (inertia).

* **Elbow Method:** Runs K-Means across varying values of $K$ and plots inertia to identify the point of diminishing returns.

### 5.2 Density-Based Spatial Clustering (DBSCAN)

Unlike K-Means, DBSCAN groups points based on spatial density thresholds. It excels at discovering arbitrary geometric shapes and automatically flagging low-density points as **noise / outliers**.

### 5.3 Dimensionality Reduction (PCA)

Principal Component Analysis rotates feature axes to align with directions of maximal variance, projecting high-dimensional datasets into orthogonal lower-dimensional subspaces while retaining maximum information.

---

## Module 6: Model Evaluation, Tuning & Production

### 6.1 Cross-Validation

To ensure performance metrics are not dependent on a single lucky train-test split, data is partitioned into $k$ folds. The model is trained and evaluated $k$ separate times, and scores are averaged.

### 6.2 Hyperparameter Optimization

* **`GridSearchCV`:** Exhaustively searches through a manually specified dictionary of hyperparameter combinations.
* **`RandomizedSearchCV`:** Samples a fixed number of random parameter combinations from specified statistical distributions, drastically speeding up optimization over large spaces.

### 6.3 Production Serialization

Trained pipelines are serialized to disk using `joblib` (optimized for large NumPy arrays over Python's native `pickle`):

```python
import joblib
joblib.dump(pipeline, 'model_v1.joblib')

```

In production, the binary artifact is loaded directly into an asynchronous web framework (like FastAPI) to handle real-time inference payloads without executing training routines.
