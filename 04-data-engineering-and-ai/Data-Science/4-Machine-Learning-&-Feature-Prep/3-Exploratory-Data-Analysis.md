# Phase 1: Foundation Building

## Part 3: Exploratory Data Analysis

Welcome back! In Parts 1 and 2, we built the infrastructure for our project—the directory structure, data ingestion, and comprehensive data quality validation. Now we're going to use these tools to truly understand our data. This is where the science of data science really begins.

### The Target: Comprehensive Exploratory Data Analysis

By the end of this part, you'll have:
1. A complete EDA framework that works with any dataset
2. Automated statistical analysis of all features
3. Interactive visualizations for exploring relationships
4. Target variable analysis and feature-target relationships
5. Automated insights and recommendations for feature engineering
6. A complete EDA report generator
7. Integration with our data pipeline

### The Concept: Why EDA is the Most Important Step

Here's a truth that separates effective data scientists from ineffective ones: **EDA is not a one-time step at the beginning—it's a process that continues throughout the modeling lifecycle.** 

Think of EDA like building a map of a new city before you decide where to build your house:

- **Without EDA**: You place your house randomly, hoping the land is stable and the location works for your needs. You might end up building on a swamp.

- **With EDA**: You survey the terrain, check the soil quality, understand the traffic patterns, talk to neighbors, study the weather patterns. By the time you build, you know exactly where and how to build.

EDA answers critical questions:
- **What does the data actually look like?** (Distributions, scales, patterns)
- **Are there subgroups or clusters?** (Segments that might need different models)
- **Which features are most informative?** (What should we focus on?)
- **Are there transformation opportunities?** (Log transforms, polynomial features)
- **Are there hidden relationships?** (Interactions, non-linear patterns)
- **Are there data quality issues we missed?** (Other things to validate)

### The Implementation: Building Our EDA Framework

#### Step 1: Core EDA Classes

Let's build a comprehensive EDA system that handles all aspects of exploratory analysis.

**File:** `src/analysis/__init__.py`
**Path:** `ml-pipeline-project/src/analysis/__init__.py`

```python
"""Exploratory Data Analysis and Visualization module."""

from .eda import ExploratoryDataAnalyzer
from .visualizations import DataVisualizer
from .reports import EDAReportGenerator

__all__ = ["ExploratoryDataAnalyzer", "DataVisualizer", "EDAReportGenerator"]
```

**File:** `src/analysis/eda.py`
**Path:** `ml-pipeline-project/src/analysis/eda.py`

```python
"""
Core exploratory data analysis module.
Provides comprehensive statistical analysis and insights.
"""

import warnings
from typing import Dict, List, Optional, Union, Any, Tuple
from pathlib import Path
from datetime import datetime
import json

import pandas as pd
import numpy as np
from loguru import logger
from scipy import stats
from scipy.stats import normaltest, spearmanr, pearsonr
import matplotlib.pyplot as plt
import seaborn as sns

warnings.filterwarnings("ignore", category=UserWarning)

class ExploratoryDataAnalyzer:
    """
    Comprehensive exploratory data analysis engine.
    
    This class performs deep statistical analysis and generates insights
    about the dataset, including:
    - Univariate analysis (distributions, statistics)
    - Bivariate analysis (relationships, correlations)
    - Multivariate analysis (interactions, patterns)
    - Feature importance estimation
    - Data transformation recommendations
    
    Example:
        >>> eda = ExploratoryDataAnalyzer(target_col="target")
        >>> report = eda.analyze(df)
        >>> eda.generate_summary(report)
    """
    
    def __init__(
        self,
        target_col: Optional[str] = None,
        categorical_threshold: int = 10,
        config: Optional[Dict[str, Any]] = None
    ):
        """
        Initialize the EDA analyzer.
        
        Args:
            target_col: Name of the target column (if known)
            categorical_threshold: Max unique values to treat as categorical
            config: Additional configuration options
        """
        self.target_col = target_col
        self.categorical_threshold = categorical_threshold
        self.config = config or {}
        
        # Analysis results storage
        self._analysis_results = {}
        
        logger.info(f"ExploratoryDataAnalyzer initialized with target_col={target_col}")
    
    def analyze(
        self,
        df: pd.DataFrame,
        deep_analysis: bool = True
    ) -> Dict[str, Any]:
        """
        Perform comprehensive analysis on the dataset.
        
        Args:
            df: DataFrame to analyze
            deep_analysis: Whether to perform intensive analysis
            
        Returns:
            Dict: Complete analysis results
        """
        logger.info(f"Starting EDA for dataset with {len(df)} rows")
        
        # Start with a copy
        df = df.copy()
        
        # Identify column types
        column_types = self._identify_column_types(df)
        
        # Build analysis report
        report = {
            "timestamp": datetime.now().isoformat(),
            "dataset_info": self._get_dataset_info(df),
            "column_types": column_types,
            "univariate": self._analyze_univariate(df, column_types),
            "missing_analysis": self._analyze_missing_patterns(df),
            "correlations": self._analyze_correlations(df, column_types),
        }
        
        # Add target-specific analysis if target is specified
        if self.target_col and self.target_col in df.columns:
            report["target_analysis"] = self._analyze_target(df, column_types)
            
            # Feature-target relationships
            report["feature_target_relationships"] = self._analyze_feature_target(
                df, column_types
            )
        
        # Optional deep analysis
        if deep_analysis:
            report["multivariate"] = self._analyze_multivariate(df, column_types)
            report["outliers"] = self._analyze_outliers_deep(df, column_types)
            report["cluster_analysis"] = self._analyze_clusters(df, column_types)
        
        # Generate insights and recommendations
        report["insights"] = self._generate_insights(report)
        report["recommendations"] = self._generate_recommendations(report)
        
        # Store results
        self._analysis_results = report
        
        logger.success("EDA analysis completed")
        return report
    
    def _identify_column_types(self, df: pd.DataFrame) -> Dict[str, str]:
        """Identify column types (numeric, categorical, datetime, text)."""
        column_types = {}
        
        for col in df.columns:
            dtype = df[col].dtype
            
            # Check for datetime
            if pd.api.types.is_datetime64_any_dtype(dtype):
                column_types[col] = "datetime"
            # Check for numeric
            elif pd.api.types.is_numeric_dtype(dtype):
                if df[col].nunique() <= self.categorical_threshold:
                    column_types[col] = "numeric_categorical"
                else:
                    column_types[col] = "numeric"
            # Check for categorical/object
            elif pd.api.types.is_categorical_dtype(dtype) or pd.api.types.is_object_dtype(dtype):
                n_unique = df[col].nunique()
                if n_unique <= self.categorical_threshold:
                    column_types[col] = "categorical"
                else:
                    # Check if it might be text
                    avg_len = df[col].astype(str).str.len().mean()
                    if avg_len > 50:
                        column_types[col] = "text"
                    else:
                        column_types[col] = "high_cardinality_categorical"
            else:
                column_types[col] = "unknown"
        
        return column_types
    
    def _get_dataset_info(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Get basic dataset information."""
        return {
            "rows": len(df),
            "columns": len(df.columns),
            "memory_usage_mb": df.memory_usage(deep=True).sum() / 1024**2,
            "column_names": list(df.columns),
            "duplicate_rows": df.duplicated().sum(),
            "duplicate_percentage": (df.duplicated().sum() / len(df)) * 100,
        }
    
    def _analyze_univariate(
        self,
        df: pd.DataFrame,
        column_types: Dict[str, str]
    ) -> Dict[str, Dict[str, Any]]:
        """Perform univariate analysis on all columns."""
        logger.debug("Performing univariate analysis")
        
        univariate = {}
        
        for col in df.columns:
            col_data = df[col]
            col_type = column_types[col]
            
            analysis = {
                "type": col_type,
                "null_count": col_data.isnull().sum(),
                "null_percentage": (col_data.isnull().sum() / len(df)) * 100,
                "unique_count": col_data.nunique(),
                "unique_percentage": (col_data.nunique() / len(df)) * 100,
            }
            
            # Numeric analysis
            if col_type in ["numeric", "numeric_categorical"]:
                clean_data = col_data.dropna()
                if len(clean_data) > 0:
                    analysis.update({
                        "min": float(clean_data.min()),
                        "max": float(clean_data.max()),
                        "mean": float(clean_data.mean()),
                        "median": float(clean_data.median()),
                        "std": float(clean_data.std()),
                        "var": float(clean_data.var()),
                        "skewness": float(clean_data.skew()),
                        "kurtosis": float(clean_data.kurtosis()),
                        "q1": float(clean_data.quantile(0.25)),
                        "q3": float(clean_data.quantile(0.75)),
                        "iqr": float(clean_data.quantile(0.75) - clean_data.quantile(0.25)),
                    })
                    
                    # Normality test
                    if len(clean_data) > 8:  # Need at least 8 samples for normality test
                        try:
                            stat, p_value = normaltest(clean_data)
                            analysis["normality"] = {
                                "p_value": p_value,
                                "is_normal": p_value > 0.05
                            }
                        except:
                            analysis["normality"] = {"is_normal": False}
            
            # Categorical analysis
            elif col_type in ["categorical", "high_cardinality_categorical"]:
                value_counts = col_data.value_counts()
                top_10 = value_counts.head(10).to_dict()
                
                analysis.update({
                    "most_frequent": str(value_counts.index[0]) if len(value_counts) > 0 else None,
                    "most_frequent_count": int(value_counts.iloc[0]) if len(value_counts) > 0 else 0,
                    "most_frequent_percentage": (value_counts.iloc[0] / len(df) * 100) if len(value_counts) > 0 else 0,
                    "top_10_values": {str(k): int(v) for k, v in top_10.items()},
                    "cardinality_level": self._get_cardinality_level(len(value_counts)),
                })
            
            # Text analysis
            elif col_type == "text":
                text_data = col_data.dropna().astype(str)
                if len(text_data) > 0:
                    analysis.update({
                        "avg_length": text_data.str.len().mean(),
                        "max_length": text_data.str.len().max(),
                        "min_length": text_data.str.len().min(),
                        "avg_words": text_data.str.split().str.len().mean(),
                    })
            
            univariate[col] = analysis
        
        return univariate
    
    def _get_cardinality_level(self, n_unique: int) -> str:
        """Determine cardinality level."""
        if n_unique <= 10:
            return "low"
        elif n_unique <= 50:
            return "medium"
        elif n_unique <= 200:
            return "high"
        else:
            return "very_high"
    
    def _analyze_missing_patterns(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Analyze patterns in missing data."""
        logger.debug("Analyzing missing patterns")
        
        # Calculate missing correlations
        missing_matrix = df.isnull()
        
        # Column missing rates
        missing_rates = missing_matrix.mean() * 100
        
        # Pairwise missing co-occurrence
        if len(df.columns) > 1:
            missing_corr = missing_matrix.corr()
            # Find highly correlated missing patterns
            high_missing_corr = []
            for i in range(len(missing_corr.columns)):
                for j in range(i+1, len(missing_corr.columns)):
                    corr = missing_corr.iloc[i, j]
                    if abs(corr) > 0.5 and corr != 1.0:
                        high_missing_corr.append({
                            "col1": missing_corr.columns[i],
                            "col2": missing_corr.columns[j],
                            "correlation": corr
                        })
        else:
            high_missing_corr = []
            missing_corr = None
        
        return {
            "missing_by_column": missing_rates.to_dict(),
            "total_missing": df.isnull().sum().sum(),
            "total_missing_percentage": (df.isnull().sum().sum() / (len(df) * len(df.columns))) * 100,
            "columns_with_missing": df.isnull().any().sum(),
            "rows_with_missing": missing_matrix.any(axis=1).sum(),
            "rows_without_missing": (~missing_matrix.any(axis=1)).sum(),
            "missing_correlation": missing_corr.to_dict() if missing_corr is not None else None,
            "high_missing_correlations": high_missing_corr,
        }
    
    def _analyze_correlations(
        self,
        df: pd.DataFrame,
        column_types: Dict[str, str]
    ) -> Dict[str, Any]:
        """Analyze correlations between numeric features."""
        logger.debug("Analyzing correlations")
        
        # Get numeric columns
        numeric_cols = [col for col, dtype in column_types.items() 
                       if dtype in ["numeric", "numeric_categorical"]]
        
        if len(numeric_cols) < 2:
            return {"message": "Need at least 2 numeric columns for correlation analysis"}
        
        # Calculate Pearson correlation
        pearson_corr = df[numeric_cols].corr(method='pearson')
        
        # Calculate Spearman correlation (robust to non-linearity)
        spearman_corr = df[numeric_cols].corr(method='spearman')
        
        # Find high correlations
        high_corr_pairs = []
        perfect_corr_pairs = []
        negative_corr_pairs = []
        
        for i in range(len(pearson_corr.columns)):
            for j in range(i+1, len(pearson_corr.columns)):
                corr = pearson_corr.iloc[i, j]
                if abs(corr) > 0.99:
                    perfect_corr_pairs.append({
                        "col1": pearson_corr.columns[i],
                        "col2": pearson_corr.columns[j],
                        "correlation": corr
                    })
                elif abs(corr) > 0.7:
                    high_corr_pairs.append({
                        "col1": pearson_corr.columns[i],
                        "col2": pearson_corr.columns[j],
                        "correlation": corr
                    })
                elif corr < -0.7:
                    negative_corr_pairs.append({
                        "col1": pearson_corr.columns[i],
                        "col2": pearson_corr.columns[j],
                        "correlation": corr
                    })
        
        return {
            "pearson_correlation": pearson_corr.to_dict(),
            "spearman_correlation": spearman_corr.to_dict(),
            "high_correlations": high_corr_pairs,
            "perfect_correlations": perfect_corr_pairs,
            "negative_correlations": negative_corr_pairs,
            "num_high_correlations": len(high_corr_pairs),
            "num_perfect_correlations": len(perfect_corr_pairs),
        }
    
    def _analyze_target(
        self,
        df: pd.DataFrame,
        column_types: Dict[str, str]
    ) -> Dict[str, Any]:
        """Analyze the target column."""
        logger.debug(f"Analyzing target column: {self.target_col}")
        
        target_data = df[self.target_col]
        target_type = column_types[self.target_col]
        
        analysis = {
            "type": target_type,
            "null_count": target_data.isnull().sum(),
            "null_percentage": (target_data.isnull().sum() / len(df)) * 100,
        }
        
        if target_type in ["numeric", "numeric_categorical"]:
            clean_data = target_data.dropna()
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
                "iqr": float(clean_data.quantile(0.75) - clean_data.quantile(0.25)),
            })
            
            # Determine if regression or classification
            if target_data.nunique() <= self.categorical_threshold:
                analysis["problem_type"] = "classification"
                analysis["class_counts"] = target_data.value_counts().to_dict()
                analysis["class_ratios"] = {
                    str(k): v / len(target_data) for k, v in target_data.value_counts().to_dict().items()
                }
                # Check balance
                max_ratio = max(analysis["class_ratios"].values())
                min_ratio = min(analysis["class_ratios"].values())
                analysis["balance_ratio"] = max_ratio / min_ratio if min_ratio > 0 else float('inf')
                analysis["is_balanced"] = analysis["balance_ratio"] < 3.0
            else:
                analysis["problem_type"] = "regression"
        else:
            # Categorical target
            analysis["class_counts"] = target_data.value_counts().to_dict()
            analysis["class_ratios"] = {
                str(k): v / len(target_data) for k, v in target_data.value_counts().to_dict().items()
            }
            analysis["problem_type"] = "classification"
        
        return analysis
    
    def _analyze_feature_target(
        self,
        df: pd.DataFrame,
        column_types: Dict[str, str]
    ) -> Dict[str, Any]:
        """Analyze relationships between features and target."""
        logger.debug("Analyzing feature-target relationships")
        
        relationships = {}
        
        # Get feature columns (exclude target)
        feature_cols = [col for col in df.columns if col != self.target_col]
        
        for col in feature_cols:
            col_type = column_types[col]
            
            rel = {
                "feature_type": col_type,
                "null_count": df[col].isnull().sum(),
            }
            
            # For numeric features
            if col_type in ["numeric", "numeric_categorical"]:
                # If target is numeric: Pearson correlation
                if self.target_col in df.columns and df[self.target_col].dtype in [np.float64, np.int64]:
                    valid_data = df[[col, self.target_col]].dropna()
                    if len(valid_data) > 0:
                        pearson_corr, p_val = pearsonr(valid_data[col], valid_data[self.target_col])
                        rel["pearson_correlation"] = pearson_corr
                        rel["pearson_p_value"] = p_val
                        
                        spearman_corr, s_p_val = spearmanr(valid_data[col], valid_data[self.target_col])
                        rel["spearman_correlation"] = spearman_corr
                        rel["spearman_p_value"] = s_p_val
                        
                        # Determine if relationship is linear or monotonic
                        rel["relationship_type"] = "linear" if abs(pearson_corr) > abs(spearman_corr) else "monotonic"
                
                # If target is categorical: ANOVA or Kruskal-Wallis
                else:
                    rel["target_correlation"] = self._calculate_categorical_correlation(
                        df, col, self.target_col
                    )
            
            # For categorical features
            elif col_type in ["categorical", "high_cardinality_categorical"]:
                # If target is numeric: ANOVA
                rel["target_correlation"] = self._calculate_categorical_correlation(
                    df, col, self.target_col
                )
                # If target is categorical: Cramér's V or Chi-squared
                if df[self.target_col].dtype.name in ['object', 'category']:
                    rel["cramers_v"] = self._calculate_cramers_v(df, col, self.target_col)
            
            relationships[col] = rel
        
        # Sort by importance (highest correlation first)
        sorted_relationships = sorted(
            relationships.items(),
            key=lambda x: abs(x[1].get('target_correlation', 0)),
            reverse=True
        )
        
        return {
            "by_feature": relationships,
            "top_10_features": sorted_relationships[:10]
        }
    
    def _calculate_categorical_correlation(
        self,
        df: pd.DataFrame,
        cat_col: str,
        target_col: str
    ) -> float:
        """Calculate correlation between categorical feature and target."""
        try:
            # If target is numeric, use ANOVA F-test
            if df[target_col].dtype in [np.float64, np.int64]:
                groups = [group[target_col].values for name, group in df.groupby(cat_col)]
                if len(groups) > 1 and all(len(g) > 1 for g in groups):
                    f_stat, p_value = stats.f_oneway(*groups)
                    # Convert F-statistic to correlation-like measure
                    # This is a rough heuristic
                    return min(1.0, f_stat / (f_stat + len(groups)))
            else:
                # Both categorical: use mutual information or Cramér's V
                return self._calculate_cramers_v(df, cat_col, target_col)
        except:
            return 0.0
    
    def _calculate_cramers_v(
        self,
        df: pd.DataFrame,
        col1: str,
        col2: str
    ) -> float:
        """Calculate Cramér's V statistic for two categorical variables."""
        from scipy.stats import chi2_contingency
        
        # Create contingency table
        contingency = pd.crosstab(df[col1], df[col2])
        
        # Chi-square test
        chi2, p, dof, expected = chi2_contingency(contingency)
        
        # Calculate Cramér's V
        n = contingency.sum().sum()
        min_dim = min(contingency.shape) - 1
        
        if min_dim == 0:
            return 0.0
        
        cramers_v = np.sqrt(chi2 / (n * min_dim))
        
        return cramers_v
    
    def _analyze_multivariate(
        self,
        df: pd.DataFrame,
        column_types: Dict[str, str]
    ) -> Dict[str, Any]:
        """Perform multivariate analysis."""
        logger.debug("Performing multivariate analysis")
        
        # PCA for dimensionality analysis
        numeric_cols = [col for col, dtype in column_types.items() 
                       if dtype in ["numeric", "numeric_categorical"]]
        
        if len(numeric_cols) >= 2:
            from sklearn.decomposition import PCA
            from sklearn.preprocessing import StandardScaler
            
            # Prepare data
            data = df[numeric_cols].dropna()
            if len(data) > 1:
                # Scale the data
                scaler = StandardScaler()
                scaled_data = scaler.fit_transform(data)
                
                # Apply PCA
                pca = PCA()
                pca_result = pca.fit_transform(scaled_data)
                
                # Calculate explained variance
                explained_variance_ratio = pca.explained_variance_ratio_
                cumulative_variance = np.cumsum(explained_variance_ratio)
                
                # Find number of components for 95% variance
                n_components_95 = np.argmax(cumulative_variance >= 0.95) + 1
                
                return {
                    "pca": {
                        "n_components_95": n_components_95,
                        "explained_variance_ratio": explained_variance_ratio.tolist(),
                        "cumulative_variance": cumulative_variance.tolist(),
                        "components": pca.components_.tolist()
                    }
                }
        
        return {"message": "Insufficient numeric columns for multivariate analysis"}
    
    def _analyze_outliers_deep(
        self,
        df: pd.DataFrame,
        column_types: Dict[str, str]
    ) -> Dict[str, Any]:
        """Perform deep outlier analysis."""
        logger.debug("Performing deep outlier analysis")
        
        numeric_cols = [col for col, dtype in column_types.items() 
                       if dtype in ["numeric", "numeric_categorical"]]
        
        outlier_analysis = {}
        
        for col in numeric_cols:
            data = df[col].dropna()
            if len(data) < 10:
                continue
            
            # IQR method
            Q1 = data.quantile(0.25)
            Q3 = data.quantile(0.75)
            IQR = Q3 - Q1
            lower = Q1 - 1.5 * IQR
            upper = Q3 + 1.5 * IQR
            iqr_outliers = ((data < lower) | (data > upper)).sum()
            
            # Z-score method
            z_scores = np.abs((data - data.mean()) / data.std())
            zscore_outliers = (z_scores > 3).sum()
            
            # Modified Z-score (MAD)
            median = data.median()
            mad = np.median(np.abs(data - median))
            if mad > 0:
                mod_z = 0.6745 * (data - median) / mad
                mad_outliers = (np.abs(mod_z) > 3.5).sum()
            else:
                mad_outliers = 0
            
            outlier_analysis[col] = {
                "iqr_count": iqr_outliers,
                "iqr_percentage": (iqr_outliers / len(data)) * 100,
                "zscore_count": zscore_outliers,
                "zscore_percentage": (zscore_outliers / len(data)) * 100,
                "mad_count": mad_outliers,
                "mad_percentage": (mad_outliers / len(data)) * 100,
                "lower_bound": lower,
                "upper_bound": upper,
                "outlier_severity": self._get_outlier_severity(iqr_outliers, len(data))
            }
        
        # Find columns with most outliers
        columns_by_outlier_count = sorted(
            [(col, info['iqr_count']) for col, info in outlier_analysis.items()],
            key=lambda x: x[1],
            reverse=True
        )
        
        return {
            "outlier_counts": outlier_analysis,
            "most_outlying_features": columns_by_outlier_count[:5],
            "total_outliers": sum(info['iqr_count'] for info in outlier_analysis.values())
        }
    
    def _get_outlier_severity(self, outlier_count: int, total: int) -> str:
        """Determine severity of outliers."""
        pct = (outlier_count / total) * 100
        if pct > 10:
            return "critical"
        elif pct > 5:
            return "high"
        elif pct > 2:
            return "medium"
        else:
            return "low"
    
    def _analyze_clusters(
        self,
        df: pd.DataFrame,
        column_types: Dict[str, str]
    ) -> Dict[str, Any]:
        """Analyze natural clusters in the data."""
        from sklearn.cluster import KMeans
        from sklearn.preprocessing import StandardScaler
        
        numeric_cols = [col for col, dtype in column_types.items() 
                       if dtype in ["numeric", "numeric_categorical"]]
        
        if len(numeric_cols) < 2:
            return {"message": "Need at least 2 numeric columns for clustering"}
        
        # Prepare data
        data = df[numeric_cols].dropna()
        if len(data) < 10:
            return {"message": "Too few rows for clustering"}
        
        # Scale data
        scaler = StandardScaler()
        scaled_data = scaler.fit_transform(data)
        
        # Find optimal number of clusters using elbow method
        inertias = []
        for k in range(2, min(11, len(data) - 1)):
            kmeans = KMeans(n_clusters=k, random_state=42, n_init=10)
            kmeans.fit(scaled_data)
            inertias.append(kmeans.inertia_)
        
        # Calculate elbow point
        if len(inertias) > 2:
            # Find the elbow using the "elbow method"
            # Compute the improvement percentage
            improvements = [1 - (inertias[i+1] / inertias[i]) for i in range(len(inertias)-1)]
            # The optimal K is where the improvement drops significantly
            optimal_k = np.argmin(improvements) + 2 if improvements else 2
        else:
            optimal_k = 2
        
        # Perform clustering with optimal K
        kmeans = KMeans(n_clusters=optimal_k, random_state=42, n_init=10)
        clusters = kmeans.fit_predict(scaled_data)
        
        # Analyze cluster characteristics
        cluster_sizes = pd.Series(clusters).value_counts().to_dict()
        cluster_characteristics = {}
        
        for cluster_id in range(optimal_k):
            cluster_mask = (clusters == cluster_id)
            cluster_data = data[cluster_mask]
            if len(cluster_data) > 0:
                cluster_characteristics[cluster_id] = {
                    "size": int(cluster_data.shape[0]),
                    "percentage": (cluster_data.shape[0] / len(data)) * 100,
                    "centroid": kmeans.cluster_centers_[cluster_id].tolist(),
                    "feature_means": cluster_data.mean().to_dict(),
                }
        
        return {
            "optimal_clusters": optimal_k,
            "cluster_sizes": cluster_sizes,
            "cluster_characteristics": cluster_characteristics,
            "inertia_values": inertias,
            "is_clusterable": optimal_k > 1
        }
    
    def _generate_insights(self, report: Dict[str, Any]) -> List[str]:
        """Generate insights from the analysis."""
        insights = []
        
        # Dataset insights
        info = report.get('dataset_info', {})
        if info.get('duplicate_percentage', 0) > 1:
            insights.append(
                f"Dataset contains {info.get('duplicate_rows')} duplicate rows "
                f"({info.get('duplicate_percentage'):.1f}% of data). Consider removing them."
            )
        
        # Missing insights
        missing = report.get('missing_analysis', {})
        if missing.get('columns_with_missing', 0) > 0:
            cols_with_missing = [col for col, rate in missing.get('missing_by_column', {}).items() 
                               if rate > 10]
            if cols_with_missing:
                insights.append(
                    f"Columns with high missing rates (>10%): {cols_with_missing}. "
                    "Consider imputation or dropping them."
                )
        
        # Target insights
        if 'target_analysis' in report:
            target = report['target_analysis']
            if target.get('problem_type') == 'classification':
                if not target.get('is_balanced', True):
                    ratio = target.get('balance_ratio', 1.0)
                    insights.append(
                        f"Target is imbalanced with class ratio {ratio:.2f}. "
                        "Consider using class weights or SMOTE."
                    )
            else:
                # Regression
                skew = target.get('skewness', 0)
                if abs(skew) > 1:
                    insights.append(
                        f"Target is highly skewed (skewness={skew:.2f}). "
                        "Consider log transformation."
                    )
        
        # Correlation insights
        corr = report.get('correlations', {})
        if corr.get('perfect_correlations'):
            pairs = corr['perfect_correlations'][:3]
            insights.append(
                f"Found {len(corr['perfect_correlations'])} pairs of perfectly correlated features. "
                "Remove one from each pair to reduce redundancy."
            )
        
        # Outlier insights
        if 'outliers' in report:
            outliers = report['outliers']
            critical_outliers = [
                (col, info['outlier_severity']) 
                for col, info in outliers.get('outlier_counts', {}).items()
                if info.get('outlier_severity') in ['critical', 'high']
            ]
            if critical_outliers:
                cols = [col for col, _ in critical_outliers[:3]]
                insights.append(
                    f"Columns with severe outliers: {cols}. "
                    "Consider winsorization or robust scaling."
                )
        
        # Dimensionality insights
        if 'multivariate' in report and 'pca' in report['multivariate']:
            pca = report['multivariate']['pca']
            n_components = pca.get('n_components_95', 0)
            if n_components > 0:
                insights.append(
                    f"PCA suggests {n_components} components capture 95% of variance "
                    f"({len(report.get('column_types', {}))} original features). "
                    "Consider dimensionality reduction."
                )
        
        return insights
    
    def _generate_recommendations(self, report: Dict[str, Any]) -> List[str]:
        """Generate actionable recommendations."""
        recommendations = []
        
        # Data cleaning recommendations
        info = report.get('dataset_info', {})
        if info.get('duplicate_percentage', 0) > 1:
            recommendations.append("Remove duplicate rows to prevent data leakage and bias.")
        
        # Missing data recommendations
        missing = report.get('missing_analysis', {})
        if missing.get('columns_with_missing', 0) > 0:
            recommendations.append(
                "Use median/mode imputation for columns with <20% missing. "
                "Consider dropping columns with >50% missing."
            )
        
        # Feature engineering recommendations
        univariate = report.get('univariate', {})
        
        # Check for highly skewed features
        skewed_features = []
        for col, stats in univariate.items():
            if stats.get('type') in ['numeric', 'numeric_categorical']:
                if abs(stats.get('skewness', 0)) > 1.5:
                    skewed_features.append(col)
        if skewed_features:
            recommendations.append(
                f"Apply log or Box-Cox transformation to skewed features: "
                f"{skewed_features[:5]}{'...' if len(skewed_features) > 5 else ''}"
            )
        
        # Check for high cardinality features
        high_cardinality = []
        for col, stats in univariate.items():
            if stats.get('cardinality_level') == 'very_high':
                high_cardinality.append(col)
        if high_cardinality:
            recommendations.append(
                f"Apply target encoding or frequency encoding to high-cardinality features: "
                f"{high_cardinality[:3]}{'...' if len(high_cardinality) > 3 else ''}"
            )
        
        # Correlation recommendations
        corr = report.get('correlations', {})
        if corr.get('high_correlations'):
            recommendations.append(
                f"Remove or merge highly correlated features ({len(corr['high_correlations'])} pairs) "
                "to reduce multicollinearity."
            )
        
        # Target-specific recommendations
        if 'target_analysis' in report:
            target = report['target_analysis']
            if target.get('problem_type') == 'classification':
                if not target.get('is_balanced', True):
                    recommendations.append(
                        "Use stratified cross-validation and class_weight='balanced' "
                        "to handle target imbalance."
                    )
            else:
                # Regression
                if abs(target.get('skewness', 0)) > 1:
                    recommendations.append(
                        "Apply log transformation to the target for better model performance."
                    )
        
        # Outlier recommendations
        if 'outliers' in report:
            outlier_cols = [col for col, info in report['outliers'].get('outlier_counts', {}).items()
                          if info.get('outlier_severity') == 'critical']
            if outlier_cols:
                recommendations.append(
                    f"Use robust scaling (RobustScaler) for columns with critical outliers: "
                    f"{outlier_cols[:3]}{'...' if len(outlier_cols) > 3 else ''}"
                )
        
        # Dimensionality recommendations
        if 'multivariate' in report and 'pca' in report['multivariate']:
            n_components = report['multivariate']['pca'].get('n_components_95', 0)
            if n_components > 0 and n_components < len(report.get('column_types', {})) * 0.7:
                recommendations.append(
                    "Consider using PCA with 95% variance retention for dimensionality reduction."
                )
        
        return recommendations
    
    def generate_summary(self, report: Dict[str, Any]) -> str:
        """Generate a human-readable summary of the analysis."""
        lines = []
        lines.append("=" * 70)
        lines.append("EXPLORATORY DATA ANALYSIS SUMMARY")
        lines.append("=" * 70)
        
        # Dataset overview
        info = report.get('dataset_info', {})
        lines.append(f"\n📊 Dataset Overview:")
        lines.append(f"   • Rows: {info.get('rows', 0):,}")
        lines.append(f"   • Columns: {info.get('columns', 0)}")
        lines.append(f"   • Memory: {info.get('memory_usage_mb', 0):.1f} MB")
        lines.append(f"   • Duplicates: {info.get('duplicate_rows', 0)}")
        
        # Column types
        types = report.get('column_types', {})
        type_counts = {}
        for dtype in types.values():
            type_counts[dtype] = type_counts.get(dtype, 0) + 1
        
        lines.append(f"\n📋 Column Types:")
        for dtype, count in type_counts.items():
            lines.append(f"   • {dtype}: {count}")
        
        # Missing data
        missing = report.get('missing_analysis', {})
        lines.append(f"\n🔍 Missing Data:")
        lines.append(f"   • Total Missing: {missing.get('total_missing', 0):,}")
        lines.append(f"   • Columns with Missing: {missing.get('columns_with_missing', 0)}")
        lines.append(f"   • Rows with Missing: {missing.get('rows_with_missing', 0)}")
        
        # Target analysis
        if 'target_analysis' in report:
            target = report['target_analysis']
            lines.append(f"\n🎯 Target Analysis ({self.target_col}):")
            lines.append(f"   • Type: {target.get('problem_type', 'unknown')}")
            if target.get('problem_type') == 'classification':
                lines.append(f"   • Classes: {len(target.get('class_counts', {}))}")
                lines.append(f"   • Balanced: {target.get('is_balanced', False)}")
                lines.append(f"   • Balance Ratio: {target.get('balance_ratio', 1.0):.2f}")
            else:
                lines.append(f"   • Skewness: {target.get('skewness', 0):.2f}")
                lines.append(f"   • Range: [{target.get('min', 0):.2f}, {target.get('max', 0):.2f}]")
        
        # Insights
        insights = report.get('insights', [])
        if insights:
            lines.append(f"\n💡 Key Insights:")
            for insight in insights:
                lines.append(f"   • {insight}")
        
        # Recommendations
        recommendations = report.get('recommendations', [])
        if recommendations:
            lines.append(f"\n✨ Recommendations:")
            for rec in recommendations:
                lines.append(f"   • {rec}")
        
        lines.append("\n" + "=" * 70)
        
        return "\n".join(lines)
    
    def save_report(self, report: Dict[str, Any], output_dir: Union[str, Path]) -> None:
        """
        Save the analysis report to files.
        
        Args:
            report: Analysis report dictionary
            output_dir: Directory to save the report
        """
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Save JSON report
        json_path = output_dir / "eda_report.json"
        with open(json_path, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        logger.info(f"Saved JSON report to: {json_path}")
        
        # Save summary text
        summary = self.generate_summary(report)
        summary_path = output_dir / "eda_summary.txt"
        with open(summary_path, 'w') as f:
            f.write(summary)
        logger.info(f"Saved summary to: {summary_path}")
```

#### Step 2: Visualization System

Now let's build a powerful visualization system that creates informative plots from our EDA.

**File:** `src/analysis/visualizations.py`
**Path:** `ml-pipeline-project/src/analysis/visualizations.py`

```python
"""
Advanced data visualization for exploratory analysis.
"""

import warnings
from typing import Dict, List, Optional, Union, Any, Tuple
from pathlib import Path
import math

import pandas as pd
import numpy as np
from loguru import logger
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore", category=UserWarning)

class DataVisualizer:
    """
    Creates publication-quality visualizations for exploratory data analysis.
    
    This class generates a comprehensive suite of plots including:
    - Distribution plots (histograms, KDE, box plots)
    - Correlation heatmaps
    - Pair plots (scatter plot matrix)
    - Feature-target relationships
    - Missing value visualizations
    - PCA visualizations
    - Categorical feature analysis
    
    Example:
        >>> visualizer = DataVisualizer()
        >>> visualizer.create_report(df, target_col="target", output_dir="reports/figures")
    """
    
    def __init__(
        self,
        style: str = "seaborn-v0_8-whitegrid",
        figsize: Tuple[int, int] = (12, 8),
        dpi: int = 100
    ):
        """
        Initialize the visualizer.
        
        Args:
            style: Matplotlib style to use
            figsize: Default figure size
            dpi: Default DPI for figures
        """
        self.style = style
        self.figsize = figsize
        self.dpi = dpi
        
        # Set default style
        plt.style.use(style)
        sns.set_palette("husl")
        
        logger.info("DataVisualizer initialized")
    
    def create_report(
        self,
        df: pd.DataFrame,
        target_col: Optional[str] = None,
        output_dir: Union[str, Path] = "reports/figures",
        max_features: int = 20
    ) -> Dict[str, List[Path]]:
        """
        Create a complete visualization report.
        
        Args:
            df: DataFrame to visualize
            target_col: Name of target column (if any)
            output_dir: Directory to save figures
            max_features: Maximum number of features to include in certain plots
            
        Returns:
            Dict: Mapping of plot types to file paths
        """
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Creating visualization report in: {output_dir}")
        
        created_files = {}
        
        # 1. Dataset overview
        files = self._create_overview(df, output_dir)
        created_files["overview"] = files
        
        # 2. Distribution analysis
        files = self._create_distribution_plots(df, output_dir, max_features)
        created_files["distributions"] = files
        
        # 3. Missing value analysis
        files = self._create_missing_plots(df, output_dir)
        created_files["missing"] = files
        
        # 4. Correlation analysis
        files = self._create_correlation_plots(df, output_dir)
        created_files["correlation"] = files
        
        # 5. Target analysis (if target specified)
        if target_col and target_col in df.columns:
            files = self._create_target_plots(df, target_col, output_dir)
            created_files["target"] = files
        
        # 6. Categorical feature analysis
        files = self._create_categorical_plots(df, output_dir, max_features)
        created_files["categorical"] = files
        
        # 7. Pairwise relationships (top features)
        files = self._create_pairwise_plots(df, target_col, output_dir, max_features)
        created_files["pairwise"] = files
        
        # 8. PCA visualization (if sufficient numeric features)
        files = self._create_pca_plots(df, target_col, output_dir)
        created_files["pca"] = files
        
        logger.success(f"Visualization report complete. Created {len(created_files)} plot categories.")
        
        return created_files
    
    def _create_overview(self, df: pd.DataFrame, output_dir: Path) -> List[Path]:
        """Create overview visualizations."""
        files = []
        
        # Overview dashboard
        fig, axes = plt.subplots(2, 2, figsize=(14, 10))
        
        # 1. Feature types distribution
        dtype_counts = df.dtypes.value_counts()
        axes[0, 0].pie(dtype_counts.values, labels=dtype_counts.index.astype(str), autopct='%1.1f%%')
        axes[0, 0].set_title('Data Types Distribution')
        
        # 2. Missing values overview
        missing_pct = (df.isnull().sum() / len(df)) * 100
        missing_pct = missing_pct[missing_pct > 0].sort_values(ascending=False)
        if len(missing_pct) > 0:
            missing_pct.plot(kind='bar', ax=axes[0, 1])
            axes[0, 1].set_title('Missing Values by Column')
            axes[0, 1].set_xlabel('Columns')
            axes[0, 1].set_ylabel('Missing Percentage (%)')
        else:
            axes[0, 1].text(0.5, 0.5, 'No Missing Values', 
                          ha='center', va='center', transform=axes[0, 1].transAxes)
            axes[0, 1].set_title('Missing Values')
        
        # 3. Dataset size
        axes[1, 0].text(0.1, 0.7, f"Rows: {len(df):,}", fontsize=24, transform=axes[1, 0].transAxes)
        axes[1, 0].text(0.1, 0.5, f"Columns: {len(df.columns):,}", fontsize=24, transform=axes[1, 0].transAxes)
        axes[1, 0].text(0.1, 0.3, f"Memory: {df.memory_usage(deep=True).sum() / 1024**2:.1f} MB", 
                       fontsize=24, transform=axes[1, 0].transAxes)
        axes[1, 0].set_title('Dataset Statistics')
        axes[1, 0].axis('off')
        
        # 4. Duplicate analysis
        dup_count = df.duplicated().sum()
        axes[1, 1].pie([dup_count, len(df) - dup_count], 
                      labels=['Duplicates', 'Unique'], 
                      autopct='%1.1f%%',
                      colors=['#ff6b6b', '#51cf66'])
        axes[1, 1].set_title(f'Duplicate Rows ({dup_count} total)')
        
        plt.tight_layout()
        filepath = output_dir / "overview.png"
        fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
        files.append(filepath)
        plt.close(fig)
        
        return files
    
    def _create_distribution_plots(
        self, 
        df: pd.DataFrame, 
        output_dir: Path,
        max_features: int
    ) -> List[Path]:
        """Create distribution plots for features."""
        files = []
        
        # Get numeric columns
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        if numeric_cols:
            # Limit number of columns for display
            cols_to_plot = numeric_cols[:max_features]
            n_cols = min(len(cols_to_plot), 4)
            n_rows = math.ceil(len(cols_to_plot) / n_cols)
            
            # Create histogram grid
            fig, axes = plt.subplots(n_rows, n_cols, figsize=(4*n_cols, 3*n_rows))
            if n_rows == 1 and n_cols == 1:
                axes = [[axes]]
            elif n_rows == 1:
                axes = [axes]
            elif n_cols == 1:
                axes = [[ax] for ax in axes]
            
            for idx, col in enumerate(cols_to_plot):
                row = idx // n_cols
                col_idx = idx % n_cols
                ax = axes[row][col_idx] if n_rows > 1 else axes[col_idx]
                
                # Plot histogram with KDE
                ax.hist(df[col].dropna(), bins=30, density=True, alpha=0.6, color='steelblue')
                sns.kdeplot(df[col].dropna(), ax=ax, color='darkred')
                ax.set_title(f'{col}')
                ax.set_xlabel('')
                ax.grid(True, alpha=0.3)
            
            # Hide unused subplots
            for idx in range(len(cols_to_plot), n_rows * n_cols):
                row = idx // n_cols
                col_idx = idx % n_cols
                if n_rows > 1:
                    axes[row][col_idx].set_visible(False)
                else:
                    axes[col_idx].set_visible(False)
            
            plt.tight_layout()
            filepath = output_dir / "distributions_histograms.png"
            fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
            files.append(filepath)
            plt.close(fig)
            
            # Box plots for numeric columns
            if len(numeric_cols) <= 20:
                fig, ax = plt.subplots(figsize=(12, 0.4 * len(numeric_cols) + 2))
                melted_data = pd.melt(df[numeric_cols], var_name='Feature', value_name='Value')
                sns.boxplot(data=melted_data, x='Value', y='Feature', ax=ax)
                ax.set_title('Distribution of Numeric Features (Box Plots)')
                ax.grid(True, alpha=0.3)
                plt.tight_layout()
                filepath = output_dir / "distributions_boxplots.png"
                fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
                files.append(filepath)
                plt.close(fig)
        
        # Categorical columns - bar charts
        cat_cols = df.select_dtypes(include=['object', 'category']).columns.tolist()
        if cat_cols:
            cols_to_plot = cat_cols[:min(len(cat_cols), 6)]
            n_cols = min(len(cols_to_plot), 3)
            n_rows = math.ceil(len(cols_to_plot) / n_cols)
            
            fig, axes = plt.subplots(n_rows, n_cols, figsize=(5*n_cols, 4*n_rows))
            if n_rows == 1 and n_cols == 1:
                axes = [[axes]]
            elif n_rows == 1:
                axes = [axes]
            elif n_cols == 1:
                axes = [[ax] for ax in axes]
            
            for idx, col in enumerate(cols_to_plot):
                row = idx // n_cols
                col_idx = idx % n_cols
                ax = axes[row][col_idx] if n_rows > 1 else axes[col_idx]
                
                value_counts = df[col].value_counts().head(10)
                value_counts.plot(kind='bar', ax=ax)
                ax.set_title(f'{col} (top 10)')
                ax.set_xlabel('')
                ax.tick_params(axis='x', rotation=45)
            
            # Hide unused subplots
            for idx in range(len(cols_to_plot), n_rows * n_cols):
                row = idx // n_cols
                col_idx = idx % n_cols
                if n_rows > 1:
                    axes[row][col_idx].set_visible(False)
                else:
                    axes[col_idx].set_visible(False)
            
            plt.tight_layout()
            filepath = output_dir / "categorical_distributions.png"
            fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
            files.append(filepath)
            plt.close(fig)
        
        return files
    
    def _create_missing_plots(self, df: pd.DataFrame, output_dir: Path) -> List[Path]:
        """Create missing value visualizations."""
        files = []
        
        # Missing value matrix
        fig, ax = plt.subplots(figsize=(12, 6))
        missing_matrix = df.isnull()
        sns.heatmap(missing_matrix, cbar=True, yticklabels=False, cmap='viridis', ax=ax)
        ax.set_title('Missing Value Pattern')
        plt.tight_layout()
        filepath = output_dir / "missing_matrix.png"
        fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
        files.append(filepath)
        plt.close(fig)
        
        # Missing value percentage bar chart
        missing_pct = (df.isnull().sum() / len(df)) * 100
        missing_pct = missing_pct[missing_pct > 0].sort_values(ascending=False)
        
        if len(missing_pct) > 0:
            fig, ax = plt.subplots(figsize=(10, 0.5 * len(missing_pct) + 1))
            missing_pct.plot(kind='barh', ax=ax, color='coral')
            ax.set_title('Missing Value Percentage by Column')
            ax.set_xlabel('Missing Percentage (%)')
            ax.axvline(x=10, color='orange', linestyle='--', label='Warning (10%)')
            ax.axvline(x=30, color='red', linestyle='--', label='Critical (30%)')
            ax.legend()
            plt.tight_layout()
            filepath = output_dir / "missing_percentage.png"
            fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
            files.append(filepath)
            plt.close(fig)
        
        return files
    
    def _create_correlation_plots(self, df: pd.DataFrame, output_dir: Path) -> List[Path]:
        """Create correlation visualizations."""
        files = []
        
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        if len(numeric_cols) > 1:
            # Correlation heatmap
            fig, ax = plt.subplots(figsize=(10, 8))
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
                ax=ax,
                square=True
            )
            ax.set_title('Feature Correlation Heatmap')
            plt.tight_layout()
            filepath = output_dir / "correlation_heatmap.png"
            fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
            files.append(filepath)
            plt.close(fig)
            
            # Correlation dendrogram (if enough features)
            if len(numeric_cols) > 3:
                from scipy.cluster import hierarchy
                
                fig, ax = plt.subplots(figsize=(12, 8))
                linkage = hierarchy.linkage(corr.values, method='ward')
                dendro = hierarchy.dendrogram(linkage, labels=corr.columns, ax=ax)
                ax.set_title('Feature Clustering (Correlation-based)')
                ax.set_xlabel('Features')
                ax.set_ylabel('Distance')
                plt.tight_layout()
                filepath = output_dir / "correlation_dendrogram.png"
                fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
                files.append(filepath)
                plt.close(fig)
        
        return files
    
    def _create_target_plots(
        self, 
        df: pd.DataFrame, 
        target_col: str, 
        output_dir: Path
    ) -> List[Path]:
        """Create target-specific visualizations."""
        files = []
        
        target_data = df[target_col].dropna()
        
        # Check if target is numeric or categorical
        if pd.api.types.is_numeric_dtype(target_data):
            # Distribution of target
            fig, axes = plt.subplots(1, 2, figsize=(12, 5))
            
            # Histogram
            axes[0].hist(target_data, bins=30, edgecolor='black', alpha=0.7)
            axes[0].set_title(f'Distribution of {target_col}')
            axes[0].set_xlabel(target_col)
            axes[0].set_ylabel('Frequency')
            
            # Box plot
            axes[1].boxplot(target_data, vert=False)
            axes[1].set_title(f'Box Plot of {target_col}')
            axes[1].set_xlabel(target_col)
            
            plt.tight_layout()
            filepath = output_dir / "target_distribution.png"
            fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
            files.append(filepath)
            plt.close(fig)
            
            # Feature-target relationships (scatter plots)
            numeric_features = df.select_dtypes(include=[np.number]).columns.tolist()
            numeric_features = [f for f in numeric_features if f != target_col]
            
            if numeric_features:
                # Select top features (based on correlation)
                corr_vals = df[numeric_features + [target_col]].corr()[target_col].drop(target_col)
                top_features = corr_vals.abs().sort_values(ascending=False).head(6).index.tolist()
                
                n_cols = min(len(top_features), 3)
                n_rows = math.ceil(len(top_features) / n_cols)
                
                fig, axes = plt.subplots(n_rows, n_cols, figsize=(5*n_cols, 4*n_rows))
                if n_rows == 1 and n_cols == 1:
                    axes = [[axes]]
                elif n_rows == 1:
                    axes = [axes]
                elif n_cols == 1:
                    axes = [[ax] for ax in axes]
                
                for idx, feature in enumerate(top_features):
                    row = idx // n_cols
                    col_idx = idx % n_cols
                    ax = axes[row][col_idx] if n_rows > 1 else axes[col_idx]
                    
                    ax.scatter(df[feature], df[target_col], alpha=0.5, s=10)
                    ax.set_xlabel(feature)
                    ax.set_ylabel(target_col)
                    ax.set_title(f'{feature} vs {target_col}')
                    ax.grid(True, alpha=0.3)
                
                # Hide unused subplots
                for idx in range(len(top_features), n_rows * n_cols):
                    row = idx // n_cols
                    col_idx = idx % n_cols
                    if n_rows > 1:
                        axes[row][col_idx].set_visible(False)
                    else:
                        axes[col_idx].set_visible(False)
                
                plt.tight_layout()
                filepath = output_dir / "target_scatter_plots.png"
                fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
                files.append(filepath)
                plt.close(fig)
        
        else:
            # Categorical target
            fig, axes = plt.subplots(1, 2, figsize=(12, 5))
            
            # Bar chart of target counts
            value_counts = target_data.value_counts()
            value_counts.plot(kind='bar', ax=axes[0])
            axes[0].set_title(f'Distribution of {target_col}')
            axes[0].set_xlabel(target_col)
            axes[0].set_ylabel('Count')
            axes[0].tick_params(axis='x', rotation=45)
            
            # Pie chart
            axes[1].pie(value_counts.values, labels=value_counts.index, autopct='%1.1f%%')
            axes[1].set_title('Class Proportions')
            
            plt.tight_layout()
            filepath = output_dir / "target_categorical.png"
            fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
            files.append(filepath)
            plt.close(fig)
        
        return files
    
    def _create_categorical_plots(
        self, 
        df: pd.DataFrame, 
        output_dir: Path,
        max_features: int
    ) -> List[Path]:
        """Create categorical feature visualizations."""
        files = []
        
        cat_cols = df.select_dtypes(include=['object', 'category']).columns.tolist()
        
        if cat_cols:
            cols_to_plot = cat_cols[:min(len(cat_cols), max_features)]
            n_cols = min(len(cols_to_plot), 3)
            n_rows = math.ceil(len(cols_to_plot) / n_cols)
            
            if n_rows > 0 and n_cols > 0:
                fig, axes = plt.subplots(n_rows, n_cols, figsize=(5*n_cols, 4*n_rows))
                if n_rows == 1 and n_cols == 1:
                    axes = [[axes]]
                elif n_rows == 1:
                    axes = [axes]
                elif n_cols == 1:
                    axes = [[ax] for ax in axes]
                
                for idx, col in enumerate(cols_to_plot):
                    row = idx // n_cols
                    col_idx = idx % n_cols
                    ax = axes[row][col_idx] if n_rows > 1 else axes[col_idx]
                    
                    value_counts = df[col].value_counts().head(10)
                    value_counts.plot(kind='barh', ax=ax, color='steelblue')
                    ax.set_title(f'{col} (top 10)')
                    ax.set_xlabel('Count')
                    
                    # Add count labels
                    for i, (v, count) in enumerate(value_counts.items()):
                        ax.text(count + 0.5, i, str(count), va='center')
                
                # Hide unused subplots
                for idx in range(len(cols_to_plot), n_rows * n_cols):
                    row = idx // n_cols
                    col_idx = idx % n_cols
                    if n_rows > 1:
                        axes[row][col_idx].set_visible(False)
                    else:
                        axes[col_idx].set_visible(False)
                
                plt.tight_layout()
                filepath = output_dir / "categorical_features.png"
                fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
                files.append(filepath)
                plt.close(fig)
        
        return files
    
    def _create_pairwise_plots(
        self,
        df: pd.DataFrame,
        target_col: Optional[str],
        output_dir: Path,
        max_features: int
    ) -> List[Path]:
        """Create pairwise relationship plots."""
        files = []
        
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        if len(numeric_cols) > 1:
            # Select top features (based on correlation with target if available)
            if target_col and target_col in numeric_cols:
                corr_vals = df[numeric_cols].corr()[target_col].drop(target_col)
                top_features = corr_vals.abs().sort_values(ascending=False).head(5).index.tolist()
                if target_col not in top_features:
                    top_features = [target_col] + top_features
            else:
                # Select top 5 numeric features
                top_features = numeric_cols[:5]
            
            # Create pairplot
            if len(top_features) >= 2 and len(top_features) <= 10:
                fig = sns.pairplot(df[top_features], diag_kind='kde', corner=True)
                filepath = output_dir / "pairplot.png"
                fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
                files.append(filepath)
                plt.close(fig)
        
        return files
    
    def _create_pca_plots(
        self,
        df: pd.DataFrame,
        target_col: Optional[str],
        output_dir: Path
    ) -> List[Path]:
        """Create PCA visualizations."""
        files = []
        
        numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        # Remove target from numeric columns for PCA
        if target_col in numeric_cols:
            numeric_cols.remove(target_col)
        
        if len(numeric_cols) >= 2:
            # Prepare data
            data = df[numeric_cols].dropna()
            if len(data) > 0:
                try:
                    # Scale data
                    scaler = StandardScaler()
                    scaled_data = scaler.fit_transform(data)
                    
                    # Apply PCA
                    pca = PCA(n_components=2)
                    pca_result = pca.fit_transform(scaled_data)
                    
                    # Create scatter plot
                    fig, ax = plt.subplots(figsize=(10, 8))
                    
                    if target_col and target_col in df.columns:
                        # Color by target
                        target_data = df.loc[data.index, target_col]
                        if pd.api.types.is_numeric_dtype(target_data):
                            scatter = ax.scatter(pca_result[:, 0], pca_result[:, 1], 
                                               c=target_data, cmap='viridis', alpha=0.6)
                            plt.colorbar(scatter, label=target_col)
                        else:
                            # Categorical target
                            unique_targets = target_data.unique()
                            colors = plt.cm.tab10(np.linspace(0, 1, len(unique_targets)))
                            for target_val, color in zip(unique_targets, colors):
                                mask = target_data == target_val
                                ax.scatter(pca_result[mask, 0], pca_result[mask, 1],
                                         c=[color], label=str(target_val), alpha=0.6)
                            ax.legend()
                    else:
                        # No target
                        ax.scatter(pca_result[:, 0], pca_result[:, 1], alpha=0.6)
                    
                    ax.set_xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.2%} variance)')
                    ax.set_ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.2%} variance)')
                    ax.set_title('PCA Projection')
                    ax.grid(True, alpha=0.3)
                    
                    plt.tight_layout()
                    filepath = output_dir / "pca_plot.png"
                    fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
                    files.append(filepath)
                    plt.close(fig)
                    
                    # Explained variance
                    fig, ax = plt.subplots(figsize=(10, 6))
                    n_components = min(10, len(numeric_cols))
                    pca_full = PCA(n_components=n_components)
                    pca_full.fit(scaled_data)
                    
                    explained_variance = pca_full.explained_variance_ratio_
                    cumulative_variance = np.cumsum(explained_variance)
                    
                    ax.bar(range(1, len(explained_variance) + 1), explained_variance, 
                          alpha=0.6, label='Individual')
                    ax.plot(range(1, len(explained_variance) + 1), cumulative_variance, 
                           'ro-', label='Cumulative')
                    ax.set_xlabel('Principal Component')
                    ax.set_ylabel('Explained Variance Ratio')
                    ax.set_title('PCA Explained Variance')
                    ax.axhline(y=0.95, color='green', linestyle='--', label='95% Threshold')
                    ax.legend()
                    ax.grid(True, alpha=0.3)
                    
                    plt.tight_layout()
                    filepath = output_dir / "pca_variance.png"
                    fig.savefig(filepath, dpi=self.dpi, bbox_inches='tight')
                    files.append(filepath)
                    plt.close(fig)
                    
                except Exception as e:
                    logger.warning(f"PCA visualization failed: {str(e)}")
        
        return files
```

#### Step 3: Report Generator

Now let's create a unified report generator that combines our EDA results into a professional HTML report.

**File:** `src/analysis/reports.py`
**Path:** `ml-pipeline-project/src/analysis/reports.py`

```python
"""
EDA report generation module.
Creates professional HTML reports from EDA results.
"""

import json
from pathlib import Path
from typing import Dict, Any, Optional
from datetime import datetime

from loguru import logger

class EDAReportGenerator:
    """
    Generates comprehensive HTML reports from EDA results.
    
    This class creates a self-contained HTML report with:
    - Executive summary
    - Interactive visualizations
    - Statistical summaries
    - Key insights and recommendations
    - Data quality assessment
    """
    
    def __init__(self, template_dir: Optional[Path] = None):
        """
        Initialize the report generator.
        
        Args:
            template_dir: Directory containing HTML templates
        """
        self.template_dir = template_dir or Path(__file__).parent / "templates"
        logger.info("EDAReportGenerator initialized")
    
    def generate(
        self,
        eda_results: Dict[str, Any],
        output_path: Union[str, Path],
        title: str = "EDA Report"
    ) -> Path:
        """
        Generate an HTML report from EDA results.
        
        Args:
            eda_results: Results from ExploratoryDataAnalyzer
            output_path: Path to save the HTML report
            title: Report title
            
        Returns:
            Path: Path to the generated report
        """
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Generating EDA report at: {output_path}")
        
        # Build the report content
        html_content = self._build_html(eda_results, title)
        
        # Write the file
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        logger.success(f"EDA report generated: {output_path}")
        return output_path
    
    def _build_html(self, results: Dict[str, Any], title: str) -> str:
        """Build the HTML content."""
        
        # Extract key information
        info = results.get('dataset_info', {})
        univariate = results.get('univariate', {})
        missing = results.get('missing_analysis', {})
        corr = results.get('correlations', {})
        insights = results.get('insights', [])
        recommendations = results.get('recommendations', [])
        
        # Count column types
        col_types = results.get('column_types', {})
        type_counts = {}
        for dtype in col_types.values():
            type_counts[dtype] = type_counts.get(dtype, 0) + 1
        
        # Build HTML
        html = f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>{title}</title>
            <style>
                * {{ margin: 0; padding: 0; box-sizing: border-box; }}
                body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; background: #f5f7fa; }}
                .container {{ max-width: 1200px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px; border-radius: 12px; margin-bottom: 30px; }}
                .header h1 {{ font-size: 2.5em; margin-bottom: 10px; }}
                .header .subtitle {{ opacity: 0.9; font-size: 1.1em; }}
                .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 20px 0; }}
                .card {{ background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }}
                .card h3 {{ color: #667eea; margin-bottom: 15px; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px; }}
                .metric {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }}
                .metric:last-child {{ border-bottom: none; }}
                .metric-label {{ font-weight: 500; }}
                .metric-value {{ color: #764ba2; font-weight: bold; }}
                .insight {{ background: #e8f4fd; border-left: 4px solid #667eea; padding: 12px 16px; margin: 8px 0; border-radius: 4px; }}
                .recommendation {{ background: #f0fdf4; border-left: 4px solid #22c55e; padding: 12px 16px; margin: 8px 0; border-radius: 4px; }}
                .warning {{ background: #fef3c7; border-left: 4px solid #f59e0b; padding: 12px 16px; margin: 8px 0; border-radius: 4px; }}
                .critical {{ background: #fee2e2; border-left: 4px solid #ef4444; padding: 12px 16px; margin: 8px 0; border-radius: 4px; }}
                .section {{ margin: 30px 0; }}
                .section-title {{ font-size: 1.8em; color: #2d3748; margin-bottom: 20px; }}
                table {{ width: 100%; border-collapse: collapse; margin: 10px 0; }}
                th, td {{ padding: 10px; text-align: left; border-bottom: 1px solid #e2e8f0; }}
                th {{ background: #f7fafc; font-weight: 600; color: #2d3748; }}
                tr:hover {{ background: #f7fafc; }}
                .badge {{ display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; font-weight: 600; }}
                .badge-success {{ background: #def7ec; color: #03543f; }}
                .badge-warning {{ background: #fef3c7; color: #92400e; }}
                .badge-danger {{ background: #fee2e2; color: #991b1b; }}
                @media (max-width: 768px) {{ .header {{ padding: 20px; }} .header h1 {{ font-size: 1.8em; }} }}
            </style>
        </head>
        <body>
            <div class="container">
                <!-- Header -->
                <div class="header">
                    <h1>{title}</h1>
                    <div class="subtitle">Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</div>
                    <div class="subtitle">Dataset: {info.get('rows', 0):,} rows, {info.get('columns', 0)} columns</div>
                </div>
                
                <!-- Dataset Overview -->
                <div class="section">
                    <h2 class="section-title">📊 Dataset Overview</h2>
                    <div class="grid">
                        <div class="card">
                            <h3>Statistics</h3>
                            <div class="metric"><span class="metric-label">Rows</span><span class="metric-value">{info.get('rows', 0):,}</span></div>
                            <div class="metric"><span class="metric-label">Columns</span><span class="metric-value">{info.get('columns', 0)}</span></div>
                            <div class="metric"><span class="metric-label">Memory Usage</span><span class="metric-value">{info.get('memory_usage_mb', 0):.1f} MB</span></div>
                            <div class="metric"><span class="metric-label">Duplicate Rows</span><span class="metric-value">{info.get('duplicate_rows', 0)} ({info.get('duplicate_percentage', 0):.1f}%)</span></div>
                        </div>
                        <div class="card">
                            <h3>Column Types</h3>
                            {''.join(f'<div class="metric"><span class="metric-label">{dtype}</span><span class="metric-value">{count}</span></div>' for dtype, count in type_counts.items())}
                        </div>
                        <div class="card">
                            <h3>Data Quality</h3>
                            <div class="metric"><span class="metric-label">Total Missing</span><span class="metric-value">{missing.get('total_missing', 0):,}</span></div>
                            <div class="metric"><span class="metric-label">Missing %</span><span class="metric-value">{missing.get('total_missing_percentage', 0):.1f}%</span></div>
                            <div class="metric"><span class="metric-label">Columns with Missing</span><span class="metric-value">{missing.get('columns_with_missing', 0)}</span></div>
                            <div class="metric"><span class="metric-label">Rows with Missing</span><span class="metric-value">{missing.get('rows_with_missing', 0)}</span></div>
                        </div>
                    </div>
                </div>
        """
        
        # Insights
        if insights:
            html += f"""
                <div class="section">
                    <h2 class="section-title">💡 Key Insights</h2>
                    {''.join(f'<div class="insight">{insight}</div>' for insight in insights[:10])}
                </div>
            """
        
        # Recommendations
        if recommendations:
            html += f"""
                <div class="section">
                    <h2 class="section-title">✨ Recommendations</h2>
                    {''.join(f'<div class="recommendation">{rec}</div>' for rec in recommendations[:10])}
                </div>
            """
        
        # Numeric Features Summary
        numeric_cols = [col for col, stats in univariate.items() 
                       if stats.get('type') in ['numeric', 'numeric_categorical']]
        if numeric_cols:
            html += f"""
                <div class="section">
                    <h2 class="section-title">📈 Numeric Features Summary</h2>
                    <div style="overflow-x: auto;">
                        <table>
                            <thead>
                                <tr>
                                    <th>Feature</th>
                                    <th>Count</th>
                                    <th>Mean</th>
                                    <th>Std</th>
                                    <th>Min</th>
                                    <th>Q1</th>
                                    <th>Median</th>
                                    <th>Q3</th>
                                    <th>Max</th>
                                    <th>Skew</th>
                                    <th>Missing %</th>
                                </tr>
                            </thead>
                            <tbody>
            """
            
            for col in numeric_cols[:20]:  # Limit to 20 for display
                stats = univariate[col]
                html += f"""
                    <tr>
                        <td><strong>{col}</strong></td>
                        <td>{len(df[col].dropna()):,}</td>
                        <td>{stats.get('mean', 'N/A')}</td>
                        <td>{stats.get('std', 'N/A')}</td>
                        <td>{stats.get('min', 'N/A')}</td>
                        <td>{stats.get('q1', 'N/A')}</td>
                        <td>{stats.get('median', 'N/A')}</td>
                        <td>{stats.get('q3', 'N/A')}</td>
                        <td>{stats.get('max', 'N/A')}</td>
                        <td>{stats.get('skewness', 'N/A'):.2f}</td>
                        <td>{stats.get('null_percentage', 0):.1f}%</td>
                    </tr>
                """
            
            html += """
                            </tbody>
                        </table>
                    </div>
                </div>
            """
        
        # Categorical Features Summary
        cat_cols = [col for col, stats in univariate.items() 
                   if stats.get('type') in ['categorical', 'high_cardinality_categorical']]
        if cat_cols:
            html += f"""
                <div class="section">
                    <h2 class="section-title">🏷️ Categorical Features Summary</h2>
                    <div style="overflow-x: auto;">
                        <table>
                            <thead>
                                <tr>
                                    <th>Feature</th>
                                    <th>Unique Values</th>
                                    <th>Cardinality</th>
                                    <th>Most Frequent</th>
                                    <th>Frequency %</th>
                                    <th>Missing %</th>
                                </tr>
                            </thead>
                            <tbody>
            """
            
            for col in cat_cols[:20]:
                stats = univariate[col]
                html += f"""
                    <tr>
                        <td><strong>{col}</strong></td>
                        <td>{stats.get('unique_count', 0):,}</td>
                        <td><span class="badge badge-{'warning' if stats.get('cardinality_level') == 'high' else 'danger' if stats.get('cardinality_level') == 'very_high' else 'success'}">{stats.get('cardinality_level', 'low')}</span></td>
                        <td>{stats.get('most_frequent', 'N/A')}</td>
                        <td>{stats.get('most_frequent_percentage', 0):.1f}%</td>
                        <td>{stats.get('null_percentage', 0):.1f}%</td>
                    </tr>
                """
            
            html += """
                            </tbody>
                        </table>
                    </div>
                </div>
            """
        
        # Correlation Analysis
        if corr.get('high_correlations') or corr.get('perfect_correlations'):
            html += f"""
                <div class="section">
                    <h2 class="section-title">🔗 Correlation Analysis</h2>
            """
            
            if corr.get('perfect_correlations'):
                html += f"""
                    <div class="critical">
                        <strong>⚠️ Perfect Correlations ({len(corr['perfect_correlations'])} pairs):</strong><br>
                        {', '.join(f"{p['col1']} ↔ {p['col2']} (r={p['correlation']:.3f})" for p in corr['perfect_correlations'][:5])}
                    </div>
                """
            
            if corr.get('high_correlations'):
                html += f"""
                    <div class="warning">
                        <strong>⚠️ High Correlations ({len(corr['high_correlations'])} pairs):</strong><br>
                        {', '.join(f"{p['col1']} ↔ {p['col2']} (r={p['correlation']:.3f})" for p in corr['high_correlations'][:5])}
                    </div>
                """
            
            if corr.get('negative_correlations'):
                html += f"""
                    <div class="insight">
                        <strong>Negative Correlations ({len(corr['negative_correlations'])} pairs):</strong><br>
                        {', '.join(f"{p['col1']} ↔ {p['col2']} (r={p['correlation']:.3f})" for p in corr['negative_correlations'][:5])}
                    </div>
                """
            
            html += "</div>"
        
        html += """
            </div>
        </body>
        </html>
        """
        
        return html
```

### The Verification: Testing Our EDA System

Now let's verify everything works.

#### Test 1: Run EDA on Our Test Data

```bash
cat > test_eda.py << 'EOF'
import pandas as pd
from pathlib import Path
from loguru import logger

from src.analysis.eda import ExploratoryDataAnalyzer
from src.analysis.visualizations import DataVisualizer
from src.analysis.reports import EDAReportGenerator

# Load the test data
df = pd.read_csv("data/raw/test_data.csv")
logger.info(f"Loaded {len(df)} rows")

# Create EDA instance
eda = ExploratoryDataAnalyzer(
    target_col=None,  # No target specified for now
    categorical_threshold=10
)

# Perform analysis
report = eda.analyze(df, deep_analysis=True)

# Print summary
summary = eda.generate_summary(report)
print(summary)

# Save the report
eda.save_report(report, "reports/eda")

# Create visualizations
visualizer = DataVisualizer()
visualizer.create_report(df, output_dir="reports/figures")

# Generate HTML report
report_generator = EDAReportGenerator()
report_generator.generate(report, "reports/eda_report.html", title="Test Dataset EDA Report")

print("\n✅ EDA complete! Check:")
print("  - reports/eda/eda_report.json (raw data)")
print("  - reports/eda/eda_summary.txt (summary)")
print("  - reports/figures/*.png (visualizations)")
print("  - reports/eda_report.html (HTML report)")
EOF

python test_eda.py
```

#### Test 2: EDA with Target Analysis

```bash
cat > test_eda_with_target.py << 'EOF'
import pandas as pd
from src.analysis.eda import ExploratoryDataAnalyzer

# Load data
df = pd.read_csv("data/raw/test_data.csv")

# Add a synthetic target
import numpy as np
np.random.seed(42)
df['target'] = (df['value'] > 100).astype(int)  # Binary target based on value
df['target'] = df['target'] ^ (np.random.random(len(df)) < 0.1)  # Add some noise

# Create EDA with target
eda = ExploratoryDataAnalyzer(target_col='target')

# Analyze
report = eda.analyze(df, deep_analysis=True)

# Print summary
print(eda.generate_summary(report))

# Save report
eda.save_report(report, "reports/eda_with_target")

# Generate HTML report
from src.analysis.reports import EDAReportGenerator
report_generator = EDAReportGenerator()
report_generator.generate(report, "reports/eda_report_with_target.html", 
                         title="EDA Report with Target Analysis")

print("\n✅ EDA with target complete!")
EOF

python test_eda_with_target.py
```

#### Test 3: View the Report

```bash
# On Linux/Mac
open reports/eda_report.html

# On Windows
start reports/eda_report.html
```

### What Just Happened: Understanding EDA

Let's dive into what our EDA system does and why it matters.

#### The Four Pillars of EDA

Our EDA system is built on four fundamental pillars:

**1. Univariate Analysis**
This examines each variable in isolation. We look at:
- **Central tendency**: Mean, median, mode
- **Spread**: Standard deviation, IQR, range
- **Shape**: Skewness, kurtosis
- **Missing values**: How much, where, patterns

**2. Bivariate Analysis**
This examines relationships between two variables:
- **Numeric-Numeric**: Correlation (Pearson, Spearman)
- **Numeric-Categorical**: ANOVA, Kruskal-Wallis
- **Categorical-Categorical**: Chi-square, Cramér's V

**3. Multivariate Analysis**
This examines relationships between many variables:
- **Principal Component Analysis**: Dimensionality reduction
- **Clustering**: Natural groupings in the data
- **Feature interactions**: How features work together

**4. Target Analysis**
If we have a target variable:
- **Classification**: Class balance, per-class statistics
- **Regression**: Distribution, skewness, outliers
- **Feature-target importance**: Which features matter most

#### Understanding Our Analysis Metrics

**Skewness** measures asymmetry in the distribution:
- `skewness = 0`: Symmetric (like a normal distribution)
- `skewness > 0`: Right-skewed (long tail to the right)
- `skewness < 0`: Left-skewed (long tail to the left)
- **Impact**: High skewness can affect model performance; consider transformations

**Kurtosis** measures tail heaviness:
- `kurtosis = 0`: Normal distribution
- `kurtosis > 0`: Heavy tails (more outliers)
- `kurtosis < 0`: Light tails (fewer outliers)
- **Impact**: High kurtosis means more extreme values; consider robust methods

**Cramér's V** measures association between categorical variables:
- `0`: No association
- `1`: Perfect association
- **Impact**: Helps identify redundant categorical features

**PCA Explained Variance** tells us how many features we really need:
- 95% variance in 5 components instead of 50 features
- **Impact**: Dimensionality reduction opportunities

### Troubleshooting Common Issues

#### Issue: "No module named 'sklearn'"

Install scikit-learn:
```bash
pip install scikit-learn
```

#### Issue: Missing plots in report

Make sure you have matplotlib and seaborn installed:
```bash
pip install matplotlib seaborn
```

#### Issue: Memory errors with large datasets

For large datasets, sample the data:
```python
df_sample = df.sample(n=10000)  # Use 10k rows for EDA
report = eda.analyze(df_sample)
```

#### Issue: Long processing time

Disable deep analysis for faster results:
```python
report = eda.analyze(df, deep_analysis=False)
```

### Summary: What We've Built

In this part, we've created a comprehensive EDA system that:

1. **Automatically analyzes** all columns, identifying their types and generating appropriate statistics

2. **Detects patterns** in missing data, identifying MCAR vs MAR

3. **Calculates correlations** using both Pearson and Spearman methods

4. **Performs multivariate analysis** with PCA and clustering

5. **Analyzes target relationships** when a target is specified

6. **Generates insights** that are automatically extracted from the data

7. **Provides recommendations** for feature engineering and modeling

8. **Creates visualizations** for every aspect of the data

9. **Generates professional HTML reports** that can be shared with stakeholders

10. **Integrates with our existing pipeline**, using the data quality system we built earlier

### What's Next

In Part 4, we'll begin Module 4.1: Feature Prep & Engineering. We'll start by implementing advanced imputation strategies and robust scaling techniques. We'll build on everything we've learned about data quality and EDA to intelligently prepare our data for modeling.
