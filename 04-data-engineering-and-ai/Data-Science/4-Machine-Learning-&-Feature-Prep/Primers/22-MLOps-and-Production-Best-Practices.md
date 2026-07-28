# Primer 22: MLOps and Production Best Practices

## Overview

This primer provides a comprehensive guide to MLOps and production best practices—the principles, patterns, and practices for building and maintaining reliable ML systems in production. Understanding these concepts is essential for moving beyond Jupyter notebooks to production-grade ML systems.

---

## 1. The MLOps Maturity Model

### MLOps Levels

```
┌─────────────────────────────────────────────────────────────────┐
│                    MLOPS MATURITY MODEL                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Level 0: Manual Processes (Research)                          │
│  └── Jupyter notebooks, manual deployment                     │
│      • Data scientists run experiments                        │
│      • Models manually saved and shared                       │
│      • No automated testing                                    │
│      • Manual deployment                                       │
│                                                                 │
│  Level 1: ML Pipeline Automation (DevOps)                      │
│  └── Automated training, CI/CD for code                       │
│      • Automated data and model pipelines                     │
│      • Versioned code, data, models                           │
│      • Automated testing                                       │
│      • CI/CD for training pipelines                           │
│                                                                 │
│  Level 2: Continuous Training (MLOps)                          │
│  └── Automated retraining, monitoring                         │
│      • Models retrained automatically                         │
│      • Performance monitoring                                  │
│      • Data drift detection                                    │
│      • Automated model validation                             │
│                                                                 │
│  Level 3: Continuous Operation (Full MLOps)                    │
│  └── Self-healing, optimization, governance                   │
│      • Automated A/B testing                                   │
│      • Auto-rollback                                           │
│      • Federated learning                                      │
│      • Full governance and compliance                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The MLOps Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    MLOPS LIFECYCLE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    PLAN                                  │  │
│  │  Business Goals → Requirements → Design                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    DATA                                  │  │
│  │  Ingestion → Validation → Preparation → Versioning      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    TRAIN                                 │  │
│  │  Feature Eng → Model Training → Tuning → Validation     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    DEPLOY                                │  │
│  │  Packaging → Testing → Deployment → Registry            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    MONITOR                               │  │
│  │  Performance → Drift → Alerts → Retraining              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    ITERATE                               │  │
│  │  Feedback → Improvement → New Version                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Production ML Architecture

### Microservices Architecture

```python
# Service architecture for ML system

class ServiceArchitecture:
    """ML microservices architecture."""
    
    services = {
        'feature_store': {
            'purpose': 'Store and serve features',
            'tech': 'Feast, Redis, PostgreSQL',
            'endpoints': ['/features', '/features/batch']
        },
        'model_registry': {
            'purpose': 'Manage model versions',
            'tech': 'MLflow, DVC, Custom',
            'endpoints': ['/models', '/models/deploy']
        },
        'training_pipeline': {
            'purpose': 'Orchestrate training',
            'tech': 'Airflow, Kubeflow, Argo',
            'endpoints': ['/train', '/retrain']
        },
        'prediction_service': {
            'purpose': 'Serve predictions',
            'tech': 'FastAPI, Flask, Ray',
            'endpoints': ['/predict', '/predict/batch']
        },
        'monitoring': {
            'purpose': 'Monitor performance',
            'tech': 'Prometheus, Grafana, ELK',
            'endpoints': ['/metrics', '/alerts']
        },
        'governance': {
            'purpose': 'Manage compliance',
            'tech': 'Custom, Fairlearn',
            'endpoints': ['/audit', '/fairness']
        }
    }
    
    @classmethod
    def display_architecture(cls):
        """Display service architecture."""
        print("ML Microservices Architecture")
        print("=" * 40)
        for service, details in cls.services.items():
            print(f"\n{service.upper()}")
            print(f"  Purpose: {details['purpose']}")
            print(f"  Technology: {details['tech']}")
            print(f"  Endpoints: {', '.join(details['endpoints'])}")
```

### API Gateway Pattern

```python
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import httpx

class APIGateway:
    """
    API Gateway for ML services.
    """
    
    def __init__(self):
        self.app = FastAPI(title="ML API Gateway")
        self.client = httpx.AsyncClient()
        self.routes = {}
    
    def register_service(self, service_name, base_url, endpoints):
        """
        Register a service with the gateway.
        
        Args:
            service_name: Name of the service
            base_url: Base URL of the service
            endpoints: List of endpoint paths
        """
        self.routes[service_name] = {
            'base_url': base_url,
            'endpoints': endpoints
        }
        
        # Create routes dynamically
        for endpoint in endpoints:
            path = f"/{service_name}{endpoint}"
            self._add_proxy_route(path, f"{base_url}{endpoint}")
    
    def _add_proxy_route(self, path, target_url):
        """Add a proxy route to FastAPI app."""
        
        async def proxy(request: Request):
            # Forward request to target
            response = await self.client.request(
                method=request.method,
                url=target_url,
                content=await request.body(),
                headers=dict(request.headers)
            )
            return response.content, response.status_code
        
        # Add route to app
        self.app.add_api_route(
            path, proxy,
            methods=['GET', 'POST', 'PUT', 'DELETE']
        )
    
    def run(self, host='0.0.0.0', port=8000):
        """Run the API gateway."""
        import uvicorn
        uvicorn.run(self.app, host=host, port=port)

# Example
gateway = APIGateway()
gateway.register_service(
    'predict',
    'http://predict-service:8000',
    ['/predict', '/predict/batch']
)
gateway.register_service(
    'monitoring',
    'http://monitoring-service:8000',
    ['/metrics', '/alerts']
)
```

---

## 3. CI/CD for ML

### GitHub Actions Pipeline

```yaml
# .github/workflows/ml-pipeline.yml

name: ML Pipeline CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.9, 3.10]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
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

  train:
    needs: test
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
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
    
    - name: Train model
      run: |
        python -m src.pipeline.trainer \
          --config configs/production.yaml \
          --data data/raw/training.csv \
          --target target \
          --output models/model.joblib
    
    - name: Validate model
      run: |
        python -m src.pipeline.validator \
          --model models/model.joblib \
          --data data/raw/validation.csv
    
    - name: Upload model artifact
      uses: actions/upload-artifact@v3
      with:
        name: model-artifact
        path: models/model.joblib

  deploy:
    needs: train
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Download model artifact
      uses: actions/download-artifact@v3
      with:
        name: model-artifact
        path: models/
    
    - name: Deploy to staging
      run: |
        # Deploy to staging environment
        echo "Deploying to staging..."
    
    - name: Run integration tests
      run: |
        # Test deployed model
        python scripts/test_api.py --url https://staging-api.example.com
    
    - name: Promote to production
      run: |
        # Promote to production
        echo "Promoting to production..."
```

### Jenkins Pipeline (Alternative)

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh 'python -m venv venv'
                sh 'source venv/bin/activate && pip install -r requirements.txt'
            }
        }
        
        stage('Test') {
            steps {
                sh 'source venv/bin/activate && pytest tests/ --cov=src/'
            }
        }
        
        stage('Train') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    source venv/bin/activate
                    python -m src.pipeline.trainer \
                        --config configs/production.yaml \
                        --data data/raw/training.csv \
                        --target target \
                        --output models/model.joblib
                '''
            }
        }
        
        stage('Validate') {
            when {
                branch 'main'
            }
            steps {
                sh '''
                    source venv/bin/activate
                    python -m src.pipeline.validator \
                        --model models/model.joblib \
                        --data data/raw/validation.csv
                '''
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh './scripts/deploy.sh'
            }
        }
    }
    
    post {
        failure {
            slackSend(color: 'danger', message: "Pipeline failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}")
        }
        success {
            slackSend(color: 'good', message: "Pipeline succeeded: ${env.JOB_NAME} - ${env.BUILD_NUMBER}")
        }
    }
}
```

---

## 4. Production Monitoring

### Comprehensive Monitoring System

```python
class ProductionMonitor:
    """
    Comprehensive production monitoring system.
    """
    
    def __init__(self, config):
        self.config = config
        self.metrics = []
        self.alerts = []
    
    def collect_metrics(self):
        """Collect all production metrics."""
        metrics = {
            'system': self._system_metrics(),
            'performance': self._performance_metrics(),
            'business': self._business_metrics(),
            'quality': self._quality_metrics()
        }
        self.metrics.append(metrics)
        return metrics
    
    def _system_metrics(self):
        """Collect system metrics."""
        import psutil
        import time
        
        return {
            'cpu_percent': psutil.cpu_percent(),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_usage': psutil.disk_usage('/').percent,
            'uptime_seconds': time.time() - psutil.boot_time()
        }
    
    def _performance_metrics(self, window=100):
        """Collect performance metrics."""
        # This would be populated from request logs
        return {
            'latency_p50': 0.0,
            'latency_p95': 0.0,
            'latency_p99': 0.0,
            'requests_per_second': 0.0,
            'error_rate': 0.0,
            'success_rate': 0.0
        }
    
    def _business_metrics(self):
        """Collect business metrics."""
        return {
            'predictions_total': 0,
            'predictions_per_second': 0,
            'active_users': 0,
            'business_value': 0.0
        }
    
    def _quality_metrics(self, window=1000):
        """Collect data quality metrics."""
        return {
            'missing_percentage': 0.0,
            'outlier_percentage': 0.0,
            'schema_validity': True,
            'data_freshness_hours': 0.0
        }
    
    def check_alerts(self, metrics):
        """Check for alerts."""
        alerts = []
        
        # System alerts
        if metrics['system']['cpu_percent'] > 80:
            alerts.append({
                'level': 'warning',
                'type': 'system',
                'message': f"CPU usage high: {metrics['system']['cpu_percent']}%"
            })
        
        if metrics['system']['memory_percent'] > 90:
            alerts.append({
                'level': 'critical',
                'type': 'system',
                'message': f"Memory usage critical: {metrics['system']['memory_percent']}%"
            })
        
        # Performance alerts
        if metrics['performance']['error_rate'] > 0.05:
            alerts.append({
                'level': 'critical',
                'type': 'performance',
                'message': f"Error rate high: {metrics['performance']['error_rate']:.2%}"
            })
        
        if metrics['performance']['latency_p95'] > 1.0:  # 1 second
            alerts.append({
                'level': 'warning',
                'type': 'performance',
                'message': f"Latency high: {metrics['performance']['latency_p95']:.2f}s"
            })
        
        # Quality alerts
        if metrics['quality']['missing_percentage'] > 10:
            alerts.append({
                'level': 'warning',
                'type': 'quality',
                'message': f"Missing values high: {metrics['quality']['missing_percentage']:.1f}%"
            })
        
        return alerts
    
    def generate_report(self):
        """Generate monitoring report."""
        metrics = self.collect_metrics()
        alerts = self.check_alerts(metrics)
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'metrics': metrics,
            'alerts': alerts,
            'status': 'healthy' if len(alerts) == 0 else 'degraded' if len(alerts) < 3 else 'critical'
        }
        
        return report
```

---

## 5. Incident Response and Rollback

### Incident Management

```python
class IncidentManager:
    """
    Incident management for ML systems.
    """
    
    def __init__(self):
        self.incidents = []
        self.incident_templates = {
            'performance_degradation': {
                'severity': 'high',
                'response': 'Rollback to previous model version',
                'owner': 'ML Team'
            },
            'data_drift': {
                'severity': 'medium',
                'response': 'Retrain model with recent data',
                'owner': 'Data Team'
            },
            'system_failure': {
                'severity': 'critical',
                'response': 'Restart service, check infrastructure',
                'owner': 'DevOps Team'
            },
            'security_issue': {
                'severity': 'critical',
                'response': 'Security team investigation',
                'owner': 'Security Team'
            },
            'business_impact': {
                'severity': 'high',
                'response': 'Business stakeholder communication',
                'owner': 'Product Team'
            }
        }
    
    def create_incident(self, incident_type, description):
        """Create an incident."""
        incident = {
            'id': f"INC-{len(self.incidents) + 1:04d}",
            'type': incident_type,
            'description': description,
            'template': self.incident_templates.get(incident_type, {}),
            'status': 'open',
            'created_at': datetime.now().isoformat(),
            'updated_at': datetime.now().isoformat(),
            'resolution': None
        }
        self.incidents.append(incident)
        return incident
    
    def resolve_incident(self, incident_id, resolution):
        """Resolve an incident."""
        for incident in self.incidents:
            if incident['id'] == incident_id:
                incident['status'] = 'resolved'
                incident['resolution'] = resolution
                incident['resolved_at'] = datetime.now().isoformat()
                return True
        return False
    
    def get_active_incidents(self):
        """Get active incidents."""
        return [i for i in self.incidents if i['status'] == 'open']
    
    def generate_incident_report(self):
        """Generate incident report."""
        active = self.get_active_incidents()
        
        report = {
            'timestamp': datetime.now().isoformat(),
            'total_incidents': len(self.incidents),
            'active_incidents': len(active),
            'incidents_by_type': {}
        }
        
        for incident in self.incidents:
            incident_type = incident['type']
            if incident_type not in report['incidents_by_type']:
                report['incidents_by_type'][incident_type] = 0
            report['incidents_by_type'][incident_type] += 1
        
        return report

def rollback_model(model_registry, model_name, target_version):
    """
    Rollback model to previous version.
    
    Args:
        model_registry: ModelRegistry instance
        model_name: Name of the model
        target_version: Version to rollback to
    
    Returns:
        bool: Success status
    """
    try:
        # Load previous version
        model = model_registry.get_model_by_version(model_name, target_version)
        
        # Deploy previous version
        model_registry.promote_to_production(model_name, target_version)
        
        print(f"Rolled back {model_name} to version {target_version}")
        return True
        
    except Exception as e:
        print(f"Rollback failed: {str(e)}")
        return False

class RollbackStrategy:
    """
    Strategies for model rollback.
    """
    
    @staticmethod
    def immediate_rollback(model_registry, model_name):
        """Rollback immediately to previous production version."""
        # Get current production version
        current = model_registry.get_production_model(model_name)
        if not current:
            return False
        
        # Find previous version
        versions = model_registry.list_models(name=model_name)
        for i, version in enumerate(versions):
            if version['id'] == current['id'] and i > 0:
                previous = versions[i-1]
                return rollback_model(model_registry, model_name, previous['version'])
        
        return False
    
    @staticmethod
    def gradual_rollback(model_registry, model_name, traffic_percentage=0.1):
        """Gradual rollback with traffic shifting."""
        # Deploy previous version alongside current
        # Route percentage of traffic to previous version
        # Gradually increase traffic to previous version
        pass
    
    @staticmethod
    def feature_flagged_rollback(model_registry, model_name, feature_flag):
        """Rollback using feature flags."""
        # Toggle feature flag to control model version
        # Enable instant rollback without deployment
        pass
```

---

## 6. Continuous Improvement

### Model Retraining Automation

```python
class AutomatedRetrainer:
    """
    Automated model retraining system.
    """
    
    def __init__(self, config):
        self.config = config
        self.retrain_history = []
    
    def should_retrain(self, monitor_results):
        """
        Determine if model should be retrained.
        
        Args:
            monitor_results: Monitoring results
        
        Returns:
            tuple: (should_retrain, reason)
        """
        # Check performance degradation
        if monitor_results.get('performance_drop', 0) > 0.05:
            return True, 'Performance degradation'
        
        # Check data drift
        if monitor_results.get('drift_detected', False):
            drift_count = len(monitor_results.get('drift_summary', []))
            if drift_count > 3:
                return True, f'Significant data drift ({drift_count} features)'
        
        # Check time since last retrain
        days_since = monitor_results.get('days_since_train', 0)
        if days_since > self.config.get('max_days_without_retrain', 30):
            return True, f'Time-based retrain ({days_since} days)'
        
        # Check data volume
        new_samples = monitor_results.get('new_samples', 0)
        if new_samples > self.config.get('min_samples_for_retrain', 10000):
            return True, f'Accumulated {new_samples} new samples'
        
        return False, 'No retrain needed'
    
    def trigger_retrain(self, reason):
        """
        Trigger model retraining.
        
        Args:
            reason: Reason for retraining
        """
        print(f"🔄 Triggering retrain: {reason}")
        
        # Record retrain event
        self.retrain_history.append({
            'timestamp': datetime.now().isoformat(),
            'reason': reason,
            'status': 'triggered'
        })
        
        # This would trigger your training pipeline
        # Could be: API call, message queue, or airflow DAG
        
        return True
```

### A/B Testing Framework

```python
class ABTestFramework:
    """
    A/B testing for ML models.
    """
    
    def __init__(self):
        self.tests = []
        self.results = []
    
    def create_test(self, test_id, model_a, model_b, traffic_split=0.5):
        """
        Create an A/B test.
        
        Args:
            test_id: Test identifier
            model_a: Model A
            model_b: Model B
            traffic_split: Proportion of traffic to model A
        """
        test = {
            'id': test_id,
            'model_a': model_a,
            'model_b': model_b,
            'traffic_split': traffic_split,
            'started_at': datetime.now().isoformat(),
            'status': 'running',
            'results': {
                'model_a': {'requests': 0, 'success': 0, 'total_latency': 0},
                'model_b': {'requests': 0, 'success': 0, 'total_latency': 0}
            }
        }
        self.tests.append(test)
        return test
    
    def route_request(self, test_id, request):
        """Route request to A or B model."""
        import random
        
        test = self._get_test(test_id)
        if not test or test['status'] != 'running':
            return None
        
        if random.random() < test['traffic_split']:
            return test['model_a']
        else:
            return test['model_b']
    
    def record_result(self, test_id, model, success, latency):
        """Record test result."""
        test = self._get_test(test_id)
        if not test:
            return
        
        model_key = 'model_a' if model == test['model_a'] else 'model_b'
        results = test['results'][model_key]
        
        results['requests'] += 1
        if success:
            results['success'] += 1
        results['total_latency'] += latency
    
    def _get_test(self, test_id):
        """Get test by ID."""
        for test in self.tests:
            if test['id'] == test_id:
                return test
        return None
    
    def analyze_test(self, test_id):
        """
        Analyze A/B test results.
        
        Args:
            test_id: Test identifier
        
        Returns:
            dict: Analysis results
        """
        test = self._get_test(test_id)
        if not test:
            return None
        
        results = test['results']
        
        # Calculate metrics
        for model in ['model_a', 'model_b']:
            r = results[model]
            if r['requests'] > 0:
                r['success_rate'] = r['success'] / r['requests']
                r['avg_latency'] = r['total_latency'] / r['requests']
            else:
                r['success_rate'] = 0
                r['avg_latency'] = 0
        
        # Compare models
        comparison = {
            'test_id': test_id,
            'sample_size': {
                'model_a': results['model_a']['requests'],
                'model_b': results['model_b']['requests']
            },
            'success_rate': {
                'model_a': results['model_a']['success_rate'],
                'model_b': results['model_b']['success_rate']
            },
            'avg_latency': {
                'model_a': results['model_a']['avg_latency'],
                'model_b': results['model_b']['avg_latency']
            }
        }
        
        # Determine winner
        if results['model_a']['success_rate'] > results['model_b']['success_rate']:
            comparison['winner'] = 'model_a'
        elif results['model_b']['success_rate'] > results['model_a']['success_rate']:
            comparison['winner'] = 'model_b'
        else:
            comparison['winner'] = 'tie'
        
        return comparison
```

---

## Quick Reference: MLOps Best Practices

### Production Readiness Checklist

```
□ 1. Code Quality
│   ├── Version control
│   ├── Automated testing
│   ├── Code reviews
│   └── Documentation
│
□ 2. Data Management
│   ├── Data versioning
│   ├── Data validation
│   ├── Feature store
│   └── Data lineage
│
□ 3. Model Management
│   ├── Model registry
│   ├── Model versioning
│   ├── Model monitoring
│   └── Model governance
│
□ 4. Infrastructure
│   ├── Containerization
│   ├── Orchestration
│   ├── CI/CD pipeline
│   └── Auto-scaling
│
□ 5. Monitoring
│   ├── Performance metrics
│   ├── Data drift detection
│   ├── Alerting
│   └── Dashboard
│
□ 6. Incident Response
│   ├── Rollback capability
│   ├── Alerting procedures
│   ├── Escalation paths
│   └── Post-mortem process
│
□ 7. Compliance
│   ├── Model cards
│   ├── Data sheets
│   ├── Audit trails
│   └── Regulatory compliance
```

---

## Conclusion

This primer covers the essential concepts of MLOps and production best practices. You now understand:

1. **MLOps maturity model**: From manual to automated
2. **Production architecture**: Microservices, API gateway
3. **CI/CD for ML**: Automated pipelines
4. **Production monitoring**: System, performance, quality
5. **Incident response**: Management, rollback strategies
6. **Continuous improvement**: Retraining, A/B testing

**Next Steps:**
1. Implement CI/CD for your ML projects
2. Set up production monitoring
3. Create incident response plans
4. Implement A/B testing
5. Proceed to Part 1 of the series

---

*End of Primer 22*
