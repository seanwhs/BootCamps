# Primer 5: MLOps Best Practices and Production Considerations

## The Target: Production-Ready MLOps Patterns and Anti-Patterns

This primer provides comprehensive best practices for production MLOps, covering architecture decisions, security, performance, and common pitfalls. Use this as a guide for designing and maintaining production-grade ML systems.

## The Concept: Production ML Mindset

Think of production ML like running a commercial airline:
- **Development** = Flight simulator (safe to experiment)
- **Staging** = Pre-flight checks (everything must work)
- **Production** = Actual flights (passengers depend on it)
- **Monitoring** = Air traffic control (constantly watching)
- **Rollback** = Emergency landing (quickly return to safety)

The mindset shift from research to production is critical for success.

---

## 1. Architecture Best Practices

### System Design Principles

```python
"""
Production ML System Design Principles:
1. Separation of Concerns - Each component has single responsibility
2. Loose Coupling - Components communicate through well-defined interfaces
3. High Cohesion - Related functionality stays together
4. Observability - Everything is measurable and monitorable
5. Reproducibility - Every run can be reproduced
6. Idempotency - Operations can be repeated safely
7. Graceful Degradation - System handles failures gracefully
8. Security by Design - Security built in, not bolted on
"""

# Good: Separation of concerns
class DataIngestion:
    """Handles data ingestion only."""
    pass

class FeatureEngineering:
    """Handles feature engineering only."""
    pass

class ModelTraining:
    """Handles model training only."""
    pass

class ModelDeployment:
    """Handles model deployment only."""
    pass

# Bad: God class doing everything
class MLSystem:
    def ingest_data(self): pass
    def engineer_features(self): pass
    def train_model(self): pass
    def deploy_model(self): pass
```

### Architecture Patterns

```python
"""
Common MLOps Architecture Patterns:
1. Pipeline Pattern - Sequential steps in a pipeline
2. Microservices - Independent services for each component
3. Event-Driven - Triggered by events/sensors
4. Lambda Architecture - Batch + Real-time processing
5. Kappa Architecture - Real-time only (no batch)
"""

# Pipeline Pattern (Good for batch processing)
class MLPipeline:
    def __init__(self):
        self.steps = []
    
    def add_step(self, step):
        self.steps.append(step)
    
    def run(self, data):
        for step in self.steps:
            data = step.process(data)
        return data

# Event-Driven Pattern (Good for reactive systems)
class MLSystemEventDriven:
    def __init__(self):
        self.handlers = {}
    
    def on_event(self, event_type, handler):
        self.handlers[event_type] = handler
    
    def emit_event(self, event_type, data):
        if event_type in self.handlers:
            self.handlers[event_type](data)
```

---

## 2. Data Management Best Practices

### Data Versioning

```python
"""
Data Versioning Best Practices:
1. Always version raw data (immutable)
2. Version processed data as well
3. Use DVC for large files
4. Store data in append-only manner
5. Include schema in version metadata
6. Tag important versions
"""

class DataVersionManager:
    def __init__(self):
        self.versions = {}
    
    def version_data(self, data_path: str) -> str:
        """Create a new version of data."""
        import hashlib
        import datetime
        
        # Compute hash
        with open(data_path, 'rb') as f:
            hash_value = hashlib.md5(f.read()).hexdigest()
        
        # Create version
        version = {
            'hash': hash_value,
            'path': data_path,
            'created_at': datetime.now().isoformat(),
            'size_bytes': Path(data_path).stat().st_size,
            'schema': self._get_schema(data_path)
        }
        
        # Store version
        version_id = f"v_{hash_value[:8]}_{datetime.now().strftime('%Y%m%d')}"
        self.versions[version_id] = version
        
        return version_id
    
    def _get_schema(self, data_path: str) -> dict:
        """Extract schema from data."""
        import pandas as pd
        df = pd.read_csv(data_path, nrows=100)
        return {
            'columns': df.columns.tolist(),
            'dtypes': df.dtypes.astype(str).to_dict()
        }
```

### Data Quality

```python
"""
Data Quality Best Practices:
1. Validate schema on ingestion
2. Check for missing values
3. Detect outliers
4. Monitor data drift
5. Implement data contracts
6. Alert on quality issues
"""

from typing import List, Dict, Any
from dataclasses import dataclass

@dataclass
class DataQualityRule:
    """Data quality rule definition."""
    name: str
    condition: callable
    severity: str  # 'warn', 'error'
    message: str

class DataQualityValidator:
    def __init__(self):
        self.rules = []
    
    def add_rule(self, rule: DataQualityRule):
        self.rules.append(rule)
    
    def validate(self, data: pd.DataFrame) -> Dict[str, List[str]]:
        """Validate data against all rules."""
        results = {
            'passed': [],
            'failed': [],
            'warnings': []
        }
        
        for rule in self.rules:
            try:
                if rule.condition(data):
                    results['passed'].append(rule.name)
                else:
                    if rule.severity == 'error':
                        results['failed'].append(rule.name)
                    else:
                        results['warnings'].append(rule.name)
            except Exception as e:
                results['failed'].append(f"{rule.name}: {e}")
        
        return results
    
    def create_default_rules(self):
        """Create default quality rules."""
        rules = [
            DataQualityRule(
                name="no_missing_values",
                condition=lambda df: df.isnull().sum().sum() == 0,
                severity="error",
                message="Data contains missing values"
            ),
            DataQualityRule(
                name="unique_primary_key",
                condition=lambda df: df.duplicated().sum() == 0,
                severity="warn",
                message="Data contains duplicate rows"
            ),
            DataQualityRule(
                name="reasonable_date_range",
                condition=lambda df: df['date'].max() - df['date'].min() < pd.Timedelta(days=365),
                severity="warn",
                message="Data range exceeds 1 year"
            )
        ]
        
        for rule in rules:
            self.add_rule(rule)
```

---

## 3. Model Management Best Practices

### Model Versioning

```python
"""
Model Versioning Best Practices:
1. Version every trained model
2. Store training parameters with model
3. Track data version used for training
4. Include performance metrics
5. Document model limitations
6. Implement model registry
"""

from dataclasses import dataclass, field
from typing import Dict, Any, Optional
from datetime import datetime

@dataclass
class ModelMetadata:
    """Complete model metadata."""
    model_id: str
    model_type: str
    version: str
    created_at: datetime = field(default_factory=datetime.now)
    
    # Training info
    data_version: Optional[str] = None
    training_params: Dict[str, Any] = field(default_factory=dict)
    
    # Performance
    performance_metrics: Dict[str, float] = field(default_factory=dict)
    validation_metrics: Dict[str, float] = field(default_factory=dict)
    
    # Context
    git_commit: Optional[str] = None
    environment: Optional[str] = None
    
    # Deployment
    deployment_stage: str = "development"  # dev, staging, production
    deployed_at: Optional[datetime] = None
    
    # Documentation
    description: Optional[str] = None
    limitations: List[str] = field(default_factory=list)

class ModelVersionManager:
    def __init__(self):
        self.models = {}
    
    def register_model(self, model_path: str, metadata: ModelMetadata):
        """Register a new model version."""
        import pickle
        import shutil
        
        # Store model
        version_dir = Path(f"models/versions/{metadata.model_id}/{metadata.version}")
        version_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy model
        shutil.copy2(model_path, version_dir / "model.pkl")
        
        # Save metadata
        import json
        with open(version_dir / "metadata.json", 'w') as f:
            json.dump(metadata.__dict__, f, indent=2, default=str)
        
        self.models[metadata.model_id] = metadata
        return metadata
```

### Model Selection

```python
"""
Model Selection Best Practices:
1. Use multiple evaluation metrics
2. Consider business constraints
3. Test on production-like data
4. Validate with cross-validation
5. Perform error analysis
6. Document selection criteria
"""

class ModelSelector:
    def __init__(self, metric_weights: Dict[str, float]):
        self.metric_weights = metric_weights
    
    def score_model(self, metrics: Dict[str, float]) -> float:
        """Calculate weighted score for a model."""
        total_score = 0
        for metric, weight in self.metric_weights.items():
            if metric in metrics:
                total_score += metrics[metric] * weight
        return total_score
    
    def select_best_model(self, models: List[Dict]) -> Dict:
        """Select best model based on weighted metrics."""
        # Score each model
        scored_models = []
        for model in models:
            score = self.score_model(model.get('metrics', {}))
            scored_models.append({
                'model': model,
                'score': score
            })
        
        # Sort by score
        scored_models.sort(key=lambda x: x['score'], reverse=True)
        
        # Return best model
        best = scored_models[0]
        
        return {
            'selected_model': best['model'],
            'selected_score': best['score'],
            'all_scores': scored_models
        }
```

---

## 4. Deployment Best Practices

### Deployment Strategies

```python
"""
Deployment Strategies:
1. Shadow Mode - Run new model in parallel without serving
2. Canary Release - Gradually shift traffic
3. A/B Testing - Split traffic for comparison
4. Blue-Green - Zero-downtime switching
5. Rolling Update - Gradual replacement
"""

class DeploymentStrategy:
    """Base deployment strategy."""
    
    def deploy(self, model, version: str):
        raise NotImplementedError()

class BlueGreenDeployment(DeploymentStrategy):
    def __init__(self):
        self.active = 'blue'
        self.environments = {
            'blue': {'status': 'active', 'model': None},
            'green': {'status': 'inactive', 'model': None}
        }
    
    def deploy(self, model, version: str):
        # Deploy to inactive environment
        inactive = 'green' if self.active == 'blue' else 'blue'
        self.environments[inactive]['model'] = model
        
        # Test inactive environment
        if self._test_environment(inactive):
            # Switch active environment
            self.active = inactive
            self.environments[self.active]['status'] = 'active'
            return {'success': True, 'active': self.active}
        else:
            return {'success': False, 'reason': 'Test failed'}
    
    def _test_environment(self, env: str) -> bool:
        """Test environment before switching."""
        # Run smoke tests
        return True

class CanaryDeployment(DeploymentStrategy):
    def __init__(self, canary_percentage: float = 0.1):
        self.canary_percentage = canary_percentage
        self.stable_model = None
        self.canary_model = None
        self.metrics = {'stable': [], 'canary': []}
    
    def deploy(self, model, version: str):
        self.canary_model = model
        
        # Monitor canary performance
        if self._monitor_canary():
            # Gradually increase traffic
            while self.canary_percentage < 1.0:
                self.canary_percentage *= 1.5
                if self.canary_percentage > 1.0:
                    self.canary_percentage = 1.0
                
                if not self._monitor_canary():
                    return {'success': False, 'reason': 'Performance degraded'}
            
            # Full deployment
            self.stable_model = model
            return {'success': True}
        else:
            return {'success': False, 'reason': 'Canary failed'}
```

### Model Serving

```python
"""
Model Serving Best Practices:
1. Use standardized model format (MLflow, ONNX, etc.)
2. Implement health checks
3. Add request/response validation
4. Monitor latency and throughput
5. Implement caching where appropriate
6. Use connection pooling
7. Enable request logging
8. Implement graceful shutdown
"""

from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
import time
import asyncio

class ModelService:
    def __init__(self, model_path: str):
        self.model = self.load_model(model_path)
        self.request_count = 0
        self.latency_history = []
    
    def load_model(self, path: str):
        """Load model with validation."""
        import pickle
        with open(path, 'rb') as f:
            return pickle.load(f)
    
    async def predict(self, features: list):
        """Make prediction with monitoring."""
        start_time = time.time()
        self.request_count += 1
        
        try:
            # Validate input
            self._validate_input(features)
            
            # Make prediction
            prediction = self.model.predict([features])
            
            # Track latency
            latency = (time.time() - start_time) * 1000
            self.latency_history.append(latency)
            
            return {
                'prediction': prediction.tolist(),
                'latency_ms': latency,
                'request_id': self.request_count
            }
        except Exception as e:
            # Log error
            self._log_error(e, features)
            raise HTTPException(status_code=500, detail=str(e))
    
    def _validate_input(self, features: list):
        """Validate input features."""
        if not features:
            raise ValueError("Empty features")
        if len(features) != self.model.n_features_in_:
            raise ValueError(f"Expected {self.model.n_features_in_} features, got {len(features)}")
```

---

## 5. Monitoring and Observability

### Monitoring Metrics

```python
"""
Monitoring Best Practices:
1. Track system metrics (CPU, memory, disk)
2. Track model metrics (accuracy, drift, latency)
3. Track business metrics (predictions, revenue)
4. Set up alerts for anomalies
5. Create dashboards for visibility
6. Log everything structured
"""

class MetricsCollector:
    def __init__(self):
        self.metrics = {
            'system': {},
            'model': {},
            'business': {}
        }
    
    def collect_system_metrics(self):
        """Collect system metrics."""
        import psutil
        self.metrics['system'] = {
            'cpu_percent': psutil.cpu_percent(),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_usage': psutil.disk_usage('/').percent,
            'timestamp': time.time()
        }
    
    def collect_model_metrics(self, model_id: str):
        """Collect model-specific metrics."""
        # In practice, collect from model endpoints
        self.metrics['model'] = {
            'model_id': model_id,
            'latency_p95': self._get_latency_p95(),
            'throughput': self._get_throughput(),
            'error_rate': self._get_error_rate(),
            'drift_score': self._calculate_drift()
        }
    
    def collect_business_metrics(self):
        """Collect business metrics."""
        self.metrics['business'] = {
            'predictions_hour': self._count_predictions_hour(),
            'prediction_distribution': self._get_prediction_distribution()
        }
    
    def _get_latency_p95(self) -> float:
        """Calculate 95th percentile latency."""
        return 0.0  # Implementation would pull from history
    
    def _get_throughput(self) -> float:
        """Calculate requests per second."""
        return 0.0
    
    def _get_error_rate(self) -> float:
        """Calculate error rate."""
        return 0.0
    
    def _calculate_drift(self) -> float:
        """Calculate feature drift."""
        return 0.0
    
    def _count_predictions_hour(self) -> int:
        """Count predictions in the last hour."""
        return 0
    
    def _get_prediction_distribution(self) -> dict:
        """Get distribution of predictions."""
        return {}
```

### Alerting

```python
"""
Alerting Best Practices:
1. Alert on actionable conditions
2. Use appropriate severity levels
3. Include context in alerts
4. Implement alert deduplication
5. Provide runbook links
6. Test alerting systems
"""

from enum import Enum

class AlertSeverity(Enum):
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"

class AlertRule:
    def __init__(self, name: str, condition: callable, severity: AlertSeverity):
        self.name = name
        self.condition = condition
        self.severity = severity
    
    def evaluate(self, metrics: dict) -> bool:
        """Evaluate alert condition."""
        try:
            return self.condition(metrics)
        except Exception:
            return False

class AlertManager:
    def __init__(self):
        self.rules = []
        self.alerts = []
        self.alert_history = []
    
    def add_rule(self, rule: AlertRule):
        self.rules.append(rule)
    
    def check(self, metrics: dict):
        """Check all alert rules."""
        triggered = []
        
        for rule in self.rules:
            if rule.evaluate(metrics):
                alert = {
                    'rule': rule.name,
                    'severity': rule.severity.value,
                    'metrics': metrics,
                    'triggered_at': time.time()
                }
                self.alerts.append(alert)
                triggered.append(alert)
                
                # Deduplicate
                self._deduplicate_alerts()
        
        # Send alerts
        for alert in triggered:
            self.send_alert(alert)
    
    def _deduplicate_alerts(self):
        """Remove duplicate alerts."""
        seen = set()
        self.alerts = [
            a for a in self.alerts
            if (a['rule'], a['severity']) not in seen
            and not seen.add((a['rule'], a['severity']))
        ]
    
    def send_alert(self, alert: dict):
        """Send alert to configured channels."""
        # Implementation would send to Slack, PagerDuty, etc.
        pass
```

---

## 6. Security Best Practices

### Secrets Management

```python
"""
Secrets Management Best Practices:
1. Never hardcode secrets
2. Use environment variables
3. Leverage secret management tools (AWS Secrets Manager, HashiCorp Vault)
4. Rotate secrets regularly
5. Use principle of least privilege
6. Audit secret access
"""

import os
from typing import Optional

class SecretsManager:
    """Secure secret management."""
    
    def __init__(self, environment: str = "development"):
        self.environment = environment
    
    def get_secret(self, key: str, default: Optional[str] = None) -> str:
        """Get a secret from environment or external store."""
        # Priority: Environment -> External Store -> Default
        
        # Check environment
        value = os.environ.get(key)
        if value is not None:
            return value
        
        # Check external store (if in production)
        if self.environment == "production":
            value = self._fetch_from_vault(key)
            if value is not None:
                return value
        
        # Return default
        if default is not None:
            return default
        
        raise ValueError(f"Secret not found: {key}")
    
    def _fetch_from_vault(self, key: str) -> Optional[str]:
        """Fetch secret from HashiCorp Vault."""
        # Implementation would use hvac library
        pass

# Usage
secrets = SecretsManager()
db_password = secrets.get_secret("DB_PASSWORD")
mlflow_password = secrets.get_secret("MLFLOW_PASSWORD")
```

### Access Control

```python
"""
Access Control Best Practices:
1. Implement role-based access control (RBAC)
2. Use principle of least privilege
3. Audit all access
4. Use API keys for programmatic access
5. Implement JWT for authentication
"""

from enum import Enum
from typing import List, Optional

class Role(Enum):
    VIEWER = "viewer"
    DEVELOPER = "developer"
    ADMIN = "admin"

class Permission(Enum):
    VIEW_RUNS = "view_runs"
    VIEW_MODELS = "view_models"
    CREATE_RUNS = "create_runs"
    REGISTER_MODELS = "register_models"
    DEPLOY_MODELS = "deploy_models"
    MANAGE_USERS = "manage_users"

class RBACManager:
    """Role-based access control."""
    
    def __init__(self):
        self.role_permissions = {
            Role.VIEWER: [Permission.VIEW_RUNS, Permission.VIEW_MODELS],
            Role.DEVELOPER: [
                Permission.VIEW_RUNS,
                Permission.VIEW_MODELS,
                Permission.CREATE_RUNS,
                Permission.REGISTER_MODELS
            ],
            Role.ADMIN: [p for p in Permission]
        }
        
        self.user_roles = {}
    
    def assign_role(self, user: str, role: Role):
        """Assign a role to a user."""
        self.user_roles[user] = role
    
    def check_permission(self, user: str, permission: Permission) -> bool:
        """Check if user has permission."""
        role = self.user_roles.get(user)
        if role is None:
            return False
        
        return permission in self.role_permissions.get(role, [])
    
    def authorize(self, user: str, permission: Permission):
        """Authorize user for an operation."""
        if not self.check_permission(user, permission):
            raise PermissionError(f"User {user} lacks {permission.value} permission")
```

---

## 7. Performance Optimization

### Caching

```python
"""
Caching Best Practices:
1. Cache expensive operations
2. Use appropriate TTL
3. Implement cache invalidation
4. Use distributed cache when needed
5. Monitor cache hit rates
"""

from functools import lru_cache
from typing import Any, Optional
import time

class Cache:
    """Simple in-memory cache with TTL."""
    
    def __init__(self, default_ttl: int = 300):  # 5 minutes
        self.cache = {}
        self.ttl = {}
        self.default_ttl = default_ttl
    
    def get(self, key: str) -> Optional[Any]:
        """Get value from cache."""
        if key in self.cache:
            # Check TTL
            if time.time() - self.ttl[key] < self.default_ttl:
                return self.cache[key]
            else:
                # Expired
                del self.cache[key]
                del self.ttl[key]
        return None
    
    def set(self, key: str, value: Any, ttl: Optional[int] = None):
        """Set value in cache."""
        self.cache[key] = value
        self.ttl[key] = time.time()
        self.default_ttl = ttl or self.default_ttl
    
    def invalidate(self, key: str):
        """Invalidate cache entry."""
        if key in self.cache:
            del self.cache[key]
            del self.ttl[key]

# Usage with decorator
class CachedModel:
    def __init__(self, model, cache_size: int = 1000):
        self.model = model
        self.cache = lru_cache(maxsize=cache_size)(self._predict)
    
    def predict(self, features: tuple):
        """Predict with caching."""
        return self.cache(tuple(features))
    
    def _predict(self, features: tuple):
        """Actual prediction."""
        return self.model.predict(list(features))
```

### Batch Processing

```python
"""
Batch Processing Best Practices:
1. Process in appropriate batch sizes
2. Use streaming for large datasets
3. Implement backpressure handling
4. Use parallel processing where possible
5. Monitor processing throughput
"""

class BatchProcessor:
    def __init__(self, batch_size: int = 1000, max_workers: int = 4):
        self.batch_size = batch_size
        self.max_workers = max_workers
    
    def process_batch(self, data: List[Any], process_fn: callable) -> List[Any]:
        """Process a single batch."""
        return [process_fn(item) for item in data]
    
    def process_stream(self, data_stream: iter, process_fn: callable) -> iter:
        """Process data stream in batches."""
        batch = []
        
        for item in data_stream:
            batch.append(item)
            if len(batch) >= self.batch_size:
                # Process batch
                results = self.process_batch(batch, process_fn)
                yield from results
                batch = []
        
        # Process remaining
        if batch:
            results = self.process_batch(batch, process_fn)
            yield from results
    
    def process_parallel(self, data: List[Any], process_fn: callable) -> List[Any]:
        """Process data in parallel."""
        import concurrent.futures
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = []
            
            # Submit tasks
            for item in data:
                future = executor.submit(process_fn, item)
                futures.append(future)
            
            # Collect results
            results = []
            for future in futures:
                results.append(future.result())
            
            return results
```

---

## 8. Common Anti-Patterns to Avoid

### Anti-Pattern Examples

```python
"""
Common MLOps Anti-Patterns:
1. Hardcoded paths and credentials
2. No versioning of data/models
3. Ignoring reproducibility
4. Testing in production
5. Monolithic ML systems
6. Over-engineering
7. Underspecifying requirements
8. Not monitoring in production
"""

# Anti-Pattern 1: Hardcoded Paths
# BAD:
def load_data():
    return pd.read_csv('/Users/john/data/important_file.csv')  # Hardcoded path

# GOOD:
def load_data(data_path: str):
    return pd.read_csv(data_path)  # Parametrized

# Anti-Pattern 2: No Versioning
# BAD:
model = train_model(data)
save_model(model, 'model.pkl')  # Always overwrites

# GOOD:
model = train_model(data, version='v1.2.3')
save_model(model, f'model_{version}.pkl')

# Anti-Pattern 3: Testing in Production
# BAD:
def deploy_model(model):
    # Directly update production endpoint
    update_production_endpoint(model)

# GOOD:
def deploy_model(model):
    # Deploy to staging first
    if staging_test_passes(model):
        # Then deploy to production with canary
        canary_deploy(model)

# Anti-Pattern 4: Monolithic System
# BAD:
class MLSystem:
    def ingest_data(self): pass
    def train_model(self): pass
    def deploy_model(self): pass
    def monitor_model(self): pass
    # Everything in one class

# GOOD:
# Separate classes for each component
class DataIngestion: pass
class ModelTraining: pass
class ModelDeployment: pass
class ModelMonitoring: pass
```

### Code Smells

```python
"""
ML Code Smells:
1. Magic numbers
2. Duplicated code
3. God classes
4. Long functions
5. Missing documentation
6. No error handling
7. Hardcoded configurations
8. Tight coupling
"""

# Code Smell: Magic Numbers
# BAD:
if len(data) > 1000:
    # Do something

# GOOD:
MAX_DATA_SIZE = 1000
if len(data) > MAX_DATA_SIZE:
    # Do something

# Code Smell: Duplicated Code
# BAD:
def process_data_1(data):
    # 100 lines of complex processing
    pass

def process_data_2(data):
    # Same 100 lines + small change
    pass

# GOOD:
def process_data(data, param):
    # 100 lines of complex processing with param
    pass

# Code Smell: God Class
# BAD:
class MLPipeline:
    # 1000 lines with everything
    pass

# GOOD:
class DataLoader: pass
class FeatureEngineer: pass
class ModelTrainer: pass
class ModelEvaluator: pass
class DeploymentManager: pass
```

---

## Production Readiness Checklist

```python
"""
Production Readiness Checklist:

□ Data:
  □ Versioned with DVC
  □ Schema validated
  □ Quality checks passed
  □ Data contracts defined

□ Models:
  □ Versioned in registry
  □ Performance validated
  □ Tested on production-like data
  □ Documentation complete

□ Deployment:
  □ CI/CD pipeline set up
  □ Blue-green or canary deployment
  □ Rollback capability
  □ Health checks implemented

□ Monitoring:
  □ Metrics collected
  □ Alerts configured
  □ Dashboards created
  □ Logs structured

□ Security:
  □ Secrets managed
  □ Access control implemented
  □ Audit logging enabled
  □ Network security configured

□ Performance:
  □ Scalability tested
  □ Latency measured
  □ Throughput benchmarked
  □ Resource utilization optimized

□ Documentation:
  □ Architecture documented
  □ API documented
  □ Operational runbooks
  □ Disaster recovery plan
"""

def production_readiness_check() -> dict:
    """Check production readiness."""
    checks = {
        'data_versioning': False,
        'model_registry': False,
        'ci_cd': False,
        'monitoring': False,
        'security': False,
        'scalability': False,
        'documentation': False
    }
    
    # Each check would have actual validation logic
    
    return checks
```

---

*End of Primer 5: MLOps Best Practices and Production Considerations*
