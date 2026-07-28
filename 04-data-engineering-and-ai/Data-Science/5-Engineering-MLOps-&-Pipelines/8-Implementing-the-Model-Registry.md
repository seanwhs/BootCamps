# Part 8: Implementing the Model Registry

## The Target: MLflow Model Registry Setup and Management

In this part, we'll implement the MLflow Model Registry to manage our models through their entire lifecycle. By the end, you'll have a complete model governance system that tracks model versions, stages, and promotes models from Staging to Production.

## The Concept: Model Registry as Your ML Control Center

Think of the model registry like an airport's air traffic control system:
- **Models** are airplanes at various stages of readiness
- **Versions** are specific aircraft with their own maintenance records
- **Stages** represent where each plane is in its journey:
  - **Staging** = Pre-flight checks (validation, testing)
  - **Production** = In active service (serving predictions)
  - **Archived** = Retired from service (historical records)
- **Model Registry** = The control tower tracking everything

## The Implementation: Model Registry Setup

### Step 1: Create Model Registry Manager

```bash
cat > src/utils/model_registry.py << 'EOF'
"""
MLflow Model Registry management utilities.
Handles model versioning, stage transitions, and lifecycle management.
"""

import mlflow
import mlflow.sklearn
from mlflow.tracking import MlflowClient
from typing import Dict, List, Optional, Tuple
import pandas as pd
import json
import logging
from datetime import datetime
import time

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ModelRegistryManager:
    """
    Comprehensive MLflow Model Registry manager.
    """
    
    def __init__(self, tracking_uri: str = "./mlruns"):
        """
        Initialize the model registry manager.
        
        Args:
            tracking_uri: MLflow tracking URI
        """
        mlflow.set_tracking_uri(tracking_uri)
        self.client = MlflowClient()
        self.tracking_uri = tracking_uri
    
    def register_model(
        self, 
        run_id: str, 
        model_artifact_path: str,
        model_name: str,
        description: Optional[str] = None,
        tags: Optional[Dict[str, str]] = None
    ) -> Dict[str, any]:
        """
        Register a model from a run to the model registry.
        
        Args:
            run_id: MLflow run ID
            model_artifact_path: Path to model within run artifacts
            model_name: Name to register the model under
            description: Model description
            tags: Tags for the model
            
        Returns:
            Dictionary with registered model information
        """
        try:
            # Get model URI
            model_uri = f"runs:/{run_id}/{model_artifact_path}"
            
            # Register the model
            logger.info(f"Registering model {model_name} from run {run_id}")
            registered_model = self.client.create_registered_model(
                name=model_name,
                tags=tags or {},
                description=description or f"Model registered from run {run_id}"
            )
            
            # Create a new version
            model_version = self.client.create_model_version(
                name=model_name,
                source=model_uri,
                run_id=run_id,
                tags={"registered_at": datetime.now().isoformat()}
            )
            
            logger.info(f"Model registered successfully: {model_name} version {model_version.version}")
            
            return {
                'model_name': model_name,
                'version': model_version.version,
                'run_id': run_id,
                'status': model_version.status,
                'registered_at': datetime.now().isoformat()
            }
            
        except mlflow.exceptions.MlflowException as e:
            if "already exists" in str(e):
                # Model already exists, create new version
                logger.info(f"Model {model_name} already exists, creating new version")
                model_version = self.client.create_model_version(
                    name=model_name,
                    source=model_uri,
                    run_id=run_id,
                    tags={"registered_at": datetime.now().isoformat()}
                )
                
                return {
                    'model_name': model_name,
                    'version': model_version.version,
                    'run_id': run_id,
                    'status': model_version.status,
                    'registered_at': datetime.now().isoformat()
                }
            else:
                raise e
    
    def transition_model_stage(
        self, 
        model_name: str, 
        version: int, 
        stage: str,
        archive_existing_versions: bool = False
    ) -> Dict[str, any]:
        """
        Transition a model version to a new stage.
        
        Args:
            model_name: Name of the model
            version: Version number
            stage: Target stage ('Staging', 'Production', 'Archived')
            archive_existing_versions: Whether to archive other versions in the same stage
            
        Returns:
            Dictionary with transition results
        """
        valid_stages = ['Staging', 'Production', 'Archived', 'None']
        if stage not in valid_stages:
            raise ValueError(f"Invalid stage. Must be one of: {valid_stages}")
        
        # Handle archiving of existing versions in the same stage
        if archive_existing_versions and stage in ['Staging', 'Production']:
            existing_versions = self.client.get_latest_versions(
                model_name, 
                stages=[stage]
            )
            
            for existing in existing_versions:
                if existing.version != version:
                    logger.info(f"Archiving existing {stage} version {existing.version}")
                    self.client.transition_model_version_stage(
                        name=model_name,
                        version=existing.version,
                        stage="Archived",
                        archive_existing_versions=True
                    )
        
        # Transition the new version
        logger.info(f"Transitioning {model_name} version {version} to {stage}")
        self.client.transition_model_version_stage(
            name=model_name,
            version=version,
            stage=stage,
            archive_existing_versions=archive_existing_versions
        )
        
        # Get updated version info
        model_version = self.client.get_model_version(
            name=model_name,
            version=version
        )
        
        return {
            'model_name': model_name,
            'version': version,
            'stage': stage,
            'status': model_version.status,
            'transitioned_at': datetime.now().isoformat()
        }
    
    def get_model_versions(self, model_name: str) -> pd.DataFrame:
        """
        Get all versions of a model.
        
        Args:
            model_name: Name of the model
            
        Returns:
            DataFrame with model versions
        """
        versions = self.client.search_model_versions(f"name='{model_name}'")
        
        if not versions:
            logger.warning(f"No versions found for model {model_name}")
            return pd.DataFrame()
        
        data = []
        for v in versions:
            data.append({
                'version': v.version,
                'stage': v.current_stage,
                'status': v.status,
                'run_id': v.run_id,
                'created_at': v.creation_timestamp,
                'description': v.description,
                'tags': v.tags
            })
        
        df = pd.DataFrame(data)
        df['created_at'] = pd.to_datetime(df['created_at'], unit='ms')
        return df.sort_values('version', ascending=False)
    
    def get_latest_version(self, model_name: str, stage: Optional[str] = None) -> Optional[Dict]:
        """
        Get the latest version of a model.
        
        Args:
            model_name: Name of the model
            stage: Optional stage filter ('Staging', 'Production', 'Archived', None)
            
        Returns:
            Dictionary with model version info or None
        """
        try:
            if stage:
                version = self.client.get_latest_versions(model_name, stages=[stage])
            else:
                version = self.client.get_latest_versions(model_name, stages=[])
            
            if not version:
                return None
            
            latest = version[0]
            return {
                'version': latest.version,
                'stage': latest.current_stage,
                'status': latest.status,
                'run_id': latest.run_id,
                'created_at': pd.to_datetime(latest.creation_timestamp, unit='ms')
            }
        except Exception as e:
            logger.error(f"Error getting latest version: {e}")
            return None
    
    def load_model(self, model_name: str, version: Optional[int] = None, stage: Optional[str] = None):
        """
        Load a model from the registry.
        
        Args:
            model_name: Name of the model
            version: Specific version (optional)
            stage: Stage to load from ('Staging', 'Production')
            
        Returns:
            Loaded model
        """
        if version:
            model_uri = f"models:/{model_name}/{version}"
        elif stage:
            model_uri = f"models:/{model_name}/{stage}"
        else:
            model_uri = f"models:/{model_name}/latest"
        
        logger.info(f"Loading model from {model_uri}")
        return mlflow.sklearn.load_model(model_uri)
    
    def add_model_metadata(
        self, 
        model_name: str, 
        version: int, 
        metadata: Dict[str, any]
    ) -> None:
        """
        Add or update metadata for a model version.
        
        Args:
            model_name: Name of the model
            version: Version number
            metadata: Dictionary of metadata to add
        """
        # Convert metadata to JSON string
        metadata_json = json.dumps(metadata)
        
        # Add as a tag
        self.client.set_model_version_tag(
            name=model_name,
            version=version,
            key="metadata",
            value=metadata_json
        )
        
        logger.info(f"Added metadata to {model_name} version {version}")
    
    def get_model_metadata(self, model_name: str, version: int) -> Dict:
        """
        Get metadata for a model version.
        
        Args:
            model_name: Name of the model
            version: Version number
            
        Returns:
            Dictionary with metadata
        """
        model_version = self.client.get_model_version(
            name=model_name,
            version=version
        )
        
        metadata = model_version.tags.get("metadata", "{}")
        return json.loads(metadata)
    
    def compare_versions(self, model_name: str, version1: int, version2: int) -> Dict:
        """
        Compare two versions of a model.
        
        Args:
            model_name: Name of the model
            version1: First version
            version2: Second version
            
        Returns:
            Dictionary with comparison results
        """
        v1 = self.client.get_model_version(name=model_name, version=version1)
        v2 = self.client.get_model_version(name=model_name, version=version2)
        
        # Get metrics from runs
        run1 = self.client.get_run(v1.run_id)
        run2 = self.client.get_run(v2.run_id)
        
        # Extract metrics
        metrics1 = run1.data.metrics if run1.data.metrics else {}
        metrics2 = run2.data.metrics if run2.data.metrics else {}
        
        # Compare
        comparison = {
            'version1': version1,
            'version2': version2,
            'metrics_diff': {}
        }
        
        for key in set(metrics1.keys()) | set(metrics2.keys()):
            val1 = metrics1.get(key)
            val2 = metrics2.get(key)
            
            if val1 is not None and val2 is not None:
                diff = val2 - val1
                pct_change = (diff / val1 * 100) if val1 != 0 else 0
                comparison['metrics_diff'][key] = {
                    'version1': val1,
                    'version2': val2,
                    'diff': diff,
                    'pct_change': pct_change
                }
        
        return comparison
    
    def stage_validation_pipeline(
        self, 
        model_name: str,
        version: int,
        validation_metrics: Dict[str, float],
        threshold_metrics: Dict[str, float]
    ) -> bool:
        """
        Validate a model version against thresholds before staging.
        
        Args:
            model_name: Name of the model
            version: Version number
            validation_metrics: Metrics from validation
            threshold_metrics: Minimum thresholds required
            
        Returns:
            True if validation passes, False otherwise
        """
        logger.info(f"Validating {model_name} version {version}")
        
        # Check all required metrics
        all_passed = True
        validation_results = {}
        
        for metric, threshold in threshold_metrics.items():
            value = validation_metrics.get(metric)
            
            if value is None:
                logger.warning(f"Metric {metric} not found in validation data")
                validation_results[metric] = 'missing'
                all_passed = False
            elif value >= threshold:
                logger.info(f"✓ {metric}: {value:.4f} >= {threshold:.4f}")
                validation_results[metric] = 'passed'
            else:
                logger.warning(f"✗ {metric}: {value:.4f} < {threshold:.4f}")
                validation_results[metric] = 'failed'
                all_passed = False
        
        # Log validation results as tags
        self.client.set_model_version_tag(
            name=model_name,
            version=version,
            key="validation_results",
            value=json.dumps(validation_results)
        )
        
        self.client.set_model_version_tag(
            name=model_name,
            version=version,
            key="validation_passed",
            value=str(all_passed)
        )
        
        return all_passed
    
    def promote_to_production(
        self, 
        model_name: str,
        version: int,
        require_validation: bool = True,
        threshold_metrics: Optional[Dict[str, float]] = None
    ) -> Tuple[bool, str]:
        """
        Promote a model to production with validation.
        
        Args:
            model_name: Name of the model
            version: Version number
            require_validation: Whether to require validation
            threshold_metrics: Minimum thresholds for validation
            
        Returns:
            Tuple of (success, message)
        """
        logger.info(f"Promoting {model_name} version {version} to production")
        
        # Get model version info
        model_version = self.client.get_model_version(
            name=model_name,
            version=version
        )
        
        if model_version.current_stage == "Production":
            return True, "Already in production"
        
        # Validate if required
        if require_validation:
            # Check if validation was performed
            validation_passed = model_version.tags.get("validation_passed")
            
            if validation_passed == "True":
                logger.info("Validation passed, proceeding with promotion")
            elif validation_passed == "False":
                return False, "Validation failed, cannot promote"
            else:
                return False, "No validation performed, run validation first"
        
        # Transition to production
        self.transition_model_stage(
            model_name=model_name,
            version=version,
            stage="Production",
            archive_existing_versions=True
        )
        
        # Add promotion metadata
        self.client.set_model_version_tag(
            name=model_name,
            version=version,
            key="promoted_at",
            value=datetime.now().isoformat()
        )
        
        self.client.set_model_version_tag(
            name=model_name,
            version=version,
            key="promoted_by",
            value="production_pipeline"
        )
        
        return True, f"Successfully promoted to production"
    
    def get_model_performance_history(
        self, 
        model_name: str,
        metric: str = 'f1'
    ) -> pd.DataFrame:
        """
        Get performance history for a model across versions.
        
        Args:
            model_name: Name of the model
            metric: Metric to track
            
        Returns:
            DataFrame with performance history
        """
        versions = self.client.search_model_versions(f"name='{model_name}'")
        
        history = []
        for v in versions:
            # Get run info
            run = self.client.get_run(v.run_id)
            
            # Extract metric
            value = run.data.metrics.get(metric)
            
            if value is not None:
                history.append({
                    'version': v.version,
                    'stage': v.current_stage,
                    'created_at': pd.to_datetime(v.creation_timestamp, unit='ms'),
                    f'{metric}_score': value,
                    'run_id': v.run_id
                })
        
        df = pd.DataFrame(history)
        return df.sort_values('created_at')
    
    def create_model_card(
        self, 
        model_name: str,
        version: Optional[int] = None,
        output_file: Optional[str] = None
    ) -> str:
        """
        Generate a model card for documentation.
        
        Args:
            model_name: Name of the model
            version: Specific version (optional)
            output_file: File to save the model card
            
        Returns:
            Model card text
        """
        if version is None:
            latest = self.get_latest_version(model_name)
            if latest is None:
                return "No version found"
            version = latest['version']
        
        model_version = self.client.get_model_version(
            name=model_name,
            version=version
        )
        
        # Get run info
        run = self.client.get_run(model_version.run_id)
        
        # Build model card
        card = []
        card.append(f"# Model Card: {model_name}")
        card.append(f"## Version: {version}")
        card.append(f"")
        card.append(f"### Model Details")
        card.append(f"- **Stage**: {model_version.current_stage}")
        card.append(f"- **Status**: {model_version.status}")
        card.append(f"- **Created**: {pd.to_datetime(model_version.creation_timestamp, unit='ms')}")
        card.append(f"- **Run ID**: {model_version.run_id}")
        card.append(f"")
        
        # Metrics
        card.append("### Performance Metrics")
        if run.data.metrics:
            for metric, value in run.data.metrics.items():
                card.append(f"- **{metric}**: {value:.4f}")
        else:
            card.append("No metrics found")
        card.append("")
        
        # Parameters
        card.append("### Model Parameters")
        if run.data.params:
            for param, value in run.data.params.items():
                card.append(f"- **{param}**: {value}")
        else:
            card.append("No parameters found")
        card.append("")
        
        # Tags
        card.append("### Tags")
        if run.data.tags:
            for tag, value in run.data.tags.items():
                card.append(f"- **{tag}**: {value}")
        else:
            card.append("No tags found")
        
        card.append("")
        card.append("---")
        card.append(f"Generated: {datetime.now().isoformat()}")
        
        card_text = "\n".join(card)
        
        if output_file:
            with open(output_file, 'w') as f:
                f.write(card_text)
            logger.info(f"Model card saved to {output_file}")
        
        return card_text
EOF
```

### Step 2: Create Model Promotion Pipeline

```bash
cat > scripts/promote_model.py << 'EOF'
#!/usr/bin/env python
"""
Model promotion pipeline with validation.
Promotes models from Staging to Production.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import argparse
import json
import logging
from src.utils.model_registry import ModelRegistryManager
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def promote_model(
    model_name: str,
    version: int,
    require_validation: bool = True,
    thresholds_file: Optional[str] = None
):
    """
    Promote a model to production with validation.
    
    Args:
        model_name: Name of the model
        version: Version number
        require_validation: Whether to require validation
        thresholds_file: JSON file with threshold metrics
    """
    registry = ModelRegistryManager()
    
    # Load thresholds if provided
    thresholds = None
    if thresholds_file and Path(thresholds_file).exists():
        with open(thresholds_file, 'r') as f:
            thresholds = json.load(f)
    
    # Promote the model
    success, message = registry.promote_to_production(
        model_name=model_name,
        version=version,
        require_validation=require_validation,
        threshold_metrics=thresholds
    )
    
    if success:
        logger.info(f"✅ Model promotion successful: {message}")
        
        # Generate model card
        card = registry.create_model_card(
            model_name=model_name,
            version=version
        )
        print("\n" + card)
    else:
        logger.error(f"❌ Model promotion failed: {message}")
        sys.exit(1)


def stage_model(
    model_name: str,
    version: int,
    validation_metrics_file: str,
    thresholds_file: str
):
    """
    Stage a model with validation.
    
    Args:
        model_name: Name of the model
        version: Version number
        validation_metrics_file: JSON file with validation metrics
        thresholds_file: JSON file with threshold metrics
    """
    registry = ModelRegistryManager()
    
    # Load metrics and thresholds
    with open(validation_metrics_file, 'r') as f:
        validation_metrics = json.load(f)
    
    with open(thresholds_file, 'r') as f:
        thresholds = json.load(f)
    
    # Run validation
    passed = registry.stage_validation_pipeline(
        model_name=model_name,
        version=version,
        validation_metrics=validation_metrics,
        threshold_metrics=thresholds
    )
    
    if passed:
        logger.info("✅ Validation passed! Transitioning to Staging...")
        
        # Transition to Staging
        registry.transition_model_stage(
            model_name=model_name,
            version=version,
            stage="Staging"
        )
        
        logger.info(f"Model {model_name} version {version} moved to Staging")
    else:
        logger.error("❌ Validation failed, staying in development stage")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Model promotion pipeline")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Promote command
    promote_parser = subparsers.add_parser("promote", help="Promote to production")
    promote_parser.add_argument("--model", type=str, required=True, help="Model name")
    promote_parser.add_argument("--version", type=int, required=True, help="Version number")
    promote_parser.add_argument("--no-validation", action="store_true", help="Skip validation")
    promote_parser.add_argument("--thresholds", type=str, help="Thresholds JSON file")
    
    # Stage command
    stage_parser = subparsers.add_parser("stage", help="Stage with validation")
    stage_parser.add_argument("--model", type=str, required=True, help="Model name")
    stage_parser.add_argument("--version", type=int, required=True, help="Version number")
    stage_parser.add_argument("--metrics", type=str, required=True, help="Validation metrics JSON file")
    stage_parser.add_argument("--thresholds", type=str, required=True, help="Thresholds JSON file")
    
    args = parser.parse_args()
    
    if args.command == "promote":
        promote_model(
            model_name=args.model,
            version=args.version,
            require_validation=not args.no_validation,
            thresholds_file=args.thresholds
        )
    elif args.command == "stage":
        stage_model(
            model_name=args.model,
            version=args.version,
            validation_metrics_file=args.metrics,
            thresholds_file=args.thresholds
        )
    else:
        parser.print_help()
EOF

chmod +x scripts/promote_model.py
```

### Step 3: Create Validation Configuration

```bash
cat > configs/model_thresholds.json << 'EOF'
{
  "accuracy": 0.85,
  "precision": 0.80,
  "recall": 0.80,
  "f1": 0.82,
  "roc_auc": 0.90
}
EOF
```

### Step 4: Integrate Registry with Training Pipeline

Now let's update our training script to automatically register models:

```bash
cat > models/training/train_with_registry.py << 'EOF'
#!/usr/bin/env python
"""
Training script with automatic model registration.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import argparse
import json
import pickle
import logging
from datetime import datetime
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from sklearn.preprocessing import StandardScaler
import mlflow
from src.utils.mlflow_utils import get_mlflow_manager
from src.utils.model_registry import ModelRegistryManager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def train_and_register(
    features_path: str,
    experiment_name: str = "Production_Training",
    model_name: str = "predictive_maintenance_model",
    test_size: float = 0.2,
    random_state: int = 42,
    register: bool = True,
    auto_stage: bool = False
):
    """
    Train model and register to registry.
    """
    
    # Initialize managers
    mlflow_manager = get_mlflow_manager()
    registry_manager = ModelRegistryManager()
    
    # Load data
    df = pd.read_csv(features_path)
    X = df.drop(columns=['label', 'timestamp'] if 'timestamp' in df.columns else ['label'])
    y = df['label']
    
    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state, stratify=y
    )
    
    # Scale
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train model
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=random_state,
        n_jobs=-1
    )
    model.fit(X_train_scaled, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test_scaled)
    y_pred_proba = model.predict_proba(X_test_scaled)[:, 1]
    
    metrics = {
        'accuracy': accuracy_score(y_test, y_pred),
        'precision': precision_score(y_test, y_pred),
        'recall': recall_score(y_test, y_pred),
        'f1': f1_score(y_test, y_pred),
        'roc_auc': roc_auc_score(y_test, y_pred_proba)
    }
    
    logger.info(f"Model metrics: {json.dumps(metrics, indent=2)}")
    
    # Start MLflow run
    with mlflow_manager.start_run(
        experiment_name=experiment_name,
        run_name=f"training_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        tags={
            'model_name': model_name,
            'training_type': 'production',
            'dataset': Path(features_path).stem
        }
    ):
        # Log parameters and metrics
        mlflow.log_params({
            'test_size': test_size,
            'random_state': random_state,
            'n_estimators': 100,
            'max_depth': 10
        })
        mlflow.log_metrics(metrics)
        
        # Log model
        mlflow.sklearn.log_model(
            model,
            artifact_path="model",
            registered_model_name=model_name if register else None,
            input_example=X_train_scaled[:5]
        )
        
        # Log scaler
        mlflow.sklearn.log_model(
            scaler,
            artifact_path="scaler"
        )
        
        # Log dataset info
        mlflow.log_param("train_samples", len(X_train))
        mlflow.log_param("test_samples", len(X_test))
        mlflow.log_param("features", len(X.columns))
        
        # Get run ID
        run_id = mlflow.active_run().info.run_id
        
        # Register if not done automatically
        if register:
            # Model is already registered via log_model with registered_model_name
            # But we need to get the version
            versions = registry_manager.get_model_versions(model_name)
            if not versions.empty:
                latest_version = versions.iloc[0]['version']
                
                # Add metadata
                registry_manager.add_model_metadata(
                    model_name=model_name,
                    version=latest_version,
                    metadata={
                        'metrics': metrics,
                        'dataset': Path(features_path).stem,
                        'train_samples': len(X_train),
                        'test_samples': len(X_test),
                        'features': len(X.columns)
                    }
                )
                
                # Auto-stage if requested
                if auto_stage and metrics['f1'] > 0.85:
                    logger.info("Model meets performance criteria, transitioning to Staging...")
                    registry_manager.transition_model_stage(
                        model_name=model_name,
                        version=latest_version,
                        stage="Staging"
                    )
                
                logger.info(f"Model registered as version {latest_version}")
        
        # Save validation metrics for later use
        metrics_path = Path(f"models/validation_metrics_{datetime.now().strftime('%Y%m%d')}.json")
        metrics_path.parent.mkdir(parents=True, exist_ok=True)
        with open(metrics_path, 'w') as f:
            json.dump(metrics, f, indent=2)
        
        logger.info(f"Validation metrics saved to {metrics_path}")
        
        return {
            'run_id': run_id,
            'metrics': metrics,
            'model_name': model_name,
            'version': latest_version if register else None
        }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train and register model")
    parser.add_argument("--features", type=str, default="data/processed/features_48h.csv")
    parser.add_argument("--experiment", type=str, default="Production_Training")
    parser.add_argument("--model_name", type=str, default="predictive_maintenance_model")
    parser.add_argument("--test_size", type=float, default=0.2)
    parser.add_argument("--random_state", type=int, default=42)
    parser.add_argument("--no-register", action="store_true", help="Don't register model")
    parser.add_argument("--auto-stage", action="store_true", help="Auto-stage if meets criteria")
    
    args = parser.parse_args()
    
    results = train_and_register(
        features_path=args.features,
        experiment_name=args.experiment,
        model_name=args.model_name,
        test_size=args.test_size,
        random_state=args.random_state,
        register=not args.no_register,
        auto_stage=args.auto_stage
    )
    
    print("\n" + "="*60)
    print("TRAINING COMPLETE")
    print("="*60)
    print(f"Model: {results['model_name']}")
    print(f"Version: {results.get('version', 'Not registered')}")
    print(f"Run ID: {results['run_id']}")
    print("\nMetrics:")
    for metric, value in results['metrics'].items():
        print(f"  {metric}: {value:.4f}")
    print("="*60)
EOF

chmod +x models/training/train_with_registry.py
```

### Step 5: Run the Registry-Integrated Training

```bash
# Train and register a model
python models/training/train_with_registry.py \
    --features data/processed/features_48h.csv \
    --experiment "Production_Training" \
    --model_name "predictive_maintenance_model"

# Check the registry
python -c "
from src.utils.model_registry import ModelRegistryManager
registry = ModelRegistryManager()
versions = registry.get_model_versions('predictive_maintenance_model')
print(versions)
"
```

### Step 6: Stage and Promote Models

```bash
# Stage the model with validation
python scripts/promote_model.py stage \
    --model "predictive_maintenance_model" \
    --version 1 \
    --metrics models/validation_metrics_20240101.json \
    --thresholds configs/model_thresholds.json

# Promote to production
python scripts/promote_model.py promote \
    --model "predictive_maintenance_model" \
    --version 1 \
    --thresholds configs/model_thresholds.json
```

## The Verification: Testing Model Registry

### Verification 1: Check Registered Models

```bash
# List all registered models
python -c "
from mlflow.tracking import MlflowClient
client = MlflowClient()
for rm in client.search_registered_models():
    print(f'{rm.name}: {len(rm.latest_versions)} versions')
    for version in rm.latest_versions:
        print(f'  v{version.version} - {version.current_stage}')
"
```

### Verification 2: Test Model Loading

```bash
# Load latest production model
python -c "
from src.utils.model_registry import ModelRegistryManager
registry = ModelRegistryManager()
model = registry.load_model('predictive_maintenance_model', stage='Production')
print(f'Model loaded: {type(model).__name__}')
"
```

### Verification 3: Check Model Performance History

```bash
# Get performance history
python -c "
from src.utils.model_registry import ModelRegistryManager
registry = ModelRegistryManager()
history = registry.get_model_performance_history('predictive_maintenance_model', 'f1')
print(history)
"
```

## What We've Accomplished

You now have a complete model registry system that:

1. **Manages model versions** with automatic versioning
2. **Implements stage transitions** (Staging → Production → Archived)
3. **Validates models** before promotion
4. **Tracks model metadata** and performance history
5. **Generates model cards** for documentation
6. **Integrates with training pipelines** for automatic registration
7. **Provides CLI tools** for model promotion

## Next Steps

In Phase 3, we'll:
- Set up Dagster for pipeline orchestration
- Build end-to-end DAGs
- Integrate DVC and MLflow with Dagster
- Implement sensors and error handling

---

*End of Part 8: Implementing the Model Registry*
