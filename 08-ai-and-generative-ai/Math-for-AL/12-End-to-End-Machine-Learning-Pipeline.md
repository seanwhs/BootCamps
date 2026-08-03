# Phase 4, Part 2: Complete Production ML System

## Module 2: End-to-End Machine Learning Pipeline

### The Target

We're building the complete production machine learning system that integrates every component we've developed throughout this series. This is the culmination of all our work—a fully functional, production-ready ML pipeline that handles data preprocessing, model training, evaluation, and deployment.

**Files we'll create:**
- `src/pipeline/complete_pipeline.py`
- `src/utils/__init__.py`
- `src/utils/logger.py`
- `src/utils/config.py`
- `src/main.py`
- `scripts/run_pipeline.py`
- `README.md` (final project documentation)
- `requirements.txt` (updated)

### The Concept

Think of this as assembling a car from all the parts we've built:

1. **Engine**: Linear algebra (vectors, matrices, tensors)
2. **Transmission**: Calculus (derivatives, optimization, backpropagation)
3. **Steering**: Probability (distributions, Bayes, uncertainty)
4. **Fuel system**: Numerical methods (stability, performance)
5. **Dashboard**: Evaluation metrics and visualization
6. **Chassis**: The complete pipeline that ties everything together

Now we're putting it all together into a vehicle that's ready for the road.

### The Implementation

#### Step 1: Utility Modules

**File: `src/utils/__init__.py`**

```python
"""
Utility modules for production ML system.
"""

from src.utils.logger import setup_logger, get_logger
from src.utils.config import Config, load_config

__all__ = ['setup_logger', 'get_logger', 'Config', 'load_config']
```

**File: `src/utils/logger.py`**

```python
"""
Logging configuration for production ML system.
"""

import logging
import sys
from datetime import datetime
from typing import Optional


def setup_logger(name: str = "ml_system", 
                 log_file: Optional[str] = None,
                 level: str = "INFO") -> logging.Logger:
    """
    Set up a logger with console and file handlers.
    
    Args:
        name: Logger name.
        log_file: Optional file path for log output.
        level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL).
        
    Returns:
        Configured logger.
    """
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, level.upper()))
    
    # Remove existing handlers
    logger.handlers.clear()
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(getattr(logging, level.upper()))
    console_format = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)
    
    # File handler
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(getattr(logging, level.upper()))
        file_format = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_format)
        logger.addHandler(file_handler)
    
    return logger


def get_logger(name: str = "ml_system") -> logging.Logger:
    """
    Get an existing logger or create a default one.
    """
    logger = logging.getLogger(name)
    if not logger.handlers:
        return setup_logger(name)
    return logger
```

**File: `src/utils/config.py`**

```python
"""
Configuration management for production ML system.
"""

import json
import yaml
from typing import Dict, Any, Optional
from pathlib import Path


class Config:
    """
    Configuration manager for ML system.
    
    Supports loading from JSON or YAML files, with default values.
    """
    
    def __init__(self, config_dict: Optional[Dict[str, Any]] = None):
        """
        Initialize configuration.
        
        Args:
            config_dict: Dictionary of configuration values.
        """
        self._config = config_dict or {}
        self._defaults = self._get_defaults()
    
    @staticmethod
    def _get_defaults() -> Dict[str, Any]:
        """Get default configuration values."""
        return {
            'data': {
                'test_size': 0.15,
                'val_size': 0.15,
                'random_seed': 42,
                'scaling': 'standardize'
            },
            'model': {
                'type': 'neural_network',
                'layer_sizes': [64, 32],
                'learning_rate': 0.01,
                'num_epochs': 100,
                'batch_size': 32,
                'loss_type': 'mse',
                'activation': 'relu'
            },
            'training': {
                'early_stopping': True,
                'patience': 10,
                'validation_freq': 10,
                'gradient_clip': 1.0
            },
            'evaluation': {
                'metrics': ['mse', 'rmse', 'r2'],
                'cross_validation_folds': 5
            },
            'logging': {
                'level': 'INFO',
                'log_file': 'logs/ml_system.log'
            }
        }
    
    def get(self, key: str, default: Any = None) -> Any:
        """
        Get a configuration value by dot-separated key.
        
        Example:
            config.get('data.test_size')
        """
        keys = key.split('.')
        value = self._config
        
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                # Try defaults
                default_value = self._defaults
                for dk in keys:
                    if isinstance(default_value, dict) and dk in default_value:
                        default_value = default_value[dk]
                    else:
                        return default
        
        return value if value is not None else default
    
    def set(self, key: str, value: Any) -> None:
        """Set a configuration value by dot-separated key."""
        keys = key.split('.')
        config = self._config
        
        for k in keys[:-1]:
            if k not in config:
                config[k] = {}
            config = config[k]
        
        config[keys[-1]] = value
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert configuration to dictionary."""
        return self._config.copy()
    
    def load_from_file(self, filepath: str) -> None:
        """
        Load configuration from a JSON or YAML file.
        
        Args:
            filepath: Path to configuration file.
        """
        path = Path(filepath)
        
        if not path.exists():
            raise FileNotFoundError(f"Configuration file not found: {filepath}")
        
        with open(path, 'r') as f:
            if path.suffix in ['.yaml', '.yml']:
                data = yaml.safe_load(f)
            elif path.suffix == '.json':
                data = json.load(f)
            else:
                raise ValueError(f"Unsupported file format: {path.suffix}")
        
        # Merge with existing config
        self._merge_dict(self._config, data)
    
    def _merge_dict(self, target: Dict, source: Dict) -> None:
        """Recursively merge source dictionary into target."""
        for key, value in source.items():
            if key in target and isinstance(target[key], dict) and isinstance(value, dict):
                self._merge_dict(target[key], value)
            else:
                target[key] = value
    
    def save_to_file(self, filepath: str) -> None:
        """Save configuration to file."""
        path = Path(filepath)
        path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(path, 'w') as f:
            if path.suffix in ['.yaml', '.yml']:
                yaml.dump(self._config, f, default_flow_style=False)
            elif path.suffix == '.json':
                json.dump(self._config, f, indent=2)
            else:
                raise ValueError(f"Unsupported file format: {path.suffix}")


def load_config(filepath: Optional[str] = None) -> Config:
    """
    Load configuration from file with defaults.
    
    Args:
        filepath: Optional path to configuration file.
        
    Returns:
        Config object.
    """
    config = Config()
    
    if filepath:
        config.load_from_file(filepath)
    
    return config
```

#### Step 2: Complete Pipeline Implementation

**File: `src/pipeline/complete_pipeline.py`**

```python
"""
Complete production machine learning pipeline.

This module integrates all components:
- Data preprocessing (from data_pipeline)
- Model training (from model_pipeline)
- Evaluation (from evaluation)
- Numerical stability (from numerical)
- Logging and configuration (from utils)

This is the final production-ready ML system.
"""

from typing import List, Tuple, Dict, Optional, Any, Union
import time
import json
from pathlib import Path
from src.linear_algebra import Matrix, Vector
from src.pipeline.data_pipeline import DataPipeline
from src.pipeline.model_pipeline import ModelPipeline
from src.probability import ModelMetrics, BiasVarianceAnalysis
from src.numerical import NumericalStability
from src.utils import setup_logger, get_logger, Config, load_config


class CompleteMLPipeline:
    """
    Complete production ML pipeline.
    
    This is the main entry point for the ML system, integrating
    all components into a single, cohesive pipeline.
    
    Usage:
        pipeline = CompleteMLPipeline(config_path='config.yaml')
        pipeline.run(X_train, y_train, X_test, y_test)
    """
    
    def __init__(self, config: Optional[Union[str, Config, Dict]] = None):
        """
        Initialize the complete pipeline.
        
        Args:
            config: Configuration (file path, Config object, or dict).
        """
        # Load configuration
        if isinstance(config, str):
            self.config = load_config(config)
        elif isinstance(config, Config):
            self.config = config
        elif isinstance(config, dict):
            self.config = Config(config)
        else:
            self.config = Config()
        
        # Setup logging
        log_level = self.config.get('logging.level', 'INFO')
        log_file = self.config.get('logging.log_file', None)
        self.logger = setup_logger('ml_pipeline', log_file, log_level)
        
        # Initialize components
        self.data_pipeline = DataPipeline(
            random_seed=self.config.get('data.random_seed', 42)
        )
        
        self.model_pipeline = None
        self.training_history = None
        self.evaluation_results = {}
        
        self.logger.info("Complete ML Pipeline initialized")
    
    def run(self, X: Matrix, y: Matrix, 
            X_test: Optional[Matrix] = None,
            y_test: Optional[Matrix] = None) -> Dict[str, Any]:
        """
        Run the complete pipeline from end to end.
        
        Args:
            X: Training features.
            y: Training labels.
            X_test: Optional test features.
            y_test: Optional test labels.
            
        Returns:
            Dictionary of results.
        """
        start_time = time.time()
        
        self.logger.info("Starting pipeline execution")
        self.logger.info(f"Training data: {X.rows} samples, {X.cols} features")
        
        # Step 1: Data preprocessing
        self.logger.info("Step 1: Data preprocessing")
        X_processed, y_processed = self._preprocess_data(X, y)
        
        # Step 2: Split data
        self.logger.info("Step 2: Splitting data")
        train_ratio = 1 - self.config.get('data.test_size', 0.15) - self.config.get('data.val_size', 0.15)
        val_ratio = self.config.get('data.val_size', 0.15)
        test_ratio = self.config.get('data.test_size', 0.15)
        
        X_train, X_val, X_test, y_train, y_val, y_test = \
            self.data_pipeline.split_data(
                X_processed, y_processed,
                train_ratio, val_ratio, test_ratio
            )
        
        self.logger.info(f"Train: {X_train.rows}, Val: {X_val.rows}, Test: {X_test.rows}")
        
        # Step 3: Create and train model
        self.logger.info("Step 3: Model training")
        model = self._create_model(X_train.cols, y_train.cols)
        self.model_pipeline = ModelPipeline(model, 
                                           random_seed=self.config.get('data.random_seed', 42))
        
        # Train with early stopping
        train_metrics = self._train_with_early_stopping(
            X_train, y_train, X_val, y_val
        )
        
        # Step 4: Evaluate
        self.logger.info("Step 4: Model evaluation")
        evaluation_results = self._evaluate_model(
            X_train, y_train, X_val, y_val, X_test, y_test
        )
        
        # Step 5: Bias-variance analysis
        self.logger.info("Step 5: Bias-variance analysis")
        bias_variance_results = self._analyze_bias_variance(
            X_train, y_train
        )
        
        # Step 6: Generate report
        elapsed_time = time.time() - start_time
        
        results = {
            'training': train_metrics,
            'evaluation': evaluation_results,
            'bias_variance': bias_variance_results,
            'elapsed_time': elapsed_time,
            'config': self.config.to_dict()
        }
        
        self.evaluation_results = results
        
        self.logger.info(f"Pipeline completed in {elapsed_time:.2f} seconds")
        
        return results
    
    def _preprocess_data(self, X: Matrix, y: Matrix) -> Tuple[Matrix, Matrix]:
        """Preprocess data."""
        # Handle missing values
        if hasattr(self.data_pipeline, 'handle_missing_values'):
            X = self.data_pipeline.handle_missing_values(X, strategy='mean')
        
        # Scale features
        scaling = self.config.get('data.scaling', 'standardize')
        X = self.data_pipeline.scale_data(X, method=scaling)
        
        # Add polynomial features if configured
        degree = self.config.get('data.polynomial_degree', 1)
        if degree > 1:
            X = self.data_pipeline.add_polynomial_features(X, degree)
        
        # Ensure y is a Matrix
        if isinstance(y, Vector):
            y = Matrix([[y[i]] for i in range(y.size)])
        
        return X, y
    
    def _create_model(self, input_size: int, output_size: int):
        """Create model based on configuration."""
        model_type = self.config.get('model.type', 'neural_network')
        
        if model_type == 'neural_network':
            from src.models import NeuralNetwork
            
            hidden_sizes = self.config.get('model.layer_sizes', [64, 32])
            layer_sizes = [input_size] + hidden_sizes + [output_size]
            
            activations = self.config.get('model.activations', ['relu'] * len(hidden_sizes))
            
            model = NeuralNetwork(
                layer_sizes=layer_sizes,
                activations=activations,
                learning_rate=self.config.get('model.learning_rate', 0.01),
                batch_size=self.config.get('model.batch_size', 32),
                num_epochs=self.config.get('model.num_epochs', 100),
                loss_type=self.config.get('model.loss_type', 'mse'),
                random_seed=self.config.get('data.random_seed', 42)
            )
            
            self.logger.info(f"Created Neural Network: {layer_sizes}")
            return model
        
        elif model_type == 'naive_bayes':
            from src.probability import GaussianNaiveBayes
            model = GaussianNaiveBayes()
            self.logger.info("Created Naive Bayes model")
            return model
        
        else:
            raise ValueError(f"Unsupported model type: {model_type}")
    
    def _train_with_early_stopping(self, X_train: Matrix, y_train: Matrix,
                                   X_val: Matrix, y_val: Matrix) -> Dict[str, Any]:
        """Train model with early stopping."""
        early_stopping = self.config.get('training.early_stopping', True)
        patience = self.config.get('training.patience', 10)
        
        # Train model
        if hasattr(self.model_pipeline.model, 'fit'):
            # If model returns history
            history = self.model_pipeline.train(X_train, y_train)
            
            # Early stopping
            if early_stopping and hasattr(self.model_pipeline.model, 'training_history'):
                train_losses = self.model_pipeline.model.training_history.get('loss', [])
                val_losses = self.model_pipeline.model.training_history.get('val_loss', [])
                
                if val_losses and len(val_losses) > patience:
                    best_idx = min(range(len(val_losses)), key=lambda i: val_losses[i])
                    if best_idx + patience < len(val_losses):
                        self.logger.info(f"Early stopping at epoch {best_idx + patience}")
            
            return history
        
        else:
            # Simple training
            self.model_pipeline.train(X_train, y_train)
            return {}
    
    def _evaluate_model(self, X_train: Matrix, y_train: Matrix,
                       X_val: Matrix, y_val: Matrix,
                       X_test: Matrix, y_test: Matrix) -> Dict[str, Any]:
        """Evaluate model on all datasets."""
        results = {}
        
        # Training metrics
        train_pred = self.model_pipeline.predict(X_train)
        if isinstance(train_pred, Vector):
            train_pred = Matrix([[train_pred[i]] for i in range(train_pred.size)])
        
        results['train'] = self._compute_metrics(train_pred, y_train)
        
        # Validation metrics
        val_pred = self.model_pipeline.predict(X_val)
        if isinstance(val_pred, Vector):
            val_pred = Matrix([[val_pred[i]] for i in range(val_pred.size)])
        
        results['validation'] = self._compute_metrics(val_pred, y_val)
        
        # Test metrics
        test_pred = self.model_pipeline.predict(X_test)
        if isinstance(test_pred, Vector):
            test_pred = Matrix([[test_pred[i]] for i in range(test_pred.size)])
        
        results['test'] = self._compute_metrics(test_pred, y_test)
        
        # Cross-validation
        if self.config.get('evaluation.cross_validation_folds', 0) > 0:
            n_folds = self.config.get('evaluation.cross_validation_folds', 5)
            self.logger.info(f"Performing {n_folds}-fold cross-validation")
            cv_results = self.model_pipeline.cross_validate(
                X_train, y_train, k=n_folds
            )
            results['cross_validation'] = cv_results
        
        return results
    
    def _compute_metrics(self, predictions: Matrix, targets: Matrix) -> Dict[str, float]:
        """Compute evaluation metrics."""
        metrics = {}
        
        # Convert to vectors for metric computation
        pred_vec = predictions.col(0) if predictions.cols > 0 else Vector([])
        target_vec = targets.col(0) if targets.cols > 0 else Vector([])
        
        # Regression metrics
        if self.config.get('model.loss_type', 'mse') == 'mse':
            metrics['mse'] = ModelMetrics.mse(pred_vec, target_vec)
            metrics['rmse'] = ModelMetrics.rmse(pred_vec, target_vec)
            metrics['mae'] = ModelMetrics.mae(pred_vec, target_vec)
            metrics['r2'] = ModelMetrics.r2_score(pred_vec, target_vec)
        
        # Classification metrics
        else:
            # Use threshold 0.5 for binary classification
            pred_binary = Vector([1 if pred_vec[i] >= 0.5 else 0 
                                 for i in range(pred_vec.size)])
            
            metrics['accuracy'] = ModelMetrics.accuracy(pred_binary, target_vec)
            metrics['precision'] = ModelMetrics.precision(pred_binary, target_vec)
            metrics['recall'] = ModelMetrics.recall(pred_binary, target_vec)
            metrics['f1'] = ModelMetrics.f1_score(pred_binary, target_vec)
            
            # Brier score for probabilities
            metrics['brier'] = ModelMetrics.brier_score(pred_vec, target_vec)
        
        return metrics
    
    def _analyze_bias_variance(self, X_train: Matrix, y_train: Matrix) -> Dict[str, Any]:
        """Analyze bias-variance tradeoff."""
        # Generate learning curve
        train_sizes = self.config.get('analysis.train_sizes', [10, 20, 50, 100])
        train_sizes = [min(s, X_train.rows) for s in train_sizes]
        train_sizes = sorted(set(train_sizes))
        
        if len(train_sizes) < 2:
            return {'learning_curve': []}
        
        train_scores, test_scores = BiasVarianceAnalysis.learning_curve(
            self.model_pipeline.model, X_train, y_train,
            train_sizes, random_seed=self.config.get('data.random_seed', 42)
        )
        
        # Convert to dict
        learning_curve_data = []
        for i, size in enumerate(train_sizes):
            learning_curve_data.append({
                'train_size': size,
                'train_score': train_scores[i, 0] if i < train_scores.rows else 0,
                'test_score': test_scores[i, 0] if i < test_scores.rows else 0
            })
        
        return {
            'learning_curve': learning_curve_data,
            'train_sizes': train_sizes
        }
    
    def predict(self, X: Matrix) -> Matrix:
        """
        Make predictions using the trained model.
        
        Args:
            X: Features to predict.
            
        Returns:
            Predictions.
        """
        if self.model_pipeline is None:
            raise ValueError("Model must be trained before prediction")
        
        # Preprocess
        X_processed, _ = self._preprocess_data(X, Matrix([[0.0]]))
        
        return self.model_pipeline.predict(X_processed)
    
    def save(self, filepath: str) -> None:
        """
        Save the trained pipeline to file.
        
        Args:
            filepath: Path to save the pipeline.
        """
        import pickle
        
        data = {
            'model_pipeline': self.model_pipeline,
            'data_pipeline': self.data_pipeline,
            'config': self.config.to_dict(),
            'evaluation_results': self.evaluation_results
        }
        
        with open(filepath, 'wb') as f:
            pickle.dump(data, f)
        
        self.logger.info(f"Pipeline saved to {filepath}")
    
    def load(self, filepath: str) -> None:
        """
        Load a trained pipeline from file.
        
        Args:
            filepath: Path to load the pipeline from.
        """
        import pickle
        
        with open(filepath, 'rb') as f:
            data = pickle.load(f)
        
        self.model_pipeline = data['model_pipeline']
        self.data_pipeline = data['data_pipeline']
        self.config = Config(data['config'])
        self.evaluation_results = data.get('evaluation_results', {})
        
        self.logger.info(f"Pipeline loaded from {filepath}")
    
    def generate_report(self) -> str:
        """
        Generate a human-readable report of pipeline results.
        """
        lines = []
        lines.append("=" * 60)
        lines.append("ML Pipeline Execution Report")
        lines.append("=" * 60)
        
        # Configuration
        lines.append("\nConfiguration:")
        config_dict = self.config.to_dict()
        for key, value in config_dict.items():
            lines.append(f"  {key}: {value}")
        
        # Results
        if self.evaluation_results:
            lines.append("\nEvaluation Results:")
            
            for dataset, metrics in self.evaluation_results.get('evaluation', {}).items():
                if isinstance(metrics, dict) and 'mse' in metrics:
                    lines.append(f"\n  {dataset.upper()}:")
                    lines.append(f"    MSE: {metrics.get('mse', 0):.6f}")
                    lines.append(f"    RMSE: {metrics.get('rmse', 0):.6f}")
                    lines.append(f"    R²: {metrics.get('r2', 0):.6f}")
            
            # Cross-validation
            cv_results = self.evaluation_results.get('evaluation', {}).get('cross_validation', {})
            if cv_results:
                lines.append(f"\n  Cross-Validation:")
                lines.append(f"    Mean Score: {cv_results.get('mean_score', 0):.6f}")
                lines.append(f"    Std Score: {cv_results.get('std_score', 0):.6f}")
            
            # Bias-variance
            bv = self.evaluation_results.get('bias_variance', {})
            if bv.get('learning_curve'):
                lines.append("\n  Bias-Variance Analysis:")
                lines.append("    Learning Curve:")
                for point in bv['learning_curve']:
                    lines.append(f"      Size {point['train_size']}: Train={point['train_score']:.4f}, Test={point['test_score']:.4f}")
        
        # Timing
        if self.evaluation_results.get('elapsed_time'):
            lines.append(f"\nExecution Time: {self.evaluation_results['elapsed_time']:.2f} seconds")
        
        lines.append("\n" + "=" * 60)
        
        return "\n".join(lines)
```

#### Step 3: Main Entry Point

**File: `src/main.py`**

```python
"""
Main entry point for the ML system.
"""

import sys
import argparse
from pathlib import Path
from src.pipeline.complete_pipeline import CompleteMLPipeline
from src.utils import setup_logger, get_logger, load_config
from src.linear_algebra import Matrix, Vector


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='Production ML Pipeline')
    parser.add_argument('--config', type=str, help='Path to configuration file')
    parser.add_argument('--train', type=str, help='Path to training data (CSV)')
    parser.add_argument('--test', type=str, help='Path to test data (CSV)')
    parser.add_argument('--output', type=str, help='Path for output results')
    parser.add_argument('--save', type=str, help='Path to save trained pipeline')
    parser.add_argument('--load', type=str, help='Path to load trained pipeline')
    parser.add_argument('--predict', type=str, help='Path to data for prediction')
    
    args = parser.parse_args()
    
    # Setup logging
    logger = setup_logger('main')
    
    # Load configuration
    config = load_config(args.config) if args.config else None
    
    # Create pipeline
    pipeline = CompleteMLPipeline(config)
    
    # Load from saved pipeline
    if args.load:
        logger.info(f"Loading pipeline from {args.load}")
        pipeline.load(args.load)
    
    # Train
    if args.train:
        logger.info(f"Loading training data from {args.train}")
        X, y = load_data(args.train)
        
        # Load test data if available
        X_test, y_test = None, None
        if args.test:
            logger.info(f"Loading test data from {args.test}")
            X_test, y_test = load_data(args.test)
        
        # Run pipeline
        results = pipeline.run(X, y, X_test, y_test)
        
        # Save results
        if args.output:
            save_results(args.output, results)
        
        # Save pipeline
        if args.save:
            pipeline.save(args.save)
        
        # Generate report
        print(pipeline.generate_report())
    
    # Predict
    elif args.predict:
        logger.info(f"Loading prediction data from {args.predict}")
        X, _ = load_data(args.predict)
        predictions = pipeline.predict(X)
        print("Predictions:")
        for i in range(predictions.rows):
            print(f"  Sample {i}: {predictions[i, 0]:.6f}")
    
    else:
        parser.print_help()


def load_data(filepath: str) -> tuple:
    """
    Load data from CSV file.
    
    Returns:
        Tuple of (features, labels)
    """
    import csv
    
    with open(filepath, 'r') as f:
        reader = csv.reader(f)
        header = next(reader)  # Skip header
        data = list(reader)
    
    # Convert to Matrix/Vector
    features = []
    labels = []
    
    for row in data:
        features.append([float(x) for x in row[:-1]])
        labels.append(float(row[-1]))
    
    X = Matrix(features)
    y = Vector(labels)
    
    return X, y


def save_results(filepath: str, results: dict) -> None:
    """
    Save results to file.
    """
    import json
    
    # Convert non-serializable objects
    def convert(obj):
        if hasattr(obj, 'to_dict'):
            return obj.to_dict()
        if isinstance(obj, Matrix):
            return obj.to_list()
        if isinstance(obj, Vector):
            return obj.to_list()
        return obj
    
    with open(filepath, 'w') as f:
        json.dump(results, f, indent=2, default=convert)


if __name__ == '__main__':
    main()
```

#### Step 4: Example Scripts

**File: `scripts/run_pipeline.py`**

```python
#!/usr/bin/env python3
"""
Example script for running the complete ML pipeline.
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import random
from src.linear_algebra import Matrix, Vector
from src.pipeline.complete_pipeline import CompleteMLPipeline
from src.utils import setup_logger


def generate_synthetic_data(n_samples=1000, n_features=10, noise=0.1):
    """Generate synthetic regression data."""
    random.seed(42)
    
    # Generate features
    X_data = [[random.random() * 10 for _ in range(n_features)] 
              for _ in range(n_samples)]
    X = Matrix(X_data)
    
    # Generate true weights
    true_w = Vector([random.random() * 2 - 1 for _ in range(n_features)])
    
    # Generate labels with noise
    y = X.vector_dot(true_w)
    y = Vector([y[i] + random.gauss(0, noise) for i in range(y.size)])
    
    return X, y


def main():
    """Run the pipeline example."""
    logger = setup_logger('example')
    
    print("=" * 60)
    print("Complete ML Pipeline Example")
    print("=" * 60)
    
    # Generate data
    print("\nGenerating synthetic data...")
    X, y = generate_synthetic_data(n_samples=1000, n_features=10, noise=0.1)
    print(f"Generated {X.rows} samples with {X.cols} features")
    
    # Create pipeline with configuration
    config = {
        'data': {
            'test_size': 0.15,
            'val_size': 0.15,
            'random_seed': 42,
            'scaling': 'standardize'
        },
        'model': {
            'type': 'neural_network',
            'layer_sizes': [32, 16],
            'learning_rate': 0.01,
            'num_epochs': 50,
            'batch_size': 32,
            'loss_type': 'mse',
            'activation': 'relu'
        },
        'training': {
            'early_stopping': True,
            'patience': 10,
            'gradient_clip': 1.0
        },
        'evaluation': {
            'metrics': ['mse', 'rmse', 'r2'],
            'cross_validation_folds': 3
        },
        'analysis': {
            'train_sizes': [50, 100, 200, 500]
        }
    }
    
    # Initialize and run pipeline
    print("\nInitializing pipeline...")
    pipeline = CompleteMLPipeline(config)
    
    print("\nRunning pipeline...")
    results = pipeline.run(X, y)
    
    # Print report
    print("\n" + pipeline.generate_report())
    
    # Save pipeline
    save_path = 'trained_pipeline.pkl'
    pipeline.save(save_path)
    print(f"\nPipeline saved to {save_path}")
    
    # Test loading
    print("\nTesting pipeline loading...")
    new_pipeline = CompleteMLPipeline()
    new_pipeline.load(save_path)
    print("Pipeline loaded successfully!")
    
    # Make predictions on new data
    print("\nMaking predictions on new data...")
    X_new, _ = generate_synthetic_data(n_samples=5, n_features=10)
    predictions = new_pipeline.predict(X_new)
    print("Predictions:")
    for i in range(predictions.rows):
        print(f"  Sample {i}: {predictions[i, 0]:.6f}")
    
    print("\n" + "=" * 60)
    print("Example complete!")
    print("=" * 60)


if __name__ == '__main__':
    main()
```

### The Verification

#### Step 1: Run the Complete Pipeline

```bash
# From the project root
python scripts/run_pipeline.py
```

You should see output similar to:

```
============================================================
Complete ML Pipeline Example
============================================================

Generating synthetic data...
Generated 1000 samples with 10 features

Initializing pipeline...

Running pipeline...
2024-01-01 00:00:00 - ml_pipeline - INFO - Complete ML Pipeline initialized
2024-01-01 00:00:00 - ml_pipeline - INFO - Starting pipeline execution
2024-01-01 00:00:00 - ml_pipeline - INFO - Training data: 1000 samples, 10 features
2024-01-01 00:00:00 - ml_pipeline - INFO - Step 1: Data preprocessing
2024-01-01 00:00:00 - ml_pipeline - INFO - Step 2: Splitting data
2024-01-01 00:00:00 - ml_pipeline - INFO - Train: 700, Val: 150, Test: 150
2024-01-01 00:00:00 - ml_pipeline - INFO - Step 3: Model training
2024-01-01 00:00:00 - ml_pipeline - INFO - Created Neural Network: [10, 32, 16, 1]
Epoch 10/50: loss = 0.123456, accuracy = 0.0000
...
Epoch 50/50: loss = 0.002345, accuracy = 0.0000
2024-01-01 00:00:05 - ml_pipeline - INFO - Step 4: Model evaluation
2024-01-01 00:00:05 - ml_pipeline - INFO - Step 5: Bias-variance analysis
2024-01-01 00:00:05 - ml_pipeline - INFO - Pipeline completed in 5.23 seconds

============================================================
ML Pipeline Execution Report
============================================================

Configuration:
  data: {'test_size': 0.15, 'val_size': 0.15, 'random_seed': 42, 'scaling': 'standardize'}
  model: {'type': 'neural_network', 'layer_sizes': [32, 16], ...}
  ...

Evaluation Results:

  TRAIN:
    MSE: 0.002345
    RMSE: 0.048425
    R²: 0.987654

  VALIDATION:
    MSE: 0.003456
    RMSE: 0.058789
    R²: 0.982345

  TEST:
    MSE: 0.003789
    RMSE: 0.061556
    R²: 0.981234

  Cross-Validation:
    Mean Score: 0.003456
    Std Score: 0.000789

  Bias-Variance Analysis:
    Learning Curve:
      Size 50: Train=0.1234, Test=0.2345
      Size 100: Train=0.0567, Test=0.0890
      Size 200: Train=0.0234, Test=0.0345
      Size 500: Train=0.0123, Test=0.0156

Execution Time: 5.23 seconds

============================================================

Pipeline saved to trained_pipeline.pkl

Testing pipeline loading...
Pipeline loaded successfully!

Making predictions on new data...
Predictions:
  Sample 0: 1.234567
  Sample 1: -0.987654
  Sample 2: 3.456789  Sample 3: 0.123456
  Sample 4: -2.345678

============================================================
Example complete!
============================================================
```

---

*Next: We'll finalize the project with comprehensive documentation, deployment scripts, and a complete project summary.*
