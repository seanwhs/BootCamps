# Primer 19: AutoML and Hyperparameter Optimization

## Overview

This primer provides a comprehensive guide to AutoML (Automated Machine Learning) and hyperparameter optimization—techniques for automating the ML workflow and finding optimal model configurations. Understanding these concepts is essential for building efficient ML pipelines, reducing manual tuning time, and achieving better model performance.

---

## 1. Introduction to AutoML

### What is AutoML?

```
┌─────────────────────────────────────────────────────────────────┐
│                    WHAT IS AUTOML?                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  AutoML automates the end-to-end machine learning process:    │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Traditional ML Pipeline                                │  │
│  │  Data → Preprocess → Feature Eng → Model → Tune → Deploy│  │
│  │  ▲         ▲            ▲          ▲      ▲             │  │
│  │  │ Manual  │ Manual     │ Manual   │ Manual│ Manual      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  AutoML Pipeline                                        │  │
│  │  Data → Auto Preprocess → Auto Feature → Auto Model →   │  │
│  │        → Auto Tune → Auto Deploy                         │  │
│  │  ▲                                                       │  │
│  │  │ Fully Automated                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### AutoML Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTOML COMPONENTS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Automated Data Preprocessing                               │
│     ├── Missing value handling                                 │
│     ├── Feature scaling                                        │
│     ├── Categorical encoding                                   │
│     └── Feature selection                                      │
│                                                                 │
│  2. Automated Feature Engineering                              │
│     ├── Feature creation                                       │
│     ├── Feature transformation                                 │
│     ├── Feature interaction                                    │
│     └── Dimensionality reduction                               │
│                                                                 │
│  3. Automated Model Selection                                  │
│     ├── Algorithm selection                                    │
│     ├── Architecture search                                    │
│     └── Ensemble construction                                  │
│                                                                 │
│  4. Automated Hyperparameter Optimization                      │
│     ├── Grid search                                            │
│     ├── Random search                                          │
│     ├── Bayesian optimization                                  │
│     └── Evolutionary algorithms                                │
│                                                                 │
│  5. Automated Deployment                                       │
│     ├── Model packaging                                        │
│     ├── API generation                                         │
│     └── Monitoring setup                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Automated Feature Engineering

### Feature Engineering Automation

```python
from sklearn.base import BaseEstimator, TransformerMixin
import pandas as pd
import numpy as np
from itertools import combinations
import warnings
warnings.filterwarnings('ignore')

class AutoFeatureEngineer(BaseEstimator, TransformerMixin):
    """
    Automated feature engineering.
    """
    
    def __init__(
        self,
        interactions=True,
        polynomials=True,
        ratios=True,
        max_degree=2,
        max_features=50,
        correlation_threshold=0.95
    ):
        self.interactions = interactions
        self.polynomials = polynomials
        self.ratios = ratios
        self.max_degree = max_degree
        self.max_features = max_features
        self.correlation_threshold = correlation_threshold
        self._feature_names = []
        self._selected_features = []
    
    def fit(self, X, y=None):
        """Identify useful features."""
        X = self._prepare_data(X)
        self._feature_names = X.columns.tolist()
        self._selected_features = self._select_features(X, y)
        return self
    
    def transform(self, X):
        """Transform data with automated features."""
        X = self._prepare_data(X)
        
        # Create features
        new_features = []
        
        if self.interactions:
            new_features.extend(self._create_interactions(X))
        
        if self.polynomials:
            new_features.extend(self._create_polynomials(X))
        
        if self.ratios:
            new_features.extend(self._create_ratios(X))
        
        # Combine with original features
        X_new = pd.concat([X] + new_features, axis=1)
        
        # Select features
        if self._selected_features:
            X_new = X_new[self._selected_features]
        
        return X_new
    
    def _prepare_data(self, X):
        """Convert to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _select_features(self, X, y):
        """Select features based on importance."""
        # If no target, use variance
        if y is None:
            variances = X.var()
            selected = variances.nlargest(self.max_features).index.tolist()
            return selected
        
        # Use correlation with target
        correlations = X.corrwith(pd.Series(y))
        selected = correlations.abs().nlargest(self.max_features).index.tolist()
        
        # Remove highly correlated features
        corr_matrix = X[selected].corr().abs()
        upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(bool))
        to_drop = [col for col in upper.columns if any(upper[col] > self.correlation_threshold)]
        
        return [col for col in selected if col not in to_drop]
    
    def _create_interactions(self, X):
        """Create interaction features."""
        features = []
        numeric_cols = X.select_dtypes(include=[np.number]).columns
        
        for col1, col2 in combinations(numeric_cols, 2):
            name = f"{col1}_x_{col2}"
            feature = X[col1] * X[col2]
            features.append(pd.DataFrame({name: feature}))
        
        return features
    
    def _create_polynomials(self, X):
        """Create polynomial features."""
        features = []
        numeric_cols = X.select_dtypes(include=[np.number]).columns
        
        for col in numeric_cols:
            for degree in range(2, self.max_degree + 1):
                name = f"{col}_pow_{degree}"
                feature = X[col] ** degree
                features.append(pd.DataFrame({name: feature}))
        
        return features
    
    def _create_ratios(self, X):
        """Create ratio features."""
        features = []
        numeric_cols = X.select_dtypes(include=[np.number]).columns
        
        for col1, col2 in combinations(numeric_cols, 2):
            # Avoid division by zero
            denom = X[col2].replace(0, np.nan)
            name = f"{col1}_div_{col2}"
            feature = X[col1] / denom
            features.append(pd.DataFrame({name: feature}))
        
        return features
    
    def get_feature_names(self):
        """Get generated feature names."""
        return self._selected_features or self._feature_names
```

### Feature Selection Automation

```python
from sklearn.feature_selection import SelectKBest, mutual_info_classif, RFE
from sklearn.ensemble import RandomForestClassifier

class AutoFeatureSelector:
    """
    Automated feature selection.
    """
    
    def __init__(self, method='ensemble', n_features=20):
        self.method = method
        self.n_features = n_features
        self._selected_features = None
    
    def fit(self, X, y):
        """Select features."""
        X = self._prepare_data(X)
        
        if self.method == 'correlation':
            self._selected_features = self._correlation_selection(X, y)
        elif self.method == 'mutual_info':
            self._selected_features = self._mutual_info_selection(X, y)
        elif self.method == 'rfe':
            self._selected_features = self._rfe_selection(X, y)
        elif self.method == 'ensemble':
            self._selected_features = self._ensemble_selection(X, y)
        else:
            raise ValueError(f"Unknown method: {self.method}")
        
        return self
    
    def transform(self, X):
        """Select features."""
        X = self._prepare_data(X)
        return X[self._selected_features]
    
    def _prepare_data(self, X):
        """Convert to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _correlation_selection(self, X, y):
        """Select based on correlation."""
        correlations = X.corrwith(pd.Series(y))
        return correlations.abs().nlargest(self.n_features).index.tolist()
    
    def _mutual_info_selection(self, X, y):
        """Select based on mutual information."""
        selector = SelectKBest(mutual_info_classif, k=self.n_features)
        selector.fit(X, y)
        
        feature_names = X.columns
        selected_indices = selector.get_support(indices=True)
        return [feature_names[i] for i in selected_indices]
    
    def _rfe_selection(self, X, y):
        """Select using Recursive Feature Elimination."""
        estimator = RandomForestClassifier(n_estimators=50, random_state=42)
        selector = RFE(estimator, n_features_to_select=self.n_features)
        selector.fit(X, y)
        
        feature_names = X.columns
        selected_indices = selector.get_support(indices=True)
        return [feature_names[i] for i in selected_indices]
    
    def _ensemble_selection(self, X, y):
        """Select using ensemble importance."""
        rf = RandomForestClassifier(n_estimators=100, random_state=42)
        rf.fit(X, y)
        
        importance = pd.DataFrame({
            'feature': X.columns,
            'importance': rf.feature_importances_
        }).sort_values('importance', ascending=False)
        
        return importance.head(self.n_features)['feature'].tolist()
```

---

## 3. Automated Model Selection

### Model Recommender

```python
class AutoModelSelector:
    """
    Automated model selection and recommendation.
    """
    
    def __init__(self, problem_type='classification'):
        self.problem_type = problem_type
        self.models = {
            'classification': {
                'logistic_regression': LogisticRegression,
                'decision_tree': DecisionTreeClassifier,
                'random_forest': RandomForestClassifier,
                'xgboost': None,  # Need to import
                'lightgbm': None,  # Need to import
                'svm': SVC
            },
            'regression': {
                'linear_regression': LinearRegression,
                'ridge': Ridge,
                'lasso': Lasso,
                'decision_tree': DecisionTreeRegressor,
                'random_forest': RandomForestRegressor,
                'xgboost': None,  # Need to import
                'lightgbm': None   # Need to import
            },
            'clustering': {
                'kmeans': KMeans,
                'dbscan': DBSCAN,
                'hierarchical': AgglomerativeClustering
            }
        }
    
    def suggest_models(self, X, y=None):
        """Suggest models based on data characteristics."""
        suggestions = []
        
        # Data characteristics
        n_samples = X.shape[0]
        n_features = X.shape[1]
        
        if self.problem_type == 'classification':
            n_classes = len(np.unique(y)) if y is not None else 2
            is_imbalanced = y is not None and max(np.bincount(y)) / min(np.bincount(y)) > 3
            
            # Suggest based on data size
            if n_samples < 100:
                suggestions.append(('logistic_regression', 'Small dataset, simple model'))
                suggestions.append(('decision_tree', 'Small dataset, interpretable'))
            
            if n_samples > 100 and n_samples < 10000:
                suggestions.append(('random_forest', 'Medium dataset, good performance'))
                suggestions.append(('xgboost', 'Medium dataset, best performance'))
            
            if n_samples > 10000:
                suggestions.append(('lightgbm', 'Large dataset, fast training'))
                suggestions.append(('random_forest', 'Large dataset, robust'))
            
            # Handle imbalanced data
            if is_imbalanced:
                suggestions.append(('balanced_rf', 'Imbalanced data, use class weights'))
                suggestions.append(('xgboost', 'Imbalanced data, use scale_pos_weight'))
            
            # Handle high dimensions
            if n_features > 100:
                suggestions.append(('svm', 'High-dimensional data'))
                suggestions.append(('logistic_regression', 'High-dimensional data, linear'))
        
        elif self.problem_type == 'regression':
            if n_samples < 100:
                suggestions.append(('linear_regression', 'Small dataset'))
                suggestions.append(('decision_tree', 'Small dataset, interpretable'))
            
            if n_samples > 100 and n_samples < 10000:
                suggestions.append(('random_forest', 'Medium dataset, good performance'))
                suggestions.append(('xgboost', 'Medium dataset, best performance'))
            
            if n_samples > 10000:
                suggestions.append(('lightgbm', 'Large dataset, fast'))
                suggestions.append(('random_forest', 'Large dataset, robust'))
        
        return suggestions
```

### Model Evaluation

```python
def evaluate_models(models, X_train, y_train, X_val, y_val, cv=5):
    """
    Evaluate multiple models and return performance.
    
    Args:
        models: Dict of model_name: model_instance
        X_train: Training features
        y_train: Training target
        X_val: Validation features
        y_val: Validation target
        cv: Cross-validation folds
    
    Returns:
        pd.DataFrame: Model evaluation results
    """
    from sklearn.model_selection import cross_val_score
    from sklearn.metrics import accuracy_score, f1_score
    
    results = []
    
    for name, model in models.items():
        try:
            # Cross-validation
            cv_scores = cross_val_score(model, X_train, y_train, cv=cv, scoring='accuracy')
            
            # Train on full training set
            model.fit(X_train, y_train)
            
            # Validation performance
            y_pred = model.predict(X_val)
            val_accuracy = accuracy_score(y_val, y_pred)
            val_f1 = f1_score(y_val, y_pred, average='weighted')
            
            # Feature importance (if available)
            has_importance = hasattr(model, 'feature_importances_') or hasattr(model, 'coef_')
            
            results.append({
                'model': name,
                'cv_mean': np.mean(cv_scores),
                'cv_std': np.std(cv_scores),
                'val_accuracy': val_accuracy,
                'val_f1': val_f1,
                'has_importance': has_importance,
                'time': 0  # Could add timing
            })
        except Exception as e:
            print(f"Error evaluating {name}: {str(e)}")
    
    return pd.DataFrame(results).sort_values('val_accuracy', ascending=False)
```

---

## 4. Hyperparameter Optimization

### Advanced Grid Search

```python
import itertools
from sklearn.model_selection import ParameterGrid

class AdaptiveGridSearch:
    """
    Adaptive grid search with multiple stages.
    """
    
    def __init__(self, param_grid, n_stages=3, reduction_factor=2):
        self.param_grid = param_grid
        self.n_stages = n_stages
        self.reduction_factor = reduction_factor
        self.best_params_ = None
        self.best_score_ = None
    
    def fit(self, model, X, y):
        """Perform adaptive grid search."""
        current_grid = self.param_grid.copy()
        
        for stage in range(self.n_stages):
            # Get all parameter combinations
            grid = ParameterGrid(current_grid)
            
            # Evaluate each combination
            scores = []
            for params in grid:
                model.set_params(**params)
                score = cross_val_score(model, X, y, cv=3, scoring='accuracy').mean()
                scores.append((params, score))
            
            # Find best parameters
            best_params, best_score = max(scores, key=lambda x: x[1])
            self.best_params_ = best_params
            self.best_score_ = best_score
            
            print(f"Stage {stage+1}: Best score = {best_score:.4f}")
            
            # Refine grid
            current_grid = self._refine_grid(best_params)
        
        return self
    
    def _refine_grid(self, best_params):
        """Refine grid around best parameters."""
        refined = {}
        
        for param, value in best_params.items():
            if isinstance(value, (int, float)):
                # Expand around best value
                step = abs(value) * 0.1 if value != 0 else 0.1
                refined[param] = [
                    value - step * self.reduction_factor,
                    value,
                    value + step * self.reduction_factor
                ]
            else:
                # Keep categorical
                refined[param] = [value]
        
        return refined
```

### Random Search with Early Stopping

```python
class RandomizedSearchWithEarlyStopping:
    """
    Random search with early stopping.
    """
    
    def __init__(self, param_dist, n_iter=100, cv=3, early_stopping_patience=10):
        self.param_dist = param_dist
        self.n_iter = n_iter
        self.cv = cv
        self.early_stopping_patience = early_stopping_patience
        self.best_params_ = None
        self.best_score_ = -np.inf
    
    def fit(self, model, X, y):
        """Perform random search with early stopping."""
        best_score = -np.inf
        patience_counter = 0
        
        for i in range(self.n_iter):
            # Sample parameters
            params = {}
            for param, distribution in self.param_dist.items():
                if isinstance(distribution, list):
                    params[param] = np.random.choice(distribution)
                elif isinstance(distribution, tuple):
                    if len(distribution) == 2:
                        low, high = distribution
                        if isinstance(low, int) and isinstance(high, int):
                            params[param] = np.random.randint(low, high)
                        else:
                            params[param] = np.random.uniform(low, high)
            
            # Evaluate
            model.set_params(**params)
            score = cross_val_score(model, X, y, cv=self.cv, scoring='accuracy').mean()
            
            print(f"Iteration {i+1}/{self.n_iter}: Score = {score:.4f}")
            
            # Check improvement
            if score > best_score:
                best_score = score
                self.best_params_ = params
                self.best_score_ = score
                patience_counter = 0
                print(f"  ✓ New best score: {score:.4f}")
            else:
                patience_counter += 1
            
            # Early stopping
            if patience_counter >= self.early_stopping_patience:
                print(f"Early stopping after {i+1} iterations")
                break
        
        return self
```

---

## 5. Automated Machine Learning Framework

### Simple AutoML Implementation

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

class SimpleAutoML:
    """
    Simplified AutoML framework.
    """
    
    def __init__(
        self,
        time_limit=3600,  # seconds
        max_models=10,
        cv=3,
        scoring='accuracy'
    ):
        self.time_limit = time_limit
        self.max_models = max_models
        self.cv = cv
        self.scoring = scoring
        self.best_model_ = None
        self.best_score_ = None
    
    def fit(self, X, y):
        """Run AutoML process."""
        import time
        start_time = time.time()
        
        # Identify column types
        numeric_cols = X.select_dtypes(include=[np.number]).columns.tolist()
        categorical_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
        
        results = []
        iteration = 0
        
        while time.time() - start_time < self.time_limit and iteration < self.max_models:
            # Try different model configurations
            config = self._sample_config()
            
            try:
                # Build pipeline
                pipeline = self._build_pipeline(numeric_cols, categorical_cols, config)
                
                # Evaluate
                score = cross_val_score(pipeline, X, y, cv=self.cv, scoring=self.scoring).mean()
                
                results.append({
                    'config': config,
                    'score': score
                })
                
                if score > self.best_score_:
                    self.best_score_ = score
                    self.best_model_ = pipeline
                    print(f"New best model: {score:.4f}")
                
                iteration += 1
                
            except Exception as e:
                print(f"Error with config: {str(e)}")
                continue
        
        # Train best model on full data
        if self.best_model_:
            self.best_model_.fit(X, y)
        
        return self
    
    def _sample_config(self):
        """Sample a random configuration."""
        config = {
            'imputation': np.random.choice(['mean', 'median', 'most_frequent']),
            'scaling': np.random.choice(['standard', 'robust', 'minmax', 'none']),
            'encoding': np.random.choice(['one_hot', 'target', 'frequency']),
            'model': np.random.choice([
                'logistic_regression',
                'random_forest',
                'xgboost',
                'svm'
            ]),
            'model_params': {}  # Could add random params
        }
        return config
    
    def _build_pipeline(self, numeric_cols, categorical_cols, config):
        """Build pipeline based on configuration."""
        # Numeric transformer
        numeric_transformer = Pipeline([
            ('imputer', SimpleImputer(strategy=config['imputation']))
        ])
        
        if config['scaling'] == 'standard':
            numeric_transformer.steps.append(('scaler', StandardScaler()))
        elif config['scaling'] == 'robust':
            numeric_transformer.steps.append(('scaler', RobustScaler()))
        elif config['scaling'] == 'minmax':
            numeric_transformer.steps.append(('scaler', MinMaxScaler()))
        
        # Categorical transformer
        categorical_transformer = Pipeline([
            ('imputer', SimpleImputer(strategy='constant', fill_value='missing'))
        ])
        
        if config['encoding'] == 'one_hot':
            categorical_transformer.steps.append(('encoder', OneHotEncoder(handle_unknown='ignore')))
        elif config['encoding'] == 'target':
            # Target encoding would need y
            categorical_transformer.steps.append(('encoder', OneHotEncoder(handle_unknown='ignore')))
        elif config['encoding'] == 'frequency':
            # Frequency encoding would need custom implementation
            categorical_transformer.steps.append(('encoder', OneHotEncoder(handle_unknown='ignore')))
        
        # Preprocessor
        preprocessor = ColumnTransformer([
            ('numeric', numeric_transformer, numeric_cols),
            ('categorical', categorical_transformer, categorical_cols)
        ])
        
        # Model
        if config['model'] == 'logistic_regression':
            model = LogisticRegression(max_iter=1000)
        elif config['model'] == 'random_forest':
            model = RandomForestClassifier(n_estimators=100, random_state=42)
        elif config['model'] == 'xgboost':
            import xgboost as xgb
            model = xgb.XGBClassifier(n_estimators=100, random_state=42)
        elif config['model'] == 'svm':
            model = SVC(kernel='rbf', probability=True, random_state=42)
        else:
            model = RandomForestClassifier(n_estimators=100, random_state=42)
        
        # Full pipeline
        pipeline = Pipeline([
            ('preprocessor', preprocessor),
            ('model', model)
        ])
        
        return pipeline
    
    def predict(self, X):
        """Make predictions."""
        if self.best_model_ is None:
            raise ValueError("Model not fitted. Call fit() first.")
        return self.best_model_.predict(X)
    
    def predict_proba(self, X):
        """Predict probabilities."""
        if self.best_model_ is None:
            raise ValueError("Model not fitted. Call fit() first.")
        return self.best_model_.predict_proba(X)
```

---

## Quick Reference: AutoML and HPO

### Hyperparameter Optimization Methods

```
┌─────────────────────────────────────────────────────────────────┐
│  METHOD        │ SPEED   │ QUALITY │ COMPLEXITY │ PARALLEL    │
├────────────────┼─────────┼─────────┼────────────┼─────────────┤
│  Grid Search   │ Slow    │ High    │ Low        │ No          │
│  Random Search │ Medium  │ Medium  │ Low        │ Yes         │
│  Bayesian      │ Medium  │ High    │ High       │ Limited     │
│  Evolution     │ Slow    │ High    │ Very High  │ Yes         │
│  Hyperband     │ Fast    │ Medium  │ Medium     │ Yes         │
│  PBT           │ Medium  │ High    │ High       │ Yes         │
└─────────────────────────────────────────────────────────────────┘
```

### AutoML Libraries

```
┌─────────────────────────────────────────────────────────────────┐
│  LIBRARY       │ BEST FOR           │ TYPE     │ EASE OF USE  │
├────────────────┼────────────────────┼──────────┼──────────────┤
│  Auto-sklearn  │ Classic ML         │ Open     │ Medium       │
│  H2O AutoML    │ Enterprise         │ Open     │ High         │
│  TPOT          │ Genetic algorithms │ Open     │ Medium       │
│  AutoKeras     │ Deep Learning      │ Open     │ High         │
│  AutoGluon     │ Tabular + Text     │ Open     │ High         │
│  MLJAR         │ Automated ML       │ Commercial│ High        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of AutoML and hyperparameter optimization. You now understand:

1. **What is AutoML**: Automated ML pipeline components
2. **Automated feature engineering**: Feature creation and selection
3. **Automated model selection**: Model recommendation and evaluation
4. **Hyperparameter optimization**: Grid, random, Bayesian, evolutionary
5. **AutoML framework**: Building a simple AutoML system

**Next Steps:**
1. Try Auto-sklearn on your datasets
2. Implement a custom hyperparameter search
3. Build an automated feature engineering pipeline
4. Create a simple AutoML system
5. Proceed to Part 1 of the series

---

*End of Primer 19*
