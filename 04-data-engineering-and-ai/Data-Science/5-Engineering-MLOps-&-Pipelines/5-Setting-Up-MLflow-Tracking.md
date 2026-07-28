# Phase 2: Experiment Tracking & Model Registry
## Part 5: Setting Up MLflow Tracking

## The Target: MLflow Infrastructure Setup

In this part, we'll set up MLflow for experiment tracking, configure the tracking server, and establish the foundation for logging all our machine learning experiments. By the end, you'll have a fully functional MLflow tracking system integrated with your DVC pipeline.

## The Concept: MLflow as Your ML Control Center

Think of MLflow like a flight control tower for your machine learning experiments:
- **Tracking** logs every flight (experiment) - its path (parameters), speed (metrics), and payload (artifacts)
- **Registry** manages which planes (models) are ready for takeoff (production)
- **Projects** provide the standard cockpit layout (reproducible environments)

Every experiment gets a unique ID, and you can compare all your flights to find the best performing one.

## The Implementation: MLflow Setup

### Step 1: Install and Configure MLflow

We already added MLflow to our requirements, but let's ensure it's properly installed and configured:

```bash
# Ensure MLflow is installed
pip install mlflow==2.4.1

# Verify installation
mlflow --version

# Create MLflow directories
mkdir -p mlruns
mkdir -p mlflow_artifacts
```

### Step 2: Create MLflow Configuration

Create a comprehensive MLflow configuration file:

```bash
cat > mlflow_config.yaml << 'EOF'
# MLflow Configuration
tracking:
  # Use file-based tracking for development
  # For production, use remote server (PostgreSQL + S3)
  uri: file:./mlruns
  # Alternative: http://localhost:5000 for remote server
  
artifacts:
  # Where to store large artifacts (models, plots, etc.)
  default_location: ./mlflow_artifacts
  # For production, use S3/GCS: s3://your-bucket/mlflow-artifacts
  
experiments:
  # Default experiment name
  default: Predictive_Maintenance_Default
  
  # Experiment naming convention
  name_template: "{model_type}_{dataset_size}_{timestamp}"
  
logging:
  # What to log by default
  log_models: true
  log_datasets: true
  log_code: true
  log_env: true
  
  # Tags to automatically add
  tags:
    project: predictive_maintenance
    team: mlops_series
    environment: development

model_registry:
  # Registry configuration
  location: ./mlruns  # File-based registry
  # For production: use remote server
  
  # Stage transition rules
  stages:
    - Staging
    - Production
    - Archived
  
  # Required approvals (if using team workflow)
  require_approval: false
EOF
```

### Step 3: Create MLflow Utility Module

Create a reusable MLflow wrapper module:

```bash
cat > src/utils/mlflow_utils.py << 'EOF'
"""
MLflow utility functions for consistent experiment tracking.
Provides wrappers for common MLflow operations with automatic
logging of code, environment, and parameters.
"""

import mlflow
import mlflow.sklearn
import os
import yaml
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, List
import pandas as pd
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class MLflowManager:
    """Centralized MLflow experiment management."""
    
    def __init__(self, tracking_uri: Optional[str] = None):
        """
        Initialize MLflow manager.
        
        Args:
            tracking_uri: MLflow tracking URI (default: from env or file)
        """
        # Load configuration
        config_path = Path("mlflow_config.yaml")
        if config_path.exists():
            with open(config_path, 'r') as f:
                self.config = yaml.safe_load(f)
        else:
            self.config = {}
        
        # Set tracking URI
        self.tracking_uri = tracking_uri or self.config.get('tracking', {}).get(
            'uri', 'file:./mlruns'
        )
        mlflow.set_tracking_uri(self.tracking_uri)
        
        # Set artifact location
        artifact_location = self.config.get('artifacts', {}).get(
            'default_location', './mlflow_artifacts'
        )
        os.makedirs(artifact_location, exist_ok=True)
        
        logger.info(f"MLflow initialized with tracking URI: {self.tracking_uri}")
        logger.info(f"Artifact location: {artifact_location}")
    
    def create_experiment(
        self, 
        experiment_name: str, 
        tags: Optional[Dict[str, str]] = None
    ) -> str:
        """
        Create a new experiment or get existing one.
        
        Args:
            experiment_name: Name of the experiment
            tags: Tags to add to the experiment
            
        Returns:
            Experiment ID
        """
        # Check if experiment exists
        experiment = mlflow.get_experiment_by_name(experiment_name)
        
        if experiment is None:
            # Create new experiment
            experiment_id = mlflow.create_experiment(
                experiment_name,
                tags=tags
            )
            logger.info(f"Created new experiment: {experiment_name} (ID: {experiment_id})")
        else:
            experiment_id = experiment.experiment_id
            logger.info(f"Using existing experiment: {experiment_name} (ID: {experiment_id})")
        
        return experiment_id
    
    def start_run(
        self, 
        experiment_name: str = None,
        run_name: str = None,
        tags: Optional[Dict[str, str]] = None,
        log_code: bool = True,
        log_env: bool = True
    ) -> mlflow.ActiveRun:
        """
        Start a new MLflow run.
        
        Args:
            experiment_name: Name of the experiment
            run_name: Name of the run (auto-generated if None)
            tags: Tags to add to the run
            log_code: Whether to log code versions
            log_env: Whether to log environment
            
        Returns:
            Active MLflow run context
        """
        # Set experiment
        if experiment_name:
            experiment_id = self.create_experiment(experiment_name)
            mlflow.set_experiment(experiment_name)
        
        # Generate run name if not provided
        if run_name is None:
            run_name = f"run_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        # Add default tags
        default_tags = {
            'project': 'predictive_maintenance',
            'environment': os.getenv('MLFLOW_ENV', 'development'),
            'user': os.getenv('USER', 'unknown')
        }
        
        if tags:
            default_tags.update(tags)
        
        # Start run
        run = mlflow.start_run(
            run_name=run_name,
            tags=default_tags
        )
        
        # Log code version if enabled
        if log_code:
            self._log_code_info()
        
        # Log environment if enabled
        if log_env:
            self._log_environment()
        
        logger.info(f"Started run: {run.info.run_id} - {run_name}")
        return run
    
    def log_params_from_dict(self, params: Dict[str, Any]):
        """
        Log multiple parameters from a dictionary.
        
        Args:
            params: Dictionary of parameters to log
        """
        for key, value in params.items():
            # Convert non-string values to strings
            mlflow.log_param(key, str(value))
        logger.info(f"Logged {len(params)} parameters")
    
    def log_metrics_from_dict(self, metrics: Dict[str, float], step: Optional[int] = None):
        """
        Log multiple metrics from a dictionary.
        
        Args:
            metrics: Dictionary of metrics to log
            step: Training step (for iterative metrics)
        """
        for key, value in metrics.items():
            mlflow.log_metric(key, value, step=step)
        logger.info(f"Logged {len(metrics)} metrics")
    
    def log_model(
        self,
        model,
        model_name: str,
        model_type: str = 'sklearn',
        registered_model_name: Optional[str] = None,
        **kwargs
    ):
        """
        Log a model with MLflow.
        
        Args:
            model: Trained model object
            model_name: Name for the model artifact
            model_type: Type of model (sklearn, pytorch, tensorflow, etc.)
            registered_model_name: Name for model registry
            **kwargs: Additional arguments for model logging
        """
        # Map model type to MLflow flavor
        flavor_map = {
            'sklearn': mlflow.sklearn,
            'pytorch': mlflow.pytorch,
            'tensorflow': mlflow.tensorflow,
            'xgboost': mlflow.xgboost,
            'lightgbm': mlflow.lightgbm
        }
        
        flavor = flavor_map.get(model_type.lower())
        if flavor is None:
            logger.warning(f"Unsupported model type: {model_type}. Using default.")
            flavor = mlflow.sklearn
        
        # Log model
        model_uri = flavor.log_model(
            model,
            artifact_path=model_name,
            registered_model_name=registered_model_name,
            **kwargs
        )
        
        logger.info(f"Model logged as: {model_uri}")
        return model_uri
    
    def log_artifacts(self, local_dir: str, artifact_path: str = None):
        """
        Log artifacts from a local directory.
        
        Args:
            local_dir: Local directory containing artifacts
            artifact_path: Path within the artifact store
        """
        mlflow.log_artifacts(local_dir, artifact_path=artifact_path)
        logger.info(f"Logged artifacts from {local_dir}")
    
    def log_dataset(self, df: pd.DataFrame, dataset_name: str, format: str = 'csv'):
        """
        Log a dataset as an artifact.
        
        Args:
            df: DataFrame to log
            dataset_name: Name for the dataset
            format: Format to save (csv, parquet, json)
        """
        # Create temporary directory
        import tempfile
        with tempfile.TemporaryDirectory() as tmpdir:
            file_path = Path(tmpdir) / f"{dataset_name}.{format}"
            
            # Save dataset
            if format == 'csv':
                df.to_csv(file_path, index=False)
            elif format == 'parquet':
                df.to_parquet(file_path, index=False)
            elif format == 'json':
                df.to_json(file_path, orient='records')
            else:
                raise ValueError(f"Unsupported format: {format}")
            
            # Log as artifact
            self.log_artifacts(tmpdir, artifact_path='datasets')
            
            # Log dataset info as parameters
            mlflow.log_param(f"{dataset_name}_rows", len(df))
            mlflow.log_param(f"{dataset_name}_columns", len(df.columns))
    
    def _log_code_info(self):
        """Log code version and commit hash."""
        import subprocess
        
        try:
            # Get git commit hash
            commit_hash = subprocess.check_output(
                ['git', 'rev-parse', 'HEAD'],
                text=True
            ).strip()
            
            # Get current branch
            branch = subprocess.check_output(
                ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
                text=True
            ).strip()
            
            # Log as tags
            mlflow.set_tag('git_commit', commit_hash)
            mlflow.set_tag('git_branch', branch)
            
            logger.info(f"Logged code info: {branch}@{commit_hash[:8]}")
        except Exception as e:
            logger.warning(f"Could not log code info: {e}")
    
    def _log_environment(self):
        """Log environment information."""
        import platform
        import sys
        
        # Log system info
        mlflow.set_tag('python_version', sys.version)
        mlflow.set_tag('platform', platform.platform())
        
        # Log installed packages (if possible)
        try:
            import pkg_resources
            packages = {pkg.key: pkg.version for pkg in pkg_resources.working_set}
            with open('requirements.txt', 'r') as f:
                requirements = f.read()
            mlflow.log_text(requirements, 'requirements.txt')
        except Exception as e:
            logger.warning(f"Could not log environment: {e}")
    
    def end_run(self):
        """End the current run."""
        mlflow.end_run()
        logger.info("Ended MLflow run")
    
    def load_model(self, model_uri: str):
        """
        Load a model from MLflow.
        
        Args:
            model_uri: URI of the model to load
            
        Returns:
            Loaded model
        """
        return mlflow.sklearn.load_model(model_uri)
    
    def get_latest_run_metrics(self, experiment_name: str) -> pd.DataFrame:
        """
        Get latest metrics for an experiment.
        
        Args:
            experiment_name: Name of the experiment
            
        Returns:
            DataFrame with run metrics
        """
        # Get experiment
        experiment = mlflow.get_experiment_by_name(experiment_name)
        if experiment is None:
            logger.warning(f"Experiment not found: {experiment_name}")
            return pd.DataFrame()
        
        # Query runs
        runs = mlflow.search_runs(
            experiment_ids=[experiment.experiment_id],
            order_by=["start_time DESC"],
            max_results=10
        )
        
        return runs
    
    @staticmethod
    def get_ui_url(tracking_uri: str = None) -> str:
        """
        Get the URL for the MLflow UI.
        
        Args:
            tracking_uri: Tracking URI (default: from config)
            
        Returns:
            URL for the MLflow UI
        """
        if tracking_uri is None:
            config_path = Path("mlflow_config.yaml")
            if config_path.exists():
                with open(config_path, 'r') as f:
                    config = yaml.safe_load(f)
                tracking_uri = config.get('tracking', {}).get('uri', 'file:./mlruns')
        
        if tracking_uri.startswith('http'):
            return tracking_uri.replace('api', '')  # Remove /api if present
        else:
            return "http://localhost:5000"  # Default local UI


# Singleton instance
_default_manager = None


def get_mlflow_manager() -> MLflowManager:
    """Get singleton MLflow manager instance."""
    global _default_manager
    if _default_manager is None:
        _default_manager = MLflowManager()
    return _default_manager


# Convenience functions
def log_run(func):
    """Decorator to automatically log a function as an MLflow run."""
    def wrapper(*args, **kwargs):
        manager = get_mlflow_manager()
        with manager.start_run():
            result = func(*args, **kwargs)
            return result
    return wrapper
EOF
```

### Step 4: Create MLflow Tracking Server Script

For development, we can run MLflow locally:

```bash
cat > scripts/start_mlflow_server.sh << 'EOF'
#!/bin/bash
# Start MLflow tracking server

# Configuration
MLFLOW_PORT=${MLFLOW_PORT:-5000}
MLFLOW_HOST=${MLFLOW_HOST:-127.0.0.1}
MLFLOW_BACKEND_STORE_URI=${MLFLOW_BACKEND_STORE_URI:-./mlruns}
MLFLOW_ARTIFACT_ROOT=${MLFLOW_ARTIFACT_ROOT:-./mlflow_artifacts}

echo "Starting MLflow tracking server..."
echo "  Host: $MLFLOW_HOST"
echo "  Port: $MLFLOW_PORT"
echo "  Backend store: $MLFLOW_BACKEND_STORE_URI"
echo "  Artifact root: $MLFLOW_ARTIFACT_ROOT"

# Create directories
mkdir -p $MLFLOW_BACKEND_STORE_URI
mkdir -p $MLFLOW_ARTIFACT_ROOT

# Start server
mlflow server \
    --host $MLFLOW_HOST \
    --port $MLFLOW_PORT \
    --backend-store-uri $MLFLOW_BACKEND_STORE_URI \
    --default-artifact-root $MLFLOW_ARTIFACT_ROOT \
    --workers 4

# Note: For production, use:
# --backend-store-uri postgresql://user:pass@host:port/db
# --default-artifact-root s3://your-bucket/mlflow-artifacts
EOF

chmod +x scripts/start_mlflow_server.sh
```

### Step 5: Create a Test Experiment

Let's create a test script to verify MLflow is working:

```bash
cat > tests/test_mlflow.py << 'EOF'
#!/usr/bin/env python
"""
Test script to verify MLflow integration.
"""

import sys
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.utils.mlflow_utils import get_mlflow_manager
import mlflow
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score


def test_mlflow_tracking():
    """Test basic MLflow tracking functionality."""
    
    print("Testing MLflow tracking...")
    
    # Get manager
    manager = get_mlflow_manager()
    
    # Create experiment
    experiment_name = "test_experiment"
    manager.create_experiment(experiment_name)
    
    # Start a run
    with manager.start_run(
        experiment_name=experiment_name,
        run_name="test_run",
        tags={'test': 'true'}
    ):
        # Log parameters
        params = {
            'n_estimators': 100,
            'max_depth': 10,
            'test_size': 0.2,
            'random_state': 42
        }
        manager.log_params_from_dict(params)
        
        # Create dummy data
        X_train = np.random.rand(100, 5)
        y_train = np.random.randint(0, 2, 100)
        X_test = np.random.rand(20, 5)
        y_test = np.random.randint(0, 2, 20)
        
        # Train a model
        model = RandomForestClassifier(**params)
        model.fit(X_train, y_train)
        
        # Make predictions
        y_pred = model.predict(X_test)
        
        # Log metrics
        metrics = {
            'accuracy': accuracy_score(y_test, y_pred),
            'f1_score': f1_score(y_test, y_pred)
        }
        manager.log_metrics_from_dict(metrics)
        
        # Log model
        manager.log_model(
            model,
            model_name='test_model',
            model_type='sklearn'
        )
        
        print("Test run completed successfully!")
        print(f"Run ID: {mlflow.active_run().info.run_id}")
        print(f"Parameters: {params}")
        print(f"Metrics: {metrics}")
    
    # Verify run was logged
    runs = manager.get_latest_run_metrics(experiment_name)
    print(f"\nLatest runs in experiment '{experiment_name}':")
    print(runs[['run_id', 'params.n_estimators', 'metrics.accuracy']] if not runs.empty else "No runs found")
    
    return True


if __name__ == "__main__":
    # Set tracking URI to local
    mlflow.set_tracking_uri("file:./mlruns")
    
    success = test_mlflow_tracking()
    sys.exit(0 if success else 1)
EOF

chmod +x tests/test_mlflow.py

# Run the test
python tests/test_mlflow.py
```

### Step 6: Integrate MLflow with DVC Pipeline

Now let's update our training script to use MLflow:

```bash
# Update the training script with MLflow integration
cat > models/training/train_model_mlflow.py << 'EOF'
#!/usr/bin/env python
"""
MLflow-integrated model training for predictive maintenance.
Logs all parameters, metrics, and artifacts to MLflow.
"""

import sys
import pandas as pd
import numpy as np
from pathlib import Path
import argparse
import logging
import json
import pickle

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.utils.mlflow_utils import get_mlflow_manager
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from sklearn.preprocessing import StandardScaler
import mlflow

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def train_with_mlflow(
    features_path: str,
    model_output_path: str,
    experiment_name: str = "Predictive_Maintenance",
    test_size: float = 0.2,
    random_state: int = 42
) -> dict:
    """
    Train and log model with MLflow tracking.
    """
    
    # Initialize MLflow manager
    manager = get_mlflow_manager()
    
    # Load data
    logger.info(f"Loading features from {features_path}")
    df = pd.read_csv(features_path)
    
    # Prepare features and target
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
    
    # Get dataset info
    dataset_info = {
        'samples': len(df),
        'features': len(feature_names),
        'train_samples': len(X_train),
        'test_samples': len(X_test),
        'anomaly_rate': y.mean()
    }
    
    # Start MLflow run
    with manager.start_run(
        experiment_name=experiment_name,
        run_name=f"train_{Path(features_path).stem}",
        tags={
            'dataset': Path(features_path).stem,
            'data_version': 'v1.0.0'  # Could be fetched from DVC
        }
    ):
        # Log dataset info
        manager.log_params_from_dict({
            'dataset_info': json.dumps(dataset_info),
            'test_size': test_size,
            'random_state': random_state
        })
        
        # Log feature names
        mlflow.log_param('feature_names', ','.join(feature_names[:10]) + '...')
        
        # Train multiple models
        models = {
            'logistic_regression': LogisticRegression(max_iter=1000, random_state=random_state),
            'random_forest': RandomForestClassifier(n_estimators=100, random_state=random_state, n_jobs=-1),
            'gradient_boosting': GradientBoostingClassifier(n_estimators=100, random_state=random_state)
        }
        
        results = {}
        best_score = 0
        best_model = None
        best_name = None
        
        for name, model in models.items():
            logger.info(f"Training {name}...")
            
            # Train model
            model.fit(X_train_scaled, y_train)
            
            # Make predictions
            y_pred = model.predict(X_test_scaled)
            y_pred_proba = model.predict_proba(X_test_scaled)[:, 1] if hasattr(model, 'predict_proba') else None
            
            # Calculate metrics
            metrics = {
                'accuracy': accuracy_score(y_test, y_pred),
                'precision': precision_score(y_test, y_pred),
                'recall': recall_score(y_test, y_pred),
                'f1': f1_score(y_test, y_pred)
            }
            
            if y_pred_proba is not None:
                metrics['roc_auc'] = roc_auc_score(y_test, y_pred_proba)
            
            # Log metrics with prefix
            for metric_name, value in metrics.items():
                mlflow.log_metric(f"{name}_{metric_name}", value)
            
            # Log model
            manager.log_model(
                model,
                model_name=f"{name}_model",
                model_type='sklearn'
            )
            
            results[name] = {
                'model': model,
                'metrics': metrics,
                'predictions': y_pred
            }
            
            logger.info(f"{name} - F1: {metrics['f1']:.4f}, Accuracy: {metrics['accuracy']:.4f}")
            
            # Track best model
            if metrics['f1'] > best_score:
                best_score = metrics['f1']
                best_model = model
                best_name = name
        
        # Log best model info
        mlflow.set_tag('best_model', best_name)
        mlflow.log_param('best_model_name', best_name)
        
        # Log best model metrics
        best_metrics = results[best_name]['metrics']
        for metric_name, value in best_metrics.items():
            mlflow.log_metric(f"best_{metric_name}", value)
        
        # Log the best model as the primary model
        manager.log_model(
            best_model,
            model_name='best_model',
            model_type='sklearn',
            registered_model_name='predictive_maintenance_model'
        )
        
        # Save model locally
        model_data = {
            'model': best_model,
            'scaler': scaler,
            'feature_names': feature_names,
            'metrics': best_metrics,
            'model_name': best_name
        }
        
        with open(model_output_path, 'wb') as f:
            pickle.dump(model_data, f)
        
        # Log model artifacts
        manager.log_artifacts(
            str(Path(model_output_path).parent),
            artifact_path='models'
        )
        
        # Log dataset as artifact
        manager.log_dataset(df, 'training_dataset')
        
        # Log summary
        summary = {
            'best_model': best_name,
            'metrics': best_metrics,
            'feature_count': len(feature_names),
            'training_samples': len(X_train),
            'test_samples': len(X_test)
        }
        
        # Save summary as JSON
        summary_path = Path(model_output_path).with_suffix('.json')
        with open(summary_path, 'w') as f:
            json.dump(summary, f, indent=2)
        
        # Log summary as artifact
        mlflow.log_artifact(summary_path)
        
        logger.info(f"Training completed! Best model: {best_name} with F1: {best_score:.4f}")
        
        return summary


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train models with MLflow tracking")
    parser.add_argument("--features", type=str, default="data/processed/features_48h.csv",
                       help="Path to features CSV")
    parser.add_argument("--output", type=str, default="models/registry/model.pkl",
                       help="Output path for trained model")
    parser.add_argument("--experiment", type=str, default="Predictive_Maintenance",
                       help="MLflow experiment name")
    parser.add_argument("--test_size", type=float, default=0.2,
                       help="Proportion of data for testing")
    parser.add_argument("--random_state", type=int, default=42,
                       help="Random seed for reproducibility")
    
    args = parser.parse_args()
    
    results = train_with_mlflow(
        features_path=args.features,
        model_output_path=args.output,
        experiment_name=args.experiment,
        test_size=args.test_size,
        random_state=args.random_state
    )
    
    print("\nTraining completed successfully!")
    print(json.dumps(results, indent=2))
EOF

chmod +x models/training/train_model_mlflow.py
```

### Step 7: Run the MLflow-Integrated Pipeline

```bash
# Run the new training script
python models/training/train_model_mlflow.py \
    --features data/processed/features_48h.csv \
    --output models/registry/model_48h_mlflow.pkl \
    --experiment "Predictive_Maintenance_48h"

# View the MLflow UI
mlflow ui --backend-store-uri ./mlruns

# This will start a web server at http://localhost:5000
# Open this URL in your browser to see the tracking UI

# For remote viewing (if running on a server):
# mlflow ui --host 0.0.0.0 --port 5000
```

### Step 8: Create an Experiment Comparison Script

```bash
cat > scripts/compare_experiments.py << 'EOF'
#!/usr/bin/env python
"""
Compare MLflow experiments and visualize results.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import mlflow
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from src.utils.mlflow_utils import get_mlflow_manager
import argparse


def compare_experiments(experiment_names: list, metric: str = 'f1', output_dir: str = 'reports'):
    """
    Compare multiple experiments and generate visualizations.
    """
    manager = get_mlflow_manager()
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    all_runs = []
    
    for exp_name in experiment_names:
        # Get experiment
        exp = mlflow.get_experiment_by_name(exp_name)
        if exp is None:
            print(f"Experiment not found: {exp_name}")
            continue
        
        # Get runs
        runs = mlflow.search_runs(
            experiment_ids=[exp.experiment_id],
            order_by=["start_time DESC"]
        )
        
        if runs.empty:
            print(f"No runs found for experiment: {exp_name}")
            continue
        
        runs['experiment'] = exp_name
        all_runs.append(runs)
    
    if not all_runs:
        print("No runs found in any experiment")
        return
    
    # Combine all runs
    df = pd.concat(all_runs, ignore_index=True)
    
    # Extract relevant columns
    metric_cols = [col for col in df.columns if col.startswith('metrics.')]
    param_cols = [col for col in df.columns if col.startswith('params.')]
    
    # Keep only relevant columns
    keep_cols = ['experiment', 'run_id', 'run_name'] + metric_cols + param_cols
    df = df[keep_cols]
    
    # Generate report
    print(f"\nExperiment Comparison Report")
    print("=" * 60)
    print(f"Total runs analyzed: {len(df)}")
    print(f"Experiments: {df['experiment'].unique()}")
    
    # Summary statistics
    for exp in df['experiment'].unique():
        exp_df = df[df['experiment'] == exp]
        print(f"\n{exp}:")
        print(f"  Runs: {len(exp_df)}")
        
        # Find best run for the specified metric
        metric_col = f'metrics.{metric}'
        if metric_col in exp_df.columns:
            best_run = exp_df.loc[exp_df[metric_col].idxmax()]
            print(f"  Best {metric}: {best_run[metric_col]:.4f} (run: {best_run['run_name']})")
    
    # Create visualization
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # 1. Metric distribution by experiment
    if len(df['experiment'].unique()) > 1:
        for exp in df['experiment'].unique():
            exp_df = df[df['experiment'] == exp]
            metric_col = f'metrics.{metric}'
            if metric_col in exp_df.columns:
                axes[0, 0].hist(exp_df[metric_col], alpha=0.5, label=exp, bins=20)
        axes[0, 0].set_xlabel(metric)
        axes[0, 0].set_ylabel('Frequency')
        axes[0, 0].set_title(f'Distribution of {metric} by Experiment')
        axes[0, 0].legend()
    
    # 2. Best metric by experiment
    best_metrics = []
    for exp in df['experiment'].unique():
        exp_df = df[df['experiment'] == exp]
        metric_col = f'metrics.{metric}'
        if metric_col in exp_df.columns:
            best_metrics.append({
                'experiment': exp,
                'best_score': exp_df[metric_col].max(),
                'mean_score': exp_df[metric_col].mean(),
                'std_score': exp_df[metric_col].std()
            })
    
    if best_metrics:
        best_df = pd.DataFrame(best_metrics)
        axes[0, 1].bar(best_df['experiment'], best_df['best_score'])
        axes[0, 1].set_xlabel('Experiment')
        axes[0, 1].set_ylabel(f'Best {metric}')
        axes[0, 1].set_title(f'Best {metric} by Experiment')
        axes[0, 1].tick_params(axis='x', rotation=45)
    
    # 3. Parameter correlation (if multiple params exist)
    param_cols_available = [col for col in param_cols if col in df.columns]
    if len(param_cols_available) > 1:
        param_df = df[param_cols_available]
        numeric_params = []
        for col in param_cols_available:
            try:
                pd.to_numeric(df[col])
                numeric_params.append(col)
            except:
                pass
        
        if numeric_params:
            corr_matrix = df[numeric_params + [f'metrics.{metric}']].corr()
            sns.heatmap(corr_matrix, annot=True, fmt='.2f', ax=axes[1, 0])
            axes[1, 0].set_title('Correlation Matrix')
    
    # 4. Run timeline
    df['start_time'] = pd.to_datetime(df['run_name'].str.extract(r'(\d{8}_\d{6})')[0], errors='coerce')
    if not df['start_time'].isna().all():
        for exp in df['experiment'].unique():
            exp_df = df[df['experiment'] == exp]
            metric_col = f'metrics.{metric}'
            if metric_col in exp_df.columns:
                axes[1, 1].scatter(exp_df['start_time'], exp_df[metric_col], alpha=0.6, label=exp)
        axes[1, 1].set_xlabel('Time')
        axes[1, 1].set_ylabel(f'{metric}')
        axes[1, 1].set_title(f'{metric} Over Time')
        axes[1, 1].legend()
    
    plt.tight_layout()
    plt.savefig(output_dir / 'experiment_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # Save summary
    df.to_csv(output_dir / 'experiment_data.csv', index=False)
    print(f"\nReports saved to: {output_dir}")
    print(f"Data saved to: {output_dir}/experiment_data.csv")
    print(f"Plot saved to: {output_dir}/experiment_comparison.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Compare MLflow experiments")
    parser.add_argument("--experiments", type=str, nargs="+", 
                       default=["Predictive_Maintenance_48h", "Predictive_Maintenance_168h"],
                       help="Experiment names to compare")
    parser.add_argument("--metric", type=str, default="f1",
                       help="Metric to compare")
    parser.add_argument("--output", type=str, default="reports",
                       help="Output directory for reports")
    
    args = parser.parse_args()
    
    compare_experiments(args.experiments, args.metric, args.output)
EOF

chmod +x scripts/compare_experiments.py

# Run the comparison
python scripts/compare_experiments.py
```

### Step 9: Create MLflow Dashboard Launcher

```bash
cat > scripts/launch_mlflow_dashboard.sh << 'EOF'
#!/bin/bash
# Launch MLflow dashboard with all experiments

echo "Starting MLflow dashboard..."

# Check if MLflow is running
if pgrep -f "mlflow server" > /dev/null; then
    echo "MLflow server is already running"
else
    echo "Starting MLflow server..."
    mlflow server \
        --host 127.0.0.1 \
        --port 5000 \
        --backend-store-uri ./mlruns \
        --default-artifact-root ./mlflow_artifacts &
    
    # Wait for server to start
    sleep 3
fi

# Open the UI
echo "Opening MLflow UI at http://localhost:5000"
if [[ "$OSTYPE" == "darwin"* ]]; then
    open http://localhost:5000
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open http://localhost:5000
else
    echo "Please open http://localhost:5000 in your browser"
fi
EOF

chmod +x scripts/launch_mlflow_dashboard.sh
```

## The Verification: Testing MLflow Setup

### Verification 1: Test MLflow Server

```bash
# Start the MLflow server
./scripts/start_mlflow_server.sh &
# Note: Run in background or in a separate terminal

# Test the server is running
curl http://localhost:5000/health

# Expected output: {"status":"OK"} or similar
```

### Verification 2: Test Experiment Tracking

```bash
# Run the test script
python tests/test_mlflow.py

# Check the run was logged
python -c "
import mlflow
runs = mlflow.search_runs(experiment_ids=['0'])
print('Runs found:', len(runs))
print(runs[['run_id', 'run_name']])
"
```

### Verification 3: Test Model Training with MLflow

```bash
# Train a model with MLflow
python models/training/train_model_mlflow.py \
    --features data/processed/features_48h.csv \
    --output models/registry/test_model.pkl

# Check MLflow run was created
python -c "
import mlflow
import pandas as pd
runs = mlflow.search_runs()
print('Latest run:')
print(runs[['run_id', 'run_name', 'metrics.best_f1']].head(1))
"
```

### Verification 4: View MLflow UI

```bash
# Launch the dashboard
./scripts/launch_mlflow_dashboard.sh

# In your browser, navigate to http://localhost:5000
# You should see your experiments and runs
```

### Verification 5: Test Artifact Logging

```bash
# Check artifacts were logged
python -c "
import mlflow
from pathlib import Path

# Get latest run
client = mlflow.tracking.MlflowClient()
runs = client.search_runs(experiment_ids=['0'], max_results=1)
if runs:
    run_id = runs[0].info.run_id
    artifacts = client.list_artifacts(run_id)
    print(f'Artifacts for run {run_id}:')
    for artifact in artifacts:
        print(f'  - {artifact.path}')
"
```

## What We've Accomplished

By completing this part, you have:

1. **Installed and configured MLflow** for experiment tracking
2. **Created a comprehensive MLflow utility module** for consistent tracking
3. **Built MLflow-integrated training scripts**
4. **Created experiment comparison tools**
5. **Set up the MLflow tracking server**
6. **Tested all MLflow functionality**
7. **Prepared for model registry implementation**

## MLflow Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     MLflow Architecture                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────┐  │
│  │  Tracking    │     │  Projects    │     │  Models  │  │
│  │  Server      │◄────│  (Code)      │     │  Registry│  │
│  └──────────────┘     └──────────────┘     └──────────┘  │
│         │                    │                    │        │
│         ▼                    ▼                    ▼        │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────┐  │
│  │  Experiments │     │  Parameters  │     │  Models  │  │
│  │  & Runs      │     │  & Metrics   │     │  & Artifacts│ │
│  └──────────────┘     └──────────────┘     └──────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Common MLflow Commands

| Command | Purpose |
|---------|---------|
| `mlflow ui` | Start the tracking UI |
| `mlflow server` | Start the tracking server |
| `mlflow models serve` | Serve a model as a REST API |
| `mlflow models predict` | Make predictions with a model |
| `mlflow run` | Run an MLflow project |
| `mlflow experiments` | List experiments |
| `mlflow runs` | List runs |

## Troubleshooting

**Issue:** MLflow server won't start
```bash
# Solution: Check port availability
lsof -i :5000  # Check if port is in use
# Change port: --port 5001
```

**Issue:** Cannot connect to MLflow server
```bash
# Solution: Set tracking URI explicitly
export MLFLOW_TRACKING_URI=http://localhost:5000
```

**Issue:** Artifacts not showing in UI
```bash
# Solution: Check artifact location
ls -la mlflow_artifacts/
# Ensure the artifact path is correctly configured
```

## Next Steps

In Part 6, we'll:
- Log detailed training runs with parameters and metrics
- Implement automatic experiment comparison
- Set up model versioning
- Prepare for the model registry

---

*End of Part 5: Setting Up MLflow Tracking*
