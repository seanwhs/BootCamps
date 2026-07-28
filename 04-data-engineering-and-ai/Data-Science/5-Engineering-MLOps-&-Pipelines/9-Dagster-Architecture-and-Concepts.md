# Phase 3: Pipeline Orchestration with Dagster
## Part 9: Dagster Architecture and Concepts

## The Target: Setting Up Dagster for Pipeline Orchestration

In this part, we'll set up Dagster, a modern data orchestration platform, and build our first pipeline. By the end, you'll understand Dagster's architecture and have a working pipeline that orchestrates our MLOps workflow.

## The Concept: Dagster as Your Pipeline Conductor

Think of Dagster like a symphony conductor:
- **Assets** are the musicians (data, models, reports)
- **Ops** are the musical phrases (processing steps)
- **Jobs** are complete pieces (end-to-end pipelines)
- **Schedules** are concert dates (regularly scheduled runs)
- **Sensors** are the conductor's ears (reacting to changes)

Dagster ensures everything plays in harmony, handles mistakes gracefully, and provides full visibility into the performance.

## The Implementation: Dagster Setup

### Step 1: Install and Configure Dagster

```bash
# Ensure Dagster is installed (already in requirements)
pip install dagster dagster-webserver dagster-docker

# Create Dagster home directory
mkdir -p dagster_home
export DAGSTER_HOME=$(pwd)/dagster_home

# Create workspace file
cat > workspace.yaml << 'EOF'
load_from:
  - python_module:
      module_name: pipelines
      attribute: defs
EOF
```

### Step 2: Create Dagster Utilities

```bash
cat > src/utils/dagster_utils.py << 'EOF'
"""
Dagster utilities for pipeline orchestration.
Provides shared functions and resources.
"""

import os
import subprocess
import json
import logging
from typing import Dict, Any, Optional
import pandas as pd
from pathlib import Path
import mlflow
from dagster import (
    Resource, 
    resource, 
    Config, 
    IOManager,
    InputContext,
    OutputContext,
    MaterializationContext
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class MLflowResource(Resource):
    """MLflow resource for Dagster pipelines."""
    
    def __init__(self, tracking_uri: str = "./mlruns"):
        self.tracking_uri = tracking_uri
        mlflow.set_tracking_uri(tracking_uri)
    
    def get_client(self):
        return mlflow.tracking.MlflowClient()


class DVCResource(Resource):
    """DVC resource for Dagster pipelines."""
    
    def __init__(self, project_path: str = "."):
        self.project_path = project_path
    
    def add_file(self, file_path: str):
        """Add a file to DVC."""
        result = subprocess.run(
            ['dvc', 'add', file_path],
            cwd=self.project_path,
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            raise Exception(f"DVC add failed: {result.stderr}")
        return result.stdout
    
    def push(self):
        """Push data to DVC remote."""
        result = subprocess.run(
            ['dvc', 'push'],
            cwd=self.project_path,
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            raise Exception(f"DVC push failed: {result.stderr}")
        return result.stdout
    
    def pull(self):
        """Pull data from DVC remote."""
        result = subprocess.run(
            ['dvc', 'pull'],
            cwd=self.project_path,
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            raise Exception(f"DVC pull failed: {result.stderr}")
        return result.stdout


class DataIOManager(IOManager):
    """Custom IOManager for handling data in Dagster."""
    
    def __init__(self, base_dir: str = "./data"):
        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(parents=True, exist_ok=True)
    
    def handle_output(self, context: OutputContext, obj: pd.DataFrame):
        """Save DataFrame to file."""
        file_path = self.base_dir / f"{context.step_key}_{context.name}.csv"
        obj.to_csv(file_path, index=False)
        context.add_output_metadata({"path": str(file_path)})
        logger.info(f"Saved output to {file_path}")
    
    def load_input(self, context: InputContext) -> pd.DataFrame:
        """Load DataFrame from file."""
        file_path = self.base_dir / f"{context.upstream_output.step_key}_{context.upstream_output.name}.csv"
        if not file_path.exists():
            raise FileNotFoundError(f"Input file not found: {file_path}")
        df = pd.read_csv(file_path)
        logger.info(f"Loaded input from {file_path}")
        return df


class ModelIOManager(IOManager):
    """IOManager for handling model artifacts."""
    
    def __init__(self, base_dir: str = "./models"):
        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(parents=True, exist_ok=True)
    
    def handle_output(self, context: OutputContext, obj: Any):
        """Save model artifact."""
        import pickle
        file_path = self.base_dir / f"{context.step_key}_{context.name}.pkl"
        with open(file_path, 'wb') as f:
            pickle.dump(obj, f)
        context.add_output_metadata({"path": str(file_path)})
        logger.info(f"Saved model to {file_path}")
    
    def load_input(self, context: InputContext) -> Any:
        """Load model artifact."""
        import pickle
        file_path = self.base_dir / f"{context.upstream_output.step_key}_{context.upstream_output.name}.pkl"
        if not file_path.exists():
            raise FileNotFoundError(f"Model file not found: {file_path}")
        with open(file_path, 'rb') as f:
            obj = pickle.load(f)
        logger.info(f"Loaded model from {file_path}")
        return obj


# Shared resources
def get_dagster_resources():
    """Get shared resources for Dagster pipelines."""
    return {
        "mlflow": MLflowResource(),
        "dvc": DVCResource(),
        "data_io": DataIOManager(),
        "model_io": ModelIOManager()
    }
EOF
```

### Step 3: Create Our First Dagster Pipeline

Now let's build our first pipeline with multiple stages:

```bash
cat > pipelines/__init__.py << 'EOF'
"""
Dagster pipeline definitions for MLOps.
"""

from dagster import Definitions
from .pipeline_assets import assets
from .pipeline_ops import jobs
from .schedules import schedules
from .sensors import sensors

defs = Definitions(
    assets=assets,
    jobs=jobs,
    schedules=schedules,
    sensors=sensors
)
EOF
```

```bash
cat > pipelines/pipeline_ops.py << 'EOF'
"""
Dagster operations and jobs for MLOps pipeline.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score
from sklearn.preprocessing import StandardScaler
import mlflow
import json
from datetime import datetime

from dagster import (
    op, 
    job, 
    graph, 
    asset, 
    Output,
    In,
    Out,
    get_dagster_logger,
    resource,
    Config,
    OpExecutionContext
)

from src.utils.dagster_utils import DataIOManager, ModelIOManager
from src.utils.mlflow_utils import get_mlflow_manager


@op(
    required_resource_keys={"dvc", "data_io"},
    out=Out(io_manager_key="data_io")
)
def generate_data(context: OpExecutionContext) -> pd.DataFrame:
    """
    Generate synthetic sensor data.
    """
    logger = context.log
    
    logger.info("Generating synthetic sensor data...")
    
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
    
    # Add labels
    df['label'] = 0
    df.loc[anomaly_indices, 'label'] = 1
    
    logger.info(f"Generated {len(df)} samples with {df['label'].sum()} anomalies")
    
    # Add to DVC
    context.resources.dvc.add_file("data/raw/generated_data.csv")
    context.resources.dvc.push()
    
    return df


@op(
    required_resource_keys={"data_io"},
    ins={"raw_data": In(io_manager_key="data_io")},
    out=Out(io_manager_key="data_io")
)
def process_features(context: OpExecutionContext, raw_data: pd.DataFrame) -> pd.DataFrame:
    """
    Process features from raw data.
    """
    logger = context.log
    
    logger.info("Processing features...")
    
    # Remove timestamp for processing
    X = raw_data.drop(columns=['label', 'timestamp'])
    y = raw_data['label']
    
    # Add rolling statistics
    for col in ['sensor_1', 'sensor_2', 'sensor_3', 'temperature', 'pressure', 'vibration']:
        for window in [5, 10]:
            X[f'{col}_rolling_mean_{window}'] = X[col].rolling(window=window, min_periods=1).mean()
            X[f'{col}_rolling_std_{window}'] = X[col].rolling(window=window, min_periods=1).std()
    
    # Fill NaN values
    X = X.fillna(0)
    
    # Add label back
    X['label'] = y
    
    logger.info(f"Processed features: {X.shape}")
    return X


@op(
    required_resource_keys={"data_io", "model_io"},
    ins={"features": In(io_manager_key="data_io")},
    out=Out(io_manager_key="model_io")
)
def train_model(context: OpExecutionContext, features: pd.DataFrame) -> dict:
    """
    Train a model on the features.
    """
    logger = context.log
    
    logger.info("Training model...")
    
    # Prepare data
    X = features.drop(columns=['label'])
    y = features['label']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Scale
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train
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
        'train_samples': len(X_train),
        'test_samples': len(X_test)
    }
    
    logger.info(f"Model metrics: {json.dumps(metrics, indent=2)}")
    
    # Log to MLflow
    mlflow_manager = get_mlflow_manager()
    with mlflow_manager.start_run(
        experiment_name="Dagster_Pipeline",
        run_name=f"dagster_run_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    ):
        mlflow.log_params({
            'n_estimators': 100,
            'max_depth': 10,
            'test_size': 0.2
        })
        mlflow.log_metrics(metrics)
        mlflow.sklearn.log_model(model, "model")
        mlflow.log_artifact("models/registry/")  # Log model artifacts
    
    # Return model and metrics
    model_data = {
        'model': model,
        'scaler': scaler,
        'metrics': metrics,
        'feature_names': X.columns.tolist()
    }
    
    return model_data


@op(
    required_resource_keys={"data_io"},
    ins={"model_data": In(io_manager_key="model_io")}
)
def evaluate_model(context: OpExecutionContext, model_data: dict) -> dict:
    """
    Evaluate the trained model.
    """
    logger = context.log
    
    logger.info("Evaluating model...")
    
    metrics = model_data['metrics']
    
    # Check if model meets criteria
    passes = metrics['f1'] > 0.80
    
    result = {
        'metrics': metrics,
        'passes_validation': passes,
        'evaluation_time': datetime.now().isoformat()
    }
    
    logger.info(f"Model evaluation: {'PASS' if passes else 'FAIL'}")
    
    # Save evaluation results
    eval_path = Path("models/evaluation/result.json")
    eval_path.parent.mkdir(parents=True, exist_ok=True)
    with open(eval_path, 'w') as f:
        json.dump(result, f, indent=2)
    
    return result


@job(resource_defs={
    "dvc": resource({"project_path": "."}),
    "data_io": DataIOManager(),
    "model_io": ModelIOManager()
})
def mlops_pipeline():
    """
    Complete MLOps pipeline:
    Generate data -> Process features -> Train model -> Evaluate
    """
    raw_data = generate_data()
    features = process_features(raw_data)
    model = train_model(features)
    evaluate_model(model)


# Export jobs for Dagster
jobs = [mlops_pipeline]
EOF
```

### Step 4: Create Dagster Assets

Now let's create assets for better data lineage:

```bash
cat > pipelines/pipeline_assets.py << 'EOF'
"""
Dagster assets for MLOps pipeline.
Assets provide better data lineage and materialization.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
from dagster import asset, AssetExecutionContext, materialize
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score
from sklearn.preprocessing import StandardScaler
import mlflow
import json
from datetime import datetime


@asset
def raw_data_asset() -> pd.DataFrame:
    """
    Asset that generates raw sensor data.
    """
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
    
    return df


@asset
def features_asset(raw_data_asset: pd.DataFrame) -> pd.DataFrame:
    """
    Asset that processes features.
    """
    # Process features
    X = raw_data_asset.drop(columns=['label', 'timestamp'])
    y = raw_data_asset['label']
    
    # Add rolling statistics
    for col in ['sensor_1', 'sensor_2', 'sensor_3', 'temperature', 'pressure', 'vibration']:
        for window in [5, 10]:
            X[f'{col}_rolling_mean_{window}'] = X[col].rolling(window=window, min_periods=1).mean()
            X[f'{col}_rolling_std_{window}'] = X[col].rolling(window=window, min_periods=1).std()
    
    X = X.fillna(0)
    X['label'] = y
    
    return X


@asset
def trained_model_asset(features_asset: pd.DataFrame) -> dict:
    """
    Asset that trains a model.
    """
    # Prepare data
    X = features_asset.drop(columns=['label'])
    y = features_asset['label']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Scale
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train
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
        'train_samples': len(X_train),
        'test_samples': len(X_test)
    }
    
    model_data = {
        'model': model,
        'scaler': scaler,
        'metrics': metrics,
        'feature_names': X.columns.tolist()
    }
    
    return model_data


assets = [raw_data_asset, features_asset, trained_model_asset]
EOF
```

### Step 5: Create Schedules and Sensors

```bash
cat > pipelines/schedules.py << 'EOF'
"""
Dagster schedules for automated pipeline runs.
"""

from dagster import ScheduleDefinition, schedule
from .pipeline_ops import mlops_pipeline


# Run the pipeline daily at midnight
@schedule(
    job=mlops_pipeline,
    cron_schedule="0 0 * * *",
    execution_timezone="UTC"
)
def daily_mlops_pipeline(context):
    """
    Daily MLOps pipeline schedule.
    Runs the complete pipeline every day at midnight UTC.
    """
    return {}


# Run the pipeline every hour for development
@schedule(
    job=mlops_pipeline,
    cron_schedule="0 * * * *",
    execution_timezone="UTC"
)
def hourly_mlops_pipeline(context):
    """
    Hourly MLOps pipeline schedule for development.
    """
    return {}


schedules = [
    daily_mlops_pipeline,
    hourly_mlops_pipeline,
]
EOF
```

```bash
cat > pipelines/sensors.py << 'EOF'
"""
Dagster sensors for reacting to events.
"""

from dagster import sensor, RunRequest, SensorExecutionContext, SkipReason
from pathlib import Path
import yaml
from .pipeline_ops import mlops_pipeline


@sensor(job=mlops_pipeline)
def data_change_sensor(context: SensorExecutionContext):
    """
    Sensor that triggers pipeline when data changes.
    """
    # Check if data file exists
    data_file = Path("data/raw/sensor_data.csv")
    
    if not data_file.exists():
        yield SkipReason("Data file not found")
        return
    
    # Check last modified time
    last_modified = data_file.stat().st_mtime
    last_run = context.cursor if context.cursor else 0
    
    if last_modified > last_run:
        # Data has changed, trigger pipeline
        yield RunRequest(
            run_key=f"data_change_{last_modified}",
            run_config={},
            tags={"trigger": "data_change_sensor"}
        )
        
        # Update cursor
        context.update_cursor(str(last_modified))
    else:
        yield SkipReason("No data changes detected")


@sensor(job=mlops_pipeline)
def model_improvement_sensor(context: SensorExecutionContext):
    """
    Sensor that triggers pipeline when model metrics improve.
    """
    # Check model metrics file
    metrics_file = Path("models/registry/model_metrics.json")
    
    if not metrics_file.exists():
        yield SkipReason("Model metrics file not found")
        return
    
    # Load metrics
    with open(metrics_file, 'r') as f:
        metrics = yaml.safe_load(f)
    
    # Check if metrics improved
    f1_score = metrics.get('f1', 0)
    threshold = 0.85  # Minimum threshold to trigger
    
    if f1_score > threshold:
        yield RunRequest(
            run_key=f"model_improvement_{f1_score}",
            run_config={},
            tags={"trigger": "model_improvement_sensor", "f1_score": f1_score}
        )
    else:
        yield SkipReason(f"Model F1 ({f1_score}) below threshold ({threshold})")


sensors = [
    data_change_sensor,
    model_improvement_sensor,
]
EOF
```

### Step 6: Run the Dagster Pipeline

```bash
# Set up Dagster environment
export DAGSTER_HOME=$(pwd)/dagster_home

# Start the Dagster webserver
dagster-webserver -f pipelines/pipeline_ops.py

# In another terminal, start the Dagster daemon
dagster-daemon run

# Or run the pipeline directly
dagster job execute -f pipelines/pipeline_ops.py -j mlops_pipeline
```

## The Verification: Testing Dagster Pipeline

### Verification 1: Check Pipeline Execution

```bash
# Run the pipeline and see the results
dagster job execute -f pipelines/pipeline_ops.py -j mlops_pipeline -l DEBUG

# Check generated data
ls -la data/
ls -la models/registry/
```

### Verification 2: View Dagster UI

```bash
# Start the web UI
dagster-webserver -f pipelines/pipeline_ops.py

# Open http://localhost:3000 in your browser
# You should see:
# - The pipeline graph
# - Run history
# - Asset lineage
```

### Verification 3: Check MLflow Integration

```bash
# Verify MLflow run was created
python -c "
import mlflow
runs = mlflow.search_runs(experiment_ids=['0'])
print(f'Found {len(runs)} runs')
print(runs[['run_name', 'metrics.f1', 'metrics.accuracy']].head())
"
```

## What We've Accomplished

You now have a working Dagster pipeline that:

1. **Orchestrates the entire MLOps workflow** from data generation to model evaluation
2. **Integrates with DVC** for data versioning
3. **Integrates with MLflow** for experiment tracking
4. **Provides data lineage** through assets
5. **Supports schedules** for automated runs
6. **Has sensors** for event-driven execution
7. **Includes comprehensive logging** and monitoring

## Next Steps

In Part 10, we'll:
- Build more complex DAGs with branching
- Implement error handling and retries
- Create custom resources and IOManagers
- Integrate with external systems

---

*End of Part 9: Dagster Architecture and Concepts*
