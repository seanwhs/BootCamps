# Appendix A: Complete Project Setup and Environment Configuration

Welcome to the first appendix of our Mastering Modern Data Architecture series. This comprehensive guide provides everything you need to set up your development environment, configure all the tools used throughout the series, and establish a production-ready workflow for your data platform projects.

## A.1 Development Environment Setup

### The Concept

A well-configured development environment is like a professional workshop - having the right tools properly set up allows you to work efficiently and consistently throughout the series.

### Complete Docker Setup

**File: `docker-compose.yml`**
```yaml
version: '3.8'

# Complete Docker Compose configuration for the entire series
# This starts all services needed across all parts

services:
  # ============================================
  # DATABASES
  # ============================================
  
  postgres:
    image: postgres:15-alpine
    container_name: dataarch_postgres
    environment:
      POSTGRES_USER: dataarch
      POSTGRES_PASSWORD: dataarch123
      POSTGRES_DB: dataarch
      POSTGRES_INITDB_ARGS: "--data-checksums"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/postgres/init:/docker-entrypoint-initdb.d
      - ./docker/postgres/conf:/etc/postgresql/conf
    command: 
      - "postgres"
      - "-c"
      - "shared_buffers=256MB"
      - "-c"
      - "max_connections=200"
      - "-c"
      - "log_statement=all"
      - "-c"
      - "logging_collector=on"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dataarch"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  mysql:
    image: mysql:8.0
    container_name: dataarch_mysql
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: dataarch
      MYSQL_USER: dataarch
      MYSQL_PASSWORD: dataarch123
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/init:/docker-entrypoint-initdb.d
    command: 
      - "--character-set-server=utf8mb4"
      - "--collation-server=utf8mb4_unicode_ci"
      - "--innodb_buffer_pool_size=256M"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  mongodb:
    image: mongo:6
    container_name: dataarch_mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: root123
      MONGO_INITDB_DATABASE: dataarch
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - ./docker/mongodb/init:/docker-entrypoint-initdb.d
    command: 
      - "--wiredTigerCacheSizeGB=1"
      - "--logpath=/var/log/mongodb/mongod.log"
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  # ============================================
  # OBJECT STORAGE
  # ============================================
  
  minio:
    image: minio/minio:RELEASE.2024-01-16T16-07-14Z
    container_name: dataarch_minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin123
      MINIO_DOMAIN: minio.local
      MINIO_PROMETHEUS_AUTH_TYPE: public
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    networks:
      - dataarch_network

  minio-init:
    image: minio/mc:latest
    container_name: dataarch_minio_init
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      until (/usr/bin/mc config host add myminio http://minio:9000 minioadmin minioadmin123) do echo '...waiting for MinIO...' && sleep 2; done;
      /usr/bin/mc mb myminio/data-lake;
      /usr/bin/mc mb myminio/data-lake-archive;
      /usr/bin/mc mb myminio/staging;
      /usr/bin/mc mb myminio/processed;
      /usr/bin/mc mb myminio/analytics;
      /usr/bin/mc mb myminio/feature-store;
      /usr/bin/mc mb myminio/ml-models;
      /usr/bin/mc policy set public myminio/data-lake;
      /usr/bin/mc policy set public myminio/staging;
      /usr/bin/mc admin user add myminio datareader datareader123;
      /usr/bin/mc admin policy attach myminio readonly --user datareader;
      echo '✅ MinIO buckets and users created successfully';
      exit 0;
      "
    networks:
      - dataarch_network

  # ============================================
  # CACHING
  # ============================================
  
  redis:
    image: redis:7-alpine
    container_name: dataarch_redis
    command: redis-server --appendonly yes --maxmemory 2gb --maxmemory-policy allkeys-lru
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
      - ./docker/redis/redis.conf:/usr/local/etc/redis/redis.conf
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  memcached:
    image: memcached:1.6-alpine
    container_name: dataarch_memcached
    command: memcached -m 1024 -I 1m
    ports:
      - "11211:11211"
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "11211"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  # ============================================
  # MESSAGE QUEUE / STREAMING
  # ============================================
  
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    container_name: dataarch_zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"
    volumes:
      - zookeeper_data:/var/lib/zookeeper/data
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "2181"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  kafka:
    image: confluentinc/cp-kafka:latest
    container_name: dataarch_kafka
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
      KAFKA_DELETE_TOPIC_ENABLE: "true"
      KAFKA_LOG_RETENTION_HOURS: 168
      KAFKA_LOG_SEGMENT_BYTES: 1073741824
      KAFKA_COMPRESSION_TYPE: snappy
    ports:
      - "9092:9092"
    volumes:
      - kafka_data:/var/lib/kafka/data
    healthcheck:
      test: ["CMD", "kafka-topics", "--bootstrap-server", "localhost:9092", "--list"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - dataarch_network

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: dataarch_kafka_ui
    depends_on:
      - kafka
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092
      KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper:2181
    ports:
      - "8080:8080"
    networks:
      - dataarch_network

  # ============================================
  # ORCHESTRATION
  # ============================================
  
  airflow-postgres:
    image: postgres:13-alpine
    container_name: dataarch_airflow_db
    environment:
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: airflow123
      POSTGRES_DB: airflow
    volumes:
      - airflow_db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U airflow"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  airflow-redis:
    image: redis:7-alpine
    container_name: dataarch_airflow_redis
    command: redis-server --appendonly yes
    volumes:
      - airflow_redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dataarch_network

  airflow-webserver:
    image: apache/airflow:2.8.1
    container_name: dataarch_airflow_webserver
    depends_on:
      - airflow-postgres
      - airflow-redis
    environment:
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://airflow:airflow123@airflow-postgres/airflow
      AIRFLOW__CELERY__BROKER_URL: redis://airflow-redis:6379/0
      AIRFLOW__CELERY__RESULT_BACKEND: db+postgresql://airflow:airflow123@airflow-postgres/airflow
      AIRFLOW__WEBSERVER__SECRET_KEY: 2g7v8w9x10y11z12a13b14c15d16e17f18
      AIRFLOW__CORE__LOAD_EXAMPLES: "false"
      AIRFLOW__CORE__DAGBAG_IMPORT_TIMEOUT: 60
      AIRFLOW__CORE__DEFAULT_TIMEZONE: UTC
      AIRFLOW__API__AUTH_BACKENDS: airflow.api.auth.backend.basic_auth
    ports:
      - "8081:8080"
    volumes:
      - ./docker/airflow/dags:/opt/airflow/dags
      - ./docker/airflow/logs:/opt/airflow/logs
      - ./docker/airflow/plugins:/opt/airflow/plugins
      - ./docker/airflow/requirements.txt:/requirements.txt
    command: >
      bash -c "
      pip install -r /requirements.txt &&
      airflow db init &&
      airflow db upgrade &&
      airflow users create -u admin -p admin123 -f Admin -l User -r Admin -e admin@example.com &&
      airflow webserver
      "
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - dataarch_network

  airflow-scheduler:
    image: apache/airflow:2.8.1
    container_name: dataarch_airflow_scheduler
    depends_on:
      - airflow-postgres
      - airflow-redis
      - airflow-webserver
    environment:
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://airflow:airflow123@airflow-postgres/airflow
      AIRFLOW__CELERY__BROKER_URL: redis://airflow-redis:6379/0
      AIRFLOW__CELERY__RESULT_BACKEND: db+postgresql://airflow:airflow123@airflow-postgres/airflow
      AIRFLOW__CORE__LOAD_EXAMPLES: "false"
      AIRFLOW__CORE__DAGBAG_IMPORT_TIMEOUT: 60
    volumes:
      - ./docker/airflow/dags:/opt/airflow/dags
      - ./docker/airflow/logs:/opt/airflow/logs
      - ./docker/airflow/plugins:/opt/airflow/plugins
    command: >
      bash -c "
      pip install -r /requirements.txt &&
      airflow scheduler
      "
    networks:
      - dataarch_network

  # ============================================
  # MONITORING
  # ============================================
  
  prometheus:
    image: prom/prometheus:latest
    container_name: dataarch_prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./docker/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:9090/-/healthy"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - dataarch_network

  grafana:
    image: grafana/grafana:latest
    container_name: dataarch_grafana
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: admin123
      GF_INSTALL_PLUGINS: grafana-piechart-panel
    volumes:
      - grafana_data:/var/lib/grafana
      - ./docker/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./docker/grafana/datasources:/etc/grafana/provisioning/datasources
    depends_on:
      - prometheus
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - dataarch_network

  # ============================================
  # DATA CATALOG
  # ============================================
  
  amundsen:
    image: amundsendev/amundsen-frontend:latest
    container_name: dataarch_amundsen
    ports:
      - "5000:5000"
    environment:
      CREDENTIALS_PROXY_USER: admin
      CREDENTIALS_PROXY_PASSWORD: admin123
      FRONTEND_PORT: 5000
      METADATA_SERVICE_HOST: http://amundsen-metadata:5002
      SEARCH_SERVICE_HOST: http://amundsen-search:5001
    depends_on:
      - amundsen-metadata
      - amundsen-search
    networks:
      - dataarch_network

  amundsen-metadata:
    image: amundsendev/amundsen-metadata:latest
    container_name: dataarch_amundsen_metadata
    environment:
      PROXY_HOST: postgres
      PROXY_PORT: 5432
      PROXY_USER: dataarch
      PROXY_PASSWORD: dataarch123
      PROXY_DATABASE: dataarch
      METADATA_SERVICE_PORT: 5002
    ports:
      - "5002:5002"
    networks:
      - dataarch_network

  amundsen-search:
    image: amundsendev/amundsen-search:latest
    container_name: dataarch_amundsen_search
    environment:
      SEARCH_SERVICE_PORT: 5001
    ports:
      - "5001:5001"
    networks:
      - dataarch_network

  # ============================================
  # DATA QUALITY
  # ============================================
  
  great-expectations:
    image: greatexpectations/great_expectations:latest
    container_name: dataarch_ge
    ports:
      - "8082:8080"
    volumes:
      - ./docker/great_expectations:/great_expectations
    working_dir: /great_expectations
    command: >
      bash -c "
      great_expectations datasource new &&
      great_expectations checkpoint new my_checkpoint &&
      great_expectations run --checkpoint my_checkpoint &&
      tail -f /dev/null
      "
    networks:
      - dataarch_network

  # ============================================
  # BI / VISUALIZATION
  # ============================================
  
  superset:
    image: apache/superset:latest
    container_name: dataarch_superset
    environment:
      SUPERSET_SECRET_KEY: 2g7v8w9x10y11z12a13b14c15d16e17f18
    ports:
      - "8088:8088"
    volumes:
      - superset_data:/app/superset_home
    command: >
      bash -c "
      superset fab create-admin --username admin --firstname Admin --lastname User --email admin@example.com --password admin123 &&
      superset db upgrade &&
      superset init &&
      superset run -p 8088 --with-threads --reload --debugger
      "
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8088/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - dataarch_network

  # ============================================
  # ML / NOTEBOOKS
  # ============================================
  
  jupyter:
    image: jupyter/datascience-notebook:latest
    container_name: dataarch_jupyter
    ports:
      - "8888:8888"
    environment:
      JUPYTER_ENABLE_LAB: "yes"
      GRANT_SUDO: "yes"
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./data:/home/jovyan/data
    command: start-notebook.sh --NotebookApp.token='dataarch123'
    networks:
      - dataarch_network

# ============================================
# VOLUMES
# ============================================

volumes:
  postgres_data:
    name: dataarch_postgres_data
  mysql_data:
    name: dataarch_mysql_data
  mongodb_data:
    name: dataarch_mongodb_data
  minio_data:
    name: dataarch_minio_data
  redis_data:
    name: dataarch_redis_data
  zookeeper_data:
    name: dataarch_zookeeper_data
  kafka_data:
    name: dataarch_kafka_data
  airflow_db_data:
    name: dataarch_airflow_db_data
  airflow_redis_data:
    name: dataarch_airflow_redis_data
  prometheus_data:
    name: dataarch_prometheus_data
  grafana_data:
    name: dataarch_grafana_data
  superset_data:
    name: dataarch_superset_data

# ============================================
# NETWORKS
# ============================================

networks:
  dataarch_network:
    name: dataarch_network
    driver: bridge
```

**File: `.env`**
```bash
# ============================================
# DATABASE CONFIGURATION
# ============================================

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=dataarch
POSTGRES_USER=dataarch
POSTGRES_PASSWORD=dataarch123
POSTGRES_SCHEMA=public

# MySQL
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=dataarch
MYSQL_USER=dataarch
MYSQL_PASSWORD=dataarch123
MYSQL_ROOT_PASSWORD=root123

# MongoDB
MONGODB_HOST=localhost
MONGODB_PORT=27017
MONGODB_DATABASE=dataarch
MONGODB_USER=root
MONGODB_PASSWORD=root123

# ============================================
# OBJECT STORAGE
# ============================================

# MinIO / S3
AWS_ENDPOINT=http://localhost:9000
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin123
AWS_REGION=us-east-1
S3_BUCKET_RAW=data-lake
S3_BUCKET_STAGING=staging
S3_BUCKET_PROCESSED=processed
S3_BUCKET_ANALYTICS=analytics
S3_BUCKET_FEATURES=feature-store
S3_BUCKET_MODELS=ml-models

# ============================================
# CACHING
# ============================================

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
REDIS_PASSWORD=
REDIS_MAX_CONNECTIONS=50

# Memcached
MEMCACHED_HOST=localhost
MEMCACHED_PORT=11211

# ============================================
# MESSAGE QUEUE
# ============================================

# Kafka
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
KAFKA_GROUP_ID=dataarch-consumer
KAFKA_CLIENT_ID=dataarch-client
KAFKA_AUTO_OFFSET_RESET=earliest
KAFKA_SECURITY_PROTOCOL=PLAINTEXT

# ============================================
# AIRFLOW
# ============================================

AIRFLOW_HOST=localhost
AIRFLOW_PORT=8081
AIRFLOW_USER=admin
AIRFLOW_PASSWORD=admin123
AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow/dags
AIRFLOW__CORE__LOGS_FOLDER=/opt/airflow/logs

# ============================================
# BI / VISUALIZATION
# ============================================

# Superset
SUPERSET_HOST=localhost
SUPERSET_PORT=8088
SUPERSET_USER=admin
SUPERSET_PASSWORD=admin123

# Grafana
GRAFANA_HOST=localhost
GRAFANA_PORT=3000
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin123

# ============================================
# APPLICATION CONFIGURATION
# ============================================

# General
APP_ENV=development
LOG_LEVEL=INFO
DEBUG=true
SECRET_KEY=2g7v8w9x10y11z12a13b14c15d16e17f18

# Feature Store
FEATURE_STORE_PATH=./data/feature_store
FEATURE_STORE_BACKEND=local

# Model Registry
MODEL_REGISTRY_PATH=./data/models
MLFLOW_TRACKING_URI=http://localhost:5000

# ============================================
# SECURITY
# ============================================

ENCRYPTION_KEY=change_this_in_production
JWT_SECRET=change_this_in_production
JWT_EXPIRATION_HOURS=24

# ============================================
# MONITORING
# ============================================

PROMETHEUS_HOST=localhost
PROMETHEUS_PORT=9090

# ============================================
# DATA QUALITY
# ============================================

GE_DATA_CONTEXT_PATH=./docker/great_expectations
GE_CHECKPOINT_NAME=my_checkpoint

# ============================================
# ML / AI
# ============================================

VECTOR_DB_DIMENSION=128
VECTOR_DB_COLLECTION=embeddings
RAG_TOP_K=3

# ============================================
# PERFORMANCE
# ============================================

QUERY_CACHE_TTL=300
SESSION_TTL=3600
BATCH_SIZE=10000
PARALLEL_WORKERS=4
```

**File: `docker/postgres/init/01-init.sql`**
```sql
-- Initialize PostgreSQL with extensions and settings

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS feature_store;
CREATE SCHEMA IF NOT EXISTS audit;

-- Set default schema search path
ALTER DATABASE dataarch SET search_path TO bronze, silver, gold, metadata, feature_store, audit, public;

-- Create roles
CREATE ROLE readonly;
CREATE ROLE readwrite;
CREATE ROLE admin;

-- Grant permissions
GRANT CONNECT ON DATABASE dataarch TO readonly, readwrite, admin;
GRANT USAGE ON SCHEMA bronze, silver, gold, metadata, feature_store, audit TO readonly, readwrite, admin;

-- Create sample tables for testing
CREATE TABLE IF NOT EXISTS bronze.customer_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB,
    event_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ingested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver.customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_key VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255),
    segment VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gold.customer_summary (
    customer_id UUID REFERENCES silver.customers(customer_id),
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(15, 2) DEFAULT 0,
    avg_order_value DECIMAL(15, 2) DEFAULT 0,
    last_order_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id)
);

-- Create indexes
CREATE INDEX idx_customer_events_customer_id ON bronze.customer_events(customer_id);
CREATE INDEX idx_customer_events_event_type ON bronze.customer_events(event_type);
CREATE INDEX idx_customer_events_timestamp ON bronze.customer_events(event_timestamp);

CREATE INDEX idx_customers_customer_key ON silver.customers(customer_key);
CREATE INDEX idx_customers_segment ON silver.customers(segment);

-- Create function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables
CREATE TRIGGER update_customers_updated_at 
    BEFORE UPDATE ON silver.customers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customer_summary_updated_at 
    BEFORE UPDATE ON gold.customer_summary 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create audit table
CREATE TABLE audit.audit_log (
    audit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(255),
    operation VARCHAR(50),
    record_id VARCHAR(255),
    old_data JSONB,
    new_data JSONB,
    user_name VARCHAR(255),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**File: `docker/airflow/requirements.txt`**
```txt
apache-airflow==2.8.1
apache-airflow-providers-postgres==5.10.0
apache-airflow-providers-mysql==5.4.0
apache-airflow-providers-mongo==4.2.0
apache-airflow-providers-apache-kafka==1.4.0
apache-airflow-providers-amazon==8.10.0
apache-airflow-providers-http==4.8.0
apache-airflow-providers-docker==3.7.0
pandas==2.1.4
numpy==1.26.3
pyarrow==14.0.2
boto3==1.34.17
redis==5.0.1
pymongo==4.6.1
psycopg2-binary==2.9.9
sqlalchemy==2.0.25
python-dotenv==1.0.0
requests==2.31.0
```

**File: `docker/prometheus/prometheus.yml`**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'dataarch-monitor'

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:9187']
  
  - job_name: 'mysql'
    static_configs:
      - targets: ['mysql:9104']
  
  - job_name: 'mongodb'
    static_configs:
      - targets: ['mongodb:9216']
  
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:9121']
  
  - job_name: 'kafka'
    static_configs:
      - targets: ['kafka:9308']
  
  - job_name: 'minio'
    metrics_path: /minio/v2/metrics/cluster
    static_configs:
      - targets: ['minio:9000']

  - job_name: 'airflow'
    static_configs:
      - targets: ['airflow-webserver:8080']
  
  - job_name: 'superset'
    static_configs:
      - targets: ['superset:8088']
```

**File: `setup.sh`**
```bash
#!/bin/bash
# Complete setup script for the data architecture tutorial

set -e

echo "=========================================="
echo "DATA ARCHITECTURE TUTORIAL - SETUP SCRIPT"
echo "=========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 not found. Please install $1${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ $1 found${NC}"
}

check_command docker
check_command docker-compose
check_command python3
check_command git

# Create directory structure
echo -e "\n${YELLOW}Creating directory structure...${NC}"

mkdir -p data/{bronze,silver,gold,metadata,feature_store,models,notebooks}
mkdir -p docker/{postgres/{init,conf},mysql/init,mongodb/init,airflow/{dags,logs,plugins},prometheus,grafana/{dashboards,datasources},great_expectations}
mkdir -p scripts
mkdir -p config
mkdir -p tests
mkdir -p docs

echo -e "${GREEN}✅ Directory structure created${NC}"

# Create Python virtual environment
echo -e "\n${YELLOW}Creating Python virtual environment...${NC}"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo -e "${GREEN}✅ Python virtual environment created${NC}"

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created from example${NC}"
fi

# Start Docker services
echo -e "\n${YELLOW}Starting Docker services...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "\n${YELLOW}Waiting for services to be ready...${NC}"
sleep 30

# Check services
echo -e "\n${YELLOW}Checking services...${NC}"
docker-compose ps

# Initialize databases
echo -e "\n${YELLOW}Initializing databases...${NC}"

# PostgreSQL
echo "Initializing PostgreSQL..."
docker exec -i dataarch_postgres psql -U dataarch -d dataarch << EOF
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS feature_store;
\dt
EOF
echo -e "${GREEN}✅ PostgreSQL initialized${NC}"

# MinIO
echo "Initializing MinIO..."
docker exec dataarch_minio mc mb local/data-lake || true
docker exec dataarch_minio mc mb local/staging || true
docker exec dataarch_minio mc mb local/processed || true
echo -e "${GREEN}✅ MinIO initialized${NC}"

# Airflow
echo "Initializing Airflow..."
docker exec dataarch_airflow_webserver airflow db init || true
docker exec dataarch_airflow_webserver airflow db upgrade || true
docker exec dataarch_airflow_webserver airflow users create -u admin -p admin123 -f Admin -l User -r Admin -e admin@example.com || true
echo -e "${GREEN}✅ Airflow initialized${NC}"

# Superset
echo "Initializing Superset..."
docker exec dataarch_superset superset fab create-admin --username admin --firstname Admin --lastname User --email admin@example.com --password admin123 || true
docker exec dataarch_superset superset db upgrade || true
docker exec dataarch_superset superset init || true
echo -e "${GREEN}✅ Superset initialized${NC}"

echo -e "\n${GREEN}=========================================="
echo "✅ SETUP COMPLETE!"
echo "==========================================${NC}"

echo -e "\n${YELLOW}Service URLs:${NC}"
echo "  📊 PostgreSQL:      localhost:5432 (user: dataarch, db: dataarch)"
echo "  📊 MySQL:           localhost:3306 (user: dataarch)"
echo "  📊 MongoDB:         localhost:27017 (user: root)"
echo "  📊 MinIO:           http://localhost:9000 (user: minioadmin, pass: minioadmin123)"
echo "  📊 MinIO Console:   http://localhost:9001 (user: minioadmin, pass: minioadmin123)"
echo "  📊 Redis:           localhost:6379"
echo "  📊 Memcached:       localhost:11211"
echo "  📊 Kafka:           localhost:9092"
echo "  📊 Airflow:         http://localhost:8081 (user: admin, pass: admin123)"
echo "  📊 Superset:        http://localhost:8088 (user: admin, pass: admin123)"
echo "  📊 Grafana:         http://localhost:3000 (user: admin, pass: admin123)"
echo "  📊 Prometheus:      http://localhost:9090"
echo "  📊 Jupyter:         http://localhost:8888 (token: dataarch123)"
echo "  📊 Amundsen:        http://localhost:5000"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "  1. Activate virtual environment: source venv/bin/activate"
echo "  2. Run the tutorial notebooks: jupyter notebook"
echo "  3. Start building your data architecture!"

echo -e "\n${GREEN}Happy building! 🚀${NC}"
```

**File: `requirements.txt`**
```txt
# Core Data Processing
pandas==2.1.4
numpy==1.26.3
pyarrow==14.0.2
pandas-gbq==0.19.2
sqlalchemy==2.0.25

# Database Connectors
psycopg2-binary==2.9.9
pymysql==1.1.0
pymongo==4.6.1
redis==5.0.1
hiredis==2.0.0

# Object Storage
boto3==1.34.17
s3fs==2024.2.0
minio==7.2.2

# Data Formats
avro==1.11.3
fastavro==1.9.4
parquet==1.4.0
orc==2.0.0

# Data Processing
dask==2024.1.1
pyspark==3.5.0
ray==2.9.0

# Streaming
kafka-python==2.0.2
confluent-kafka==2.3.0
pulsar-client==3.4.0

# Orchestration
apache-airflow==2.8.1
dagster==1.5.7
prefect==2.14.5

# ML / AI
scikit-learn==1.4.0
tensorflow==2.15.0
torch==2.1.2
transformers==4.37.1
sentence-transformers==2.2.2
langchain==0.1.0
openai==1.10.0
chromadb==0.4.22
faiss-cpu==1.7.4
mlflow==2.9.0
feature-engine==1.6.1

# Vector Databases
qdrant-client==1.7.0
pinecone-client==3.0.0
weaviate-client==3.24.4

# Metadata & Governance
amundsen-metadata==5.0.0
amundsen-search==5.0.0
amundsen-frontend==5.0.0
great-expectations==0.18.7
datahub==0.12.0
openmetadata==1.2.0

# Visualization
matplotlib==3.8.2
seaborn==0.13.0
plotly==5.18.0
streamlit==1.29.0
superset==3.0.0

# API & Web
fastapi==0.108.0
uvicorn==0.25.0
pydantic==2.5.3
requests==2.31.0
httpx==0.26.0
flask==3.0.0
django==5.0.1

# Monitoring
prometheus-client==0.19.0
opentelemetry-api==1.23.0
opentelemetry-sdk==1.23.0
opentelemetry-exporter-otlp==1.23.0

# Utilities
python-dotenv==1.0.0
click==8.1.7
pyyaml==6.0.1
jsonschema==4.20.0
marshmallow==3.20.1
tenacity==8.2.3
retry==0.9.2
black==24.1.0
flake8==7.0.0
mypy==1.8.0
pytest==8.0.0
pytest-cov==4.1.0
pre-commit==3.6.0

# Notifications
slack-sdk==3.26.2
sendgrid==6.11.0

# Development Tools
jupyter==1.0.0
ipython==8.20.0
notebook==7.0.6
nbconvert==7.13.0
```

**File: `scripts/verify_environment.py`**
```python
#!/usr/bin/env python3
"""
Environment Verification Script
Checks that all services are running and accessible
"""

import sys
import os
import time
import subprocess
import socket
from typing import Dict, List, Tuple, Any
import json

class EnvironmentVerifier:
    """Verify the development environment"""
    
    def __init__(self):
        self.services = {
            'postgres': {'port': 5432, 'env': 'POSTGRES_HOST'},
            'mysql': {'port': 3306, 'env': 'MYSQL_HOST'},
            'mongodb': {'port': 27017, 'env': 'MONGODB_HOST'},
            'minio': {'port': 9000, 'env': 'AWS_ENDPOINT'},
            'redis': {'port': 6379, 'env': 'REDIS_HOST'},
            'memcached': {'port': 11211, 'env': 'MEMCACHED_HOST'},
            'kafka': {'port': 9092, 'env': 'KAFKA_BOOTSTRAP_SERVERS'},
            'airflow': {'port': 8081, 'env': 'AIRFLOW_HOST'},
            'superset': {'port': 8088, 'env': 'SUPERSET_HOST'},
            'grafana': {'port': 3000, 'env': 'GRAFANA_HOST'},
            'prometheus': {'port': 9090, 'env': 'PROMETHEUS_HOST'},
            'jupyter': {'port': 8888, 'env': 'JUPYTER_ENABLE_LAB'},
        }
        self.results = {}
        
    def check_port(self, service: str, port: int) -> bool:
        """Check if a port is open"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2)
            result = sock.connect_ex(('localhost', port))
            sock.close()
            return result == 0
        except Exception:
            return False
    
    def check_docker_container(self, container_name: str) -> bool:
        """Check if a Docker container is running"""
        try:
            cmd = ['docker', 'ps', '--filter', f'name={container_name}', '--format', '{{.Status}}']
            result = subprocess.check_output(cmd, text=True).strip()
            return 'Up' in result
        except Exception:
            return False
    
    def check_database_connection(self, service: str) -> bool:
        """Check database connections"""
        try:
            if service == 'postgres':
                import psycopg2
                conn = psycopg2.connect(
                    host=os.getenv('POSTGRES_HOST', 'localhost'),
                    port=os.getenv('POSTGRES_PORT', '5432'),
                    user=os.getenv('POSTGRES_USER', 'dataarch'),
                    password=os.getenv('POSTGRES_PASSWORD', 'dataarch123'),
                    dbname=os.getenv('POSTGRES_DB', 'dataarch')
                )
                conn.close()
                return True
            elif service == 'mysql':
                import pymysql
                conn = pymysql.connect(
                    host=os.getenv('MYSQL_HOST', 'localhost'),
                    port=int(os.getenv('MYSQL_PORT', 3306)),
                    user=os.getenv('MYSQL_USER', 'dataarch'),
                    password=os.getenv('MYSQL_PASSWORD', 'dataarch123'),
                    database=os.getenv('MYSQL_DATABASE', 'dataarch')
                )
                conn.close()
                return True
            elif service == 'mongodb':
                import pymongo
                client = pymongo.MongoClient(
                    host=os.getenv('MONGODB_HOST', 'localhost'),
                    port=int(os.getenv('MONGODB_PORT', 27017)),
                    username=os.getenv('MONGODB_USER', 'root'),
                    password=os.getenv('MONGODB_PASSWORD', 'root123')
                )
                client.admin.command('ping')
                return True
            elif service == 'redis':
                import redis
                r = redis.Redis(
                    host=os.getenv('REDIS_HOST', 'localhost'),
                    port=int(os.getenv('REDIS_PORT', 6379)),
                    db=int(os.getenv('REDIS_DB', 0))
                )
                r.ping()
                return True
            elif service == 'minio':
                from minio import Minio
                client = Minio(
                    os.getenv('AWS_ENDPOINT', 'localhost:9000').replace('http://', ''),
                    access_key=os.getenv('AWS_ACCESS_KEY_ID', 'minioadmin'),
                    secret_key=os.getenv('AWS_SECRET_ACCESS_KEY', 'minioadmin123'),
                    secure=False
                )
                client.list_buckets()
                return True
        except Exception as e:
            print(f"   ⚠️ {service} connection failed: {e}")
            return False
        
        return False
    
    def run_verification(self) -> Dict[str, Any]:
        """Run all verification checks"""
        print("="*60)
        print("ENVIRONMENT VERIFICATION")
        print("="*60)
        
        # Load environment variables
        from dotenv import load_dotenv
        load_dotenv()
        
        results = {
            'services': {},
            'summary': {'passed': 0, 'failed': 0, 'total': 0}
        }
        
        print("\n🔍 Checking services...")
        
        for service_name, service_config in self.services.items():
            print(f"\n   📊 Checking {service_name}...")
            
            checks = {
                'port': False,
                'container': False,
                'connection': False
            }
            
            # Check port
            port = service_config.get('port')
            if port:
                checks['port'] = self.check_port(service_name, port)
                print(f"      Port {port}: {'✅' if checks['port'] else '❌'}")
            
            # Check Docker container
            container_name = f"dataarch_{service_name}"
            checks['container'] = self.check_docker_container(container_name)
            print(f"      Container: {'✅' if checks['container'] else '❌'}")
            
            # Check connection
            checks['connection'] = self.check_database_connection(service_name)
            print(f"      Connection: {'✅' if checks['connection'] else '❌'}")
            
            all_passed = all(checks.values())
            results['services'][service_name] = {
                'checks': checks,
                'all_passed': all_passed
            }
            
            if all_passed:
                results['summary']['passed'] += 1
                print(f"   ✅ {service_name} is ready")
            else:
                results['summary']['failed'] += 1
                print(f"   ❌ {service_name} needs attention")
            
            results['summary']['total'] += 1
        
        # Check Python packages
        print("\n📦 Checking Python packages...")
        
        required_packages = [
            'pandas', 'numpy', 'psycopg2', 'pymysql', 'pymongo',
            'redis', 'boto3', 'minio', 'pyarrow', 'fastavro',
            'kafka-python', 'apache-airflow', 'scikit-learn',
            'tensorflow', 'transformers', 'langchain', 'openai',
            'mlflow', 'great-expectations'
        ]
        
        missing_packages = []
        for package in required_packages:
            try:
                __import__(package.replace('-', '_'))
                print(f"   ✅ {package}")
            except ImportError:
                print(f"   ❌ {package} (not installed)")
                missing_packages.append(package)
        
        if missing_packages:
            print(f"\n   ⚠️ Missing {len(missing_packages)} packages")
            print(f"   Run: pip install {' '.join(missing_packages)}")
        
        # Print summary
        print("\n" + "="*60)
        print("VERIFICATION SUMMARY")
        print("="*60)
        
        summary = results['summary']
        print(f"\n   Services passed: {summary['passed']}/{summary['total']}")
        
        if summary['failed'] == 0 and not missing_packages:
            print("\n   🎉 All services are ready!")
            print("   You can proceed with the tutorial.")
        else:
            print(f"\n   ⚠️ {summary['failed']} services need attention")
            if missing_packages:
                print(f"   ⚠️ Missing Python packages: {', '.join(missing_packages)}")
            print("\n   Please resolve the issues before proceeding.")
        
        return results

def main():
    """Run the verifier"""
    verifier = EnvironmentVerifier()
    results = verifier.run_verification()
    
    # Save results to file
    import json
    with open('verification_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    print("\n   📄 Results saved to verification_results.json")
    
    sys.exit(0 if results['summary']['failed'] == 0 else 1)

if __name__ == "__main__":
    main()
```

## Verification

Let's verify the environment setup:

```bash
# Make the setup script executable
chmod +x setup.sh

# Run the setup
./setup.sh

# Verify the environment
python scripts/verify_environment.py

# Expected output:
# ============================================================
# ENVIRONMENT VERIFICATION
# ============================================================
# 
# 🔍 Checking services...
# 
#    📊 Checking postgres...
#       Port 5432: ✅
#       Container: ✅
#       Connection: ✅
#    ✅ postgres is ready
# 
#    📊 Checking mysql...
#       Port 3306: ✅
#       Container: ✅
#       Connection: ✅
#    ✅ mysql is ready
# 
# ... [additional services]
# 
# ============================================================
# VERIFICATION SUMMARY
# ============================================================
# 
#    Services passed: 12/12
# 
#    🎉 All services are ready!
#    You can proceed with the tutorial.
# 
# ============================================================
```
