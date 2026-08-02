# Appendix C: Complete Configuration Reference

Welcome to Appendix C, which provides a comprehensive reference for all configuration files, settings, and environment variables used throughout the Mastering Modern Data Architecture series. This appendix serves as your configuration dictionary - a complete guide to every setting you might need to customize, optimize, or debug your data platform.

## C.1 Configuration Architecture

### The Concept

Configuration management is like the control panel of a building - it controls how everything operates. A well-structured configuration system allows you to:

- **Environment-based settings** - Development, staging, production
- **Secret management** - Securely handling passwords and keys
- **Service discovery** - Connecting to external services
- **Feature flags** - Enabling/disabling features dynamically
- **Performance tuning** - Optimizing for different workloads

### The Implementation

**File: `config/config_loader.py`**
```python
#!/usr/bin/env python3
"""
Configuration Loader
Centralized configuration management with environment support
"""

import os
import json
import yaml
from typing import Dict, Any, Optional, List
from pathlib import Path
from dotenv import load_dotenv
import logging

logger = logging.getLogger(__name__)

class ConfigLoader:
    """
    Centralized configuration loader
    Supports JSON, YAML, and environment variables
    """
    
    _instance = None
    _config = {}
    _env = 'development'
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ConfigLoader, cls).__new__(cls)
            cls._instance._initialize()
        return cls._instance
    
    def _initialize(self):
        """Initialize the configuration loader"""
        # Load environment variables from .env file
        env_file = os.getenv('ENV_FILE', '.env')
        if os.path.exists(env_file):
            load_dotenv(env_file)
        
        # Detect environment
        self._env = os.getenv('APP_ENV', 'development')
        
        # Load configuration
        self._load_config()
        
        logger.info(f"ConfigLoader initialized with environment: {self._env}")
    
    def _load_config(self):
        """Load configuration from multiple sources"""
        # Load default configuration
        default_config = self._load_from_file('config/default.yaml')
        if default_config:
            self._config.update(default_config)
        
        # Load environment-specific configuration
        env_config = self._load_from_file(f'config/{self._env}.yaml')
        if env_config:
            self._config.update(env_config)
        
        # Load local override (for development)
        local_config = self._load_from_file('config/local.yaml')
        if local_config:
            self._config.update(local_config)
        
        # Override with environment variables
        self._load_from_env()
    
    def _load_from_file(self, filepath: str) -> Optional[Dict[str, Any]]:
        """Load configuration from a file"""
        if not os.path.exists(filepath):
            return None
        
        try:
            if filepath.endswith('.json'):
                with open(filepath, 'r') as f:
                    return json.load(f)
            elif filepath.endswith(('.yaml', '.yml')):
                with open(filepath, 'r') as f:
                    return yaml.safe_load(f)
        except Exception as e:
            logger.error(f"Failed to load config from {filepath}: {e}")
        
        return None
    
    def _load_from_env(self):
        """Load configuration from environment variables"""
        # Load all environment variables starting with APP_
        for key, value in os.environ.items():
            if key.startswith('APP_'):
                config_key = key[4:].lower()  # Remove APP_ prefix
                
                # Parse JSON if value looks like JSON
                try:
                    if value.startswith(('{', '[')):
                        value = json.loads(value)
                except json.JSONDecodeError:
                    pass
                
                self._config[config_key] = value
    
    def get(self, key: str, default: Any = None) -> Any:
        """
        Get a configuration value by key
        Supports dot notation for nested keys
        """
        if '.' in key:
            parts = key.split('.')
            value = self._config
            for part in parts:
                if isinstance(value, dict):
                    value = value.get(part)
                else:
                    return default
            return value if value is not None else default
        
        return self._config.get(key, default)
    
    def set(self, key: str, value: Any):
        """Set a configuration value"""
        if '.' in key:
            parts = key.split('.')
            config = self._config
            for part in parts[:-1]:
                if part not in config:
                    config[part] = {}
                config = config[part]
            config[parts[-1]] = value
        else:
            self._config[key] = value
    
    def get_all(self) -> Dict[str, Any]:
        """Get all configuration"""
        return self._config.copy()
    
    def get_env(self) -> str:
        """Get current environment"""
        return self._env
    
    def is_production(self) -> bool:
        """Check if running in production"""
        return self._env == 'production'
    
    def is_development(self) -> bool:
        """Check if running in development"""
        return self._env == 'development'
    
    def is_test(self) -> bool:
        """Check if running in test"""
        return self._env == 'test'

# Singleton instance
config = ConfigLoader()
```

**File: `config/default.yaml`**
```yaml
# ============================================
# DEFAULT CONFIGURATION
# Applied to all environments
# ============================================

app:
  name: "Data Architecture Tutorial"
  version: "1.0.0"
  description: "Mastering Modern Data Architecture"

server:
  host: "0.0.0.0"
  port: 8000
  workers: 4
  timeout: 60
  max_request_size: 104857600  # 100MB

logging:
  level: "INFO"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  file: "logs/app.log"
  max_size: 104857600  # 100MB
  backup_count: 5

# ============================================
# DATABASE CONFIGURATIONS
# ============================================

databases:
  postgres:
    host: "localhost"
    port: 5432
    database: "dataarch"
    user: "dataarch"
    password: "dataarch123"
    pool_size: 10
    max_overflow: 20
    pool_timeout: 30
    ssl_mode: "prefer"
    
  mysql:
    host: "localhost"
    port: 3306
    database: "dataarch"
    user: "dataarch"
    password: "dataarch123"
    pool_size: 10
    max_overflow: 20
    
  mongodb:
    host: "localhost"
    port: 27017
    database: "dataarch"
    user: "root"
    password: "root123"
    auth_source: "admin"
    max_pool_size: 10

# ============================================
# OBJECT STORAGE
# ============================================

storage:
  endpoint: "http://localhost:9000"
  access_key: "minioadmin"
  secret_key: "minioadmin123"
  region: "us-east-1"
  secure: false
  
  buckets:
    raw: "data-lake"
    staging: "staging"
    processed: "processed"
    analytics: "analytics"
    features: "feature-store"
    models: "ml-models"
    logs: "logs"

# ============================================
# CACHING
# ============================================

cache:
  redis:
    host: "localhost"
    port: 6379
    db: 0
    password: ""
    max_connections: 50
    socket_timeout: 5
    retry_on_timeout: true
    
  memcached:
    servers: ["localhost:11211"]
    connect_timeout: 1
    timeout: 2

  default_ttl: 300
  max_size: 1000

# ============================================
# MESSAGE QUEUE
# ============================================

messaging:
  kafka:
    bootstrap_servers: ["localhost:9092"]
    client_id: "dataarch-client"
    group_id: "dataarch-consumer"
    auto_offset_reset: "earliest"
    enable_auto_commit: true
    max_poll_records: 500
    security_protocol: "PLAINTEXT"
    
    topics:
      data_events: "data-events"
      system_alerts: "system-alerts"
      metrics: "metrics"
      audit: "audit"

# ============================================
# ORCHESTRATION
# ============================================

orchestration:
  airflow:
    host: "localhost"
    port: 8081
    user: "admin"
    password: "admin123"
    dag_folder: "/opt/airflow/dags"
    executor: "LocalExecutor"
    parallel_workers: 4
    
  schedule:
    timezone: "UTC"
    default_retries: 3
    retry_delay: 300  # 5 minutes
    catchup: false

# ============================================
# ML / AI CONFIGURATION
# ============================================

ml:
  feature_store:
    path: "./data/feature_store"
    backend: "local"
    cache_size: 1000
    
  model_registry:
    path: "./data/models"
    backend: "local"
    
  vector_db:
    dimension: 128
    collection: "embeddings"
    distance_metric: "cosine"
    
  rag:
    top_k: 3
    model: "gpt-4"
    temperature: 0.7
    max_tokens: 1000

# ============================================
# MONITORING
# ============================================

monitoring:
  prometheus:
    host: "localhost"
    port: 9090
    path: "/metrics"
    
  grafana:
    host: "localhost"
    port: 3000
    user: "admin"
    password: "admin123"
    dashboards_path: "./docker/grafana/dashboards"

  metrics:
    collection_interval: 15
    retention_days: 30

# ============================================
# SECURITY
# ============================================

security:
  jwt:
    secret: "change_this_in_production"
    expiration_hours: 24
    algorithm: "HS256"
    
  encryption:
    algorithm: "AES-256-GCM"
    key_rotation_days: 90
    
  cors:
    allowed_origins: ["*"]
    allowed_methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allowed_headers: ["Authorization", "Content-Type"]

  audit:
    enabled: true
    log_file: "logs/audit.log"
    include_pii: false

# ============================================
# DATA QUALITY
# ============================================

quality:
  great_expectations:
    data_context_path: "./docker/great_expectations"
    checkpoint_name: "my_checkpoint"
    
  rules:
    completeness_threshold: 0.95
    accuracy_threshold: 0.90
    timeliness_threshold: 0.85
    
  monitoring:
    check_frequency: 3600  # 1 hour
    alert_on_failure: true

# ============================================
# GOVERNANCE
# ============================================

governance:
  catalog:
    amundsen:
      host: "localhost"
      port: 5000
      
  data_lineage:
    enabled: true
    tracking_interval: 300  # 5 minutes
    
  compliance:
    gdpr:
      enabled: true
      retention_days: 365
    ccpa:
      enabled: true
      opt_out_enabled: true

# ============================================
# PERFORMANCE
# ============================================

performance:
  query_cache_ttl: 300
  session_ttl: 3600
  batch_size: 10000
  parallel_workers: 4
  
  compression:
    enabled: true
    algorithm: "snappy"
    level: 6

  bulk_operations:
    chunk_size: 1000
    max_retries: 3
    retry_delay: 1

# ============================================
# INTEGRATION
# ============================================

integration:
  http:
    timeout: 30
    max_retries: 3
    retry_delay: 1
    
  webhooks:
    enabled: true
    retry_attempts: 3
    retry_delay: 60

  external_apis:
    slack_webhook: ""
    sendgrid_api_key: ""
```

**File: `config/development.yaml`**
```yaml
# ============================================
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# ============================================

app:
  debug: true
  log_level: "DEBUG"

server:
  port: 8000
  workers: 1
  reload: true

databases:
  postgres:
    host: "localhost"
    password: "dataarch123"
    pool_size: 5
    
  mysql:
    host: "localhost"
    password: "dataarch123"
    pool_size: 5

logging:
  level: "DEBUG"
  file: "logs/dev.log"

cache:
  redis:
    host: "localhost"
    db: 0
    
  default_ttl: 60  # 1 minute for development

orchestration:
  airflow:
    dag_folder: "./docker/airflow/dags"
    parallel_workers: 2

performance:
  query_cache_ttl: 60  # 1 minute
  batch_size: 1000  # Smaller for development

monitoring:
  metrics:
    collection_interval: 5  # 5 seconds

security:
  jwt:
    secret: "dev_secret_key_do_not_use_in_production"
    expiration_hours: 24

# Development-specific features
features:
  hot_reload: true
  mock_external_apis: true
  enable_debug_toolbar: true
  auto_migrate: true
```

**File: `config/production.yaml`**
```yaml
# ============================================
# PRODUCTION ENVIRONMENT CONFIGURATION
# ============================================

app:
  debug: false
  log_level: "INFO"

server:
  port: 8000
  workers: 8
  reload: false
  timeout: 120

databases:
  postgres:
    host: "postgres-production.internal"
    password: "${POSTGRES_PASSWORD}"  # From environment variable
    pool_size: 20
    max_overflow: 40
    ssl_mode: "require"
    
  mysql:
    host: "mysql-production.internal"
    password: "${MYSQL_PASSWORD}"
    pool_size: 20
    max_overflow: 40

  mongodb:
    host: "mongodb-production.internal"
    user: "${MONGODB_USER}"
    password: "${MONGODB_PASSWORD}"
    max_pool_size: 20

storage:
  endpoint: "https://s3-production.internal"
  access_key: "${AWS_ACCESS_KEY_ID}"
  secret_key: "${AWS_SECRET_ACCESS_KEY}"
  secure: true

cache:
  redis:
    host: "redis-production.internal"
    password: "${REDIS_PASSWORD}"
    max_connections: 100
    
  default_ttl: 600  # 10 minutes

messaging:
  kafka:
    bootstrap_servers: ["kafka-1.production.internal:9092", "kafka-2.production.internal:9092"]
    security_protocol: "SASL_SSL"
    sasl_mechanism: "PLAIN"
    sasl_username: "${KAFKA_USERNAME}"
    sasl_password: "${KAFKA_PASSWORD}"

orchestration:
  airflow:
    host: "airflow-production.internal"
    user: "${AIRFLOW_USER}"
    password: "${AIRFLOW_PASSWORD}"
    executor: "CeleryExecutor"
    parallel_workers: 16

monitoring:
  prometheus:
    host: "prometheus-production.internal"
    
  grafana:
    host: "grafana-production.internal"
    user: "${GRAFANA_USER}"
    password: "${GRAFANA_PASSWORD}"

security:
  jwt:
    secret: "${JWT_SECRET}"
    expiration_hours: 12
    
  cors:
    allowed_origins: ["https://app.example.com"]
    
  audit:
    enabled: true
    log_file: "/var/log/audit.log"

performance:
  query_cache_ttl: 600
  session_ttl: 7200  # 2 hours
  batch_size: 50000

# Production-specific settings
features:
  hot_reload: false
  mock_external_apis: false
  enable_debug_toolbar: false
  auto_migrate: false
  
  backup_enabled: true
  backup_schedule: "0 2 * * *"  # 2 AM daily
  
  disaster_recovery:
    enabled: true
    region: "us-west-2"
    failover_auto: true
```

**File: `config/test.yaml`**
```yaml
# ============================================
# TEST ENVIRONMENT CONFIGURATION
# ============================================

app:
  debug: false
  log_level: "WARNING"

server:
  port: 8000
  workers: 1
  reload: false

databases:
  postgres:
    host: "localhost"
    database: "dataarch_test"
    pool_size: 2
    max_overflow: 5
    
  mysql:
    host: "localhost"
    database: "dataarch_test"
    pool_size: 2
    max_overflow: 5

  mongodb:
    host: "localhost"
    database: "dataarch_test"
    max_pool_size: 5

storage:
  endpoint: "http://localhost:9000"
  buckets:
    raw: "data-lake-test"
    staging: "staging-test"
    processed: "processed-test"

cache:
  redis:
    host: "localhost"
    db: 1  # Separate DB for tests
    
  default_ttl: 0  # No caching in tests

messaging:
  kafka:
    bootstrap_servers: ["localhost:9092"]
    auto_offset_reset: "earliest"

performance:
  query_cache_ttl: 0  # Disable cache in tests
  batch_size: 100

# Test-specific settings
features:
  mock_external_apis: true
  enable_debug_toolbar: false
  auto_migrate: true
```

**File: `config/local.yaml.example`**
```yaml
# ============================================
# LOCAL OVERRIDE CONFIGURATION
# Copy to config/local.yaml and customize
# This file is gitignored
# ============================================

# Example: Override database settings
databases:
  postgres:
    host: "localhost"
    password: "my_local_password"
    
  mysql:
    host: "localhost"
    password: "my_local_password"

# Example: Override caching
cache:
  redis:
    host: "localhost"
    db: 2  # Use a different DB for local work

# Example: Add local debug settings
app:
  debug: true
  log_level: "DEBUG"

# Example: Add custom local features
features:
  local_debug_flag: true
  custom_data_path: "./data/local"
```

**File: `config/schema_validation.py`**
```python
#!/usr/bin/env python3
"""
Configuration Schema Validation
Validates configuration files against schemas
"""

import json
import jsonschema
from typing import Dict, Any, List

class ConfigValidator:
    """
    Validates configuration against JSON schemas
    """
    
    CONFIG_SCHEMA = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "properties": {
            "app": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "version": {"type": "string"},
                    "debug": {"type": "boolean"},
                    "log_level": {"type": "string"}
                },
                "required": ["name"]
            },
            "databases": {
                "type": "object",
                "properties": {
                    "postgres": {
                        "type": "object",
                        "properties": {
                            "host": {"type": "string"},
                            "port": {"type": "integer", "minimum": 1, "maximum": 65535},
                            "database": {"type": "string"},
                            "user": {"type": "string"},
                            "password": {"type": "string"},
                            "pool_size": {"type": "integer", "minimum": 1},
                            "max_overflow": {"type": "integer", "minimum": 0}
                        },
                        "required": ["host", "database", "user"]
                    }
                }
            },
            "cache": {
                "type": "object",
                "properties": {
                    "default_ttl": {"type": "integer", "minimum": 0},
                    "max_size": {"type": "integer", "minimum": 1}
                }
            },
            "logging": {
                "type": "object",
                "properties": {
                    "level": {"type": "string"},
                    "format": {"type": "string"},
                    "file": {"type": "string"}
                }
            },
            "server": {
                "type": "object",
                "properties": {
                    "host": {"type": "string"},
                    "port": {"type": "integer", "minimum": 1, "maximum": 65535},
                    "workers": {"type": "integer", "minimum": 1},
                    "timeout": {"type": "integer", "minimum": 1}
                }
            }
        },
        "required": ["app"]
    }
    
    @classmethod
    def validate_config(cls, config: Dict[str, Any]) -> List[str]:
        """
        Validate configuration against schema
        Returns list of validation errors
        """
        errors = []
        try:
            jsonschema.validate(config, cls.CONFIG_SCHEMA)
        except jsonschema.ValidationError as e:
            errors.append(str(e))
        except jsonschema.SchemaError as e:
            errors.append(f"Schema error: {e}")
        
        # Additional custom validation
        errors.extend(cls._custom_validation(config))
        
        return errors
    
    @classmethod
    def _custom_validation(cls, config: Dict[str, Any]) -> List[str]:
        """Additional custom validation rules"""
        errors = []
        
        # Validate logging level
        if 'logging' in config:
            level = config['logging'].get('level', 'INFO')
            valid_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
            if level not in valid_levels:
                errors.append(f"Invalid log level: {level}")
        
        # Validate database pool settings
        if 'databases' in config:
            for db_type, db_config in config['databases'].items():
                if 'pool_size' in db_config and 'max_overflow' in db_config:
                    if db_config['max_overflow'] < 0:
                        errors.append(f"{db_type}: max_overflow must be >= 0")
        
        # Validate cache settings
        if 'cache' in config:
            ttl = config['cache'].get('default_ttl', 0)
            if ttl < 0:
                errors.append("cache.default_ttl must be >= 0")
        
        return errors

# Example usage
if __name__ == "__main__":
    import yaml
    
    # Load a config file
    with open('config/default.yaml', 'r') as f:
        config = yaml.safe_load(f)
    
    # Validate
    errors = ConfigValidator.validate_config(config)
    
    if errors:
        print("❌ Configuration validation failed:")
        for error in errors:
            print(f"  - {error}")
    else:
        print("✅ Configuration is valid")
```

## C.2 Environment Variables Reference

**File: `.env.example`**
```bash
# ============================================
# DATA ARCHITECTURE TUTORIAL
# ENVIRONMENT VARIABLES
# ============================================

# ============================================
# APPLICATION
# ============================================

APP_ENV=development
APP_NAME="Data Architecture Tutorial"
APP_VERSION=1.0.0
APP_DEBUG=true
APP_LOG_LEVEL=INFO
APP_SECRET_KEY=2g7v8w9x10y11z12a13b14c15d16e17f18

# ============================================
# SERVER
# ============================================

SERVER_HOST=0.0.0.0
SERVER_PORT=8000
SERVER_WORKERS=4
SERVER_TIMEOUT=60
SERVER_MAX_REQUEST_SIZE=104857600

# ============================================
# DATABASES
# ============================================

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=dataarch
POSTGRES_USER=dataarch
POSTGRES_PASSWORD=dataarch123
POSTGRES_POOL_SIZE=10
POSTGRES_MAX_OVERFLOW=20
POSTGRES_POOL_TIMEOUT=30
POSTGRES_SSL_MODE=prefer

# MySQL
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=dataarch
MYSQL_USER=dataarch
MYSQL_PASSWORD=dataarch123
MYSQL_ROOT_PASSWORD=root123
MYSQL_POOL_SIZE=10
MYSQL_MAX_OVERFLOW=20

# MongoDB
MONGODB_HOST=localhost
MONGODB_PORT=27017
MONGODB_DATABASE=dataarch
MONGODB_USER=root
MONGODB_PASSWORD=root123
MONGODB_AUTH_SOURCE=admin
MONGODB_MAX_POOL_SIZE=10

# ============================================
# OBJECT STORAGE (MinIO / S3)
# ============================================

AWS_ENDPOINT=http://localhost:9000
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin123
AWS_REGION=us-east-1
AWS_SECURE=false

S3_BUCKET_RAW=data-lake
S3_BUCKET_STAGING=staging
S3_BUCKET_PROCESSED=processed
S3_BUCKET_ANALYTICS=analytics
S3_BUCKET_FEATURES=feature-store
S3_BUCKET_MODELS=ml-models
S3_BUCKET_LOGS=logs

# ============================================
# CACHING
# ============================================

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=
REDIS_MAX_CONNECTIONS=50
REDIS_SOCKET_TIMEOUT=5
REDIS_RETRY_ON_TIMEOUT=true

# Memcached
MEMCACHED_SERVERS=localhost:11211
MEMCACHED_CONNECT_TIMEOUT=1
MEMCACHED_TIMEOUT=2

CACHE_DEFAULT_TTL=300
CACHE_MAX_SIZE=1000

# ============================================
# MESSAGE QUEUE (Kafka)
# ============================================

KAFKA_BOOTSTRAP_SERVERS=localhost:9092
KAFKA_CLIENT_ID=dataarch-client
KAFKA_GROUP_ID=dataarch-consumer
KAFKA_AUTO_OFFSET_RESET=earliest
KAFKA_ENABLE_AUTO_COMMIT=true
KAFKA_MAX_POLL_RECORDS=500
KAFKA_SECURITY_PROTOCOL=PLAINTEXT

KAFKA_TOPIC_DATA_EVENTS=data-events
KAFKA_TOPIC_SYSTEM_ALERTS=system-alerts
KAFKA_TOPIC_METRICS=metrics
KAFKA_TOPIC_AUDIT=audit

# ============================================
# ORCHESTRATION (Airflow)
# ============================================

AIRFLOW_HOST=localhost
AIRFLOW_PORT=8081
AIRFLOW_USER=admin
AIRFLOW_PASSWORD=admin123
AIRFLOW_DAG_FOLDER=/opt/airflow/dags
AIRFLOW_EXECUTOR=LocalExecutor
AIRFLOW_PARALLEL_WORKERS=4

AIRFLOW_SCHEDULE_TIMEZONE=UTC
AIRFLOW_DEFAULT_RETRIES=3
AIRFLOW_RETRY_DELAY=300

# ============================================
# ML / AI
# ============================================

FEATURE_STORE_PATH=./data/feature_store
FEATURE_STORE_BACKEND=local
FEATURE_STORE_CACHE_SIZE=1000

MODEL_REGISTRY_PATH=./data/models
MODEL_REGISTRY_BACKEND=local

VECTOR_DB_DIMENSION=128
VECTOR_DB_COLLECTION=embeddings
VECTOR_DB_DISTANCE_METRIC=cosine

RAG_TOP_K=3
RAG_MODEL=gpt-4
RAG_TEMPERATURE=0.7
RAG_MAX_TOKENS=1000

OPENAI_API_KEY=your_openai_key_here

# ============================================
# MONITORING
# ============================================

PROMETHEUS_HOST=localhost
PROMETHEUS_PORT=9090
PROMETHEUS_PATH=/metrics

GRAFANA_HOST=localhost
GRAFANA_PORT=3000
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin123
GRAFANA_DASHBOARDS_PATH=./docker/grafana/dashboards

METRICS_COLLECTION_INTERVAL=15
METRICS_RETENTION_DAYS=30

# ============================================
# SECURITY
# ============================================

JWT_SECRET=change_this_in_production
JWT_EXPIRATION_HOURS=24
JWT_ALGORITHM=HS256

ENCRYPTION_ALGORITHM=AES-256-GCM
ENCRYPTION_KEY_ROTATION_DAYS=90

CORS_ALLOWED_ORIGINS=*
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Authorization,Content-Type

AUDIT_ENABLED=true
AUDIT_LOG_FILE=logs/audit.log
AUDIT_INCLUDE_PII=false

# ============================================
# DATA QUALITY
# ============================================

GE_DATA_CONTEXT_PATH=./docker/great_expectations
GE_CHECKPOINT_NAME=my_checkpoint

QUALITY_COMPLETENESS_THRESHOLD=0.95
QUALITY_ACCURACY_THRESHOLD=0.90
QUALITY_TIMELINESS_THRESHOLD=0.85

QUALITY_CHECK_FREQUENCY=3600
QUALITY_ALERT_ON_FAILURE=true

# ============================================
# GOVERNANCE
# ============================================

AMUNDSEN_HOST=localhost
AMUNDSEN_PORT=5000

DATA_LINEAGE_ENABLED=true
DATA_LINEAGE_TRACKING_INTERVAL=300

GDPR_ENABLED=true
GDPR_RETENTION_DAYS=365

CCPA_ENABLED=true
CCPA_OPT_OUT_ENABLED=true

# ============================================
# PERFORMANCE
# ============================================

QUERY_CACHE_TTL=300
SESSION_TTL=3600
BATCH_SIZE=10000
PARALLEL_WORKERS=4

COMPRESSION_ENABLED=true
COMPRESSION_ALGORITHM=snappy
COMPRESSION_LEVEL=6

BULK_CHUNK_SIZE=1000
BULK_MAX_RETRIES=3
BULK_RETRY_DELAY=1

# ============================================
# INTEGRATION
# ============================================

HTTP_TIMEOUT=30
HTTP_MAX_RETRIES=3
HTTP_RETRY_DELAY=1

WEBHOOKS_ENABLED=true
WEBHOOKS_RETRY_ATTEMPTS=3
WEBHOOKS_RETRY_DELAY=60

SLACK_WEBHOOK_URL=
SENDGRID_API_KEY=

# ============================================
# DEVELOPMENT ONLY
# ============================================

DEV_HOT_RELOAD=true
DEV_MOCK_EXTERNAL_APIS=true
DEV_ENABLE_DEBUG_TOOLBAR=true
DEV_AUTO_MIGRATE=true

# ============================================
# PRODUCTION ONLY
# ============================================

PROD_BACKUP_ENABLED=true
PROD_BACKUP_SCHEDULE="0 2 * * *"
PROD_DR_ENABLED=true
PROD_DR_REGION=us-west-2
PROD_DR_FAILOVER_AUTO=true
```

## C.3 Docker Configuration Reference

**File: `docker/postgres/conf/postgresql.conf`**
```conf
# ============================================
# PostgreSQL Configuration
# ============================================

# Connections
max_connections = 100
superuser_reserved_connections = 3
tcp_keepalives_idle = 60
tcp_keepalives_interval = 15
tcp_keepalives_count = 5

# Memory
shared_buffers = 256MB
work_mem = 8MB
maintenance_work_mem = 64MB
effective_cache_size = 1GB

# Write-ahead log
wal_level = replica
fsync = on
wal_sync_method = fdatasync
full_page_writes = on
wal_buffers = 16MB
wal_writer_delay = 200ms
commit_delay = 0
commit_siblings = 5

# Checkpoint
checkpoint_timeout = 5min
checkpoint_completion_target = 0.9
checkpoint_flush_after = 256kB

# Query tuning
enable_hashjoin = on
enable_mergejoin = on
enable_nestloop = on
seq_page_cost = 1.0
random_page_cost = 4.0
effective_io_concurrency = 2

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d.log'
log_file_mode = 0600
log_min_duration_statement = 5000
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_statement = 'ddl'
log_line_prefix = '%m [%p] %q%u@%d '

# Monitoring
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
pg_stat_statements.max = 10000
pg_stat_statements.save = on
track_activity_query_size = 2048
track_counts = on
track_io_timing = on
track_functions = all

# Optimization
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 32MB
maintenance_work_mem = 1GB
max_wal_size = 4GB
min_wal_size = 1GB
```

## C.4 Kubernetes Configuration Reference

**File: `k8s/configmap.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dataarch-config
  namespace: data-platform
data:
  APP_ENV: "production"
  APP_NAME: "Data Architecture Platform"
  
  POSTGRES_HOST: "postgres-service"
  POSTGRES_PORT: "5432"
  POSTGRES_DB: "dataarch"
  POSTGRES_POOL_SIZE: "20"
  
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"
  REDIS_DB: "0"
  
  KAFKA_BOOTSTRAP_SERVERS: "kafka-service:9092"
  KAFKA_GROUP_ID: "dataarch-consumer"
  
  AWS_REGION: "us-east-1"
  S3_BUCKET_RAW: "data-lake-prod"
  S3_BUCKET_PROCESSED: "processed-prod"
  
  CACHE_DEFAULT_TTL: "600"
  QUERY_CACHE_TTL: "600"
  BATCH_SIZE: "50000"
  
  LOG_LEVEL: "INFO"
  METRICS_COLLECTION_INTERVAL: "15"
  
  GDPR_ENABLED: "true"
  GDPR_RETENTION_DAYS: "365"
  CCPA_ENABLED: "true"
  
  RAG_TOP_K: "3"
  RAG_MODEL: "gpt-4"
  VECTOR_DB_DIMENSION: "128"
  
  QUALITY_CHECK_FREQUENCY: "3600"
  QUALITY_ALERT_ON_FAILURE: "true"
  
  DATA_LINEAGE_ENABLED: "true"
  AUDIT_ENABLED: "true"
  
  PROMETHEUS_HOST: "prometheus-service"
  GRAFANA_HOST: "grafana-service"
```

**File: `k8s/secrets.yaml`**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dataarch-secrets
  namespace: data-platform
type: Opaque
data:
  # Values are base64 encoded
  postgres-password: ZGF0YWFyY2gxMjM=  # dataarch123
  mysql-password: ZGF0YWFyY2gxMjM=     # dataarch123
  mongodb-password: cm9vdDEyMw==       # root123
  redis-password: ""                    # Empty string base64 encoded
  jwt-secret: Y2hhbmdlX3RoaXNfaW5fcHJvZHVjdGlvbg==
  encryption-key: Y2hhbmdlX3RoaXNfaW5fcHJvZHVjdGlvbg==
  airflow-password: YWRtaW4xMjM=        # admin123
  grafana-password: YWRtaW4xMjM=        # admin123
  slack-webhook-url: aHR0cHM6Ly9ob29rcy5zbGFjay5jb20v
  sendgrid-api-key: U0cuYXBpLmtleQ==
```

## C.5 Configuration Verification Script

**File: `scripts/verify_config.py`**
```python
#!/usr/bin/env python3
"""
Configuration Verification Script
Validates all configuration files
"""

import os
import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any

def verify_config_files():
    """Verify all configuration files"""
    print("="*60)
    print("CONFIGURATION VERIFICATION")
    print("="*60)
    
    config_dir = Path("config")
    errors = []
    
    # Check for required files
    required_files = ['default.yaml', 'development.yaml', 'production.yaml', 'test.yaml']
    for filename in required_files:
        filepath = config_dir / filename
        if not filepath.exists():
            errors.append(f"Missing required file: {filename}")
        else:
            print(f"✅ Found: {filename}")
    
    # Validate each config file
    for yaml_file in config_dir.glob("*.yaml"):
        print(f"\n📄 Validating: {yaml_file.name}")
        
        try:
            with open(yaml_file, 'r') as f:
                config = yaml.safe_load(f)
            
            # Check required sections
            if 'app' not in config:
                errors.append(f"{yaml_file.name}: Missing 'app' section")
            else:
                print(f"  ✅ Has 'app' section")
            
            # Check database configuration
            if 'databases' in config:
                print(f"  ✅ Has 'databases' section")
                for db_name in config['databases']:
                    print(f"    - {db_name}")
            
            # Check other sections
            sections = ['cache', 'logging', 'server', 'security', 'monitoring']
            for section in sections:
                if section in config:
                    print(f"  ✅ Has '{section}' section")
            
            # Validate environment-specific settings
            if yaml_file.name == 'production.yaml':
                # Check for environment variable references
                if '${' in str(config):
                    print(f"  ✅ Has environment variable references")
                
                # Check for SSL/TLS settings
                if 'databases' in config:
                    for db in config['databases'].values():
                        if 'ssl_mode' in db or 'ssl' in db:
                            print(f"  ✅ Has SSL/TLS settings")
            
            print(f"✅ {yaml_file.name} is valid")
            
        except yaml.YAMLError as e:
            errors.append(f"{yaml_file.name}: YAML error - {e}")
        except Exception as e:
            errors.append(f"{yaml_file.name}: Error - {e}")
    
    # Verify .env file
    env_file = Path('.env')
    if env_file.exists():
        print(f"\n📄 Validating: .env")
        with open(env_file, 'r') as f:
            env_content = f.read()
        
        # Check for required variables
        required_vars = ['APP_ENV', 'POSTGRES_HOST', 'REDIS_HOST', 'KAFKA_BOOTSTRAP_SERVERS']
        for var in required_vars:
            if var not in env_content:
                errors.append(f".env: Missing {var}")
            else:
                print(f"  ✅ Has {var}")
        
        # Check for production-specific variables
        if 'APP_ENV=production' in env_content:
            required_prod_vars = ['JWT_SECRET', 'ENCRYPTION_KEY']
            for var in required_prod_vars:
                if var in env_content and 'change_this' in env_content:
                    errors.append(f".env: {var} still uses default value")
                elif var in env_content:
                    print(f"  ✅ Has {var} (custom value)")
    
    # Summary
    print("\n" + "="*60)
    if errors:
        print(f"❌ Found {len(errors)} configuration issues:")
        for error in errors:
            print(f"  - {error}")
        return False
    else:
        print("✅ All configurations are valid!")
        return True

if __name__ == "__main__":
    sys.exit(0 if verify_config_files() else 1)
```

## Verification

Let's verify the configuration system:

```bash
# Navigate to the config directory
cd config

# Run the configuration validation
python schema_validation.py

# Verify all config files
python ../scripts/verify_config.py

# Test the config loader
python -c "
from config_loader import config
print('Environment:', config.get_env())
print('App Name:', config.get('app.name'))
print('Database:', config.get('databases.postgres.host'))
"

# Expected output:
# Environment: development
# App Name: Data Architecture Tutorial
# Database: localhost
```
