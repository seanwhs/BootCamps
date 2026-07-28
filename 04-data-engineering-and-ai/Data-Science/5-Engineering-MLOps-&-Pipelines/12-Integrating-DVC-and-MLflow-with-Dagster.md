# Part 12: Integrating DVC and MLflow with Dagster

## The Target: Complete Integration of DVC and MLflow into Dagster

In this part, we'll integrate DVC for data versioning and MLflow for experiment tracking into our Dagster pipelines. By the end, you'll have a unified MLOps pipeline that orchestrates the entire lifecycle.

## The Concept: The MLOps Holy Trinity

Think of this integration like a well-orchestrated restaurant:
- **DVC** is the inventory management (tracking ingredients/data versions)
- **MLflow** is the recipe book and quality control (tracking experiments and models)
- **Dagster** is the head chef (orchestrating the entire kitchen)

When integrated, you get:
- **Reproducibility**: Every run knows exactly which data version and code were used
- **Traceability**: Complete lineage from raw data to deployed model
- **Automation**: End-to-end orchestration with minimal human intervention

## The Implementation: Complete Integration

### Step 1: Create Integration Resources

```bash
cat > src/utils/integration_utils.py << 'EOF'
"""
Integration utilities for DVC, MLflow, and Dagster.
Provides unified resource management and helper functions.
"""

import os
import subprocess
import json
import yaml
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
import logging
import mlflow
import pandas as pd
from datetime import datetime
import pickle

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DVCMLflowIntegration:
    """Unified integration for DVC and MLflow operations."""
    
    def __init__(self, project_root: str = "."):
        self.project_root = Path(project_root)
        self.tracking_uri = os.getenv("MLFLOW_TRACKING_URI", "./mlruns")
        mlflow.set_tracking_uri(self.tracking_uri)
    
    def get_data_version(self, data_path: str) -> Dict[str, Any]:
        """
        Get DVC version information for a data file.
        
        Args:
            data_path: Path to the data file
            
        Returns:
            Dictionary with version information
        """
        data_path = Path(data_path)
        dvc_file = data_path.with_suffix(data_path.suffix + '.dvc')
        
        if not dvc_file.exists():
            return {
                'version': 'unknown',
                'file': str(data_path),
                'tracked': False
            }
        
        # Parse DVC file
        with open(dvc_file, 'r') as f:
            dvc_data = yaml.safe_load(f)
        
        # Get hash from DVC
        hash_info = dvc_data.get('outs', [{}])[0].get('md5', 'unknown')
        
        # Get git commit
        try:
            commit_hash = subprocess.check_output(
                ['git', 'rev-parse', 'HEAD'],
                cwd=self.project_root,
                text=True
            ).strip()
        except:
            commit_hash = 'unknown'
        
        return {
            'version': hash_info[:8] if hash_info != 'unknown' else 'unknown',
            'full_hash': hash_info,
            'file': str(data_path),
            'tracked': True,
            'git_commit': commit_hash
        }
    
    def log_data_version_to_mlflow(self, data_path: str, prefix: str = "data"):
        """
        Log DVC version information to MLflow.
        
        Args:
            data_path: Path to the data file
            prefix: Prefix for parameter names
        """
        version_info = self.get_data_version(data_path)
        
        for key, value in version_info.items():
            mlflow.log_param(f"{prefix}_{key}", str(value))
        
        logger.info(f"Logged DVC version for {data_path}: {version_info['version']}")
        return version_info
    
    def track_pipeline_artifacts(self, artifacts: Dict[str, str]) -> None:
        """
        Track pipeline artifacts with both DVC and MLflow.
        
        Args:
            artifacts: Dictionary mapping artifact names to paths
        """
        for name, path in artifacts.items():
            path = Path(path)
            
            if not path.exists():
                logger.warning(f"Artifact {name} not found at {path}")
                continue
            
            # Add to DVC if it's a data file
            if path.suffix in ['.csv', '.parquet', '.json', '.pkl']:
                try:
                    subprocess.run(
                        ['dvc', 'add', str(path)],
                        cwd=self.project_root,
                        check=True,
                        capture_output=True
                    )
                    logger.info(f"Added {path} to DVC")
                except subprocess.CalledProcessError as e:
                    logger.error(f"Failed to add {path} to DVC: {e}")
            
            # Log to MLflow
            if path.is_file():
                mlflow.log_artifact(str(path), artifact_path=name)
                logger.info(f"Logged {path} to MLflow as artifact {name}")
    
    def create_experiment_run(
        self, 
        experiment_name: str,
        run_name: Optional[str] = None,
        tags: Optional[Dict[str, str]] = None
    ) -> mlflow.ActiveRun:
        """
        Create an MLflow run with DVC context.
        
        Args:
            experiment_name: Name of the MLflow experiment
            run_name: Name of the run (auto-generated if None)
            tags: Additional tags
            
        Returns:
            MLflow active run context
        """
        # Set experiment
        experiment = mlflow.get_experiment_by_name(experiment_name)
        if experiment is None:
            experiment_id = mlflow.create_experiment(experiment_name)
            logger.info(f"Created experiment {experiment_name} (ID: {experiment_id})")
        
        mlflow.set_experiment(experiment_name)
        
        # Start run
        if run_name is None:
            run_name = f"dagster_run_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        # Add DVC version tags
        dvc_tags = {
            'dvc_version': self._get_dvc_version(),
            'git_commit': self._get_git_commit(),
            'git_branch': self._get_git_branch(),
            'dagster_run_type': 'orchestrated'
        }
        
        if tags:
            dvc_tags.update(tags)
        
        run = mlflow.start_run(
            run_name=run_name,
            tags=dvc_tags
        )
        
        logger.info(f"Started MLflow run: {run.info.run_id} - {run_name}")
        return run
    
    def _get_dvc_version(self) -> str:
        """Get DVC version."""
        try:
            result = subprocess.run(
                ['dvc', '--version'],
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            return result.stdout.strip()
        except:
            return 'unknown'
    
    def _get_git_commit(self) -> str:
        """Get current git commit hash."""
        try:
            result = subprocess.run(
                ['git', 'rev-parse', 'HEAD'],
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            return result.stdout.strip()
        except:
            return 'unknown'
    
    def _get_git_branch(self) -> str:
        """Get current git branch."""
        try:
            result = subprocess.run(
                ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            return result.stdout.strip()
        except:
            return 'unknown'
    
    def get_model_from_registry(self, model_name: str, stage: str = "Production") -> Any:
        """
        Load a model from MLflow Model Registry.
        
        Args:
            model_name: Name of the model
            stage: Stage to load from ('Staging', 'Production')
            
        Returns:
            Loaded model
        """
        model_uri = f"models:/{model_name}/{stage}"
        logger.info(f"Loading model from {model_uri}")
        
        try:
            model = mlflow.sklearn.load_model(model_uri)
            logger.info(f"Model loaded successfully")
            return model
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            raise
    
    def compare_data_versions(self, path1: str, path2: str) -> Dict[str, Any]:
        """
        Compare two DVC-tracked data versions.
        
        Args:
            path1: First data path
            path2: Second data path
            
        Returns:
            Dictionary with comparison results
        """
        version1 = self.get_data_version(path1)
        version2 = self.get_data_version(path2)
        
        comparison = {
            'path1': path1,
            'path2': path2,
            'version1': version1.get('version', 'unknown'),
            'version2': version2.get('version', 'unknown'),
            'same_version': version1.get('version') == version2.get('version')
        }
        
        return comparison
    
    def create_pipeline_context(self, run_name: Optional[str] = None) -> Dict[str, Any]:
        """
        Create a unified pipeline context with DVC and MLflow info.
        
        Args:
            run_name: Name for the pipeline run
            
        Returns:
            Dictionary with context information
        """
        context = {
            'timestamp': datetime.now().isoformat(),
            'run_name': run_name or f"pipeline_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
            'dvc_version': self._get_dvc_version(),
            'git_commit': self._get_git_commit(),
            'git_branch': self._get_git_branch(),
            'mlflow_tracking_uri': self.tracking_uri
        }
        
        return context


# Singleton instance
_integration = None


def get_integration() -> DVCMLflowIntegration:
    """Get singleton integration instance."""
    global _integration
    if _integration is None:
        _integration = DVCMLflowIntegration()
    return _integration
EOF
```

### Step 2: Create Integrated Pipeline Ops

```bash
cat > pipelines/integrated_pipeline.py << 'EOF'
"""
Fully integrated pipeline with DVC, MLflow, and Dagster.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.preprocessing import StandardScaler
import mlflow
import json
import pickle
from datetime import datetime

from dagster import (
    op, 
    job, 
    graph, 
    In,
    Out,
    get_dagster_logger,
    resource,
    OpExecutionContext,
    RetryPolicy
)

from src.utils.dagster_utils import DataIOManager, ModelIOManager
from src.utils.integration_utils import get_integration, DVCMLflowIntegration


# ============= INTEGRATED OPS =============

@op(
    required_resource_keys={"dvc", "data_io"},
    out=Out(io_manager_key="data_io"),
    retry_policy=RetryPolicy(max_retries=2, delay=5)
)
def generate_integrated_data(context: OpExecutionContext) -> pd.DataFrame:
    """
    Generate data with DVC and MLflow integration.
    """
    logger = context.log
    integration = get_integration()
    
    logger.info("Generating integrated data...")
    
    # Create MLflow run context
    with integration.create_experiment_run(
        experiment_name="Dagster_Integrated_Pipeline",
        run_name=f"generate_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        tags={"operation": "data_generation"}
    ):
        # Generate data
        np.random.seed(42)
        n_samples = 1000
        
        data = {
            'timestamp': pd.date_range('2024-01-01', periods=n_samples, freq='min'),
            'sensor_1': np.random.normal(20, 5, n_samples),
            'sensor_2': np.random.normal(30, 5, n_samples),
            'sensor_3': np.random.normal(50, 5, n_samples),
            'temperature': np.random.normal(75, 10, n_samples),
            'pressure': np.random.normal(1.2, 0.2, n_samples),
            'vibration': np.random.normal(0.5, 0.1, n_samples)
        }
        
        df = pd.DataFrame(data)
        
        # Add anomalies
        anomaly_indices = np.random.choice(n_samples, size=50, replace=False)
        df.loc[anomaly_indices, 'temperature'] += np.random.uniform(10, 30, 50)
        df.loc[anomaly_indices, 'vibration'] += np.random.uniform(1, 3, 50)
        df['label'] = 0
        df.loc[anomaly_indices, 'label'] = 1
        
        # Log data info to MLflow
        mlflow.log_params({
            'data_samples': len(df),
            'data_features': len(df.columns),
            'anomalies': df['label'].sum(),
            'anomaly_rate': df['label'].mean()
        })
        
        # Save to file
        data_path = Path("data/raw/integrated_data.csv")
        data_path.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(data_path, index=False)
        
        # Log data version to MLflow
        version_info = integration.log_data_version_to_mlflow(str(data_path))
        
        # Add to DVC
        context.resources.dvc.add_file(str(data_path))
        
        logger.info(f"Generated {len(df)} samples, version: {version_info['version']}")
        
        return df


@op(
    required_resource_keys={"data_io", "dvc"},
    ins={"raw_data": In(io_manager_key="data_io")},
    out=Out(io_manager_key="data_io")
)
def process_integrated_features(context: OpExecutionContext, raw_data: pd.DataFrame) -> pd.DataFrame:
    """
    Process features with DVC and MLflow tracking.
    """
    logger = context.log
    integration = get_integration()
    
    logger.info("Processing integrated features...")
    
    with integration.create_experiment_run(
        experiment_name="Dagster_Integrated_Pipeline",
        run_name=f"process_features_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        tags={"operation": "feature_engineering"}
    ):
        # Process features
        X = raw_data.drop(columns=['label', 'timestamp'])
        y = raw_data['label']
        
        # Add rolling statistics
        for col in ['sensor_1', 'sensor_2', 'sensor_3', 'temperature', 'pressure', 'vibration']:
            for window in [5, 10]:
                X[f'{col}_rolling_mean_{window}'] = X[col].rolling(window=window, min_periods=1).mean()
                X[f'{col}_rolling_std_{window}'] = X[col].rolling(window=window, min_periods=1).std()
        
        X = X.fillna(0)
        X['label'] = y
        
        # Log feature info
        mlflow.log_params({
            'feature_count': len(X.columns),
            'feature_names': ','.join(X.columns[:5]),
            'samples': len(X)
        })
        
        # Save features
        features_path = Path("data/processed/integrated_features.csv")
        features_path.parent.mkdir(parents=True, exist_ok=True)
        X.to_csv(features_path, index=False)
        
        # Log version
        integration.log_data_version_to_mlflow(str(features_path), prefix="features")
        
        logger.info(f"Processed {len(X)} samples with {len(X.columns)} features")
        
        return X


@op(
    required_resource_keys={"data_io", "model_io"},
    ins={"features": In(io_manager_key="data_io")},
    out=Out(io_manager_key="model_io")
)
def train_integrated_model(context: OpExecutionContext, features: pd.DataFrame) -> dict:
    """
    Train model with MLflow tracking and DVC versioning.
    """
    logger = context.log
    integration = get_integration()
    
    logger.info("Training integrated model...")
    
    with integration.create_experiment_run(
        experiment_name="Dagster_Integrated_Pipeline",
        run_name=f"train_model_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        tags={"operation": "model_training"}
    ):
        # Prepare data
        X = features.drop(columns=['label'])
        y = features['label']
        
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        
        # Log data split info
        mlflow.log_params({
            'train_samples': len(X_train),
            'test_samples': len(X_test),
            'features_count': len(X.columns)
        })
        
        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)
        
        # Train model
        model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            random_state=42,
            n_jobs=-1
        )
        model.fit(X_train_scaled, y_train)
        
        # Evaluate
        y_pred = model.predict(X_test_scaled)
        
        metrics = {
            'accuracy': accuracy_score(y_test, y_pred),
            'f1': f1_score(y_test, y_pred),
            'precision': precision_score(y_test, y_pred),
            'recall': recall_score(y_test, y_pred)
        }
        
        # Log metrics
        mlflow.log_metrics(metrics)
        
        # Log model
        mlflow.sklearn.log_model(
            model,
            artifact_path="model",
            registered_model_name="predictive_maintenance_integrated"
        )
        
        # Log scaler
        mlflow.sklearn.log_model(scaler, artifact_path="scaler")
        
        # Log feature importance
        if hasattr(model, 'feature_importances_'):
            importances = dict(zip(X.columns, model.feature_importances_))
            sorted_importances = dict(sorted(importances.items(), key=lambda x: x[1], reverse=True)[:10])
            mlflow.log_dict(sorted_importances, "feature_importances.json")
        
        # Save model locally
        model_data = {
            'model': model,
            'scaler': scaler,
            'metrics': metrics,
            'feature_names': X.columns.tolist(),
            'training_date': datetime.now().isoformat()
        }
        
        model_path = Path("models/registry/integrated_model.pkl")
        model_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(model_path, 'wb') as f:
            pickle.dump(model_data, f)
        
        # Log model version
        integration.log_data_version_to_mlflow(str(model_path), prefix="model")
        
        logger.info(f"Model trained with F1: {metrics['f1']:.4f}")
        
        return model_data


@op(
    ins={"model_data": In(io_manager_key="model_io")}
)
def evaluate_and_promote_integrated(context: OpExecutionContext, model_data: dict) -> dict:
    """
    Evaluate and promote model with MLflow Model Registry.
    """
    logger = context.log
    integration = get_integration()
    
    logger.info("Evaluating and promoting integrated model...")
    
    with integration.create_experiment_run(
        experiment_name="Dagster_Integrated_Pipeline",
        run_name=f"promote_model_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        tags={"operation": "model_promotion"}
    ):
        metrics = model_data['metrics']
        f1_score = metrics['f1']
        
        # Decision logic
        if f1_score >= 0.85:
            status = "promoted"
            stage = "Production"
            message = "Model meets criteria, promoting to production"
        elif f1_score >= 0.75:
            status = "staged"
            stage = "Staging"
            message = "Model meets staging criteria"
        else:
            status = "rejected"
            stage = "Archived"
            message = "Model does not meet criteria"
        
        # Log promotion decision
        mlflow.log_params({
            'promotion_status': status,
            'target_stage': stage,
            'f1_threshold_met': f1_score >= 0.75
        })
        
        # If promoted, transition model in registry
        if status in ["promoted", "staged"]:
            try:
                from mlflow.tracking import MlflowClient
                client = MlflowClient()
                
                # Get latest model version
                model_versions = client.search_model_versions("name='predictive_maintenance_integrated'")
                if model_versions:
                    latest_version = model_versions[0].version
                    client.transition_model_version_stage(
                        name="predictive_maintenance_integrated",
                        version=latest_version,
                        stage=stage
                    )
                    logger.info(f"Model transitioned to {stage}")
            except Exception as e:
                logger.warning(f"Failed to transition model: {e}")
        
        # Save promotion report
        report = {
            'model_type': 'random_forest',
            'f1_score': f1_score,
            'status': status,
            'stage': stage,
            'message': message,
            'metrics': metrics,
            'evaluation_time': datetime.now().isoformat()
        }
        
        report_path = Path("models/evaluation/promotion_report_integrated.json")
        report_path.parent.mkdir(parents=True, exist_ok=True)
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Model evaluation: {status} - {message}")
        
        return report


# ============= COMPLETE INTEGRATED PIPELINE =============

@job(
    resource_defs={
        "dvc": resource({"project_path": "."}),
        "data_io": DataIOManager(),
        "model_io": ModelIOManager()
    }
)
def integrated_mlops_pipeline():
    """
    Complete integrated MLOps pipeline with DVC and MLflow.
    """
    raw_data = generate_integrated_data()
    features = process_integrated_features(raw_data)
    model_data = train_integrated_model(features)
    evaluation = evaluate_and_promote_integrated(model_data)
    return evaluation


# Export
jobs = [integrated_mlops_pipeline]
EOF
```

### Step 3: Create Schedule with Integration

```bash
cat > pipelines/integrated_schedules.py << 'EOF'
"""
Schedules for integrated pipelines.
"""

from dagster import schedule, ScheduleDefinition
from pipelines.integrated_pipeline import integrated_mlops_pipeline


@schedule(
    job=integrated_mlops_pipeline,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def integrated_daily_schedule(context):
    """
    Daily integrated pipeline schedule.
    """
    return {
        "tags": {
            "schedule_name": "integrated_daily_schedule",
            "pipeline_type": "integrated",
            "run_environment": "production"
        }
    }


@schedule(
    job=integrated_mlops_pipeline,
    cron_schedule="0 0 * * 0",  # Weekly on Sunday
    execution_timezone="UTC"
)
def integrated_weekly_schedule(context):
    """
    Weekly integrated pipeline schedule for full retraining.
    """
    return {
        "tags": {
            "schedule_name": "integrated_weekly_schedule",
            "pipeline_type": "integrated",
            "run_environment": "production",
            "run_type": "full_retraining"
        }
    }


# Export
schedules = [integrated_daily_schedule, integrated_weekly_schedule]
EOF
```

### Step 4: Run the Integrated Pipeline

```bash
# Run the integrated pipeline
dagster job execute -f pipelines/integrated_pipeline.py -j integrated_mlops_pipeline -l DEBUG

# Check MLflow runs
python -c "
import mlflow
mlflow.set_tracking_uri('./mlruns')
experiment = mlflow.get_experiment_by_name('Dagster_Integrated_Pipeline')
if experiment:
    runs = mlflow.search_runs(experiment_ids=[experiment.experiment_id])
    print(f'Found {len(runs)} runs')
    print(runs[['run_name', 'metrics.f1', 'tags.dvc_version']].head())
"

# Check DVC status
dvc status

# Check model registry
python -c "
from mlflow.tracking import MlflowClient
client = MlflowClient()
versions = client.search_model_versions(\"name='predictive_maintenance_integrated'\")
for v in versions:
    print(f'Version {v.version}: {v.current_stage}')
"
```

## The Verification: Testing Integration

### Verification 1: Check Data Versioning

```bash
# Verify data was added to DVC
dvc list

# Check DVC status
dvc status

# View DVC metadata
cat data/raw/integrated_data.csv.dvc
```

### Verification 2: Check MLflow Tracking

```bash
# Start MLflow UI
mlflow ui --backend-store-uri ./mlruns

# Open http://localhost:5000
# You should see:
# - Experiment: Dagster_Integrated_Pipeline
# - Runs with parameters, metrics, and tags
# - DVC version information in tags
# - Registered model: predictive_maintenance_integrated
```

### Verification 3: Check End-to-End Lineage

```bash
# Show pipeline lineage
dagster job describe -f pipelines/integrated_pipeline.py -j integrated_mlops_pipeline

# Check assets
dagster asset list -f pipelines/integrated_pipeline.py
```

## What We've Accomplished

You now have a fully integrated MLOps system where:

1. **DVC tracks all data versions** (raw data, features, models)
2. **MLflow tracks all experiments** (parameters, metrics, artifacts)
3. **Dagster orchestrates the entire workflow** (automation, scheduling, error handling)
4. **Model registry manages model lifecycle** (Staging → Production)
5. **Complete lineage** from raw data to deployed model

## Next Steps

In the final Phase 4, we'll:
- Build the end-to-end pipeline complete with all integrations
- Add deployment and monitoring
- Implement CI/CD for the pipeline itself
- Create production-ready deployment

---

*End of Part 12: Integrating DVC and MLflow*
