## Appendix A: The Scikit-Learn API & Method Cheat Sheet

This reference manual maps out the core object methods, naming conventions, and interface rules across all Scikit-Learn estimators, transformers, and pipelines.

### 1. The Core Estimator Methods

Every object in Scikit-Learn adheres to a strict, predictable interface. Depending on whether an object is a transformer, a model, or a full pipeline, it implements a combination of the following core methods:

| Method | Applicable Object Type | Description |
| --- | --- | --- |
| `fit(X, y=1/0)` | Transformers, Models, Pipelines | Computes internal parameters (e.g., means, variances, weights) based on training data. Returns `self`. |
| `transform(X)` | Preprocessors, Transformers, Dimensionality Reduction | Applies learned parameters to transform input data $X$ into a modified representation. |
| `fit_transform(X, y=1/0)` | Transformers, Preprocessors | Optimized shorthand that calls `fit()` and `transform()` sequentially on the same dataset in a single pass. |
| `predict(X)` | Supervised Models, Pipelines | Applies learned rules to generate categorical class labels or continuous regression targets for input data $X$. |
| `predict_proba(X)` | Classification Models, Pipelines | Computes class membership probabilities for classification tasks (returns an array of shape `(n_samples, n_classes)`). |
| `score(X, y)` | Supervised Models, Pipelines | Computes the default evaluation metric for the model (e.g., Accuracy for classifiers, $R^2$ score for regressors). |

---

### 2. Common Parameter Conventions

Scikit-Learn maintains strict naming conventions across all classes:

* **Parameters (Hyperparameters):** Settings configured *before* training via the constructor (e.g., `n_estimators=100`, `max_depth=5`, `C=1.0`). These can be inspected or tuned using grid searches.
* **Attributes (Learned Parameters):** Internal parameters learned *during* training via `.fit()`. These are always suffixed with a trailing underscore (`_`) (e.g., `model.coef_`, `model.intercept_`, `scaler.mean_`, `imputer.statistics_`). Trying to access an attribute before calling `.fit()` will raise a `NotFittedError`.

---

### 3. Quick Code Reference: Inspecting Fitted Pipelines

When debugging complex pipelines, you can access individual named steps and inspect their fitted attributes using dictionary-style indexing:

```python
# Accessing a specific step inside a fitted pipeline
fitted_scaler = full_pipeline.named_steps['preprocessor'] \
                             .named_transformers_['num'] \
                             .named_steps['scaler']

# Inspecting learned means from the scaler
print("Learned Feature Means:", fitted_scaler.mean_)

```
