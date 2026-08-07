# Appendix G: Deployment Strategies & DevOps Best Practices

Welcome to Appendix G! This comprehensive reference provides expert-level guidance on deploying Flask applications to production, implementing DevOps practices, and ensuring reliable, scalable, and maintainable deployments. This appendix covers everything from basic deployment to advanced strategies used in enterprise environments.

---

## Table of Contents

1. [Deployment Fundamentals](#1-deployment-fundamentals)
2. [Environment Configuration & Management](#2-environment-configuration--management)
3. [Deployment Strategies & Patterns](#3-deployment-strategies--patterns)
4. [Container Orchestration (Kubernetes)](#4-container-orchestration-kubernetes)
5. [CI/CD Pipeline Implementation](#5-cicd-pipeline-implementation)
6. [Infrastructure as Code (IaC)](#6-infrastructure-as-code-iac)
7. [Monitoring & Observability](#7-monitoring--observability)
8. [Disaster Recovery & Business Continuity](#8-disaster-recovery--business-continuity)
9. [Compliance & Security Auditing](#9-compliance--security-auditing)

---

## 1. Deployment Fundamentals

### Deployment Architecture Overview

```python
# Understanding different deployment architectures

deployment_architectures = {
    "Single Server": {
        "description": "All components on one server",
        "pros": ["Simple", "Cost-effective", "Easy to manage"],
        "cons": ["Single point of failure", "Limited scalability", "No redundancy"],
        "use_case": "Small projects, prototypes, internal tools"
    },
    "Layered Architecture": {
        "description": "Separate web, application, and database servers",
        "pros": ["Better security", "Independent scaling", "Improved performance"],
        "cons": ["More complex", "Higher cost", "Requires more management"],
        "use_case": "Medium to large applications"
    },
    "Microservices": {
        "description": "Multiple independent services",
        "pros": ["Independent scaling", "Team autonomy", "Faster deployments"],
        "cons": ["Complexity", "Network overhead", "Distributed system challenges"],
        "use_case": "Large enterprise applications"
    },
    "Serverless": {
        "description": "Function-as-a-Service architecture",
        "pros": ["No server management", "Auto-scaling", "Pay-per-use"],
        "cons": ["Cold starts", "Execution limits", "Vendor lock-in"],
        "use_case": "Event-driven applications, APIs"
    }
}

# Deployment environment configuration
class DeploymentEnvironment:
    """Configure deployment environments."""
    
    def __init__(self, name, config):
        self.name = name
        self.config = config
    
    def validate(self):
        """Validate environment configuration."""
        required_keys = [
            'SECRET_KEY', 'DATABASE_URL', 'REDIS_URL',
            'ENVIRONMENT', 'LOG_LEVEL'
        ]
        
        for key in required_keys:
            if key not in self.config:
                raise ValueError(f"Missing required config: {key}")
        
        # Validate secret key strength
        if len(self.config['SECRET_KEY']) < 32:
            raise ValueError("SECRET_KEY must be at least 32 characters")
        
        return True

# Environment configurations
environments = {
    'development': DeploymentEnvironment('development', {
        'ENVIRONMENT': 'development',
        'DEBUG': True,
        'LOG_LEVEL': 'DEBUG',
        'SECRET_KEY': 'dev-key-for-testing-only',
        'DATABASE_URL': 'sqlite:///dev.db',
        'REDIS_URL': 'redis://localhost:6379/0',
    }),
    'staging': DeploymentEnvironment('staging', {
        'ENVIRONMENT': 'staging',
        'DEBUG': False,
        'LOG_LEVEL': 'INFO',
        'SECRET_KEY': os.environ.get('SECRET_KEY'),
        'DATABASE_URL': os.environ.get('DATABASE_URL'),
        'REDIS_URL': os.environ.get('REDIS_URL'),
    }),
    'production': DeploymentEnvironment('production', {
        'ENVIRONMENT': 'production',
        'DEBUG': False,
        'LOG_LEVEL': 'WARNING',
        'SECRET_KEY': os.environ.get('SECRET_KEY'),
        'DATABASE_URL': os.environ.get('DATABASE_URL'),
        'REDIS_URL': os.environ.get('REDIS_URL'),
    })
}
```

### Server Provisioning & Configuration

```python
# Server configuration with Ansible
"""
# ansible/playbooks/deploy.yml
---
- name: Deploy TaskFlow Application
  hosts: app_servers
  become: yes
  vars:
    app_name: taskflow
    app_user: taskflow
    app_group: taskflow
    app_dir: /var/www/taskflow
    
  tasks:
    - name: Create application user
      user:
        name: "{{ app_user }}"
        group: "{{ app_group }}"
        shell: /bin/bash
        create_home: yes
    
    - name: Create application directory
      file:
        path: "{{ app_dir }}"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_group }}"
        mode: 0755
    
    - name: Install system dependencies
      apt:
        name:
          - python3-pip
          - python3-venv
          - nginx
          - postgresql
          - redis-server
          - git
          - supervisor
        state: present
    
    - name: Configure Nginx
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/{{ app_name }}
      notify: restart nginx
    
    - name: Enable Nginx site
      file:
        src: /etc/nginx/sites-available/{{ app_name }}
        dest: /etc/nginx/sites-enabled/{{ app_name }}
        state: link
    
    - name: Configure Supervisor
      template:
        src: templates/supervisor.conf.j2
        dest: /etc/supervisor/conf.d/{{ app_name }}.conf
      notify: restart supervisor
    
    - name: Deploy application
      git:
        repo: "{{ repo_url }}"
        dest: "{{ app_dir }}"
        version: "{{ version | default('master') }}"
        force: yes
    
    - name: Install Python dependencies
      pip:
        requirements: "{{ app_dir }}/requirements.txt"
        virtualenv: "{{ app_dir }}/venv"
        virtualenv_python: python3
    
    - name: Run database migrations
      command: |
        cd {{ app_dir }}
        source venv/bin/activate
        flask db upgrade
      environment:
        FLASK_ENV: production
        DATABASE_URL: "{{ database_url }}"
    
    - name: Collect static files
      command: |
        cd {{ app_dir }}
        source venv/bin/activate
        flask assets build
    
    - name: Restart application
      supervisorctl:
        name: "{{ app_name }}"
        state: restarted
    
  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
    
    - name: restart supervisor
      service:
        name: supervisor
        state: restarted
"""
```

---

## 2. Environment Configuration & Management

### Advanced Environment Management

```python
from pathlib import Path
import os
import yaml
import json
from typing import Dict, Any

class ConfigManager:
    """Advanced configuration management with multiple sources."""
    
    def __init__(self):
        self.config = {}
        self.load_order = []
    
    def load_from_file(self, file_path: str) -> None:
        """Load configuration from file."""
        path = Path(file_path)
        
        if not path.exists():
            raise FileNotFoundError(f"Config file not found: {file_path}")
        
        if path.suffix == '.yaml':
            with open(path) as f:
                self.config.update(yaml.safe_load(f))
        elif path.suffix == '.json':
            with open(path) as f:
                self.config.update(json.load(f))
        elif path.suffix == '.py':
            # Python file with config
            import importlib.util
            spec = importlib.util.spec_from_file_location("config", path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            
            for key in dir(module):
                if not key.startswith('_') and key.isupper():
                    self.config[key] = getattr(module, key)
        else:
            # Default to .env style
            self.load_dotenv(str(path))
        
        self.load_order.append(str(path))
    
    def load_from_env(self, prefix: str = 'TASKFLOW_') -> None:
        """Load configuration from environment variables."""
        for key, value in os.environ.items():
            if key.startswith(prefix):
                config_key = key[len(prefix):]
                self.config[config_key] = self._parse_value(value)
    
    def load_from_aws_secrets(self, secret_name: str) -> None:
        """Load configuration from AWS Secrets Manager."""
        import boto3
        from botocore.exceptions import ClientError
        
        try:
            session = boto3.session.Session()
            client = session.client('secretsmanager')
            
            response = client.get_secret_value(SecretId=secret_name)
            
            if 'SecretString' in response:
                secrets = json.loads(response['SecretString'])
                self.config.update(secrets)
            else:
                # Binary secret (unlikely for config)
                pass
        except ClientError as e:
            print(f"Error loading secrets: {e}")
    
    def load_from_vault(self, path: str, token: str) -> None:
        """Load configuration from HashiCorp Vault."""
        import hvac
        
        client = hvac.Client(
            url=os.environ.get('VAULT_ADDR', 'http://vault:8200'),
            token=token
        )
        
        if client.is_authenticated():
            secret = client.read(path)
            if secret and 'data' in secret:
                self.config.update(secret['data'])
    
    def _parse_value(self, value: str) -> Any:
        """Parse environment variable value."""
        # Parse booleans
        if value.lower() in ('true', 'yes', '1'):
            return True
        if value.lower() in ('false', 'no', '0'):
            return False
        
        # Parse integers
        try:
            return int(value)
        except ValueError:
            pass
        
        # Parse floats
        try:
            return float(value)
        except ValueError:
            pass
        
        # Parse JSON
        try:
            return json.loads(value)
        except json.JSONDecodeError:
            pass
        
        # Return as string
        return value
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get configuration value."""
        return self.config.get(key, default)
    
    def validate_config(self, schema: Dict[str, Any]) -> bool:
        """Validate configuration against schema."""
        from jsonschema import validate
        
        try:
            validate(instance=self.config, schema=schema)
            return True
        except Exception as e:
            print(f"Configuration validation failed: {e}")
            return False

# Application configuration
class AppConfig:
    """Application configuration class."""
    
    def __init__(self):
        self.manager = ConfigManager()
        self._load_config()
    
    def _load_config(self):
        """Load configuration from multiple sources."""
        # Load default config
        if Path('config/default.yaml').exists():
            self.manager.load_from_file('config/default.yaml')
        
        # Load environment-specific config
        env = os.environ.get('FLASK_ENV', 'development')
        if Path(f'config/{env}.yaml').exists():
            self.manager.load_from_file(f'config/{env}.yaml')
        
        # Load from environment variables
        self.manager.load_from_env(prefix='TASKFLOW_')
        
        # Load from secrets (production only)
        if env == 'production':
            self.manager.load_from_aws_secrets('taskflow/production')
        
        # Validate configuration
        self._validate()
    
    def _validate(self):
        """Validate configuration."""
        required = [
            'SECRET_KEY', 'DATABASE_URL', 'REDIS_URL',
            'ENVIRONMENT', 'LOG_LEVEL'
        ]
        
        for key in required:
            if not self.manager.get(key):
                raise ValueError(f"Missing required configuration: {key}")
    
    def __getattr__(self, name):
        """Get configuration attribute."""
        return self.manager.get(name)

# Usage
config = AppConfig()

# Access configuration
app.secret_key = config.SECRET_KEY
app.config['SQLALCHEMY_DATABASE_URI'] = config.DATABASE_URL
app.config['ENV'] = config.ENVIRONMENT
```

### Feature Flags

```python
class FeatureFlags:
    """Feature flag management for gradual rollouts."""
    
    def __init__(self, config_manager):
        self.config = config_manager
        self.flags = {}
        self._load_flags()
    
    def _load_flags(self):
        """Load feature flags from configuration."""
        self.flags = self.config.get('FEATURE_FLAGS', {})
    
    def is_enabled(self, flag_name: str, context: Dict[str, Any] = None) -> bool:
        """Check if a feature flag is enabled."""
        flag = self.flags.get(flag_name)
        
        if not flag:
            return False
        
        # Simple boolean flag
        if isinstance(flag, bool):
            return flag
        
        # Percentage rollout
        if isinstance(flag, dict):
            if flag.get('enabled', False):
                # Check percentage
                percentage = flag.get('percentage', 0)
                if percentage >= 100:
                    return True
                
                # User-specific rollout
                user_id = context.get('user_id') if context else None
                if user_id:
                    # Deterministic assignment
                    import hashlib
                    hash_value = int(hashlib.md5(str(user_id).encode()).hexdigest(), 16)
                    return (hash_value % 100) < percentage
                
                # Random assignment for non-authenticated users
                import random
                return random.random() * 100 < percentage
        
        return False
    
    def enable(self, flag_name: str):
        """Enable a feature flag."""
        self.flags[flag_name] = {'enabled': True}
        self._save_flags()
    
    def disable(self, flag_name: str):
        """Disable a feature flag."""
        self.flags[flag_name] = {'enabled': False}
        self._save_flags()
    
    def set_percentage(self, flag_name: str, percentage: int):
        """Set rollout percentage."""
        if flag_name not in self.flags:
            self.flags[flag_name] = {}
        self.flags[flag_name]['percentage'] = percentage
        self._save_flags()
    
    def _save_flags(self):
        """Save flags to configuration."""
        # In production, store in Redis or database
        pass

# Decorator for feature flags
def feature_flag(flag_name):
    """Decorator to control endpoint with feature flags."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            flags = current_app.extensions['feature_flags']
            
            # Build context
            context = {'user_id': current_user.id if current_user.is_authenticated else None}
            
            if flags.is_enabled(flag_name, context):
                return f(*args, **kwargs)
            else:
                if request.is_json:
                    return jsonify({
                        'error': 'Feature not available',
                        'feature': flag_name
                    }), 404
                else:
                    abort(404)
        
        return decorated
    return decorator

# Usage
@app.route('/api/new-feature')
@feature_flag('new_api_v2')
def new_feature_endpoint():
    return jsonify({'message': 'New feature is working!'})

# In templates
"""
{% if feature_flags.is_enabled('new_ui') %}
    <div class="new-ui">
        <!-- New UI content -->
    </div>
{% else %}
    <div class="old-ui">
        <!-- Old UI content -->
    </div>
{% endif %}
"""
```

---

## 3. Deployment Strategies & Patterns

### Blue-Green Deployment

```python
# Blue-Green deployment implementation
class BlueGreenDeployment:
    """Manage blue-green deployments."""
    
    def __init__(self, app_name, environments):
        self.app_name = app_name
        self.environments = environments  # {'blue': {...}, 'green': {...}}
        self.current = 'blue'  # Current active environment
    
    def deploy(self, version):
        """Deploy new version to inactive environment."""
        # Determine inactive environment
        inactive = 'green' if self.current == 'blue' else 'blue'
        
        # Deploy to inactive environment
        self._deploy_to_environment(inactive, version)
        
        # Validate deployment
        if self._validate_environment(inactive):
            return self.switch(inactive)
        
        # Rollback
        self._rollback(inactive)
        return False
    
    def switch(self, environment):
        """Switch traffic to specified environment."""
        if environment not in self.environments:
            raise ValueError(f"Invalid environment: {environment}")
        
        # Update load balancer
        self._update_load_balancer(environment)
        
        # Update current
        old = self.current
        self.current = environment
        
        # Clean up old environment if needed
        self._cleanup_old_environment(old)
        
        return True
    
    def rollback(self):
        """Rollback to previous version."""
        inactive = 'green' if self.current == 'blue' else 'blue'
        return self.switch(inactive)
    
    def _deploy_to_environment(self, env_name, version):
        """Deploy to specific environment."""
        env = self.environments[env_name]
        
        # Update configuration
        env['version'] = version
        
        # Start deployment
        print(f"Deploying {version} to {env_name}")
        
        # Run migrations (if needed)
        self._run_migrations(env)
        
        # Restart application
        self._restart_application(env)
        
        # Wait for health check
        if not self._wait_for_health(env):
            raise Exception(f"Health check failed for {env_name}")
    
    def _validate_environment(self, env_name):
        """Validate environment health."""
        env = self.environments[env_name]
        
        # Run smoke tests
        if not self._run_smoke_tests(env):
            return False
        
        # Check metrics
        if not self._check_metrics(env):
            return False
        
        return True
    
    def _update_load_balancer(self, env_name):
        """Update load balancer configuration."""
        env = self.environments[env_name]
        # Implementation depends on load balancer
        print(f"Switching traffic to {env_name}")
    
    def _cleanup_old_environment(self, env_name):
        """Clean up old environment."""
        print(f"Cleaning up {env_name}")
    
    def _run_migrations(self, env):
        """Run database migrations."""
        # Run migrations
        pass
    
    def _restart_application(self, env):
        """Restart application."""
        # Restart application
        pass
    
    def _wait_for_health(self, env, timeout=120):
        """Wait for health check."""
        import time
        
        start = time.time()
        while time.time() - start < timeout:
            if self._check_health(env):
                return True
            time.sleep(5)
        
        return False
    
    def _check_health(self, env):
        """Check health endpoint."""
        # Check health endpoint
        return True
    
    def _run_smoke_tests(self, env):
        """Run smoke tests."""
        # Run smoke tests
        return True
    
    def _check_metrics(self, env):
        """Check metrics."""
        # Check metrics
        return True

# Usage
deployment = BlueGreenDeployment('taskflow', {
    'blue': {
        'host': '10.0.0.10',
        'port': 8000,
        'version': 'v1.2.3',
    },
    'green': {
        'host': '10.0.0.11',
        'port': 8000,
        'version': 'v1.2.4',
    }
})

# Deploy new version
success = deployment.deploy('v1.2.4')
if success:
    print("Deployment successful")
else:
    print("Deployment failed, rolled back")
```

### Canary Deployments

```python
class CanaryDeployment:
    """Canary deployment with gradual rollout."""
    
    def __init__(self, app_name, base_version, canary_version):
        self.app_name = app_name
        self.base_version = base_version
        self.canary_version = canary_version
        self.canary_percentage = 0
        self.metrics = {}
    
    def deploy(self, percentage=10):
        """Deploy canary with initial percentage."""
        self.canary_percentage = percentage
        
        # Deploy canary version
        self._deploy_canary()
        
        # Monitor metrics
        self._start_monitoring()
        
        return True
    
    def adjust_rollout(self, percentage):
        """Adjust canary percentage."""
        if percentage < 0 or percentage > 100:
            raise ValueError("Percentage must be between 0 and 100")
        
        self.canary_percentage = percentage
        
        # Update load balancer routing
        self._update_routing(percentage)
        
        return True
    
    def promote(self):
        """Promote canary to full deployment."""
        # Deploy canary as base
        self._promote_canary()
        
        # Reset canary percentage
        self.canary_percentage = 0
        
        return True
    
    def rollback(self):
        """Rollback canary deployment."""
        # Remove canary deployment
        self._remove_canary()
        
        # Reset routing
        self.canary_percentage = 0
        
        return True
    
    def _deploy_canary(self):
        """Deploy canary version."""
        print(f"Deploying canary {self.canary_version}")
    
    def _update_routing(self, percentage):
        """Update routing to control traffic flow."""
        print(f"Routing {percentage}% of traffic to canary")
    
    def _start_monitoring(self):
        """Start monitoring canary performance."""
        print("Starting canary monitoring")
    
    def _promote_canary(self):
        """Promote canary to base."""
        print(f"Promoting {self.canary_version} to base")
    
    def _remove_canary(self):
        """Remove canary deployment."""
        print("Removing canary deployment")

# Auto-rollout based on metrics
class AutoCanaryRollout:
    """Automated canary rollout with metric-based decisions."""
    
    def __init__(self, deployment, metric_thresholds):
        self.deployment = deployment
        self.thresholds = metric_thresholds
        self.current_percentage = 0
    
    def rollout(self, target_percentage=100, step=10, interval=300):
        """Automated rollout with steps."""
        while self.current_percentage < target_percentage:
            # Check metrics
            if not self._check_metrics():
                print("Metrics threshold exceeded, rolling back")
                self.deployment.rollback()
                return False
            
            # Increase percentage
            next_percentage = min(
                self.current_percentage + step,
                target_percentage
            )
            
            self.deployment.adjust_rollout(next_percentage)
            self.current_percentage = next_percentage
            
            print(f"Canary rollout at {self.current_percentage}%")
            
            # Wait before next step
            import time
            time.sleep(interval)
        
        # Promote canary
        self.deployment.promote()
        print("Canary rollout complete!")
        return True
    
    def _check_metrics(self):
        """Check metrics against thresholds."""
        metrics = self._get_metrics()
        
        for metric, threshold in self.thresholds.items():
            if metric in metrics and metrics[metric] > threshold:
                print(f"Metric {metric} exceeded threshold: {metrics[metric]} > {threshold}")
                return False
        
        return True
    
    def _get_metrics(self):
        """Get current metrics."""
        # Collect metrics from monitoring system
        return {
            'error_rate': 0.5,      # Percentage
            'response_time': 200,   # ms
            'cpu_usage': 60,        # Percentage
            'memory_usage': 70,     # Percentage
        }

# Usage
canary = CanaryDeployment('taskflow', 'v1.2.3', 'v1.2.4')
auto_rollout = AutoCanaryRollout(canary, {
    'error_rate': 1.0,      # Max 1% error rate
    'response_time': 300,   # Max 300ms response time
    'cpu_usage': 80,        # Max 80% CPU usage
    'memory_usage': 85,     # Max 85% memory usage
})

# Start automated rollout
auto_rollout.rollout(target_percentage=100, step=20, interval=300)
```

---

## 4. Container Orchestration (Kubernetes)

### Kubernetes Deployment Configuration

```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taskflow-web
  namespace: taskflow
  labels:
    app: taskflow
    component: web
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: taskflow
      component: web
  template:
    metadata:
      labels:
        app: taskflow
        component: web
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: web
        image: taskflow/web:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: FLASK_ENV
          value: production
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: taskflow-secrets
              key: database-url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: taskflow-secrets
              key: redis-url
        - name: SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: taskflow-secrets
              key: secret-key
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/liveness
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/readiness
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: uploads
          mountPath: /app/uploads
        - name: logs
          mountPath: /app/logs
      volumes:
      - name: uploads
        persistentVolumeClaim:
          claimName: taskflow-uploads
      - name: logs
        emptyDir: {}

---
# kubernetes/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: taskflow-web
  namespace: taskflow
  labels:
    app: taskflow
    component: web
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8000
    name: http
  selector:
    app: taskflow
    component: web

---
# kubernetes/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: taskflow-ingress
  namespace: taskflow
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-body-size: "20m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
spec:
  tls:
  - hosts:
    - taskflow.com
    - www.taskflow.com
    secretName: taskflow-tls
  rules:
  - host: taskflow.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: taskflow-web
            port:
              number: 80

---
# kubernetes/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: taskflow-secrets
  namespace: taskflow
type: Opaque
stringData:
  secret-key: your-secret-key-here
  database-url: postgresql://user:pass@postgres:5432/taskflow
  redis-url: redis://redis:6379/0

---
# kubernetes/autoscaling.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: taskflow-web-hpa
  namespace: taskflow
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: taskflow-web
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80

---
# kubernetes/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: taskflow-uploads
  namespace: taskflow
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
```

### Helm Chart Structure

```yaml
# helm/taskflow/Chart.yaml
apiVersion: v2
name: taskflow
description: TaskFlow - Production Task Management Application
type: application
version: 1.0.0
appVersion: "1.0.0"
dependencies:
  - name: postgresql
    version: 11.x
    repository: https://charts.bitnami.com/bitnami
  - name: redis
    version: 16.x
    repository: https://charts.bitnami.com/bitnami

---
# helm/taskflow/values.yaml
replicaCount: 3

image:
  repository: taskflow/web
  tag: latest
  pullPolicy: Always

nameOverride: ""
fullnameOverride: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: taskflow.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - taskflow.com
      secretName: taskflow-tls

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

postgresql:
  enabled: true
  postgresqlUsername: taskflow
  postgresqlPassword: taskflow_password
  postgresqlDatabase: taskflow
  persistence:
    enabled: true
    size: 10Gi

redis:
  enabled: true
  auth:
    password: redis_password
  architecture: standalone
  master:
    persistence:
      enabled: true
      size: 1Gi

secrets:
  secretKey: "{{ .Values.secrets.secretKey }}"
  databaseUrl: "postgresql://taskflow:{{ .Values.postgresql.postgresqlPassword }}@taskflow-postgresql:5432/taskflow"
  redisUrl: "redis://:{{ .Values.redis.auth.password }}@taskflow-redis:6379/0"

env:
  - name: FLASK_ENV
    value: production
  - name: LOG_LEVEL
    value: INFO

healthCheck:
  livenessProbe:
    httpGet:
      path: /health/liveness
      port: 8000
    initialDelaySeconds: 30
    periodSeconds: 10
  readinessProbe:
    httpGet:
      path: /health/readiness
      port: 8000
    initialDelaySeconds: 5
    periodSeconds: 5
```

---

## 5. CI/CD Pipeline Implementation

### GitHub Actions Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy TaskFlow

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  DOCKER_REGISTRY: ghcr.io
  DOCKER_IMAGE: ${{ github.repository }}
  KUBERNETES_NAMESPACE: taskflow

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.13'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run tests
        run: |
          pytest tests/ --cov=app --cov-report=xml
        env:
          FLASK_ENV: testing
          DATABASE_URL: sqlite:///test.db
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE }}:${{ github.sha }}
            ${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_VERSION=${{ github.sha }}
            BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Kubernetes config
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBECONFIG }}" > $HOME/.kube/config
      
      - name: Deploy to staging
        run: |
          kubectl set image deployment/taskflow-web web=${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE }}:${{ github.sha }} -n ${{ env.KUBERNETES_NAMESPACE }}
          kubectl rollout status deployment/taskflow-web -n ${{ env.KUBERNETES_NAMESPACE }} --timeout=300s
      
      - name: Run smoke tests
        run: |
          ./scripts/smoke_tests.sh https://staging.taskflow.com

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Setup Kubernetes config
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBECONFIG_PROD }}" > $HOME/.kube/config
      
      - name: Deploy to production        run: |
          kubectl set image deployment/taskflow-web web=${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE }}:${{ github.sha }} -n ${{ env.KUBERNETES_NAMESPACE }}
          kubectl rollout status deployment/taskflow-web -n ${{ env.KUBERNETES_NAMESPACE }} --timeout=300s
      
      - name: Verify deployment
        run: |
          ./scripts/verify_deployment.sh https://taskflow.com

  rollback:
    runs-on: ubuntu-latest
    if: failure()
    steps:
      - name: Rollback deployment
        run: |
          kubectl rollout undo deployment/taskflow-web -n ${{ env.KUBERNETES_NAMESPACE }}
          kubectl rollout status deployment/taskflow-web -n ${{ env.KUBERNETES_NAMESPACE }} --timeout=300s
```

### GitLab CI Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy-staging
  - deploy-production

variables:
  DOCKER_REGISTRY: registry.gitlab.com
  DOCKER_IMAGE: $CI_PROJECT_PATH
  KUBERNETES_NAMESPACE: taskflow

cache:
  paths:
    - .pip_cache/

.test_template: &test_template
  stage: test
  image: python:3.13
  before_script:
    - python -m pip install --upgrade pip
    - pip install -r requirements.txt
    - pip install -r requirements-dev.txt
  script:
    - pytest tests/ --cov=app --cov-report=xml
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

unit-tests:
  <<: *test_template
  variables:
    FLASK_ENV: testing
    DATABASE_URL: sqlite:///test.db

integration-tests:
  <<: *test_template
  variables:
    FLASK_ENV: testing
    DATABASE_URL: postgresql://postgres:postgres@postgres:5432/test
  services:
    - postgres:latest

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $DOCKER_REGISTRY
    - docker build -t $DOCKER_REGISTRY/$DOCKER_IMAGE:$CI_COMMIT_SHA .
    - docker tag $DOCKER_REGISTRY/$DOCKER_IMAGE:$CI_COMMIT_SHA $DOCKER_REGISTRY/$DOCKER_IMAGE:latest
    - docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:$CI_COMMIT_SHA
    - docker push $DOCKER_REGISTRY/$DOCKER_IMAGE:latest

deploy-staging:
  stage: deploy-staging
  image: bitnami/kubectl:latest
  script:
    - kubectl set image deployment/taskflow-web web=$DOCKER_REGISTRY/$DOCKER_IMAGE:$CI_COMMIT_SHA -n $KUBERNETES_NAMESPACE
    - kubectl rollout status deployment/taskflow-web -n $KUBERNETES_NAMESPACE --timeout=300s
  environment:
    name: staging
    url: https://staging.taskflow.com
  only:
    - main
  when: manual

deploy-production:
  stage: deploy-production
  image: bitnami/kubectl:latest
  script:
    - kubectl set image deployment/taskflow-web web=$DOCKER_REGISTRY/$DOCKER_IMAGE:$CI_COMMIT_SHA -n $KUBERNETES_NAMESPACE
    - kubectl rollout status deployment/taskflow-web -n $KUBERNETES_NAMESPACE --timeout=300s
  environment:
    name: production
    url: https://taskflow.com
  only:
    - main
  when: manual
```

---

## 6. Infrastructure as Code (IaC)

### Terraform Configuration

```hcl
# terraform/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "taskflow" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "taskflow-vpc"
    Environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.taskflow.id
  cidr_block        = cidrsubnet(aws_vpc.taskflow.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "taskflow-public-${count.index}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "taskflow" {
  vpc_id = aws_vpc.taskflow.id
  
  tags = {
    Name        = "taskflow-igw"
    Environment = var.environment
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.taskflow.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.taskflow.id
  }
  
  tags = {
    Name        = "taskflow-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "web" {
  name        = "taskflow-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.taskflow.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "taskflow-web-sg"
    Environment = var.environment
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier     = "taskflow-${var.environment}"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = var.db_instance_class
  allocated_storage = 100
  
  db_name  = "taskflow"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.taskflow.name
  
  backup_retention_period = 30
  backup_window         = "03:00-04:00"
  maintenance_window    = "sun:04:00-sun:05:00"
  
  storage_encrypted = true
  
  tags = {
    Name        = "taskflow-db-${var.environment}"
    Environment = var.environment
  }
}

# ElastiCache Redis
resource "aws_elasticache_subnet_group" "taskflow" {
  name       = "taskflow-cache"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "taskflow-${var.environment}"
  description         = "Redis cache for TaskFlow"
  node_type           = var.cache_node_type
  num_cache_clusters  = 2
  automatic_failover_enabled = true
  
  subnet_group_name = aws_elasticache_subnet_group.taskflow.name
  security_group_ids = [aws_security_group.cache.id]
  
  parameter_group_name = "default.redis7"
  port                = 6379
  
  tags = {
    Name        = "taskflow-redis-${var.environment}"
    Environment = var.environment
  }
}

# Outputs
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}
```

---

## 7. Monitoring & Observability

### Prometheus & Grafana Configuration

```yaml
# prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'taskflow'
    metrics_path: /metrics
    static_configs:
      - targets:
        - 'taskflow-web:8000'
        - 'taskflow-web-2:8000'
        labels:
          app: taskflow
          environment: production

  - job_name: 'postgresql'
    static_configs:
      - targets:
        - 'postgres-exporter:9187'

  - job_name: 'redis'
    static_configs:
      - targets:
        - 'redis-exporter:9121'

  - job_name: 'nginx'
    static_configs:
      - targets:
        - 'nginx-exporter:9113'

---
# grafana/dashboards/taskflow.json
{
  "title": "TaskFlow Application Dashboard",
  "panels": [
    {
      "title": "Request Rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(flask_http_request_total[5m])",
          "legendFormat": "{{method}} {{endpoint}}"
        }
      ]
    },
    {
      "title": "Response Time (P95)",
      "type": "graph",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, rate(flask_http_request_duration_bucket[5m]))",
          "legendFormat": "{{endpoint}}"
        }
      ]
    },
    {
      "title": "Error Rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(flask_http_errors_total[5m])",
          "legendFormat": "{{endpoint}}"
        }
      ]
    },
    {
      "title": "Database Connections",
      "type": "graph",
      "targets": [
        {
          "expr": "pg_stat_database_numbackends",
          "legendFormat": "{{datname}}"
        }
      ]
    },
    {
      "title": "Redis Memory Usage",
      "type": "graph",
      "targets": [
        {
          "expr": "redis_memory_used_bytes / 1024 / 1024",
          "legendFormat": "Redis Memory (MB)"
        }
      ]
    }
  ]
}
```

### Application Metrics

```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
import time

# Define metrics
REQUEST_COUNT = Counter(
    'flask_http_request_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'flask_http_request_duration',
    'HTTP request duration in seconds',
    ['method', 'endpoint'],
    buckets=[0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10]
)

ERROR_COUNT = Counter(
    'flask_http_errors_total',
    'Total HTTP errors',
    ['method', 'endpoint', 'error_type']
)

ACTIVE_REQUESTS = Gauge(
    'flask_http_active_requests',
    'Active HTTP requests',
    ['method']
)

DB_CONNECTION_POOL = Gauge(
    'flask_db_connection_pool',
    'Database connection pool stats',
    ['state']  # 'size', 'checkedout', 'overflow'
)

# Metrics middleware
class MetricsMiddleware:
    """Prometheus metrics middleware."""
    
    def __init__(self, app):
        self.app = app
    
    def __call__(self, environ, start_response):
        method = environ.get('REQUEST_METHOD', 'GET')
        path = environ.get('PATH_INFO', '/')
        
        # Track active requests
        ACTIVE_REQUESTS.labels(method=method).inc()
        
        # Start timer
        start_time = time.time()
        
        # Process request
        def custom_start_response(status, headers, exc_info=None):
            # Get status code
            status_code = int(status.split(' ')[0])
            
            # Record metrics
            REQUEST_COUNT.labels(
                method=method,
                endpoint=path,
                status=status_code
            ).inc()
            
            REQUEST_DURATION.labels(
                method=method,
                endpoint=path
            ).observe(time.time() - start_time)
            
            if status_code >= 400:
                ERROR_COUNT.labels(
                    method=method,
                    endpoint=path,
                    error_type=str(status_code)
                ).inc()
            
            # Decrement active requests
            ACTIVE_REQUESTS.labels(method=method).dec()
            
            return start_response(status, headers, exc_info)
        
        return self.app(environ, custom_start_response)

# Custom metrics endpoint
@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint."""
    return Response(generate_latest(REGISTRY), mimetype='text/plain')

# Database connection pool metrics
def update_db_pool_metrics():
    """Update database connection pool metrics."""
    pool = db.engine.pool
    DB_CONNECTION_POOL.labels(state='size').set(pool.size())
    DB_CONNECTION_POOL.labels(state='checkedout').set(pool.checkedout())
    DB_CONNECTION_POOL.labels(state='overflow').set(pool.overflow())

# Update pool metrics periodically
@app.before_request
def before_request():
    g.start_time = time.time()
    update_db_pool_metrics()
```

---

## 8. Disaster Recovery & Business Continuity

### Backup & Recovery Automation

```python
import boto3
import subprocess
from datetime import datetime, timedelta
from pathlib import Path

class BackupManager:
    """Automated backup management with cloud storage."""
    
    def __init__(self):
        self.backup_dir = Path('/var/backups/taskflow')
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        self.s3_client = boto3.client('s3')
        self.bucket_name = 'taskflow-backups'
    
    def create_backup(self):
        """Create a full backup."""
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        backup_file = self.backup_dir / f"full_backup_{timestamp}.tar.gz"
        
        # Backup database
        self._backup_database(timestamp)
        
        # Backup uploads
        self._backup_uploads(timestamp)
        
        # Backup configuration
        self._backup_config(timestamp)
        
        # Combine backups
        self._combine_backups(timestamp)
        
        # Upload to cloud
        self._upload_to_cloud(backup_file)
        
        # Clean old backups
        self._clean_old_backups()
        
        return backup_file
    
    def _backup_database(self, timestamp):
        """Backup PostgreSQL database."""
        db_backup = self.backup_dir / f"db_backup_{timestamp}.sql.gz"
        
        subprocess.run([
            'pg_dump',
            '-h', 'localhost',
            '-U', 'taskflow',
            '-d', 'taskflow',
            '-Fc',
            '-f', str(db_backup)
        ], check=True)
    
    def _backup_uploads(self, timestamp):
        """Backup uploads directory."""
        uploads_backup = self.backup_dir / f"uploads_{timestamp}.tar.gz"
        
        subprocess.run([
            'tar', '-czf', str(uploads_backup),
            '-C', '/var/www/taskflow', 'uploads'
        ], check=True)
    
    def _backup_config(self, timestamp):
        """Backup configuration."""
        config_backup = self.backup_dir / f"config_{timestamp}.tar.gz"
        
        subprocess.run([
            'tar', '-czf', str(config_backup),
            '-C', '/etc', 'taskflow'
        ], check=True)
    
    def _combine_backups(self, timestamp):
        """Combine individual backups."""
        combined = self.backup_dir / f"full_backup_{timestamp}.tar.gz"
        
        subprocess.run([
            'tar', '-czf', str(combined),
            '-C', str(self.backup_dir),
            f"db_backup_{timestamp}.sql.gz",
            f"uploads_{timestamp}.tar.gz",
            f"config_{timestamp}.tar.gz"
        ], check=True)
    
    def _upload_to_cloud(self, file_path):
        """Upload backup to S3."""
        try:
            self.s3_client.upload_file(
                str(file_path),
                self.bucket_name,
                f"backups/{file_path.name}"
            )
        except Exception as e:
            print(f"Failed to upload to S3: {e}")
    
    def _clean_old_backups(self):
        """Remove backups older than 30 days."""
        cutoff = time.time() - 30 * 86400
        
        for file_path in self.backup_dir.glob("*.tar.gz"):
            if file_path.stat().st_mtime < cutoff:
                file_path.unlink()
    
    def restore_backup(self, backup_file):
        """Restore from backup."""
        if not backup_file.exists():
            raise FileNotFoundError(f"Backup file not found: {backup_file}")
        
        # Extract timestamp
        timestamp = backup_file.stem.replace('full_backup_', '')
        
        # Restore database
        self._restore_database(timestamp)
        
        # Restore uploads
        self._restore_uploads(timestamp)
        
        # Restore configuration
        self._restore_config(timestamp)
    
    def _restore_database(self, timestamp):
        """Restore database from backup."""
        db_backup = self.backup_dir / f"db_backup_{timestamp}.sql.gz"
        
        subprocess.run([
            'pg_restore',
            '-h', 'localhost',
            '-U', 'taskflow',
            '-d', 'taskflow',
            str(db_backup)
        ], check=True)
    
    def _restore_uploads(self, timestamp):
        """Restore uploads from backup."""
        uploads_backup = self.backup_dir / f"uploads_{timestamp}.tar.gz"
        
        subprocess.run([
            'tar', '-xzf', str(uploads_backup),
            '-C', '/var/www/taskflow'
        ], check=True)
    
    def _restore_config(self, timestamp):
        """Restore configuration."""
        config_backup = self.backup_dir / f"config_{timestamp}.tar.gz"
        
        subprocess.run([
            'tar', '-xzf', str(config_backup),
            '-C', '/etc'
        ], check=True)

# Scheduled backups
import schedule

def schedule_backups():
    """Schedule automated backups."""
    manager = BackupManager()
    
    # Daily full backup at 2 AM
    schedule.every().day.at("02:00").do(manager.create_backup)
    
    # Hourly database backup (for point-in-time recovery)
    schedule.every().hour.at(":00").do(manager._backup_database)
    
    while True:
        schedule.run_pending()
        time.sleep(60)

# Disaster recovery script
def disaster_recovery():
    """Complete disaster recovery procedure."""
    print("Starting disaster recovery...")
    
    # 1. Stop services
    subprocess.run(['systemctl', 'stop', 'taskflow'])
    
    # 2. Find latest backup
    backup_dir = Path('/var/backups/taskflow')
    latest_backup = sorted(backup_dir.glob("full_backup_*.tar.gz"))[-1]
    
    # 3. Restore from backup
    manager = BackupManager()
    manager.restore_backup(latest_backup)
    
    # 4. Run migrations
    subprocess.run(['flask', 'db', 'upgrade'])
    
    # 5. Start services
    subprocess.run(['systemctl', 'start', 'taskflow'])
    
    print("Disaster recovery complete!")
```

---

## 9. Compliance & Security Auditing

### Security Compliance Checks

```python
import subprocess
import json
import ssl
import socket

class ComplianceAuditor:
    """Security compliance auditing."""
    
    def __init__(self):
        self.checks = []
        self.results = {}
    
    def add_check(self, name, func):
        """Add a compliance check."""
        self.checks.append({
            'name': name,
            'function': func
        })
    
    def run_audit(self):
        """Run all compliance checks."""
        for check in self.checks:
            try:
                result = check['function']()
                self.results[check['name']] = result
            except Exception as e:
                self.results[check['name']] = {
                    'status': 'error',
                    'message': str(e)
                }
        
        return self.results

# SSL/TLS Check
def check_ssl_tls():
    """Check SSL/TLS configuration."""
    try:
        context = ssl.create_default_context()
        with socket.create_connection(('taskflow.com', 443), timeout=10) as sock:
            with context.wrap_socket(sock, server_hostname='taskflow.com') as ssock:
                cert = ssock.getpeercert()
                
                # Check certificate expiration
                import datetime
                expiry = datetime.datetime.strptime(
                    cert['notAfter'],
                    '%b %d %H:%M:%S %Y %Z'
                )
                days_until_expiry = (expiry - datetime.datetime.utcnow()).days
                
                return {
                    'status': 'pass',
                    'expires_in_days': days_until_expiry,
                    'expired': days_until_expiry < 0,
                    'issuer': cert['issuer'],
                    'subject': cert['subject']
                }
    except Exception as e:
        return {
            'status': 'fail',
            'error': str(e)
        }

# Security Headers Check
def check_security_headers():
    """Check security headers."""
    import requests
    
    try:
        response = requests.get('https://taskflow.com', timeout=10)
        headers = response.headers
        
        required_headers = {
            'Strict-Transport-Security': 'max-age=31536000',
            'X-Frame-Options': 'SAMEORIGIN',
            'X-Content-Type-Options': 'nosniff',
            'X-XSS-Protection': '1; mode=block',
            'Content-Security-Policy': None,
            'Referrer-Policy': 'strict-origin-when-cross-origin'
        }
        
        missing_headers = []
        for header, expected in required_headers.items():
            if header not in headers:
                missing_headers.append(header)
        
        return {
            'status': 'pass' if not missing_headers else 'fail',
            'missing_headers': missing_headers,
            'headers': {k: v for k, v in headers.items() if k in required_headers}
        }
    except Exception as e:
        return {
            'status': 'fail',
            'error': str(e)
        }

# CORS Configuration Check
def check_cors():
    """Check CORS configuration."""
    import requests
    
    try:
        response = requests.options(
            'https://taskflow.com/api/v1/tasks',
            headers={'Origin': 'https://example.com'}
        )
        
        headers = response.headers
        errors = []
        
        if 'Access-Control-Allow-Origin' in headers:
            if headers['Access-Control-Allow-Origin'] == '*':
                errors.append("CORS wildcard allowed")
        
        return {
            'status': 'pass' if not errors else 'fail',
            'errors': errors,
            'headers': {k: v for k, v in headers.items() if k.startswith('Access-Control')}
        }
    except Exception as e:
        return {
            'status': 'fail',
            'error': str(e)
        }

# Dependency Vulnerability Check
def check_dependencies():
    """Check dependencies for known vulnerabilities."""
    try:
        # Run safety check
        result = subprocess.run(
            ['safety', 'check', '-r', 'requirements.txt', '--json'],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            return {
                'status': 'pass',
                'vulnerabilities': []
            }
        
        vulnerabilities = json.loads(result.stdout)
        return {
            'status': 'fail',
            'vulnerabilities': vulnerabilities,
            'message': 'Vulnerable dependencies found'
        }
    except Exception as e:
        return {
            'status': 'fail',
            'error': str(e)
        }

# Run compliance audit
auditor = ComplianceAuditor()
auditor.add_check('SSL/TLS', check_ssl_tls)
auditor.add_check('Security Headers', check_security_headers)
auditor.add_check('CORS Configuration', check_cors)
auditor.add_check('Dependencies', check_dependencies)

results = auditor.run_audit()

# Generate compliance report
def generate_compliance_report(results, output_file='compliance_report.html'):
    """Generate HTML compliance report."""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Compliance Audit Report</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .pass { color: green; }
            .fail { color: red; }
            .error { color: orange; }
            .check { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }
            .summary { margin: 20px 0; }
        </style>
    </head>
    <body>
        <h1>Compliance Audit Report</h1>
        <div class="summary">
            <h2>Summary</h2>
    """
    
    total = len(results)
    passing = sum(1 for r in results.values() if r.get('status') == 'pass')
    failing = total - passing
    
    html += f"<p>Total Checks: {total}</p>"
    html += f"<p>Passing: <span class='pass'>{passing}</span></p>"
    html += f"<p>Failing: <span class='fail'>{failing}</span></p>"
    
    html += """
        </div>
        <h2>Detailed Results</h2>
    """
    
    for check_name, result in results.items():
        status = result.get('status', 'unknown')
        status_class = status
        html += f"""
        <div class="check">
            <h3>{check_name} - <span class="{status_class}">{status.upper()}</span></h3>
        """
        
        if status == 'pass':
            html += "<p>All checks passed</p>"
        elif status == 'fail':
            html += f"<p>Failed: {result.get('message', 'Check failed')}</p>"
            if 'missing_headers' in result:
                html += f"<p>Missing headers: {', '.join(result['missing_headers'])}</p>"
            if 'vulnerabilities' in result:
                html += "<ul>"
                for vuln in result['vulnerabilities']:
                    html += f"<li>{vuln}</li>"
                html += "</ul>"
        else:
            html += f"<p>Error: {result.get('error', 'Unknown error')}</p>"
        
        html += "</div>"
    
    html += """
    </body>
    </html>
    """
    
    with open(output_file, 'w') as f:
        f.write(html)
    
    return output_file

generate_compliance_report(results)
```

---

## Summary

This appendix has covered comprehensive deployment strategies and DevOps best practices:

1. **Deployment Fundamentals**: Architecture patterns, environment configuration
2. **Environment Management**: Multi-environment config, feature flags
3. **Deployment Strategies**: Blue-green, canary, rolling updates
4. **Container Orchestration**: Kubernetes, Helm charts, autoscaling
5. **CI/CD Pipeline**: GitHub Actions, GitLab CI, automated deployments
6. **Infrastructure as Code**: Terraform, AWS resources
7. **Monitoring & Observability**: Prometheus, Grafana, application metrics
8. **Disaster Recovery**: Backup automation, business continuity
9. **Compliance & Security**: Auditing, vulnerability scanning

**DevOps Best Practices Checklist**:
- [ ] Use Infrastructure as Code (Terraform/CloudFormation)
- [ ] Implement CI/CD with automated testing
- [ ] Use blue-green or canary deployments
- [ ] Monitor application and infrastructure metrics
- [ ] Implement automated backup and recovery
- [ ] Use container orchestration (Kubernetes)
- [ ] Implement proper secret management
- [ ] Use feature flags for gradual rollouts
- [ ] Implement auto-scaling based on metrics
- [ ] Regular security compliance audits
