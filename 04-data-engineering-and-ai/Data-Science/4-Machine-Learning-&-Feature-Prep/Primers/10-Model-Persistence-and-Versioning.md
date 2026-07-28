# Primer 10: Model Persistence and Versioning

## Overview

This primer provides a comprehensive guide to model persistence and versioning—critical skills for deploying and maintaining machine learning models in production. Understanding how to save, load, and version models ensures reproducibility, enables easy rollback, and supports continuous deployment.

---

## 1. Model Persistence Fundamentals

### Why Persistence Matters

```
┌─────────────────────────────────────────────────────────────────┐
│              WHY MODEL PERSISTENCE MATTERS                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Deployment                                                  │
│     └── Models need to be saved after training                 │
│                                                                 │
│  2. Reproducibility                                             │
│     └── Same model can be recreated exactly                   │
│                                                                 │
│  3. Sharing                                                     │
│     └── Models can be shared with team members                │
│                                                                 │
│  4. Versioning                                                  │
│     └── Track different model versions                        │
│                                                                 │
│  5. Auditing                                                    │
│     └── Keep record of what was deployed                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Persistence Methods Comparison

| Method | Best For | Pros | Cons |
|--------|----------|------|------|
| **Joblib** | Scikit-learn models | Efficient for numpy arrays | Limited to Python |
| **Pickle** | General Python objects | Universal Python serialization | Security risks |
| **ONNX** | Cross-platform deployment | Works with many frameworks | Limited operator support |
| **PyTorch** | PyTorch models | Native format | Only for PyTorch |
| **TensorFlow** | TensorFlow models | Native format | Only for TensorFlow |
| **MLflow** | Production systems | Metadata + model tracking | Requires MLflow |

---

## 2. Saving and Loading Models

### Joblib (Recommended for Scikit-learn)

```python
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline

def save_pipeline(pipeline, filepath):
    """Save pipeline using joblib."""
    joblib.dump(pipeline, filepath)
    print(f"Pipeline saved to: {filepath}")

def load_pipeline(filepath):
    """Load pipeline using joblib."""
    pipeline = joblib.load(filepath)
    print(f"Pipeline loaded from: {filepath}")
    return pipeline

# Example
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('model', RandomForestClassifier())
])

# Save
save_pipeline(pipeline, 'models/pipeline.joblib')

# Load
loaded_pipeline = load_pipeline('models/pipeline.joblib')
```

### Pickle

```python
import pickle

def save_pickle_model(model, filepath):
    """Save model using pickle."""
    with open(filepath, 'wb') as f:
        pickle.dump(model, f)
    print(f"Model saved to: {filepath}")

def load_pickle_model(filepath):
    """Load model using pickle."""
    with open(filepath, 'rb') as f:
        model = pickle.load(f)
    print(f"Model loaded from: {filepath}")
    return model

# Save with higher protocol (faster)
def save_pickle_fast(model, filepath):
    with open(filepath, 'wb') as f:
        pickle.dump(model, f, protocol=pickle.HIGHEST_PROTOCOL)
```

### PyTorch

```python
import torch
import torch.nn as nn

def save_pytorch_model(model, filepath):
    """Save PyTorch model."""
    # Save model state dict (recommended)
    torch.save(model.state_dict(), filepath)
    print(f"Model state dict saved to: {filepath}")

def save_pytorch_model_full(model, filepath):
    """Save full PyTorch model (not recommended for large models)."""
    torch.save(model, filepath)
    print(f"Full model saved to: {filepath}")

def load_pytorch_model(model_class, filepath, *args, **kwargs):
    """Load PyTorch model state dict."""
    # Create model instance
    model = model_class(*args, **kwargs)
    # Load state dict
    model.load_state_dict(torch.load(filepath))
    model.eval()
    print(f"Model loaded from: {filepath}")
    return model
```

### XGBoost

```python
import xgboost as xgb

def save_xgboost_model(model, filepath):
    """Save XGBoost model."""
    model.save_model(filepath)
    print(f"XGBoost model saved to: {filepath}")

def load_xgboost_model(filepath):
    """Load XGBoost model."""
    model = xgb.XGBClassifier()
    model.load_model(filepath)
    print(f"XGBoost model loaded from: {filepath}")
    return model
```

### LightGBM

```python
import lightgbm as lgb

def save_lightgbm_model(model, filepath):
    """Save LightGBM model."""
    model.booster_.save_model(filepath)
    print(f"LightGBM model saved to: {filepath}")

def load_lightgbm_model(filepath):
    """Load LightGBM model."""
    import lightgbm as lgb
    model = lgb.Booster(model_file=filepath)
    print(f"LightGBM model loaded from: {filepath}")
    return model
```

---

## 3. Model Versioning

### Simple Versioning System

```python
import json
from datetime import datetime
from pathlib import Path

class ModelVersioner:
    """
    Simple model versioning system.
    """
    
    def __init__(self, model_dir='models'):
        self.model_dir = Path(model_dir)
        self.model_dir.mkdir(parents=True, exist_ok=True)
        self.metadata_file = self.model_dir / 'metadata.json'
        self.metadata = self._load_metadata()
    
    def _load_metadata(self):
        """Load metadata from file."""
        if self.metadata_file.exists():
            with open(self.metadata_file, 'r') as f:
                return json.load(f)
        return {'versions': []}
    
    def _save_metadata(self):
        """Save metadata to file."""
        with open(self.metadata_file, 'w') as f:
            json.dump(self.metadata, f, indent=2)
    
    def register_version(self, model, model_name, metrics=None, parameters=None):
        """
        Register a new model version.
        
        Args:
            model: Trained model
            model_name: Name of the model
            metrics: Performance metrics
            parameters: Model parameters
        
        Returns:
            str: Version ID
        """
        # Generate version ID
        version_id = f"v{len(self.metadata['versions']) + 1:04d}"
        timestamp = datetime.now().isoformat()
        
        # Create version directory
        version_dir = self.model_dir / version_id
        version_dir.mkdir(exist_ok=True)
        
        # Save model
        model_path = version_dir / f"{model_name}.joblib"
        joblib.dump(model, model_path)
        
        # Save metadata
        version_info = {
            'id': version_id,
            'name': model_name,
            'timestamp': timestamp,
            'model_path': str(model_path),
            'metrics': metrics or {},
            'parameters': parameters or {},
            'status': 'active'
        }
        
        self.metadata['versions'].append(version_info)
        self._save_metadata()
        
        print(f"Version {version_id} registered: {model_name}")
        return version_id
    
    def get_version(self, version_id=None):
        """Get a specific version or latest."""
        if version_id is None:
            # Return latest active version
            active = [v for v in self.metadata['versions'] if v.get('status') == 'active']
            if active:
                return active[-1]
            return None
        
        for version in self.metadata['versions']:
            if version['id'] == version_id:
                return version
        return None
    
    def load_version(self, version_id):
        """Load a specific version."""
        version_info = self.get_version(version_id)
        if not version_info:
            raise ValueError(f"Version {version_id} not found")
        
        model_path = Path(version_info['model_path'])
        if not model_path.exists():
            raise FileNotFoundError(f"Model file not found: {model_path}")
        
        model = joblib.load(model_path)
        print(f"Loaded version {version_id}: {version_info['name']}")
        return model
    
    def list_versions(self, name=None):
        """List all versions."""
        versions = self.metadata['versions']
        if name:
            versions = [v for v in versions if v['name'] == name]
        return versions
    
    def promote_version(self, version_id, status='production'):
        """Promote a version to production."""
        for version in self.metadata['versions']:
            if version['id'] == version_id:
                version['status'] = status
                self._save_metadata()
                print(f"Version {version_id} promoted to {status}")
                return True
        return False

# Example usage
versioner = ModelVersioner()

# Train and register model
model = RandomForestClassifier()
model.fit(X_train, y_train)

version_id = versioner.register_version(
    model,
    'churn_predictor',
    metrics={'accuracy': 0.85, 'roc_auc': 0.92},
    parameters={'n_estimators': 100, 'max_depth': 6}
)

# List versions
print("All versions:")
for v in versioner.list_versions():
    print(f"  {v['id']}: {v['name']} - {v['timestamp']}")

# Promote to production
versioner.promote_version(version_id, 'production')

# Load for inference
production_model = versioner.load_version(version_id)
```

### DVC for Model Versioning

```bash
# Initialize DVC
dvc init

# Track model files
dvc add models/versioned_model.joblib

# Track metadata
git add models/versioned_model.joblib.dvc

# Commit
git commit -m "Added model version"

# Push to remote
dvc push

# Track different versions
git tag v1.0
```

---

## 4. Model Registry

### Complete Model Registry

```python
import json
import hashlib
from datetime import datetime
from pathlib import Path
import joblib

class ModelRegistry:
    """
    Complete model registry with tracking, versioning, and metadata.
    """
    
    def __init__(self, registry_dir='models/registry'):
        self.registry_dir = Path(registry_dir)
        self.registry_dir.mkdir(parents=True, exist_ok=True)
        self.registry_file = self.registry_dir / 'registry.json'
        self.registry = self._load_registry()
    
    def _load_registry(self):
        if self.registry_file.exists():
            with open(self.registry_file, 'r') as f:
                return json.load(f)
        return {'models': [], 'deployments': {}}
    
    def _save_registry(self):
        with open(self.registry_file, 'w') as f:
            json.dump(self.registry, f, indent=2)
    
    def _compute_hash(self, model):
        """Compute hash of model for deduplication."""
        # For scikit-learn models
        if hasattr(model, '__class__'):
            import pickle
            model_bytes = pickle.dumps(model)
            return hashlib.sha256(model_bytes).hexdigest()
        return None
    
    def register_model(self, model, name, metrics=None, parameters=None, tags=None):
        """
        Register a model in the registry.
        
        Args:
            model: Trained model
            name: Model name
            metrics: Performance metrics
            parameters: Model parameters
            tags: Tags for filtering
        
        Returns:
            dict: Registration info
        """
        # Compute hash
        model_hash = self._compute_hash(model)
        
        # Check if already registered
        for existing in self.registry['models']:
            if existing.get('hash') == model_hash and existing['name'] == name:
                print(f"Model already registered: {name}")
                return existing
        
        # Generate version
        versions = [m for m in self.registry['models'] if m['name'] == name]
        version = f"v{len(versions) + 1:04d}"
        timestamp = datetime.now().isoformat()
        
        # Save model
        model_dir = self.registry_dir / name / version
        model_dir.mkdir(parents=True, exist_ok=True)
        model_path = model_dir / 'model.joblib'
        joblib.dump(model, model_path)
        
        # Save metadata
        metadata = {
            'name': name,
            'version': version,
            'hash': model_hash,
            'timestamp': timestamp,
            'path': str(model_path),
            'metrics': metrics or {},
            'parameters': parameters or {},
            'tags': tags or [],
            'status': 'staged'
        }
        
        # Save to registry
        self.registry['models'].append(metadata)
        self._save_registry()
        
        print(f"Registered {name} {version}")
        return metadata
    
    def promote_to_staging(self, name, version):
        """Promote a model to staging."""
        return self._update_status(name, version, 'staging')
    
    def promote_to_production(self, name, version):
        """Promote a model to production."""
        self._update_status(name, version, 'production')
        
        # Update deployment record
        deployment_key = f"{name}_production"
        self.registry['deployments'][deployment_key] = {
            'name': name,
            'version': version,
            'deployed_at': datetime.now().isoformat()
        }
        self._save_registry()
    
    def _update_status(self, name, version, status):
        """Update model status."""
        for model in self.registry['models']:
            if model['name'] == name and model['version'] == version:
                model['status'] = status
                self._save_registry()
                print(f"Model {name} {version} promoted to {status}")
                return True
        return False
    
    def get_latest_version(self, name, status=None):
        """Get the latest version of a model."""
        models = [m for m in self.registry['models'] if m['name'] == name]
        if status:
            models = [m for m in models if m.get('status') == status]
        if not models:
            return None
        return sorted(models, key=lambda x: x['version'])[-1]
    
    def get_production_model(self, name):
        """Get the production model for a given name."""
        production_key = f"{name}_production"
        deployment = self.registry['deployments'].get(production_key)
        if not deployment:
            return None
        
        version = deployment['version']
        return self.get_model_by_version(name, version)
    
    def get_model_by_version(self, name, version):
        """Load a specific version of a model."""
        for model in self.registry['models']:
            if model['name'] == name and model['version'] == version:
                model_path = Path(model['path'])
                if model_path.exists():
                    return joblib.load(model_path)
        return None
    
    def list_models(self, name=None, status=None):
        """List registered models."""
        models = self.registry['models']
        if name:
            models = [m for m in models if m['name'] == name]
        if status:
            models = [m for m in models if m.get('status') == status]
        return models
    
    def get_model_info(self, name, version=None):
        """Get metadata for a model."""
        if version is None:
            latest = self.get_latest_version(name)
            if not latest:
                return None
            version = latest['version']
        
        for model in self.registry['models']:
            if model['name'] == name and model['version'] == version:
                return model
        return None

# Example usage
registry = ModelRegistry()

# Register models
model1 = RandomForestClassifier()
model1.fit(X_train, y_train)
registry.register_model(
    model1,
    'churn_predictor',
    metrics={'accuracy': 0.85},
    tags=['v1', 'experimental']
)

# Promote to staging
registry.promote_to_staging('churn_predictor', 'v0001')

# Get latest
latest = registry.get_latest_version('churn_predictor')
print(f"Latest: {latest}")

# Get production model
prod = registry.get_production_model('churn_predictor')
```

---

## 5. Model Metadata and Documentation

### Comprehensive Model Metadata

```python
def generate_model_card(model, X_train, y_train, metrics, feature_names):
    """
    Generate a comprehensive model card.
    
    Args:
        model: Trained model
        X_train: Training data
        y_train: Training target
        metrics: Performance metrics
        feature_names: List of feature names
    
    Returns:
        dict: Model card
    """
    model_card = {
        'model_info': {
            'name': model.__class__.__name__,
            'type': 'classification',
            'framework': 'scikit-learn',
            'parameters': model.get_params()
        },
        'training_info': {
            'training_date': datetime.now().isoformat(),
            'training_samples': len(X_train),
            'feature_count': X_train.shape[1],
            'feature_names': feature_names,
            'class_distribution': dict(pd.Series(y_train).value_counts())
        },
        'performance': metrics,
        'interpretation': {}
    }
    
    # Add feature importance if available
    if hasattr(model, 'feature_importances_'):
        importances = model.feature_importances_
        sorted_idx = np.argsort(importances)[::-1]
        model_card['interpretation']['feature_importance'] = {
            feature_names[i]: float(importances[i]) 
            for i in sorted_idx[:10]
        }
    
    # Add coefficients if available
    if hasattr(model, 'coef_'):
        model_card['interpretation']['coefficients'] = {
            feature_names[i]: float(model.coef_[0][i])
            for i in range(len(feature_names))
        }
    
    return model_card
```

---

## 6. Best Practices

### Model Persistence Checklist

```
□ 1. Save models with metadata
□ 2. Use versioning system
□ 3. Store model in registry
□ 4. Document model performance
□ 5. Save feature names
□ 6. Save preprocessing pipeline
□ 7. Pin library versions
□ 8. Save training data schema
□ 9. Add deployment status
□ 10. Include timestamp
```

### File Naming Conventions

```
models/
├── churn_predictor/
│   ├── v0001/
│   │   ├── model.joblib
│   │   ├── metadata.json
│   │   └── features.json
│   ├── v0002/
│   └── latest -> v0002/
├── registry/
│   └── registry.json
└── production/
    └── churn_predictor -> ../churn_predictor/v0002/
```

---

## Quick Reference

### Saving Commands

```python
# Joblib (recommended)
joblib.dump(model, 'model.joblib')
model = joblib.load('model.joblib')

# Pickle
pickle.dump(model, open('model.pkl', 'wb'))
model = pickle.load(open('model.pkl', 'rb'))

# PyTorch
torch.save(model.state_dict(), 'model.pt')
model.load_state_dict(torch.load('model.pt'))

# XGBoost
model.save_model('model.json')
model = xgb.XGBClassifier()
model.load_model('model.json')
```

---

## Conclusion

This primer covers the essential concepts of model persistence and versioning. You now understand:

1. **Persistence methods**: Joblib, Pickle, framework-specific
2. **Model versioning**: Tracking model changes
3. **Model registry**: Centralized model management
4. **Model metadata**: Tracking important information
5. **Best practices**: File organization, naming conventions

**Next Steps:**
1. Implement versioning for your models
2. Set up a model registry
3. Document model metadata
4. Create deployment pipelines
5. Proceed to Part 1 of the series

---

*End of Primer 10*
