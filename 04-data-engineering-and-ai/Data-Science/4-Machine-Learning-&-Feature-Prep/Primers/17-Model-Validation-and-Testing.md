# Primer 17: Model Validation and Testing

## Overview

This primer provides a comprehensive guide to model validation and testing—the systematic process of evaluating model performance, robustness, and reliability before deployment. Understanding these concepts is essential for building models that generalize well and perform reliably in production.

---

## 1. The Validation and Testing Framework

### The Validation Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                    VALIDATION HIERARCHY                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Unit Tests                                                     │
│  └── Test individual components in isolation                   │
│      • Data transformations                                    │
│      • Feature engineering                                     │
│      • Model functions                                         │
│                                                                 │
│  Integration Tests                                              │
│  └── Test component interactions                              │
│      • Pipeline end-to-end                                     │
│      • API endpoints                                           │
│      • Data flow                                              │
│                                                                 │
│  Model Validation                                               │
│  └── Test model performance                                   │
│      • Cross-validation                                        │
│      • Hold-out testing                                        │
│      • Performance metrics                                     │
│                                                                 │
│  System Tests                                                   │
│  └── Test in production-like environment                      │
│      • Performance testing                                     │
│      • Load testing                                            │
│      • Security testing                                        │
│                                                                 │
│  User Acceptance Testing                                        │
│  └── Test with stakeholders                                   │
│      • Business requirements                                   │
│      • User experience                                         │
│      • Domain validation                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Validation vs Testing

```
┌─────────────────────────────────────────────────────────────────┐
│                    VALIDATION VS TESTING                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Validation                                                    │
│  └── "Are we building the right model?"                       │
│      • Business requirements                                   │
│      • Stakeholder needs                                       │
│      • Domain expertise                                        │
│      • Interpretability                                        │
│                                                                 │
│  Testing                                                       │
│  └── "Are we building the model right?"                       │
│      • Correctness                                             │
│      • Performance                                             │
│      • Robustness                                              │
│      • Security                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Unit Testing for ML

### Testing Data Transformations

```python
import unittest
import pandas as pd
import numpy as np
from src.data.ingestion import DataIngestor
from src.preprocessing.scaling import FeatureScaler

class TestDataTransformation(unittest.TestCase):
    """Test data transformation functions."""
    
    def setUp(self):
        """Set up test data."""
        self.df = pd.DataFrame({
            'feature1': [1, 2, 3, 4, 5],
            'feature2': [10, 20, 30, 40, 50],
            'category': ['A', 'B', 'A', 'B', 'C']
        })
    
    def test_scaling(self):
        """Test scaling transformation."""
        scaler = FeatureScaler(strategy='standard')
        X_scaled = scaler.fit_transform(self.df[['feature1', 'feature2']])
        
        # Check shape
        self.assertEqual(X_scaled.shape, (5, 2))
        
        # Check mean (should be ~0)
        self.assertAlmostEqual(X_scaled.mean(), 0, places=2)
        
        # Check std (should be ~1)
        self.assertAlmostEqual(X_scaled.std(), 1, places=2)
    
    def test_missing_value_handling(self):
        """Test missing value handling."""
        df_with_na = self.df.copy()
        df_with_na.loc[0, 'feature1'] = np.nan
        
        from src.preprocessing.imputation import MissingValueImputer
        imputer = MissingValueImputer()
        df_imputed = imputer.impute(df_with_na, numeric_strategy='median')
        
        self.assertFalse(df_imputed['feature1'].isnull().any())
    
    def test_categorical_encoding(self):
        """Test categorical encoding."""
        from src.features.encoding import CategoricalEncoder
        encoder = CategoricalEncoder(strategy='one_hot')
        X_encoded = encoder.fit_transform(self.df[['category']])
        
        # Check that categories were encoded
        self.assertTrue('category_A' in X_encoded.columns)
        self.assertTrue('category_B' in X_encoded.columns)
        self.assertTrue('category_C' in X_encoded.columns)

# Run tests
unittest.main()
```

### Testing Model Functions

```python
class TestModelFunctions(unittest.TestCase):
    """Test model functions."""
    
    def setUp(self):
        """Set up test data."""
        from sklearn.datasets import make_classification
        from sklearn.model_selection import train_test_split
        
        X, y = make_classification(n_samples=100, n_features=10, random_state=42)
        self.X_train, self.X_test, self.y_train, self.y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
    
    def test_model_training(self):
        """Test model training."""
        from sklearn.ensemble import RandomForestClassifier
        
        model = RandomForestClassifier(n_estimators=10, random_state=42)
        model.fit(self.X_train, self.y_train)
        
        # Check that model has been fitted
        self.assertTrue(hasattr(model, 'feature_importances_'))
        
        # Check predictions shape
        y_pred = model.predict(self.X_test)
        self.assertEqual(len(y_pred), len(self.y_test))
    
    def test_prediction_pipeline(self):
        """Test full prediction pipeline."""
        from sklearn.pipeline import Pipeline
        from sklearn.preprocessing import StandardScaler
        from sklearn.ensemble import RandomForestClassifier
        
        pipeline = Pipeline([
            ('scaler', StandardScaler()),
            ('classifier', RandomForestClassifier(n_estimators=10, random_state=42))
        ])
        
        pipeline.fit(self.X_train, self.y_train)
        y_pred = pipeline.predict(self.X_test)
        
        self.assertEqual(len(y_pred), len(self.y_test))
        self.assertTrue(pipeline.score(self.X_test, self.y_test) > 0.5)
    
    def test_model_robustness(self):
        """Test model robustness to input variations."""
        from sklearn.ensemble import RandomForestClassifier
        
        model = RandomForestClassifier(n_estimators=10, random_state=42)
        model.fit(self.X_train, self.y_train)
        
        # Test with slight noise
        X_test_noisy = self.X_test + np.random.normal(0, 0.1, self.X_test.shape)
        y_pred_original = model.predict(self.X_test)
        y_pred_noisy = model.predict(X_test_noisy)
        
        # Predictions shouldn't change too much with small noise
        diff_rate = np.mean(y_pred_original != y_pred_noisy)
        self.assertLess(diff_rate, 0.2)
```

---

## 3. Integration Testing

### Pipeline Testing

```python
import unittest
import pandas as pd
import numpy as np
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier

class TestMLPipeline(unittest.TestCase):
    """Test the complete ML pipeline."""
    
    def setUp(self):
        """Set up test data."""
        from sklearn.datasets import make_classification
        X, y = make_classification(n_samples=100, n_features=10, random_state=42)
        self.X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])
        self.y = pd.Series(y, name='target')
    
    def test_pipeline_end_to_end(self):
        """Test end-to-end pipeline."""
        # Build pipeline
        pipeline = Pipeline([
            ('scaler', StandardScaler()),
            ('classifier', RandomForestClassifier(n_estimators=10, random_state=42))
        ])
        
        # Train
        pipeline.fit(self.X, self.y)
        
        # Predict
        y_pred = pipeline.predict(self.X)
        
        # Check shape
        self.assertEqual(len(y_pred), len(self.y))
        
        # Check score
        score = pipeline.score(self.X, self.y)
        self.assertGreater(score, 0.5)
    
    def test_pipeline_with_missing_values(self):
        """Test pipeline with missing values."""
        from sklearn.impute import SimpleImputer
        
        # Introduce missing values
        X_missing = self.X.copy()
        X_missing.loc[0, 'feature_0'] = np.nan
        
        pipeline = Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler()),
            ('classifier', RandomForestClassifier(n_estimators=10, random_state=42))
        ])
        
        # Should handle missing values
        pipeline.fit(X_missing, self.y)
        y_pred = pipeline.predict(X_missing)
        
        self.assertEqual(len(y_pred), len(self.y))
```

### API Testing

```python
import unittest
import json
from fastapi.testclient import TestClient
from src.api.app import app

class TestAPI(unittest.TestCase):
    """Test the API endpoints."""
    
    def setUp(self):
        """Set up test client."""
        self.client = TestClient(app)
    
    def test_health_endpoint(self):
        """Test health check endpoint."""
        response = self.client.get("/api/health")
        self.assertEqual(response.status_code, 200)
        
        data = response.json()
        self.assertEqual(data['status'], 'healthy')
    
    def test_prediction_endpoint(self):
        """Test prediction endpoint."""
        # Sample request
        request_data = {
            "features": {
                "age": 30,
                "income": 50000,
                "tenure": 12,
                "contract": "month-to-month"
            }
        }
        
        response = self.client.post("/api/predict", json=request_data)
        self.assertEqual(response.status_code, 200)
        
        data = response.json()
        self.assertIn('prediction', data)
        self.assertIn('timestamp', data)
        self.assertEqual(data['status'], 'success')
    
    def test_batch_prediction(self):
        """Test batch prediction endpoint."""
        request_data = {
            "features": [
                {"age": 30, "income": 50000, "tenure": 12},
                {"age": 40, "income": 60000, "tenure": 24},
                {"age": 25, "income": 40000, "tenure": 6}
            ]
        }
        
        response = self.client.post("/api/predict/batch", json=request_data)
        self.assertEqual(response.status_code, 200)
        
        data = response.json()
        self.assertEqual(data['count'], 3)
        self.assertEqual(len(data['predictions']), 3)
        self.assertEqual(data['status'], 'success')
    
    def test_invalid_request(self):
        """Test invalid request handling."""
        # Missing required field
        request_data = {
            "features": {
                "age": 30
                # Missing income
            }
        }
        
        response = self.client.post("/api/predict", json=request_data)
        self.assertEqual(response.status_code, 422)  # Unprocessable Entity
```

---

## 4. Model Validation

### Cross-Validation Strategies

```python
import numpy as np
from sklearn.model_selection import cross_val_score, StratifiedKFold, TimeSeriesSplit
from sklearn.ensemble import RandomForestClassifier

def validate_with_cross_validation(model, X, y, cv_type='stratified', n_folds=5):
    """
    Validate model with cross-validation.
    
    Args:
        model: Model to validate
        X: Feature matrix
        y: Target vector
        cv_type: Type of cross-validation
        n_folds: Number of folds
    
    Returns:
        dict: Validation results
    """
    if cv_type == 'stratified':
        cv = StratifiedKFold(n_splits=n_folds, shuffle=True, random_state=42)
    elif cv_type == 'kfold':
        from sklearn.model_selection import KFold
        cv = KFold(n_splits=n_folds, shuffle=True, random_state=42)
    elif cv_type == 'timeseries':
        cv = TimeSeriesSplit(n_splits=n_folds)
    else:
        raise ValueError(f"Unknown cv_type: {cv_type}")
    
    # Compute scores
    scores = cross_val_score(model, X, y, cv=cv, scoring='accuracy')
    
    return {
        'scores': scores,
        'mean_score': np.mean(scores),
        'std_score': np.std(scores)
    }

def nested_cross_validation(model, param_grid, X, y, inner_cv=3, outer_cv=5):
    """
    Perform nested cross-validation for unbiased evaluation.
    
    Args:
        model: Model to validate
        param_grid: Hyperparameter grid
        X: Feature matrix
        y: Target vector
        inner_cv: Number of inner CV folds
        outer_cv: Number of outer CV folds
    
    Returns:
        dict: Nested CV results
    """
    from sklearn.model_selection import GridSearchCV, cross_val_score
    
    # Inner CV: Hyperparameter tuning
    inner_cv = StratifiedKFold(n_splits=inner_cv, shuffle=True, random_state=42)
    grid_search = GridSearchCV(model, param_grid, cv=inner_cv)
    
    # Outer CV: Performance evaluation
    outer_cv = StratifiedKFold(n_splits=outer_cv, shuffle=True, random_state=42)
    scores = cross_val_score(grid_search, X, y, cv=outer_cv, scoring='accuracy')
    
    return {
        'scores': scores,
        'mean_score': np.mean(scores),
        'std_score': np.std(scores)
    }
```

### Bootstrap Validation

```python
def bootstrap_validate(model, X, y, n_iterations=1000, test_size=0.2):
    """
    Validate model using bootstrap sampling.
    
    Args:
        model: Model to validate
        X: Feature matrix
        y: Target vector
        n_iterations: Number of bootstrap iterations
        test_size: Proportion of test data
    
    Returns:
        dict: Bootstrap results
    """
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import accuracy_score
    
    scores = []
    for i in range(n_iterations):
        # Bootstrap sample
        indices = np.random.choice(len(X), len(X), replace=True)
        X_boot = X.iloc[indices] if hasattr(X, 'iloc') else X[indices]
        y_boot = y.iloc[indices] if hasattr(y, 'iloc') else y[indices]
        
        # Train model
        model_copy = model.__class__(**model.get_params())
        model_copy.fit(X_boot, y_boot)
        
        # Evaluate on out-of-bag samples
        oob_indices = list(set(range(len(X))) - set(indices))
        if oob_indices:
            X_oob = X.iloc[oob_indices] if hasattr(X, 'iloc') else X[oob_indices]
            y_oob = y.iloc[oob_indices] if hasattr(y, 'iloc') else y[oob_indices]
            score = accuracy_score(y_oob, model_copy.predict(X_oob))
            scores.append(score)
    
    # Calculate confidence intervals
    confidence_intervals = {
        '95%': (np.percentile(scores, 2.5), np.percentile(scores, 97.5)),
        '90%': (np.percentile(scores, 5), np.percentile(scores, 95))
    }
    
    return {
        'scores': scores,
        'mean_score': np.mean(scores),
        'std_score': np.std(scores),
        'confidence_intervals': confidence_intervals
    }
```

---

## 5. Performance Testing

### Benchmarking

```python
import time
import numpy as np
import matplotlib.pyplot as plt

def benchmark_model(model, X_train, y_train, X_test, y_test, sizes=None):
    """
    Benchmark model performance with varying dataset sizes.
    
    Args:
        model: Model to benchmark
        X_train: Training features
        y_train: Training targets
        X_test: Test features
        y_test: Test targets
        sizes: List of training sizes to test
    
    Returns:
        dict: Benchmark results
    """
    if sizes is None:
        sizes = [0.1, 0.2, 0.4, 0.6, 0.8, 1.0]
    
    results = {
        'train_scores': [],
        'test_scores': [],
        'train_times': [],
        'sizes': []
    }
    
    for size in sizes:
        # Subset training data
        n_samples = int(len(X_train) * size)
        X_subset = X_train[:n_samples]
        y_subset = y_train[:n_samples]
        
        # Train model
        start_time = time.time()
        model_copy = model.__class__(**model.get_params())
        model_copy.fit(X_subset, y_subset)
        train_time = time.time() - start_time
        
        # Evaluate
        train_score = model_copy.score(X_subset, y_subset)
        test_score = model_copy.score(X_test, y_test)
        
        # Store results
        results['train_scores'].append(train_score)
        results['test_scores'].append(test_score)
        results['train_times'].append(train_time)
        results['sizes'].append(size)
    
    return results

def plot_learning_curves(results, title="Learning Curves"):
    """
    Plot learning curves from benchmark results.
    
    Args:
        results: Benchmark results dictionary
        title: Plot title
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Performance curves
    ax = axes[0]
    ax.plot(results['sizes'], results['train_scores'], label='Train', marker='o')
    ax.plot(results['sizes'], results['test_scores'], label='Test', marker='s')
    ax.set_xlabel('Training Size')
    ax.set_ylabel('Score')
    ax.set_title('Learning Curves')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Time curves
    ax = axes[1]
    ax.plot(results['sizes'], results['train_times'], marker='o')
    ax.set_xlabel('Training Size')
    ax.set_ylabel('Training Time (seconds)')
    ax.set_title('Training Time')
    ax.grid(True, alpha=0.3)
    
    plt.suptitle(title)
    plt.tight_layout()
    return fig
```

### Stress Testing

```python
def stress_test_model(model, X_test, y_test, n_trials=100):
    """
    Stress test model with different perturbations.
    
    Args:
        model: Model to test
        X_test: Test features
        y_test: Test targets
        n_trials: Number of stress trials
    
    Returns:
        dict: Stress test results
    """
    from sklearn.metrics import accuracy_score
    
    results = {
        'original_score': model.score(X_test, y_test),
        'perturbed_scores': [],
        'perturbations': []
    }
    
    for i in range(n_trials):
        # Apply different perturbations
        perturbation_type = np.random.choice(['noise', 'scale', 'missing', 'mix'])
        
        X_perturbed = X_test.copy()
        
        if perturbation_type == 'noise':
            # Add Gaussian noise
            noise_level = np.random.uniform(0.01, 0.2)
            X_perturbed += np.random.normal(0, noise_level * X_perturbed.std(axis=0), X_perturbed.shape)
            
        elif perturbation_type == 'scale':
            # Scale features
            scale_factor = np.random.uniform(0.5, 2.0)
            X_perturbed *= scale_factor
            
        elif perturbation_type == 'missing':
            # Introduce missing values
            missing_rate = np.random.uniform(0.01, 0.1)
            mask = np.random.random(X_perturbed.shape) < missing_rate
            X_perturbed[mask] = np.nan
            
            # Impute missing values
            from sklearn.impute import SimpleImputer
            imputer = SimpleImputer(strategy='median')
            X_perturbed = imputer.fit_transform(X_perturbed)
            
        elif perturbation_type == 'mix':
            # Combination of perturbations
            X_perturbed += np.random.normal(0, 0.05, X_perturbed.shape)
            X_perturbed = X_perturbed * np.random.uniform(0.8, 1.2)
        
        # Evaluate
        score = accuracy_score(y_test, model.predict(X_perturbed))
        
        results['perturbed_scores'].append(score)
        results['perturbations'].append(perturbation_type)
    
    return results
```

---

## 6. Model Robustness Testing

### Adversarial Testing

```python
def adversarial_test(model, X_test, y_test, epsilon=0.1):
    """
    Test model robustness to adversarial examples.
    
    Args:
        model: Model to test
        X_test: Test features
        y_test: Test targets
        epsilon: Perturbation magnitude
    
    Returns:
        dict: Adversarial test results
    """
    from sklearn.metrics import accuracy_score
    
    # Original predictions
    y_pred_original = model.predict(X_test)
    accuracy_original = accuracy_score(y_test, y_pred_original)
    
    # Create adversarial examples (simplified FGSM)
    X_adv = X_test.copy()
    
    if hasattr(model, 'coef_'):
        # Linear models: gradient is coefficients
        gradient = model.coef_
        if len(gradient.shape) > 1:
            gradient = gradient[0]
        X_adv += epsilon * np.sign(gradient)
    elif hasattr(model, 'predict_proba'):
        # For other models, use a simpler approach
        # Random perturbation in the direction of features
        X_adv += epsilon * np.random.randn(*X_adv.shape)
    
    # Adversarial predictions
    y_pred_adv = model.predict(X_adv)
    accuracy_adv = accuracy_score(y_test, y_pred_adv)
    
    return {
        'original_accuracy': accuracy_original,
        'adversarial_accuracy': accuracy_adv,
        'accuracy_drop': accuracy_original - accuracy_adv,
        'robustness_score': accuracy_adv / accuracy_original if accuracy_original > 0 else 0
    }
```

### Edge Case Testing

```python
def edge_case_test(model, X_train, feature_ranges):
    """
    Test model on edge cases.
    
    Args:
        model: Model to test
        X_train: Training data
        feature_ranges: Dictionary of feature ranges
    
    Returns:
        dict: Edge case test results
    """
    results = {
        'edge_cases_tested': [],
        'predictions': []
    }
    
    # Test extreme values
    for feature, (min_val, max_val) in feature_ranges.items():
        # Test minimum
        X_edge = X_train.iloc[0:1].copy()
        X_edge[feature] = min_val
        pred_min = model.predict(X_edge)[0]
        
        # Test maximum
        X_edge = X_train.iloc[0:1].copy()
        X_edge[feature] = max_val
        pred_max = model.predict(X_edge)[0]
        
        results['edge_cases_tested'].append({
            'feature': feature,
            'min_value': min_val,
            'min_prediction': pred_min,
            'max_value': max_val,
            'max_prediction': pred_max
        })
    
    # Test combinations of extreme values
    for feature1, (min1, max1) in feature_ranges.items():
        for feature2, (min2, max2) in feature_ranges.items():
            if feature1 < feature2:
                # All extremes combination
                X_edge = X_train.iloc[0:1].copy()
                X_edge[feature1] = min1
                X_edge[feature2] = min2
                pred = model.predict(X_edge)[0]
                results['predictions'].append({
                    'feature1': feature1,
                    'value1': min1,
                    'feature2': feature2,
                    'value2': min2,
                    'prediction': pred
                })
    
    return results
```

---

## 7. Test Automation

### Pytest Configuration

```python
# conftest.py
import pytest
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification

@pytest.fixture
def sample_data():
    """Create sample data for testing."""
    X, y = make_classification(n_samples=100, n_features=10, random_state=42)
    X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])
    y = pd.Series(y, name='target')
    return X, y

@pytest.fixture
def sample_model():
    """Create sample model for testing."""
    from sklearn.ensemble import RandomForestClassifier
    return RandomForestClassifier(n_estimators=10, random_state=42)
```

### Running Tests

```bash
# Run all tests
pytest tests/

# Run with coverage
pytest tests/ --cov=src/ --cov-report=html

# Run specific test file
pytest tests/test_validation.py -v

# Run specific test function
pytest tests/test_validation.py::TestModelValidation::test_cross_validation -v

# Run with verbose output
pytest -v --tb=short
```

---

## Quick Reference: Validation and Testing

### Test Types

```
┌─────────────────────────────────────────────────────────────────┐
│  TEST TYPE     │ PURPOSE                    │ WHEN TO USE     │
├────────────────┼────────────────────────────┼─────────────────┤
│  Unit Tests    │ Test individual functions  │ During development│
│  Integration   │ Test component interaction │ Before deployment│
│  Model         │ Test model performance     │ Before deployment│
│  Stress        │ Test robustness           │ Production prep  │
│  Adversarial   │ Test security             │ Security critical│
│  Performance   │ Test speed/scale          │ Scalability      │
└─────────────────────────────────────────────────────────────────┘
```

### Validation Strategies

```
┌─────────────────────────────────────────────────────────────────┐
│  STRATEGY      │ BEST FOR                    │ DATA SIZE      │
├────────────────┼─────────────────────────────┼─────────────────┤
│  Hold-out      │ Quick evaluation            │ Large          │
│  K-Fold        │ Robust evaluation           │ Medium         │
│  Stratified    │ Imbalanced data             │ Medium         │
│  Time Series   │ Temporal data               │ Any            │
│  Bootstrap     │ Confidence intervals        │ Small          │
│  Nested        │ Unbiased evaluation         │ Medium         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of model validation and testing. You now understand:

1. **Validation hierarchy**: Unit, integration, model, system, UAT
2. **Unit testing**: Data transformations, model functions
3. **Integration testing**: Pipeline, API
4. **Model validation**: Cross-validation, bootstrap
5. **Performance testing**: Benchmarking, stress testing
6. **Robustness testing**: Adversarial, edge cases
7. **Test automation**: Pytest, CI/CD integration

**Next Steps:**
1. Write unit tests for your code
2. Implement integration tests
3. Perform cross-validation
4. Stress test your model
5. Proceed to Part 1 of the series

---

*End of Primer 17*
