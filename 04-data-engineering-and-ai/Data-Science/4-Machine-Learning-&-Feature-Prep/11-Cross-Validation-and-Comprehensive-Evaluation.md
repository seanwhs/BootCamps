# Module 4.3: Model Validation & Hyperparameter Tuning

## Part 11: Cross-Validation and Comprehensive Evaluation

Welcome to Module 4.3! We've built powerful models across the machine learning spectrum—from tree-based ensembles to neural networks. Now we tackle the critical question: **How do we know our models will work in the real world?** This is where rigorous validation and evaluation come in.

### The Target: A Complete Validation and Evaluation System

By the end of this part, you'll have:
1. Multiple cross-validation strategies (K-Fold, Stratified, GroupKFold, TimeSeriesSplit)
2. Comprehensive classification metrics (Precision, Recall, F1, ROC-AUC, PR-AUC)
3. Comprehensive regression metrics (MAE, RMSE, MAPE, R²)
4. Confusion matrix visualization
5. Learning curves and validation curves
6. Unified evaluation framework
7. Integration with our modeling pipeline

### The Concept: Why Validation Matters

Think of validation like test-driving a car before buying it:

**Train/Test Split**: Like taking one test drive on a sunny day. Good, but limited.

**K-Fold Cross-Validation**: Like test-driving the car on 5 different days in different conditions. Much more reliable.

**Stratified K-Fold**: Like making sure each test drive includes the same mix of highway and city driving as the real world.

**TimeSeriesSplit**: Like test-driving over time to see how the car performs as it ages.

**The Goal**: Estimate how well your model will perform on new, unseen data. Without proper validation, you're driving blind.

### The Implementation: Building Our Validation System

#### Step 1: Cross-Validation Strategies

**File:** `src/validation/cross_validation.py`
**Path:** `ml-pipeline-project/src/validation/cross_validation.py`

```python
"""
Advanced cross-validation strategies for robust model evaluation.

This module implements:
- K-Fold Cross-Validation
- Stratified K-Fold (for classification)
- Group K-Fold (for grouped data)
- Time Series Split (for temporal data)
- Leave-One-Out Cross-Validation
- Custom cross-validation utilities
"""

from typing import Dict, List, Optional, Union, Any, Tuple, Callable
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.model_selection import (
    KFold, StratifiedKFold, GroupKFold, TimeSeriesSplit,
    LeaveOneOut, ShuffleSplit, StratifiedShuffleSplit,
    cross_val_score, cross_validate, cross_val_predict
)
from sklearn.base import BaseEstimator
from sklearn.metrics import make_scorer
from sklearn.preprocessing import LabelEncoder
import warnings

warnings.filterwarnings("ignore", category=UserWarning)

class CrossValidator:
    """
    Unified interface for cross-validation strategies.
    
    This class provides a consistent API for different CV strategies
    with automatic selection based on data characteristics.
    
    Example:
        >>> cv = CrossValidator(
        ...     method='stratified_kfold',
        ...     n_splits=5,
        ...     shuffle=True
        ... )
        >>> results = cv.validate(model, X, y)
    """
    
    # Available CV methods
    METHODS = {
        'kfold': KFold,
        'stratified_kfold': StratifiedKFold,
        'group_kfold': GroupKFold,
        'timeseries': TimeSeriesSplit,
        'leave_one_out': LeaveOneOut,
        'shuffle': ShuffleSplit,
        'stratified_shuffle': StratifiedShuffleSplit
    }
    
    def __init__(
        self,
        method: str = 'stratified_kfold',
        n_splits: int = 5,
        shuffle: bool = True,
        random_state: int = 42,
        **kwargs
    ):
        """
        Initialize the cross-validator.
        
        Args:
            method: CV method name
            n_splits: Number of folds
            shuffle: Whether to shuffle data
            random_state: Random seed
            **kwargs: Additional method-specific arguments
        """
        self.method = method
        self.n_splits = n_splits
        self.shuffle = shuffle
        self.random_state = random_state
        self.kwargs = kwargs
        
        self._cv = None
        self._selected_method = None
        
        logger.info(f"CrossValidator initialized with method={method}")
    
    def get_splits(
        self,
        X: Union[pd.DataFrame, np.ndarray],
        y: Optional[Union[pd.Series, np.ndarray]] = None,
        groups: Optional[Union[pd.Series, np.ndarray]] = None
    ) -> List[Tuple[np.ndarray, np.ndarray]]:
        """
        Get train/test indices for each fold.
        
        Args:
            X: Feature matrix
            y: Target vector (required for stratified methods)
            groups: Group labels (required for group methods)
            
        Returns:
            List: List of (train_indices, test_indices) tuples
        """
        # Auto-select method if not specified
        if self.method == 'auto':
            self._selected_method = self._select_method(X, y, groups)
        else:
            self._selected_method = self.method
        
        # Create CV object
        self._cv = self._create_cv(X, y, groups)
        
        # Get splits
        if self._selected_method in ['stratified_kfold', 'stratified_shuffle']:
            if y is None:
                raise ValueError(f"{self._selected_method} requires target (y)")
            splits = list(self._cv.split(X, y))
        elif self._selected_method in ['group_kfold']:
            if groups is None:
                raise ValueError("GroupKFold requires groups")
            splits = list(self._cv.split(X, groups=groups))
        else:
            splits = list(self._cv.split(X))
        
        logger.info(f"Generated {len(splits)} splits using {self._selected_method}")
        return splits
    
    def validate(
        self,
        model: BaseEstimator,
        X: Union[pd.DataFrame, np.ndarray],
        y: Union[pd.Series, np.ndarray],
        scoring: Optional[Union[str, Callable]] = None,
        groups: Optional[Union[pd.Series, np.ndarray]] = None,
        return_predictions: bool = False
    ) -> Dict[str, Any]:
        """
        Perform cross-validation on a model.
        
        Args:
            model: Scikit-learn compatible model
            X: Feature matrix
            y: Target vector
            scoring: Scoring metric or callable
            groups: Group labels (for group methods)
            return_predictions: Whether to return predictions
            
        Returns:
            Dict: Cross-validation results
        """
        # Auto-select method
        if self.method == 'auto':
            self._selected_method = self._select_method(X, y, groups)
        else:
            self._selected_method = self.method
        
        # Create CV object
        self._cv = self._create_cv(X, y, groups)
        
        # Determine scoring
        if scoring is None:
            # Use default scoring based on problem type
            if len(np.unique(y)) <= 2:
                scoring = 'accuracy'
            else:
                scoring = 'neg_mean_squared_error'
        
        # Perform cross-validation
        logger.info(f"Performing {self._selected_method} CV with {self.n_splits} folds")
        
        # Get train/test splits
        if self._selected_method in ['stratified_kfold', 'stratified_shuffle']:
            splits = list(self._cv.split(X, y))
        elif self._selected_method in ['group_kfold']:
            if groups is None:
                raise ValueError("GroupKFold requires groups")
            splits = list(self._cv.split(X, groups=groups))
        else:
            splits = list(self._cv.split(X))
        
        # Validate each fold
        fold_results = []
        predictions = []
        true_values = []
        
        for fold, (train_idx, test_idx) in enumerate(splits):
            X_train = X.iloc[train_idx] if isinstance(X, pd.DataFrame) else X[train_idx]
            X_test = X.iloc[test_idx] if isinstance(X, pd.DataFrame) else X[test_idx]
            y_train = y.iloc[train_idx] if isinstance(y, pd.Series) else y[train_idx]
            y_test = y.iloc[test_idx] if isinstance(y, pd.Series) else y[test_idx]
            
            # Train model
            model_copy = model.__class__(**model.get_params())
            model_copy.fit(X_train, y_train)
            
            # Make predictions
            y_pred = model_copy.predict(X_test)
            predictions.extend(y_pred)
            true_values.extend(y_test)
            
            # Calculate score
            if callable(scoring):
                score = scoring(y_test, y_pred)
            else:
                score = self._calculate_score(y_test, y_pred, scoring)
            
            fold_results.append({
                'fold': fold,
                'train_size': len(train_idx),
                'test_size': len(test_idx),
                'score': score
            })
        
        # Compile results
        results = {
            'method': self._selected_method,
            'n_splits': self.n_splits,
            'scores': [r['score'] for r in fold_results],
            'mean_score': np.mean([r['score'] for r in fold_results]),
            'std_score': np.std([r['score'] for r in fold_results]),
            'fold_details': fold_results
        }
        
        if return_predictions:
            results['predictions'] = np.array(predictions)
            results['true_values'] = np.array(true_values)
        
        logger.info(f"CV complete. Mean score: {results['mean_score']:.4f} (+/- {results['std_score']:.4f})")
        
        return results
    
    def _create_cv(self, X, y, groups):
        """Create the appropriate CV object."""
        # Auto-select method
        if self.method == 'auto':
            method = self._selected_method
        else:
            method = self.method
        
        # Adjust n_splits for LeaveOneOut
        if method == 'leave_one_out':
            self.n_splits = len(X)
        
        # Create CV object
        if method == 'kfold':
            return KFold(
                n_splits=self.n_splits,
                shuffle=self.shuffle,
                random_state=self.random_state,
                **self.kwargs
            )
        elif method == 'stratified_kfold':
            return StratifiedKFold(
                n_splits=self.n_splits,
                shuffle=self.shuffle,
                random_state=self.random_state,
                **self.kwargs
            )
        elif method == 'group_kfold':
            return GroupKFold(
                n_splits=self.n_splits,
                **self.kwargs
            )
        elif method == 'timeseries':
            return TimeSeriesSplit(
                n_splits=self.n_splits,
                **self.kwargs
            )
        elif method == 'leave_one_out':
            return LeaveOneOut(**self.kwargs)
        elif method == 'shuffle':
            return ShuffleSplit(
                n_splits=self.n_splits,
                test_size=self.kwargs.get('test_size', 0.2),
                random_state=self.random_state,
                **self.kwargs
            )
        elif method == 'stratified_shuffle':
            return StratifiedShuffleSplit(
                n_splits=self.n_splits,
                test_size=self.kwargs.get('test_size', 0.2),
                random_state=self.random_state,
                **self.kwargs
            )
        else:
            raise ValueError(f"Unknown method: {method}")
    
    def _select_method(self, X, y, groups):
        """Automatically select the best CV method."""
        n_samples = len(X)
        n_classes = len(np.unique(y)) if y is not None else 0
        
        # If groups provided, use GroupKFold
        if groups is not None:
            return 'group_kfold'
        
        # If classification with categorical target, use StratifiedKFold
        if y is not None and n_classes <= 10:
            return 'stratified_kfold'
        
        # If temporal data (time-based index), use TimeSeriesSplit
        if isinstance(X, pd.DataFrame) and isinstance(X.index, pd.DatetimeIndex):
            return 'timeseries'
        
        # If small dataset, use LeaveOneOut
        if n_samples <= 50:
            return 'leave_one_out'
        
        # Default to KFold
        return 'kfold'
    
    def _calculate_score(self, y_true, y_pred, scoring):
        """Calculate score based on scoring string."""
        metrics = {
            'accuracy': lambda y, p: np.mean(y == p),
            'precision': lambda y, p: precision_score(y, p, average='weighted', zero_division=0),
            'recall': lambda y, p: recall_score(y, p, average='weighted', zero_division=0),
            'f1': lambda y, p: f1_score(y, p, average='weighted', zero_division=0),
            'roc_auc': lambda y, p: roc_auc_score(y, p),
            'mse': lambda y, p: mean_squared_error(y, p),
            'rmse': lambda y, p: np.sqrt(mean_squared_error(y, p)),
            'mae': lambda y, p: mean_absolute_error(y, p),
            'r2': lambda y, p: r2_score(y, p),
            'neg_mean_squared_error': lambda y, p: -mean_squared_error(y, p),
            'neg_mean_absolute_error': lambda y, p: -mean_absolute_error(y, p),
        }
        
        if scoring in metrics:
            return metrics[scoring](y_true, y_pred)
        else:
            # Try to import from sklearn
            from sklearn.metrics import get_scorer
            try:
                scorer = get_scorer(scoring)
                return scorer(None, y_true, y_pred)
            except:
                raise ValueError(f"Unknown scoring metric: {scoring}")
    
    def plot_cv(self, X, y=None, groups=None, figsize=(10, 6)):
        """
        Visualize the cross-validation splits.
        
        Args:
            X: Feature matrix
            y: Target vector
            groups: Group labels
            figsize: Figure size
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        import matplotlib.pyplot as plt
        from matplotlib.patches import Patch
        
        # Get splits
        splits = self.get_splits(X, y, groups)
        n_splits = len(splits)
        
        fig, ax = plt.subplots(figsize=figsize)
        
        # Create colormap
        colors = plt.cm.viridis(np.linspace(0, 1, n_splits))
        
        # Plot each split
        for fold, (train_idx, test_idx) in enumerate(splits):
            y_pos = -fold - 1
            
            # Training set
            ax.scatter(
                train_idx,
                np.full_like(train_idx, y_pos),
                c=[colors[fold]],
                marker='s',
                s=10,
                alpha=0.6,
                label=f'Fold {fold+1} Train' if fold == 0 else ""
            )
            
            # Test set
            ax.scatter(
                test_idx,
                np.full_like(test_idx, y_pos),
                c=['red'],
                marker='s',
                s=10,
                alpha=0.6,
                label=f'Fold {fold+1} Test' if fold == 0 else ""
            )
        
        ax.set_xlabel('Sample Index')
        ax.set_ylabel('Fold')
        ax.set_title(f'Cross-Validation Splits ({self.method})')
        ax.set_yticks([-i-1 for i in range(n_splits)])
        ax.set_yticklabels([f'Fold {i+1}' for i in range(n_splits)])
        ax.invert_yaxis()
        
        # Legend
        legend_elements = [
            Patch(facecolor=colors[0], alpha=0.6, label='Training'),
            Patch(facecolor='red', alpha=0.6, label='Test')
        ]
        ax.legend(handles=legend_elements)
        
        plt.tight_layout()
        return fig
```

#### Step 2: Comprehensive Evaluation Metrics

**File:** `src/validation/metrics.py`
**Path:** `ml-pipeline-project/src/validation/metrics.py`

```python
"""
Comprehensive evaluation metrics for classification and regression.

This module implements:
- Classification: Accuracy, Precision, Recall, F1, ROC-AUC, PR-AUC
- Regression: MAE, RMSE, MAPE, R², Explained Variance
- Custom metrics for specific use cases
"""

from typing import Dict, List, Optional, Union, Any, Tuple
import numpy as np
import pandas as pd
from loguru import logger
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, average_precision_score, confusion_matrix,
    mean_squared_error, mean_absolute_error, r2_score,
    explained_variance_score, mean_absolute_percentage_error
)
from sklearn.preprocessing import label_binarize
import warnings

warnings.filterwarnings("ignore", category=UserWarning)

class MetricsCalculator:
    """
    Comprehensive metrics calculator for classification and regression.
    
    Provides a unified interface for computing and reporting metrics.
    
    Example:
        >>> calc = MetricsCalculator()
        >>> results = calc.compute_metrics(y_true, y_pred)
        >>> calc.print_report(results)
    """
    
    # Classification metrics
    CLASSIFICATION_METRICS = {
        'accuracy': accuracy_score,
        'precision': lambda y, p: precision_score(y, p, average='weighted', zero_division=0),
        'recall': lambda y, p: recall_score(y, p, average='weighted', zero_division=0),
        'f1': lambda y, p: f1_score(y, p, average='weighted', zero_division=0),
        'roc_auc': roc_auc_score,
        'average_precision': average_precision_score
    }
    
    # Regression metrics
    REGRESSION_METRICS = {
        'mse': mean_squared_error,
        'rmse': lambda y, p: np.sqrt(mean_squared_error(y, p)),
        'mae': mean_absolute_error,
        'mape': mean_absolute_percentage_error,
        'r2': r2_score,
        'explained_variance': explained_variance_score
    }
    
    def __init__(self, task: str = 'classification'):
        """
        Initialize the metrics calculator.
        
        Args:
            task: Task type ('classification' or 'regression')
        """
        self.task = task
        logger.info(f"MetricsCalculator initialized for {task}")
    
    def compute_metrics(
        self,
        y_true: Union[np.ndarray, pd.Series],
        y_pred: Union[np.ndarray, pd.Series],
        y_proba: Optional[Union[np.ndarray, pd.Series]] = None,
        metrics: Optional[List[str]] = None
    ) -> Dict[str, float]:
        """
        Compute evaluation metrics.
        
        Args:
            y_true: True target values
            y_pred: Predicted target values
            y_proba: Predicted probabilities (for ROC-AUC, PR-AUC)
            metrics: List of metrics to compute (None for all)
            
        Returns:
            Dict: Metric to value mapping
        """
        # Convert to numpy arrays
        y_true = np.array(y_true)
        y_pred = np.array(y_pred)
        
        results = {}
        
        # Determine problem type
        n_classes = len(np.unique(y_true))
        is_binary = n_classes == 2
        
        if self.task == 'classification':
            # Classification metrics
            if metrics is None:
                metrics = list(self.CLASSIFICATION_METRICS.keys())
            
            for metric in metrics:
                if metric in self.CLASSIFICATION_METRICS:
                    try:
                        if metric == 'roc_auc' and y_proba is not None:
                            # ROC-AUC requires probabilities
                            if is_binary:
                                score = roc_auc_score(y_true, y_proba)
                            else:
                                # Multi-class: one-vs-rest
                                y_bin = label_binarize(y_true, classes=np.unique(y_true))
                                score = roc_auc_score(y_bin, y_proba, average='weighted', multi_class='ovr')
                            results[metric] = score
                        elif metric == 'average_precision' and y_proba is not None:
                            # PR-AUC requires probabilities
                            if is_binary:
                                score = average_precision_score(y_true, y_proba)
                            else:
                                # Multi-class: one-vs-rest
                                y_bin = label_binarize(y_true, classes=np.unique(y_true))
                                score = average_precision_score(y_bin, y_proba, average='weighted')
                            results[metric] = score
                        else:
                            score = self.CLASSIFICATION_METRICS[metric](y_true, y_pred)
                            results[metric] = score
                    except Exception as e:
                        logger.warning(f"Metric {metric} failed: {str(e)}")
                        results[metric] = np.nan
        
        else:
            # Regression metrics
            if metrics is None:
                metrics = list(self.REGRESSION_METRICS.keys())
            
            for metric in metrics:
                if metric in self.REGRESSION_METRICS:
                    try:
                        score = self.REGRESSION_METRICS[metric](y_true, y_pred)
                        results[metric] = score
                    except Exception as e:
                        logger.warning(f"Metric {metric} failed: {str(e)}")
                        results[metric] = np.nan
        
        return results
    
    def confusion_matrix_summary(
        self,
        y_true: Union[np.ndarray, pd.Series],
        y_pred: Union[np.ndarray, pd.Series],
        labels: Optional[List[Any]] = None
    ) -> Dict[str, Any]:
        """
        Compute confusion matrix and derived metrics.
        
        Args:
            y_true: True target values
            y_pred: Predicted target values
            labels: List of label names
            
        Returns:
            Dict: Confusion matrix summary
        """
        # Convert to numpy arrays
        y_true = np.array(y_true)
        y_pred = np.array(y_pred)
        
        # Compute confusion matrix
        cm = confusion_matrix(y_true, y_pred)
        
        # Get unique labels
        if labels is None:
            labels = np.unique(np.concatenate([y_true, y_pred]))
        
        summary = {
            'matrix': cm,
            'labels': labels,
            'n_classes': len(labels),
            'class_counts': {str(label): int(np.sum(y_true == label)) for label in labels}
        }
        
        # If binary classification, compute additional metrics
        if len(labels) == 2:
            tn, fp, fn, tp = cm.ravel()
            summary.update({
                'true_negatives': int(tn),
                'false_positives': int(fp),
                'false_negatives': int(fn),
                'true_positives': int(tp),
                'specificity': tn / (tn + fp) if (tn + fp) > 0 else 0,
                'sensitivity': tp / (tp + fn) if (tp + fn) > 0 else 0,
                'positive_predictive_value': tp / (tp + fp) if (tp + fp) > 0 else 0,
                'negative_predictive_value': tn / (tn + fn) if (tn + fn) > 0 else 0,
                'false_positive_rate': fp / (fp + tn) if (fp + tn) > 0 else 0,
                'false_negative_rate': fn / (fn + tp) if (fn + tp) > 0 else 0
            })
        
        return summary
    
    def print_report(self, metrics: Dict[str, float], title: str = "Evaluation Results"):
        """
        Print a formatted report of metrics.
        
        Args:
            metrics: Metric dictionary
            title: Report title
        """
        print("\n" + "="*60)
        print(title)
        print("="*60)
        
        for name, value in metrics.items():
            if not np.isnan(value):
                print(f"  {name.upper():20s}: {value:.4f}")
            else:
                print(f"  {name.upper():20s}: N/A")
        
        print("="*60 + "\n")
    
    def get_best_metric(self, metrics: Dict[str, float]) -> Tuple[str, float]:
        """
        Get the best performing metric (for higher-is-better metrics).
        
        Args:
            metrics: Metric dictionary
            
        Returns:
            Tuple: (metric_name, value)
        """
        # Metrics where higher is better
        higher_better = ['accuracy', 'precision', 'recall', 'f1', 'roc_auc', 
                        'average_precision', 'r2', 'explained_variance']
        
        # Metrics where lower is better
        lower_better = ['mse', 'rmse', 'mae', 'mape']
        
        best_name = None
        best_value = None
        
        for name, value in metrics.items():
            if np.isnan(value):
                continue
            
            if best_value is None:
                best_name = name
                best_value = value
                continue
            
            if name in higher_better and value > best_value:
                best_name = name
                best_value = value
            elif name in lower_better and value < best_value:
                best_name = name
                best_value = value
        
        return best_name, best_value
    
    def plot_confusion_matrix(
        self,
        y_true: Union[np.ndarray, pd.Series],
        y_pred: Union[np.ndarray, pd.Series],
        labels: Optional[List[Any]] = None,
        normalize: bool = False,
        figsize: Tuple[int, int] = (8, 6),
        save_path: Optional[str] = None
    ):
        """
        Plot a confusion matrix.
        
        Args:
            y_true: True target values
            y_pred: Predicted target values
            labels: List of label names
            normalize: Whether to normalize the matrix
            figsize: Figure size
            save_path: Path to save the figure
            
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        import matplotlib.pyplot as plt
        import seaborn as sns
        
        # Compute confusion matrix
        cm = confusion_matrix(y_true, y_pred)
        
        if normalize:
            cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
            fmt = '.2f'
        else:
            fmt = 'd'
        
        # Get labels
        if labels is None:
            labels = np.unique(np.concatenate([y_true, y_pred]))
        
        # Create plot
        fig, ax = plt.subplots(figsize=figsize)
        sns.heatmap(
            cm,
            annot=True,
            fmt=fmt,
            xticklabels=labels,
            yticklabels=labels,
            cmap='Blues',
            ax=ax,
            cbar=True
        )
        
        ax.set_xlabel('Predicted')
        ax.set_ylabel('Actual')
        title = 'Confusion Matrix' + (' (Normalized)' if normalize else '')
        ax.set_title(title)
        
        plt.tight_layout()
        
        if save_path:
            fig.savefig(save_path, dpi=100, bbox_inches='tight')
            logger.info(f"Confusion matrix saved to: {save_path}")
        
        return fig
```

### The Verification: Testing Our Validation System

#### Test 1: Cross-Validation Strategies

```bash
cat > test_cross_validation.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.ensemble import RandomForestClassifier
from src.validation.cross_validation import CrossValidator

# Create dataset
X, y = make_classification(
    n_samples=500,
    n_features=20,
    n_informative=10,
    n_redundant=5,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])

print(f"Data shape: {X.shape}")
print(f"Class distribution: {pd.Series(y).value_counts().to_dict()}")

# Test different CV methods
print("\n" + "="*60)
print("Cross-Validation Methods Comparison")
print("="*60)

model = RandomForestClassifier(n_estimators=50, random_state=42)
methods = ['kfold', 'stratified_kfold', 'shuffle']

for method in methods:
    print(f"\n{method.upper()}:")
    cv = CrossValidator(method=method, n_splits=5, shuffle=True, random_state=42)
    
    try:
        results = cv.validate(model, X, y, scoring='accuracy')
        print(f"  Mean Accuracy: {results['mean_score']:.4f} (+/- {results['std_score']:.4f})")
        print(f"  Individual scores: {[f'{s:.4f}' for s in results['scores']]}")
    except Exception as e:
        print(f"  Error: {str(e)}")

# Test auto-selection
print("\n" + "="*60)
print("Auto-Selection")
print("="*60)

cv = CrossValidator(method='auto', n_splits=5)
results = cv.validate(model, X, y, scoring='accuracy')
print(f"Selected method: {results['method']}")
print(f"Mean Accuracy: {results['mean_score']:.4f} (+/- {results['std_score']:.4f})")

# Visualize CV splits
print("\n" + "="*60)
print("Visualizing CV Splits")
print("="*60)

cv = CrossValidator(method='stratified_kfold', n_splits=5)
fig = cv.plot_cv(X, y)
fig.savefig('reports/figures/cv_splits.png', dpi=100, bbox_inches='tight')
print("CV splits plot saved to: reports/figures/cv_splits.png")

print("\n✅ Cross-validation test complete!")
EOF

python test_cross_validation.py
```

#### Test 2: Comprehensive Metrics

```bash
cat > test_metrics.py << 'EOF'
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification, make_regression
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from src.validation.metrics import MetricsCalculator

# Classification test
print("="*60)
print("Classification Metrics")
print("="*60)

X, y = make_classification(
    n_samples=500,
    n_features=10,
    n_informative=5,
    n_classes=2,
    random_state=42
)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = RandomForestClassifier(n_estimators=50, random_state=42)
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)[:, 1]

calc = MetricsCalculator(task='classification')
metrics = calc.compute_metrics(y_test, y_pred, y_proba)
calc.print_report(metrics, "Classification Results")

# Confusion matrix
cm_summary = calc.confusion_matrix_summary(y_test, y_pred)
print("Confusion Matrix Summary:")
print(f"  True Positives: {cm_summary.get('true_positives', 'N/A')}")
print(f"  False Positives: {cm_summary.get('false_positives', 'N/A')}")
print(f"  True Negatives: {cm_summary.get('true_negatives', 'N/A')}")
print(f"  False Negatives: {cm_summary.get('false_negatives', 'N/A')}")

# Plot confusion matrix
fig = calc.plot_confusion_matrix(y_test, y_pred, normalize=False)
fig.savefig('reports/figures/confusion_matrix.png', dpi=100, bbox_inches='tight')
print("Confusion matrix saved to: reports/figures/confusion_matrix.png")

# Regression test
print("\n" + "="*60)
print("Regression Metrics")
print("="*60)

X, y = make_regression(
    n_samples=500,
    n_features=10,
    n_informative=5,
    noise=0.1,
    random_state=42
)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

regressor = RandomForestRegressor(n_estimators=50, random_state=42)
regressor.fit(X_train, y_train)
y_pred = regressor.predict(X_test)

calc_reg = MetricsCalculator(task='regression')
metrics_reg = calc_reg.compute_metrics(y_test, y_pred)
calc_reg.print_report(metrics_reg, "Regression Results")

# Get best metric
best_metric, best_value = calc_reg.get_best_metric(metrics_reg)
print(f"Best Metric: {best_metric.upper()} = {best_value:.4f}")

print("\n✅ Metrics test complete!")
EOF

python test_metrics.py
```

#### Test 3: Full Validation Pipeline

```bash
cat > test_validation_pipeline.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from src.validation.cross_validation import CrossValidator
from src.validation.metrics import MetricsCalculator
from src.preprocessing.pipeline import DataPreprocessor
from src.features.encoding import CategoricalEncoder

# Create dataset with preprocessing needs
X, y = make_classification(
    n_samples=800,
    n_features=15,
    n_informative=8,
    n_redundant=3,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])
X['category'] = np.random.choice(['A', 'B', 'C', 'D', 'E'], len(X))
X['region'] = np.random.choice(['North', 'South', 'East', 'West'], len(X))

# Introduce missing values
X.loc[np.random.choice(len(X), 50, replace=False), 'feature_0'] = np.nan
X.loc[np.random.choice(len(X), 30, replace=False), 'feature_1'] = np.nan

print(f"Data shape: {X.shape}")
print(f"Class distribution: {pd.Series(y).value_counts().to_dict()}")
print(f"Missing values: {X.isnull().sum().sum()}")

# Create preprocessing pipeline
preprocessor = DataPreprocessor(
    numeric_imputation='median',
    categorical_imputation='mode',
    scaling_strategy='standard',
    exclude_columns=['category', 'region']
)

encoder = CategoricalEncoder(strategy='auto', columns=['category', 'region'])

# Create model
model = RandomForestClassifier(n_estimators=50, random_state=42)

# Build full pipeline
from sklearn.pipeline import Pipeline
pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('encoder', encoder),
    ('model', model)
])

# Cross-validate
print("\n" + "="*60)
print("Full Pipeline Cross-Validation")
print("="*60)

cv = CrossValidator(method='stratified_kfold', n_splits=5, shuffle=True, random_state=42)
results = cv.validate(pipeline, X, y, scoring='accuracy')

print(f"CV Method: {results['method']}")
print(f"Mean Accuracy: {results['mean_score']:.4f} (+/- {results['std_score']:.4f})")
print(f"Individual scores: {[f'{s:.4f}' for s in results['scores']]}")

# Train on full data and evaluate
print("\n" + "="*60)
print("Full Training and Evaluation")
print("="*60)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

pipeline.fit(X_train, y_train)
y_pred = pipeline.predict(X_test)
y_proba = pipeline.predict_proba(X_test)[:, 1]

calc = MetricsCalculator(task='classification')
metrics = calc.compute_metrics(y_test, y_pred, y_proba)
calc.print_report(metrics, "Test Set Evaluation")

# Plot confusion matrix
fig = calc.plot_confusion_matrix(y_test, y_pred)
fig.savefig('reports/figures/full_pipeline_confusion_matrix.png', dpi=100, bbox_inches='tight')

print("\n✅ Full validation pipeline test complete!")
EOF

python test_validation_pipeline.py
```

### What Just Happened: Understanding Validation

#### Cross-Validation Methods

**K-Fold Cross-Validation**
- Splits data into K equal parts
- Trains on K-1 parts, tests on 1 part
- Repeats K times with different test parts
- **Best for**: General ML problems
- **Pros**: Efficient use of data, reduces variance
- **Cons**: Can be biased for imbalanced data

**Stratified K-Fold**
- Maintains class proportions in each fold
- **Best for**: Classification with imbalanced classes
- **Pros**: Preserves class distribution
- **Cons**: Requires categorical target

**Group K-Fold**
- Ensures groups are not split across folds
- **Best for**: Data with natural groups (patients, locations)
- **Pros**: Prevents data leakage
- **Cons**: Requires group labels

**Time Series Split**
- Uses earlier data for training, later for testing
- **Best for**: Temporal data
- **Pros**: Preserves temporal order
- **Cons**: Can't use future data to predict past

#### Evaluation Metrics

**Classification Metrics**

| Metric | Formula | Best For | Range |
|--------|---------|----------|-------|
| Accuracy | (TP+TN)/(TP+TN+FP+FN) | Balanced classes | 0-1 |
| Precision | TP/(TP+FP) | Minimize false positives | 0-1 |
| Recall | TP/(TP+FN) | Minimize false negatives | 0-1 |
| F1 | 2*(P*R)/(P+R) | Balance P and R | 0-1 |
| ROC-AUC | Area under ROC curve | Overall performance | 0-1 |
| PR-AUC | Area under PR curve | Imbalanced classes | 0-1 |

**Regression Metrics**

| Metric | Formula | Best For | Range |
|--------|---------|----------|-------|
| MSE | Σ(y-ŷ)²/n | Large errors penalized | [0,∞) |
| RMSE | √MSE | Interpretable | [0,∞) |
| MAE | Σ|y-ŷ|/n | Robust to outliers | [0,∞) |
| MAPE | Σ|(y-ŷ)/y|/n | Relative error | [0,∞) |
| R² | 1 - SS_res/SS_tot | Variance explained | (-∞,1] |

### Summary

In this part, we've built a comprehensive validation and evaluation system that:

1. **Implements multiple CV strategies** with automatic selection
2. **Computes comprehensive metrics** for classification and regression
3. **Visualizes** confusion matrices and CV splits
4. **Integrates** with our preprocessing and modeling pipeline
5. **Provides** formatted reports for easy interpretation
6. **Handles** binary, multi-class, and regression problems

### What's Next

In Part 12, we'll tackle hyperparameter optimization with Grid Search, Random Search, and Bayesian Optimization using Optuna.
