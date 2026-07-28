# Part 4: Managing Data Pipelines with DVC

## The Target: Advanced DVC Pipeline Management

In this part, we'll master DVC's pipeline capabilities, learning how to create complex, multi-stage data pipelines with proper dependency management, caching, and parameterization. By the end, you'll have a production-grade DVC pipeline that automatically handles data transformations, feature engineering, and model training.

## The Concept: DVC Pipelines as Directed Acyclic Graphs (DAGs)

Think of a DVC pipeline like a recipe with multiple steps:
- Each step has **inputs** (ingredients) and **outputs** (dishes)
- Steps must happen in the **right order** (you can't bake before mixing)
- If an ingredient changes, only the steps that depend on it need to be redone

DVC automatically tracks these dependencies and only re-runs steps that have changed, saving you time and ensuring reproducibility.

## The Implementation: Building Advanced DVC Pipelines

### Step 1: Extend Our Pipeline with Model Training

Let's expand our DVC pipeline to include model training and evaluation:

```bash
# Create a model training script
cat > models/training/train_model.py << 'EOF'
#!/usr/bin/env python
"""
Machine learning model training for predictive maintenance.
Trains multiple models and selects the best one.
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
from sklearn.preprocessing import StandardScaler
import pickle
import argparse
import logging
from pathlib import Path
import json
import sys

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def load_data(features_path: str) -> pd.DataFrame:
    """
    Load features dataset.
    
    Args:
        features_path: Path to features CSV
        
    Returns:
        DataFrame with features and labels
    """
    logger.info(f"Loading features from {features_path}")
    df = pd.read_csv(features_path)
    logger.info(f"Loaded {len(df):,} rows with {len(df.columns)} columns")
    return df


def prepare_data(df: pd.DataFrame, target_col: str = 'label') -> tuple:
    """
    Split data into features and target, and into train/test sets.
    
    Args:
        df: DataFrame with features and target
        target_col: Name of the target column
        
    Returns:
        X_train, X_test, y_train, y_test, feature_names
    """
    # Separate features and target
    X = df.drop(columns=[target_col, 'timestamp'] if 'timestamp' in df.columns else [target_col])
    y = df[target_col]
    
    # Store feature names for later
    feature_names = X.columns.tolist()
    
    # Split into train and test
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Convert back to DataFrame (for feature names)
    X_train_scaled = pd.DataFrame(X_train_scaled, columns=feature_names)
    X_test_scaled = pd.DataFrame(X_test_scaled, columns=feature_names)
    
    logger.info(f"Training set: {len(X_train_scaled):,} samples")
    logger.info(f"Test set: {len(X_test_scaled):,} samples")
    logger.info(f"Features: {len(feature_names)}")
    
    return X_train_scaled, X_test_scaled, y_train, y_test, feature_names, scaler


def train_models(X_train, y_train, X_test, y_test) -> dict:
    """
    Train multiple models and evaluate them.
    
    Args:
        X_train, y_train: Training data
        X_test, y_test: Test data
        
    Returns:
        Dictionary with trained models and their metrics
    """
    models = {
        'logistic_regression': LogisticRegression(max_iter=1000, random_state=42),
        'random_forest': RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1),
        'gradient_boosting': GradientBoostingClassifier(n_estimators=100, random_state=42)
    }
    
    results = {}
    
    for name, model in models.items():
        logger.info(f"Training {name}...")
        model.fit(X_train, y_train)
        
        # Make predictions
        y_pred = model.predict(X_test)
        y_pred_proba = model.predict_proba(X_test)[:, 1] if hasattr(model, 'predict_proba') else None
        
        # Calculate metrics
        metrics = {
            'accuracy': accuracy_score(y_test, y_pred),
            'precision': precision_score(y_test, y_pred),
            'recall': recall_score(y_test, y_pred),
            'f1': f1_score(y_test, y_pred)
        }
        
        # Add ROC-AUC if probability predictions are available
        if y_pred_proba is not None:
            metrics['roc_auc'] = roc_auc_score(y_test, y_pred_proba)
        
        results[name] = {
            'model': model,
            'metrics': metrics,
            'predictions': y_pred
        }
        
        logger.info(f"{name} - Accuracy: {metrics['accuracy']:.4f}, F1: {metrics['f1']:.4f}")
    
    return results


def select_best_model(results: dict) -> tuple:
    """
    Select the best model based on F1 score.
    
    Args:
        results: Dictionary with model results
        
    Returns:
        Best model name, best model object, best model metrics
    """
    best_name = max(results.keys(), key=lambda k: results[k]['metrics']['f1'])
    best_model = results[best_name]['model']
    best_metrics = results[best_name]['metrics']
    
    logger.info(f"Best model: {best_name} with F1 score: {best_metrics['f1']:.4f}")
    return best_name, best_model, best_metrics


def save_model(model, scaler, feature_names, metrics, model_name, output_path: str):
    """
    Save the trained model, scaler, and metadata.
    
    Args:
        model: Trained model
        scaler: Fitted StandardScaler
        feature_names: List of feature names
        metrics: Dictionary of model metrics
        model_name: Name of the model
        output_path: Where to save the model artifacts
    """
    output_dir = Path(output_path).parent
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Save model
    model_path = output_path
    with open(model_path, 'wb') as f:
        pickle.dump({
            'model': model,
            'scaler': scaler,
            'feature_names': feature_names,
            'metrics': metrics,
            'model_name': model_name
        }, f)
    
    # Save metrics as JSON
    metrics_path = str(Path(output_path).with_suffix('.json'))
    with open(metrics_path, 'w') as f:
        json.dump({
            'model_name': model_name,
            'metrics': metrics,
            'feature_count': len(feature_names),
            'training_date': pd.Timestamp.now().isoformat()
        }, f, indent=2)
    
    logger.info(f"Model saved to {model_path}")
    logger.info(f"Metrics saved to {metrics_path}")


def train_pipeline(
    features_path: str,
    model_output_path: str,
    test_size: float = 0.2,
    random_state: int = 42
) -> dict:
    """
    Complete training pipeline.
    
    Args:
        features_path: Path to features CSV
        model_output_path: Where to save the model
        test_size: Proportion of data for testing
        random_state: Random seed for reproducibility
        
    Returns:
        Dictionary with training results
    """
    # 1. Load data
    df = load_data(features_path)
    
    # 2. Prepare data
    X_train, X_test, y_train, y_test, feature_names, scaler = prepare_data(df)
    
    # 3. Train models
    results = train_models(X_train, y_train, X_test, y_test)
    
    # 4. Select best model
    best_name, best_model, best_metrics = select_best_model(results)
    
    # 5. Save model
    save_model(best_model, scaler, feature_names, best_metrics, best_name, model_output_path)
    
    return {
        'best_model': best_name,
        'metrics': best_metrics,
        'feature_count': len(feature_names),
        'training_samples': len(X_train),
        'test_samples': len(X_test)
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train predictive maintenance models")
    parser.add_argument("--features", type=str, default="data/processed/features_48h.csv",
                       help="Path to features CSV")
    parser.add_argument("--output", type=str, default="models/registry/model.pkl",
                       help="Output path for trained model")
    parser.add_argument("--test_size", type=float, default=0.2,
                       help="Proportion of data for testing")
    parser.add_argument("--random_state", type=int, default=42,
                       help="Random seed for reproducibility")
    
    args = parser.parse_args()
    
    results = train_pipeline(
        features_path=args.features,
        model_output_path=args.output,
        test_size=args.test_size,
        random_state=args.random_state
    )
    
    print("\nTraining completed successfully!")
    print(f"Best model: {results['best_model']}")
    print(f"Metrics: {results['metrics']}")
EOF

# Make the script executable
chmod +x models/training/train_model.py
```

### Step 2: Create a Model Evaluation Script

```bash
cat > models/training/evaluate_model.py << 'EOF'
#!/usr/bin/env python
"""
Model evaluation script for trained models.
Generates detailed evaluation reports and visualizations.
"""

import pandas as pd
import numpy as np
import pickle
import json
import argparse
import logging
from pathlib import Path
from sklearn.metrics import classification_report, confusion_matrix, roc_curve, auc
import matplotlib.pyplot as plt
import seaborn as sns

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def load_model_and_data(model_path: str, features_path: str):
    """
    Load saved model and test data.
    
    Args:
        model_path: Path to saved model pickle
        features_path: Path to features CSV
        
    Returns:
        model, scaler, feature_names, X_test, y_test
    """
    # Load model
    with open(model_path, 'rb') as f:
        model_data = pickle.load(f)
    
    model = model_data['model']
    scaler = model_data['scaler']
    feature_names = model_data['feature_names']
    
    # Load data
    df = pd.read_csv(features_path)
    
    # Prepare test data
    X = df.drop(columns=['label', 'timestamp'] if 'timestamp' in df.columns else ['label'])
    y = df['label']
    
    # Filter to only features used in training
    X = X[feature_names]
    
    # Scale features
    X_scaled = scaler.transform(X)
    X_scaled = pd.DataFrame(X_scaled, columns=feature_names)
    
    return model, X_scaled, y, feature_names


def generate_evaluation_report(model, X_test, y_test, feature_names, output_dir: str):
    """
    Generate comprehensive evaluation report.
    
    Args:
        model: Trained model
        X_test: Test features
        y_test: Test labels
        feature_names: List of feature names
        output_dir: Directory to save reports
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Make predictions
    y_pred = model.predict(X_test)
    y_pred_proba = model.predict_proba(X_test)[:, 1] if hasattr(model, 'predict_proba') else None
    
    # Classification report
    report = classification_report(y_test, y_pred, output_dict=True)
    report_df = pd.DataFrame(report).transpose()
    report_df.to_csv(output_dir / 'classification_report.csv')
    
    # Confusion matrix
    cm = confusion_matrix(y_test, y_pred)
    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues')
    plt.title('Confusion Matrix')
    plt.ylabel('True Label')
    plt.xlabel('Predicted Label')
    plt.savefig(output_dir / 'confusion_matrix.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # Feature importance (if available)
    if hasattr(model, 'feature_importances_'):
        importances = model.feature_importances_
        feature_importance_df = pd.DataFrame({
            'feature': feature_names,
            'importance': importances
        }).sort_values('importance', ascending=False)
        
        feature_importance_df.to_csv(output_dir / 'feature_importance.csv', index=False)
        
        plt.figure(figsize=(10, 6))
        top_features = feature_importance_df.head(20)
        plt.barh(top_features['feature'], top_features['importance'])
        plt.xlabel('Feature Importance')
        plt.title('Top 20 Feature Importances')
        plt.tight_layout()
        plt.savefig(output_dir / 'feature_importance.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    # ROC curve (if probability predictions available)
    if y_pred_proba is not None:
        fpr, tpr, _ = roc_curve(y_test, y_pred_proba)
        roc_auc = auc(fpr, tpr)
        
        plt.figure(figsize=(8, 6))
        plt.plot(fpr, tpr, label=f'ROC curve (AUC = {roc_auc:.3f})')
        plt.plot([0, 1], [0, 1], 'k--', label='Random')
        plt.xlabel('False Positive Rate')
        plt.ylabel('True Positive Rate')
        plt.title('ROC Curve')
        plt.legend(loc='lower right')
        plt.savefig(output_dir / 'roc_curve.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    # Save summary metrics
    summary = {
        'accuracy': report['accuracy'],
        'precision_anomaly': report['1']['precision'],
        'recall_anomaly': report['1']['recall'],
        'f1_anomaly': report['1']['f1-score'],
        'roc_auc': roc_auc if y_pred_proba is not None else None,
        'test_samples': len(y_test),
        'anomaly_samples': int(y_test.sum()),
        'normal_samples': int(len(y_test) - y_test.sum())
    }
    
    with open(output_dir / 'summary.json', 'w') as f:
        json.dump(summary, f, indent=2)
    
    logger.info(f"Evaluation reports saved to {output_dir}")
    logger.info(f"Summary: {summary}")


def evaluate_pipeline(model_path: str, features_path: str, output_dir: str):
    """
    Complete evaluation pipeline.
    
    Args:
        model_path: Path to saved model
        features_path: Path to features CSV
        output_dir: Directory to save reports
    """
    logger.info("Starting model evaluation...")
    
    # Load model and data
    model, X_test, y_test, feature_names = load_model_and_data(model_path, features_path)
    
    # Generate evaluation report
    generate_evaluation_report(model, X_test, y_test, feature_names, output_dir)
    
    logger.info("Evaluation completed successfully!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Evaluate trained model")
    parser.add_argument("--model", type=str, default="models/registry/model.pkl",
                       help="Path to model pickle")
    parser.add_argument("--features", type=str, default="data/processed/features_48h.csv",
                       help="Path to features CSV")
    parser.add_argument("--output", type=str, default="models/evaluation/report",
                       help="Output directory for reports")
    
    args = parser.parse_args()
    
    evaluate_pipeline(
        model_path=args.model,
        features_path=args.features,
        output_dir=args.output
    )
EOF

chmod +x models/training/evaluate_model.py
```

### Step 3: Update DVC Pipeline with Training Stages

```bash
# Create a comprehensive DVC pipeline
cat > dvc.yaml << 'EOF'
# DVC Pipeline for Predictive Maintenance
# Stages:
# 1. Generate raw data
# 2. Build features
# 3. Train model
# 4. Evaluate model

vars:
  - data_dir: data
  - model_dir: models

stages:
  # Stage 1: Generate raw sensor data (48h)
  generate_raw_data_48h:
    cmd: python src/data/generate_sensor_data.py --hours 48 --output ${data_dir}/raw/sensor_data_48h.csv
    deps:
      - src/data/generate_sensor_data.py
    outs:
      - ${data_dir}/raw/sensor_data_48h.csv
    metrics:
      - ${data_dir}/raw/sensor_data_48h_metrics.json:
          cache: false
  
  # Stage 2: Generate raw sensor data (168h)
  generate_raw_data_168h:
    cmd: python src/data/generate_sensor_data.py --hours 168 --sampling_rate 30 --anomaly_rate 0.03 --output ${data_dir}/raw/sensor_data_168h.csv
    deps:
      - src/data/generate_sensor_data.py
    outs:
      - ${data_dir}/raw/sensor_data_168h.csv
    metrics:
      - ${data_dir}/raw/sensor_data_168h_metrics.json:
          cache: false
  
  # Stage 3: Build features (48h)
  build_features_48h:
    cmd: python src/features/build_features.py --input ${data_dir}/raw/sensor_data_48h.csv --output ${data_dir}/processed/features_48h.csv
    deps:
      - src/features/build_features.py
      - ${data_dir}/raw/sensor_data_48h.csv
    outs:
      - ${data_dir}/processed/features_48h.csv
    params:
      - src/features/build_features.py # Track changes to the script
    metrics:
      - ${data_dir}/processed/features_48h_stats.json:
          cache: false
  
  # Stage 4: Build features (168h)
  build_features_168h:
    cmd: python src/features/build_features.py --input ${data_dir}/raw/sensor_data_168h.csv --output ${data_dir}/processed/features_168h.csv --windows 5 10 30 60 120
    deps:
      - src/features/build_features.py
      - ${data_dir}/raw/sensor_data_168h.csv
    outs:
      - ${data_dir}/processed/features_168h.csv
    params:
      - src/features/build_features.py
    metrics:
      - ${data_dir}/processed/features_168h_stats.json:
          cache: false
  
  # Stage 5: Train model on 48h data
  train_model_48h:
    cmd: python models/training/train_model.py --features ${data_dir}/processed/features_48h.csv --output ${model_dir}/registry/model_48h.pkl
    deps:
      - models/training/train_model.py
      - ${data_dir}/processed/features_48h.csv
    outs:
      - ${model_dir}/registry/model_48h.pkl
    metrics:
      - ${model_dir}/registry/model_48h.json:
          cache: false
    params:
      - models/training/train_model.py
  
  # Stage 6: Train model on 168h data
  train_model_168h:
    cmd: python models/training/train_model.py --features ${data_dir}/processed/features_168h.csv --output ${model_dir}/registry/model_168h.pkl
    deps:
      - models/training/train_model.py
      - ${data_dir}/processed/features_168h.csv
    outs:
      - ${model_dir}/registry/model_168h.pkl
    metrics:
      - ${model_dir}/registry/model_168h.json:
          cache: false
    params:
      - models/training/train_model.py
  
  # Stage 7: Evaluate model on 48h data
  evaluate_model_48h:
    cmd: python models/training/evaluate_model.py --model ${model_dir}/registry/model_48h.pkl --features ${data_dir}/processed/features_48h.csv --output ${model_dir}/evaluation/report_48h
    deps:
      - models/training/evaluate_model.py
      - ${model_dir}/registry/model_48h.pkl
      - ${data_dir}/processed/features_48h.csv
    outs:
      - ${model_dir}/evaluation/report_48h
    metrics:
      - ${model_dir}/evaluation/report_48h/summary.json:
          cache: false
  
  # Stage 8: Evaluate model on 168h data
  evaluate_model_168h:
    cmd: python models/training/evaluate_model.py --model ${model_dir}/registry/model_168h.pkl --features ${data_dir}/processed/features_168h.csv --output ${model_dir}/evaluation/report_168h
    deps:
      - models/training/evaluate_model.py
      - ${model_dir}/registry/model_168h.pkl
      - ${data_dir}/processed/features_168h.csv
    outs:
      - ${model_dir}/evaluation/report_168h
    metrics:
      - ${model_dir}/evaluation/report_168h/summary.json:
          cache: false

# Add metadata
meta:
  name: Predictive Maintenance Pipeline
  version: 1.0.0
  description: End-to-end ML pipeline for predictive maintenance
EOF
```

### Step 4: Create Parameter Configuration

DVC supports parameterization through params files:

```bash
# Create a parameters file
cat > params.yaml << 'EOF'
# Pipeline parameters
data:
  raw:
    hours: [48, 168]
    sampling_rate: 60
    anomaly_rate: 0.05
  
  processed:
    rolling_windows: [5, 10, 30, 60, 120]
    test_size: 0.2

model:
  training:
    test_size: 0.2
    random_state: 42
    models:
      - logistic_regression
      - random_forest
      - gradient_boosting
  
  random_forest:
    n_estimators: 100
    max_depth: null
    min_samples_split: 2
  
  gradient_boosting:
    n_estimators: 100
    learning_rate: 0.1
    max_depth: 3

evaluation:
  output_dir: models/evaluation
  plots: true
  feature_importance_top_n: 20
EOF

# Update dvc.yaml to use params
# Add this to dvc.yaml:
cat >> dvc.yaml << 'EOF'

params:
  - params.yaml
EOF
```

### Step 5: Run the Complete Pipeline

```bash
# Now run the entire pipeline
dvc repro

# This will run all stages in the correct order:
# generate_raw_data_48h → build_features_48h → train_model_48h → evaluate_model_48h
# generate_raw_data_168h → build_features_168h → train_model_168h → evaluate_model_168h

# View the pipeline status
dvc status

# Show the pipeline graph
dvc dag

# View all metrics
dvc metrics show
```

### Step 6: Create a Pipeline with Conditional Logic

DVC doesn't support native conditional logic, but we can use shell scripts to implement it:

```bash
cat > scripts/conditional_pipeline.sh << 'EOF'
#!/bin/bash
# Conditional pipeline execution

echo "Starting conditional pipeline..."

# Check if we should run the 48h or 168h pipeline
DATA_VERSION=${1:-48h}

case $DATA_VERSION in
    48h)
        echo "Running 48h pipeline..."
        dvc repro generate_raw_data_48h
        dvc repro build_features_48h
        dvc repro train_model_48h
        dvc repro evaluate_model_48h
        ;;
    168h)
        echo "Running 168h pipeline..."
        dvc repro generate_raw_data_168h
        dvc repro build_features_168h
        dvc repro train_model_168h
        dvc repro evaluate_model_168h
        ;;
    all)
        echo "Running full pipeline..."
        dvc repro
        ;;
    *)
        echo "Unknown data version: $DATA_VERSION"
        echo "Valid options: 48h, 168h, all"
        exit 1
        ;;
esac

echo "Pipeline execution completed!"
EOF

chmod +x scripts/conditional_pipeline.sh

# Test the script
./scripts/conditional_pipeline.sh 48h
```

### Step 7: Implement Pipeline Versioning

```bash
# Create a versioning system for your pipeline
cat > scripts/version_pipeline.sh << 'EOF'
#!/bin/bash
# Version and tag the current pipeline state

VERSION_TAG=${1:-v1.0.0}
PIPELINE_NAME=${2:-predictive_maintenance}

echo "Creating pipeline version: $VERSION_TAG"

# 1. Check that all stages are up to date
if ! dvc status | grep -q "up to date"; then
    echo "ERROR: Pipeline has uncommitted changes!"
    echo "Run 'dvc status' to see what has changed."
    exit 1
fi

# 2. Save current metrics as baseline
dvc metrics show --json > metrics_${VERSION_TAG}.json

# 3. Create a tag in Git
git tag -a "pipeline_${VERSION_TAG}" -m "Pipeline version ${VERSION_TAG}"

# 4. Tag DVC data
for file in $(dvc list --all); do
    dvc tag $file ${VERSION_TAG}
done

# 5. Push tags
dvc push --all-tags
git push --tags

echo "Pipeline version ${VERSION_TAG} created!"
echo "To reproduce this pipeline, run:"
echo "  git checkout pipeline_${VERSION_TAG}"
echo "  dvc checkout"
echo "  dvc repro"
EOF

chmod +x scripts/version_pipeline.sh

# Create a version
./scripts/version_pipeline.sh v1.0.0
```

### Step 8: Create a Pipeline Monitoring Script

```bash
cat > scripts/monitor_pipeline.sh << 'EOF'
#!/bin/bash
# Monitor pipeline execution and collect metrics

PIPELINE_RUN_ID=$(date +%Y%m%d_%H%M%S)
LOG_DIR="logs/pipelines"
mkdir -p $LOG_DIR

LOG_FILE="${LOG_DIR}/pipeline_${PIPELINE_RUN_ID}.log"

echo "Starting pipeline monitoring at $(date)" | tee $LOG_FILE

# Function to log execution time
log_time() {
    local stage=$1
    local start_time=$2
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo "$stage completed in ${duration}s" | tee -a $LOG_FILE
}

# Run each stage with timing
echo "Starting generate_raw_data_48h..." | tee -a $LOG_FILE
start_time=$(date +%s)
dvc repro generate_raw_data_48h >> $LOG_FILE 2>&1
log_time "generate_raw_data_48h" $start_time

echo "Starting build_features_48h..." | tee -a $LOG_FILE
start_time=$(date +%s)
dvc repro build_features_48h >> $LOG_FILE 2>&1
log_time "build_features_48h" $start_time

echo "Starting train_model_48h..." | tee -a $LOG_FILE
start_time=$(date +%s)
dvc repro train_model_48h >> $LOG_FILE 2>&1
log_time "train_model_48h" $start_time

echo "Starting evaluate_model_48h..." | tee -a $LOG_FILE
start_time=$(date +%s)
dvc repro evaluate_model_48h >> $LOG_FILE 2>&1
log_time "evaluate_model_48h" $start_time

# Extract metrics
echo "Collecting metrics..." | tee -a $LOG_FILE
dvc metrics show --json > "${LOG_DIR}/metrics_${PIPELINE_RUN_ID}.json"

echo "Pipeline monitoring completed!" | tee -a $LOG_FILE
echo "Log saved to: $LOG_FILE"
echo "Metrics saved to: ${LOG_DIR}/metrics_${PIPELINE_RUN_ID}.json"
EOF

chmod +x scripts/monitor_pipeline.sh

# Run the monitor script
./scripts/monitor_pipeline.sh
```

### Step 9: Create a Pipeline Comparison Tool

```bash
cat > scripts/compare_pipelines.py << 'EOF'
#!/usr/bin/env python
"""
Compare pipeline metrics across different runs or versions.
"""

import json
import sys
from pathlib import Path
import pandas as pd
import argparse
import glob


def load_metrics(file_pattern: str) -> pd.DataFrame:
    """Load metrics from multiple JSON files."""
    all_metrics = []
    
    for file_path in glob.glob(file_pattern):
        run_id = Path(file_path).stem.replace('metrics_', '')
        
        with open(file_path, 'r') as f:
            metrics = json.load(f)
        
        # Flatten the nested structure
        flat_metrics = {'run_id': run_id}
        for key, value in metrics.items():
            if isinstance(value, dict):
                for sub_key, sub_value in value.items():
                    flat_metrics[f'{key}_{sub_key}'] = sub_value
            else:
                flat_metrics[key] = value
        
        all_metrics.append(flat_metrics)
    
    return pd.DataFrame(all_metrics)


def compare_metrics(df: pd.DataFrame) -> pd.DataFrame:
    """Compare metrics across runs."""
    # Find the best run for each metric
    comparison = df.describe()
    
    # Add rankings
    for col in df.select_dtypes(include=['float64', 'int64']).columns:
        if 'accuracy' in col or 'f1' in col or 'auc' in col:
            df[f'{col}_rank'] = df[col].rank(method='dense', ascending=False)
        elif 'time' in col or 'samples' in col:
            df[f'{col}_rank'] = df[col].rank(method='dense', ascending=True)
    
    return df


def main():
    parser = argparse.ArgumentParser(description="Compare pipeline metrics")
    parser.add_argument("--pattern", type=str, default="logs/pipelines/metrics_*.json",
                       help="Pattern for metrics files")
    parser.add_argument("--output", type=str, default="pipeline_comparison.csv",
                       help="Output CSV file")
    
    args = parser.parse_args()
    
    # Load all metrics
    df = load_metrics(args.pattern)
    
    if df.empty:
        print(f"No metrics found matching pattern: {args.pattern}")
        sys.exit(1)
    
    # Compare metrics
    df = compare_metrics(df)
    
    # Save results
    df.to_csv(args.output, index=False)
    print(f"Comparison saved to {args.output}")
    print(f"Number of runs compared: {len(df)}")
    print(f"Metrics columns: {list(df.columns)}")
    
    # Display best run
    best_run = df.loc[df['train_model_f1'].idxmax()] if 'train_model_f1' in df.columns else None
    if best_run is not None:
        print(f"\nBest performing run: {best_run['run_id']}")
        print(f"F1 Score: {best_run['train_model_f1']:.4f}")

if __name__ == "__main__":
    main()
EOF

chmod +x scripts/compare_pipelines.py

# Run the comparison
python scripts/compare_pipelines.py
```

### Step 10: Create a Pipeline Reset Script

Sometimes you need to force a complete rebuild:

```bash
cat > scripts/reset_pipeline.sh << 'EOF'
#!/bin/bash
# Reset the pipeline to a clean state

echo "WARNING: This will remove all generated data and models!"
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo "Resetting pipeline..."

# Remove all generated outputs
rm -rf data/raw/*
rm -rf data/processed/*
rm -rf models/registry/*
rm -rf models/evaluation/*

# Remove DVC cache for these files
dvc gc --workspace

# Re-run the complete pipeline
dvc repro

echo "Pipeline reset and re-run completed!"
EOF

chmod +x scripts/reset_pipeline.sh
```

## The Verification: Testing Advanced Pipeline Features

### Verification 1: Test Pipeline Execution

```bash
# Run the pipeline with verbose output
dvc repro -v

# Check the status
dvc status

# View the pipeline structure
dvc dag

# Expected output should show all stages in the correct order
```

### Verification 2: Test Incremental Build

```bash
# Modify a source file
echo "# Test change" >> src/features/build_features.py

# Check what will be rebuilt
dvc status

# This should show that stages depending on build_features.py will be rebuilt

# Run the pipeline
dvc repro

# Only the affected stages should be rebuilt
```

### Verification 3: Test Parameter Changes

```bash
# Modify a parameter
sed -i 's/test_size: 0.2/test_size: 0.3/' params.yaml

# Check what will change
dvc status

# Run the pipeline
dvc repro

# The training stage should be rebuilt with the new parameters
```

### Verification 4: Test Pipeline Metrics

```bash
# Show all metrics
dvc metrics show

# Show specific metrics
dvc metrics show --targets model/registry/model_48h.json

# Show metrics in a table
dvc metrics show --all
```

### Verification 5: Test Pipeline Versioning

```bash
# Create a new pipeline version
./scripts/version_pipeline.sh v1.1.0

# List all versions
git tag -l | grep pipeline

# Checkout a specific version
git checkout pipeline_v1.0.0
dvc checkout
dvc status
```

## Advanced DVC Pipeline Concepts

### Parameterized Pipelines

DVC supports parameterization through params files. Here's how to use it effectively:

```bash
# Access parameters in your code
cat > src/utils/get_params.py << 'EOF'
import yaml

def get_params():
    """Load parameters from params.yaml."""
    with open('params.yaml', 'r') as f:
        params = yaml.safe_load(f)
    return params
EOF
```

### Multi-Environment Pipelines

```bash
# Create environment-specific configurations
cat > params.dev.yaml << 'EOF'
# Development environment parameters
data:
  raw:
    hours: [48]  # Smaller dataset for dev
  processed:
    test_size: 0.3  # Larger test set for faster iteration
EOF

# Use environment-specific params
DVC_PARAMS=params.dev.yaml dvc repro
```

### External Dependencies

```bash
# Track external dependencies
cat >> dvc.yaml << 'EOF'
  download_external_data:
    cmd: python scripts/download_data.py --url ${EXTERNAL_DATA_URL}
    deps:
      - scripts/download_data.py
      - ${EXTERNAL_DATA_URL}  # DVC tracks this as a dependency
    outs:
      - data/external/external_data.csv
    # External dependencies are tracked by hash
EOF
```

## What We've Accomplished

By completing this part, you have:

1. **Extended your DVC pipeline** to include model training and evaluation
2. **Created comprehensive pipeline stages** with proper dependencies
3. **Implemented parameterization** for flexible pipeline execution
4. **Added conditional pipeline logic** for different data versions
5. **Created pipeline versioning** for reproducibility
6. **Built monitoring tools** to track pipeline execution
7. **Developed comparison tools** to evaluate pipeline performance
8. **Implemented reset mechanisms** for clean rebuilds

## Common Pipeline Operations

| Command | Purpose |
|---------|---------|
| `dvc repro` | Run the pipeline (incremental) |
| `dvc repro --force` | Force re-run all stages |
| `dvc status` | Check what changed |
| `dvc dag` | Visualize pipeline |
| `dvc metrics show` | View pipeline metrics |
| `dvc params diff` | Show parameter changes |
| `dvc pull` | Download data from remote |
| `dvc push` | Upload data to remote |

## Troubleshooting

**Issue:** Pipeline stages not re-running when they should
```bash
# Solution: Check dependency hashes
dvc status --checks
# Or force re-run
dvc repro --force
```

**Issue:** Pipeline failing due to missing dependencies
```bash
# Solution: Check all deps are tracked
dvc status --remote
# Download missing data
dvc pull
```

**Issue:** Memory issues during pipeline execution
```bash
# Solution: Run stages individually
dvc repro --single-item stage_name
# Or use smaller datasets for development
```

## Next Steps

You've mastered DVC pipelines! In Phase 2, we'll:
- Set up MLflow for experiment tracking
- Integrate DVC with MLflow
- Implement model registry
- Track experiments with versioned data

---

*End of Part 4: Managing Data Pipelines with DVC*
