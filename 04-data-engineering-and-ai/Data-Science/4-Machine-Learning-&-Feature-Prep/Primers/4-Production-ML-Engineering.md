# Primer 4: Production ML Engineering

## Overview

This primer provides a crash course in production machine learning engineering. It covers the principles, practices, and tools needed to take machine learning models from research to production. Understanding these concepts is crucial for building reliable, scalable, and maintainable ML systems.

---

## 1. The ML Engineering Landscape

### The Evolution of ML Systems

```
┌─────────────────────────────────────────────────────────────────┐
│              ML SYSTEM EVOLUTION                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Notebook → Script → Package → Pipeline → Production System   │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐│
│  │ Jupyter  │───▶│ Python   │───▶│ Python   │───▶│ API +    ││
│  │ Notebook │    │ Script   │    │ Package  │    │ Pipeline ││
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘│
│                                                                 │
│  Research        │    Ad-hoc     │   Reusable   │  Production │
│  Exploration     │    Analysis   │   Code       │  System     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The ML Engineering Disciplines

```
┌─────────────────────────────────────────────────────────────────┐
│                    ML ENGINEERING DISCIPLINES                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   ML Research     ║  ║   ML Engineering  ║                  │
│  ║   (Data Science)  ║  ║   (ML Ops)        ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
│  • Algorithms         │  • Infrastructure                     │
│  • Models             │  • Pipelines                          │
│  • Experiments        │  • Deployment                         │
│  • Evaluation         │  • Monitoring                         │
│  • Papers             │  • Scaling                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Production ML Principles

### The ML Production Pyramid

```
                    ┌─────────────────┐
                    │    Business     │
                    │    Value        │
                    ├─────────────────┤
                    │   Monitoring    │
                    │   & Alerting    │
                    ├─────────────────┤
                    │   Deployment    │
                    │   & Serving     │
                    ├─────────────────┤
                    │   Testing &     │
                    │   Validation    │
                    ├─────────────────┤
                    │   Pipeline      │
                    │   Automation    │
                    ├─────────────────┤
                    │   Data &        │
                    │   Feature Mgmt  │
                    ├─────────────────┤
                    │   Code &        │
                    │   Model Mgmt    │
                    ├─────────────────┤
                    │   Infrastructure│
                    │   & Security    │
                    └─────────────────┘
```

### Key Principles

#### 1. Reliability

- **Graceful Degradation**: Handle failures gracefully
- **Error Handling**: Comprehensive error handling
- **Retry Logic**: Automatic retries for transient failures
- **Timeouts**: Prevent hanging operations
- **Circuit Breakers**: Prevent cascading failures

#### 2. Scalability

- **Horizontal Scaling**: Add more instances
- **Vertical Scaling**: Increase resources
- **Load Balancing**: Distribute traffic
- **Caching**: Reduce computation
- **Batch Processing**: Handle large volumes

#### 3. Maintainability

- **Clean Code**: Readable and well-documented
- **Testing**: Comprehensive test coverage
- **Version Control**: Track all changes
- **Documentation**: Clear and up-to-date
- **Modularity**: Reusable components

#### 4. Reproducibility

- **Versioned Data**: Track data lineage
- **Versioned Code**: Track code versions
- **Versioned Models**: Track model versions
- **Fixed Dependencies**: Pin library versions
- **Random Seeds**: Reproducible experiments

#### 5. Observability

- **Logging**: Comprehensive logging
- **Metrics**: Performance metrics
- **Tracing**: Request tracing
- **Dashboards**: Visual monitoring
- **Alerting**: Proactive notifications

#### 6. Security

- **Authentication**: Verify identities
- **Authorization**: Control access
- **Encryption**: Protect data
- **Audit Logs**: Track access
- **Vulnerability Scanning**: Regular checks

---

## 3. The ML Pipeline

### Training Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    TRAINING PIPELINE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐                                               │
│  │  Data       │                                               │
│  │  Ingestion  │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Data       │                                               │
│  │  Validation │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Feature    │                                               │
│  │  Engineering│                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Model      │                                               │
│  │  Training   │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Model      │                                               │
│  │  Validation │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Model      │                                               │
│  │  Registry   │                                               │
│  └─────────────┘                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Inference Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    INFERENCE PIPELINE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐                                               │
│  │  Request    │                                               │
│  │  (API/HTTP) │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Input      │                                               │
│  │  Validation │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Feature    │                                               │
│  │  Transform  │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Model      │                                               │
│  │  Predict    │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Response   │                                               │
│  │  Formatting │                                               │
│  └──────┬──────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────┐                                               │
│  │  Logging &  │                                               │
│  │  Monitoring │                                               │
│  └─────────────┘                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. ML Ops Tools

### Tool Categories

```
┌─────────────────────────────────────────────────────────────────┐
│                     ML OPS TOOL LANDSCAPE                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Experiment Tracking:                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  MLflow  │  Weights & Biases  │  Neptune  │  DVC        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Data Versioning:                                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  DVC  │  LakeFS  │  Git LFS  │  Delta Lake              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Model Serving:                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  FastAPI  │  Flask  │  TensorFlow Serving  │  TorchServe│  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Workflow Orchestration:                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Airflow  │  Kubeflow  │  ZenML  │  Metaflow            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Monitoring:                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Prometheus  │  Grafana  │  ELK Stack  │  Datadog       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Feature Stores:                                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Feast  │  Tecton  │  Hopsworks  │  Databricks          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Essential ML Ops Tools

#### MLflow (Experiment Tracking)

```python
import mlflow

# Start tracking
mlflow.set_experiment("churn_prediction")

with mlflow.start_run():
    # Log parameters
    mlflow.log_param("model_type", "xgboost")
    mlflow.log_param("n_estimators", 100)
    mlflow.log_param("max_depth", 6)
    
    # Log metrics
    mlflow.log_metric("accuracy", 0.85)
    mlflow.log_metric("roc_auc", 0.92)
    
    # Log model
    mlflow.sklearn.log_model(model, "model")
    
    # Log artifacts
    mlflow.log_artifact("confusion_matrix.png")
```

#### DVC (Data Version Control)

```bash
# Initialize DVC
dvc init

# Track data
dvc add data/raw/data.csv
dvc add models/

# Push to remote
dvc push

# Pull specific version
git checkout <commit>
dvc checkout

# Track pipeline
dvc run -n train \
    -d src/train.py \
    -d data/processed/ \
    -o models/model.pkl \
    python src/train.py
```

#### FastAPI (Model Serving)

```python
from fastapi import FastAPI
from pydantic import BaseModel
import joblib

app = FastAPI()
model = joblib.load('model.pkl')

class PredictionRequest(BaseModel):
    features: dict

@app.post("/predict")
def predict(request: PredictionRequest):
    # Transform features
    X = preprocess(request.features)
    
    # Predict
    prediction = model.predict(X)
    probability = model.predict_proba(X)
    
    return {
        "prediction": int(prediction[0]),
        "probability": float(probability[0][1])
    }
```

#### Prometheus & Grafana (Monitoring)

```python
from prometheus_client import Counter, Histogram, start_http_server

# Define metrics
request_count = Counter('predictions_total', 'Total predictions')
request_latency = Histogram('prediction_latency_seconds', 'Prediction latency')

@request_latency.time()
def predict(request):
    request_count.inc()
    return model.predict(request)

# Start metrics server
start_http_server(8000)
```

---

## 5. Model Serving Patterns

### Serving Architectures

```
┌─────────────────────────────────────────────────────────────────┐
│                    SERVING PATTERNS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. SINGLE MODEL                                               │
│  ┌─────────────┐                                               │
│  │  API → Model│                                               │
│  └─────────────┘                                               │
│                                                                 │
│  2. MULTIPLE MODELS                                            │
│  ┌─────────────────────────────────────┐                       │
│  │     ┌──────────────┐               │                       │
│  │  ──▶│  Model A     │               │                       │
│  │     ├──────────────┤               │                       │
│  │  ──▶│  Model B     │──▶ Aggregate──▶                       │
│  │     ├──────────────┤               │                       │
│  │  ──▶│  Model C     │               │                       │
│  │     └──────────────┘               │                       │
│  └─────────────────────────────────────┘                       │
│                                                                 │
│  3. ENSEMBLE                                                   │
│  ┌─────────────────────────────────────┐                       │
│  │     ┌──────────────┐               │                       │
│  │  ──▶│  Model 1     │               │                       │
│  │     ├──────────────┤               │                       │
│  │  ──▶│  Model 2     │──▶ Ensemble───▶                       │
│  │     ├──────────────┤               │                       │
│  │  ──▶│  Model 3     │               │                       │
│  │     └──────────────┘               │                       │
│  └─────────────────────────────────────┘                       │
│                                                                 │
│  4. MULTI-STAGE (Pipeline)                                     │
│  ┌────────────────────────────────────────────────────────────┐│
│  │  Preprocess → Feature → Model → Post-process              ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Deployment Strategies

| Strategy | Description | When to Use |
|----------|-------------|-------------|
| **Canary** | Gradual rollout to subset | Risky updates |
| **A/B Testing** | Compare two versions | Testing changes |
| **Blue-Green** | Switch between environments | Zero-downtime |
| **Shadow** | Run new model alongside | Test without impact |
| **Multi-armed Bandit** | Dynamic allocation | Optimizing performance |

---

## 6. Monitoring in Production

### What to Monitor

```
┌─────────────────────────────────────────────────────────────────┐
│                    MONITORING CATEGORIES                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INFRASTRUCTURE                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CPU  │  Memory  │  Disk  │  Network  │  Latency         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  APPLICATION                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Requests  │  Errors  │  Response Time  │  Throughput    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  MODEL                                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Predictions  │  Distribution  │  Performance  │  Drift   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  DATA                                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Quality  │  Schema  │  Distribution  │  Missing        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Drift Detection

```python
import numpy as np
from scipy import stats

def detect_drift(reference_data, current_data, threshold=0.05):
    """
    Detect data drift using statistical tests.
    
    Args:
        reference_data: Reference data distribution
        current_data: Current data distribution
        threshold: P-value threshold for drift detection
    
    Returns:
        dict: Drift detection results
    """
    results = {}
    
    # For numeric features: Kolmogorov-Smirnov test
    for col in reference_data.select_dtypes(include=[np.number]).columns:
        if col in current_data.columns:
            ks_stat, p_value = stats.ks_2samp(
                reference_data[col].dropna(),
                current_data[col].dropna()
            )
            results[col] = {
                'test': 'ks',
                'statistic': ks_stat,
                'p_value': p_value,
                'drift_detected': p_value < threshold
            }
    
    # For categorical features: Chi-square test
    for col in reference_data.select_dtypes(include=['object', 'category']).columns:
        if col in current_data.columns:
            ref_counts = reference_data[col].value_counts(normalize=True)
            cur_counts = current_data[col].value_counts(normalize=True)
            
            # Align categories
            all_cats = set(ref_counts.index) | set(cur_counts.index)
            ref_aligned = [ref_counts.get(cat, 0) for cat in all_cats]
            cur_aligned = [cur_counts.get(cat, 0) for cat in all_cats]
            
            chi2_stat, p_value = stats.chisquare(cur_aligned, f_exp=ref_aligned)
            results[col] = {
                'test': 'chi2',
                'statistic': chi2_stat,
                'p_value': p_value,
                'drift_detected': p_value < threshold
            }
    
    return results
```

### Performance Tracking

```python
class ModelPerformanceTracker:
    """Track model performance over time."""
    
    def __init__(self):
        self.predictions = []
        self.ground_truth = []
        self.metrics = []
    
    def log_prediction(self, prediction, features=None):
        self.predictions.append({
            'timestamp': datetime.now(),
            'prediction': prediction,
            'features': features
        })
    
    def log_ground_truth(self, true_value):
        self.ground_truth.append({
            'timestamp': datetime.now(),
            'true_value': true_value
        })
    
    def compute_metrics(self):
        """Compute performance metrics for recent predictions."""
        # Match predictions with ground truth
        matches = self._match_predictions()
        
        if len(matches) == 0:
            return {'accuracy': None, 'f1': None}
        
        # Compute metrics
        y_true = [m['true_value'] for m in matches]
        y_pred = [m['prediction'] for m in matches]
        
        return {
            'accuracy': accuracy_score(y_true, y_pred),
            'f1': f1_score(y_true, y_pred, average='weighted'),
            'precision': precision_score(y_true, y_pred, average='weighted'),
            'recall': recall_score(y_true, y_pred, average='weighted')
        }
    
    def _match_predictions(self):
        """Match predictions with ground truth."""
        # Simplified matching logic
        matches = []
        for pred in self.predictions:
            # Find matching ground truth
            for truth in self.ground_truth:
                if pred['timestamp'].date() == truth['timestamp'].date():
                    matches.append({
                        'prediction': pred['prediction'],
                        'true_value': truth['true_value']
                    })
                    break
        return matches
```

---

## 7. CI/CD for ML

### The ML CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    ML CI/CD PIPELINE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Code Commit                                                    │
│      │                                                          │
│      ▼                                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CI Stage                                                │  │
│  │  ├── Lint & Format Code                                  │  │
│  │  ├── Run Unit Tests                                      │  │
│  │  ├── Run Integration Tests                               │  │
│  │  └── Build Docker Image                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│      │                                                          │
│      ▼                                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  CD Stage                                               │  │
│  │  ├── Deploy to Staging                                  │  │
│  │  ├── Run Smoke Tests                                    │  │
│  │  ├── Run Performance Tests                              │  │
│  │  └── Get Approval                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│      │                                                          │
│      ▼                                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Production Stage                                        │  │
│  │  ├── Deploy to Production                               │  │
│  │  ├── Run Health Checks                                  │  │
│  │  ├── Monitor for Issues                                 │  │
│  │  └── Rollback if Needed                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### GitHub Actions Example

```yaml
name: ML Pipeline CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install -e .
    
    - name: Lint code
      run: |
        black --check src/
        flake8 src/
    
    - name: Run tests
      run: |
        pytest tests/ --cov=src/ --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3

  build:
    needs: test
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: |
        docker build -t ml-pipeline:latest .
        docker tag ml-pipeline:latest ${{ secrets.REGISTRY }}/ml-pipeline:latest
    
    - name: Push to registry
      run: |
        echo ${{ secrets.REGISTRY_PASSWORD }} | docker login -u ${{ secrets.REGISTRY_USER }} --password-stdin
        docker push ${{ secrets.REGISTRY }}/ml-pipeline:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Deploy to production
      run: |
        ssh ${{ secrets.DEPLOY_HOST }} "docker pull ${{ secrets.REGISTRY }}/ml-pipeline:latest && docker-compose up -d"
```

---

## 8. Feature Stores

### What is a Feature Store?

A feature store is a centralized repository for storing, managing, and serving features for machine learning.

```
┌─────────────────────────────────────────────────────────────────┐
│                    FEATURE STORE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Feature Registry                                        │  │
│  │  ├── Feature Definitions                                │  │
│  │  ├── Feature Metadata                                   │  │
│  │  └── Feature Dependencies                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Feature Store                                           │  │
│  │  ├── Historical Features (Training)                     │  │
│  │  └── Online Features (Serving)                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Feature Serving                                         │  │
│  │  ├── Batch Serving (Training Data)                      │  │
│  │  └── Online Serving (Real-time)                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Simple Feature Store Implementation

```python
class FeatureStore:
    """Simple feature store implementation."""
    
    def __init__(self):
        self._features = {}
        self._metadata = {}
        self._online_features = {}
    
    def register_feature(self, name, compute_fn, dependencies=None):
        """Register a feature definition."""
        self._features[name] = {
            'compute_fn': compute_fn,
            'dependencies': dependencies or []
        }
        self._metadata[name] = {
            'created_at': datetime.now(),
            'version': '1.0.0'
        }
    
    def compute_batch(self, features, data):
        """Compute features in batch for training."""
        results = {}
        for name in features:
            if name in self._features:
                fn = self._features[name]['compute_fn']
                results[name] = fn(data)
        return results
    
    def compute_online(self, features, data_point):
        """Compute features online for serving."""
        results = {}
        for name in features:
            if name in self._features:
                fn = self._features[name]['compute_fn']
                results[name] = fn(data_point)
                self._online_features[name] = results[name]
        return results
    
    def get_metadata(self, feature_name):
        """Get feature metadata."""
        return self._metadata.get(feature_name, {})

# Example usage
feature_store = FeatureStore()

# Register features
feature_store.register_feature(
    'customer_tenure',
    lambda x: x['tenure']
)

feature_store.register_feature(
    'avg_monthly_charge',
    lambda x: x['total_charges'] / (x['tenure'] + 1)
)

feature_store.register_feature(
    'has_premium_services',
    lambda x: sum([x.get('online_security', 0), 
                   x.get('online_backup', 0), 
                   x.get('device_protection', 0)])
)

# Compute features
training_features = feature_store.compute_batch(
    ['customer_tenure', 'avg_monthly_charge', 'has_premium_services'],
    training_data
)
```

---

## 9. Model Registry

### What is a Model Registry?

A model registry manages the lifecycle of ML models, including versioning, staging, and deployment.

```python
import json
from datetime import datetime
from pathlib import Path

class ModelRegistry:
    """
    Simple model registry for managing model versions.
    
    Tracks:
    - Model versions
    - Performance metrics
    - Training metadata
    - Deployment status
    """
    
    def __init__(self, registry_path='models/registry.json'):
        self.registry_path = Path(registry_path)
        self.registry = self._load_registry()
    
    def _load_registry(self):
        """Load registry from disk."""
        if self.registry_path.exists():
            with open(self.registry_path, 'r') as f:
                return json.load(f)
        return {'models': [], 'deployments': {}}
    
    def _save_registry(self):
        """Save registry to disk."""
        with open(self.registry_path, 'w') as f:
            json.dump(self.registry, f, indent=2)
    
    def register_model(self, model_path, metadata):
        """Register a new model version."""
        model_id = f"model_{len(self.registry['models']) + 1}"
        timestamp = datetime.now().isoformat()
        
        entry = {
            'id': model_id,
            'path': str(model_path),
            'version': metadata.get('version', '1.0.0'),
            'metrics': metadata.get('metrics', {}),
            'parameters': metadata.get('parameters', {}),
            'created_at': timestamp,
            'status': 'staged'
        }
        
        self.registry['models'].append(entry)
        self._save_registry()
        return model_id
    
    def promote_to_production(self, model_id):
        """Promote a model to production."""
        for model in self.registry['models']:
            if model['id'] == model_id:
                model['status'] = 'production'
                self.registry['deployments']['production'] = {
                    'model_id': model_id,
                    'deployed_at': datetime.now().isoformat()
                }
                self._save_registry()
                return True
        return False
    
    def get_production_model(self):
        """Get the current production model."""
        deployment = self.registry['deployments'].get('production')
        if not deployment:
            return None
        
        for model in self.registry['models']:
            if model['id'] == deployment['model_id']:
                return model
        return None
    
    def list_models(self, status=None):
        """List all models, optionally filtered by status."""
        models = self.registry['models']
        if status:
            models = [m for m in models if m.get('status') == status]
        return models
    
    def get_model_performance(self, model_id):
        """Get performance metrics for a model."""
        for model in self.registry['models']:
            if model['id'] == model_id:
                return model.get('metrics', {})
        return {}

# Example usage
registry = ModelRegistry()

# Register a model
registry.register_model(
    'models/churn_v1.pkl',
    {
        'version': '1.0.0',
        'metrics': {'accuracy': 0.85, 'roc_auc': 0.92},
        'parameters': {'n_estimators': 100, 'max_depth': 6}
    }
)

# Promote to production
registry.promote_to_production('model_1')

# Get production model
production_model = registry.get_production_model()
```

---

## 10. Best Practices Summary

### Development

```
✅ Write clean, modular code
✅ Use type hints and docstrings
✅ Implement comprehensive tests
✅ Version all code, data, and models
✅ Use configuration files for parameters
✅ Log all experiments and runs
✅ Document design decisions
✅ Review code with peers
```

### Training

```
✅ Split data before preprocessing
✅ Use cross-validation for evaluation
✅ Monitor for data leakage
✅ Track all hyperparameters
✅ Save model with all dependencies
✅ Log training metrics
✅ Validate on held-out test set
✅ Compare with baseline models
```

### Deployment

```
✅ Use containerization (Docker)
✅ Implement health checks
✅ Add request/response validation
✅ Use appropriate deployment strategy
✅ Set up monitoring and alerting
✅ Plan for rollback
✅ Document API endpoints
✅ Test in staging before production
```

### Monitoring

```
✅ Monitor system metrics
✅ Track model performance
✅ Detect data drift
✅ Monitor prediction distributions
✅ Set up alerts for anomalies
✅ Log all requests and responses
✅ Track business metrics
✅ Create dashboards for visibility
```

---

## Quick Reference: Production ML Checklist

```
□ 1. Code Version Control (Git)
□ 2. Data Version Control (DVC)
□ 3. Experiment Tracking (MLflow)
□ 4. Model Registry
□ 5. CI/CD Pipeline
□ 6. Containerization (Docker)
□ 7. API Service (FastAPI)
□ 8. Monitoring (Prometheus/Grafana)
□ 9. Drift Detection
□ 10. Alerting System
□ 11. Documentation
□ 12. Rollback Plan
```

---

## Conclusion

This primer covers the fundamentals of production ML engineering. You now understand:

1. **The ML engineering disciplines** and how they work together
2. **Production principles**: reliability, scalability, maintainability
3. **Pipeline architecture**: training and inference pipelines
4. **ML Ops tools**: experiment tracking, model serving, monitoring
5. **Serving patterns**: different ways to serve models
6. **Monitoring**: what to monitor and how to detect drift
7. **CI/CD**: automating the ML pipeline
8. **Feature stores**: centralized feature management
9. **Model registry**: versioning and managing models

**Next Steps:**
1. Practice with MLflow for experiment tracking
2. Build a simple API with FastAPI
3. Set up monitoring for a model
4. Implement a CI/CD pipeline
5. Proceed to Part 1 of the series

---

*End of Primer 4*
