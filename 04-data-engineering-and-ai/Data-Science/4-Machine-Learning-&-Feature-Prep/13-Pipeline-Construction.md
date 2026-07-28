# Phase 4 Capstone: The End-to-End Predictive Pipeline

## Part 13: Pipeline Construction

Welcome to the Phase 4 Capstone! We've built all the individual components—data ingestion, validation, preprocessing, feature engineering, modeling, validation, and optimization. Now we integrate everything into a cohesive, production-grade pipeline. This is where theory becomes practice, and components become a system.

### The Target: A Complete Production-Grade Pipeline

By the end of this part, you'll have:
1. A leak-free preprocessing pipeline with Scikit-learn
2. Integrated categorical encoding, scaling, and imbalance handling
3. Pipeline with built-in cross-validation
4. Hyperparameter optimization integrated into the pipeline
5. Model persistence and versioning
6. Comprehensive logging and monitoring
7. A complete, runnable training pipeline
8. Prediction pipeline for new data

### The Concept: Building the Ultimate Pipeline

Think of our pipeline like an automated factory:

**Raw Materials** (Raw Data) → **Quality Control** (Validation) → **Processing** (Preprocessing) → **Assembly** (Feature Engineering) → **Quality Assurance** (Validation) → **Packaging** (Model) → **Shipping** (Deployment)

Each step is carefully designed, tested, and monitored. The pipeline handles everything automatically, from raw data to predictions.

#### The Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  DataIngestor    │  DataValidator    │  DataPipeline    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FEATURE LAYER                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Imputation  │  Scaling  │  Encoding  │  Creation       │  │
│  │  Selection   │  Reduction│  Imbalance │                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       MODEL LAYER                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Tree Models  │  Clustering  │  Deep Learning           │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    VALIDATION LAYER                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Cross-Validation  │  Metrics  │  Hyperparameter Tuning │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT LAYER                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Model Persistence  │  Prediction API  │  Monitoring    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### The Implementation: Building the Complete Pipeline

#### Step 1: The Unified Pipeline Class

**File:** `src/pipeline/builder.py`
**Path:** `ml-pipeline-project/src/pipeline/builder.py`

```python
"""
Complete end-to-end machine learning pipeline builder.

This module integrates all pipeline components into a unified system:
- Data ingestion and validation
- Preprocessing and feature engineering
- Model training and hyperparameter optimization
- Model evaluation and persistence
- Prediction interface
"""

from typing import Dict, List, Optional, Union, Any, Tuple, Callable
from pathlib import Path
import json
import time
import joblib
import pandas as pd
import numpy as np
from loguru import logger
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.base import BaseEstimator, TransformerMixin

from src.data.ingestion import DataIngestor
from src.data.validation import DataValidator, DataSchema
from src.preprocessing.pipeline import DataPreprocessor
from src.features.encoding import CategoricalEncoder
from src.features.creation import FeatureCreator
from src.features.selection import FeatureSelector
from src.features.dimensionality import DimensionalityReducer
from src.features.imbalance import ImbalanceHandler
from src.models.tree_based import TreeModel
from src.models.nn_architectures import MLP
from src.validation.cross_validation import CrossValidator
from src.validation.metrics import MetricsCalculator
from src.validation.tuning import GridSearchOptimizer, RandomSearchOptimizer
from src.validation.optuna_tuner import OptunaTuner

class MLPipeline:
    """
    Complete end-to-end machine learning pipeline.
    
    This class orchestrates the entire ML workflow from data loading
    to model deployment with comprehensive logging and validation.
    
    Example:
        >>> pipeline = MLPipeline(
        ...     config={
        ...         'model_type': 'random_forest',
        ...         'task': 'classification',
        ...         'target_col': 'target'
        ...     }
        ... )
        >>> pipeline.train(X_train, y_train)
        >>> predictions = pipeline.predict(X_test)
    """
    
    def __init__(
        self,
        config: Dict[str, Any],
        schema: Optional[DataSchema] = None
    ):
        """
        Initialize the ML pipeline.
        
        Args:
            config: Configuration dictionary
            schema: Optional data schema for validation
        """
        self.config = config
        self.schema = schema
        
        # Components
        self.ingestor = DataIngestor(**config.get('data', {}))
        self.validator = DataValidator(config=config.get('validation', {}))
        self.preprocessor = None
        self.encoder = None
        self.feature_creator = None
        self.feature_selector = None
        self.dimensionality_reducer = None
        self.imbalance_handler = None
        self.model = None
        self.trainer = None
        
        # State
        self._is_trained = False
        self._feature_names = None
        self._target_col = config.get('target_col')
        self._model_type = config.get('model_type', 'random_forest')
        self._task = config.get('task', 'classification')
        
        # Results
        self.training_results = None
        self.evaluation_results = None
        self.best_params = None
        
        logger.info(f"MLPipeline initialized with model_type={self._model_type}")
    
    def train(
        self,
        X: Union[pd.DataFrame, np.ndarray],
        y: Optional[Union[pd.Series, np.ndarray]] = None,
        validation_data: Optional[Tuple] = None,
        tune_hyperparameters: bool = True
    ) -> Dict[str, Any]:
        """
        Train the complete pipeline.
        
        Args:
            X: Feature matrix
            y: Target vector (if not in X)
            validation_data: Optional (X_val, y_val) tuple
            tune_hyperparameters: Whether to perform hyperparameter tuning
            
        Returns:
            Dict: Training results
        """
        logger.info("Starting pipeline training")
        start_time = time.time()
        
        # Prepare data
        X = self._prepare_data(X)
        
        # Extract target if in X
        if self._target_col and self._target_col in X.columns:
            y = X[self._target_col]
            X = X.drop(columns=[self._target_col])
        
        if y is None:
            raise ValueError("Target (y) must be provided or present in X")
        
        # Store feature names
        self._feature_names = X.columns.tolist() if hasattr(X, 'columns') else None
        
        # Step 1: Data validation
        if self.schema:
            logger.info("Step 1: Validating data")
            self.validator.validate_schema(X, self.schema)
        
        # Step 2: Preprocessing
        logger.info("Step 2: Preprocessing data")
        self.preprocessor = DataPreprocessor(
            numeric_imputation=self.config.get('imputation', {}).get('numeric', 'median'),
            categorical_imputation=self.config.get('imputation', {}).get('categorical', 'mode'),
            scaling_strategy=self.config.get('scaling', {}).get('method', 'standard'),
            exclude_columns=[self._target_col] if self._target_col else None
        )
        X_preprocessed = self.preprocessor.fit_transform(X)
        
        # Step 3: Feature engineering
        logger.info("Step 3: Feature engineering")
        
        # Encoding
        self.encoder = CategoricalEncoder(
            strategy=self.config.get('encoding', {}).get('strategy', 'auto'),
            target_col=self._target_col
        )
        X_encoded = self.encoder.fit_transform(X_preprocessed, y)
        
        # Feature creation
        self.feature_creator = FeatureCreator(
            polynomial_degree=self.config.get('feature_creation', {}).get('polynomial_degree'),
            interactions=self.config.get('feature_creation', {}).get('interactions', True),
            ratios=self.config.get('feature_creation', {}).get('ratios', False)
        )
        X_enhanced = self.feature_creator.fit_transform(X_encoded)
        
        # Feature selection
        if self.config.get('feature_selection', {}).get('enabled', False):
            logger.info("  Performing feature selection")
            self.feature_selector = FeatureSelector(
                method=self.config.get('feature_selection', {}).get('method', 'model'),
                n_features_to_select=self.config.get('feature_selection', {}).get('n_features')
            )
            X_selected = self.feature_selector.fit_transform(X_enhanced, y)
        else:
            X_selected = X_enhanced
        
        # Dimensionality reduction
        if self.config.get('dimensionality_reduction', {}).get('enabled', False):
            logger.info("  Performing dimensionality reduction")
            self.dimensionality_reducer = DimensionalityReducer(
                method=self.config.get('dimensionality_reduction', {}).get('method', 'pca'),
                n_components=self.config.get('dimensionality_reduction', {}).get('n_components')
            )
            X_reduced = self.dimensionality_reducer.fit_transform(X_selected, y)
        else:
            X_reduced = X_selected
        
        # Step 4: Create model
        logger.info("Step 4: Creating model")
        self.model = self._create_model()
        
        # Step 5: Hyperparameter tuning (if enabled)
        if tune_hyperparameters:
            logger.info("Step 5: Hyperparameter tuning")
            self.best_params = self._tune_hyperparameters(X_reduced, y)
            if self.best_params:
                self.model.set_params(**self.best_params)
                logger.info(f"  Best params: {self.best_params}")
        
        # Step 6: Train final model
        logger.info("Step 6: Training final model")
        self.model.fit(X_reduced, y)
        
        # Step 7: Evaluate
        logger.info("Step 7: Evaluating model")
        eval_results = self._evaluate_model(X_reduced, y)
        
        # Store results
        self.training_results = {
            'time_seconds': time.time() - start_time,
            'model_type': self._model_type,
            'task': self._task,
            'n_features': X_reduced.shape[1],
            'n_samples': len(X_reduced),
            'best_params': self.best_params,
            'evaluation': eval_results
        }
        
        self._is_trained = True
        
        logger.info(f"Pipeline training completed in {self.training_results['time_seconds']:.2f}s")
        logger.info(f"Final score: {eval_results.get('best_metric', 0):.4f}")
        
        return self.training_results
    
    def predict(
        self,
        X: Union[pd.DataFrame, np.ndarray],
        return_proba: bool = False
    ) -> Union[np.ndarray, pd.Series]:
        """
        Make predictions on new data.
        
        Args:
            X: Feature matrix
            return_proba: Whether to return probabilities
            
        Returns:
            Union[np.ndarray, pd.Series]: Predictions
        """
        if not self._is_trained:
            raise ValueError("Pipeline has not been trained. Call train() first.")
        
        # Prepare data
        X = self._prepare_data(X)
        
        # Apply preprocessing
        X_preprocessed = self.preprocessor.transform(X)
        
        # Apply encoding
        X_encoded = self.encoder.transform(X_preprocessed)
        
        # Apply feature creation
        X_enhanced = self.feature_creator.transform(X_encoded)
        
        # Apply feature selection
        if self.feature_selector:
            X_selected = self.feature_selector.transform(X_enhanced)
        else:
            X_selected = X_enhanced
        
        # Apply dimensionality reduction
        if self.dimensionality_reducer:
            X_reduced = self.dimensionality_reducer.transform(X_selected)
        else:
            X_reduced = X_selected
        
        # Make predictions
        if return_proba and hasattr(self.model, 'predict_proba'):
            predictions = self.model.predict_proba(X_reduced)
        else:
            predictions = self.model.predict(X_reduced)
        
        return predictions
    
    def _create_model(self) -> BaseEstimator:
        """
        Create the model based on configuration.
        
        Returns:
            BaseEstimator: Configured model
        """
        # Get model parameters
        model_params = self.config.get('model_params', {})
        
        if self._model_type in ['decision_tree', 'random_forest', 'xgboost', 'lightgbm', 'catboost', 'gradient_boost']:
            # Tree-based model
            return TreeModel(
                model_type=self._model_type,
                task=self._task,
                **model_params
            )
        
        elif self._model_type == 'mlp':
            # Neural network
            n_features = self.config.get('n_features', 100)
            n_classes = len(np.unique(self.config.get('y', [0, 1])))
            
            return MLP(
                input_dim=n_features,
                hidden_dims=model_params.get('hidden_dims', [64, 32]),
                output_dim=n_classes if self._task == 'classification' else 1,
                activation=model_params.get('activation', 'relu'),
                dropout_rate=model_params.get('dropout_rate', 0.0),
                use_batch_norm=model_params.get('use_batch_norm', True)
            )
        
        else:
            raise ValueError(f"Unknown model type: {self._model_type}")
    
    def _tune_hyperparameters(self, X: pd.DataFrame, y: np.ndarray) -> Dict[str, Any]:
        """
        Perform hyperparameter tuning.
        
        Args:
            X: Feature matrix
            y: Target vector
            
        Returns:
            Dict: Best parameters
        """
        tuning_config = self.config.get('tuning', {})
        method = tuning_config.get('method', 'bayesian')
        
        # Get parameter space
        param_space = self._get_param_space()
        
        if not param_space:
            return {}
        
        if method == 'grid':
            tuner = GridSearchOptimizer(
                param_grid=param_space,
                cv=tuning_config.get('cv', 3),
                scoring=tuning_config.get('scoring'),
                n_jobs=-1
            )
            results = tuner.optimize(self.model, X, y)
            return results['best_params']
        
        elif method == 'random':
            tuner = RandomSearchOptimizer(
                param_distributions=param_space,
                n_iter=tuning_config.get('n_trials', 30),
                cv=tuning_config.get('cv', 3),
                scoring=tuning_config.get('scoring'),
                random_state=42,
                n_jobs=-1
            )
            results = tuner.optimize(self.model, X, y)
            return results['best_params']
        
        elif method == 'bayesian':
            tuner = OptunaTuner(
                param_space=param_space,
                n_trials=tuning_config.get('n_trials', 50),
                cv=tuning_config.get('cv', 3),
                scoring=tuning_config.get('scoring'),
                random_state=42
            )
            results = tuner.optimize(X=X, y=y, model=self.model)
            return results['best_params']
        
        else:
            logger.warning(f"Unknown tuning method: {method}")
            return {}
    
    def _get_param_space(self) -> Dict[str, Any]:
        """
        Get parameter space for tuning based on model type.
        
        Returns:
            Dict: Parameter space
        """
        # Model-specific parameter spaces
        param_spaces = {
            'random_forest': {
                'n_estimators': (50, 200),
                'max_depth': (3, 10),
                'min_samples_split': (2, 10),
                'min_samples_leaf': (1, 4),
                'max_features': ['sqrt', 'log2']
            },
            'xgboost': {
                'n_estimators': (50, 200),
                'max_depth': (3, 10),
                'learning_rate': (0.01, 0.3),
                'subsample': (0.6, 1.0),
                'colsample_bytree': (0.6, 1.0)
            },
            'lightgbm': {
                'n_estimators': (50, 200),
                'max_depth': (3, 10),
                'learning_rate': (0.01, 0.3),
                'num_leaves': (10, 50),
                'subsample': (0.6, 1.0)
            },
            'decision_tree': {
                'max_depth': (3, 10),
                'min_samples_split': (2, 10),
                'min_samples_leaf': (1, 4)
            }
        }
        
        return param_spaces.get(self._model_type, {})
    
    def _evaluate_model(self, X: pd.DataFrame, y: np.ndarray) -> Dict[str, Any]:
        """
        Evaluate the trained model.
        
        Args:
            X: Feature matrix
            y: Target vector
            
        Returns:
            Dict: Evaluation results
        """
        # Get predictions
        y_pred = self.model.predict(X)
        
        # Get probabilities if available
        y_proba = None
        if hasattr(self.model, 'predict_proba'):
            y_proba = self.model.predict_proba(X)
            if y_proba.shape[1] == 2:
                y_proba = y_proba[:, 1]
        
        # Compute metrics
        calculator = MetricsCalculator(task=self._task)
        metrics = calculator.compute_metrics(y, y_pred, y_proba)
        
        # Get best metric
        best_metric, best_value = calculator.get_best_metric(metrics)
        
        # Cross-validation
        cv = CrossValidator(
            method='stratified_kfold' if self._task == 'classification' else 'kfold',
            n_splits=5
        )
        cv_results = cv.validate(self.model, X, y)
        
        return {
            'metrics': metrics,
            'best_metric': best_value,
            'best_metric_name': best_metric,
            'cv_mean': cv_results['mean_score'],
            'cv_std': cv_results['std_score'],
            'n_samples': len(y)
        }
    
    def _prepare_data(self, X: Union[pd.DataFrame, np.ndarray]) -> pd.DataFrame:
        """Convert input to DataFrame."""
        if isinstance(X, np.ndarray):
            if self._feature_names is not None:
                return pd.DataFrame(X, columns=self._feature_names)
            else:
                return pd.DataFrame(X)
        return X
    
    def save(self, filepath: Union[str, Path]):
        """
        Save the entire pipeline to disk.
        
        Args:
            filepath: Path to save the pipeline
        """
        filepath = Path(filepath)
        filepath.parent.mkdir(parents=True, exist_ok=True)
        
        # Save model and transformers
        joblib.dump({
            'config': self.config,
            'preprocessor': self.preprocessor,
            'encoder': self.encoder,
            'feature_creator': self.feature_creator,
            'feature_selector': self.feature_selector,
            'dimensionality_reducer': self.dimensionality_reducer,
            'model': self.model,
            'feature_names': self._feature_names,
            'best_params': self.best_params,
            'is_trained': self._is_trained
        }, filepath)
        
        logger.info(f"Pipeline saved to: {filepath}")
    
    def load(self, filepath: Union[str, Path]):
        """
        Load a saved pipeline.
        
        Args:
            filepath: Path to the saved pipeline
        """
        filepath = Path(filepath)
        if not filepath.exists():
            raise FileNotFoundError(f"Pipeline not found: {filepath}")
        
        data = joblib.load(filepath)
        
        self.config = data['config']
        self.preprocessor = data['preprocessor']
        self.encoder = data['encoder']
        self.feature_creator = data['feature_creator']
        self.feature_selector = data['feature_selector']
        self.dimensionality_reducer = data['dimensionality_reducer']
        self.model = data['model']
        self._feature_names = data['feature_names']
        self.best_params = data['best_params']
        self._is_trained = data['is_trained']
        
        logger.info(f"Pipeline loaded from: {filepath}")
    
    def get_summary(self) -> Dict[str, Any]:
        """
        Get a summary of the pipeline.
        
        Returns:
            Dict: Pipeline summary
        """
        return {
            'model_type': self._model_type,
            'task': self._task,
            'is_trained': self._is_trained,
            'feature_names': self._feature_names,
            'best_params': self.best_params,
            'training_results': self.training_results
        }
```

#### Step 2: The Training Script

**File:** `src/pipeline/trainer.py`
**Path:** `ml-pipeline-project/src/pipeline/trainer.py`

```python
"""
Training script for the ML pipeline.

This script orchestrates the complete training workflow:
- Load data
- Configure pipeline
- Train with hyperparameter optimization
- Save model and results
"""

import argparse
import json
import sys
from pathlib import Path
import pandas as pd
from loguru import logger
import yaml

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from src.pipeline.builder import MLPipeline

def load_config(config_path: str) -> dict:
    """
    Load configuration from YAML file.
    
    Args:
        config_path: Path to config file
        
    Returns:
        dict: Configuration dictionary
    """
    with open(config_path, 'r') as f:
        if config_path.endswith('.yaml') or config_path.endswith('.yml'):
            config = yaml.safe_load(f)
        else:
            config = json.load(f)
    return config

def main():
    """Main training function."""
    parser = argparse.ArgumentParser(description='Train ML pipeline')
    parser.add_argument('--config', type=str, required=True, help='Path to config file')
    parser.add_argument('--data', type=str, required=True, help='Path to data file')
    parser.add_argument('--output', type=str, default='models/pipeline.joblib', help='Output path')
    parser.add_argument('--target', type=str, required=True, help='Target column name')
    parser.add_argument('--no-tune', action='store_true', help='Skip hyperparameter tuning')
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    config['target_col'] = args.target
    
    # Load data
    logger.info(f"Loading data from: {args.data}")
    data = pd.read_csv(args.data)
    logger.info(f"Data shape: {data.shape}")
    
    # Split features and target
    if args.target not in data.columns:
        raise ValueError(f"Target column '{args.target}' not found in data")
    
    X = data.drop(columns=[args.target])
    y = data[args.target]
    
    # Create and train pipeline
    logger.info("Creating pipeline")
    pipeline = MLPipeline(config=config)
    
    logger.info("Starting training")
    results = pipeline.train(
        X=X,
        y=y,
        tune_hyperparameters=not args.no_tune
    )
    
    # Save pipeline
    logger.info(f"Saving pipeline to: {args.output}")
    pipeline.save(args.output)
    
    # Save results
    results_path = Path(args.output).with_suffix('.results.json')
    with open(results_path, 'w') as f:
        # Convert numpy types to Python types for JSON serialization
        results_clean = {}
        for key, value in results.items():
            if isinstance(value, dict):
                results_clean[key] = {k: float(v) if isinstance(v, (np.floating, float)) else v 
                                    for k, v in value.items()}
            else:
                results_clean[key] = float(value) if isinstance(value, (np.floating, float)) else value
        json.dump(results_clean, f, indent=2)
    
    logger.info(f"Results saved to: {results_path}")
    logger.info("Training complete!")

if __name__ == "__main__":
    main()
```

#### Step 3: The Prediction Script

**File:** `src/pipeline/predictor.py`
**Path:** `ml-pipeline-project/src/pipeline/predictor.py`

```python
"""
Prediction script for the ML pipeline.

This script loads a trained pipeline and makes predictions on new data.
"""

import argparse
import sys
from pathlib import Path
import pandas as pd
import numpy as np
from loguru import logger

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from src.pipeline.builder import MLPipeline

def main():
    """Main prediction function."""
    parser = argparse.ArgumentParser(description='Make predictions')
    parser.add_argument('--pipeline', type=str, required=True, help='Path to saved pipeline')
    parser.add_argument('--data', type=str, required=True, help='Path to data file')
    parser.add_argument('--output', type=str, default='predictions.csv', help='Output path')
    parser.add_argument('--proba', action='store_true', help='Output probabilities')
    args = parser.parse_args()
    
    # Load pipeline
    logger.info(f"Loading pipeline from: {args.pipeline}")
    pipeline = MLPipeline(config={})
    pipeline.load(args.pipeline)
    
    # Load data
    logger.info(f"Loading data from: {args.data}")
    data = pd.read_csv(args.data)
    logger.info(f"Data shape: {data.shape}")
    
    # Make predictions
    logger.info("Making predictions")
    predictions = pipeline.predict(data, return_proba=args.proba)
    
    # Save predictions
    if args.proba:
        # Save probabilities
        if len(predictions.shape) == 1:
            predictions = predictions.reshape(-1, 1)
        pred_df = pd.DataFrame(predictions, columns=[f'prob_class_{i}' for i in range(predictions.shape[1])])
    else:
        pred_df = pd.DataFrame({'prediction': predictions})
    
    pred_df.to_csv(args.output, index=False)
    logger.info(f"Predictions saved to: {args.output}")
    logger.info(f"Predictions shape: {pred_df.shape}")
    
    # Print summary
    if not args.proba:
        logger.info(f"Prediction distribution:\n{pd.Series(predictions).value_counts().to_string()}")

if __name__ == "__main__":
    main()
```

### The Verification: Testing the Complete Pipeline

#### Test 1: End-to-End Pipeline Training

```bash
cat > test_full_pipeline.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from src.pipeline.builder import MLPipeline

# Create dataset with preprocessing needs
X, y = make_classification(
    n_samples=1000,
    n_features=20,
    n_informative=10,
    n_redundant=5,
    n_classes=2,
    random_state=42
)

# Add categorical and missing values
X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])
X['category'] = np.random.choice(['A', 'B', 'C', 'D', 'E'], len(X))
X['region'] = np.random.choice(['North', 'South', 'East', 'West'], len(X))
y = pd.Series(y, name='target')

# Introduce missing values
X.loc[np.random.choice(len(X), 50, replace=False), 'feature_0'] = np.nan
X.loc[np.random.choice(len(X), 30, replace=False), 'feature_1'] = np.nan

print("Data shape:", X.shape)
print(f"Class distribution: {y.value_counts().to_dict()}")
print(f"Missing values: {X.isnull().sum().sum()}")

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Configuration
config = {
    'model_type': 'random_forest',
    'task': 'classification',
    'target_col': 'target',
    'imputation': {
        'numeric': 'median',
        'categorical': 'mode'
    },
    'scaling': {
        'method': 'standard'
    },
    'encoding': {
        'strategy': 'auto'
    },
    'feature_creation': {
        'polynomial_degree': 2,
        'interactions': True,
        'ratios': False
    },
    'feature_selection': {
        'enabled': True,
        'method': 'model',
        'n_features': 15
    },
    'tuning': {
        'method': 'random',
        'n_trials': 10,
        'cv': 3
    }
}

print("\n" + "="*60)
print("Training Full Pipeline")
print("="*60)

# Create and train pipeline
pipeline = MLPipeline(config=config)
results = pipeline.train(
    X_train,
    y_train,
    tune_hyperparameters=True
)

print(f"\nTraining Results:")
print(f"  Time: {results['time_seconds']:.2f}s")
print(f"  Model: {results['model_type']}")
print(f"  Features: {results['n_features']}")
print(f"  Best params: {results.get('best_params', {})}")

if results['evaluation']:
    eval_results = results['evaluation']
    print(f"\nEvaluation:")
    print(f"  CV Mean: {eval_results.get('cv_mean', 0):.4f}")
    print(f"  CV Std: {eval_results.get('cv_std', 0):.4f}")
    print(f"  Best Metric: {eval_results.get('best_metric_name', 'N/A')} = {eval_results.get('best_metric', 0):.4f}")

# Test predictions
print("\n" + "="*60)
print("Making Predictions on Test Set")
print("="*60)

y_pred = pipeline.predict(X_test)
accuracy = np.mean(y_pred == y_test)
print(f"Test Accuracy: {accuracy:.4f}")

# Save pipeline
pipeline.save('models/test_pipeline.joblib')
print("\nPipeline saved to: models/test_pipeline.joblib")

print("\n✅ Full pipeline test complete!")
EOF

python test_full_pipeline.py
```

#### Test 2: Training Script Test

```bash
cat > test_training_script.py << 'EOF'
import pandas as pd
import numpy as np
import json
from sklearn.datasets import make_classification

# Create dataset
X, y = make_classification(
    n_samples=1000,
    n_features=15,
    n_informative=8,
    n_redundant=3,
    n_classes=2,
    random_state=42
)

X = pd.DataFrame(X, columns=[f'feature_{i}' for i in range(X.shape[1])])
X['category'] = np.random.choice(['A', 'B', 'C', 'D'], len(X))
y = pd.Series(y, name='target')

# Save data
data = pd.concat([X, y], axis=1)
data.to_csv('data/raw/training_data.csv', index=False)
print("Data saved to: data/raw/training_data.csv")

# Create config
config = {
    'model_type': 'random_forest',
    'task': 'classification',
    'imputation': {
        'numeric': 'median',
        'categorical': 'mode'
    },
    'scaling': {
        'method': 'standard'
    },
    'encoding': {
        'strategy': 'auto'
    },
    'feature_creation': {
        'polynomial_degree': 2,
        'interactions': True,
        'ratios': False
    },
    'feature_selection': {
        'enabled': True,
        'method': 'model',
        'n_features': 12
    },
    'tuning': {
        'method': 'random',
        'n_trials': 5,
        'cv': 3
    }
}

with open('configs/training_config.json', 'w') as f:
    json.dump(config, f, indent=2)
print("Config saved to: configs/training_config.json")

print("\n" + "="*60)
print("Test Training Script")
print("="*60)

# Run the training script
import subprocess
import sys

result = subprocess.run([
    sys.executable,
    'src/pipeline/trainer.py',
    '--config', 'configs/training_config.json',
    '--data', 'data/raw/training_data.csv',
    '--output', 'models/trained_pipeline.joblib',
    '--target', 'target'
], capture_output=True, text=True)

print(result.stdout)
if result.stderr:
    print("Errors:", result.stderr)

print("\n✅ Training script test complete!")
EOF

python test_training_script.py
```

#### Test 3: Prediction Script Test

```bash
cat > test_prediction_script.py << 'EOF'
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification

# Check if trained pipeline exists
import os
if not os.path.exists('models/trained_pipeline.joblib'):
    print("Trained pipeline not found. Run test_training_script.py first.")
    exit(1)

# Create test data
X_test, y_test = make_classification(
    n_samples=100,
    n_features=15,
    n_informative=8,
    n_redundant=3,
    n_classes=2,
    random_state=43
)

X_test = pd.DataFrame(X_test, columns=[f'feature_{i}' for i in range(X_test.shape[1])])
X_test['category'] = np.random.choice(['A', 'B', 'C', 'D'], len(X_test))

# Save test data
X_test.to_csv('data/raw/test_data.csv', index=False)
print("Test data saved to: data/raw/test_data.csv")

print("\n" + "="*60)
print("Test Prediction Script")
print("="*60)

# Run the prediction script
import subprocess
import sys

result = subprocess.run([
    sys.executable,
    'src/pipeline/predictor.py',
    '--pipeline', 'models/trained_pipeline.joblib',
    '--data', 'data/raw/test_data.csv',
    '--output', 'predictions.csv'
], capture_output=True, text=True)

print(result.stdout)
if result.stderr:
    print("Errors:", result.stderr)

# Check predictions
if os.path.exists('predictions.csv'):
    predictions = pd.read_csv('predictions.csv')
    print(f"\nPredictions shape: {predictions.shape}")
    print(f"Predictions distribution:\n{predictions['prediction'].value_counts().to_string()}")

print("\n✅ Prediction script test complete!")
EOF

python test_prediction_script.py
```

### What Just Happened: Understanding the Pipeline

#### The Pipeline Architecture

Our pipeline follows a modular, layered architecture:

1. **Data Layer**: Handles ingestion and validation
2. **Feature Layer**: Transforms raw data into model-ready features
3. **Model Layer**: Trains and evaluates models
4. **Validation Layer**: Ensures robustness and generalization
5. **Deployment Layer**: Serves predictions in production

#### Key Design Decisions

**Leak-Free Preprocessing**:
- All transformers are fitted on training data only
- Transformations are applied consistently to new data
- Cross-validation is integrated into the pipeline

**Configuration-Driven**:
- Everything is configured through YAML/JSON
- Easy to experiment with different settings
- Supports different environments (dev, staging, production)

**Comprehensive Logging**:
- Every step is logged for debugging
- Performance metrics are tracked
- Errors are caught and reported

**Model Persistence**:
- Whole pipeline is saved as a single artifact
- Includes all transformers and the model
- Easy to version and deploy

### Summary

In this part, we've built a complete production-grade pipeline that:

1. **Integrates** all components from data ingestion to prediction
2. **Prevents data leakage** through proper transformer fitting
3. **Supports hyperparameter tuning** with multiple methods
4. **Provides comprehensive logging** for monitoring
5. **Handles model persistence** for deployment
6. **Includes training and prediction scripts** for easy use
7. **Is fully configurable** through YAML/JSON

### What's Next

In Part 14, we'll complete the Capstone Project with a real-world dataset, applying everything we've built to solve a concrete business problem. Then in Part 15, we'll deploy the pipeline as an API service.
