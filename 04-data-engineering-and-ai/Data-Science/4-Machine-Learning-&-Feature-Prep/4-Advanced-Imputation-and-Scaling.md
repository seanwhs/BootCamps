# Module 4.1: Feature Prep & Engineering

## Part 4: Advanced Imputation and Scaling

Welcome to Module 4.1! We've spent the first three parts building our foundation—project structure, data validation, and exploratory analysis. Now we transition into the heart of feature engineering: transforming raw data into model-ready features. We start with two of the most critical preprocessing steps: handling missing values and scaling numerical features.

### The Target: A Complete Imputation and Scaling System

By the end of this part, you'll have:
1. Multiple imputation strategies (mean, median, mode, KNN, MICE)
2. Robust scaling techniques (StandardScaler, RobustScaler, MinMaxScaler, MaxAbsScaler)
3. A unified API for preprocessing
4. Integration with our data pipeline
5. Visualization of preprocessing effects
6. Comprehensive testing and validation

### The Concept: Why Preprocessing Matters

Think of your data like ingredients for a gourmet meal:

**Missing Values** are like missing ingredients. You have three options:
- **Throw away the dish** (delete rows) - Wasteful, loses information
- **Substitute something else** (imputation) - Sometimes works, sometimes ruins the dish
- **Change the recipe** (model that handles missingness) - Some models can handle it, but not all

**Scaling** is like measuring ingredients correctly:
- If you measure flour in cups but sugar in grams, you're mixing units
- Models like linear regression and neural networks are sensitive to feature scales
- Tree-based models don't care about scale, but many others do

The key insight: **different features have different scales, and many models assume all features are on similar scales**. Without proper scaling, models can become dominated by features with larger magnitudes, even if those features aren't more important.

### The Implementation: Building Our Preprocessing System

#### Step 1: Imputation Strategies

Let's build a comprehensive imputation system that handles various missing data patterns.

**File:** `src/preprocessing/imputation.py`
**Path:** `ml-pipeline-project/src/preprocessing/imputation.py`

```python
"""
Advanced missing value imputation strategies.

This module provides multiple imputation methods with support for
different data types and missingness patterns.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
from pathlib import Path
import warnings
import numpy as np
import pandas as pd
from loguru import logger
from scipy import stats
from sklearn.impute import KNNImputer, SimpleImputer
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.preprocessing import LabelEncoder

warnings.filterwarnings("ignore", category=UserWarning)

class ImputationStrategy:
    """
    Enumeration of available imputation strategies.
    """
    MEAN = "mean"
    MEDIAN = "median"
    MODE = "mode"
    CONSTANT = "constant"
    KNN = "knn"
    MICE = "mice"  # Multiple Imputation by Chained Equations
    RANDOM_FOREST = "random_forest"
    LINEAR = "linear"
    INTERPOLATE = "interpolate"
    FORWARD_FILL = "forward_fill"
    BACKWARD_FILL = "backward_fill"

class MissingValueImputer:
    """
    Advanced missing value imputation with multiple strategies.
    
    This class provides a unified interface for various imputation
    methods, with support for:
    - Simple imputation (mean, median, mode, constant)
    - KNN imputation
    - MICE (multiple imputation)
    - Model-based imputation (linear regression, random forest)
    - Time-series specific (interpolation, forward/backward fill)
    
    Example:
        >>> imputer = MissingValueImputer()
        >>> df_imputed = imputer.impute(
        ...     df,
        ...     numeric_strategy="median",
        ...     categorical_strategy="mode",
        ...     columns=["age", "income", "category"]
        ... )
    """
    
    def __init__(
        self,
        config: Optional[Dict[str, Any]] = None
    ):
        """
        Initialize the imputer.
        
        Args:
            config: Configuration options
        """
        self.config = config or {}
        self._imputers = {}  # Store fitted imputers
        self._feature_columns = []
        
        logger.info("MissingValueImputer initialized")
    
    def impute(
        self,
        df: pd.DataFrame,
        numeric_strategy: Union[str, Dict[str, str]] = "median",
        categorical_strategy: Union[str, Dict[str, str]] = "mode",
        columns: Optional[List[str]] = None,
        **kwargs
    ) -> pd.DataFrame:
        """
        Impute missing values in the dataset.
        
        Args:
            df: DataFrame with missing values
            numeric_strategy: Strategy for numeric columns
            categorical_strategy: Strategy for categorical columns
            columns: Specific columns to impute (None for all)
            **kwargs: Additional arguments for specific strategies
            
        Returns:
            pd.DataFrame: Imputed DataFrame
        """
        df_result = df.copy()
        
        # Determine columns to impute
        if columns is None:
            columns = df.columns.tolist()
        
        # Separate numeric and categorical columns
        numeric_cols = df[columns].select_dtypes(include=[np.number]).columns.tolist()
        categorical_cols = df[columns].select_dtypes(include=['object', 'category']).columns.tolist()
        
        logger.info(f"Imputing {len(numeric_cols)} numeric and {len(categorical_cols)} categorical columns")
        
        # Impute numeric columns
        if numeric_cols:
            strategy_dict = self._parse_strategy(numeric_strategy, numeric_cols)
            for col in numeric_cols:
                strategy = strategy_dict.get(col, "median")
                if strategy is not None:
                    df_result[col] = self._impute_numeric(
                        df_result[col], strategy, **kwargs
                    )
        
        # Impute categorical columns
        if categorical_cols:
            strategy_dict = self._parse_strategy(categorical_strategy, categorical_cols)
            for col in categorical_cols:
                strategy = strategy_dict.get(col, "mode")
                if strategy is not None:
                    df_result[col] = self._impute_categorical(
                        df_result[col], strategy, **kwargs
                    )
        
        # Store feature columns for later use
        self._feature_columns = numeric_cols + categorical_cols
        
        return df_result
    
    def _parse_strategy(
        self,
        strategy: Union[str, Dict[str, str]],
        columns: List[str]
    ) -> Dict[str, Optional[str]]:
        """
        Parse strategy into column-specific mapping.
        
        Args:
            strategy: Strategy string or dict
            columns: List of column names
            
        Returns:
            Dict: Column to strategy mapping
        """
        if isinstance(strategy, str):
            return {col: strategy for col in columns}
        elif isinstance(strategy, dict):
            # Use default for unspecified columns
            result = {col: None for col in columns}
            for col, strat in strategy.items():
                if col in columns:
                    result[col] = strat
            return result
        else:
            raise ValueError(f"Invalid strategy type: {type(strategy)}")
    
    def _impute_numeric(
        self,
        series: pd.Series,
        strategy: str,
        **kwargs
    ) -> pd.Series:
        """
        Impute a numeric series.
        
        Args:
            series: Series with missing values
            strategy: Imputation strategy
            **kwargs: Additional arguments
            
        Returns:
            pd.Series: Imputed series
        """
        # Handle case with no missing values
        if series.isnull().sum() == 0:
            return series
        
        data = series.values.reshape(-1, 1)
        
        try:
            if strategy == ImputationStrategy.MEAN:
                imputer = SimpleImputer(strategy='mean')
                imputed = imputer.fit_transform(data)
                
            elif strategy == ImputationStrategy.MEDIAN:
                imputer = SimpleImputer(strategy='median')
                imputed = imputer.fit_transform(data)
                
            elif strategy == ImputationStrategy.CONSTANT:
                fill_value = kwargs.get('fill_value', 0)
                imputer = SimpleImputer(strategy='constant', fill_value=fill_value)
                imputed = imputer.fit_transform(data)
                
            elif strategy == ImputationStrategy.KNN:
                n_neighbors = kwargs.get('n_neighbors', 5)
                imputer = KNNImputer(n_neighbors=n_neighbors)
                # Need 2D data for KNN
                imputed = imputer.fit_transform(data)
                
            elif strategy == ImputationStrategy.MICE:
                # Iterative imputation
                imputer = IterativeImputer(
                    estimator=LinearRegression(),
                    random_state=kwargs.get('random_state', 42),
                    max_iter=kwargs.get('max_iter', 10)
                )
                imputed = imputer.fit_transform(data)
                
            elif strategy == ImputationStrategy.LINEAR:
                # Simple linear regression imputation
                # For single column, we need other features
                # This is a simplified version
                imputer = IterativeImputer(
                    estimator=LinearRegression(),
                    random_state=kwargs.get('random_state', 42)
                )
                imputed = imputer.fit_transform(data)
                
            elif strategy == ImputationStrategy.INTERPOLATE:
                # Interpolation (useful for time series)
                return series.interpolate(method=kwargs.get('method', 'linear'))
                
            elif strategy == ImputationStrategy.FORWARD_FILL:
                return series.fillna(method='ffill')
                
            elif strategy == ImputationStrategy.BACKWARD_FILL:
                return series.fillna(method='bfill')
                
            else:
                logger.warning(f"Unknown strategy '{strategy}', using median")
                imputer = SimpleImputer(strategy='median')
                imputed = imputer.fit_transform(data)
            
            return pd.Series(imputed.flatten(), index=series.index)
            
        except Exception as e:
            logger.error(f"Imputation failed for {series.name}: {str(e)}")
            # Fallback to median
            imputer = SimpleImputer(strategy='median')
            imputed = imputer.fit_transform(data)
            return pd.Series(imputed.flatten(), index=series.index)
    
    def _impute_categorical(
        self,
        series: pd.Series,
        strategy: str,
        **kwargs
    ) -> pd.Series:
        """
        Impute a categorical series.
        
        Args:
            series: Series with missing values
            strategy: Imputation strategy
            **kwargs: Additional arguments
            
        Returns:
            pd.Series: Imputed series
        """
        # Handle case with no missing values
        if series.isnull().sum() == 0:
            return series
        
        # Convert to string for consistent handling
        series_str = series.astype(str)
        
        if strategy == ImputationStrategy.MODE:
            # Most frequent value
            mode_value = series_str.mode()
            if len(mode_value) > 0:
                fill_value = mode_value.iloc[0]
            else:
                fill_value = "unknown"
            return series.fillna(fill_value)
            
        elif strategy == ImputationStrategy.CONSTANT:
            fill_value = kwargs.get('fill_value', 'unknown')
            return series.fillna(fill_value)
            
        elif strategy == ImputationStrategy.FORWARD_FILL:
            return series.fillna(method='ffill')
            
        elif strategy == ImputationStrategy.BACKWARD_FILL:
            return series.fillna(method='bfill')
            
        elif strategy == ImputationStrategy.KNN:
            # For KNN, we need to encode categorical as numeric
            # This is a simplified version
            le = LabelEncoder()
            encoded = le.fit_transform(series_str.fillna('missing'))
            
            # Use KNN on encoded values
            data = encoded.reshape(-1, 1)
            imputer = KNNImputer(n_neighbors=kwargs.get('n_neighbors', 5))
            imputed = imputer.fit_transform(data)
            
            # Decode back
            imputed_int = np.round(imputed.flatten()).astype(int)
            imputed_values = le.inverse_transform(imputed_int)
            
            return pd.Series(imputed_values, index=series.index)
            
        else:
            logger.warning(f"Unknown categorical strategy '{strategy}', using mode")
            mode_value = series_str.mode()
            fill_value = mode_value.iloc[0] if len(mode_value) > 0 else "unknown"
            return series.fillna(fill_value)
    
    def impute_with_model(
        self,
        df: pd.DataFrame,
        target_col: str,
        model_type: str = "random_forest",
        columns: Optional[List[str]] = None,
        **kwargs
    ) -> pd.DataFrame:
        """
        Impute missing values using a machine learning model.
        
        This is a more sophisticated approach where we train a model
        to predict missing values based on other features.
        
        Args:
            df: DataFrame with missing values
            target_col: Column to impute
            model_type: Type of model ('random_forest', 'linear', 'knn')
            columns: Features to use for imputation
            **kwargs: Additional model arguments
            
        Returns:
            pd.DataFrame: Imputed DataFrame
        """
        df_result = df.copy()
        
        # Get rows with and without missing target
        missing_mask = df[target_col].isnull()
        train_df = df[~missing_mask]
        predict_df = df[missing_mask]
        
        if len(predict_df) == 0:
            logger.info(f"No missing values in {target_col}")
            return df_result
        
        # Determine feature columns
        if columns is None:
            columns = [col for col in df.columns if col != target_col]
        
        # Prepare features
        X_train = train_df[columns].dropna(axis=0, how='any')
        y_train = train_df.loc[X_train.index, target_col]
        
        # Check if we have enough training data
        if len(X_train) < 10:
            logger.warning(f"Insufficient data for model imputation, using median")
            df_result[target_col] = df[target_col].fillna(df[target_col].median())
            return df_result
        
        # Select and train model
        if model_type == "random_forest":
            from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
            
            if pd.api.types.is_numeric_dtype(df[target_col]):
                model = RandomForestRegressor(
                    n_estimators=kwargs.get('n_estimators', 100),
                    random_state=kwargs.get('random_state', 42)
                )
            else:
                model = RandomForestClassifier(
                    n_estimators=kwargs.get('n_estimators', 100),
                    random_state=kwargs.get('random_state', 42)
                )
                
        elif model_type == "linear":
            if pd.api.types.is_numeric_dtype(df[target_col]):
                model = LinearRegression()
            else:
                model = LogisticRegression(
                    max_iter=kwargs.get('max_iter', 1000),
                    random_state=kwargs.get('random_state', 42)
                )
                
        elif model_type == "knn":
            from sklearn.neighbors import KNeighborsRegressor, KNeighborsClassifier
            
            if pd.api.types.is_numeric_dtype(df[target_col]):
                model = KNeighborsRegressor(n_neighbors=kwargs.get('n_neighbors', 5))
            else:
                model = KNeighborsClassifier(n_neighbors=kwargs.get('n_neighbors', 5))
        else:
            raise ValueError(f"Unknown model type: {model_type}")
        
        # Train model
        model.fit(X_train, y_train)
        
        # Predict missing values
        X_predict = predict_df[columns].dropna(axis=0, how='any')
        if len(X_predict) > 0:
            predictions = model.predict(X_predict)
            df_result.loc[X_predict.index, target_col] = predictions
        
        return df_result
    
    def get_imputation_summary(self, df_before: pd.DataFrame, df_after: pd.DataFrame) -> Dict[str, Any]:
        """
        Generate a summary of imputation effects.
        
        Args:
            df_before: Original DataFrame
            df_after: Imputed DataFrame
            
        Returns:
            Dict: Imputation summary
        """
        summary = {
            "total_imputed": (df_before.isnull().sum() - df_after.isnull().sum()).sum(),
            "columns_imputed": [],
            "imputation_by_column": {}
        }
        
        for col in df_before.columns:
            before_missing = df_before[col].isnull().sum()
            after_missing = df_after[col].isnull().sum()
            imputed = before_missing - after_missing
            
            if imputed > 0:
                summary["columns_imputed"].append(col)
                summary["imputation_by_column"][col] = {
                    "imputed_count": imputed,
                    "imputed_percentage": (imputed / len(df_before)) * 100
                }
        
        return summary
```

#### Step 2: Robust Scaling Strategies

Now let's build our scaling system with multiple strategies.

**File:** `src/preprocessing/scaling.py`
**Path:** `ml-pipeline-project/src/preprocessing/scaling.py`

```python
"""
Robust feature scaling strategies.

This module provides multiple scaling methods with support for
handling outliers and different data distributions.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.preprocessing import (
    StandardScaler,
    RobustScaler,
    MinMaxScaler,
    MaxAbsScaler,
    PowerTransformer,
    QuantileTransformer,
    Normalizer
)
from sklearn.base import BaseEstimator, TransformerMixin

class ScalingStrategy:
    """
    Enumeration of available scaling strategies.
    """
    STANDARD = "standard"      # StandardScaler (z-score)
    ROBUST = "robust"          # RobustScaler (IQR-based)
    MINMAX = "minmax"          # MinMaxScaler (0-1 range)
    MAXABS = "maxabs"          # MaxAbsScaler (-1 to 1 range)
    POWER = "power"            # PowerTransformer (Box-Cox/Yeo-Johnson)
    QUANTILE = "quantile"      # QuantileTransformer (uniform/normal)
    NORMALIZER = "normalizer"  # Normalizer (L1/L2 normalization)
    NONE = "none"              # No scaling

class FeatureScaler(BaseEstimator, TransformerMixin):
    """
    Robust feature scaling with multiple strategies.
    
    This class provides a unified interface for various scaling
    methods, with support for:
    - Standardization (z-score)
    - Robust scaling (IQR-based, handles outliers)
    - Min-Max scaling (bounded ranges)
    - Power transformations (handles skewness)
    - Quantile transformations (handles arbitrary distributions)
    - Normalization (unit norm)
    
    Example:
        >>> scaler = FeatureScaler(strategy="robust")
        >>> X_scaled = scaler.fit_transform(X)
        >>> X_new_scaled = scaler.transform(X_new)
    """
    
    def __init__(
        self,
        strategy: str = "standard",
        columns: Optional[List[str]] = None,
        **kwargs
    ):
        """
        Initialize the feature scaler.
        
        Args:
            strategy: Scaling strategy to use
            columns: Specific columns to scale (None for all numeric)
            **kwargs: Additional arguments for the scaler
        """
        self.strategy = strategy
        self.columns = columns
        self.kwargs = kwargs
        self._scaler = None
        self._fitted = False
        
        logger.info(f"FeatureScaler initialized with strategy={strategy}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'FeatureScaler':
        """
        Fit the scaler to the data.
        
        Args:
            X: Input data
            y: Ignored
            
        Returns:
            FeatureScaler: Fitted scaler
        """
        X_copy = self._prepare_data(X)
        
        # Create the appropriate scaler
        self._scaler = self._create_scaler()
        
        # Fit the scaler
        self._scaler.fit(X_copy)
        self._fitted = True
        
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data using the fitted scaler.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Scaled data
        """
        if not self._fitted:
            raise ValueError("Scaler has not been fitted yet. Call fit() first.")
        
        X_copy = self._prepare_data(X)
        
        # Transform
        X_transformed = self._scaler.transform(X_copy)
        
        # Convert back to DataFrame if input was DataFrame
        if isinstance(X, pd.DataFrame):
            if self.columns is not None:
                # Only transform specified columns
                result = X.copy()
                result[self.columns] = X_transformed
                return result
            else:
                return pd.DataFrame(X_transformed, index=X.index, columns=X.columns)
        
        return X_transformed
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit the scaler and transform the data in one step.
        
        Args:
            X: Input data
            y: Ignored
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Scaled data
        """
        self.fit(X)
        return self.transform(X)
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """
        Prepare data for scaling.
        
        Args:
            X: Input data
            
        Returns:
            np.ndarray: Prepared data
        """
        if isinstance(X, pd.DataFrame):
            if self.columns is not None:
                return X[self.columns].values
            else:
                numeric_cols = X.select_dtypes(include=[np.number]).columns
                if len(numeric_cols) == 0:
                    logger.warning("No numeric columns found for scaling")
                    return X.values
                return X[numeric_cols].values
        else:
            return X
    
    def _create_scaler(self):
        """
        Create the appropriate scaler based on strategy.
        
        Returns:
            sklearn scaler: Configured scaler
        """
        if self.strategy == ScalingStrategy.STANDARD:
            return StandardScaler(**self.kwargs)
            
        elif self.strategy == ScalingStrategy.ROBUST:
            return RobustScaler(**self.kwargs)
            
        elif self.strategy == ScalingStrategy.MINMAX:
            return MinMaxScaler(**self.kwargs)
            
        elif self.strategy == ScalingStrategy.MAXABS:
            return MaxAbsScaler(**self.kwargs)
            
        elif self.strategy == ScalingStrategy.POWER:
            method = self.kwargs.get('method', 'yeo-johnson')
            return PowerTransformer(method=method, **self.kwargs)
            
        elif self.strategy == ScalingStrategy.QUANTILE:
            output = self.kwargs.get('output', 'normal')
            return QuantileTransformer(output=output, **self.kwargs)
            
        elif self.strategy == ScalingStrategy.NORMALIZER:
            norm = self.kwargs.get('norm', 'l2')
            return Normalizer(norm=norm, **self.kwargs)
            
        elif self.strategy == ScalingStrategy.NONE:
            # Identity transformer
            class IdentityScaler:
                def fit(self, X, y=None): return self
                def transform(self, X): return X
                def fit_transform(self, X, y=None): return X
            return IdentityScaler()
            
        else:
            logger.warning(f"Unknown strategy '{self.strategy}', using StandardScaler")
            return StandardScaler()
    
    def inverse_transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Inverse transform the data.
        
        Args:
            X: Scaled data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Original-scale data
        """
        if not self._fitted:
            raise ValueError("Scaler has not been fitted yet. Call fit() first.")
        
        X_copy = self._prepare_data(X)
        
        # Inverse transform
        X_inv = self._scaler.inverse_transform(X_copy)
        
        # Convert back to DataFrame if input was DataFrame
        if isinstance(X, pd.DataFrame):
            if self.columns is not None:
                result = X.copy()
                result[self.columns] = X_inv
                return result
            else:
                return pd.DataFrame(X_inv, index=X.index, columns=X.columns)
        
        return X_inv
    
    def get_params(self, deep=True):
        """Get parameters for this estimator."""
        return {
            'strategy': self.strategy,
            'columns': self.columns,
            **self.kwargs
        }
    
    def set_params(self, **params):
        """Set parameters for this estimator."""
        for key, value in params.items():
            if key == 'strategy':
                self.strategy = value
            elif key == 'columns':
                self.columns = value
            else:
                self.kwargs[key] = value
        return self

class SmartScaler(FeatureScaler):
    """
    Smart scaler that automatically selects the best scaling strategy.
    
    This scaler analyzes the data distribution and selects the most
    appropriate scaling strategy.
    """
    
    def __init__(
        self,
        columns: Optional[List[str]] = None,
        **kwargs
    ):
        """
        Initialize the smart scaler.
        
        Args:
            columns: Columns to scale
            **kwargs: Additional arguments
        """
        super().__init__(strategy="standard", columns=columns, **kwargs)
        self._selected_strategies = {}
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'SmartScaler':
        """
        Fit the scaler by selecting optimal strategies for each column.
        
        Args:
            X: Input data
            y: Ignored
            
        Returns:
            SmartScaler: Fitted scaler
        """
        if isinstance(X, pd.DataFrame):
            if self.columns is None:
                columns = X.select_dtypes(include=[np.number]).columns.tolist()
            else:
                columns = [col for col in self.columns if col in X.columns]
        else:
            # For numpy arrays, we can't select per-column strategies
            # Just use standard scaling
            self._scaler = StandardScaler(**self.kwargs)
            self._scaler.fit(X)
            self._fitted = True
            return self
        
        # Analyze each column and select strategy
        for col in columns:
            data = X[col].dropna()
            if len(data) < 2:
                self._selected_strategies[col] = ScalingStrategy.NONE
                continue
            
            # Check for outliers
            Q1 = data.quantile(0.25)
            Q3 = data.quantile(0.75)
            IQR = Q3 - Q1
            outlier_count = ((data < (Q1 - 1.5 * IQR)) | (data > (Q3 + 1.5 * IQR))).sum()
            outlier_pct = outlier_count / len(data)
            
            # Check for skewness
            skewness = abs(data.skew())
            
            # Check for bounded range
            is_bounded = (data.min() >= 0 and data.max() <= 1)
            
            # Select strategy
            if is_bounded:
                strategy = ScalingStrategy.NONE
            elif outlier_pct > 0.05:
                strategy = ScalingStrategy.ROBUST
            elif skewness > 1:
                strategy = ScalingStrategy.POWER
            elif data.std() < 0.1:
                strategy = ScalingStrategy.STANDARD
            else:
                strategy = ScalingStrategy.STANDARD
            
            self._selected_strategies[col] = strategy
        
        # Create and fit scalers for each column
        # For simplicity, we'll use the most common strategy or a standard scaler
        strategy_counts = {}
        for strat in self._selected_strategies.values():
            strategy_counts[strat] = strategy_counts.get(strat, 0) + 1
        
        most_common_strategy = max(strategy_counts.items(), key=lambda x: x[1])[0]
        
        # Use standard scaler as default if no strategy found
        if most_common_strategy is None:
            most_common_strategy = ScalingStrategy.STANDARD
        
        # Create the scaler with the most common strategy
        self._scaler = FeatureScaler(
            strategy=most_common_strategy,
            columns=columns,
            **self.kwargs
        )
        self._scaler.fit(X)
        self._fitted = True
        
        logger.info(f"SmartScaler selected strategies: {self._selected_strategies}")
        
        return self
```

#### Step 3: The Preprocessing Pipeline

Now let's combine imputation and scaling into a unified preprocessing system.

**File:** `src/preprocessing/pipeline.py`
**Path:** `ml-pipeline-project/src/preprocessing/pipeline.py`

```python
"""
Unified preprocessing pipeline combining imputation and scaling.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import pandas as pd
import numpy as np
from loguru import logger
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.base import BaseEstimator, TransformerMixin

from .imputation import MissingValueImputer
from .scaling import FeatureScaler, SmartScaler, ScalingStrategy

class DataPreprocessor(BaseEstimator, TransformerMixin):
    """
    Comprehensive data preprocessing pipeline.
    
    This class combines imputation and scaling into a unified
    pipeline with support for:
    - Multiple imputation strategies
    - Multiple scaling strategies
    - Column-specific transformations
    - Pipeline persistence
    
    Example:
        >>> preprocessor = DataPreprocessor(
        ...     numeric_imputation="median",
        ...     categorical_imputation="mode",
        ...     scaling_strategy="robust"
        ... )
        >>> X_processed = preprocessor.fit_transform(X)
    """
    
    def __init__(
        self,
        numeric_imputation: Union[str, Dict[str, str]] = "median",
        categorical_imputation: Union[str, Dict[str, str]] = "mode",
        scaling_strategy: Union[str, Dict[str, str]] = "standard",
        numeric_columns: Optional[List[str]] = None,
        categorical_columns: Optional[List[str]] = None,
        exclude_columns: Optional[List[str]] = None,
        **kwargs
    ):
        """
        Initialize the data preprocessor.
        
        Args:
            numeric_imputation: Imputation strategy for numeric columns
            categorical_imputation: Imputation strategy for categorical columns
            scaling_strategy: Scaling strategy for numeric columns
            numeric_columns: Specific numeric columns (None for auto-detect)
            categorical_columns: Specific categorical columns (None for auto-detect)
            exclude_columns: Columns to exclude from preprocessing
            **kwargs: Additional arguments
        """
        self.numeric_imputation = numeric_imputation
        self.categorical_imputation = categorical_imputation
        self.scaling_strategy = scaling_strategy
        self.numeric_columns = numeric_columns
        self.categorical_columns = categorical_columns
        self.exclude_columns = exclude_columns or []
        self.kwargs = kwargs
        
        self._imputer = None
        self._scaler = None
        self._column_transformer = None
        self._feature_names = None
        
        logger.info("DataPreprocessor initialized")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'DataPreprocessor':
        """
        Fit the preprocessor to the data.
        
        Args:
            X: Input data
            y: Ignored
            
        Returns:
            DataPreprocessor: Fitted preprocessor
        """
        X_copy = self._prepare_data(X)
        
        # Identify columns
        self._identify_columns(X_copy)
        
        # Create and fit imputer
        self._imputer = MissingValueImputer(config=self.kwargs)
        self._imputer.impute(
            X_copy,
            numeric_strategy=self.numeric_imputation,
            categorical_strategy=self.categorical_imputation,
            columns=self.numeric_columns + self.categorical_columns
        )
        
        # Create and fit scaler
        if self.scaling_strategy == "smart":
            self._scaler = SmartScaler(columns=self.numeric_columns, **self.kwargs)
        else:
            self._scaler = FeatureScaler(
                strategy=self.scaling_strategy,
                columns=self.numeric_columns,
                **self.kwargs
            )
        self._scaler.fit(X_copy)
        
        self._feature_names = X_copy.columns.tolist()
        
        logger.info(f"DataPreprocessor fitted with {len(self.numeric_columns)} numeric and "
                   f"{len(self.categorical_columns)} categorical columns")
        
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data using the fitted preprocessor.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Preprocessed data
        """
        if self._imputer is None or self._scaler is None:
            raise ValueError("Preprocessor has not been fitted yet. Call fit() first.")
        
        X_copy = self._prepare_data(X)
        
        # Impute
        X_imputed = self._imputer.impute(
            X_copy,
            numeric_strategy=self.numeric_imputation,
            categorical_strategy=self.categorical_imputation,
            columns=self.numeric_columns + self.categorical_columns
        )
        
        # Scale
        X_scaled = self._scaler.transform(X_imputed)
        
        return X_scaled
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit the preprocessor and transform the data in one step.
        
        Args:
            X: Input data
            y: Ignored
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Preprocessed data
        """
        self.fit(X)
        return self.transform(X)
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            # Try to infer column names
            if hasattr(self, '_feature_names') and self._feature_names:
                return pd.DataFrame(X, columns=self._feature_names)
            else:
                # Create generic column names
                return pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])
        return X.copy()
    
    def _identify_columns(self, X: pd.DataFrame):
        """Identify numeric and categorical columns."""
        # Exclude specified columns
        columns = [col for col in X.columns if col not in self.exclude_columns]
        
        # If columns are specified, use them
        if self.numeric_columns is not None:
            numeric_cols = [col for col in self.numeric_columns if col in columns]
        else:
            numeric_cols = X[columns].select_dtypes(include=[np.number]).columns.tolist()
        
        if self.categorical_columns is not None:
            cat_cols = [col for col in self.categorical_columns if col in columns]
        else:
            cat_cols = X[columns].select_dtypes(include=['object', 'category']).columns.tolist()
        
        # Remove overlaps
        numeric_cols = [col for col in numeric_cols if col not in cat_cols]
        
        self.numeric_columns = numeric_cols
        self.categorical_columns = cat_cols
    
    def get_preprocessing_summary(self) -> Dict[str, Any]:
        """
        Get a summary of the preprocessing configuration.
        
        Returns:
            Dict: Preprocessing summary
        """
        return {
            "numeric_columns": self.numeric_columns,
            "categorical_columns": self.categorical_columns,
            "numeric_imputation": self.numeric_imputation,
            "categorical_imputation": self.categorical_imputation,
            "scaling_strategy": self.scaling_strategy,
            "exclude_columns": self.exclude_columns
        }
    
    def get_feature_names(self) -> List[str]:
        """Get the names of features after preprocessing."""
        return self._feature_namesclass PreprocessingPipeline:
    """
    Complete preprocessing pipeline with configurable steps.
    
    This class provides a high-level interface for constructing
    and running preprocessing pipelines.
    """
    
    def __init__(
        self,
        steps: List[Tuple[str, Any]] = None,
        **kwargs
    ):
        """
        Initialize the preprocessing pipeline.
        
        Args:
            steps: List of (name, transformer) tuples
            **kwargs: Additional configuration
        """
        self.steps = steps or []
        self.config = kwargs
        self._pipeline = None
        
        logger.info("PreprocessingPipeline initialized")
    
    def add_step(self, name: str, transformer: Any):
        """
        Add a step to the pipeline.
        
        Args:
            name: Step name
            transformer: Transformer object
        """
        self.steps.append((name, transformer))
        self._pipeline = None  # Invalidate cached pipeline
        
    def build(self) -> Pipeline:
        """
        Build the scikit-learn pipeline.
        
        Returns:
            Pipeline: Configured pipeline
        """
        if self._pipeline is None:
            self._pipeline = Pipeline(self.steps)
        return self._pipeline
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit the pipeline and transform the data.
        
        Args:
            X: Input data
            y: Target (optional)
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Transformed data
        """
        pipeline = self.build()
        return pipeline.fit_transform(X, y)
```

#### Step 4: Visualization of Preprocessing Effects

Let's add visualization support to see how our preprocessing transforms the data.

**File:** `src/preprocessing/visualization.py`
**Path:** `ml-pipeline-project/src/preprocessing/visualization.py`

```python
"""
Visualization utilities for preprocessing effects.
"""

from typing import Dict, List, Optional, Union, Any
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
from loguru import logger

class PreprocessingVisualizer:
    """
    Visualizes the effects of preprocessing transformations.
    
    This class creates visual comparisons of:
    - Before/after imputation
    - Before/after scaling
    - Distribution changes
    - Outlier handling
    """
    
    def __init__(
        self,
        figsize: Tuple[int, int] = (12, 8),
        dpi: int = 100
    ):
        """
        Initialize the visualizer.
        
        Args:
            figsize: Default figure size
            dpi: Default DPI
        """
        self.figsize = figsize
        self.dpi = dpi
        plt.style.use('seaborn-v0_8-whitegrid')
        
    def compare_imputation(
        self,
        df_before: pd.DataFrame,
        df_after: pd.DataFrame,
        column: str,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Compare data before and after imputation.
        
        Args:
            df_before: DataFrame before imputation
            df_after: DataFrame after imputation
            column: Column to visualize
            output_path: Optional path to save the figure
            
        Returns:
            plt.Figure: The created figure
        """
        fig, axes = plt.subplots(1, 2, figsize=self.figsize)
        
        # Before imputation
        data_before = df_before[column].dropna()
        if len(data_before) > 0:
            axes[0].hist(data_before, bins=30, alpha=0.7, color='steelblue', edgecolor='black')
            axes[0].set_title(f'Before Imputation ({len(data_before)} non-null)')
            axes[0].set_xlabel(column)
            axes[0].set_ylabel('Frequency')
            axes[0].axvline(data_before.mean(), color='red', linestyle='--', label='Mean')
            axes[0].axvline(data_before.median(), color='green', linestyle='--', label='Median')
            axes[0].legend()
        
        # After imputation
        data_after = df_after[column]
        axes[1].hist(data_after, bins=30, alpha=0.7, color='coral', edgecolor='black')
        axes[1].set_title(f'After Imputation ({len(data_after)} non-null)')
        axes[1].set_xlabel(column)
        axes[1].set_ylabel('Frequency')
        axes[1].axvline(data_after.mean(), color='red', linestyle='--', label='Mean')
        axes[1].axvline(data_after.median(), color='green', linestyle='--', label='Median')
        axes[1].legend()
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Imputation comparison saved to: {output_path}")
        
        return fig
    
    def compare_scaling(
        self,
        df_before: pd.DataFrame,
        df_after: pd.DataFrame,
        column: str,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Compare data before and after scaling.
        
        Args:
            df_before: DataFrame before scaling
            df_after: DataFrame after scaling
            column: Column to visualize
            output_path: Optional path to save the figure
            
        Returns:
            plt.Figure: The created figure
        """
        fig, axes = plt.subplots(2, 2, figsize=self.figsize)
        
        # Before scaling
        data_before = df_before[column].dropna()
        axes[0, 0].hist(data_before, bins=30, alpha=0.7, color='steelblue', edgecolor='black')
        axes[0, 0].set_title(f'Before Scaling - {column}')
        axes[0, 0].set_xlabel(column)
        axes[0, 0].set_ylabel('Frequency')
        
        # Box plot before
        axes[0, 1].boxplot(data_before, vert=False)
        axes[0, 1].set_title(f'Box Plot - Before Scaling')
        axes[0, 1].set_xlabel(column)
        
        # After scaling
        data_after = df_after[column]
        axes[1, 0].hist(data_after, bins=30, alpha=0.7, color='coral', edgecolor='black')
        axes[1, 0].set_title(f'After Scaling - {column}')
        axes[1, 0].set_xlabel(column)
        axes[1, 0].set_ylabel('Frequency')
        
        # Box plot after
        axes[1, 1].boxplot(data_after, vert=False)
        axes[1, 1].set_title(f'Box Plot - After Scaling')
        axes[1, 1].set_xlabel(column)
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Scaling comparison saved to: {output_path}")
        
        return fig
    
    def compare_strategies(
        self,
        df: pd.DataFrame,
        column: str,
        strategies: List[str],
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Compare different scaling strategies on a single column.
        
        Args:
            df: Original DataFrame
            column: Column to visualize
            strategies: List of scaling strategies to compare
            output_path: Optional path to save the figure
            
        Returns:
            plt.Figure: The created figure
        """
        from .scaling import FeatureScaler
        
        n_strategies = len(strategies) + 1  # +1 for original
        n_cols = min(3, n_strategies)
        n_rows = (n_strategies + n_cols - 1) // n_cols
        
        fig, axes = plt.subplots(n_rows, n_cols, figsize=(self.figsize[0], self.figsize[1] * 0.7))
        axes = axes.flatten() if n_rows > 1 else [axes]
        
        # Original
        data = df[column].dropna()
        axes[0].hist(data, bins=30, alpha=0.7, color='steelblue', edgecolor='black')
        axes[0].set_title(f'Original\nmean={data.mean():.2f}, std={data.std():.2f}')
        axes[0].set_xlabel(column)
        
        # Each strategy
        for idx, strategy in enumerate(strategies, 1):
            scaler = FeatureScaler(strategy=strategy, columns=[column])
            df_scaled = scaler.fit_transform(df)
            scaled_data = df_scaled[column].dropna()
            
            axes[idx].hist(scaled_data, bins=30, alpha=0.7, color='coral', edgecolor='black')
            axes[idx].set_title(f'{strategy}\nmean={scaled_data.mean():.2f}, std={scaled_data.std():.2f}')
            axes[idx].set_xlabel(column)
        
        # Hide unused subplots
        for idx in range(n_strategies, len(axes)):
            axes[idx].set_visible(False)
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Strategy comparison saved to: {output_path}")
        
        return fig
    
    def create_preprocessing_report(
        self,
        df_before: pd.DataFrame,
        df_after: pd.DataFrame,
        columns: Optional[List[str]] = None,
        output_dir: Optional[Path] = None
    ) -> Dict[str, plt.Figure]:
        """
        Create a comprehensive preprocessing report.
        
        Args:
            df_before: DataFrame before preprocessing
            df_after: DataFrame after preprocessing
            columns: Columns to include in the report
            output_dir: Directory to save figures
            
        Returns:
            Dict: Mapping of column names to figures
        """
        if columns is None:
            numeric_cols = df_before.select_dtypes(include=[np.number]).columns
            columns = numeric_cols[:6].tolist()  # Limit to 6 columns
            
            # Include at least one categorical column if available
            cat_cols = df_before.select_dtypes(include=['object', 'category']).columns
            if len(cat_cols) > 0 and len(columns) < 6:
                columns.append(cat_cols[0])
        
        figures = {}
        
        for col in columns:
            if col in df_before.columns:
                if pd.api.types.is_numeric_dtype(df_before[col]):
                    fig = self.compare_imputation(df_before, df_after, col)
                    figures[f'imputation_{col}'] = fig
                    
                    # Also compare scaling if data was scaled
                    if df_after[col].std() != df_before[col].std():
                        fig = self.compare_scaling(df_before, df_after, col)
                        figures[f'scaling_{col}'] = fig
        
        if output_dir:
            output_dir = Path(output_dir)
            output_dir.mkdir(parents=True, exist_ok=True)
            
            for name, fig in figures.items():
                fig.savefig(output_dir / f"{name}.png", dpi=self.dpi, bbox_inches='tight')
                plt.close(fig)
            
            logger.info(f"Preprocessing report saved to: {output_dir}")
        
        return figures
```

### The Verification: Testing Our Preprocessing System

Now let's verify everything works.

#### Test 1: Basic Imputation and Scaling

```bash
cat > test_preprocessing.py << 'EOF'
import pandas as pd
import numpy as np
from src.preprocessing.imputation import MissingValueImputer
from src.preprocessing.scaling import FeatureScaler, SmartScaler
from src.preprocessing.pipeline import DataPreprocessor
from src.preprocessing.visualization import PreprocessingVisualizer

# Create sample data with missing values
np.random.seed(42)
df = pd.DataFrame({
    'age': np.random.normal(35, 10, 100),
    'income': np.random.exponential(50000, 100),
    'category': np.random.choice(['A', 'B', 'C'], 100, p=[0.5, 0.3, 0.2]),
    'value': np.random.normal(100, 20, 100),
})

# Introduce missing values
df.loc[np.random.choice(100, 15, replace=False), 'age'] = np.nan
df.loc[np.random.choice(100, 10, replace=False), 'income'] = np.nan
df.loc[np.random.choice(100, 8, replace=False), 'category'] = np.nan

print("Original data:")
print(df.head())
print(f"\nMissing values:\n{df.isnull().sum()}")

# Test imputation
imputer = MissingValueImputer()
df_imputed = imputer.impute(
    df,
    numeric_strategy='median',
    categorical_strategy='mode'
)

print(f"\nAfter imputation:\n{df_imputed.isnull().sum()}")

# Test scaling
scaler = FeatureScaler(strategy='robust', columns=['age', 'income', 'value'])
df_scaled = scaler.fit_transform(df_imputed)

print("\nAfter scaling:")
print(df_scaled[['age', 'income', 'value']].describe())

# Test smart scaler
smart_scaler = SmartScaler()
df_smart = smart_scaler.fit_transform(df_imputed)

print("\nSmart scaling statistics:")
print(df_smart[['age', 'income', 'value']].describe())

# Test full preprocessor
preprocessor = DataPreprocessor(
    numeric_imputation='median',
    categorical_imputation='mode',
    scaling_strategy='smart'
)
df_processed = preprocessor.fit_transform(df)

print("\nFull preprocessing summary:")
print(preprocessor.get_preprocessing_summary())

# Create visualizations
visualizer = PreprocessingVisualizer()
visualizer.compare_imputation(df, df_imputed, 'age', output_path='reports/figures/imputation_age.png')
visualizer.compare_scaling(df_imputed, df_scaled, 'age', output_path='reports/figures/scaling_age.png')
visualizer.compare_strategies(df_imputed, 'income', 
                             ['standard', 'robust', 'minmax'], 
                             output_path='reports/figures/strategy_comparison.png')

print("\n✅ Preprocessing test complete!")
EOF

python test_preprocessing.py
```

#### Test 2: Integration with Data Pipeline

```bash
cat > test_preprocessing_pipeline.py << 'EOF'
import pandas as pd
import numpy as np
from src.data.pipeline import DataPipeline
from src.preprocessing.pipeline import DataPreprocessor

# Create sample data
np.random.seed(42)
df = pd.DataFrame({
    'age': np.random.normal(35, 10, 1000),
    'income': np.random.exponential(50000, 1000),
    'category': np.random.choice(['A', 'B', 'C', 'D'], 1000, p=[0.4, 0.3, 0.2, 0.1]),
    'target': np.random.choice([0, 1], 1000, p=[0.7, 0.3]),
})

# Introduce issues
df.loc[np.random.choice(1000, 100, replace=False), 'age'] = np.nan
df.loc[np.random.choice(1000, 50, replace=False), 'income'] = np.nan
df.loc[np.random.choice(1000, 30, replace=False), 'category'] = np.nan

# Add outliers
df.loc[np.random.choice(1000, 10, replace=False), 'income'] = 10000000

print("Original data shape:", df.shape)
print(f"Missing values:\n{df.isnull().sum()}")

# Create preprocessor
preprocessor = DataPreprocessor(
    numeric_imputation='median',
    categorical_imputation='mode',
    scaling_strategy='robust',
    exclude_columns=['target']
)

# Process data
df_processed = preprocessor.fit_transform(df)

print("\nProcessed data:")
print(f"Shape: {df_processed.shape}")
print(f"Missing after preprocessing: {df_processed.isnull().sum().sum()}")
print("\nProcessed statistics:")
print(df_processed.describe())

# Save processed data
df_processed.to_csv('data/processed/processed_data.csv', index=False)
print("\n✅ Processed data saved to data/processed/processed_data.csv")
EOF

python test_preprocessing_pipeline.py
```

#### Test 3: Test Different Strategies

```bash
cat > test_strategies.py << 'EOF'
import pandas as pd
import numpy as np
from src.preprocessing.scaling import FeatureScaler

# Create sample data
np.random.seed(42)
df = pd.DataFrame({
    'normal': np.random.normal(0, 1, 1000),
    'skewed': np.random.exponential(2, 1000),
    'bounded': np.random.uniform(0, 1, 1000),
    'with_outliers': np.concatenate([np.random.normal(0, 1, 950), np.random.normal(10, 1, 50)])
})

print("Original distributions:")
print(df.describe())

strategies = ['standard', 'robust', 'minmax', 'power', 'quantile']

for strategy in strategies:
    scaler = FeatureScaler(strategy=strategy)
    df_scaled = scaler.fit_transform(df)
    
    print(f"\n{strategy.upper()} scaling:")
    print(df_scaled.describe())
    print(f"Range: [{df_scaled.min().min():.2f}, {df_scaled.max().max():.2f}]")
EOF

python test_strategies.py
```

### What Just Happened: Understanding Preprocessing

#### The Missing Data Problem

Missing data is one of the most common and vexing problems in machine learning. Let's understand the types and our handling strategies:

**Types of Missing Data:**

1. **MCAR (Missing Completely At Random)**: The missingness has no relationship with any variable. Example: A survey respondent accidentally skipped a question. Our solution: Simple imputation works fine.

2. **MAR (Missing At Random)**: The missingness is related to observed variables. Example: Younger people are more likely to skip a question about retirement. Our solution: Model-based imputation can work well.

3. **MNAR (Missing Not At Random)**: The missingness is related to the missing value itself. Example: People with high income are less likely to report their income. Our solution: Requires careful modeling; our random forest imputation can help.

**Our Imputation Strategies:**

| Strategy | Best For | When to Use |
|----------|----------|-------------|
| Mean | Numeric, normal distribution | Data is roughly symmetric, few outliers |
| Median | Numeric, skewed distribution | Data is skewed or has outliers |
| Mode | Categorical | Most common category is representative |
| KNN | Numeric, strong patterns | Data has local structure, moderate missingness |
| MICE | Numeric, complex patterns | Multiple correlated features, moderate missingness |
| Random Forest | Any, complex patterns | Good for non-linear relationships, high missingness |

#### The Scaling Problem

Different features on different scales cause problems for many models:

**Why Scaling Matters:**

1. **Gradient Descent**: Features with larger scales dominate gradients, leading to slow convergence
2. **Distance-based Models**: Euclidean distance is dominated by large-scale features
3. **Regularization**: Regularization penalties apply equally to all features, but features with different scales have different sensitivity
4. **Interpretability**: Coefficients in linear models are scale-dependent

**Our Scaling Strategies:**

| Strategy | Formula | Best For |
|----------|---------|----------|
| Standard | (x - μ) / σ | Normal distributions, no extreme outliers |
| Robust | (x - median) / IQR | Data with outliers, skewed distributions |
| MinMax | (x - min) / (max - min) | Bounded data, [0,1] range needed |
| MaxAbs | x / max(abs) | Sparse data, preserving sparsity |
| Power | Box-Cox/Yeo-Johnson | Highly skewed data, non-normal distributions |
| Quantile | Rank-based transformation | Arbitrary distributions, making data uniform/normal |

### Summary

In this part, we've built a comprehensive preprocessing system that:

1. **Imputes missing values** with multiple strategies (mean, median, mode, KNN, MICE, random forest)
2. **Scales features** with multiple strategies (standard, robust, minmax, power, quantile)
3. **Automatically detects** column types and applies appropriate transformations
4. **Handles outliers** through robust scaling methods
5. **Visualizes** the effects of preprocessing
6. **Integrates** with our existing data pipeline
7. **Provides** a unified API for all preprocessing operations

### What's Next

In Part 5, we'll tackle categorical encoding—transforming categorical variables into formats that machine learning models can use. We'll cover one-hot encoding, target encoding, frequency encoding, and handle high-cardinality features.
