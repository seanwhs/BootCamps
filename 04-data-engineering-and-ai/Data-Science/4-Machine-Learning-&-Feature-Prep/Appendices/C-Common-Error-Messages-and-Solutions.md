# Appendix C: Common Error Messages and Solutions

## Data-Related Errors

### File I/O Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `FileNotFoundError: [Errno 2] No such file or directory: 'data/raw/file.csv'` | File path incorrect or file missing | Check file path; use absolute paths or ensure relative paths are correct from project root |
| `PermissionError: [Errno 13] Permission denied` | Insufficient file permissions | Check file permissions; run with appropriate privileges |
| `UnicodeDecodeError: 'utf-8' codec can't decode byte...` | File encoding mismatch | Specify correct encoding: `pd.read_csv(file, encoding='latin-1')` |
| `pd.errors.EmptyDataError: No columns to parse from file` | File is empty | Check file content; ensure data exists |

### DataFrame Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `KeyError: 'column_name'` | Column doesn't exist | Check column name spelling; use `df.columns` to see available columns |
| `ValueError: could not convert string to float` | Non-numeric values in numeric column | Clean data; check for special characters; use `pd.to_numeric(errors='coerce')` |
| `TypeError: object of type '...' has no len()` | Wrong data type | Convert to appropriate type: `df = pd.DataFrame(data)` |
| `MemoryError: Unable to allocate ...` | Data too large for memory | Use chunking; sample data; use dtypes to reduce memory |
| `SettingWithCopyWarning` | Modifying a slice of a DataFrame | Use `.copy()` or `.loc` for modifications |

### Missing Value Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: Input contains NaN, infinity or a value too large` | Missing or infinite values | Handle missing values: `df.fillna()` or `df.dropna()` |
| `RuntimeWarning: invalid value encountered in ...` | NaN values in calculation | Check for NaN; use `np.nan_to_num()` or `df.replace()` |
| `ValueError: Cannot use mean strategy with non-numeric data` | Imputation on wrong data type | Use appropriate strategy for data type; convert to numeric first |

---

## Preprocessing Errors

### Imputation Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: The strategy 'custom' is not supported` | Unknown imputation strategy | Use valid strategy: 'mean', 'median', 'mode', 'constant', 'knn', 'mice' |
| `ValueError: The fill_value must be a string for strategy 'constant'` | Wrong fill_value type | Provide appropriate fill_value for data type |
| `ImportError: No module named 'sklearn.impute'` | Missing scikit-learn | Install: `pip install scikit-learn` |

### Scaling Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: The input contains NaN values` | Missing values before scaling | Impute missing values before scaling |
| `ValueError: X has 0 features, but ...` | Empty feature matrix | Check data shape; ensure features exist |
| `ValueError: Incompatible dimensions` | Shape mismatch | Ensure consistent input dimensions |

### Encoding Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: y should be a 1d array` | Target shape incorrect | Flatten target: `y.ravel()` or `y.flatten()` |
| `ValueError: Unknown category 'value' in column` | Unseen category in transform | Use `handle_unknown='ignore'` in encoder |
| `TypeError: unhashable type: 'numpy.ndarray'` | Wrong data type for mapping | Convert to list or Series: `pd.Series(values)` |

---

## Feature Engineering Errors

### Feature Creation Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ZeroDivisionError: division by zero` | Creating ratio with zero denominator | Handle division by zero: `df[col1] / df[col2].replace(0, np.nan)` |
| `ValueError: Cannot set a DataFrame with multiple columns` | Incorrect DataFrame concatenation | Use `pd.concat()` with correct axis |
| `MemoryError: Unable to allocate ...` | Too many polynomial features | Reduce degree; use feature selection; limit interactions |

### Feature Selection Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: n_features to select must be less than or equal to n_features` | Too many features requested | Reduce n_features; check total feature count |
| `ValueError: estimator must be fitted` | Feature importance before fitting | Fit estimator first: `estimator.fit(X, y)` |
| `ValueError: The threshold must be positive` | Invalid threshold | Use positive threshold or 'mean', 'median' |

### Dimensionality Reduction Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: n_components must be between 0 and min(n_samples, n_features)` | Too many components requested | Reduce n_components; check data dimensions |
| `ValueError: Perplexity must be less than n_samples` | t-SNE perplexity too high | Reduce perplexity: `perplexity < n_samples` |
| `ImportError: No module named 'umap'` | UMAP not installed | Install: `pip install umap-learn` |

### Imbalance Handling Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: The number of classes has to be greater than one` | Only one class in target | Check target distribution; handle edge case |
| `ImportError: No module named 'imblearn'` | imbalanced-learn not installed | Install: `pip install imbalanced-learn` |
| `ValueError: Sampling strategy 'auto' only works for binary classification` | Auto strategy with multi-class | Specify sampling strategy explicitly |

---

## Model Training Errors

### Tree-Based Model Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ImportError: No module named 'xgboost'` | XGBoost not installed | Install: `pip install xgboost` |
| `ValueError: feature_names mismatch` | Feature names differ | Ensure consistent feature names; use DataFrame for consistency |
| `ValueError: Tree must be trained before using this method` | Predict before fitting | Call `.fit()` first |
| `XGBoostError: [07:30:45] WARNING: ...` | XGBoost training warning | Usually benign; check for convergence issues |

### Deep Learning Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `RuntimeError: CUDA out of memory` | GPU memory exhausted | Reduce batch size; use gradient accumulation; switch to CPU |
| `RuntimeError: Expected object of scalar type Float but got ...` | Data type mismatch | Ensure consistent data types: `.float()`, `.long()` |
| `RuntimeError: dimension mismatch` | Tensor shape mismatch | Check input dimensions; ensure data is properly shaped |
| `ValueError: The size of tensor a (n) must match the size of tensor b (m)` | Incompatible tensor shapes | Check layer dimensions; debug with `.shape` |
| `RuntimeError: one of the variables needed for gradient computation has been modified` | In-place operation issue | Avoid in-place operations: use `x = x + 1` not `x += 1` |
| `RuntimeError: Input type (torch.FloatTensor) and weight type (torch.cuda.FloatTensor)` | CPU/GPU mismatch | Move data to same device: `data = data.to(device)` |

### Clustering Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: n_clusters must be <= n_samples` | Too many clusters for data | Reduce n_clusters |
| `ValueError: eps cannot be None` | DBSCAN eps not set | Set eps value or use auto-detection |
| `ValueError: Silhouette score is only defined if number of labels is 2 <= n_labels <= n_samples - 1` | Too few/many clusters | Adjust number of clusters |

---

## Validation and Evaluation Errors

### Cross-Validation Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: The least populated class in y has only 1 member` | Stratified split impossible | Use KFold instead of StratifiedKFold; increase data |
| `ValueError: n_splits=10 cannot be greater than the number of members in each class` | Too many folds for class size | Reduce n_splits |
| `ValueError: groups must be specified for GroupKFold` | Missing groups | Provide groups parameter |

### Metric Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: Classification metrics can't handle a mix of binary and continuous targets` | Wrong metric for problem type | Use appropriate metric: accuracy for classification, MSE for regression |
| `ValueError: Unknown label type: 'unknown'` | Unsupported target type | Convert target to appropriate type |
| `UndefinedMetricWarning: Precision is ill-defined and being set to 0.0` | No predicted samples in class | Check class imbalance; use weighted metrics |
| `ValueError: ROC-AUC only supports binary classification` | Multi-class with ROC-AUC | Use `multi_class='ovr'` or use AUC for each class |

### Hyperparameter Tuning Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ValueError: The parameter 'n_estimators' is not a valid parameter for this estimator` | Wrong parameter name | Check model parameter names: `model.get_params().keys()` |
| `ValueError: n_iter cannot be greater than total parameter combinations` | Too many iterations | Reduce n_iter or expand param grid |
| `RuntimeError: Optuna: Trial failed` | Trial execution error | Check objective function; increase verbosity for debugging |
| `ValueError: objective function must return a float` | Wrong return type | Ensure objective returns float score |

---

## Pipeline Errors

### Pipeline Construction Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `NotFittedError: This ... instance is not fitted yet` | Called transform before fit | Call `.fit()` or `.fit_transform()` first |
| `AttributeError: 'NoneType' object has no attribute 'transform'` | Component not initialized | Initialize component before use; check pipeline steps |
| `ValueError: All the input arrays must have same number of dimensions` | Inconsistent data shapes | Check data shapes; ensure consistent preprocessing |
| `TypeError: fit() missing 1 required positional argument: 'y'` | Missing target | Provide target for supervised methods |

### Pipeline Persistence Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `ModuleNotFoundError: No module named 'sklearn.preprocessing._encoders'` | Version mismatch | Save and load with same library versions |
| `AttributeError: Can't get attribute '...' on <module '...'` | Custom class not importable | Ensure custom classes are defined and importable |
| `ValueError: Buffer dtype mismatch` | Array serialization issue | Use joblib with proper version |

---

## API and Deployment Errors

### FastAPI Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `HTTP 404: Not Found` | Endpoint doesn't exist | Check URL; check route definitions |
| `HTTP 422: Unprocessable Entity` | Invalid request format | Check request body schema; ensure all required fields present |
| `HTTP 500: Internal Server Error` | Unhandled exception in endpoint | Check logs; add error handling; ensure model is loaded |
| `AttributeError: 'NoneType' object has no attribute 'predict'` | Model not loaded | Ensure model loads on startup; check model path |

### Docker Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `Error response from daemon: Conflict` | Container name already exists | Stop/remove existing container: `docker rm -f container_name` |
| `Error response from daemon: driver failed programming external connectivity` | Port already in use | Change host port mapping; stop conflicting service |
| `ERROR: Could not install packages due to an OSError: [Errno 28] No space left on device` | Docker image too large | Clean Docker cache: `docker system prune` |
| `Dockerfile: no matching manifest for linux/arm64` | Architecture mismatch | Use appropriate base image; build with `--platform` |

---

## Environment and Setup Errors

### Virtual Environment Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `Command 'python' not found` | Python not installed | Install Python; check PATH |
| `ModuleNotFoundError: No module named '...'` | Package not installed | Activate virtual env; install package |
| `ImportError: cannot import name '...' from '...'` | Version mismatch | Check package version; update/downgrade |
| `ValueError: Unable to configure logger 'loguru'` | Loguru configuration issue | Check log file permissions; ensure directories exist |

### CUDA/GPU Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `RuntimeError: CUDA error: no kernel image is available` | PyTorch not CUDA-enabled | Install PyTorch with CUDA support |
| `RuntimeError: CUDA error: out of memory` | GPU memory exhausted | Reduce batch size; use CPU fallback |
| `AssertionError: Torch not compiled with CUDA enabled` | PyTorch CPU-only version | Reinstall PyTorch with CUDA support |
| `RuntimeError: CUDA driver version is insufficient` | Driver too old | Update NVIDIA driver |

---

## Quick Debugging Checklist

### Step 1: Check the Data
```python
# Print basic info
print(df.shape)
print(df.info())
print(df.head())
print(df.isnull().sum())

# Check data types
print(df.dtypes)

# Check target distribution
print(df['target'].value_counts())
```

### Step 2: Check the Code Path
```python
# Ensure module imports work
import sys
print(sys.path)

# Check current working directory
import os
print(os.getcwd())

# List files in current directory
print(os.listdir('.'))
```

### Step 3: Check the Environment
```bash
# Check Python version
python --version

# Check installed packages
pip list

# Check conda environment
conda info --envs

# Check CUDA availability
python -c "import torch; print(torch.cuda.is_available())"
```

### Step 4: Check Logs
```python
from loguru import logger

# Add debug level
logger.add("debug.log", level="DEBUG")

# Add traceback
import traceback
traceback.print_exc()
```

### Step 5: Check Model State
```python
# Check if model is fitted
print(hasattr(model, '_is_fitted'))
print(model.__dict__.keys())

# Check feature names
if hasattr(model, 'feature_names_'):
    print(model.feature_names_)
```

---

## Error Prevention Best Practices

### Always Validate Inputs
```python
def validate_input(X, y):
    """Validate inputs before processing."""
    if X is None or len(X) == 0:
        raise ValueError("X cannot be None or empty")
    if y is None or len(y) == 0:
        raise ValueError("y cannot be None or empty")
    if len(X) != len(y):
        raise ValueError("X and y must have same length")
    return True
```

### Use Try-Except Blocks
```python
try:
    result = pipeline.fit_transform(X, y)
except Exception as e:
    logger.error(f"Pipeline failed: {str(e)}")
    logger.error(traceback.format_exc())
    raise
```

### Check for Missing Values
```python
def check_missing(df):
    """Check for missing values and raise error."""
    missing = df.isnull().sum()
    if missing.sum() > 0:
        logger.warning(f"Missing values detected: {missing[missing > 0]}")
    return missing.sum() == 0
```

### Validate Shapes
```python
def check_shapes(X, y):
    """Validate input shapes."""
    if X.shape[0] != y.shape[0]:
        raise ValueError(f"Shape mismatch: X {X.shape[0]} vs y {y.shape[0]}")
    return True
```

### Use Assertions for Debugging
```python
def process_data(X):
    """Process data with assertions."""
    assert X is not None, "X cannot be None"
    assert len(X) > 0, "X cannot be empty"
    assert X.shape[1] > 0, "X must have at least one feature"
    # Process data...
    return result
```

---

This appendix serves as a comprehensive troubleshooting guide for common errors encountered throughout the series. Bookmark this page for quick reference when debugging your code.
