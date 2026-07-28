I cannot generate a full 300+ slide PowerPoint presentation directly as a `.pptx` file in this chat interface. However, I can provide you with:

1. **A complete slide deck outline** with all 300+ slides in text format
2. **Instructions** on how to quickly convert this into a professional PowerPoint presentation
3. **A Python script** using `python-pptx` to generate the `.pptx` file automatically

---

## Option 1: Complete Slide Deck Text Outline

Here is the complete 300+ slide outline for teaching the entire series. You can copy this and paste into PowerPoint or use the Python script below.

---

# MASTERING MACHINE LEARNING & PREDICTIVE MODELING
## Complete Slide Deck (300+ Slides)

---

### PART 0: INTRODUCTION (Slides 1-20)

---

**Slide 1**
MASTERING MACHINE LEARNING & PREDICTIVE MODELING
An End-to-End Pipeline Series

---

**Slide 2**
AGENDA
• Part 0: Introduction
• Part 1: Project Setup
• Part 2: Data Validation
• Part 3: Exploratory Data Analysis
• Part 4: Imputation & Scaling
• Part 5: Categorical Encoding
• Part 6: Feature Creation & Selection
• Part 7: Dimensionality Reduction & Imbalance
• Part 8: Tree-Based & Ensemble Models
• Part 9: Unsupervised Learning
• Part 10: Deep Learning Fundamentals
• Part 11: Cross-Validation & Evaluation
• Part 12: Hyperparameter Optimization
• Part 13: Pipeline Construction
• Part 14: Capstone Project
• Part 15: Deployment & Monitoring

---

**Slide 3**
WHAT MAKES THIS SERIES DIFFERENT
• Production-Grade Code, Not Notebook Experiments
• Obsessed with Data Leakage Prevention
• Complete Ecosystem: Ingestion → Deployment

---

**Slide 4**
TARGET AUDIENCE
• Know some Python
• Have trained a model before
• Curious about the "why"
• Want to build real systems
• Have patience for thoroughness

---

**Slide 5**
PREREQUISITES
• Python: Write functions, use lists/dicts
• Basic ML: Know train/test split
• Scikit-learn: Used .fit() and .predict()
• NumPy/Pandas: Basic DataFrame operations
• Command Line: Navigate directories

---

**Slide 6**
MODULE 4.1: FEATURE PREP & ENGINEERING
• Data Integrity & Preprocessing
• Categorical Encodings
• Dimensionality Reduction
• Imbalanced Learning

---

**Slide 7**
MODULE 4.2: SUPERVISED & UNSUPERVISED LEARNING
• Classification & Regression Ensembles
• Unsupervised Discovery
• Deep Learning Baseline

---

**Slide 8**
MODULE 4.3: MODEL VALIDATION & TUNING
• Cross-Validation Schemes
• Comprehensive Evaluation Metrics
• Hyperparameter Optimization

---

**Slide 9**
PHASE 4 CAPSTONE
• End-to-End Predictive Pipeline
• Leak-Free Workflow
• Bayesian Hyperparameter Tuning
• Production-Grade Evaluation

---

**Slide 10**
TOOLS & TECHNOLOGIES
• Python 3.9+
• NumPy, Pandas
• Scikit-learn
• XGBoost, LightGBM, CatBoost
• PyTorch
• Optuna
• FastAPI
• Docker
• Pytest
• Loguru
• Pydantic

---

**Slide 11**
WHAT YOU'LL BUILD
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── src/
│   ├── data/
│   ├── features/
│   ├── models/
│   ├── validation/
│   └── pipeline/
├── tests/
├── notebooks/
├── configs/
├── models/
├── logs/
├── reports/
├── requirements.txt
├── Dockerfile
├── Makefile
└── README.md

---

**Slide 12**
THE DATA FLOW
Data Ingestion → Data Validation → Feature Engineering → Leak-Free Pipeline → Model Training → Hyperparameter Tuning → Model Evaluation → Model Persistence → Prediction Interface

---

**Slide 13**
DATA LAYER
• DataIngestor: Load CSV, JSON, Parquet, SQL
• DataValidator: Schema validation, quality checks
• DataQualityChecker: Comprehensive assessment

---

**Slide 14**
FEATURE LAYER
• Imputation: Mean, Median, Mode, KNN, MICE
• Scaling: Standard, Robust, MinMax, Power
• Encoding: One-Hot, Target, Frequency, Hashing
• Creation: Polynomial, Ratio, Aggregation
• Selection: Filter, Wrapper, Embedded
• Reduction: PCA, LDA, t-SNE, UMAP

---

**Slide 15**
MODEL LAYER
• Tree-Based: Decision Trees, Random Forest
• Gradient Boosting: XGBoost, LightGBM, CatBoost
• Unsupervised: K-Means, DBSCAN, Hierarchical
• Deep Learning: MLP, ResNet, Autoencoder

---

**Slide 16**
VALIDATION LAYER
• Cross-Validation: K-Fold, Stratified, Group, TimeSeries
• Metrics: Accuracy, Precision, Recall, F1, ROC-AUC, PR-AUC, MAE, RMSE, MAPE, R²
• Tuning: Grid Search, Random Search, Bayesian (Optuna)

---

**Slide 17**
DEPLOYMENT LAYER
• Model Persistence: Joblib, Pickle
• API: FastAPI
• Containerization: Docker
• Monitoring: Performance, Drift, Alerts
• Versioning: Model Registry

---

**Slide 18**
LEARNING PATH
Module 4.1 (Parts 1-7): Feature Prep & Engineering
Module 4.2 (Parts 8-10): Supervised & Unsupervised
Module 4.3 (Parts 11-12): Validation & Tuning
Phase 4 Capstone (Parts 13-15): Complete System

---

**Slide 19**
HOW TO GET THE MOST OUT OF THIS SERIES
• Code Along, Don't Just Read
• Experiment at Each Verification Step
• Break Things Intentionally
• Complete the Capstone
• Keep Your Own Notes

---

**Slide 20**
LET'S BEGIN
The journey starts now. Phase 1 begins with project setup.

---

### PART 1: PROJECT SETUP (Slides 21-50)

---

**Slide 21**
PART 1: PROJECT SETUP AND CONFIGURATION
Building the Foundation

---

**Slide 22**
TARGET
• Professional Python project structure
• Dependency management with pinned versions
• Environment variables management
• Logging configured and working
• Data ingestion module

---

**Slide 23**
WHY PROJECT STRUCTURE MATTERS
Without Structure:
• Unreproducible
• Unmaintainable
• Unshareable
• Fragile

With Structure:
• Reproducible
• Maintainable
• Shareable
• Robust

---

**Slide 24**
PROJECT DIRECTORY STRUCTURE
ml-pipeline-project/
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── src/
│   ├── data/
│   ├── features/
│   ├── models/
│   ├── validation/
│   └── pipeline/
├── tests/
├── notebooks/
├── configs/
├── models/
├── logs/
├── reports/
├── .github/
├── .vscode/
├── requirements.txt
├── Dockerfile
├── Makefile
├── pyproject.toml
├── .env.example
└── README.md

---

**Slide 25**
pyproject.toml
Modern standard for Python project configuration.
Defines:
• Project name and version
• Description and authors
• License
• Python version requirement
• Dependencies
• Optional dependencies
• Project URLs

---

**Slide 26**
requirements.txt
Pins exact versions for reproducibility.
• Core: numpy, pandas, scipy
• ML: scikit-learn, xgboost, lightgbm, catboost
• Deep Learning: torch, torchvision
• Optimization: optuna
• API: fastapi, uvicorn
• Utils: loguru, python-dotenv, joblib

---

**Slide 27**
README.md
• Overview
• Project Structure
• Quick Start
• Installation
• Configuration
• Running the Pipeline
• Testing
• License

---

**Slide 28**
.env.example
Environment variables template.
Never commit actual .env to version control!

ENVIRONMENT=development
DATA_RAW_PATH=./data/raw
LOG_LEVEL=INFO
MODEL_PATH=./models
API_HOST=0.0.0.0
API_PORT=8000

---

**Slide 29**
MAKEFILE
Automation commands:
• make install: Install dependencies
• make test: Run tests
• make lint: Lint code
• make format: Format code
• make clean: Clean up
• make train: Train model
• make predict: Run predictions
• make serve: Start API
• make docker-build: Build container
• make setup: Complete setup

---

**Slide 30**
src/data/ingestion.py
DataIngestor class:
• load_csv(): Load CSV with error handling
• load_json(): Load JSON files
• load_parquet(): Load Parquet files
• load_sql(): Load from SQL database
• save_data(): Save in various formats
• get_dataset_info(): Get statistics
• preview_data(): Generate preview

---

**Slide 31**
DataIngestor: INITIALIZATION
def __init__(self, raw_data_path=None, processed_data_path=None):
    self.raw_data_path = Path(raw_data_path or os.getenv("DATA_RAW_PATH", "./data/raw"))
    self.processed_data_path = Path(processed_data_path or os.getenv("DATA_PROCESSED_PATH", "./data/processed"))
    self.raw_data_path.mkdir(parents=True, exist_ok=True)
    self.processed_data_path.mkdir(parents=True, exist_ok=True)

---

**Slide 32**
DataIngestor: LOAD_CSV
def load_csv(self, file_path, **read_csv_kwargs):
    file_path = Path(file_path)
    if not file_path.is_absolute() and not file_path.exists():
        possible_path = self.raw_data_path / file_path
        if possible_path.exists():
            file_path = possible_path
    try:
        df = pd.read_csv(file_path, **read_csv_kwargs)
        logger.success(f"Successfully loaded CSV: {file_path}\n  Shape: {df.shape}")
        return df
    except FileNotFoundError:
        logger.error(f"CSV file not found: {file_path}")
        raise

---

**Slide 33**
DataIngestor: SAVE_DATA
def save_data(self, df, file_path, format="csv", **save_kwargs):
    file_path = Path(file_path)
    if not file_path.is_absolute():
        file_path = self.processed_data_path / file_path
    file_path.parent.mkdir(parents=True, exist_ok=True)
    if format.lower() == "csv":
        df.to_csv(file_path, **save_kwargs)
    elif format.lower() == "parquet":
        df.to_parquet(file_path, **save_kwargs)
    # ...

---

**Slide 34**
DataIngestor: GET_DATASET_INFO
def get_dataset_info(self, df):
    return {
        "shape": df.shape,
        "columns": list(df.columns),
        "dtypes": df.dtypes.to_dict(),
        "missing_count": df.isnull().sum().to_dict(),
        "missing_percentage": (df.isnull().sum() / len(df) * 100).to_dict(),
        "memory_usage": df.memory_usage(deep=True).sum() / 1024**2,
        "numeric_columns": list(df.select_dtypes(include=[np.number]).columns),
        "categorical_columns": list(df.select_dtypes(include=["object", "category"]).columns)
    }

---

**Slide 35**
src/data/validation.py
DataValidator class:
• validate_schema(): Check columns, types, constraints
• detect_missing_values(): Analyze missing data
• detect_duplicates(): Find duplicate rows
• detect_outliers(): Identify outliers (IQR, Z-score)
• generate_report(): Complete validation report

---

**Slide 36**
DataSchema (Pydantic Model)
class DataSchema(BaseModel):
    columns: Dict[str, str]
    required_columns: List[str]
    nullable_columns: List[str] = []
    numerical_columns: List[str] = []
    categorical_columns: List[str] = []
    min_values: Dict[str, float] = {}
    max_values: Dict[str, float] = {}
    allowed_values: Dict[str, List[Any]] = {}

---

**Slide 37**
VALIDATE_SCHEMA
def validate_schema(self, df, schema):
    # Check required columns exist
    missing_columns = set(schema.required_columns) - set(df.columns)
    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")
    # Check column types match
    for col, expected_type in schema.columns.items():
        actual_type = str(df[col].dtype)
        # Map pandas dtypes to our type names
        # ...
    # Check constraints

---

**Slide 38**
DETECT_MISSING_VALUES
def detect_missing_values(self, df, threshold=0.5):
    missing_counts = df.isnull().sum()
    missing_percentages = (missing_counts / len(df)) * 100
    drop_columns = missing_percentages[missing_percentages > threshold * 100].index.tolist()
    return {
        "total_missing": df.isnull().sum().sum(),
        "missing_by_column": missing_counts.to_dict(),
        "missing_percentage_by_column": missing_percentages.to_dict(),
        "columns_above_threshold": drop_columns
    }

---

**Slide 39**
DETECT_OUTLIERS
def detect_outliers(self, df, method="iqr", columns=None):
    for col in columns:
        if method == "iqr":
            Q1 = data.quantile(0.25)
            Q3 = data.quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - 1.5 * IQR
            upper_bound = Q3 + 1.5 * IQR
            outlier_mask = (data < lower_bound) | (data > upper_bound)
        elif method == "zscore":
            z_scores = np.abs((data - data.mean()) / data.std())
            outlier_mask = z_scores > 3

---

**Slide 40**
TESTING THE SETUP
• Verify directory structure
• Create virtual environment
• Install dependencies
• Run tests
• Test data ingestion manually
• Verify Makefile commands

---

**Slide 41**
VIRTUAL ENVIRONMENT
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

pip install -r requirements.txt
pip install -e .

---

**Slide 42**
RUNNING TESTS
pytest tests/test_ingestion.py -v

Expected output:
collected 7 items
test_ingestion.py::TestDataIngestor::test_load_csv PASSED
test_ingestion.py::TestDataIngestor::test_load_csv_with_absolute_path PASSED
test_ingestion.py::TestDataIngestor::test_load_csv_nonexistent_file PASSED
test_ingestion.py::TestDataIngestor::test_save_data_csv PASSED
test_ingestion.py::TestDataIngestor::test_save_data_parquet PASSED
test_ingestion.py::TestDataIngestor::test_get_dataset_info PASSED
test_ingestion.py::TestDataIngestor::test_preview_data PASSED
7 passed in 0.25s

---

**Slide 43**
TEST DATA INGESTION MANUALLY
from src.data.ingestion import DataIngestor
import pandas as pd

ingestor = DataIngestor()
df = ingestor.load_csv("data/raw/sample.csv")
print(df.head())
info = ingestor.get_dataset_info(df)
print(info)

---

**Slide 44**
MAKEFILE COMMANDS
make help
Available commands:
  help            Show this help message
  install         Install dependencies
  test            Run tests
  lint            Lint code
  format          Format code
  clean           Clean up
  train           Train the model
  predict         Run predictions
  serve           Start the API server
  docker-build    Build Docker image
  docker-run      Run Docker container
  setup           Complete setup

---

**Slide 45**
WHAT WE'VE ACCOMPLISHED
• Professional Python project structure
• Dependency management
• Environment variables
• Production-grade DataIngestor
• DataValidator with quality checks
• Test suite
• Automation with Make
• Comprehensive logging

---

**Slide 46**
NEXT: PART 2
Data Validation and Quality
• Advanced schema validation
• Missing value handling strategies
• Outlier detection pipelines
• Data quality reports
• Quality monitoring

---

**Slide 47**
DATA QUALITY DIMENSIONS
• Completeness: Missing values
• Accuracy: Correct values
• Consistency: Same format
• Timeliness: Up-to-date
• Validity: Within range
• Uniqueness: No duplicates

---

**Slide 48**
MISSING DATA MECHANISMS
• MCAR: Missing Completely At Random
  - Probability of missing is the same for all
  - Least problematic
• MAR: Missing At Random
  - Depends on observed variables
  - Can introduce bias
• MNAR: Missing Not At Random
  - Depends on missing value itself
  - Most problematic

---

**Slide 49**
OUTLIER DETECTION METHODS
• IQR: Interquartile Range
  - Uses quartiles, robust to extreme values
• Z-Score: Standard deviations from mean
  - Assumes normal distribution
• Modified Z-Score (MAD-based)
  - Uses median and MAD
  - Robust to extreme values

---

**Slide 50**
KEY TAKEAWAYS
• Project structure is foundational
• Data ingestion is the first step
• Validation catches problems early
• Testing ensures reliability
• Automation saves time

---

### PART 2: DATA VALIDATION (Slides 51-70)

---

**Slide 51**
PART 2: DATA VALIDATION AND QUALITY
Ensuring Data Integrity

---

**Slide 52**
TARGET
• Advanced schema validation with Pydantic
• Strategic missing value handling
• Outlier detection with multiple methods
• Data quality reporting with visualizations
• Automated quality checks

---

**Slide 53**
WHY DATA QUALITY > MODEL QUALITY
• Great data + average model > average data + great model
• Garbage data with best algorithm still produces garbage
• High-quality data with simple model often outperforms complex models on bad data

---

**Slide 54**
COLUMN TYPES
class ColumnType(str, Enum):
    INTEGER = "int"
    FLOAT = "float"
    STRING = "object"
    CATEGORICAL = "category"
    DATETIME = "datetime"
    BOOLEAN = "bool"
    TEXT = "text"
    JSON = "json"

---

**Slide 55**
COLUMN CONSTRAINT
class ColumnConstraint(BaseModel):
    min_value: Optional[float] = None
    max_value: Optional[float] = None
    allowed_values: Optional[List[Any]] = None
    regex_pattern: Optional[str] = None
    min_length: Optional[int] = None
    max_length: Optional[int] = None
    unique: bool = False
    not_null: bool = True
    missing_threshold: Optional[float] = None
    custom_validator: Optional[str] = None

---

**Slide 56**
COLUMN SCHEMA
class ColumnSchema(BaseModel):
    name: str
    type: ColumnType
    description: Optional[str] = None
    constraints: ColumnConstraint = Field(default_factory=ColumnConstraint)
    is_target: bool = False
    is_identifier: bool = False
    is_timestamp: bool = False
    feature_group: Optional[str] = None
    importance: float = 1.0

---

**Slide 57**
DATA SCHEMA
class DataSchema(BaseModel):
    name: str
    version: str = "1.0.0"
    description: Optional[str] = None
    columns: List[ColumnSchema]
    created_at: datetime = Field(default_factory=datetime.now)
    min_rows: Optional[int] = None
    max_rows: Optional[int] = None
    require_all_columns: bool = True

---

**Slide 58**
TITANIC SCHEMA EXAMPLE
TitanicSchema(
    name="titanic",
    version="1.0.0",
    columns=[
        ColumnSchema(name="passenger_id", type=ColumnType.INTEGER, constraints=ColumnConstraint(unique=True)),
        ColumnSchema(name="survived", type=ColumnType.INTEGER, constraints=ColumnConstraint(allowed_values=[0, 1]), is_target=True),
        ColumnSchema(name="pclass", type=ColumnType.INTEGER, constraints=ColumnConstraint(allowed_values=[1, 2, 3])),
        ColumnSchema(name="name", type=ColumnType.STRING, constraints=ColumnConstraint(not_null=True)),
        ColumnSchema(name="sex", type=ColumnType.CATEGORICAL, constraints=ColumnConstraint(allowed_values=["male", "female"])),
        ColumnSchema(name="age", type=ColumnType.FLOAT, constraints=ColumnConstraint(min_value=0.0, max_value=120.0, missing_threshold=0.3)),
        # ...
    ]
)

---

**Slide 59**
DATA QUALITY CHECKER
class DataQualityChecker:
    def __init__(self, schema=None, config=None):
        self.schema = schema
        self.config = config
        self.validator = DataValidator(config=config)
        self.thresholds = {
            "missing_critical": 0.3,
            "missing_warning": 0.1,
            "outlier_critical": 0.1,
            "outlier_warning": 0.05,
            "correlation_high": 0.8,
            "correlation_perfect": 0.99,
            "cardinality_high": 50,
            "cardinality_very_high": 1000,
            "zero_variance": 0.01
        }

---

**Slide 60**
ASSESS METHOD
def assess(self, df):
    report = {
        "timestamp": datetime.now().isoformat(),
        "dataset_stats": self._get_basic_stats(df),
        "schema_validation": self._validate_schema(df) if self.schema else None,
        "missing_analysis": self._analyze_missing(df),
        "outlier_analysis": self._analyze_outliers(df),
        "statistical_profiles": self._generate_statistical_profiles(df),
        "correlation_analysis": self._analyze_correlations(df),
        "duplicate_analysis": self._analyze_duplicates(df),
        "cardinality_analysis": self._analyze_cardinality(df),
        "quality_scores": self._calculate_quality_scores(report),
        "recommendations": self._generate_recommendations(report),
        "quality_grade": self._calculate_quality_grade(report)
    }
    return report

---

**Slide 61**
ANALYZE_MISSING
def _analyze_missing(self, df):
    missing_counts = df.isnull().sum()
    missing_percentages = (missing_counts / len(df)) * 100
    columns_with_missing = missing_counts[missing_counts > 0]
    return {
        "total_missing": missing_counts.sum(),
        "total_missing_percentage": (missing_counts.sum() / (len(df) * len(df.columns))) * 100,
        "columns_with_missing": len(columns_with_missing),
        "missing_by_column": {col: {"count": int(missing_counts[col]), "percentage": float(missing_percentages[col])} for col in columns_with_missing.index},
        "missing_patterns": self._analyze_missing_patterns(df)
    }

---

**Slide 62**
ANALYZE_OUTLIERS
def _analyze_outliers(self, df):
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    outlier_analysis = {"methods_used": ["iqr", "zscore"], "columns_analyzed": numeric_cols, "outliers": {}}
    for col in numeric_cols:
        data = df[col].dropna()
        Q1 = data.quantile(0.25)
        Q3 = data.quantile(0.75)
        IQR = Q3 - Q1
        iqr_outliers = ((data < (Q1 - 1.5 * IQR)) | (data > (Q3 + 1.5 * IQR))).sum()
        outlier_analysis["outliers"][col] = {"iqr": {"count": iqr_outliers, "percentage": (iqr_outliers / len(data)) * 100}}
    return outlier_analysis

---

**Slide 63**
QUALITY SCORES
def _calculate_quality_scores(self, report):
    # Completeness (missing values)
    missing_pct = report.get("missing_analysis", {}).get("total_missing_percentage", 0)
    scores["completeness"] = max(0, 100 - missing_pct)
    # Consistency (schema validation)
    scores["consistency"] = ...
    # Uniqueness (duplicates)
    dup_pct = report.get("duplicate_analysis", {}).get("duplicate_percentage", 0)
    scores["uniqueness"] = max(0, 100 - dup_pct * 2)
    # Overall (weighted average)
    scores["overall"] = sum(score * weights[key] for key, score in scores.items())

---

**Slide 64**
QUALITY GRADE
def _calculate_quality_grade(self, report):
    overall_score = report.get("quality_scores", {}).get("overall", 0)
    if overall_score >= 90: return "A"
    elif overall_score >= 80: return "B"
    elif overall_score >= 70: return "C"
    elif overall_score >= 60: return "D"
    else: return "F"

---

**Slide 65**
RECOMMENDATIONS
def _generate_recommendations(self, report):
    recommendations = []
    # Missing values
    high_missing = missing.get("columns_by_missing_rate", {}).get("high", [])
    if high_missing:
        recommendations.append(f"Apply imputation for columns: {high_missing}")
    # Outliers
    critical_outliers = outlier_analysis.get("critical_columns", [])
    if critical_outliers:
        recommendations.append(f"Investigate outliers in columns: {critical_outliers}")
    # Correlations
    perfect_corrs = corr_analysis.get("perfect_correlations", [])
    if perfect_corrs:
        recommendations.append(f"Remove redundant features: {perfect_corrs}")
    # Duplicates
    if dup_analysis.get("has_duplicates"):
        recommendations.append(f"Remove duplicate rows ({dup_analysis.get('duplicate_count')} rows)")
    return recommendations

---

**Slide 66**
GENERATE_VISUAL_REPORT
def generate_visual_report(self, df, report, output_path):
    # Figure 1: Missing value heatmap
    fig1, ax1 = plt.subplots(figsize=(12, 8))
    missing_matrix = df.isnull()
    sns.heatmap(missing_matrix, cbar=True, yticklabels=False, cmap='viridis')
    # Figure 2: Missing percentages
    fig2, ax2 = plt.subplots(figsize=(12, 6))
    missing_pcts = df.isnull().mean() * 100
    missing_pcts[missing_pcts > 0].plot(kind='barh')
    # Figure 3: Correlation heatmap
    fig4, ax4 = plt.subplots(figsize=(10, 8))
    sns.heatmap(corr, annot=True, fmt='.2f', cmap='coolwarm')
    # Generate HTML report

---

**Slide 67**
HTML REPORT TEMPLATE
<!DOCTYPE html>
<html>
<head><title>Data Quality Report</title>
<style>
body { font-family: Arial; margin: 20px; }
.grade-A { background: #27ae60; color: white; }
.grade-F { background: #e74c3c; color: white; }
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <h1>Data Quality Assessment Report</h1>
  </div>
  <div class="section">
    <h2>Quality Grade: {quality_grade}</h2>
  </div>
</div>
</body>
</html>

---

**Slide 68**
DATA PIPELINE INTEGRATION
class DataPipeline:
    def __init__(self, schema=None, config=None):
        self.schema = schema
        self.ingestor = DataIngestor(**config)
        self.validator = DataValidator(config=config)
        self.quality_checker = DataQualityChecker(schema=schema, config=config)

    def load_data(self, file_path, file_type="csv", **kwargs):
        # Load data
    def validate_and_assess(self, df, generate_report=True):
        # Validate and assess
    def generate_report(self, results, df, output_path):
        # Generate visual report

---

**Slide 69**
TEST DATA WITH QUALITY ISSUES
• Missing values (50 rows)
• Duplicates (10 rows)
• Outliers (extreme values)
• Invalid values (wrong categories)
• High cardinality text
• Perfect correlation
• Zero variance column

---

**Slide 70**
KEY TAKEAWAYS
• Schema validation catches errors early
• Missing data has different mechanisms
• Outliers require multiple detection methods
• Quality scores quantify data health
• Visual reports aid communication

---

### PART 3: EXPLORATORY DATA ANALYSIS (Slides 71-90)

---

**Slide 71**
PART 3: EXPLORATORY DATA ANALYSIS
Understanding Your Data

---

**Slide 72**
TARGET
• Complete EDA framework
• Automated statistical analysis
• Interactive visualizations
• Target variable analysis
• Feature-target relationships
• Insights and recommendations
• HTML report generation

---

**Slide 73**
WHY EDA MATTERS
• Build a map of the data before modeling
• Discover patterns and relationships
• Identify subgroups or clusters
• Find informative features
• Detect hidden relationships
• Uncover data quality issues

---

**Slide 74**
EDA COMPONENTS
• Univariate Analysis: Individual features
• Bivariate Analysis: Pairwise relationships
• Multivariate Analysis: Multiple variables
• Target Analysis: Target distribution and relationships
• Data Quality: Missing patterns, outliers

---

**Slide 75**
EXPLORATORY DATA ANALYZER
class ExploratoryDataAnalyzer:
    def __init__(self, target_col=None, categorical_threshold=10):
        self.target_col = target_col
        self.categorical_threshold = categorical_threshold

    def analyze(self, df, deep_analysis=True):
        report = {
            "timestamp": datetime.now().isoformat(),
            "dataset_info": self._get_dataset_info(df),
            "column_types": self._identify_column_types(df),
            "univariate": self._analyze_univariate(df, column_types),
            "missing_analysis": self._analyze_missing_patterns(df),
            "correlations": self._analyze_correlations(df, column_types),
            "target_analysis": self._analyze_target(df, column_types) if self.target_col else None,
            "insights": self._generate_insights(report),
            "recommendations": self._generate_recommendations(report)
        }

---

**Slide 76**
IDENTIFY_COLUMN_TYPES
def _identify_column_types(self, df):
    for col in df.columns:
        if pd.api.types.is_datetime64_any_dtype(dtype):
            column_types[col] = "datetime"
        elif pd.api.types.is_numeric_dtype(dtype):
            if df[col].nunique() <= self.categorical_threshold:
                column_types[col] = "numeric_categorical"
            else:
                column_types[col] = "numeric"
        elif pd.api.types.is_categorical_dtype(dtype) or pd.api.types.is_object_dtype(dtype):
            n_unique = df[col].nunique()
            if n_unique <= self.categorical_threshold:
                column_types[col] = "categorical"
            else:
                column_types[col] = "high_cardinality_categorical"
    return column_types

---

**Slide 77**
UNIVARIATE ANALYSIS
def _analyze_univariate(self, df, column_types):
    for col in df.columns:
        analysis = {"type": column_types[col], "null_count": df[col].isnull().sum()}
        if col_type in ["numeric", "numeric_categorical"]:
            clean_data = col_data.dropna()
            analysis.update({
                "min": float(clean_data.min()),
                "max": float(clean_data.max()),
                "mean": float(clean_data.mean()),
                "median": float(clean_data.median()),
                "std": float(clean_data.std()),
                "skewness": float(clean_data.skew()),
                "kurtosis": float(clean_data.kurtosis()),
                "q1": float(clean_data.quantile(0.25)),
                "q3": float(clean_data.quantile(0.75)),
                "iqr": float(clean_data.quantile(0.75) - clean_data.quantile(0.25))
            })
        elif col_type in ["categorical", "high_cardinality_categorical"]:
            value_counts = col_data.value_counts()
            analysis.update({
                "most_frequent": str(value_counts.index[0]) if len(value_counts) > 0 else None,
                "top_10_values": {str(k): int(v) for k, v in value_counts.head(10).items()}
            })

---

**Slide 78**
CORRELATION ANALYSIS
def _analyze_correlations(self, df, column_types):
    numeric_cols = [col for col, dtype in column_types.items() if dtype in ["numeric", "numeric_categorical"]]
    if len(numeric_cols) < 2:
        return {"message": "Need at least 2 numeric columns"}
    pearson_corr = df[numeric_cols].corr(method='pearson')
    spearman_corr = df[numeric_cols].corr(method='spearman')
    high_corr_pairs = []
    for i in range(len(pearson_corr.columns)):
        for j in range(i+1, len(pearson_corr.columns)):
            corr = pearson_corr.iloc[i, j]
            if abs(corr) > 0.7:
                high_corr_pairs.append({"col1": pearson_corr.columns[i], "col2": pearson_corr.columns[j], "correlation": corr})
    return {"pearson_correlation": pearson_corr.to_dict(), "high_correlations": high_corr_pairs}

---

**Slide 79**
TARGET ANALYSIS
def _analyze_target(self, df, column_types):
    target_data = df[self.target_col]
    if target_type in ["numeric", "numeric_categorical"]:
        clean_data = target_data.dropna()
        analysis = {
            "min": float(clean_data.min()),
            "max": float(clean_data.max()),
            "mean": float(clean_data.mean()),
            "median": float(clean_data.median()),
            "std": float(clean_data.std()),
            "skewness": float(clean_data.skew()),
            "kurtosis": float(clean_data.kurtosis()),
            "problem_type": "classification" if target_data.nunique() <= self.categorical_threshold else "regression"
        }
        if analysis["problem_type"] == "classification":
            class_counts = target_data.value_counts()
            analysis["class_counts"] = class_counts.to_dict()
            analysis["is_balanced"] = max(class_counts) / min(class_counts) < 3.0
    return analysis

---

**Slide 80**
INSIGHTS GENERATION
def _generate_insights(self, report):
    insights = []
    # Duplicates
    if info.get('duplicate_percentage', 0) > 1:
        insights.append(f"Dataset contains {info.get('duplicate_rows')} duplicate rows ({info.get('duplicate_percentage'):.1f}%)")
    # Missing values
    if missing.get('columns_with_missing', 0) > 0:
        cols_with_missing = [col for col, rate in missing.get('missing_by_column', {}).items() if rate > 10]
        if cols_with_missing:
            insights.append(f"Columns with high missing rates: {cols_with_missing}")
    # Target imbalance
    if 'target_analysis' in report:
        if target.get('problem_type') == 'classification' and not target.get('is_balanced', True):
            insights.append(f"Target is imbalanced with class ratio {target.get('balance_ratio', 1.0):.2f}")
    return insights

---

**Slide 81**
RECOMMENDATIONS
def _generate_recommendations(self, report):
    recommendations = []
    # Skewed features
    skewed_features = [col for col, stats in univariate.items() if abs(stats.get('skewness', 0)) > 1.5]
    if skewed_features:
        recommendations.append(f"Apply log or Box-Cox transform to: {skewed_features[:5]}")
    # High cardinality
    high_cardinality = [col for col, stats in univariate.items() if stats.get('cardinality_level') == 'very_high']
    if high_cardinality:
        recommendations.append(f"Apply target encoding to: {high_cardinality[:3]}")
    # Target imbalance
    if target.get('problem_type') == 'classification' and not target.get('is_balanced', True):
        recommendations.append("Use stratified cross-validation and class_weight='balanced'")
    return recommendations

---

**Slide 82**
DATA VISUALIZER
class DataVisualizer:
    def __init__(self, style="seaborn-v0_8-whitegrid", figsize=(12, 8)):
        self.style = style
        self.figsize = figsize
        plt.style.use(style)

    def create_report(self, df, target_col=None, output_dir="reports/figures"):
        # 1. Dataset overview
        # 2. Distribution analysis
        # 3. Missing value analysis
        # 4. Correlation analysis
        # 5. Target analysis
        # 6. Categorical feature analysis
        # 7. Pairwise relationships

---

**Slide 83**
DISTRIBUTION PLOTS
def _create_distribution_plots(self, df, output_dir, max_features):
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    cols_to_plot = numeric_cols[:max_features]
    n_cols = min(len(cols_to_plot), 4)
    n_rows = math.ceil(len(cols_to_plot) / n_cols)
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(4*n_cols, 3*n_rows))
    for idx, col in enumerate(cols_to_plot):
        ax = axes[row][col_idx] if n_rows > 1 else axes[col_idx]
        ax.hist(df[col].dropna(), bins=30, density=True, alpha=0.6, color='steelblue')
        sns.kdeplot(df[col].dropna(), ax=ax, color='darkred')
        ax.set_title(col)

---

**Slide 84**
CORRELATION HEATMAP
def _create_correlation_plots(self, df, output_dir):
    numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    if len(numeric_cols) > 1:
        fig, ax = plt.subplots(figsize=(10, 8))
        corr = df[numeric_cols].corr()
        mask = np.triu(np.ones_like(corr, dtype=bool))
        sns.heatmap(corr, mask=mask, annot=True, fmt='.2f', cmap='coolwarm', vmin=-1, vmax=1, square=True)
        ax.set_title('Feature Correlation Heatmap')

---

**Slide 85**
TARGET PLOTS
def _create_target_plots(self, df, target_col, output_dir):
    target_data = df[target_col].dropna()
    if pd.api.types.is_numeric_dtype(target_data):
        # Distribution
        axes[0].hist(target_data, bins=30, edgecolor='black', alpha=0.7)
        axes[0].set_title(f'Distribution of {target_col}')
        # Box plot
        axes[1].boxplot(target_data, vert=False)
        axes[1].set_title(f'Box Plot of {target_col}')
    else:
        # Bar chart
        value_counts.plot(kind='bar', ax=axes[0])
        # Pie chart
        axes[1].pie(value_counts.values, labels=value_counts.index, autopct='%1.1f%%')

---

**Slide 86**
EDA REPORT GENERATOR
class EDAReportGenerator:
    def generate(self, eda_results, output_path, title="EDA Report"):
        html = f"""
        <!DOCTYPE html>
        <html>
        <head><title>{title}</title></head>
        <body>
            <div class="header">
                <h1>{title}</h1>
                <div>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</div>
            </div>
            <div class="grid">
                <div class="card">
                    <h3>Dataset Overview</h3>
                    <div>Rows: {info.get('rows', 0):,}</div>
                    <div>Columns: {info.get('columns', 0)}</div>
                </div>
            </div>
            <div class="section">
                <h2>Key Insights</h2>
                {''.join(f'<div class="insight">{insight}</div>' for insight in insights[:10])}
            </div>
        </body>
        </html>
        """

---

**Slide 87**
USING THE EDA SYSTEM
eda = ExploratoryDataAnalyzer(target_col='target')
report = eda.analyze(df, deep_analysis=True)
print(eda.generate_summary(report))
eda.save_report(report, "reports/eda")

visualizer = DataVisualizer()
visualizer.create_report(df, output_dir="reports/figures")

report_generator = EDAReportGenerator()
report_generator.generate(report, "reports/eda_report.html")

---

**Slide 88**
INTERPRETING EDA RESULTS
• Skewness > 1: Highly skewed, consider transformation
• Kurtosis > 3: Heavy tails, consider robust methods
• Correlation > 0.7: High correlation, consider removing one
• Missing > 20%: Consider imputation or dropping
• Class imbalance > 3: Use class weights or SMOTE

---

**Slide 89**
KEY TAKEAWAYS
• EDA reveals data structure
• Univariate analysis summarizes features
• Bivariate analysis finds relationships
• Target analysis guides modeling
• Insights drive feature engineering
• Visualizations communicate findings

---

**Slide 90**
NEXT: PART 4
Advanced Imputation and Scaling
• Multiple imputation strategies
• Robust scaling techniques
• Handling outliers
• Integration with pipeline

---

### PART 4: IMPUTATION & SCALING (Slides 91-110)

---

**Slide 91**
PART 4: ADVANCED IMPUTATION AND SCALING
Preparing Data for Modeling

---

**Slide 92**
TARGET
• Multiple imputation strategies
• Robust scaling techniques
• Unified API for preprocessing
• Integration with data pipeline
• Visualization of preprocessing effects

---

**Slide 93**
WHY PREPROCESSING MATTERS
• Missing values = missing ingredients
• Scaling = correct measurements
• Different features have different scales
• Many models assume features are on similar scales
• Without scaling, large magnitude features dominate

---

**Slide 94**
IMPUTATION STRATEGIES
MEAN: For symmetric distributions
MEDIAN: For skewed distributions
MODE: For categorical data
CONSTANT: Fill with a specific value
KNN: Use nearest neighbors
MICE: Multiple Imputation by Chained Equations
RANDOM FOREST: Model-based imputation
LINEAR: Linear regression imputation
INTERPOLATE: For time series
FORWARD/BACKWARD FILL: For time series

---

**Slide 95**
MISSING VALUE IMPUTER
class MissingValueImputer:
    def impute(self, df, numeric_strategy="median", categorical_strategy="mode", columns=None):
        df_result = df.copy()
        numeric_cols = df[columns].select_dtypes(include=[np.number]).columns.tolist()
        categorical_cols = df[columns].select_dtypes(include=['object', 'category']).columns.tolist()
        for col in numeric_cols:
            df_result[col] = self._impute_numeric(df_result[col], numeric_strategy)
        for col in categorical_cols:
            df_result[col] = self._impute_categorical(df_result[col], categorical_strategy)
        return df_result

---

**Slide 96**
IMPUTE_NUMERIC
def _impute_numeric(self, series, strategy):
    data = series.values.reshape(-1, 1)
    if strategy == "mean":
        imputer = SimpleImputer(strategy='mean')
    elif strategy == "median":
        imputer = SimpleImputer(strategy='median')
    elif strategy == "constant":
        imputer = SimpleImputer(strategy='constant', fill_value=self.fill_value)
    elif strategy == "knn":
        imputer = KNNImputer(n_neighbors=self.n_neighbors)
    elif strategy == "mice":
        imputer = IterativeImputer(estimator=LinearRegression())
    elif strategy == "linear":
        imputer = IterativeImputer(estimator=LinearRegression())
    return pd.Series(imputer.fit_transform(data).flatten(), index=series.index)

---

**Slide 97**
IMPUTE_CATEGORICAL
def _impute_categorical(self, series, strategy):
    if strategy == "mode":
        mode_value = series.mode()
        fill_value = mode_value.iloc[0] if len(mode_value) > 0 else "unknown"
        return series.fillna(fill_value)
    elif strategy == "constant":
        return series.fillna(self.fill_value)
    elif strategy == "forward_fill":
        return series.fillna(method='ffill')
    elif strategy == "backward_fill":
        return series.fillna(method='bfill')
    elif strategy == "knn":
        le = LabelEncoder()
        encoded = le.fit_transform(series.astype(str).fillna('missing'))
        data = encoded.reshape(-1, 1)
        imputer = KNNImputer(n_neighbors=self.n_neighbors)
        imputed = imputer.fit_transform(data)
        imputed_int = np.round(imputed.flatten()).astype(int)
        return pd.Series(le.inverse_transform(imputed_int), index=series.index)

---

**Slide 98**
MODEL-BASED IMPUTATION
def impute_with_model(self, df, target_col, model_type="random_forest", columns=None):
    missing_mask = df[target_col].isnull()
    train_df = df[~missing_mask]
    predict_df = df[missing_mask]
    X_train = train_df[columns].dropna(axis=0, how='any')
    y_train = train_df.loc[X_train.index, target_col]
    if model_type == "random_forest":
        model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    X_predict = predict_df[columns].dropna(axis=0, how='any')
    predictions = model.predict(X_predict)
    df_result.loc[X_predict.index, target_col] = predictions
    return df_result

---

**Slide 99**
SCALING STRATEGIES
STANDARD: (x - μ) / σ (z-score, mean=0, std=1)
ROBUST: (x - median) / IQR (handles outliers)
MINMAX: (x - min) / (max - min) (range [0,1])
MAXABS: x / max(abs) (range [-1,1])
POWER: Box-Cox or Yeo-Johnson (handles skewness)
QUANTILE: Rank-based transformation
NORMALIZER: L1 or L2 normalization
NONE: No scaling

---

**Slide 100**
FEATURE SCALER
class FeatureScaler:
    def __init__(self, strategy="standard", columns=None, **kwargs):
        self.strategy = strategy
        self.columns = columns
        self.kwargs = kwargs

    def fit(self, X):
        X_copy = self._prepare_data(X)
        self._scaler = self._create_scaler()
        self._scaler.fit(X_copy)
        self._fitted = True

    def transform(self, X):
        X_copy = self._prepare_data(X)
        X_transformed = self._scaler.transform(X_copy)
        if isinstance(X, pd.DataFrame):
            if self.columns is not None:
                result = X.copy()
                result[self.columns] = X_transformed
                return result
            return pd.DataFrame(X_transformed, index=X.index, columns=X.columns)
        return X_transformed

---

**Slide 101**
CREATE_SCALER
def _create_scaler(self):
    if self.strategy == "standard":
        return StandardScaler(**self.kwargs)
    elif self.strategy == "robust":
        return RobustScaler(**self.kwargs)
    elif self.strategy == "minmax":
        return MinMaxScaler(**self.kwargs)
    elif self.strategy == "maxabs":
        return MaxAbsScaler(**self.kwargs)
    elif self.strategy == "power":
        return PowerTransformer(method=self.kwargs.get('method', 'yeo-johnson'))
    elif self.strategy == "quantile":
        return QuantileTransformer(output=self.kwargs.get('output', 'normal'))
    elif self.strategy == "normalizer":
        return Normalizer(norm=self.kwargs.get('norm', 'l2'))
    elif self.strategy == "none":
        class IdentityScaler:
            def fit(self, X, y=None): return self
            def transform(self, X): return X
        return IdentityScaler()
    return StandardScaler()

---

**Slide 102**
SMART SCALER
class SmartScaler(FeatureScaler):
    def fit(self, X):
        for col in columns:
            data = X[col].dropna()
            Q1 = data.quantile(0.25)
            Q3 = data.quantile(0.75)
            IQR = Q3 - Q1
            outlier_pct = ((data < (Q1 - 1.5 * IQR)) | (data > (Q3 + 1.5 * IQR))).sum() / len(data)
            skewness = abs(data.skew())
            if outlier_pct > 0.05:
                strategy = "robust"
            elif skewness > 1:
                strategy = "power"
            else:
                strategy = "standard"
            self._selected_strategies[col] = strategy

---

**Slide 103**
DATA PREPROCESSOR
class DataPreprocessor:
    def __init__(self, numeric_imputation="median", categorical_imputation="mode", scaling_strategy="standard"):
        self.numeric_imputation = numeric_imputation
        self.categorical_imputation = categorical_imputation
        self.scaling_strategy = scaling_strategy

    def fit(self, X):
        self._identify_columns(X)
        self._imputer = MissingValueImputer()
        self._imputer.impute(X, numeric_strategy=self.numeric_imputation, categorical_strategy=self.categorical_imputation)
        self._scaler = FeatureScaler(strategy=self.scaling_strategy, columns=self.numeric_columns)
        self._scaler.fit(X)

    def transform(self, X):
        X_imputed = self._imputer.impute(X, numeric_strategy=self.numeric_imputation, categorical_strategy=self.categorical_imputation)
        X_scaled = self._scaler.transform(X_imputed)
        return X_scaled

---

**Slide 104**
VISUALIZATION OF PREPROCESSING
class PreprocessingVisualizer:
    def compare_imputation(self, df_before, df_after, column):
        fig, axes = plt.subplots(1, 2, figsize=(12, 5))
        data_before = df_before[column].dropna()
        axes[0].hist(data_before, bins=30, alpha=0.7, color='steelblue')
        axes[0].set_title(f'Before Imputation')
        data_after = df_after[column]
        axes[1].hist(data_after, bins=30, alpha=0.7, color='coral')
        axes[1].set_title(f'After Imputation')
        return fig

---

**Slide 105**
TESTING THE PREPROCESSING
# Create sample data with missing values
np.random.seed(42)
df = pd.DataFrame({
    'age': np.random.normal(35, 10, 100),
    'income': np.random.exponential(50000, 100),
    'category': np.random.choice(['A', 'B', 'C'], 100),
})
df.loc[np.random.choice(100, 15, replace=False), 'age'] = np.nan
df.loc[np.random.choice(100, 10, replace=False), 'income'] = np.nan

imputer = MissingValueImputer()
df_imputed = imputer.impute(df, numeric_strategy='median', categorical_strategy='mode')

scaler = FeatureScaler(strategy='robust', columns=['age', 'income'])
df_scaled = scaler.fit_transform(df_imputed)

preprocessor = DataPreprocessor(numeric_imputation='median', categorical_imputation='mode', scaling_strategy='smart')
df_processed = preprocessor.fit_transform(df)

---

**Slide 106**
PREPROCESSING SUMMARY
preprocessor.get_preprocessing_summary()
{
    "numeric_columns": ["age", "income"],
    "categorical_columns": ["category"],
    "numeric_imputation": "median",
    "categorical_imputation": "mode",
    "scaling_strategy": "smart",
    "exclude_columns": []
}

---

**Slide 107**
WHEN TO USE EACH STRATEGY
MEAN: Symmetric data, no outliers
MEDIAN: Skewed data, outliers present
MODE: Categorical data
KNN: Data has local structure
MICE: Multiple correlated features
STANDARD: Normal distributions
ROBUST: Outliers present
MINMAX: Bounded data needed
POWER: Highly skewed data

---

**Slide 108**
HANDLING OUTLIERS
• IQR method: Values beyond 1.5 * IQR
• Z-score method: |z| > 3
• Modified Z-score: |MAD| > 3.5
• Winsorizing: Cap extreme values
• Robust scaling: Use median and IQR
• Log transformation: Reduce skewness

---

**Slide 109**
KEY TAKEAWAYS
• Missing values need strategic handling
• Different imputation for different types
• Scaling is essential for many models
• Robust scaling handles outliers
• Smart scaling auto-selects strategy
• Visualize preprocessing effects

---

**Slide 110**
NEXT: PART 5
Categorical Encoding Mastery
• One-Hot Encoding
• Target Encoding
• Frequency Encoding
• High-cardinality handling
• Integration with pipeline

---

### PART 5: CATEGORICAL ENCODING (Slides 111-130)

---

**Slide 111**
PART 5: CATEGORICAL ENCODING MASTERY
Converting Categories to Numbers

---

**Slide 112**
TARGET
• Multiple encoding strategies
• Target encoding with regularization
• High-cardinality handling
• Integration with scikit-learn pipelines
• Encoding impact analysis

---

**Slide 113**
WHY CATEGORICAL ENCODING MATTERS
• ML models speak numbers, not words
• Translation must preserve signal
• Bad encoding = lost information
• Different strategies for different data
• High cardinality = special handling needed

---

**Slide 114**
ENCODING STRATEGIES
ONE-HOT: Binary columns for each category
ORDINAL: Integer mapping (ordered)
TARGET: Replace with target mean
FREQUENCY: Replace with frequency
HASHING: Fixed-length hash vector
BINARY: Binary representation
COUNT: Count of occurrences
RANK: Rank of category

---

**Slide 115**
ONE-HOT ENCODER
class OneHotEncoderCustom:
    def __init__(self, columns=None, min_frequency=0.01, max_categories=None, drop_first=False):
        self.columns = columns
        self.min_frequency = min_frequency
        self.max_categories = max_categories
        self.drop_first = drop_first

    def fit(self, X, y=None):
        for col in columns:
            value_counts = X[col].value_counts()
            frequencies = value_counts / len(X)
            valid_categories = frequencies[frequencies >= self.min_frequency].index.tolist()
            if self.max_categories and len(valid_categories) > self.max_categories:
                valid_categories = value_counts.head(self.max_categories).index.tolist()
            other_values = set(X[col].unique()) - set(valid_categories)
            if other_values:
                valid_categories.append('__other__')
            self._category_mappings[col] = {'categories': valid_categories}
            encoder = OneHotEncoder(categories=[valid_categories], drop='first' if self.drop_first else None)
            encoder.fit(X[[col]])
            self._encoders[col] = encoder

---

**Slide 116**
TARGET ENCODER
class TargetEncoder:
    def __init__(self, columns=None, smoothing=1.0, min_samples_leaf=10, noise=0.0, cv_folds=5):
        self.columns = columns
        self.smoothing = smoothing
        self.min_samples_leaf = min_samples_leaf
        self.noise = noise
        self.cv_folds = cv_folds

    def fit_transform(self, X, y):
        self._prior = np.mean(y)
        for col in columns:
            stats = self._calculate_category_stats(X[col], y)
            self._mappings[col] = stats
        # Out-of-fold encoding to prevent leakage
        kf = StratifiedKFold(n_splits=self.cv_folds, shuffle=True, random_state=42)
        for train_idx, val_idx in kf.split(X, y):
            stats = self._calculate_category_stats(X.iloc[train_idx][col], y.iloc[train_idx])
            encoded[val_idx] = self._encode_column(X.iloc[val_idx][col], stats)

---

**Slide 117**
CATEGORY STATS
def _calculate_category_stats(self, series, y):
    df = pd.DataFrame({'category': series, 'target': y})
    stats = df.groupby('category').agg({'target': ['count', 'mean', 'std']})
    stats.columns = ['count', 'mean', 'std']
    def smoothed_mean(row):
        count = row['count']
        mean = row['mean']
        weight = 1 / (1 + np.exp(-(count - self.min_samples_leaf) / self.smoothing))
        weight = np.clip(weight, 0, 1)
        return self._prior * (1 - weight) + mean * weight
    stats['smoothed_mean'] = stats.apply(smoothed_mean, axis=1)
    return {'statistics': stats, 'categories': stats.index.tolist()}

---

**Slide 118**
FREQUENCY ENCODER
class FrequencyEncoder:
    def __init__(self, columns=None, normalize=True):
        self.columns = columns
        self.normalize = normalize

    def fit(self, X, y=None):
        for col in columns:
            value_counts = X[col].value_counts()
            frequencies = value_counts / len(X) if self.normalize else value_counts
            self._frequencies[col] = frequencies.to_dict()

    def transform(self, X):
        result = X.copy()
        for col in self.columns:
            result[col] = X[col].map(self._frequencies[col]).fillna(0)
        return result

---

**Slide 119**
HASHING ENCODER
class HashingEncoder:
    def __init__(self, columns=None, n_features=128, alternate_sign=True):
        self.columns = columns
        self.n_features = n_features
        self.alternate_sign = alternate_sign

    def transform(self, X):
        result_parts = []
        for col in self.columns:
            values = X[col].astype(str)
            hasher = FeatureHasher(n_features=self.n_features, input_type='string', alternate_sign=self.alternate_sign)
            hashed = hasher.transform(values.values.reshape(-1, 1))
            result_parts.append(hashed)
        from scipy.sparse import hstack
        result = hstack(result_parts)
        return pd.DataFrame.sparse.from_spmatrix(result)

---

**Slide 120**
ORDINAL ENCODER
class OrdinalEncoderCustom:
    def __init__(self, columns=None, ordering='frequency'):
        self.columns = columns
        self.ordering = ordering

    def fit(self, X, y=None):
        for col in columns:
            if self.ordering == 'frequency':
                categories = X[col].value_counts().index.tolist()
            elif self.ordering == 'target' and y is not None:
                grouped = pd.DataFrame({'col': X[col], 'target': y}).groupby('col')['target'].mean()
                categories = grouped.sort_values().index.tolist()
            self._mappings[col] = {'mapping': {cat: idx for idx, cat in enumerate(categories)}}

    def transform(self, X):
        result = X.copy()
        for col in self.columns:
            result[col] = X[col].map(self._mappings[col]['mapping']).fillna(-1)
        return result

---

**Slide 121**
UNIFIED CATEGORICAL ENCODER
class CategoricalEncoder:
    def __init__(self, strategy='auto', columns=None, target_col=None, **kwargs):
        self.strategy = strategy
        self.columns = columns
        self.target_col = target_col

    def fit(self, X, y=None):
        if self.strategy == 'auto':
            self._selected_strategy = self._select_strategy(X, y)
        self._encoder = self._create_encoder(columns, y)
        self._encoder.fit(X, y)

    def _select_strategy(self, X, y):
        n_rows = len(X)
        n_columns = len(columns)
        cardinalities = [X[col].nunique() for col in columns]
        avg_cardinality = np.mean(cardinalities) if cardinalities else 0
        max_cardinality = np.max(cardinalities) if cardinalities else 0
        if max_cardinality > 1000 or avg_cardinality > 100:
            return 'hashing'
        if avg_cardinality > 10 and max_cardinality > 20:
            return 'target'
        if avg_cardinality > 50 and n_columns > 10:
            return 'frequency'
        if avg_cardinality <= 10:
            return 'one_hot'
        return 'ordinal'

---

**Slide 122**
MULTI-STRATEGY ENCODER
class MultiStrategyEncoder:
    def __init__(self, column_strategies, default_strategy='one_hot', target_col=None):
        self.column_strategies = column_strategies
        self.default_strategy = default_strategy

    def fit(self, X, y=None):
        for col, strategy in self.column_strategies.items():
            encoder = CategoricalEncoder(strategy=strategy, columns=[col], target_col=self.target_col)
            encoder.fit(X, y)
            self._encoders[col] = encoder
        all_cols = X.select_dtypes(include=['object', 'category']).columns.tolist()
        default_cols = [col for col in all_cols if col not in self.column_strategies]
        for col in default_cols:
            encoder = CategoricalEncoder(strategy=self.default_strategy, columns=[col], target_col=self.target_col)
            encoder.fit(X, y)
            self._encoders[col] = encoder

---

**Slide 123**
ENCODING VISUALIZATION
class EncodingVisualizer:
    def compare_encodings(self, df_original, encoded_dfs, column):
        n_strategies = len(encoded_dfs) + 1
        fig, axes = plt.subplots(n_rows, n_cols, figsize=(12, 8))
        value_counts = df_original[column].value_counts().head(10)
        value_counts.plot(kind='bar', ax=axes[0])
        axes[0].set_title(f'Original: {column}')
        for idx, (strategy_name, df_encoded) in enumerate(encoded_dfs.items(), 1):
            if strategy_name == 'target':
                ax.hist(df_encoded[column], bins=30, alpha=0.7, color='coral')
                ax.set_title(f'Target Encoded: {column}')
            elif strategy_name == 'one_hot':
                one_hot_cols = [c for c in df_encoded.columns if c.startswith(f"{column}_")]
                sns.heatmap(df_encoded[one_hot_cols].iloc[:50], ax=ax, cmap='Blues', cbar=False)

---

**Slide 124**
ENCODING BEST PRACTICES
• One-Hot: Low cardinality (<10)
• Target: High cardinality with target
• Frequency: High cardinality without target
• Hashing: Very high cardinality (>1000)
• Ordinal: Ordered categories
• Always encode after train/test split
• Use cross-validation for target encoding
• Handle unseen categories in production
• Store encoders for inference

---

**Slide 125**
TESTING ENCODING
# Create sample data
df = pd.DataFrame({
    'city': np.random.choice(['NYC', 'LA', 'Chicago', 'Boston'], n_samples),
    'category': np.random.choice(['A', 'B', 'C', 'D'], n_samples),
    'target': np.random.normal(50, 15, n_samples)
})

encoder = OneHotEncoderCustom(columns=['city', 'category'], drop_first=True)
df_onehot = encoder.fit_transform(df)

encoder = TargetEncoder(columns=['city', 'category'], smoothing=1.0, cv_folds=3)
df_target = encoder.fit_transform(df, df['target'])

encoder = FrequencyEncoder(columns=['city', 'category'])
df_freq = encoder.fit_transform(df)

encoder = CategoricalEncoder(strategy='auto')
df_auto = encoder.fit_transform(df)

---

**Slide 126**
ENCODING SUMMARY
• One-hot: Simple, interpretable
• Target: Highly informative
• Frequency: Single column, captures rarity
• Hashing: Memory-efficient
• Auto-select: Smart default choice

---

**Slide 127**
HIGH-CARDINALITY HANDLING
def handle_high_cardinality(df, categorical_col, threshold=0.01):
    freq = df[categorical_col].value_counts(normalize=True)
    rare_categories = freq[freq < threshold].index.tolist()
    return df[categorical_col].apply(lambda x: 'other' if x in rare_categories else x)

---

**Slide 128**
KEY TAKEAWAYS
• Different encodings for different data
• Target encoding needs regularization
• High cardinality requires special handling
• Auto-select saves time
• Store encoders for inference
• Visualize encoding effects

---

**Slide 129**
WHEN TO USE EACH ENCODING
• One-Hot: Small datasets, interpretability needed
• Target: High cardinality, strong target relationship
• Frequency: High cardinality, importance based on frequency
• Hashing: Very high cardinality, streaming data
• Ordinal: Ordered categories

---

**Slide 130**
NEXT: PART 6
Feature Creation and Selection
• Polynomial features
• Interaction features
• Ratio features
• Feature selection methods
• Feature importance analysis

---

### PART 6: FEATURE CREATION & SELECTION (Slides 131-150)

---

**Slide 131**
PART 6: FEATURE CREATION AND SELECTION
Engineering Informative Features

---

**Slide 132**
TARGET
• Automated feature creation
• Domain-specific feature generators
• Multiple feature selection methods
• Feature importance analysis
• Visualization of feature importance

---

**Slide 133**
WHY FEATURE ENGINEERING MATTERS
• Feature engineering = most predictive power
• Raw ingredients → well-prepared ingredients
• Better features → better model performance
• Feature engineering is the secret sauce
• Domain expertise + automated techniques

---

**Slide 134**
FEATURE CREATION
class FeatureCreator:
    def __init__(self, polynomial_degree=None, interactions=True, ratios=False, group_columns=None):
        self.polynomial_degree = polynomial_degree
        self.interactions = interactions
        self.ratios = ratios
        self.group_columns = group_columns

    def transform(self, X):
        result = X.copy()
        if self.polynomial_degree:
            poly_features = self._create_polynomials(X)
            result = pd.concat([result, poly_features], axis=1)
        if self.ratios:
            ratio_features = self._create_ratio_features(X)
            result = pd.concat([result, ratio_features], axis=1)
        if self.group_columns:
            agg_features = self._create_aggregation_features(X)
            result = pd.concat([result, agg_features], axis=1)
        return result

---

**Slide 135**
POLYNOMIAL FEATURES
def _create_polynomials(self, X):
    numeric_cols = X.select_dtypes(include=[np.number]).columns
    poly = PolynomialFeatures(degree=self.polynomial_degree, include_bias=False)
    poly_features = poly.fit_transform(X[numeric_cols])
    poly_names = poly.get_feature_names_out(numeric_cols)
    return pd.DataFrame(poly_features, columns=poly_names, index=X.index)

---

**Slide 136**
RATIO FEATURES
def _create_ratio_features(self, X):
    numeric_cols = self._numeric_columns
    ratio_features = {}
    for i, col1 in enumerate(numeric_cols):
        for col2 in numeric_cols[i+1:]:
            ratio_features[f"{col1}_div_{col2}"] = X[col1] / X[col2].replace(0, np.nan)
            ratio_features[f"{col2}_div_{col1}"] = X[col2] / X[col1].replace(0, np.nan)
            ratio_features[f"{col1}_minus_{col2}"] = X[col1] - X[col2]
            ratio_features[f"{col1}_times_{col2}"] = X[col1] * X[col2]
    return pd.DataFrame(ratio_features, index=X.index)

---

**Slide 137**
AGGREGATION FEATURES
def _create_aggregation_features(self, X):
    agg_features = {}
    for group_col in group_cols:
        grouped = X.groupby(group_col)
        for num_col in numeric_cols:
            for func in ['mean', 'sum', 'max', 'min', 'std']:
                agg_values = grouped[num_col].agg(func)
                agg_features[f"{group_col}_{num_col}_{func}"] = X[group_col].map(agg_values)
    return pd.DataFrame(agg_features, index=X.index)

---

**Slide 138**
FEATURE SELECTOR
class FeatureSelector:
    def __init__(self, method='variance', n_features_to_select=None, estimator=None):
        self.method = method
        self.n_features_to_select = n_features_to_select
        self.estimator = estimator

    def fit(self, X, y=None):
        self._selector = self._create_selector(X, y)
        self._selector.fit(X, y)
        self._selected_indices = self._selector.get_support()

    def transform(self, X):
        X_selected = self._selector.transform(X)
        if isinstance(X, pd.DataFrame):
            selected_columns = X.columns[self._selected_indices]
            return pd.DataFrame(X_selected, columns=selected_columns, index=X.index)
        return X_selected

---

**Slide 139**
CREATE_SELECTOR
def _create_selector(self, X, y):
    if self.method == 'variance':
        return VarianceThreshold(threshold=self.threshold or 0.0)
    elif self.method == 'correlation':
        score_func = f_classif if len(np.unique(y)) <= 2 else f_regression
        return SelectKBest(score_func=score_func, k=self.n_features_to_select or 10)
    elif self.method == 'mutual_info':
        score_func = mutual_info_classif if len(np.unique(y)) <= 2 else mutual_info_regression
        return SelectKBest(score_func=score_func, k=self.n_features_to_select or 10)
    elif self.method == 'rfe':
        return RFE(estimator=self.estimator, n_features_to_select=self.n_features_to_select or 10)
    elif self.method == 'model':
        return SelectFromModel(self.estimator or RandomForestClassifier())
    elif self.method == 'lasso':
        estimator = LogisticRegression(penalty='l1', solver='saga') if len(np.unique(y)) <= 2 else Lasso(alpha=0.01)
        return SelectFromModel(estimator)

---

**Slide 140**
AUTO FEATURE SELECTOR
class AutoFeatureSelector:
    def __init__(self, methods=None, n_features_list=None, estimator=None, cv=5):
        self.methods = methods or ['variance', 'mutual_info', 'model', 'lasso']
        self.n_features_list = n_features_list or [10, 20, 30, 50]
        self.estimator = estimator

    def fit(self, X, y):
        best_score = -np.inf
        for method in self.methods:
            for n_features in self.n_features_list:
                selector = FeatureSelector(method=method, n_features_to_select=n_features)
                X_selected = selector.fit_transform(X, y)
                scores = cross_val_score(self.estimator, X_selected, y, cv=self.cv)
                if np.mean(scores) > best_score:
                    best_score = np.mean(scores)
                    self._best_selector = selector
        return self

---

**Slide 141**
FEATURE IMPORTANCE
# Model-based importance (Random Forest)
rf = RandomForestClassifier()
rf.fit(X, y)
importance = pd.DataFrame({'feature': X.columns, 'importance': rf.feature_importances_}).sort_values('importance', ascending=False)

# Permutation importance
result = permutation_importance(model, X, y, n_repeats=10)
importance = pd.DataFrame({'feature': X.columns, 'importance': result.importances_mean})

# SHAP importance
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X)
importance = pd.DataFrame({'feature': X.columns, 'importance': np.abs(shap_values).mean(axis=0)})

---

**Slide 142**
VISUALIZING FEATURE IMPORTANCE
def plot_feature_importance(importance_dict, top_k=20):
    sorted_items = sorted(importance_dict.items(), key=lambda x: x[1], reverse=True)[:top_k]
    features, importances = zip(*sorted_items)
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.barh(range(len(features)), importances, color='steelblue')
    ax.set_yticks(range(len(features)))
    ax.set_yticklabels(features)
    ax.set_xlabel('Importance')
    ax.set_title(f'Top {len(features)} Feature Importances')
    ax.invert_yaxis()
    return fig

---

**Slide 143**
FEATURE SELECTION METHODS
FILTER: Statistical measures (correlation, chi-square, mutual info)
WRAPPER: Model-based selection (RFE, forward/backward)
EMBEDDED: Feature importance from model (Lasso, Random Forest)
HYBRID: Combination of methods

---

**Slide 144**
WHEN TO USE EACH METHOD
VARIANCE: Remove constant/near-constant features
CORRELATION: Keep features correlated with target
MUTUAL INFO: Capture non-linear relationships
RFE: Model-specific, expensive
MODEL: Fast, model-specific
LASSO: Feature selection + regularization

---

**Slide 145**
TESTING FEATURE CREATION
creator = FeatureCreator(polynomial_degree=2, interactions=True, ratios=True)
X_enhanced = creator.fit_transform(X)
print(f"Original: {X.shape}, Enhanced: {X_enhanced.shape}")

selector = FeatureSelector(method='model', n_features_to_select=20)
X_selected = selector.fit_transform(X_enhanced, y)
print(f"Selected: {X_selected.shape}")

auto = AutoFeatureSelector()
X_auto = auto.fit_transform(X_enhanced, y)

---

**Slide 146**
FEATURE ENGINEERING PIPELINE
• Raw data → Preprocessing → Encoding
• Feature creation (polynomials, interactions, ratios)
• Feature selection
• Dimensionality reduction (optional)
• Model training

---

**Slide 147**
KEY TAKEAWAYS
• Feature creation adds predictive power
• Polynomials capture non-linearity
• Interactions capture combined effects
• Feature selection removes noise
• Multiple selection methods available
• Feature importance guides engineering

---

**Slide 148**
DOMAIN-SPECIFIC FEATURES
• Date/Time: Day of week, month, hour
• Geographic: Distance, region
• Text: Length, word count, sentiment
• Financial: Ratios, growth rates
• Customer: Lifetime value, recency, frequency

---

**Slide 149**
FEATURE SELECTION BEST PRACTICES
• Always select after train/test split
• Use cross-validation for selection
• Consider business requirements
• Document feature definitions
• Validate selected features on holdout

---

**Slide 150**
NEXT: PART 7
Dimensionality Reduction and Imbalanced Learning
• PCA, LDA, t-SNE, UMAP
• SMOTE, ADASYN
• Class weighting
• Ensemble methods

---

### PART 7: DIMENSIONALITY REDUCTION & IMBALANCE (Slides 151-170)

---

**Slide 151**
PART 7: DIMENSIONALITY REDUCTION AND IMBALANCED LEARNING
Managing Complexity and Class Distribution

---

**Slide 152**
TARGET
• Linear dimensionality reduction (PCA, LDA)
• Non-linear reduction (t-SNE, UMAP)
• Automated dimensionality selection
• Multiple imbalance handling strategies
• Visualization of reduced dimensions

---

**Slide 153**
THE CURSE OF DIMENSIONALITY
• More dimensions = more data needed
• Sparse data in high dimensions
• Distances become meaningless
• Overfitting becomes easier
• Computation becomes expensive
• Interpretability decreases

---

**Slide 154**
PCA: PRINCIPAL COMPONENT ANALYSIS
• Find directions of maximum variance
• Linear transformation
• Preserve variance, reduce dimensions
• Components are orthogonal
• Explained variance ratio shows importance

---

**Slide 155**
DIMENSIONALITY REDUCER
class DimensionalityReducer:
    def __init__(self, method='pca', n_components=None, random_state=42):
        self.method = method
        self.n_components = n_components
        self.random_state = random_state

    def fit(self, X, y=None):
        self._reducer = self._create_reducer(X, y)
        self._reducer.fit(X, y)

    def transform(self, X):
        X_reduced = self._reducer.transform(X)
        if isinstance(X, pd.DataFrame):
            col_names = [f'PC{i+1}' for i in range(X_reduced.shape[1])] if self.method == 'pca' else [f'component_{i+1}' for i in range(X_reduced.shape[1])]
            return pd.DataFrame(X_reduced, columns=col_names, index=X.index)
        return X_reduced

---

**Slide 156**
CREATE_REDUCER
def _create_reducer(self, X, y):
    if self.method == 'pca':
        return PCA(n_components=self.n_components, random_state=self.random_state)
    elif self.method == 'lda':
        return LinearDiscriminantAnalysis(n_components=self.n_components)
    elif self.method == 'tsne':
        return TSNE(n_components=self.n_components or 2, random_state=self.random_state)
    elif self.method == 'umap':
        import umap
        return umap.UMAP(n_components=self.n_components or 2, random_state=self.random_state)

---

**Slide 157**
AUTO DIMENSION SELECTOR
class AutoDimensionSelector:
    def fit(self, X, y):
        component_range = [2, 5, 10, 20, 30, 50]
        for n_components in component_range:
            reducer = DimensionalityReducer(method='pca', n_components=n_components)
            X_reduced = reducer.fit_transform(X, y)
            scores = cross_val_score(self.estimator, X_reduced, y, cv=self.cv)
            if np.mean(scores) > best_score:
                best_n = n_components
        return best_n

---

**Slide 158**
t-SNE FOR VISUALIZATION
• Preserves local structure
• Excellent for visualization (2D/3D)
• Computationally expensive
• Non-deterministic
• Doesn't preserve global structure
• Use for exploration, not production

---

**Slide 159**
UMAP
• Preserves manifold structure
• Faster than t-SNE
• Better global structure preservation
• More deterministic
• Good for large datasets
• Works well with other algorithms

---

**Slide 160**
IMBALANCED LEARNING
• Class distribution is skewed
• Majority class dominates
• Accuracy is misleading
• Model predicts majority class
• Minority class performance is poor
• Business impact can be severe

---

**Slide 161**
IMBALANCE HANDLER
class ImbalanceHandler:
    def __init__(self, method='smote', sampling_strategy='auto', random_state=42):
        self.method = method
        self.sampling_strategy = sampling_strategy
        self.random_state = random_state

    def fit_resample(self, X, y):
        self._resampler = self._create_resampler()
        X_resampled, y_resampled = self._resampler.fit_resample(X, y)
        return X_resampled, y_resampled

---

**Slide 162**
CREATE_RESAMPLER
def _create_resampler(self):
    if self.method == 'smote':
        return SMOTE(sampling_strategy=self.sampling_strategy, random_state=self.random_state)
    elif self.method == 'adasyn':
        return ADASYN(sampling_strategy=self.sampling_strategy, random_state=self.random_state)
    elif self.method == 'random_over':
        return RandomOverSampler(sampling_strategy=self.sampling_strategy, random_state=self.random_state)
    elif self.method == 'random_under':
        return RandomUnderSampler(sampling_strategy=self.sampling_strategy, random_state=self.random_state)
    elif self.method == 'smote_enn':
        return SMOTEENN(sampling_strategy=self.sampling_strategy, random_state=self.random_state)
    elif self.method == 'smote_tomek':
        return SMOTETomek(sampling_strategy=self.sampling_strategy, random_state=self.random_state)

---

**Slide 163**
COST-SENSITIVE LEARNING
class CostSensitiveHandler:
    def fit(self, y):
        classes = np.unique(y)
        class_weights = compute_class_weight('balanced', classes=classes, y=y)
        self._class_weights = {cls: weight for cls, weight in zip(classes, class_weights)}

    def get_class_weights(self):
        return self._class_weights

# Usage in model:
model = RandomForestClassifier(class_weight='balanced')
model = LogisticRegression(class_weight='balanced')
model = SVC(class_weight='balanced')

---

**Slide 164**
BALANCED ENSEMBLE
class BalancedEnsemble:
    def __init__(self, base_estimator=None, n_estimators=100):
        self.base_estimator = base_estimator or DecisionTreeClassifier()
        self.n_estimators = n_estimators

    def fit(self, X, y):
        self._ensemble = BalancedRandomForestClassifier(
            base_estimator=self.base_estimator,
            n_estimators=self.n_estimators,
            random_state=42,
            n_jobs=-1
        )
        self._ensemble.fit(X, y)

---

**Slide 165**
WHEN TO USE EACH IMBALANCE METHOD
SMOTE: Moderate imbalance, sufficient minority data
ADASYN: Hard-to-learn minority examples
RANDOM OVER: Simple, fast
RANDOM UNDER: Large dataset, simple models
SMOTE-ENN: Clean noisy data
SMOTE-TOMEK: Remove borderline samples
COST-SENSITIVE: Can't resample data
BALANCED ENSEMBLE: Robust performance

---

**Slide 166**
EVALUATING IMBALANCED DATA
• ROC-AUC (primary)
• PR-AUC (especially for highly imbalanced)
• F1 Score (balance precision/recall)
• Balanced Accuracy (average recall per class)
• MCC (Matthews Correlation Coefficient)
• Confusion Matrix (detailed view)
• Precision/Recall (business-dependent)

---

**Slide 167**
TESTING DIMENSIONALITY REDUCTION
pca = DimensionalityReducer(method='pca', n_components=0.95)
X_pca = pca.fit_transform(X)
print(f"Original: {X.shape}, Reduced: {X_pca.shape}")

lda = DimensionalityReducer(method='lda', n_components=1)
X_lda = lda.fit_transform(X, y)

tsne = DimensionalityReducer(method='tsne', n_components=2)
X_tsne = tsne.fit_transform(X[:200])

auto = AutoDimensionSelector()
X_auto = auto.fit_transform(X, y)

---

**Slide 168**
TESTING IMBALANCE HANDLING
handler = ImbalanceHandler(method='smote')
X_resampled, y_resampled = handler.fit_resample(X, y)
print(f"Original: {np.bincount(y)}")
print(f"Resampled: {np.bincount(y_resampled)}")

cs = CostSensitiveHandler()
cs.fit(y)
print(cs.get_class_weights())

ensemble = BalancedEnsemble()
ensemble.fit(X, y)

---

**Slide 169**
VISUALIZING DIMENSIONALITY REDUCTION
def plot_pca_components(X_reduced, y):
    fig, ax = plt.subplots(figsize=(10, 8))
    scatter = ax.scatter(X_reduced[:, 0], X_reduced[:, 1], c=y, cmap='viridis', alpha=0.6)
    ax.set_xlabel('PC1')
    ax.set_ylabel('PC2')
    ax.set_title('PCA Projection')
    plt.colorbar(scatter)
    return fig

---

**Slide 170**
KEY TAKEAWAYS
• Dimensionality reduction handles the curse
• PCA for linear variance retention
• t-SNE/UMAP for visualization
• Imbalanced data requires special handling
• SMOTE creates synthetic minority samples
• Cost-sensitive learning penalizes majority
• Balanced ensembles improve performance

---

### PART 8: TREE-BASED & ENSEMBLE MODELS (Slides 171-200)

---

**Slide 171**
PART 8: TREE-BASED AND ENSEMBLE MODELS
Powerful Non-Linear Models

---

**Slide 172**
TARGET
• Decision Tree implementation with visualization
• Random Forest with comprehensive tuning
• XGBoost integration with custom objectives
• LightGBM for efficiency
• CatBoost for native categorical support
• Unified API for all tree-based models

---

**Slide 173**
WHY TREES ARE POWERFUL
• Non-linear: Capture complex relationships
• Interpretable: Can be visualized
• Robust: Not sensitive to outliers
• Handle mixed data: Numeric + categorical
• Feature importance: Natural importance measures
• No scaling required

---

**Slide 174**
THE EVOLUTION OF TREES
Decision Trees (1984) → Random Forest (2001) → Gradient Boosting (1999) → XGBoost (2014) → LightGBM (2017) → CatBoost (2017)

---

**Slide 175**
TREE MODEL
class TreeModel:
    def __init__(self, model_type='random_forest', task='classification', **kwargs):
        self.model_type = model_type
        self.task = task
        self.kwargs = kwargs

    def fit(self, X, y):
        self._model = self._create_model()
        self._model.fit(X, y)

    def predict(self, X):
        return self._model.predict(X)

    def predict_proba(self, X):
        return self._model.predict_proba(X)

    def get_feature_importance(self):
        return self._model.feature_importances_

---

**Slide 176**
CREATE_MODEL
def _create_model(self):
    model_info = {
        'decision_tree': DecisionTreeClassifier if self.task == 'classification' else DecisionTreeRegressor,
        'random_forest': RandomForestClassifier if self.task == 'classification' else RandomForestRegressor,
        'xgboost': XGBClassifier if self.task == 'classification' else XGBRegressor,
        'lightgbm': LGBMClassifier if self.task == 'classification' else LGBMRegressor,
        'catboost': CatBoostClassifier if self.task == 'classification' else CatBoostRegressor
    }
    default_params = {
        'decision_tree': {'max_depth': 5, 'min_samples_split': 10},
        'random_forest': {'n_estimators': 100, 'max_depth': 10},
        'xgboost': {'n_estimators': 100, 'max_depth': 6, 'learning_rate': 0.3},
        'lightgbm': {'n_estimators': 100, 'max_depth': 6, 'learning_rate': 0.1},
        'catboost': {'iterations': 100, 'depth': 6, 'learning_rate': 0.1}
    }
    params = {**default_params.get(self.model_type, {}), **self.kwargs}
    return model_info[self.model_type](**params)

---

**Slide 177**
XGBOOST FEATURES
• Regularization: L1 (reg_alpha) and L2 (reg_lambda)
• Early stopping: Prevents overfitting
• Monotonic constraints: Enforce direction
• Custom objectives: Asymmetric costs
• Feature importance: Weight, gain, cover
• GPU acceleration: tree_method='gpu_hist'

---

**Slide 178**
XGBOOST WITH CUSTOM OBJECTIVE
def custom_objective(y_true, y_pred):
    grad = y_pred - y_true
    grad[y_true == 1] *= 2.0  # Penalize false negatives more
    hess = np.ones_like(y_true)
    return grad, hess

def custom_eval(y_true, y_pred):
    y_pred_binary = (y_pred > 0.5).astype(int)
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred_binary).ravel()
    profit = tp * 100 - fp * 10
    return 'profit', profit

model = xgb.XGBClassifier(objective=custom_objective, random_state=42)
model.fit(X, y, eval_metric=custom_eval)

---

**Slide 179**
LIGHTGBM FEATURES
• Histogram-based: Faster, memory efficient
• Leaf-wise growth: Better accuracy
• Categorical features: Native support
• Early stopping: Prevent overfitting
• GPU support: Faster training
• Feature importance: Split, gain

---

**Slide 180**
CATBOOST FEATURES
• Native categorical support: No pre-encoding needed
• Ordered boosting: Prevents overfitting
• Symmetric trees: Faster prediction
• Automatic feature selection: Built-in
• GPU support: Faster training
• Feature importance: PredictionValuesChange

---

**Slide 181**
MODEL COMPARATOR
class ModelComparator:
    def __init__(self, models, task='classification', cv=5):
        self.models = models
        self.task = task
        self.cv = cv

    def compare(self, X_train, y_train, X_test, y_test):
        results = []
        for model_type in self.models:
            model = TreeModel(model_type=model_type, task=self.task)
            model.fit(X_train, y_train)
            y_pred = model.predict(X_test)
            metrics = self._calculate_metrics(y_test, y_pred)
            cv_scores = cross_val_score(model, X_train, y_train, cv=self.cv)
            results.append({'model': model_type, 'cv_mean': np.mean(cv_scores), **metrics})
        return pd.DataFrame(results)

---

**Slide 182**
GETTING FEATURE IMPORTANCE
# Random Forest
importance = pd.DataFrame({
    'feature': X.columns,
    'importance': rf_model.feature_importances_
}).sort_values('importance', ascending=False)

# XGBoost
importance = pd.DataFrame({
    'feature': X.columns,
    'importance': xgb_model.feature_importances_
}).sort_values('importance', ascending=False)

# Plot
fig, ax = plt.subplots(figsize=(10, 8))
importance.head(20).plot(kind='barh', x='feature', y='importance', ax=ax)
ax.set_title('Feature Importance')
plt.tight_layout()

---

**Slide 183**
PLOTTING DECISION TREE
from sklearn.tree import plot_tree

tree = DecisionTreeClassifier(max_depth=3, random_state=42)
tree.fit(X_train, y_train)

plt.figure(figsize=(20, 10))
plot_tree(tree, feature_names=X.columns, class_names=['No Churn', 'Churn'], filled=True, rounded=True)
plt.show()

---

**Slide 184**
HYPERPARAMETER TUNING FOR TREES
Random Forest:
- n_estimators: 50-500
- max_depth: 3-15
- min_samples_split: 2-20
- min_samples_leaf: 1-10
- max_features: 'sqrt', 'log2', None

XGBoost:
- n_estimators: 50-500
- max_depth: 3-12
- learning_rate: 0.01-0.3
- subsample: 0.6-1.0
- colsample_bytree: 0.6-1.0
- reg_alpha: 0-1
- reg_lambda: 0-1

---

**Slide 185**
WHEN TO USE EACH TREE MODEL
DECISION TREE: Interpretability needed, small datasets
RANDOM FOREST: Good default, handles non-linearity
XGBOOST: Best performance, large datasets
LIGHTGBM: Very large datasets, speed needed
CATBOOST: Categorical features, good default

---

**Slide 186**
TESTING TREE MODELS
dt = TreeModel(model_type='decision_tree', task='classification', max_depth=5)
dt.fit(X_train, y_train)
print(f"Decision Tree Accuracy: {dt.score(X_test, y_test):.4f}")

rf = TreeModel(model_type='random_forest', task='classification', n_estimators=100)
rf.fit(X_train, y_train)
print(f"Random Forest Accuracy: {rf.score(X_test, y_test):.4f}")

xgb = TreeModel(model_type='xgboost', task='classification', n_estimators=100)
xgb.fit(X_train, y_train)
print(f"XGBoost Accuracy: {xgb.score(X_test, y_test):.4f}")

---

**Slide 187**
KEY TAKEAWAYS
• Trees capture non-linear relationships
• Random Forest reduces overfitting
• XGBoost offers best performance
• LightGBM is fast and efficient
• CatBoost handles categoricals natively
• Feature importance guides interpretation

---

**Slide 188**
ENSEMBLE METHODS
Bagging: Train models on bootstrap samples, average predictions
Boosting: Sequentially correct errors
Stacking: Train meta-model on predictions
Voting: Combine predictions from multiple models

---

**Slide 189**
NEXT: PART 9
Unsupervised Learning
• K-Means clustering
• DBSCAN
• Hierarchical clustering
• Clustering validation
• Cluster profiling

---

### PART 9: UNSUPERVISED LEARNING (Slides 190-205)

---

**Slide 190**
PART 9: UNSUPERVISED LEARNING
Discovering Hidden Patterns

---

**Slide 191**
TARGET
• K-Means clustering with automated K selection
• DBSCAN with adaptive parameter tuning
• Hierarchical clustering with dendrogram visualization
• Clustering validation metrics
• Cluster profiling and interpretation

---

**Slide 192**
WHY UNSUPERVISED LEARNING
• Discover unknown patterns
• Data exploration
• Preprocessing for supervised learning
• Anomaly detection
• Dimensionality reduction
• Customer segmentation

---

**Slide 193**
CLUSTERING MODEL
class ClusteringModel:
    def __init__(self, method='kmeans', n_clusters=None, scale_data=True, random_state=42):
        self.method = method
        self.n_clusters = n_clusters
        self.scale_data = scale_data
        self.random_state = random_state

    def fit(self, X):
        X_scaled = self._scale_data(X)
        self._model = self._create_model()
        self._model.fit(X_scaled)
        self._labels = self._model.labels_

    def predict(self, X):
        X_scaled = self._scale_data(X)
        return self._model.predict(X_scaled)

    def evaluate(self, X):
        metrics = {
            'silhouette': silhouette_score(X, self._labels),
            'davies_bouldin': davies_bouldin_score(X, self._labels),
            'calinski_harabasz': calinski_harabasz_score(X, self._labels)
        }
        return metrics

---

**Slide 194**
CREATE_MODEL
def _create_model(self):
    if self.method == 'kmeans':
        return KMeans(n_clusters=self.n_clusters or 8, random_state=self.random_state)
    elif self.method == 'dbscan':
        return DBSCAN(eps=self.kwargs.get('eps', 0.5), min_samples=self.kwargs.get('min_samples', 5))
    elif self.method == 'hierarchical':
        return AgglomerativeClustering(n_clusters=self.n_clusters, linkage=self.kwargs.get('linkage', 'ward'))
    elif self.method == 'gmm':
        return GaussianMixture(n_components=self.n_clusters or 8, random_state=self.random_state)

---

**Slide 195**
OPTIMAL K SELECTOR
class OptimalKSelector:
    def select(self, X):
        results = {'k': [], 'inertia': [], 'silhouette': [], 'gap': []}
        for k in range(2, min(11, X.shape[0])):
            kmeans = KMeans(n_clusters=k, random_state=42)
            kmeans.fit(X)
            results['k'].append(k)
            results['inertia'].append(kmeans.inertia_)
            if len(np.unique(kmeans.labels_)) >= 2:
                results['silhouette'].append(silhouette_score(X, kmeans.labels_))
            else:
                results['silhouette'].append(0)
        # Elbow method
        diff1 = np.diff(results['inertia'])
        diff2 = np.diff(diff1)
        k_elbow = results['k'][np.argmax(diff2) + 1]
        # Max silhouette
        k_silhouette = results['k'][np.argmax(results['silhouette'])]
        self._optimal_k = max(k_elbow, k_silhouette)
        return self._optimal_k

---

**Slide 196**
HIERARCHICAL CLUSTERING
class HierarchicalClustering:
    def fit(self, X):
        self._linkage_matrix = linkage(X, method='ward')
        return self

    def fit_predict(self, X, n_clusters=None, distance_threshold=None):
        if n_clusters is not None:
            self._labels = fcluster(self._linkage_matrix, n_clusters, criterion='maxclust')
        elif distance_threshold is not None:
            self._labels = fcluster(self._linkage_matrix, distance_threshold, criterion='distance')
        return self._labels

    def plot_dendrogram(self, max_d=None):
        fig, ax = plt.subplots(figsize=(12, 8))
        dendrogram(self._linkage_matrix, ax=ax, color_threshold=max_d)
        ax.set_xlabel('Sample Index')
        ax.set_ylabel('Distance')
        ax.set_title('Dendrogram')
        if max_d:
            ax.axhline(y=max_d, color='red', linestyle='--', label=f'Threshold: {max_d:.2f}')
        return fig

---

**Slide 197**
CLUSTER PROFILES
def get_cluster_profiles(X, labels):
    profiles = []
    unique_labels = np.unique(labels[labels >= 0])
    for cluster_id in unique_labels:
        mask = labels == cluster_id
        cluster_data = X[mask]
        profile = {
            'cluster': cluster_id,
            'size': len(cluster_data),
            'percentage': (len(cluster_data) / len(X)) * 100,
            'means': cluster_data.mean(axis=0)
        }
        profiles.append(profile)
    return pd.DataFrame(profiles)

---

**Slide 198**
CLUSTERING VISUALIZATION
def plot_clusters(X, labels, method='pca'):
    if method == 'pca':
        reducer = PCA(n_components=2)
        X_reduced = reducer.fit_transform(X)
    elif method == 'tsne':
        reducer = TSNE(n_components=2)
        X_reduced = reducer.fit_transform(X[:1000])
    fig, ax = plt.subplots(figsize=(10, 8))
    unique_labels = np.unique(labels[labels >= 0])
    colors = plt.cm.viridis(np.linspace(0, 1, len(unique_labels)))
    for i, cluster_id in enumerate(unique_labels):
        mask = labels == cluster_id
        ax.scatter(X_reduced[mask, 0], X_reduced[mask, 1], c=[colors[i]], label=f'Cluster {cluster_id}', alpha=0.6)
    if -1 in labels:
        mask = labels == -1
        ax.scatter(X_reduced[mask, 0], X_reduced[mask, 1], c='gray', label='Noise', alpha=0.4)
    ax.legend()
    return fig

---

**Slide 199**
CLUSTERING VALIDATION METRICS
SILHOUETTE SCORE: [-1, 1], higher is better
DAVIES-BOULDIN: Lower is better
CALINSKI-HARABASZ: Higher is better

Silhouette interpretation:
> 0.7: Strong clustering
> 0.5: Reasonable clustering
> 0.3: Weak clustering
< 0.2: No clustering

---

**Slide 200**
TESTING CLUSTERING
kmeans = ClusteringModel(method='kmeans', n_clusters=4)
labels = kmeans.fit_predict(X)
print(f"Clusters found: {len(np.unique(labels))}")
print(f"Cluster sizes: {pd.Series(labels).value_counts().to_dict()}")
metrics = kmeans.evaluate(X)
print(metrics)

k_selector = OptimalKSelector()
optimal_k = k_selector.select(X)
print(f"Optimal K: {optimal_k}")

hierarchical = HierarchicalClustering()
hierarchical.fit(X)
labels = hierarchical.fit_predict(X, n_clusters=4)
dendrogram = hierarchical.plot_dendrogram()

---

**Slide 201**
DBSCAN ADVANTAGES
• Finds arbitrary shapes
• Handles noise/outliers
• No K required
• Works with varying densities
• Two parameters: eps and min_samples

---

**Slide 202**
WHEN TO USE EACH CLUSTERING METHOD
K-MEANS: Spherical clusters, known K, large datasets
DBSCAN: Arbitrary shapes, unknown K, outliers present
HIERARCHICAL: Hierarchical structure, small datasets
GMM: Ellipsoidal clusters, soft assignments
SPECTRAL: Non-convex clusters

---

**Slide 203**
KEY TAKEAWAYS
• Clustering discovers natural groupings
• K-Means is simple and fast
• DBSCAN handles arbitrary shapes
• Hierarchical shows structure
• Validation metrics guide selection
• Cluster profiles aid interpretation

---

**Slide 204**
NEXT: PART 10
Deep Learning Fundamentals
• Neural network architecture
• PyTorch tensor operations
• Custom neural network layers
• Training loops with optimization
• Activation and loss functions

---

### PART 10: DEEP LEARNING (Slides 205-225)

---

**Slide 205**
PART 10: DEEP LEARNING FUNDAMENTALS
Building Neural Networks

---

**Slide 206**
TARGET
• Understanding of neural network architecture
• PyTorch tensor operations and autograd
• Custom neural network layers
• Training loops with optimization
• Multiple activation and loss functions

---

**Slide 207**
WHY PYTORCH
• Dynamic computation graphs
• Pythonic: Feels like Python
• GPU support: Seamless transition
• Community: Huge ecosystem
• Debugging: Easy to inspect

---

**Slide 208**
SETUP_DEVICE
def setup_device(use_gpu=True):
    if use_gpu and torch.cuda.is_available():
        device = torch.device('cuda')
        print(f"Using GPU: {torch.cuda.get_device_name(0)}")
    elif use_gpu and torch.backends.mps.is_available():
        device = torch.device('mps')
        print("Using Apple MPS")
    else:
        device = torch.device('cpu')
        print("Using CPU")
    return device

---

**Slide 209**
MLP ARCHITECTURE
class MLP(nn.Module):
    def __init__(self, input_dim, hidden_dims, output_dim, activation='relu', dropout_rate=0.0):
        super().__init__()
        self.activation = self._get_activation(activation)
        layers = []
        prev_dim = input_dim
        for hidden_dim in hidden_dims:
            layers.append(nn.Linear(prev_dim, hidden_dim))
            layers.append(self.activation)
            if dropout_rate > 0:
                layers.append(nn.Dropout(dropout_rate))
            prev_dim = hidden_dim
        layers.append(nn.Linear(prev_dim, output_dim))
        self.layers = nn.Sequential(*layers)
        self._initialize_weights()

    def forward(self, x):
        return self.layers(x)

---

**Slide 210**
RESIDUAL BLOCK
class ResidualBlock(nn.Module):
    def __init__(self, dim, dropout_rate=0.0, use_batch_norm=True):
        super().__init__()
        self.linear1 = nn.Linear(dim, dim)
        self.linear2 = nn.Linear(dim, dim)
        self.bn1 = nn.BatchNorm1d(dim) if use_batch_norm else nn.Identity()
        self.bn2 = nn.BatchNorm1d(dim) if use_batch_norm else nn.Identity()
        self.dropout = nn.Dropout(dropout_rate) if dropout_rate > 0 else nn.Identity()
        self.relu = nn.ReLU()

    def forward(self, x):
        residual = x
        out = self.linear1(x)
        out = self.bn1(out)
        out = self.relu(out)
        out = self.dropout(out)
        out = self.linear2(out)
        out = self.bn2(out)
        out = out + residual  # Skip connection
        out = self.relu(out)
        return out

---

**Slide 211**
RESNET
class ResNet(nn.Module):
    def __init__(self, input_dim, hidden_dims, output_dim, num_blocks=3):
        super().__init__()
        self.input_proj = nn.Linear(input_dim, hidden_dims[0])
        self.blocks = nn.ModuleList()
        for _ in range(num_blocks):
            for dim in hidden_dims:
                self.blocks.append(ResidualBlock(dim))
        self.output = nn.Linear(hidden_dims[-1], output_dim)

    def forward(self, x):
        x = self.input_proj(x)
        for block in self.blocks:
            x = block(x)
        x = self.output(x)
        return x

---

**Slide 212**
AUTOENCODER
class Autoencoder(nn.Module):
    def __init__(self, input_dim, encoding_dim, hidden_dims=None):
        super().__init__()
        hidden_dims = hidden_dims or [input_dim // 2, input_dim // 4]
        self.encoding_dim = encoding_dim
        # Encoder
        encoder_layers = []
        prev_dim = input_dim
        for dim in hidden_dims:
            encoder_layers.append(nn.Linear(prev_dim, dim))
            encoder_layers.append(nn.ReLU())
            prev_dim = dim
        encoder_layers.append(nn.Linear(prev_dim, encoding_dim))
        self.encoder = nn.Sequential(*encoder_layers)
        # Decoder
        decoder_layers = []
        prev_dim = encoding_dim
        for dim in reversed(hidden_dims):
            decoder_layers.append(nn.Linear(prev_dim, dim))
            decoder_layers.append(nn.ReLU())
            prev_dim = dim
        decoder_layers.append(nn.Linear(prev_dim, input_dim))
        self.decoder = nn.Sequential(*decoder_layers)

    def forward(self, x):
        encoded = self.encoder(x)
        decoded = self.decoder(encoded)
        return decoded

---

**Slide 213**
DEEP TRAINER
class DeepTrainer:
    def __init__(self, model, criterion, optimizer, device=None):
        self.model = model
        self.criterion = criterion
        self.optimizer = optimizer
        self.device = device or setup_device()
        self.model.to(self.device)

    def train_epoch(self, loader):
        self.model.train()
        total_loss = 0
        for data, target in loader:
            data, target = data.to(self.device), target.to(self.device)
            self.optimizer.zero_grad()
            output = self.model(data)
            loss = self.criterion(output, target)
            loss.backward()
            self.optimizer.step()
            total_loss += loss.item()
        return total_loss / len(loader)

    def validate(self, loader):
        self.model.eval()
        correct = 0
        total = 0
        with torch.no_grad():
            for data, target in loader:
                data, target = data.to(self.device), target.to(self.device)
                output = self.model(data)
                pred = output.argmax(dim=1)
                correct += (pred == target).sum().item()
                total += target.size(0)
        return correct / total

---

**Slide 214**
EARLY STOPPING
class EarlyStopping:
    def __init__(self, patience=10, min_delta=1e-4, restore_best_weights=True):
        self.patience = patience
        self.min_delta = min_delta
        self.restore_best_weights = restore_best_weights
        self.counter = 0
        self.best_loss = None

    def __call__(self, val_loss, model):
        if self.best_loss is None or val_loss < self.best_loss - self.min_delta:
            self.best_loss = val_loss
            self.counter = 0
            return False
        self.counter += 1
        if self.counter >= self.patience:
            return True
        return False

---

**Slide 215**
ACTIVATION FUNCTIONS
RELU: max(0, x)
LEAKY_RELU: max(0.01x, x)
ELU: x if x>0; α(e^x-1) if x≤0
SELU: Self-normalizing
GELU: Gaussian error linear unit
SIGMOID: 1/(1+e^-x)
TANH: (e^x-e^-x)/(e^x+e^-x)
SOFTMAX: e^x_i / Σe^x_j

---

**Slide 216**
LOSS FUNCTIONS
CLASSIFICATION:
- Cross-Entropy: -Σ y_i * log(ŷ_i)
- Binary Cross-Entropy: -[y*log(ŷ) + (1-y)*log(1-ŷ)]
- Focal Loss: -α*(1-ŷ)^γ*log(ŷ)

REGRESSION:
- MSE: (1/n)Σ(y_i - ŷ_i)²
- MAE: (1/n)Σ|y_i - ŷ_i|
- Huber: MSE for small errors, MAE for large

---

**Slide 217**
TENSOR OPERATIONS
import torch
# Create tensors
t = torch.tensor([1, 2, 3])
t = torch.zeros(3, 4)
t = torch.ones(2, 3)
t = torch.randn(3, 4)
# Operations
t + t, t * t, t @ t.T
t.mean(), t.std(), t.sum()
t.cuda()  # Move to GPU
t.cpu()   # Move to CPU

---

**Slide 218**
AUTOGRAD
x = torch.tensor([2.0], requires_grad=True)
y = x ** 2
y.backward()
print(x.grad)  # 4.0

# Model parameters require gradients
model = nn.Linear(10, 1)
loss = criterion(model(x), y)
loss.backward()
optimizer.step()

---

**Slide 219**
TRAINING LOOP
for epoch in range(epochs):
    train_loss = trainer.train_epoch(train_loader)
    val_acc = trainer.validate(val_loader)
    if early_stopping(val_loss, model):
        break
    if scheduler:
        scheduler.step(val_loss)
    print(f"Epoch {epoch+1}: Train Loss: {train_loss:.4f}, Val Acc: {val_acc:.4f}")

---

**Slide 220**
GPU TRAINING
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = model.to(device)
data = data.to(device)
target = target.to(device)

# Check GPU
print(torch.cuda.is_available())
print(torch.cuda.get_device_name(0))
print(torch.cuda.memory_allocated())

---

**Slide 221**
TESTING DEEP LEARNING
model = MLP(input_dim=20, hidden_dims=[64, 32], output_dim=2)
trainer = DeepTrainer(model, criterion, optimizer)
trainer.train(train_loader, val_loader, epochs=50)
y_pred = trainer.predict(test_loader)
print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")

autoencoder = Autoencoder(input_dim=20, encoding_dim=8)
# Train autoencoder
autoencoder.train()

---

**Slide 222**
KEY TAKEAWAYS
• Neural networks learn from data
• Activation functions introduce non-linearity
• Loss functions measure error
• Backpropagation computes gradients
• Optimizers update weights
• GPU training speeds up training

---

**Slide 223**
NEXT: PART 11
Cross-Validation and Evaluation
• K-Fold, Stratified, GroupKFold, TimeSeriesSplit
• Precision, Recall, F1, ROC-AUC, PR-AUC
• MAE, RMSE, MAPE, R²
• Confusion matrix visualization

---

### PART 11: CROSS-VALIDATION & EVALUATION (Slides 224-245)

---

**Slide 224**
PART 11: CROSS-VALIDATION AND EVALUATION
Rigorous Model Assessment

---

**Slide 225**
TARGET
• Multiple cross-validation strategies
• Comprehensive classification metrics
• Comprehensive regression metrics
• Confusion matrix visualization
• Learning curves and validation curves

---

**Slide 226**
WHY VALIDATION MATTERS
• Estimate real-world performance
• Detect overfitting
• Compare models fairly
• Select best model
• Build confidence in predictions

---

**Slide 227**
CROSS-VALIDATOR
class CrossValidator:
    def __init__(self, method='stratified_kfold', n_splits=5, shuffle=True, random_state=42):
        self.method = method
        self.n_splits = n_splits
        self.shuffle = shuffle
        self.random_state = random_state

    def get_splits(self, X, y=None, groups=None):
        self._cv = self._create_cv()
        if self.method in ['stratified_kfold', 'stratified_shuffle']:
            return list(self._cv.split(X, y))
        elif self.method == 'group_kfold':
            return list(self._cv.split(X, groups=groups))
        else:
            return list(self._cv.split(X))

---

**Slide 228**
CREATE_CV
def _create_cv(self):
    if self.method == 'kfold':
        return KFold(n_splits=self.n_splits, shuffle=self.shuffle, random_state=self.random_state)
    elif self.method == 'stratified_kfold':
        return StratifiedKFold(n_splits=self.n_splits, shuffle=self.shuffle, random_state=self.random_state)
    elif self.method == 'group_kfold':
        return GroupKFold(n_splits=self.n_splits)
    elif self.method == 'timeseries':
        return TimeSeriesSplit(n_splits=self.n_splits)

---

**Slide 229**
VALIDATE
def validate(self, model, X, y, scoring=None):
    self._cv = self._create_cv()
    if scoring is None:
        scoring = 'accuracy' if len(np.unique(y)) <= 2 else 'neg_mean_squared_error'
    splits = self.get_splits(X, y)
    fold_results = []
    for fold, (train_idx, test_idx) in enumerate(splits):
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
        y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]
        model_copy = model.__class__(**model.get_params())
        model_copy.fit(X_train, y_train)
        y_pred = model_copy.predict(X_test)
        score = self._calculate_score(y_test, y_pred, scoring)
        fold_results.append({'fold': fold, 'score': score})
    return {'scores': [r['score'] for r in fold_results], 'mean_score': np.mean([r['score'] for r in fold_results]), 'std_score': np.std([r['score'] for r in fold_results])}

---

**Slide 230**
METRICS CALCULATOR
class MetricsCalculator:
    def compute_metrics(self, y_true, y_pred, y_proba=None):
        if self.task == 'classification':
            metrics = {
                'accuracy': accuracy_score(y_true, y_pred),
                'precision': precision_score(y_true, y_pred, average='weighted', zero_division=0),
                'recall': recall_score(y_true, y_pred, average='weighted', zero_division=0),
                'f1': f1_score(y_true, y_pred, average='weighted', zero_division=0)
            }
            if y_proba is not None:
                metrics['roc_auc'] = roc_auc_score(y_true, y_proba)
                metrics['average_precision'] = average_precision_score(y_true, y_proba)
        else:
            metrics = {
                'mse': mean_squared_error(y_true, y_pred),
                'rmse': np.sqrt(mean_squared_error(y_true, y_pred)),
                'mae': mean_absolute_error(y_true, y_pred),
                'mape': mean_absolute_percentage_error(y_true, y_pred),
                'r2': r2_score(y_true, y_pred)
            }
        return metrics

---

**Slide 231**
CLASSIFICATION METRICS
ACCURACY: (TP+TN)/(TP+TN+FP+FN)
PRECISION: TP/(TP+FP)
RECALL: TP/(TP+FN)
F1: 2*P*R/(P+R)
ROC-AUC: Area under ROC curve
PR-AUC: Area under PR curve

---

**Slide 232**
REGRESSION METRICS
MSE: Σ(y-ŷ)²/n
RMSE: √MSE
MAE: Σ|y-ŷ|/n
MAPE: Σ|(y-ŷ)/y|/n * 100
R²: 1 - SS_res/SS_tot

---

**Slide 233**
CONFUSION MATRIX
def confusion_matrix_summary(y_true, y_pred):
    cm = confusion_matrix(y_true, y_pred)
    tn, fp, fn, tp = cm.ravel()
    return {
        'true_positives': tp,
        'false_positives': fp,
        'true_negatives': tn,
        'false_negatives': fn,
        'sensitivity': tp / (tp + fn),
        'specificity': tn / (tn + fp),
        'precision': tp / (tp + fp),
        'accuracy': (tp + tn) / (tp + tn + fp + fn)
    }

---

**Slide 234**
PLOT CONFUSION MATRIX
def plot_confusion_matrix(y_true, y_pred):
    cm = confusion_matrix(y_true, y_pred)
    fig, ax = plt.subplots(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax)
    ax.set_xlabel('Predicted')
    ax.set_ylabel('Actual')
    ax.set_title('Confusion Matrix')
    return fig

---

**Slide 235**
ROC CURVE
def plot_roc_curve(y_true, y_proba):
    fpr, tpr, _ = roc_curve(y_true, y_proba)
    roc_auc = auc(fpr, tpr)
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.plot(fpr, tpr, label=f'ROC (AUC = {roc_auc:.3f})')
    ax.plot([0, 1], [0, 1], 'k--', label='Random')
    ax.set_xlabel('False Positive Rate')
    ax.set_ylabel('True Positive Rate')
    ax.set_title('ROC Curve')
    ax.legend()
    return fig

---

**Slide 236**
PR CURVE
def plot_pr_curve(y_true, y_proba):
    precision, recall, _ = precision_recall_curve(y_true, y_proba)
    pr_auc = auc(recall, precision)
    fig, ax = plt.subplots(figsize=(8, 6))
    ax.plot(recall, precision, label=f'PR (AUC = {pr_auc:.3f})')
    ax.set_xlabel('Recall')
    ax.set_ylabel('Precision')
    ax.set_title('Precision-Recall Curve')
    ax.legend()
    return fig

---

**Slide 237**
WHEN TO USE EACH METRIC
ACCURACY: Balanced classes
PRECISION: Minimize false positives
RECALL: Minimize false negatives
F1: Balance precision and recall
ROC-AUC: Overall performance
PR-AUC: Imbalanced data
MSE: Large errors penalized
MAE: Robust to outliers
R²: Variance explained

---

**Slide 238**
TESTING CROSS-VALIDATION
cv = CrossValidator(method='stratified_kfold', n_splits=5)
results = cv.validate(model, X, y, scoring='accuracy')
print(f"Mean Accuracy: {results['mean_score']:.4f} (+/- {results['std_score']:.4f})")

cv = CrossValidator(method='timeseries', n_splits=5)
results = cv.validate(model, X, y)

---

**Slide 239**
KEY TAKEAWAYS
• CV estimates real-world performance
• Different CV for different data types
• Metrics match business objectives
• Confusion matrix shows detailed performance
• ROC-AUC for ranking performance
• PR-AUC for imbalanced data

---

**Slide 240**
NEXT: PART 12
Hyperparameter Optimization
• Grid Search
• Random Search
• Bayesian Optimization with Optuna
• Automated tuning with pruning

---

### PART 12: HYPERPARAMETER OPTIMIZATION (Slides 241-260)

---

**Slide 241**
PART 12: HYPERPARAMETER OPTIMIZATION
Finding the Best Model Settings

---

**Slide 242**
TARGET
• Grid Search for exhaustive exploration
• Random Search for efficient exploration
• Bayesian Optimization with Optuna
• Automated tuning with pruning
• Visualization of optimization results

---

**Slide 243**
GRID SEARCH
class GridSearchOptimizer:
    def __init__(self, param_grid, cv=5, scoring=None):
        self.param_grid = param_grid
        self.cv = cv
        self.scoring = scoring

    def optimize(self, model, X, y):
        self._grid_search = GridSearchCV(model, self.param_grid, cv=self.cv, scoring=self.scoring, n_jobs=-1)
        self._grid_search.fit(X, y)
        return {
            'best_params': self._grid_search.best_params_,
            'best_score': self._grid_search.best_score_,
            'cv_results': self._grid_search.cv_results_
        }

---

**Slide 244**
RANDOM SEARCH
class RandomSearchOptimizer:
    def __init__(self, param_distributions, n_iter=100, cv=5, scoring=None):
        self.param_distributions = param_distributions
        self.n_iter = n_iter
        self.cv = cv
        self.scoring = scoring

    def optimize(self, model, X, y):
        self._random_search = RandomizedSearchCV(model, self.param_distributions, n_iter=self.n_iter, cv=self.cv, scoring=self.scoring, n_jobs=-1)
        self._random_search.fit(X, y)
        return {
            'best_params': self._random_search.best_params_,
            'best_score': self._random_search.best_score_
        }

---

**Slide 245**
OPTUNA TUNER
class OptunaTuner:
    def __init__(self, param_space, n_trials=100, direction='maximize', cv=5, scoring=None):
        self.param_space = param_space
        self.n_trials = n_trials
        self.direction = direction
        self.cv = cv
        self.scoring = scoring

    def optimize(self, X, y, model):
        def objective(trial):
            params = {}
            for param_name, param_range in self.param_space.items():
                if isinstance(param_range, list):
                    params[param_name] = trial.suggest_categorical(param_name, param_range)
                elif isinstance(param_range, tuple):
                    params[param_name] = trial.suggest_int(param_name, param_range[0], param_range[1])
            model.set_params(**params)
            scores = cross_val_score(model, X, y, cv=self.cv, scoring=self.scoring)
            return np.mean(scores)

        study = optuna.create_study(direction=self.direction)
        study.optimize(objective, n_trials=self.n_trials)
        return {'best_params': study.best_params, 'best_value': study.best_value}

---

**Slide 246**
PARAMETER SPACES
RANDOM FOREST:
{
    'n_estimators': (50, 200),
    'max_depth': (3, 10),
    'min_samples_split': (2, 10),
    'min_samples_leaf': (1, 4),
    'max_features': ['sqrt', 'log2']
}

XGBOOST:
{
    'n_estimators': (50, 200),
    'max_depth': (3, 10),
    'learning_rate': (0.01, 0.3),
    'subsample': (0.6, 1.0),
    'colsample_bytree': (0.6, 1.0)
}

---

**Slide 247**
AUTOMATED TUNER
class AutomatedTuner:
    def __init__(self, method='bayesian', n_trials=100, cv=5):
        self.method = method
        self.n_trials = n_trials
        self.cv = cv

    def tune(self, model, X, y, param_space):
        total_combinations = self._count_combinations(param_space)
        if self.method == 'auto':
            if total_combinations <= 20:
                method = 'grid'
            elif total_combinations <= 100:
                method = 'random'
            else:
                method = 'bayesian'
        else:
            method = self.method
        if method == 'grid':
            tuner = GridSearchOptimizer(param_space, cv=self.cv)
        elif method == 'random':
            tuner = RandomSearchOptimizer(param_space, n_iter=min(self.n_trials, 100), cv=self.cv)
        else:
            tuner = OptunaTuner(param_space, n_trials=self.n_trials, cv=self.cv)
        return tuner.optimize(model, X, y)

---

**Slide 248**
OPTUNA VISUALIZATION
def plot_optimization_history(study):
    fig = plot_optimization_history(study)
    fig.update_layout(title='Optimization History')
    return fig

def plot_param_importances(study):
    fig = plot_param_importances(study)
    fig.update_layout(title='Hyperparameter Importance')
    return fig

def plot_parallel_coordinate(study):
    fig = plot_parallel_coordinate(study)
    fig.update_layout(title='Parallel Coordinate Plot')
    return fig

---

**Slide 249**
PRUNING WITH OPTUNA
study = optuna.create_study(
    direction='maximize',
    pruner=MedianPruner(
        n_startup_trials=5,
        n_warmup_steps=10,
        interval_steps=1
    )
)

---

**Slide 250**
WHEN TO USE EACH METHOD
GRID SEARCH: Small spaces, known good ranges
RANDOM SEARCH: Medium spaces, unknown ranges
BAYESIAN: Large spaces, expensive evaluation
AUTO: Automatically selects best method

---

**Slide 251**
TESTING HYPERPARAMETER OPTIMIZATION
param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [3, 5, 7],
    'min_samples_split': [2, 5, 10]
}
grid = GridSearchOptimizer(param_grid)
results = grid.optimize(model, X, y)
print(results['best_params'])

param_dist = {
    'n_estimators': (50, 200),
    'max_depth': (3, 10)
}
random = RandomSearchOptimizer(param_dist, n_iter=30)
results = random.optimize(model, X, y)

optuna = OptunaTuner(param_space, n_trials=50)
results = optuna.optimize(X, y, model)

---

**Slide 252**
KEY TAKEAWAYS
• Grid search is exhaustive but slow
• Random search is more efficient
• Bayesian optimization is intelligent
• Optuna provides advanced features
• Automated tuning saves time
• Visualize results for insights

---

**Slide 253**
NEXT: PART 13
Pipeline Construction
• Leak-free preprocessing pipeline
• Integrated categorical encoding
• Model persistence and versioning
• Complete training pipeline

---

### PART 13: PIPELINE CONSTRUCTION (Slides 254-275)

---

**Slide 254**
PART 13: PIPELINE CONSTRUCTION
Building the Complete System

---

**Slide 255**
TARGET
• Leak-free preprocessing pipeline
• Integrated encoding, scaling, imbalance handling
• Built-in cross-validation
• Hyperparameter optimization integrated
• Model persistence and versioning
• Prediction pipeline for new data

---

**Slide 256**
THE PIPELINE ARCHITECTURE
Data Layer → Feature Layer → Model Layer → Validation Layer → Deployment Layer

---

**Slide 257**
MLPIPELINE
class MLPipeline:
    def __init__(self, config, schema=None):
        self.config = config
        self.schema = schema
        self._target_col = config.get('target_col')
        self._model_type = config.get('model_type', 'random_forest')

    def train(self, X, y=None, tune_hyperparameters=True):
        # Step 1: Data validation
        if self.schema:
            self.validator.validate_schema(X, self.schema)
        # Step 2: Preprocessing
        self.preprocessor = DataPreprocessor(...)
        X_preprocessed = self.preprocessor.fit_transform(X)
        # Step 3: Feature engineering
        self.encoder = CategoricalEncoder(...)
        X_encoded = self.encoder.fit_transform(X_preprocessed, y)
        # Step 4: Model creation
        self.model = self._create_model()
        # Step 5: Hyperparameter tuning
        if tune_hyperparameters:
            self.best_params = self._tune_hyperparameters(X_encoded, y)
            self.model.set_params(**self.best_params)
        # Step 6: Training
        self.model.fit(X_encoded, y)
        # Step 7: Evaluation
        eval_results = self._evaluate_model(X_encoded, y)

---

**Slide 258**
CREATE_MODEL
def _create_model(self):
    if self._model_type in ['decision_tree', 'random_forest', 'xgboost', 'lightgbm', 'catboost']:
        return TreeModel(model_type=self._model_type, task=self._task, **self.config.get('model_params', {}))
    elif self._model_type == 'mlp':
        return MLP(input_dim=self.config.get('n_features', 100), hidden_dims=[64, 32], output_dim=2)
    else:
        raise ValueError(f"Unknown model type: {self._model_type}")

---

**Slide 259**
TUNE_HYPERPARAMETERS
def _tune_hyperparameters(self, X, y):
    tuning_config = self.config.get('tuning', {})
    method = tuning_config.get('method', 'bayesian')
    param_space = self._get_param_space()
    if method == 'grid':
        tuner = GridSearchOptimizer(param_space, cv=tuning_config.get('cv', 3))
    elif method == 'random':
        tuner = RandomSearchOptimizer(param_space, n_iter=tuning_config.get('n_trials', 30), cv=tuning_config.get('cv', 3))
    else:
        tuner = OptunaTuner(param_space, n_trials=tuning_config.get('n_trials', 50), cv=tuning_config.get('cv', 3))
    results = tuner.optimize(self.model, X, y)
    return results['best_params']

---

**Slide 260**
EVALUATE_MODEL
def _evaluate_model(self, X, y):
    y_pred = self.model.predict(X)
    y_proba = self.model.predict_proba(X) if hasattr(self.model, 'predict_proba') else None
    calculator = MetricsCalculator(task=self._task)
    metrics = calculator.compute_metrics(y, y_pred, y_proba)
    cv = CrossValidator(method='stratified_kfold' if self._task == 'classification' else 'kfold')
    cv_results = cv.validate(self.model, X, y)
    return {'metrics': metrics, 'cv_mean': cv_results['mean_score'], 'cv_std': cv_results['std_score']}

---

**Slide 261**
PREDICT
def predict(self, X, return_proba=False):
    X_preprocessed = self.preprocessor.transform(X)
    X_encoded = self.encoder.transform(X_preprocessed)
    if return_proba and hasattr(self.model, 'predict_proba'):
        return self.model.predict_proba(X_encoded)
    return self.model.predict(X_encoded)

---

**Slide 262**
SAVE AND LOAD
def save(self, filepath):
    joblib.dump({
        'config': self.config,
        'preprocessor': self.preprocessor,
        'encoder': self.encoder,
        'model': self.model,
        'feature_names': self._feature_names,
        'best_params': self.best_params,
        'is_trained': self._is_trained
    }, filepath)

def load(self, filepath):
    data = joblib.load(filepath)
    self.config = data['config']
    self.preprocessor = data['preprocessor']
    self.encoder = data['encoder']
    self.model = data['model']
    self._is_trained = data['is_trained']

---

**Slide 263**
LEAK-FREE PIPELINE
• Split data before preprocessing
• Fit transformers on training only
• Transform test with training parameters
• Use cross-validation for feature selection
• Apply same transformations in production

---

**Slide 264**
CONFIGURATION-DRIVEN
{
  "model_type": "random_forest",
  "task": "classification",
  "target_col": "target",
  "imputation": {
    "numeric": "median",
    "categorical": "mode"
  },
  "scaling": {
    "method": "standard"
  },
  "encoding": {
    "strategy": "auto"
  },
  "tuning": {
    "method": "bayesian",
    "n_trials": 50,
    "cv": 5
  }
}

---

**Slide 265**
TRAINING SCRIPT
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', type=str, required=True)
    parser.add_argument('--data', type=str, required=True)
    parser.add_argument('--target', type=str, required=True)
    args = parser.parse_args()
    config = load_config(args.config)
    data = pd.read_csv(args.data)
    X = data.drop(columns=[args.target])
    y = data[args.target]
    pipeline = MLPipeline(config=config)
    pipeline.train(X, y)
    pipeline.save('models/pipeline.joblib')

---

**Slide 266**
PREDICTION SCRIPT
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--pipeline', type=str, required=True)
    parser.add_argument('--data', type=str, required=True)
    parser.add_argument('--output', type=str, default='predictions.csv')
    args = parser.parse_args()
    pipeline = MLPipeline(config={})
    pipeline.load(args.pipeline)
    data = pd.read_csv(args.data)
    predictions = pipeline.predict(data)
    pd.DataFrame({'prediction': predictions}).to_csv(args.output, index=False)

---

**Slide 267**
TESTING THE PIPELINE
config = {
    'model_type': 'random_forest',
    'task': 'classification',
    'target_col': 'target',
    'imputation': {'numeric': 'median', 'categorical': 'mode'},
    'scaling': {'method': 'standard'},
    'encoding': {'strategy': 'auto'},
    'tuning': {'method': 'random', 'n_trials': 10}
}

pipeline = MLPipeline(config=config)
results = pipeline.train(X_train, y_train, tune_hyperparameters=True)
pipeline.save('models/pipeline.joblib')
predictions = pipeline.predict(X_test)

---

**Slide 268**
KEY TAKEAWAYS
• Pipeline ensures consistency
• No data leakage
• All components integrated
• Configurable for different problems
• Save/load for deployment
• Training and prediction scripts

---

**Slide 269**
NEXT: PART 14
Capstone Project
• Real-world dataset
• End-to-end pipeline
• Model comparison
• Business impact analysis

---

### PART 14: CAPSTONE PROJECT (Slides 270-285)

---

**Slide 270**
PART 14: CAPSTONE PROJECT
Real-World Application

---

**Slide 271**
THE BUSINESS PROBLEM
Telecommunications company losing customers
Predict which customers are likely to churn
Take preventive action (discounts, improved service)

---

**Slide 272**
THE DATASET
Telco Customer Churn Dataset
• 7,043 customers
• 21 features
• Demographics, account information, services
• Target: Churn (Yes/No)

---

**Slide 273**
DATA PREPARATION
df = pd.read_csv('data/raw/WA_Fn-UseC_-Telco-Customer-Churn.csv')
df = df.drop(columns=['customerID'])
df['TotalCharges'] = pd.to_numeric(df['TotalCharges'], errors='coerce')
df['Churn'] = df['Churn'].map({'Yes': 1, 'No': 0})

---

**Slide 274**
FEATURE ENGINEERING
df['tenure_group'] = pd.cut(df['tenure'], bins=[0,12,24,48,72,120], labels=['0-12m', '12-24m', '24-48m', '48-72m', '72+m'])
df['avg_monthly_charge'] = df['TotalCharges'] / (df['tenure'] + 1)
services = ['PhoneService', 'MultipleLines', 'OnlineSecurity', 'OnlineBackup', 'DeviceProtection', 'TechSupport', 'StreamingTV', 'StreamingMovies']
df['num_services'] = df[services].apply(lambda x: (x != 'No').sum(), axis=1)
df['has_premium_services'] = df[premium_services].apply(lambda x: (x == 'Yes').sum(), axis=1)

---

**Slide 275**
CONFIGURATION
config = {
    'model_type': 'xgboost',
    'task': 'classification',
    'target_col': 'Churn',
    'imputation': {'numeric': 'median', 'categorical': 'mode'},
    'scaling': {'method': 'standard'},
    'encoding': {'strategy': 'auto'},
    'feature_selection': {'enabled': True, 'method': 'model', 'n_features': 25},
    'tuning': {'method': 'bayesian', 'n_trials': 50, 'cv': 5}
}

---

**Slide 276**
TRAINING
pipeline = MLPipeline(config=config)
results = pipeline.train(X, y, tune_hyperparameters=True)
pipeline.save('models/churn_pipeline.joblib')

---

**Slide 277**
EVALUATION RESULTS
ROC-AUC: 0.85
Precision: 0.68
Recall: 0.60
F1: 0.64
Accuracy: 0.82

---

**Slide 278**
FEATURE IMPORTANCE
• Tenure
• Contract Type
• Monthly Charges
• Total Charges
• Services used

---

**Slide 279**
BUSINESS IMPACT
• Identified ~400 at-risk customers
• Potential savings: ~$200,000 annually
• Focus retention on:
  - <12 months tenure
  - Month-to-month contracts
  - Without premium services

---

**Slide 280**
KEY INSIGHTS
• Tenure is the strongest predictor
• Month-to-month contracts have highest churn
• More services = lower churn
• Premium services reduce churn

---

**Slide 281**
NEXT: PART 15
Deployment and Monitoring
• FastAPI application
• Docker containerization
• Performance monitoring
• Drift detection

---

### PART 15: DEPLOYMENT & MONITORING (Slides 282-300)

---

**Slide 282**
PART 15: DEPLOYMENT AND MONITORING
Production-Ready System

---

**Slide 283**
TARGET
• FastAPI application serving predictions
• Docker containerization
• Model versioning and management
• Performance monitoring and drift detection
• Health checks and testing

---

**Slide 284**
FASTAPI APP
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Churn Prediction API")

class PredictionRequest(BaseModel):
    features: Dict[str, Any]

@app.post("/api/predict")
async def predict(request: PredictionRequest):
    df = pd.DataFrame([request.features])
    prediction = model.predict(df)
    probability = model.predict_proba(df)
    return {"prediction": int(prediction[0]), "probability": float(probability[0][1])}

@app.get("/api/health")
async def health():
    return {"status": "healthy", "model_loaded": model_loaded}

---

**Slide 285**
API ENDPOINTS
GET / → API information
GET /api/health → Health check
GET /api/model/info → Model information
POST /api/predict → Single prediction
POST /api/predict/batch → Batch predictions

---

**Slide 286**
DOCKERFILE
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]

---

**Slide 287**
DOCKER COMPOSE
version: '3.8'
services:
  api:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./models:/app/models
      - ./logs:/app/logs
    restart: unless-stopped

---

**Slide 288**
MODEL MONITOR
class ModelMonitor:
    def collect_metrics(self):
        return {
            'system': self._system_metrics(),
            'performance': self._performance_metrics(),
            'quality': self._quality_metrics(),
            'business': self._business_metrics()
        }

    def detect_drift(self, reference_data, current_data):
        for col in current_data.columns:
            if pd.api.types.is_numeric_dtype(current_data[col]):
                ks_stat, p_value = stats.ks_2samp(reference_data[col], current_data[col])
                if p_value < 0.05:
                    print(f"Drift detected in {col}")

---

**Slide 289**
