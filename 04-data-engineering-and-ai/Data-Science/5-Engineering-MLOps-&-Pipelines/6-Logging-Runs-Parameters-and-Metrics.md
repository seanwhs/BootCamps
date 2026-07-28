# Part 6: Logging Runs, Parameters, and Metrics

## The Target: Comprehensive Experiment Logging

In this part, we'll implement comprehensive logging for our ML experiments, tracking everything from hyperparameters to model performance metrics. By the end, you'll have a complete experiment tracking system that captures every detail of your training runs.

## The Concept: Complete Experiment Capture

Imagine you're a chef developing a new recipe:
- **Parameters** are your ingredients and measurements (learning rate, batch size, number of trees)
- **Metrics** are the taste test results (accuracy, F1 score, training time)
- **Artifacts** are the actual dishes and photos (model files, plots, confusion matrices)
- **Tags** are your notes about the cooking process (data version, environment, notes)

MLflow captures all of this automatically, so you can recreate your best results at any time.

## The Implementation: Enhanced MLflow Logging

### Step 1: Create Enhanced Training Script with Full Logging

Let's create a comprehensive training script that logs everything:

```bash
cat > models/training/train_model_full.py << 'EOF'
#!/usr/bin/env python
"""
Enhanced MLflow training with full experiment logging.
Captures parameters, metrics, artifacts, and system information.
"""

import sys
import os
import json
import pickle
import logging
import argparse
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional, List, Tuple
import warnings
warnings.filterwarnings('ignore')

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent))

import numpy as np
import pandas as pd
import mlflow
import mlflow.sklearn
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, confusion_matrix, classification_report,
    mean_squared_error, r2_score
)
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
import seaborn as sns

# Import our MLflow utilities
from src.utils.mlflow_utils import get_mlflow_manager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ExperimentLogger:
    """Enhanced experiment logging with MLflow."""
    
    def __init__(self, experiment_name: str, run_name: Optional[str] = None):
        """
        Initialize the experiment logger.
        
        Args:
            experiment_name: Name of the experiment
            run_name: Name of the run (auto-generated if None)
        """
        self.experiment_name = experiment_name
        self.run_name = run_name or f"run_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.manager = get_mlflow_manager()
        self.start_time = time.time()
        
        # Store for later
        self.metrics_history = {}
        self.params_logged = {}
        self.artifacts_logged = []
        
    def __enter__(self):
        """Start the MLflow run."""
        self.run = self.manager.start_run(
            experiment_name=self.experiment_name,
            run_name=self.run_name,
            tags={
                'start_time': datetime.now().isoformat(),
                'run_type': 'training',
                'logger_version': '1.0.0'
            }
        )
        logger.info(f"Started experiment run: {self.run_name}")
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """End the MLflow run with error handling."""
        # Calculate total runtime
        runtime = time.time() - self.start_time
        mlflow.log_metric('total_runtime_seconds', runtime)
        
        # Log any exceptions
        if exc_type is not None:
            mlflow.set_tag('run_status', 'failed')
            mlflow.set_tag('error_type', exc_type.__name__)
            mlflow.log_text(str(exc_val), 'error_log.txt')
            logger.error(f"Run failed with error: {exc_val}")
        else:
            mlflow.set_tag('run_status', 'success')
            logger.info(f"Run completed successfully in {runtime:.2f} seconds")
        
        # End the run
        self.manager.end_run()
    
    def log_dataset_info(self, df: pd.DataFrame, name: str = "dataset"):
        """
        Log comprehensive dataset information.
        
        Args:
            df: DataFrame to analyze
            name: Name of the dataset
        """
        # Basic info
        mlflow.log_param(f"{name}_rows", len(df))
        mlflow.log_param(f"{name}_columns", len(df.columns))
        mlflow.log_param(f"{name}_columns_list", ', '.join(df.columns[:10]) + ('...' if len(df.columns) > 10 else ''))
        
        # Data types
        dtypes = df.dtypes.value_counts().to_dict()
        for dtype, count in dtypes.items():
            mlflow.log_param(f"{name}_dtype_{dtype}", count)
        
        # Missing values
        missing = df.isnull().sum()
        if missing.sum() > 0:
            mlflow.log_param(f"{name}_missing_values", missing.sum())
            mlflow.log_param(f"{name}_missing_columns", ', '.join(missing[missing > 0].index[:5]))
        
        # Statistics for numerical columns
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        if len(numeric_cols) > 0:
            stats = df[numeric_cols].describe()
            
            # Log min, max, mean for first few columns
            for col in numeric_cols[:5]:
                mlflow.log_param(f"{name}_{col}_min", stats.loc['min', col])
                mlflow.log_param(f"{name}_{col}_max", stats.loc['max', col])
                mlflow.log_param(f"{name}_{col}_mean", stats.loc['mean', col])
                mlflow.log_param(f"{name}_{col}_std", stats.loc['std', col])
        
        # Log dataset distribution if label column exists
        if 'label' in df.columns:
            class_counts = df['label'].value_counts()
            for label, count in class_counts.items():
                mlflow.log_param(f"{name}_class_{label}_count", count)
            mlflow.log_param(f"{name}_anomaly_rate", class_counts.get(1, 0) / len(df))
        
        logger.info(f"Logged dataset info for {name}: {len(df)} rows, {len(df.columns)} columns")
    
    def log_model_parameters(self, model_params: Dict[str, Any], prefix: str = ""):
        """
        Log model hyperparameters.
        
        Args:
            model_params: Dictionary of model parameters
            prefix: Prefix for parameter names
        """
        for key, value in model_params.items():
            param_name = f"{prefix}_{key}" if prefix else key
            # Convert complex objects to strings
            if isinstance(value, (list, dict, tuple)):
                mlflow.log_param(param_name, str(value))
            else:
                mlflow.log_param(param_name, value)
        
        logger.info(f"Logged {len(model_params)} model parameters")
    
    def log_training_metrics(self, metrics: Dict[str, float], step: Optional[int] = None):
        """
        Log training metrics with optional step.
        
        Args:
            metrics: Dictionary of metrics
            step: Current training step
        """
        for name, value in metrics.items():
            mlflow.log_metric(name, value, step=step)
            self.metrics_history[name] = value
        
        logger.info(f"Logged {len(metrics)} metrics")
    
    def log_confusion_matrix(self, y_true, y_pred, name: str = "confusion_matrix"):
        """
        Log confusion matrix as an artifact.
        
        Args:
            y_true: True labels
            y_pred: Predicted labels
            name: Name for the artifact
        """
        cm = confusion_matrix(y_true, y_pred)
        
        # Create figure
        fig, ax = plt.subplots(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax)
        ax.set_xlabel('Predicted')
        ax.set_ylabel('True')
        ax.set_title(f'Confusion Matrix - {self.run_name}')
        
        # Save and log
        temp_file = Path(f"/tmp/{name}_{self.run_name}.png")
        plt.savefig(temp_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        mlflow.log_artifact(str(temp_file), artifact_path='plots')
        temp_file.unlink()
        
        logger.info(f"Logged confusion matrix")
    
    def log_classification_report(self, y_true, y_pred, name: str = "classification_report"):
        """
        Log classification report as text and parameters.
        
        Args:
            y_true: True labels
            y_pred: Predicted labels
            name: Name for the artifact
        """
        report = classification_report(y_true, y_pred, output_dict=True)
        
        # Log metrics from report
        for label, metrics in report.items():
            if isinstance(metrics, dict):
                for metric_name, value in metrics.items():
                    mlflow.log_metric(f"{name}_{label}_{metric_name}", value)
            elif label == 'accuracy':
                mlflow.log_metric(f"{name}_accuracy", metrics)
        
        # Save full report as text
        report_text = classification_report(y_true, y_pred)
        mlflow.log_text(report_text, f"{name}.txt")
        
        logger.info(f"Logged classification report")
    
    def log_feature_importance(self, model, feature_names: List[str], top_n: int = 20):
        """
        Log feature importance plots and values.
        
        Args:
            model: Trained model with feature_importances_ attribute
            feature_names: List of feature names
            top_n: Number of top features to display
        """
        if not hasattr(model, 'feature_importances_'):
            logger.warning("Model doesn't have feature_importances_ attribute")
            return
        
        importances = model.feature_importances_
        feature_importance = pd.DataFrame({
            'feature': feature_names,
            'importance': importances
        }).sort_values('importance', ascending=False)
        
        # Log top features
        top_features = feature_importance.head(top_n)
        for idx, row in top_features.iterrows():
            mlflow.log_param(f"feature_importance_{row['feature']}", row['importance'])
        
        # Create plot
        fig, ax = plt.subplots(figsize=(10, 8))
        plt.barh(top_features['feature'][:20], top_features['importance'][:20])
        plt.xlabel('Feature Importance')
        plt.title(f'Top {min(20, len(top_features))} Features - {self.run_name}')
        plt.tight_layout()
        
        # Save and log
        temp_file = Path(f"/tmp/feature_importance_{self.run_name}.png")
        plt.savefig(temp_file, dpi=300, bbox_inches='tight')
        plt.close()
        
        mlflow.log_artifact(str(temp_file), artifact_path='plots')
        temp_file.unlink()
        
        # Save CSV
        temp_csv = Path(f"/tmp/feature_importance_{self.run_name}.csv")
        feature_importance.to_csv(temp_csv, index=False)
        mlflow.log_artifact(str(temp_csv), artifact_path='data')
        temp_csv.unlink()
        
        logger.info(f"Logged feature importance for {len(feature_importance)} features")
    
    def log_model(self, model, model_name: str, registered_name: Optional[str] = None):
        """
        Log model with comprehensive metadata.
        
        Args:
            model: Trained model
            model_name: Name for the model artifact
            registered_name: Name for model registry
        """
        # Log model
        model_uri = mlflow.sklearn.log_model(
            model,
            artifact_path=model_name,
            registered_model_name=registered_name,
            input_example=model.feature_names_in_ if hasattr(model, 'feature_names_in_') else None
        )
        
        # Log model info
        mlflow.set_tag('model_uri', model_uri)
        mlflow.set_tag('model_type', type(model).__name__)
        
        # Log model parameters
        if hasattr(model, 'get_params'):
            params = model.get_params()
            for key, value in params.items():
                if not key.startswith('_'):
                    mlflow.log_param(f"model_{key}", str(value))
        
        logger.info(f"Logged model: {model_name}")
        return model_uri
    
    def log_system_info(self):
        """Log system and environment information."""
        import platform
        import psutil
        
        # System info
        mlflow.set_tag('system_platform', platform.platform())
        mlflow.set_tag('system_processor', platform.processor())
        mlflow.set_tag('system_python', platform.python_version())
        
        # Hardware info
        mlflow.set_tag('cpu_count', psutil.cpu_count())
        mlflow.set_tag('memory_total_gb', psutil.virtual_memory().total / (1024**3))
        
        # GPU info (if available)
        try:
            import torch
            if torch.cuda.is_available():
                mlflow.set_tag('gpu_count', torch.cuda.device_count())
                mlflow.set_tag('gpu_name', torch.cuda.get_device_name(0))
        except ImportError:
            pass
        
        logger.info("Logged system information")
    
    def log_run_summary(self):
        """Log a summary of the run."""
        summary = {
            'run_id': mlflow.active_run().info.run_id,
            'experiment_name': self.experiment_name,
            'run_name': self.run_name,
            'start_time': datetime.fromtimestamp(self.start_time).isoformat(),
            'duration_seconds': time.time() - self.start_time,
            'metrics': self.metrics_history,
            'parameters': self.params_logged
        }
        
        # Save summary
        mlflow.log_dict(summary, 'run_summary.json')
        
        # Print summary
        logger.info("\n" + "=" * 60)
        logger.info("RUN SUMMARY")
        logger.info("=" * 60)
        logger.info(f"Run ID: {summary['run_id']}")
        logger.info(f"Run Name: {summary['run_name']}")
        logger.info(f"Duration: {summary['duration_seconds']:.2f} seconds")
        logger.info("\nKey Metrics:")
        for metric, value in summary['metrics'].items():
            if 'f1' in metric.lower() or 'accuracy' in metric.lower():
                logger.info(f"  {metric}: {value:.4f}")
        logger.info("=" * 60)


def load_and_prepare_data(features_path: str, test_size: float = 0.2, random_state: int = 42):
    """
    Load and prepare data for training.
    
    Returns:
        X_train, X_test, y_train, y_test, feature_names, scaler
    """
    logger.info(f"Loading data from {features_path}")
    df = pd.read_csv(features_path)
    
    # Separate features and target
    X = df.drop(columns=['label', 'timestamp'] if 'timestamp' in df.columns else ['label'])
    y = df['label']
    feature_names = X.columns.tolist()
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state, stratify=y
    )
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Convert back to DataFrame for feature names
    X_train_scaled = pd.DataFrame(X_train_scaled, columns=feature_names)
    X_test_scaled = pd.DataFrame(X_test_scaled, columns=feature_names)
    
    logger.info(f"Data prepared: {len(X_train)} train, {len(X_test)} test samples")
    
    return X_train_scaled, X_test_scaled, y_train, y_test, feature_names, scaler, df


def train_models_full_experiment(
    features_path: str,
    output_path: str,
    experiment_name: str = "Predictive_Maintenance_Full",
    test_size: float = 0.2,
    random_state: int = 42,
    run_name: Optional[str] = None
) -> Dict[str, Any]:
    """
    Run full experiment with comprehensive MLflow logging.
    """
    
    # Start experiment logger
    with ExperimentLogger(experiment_name, run_name) as logger_ctx:
        
        # 1. Load and prepare data
        X_train, X_test, y_train, y_test, feature_names, scaler, df = load_and_prepare_data(
            features_path, test_size, random_state
        )
        
        # 2. Log dataset information
        logger_ctx.log_dataset_info(df, "full_dataset")
        logger_ctx.log_dataset_info(pd.DataFrame(X_train), "training_features")
        logger_ctx.log_dataset_info(pd.DataFrame(y_train, columns=['label']), "training_labels")
        
        # 3. Log system info
        logger_ctx.log_system_info()
        
        # 4. Log data version (from DVC)
        try:
            import subprocess
            dvc_status = subprocess.check_output(['dvc', 'status'], text=True)
            mlflow.log_text(dvc_status, 'dvc_status.txt')
        except:
            logger.warning("Could not get DVC status")
        
        # 5. Define models to train
        models_to_train = {
            'logistic_regression': {
                'model': LogisticRegression(max_iter=1000, random_state=random_state),
                'params': {'max_iter': 1000, 'random_state': random_state}
            },
            'random_forest': {
                'model': RandomForestClassifier(
                    n_estimators=100, 
                    max_depth=10,
                    min_samples_split=5,
                    random_state=random_state,
                    n_jobs=-1
                ),
                'params': {
                    'n_estimators': 100,
                    'max_depth': 10,
                    'min_samples_split': 5,
                    'random_state': random_state
                }
            },
            'gradient_boosting': {
                'model': GradientBoostingClassifier(
                    n_estimators=100,
                    learning_rate=0.1,
                    max_depth=3,
                    random_state=random_state
                ),
                'params': {
                    'n_estimators': 100,
                    'learning_rate': 0.1,
                    'max_depth': 3,
                    'random_state': random_state
                }
            },
            'svm': {
                'model': SVC(
                    kernel='rbf',
                    C=1.0,
                    gamma='scale',
                    probability=True,
                    random_state=random_state
                ),
                'params': {
                    'kernel': 'rbf',
                    'C': 1.0,
                    'gamma': 'scale',
                    'probability': True
                }
            },
            'knn': {
                'model': KNeighborsClassifier(
                    n_neighbors=5,
                    weights='distance',
                    metric='minkowski'
                ),
                'params': {
                    'n_neighbors': 5,
                    'weights': 'distance',
                    'metric': 'minkowski'
                }
            }
        }
        
        # 6. Train and evaluate each model
        results = {}
        best_score = 0
        best_model = None
        best_name = None
        
        for model_name, model_dict in models_to_train.items():
            logger.info(f"\n{'='*60}")
            logger.info(f"Training {model_name}")
            logger.info(f"{'='*60}")
            
            model = model_dict['model']
            
            # Log model parameters
            logger_ctx.log_model_parameters(model_dict['params'], prefix=model_name)
            
            # Train with timing
            start_time = time.time()
            model.fit(X_train, y_train)
            train_time = time.time() - start_time
            
            # Make predictions
            y_pred = model.predict(X_test)
            y_pred_proba = model.predict_proba(X_test)[:, 1] if hasattr(model, 'predict_proba') else None
            
            # Calculate metrics
            metrics = {
                f'{model_name}_accuracy': accuracy_score(y_test, y_pred),
                f'{model_name}_precision': precision_score(y_test, y_pred),
                f'{model_name}_recall': recall_score(y_test, y_pred),
                f'{model_name}_f1': f1_score(y_test, y_pred),
                f'{model_name}_train_time': train_time
            }
            
            if y_pred_proba is not None:
                metrics[f'{model_name}_roc_auc'] = roc_auc_score(y_test, y_pred_proba)
            
            # Log metrics
            logger_ctx.log_training_metrics(metrics)
            
            # Log confusion matrix for this model
            logger_ctx.log_confusion_matrix(y_test, y_pred, name=f"cm_{model_name}")
            
            # Log classification report
            logger_ctx.log_classification_report(y_test, y_pred, name=f"report_{model_name}")
            
            # Log feature importance if available
            if hasattr(model, 'feature_importances_'):
                logger_ctx.log_feature_importance(model, feature_names)
            
            # Log model
            logger_ctx.log_model(
                model, 
                model_name=f"{model_name}_model",
                registered_name=f"predictive_maintenance_{model_name}"
            )
            
            # Store results
            results[model_name] = {
                'model': model,
                'metrics': {k.replace(f'{model_name}_', ''): v for k, v in metrics.items() if k.startswith(model_name)},
                'train_time': train_time
            }
            
            # Track best model
            f1_score_ = metrics[f'{model_name}_f1']
            if f1_score_ > best_score:
                best_score = f1_score_
                best_model = model
                best_name = model_name
                
                # Log best model info
                mlflow.set_tag('best_model_so_far', model_name)
                mlflow.set_tag('best_f1_so_far', best_score)
            
            logger.info(f"{model_name} - F1: {f1_score_:.4f}, Accuracy: {metrics[f'{model_name}_accuracy']:.4f}")
        
        # 7. Log best model summary
        mlflow.set_tag('best_model', best_name)
        mlflow.set_tag('best_f1', best_score)
        
        # Log best model separately
        logger_ctx.log_model(
            best_model,
            model_name="best_model",
            registered_name="predictive_maintenance_best"
        )
        
        # 8. Save best model locally
        model_data = {
            'model': best_model,
            'scaler': scaler,
            'feature_names': feature_names,
            'best_model_name': best_name,
            'best_score': best_score,
            'training_date': datetime.now().isoformat()
        }
        
        with open(output_path, 'wb') as f:
            pickle.dump(model_data, f)
        
        # Save scaler separately
        scaler_path = Path(output_path).parent / 'scaler.pkl'
        with open(scaler_path, 'wb') as f:
            pickle.dump(scaler, f)
        
        # 9. Log final summary
        summary = {
            'best_model': best_name,
            'best_f1': best_score,
            'feature_count': len(feature_names),
            'train_samples': len(X_train),
            'test_samples': len(X_test),
            'models_trained': len(results)
        }
        
        logger_ctx.log_run_summary()
        
        return summary


def main():
    parser = argparse.ArgumentParser(description="Full experiment with MLflow logging")
    parser.add_argument("--features", type=str, default="data/processed/features_48h.csv")
    parser.add_argument("--output", type=str, default="models/registry/best_model.pkl")
    parser.add_argument("--experiment", type=str, default="Predictive_Maintenance_Full")
    parser.add_argument("--run_name", type=str, help="Name for this run")
    parser.add_argument("--test_size", type=float, default=0.2)
    parser.add_argument("--random_state", type=int, default=42)
    
    args = parser.parse_args()
    
    # Run experiment
    results = train_models_full_experiment(
        features_path=args.features,
        output_path=args.output,
        experiment_name=args.experiment,
        test_size=args.test_size,
        random_state=args.random_state,
        run_name=args.run_name
    )
    
    # Print results
    print("\n" + "="*60)
    print("EXPERIMENT COMPLETED SUCCESSFULLY")
    print("="*60)
    print(f"Best Model: {results['best_model']}")
    print(f"Best F1 Score: {results['best_f1']:.4f}")
    print(f"Features Used: {results['feature_count']}")
    print(f"Training Samples: {results['train_samples']}")
    print(f"Test Samples: {results['test_samples']}")
    print("="*60)
    
    # Print MLflow UI command
    print("\nView results in MLflow UI:")
    print("mlflow ui --backend-store-uri ./mlruns")
    print("Then open http://localhost:5000")


if __name__ == "__main__":
    main()
EOF

chmod +x models/training/train_model_full.py
```

### Step 2: Create a Batch Experiment Runner

Now let's create a script to run multiple experiments in batch:

```bash
cat > scripts/run_batch_experiments.py << 'EOF'
#!/usr/bin/env python
"""
Batch experiment runner for hyperparameter tuning and comparison.
Runs multiple experiments and logs them to MLflow.
"""

import sys
import subprocess
import json
import time
from pathlib import Path
from datetime import datetime
import argparse
import itertools
import pandas as pd

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent))


def generate_experiment_configs(base_config: dict, param_grid: dict):
    """
    Generate experiment configurations from parameter grid.
    
    Args:
        base_config: Base configuration (fixed parameters)
        param_grid: Dictionary of parameter lists to vary
        
    Returns:
        List of configuration dictionaries
    """
    # Get all parameter combinations
    param_names = list(param_grid.keys())
    param_values = list(param_grid.values())
    combinations = list(itertools.product(*param_values))
    
    configs = []
    for combo in combinations:
        config = base_config.copy()
        for name, value in zip(param_names, combo):
            config[name] = value
        configs.append(config)
    
    return configs


def run_experiment(config: dict):
    """
    Run a single experiment with given configuration.
    
    Args:
        config: Configuration dictionary
        
    Returns:
        Dictionary with experiment results
    """
    # Build command
    cmd = [
        "python", "models/training/train_model_full.py",
        "--features", config['features_path'],
        "--output", config['output_path'],
        "--experiment", config['experiment_name'],
        "--test_size", str(config['test_size']),
        "--random_state", str(config['random_state'])
    ]
    
    if 'run_name' in config:
        cmd.extend(["--run_name", config['run_name']])
    
    # Run experiment
    print(f"\n{'='*60}")
    print(f"Running experiment: {config.get('run_name', 'unnamed')}")
    print(f"{'='*60}")
    print(f"Command: {' '.join(cmd)}")
    
    start_time = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True)
    duration = time.time() - start_time
    
    # Parse output for results
    results = {
        'config': config,
        'duration': duration,
        'success': result.returncode == 0,
        'output': result.stdout,
        'error': result.stderr
    }
    
    if result.returncode == 0:
        print(f"✓ Experiment completed in {duration:.2f} seconds")
    else:
        print(f"✗ Experiment failed in {duration:.2f} seconds")
        print(f"Error: {result.stderr[:200]}...")
    
    return results


def run_batch_experiments(config_file: str = None, param_grid_file: str = None):
    """
    Run batch experiments from configuration files.
    
    Args:
        config_file: JSON file with base configuration
        param_grid_file: JSON file with parameter grid
    """
    # Load configurations
    if config_file and Path(config_file).exists():
        with open(config_file, 'r') as f:
            base_config = json.load(f)
    else:
        base_config = {
            'features_path': 'data/processed/features_48h.csv',
            'output_path': 'models/registry/model.pkl',
            'experiment_name': 'Batch_Experiment',
            'test_size': 0.2,
            'random_state': 42
        }
    
    if param_grid_file and Path(param_grid_file).exists():
        with open(param_grid_file, 'r') as f:
            param_grid = json.load(f)
    else:
        param_grid = {
            'test_size': [0.15, 0.2, 0.25],
            'random_state': [42, 123, 456]
        }
    
    # Generate configurations
    configs = generate_experiment_configs(base_config, param_grid)
    
    # Add unique run names
    for i, config in enumerate(configs):
        config['run_name'] = f"exp_{i+1:03d}_{config.get('test_size', 0.2):.2f}_rs{config.get('random_state', 42)}"
        config['output_path'] = f"models/registry/model_{config['run_name']}.pkl"
    
    print(f"\n{'='*60}")
    print(f"BATCH EXPERIMENT RUNNER")
    print(f"{'='*60}")
    print(f"Total experiments to run: {len(configs)}")
    print(f"Experiment parameters: {list(param_grid.keys())}")
    print(f"{'='*60}")
    
    # Run all experiments
    results = []
    total_start = time.time()
    
    for i, config in enumerate(configs, 1):
        print(f"\n[{i}/{len(configs)}] Running experiment {i}...")
        result = run_experiment(config)
        results.append(result)
    
    total_duration = time.time() - total_start
    
    # Print summary
    print(f"\n{'='*60}")
    print("BATCH EXPERIMENT SUMMARY")
    print(f"{'='*60}")
    print(f"Total experiments: {len(results)}")
    print(f"Successful: {sum(1 for r in results if r['success'])}")
    print(f"Failed: {sum(1 for r in results if not r['success'])}")
    print(f"Total duration: {total_duration:.2f} seconds")
    
    # Save results
    output_file = f"batch_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    print(f"\nResults saved to: {output_file}")
    
    # Create summary dataframe
    summary_data = []
    for result in results:
        if result['success']:
            summary_data.append({
                'run_name': result['config'].get('run_name'),
                'success': result['success'],
                'duration': result['duration'],
                'test_size': result['config'].get('test_size'),
                'random_state': result['config'].get('random_state')
            })
    
    if summary_data:
        df = pd.DataFrame(summary_data)
        print("\nSummary:")
        print(df.to_string(index=False))
    
    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run batch experiments")
    parser.add_argument("--config", type=str, help="JSON file with base configuration")
    parser.add_argument("--param_grid", type=str, help="JSON file with parameter grid")
    
    args = parser.parse_args()
    
    run_batch_experiments(args.config, args.param_grid)
EOF

chmod +x scripts/run_batch_experiments.py
```

### Step 3: Create Hyperparameter Sweep Configuration

```bash
cat > configs/param_grid.json << 'EOF'
{
  "test_size": [0.15, 0.2, 0.25],
  "random_state": [42, 123, 456]
}
EOF

cat > configs/base_config.json << 'EOF'
{
  "features_path": "data/processed/features_48h.csv",
  "output_path": "models/registry/model.pkl",
  "experiment_name": "Hyperparameter_Sweep",
  "test_size": 0.2,
  "random_state": 42
}
EOF
```

### Step 4: Create Experiment Analysis Tools

```bash
cat > scripts/analyze_experiments.py << 'EOF'
#!/usr/bin/env python
"""
Analyze MLflow experiment results and generate insights.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import mlflow
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import json
import argparse


def analyze_experiments(experiment_name: str, output_dir: str = "reports"):
    """
    Analyze all runs in an experiment.
    
    Args:
        experiment_name: Name of the experiment to analyze
        output_dir: Directory to save reports
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Get experiment
    exp = mlflow.get_experiment_by_name(experiment_name)
    if exp is None:
        print(f"Experiment not found: {experiment_name}")
        return
    
    print(f"\n{'='*60}")
    print(f"ANALYZING EXPERIMENT: {experiment_name}")
    print(f"{'='*60}")
    
    # Get all runs
    runs = mlflow.search_runs(
        experiment_ids=[exp.experiment_id],
        order_by=["start_time DESC"]
    )
    
    if runs.empty:
        print("No runs found in this experiment")
        return
    
    print(f"Total runs: {len(runs)}")
    
    # Extract metrics
    metric_cols = [col for col in runs.columns if col.startswith('metrics.')]
    param_cols = [col for col in runs.columns if col.startswith('params.')]
    tag_cols = [col for col in runs.columns if col.startswith('tags.')]
    
    # 1. Summary statistics
    print("\n" + "-"*40)
    print("SUMMARY STATISTICS")
    print("-"*40)
    
    # Find best f1 score across all models
    f1_cols = [col for col in metric_cols if 'f1' in col.lower()]
    if f1_cols:
        f1_values = []
        for col in f1_cols:
            values = runs[col].dropna()
            if not values.empty:
                f1_values.extend(values.tolist())
        
        if f1_values:
            print(f"Best F1 Score: {max(f1_values):.4f}")
            print(f"Mean F1 Score: {np.mean(f1_values):.4f}")
            print(f"Std F1 Score: {np.std(f1_values):.4f}")
    
    # 2. Best run
    print("\n" + "-"*40)
    print("BEST PERFORMING RUN")
    print("-"*40)
    
    best_f1 = -1
    best_run = None
    
    for idx, run in runs.iterrows():
        for col in f1_cols:
            if not pd.isna(run[col]) and run[col] > best_f1:
                best_f1 = run[col]
                best_run = run
    
    if best_run is not None:
        print(f"Run Name: {best_run.get('run_name', 'N/A')}")
        print(f"Run ID: {best_run.get('run_id', 'N/A')}")
        print(f"Best F1: {best_f1:.4f}")
        
        # Print parameters of best run
        print("\nParameters:")
        for col in param_cols:
            if not pd.isna(best_run[col]):
                param_name = col.replace('params.', '')
                print(f"  {param_name}: {best_run[col]}")
        
        # Print metrics of best run
        print("\nMetrics:")
        for col in metric_cols:
            if not pd.isna(best_run[col]):
                metric_name = col.replace('metrics.', '')
                if 'f1' in metric_name.lower() or 'accuracy' in metric_name.lower():
                    print(f"  {metric_name}: {best_run[col]:.4f}")
    
    # 3. Create visualizations
    print("\n" + "-"*40)
    print("GENERATING VISUALIZATIONS")
    print("-"*40)
    
    # Plot 1: F1 distribution
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    if f1_cols:
        # Distribution of F1 scores
        all_f1 = []
        labels = []
        for col in f1_cols:
            values = runs[col].dropna()
            if not values.empty:
                all_f1.extend(values)
                labels.extend([col.replace('metrics.', '')] * len(values))
        
        if all_f1:
            f1_df = pd.DataFrame({'f1': all_f1, 'model': labels})
            sns.boxplot(data=f1_df, x='model', y='f1', ax=axes[0, 0])
            axes[0, 0].set_title('F1 Score Distribution by Model')
            axes[0, 0].set_xticklabels(axes[0, 0].get_xticklabels(), rotation=45)
    
    # Plot 2: Accuracy vs F1
    acc_cols = [col for col in metric_cols if 'accuracy' in col.lower()]
    if acc_cols and f1_cols:
        for acc_col in acc_cols:
            for f1_col in f1_cols:
                # Check if they are from the same model
                acc_model = acc_col.replace('metrics.', '').replace('_accuracy', '')
                f1_model = f1_col.replace('metrics.', '').replace('_f1', '')
                if acc_model == f1_model:
                    axes[0, 1].scatter(runs[acc_col], runs[f1_col], alpha=0.6, label=acc_model)
        
        axes[0, 1].set_xlabel('Accuracy')
        axes[0, 1].set_ylabel('F1 Score')
        axes[0, 1].set_title('Accuracy vs F1 Score')
        axes[0, 1].legend()
    
    # Plot 3: Training time
    time_cols = [col for col in metric_cols if 'time' in col.lower()]
    if time_cols:
        for col in time_cols:
            values = runs[col].dropna()
            if not values.empty:
                axes[1, 0].hist(values, alpha=0.5, label=col.replace('metrics.', ''), bins=20)
        axes[1, 0].set_xlabel('Training Time (seconds)')
        axes[1, 0].set_ylabel('Frequency')
        axes[1, 0].set_title('Training Time Distribution')
        axes[1, 0].legend()
    
    # Plot 4: Correlation between parameters and metrics
    if len(param_cols) > 0 and len(metric_cols) > 0:
        numeric_params = []
        for col in param_cols:
            try:
                pd.to_numeric(runs[col])
                numeric_params.append(col)
            except:
                pass
        
        if numeric_params and f1_cols:
            # Select a representative f1 metric
            f1_col = f1_cols[0] if f1_cols else None
            if f1_col:
                corr_data = runs[numeric_params + [f1_col]].corr()
                sns.heatmap(corr_data, annot=True, fmt='.2f', cmap='coolwarm', ax=axes[1, 1])
                axes[1, 1].set_title('Parameter Correlation with F1')
    
    plt.tight_layout()
    plt.savefig(output_dir / f'{experiment_name}_analysis.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"Visualization saved to: {output_dir / f'{experiment_name}_analysis.png'}")
    
    # 4. Save detailed report
    report = {
        'experiment_name': experiment_name,
        'total_runs': len(runs),
        'analysis_date': datetime.now().isoformat(),
        'best_run': {
            'run_id': best_run.get('run_id') if best_run is not None else None,
            'run_name': best_run.get('run_name') if best_run is not None else None,
            'best_f1': best_f1
        },
        'metrics_summary': {
            col: {
                'mean': runs[col].mean(),
                'std': runs[col].std(),
                'min': runs[col].min(),
                'max': runs[col].max()
            } for col in metric_cols if not runs[col].isna().all()
        }
    }
    
    with open(output_dir / f'{experiment_name}_report.json', 'w') as f:
        json.dump(report, f, indent=2, default=str)
    
    print(f"Report saved to: {output_dir / f'{experiment_name}_report.json'}")
    
    # 5. Save runs data
    runs.to_csv(output_dir / f'{experiment_name}_runs.csv', index=False)
    print(f"Runs data saved to: {output_dir / f'{experiment_name}_runs.csv'}")
    
    print(f"\n{'='*60}")
    print("ANALYSIS COMPLETE")
    print(f"{'='*60}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Analyze MLflow experiments")
    parser.add_argument("--experiment", type=str, default="Predictive_Maintenance_Full",
                       help="Experiment name to analyze")
    parser.add_argument("--output", type=str, default="reports",
                       help="Output directory for reports")
    
    args = parser.parse_args()
    
    analyze_experiments(args.experiment, args.output)
EOF

chmod +x scripts/analyze_experiments.py
```

### Step 5: Run the Enhanced Training

```bash
# Run a single comprehensive experiment
python models/training/train_model_full.py \
    --features data/processed/features_48h.csv \
    --output models/registry/best_model.pkl \
    --experiment "Predictive_Maintenance_Full" \
    --run_name "baseline_run_48h"

# Run a batch of experiments
python scripts/run_batch_experiments.py \
    --config configs/base_config.json \
    --param_grid configs/param_grid.json

# Analyze the results
python scripts/analyze_experiments.py \
    --experiment "Hyperparameter_Sweep" \
    --output reports
```

## The Verification: Testing Enhanced Logging

### Verification 1: Check MLflow UI

```bash
# Start MLflow UI
mlflow ui --backend-store-uri ./mlruns

# Open http://localhost:5000 in your browser
# You should see:
# - Comprehensive parameter list
# - All metrics with nice plots
# - Artifacts including confusion matrices and feature importance plots
```

### Verification 2: Verify Artifacts

```bash
# Check what artifacts were logged
python -c "
import mlflow
client = mlflow.tracking.MlflowClient()

# Get latest run
runs = client.search_runs(experiment_ids=['0'], max_results=1)
if runs:
    run_id = runs[0].info.run_id
    artifacts = client.list_artifacts(run_id)
    print('Artifacts:')
    for artifact in artifacts:
        print(f'  - {artifact.path}')
"
```

### Verification 3: Compare Experiments

```bash
# Run multiple experiments and compare
python scripts/compare_experiments.py \
    --experiments "Predictive_Maintenance_Full" "Hyperparameter_Sweep" \
    --metric f1 \
    --output reports
```

## What We've Accomplished

You now have a comprehensive experiment tracking system that:

1. **Logs detailed dataset information** (shape, types, missing values, distributions)
2. **Captures model parameters** and hyperparameters
3. **Tracks multiple metrics** (accuracy, precision, recall, F1, ROC-AUC)
4. **Logs artifacts** (confusion matrices, feature importance plots)
5. **Records system information** (CPU, memory, GPU)
6. **Runs batch experiments** with hyperparameter sweeps
7. **Analyzes and compares** experiments automatically

## Next Steps

In Part 7, we'll:
- Implement experiment comparison and selection
- Build the model registry
- Manage model lifecycle (Staging → Production)
- Set up automatic model promotion

---

*End of Part 6: Logging Runs, Parameters, and Metrics*
