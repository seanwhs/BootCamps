# Primer 12: Cloud and MLOps

## Overview

This primer provides a comprehensive introduction to cloud computing and MLOps (Machine Learning Operations) for deploying and managing ML systems at scale. Understanding these concepts is essential for building production-grade ML systems that are reliable, scalable, and maintainable.

---

## 1. Cloud Computing Fundamentals

### Cloud Service Models

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLOUD SERVICE MODELS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  On-Premises          │  Infrastructure as a Service (IaaS)    │
│  ┌─────────────────┐  │  ┌─────────────────────────────────┐  │
│  │  Applications   │  │  │  Applications  │  (you manage)   │  │
│  │  Data           │  │  │  Data          │                  │  │
│  │  Runtime        │  │  │  Runtime       │                  │  │
│  │  Middleware     │  │  │  Middleware    │                  │  │
│  │  OS             │  │  │  OS            │                  │  │
│  │  Virtualization │  │  │  Virtualization│  (provider)     │  │
│  │  Servers        │  │  │  Servers       │                  │  │
│  │  Storage        │  │  │  Storage       │                  │  │
│  │  Networking     │  │  │  Networking    │                  │  │
│  └─────────────────┘  │  └─────────────────────────────────┘  │
│                                                                 │
│  Platform as a Service (PaaS) │  Software as a Service (SaaS)  │
│  ┌─────────────────────────┐  │  ┌─────────────────────────┐  │
│  │  Applications  │(you)    │  │  │  Applications  │(provider) │  │
│  │  Data          │         │  │  │  Data          │           │  │
│  │  Runtime       │         │  │  │  Runtime       │           │  │
│  │  Middleware    │(provider)│  │  │  Middleware    │           │  │
│  │  OS            │         │  │  │  OS            │           │  │
│  │  Virtualization│         │  │  │  Virtualization│           │  │
│  │  Servers       │         │  │  │  Servers       │           │  │
│  │  Storage       │         │  │  │  Storage       │           │  │
│  │  Networking    │         │  │  │  Networking    │           │  │
│  └─────────────────────────┘  │  └─────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Major Cloud Providers

| Provider | ML Services | Best For |
|----------|-------------|----------|
| **AWS** | SageMaker, Bedrock, Rekognition | Full ecosystem, enterprise |
| **Azure** | Azure ML, Cognitive Services | Microsoft integration |
| **GCP** | Vertex AI, AutoML, BigQuery | Data and AI focus |
| **Databricks** | MLflow, Feature Store | Data engineering + ML |

---

## 2. MLOps Fundamentals

### The MLOps Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    MLOPS LIFECYCLE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    PLAN                                  │  │
│  │  Business Goals → Success Metrics → Requirements        │  │
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
│  │  Feature Engineering → Model Training → Tuning           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    DEPLOY                                │  │
│  │  Packaging → Testing → Deployment → Monitoring          │  │
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

### MLOps vs DevOps

```
┌─────────────────────────────────────────────────────────────────┐
│                    MLOPS VS DEVOPS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  DevOps                    │  MLOps                           │
│  ┌─────────────────────┐  │  ┌─────────────────────────────┐ │
│  │  Code               │  │  │  Code + Data + Models       │ │
│  │  Build              │  │  │  Data Versioning            │ │
│  │  Test               │  │  │  Model Testing              │ │
│  │  Deploy             │  │  │  Model Deployment           │ │
│  │  Monitor            │  │  │  Model Monitoring           │ │
│  │  Rollback           │  │  │  Model Rollback             │ │
│  └─────────────────────┘  │  └─────────────────────────────┘ │
│                                                                 │
│  Key Differences:                                              │
│  • Models need continuous retraining                           │
│  • Data drift affects performance                              │
│  • Model evaluation is complex                                 │
│  • Feature engineering is critical                             │
│  • Business metrics matter more than technical metrics         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. ML Pipeline Orchestration

### Apache Airflow

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'ml_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'ml_pipeline',
    default_args=default_args,
    description='ML Pipeline',
    schedule_interval='@daily',
    catchup=False
)

def extract_data(**context):
    """Extract data from source."""
    import pandas as pd
    df = pd.read_csv('data/raw/data.csv')
    return df.to_json()

def transform_data(**context):
    """Transform data."""
    import pandas as pd
    ti = context['ti']
    data_json = ti.xcom_pull(task_ids='extract_data')
    df = pd.read_json(data_json)
    # Transformations
    df_processed = df.dropna()
    return df_processed.to_json()

def train_model(**context):
    """Train the model."""
    import pandas as pd
    from sklearn.ensemble import RandomForestClassifier
    
    ti = context['ti']
    data_json = ti.xcom_pull(task_ids='transform_data')
    df = pd.read_json(data_json)
    
    X = df.drop('target', axis=1)
    y = df['target']
    
    model = RandomForestClassifier()
    model.fit(X, y)
    
    # Save model
    import joblib
    joblib.dump(model, 'models/model.joblib')
    return 'Model trained successfully'

def evaluate_model(**context):
    """Evaluate the model."""
    import joblib
    from sklearn.metrics import accuracy_score
    
    model = joblib.load('models/model.joblib')
    # Evaluation logic
    
    return 'Model evaluation complete'

def deploy_model(**context):
    """Deploy the model."""
    # Deployment logic
    return 'Model deployed successfully'

# Define tasks
extract_task = PythonOperator(
    task_id='extract_data',
    python_callable=extract_data,
    dag=dag
)

transform_task = PythonOperator(
    task_id='transform_data',
    python_callable=transform_data,
    dag=dag
)

train_task = PythonOperator(
    task_id='train_model',
    python_callable=train_model,
    dag=dag
)

evaluate_task = PythonOperator(
    task_id='evaluate_model',
    python_callable=evaluate_model,
    dag=dag
)

deploy_task = PythonOperator(
    task_id='deploy_model',
    python_callable=deploy_model,
    dag=dag
)

# Set dependencies
extract_task >> transform_task >> train_task >> evaluate_task >> deploy_task
```

### Kubeflow Pipelines

```python
import kfp
from kfp import dsl
from kfp.dsl import ContainerOp

@dsl.pipeline(
    name='ML Training Pipeline',
    description='End-to-end ML pipeline'
)
def ml_pipeline(
    data_path: str = 's3://bucket/data.csv',
    model_type: str = 'xgboost',
    n_estimators: int = 100
):
    """ML pipeline using Kubeflow."""
    
    # Data preprocessing
    preprocess = ContainerOp(
        name='preprocess_data',
        image='preprocess:latest',
        command=['python', 'preprocess.py'],
        arguments=['--data-path', data_path],
        file_outputs={'processed_path': '/output/processed.csv'}
    )
    
    # Train model
    train = ContainerOp(
        name='train_model',
        image='train:latest',
        command=['python', 'train.py'],
        arguments=[
            '--data-path', preprocess.outputs['processed_path'],
            '--model-type', model_type,
            '--n-estimators', str(n_estimators)
        ],
        file_outputs={'model_path': '/output/model.joblib'}
    )
    
    # Evaluate model
    evaluate = ContainerOp(
        name='evaluate_model',
        image='evaluate:latest',
        command=['python', 'evaluate.py'],
        arguments=['--model-path', train.outputs['model_path']],
        file_outputs={'metrics_path': '/output/metrics.json'}
    )
    
    # Deploy model (conditional on performance)
    deploy = ContainerOp(
        name='deploy_model',
        image='deploy:latest',
        command=['python', 'deploy.py'],
        arguments=[
            '--model-path', train.outputs['model_path'],
            '--metrics-path', evaluate.outputs['metrics_path']
        ]
    )
    
    # Set dependencies
    preprocess >> train >> evaluate >> deploy

# Compile pipeline
kfp.compiler.Compiler().compile(ml_pipeline, 'ml_pipeline.yaml')
```

---

## 4. Cloud ML Services

### AWS SageMaker

```python
import boto3
import sagemaker
from sagemaker import get_execution_role
from sagemaker.sklearn import SKLearn
from sagemaker.inputs import TrainingInput

# Setup SageMaker
role = get_execution_role()
sagemaker_session = sagemaker.Session()

# Create SKLearn estimator
estimator = SKLearn(
    entry_point='train.py',
    source_dir='src',
    role=role,
    instance_type='ml.m5.large',
    framework_version='1.2-1',
    py_version='py3',
    hyperparameters={
        'n_estimators': 100,
        'max_depth': 6
    }
)

# Train
estimator.fit({
    'train': TrainingInput('s3://bucket/train/'),
    'validation': TrainingInput('s3://bucket/validation/')
})

# Deploy
predictor = estimator.deploy(
    initial_instance_count=1,
    instance_type='ml.t2.medium'
)

# Make predictions
predictions = predictor.predict(data)

# Clean up
predictor.delete_endpoint()
```

### Azure ML

```python
from azureml.core import Workspace, Experiment, Environment
from azureml.core.compute import ComputeTarget, AmlCompute
from azureml.core.compute_target import ComputeTargetException
from azureml.train.sklearn import SKLearn

# Connect to workspace
ws = Workspace.from_config()

# Create compute cluster
try:
    compute_target = ComputeTarget(workspace=ws, name='cpu-cluster')
except ComputeTargetException:
    compute_config = AmlCompute.provisioning_configuration(
        vm_size='STANDARD_D2_V2',
        min_nodes=0,
        max_nodes=4
    )
    compute_target = ComputeTarget.create(ws, 'cpu-cluster', compute_config)
    compute_target.wait_for_completion()

# Create environment
env = Environment('sklearn-env')
env.python.conda_dependencies.add_pip_package('scikit-learn')
env.python.conda_dependencies.add_pip_package('pandas')

# Configure training
estimator = SKLearn(
    source_directory='.',
    entry_script='train.py',
    compute_target=compute_target,
    environment_definition=env,
    framework_version='1.2'
)

# Submit experiment
experiment = Experiment(ws, 'ml-pipeline')
run = experiment.submit(estimator)
run.wait_for_completion()

# Register model
model = run.register_model(
    model_name='churn-model',
    model_path='outputs/model.joblib'
)
```

### GCP Vertex AI

```python
from google.cloud import aiplatform

# Initialize Vertex AI
aiplatform.init(
    project='my-project',
    location='us-central1',
    staging_bucket='gs://my-bucket'
)

# Create custom job
job = aiplatform.CustomJob(
    display_name='churn-prediction',
    worker_pool_specs=[{
        'machine_spec': {
            'machine_type': 'n1-standard-4',
        },
        'replica_count': 1,
        'container_spec': {
            'image_uri': 'us-docker.pkg.dev/vertex-ai/training/scikit-learn-cpu.0-24:latest',
            'command': [],
            'args': [
                'python', '-m', 'train',
                '--data-path', 'gs://bucket/data.csv',
                '--model-output', '/model/model.joblib'
            ]
        }
    }]
)

# Run job
job.run()

# Deploy model
endpoint = aiplatform.Endpoint.create(
    display_name='churn-endpoint',
    project='my-project',
    location='us-central1'
)

model = aiplatform.Model.upload(
    display_name='churn-model',
    artifact_uri='gs://bucket/models/',
    serving_container_image_uri='us-docker.pkg.dev/vertex-ai/prediction/sklearn-cpu.0-24:latest'
)

endpoint.deploy(model, traffic_percentage=100)
```

---

## 5. Containerization for ML

### Dockerfile for ML

```dockerfile
# Multi-stage build for ML model

# Base image
FROM python:3.9-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Copy source code
COPY . .

# Build stage
FROM python:3.9-slim

# Copy from builder
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

# Set PATH
ENV PATH=/root/.local/bin:$PATH

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Run the application
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Kubernetes Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-api
  labels:
    app: ml-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ml-api
  template:
    metadata:
      labels:
        app: ml-api
    spec:
      containers:
      - name: ml-api
        image: ml-api:latest
        ports:
        - containerPort: 8000
        env:
        - name: MODEL_PATH
          value: "/models/churn_pipeline.joblib"
        - name: LOG_LEVEL
          value: "INFO"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: model-volume
          mountPath: /models
      volumes:
      - name: model-volume
        persistentVolumeClaim:
          claimName: model-pvc
---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ml-api-service
spec:
  selector:
    app: ml-api
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
---
# horizontal-autoscaling.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ml-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ml-api
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
```

---

## 6. Terraform for ML Infrastructure

```hcl
# terraform/main.tf

provider "aws" {
  region = var.aws_region
}

# S3 bucket for data and models
resource "aws_s3_bucket" "ml_bucket" {
  bucket = "ml-data-${var.environment}"
  acl    = "private"
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    enabled = true
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
  }
  
  tags = {
    Environment = var.environment
    Project = "ML-Pipeline"
  }
}

# ECR repository for models
resource "aws_ecr_repository" "ml_repository" {
  name = "ml-api"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Environment = var.environment
    Project = "ML-Pipeline"
  }
}

# ECS cluster
resource "aws_ecs_cluster" "ml_cluster" {
  name = "ml-cluster-${var.environment}"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Environment = var.environment
    Project = "ML-Pipeline"
  }
}

# RDS for metadata
resource "aws_db_instance" "ml_metadata" {
  identifier     = "ml-metadata-${var.environment}"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp2"
  
  db_name  = "ml_metadata"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = var.environment != "production"
  
  tags = {
    Environment = var.environment
    Project = "ML-Pipeline"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Environment = var.environment
    Project = "ML-Pipeline"
  }
}

# Security groups
resource "aws_security_group" "api" {
  name        = "ml-api-${var.environment}"
  description = "ML API Security Group"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Environment = var.environment
    Project = "ML-Pipeline"
  }
}
```

---

## 7. Feature Store (Feast)

```yaml
# feature_store.yaml
project: ml_pipeline
provider: local
online_store: redis
offline_store: file
registry: /tmp/registry.db

# features.yaml
features:
  - name: customer_features
    entities:
      - customer_id
    schema:
      fields:
        - name: customer_id
          type: int64
          status: required
        - name: age
          type: float
        - name: tenure
          type: float
        - name: monthly_charges
          type: float
    feature_view:
      name: customer_features
      entities:
        - customer_id
      ttl: 86400
      batch_source:
        type: file
        path: /data/features/customer_features.parquet
```

---

## Quick Reference: Cloud and MLOps

### Key Commands

```bash
# AWS
aws s3 cp model.joblib s3://bucket/models/
aws sagemaker create-model --model-name model --primary-container Image=...

# Azure
az ml model register --name model --path model.joblib
az ml endpoint create --name endpoint --model model

# GCP
gcloud ai models upload --region=us-central1 --display-name=model
gcloud ai endpoints deploy --endpoint=endpoint --model=model

# Docker
docker build -t ml-api:latest .
docker push ml-api:latest
docker run -p 8000:8000 ml-api:latest

# Kubernetes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods
kubectl logs pod-name

# Terraform
terraform init
terraform plan
terraform apply
terraform destroy
```

---

## Conclusion

This primer covers the essential concepts of cloud computing and MLOps. You now understand:

1. **Cloud fundamentals**: IaaS, PaaS, SaaS, cloud providers
2. **MLOps lifecycle**: Plan, data, train, deploy, monitor, iterate
3. **Pipeline orchestration**: Airflow, Kubeflow
4. **Cloud ML services**: AWS SageMaker, Azure ML, GCP Vertex
5. **Containerization**: Docker, Kubernetes
6. **Infrastructure as Code**: Terraform
7. **Feature stores**: Feast

**Next Steps:**
1. Practice with a cloud provider
2. Build a CI/CD pipeline
3. Deploy using containers
4. Set up monitoring and alerting
5. Proceed to Part 1 of the series

---

*End of Primer 12*
