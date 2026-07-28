## Appendix A: The Scikit-Learn API, Method Signatures & Deep Architecture Master Reference

This comprehensive reference manual maps out the core object methods, architectural naming conventions, design patterns, and interface rules across all Scikit-Learn estimators, transformers, and pipelines.

---

### 1. The Core Estimator Methods & Deep Signature Taxonomy

Every object in Scikit-Learn adheres to a strict, predictable interface. Depending on whether an object is a transformer, a model, or a full pipeline, it implements a combination of the following core methods:

| Method | Applicable Object Type | Detailed Signature & Description |
| --- | --- | --- |
| `fit(X, y=None, **fit_params)` | Transformers, Models, Pipelines | Computes internal parameters (e.g., means, variances, weights) based on training data $X$ and optional target vector $y$. Always returns `self` to enable method chaining.

 |
| `transform(X)` | Preprocessors, Transformers, Dimensionality Reduction | Applies learned internal parameters to transform input data $X$ into a modified, scaled, or projected representation.

 |
| `fit_transform(X, y=None, **fit_params)` | Transformers, Preprocessors | Optimized shorthand method that calls `fit()` and `transform()` sequentially on the same dataset in a single highly efficient pass.

 |
| `predict(X)` | Supervised Models, Pipelines | Applies learned mathematical rules to generate categorical class labels or continuous regression targets for input data $X$.

 |
| `predict_proba(X)` | Classification Models, Pipelines | Computes class membership probabilities for classification tasks. Returns a 2D NumPy array of shape `(n_samples, n_classes)` representing likelihood distributions.

 |
| `predict_log_proba(X)` | Classification Models, Pipelines | Computes the natural logarithm of class probabilities, often used for numerical stability in advanced probabilistic modeling. |
| `decision_function(X)` | Linear & Kernel Models, Support Vector Machines | Computes confidence scores or distance metrics relative to the separating hyperplane for each class.

 |
| `score(X, y)` | Supervised Models, Pipelines | Computes the default evaluation metric for the model (e.g., Mean Accuracy for classifiers, Coefficient of Determination $R^2$ score for regressors).

 |
| `get_params(deep=True)` | All Estimators | Retrieves a dictionary of all constructor parameters (hyperparameters) and their current assigned values for meta-estimators and grid search optimization. |
| `set_params(**params)` | All Estimators | Safely updates the hyperparameters of an estimator or pipeline step post-instantiation, returning `self` for fluent configuration. |

---

### 2. Advanced Parameter Conventions & Attribute Life Cycles

Scikit-Learn maintains strict architectural naming conventions across all classes to differentiate static user choices from dynamically learned artifacts:

* **Parameters (Hyperparameters):** Settings configured *before* training via the class constructor (e.g., `n_estimators=100`, `max_depth=5`, `C=1.0`, `penalty='l2'`). These remain constant during `.fit()` and can be inspected or tuned using grid searches or randomized parameter optimizations.


* **Attributes (Learned Parameters):** Internal parameters learned *exclusively* during training via the execution of `.fit()`. These are always suffixed with a mandatory trailing underscore (`_`) (e.g., `model.coef_`, `model.intercept_`, `scaler.mean_`, `imputer.statistics_`, `pca.components_`). Trying to access any learned attribute before calling `.fit()` will immediately raise a `NotFittedError`.



---

### 3. Quick Code Reference: Inspecting Fitted Pipelines & Complex Sub-Objects

When debugging complex production pipelines, accessing individual named steps and inspecting their nested fitted attributes requires precise dictionary-style navigation:

```python
# Accessing a specific nested step inside a compound fitted pipeline
fitted_scaler = full_pipeline.named_steps['preprocessor'] \
                             .named_transformers_['num'] \
                             .named_steps['scaler']

# Inspecting learned empirical feature means from the deeply nested scaler
print("Learned Feature Means:", fitted_scaler.mean_)

# Inspecting feature importances from a fitted Random Forest model step
rf_model = full_pipeline.named_steps['model']
print("Feature Importances:", rf_model.feature_importances_)

```

---

### 4. Custom Transformer Design Pattern & Meta-Estimator Extension

To seamlessly integrate custom preprocessing logic into Scikit-Learn pipelines, inherit from `BaseEstimator` and `TransformerMixin` to automatically inherit `.fit()`, `.fit_transform()`, and pipeline compatibility:

```python
from sklearn.base import BaseEstimator, TransformerMixin
import numpy as np

class OutlierCapper(BaseEstimator, TransformerMixin):
    """Custom transformer to cap extreme outliers based on training percentiles."""
    def __init__(self, lower_quantile=0.05, upper_quantile=0.95):
        self.lower_quantile = lower_quantile
        self.upper_quantile = upper_quantile
        
    def fit(self, X, y=None):
        X_arr = np.asarray(X)
        self.lower_bounds_ = np.percentile(X_arr, self.lower_quantile * 100, axis=0)
        self.upper_bounds_ = np.percentile(X_arr, self.upper_quantile * 100, axis=0)
        return self
        
    def transform(self, X):
        X_arr = np.asarray(X)
        return np.clip(X_arr, self.lower_bounds_, self.upper_bounds_)

```
