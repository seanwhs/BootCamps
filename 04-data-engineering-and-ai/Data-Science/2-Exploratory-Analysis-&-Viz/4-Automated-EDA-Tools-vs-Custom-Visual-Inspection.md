# Phase 2: Exploratory Data Analysis & Visualization

## Module 2.1: Systematic EDA & Data Profiling

### Part 4: Automated EDA Tools vs. Custom Visual Inspection

---

#### The Target

In this part, we'll explore the landscape of automated EDA tools and learn when to use them versus when to write custom visualizations. By the end, you'll have:

1. Hands-on experience with three major automated EDA libraries
2. A comparison framework to decide when to use automated vs. custom approaches
3. Integrated automated profiling into our workflow
4. A deep understanding of what automated tools miss and why human intuition still matters

---

#### The Concept

**The Automated EDA Revolution**

Think of automated EDA tools like a spell-checker for your data. They quickly flag obvious issues, generate comprehensive reports, and save you from tedious manual work. But just like a spell-checker can't tell you if your writing is persuasive or logical, automated EDA tools can't tell you if your data tells a meaningful story.

**When to use automated tools:**
- **Initial data exploration:** Get a quick overview of a new dataset in minutes
- **Quality checks:** Quickly identify missing values, outliers, and data type issues
- **Documentation:** Generate comprehensive reports for stakeholders
- **Baseline understanding:** Establish what "normal" looks like before deep diving

**When to use custom visual inspection:**
- **Investigating unexpected patterns:** Automated tools flag anomalies, but you need custom plots to understand them
- **Domain-specific analysis:** You know what questions matter in your field
- **Presentation-quality visuals:** Automated reports look generic; custom visuals tell your specific story
- **Hypothesis testing:** You have specific questions that automated reports don't answer

**The tools we'll explore:**
1. **pandas-profiling (now ydata-profiling):** The pioneer in automated EDA. Generates comprehensive HTML reports with interactive visualizations.

2. **D-Tale:** An interactive, GUI-based EDA tool built into your Jupyter notebook. Think of it as Excel + pandas in your browser.

3. **Sweetviz:** Focuses on comparing datasets (e.g., training vs. test, before vs. after cleaning).

---

#### The Implementation

##### Step 1: Install Automated EDA Libraries

First, let's install the tools we'll be exploring:

```bash
# Install automated EDA libraries
pip install ydata-profiling
pip install dtale
pip install sweetviz

# Also install lux for an alternative approach (optional)
pip install lux-api
```

Add these to your requirements.txt for future reference:

**File:** `requirements_eda_tools.txt`
```txt
ydata-profiling>=4.0.0
dtale>=2.0.0
sweetviz>=2.0.0
lux-api>=0.4.0
```

---

##### Step 2: Create the Automated EDA Comparison Module

**File:** `src/automated_eda.py`
```python
"""
Automated EDA Tools Comparison Module

Explores and compares various automated EDA tools:
- ydata-profiling (formerly pandas-profiling)
- D-Tale
- Sweetviz
- Lux

Provides utilities to generate reports and compare results.
"""

import pandas as pd
import numpy as np
from pathlib import Path
import json
import time
import warnings
warnings.filterwarnings('ignore')

class AutomatedEDAComparator:
    """
    A class to generate and compare automated EDA reports.
    
    This class wraps multiple automated EDA tools and provides
    a unified interface for generating reports and benchmarks.
    """
    
    def __init__(self, df: pd.DataFrame, output_dir: str = "outputs/eda_reports"):
        """
        Initialize the comparator with a DataFrame.
        
        Parameters:
        -----------
        df : pd.DataFrame
            The dataset to analyze
        output_dir : str
            Directory for saving reports
        """
        self.df = df.copy()
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        self.timing_results = {}
        self.report_paths = {}
        
        print(f"📊 Analyzing dataset with {df.shape[0]} rows, {df.shape[1]} columns")
    
    # ---------- YDATA-PROFILING ----------
    
    def generate_ydata_profile(self) -> dict:
        """
        Generate a comprehensive profile report using ydata-profiling.
        
        ydata-profiling generates an interactive HTML report with:
        - Overview statistics
        - Variable details (distributions, missing values, correlations)
        - Interactive visualizations
        - Alerts for data quality issues
        
        Returns:
        --------
        dict
            Timing and path information
        """
        from ydata_profiling import ProfileReport
        
        print("\n🔍 Generating ydata-profiling report...")
        start_time = time.time()
        
        try:
            # Create profile
            profile = ProfileReport(
                self.df,
                title="Customer Data Profile Report",
                explorative=True,
                minimal=False,
                interactions={
                    "continuous": True,
                    "categorical": True
                },
                correlations={
                    "pearson": {"calculate": True},
                    "spearman": {"calculate": True},
                    "cramers": {"calculate": True}
                },
                missing_diagrams={
                    "bar": True,
                    "matrix": True,
                    "heatmap": True
                }
            )
            
            # Save report
            report_path = self.output_dir / "ydata_profile_report.html"
            profile.to_file(str(report_path))
            
            # Also save as JSON for programmatic access
            json_path = self.output_dir / "ydata_profile_data.json"
            profile.to_file(str(json_path))
            
            elapsed_time = time.time() - start_time
            self.timing_results['ydata_profiling'] = elapsed_time
            self.report_paths['ydata_profiling'] = report_path
            
            print(f"  ✅ Report generated in {elapsed_time:.2f} seconds")
            print(f"  📄 Report saved to: {report_path}")
            
            return {
                'path': report_path,
                'time': elapsed_time,
                'profile': profile
            }
            
        except Exception as e:
            print(f"  ❌ Error generating ydata profile: {str(e)}")
            return {'error': str(e)}
    
    # ---------- D-TALE ----------
    
    def generate_dtale_report(self, host: str = "127.0.0.1", port: int = 40000) -> dict:
        """
        Launch an interactive D-Tale session.
        
        D-Tale provides an in-browser interface for exploring data:
        - Interactive filtering and sorting
        - Chart builder for custom visualizations
        - Data manipulation UI
        - Column analysis and statistics
        
        Note: This launches a web server that runs until stopped.
        
        Parameters:
        -----------
        host : str
            Host address for the server
        port : int
            Port for the server
            
        Returns:
        --------
        dict
            Information about the launched session
        """
        import dtale
        
        print(f"\n🚀 Launching D-Tale server on {host}:{port}...")
        start_time = time.time()
        
        try:
            # Launch D-Tale instance
            d = dtale.show(
                self.df,
                host=host,
                port=port,
                subprocess=False,
                open_browser=True,
                name="Customer Data Explorer"
            )
            
            elapsed_time = time.time() - start_time
            self.timing_results['dtale'] = elapsed_time
            
            print(f"  ✅ D-Tale launched in {elapsed_time:.2f} seconds")
            print(f"  🌐 Access at: http://{host}:{port}")
            print("  ⚠️  Press Ctrl+C in terminal to stop the server when done")
            
            return {
                'instance': d,
                'url': f"http://{host}:{port}",
                'time': elapsed_time
            }
            
        except Exception as e:
            print(f"  ❌ Error launching D-Tale: {str(e)}")
            return {'error': str(e)}
    
    # ---------- SWEETVIZ ----------
    
    def generate_sweetviz_report(self, compare_col: str = None) -> dict:
        """
        Generate a Sweetviz report with optional comparisons.
        
        Sweetviz is great for:
        - Comparing two datasets (e.g., train vs. test)
        - Comparing segments within a dataset
        - Visualizing associations
        
        Parameters:
        -----------
        compare_col : str
            Column to use for comparison (e.g., 'gender' to compare groups)
            
        Returns:
        --------
        dict
            Timing and path information
        """
        import sweetviz as sv
        
        print("\n🍬 Generating Sweetviz report...")
        start_time = time.time()
        
        try:
            if compare_col:
                # Compare groups based on a column
                report = sv.compare_intra(
                    self.df,
                    compare_col,
                    target_feat=compare_col,
                    feat_cfg=sv.FeatureConfig(skip=['customer_id'] if 'customer_id' in self.df.columns else [])
                )
                report_name = f"sweetviz_comparison_{compare_col}.html"
            else:
                # Standard analysis
                report = sv.analyze(
                    self.df,
                    target_feat=None,
                    feat_cfg=sv.FeatureConfig(skip=['customer_id'] if 'customer_id' in self.df.columns else [])
                )
                report_name = "sweetviz_report.html"
            
            # Save report
            report_path = self.output_dir / report_name
            report.show_html(str(report_path))
            
            elapsed_time = time.time() - start_time
            self.timing_results['sweetviz'] = elapsed_time
            self.report_paths['sweetviz'] = report_path
            
            print(f"  ✅ Report generated in {elapsed_time:.2f} seconds")
            print(f"  📄 Report saved to: {report_path}")
            
            return {
                'path': report_path,
                'time': elapsed_time,
                'report': report
            }
            
        except Exception as e:
            print(f"  ❌ Error generating Sweetviz report: {str(e)}")
            return {'error': str(e)}
    
    # ---------- LUX ----------
    
    def demonstrate_lux(self) -> dict:
        """
        Demonstrate Lux for intelligent visualization recommendations.
        
        Lux automatically suggests visualizations based on your data
        and interacts seamlessly with pandas DataFrames.
        
        Returns:
        --------
        dict
            Information about the Lux session
        """
        import lux
        
        print("\n💡 Setting up Lux for intelligent visualization...")
        
        try:
            # Activate Lux widget
            lux.config.default_theme = 'dark'
            
            # Create Lux DataFrame
            lux_df = self.df.copy()
            
            # Add intent-based recommendations
            # Lux will automatically generate visualizations based on data types
            
            print("  ✅ Lux is ready!")
            print("  📝 In your Jupyter notebook, add 'import lux'")
            print("  📝 Then call .widget() on your DataFrame")
            
            # Return a sample of recommendations
            # This shows what Lux would recommend
            recommendations = {
                'numerical_distributions': [col for col in lux_df.select_dtypes(include=[np.number]).columns[:5]],
                'categorical_distributions': [col for col in lux_df.select_dtypes(include=['object']).columns[:5]]
            }
            
            return {
                'status': 'ready',
                'recommendations': recommendations,
                'note': 'Lux works best in Jupyter notebooks with widget support'
            }
            
        except Exception as e:
            print(f"  ❌ Error setting up Lux: {str(e)}")
            return {'error': str(e)}
    
    # ---------- COMPARISON ----------
    
    def compare_all_tools(self, launch_dtale: bool = True) -> dict:
        """
        Run all automated EDA tools and compare their outputs.
        
        Parameters:
        -----------
        launch_dtale : bool
            Whether to launch D-Tale (requires manual shutdown)
            
        Returns:
        --------
        dict
            Comparison results
        """
        print("\n" + "=" * 60)
        print("AUTOMATED EDA TOOLS COMPARISON")
        print("=" * 60)
        
        results = {
            'tools_tested': [],
            'timing': {},
            'paths': {},
            'recommendations': []
        }
        
        # 1. ydata-profiling
        print("\n" + "-" * 60)
        print("Tool 1: ydata-profiling")
        print("-" * 60)
        ydata_result = self.generate_ydata_profile()
        results['tools_tested'].append('ydata_profiling')
        results['timing']['ydata_profiling'] = ydata_result.get('time', None)
        results['paths']['ydata_profiling'] = ydata_result.get('path', None)
        
        # 2. Sweetviz
        print("\n" + "-" * 60)
        print("Tool 2: Sweetviz")
        print("-" * 60)
        sweetviz_result = self.generate_sweetviz_report()
        results['tools_tested'].append('sweetviz')
        results['timing']['sweetviz'] = sweetviz_result.get('time', None)
        results['paths']['sweetviz'] = sweetviz_result.get('path', None)
        
        # Generate a comparison report (e.g., compare male vs. female)
        if 'gender' in self.df.columns:
            print("\n" + "-" * 60)
            print("Sweetviz Comparison Report")
            print("-" * 60)
            compare_result = self.generate_sweetviz_report(compare_col='gender')
            results['paths']['sweetviz_comparison'] = compare_result.get('path', None)
        
        # 3. D-Tale (optional, requires manual shutdown)
        if launch_dtale:
            print("\n" + "-" * 60)
            print("Tool 3: D-Tale")
            print("-" * 60)
            print("Launching D-Tale (press Ctrl+C when done to continue)...")
            dtale_result = self.generate_dtale_report()
            results['tools_tested'].append('dtale')
            results['timing']['dtale'] = dtale_result.get('time', None)
            results['dtale_url'] = dtale_result.get('url', None)
        
        # 4. Lux (demonstration only)
        print("\n" + "-" * 60)
        print("Tool 4: Lux")
        print("-" * 60)
        lux_result = self.demonstrate_lux()
        results['tools_tested'].append('lux')
        results['lux'] = lux_result
        
        # Generate recommendations
        print("\n" + "=" * 60)
        print("COMPARISON RESULTS")
        print("=" * 60)
        
        # Find fastest tool
        valid_timings = {k: v for k, v in results['timing'].items() if v is not None}
        if valid_timings:
            fastest = min(valid_timings, key=valid_timings.get)
            print(f"\n🚀 Fastest tool: {fastest} ({valid_timings[fastest]:.2f} seconds)")
            
        print("\n📊 Tool capabilities summary:")
        print("  • ydata-profiling: Most comprehensive, best for documentation")
        print("  • Sweetviz: Best for comparing groups/datasets")
        print("  • D-Tale: Best for interactive, ad-hoc exploration")
        print("  • Lux: Best for intelligent visualization recommendations")
        
        print("\n💡 Recommendations:")
        print("  • Use ydata-profiling for: Initial data overview, stakeholder reports")
        print("  • Use Sweetviz for: Comparing training vs. test data, A/B test analysis")
        print("  • Use D-Tale for: Deep, interactive exploration of complex datasets")
        print("  • Use Lux for: Quick visualization suggestions in notebooks")
        print("  • Use custom plots when: You need publication quality or domain-specific visuals")
        
        return results


# ---------- UTILITY FUNCTIONS ----------

def compare_with_custom_analysis(results: dict) -> str:
    """
    Generate a comparison between automated tools and custom analysis.
    
    Parameters:
    -----------
    results : dict
        Results from AutomatedEDAComparator
        
    Returns:
    --------
    str
        Comparison report
    """
    report_lines = []
    report_lines.append("=" * 70)
    report_lines.append("AUTOMATED EDA vs. CUSTOM ANALYSIS COMPARISON")
    report_lines.append("=" * 70)
    
    report_lines.append("\n📊 SPEED COMPARISON:")
    if results.get('timing'):
        for tool, timing in results['timing'].items():
            if timing:
                report_lines.append(f"  • {tool}: {timing:.2f} seconds")
    
    report_lines.append("\n📈 COMPREHENSIVENESS:")
    report_lines.append("  • Automated tools: Generate 50+ statistics and visualizations")
    report_lines.append("  • Custom analysis: Focused, domain-specific insights")
    
    report_lines.append("\n🎯 WHEN TO USE AUTOMATED TOOLS:")
    report_lines.append("  • ✅ Initial data exploration (minutes vs. hours)")
    report_lines.append("  • ✅ Quality assurance and data validation")
    report_lines.append("  • ✅ Documentation for stakeholders")
    report_lines.append("  • ✅ Baseline understanding before deep analysis")
    
    report_lines.append("\n👁️ WHEN TO USE CUSTOM VISUAL INSPECTION:")
    report_lines.append("  • ✅ Investigating unexpected patterns")
    report_lines.append("  • ✅ Domain-specific visualizations")
    report_lines.append("  • ✅ Publication-ready figures")
    report_lines.append("  • ✅ Testing specific hypotheses")
    report_lines.append("  • ✅ Exploratory storytelling")
    
    report_lines.append("\n🔑 KEY TAKEAWAY:")
    report_lines.append("  " + "=" * 50)
    report_lines.append("  Automated tools are the 'high-level survey' - they show you")
    report_lines.append("  where to dig. Custom analysis is the 'excavation' - it's")
    report_lines.append("  where you find the real insights.")
    report_lines.append("  " + "=" * 50)
    
    return "\n".join(report_lines)


def run_automated_eda_comparison(data_path: str = "data/customer_data.csv",
                                output_dir: str = "outputs/eda_reports",
                                launch_dtale: bool = False) -> dict:
    """
    Convenience function to run the automated EDA comparison.
    
    Parameters:
    -----------
    data_path : str
        Path to the CSV file
    output_dir : str
        Directory for saving reports
    launch_dtale : bool
        Whether to launch D-Tale (requires manual shutdown)
        
    Returns:
    --------
    dict
        Comparison results
    """
    print("📂 Loading dataset...")
    df = pd.read_csv(data_path)
    print(f"✅ Loaded {df.shape[0]} rows and {df.shape[1]} columns")
    
    # Create comparator
    comparator = AutomatedEDAComparator(df, output_dir=output_dir)
    
    # Run comparison
    results = comparator.compare_all_tools(launch_dtale=launch_dtale)
    
    # Generate comparison report
    comparison_text = compare_with_custom_analysis(results)
    report_path = Path(output_dir) / "automated_vs_custom_comparison.txt"
    report_path.parent.mkdir(parents=True, exist_ok=True)
    with open(report_path, 'w') as f:
        f.write(comparison_text)
    print(f"\n📄 Comparison report saved to: {report_path}")
    
    return results


if __name__ == "__main__":
    # Run the comparison (without launching D-Tale for simplicity)
    results = run_automated_eda_comparison(launch_dtale=False)
```

---

##### Step 3: Create a Custom Visual Inspection Module

Now let's create a complementary module that demonstrates what automated tools miss and why custom inspection is valuable:

**File:** `src/custom_visual_inspection.py`
```python
"""
Custom Visual Inspection Module

Demonstrates how to go beyond automated EDA tools with
targeted, domain-specific visualizations that reveal
deeper insights about the data.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from scipy import stats
import warnings
warnings.filterwarnings('ignore')

class CustomVisualInspector:
    """
    A class for creating targeted, custom visualizations
    that go beyond what automated EDA tools provide.
    """
    
    def __init__(self, df: pd.DataFrame, output_dir: str = "outputs/figures"):
        """
        Initialize the inspector with a DataFrame.
        
        Parameters:
        -----------
        df : pd.DataFrame
            The dataset to analyze
        output_dir : str
            Directory for saving figures
        """
        self.df = df.copy()
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        plt.style.use('seaborn-v0_8-darkgrid')
        sns.set_palette("husl")
    
    def investigate_missing_patterns(self) -> plt.Figure:
        """
        Create a visualization showing patterns in missing data.
        
        Automated tools show count of missing values, but custom
        plots can reveal patterns - are missing values random
        or concentrated in specific segments?
        """
        fig, axes = plt.subplots(2, 1, figsize=(14, 10))
        
        # Plot 1: Missing value count per column
        missing_counts = self.df.isnull().sum()
        missing_counts = missing_counts[missing_counts > 0].sort_values()
        
        if missing_counts.empty:
            axes[0].text(0.5, 0.5, "No missing values found!", 
                        ha='center', va='center', fontsize=14)
        else:
            bars = axes[0].bar(missing_counts.index, missing_counts.values,
                              color='coral', edgecolor='black')
            axes[0].set_title('Missing Values by Column', fontsize=14, fontweight='bold')
            axes[0].set_xlabel('Column')
            axes[0].set_ylabel('Number of Missing Values')
            axes[0].tick_params(axis='x', rotation=45)
            
            # Add count labels
            for bar in bars:
                height = bar.get_height()
                axes[0].text(bar.get_x() + bar.get_width()/2., height,
                            f'{int(height)}',
                            ha='center', va='bottom', fontsize=10)
        
        # Plot 2: Missingness heatmap (shows patterns)
        # Create a matrix showing missing values (1 if missing, 0 otherwise)
        missing_matrix = self.df.isnull().astype(int)
        
        # Only include columns with some missing values
        if not missing_matrix.empty:
            missing_cols = missing_matrix.columns[missing_matrix.sum() > 0]
            if len(missing_cols) > 0:
                # Sample rows to keep plot readable (max 100 rows)
                sample_size = min(100, len(missing_matrix))
                sampled_data = missing_matrix[missing_cols].iloc[:sample_size]
                
                # Create heatmap
                sns.heatmap(sampled_data.T, 
                           cmap=['white', 'navy'],
                           cbar=False,
                           xticklabels=False,
                           ax=axes[1])
                axes[1].set_title('Missing Value Patterns (First 100 rows)', 
                                 fontsize=14, fontweight='bold')
                axes[1].set_xlabel('Row Index')
                axes[1].set_ylabel('Column')
        
        plt.tight_layout()
        fig_path = self.output_dir / 'custom_missing_patterns.png'
        plt.savefig(fig_path, dpi=300, bbox_inches='tight')
        print(f"  ✅ Saved: {fig_path}")
        
        return fig
    
    def investigate_outlier_context(self) -> plt.Figure:
        """
        Create visualizations showing context of outliers.
        
        Automated tools flag outliers but don't explain WHY
        they might exist. Custom plots can reveal if outliers
        correspond to specific customer segments.
        """
        fig, axes = plt.subplots(2, 3, figsize=(18, 10))
        axes = axes.flatten()
        
        # Select numerical columns with potential outliers
        num_cols = ['age', 'time_on_site', 'avg_order_value', 
                    'order_frequency', 'return_rate']
        plot_idx = 0
        
        for col in num_cols:
            if col not in self.df.columns:
                continue
                
            ax = axes[plot_idx]
            series = self.df[col].dropna()
            
            # Create boxplot with jittered points
            sns.boxplot(y=series, ax=ax, color='steelblue', flierprops={'alpha': 0.5})
            
            # Add jittered points to show distribution
            sns.stripplot(y=series, ax=ax, color='darkblue', 
                         alpha=0.3, size=3, jitter=True)
            
            # Add outlier context: what segments do outliers belong to?
            q1 = series.quantile(0.25)
            q3 = series.quantile(0.75)
            iqr = q3 - q1
            lower_bound = q1 - 1.5 * iqr
            upper_bound = q3 + 1.5 * iqr
            
            outliers = series[(series < lower_bound) | (series > upper_bound)]
            n_outliers = len(outliers)
            pct_outliers = (n_outliers / len(series)) * 100
            
            ax.set_title(f'{col}\nOutliers: {n_outliers} ({pct_outliers:.1f}%)',
                        fontsize=12, fontweight='bold')
            ax.set_ylabel(col)
            
            # Annotate if outliers are significant
            if pct_outliers > 5:
                ax.text(0.02, 0.98, f"⚠️ High outlier rate", 
                       transform=ax.transAxes, fontsize=10,
                       verticalalignment='top',
                       bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.7))
            
            plot_idx += 1
        
        # Remove unused subplots
        for idx in range(plot_idx, 6):
            fig.delaxes(axes[idx])
        
        plt.suptitle('Outlier Analysis with Context', fontsize=16, fontweight='bold')
        plt.tight_layout()
        fig_path = self.output_dir / 'custom_outlier_context.png'
        plt.savefig(fig_path, dpi=300, bbox_inches='tight')
        print(f"  ✅ Saved: {fig_path}")
        
        return fig
    
    def investigate_segment_differences(self) -> plt.Figure:
        """
        Create visualizations that reveal segment differences.
        
        Automated tools show global distributions but don't
        automatically highlight segment differences that are
        business-relevant.
        """
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        
        # 1. Age distribution by income bracket
        ax = axes[0, 0]
        income_order = ['<$25K', '$25K-$50K', '$50K-$75K', 
                        '$75K-$100K', '>$100K']
        for income in income_order:
            data = self.df[self.df['income_bracket'] == income]['age'].dropna()
            if not data.empty:
                sns.kdeplot(data, label=income, ax=ax, fill=True, alpha=0.3)
        ax.set_title('Age Distribution by Income Bracket', fontsize=12, fontweight='bold')
        ax.set_xlabel('Age')
        ax.set_ylabel('Density')
        ax.legend()
        
        # 2. Order frequency by favorite category
        ax = axes[0, 1]
        cat_order = self.df.groupby('favorite_category')['order_frequency'].mean().sort_values().index
        sns.boxplot(x='favorite_category', y='order_frequency', data=self.df,
                   order=cat_order, ax=ax, palette='husl')
        ax.set_title('Order Frequency by Favorite Category', fontsize=12, fontweight='bold')
        ax.set_xlabel('Favorite Category')
        ax.set_ylabel('Order Frequency')
        ax.tick_params(axis='x', rotation=45)
        
        # 3. Satisfaction by city tier
        ax = axes[1, 0]
        city_labels = {1: 'Major Metro', 2: 'Mid-size', 3: 'Small City'}
        self.df['city_tier_label'] = self.df['city_tier'].map(city_labels)
        sns.violinplot(x='city_tier_label', y='customer_rating', 
                      data=self.df.dropna(subset=['customer_rating']),
                      ax=ax, palette='viridis')
        ax.set_title('Customer Rating by City Tier', fontsize=12, fontweight='bold')
        ax.set_xlabel('City Tier')
        ax.set_ylabel('Customer Rating')
        
        # 4. Return rate vs. rating with segment overlay
        ax = axes[1, 1]
        scatter = ax.scatter(self.df['customer_rating'], self.df['return_rate'],
                           c=self.df['income_numeric'] if 'income_numeric' in self.df.columns else 'blue',
                           alpha=0.5, s=30, cmap='plasma')
        ax.set_xlabel('Customer Rating')
        ax.set_ylabel('Return Rate (%)')
        ax.set_title('Return Rate vs. Rating (Colored by Income)', 
                    fontsize=12, fontweight='bold')
        if 'income_numeric' in self.df.columns:
            plt.colorbar(scatter, ax=ax, label='Income Level')
        
        plt.suptitle('Segment Differences Revealed Through Custom Visualizations', 
                    fontsize=16, fontweight='bold')
        plt.tight_layout()
        fig_path = self.output_dir / 'custom_segment_differences.png'
        plt.savefig(fig_path, dpi=300, bbox_inches='tight')
        print(f"  ✅ Saved: {fig_path}")
        
        return fig
    
    def investigate_temporal_patterns(self) -> plt.Figure:
        """
        Create visualizations showing patterns over time.
        
        Automated tools often ignore temporal patterns.
        Custom plots can reveal seasonality, trends, and cohort effects.
        """
        # Convert timestamps
        self.df['account_created'] = pd.to_datetime(self.df['account_created'])
        self.df['last_purchase'] = pd.to_datetime(self.df['last_purchase'])
        
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        
        # 1. Account creation over time
        ax = axes[0, 0]
        self.df['account_created'].dt.month.plot.hist(bins=12, ax=ax, color='steelblue', edgecolor='black')
        ax.set_title('Account Creation by Month', fontsize=12, fontweight='bold')
        ax.set_xlabel('Month')
        ax.set_ylabel('Number of Accounts')
        
        # 2. Account creation by year
        ax = axes[0, 1]
        self.df['account_created'].dt.year.value_counts().sort_index().plot(kind='bar', ax=ax, color='coral')
        ax.set_title('Account Creation by Year', fontsize=12, fontweight='bold')
        ax.set_xlabel('Year')
        ax.set_ylabel('Number of Accounts')
        
        # 3. Days since last purchase
        ax = axes[1, 0]
        self.df['days_since_purchase'] = (pd.Timestamp.now() - self.df['last_purchase']).dt.days
        self.df['days_since_purchase'].hist(bins=30, ax=ax, color='forestgreen', edgecolor='black')
        ax.set_title('Days Since Last Purchase', fontsize=12, fontweight='bold')
        ax.set_xlabel('Days')
        ax.set_ylabel('Number of Customers')
        ax.axvline(self.df['days_since_purchase'].median(), color='red', linestyle='--', 
                   label=f"Median: {self.df['days_since_purchase'].median():.0f} days")
        ax.legend()
        
        # 4. Time since account creation vs. purchase activity
        ax = axes[1, 1]
        self.df['account_age_days'] = (pd.Timestamp.now() - self.df['account_created']).dt.days
        scatter = ax.scatter(self.df['account_age_days'], self.df['order_frequency'],
                           c=self.df['avg_order_value'], alpha=0.5, cmap='viridis')
        ax.set_xlabel('Account Age (Days)')
        ax.set_ylabel('Order Frequency')
        ax.set_title('Account Age vs. Order Frequency (Color = Order Value)', 
                    fontsize=12, fontweight='bold')
        plt.colorbar(scatter, ax=ax, label='Avg Order Value')
        
        plt.suptitle('Temporal Patterns in Customer Data', 
                    fontsize=16, fontweight='bold')
        plt.tight_layout()
        fig_path = self.output_dir / 'custom_temporal_patterns.png'
        plt.savefig(fig_path, dpi=300, bbox_inches='tight')
        print(f"  ✅ Saved: {fig_path}")
        
        return fig
    
    def investigate_interaction_effects(self) -> plt.Figure:
        """
        Create visualizations showing interaction effects.
        
        Automated tools show main effects (A correlates with B),
        but not interactions (A's effect on B changes depending on C).
        """
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        
        # 1. Age x Income effect on Order Frequency
        ax = axes[0, 0]
        # Create age groups
        self.df['age_group'] = pd.cut(self.df['age'], bins=[0, 25, 35, 45, 55, 100],
                                     labels=['<25', '25-35', '35-45', '45-55', '55+'])
        
        # Map income to numeric
        income_order = ['<$25K', '$25K-$50K', '$50K-$75K', '$75K-$100K', '>$100K']
        self.df['income_numeric'] = self.df['income_bracket'].map(
            {v: i for i, v in enumerate(income_order)}
        )
        
        # Create heatmap of mean order frequency
        pivot = self.df.pivot_table(
            values='order_frequency',
            index='age_group',
            columns='income_numeric',
            aggfunc='mean'
        )
        sns.heatmap(pivot, ax=ax, annot=True, fmt='.2f', cmap='RdBu_r', center=0.5)
        ax.set_title('Order Frequency: Age × Income Interaction', fontsize=12, fontweight='bold')
        ax.set_xlabel('Income Level (0=Low, 4=High)')
        ax.set_ylabel('Age Group')
        
        # 2. City Tier × Category effect on Order Value
        ax = axes[0, 1]
        pivot2 = self.df.pivot_table(
            values='avg_order_value',
            index='city_tier',
            columns='favorite_category',
            aggfunc='mean'
        )
        sns.heatmap(pivot2, ax=ax, annot=True, fmt='.0f', cmap='viridis')
        ax.set_title('Order Value: City Tier × Category Interaction', fontsize=12, fontweight='bold')
        ax.set_xlabel('Favorite Category')
        ax.set_ylabel('City Tier')
        
        # 3. Age × Gender effect on Rating
        ax = axes[1, 0]
        # Only include top 3 age groups for clarity
        top_age_groups = self.df['age_group'].value_counts().head(3).index
        filtered = self.df[self.df['age_group'].isin(top_age_groups)]
        sns.boxplot(x='age_group', y='customer_rating', hue='gender', 
                   data=filtered.dropna(subset=['customer_rating']),
                   ax=ax, palette='Set2')
        ax.set_title('Rating: Age × Gender Interaction', fontsize=12, fontweight='bold')
        ax.set_xlabel('Age Group')
        ax.set_ylabel('Customer Rating')
        ax.legend(loc='upper right')
        
        # 4. Engagement × Income effect on Return Rate
        ax = axes[1, 1]
        # Create engagement groups (low, medium, high based on time_on_site)
        self.df['engagement_group'] = pd.cut(self.df['time_on_site'], 
                                            bins=[0, 5, 15, 100],
                                            labels=['Low', 'Medium', 'High'])
        # Filter income groups
        income_groups = ['<$25K', '$25K-$50K', '$50K-$75K']
        filtered_income = self.df[self.df['income_bracket'].isin(income_groups)]
        sns.boxplot(x='engagement_group', y='return_rate', hue='income_bracket',
                   data=filtered_income.dropna(subset=['return_rate']),
                   ax=ax, palette='Blues')
        ax.set_title('Return Rate: Engagement × Income Interaction', fontsize=12, fontweight='bold')
        ax.set_xlabel('Engagement Level')
        ax.set_ylabel('Return Rate (%)')
        ax.legend(loc='upper right')
        
        plt.suptitle('Interaction Effects: How Variables Work Together', 
                    fontsize=16, fontweight='bold')
        plt.tight_layout()
        fig_path = self.output_dir / 'custom_interaction_effects.png'
        plt.savefig(fig_path, dpi=300, bbox_inches='tight')
        print(f"  ✅ Saved: {fig_path}")
        
        return fig
    
    def run_all_inspections(self) -> dict:
        """
        Run all custom visual inspections.
        
        Returns:
        --------
        dict
            Dictionary of all generated figures
        """
        print("\n" + "=" * 60)
        print("CUSTOM VISUAL INSPECTION - STARTING")
        print("=" * 60)
        
        results = {}
        
        print("\n🔍 Investigating missing data patterns...")
        results['missing_patterns'] = self.investigate_missing_patterns()
        
        print("\n🔍 Investigating outlier context...")
        results['outlier_context'] = self.investigate_outlier_context()
        
        print("\n🔍 Investigating segment differences...")
        results['segment_differences'] = self.investigate_segment_differences()
        
        print("\n🔍 Investigating temporal patterns...")
        results['temporal_patterns'] = self.investigate_temporal_patterns()
        
        print("\n🔍 Investigating interaction effects...")
        results['interaction_effects'] = self.investigate_interaction_effects()
        
        print("\n" + "=" * 60)
        print("CUSTOM VISUAL INSPECTION - COMPLETE")
        print("=" * 60)
        
        print("\n💡 What automated tools typically miss in our analysis:")
        print("  1. Missing data patterns: Are missing values random or systematic?")
        print("  2. Outlier context: Do outliers correspond to specific customer segments?")
        print("  3. Segment differences: How do customer behaviors vary by group?")
        print("  4. Temporal patterns: Are there seasonal or trend effects?")
        print("  5. Interaction effects: How do variables combine to influence outcomes?")
        
        return results


def run_custom_inspection(data_path: str = "data/customer_data.csv",
                         output_dir: str = "outputs/figures") -> dict:
    """
    Convenience function to run custom visual inspection.
    
    Parameters:
    -----------
    data_path : str
        Path to the CSV file
    output_dir : str
        Directory for saving figures
        
    Returns:
    --------
    dict
        Results of the inspection
    """
    print("📂 Loading dataset...")
    df = pd.read_csv(data_path)
    print(f"✅ Loaded {df.shape[0]} rows and {df.shape[1]} columns")
    
    # Create inspector
    inspector = CustomVisualInspector(df, output_dir=output_dir)
    
    # Run inspections
    results = inspector.run_all_inspections()
    
    return results


if __name__ == "__main__":
    results = run_custom_inspection()
```

---

#### The Verification

**Verification 1: Check Automated Reports**

```bash
# List generated automated reports
ls -la outputs/eda_reports/

# Open ydata profile in browser (on macOS)
open outputs/eda_reports/ydata_profile_report.html

# On Linux:
xdg-open outputs/eda_reports/ydata_profile_report.html

# On Windows:
start outputs/eda_reports/ydata_profile_report.html
```

**Verification 2: Check Custom Visualizations**

```bash
# List custom figures
ls -la outputs/figures/custom_*.png

# Check the custom vs automated comparison
cat outputs/eda_reports/automated_vs_custom_comparison.txt
```

**Verification 3: Quick Comparison Script**

**File:** `src/compare_eda_approaches.py`
```python
"""
Quick script to compare automated vs custom approaches.
"""

import pandas as pd
from pathlib import Path

def compare_approaches():
    """Generate a quick comparison summary."""
    
    print("=" * 60)
    print("AUTOMATED vs. CUSTOM EDA COMPARISON")
    print("=" * 60)
    
    # Check what files were generated
    automated_dir = Path("outputs/eda_reports")
    custom_dir = Path("outputs/figures")
    
    automated_files = list(automated_dir.glob("*.html")) if automated_dir.exists() else []
    custom_files = list(custom_dir.glob("custom_*.png")) if custom_dir.exists() else []
    
    print(f"\n📁 Automated reports generated: {len(automated_files)}")
    for f in automated_files:
        size = f.stat().st_size / 1024  # KB
        print(f"  • {f.name} ({size:.1f} KB)")
    
    print(f"\n📁 Custom visualizations generated: {len(custom_files)}")
    for f in custom_files:
        size = f.stat().st_size / 1024
        print(f"  • {f.name} ({size:.1f} KB)")
    
    # Load comparison report
    comp_path = Path("outputs/eda_reports/automated_vs_custom_comparison.txt")
    if comp_path.exists():
        print("\n" + "=" * 60)
        with open(comp_path, 'r') as f:
            print(f.read())
    
    print("\n" + "=" * 60)
    print("🔑 KEY INSIGHT:")
    print("  Both approaches have their place. Use automated tools for")
    print("  speed and breadth; use custom inspection for depth and context.")
    print("=" * 60)

if __name__ == "__main__":
    compare_approaches()
```

Run it:
```bash
python src/compare_eda_approaches.py
```

---

#### What We've Accomplished

In this part, we've:

1. ✅ Explored four major automated EDA tools:
   - **ydata-profiling:** Most comprehensive, best for documentation and stakeholder reports
   - **Sweetviz:** Excellent for comparing groups (training vs. test, A/B test groups)
   - **D-Tale:** Interactive GUI for ad-hoc exploration, great for non-technical stakeholders
   - **Lux:** Intelligent visualization recommendations within notebooks

2. ✅ Learned the speed vs. depth trade-off:
   - Automated tools generate comprehensive reports in seconds
   - Custom inspection takes more time but reveals deeper patterns

3. ✅ Discovered what automated tools miss:
   - **Missing value patterns:** Are missing values random or systematic?
   - **Outlier context:** Why do outliers exist? Do they represent meaningful segments?
   - **Segment differences:** How do groups differ beyond global distributions?
   - **Temporal patterns:** What trends and seasonality exist?
   - **Interaction effects:** How do variables combine to influence outcomes?

4. ✅ Created a framework for deciding when to use each approach:
   - **Use automated tools for:** Initial surveys, QA, documentation, baseline understanding
   - **Use custom inspection for:** Deep dives, domain-specific questions, publication-ready visuals, storytelling

---

#### Deep Dive Reference: The Psychology of Data Exploration

**Why Automated Tools Can't Replace Human Intuition**

**The "Answering Questions" Problem:**
Automated tools are great at asking generic questions (What are the distributions? What are the correlations?). But they can't ask the right questions for your specific domain.

**Example:** 
- Automated tool: "Here are 50 correlations..."
- Human: "Why do middle-aged customers in Tier 1 cities have higher order frequencies? Let me investigate..."

**The Pattern Recognition Advantage:**
Humans are exceptional at recognizing patterns, especially when presented visually. Automated tools generate patterns, but they don't interpret them in context.

**The Confirmation Bias Trap:**
Automated tools don't know what you're looking for. They're neutral. But this can be a weakness—they might not emphasize what's truly important in your domain.

**The Communication Gap:**
Automated reports are comprehensive but generic. Custom visualizations can be tailored to tell a specific story to a specific audience.

**The Practical Workflow**

The most effective approach combines both:

```
Step 1: Automated EDA (5-10 minutes)
    └── Run ydata-profiling or Sweetviz
    └── Get overview, identify potential issues
    └── Note interesting patterns to investigate

Step 2: Hypothesis Generation (10-15 minutes)
    └── Based on automated results, formulate questions
    └── Example: "Why do young customers have higher return rates?"

Step 3: Custom Investigation (30-60+ minutes)
    └── Create targeted visualizations
    └── Explore segment differences
    └── Investigate patterns in context

Step 4: Story Building (30-60+ minutes)
    └── Synthesize findings
    └── Create publication-ready visuals
    └── Build final narrative
```

---

#### Module 2.1 Summary

Congratulations! You've completed Module 2.1: Systematic EDA & Data Profiling. Let's recap what you've learned:

**Part 1:** Project setup, environment configuration, and data generation
**Part 2:** Univariate analysis - understanding individual variables
**Part 3:** Bivariate and multivariate analysis - exploring relationships
**Part 4:** Automated EDA tools vs. custom visual inspection

**Key Skills Acquired:**
- Setting up a professional data science project
- Generating synthetic data with realistic patterns
- Performing rigorous statistical profiling
- Creating publication-quality visualizations
- Detecting and interpreting correlations
- Using automated EDA tools effectively
- Knowing when to use automated vs. custom approaches

**What's Next:**

You're now ready for **Module 2.2: Static & Declarative Visualizations**, where we'll dive deep into the three most important static visualization libraries in Python:
- Matplotlib (total control, custom layouts)
- Seaborn (statistical summaries, multi-plot grids)
- Altair (declarative, grammar-based, interactive)

You'll learn to create publication-ready figures that tell compelling data stories.
