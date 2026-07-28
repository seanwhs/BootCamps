# Phase 1: Foundation Building

## Part 2: Data Validation and Quality

Welcome back! In Part 1, we established the foundation of our project—the directory structure, dependency management, and basic data ingestion capabilities. Now we're going to build something even more critical: a robust data validation and quality assurance system.

### The Target: A Comprehensive Data Quality System

By the end of this part, you'll have:
1. Advanced schema validation with Pydantic models
2. Strategic missing value handling (not just dropping or filling blindly)
3. Comprehensive outlier detection with multiple methods
4. Data quality reporting with visualizations
5. Automated data quality checks that run before any model training
6. Integration with our existing DataIngestor and DataValidator

### The Concept: Why Data Quality Matters More Than Model Quality

Here's a truth that separates professionals from beginners: **data quality matters more than model quality.** 

Let me illustrate with an analogy:

Imagine you're building a house. You have three options:
- **Option A**: Premium materials (high-quality lumber, steel, concrete) with a mediocre architect
- **Option B**: Mediocre materials with a world-class architect
- **Option C**: Premium materials with a world-class architect

Which house would you trust? Option C, obviously. But here's the insight: Option A (great materials, average architect) will usually build a better house than Option B (mediocre materials, great architect). 

The same applies to machine learning:
- **Great data + average model** typically beats **average data + great model**
- Garbage data with the best algorithm still produces garbage predictions
- High-quality data with a simple model often outperforms complex models on bad data

This is why we're spending so much time on data quality before we even touch a model.

### The Implementation: Building Our Data Quality System

#### Step 1: Enhanced Schema Validation

Let's create a more sophisticated schema validation system. We'll use Pydantic's powerful validation capabilities.

**File:** `src/data/schemas.py`
**Path:** `ml-pipeline-project/src/data/schemas.py`

```python
"""
Advanced schema definitions for data validation using Pydantic.
"""

from typing import Dict, List, Optional, Union, Any, Callable
from datetime import datetime
from enum import Enum
import pandas as pd
import numpy as np
from pydantic import BaseModel, Field, validator, root_validator, ValidationError
from loguru import logger

class ColumnType(str, Enum):
    """Enumeration of supported column types."""
    INTEGER = "int"
    FLOAT = "float"
    STRING = "object"
    CATEGORICAL = "category"
    DATETIME = "datetime"
    BOOLEAN = "bool"
    TEXT = "text"  # Long text fields
    JSON = "json"  # JSON/structured data

class ColumnConstraint(BaseModel):
    """
    Constraints that can be applied to a column.
    
    This allows us to define what values are valid for each column,
    going beyond just type checking.
    """
    min_value: Optional[float] = None
    max_value: Optional[float] = None
    allowed_values: Optional[List[Any]] = None
    regex_pattern: Optional[str] = None  # For string validation
    min_length: Optional[int] = None  # For string/array length
    max_length: Optional[int] = None
    unique: bool = False
    not_null: bool = True
    missing_threshold: Optional[float] = None  # Max allowed % of missing values
    
    # Custom validator function (as string, will be evaluated)
    custom_validator: Optional[str] = None
    
    class Config:
        use_enum_values = True

class ColumnSchema(BaseModel):
    """
    Schema definition for a single column.
    
    Combines type information with constraints and metadata.
    """
    name: str
    type: ColumnType
    description: Optional[str] = None
    constraints: ColumnConstraint = Field(default_factory=ColumnConstraint)
    
    # Metadata for feature engineering
    is_target: bool = False
    is_identifier: bool = False
    is_timestamp: bool = False
    feature_group: Optional[str] = None  # For grouping features
    importance: float = 1.0  # Relative importance for modeling
    
    @validator('name')
    def validate_name(cls, v):
        """Ensure column name is valid."""
        if not v or not isinstance(v, str):
            raise ValueError("Column name must be a non-empty string")
        return v.strip()

class DataSchema(BaseModel):
    """
    Complete schema definition for a dataset.
    
    Contains multiple ColumnSchema objects and dataset-level constraints.
    """
    name: str
    version: str = "1.0.0"
    description: Optional[str] = None
    columns: List[ColumnSchema]
    created_at: datetime = Field(default_factory=datetime.now)
    
    # Dataset-level constraints
    min_rows: Optional[int] = None
    max_rows: Optional[int] = None
    require_all_columns: bool = True
    
    @root_validator
    def validate_column_names_unique(cls, values):
        """Ensure all column names are unique."""
        columns = values.get('columns', [])
        names = [col.name for col in columns]
        if len(names) != len(set(names)):
            duplicates = [name for name in set(names) if names.count(name) > 1]
            raise ValueError(f"Duplicate column names found: {duplicates}")
        return values
    
    def get_column_by_name(self, name: str) -> Optional[ColumnSchema]:
        """Get a column schema by name."""
        for col in self.columns:
            if col.name == name:
                return col
        return None
    
    def get_target_column(self) -> Optional[ColumnSchema]:
        """Get the target column (if any)."""
        for col in self.columns:
            if col.is_target:
                return col
        return None
    
    def get_identifier_columns(self) -> List[ColumnSchema]:
        """Get all identifier columns."""
        return [col for col in self.columns if col.is_identifier]
    
    def get_feature_columns(self) -> List[ColumnSchema]:
        """Get all feature columns (exclude target and identifiers)."""
        return [
            col for col in self.columns 
            if not col.is_target and not col.is_identifier
        ]
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert schema to dictionary for serialization."""
        return {
            "name": self.name,
            "version": self.version,
            "description": self.description,
            "columns": [
                {
                    "name": col.name,
                    "type": col.type.value,
                    "description": col.description,
                    "constraints": col.constraints.dict(),
                    "is_target": col.is_target,
                    "is_identifier": col.is_identifier,
                    "is_timestamp": col.is_timestamp,
                    "feature_group": col.feature_group,
                }
                for col in self.columns
            ],
            "created_at": self.created_at.isoformat(),
        }

# Pre-defined schemas for common datasets

class IrisSchema(DataSchema):
    """Schema for the Iris dataset."""
    
    def __init__(self, **kwargs):
        super().__init__(
            name="iris",
            version="1.0.0",
            description="Fisher's Iris dataset",
            columns=[
                ColumnSchema(
                    name="sepal_length",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(
                        min_value=0.0,
                        max_value=20.0,
                        not_null=True
                    ),
                    feature_group="measurements"
                ),
                ColumnSchema(
                    name="sepal_width",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(
                        min_value=0.0,
                        max_value=20.0,
                        not_null=True
                    ),
                    feature_group="measurements"
                ),
                ColumnSchema(
                    name="petal_length",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(
                        min_value=0.0,
                        max_value=20.0,
                        not_null=True
                    ),
                    feature_group="measurements"
                ),
                ColumnSchema(
                    name="petal_width",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(
                        min_value=0.0,
                        max_value=20.0,
                        not_null=True
                    ),
                    feature_group="measurements"
                ),
                ColumnSchema(
                    name="species",
                    type=ColumnType.CATEGORICAL,
                    constraints=ColumnConstraint(
                        allowed_values=["setosa", "versicolor", "virginica"],
                        not_null=True
                    ),
                    is_target=True,
                    feature_group="target"
                ),
            ],
            **kwargs
        )

class TitanicSchema(DataSchema):
    """Schema for the Titanic dataset."""
    
    def __init__(self, **kwargs):
        super().__init__(
            name="titanic",
            version="1.0.0",
            description="Titanic passenger survival dataset",
            columns=[
                ColumnSchema(
                    name="passenger_id",
                    type=ColumnType.INTEGER,
                    constraints=ColumnConstraint(unique=True, not_null=True),
                    is_identifier=True
                ),
                ColumnSchema(
                    name="survived",
                    type=ColumnType.INTEGER,
                    constraints=ColumnConstraint(
                        allowed_values=[0, 1],
                        not_null=True
                    ),
                    is_target=True
                ),
                ColumnSchema(
                    name="pclass",
                    type=ColumnType.INTEGER,
                    constraints=ColumnConstraint(
                        allowed_values=[1, 2, 3],
                        not_null=True
                    ),
                    feature_group="demographic"
                ),
                ColumnSchema(
                    name="name",
                    type=ColumnType.STRING,
                    constraints=ColumnConstraint(not_null=True),
                    feature_group="identity"
                ),
                ColumnSchema(
                    name="sex",
                    type=ColumnType.CATEGORICAL,
                    constraints=ColumnConstraint(
                        allowed_values=["male", "female"],
                        not_null=True
                    ),
                    feature_group="demographic"
                ),
                ColumnSchema(
                    name="age",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(
                        min_value=0.0,
                        max_value=120.0,
                        missing_threshold=0.3  # Allow up to 30% missing
                    ),
                    feature_group="demographic"
                ),
                ColumnSchema(
                    name="sibsp",
                    type=ColumnType.INTEGER,
                    constraints=ColumnConstraint(
                        min_value=0,
                        not_null=True
                    ),
                    feature_group="family"
                ),
                ColumnSchema(
                    name="parch",
                    type=ColumnType.INTEGER,
                    constraints=ColumnConstraint(
                        min_value=0,
                        not_null=True
                    ),
                    feature_group="family"
                ),
                ColumnSchema(
                    name="ticket",
                    type=ColumnType.STRING,
                    constraints=ColumnConstraint(not_null=True),
                    feature_group="identity"
                ),
                ColumnSchema(
                    name="fare",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(
                        min_value=0.0,
                        not_null=True
                    ),
                    feature_group="financial"
                ),
                ColumnSchema(
                    name="cabin",
                    type=ColumnType.STRING,
                    constraints=ColumnConstraint(
                        missing_threshold=0.7  # Allow up to 70% missing
                    ),
                    feature_group="location"
                ),
                ColumnSchema(
                    name="embarked",
                    type=ColumnType.CATEGORICAL,
                    constraints=ColumnConstraint(
                        allowed_values=["C", "Q", "S"],
                        missing_threshold=0.1
                    ),
                    feature_group="location"
                ),
            ],
            **kwargs
        )
```

#### Step 2: Advanced Data Quality Checker

Now let's implement a comprehensive data quality checker that uses our schema definitions.

**File:** `src/data/quality.py`
**Path:** `ml-pipeline-project/src/data/quality.py`

```python
"""
Advanced data quality checking and reporting module.
"""

import json
import warnings
from typing import Dict, List, Optional, Union, Any, Tuple
from pathlib import Path
from datetime import datetime
import math

import pandas as pd
import numpy as np
from loguru import logger
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats

from .schemas import DataSchema, ColumnSchema, ColumnConstraint, ColumnType
from .validation import DataValidator

class DataQualityChecker:
    """
    Comprehensive data quality assessment system.
    
    This class performs detailed quality checks on datasets, including:
    - Schema compliance
    - Statistical profiling
    - Missing value patterns
    - Outlier detection (multiple methods)
    - Data drift detection
    - Correlation analysis
    - Quality scoring
    
    Example:
        >>> checker = DataQualityChecker(schema=my_schema)
        >>> report = checker.assess(df)
        >>> checker.generate_report(report, "quality_report.html")
    """
    
    def __init__(
        self,
        schema: Optional[DataSchema] = None,
        config: Optional[Dict[str, Any]] = None
    ):
        """
        Initialize the data quality checker.
        
        Args:
            schema: Optional schema definition for validation
            config: Configuration options for quality checks
        """
        self.schema = schema
        self.config = config or {}
        self.validator = DataValidator(config=config)
        
        # Quality thresholds
        self.thresholds = {
            "missing_critical": 0.3,  # >30% missing is critical
            "missing_warning": 0.1,   # >10% missing is warning
            "outlier_critical": 0.1,   # >10% outliers is critical
            "outlier_warning": 0.05,   # >5% outliers is warning
            "correlation_high": 0.8,   # Correlation >0.8 is concerning
            "correlation_perfect": 0.99,  # >0.99 is probably an error
            "cardinality_high": 50,    # >50 unique values for categorical
            "cardinality_very_high": 1000,  # >1000 is very high
            "zero_variance": 0.01,     # Variance <1% is concerning
        }
        
        logger.info("DataQualityChecker initialized")
    
    def assess(self, df: pd.DataFrame) -> Dict[str, Any]:
        """
        Perform comprehensive quality assessment on a dataset.
        
        Args:
            df: DataFrame to assess
            
        Returns:
            Dict: Complete quality assessment report
        """
        logger.info(f"Starting quality assessment for dataset with {len(df)} rows")
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "dataset_stats": self._get_basic_stats(df),
            "schema_validation": None,
            "missing_analysis": self._analyze_missing(df),
            "outlier_analysis": self._analyze_outliers(df),
            "statistical_profiles": self._generate_statistical_profiles(df),
            "correlation_analysis": self._analyze_correlations(df),
            "duplicate_analysis": self._analyze_duplicates(df),
            "cardinality_analysis": self._analyze_cardinality(df),
            "quality_scores": None,
            "recommendations": [],
            "critical_issues": [],
            "warnings": []
        }
        
        # Schema validation if available
        if self.schema:
            try:
                schema_results = self._validate_schema(df)
                report["schema_validation"] = schema_results
                
                # Check required columns
                required_cols = [col.name for col in self.schema.columns 
                               if col.constraints.not_null]
                for col in required_cols:
                    if col not in df.columns:
                        report["critical_issues"].append(
                            f"Required column '{col}' is missing"
                        )
            except Exception as e:
                logger.error(f"Schema validation failed: {str(e)}")
                report["critical_issues"].append(
                    f"Schema validation error: {str(e)}"
                )
        
        # Calculate quality scores
        report["quality_scores"] = self._calculate_quality_scores(report)
        
        # Generate recommendations
        report["recommendations"] = self._generate_recommendations(report)
        
        # Calculate overall quality grade
        report["quality_grade"] = self._calculate_quality_grade(report)
        
        logger.info(f"Quality assessment complete. Grade: {report['quality_grade']}")
        
        return report
    
    def _get_basic_stats(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Get basic dataset statistics."""
        return {
            "rows": len(df),
            "columns": len(df.columns),
            "memory_usage_mb": df.memory_usage(deep=True).sum() / 1024**2,
            "dtype_counts": df.dtypes.value_counts().to_dict(),
            "null_count_total": df.isnull().sum().sum(),
            "null_columns": df.isnull().any().sum(),
        }
    
    def _validate_schema(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Validate DataFrame against schema."""
        results = {
            "valid": True,
            "errors": [],
            "warnings": [],
            "column_checks": {}
        }
        
        if not self.schema:
            return results
        
        # Check each column in schema
        for col_schema in self.schema.columns:
            col_name = col_schema.name
            col_results = {
                "present": col_name in df.columns,
                "type_match": False,
                "constraint_checks": {}
            }
            
            if col_name not in df.columns:
                results["valid"] = False
                results["errors"].append(f"Column '{col_name}' is required but missing")
                results["column_checks"][col_name] = col_results
                continue
            
            # Type checking
            expected_type = col_schema.type
            actual_type = df[col_name].dtype
            
            # Map pandas dtypes to our types
            type_map = {
                'int64': ColumnType.INTEGER,
                'int32': ColumnType.INTEGER,
                'float64': ColumnType.FLOAT,
                'float32': ColumnType.FLOAT,
                'object': ColumnType.STRING,
                'category': ColumnType.CATEGORICAL,
                'datetime64[ns]': ColumnType.DATETIME,
                'bool': ColumnType.BOOLEAN,
            }
            
            actual_enum = type_map.get(str(actual_type))
            
            # Allow int/float interchangeability
            if actual_enum in [ColumnType.INTEGER, ColumnType.FLOAT] and \
               expected_type in [ColumnType.INTEGER, ColumnType.FLOAT]:
                col_results["type_match"] = True
            elif actual_enum == expected_type:
                col_results["type_match"] = True
            elif expected_type == ColumnType.STRING and actual_enum == ColumnType.CATEGORICAL:
                col_results["type_match"] = True
            elif expected_type == ColumnType.CATEGORICAL and actual_enum == ColumnType.STRING:
                col_results["type_match"] = True
            else:
                results["warnings"].append(
                    f"Column '{col_name}' expected {expected_type.value}, "
                    f"got {actual_enum.value if actual_enum else str(actual_type)}"
                )
            
            # Constraint checking
            constraints = col_schema.constraints
            col_data = df[col_name]
            
            # Check null constraints
            if constraints.not_null:
                null_count = col_data.isnull().sum()
                if null_count > 0:
                    col_results["constraint_checks"]["not_null"] = {
                        "passed": False,
                        "message": f"Found {null_count} null values"
                    }
                    results["warnings"].append(
                        f"Column '{col_name}' has {null_count} null values "
                        f"({null_count/len(df)*100:.1f}%)"
                    )
                else:
                    col_results["constraint_checks"]["not_null"] = {"passed": True}
            
            # Check min/max values
            if constraints.min_value is not None:
                min_val = col_data.min()
                if min_val < constraints.min_value:
                    col_results["constraint_checks"]["min_value"] = {
                        "passed": False,
                        "message": f"Min value {min_val} < {constraints.min_value}"
                    }
                    results["warnings"].append(
                        f"Column '{col_name}' has min value {min_val} "
                        f"below threshold {constraints.min_value}"
                    )
                else:
                    col_results["constraint_checks"]["min_value"] = {"passed": True}
            
            if constraints.max_value is not None:
                max_val = col_data.max()
                if max_val > constraints.max_value:
                    col_results["constraint_checks"]["max_value"] = {
                        "passed": False,
                        "message": f"Max value {max_val} > {constraints.max_value}"
                    }
                    results["warnings"].append(
                        f"Column '{col_name}' has max value {max_val} "
                        f"above threshold {constraints.max_value}"
                    )
                else:
                    col_results["constraint_checks"]["max_value"] = {"passed": True}
            
            # Check allowed values
            if constraints.allowed_values:
                invalid_mask = ~col_data.isin(constraints.allowed_values)
                invalid_count = invalid_mask.sum()
                if invalid_count > 0:
                    invalid_examples = col_data[invalid_mask].head(3).tolist()
                    col_results["constraint_checks"]["allowed_values"] = {
                        "passed": False,
                        "message": f"Found {invalid_count} invalid values: {invalid_examples}"
                    }
                    results["warnings"].append(
                        f"Column '{col_name}' has {invalid_count} values "
                        f"not in allowed set"
                    )
                else:
                    col_results["constraint_checks"]["allowed_values"] = {"passed": True}
            
            # Check uniqueness
            if constraints.unique:
                if col_data.duplicated().any():
                    dup_count = col_data.duplicated().sum()
                    col_results["constraint_checks"]["unique"] = {
                        "passed": False,
                        "message": f"Found {dup_count} duplicate values"
                    }
                    results["warnings"].append(
                        f"Column '{col_name}' has {dup_count} duplicate values"
                    )
                else:
                    col_results["constraint_checks"]["unique"] = {"passed": True}
            
            results["column_checks"][col_name] = col_results
        
        # Mark overall validity
        if results["errors"]:
            results["valid"] = False
        
        return results
    
    def _analyze_missing(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze missing value patterns in the dataset."""
        logger.debug("Analyzing missing values")
        
        missing_counts = df.isnull().sum()
        missing_percentages = (missing_counts / len(df)) * 100
        
        # Identify columns with missing values
        columns_with_missing = missing_counts[missing_counts > 0]
        
        analysis = {
            "total_missing": missing_counts.sum(),
            "total_missing_percentage": (missing_counts.sum() / (len(df) * len(df.columns))) * 100,
            "columns_with_missing": len(columns_with_missing),
            "missing_by_column": {
                col: {
                    "count": int(missing_counts[col]),
                    "percentage": float(missing_percentages[col])
                }
                for col in columns_with_missing.index
            },
            "missing_patterns": self._analyze_missing_patterns(df),
            "columns_by_missing_rate": {
                "none": missing_counts[missing_counts == 0].index.tolist(),
                "low": missing_counts[(missing_counts > 0) & (missing_percentages <= 5)].index.tolist(),
                "medium": missing_counts[(missing_percentages > 5) & (missing_percentages <= 20)].index.tolist(),
                "high": missing_counts[(missing_percentages > 20) & (missing_percentages <= 50)].index.tolist(),
                "very_high": missing_counts[missing_percentages > 50].index.tolist(),
            }
        }
        
        # Check against schema thresholds
        if self.schema:
            for col_schema in self.schema.columns:
                if col_schema.name in missing_counts:
                    threshold = col_schema.constraints.missing_threshold
                    if threshold is not None:
                        missing_pct = missing_percentages[col_schema.name] / 100
                        if missing_pct > threshold:
                            analysis["missing_by_column"][col_schema.name]["exceeds_threshold"] = True
        
        return analysis
    
    def _analyze_missing_patterns(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze patterns in missing data (MCAR, MAR, MNAR)."""
        # This is a simplified analysis - in practice, you'd use more sophisticated methods
        
        missing_matrix = df.isnull()
        missing_rows = missing_matrix.any(axis=1)
        missing_cols = missing_matrix.any(axis=0)
        
        patterns = {
            "rows_with_missing": missing_rows.sum(),
            "rows_without_missing": (~missing_rows).sum(),
            "row_missing_percentage": (missing_rows.sum() / len(df)) * 100,
            "missingness_pattern": "unknown",  # Will be inferred
        }
        
        # Check if missing values are random (simple test)
        if missing_rows.sum() > 0:
            # Check if missing rows have different distribution
            complete_data = df[~missing_rows]
            partial_data = df[missing_rows]
            
            # Compare means of numeric columns
            numeric_cols = df.select_dtypes(include=[np.number]).columns
            if len(numeric_cols) > 0:
                significant_diffs = 0
                for col in numeric_cols:
                    if len(complete_data[col].dropna()) > 0 and len(partial_data[col].dropna()) > 0:
                        # T-test to compare means
                        _, p_value = stats.ttest_ind(
                            complete_data[col].dropna(),
                            partial_data[col].dropna()
                        )
                        if p_value < 0.05:
                            significant_diffs += 1
                
                if significant_diffs / len(numeric_cols) > 0.3:
                    patterns["missingness_pattern"] = "MAR"  # Missing At Random
                else:
                    patterns["missingness_pattern"] = "MCAR"  # Missing Completely At Random
            else:
                patterns["missingness_pattern"] = "MCAR"
        else:
            patterns["missingness_pattern"] = "none"
        
        return patterns
    
    def _analyze_outliers(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze outliers using multiple methods."""
        logger.debug("Analyzing outliers")
        
        # Get numeric columns only
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        outlier_analysis = {
            "methods_used": ["iqr", "zscore", "isolation_forest"],
            "columns_analyzed": numeric_cols,
            "outliers": {}
        }
        
        for col in numeric_cols:
            data = df[col].dropna()
            if len(data) < 10:  # Skip if too few data points
                continue
            
            col_outliers = {}
            
            # Method 1: IQR
            Q1 = data.quantile(0.25)
            Q3 = data.quantile(0.75)
            IQR = Q3 - Q1
            iqr_lower = Q1 - 1.5 * IQR
            iqr_upper = Q3 + 1.5 * IQR
            iqr_outliers = ((data < iqr_lower) | (data > iqr_upper)).sum()
            col_outliers["iqr"] = {
                "count": iqr_outliers,
                "percentage": (iqr_outliers / len(data)) * 100,
                "lower_bound": iqr_lower,
                "upper_bound": iqr_upper
            }
            
            # Method 2: Z-score
            z_scores = np.abs((data - data.mean()) / data.std())
            zscore_outliers = (z_scores > 3).sum()
            col_outliers["zscore"] = {
                "count": zscore_outliers,
                "percentage": (zscore_outliers / len(data)) * 100,
                "threshold": 3
            }
            
            # Method 3: Modified Z-score (MAD-based)
            median = data.median()
            mad = np.median(np.abs(data - median))
            if mad > 0:
                mod_z_scores = 0.6745 * (data - median) / mad
                mad_outliers = (np.abs(mod_z_scores) > 3.5).sum()
                col_outliers["modified_zscore"] = {
                    "count": mad_outliers,
                    "percentage": (mad_outliers / len(data)) * 100
                }
            
            # Calculate severity
            outlier_pct = col_outliers["iqr"]["percentage"]
            severity = "low"
            if outlier_pct > self.thresholds["outlier_critical"] * 100:
                severity = "critical"
            elif outlier_pct > self.thresholds["outlier_warning"] * 100:
                severity = "warning"
            
            col_outliers["severity"] = severity
            
            # Store outliers values for inspection
            if iqr_outliers > 0:
                outlier_values = data[(data < iqr_lower) | (data > iqr_upper)]
                col_outliers["sample_outliers"] = outlier_values.head(10).tolist()
            
            outlier_analysis["outliers"][col] = col_outliers
        
        # Summary statistics
        total_outliers = sum(
            info["iqr"]["count"] 
            for info in outlier_analysis["outliers"].values()
        )
        outlier_analysis["total_outliers"] = total_outliers
        
        outlier_analysis["critical_columns"] = [
            col for col, info in outlier_analysis["outliers"].items()
            if info.get("severity") == "critical"
        ]
        
        return outlier_analysis
    
    def _generate_statistical_profiles(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Generate detailed statistical profiles for each column."""
        logger.debug("Generating statistical profiles")
        
        profiles = {}
        
        for col in df.columns:
            data = df[col].dropna()
            
            profile = {
                "dtype": str(df[col].dtype),
                "null_count": df[col].isnull().sum(),
                "null_percentage": (df[col].isnull().sum() / len(df)) * 100,
                "unique_values": df[col].nunique(),
                "unique_percentage": (df[col].nunique() / len(df)) * 100,
            }
            
            # Numeric-specific statistics
            if pd.api.types.is_numeric_dtype(df[col]):
                profile.update({
                    "min": float(data.min()),
                    "max": float(data.max()),
                    "mean": float(data.mean()),
                    "median": float(data.median()),
                    "std": float(data.std()),
                    "variance": float(data.var()),
                    "skewness": float(data.skew()),
                    "kurtosis": float(data.kurtosis()),
                    "q1": float(data.quantile(0.25)),
                    "q3": float(data.quantile(0.75)),
                    "iqr": float(data.quantile(0.75) - data.quantile(0.25)),
                })
                
                # Check for zero/low variance
                if profile["variance"] < self.thresholds["zero_variance"]:
                    profile["warning"] = "Very low variance"
                
                # Check distribution shape
                if abs(profile["skewness"]) > 1:
                    profile["distribution"] = "highly_skewed"
                elif abs(profile["skewness"]) > 0.5:
                    profile["distribution"] = "moderately_skewed"
                else:
                    profile["distribution"] = "approximately_symmetric"
            
            # Categorical-specific statistics
            elif pd.api.types.is_categorical_dtype(df[col]) or \
                 pd.api.types.is_object_dtype(df[col]):
                value_counts = df[col].value_counts()
                profile.update({
                    "most_frequent": str(value_counts.index[0]) if len(value_counts) > 0 else None,
                    "most_frequent_count": int(value_counts.iloc[0]) if len(value_counts) > 0 else 0,
                    "most_frequent_percentage": (value_counts.iloc[0] / len(df) * 100) if len(value_counts) > 0 else 0,
                    "second_most_frequent": str(value_counts.index[1]) if len(value_counts) > 1 else None,
                    "class_balance_ratio": value_counts.iloc[0] / value_counts.iloc[-1] if len(value_counts) > 0 and value_counts.iloc[-1] > 0 else None,
                })
            
            profiles[col] = profile
        
        return profiles
    
    def _analyze_correlations(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze correlations between features."""
        logger.debug("Analyzing correlations")
        
        # Get numeric columns
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        if len(numeric_cols) < 2:
            return {"message": "Need at least 2 numeric columns for correlation analysis"}
        
        # Calculate correlation matrix
        corr_matrix = df[numeric_cols].corr()
        
        # Find high correlations
        high_corr_pairs = []
        perfect_corr_pairs = []
        
        for i in range(len(corr_matrix.columns)):
            for j in range(i+1, len(corr_matrix.columns)):
                corr_val = corr_matrix.iloc[i, j]
                if abs(corr_val) > self.thresholds["correlation_perfect"]:
                    perfect_corr_pairs.append({
                        "col1": corr_matrix.columns[i],
                        "col2": corr_matrix.columns[j],
                        "correlation": corr_val
                    })
                elif abs(corr_val) > self.thresholds["correlation_high"]:
                    high_corr_pairs.append({
                        "col1": corr_matrix.columns[i],
                        "col2": corr_matrix.columns[j],
                        "correlation": corr_val
                    })
        
        analysis = {
            "numeric_columns": numeric_cols,
            "correlation_matrix": corr_matrix.to_dict(),
            "high_correlations": high_corr_pairs,
            "perfect_correlations": perfect_corr_pairs,
            "number_high_correlations": len(high_corr_pairs),
            "number_perfect_correlations": len(perfect_corr_pairs)
        }
        
        # Calculate target correlations if target column exists
        if self.schema:
            target_col = self.schema.get_target_column()
            if target_col and target_col.name in numeric_cols:
                target_corr = corr_matrix[target_col.name].drop(target_col.name)
                analysis["target_correlations"] = {
                    col: corr_val for col, corr_val in target_corr.items()
                    if not pd.isna(corr_val)
                }
        
        return analysis
    
    def _analyze_duplicates(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze duplicate rows in the dataset."""
        logger.debug("Analyzing duplicates")
        
        duplicate_mask = df.duplicated()
        duplicate_count = duplicate_mask.sum()
        
        analysis = {
            "duplicate_count": duplicate_count,
            "duplicate_percentage": (duplicate_count / len(df)) * 100,
            "has_duplicates": duplicate_count > 0,
            "duplicate_key_columns": self._find_duplicate_key_columns(df) if duplicate_count > 0 else []
        }
        
        if duplicate_count > 0:
            # Get duplicate rows
            duplicate_rows = df[duplicate_mask]
            analysis["duplicate_example"] = duplicate_rows.head(5).to_dict('records')
            
            # Analyze patterns
            value_counts = df.apply(lambda x: x.value_counts().iloc[0] if len(x.value_counts()) > 0 else 0)
            analysis["columns_with_high_frequency"] = {
                col: int(count) for col, count in value_counts.items()
                if count > len(df) * 0.1
            }
        
        return analysis
    
    def _find_duplicate_key_columns(self, df: pd.DataFrame) -> List[str]:
        """Find columns that could serve as duplicate keys."""
        # Simple heuristic: find columns with high uniqueness
        uniqueness = df.nunique() / len(df)
        potential_keys = uniqueness[uniqueness > 0.9].index.tolist()
        return potential_keys
    
    def _analyze_cardinality(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze cardinality of categorical columns."""
        logger.debug("Analyzing cardinality")
        
        categorical_cols = df.select_dtypes(include=['object', 'category']).columns.tolist()
        
        analysis = {
            "categorical_columns": categorical_cols,
            "cardinality": {}
        }
        
        for col in categorical_cols:
            n_unique = df[col].nunique()
            cardinality_level = "low"
            if n_unique > self.thresholds["cardinality_very_high"]:
                cardinality_level = "very_high"
            elif n_unique > self.thresholds["cardinality_high"]:
                cardinality_level = "high"
            
            analysis["cardinality"][col] = {
                "unique_values": n_unique,
                "cardinality_level": cardinality_level,
                "top_values": df[col].value_counts().head(10).to_dict()
            }
        
        # Count columns by cardinality level
        analysis["cardinality_summary"] = {
            "low": sum(1 for v in analysis["cardinality"].values() if v["cardinality_level"] == "low"),
            "high": sum(1 for v in analysis["cardinality"].values() if v["cardinality_level"] == "high"),
            "very_high": sum(1 for v in analysis["cardinality"].values() if v["cardinality_level"] == "very_high"),
        }
        
        return analysis
    
    def _calculate_quality_scores(self, report: Dict[str, Any]) -> Dict[str, Any]:
        """Calculate quality scores for different dimensions."""
        scores = {}
        
        # Completeness score (based on missing values)
        missing_pct = report.get("missing_analysis", {}).get("total_missing_percentage", 0)
        scores["completeness"] = max(0, 100 - missing_pct)
        
        # Consistency score (based on schema validation)
        schema_valid = report.get("schema_validation", {})
        if schema_valid:
            errors = len(schema_valid.get("errors", []))
            warnings = len(schema_valid.get("warnings", []))
            max_issues = 10  # Normalize to 10 issues = 0 score
            scores["consistency"] = max(0, 100 - ((errors * 10 + warnings * 2) / max_issues) * 100)
        else:
            scores["consistency"] = 70  # Default if no schema
        
        # Uniqueness score (based on duplicates)
        dup_pct = report.get("duplicate_analysis", {}).get("duplicate_percentage", 0)
        scores["uniqueness"] = max(0, 100 - dup_pct * 2)
        
        # Integrity score (based on outliers)
        outlier_analysis = report.get("outlier_analysis", {})
        if outlier_analysis.get("outliers"):
            avg_outlier_pct = np.mean([
                info.get("iqr", {}).get("percentage", 0)
                for info in outlier_analysis["outliers"].values()
            ])
            scores["integrity"] = max(0, 100 - avg_outlier_pct * 0.5)
        else:
            scores["integrity"] = 100
        
        # Overall score (weighted average)
        weights = {
            "completeness": 0.3,
            "consistency": 0.25,
            "uniqueness": 0.2,
            "integrity": 0.25
        }
        
        scores["overall"] = sum(score * weights[key] for key, score in scores.items())
        scores["overall"] = min(100, max(0, scores["overall"]))
        
        return scores
    
    def _calculate_quality_grade(self, report: Dict[str, Any]) -> str:
        """Calculate overall quality grade."""
        overall_score = report.get("quality_scores", {}).get("overall", 0)
        
        if overall_score >= 90:
            return "A"  # Excellent
        elif overall_score >= 80:
            return "B"  # Good
        elif overall_score >= 70:
            return "C"  # Fair
        elif overall_score >= 60:
            return "D"  # Poor
        else:
            return "F"  # Critical
        
    def _generate_recommendations(self, report: Dict[str, Any]) -> List[str]:
        """Generate actionable recommendations based on quality assessment."""
        recommendations = []
        
        # Missing value recommendations
        missing_analysis = report.get("missing_analysis", {})
        if missing_analysis:
            high_missing = missing_analysis.get("columns_by_missing_rate", {}).get("high", [])
            very_high_missing = missing_analysis.get("columns_by_missing_rate", {}).get("very_high", [])
            
            if very_high_missing:
                recommendations.append(
                    f"Consider dropping columns with very high missing rates: {very_high_missing}"
                )
            elif high_missing:
                recommendations.append(
                    f"Apply imputation for columns with high missing rates: {high_missing}"
                )
        
        # Outlier recommendations
        outlier_analysis = report.get("outlier_analysis", {})
        if outlier_analysis:
            critical_outliers = outlier_analysis.get("critical_columns", [])
            if critical_outliers:
                recommendations.append(
                    f"Investigate outliers in columns: {critical_outliers}. Consider robust scaling or winsorizing."
                )
        
        # Correlation recommendations
        corr_analysis = report.get("correlation_analysis", {})
        perfect_corrs = corr_analysis.get("perfect_correlations", [])
        if perfect_corrs:
            recommendations.append(
                f"Remove redundant features with perfect correlation: {perfect_corrs}"
            )
        
        high_corrs = corr_analysis.get("high_correlations", [])
        if high_corrs:
            recommendations.append(
                f"Consider feature selection for highly correlated features: {len(high_corrs)} pairs"
            )
        
        # Duplicate recommendations
        dup_analysis = report.get("duplicate_analysis", {})
        if dup_analysis.get("has_duplicates", False):
            recommendations.append(
                f"Remove duplicate rows ({dup_analysis.get('duplicate_count')} rows, "
                f"{dup_analysis.get('duplicate_percentage'):.1f}% of data)"
            )
        
        # Cardinality recommendations
        card_analysis = report.get("cardinality_analysis", {})
        for col, info in card_analysis.get("cardinality", {}).items():
            if info.get("cardinality_level") == "very_high":
                recommendations.append(
                    f"Consider target encoding or text embeddings for high-cardinality column: {col}"
                )
        
        # Schema recommendations
        schema_val = report.get("schema_validation", {})
        if schema_val:
            for warning in schema_val.get("warnings", [])[:3]:  # Limit to top 3
                recommendations.append(f"Fix schema warning: {warning}")
        
        return recommendations[:10]  # Limit to top 10 recommendations

    def generate_visual_report(
        self,
        df: pd.DataFrame,
        report: Dict[str, Any],
        output_path: Union[str, Path],
        show_plots: bool = True
    ) -> Path:
        """
        Generate a visual HTML report with plots and charts.
        
        Args:
            df: DataFrame that was assessed
            report: Quality assessment report
            output_path: Path to save the report
            show_plots: Whether to display plots interactively
            
        Returns:
            Path: Path to the generated report
        """
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Generating visual report at: {output_path}")
        
        # Create figures directory
        figs_dir = output_path.parent / "figures"
        figs_dir.mkdir(parents=True, exist_ok=True)
        
        # Figure 1: Missing value heatmap
        fig1, ax1 = plt.subplots(figsize=(12, 8))
        missing_matrix = df.isnull()
        sns.heatmap(
            missing_matrix, 
            cbar=True, 
            yticklabels=False, 
            cmap='viridis',
            ax=ax1
        )
        ax1.set_title("Missing Value Pattern")
        ax1.set_xlabel("Columns")
        ax1.set_ylabel("Rows")
        plt.tight_layout()
        fig1_path = figs_dir / "missing_heatmap.png"
        fig1.savefig(fig1_path, dpi=100, bbox_inches='tight')
        
        # Figure 2: Missing percentages
        fig2, ax2 = plt.subplots(figsize=(12, 6))
        missing_pcts = df.isnull().mean() * 100
        missing_pcts = missing_pcts[missing_pcts > 0].sort_values()
        if not missing_pcts.empty:
            missing_pcts.plot(kind='barh', ax=ax2)
            ax2.set_title("Missing Value Percentage by Column")
            ax2.set_xlabel("Missing Percentage (%)")
            ax2.axvline(x=10, color='orange', linestyle='--', label='Warning (10%)')
            ax2.axvline(x=30, color='red', linestyle='--', label='Critical (30%)')
            ax2.legend()
        plt.tight_layout()
        fig2_path = figs_dir / "missing_percentages.png"
        fig2.savefig(fig2_path, dpi=100, bbox_inches='tight')
        
        # Figure 3: Outlier detection for numeric columns
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        if len(numeric_cols) > 0:
            n_cols = min(len(numeric_cols), 6)
            n_rows = (n_cols + 1) // 2
            fig3, axes = plt.subplots(n_rows, 2, figsize=(14, 4*n_rows))
            if n_rows == 1:
                axes = [axes]
            axes_flat = [ax for row in axes for ax in row]
            
            for idx, col in enumerate(numeric_cols[:n_cols]):
                ax = axes_flat[idx] if idx < len(axes_flat) else axes_flat[0]
                df[col].dropna().hist(bins=30, ax=ax, edgecolor='black')
                ax.set_title(f"Distribution: {col}")
                ax.set_xlabel(col)
            
            # Hide unused subplots
            for idx in range(len(numeric_cols[:n_cols]), len(axes_flat)):
                axes_flat[idx].set_visible(False)
            
            plt.tight_layout()
            fig3_path = figs_dir / "distributions.png"
            fig3.savefig(fig3_path, dpi=100, bbox_inches='tight')
        
        # Figure 4: Correlation heatmap
        if len(numeric_cols) > 1:
            fig4, ax4 = plt.subplots(figsize=(10, 8))
            corr = df[numeric_cols].corr()
            mask = np.triu(np.ones_like(corr, dtype=bool))
            sns.heatmap(
                corr, 
                mask=mask,
                annot=True, 
                fmt='.2f', 
                cmap='coolwarm',
                vmin=-1, 
                vmax=1,
                ax=ax4,
                square=True
            )
            ax4.set_title("Feature Correlation Matrix")
            plt.tight_layout()
            fig4_path = figs_dir / "correlation_heatmap.png"
            fig4.savefig(fig4_path, dpi=100, bbox_inches='tight')
        
        # Generate HTML report
        html_content = self._generate_html_report(report, figs_dir)
        
        # Save HTML
        with open(output_path, 'w') as f:
            f.write(html_content)
        
        if show_plots:
            plt.show()
        
        plt.close('all')
        
        logger.success(f"Visual report generated at: {output_path}")
        return output_path
    
    def _generate_html_report(self, report: Dict[str, Any], figs_dir: Path) -> str:
        """Generate HTML content for the report."""
        # This is a simplified HTML template - in production, you'd use a proper templating engine
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Data Quality Report</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }}
                .container {{ max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }}
                .header {{ background: #2c3e50; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }}
                .grade {{ font-size: 48px; font-weight: bold; display: inline-block; padding: 10px 20px; border-radius: 4px; }}
                .grade-A {{ background: #27ae60; color: white; }}
                .grade-B {{ background: #3498db; color: white; }}
                .grade-C {{ background: #f39c12; color: white; }}
                .grade-D {{ background: #e67e22; color: white; }}
                .grade-F {{ background: #e74c3c; color: white; }}
                .section {{ margin: 20px 0; padding: 15px; background: #f8f9fa; border-radius: 4px; }}
                .section h2 {{ margin-top: 0; color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }}
                .metric {{ display: inline-block; margin: 10px; padding: 15px; background: white; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }}
                .metric-value {{ font-size: 24px; font-weight: bold; }}
                .warning {{ color: #e67e22; }}
                .critical {{ color: #e74c3c; }}
                .success {{ color: #27ae60; }}
                table {{ border-collapse: collapse; width: 100%; margin: 10px 0; }}
                th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                th {{ background-color: #3498db; color: white; }}
                .recommendations {{ background: #d4edda; padding: 15px; border-radius: 4px; }}
                .recommendations li {{ margin: 5px 0; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Data Quality Assessment Report</h1>
                    <p>Generated: {report.get('timestamp', 'N/A')}</p>
                </div>
                
                <div class="section">
                    <h2>Overall Quality Grade</h2>
                    <div class="grade grade-{report.get('quality_grade', 'F')}">
                        {report.get('quality_grade', 'N/A')}
                    </div>
                    <p>Score: {report.get('quality_scores', {}).get('overall', 0):.1f}%</p>
                </div>
                
                <div class="section">
                    <h2>Quality Scores</h2>
                    <div class="metric">
                        <div>Completeness</div>
                        <div class="metric-value">{report.get('quality_scores', {}).get('completeness', 0):.1f}%</div>
                    </div>
                    <div class="metric">
                        <div>Consistency</div>
                        <div class="metric-value">{report.get('quality_scores', {}).get('consistency', 0):.1f}%</div>
                    </div>
                    <div class="metric">
                        <div>Uniqueness</div>
                        <div class="metric-value">{report.get('quality_scores', {}).get('uniqueness', 0):.1f}%</div>
                    </div>
                    <div class="metric">
                        <div>Integrity</div>
                        <div class="metric-value">{report.get('quality_scores', {}).get('integrity', 0):.1f}%</div>
                    </div>
                </div>
        """
        
        # Dataset stats
        stats = report.get('dataset_stats', {})
        html += f"""
                <div class="section">
                    <h2>Dataset Overview</h2>
                    <ul>
                        <li>Rows: {stats.get('rows', 0):,}</li>
                        <li>Columns: {stats.get('columns', 0)}</li>
                        <li>Memory Usage: {stats.get('memory_usage_mb', 0):.1f} MB</li>
                        <li>Null Values: {stats.get('null_count_total', 0):,}</li>
                        <li>Columns with Nulls: {stats.get('null_columns', 0)}</li>
                    </ul>
                </div>
        """
        
        # Missing analysis
        missing = report.get('missing_analysis', {})
        if missing:
            html += f"""
                <div class="section">
                    <h2>Missing Value Analysis</h2>
                    <p>Total Missing: {missing.get('total_missing', 0):,} ({missing.get('total_missing_percentage', 0):.1f}%)</p>
                    <p>Columns with Missing: {missing.get('columns_with_missing', 0)}</p>
                    <p>Missing Pattern: {missing.get('missing_patterns', {}).get('missingness_pattern', 'unknown')}</p>
                    <img src="figures/missing_heatmap.png" style="max-width: 100%;">
                    <img src="figures/missing_percentages.png" style="max-width: 100%;">
                </div>
            """
        
        # Recommendations
        recommendations = report.get('recommendations', [])
        if recommendations:
            html += f"""
                <div class="section">
                    <h2>Recommendations</h2>
                    <div class="recommendations">
                        <ul>
                            {"".join(f"<li>{rec}</li>" for rec in recommendations[:10])}
                        </ul>
                    </div>
                </div>
            """
        
        # Critical issues
        critical = report.get('critical_issues', [])
        if critical:
            html += f"""
                <div class="section">
                    <h2 style="color: red;">Critical Issues</h2>
                    <ul>
                        {"".join(f"<li class='critical'>{issue}</li>" for issue in critical)}
                    </ul>
                </div>
            """
        
        # Visualizations
        html += """
                <div class="section">
                    <h2>Visualizations</h2>
                    <img src="figures/distributions.png" style="max-width: 100%;">
                    <img src="figures/correlation_heatmap.png" style="max-width: 100%;">
                </div>
        """
        
        html += """
            </div>
        </body>
        </html>
        """
        
        return html
```

#### Step 3: Integration Script

Now let's create a script that ties everything together and demonstrates the complete workflow.

**File:** `src/data/pipeline.py`
**Path:** `ml-pipeline-project/src/data/pipeline.py`

```python
"""
Data pipeline that integrates ingestion, validation, and quality assessment.
"""

from typing import Optional, Dict, Any, Union
from pathlib import Path
import pandas as pd
from loguru import logger

from .ingestion import DataIngestor
from .validation import DataValidator
from .quality import DataQualityChecker
from .schemas import DataSchema

class DataPipeline:
    """
    End-to-end data pipeline for ingestion, validation, and quality assessment.
    
    This class orchestrates the entire data preparation process:
    1. Load data from source
    2. Validate against schema
    3. Assess data quality
    4. Generate reports
    
    Example:
        >>> pipeline = DataPipeline()
        >>> df = pipeline.load_data("training_data.csv")
        >>> quality_report = pipeline.validate_and_assess(df)
        >>> pipeline.generate_report(quality_report)
    """
    
    def __init__(
        self,
        schema: Optional[DataSchema] = None,
        config: Optional[Dict[str, Any]] = None
    ):
        """
        Initialize the data pipeline.
        
        Args:
            schema: Optional schema for validation
            config: Configuration options
        """
        self.schema = schema
        self.config = config or {}
        self.ingestor = DataIngestor(**self.config)
        self.validator = DataValidator(config=self.config)
        self.quality_checker = DataQualityChecker(schema=schema, config=self.config)
        
        logger.info("DataPipeline initialized")
    
    def load_data(
        self,
        file_path: Union[str, Path],
        file_type: str = "csv",
        **kwargs
    ) -> pd.DataFrame:
        """
        Load data from a file.
        
        Args:
            file_path: Path to the data file
            file_type: Type of file ('csv', 'json', 'parquet')
            **kwargs: Additional arguments for the loading function
            
        Returns:
            pd.DataFrame: Loaded data
        """
        logger.info(f"Loading data from: {file_path}")
        
        if file_type.lower() == "csv":
            df = self.ingestor.load_csv(file_path, **kwargs)
        elif file_type.lower() == "json":
            df = self.ingestor.load_json(file_path, **kwargs)
        elif file_type.lower() == "parquet":
            df = self.ingestor.load_parquet(file_path, **kwargs)
        else:
            raise ValueError(f"Unsupported file type: {file_type}")
        
        logger.success(f"Loaded {len(df)} rows with {len(df.columns)} columns")
        return df
    
    def validate_and_assess(
        self,
        df: pd.DataFrame,
        generate_report: bool = True
    ) -> Dict[str, Any]:
        """
        Validate and assess data quality.
        
        Args:
            df: DataFrame to validate and assess
            generate_report: Whether to generate a detailed report
            
        Returns:
            Dict: Quality assessment results
        """
        logger.info("Starting validation and quality assessment")
        
        results = {
            "validation": None,
            "quality": None
        }
        
        # Validate
        if self.schema:
            try:
                validation_results = self.validator.validate_schema(df, self.schema)
                results["validation"] = validation_results
                logger.success("Schema validation completed")
            except Exception as e:
                logger.error(f"Schema validation failed: {str(e)}")
                results["validation"] = {"error": str(e)}
        
        # Quality assessment
        try:
            quality_results = self.quality_checker.assess(df)
            results["quality"] = quality_results
            logger.success(f"Quality assessment completed. Grade: {quality_results.get('quality_grade', 'N/A')}")
        except Exception as e:
            logger.error(f"Quality assessment failed: {str(e)}")
            results["quality"] = {"error": str(e)}
        
        return results
    
    def generate_report(
        self,
        results: Dict[str, Any],
        df: pd.DataFrame,
        output_path: Union[str, Path] = "reports/quality_report.html"
    ) -> Path:
        """
        Generate a visual quality report.
        
        Args:
            results: Results from validate_and_assess
            df: Original DataFrame
            output_path: Path to save the report
            
        Returns:
            Path: Path to the generated report
        """
        if "quality" in results and results["quality"] and "error" not in results["quality"]:
            return self.quality_checker.generate_visual_report(
                df, results["quality"], output_path, show_plots=False
            )
        else:
            logger.warning("No quality results available for report generation")
            return None
```

### The Verification: Testing Our Data Quality System

Now let's verify everything works. Run these commands and verify the outputs.

#### Test 1: Create Sample Data with Quality Issues

```bash
cat > create_test_data.py << 'EOF'
import pandas as pd
import numpy as np

# Create sample data with various quality issues
np.random.seed(42)
n_samples = 1000

df = pd.DataFrame({
    'id': range(n_samples),
    'name': np.random.choice(['Alice', 'Bob', 'Charlie', 'Diana', 'Eve'], n_samples),
    'age': np.random.normal(35, 15, n_samples).astype(int),
    'salary': np.random.exponential(50000, n_samples),
    'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], n_samples, p=[0.4, 0.3, 0.15, 0.1, 0.05]),
    'value': np.random.normal(100, 20, n_samples),
})

# Introduce quality issues
# 1. Missing values
df.loc[np.random.choice(n_samples, 50, replace=False), 'age'] = np.nan
df.loc[np.random.choice(n_samples, 30, replace=False), 'salary'] = np.nan
df.loc[np.random.choice(n_samples, 20, replace=False), 'category'] = np.nan

# 2. Duplicates
duplicate_idx = np.random.choice(n_samples, 10, replace=False)
df_duplicates = df.iloc[duplicate_idx].copy()
df = pd.concat([df, df_duplicates], ignore_index=True)

# 3. Outliers
df.loc[np.random.choice(len(df), 5, replace=False), 'age'] = 500  # Extreme outlier
df.loc[np.random.choice(len(df), 3, replace=False), 'salary'] = 10000000  # Extreme outlier

# 4. Invalid values
df.loc[np.random.choice(len(df), 2, replace=False), 'category'] = 'Z'  # Invalid category

# 5. High cardinality text column
df['description'] = np.random.choice([f"Product_{i}" for i in range(200)], len(df))

# 6. Perfect correlation (column that's just a copy)
df['value_copy'] = df['value']

# 7. Zero variance column
df['constant'] = 1

# Save the data
df.to_csv('data/raw/test_data.csv', index=False)
print(f"Created test data with {len(df)} rows and {len(df.columns)} columns")
print("\nDataset info:")
print(f"- Rows: {len(df)}")
print(f"- Columns: {df.columns.tolist()}")
print(f"- Age nulls: {df['age'].isnull().sum()}")
print(f"- Salary nulls: {df['salary'].isnull().sum()}")
print(f"- Category nulls: {df['category'].isnull().sum()}")
print(f"- Duplicates: {df.duplicated().sum()}")
print(f"- Constant column: {df['constant'].nunique()} unique values")
print(f"- Perfect correlation: {df['value'].corr(df['value_copy'])}")
EOF

python create_test_data.py
```

#### Test 2: Run the Data Quality Assessment

```bash
cat > test_quality.py << 'EOF'
from src.data.pipeline import DataPipeline
from src.data.schemas import DataSchema, ColumnSchema, ColumnConstraint, ColumnType
import pandas as pd

# Define a schema for our test data
schema = DataSchema(
    name="test_data",
    version="1.0.0",
    description="Test dataset with quality issues",
    columns=[
        ColumnSchema(
            name="id",
            type=ColumnType.INTEGER,
            constraints=ColumnConstraint(unique=True, not_null=True),
            is_identifier=True
        ),
        ColumnSchema(
            name="name",
            type=ColumnType.CATEGORICAL,
            constraints=ColumnConstraint(not_null=True),
            feature_group="identity"
        ),
        ColumnSchema(
            name="age",
            type=ColumnType.INTEGER,
            constraints=ColumnConstraint(min_value=0, max_value=120, not_null=True),
            feature_group="demographic"
        ),
        ColumnSchema(
            name="salary",
            type=ColumnType.FLOAT,
            constraints=ColumnConstraint(min_value=0),
            feature_group="financial"
        ),
        ColumnSchema(
            name="category",
            type=ColumnType.CATEGORICAL,
            constraints=ColumnConstraint(allowed_values=['A', 'B', 'C', 'D', 'E']),
            feature_group="categorical"
        ),
        ColumnSchema(
            name="value",
            type=ColumnType.FLOAT,
            feature_group="measurements"
        ),
        ColumnSchema(
            name="description",
            type=ColumnType.STRING,
            feature_group="text"
        ),
        ColumnSchema(
            name="value_copy",
            type=ColumnType.FLOAT,
            feature_group="measurements"
        ),
        ColumnSchema(
            name="constant",
            type=ColumnType.INTEGER,
            feature_group="other"
        ),
    ]
)

# Initialize pipeline
pipeline = DataPipeline(schema=schema)

# Load data
df = pipeline.load_data("data/raw/test_data.csv")

# Print basic info
print("Dataset loaded:")
print(f"  Shape: {df.shape}")
print(f"  Columns: {df.columns.tolist()}")
print(f"  Nulls: {df.isnull().sum().sum()}")

# Validate and assess
results = pipeline.validate_and_assess(df)

# Print results
print("\n" + "="*60)
print("QUALITY ASSESSMENT RESULTS")
print("="*60)

quality = results['quality']
print(f"Quality Grade: {quality.get('quality_grade', 'N/A')}")
print(f"Overall Score: {quality.get('quality_scores', {}).get('overall', 0):.1f}%")

print("\nQuality Scores:")
scores = quality.get('quality_scores', {})
for key, value in scores.items():
    if key != 'overall':
        print(f"  {key.capitalize()}: {value:.1f}%")

print("\nCritical Issues:")
for issue in quality.get('critical_issues', []):
    print(f"  ⚠️ {issue}")

print("\nRecommendations:")
for rec in quality.get('recommendations', [])[:5]:
    print(f"  💡 {rec}")

# Generate visual report
report_path = pipeline.generate_report(results, df, "reports/quality_report.html")
print(f"\nReport generated: {report_path}")

# Save results as JSON
import json
from pathlib import Path

# Remove non-serializable objects
def clean_for_json(obj):
    if isinstance(obj, (pd.DataFrame, pd.Series)):
        return None
    if isinstance(obj, (np.integer, np.floating)):
        return float(obj)
    if isinstance(obj, np.ndarray):
        return obj.tolist()
    if isinstance(obj, dict):
        return {k: clean_for_json(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [clean_for_json(v) for v in obj]
    return obj

clean_results = clean_for_json(results)
with open('reports/quality_report.json', 'w') as f:
    json.dump(clean_results, f, indent=2, default=str)

print("Quality report saved as JSON: reports/quality_report.json")
EOF

python test_quality.py
```

#### Test 3: View the Generated Report

The report will be saved as `reports/quality_report.html`. Open it in your browser:

```bash
# On Linux/Mac
open reports/quality_report.html

# On Windows
start reports/quality_report.html
```

You should see a comprehensive report with:
- Overall quality grade
- Quality scores for each dimension
- Missing value analysis with visualizations
- Recommendations for improvement
- Critical issues identified
- Distribution plots
- Correlation heatmap

#### Test 4: Run the Full Test Suite

```bash
# Create a test file for the quality system
cat > tests/test_quality.py << 'EOF'
import pytest
import pandas as pd
import numpy as np
from pathlib import Path

from src.data.quality import DataQualityChecker
from src.data.schemas import DataSchema, ColumnSchema, ColumnConstraint, ColumnType

class TestDataQualityChecker:
    """Test suite for DataQualityChecker."""
    
    def setup_method(self):
        """Set up test fixtures."""
        # Create test data with known issues
        np.random.seed(42)
        self.df = pd.DataFrame({
            'numeric_clean': np.random.normal(100, 10, 100),
            'numeric_with_outliers': np.append(
                np.random.normal(100, 10, 95),
                [500, 600, 700, 800, 900]  # Outliers
            ),
            'categorical': np.random.choice(['A', 'B', 'C'], 100, p=[0.6, 0.3, 0.1]),
            'with_missing': np.append(
                np.random.normal(50, 5, 90),
                [np.nan] * 10
            ),
            'constant': [1] * 100,
            'duplicate_col': np.random.choice([1, 2, 3], 100)
        })
        # Add duplicate rows
        self.df = pd.concat([self.df, self.df.iloc[0:10]], ignore_index=True)
        
        # Create schema
        self.schema = DataSchema(
            name="test",
            version="1.0",
            columns=[
                ColumnSchema(
                    name="numeric_clean",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(not_null=True)
                ),
                ColumnSchema(
                    name="numeric_with_outliers",
                    type=ColumnType.FLOAT,
                    constraints=ColumnConstraint(not_null=True)
                ),
                ColumnSchema(
                    name="categorical",
                    type=ColumnType.CATEGORICAL,
                    constraints=ColumnConstraint(not_null=True)
                ),
                ColumnSchema(
                    name="with_missing",
                    type=ColumnType.FLOAT
                ),
            ]
        )
        
        self.checker = DataQualityChecker(schema=self.schema)
    
    def test_assess_returns_all_keys(self):
        """Test that assessment returns all expected keys."""
        report = self.checker.assess(self.df)
        
        expected_keys = [
            'timestamp', 'dataset_stats', 'schema_validation',
            'missing_analysis', 'outlier_analysis', 'statistical_profiles',
            'correlation_analysis', 'duplicate_analysis',
            'cardinality_analysis', 'quality_scores', 'recommendations',
            'critical_issues', 'warnings', 'quality_grade'
        ]
        
        for key in expected_keys:
            assert key in report, f"Missing key: {key}"
    
    def test_missing_analysis(self):
        """Test missing value analysis."""
        report = self.checker.assess(self.df)
        missing = report['missing_analysis']
        
        assert 'with_missing' in missing['missing_by_column']
        assert missing['missing_by_column']['with_missing']['count'] == 10
    
    def test_outlier_analysis(self):
        """Test outlier detection."""
        report = self.checker.assess(self.df)
        outliers = report['outlier_analysis']
        
        # Should detect outliers in numeric_with_outliers
        assert 'numeric_with_outliers' in outliers['outliers']
        assert outliers['outliers']['numeric_with_outliers']['iqr']['count'] > 0
    
    def test_duplicate_analysis(self):
        """Test duplicate detection."""
        report = self.checker.assess(self.df)
        duplicates = report['duplicate_analysis']
        
        assert duplicates['has_duplicates'] is True
        assert duplicates['duplicate_count'] == 10
    
    def test_quality_scores(self):
        """Test quality score calculation."""
        report = self.checker.assess(self.df)
        scores = report['quality_scores']
        
        assert 'completeness' in scores
        assert 'consistency' in scores
        assert 'uniqueness' in scores
        assert 'integrity' in scores
        assert 'overall' in scores
        assert 0 <= scores['overall'] <= 100
    
    def test_generate_visual_report(self):
        """Test visual report generation."""
        report = self.checker.assess(self.df)
        
        output_path = Path("test_report.html")
        generated_path = self.checker.generate_visual_report(
            self.df, report, output_path, show_plots=False
        )
        
        assert generated_path.exists()
        assert generated_path.suffix == '.html'
        
        # Clean up
        generated_path.unlink()
        # Clean up figures directory
        figures_dir = generated_path.parent / "figures"
        if figures_dir.exists():
            import shutil
            shutil.rmtree(figures_dir)

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
EOF

# Run the tests
pytest tests/test_quality.py -v
```

### What Just Happened: Deep Dive into Data Quality

Let's understand the sophisticated system we've built.

#### Understanding Missing Data Mechanisms

In statistics, missing data falls into three categories. Understanding these is crucial because they determine how you should handle the missingness:

**MCAR (Missing Completely At Random)**
- The probability of missing data is the same for all observations
- Example: A sensor fails randomly, independent of what it's measuring
- Impact: Less problematic; you can often delete these cases without much bias
- Our code: Identifies this when missing rows don't differ significantly from complete rows

**MAR (Missing At Random)**
- The probability of missing data depends on observed variables, not the missing value itself
- Example: Younger people are more likely to skip a question about retirement savings
- Impact: Can introduce bias if not handled properly
- Our code: Identifies this when missing rows differ on some observed characteristics

**MNAR (Missing Not At Random)**
- The probability of missing data depends on the missing value itself
- Example: People with high income are less likely to report their income
- Impact: Most problematic; requires careful modeling or domain knowledge
- Our code: Flags this as a warning when patterns suggest it

#### The Quality Dimensions We Measure

**Completeness (What's missing?)**
- How much data is missing?
- Where is it missing?
- Is it missing randomly or systematically?

**Consistency (Does it match expectations?)**
- Do columns have the right types?
- Are values within expected ranges?
- Do categorical values match allowed sets?

**Uniqueness (Are there duplicates?)**
- Are there duplicate rows?
- Are there duplicate values in identifier columns?
- What percentage of data is duplicated?

**Integrity (Are there errors?)**
- Are there outliers?
- Are there impossible values?
- Are there contradictions in the data?

#### The Outlier Detection Methods

We implemented three different outlier detection methods:

**IQR (Interquartile Range)**
- Most common method
- Uses quartiles to define the "normal" range
- Points outside 1.5×IQR are considered outliers
- Robust to extreme values

**Z-Score**
- Measures how many standard deviations a point is from the mean
- Points with |z| > 3 are outliers
- Assumes roughly normal distribution

**Modified Z-Score (MAD-based)**
- Uses median and median absolute deviation
- More robust to extreme values than regular Z-score
- Good for skewed distributions

### Troubleshooting

#### Issue: "ModuleNotFoundError: No module named 'src'"

Add the project root to PYTHONPATH:

```bash
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
```

#### Issue: Matplotlib figures not displaying

If you're in a headless environment, set the backend:

```python
import matplotlib
matplotlib.use('Agg')  # For non-interactive environments
```

#### Issue: Memory errors with large datasets

Reduce the sample size for quality assessment:

```python
# Sample the data for assessment
df_sample = df.sample(min(10000, len(df)))
results = checker.assess(df_sample)
```

### Summary

In this part, we've built a comprehensive data quality system that:

1. **Defines schemas** using Pydantic, with rich constraints and metadata
2. **Validates data** against schemas, catching type errors and constraint violations
3. **Analyzes missing data** patterns and identifies MCAR vs MAR
4. **Detects outliers** using IQR, Z-score, and MAD-based methods
5. **Finds duplicates** and identifies potential duplicate keys
6. **Analyzes correlations** between features
7. **Assesses cardinality** of categorical columns
8. **Calculates quality scores** across multiple dimensions
9. **Generates actionable recommendations** for improving data quality
10. **Creates visual HTML reports** with plots and charts

This system will be integrated into our pipeline so that every time we load data, we automatically check its quality before doing anything else. This prevents the "garbage in, garbage out" problem and ensures that when we later train models, we trust our data.

### What's Next

In Part 3, we'll explore the data through exploratory data analysis (EDA). We'll:
- Analyze feature distributions
- Investigate relationships between features and the target
- Identify potential transformations
- Document our findings
- Create visualizations that inform our feature engineering decisions
