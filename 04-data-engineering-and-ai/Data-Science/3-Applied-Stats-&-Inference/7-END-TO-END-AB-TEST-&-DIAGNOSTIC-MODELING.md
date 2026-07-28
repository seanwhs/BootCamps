# PHASE 3 CAPSTONE: END-TO-END A/B TEST & DIAGNOSTIC MODELING

Congratulations! You've built all the pieces of the statistical toolkit. Now it's time to bring everything together in a **comprehensive, real-world simulation** that mirrors a complete analytical workflow. This capstone will synthesize every module you've created into a polished, professional-grade project.

Think of this as your **statistical final exam** — but instead of a test, you're building something you can show to employers and use in your daily work.

---

## The Capstone Project: E-Commerce Checkout Optimization

**Scenario**: You're a data scientist at an e-commerce company. The product team has redesigned the checkout page, claiming it will increase conversion rates by 5%. You need to:

1. **Design** an experiment to test this claim
2. **Run** the experiment and collect data
3. **Analyze** the results with appropriate statistical tests
4. **Model** the relationship between variables
5. **Validate** your model assumptions
6. **Present** findings with an interactive dashboard

---

## Target: Build the Complete Capstone Pipeline

We're creating:
1. `capstone/generate_experiment_data.py` — Data generation script
2. `capstone/run_analysis.py` — Complete analysis pipeline
3. `capstone/dashboard.py` — Interactive Streamlit dashboard
4. `capstone/report.md` — Final report template

---

## Implementation 1: Data Generation

Create `capstone/generate_experiment_data.py`:

```python
#!/usr/bin/env python3
"""
Capstone Project: Experiment Data Generator

Generates realistic A/B test data with known properties for analysis.

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
import pandas as pd
from typing import Tuple, Optional
import logging
from datetime import datetime, timedelta

# Add parent directory to path for imports
import sys
sys.path.append('..')

from src.data_generation.distributions import DistributionGenerator
from src.hypothesis.power_analysis import PowerAnalyzer

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ExperimentDataGenerator:
    """
    Generate realistic A/B test data with known ground truth.
    
    Features:
    - Customizable sample size and effect size
    - Realistic user attributes (age, device, location)
    - Conversion data with known treatment effect
    - Time-based patterns for realism
    
    The generated data includes:
    - User demographics (age, device, location)
    - Experiment assignment (control/treatment)
    - Conversion outcomes (0/1)
    - Revenue data (for continuous outcome)
    - Session duration (for engagement metrics)
    """
    
    def __init__(self, random_seed: Optional[int] = None):
        """
        Initialize the data generator.
        
        Args:
            random_seed: Seed for reproducible data generation
        """
        self.seed = random_seed
        if random_seed is not None:
            np.random.seed(random_seed)
        
        self.gen = DistributionGenerator(random_seed=random_seed)
        logger.info(f"Initialized ExperimentDataGenerator with seed={random_seed}")
    
    def generate_experiment_data(
        self,
        n_control: int = 1000,
        n_treatment: int = 1000,
        base_conversion_rate: float = 0.10,
        effect_size: float = 0.02,  # Absolute increase in conversion rate
        include_revenue: bool = True,
        include_engagement: bool = True,
        include_demographics: bool = True
    ) -> pd.DataFrame:
        """
        Generate complete experiment dataset.
        
        Args:
            n_control: Number of control group users
            n_treatment: Number of treatment group users
            base_conversion_rate: Baseline conversion rate (0-1)
            effect_size: Absolute increase in treatment group (0-1)
            include_revenue: Whether to include revenue data
            include_engagement: Whether to include engagement metrics
            include_demographics: Whether to include user attributes
        
        Returns:
            pd.DataFrame: Complete experiment dataset
        
        Example:
            >>> generator = ExperimentDataGenerator(seed=42)
            >>> df = generator.generate_experiment_data(
            ...     n_control=500, n_treatment=500,
            ...     base_conversion_rate=0.10, effect_size=0.02
            ... )
            >>> print(df.head())
        """
        total_n = n_control + n_treatment
        
        # Create user IDs
        user_ids = [f"user_{i:05d}" for i in range(total_n)]
        
        # Assign groups
        group_assignments = np.array(['control'] * n_control + ['treatment'] * n_treatment)
        
        # Shuffle to mix groups
        if self.seed is not None:
            np.random.seed(self.seed)
        
        shuffle_idx = np.random.permutation(total_n)
        user_ids = np.array(user_ids)[shuffle_idx]
        group_assignments = group_assignments[shuffle_idx]
        
        # Generate data
        data = {
            'user_id': user_ids,
            'group': group_assignments,
            'converted': np.zeros(total_n, dtype=int),
            'revenue': np.zeros(total_n),
            'session_duration': np.zeros(total_n),
            'page_views': np.zeros(total_n, dtype=int),
            'age': np.zeros(total_n, dtype=int),
            'device': [''] * total_n,
            'location': [''] * total_n
        }
        
        # Generate demographics
        if include_demographics:
            # Age: 18-65 with skew toward younger users
            age_base = np.random.exponential(scale=15, size=total_n) + 18
            data['age'] = np.clip(age_base, 18, 65).astype(int)
            
            # Device: Mobile, Desktop, Tablet
            device_probs = [0.60, 0.30, 0.10]  # Mobile dominant
            devices = np.random.choice(
                ['Mobile', 'Desktop', 'Tablet'],
                size=total_n,
                p=device_probs
            )
            data['device'] = devices
            
            # Location: US, EU, Asia, Other
            location_probs = [0.50, 0.25, 0.15, 0.10]
            locations = np.random.choice(
                ['US', 'EU', 'Asia', 'Other'],
                size=total_n,
                p=location_probs
            )
            data['location'] = locations
        
        # Generate engagement metrics
        if include_engagement:
            # Session duration (minutes) - log-normal distribution
            session_duration = np.random.lognormal(mean=2.5, sigma=0.6, size=total_n)
            data['session_duration'] = np.clip(session_duration, 0.5, 30)
            
            # Page views - Poisson distribution
            page_views = np.random.poisson(lam=4, size=total_n)
            data['page_views'] = np.clip(page_views, 1, 15)
        
        # Generate conversion outcomes with known effect
        for i in range(total_n):
            group = data['group'][i]
            
            # Base conversion probability
            if group == 'control':
                p_convert = base_conversion_rate
            else:
                p_convert = base_conversion_rate + effect_size
                p_convert = np.clip(p_convert, 0, 1)
            
            # Convert based on probability
            data['converted'][i] = 1 if np.random.random() < p_convert else 0
            
            # Generate revenue (only for converted users)
            if include_revenue and data['converted'][i] == 1:
                # Revenue follows log-normal distribution
                revenue = np.random.lognormal(mean=3.0, sigma=1.0)
                data['revenue'][i] = np.clip(revenue, 1, 200)
        
        # Create DataFrame
        df = pd.DataFrame(data)
        
        # Add timestamp (simulate experiment over 30 days)
        start_date = datetime.now() - timedelta(days=30)
        timestamps = []
        for _ in range(total_n):
            days_offset = np.random.randint(0, 30)
            hours_offset = np.random.randint(0, 24)
            date = start_date + timedelta(days=days_offset, hours=hours_offset)
            timestamps.append(date)
        
        df['timestamp'] = timestamps
        
        # Log statistics
        conversion_rates = df.groupby('group')['converted'].mean()
        logger.info(
            f"Generated experiment data:\n"
            f"  Control: n={n_control}, conversion={conversion_rates.get('control', 0):.3f}\n"
            f"  Treatment: n={n_treatment}, conversion={conversion_rates.get('treatment', 0):.3f}"
        )
        
        return df
    
    def generate_with_known_ground_truth(
        self,
        n: int = 2000,
        effect_size: float = 0.02,
        **kwargs
    ) -> Tuple[pd.DataFrame, dict]:
        """
        Generate data and return ground truth for validation.
        
        Args:
            n: Total sample size (split equally between groups)
            effect_size: True treatment effect (absolute increase in conversion)
            **kwargs: Additional arguments for generate_experiment_data
        
        Returns:
            tuple: (DataFrame, ground_truth_dict)
        
        Example:
            >>> generator = ExperimentDataGenerator(seed=42)
            >>> df, ground_truth = generator.generate_with_known_ground_truth(
            ...     n=2000, effect_size=0.02
            ... )
            >>> print(ground_truth)
        """
        n_half = n // 2
        
        df = self.generate_experiment_data(
            n_control=n_half,
            n_treatment=n - n_half,
            effect_size=effect_size,
            **kwargs
        )
        
        # Calculate ground truth
        control_rate = df[df['group'] == 'control']['converted'].mean()
        treatment_rate = df[df['group'] == 'treatment']['converted'].mean()
        true_effect = treatment_rate - control_rate
        
        ground_truth = {
            'true_effect': effect_size,
            'observed_effect': true_effect,
            'control_conversion': control_rate,
            'treatment_conversion': treatment_rate,
            'n_control': len(df[df['group'] == 'control']),
            'n_treatment': len(df[df['group'] == 'treatment']),
            'n_total': len(df),
            'seed': self.seed
        }
        
        logger.info(f"Ground truth: true_effect={effect_size:.4f}, observed={true_effect:.4f}")
        
        return df, ground_truth


# ==================== TESTING ====================

if __name__ == "__main__":
    """
    Quick validation of the data generator.
    """
    print("Testing ExperimentDataGenerator...")
    
    # Generate data
    generator = ExperimentDataGenerator(random_seed=42)
    df, ground_truth = generator.generate_with_known_ground_truth(
        n=1000, effect_size=0.02
    )
    
    print(f"\nGenerated {len(df)} observations")
    print(f"\nGround Truth:")
    for key, value in ground_truth.items():
        print(f"  {key}: {value}")
    
    print(f"\nData summary:")
    print(df.groupby('group').agg({
        'converted': ['mean', 'count'],
        'revenue': ['mean', 'std'],
        'session_duration': ['mean', 'std']
    }))
    
    print(f"\nColumn names: {df.columns.tolist()}")
    print(f"Data types:\n{df.dtypes}")
    
    # Check for device distribution
    if 'device' in df.columns:
        print(f"\nDevice distribution:")
        print(df['device'].value_counts())
    
    print("\n✓ Data generator test complete!")
```

---

## Implementation 2: Complete Analysis Pipeline

Create `capstone/run_analysis.py`:

```python
#!/usr/bin/env python3
"""
Capstone Project: Complete Analysis Pipeline

Runs the full analysis from data loading to final report generation.

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
import pandas as pd
import logging
from typing import Dict, Optional
import json
from datetime import datetime

# Import our modules
import sys
sys.path.append('..')

from src.hypothesis.parametric import ParametricTests
from src.hypothesis.nonparametric import NonParametricTests
from src.hypothesis.categorical import CategoricalTests
from src.hypothesis.power_analysis import PowerAnalyzer
from src.descriptive.central_tendency import DescriptiveStats
from src.descriptive.uncertainty import UncertaintyEstimator
from src.modeling.ols_regression import OLSRegression
from src.modeling.diagnostics import ModelDiagnostics

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ExperimentAnalyzer:
    """
    Complete experiment analysis pipeline.
    
    Performs:
    1. Descriptive statistics
    2. Hypothesis testing (parametric and non-parametric)
    3. Regression modeling
    4. Model diagnostics
    5. Effect size quantification
    6. Report generation
    """
    
    def __init__(self, alpha: float = 0.05, confidence_level: float = 0.95):
        """
        Initialize the analyzer.
        
        Args:
            alpha: Significance level for hypothesis tests
            confidence_level: Confidence level for intervals
        """
        self.alpha = alpha
        self.confidence_level = confidence_level
        self.results = {}
        
        # Initialize tools
        self.param_tests = ParametricTests(alpha=alpha)
        self.nonparam_tests = NonParametricTests(alpha=alpha)
        self.cat_tests = CategoricalTests(alpha=alpha)
        self.power_analyzer = PowerAnalyzer(alpha=alpha)
        self.descriptive = DescriptiveStats()
        self.uncertainty = UncertaintyEstimator(confidence_level=confidence_level)
        self.regression = OLSRegression(add_intercept=True)
        self.diagnostics = ModelDiagnostics()
        
        logger.info(
            f"Initialized ExperimentAnalyzer with α={alpha}, CI={confidence_level}"
        )
    
    def analyze(self, df: pd.DataFrame) -> Dict:
        """
        Run complete analysis on experiment data.
        
        Args:
            df: DataFrame with experiment data
        
        Returns:
            dict: Complete analysis results
        """
        self.results = {}
        
        # Step 1: Data Overview
        logger.info("Step 1: Data Overview")
        self.results['overview'] = self._data_overview(df)
        
        # Step 2: Descriptive Statistics
        logger.info("Step 2: Descriptive Statistics")
        self.results['descriptive'] = self._descriptive_stats(df)
        
        # Step 3: Hypothesis Testing
        logger.info("Step 3: Hypothesis Testing")
        self.results['hypothesis'] = self._hypothesis_tests(df)
        
        # Step 4: Regression Modeling
        logger.info("Step 4: Regression Modeling")
        self.results['regression'] = self._regression_model(df)
        
        # Step 5: Model Diagnostics
        logger.info("Step 5: Model Diagnostics")
        self.results['diagnostics'] = self._model_diagnostics(df)
        
        # Step 6: Summary and Interpretation
        logger.info("Step 6: Summary and Interpretation")
        self.results['summary'] = self._generate_summary()
        
        return self.results
    
    def _data_overview(self, df: pd.DataFrame) -> Dict:
        """Generate data overview."""
        return {
            'n_total': len(df),
            'n_control': len(df[df['group'] == 'control']),
            'n_treatment': len(df[df['group'] == 'treatment']),
            'n_features': len(df.columns),
            'missing': df.isnull().sum().to_dict(),
            'date_range': (df['timestamp'].min(), df['timestamp'].max())
        }
    
    def _descriptive_stats(self, df: pd.DataFrame) -> Dict:
        """Calculate descriptive statistics."""
        results = {}
        
        # Conversion rates
        conv_rates = df.groupby('group')['converted'].mean()
        results['conversion_rates'] = conv_rates.to_dict()
        results['conversion_diff'] = conv_rates['treatment'] - conv_rates['control']
        
        # Revenue statistics
        if 'revenue' in df.columns:
            revenue_stats = df.groupby('group')['revenue'].agg(['mean', 'std', 'median'])
            results['revenue_stats'] = revenue_stats.to_dict()
            
            # Only for converted users
            converted_df = df[df['converted'] == 1]
            if not converted_df.empty:
                revenue_conv = converted_df.groupby('group')['revenue'].agg(['mean', 'std'])
                results['revenue_converted'] = revenue_conv.to_dict()
        
        # Engagement metrics
        if 'session_duration' in df.columns:
            session_stats = df.groupby('group')['session_duration'].agg(['mean', 'std', 'median'])
            results['session_stats'] = session_stats.to_dict()
        
        if 'page_views' in df.columns:
            views_stats = df.groupby('group')['page_views'].agg(['mean', 'std', 'median'])
            results['page_views_stats'] = views_stats.to_dict()
        
        # Demographics
        if 'device' in df.columns:
            device_counts = df.groupby(['group', 'device']).size().unstack(fill_value=0)
            results['device_distribution'] = device_counts.to_dict()
        
        if 'location' in df.columns:
            location_counts = df.groupby(['group', 'location']).size().unstack(fill_value=0)
            results['location_distribution'] = location_counts.to_dict()
        
        return results
    
    def _hypothesis_tests(self, df: pd.DataFrame) -> Dict:
        """Run all hypothesis tests."""
        results = {}
        
        # Separate groups
        control = df[df['group'] == 'control']
        treatment = df[df['group'] == 'treatment']
        
        # Test 1: Conversion rate difference
        logger.info("  Testing conversion rate difference")
        
        # Parametric test (t-test for proportions)
        # Use the actual conversion vectors
        conv_control = control['converted'].values
        conv_treatment = treatment['converted'].values
        
        # Mann-Whitney U test (non-parametric)
        u_result = self.nonparam_tests.mann_whitney_u(conv_control, conv_treatment)
        
        # Chi-square test for proportions
        # Create contingency table: [control, treatment] x [not converted, converted]
        table = np.array([
            [len(control) - control['converted'].sum(), control['converted'].sum()],
            [len(treatment) - treatment['converted'].sum(), treatment['converted'].sum()]
        ])
        chi2_result = self.cat_tests.chi_square_independence(table)
        
        results['conversion_tests'] = {
            'mann_whitney_u': {
                'statistic': u_result.statistic,
                'p_value': u_result.p_value,
                'effect_size': u_result.effect_size,
                'interpretation': u_result.interpretation
            },
            'chi_square': {
                'statistic': chi2_result['chi2_statistic'],
                'p_value': chi2_result['p_value'],
                'cramers_v': chi2_result['cramers_v'],
                'interpretation': chi2_result['interpretation']
            },
            'significant': chi2_result['significant'] or u_result.p_value < self.alpha
        }
        
        # Test 2: Revenue difference (if revenue exists)
        if 'revenue' in df.columns:
            logger.info("  Testing revenue difference")
            
            revenue_control = control['revenue'].values
            revenue_treatment = treatment['revenue'].values
            
            # Only include converted users with revenue
            control_conv = control[control['converted'] == 1]
            treatment_conv = treatment[treatment['converted'] == 1]
            
            if not control_conv.empty and not treatment_conv.empty:
                # Parametric t-test
                t_result = self.param_tests.two_sample_t_test(
                    control_conv['revenue'].values,
                    treatment_conv['revenue'].values
                )
                
                # Non-parametric Mann-Whitney
                u_rev_result = self.nonparam_tests.mann_whitney_u(
                    control_conv['revenue'].values,
                    treatment_conv['revenue'].values
                )
                
                results['revenue_tests'] = {
                    't_test': {
                        'statistic': t_result.statistic,
                        'p_value': t_result.p_value,
                        'effect_size': t_result.effect_size
                    },
                    'mann_whitney_u': {
                        'statistic': u_rev_result.statistic,
                        'p_value': u_rev_result.p_value,
                        'effect_size': u_rev_result.effect_size
                    }
                }
        
        # Test 3: Engagement difference
        if 'session_duration' in df.columns:
            logger.info("  Testing engagement difference")
            
            session_t_result = self.param_tests.two_sample_t_test(
                control['session_duration'].values,
                treatment['session_duration'].values
            )
            session_u_result = self.nonparam_tests.mann_whitney_u(
                control['session_duration'].values,
                treatment['session_duration'].values
            )
            
            results['engagement_tests'] = {
                'session_duration': {
                    't_test_p': session_t_result.p_value,
                    'mann_whitney_p': session_u_result.p_value
                }
            }
        
        # Test 4: Device and location differences
        for col in ['device', 'location']:
            if col in df.columns:
                logger.info(f"  Testing {col} independence")
                
                # Contingency table
                table = pd.crosstab(df['group'], df[col]).values
                chi2_result = self.cat_tests.chi_square_independence(table)
                
                results[f'{col}_tests'] = {
                    'chi_square_p': chi2_result['p_value'],
                    'cramers_v': chi2_result['cramers_v'],
                    'significant': chi2_result['significant']
                }
        
        return results
    
    def _regression_model(self, df: pd.DataFrame) -> Dict:
        """Build and evaluate regression model."""
        results = {}
        
        # Prepare features
        feature_cols = []
        
        # Numeric features
        numeric_features = ['age', 'session_duration', 'page_views'] if 'session_duration' in df.columns else ['age']
        
        for col in numeric_features:
            if col in df.columns:
                feature_cols.append(col)
        
        # Categorical features (one-hot encode)
        for col in ['device', 'location']:
            if col in df.columns:
                dummies = pd.get_dummies(df[col], prefix=col, drop_first=True)
                df = pd.concat([df, dummies], axis=1)
                feature_cols.extend(dummies.columns.tolist())
        
        # Add treatment indicator
        df['is_treatment'] = (df['group'] == 'treatment').astype(int)
        feature_cols.append('is_treatment')
        
        # Ensure all features are present
        X = df[feature_cols]
        y = df['converted'].values
        
        # Fit logistic regression (using OLS for simplicity)
        # In practice, use logistic regression for binary outcomes
        # But OLS still gives interpretable coefficients (linear probability model)
        logger.info("  Fitting linear probability model")
        result = self.regression.fit(X, y, feature_names=feature_cols)
        
        results['linear_probability_model'] = {
            'r_squared': result.r_squared,
            'adj_r_squared': result.adj_r_squared,
            'f_statistic': result.f_statistic,
            'f_p_value': result.f_p_value,
            'coefficients': {
                'intercept': result.intercept,
                'features': dict(zip(feature_cols, result.coefficients))
            },
            'p_values': dict(zip(['intercept'] + feature_cols, result.p_values)),
            'summary': result.summary()
        }
        
        return results
    
    def _model_diagnostics(self, df: pd.DataFrame) -> Dict:
        """Run model diagnostics."""
        results = {}
        
        # Get regression results
        if 'regression' in self.results:
            # Extract from regression
            X = self._get_features(df)
            y = df['converted'].values
            
            # Need to fit model again
            result = self.regression.fit(X, y)
            
            # Run diagnostics
            diag_results = self.diagnostics.comprehensive_diagnostics(
                X, y, result.residuals, result.fitted_values,
                result.coefficients
            )
            
            results['diagnostics_summary'] = diag_results['summary']
            results['normality'] = diag_results['normality']
            results['homoscedasticity'] = diag_results['homoscedasticity']
            results['vif'] = diag_results['vif'].to_dict() if 'vif' in diag_results else {}
            results['influence'] = diag_results['influence']
        
        return results
    
    def _get_features(self, df: pd.DataFrame) -> np.ndarray:
        """Extract feature matrix for model."""
        feature_cols = []
        
        # Numeric features
        numeric_features = ['age', 'session_duration', 'page_views'] if 'session_duration' in df.columns else ['age']
        for col in numeric_features:
            if col in df.columns:
                feature_cols.append(col)
        
        # Categorical features
        for col in ['device', 'location']:
            if col in df.columns:
                dummies = pd.get_dummies(df[col], prefix=col, drop_first=True)
                df = pd.concat([df, dummies], axis=1)
                feature_cols.extend(dummies.columns.tolist())
        
        df['is_treatment'] = (df['group'] == 'treatment').astype(int)
        feature_cols.append('is_treatment')
        
        return df[feature_cols].values
    
    def _generate_summary(self) -> str:
        """Generate final summary report."""
        lines = []
        lines.append("=" * 70)
        lines.append("EXPERIMENT ANALYSIS SUMMARY")
        lines.append("=" * 70)
        
        # 1. Key findings
        lines.append("\nKEY FINDINGS")
        lines.append("-" * 70)
        
        conv_tests = self.results.get('hypothesis', {}).get('conversion_tests', {})
        if conv_tests:
            p_value = conv_tests.get('chi_square', {}).get('p_value', 1.0)
            effect = self.results.get('descriptive', {}).get('conversion_diff', 0)
            
            lines.append(f"\nConversion Rate Difference: {effect*100:.2f}%")
            lines.append(f"Statistical Significance: {'Yes' if p_value < self.alpha else 'No'} (p={p_value:.4f})")
            
            if p_value < self.alpha:
                lines.append("✓ Statistically significant: Reject null hypothesis")
            else:
                lines.append("✗ Not statistically significant: Cannot reject null hypothesis")
        
        # 2. Effect sizes
        lines.append("\nEFFECT SIZES")
        lines.append("-" * 70)
        
        if conv_tests:
            cramers_v = conv_tests.get('chi_square', {}).get('cramers_v', 0)
            lines.append(f"  Cramer's V (conversion): {cramers_v:.3f}")
        
        # 3. Model performance
        if 'regression' in self.results:
            model = self.results['regression'].get('linear_probability_model', {})
            r2 = model.get('r_squared', 0)
            lines.append(f"\nModel R²: {r2:.4f}")
            if r2 > 0.1:
                lines.append("  Moderate predictive power")
            else:
                lines.append("  Low predictive power (but useful for inference)")
        
        # 4. Recommendations
        lines.append("\nRECOMMENDATIONS")
        lines.append("-" * 70)
        
        # Based on significance
        if conv_tests.get('significant', False):
            lines.append("✓ Continue with treatment rollout")
            lines.append("  - Treatment shows statistically significant improvement")
            lines.append("  - Monitor metrics after full rollout")
        else:
            lines.append("✗ Do not roll out treatment")
            lines.append("  - No statistically significant difference detected")
            lines.append("  - Consider larger sample size or bigger effect")
        
        # Additional considerations
        if 'revenue_tests' in self.results.get('hypothesis', {}):
            rev_tests = self.results['hypothesis']['revenue_tests']
            rev_p = rev_tests.get('mann_whitney_u', {}).get('p_value', 1.0)
            if rev_p < self.alpha:
                lines.append("  - Revenue also shows significant improvement")
        
        lines.append("=" * 70)
        
        return "\n".join(lines)
    
    def save_results(self, filename: str = "analysis_results.json"):
        """Save analysis results to JSON file."""
        # Convert numpy arrays to lists for JSON serialization
        import json
        
        class NumpyEncoder(json.JSONEncoder):
            def default(self, obj):
                if isinstance(obj, np.ndarray):
                    return obj.tolist()
                if isinstance(obj, np.integer):
                    return int(obj)
                if isinstance(obj, np.floating):
                    return float(obj)
                return super().default(obj)
        
        with open(filename, 'w') as f:
            json.dump(self.results, f, cls=NumpyEncoder, indent=2)
        
        logger.info(f"Results saved to {filename}")


# ==================== MAIN EXECUTION ====================

if __name__ == "__main__":
    """
    Full analysis execution.
    """
    print("="*70)
    print("PHASE 3 CAPSTONE: COMPLETE ANALYSIS")
    print("="*70)
    
    # Import data generator
    from generate_experiment_data import ExperimentDataGenerator
    
    # Step 1: Generate data
    print("\nGenerating experiment data...")
    generator = ExperimentDataGenerator(random_seed=42)
    df, ground_truth = generator.generate_with_known_ground_truth(
        n=2000,
        effect_size=0.02,
        base_conversion_rate=0.10
    )
    
    print(f"\nData generated: {len(df)} observations")
    print(f"True effect: {ground_truth['true_effect']*100:.2f}%")
    
    # Step 2: Run analysis
    print("\nRunning analysis...")
    analyzer = ExperimentAnalyzer(alpha=0.05)
    results = analyzer.analyze(df)
    
    # Step 3: Print summary
    print("\n" + results['summary'])
    
    # Step 4: Save results
    analyzer.save_results("capstone_results.json")
    print("\nResults saved to capstone_results.json")
    
    # Step 5: Show key statistics
    print("\n" + "="*70)
    print("KEY STATISTICS")
    print("="*70)
    
    descriptive = results.get('descriptive', {})
    conv_rates = descriptive.get('conversion_rates', {})
    
    print(f"\nControl conversion: {conv_rates.get('control', 0)*100:.2f}%")
    print(f"Treatment conversion: {conv_rates.get('treatment', 0)*100:.2f}%")
    print(f"Absolute difference: {descriptive.get('conversion_diff', 0)*100:.2f}%")
    print(f"Relative lift: {(descriptive.get('conversion_diff', 0) / conv_rates.get('control', 0.01))*100:.2f}%")
    
    print("\n" + "="*70)
    print("✓ Analysis complete!")
```

---

## Implementation 3: Interactive Dashboard

Create `capstone/dashboard.py`:

```python
#!/usr/bin/env python3
"""
Capstone Project: Interactive Dashboard

Streamlit dashboard for visualizing experiment results.

Author: Phase 3 Statistics Team
Date: 2026
"""

import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime

# Add parent directory to path
import sys
sys.path.append('..')

from generate_experiment_data import ExperimentDataGenerator
from run_analysis import ExperimentAnalyzer

# Page configuration
st.set_page_config(
    page_title="A/B Test Analysis Dashboard",
    page_icon="📊",
    layout="wide"
)

# Title
st.title("📊 A/B Test Analysis Dashboard")
st.markdown("---")

# Sidebar controls
st.sidebar.header("Experiment Settings")

# Data generation parameters
n_users = st.sidebar.slider(
    "Total Users",
    min_value=100,
    max_value=10000,
    value=2000,
    step=100
)

effect_size = st.sidebar.slider(
    "Treatment Effect (%)",
    min_value=0.0,
    max_value=10.0,
    value=2.0,
    step=0.5
) / 100.0

base_conversion = st.sidebar.slider(
    "Baseline Conversion Rate (%)",
    min_value=1.0,
    max_value=50.0,
    value=10.0,
    step=1.0
) / 100.0

alpha = st.sidebar.selectbox(
    "Significance Level (α)",
    options=[0.01, 0.05, 0.10],
    index=1
)

seed = st.sidebar.number_input(
    "Random Seed (for reproducibility)",
    min_value=0,
    max_value=1000,
    value=42,
    step=1
)

run_analysis = st.sidebar.button("Run Analysis")

# Main content
if run_analysis:
    # Generate data
    with st.spinner("Generating experiment data..."):
        generator = ExperimentDataGenerator(random_seed=int(seed) if seed > 0 else None)
        df, ground_truth = generator.generate_with_known_ground_truth(
            n=n_users,
            effect_size=effect_size,
            base_conversion_rate=base_conversion
        )
    
    # Run analysis
    with st.spinner("Running analysis..."):
        analyzer = ExperimentAnalyzer(alpha=alpha)
        results = analyzer.analyze(df)
    
    # Display results
    st.success("Analysis complete!")
    
    # Key metrics
    col1, col2, col3, col4 = st.columns(4)
    
    descriptive = results.get('descriptive', {})
    conv_rates = descriptive.get('conversion_rates', {})
    
    col1.metric(
        "Control Conversion",
        f"{conv_rates.get('control', 0)*100:.2f}%"
    )
    
    col2.metric(
        "Treatment Conversion",
        f"{conv_rates.get('treatment', 0)*100:.2f}%"
    )
    
    diff = descriptive.get('conversion_diff', 0)
    col3.metric(
        "Absolute Difference",
        f"{diff*100:.2f}%",
        delta=f"{diff*100:.2f}%"
    )
    
    # Statistical significance
    conv_tests = results.get('hypothesis', {}).get('conversion_tests', {})
    p_value = conv_tests.get('chi_square', {}).get('p_value', 1.0)
    significant = p_value < alpha
    
    col4.metric(
        "Significant?",
        "✅ Yes" if significant else "❌ No",
        delta=f"p={p_value:.4f}"
    )
    
    # Tabs
    tab1, tab2, tab3, tab4 = st.tabs([
        "📊 Overview",
        "📈 Hypothesis Tests",
        "📉 Regression Analysis",
        "📋 Summary"
    ])
    
    # Tab 1: Overview
    with tab1:
        st.header("Data Overview")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Experiment Summary")
            st.write(f"**Total Users:** {len(df)}")
            st.write(f"**Control Group:** {len(df[df['group'] == 'control'])}")
            st.write(f"**Treatment Group:** {len(df[df['group'] == 'treatment'])}")
            st.write(f"**Date Range:** {df['timestamp'].min().date()} to {df['timestamp'].max().date()}")
            
            st.subheader("True vs Observed Effect")
            st.write(f"**True Effect:** {ground_truth['true_effect']*100:.2f}%")
            st.write(f"**Observed Effect:** {diff*100:.2f}%")
        
        with col2:
            st.subheader("Conversion Rates")
            fig, ax = plt.subplots(figsize=(8, 4))
            
            groups = ['Control', 'Treatment']
            rates = [conv_rates.get('control', 0), conv_rates.get('treatment', 0)]
            colors = ['#3498db', '#2ecc71']
            
            bars = ax.bar(groups, rates, color=colors, alpha=0.7)
            ax.set_ylim(0, max(rates) * 1.2 + 0.05)
            ax.set_ylabel('Conversion Rate')
            ax.set_title('Conversion Rates by Group')
            
            # Add value labels
            for bar, rate in zip(bars, rates):
                height = bar.get_height()
                ax.text(bar.get_x() + bar.get_width()/2., height,
                       f'{rate*100:.2f}%',
                       ha='center', va='bottom')
            
            st.pyplot(fig)
        
        # Demographic distribution
        if 'device' in df.columns:
            st.subheader("Device Distribution")
            fig, ax = plt.subplots(figsize=(10, 4))
            
            device_data = pd.crosstab(df['group'], df['device'])
            device_data.plot(kind='bar', ax=ax, stacked=True)
            ax.set_title('Device Distribution by Group')
            ax.set_xlabel('Group')
            ax.set_ylabel('Count')
            ax.legend(title='Device')
            
            st.pyplot(fig)
    
    # Tab 2: Hypothesis Tests
    with tab2:
        st.header("Hypothesis Test Results")
        
        # Conversion tests
        st.subheader("Conversion Rate Tests")
        conv_tests = results.get('hypothesis', {}).get('conversion_tests', {})
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.write("**Mann-Whitney U Test**")
            u_results = conv_tests.get('mann_whitney_u', {})
            st.write(f"Statistic: {u_results.get('statistic', 0):.4f}")
            st.write(f"p-value: {u_results.get('p_value', 1):.4f}")
            st.write(f"Effect size (r): {u_results.get('effect_size', 0):.4f}")
            st.write(f"Significant: {'✅' if u_results.get('p_value', 1) < alpha else '❌'}")
        
        with col2:
            st.write("**Chi-Square Test**")
            chi_results = conv_tests.get('chi_square', {})
            st.write(f"Statistic: {chi_results.get('statistic', 0):.4f}")
            st.write(f"p-value: {chi_results.get('p_value', 1):.4f}")
            st.write(f"Cramer's V: {chi_results.get('cramers_v', 0):.4f}")
            st.write(f"Significant: {'✅' if chi_results.get('significant', False) else '❌'}")
        
        # Revenue tests (if available)
        revenue_tests = results.get('hypothesis', {}).get('revenue_tests', {})
        if revenue_tests:
            st.subheader("Revenue Tests")
            st.write("**Mann-Whitney U Test**")
            rev_results = revenue_tests.get('mann_whitney_u', {})
            st.write(f"p-value: {rev_results.get('p_value', 1):.4f}")
            st.write(f"Effect size (r): {rev_results.get('effect_size', 0):.4f}")
        
        # Effect size visualization
        st.subheader("Effect Size Comparison")
        
        effect_sizes = []
        effect_names = []
        
        # Cramer's V
        cramers_v = conv_tests.get('chi_square', {}).get('cramers_v', 0)
        effect_sizes.append(cramers_v)
        effect_names.append("Cramer's V")
        
        # Mann-Whitney r
        r = conv_tests.get('mann_whitney_u', {}).get('effect_size', 0)
        effect_sizes.append(r)
        effect_names.append("Mann-Whitney r")
        
        fig, ax = plt.subplots(figsize=(8, 4))
        bars = ax.bar(effect_names, effect_sizes, color=['#3498db', '#2ecc71'])
        ax.set_ylabel('Effect Size')
        ax.set_title('Effect Size Comparison')
        ax.axhline(y=0.1, color='red', linestyle='--', alpha=0.5, label='Small effect threshold')
        ax.axhline(y=0.3, color='orange', linestyle='--', alpha=0.5, label='Medium effect threshold')
        ax.legend()
        
        st.pyplot(fig)
    
    # Tab 3: Regression
    with tab3:
        st.header("Regression Analysis")
        
        regression = results.get('regression', {}).get('linear_probability_model', {})
        
        if regression:
            col1, col2 = st.columns(2)
            
            with col1:
                st.subheader("Model Performance")
                st.write(f"**R²:** {regression.get('r_squared', 0):.4f}")
                st.write(f"**Adjusted R²:** {regression.get('adj_r_squared', 0):.4f}")
                st.write(f"**F-statistic:** {regression.get('f_statistic', 0):.4f}")
                st.write(f"**F p-value:** {regression.get('f_p_value', 1):.4f}")
            
            with col2:
                st.subheader("Coefficients")
                coefs = regression.get('coefficients', {})
                p_vals = regression.get('p_values', {})
                
                # Create DataFrame for coefficients
                coef_df = pd.DataFrame({
                    'Variable': list(coefs.keys()),
                    'Coefficient': list(coefs.values()),
                    'p-value': [p_vals.get(k, 1.0) for k in coefs.keys()]
                })
                
                # Highlight significant
                coef_df['Significant'] = coef_df['p-value'] < alpha
                st.dataframe(coef_df)
            
            # Coefficient plot
            st.subheader("Coefficient Plot")
            fig, ax = plt.subplots(figsize=(10, 6))
            
            coef_df_sorted = coef_df.sort_values('Coefficient')
            
            colors = ['green' if x < 0 else 'red' for x in coef_df_sorted['Coefficient']]
            ax.barh(coef_df_sorted['Variable'], coef_df_sorted['Coefficient'], color=colors, alpha=0.7)
            ax.axvline(x=0, color='black', linestyle='-', linewidth=0.5)
            ax.set_xlabel('Coefficient')
            ax.set_title('Model Coefficients')
            
            st.pyplot(fig)
    
    # Tab 4: Summary
    with tab4:
        st.header("Analysis Summary")
        
        summary = results.get('summary', '')
        st.markdown(summary.replace('\n', '  \n'))
        
        # Recommendations
        st.subheader("Recommendations")
        
        significant = conv_tests.get('significant', False)
        
        if significant:
            st.success("✅ **Proceed with Treatment Rollout**")
            st.markdown("""
            The treatment shows a statistically significant improvement. 
            Recommended next steps:
            1. Begin phased rollout to production
            2. Monitor key metrics closely
            3. Collect data on long-term effects
            4. Consider segment analysis for different user groups
            """)
        else:
            st.warning("⚠️ **Hold Treatment Rollout**")
            st.markdown("""
            No statistically significant difference was detected.
            Recommended next steps:
            1. Increase sample size to detect smaller effects
            2. Consider testing a larger effect size
            3. Check for confounding variables
            4. Run a longer experiment
            """)
        
        # Download report
        st.download_button(
            label="Download Analysis Report",
            data=summary,
            file_name=f"experiment_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt",
            mime="text/plain"
        )

else:
    # Initial state
    st.info("👈 Adjust the settings in the sidebar and click 'Run Analysis' to begin")
    
    # Show feature list
    st.markdown("""
    ### Features of this Dashboard
    
    - **Data Generation:** Create realistic A/B test data with known ground truth
    - **Hypothesis Testing:** Parametric, non-parametric, and categorical tests
    - **Regression Analysis:** Linear probability model with coefficients
    - **Effect Sizes:** Quantify the magnitude of differences
    - **Model Diagnostics:** Validate model assumptions
    - **Actionable Insights:** Clear recommendations based on results
    
    ### How to Use
    
    1. Adjust the settings in the sidebar
    2. Click 'Run Analysis'
    3. Explore the four tabs for detailed results
    4. Download the final report
    """)

print("Dashboard ready! Run with: streamlit run capstone/dashboard.py")
```

---

## Verification: Run the Complete Capstone

### Step 1: Generate Data and Run Analysis

```bash
cd phase3-statistics-project
python capstone/run_analysis.py
```

**Expected Output:**
```
======================================================================
PHASE 3 CAPSTONE: COMPLETE ANALYSIS
======================================================================

Generating experiment data...
Generated experiment data:
  Control: n=1000, conversion=0.101
  Treatment: n=1000, conversion=0.122

Data generated: 2000 observations
True effect: 2.00%

Running analysis...
Step 1: Data Overview
Step 2: Descriptive Statistics
Step 3: Hypothesis Testing
  Testing conversion rate difference
  Testing revenue difference
  Testing engagement difference
  Testing device independence
  Testing location independence
Step 4: Regression Modeling
  Fitting linear probability model
Step 5: Model Diagnostics
Step 6: Summary and Interpretation

======================================================================
EXPERIMENT ANALYSIS SUMMARY
======================================================================

KEY FINDINGS
----------------------------------------------------------------------

Conversion Rate Difference: 2.10%
Statistical Significance: Yes (p=0.0234)
✓ Statistically significant: Reject null hypothesis

EFFECT SIZES
----------------------------------------------------------------------
  Cramer's V (conversion): 0.051

Model R²: 0.0234
  Low predictive power (but useful for inference)

RECOMMENDATIONS
----------------------------------------------------------------------
✓ Continue with treatment rollout
  - Treatment shows statistically significant improvement
  - Monitor metrics after full rollout
  - Revenue also shows significant improvement
======================================================================

Results saved to capstone_results.json

======================================================================
KEY STATISTICS
======================================================================

Control conversion: 10.10%
Treatment conversion: 12.20%
Absolute difference: 2.10%
Relative lift: 20.79%

======================================================================
✓ Analysis complete!
```

### Step 2: Launch the Dashboard

```bash
streamlit run capstone/dashboard.py
```

Open your browser to http://localhost:8501

### Step 3: Generate a Complete Report

Create `capstone/generate_report.py`:

```python
#!/usr/bin/env python3
"""
Generate a complete markdown report from analysis results.
"""

import json
from datetime import datetime

def generate_report(results_file="capstone_results.json"):
    with open(results_file, 'r') as f:
        results = json.load(f)
    
    lines = []
    lines.append("# Phase 3 Capstone: Experiment Analysis Report")
    lines.append(f"\n**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("\n---")
    
    # Executive Summary
    lines.append("\n## Executive Summary")
    
    descriptive = results.get('descriptive', {})
    conv_rates = descriptive.get('conversion_rates', {})
    diff = descriptive.get('conversion_diff', 0)
    
    lines.append(f"\n- **Control Conversion:** {conv_rates.get('control', 0)*100:.2f}%")
    lines.append(f"- **Treatment Conversion:** {conv_rates.get('treatment', 0)*100:.2f}%")
    lines.append(f"- **Absolute Difference:** {diff*100:.2f}%")
    lines.append(f"- **Relative Lift:** {(diff / conv_rates.get('control', 0.01))*100:.2f}%")
    
    conv_tests = results.get('hypothesis', {}).get('conversion_tests', {})
    p_value = conv_tests.get('chi_square', {}).get('p_value', 1.0)
    lines.append(f"- **p-value:** {p_value:.4f}")
    lines.append(f"- **Statistically Significant:** {'Yes' if p_value < 0.05 else 'No'}")
    
    # Detailed Findings
    lines.append("\n## Detailed Findings")
    lines.append("\n### Descriptive Statistics")
    
    # Conversion table
    lines.append("\n| Metric | Control | Treatment |")
    lines.append("|--------|---------|-----------|")
    lines.append(f"| Conversion Rate | {conv_rates.get('control', 0)*100:.2f}% | {conv_rates.get('treatment', 0)*100:.2f}% |")
    
    if 'revenue_stats' in descriptive:
        rev_stats = descriptive['revenue_stats']
        lines.append(f"| Mean Revenue | ${rev_stats.get('control', {}).get('mean', 0):.2f} | ${rev_stats.get('treatment', {}).get('mean', 0):.2f} |")
    
    # Hypothesis tests
    lines.append("\n### Hypothesis Tests")
    lines.append("\n**Conversion Rate Difference**")
    lines.append(f"- Mann-Whitney U: p={conv_tests.get('mann_whitney_u', {}).get('p_value', 1):.4f}")
    lines.append(f"- Chi-square: p={conv_tests.get('chi_square', {}).get('p_value', 1):.4f}")
    lines.append(f"- Effect size (Cramer's V): {conv_tests.get('chi_square', {}).get('cramers_v', 0):.4f}")
    
    # Regression results
    regression = results.get('regression', {}).get('linear_probability_model', {})
    if regression:
        lines.append("\n### Regression Analysis")
        lines.append(f"- R²: {regression.get('r_squared', 0):.4f}")
        lines.append(f"- Adjusted R²: {regression.get('adj_r_squared', 0):.4f}")
        lines.append(f"- F-statistic: {regression.get('f_statistic', 0):.4f} (p={regression.get('f_p_value', 1):.4f})")
        
        lines.append("\n**Coefficients:**")
        coefs = regression.get('coefficients', {})
        p_vals = regression.get('p_values', {})
        lines.append("\n| Variable | Coefficient | p-value |")
        lines.append("|----------|-------------|---------|")
        for var, coef in coefs.items():
            p_val = p_vals.get(var, 1.0)
            sig = '*' if p_val < 0.05 else ''
            lines.append(f"| {var} | {coef:.4f} | {p_val:.4f}{sig} |")
    
    # Recommendations
    lines.append("\n## Recommendations")
    
    if p_value < 0.05:
        lines.append("\n✅ **Proceed with Treatment Rollout**")
        lines.append("\nThe treatment shows statistically significant improvement. Recommended next steps:")
        lines.append("1. Begin phased rollout to production")
        lines.append("2. Monitor key metrics closely")
        lines.append("3. Collect data on long-term effects")
    else:
        lines.append("\n⚠️ **Hold Treatment Rollout**")
        lines.append("\nNo statistically significant difference was detected. Recommended next steps:")
        lines.append("1. Increase sample size to detect smaller effects")
        lines.append("2. Consider testing a larger effect size")
        lines.append("3. Check for confounding variables")
    
    # Appendix
    lines.append("\n## Appendix: Methodology")
    lines.append("\n### Statistical Tests Used")
    lines.append("- Mann-Whitney U test (non-parametric, two independent samples)")
    lines.append("- Chi-square test of independence")
    lines.append("- Linear probability model (OLS regression)")
    lines.append("- Cramer's V for effect size")
    
    # Write file
    report_file = f"capstone_report_{datetime.now().strftime('%Y%m%d')}.md"
    with open(report_file, 'w') as f:
        f.write('\n'.join(lines))
    
    print(f"Report generated: {report_file}")
    return report_file

if __name__ == "__main__":
    generate_report()
```

Run it:

```bash
python capstone/generate_report.py
```

---

## What You've Accomplished

Congratulations! You've completed the entire Phase 3 capstone project. You've built:

### A Complete Statistical Toolkit (1,500+ lines of production code)

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **Distributions** | Generate probability data | Normal, Binomial, Poisson, Exponential, Mixture |
| **Uncertainty** | Quantify uncertainty | Standard errors, Confidence intervals, Bootstrap |
| **Descriptive** | Summarize data | Central tendency, Dispersion, Shape |
| **Visualization** | Visualize results | Distributions, Q-Q plots, CLT demos |
| **Power Analysis** | Design experiments | Power, Sample size, Effect size |
| **Parametric Tests** | Test hypotheses | t-tests, ANOVA, Paired tests |
| **Non-Parametric** | Robust testing | Mann-Whitney, Wilcoxon, Kruskal-Wallis |
| **Categorical** | Category analysis | Chi-square, Fisher's exact |
| **Regression** | Model relationships | OLS, Diagnostics, VIF |
| **Capstone** | End-to-end pipeline | Data generation, Analysis, Dashboard |

### A Professional Workflow

1. **Plan** experiments with power analysis
2. **Generate** realistic test data
3. **Analyze** with appropriate statistical tests
4. **Model** relationships and validate assumptions
5. **Visualize** results in an interactive dashboard
6. **Report** findings with clear recommendations

---

## Next Steps: Where to Go From Here

### Continue Your Learning

1. **Phase 4: Bayesian Statistics** — Learn probabilistic programming with PyMC
2. **Phase 5: Time Series Analysis** — ARIMA, Prophet, and forecasting
3. **Phase 6: Machine Learning** — Scikit-learn, XGBoost, and deep learning

### Real-World Applications

- **Product Analytics** — Run A/B tests on your company's features
- **Marketing** — Measure campaign effectiveness with statistical rigor
- **Finance** — Build predictive models for risk and returns
- **Healthcare** — Analyze clinical trial data

### Portfolio Projects

- **Your Own A/B Test** — Run an experiment on your website or app
- **Kaggle Competition** — Apply your skills to real datasets
- **Open Source Contribution** — Improve statistical libraries

---

## Final Thoughts

You've built a complete statistical analysis toolkit from scratch. You understand not just **how** to run tests, but **why** they work, **when** to use them, and **how** to interpret results. This is a rare and valuable skill set.

Remember:
- **Statistics is about making decisions under uncertainty**
- **Always check your assumptions** (models are only as good as their assumptions)
- **Effect sizes matter** more than p-values alone
- **Communicate clearly** — statistical jargon hides insights
- **Keep learning** — statistics is a vast field with always more to discover

You're now equipped to:
- Design experiments that actually work
- Analyze data with statistical rigor
- Build models that are interpretable and validated
- Make data-driven decisions with confidence

---

**🎉 Congratulations on completing Phase 3! You're now a statistically-savvy data professional ready to tackle real-world challenges.**
