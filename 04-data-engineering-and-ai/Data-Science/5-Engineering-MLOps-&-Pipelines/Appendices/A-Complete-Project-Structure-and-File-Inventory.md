# Appendix A: Complete Project Structure and File Inventory

## The Target: Comprehensive Project Reference

This appendix provides a complete inventory of all files created throughout the series, their purposes, and their relationships. Use this as a reference when navigating the project or troubleshooting.

## The Concept: Project Map

Think of this like a building blueprint:
- **Root directory** = The building foundation
- **Subdirectories** = Different floors with specific functions
- **Files** = Individual rooms with specific purposes
- **Dependencies** = Hallways connecting rooms

## Complete Project Structure

```
mlops-pipeline-series/
│
├── .dvc/                          # DVC internal directory (auto-generated)
│   ├── cache/                     # Data cache storage
│   ├── config                     # DVC configuration
│   └── tmp/                       # Temporary DVC files
│
├── .github/                       # GitHub Actions CI/CD
│   └── workflows/
│       └── mlops_ci_cd.yaml       # CI/CD pipeline definition
│
├── configs/                       # Configuration files
│   ├── base_config.json           # Base pipeline configuration
│   ├── data_schema.json           # Data validation schema
│   ├── master_pipeline_config.yaml # Master pipeline configuration
│   ├── model_thresholds.json      # Model performance thresholds
│   ├── param_grid.json            # Hyperparameter grid for sweeping
│   └── pipeline_config.yaml       # General pipeline configuration
│
├── data/                          # Data storage
│   ├── raw/                       # Raw, immutable data
│   │   ├── generated_data.csv
│   │   ├── integrated_data.csv
│   │   ├── new_data.csv
│   │   ├── sensor_data_48h.csv
│   │   ├── sensor_data_168h.csv
│   │   └── sample_data.csv
│   ├── processed/                 # Processed features
│   │   ├── features_48h.csv
│   │   ├── features_168h.csv
│   │   ├── integrated_features.csv
│   │   └── master_features.csv
│   ├── external/                  # External data sources
│   ├── predictions/               # Batch prediction outputs
│   └── validation_report.json     # Data validation report
│
├── logs/                          # Log files
│   ├── errors/                    # Error logs
│   │   └── YYYYMMDD.json
│   ├── failures/                  # Pipeline failure logs
│   ├── monitoring/                # Monitoring metrics
│   │   ├── metrics.json
│   │   └── alerts.json
│   ├── pipelines/                 # Pipeline execution logs
│   ├── alerts.txt                 # Alert history
│   └── pipeline_status.json       # Current pipeline status
│
├── models/                        # Model artifacts
│   ├── training/                  # Training scripts
│   │   ├── train_model.py
│   │   ├── train_model_full.py
│   │   ├── train_model_mlflow.py
│   │   └── train_with_registry.py
│   ├── inference/                 # Inference code
│   ├── registry/                  # Registered models
│   │   ├── best_model.pkl
│   │   ├── ci_cd_model.pkl
│   │   ├── integrated_model.pkl
│   │   ├── master_model.pkl
│   │   ├── model_48h.pkl
│   │   ├── model_168h.pkl
│   │   ├── model_*.pkl
│   │   └── scaler.pkl
│   ├── evaluation/                # Evaluation reports
│   │   ├── report_48h/
│   │   ├── report_168h/
│   │   ├── ci_cd_report/
│   │   ├── promotion_report.json
│   │   ├── promotion_report_integrated.json
│   │   └── result.json
│   └── deployment/                # Deployment artifacts
│       ├── api_app.py
│       ├── batch_predict.py
│       ├── batch_schedule.json
│       ├── active_env.json
│       ├── active_service.json
│       ├── deployment_record.json
│       ├── blue/                  # Blue environment
│       │   ├── model.pkl
│       │   ├── scaler.pkl
│       │   ├── service.json
│       │   └── test_results.json
│       └── green/                 # Green environment
│           ├── model.pkl
│           ├── scaler.pkl
│           ├── service.json
│           └── test_results.json
│
├── notebooks/                     # Jupyter notebooks
│   └── README.md                  # Notebook documentation
│
├── pipelines/                     # Dagster pipeline definitions
│   ├── __init__.py                # Pipeline exports
│   ├── advanced_pipeline.py       # Advanced pipeline with branching
│   ├── advanced_schedules.py      # Schedule definitions
│   ├── advanced_sensors.py        # Sensor definitions
│   ├── configurable_pipeline.py   # Configurable pipeline
│   ├── error_handling.py          # Error handling pipeline
│   ├── integrated_pipeline.py     # Integrated DVC+MLflow pipeline
│   ├── integrated_schedules.py    # Integrated schedules
│   ├── master_pipeline.py         # Complete end-to-end pipeline
│   ├── monitoring_pipeline.py     # Monitoring pipeline
│   ├── pipeline_assets.py         # Asset definitions
│   ├── pipeline_ops.py            # Operation definitions
│   ├── schedules.py               # Basic schedules
│   ├── sensors.py                 # Basic sensors
│   └── sub_graphs.py              # Reusable sub-graphs
│
├── reports/                       # Generated reports
│   ├── experiment_comparison.png
│   ├── experiment_data.csv
│   ├── Predictive_Maintenance_Full_report.html
│   ├── Predictive_Maintenance_Full_analysis.png
│   ├── Predictive_Maintenance_Full_report.json
│   └── Predictive_Maintenance_Full_runs.csv
│
├── scripts/                       # Utility scripts
│   ├── analyze_experiments.py     # Experiment analysis
│   ├── backup_data.sh             # Data backup script
│   ├── blue_green_deploy.py       # Blue-green deployment
│   ├── compare_experiments.py     # Experiment comparison
│   ├── compare_pipelines.py       # Pipeline comparison
│   ├── conditional_pipeline.sh    # Conditional pipeline execution
│   ├── configure_dvc_remote.sh    # DVC remote configuration
│   ├── dashboard.py               # Interactive dashboard
│   ├── deploy_model.py            # Model deployment
│   ├── deploy_production.sh       # Production deployment
│   ├── generate_visualizations.py # Visualization generation
│   ├── launch_mlflow_dashboard.sh # MLflow UI launcher
│   ├── monitor_pipeline.py        # Pipeline monitoring
│   ├── monitoring_dashboard.py    # Monitoring dashboard
│   ├── promote_model.py           # Model promotion
│   ├── reset_pipeline.sh          # Pipeline reset
│   ├── run_batch_experiments.py   # Batch experiment runner
│   ├── run_master_pipeline.py     # Master pipeline runner
│   ├── start_mlflow_server.sh     # MLflow server starter
│   ├── tag_data_version.sh        # Data version tagging
│   ├── test_advanced_pipeline.py  # Advanced pipeline test
│   ├── verify_deployment.py       # Deployment verification
│   └── version_pipeline.sh        # Pipeline versioning
│
├── src/                           # Source code
│   ├── data/                      # Data processing modules
│   │   └── generate_sensor_data.py
│   ├── features/                  # Feature engineering
│   │   └── build_features.py
│   ├── utils/                     # Utility functions
│   │   ├── dagster_utils.py       # Dagster utilities
│   │   ├── get_params.py          # Parameter loading
│   │   ├── integration_utils.py   # DVC+MLflow integration
│   │   ├── mlflow_utils.py        # MLflow utilities
│   │   └── model_registry.py      # Model registry utilities
│   └── visualization/             # Visualization modules
│       └── mlflow_viz.py          # MLflow visualization
│
├── tests/                         # Test files
│   ├── test_mlflow.py             # MLflow tests
│   ├── test_remote_access.py      # Remote storage tests
│   ├── production_tests.json      # Production test data
│   └── data/
│       └── sample_input.json      # Sample test input
│
├── dagster_home/                  # Dagster home directory
│   ├── dagster.yaml               # Dagster configuration
│   └── storage/                   # Dagster storage
│
├── mlruns/                        # MLflow tracking data
│   ├── 0/                         # Experiment directories
│   ├── metadata/                  # MLflow metadata
│   └── model-registry/            # Model registry data
│
├── mlflow_artifacts/              # MLflow artifact storage
│
├── .dvcignore                     # DVC ignore patterns
├── .env                           # Environment variables (not committed)
├── .gitignore                     # Git ignore patterns
├── dvc.yaml                       # DVC pipeline definition
├── dvc.lock                       # DVC lock file
├── mlflow_config.yaml             # MLflow configuration
├── mlops_pipeline.code-workspace  # VS Code workspace
├── params.yaml                    # DVC parameters
├── requirements.txt               # Python dependencies
├── workspace.yaml                 # Dagster workspace
├── metrics.yaml                   # DVC metrics
├── README.md                      # Project documentation
└── LICENSE                        # License file
```

## File Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FILE DEPENDENCY GRAPH                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  requirements.txt                                                   │
│       │                                                             │
│       ▼                                                             │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  src/utils/                                                  │   │
│  │  ├── dagster_utils.py    ←───  pipelines/*.py               │   │
│  │  ├── mlflow_utils.py     ←───  models/training/*.py         │   │
│  │  ├── integration_utils.py ←── pipelines/integrated_pipeline.py│   │
│  │  └── model_registry.py   ←─── scripts/promote_model.py      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│       │                                                             │
│       ├─────────────────────────────────────────────────────────────┤
│       │                         │                                   │
│       ▼                         ▼                                   │
│  ┌───────────────────┐   ┌───────────────────┐                    │
│  │  src/data/         │   │  src/features/    │                    │
│  │  generate_sensor_  │   │  build_features.  │                    │
│  │  data.py           │   │  py               │                    │
│  └───────────────────┘   └───────────────────┘                    │
│       │                         │                                   │
│       └──────────┬──────────────┘                                   │
│                  ▼                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  models/training/                                            │   │
│  │  ├── train_model.py                                          │   │
│  │  ├── train_model_full.py                                     │   │
│  │  ├── train_model_mlflow.py                                   │   │
│  │  └── train_with_registry.py                                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│       │                                                             │
│       ▼                                                             │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  pipelines/                                                  │   │
│  │  ├── pipeline_ops.py       ←─── Basic pipeline              │   │
│  │  ├── advanced_pipeline.py  ←─── Branching pipeline          │   │
│  │  ├── integrated_pipeline.py ←── DVC+MLflow integration      │   │
│  │  └── master_pipeline.py    ←─── Complete end-to-end         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│       │                                                             │
│       ├────────────────────┬─────────────────────┐                 │
│       ▼                    ▼                     ▼                 │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐          │
│  │  Schedules   │   │   Sensors    │   │   Jobs       │          │
│  │  *.py        │   │   *.py       │   │   *.py       │          │
│  └──────────────┘   └──────────────┘   └──────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Configuration Files Reference

| File | Purpose | Key Settings |
|------|---------|--------------|
| `configs/master_pipeline_config.yaml` | Master pipeline configuration | Data sources, validation, features, models, deployment |
| `configs/model_thresholds.json` | Model promotion thresholds | accuracy, precision, recall, f1 thresholds |
| `configs/param_grid.json` | Hyperparameter sweep grid | test_size, random_state, model parameters |
| `configs/data_schema.json` | Data validation schema | Column types, ranges, required fields |
| `mlflow_config.yaml` | MLflow configuration | Tracking URI, artifact location, experiment defaults |
| `params.yaml` | DVC parameters | Data generation, feature engineering parameters |
| `dvc.yaml` | DVC pipeline definition | Stages, dependencies, outputs |
| `.env` | Environment variables | AWS credentials, MLflow URI, DVC remote |

## Key File Relationships

### 1. Data Flow
```
src/data/generate_sensor_data.py
    ↓ (generates)
data/raw/*.csv
    ↓ (processed by)
src/features/build_features.py
    ↓ (generates)
data/processed/*.csv
    ↓ (used by)
models/training/train_model*.py
    ↓ (generates)
models/registry/*.pkl
    ↓ (deployed by)
scripts/deploy_model.py
```

### 2. Pipeline Flow
```
pipelines/pipeline_ops.py (Basic)
    ↓ (extends)
pipelines/advanced_pipeline.py (Branching)
    ↓ (integrates)
pipelines/integrated_pipeline.py (DVC+MLflow)
    ↓ (completes)
pipelines/master_pipeline.py (End-to-end)
```

### 3. Experiment Tracking Flow
```
models/training/train_model_mlflow.py
    ↓ (logs to)
mlruns/ (MLflow tracking)
    ↓ (visualized by)
src/visualization/mlflow_viz.py
    ↓ (generates)
reports/*.html
```

### 4. Monitoring Flow
```
pipelines/monitoring_pipeline.py
    ↓ (collects metrics from)
src/monitoring/monitor.py
    ↓ (stores in)
logs/monitoring/metrics.json
    ↓ (displayed by)
scripts/monitoring_dashboard.py
```

## Deployment Artifact Flow

```
models/registry/best_model.pkl
    ↓ (processed by)
scripts/blue_green_deploy.py
    ↓ (deploys to)
models/deployment/blue/ or green/
    ↓ (active environment)
models/deployment/active_service.json
    ↓ (served by)
models/deployment/api_app.py
    ↓ (verified by)
scripts/verify_deployment.py
```

## Python Package Dependencies

```
requirements.txt Structure:
├── Core Data Science
│   ├── numpy==1.24.3
│   ├── pandas==2.0.3
│   ├── scikit-learn==1.3.0
│   └── scipy==1.10.1
├── Machine Learning
│   ├── torch==2.0.1
│   ├── tensorflow==2.13.0
│   └── xgboost==1.7.6
├── Data Versioning
│   ├── dvc==3.15.3
│   ├── dvc-s3==3.15.3
│   └── dvc-gs==3.15.3
├── Experiment Tracking
│   └── mlflow==2.4.1
├── Pipeline Orchestration
│   ├── dagster==1.5.3
│   ├── dagster-webserver==1.5.3
│   └── dagster-docker==0.21.3
├── Database
│   ├── psycopg2-binary==2.9.7
│   └── sqlalchemy==2.0.19
├── Data Validation
│   ├── pydantic==2.3.0
│   └── great-expectations==0.17.19
├── API & Web
│   ├── fastapi==0.100.0
│   └── uvicorn==0.23.2
├── Utilities
│   ├── python-dotenv==1.0.0
│   ├── click==8.1.7
│   ├── pyyaml==6.0.1
│   └── tqdm==4.65.0
└── Testing
    ├── pytest==7.4.0
    ├── pytest-cov==4.1.0
    ├── black==23.7.0
    ├── flake8==6.1.0
    └── mypy==1.5.1
```

## Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `MLFLOW_TRACKING_URI` | MLflow server location | `./mlruns` or `http://localhost:5000` |
| `MLFLOW_ENV` | Environment name | `development`, `staging`, `production` |
| `DVC_REMOTE_TYPE` | DVC remote type | `s3`, `gcs`, `network` |
| `DVC_REMOTE_PATH` | DVC remote path | `s3://bucket-name` |
| `AWS_ACCESS_KEY_ID` | AWS credentials | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials | `...` |
| `AWS_DEFAULT_REGION` | AWS region | `us-east-1` |
| `GOOGLE_APPLICATION_CREDENTIALS` | GCP service account | `/path/to/key.json` |
| `DAGSTER_HOME` | Dagster home directory | `./dagster_home` |

## Quick Reference Commands

### DVC Commands
```bash
dvc init                     # Initialize DVC
dvc add <file>               # Start tracking a file
dvc status                   # Check changes
dvc push/pull                # Sync with remote
dvc repro                    # Run pipeline
dvc remote list              # List remotes
```

### MLflow Commands
```bash
mlflow ui                    # Start tracking UI
mlflow server                # Start tracking server
mlflow experiments list      # List experiments
mlflow runs list             # List runs
```

### Dagster Commands
```bash
dagster-webserver            # Start UI
dagster-daemon run           # Start daemon
dagster job execute          # Run a job
dagster schedule list        # List schedules
dagster sensor list          # List sensors
```

### Deployment Commands
```bash
python scripts/deploy_model.py --model <path> --environment <env>
python scripts/blue_green_deploy.py --model <path>
python scripts/verify_deployment.py --endpoint <url>
python scripts/promote_model.py promote --model <name> --version <v>
```

---

*End of Appendix A: Complete Project Structure and File Inventory*
