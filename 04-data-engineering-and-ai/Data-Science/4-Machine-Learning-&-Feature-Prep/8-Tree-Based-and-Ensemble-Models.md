# Module 4.2: Supervised & Unsupervised Learning

## Part 8: Tree-Based and Ensemble Models

Welcome to Module 4.2! We've completed our feature engineering journey—we can now clean, encode, scale, create, select, and reduce features with confidence. Now we transition to the heart of machine learning: the models themselves. We'll start with tree-based methods, which are among the most powerful and widely used algorithms in practice.

### The Target: A Complete Tree-Based Modeling System

By the end of this part, you'll have:
1. Decision Tree implementation with visualization
2. Random Forest with comprehensive tuning
3. XGBoost integration with custom objectives
4. LightGBM for efficiency with large datasets
5. CatBoost for native categorical support
6. Unified API for all tree-based models
7. Feature importance analysis across models
8. Model comparison and selection framework

### The Concept: Understanding Tree-Based Models

Think of decision trees like playing the game "20 Questions":

**Decision Tree**: One person thinks of an object, and others ask yes/no questions. Each question splits the possibilities in half. After enough questions, you've identified the object.

**Random Forest**: Like asking 100 people to play 20 Questions independently. Each person asks different questions based on their experience. You take a vote on the final answer. This reduces the chance that any one person's mistakes mislead you.

**Gradient Boosting (XGBoost, LightGBM, CatBoost)**: Like playing 20 Questions where each new question corrects the mistakes made by previous questions. The second player learns from the first, the third from the second, and so on. Each subsequent tree focuses on the cases the previous trees got wrong.

#### Why Trees Are So Powerful

1. **Non-linear**: They capture complex, non-linear relationships naturally
2. **Interpretable**: Decision trees can be visualized and explained
3. **Robust**: Not sensitive to outliers or feature scales
4. **Handle mixed data**: Work with both numeric and categorical features
5. **Feature importance**: Naturally provide feature importance measures

#### The Evolution of Tree-Based Methods

```
Decision Trees (1984)
    ↓
Random Forest (2001) - Bagging + Feature Randomization
    ↓
Gradient Boosting (1999) - Sequential Correction
    ↓
XGBoost (2014) - Regularization + Optimized
    ↓
LightGBM (2017) - Histogram-based + Leaf-wise Growth
    ↓
CatBoost (2017) - Ordered Boosting + Native Categorical Support
```

### The Implementation: Building Our Tree-Based Modeling System

#### Step 1: Unified Tree-Based Model Interface

**File:** `src/models/tree_based.py`
**Path:** `ml-pipeline-project/src/models/tree_based.py`

```python
"""
Unified interface for tree-based and ensemble models.

This module provides a consistent API for:
- Decision Trees
- Random Forest
- XGBoost
- LightGBM
- CatBoost
- Gradient Boosting
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import warnings
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.base import BaseEstimator, ClassifierMixin, RegressorMixin
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor
from sklearn.ensemble import (
    RandomForestClassifier, RandomForestRegressor,
    GradientBoostingClassifier, GradientBoostingRegressor
)
from sklearn.model_selection import cross_val_score
from sklearn.metrics import accuracy_score, mean_squared_error

warnings.filterwarnings("ignore", category=UserWarning)

class TreeModelConfig:
    """Configuration constants for tree-based models."""
    
    # Model type mappings
    MODEL_TYPES = {
        'decision_tree': {'class': DecisionTreeClassifier, 'reg': DecisionTreeRegressor},
        'random_forest': {'class': RandomForestClassifier, 'reg': RandomForestRegressor},
        'gradient_boost': {'class': GradientBoostingClassifier, 'reg': GradientBoostingRegressor},
        'xgboost': {'class': 'XGBClassifier', 'reg': 'XGBRegressor'},
        'lightgbm': {'class': 'LGBMClassifier', 'reg': 'LGBMRegressor'},
        'catboost': {'class': 'CatBoostClassifier', 'reg': 'CatBoostRegressor'}
    }
    
    # Default parameters by model type
    DEFAULT_PARAMS = {
        'decision_tree': {'max_depth': 5, 'min_samples_split': 10, 'random_state': 42},
        'random_forest': {'n_estimators': 100, 'max_depth': 10, 'min_samples_split': 5, 'random_state': 42},
        'gradient_boost': {'n_estimators': 100, 'learning_rate': 0.1, 'max_depth': 5, 'random_state': 42},
        'xgboost': {'n_estimators': 100, 'max_depth': 6, 'learning_rate': 0.3, 'random_state': 42},
        'lightgbm': {'n_estimators': 100, 'max_depth': 6, 'learning_rate': 0.1, 'random_state': 42},
        'catboost': {'iterations': 100, 'depth': 6, 'learning_rate': 0.1, 'random_state': 42}
    }

class TreeModel(BaseEstimator):
    """
    Unified interface for all tree-based models.
    
    This class provides a consistent API for training, predicting,
    and evaluating various tree-based models.
    
    Example:
        >>> model = TreeModel(model_type='xgboost', task='classification')
        >>> model.fit(X_train, y_train)
        >>> y_pred = model.predict(X_test)
        >>> model.plot_importance()
    """
    
    def __init__(
        self,
        model_type: str = 'random_forest',
        task: str = 'classification',
        **kwargs
    ):
        """
        Initialize the tree model.
        
        Args:
            model_type: Type of model ('decision_tree', 'random_forest', 
                       'gradient_boost', 'xgboost', 'lightgbm', 'catboost')
            task: Task type ('classification' or 'regression')
            **kwargs: Model-specific parameters
        """
        self.model_type = model_type
        self.task = task
        self.kwargs = kwargs
        
        self._model = None
        self._feature_names = None
        self._is_fitted = False
        
        logger.info(f"TreeModel initialized: {model_type} for {task}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y: Union[np.ndarray, pd.Series]) -> 'TreeModel':
        """
        Fit the model to the data.
        
        Args:
            X: Feature matrix
            y: Target vector
            
        Returns:
            TreeModel: Fitted model
        """
        X = self._prepare_data(X)
        y = self._prepare_target(y)
        
        # Store feature names
        if hasattr(X, 'columns'):
            self._feature_names = X.columns.tolist()
        else:
            self._feature_names = [f'feature_{i}' for i in range(X.shape[1])]
        
        # Create and fit the model
        self._model = self._create_model()
        
        # Handle special cases for XGBoost, LightGBM, CatBoost
        if self.model_type in ['xgboost', 'lightgbm', 'catboost']:
            self._fit_specialized(X, y)
        else:
            self._model.fit(X, y)
        
        self._is_fitted = True
        logger.info(f"Model fitted successfully")
        return self
    
    def predict(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """
        Make predictions.
        
        Args:
            X: Feature matrix
            
        Returns:
            np.ndarray: Predictions
        """
        if not self._is_fitted:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        
        # Handle special cases
        if self.model_type in ['xgboost', 'lightgbm', 'catboost']:
            return self._predict_specialized(X)
        else:
            return self._model.predict(X)
    
    def predict_proba(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """
        Predict class probabilities (for classification).
        
        Args:
            X: Feature matrix
            
        Returns:
            np.ndarray: Class probabilities
        """
        if not self._is_fitted:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        if self.task != 'classification':
            raise ValueError("predict_proba only available for classification tasks")
        
        X = self._prepare_data(X)
        
        # Handle special cases
        if self.model_type in ['xgboost', 'lightgbm', 'catboost']:
            return self._predict_proba_specialized(X)
        else:
            return self._model.predict_proba(X)
    
    def _create_model(self):
        """Create the appropriate model instance."""
        import importlib
        
        # Get model class
        if self.model_type in TreeModelConfig.MODEL_TYPES:
            model_info = TreeModelConfig.MODEL_TYPES[self.model_type]
            
            # Check if it's a string (external library)
            if isinstance(model_info['class'], str):
                # Import the library
                if self.model_type == 'xgboost':
                    try:
                        import xgboost as xgb
                        model_class = getattr(xgb, model_info['class'])
                    except ImportError:
                        raise ImportError("XGBoost not installed. Install with: pip install xgboost")
                elif self.model_type == 'lightgbm':
                    try:
                        import lightgbm as lgb
                        model_class = getattr(lgb, model_info['class'])
                    except ImportError:
                        raise ImportError("LightGBM not installed. Install with: pip install lightgbm")
                elif self.model_type == 'catboost':
                    try:
                        from catboost import CatBoostClassifier, CatBoostRegressor
                        model_class = CatBoostClassifier if self.task == 'classification' else CatBoostRegressor
                    except ImportError:
                        raise ImportError("CatBoost not installed. Install with: pip install catboost")
                else:
                    raise ValueError(f"Unsupported model type: {self.model_type}")
            else:
                # Sklearn model
                model_class = model_info['class'] if self.task == 'classification' else model_info['reg']
            
            # Get default parameters
            default_params = TreeModelConfig.DEFAULT_PARAMS.get(self.model_type, {})
            
            # Merge with user-provided kwargs
            params = {**default_params, **self.kwargs}
            
            # Remove any None values
            params = {k: v for k, v in params.items() if v is not None}
            
            return model_class(**params)
        else:
            raise ValueError(f"Unknown model type: {self.model_type}")
    
    def _fit_specialized(self, X: pd.DataFrame, y: np.ndarray):
        """Fit specialized models (XGBoost, LightGBM, CatBoost)."""
        if self.model_type == 'xgboost':
            # XGBoost
            import xgboost as xgb
            if self.task == 'classification':
                # Convert to DMatrix and train
                dtrain = xgb.DMatrix(X, label=y)
                params = self._model.get_params()
                params['objective'] = 'binary:logistic' if len(np.unique(y)) == 2 else 'multi:softprob'
                params['eval_metric'] = 'logloss' if len(np.unique(y)) == 2 else 'mlogloss'
                # Remove parameters that don't belong in params
                fit_params = {k: v for k, v in params.items() if k not in ['random_state']}
                self._model = xgb.train(
                    fit_params,
                    dtrain,
                    num_boost_round=params.get('n_estimators', 100)
                )
                # Store as xgb.Booster
            else:
                # Regression
                dtrain = xgb.DMatrix(X, label=y)
                params = self._model.get_params()
                params['objective'] = 'reg:squarederror'
                params['eval_metric'] = 'rmse'
                fit_params = {k: v for k, v in params.items() if k not in ['random_state']}
                self._model = xgb.train(
                    fit_params,
                    dtrain,
                    num_boost_round=params.get('n_estimators', 100)
                )
                
        elif self.model_type == 'lightgbm':
            # LightGBM
            import lightgbm as lgb
            if self.task == 'classification':
                self._model = lgb.LGBMClassifier(**self._model.get_params())
            else:
                self._model = lgb.LGBMRegressor(**self._model.get_params())
            self._model.fit(X, y)
            
        elif self.model_type == 'catboost':
            # CatBoost
            from catboost import Pool
            if self.task == 'classification':
                self._model = CatBoostClassifier(**self._model.get_params())
            else:
                self._model = CatBoostRegressor(**self._model.get_params())
            
            # Handle categorical features
            cat_features = []
            if hasattr(X, 'select_dtypes'):
                cat_features = X.select_dtypes(include=['object', 'category']).columns.tolist()
                if cat_features:
                    # Convert to indices
                    cat_indices = [X.columns.get_loc(col) for col in cat_features]
                    self._model.fit(X, y, cat_features=cat_indices, verbose=False)
                else:
                    self._model.fit(X, y, verbose=False)
            else:
                self._model.fit(X, y, verbose=False)
    
    def _predict_specialized(self, X: pd.DataFrame) -> np.ndarray:
        """Make predictions with specialized models."""
        if self.model_type == 'xgboost':
            import xgboost as xgb
            dtest = xgb.DMatrix(X)
            if self.task == 'classification':
                preds = self._model.predict(dtest)
                if len(preds.shape) > 1 and preds.shape[1] > 1:
                    return np.argmax(preds, axis=1)
                else:
                    return (preds > 0.5).astype(int)
            else:
                return self._model.predict(dtest)
                
        elif self.model_type == 'lightgbm':
            return self._model.predict(X)
            
        elif self.model_type == 'catboost':
            return self._model.predict(X)
        
        return np.array([])
    
    def _predict_proba_specialized(self, X: pd.DataFrame) -> np.ndarray:
        """Predict probabilities with specialized models."""
        if self.model_type == 'xgboost':
            import xgboost as xgb
            dtest = xgb.DMatrix(X)
            return self._model.predict(dtest)
            
        elif self.model_type == 'lightgbm':
            return self._model.predict_proba(X)
            
        elif self.model_type == 'catboost':
            return self._model.predict_proba(X)
        
        return np.array([])
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _prepare_target(self, y: Union[np.ndarray, pd.Series]) -> np.ndarray:
        """Convert target to numpy array."""
        if isinstance(y, pd.Series):
            return y.values
        return y
    
    def get_feature_importance(self) -> Dict[str, float]:
        """
        Get feature importance from the model.
        
        Returns:
            Dict: Feature to importance mapping
        """
        if not self._is_fitted:
            raise ValueError("Model has not been fitted yet. Call fit() first.")
        
        importance = {}
        
        # Try different methods to get feature importance
        if hasattr(self._model, 'feature_importances_'):
            importances = self._model.feature_importances_
        elif hasattr(self._model, 'get_score'):
            # XGBoost
            score_dict = self._model.get_score(importance_type='weight')
            if score_dict:
                # Convert to array aligned with features
                importances = np.zeros(len(self._feature_names))
                for idx, name in enumerate(self._feature_names):
                    if f'f{idx}' in score_dict:
                        importances[idx] = score_dict[f'f{idx}']
                # Normalize
                if importances.sum() > 0:
                    importances = importances / importances.sum()
            else:
                return {}
        elif hasattr(self._model, 'booster') and hasattr(self._model.booster, 'get_score'):
            # XGBoost booster
            score_dict = self._model.booster.get_score(importance_type='weight')
            if score_dict:
                importances = np.zeros(len(self._feature_names))
                for idx, name in enumerate(self._feature_names):
                    if f'f{idx}' in score_dict:
                        importances[idx] = score_dict[f'f{idx}']
                if importances.sum() > 0:
                    importances = importances / importances.sum()
            else:
                return {}
        else:
            return {}
        
        # Map to feature names
        if len(importances) == len(self._feature_names):
            for name, imp in zip(self._feature_names, importances):
                importance[name] = float(imp)
        
        return importance
    
    def plot_importance(self, top_k: int = 20, figsize: Tuple[int, int] = (10, 8)):
        """
        Plot feature importance.
        
        Args:
            top_k: Number of top features to show
            figsize: Figure size
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        import matplotlib.pyplot as plt
        
        importance = self.get_feature_importance()
        if not importance:
            logger.warning("No feature importance available")
            return None
        
        # Sort by importance
        sorted_items = sorted(importance.items(), key=lambda x: x[1], reverse=True)
        top_items = sorted_items[:top_k]
        
        if not top_items:
            logger.warning("No feature importance to plot")
            return None
        
        features, importances = zip(*top_items)
        
        fig, ax = plt.subplots(figsize=figsize)
        ax.barh(range(len(features)), importances)
        ax.set_yticks(range(len(features)))
        ax.set_yticklabels(features)
        ax.set_xlabel('Importance')
        ax.set_title(f'Top {len(features)} Feature Importances')
        ax.invert_yaxis()
        
        plt.tight_layout()
        return fig
    
    def cross_validate(
        self,
        X: Union[pd.DataFrame, np.ndarray],
        y: Union[np.ndarray, pd.Series],
        cv: int = 5,
        scoring: Optional[str] = None,
        verbose: bool = True
    ) -> Dict[str, Any]:
        """
        Perform cross-validation.
        
        Args:
            X: Feature matrix
            y: Target vector
            cv: Number of folds
            scoring: Scoring metric
            verbose: Whether to print results
            
        Returns:
            Dict: Cross-validation results
        """
        X = self._prepare_data(X)
        y = self._prepare_target(y)
        
        # Determine default scoring
        if scoring is None:
            if self.task == 'classification':
                scoring = 'accuracy'
            else:
                scoring = 'neg_mean_squared_error'
        
        # Perform cross-validation
        scores = cross_val_score(self, X, y, cv=cv, scoring=scoring)
        
        results = {
            'scores': scores,
            'mean': np.mean(scores),
            'std': np.std(scores),
            'cv': cv,
            'scoring': scoring
        }
        
        if verbose:
            logger.info(f"Cross-validation results ({scoring}):")
            logger.info(f"  Mean: {results['mean']:.4f} (+/- {results['std']:.4f})")
            logger.info(f"  Individual scores: {scores}")
        
        return results
    
    def get_params(self, deep=True):
        """Get model parameters."""
        if self._model is None:
            return self.kwargs
        return self._model.get_params()
    
    def set_params(self, **params):
        """Set model parameters."""
        self.kwargs.update(params)
        if self._model is not None:
            self._model.set_params(**params)
        return self
```

#### Step 2: Specialized Model Parameters

**File:** `src/models/params.py`
**Path:** `ml-pipeline-project/src/models/params.py`

```python
"""
Model-specific parameter templates for tree-based models.
"""

from typing import Dict, Any

# XGBoost parameter templates
XGBOOST_PARAMS = {
    'default': {
        'n_estimators': 100,
        'max_depth': 6,
        'learning_rate': 0.3,
        'subsample': 0.8,
        'colsample_bytree': 0.8,
        'min_child_weight': 1,
        'gamma': 0,
        'reg_alpha': 0,
        'reg_lambda': 1,
        'random_state': 42,
        'n_jobs': -1
    },
    'conservative': {
        'n_estimators': 200,
        'max_depth': 4,
        'learning_rate': 0.05,
        'subsample': 0.7,
        'colsample_bytree': 0.7,
        'min_child_weight': 3,
        'gamma': 1,
        'reg_alpha': 0.1,
        'reg_lambda': 2,
        'random_state': 42,
        'n_jobs': -1
    },
    'aggressive': {
        'n_estimators': 500,
        'max_depth': 8,
        'learning_rate': 0.1,
        'subsample': 0.9,
        'colsample_bytree': 0.9,
        'min_child_weight': 1,
        'gamma': 0,
        'reg_alpha': 0,
        'reg_lambda': 0.5,
        'random_state': 42,
        'n_jobs': -1
    }
}

# LightGBM parameter templates
LIGHTGBM_PARAMS = {
    'default': {
        'n_estimators': 100,
        'max_depth': 6,
        'learning_rate': 0.1,
        'num_leaves': 31,
        'subsample': 0.8,
        'colsample_bytree': 0.8,
        'min_child_samples': 20,
        'reg_alpha': 0,
        'reg_lambda': 0,
        'random_state': 42,
        'n_jobs': -1
    },
    'conservative': {
        'n_estimators': 200,
        'max_depth': 4,
        'learning_rate': 0.05,
        'num_leaves': 15,
        'subsample': 0.7,
        'colsample_bytree': 0.7,
        'min_child_samples': 30,
        'reg_alpha': 0.1,
        'reg_lambda': 1,
        'random_state': 42,
        'n_jobs': -1
    },
    'aggressive': {
        'n_estimators': 500,
        'max_depth': 8,
        'learning_rate': 0.1,
        'num_leaves': 63,
        'subsample': 0.9,
        'colsample_bytree': 0.9,
        'min_child_samples': 10,
        'reg_alpha': 0,
        'reg_lambda': 0.1,
        'random_state': 42,
        'n_jobs': -1
    }
}

# CatBoost parameter templates
CATBOOST_PARAMS = {
    'default': {
        'iterations': 100,
        'depth': 6,
        'learning_rate': 0.1,
        'l2_leaf_reg': 3,
        'border_count': 128,
        'subsample': 0.8,
        'random_state': 42,
        'verbose': False
    },
    'conservative': {
        'iterations': 200,
        'depth': 4,
        'learning_rate': 0.05,
        'l2_leaf_reg': 5,
        'border_count': 64,
        'subsample': 0.7,
        'random_state': 42,
        'verbose': False
    },
    'aggressive': {
        'iterations': 500,
        'depth': 8,
        'learning_rate': 0.1,
        'l2_leaf_reg': 1,
        'border_count': 256,
        'subsample': 0.9,
        'random_state': 42,
        'verbose': False
    }
}

# Random Forest parameter templates
RANDOM_FOREST_PARAMS = {
    'default': {
        'n_estimators': 100,
        'max_depth': 10,
        'min_samples_split': 2,
        'min_samples_leaf': 1,
        'max_features': 'sqrt',
        'bootstrap': True,
        'random_state': 42,
        'n_jobs': -1
    },
    'conservative': {
        'n_estimators': 200,
        'max_depth': 6,
        'min_samples_split': 5,
        'min_samples_leaf': 2,
        'max_features': 0.5,
        'bootstrap': True,
        'random_state': 42,
        'n_jobs': -1
    },
    'aggressive': {
        'n_estimators': 500,
        'max_depth': 20,
        'min_samples_split': 2,
        'min_samples_leaf': 1,
        'max_features': 'auto',
        'bootstrap': True,
        'random_state': 42,
        'n_jobs': -1
    }
}

# Decision Tree parameter templates
DECISION_TREE_PARAMS = {
    'default': {
        'max_depth': 5,
        'min_samples_split': 10,
        'min_samples_leaf': 5,
        'random_state': 42
    },
    'conservative': {
        'max_depth': 3,
        'min_samples_split': 20,
        'min_samples_leaf': 10,
        'random_state': 42
    },
    'aggressive': {
        'max_depth': 10,
        'min_samples_split': 2,
        'min_samples_leaf': 1,
        'random_state': 42
    }
}

def get_model_params(model_type: str, preset: str = 'default') -> Dict[str, Any]:
    """
    Get parameter template for a model type.
    
    Args:
        model_type: Type of model ('xgboost', 'lightgbm', 'catboost', 
                   'random_forest', 'decision_tree')
        preset: Preset name ('default', 'conservative', 'aggressive')
        
    Returns:
        Dict: Model parameters
    """
    params_map = {
        'xgboost': XGBOOST_PARAMS,
        'lightgbm': LIGHTGBM_PARAMS,
        'catboost': CATBOOST_PARAMS,
        'random_forest': RANDOM_FOREST_PARAMS,
        'decision_tree': DECISION_TREE_PARAMS,
        'gradient_boost': RANDOM_FOREST_PARAMS  # Use similar structure
    }
    
    if model_type not in params_map:
        raise ValueError(f"Unknown model type: {model_type}")
    
    if preset not in params_map[model_type]:
        preset = 'default'
    
    return params_map[model_type][preset]
```

#### Step 3: Model Comparator

**File:** `src/models/comparator.py`
**Path:** `ml-pipeline-project/src/models/comparator.py`

```python
"""
Model comparison framework for tree-based models.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import time
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.model_selection import cross_val_score, train_test_split
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score, roc_auc_score,
    mean_squared_error, mean_absolute_error, r2_score
)
from sklearn.base import BaseEstimator

from .tree_based import TreeModel
from .params import get_model_params

class ModelComparator:
    """
    Compare multiple tree-based models.
    
    This class trains and evaluates multiple models on the same
    dataset and provides a comprehensive comparison.
    
    Example:
        >>> comparator = ModelComparator(
        ...     models=['xgboost', 'random_forest', 'lightgbm']
        ... )
        >>> results = comparator.compare(X_train, y_train, X_test, y_test)
        >>> comparator.plot_comparison(results)
    """
    
    def __init__(
        self,
        models: List[str],
        task: str = 'classification',
        cv: int = 5,
        random_state: int = 42
    ):
        """
        Initialize the model comparator.
        
        Args:
            models: List of model types to compare
            task: Task type ('classification' or 'regression')
            cv: Number of cross-validation folds
            random_state: Random seed
        """
        self.models = models
        self.task = task
        self.cv = cv
        self.random_state = random_state
        
        self._results = None
        self._trained_models = {}
        
        logger.info(f"ModelComparator initialized with {len(models)} models")
    
    def compare(
        self,
        X_train: Union[pd.DataFrame, np.ndarray],
        y_train: Union[np.ndarray, pd.Series],
        X_test: Union[pd.DataFrame, np.ndarray],
        y_test: Union[np.ndarray, pd.Series]
    ) -> pd.DataFrame:
        """
        Compare models on the given data.
        
        Args:
            X_train: Training features
            y_train: Training target
            X_test: Test features
            y_test: Test target
            
        Returns:
            pd.DataFrame: Comparison results
        """
        results = []
        
        for model_type in self.models:
            logger.info(f"Evaluating {model_type}...")
            
            try:
                # Create and train model
                model = TreeModel(
                    model_type=model_type,
                    task=self.task,
                    **get_model_params(model_type, 'default')
                )
                
                # Time training
                start_time = time.time()
                model.fit(X_train, y_train)
                train_time = time.time() - start_time
                
                # Predictions
                start_time = time.time()
                y_pred = model.predict(X_test)
                predict_time = time.time() - start_time
                
                # Get feature importance
                importance = model.get_feature_importance()
                
                # Calculate metrics
                metrics = self._calculate_metrics(y_test, y_pred)
                
                # Cross-validation
                cv_scores = model.cross_validate(
                    X_train, y_train, cv=self.cv, verbose=False
                )
                
                # Store results
                result = {
                    'model': model_type,
                    'train_time': train_time,
                    'predict_time': predict_time,
                    'cv_mean': cv_scores['mean'],
                    'cv_std': cv_scores['std'],
                    **metrics
                }
                
                # Store model for later
                self._trained_models[model_type] = {
                    'model': model,
                    'importance': importance,
                    'predictions': y_pred
                }
                
                results.append(result)
                logger.info(f"  {model_type} completed. {metrics}")
                
            except Exception as e:
                logger.error(f"  {model_type} failed: {str(e)}")
                results.append({
                    'model': model_type,
                    'error': str(e)
                })
        
        # Convert to DataFrame
        self._results = pd.DataFrame(results)
        return self._results
    
    def _calculate_metrics(self, y_true: np.ndarray, y_pred: np.ndarray) -> Dict[str, float]:
        """Calculate performance metrics based on task."""
        metrics = {}
        
        if self.task == 'classification':
            metrics['accuracy'] = accuracy_score(y_true, y_pred)
            metrics['precision'] = precision_score(y_true, y_pred, average='weighted', zero_division=0)
            metrics['recall'] = recall_score(y_true, y_pred, average='weighted', zero_division=0)
            metrics['f1'] = f1_score(y_true, y_pred, average='weighted', zero_division=0)
            
            # Try to get ROC-AUC if binary classification
            if len(np.unique(y_true)) == 2:
                try:
                    # Need probabilities
                    model = self._trained_models.get('model')
                    if model and hasattr(model, 'predict_proba'):
                        y_proba = model.predict_proba(X_test)[:, 1]
                        metrics['roc_auc'] = roc_auc_score(y_true, y_proba)
                except:
                    pass
        
        else:  # Regression
            metrics['mse'] = mean_squared_error(y_true, y_pred)
            metrics['rmse'] = np.sqrt(metrics['mse'])
            metrics['mae'] = mean_absolute_error(y_true, y_pred)
            metrics['r2'] = r2_score(y_true, y_pred)
        
        return metrics
    
    def get_best_model(self, metric: Optional[str] = None) -> str:
        """
        Get the best model based on a metric.
        
        Args:
            metric: Metric to use for comparison
            
        Returns:
            str: Best model name
        """
        if self._results is None:
            raise ValueError("No results available. Run compare() first.")
        
        # Default metric
        if metric is None:
            metric = 'cv_mean' if 'cv_mean' in self._results.columns else 'accuracy'
        
        if metric not in self._results.columns:
            logger.warning(f"Metric {metric} not found. Using first available.")
            metric = self._results.columns[0]
        
        # For metrics where higher is better
        higher_better = metric in ['cv_mean', 'accuracy', 'precision', 'recall', 'f1', 'roc_auc', 'r2']
        
        # Filter out rows with errors
        valid_results = self._results[self._results['error'].isnull() if 'error' in self._results.columns else self._results.index]
        
        if higher_better:
            best_idx = valid_results[metric].idxmax()
        else:
            best_idx = valid_results[metric].idxmin()
        
        return valid_results.loc[best_idx, 'model']
    
    def plot_comparison(
        self,
        metrics: Optional[List[str]] = None,
        figsize: Tuple[int, int] = (12, 8)
    ):
        """
        Plot comparison of models.
        
        Args:
            metrics: Metrics to plot
            figsize: Figure size
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        import matplotlib.pyplot as plt
        
        if self._results is None:
            raise ValueError("No results available. Run compare() first.")
        
        # Default metrics
        if metrics is None:
            if self.task == 'classification':
                metrics = ['accuracy', 'precision', 'recall', 'f1']
            else:
                metrics = ['rmse', 'mae', 'r2']
        
        # Filter for available metrics
        available_metrics = [m for m in metrics if m in self._results.columns]
        if not available_metrics:
            logger.warning("No metrics available for plotting")
            return None
        
        # Filter out rows with errors
        valid_results = self._results[self._results['error'].isnull() if 'error' in self._results.columns else self._results.index]
        
        if len(valid_results) == 0:
            logger.warning("No valid results to plot")
            return None
        
        # Create subplots
        n_metrics = len(available_metrics)
        fig, axes = plt.subplots(1, n_metrics, figsize=(figsize[0], figsize[1] * 0.5))
        if n_metrics == 1:
            axes = [axes]
        
        x = np.arange(len(valid_results))
        width = 0.25
        
        for idx, metric in enumerate(available_metrics):
            ax = axes[idx]
            
            # Plot bars
            values = valid_results[metric].values
            colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(values)))
            bars = ax.bar(x, values, color=colors)
            
            # Add value labels
            for bar, val in zip(bars, values):
                height = bar.get_height()
                ax.annotate(
                    f'{val:.3f}',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 3),
                    textcoords="offset points",
                    ha='center', va='bottom',
                    fontsize=8
                )
            
            ax.set_xticks(x)
            ax.set_xticklabels(valid_results['model'], rotation=45, ha='right')
            ax.set_title(metric.upper())
            ax.set_ylabel(metric)
            ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        return fig
    
    def get_summary(self) -> Dict[str, Any]:
        """
        Get a summary of the comparison.
        
        Returns:
            Dict: Comparison summary
        """
        if self._results is None:
            return {'error': 'No results available'}
        
        summary = {
            'n_models': len(self._results),
            'task': self.task,
            'cv': self.cv
        }
        
        # Find best model by different metrics
        for col in ['cv_mean', 'accuracy', 'f1', 'roc_auc', 'r2']:
            if col in self._results.columns and col != 'error':
                try:
                    valid = self._results[self._results['error'].isnull() if 'error' in self._results.columns else self._results.index]
                    if col in valid.columns:
                        best_idx = valid[col].idxmax()
                        summary[f'best_{col}'] = valid.loc[best_idx, 'model']
                except:
                    pass
        
        return summary
```

### The Verification: Testing Our Tree-Based System

#### Test 1: Basic Model Training

```bash
cat > test_tree_models.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from src.models.tree_based import TreeModel

# Create dataset
X, y = make_classification(
    n_samples=1000,
    n_features=20,
    n_informative=10,
    n_redundant=5,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print("Dataset shape:", X.shape)
print("Train shape:", X_train.shape)
print("Test shape:", X_test.shape)

# Test Decision Tree
print("\n" + "="*60)
print("Test 1: Decision Tree")
print("="*60)

dt = TreeModel(model_type='decision_tree', task='classification', max_depth=5)
dt.fit(X_train, y_train)
y_pred = dt.predict(X_test)
print(f"Accuracy: {np.mean(y_pred == y_test):.4f}")

# Test Random Forest
print("\n" + "="*60)
print("Test 2: Random Forest")
print("="*60)

rf = TreeModel(model_type='random_forest', task='classification', n_estimators=50)
rf.fit(X_train, y_train)
y_pred = rf.predict(X_test)
print(f"Accuracy: {np.mean(y_pred == y_test):.4f}")

# Test XGBoost
print("\n" + "="*60)
print("Test 3: XGBoost")
print("="*60)

try:
    xgb = TreeModel(model_type='xgboost', task='classification', n_estimators=50)
    xgb.fit(X_train, y_train)
    y_pred = xgb.predict(X_test)
    print(f"Accuracy: {np.mean(y_pred == y_test):.4f}")
    print(f"Feature importance available: {len(xgb.get_feature_importance()) > 0}")
except ImportError:
    print("XGBoost not installed. Skipping.")

# Test LightGBM
print("\n" + "="*60)
print("Test 4: LightGBM")
print("="*60)

try:
    lgb = TreeModel(model_type='lightgbm', task='classification', n_estimators=50)
    lgb.fit(X_train, y_train)
    y_pred = lgb.predict(X_test)
    print(f"Accuracy: {np.mean(y_pred == y_test):.4f}")
except ImportError:
    print("LightGBM not installed. Skipping.")

# Test CatBoost
print("\n" + "="*60)
print("Test 5: CatBoost")
print("="*60)

try:
    cat = TreeModel(model_type='catboost', task='classification', iterations=50)
    cat.fit(X_train, y_train)
    y_pred = cat.predict(X_test)
    print(f"Accuracy: {np.mean(y_pred == y_test):.4f}")
except ImportError:
    print("CatBoost not installed. Skipping.")

# Cross-validation
print("\n" + "="*60)
print("Cross-Validation")
print("="*60)

rf = TreeModel(model_type='random_forest', task='classification')
cv_results = rf.cross_validate(X_train, y_train, cv=5)
print(f"CV Mean: {cv_results['mean']:.4f} (+/- {cv_results['std']:.4f})")

print("\n✅ Tree models test complete!")
EOF

python test_tree_models.py
```

#### Test 2: Model Comparison

```bash
cat > test_model_comparison.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from src.models.comparator import ModelComparator

# Create dataset
X, y = make_classification(
    n_samples=1000,
    n_features=20,
    n_informative=10,
    n_redundant=5,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print("Dataset shape:", X.shape)
print("Train shape:", X_train.shape)
print("Test shape:", X_test.shape)

# Define models to compare
models = ['decision_tree', 'random_forest', 'xgboost', 'lightgbm']

# Create comparator
comparator = ModelComparator(
    models=models,
    task='classification',
    cv=3
)

# Run comparison
results = comparator.compare(X_train, y_train, X_test, y_test)

print("\n" + "="*60)
print("Comparison Results")
print("="*60)
print(results.to_string())

# Get best model
best = comparator.get_best_model()
print(f"\nBest model: {best}")

# Plot comparison
fig = comparator.plot_comparison()
if fig:
    fig.savefig('reports/figures/model_comparison.png', dpi=100, bbox_inches='tight')
    print("\nComparison plot saved to: reports/figures/model_comparison.png")

# Get summary
summary = comparator.get_summary()
print(f"\nSummary:")
for key, value in summary.items():
    print(f"  {key}: {value}")

print("\n✅ Model comparison test complete!")
EOF

python test_model_comparison.py
```

#### Test 3: Feature Importance Visualization

```bash
cat > test_feature_importance.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from src.models.tree_based import TreeModel
from src.models.comparator import ModelComparator

# Create dataset with known feature importance
np.random.seed(42)
X, y = make_classification(
    n_samples=500,
    n_features=10,
    n_informative=3,
    n_redundant=2,
    n_classes=2,
    random_state=42
)

# Name features
feature_names = [f'feature_{i}' for i in range(X.shape[1])]
X = pd.DataFrame(X, columns=feature_names)

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train model
model = TreeModel(model_type='random_forest', task='classification')
model.fit(X_train, y_train)

# Get feature importance
importance = model.get_feature_importance()
print("Feature Importance:")
for name, imp in sorted(importance.items(), key=lambda x: x[1], reverse=True):
    print(f"  {name}: {imp:.4f}")

# Plot importance
fig = model.plot_importance(top_k=10)
if fig:
    fig.savefig('reports/figures/feature_importance.png', dpi=100, bbox_inches='tight')
    print("\nFeature importance plot saved to: reports/figures/feature_importance.png")

# Compare feature importance across models
print("\n" + "="*60)
print("Feature Importance Across Models")
print("="*60)

models = ['decision_tree', 'random_forest', 'xgboost']

for model_type in models:
    try:
        m = TreeModel(model_type=model_type, task='classification', n_estimators=50)
        m.fit(X_train, y_train)
        imp = m.get_feature_importance()
        top = sorted(imp.items(), key=lambda x: x[1], reverse=True)[:3]
        print(f"\n{model_type} top features:")
        for name, val in top:
            print(f"  {name}: {val:.4f}")
    except Exception as e:
        print(f"  {model_type}: {str(e)}")

print("\n✅ Feature importance test complete!")
EOF

python test_feature_importance.py
```

### What Just Happened: Understanding Tree-Based Models

#### The Decision Tree

**How it works**: 
1. Start with all data at the root
2. Find the best feature to split on (maximizes purity)
3. Split the data into two child nodes
4. Repeat recursively on each child
5. Stop when a stopping criterion is met (max depth, min samples, etc.)

**Splitting Criteria**:
- **Classification**: Gini impurity, entropy
- **Regression**: Mean squared error, mean absolute error

**Pros**: Interpretable, handles non-linearity, no scaling needed
**Cons**: Prone to overfitting, unstable (small changes in data can change tree)

#### The Random Forest

**How it works**: 
1. Create B bootstrap samples from the original data
2. For each sample, grow a decision tree
3. At each split, consider only a random subset of features
4. Aggregate predictions (majority vote for classification, average for regression)

**Why it's better**:
- **Bagging**: Reduces variance by averaging
- **Feature randomization**: Reduces correlation between trees
- **Out-of-bag error**: Built-in validation

**Pros**: Robust to overfitting, handles many features well, provides feature importance
**Cons**: Less interpretable, more memory intensive

#### Gradient Boosting (XGBoost, LightGBM, CatBoost)

**How it works**:
1. Start with a simple initial prediction
2. Fit a small tree to the residuals (errors)
3. Add this tree to the ensemble with a learning rate
4. Repeat for many iterations

**Key differences between implementations**:

| Feature | XGBoost | LightGBM | CatBoost |
|---------|---------|----------|----------|
| Splitting | Level-wise | Leaf-wise | Level-wise |
| Categorical | Manual encoding | Manual encoding | Native support |
| Speed | Fast | Very fast | Moderate |
| Memory | Moderate | Low | Moderate |
| Best for | Tabular data | Large datasets | Categorical features |

### Summary

In this part, we've built a comprehensive tree-based modeling system that:

1. **Provides a unified interface** for all tree-based models
2. **Implements Decision Trees, Random Forest, XGBoost, LightGBM, and CatBoost**
3. **Handles both classification and regression** tasks
4. **Extracts feature importance** from all models
5. **Compares models** using a comprehensive framework
6. **Visualizes** feature importance and model comparison
7. **Uses parameter templates** for different modeling scenarios

### What's Next

In Part 9, we'll explore unsupervised learning with clustering algorithms including K-Means, DBSCAN, and Hierarchical Clustering, along with validation metrics like Silhouette Score.
