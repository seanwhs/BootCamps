# Scikit-Learn: Student Quiz & Test Bank

This test bank provides a rigorous collection of multiple-choice questions, conceptual short answers, and code-based debugging challenges spanning all six modules of the *Mastering Scikit-Learn* curriculum. Complete answer keys and explanations are provided at the end of each section.

---

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



### Conceptual & Coding Questions

5. **Code Fix:** A junior developer writes the following code to scale features before splitting data:
```python
scaler = StandardScaler()
X_scaled = scaler.fit_transform(df[['feature1', 'feature2']])
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2)

```


*Identify the architectural flaw in this code and explain why it invalidates test metrics.*

---

## Module 2: Data Preprocessing & Feature Engineering

### Multiple-Choice Questions

6. **Why must transformers be fitted exclusively on the training split rather than the entire dataset?**
* A) To save memory on the test set
* B) To prevent data leakage and artificially inflated performance metrics
* C) Because `.fit()` fails when dataset rows exceed 1,000
* D) To ensure one-hot encoded columns sum to zero


7. **Which preprocessing transformer is best suited for replacing missing numeric values (`NaN`) with the median of a column?**
* A) `StandardScaler`
* B) `OneHotEncoder`
* C) `SimpleImputer(strategy='median')`
* D) `FunctionTransformer`


8. **When utilizing `OneHotEncoder` for categorical variables in production, which parameter configuration is critical to prevent errors when encountering unseen categories?**
* A) `drop='first'`
* B) `sparse_output=False`
* C) `handle_unknown='ignore'`
* D) `dtype=int`


9. **What is the primary mathematical effect of applying `StandardScaler` to a feature?**
* A) Bounds values strictly between 0 and 1
* B) Centers the mean to 0 and standard deviation to 1
* C) Converts negative numbers into absolute positive values
* D) Eliminates collinearity between features



### Conceptual & Coding Questions

10. **Pipeline Architecture:** Write a Python snippet utilizing `ColumnTransformer` and `Pipeline` that applies `SimpleImputer(strategy='median')` and `StandardScaler` to a numerical column `'age'`, and `SimpleImputer(strategy='constant', fill_value='Missing')` followed by `OneHotEncoder(handle_unknown='ignore')` to a categorical column `'city'`.

---

## Module 3: Supervised Learning — Regression

### Multiple-Choice Questions

11. **Which regression metric squares errors before averaging, heavily penalizing large outliers?**
* A) Mean Absolute Error (MAE)
* B) Mean Squared Error (MSE)
* C) R-Squared ($R^2$)
* D) Median Absolute Deviation


12. **How does Ridge Regression (L2 regularization) differ from Lasso Regression (L1 regularization)?**
* A) Ridge drives coefficients precisely to zero; Lasso shrinks them smoothly.
* B) Ridge shrinks coefficients smoothly toward zero; Lasso can drive irrelevant coefficients exactly to zero.
* C) Ridge only works on classification tasks; Lasso only works on regression.
* D) Ridge requires no hyperparameters; Lasso requires setting $K$.


13. **What is the primary purpose of ensembling multiple decision trees via a Random Forest Regressor?**
* A) To increase model bias and reduce training time
* B) To reduce variance by averaging predictions across randomized trees
* C) To eliminate the need for feature scaling
* D) To convert regression problems into classification tasks


14. **What does an $R^2$ score of $1.0$ indicate?**
* A) The model makes random guesses.
* B) The model explains 100% of the variance in the target variable.
* C) The model is suffering from severe data leakage.
* D) The mean squared error is equal to one.



---

## Module 4: Supervised Learning — Classification

### Multiple-Choice Questions

15. **Despite its name, Logistic Regression is used for which type of machine learning problem?**
* A) Clustering
* B) Dimensionality Reduction
* C) Regression
* D) Classification


16. **Which evaluation metric measures the proportion of positive identifications that were actually correct ($TP / [TP + FP]$)?**
* A) Recall
* B) Accuracy
* C) Precision
* D) Specificity


17. **When dealing with a highly imbalanced dataset (e.g., 99% negative cases, 1% positive cases), why is raw Accuracy a misleading metric?**
* A) A naive model predicting all zeros achieves 99% accuracy while failing to capture any positive cases.
* B) Accuracy causes Logistic Regression convergence loops to crash.
* C) Accuracy calculation requires continuous target variables.
* D) Accuracy over-penalizes False Positives.


18. **What does the Area Under the ROC Curve (ROC-AUC) measure?**
* A) The exact threshold where accuracy is maximized
* B) The model's ability to rank positive instances higher than negative instances across all thresholds
* C) The total training time required for convergence
* D) The geometric margin between support vectors



---

## Module 5: Unsupervised Learning

### Multiple-Choice Questions

19. **What core structural assumption does K-Means clustering make regarding data clusters?**
* A) Clusters must be linear and unbounded.
* B) Clusters must be spherical and approximately equal in size and variance.
* C) Clusters can take any arbitrary geometric shape.
* D) Clusters must contain an identical number of samples.


20. **How does DBSCAN differ fundamentally from K-Means?**
* A) DBSCAN requires the user to pre-specify the exact number of clusters ($K$).
* B) DBSCAN groups points based on spatial density thresholds and automatically flags outliers as noise.
* C) DBSCAN only works on 1-dimensional datasets.
* D) DBSCAN is a supervised classification algorithm.


21. **What does the "explained variance ratio" represent in Principal Component Analysis (PCA)?**
* A) The percentage of missing values imputed during preprocessing
* B) The fraction of total historical variance accounted for by each principal component axis
* C) The classification error rate on the test set
* D) The ratio of training samples to features


22. **What metric evaluates clustering quality without requiring ground-truth target labels?**
* A) Silhouette Score
* B) F1-Score
* C) Mean Squared Error
* D) Confusion Matrix



---

## Module 6: Model Evaluation, Tuning & Production

### Multiple-Choice Questions

23. **Why is `joblib` preferred over Python's native `pickle` module when saving Scikit-Learn models to disk?**
* A) `joblib` encrypts model files for security.
* B) `joblib` is heavily optimized for efficiently serializing large NumPy arrays commonly found in Scikit-Learn pipelines.
* C) `pickle` cannot save Python objects containing functions.
* D) `joblib` compresses models into executable `.exe` files automatically.


24. **What is the architectural danger of performing model retraining dynamically inside an online web server request cycle?**
* A) It causes high latency, blocking incoming user requests and threatening server stability.
* B) It automatically triggers data drift across test datasets.
* C) Web frameworks like FastAPI prohibit the use of `.fit()` methods.
* D) It converts classification models into regression estimators.


25. **When tuning hyperparameters inside a pipeline using `GridSearchCV`, how must dictionary keys be formatted if you want to target a parameter named `'n_estimators'` inside a step named `'model'`?**
* A) `{'n_estimators': [...]}`
* B) `{'model__n_estimators': [...]}`
* C) `{'model.n_estimators': [...]}`
* D) `{'step_model_n_estimators': [...]}`



---

## Answer Keys & Explanations

### Module 1 Answers

1. **B** (NumPy provides the underlying multidimensional array structures).
2. **B** (Public learned attributes end with an underscore, e.g., `.coef_`).
3. **B** (`(n_samples, n_features)`).
4. **C** (`.fit()` trains estimators).
5. **Debug Explanation:** This code commits **data leakage**. Scaling the entire dataset before splitting causes statistics (mean/variance) from the test set to leak into the training normalization phase. **Fix:** Split data first, then fit the scaler exclusively on `X_train`.

### Module 2 Answers

6. **B** (Prevents data leakage and test optimism).
7. **C** (`SimpleImputer(strategy='median')`).
8. **C** (`handle_unknown='ignore'` prevents runtime crashes from unseen categories).
9. **B** (Centers mean to 0 and standard deviation to 1).
10. **Code Solution:**
```python
preprocessor = ColumnTransformer([
    ('num', Pipeline([('imputer', SimpleImputer(strategy='median')), ('scaler', StandardScaler())]), ['age']),
    ('cat', Pipeline([('imputer', SimpleImputer(strategy='constant', fill_value='Missing')), ('onehot', OneHotEncoder(handle_unknown='ignore'))]), ['city'])
])

```



### Module 3 Answers

11. **B** (Mean Squared Error squares errors, heavily weighting large misses).
12. **B** (Ridge shrinks coefficients smoothly; Lasso can drive them to zero).
13. **B** (Random forests reduce variance by averaging predictions across bagged trees).
14. **B** ($R^2$ of 1.0 means the model explains 100% of target variance).

### Module 4 Answers

15. **D** (Logistic Regression is a linear classification algorithm).
16. **C** (Precision measures true positives out of all positive predictions).
17. **A** (A naive zero-predictor achieves 99% accuracy on a 99/1 imbalanced dataset while failing completely).
18. **B** (ROC-AUC measures ranking capability across all classification thresholds).

### Module 5 Answers

19. **B** (K-Means assumes spherical clusters of roughly equal variance).
20. **B** (DBSCAN uses density thresholds and isolates noise/outliers).
21. **B** (Explained variance ratio measures historical variance captured per principal component axis).
22. **A** (Silhouette score evaluates cluster cohesion without ground truth labels).

### Module 6 Answers

23. **B** (`joblib` is optimized for large NumPy arrays).
24. **A** (Training is compute-intensive and introduces high latency, blocking web servers).
25. **B** (`{'model__n_estimators': [...]}` uses double underscores to target named pipeline steps).
