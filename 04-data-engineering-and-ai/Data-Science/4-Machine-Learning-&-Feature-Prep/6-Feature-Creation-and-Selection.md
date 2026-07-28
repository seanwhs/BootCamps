# Module 4.1: Feature Prep & Engineering

## Part 6: Feature Creation and Selection

Welcome back! In Part 5, we mastered categorical encoding. Now we'll tackle two interconnected challenges: creating powerful new features from existing ones and selecting the most informative features for our models. This is where domain expertise meets automated intelligence.

### The Target: A Complete Feature Engineering System

By the end of this part, you'll have:
1. Automated feature creation (interactions, polynomials, ratios, aggregations)
2. Domain-specific feature generators
3. Multiple feature selection methods (filter, wrapper, embedded)
4. Feature importance analysis
5. Integration with our preprocessing pipeline
6. Visualization of feature importance and selection effects

### The Concept: Why Feature Engineering is the Secret Sauce

Here's a truth that separates expert data scientists from beginners: **Feature engineering is where most of the predictive power comes from.**

Think of it like cooking:

- **Raw ingredients** (original data): Flour, eggs, sugar, butter
- **Basic preparation** (preprocessing): Sifting flour, melting butter
- **Feature engineering** (creating new ingredients): Making a custard, whipping cream
- **The model** (the recipe): Combining ingredients to create a dish

You can have the best recipe (model) in the world, but without well-prepared ingredients (features), you'll never create a masterpiece. The difference between average and exceptional results often comes down to feature engineering.

**The Feature Engineering Flywheel:**

```
More informative features → Better model performance
Better model performance → Better understanding of what matters
Better understanding → Better feature engineering ideas
Better feature ideas → Even more informative features
```

### The Implementation: Building Our Feature Engineering System

#### Step 1: Feature Creation

**File:** `src/features/creation.py`
**Path:** `ml-pipeline-project/src/features/creation.py`

```python
"""
Automated feature creation and transformation.

This module provides tools for creating new features from existing ones,
including interactions, polynomials, ratios, and domain-specific transformations.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import itertools
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.preprocessing import PolynomialFeatures
from sklearn.feature_selection import SelectKBest, f_regression, f_classif

class FeatureCreator:
    """
    Automated feature creation from existing features.
    
    This class generates new features through various transformations:
    - Polynomial features (x^2, x^3, etc.)
    - Interaction features (x1 * x2, x1 / x2, etc.)
    - Ratio features (x1 / x2, x1 - x2)
    - Aggregation features (sum, mean, max, min across groups)
    - Domain-specific transformations (log, sqrt, etc.)
    
    Example:
        >>> creator = FeatureCreator(
        ...     polynomial_degree=2,
        ...     interactions=True,
        ...     ratios=True
        ... )
        >>> X_enhanced = creator.fit_transform(X)
    """
    
    def __init__(
        self,
        polynomial_degree: Optional[int] = None,
        interactions: bool = True,
        ratios: bool = False,
        include_bias: bool = False,
        group_columns: Optional[List[str]] = None,
        aggregation_functions: List[str] = ['mean', 'sum', 'max', 'min', 'std'],
        **kwargs
    ):
        """
        Initialize the feature creator.
        
        Args:
            polynomial_degree: Degree of polynomial features (None for no polynomials)
            interactions: Whether to create interaction features
            ratios: Whether to create ratio features (x1 / x2)
            include_bias: Whether to include a bias column (intercept)
            group_columns: Columns to group by for aggregation features
            aggregation_functions: Functions to apply for aggregation
            **kwargs: Additional arguments
        """
        self.polynomial_degree = polynomial_degree
        self.interactions = interactions
        self.ratios = ratios
        self.include_bias = include_bias
        self.group_columns = group_columns
        self.aggregation_functions = aggregation_functions
        
        self._feature_names = []
        self._created_features = []
        self._poly_transformer = None
        
        logger.info("FeatureCreator initialized")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'FeatureCreator':
        """
        Fit the feature creator (identifies columns and configurations).
        
        Args:
            X: Input data
            y: Target (optional, for supervised transformations)
            
        Returns:
            FeatureCreator: Fitted creator
        """
        X = self._prepare_data(X)
        
        # Store column names
        self._original_columns = X.columns.tolist()
        self._numeric_columns = X.select_dtypes(include=[np.number]).columns.tolist()
        
        # Initialize polynomial transformer if needed
        if self.polynomial_degree and self.polynomial_degree > 0 and self._numeric_columns:
            self._poly_transformer = PolynomialFeatures(
                degree=self.polynomial_degree,
                include_bias=self.include_bias,
                interaction_only=not self.interactions
            )
            self._poly_transformer.fit(X[self._numeric_columns])
            
            # Get polynomial feature names
            poly_names = self._poly_transformer.get_feature_names_out(self._numeric_columns)
            self._created_features.extend(poly_names)
        
        self._fitted = True
        logger.info(f"FeatureCreator fitted with {len(self._numeric_columns)} numeric columns")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data by creating new features.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Enhanced data
        """
        if not self._fitted:
            raise ValueError("FeatureCreator has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        result = X.copy()
        
        # Create polynomial features
        if self._poly_transformer and self._numeric_columns:
            poly_features = self._poly_transformer.transform(X[self._numeric_columns])
            poly_df = pd.DataFrame(
                poly_features,
                columns=self._created_features[:poly_features.shape[1]],
                index=X.index
            )
            # Exclude original columns (they're already in result)
            original_cols = set(self._numeric_columns)
            new_cols = [col for col in poly_df.columns if col not in original_cols]
            result = pd.concat([result, poly_df[new_cols]], axis=1)
        
        # Create ratio features
        if self.ratios and len(self._numeric_columns) >= 2:
            ratio_features = self._create_ratio_features(X)
            result = pd.concat([result, ratio_features], axis=1)
        
        # Create aggregation features
        if self.group_columns:
            agg_features = self._create_aggregation_features(X)
            result = pd.concat([result, agg_features], axis=1)
        
        return result
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit and transform in one step.
        """
        self.fit(X, y)
        return self.transform(X)
    
    def _create_ratio_features(self, X: pd.DataFrame) -> pd.DataFrame:
        """
        Create ratio features from numeric columns.
        
        Args:
            X: Input data
            
        Returns:
            pd.DataFrame: Ratio features
        """
        numeric_cols = self._numeric_columns
        ratio_features = {}
        
        for i, col1 in enumerate(numeric_cols):
            for col2 in numeric_cols[i+1:]:
                # Avoid division by zero
                denom = X[col2].replace(0, np.nan)
                
                # Ratio
                ratio_name = f"{col1}_div_{col2}"
                ratio_features[ratio_name] = X[col1] / denom
                
                # Inverse ratio
                ratio_name = f"{col2}_div_{col1}"
                ratio_features[ratio_name] = X[col2] / X[col1].replace(0, np.nan)
                
                # Difference
                ratio_name = f"{col1}_minus_{col2}"
                ratio_features[ratio_name] = X[col1] - X[col2]
                
                # Product
                ratio_name = f"{col1}_times_{col2}"
                ratio_features[ratio_name] = X[col1] * X[col2]
        
        # Handle infinite values
        for key in ratio_features:
            ratio_features[key] = ratio_features[key].replace([np.inf, -np.inf], np.nan)
        
        return pd.DataFrame(ratio_features, index=X.index)
    
    def _create_aggregation_features(self, X: pd.DataFrame) -> pd.DataFrame:
        """
        Create aggregation features based on group columns.
        
        Args:
            X: Input data
            
        Returns:
            pd.DataFrame: Aggregation features
        """
        if not self.group_columns:
            return pd.DataFrame(index=X.index)
        
        # Ensure group columns exist
        group_cols = [col for col in self.group_columns if col in X.columns]
        if not group_cols:
            return pd.DataFrame(index=X.index)
        
        # Get numeric columns to aggregate
        numeric_cols = [col for col in self._numeric_columns if col not in group_cols]
        if not numeric_cols:
            return pd.DataFrame(index=X.index)
        
        agg_features = {}
        
        # For each group by combination
        for group_col in group_cols:
            grouped = X.groupby(group_col)
            
            for num_col in numeric_cols:
                for func in self.aggregation_functions:
                    try:
                        # Get aggregated values
                        agg_values = grouped[num_col].agg(func)
                        
                        # Map back to original rows
                        feature_name = f"{group_col}_{num_col}_{func}"
                        agg_features[feature_name] = X[group_col].map(agg_values)
                    except Exception as e:
                        logger.debug(f"Could not create aggregation {func} for {num_col}: {str(e)}")
        
        return pd.DataFrame(agg_features, index=X.index)
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def get_feature_names(self) -> List[str]:
        """Get all feature names after transformation."""
        if not self._fitted:
            return self._original_columns or []
        
        # Start with original columns
        names = self._original_columns.copy()
        
        # Add polynomial features (excluding original columns)
        if self._poly_transformer:
            poly_names = self._poly_transformer.get_feature_names_out(self._numeric_columns)
            original_set = set(self._original_columns)
            names.extend([name for name in poly_names if name not in original_set])
        
        # Add ratio features
        if self.ratios and self._numeric_columns:
            for i, col1 in enumerate(self._numeric_columns):
                for col2 in self._numeric_columns[i+1:]:
                    names.extend([
                        f"{col1}_div_{col2}",
                        f"{col2}_div_{col1}",
                        f"{col1}_minus_{col2}",
                        f"{col1}_times_{col2}"
                    ])
        
        return names
    
    def get_feature_importance(self, X: pd.DataFrame, y: np.ndarray, method: str = 'correlation') -> Dict[str, float]:
        """
        Calculate importance of created features.
        
        Args:
            X: Input data
            y: Target values
            method: Importance calculation method
            
        Returns:
            Dict: Feature to importance mapping
        """
        # Transform data to get all features
        X_enhanced = self.transform(X)
        
        # Calculate importance
        importance = {}
        
        if method == 'correlation':
            # Simple correlation with target
            for col in X_enhanced.columns:
                if pd.api.types.is_numeric_dtype(X_enhanced[col]):
                    clean_data = X_enhanced[[col]].dropna()
                    if len(clean_data) > 0:
                        corr = np.corrcoef(clean_data[col], y[clean_data.index])[0, 1]
                        importance[col] = abs(corr) if not np.isnan(corr) else 0.0
        
        elif method == 'mutual_info':
            from sklearn.feature_selection import mutual_info_regression
            
            X_clean = X_enhanced.select_dtypes(include=[np.number])
            mi = mutual_info_regression(X_clean, y, random_state=42)
            importance = {col: score for col, score in zip(X_clean.columns, mi)}
        
        return importance
```

#### Step 2: Feature Selection

**File:** `src/features/selection.py`
**Path:** `ml-pipeline-project/src/features/selection.py`

```python
"""
Advanced feature selection methods.

This module provides multiple feature selection techniques:
- Filter methods (statistical tests)
- Wrapper methods (recursive feature elimination)
- Embedded methods (feature importance from models)
- Hybrid methods (combining approaches)
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.feature_selection import (
    SelectKBest,
    SelectPercentile,
    VarianceThreshold,
    RFE,
    RFECV,
    SelectFromModel,
    mutual_info_regression,
    mutual_info_classif,
    f_regression,
    f_classif,
    chi2
)
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.linear_model import Lasso, LogisticRegression
from sklearn.model_selection import cross_val_score
import warnings

warnings.filterwarnings("ignore", category=UserWarning)

class FeatureSelector(BaseEstimator, TransformerMixin):
    """
    Comprehensive feature selection with multiple methods.
    
    This class provides a unified interface for various feature
    selection techniques:
    - Variance threshold (remove constant features)
    - Statistical tests (correlation, chi-square, mutual info)
    - Recursive feature elimination
    - Model-based feature importance
    - Combination of methods
    
    Example:
        >>> selector = FeatureSelector(
        ...     method='rfe',
        ...     n_features_to_select=20,
        ...     estimator=RandomForestRegressor()
        ... )
        >>> X_selected = selector.fit_transform(X, y)
    """
    
    def __init__(
        self,
        method: str = 'variance',
        n_features_to_select: Optional[int] = None,
        percentile: Optional[float] = None,
        threshold: Optional[float] = None,
        estimator: Optional[BaseEstimator] = None,
        scoring: Optional[str] = None,
        cv: int = 5,
        random_state: int = 42,
        **kwargs
    ):
        """
        Initialize the feature selector.
        
        Args:
            method: Selection method ('variance', 'correlation', 'mutual_info', 
                   'rfe', 'rfecv', 'model', 'lasso', 'ensemble')
            n_features_to_select: Number of features to select
            percentile: Percentile of features to keep
            threshold: Variance threshold (for variance method)
            estimator: Base estimator (for model-based methods)
            scoring: Scoring metric for RFECV
            cv: Number of cross-validation folds
            random_state: Random seed
            **kwargs: Additional arguments
        """
        self.method = method
        self.n_features_to_select = n_features_to_select
        self.percentile = percentile
        self.threshold = threshold
        self.estimator = estimator
        self.scoring = scoring
        self.cv = cv
        self.random_state = random_state
        self.kwargs = kwargs
        
        self._selector = None
        self._feature_names = None
        self._selected_indices = None
        self._feature_importances = None
        
        logger.info(f"FeatureSelector initialized with method={method}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'FeatureSelector':
        """
        Fit the feature selector.
        
        Args:
            X: Input data
            y: Target values (required for supervised methods)
            
        Returns:
            FeatureSelector: Fitted selector
        """
        X = self._prepare_data(X)
        self._feature_names = X.columns.tolist() if hasattr(X, 'columns') else None
        
        # Create the appropriate selector
        self._selector = self._create_selector(X, y)
        
        # Fit the selector
        if self.method in ['rfe', 'rfecv', 'model', 'lasso']:
            if y is None:
                raise ValueError(f"Method '{self.method}' requires target values (y)")
            self._selector.fit(X, y)
        else:
            self._selector.fit(X)
        
        # Store selected indices
        if hasattr(self._selector, 'get_support'):
            self._selected_indices = self._selector.get_support()
        
        # Store feature importances if available
        if hasattr(self._selector, 'feature_importances_'):
            self._feature_importances = self._selector.feature_importances_
        elif hasattr(self._selector, 'coef_'):
            self._feature_importances = self._selector.coef_
        
        logger.info(f"FeatureSelector fitted. Selected {self.get_n_selected()} features out of {X.shape[1]}")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data by selecting features.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Selected features
        """
        if self._selector is None:
            raise ValueError("FeatureSelector has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        X_selected = self._selector.transform(X)
        
        # Convert back to DataFrame if input was DataFrame
        if isinstance(X, pd.DataFrame):
            selected_columns = X.columns[self._selected_indices] if self._selected_indices is not None else None
            if selected_columns is not None:
                return pd.DataFrame(X_selected, columns=selected_columns, index=X.index)
            else:
                return pd.DataFrame(X_selected, index=X.index)
        
        return X_selected
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit and transform in one step.
        """
        self.fit(X, y)
        return self.transform(X)
    
    def _create_selector(self, X: pd.DataFrame, y: Optional[np.ndarray] = None):
        """
        Create the appropriate selector based on method.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            sklearn selector: Configured selector
        """
        if self.method == 'variance':
            return VarianceThreshold(threshold=self.threshold or 0.0)
        
        elif self.method == 'correlation':
            # Use f_regression or f_classif based on target type
            if y is not None and len(np.unique(y)) <= 2:
                score_func = f_classif
            else:
                score_func = f_regression
            
            if self.percentile is not None:
                return SelectPercentile(score_func=score_func, percentile=self.percentile)
            else:
                return SelectKBest(score_func=score_func, k=self.n_features_to_select or 10)
        
        elif self.method == 'mutual_info':
            if y is not None and len(np.unique(y)) <= 2:
                score_func = mutual_info_classif
            else:
                score_func = mutual_info_regression
            
            if self.percentile is not None:
                return SelectPercentile(score_func=score_func, percentile=self.percentile)
            else:
                return SelectKBest(score_func=score_func, k=self.n_features_to_select or 10)
        
        elif self.method == 'chi2':
            # Chi-square requires non-negative integer values
            return SelectKBest(score_func=chi2, k=self.n_features_to_select or 10)
        
        elif self.method == 'rfe':
            if self.estimator is None:
                raise ValueError("RFE requires an estimator")
            return RFE(
                estimator=self.estimator,
                n_features_to_select=self.n_features_to_select or 10,
                **self.kwargs
            )
        
        elif self.method == 'rfecv':
            if self.estimator is None:
                raise ValueError("RFECV requires an estimator")
            return RFECV(
                estimator=self.estimator,
                step=1,
                cv=self.cv,
                scoring=self.scoring,
                **self.kwargs
            )
        
        elif self.method == 'model':
            if self.estimator is None:
                # Use default random forest
                if y is not None and len(np.unique(y)) <= 2:
                    self.estimator = RandomForestClassifier(
                        n_estimators=100,
                        random_state=self.random_state
                    )
                else:
                    self.estimator = RandomForestRegressor(
                        n_estimators=100,
                        random_state=self.random_state
                    )
            
            return SelectFromModel(
                self.estimator,
                threshold=self.threshold,
                **self.kwargs
            )
        
        elif self.method == 'lasso':
            # Lasso for regression, LogisticRegression with L1 for classification
            if y is not None and len(np.unique(y)) <= 2:
                estimator = LogisticRegression(
                    penalty='l1',
                    solver='saga',
                    random_state=self.random_state,
                    max_iter=1000,
                    **self.kwargs
                )
            else:
                estimator = Lasso(
                    alpha=self.threshold or 0.01,
                    random_state=self.random_state,
                    **self.kwargs
                )
            
            return SelectFromModel(estimator, threshold=1e-5)
        
        elif self.method == 'ensemble':
            # Use multiple models and select features that appear in all
            # This is a simplified version
            if y is not None and len(np.unique(y)) <= 2:
                estimators = [
                    RandomForestClassifier(n_estimators=50, random_state=self.random_state),
                    LogisticRegression(penalty='l1', solver='saga', max_iter=1000)
                ]
            else:
                estimators = [
                    RandomForestRegressor(n_estimators=50, random_state=self.random_state),
                    Lasso(alpha=0.01)
                ]
            
            # Get feature importances from each model
            importances = []
            for est in estimators:
                est.fit(X, y)
                if hasattr(est, 'feature_importances_'):
                    importances.append(est.feature_importances_)
                elif hasattr(est, 'coef_'):
                    importances.append(np.abs(est.coef_))
            
            # Average importances
            avg_importance = np.mean(importances, axis=0)
            
            # Select top features
            n_features = self.n_features_to_select or (X.shape[1] // 2)
            indices = np.argsort(avg_importance)[-n_features:]
            
            # Create a selector using the indices
            class CustomSelector:
                def __init__(self, indices):
                    self.indices = indices
                    self.feature_importances_ = avg_importance
                
                def fit(self, X, y=None):
                    return self
                
                def transform(self, X):
                    if isinstance(X, pd.DataFrame):
                        return X.iloc[:, self.indices]
                    return X[:, self.indices]
                
                def get_support(self):
                    return np.isin(np.arange(len(avg_importance)), self.indices)
            
            return CustomSelector(indices)
        
        else:
            raise ValueError(f"Unknown method: {self.method}")
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def get_n_selected(self) -> int:
        """Get the number of selected features."""
        if self._selected_indices is None:
            return 0
        return int(self._selected_indices.sum())
    
    def get_selected_features(self) -> List[str]:
        """Get the names of selected features."""
        if self._feature_names is None or self._selected_indices is None:
            return []
        return [self._feature_names[i] for i, selected in enumerate(self._selected_indices) if selected]
    
    def get_importance_dict(self) -> Dict[str, float]:
        """Get feature importance mapping."""
        if self._feature_names is None or self._feature_importances is None:
            return {}
        
        # Handle case where importance array might be 2D
        if len(self._feature_importances.shape) > 1:
            importances = self._feature_importances.flatten()
        else:
            importances = self._feature_importances
        
        # Ensure lengths match
        if len(importances) != len(self._feature_names):
            # For coefficients that might have different length
            # Use first n features
            n = min(len(importances), len(self._feature_names))
            names = self._feature_names[:n]
            return {name: float(imp) for name, imp in zip(names, importances[:n])}
        
        return {name: float(imp) for name, imp in zip(self._feature_names, importances)}
    
    def get_selection_summary(self) -> Dict[str, Any]:
        """
        Get a summary of the feature selection.
        
        Returns:
            Dict: Selection summary
        """
        return {
            "method": self.method,
            "total_features": len(self._feature_names) if self._feature_names else 0,
            "selected_features": self.get_n_selected(),
            "selection_percentage": (self.get_n_selected() / len(self._feature_names) * 100) 
                                   if self._feature_names else 0,
            "selected_feature_names": self.get_selected_features(),
            "feature_importances": self.get_importance_dict()
        }

class AutoFeatureSelector:
    """
    Automatic feature selection with multiple strategies.
    
    This class combines multiple selection methods and picks the best
    based on cross-validation performance.
    """
    
    def __init__(
        self,
        methods: List[str] = None,
        n_features_list: List[int] = None,
        estimator: Optional[BaseEstimator] = None,
        scoring: str = 'neg_mean_squared_error',
        cv: int = 5,
        random_state: int = 42
    ):
        """
        Initialize the automatic feature selector.
        
        Args:
            methods: List of selection methods to try
            n_features_list: List of feature counts to try
            estimator: Base estimator for evaluation
            scoring: Scoring metric
            cv: Number of cross-validation folds
            random_state: Random seed
        """
        self.methods = methods or ['variance', 'mutual_info', 'model', 'lasso']
        self.n_features_list = n_features_list or [10, 20, 30, 50, 100]
        self.estimator = estimator
        self.scoring = scoring
        self.cv = cv
        self.random_state = random_state
        
        self._best_selector = None
        self._best_score = None
        self._results = []
        
        logger.info("AutoFeatureSelector initialized")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y: np.ndarray) -> 'AutoFeatureSelector':
        """
        Fit the automatic selector by trying multiple methods.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            AutoFeatureSelector: Fitted selector
        """
        X = self._prepare_data(X)
        
        # Create default estimator if none provided
        if self.estimator is None:
            if len(np.unique(y)) <= 2:
                self.estimator = RandomForestClassifier(n_estimators=100, random_state=self.random_state)
            else:
                self.estimator = RandomForestRegressor(n_estimators=100, random_state=self.random_state)
        
        best_score = -np.inf
        best_selector = None
        
        for method in self.methods:
            for n_features in self.n_features_list:
                try:
                    # Skip if n_features > total features
                    if n_features >= X.shape[1]:
                        continue
                    
                    # Create selector
                    selector = FeatureSelector(
                        method=method,
                        n_features_to_select=n_features,
                        estimator=self.estimator,
                        random_state=self.random_state
                    )
                    
                    # Fit selector
                    X_selected = selector.fit_transform(X, y)
                    
                    # Evaluate using cross-validation
                    scores = cross_val_score(
                        self.estimator,
                        X_selected,
                        y,
                        cv=self.cv,
                        scoring=self.scoring
                    )
                    
                    mean_score = np.mean(scores)
                    
                    self._results.append({
                        'method': method,
                        'n_features': n_features,
                        'mean_score': mean_score,
                        'std_score': np.std(scores)
                    })
                    
                    if mean_score > best_score:
                        best_score = mean_score
                        best_selector = selector
                        
                        logger.info(f"New best: method={method}, n_features={n_features}, score={mean_score:.4f}")
                
                except Exception as e:
                    logger.debug(f"Method {method} with {n_features} features failed: {str(e)}")
                    continue
        
        self._best_selector = best_selector
        self._best_score = best_score
        
        logger.info(f"AutoFeatureSelector complete. Best score: {best_score:.4f}")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data using the best selector.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Selected features
        """
        if self._best_selector is None:
            raise ValueError("AutoFeatureSelector has not been fitted yet. Call fit() first.")
        
        return self._best_selector.transform(X)
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y: np.ndarray) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit and transform in one step.
        """
        self.fit(X, y)
        return self.transform(X)
    
    def get_best_method(self) -> str:
        """Get the best performing method."""
        if not self._results:
            return None
        best_result = max(self._results, key=lambda x: x['mean_score'])
        return best_result['method']
    
    def get_best_n_features(self) -> int:
        """Get the best number of features."""
        if not self._results:
            return None
        best_result = max(self._results, key=lambda x: x['mean_score'])
        return best_result['n_features']
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def get_summary(self) -> pd.DataFrame:
        """Get a summary of all results."""
        return pd.DataFrame(self._results)
```

#### Step 3: Visualization of Feature Engineering

**File:** `src/features/visualization.py`
**Path:** `ml-pipeline-project/src/features/visualization.py` (extend existing)

```python
"""
Feature engineering visualization utilities (extended).
"""

from typing import Dict, List, Optional, Union, Any
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
from loguru import logger

# Extend the existing EncodingVisualizer class with feature engineering methods

class FeatureEngineeringVisualizer:
    """
    Visualization utilities for feature engineering.
    """
    
    def __init__(
        self,
        figsize: Tuple[int, int] = (12, 8),
        dpi: int = 100
    ):
        self.figsize = figsize
        self.dpi = dpi
        plt.style.use('seaborn-v0_8-whitegrid')
    
    def plot_feature_importance(
        self,
        importance_dict: Dict[str, float],
        top_k: int = 20,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Plot feature importance.
        
        Args:
            importance_dict: Dictionary mapping feature names to importance scores
            top_k: Number of top features to show
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        # Sort by importance
        sorted_items = sorted(importance_dict.items(), key=lambda x: x[1], reverse=True)
        top_items = sorted_items[:top_k]
        
        features, importances = zip(*top_items) if top_items else ([], [])
        
        fig, ax = plt.subplots(figsize=(self.figsize[0], self.figsize[1] * 0.6))
        
        ax.barh(range(len(features)), importances, color='steelblue')
        ax.set_yticks(range(len(features)))
        ax.set_yticklabels(features)
        ax.set_xlabel('Importance')
        ax.set_title(f'Top {len(features)} Feature Importances')
        ax.invert_yaxis()
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Feature importance plot saved to: {output_path}")
        
        return fig
    
    def plot_feature_selection_comparison(
        self,
        X_original: pd.DataFrame,
        X_selected: pd.DataFrame,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Compare original and selected features.
        
        Args:
            X_original: Original data
            X_selected: Selected features
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        fig, axes = plt.subplots(1, 2, figsize=(self.figsize[0], self.figsize[1] * 0.5))
        
        # Original features
        ax = axes[0]
        corr = X_original.select_dtypes(include=[np.number]).corr()
        sns.heatmap(corr, ax=ax, cmap='coolwarm', center=0, square=True, 
                   annot=False, cbar_kws={'shrink': 0.8})
        ax.set_title(f'Original Features ({X_original.shape[1]})')
        
        # Selected features
        ax = axes[1]
        corr = X_selected.select_dtypes(include=[np.number]).corr()
        sns.heatmap(corr, ax=ax, cmap='coolwarm', center=0, square=True,
                   annot=False, cbar_kws={'shrink': 0.8})
        ax.set_title(f'Selected Features ({X_selected.shape[1]})')
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Feature selection comparison saved to: {output_path}")
        
        return fig
    
    def plot_created_features_impact(
        self,
        X_original: pd.DataFrame,
        X_enhanced: pd.DataFrame,
        y: np.ndarray,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Plot the impact of created features on model performance.
        
        Args:
            X_original: Original data
            X_enhanced: Data with created features
            y: Target values
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        from sklearn.ensemble import RandomForestRegressor
        from sklearn.model_selection import cross_val_score
        
        # Train a simple model on both datasets
        model = RandomForestRegressor(n_estimators=50, random_state=42)
        
        scores_original = cross_val_score(model, X_original, y, cv=3, scoring='neg_mean_squared_error')
        scores_enhanced = cross_val_score(model, X_enhanced, y, cv=3, scoring='neg_mean_squared_error')
        
        fig, ax = plt.subplots(figsize=(self.figsize[0], self.figsize[1] * 0.4))
        
        x_pos = np.arange(2)
        means = [-np.mean(scores_original), -np.mean(scores_enhanced)]
        stds = [np.std(scores_original), np.std(scores_enhanced)]
        
        ax.bar(x_pos, means, yerr=stds, capsize=10, color=['steelblue', 'coral'])
        ax.set_xticks(x_pos)
        ax.set_xticklabels(['Original', 'Enhanced'])
        ax.set_ylabel('Mean Squared Error (lower is better)')
        ax.set_title('Impact of Feature Creation on Model Performance')
        
        # Add value labels
        for i, v in enumerate(means):
            ax.text(i, v + 0.5, f'{v:.2f}', ha='center', va='bottom')
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Feature impact plot saved to: {output_path}")
        
        return fig
```

### The Verification: Testing Our Feature Engineering System

#### Test 1: Feature Creation

```bash
cat > test_feature_creation.py << 'EOF'
import pandas as pd
import numpy as np
from src.features.creation import FeatureCreator

# Create sample data
np.random.seed(42)
n_samples = 500

df = pd.DataFrame({
    'x1': np.random.normal(10, 2, n_samples),
    'x2': np.random.normal(5, 1, n_samples),
    'x3': np.random.uniform(0, 10, n_samples),
    'x4': np.random.choice(['A', 'B', 'C'], n_samples),
    'target': np.random.normal(50, 10, n_samples)
})

# Add some relationships
df['target'] = df['target'] + 3*df['x1'] - 2*df['x2'] + 0.5*df['x1']*df['x2']

print("Original data:")
print(f"Shape: {df.shape}")
print(f"Columns: {df.columns.tolist()}")

# Test feature creator with polynomials
print("\n" + "="*60)
print("Test 1: Polynomial Features")
print("="*60)

creator = FeatureCreator(
    polynomial_degree=2,
    interactions=True,
    include_bias=False
)

X = df.drop('target', axis=1)
X_enhanced = creator.fit_transform(X)

print(f"Enhanced shape: {X_enhanced.shape}")
print(f"New features: {len(creator.get_feature_names())} total")
print(f"Feature names (first 10): {creator.get_feature_names()[:10]}")

# Test with ratios
print("\n" + "="*60)
print("Test 2: Ratio Features")
print("="*60)

creator = FeatureCreator(
    polynomial_degree=None,
    interactions=True,
    ratios=True,
    group_columns=['x4']
)

X_enhanced_ratio = creator.fit_transform(X)
print(f"With ratios shape: {X_enhanced_ratio.shape}")

# Show ratio features
ratio_cols = [col for col in X_enhanced_ratio.columns if 'div' in col or 'times' in col]
print(f"Ratio features created: {len(ratio_cols)}")
print(f"Sample ratio features: {ratio_cols[:5]}")

# Test with aggregations
print("\n" + "="*60)
print("Test 3: Aggregation Features")
print("="*60)

creator = FeatureCreator(
    polynomial_degree=None,
    interactions=False,
    ratios=False,
    group_columns=['x4'],
    aggregation_functions=['mean', 'sum', 'max', 'min']
)

X_enhanced_agg = creator.fit_transform(X)
agg_cols = [col for col in X_enhanced_agg.columns if 'x4' in col]
print(f"Aggregation features: {len(agg_cols)}")
print(f"Sample aggregation features: {agg_cols[:5]}")

# Show sample data
print("\nSample enhanced data:")
print(X_enhanced_agg.head())

print("\n✅ Feature creation test complete!")
EOF

python test_feature_creation.py
```

#### Test 2: Feature Selection

```bash
cat > test_feature_selection.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_regression
from src.features.selection import FeatureSelector, AutoFeatureSelector

# Create dataset with many features
np.random.seed(42)
X, y = make_regression(
    n_samples=500,
    n_features=50,
    n_informative=10,
    n_redundant=5,
    noise=10,
    random_state=42
)

# Convert to DataFrame
feature_names = [f'feature_{i}' for i in range(X.shape[1])]
X = pd.DataFrame(X, columns=feature_names)

print("Original data:")
print(f"Shape: {X.shape}")
print(f"Target shape: {y.shape}")

# Test different selection methods
print("\n" + "="*60)
print("Test 1: Variance Threshold")
print("="*60)

selector = FeatureSelector(method='variance', threshold=0.01)
X_selected = selector.fit_transform(X)
print(f"Variance selection: {X_selected.shape[1]} features retained")

print("\n" + "="*60)
print("Test 2: Mutual Information")
print("="*60)

selector = FeatureSelector(method='mutual_info', n_features_to_select=15)
X_selected = selector.fit_transform(X, y)
print(f"Mutual info selection: {X_selected.shape[1]} features selected")
print(f"Selected features: {selector.get_selected_features()[:5]}...")

print("\n" + "="*60)
print("Test 3: RFE with Random Forest")
print("="*60)

from sklearn.ensemble import RandomForestRegressor
selector = FeatureSelector(
    method='rfe',
    n_features_to_select=15,
    estimator=RandomForestRegressor(n_estimators=50, random_state=42)
)
X_selected = selector.fit_transform(X, y)
print(f"RFE selection: {X_selected.shape[1]} features selected")

print("\n" + "="*60)
print("Test 4: Model-based Selection")
print("="*60)

selector = FeatureSelector(
    method='model',
    estimator=RandomForestRegressor(n_estimators=50, random_state=42),
    threshold='median'  # Select features above median importance
)
X_selected = selector.fit_transform(X, y)
print(f"Model-based selection: {X_selected.shape[1]} features selected")

# Get importance summary
summary = selector.get_selection_summary()
print(f"Feature importances (top 5):")
for name, imp in sorted(summary['feature_importances'].items(), key=lambda x: x[1], reverse=True)[:5]:
    print(f"  {name}: {imp:.4f}")

print("\n" + "="*60)
print("Test 5: Auto Feature Selection")
print("="*60)

auto_selector = AutoFeatureSelector(
    methods=['variance', 'mutual_info', 'model', 'lasso'],
    n_features_list=[5, 10, 15, 20],
    cv=3
)
X_selected = auto_selector.fit_transform(X, y)
print(f"Auto selection: {X_selected.shape[1]} features selected")
print(f"Best method: {auto_selector.get_best_method()}")
print(f"Best n_features: {auto_selector.get_best_n_features()}")

# Show results summary
print("\nAuto selector results summary:")
summary_df = auto_selector.get_summary()
print(summary_df.sort_values('mean_score', ascending=False).head(5))

print("\n✅ Feature selection test complete!")
EOF

python test_feature_selection.py
```

#### Test 3: Integration with Preprocessing Pipeline

```bash
cat > test_feature_engineering_pipeline.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
from src.preprocessing.pipeline import DataPreprocessor
from src.features.creation import FeatureCreator
from src.features.selection import FeatureSelector
from src.features.encoding import CategoricalEncoder

# Create sample data
np.random.seed(42)
n_samples = 1000

df = pd.DataFrame({
    'age': np.random.normal(35, 10, n_samples),
    'income': np.random.exponential(50000, n_samples),
    'city': np.random.choice(['NYC', 'LA', 'Chicago', 'Boston', 'SF'], 
                            n_samples, p=[0.25, 0.25, 0.2, 0.15, 0.15]),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n_samples),
    'value1': np.random.normal(100, 20, n_samples),
    'value2': np.random.normal(50, 10, n_samples),
})

# Create target with non-linear relationships
df['target'] = (
    2*df['age'] + 
    0.5*df['income']/10000 + 
    3*df['value1'] - 
    2*df['value2'] + 
    0.1*df['value1']*df['value2'] +
    df['city'].map({'NYC': 10, 'LA': 5, 'Chicago': 0, 'Boston': -5, 'SF': -10}) +
    np.random.normal(0, 5, n_samples)
)

# Introduce missing values
df.loc[np.random.choice(n_samples, 50, replace=False), 'age'] = np.nan
df.loc[np.random.choice(n_samples, 30, replace=False), 'income'] = np.nan

print("Original data:")
print(f"Shape: {df.shape}")
print(f"Missing:\n{df.isnull().sum()}")

# Split data
X = df.drop('target', axis=1)
y = df['target']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print(f"\nTrain shape: {X_train.shape}, Test shape: {X_test.shape}")

# Create full pipeline
print("\n" + "="*60)
print("Building feature engineering pipeline")
print("="*60)

# Step 1: Preprocessing
preprocessor = DataPreprocessor(
    numeric_imputation='median',
    categorical_imputation='mode',
    scaling_strategy='standard'
)

# Step 2: Encoding
encoder = CategoricalEncoder(strategy='auto')

# Step 3: Feature creation
feature_creator = FeatureCreator(
    polynomial_degree=2,
    interactions=True,
    ratios=True,
    include_bias=False
)

# Step 4: Feature selection
feature_selector = FeatureSelector(
    method='model',
    n_features_to_select=20,
    estimator=RandomForestRegressor(n_estimators=50, random_state=42)
)

# Step 5: Model
model = RandomForestRegressor(n_estimators=100, random_state=42)

# Apply pipeline steps
print("Step 1: Preprocessing...")
X_train_proc = preprocessor.fit_transform(X_train)
X_test_proc = preprocessor.transform(X_test)

print(f"After preprocessing: {X_train_proc.shape}")

print("Step 2: Encoding...")
X_train_enc = encoder.fit_transform(X_train_proc)
X_test_enc = encoder.transform(X_test_proc)

print(f"After encoding: {X_train_enc.shape}")
print(f"Encoding strategy: {encoder._selected_strategy}")

print("Step 3: Feature creation...")
X_train_enhanced = feature_creator.fit_transform(X_train_enc)
X_test_enhanced = feature_creator.transform(X_test_enc)

print(f"After feature creation: {X_train_enhanced.shape}")
print(f"Total features: {len(feature_creator.get_feature_names())}")

print("Step 4: Feature selection...")
X_train_selected = feature_selector.fit_transform(X_train_enhanced, y_train)
X_test_selected = feature_selector.transform(X_test_enhanced)

print(f"After feature selection: {X_train_selected.shape}")
print(f"Selected features: {feature_selector.get_n_selected()}")

print("Step 5: Training model...")
model.fit(X_train_selected, y_train)

# Evaluate
y_pred = model.predict(X_test_selected)

mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print("\n" + "="*60)
print("Model Performance")
print("="*60)
print(f"MSE: {mse:.4f}")
print(f"R² Score: {r2:.4f}")

# Compare with baseline (no feature engineering)
print("\n" + "="*60)
print("Baseline (no feature engineering)")
print("="*60)

# Simple pipeline: just preprocessing and model
X_train_base = preprocessor.fit_transform(X_train)
X_test_base = preprocessor.transform(X_test)

# Handle categorical columns for baseline
X_train_base = pd.get_dummies(X_train_base, drop_first=True)
X_test_base = pd.get_dummies(X_test_base, drop_first=True)

# Align columns
common_cols = set(X_train_base.columns) & set(X_test_base.columns)
X_train_base = X_train_base[list(common_cols)]
X_test_base = X_test_base[list(common_cols)]

model_base = RandomForestRegressor(n_estimators=100, random_state=42)
model_base.fit(X_train_base, y_train)
y_pred_base = model_base.predict(X_test_base)

mse_base = mean_squared_error(y_test, y_pred_base)
r2_base = r2_score(y_test, y_pred_base)

print(f"MSE: {mse_base:.4f}")
print(f"R² Score: {r2_base:.4f}")

print("\n" + "="*60)
print("Improvement")
print("="*60)
print(f"MSE Improvement: {((mse_base - mse) / mse_base * 100):.2f}%")
print(f"R² Improvement: {((r2 - r2_base) / abs(r2_base) * 100):.2f}%")

print("\n✅ Feature engineering pipeline test complete!")
EOF

python test_feature_engineering_pipeline.py
```

### What Just Happened: Understanding Feature Engineering

#### The Feature Creation Spectrum

**1. Simple Transformations**
- **Polynomial Features**: x², x³, etc. - Captures non-linear relationships
- **Log/Exp Transformations**: Handles skewed distributions
- **Square Root**: Stabilizes variance

**2. Interaction Features**
- **Multiplicative**: x1 * x2 - Captures interaction effects
- **Ratio**: x1 / x2 - Captures relative importance
- **Difference**: x1 - x2 - Captures change or spread

**3. Aggregation Features**
- **Group Means**: Average value within a category
- **Group Statistics**: Max, min, std, count
- **Relative to Group**: Deviation from group mean

**4. Domain-Specific Features**
- **Date/Time**: Day of week, month, hour
- **Geographic**: Distance, region
- **Text**: Length, word count, sentiment

#### The Feature Selection Landscape

**Filter Methods (Statistical)**
- **Variance**: Remove constant/near-constant features
- **Correlation**: Keep features correlated with target
- **Mutual Information**: Capture non-linear relationships
- **Chi-Square**: For categorical features
- **Pros**: Fast, independent of model
- **Cons**: Doesn't consider feature interactions

**Wrapper Methods (Search)**
- **RFE**: Recursively remove least important features
- **RFECV**: RFE with cross-validation
- **Forward/Backward Selection**: Add or remove features greedily
- **Pros**: Model-specific, finds good subsets
- **Cons**: Computationally expensive

**Embedded Methods (Model-Based)**
- **Lasso/L1**: Feature weights shrink to zero
- **Random Forest**: Feature importance from trees
- **XGBoost**: Gain-based importance
- **Pros**: Fast, model-specific
- **Cons**: Depends on model quality

**Hybrid Methods**
- **Ensemble**: Combine multiple selection methods
- **Automatic**: Try multiple methods and pick best
- **Pros**: More robust
- **Cons**: More complex

#### Understanding Feature Importance

Different models give different importance measures:

**Tree-Based (Random Forest, XGBoost)**:
- **Gain**: How much a feature reduces impurity
- **Cover**: How many samples are affected
- **Frequency**: How often a feature is used
- **Interpretation**: Higher importance = more useful splits

**Linear Models**:
- **Coefficients**: Size of effect on target
- **Interpretation**: Larger absolute values = more important

**Correlation-Based**:
- **Pearson**: Linear relationship
- **Spearman**: Monotonic relationship
- **Mutual Information**: Any relationship

### Summary

In this part, we've built a comprehensive feature engineering system that:

1. **Creates new features** through polynomials, interactions, ratios, and aggregations
2. **Automatically selects** optimal features using multiple methods
3. **Combines** feature creation and selection in a unified pipeline
4. **Visualizes** feature importance and selection effects
5. **Integrates** with preprocessing and encoding
6. **Improves** model performance through intelligent feature engineering

### What's Next

In Part 7, we'll tackle dimensionality reduction and imbalanced learning. We'll use PCA and t-SNE for reducing feature space while preserving information, and SMOTE and class weighting for handling imbalanced target variables.
