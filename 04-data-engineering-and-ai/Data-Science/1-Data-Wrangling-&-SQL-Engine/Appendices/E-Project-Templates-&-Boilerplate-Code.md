# APPENDIX E: Project Templates & Boilerplate Code

This appendix provides ready-to-use templates for common data science project structures, boilerplate code for data pipelines, and reusable utilities. Use these as starting points for your own projects.

---

## E.1 Project Structure Templates

### Template 1: Basic Data Science Project

```
project-name/
├── README.md                     # Project documentation
├── requirements.txt              # Python dependencies
├── .env                          # Environment variables (gitignored)
├── .gitignore                    # Git ignore file
├── Makefile                      # Build automation
│
├── data/                         # Data directory
│   ├── raw/                      # Raw, immutable data
│   ├── processed/                # Cleaned, processed data
│   └── external/                 # External reference data
│
├── notebooks/                    # Jupyter notebooks
│   ├── 01_data_exploration.ipynb
│   ├── 02_feature_engineering.ipynb
│   └── 03_modeling.ipynb
│
├── src/                          # Source code
│   ├── __init__.py
│   ├── data/                     # Data processing
│   │   ├── __init__.py
│   │   ├── loader.py
│   │   ├── cleaner.py
│   │   └── transformer.py
│   ├── features/                 # Feature engineering
│   │   ├── __init__.py
│   │   └── builder.py
│   ├── models/                   # Model code
│   │   ├── __init__.py
│   │   ├── train.py
│   │   └── predict.py
│   └── utils/                    # Utilities
│       ├── __init__.py
│       ├── logger.py
│       ├── config.py
│       └── metrics.py
│
├── tests/                        # Unit tests
│   ├── __init__.py
│   ├── test_data.py
│   ├── test_features.py
│   └── test_models.py
│
└── config/                       # Configuration files
    ├── config.yaml
    └── logging.yaml
```

### Template 2: ETL Pipeline Project

```
etl-pipeline/
├── README.md
├── requirements.txt
├── docker-compose.yml            # For local development
├── .env
│
├── dags/                         # Airflow DAGs
│   ├── __init__.py
│   ├── etl_dag.py
│   └── monitoring_dag.py
│
├── src/
│   ├── __init__.py
│   ├── extract/                  # Extraction modules
│   │   ├── __init__.py
│   │   ├── database_extractor.py
│   │   ├── api_extractor.py
│   │   └── file_extractor.py
│   ├── transform/                # Transformation modules
│   │   ├── __init__.py
│   │   ├── cleaner.py
│   │   ├── validator.py
│   │   └── aggregator.py
│   ├── load/                     # Loading modules
│   │   ├── __init__.py
│   │   ├── database_loader.py
│   │   └── file_writer.py
│   └── common/                   # Shared utilities
│       ├── __init__.py
│       ├── logging.py
│       ├── config.py
│       └── monitoring.py
│
├── tests/
│   ├── __init__.py
│   ├── test_extract.py
│   ├── test_transform.py
│   └── test_load.py
│
└── scripts/                      # Utility scripts
    ├── init_db.py
    ├── backfill.py
    └── cleanup.py
```

---

## E.2 Boilerplate Code Templates

### Template: Project Configuration

**config/config.yaml:**
```yaml
# Project configuration
project:
  name: "Data Engineering Project"
  version: "1.0.0"
  environment: "development"  # development, staging, production

# Data paths
paths:
  raw_data: "data/raw/"
  processed_data: "data/processed/"
  external_data: "data/external/"
  models: "models/"
  logs: "logs/"
  reports: "reports/"

# Database connections
databases:
  postgres:
    host: ${PG_HOST}
    port: ${PG_PORT}
    database: ${PG_DATABASE}
    user: ${PG_USER}
    password: ${PG_PASSWORD}
  duckdb:
    path: "data/duckdb.db"

# Data quality
quality:
  missing_threshold: 0.1
  duplicate_threshold: 0.05
  outlier_method: "iqr"
  outlier_threshold: 1.5

# Modeling
modeling:
  test_size: 0.2
  random_state: 42
  cv_folds: 5
  metrics: ["accuracy", "precision", "recall", "f1"]

# Logging
logging:
  level: "INFO"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  file: "logs/project.log"
```

**src/utils/config.py:**
```python
"""Configuration management module."""

import os
import yaml
from typing import Any, Dict
from pathlib import Path
from dotenv import load_dotenv


class Config:
    """Configuration manager that loads from YAML and environment variables."""
    
    def __init__(self, config_path: str = "config/config.yaml"):
        self.config_path = Path(config_path)
        self._config = self._load_config()
        
    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from YAML file."""
        if not self.config_path.exists():
            raise FileNotFoundError(f"Config file not found: {self.config_path}")
            
        with open(self.config_path, 'r') as f:
            config = yaml.safe_load(f)
            
        # Expand environment variables
        config = self._expand_env_vars(config)
        
        return config
    
    def _expand_env_vars(self, config: Any) -> Any:
        """Recursively expand environment variables in config."""
        if isinstance(config, dict):
            return {k: self._expand_env_vars(v) for k, v in config.items()}
        elif isinstance(config, list):
            return [self._expand_env_vars(v) for v in config]
        elif isinstance(config, str) and config.startswith('${') and config.endswith('}'):
            env_var = config[2:-1]
            return os.environ.get(env_var, config)
        else:
            return config
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get a configuration value by dot-notation key."""
        keys = key.split('.')
        value = self._config
        
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
                if value is None:
                    return default
            else:
                return default
        
        return value
    
    def __getitem__(self, key: str) -> Any:
        """Get configuration value using dict-style access."""
        return self.get(key)


# Load environment variables
load_dotenv()

# Create global config instance
config = Config()
```

---

### Template: Logging Setup

**src/utils/logger.py:**
```python
"""Logging setup and utilities."""

import logging
import sys
from pathlib import Path
from logging.handlers import RotatingFileHandler
from datetime import datetime


class Logger:
    """Configure and manage application logging."""
    
    _instance = None
    
    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self, 
                 name: str = "data_engineering",
                 log_dir: str = "logs",
                 level: int = logging.INFO,
                 max_bytes: int = 10_485_760,  # 10MB
                 backup_count: int = 5):
        
        if hasattr(self, '_initialized'):
            return
            
        self._initialized = True
        self.name = name
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        self._logger = logging.getLogger(name)
        self._logger.setLevel(level)
        self._logger.propagate = False
        
        # Clear any existing handlers
        self._logger.handlers.clear()
        
        # Add console handler
        self._add_console_handler()
        
        # Add file handler
        self._add_file_handler()
    
    def _add_console_handler(self):
        """Add console (stdout) handler."""
        formatter = logging.Formatter(
            fmt='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(formatter)
        self._logger.addHandler(console_handler)
    
    def _add_file_handler(self):
        """Add rotating file handler."""
        log_file = self.log_dir / f"{self.name}.log"
        formatter = logging.Formatter(
            fmt='%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler = RotatingFileHandler(
            log_file,
            maxBytes=self.max_bytes,
            backupCount=self.backup_count
        )
        file_handler.setFormatter(formatter)
        self._logger.addHandler(file_handler)
    
    def get_logger(self):
        """Return the configured logger instance."""
        return self._logger
    
    def debug(self, message: str, *args, **kwargs):
        self._logger.debug(message, *args, **kwargs)
    
    def info(self, message: str, *args, **kwargs):
        self._logger.info(message, *args, **kwargs)
    
    def warning(self, message: str, *args, **kwargs):
        self._logger.warning(message, *args, **kwargs)
    
    def error(self, message: str, *args, **kwargs):
        self._logger.error(message, *args, **kwargs)
    
    def critical(self, message: str, *args, **kwargs):
        self._logger.critical(message, *args, **kwargs)


# Global logger instance
logger = Logger().get_logger()
```

---

### Template: Database Connection

**src/data/database.py:**
```python
"""Database connection and utilities."""

import psycopg2
from psycopg2.extras import execute_values
from contextlib import contextmanager
import pandas as pd
from typing import Optional, Dict, Any
from src.utils.config import config
from src.utils.logger import logger


class DatabaseConnection:
    """Database connection manager with context management."""
    
    def __init__(self, db_config: Optional[Dict[str, Any]] = None):
        self.db_config = db_config or {
            'host': config.get('databases.postgres.host'),
            'port': config.get('databases.postgres.port'),
            'database': config.get('databases.postgres.database'),
            'user': config.get('databases.postgres.user'),
            'password': config.get('databases.postgres.password')
        }
        self._connection = None
    
    @contextmanager
    def get_connection(self):
        """Get a database connection using context manager."""
        conn = None
        try:
            conn = psycopg2.connect(**self.db_config)
            logger.info("Database connection established")
            yield conn
        except Exception as e:
            logger.error(f"Database connection error: {e}")
            raise
        finally:
            if conn:
                conn.close()
                logger.info("Database connection closed")
    
    def execute_query(self, query: str, params: tuple = None) -> pd.DataFrame:
        """Execute a query and return results as DataFrame."""
        with self.get_connection() as conn:
            return pd.read_sql(query, conn, params=params)
    
    def execute_write(self, query: str, params: tuple = None) -> int:
        """Execute a write operation and return rows affected."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(query, params)
                conn.commit()
                return cur.rowcount
    
    def insert_dataframe(self, df: pd.DataFrame, table: str):
        """Insert a DataFrame into a table efficiently."""
        if df.empty:
            logger.warning("Empty DataFrame, nothing to insert")
            return 0
        
        # Convert DataFrame to list of tuples
        columns = df.columns.tolist()
        values = [tuple(row) for row in df.to_numpy()]
        
        # Create insert statement
        placeholders = ', '.join(['%s'] * len(columns))
        columns_str = ', '.join(columns)
        query = f"INSERT INTO {table} ({columns_str}) VALUES %s"
        
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                execute_values(cur, query, values)
                conn.commit()
                return len(values)
    
    def execute_transaction(self, queries: list):
        """Execute multiple queries in a transaction."""
        with self.get_connection() as conn:
            with conn.cursor() as cur:
                try:
                    for query, params in queries:
                        cur.execute(query, params)
                    conn.commit()
                    logger.info("Transaction completed successfully")
                except Exception as e:
                    conn.rollback()
                    logger.error(f"Transaction failed, rolled back: {e}")
                    raise


# Global database instance
db = DatabaseConnection()
```

---

### Template: Data Validation

**src/data/validator.py:**
```python
"""Data validation and quality checks."""

import pandas as pd
import pandera as pa
from pandera.typing import Series
from typing import Dict, Any, Optional
from src.utils.logger import logger


class DataSchema(pa.SchemaModel):
    """Base schema for data validation."""
    
    # Override this in subclasses
    class Config:
        strict = False
        coerce = True
    
    @classmethod
    def validate_dataframe(cls, df: pd.DataFrame, lazy: bool = True) -> pd.DataFrame:
        """Validate a DataFrame against the schema."""
        try:
            validated_df = cls.validate(df, lazy=lazy)
            logger.info(f"Validation passed for {len(df)} rows")
            return validated_df
        except pa.errors.SchemaErrors as e:
            logger.error(f"Validation failed with {len(e.failure_cases)} errors")
            # Log sample failures
            if len(e.failure_cases) > 0:
                sample = e.failure_cases.head(5)
                for _, row in sample.iterrows():
                    logger.error(f"  {row['column']}: {row['failure_cases']}")
            raise


class SalesDataSchema(DataSchema):
    """Schema for sales data."""
    
    transaction_id: Series[str] = pa.Field(nullable=False)
    customer_id: Series[int] = pa.Field(gt=0, nullable=False)
    product_id: Series[int] = pa.Field(gt=0, nullable=False)
    quantity: Series[int] = pa.Field(ge=1, le=100, nullable=False)
    price: Series[float] = pa.Field(ge=0, le=10000, nullable=False)
    total_amount: Series[float] = pa.Field(ge=0, nullable=False)
    transaction_date: Series[pd.Timestamp] = pa.Field(nullable=False)
    
    @pa.dataframe_check
    def validate_total(cls, df: pd.DataFrame) -> Series[bool]:
        """Validate that total_amount = quantity * price."""
        return df['total_amount'] == df['quantity'] * df['price']


class DataQualityChecker:
    """Check data quality metrics."""
    
    def __init__(self, df: pd.DataFrame):
        self.df = df
        self.results = {}
    
    def check_missing_values(self, threshold: float = 0.1) -> Dict[str, Any]:
        """Check for missing values above threshold."""
        missing_rates = self.df.isna().mean()
        high_missing = missing_rates[missing_rates > threshold]
        
        self.results['missing'] = {
            'columns_with_missing': list(missing_rates[missing_rates > 0].index),
            'high_missing_columns': list(high_missing.index),
            'max_missing_rate': missing_rates.max(),
            'summary': f"Found {len(missing_rates[missing_rates > 0])} columns with missing values"
        }
        
        return self.results['missing']
    
    def check_duplicates(self) -> Dict[str, Any]:
        """Check for duplicate rows."""
        duplicates = self.df.duplicated()
        
        self.results['duplicates'] = {
            'duplicate_count': duplicates.sum(),
            'duplicate_rate': duplicates.mean(),
            'summary': f"Found {duplicates.sum()} duplicate rows ({duplicates.mean():.2%})"
        }
        
        return self.results['duplicates']
    
    def check_outliers(self, method: str = 'iqr', threshold: float = 1.5) -> Dict[str, Any]:
        """Check for outliers in numeric columns."""
        numeric_cols = self.df.select_dtypes(include=['float64', 'int64']).columns
        outliers = {}
        
        for col in numeric_cols:
            if method == 'iqr':
                Q1 = self.df[col].quantile(0.25)
                Q3 = self.df[col].quantile(0.75)
                IQR = Q3 - Q1
                lower_bound = Q1 - threshold * IQR
                upper_bound = Q3 + threshold * IQR
                outliers_mask = (self.df[col] < lower_bound) | (self.df[col] > upper_bound)
                outliers[col] = outliers_mask.sum()
        
        self.results['outliers'] = {
            'columns_with_outliers': [col for col, count in outliers.items() if count > 0],
            'outlier_counts': outliers,
            'summary': f"Found outliers in {len([c for c in outliers if outliers[c] > 0])} columns"
        }
        
        return self.results['outliers']
    
    def generate_report(self) -> Dict[str, Any]:
        """Generate a complete quality report."""
        report = {
            'total_rows': len(self.df),
            'total_columns': len(self.df.columns),
            'missing_values': self.check_missing_values(),
            'duplicates': self.check_duplicates(),
            'outliers': self.check_outliers()
        }
        
        return report
```

---

### Template: ETL Pipeline Base

**src/pipeline/etl.py:**
```python
"""Base ETL pipeline implementation."""

from abc import ABC, abstractmethod
from typing import Optional, Dict, Any
import pandas as pd
from pathlib import Path
from datetime import datetime
from src.utils.logger import logger
from src.utils.config import config


class ETLPipeline(ABC):
    """Base class for ETL pipelines."""
    
    def __init__(self, 
                 name: str,
                 source_config: Dict[str, Any],
                 destination_config: Dict[str, Any]):
        self.name = name
        self.source_config = source_config
        self.destination_config = destination_config
        self.start_time = None
        self.end_time = None
        self.extracted_data = None
        self.transformed_data = None
    
    @abstractmethod
    def extract(self) -> pd.DataFrame:
        """Extract data from source."""
        pass
    
    @abstractmethod
    def transform(self, df: pd.DataFrame) -> pd.DataFrame:
        """Transform the extracted data."""
        pass
    
    @abstractmethod
    def load(self, df: pd.DataFrame) -> None:
        """Load the transformed data."""
        pass
    
    def run(self) -> Dict[str, Any]:
        """Execute the complete ETL pipeline."""
        self.start_time = datetime.now()
        logger.info(f"Starting ETL pipeline: {self.name}")
        
        try:
            # Extract
            logger.info("Extracting data...")
            self.extracted_data = self.extract()
            logger.info(f"Extracted {len(self.extracted_data)} rows")
            
            # Transform
            logger.info("Transforming data...")
            self.transformed_data = self.transform(self.extracted_data)
            logger.info(f"Transformed {len(self.transformed_data)} rows")
            
            # Load
            logger.info("Loading data...")
            self.load(self.transformed_data)
            logger.info("Data loaded successfully")
            
            self.end_time = datetime.now()
            duration = (self.end_time - self.start_time).total_seconds()
            
            result = {
                'status': 'success',
                'rows_extracted': len(self.extracted_data),
                'rows_loaded': len(self.transformed_data),
                'duration_seconds': duration,
                'start_time': self.start_time.isoformat(),
                'end_time': self.end_time.isoformat()
            }
            
            logger.info(f"Pipeline completed in {duration:.2f} seconds")
            return result
            
        except Exception as e:
            self.end_time = datetime.now()
            logger.error(f"Pipeline failed: {e}")
            return {
                'status': 'failed',
                'error': str(e),
                'start_time': self.start_time.isoformat(),
                'end_time': self.end_time.isoformat()
            }


class CSVToParquetPipeline(ETLPipeline):
    """Example pipeline: CSV to Parquet."""
    
    def extract(self) -> pd.DataFrame:
        """Extract data from CSV file."""
        file_path = self.source_config.get('file_path')
        if not file_path:
            raise ValueError("File path not specified in source config")
        
        logger.info(f"Reading from {file_path}")
        
        # Use chunks for large files
        if self.source_config.get('chunk_size'):
            chunks = []
            chunk_size = self.source_config['chunk_size']
            for chunk in pd.read_csv(file_path, chunksize=chunk_size):
                chunks.append(chunk)
            return pd.concat(chunks, ignore_index=True)
        else:
            return pd.read_csv(file_path)
    
    def transform(self, df: pd.DataFrame) -> pd.DataFrame:
        """Apply transformations to the data."""
        logger.info("Applying transformations...")
        
        # Example transformations
        if 'date' in df.columns:
            df['date'] = pd.to_datetime(df['date'])
            df['year'] = df['date'].dt.year
            df['month'] = df['date'].dt.month
        
        # Remove duplicates
        df = df.drop_duplicates()
        
        # Handle missing values
        if self.source_config.get('fillna'):
            df = df.fillna(self.source_config['fillna'])
        else:
            df = df.dropna()
        
        return df
    
    def load(self, df: pd.DataFrame) -> None:
        """Load data to Parquet file."""
        output_path = self.destination_config.get('file_path')
        if not output_path:
            raise ValueError("Output path not specified in destination config")
        
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        df.to_parquet(output_path, index=False)
        logger.info(f"Saved {len(df)} rows to {output_path}")
```

---

### Template: Makefile for Automation

**Makefile:**
```makefile
# Project Makefile for common tasks

.PHONY: help install test clean jupyter run-etl

# Default target
help:
	@echo "Available targets:"
	@echo "  install      - Install dependencies"
	@echo "  test         - Run tests"
	@echo "  clean        - Clean cache and temporary files"
	@echo "  jupyter      - Start Jupyter notebook"
	@echo "  run-etl      - Run ETL pipeline"
	@echo "  lint         - Run linting"

# Install dependencies
install:
	pip install -r requirements.txt
	pip install -r requirements-dev.txt 2>/dev/null || true

# Install with development dependencies
install-dev:
	pip install -r requirements.txt -r requirements-dev.txt

# Run tests
test:
	pytest tests/ -v --cov=src --cov-report=html

# Clean temporary files
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.so" -delete
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf *.egg-info/

# Start Jupyter
jupyter:
	jupyter notebook --no-browser

# Run ETL pipeline
run-etl:
	python -m src.pipeline.run_etl --config config/config.yaml

# Run linting
lint:
	black src/ tests/
	flake8 src/ tests/
	mypy src/

# Run all checks
check: lint test

# Create data directories
setup-dirs:
	mkdir -p data/raw data/processed data/external
	mkdir -p logs
	mkdir -p models
	mkdir -p reports
```

---

### Template: Docker Setup

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  # PostgreSQL database
  postgres:
    image: postgres:15
    container_name: data_engineering_postgres
    environment:
      POSTGRES_DB: ${PG_DATABASE:-data_engineering}
      POSTGRES_USER: ${PG_USER:-postgres}
      POSTGRES_PASSWORD: ${PG_PASSWORD:-postgres}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Jupyter Lab
  jupyter:
    image: jupyter/datascience-notebook:latest
    container_name: data_engineering_jupyter
    environment:
      JUPYTER_ENABLE_LAB: "yes"
    ports:
      - "8888:8888"
    volumes:
      - ./:/home/jovyan/work
    depends_on:
      postgres:
        condition: service_healthy
    command: start-notebook.sh --NotebookApp.token=''

  # Airflow (optional)
  airflow:
    image: apache/airflow:2.7.0
    container_name: data_engineering_airflow
    environment:
      AIRFLOW__CORE__EXECUTOR: LocalExecutor
      AIRFLOW__CORE__SQL_ALCHEMY_CONN: postgresql+psycopg2://${PG_USER:-postgres}:${PG_PASSWORD:-postgres}@postgres:5432/${PG_DATABASE:-data_engineering}
    ports:
      - "8080:8080"
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  postgres_data:
```

---

## E.3 .gitignore Template

**.gitignore:**
```
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# Virtual Environment
venv/
env/
.env/
.venv/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Jupyter Notebooks
.ipynb_checkpoints/
*.ipynb_checkpoints

# Data
data/raw/
data/processed/
data/external/
*.csv
*.parquet
*.db
*.sqlite3
*.duckdb

# Logs
logs/
*.log

# Models
models/
*.pkl
*.joblib
*.h5
*.pt
*.onnx

# Reports
reports/
*.html
*.png
*.jpeg
*.pdf

# Environment variables
.env
.env.local
.env.*.local

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/

# Build artifacts
dist/
build/
*.egg-info/
*.egg

# OS artifacts
.DS_Store
Thumbs.db
```

---

**[APPENDIX E COMPLETE]**  
