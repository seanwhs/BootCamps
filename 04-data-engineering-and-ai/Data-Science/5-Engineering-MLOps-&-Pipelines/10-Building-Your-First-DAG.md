# Part 10: Building Your First DAG

## The Target: Advanced DAG Construction with Branching and Error Handling

In this part, we'll build sophisticated DAGs with branching logic, conditional execution, retry strategies, and robust error handling. By the end, you'll have a production-grade pipeline that can handle complex workflows.

## The Concept: DAGs as Decision Trees

Think of a DAG (Directed Acyclic Graph) like a manufacturing assembly line:
- **Linear path**: Parts move from station to station (straight pipeline)
- **Branching**: Different parts go to different stations (conditional logic)
- **Joining**: Parts come together at assembly (merge steps)
- **Error handling**: Quality control stations that catch defects (retries/failures)

Dagster gives you powerful tools to model these complex workflows.

## The Implementation: Building Advanced DAGs

### Step 1: Create a Multi-Branch Pipeline

Let's build a pipeline with multiple branches for different models:

```bash
cat > pipelines/advanced_pipeline.py << 'EOF'
"""
Advanced Dagster pipeline with branching, conditional logic, and error handling.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.preprocessing import StandardScaler
import mlflow
import json
import pickle
from datetime import datetime
import time
import random

from dagster import (
    op, 
    job, 
    graph, 
    Output,
    In,
    Out,
    get_dagster_logger,
    resource,
    Config,
    OpExecutionContext,
    RetryPolicy,
    Failure,
    HookContext,
    hook,
    op_failure_hook,
    asset,
    Nothing
)

from src.utils.dagster_utils import DataIOManager, ModelIOManager


# Define retry policies
retry_policy_3_times = RetryPolicy(
    max_retries=3,
    delay=5,  # seconds
    backoff=2  # exponential backoff multiplier
)

retry_policy_5_times = RetryPolicy(
    max_retries=5,
    delay=10,
    backoff=2
)


# Define failure hooks
@op_failure_hook
def log_failure_hook(context: HookContext, failure: Failure):
    """Hook to log failures with detailed information."""
    logger = get_dagster_logger()
    logger.error(f"Operation failed: {context.op.name}")
    logger.error(f"Error: {failure.message}")
    logger.error(f"Step key: {context.step_key}")
    logger.error(f"Run ID: {context.run_id}")
    
    # Log to file
    log_dir = Path("logs/failures")
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / f"failure_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    with open(log_file, 'w') as f:
        json.dump({
            'op': context.op.name,
            'error': failure.message,
            'step_key': context.step_key,
            'run_id': context.run_id,
            'timestamp': datetime.now().isoformat()
        }, f, indent=2)


# ============= DATA GENERATION OPS =============

@op(
    out=Out(io_manager_key="data_io"),
    retry_policy=retry_policy_3_times,
    tags={"stage": "data_generation"}
)
def generate_batch_data(context: OpExecutionContext) -> pd.DataFrame:
    """Generate a batch of synthetic sensor data."""
    logger = context.log
    
    logger.info("Generating batch sensor data...")
    
    # Simulate occasional failure for testing
    if random.random() < 0.1:  # 10% chance of failure
        raise Exception("Random data generation failure!")
    
    np.random.seed(42)
    n_samples = 1000
    
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
    anomaly_indices = np.random.choice(n_samples, size=50, replace=False)
    df.loc[anomaly_indices, 'temperature'] += np.random.uniform(10, 30, 50)
    df.loc[anomaly_indices, 'vibration'] += np.random.uniform(1, 3, 50)
    df['label'] = 0
    df.loc[anomaly_indices, 'label'] = 1
    
    logger.info(f"Generated {len(df)} samples with {df['label'].sum()} anomalies")
    
    return df


@op(
    ins={"raw_data": In(io_manager_key="data_io")},
    out=Out(io_manager_key="data_io"),
    retry_policy=retry_policy_3_times
)
def clean_and_validate_data(context: OpExecutionContext, raw_data: pd.DataFrame) -> pd.DataFrame:
    """Clean and validate the raw data."""
    logger = context.log
    
    logger.info("Cleaning and validating data...")
    
    # Remove duplicates
    initial_len = len(raw_data)
    raw_data = raw_data.drop_duplicates()
    logger.info(f"Removed {initial_len - len(raw_data)} duplicates")
    
    # Check for missing values
    missing = raw_data.isnull().sum()
    if missing.sum() > 0:
        logger.warning(f"Found missing values: {missing.to_dict()}")
        raw_data = raw_data.fillna(raw_data.mean())
    
    # Validate ranges
    valid_ranges = {
        'sensor_1': (10, 30),
        'sensor_2': (20, 40),
        'sensor_3': (40, 60),
        'temperature': (50, 100),
        'pressure': (0.8, 1.8),
        'vibration': (0.1, 1.0)
    }
    
    for col, (min_val, max_val) in valid_ranges.items():
        if col in raw_data.columns:
            invalid = raw_data[(raw_data[col] < min_val) | (raw_data[col] > max_val)]
            if len(invalid) > 0:
                logger.warning(f"Found {len(invalid)} invalid values in {col}")
                # Clip to valid range
                raw_data[col] = raw_data[col].clip(min_val, max_val)
    
    logger.info(f"Data validated: {len(raw_data)} rows")
    return raw_data


# ============= FEATURE ENGINEERING OPS =============

@op(
    ins={"clean_data": In(io_manager_key="data_io")},
    out=Out(io_manager_key="data_io"),
    retry_policy=retry_policy_3_times
)
def create_features_basic(context: OpExecutionContext, clean_data: pd.DataFrame) -> pd.DataFrame:
    """Create basic features."""
    logger = context.log
    
    logger.info("Creating basic features...")
    
    X = clean_data.drop(columns=['label', 'timestamp'])
    y = clean_data['label']
    
    # Basic features - just use original columns
    X['label'] = y
    
    logger.info(f"Basic features: {X.shape}")
    return X


@op(
    ins={"clean_data": In(io_manager_key="data_io")},
    out=Out(io_manager_key="data_io"),
    retry_policy=retry_policy_3_times
)
def create_features_advanced(context: OpExecutionContext, clean_data: pd.DataFrame) -> pd.DataFrame:
    """Create advanced features with rolling statistics."""
    logger = context.log
    
    logger.info("Creating advanced features...")
    
    X = clean_data.drop(columns=['label', 'timestamp'])
    y = clean_data['label']
    
    # Add rolling statistics
    for col in ['sensor_1', 'sensor_2', 'sensor_3', 'temperature', 'pressure', 'vibration']:
        for window in [5, 10, 30]:
            X[f'{col}_rolling_mean_{window}'] = X[col].rolling(window=window, min_periods=1).mean()
            X[f'{col}_rolling_std_{window}'] = X[col].rolling(window=window, min_periods=1).std()
            X[f'{col}_rolling_max_{window}'] = X[col].rolling(window=window, min_periods=1).max()
            X[f'{col}_rolling_min_{window}'] = X[col].rolling(window=window, min_periods=1).min()
    
    # Add interaction features
    X['temp_pressure_ratio'] = X['temperature'] / (X['pressure'] + 0.001)
    X['sensor_sum'] = X['sensor_1'] + X['sensor_2'] + X['sensor_3']
    
    # Fill NaN values
    X = X.fillna(0)
    
    X['label'] = y
    
    logger.info(f"Advanced features: {X.shape} with {len(X.columns)} columns")
    return X


# ============= MODEL TRAINING OPS =============

@op(
    ins={"features": In(io_manager_key="data_io")},
    out=Out(io_manager_key="model_io"),
    retry_policy=retry_policy_5_times
)
def train_random_forest(context: OpExecutionContext, features: pd.DataFrame) -> dict:
    """Train a Random Forest model."""
    logger = context.log
    
    logger.info("Training Random Forest model...")
    
    X = features.drop(columns=['label'])
    y = features['label']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Hyperparameter tuning simulation
    params = {
        'n_estimators': [100, 200, 300],
        'max_depth': [10, 15, 20],
        'min_samples_split': [2, 5, 10]
    }
    
    # Simple grid search (simplified)
    best_params = {}
    best_score = 0
    
    for n_estimators in params['n_estimators']:
        for max_depth in params['max_depth']:
            model = RandomForestClassifier(
                n_estimators=n_estimators,
                max_depth=max_depth,
                random_state=42,
                n_jobs=-1
            )
            model.fit(X_train_scaled, y_train)
            y_pred = model.predict(X_test_scaled)
            score = f1_score(y_test, y_pred)
            
            if score > best_score:
                best_score = score
                best_params = {
                    'n_estimators': n_estimators,
                    'max_depth': max_depth
                }
                best_model = model
    
    # Evaluate best model
    y_pred = best_model.predict(X_test_scaled)
    metrics = {
        'accuracy': accuracy_score(y_test, y_pred),
        'f1': f1_score(y_test, y_pred),
        'precision': precision_score(y_test, y_pred),
        'recall': recall_score(y_test, y_pred),
        'train_samples': len(X_train),
        'test_samples': len(X_test)
    }
    
    logger.info(f"Random Forest F1: {metrics['f1']:.4f}")
    
    model_data = {
        'model': best_model,
        'scaler': scaler,
        'metrics': metrics,
        'feature_names': X.columns.tolist(),
        'model_type': 'random_forest',
        'params': best_params
    }
    
    return model_data


@op(
    ins={"features": In(io_manager_key="data_io")},
    out=Out(io_manager_key="model_io"),
    retry_policy=retry_policy_5_times
)
def train_gradient_boosting(context: OpExecutionContext, features: pd.DataFrame) -> dict:
    """Train a Gradient Boosting model."""
    logger = context.log
    
    logger.info("Training Gradient Boosting model...")
    
    X = features.drop(columns=['label'])
    y = features['label']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    model = GradientBoostingClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=3,
        random_state=42
    )
    model.fit(X_train_scaled, y_train)
    
    y_pred = model.predict(X_test_scaled)
    metrics = {
        'accuracy': accuracy_score(y_test, y_pred),
        'f1': f1_score(y_test, y_pred),
        'precision': precision_score(y_test, y_pred),
        'recall': recall_score(y_test, y_pred),
        'train_samples': len(X_train),
        'test_samples': len(X_test)
    }
    
    logger.info(f"Gradient Boosting F1: {metrics['f1']:.4f}")
    
    model_data = {
        'model': model,
        'scaler': scaler,
        'metrics': metrics,
        'feature_names': X.columns.tolist(),
        'model_type': 'gradient_boosting',
        'params': {
            'n_estimators': 100,
            'learning_rate': 0.1,
            'max_depth': 3
        }
    }
    
    return model_data


@op(
    ins={"features": In(io_manager_key="data_io")},
    out=Out(io_manager_key="model_io"),
    retry_policy=retry_policy_3_times
)
def train_logistic_regression(context: OpExecutionContext, features: pd.DataFrame) -> dict:
    """Train a Logistic Regression model."""
    logger = context.log
    
    logger.info("Training Logistic Regression model...")
    
    X = features.drop(columns=['label'])
    y = features['label']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    model = LogisticRegression(
        max_iter=1000,
        random_state=42,
        class_weight='balanced'
    )
    model.fit(X_train_scaled, y_train)
    
    y_pred = model.predict(X_test_scaled)
    metrics = {
        'accuracy': accuracy_score(y_test, y_pred),
        'f1': f1_score(y_test, y_pred),
        'precision': precision_score(y_test, y_pred),
        'recall': recall_score(y_test, y_pred),
        'train_samples': len(X_train),
        'test_samples': len(X_test)
    }
    
    logger.info(f"Logistic Regression F1: {metrics['f1']:.4f}")
    
    model_data = {
        'model': model,
        'scaler': scaler,
        'metrics': metrics,
        'feature_names': X.columns.tolist(),
        'model_type': 'logistic_regression',
        'params': {
            'max_iter': 1000,
            'class_weight': 'balanced'
        }
    }
    
    return model_data


# ============= MODEL SELECTION OP =============

@op(
    ins={
        "rf_model": In(io_manager_key="model_io"),
        "gb_model": In(io_manager_key="model_io"),
        "lr_model": In(io_manager_key="model_io")
    },
    out=Out(io_manager_key="model_io")
)
def select_best_model(context: OpExecutionContext, 
                      rf_model: dict, 
                      gb_model: dict, 
                      lr_model: dict) -> dict:
    """Select the best model based on F1 score."""
    logger = context.log
    
    logger.info("Selecting best model...")
    
    models = {
        'random_forest': rf_model,
        'gradient_boosting': gb_model,
        'logistic_regression': lr_model
    }
    
    best_score = 0
    best_name = None
    best_model_data = None
    
    for name, model_data in models.items():
        f1 = model_data['metrics']['f1']
        logger.info(f"  {name}: F1 = {f1:.4f}")
        
        if f1 > best_score:
            best_score = f1
            best_name = name
            best_model_data = model_data
    
    # Add selection info
    best_model_data['selected'] = True
    best_model_data['selection_info'] = {
        'selected_model': best_name,
        'selected_score': best_score,
        'models_evaluated': list(models.keys())
    }
    
    # Log to MLflow
    with mlflow.start_run(run_name=f"model_selection_{datetime.now().strftime('%Y%m%d_%H%M%S')}"):
        mlflow.log_param("selected_model", best_name)
        mlflow.log_metric("selected_f1", best_score)
        mlflow.log_dict(best_model_data['selection_info'], "selection_info.json")
    
    logger.info(f"Selected {best_name} with F1 = {best_score:.4f}")
    
    return best_model_data


# ============= EVALUATION AND DEPLOYMENT OPS =============

@op(
    ins={"best_model": In(io_manager_key="model_io")}
)
def evaluate_and_promote(context: OpExecutionContext, best_model: dict) -> dict:
    """Evaluate the best model and decide on promotion."""
    logger = context.log
    
    logger.info("Evaluating model for promotion...")
    
    f1_score = best_model['metrics']['f1']
    
    # Check if model meets promotion criteria
    if f1_score >= 0.80:
        status = "promoted_to_production"
        logger.info(f"✅ Model F1 ({f1_score:.4f}) meets criteria, promoting!")
    elif f1_score >= 0.70:
        status = "staging_ready"
        logger.info(f"⚠️ Model F1 ({f1_score:.4f}) meets staging criteria")
    else:
        status = "needs_improvement"
        logger.info(f"❌ Model F1 ({f1_score:.4f}) needs improvement")
    
    # Save evaluation report
    report = {
        'model_type': best_model['model_type'],
        'f1_score': f1_score,
        'status': status,
        'metrics': best_model['metrics'],
        'evaluation_time': datetime.now().isoformat()
    }
    
    report_path = Path("models/evaluation/promotion_report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    
    return report


# ============= ASSEMBLE THE DAG =============

@job(
    resource_defs={
        "data_io": DataIOManager(),
        "model_io": ModelIOManager()
    },
    hooks={"log_failure": log_failure_hook}
)
def advanced_mlops_pipeline():
    """
    Advanced MLOps pipeline with branching and conditional logic.
    """
    # Data generation stage
    raw_data = generate_batch_data()
    clean_data = clean_and_validate_data(raw_data)
    
    # Feature engineering - two parallel branches
    basic_features = create_features_basic(clean_data)
    advanced_features = create_features_advanced(clean_data)
    
    # Model training - parallel training on both feature sets
    # Random Forest
    rf_basic = train_random_forest(basic_features)
    rf_advanced = train_random_forest(advanced_features)
    
    # Gradient Boosting
    gb_basic = train_gradient_boosting(basic_features)
    gb_advanced = train_gradient_boosting(advanced_features)
    
    # Logistic Regression
    lr_basic = train_logistic_regression(basic_features)
    lr_advanced = train_logistic_regression(advanced_features)
    
    # Combine all models
    all_models = [rf_basic, rf_advanced, gb_basic, gb_advanced, lr_basic, lr_advanced]
    
    # Since we can't dynamically select from list, we'll choose the best manually
    # For simplicity, we select the best from each category
    
    # Simple selection logic using an op that takes all models
    best_rf = rf_advanced if rf_advanced['metrics']['f1'] > rf_basic['metrics']['f1'] else rf_basic
    best_gb = gb_advanced if gb_advanced['metrics']['f1'] > gb_basic['metrics']['f1'] else gb_basic
    best_lr = lr_advanced if lr_advanced['metrics']['f1'] > lr_basic['metrics']['f1'] else lr_basic
    
    # Select the best overall
    best_model = select_best_model(best_rf, best_gb, best_lr)
    
    # Final evaluation
    evaluation = evaluate_and_promote(best_model)
    
    return evaluation


# Export for Dagster
jobs = [advanced_mlops_pipeline]
EOF
```

### Step 2: Create a Graph with Sub-Graphs

Now let's create reusable sub-graphs:

```bash
cat > pipelines/sub_graphs.py << 'EOF'
"""
Reusable sub-graphs for Dagster pipelines.
"""

from dagster import graph, op, job, In, Out
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split


@op
def load_data() -> pd.DataFrame:
    """Load data from a file."""
    import pandas as pd
    # In practice, load from actual source
    return pd.DataFrame({'feature': [1, 2, 3], 'label': [0, 1, 0]})


@op
def preprocess_data(data: pd.DataFrame) -> pd.DataFrame:
    """Preprocess the data."""
    return data


@op
def split_data(data: pd.DataFrame) -> tuple:
    """Split data into train and test."""
    X = data.drop(columns=['label'])
    y = data['label']
    return train_test_split(X, y, test_size=0.2, random_state=42)


@op
def train_model(X_train, y_train):
    """Train a model."""
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    return model


@op
def evaluate_model(model, X_test, y_test):
    """Evaluate the model."""
    from sklearn.metrics import accuracy_score
    y_pred = model.predict(X_test)
    return {'accuracy': accuracy_score(y_test, y_pred)}


@graph
def model_training_subgraph():
    """
    Reusable sub-graph for model training.
    """
    data = load_data()
    processed = preprocess_data(data)
    X_train, X_test, y_train, y_test = split_data(processed)
    model = train_model(X_train, y_train)
    metrics = evaluate_model(model, X_test, y_test)
    return metrics


@graph
def data_processing_subgraph():
    """
    Reusable sub-graph for data processing.
    """
    data = load_data()
    processed = preprocess_data(data)
    return processed


# Create jobs from sub-graphs
full_pipeline_job = model_training_subgraph.to_job()
processing_job = data_processing_subgraph.to_job()


# Export for Dagster
jobs = [full_pipeline_job, processing_job]
EOF
```

### Step 3: Create Configuration-Driven Pipeline

Now let's make our pipeline configurable:

```bash
cat > pipelines/configurable_pipeline.py << 'EOF'
"""
Configurable Dagster pipeline with dynamic configuration.
"""

from dagster import (
    job, 
    op, 
    Config, 
    In, 
    Out,
    ConfigurableResource,
    EnvVar,
    OpExecutionContext
)
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import f1_score, accuracy_score
import mlflow


class ModelTrainingConfig(Config):
    """Configuration for model training."""
    model_type: str = "random_forest"
    test_size: float = 0.2
    random_state: int = 42
    n_estimators: int = 100
    max_depth: int = 10
    learning_rate: float = 0.1


class DataConfig(Config):
    """Configuration for data generation."""
    n_samples: int = 1000
    anomaly_rate: float = 0.05
    random_seed: int = 42


@op(
    config_schema=DataConfig
)
def generate_configurable_data(context: OpExecutionContext) -> pd.DataFrame:
    """Generate data using configuration."""
    config = context.op_config
    
    import numpy as np
    np.random.seed(config.random_seed)
    
    n_samples = config.n_samples
    
    data = {
        'feature_1': np.random.normal(0, 1, n_samples),
        'feature_2': np.random.normal(0, 1, n_samples),
        'feature_3': np.random.normal(0, 1, n_samples)
    }
    
    df = pd.DataFrame(data)
    
    # Add labels
    df['label'] = np.random.binomial(1, config.anomaly_rate, n_samples)
    
    context.log.info(f"Generated {n_samples} samples with anomaly rate {config.anomaly_rate}")
    return df


@op(
    config_schema=ModelTrainingConfig
)
def train_configurable_model(context: OpExecutionContext, data: pd.DataFrame) -> dict:
    """Train a model using configuration."""
    config = context.op_config
    
    X = data.drop(columns=['label'])
    y = data['label']
    
    from sklearn.model_selection import train_test_split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=config.test_size, random_state=config.random_state
    )
    
    # Select model based on configuration
    if config.model_type == "random_forest":
        model = RandomForestClassifier(
            n_estimators=config.n_estimators,
            max_depth=config.max_depth,
            random_state=config.random_state,
            n_jobs=-1
        )
    elif config.model_type == "gradient_boosting":
        model = GradientBoostingClassifier(
            n_estimators=config.n_estimators,
            learning_rate=config.learning_rate,
            max_depth=config.max_depth,
            random_state=config.random_state
        )
    else:
        model = LogisticRegression(
            max_iter=1000,
            random_state=config.random_state
        )
    
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    
    metrics = {
        'accuracy': accuracy_score(y_test, y_pred),
        'f1': f1_score(y_test, y_pred),
        'model_type': config.model_type,
        'test_size': config.test_size
    }
    
    context.log.info(f"Model metrics: {metrics}")
    
    # Log to MLflow
    with mlflow.start_run(run_name=f"config_train_{config.model_type}"):
        mlflow.log_params(config.dict())
        mlflow.log_metrics(metrics)
    
    return metrics


@job
def configurable_mlops_pipeline():
    """Configurable MLOps pipeline."""
    data = generate_configurable_data()
    metrics = train_configurable_model(data)
    return metrics
EOF
```

### Step 4: Create a Testing Script

```bash
cat > scripts/test_advanced_pipeline.py << 'EOF'
#!/usr/bin/env python
"""
Test script for advanced Dagster pipelines.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from dagster import execute_job, materialize
from pipelines.advanced_pipeline import advanced_mlops_pipeline
from pipelines.configurable_pipeline import configurable_mlops_pipeline, DataConfig, ModelTrainingConfig
import json
import yaml


def test_advanced_pipeline():
    """Test the advanced pipeline execution."""
    print("=" * 60)
    print("Testing Advanced MLOps Pipeline")
    print("=" * 60)
    
    # Execute the pipeline
    result = execute_job(advanced_mlops_pipeline)
    
    print(f"Success: {result.success}")
    
    if result.success:
        # Get outputs
        output_values = result.output_values()
        for key, value in output_values.items():
            if isinstance(value, dict):
                print(f"{key}: {json.dumps(value, indent=2)}")
    else:
        print(f"Failure: {result.failure_data}")
    
    return result.success


def test_configurable_pipeline():
    """Test the configurable pipeline."""
    print("\n" + "=" * 60)
    print("Testing Configurable Pipeline")
    print("=" * 60)
    
    # Run with different configurations
    configs = [
        {"model_type": "random_forest", "n_estimators": 50, "max_depth": 5},
        {"model_type": "random_forest", "n_estimators": 200, "max_depth": 15},
        {"model_type": "gradient_boosting", "n_estimators": 100, "learning_rate": 0.1},
        {"model_type": "logistic_regression"}
    ]
    
    results = []
    for config in configs:
        print(f"\nRunning with config: {config}")
        
        result = execute_job(
            configurable_mlops_pipeline,
            run_config={
                "ops": {
                    "generate_configurable_data": {
                        "config": {"n_samples": 500, "anomaly_rate": 0.05}
                    },
                    "train_configurable_model": {
                        "config": config
                    }
                }
            }
        )
        
        success = result.success
        metrics = result.output_values().get('result')
        
        results.append({
            'config': config,
            'success': success,
            'metrics': metrics
        })
        
        print(f"Success: {success}")
        if metrics:
            print(f"Metrics: {json.dumps(metrics, indent=2)}")
    
    return results


if __name__ == "__main__":
    success1 = test_advanced_pipeline()
    results2 = test_configurable_pipeline()
    
    if success1:
        print("\n✅ Advanced pipeline test passed!")
    else:
        print("\n❌ Advanced pipeline test failed!")
    
    sys.exit(0 if success1 else 1)
EOF

chmod +x scripts/test_advanced_pipeline.py
```

### Step 5: Run the Advanced Pipeline

```bash
# Run the advanced pipeline
python scripts/test_advanced_pipeline.py

# Or use Dagster CLI
dagster job execute -f pipelines/advanced_pipeline.py -j advanced_mlops_pipeline

# View the UI
dagster-webserver -f pipelines/advanced_pipeline.py
```

## The Verification: Testing Advanced Features

### Verification 1: Test Retry Policies

```bash
# Simulate failures and watch retries
dagster job execute -f pipelines/advanced_pipeline.py -j advanced_mlops_pipeline -l DEBUG

# Check logs for retry attempts
tail -f logs/failures/*.json
```

### Verification 2: Test Configuration

```bash
# Run with custom configuration
dagster job execute \
    -f pipelines/configurable_pipeline.py \
    -j configurable_mlops_pipeline \
    -c configs/pipeline_config.yaml
```

### Verification 3: Check Branching Execution

```bash
# View the DAG structure
dagster job describe -f pipelines/advanced_pipeline.py -j advanced_mlops_pipeline

# Expected output shows multiple branches
```

## What We've Accomplished

You now have a sophisticated Dagster pipeline that:

1. **Implements branching logic** with parallel model training
2. **Uses retry policies** for fault tolerance
3. **Has failure hooks** for error logging
4. **Supports configuration-driven execution**
5. **Includes sub-graphs** for reusability
6. **Provides detailed logging** and monitoring
7. **Handles complex workflows** with multiple stages

## Next Steps

In Part 11, we'll:
- Implement sensors for event-driven pipelines
- Set up schedules for automated execution
- Handle dependency management
- Monitor pipeline performance

---

*End of Part 10: Building Your First DAG*
