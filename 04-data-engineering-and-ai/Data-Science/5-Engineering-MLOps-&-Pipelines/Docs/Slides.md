# MLOps Pipeline Series: Complete Slide Outline

## Comprehensive Teaching Presentation (300+ Slides)

---

# SECTION 1: INTRODUCTION & FOUNDATIONS (Slides 1-40)

---

## Module 1: Course Overview (Slides 1-15)

### Slide 1: Title Slide
- **Title:** MLOps Pipeline Engineering: From Development to Production
- **Subtitle:** A Comprehensive Guide to Building Production-Grade ML Systems
- **Presenter:** [Your Name]
- **Date:** [Date]

### Slide 2: Course Objectives
- Build end-to-end production ML pipelines
- Master DVC for data versioning
- Implement MLflow for experiment tracking
- Orchestrate with Dagster
- Deploy and monitor in production
- Understand MLOps best practices

### Slide 3: What is MLOps?
- **Definition:** ML + DevOps + Data Engineering
- **Goal:** Bridge the gap between research and production
- **Key Components:**
  - Data versioning
  - Experiment tracking
  - Pipeline orchestration
  - Model deployment
  - Monitoring and alerting

### Slide 4: The MLOps Journey
```
Research → Development → Staging → Production → Monitoring
    ↓           ↓            ↓          ↓           ↓
  Jupyter    Pipelines    Validation  Deployment  Alerts
  Notebooks  (Dagster)    (Testing)   (CI/CD)    (Dashboards)
```

### Slide 5: Why MLOps Matters
- **80%** of ML projects never reach production
- **60%** of models degrade within 6 months
- **70%** of data science time spent on data preparation
- **Goal:** Reduce time to production from months to days

### Slide 6: The Three Pillars
1. **Data Versioning** (DVC)
   - Track datasets
   - Version features
   - Manage models

2. **Experiment Tracking** (MLflow)
   - Log parameters
   - Track metrics
   - Compare runs

3. **Pipeline Orchestration** (Dagster)
   - Automate workflows
   - Handle dependencies
   - Error recovery

### Slide 7: Course Prerequisites
- **Technical:**
  - Python (functions, classes, modules)
  - Git (commits, branches, remotes)
  - Command line (navigating, running scripts)
  - Basic ML concepts (training, validation)

- **Tools to Install:**
  - Python 3.9+
  - Git 2.30+
  - DVC 2.0+
  - MLflow 2.0+
  - Dagster 1.0+

### Slide 8: Course Structure
- **Phase 1:** Data & Artifact Versioning (DVC)
- **Phase 2:** Experiment Tracking (MLflow)
- **Phase 3:** Pipeline Orchestration (Dagster)
- **Phase 4:** Full Integration & Deployment
- **Primers:** Python, DVC, MLflow, Dagster
- **Appendices:** API Reference, Commands

### Slide 9: What You'll Build
- **Complete MLOps System:**
  - Versioned data pipeline
  - Experiment tracking system
  - Model registry
  - Orchestrated workflow
  - Production deployment
  - Monitoring dashboard

### Slide 10: The Use Case
- **Predictive Maintenance**
- **Goal:** Detect equipment anomalies
- **Data:** Sensor readings (temperature, pressure, vibration)
- **Models:** Classification (Normal/Anomaly)
- **Deployment:** REST API + Batch

### Slide 11: Why Predictive Maintenance?
- Real-world problem
- Time-series data (complexity)
- Multiple data sources
- Clear business value
- Production requirements (reliability)

### Slide 12: The Architecture Overview
```
┌─────────────────────────────────────────────────────┐
│           END-TO-END MLOPS ARCHITECTURE            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [Data Source] → DVC → MLflow → Dagster → Deploy   │
│       ↓           ↓        ↓          ↓        ↓   │
│    Raw Data    Version  Track    Orchestrate  Serve │
│                                                     │
│  Monitoring ← Dashboard ← Alerts ← Logging         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Slide 13: Timeline
- **Phase 1:** DVC (4 parts) - 2 weeks
- **Phase 2:** MLflow (4 parts) - 2 weeks
- **Phase 3:** Dagster (4 parts) - 2 weeks
- **Phase 4:** Integration (3 parts) - 1.5 weeks
- **Total:** ~7.5 weeks (with practice)

### Slide 14: Learning Approach
- **Learn by Doing**
  - Copy-paste-ready code
  - Verification steps
  - Real-world examples
  - Troubleshooting guides

- **Progressive Complexity**
  - Start simple
  - Add features incrementally
  - Build to production

### Slide 15: Success Metrics
- ✅ Run full pipeline automatically
- ✅ Track all experiments
- ✅ Version all data
- ✅ Deploy model
- ✅ Monitor performance
- ✅ Handle failures gracefully

---

## Module 2: Core Concepts (Slides 16-40)

### Slide 16: What is Data Versioning?
- **Definition:** Tracking changes to data over time
- **Why:** Reproducibility, rollback, collaboration
- **Challenge:** Large files (>Git limits)

### Slide 17: Git vs. DVC
```
Git                          DVC
───                          ───
Tracks code                  Tracks data
Lightweight files            Large files
Text-based                   Binary files
Fast commits                 Efficient storage
Branching/merging            Versioning
Remote hosting               Cloud storage
```

### Slide 18: DVC Architecture
```
┌─────────────────────────────────────┐
│         DVC Architecture            │
├─────────────────────────────────────┤
│                                     │
│  Git Repository ←→ .dvc Files      │
│       ↓                  ↓          │
│  DVC Cache ←→ Remote Storage       │
│                                     │
└─────────────────────────────────────┘
```

### Slide 19: Experiment Tracking
- **Definition:** Logging ML experiments
- **What to Track:**
  - Parameters (hyperparameters)
  - Metrics (accuracy, F1)
  - Artifacts (models, plots)
  - Code version (Git hash)
  - Environment (dependencies)

### Slide 20: MLflow Components
```
┌─────────────────────────────────────┐
│         MLflow Components           │
├─────────────────────────────────────┤
│                                     │
│  Tracking Server (UI)               │
│  ↓                                  │
│  Experiment → Runs → Metrics        │
│  ↓                                  │
│  Model Registry                     │
│  ↓                                  │
│  Staging → Production → Archived   │
│                                     │
└─────────────────────────────────────┘
```

### Slide 21: Pipeline Orchestration
- **Definition:** Automating workflow execution
- **Why:** Repeatability, error handling, monitoring
- **Concepts:**
  - DAG (Directed Acyclic Graph)
  - Tasks/Operations
  - Dependencies
  - Schedules
  - Sensors

### Slide 22: Dagster Architecture
```
┌─────────────────────────────────────┐
│       Dagster Architecture          │
├─────────────────────────────────────┤
│                                     │
│  User Code (Assets/Ops/Jobs)       │
│  ↓                                  │
│  Execution Engine                   │
│  ↓                                  │
│  Storage Layer (PostgreSQL/S3)     │
│  ↓                                  │
│  UI / API                          │
│                                     │
└─────────────────────────────────────┘
```

### Slide 23: The MLOps Workflow
```
1. Data Ingestion → 2. Validation → 3. Feature Engineering
        ↓                  ↓                  ↓
4. Model Training → 5. Evaluation → 6. Registry
        ↓                  ↓                  ↓
7. Staging → 8. Production → 9. Monitoring
```

### Slide 24: CI/CD for ML
- **Continuous Integration:**
  - Code testing
  - Data validation
  - Model testing

- **Continuous Deployment:**
  - Automated deployment
  - Blue-Green
  - Canary releases

- **Continuous Monitoring:**
  - Performance tracking
  - Drift detection
  - Alerting

### Slide 25: Reproducibility
- **Definition:** Ability to reproduce results exactly
- **Requirements:**
  - Data version
  - Code version
  - Environment
  - Parameters
  - Random seeds
  - Hardware configuration

### Slide 26: Data Quality
- **Dimensions:**
  - Completeness (no missing values)
  - Consistency (valid values)
  - Accuracy (correct values)
  - Timeliness (up-to-date)
  - Relevance (useful features)

### Slide 27: Model Quality
- **Offline Metrics:**
  - Accuracy
  - Precision/Recall
  - F1 Score
  - ROC-AUC
  - MSE/RMSE

- **Online Metrics:**
  - Latency
  - Throughput
  - Error rate
  - Business impact

### Slide 28: The Cost of Poor MLOps
- **Financial:**
  - Wasted compute ($100K+/year)
  - Failed deployments ($50K+ per incident)
  - Reputational damage

- **Time:**
  - 40% time spent on data prep
  - 60% models never deployed
  - 80% effort duplicated

### Slide 29: MLOps Maturity Model
```
Level 0: No MLOps (Jupyter only)
Level 1: Scripting (manual runs)
Level 2: Automation (scheduled runs)
Level 3: CI/CD (automated deployment)
Level 4: Full MLOps (continuous everything)
```

### Slide 30: Team Structure
```
MLOps Team
├── Data Engineer (DVC, data pipelines)
├── ML Engineer (MLflow, model training)
├── DevOps Engineer (Dagster, deployment)
├── Data Scientist (Model development)
└── Product Manager (Requirements, prioritization)
```

### Slide 31: Tool Selection Criteria
- **Evaluate:**
  - Team expertise
  - Infrastructure
  - Cost
  - Scalability
  - Integration
  - Community support
  - Documentation

### Slide 32: Why These Tools?
- **DVC:** Best for data versioning
- **MLflow:** Most complete experiment tracking
- **Dagster:** Modern orchestration (vs. Airflow)
- **All:** Open source, active community, production-ready

### Slide 33: Environment Setup
```
Python 3.9+
Virtual Environment
DVC 2.0+
MLflow 2.0+
Dagster 1.0+
Git 2.30+
AWS CLI / GCloud SDK
```

### Slide 34: Development Environment
- **IDE:** VS Code, PyCharm
- **Extensions:**
  - Python
  - Docker
  - Git
  - YAML
  - JSON
- **Terminal:** Terminal, iTerm2, PowerShell

### Slide 35: Version Control Strategy
```
main
├── develop
│   ├── feature/data-versioning
│   ├── feature/experiment-tracking
│   ├── feature/pipeline-orchestration
│   └── feature/integration
└── release/v1.0
```

### Slide 36: Branch Naming Convention
- `main` - Production
- `develop` - Integration
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Emergency fixes
- `release/*` - Release candidates

### Slide 37: Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>

Types: feat, fix, docs, style, refactor, test, chore
Scope: dvc, mlflow, dagster, config, deployment
```

### Slide 38: Code Review Process
1. Create PR
2. Run CI/CD
3. Team review
4. Address feedback
5. Merge to develop
6. Release to production

### Slide 39: Documentation Standards
- **README.md:** Project overview
- **CONTRIBUTING.md:** Contribution guidelines
- **CHANGELOG.md:** Version history
- **API docs:** Function/class documentation
- **Tutorials:** How-to guides
- **Runbooks:** Operational procedures

### Slide 40: Recap: Foundations
- MLOps: ML + DevOps + Data Engineering
- Three pillars: DVC, MLflow, Dagster
- Real-world use case: Predictive maintenance
- Progressive learning approach
- Production mindset from day one

---

# SECTION 2: DATA VERSIONING WITH DVC (Slides 41-100)

---

## Module 3: DVC Fundamentals (Slides 41-65)

### Slide 41: DVC Introduction
- **What is DVC?**
  - Data Version Control
  - Git for data
  - Open source
  - Python-based

- **Key Features:**
  - Version large files
  - Pipeline management
  - Remote storage
  - Data reproducibility

### Slide 42: Why DVC?
- **Problems Solved:**
  - Large file storage in Git
  - Data reproducibility
  - Team collaboration
  - Pipeline automation

- **Benefits:**
  - Git integration
  - Cloud storage support
  - Language agnostic
  - Free and open source

### Slide 43: How DVC Works
```
1. dvc add file.csv
   ↓
2. File hashed (MD5)
   ↓
3. File stored in .dvc/cache
   ↓
4. Pointer file (.dvc) in Git
   ↓
5. Git tracks pointer, not data
```

### Slide 44: DVC vs. Git LFS
```
DVC                          Git LFS
───                          ──────
Data versioning              Large file storage
Pipeline management          Basic file handling
Remote storage               Git LFS servers
Free                         Paid (over limit)
Open source                  Proprietary
```

### Slide 45: DVC Installation
```bash
# Install via pip
pip install dvc

# Install with cloud support
pip install dvc-s3      # AWS
pip install dvc-gs      # GCS
pip install dvc-azure   # Azure

# Verify installation
dvc --version
```

### Slide 46: DVC Initialization
```bash
# Initialize DVC in existing Git repo
dvc init

# Check files created
ls -la .dvc/
# .dvc/config
# .dvcignore

# Verify
dvc status
```

### Slide 47: Tracking Data Files
```bash
# Add a file
dvc add data/raw/dataset.csv

# What happens:
# 1. dataset.csv → .dvc/cache/
# 2. dataset.csv.dvc created
# 3. dataset.csv becomes symlink to cache

# Commit to Git
git add dataset.csv.dvc .gitignore
git commit -m "Add dataset"
```

### Slide 48: DVC File Structure
```yaml
# dataset.csv.dvc
md5: 8d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a
outs:
- md5: 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d
  path: dataset.csv
  size: 1024000
  hash: md5
  cache: true
  metric: false
  persist: false
wdir: .
```

### Slide 49: DVC Status
```bash
# Check status
dvc status

# Output meanings:
# "up to date" - Everything synchronized
# "changed" - File modified locally
# "deleted" - File removed
# "new" - New file
# "not pushed" - Not in remote
```

### Slide 50: DVC Checkout
```bash
# Restore data from cache
dvc checkout

# Checkout specific file
dvc checkout dataset.csv

# Checkout from specific version
git checkout v1.0
dvc checkout
```

### Slide 51: DVC Push/Pull
```bash
# Push data to remote
dvc push

# Push specific file
dvc push dataset.csv.dvc

# Pull data from remote
dvc pull

# Pull specific file
dvc pull dataset.csv.dvc
```

### Slide 52: DVC Remote Storage
```bash
# Add remote
dvc remote add -d myremote s3://mybucket

# List remotes
dvc remote list

# Remove remote
dvc remote remove myremote

# Modify remote config
dvc remote modify myremote region us-east-1
```

### Slide 53: Remote Types
```
Local     : /path/to/storage
AWS S3    : s3://bucket/path
GCS       : gs://bucket/path
Azure     : azure://container/path
SSH       : ssh://user@host/path
HTTP/HTTPS: https://example.com/path
```

### Slide 54: Configuring S3 Remote
```bash
# Setup AWS credentials
aws configure
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

# Add S3 remote
dvc remote add s3_remote s3://mybucket/dvc-storage
dvc remote default s3_remote

# Configure region
dvc remote modify s3_remote region us-east-1
```

### Slide 55: GCS Remote Configuration
```bash
# Setup GCS
gcloud auth login
export GOOGLE_APPLICATION_CREDENTIALS=key.json

# Add GCS remote
dvc remote add gcs_remote gs://mybucket/dvc-storage
dvc remote default gcs_remote
```

### Slide 56: DVC Cache Management
```bash
# View cache location
dvc cache dir

# Clean cache
dvc gc

# Force clean all
dvc gc --force

# Check cache usage
du -sh .dvc/cache/
```

### Slide 57: DVC Tagging
```bash
# Tag a version
dvc tag data/raw/dataset.csv v1.0.0

# List tags
dvc tag list

# Checkout tagged version
dvc checkout data/raw/dataset.csv --tag v1.0.0

# Tag with message
dvc tag data/raw/dataset.csv v1.0.0 --with-msg "Initial dataset"
```

### Slide 58: Working with Multiple Versions
```bash
# Checkout specific version
git checkout v1.0.0
dvc checkout

# Compare versions
dvc diff data/raw/dataset.csv.dvc v1.0.0 v2.0.0

# Show metrics across versions
dvc metrics diff v1.0.0 v2.0.0
```

### Slide 59: DVC Plots
```bash
# Define plot
dvc plots show

# Create plot
dvc plots show data/processed/features.csv

# Compare plots
dvc plots diff v1.0.0 v2.0.0
```

### Slide 60: DVC Metrics
```bash
# Define metrics
dvc metrics add metrics.json

# Show metrics
dvc metrics show

# Compare metrics
dvc metrics diff v1.0.0 v2.0.0
```

### Slide 61: DVC Parameters
```yaml
# params.yaml
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

### Slide 62: Using Parameters
```bash
# Track parameters
dvc params diff

# Reference in code
import yaml
with open('params.yaml') as f:
    params = yaml.safe_load(f)
```

### Slide 63: DVC Lock File
```yaml
# dvc.lock
schema: '2.0'
stages:
  generate_data:
    cmd: python generate.py
    deps:
    - path: generate.py
      md5: abc123...
    outs:
    - path: data/raw/data.csv
      md5: def456...
```

### Slide 64: DVC Pipeline Visualization
```bash
# Show pipeline graph
dvc dag

# Output:
# +----------------+      
# | generate_data  |      
# +----------------+      
#         *            
#         *            
# +----------------+      
# | process_data   |      
# +----------------+      
#         *            
#         *            
# +----------------+      
# | train_model    |      
# +----------------+      
```

### Slide 65: DVC Best Practices
- Version raw data (immutable)
- Track processed data
- Use meaningful tags
- Push to remote regularly
- Clean cache periodically
- Document data versions
- Use parameters for config
- Keep pipeline simple

---

## Module 4: Advanced DVC (Slides 66-85)

### Slide 66: DVC Pipelines
- **What:** Reproducible data pipelines
- **Why:** Automation, consistency, tracking
- **Components:**
  - Stages (processing steps)
  - Dependencies (inputs)
  - Outputs (artifacts)
  - Commands (execution)

### Slide 67: Pipeline Definition
```yaml
# dvc.yaml
stages:
  process:
    cmd: python process.py data/raw/ output/processed/
    deps:
    - data/raw/
    - process.py
    outs:
    - output/processed/
    params:
    - params.yaml#process
```

### Slide 68: Running Pipelines
```bash
# Run pipeline
dvc repro

# Run specific stage
dvc repro process

# Force run
dvc repro --force

# Dry run
dvc repro --dry

# Single item
dvc repro --single-item process
```

### Slide 69: Pipeline Dependencies
```yaml
stages:
  stage1:
    cmd: python script1.py
    deps:
    - input.csv
    - script1.py
    outs:
    - output1.csv
  
  stage2:
    cmd: python script2.py
    deps:
    - output1.csv  # Depends on stage1
    - script2.py
    outs:
    - final.csv
```

### Slide 70: Conditional Execution
- DVC only runs changed stages
- Detects changes via hashing
- Excludes unchanged stages
- Saves time and resources

### Slide 71: External Dependencies
```yaml
stages:
  download:
    cmd: python download.py
    deps:
    - https://example.com/data.zip  # External URL
    - download.py
    outs:
    - data/raw/data.csv
```

### Slide 72: Pipelines with Multiple Outputs
```yaml
stages:
  split:
    cmd: python split.py
    deps:
    - data.csv
    outs:
    - train.csv
    - test.csv
    - val.csv
```

### Slide 73: Pipeline Parameters
```yaml
# params.yaml
split:
  test_size: 0.2
  val_size: 0.1
  random_state: 42

# dvc.yaml
stages:
  split:
    cmd: python split.py --test ${split.test_size} --val ${split.val_size}
    params:
    - split.test_size
    - split.val_size
```

### Slide 74: Pipeline Metrics
```yaml
stages:
  evaluate:
    cmd: python evaluate.py
    deps:
    - model.pkl
    - test.csv
    outs:
    - metrics.json
    metrics:
    - metrics.json:
        cache: false
```

### Slide 75: Pipeline Plots
```yaml
stages:
  analyze:
    cmd: python analyze.py
    outs:
    - plots/
    plots:
    - plots/confusion_matrix.png
    - plots/feature_importance.png
```

### Slide 76: Custom Pipelines
```python
# pipeline.py
import dvc.api

def run_pipeline():
    # Run stages
    dvc.repro('process')
    dvc.repro('train')
    dvc.repro('evaluate')
    
    # Get metrics
    metrics = dvc.api.metrics_show()
    return metrics
```

### Slide 77: Importing Data
```bash
# Import from remote
dvc import s3://mybucket/data.csv

# Import specific version
dvc import s3://mybucket/data.csv --rev v1.0.0

# Update import
dvc update data.csv.dvc
```

### Slide 78: Exporting Data
```bash
# Export to remote
dvc export data.csv s3://mybucket/export/data.csv

# Export specific version
dvc export data.csv s3://mybucket/export/data.csv --rev v1.0.0
```

### Slide 79: Running Experiments
```bash
# Run experiment
dvc exp run

# List experiments
dvc exp list

# Show experiment results
dvc exp show

# Compare experiments
dvc exp diff

# Apply experiment
dvc exp apply experiment-name
```

### Slide 80: Experiment Parameters
```bash
# Run with parameters
dvc exp run --set-param train.lr=0.01

# Run multiple experiments
dvc exp run --queue
dvc exp run --queue --set-param train.lr=0.01
dvc exp run --queue --set-param train.lr=0.001
dvc exp run --run-all
```

### Slide 81: Reproducing Experiments
```bash
# Reproduce experiment
dvc exp apply experiment-name

# Compare experiments
dvc exp diff

# Show experiment table
dvc exp show --only-changed
```

### Slide 82: DVC with MLflow Integration
```python
import dvc.api
import mlflow

# Get data version
with dvc.api.open('data/raw/data.csv') as f:
    data = f.read()

# Log DVC version
mlflow.log_param('data_version', dvc.api.get_url('data/raw/data.csv'))

# Log data hash
import hashlib
hash = hashlib.md5(data).hexdigest()
mlflow.log_param('data_hash', hash)
```

### Slide 83: DVC with Dagster Integration
```python
from dagster import resource

@resource
def dvc_resource():
    import dvc.repo
    return dvc.repo.Repo()

@op(required_resource_keys={'dvc'})
def run_pipeline(context):
    repo = context.resources.dvc
    repo.reproduce()
```

### Slide 84: DVC Troubleshooting
- **Issue:** Cache corruption
  - Solution: `dvc cache verify`
- **Issue:** Remote connection
  - Solution: Check credentials, network
- **Issue:** Pipeline not updating
  - Solution: `dvc status --checks`, `dvc repro --force`
- **Issue:** Large cache
  - Solution: `dvc gc --workspace`

### Slide 85: DVC Performance Tips
- Use `.dvcignore` for temporary files
- Use `--single-item` for specific stages
- Use `--force` only when needed
- Clean cache regularly
- Use appropriate batch sizes
- Monitor remote upload/download speed

---

## Module 5: DVC in Practice (Slides 86-100)

### Slide 86: Real-World Example
```bash
# Project structure
mlops-pipeline-series/
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── models/
├── src/
├── dvc.yaml
├── params.yaml
└── .dvc/
```

### Slide 87: Data Pipeline Setup
```yaml
# dvc.yaml
stages:
  generate_data:
    cmd: python src/data/generate.py --hours 48
    deps:
    - src/data/generate.py
    outs:
    - data/raw/sensor_data_48h.csv
  
  process_features:
    cmd: python src/features/build.py --input data/raw/sensor_data_48h.csv
    deps:
    - src/features/build.py
    - data/raw/sensor_data_48h.csv
    outs:
    - data/processed/features_48h.csv
```

### Slide 88: Running the Pipeline
```bash
# Initial run
dvc repro

# After code changes
dvc status
# Changed stages identified
dvc repro  # Only changed stages run

# Force full run
dvc repro --force
```

### Slide 89: Tracking Model Versions
```bash
# Track model
dvc add models/registry/model.pkl

# Commit
git add models/registry/model.pkl.dvc
git commit -m "Add model v1.0"

# Push data
dvc push

# Push code
git push
```

### Slide 90: Team Collaboration Workflow
```
1. Developer A updates data
   dvc add data.csv
   dvc push
   git commit
   git push

2. Developer B pulls
   git pull
   dvc pull
   
3. Both work with same data version
```

### Slide 91: Data Versioning Strategy
```
Raw Data:      Always versioned (immutable)
Processed:     Versioned (reproducible)
Model:         Versioned (track changes)
Metrics:       Versioned (track performance)
```

### Slide 92: Pipeline Versioning
```bash
# Tag pipeline
dvc tag data/raw/sensor_data_48h.csv v1.0.0
git tag -a pipeline-v1.0.0 -m "Pipeline version 1.0.0"

# Reproduce old pipeline
git checkout pipeline-v1.0.0
dvc checkout
dvc repro
```

### Slide 93: Data Quality Checks
```python
# data_validation.py
def validate_data(df):
    # Check schema
    assert all(col in df.columns for col in expected_columns)
    
    # Check missing values
    assert df.isnull().sum().sum() == 0
    
    # Check ranges
    assert df['temperature'].between(50, 100).all()
    
    # Check labels
    assert df['label'].isin([0, 1]).all()
```

### Slide 94: Automated Data Validation
```yaml
# dvc.yaml
stages:
  validate_data:
    cmd: python scripts/validate_data.py data/raw/data.csv
    deps:
    - data/raw/data.csv
    - scripts/validate_data.py
    outs:
    - validation_report.json
    metrics:
    - validation_report.json:
        cache: false
```

### Slide 95: Data Drift Detection
```python
# drift_detection.py
from scipy.stats import ks_2samp

def detect_drift(old_data, new_data, threshold=0.05):
    for col in old_data.columns:
        stat, p_value = ks_2samp(old_data[col], new_data[col])
        if p_value < threshold:
            print(f"Drift detected in {col}: p={p_value:.4f}")
            return True
    return False
```

### Slide 96: Data Version Rollback
```bash
# Identify bad version
dvc status
dvc metrics diff

# Rollback
git checkout previous_commit
dvc checkout
dvc repro

# Or use tags
git checkout v1.0.0
dvc checkout
dvc repro
```

### Slide 97: CI/CD Integration
```yaml
# .github/workflows/dvc.yaml
name: DVC Pipeline
on: [push]

jobs:
  pipeline:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-python@v4
    - name: Install DVC
      run: pip install dvc
    - name: Pull data
      run: dvc pull
    - name: Run pipeline
      run: dvc repro
```

### Slide 98: DVC Best Practices Recap
1. Always version raw data
2. Use meaningful commit messages
3. Tag important versions
4. Push data regularly
5. Clean cache periodically
6. Use pipelines for automation
7. Track metrics and plots
8. Document data schemas
9. Test data validation
10. Monitor data drift

### Slide 99: DVC Common Pitfalls
- ❌ Versioning large files with Git
- ❌ Not pushing to remote
- ❌ Ignoring .dvcignore
- ❌ Not cleaning cache
- ❌ Complex pipelines (too many stages)
- ❌ Hard-coded paths
- ❌ Not using parameters
- ❌ Missing documentation

### Slide 100: DVC Recap
- ✅ Git for code, DVC for data
- ✅ Remote storage for collaboration
- ✅ Pipelines for automation
- ✅ Reproducible experiments
- ✅ Version tracking
- ✅ Data quality validation

---

# SECTION 3: EXPERIMENT TRACKING WITH MLFLOW (Slides 101-160)

---

## Module 6: MLflow Fundamentals (Slides 101-125)

### Slide 101: MLflow Introduction
- **What is MLflow?**
  - Open source platform
  - Manage ML lifecycle
  - Experiment tracking
  - Model registry
  - Projects

- **Key Features:**
  - Tracking (parameters/metrics)
  - Projects (reproducible)
  - Models (packaging)
  - Registry (model management)
  - Serving (deployment)

### Slide 102: MLflow Components
```
┌─────────────────────────────────────┐
│          MLflow Components          │
├─────────────────────────────────────┤
│                                     │
│  Tracking (Experiments/Runs)        │
│  ↓                                  │
│  Projects (Reproducible Code)       │
│  ↓                                  │
│  Models (Packaging/Deployment)      │
│  ↓                                  │
│  Registry (Model Management)        │
│                                     │
└─────────────────────────────────────┘
```

### Slide 103: MLflow Architecture
```
┌─────────────────────────────────────┐
│         MLflow Architecture         │
├─────────────────────────────────────┤
│                                     │
│  Client (SDK) ←→ Tracking Server   │
│                     ↓               │
│               Backend Store         │
│               (PostgreSQL)          │
│               ↓                     │
│               Artifact Store        │
│               (S3/GCS)              │
│                                     │
└─────────────────────────────────────┘
```

### Slide 104: MLflow Installation
```bash
# Install MLflow
pip install mlflow

# Install with extras
pip install mlflow[extras]

# Verify installation
mlflow --version

# Install specific version
pip install mlflow==2.4.1
```

### Slide 105: Setting Up Tracking
```python
import mlflow

# Set tracking URI
mlflow.set_tracking_uri("file:./mlruns")

# Or remote server
mlflow.set_tracking_uri("http://localhost:5000")

# Set experiment
mlflow.set_experiment("my_experiment")

# Start run
with mlflow.start_run():
    # Your code here
```

### Slide 106: MLflow Concepts
- **Experiment:** Container for runs
- **Run:** Single execution instance
- **Parameters:** Input values (hyperparameters)
- **Metrics:** Output values (accuracy, loss)
- **Artifacts:** Files (models, plots)
- **Tags:** Metadata (notes, version)

### Slide 107: Starting a Run
```python
# Method 1: Context manager
with mlflow.start_run(run_name="my_run"):
    # Log parameters
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_param("batch_size", 32)
    
    # Log metrics
    mlflow.log_metric("accuracy", 0.95)
    mlflow.log_metric("loss", 0.12)

# Method 2: Manual start/end
run = mlflow.start_run()
# ... code ...
mlflow.end_run()

# Method 3: Resume run
mlflow.start_run(run_id=existing_run_id)
```

### Slide 108: Logging Parameters
```python
# Single parameter
mlflow.log_param("learning_rate", 0.01)
mlflow.log_param("model_type", "random_forest")

# Multiple parameters
params = {
    "learning_rate": 0.01,
    "batch_size": 32,
    "epochs": 100,
    "optimizer": "adam"
}
mlflow.log_params(params)

# Nested parameters
mlflow.log_param("model.random_forest.n_estimators", 100)
mlflow.log_param("model.random_forest.max_depth", 10)
```

### Slide 109: Logging Metrics
```python
# Single metric
mlflow.log_metric("accuracy", 0.95)

# Multiple metrics
metrics = {
    "accuracy": 0.95,
    "f1_score": 0.93,
    "precision": 0.94,
    "recall": 0.92
}
mlflow.log_metrics(metrics)

# Metrics with step (training loop)
for epoch in range(epochs):
    loss = train_step()
    mlflow.log_metric("loss", loss, step=epoch)
```

### Slide 110: Logging Artifacts
```python
# Text file
mlflow.log_text("Hello World", "hello.txt")

# JSON
mlflow.log_dict({"key": "value"}, "data.json")

# CSV/DataFrame
import pandas as pd
df.to_csv("data.csv")
mlflow.log_artifact("data.csv")

# Entire directory
mlflow.log_artifacts("output_dir/", artifact_path="outputs")

# Figure (matplotlib)
import matplotlib.pyplot as plt
plt.savefig("plot.png")
mlflow.log_artifact("plot.png")
```

### Slide 111: Logging Models
```python
# Scikit-learn
mlflow.sklearn.log_model(model, "sklearn_model")

# PyTorch
mlflow.pytorch.log_model(model, "pytorch_model")

# TensorFlow
mlflow.tensorflow.log_model(model, "tf_model")

# XGBoost
mlflow.xgboost.log_model(model, "xgboost_model")

# Custom model (PyFunc)
mlflow.pyfunc.log_model(
    artifact_path="custom_model",
    python_model=wrapper,
    code_paths=["src/"]
)
```

### Slide 112: Tags and Notes
```python
# Set tags
mlflow.set_tag("dataset_version", "v1.0.0")
mlflow.set_tag("environment", "staging")
mlflow.set_tag("notes", "Initial model with 100 trees")

# Multiple tags
tags = {
    "team": "mlops",
    "project": "predictive_maintenance",
    "model_version": "1.0.0"
}
mlflow.set_tags(tags)

# Note as tag
mlflow.set_tag("description", """
This model uses random forest with 100 trees.
Trained on 48 hours of sensor data.
Test accuracy: 0.95
""")
```

### Slide 113: MLflow UI
```bash
# Start UI
mlflow ui

# With backend store
mlflow ui --backend-store-uri ./mlruns

# Remote server
mlflow ui --backend-store-uri http://localhost:5000

# Port
mlflow ui --port 5001
```

### Slide 114: MLflow UI Features
- Experiment list
- Run details
- Parameter comparison
- Metric visualization
- Artifact viewer
- Model registry
- Search/filter

### Slide 115: Experiment Management
```python
# Create experiment
experiment_id = mlflow.create_experiment(
    name="my_experiment",
    artifact_location="./my_artifacts"
)

# Get experiment
experiment = mlflow.get_experiment(experiment_id)

# List experiments
experiments = mlflow.list_experiments()

# Set active experiment
mlflow.set_experiment("my_experiment")
```

### Slide 116: Run Comparison
```python
# Search runs
runs = mlflow.search_runs(
    experiment_ids=["0", "1"],
    filter_string="metrics.accuracy > 0.9",
    order_by=["metrics.accuracy DESC"],
    max_results=10
)

# Get specific run
run = mlflow.get_run(run_id)

# Compare runs
runs_df = mlflow.search_runs()
best_run = runs_df.loc[runs_df['metrics.f1'].idxmax()]
```

### Slide 117: MLflow Projects
```yaml
# MLproject file
name: My Project
conda_env: conda.yaml

entry_points:
  main:
    parameters:
      learning_rate: {type: float, default: 0.01}
      batch_size: {type: int, default: 32}
    command: "python train.py --lr {learning_rate} --batch {batch_size}"
```

### Slide 118: Running Projects
```bash
# Run project
mlflow run .

# With parameters
mlflow run . -P learning_rate=0.001 -P batch_size=64

# Run remote project
mlflow run git://github.com/user/project.git

# Specify entry point
mlflow run . -e train
```

### Slide 119: MLflow Models
```yaml
# MLmodel file
artifact_path: model
flavors:
  sklearn:
    sklearn_version: 1.3.0
    pickled_model: model.pkl
  python_function:
    model_path: model.pkl
    predict: predict
    env: conda.yaml
```

### Slide 120: Model Serving
```bash
# Serve model
mlflow models serve -m models:/my_model/Production

# With specific port
mlflow models serve -m models:/my_model/Production -p 8000

# Test prediction
curl -X POST http://localhost:8000/invocations \
  -H "Content-Type: application/json" \
  -d '{"dataframe_split": {"columns": ["feature1"], "data": [[1.0]]}}'
```

### Slide 121: Model Registry
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

### Slide 122: Registry Stages
- **Staging:** Testing and validation
- **Production:** Serving predictions
- **Archived:** Historical record
- **None:** Unstaged

### Slide 123: Model Versioning
```python
# List versions
versions = client.search_model_versions("name='my_model'")

# Get specific version
version = client.get_model_version("my_model", 1)

# Update description
client.update_model_version(
    name="my_model",
    version=1,
    description="Improved model with more data"
)

# Add tags
client.set_model_version_tag(
    name="my_model",
    version=1,
    key="accuracy",
    value="0.95"
)
```

### Slide 124: MLflow Best Practices
1. Use meaningful experiment names
2. Log all relevant parameters
3. Track all metrics (training, validation, test)
4. Store models in registry
5. Use tags for metadata
6. Document runs with descriptions
7. Version models semantically
8. Use stages for lifecycle
9. Backup artifacts
10. Monitor registry usage

### Slide 125: MLflow Recap
- ✅ Track experiments
- ✅ Log parameters/metrics
- ✅ Store artifacts
- ✅ Manage models
- ✅ Version via registry
- ✅ Deploy with serving

---

## Module 7: Advanced MLflow (Slides 126-145)

### Slide 126: Custom Flavor
```python
from mlflow.models import Model, ModelSignature
from mlflow.models.model import MLModel
import cloudpickle

class CustomModel:
    def __init__(self, model):
        self.model = model
    
    def predict(self, data):
        return self.model.predict(data)

def save_custom_model(model, path):
    import cloudpickle
    with open(path, 'wb') as f:
        cloudpickle.dump(model, f)
    
    mlflow.pyfunc.save_model(
        path=path,
        python_model=model,
        code_paths=["src/"]
    )
```

### Slide 127: Custom Artifacts
```python
class CustomArtifact:
    def __init__(self, data):
        self.data = data
    
    def save(self, path):
        import json
        with open(path, 'w') as f:
            json.dump(self.data, f)

# Log custom artifact
mlflow.log_artifact("custom_artifact.json")

# Load custom artifact
import json
with open("artifacts/custom_artifact.json", 'r') as f:
    data = json.load(f)
```

### Slide 128: MLflow with Docker
```dockerfile
# Dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["mlflow", "models", "serve", "-m", "models:/my_model/Production"]
```

### Slide 129: MLflow with Kubernetes
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mlflow
  template:
    metadata:
      labels:
        app: mlflow
    spec:
      containers:
      - name: mlflow
        image: mlflow:latest
        ports:
        - containerPort: 5000
        env:
        - name: MLFLOW_TRACKING_URI
          value: "postgresql://..."
```

### Slide 130: MLflow Security
```python
# Basic auth
import requests
from requests.auth import HTTPBasicAuth

response = requests.post(
    "http://localhost:5000/api/2.0/mlflow/runs/search",
    auth=HTTPBasicAuth("user", "pass"),
    json={"experiment_ids": ["0"]}
)

# Environment variables
os.environ['MLFLOW_TRACKING_USERNAME'] = 'user'
os.environ['MLFLOW_TRACKING_PASSWORD'] = 'pass'
```

### Slide 131: MLflow Performance
```python
# Batch logging
import time
class BatchLogger:
    def __init__(self):
        self.batch = []
        self.batch_size = 100
    
    def log_metric(self, key, value):
        self.batch.append((key, value))
        if len(self.batch) >= self.batch_size:
            self.flush()
    
    def flush(self):
        for key, value in self.batch:
            mlflow.log_metric(key, value)
        self.batch = []

# Connection pooling
import requests
from requests.adapters import HTTPAdapter
session = requests.Session()
adapter = HTTPAdapter(pool_connections=10, pool_maxsize=20)
session.mount('http://', adapter)
```

### Slide 132: MLflow with Apache Spark
```python
from pyspark.ml import Pipeline
from pyspark.ml.classification import RandomForestClassifier
import mlflow
import mlflow.spark

# Log Spark model
with mlflow.start_run():
    model = RandomForestClassifier()
    pipeline = Pipeline(stages=[model])
    
    mlflow.spark.log_model(
        spark_model=pipeline,
        artifact_path="spark_model",
        registered_model_name="spark_model"
    )
```

### Slide 133: MLflow with TensorFlow
```python
import tensorflow as tf
import mlflow.tensorflow

# Log TF model
with mlflow.start_run():
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid')
    ])
    
    # Keras callback
    callback = mlflow.tensorflow.MlflowCallback()
    model.fit(X, y, callbacks=[callback])
    
    mlflow.tensorflow.log_model(model, "tf_model")
```

### Slide 134: MLflow with PyTorch
```python
import torch
import torch.nn as nn
import mlflow.pytorch

# Log PyTorch model
with mlflow.start_run():
    model = nn.Sequential(
        nn.Linear(10, 64),
        nn.ReLU(),
        nn.Linear(64, 1),
        nn.Sigmoid()
    )
    
    mlflow.pytorch.log_model(model, "pytorch_model")
```

### Slide 135: MLflow with XGBoost
```python
import xgboost as xgb
import mlflow.xgboost

# Log XGBoost model
with mlflow.start_run():
    model = xgb.XGBClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5
    )
    
    model.fit(X, y)
    mlflow.xgboost.log_model(model, "xgboost_model")
```

### Slide 136: MLflow with LightGBM
```python
import lightgbm as lgb
import mlflow.lightgbm

# Log LightGBM model
with mlflow.start_run():
    model = lgb.LGBMClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5
    )
    
    model.fit(X, y)
    mlflow.lightgbm.log_model(model, "lightgbm_model")
```

### Slide 137: MLflow Integration with DVC
```python
import dvc.api
import mlflow

def track_data_version(data_path):
    # Get DVC version
    with dvc.api.open(data_path) as f:
        import hashlib
        hash = hashlib.md5(f.read()).hexdigest()
    
    # Log to MLflow
    mlflow.log_param("data_version", hash)
    mlflow.set_tag("data_file", data_path)
    
    return hash
```

### Slide 138: MLflow Integration with Dagster
```python
from dagster import op, resource, job
import mlflow

@resource
def mlflow_resource():
    mlflow.set_tracking_uri("./mlruns")
    return mlflow

@op(required_resource_keys={"mlflow"})
def train_model(context):
    mlflow = context.resources.mlflow
    with mlflow.start_run():
        # Train model
        model = train()
        mlflow.log_metric("accuracy", 0.95)

@job(resource_defs={"mlflow": mlflow_resource})
def ml_pipeline():
    train_model()
```

### Slide 139: MLflow Troubleshooting
- **Issue:** Connection refused
  - Solution: Check tracking URI
- **Issue:** Duplicate runs
  - Solution: Use unique run names
- **Issue:** Large artifacts
  - Solution: Use multipart upload
- **Issue:** Slow UI
  - Solution: Use PostgreSQL backend
- **Issue:** Missing artifacts
  - Solution: Check artifact path

### Slide 140: MLflow Performance Tips
- Use batch logging for many metrics
- Use connection pooling
- Limit artifact size
- Use binary formats (Parquet)
- Compress artifacts
- Use remote server for scale
- Cache frequently accessed data

### Slide 141: MLflow Monitoring
```python
# Monitor run status
def monitor_run(run_id, interval=10):
    while True:
        run = mlflow.get_run(run_id)
        if run.info.status != "RUNNING":
            break
        time.sleep(interval)

# Get run metrics
run = mlflow.get_run(run_id)
metrics = run.data.metrics
params = run.data.params
```

### Slide 142: MLflow Export/Import
```python
# Export experiment
import json
def export_experiment(experiment_name):
    experiment = mlflow.get_experiment_by_name(experiment_name)
    runs = mlflow.search_runs(experiment_ids=[experiment.experiment_id])
    
    # Convert to JSON
    data = {
        "experiment": experiment.__dict__,
        "runs": runs.to_dict()
    }
    
    with open("experiment.json", 'w') as f:
        json.dump(data, f, default=str)

# Import experiment
def import_experiment(file_path):
    with open(file_path, 'r') as f:
        data = json.load(f)
    # Recreate experiment and runs
```

### Slide 143: MLflow Best Practices Recap
1. Use meaningful experiment names
2. Log all parameters
3. Track relevant metrics
4. Store model artifacts
5. Use registry stages
6. Tag runs
7. Document experiments
8. Version models
9. Monitor performance
10. Backup data

### Slide 144: MLflow Common Pitfalls
- ❌ Not setting tracking URI
- ❌ Hardcoding paths
- ❌ Missing parameter logging
- ❌ Not using registry
- ❌ Too many artifacts
- ❌ Not tagging runs
- ❌ Ignoring model stages
- ❌ Not documenting models
- ❌ Not monitoring performance
- ❌ Not backing up experiments

### Slide 145: MLflow Recap
- ✅ Experiment tracking
- ✅ Parameter/metric logging
- ✅ Artifact storage
- ✅ Model registry
- ✅ Stage management
- ✅ Deployment capabilities

---

## Module 8: Model Registry (Slides 146-160)

### Slide 146: Model Registry Concepts
- **What:** Centralized model management
- **Why:** Versioning, governance, collaboration
- **Components:**
  - Registered Model
  - Model Version
  - Stages (Staging, Production, Archived)
  - Tags/Annotations

### Slide 147: Registry vs. Tracking
```
Tracking                    Registry
────────                    ────────
Experiment runs             Model versions
Parameters/Metrics          Model artifacts
Temporary storage           Long-term storage
Experiment analysis         Production management
```

### Slide 148: Setting Up Registry
```python
from mlflow.tracking import MlflowClient

client = MlflowClient()

# Create registered model
registered_model = client.create_registered_model(
    name="predictive_maintenance_model",
    tags={"team": "mlops", "project": "maintenance"},
    description="Model for predicting equipment failures"
)
```

### Slide 149: Registering Models
```python
# Register from run
model_version = client.create_model_version(
    name="predictive_maintenance_model",
    source="runs:/run_id/model",
    run_id="run_id",
    tags={"accuracy": "0.95"}
)

# Register directly
mlflow.sklearn.log_model(
    sk_model=model,
    artifact_path="model",
    registered_model_name="predictive_maintenance_model"
)
```

### Slide 150: Version Management
```python
# List versions
versions = client.search_model_versions("name='predictive_maintenance_model'")

# Get version
version = client.get_model_version(
    name="predictive_maintenance_model",
    version=1
)

# Update version
client.update_model_version(
    name="predictive_maintenance_model",
    version=1,
    description="Improved with additional features"
)
```

### Slide 151: Stage Transitions
```python
# Transition to Staging
client.transition_model_version_stage(
    name="predictive_maintenance_model",
    version=1,
    stage="Staging"
)

# Transition to Production (auto-archive)
client.transition_model_version_stage(
    name="predictive_maintenance_model",
    version=1,
    stage="Production",
    archive_existing_versions=True
)

# Transition to Archived
client.transition_model_version_stage(
    name="predictive_maintenance_model",
    version=1,
    stage="Archived"
)
```

### Slide 152: Model Versioning Strategy
```
v1.0.0 → Staging → v1.0.1 → Staging → Production
             ↓                    ↓
v2.0.0 → Staging → Production → Archived
             ↓                    ↓
v2.1.0 → Staging                Archived
```

### Slide 153: Promoting Models
```python
def promote_model(model_name, version):
    # Validate
    version = client.get_model_version(model_name, version)
    run = mlflow.get_run(version.run_id)
    
    # Check metrics
    metrics = run.data.metrics
    if metrics.get('f1', 0) < 0.85:
        raise ValueError("Model does not meet criteria")
    
    # Promote
    client.transition_model_version_stage(
        name=model_name,
        version=version,
        stage="Production",
        archive_existing_versions=True
    )
    
    # Add metadata
    client.set_model_version_tag(
        name=model_name,
        version=version,
        key="promoted_by",
        value="validation_pipeline"
    )
```

### Slide 154: Model Lineage
```python
# Trace model lineage
def trace_lineage(model_name, version):
    version = client.get_model_version(model_name, version)
    run = mlflow.get_run(version.run_id)
    
    lineage = {
        "model": model_name,
        "version": version.version,
        "run_id": version.run_id,
        "params": run.data.params,
        "metrics": run.data.metrics,
        "tags": run.data.tags,
        "dataset": run.data.tags.get("dataset_version")
    }
    return lineage
```

### Slide 155: Model Lifecycle
```
Development → Staging → Production → Archived
     ↓           ↓           ↓           ↓
  Experiment  Validation  Serving    Historical
  Tracking    Testing     Deployment  Record
```

### Slide 156: Model Metadata
```python
# Add metadata
client.set_model_version_tag(
    name="model",
    version=1,
    key="metadata",
    value=json.dumps({
        "training_date": "2024-01-01",
        "dataset_version": "v1.0.0",
        "test_accuracy": 0.95,
        "feature_importance": {"feature1": 0.3, "feature2": 0.2}
    })
)

# Retrieve metadata
version = client.get_model_version("model", 1)
metadata = json.loads(version.tags.get("metadata", "{}"))
```

### Slide 157: Model Search
```python
# Search by name
models = client.search_registered_models()

# Search by filter
models = client.search_registered_models(
    filter_string="tags.team = 'mlops'"
)

# Search versions
versions = client.search_model_versions(
    filter_string="name='model' AND current_stage='Production'"
)
```

### Slide 158: Registry Integration
```python
# CI/CD integration
def register_model_from_ci(run_id):
    client = MlflowClient()
    
    # Get run
    run = mlflow.get_run(run_id)
    metrics = run.data.metrics
    
    # Create model
    client.create_model_version(
        name="ci_cd_model",
        source=f"runs:/{run_id}/model",
        run_id=run_id
    )
    
    # Stage based on metrics
    if metrics.get('f1', 0) > 0.90:
        client.transition_model_version_stage(
            name="ci_cd_model",
            version=1,
            stage="Production"
        )
```

### Slide 159: Registry Best Practices
1. Use descriptive model names
2. Version models semantically
3. Document model versions
4. Use stages for lifecycle
5. Add metadata/tags
6. Monitor production models
7. Archive old models
8. Track lineage
9. Validate before promotion
10. Automate where possible

### Slide 160: Registry Recap
- ✅ Centralized model management
- ✅ Version control
- ✅ Stage transitions
- ✅ Metadata management
- ✅ Lineage tracking
- ✅ Integration with CI/CD

---

# SECTION 4: PIPELINE ORCHESTRATION WITH DAGSTER (Slides 161-220)

---

## Module 9: Dagster Fundamentals (Slides 161-185)

### Slide 161: Dagster Introduction
- **What is Dagster?**
  - Data orchestration platform
  - Modern alternative to Airflow
  - Type-safe and testable
  - Asset-aware

- **Key Features:**
  - Assets (data lineage)
  - Ops (transformations)
  - Jobs (pipelines)
  - Schedules (time-based)
  - Sensors (event-based)
  - Resources (dependencies)

### Slide 162: Why Dagster?
- **Problems Solved:**
  - Complex dependencies
  - Pipeline failures
  - Data lineage
  - Testing challenges
  - Monitoring gaps

- **Benefits:**
  - Type safety
  - Local development
  - Rich UI
  - Asset tracking
  - Observability
  - Testing support

### Slide 163: Dagster vs. Airflow
```
Dagster                    Airflow
────────                   ───────
Asset-aware                Task-based
Type safety                Dynamic typing
Local dev support          Limited local dev
Rich UI                    Basic UI
Python-centric             Python-based
Modern design              Legacy design
```

### Slide 164: Dagster Architecture
```
┌─────────────────────────────────────┐
│        Dagster Architecture         │
├─────────────────────────────────────┤
│                                     │
│  User Code (Definitions)            │
│  ↓                                  │
│  API (gRPC)                         │
│  ↓                                  │
│  Execution Engine                   │
│  ↓                                  │
│  Storage (PostgreSQL/SQLite)        │
│  ↓                                  │
│  UI/Webserver                      │
│                                     │
└─────────────────────────────────────┘
```

### Slide 165: Dagster Components
```
Assets    → Data artifacts (tables, files, models)
Ops       → Transformations (functions)
Jobs      → Pipeline of ops
Schedules → Time-based triggers
Sensors   → Event-based triggers
Resources → Shared services (DB, API)
IOManager → Data persistence
```

### Slide 166: Installation
```bash
# Install Dagster
pip install dagster dagster-webserver

# Install with extras
pip install dagster dagster-webserver dagster-docker

# Verify installation
dagster --version

# Install specific version
pip install dagster==1.5.3
```

### Slide 167: Project Structure
```
my_project/
├── __init__.py
├── ops.py          # Operation definitions
├── assets.py       # Asset definitions
├── jobs.py         # Job definitions
├── schedules.py    # Schedule definitions
├── sensors.py      # Sensor definitions
├── resources.py    # Resource definitions
└── repository.py   # Repository definition
```

### Slide 168: Defining Ops
```python
from dagster import op, OpExecutionContext

@op
def my_op(context: OpExecutionContext):
    context.log.info("Hello from my_op")
    return 1

@op(
    name="custom_name",
    description="This op does something",
    tags={"team": "mlops"},
    retry_policy=RetryPolicy(max_retries=3)
)
def another_op(context: OpExecutionContext):
    return "result"
```

### Slide 169: Op Inputs/Outputs
```python
from dagster import op, In, Out

@op(
    ins={"input": In(dagster_type=int)},
    out={"output": Out(dagster_type=int)}
)
def process_op(context, input: int):
    result = input * 2
    return result

@op(
    ins={"data": In(dagster_type=str)},
    out=Out(dagster_type=str)
)
def string_op(context, data: str):
    return data.upper()
```

### Slide 170: Defining Jobs
```python
from dagster import job, graph

@job
def my_job():
    # Define pipeline
    result = op1()
    final = op2(result)
    return final

# With resources
@job(resource_defs={"db": DatabaseResource()})
def resource_job():
    result = op1()
    final = op2(result)
    return final
```

### Slide 171: Defining Assets
```python
from dagster import asset, AssetExecutionContext

@asset
def raw_data(context: AssetExecutionContext):
    return pd.DataFrame({"col": [1, 2, 3]})

@asset
def processed_data(context: AssetExecutionContext, raw_data: pd.DataFrame):
    return raw_data * 2

@asset(
    name="custom_name",
    description="Asset description",
    tags={"team": "mlops"},
    group_name="processing"
)
def my_asset():
    return "data"
```

### Slide 172: Asset Dependencies
```python
@asset
def upstream_asset():
    return "data"

@asset(deps=[upstream_asset])
def downstream_asset():
    # Automatically uses upstream_asset
    data = upstream_asset()  # Injected
    return data + "_processed"

# Explicit dependency
@asset(ins={"upstream": AssetKey(["upstream_asset"])})
def explicit_asset(upstream: str):
    return upstream + "_explicit"
```

### Slide 173: Multi-Assets
```python
from dagster import multi_asset, AssetOut

@multi_asset(
    outs={
        "train": AssetOut(),
        "test": AssetOut()
    }
)
def split_data(raw_data):
    train, test = train_test_split(raw_data)
    return {"train": train, "test": test}
```

### Slide 174: Schedules
```python
from dagster import schedule

@schedule(
    job=my_job,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def daily_schedule(context):
    return {}

@schedule(
    job=my_job,
    cron_schedule="0 0 * * 0",  # Weekly on Sunday
    execution_timezone="UTC"
)
def weekly_schedule(context):
    return {
        "ops": {
            "my_op": {
                "config": {"batch_size": 1000}
            }
        }
    }
```

### Slide 175: Sensors
```python
from dagster import sensor, RunRequest, SkipReason

@sensor(job=my_job)
def file_sensor(context):
    file_path = Path("data/new_data.csv")
    
    if not file_path.exists():
        return SkipReason("No new data")
    
    return RunRequest(
        run_key=f"file_{file_path.stat().st_mtime}",
        tags={"trigger": "file_sensor"}
    )
```

### Slide 176: Resources
```python
from dagster import resource, Resource

class DatabaseResource(Resource):
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
    
    def get_connection(self):
        # Create DB connection
        pass

@resource(config_schema={"connection_string": str})
def db_resource(context):
    return DatabaseResource(context.resource_config["connection_string"])
```

### Slide 177: I/O Managers
```python
from dagster import IOManager, OutputContext, InputContext

class CustomIOManager(IOManager):
    def handle_output(self, context: OutputContext, obj):
        # Save output
        pass
    
    def load_input(self, context: InputContext):
        # Load input
        pass

@io_manager
def custom_io_manager():
    return CustomIOManager()
```

### Slide 178: Config Schema
```python
from dagster import Config, op
from typing import Optional

class MyOpConfig(Config):
    batch_size: int = 1000
    learning_rate: float = 0.01
    model_type: str
    debug: Optional[bool] = False

@op
def configurable_op(context):
    config = MyOpConfig()
    batch_size = config.batch_size
    lr = config.learning_rate
```

### Slide 179: Error Handling
```python
from dagster import op, Failure, RetryPolicy

@op(
    retry_policy=RetryPolicy(
        max_retries=3,
        delay=5,
        backoff=2
    )
)
def retryable_op(context):
    import random
    if random.random() < 0.2:
        raise Failure("Transient error")
    return "success"

@op
def error_handling_op(context):
    try:
        # Risky operation
        result = risky_function()
    except Exception as e:
        context.log.error(f"Error: {e}")
        return {"status": "failed", "error": str(e)}
    return {"status": "success", "result": result}
```

### Slide 180: Testing Ops
```python
from dagster import build_op_context

def test_op():
    context = build_op_context()
    result = my_op(context)
    assert result == expected

def test_asset():
    context = build_asset_context()
    result = my_asset(context)
    assert isinstance(result, pd.DataFrame)
```

### Slide 181: Testing Jobs
```python
from dagster import execute_job

def test_job():
    result = execute_job(my_job)
    assert result.success
    
    output_values = result.output_values()
    assert output_values["result"] == expected
```

### Slide 182: Running Locally
```bash
# Start webserver
dagster-webserver

# With specific file
dagster-webserver -f my_pipeline.py

# With module
dagster-webserver -m my_project

# Run job
dagster job execute -f my_pipeline.py -j my_job

# Run with config
dagster job execute -f my_pipeline.py -j my_job -c config.yaml
```

### Slide 183: Dagster UI Features
- Pipeline graph visualization
- Run history
- Asset lineage
- Schedule management
- Sensor management
- Resource configuration
- Log viewer
- Performance metrics

### Slide 184: Dagster Best Practices
1. Use type annotations
2. Write tests for ops
3. Use resources for external services
4. Define clear config schemas
5. Use assets for data lineage
6. Document ops and assets
7. Use schedules for automation
8. Implement error handling
9. Monitor runs
10. Use version control

### Slide 185: Dagster Recap
- ✅ Modern orchestration
- ✅ Asset awareness
- ✅ Type safety
- ✅ Rich UI
- ✅ Testing support
- ✅ Integration friendly

---

## Module 10: Advanced Dagster (Slides 186-205)

### Slide 186: Advanced Assets
```python
from dagster import asset, materialize, AssetKey

# Partitioned assets
@asset(partitions_def=DailyPartitionsDefinition(start_date="2024-01-01"))
def daily_data(context):
    partition = context.partition_key
    # Load data for partition

# Asset with config
@asset(config_schema={"batch_size": int})
def configurable_asset(context):
    config = context.op_config
    batch_size = config["batch_size"]

# Asset with metadata
@asset
def metadata_asset(context):
    return Output(
        data,
        metadata={"rows": len(data), "columns": len(data.columns)}
    )
```

### Slide 187: Dynamic Assets
```python
from dagster import dynamic_asset, DynamicAssetDefinition

@dynamic_asset
def dynamic_assets():
    for i in range(10):
        yield AssetOut(key=f"asset_{i}")

# Dynamic output
from dagster import DynamicOut, DynamicOutput

@op(out=DynamicOut())
def dynamic_op(context):
    for item in data:
        yield DynamicOutput(item, mapping_key=str(item.id))
```

### Slide 188: Complex DAGs
```python
from dagster import graph, job

@graph
def complex_graph():
    # Branching
    data = load_data()
    branch1 = process_branch1(data)
    branch2 = process_branch2(data)
    
    # Joining
    final = combine(branch1, branch2)
    
    # Additional steps
    result = finalize(final)
    return result

# Create job from graph
complex_job = complex_graph.to_job()
```

### Slide 189: Conditional Logic
```python
from dagster import op, graph, job

@op
def condition_op(context):
    # Returns a boolean
    return True

@op
def branch_true_op(context):
    return "True path"

@op
def branch_false_op(context):
    return "False path"

@graph
def conditional_graph():
    condition = condition_op()
    
    # Conditional execution
    true_result = branch_true_op(condition)
    false_result = branch_false_op(condition)
    
    return true_result, false_result
```

### Slide 190: Sub-graphs
```python
from dagster import graph

@graph
def sub_graph1():
    data = load_data()
    processed = process_data(data)
    return processed

@graph
def sub_graph2(data):
    transformed = transform_data(data)
    return transformed

@job
def main_job():
    data = sub_graph1()
    result = sub_graph2(data)
    return result
```

### Slide 191: Hooks
```python
from dagster import hook, HookContext, run_failure_hook

@hook
def log_metadata_hook(context: HookContext):
    context.log.info(f"Op: {context.op.name}")
    context.log.info(f"Run: {context.run_id}")

@run_failure_hook
def notify_failure_hook(context, failure):
    # Send notification
    send_alert(f"Pipeline failed: {failure}")

# Apply hook
@op(hooks={log_metadata_hook})
def logged_op(context):
    return "result"
```

### Slide 192: Custom I/O Manager
```python
from dagster import IOManager, OutputContext, InputContext
import pandas as pd

class PandasParquetIOManager(IOManager):
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
    
    def handle_output(self, context: OutputContext, obj: pd.DataFrame):
        path = self.base_path / f"{context.step_key}.parquet"
        obj.to_parquet(path)
        context.add_output_metadata({"path": str(path)})
    
    def load_input(self, context: InputContext) -> pd.DataFrame:
        path = self.base_path / f"{context.upstream_output.step_key}.parquet"
        return pd.read_parquet(path)
```

### Slide 193: External Services
```python
from dagster import resource

@resource
def slack_resource(context):
    import slack_sdk
    webhook = context.resource_config["webhook_url"]
    return slack_sdk.WebhookClient(webhook)

@op(required_resource_keys={"slack"})
def notify_slack(context):
    client = context.resources.slack
    client.send(text="Pipeline completed!")
```

### Slide 194: Docker Integration
```python
from dagster import job, op
from dagster_docker import docker_executor

@job(executor_def=docker_executor)
def docker_job():
    # Runs in Docker containers
    result = my_op()
    return result

# Docker image
@job(
    executor_def=docker_executor,
    executor_config={
        "docker": {
            "image": "my_image:latest"
        }
    }
)
def custom_docker_job():
    result = my_op()
    return result
```

### Slide 195: Kubernetes Integration
```python
from dagster import job, op
from dagster_k8s import k8s_executor

@job(
    executor_def=k8s_executor,
    executor_config={
        "k8s": {
            "job_namespace": "dagster",
            "image": "my_image:latest"
        }
    }
)
def k8s_job():
    result = my_op()
    return result
```

### Slide 196: Run Configuration
```yaml
# config.yaml
ops:
  my_op:
    config:
      batch_size: 1000
      learning_rate: 0.01
resources:
  db:
    config:
      connection_string: postgresql://user:pass@host/db
```

### Slide 197: Partitioned Pipelines
```python
from dagster import DailyPartitionsDefinition, asset, materialize_partition

@asset(partitions_def=DailyPartitionsDefinition(start_date="2024-01-01"))
def daily_data(context):
    date = context.partition_key
    return load_data_for_date(date)

# Materialize partition
materialize_partition(daily_data, partition_key="2024-01-01")
```

### Slide 198: Scheduled Jobs with Config
```python
@schedule(
    job=my_job,
    cron_schedule="0 0 * * *"
)
def configurable_schedule(context):
    return {
        "ops": {
            "my_op": {
                "config": {
                    "batch_size": 1000,
                    "env": "production"
                }
            }
        },
        "tags": {
            "schedule": "daily",
            "environment": "prod"
        }
    }
```

### Slide 199: Monitoring with Dagster
```python
from dagster import DagsterInstance

instance = DagsterInstance.get()

# Get runs
runs = instance.get_runs(limit=10)

# Get run status
run = instance.get_run_by_id(run_id)
status = run.status

# Get logs
events = instance.get_events(run_id)
```

### Slide 200: Dagster Performance
- Use I/O managers for data
- Use resources for connections
- Batch operations
- Use appropriate concurrency
- Monitor memory usage
- Use partitioned assets
- Optimize Docker images
- Use database indexes
- Clean up old runs
- Use proper logging levels

### Slide 201: Dagster Troubleshooting
- **Issue:** Connection errors
  - Solution: Check resources
- **Issue:** Op failures
  - Solution: Use retry policies
- **Issue:** Slow execution
  - Solution: Optimize ops, use parallelism
- **Issue:** Schedule not running
  - Solution: Check daemon status
- **Issue:** Sensor not triggering
  - Solution: Check cursor, conditions

### Slide 202: Dagster Best Practices Recap
1. Use type annotations
2. Write tests
3. Use resources
4. Define config schemas
5. Use assets
6. Document everything
7. Use schedules
8. Handle errors
9. Monitor runs
10. Version control

### Slide 203: Dagster Common Pitfalls
- ❌ Not using type hints
- ❌ Hardcoding configurations
- ❌ Ignoring dependencies
- ❌ Not testing ops
- ❌ Missing error handling
- ❌ No resource management
- ❌ Poor logging
- ❌ Not monitoring
- ❌ Overly complex graphs
- ❌ Not using I/O managers

### Slide 204: Dagster with DVC
```python
from dagster import op, resource
import dvc.api

@resource
def dvc_resource():
    import dvc.repo
    return dvc.repo.Repo()

@op(required_resource_keys={"dvc"})
def dvc_op(context):
    repo = context.resources.dvc
    repo.pull()
    repo.reproduce()
```

### Slide 205: Dagster Recap
- ✅ Modern orchestration
- ✅ Asset awareness
- ✅ Type safety
- ✅ Rich UI
- ✅ Testing support
- ✅ Integration friendly
- ✅ Production ready

---

## Module 11: Integration (Slides 206-220)

### Slide 206: Complete Integration
```
DVC (Data Version) → MLflow (Track) → Dagster (Orchestrate)
         ↓                  ↓                  ↓
    Data Version      Experiment        Pipeline
         ↓                  ↓                  ↓
    Raw Data           Model             Deployment
         ↓                  ↓                  ↓
    Processed          Registry          Production
```

### Slide 207: End-to-End Flow
```
1. Data Ingestion (DVC)
2. Data Versioning (DVC)
3. Feature Engineering (DVC)
4. Experiment Tracking (MLflow)
5. Model Training (MLflow)
6. Model Registry (MLflow)
7. Pipeline Orchestration (Dagster)
8. Deployment (CI/CD)
9. Monitoring (MLflow + Dagster)
10. Alerting (Monitoring)
```

### Slide 208: Unified Architecture
```
┌─────────────────────────────────────────────────────┐
│              Complete MLOps Architecture            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │          Dagster Orchestration              │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │  │
│  │  │Schedule  │  │ Sensors  │  │   Jobs   │  │  │
│  │  └──────────┘  └──────────┘  └──────────┘  │  │
│  └──────────────────────────────────────────────┘  │
│              ↓                   ↓                 │
│  ┌──────────────────────────────────────────────┐  │
│  │      DVC + MLflow + Registry               │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │  │
│  │  │  DVC     │  │ MLflow   │  │Registry  │  │  │
│  │  │ Version  │  │ Tracking │  │  Models  │  │  │
│  │  └──────────┘  └──────────┘  └──────────┘  │  │
│  └──────────────────────────────────────────────┘  │
│              ↓                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │         Deployment & Monitoring             │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │  │
│  │  │  API     │  │  Batch   │  │  Alerts  │  │  │
│  │  └──────────┘  └──────────┘  └──────────┘  │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Slide 209: Data Pipeline
```yaml
# Complete data pipeline
data:
  sources:
    - type: "synthetic"
      parameters:
        hours: 48
        anomaly_rate: 0.05
  validation:
    schema: "configs/schema.json"
    quality: ["no_missing", "no_duplicates"]
  features:
    windows: [5, 10, 30]
    interactions: true
    selection: "feature_importance"
```

### Slide 210: Training Pipeline
```yaml
# Model training pipeline
model:
  algorithms:
    - random_forest
    - gradient_boosting
    - logistic_regression
  hyperparameters:
    random_forest:
      n_estimators: [50, 100, 200]
      max_depth: [5, 10, 20]
  evaluation:
    metrics: ["accuracy", "f1", "precision", "recall"]
    cv: 5
  selection:
    metric: "f1"
    minimize: false
```

### Slide 211: Deployment Pipeline
```yaml
# Deployment pipeline
deployment:
  stages:
    - staging
    - production
  strategy: "blue-green"
  validation:
    tests: ["smoke", "performance", "integration"]
    threshold: 0.85
  rollback:
    enabled: true
    max_attempts: 3
  monitoring:
    metrics: ["latency", "throughput", "error_rate"]
    alerts: ["Slack", "Email"]
```

### Slide 212: CI/CD Integration
```yaml
# CI/CD pipeline
name: MLOps CI/CD
on: [push, schedule]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: pytest tests/
  
  train:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Pull data
        run: dvc pull
      - name: Train model
        run: python train.py
      - name: Register model
        run: python register.py
  
  deploy:
    needs: train
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to staging
        run: python deploy.py --env staging
      - name: Promote to production
        run: python promote.py --env production
```

### Slide 213: Complete Flow Example
```python
# Complete MLOps pipeline
@job
def full_mlops_pipeline():
    # 1. Data ingestion
    raw = ingest_data()
    
    # 2. Validation
    validated = validate_data(raw)
    
    # 3. Feature engineering
    features = engineer_features(validated)
    
    # 4. Model training
    model = train_model(features)
    
    # 5. Evaluation
    metrics = evaluate_model(model, features)
    
    # 6. Registry
    registered = register_model(model, metrics)
    
    # 7. Deployment
    deploy_model(registered)
    
    # 8. Monitoring
    monitor_deployment(registered)
```

### Slide 214: Integration Benefits
- **End-to-end traceability**
- **Automated workflows**
- **Reproducibility**
- **Governance**
- **Scalability**
- **Reduced time to production**
- **Improved collaboration**
- **Better quality**
- **Cost savings**

### Slide 215: Common Integration Challenges
- **Data consistency:** DVC + MLflow + Dagster
- **Version management:** Code + Data + Models
- **State management:** Pipeline state + Model state
- **Error handling:** Multiple failure points
- **Performance:** Resource intensive
- **Complexity:** Multiple tools to manage

### Slide 216: Integration Best Practices
1. Start simple, add complexity
2. Use consistent naming
3. Implement idempotency
4. Add robust error handling
5. Monitor everything
6. Use version control
7. Document integration
8. Test end-to-end
9. Automate where possible
10. Plan for rollback

### Slide 217: Integration Troubleshooting
- **Data not updating:** Check DVC push/pull
- **Experiments not tracking:** Check MLflow URI
- **Pipeline not running:** Check Dagster daemon
- **Models not deploying:** Check registry status
- **Monitoring not working:** Check configuration

### Slide 218: Integration Security
- **Access Control:** RBAC
- **Secrets Management:** Environment variables, Vault
- **Data Encryption:** At rest, in transit
- **Audit Logging:** All operations
- **Network Security:** Firewalls, VPN
- **Authentication:** OAuth, JWT

### Slide 219: Production Checklist
- ✅ Data versioned (DVC)
- ✅ Experiments tracked (MLflow)
- ✅ Models registered (Registry)
- ✅ Pipeline automated (Dagster)
- ✅ Deployment automated (CI/CD)
- ✅ Monitoring enabled (Monitoring)
- ✅ Alerts configured (Alerting)
- ✅ Security implemented (Security)
- ✅ Documentation complete (Docs)
- ✅ Team trained (Training)

### Slide 220: Recap: Integration
- ✅ DVC: Data versioning
- ✅ MLflow: Experiment tracking
- ✅ Dagster: Pipeline orchestration
- ✅ Registry: Model management
- ✅ CI/CD: Automated deployment
- ✅ Monitoring: Observability

---

# SECTION 5: PRODUCTION & DEPLOYMENT (Slides 221-260)

---

## Module 12: Production Considerations (Slides 221-240)

### Slide 221: Production Mindset
- **Reliability:** Always available
- **Performance:** Fast enough
- **Scalability:** Handles load
- **Security:** Protected
- **Observability:** Monitored
- **Maintainability:** Easy to update
- **Cost-effective:** Efficient

### Slide 222: Production vs. Development
```
Development                Production
───────────                ──────────
Experiment                Stability
Speed                     Reliability
Flexibility               Consistency
Debugging                Observability
Bleeding edge            Battle-tested
Quick iteration          Careful validation
```

### Slide 223: Production Requirements
- **Uptime:** 99.9%+
- **Latency:** <100ms
- **Throughput:** 1000+ req/s
- **Error Rate:** <1%
- **Data Freshness:** <1 hour
- **Model Accuracy:** >90%
- **Recovery Time:** <5 minutes

### Slide 224: Scalability
```python
# Horizontal scaling
app = FastAPI()
workers = 4
uvicorn.run(app, host="0.0.0.0", port=8000, workers=workers)

# Vertical scaling
# Increase memory, CPU, disk

# Auto-scaling
from kubernetes import client, autoscaling
autoscaling.v1.HorizontalPodAutoscaler(
    min_replicas=2,
    max_replicas=10,
    target_cpu_utilization_percentage=70
)
```

### Slide 225: High Availability
```
┌─────────────────────────────────────┐
│         High Availability           │
├─────────────────────────────────────┤
│                                     │
│  Load Balancer                      │
│      ↓                              │
│  ┌─────┐  ┌─────┐  ┌─────┐       │
│  │ Pod1 │  │ Pod2 │  │ Pod3 │       │
│  └─────┘  └─────┘  └─────┘       │
│      ↓        ↓        ↓          │
│  Shared Storage (S3/PostgreSQL)   │
│                                     │
└─────────────────────────────────────┘
```

### Slide 226: Disaster Recovery
- **Backups:** Regular automated backups
- **Replication:** Multiple copies
- **Failover:** Automatic switching
- **Testing:** Regular DR tests
- **RPO:** Recovery point objective
- **RTO:** Recovery time objective

### Slide 227: Security Layers
```
Layer 1: Network (Firewall, VPC)
Layer 2: Authentication (OAuth, JWT)
Layer 3: Authorization (RBAC)
Layer 4: Data (Encryption)
Layer 5: Application (Input validation)
Layer 6: Monitoring (Audit logs)
```

### Slide 228: Secrets Management
```python
# Never hardcode secrets
# Use environment variables
DB_PASSWORD = os.environ.get('DB_PASSWORD')

# Use secret management tools
import boto3
client = boto3.client('secretsmanager')
secret = client.get_secret_value(SecretId='db_password')

# Use HashiCorp Vault
import hvac
client = hvac.Client(url='http://vault:8200')
secret = client.secrets.kv.v2.read_secret_version(path='db_password')
```

### Slide 229: Monitoring Stack
```
Prometheus → Metrics Collection
Grafana → Visualization
ELK Stack → Logs (Elasticsearch, Logstash, Kibana)
Jaeger → Distributed Tracing
Alertmanager → Alerting
```

### Slide 230: Logging Strategy
```python
# Structured logging
import structlog
logger = structlog.get_logger()

logger.info(
    "Request processed",
    request_id=request_id,
    latency_ms=latency,
    status_code=200,
    model_version="v1.0.0"
)

# Log levels
DEBUG: Development debugging
INFO: General information
WARNING: Warning conditions
ERROR: Error conditions
CRITICAL: Critical failures
```

### Slide 231: Metrics to Monitor
```
System Metrics:
- CPU usage
- Memory usage
- Disk usage
- Network I/O

Application Metrics:
- Request count
- Response time
- Error rate
- Throughput

Model Metrics:
- Prediction accuracy
- Latency
- Drift score
- Confidence scores

Business Metrics:
- Predictions per day
- Prediction distribution
- Business impact
```

### Slide 232: Alerting Strategy
```python
# Define alert rules
alerts = {
    "high_latency": {
        "condition": "latency_p95 > 100ms",
        "severity": "warning",
        "action": "Slack notification"
    },
    "model_drift": {
        "condition": "drift_score > 0.5",
        "severity": "critical",
        "action": "PagerDuty"
    },
    "pipeline_failure": {
        "condition": "pipeline_status == 'failed'",
        "severity": "critical",
        "action": "Email + Slack"
    }
}
```

### Slide 233: Incident Response
```
1. Detection: Alert triggered
2. Triage: Assess severity
3. Investigation: Find root cause
4. Mitigation: Stop the bleeding
5. Resolution: Fix the issue
6. Post-mortem: Document and learn
7. Prevention: Implement fixes
```

### Slide 234: Model Drift Detection
```python
def detect_drift(old_data, new_data, threshold=0.05):
    for col in old_data.columns:
        stat, p_value = ks_2samp(old_data[col], new_data[col])
        if p_value < threshold:
            return True, col, p_value
    return False, None, None

def detect_concept_drift(old_predictions, new_predictions):
    old_dist = old_predictions.value_counts(normalize=True)
    new_dist = new_predictions.value_counts(normalize=True)
    return old_dist != new_dist
```

### Slide 235: Model Retraining Strategy
```
Trigger Types:
- Scheduled (Daily/Weekly)
- Data-based (New data available)
- Performance-based (Accuracy drops)
- Business-based (New requirements)

Strategies:
- Incremental: Update existing model
- Full: Retrain from scratch
- Ensemble: Combine old + new
- Hybrid: Partial retraining
```

### Slide 236: A/B Testing
```
┌─────────────────────────────────────┐
│           A/B Testing               │
├─────────────────────────────────────┤
│                                     │
│  50% → Model A (Current)           │
│  50% → Model B (New)               │
│       ↓                            │
│  Collect metrics for both          │
│       ↓                            │
│  Compare performance               │
│       ↓                            │
│  If B better: Rollout fully        │
│  If B worse: Rollback              │
│                                     │
└─────────────────────────────────────┘
```

### Slide 237: Canary Deployment
```
┌─────────────────────────────────────┐
│         Canary Deployment           │
├─────────────────────────────────────┤
│                                     │
│  Step 1: 1% traffic to new model   │
│  Step 2: Monitor metrics           │
│  Step 3: 10% traffic               │
│  Step 4: Monitor metrics           │
│  Step 5: 50% traffic               │
│  Step 6: Monitor metrics           │
│  Step 7: 100% traffic              │
│  Step 8: Old model retired         │
│                                     │
└─────────────────────────────────────┘
```

### Slide 238: Blue-Green Deployment
```
┌─────────────────────────────────────┐
│        Blue-Green Deployment        │
├─────────────────────────────────────┤
│                                     │
│  Blue: Production (Active)         │
│  Green: New version (Inactive)     │
│         ↓                          │
│  1. Deploy to Green                │
│  2. Test Green                     │
│  3. Switch traffic to Green        │
│  4. Blue becomes inactive          │
│  5. Rollback: Switch to Blue       │
│                                     │
└─────────────────────────────────────┘
```

### Slide 239: Cost Optimization
- **Compute:** Right-size instances
- **Storage:** Use appropriate tiers
- **Data:** Compress where possible
- **Network:** Minimize data transfer
- **Monitoring:** Collect what's needed
- **Automation:** Reduce manual work
- **Spot instances:** For training
- **Serverless:** For variable workloads

### Slide 240: Production Checklist
- ✅ Requirements defined
- ✅ Architecture designed
- ✅ Security implemented
- ✅ Monitoring configured
- ✅ Alerts set up
- ✅ Testing complete
- ✅ Documentation ready
- ✅ Team trained
- ✅ Rollback plan ready
- ✅ Go/No-go decision

---

## Module 13: Deployment Strategies (Slides 241-260)

### Slide 241: Deployment Options
- **REST API:** HTTP endpoints
- **Batch:** Scheduled jobs
- **Streaming:** Real-time
- **Edge:** IoT devices
- **Mobile:** Apps
- **Serverless:** Functions
- **Containerized:** Docker/Kubernetes

### Slide 242: REST API Deployment
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

# Serve
# uvicorn app:app --host 0.0.0.0 --port 8000
```

### Slide 243: Batch Deployment
```python
import pandas as pd
import mlflow

def run_batch_prediction():
    # Load model
    model = mlflow.sklearn.load_model("models:/model/Production")
    
    # Load data
    df = pd.read_csv("data/batch_input.csv")
    
    # Predict
    predictions = model.predict(df)
    
    # Save results
    df['prediction'] = predictions
    df.to_csv("data/batch_output.csv", index=False)

# Schedule with Dagster
@schedule(job=batch_job, cron_schedule="0 0 * * *")
def batch_schedule(context):
    return {}
```

### Slide 244: Serverless Deployment
```python
# AWS Lambda
import mlflow
import boto3

def handler(event, context):
    # Load model from S3
    model = mlflow.sklearn.load_model("s3://bucket/model")
    
    # Predict
    features = event['features']
    prediction = model.predict([features])
    
    return {
        'statusCode': 200,
        'body': {'prediction': prediction.tolist()}
    }
```

### Slide 245: Containerized Deployment
```dockerfile
# Dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Slide 246: Kubernetes Deployment
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: model-api
  template:
    metadata:
      labels:
        app: model-api
    spec:
      containers:
      - name: model-api
        image: model-api:latest
        ports:
        - containerPort: 8000
        env:
        - name: MLFLOW_TRACKING_URI
          value: "http://mlflow:5000"
```

### Slide 247: Model Serving Platforms
- **Seldon Core:** Kubernetes-native
- **KFServing:** Serverless
- **BentoML:** Framework agnostic
- **Triton:** NVIDIA inference server
- **TorchServe:** PyTorch
- **TensorFlow Serving:** TensorFlow
- **MLflow:** General purpose

### Slide 248: CI/CD Pipeline
```yaml
# Complete CI/CD pipeline
stages:
  - test
  - build
  - deploy-staging
  - test-staging
  - deploy-production
  - monitor

variables:
  DOCKER_IMAGE: registry/model-api
  MLFLOW_TRACKING_URI: http://mlflow:5000

test:
  stage: test
  script:
    - pytest tests/

build:
  stage: build
  script:
    - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHA .
    - docker push $DOCKER_IMAGE:$CI_COMMIT_SHA

deploy-staging:
  stage: deploy-staging
  script:
    - kubectl set image deployment/model-api model-api=$DOCKER_IMAGE:$CI_COMMIT_SHA -n staging

test-staging:
  stage: test-staging
  script:
    - python scripts/test_api.py --env staging

deploy-production:
  stage: deploy-production
  script:
    - kubectl set image deployment/model-api model-api=$DOCKER_IMAGE:$CI_COMMIT_SHA -n production

monitor:
  stage: monitor
  script:
    - python scripts/monitor.py
```

### Slide 249: Rollback Strategy
```bash
# Kubernetes rollback
kubectl rollout undo deployment/model-api

# Docker rollback
docker run -d --name model-api-old $DOCKER_IMAGE:$OLD_VERSION
docker stop model-api
docker start model-api-old

# Model registry rollback
mlflow models serve -m models:/model/v0.9.0
```

### Slide 250: Traffic Management
```python
# Traffic splitting
def route_traffic(request):
    import random
    if random.random() < 0.9:
        return predict_v1(request)
    else:
        return predict_v2(request)

# Weighted routing
weights = {
    "model_v1": 0.9,
    "model_v2": 0.1
}
```

### Slide 251: Performance Testing
```python
import time
import requests
from concurrent.futures import ThreadPoolExecutor

def test_performance(endpoint, requests=1000, concurrency=10):
    def make_request():
        start = time.time()
        response = requests.post(endpoint, json={"features": [1, 2, 3]})
        return time.time() - start
    
    with ThreadPoolExecutor(max_workers=concurrency) as executor:
        latencies = list(executor.map(make_request, range(requests)))
    
    return {
        "p50": np.percentile(latencies, 50),
        "p95": np.percentile(latencies, 95),
        "p99": np.percentile(latencies, 99),
        "mean": np.mean(latencies),
        "max": np.max(latencies)
    }
```

### Slide 252: Load Testing
```bash
# Locust
locust -f locustfile.py --host http://api:8000

# Vegeta
echo "POST http://api:8000/predict" | vegeta attack -duration=60s -rate=100 | vegeta report

# Apache Bench
ab -n 1000 -c 10 -p payload.json -T application/json http://api:8000/predict
```

### Slide 253: Monitoring Deployment
```python
class DeploymentMonitor:
    def __init__(self):
        self.metrics = {
            "requests": 0,
            "errors": 0,
            "latencies": []
        }
    
    def record_request(self, latency, error=False):
        self.metrics["requests"] += 1
        if error:
            self.metrics["errors"] += 1
        self.metrics["latencies"].append(latency)
    
    def get_metrics(self):
        return {
            "total_requests": self.metrics["requests"],
            "error_rate": self.metrics["errors"] / self.metrics["requests"],
            "avg_latency": np.mean(self.metrics["latencies"]),
            "p95_latency": np.percentile(self.metrics["latencies"], 95)
        }
```

### Slide 254: Logging in Production
```python
import logging
from pythonjsonlogger import jsonlogger

# JSON logging
logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
handler.setFormatter(formatter)
logger.addHandler(handler)

# Log structured data
logger.info(
    "Prediction made",
    extra={
        "request_id": request_id,
        "model_version": model_version,
        "latency_ms": latency,
        "features": features,
        "prediction": prediction
    }
)
```

### Slide 255: Production Dashboards
```
┌─────────────────────────────────────┐
│         Production Dashboard        │
├─────────────────────────────────────┤
│                                     │
│  Model Performance                  │
│  ─────────────────                │
│  Accuracy: 0.95 ↑                  │
│  F1: 0.93 →                        │
│  Latency: 45ms ↓                   │
│                                     │
│  System Health                      │
│  ─────────────────                │
│  CPU: 45%                          │
│  Memory: 60%                       │
│  Disk: 30%                         │
│                                     │
│  Alerts                            │
│  ─────────────────                │
│  ⚠️ Latency spike detected         │
│  ✅ All systems normal             │
│                                     │
└─────────────────────────────────────┘
```

### Slide 256: Post-Deployment Steps
1. Monitor logs
2. Check metrics
3. Validate predictions
4. Test edge cases
5. Verify performance
6. Update documentation
7. Notify stakeholders
8. Review alerts
9. Plan next iteration
10. Celebrate success

### Slide 257: Deployment Checklist
- ✅ Code reviewed
- ✅ Tests passed
- ✅ Model validated
- ✅ Performance tested
- ✅ Security reviewed
- ✅ Documentation updated
- ✅ Rollback plan ready
- ✅ Monitoring configured
- ✅ Alerts set up
- ✅ Stakeholders notified

### Slide 258: Common Deployment Pitfalls
- ❌ No rollback plan
- ❌ Insufficient testing
- ❌ Missing monitoring
- ❌ Poor error handling
- ❌ Hardcoded values
- ❌ No versioning
- ❌ Not documenting
- ❌ Skipping staging
- ❌ Forgetting security
- ❌ Not scaling properly

### Slide 259: Deployment Recap
- ✅ Multiple strategies available
- ✅ Choose based on needs
- ✅ Always have rollback
- ✅ Monitor everything
- ✅ Test thoroughly
- ✅ Document clearly
- ✅ Automate where possible
- ✅ Plan for failure

### Slide 260: Production Recap
- ✅ Reliability matters
- ✅ Performance matters
- ✅ Security matters
- ✅ Monitoring matters
- ✅ Scalability matters
- ✅ Documentation matters
- ✅ Testing matters
- ✅ Team matters

---

# SECTION 6: CONCLUSION & NEXT STEPS (Slides 261-280)

---

## Module 14: Course Summary (Slides 261-280)

### Slide 261: Journey Recap
```
Phase 1: Data Versioning (DVC)
   ↓
Phase 2: Experiment Tracking (MLflow)
   ↓
Phase 3: Pipeline Orchestration (Dagster)
   ↓
Phase 4: Integration & Deployment
   ↓
Production MLOps System
```

### Slide 262: What We Built
- ✅ Data versioning with DVC
- ✅ Experiment tracking with MLflow
- ✅ Model registry with MLflow
- ✅ Pipeline orchestration with Dagster
- ✅ End-to-end automation
- ✅ Production deployment
- ✅ Monitoring and alerting
- ✅ CI/CD pipeline

### Slide 263: Key Learnings
1. **Data Versioning:** Track everything
2. **Experiment Tracking:** Log everything
3. **Pipeline Orchestration:** Automate everything
4. **Production:** Monitor everything
5. **Security:** Protect everything
6. **Documentation:** Document everything

### Slide 264: The MLOps Mindset
- Think production-first
- Plan for failure
- Automate everything
- Monitor continuously
- Document thoroughly
- Test rigorously
- Iterate constantly

### Slide 265: Common Mistakes We Learned
- ❌ Ignoring data versioning
- ❌ Not tracking experiments
- ❌ Manual pipeline execution
- ❌ No model registry
- ❌ No monitoring
- ❌ Poor security
- ❌ No documentation
- ❌ Not testing

### Slide 266: Success Factors
1. **Reproducibility:** Every run reproducible
2. **Automation:** Everything automated
3. **Monitoring:** Everything monitored
4. **Documentation:** Everything documented
5. **Security:** Everything secured
6. **Testing:** Everything tested

### Slide 267: Best Practices Recap
```
DVC:
- Version raw data
- Use remote storage
- Automate pipelines
- Track metrics

MLflow:
- Track all experiments
- Log parameters/metrics
- Use model registry
- Stage models

Dagster:
- Define assets
- Orchestrate pipelines
- Handle errors
- Monitor runs

Deployment:
- Automate deployments
- Use blue-green
- Monitor continuously
- Have rollback plan
```

### Slide 268: Tools Recap
```
DVC        → Data Versioning
MLflow     → Experiment Tracking
Model Registry → Model Management
Dagster    → Pipeline Orchestration
Git        → Code Versioning
Docker     → Containerization
Kubernetes → Orchestration
Prometheus → Monitoring
Grafana    → Visualization
```

### Slide 269: Architecture Evolution
```
Development:    Jupyter Notebooks
                ↓
Staging:        Scripts + Git
                ↓
Production:     DVC + MLflow + Dagster
                ↓
Enterprise:     Full MLOps Platform
```

### Slide 270: Next Steps
1. **Practice:** Apply to your projects
2. **Extend:** Add more features
3. **Optimize:** Improve performance
4. **Scale:** Handle more data
5. **Automate:** Reduce manual steps
6. **Monitor:** Add more metrics
7. **Secure:** Enhance security
8. **Document:** Create docs
9. **Share:** Help others
10. **Iterate:** Keep improving

### Slide 271: Advanced Topics
- **Feature Stores:** Feast, Tecton
- **Data Quality:** Great Expectations
- **Workflow:** Kubeflow, Airflow
- **Monitoring:** Prometheus, Grafana
- **Logging:** ELK Stack
- **Tracing:** Jaeger
- **Security:** Vault, OAuth
- **Cost:** Optimizations

### Slide 272: Continuous Learning
- **Books:**
  - "Machine Learning Engineering"
  - "Designing Data-Intensive Applications"
  - "The DevOps Handbook"

- **Courses:**
  - Coursera MLOps
  - DataCamp MLOps
  - DeepLearning.AI

- **Resources:**
  - MLflow Documentation
  - DVC Documentation
  - Dagster Documentation

### Slide 273: Community
- **Slack:** MLflow, DVC, Dagster
- **Discord:** Data Science
- **Reddit:** r/mlops, r/datascience
- **GitHub:** Open source projects
- **Meetups:** Local MLOps groups
- **Conferences:** MLflow Summit, DVC Summit

### Slide 274: Contribution Paths
- **Documentation:** Improve docs
- **Bug Reports:** Report issues
- **Feature Requests:** Suggest features
- **Code Contributions:** Submit PRs
- **Tutorials:** Create content
- **Talks:** Present at events

### Slide 275: Career Paths
- **ML Engineer:** Build pipelines
- **Data Engineer:** Manage data
- **MLOps Engineer:** Infrastructure
- **DevOps Engineer:** Operations
- **Data Scientist:** Models
- **Platform Engineer:** Platform

### Slide 276: Skills for the Future
- Python
- Docker/Kubernetes
- Cloud platforms (AWS, GCP, Azure)
- Data versioning (DVC)
- Experiment tracking (MLflow)
- Pipeline orchestration (Dagster)
- Monitoring (Prometheus/Grafana)
- Security (Best practices)

### Slide 277: Project Portfolio
- Predictive maintenance system
- End-to-end MLOps pipeline
- Model registry
- Automated deployment
- Monitoring dashboard
- CI/CD pipeline

### Slide 278: Interview Preparation
- Explain MLOps concepts
- Demonstrate tool knowledge
- Show system design
- Discuss best practices
- Share real experience
- Prepare architecture diagrams
- Practice coding

### Slide 279: Final Thoughts
- **Start simple:** Add complexity gradually
- **Iterate:** Keep improving
- **Learn:** Always learning
- **Share:** Help others
- **Automate:** Reduce manual work
- **Monitor:** Stay aware
- **Document:** Write everything

### Slide 280: Thank You
- Questions?
- Feedback?
- Resources available
- Stay in touch
- Happy MLOps!

---

# SECTION 7: APPENDICES (Slides 281-300+)

---

## Appendix A: Code References (Slides 281-290)

### Slide 281: DVC Reference
```bash
# Common DVC commands
dvc init
dvc add <file>
dvc push
dvc pull
dvc checkout
dvc status
dvc remote add
dvc repro
dvc dag
dvc metrics
```

### Slide 282: DVC Pipeline Example
```yaml
# dvc.yaml
stages:
  generate:
    cmd: python generate.py
    deps: [generate.py]
    outs: [data/raw/data.csv]
  
  process:
    cmd: python process.py
    deps: [process.py, data/raw/data.csv]
    outs: [data/processed/data.csv]
  
  train:
    cmd: python train.py
    deps: [train.py, data/processed/data.csv]
    outs: [models/model.pkl]
```

### Slide 283: MLflow Reference
```python
# Common MLflow commands
import mlflow

mlflow.set_tracking_uri()
mlflow.set_experiment()
mlflow.start_run()
mlflow.log_param()
mlflow.log_metric()
mlflow.log_artifact()
mlflow.sklearn.log_model()
mlflow.sklearn.load_model()
```

### Slide 284: MLflow Registry Example
```python
from mlflow.tracking import MlflowClient

client = MlflowClient()

# Register model
client.create_model_version(
    name="model",
    source="runs:/run_id/model",
    run_id="run_id"
)

# Transition stage
client.transition_model_version_stage(
    name="model",
    version=1,
    stage="Production"
)

# Get latest
latest = client.get_latest_versions("model")
```

### Slide 285: Dagster Reference
```python
from dagster import op, asset, job, schedule

@op
def my_op():
    return "result"

@asset
def my_asset():
    return "data"

@job
def my_job():
    result = my_op()
    return result

@schedule(job=my_job, cron_schedule="0 0 * * *")
def my_schedule():
    return {}
```

### Slide 286: Dagster Pipeline Example
```python
@op
def load_data():
    return pd.read_csv("data.csv")

@op
def process_data(data):
    return data * 2

@op
def train_model(data):
    model = RandomForestClassifier()
    model.fit(data)
    return model

@job
def ml_pipeline():
    data = load_data()
    processed = process_data(data)
    model = train_model(processed)
    return model
```

### Slide 287: FastAPI Reference
```python
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class PredictRequest(BaseModel):
    features: list

@app.post("/predict")
def predict(request: PredictRequest):
    prediction = model.predict([request.features])
    return {"prediction": prediction.tolist()}
```

### Slide 288: Testing Reference
```python
# pytest example
def test_op():
    context = build_op_context()
    result = my_op(context)
    assert result == expected

def test_job():
    result = execute_job(my_job)
    assert result.success

def test_model():
    model = load_model()
    predictions = model.predict(test_data)
    assert accuracy(predictions, labels) > 0.85
```

### Slide 289: Deployment Reference
```bash
# Deploy model
python scripts/deploy_model.py --model model.pkl --env production

# Blue-green deploy
python scripts/blue_green_deploy.py --model model.pkl

# Verify deployment
python scripts/verify_deployment.py --endpoint https://api.example.com

# Promote model
python scripts/promote_model.py promote --model my_model --version 1
```

### Slide 290: Monitoring Reference
```python
# Monitor metrics
monitor = PipelineMonitor()
monitor.add_metric("accuracy", 0.95)
monitor.add_metric("latency", 45)

# Set alerts
monitor.register_alert_rule(
    name="high_latency",
    condition=lambda m: m.value > 100,
    severity="warning"
)

# Send alert
monitor.send_alert(alert)
```

---

## Appendix B: Troubleshooting (Slides 291-295)

### Slide 291: DVC Troubleshooting
```
Issue: Cache corruption
Solution: dvc cache verify; dvc gc --force

Issue: Remote connection failed
Solution: Check credentials; Check network

Issue: Pipeline not updating
Solution: dvc status --checks; dvc repro --force

Issue: Large cache
Solution: dvc gc --workspace

Issue: Lock conflicts
Solution: git pull; dvc pull; dvc repro
```

### Slide 292: MLflow Troubleshooting
```
Issue: Connection refused
Solution: Check tracking URI; Start server

Issue: Duplicate runs
Solution: Use unique run names

Issue: Large artifacts
Solution: Use multipart upload

Issue: Slow UI
Solution: Use PostgreSQL backend

Issue: Missing artifacts
Solution: Check artifact path
```

### Slide 293: Dagster Troubleshooting
```
Issue: Connection errors
Solution: Check resources

Issue: Op failures
Solution: Use retry policies

Issue: Slow execution
Solution: Optimize ops; Use parallelism

Issue: Schedule not running
Solution: Check daemon status

Issue: Sensor not triggering
Solution: Check cursor; Check conditions
```

### Slide 294: Deployment Troubleshooting
```
Issue: Model not loading
Solution: Check path; Check dependencies

Issue: API not responding
Solution: Check port; Check service

Issue: Performance issues
Solution: Scale horizontally; Optimize code

Issue: Deployment failure
Solution: Rollback; Check logs

Issue: Monitoring not working
Solution: Check configuration; Check permissions
```

### Slide 295: General Troubleshooting
```
1. Check logs
2. Check configuration
3. Check permissions
4. Check network
5. Check dependencies
6. Check versions
7. Check environment
8. Check resources
9. Check code
10. Check documentation
```

---

## Appendix C: Resources (Slides 296-300)

### Slide 296: Official Documentation
- **DVC:** https://dvc.org/doc
- **MLflow:** https://mlflow.org/docs
- **Dagster:** https://docs.dagster.io
- **FastAPI:** https://fastapi.tiangolo.com
- **Kubernetes:** https://kubernetes.io/docs
- **Docker:** https://docs.docker.com

### Slide 297: Learning Resources
- **Books:**
  - "Machine Learning Engineering"
  - "Designing Data-Intensive Applications"
  - "The DevOps Handbook"
- **Courses:**
  - Coursera: MLOps
  - DeepLearning.AI: ML Engineering
  - DataCamp: MLOps
- **Blogs:**
  - MLOps Community
  - Towards Data Science
  - Analytics Vidhya

### Slide 298: Community
- **Slack Communities:**
  - MLflow
  - DVC
  - Dagster
- **Discord:**
  - Data Science
  - Machine Learning
- **Reddit:**
  - r/mlops
  - r/datascience
- **GitHub:**
  - Open source contributions
  - Issue tracking

### Slide 299: Tools and Services
- **Cloud Platforms:**
  - AWS
  - Google Cloud
  - Azure
- **CI/CD:**
  - GitHub Actions
  - GitLab CI
  - Jenkins
- **Monitoring:**
  - Prometheus
  - Grafana
  - ELK Stack
- **Security:**
  - Vault
  - OAuth
  - JWT

### Slide 300: Series Recap
✅ Data Versioning with DVC
✅ Experiment Tracking with MLflow
✅ Model Registry
✅ Pipeline Orchestration with Dagster
✅ End-to-End Integration
✅ Production Deployment
✅ Monitoring and Alerting
✅ CI/CD Pipeline
✅ Best Practices
✅ Real-World Examples

---

# SECTION 8: APPENDICES CONTINUED (Slides 301-320)

## Appendix D: Architecture Diagrams (Slides 301-305)

### Slide 301: Complete System Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                      COMPLETE MLOPS SYSTEM                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              DATA SOURCES                                │  │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐              │  │
│  │  │Sensors│  │Files │  │API   │  │DB    │              │  │
│  │  └──────┘  └──────┘  └──────┘  └──────┘              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              DAGSTER ORCHESTRATION                       │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │  Schedules │  │  Sensors   │  │   Jobs     │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              DVC + MLflow + REGISTRY                    │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │ Data       │  │ Experiment │  │ Model      │       │  │
│  │  │ Versioning │  │ Tracking   │  │ Registry   │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              DEPLOYMENT TARGETS                          │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │ REST API   │  │ Batch Jobs │  │ Edge       │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              MONITORING + ALERTING                       │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐       │  │
│  │  │ Metrics    │  │ Logs       │  │ Alerts     │       │  │
│  │  └────────────┘  └────────────┘  └────────────┘       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Slide 302: Data Flow
```
┌─────────────────────────────────────────────────────────────────┐
│                      DATA FLOW DIAGRAM                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Raw Data ──→ Validation ──→ Feature Engineering              │
│    ↓              ↓               ↓                            │
│  DVC Add      Check Schema    DVC Version                     │
│    ↓              ↓               ↓                            │
│  ──────────────────────────────────────                       │
│  ↓                                                             │
│  Training Data ──→ Model Training ──→ Model Evaluation        │
│    ↓                   ↓                   ↓                   │
│  MLflow Track      MLflow Log        Registry Stage           │
│    ↓                   ↓                   ↓                   │
│  ──────────────────────────────────────                       │
│  ↓                                                             │
│  Model Registry ──→ Deployment ──→ Monitoring                │
│    ↓                  ↓               ↓                        │
│  Version          Blue-Green        Metrics/Alerts            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Slide 303: CI/CD Pipeline Flow
```
┌─────────────────────────────────────────────────────────────────┐
│                     CI/CD PIPELINE FLOW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Code Push                                                      │
│  ↓                                                             │
│  Unit Tests ──→ Integration Tests ──→ Data Validation         │
│    ↓                    ↓                    ↓                  │
│  ──────────────────────────────────────                       │
│  ↓                                                             │
│  Build ──→ Model Training ──→ Model Evaluation               │
│    ↓              ↓                   ↓                        │
│  ──────────────────────────────────────                       │
│  ↓                                                             │
│  Staging Deploy ──→ Smoke Tests ──→ Performance Tests         │
│    ↓                    ↓                    ↓                  │
│  ──────────────────────────────────────                       │
│  ↓                                                             │
│  Production Deploy ──→ Health Check ──→ Monitor              │
│    ↓                    ↓                    ↓                  │
│  ──────────────────────────────────────                       │
│  ↓                                                             │
│  Completed                                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Slide 304: Technology Stack
```
┌─────────────────────────────────────────────────────────────────┐
│                     TECHNOLOGY STACK                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LANGUAGES & FRAMEWORKS                                        │
│  ────────────────────                                         │
│  Python 3.10+                                                  │
│  FastAPI                                                       │
│  Pandas/Numpy                                                  │
│  Scikit-learn                                                  │
│                                                                 │
│  VERSIONING & TRACKING                                         │
│  ────────────────────                                         │
│  Git                                                           │
│  DVC                                                           │
│  MLflow                                                        │
│                                                                 │
│  ORCHESTRATION                                                 │
│  ─────────────                                                 │
│  Dagster                                                       │
│  Schedules                                                     │
│  Sensors                                                       │
│                                                                 │
│  DEPLOYMENT                                                    │
│  ──────────                                                    │
│  Docker                                                        │
│  Kubernetes                                                    │
│  GitHub Actions                                                │
│                                                                 │
│  MONITORING                                                    │
│  ──────────                                                    │
│  Prometheus                                                    │
│  Grafana                                                       │
│  ELK Stack                                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Slide 305: Deployment Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │                    Load Balancer                       │   │
│  └────────────────────────────────────────────────────────┘   │
│                           │                                    │
│  ┌─────────────┬─────────┼─────────┬─────────────┐          │
│  ↓             ↓         ↓         ↓             ↓          │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐          │
│  │Pod 1 │  │Pod 2 │  │Pod 3 │  │Pod 4 │  │Pod 5 │          │
│  │Model │  │Model │  │Model │  │Model │  │Model │          │
│  │API   │  │API   │  │API   │  │API   │  │API   │          │
│  └──────┘  └──────┘  └──────┘  └──────┘  └──────┘          │
│                           │                                    │
│  ┌────────────────────────┼────────────────────────┐          │
│  │                        │                        │          │
│  ↓                        ↓                        ↓          │
│  ┌──────────┐    ┌──────────────┐    ┌──────────┐         │
│  │  MLflow  │    │  PostgreSQL  │    │   S3     │         │
│  │  Server  │    │  (Metadata)  │    │(Artifacts)│         │
│  └──────────┘    └──────────────┘    └──────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Appendix E: Course Materials (Slides 306-310)

### Slide 306: Code Repository Structure
```
mlops-pipeline-series/
├── .dvc/
├── .github/
├── configs/
├── data/
├── logs/
├── models/
├── notebooks/
├── pipelines/
├── reports/
├── scripts/
├── src/
├── tests/
├── dagster_home/
├── mlruns/
├── .env
├── .gitignore
├── dvc.yaml
├── mlflow_config.yaml
├── params.yaml
├── requirements.txt
└── README.md
```

### Slide 307: Key Files
```
Configuration:         dvc.yaml, mlflow_config.yaml, params.yaml
Data Processing:       src/data/, src/features/
Model Training:        models/training/
Pipeline Definitions:  pipelines/
Scripts:               scripts/
Tests:                 tests/
Documentation:         README.md
```

### Slide 308: Environment Setup
```bash
# Clone repository
git clone https://github.com/yourusername/mlops-pipeline-series

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Setup DVC
dvc init

# Setup MLflow
export MLFLOW_TRACKING_URI=./mlruns

# Setup Dagster
export DAGSTER_HOME=$(pwd)/dagster_home
```

### Slide 309: Quick Start
```bash
# Run full pipeline
python scripts/run_master_pipeline.py

# Start MLflow UI
mlflow ui

# Start Dagster UI
dagster-webserver

# Start monitoring dashboard
streamlit run scripts/monitoring_dashboard.py
```

### Slide 310: Testing Commands
```bash
# Run tests
pytest tests/

# Run with coverage
pytest --cov=src tests/

# Run specific test
pytest tests/test_mlflow.py

# Run integration test
python scripts/test_advanced_pipeline.py
```

---

## Appendix F: Glossary (Slides 311-315)

### Slide 311: A-M
```
Artifact: File or object stored in MLflow
Asset: Data artifact in Dagster
Backend Store: Database storing MLflow metadata
Blue-Green: Deployment strategy with zero downtime
Canary: Gradual deployment strategy
CI/CD: Continuous Integration/Continuous Deployment
DAG: Directed Acyclic Graph (pipeline)
Drift: Model performance degradation over time
Experiment: Container for MLflow runs
Feature: Input variable for model
F1 Score: Harmonic mean of precision and recall
Git: Version control system
Grafana: Visualization tool
```

### Slide 312: N-Z
```
Op: Operation in Dagster (transformation)
Pipeline: Sequence of data processing steps
Precision: True positives / (True positives + False positives)
Recall: True positives / (True positives + False negatives)
Registry: Centralized model repository
Reproducibility: Ability to reproduce results
Resource: Shared service in Dagster
ROC-AUC: Area under ROC curve
Run: Single execution in MLflow
Schedule: Time-based trigger
Sensor: Event-based trigger
Stage: Model lifecycle state
Tracking: Experiment logging in MLflow
Version: Specific snapshot of data/model
```

### Slide 313: DVC Terms
```
Cache: Local storage of versioned data
Remote: External storage for data
Pipeline: Series of processing stages
Stage: Individual processing step
State: Database tracking pipeline status
Tag: Named version
Workspace: Current working directory
```

### Slide 314: MLflow Terms
```
Artifact: File or object stored with run
Experiment: Collection of runs
Metric: Numeric value tracked over runs
Model: Machine learning model
Parameter: Input value for model
Run: Single execution
Tag: Key-value metadata
Tracking: System for logging experiments
Registry: Centralized model store
Stage: Model lifecycle state
```

### Slide 315: Dagster Terms
```
Asset: Data artifact
Graph: Collection of ops
Hook: Lifecycle event handler
IOManager: Data persistence
Job: Collection of ops to execute
Op: Single transformation
Resource: Shared service
Schedule: Time-based trigger
Sensor: Event-based trigger
Step: Individual execution unit
```

---

## Appendix G: Cheat Sheets (Slides 316-320)

### Slide 316: DVC Cheat Sheet
```bash
# Version control
dvc add <file>              # Track file
dvc status                  # Check status
dvc push/pull               # Sync with remote

# Pipelines
dvc repro                   # Run pipeline
dvc dag                     # Show graph
dvc status --checks         # Detailed status

# Remote
dvc remote add -d <name> <url>
dvc remote list
dvc remote modify <name> <option> <value>

# Maintenance
dvc gc                      # Clean cache
dvc cache dir               # Show cache location
```

### Slide 317: MLflow Cheat Sheet
```python
# Setup
import mlflow
mlflow.set_tracking_uri("file:./mlruns")
mlflow.set_experiment("my_experiment")

# Run
with mlflow.start_run():
    mlflow.log_param("param", value)
    mlflow.log_metric("metric", value)
    mlflow.log_artifact("file.txt")

# Models
mlflow.sklearn.log_model(model, "model")
mlflow.sklearn.load_model("models:/model/Production")

# Registry
from mlflow.tracking import MlflowClient
client = MlflowClient()
client.create_model_version(...)
client.transition_model_version_stage(...)
```

### Slide 318: Dagster Cheat Sheet
```python
# Ops
@op
def my_op():
    return "result"

# Assets
@asset
def my_asset():
    return "data"

# Jobs
@job
def my_job():
    result = my_op()
    return result

# Schedules
@schedule(job=my_job, cron_schedule="0 0 * * *")
def my_schedule():
    return {}

# Sensors
@sensor(job=my_job)
def my_sensor():
    return RunRequest(...)

# Resources
@resource
def my_resource():
    return connection
```

### Slide 319: Deployment Cheat Sheet
```bash
# Build
docker build -t model-api .

# Deploy
kubectl apply -f deployment.yaml
kubectl rollout status deployment/model-api

# Scale
kubectl scale deployment model-api --replicas=5

# Update
kubectl set image deployment/model-api model-api=model-api:v2

# Rollback
kubectl rollout undo deployment/model-api

# Monitor
kubectl logs deployment/model-api
kubectl get pods
kubectl describe deployment/model-api
```

### Slide 320: Monitoring Cheat Sheet
```python
# Metrics collection
prometheus_client.start_http_server(8000)
counter = Counter('requests', 'Total requests')
counter.inc()

# Alerting
from prometheus_client import Gauge
latency = Gauge('latency_ms', 'Request latency')
latency.set(latency_ms)

# Logging
import logging
logging.info("Request processed", extra={"request_id": id})

# Dashboard
# Grafana: Create dashboards from metrics
# Prometheus: Query language (PromQL)

# Alerts
# Alertmanager: Configure alert rules
# Slack/Email/PagerDuty: Send notifications
```

---

# END OF SLIDE OUTLINE

---

**Total Slides: 320+**

This comprehensive slide outline covers:
- ✅ 8 major sections
- ✅ 20+ modules
- ✅ 320+ slides
- ✅ All tools and concepts
- ✅ Practical examples
- ✅ Architecture diagrams
- ✅ Cheat sheets and references
- ✅ Best practices and troubleshooting
