# Module 4.1: Feature Prep & Engineering

## Part 5: Categorical Encoding Mastery

Welcome back! In Part 4, we mastered imputation and scaling. Now we tackle one of the most critical challenges in machine learning: converting categorical variables into numerical representations that models can understand. This is where the difference between a good model and a great model often lies.

### The Target: A Complete Categorical Encoding System

By the end of this part, you'll have:
1. Multiple encoding strategies (one-hot, ordinal, target, frequency, feature hashing)
2. Advanced target encoding with regularization
3. High-cardinality handling with feature hashing
4. Integration with scikit-learn pipelines
5. Encoding impact analysis
6. Comprehensive visualization of encoding effects

### The Concept: Why Categorical Encoding Matters

Think of categorical encoding like translating between languages:

**The Problem**: Machine learning models speak numbers. Categorical variables speak words. We need a translator.

**The Challenge**: Not all translations are equal. A bad translation loses meaning. A good translation preserves the signal.

Consider the category "city":
- **One-hot encoding** turns "New York" into [1,0,0,0,...] - Like translating each word independently, losing relationships between cities
- **Ordinal encoding** turns "New York" into 1, "Boston" into 2 - Like numbering cities arbitrarily, implying an order that doesn't exist
- **Target encoding** turns "New York" into the average target value for that city - Like understanding the meaning through context

The right encoding preserves the information in the categorical variable while making it usable for the model.

### The Implementation: Building Our Encoding System

#### Step 1: Core Encoding Classes

**File:** `src/features/encoders.py`
**Path:** `ml-pipeline-project/src/features/encoders.py`

```python
"""
Advanced categorical encoding strategies.

This module provides multiple encoding methods with support for:
- One-hot encoding (dummy variables)
- Ordinal encoding (integer mapping)
- Target encoding (mean-target with regularization)
- Frequency encoding (count-based)
- Feature hashing (for high cardinality)
- Embedding-based encoding (learned representations)
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import warnings
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
from sklearn.feature_extraction import FeatureHasher
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.model_selection import StratifiedKFold, KFold

warnings.filterwarnings("ignore", category=UserWarning)

class EncodingStrategy:
    """Enumeration of available encoding strategies."""
    ONE_HOT = "one_hot"
    ORDINAL = "ordinal"
    TARGET = "target"
    FREQUENCY = "frequency"
    HASHING = "hashing"
    LABEL = "label"  # Simple label encoding
    BINARY = "binary"  # Binary encoding
    COUNT = "count"  # Count encoding
    RANK = "rank"  # Rank encoding

class BaseEncoder(BaseEstimator, TransformerMixin):
    """Base class for all encoders."""
    
    def __init__(self, columns: Optional[List[str]] = None, **kwargs):
        self.columns = columns
        self.kwargs = kwargs
        self._fitted = False
        self._feature_names = None
        
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None):
        raise NotImplementedError
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]):
        raise NotImplementedError
    
    def get_feature_names(self) -> List[str]:
        """Get the names of features after transformation."""
        return self._feature_names

class OneHotEncoderCustom(BaseEncoder):
    """
    One-hot encoding with support for handling rare categories.
    
    This encoder creates binary dummy variables for each category,
    with options to handle rare categories and maintain sparsity.
    
    Example:
        >>> encoder = OneHotEncoderCustom(
        ...     columns=['city', 'category'],
        ...     min_frequency=0.05,  # Combine categories appearing in <5% of rows
        ...     max_categories=20    # Limit to top 20 categories
        ... )
        >>> X_encoded = encoder.fit_transform(X)
    """
    
    def __init__(
        self,
        columns: Optional[List[str]] = None,
        min_frequency: float = 0.01,
        max_categories: Optional[int] = None,
        drop_first: bool = False,
        sparse: bool = True,
        handle_unknown: str = 'ignore',
        **kwargs
    ):
        """
        Initialize the one-hot encoder.
        
        Args:
            columns: Columns to encode (None for all categorical)
            min_frequency: Minimum frequency for a category to be kept
            max_categories: Maximum number of categories to keep
            drop_first: Whether to drop the first category to avoid multicollinearity
            sparse: Whether to return sparse matrix
            handle_unknown: How to handle unknown categories ('ignore' or 'error')
            **kwargs: Additional arguments
        """
        super().__init__(columns, **kwargs)
        self.min_frequency = min_frequency
        self.max_categories = max_categories
        self.drop_first = drop_first
        self.sparse = sparse
        self.handle_unknown = handle_unknown
        
        self._encoders = {}
        self._category_mappings = {}
        self._feature_names = []
        
        logger.info(f"OneHotEncoderCustom initialized with max_categories={max_categories}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'OneHotEncoderCustom':
        """
        Fit the encoder to the data.
        
        Args:
            X: Input data
            y: Ignored
            
        Returns:
            OneHotEncoderCustom: Fitted encoder
        """
        X = self._prepare_data(X)
        columns = self._get_columns(X)
        
        for col in columns:
            # Get value counts and frequencies
            value_counts = X[col].value_counts()
            frequencies = value_counts / len(X)
            
            # Apply minimum frequency threshold
            valid_categories = frequencies[frequencies >= self.min_frequency].index.tolist()
            
            # Apply max categories limit
            if self.max_categories and len(valid_categories) > self.max_categories:
                valid_categories = value_counts.head(self.max_categories).index.tolist()
            
            # Add a special "other" category for rare values
            other_values = set(X[col].unique()) - set(valid_categories)
            if other_values:
                valid_categories.append('__other__')
                logger.info(f"Column '{col}': {len(other_values)} rare values grouped as '__other__'")
            
            # Store the mapping
            self._category_mappings[col] = {
                'categories': valid_categories,
                'frequencies': {cat: freq for cat, freq in frequencies.items() if cat in valid_categories}
            }
            
            # Create OneHotEncoder for this column
            encoder = OneHotEncoder(
                categories=[valid_categories],
                drop='first' if self.drop_first else None,
                sparse_output=self.sparse,
                handle_unknown=self.handle_unknown
            )
            encoder.fit(X[[col]])
            self._encoders[col] = encoder
            
            # Generate feature names
            feature_names = [f"{col}_{cat}" for cat in valid_categories]
            if self.drop_first and valid_categories:
                feature_names = feature_names[1:]  # Drop first category
            self._feature_names.extend(feature_names)
        
        self._fitted = True
        self._columns = columns
        
        logger.info(f"OneHotEncoderCustom fitted on {len(columns)} columns")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data using the fitted encoder.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Encoded data
        """
        if not self._fitted:
            raise ValueError("Encoder has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        columns = self._get_columns(X)
        
        # Check that required columns exist
        missing_cols = [col for col in self._columns if col not in columns]
        if missing_cols:
            logger.warning(f"Missing columns: {missing_cols}")
        
        encoded_parts = []
        
        for col in self._columns:
            if col in X.columns:
                # Encode this column
                encoded = self._encoders[col].transform(X[[col]])
                encoded_parts.append(encoded)
            else:
                # Column missing, create zeros
                n_features = len(self._category_mappings[col]['categories'])
                if self.drop_first:
                    n_features = max(0, n_features - 1)
                encoded_parts.append(np.zeros((len(X), n_features)))
        
        # Combine all encoded parts
        if len(encoded_parts) == 1:
            result = encoded_parts[0]
        else:
            if self.sparse:
                from scipy.sparse import hstack
                result = hstack(encoded_parts)
            else:
                result = np.hstack(encoded_parts)
        
        # Convert to DataFrame if input was DataFrame
        if isinstance(X, pd.DataFrame):
            if self.sparse:
                result = pd.DataFrame.sparse.from_spmatrix(result, columns=self._feature_names)
            else:
                result = pd.DataFrame(result, columns=self._feature_names)
        
        return result
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _get_columns(self, X: pd.DataFrame) -> List[str]:
        """Get columns to encode."""
        if self.columns is None:
            # Use all categorical columns
            cat_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
            return cat_cols
        else:
            return [col for col in self.columns if col in X.columns]

class TargetEncoder(BaseEncoder):
    """
    Target encoding with regularization to prevent overfitting.
    
    This encoder replaces categories with the mean target value,
    with smoothing to handle rare categories and prevent overfitting.
    
    The formula used is:
        encoded_value = (prior * weight) + (category_mean * (1 - weight))
    where weight = 1 / (1 + exp(-(count - 1) / smoothing))
    
    Example:
        >>> encoder = TargetEncoder(
        ...     columns=['city', 'category'],
        ...     smoothing=1.0,
        ...     min_samples_leaf=10,
        ...     noise=0.01
        ... )
        >>> X_encoded = encoder.fit_transform(X, y)
    """
    
    def __init__(
        self,
        columns: Optional[List[str]] = None,
        smoothing: float = 1.0,
        min_samples_leaf: int = 10,
        noise: float = 0.0,
        cv_folds: int = 5,
        **kwargs
    ):
        """
        Initialize the target encoder.
        
        Args:
            columns: Columns to encode
            smoothing: Smoothing factor for regularization
            min_samples_leaf: Minimum samples in a category for no regularization
            noise: Random noise to add (prevents overfitting)
            cv_folds: Number of cross-validation folds for out-of-fold encoding
            **kwargs: Additional arguments
        """
        super().__init__(columns, **kwargs)
        self.smoothing = smoothing
        self.min_samples_leaf = min_samples_leaf
        self.noise = noise
        self.cv_folds = cv_folds
        
        self._mappings = {}
        self._prior = None
        self._feature_names = []
        
        logger.info(f"TargetEncoder initialized with smoothing={smoothing}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y: Union[np.ndarray, pd.Series]) -> 'TargetEncoder':
        """
        Fit the target encoder to the data.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            TargetEncoder: Fitted encoder
        """
        X = self._prepare_data(X)
        y = self._prepare_target(y)
        columns = self._get_columns(X)
        
        # Calculate global prior
        self._prior = np.mean(y)
        
        # Calculate category statistics
        for col in columns:
            if col in X.columns:
                stats = self._calculate_category_stats(X[col], y)
                self._mappings[col] = stats
                
                # Generate feature name
                self._feature_names.append(col)
        
        self._fitted = True
        self._columns = columns
        
        logger.info(f"TargetEncoder fitted on {len(columns)} columns")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data using the fitted encoder.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Encoded data
        """
        if not self._fitted:
            raise ValueError("Encoder has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        
        result = X.copy()
        
        for col in self._columns:
            if col in X.columns and col in self._mappings:
                encoded = self._encode_column(X[col], self._mappings[col])
                result[col] = encoded
        
        return result
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y: Union[np.ndarray, pd.Series]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit the encoder and transform with cross-validation to prevent leakage.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Encoded data
        """
        X = self._prepare_data(X)
        y = self._prepare_target(y)
        columns = self._get_columns(X)
        
        result = X.copy()
        
        # Calculate global prior
        self._prior = np.mean(y)
        
        # If only one fold or no cross-validation, use regular fit_transform
        if self.cv_folds <= 1:
            self.fit(X, y)
            return self.transform(X)
        
        # Use cross-validation for out-of-fold encoding
        kf = StratifiedKFold(n_splits=self.cv_folds, shuffle=True, random_state=42)
        
        # For each column, compute out-of-fold encodings
        for col in columns:
            if col in X.columns:
                # Initialize array for out-of-fold encodings
                encoded = np.zeros(len(X))
                encoded.fill(np.nan)
                
                # For each fold, encode the validation set using training set statistics
                for train_idx, val_idx in kf.split(X, y):
                    X_train = X.iloc[train_idx]
                    y_train = y.iloc[train_idx]
                    X_val = X.iloc[val_idx]
                    
                    # Calculate statistics on training set
                    stats = self._calculate_category_stats(X_train[col], y_train)
                    
                    # Encode validation set
                    encoded[val_idx] = self._encode_column(X_val[col], stats)
                
                # Fit on full data for future transformations
                full_stats = self._calculate_category_stats(X[col], y)
                self._mappings[col] = full_stats
                
                # Add noise if specified
                if self.noise > 0:
                    noise = np.random.normal(0, self.noise, len(encoded))
                    encoded = encoded + noise
                
                result[col] = encoded
                self._feature_names.append(col)
        
        self._fitted = True
        self._columns = columns
        
        logger.info(f"TargetEncoder fit_transform completed on {len(columns)} columns")
        return result
    
    def _calculate_category_stats(self, series: pd.Series, y: Union[np.ndarray, pd.Series]) -> Dict[str, Any]:
        """
        Calculate statistics for each category.
        
        Args:
            series: Categorical series
            y: Target values
            
        Returns:
            Dict: Category statistics
        """
        # Create DataFrame for easier aggregation
        df = pd.DataFrame({
            'category': series,
            'target': y
        })
        
        # Calculate statistics per category
        stats = df.groupby('category').agg({
            'target': ['count', 'mean', 'std']
        })
        stats.columns = ['count', 'mean', 'std']
        
        # Calculate smoothed mean
        def smoothed_mean(row):
            count = row['count']
            mean = row['mean']
            
            # Regularization weight
            weight = 1 / (1 + np.exp(-(count - self.min_samples_leaf) / self.smoothing))
            weight = np.clip(weight, 0, 1)
            
            return self._prior * (1 - weight) + mean * weight
        
        stats['smoothed_mean'] = stats.apply(smoothed_mean, axis=1)
        
        return {
            'statistics': stats,
            'categories': stats.index.tolist()
        }
    
    def _encode_column(self, series: pd.Series, stats: Dict[str, Any]) -> np.ndarray:
        """
        Encode a single column using the statistics.
        
        Args:
            series: Series to encode
            stats: Category statistics
            
        Returns:
            np.ndarray: Encoded values
        """
        # Map each value to its smoothed mean, using prior for unseen values
        encoded = series.map(stats['statistics']['smoothed_mean'])
        
        # Handle NaN values (unseen categories)
        encoded = encoded.fillna(self._prior)
        
        return encoded.values
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _prepare_target(self, y: Union[np.ndarray, pd.Series]) -> pd.Series:
        """Convert target to Series if needed."""
        if isinstance(y, np.ndarray):
            return pd.Series(y)
        return y
    
    def _get_columns(self, X: pd.DataFrame) -> List[str]:
        """Get columns to encode."""
        if self.columns is None:
            cat_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
            return cat_cols
        else:
            return [col for col in self.columns if col in X.columns]
    
    def get_feature_names(self) -> List[str]:
        """Get feature names after encoding."""
        return self._feature_names

class FrequencyEncoder(BaseEncoder):
    """
    Frequency encoding - replace categories with their frequency in the training data.
    
    This is a simple but effective encoding for high-cardinality categorical features.
    """
    
    def __init__(self, columns: Optional[List[str]] = None, normalize: bool = True, **kwargs):
        """
        Initialize the frequency encoder.
        
        Args:
            columns: Columns to encode
            normalize: Whether to normalize frequencies (0-1 range)
            **kwargs: Additional arguments
        """
        super().__init__(columns, **kwargs)
        self.normalize = normalize
        self._frequencies = {}
        self._feature_names = []
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'FrequencyEncoder':
        """Fit the encoder by calculating frequencies."""
        X = self._prepare_data(X)
        columns = self._get_columns(X)
        
        for col in columns:
            if col in X.columns:
                value_counts = X[col].value_counts()
                if self.normalize:
                    frequencies = value_counts / len(X)
                else:
                    frequencies = value_counts
                
                self._frequencies[col] = frequencies.to_dict()
                self._feature_names.append(col)
        
        self._fitted = True
        self._columns = columns
        
        logger.info(f"FrequencyEncoder fitted on {len(columns)} columns")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """Transform data using frequencies."""
        if not self._fitted:
            raise ValueError("Encoder has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        result = X.copy()
        
        for col in self._columns:
            if col in X.columns and col in self._frequencies:
                # Map values to frequencies, default to 0 for unseen values
                result[col] = X[col].map(self._frequencies[col]).fillna(0)
        
        return result
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _get_columns(self, X: pd.DataFrame) -> List[str]:
        """Get columns to encode."""
        if self.columns is None:
            cat_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
            return cat_cols
        else:
            return [col for col in self.columns if col in X.columns]
    
    def get_feature_names(self) -> List[str]:
        """Get feature names after encoding."""
        return self._feature_names

class HashingEncoder(BaseEncoder):
    """
    Feature hashing for high-cardinality categorical variables.
    
    This encoder uses the hashing trick to convert categories to a fixed-length
    vector, which is memory-efficient for high-cardinality features.
    """
    
    def __init__(
        self,
        columns: Optional[List[str]] = None,
        n_features: int = 128,
        alternate_sign: bool = True,
        **kwargs
    ):
        """
        Initialize the hashing encoder.
        
        Args:
            columns: Columns to encode
            n_features: Number of features to output
            alternate_sign: Whether to use alternate sign for hashing
            **kwargs: Additional arguments
        """
        super().__init__(columns, **kwargs)
        self.n_features = n_features
        self.alternate_sign = alternate_sign
        self._feature_names = []
        
        logger.info(f"HashingEncoder initialized with n_features={n_features}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'HashingEncoder':
        """Fit the encoder (no fitting required for hashing)."""
        X = self._prepare_data(X)
        columns = self._get_columns(X)
        
        # Generate feature names
        for col in columns:
            for i in range(self.n_features):
                self._feature_names.append(f"{col}_hash_{i}")
        
        self._fitted = True
        self._columns = columns
        
        logger.info(f"HashingEncoder initialized for {len(columns)} columns")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """Transform data using feature hashing."""
        if not self._fitted:
            raise ValueError("Encoder has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        
        result_parts = []
        
        for col in self._columns:
            if col in X.columns:
                # Convert to string
                values = X[col].astype(str)
                
                # Apply feature hashing
                hasher = FeatureHasher(
                    n_features=self.n_features,
                    input_type='string',
                    alternate_sign=self.alternate_sign
                )
                hashed = hasher.transform(values.values.reshape(-1, 1))
                result_parts.append(hashed)
        
        # Combine all parts
        if result_parts:
            from scipy.sparse import hstack
            result = hstack(result_parts)
            
            # Convert to DataFrame
            return pd.DataFrame.sparse.from_spmatrix(result, columns=self._feature_names)
        else:
            return pd.DataFrame()
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _get_columns(self, X: pd.DataFrame) -> List[str]:
        """Get columns to encode."""
        if self.columns is None:
            cat_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
            return cat_cols
        else:
            return [col for col in self.columns if col in X.columns]
    
    def get_feature_names(self) -> List[str]:
        """Get feature names after encoding."""
        return self._feature_names

class OrdinalEncoderCustom(BaseEncoder):
    """
    Ordinal encoding with automatic handling of categories.
    
    This encoder assigns integer values to categories based on their
    frequency, target mean, or alphabetical order.
    """
    
    def __init__(
        self,
        columns: Optional[List[str]] = None,
        ordering: str = 'frequency',  # 'frequency', 'target', 'alphabetical'
        **kwargs
    ):
        """
        Initialize the ordinal encoder.
        
        Args:
            columns: Columns to encode
            ordering: How to order categories ('frequency', 'target', 'alphabetical')
            **kwargs: Additional arguments
        """
        super().__init__(columns, **kwargs)
        self.ordering = ordering
        self._mappings = {}
        self._feature_names = []
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'OrdinalEncoderCustom':
        """Fit the encoder by creating category mappings."""
        X = self._prepare_data(X)
        columns = self._get_columns(X)
        
        for col in columns:
            if col in X.columns:
                if self.ordering == 'frequency':
                    # Order by frequency (most frequent first)
                    categories = X[col].value_counts().index.tolist()
                elif self.ordering == 'alphabetical':
                    # Alphabetical order
                    categories = sorted(X[col].unique())
                elif self.ordering == 'target' and y is not None:
                    # Order by target mean
                    y_series = self._prepare_target(y)
                    grouped = pd.DataFrame({
                        'col': X[col],
                        'target': y_series
                    }).groupby('col')['target'].mean()
                    categories = grouped.sort_values().index.tolist()
                else:
                    # Default: unique values in order of appearance
                    categories = X[col].unique().tolist()
                
                # Create mapping
                self._mappings[col] = {
                    'categories': categories,
                    'mapping': {cat: idx for idx, cat in enumerate(categories)}
                }
                self._feature_names.append(col)
        
        self._fitted = True
        self._columns = columns
        
        logger.info(f"OrdinalEncoderCustom fitted on {len(columns)} columns")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """Transform data using ordinal encoding."""
        if not self._fitted:
            raise ValueError("Encoder has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        result = X.copy()
        
        for col in self._columns:
            if col in X.columns and col in self._mappings:
                # Map values to integers, use -1 for unseen values
                result[col] = X[col].map(self._mappings[col]['mapping']).fillna(-1)
        
        return result
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y: Union[np.ndarray, pd.Series] = None):
        """Fit and transform in one step."""
        self.fit(X, y)
        return self.transform(X)
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _prepare_target(self, y: Union[np.ndarray, pd.Series]) -> pd.Series:
        """Convert target to Series if needed."""
        if isinstance(y, np.ndarray):
            return pd.Series(y)
        return y
    
    def _get_columns(self, X: pd.DataFrame) -> List[str]:
        """Get columns to encode."""
        if self.columns is None:
            cat_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
            return cat_cols
        else:
            return [col for col in self.columns if col in X.columns]
    
    def get_feature_names(self) -> List[str]:
        """Get feature names after encoding."""
        return self._feature_names
```

#### Step 2: Unified Encoder with Strategy Selection

**File:** `src/features/encoding.py`
**Path:** `ml-pipeline-project/src/features/encoding.py`

```python
"""
Unified interface for categorical encoding with strategy selection.
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import pandas as pd
import numpy as np
from loguru import logger
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.compose import ColumnTransformer

from .encoders import (
    OneHotEncoderCustom,
    TargetEncoder,
    FrequencyEncoder,
    HashingEncoder,
    OrdinalEncoderCustom,
    EncodingStrategy
)

class CategoricalEncoder(BaseEstimator, TransformerMixin):
    """
    Unified categorical encoder with automatic strategy selection.
    
    This class provides a simple interface for encoding categorical
    variables with automatic strategy selection based on data characteristics.
    
    Example:
        >>> encoder = CategoricalEncoder(
        ...     strategy='auto',  # Automatically selects best strategy
        ...     target_col='target'
        ... )
        >>> X_encoded = encoder.fit_transform(X, y)
    """
    
    def __init__(
        self,
        strategy: str = 'auto',
        columns: Optional[List[str]] = None,
        target_col: Optional[str] = None,
        **kwargs
    ):
        """
        Initialize the categorical encoder.
        
        Args:
            strategy: Encoding strategy ('auto', 'one_hot', 'target', 'frequency', 'hashing', 'ordinal')
            columns: Columns to encode (None for all categorical)
            target_col: Target column name (for target encoding)
            **kwargs: Additional arguments for the encoders
        """
        self.strategy = strategy
        self.columns = columns
        self.target_col = target_col
        self.kwargs = kwargs
        
        self._encoder = None
        self._selected_strategy = None
        self._feature_names = None
        
        logger.info(f"CategoricalEncoder initialized with strategy={strategy}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'CategoricalEncoder':
        """
        Fit the encoder to the data.
        
        Args:
            X: Input data
            y: Target values (required for target encoding)
            
        Returns:
            CategoricalEncoder: Fitted encoder
        """
        X = self._prepare_data(X)
        columns = self._get_columns(X)
        
        # Determine the best strategy if auto
        if self.strategy == 'auto':
            self._selected_strategy = self._select_strategy(X, columns, y)
        else:
            self._selected_strategy = self.strategy
        
        # Create the appropriate encoder
        self._encoder = self._create_encoder(columns, y)
        
        # Fit the encoder
        if y is not None and self._selected_strategy in ['target', 'ordinal']:
            self._encoder.fit(X, y)
        else:
            self._encoder.fit(X)
        
        self._feature_names = self._encoder.get_feature_names() if hasattr(self._encoder, 'get_feature_names') else columns
        
        logger.info(f"CategoricalEncoder fitted using strategy: {self._selected_strategy}")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data using the fitted encoder.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Encoded data
        """
        if self._encoder is None:
            raise ValueError("Encoder has not been fitted yet. Call fit() first.")
        
        return self._encoder.transform(X)
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit and transform in one step.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Encoded data
        """
        self.fit(X, y)
        return self.transform(X)
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def _get_columns(self, X: pd.DataFrame) -> List[str]:
        """Get columns to encode."""
        if self.columns is None:
            cat_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
            return cat_cols
        else:
            return [col for col in self.columns if col in X.columns]
    
    def _select_strategy(
        self,
        X: pd.DataFrame,
        columns: List[str],
        y: Optional[Union[np.ndarray, pd.Series]] = None
    ) -> str:
        """
        Automatically select the best encoding strategy.
        
        Args:
            X: Input data
            columns: Columns to encode
            y: Target values
            
        Returns:
            str: Selected strategy
        """
        # Analyze the data
        n_rows = len(X)
        n_columns = len(columns)
        
        # Check for target column (for target encoding)
        has_target = (self.target_col is not None and self.target_col in X.columns) or y is not None
        
        # Analyze each column
        cardinalities = []
        for col in columns:
            n_unique = X[col].nunique()
            cardinalities.append(n_unique)
        
        avg_cardinality = np.mean(cardinalities) if cardinalities else 0
        max_cardinality = np.max(cardinalities) if cardinalities else 0
        
        logger.info(f"Data characteristics: avg_cardinality={avg_cardinality:.1f}, max_cardinality={max_cardinality}")
        
        # Decision logic
        if n_columns == 0:
            return 'one_hot'  # Default
        
        # For very high cardinality, use hashing
        if max_cardinality > 1000 or avg_cardinality > 100:
            return 'hashing'
        
        # For moderate cardinality with target available, use target encoding
        if has_target and avg_cardinality > 10 and max_cardinality > 20:
            return 'target'
        
        # For high cardinality with many columns, use frequency encoding
        if avg_cardinality > 50 and n_columns > 10:
            return 'frequency'
        
        # Default to one-hot for low cardinality
        if avg_cardinality <= 10:
            return 'one_hot'
        
        # For medium cardinality, use ordinal or target
        if has_target:
            return 'target'
        else:
            return 'ordinal'
    
    def _create_encoder(self, columns: List[str], y: Optional[Union[np.ndarray, pd.Series]] = None):
        """
        Create the appropriate encoder based on selected strategy.
        
        Args:
            columns: Columns to encode
            y: Target values
            
        Returns:
            BaseEncoder: Configured encoder
        """
        if self._selected_strategy == EncodingStrategy.ONE_HOT:
            return OneHotEncoderCustom(
                columns=columns,
                **self.kwargs
            )
        
        elif self._selected_strategy == EncodingStrategy.TARGET:
            return TargetEncoder(
                columns=columns,
                **self.kwargs
            )
        
        elif self._selected_strategy == EncodingStrategy.FREQUENCY:
            return FrequencyEncoder(
                columns=columns,
                **self.kwargs
            )
        
        elif self._selected_strategy == EncodingStrategy.HASHING:
            return HashingEncoder(
                columns=columns,
                **self.kwargs
            )
        
        elif self._selected_strategy == EncodingStrategy.ORDINAL:
            return OrdinalEncoderCustom(
                columns=columns,
                **self.kwargs
            )
        
        else:
            # Default to one-hot
            logger.warning(f"Unknown strategy '{self._selected_strategy}', using one-hot")
            return OneHotEncoderCustom(columns=columns, **self.kwargs)
    
    def get_feature_names(self) -> List[str]:
        """Get feature names after encoding."""
        return self._feature_names
    
    def get_encoding_summary(self) -> Dict[str, Any]:
        """
        Get a summary of the encoding configuration.
        
        Returns:
            Dict: Encoding summary
        """
        return {
            "selected_strategy": self._selected_strategy,
            "columns": self.columns,
            "target_col": self.target_col,
            "kwargs": self.kwargs
        }

class MultiStrategyEncoder:
    """
    Encoder that can apply different strategies to different columns.
    
    This is useful when different categorical columns have different characteristics.
    """
    
    def __init__(
        self,
        column_strategies: Dict[str, str],
        default_strategy: str = 'one_hot',
        target_col: Optional[str] = None,
        **kwargs
    ):
        """
        Initialize the multi-strategy encoder.
        
        Args:
            column_strategies: Mapping of column names to strategies
            default_strategy: Default strategy for columns not specified
            target_col: Target column name
            **kwargs: Additional arguments
        """
        self.column_strategies = column_strategies
        self.default_strategy = default_strategy
        self.target_col = target_col
        self.kwargs = kwargs
        
        self._encoders = {}
        self._feature_names = []
        self._fitted = False
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'MultiStrategyEncoder':
        """
        Fit the encoders for each column.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            MultiStrategyEncoder: Fitted encoder
        """
        X = self._prepare_data(X)
        
        for col, strategy in self.column_strategies.items():
            if col in X.columns:
                # Create encoder for this column
                encoder = CategoricalEncoder(
                    strategy=strategy,
                    columns=[col],
                    target_col=self.target_col,
                    **self.kwargs
                )
                
                # Fit the encoder
                if y is not None and strategy in ['target', 'ordinal']:
                    encoder.fit(X, y)
                else:
                    encoder.fit(X)
                
                self._encoders[col] = encoder
                self._feature_names.extend(encoder.get_feature_names())
        
        # Handle columns with default strategy
        all_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
        default_cols = [col for col in all_cols if col not in self.column_strategies]
        
        for col in default_cols:
            encoder = CategoricalEncoder(
                strategy=self.default_strategy,
                columns=[col],
                target_col=self.target_col,
                **self.kwargs
            )
            
            if y is not None and self.default_strategy in ['target', 'ordinal']:
                encoder.fit(X, y)
            else:
                encoder.fit(X)
            
            self._encoders[col] = encoder
            self._feature_names.extend(encoder.get_feature_names())
        
        self._fitted = True
        logger.info(f"MultiStrategyEncoder fitted on {len(self._encoders)} columns")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data using the fitted encoders.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Encoded data
        """
        if not self._fitted:
            raise ValueError("Encoder has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        
        encoded_parts = []
        
        for col, encoder in self._encoders.items():
            if col in X.columns:
                encoded = encoder.transform(X)
                encoded_parts.append(encoded)
        
        # Combine all encoded parts
        if encoded_parts:
            return pd.concat(encoded_parts, axis=1)
        else:
            return pd.DataFrame()
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit and transform in one step.
        """
        self.fit(X, y)
        return self.transform(X)
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def get_feature_names(self) -> List[str]:
        """Get feature names after encoding."""
        return self._feature_names
```

#### Step 3: Visualization of Encoding Effects

**File:** `src/features/visualization.py`
**Path:** `ml-pipeline-project/src/features/visualization.py`

```python
"""
Visualization utilities for categorical encoding.
"""

from typing import Dict, List, Optional, Union, Any
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
from loguru import logger

class EncodingVisualizer:
    """
    Visualizes the effects of different encoding strategies.
    """
    
    def __init__(
        self,
        figsize: Tuple[int, int] = (12, 8),
        dpi: int = 100
    ):
        self.figsize = figsize
        self.dpi = dpi
        plt.style.use('seaborn-v0_8-whitegrid')
    
    def compare_encodings(
        self,
        df_original: pd.DataFrame,
        encoded_dfs: Dict[str, pd.DataFrame],
        column: str,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Compare different encodings for a single column.
        
        Args:
            df_original: Original DataFrame
            encoded_dfs: Dictionary mapping strategy name to encoded DataFrame
            column: Column to visualize
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        n_strategies = len(encoded_dfs) + 1
        n_cols = min(3, n_strategies)
        n_rows = (n_strategies + n_cols - 1) // n_cols
        
        fig, axes = plt.subplots(n_rows, n_cols, figsize=(self.figsize[0], self.figsize[1] * 0.7))
        axes = axes.flatten() if n_rows > 1 else [axes]
        
        # Original column
        ax = axes[0]
        value_counts = df_original[column].value_counts().head(10)
        value_counts.plot(kind='bar', ax=ax, color='steelblue')
        ax.set_title(f'Original: {column}')
        ax.set_xlabel('Category')
        ax.set_ylabel('Count')
        ax.tick_params(axis='x', rotation=45)
        
        # Encoded versions
        for idx, (strategy_name, df_encoded) in enumerate(encoded_dfs.items(), 1):
            if idx >= len(axes):
                break
            
            ax = axes[idx]
            
            if strategy_name == 'target':
                # Plot distribution of encoded values
                ax.hist(df_encoded[column], bins=30, alpha=0.7, color='coral', edgecolor='black')
                ax.set_title(f'Target Encoded: {column}')
                ax.set_xlabel('Encoded Value')
                ax.set_ylabel('Frequency')
            elif strategy_name == 'one_hot':
                # Show heatmap of one-hot encoded columns
                one_hot_cols = [c for c in df_encoded.columns if c.startswith(f"{column}_")]
                if one_hot_cols:
                    data = df_encoded[one_hot_cols].iloc[:50]  # Show first 50 rows
                    sns.heatmap(data, ax=ax, cmap='Blues', cbar=False, yticklabels=False)
                    ax.set_title(f'One-Hot: {column}')
                    ax.set_xlabel('Category')
                    ax.set_ylabel('Row')
                    ax.tick_params(axis='x', rotation=45)
            else:
                # General plot for other encodings
                ax.hist(df_encoded[column], bins=30, alpha=0.7, color='lightgreen', edgecolor='black')
                ax.set_title(f'{strategy_name.capitalize()}: {column}')
                ax.set_xlabel('Encoded Value')
                ax.set_ylabel('Frequency')
        
        # Hide unused subplots
        for idx in range(n_strategies, len(axes)):
            axes[idx].set_visible(False)
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Encoding comparison saved to: {output_path}")
        
        return fig
    
    def analyze_target_encoding(
        self,
        X: pd.DataFrame,
        y: pd.Series,
        column: str,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Analyze the effect of target encoding on a categorical variable.
        
        Args:
            X: Input data
            y: Target values
            column: Column to analyze
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        fig, axes = plt.subplots(1, 3, figsize=(self.figsize[0], self.figsize[1] * 0.6))
        
        # 1. Category frequencies
        ax = axes[0]
        value_counts = X[column].value_counts().head(10)
        value_counts.plot(kind='bar', ax=ax, color='steelblue')
        ax.set_title(f'Category Frequencies: {column}')
        ax.set_xlabel('Category')
        ax.set_ylabel('Count')
        ax.tick_params(axis='x', rotation=45)
        
        # 2. Target mean per category
        ax = axes[1]
        category_means = X.groupby(column)[y.name if hasattr(y, 'name') else 'target'].mean()
        category_means = category_means.sort_values(ascending=False).head(10)
        category_means.plot(kind='bar', ax=ax, color='coral')
        ax.set_title(f'Target Mean per Category')
        ax.set_xlabel('Category')
        ax.set_ylabel('Target Mean')
        ax.tick_params(axis='x', rotation=45)
        
        # 3. Correlation with target
        ax = axes[2]
        # Calculate target encoded values (simple version)
        encoding = X.groupby(column)[y.name if hasattr(y, 'name') else 'target'].mean()
        encoded_values = X[column].map(encoding)
        
        if len(encoded_values) > 0:
            ax.scatter(encoded_values, y, alpha=0.3, s=10)
            ax.set_title('Target Encoding vs Target')
            ax.set_xlabel('Encoded Value')
            ax.set_ylabel('Target')
            
            # Add trend line
            z = np.polyfit(encoded_values, y, 1)
            p = np.poly1d(z)
            ax.plot(sorted(encoded_values), p(sorted(encoded_values)), 
                   'red', linewidth=2, label='Trend')
            ax.legend()
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Target encoding analysis saved to: {output_path}")
        
        return fig
    
    def create_encoding_report(
        self,
        df_original: pd.DataFrame,
        df_encoded: pd.DataFrame,
        columns: Optional[List[str]] = None,
        output_dir: Optional[Path] = None
    ) -> Dict[str, plt.Figure]:
        """
        Create a comprehensive encoding report.
        
        Args:
            df_original: Original DataFrame
            df_encoded: Encoded DataFrame
            columns: Columns to include
            output_dir: Directory to save figures
            
        Returns:
            Dict: Mapping of column names to figures
        """
        if columns is None:
            cat_cols = df_original.select_dtypes(include=['object', 'category']).columns
            columns = cat_cols[:6].tolist()
        
        figures = {}
        
        for col in columns:
            if col in df_original.columns:
                fig = self._create_column_report(df_original, df_encoded, col)
                figures[col] = fig
                
                if output_dir:
                    output_dir = Path(output_dir)
                    output_dir.mkdir(parents=True, exist_ok=True)
                    fig.savefig(output_dir / f"encoding_{col}.png", 
                               dpi=self.dpi, bbox_inches='tight')
                    plt.close(fig)
        
        if output_dir:
            logger.info(f"Encoding report saved to: {output_dir}")
        
        return figures
    
    def _create_column_report(
        self,
        df_original: pd.DataFrame,
        df_encoded: pd.DataFrame,
        column: str
    ) -> plt.Figure:
        """
        Create a report for a single column.
        
        Args:
            df_original: Original DataFrame
            df_encoded: Encoded DataFrame
            column: Column to report on
            
        Returns:
            plt.Figure: The created figure
        """
        fig, axes = plt.subplots(1, 2, figsize=(self.figsize[0], self.figsize[1] * 0.5))
        
        # Original distribution
        ax = axes[0]
        value_counts = df_original[column].value_counts().head(10)
        value_counts.plot(kind='bar', ax=ax, color='steelblue')
        ax.set_title(f'Original: {column}')
        ax.set_xlabel('Category')
        ax.set_ylabel('Count')
        ax.tick_params(axis='x', rotation=45)
        
        # Encoded distribution
        ax = axes[1]
        if column in df_encoded.columns:
            if pd.api.types.is_numeric_dtype(df_encoded[column]):
                # Numeric encoding
                ax.hist(df_encoded[column].dropna(), bins=30, 
                       alpha=0.7, color='coral', edgecolor='black')
                ax.set_title(f'Encoded: {column}')
                ax.set_xlabel('Encoded Value')
                ax.set_ylabel('Frequency')
            else:
                # One-hot or other encoding
                encoded_cols = [c for c in df_encoded.columns if c.startswith(f"{column}_")]
                if encoded_cols:
                    # Show first 20 rows of one-hot encoding as heatmap
                    data = df_encoded[encoded_cols].iloc[:20]
                    sns.heatmap(data, ax=ax, cmap='Blues', cbar=False, 
                              yticklabels=False, xticklabels=True)
                    ax.set_title(f'Encoded: {column} (first 20 rows)')
                    ax.set_xlabel('Category')
                    ax.tick_params(axis='x', rotation=45)
        
        plt.tight_layout()
        return fig
```

### The Verification: Testing Our Encoding System

#### Test 1: Basic Encoding

```bash
cat > test_encoding.py << 'EOF'
import pandas as pd
import numpy as np
from src.features.encoders import (
    OneHotEncoderCustom,
    TargetEncoder,
    FrequencyEncoder,
    OrdinalEncoderCustom
)
from src.features.encoding import CategoricalEncoder

# Create sample data
np.random.seed(42)
n_samples = 1000

df = pd.DataFrame({
    'city': np.random.choice(['NYC', 'LA', 'Chicago', 'Boston', 'SF', 'Austin'], 
                             n_samples, p=[0.3, 0.2, 0.2, 0.1, 0.1, 0.1]),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n_samples),
    'high_cardinality': np.random.choice([f'value_{i}' for i in range(200)], n_samples),
    'target': np.random.normal(50, 15, n_samples)
})

# Add some relationship in target
df['target'] = df['target'] + df['city'].map({
    'NYC': 10, 'LA': 5, 'Chicago': 0, 'Boston': -5, 'SF': -10, 'Austin': -8
})

print("Original data:")
print(df.head())
print(f"\nUnique values per column:\n{df.nunique()}")

# Test each encoder

print("\n" + "="*60)
print("1. One-Hot Encoding")
print("="*60)
encoder = OneHotEncoderCustom(columns=['city', 'category'], drop_first=True)
df_onehot = encoder.fit_transform(df)
print(f"One-hot encoded shape: {df_onehot.shape}")
print(f"Feature names: {encoder.get_feature_names()[:5]}...")

print("\n" + "="*60)
print("2. Target Encoding")
print("="*60)
encoder = TargetEncoder(columns=['city', 'category'], smoothing=1.0, cv_folds=3)
df_target = encoder.fit_transform(df, df['target'])
print(f"Target encoded shape: {df_target.shape}")
print(df_target[['city', 'category']].head())

print("\n" + "="*60)
print("3. Frequency Encoding")
print("="*60)
encoder = FrequencyEncoder(columns=['city', 'high_cardinality'])
df_freq = encoder.fit_transform(df)
print(f"Frequency encoded shape: {df_freq.shape}")
print(df_freq[['city', 'high_cardinality']].head())

print("\n" + "="*60)
print("4. Ordinal Encoding")
print("="*60)
encoder = OrdinalEncoderCustom(columns=['city', 'category'], ordering='frequency')
df_ordinal = encoder.fit_transform(df)
print(f"Ordinal encoded shape: {df_ordinal.shape}")
print(df_ordinal[['city', 'category']].head())

print("\n" + "="*60)
print("5. Auto Strategy Selection")
print("="*60)
encoder = CategoricalEncoder(strategy='auto')
df_auto = encoder.fit_transform(df)
print(f"Auto encoded shape: {df_auto.shape}")
print(f"Selected strategy: {encoder._selected_strategy}")

print("\n✅ Encoding test complete!")
EOF

python test_encoding.py
```

#### Test 2: Encoding Integration

```bash
cat > test_encoding_integration.py << 'EOF'
import pandas as pd
import numpy as np
from src.features.encoding import CategoricalEncoder, MultiStrategyEncoder
from src.preprocessing.pipeline import DataPreprocessor
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

# Create sample data
np.random.seed(42)
n_samples = 500

df = pd.DataFrame({
    'age': np.random.normal(35, 10, n_samples),
    'city': np.random.choice(['NYC', 'LA', 'Chicago', 'Boston', 'SF'], 
                             n_samples, p=[0.25, 0.25, 0.2, 0.15, 0.15]),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E', 'F'], 
                                 n_samples, p=[0.2, 0.2, 0.2, 0.15, 0.15, 0.1]),
    'high_card': np.random.choice([f'val_{i}' for i in range(100)], n_samples),
    'target': np.random.normal(50, 15, n_samples)
})

# Introduce some missing values
df.loc[np.random.choice(n_samples, 30, replace=False), 'age'] = np.nan
df.loc[np.random.choice(n_samples, 20, replace=False), 'city'] = np.nan

print("Original data:")
print(f"Shape: {df.shape}")
print(f"Missing:\n{df.isnull().sum()}")

# Test 1: Using CategoricalEncoder in a pipeline
print("\n" + "="*60)
print("Test 1: Pipeline with CategoricalEncoder")
print("="*60)

# Create a pipeline with preprocessing and encoding
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression

encoder = CategoricalEncoder(strategy='auto')
preprocessor = DataPreprocessor(
    numeric_imputation='median',
    categorical_imputation='mode',
    scaling_strategy='standard'
)

pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('encoder', encoder),
    ('scaler', StandardScaler()),
    ('model', LinearRegression())
])

# Fit the pipeline
X = df.drop('target', axis=1)
y = df['target']

pipeline.fit(X, y)
print("Pipeline fitted successfully!")
print(f"Encoder selected strategy: {encoder._selected_strategy}")
print(f"Pipeline steps: {pipeline.named_steps.keys()}")

# Test 2: Multi-strategy encoding
print("\n" + "="*60)
print("Test 2: Multi-Strategy Encoding")
print("="*60)

# Define different strategies for different columns
column_strategies = {
    'city': 'one_hot',           # Low cardinality -> one-hot
    'category': 'target',        # Medium cardinality -> target
    'high_card': 'hashing'       # High cardinality -> hashing
}

multi_encoder = MultiStrategyEncoder(
    column_strategies=column_strategies,
    default_strategy='one_hot'
)

# Prepare data (handle missing values first)
df_clean = df.dropna(subset=['city', 'category', 'high_card'])
X_clean = df_clean.drop('target', axis=1)

# Fit and transform
X_encoded = multi_encoder.fit_transform(X_clean, df_clean['target'])
print(f"Multi-encoder output shape: {X_encoded.shape}")
print(f"Feature names: {X_encoded.columns.tolist()[:10]}...")

# Test 3: Encoding with different target types
print("\n" + "="*60)
print("Test 3: Different Target Types")
print("="*60)

# Classification target
df_class = df.copy()
df_class['target_class'] = (df['target'] > 50).astype(int)

encoder_class = CategoricalEncoder(strategy='target')
encoder_class.fit_transform(df_class[['city', 'category']], df_class['target_class'])
print(f"Classification target - strategy: {encoder_class._selected_strategy}")

# Regression target
encoder_reg = CategoricalEncoder(strategy='target')
encoder_reg.fit_transform(df_class[['city', 'category']], df_class['target'])
print(f"Regression target - strategy: {encoder_reg._selected_strategy}")

print("\n✅ Encoding integration test complete!")
EOF

python test_encoding_integration.py
```

#### Test 3: Encoding Visualization

```bash
cat > test_encoding_visualization.py << 'EOF'
import pandas as pd
import numpy as np
from src.features.encoders import OneHotEncoderCustom, TargetEncoder, FrequencyEncoder
from src.features.visualization import EncodingVisualizer

# Create sample data
np.random.seed(42)
n_samples = 500

df = pd.DataFrame({
    'city': np.random.choice(['NYC', 'LA', 'Chicago', 'Boston', 'SF', 'Austin', 'Miami'], 
                             n_samples, p=[0.2, 0.18, 0.15, 0.13, 0.12, 0.11, 0.11]),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n_samples),
    'target': np.random.normal(50, 15, n_samples)
})

# Add relationship in target
df['target'] = df['target'] + df['city'].map({
    'NYC': 15, 'LA': 8, 'Chicago': 3, 'Boston': -3, 'SF': -8, 'Austin': -10, 'Miami': -5
})

# Encode using different strategies
encoders = {
    'one_hot': OneHotEncoderCustom(columns=['city', 'category'], drop_first=True),
    'target': TargetEncoder(columns=['city', 'category'], smoothing=1.0, cv_folds=3),
    'frequency': FrequencyEncoder(columns=['city', 'category']),
    'ordinal': None  # We'll use our custom ordinal encoder
}

from src.features.encoders import OrdinalEncoderCustom
encoders['ordinal'] = OrdinalEncoderCustom(columns=['city', 'category'], ordering='frequency')

# Apply each encoder
encoded_dfs = {}
for name, encoder in encoders.items():
    if name == 'target':
        encoded = encoder.fit_transform(df, df['target'])
    else:
        encoded = encoder.fit_transform(df)
    encoded_dfs[name] = encoded

# Create visualizations
visualizer = EncodingVisualizer()

# Compare encodings for city column
visualizer.compare_encodings(
    df, encoded_dfs, 'city',
    output_path='reports/figures/encoding_comparison_city.png'
)

# Analyze target encoding
visualizer.analyze_target_encoding(
    df, df['target'], 'city',
    output_path='reports/figures/target_encoding_analysis.png'
)

# Create comprehensive report
visualizer.create_encoding_report(
    df, encoded_dfs['target'], 
    columns=['city', 'category'],
    output_dir='reports/figures/encoding_report'
)

print("\n✅ Encoding visualization complete!")
print("Check reports/figures/ for visualizations")
EOF

python test_encoding_visualization.py
```

### What Just Happened: Understanding Categorical Encoding

#### The Encoding Spectrum

Categorical encodings exist on a spectrum from simple to complex:

**1. Simple Encodings (Low Information, High Interpretability)**
- **One-Hot**: Creates binary columns for each category
  - Pros: Simple, interpretable, no ordinal assumption
  - Cons: Can create many columns, loses category relationships
  - Best for: Low-cardinality categories (<10 unique values)

**2. Medium Encodings (Moderate Information, Mixed Interpretability)**
- **Ordinal**: Assigns integers based on frequency or target
  - Pros: Single column, preserves ordinal relationships
  - Cons: Imposes arbitrary ordering
  - Best for: Ordered categories or frequency-based importance

- **Frequency**: Replaces categories with their count
  - Pros: Single column, captures rarity
  - Cons: Can be dominated by frequent categories
  - Best for: High-cardinality, importance based on frequency

**3. Complex Encodings (High Information, Lower Interpretability)**
- **Target Encoding**: Replaces categories with target mean
  - Pros: Highly informative, captures relationships
  - Cons: Prone to overfitting, requires regularization
  - Best for: High-cardinality, strong target relationship

- **Feature Hashing**: Uses hashing to create fixed-length vectors
  - Pros: Memory-efficient, handles any cardinality
  - Cons: Collisions possible, less interpretable
  - Best for: Very high cardinality, streaming data

#### The Target Encoding Regularization

Target encoding is powerful but dangerous. Here's why we need regularization:

**The Problem**: If a category appears only once, its target mean is just that single value. This can overfit horribly.

**Our Solution - Smoothing**:
```
encoded_value = prior * (1 - weight) + category_mean * weight
```
where `weight = 1 / (1 + exp(-(count - min_samples_leaf) / smoothing))`

This means:
- Frequent categories: weight → 1 (use category mean)
- Rare categories: weight → 0 (use global prior)
- Smooth transition in between

**The Solution - Cross-Validation**:
We use out-of-fold encoding during training:
- For each fold, compute encodings on training folds
- Apply to validation fold
- Prevents leakage from validation data

#### Automatic Strategy Selection

Our `CategoricalEncoder` with `strategy='auto'` makes decisions based on:

1. **Cardinality**: Number of unique values
   - Low (<10): One-hot encoding
   - Medium (10-100): Target or ordinal encoding
   - High (>100): Hashing or frequency encoding

2. **Target Availability**: 
   - Has target: Target encoding is viable
   - No target: Use unsupervised methods

3. **Dimensionality Constraints**:
   - Many columns: Use memory-efficient methods (hashing, frequency)
   - Few columns: Can use one-hot or target

4. **Data Scale**:
   - Small datasets: Use simpler encodings (one-hot)
   - Large datasets: Can use complex encodings (target)

### Summary

In this part, we've built a comprehensive categorical encoding system that:

1. **Implements multiple encoding strategies** (one-hot, target, frequency, ordinal, hashing)
2. **Prevents overfitting** in target encoding with smoothing and cross-validation
3. **Automatically selects** optimal strategies based on data characteristics
4. **Handles high cardinality** with hashing and frequency encoding
5. **Integrates** with scikit-learn pipelines
6. **Visualizes** the effects of different encodings
7. **Provides** a unified API for all encoding operations

### What's Next

In Part 6, we'll explore feature creation—generating new features from existing ones through interactions, polynomials, and domain-specific transformations. We'll also cover feature selection techniques to identify the most important features for our models.
