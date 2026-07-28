# Student Notes: MLOps Pipeline Engineering

## Comprehensive Lecture Notes and Reference Material

---

# PART 0: INTRODUCTION TO MLOPS

## What is MLOps?

### Definition
MLOps (Machine Learning Operations) is the practice of combining machine learning, data engineering, and DevOps to deploy and maintain ML systems in production.

### The MLOps Lifecycle
```
┌─────────────────────────────────────────────────────────────────┐
│                    MLOps Lifecycle                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │  Data    │ →  │  Model   │ →  │  Model   │ →  │  Model   │ │
│  │  Prep    │    │  Train   │    │  Eval    │    │  Deploy  │ │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│       ↓              ↓              ↓              ↓          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │  Data    │    │  Model   │    │  Model   │    │  Model   │ │
│  │  Version │    │  Track   │    │  Registry│    │  Monitor │ │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Principles
1. **Reproducibility** - Every run should be reproducible
2. **Version Control** - Track code, data, and models
3. **Automation** - Automate everything possible
4. **Monitoring** - Always monitor performance
5. **Security** - Protect data and models

---

## The Three Pillars of MLOps

### 1. Data Version Control (DVC)
- **Purpose:** Version large datasets and models
- **Key Features:**
  - Git for data
  - Pipeline management
  - Remote storage
  - Reproducibility

### 2. Experiment Tracking (MLflow)
- **Purpose:** Track ML experiments
- **Key Features:**
  - Parameter logging
  - Metric tracking
  - Artifact storage
  - Model registry

### 3. Pipeline Orchestration (Dagster)
- **Purpose:** Automate workflows
- **Key Features:**
  - DAG execution
  - Dependency management
  - Error handling
  - Scheduling

---

## The Use Case: Predictive Maintenance

### Problem Statement
Manufacturing equipment sensors generate data that can predict failures before they occur.

### Key Components
- **Data:** Sensor readings (temperature, pressure, vibration)
- **Goal:** Predict anomalies (normal vs. anomaly)
- **Model:** Classification model
- **Deployment:** REST API for real-time predictions

### Data Schema
```python
{
    'timestamp': datetime,
    'sensor_1': float,      # Temperature sensor
    'sensor_2': float,      # Pressure sensor
    'sensor_3': float,      # Vibration sensor
    'temperature': float,   # Machine temperature
    'pressure': float,      # System pressure
    'vibration': float,     # Vibration level
    'label': int           # 0=normal, 1=anomaly
}
```

---

# PART 1: DATA VERSION CONTROL WITH DVC

## DVC Fundamentals

### What is DVC?
- Data Version Control
- Open source tool
- Works with Git
- Manages large files

### How DVC Works
```
┌─────────────────────────────────────────────────────────────────┐
│                    DVC Architecture                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Git Repository                    DVC Cache                   │
│  ┌─────────────────┐              ┌─────────────────────────┐ │
│  │  .dvc Files     │     ↕       │  .dvc/cache/            │ │
│  │  (Pointers)     │              │  (Actual Data)          │ │
│  │                 │              │                         │ │
│  │  dvc.yaml       │              │  Remote Storage          │ │
│  │  (Pipeline)     │     ↕       │  ┌─────────────────┐    │ │
│  └─────────────────┘              │  │  S3/GCS/Azure   │    │ │
│                                   │  └─────────────────┘    │ │
│                                   └─────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Commands Cheat Sheet

| Command | Purpose |
|---------|---------|
| `dvc init` | Initialize DVC |
| `dvc add <file>` | Track a file |
| `dvc status` | Check changes |
| `dvc push` | Upload to remote |
| `dvc pull` | Download from remote |
| `dvc checkout` | Restore data |
| `dvc repro` | Run pipeline |

### DVC File Structure
```yaml
# data.csv.dvc
outs:
- md5: a1b2c3d4e5f6  # Data hash
  path: data.csv      # File path
  size: 1024          # File size
  cache: true         # Cache enabled
wdir: .               # Working directory
```

---

## DVC Pipelines

### Pipeline Definition (dvc.yaml)
```yaml
stages:
  stage_name:
    cmd: python script.py
    deps:
      - input.csv
      - script.py
    outs:
      - output.csv
    params:
      - params.yaml#parameter
    metrics:
      - metrics.json
    plots:
      - plot.png
```

### Pipeline Execution
```bash
# Run pipeline
dvc repro

# Check pipeline status
dvc status

# View pipeline graph
dvc dag

# Run specific stage
dvc repro stage_name

# Force run all
dvc repro --force
```

### Parameterization (params.yaml)
```yaml
data:
  raw:
    hours: 48
    anomaly_rate: 0.05

features:
  windows: [5, 10, 30]

model:
  test_size: 0.2
  random_state: 42
```

### Using Parameters in Python
```python
import yaml

with open('params.yaml', 'r') as f:
    params = yaml.safe_load(f)

hours = params['data']['raw']['hours']
test_size = params['model']['test_size']
```

---

## DVC Remote Storage

### Remote Configuration
```bash
# Add remote
dvc remote add -d remote_name s3://bucket/path

# Configure remote
dvc remote modify remote_name region us-east-1

# List remotes
dvc remote list
```

### Remote Types
| Type | URL Format | Use Case |
|------|------------|----------|
| AWS S3 | `s3://bucket/path` | Cloud storage |
| GCS | `gs://bucket/path` | Cloud storage |
| Azure | `azure://container/path` | Cloud storage |
| SSH | `ssh://user@host/path` | On-premises |
| Local | `/path/to/storage` | Development |

### Credential Management
```bash
# Environment variables
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

# .env file
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
```

---

# PART 2: EXPERIMENT TRACKING WITH MLFLOW

## MLflow Fundamentals

### What is MLflow?
- Open source platform
- Manages ML lifecycle
- Four main components

### MLflow Components
```
┌─────────────────────────────────────────────────────────────────┐
│                    MLflow Components                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Tracking   │  │   Projects   │  │    Models   │       │
│  │   (Logging)  │  │  (Reproduce) │  │  (Package)  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Model Registry                          │  │
│  │  (Model Management)                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Concepts
- **Experiment:** Container for runs
- **Run:** Single execution
- **Parameters:** Input values
- **Metrics:** Output values
- **Artifacts:** Files/objects
- **Tags:** Metadata

### MLflow Data Model
```
Experiment
  └── Run
        ├── Parameters
        ├── Metrics
        ├── Tags
        └── Artifacts
              ├── Model
              ├── Plots
              └── Files
```

---

## MLflow Tracking

### Setup
```python
import mlflow

# Set tracking URI
mlflow.set_tracking_uri("file:./mlruns")

# Set experiment
mlflow.set_experiment("experiment_name")
```

### Logging Parameters
```python
# Single parameter
mlflow.log_param("learning_rate", 0.01)

# Multiple parameters
params = {
    "n_estimators": 100,
    "max_depth": 10,
    "random_state": 42
}
mlflow.log_params(params)
```

### Logging Metrics
```python
# Single metric
mlflow.log_metric("accuracy", 0.95)

# Multiple metrics
mlflow.log_metrics({
    "accuracy": 0.95,
    "f1": 0.93,
    "precision": 0.94
})

# Metrics with step (training loop)
for epoch in range(epochs):
    loss = train_step()
    mlflow.log_metric("loss", loss, step=epoch)
```

### Logging Artifacts
```python
# Text
mlflow.log_text("Hello World", "hello.txt")

# JSON
mlflow.log_dict({"key": "value"}, "data.json")

# Image
mlflow.log_figure(fig, "plot.png")

# Model
mlflow.sklearn.log_model(model, "sklearn_model")

# Custom file
mlflow.log_artifact("file.txt")
```

---

## MLflow Model Registry

### Registry Concepts
- **Registered Model:** Named collection
- **Model Version:** Specific version
- **Stage:** Lifecycle state
- **Tag:** Metadata label

### Stages
```
Development → Staging → Production → Archived
     ↓           ↓           ↓           ↓
  Experiment  Testing    Serving    Historical
  Tracking    Validation  Deployment  Record
```

### Registry Operations
```python
from mlflow.tracking import MlflowClient

client = MlflowClient()

# Register model
version = client.create_model_version(
    name="my_model",
    source="runs:/run_id/model",
    run_id="run_id"
)

# Transition stage
client.transition_model_version_stage(
    name="my_model",
    version=1,
    stage="Production"
)

# Get latest versions
latest = client.get_latest_versions("my_model")
```

---

## MLflow UI

### Starting the UI
```bash
# Local UI
mlflow ui

# With backend store
mlflow ui --backend-store-uri ./mlruns

# Remote server
mlflow server --host 0.0.0.0 --port 5000
```

### UI Features
1. **Experiments List**
   - View all experiments
   - Create new experiments

2. **Run Details**
   - Parameters
   - Metrics
   - Artifacts
   - Tags

3. **Comparison View**
   - Parallel coordinates
   - Scatter plots
   - Metric visualization

4. **Model Registry**
   - View models
   - Manage stages
   - View versions

---

# PART 3: PIPELINE ORCHESTRATION WITH DAGSTER

## Dagster Fundamentals

### What is Dagster?
- Data orchestration platform
- Modern alternative to Airflow
- Type-safe and testable
- Asset-aware

### Core Concepts
```
┌─────────────────────────────────────────────────────────────────┐
│                    Dagster Core Concepts                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │    Assets    │  │     Ops      │  │     Jobs     │       │
│  │  (Data)      │  │  (Logic)     │  │  (Graphs)    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Schedules   │  │   Sensors    │  │  Resources   │       │
│  │  (Time)      │  │  (Events)    │  │  (Services)  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Definitions

**Ops** - Transformations
```python
from dagster import op

@op
def process_data(data):
    return data * 2
```

**Assets** - Data artifacts
```python
from dagster import asset

@asset
def raw_data():
    return pd.DataFrame()
```

**Jobs** - Pipelines of ops
```python
from dagster import job

@job
def my_pipeline():
    processed = process_data(raw_data())
    return processed
```

**Schedules** - Time-based triggers
```python
from dagster import schedule

@schedule(job=my_pipeline, cron_schedule="0 0 * * *")
def daily_schedule():
    return {}
```

**Sensors** - Event-based triggers
```python
from dagster import sensor

@sensor(job=my_pipeline)
def file_sensor():
    if new_data_available():
        return RunRequest(...)
```

---

## Dagster Architecture

### Components
```
┌─────────────────────────────────────────────────────────────────┐
│                    Dagster Architecture                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   User Code                              │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │   Assets   │  │    Ops     │  │    Jobs    │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                Dagster API (gRPC)                       │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │ Execution  │  │  Schedule  │  │  Sensors   │       │  │
│  │  │  Engine    │  │  Manager   │  │  Manager   │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                  Storage Layer                           │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │    Run     │  │   Event    │  │   Asset    │       │  │
│  │  │  Storage   │  │    Log     │  │   Store    │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Resource Management
```python
from dagster import resource

@resource
def database_resource():
    import psycopg2
    return psycopg2.connect("...")

@op(required_resource_keys={"database"})
def query_data(context):
    conn = context.resources.database
    return conn.execute("SELECT * FROM data")
```

### I/O Managers
```python
from dagster import IOManager

class CustomIOManager(IOManager):
    def handle_output(self, context, obj):
        # Save output
        pass
    
    def load_input(self, context):
        # Load input
        pass
```

---

## Error Handling in Dagster

### Retry Policies
```python
from dagster import RetryPolicy

@op(
    retry_policy=RetryPolicy(
        max_retries=3,
        delay=5,
        backoff=2
    )
)
def retryable_op():
    # Code that might fail
    pass
```

### Failure Handling
```python
from dagster import Failure, op

@op
def error_handling_op():
    try:
        # Risky operation
        result = risky_operation()
    except Exception as e:
        raise Failure(f"Operation failed: {e}")
    return result
```

### Hooks
```python
from dagster import hook, run_failure_hook

@hook
def log_failure_hook(context, failure):
    context.log.error(f"Failure: {failure}")

@run_failure_hook
def send_alert_hook(context, failure):
    # Send alert
    send_slack_alert(f"Pipeline failed: {failure}")
```

---

# PART 4: INTEGRATION AND DEPLOYMENT

## Complete System Architecture

### Three-Tier Integration
```
┌─────────────────────────────────────────────────────────────────┐
│                   Complete MLOps Architecture                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           DAGSTER (Orchestration)                        │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │  Schedules │  │  Sensors   │  │    Jobs    │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│  ┌────────────────────────┼───────────────────────────┐      │
│  │                        │                           │      │
│  ▼                        ▼                           ▼      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     DVC      │  │    MLflow    │  │   Registry   │      │
│  │  (Data)      │  │  (Track)     │  │  (Model)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              DEPLOYMENT                                  │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │  API       │  │  Batch     │  │  Edge      │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           MONITORING                                     │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │  Metrics   │  │   Logs     │  │   Alerts   │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Integration Points

**DVC ↔ Dagster**
```python
# Pull data before pipeline
@op(required_resource_keys={"dvc"})
def pull_data(context):
    context.resources.dvc.pull()
    return "Data pulled"
```

**MLflow ↔ Dagster**
```python
# Log experiment in pipeline
@op(required_resource_keys={"mlflow"})
def train_with_mlflow(context):
    with mlflow.start_run():
        # Train model
        mlflow.log_metric("accuracy", accuracy)
        return model
```

**DVC ↔ MLflow**
```python
# Log data version in MLflow
with dvc.api.open(data_path) as f:
    data_hash = hashlib.md5(f.read()).hexdigest()
    mlflow.log_param("data_version", data_hash)
```

---

## Deployment Strategies

### REST API Deployment
```python
from fastapi import FastAPI
import mlflow

app = FastAPI()

# Load model
model = mlflow.sklearn.load_model("models:/model/Production")

@app.post("/predict")
def predict(features: list):
    prediction = model.predict([features])
    return {"prediction": prediction.tolist()}
```

### Blue-Green Deployment
```
┌─────────────────────────────────────────────────────────────────┐
│                   Blue-Green Deployment                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Step 1: Deploy to Green (Inactive)                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Blue (Active)  │  Green (Inactive)                     │  │
│  │  ┌────────────┐ │  ┌────────────┐                      │  │
│  │  │  Model V1  │ │  │  Model V2  │                      │  │
│  │  └────────────┘ │  └────────────┘                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Step 2: Test Green                                             │
│  Run smoke tests, validation                                    │
│                                                                 │
│  Step 3: Switch Traffic                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Blue (Inactive) │  Green (Active)                      │  │
│  │  ┌────────────┐  │  ┌────────────┐                     │  │
│  │  │  Model V1  │  │  │  Model V2  │                     │  │
│  │  └────────────┘  │  └────────────┘                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### CI/CD Pipeline
```yaml
stages:
  test:
    - Run unit tests
    - Run integration tests
  
  build:
    - Build model
    - Package artifacts
  
  deploy-staging:
    - Deploy to staging
    - Run validation tests
  
  deploy-production:
    - Blue-green deployment
    - Health check
    - Monitor
```

---

## Monitoring and Alerting

### Key Metrics

**System Metrics**
- CPU usage
- Memory usage
- Disk usage
- Network I/O

**Application Metrics**
- Request count
- Response time
- Error rate
- Throughput

**Model Metrics**
- Accuracy
- Latency
- Drift score
- Confidence scores

### Alert Configuration
```python
alerts = {
    'high_latency': {
        'condition': 'latency_p95 > 100ms',
        'severity': 'warning',
        'action': 'slack'
    },
    'model_drift': {
        'condition': 'drift_score > 0.5',
        'severity': 'critical',
        'action': 'pagerduty'
    },
    'pipeline_failure': {
        'condition': 'pipeline_status == failed',
        'severity': 'critical',
        'action': 'email+slack'
    }
}
```

### Dashboard Structure
```
┌─────────────────────────────────────────────────────────────────┐
│              MLOps Dashboard                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Model Performance                                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Accuracy: 0.95 ↑  │  F1: 0.93 →  │  Latency: 45ms ↓  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  System Health                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CPU: 45%  │  Memory: 60%  │  Disk: 30%  │  Network: 50%│  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Recent Alerts                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ⚠️ Latency spike detected at 14:23                     │  │
│  │  ✅ All systems normal                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

# GLOSSARY

## A
- **Artifact**: File or object stored in MLflow (models, plots, data)
- **Asset**: Data artifact in Dagster (tables, files, models)
- **AUC**: Area Under the ROC Curve - model performance metric

## B
- **Backend Store**: Database storing MLflow metadata
- **Batch Prediction**: Processing multiple predictions at once
- **Blue-Green Deployment**: Zero-downtime deployment strategy

## C
- **Cache**: Local storage of versioned data in DVC
- **Canary Deployment**: Gradual rollout of new model
- **CI/CD**: Continuous Integration/Continuous Deployment
- **Context Manager**: Python construct for resource management

## D
- **DAG**: Directed Acyclic Graph - pipeline structure
- **DVC**: Data Version Control - versioning for data
- **Drift**: Model performance degradation over time

## E
- **Experiment**: Container for MLflow runs
- **Exploratory Data Analysis**: Initial data investigation

## F
- **F1 Score**: Harmonic mean of precision and recall
- **Feature**: Input variable for model

## G
- **Grafana**: Visualization and dashboard tool
- **Git**: Version control system for code

## H
- **Hook**: Lifecycle event handler in Dagster
- **Hyperparameter**: Model configuration parameter

## I
- **I/O Manager**: Data persistence in Dagster
- **Inference**: Making predictions with model

## J
- **Job**: Collection of ops to execute in Dagster
- **JSON**: JavaScript Object Notation - data format

## K
- **Kubernetes**: Container orchestration platform
- **K-fold**: Cross-validation technique

## L
- **Lineage**: Data tracking from source to destination
- **Logging**: Recording events and metrics

## M
- **Metrics**: Numeric values tracked over runs
- **MLflow**: Platform for ML lifecycle management
- **Model Registry**: Centralized model repository

## O
- **Op**: Operation in Dagster (transformation)
- **Observability**: System monitoring and insight

## P
- **Parameters**: Input values for model training
- **Pipeline**: Sequence of data processing steps
- **Precision**: True positives / (True + False positives)
- **Prometheus**: Metrics collection and monitoring

## R
- **Recall**: True positives / (True + False negatives)
- **Registry**: Centralized model repository
- **Reproducibility**: Ability to reproduce results
- **Resource**: Shared service in Dagster
- **Run**: Single execution in MLflow

## S
- **Schedule**: Time-based trigger in Dagster
- **Sensor**: Event-based trigger in Dagster
- **Stage**: Model lifecycle state (Staging, Production, Archived)
- **Staging**: Test environment before production

## T
- **Tags**: Key-value metadata in MLflow/Dagster
- **Tracking**: Experiment logging in MLflow
- **Training**: Process of building model

## V
- **Version**: Specific snapshot of data/model
- **Version Control**: Tracking changes over time

## Y
- **YAML**: Yet Another Markup Language - configuration format

---

# QUICK REFERENCE CARDS

## DVC Quick Reference
```bash
# Initialize
dvc init

# Version data
dvc add <file>

# Remote operations
dvc push
dvc pull

# Pipeline
dvc repro
dvc status
dvc dag
```

## MLflow Quick Reference
```python
# Setup
import mlflow
mlflow.set_tracking_uri("file:./mlruns")
mlflow.set_experiment("experiment")

# Logging
with mlflow.start_run():
    mlflow.log_param("param", value)
    mlflow.log_metric("metric", value)
    mlflow.log_artifact("file.txt")
    mlflow.sklearn.log_model(model, "model")
```

## Dagster Quick Reference
```python
from dagster import op, asset, job, schedule

# Op
@op
def my_op():
    return "result"

# Asset
@asset
def my_asset():
    return "data"

# Job
@job
def my_job():
    result = my_op()
    return result

# Schedule
@schedule(job=my_job, cron_schedule="0 0 * * *")
def my_schedule():
    return {}
```

---

**End of Student Notes**
