# Appendix A: Complete Code Index

## Project Structure Reference

```
ml-pipeline-project/
├── 📁 configs/
│   ├── base.yaml                          # Base configuration template
│   └── training_config.json               # Training configuration for capstone
│
├── 📁 data/
│   ├── 📁 raw/                            # Raw data storage
│   ├── 📁 processed/                      # Processed data storage
│   └── 📁 external/                       # External reference data
│
├── 📁 src/
│   ├── 📁 data/
│   │   ├── __init__.py
│   │   ├── ingestion.py                   # Data loading (Part 1)
│   │   ├── validation.py                  # Data validation (Part 1-2)
│   │   ├── quality.py                     # Data quality checks (Part 2)
│   │   └── schemas.py                     # Schema definitions (Part 2)
│   │
│   ├── 📁 features/
│   │   ├── __init__.py
│   │   ├── encoders.py                    # Categorical encoders (Part 5)
│   │   ├── encoding.py                    # Unified encoding (Part 5)
│   │   ├── creation.py                    # Feature creation (Part 6)
│   │   ├── selection.py                   # Feature selection (Part 6)
│   │   ├── dimensionality.py              # Dimensionality reduction (Part 7)
│   │   ├── imbalance.py                   # Imbalance handling (Part 7)
│   │   └── visualization.py               # Feature visualization
│   │
│   ├── 📁 preprocessing/
│   │   ├── __init__.py
│   │   ├── imputation.py                  # Missing value handling (Part 4)
│   │   ├── scaling.py                     # Feature scaling (Part 4)
│   │   └── pipeline.py                    # Preprocessing pipeline (Part 4)
│   │
│   ├── 📁 models/
│   │   ├── __init__.py
│   │   ├── tree_based.py                  # Tree-based models (Part 8)
│   │   ├── params.py                      # Model parameters (Part 8)
│   │   ├── comparator.py                  # Model comparison (Part 8)
│   │   ├── clustering.py                  # Clustering algorithms (Part 9)
│   │   ├── hierarchical.py                # Hierarchical clustering (Part 9)
│   │   ├── nn_architectures.py            # Neural network architectures (Part 10)
│   │   ├── trainer.py                     # Training engine (Part 10)
│   │   └── deep_utils.py                  # Deep learning utilities (Part 10)
│   │
│   ├── 📁 validation/
│   │   ├── __init__.py
│   │   ├── cross_validation.py            # CV strategies (Part 11)
│   │   ├── metrics.py                     # Evaluation metrics (Part 11)
│   │   ├── tuning.py                      # Grid/Random search (Part 12)
│   │   └── optuna_tuner.py                # Bayesian optimization (Part 12)
│   │
│   ├── 📁 pipeline/
│   │   ├── __init__.py
│   │   ├── builder.py                     # Pipeline construction (Part 13)
│   │   ├── trainer.py                     # Training script (Part 13)
│   │   └── predictor.py                   # Prediction script (Part 13)
│   │
│   ├── 📁 analysis/
│   │   ├── __init__.py
│   │   ├── eda.py                         # Exploratory analysis (Part 3)
│   │   ├── visualizations.py              # Visualization (Part 3)
│   │   └── reports.py                     # Report generation (Part 3)
│   │
│   └── 📁 api/
│       ├── app.py                         # FastAPI application (Part 15)
│       └── monitoring.py                  # Monitoring system (Part 15)
│
├── 📁 capstone/
│   ├── prepare_data.py                    # Data prep (Part 14)
│   ├── train_churn_model.py               # Training (Part 14)
│   └── evaluate_churn_model.py            # Evaluation (Part 14)
│
├── 📁 scripts/
│   ├── deploy.sh                          # Deployment script (Part 15)
│   └── test_api.py                        # API test client (Part 15)
│
├── 📁 tests/
│   ├── test_ingestion.py                  # Data ingestion tests
│   └── test_quality.py                    # Quality checks tests
│
├── 📁 notebooks/                          # Jupyter notebooks
├── 📁 models/                             # Saved models
├── 📁 logs/                               # Application logs
├── 📁 reports/                            # Reports and figures
│
├── 📄 requirements.txt                    # Python dependencies
├── 📄 Dockerfile                          # Containerization
├── 📄 docker-compose.yml                  # Container orchestration
├── 📄 Makefile                            # Automation
├── 📄 pyproject.toml                      # Project metadata
├── 📄 .env.example                        # Environment template
└── 📄 README.md                           # Project documentation
```

---

## Key Code Reference Table

### Data Layer (src/data/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **ingestion.py** | `DataIngestor` | Load data from CSV, JSON, Parquet, SQL | 1 |
| | `.load_csv()` | Load CSV with error handling | 1 |
| | `.load_json()` | Load JSON/NDJSON files | 1 |
| | `.load_parquet()` | Load Parquet files | 1 |
| | `.load_sql()` | Load from SQL database | 1 |
| | `.save_data()` | Save data in various formats | 1 |
| | `.get_dataset_info()` | Get dataset statistics | 1 |
| | `.preview_data()` | Generate data preview | 1 |
| **validation.py** | `DataValidator` | Validate data quality and schema | 1-2 |
| | `.validate_schema()` | Check column types, constraints | 2 |
| | `.detect_missing_values()` | Analyze missing data patterns | 2 |
| | `.detect_duplicates()` | Find duplicate rows | 2 |
| | `.detect_outliers()` | Identify outliers (IQR, Z-score) | 2 |
| | `.generate_report()` | Create comprehensive validation report | 2 |
| | `.save_report()` | Save report as JSON | 2 |
| **quality.py** | `DataQualityChecker` | Advanced quality assessment | 2 |
| | `.assess()` | Complete quality assessment | 2 |
| | `.generate_visual_report()` | Create HTML report with plots | 2 |
| | `_analyze_missing()` | Deep missing value analysis | 2 |
| | `_analyze_outliers()` | Multi-method outlier detection | 2 |
| | `_calculate_quality_scores()` | Score quality dimensions | 2 |
| **schemas.py** | `DataSchema` | Schema definition with Pydantic | 2 |
| | `ColumnSchema` | Column-level schema | 2 |
| | `ColumnConstraint` | Value constraints | 2 |
| | `IrisSchema` | Pre-defined Iris schema | 2 |
| | `TitanicSchema` | Pre-defined Titanic schema | 2 |

### Preprocessing Layer (src/preprocessing/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **imputation.py** | `MissingValueImputer` | Handle missing values | 4 |
| | `.impute()` | Main imputation interface | 4 |
| | `_impute_numeric()` | Numeric imputation strategies | 4 |
| | `_impute_categorical()` | Categorical imputation | 4 |
| | `.impute_with_model()` | Model-based imputation | 4 |
| | `.get_imputation_summary()` | Summary of imputation | 4 |
| **scaling.py** | `FeatureScaler` | Unified scaling interface | 4 |
| | `.fit_transform()` | Scale data | 4 |
| | `.inverse_transform()` | Reverse scaling | 4 |
| | `SmartScaler` | Auto-select scaling strategy | 4 |
| **pipeline.py** | `DataPreprocessor` | Combined preprocessing | 4 |
| | `.fit_transform()` | Apply imputation + scaling | 4 |
| | `.get_preprocessing_summary()` | Get pipeline summary | 4 |

### Feature Layer (src/features/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **encoders.py** | `OneHotEncoderCustom` | One-hot with rare category handling | 5 |
| | `TargetEncoder` | Target encoding with smoothing | 5 |
| | `FrequencyEncoder` | Frequency-based encoding | 5 |
| | `HashingEncoder` | Feature hashing for high cardinality | 5 |
| | `OrdinalEncoderCustom` | Ordinal encoding | 5 |
| **encoding.py** | `CategoricalEncoder` | Unified encoding interface | 5 |
| | `.fit_transform()` | Auto-select and apply encoding | 5 |
| | `_select_strategy()` | Auto strategy selection | 5 |
| | `MultiStrategyEncoder` | Per-column strategies | 5 |
| **creation.py** | `FeatureCreator` | Create new features | 6 |
| | `.fit_transform()` | Generate polynomial, ratio, aggregation | 6 |
| | `_create_ratio_features()` | Ratio and difference features | 6 |
| | `_create_aggregation_features()` | Group-based aggregations | 6 |
| | `.get_feature_importance()` | Feature importance for new features | 6 |
| **selection.py** | `FeatureSelector` | Feature selection | 6 |
| | `.fit_transform()` | Apply selection method | 6 |
| | `.get_selected_features()` | Get selected feature names | 6 |
| | `.get_selection_summary()` | Selection summary | 6 |
| | `AutoFeatureSelector` | Automatic method selection | 6 |
| **dimensionality.py** | `DimensionalityReducer` | Dimension reduction | 7 |
| | `.fit_transform()` | Apply PCA, LDA, t-SNE, UMAP | 7 |
| | `.get_explained_variance()` | Get variance explained | 7 |
| | `AutoDimensionSelector` | Auto-select dimensions | 7 |
| **imbalance.py** | `ImbalanceHandler` | Handle imbalanced data | 7 |
| | `.fit_resample()` | Apply SMOTE, ADASYN, etc. | 7 |
| | `CostSensitiveHandler` | Class weights for models | 7 |
| | `BalancedEnsemble` | Balanced ensemble methods | 7 |

### Model Layer (src/models/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **tree_based.py** | `TreeModel` | Unified tree model interface | 8 |
| | `.fit()` | Train the model | 8 |
| | `.predict()` | Make predictions | 8 |
| | `.predict_proba()` | Get probabilities | 8 |
| | `.get_feature_importance()` | Extract importance | 8 |
| | `.cross_validate()` | Perform CV | 8 |
| | `.plot_importance()` | Visualize importance | 8 |
| **params.py** | `get_model_params()` | Get parameter templates | 8 |
| | `XGBOOST_PARAMS` | XGBoost parameter presets | 8 |
| | `LIGHTGBM_PARAMS` | LightGBM parameter presets | 8 |
| | `CATBOOST_PARAMS` | CatBoost parameter presets | 8 |
| | `RANDOM_FOREST_PARAMS` | Random Forest presets | 8 |
| **comparator.py** | `ModelComparator` | Compare multiple models | 8 |
| | `.compare()` | Run comparison | 8 |
| | `.get_best_model()` | Get best model | 8 |
| | `.plot_comparison()` | Visualize comparison | 8 |
| **clustering.py** | `ClusteringModel` | Unified clustering interface | 9 |
| | `.fit_predict()` | Cluster data | 9 |
| | `.evaluate()` | Validate clusters | 9 |
| | `.get_cluster_profiles()` | Profile clusters | 9 |
| | `.plot_clusters()` | Visualize clusters | 9 |
| | `OptimalKSelector` | Auto-select K | 9 |
| **hierarchical.py** | `HierarchicalClustering` | Hierarchical clustering | 9 |
| | `.fit_predict()` | Cluster with hierarchy | 9 |
| | `.plot_dendrogram()` | Plot dendrogram | 9 |
| | `.get_cluster_hierarchy()` | Get hierarchy as DataFrame | 9 |
| **nn_architectures.py** | `MLP` | Multi-layer perceptron | 10 |
| | `ResNet` | Residual network | 10 |
| | `Autoencoder` | Autoencoder for dimensionality | 10 |
| | `ResidualBlock` | Skip connection block | 10 |
| **trainer.py** | `DeepTrainer` | PyTorch training engine | 10 |
| | `.train()` | Train loop with validation | 10 |
| | `.predict()` | Make predictions | 10 |
| | `.save_checkpoint()` | Save model state | 10 |
| | `.load_checkpoint()` | Load model state | 10 |
| **deep_utils.py** | `setup_device()` | Configure GPU/CPU | 10 |
| | `set_seed()` | Set random seeds | 10 |
| | `create_dataloaders()` | Create PyTorch DataLoaders | 10 |
| | `EarlyStopping` | Early stopping callback | 10 |

### Validation Layer (src/validation/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **cross_validation.py** | `CrossValidator` | CV strategies | 11 |
| | `.get_splits()` | Get train/test indices | 11 |
| | `.validate()` | Perform CV on model | 11 |
| | `_select_method()` | Auto-select CV method | 11 |
| | `.plot_cv()` | Visualize CV splits | 11 |
| **metrics.py** | `MetricsCalculator` | Compute evaluation metrics | 11 |
| | `.compute_metrics()` | Calculate all metrics | 11 |
| | `.confusion_matrix_summary()` | Detailed confusion matrix | 11 |
| | `.print_report()` | Print formatted report | 11 |
| | `.plot_confusion_matrix()` | Visualize confusion matrix | 11 |
| **tuning.py** | `GridSearchOptimizer` | Grid search optimization | 12 |
| | `.optimize()` | Run grid search | 12 |
| | `.get_results_dataframe()` | Results as DataFrame | 12 |
| | `.plot_results()` | Visualize grid results | 12 |
| | `RandomSearchOptimizer` | Random search | 12 |
| **optuna_tuner.py** | `OptunaTuner` | Bayesian optimization | 12 |
| | `.optimize()` | Run Optuna study | 12 |
| | `.get_trials_dataframe()` | Get trial results | 12 |
| | `.plot_optimization_history()` | Plot convergence | 12 |
| | `.plot_param_importances()` | Show parameter importance | 12 |
| | `.save_study()` | Save study to disk | 12 |
| | `AutomatedTuner` | Auto-select tuning method | 12 |

### Pipeline Layer (src/pipeline/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **builder.py** | `MLPipeline` | Complete end-to-end pipeline | 13 |
| | `.train()` | Train the full pipeline | 13 |
| | `.predict()` | Make predictions | 13 |
| | `_tune_hyperparameters()` | Run hyperparameter tuning | 13 |
| | `_evaluate_model()` | Evaluate performance | 13 |
| | `.save()` | Save pipeline to disk | 13 |
| | `.load()` | Load saved pipeline | 13 |
| | `.get_summary()` | Get pipeline summary | 13 |
| **trainer.py** | `main()` | Training script entry point | 13 |
| **predictor.py** | `main()` | Prediction script entry point | 13 |

### Analysis Layer (src/analysis/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **eda.py** | `ExploratoryDataAnalyzer` | Comprehensive EDA | 3 |
| | `.analyze()` | Perform full analysis | 3 |
| | `_analyze_univariate()` | Individual feature analysis | 3 |
| | `_analyze_correlations()` | Feature correlations | 3 |
| | `_analyze_target()` | Target variable analysis | 3 |
| | `_generate_insights()` | Extract key insights | 3 |
| | `.generate_summary()` | Human-readable summary | 3 |
| | `.save_report()` | Save analysis to files | 3 |
| **visualizations.py** | `DataVisualizer` | Visualization generation | 3 |
| | `.create_report()` | Create full visualization report | 3 |
| | `_create_distribution_plots()` | Distribution plots | 3 |
| | `_create_correlation_plots()` | Correlation heatmap | 3 |
| | `_create_target_plots()` | Target analysis plots | 3 |
| **reports.py** | `EDAReportGenerator` | HTML report generation | 3 |
| | `.generate()` | Generate HTML report | 3 |

### API Layer (src/api/)

| File | Key Classes/Functions | Description | Part |
|------|----------------------|-------------|------|
| **app.py** | FastAPI app | Web application | 15 |
| | `/api/health` | Health check endpoint | 15 |
| | `/api/predict` | Single prediction endpoint | 15 |
| | `/api/predict/batch` | Batch prediction endpoint | 15 |
| | `/api/model/info` | Model information endpoint | 15 |
| **monitoring.py** | `ModelMonitor` | Monitor model performance | 15 |
| | `.log_prediction()` | Log prediction request | 15 |
| | `.detect_drift()` | Detect data drift | 15 |
| | `.get_performance_summary()` | Performance summary | 15 |
| | `.generate_report()` | Monitoring report | 15 |

### Capstone Layer (capstone/)

| File | Key Functions | Description | Part |
|------|---------------|-------------|------|
| **prepare_data.py** | `load_and_explore_data()` | Load and explore churn data | 14 |
| | `clean_and_prepare_data()` | Clean and prepare data | 14 |
| | `create_features()` | Engineer new features | 14 |
| | `plot_exploratory_analysis()` | Create EDA plots | 14 |
| **train_churn_model.py** | `main()` | Train churn prediction model | 14 |
| **evaluate_churn_model.py** | `main()` | Evaluate churn model | 14 |
| | `evaluate_predictions()` | Compute metrics | 14 |
| | `analyze_business_impact()` | Business impact analysis | 14 |
| | `generate_report()` | Generate evaluation report | 14 |

### Scripts

| File | Purpose | Part |
|------|---------|------|
| **deploy.sh** | Deploy API with Docker | 15 |
| **test_api.py** | Test API endpoints | 15 |
| **Makefile** | Automation commands | 1 |

### Tests

| File | Purpose | Part |
|------|---------|------|
| **test_ingestion.py** | Test DataIngestor | 1 |
| **test_quality.py** | Test DataQualityChecker | 2 |

---

## Configuration Files

| File | Purpose | Part |
|------|---------|------|
| **base.yaml** | Base configuration template | 1 |
| **training_config.json** | Training configuration | 13-14 |
| **requirements.txt** | Python dependencies | 1 |
| **pyproject.toml** | Project metadata | 1 |
| **.env.example** | Environment variables template | 1 |
| **Dockerfile** | Container definition | 15 |
| **docker-compose.yml** | Container orchestration | 15 |
| **Makefile** | Automation targets | 1 |

---

## Quick Command Reference

### Setup Commands

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt

# Install in development mode
pip install -e .

# Setup project
make setup
```

### Testing Commands

```bash
# Run all tests
make test

# Run with coverage
make coverage

# Run specific test file
pytest tests/test_ingestion.py -v

# Run specific test function
pytest tests/test_ingestion.py::TestDataIngestor::test_load_csv -v
```

### Training Commands

```bash
# Train pipeline with config
python -m src.pipeline.trainer --config configs/training_config.json --data data/raw/data.csv --target target --output models/pipeline.joblib

# Train with hyperparameter tuning
python -m src.pipeline.trainer --config configs/training_config.json --data data/raw/data.csv --target target --output models/pipeline.joblib

# Train without tuning
python -m src.pipeline.trainer --config configs/training_config.json --data data/raw/data.csv --target target --output models/pipeline.joblib --no-tune
```

### Prediction Commands

```bash
# Make predictions
python -m src.pipeline.predictor --pipeline models/pipeline.joblib --data data/raw/new_data.csv --output predictions.csv

# Get probabilities
python -m src.pipeline.predictor --pipeline models/pipeline.joblib --data data/raw/new_data.csv --output predictions.csv --proba
```

### API Commands

```bash
# Run API locally
python -m src.api.app

# Run with uvicorn
uvicorn src.api.app:app --host 0.0.0.0 --port 8000 --reload

# Test API
python scripts/test_api.py

# Deploy with Docker
./scripts/deploy.sh

# Using docker-compose
docker-compose up -d
docker-compose down
```

### Capstone Commands

```bash
# Prepare data
python capstone/prepare_data.py

# Train model
python capstone/train_churn_model.py

# Evaluate model
python capstone/evaluate_churn_model.py
```

---

## Import Paths Reference

```python
# Data layer
from src.data.ingestion import DataIngestor
from src.data.validation import DataValidator
from src.data.quality import DataQualityChecker
from src.data.schemas import DataSchema, ColumnSchema

# Preprocessing
from src.preprocessing.imputation import MissingValueImputer
from src.preprocessing.scaling import FeatureScaler, SmartScaler
from src.preprocessing.pipeline import DataPreprocessor

# Features
from src.features.encoders import OneHotEncoderCustom, TargetEncoder, FrequencyEncoder
from src.features.encoding import CategoricalEncoder, MultiStrategyEncoder
from src.features.creation import FeatureCreator
from src.features.selection import FeatureSelector, AutoFeatureSelector
from src.features.dimensionality import DimensionalityReducer, AutoDimensionSelector
from src.features.imbalance import ImbalanceHandler, CostSensitiveHandler

# Models
from src.models.tree_based import TreeModel
from src.models.params import get_model_params
from src.models.comparator import ModelComparator
from src.models.clustering import ClusteringModel, OptimalKSelector
from src.models.hierarchical import HierarchicalClustering
from src.models.nn_architectures import MLP, ResNet, Autoencoder
from src.models.trainer import DeepTrainer
from src.models.deep_utils import setup_device, EarlyStopping

# Validation
from src.validation.cross_validation import CrossValidator
from src.validation.metrics import MetricsCalculator
from src.validation.tuning import GridSearchOptimizer, RandomSearchOptimizer
from src.validation.optuna_tuner import OptunaTuner, AutomatedTuner

# Pipeline
from src.pipeline.builder import MLPipeline

# Analysis
from src.analysis.eda import ExploratoryDataAnalyzer
from src.analysis.visualizations import DataVisualizer
from src.analysis.reports import EDAReportGenerator

# API
from src.api.app import app
from src.api.monitoring import ModelMonitor
```

---

This appendix serves as your quick reference guide for navigating the codebase and finding the specific components you need. Each file, class, and function is documented with its purpose and the part where it was introduced.
