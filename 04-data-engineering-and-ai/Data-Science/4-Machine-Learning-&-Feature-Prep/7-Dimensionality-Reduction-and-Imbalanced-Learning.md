# Module 4.1: Feature Prep & Engineering

## Part 7: Dimensionality Reduction and Imbalanced Learning

Welcome to the final part of Module 4.1! We've covered imputation, scaling, encoding, feature creation, and selection. Now we'll tackle two critical challenges that often arise in real-world machine learning: high-dimensional data (too many features) and imbalanced target variables (one class dominates). These challenges can cripple your model if not handled properly.

### The Target: A Complete Dimensionality Reduction and Imbalance Handling System

By the end of this part, you'll have:
1. Linear dimensionality reduction (PCA, LDA)
2. Non-linear dimensionality reduction (t-SNE, UMAP)
3. Automated dimensionality selection
4. Multiple imbalance handling strategies (SMOTE, ADASYN, class weighting)
5. Integration with our preprocessing pipeline
6. Visualization of reduced dimensions
7. Comprehensive evaluation of imbalance handling

### The Concept: Understanding the Challenges

#### The Curse of Dimensionality

Imagine you're trying to find a specific grain of sand on a beach. Easy enough with one beach. Now imagine you have 100 beaches, and the grain could be on any of them. Each additional "dimension" (beach) makes the search exponentially harder.

In machine learning, each feature adds another dimension:
- **2 features**: Points on a 2D plane
- **3 features**: Points in a 3D space
- **100 features**: Points in 100-dimensional hyperspace

The problem: In high dimensions, data becomes sparse, distances become meaningless, and models struggle to find patterns.

**The Curse of Dimensionality in Practice:**
- More data needed to fill the space
- Overfitting becomes easier
- Computation becomes expensive
- Interpretability decreases

**The Solution: Dimensionality Reduction**
- **PCA**: Find the directions of maximum variance
- **t-SNE**: Preserve local structure for visualization
- **LDA**: Find directions that separate classes

#### The Imbalance Problem

Think of a rare disease that affects 1% of patients. A model that always predicts "no disease" is 99% accurate but completely useless. Accuracy is a terrible metric for imbalanced data.

**The Problem with Imbalanced Data:**
- Model learns to predict the majority class
- Minority class performance is poor
- Accuracy is misleading
- Business impact can be severe (missing fraud, disease, etc.)

**The Solution: Imbalance Handling**
- **Resampling**: Over-sample minority, under-sample majority
- **Synthetic Data**: SMOTE creates synthetic minority examples
- **Cost-Sensitive Learning**: Penalize misclassifying minority class
- **Ensemble Methods**: Balanced random forests, EasyEnsemble

### The Implementation: Building Our Solutions

#### Step 1: Dimensionality Reduction

**File:** `src/features/dimensionality.py`
**Path:** `ml-pipeline-project/src/features/dimensionality.py`

```python
"""
Dimensionality reduction techniques for feature space compression.

This module provides both linear and non-linear dimensionality reduction methods:
- PCA (Principal Component Analysis)
- LDA (Linear Discriminant Analysis)
- t-SNE (t-Distributed Stochastic Neighbor Embedding)
- UMAP (Uniform Manifold Approximation and Projection)
- Autoencoders (Deep learning-based reduction)
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import warnings
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.decomposition import PCA, IncrementalPCA
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.manifold import TSNE
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestClassifier

warnings.filterwarnings("ignore", category=UserWarning)

class DimensionalityReducer(BaseEstimator, TransformerMixin):
    """
    Unified interface for dimensionality reduction.
    
    This class provides a consistent API for various dimensionality
    reduction techniques with automatic parameter selection.
    
    Example:
        >>> reducer = DimensionalityReducer(
        ...     method='pca',
        ...     n_components=0.95  # Preserve 95% variance
        ... )
        >>> X_reduced = reducer.fit_transform(X)
    """
    
    def __init__(
        self,
        method: str = 'pca',
        n_components: Optional[Union[int, float]] = None,
        random_state: int = 42,
        **kwargs
    ):
        """
        Initialize the dimensionality reducer.
        
        Args:
            method: Reduction method ('pca', 'lda', 'tsne', 'umap', 'incremental_pca')
            n_components: Number of components or variance ratio to preserve
            random_state: Random seed for reproducibility
            **kwargs: Additional arguments for the reducer
        """
        self.method = method
        self.n_components = n_components
        self.random_state = random_state
        self.kwargs = kwargs
        
        self._reducer = None
        self._feature_names = None
        self._explained_variance = None
        
        logger.info(f"DimensionalityReducer initialized with method={method}")
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> 'DimensionalityReducer':
        """
        Fit the dimensionality reducer.
        
        Args:
            X: Input data
            y: Target (required for LDA)
            
        Returns:
            DimensionalityReducer: Fitted reducer
        """
        X = self._prepare_data(X)
        
        # Create the appropriate reducer
        self._reducer = self._create_reducer(X, y)
        
        # Fit the reducer
        if self.method == 'lda':
            if y is None:
                raise ValueError("LDA requires target values (y)")
            self._reducer.fit(X, y)
        else:
            self._reducer.fit(X)
        
        # Store explained variance for PCA
        if hasattr(self._reducer, 'explained_variance_ratio_'):
            self._explained_variance = self._reducer.explained_variance_ratio_
        
        self._fitted = True
        logger.info(f"DimensionalityReducer fitted. Components: {self.get_n_components()}")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform the data to lower dimensions.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Reduced data
        """
        if not self._fitted:
            raise ValueError("DimensionalityReducer has not been fitted yet. Call fit() first.")
        
        X = self._prepare_data(X)
        X_reduced = self._reducer.transform(X)
        
        # Convert back to DataFrame if input was DataFrame
        if isinstance(X, pd.DataFrame):
            # Create meaningful column names
            if self.method == 'pca':
                col_names = [f'PC{i+1}' for i in range(X_reduced.shape[1])]
            elif self.method == 'lda':
                col_names = [f'LD{i+1}' for i in range(X_reduced.shape[1])]
            else:
                col_names = [f'component_{i+1}' for i in range(X_reduced.shape[1])]
            
            return pd.DataFrame(X_reduced, columns=col_names, index=X.index)
        
        return X_reduced
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y=None) -> Union[pd.DataFrame, np.ndarray]:
        """
        Fit and transform in one step.
        """
        self.fit(X, y)
        return self.transform(X)
    
    def _create_reducer(self, X: pd.DataFrame, y: Optional[np.ndarray] = None):
        """
        Create the appropriate reducer based on method.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            sklearn transformer: Configured reducer
        """
        n_features = X.shape[1]
        
        # Handle n_components for different methods
        if self.n_components is None:
            n_comp = min(10, n_features)  # Default to 10 components or all features
        elif isinstance(self.n_components, float) and self.n_components < 1:
            # Interpret as variance ratio for PCA
            n_comp = self.n_components
        else:
            n_comp = int(self.n_components)
        
        if self.method == 'pca':
            return PCA(
                n_components=n_comp,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == 'incremental_pca':
            return IncrementalPCA(
                n_components=n_comp if isinstance(n_comp, int) else None,
                **self.kwargs
            )
        
        elif self.method == 'lda':
            # LDA requires n_components <= n_classes - 1
            if y is not None:
                n_classes = len(np.unique(y))
                if isinstance(n_comp, int) and n_comp >= n_classes:
                    logger.warning(f"LDA n_components ({n_comp}) reduced to {n_classes-1} (n_classes-1)")
                    n_comp = n_classes - 1
            return LinearDiscriminantAnalysis(
                n_components=n_comp if isinstance(n_comp, int) else None,
                **self.kwargs
            )
        
        elif self.method == 'tsne':
            # t-SNE is typically used with fixed n_components (2 or 3)
            n_comp = self.n_components if self.n_components is not None else 2
            if isinstance(n_comp, float):
                n_comp = 2
            
            return TSNE(
                n_components=n_comp,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == 'umap':
            try:
                import umap
                n_comp = self.n_components if self.n_components is not None else 2
                if isinstance(n_comp, float):
                    n_comp = 2
                
                return umap.UMAP(
                    n_components=n_comp,
                    random_state=self.random_state,
                    **self.kwargs
                )
            except ImportError:
                logger.error("UMAP not installed. Install with: pip install umap-learn")
                raise
        
        else:
            raise ValueError(f"Unknown method: {self.method}")
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame if needed."""
        if isinstance(X, np.ndarray):
            return pd.DataFrame(X)
        return X
    
    def get_n_components(self) -> int:
        """Get the number of components in the reduced space."""
        if self._reducer is None:
            return 0
        return self._reducer.n_components_
    
    def get_explained_variance(self) -> Optional[np.ndarray]:
        """Get explained variance ratio (for PCA)."""
        return self._explained_variance
    
    def get_component_importance(self) -> Dict[str, float]:
        """
        Get component importance (for PCA).
        
        Returns:
            Dict: Component to importance mapping
        """
        if self._explained_variance is None:
            return {}
        
        return {f'PC{i+1}': var for i, var in enumerate(self._explained_variance)}
    
    def inverse_transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Inverse transform (reconstruct original data from reduced representation).
        
        Args:
            X: Reduced data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Reconstructed data
        """
        if not self._fitted:
            raise ValueError("DimensionalityReducer has not been fitted yet. Call fit() first.")
        
        if not hasattr(self._reducer, 'inverse_transform'):
            raise ValueError(f"Method '{self.method}' does not support inverse_transform")
        
        X = self._prepare_data(X)
        X_reconstructed = self._reducer.inverse_transform(X)
        
        # Convert back to DataFrame if needed
        if isinstance(X, pd.DataFrame):
            return pd.DataFrame(X_reconstructed, index=X.index)
        
        return X_reconstructed

class AutoDimensionSelector:
    """
    Automatically selects optimal number of dimensions.
    
    This class uses cross-validation to find the best number of
    components for a given model and metric.
    """
    
    def __init__(
        self,
        method: str = 'pca',
        component_range: List[int] = None,
        estimator: Optional[BaseEstimator] = None,
        scoring: str = 'accuracy',
        cv: int = 5,
        random_state: int = 42
    ):
        """
        Initialize the automatic dimension selector.
        
        Args:
            method: Dimensionality reduction method
            component_range: Range of components to try
            estimator: Model to evaluate
            scoring: Scoring metric
            cv: Number of cross-validation folds
            random_state: Random seed
        """
        self.method = method
        self.component_range = component_range or [2, 5, 10, 20, 30, 50]
        self.estimator = estimator
        self.scoring = scoring
        self.cv = cv
        self.random_state = random_state
        
        self._best_n_components = None
        self._best_score = None
        self._results = []
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y: np.ndarray) -> 'AutoDimensionSelector':
        """
        Find the optimal number of dimensions.
        
        Args:
            X: Input data
            y: Target values
            
        Returns:
            AutoDimensionSelector: Fitted selector
        """
        X = self._prepare_data(X)
        
        # Create default estimator if none provided
        if self.estimator is None:
            if len(np.unique(y)) <= 2:
                self.estimator = RandomForestClassifier(
                    n_estimators=50, random_state=self.random_state
                )
            else:
                from sklearn.ensemble import RandomForestRegressor
                self.estimator = RandomForestRegressor(
                    n_estimators=50, random_state=self.random_state
                )
        
        best_score = -np.inf
        best_n = None
        
        # Limit component range to features
        max_components = X.shape[1]
        component_range = [n for n in self.component_range if n <= max_components]
        
        if not component_range:
            component_range = [min(10, max_components)]
        
        for n_components in component_range:
            try:
                # Create reducer
                reducer = DimensionalityReducer(
                    method=self.method,
                    n_components=n_components,
                    random_state=self.random_state
                )
                
                # Reduce data
                X_reduced = reducer.fit_transform(X, y)
                
                # Evaluate using cross-validation
                scores = cross_val_score(
                    self.estimator,
                    X_reduced,
                    y,
                    cv=self.cv,
                    scoring=self.scoring
                )
                
                mean_score = np.mean(scores)
                std_score = np.std(scores)
                
                self._results.append({
                    'n_components': n_components,
                    'mean_score': mean_score,
                    'std_score': std_score
                })
                
                if mean_score > best_score:
                    best_score = mean_score
                    best_n = n_components
                    
                    logger.info(f"Best so far: {n_components} components, score={mean_score:.4f}")
            
            except Exception as e:
                logger.debug(f"Failed with {n_components} components: {str(e)}")
                continue
        
        self._best_n_components = best_n
        self._best_score = best_score
        
        logger.info(f"AutoDimensionSelector complete. Best: {best_n} components, score={best_score:.4f}")
        return self
    
    def transform(self, X: Union[pd.DataFrame, np.ndarray]) -> Union[pd.DataFrame, np.ndarray]:
        """
        Transform using the optimal number of dimensions.
        
        Args:
            X: Input data
            
        Returns:
            Union[pd.DataFrame, np.ndarray]: Reduced data
        """
        if self._best_n_components is None:
            raise ValueError("AutoDimensionSelector has not been fitted yet. Call fit() first.")
        
        reducer = DimensionalityReducer(
            method=self.method,
            n_components=self._best_n_components,
            random_state=self.random_state
        )
        
        return reducer.fit_transform(X)
    
    def fit_transform(self, X: Union[pd.DataFrame, np.ndarray], y: np.ndarray) -> Union[pd.DataFrame, np.ndarray]:
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
    
    def get_results(self) -> pd.DataFrame:
        """Get results for all tested component counts."""
        return pd.DataFrame(self._results)
    
    def get_best_n(self) -> int:
        """Get the best number of components."""
        return self._best_n_components
```

#### Step 2: Imbalanced Learning

**File:** `src/features/imbalance.py`
**Path:** `ml-pipeline-project/src/features/imbalance.py`

```python
"""
Techniques for handling imbalanced datasets.

This module provides:
- Over-sampling (SMOTE, ADASYN, RandomOverSampler)
- Under-sampling (RandomUnderSampler, ClusterCentroids)
- Hybrid methods (SMOTE-ENN, SMOTE-Tomek)
- Cost-sensitive learning
- Balanced ensemble methods
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import warnings
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.utils.class_weight import compute_class_weight
from sklearn.model_selection import StratifiedKFold

warnings.filterwarnings("ignore", category=UserWarning)

class ImbalanceHandler(BaseEstimator, TransformerMixin):
    """
    Comprehensive imbalance handling with multiple strategies.
    
    This class provides a unified interface for various imbalance
    handling techniques:
    - SMOTE: Synthetic Minority Over-sampling
    - ADASYN: Adaptive Synthetic Sampling
    - Random Over-sampling
    - Random Under-sampling
    - SMOTE-ENN: SMOTE with Edited Nearest Neighbors
    - SMOTE-Tomek: SMOTE with Tomek links
    
    Example:
        >>> handler = ImbalanceHandler(
        ...     method='smote',
        ...     sampling_strategy=0.5  # Balance to 50% minority
        ... )
        >>> X_resampled, y_resampled = handler.fit_resample(X, y)
    """
    
    def __init__(
        self,
        method: str = 'smote',
        sampling_strategy: Union[str, float, Dict] = 'auto',
        random_state: int = 42,
        **kwargs
    ):
        """
        Initialize the imbalance handler.
        
        Args:
            method: Resampling method ('smote', 'adasyn', 'random_over', 
                   'random_under', 'smote_enn', 'smote_tomek')
            sampling_strategy: Sampling strategy ('auto', float, or dict)
            random_state: Random seed
            **kwargs: Additional arguments for the resampler
        """
        self.method = method
        self.sampling_strategy = sampling_strategy
        self.random_state = random_state
        self.kwargs = kwargs
        
        self._resampler = None
        self._fitted = False
        
        logger.info(f"ImbalanceHandler initialized with method={method}")
    
    def fit_resample(
        self,
        X: Union[pd.DataFrame, np.ndarray],
        y: Union[np.ndarray, pd.Series]
    ) -> Tuple[Union[pd.DataFrame, np.ndarray], Union[np.ndarray, pd.Series]]:
        """
        Resample the dataset to handle imbalance.
        
        Args:
            X: Feature matrix
            y: Target vector
            
        Returns:
            Tuple: Resampled X and y
        """
        X = self._prepare_data(X)
        y = self._prepare_target(y)
        
        # Check if imbalance needs handling
        class_counts = pd.Series(y).value_counts()
        if len(class_counts) < 2:
            logger.warning("Only one class found. No resampling performed.")
            return X, y
        
        max_ratio = class_counts.max() / class_counts.min()
        if max_ratio < 1.5:
            logger.info(f"Dataset is relatively balanced (ratio={max_ratio:.2f}). No resampling needed.")
            return X, y
        
        # Create the appropriate resampler
        self._resampler = self._create_resampler()
        
        # Perform resampling
        try:
            X_resampled, y_resampled = self._resampler.fit_resample(X, y)
            self._fitted = True
            
            logger.info(f"Resampling complete. Original shape: {X.shape}, New shape: {X_resampled.shape}")
            logger.info(f"Class distribution after resampling: {pd.Series(y_resampled).value_counts().to_dict()}")
            
            return X_resampled, y_resampled
        
        except Exception as e:
            logger.error(f"Resampling failed: {str(e)}")
            logger.warning("Falling back to original data")
            return X, y
    
    def _create_resampler(self):
        """
        Create the appropriate resampler based on method.
        
        Returns:
            imblearn resampler: Configured resampler
        """
        try:
            from imblearn.over_sampling import (
                SMOTE, ADASYN, RandomOverSampler
            )
            from imblearn.under_sampling import (
                RandomUnderSampler, ClusterCentroids
            )
            from imblearn.combine import SMOTEENN, SMOTETomek
        except ImportError:
            logger.error("imbalanced-learn not installed. Install with: pip install imbalanced-learn")
            raise
        
        if self.method == 'smote':
            return SMOTE(
                sampling_strategy=self.sampling_strategy,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == 'adasyn':
            return ADASYN(
                sampling_strategy=self.sampling_strategy,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == 'random_over':
            return RandomOverSampler(
                sampling_strategy=self.sampling_strategy,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == 'random_under':
            return RandomUnderSampler(
                sampling_strategy=self.sampling_strategy,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == 'smote_enn':
            return SMOTEENN(
                sampling_strategy=self.sampling_strategy,
                random_state=self.random_state,
                **self.kwargs
            )
        
        elif self.method == 'smote_tomek':
            return SMOTETomek(
                sampling_strategy=self.sampling_strategy,
                random_state=self.random_state,
                **self.kwargs
            )
        
        else:
            raise ValueError(f"Unknown method: {self.method}")
    
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

class CostSensitiveHandler:
    """
    Handles imbalance through cost-sensitive learning.
    
    This class computes class weights for use in models that support
    class_weight parameters.
    """
    
    def __init__(
        self,
        strategy: str = 'balanced',
        **kwargs
    ):
        """
        Initialize the cost-sensitive handler.
        
        Args:
            strategy: Weight strategy ('balanced', 'balanced_subsample', or dict)
            **kwargs: Additional arguments
        """
        self.strategy = strategy
        self.kwargs = kwargs
        self._class_weights = None
    
    def fit(self, y: Union[np.ndarray, pd.Series]) -> 'CostSensitiveHandler':
        """
        Compute class weights from the target.
        
        Args:
            y: Target vector
            
        Returns:
            CostSensitiveHandler: Fitted handler
        """
        y = self._prepare_target(y)
        classes = np.unique(y)
        
        if self.strategy == 'balanced':
            self._class_weights = compute_class_weight(
                'balanced',
                classes=classes,
                y=y
            )
        elif self.strategy == 'balanced_subsample':
            self._class_weights = compute_class_weight(
                'balanced_subsample',
                classes=classes,
                y=y
            )
        elif isinstance(self.strategy, dict):
            self._class_weights = [self.strategy.get(cls, 1.0) for cls in classes]
        else:
            self._class_weights = np.ones(len(classes))
        
        self._class_weights = {cls: weight for cls, weight in zip(classes, self._class_weights)}
        
        logger.info(f"Class weights computed: {self._class_weights}")
        return self
    
    def get_class_weights(self) -> Dict:
        """Get the class weights."""
        if self._class_weights is None:
            raise ValueError("CostSensitiveHandler has not been fitted yet. Call fit() first.")
        return self._class_weights
    
    def _prepare_target(self, y: Union[np.ndarray, pd.Series]) -> pd.Series:
        """Convert target to Series if needed."""
        if isinstance(y, np.ndarray):
            return pd.Series(y)
        return y

class BalancedEnsemble:
    """
    Balanced ensemble methods for imbalanced data.
    
    This class creates ensembles that specifically handle imbalance
    through techniques like balanced random forests.
    """
    
    def __init__(
        self,
        base_estimator: Optional[BaseEstimator] = None,
        n_estimators: int = 100,
        sampling_strategy: Union[str, float] = 'auto',
        random_state: int = 42
    ):
        """
        Initialize the balanced ensemble.
        
        Args:
            base_estimator: Base estimator (defaults to DecisionTree)
            n_estimators: Number of estimators in ensemble
            sampling_strategy: Sampling strategy for each base estimator
            random_state: Random seed
        """
        self.base_estimator = base_estimator
        self.n_estimators = n_estimators
        self.sampling_strategy = sampling_strategy
        self.random_state = random_state
        
        self._ensemble = None
        self._fitted = False
    
    def fit(self, X: Union[pd.DataFrame, np.ndarray], y: Union[np.ndarray, pd.Series]) -> 'BalancedEnsemble':
        """
        Fit the balanced ensemble.
        
        Args:
            X: Feature matrix
            y: Target vector
            
        Returns:
            BalancedEnsemble: Fitted ensemble
        """
        try:
            from imblearn.ensemble import BalancedRandomForestClassifier
        except ImportError:
            logger.error("imbalanced-learn not installed. Install with: pip install imbalanced-learn")
            raise
        
        # Create default base estimator if needed
        if self.base_estimator is None:
            from sklearn.tree import DecisionTreeClassifier
            self.base_estimator = DecisionTreeClassifier()
        
        self._ensemble = BalancedRandomForestClassifier(
            base_estimator=self.base_estimator,
            n_estimators=self.n_estimators,
            sampling_strategy=self.sampling_strategy,
            random_state=self.random_state,
            n_jobs=-1
        )
        
        self._ensemble.fit(X, y)
        self._fitted = True
        
        logger.info(f"Balanced ensemble fitted with {self.n_estimators} estimators")
        return self
    
    def predict(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """
        Predict using the ensemble.
        
        Args:
            X: Feature matrix
            
        Returns:
            np.ndarray: Predictions
        """
        if not self._fitted:
            raise ValueError("Ensemble has not been fitted yet. Call fit() first.")
        
        return self._ensemble.predict(X)
    
    def predict_proba(self, X: Union[pd.DataFrame, np.ndarray]) -> np.ndarray:
        """
        Predict probabilities.
        
        Args:
            X: Feature matrix
            
        Returns:
            np.ndarray: Prediction probabilities
        """
        if not self._fitted:
            raise ValueError("Ensemble has not been fitted yet. Call fit() first.")
        
        return self._ensemble.predict_proba(X)
    
    def get_ensemble(self):
        """Get the underlying ensemble object."""
        return self._ensemble
    
    def get_feature_importance(self) -> np.ndarray:
        """Get feature importances from the ensemble."""
        if not self._fitted:
            raise ValueError("Ensemble has not been fitted yet. Call fit() first.")
        
        if hasattr(self._ensemble, 'feature_importances_'):
            return self._ensemble.feature_importances_
        else:
            return None
```

#### Step 3: Visualization of Dimensionality Reduction and Imbalance Handling

**File:** `src/features/visualization.py` (extended further)

```python
"""
Extended visualization for dimensionality reduction and imbalance handling.
"""

import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd
from typing import Optional, Tuple, Dict, Any
from pathlib import Path
from loguru import logger

class AdvancedVisualizer:
    """
    Advanced visualization for dimensionality reduction and imbalance.
    """
    
    def __init__(
        self,
        figsize: Tuple[int, int] = (12, 8),
        dpi: int = 100
    ):
        self.figsize = figsize
        self.dpi = dpi
        plt.style.use('seaborn-v0_8-whitegrid')
    
    def plot_pca_components(
        self,
        X_reduced: pd.DataFrame,
        y: np.ndarray,
        explained_variance: Optional[np.ndarray] = None,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Plot PCA components.
        
        Args:
            X_reduced: Reduced data (from PCA)
            y: Target values
            explained_variance: Explained variance ratio
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        fig, axes = plt.subplots(1, 2, figsize=self.figsize)
        
        # Scatter plot of first two components
        ax = axes[0]
        scatter = ax.scatter(
            X_reduced.iloc[:, 0],
            X_reduced.iloc[:, 1],
            c=y,
            cmap='viridis',
            alpha=0.6,
            s=20
        )
        ax.set_xlabel('PC1')
        ax.set_ylabel('PC2')
        ax.set_title('PCA Projection')
        plt.colorbar(scatter, ax=ax)
        
        # Explained variance
        ax = axes[1]
        if explained_variance is not None:
            cumulative = np.cumsum(explained_variance)
            ax.bar(range(1, len(explained_variance) + 1), 
                  explained_variance, alpha=0.6, label='Individual')
            ax.plot(range(1, len(explained_variance) + 1), 
                   cumulative, 'ro-', label='Cumulative')
            ax.axhline(y=0.95, color='green', linestyle='--', label='95% threshold')
            ax.set_xlabel('Component')
            ax.set_ylabel('Explained Variance Ratio')
            ax.set_title('Explained Variance')
            ax.legend()
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"PCA plot saved to: {output_path}")
        
        return fig
    
    def plot_class_distribution(
        self,
        y_before: np.ndarray,
        y_after: np.ndarray,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Plot class distribution before and after resampling.
        
        Args:
            y_before: Original target
            y_after: Resampled target
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        fig, axes = plt.subplots(1, 2, figsize=self.figsize)
        
        # Before
        ax = axes[0]
        classes_before = pd.Series(y_before).value_counts()
        ax.bar(classes_before.index.astype(str), classes_before.values, color='steelblue')
        ax.set_title(f'Before Resampling\n({len(y_before)} samples)')
        ax.set_xlabel('Class')
        ax.set_ylabel('Count')
        
        # After
        ax = axes[1]
        classes_after = pd.Series(y_after).value_counts()
        ax.bar(classes_after.index.astype(str), classes_after.values, color='coral')
        ax.set_title(f'After Resampling\n({len(y_after)} samples)')
        ax.set_xlabel('Class')
        ax.set_ylabel('Count')
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Class distribution plot saved to: {output_path}")
        
        return fig
    
    def plot_tsne_visualization(
        self,
        X_reduced: pd.DataFrame,
        y: np.ndarray,
        output_path: Optional[Path] = None
    ) -> plt.Figure:
        """
        Plot t-SNE visualization.
        
        Args:
            X_reduced: Reduced data (from t-SNE)
            y: Target values
            output_path: Optional path to save figure
            
        Returns:
            plt.Figure: The created figure
        """
        fig, ax = plt.subplots(figsize=(10, 8))
        
        # Check if 2D or 3D
        if X_reduced.shape[1] == 3:
            from mpl_toolkits.mplot3d import Axes3D
            ax = fig.add_subplot(111, projection='3d')
            scatter = ax.scatter(
                X_reduced.iloc[:, 0],
                X_reduced.iloc[:, 1],
                X_reduced.iloc[:, 2],
                c=y,
                cmap='viridis',
                alpha=0.6,
                s=20
            )
            ax.set_xlabel('t-SNE 1')
            ax.set_ylabel('t-SNE 2')
            ax.set_zlabel('t-SNE 3')
        else:
            scatter = ax.scatter(
                X_reduced.iloc[:, 0],
                X_reduced.iloc[:, 1],
                c=y,
                cmap='viridis',
                alpha=0.6,
                s=20
            )
            ax.set_xlabel('t-SNE 1')
            ax.set_ylabel('t-SNE 2')
        
        ax.set_title('t-SNE Visualization')
        plt.colorbar(scatter, ax=ax)
        
        plt.tight_layout()
        
        if output_path:
            fig.savefig(output_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"t-SNE plot saved to: {output_path}")
        
        return fig
```

### The Verification: Testing Our Dimensionality Reduction and Imbalance Handling

#### Test 1: Dimensionality Reduction

```bash
cat > test_dimensionality.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from src.features.dimensionality import DimensionalityReducer, AutoDimensionSelector

# Create high-dimensional data
X, y = make_classification(
    n_samples=500,
    n_features=50,
    n_informative=10,
    n_redundant=20,
    n_repeated=5,
    n_classes=2,
    random_state=42
)

feature_names = [f'feature_{i}' for i in range(X.shape[1])]
X = pd.DataFrame(X, columns=feature_names)

print(f"Original data shape: {X.shape}")
print(f"Target classes: {np.unique(y, return_counts=True)}")

# Test PCA
print("\n" + "="*60)
print("Test 1: PCA")
print("="*60)

pca = DimensionalityReducer(method='pca', n_components=0.95)
X_pca = pca.fit_transform(X)
print(f"PCA reduced shape: {X_pca.shape}")
print(f"Explained variance: {pca.get_explained_variance()[:5]}...")
print(f"Component importance: {pca.get_component_importance()}")

# Test LDA (requires target)
print("\n" + "="*60)
print("Test 2: LDA")
print("="*60)

lda = DimensionalityReducer(method='lda', n_components=1)
X_lda = lda.fit_transform(X, y)
print(f"LDA reduced shape: {X_lda.shape}")

# Test t-SNE
print("\n" + "="*60)
print("Test 3: t-SNE")
print("="*60)

tsne = DimensionalityReducer(method='tsne', n_components=2, perplexity=30)
# Use a subset for t-SNE (computationally expensive)
X_subset = X.iloc[:200]
X_tsne = tsne.fit_transform(X_subset)
print(f"t-SNE reduced shape: {X_tsne.shape}")

# Test auto dimension selection
print("\n" + "="*60)
print("Test 4: Auto Dimension Selection")
print("="*60)

auto = AutoDimensionSelector(
    method='pca',
    component_range=[5, 10, 15, 20, 30],
    cv=3
)
X_auto = auto.fit_transform(X, y)
print(f"Auto selected {auto.get_best_n()} components")
print(f"Shape after auto selection: {X_auto.shape}")

# Show results
results_df = auto.get_results()
print("\nAuto selection results:")
print(results_df)

print("\n✅ Dimensionality reduction test complete!")
EOF

python test_dimensionality.py
```

#### Test 2: Imbalance Handling

```bash
cat > test_imbalance.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from src.features.imbalance import ImbalanceHandler, CostSensitiveHandler, BalancedEnsemble

# Create imbalanced dataset
X, y = make_classification(
    n_samples=1000,
    n_features=20,
    n_informative=10,
    n_redundant=5,
    n_classes=2,
    weights=[0.9, 0.1],  # 90% majority, 10% minority
    random_state=42
)

X = pd.DataFrame(X)
print(f"Original shape: {X.shape}")
print(f"Class distribution: {pd.Series(y).value_counts().to_dict()}")

# Test SMOTE
print("\n" + "="*60)
print("Test 1: SMOTE")
print("="*60)

smote = ImbalanceHandler(method='smote', sampling_strategy='auto')
X_smote, y_smote = smote.fit_resample(X, y)
print(f"SMOTE shape: {X_smote.shape}")
print(f"SMOTE class distribution: {pd.Series(y_smote).value_counts().to_dict()}")

# Test ADASYN
print("\n" + "="*60)
print("Test 2: ADASYN")
print("="*60)

adasyn = ImbalanceHandler(method='adasyn')
X_adasyn, y_adasyn = adasyn.fit_resample(X, y)
print(f"ADASYN shape: {X_adasyn.shape}")
print(f"ADASYN class distribution: {pd.Series(y_adasyn).value_counts().to_dict()}")

# Test Random Under-sampling
print("\n" + "="*60)
print("Test 3: Random Under-sampling")
print("="*60)

under = ImbalanceHandler(method='random_under', sampling_strategy='auto')
X_under, y_under = under.fit_resample(X, y)
print(f"Under-sampling shape: {X_under.shape}")
print(f"Under-sampling class distribution: {pd.Series(y_under).value_counts().to_dict()}")

# Test SMOTE-ENN
print("\n" + "="*60)
print("Test 4: SMOTE-ENN")
print("="*60)

smote_enn = ImbalanceHandler(method='smote_enn')
X_enn, y_enn = smote_enn.fit_resample(X, y)
print(f"SMOTE-ENN shape: {X_enn.shape}")
print(f"SMOTE-ENN class distribution: {pd.Series(y_enn).value_counts().to_dict()}")

# Test Cost-Sensitive Learning
print("\n" + "="*60)
print("Test 5: Cost-Sensitive Learning")
print("="*60)

cs = CostSensitiveHandler(strategy='balanced')
cs.fit(y)
class_weights = cs.get_class_weights()
print(f"Class weights: {class_weights}")

# Test Balanced Ensemble
print("\n" + "="*60)
print("Test 6: Balanced Ensemble")
print("="*60)

from sklearn.tree import DecisionTreeClassifier
ensemble = BalancedEnsemble(
    base_estimator=DecisionTreeClassifier(max_depth=3),
    n_estimators=10
)
ensemble.fit(X, y)
print("Balanced ensemble fitted successfully!")

# Get feature importance if available
importances = ensemble.get_feature_importance()
if importances is not None:
    print(f"Top 5 feature importances: {importances[:5]}")

print("\n✅ Imbalance handling test complete!")
EOF

python test_imbalance.py
```

#### Test 3: Full Integration

```bash
cat > test_full_integration.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score
from src.features.dimensionality import DimensionalityReducer
from src.features.imbalance import ImbalanceHandler, CostSensitiveHandler
from src.preprocessing.pipeline import DataPreprocessor
from src.features.encoding import CategoricalEncoder

# Create imbalanced, high-dimensional dataset
X, y = make_classification(
    n_samples=1000,
    n_features=30,
    n_informative=8,
    n_redundant=10,
    n_repeated=5,
    n_classes=2,
    weights=[0.85, 0.15],
    random_state=42
)

# Convert to DataFrame with some categorical columns
X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])
X['category'] = np.random.choice(['A', 'B', 'C', 'D'], len(X))
X['region'] = np.random.choice(['North', 'South', 'East', 'West'], len(X))

# Introduce some missing values
X.loc[np.random.choice(len(X), 50, replace=False), 'feature_0'] = np.nan
X.loc[np.random.choice(len(X), 30, replace=False), 'feature_1'] = np.nan

print("Original data:")
print(f"Shape: {X.shape}")
print(f"Class distribution: {pd.Series(y).value_counts().to_dict()}")
print(f"Missing: {X.isnull().sum().sum()}")

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

print(f"\nTrain: {X_train.shape}, Test: {X_test.shape}")

# Build full pipeline
print("\n" + "="*60)
print("Building Complete Feature Engineering Pipeline")
print("="*60)

# Step 1: Preprocessing
preprocessor = DataPreprocessor(
    numeric_imputation='median',
    categorical_imputation='mode',
    scaling_strategy='standard',
    exclude_columns=['category', 'region']
)

# Step 2: Encoding
encoder = CategoricalEncoder(
    strategy='auto',
    columns=['category', 'region']
)

# Step 3: Dimensionality reduction
reducer = DimensionalityReducer(
    method='pca',
    n_components=15  # Reduce from ~30 to 15
)

# Step 4: Imbalance handling
imbalance_handler = ImbalanceHandler(
    method='smote',
    sampling_strategy='auto'
)

# Step 5: Model with class weights
model = RandomForestClassifier(
    n_estimators=100,
    random_state=42,
    class_weight='balanced'
)

# Apply pipeline steps
print("Step 1: Preprocessing...")
X_train_proc = preprocessor.fit_transform(X_train)
X_test_proc = preprocessor.transform(X_test)

print("Step 2: Encoding...")
X_train_enc = encoder.fit_transform(X_train_proc)
X_test_enc = encoder.transform(X_test_proc)

print(f"After encoding: {X_train_enc.shape}")

print("Step 3: Dimensionality reduction...")
X_train_reduced = reducer.fit_transform(X_train_enc)
X_test_reduced = reducer.transform(X_test_enc)

print(f"After reduction: {X_train_reduced.shape}")

print("Step 4: Imbalance handling...")
X_train_balanced, y_train_balanced = imbalance_handler.fit_resample(
    X_train_reduced, y_train
)
print(f"After resampling: {X_train_balanced.shape}")
print(f"New class distribution: {pd.Series(y_train_balanced).value_counts().to_dict()}")

print("Step 5: Training model...")
model.fit(X_train_balanced, y_train_balanced)

# Evaluate
y_pred = model.predict(X_test_reduced)
y_proba = model.predict_proba(X_test_reduced)[:, 1]

print("\n" + "="*60)
print("Model Performance")
print("="*60)

print("\nClassification Report:")
print(classification_report(y_test, y_pred))

print(f"\nROC-AUC Score: {roc_auc_score(y_test, y_proba):.4f}")

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, y_pred))

# Compare with baseline (no feature engineering)
print("\n" + "="*60)
print("Baseline (No Feature Engineering)")
print("="*60)

# Simple preprocessing + model
X_train_base = preprocessor.fit_transform(X_train)
X_test_base = preprocessor.transform(X_test)

# Handle categoricals with one-hot
X_train_base = pd.get_dummies(X_train_base, drop_first=True)
X_test_base = pd.get_dummies(X_test_base, drop_first=True)

# Align columns
common_cols = set(X_train_base.columns) & set(X_test_base.columns)
X_train_base = X_train_base[list(common_cols)]
X_test_base = X_test_base[list(common_cols)]

model_base = RandomForestClassifier(n_estimators=100, random_state=42)
model_base.fit(X_train_base, y_train)
y_pred_base = model_base.predict(X_test_base)
y_proba_base = model_base.predict_proba(X_test_base)[:, 1]

print(f"Baseline ROC-AUC: {roc_auc_score(y_test, y_proba_base):.4f}")
print(f"Baseline Classification Report:")
print(classification_report(y_test, y_pred_base))

print("\n" + "="*60)
print("Improvement Summary")
print("="*60)
improvement = (roc_auc_score(y_test, y_proba) - roc_auc_score(y_test, y_proba_base))
print(f"ROC-AUC Improvement: {improvement:.4f}")

# Save processed data
X_train_balanced.to_csv('data/processed/X_train_balanced.csv', index=False)
pd.Series(y_train_balanced).to_csv('data/processed/y_train_balanced.csv', index=False)

print("\n✅ Full integration test complete!")
EOF

python test_full_integration.py
```

### What Just Happened: Understanding Dimensionality Reduction and Imbalance

#### Dimensionality Reduction Methods

**PCA (Principal Component Analysis)**
- **How it works**: Finds directions of maximum variance in the data
- **When to use**: Linear structure, want to reduce features while preserving variance
- **Pros**: Fast, interpretable, works well when features are correlated
- **Cons**: Assumes linear relationships, loses interpretability of original features

**LDA (Linear Discriminant Analysis)**
- **How it works**: Finds directions that maximize class separation
- **When to use**: Classification problems with labeled data
- **Pros**: Supervised, maximizes class separation
- **Cons**: Requires labeled data, limited to n_classes-1 components

**t-SNE (t-Distributed Stochastic Neighbor Embedding)**
- **How it works**: Preserves local structure by modeling pairwise distances
- **When to use**: Visualization (2D or 3D), exploring clusters
- **Pros**: Excellent for visualization, preserves local structure
- **Cons**: Computationally expensive, non-deterministic, doesn't preserve global structure

**UMAP (Uniform Manifold Approximation and Projection)**
- **How it works**: Finds a low-dimensional representation that preserves manifold structure
- **When to use**: Visualization, clustering, feature reduction
- **Pros**: Faster than t-SNE, better preserves global structure
- **Cons**: Newer method, less proven in some applications

#### Imbalance Handling Strategies

**Over-sampling (SMOTE, ADASYN)**
- **How it works**: Creates synthetic samples of minority class
- **When to use**: Moderate imbalance, sufficient data for minority class
- **Pros**: No data loss, can create many synthetic samples
- **Cons**: Can create unrealistic samples, may cause overfitting

**Under-sampling**
- **How it works**: Removes samples from majority class
- **When to use**: Very large dataset, simple models
- **Pros**: Simple, faster training
- **Cons**: Loses potentially useful information

**Hybrid Methods (SMOTE-ENN, SMOTE-Tomek)**
- **How it works**: Combine over-sampling with cleaning
- **When to use**: When you want to create samples AND clean noisy data
- **Pros**: Better quality samples, removes borderline samples
- **Cons**: More computationally expensive

**Cost-Sensitive Learning**
- **How it works**: Penalizes misclassification of minority class more
- **When to use**: When you can't resample (e.g., small dataset)
- **Pros**: No data modification, works with any model
- **Cons**: Requires model support for class weights

**Balanced Ensembles**
- **How it works**: Builds ensemble where each tree is trained on a balanced subset
- **When to use**: When you want robust performance on imbalanced data
- **Pros**: Reduces overfitting, often outperforms resampling alone
- **Cons**: Computationally expensive

### Summary

In this final part of Module 4.1, we've built:

1. **Dimensionality reduction** with PCA, LDA, t-SNE, and UMAP
2. **Automatic dimension selection** through cross-validation
3. **Imbalance handling** with SMOTE, ADASYN, and hybrid methods
4. **Cost-sensitive learning** for models that support class weights
5. **Balanced ensembles** for robust performance
6. **Visualization** of reduced dimensions and class distributions
7. **Full integration** with our preprocessing pipeline

### What's Next

We've completed Module 4.1: Feature Prep & Engineering. The next module (4.2) will cover Supervised and Unsupervised Learning, where we'll implement core algorithms including tree-based ensembles, gradient boosting, clustering, and deep learning fundamentals.
