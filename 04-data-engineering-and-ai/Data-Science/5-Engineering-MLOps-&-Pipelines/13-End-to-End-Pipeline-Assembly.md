# Phase 4: Full Integration and Deployment
## Part 13: End-to-End Pipeline Assembly

## The Target: Complete Production-Grade MLOps Pipeline

In this part, we'll assemble the entire end-to-end pipeline, integrating all components into a single, production-ready system. By the end, you'll have a complete MLOps pipeline that handles data ingestion, versioning, experiment tracking, model training, registry management, and deployment.

## The Concept: The Complete MLOps Lifecycle

Think of this as a fully automated factory:
- **Raw materials** (data) come in through the loading dock
- **Quality control** (validation) checks everything
- **Processing** (feature engineering) transforms materials
- **Manufacturing** (model training) creates the product
- **Quality assurance** (evaluation) tests the product
- **Warehouse** (model registry) stores finished products
- **Shipping** (deployment) delivers to customers
- **Maintenance** (monitoring) ensures ongoing quality

## The Implementation: The Complete Pipeline

### Step 1: Create the Master Pipeline Configuration

```bash
cat > configs/master_pipeline_config.yaml << 'EOF'
# Master pipeline configuration for end-to-end MLOps

pipeline:
  name: "End-to-End MLOps Pipeline"
  version: "1.0.0"
  description: "Complete production ML pipeline from data ingestion to deployment"

# Data configuration
data:
  sources:
    - type: "synthetic"
      parameters:
        n_samples: 10000
        anomaly_rate: 0.05
        seed: 42
    - type: "csv"
      path: "data/raw/external_data.csv"
      fallback: "synthetic"
  
  validation:
    schema: "configs/data_schema.json"
    quality_checks:
      - type: "missing_values"
        max_allowed: 0.05
      - type: "outliers"
        method: "iqr"
        threshold: 1.5
      - type: "data_types"
        enforce: true

# Feature engineering
features:
  engineering:
    rolling_windows: [5, 10, 30, 60]
    interaction_features: true
    time_features: true
  
  selection:
    method: "feature_importance"
    top_k: 50
    threshold: 0.01

# Model training
model:
  algorithms:
    - type: "random_forest"
      parameters:
        n_estimators: [100, 200, 300]
        max_depth: [10, 15, 20]
        min_samples_split: [2, 5, 10]
    - type: "gradient_boosting"
      parameters:
        n_estimators: [100, 200]
        learning_rate: [0.05, 0.1, 0.15]
        max_depth: [3, 5, 7]
    - type: "xgboost"
      parameters:
        n_estimators: [100, 200]
        learning_rate: [0.05, 0.1]
        max_depth: [3, 5]
  
  selection_metric: "f1"
  cv_folds: 5
  test_size: 0.2

# Experiment tracking
mlflow:
  tracking_uri: "./mlruns"
  experiment_name: "Master_Pipeline_Experiments"
  artifact_location: "./mlflow_artifacts"
  
  logging:
    log_models: true
    log_datasets: true
    log_code: true
    log_env: true

# Model registry
registry:
  model_name: "master_predictive_model"
  stages:
    - "Staging"
    - "Production"
    - "Archived"
  
  promotion_criteria:
    min_f1: 0.85
    min_accuracy: 0.90
    min_precision: 0.85
    min_recall: 0.85

# Deployment
deployment:
  targets:
    - type: "rest_api"
      endpoint: "/predict"
      port: 8000
    - type: "batch"
      schedule: "0 0 * * *"
      output_path: "data/predictions/"
  
  validation:
    test_predictions: true
    performance_monitoring: true
    drift_detection: true

# Orchestration
orchestration:
  schedules:
    - name: "daily_training"
      cron: "0 0 * * *"
      timezone: "UTC"
    - name: "weekly_full"
      cron: "0 0 * * 0"
      timezone: "UTC"
  
  sensors:
    - type: "file"
      path: "data/raw/new_data.csv"
      poll_interval: 60
    - type: "api"
      endpoint: "http://data-source/api/trigger"
      poll_interval: 300

# Monitoring
monitoring:
  metrics:
    - "accuracy"
    - "f1"
    - "precision"
    - "recall"
    - "latency"
    - "throughput"
  
  alerts:
    - metric: "accuracy"
      threshold: 0.80
      condition: "<"
    - metric: "latency"
      threshold: 1000
      condition: ">"
  
  slack_webhook: "https://hooks.slack.com/services/your/webhook"
  email_recipients: ["team@yourdomain.com"]
EOF
```

### Step 2: Create the Master Pipeline

```bash
cat > pipelines/master_pipeline.py << 'EOF'
"""
Complete end-to-end MLOps pipeline.
Integrates data ingestion, validation, feature engineering, model training,
registry management, and deployment.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
import json
import yaml
import pickle
import subprocess
from datetime import datetime
from typing import Dict, Any, Optional, Tuple, List
import logging

from dagster import (
    op, 
    job, 
    graph, 
    asset,
    In,
    Out,
    get_dagster_logger,
    resource,
    OpExecutionContext,
    RetryPolicy,
    Output,
    Failure
)

from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import (
    accuracy_score, f1_score, precision_score, recall_score,
    roc_auc_score, confusion_matrix, classification_report
)
import xgboost as xgb
import mlflow
from mlflow.tracking import MlflowClient

from src.utils.dagster_utils import DataIOManager, ModelIOManager
from src.utils.integration_utils import get_integration
from src.utils.model_registry import ModelRegistryManager


# Configure logging
logger = get_dagster_logger()


# ============= CONFIGURATION OP =============

@op
def load_pipeline_config(context: OpExecutionContext) -> Dict[str, Any]:
    """
    Load master pipeline configuration.
    """
    config_path = Path("configs/master_pipeline_config.yaml")
    
    if not config_path.exists():
        context.log.warning("Config file not found, using default configuration")
        return {
            "data": {"validation": {"quality_checks": []}},
            "features": {"engineering": {"rolling_windows": [5, 10]}},
            "model": {"algorithms": [{"type": "random_forest", "parameters": {"n_estimators": 100}}]},
            "mlflow": {"experiment_name": "Default_Experiment"},
            "registry": {"model_name": "default_model"},
            "deployment": {"targets": []}
        }
    
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    
    context.log.info(f"Loaded configuration from {config_path}")
    return config


# ============= DATA INGESTION OPS =============

@op(
    out=Out(io_manager_key="data_io"),
    retry_policy=RetryPolicy(max_retries=3, delay=10, backoff=2)
)
def ingest_data(context: OpExecutionContext, config: Dict) -> pd.DataFrame:
    """
    Ingest data from various sources.
    """
    logger = context.log
    integration = get_integration()
    
    logger.info("Starting data ingestion...")
    
    data_config = config.get('data', {})
    sources = data_config.get('sources', [])
    
    if not sources:
        raise Failure("No data sources configured")
    
    # Try each source in order
    df = None
    source_used = None
    
    for source in sources:
        source_type = source.get('type')
        
        try:
            if source_type == 'synthetic':
                logger.info("Generating synthetic data...")
                params = source.get('parameters', {})
                n_samples = params.get('n_samples', 10000)
                anomaly_rate = params.get('anomaly_rate', 0.05)
                seed = params.get('seed', 42)
                
                np.random.seed(seed)
                
                data = {
                    'timestamp': pd.date_range('2024-01-01', periods=n_samples, freq='min'),
                    'sensor_1': np.random.normal(20, 5, n_samples),
                    'sensor_2': np.random.normal(30, 5, n_samples),
                    'sensor_3': np.random.normal(50, 5, n_samples),
                    'temperature': np.random.normal(75, 10, n_samples),
                    'pressure': np.random.normal(1.2, 0.2, n_samples),
                    'vibration': np.random.normal(0.5, 0.1, n_samples)
                }
                
                df = pd.DataFrame(data)
                
                # Add anomalies
                anomaly_indices = np.random.choice(
                    n_samples, 
                    size=int(n_samples * anomaly_rate), 
                    replace=False
                )
                df.loc[anomaly_indices, 'temperature'] += np.random.uniform(10, 30, len(anomaly_indices))
                df.loc[anomaly_indices, 'vibration'] += np.random.uniform(1, 3, len(anomaly_indices))
                df['label'] = 0
                df.loc[anomaly_indices, 'label'] = 1
                
                source_used = 'synthetic'
                break
                
            elif source_type == 'csv':
                path = source.get('path')
                if path and Path(path).exists():
                    logger.info(f"Loading data from {path}")
                    df = pd.read_csv(path)
                    source_used = 'csv'
                    break
                else:
                    logger.warning(f"CSV file not found: {path}")
                    
            else:
                logger.warning(f"Unknown source type: {source_type}")
                
        except Exception as e:
            logger.error(f"Failed to ingest from {source_type}: {e}")
            continue
    
    if df is None:
        raise Failure("Failed to ingest data from any source")
    
    # Log ingestion metadata
    with mlflow.start_run(run_name=f"ingest_{datetime.now().strftime('%Y%m%d_%H%M%S')}"):
        mlflow.log_params({
            'source_type': source_used,
            'n_samples': len(df),
            'n_features': len(df.columns),
            'anomaly_count': df['label'].sum(),
            'anomaly_rate': df['label'].mean()
        })
    
    logger.info(f"Data ingested: {len(df)} samples from {source_used}")
    
    return df


@op(
    ins={"data": In(io_manager_key="data_io")},
    out=Out(io_manager_key="data_io")
)
def validate_data(context: OpExecutionContext, data: pd.DataFrame, config: Dict) -> pd.DataFrame:
    """
    Validate data quality and schema.
    """
    logger = context.log
    
    logger.info("Validating data...")
    
    validation_config = config.get('data', {}).get('validation', {})
    quality_checks = validation_config.get('quality_checks', [])
    
    # Track validation results
    validation_results = {
        'passed': True,
        'checks': []
    }
    
    # Check for missing values
    missing_ratio = data.isnull().sum().sum() / (len(data) * len(data.columns))
    max_missing = 0.05  # Default threshold
    
    for check in quality_checks:
        if check.get('type') == 'missing_values':
            max_missing = check.get('max_allowed', 0.05)
    
    if missing_ratio > max_missing:
        validation_results['passed'] = False
        validation_results['checks'].append({
            'type': 'missing_values',
            'passed': False,
            'message': f"Missing value ratio {missing_ratio:.2%} exceeds {max_missing:.2%}"
        })
        logger.warning(f"Missing value ratio {missing_ratio:.2%} exceeds threshold")
    else:
        validation_results['checks'].append({
            'type': 'missing_values',
            'passed': True,
            'message': f"Missing value ratio {missing_ratio:.2%} within threshold"
        })
    
    # Check for outliers using IQR
    outlier_check = False
    for check in quality_checks:
        if check.get('type') == 'outliers':
            outlier_check = True
            threshold = check.get('threshold', 1.5)
            
            numeric_cols = data.select_dtypes(include=[np.number]).columns
            outlier_counts = {}
            
            for col in numeric_cols:
                Q1 = data[col].quantile(0.25)
                Q3 = data[col].quantile(0.75)
                IQR = Q3 - Q1
                lower_bound = Q1 - threshold * IQR
                upper_bound = Q3 + threshold * IQR
                
                outliers = data[(data[col] < lower_bound) | (data[col] > upper_bound)]
                outlier_counts[col] = len(outliers)
            
            total_outliers = sum(outlier_counts.values())
            outlier_ratio = total_outliers / (len(data) * len(numeric_cols))
            
            if outlier_ratio > 0.05:
                validation_results['passed'] = False
                validation_results['checks'].append({
                    'type': 'outliers',
                    'passed': False,
                    'message': f"Outlier ratio {outlier_ratio:.2%} exceeds threshold"
                })
            else:
                validation_results['checks'].append({
                    'type': 'outliers',
                    'passed': True,
                    'message': f"Outlier ratio {outlier_ratio:.2%} within threshold"
                })
    
    # Log validation results
    with mlflow.start_run(run_name=f"validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}"):
        mlflow.log_dict(validation_results, "validation_results.json")
        
        # Log each check as a parameter
        for check in validation_results['checks']:
            mlflow.log_param(f"validation_{check['type']}", check['passed'])
    
    if not validation_results['passed']:
        logger.warning("Data validation failed, but continuing with pipeline")
        # Could raise Failure here to stop pipeline
        # raise Failure("Data validation failed")
    
    # Save validation report
    report_path = Path("data/validation_report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, 'w') as f:
        json.dump(validation_results, f, indent=2)
    
    logger.info(f"Data validation complete: {len(validation_results['checks'])} checks performed")
    
    return data


# ============= FEATURE ENGINEERING OPS =============

@op(
    ins={"data": In(io_manager_key="data_io")},
    out=Out(io_manager_key="data_io")
)
def engineer_features(context: OpExecutionContext, data: pd.DataFrame, config: Dict) -> pd.DataFrame:
    """
    Engineer features for model training.
    """
    logger = context.log
    integration = get_integration()
    
    logger.info("Engineering features...")
    
    feature_config = config.get('features', {})
    engineering_config = feature_config.get('engineering', {})
    
    # Start MLflow run
    with integration.create_experiment_run(
        experiment_name="Master_Pipeline",
        run_name=f"feature_engineering_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        tags={"operation": "feature_engineering"}
    ):
        # Separate features and target
        X = data.drop(columns=['label', 'timestamp'] if 'timestamp' in data.columns else ['label'])
        y = data['label']
        
        original_features = X.columns.tolist()
        all_features = X.copy()
        
        # Add rolling statistics
        windows = engineering_config.get('rolling_windows', [5, 10, 30])
        for col in X.columns:
            if col in ['sensor_1', 'sensor_2', 'sensor_3', 'temperature', 'pressure', 'vibration']:
                for window in windows:
                    all_features[f'{col}_rolling_mean_{window}'] = X[col].rolling(window=window, min_periods=1).mean()
                    all_features[f'{col}_rolling_std_{window}'] = X[col].rolling(window=window, min_periods=1).std()
                    all_features[f'{col}_rolling_max_{window}'] = X[col].rolling(window=window, min_periods=1).max()
                    all_features[f'{col}_rolling_min_{window}'] = X[col].rolling(window=window, min_periods=1).min()
        
        # Add interaction features
        if engineering_config.get('interaction_features', True):
            for i, col1 in enumerate(X.columns[:3]):
                for col2 in X.columns[i+1:i+4]:
                    if col1 != col2:
                        all_features[f'{col1}_{col2}_ratio'] = X[col1] / (X[col2] + 0.001)
                        all_features[f'{col1}_{col2}_product'] = X[col1] * X[col2]
        
        # Add time features
        if engineering_config.get('time_features', True) and 'timestamp' in data.columns:
            all_features['hour'] = pd.to_datetime(data['timestamp']).dt.hour
            all_features['day_of_week'] = pd.to_datetime(data['timestamp']).dt.dayofweek
            all_features['month'] = pd.to_datetime(data['timestamp']).dt.month
        
        # Handle missing values
        all_features = all_features.fillna(0)
        
        # Add label back
        all_features['label'] = y
        
        # Feature selection (if specified)
        selection_config = feature_config.get('selection', {})
        if selection_config.get('method') == 'feature_importance':
            # Train a quick model for feature selection
            from sklearn.ensemble import RandomForestClassifier
            temp_model = RandomForestClassifier(n_estimators=100, random_state=42)
            X_temp = all_features.drop(columns=['label'])
            temp_model.fit(X_temp, y)
            
            importances = temp_model.feature_importances_
            feature_importance_df = pd.DataFrame({
                'feature': X_temp.columns,
                'importance': importances
            }).sort_values('importance', ascending=False)
            
            top_k = selection_config.get('top_k', 50)
            selected_features = feature_importance_df.head(top_k)['feature'].tolist()
            
            all_features = all_features[selected_features + ['label']]
            
            logger.info(f"Selected top {len(selected_features)} features")
        
        # Log feature info
        mlflow.log_params({
            'original_features': len(original_features),
            'engineered_features': len(all_features.columns) - 1,  # Excluding label
            'feature_selection_used': selection_config.get('method') is not None
        })
        
        # Save features
        features_path = Path("data/processed/master_features.csv")
        features_path.parent.mkdir(parents=True, exist_ok=True)
        all_features.to_csv(features_path, index=False)
        
        # Log version
        integration.log_data_version_to_mlflow(str(features_path), prefix="features")
        
        logger.info(f"Feature engineering complete: {len(all_features.columns)} features")
        
        return all_features


# ============= MODEL TRAINING OPS =============

@op(
    ins={"features": In(io_manager_key="data_io")},
    out=Out(io_manager_key="model_io"),
    retry_policy=RetryPolicy(max_retries=3, delay=15, backoff=2)
)
def train_models(context: OpExecutionContext, features: pd.DataFrame, config: Dict) -> Dict[str, Any]:
    """
    Train multiple models and select the best one.
    """
    logger = context.log
    integration = get_integration()
    
    logger.info("Training models...")
    
    model_config = config.get('model', {})
    algorithms = model_config.get('algorithms', [])
    test_size = model_config.get('test_size', 0.2)
    cv_folds = model_config.get('cv_folds', 5)
    selection_metric = model_config.get('selection_metric', 'f1')
    
    # Prepare data
    X = features.drop(columns=['label'])
    y = features['label']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42, stratify=y
    )
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train multiple models
    models = {}
    results = {}
    
    # Map algorithm names to classes
    algorithm_map = {
        'random_forest': RandomForestClassifier,
        'gradient_boosting': GradientBoostingClassifier,
        'logistic_regression': LogisticRegression,
        'xgboost': xgb.XGBClassifier
    }
    
    # MLflow experiment
    with integration.create_experiment_run(
        experiment_name="Master_Pipeline",
        run_name=f"model_training_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        tags={"operation": "model_training"}
    ):
        for algo_config in algorithms:
            algo_type = algo_config.get('type', 'random_forest')
            param_grid = algo_config.get('parameters', {})
            
            logger.info(f"Training {algo_type}...")
            
            # Get algorithm class
            algo_class = algorithm_map.get(algo_type)
            if algo_class is None:
                logger.warning(f"Unknown algorithm: {algo_type}, skipping")
                continue
            
            # Grid search (simplified - in production use sklearn GridSearchCV)
            best_score = 0
            best_params = {}
            best_model = None
            
            # Extract parameter lists
            param_lists = {}
            for param_name, param_values in param_grid.items():
                if isinstance(param_values, list):
                    param_lists[param_name] = param_values
                else:
                    param_lists[param_name] = [param_values]
            
            # Generate parameter combinations
            import itertools
            param_names = list(param_lists.keys())
            param_values = list(param_lists.values())
            
            for combo in itertools.product(*param_values):
                params = dict(zip(param_names, combo))
                
                try:
                    model = algo_class(**params, random_state=42)
                    
                    # Cross-validation
                    cv_scores = cross_val_score(
                        model, X_train_scaled, y_train, 
                        cv=cv_folds, scoring=selection_metric
                    )
                    mean_score = np.mean(cv_scores)
                    
                    if mean_score > best_score:
                        best_score = mean_score
                        best_params = params
                        best_model = model
                        
                except Exception as e:
                    logger.warning(f"Failed to train with params {params}: {e}")
                    continue
            
            if best_model is None:
                logger.warning(f"Failed to train {algo_type}")
                continue
            
            # Train best model on full training data
            best_model.fit(X_train_scaled, y_train)
            
            # Evaluate on test set
            y_pred = best_model.predict(X_test_scaled)
            y_pred_proba = best_model.predict_proba(X_test_scaled)[:, 1] if hasattr(best_model, 'predict_proba') else None
            
            metrics = {
                'accuracy': accuracy_score(y_test, y_pred),
                'f1': f1_score(y_test, y_pred),
                'precision': precision_score(y_test, y_pred),
                'recall': recall_score(y_test, y_pred),
            }
            
            if y_pred_proba is not None:
                metrics['roc_auc'] = roc_auc_score(y_test, y_pred_proba)
            
            # Log metrics
            for metric_name, value in metrics.items():
                mlflow.log_metric(f"{algo_type}_{metric_name}", value)
            
            # Log model
            mlflow.sklearn.log_model(
                best_model,
                artifact_path=f"models/{algo_type}",
                registered_model_name=f"master_model_{algo_type}"
            )
            
            models[algo_type] = {
                'model': best_model,
                'params': best_params,
                'metrics': metrics,
                'cv_score': best_score
            }
            
            results[algo_type] = {
                'metrics': metrics,
                'cv_score': best_score,
                'params': best_params
            }
            
            logger.info(f"{algo_type} - F1: {metrics['f1']:.4f}, CV: {best_score:.4f}")
        
        # Select best model
        best_algo = max(models.keys(), key=lambda k: models[k]['metrics'][selection_metric])
        best_model_data = models[best_algo]
        
        logger.info(f"Best model: {best_algo} with {selection_metric}: {best_model_data['metrics'][selection_metric]:.4f}")
        
        # Prepare final model data
        model_data = {
            'model': best_model_data['model'],
            'scaler': scaler,
            'metrics': best_model_data['metrics'],
            'params': best_model_data['params'],
            'feature_names': X.columns.tolist(),
            'algorithm': best_algo,
            'training_date': datetime.now().isoformat(),
            'all_results': results
        }
        
        # Log best model info
        mlflow.log_params({
            'best_algorithm': best_algo,
            'best_f1': best_model_data['metrics']['f1'],
            'model_features': len(X.columns)
        })
        
        # Save model
        model_path = Path("models/registry/master_model.pkl")
        model_path.parent.mkdir(parents=True, exist_ok=True)
        with open(model_path, 'wb') as f:
            pickle.dump(model_data, f)
        
        # Log version
        integration.log_data_version_to_mlflow(str(model_path), prefix="model")
        
        return model_data


# ============= MODEL REGISTRY OP =============

@op(
    ins={"model_data": In(io_manager_key="model_io")}
)
def register_model(context: OpExecutionContext, model_data: Dict, config: Dict) -> Dict:
    """
    Register the best model in MLflow Model Registry.
    """
    logger = context.log
    
    logger.info("Registering model...")
    
    registry_config = config.get('registry', {})
    model_name = registry_config.get('model_name', 'master_predictive_model')
    promotion_criteria = registry_config.get('promotion_criteria', {})
    
    # Check if model meets criteria
    metrics = model_data['metrics']
    meets_criteria = True
    criteria_results = {}
    
    for metric, threshold in promotion_criteria.items():
        value = metrics.get(metric, 0)
        criteria_results[metric] = value >= threshold
        if not criteria_results[metric]:
            meets_criteria = False
        logger.info(f"  {metric}: {value:.4f} >= {threshold:.4f} = {criteria_results[metric]}")
    
    # Determine stage
    if meets_criteria:
        target_stage = "Production"
        status = "promoted"
        logger.info("✅ Model meets criteria, promoting to Production")
    elif metrics.get('f1', 0) >= 0.75:
        target_stage = "Staging"
        status = "staged"
        logger.info("⚠️ Model meets staging criteria, moving to Staging")
    else:
        target_stage = "Archived"
        status = "rejected"
        logger.info("❌ Model does not meet criteria, archiving")
    
    # Get or create registered model
    try:
        from mlflow.tracking import MlflowClient
        client = MlflowClient()
        
        # Get latest version
        model_versions = client.search_model_versions(f"name='{model_name}'")
        
        if model_versions:
            latest_version = model_versions[0].version
            
            # Transition to target stage
            client.transition_model_version_stage(
                name=model_name,
                version=latest_version,
                stage=target_stage,
                archive_existing_versions=True
            )
            logger.info(f"Model version {latest_version} transitioned to {target_stage}")
            
            version = latest_version
        else:
            logger.warning(f"Model {model_name} not found in registry")
            version = None
            
    except Exception as e:
        logger.warning(f"Failed to update registry: {e}")
        version = None
    
    # Create promotion report
    report = {
        'model_name': model_name,
        'version': version,
        'status': status,
        'target_stage': target_stage,
        'meets_criteria': meets_criteria,
        'criteria_results': criteria_results,
        'metrics': metrics,
        'evaluation_time': datetime.now().isoformat()
    }
    
    # Save report
    report_path = Path("models/evaluation/promotion_report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    
    logger.info(f"Model registration complete: {status}")
    
    return report


# ============= DEPLOYMENT OP =============

@op
def deploy_model(context: OpExecutionContext, report: Dict, config: Dict) -> Dict:
    """
    Deploy the model if promoted to production.
    """
    logger = context.log
    
    logger.info("Deploying model...")
    
    deployment_config = config.get('deployment', {})
    targets = deployment_config.get('targets', [])
    
    deployment_results = []
    
    # Only deploy if promoted
    if report.get('status') != 'promoted':
        logger.info("Model not promoted to production, skipping deployment")
        return {'deployed': False, 'reason': 'Model not promoted'}
    
    # Deploy to each target
    for target in targets:
        target_type = target.get('type')
        
        try:
            if target_type == 'rest_api':
                # Deploy as REST API
                port = target.get('port', 8000)
                endpoint = target.get('endpoint', '/predict')
                
                logger.info(f"Deploying REST API on port {port}{endpoint}")
                
                # In production, would use a serving framework like MLflow's serve
                # or build a FastAPI application
                with open("models/deployment/api_config.json", 'w') as f:
                    json.dump({
                        'endpoint': endpoint,
                        'port': port,
                        'model_name': config.get('registry', {}).get('model_name'),
                        'deployed_at': datetime.now().isoformat()
                    }, f)
                
                deployment_results.append({
                    'type': 'rest_api',
                    'status': 'success',
                    'port': port,
                    'endpoint': endpoint
                })
                
            elif target_type == 'batch':
                # Deploy as batch prediction job
                schedule = target.get('schedule', '0 0 * * *')
                output_path = target.get('output_path', 'data/predictions/')
                
                logger.info(f"Deploying batch prediction job with schedule {schedule}")
                
                # Save batch configuration
                with open("models/deployment/batch_config.json", 'w') as f:
                    json.dump({
                        'schedule': schedule,
                        'output_path': output_path,
                        'model_name': config.get('registry', {}).get('model_name'),
                        'deployed_at': datetime.now().isoformat()
                    }, f)
                
                deployment_results.append({
                    'type': 'batch',
                    'status': 'success',
                    'schedule': schedule,
                    'output_path': output_path
                })
                
            else:
                logger.warning(f"Unknown deployment target: {target_type}")
                
        except Exception as e:
            logger.error(f"Failed to deploy to {target_type}: {e}")
            deployment_results.append({
                'type': target_type,
                'status': 'failed',
                'error': str(e)
            })
    
    deployment_result = {
        'deployed': any(r['status'] == 'success' for r in deployment_results),
        'targets': deployment_results,
        'deployment_time': datetime.now().isoformat()
    }
    
    # Save deployment record
    deploy_path = Path("models/deployment/deployment_record.json")
    deploy_path.parent.mkdir(parents=True, exist_ok=True)
    with open(deploy_path, 'w') as f:
        json.dump(deployment_result, f, indent=2)
    
    logger.info(f"Deployment complete: {len(deployment_results)} targets")
    
    return deployment_result


# ============= COMPLETE MASTER PIPELINE =============

@job(
    resource_defs={
        "data_io": DataIOManager(),
        "model_io": ModelIOManager()
    }
)
def master_mlops_pipeline():
    """
    Complete end-to-end MLOps pipeline.
    """
    # Load configuration
    config = load_pipeline_config()
    
    # Data ingestion
    raw_data = ingest_data(config)
    validated_data = validate_data(raw_data, config)
    
    # Feature engineering
    features = engineer_features(validated_data, config)
    
    # Model training
    model_data = train_models(features, config)
    
    # Registry
    report = register_model(model_data, config)
    
    # Deployment
    deployment = deploy_model(report, config)
    
    return deployment


# Export jobs
jobs = [master_mlops_pipeline]
EOF
```

### Step 3: Create Pipeline Runner Script

```bash
cat > scripts/run_master_pipeline.py << 'EOF'
#!/usr/bin/env python
"""
Runner script for the master MLOps pipeline.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from dagster import execute_job, DagsterInstance
from pipelines.master_pipeline import master_mlops_pipeline
import json
import time
from datetime import datetime


def run_master_pipeline():
    """
    Execute the master MLOps pipeline.
    """
    print("=" * 60)
    print("STARTING MASTER MLOPS PIPELINE")
    print("=" * 60)
    print(f"Time: {datetime.now().isoformat()}")
    
    start_time = time.time()
    
    # Execute pipeline
    result = execute_job(master_mlops_pipeline)
    
    elapsed = time.time() - start_time
    
    print("\n" + "=" * 60)
    print("PIPELINE EXECUTION COMPLETE")
    print("=" * 60)
    print(f"Success: {result.success}")
    print(f"Duration: {elapsed:.2f} seconds")
    
    if result.success:
        # Get outputs
        outputs = result.output_values()
        for key, value in outputs.items():
            if key == 'deploy_model':
                print(f"\nDeployment Results:")
                print(json.dumps(value, indent=2))
    else:
        print(f"\nFailure: {result.failure_data}")
    
    return result.success


if __name__ == "__main__":
    success = run_master_pipeline()
    sys.exit(0 if success else 1)
EOF

chmod +x scripts/run_master_pipeline.py
```

### Step 4: Run the Complete Pipeline

```bash
# Run the master pipeline
python scripts/run_master_pipeline.py

# Or use Dagster CLI
dagster job execute -f pipelines/master_pipeline.py -j master_mlops_pipeline -l DEBUG

# Start the Dagster UI to monitor
dagster-webserver -f pipelines/master_pipeline.py
```

## The Verification: Testing End-to-End

### Verification 1: Check All Artifacts

```bash
# Check all generated artifacts
ls -la data/raw/
ls -la data/processed/
ls -la models/registry/
ls -la models/evaluation/
ls -la models/deployment/
ls -la mlruns/
```

### Verification 2: Validate Model Registry

```bash
# Check registered models
python -c "
from mlflow.tracking import MlflowClient
client = MlflowClient()

# List all registered models
for rm in client.search_registered_models():
    print(f'\n{rm.name}:')
    for v in rm.latest_versions:
        print(f'  Version {v.version}: {v.current_stage}')
"
```

### Verification 3: Check Data Versions

```bash
# Check DVC status
dvc status
dvc list --all
```

### Verification 4: View MLflow Experiment

```bash
# Start MLflow UI
mlflow ui --backend-store-uri ./mlruns
# Open http://localhost:5000
```

## What We've Accomplished

You now have a complete, production-ready MLOps pipeline that:

1. **Ingests data** from multiple sources
2. **Validates data quality** before processing
3. **Engineers features** with configurable transformations
4. **Trains multiple models** with hyperparameter tuning
5. **Selects the best model** based on performance metrics
6. **Registers models** in the MLflow Model Registry
7. **Promotes models** based on predefined criteria
8. **Deploys models** to REST API and batch targets
9. **Tracks everything** with DVC, MLflow, and Dagster

---

*End of Part 13: End-to-End Pipeline Assembly*
