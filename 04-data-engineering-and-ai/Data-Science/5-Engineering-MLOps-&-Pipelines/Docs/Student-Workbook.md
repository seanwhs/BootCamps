# Student Workbook: MLOps Pipeline Engineering

## Comprehensive Hands-On Exercises and Activities

---

# TABLE OF CONTENTS

**Part 0: Introduction**
- 0.1: Course Overview and Setup
- 0.2: Environment Setup Checklist
- 0.3: Project Initialization Exercise

**Part 1: DVC (Data Version Control)**
- 1.1: DVC Setup and Initial Configuration
- 1.2: Versioning Datasets and Feature Stores
- 1.3: Remote Storage Configuration
- 1.4: Managing Data Pipelines with DVC

**Part 2: MLflow (Experiment Tracking)**
- 2.1: Setting Up MLflow Tracking
- 2.2: Logging Runs, Parameters, and Metrics
- 2.3: Visualizing Experiments and Comparing Runs
- 2.4: Implementing the Model Registry

**Part 3: Dagster (Pipeline Orchestration)**
- 3.1: Dagster Architecture and Setup
- 3.2: Building Your First DAG
- 3.3: Sensors, Schedules, and Error Handling
- 3.4: Integrating DVC and MLflow

**Part 4: Integration and Deployment**
- 4.1: End-to-End Pipeline Assembly
- 4.2: Monitoring and Alerting
- 4.3: Continuous Deployment Strategies

**Final Project: Capstone**
- 5.1: Design Document
- 5.2: Implementation Plan
- 5.3: Deliverables
- 5.4: Evaluation Rubric

---

# PART 0: INTRODUCTION

## 0.1: Course Overview and Setup

### Objectives
- Understand the course structure and expectations
- Set up your development environment
- Complete the initial project scaffold

### Pre-Reading
- Review the course syllabus
- Watch the introduction video (if available)
- Review the series Part 0: Introduction

### Activity 0.1.1: Self-Assessment

Rate your current proficiency (1-5):

1. **Python Programming:** _____
2. **Git/GitHub:** _____
3. **Machine Learning Concepts:** _____
4. **Command Line/Terminal:** _____
5. **Cloud Services (AWS/GCP/Azure):** _____
6. **Docker/Containerization:** _____
7. **CI/CD Concepts:** _____
8. **Data Engineering:** _____

**Total Score:** _____ / 40

**Notes:**
- Score < 20: Consider reviewing prerequisites first
- Score 20-30: Ready for the course, may need extra practice
- Score 30+: Well-prepared for the material

### Activity 0.1.2: Hardware Check

**Minimum Requirements:**
- CPU: 4+ cores
- RAM: 8GB+ (16GB recommended)
- Storage: 50GB+ free space
- Internet: Broadband connection

**Your System:**
- CPU Model: ____________________
- Cores/Threads: ____________________
- RAM: ____________________ GB
- Free Storage: ____________________ GB
- OS: ____________________

**Meet Requirements?** ☐ Yes ☐ No

### Activity 0.1.3: Software Checklist

**Required Software:**

| Software | Version Check | Installed? |
|----------|---------------|------------|
| Python | `python3 --version` | ☐ |
| Git | `git --version` | ☐ |
| pip | `pip --version` | ☐ |
| Virtual Environment | `python3 -m venv --help` | ☐ |
| VS Code/PyCharm | Check installed | ☐ |
| Docker | `docker --version` | ☐ |
| AWS CLI | `aws --version` | ☐ |

**Your Versions:**
- Python: ____________________
- Git: ____________________
- pip: ____________________
- Docker: ____________________
- AWS CLI: ____________________

---

## 0.2: Environment Setup Checklist

### Activity 0.2.1: Step-by-Step Setup

**Step 1: Create Project Directory**
```bash
# Create directory
mkdir mlops-pipeline-series
cd mlops-pipeline-series

# Verify
pwd
# Should show: /path/to/mlops-pipeline-series
```

**Step 2: Create Virtual Environment**
```bash
# Create venv
python3 -m venv venv

# Activate (Linux/macOS)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Verify
which python
# Should show: .../mlops-pipeline-series/venv/bin/python
```

**Step 3: Create Requirements File**

Create `requirements.txt` in the project root with:
```
numpy==1.24.3
pandas==2.0.3
scikit-learn==1.3.0
scipy==1.10.1
dvc==3.15.3
mlflow==2.4.1
dagster==1.5.3
dagster-webserver==1.5.3
```

**Step 4: Install Dependencies**
```bash
pip install -r requirements.txt
```

**Step 5: Initialize Git**
```bash
git init
echo "venv/" > .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
git add .gitignore
git commit -m "Initial commit"
```

### Activity 0.2.2: Verification

**Check 1: Verify Installations**
```bash
dvc --version
mlflow --version
dagster --version
```

**Check 2: Test Python**
```python
import numpy as np
import pandas as pd
import sklearn

print("NumPy:", np.__version__)
print("Pandas:", pd.__version__)
print("Sklearn:", sklearn.__version__)
```

**Check 3: Test Git**
```bash
git status
git log --oneline
```

### Activity 0.2.3: Troubleshooting Log

Record any issues encountered during setup:

| Issue | Solution | Status |
|-------|----------|--------|
| | | ☐ |
| | | ☐ |
| | | ☐ |

---

## 0.3: Project Initialization Exercise

### Activity 0.3.1: Directory Structure

Create the following directory structure:

```bash
mkdir -p data/{raw,processed,external}
mkdir -p models/{training,inference,registry}
mkdir -p notebooks
mkdir -p src/{data,features,utils}
mkdir -p tests
mkdir -p pipelines
mkdir -p configs
mkdir -p scripts
mkdir -p logs
mkdir -p reports
```

**Your Structure:**

```
mlops-pipeline-series/
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── models/
│   ├── training/
│   ├── inference/
│   └── registry/
├── notebooks/
├── src/
│   ├── data/
│   ├── features/
│   └── utils/
├── tests/
├── pipelines/
├── configs/
├── scripts/
├── logs/
├── reports/
├── .gitignore
├── requirements.txt
└── README.md
```

### Activity 0.3.2: Create README.md

Create a basic README.md file:

```markdown
# MLOps Pipeline Engineering Series

## Project Overview
This project implements a complete MLOps pipeline for predictive maintenance using DVC, MLflow, and Dagster.

## Tools Used
- DVC: Data version control
- MLflow: Experiment tracking
- Dagster: Pipeline orchestration

## Setup
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Project Structure
[Document your structure here]
```

### Activity 0.3.3: Initial Commit

```bash
# Add all files
git add .

# Commit
git commit -m "Initial project scaffold"

# Verify
git log --oneline
```

---

# PART 1: DVC (DATA VERSION CONTROL)

## 1.1: DVC Setup and Initial Configuration

### Objectives
- Initialize DVC in the project
- Configure DVC with Git
- Version a sample dataset

### Activity 1.1.1: DVC Initialization

**Step 1: Initialize DVC**
```bash
dvc init
```

**Expected Output:**
```
Initialized DVC repository.
You can now commit the changes to Git.
```

**Step 2: Check DVC Files**
```bash
ls -la .dvc/
```

**Step 3: Create .dvcignore**
```bash
echo "*.tmp" > .dvcignore
echo "*.log" >> .dvcignore
```

**Step 4: Commit DVC Configuration**
```bash
git add .dvc/ .dvcignore
git commit -m "Initialize DVC"
```

### Activity 1.1.2: Version Your First File

**Step 1: Create Sample Data**
```bash
echo "id,name,value" > data/raw/sample.csv
echo "1,Alice,100" >> data/raw/sample.csv
echo "2,Bob,200" >> data/raw/sample.csv
echo "3,Charlie,300" >> data/raw/sample.csv
```

**Step 2: Track with DVC**
```bash
dvc add data/raw/sample.csv
```

**Step 3: Check DVC Status**
```bash
dvc status
```

**Step 4: Commit to Git**
```bash
git add data/raw/sample.csv.dvc
git commit -m "Add sample dataset"
```

### Activity 1.1.3: Verification

**Check 1: Verify Tracking**
```bash
dvc list
```

**Check 2: Check Git Tracking**
```bash
git ls-files | grep sample
```

**Check 3: Check DVC File**
```bash
cat data/raw/sample.csv.dvc
```

### Activity 1.1.4: Exercise: Version Another File

1. Create a second dataset:
```bash
echo "date,product,sales" > data/raw/sales.csv
echo "2024-01-01,A,150" >> data/raw/sales.csv
echo "2024-01-02,B,200" >> data/raw/sales.csv
```

2. Track it with DVC

3. Verify it's tracked

4. Commit to Git

---

## 1.2: Versioning Datasets and Feature Stores

### Objectives
- Version multiple datasets
- Create a feature engineering pipeline
- Version processed data

### Activity 1.2.1: Generate Synthetic Sensor Data

**Step 1: Create Generator Script**

Create `src/data/generate_sensor_data.py`:

```python
#!/usr/bin/env python
import numpy as np
import pandas as pd
from datetime import datetime, timedelta

def generate_sensor_data(hours=24, anomaly_rate=0.05):
    np.random.seed(42)
    n_samples = hours * 60
    
    timestamps = [datetime.now() + timedelta(minutes=i) for i in range(n_samples)]
    
    data = {
        'timestamp': timestamps,
        'sensor_1': np.random.normal(20, 5, n_samples),
        'sensor_2': np.random.normal(30, 5, n_samples),
        'temperature': np.random.normal(75, 10, n_samples),
        'pressure': np.random.normal(1.2, 0.2, n_samples)
    }
    
    df = pd.DataFrame(data)
    
    # Add anomalies
    anomaly_idx = np.random.choice(n_samples, int(n_samples * anomaly_rate))
    df.loc[anomaly_idx, 'temperature'] += np.random.uniform(10, 30, len(anomaly_idx))
    
    df['label'] = 0
    df.loc[anomaly_idx, 'label'] = 1
    
    return df

if __name__ == "__main__":
    df = generate_sensor_data()
    df.to_csv('data/raw/sensor_data.csv', index=False)
    print(f"Generated {len(df)} samples")
```

**Step 2: Generate and Version Data**
```bash
python src/data/generate_sensor_data.py
dvc add data/raw/sensor_data.csv
git add src/data/generate_sensor_data.py data/raw/sensor_data.csv.dvc
git commit -m "Add sensor data generator and dataset"
```

### Activity 1.2.2: Create Feature Engineering

**Step 1: Create Feature Script**

Create `src/features/build_features.py`:

```python
#!/usr/bin/env python
import pandas as pd
import numpy as np

def build_features(input_path='data/raw/sensor_data.csv', 
                   output_path='data/processed/features.csv'):
    df = pd.read_csv(input_path, parse_dates=['timestamp'])
    
    # Time features
    df['hour'] = df['timestamp'].dt.hour
    df['day_of_week'] = df['timestamp'].dt.dayofweek
    
    # Rolling statistics
    for col in ['sensor_1', 'sensor_2', 'temperature', 'pressure']:
        df[f'{col}_rolling_mean_5'] = df[col].rolling(5).mean()
        df[f'{col}_rolling_std_5'] = df[col].rolling(5).std()
    
    # Fill missing values
    df = df.fillna(0)
    
    df.to_csv(output_path, index=False)
    print(f"Features saved to {output_path}")

if __name__ == "__main__":
    build_features()
```

**Step 2: Build and Version Features**
```bash
python src/features/build_features.py
dvc add data/processed/features.csv
git add src/features/build_features.py data/processed/features.csv.dvc
git commit -m "Add feature engineering pipeline"
```

### Activity 1.2.3: Exercise

1. Create a 48-hour dataset
2. Process it with the feature pipeline
3. Version both raw and processed data
4. Verify with `dvc status`

---

## 1.3: Remote Storage Configuration

### Objectives
- Configure AWS S3 remote storage
- Set up credentials securely
- Push data to remote

### Activity 1.3.1: AWS S3 Setup

**Step 1: Create AWS Account (if needed)**
- Go to aws.amazon.com
- Create an account
- Set up billing

**Step 2: Create S3 Bucket**
```bash
# Install AWS CLI
pip install awscli

# Configure AWS CLI
aws configure
# Enter: Access Key, Secret Key, Region, Output format

# Create bucket
aws s3 mb s3://mlops-pipeline-data-$(whoami)-$(date +%Y%m%d)
```

**Step 3: Add DVC Remote**
```bash
dvc remote add -d s3_remote s3://mlops-pipeline-data-$(whoami)-$(date +%Y%m%d)
dvc remote modify s3_remote region us-east-1
```

### Activity 1.3.2: Configure Credentials

**Step 1: Create .env File**
```bash
cat > .env << 'EOF'
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=us-east-1
EOF
```

**Step 2: Update .gitignore**
```bash
echo ".env" >> .gitignore
```

**Step 3: Configure DVC with Environment Variables**
```bash
export AWS_ACCESS_KEY_ID=$(grep AWS_ACCESS_KEY_ID .env | cut -d= -f2)
export AWS_SECRET_ACCESS_KEY=$(grep AWS_SECRET_ACCESS_KEY .env | cut -d= -f2)
```

### Activity 1.3.3: Push and Pull

**Step 1: Push Data**
```bash
dvc push
```

**Step 2: Verify Push**
```bash
aws s3 ls s3://mlops-pipeline-data-$(whoami)-$(date +%Y%m%d)/ --recursive
```

**Step 3: Simulate Pull**
```bash
# Remove local data
rm data/raw/sensor_data.csv data/processed/features.csv

# Restore
dvc pull

# Verify
ls -la data/raw/ data/processed/
```

### Activity 1.3.4: Exercise

1. Create a GCS remote (if using GCP)
2. Create a local file remote
3. Push data to both remotes
4. Test pulling from each

---

## 1.4: Managing Data Pipelines with DVC

### Objectives
- Create a DVC pipeline
- Run and monitor pipeline execution
- Compare pipeline versions

### Activity 1.4.1: Create DVC Pipeline

**Step 1: Create dvc.yaml**
```yaml
stages:
  generate_data:
    cmd: python src/data/generate_sensor_data.py --hours 48 --output data/raw/sensor_data_48h.csv
    deps:
      - src/data/generate_sensor_data.py
    outs:
      - data/raw/sensor_data_48h.csv
  
  build_features:
    cmd: python src/features/build_features.py --input data/raw/sensor_data_48h.csv --output data/processed/features_48h.csv
    deps:
      - src/features/build_features.py
      - data/raw/sensor_data_48h.csv
    outs:
      - data/processed/features_48h.csv
```

**Step 2: Run Pipeline**
```bash
dvc repro
```

**Step 3: Check Pipeline Status**
```bash
dvc status
dvc dag
```

### Activity 1.4.2: Pipeline Exercises

**Exercise 1: Add a Model Training Stage**

Add to `dvc.yaml`:
```yaml
  train_model:
    cmd: python models/training/train_model.py --features data/processed/features_48h.csv --output models/registry/model.pkl
    deps:
      - models/training/train_model.py
      - data/processed/features_48h.csv
    outs:
      - models/registry/model.pkl
```

**Exercise 2: Add Evaluation Stage**

Add:
```yaml
  evaluate_model:
    cmd: python models/training/evaluate_model.py --model models/registry/model.pkl --features data/processed/features_48h.csv
    deps:
      - models/registry/model.pkl
      - data/processed/features_48h.csv
    outs:
      - models/evaluation/report.json
    metrics:
      - models/evaluation/report.json:
          cache: false
```

### Activity 1.4.3: Pipeline Comparison

**Step 1: Create Different Versions**
```bash
# Generate 168h data
python src/data/generate_sensor_data.py --hours 168 --output data/raw/sensor_data_168h.csv
dvc add data/raw/sensor_data_168h.csv
```

**Step 2: Compare Versions**
```bash
dvc diff data/raw/sensor_data_48h.csv.dvc data/raw/sensor_data_168h.csv.dvc
```

### Activity 1.4.4: Final DVC Exercises

1. Add parameters to `params.yaml` for:
   - Data generation parameters
   - Feature engineering parameters
   - Model training parameters

2. Update `dvc.yaml` to use these parameters

3. Run multiple pipeline versions with different parameters

4. Compare results using `dvc metrics`

---

# PART 2: MLFLOW (EXPERIMENT TRACKING)

## 2.1: Setting Up MLflow Tracking

### Objectives
- Install and configure MLflow
- Set up the tracking server
- Create your first experiment

### Activity 2.1.1: MLflow Installation and Setup

**Step 1: Install MLflow**
```bash
pip install mlflow
```

**Step 2: Verify Installation**
```bash
mlflow --version
```

**Step 3: Create MLflow Directory**
```bash
mkdir -p mlruns
mkdir -p mlflow_artifacts
```

**Step 4: Start MLflow UI**
```bash
mlflow ui --backend-store-uri ./mlruns
```

**Step 5: Open Browser**
- Navigate to http://localhost:5000
- You should see the MLflow UI

### Activity 2.1.2: Your First MLflow Experiment

**Step 1: Create Experiment Script**

Create `scripts/first_experiment.py`:

```python
import mlflow
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score

# Set tracking URI
mlflow.set_tracking_uri("file:./mlruns")

# Set experiment
mlflow.set_experiment("First_Experiment")

# Start run
with mlflow.start_run():
    # Generate dummy data
    X = np.random.rand(1000, 10)
    y = np.random.randint(0, 2, 1000)
    
    # Log parameters
    mlflow.log_param("n_estimators", 100)
    mlflow.log_param("max_depth", 10)
    mlflow.log_param("random_state", 42)
    
    # Train model
    model = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42)
    model.fit(X, y)
    
    # Make predictions
    y_pred = model.predict(X)
    
    # Log metrics
    mlflow.log_metric("accuracy", accuracy_score(y, y_pred))
    mlflow.log_metric("f1", f1_score(y, y_pred))
    
    # Log model
    mlflow.sklearn.log_model(model, "model")
    
    print("Experiment logged successfully!")
```

**Step 2: Run Experiment**
```bash
python scripts/first_experiment.py
```

**Step 3: Check MLflow UI**
- Refresh http://localhost:5000
- Find your experiment and run

### Activity 2.1.3: Exercise

1. Create a second experiment with different parameters
2. Compare the two experiments in the UI
3. Export experiment data to CSV

---

## 2.2: Logging Runs, Parameters, and Metrics

### Objectives
- Log comprehensive experiment details
- Track training progress
- Store artifacts

### Activity 2.2.1: Comprehensive Logging

**Step 1: Create Full Experiment Script**

Create `scripts/full_experiment.py`:

```python
import mlflow
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
import matplotlib.pyplot as plt

# Set tracking URI
mlflow.set_tracking_uri("file:./mlruns")

# Create experiment
mlflow.set_experiment("Full_Experiment")

def log_experiment():
    with mlflow.start_run():
        # Generate data
        np.random.seed(42)
        X = np.random.rand(1000, 20)
        y = np.random.randint(0, 2, 1000)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Log dataset info
        mlflow.log_param("train_samples", len(X_train))
        mlflow.log_param("test_samples", len(X_test))
        mlflow.log_param("features", X.shape[1])
        
        # Log DataFrame as artifact
        df = pd.DataFrame(X, columns=[f"feature_{i}" for i in range(X.shape[1])])
        df['label'] = y
        df.to_csv("data.csv")
        mlflow.log_artifact("data.csv")
        
        # Hyperparameter grid
        params = {
            'n_estimators': 100,
            'max_depth': 10,
            'min_samples_split': 2,
            'min_samples_leaf': 1,
            'random_state': 42
        }
        
        # Log parameters
        for key, value in params.items():
            mlflow.log_param(key, value)
        
        # Train model
        model = RandomForestClassifier(**params)
        model.fit(X_train, y_train)
        
        # Predict
        y_pred = model.predict(X_test)
        y_pred_proba = model.predict_proba(X_test)[:, 1]
        
        # Log metrics
        metrics = {
            'accuracy': accuracy_score(y_test, y_pred),
            'precision': precision_score(y_test, y_pred),
            'recall': recall_score(y_test, y_pred),
            'f1': f1_score(y_test, y_pred),
            'roc_auc': roc_auc_score(y_test, y_pred_proba)
        }
        
        for key, value in metrics.items():
            mlflow.log_metric(key, value)
        
        # Log feature importance
        importances = model.feature_importances_
        features = [f"feature_{i}" for i in range(len(importances))]
        
        # Create feature importance plot
        plt.figure(figsize=(10, 6))
        plt.barh(features[:10], importances[:10])
        plt.title("Feature Importances")
        plt.tight_layout()
        plt.savefig("feature_importance.png")
        mlflow.log_artifact("feature_importance.png")
        plt.close()
        
        # Log feature importance as JSON
        importance_dict = dict(zip(features, importances))
        import json
        with open("feature_importance.json", "w") as f:
            json.dump(importance_dict, f, indent=2)
        mlflow.log_artifact("feature_importance.json")
        
        # Log model
        mlflow.sklearn.log_model(
            model,
            "model",
            registered_model_name="full_experiment_model"
        )
        
        print("Experiment completed!")

if __name__ == "__main__":
    log_experiment()
```

**Step 2: Run and Check UI**
```bash
python scripts/full_experiment.py
```

### Activity 2.2.2: Exercise

1. Add a confusion matrix plot to the experiment
2. Log it as an artifact
3. Add a classification report as text
4. Run 3 experiments with different parameters

---

## 2.3: Visualizing Experiments and Comparing Runs

### Objectives
- Use MLflow UI for visualization
- Compare runs effectively
- Identify best performing models

### Activity 2.3.1: Experiment Comparison

**Step 1: Run Multiple Experiments**

Create `scripts/run_multiple.py`:

```python
import mlflow
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score
from sklearn.model_selection import train_test_split

mlflow.set_tracking_uri("file:./mlruns")

# Generate data
np.random.seed(42)
X = np.random.rand(1000, 20)
y = np.random.randint(0, 2, 1000)

for n_estimators in [50, 100, 200, 500]:
    for max_depth in [5, 10, 15]:
        for min_samples_split in [2, 5, 10]:
            with mlflow.start_run():
                params = {
                    'n_estimators': n_estimators,
                    'max_depth': max_depth,
                    'min_samples_split': min_samples_split,
                    'random_state': 42
                }
                
                mlflow.log_params(params)
                
                model = RandomForestClassifier(**params)
                model.fit(X, y)
                
                y_pred = model.predict(X)
                f1 = f1_score(y, y_pred)
                
                mlflow.log_metric("f1", f1)
                mlflow.log_metric("train_samples", len(X))
```

**Step 2: Run Experiments**
```bash
python scripts/run_multiple.py
```

**Step 3: Compare in UI**
1. Go to MLflow UI
2. Select all runs
3. Click "Compare"
4. View:
   - Parallel coordinates
   - Scatter plots
   - Parameter importance

### Activity 2.3.2: Exercise

1. Find the best performing combination
2. Export the comparison data
3. Create a visualization in Python

---

## 2.4: Implementing the Model Registry

### Objectives
- Register models in the registry
- Manage model stages
- Promote models to production

### Activity 2.4.1: Model Registration

**Step 1: Register Best Model**

Create `scripts/register_model.py`:

```python
import mlflow
from mlflow.tracking import MlflowClient
import json

mlflow.set_tracking_uri("file:./mlruns")
client = MlflowClient()

def register_best_model():
    # Search runs
    runs = mlflow.search_runs(
        experiment_ids=["0"],
        filter_string="metrics.f1 > 0.9",
        order_by=["metrics.f1 DESC"],
        max_results=1
    )
    
    if runs.empty:
        print("No runs with f1 > 0.9")
        return
    
    best_run = runs.iloc[0]
    run_id = best_run['run_id']
    f1_score = best_run['metrics.f1']
    
    print(f"Best run: {run_id} with f1: {f1_score:.4f}")
    
    # Register model
    model_version = client.create_model_version(
        name="best_model",
        source=f"runs:/{run_id}/model",
        run_id=run_id,
        description=f"Model with f1: {f1_score:.4f}"
    )
    
    print(f"Registered as version {model_version.version}")
    
    # Transition to staging
    client.transition_model_version_stage(
        name="best_model",
        version=model_version.version,
        stage="Staging"
    )
    
    print(f"Model transitioned to Staging")

if __name__ == "__main__":
    register_best_model()
```

**Step 2: Run and Check Registry**
```bash
python scripts/register_model.py
```

### Activity 2.4.2: Model Promotion

**Step 1: Create Promotion Script**

Create `scripts/promote_model.py`:

```python
import mlflow
from mlflow.tracking import MlflowClient

mlflow.set_tracking_uri("file:./mlruns")
client = MlflowClient()

def promote_model(model_name, version, stage):
    client.transition_model_version_stage(
        name=model_name,
        version=version,
        stage=stage,
        archive_existing_versions=True
    )
    
    print(f"Model {model_name} version {version} promoted to {stage}")

if __name__ == "__main__":
    # Get latest version in staging
    versions = client.get_latest_versions("best_model", stages=["Staging"])
    
    if versions:
        version = versions[0].version
        promote_model("best_model", version, "Production")
    else:
        print("No model in Staging")
```

**Step 2: Run Promotion**
```bash
python scripts/promote_model.py
```

### Activity 2.4.3: Exercise

1. Register two more models
2. Stage one of them
3. Promote to Production
4. Archive old production model

---

# PART 3: DAGSTER (PIPELINE ORCHESTRATION)

## 3.1: Dagster Architecture and Setup

### Objectives
- Install and configure Dagster
- Understand Dagster concepts
- Create your first pipeline

### Activity 3.1.1: Dagster Setup

**Step 1: Install Dagster**
```bash
pip install dagster dagster-webserver
```

**Step 2: Create Workspace**

Create `workspace.yaml`:
```yaml
load_from:
  - python_module:
      module_name: pipelines
      attribute: defs
```

**Step 3: Initialize Dagster Home**
```bash
export DAGSTER_HOME=$(pwd)/dagster_home
mkdir -p $DAGSTER_HOME
```

### Activity 3.1.2: Your First Pipeline

**Step 1: Create Pipeline File**

Create `pipelines/__init__.py`:

```python
from dagster import Definitions, op, job

@op
def say_hello():
    return "Hello"

@op
def say_world():
    return "World!"

@op
def combine(a, b):
    return f"{a} {b}"

@job
def hello_world_job():
    hello = say_hello()
    world = say_world()
    combine(hello, world)

defs = Definitions(jobs=[hello_world_job])
```

**Step 2: Run the Pipeline**
```bash
dagster job execute -f pipelines/__init__.py -j hello_world_job
```

**Step 3: Start UI**
```bash
dagster-webserver -f pipelines/__init__.py
```

### Activity 3.1.3: Exercise

1. Add a new op that does a calculation
2. Add it to the pipeline
3. Run and verify

---

## 3.2: Building Your First DAG

### Objectives
- Build multi-step pipelines
- Handle dependencies
- Use resources

### Activity 3.2.1: Data Processing Pipeline

Create `pipelines/data_pipeline.py`:

```python
from dagster import op, job, In, Out, OpExecutionContext
import pandas as pd
import numpy as np

@op
def generate_data():
    """Generate synthetic data."""
    return pd.DataFrame({
        'feature1': np.random.rand(100),
        'feature2': np.random.rand(100),
        'feature3': np.random.rand(100)
    })

@op
def clean_data(data: pd.DataFrame):
    """Clean the data."""
    data = data.fillna(0)
    data = data.drop_duplicates()
    return data

@op
def normalize_data(data: pd.DataFrame):
    """Normalize the data."""
    return (data - data.mean()) / data.std()

@op
def split_data(data: pd.DataFrame):
    """Split into train and test."""
    train = data.iloc[:80]
    test = data.iloc[80:]
    return train, test

@op
def train_model(train_data: pd.DataFrame):
    """Train a model."""
    from sklearn.ensemble import RandomForestRegressor
    model = RandomForestRegressor(n_estimators=100)
    X = train_data
    y = np.random.rand(len(train_data))
    model.fit(X, y)
    return model

@job
def data_pipeline():
    data = generate_data()
    cleaned = clean_data(data)
    normalized = normalize_data(cleaned)
    train, test = split_data(normalized)
    model = train_model(train)
    return model
```

### Activity 3.2.2: Run and Visualize

```bash
# Run pipeline
dagster job execute -f pipelines/data_pipeline.py -j data_pipeline

# View in UI
dagster-webserver -f pipelines/data_pipeline.py
```

### Activity 3.2.3: Exercise

1. Add an evaluation op
2. Add it to the pipeline
3. Visualize the full pipeline

---

## 3.3: Sensors, Schedules, and Error Handling

### Objectives
- Automate pipeline execution
- Use sensors and schedules
- Handle errors gracefully

### Activity 3.3.1: Schedules

Create `pipelines/schedules.py`:

```python
from dagster import schedule, job, op
from datetime import datetime

@op
def current_time():
    return datetime.now().isoformat()

@job
def time_job():
    current_time()

@schedule(
    job=time_job,
    cron_schedule="*/5 * * * *",  # Every 5 minutes
    execution_timezone="UTC"
)
def every_5_minutes(context):
    return {}

@schedule(
    job=time_job,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def daily_midnight(context):
    return {}
```

### Activity 3.3.2: Sensors

Create `pipelines/sensors.py`:

```python
from dagster import sensor, RunRequest, SkipReason, SensorExecutionContext
from pathlib import Path
import hashlib

@sensor(job=time_job)
def file_sensor(context: SensorExecutionContext):
    file_path = Path("data/trigger.txt")
    
    if not file_path.exists():
        return SkipReason("Trigger file not found")
    
    # Get file hash
    with open(file_path, 'rb') as f:
        current_hash = hashlib.md5(f.read()).hexdigest()
    
    # Check cursor
    if context.cursor and context.cursor == current_hash:
        return SkipReason("File unchanged")
    
    # Trigger run
    context.update_cursor(current_hash)
    return RunRequest(
        run_key=f"file_{current_hash[:8]}",
        tags={"trigger": "file_sensor"}
    )
```

### Activity 3.3.3: Error Handling

Create `pipelines/error_handling.py`:

```python
from dagster import op, job, RetryPolicy, Failure, OpExecutionContext
import random

@op(
    retry_policy=RetryPolicy(
        max_retries=3,
        delay=5,
        backoff=2
    )
)
def unreliable_op(context: OpExecutionContext):
    attempt = context.op_retry_count + 1
    context.log.info(f"Attempt {attempt}")
    
    if random.random() < 0.5:
        raise Failure("Random failure - will retry")
    
    return "Success!"

@op
def always_fails(context: OpExecutionContext):
    context.log.error("This always fails")
    raise Failure("Permanent failure")

@op
def fallback_op(context: OpExecutionContext):
    context.log.info("Using fallback")
    return "Fallback result"

@job
def error_handling_job():
    try:
        result = unreliable_op()
    except:
        result = fallback_op()
    return result
```

### Activity 3.3.4: Exercise

1. Create a schedule that runs your ML pipeline daily
2. Create a sensor that triggers on new data
3. Add retry policies to your pipeline

---

## 3.4: Integrating DVC and MLflow

### Objectives
- Integrate DVC with Dagster
- Integrate MLflow with Dagster
- Build a complete pipeline

### Activity 3.4.1: DVC Integration

Create `pipelines/dvc_integration.py`:

```python
from dagster import op, job, resource, OpExecutionContext
import subprocess
import dvc.api

@resource
def dvc_resource():
    class DVCClient:
        def pull(self):
            subprocess.run(['dvc', 'pull'], check=True)
        
        def repro(self):
            subprocess.run(['dvc', 'repro'], check=True)
        
        def push(self):
            subprocess.run(['dvc', 'push'], check=True)
        
        def get_data_version(self, path):
            with dvc.api.open(path) as f:
                import hashlib
                return hashlib.md5(f.read()).hexdigest()
    
    return DVCClient()

@op(required_resource_keys={"dvc"})
def pull_data(context: OpExecutionContext):
    context.resources.dvc.pull()
    return "Data pulled"

@op(required_resource_keys={"dvc"})
def run_pipeline(context: OpExecutionContext):
    context.resources.dvc.repro()
    return "Pipeline run"

@job(resource_defs={"dvc": dvc_resource})
def dvc_pipeline():
    pull = pull_data()
    run = run_pipeline()
    return run
```

### Activity 3.4.2: MLflow Integration

Create `pipelines/mlflow_integration.py`:

```python
from dagster import op, job, resource, OpExecutionContext
import mlflow
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score

@resource
def mlflow_resource():
    mlflow.set_tracking_uri("./mlruns")
    return mlflow

@op(required_resource_keys={"mlflow"})
def train_with_mlflow(context: OpExecutionContext):
    mlflow = context.resources.mlflow
    
    with mlflow.start_run():
        # Generate data
        X = np.random.rand(1000, 10)
        y = np.random.randint(0, 2, 1000)
        
        # Log parameters
        mlflow.log_param("n_estimators", 100)
        mlflow.log_param("max_depth", 10)
        
        # Train model
        model = RandomForestClassifier(n_estimators=100, max_depth=10)
        model.fit(X, y)
        
        # Log metrics
        y_pred = model.predict(X)
        mlflow.log_metric("f1", f1_score(y, y_pred))
        
        # Log model
        mlflow.sklearn.log_model(model, "model")
        
        return {"run_id": mlflow.active_run().info.run_id}

@job(resource_defs={"mlflow": mlflow_resource})
def mlflow_pipeline():
    train_with_mlflow()
```

### Activity 3.4.3: Complete Integration

Create `pipelines/complete_pipeline.py`:

```python
from dagster import op, job, resource, In, Out, OpExecutionContext
import mlflow
import subprocess

@resource
def mlflow_resource():
    mlflow.set_tracking_uri("./mlruns")
    return mlflow

@resource
def dvc_resource():
    class DVCClient:
        def get_version(self, path):
            import dvc.api
            with dvc.api.open(path) as f:
                import hashlib
                return hashlib.md5(f.read()).hexdigest()
    return DVCClient()

@op(required_resource_keys={"dvc", "mlflow"})
def integrated_op(context: OpExecutionContext):
    dvc = context.resources.dvc
    mlflow = context.resources.mlflow
    
    with mlflow.start_run():
        # Get data version
        data_version = dvc.get_version("data/raw/sensor_data.csv")
        mlflow.log_param("data_version", data_version)
        
        # Simulate training
        import numpy as np
        X = np.random.rand(1000, 10)
        y = np.random.randint(0, 2, 1000)
        
        from sklearn.ensemble import RandomForestClassifier
        model = RandomForestClassifier(n_estimators=100)
        model.fit(X, y)
        
        # Log metrics
        from sklearn.metrics import f1_score
        y_pred = model.predict(X)
        mlflow.log_metric("f1", f1_score(y, y_pred))
        
        # Log model
        mlflow.sklearn.log_model(model, "model")
        
        return {"data_version": data_version}

@job(resource_defs={"dvc": dvc_resource, "mlflow": mlflow_resource})
def complete_pipeline():
    integrated_op()
```

---

# PART 4: INTEGRATION AND DEPLOYMENT

## 4.1: End-to-End Pipeline Assembly

### Objectives
- Assemble all components
- Build final pipeline
- Test end-to-end

### Activity 4.1.1: Master Pipeline Configuration

Create `configs/master_config.yaml`:

```yaml
pipeline:
  name: "Master MLOps Pipeline"
  version: "1.0.0"

data:
  raw_path: "data/raw/sensor_data.csv"
  processed_path: "data/processed/features.csv"
  validation:
    schema: "configs/schema.json"
    quality_checks: ["no_missing", "no_duplicates"]

features:
  windows: [5, 10, 30]
  interaction_features: true

model:
  algorithm: "random_forest"
  parameters:
    n_estimators: 100
    max_depth: 10
    random_state: 42
  test_size: 0.2
  cv_folds: 5

mlflow:
  experiment_name: "Master_Pipeline"
  tracking_uri: "./mlruns"

registry:
  model_name: "master_model"
  promotion_criteria:
    min_f1: 0.85

deployment:
  type: "api"
  port: 8000
  endpoint: "/predict"
```

### Activity 4.1.2: Complete Pipeline

Create `pipelines/master_pipeline.py` (summary - see part 13 for full code):

```python
from dagster import op, job, In, Out, resource
import pandas as pd
import mlflow
import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score

# Define all operations
@op
def load_data() -> pd.DataFrame:
    # Load data
    pass

@op
def preprocess_data(data: pd.DataFrame) -> pd.DataFrame:
    # Preprocess
    pass

@op
def train_model(data: pd.DataFrame):
    # Train model
    pass

@op
def register_model(model):
    # Register in MLflow
    pass

@op
def deploy_model(model):
    # Deploy API
    pass

@job
def master_pipeline():
    data = load_data()
    processed = preprocess_data(data)
    model = train_model(processed)
    registered = register_model(model)
    deployed = deploy_model(registered)
    return deployed
```

### Activity 4.1.3: Exercise

1. Fill in all the operations
2. Add error handling
3. Add retry policies
4. Test the complete pipeline

---

## 4.2: Monitoring and Alerting

### Objectives
- Set up monitoring
- Configure alerts
- Create dashboards

### Activity 4.2.1: Monitoring Setup

Create `src/monitoring/monitor.py`:

```python
import json
from datetime import datetime
from pathlib import Path

class Monitor:
    def __init__(self):
        self.metrics = []
        self.alerts = []
    
    def add_metric(self, name, value, tags=None):
        metric = {
            'name': name,
            'value': value,
            'timestamp': datetime.now().isoformat(),
            'tags': tags or {}
        }
        self.metrics.append(metric)
        return metric
    
    def add_alert(self, title, message, severity='warning'):
        alert = {
            'title': title,
            'message': message,
            'severity': severity,
            'timestamp': datetime.now().isoformat()
        }
        self.alerts.append(alert)
        return alert
    
    def check_thresholds(self, metric_name, value, threshold):
        if value > threshold:
            return self.add_alert(
                f"High {metric_name}",
                f"Value {value} exceeds {threshold}",
                'error'
            )
        return None

    def save(self):
        with open('logs/monitoring.json', 'w') as f:
            json.dump({
                'metrics': self.metrics,
                'alerts': self.alerts
            }, f, indent=2)
```

### Activity 4.2.2: Alerting Configuration

Create `configs/alerts.yaml`:

```yaml
alerts:
  - metric: "accuracy"
    threshold: 0.80
    severity: "warning"
    action: "slack"
  
  - metric: "latency_ms"
    threshold: 100
    severity: "error"
    action: "pagerduty"
  
  - metric: "error_rate"
    threshold: 0.05
    severity: "error"
    action: "email"
  
  - metric: "drift_score"
    threshold: 0.3
    severity: "warning"
    action: "slack"
```

### Activity 4.2.3: Exercise

1. Create a monitoring pipeline in Dagster
2. Add system metrics collection
3. Configure email alerts
4. Test the alerting system

---

## 4.3: Continuous Deployment Strategies

### Objectives
- Implement blue-green deployment
- Set up CI/CD pipeline
- Create deployment automation

### Activity 4.3.1: GitHub Actions Setup

Create `.github/workflows/mlops_ci_cd.yaml`:

```yaml
name: MLOps CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      - name: Run tests
        run: |
          pytest tests/

  train:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Pull data
        run: dvc pull
      - name: Train model
        run: python models/training/train.py

  deploy:
    runs-on: ubuntu-latest
    needs: train
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - uses: actions/checkout@v3
      - name: Deploy
        run: |
          python scripts/deploy.py
```

### Activity 4.3.2: Blue-Green Deployment

Create `scripts/blue_green.py`:

```python
#!/usr/bin/env python
import json
from pathlib import Path
import shutil
import subprocess

class BlueGreenDeploy:
    def __init__(self, base_path="./deployment"):
        self.base_path = Path(base_path)
        self.blue_path = self.base_path / "blue"
        self.green_path = self.base_path / "green"
        self.active_file = self.base_path / "active.txt"
        
        self.blue_path.mkdir(parents=True, exist_ok=True)
        self.green_path.mkdir(parents=True, exist_ok=True)
    
    def get_active(self):
        if self.active_file.exists():
            with open(self.active_file, 'r') as f:
                return f.read().strip()
        return 'blue'
    
    def deploy_to_green(self, model_path):
        # Clear green
        shutil.rmtree(self.green_path)
        self.green_path.mkdir()
        
        # Copy model
        shutil.copy2(model_path, self.green_path / "model.pkl")
        
        # Start service
        with open(self.green_path / "service.log", 'w') as f:
            subprocess.Popen(
                ["python", "-m", "uvicorn", "app:app", "--port", "8001"],
                stdout=f,
                stderr=f
            )
    
    def switch(self):
        active = self.get_active()
        new_active = 'green' if active == 'blue' else 'blue'
        
        # Test new environment
        result = subprocess.run(
            ["curl", "-f", "http://localhost:8001/health"],
            capture_output=True
        )
        
        if result.returncode != 0:
            raise Exception("New environment failed health check")
        
        # Switch
        with open(self.active_file, 'w') as f:
            f.write(new_active)
        
        return new_active

if __name__ == "__main__":
    deployer = BlueGreenDeploy()
    deployer.deploy_to_green("models/registry/model.pkl")
    active = deployer.switch()
    print(f"Active: {active}")
```

### Activity 4.3.3: Exercise

1. Create a deployment pipeline
2. Implement canary deployment
3. Add rollback capability
4. Test full deployment flow

---

# PART 5: FINAL PROJECT - CAPSTONE

## 5.1: Design Document

### Project Requirements

**Overview:**
Build a complete MLOps pipeline for a predictive maintenance system that:
1. Versions data with DVC
2. Tracks experiments with MLflow
3. Orchestrates with Dagster
4. Deploys to production
5. Monitors performance

**Technical Requirements:**
- Use synthetic sensor data
- Train classification model
- Implement model registry
- Create REST API
- Add monitoring
- Configure CI/CD

**Deliverables:**
- Complete working pipeline
- Documentation
- Test results
- Deployment evidence

### Activity 5.1.1: Project Planning

**Use Case Description:**
[Write 2-3 paragraphs describing your system]

**Architecture Diagram:**
[Drawing/Description of your architecture]

**Technology Stack:**
| Component | Tool | Justification |
|-----------|------|---------------|
| Data Versioning | DVC | |
| Experiment Tracking | MLflow | |
| Orchestration | Dagster | |
| Deployment | Docker/K8s | |
| Monitoring | Prometheus/Grafana | |

**Data Flow:**
[Diagram of data flow through your system]

**Success Criteria:**
1. [ ] Data versioned and tracked
2. [ ] Experiments logged and compared
3. [ ] Pipeline runs automatically
4. [ ] Model registered and staged
5. [ ] API deployed and tested
6. [ ] Monitoring configured
7. [ ] CI/CD working

### Activity 5.1.2: Timeline

| Week | Milestone | Deliverable | Status |
|------|-----------|-------------|--------|
| 1 | Setup | Environment + DVC | ☐ |
| 2 | Data | Data pipeline + versioning | ☐ |
| 3 | Experiments | MLflow + registry | ☐ |
| 4 | Orchestration | Dagster pipeline | ☐ |
| 5 | Integration | Complete system | ☐ |
| 6 | Deployment | Production deploy | ☐ |
| 7 | Monitoring | Dashboard + alerts | ☐ |

---

## 5.2: Implementation Plan

### Activity 5.2.1: Phase 1 - Data Pipeline

**Objectives:**
- Set up DVC
- Create data generation
- Version raw data
- Build feature pipeline

**Step-by-Step:**

1. Initialize DVC
2. Create synthetic data generator
3. Version raw data
4. Create feature engineering
5. Version processed data
6. Test with `dvc repro`

**Verification:**
- [ ] DVC initialized
- [ ] Raw data generated and versioned
- [ ] Features built and versioned
- [ ] Pipeline runs successfully

### Activity 5.2.2: Phase 2 - Experiment Tracking

**Objectives:**
- Set up MLflow
- Log experiments
- Compare results
- Register models

**Step-by-Step:**

1. Install MLflow
2. Create experiment script
3. Log parameters/metrics
4. Store artifacts
5. Register best model

**Verification:**
- [ ] MLflow server running
- [ ] Experiments logged
- [ ] Parameters/metrics tracked
- [ ] Model registered

### Activity 5.2.3: Phase 3 - Pipeline Orchestration

**Objectives:**
- Set up Dagster
- Build pipeline
- Add schedules
- Integrate DVC/MLflow

**Step-by-Step:**

1. Install Dagster
2. Define operations
3. Create assets
4. Add schedules/sensors
5. Integrate DVC
6. Integrate MLflow

**Verification:**
- [ ] Pipeline runs
- [ ] Schedules work
- [ ] DVC integration works
- [ ] MLflow integration works

### Activity 5.2.4: Phase 4 - Deployment

**Objectives:**
- Create API
- Deploy model
- Set up CI/CD
- Monitor system

**Step-by-Step:**

1. Create FastAPI app
2. Package with Docker
3. Deploy to staging
4. Test deployment
5. Deploy to production
6. Add monitoring
7. Configure alerts

**Verification:**
- [ ] API responds
- [ ] Docker image builds
- [ ] CI/CD works
- [ ] Monitoring works

---

## 5.3: Deliverables

### Activity 5.3.1: Code Deliverables

**Required Files:**

```
final_project/
├── data/
│   ├── raw/                   # Versioned raw data
│   └── processed/             # Versioned processed data
├── models/
│   ├── registry/              # Registered models
│   └── training/              # Training scripts
├── pipelines/                 # Dagster pipelines
├── src/
│   ├── data/                  # Data processing
│   ├── features/              # Feature engineering
│   └── utils/                 # Utilities
├── scripts/                   # Automation scripts
├── configs/                   # Configuration files
├── tests/                     # Tests
├── dvc.yaml                   # DVC pipeline
├── .github/workflows/         # CI/CD
├── README.md                  # Documentation
└── requirements.txt           # Dependencies
```

### Activity 5.3.2: Documentation Deliverables

**Required Documentation:**

1. **README.md**
   - Project overview
   - Setup instructions
   - Usage guide
   - Architecture diagram

2. **API Documentation**
   - Endpoints
   - Request/response formats
   - Examples

3. **Deployment Guide**
   - Steps to deploy
   - Configuration
   - Testing

4. **User Guide**
   - How to use the system
   - Common operations
   - Troubleshooting

5. **Developer Guide**
   - Code structure
   - Adding new features
   - Testing guide

### Activity 5.3.3: Testing Deliverables

**Test Coverage Required:**

| Test Type | Description | Status |
|-----------|-------------|--------|
| Unit Tests | Individual components | ☐ |
| Integration Tests | Component interactions | ☐ |
| End-to-End Tests | Full pipeline | ☐ |
| Performance Tests | Speed/throughput | ☐ |
| Security Tests | Vulnerabilities | ☐ |
| Load Tests | Scalability | ☐ |

**Sample Tests:**

```python
# test_data_pipeline.py
def test_data_generation():
    df = generate_data()
    assert len(df) > 0
    assert 'label' in df.columns

# test_model.py
def test_model_training():
    model = train_model(X_train, y_train)
    assert model is not None
    assert hasattr(model, 'predict')

# test_api.py
def test_prediction_endpoint():
    response = client.post("/predict", json={"features": [...]})
    assert response.status_code == 200
    assert "prediction" in response.json()

# test_pipeline.py
def test_full_pipeline():
    result = execute_job(complete_pipeline)
    assert result.success
```

---

## 5.4: Evaluation Rubric

### Activity 5.4.1: Self-Assessment Rubric

| Category | Weight | Excellent (4) | Good (3) | Satisfactory (2) | Needs Work (1) | Score |
|----------|--------|---------------|----------|------------------|----------------|-------|
| **Data Versioning** | 15% | | | | | |
| - DVC setup | | All features | Most features | Basic setup | Missing | |
| - Data tracking | | Complete | Partial | Minimal | None | |
| - Pipeline | | Automated | Semi-auto | Manual | Not working | |
| **Experiment Tracking** | 15% | | | | | |
| - MLflow setup | | Production ready | Complete | Basic | Missing | |
| - Experiment logging | | Comprehensive | Complete | Partial | Minimal | |
| - Registry | | Full lifecycle | Staging | Basic | None | |
| **Pipeline Orchestration** | 20% | | | | | |
| - Dagster setup | | Production ready | Complete | Basic | Missing | |
| - Pipeline design | | Optimal | Good | Basic | Poor | |
| - Automation | | Full automation | Partial | Manual | None | |
| **Deployment** | 20% | | | | | |
| - API | | Production ready | Complete | Basic | Missing | |
| - CI/CD | | Full pipeline | Partial | Basic | None | |
| - Monitoring | | Comprehensive | Complete | Basic | None | |
| **Documentation** | 15% | | | | | |
| - README | | Comprehensive | Complete | Basic | Missing | |
| - Code docs | | Full | Good | Partial | Minimal | |
| - Runbooks | | Complete | Partial | Basic | Missing | |
| **Code Quality** | 15% | | | | | |
| - Structure | | Excellent | Good | Acceptable | Poor | |
| - Testing | | Comprehensive | Good | Basic | None | |
| - Style | | Consistent | Good | Acceptable | Poor | |
| **Total** | 100% | | | | | |

### Activity 5.4.2: Peer Review Checklist

**For Each Peer:**

1. Is the system functional? ☐
2. Is data properly versioned? ☐
3. Are experiments tracked? ☐
4. Does orchestration work? ☐
5. Is deployment automated? ☐
6. Is monitoring configured? ☐
7. Is documentation complete? ☐
8. Are tests comprehensive? ☐
9. Is code well-structured? ☐
10. Is security considered? ☐

**Strengths:**
1. ________________________________
2. ________________________________
3. ________________________________

**Areas for Improvement:**
1. ________________________________
2. ________________________________
3. ________________________________

**Overall Score:** _____ / 40

---

## Final Project Submission Checklist

### Required Deliverables

- [ ] **Code Repository**
  - [ ] All code committed
  - [ ] README.md updated
  - [ ] Requirements.txt complete
  - [ ] .gitignore configured

- [ ] **Data Pipeline**
  - [ ] DVC configured
  - [ ] Data versioned
  - [ ] Pipeline automated

- [ ] **Experiment Tracking**
  - [ ] MLflow setup
  - [ ] Experiments logged
  - [ ] Registry populated

- [ ] **Orchestration**
  - [ ] Dagster pipeline
  - [ ] Schedules configured
  - [ ] Error handling

- [ ] **Deployment**
  - [ ] API implemented
  - [ ] CI/CD working
  - [ ] Monitoring active

- [ ] **Documentation**
  - [ ] Setup guide
  - [ ] User guide
  - [ ] API docs

- [ ] **Testing**
  - [ ] Unit tests
  - [ ] Integration tests
  - [ ] End-to-end tests

### Submission Format

1. **GitHub Repository:** [URL]
2. **README.md:** Complete
3. **Video Demo:** 10-15 minutes
4. **Design Document:** PDF/Word
5. **Self-Assessment:** Completed

---

**End of Student Workbook**

---

## Answer Key for Self-Check Exercises

### Activity 1.1.1 - DVC Initialization
```bash
# Expected output
dvc init
# Should show: "Initialized DVC repository."

# Check files
ls .dvc/
# Should show: cache, config, state, tmp
```

### Activity 2.1.1 - MLflow Setup
```python
# Verify installation
import mlflow
print(mlflow.__version__)
# Should print version number

# Test tracking
mlflow.set_tracking_uri("file:./mlruns")
with mlflow.start_run():
    mlflow.log_param("test", "value")
# Should complete without errors
```

### Activity 3.1.1 - Dagster Setup
```bash
# Verify installation
dagster --version
# Should print version

# Test pipeline
dagster job execute -f pipelines/__init__.py -j hello_world_job
# Should show "Hello World!"
```

---

## Additional Resources

### Online Documentation
- DVC: https://dvc.org/doc
- MLflow: https://mlflow.org/docs
- Dagster: https://docs.dagster.io
- FastAPI: https://fastapi.tiangolo.com

### Troubleshooting Common Issues

**Issue: DVC remote connection failed**
```bash
# Check credentials
aws configure list
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

**Issue: MLflow server not starting**
```bash
# Check port
lsof -i :5000
# Kill process or use different port
mlflow ui --port 5001
```

**Issue: Dagster daemon not running**
```bash
# Check status
dagster-daemon run
# Check logs
tail -f dagster_home/logs/*
```

---

**Congratulations on completing the MLOps Pipeline Engineering Workbook!**

Remember: The key to mastering MLOps is practice. Keep iterating, keep learning, and keep building!
