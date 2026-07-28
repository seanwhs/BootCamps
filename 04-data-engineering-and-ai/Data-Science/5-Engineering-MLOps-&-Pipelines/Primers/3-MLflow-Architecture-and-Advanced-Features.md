# Primer 3: MLflow Architecture and Advanced Features

## The Target: Comprehensive Understanding of MLflow Internals and Advanced Usage

This primer provides an in-depth exploration of MLflow's architecture, components, and advanced features. Understanding these concepts will help you effectively track experiments, manage models, and debug issues in production.

## The Concept: MLflow's Component Architecture

Think of MLflow like a modern hospital system:
- **Tracking Server** = Central patient records (stores all experiment data)
- **Model Registry** = Pharmacy inventory (manages model versions and stages)
- **Projects** = Standard treatment protocols (reproducible research)
- **Models** = Patients being treated (packaged for deployment)

Each component serves a specific purpose and works together to manage the ML lifecycle.

---

## 1. MLflow Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                      MLflow Architecture                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   MLflow Client (SDK)                    │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │  Tracking    │  │  Registry    │  │  Projects    │  │  │
│  │  │  API         │  │  API         │  │  API         │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                 MLflow Tracking Server                   │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │  REST API (HTTP)                                │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │  Backend     │  │  Artifact    │  │  Model       │  │  │
│  │  │  Store       │──│  Store       │  │  Registry    │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│  ┌────────────────────────┼───────────────────────┐          │
│  │                        ▼                       │          │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────┐ │          │
│  │  │  PostgreSQL  │  │  S3/GCS/Azure│  │ File │ │          │
│  │  │  (Metadata)  │  │  (Artifacts) │  │System│ │          │
│  │  └──────────────┘  └──────────────┘  └──────┘ │          │
│  └──────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### Backend Store Options

```python
# File-based backend (local development)
tracking_uri = "file:./mlruns"

# SQL-based backend (production)
tracking_uri = "postgresql://user:pass@localhost/mlflow"

# MySQL
tracking_uri = "mysql://user:pass@localhost/mlflow"

# SQLite
tracking_uri = "sqlite:///mlflow.db"
```

### Artifact Store Options

```python
# Local file system
artifact_location = "./mlflow_artifacts"

# AWS S3
artifact_location = "s3://my-bucket/mlflow-artifacts"

# Google Cloud Storage
artifact_location = "gs://my-bucket/mlflow-artifacts"

# Azure Blob Storage
artifact_location = "azure://container-name/path"
```

---

## 2. MLflow Data Model

### Core Entities

```python
"""
MLflow Data Model:
- Experiment: Container for runs
- Run: Single execution with parameters, metrics, and artifacts
- Model: Registered model in the registry
- ModelVersion: Specific version of a model
"""

# Experiment schema
class Experiment:
    experiment_id: str
    name: str
    artifact_location: str
    lifecycle_stage: str  # active, deleted
    tags: dict
    creation_time: int
    last_update_time: int

# Run schema
class Run:
    info: RunInfo
    data: RunData
    tags: dict

class RunInfo:
    run_id: str
    experiment_id: str
    status: str  # running, finished, failed
    start_time: int
    end_time: int
    lifecycle_stage: str

class RunData:
    metrics: dict  # name -> value
    params: dict   # name -> value
    tags: dict     # name -> value

# Model Version schema
class ModelVersion:
    name: str
    version: int
    run_id: str
    current_stage: str  # Staging, Production, Archived
    status: str  # READY, FAILED, PENDING_REGISTRATION
    description: str
    tags: dict
```

### Database Schema

```sql
-- MLflow tracking database schema (PostgreSQL example)

-- Experiments table
CREATE TABLE experiments (
    experiment_id INTEGER PRIMARY KEY,
    name VARCHAR(256) NOT NULL,
    artifact_location VARCHAR(512),
    lifecycle_stage VARCHAR(20),
    creation_time BIGINT,
    last_update_time BIGINT,
    UNIQUE(name)
);

-- Runs table
CREATE TABLE runs (
    run_id VARCHAR(32) PRIMARY KEY,
    experiment_id INTEGER REFERENCES experiments(experiment_id),
    name VARCHAR(512),
    source_type VARCHAR(20),
    source_name VARCHAR(512),
    user_id VARCHAR(256),
    status VARCHAR(20),
    start_time BIGINT,
    end_time BIGINT,
    source_version VARCHAR(512),
    lifecycle_stage VARCHAR(20),
    artifact_uri VARCHAR(512)
);

-- Metrics table
CREATE TABLE metrics (
    run_id VARCHAR(32) REFERENCES runs(run_id),
    key VARCHAR(250),
    value REAL,
    timestamp BIGINT,
    step BIGINT,
    PRIMARY KEY (run_id, key, step)
);

-- Parameters table
CREATE TABLE params (
    run_id VARCHAR(32) REFERENCES runs(run_id),
    key VARCHAR(250),
    value VARCHAR(500),
    PRIMARY KEY (run_id, key)
);

-- Tags table
CREATE TABLE tags (
    run_id VARCHAR(32) REFERENCES runs(run_id),
    key VARCHAR(250),
    value VARCHAR(500),
    PRIMARY KEY (run_id, key)
);
```

---

## 3. MLflow Tracking Internals

### How Logging Works

```python
import mlflow
import time

"""
MLflow logging flow:
1. Client creates run context
2. Parameters/metrics are buffered locally
3. Flushed to server in batches
4. Artifacts uploaded separately
"""

# Logging with batching
class MLflowLogger:
    def __init__(self, tracking_uri: str):
        self.tracking_uri = tracking_uri
        self.buffer = {
            'metrics': [],
            'params': [],
            'tags': []
        }
        self.batch_size = 100
    
    def log_metric(self, key: str, value: float, step: int = None):
        """Log metric with buffering."""
        self.buffer['metrics'].append({
            'key': key,
            'value': value,
            'step': step or 0,
            'timestamp': int(time.time() * 1000)
        })
        
        if len(self.buffer['metrics']) >= self.batch_size:
            self.flush()
    
    def flush(self):
        """Flush buffer to server."""
        if not self.buffer['metrics']:
            return
        
        # Send to server
        # In practice, uses REST API
        self._send_to_server(self.buffer)
        
        # Clear buffer
        self.buffer['metrics'] = []
    
    def _send_to_server(self, data: dict):
        """Send data to MLflow server (REST API)."""
        import requests
        response = requests.post(
            f"{self.tracking_uri}/api/2.0/mlflow/runs/log-batch",
            json=data
        )
        response.raise_for_status()
```

### REST API Endpoints

```python
"""
MLflow REST API endpoints (v2.0):
- /api/2.0/mlflow/experiments
- /api/2.0/mlflow/runs
- /api/2.0/mlflow/metrics
- /api/2.0/mlflow/params
- /api/2.0/mlflow/tags
- /api/2.0/mlflow/artifacts
"""

import requests

class MLflowClientAPI:
    def __init__(self, base_url: str):
        self.base_url = base_url.rstrip('/')
    
    def create_experiment(self, name: str) -> str:
        """Create a new experiment."""
        response = requests.post(
            f"{self.base_url}/api/2.0/mlflow/experiments/create",
            json={"name": name}
        )
        response.raise_for_status()
        return response.json()['experiment_id']
    
    def get_experiment(self, experiment_id: str) -> dict:
        """Get experiment details."""
        response = requests.get(
            f"{self.base_url}/api/2.0/mlflow/experiments/get",
            params={"experiment_id": experiment_id}
        )
        response.raise_for_status()
        return response.json()['experiment']
    
    def search_runs(self, experiment_id: str) -> list:
        """Search runs in an experiment."""
        response = requests.post(
            f"{self.base_url}/api/2.0/mlflow/runs/search",
            json={"experiment_ids": [experiment_id]}
        )
        response.raise_for_status()
        return response.json()['runs']
    
    def log_metric(self, run_id: str, key: str, value: float):
        """Log a metric to a run."""
        response = requests.post(
            f"{self.base_url}/api/2.0/mlflow/runs/log-metric",
            json={
                "run_id": run_id,
                "key": key,
                "value": value,
                "timestamp": int(time.time() * 1000)
            }
        )
        response.raise_for_status()
```

---

## 4. Model Registry Deep Dive

### Registry Architecture

```python
"""
Model Registry Components:
1. Registered Model: Container for model versions
2. Model Version: Specific instance of a model
3. Stage: Lifecycle state (Staging, Production, Archived)
4. Tag: Metadata annotations
"""

class ModelRegistryManager:
    def __init__(self, tracking_uri: str):
        self.client = mlflow.tracking.MlflowClient(tracking_uri)
    
    def register_model(self, run_id: str, model_path: str, name: str):
        """Register a model from a run."""
        model_uri = f"runs:/{run_id}/{model_path}"
        return self.client.create_model_version(
            name=name,
            source=model_uri,
            run_id=run_id
        )
    
    def transition_stage(self, name: str, version: int, stage: str):
        """Transition model to a new stage."""
        return self.client.transition_model_version_stage(
            name=name,
            version=version,
            stage=stage
        )
    
    def get_latest_versions(self, name: str) -> list:
        """Get latest versions of a model."""
        return self.client.get_latest_versions(name)
    
    def set_model_tag(self, name: str, version: int, key: str, value: str):
        """Set a tag on a model version."""
        return self.client.set_model_version_tag(
            name=name,
            version=version,
            key=key,
            value=value
        )
    
    def update_model_description(self, name: str, version: int, description: str):
        """Update model version description."""
        return self.client.update_model_version(
            name=name,
            version=version,
            description=description
        )
```

### Stage Transition Workflow

```python
import mlflow
from mlflow.tracking import MlflowClient
from typing import Dict, Any

class ModelLifecycleManager:
    """Manage model lifecycle with validation."""
    
    def __init__(self, tracking_uri: str):
        self.client = MlflowClient(tracking_uri)
        self.thresholds = {}
    
    def set_thresholds(self, thresholds: Dict[str, float]):
        """Set validation thresholds."""
        self.thresholds = thresholds
    
    def validate_model(self, run_id: str) -> bool:
        """Validate model against thresholds."""
        run = self.client.get_run(run_id)
        
        for metric, threshold in self.thresholds.items():
            value = run.data.metrics.get(metric)
            if value is None:
                return False
            if value < threshold:
                return False
        
        return True
    
    def register_and_promote(self, run_id: str, model_name: str, 
                           stage: str = "Staging"):
        """Register model and promote to stage."""
        # Validate model
        if not self.validate_model(run_id):
            raise ValueError("Model validation failed")
        
        # Register model
        version = self.client.create_model_version(
            name=model_name,
            source=f"runs:/{run_id}/model",
            run_id=run_id
        )
        
        # Transition to stage
        self.client.transition_model_version_stage(
            name=model_name,
            version=version.version,
            stage=stage
        )
        
        # Add metadata
        self.client.set_model_version_tag(
            name=model_name,
            version=version.version,
            key="validation_passed",
            value="true"
        )
        
        return version
    
    def promote_to_production(self, model_name: str, version: int):
        """Promote to production with archiving."""
        # Archive existing production versions
        production_versions = self.client.get_latest_versions(
            model_name, stages=["Production"]
        )
        
        for prod_version in production_versions:
            self.client.transition_model_version_stage(
                name=model_name,
                version=prod_version.version,
                stage="Archived"
            )
        
        # Promote new version
        self.client.transition_model_version_stage(
            name=model_name,
            version=version,
            stage="Production"
        )
        
        # Add promotion metadata
        self.client.set_model_version_tag(
            name=model_name,
            version=version,
            key="promoted_at",
            value=datetime.now().isoformat()
        )
```

---

## 5. MLflow Artifacts

### Artifact Types

```python
import mlflow

# Text files
mlflow.log_text("Hello World", "hello.txt")

# JSON files
mlflow.log_dict({"key": "value"}, "data.json")

# Images (matplotlib)
import matplotlib.pyplot as plt
fig, ax = plt.subplots()
ax.plot([1, 2, 3], [4, 5, 6])
mlflow.log_figure(fig, "plot.png")

# Plots (using plotly)
import plotly.express as px
fig = px.scatter(x=[1, 2, 3], y=[4, 5, 6])
mlflow.log_figure(fig, "plotly_plot.html")

# Models
mlflow.sklearn.log_model(model, "sklearn_model")
mlflow.pytorch.log_model(model, "pytorch_model")
mlflow.tensorflow.log_model(model, "tf_model")

# Custom artifacts
mlflow.log_artifact("local_file.txt")
mlflow.log_artifacts("local_directory/", artifact_path="dir")
```

### Artifact Storage Structure

```python
# Artifact storage structure (S3 example)
s3://my-bucket/mlflow-artifacts/
└── 1a2b3c4d5e6f7a8b/          # Run ID
    ├── artifacts/
    │   ├── model/
    │   │   ├── model.pkl
    │   │   ├── conda.yaml
    │   │   └── python_env.yaml
    │   ├── plots/
    │   │   ├── confusion_matrix.png
    │   │   └── feature_importance.png
    │   └── data/
    │       └── validation_report.json
    └── metrics/
        ├── accuracy
        └── f1_score
```

### Custom Artifact Handler

```python
class CustomArtifactHandler:
    def __init__(self, run_id: str):
        self.run_id = run_id
        self.artifacts = []
    
    def log_plot(self, fig, filename: str, format: str = 'png'):
        """Log a plot with high quality."""
        import tempfile
        import os
        
        with tempfile.NamedTemporaryFile(suffix=f'.{format}', delete=False) as tmp:
            fig.savefig(tmp.name, format=format, dpi=300, bbox_inches='tight')
            mlflow.log_artifact(tmp.name, artifact_path='plots')
            os.unlink(tmp.name)
        
        self.artifacts.append({
            'type': 'plot',
            'filename': filename,
            'format': format
        })
    
    def log_report(self, data: dict, filename: str):
        """Log a report as JSON."""
        import json
        import tempfile
        
        with tempfile.NamedTemporaryFile(suffix='.json', delete=False) as tmp:
            json.dump(data, tmp, indent=2)
            mlflow.log_artifact(tmp.name, artifact_path='reports')
            os.unlink(tmp.name)
        
        self.artifacts.append({
            'type': 'report',
            'filename': filename
        })
    
    def log_dataset(self, df, name: str):
        """Log a dataset sample."""
        import tempfile
        
        with tempfile.NamedTemporaryFile(suffix='.csv', delete=False) as tmp:
            df.head(1000).to_csv(tmp.name, index=False)
            mlflow.log_artifact(tmp.name, artifact_path=f'datasets/{name}')
            os.unlink(tmp.name)
        
        mlflow.log_param(f'dataset_{name}_rows', len(df))
        self.artifacts.append({
            'type': 'dataset',
            'name': name,
            'rows': len(df)
        })
```

---

## 6. MLflow with Big Data

### Streaming Metrics

```python
import mlflow
import numpy as np
from tqdm import tqdm

class StreamingTrainingTracker:
    """Track training progress with streaming metrics."""
    
    def __init__(self):
        self.metrics = {}
    
    def log_metrics_interval(self, metrics: dict, step: int, interval: int = 10):
        """Log metrics every N steps."""
        for key, value in metrics.items():
            self.metrics.setdefault(key, []).append(value)
        
        if step % interval == 0:
            for key, values in self.metrics.items():
                mlflow.log_metric(f"{key}", np.mean(values), step=step)
            self.metrics = {}  # Reset
    
    def log_training_loop(self, n_epochs: int, n_steps_per_epoch: int):
        """Track training with streaming."""
        for epoch in tqdm(range(n_epochs)):
            for step in range(n_steps_per_epoch):
                # Simulate training
                loss = np.random.random()
                
                # Log metrics
                self.log_metrics_interval(
                    {'loss': loss, 'epoch_loss': loss},
                    step=epoch * n_steps_per_epoch + step,
                    interval=10
                )
            
            # Log epoch metrics
            mlflow.log_metric('epoch', epoch)
```

### Large Artifact Upload

```python
import os
import tempfile
import boto3
from pathlib import Path

class LargeArtifactHandler:
    def __init__(self, tracking_uri: str):
        self.tracking_uri = tracking_uri
    
    def upload_large_file(self, file_path: str, run_id: str, 
                         artifact_path: str = "models"):
        """
        Upload a large file as an artifact using multipart upload.
        """
        file_size = os.path.getsize(file_path)
        chunk_size = 10 * 1024 * 1024  # 10MB chunks
        
        # For very large files, use AWS multipart upload
        if file_size > 100 * 1024 * 1024:  # 100MB
            self._multipart_upload(file_path, run_id, artifact_path)
        else:
            mlflow.log_artifact(file_path, artifact_path=artifact_path)
    
    def _multipart_upload(self, file_path: str, run_id: str, 
                         artifact_path: str):
        """Upload using multipart upload."""
        # Get artifact URI
        run = mlflow.tracking.MlflowClient().get_run(run_id)
        artifact_uri = run.info.artifact_uri
        
        # Parse S3 URI
        if artifact_uri.startswith('s3://'):
            bucket, prefix = self._parse_s3_uri(artifact_uri)
            
            # Upload using boto3 multipart
            s3 = boto3.client('s3')
            key = f"{prefix}/{artifact_path}/{Path(file_path).name}"
            
            with open(file_path, 'rb') as f:
                s3.upload_fileobj(f, bucket, key)
    
    def _parse_s3_uri(self, uri: str) -> tuple:
        """Parse S3 URI into bucket and prefix."""
        # s3://bucket/path/to/artifacts
        parts = uri.replace('s3://', '').split('/', 1)
        return parts[0], parts[1] if len(parts) > 1 else ''
```

---

## 7. MLflow Performance Optimization

### Batch Logging

```python
import mlflow
import threading
import time
from queue import Queue

class BatchLogger:
    """Batch logging for high-frequency metrics."""
    
    def __init__(self, batch_size: int = 100, flush_interval: float = 10.0):
        self.queue = Queue()
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.running = True
        self.thread = threading.Thread(target=self._worker)
        self.thread.start()
    
    def log_metric(self, key: str, value: float, step: int = None):
        """Add metric to batch queue."""
        self.queue.put({
            'key': key,
            'value': value,
            'step': step or 0,
            'timestamp': int(time.time() * 1000)
        })
    
    def _worker(self):
        """Background worker for batch processing."""
        batch = []
        last_flush = time.time()
        
        while self.running:
            try:
                # Get item with timeout
                item = self.queue.get(timeout=1)
                batch.append(item)
                
                # Flush if batch is full or timeout reached
                if len(batch) >= self.batch_size:
                    self._flush_batch(batch)
                    batch = []
                    last_flush = time.time()
                elif time.time() - last_flush > self.flush_interval and batch:
                    self._flush_batch(batch)
                    batch = []
                    last_flush = time.time()
            
            except:
                pass
    
    def _flush_batch(self, batch: list):
        """Flush batch to MLflow."""
        for item in batch:
            mlflow.log_metric(
                item['key'],
                item['value'],
                step=item['step']
            )
    
    def close(self):
        """Close the logger."""
        self.running = False
        self.thread.join()
```

### Connection Pooling

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def get_mlflow_session():
    """Get MLflow session with connection pooling."""
    session = requests.Session()
    
    # Retry strategy
    retry = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
    )
    
    adapter = HTTPAdapter(
        max_retries=retry,
        pool_connections=10,
        pool_maxsize=20
    )
    
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    
    return session
```

---

## 8. MLflow Security

### Authentication

```python
import mlflow
from mlflow.tracking import MlflowClient

# Using environment variables
import os
os.environ['MLFLOW_TRACKING_USERNAME'] = 'user'
os.environ['MLFLOW_TRACKING_PASSWORD'] = 'pass'

# Using basic auth
class AuthClient(MlflowClient):
    def __init__(self, tracking_uri: str, username: str, password: str):
        self.auth = (username, password)
        super().__init__(tracking_uri)
    
    def _call_endpoint(self, path: str, method: str = 'GET', **kwargs):
        # Add auth to requests
        import requests
        response = requests.request(
            method,
            f"{self.tracking_uri}{path}",
            auth=self.auth,
            **kwargs
        )
        return response.json()
```

### Access Control

```python
class MLflowAccessControl:
    """Simple access control for MLflow operations."""
    
    def __init__(self):
        self.permissions = {}
    
    def grant_permission(self, user: str, role: str):
        """Grant a role to a user."""
        self.permissions[user] = role
    
    def check_permission(self, user: str, operation: str) -> bool:
        """Check if user can perform operation."""
        role = self.permissions.get(user)
        if role is None:
            return False
        
        # Define role permissions
        role_permissions = {
            'viewer': ['view_experiments', 'view_runs', 'view_models'],
            'developer': ['view*', 'create_runs', 'log_metrics', 'register_models'],
            'admin': ['*']
        }
        
        if role == 'admin':
            return True
        
        allowed = role_permissions.get(role, [])
        if operation in allowed:
            return True
        
        # Check wildcard permissions
        if any(p.endswith('*') and operation.startswith(p[:-1]) for p in allowed):
            return True
        
        return False
```

---

## Troubleshooting MLflow

### Common Issues

```python
"""
Common MLflow issues and solutions:
1. Connection refused - Check tracking URI
2. Duplicate run IDs - Use unique run names
3. Large artifact upload - Use multipart upload
4. SQLite concurrent writes - Use PostgreSQL
5. Metric name collisions - Use unique prefixes
6. Model loading errors - Check environment compatibility
"""

def diagnose_mlflow():
    """Diagnose common MLflow issues."""
    import mlflow
    
    # Check tracking URI
    uri = mlflow.get_tracking_uri()
    print(f"Tracking URI: {uri}")
    
    # Check connection
    try:
        experiment = mlflow.get_experiment_by_name('test')
        if experiment is not None:
            print("✓ Connection successful")
        else:
            print("✗ Could not connect to tracking server")
    except Exception as e:
        print(f"✗ Connection failed: {e}")
    
    # Check artifact storage
    try:
        with mlflow.start_run() as run:
            mlflow.log_text("Test", "test.txt")
            print("✓ Artifact storage working")
    except Exception as e:
        print(f"✗ Artifact storage failed: {e}")
    
    # Check model registry
    try:
        client = mlflow.tracking.MlflowClient()
        models = client.search_registered_models()
        print(f"✓ Model registry accessible ({len(models)} models)")
    except Exception as e:
        print(f"✗ Model registry failed: {e}")
```

---

*End of Primer 3: MLflow Architecture and Advanced Features*
