## Module 1: Introduction & Ecosystem

### Multiple-Choice Questions

1. **Which Python library serves as the underlying mathematical and multidimensional array engine for Scikit-Learn?**

* A) Pandas
* B) NumPy
* C) Matplotlib
* D) Requests

2. **In Scikit-Learn, what is the naming convention for learned model attributes (such as coefficients or cluster centers)?**

* A) They begin with an underscore (`_coefficient`)
* B) They end with an underscore (`.coef_`)
* C) They are uppercase strings (`COEF`)
* D) They require calling a getter method (`get_coef()`)

3. **What is the standard shape of a feature matrix ($X$) in Scikit-Learn?**

* A) `(n_features,)`
* B) `(n_samples, n_features)`
* C) `(n_features, n_samples, 2)`
* D) `(n_samples,)`

4. **Which method is used to train an estimator on training data?**

* A) `.transform()`
* B) `.predict()`
* C) `.fit()`
* D) `.evaluate()`

5. **Which object type represents algorithms that learn parameters directly from data within the Scikit-Learn architecture?**

* A) Transformers
* B) Estimators
* C) Pipelines
* D) Mutators

6. **What is the primary role of the `.transform()` method in a Scikit-Learn transformer object?**

* A) To compute model evaluation metrics like MSE or accuracy
* B) To modify an input feature matrix $X$ using parameters learned during `.fit()`
* C) To serialize model binary artifacts to disk
* D) To split datasets into training and testing folds

7. **Why does Scikit-Learn enforce strict 2D array layouts for feature matrices ($X$) instead of supporting arbitrary nested lists natively everywhere?**

* A) To ensure vectorized performance and consistent matrix multiplication via C-backed NumPy engines
* B) Because Python dictionaries cannot store floating-point numbers
* C) To restrict datasets to a maximum of 256 columns
* D) To automatically handle missing string values without imputers

---

### Conceptual & Coding Questions

8. **Code Fix:** A junior developer writes the following code to scale features before splitting data:

```python
scaler = StandardScaler()
X_scaled = scaler.fit_transform(df[['feature1', 'feature2']])
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)

```

*Identify the architectural flaw in this code and explain why it invalidates test metrics.*

9. **API Design Analysis:** Explain the computational advantage of calling `.fit_transform(X, y)` over executing `.fit(X, y)` followed by `.transform(X)` separately on identical training datasets.
10. **Debugging Challenge:** A data scientist inspects a custom linear model after training and attempts to print model coefficients using `print(model.coef)`. The execution crashes with an `AttributeError`. Correct the syntax and explain the underlying design pattern rationale.

---

## Module 2: Data Preprocessing & Feature Engineering

### Multiple-Choice Questions

11. **Why must transformers be fitted exclusively on the training split rather than the entire dataset?**

* A) To save memory on the test set
* B) To prevent data leakage and artificially inflated performance metrics
* C) Because `.fit()` fails when dataset rows exceed 1,000
* D) To ensure one-hot encoded columns sum to zero

12. **Which preprocessing transformer is best suited for replacing missing numeric values (`NaN`) with the median of a column?**

* A) `StandardScaler`
* B) `OneHotEncoder`
* C) `SimpleImputer(strategy='median')`
* D) `FunctionTransformer`

13. **When utilizing `OneHotEncoder` for categorical variables in production, which parameter configuration is critical to prevent errors when encountering unseen categories?**

* A) `drop='first'`
* B) `sparse_output=False`
* C) `handle_unknown='ignore'`
* D) `dtype=int`

14. **What is the primary mathematical effect of applying `StandardScaler` to a feature?**

* A) Bounds values strictly between 0 and 1
* B) Centers the mean to 0 and standard deviation to 1
* C) Converts negative numbers into absolute positive values
* D) Eliminates collinearity between features

15. **Which Scikit-Learn meta-estimator enables simultaneous, distinct preprocessing pathways for numeric versus categorical columns within a single pipeline?**

* A) `Pipeline`
* B) `ColumnTransformer`
* C) `FeatureUnion`
* D) `GridSearchCV`

16. **What is the consequence of omitting `handle_unknown='ignore'` in an `OneHotEncoder` when a production inference payload introduces a brand-new categorical string value?**

* A) The encoder automatically ignores the row without logging an error.
* B) A `ValueError` is raised, crashing the inference server.
* C) The unknown string is automatically imputed using the mode.
* D) The feature matrix shape expands dynamically to include a new column.

17. **Which scaling transformer bounds all continuous features to a precise, fixed range between $0$ and $1$?**

* A) `StandardScaler`
* B) `MinMaxScaler`
* C) `RobustScaler`
* D) `MaxAbsScaler`

---

### Conceptual & Coding Questions

18. **Pipeline Architecture:** Write a Python snippet utilizing `ColumnTransformer` and `Pipeline` that applies `SimpleImputer(strategy='median')` and `StandardScaler` to a numerical column `'age'`, and `SimpleImputer(strategy='constant', fill_value='Missing')` followed by `OneHotEncoder(handle_unknown='ignore')` to a categorical column `'city'`.
19. **Data Leakage Mitigation:** Describe an enterprise scenario where failing to isolate preprocessing transformations inside a cross-validation loop leads to catastrophic financial model deployment failure.
20. **Code Construction:** Construct a complete Scikit-Learn preprocessing pipeline that ingests a dataframe with columns `['income', 'credit_score', 'employment_type']`, imputes missing numerical values with the mean, standardizes them, imputes categorical text with `'Unknown'`, and applies one-hot encoding.

---

## Module 3: Supervised Learning — Regression

### Multiple-Choice Questions

21. **Which regression metric squares errors before averaging, heavily penalizing large outliers?**

* A) Mean Absolute Error (MAE)
* B) Mean Squared Error (MSE)
* C) R-Squared ($R^2$)
* D) Median Absolute Deviation

22. **How does Ridge Regression (L2 regularization) differ from Lasso Regression (L1 regularization)?**

* A) Ridge drives coefficients precisely to zero; Lasso shrinks them smoothly.
* B) Ridge shrinks coefficients smoothly toward zero; Lasso can drive irrelevant coefficients exactly to zero.
* C) Ridge only works on classification tasks; Lasso only works on regression.
* D) Ridge requires no hyperparameters; Lasso requires setting $K$.

23. **What is the primary purpose of ensembling multiple decision trees via a Random Forest Regressor?**

* A) To increase model bias and reduce training time
* B) To reduce variance by averaging predictions across randomized trees
* C) To eliminate the need for feature scaling
* D) To convert regression problems into classification tasks

24. **What does an $R^2$ score of $1.0$ indicate?**

* A) The model makes random guesses.
* B) The model explains 100% of the variance in the target variable.
* C) The model is suffering from severe data leakage.
* D) The mean squared error is equal to one.

25. **Which regularization penalty adds a term proportional to the absolute magnitude of coefficients ($\sum \vert{}w_j\vert{}$)?**

* A) L2 / Ridge
* B) L1 / Lasso
* C) Elastic Net
* D) Frobenius Norm

26. **Why do unconstrained, deep decision trees suffer from severe performance degradation on test datasets?**

* A) They underfit the training data by ignoring linear correlations.
* B) They memorize training anomalies and noise, resulting in high variance and overfitting.
* C) They require target vectors to be binary strings.
* D) They execute gradient descent updates too slowly.

27. **What optimization technique is typically used to solve Ordinary Least Squares regression when feature matrices are exceptionally large?**

* A) Singular Value Decomposition or gradient descent optimization
* B) Exhaustive grid search over all possible weight combinations
* C) Random Monte Carlo sampling
* D) DBSCAN density radius evaluation

---

### Conceptual & Coding Questions

28. **Regularization Mechanics:** Contrast how Ridge and Lasso behave when presented with a dataset containing 50 highly correlated features. Explain why Lasso tends to select only one feature from a correlated group while Ridge retains all of them.
29. **Coding Challenge:** Write a Python script using Scikit-Learn that trains a `Ridge` regression model with an alpha of `2.5` on synthetic data, evaluates its Mean Squared Error, and extracts its learned coefficient array.
30. **Bias-Variance Tradeoff:** Explain how increasing the number of estimators (`n_estimators`) in a `RandomForestRegressor` impacts model bias versus model variance.

---

## Module 4: Supervised Learning — Classification

### Multiple-Choice Questions

31. **Despite its name containing "regression," Logistic Regression is used for which type of machine learning problem?**

* A) Clustering
* B) Dimensionality Reduction
* C) Regression
* D) Classification

32. **Which evaluation metric measures the proportion of positive identifications that were actually correct ($TP / [TP + FP]$)?**

* A) Recall
* B) Accuracy
* C) Precision
* D) Specificity

33. **When dealing with a highly imbalanced dataset (e.g., 99% negative cases, 1% positive cases), why is raw Accuracy a misleading metric?**

* A) A naive model predicting all zeros achieves 99% accuracy while failing to capture any positive cases.
* B) Accuracy causes Logistic Regression convergence loops to crash.
* C) Accuracy calculation requires continuous target variables.
* D) Accuracy over-penalizes False Positives.

34. **What does the Area Under the ROC Curve (ROC-AUC) measure?**

* A) The exact threshold where accuracy is maximized
* B) The model's ability to rank positive instances higher than negative instances across all thresholds
* C) The total training time required for convergence
* D) The geometric margin between support vectors

35. **What mathematical function does Logistic Regression apply to linear combinations of features to output calibrated probabilities?**

* A) Rectified Linear Unit (ReLU)
* B) Sigmoid function
* C) Hyperbolic tangent (tanh)
* D) Softmax polynomial

36. **What is the primary function of the kernel trick in Support Vector Machines (SVMs)?**

* A) To scale numerical features between 0 and 1
* B) To implicitly project low-dimensional data into higher-dimensional spaces where linear separability is achieved
* C) To impute missing values using neighborhood means
* D) To prune unnecessary decision tree branches

37. **Which classification metric computes the harmonic mean of precision and recall?**

* A) F1-Score
* B) ROC-AUC
* C) Log Loss
* D) Matthews Correlation Coefficient

---

### Conceptual & Coding Questions

38. **Threshold Tuning:** A fraud detection classifier flags transactions with a default threshold of $0.5$, resulting in high false negatives. Explain how adjusting the decision threshold downward affects precision and recall.
39. **Coding Challenge:** Given binary true labels `y_true = [0, 1, 1, 0, 1]` and predicted probabilities `y_scores = [0.1, 0.7, 0.4, 0.3, 0.9]`, write a script using Scikit-Learn to compute the ROC-AUC score.
40. **Multiclass Strategy:** Describe how binary classifiers like Support Vector Machines can be extended to handle multi-class classification problems via One-vs-Rest (OvR) or One-vs-One (OvO) strategies.

---

## Module 5: Unsupervised Learning

### Multiple-Choice Questions

41. **What core structural assumption does K-Means clustering make regarding data clusters?**

* A) Clusters must be linear and unbounded.
* B) Clusters must be spherical and approximately equal in size and variance.
* C) Clusters can take any arbitrary geometric shape.
* D) Clusters must contain an identical number of samples.

42. **How does DBSCAN differ fundamentally from K-Means?**

* A) DBSCAN requires the user to pre-specify the exact number of clusters ($K$).
* B) DBSCAN groups points based on spatial density thresholds and automatically flags outliers as noise.
* C) DBSCAN only works on 1-dimensional datasets.
* D) DBSCAN is a supervised classification algorithm.

43. **What does the "explained variance ratio" represent in Principal Component Analysis (PCA)?**

* A) The percentage of missing values imputed during preprocessing
* B) The fraction of total historical variance accounted for by each principal component axis
* C) The classification error rate on the test set
* D) The ratio of training samples to features

44. **What metric evaluates clustering quality without requiring ground-truth target labels?**

* A) Silhouette Score
* B) F1-Score
* C) Mean Squared Error
* D) Confusion Matrix

45. **What is the purpose of the "Elbow Method" in K-Means clustering?**

* A) To determine the optimal number of clusters ($K$) by plotting inertia against cluster counts
* B) To find the optimal learning rate for gradient descent
* C) To identify corrupted feature columns containing missing values
* D) To calculate the geometric margin between decision boundaries

46. **How does DBSCAN handle data points that reside in low-density regions failing to meet neighborhood thresholds?**

* A) They are merged into a single overarching cluster.
* B) They are labeled as noise/outliers with an index of `-1`.
* C) They are automatically dropped from the input feature matrix prior to fitting.
* D) They are assigned to the nearest cluster centroid.

47. **What is the mathematical objective of Principal Component Analysis (PCA) during feature projection?**

* A) To minimize classification error across categorical targets
* B) To maximize the variance of projected data points along orthogonal principal axes
* C) To equalize the mean and variance of all input features
* D) To cluster rows into $K$ distinct geometric partitions

---

### Conceptual & Coding Questions

48. **Clustering Comparison:** Compare and contrast K-Means and DBSCAN when applied to a dataset containing concentric ring structures and varying cluster densities. Which algorithm succeeds and why?
49. **Coding Challenge:** Write a Python snippet utilizing `PCA` to reduce a 10-dimensional feature matrix down to 2 principal components, and print the resulting explained variance ratio.
50. **Unsupervised Evaluation:** Explain how the Silhouette Score measures cluster separation and cohesion, interpreting what a score close to $+1.0$ versus $-1.0$ signifies.

---

## Module 6: Model Evaluation, Tuning & Production

### Multiple-Choice Questions

51. **Why is `joblib` preferred over Python's native `pickle` module when saving Scikit-Learn models to disk?**

* A) `joblib` encrypts model files for security.
* B) `joblib` is heavily optimized for efficiently serializing large NumPy arrays commonly found in Scikit-Learn pipelines.
* C) `pickle` cannot save Python objects containing functions.
* D) `joblib` compresses models into executable `.exe` files automatically.

52. **What is the architectural danger of performing model retraining dynamically inside an online web server request cycle?**

* A) It causes high latency, blocking incoming user requests and threatening server stability.
* B) It automatically triggers data drift across test datasets.
* C) Web frameworks like FastAPI prohibit the use of `.fit()` methods.
* D) It converts classification models into regression estimators.

53. **When tuning hyperparameters inside a pipeline using `GridSearchCV`, how must dictionary keys be formatted if you want to target a parameter named `'n_estimators'` inside a step named `'model'`?**

* A) `{'n_estimators': [...]}`
* B) `{'model__n_estimators': [...]}`
* C) `{'model.n_estimators': [...]}`
* D) `{'step_model_n_estimators': [...]}`

54. **What is the primary execution advantage of `RandomizedSearchCV` over `GridSearchCV` when optimizing massive hyperparameter spaces?**

* A) It evaluates every possible combination exhaustively using parallel C threads.
* B) It samples a fixed, budgeted number of random parameter combinations from statistical distributions, drastically reducing execution time.
* C) It eliminates the need for cross-validation splits.
* D) It automatically performs feature engineering alongside tuning.

55. **During $k$-fold cross-validation, what happens to the dataset during each of the $k$ training iterations?**

* A) $1$ fold is used for training and $k-1$ folds are used for testing.
* B) $k-1$ folds are used for training and $1$ held-out fold is used for validation/testing.
* C) All $k$ folds are used simultaneously for training without validation.
* D) Data rows are randomly shuffled and downsampled by 50%.

56. **Why is native Python `pickle` suboptimal for saving large Scikit-Learn estimators?**

* A) It stores large NumPy arrays inefficiently as standard Python object hierarchies.
* B) It cannot serialize dictionaries.
* C) It lacks support for multi-threading.
* D) It automatically strips trailing underscores from learned model attributes.

57. **How does an asynchronous web framework like FastAPI handle incoming real-time inference requests when paired with a pre-loaded Scikit-Learn pipeline artifact?**

* A) By blocking all network ports until training loops finish executing
* B) By executing rapid `.predict()` calls in memory without re-running training routines or blocking server threads
* C) By converting incoming JSON payloads into Pandas DataFrames via distributed Spark clusters
* D) By serializing models back to disk on every request

---

### Conceptual & Coding Questions

58. **Pipeline Hyperparameter Tuning:** Explain why hyperparameter tuning must be encapsulated *inside* a cross-validation loop or pipeline rather than applied to pre-transformed data outside.
59. **Coding Challenge:** Write a complete Python script utilizing `GridSearchCV` to optimize the `C` parameter (`[0.1, 1.0, 10.0]`) for a `LogisticRegression` classifier using 3-fold cross-validation.
60. **Production Deployment Architecture:** Outline the architectural lifecycle of an enterprise machine learning service, from training notebook serialization via `joblib` to asynchronous FastAPI serving.

---

## Answer Keys & Explanations

### Module 1 Answers

1. **B** (NumPy provides the underlying multidimensional array structures).
2. **B** (Public learned attributes end with an underscore, e.g., `.coef_`).
3. **B** (`(n_samples, n_features)`).
4. **C** (`.fit()` trains estimators).
5. **B** (Estimators learn parameters from data).
6. **B** (`.transform()` modifies input feature matrices using parameters learned during `.fit()`).
7. **A** (2D array layouts ensure vectorized performance and consistent matrix multiplication via C-backed NumPy engines).
8. **Debug Explanation:** This code commits **data leakage**. Scaling the entire dataset before splitting causes statistics (mean/variance) from the test set to leak into the training normalization phase. **Fix:** Split data first, then fit the scaler exclusively on `X_train`.
9. **Explanation:** `.fit_transform(X, y)` runs both steps sequentially in a single pass, sharing internal memory buffers to avoid redundant allocation and calculation overhead.
10. **Correction & Explanation:** Change `model.coef` to `model.coef_`. Public learned attributes in Scikit-Learn always end with a trailing underscore to distinguish them from user-defined parameters.

---

### Module 2 Answers

11. **B** (Prevents data leakage and test optimism).
12. **C** (`SimpleImputer(strategy='median')`).
13. **C** (`handle_unknown='ignore'` prevents runtime crashes from unseen categories).
14. **B** (Centers mean to 0 and standard deviation to 1).
15. **B** (`ColumnTransformer` routes distinct subset columns to specialized preprocessing pipelines simultaneously).
16. **B** (A `ValueError` is raised, crashing the server).
17. **B** (`MinMaxScaler`).
18. **Code Solution:**

```python
preprocessor = ColumnTransformer([
    ('num', Pipeline([('imputer', SimpleImputer(strategy='median')), ('scaler', StandardScaler())]), ['age']),
    ('cat', Pipeline([('imputer', SimpleImputer(strategy='constant', fill_value='Missing')), ('onehot', OneHotEncoder(handle_unknown='ignore'))]), ['city'])
])

```

19. **Explanation:** If preprocessing parameters (like normalization means or target encodings) are computed across an entire unpartitioned dataset before splitting, information from the test fold leaks into training. This creates artificially inflated cross-validation metrics that collapse entirely upon live deployment.
20. **Code Solution:**

```python
num_pipe = Pipeline([('imputer', SimpleImputer(strategy='mean')), ('scaler', StandardScaler())])
cat_pipe = Pipeline([('imputer', SimpleImputer(strategy='constant', fill_value='Unknown')), ('onehot', OneHotEncoder(handle_unknown='ignore'))])
preprocessor = ColumnTransformer([
    ('num', num_pipe, ['income', 'credit_score']),
    ('cat', cat_pipe, ['employment_type'])
])

```

---

### Module 3 Answers

21. **B** (Mean Squared Error squares errors, heavily weighting large misses).
22. **B** (Ridge shrinks coefficients smoothly; Lasso can drive them to zero).
23. **B** (Random forests reduce variance by averaging predictions across bagged trees).
24. **B** ($R^2$ of 1.0 means the model explains 100% of target variance).
25. **B** (L1 / Lasso).
26. **B** (Deep trees memorize training anomalies and noise, resulting in high variance and overfitting).
27. **A** (Singular Value Decomposition or gradient descent optimization).
28. **Explanation:** Ridge penalizes squared weights, distributing coefficient values across correlated predictors. Lasso penalizes absolute magnitude, forcing coefficients of redundant features precisely to zero to select a single representative predictor.
29. **Code Solution:**

```python
import numpy as np
from sklearn.linear_model import Ridge
from sklearn.metrics import mean_squared_error

X = np.array([[1, 2], [2, 3], [3, 4], [4, 5]])
y = np.array([3, 5, 7, 9])
model = Ridge(alpha=2.5)
model.fit(X, y)
preds = model.predict(X)
print("MSE:", mean_squared_error(y, preds))
print("Coefficients:", model.coef_)

```

30. **Explanation:** Increasing `n_estimators` reduces model variance further by averaging a larger pool of randomized decision trees without increasing model bias.

---

### Module 4 Answers

31. **D** (Logistic Regression is a linear classification algorithm).
32. **C** (Precision measures true positives out of all positive predictions).
33. **A** (A naive zero-predictor achieves 99% accuracy on a 99/1 imbalanced dataset while failing completely).
34. **B** (ROC-AUC measures ranking capability across all classification thresholds).
35. **B** (Sigmoid function).
36. **B** (To implicitly project low-dimensional data into higher-dimensional spaces where linear separability is achieved).
37. **A** (F1-Score).
38. **Explanation:** Lowering the decision threshold flags more samples as positive, which increases recall (catching more true positives) at the expense of precision (increasing false positives).
39. **Code Solution:**

```python
import numpy as np
from sklearn.metrics import roc_auc_score

y_true = np.array([0, 1, 1, 0, 1])
y_scores = np.array([0.1, 0.7, 0.4, 0.3, 0.9])
print("ROC-AUC:", roc_auc_score(y_true, y_scores))

```

40. **Explanation:** OvR trains a separate binary classifier for each class against all others combined. OvO trains a binary classifier for every distinct pair of classes, combining their votes during inference.

---

### Module 5 Answers

41. **B** (K-Means assumes spherical clusters of roughly equal variance).
42. **B** (DBSCAN uses density thresholds and isolates noise/outliers).
43. **B** (Explained variance ratio measures historical variance captured per principal component axis).
44. **A** (Silhouette score evaluates cluster cohesion without ground truth labels).
45. **A** (To determine the optimal number of clusters $K$ by plotting inertia against cluster counts).
46. **B** (They are labeled as noise/outliers with an index of `-1`).
47. **B** (To maximize the variance of projected data points along orthogonal principal axes).
48. **Explanation:** K-Means fails on concentric rings and varying densities because it assumes spherical, uniform clusters. DBSCAN succeeds by evaluating spatial density connectivity, easily isolating complex shapes and noise.
49. **Code Solution:**

```python
import numpy as np
from sklearn.decomposition import PCA

X = np.random.rand(100, 10)
pca = PCA(n_components=2)
X_reduced = pca.fit_transform(X)
print("Explained Variance Ratio:", pca.explained_variance_ratio_)

```

50. **Explanation:** The Silhouette Score contrasts mean intra-cluster distance with mean nearest-cluster distance. A score near $+1.0$ indicates dense, well-separated clusters; a score near $-1.0$ indicates samples are assigned to incorrect clusters.

---

### Module 6 Answers

51. **B** (`joblib` is optimized for large NumPy arrays).
52. **A** (Training is compute-intensive and introduces high latency, blocking web servers).
53. **B** (`{'model__n_estimators': [...]}` uses double underscores to target named pipeline steps).
54. **B** (It samples a fixed, budgeted number of random parameter combinations from statistical distributions, drastically reducing execution time).
55. **B** ($k-1$ folds are used for training and $1$ held-out fold is used for validation/testing).
56. **A** (It stores large NumPy arrays inefficiently as standard Python object hierarchies).
57. **B** (By executing rapid `.predict()` calls in memory without re-running training routines or blocking server threads).
58. **Explanation:** If preprocessing or feature selection occurs outside cross-validation tuning, information leaks across splits. Encapsulating tuning inside a pipeline ensures transformations are re-fitted independently inside every single CV fold.
59. **Code Solution:**

```python
from sklearn.model_selection import GridSearchCV
from sklearn.linear_model import LogisticRegression

param_grid = {'C': [0.1, 1.0, 10.0]}
grid = GridSearchCV(LogisticRegression(random_state=42), param_grid, cv=3)
grid.fit(X_class, y_class)
print("Best Params:", grid.best_params_)

```

60. **Explanation:** Data is preprocessed and fitted inside a Scikit-Learn pipeline, serialized to disk using `joblib.dump()`, loaded into memory upon startup by an asynchronous server (like FastAPI), and invoked via stateless `.predict()` endpoints for instant sub-millisecond inference.
