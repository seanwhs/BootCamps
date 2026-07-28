# Appendix G: Project Templates and Quick Start Guide

## Ready-to-Use Templates for Your Data Analysis Projects

---

#### Purpose of This Appendix

This appendix provides ready-to-use templates and quick-start guides that allow you to begin new data analysis projects immediately. Instead of starting from scratch, you can:

- Copy and adapt proven project structures
- Use pre-configured environment setups
- Leverage boilerplate code for common tasks
- Follow established best practices

Think of these templates as your data analysis starter kit—everything you need to begin a professional project in minutes.

---

## G.1 Project Structure Templates

### G.1.1 Basic Data Analysis Project

```
project_name/
├── README.md
├── requirements.txt
├── .gitignore
├── setup.py
├── src/
│   ├── __init__.py
│   ├── data_loader.py
│   ├── preprocessing.py
│   ├── analysis.py
│   └── visualization.py
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── notebooks/
│   ├── 01_exploratory_analysis.ipynb
│   └── 02_modeling.ipynb
├── outputs/
│   ├── figures/
│   ├── reports/
│   └── models/
├── tests/
│   ├── __init__.py
│   ├── test_data_loader.py
│   └── test_preprocessing.py
└── config/
    └── config.yaml
```

### G.1.2 Dash Dashboard Project

```
dashboard_project/
├── app.py
├── requirements.txt
├── runtime.txt
├── Procfile
├── .env
├── config.py
├── assets/
│   ├── style.css
│   └── logo.png
├── data/
│   └── data.csv
├── src/
│   ├── callbacks.py
│   ├── layout.py
│   └── utils.py
└── tests/
    └── test_app.py
```

### G.1.3 Machine Learning Project

```
ml_project/
├── README.md
├── requirements.txt
├── Makefile
├── data/
│   ├── raw/
│   ├── interim/
│   └── processed/
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_feature_engineering.ipynb
│   └── 03_modeling.ipynb
├── src/
│   ├── __init__.py
│   ├── data/
│   │   ├── __init__.py
│   │   ├── make_dataset.py
│   │   └── preprocess.py
│   ├── features/
│   │   ├── __init__.py
│   │   └── build_features.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── train_model.py
│   │   └── predict.py
│   └── visualization/
│       ├── __init__.py
│       └── visualize.py
├── models/
│   ├── trained_model.pkl
│   └── model_metrics.json
└── config/
    └── config.yaml
```

---

## G.2 Configuration Templates

### G.2.1 requirements.txt (Basic)

```txt
# Core Data Science Libraries
pandas>=2.0.0
numpy>=1.24.0
scipy>=1.10.0

# Visualization
matplotlib>=3.7.0
seaborn>=0.12.0
plotly>=5.14.0
altair>=5.0.0

# Machine Learning
scikit-learn>=1.2.0

# Web Apps
dash>=2.9.0
dash-bootstrap-components>=1.4.0

# Utilities
python-dotenv>=1.0.0
pyyaml>=6.0
jupyter>=1.0.0

# Development Tools
black>=23.0.0
pylint>=2.17.0
pytest>=7.0.0
```

### G.2.2 requirements.txt (Full Stack)

```txt
# Data Manipulation
pandas==2.0.3
numpy==1.24.3
dask==2023.4.1
modin==0.24.1

# Statistical Analysis
scipy==1.10.1
statsmodels==0.14.0
pingouin==0.5.3

# Visualization
matplotlib==3.7.2
seaborn==0.12.2
plotly==5.14.1
altair==5.0.1
vega_datasets==0.9.0

# Web Frameworks
dash==2.10.2
dash-bootstrap-components==1.4.2
dash-core-components==2.0.0
dash-html-components==2.0.0
flask==2.3.3

# Machine Learning
scikit-learn==1.3.0
xgboost==1.7.6
lightgbm==3.3.5
catboost==1.1.1

# Deep Learning (Optional)
tensorflow==2.13.0
torch==2.0.1

# Data Storage
sqlalchemy==2.0.19
duckdb==0.8.1
sqlite3

# Utilities
python-dotenv==1.0.0
pyyaml==6.0.1
joblib==1.3.1
tqdm==4.65.0
loguru==0.7.2

# Development
black==23.7.0
pylint==2.17.5
pytest==7.4.0
jupyter==1.0.0
ipython==8.14.0

# Deployment
gunicorn==20.1.0
whitenoise==6.4.0
```

### G.2.3 .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/

# Jupyter
.ipynb_checkpoints/
*.ipynb
.pytest_cache/
.coverage
htmlcov/

# Data
data/raw/
data/processed/
!data/raw/.gitkeep
!data/processed/.gitkeep
*.csv
*.h5
*.parquet

# Outputs
outputs/
logs/
*.log
*.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Environment
.env
.env.local

# OS
.DS_Store
Thumbs.db

# Large files
*.pkl
*.joblib
*.model
*.h5
*.pb
*.onnx
```

### G.2.4 config.yaml

```yaml
# Project Configuration
project:
  name: "Customer Analytics"
  version: "1.0.0"
  environment: "development"  # development, staging, production

# Data Paths
data:
  raw: "data/raw/customer_data.csv"
  processed: "data/processed/customer_data_processed.csv"
  external: "data/external/"
  output: "outputs/"

# Data Processing
processing:
  test_size: 0.2
  random_state: 42
  imputation_strategy: "median"  # mean, median, mode
  outlier_method: "iqr"  # iqr, zscore, none
  
# Visualization
visualization:
  style: "seaborn-v0_8-darkgrid"
  dpi: 300
  figsize: [12, 8]
  save_figures: true
  figure_format: "png"

# Model Training
model:
  target: "customer_rating"
  features:
    - "age"
    - "gender"
    - "income_bracket"
    - "order_frequency"
    - "avg_order_value"
  algorithms:
    - "random_forest"
    - "xgboost"
    - "linear_regression"
  cv_folds: 5
  scoring: "r2"

# Logging
logging:
  level: "INFO"  # DEBUG, INFO, WARNING, ERROR
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  file: "logs/app.log"
```

### G.2.5 Dockerfile

```dockerfile
# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd -m -u 1000 appuser
USER appuser

# Expose port
EXPOSE 8050

# Run application
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8050", "app:server"]
```

---

## G.3 Code Templates

### G.3.1 Data Loader Template

**File:** `src/data_loader.py`

```python
"""
Data Loading Module

Handles loading data from various sources with validation
and error handling.
"""

import pandas as pd
import numpy as np
from pathlib import Path
from typing import Optional, Union, List
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DataLoader:
    """
    A class for loading data from various sources.
    """
    
    def __init__(self, config: Optional[dict] = None):
        """
        Initialize the data loader.
        
        Parameters:
        -----------
        config : dict, optional
            Configuration dictionary
        """
        self.config = config or {}
        self.data = None
        
    def load_csv(self, filepath: Union[str, Path], 
                 **kwargs) -> pd.DataFrame:
        """
        Load data from CSV file.
        
        Parameters:
        -----------
        filepath : str or Path
            Path to CSV file
        **kwargs : dict
            Additional pandas read_csv parameters
            
        Returns:
        --------
        pd.DataFrame
            Loaded data
        """
        try:
            filepath = Path(filepath)
            
            if not filepath.exists():
                raise FileNotFoundError(f"File not found: {filepath}")
            
            logger.info(f"Loading data from {filepath}")
            
            # Set default parameters
            default_params = {
                'encoding': 'utf-8',
                'low_memory': False
            }
            default_params.update(kwargs)
            
            self.data = pd.read_csv(filepath, **default_params)
            
            logger.info(f"Loaded {len(self.data):,} rows, "
                       f"{len(self.data.columns)} columns")
            
            return self.data
            
        except Exception as e:
            logger.error(f"Error loading data: {str(e)}")
            raise
            
    def load_excel(self, filepath: Union[str, Path],
                   sheet_name: str = 0, **kwargs) -> pd.DataFrame:
        """
        Load data from Excel file.
        """
        try:
            filepath = Path(filepath)
            
            if not filepath.exists():
                raise FileNotFoundError(f"File not found: {filepath}")
            
            logger.info(f"Loading data from {filepath} (sheet: {sheet_name})")
            
            self.data = pd.read_excel(filepath, sheet_name=sheet_name, **kwargs)
            
            logger.info(f"Loaded {len(self.data):,} rows, "
                       f"{len(self.data.columns)} columns")
            
            return self.data
            
        except Exception as e:
            logger.error(f"Error loading Excel file: {str(e)}")
            raise
            
    def load_parquet(self, filepath: Union[str, Path], **kwargs) -> pd.DataFrame:
        """Load data from Parquet file."""
        try:
            filepath = Path(filepath)
            
            if not filepath.exists():
                raise FileNotFoundError(f"File not found: {filepath}")
            
            logger.info(f"Loading data from {filepath}")
            
            self.data = pd.read_parquet(filepath, **kwargs)
            
            logger.info(f"Loaded {len(self.data):,} rows, "
                       f"{len(self.data.columns)} columns")
            
            return self.data
            
        except Exception as e:
            logger.error(f"Error loading Parquet file: {str(e)}")
            raise
            
    def load_database(self, query: str, connection_string: str) -> pd.DataFrame:
        """Load data from SQL database."""
        try:
            import sqlalchemy
            
            logger.info("Connecting to database...")
            
            engine = sqlalchemy.create_engine(connection_string)
            
            with engine.connect() as conn:
                self.data = pd.read_sql_query(query, conn)
            
            logger.info(f"Loaded {len(self.data):,} rows, "
                       f"{len(self.data.columns)} columns")
            
            return self.data
            
        except Exception as e:
            logger.error(f"Error loading from database: {str(e)}")
            raise
            
    def save_data(self, data: pd.DataFrame, filepath: Union[str, Path],
                  format: str = 'csv', **kwargs) -> None:
        """
        Save data to file.
        
        Parameters:
        -----------
        data : pd.DataFrame
            Data to save
        filepath : str or Path
            Output file path
        format : str
            Output format ('csv', 'parquet', 'excel')
        **kwargs : dict
            Additional format-specific parameters
        """
        try:
            filepath = Path(filepath)
            filepath.parent.mkdir(parents=True, exist_ok=True)
            
            if format == 'csv':
                data.to_csv(filepath, index=False, **kwargs)
            elif format == 'parquet':
                data.to_parquet(filepath, index=False, **kwargs)
            elif format == 'excel':
                data.to_excel(filepath, index=False, **kwargs)
            else:
                raise ValueError(f"Unsupported format: {format}")
            
            logger.info(f"Saved data to {filepath}")
            
        except Exception as e:
            logger.error(f"Error saving data: {str(e)}")
            raise

# Usage example
if __name__ == "__main__":
    loader = DataLoader()
    
    # Load CSV
    df = loader.load_csv('data/raw/customer_data.csv')
    
    # Show info
    print(df.info())
```

### G.3.2 Preprocessing Template

**File:** `src/preprocessing.py`

```python
"""
Data Preprocessing Module

Handles cleaning, transformation, and feature engineering.
"""

import pandas as pd
import numpy as np
from typing import Optional, List, Union
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.model_selection import train_test_split
import logging

logger = logging.getLogger(__name__)

class DataPreprocessor:
    """
    A class for preprocessing data.
    """
    
    def __init__(self, config: Optional[dict] = None):
        """
        Initialize the preprocessor.
        
        Parameters:
        -----------
        config : dict, optional
            Configuration dictionary
        """
        self.config = config or {}
        self.scalers = {}
        self.encoders = {}
        
    def handle_missing_values(self, df: pd.DataFrame, 
                             strategy: str = 'median') -> pd.DataFrame:
        """
        Handle missing values in DataFrame.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        strategy : str
            Imputation strategy ('mean', 'median', 'mode', 'drop')
            
        Returns:
        --------
        pd.DataFrame
            Data with missing values handled
        """
        df_clean = df.copy()
        
        if strategy == 'drop':
            df_clean = df_clean.dropna()
            logger.info(f"Dropped {len(df) - len(df_clean)} rows with missing values")
            return df_clean
        
        for col in df_clean.columns:
            if df_clean[col].isnull().sum() > 0:
                if df_clean[col].dtype in ['float64', 'int64']:
                    if strategy == 'mean':
                        value = df_clean[col].mean()
                    elif strategy == 'median':
                        value = df_clean[col].median()
                    else:
                        value = 0
                else:
                    value = df_clean[col].mode()[0]
                
                df_clean[col] = df_clean[col].fillna(value)
                logger.info(f"Imputed {col} with {value}")
        
        return df_clean
    
    def handle_outliers(self, df: pd.DataFrame, method: str = 'iqr',
                       threshold: float = 1.5) -> pd.DataFrame:
        """
        Handle outliers in numerical columns.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        method : str
            Method for outlier detection ('iqr', 'zscore')
        threshold : float
            Threshold for outlier detection
            
        Returns:
        --------
        pd.DataFrame
            Data with outliers handled
        """
        df_clean = df.copy()
        
        for col in df_clean.select_dtypes(include=['float64', 'int64']).columns:
            data = df_clean[col].dropna()
            
            if method == 'iqr':
                q1 = data.quantile(0.25)
                q3 = data.quantile(0.75)
                iqr = q3 - q1
                lower = q1 - threshold * iqr
                upper = q3 + threshold * iqr
                
                # Cap outliers
                df_clean[col] = df_clean[col].clip(lower=lower, upper=upper)
                
            elif method == 'zscore':
                mean = data.mean()
                std = data.std()
                if std > 0:
                    lower = mean - threshold * std
                    upper = mean + threshold * std
                    df_clean[col] = df_clean[col].clip(lower=lower, upper=upper)
            
            logger.info(f"Capped outliers in {col}")
        
        return df_clean
    
    def scale_features(self, df: pd.DataFrame, 
                       method: str = 'standard',
                       columns: Optional[List[str]] = None) -> pd.DataFrame:
        """
        Scale numerical features.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        method : str
            Scaling method ('standard', 'minmax', 'robust')
        columns : list, optional
            Columns to scale (all numerical if None)
            
        Returns:
        --------
        pd.DataFrame
            Scaled data
        """
        df_scaled = df.copy()
        
        if columns is None:
            columns = df_scaled.select_dtypes(include=['float64', 'int64']).columns.tolist()
        
        if method == 'standard':
            scaler = StandardScaler()
        elif method == 'minmax':
            scaler = MinMaxScaler()
        elif method == 'robust':
            from sklearn.preprocessing import RobustScaler
            scaler = RobustScaler()
        else:
            raise ValueError(f"Unknown scaling method: {method}")
        
        df_scaled[columns] = scaler.fit_transform(df_scaled[columns])
        self.scalers[method] = scaler
        
        logger.info(f"Scaled {len(columns)} columns using {method}")
        
        return df_scaled
    
    def encode_categorical(self, df: pd.DataFrame,
                          method: str = 'onehot',
                          columns: Optional[List[str]] = None) -> pd.DataFrame:
        """
        Encode categorical variables.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        method : str
            Encoding method ('onehot', 'label', 'frequency')
        columns : list, optional
            Columns to encode
            
        Returns:
        --------
        pd.DataFrame
            Encoded data
        """
        df_encoded = df.copy()
        
        if columns is None:
            columns = df_encoded.select_dtypes(include=['object']).columns.tolist()
        
        for col in columns:
            if method == 'onehot':
                dummies = pd.get_dummies(df_encoded[col], prefix=col, drop_first=True)
                df_encoded = pd.concat([df_encoded, dummies], axis=1)
                df_encoded = df_encoded.drop(columns=[col])
                
            elif method == 'label':
                from sklearn.preprocessing import LabelEncoder
                le = LabelEncoder()
                df_encoded[col + '_encoded'] = le.fit_transform(df_encoded[col].astype(str))
                self.encoders[col] = le
                
            elif method == 'frequency':
                freq_map = df_encoded[col].value_counts(normalize=True).to_dict()
                df_encoded[col + '_freq'] = df_encoded[col].map(freq_map)
            
            logger.info(f"Encoded {col} using {method}")
        
        return df_encoded
    
    def create_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Create new features from existing columns.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
            
        Returns:
        --------
        pd.DataFrame
            Data with new features
        """
        df_fe = df.copy()
        
        # Example: Create age groups
        if 'age' in df_fe.columns:
            df_fe['age_group'] = pd.cut(df_fe['age'],
                                       bins=[0, 25, 35, 45, 55, 100],
                                       labels=['Under 25', '25-35', '35-45', 
                                              '45-55', '55+'])
        
        # Example: Create engagement levels
        if 'time_on_site' in df_fe.columns:
            df_fe['engagement_level'] = pd.cut(df_fe['time_on_site'],
                                              bins=[0, 5, 15, 100],
                                              labels=['Low', 'Medium', 'High'])
        
        # Example: Create ratios
        if 'time_on_site' in df_fe.columns and 'pages_viewed' in df_fe.columns:
            df_fe['time_per_page'] = df_fe['time_on_site'] / (df_fe['pages_viewed'] + 1)
        
        # Example: Create interaction features
        if 'income_bracket' in df_fe.columns:
            income_map = {'<$25K': 0, '$25K-$50K': 1, '$50K-$75K': 2,
                         '$75K-$100K': 3, '>$100K': 4}
            df_fe['income_numeric'] = df_fe['income_bracket'].map(income_map)
        
        logger.info(f"Created {len(df_fe.columns) - len(df.columns)} new features")
        
        return df_fe
    
    def split_data(self, df: pd.DataFrame, target_col: str,
                  test_size: float = 0.2, random_state: int = 42) -> dict:
        """
        Split data into train and test sets.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        target_col : str
            Target column name
        test_size : float
            Proportion of test data
        random_state : int
            Random seed
            
        Returns:
        --------
        dict
            Dictionary with train/test splits
        """
        X = df.drop(columns=[target_col])
        y = df[target_col]
        
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=random_state
        )
        
        logger.info(f"Split data: {len(X_train)} train, {len(X_test)} test")
        
        return {
            'X_train': X_train,
            'X_test': X_test,
            'y_train': y_train,
            'y_test': y_test
        }
    
    def run_pipeline(self, df: pd.DataFrame, config: dict = None) -> pd.DataFrame:
        """
        Run complete preprocessing pipeline.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        config : dict
            Pipeline configuration
            
        Returns:
        --------
        pd.DataFrame
            Processed data
        """
        if config is None:
            config = self.config.get('pipeline', {})
        
        logger.info("Starting preprocessing pipeline...")
        
        # Handle missing values
        if config.get('handle_missing', True):
            df = self.handle_missing_values(df, 
                strategy=config.get('missing_strategy', 'median'))
        
        # Handle outliers
        if config.get('handle_outliers', True):
            df = self.handle_outliers(df,
                method=config.get('outlier_method', 'iqr'))
        
        # Create features
        if config.get('create_features', True):
            df = self.create_features(df)
        
        # Encode categorical
        if config.get('encode_categorical', True):
            df = self.encode_categorical(df,
                method=config.get('encoding_method', 'onehot'))
        
        # Scale features
        if config.get('scale_features', False):
            df = self.scale_features(df,
                method=config.get('scaling_method', 'standard'))
        
        logger.info("Preprocessing pipeline complete")
        
        return df

# Usage example
if __name__ == "__main__":
    preprocessor = DataPreprocessor()
    
    # Load data
    df = pd.read_csv('data/raw/customer_data.csv')
    
    # Preprocess
    df_processed = preprocessor.run_pipeline(df)
    
    # Save processed data
    df_processed.to_csv('data/processed/customer_data_processed.csv', index=False)
```

### G.3.3 Visualization Template

**File:** `src/visualization.py`

```python
"""
Visualization Module

Handles creation of plots and figures for data analysis.
"""

import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import numpy as np
from pathlib import Path
from typing import Optional, List, Union
import logging

logger = logging.getLogger(__name__)

class Visualizer:
    """
    A class for creating visualizations.
    """
    
    def __init__(self, output_dir: str = "outputs/figures",
                 style: str = "seaborn-v0_8-darkgrid"):
        """
        Initialize the visualizer.
        
        Parameters:
        -----------
        output_dir : str
            Directory for saving figures
        style : str
            Matplotlib style
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        plt.style.use(style)
        sns.set_palette("husl")
        
    def create_distribution(self, data: pd.Series, 
                           title: str = None,
                           save: bool = True) -> plt.Figure:
        """
        Create distribution plot.
        
        Parameters:
        -----------
        data : pd.Series
            Data to visualize
        title : str
            Plot title
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            Matplotlib figure
        """
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8),
                                      gridspec_kw={'height_ratios': [2, 1]})
        
        # Histogram with KDE
        sns.histplot(data, kde=True, ax=ax1, color='steelblue')
        ax1.axvline(data.mean(), color='red', linestyle='--', 
                   label=f'Mean: {data.mean():.2f}')
        ax1.axvline(data.median(), color='green', linestyle='-.', 
                   label=f'Median: {data.median():.2f}')
        ax1.set_title(title or f'Distribution of {data.name}')
        ax1.legend()
        
        # Boxplot
        sns.boxplot(y=data, ax=ax2, color='steelblue')
        ax2.set_ylabel(data.name)
        
        plt.tight_layout()
        
        if save:
            filename = f"distribution_{data.name}.png"
            plt.savefig(self.output_dir / filename, dpi=300, bbox_inches='tight')
            logger.info(f"Saved: {filename}")
        
        return fig
    
    def create_correlation_heatmap(self, df: pd.DataFrame,
                                  cols: Optional[List[str]] = None,
                                  save: bool = True) -> plt.Figure:
        """
        Create correlation heatmap.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        cols : list, optional
            Columns to include
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            Matplotlib figure
        """
        if cols is None:
            cols = df.select_dtypes(include=['float64', 'int64']).columns.tolist()
        
        corr_matrix = df[cols].corr()
        
        fig, ax = plt.subplots(figsize=(12, 10))
        
        mask = np.triu(np.ones_like(corr_matrix, dtype=bool))
        sns.heatmap(corr_matrix, mask=mask, annot=True, fmt='.2f',
                   cmap='RdBu_r', center=0, square=True,
                   linewidths=0.5, ax=ax)
        
        plt.title('Correlation Heatmap', fontsize=16, fontweight='bold')
        plt.tight_layout()
        
        if save:
            filename = "correlation_heatmap.png"
            plt.savefig(self.output_dir / filename, dpi=300, bbox_inches='tight')
            logger.info(f"Saved: {filename}")
        
        return fig
    
    def create_pairplot(self, df: pd.DataFrame,
                       cols: Optional[List[str]] = None,
                       hue: Optional[str] = None,
                       save: bool = True) -> sns.PairGrid:
        """
        Create pairplot.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        cols : list, optional
            Columns to include
        hue : str, optional
            Column for coloring
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        sns.PairGrid
            Seaborn PairGrid object
        """
        if cols is None:
            cols = df.select_dtypes(include=['float64', 'int64']).columns[:5].tolist()
        
        g = sns.pairplot(df[cols], hue=hue, diag_kind='kde')
        
        if save:
            filename = "pairplot.png"
            plt.savefig(self.output_dir / filename, dpi=300, bbox_inches='tight')
            logger.info(f"Saved: {filename}")
        
        return g
    
    def create_plotly_scatter(self, df: pd.DataFrame,
                             x_col: str, y_col: str,
                             color_col: Optional[str] = None,
                             title: str = None,
                             save: bool = True) -> go.Figure:
        """
        Create interactive scatter plot using Plotly.
        
        Parameters:
        -----------
        df : pd.DataFrame
            Input data
        x_col : str
            X-axis column
        y_col : str
            Y-axis column
        color_col : str, optional
            Column for coloring
        title : str
            Plot title
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        go.Figure
            Plotly figure
        """
        fig = px.scatter(df, x=x_col, y=y_col, color=color_col,
                        title=title or f'{y_col} vs {x_col}')
        
        fig.update_layout(
            xaxis_title=x_col,
            yaxis_title=y_col,
            hovermode='closest',
            template='plotly_white'
        )
        
        if save:
            filename = f"scatter_{x_col}_vs_{y_col}.html"
            fig.write_html(self.output_dir / filename)
            logger.info(f"Saved: {filename}")
        
        return fig
    
    def create_dashboard(self, df: pd.DataFrame,
                        x_col: str, y_col: str,
                        color_col: Optional[str] = None,
                        title: str = "Interactive Dashboard") -> None:
        """
        Create interactive dashboard using Dash.
        
        This is a minimal example - use the full dash_dashboard.py
        for production dashboards.
        """
        import dash
        from dash import dcc, html
        
        app = dash.Dash(__name__)
        
        app.layout = html.Div([
            html.H1(title, style={'textAlign': 'center'}),
            html.P("Hover, zoom, and explore the data!",
                  style={'textAlign': 'center'}),
            dcc.Graph(
                id='main-chart',
                figure=self.create_plotly_scatter(df, x_col, y_col,
                                                  color_col, save=False)
            )
        ])
        
        app.run_server(debug=True, host='127.0.0.1', port=8050)

# Usage example
if __name__ == "__main__":
    # Load data
    df = pd.read_csv('data/raw/customer_data.csv')
    
    # Initialize visualizer
    viz = Visualizer()
    
    # Create visualizations
    viz.create_distribution(df['age'])
    viz.create_correlation_heatmap(df)
    
    # Interactive chart
    viz.create_plotly_scatter(df, 'age', 'order_frequency', 'income_bracket')
    
    # Run dashboard
    viz.create_dashboard(df, 'age', 'order_frequency', 'income_bracket')
```

---

## G.4 Quick Start Commands

### G.4.1 Project Initialization

```bash
# Create project structure
mkdir my_data_project
cd my_data_project

# Initialize git
git init

# Create virtual environment
python -m venv venv

# Activate environment
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Create directories
mkdir src data notebooks outputs tests config

# Create empty __init__.py files
touch src/__init__.py tests/__init__.py

# Create .gitignore
touch .gitignore

# Create requirements.txt
touch requirements.txt

# Create README
touch README.md
```

### G.4.2 Installation Commands

```bash
# Install from requirements
pip install -r requirements.txt

# Update requirements
pip freeze > requirements.txt

# Install with specific Python version
python3.9 -m venv venv
python3.9 -m pip install -r requirements.txt

# Development mode install
pip install -e .
```

### G.4.3 Running Commands

```bash
# Run Jupyter
jupyter notebook
jupyter lab

# Run Dash app
python app.py

# Run tests
pytest tests/
pytest --cov=src tests/

# Run linting
pylint src/
black src/

# Run profiling
python -m cProfile -o profile.stats script.py
```

---

## G.5 Deployment Commands

### G.5.1 Heroku

```bash
# Login
heroku login

# Create app
heroku create my-app-name

# Add buildpack
heroku buildpacks:add heroku/python

# Deploy
git push heroku main

# Open app
heroku open

# Check logs
heroku logs --tail
```

### G.5.2 Docker

```bash
# Build image
docker build -t my-app .

# Run container
docker run -d -p 8050:8050 --name my-app my-app

# View logs
docker logs my-app

# Stop container
docker stop my-app

# Remove container
docker rm my-app

# Deploy to Docker Hub
docker tag my-app username/my-app:latest
docker push username/my-app:latest
```

---

## G.6 Quick Reference: Common Data Operations

### G.6.1 Pandas Operations

```python
# Read data
df = pd.read_csv('file.csv')
df = pd.read_excel('file.xlsx')
df = pd.read_parquet('file.parquet')

# Inspect data
df.head()
df.info()
df.describe()
df.shape
df.dtypes

# Select columns
df['col']
df[['col1', 'col2']]
df.loc[df['col'] > value]

# Group and aggregate
df.groupby('col').mean()
df.groupby('col').agg(['mean', 'sum', 'count'])

# Handle missing
df.dropna()
df.fillna(value)
df.fillna(method='ffill')

# Merge data
pd.merge(df1, df2, on='key')
pd.concat([df1, df2])

# Pivot
df.pivot_table(index='col1', columns='col2', values='col3')
```

### G.6.2 Plotting Commands

```python
# Matplotlib
plt.plot(x, y)
plt.scatter(x, y)
plt.hist(data)
plt.bar(x, y)
plt.boxplot(data)
plt.savefig('plot.png', dpi=300)

# Seaborn
sns.histplot(data, kde=True)
sns.boxplot(x='cat', y='num', data=df)
sns.violinplot(x='cat', y='num', data=df)
sns.pairplot(df)
sns.heatmap(corr_matrix)

# Plotly
px.scatter(df, x='col1', y='col2')
px.bar(df, x='cat', y='num')
px.histogram(df, x='col')
px.line(df, x='date', y='value')

# Altair
alt.Chart(df).mark_point().encode(x='col1:Q', y='col2:Q')
```

---

## G.7 Quick Reference: Data Science Lifecycle

```
1. Define Problem
   ├── What are you trying to solve?
   ├── What are the success criteria?
   └── What resources are available?

2. Data Collection
   ├── Internal data sources
   ├── External data sources
   └── Data quality assessment

3. Data Cleaning
   ├── Handle missing values
   ├── Handle outliers
   ├── Fix data types
   └── Remove duplicates

4. Exploratory Analysis
   ├── Univariate analysis
   ├── Bivariate analysis
   ├── Visualization
   └── Hypothesis generation

5. Feature Engineering
   ├── Create new features
   ├── Transform features
   ├── Select features
   └── Encode categorical

6. Modeling
   ├── Select algorithms
   ├── Train models
   ├── Tune hyperparameters
   └── Evaluate performance

7. Interpretation
   ├── Understand predictions
   ├── Feature importance
   ├── Model explanations
   └── Business insights

8. Deployment
   ├── Model serving
   ├── API development
   ├── Dashboard creation
   └── Monitoring

9. Iteration
   ├── Gather feedback
   ├── Update model
   ├── Improve features
   └── Retrain on new data
```

This appendix provides everything you need to start new data analysis projects quickly and professionally. Use these templates, configurations, and commands as your foundation, then customize them for your specific needs.

**Remember:** The best projects start with good structure. Taking time to set up your project properly at the beginning saves countless hours later.
