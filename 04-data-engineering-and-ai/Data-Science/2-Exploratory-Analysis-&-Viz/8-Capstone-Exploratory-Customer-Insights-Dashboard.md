# Phase 2 Capstone: Exploratory Customer Insights Dashboard

---

#### The Target

In this capstone project, you'll synthesize everything from Modules 2.1, 2.2, and 2.3 into a complete, end-to-end analytical artifact. By the end, you'll have:

1. A comprehensive static report with publication-quality figures (Matplotlib, Seaborn, Altair)
2. An interactive Plotly dashboard for ad-hoc exploration
3. A unified Dash application that combines both approaches
4. Deep statistical profiling with automated insights
5. A fully deployable analytical product

---

#### The Concept

**The Analytical Artifact: Static + Interactive = Complete Story**

Think of this capstone as building a comprehensive museum exhibit about your data. 

- **Static Report:** The curated gallery with carefully selected, publication-quality exhibits. Each visualization is polished and tells a specific story. This is what you'd include in a formal report or presentation.

- **Interactive Dashboard:** The hands-on discovery room where visitors can explore on their own terms. They can filter, zoom, and ask their own questions.

- **Unified Application:** The complete museum experience—visitors can view the curated exhibit and then dive deeper interactively.

**The Workflow:**

```
Raw Data
    ↓
Statistical Profiling (Module 2.1)
    ↓
┌─────────────────────────────────────┐
│                                     │
│  Static Report        Interactive   │
│  (Publication-ready)   (Exploration) │
│                                     │
│  Matplotlib + Seaborn    Plotly +   │
│  + Altair                Dash      │
│                                     │
└─────────────────────────────────────┘
    ↓
Unified Dashboard Application
    ↓
Deployable Analytical Product
```

---

#### The Implementation

##### Step 1: Create the Capstone Report Generator

**File:** `src/capstone_report.py`
```python
"""
Capstone: Exploratory Customer Insights Report Generator

Generates a comprehensive static report with:
- Executive summary
- Statistical profiling
- Publication-quality visualizations
- Key insights and recommendations
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import altair as alt
from pathlib import Path
import json
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# Import our toolkit modules
from univariate_analysis import UnivariateAnalyzer
from bivariate_analysis import RelationshipAnalyzer
from matplotlib_toolkit import FigureTemplates, MatplotlibFigureBuilder
from seaborn_toolkit import SeabornVisualizer
from altair_toolkit import AltairVisualizer

class CapstoneReportGenerator:
    """
    Generates a complete analytical report with static visualizations.
    
    Combines all modules to create a professional, publication-ready
    report with statistical profiling and visualizations.
    """
    
    def __init__(self, data_path: str = "data/customer_data.csv",
                 output_dir: str = "outputs/capstone"):
        """
        Initialize the report generator.
        
        Parameters:
        -----------
        data_path : str
            Path to the dataset
        output_dir : str
            Directory for report outputs
        """
        self.df = pd.read_csv(data_path)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Create subdirectories
        (self.output_dir / 'figures').mkdir(exist_ok=True)
        (self.output_dir / 'altair').mkdir(exist_ok=True)
        
        # Set random seed for reproducibility
        np.random.seed(42)
        
        print(f"📊 Loaded {self.df.shape[0]} rows, {self.df.shape[1]} columns")
        print(f"📁 Output directory: {self.output_dir}")
    
    def generate_executive_summary(self) -> str:
        """Generate executive summary with key metrics."""
        
        summary = []
        summary.append("=" * 70)
        summary.append("EXECUTIVE SUMMARY")
        summary.append("=" * 70)
        summary.append("")
        
        # Key metrics
        total_customers = len(self.df)
        avg_age = self.df['age'].mean()
        avg_order_value = self.df['avg_order_value'].mean()
        avg_rating = self.df['customer_rating'].mean()
        avg_return_rate = self.df['return_rate'].mean()
        top_category = self.df['favorite_category'].mode().iloc[0]
        
        summary.append(f"📊 Dataset Overview:")
        summary.append(f"  • Total Customers: {total_customers:,}")
        summary.append(f"  • Average Age: {avg_age:.1f} years")
        summary.append(f"  • Average Order Value: ${avg_order_value:.2f}")
        summary.append(f"  • Average Customer Rating: {avg_rating:.2f}/5.0")
        summary.append(f"  • Average Return Rate: {avg_return_rate:.1f}%")
        summary.append(f"  • Top Product Category: {top_category}")
        summary.append("")
        
        # Key insights
        summary.append("💡 Key Insights:")
        
        # Correlation insights
        corr_matrix = self.df[['age', 'order_frequency', 'avg_order_value', 
                              'customer_rating', 'return_rate']].corr()
        
        # Find strongest correlation
        max_corr = 0
        best_pair = None
        for i in range(len(corr_matrix.columns)):
            for j in range(i+1, len(corr_matrix.columns)):
                corr_val = abs(corr_matrix.iloc[i, j])
                if corr_val > max_corr and corr_val < 1:
                    max_corr = corr_val
                    best_pair = (corr_matrix.columns[i], corr_matrix.columns[j], corr_val)
        
        if best_pair:
            summary.append(f"  • Strongest relationship: {best_pair[0]} ↔ {best_pair[1]} (r={best_pair[2]:.3f})")
        
        # Segment insights
        # Highest spending segment
        high_spenders = self.df.nlargest(10, 'avg_order_value')
        summary.append(f"  • Top 10 customers spend an average of ${high_spenders['avg_order_value'].mean():.2f}")
        
        # Most engaged segment
        high_engagement = self.df.nlargest(10, 'time_on_site')
        summary.append(f"  • Top 10 engaged customers spend {high_engagement['time_on_site'].mean():.1f} min/session")
        
        summary.append("")
        summary.append("📈 Recommendations:")
        summary.append("  • Focus marketing on high-income, urban customers for maximum ROI")
        summary.append("  • Improve customer experience to reduce return rates")
        summary.append("  • Target middle-aged customers for higher order frequency")
        summary.append("  • Optimize email engagement to increase purchase frequency")
        
        return "\n".join(summary)
    
    def generate_statistical_profile(self) -> str:
        """Generate comprehensive statistical profile."""
        
        profile = []
        profile.append("=" * 70)
        profile.append("STATISTICAL PROFILE")
        profile.append("=" * 70)
        profile.append("")
        
        # Numerical columns
        num_cols = self.df.select_dtypes(include=[np.number]).columns
        num_cols = [c for c in num_cols if c != 'customer_id']
        
        profile.append("📊 Numerical Variables:")
        profile.append("-" * 60)
        profile.append("")
        
        for col in num_cols:
            data = self.df[col].dropna()
            if len(data) > 0:
                profile.append(f"{col}:")
                profile.append(f"  Count: {len(data):,}")
                profile.append(f"  Mean: {data.mean():.2f}")
                profile.append(f"  Median: {data.median():.2f}")
                profile.append(f"  Std Dev: {data.std():.2f}")
                profile.append(f"  Min: {data.min():.2f}")
                profile.append(f"  Max: {data.max():.2f}")
                profile.append(f"  Skewness: {data.skew():.2f}")
                profile.append(f"  Missing: {self.df[col].isnull().sum():,}")
                profile.append("")
        
        # Categorical columns
        cat_cols = self.df.select_dtypes(include=['object']).columns
        
        profile.append("📋 Categorical Variables:")
        profile.append("-" * 60)
        profile.append("")
        
        for col in cat_cols:
            if col not in ['customer_id']:
                data = self.df[col].dropna()
                value_counts = data.value_counts()
                profile.append(f"{col}:")
                profile.append(f"  Unique values: {data.nunique():,}")
                profile.append(f"  Missing: {self.df[col].isnull().sum():,}")
                profile.append(f"  Top categories:")
                for val, count in value_counts.head(3).items():
                    pct = (count / len(data)) * 100
                    profile.append(f"    {val}: {count:,} ({pct:.1f}%)")
                profile.append("")
        
        return "\n".join(profile)
    
    def generate_visualizations(self) -> dict:
        """
        Generate all static visualizations.
        
        Returns:
        --------
        dict
            Dictionary of generated figure paths
        """
        print("\n" + "=" * 60)
        print("GENERATING STATIC VISUALIZATIONS")
        print("=" * 60)
        
        results = {'matplotlib': [], 'seaborn': [], 'altair': []}
        
        # ---- Matplotlib Visualizations ----
        print("\n📊 Generating Matplotlib figures...")
        
        templates = FigureTemplates(output_dir=str(self.output_dir / 'figures'))
        
        # Distribution grid
        try:
            num_cols = self.df.select_dtypes(include=[np.number]).columns.tolist()
            num_cols = [c for c in num_cols if c not in ['customer_id', 'city_tier']]
            if len(num_cols) > 6:
                num_cols = num_cols[:6]
            templates.create_distribution_grid(self.df, num_cols)
            results['matplotlib'].append('template_distribution_grid.png')
        except Exception as e:
            print(f"  ⚠️ Error creating distribution grid: {e}")
        
        # Correlation heatmap
        try:
            templates.create_correlation_heatmap(self.df)
            results['matplotlib'].append('template_correlation_heatmap.png')
        except Exception as e:
            print(f"  ⚠️ Error creating correlation heatmap: {e}")
        
        # ---- Seaborn Visualizations ----
        print("\n📊 Generating Seaborn figures...")
        
        visualizer = SeabornVisualizer(self.df, output_dir=str(self.output_dir / 'figures'))
        
        # Histograms for key columns
        key_cols = ['age', 'order_frequency', 'avg_order_value', 'customer_rating']
        for col in key_cols:
            if col in self.df.columns:
                try:
                    visualizer.plot_histogram_with_kde(col, save=True)
                    results['seaborn'].append(f'seaborn_{col}_histogram.png')
                except Exception as e:
                    print(f"  ⚠️ Error creating histogram for {col}: {e}")
        
        # Box plots by category
        if 'income_bracket' in self.df.columns:
            try:
                visualizer.plot_violin_with_box('avg_order_value', 'income_bracket', save=True)
                results['seaborn'].append('seaborn_avg_order_value_by_income_bracket_violin.png')
            except Exception as e:
                print(f"  ⚠️ Error creating violin plot: {e}")
        
        # Correlation heatmap with Seaborn
        try:
            visualizer.plot_correlation_heatmap(save=True)
            results['seaborn'].append('seaborn_correlation_pearson_heatmap.png')
        except Exception as e:
            print(f"  ⚠️ Error creating Seaborn heatmap: {e}")
        
        # ---- Altair Visualizations ----
        print("\n📊 Generating Altair visualizations...")
        
        altair_visualizer = AltairVisualizer(self.df, output_dir=str(self.output_dir / 'altair'))
        
        # Scatter plots
        if len(self.df.select_dtypes(include=[np.number]).columns) >= 2:
            num_cols = self.df.select_dtypes(include=[np.number]).columns.tolist()
            num_cols = [c for c in num_cols if c not in ['customer_id']]
            if len(num_cols) >= 2:
                try:
                    chart = altair_visualizer.create_scatter_plot(
                        num_cols[0], num_cols[1],
                        color_col='income_bracket' if 'income_bracket' in self.df.columns else None,
                        save=False
                    )
                    altair_visualizer.save_chart(chart, 'altair_scatter', ['html', 'png'])
                    results['altair'].append('altair_scatter.html')
                    results['altair'].append('altair_scatter.png')
                except Exception as e:
                    print(f"  ⚠️ Error creating Altair scatter: {e}")
        
        # Bar chart
        if 'favorite_category' in self.df.columns:
            try:
                chart = altair_visualizer.create_bar_chart('favorite_category', save=False)
                altair_visualizer.save_chart(chart, 'altair_category_bar', ['html', 'png'])
                results['altair'].append('altair_category_bar.html')
                results['altair'].append('altair_category_bar.png')
            except Exception as e:
                print(f"  ⚠️ Error creating Altair bar chart: {e}")
        
        # Interactive dashboard
        if len(num_cols) >= 2 and 'income_bracket' in self.df.columns:
            try:
                chart = altair_visualizer.create_interactive_dashboard(
                    num_cols[0], num_cols[1],
                    color_col='income_bracket',
                    filter_col='favorite_category' if 'favorite_category' in self.df.columns else None,
                    save=False
                )
                altair_visualizer.save_chart(chart, 'altair_dashboard', ['html'])
                results['altair'].append('altair_dashboard.html')
            except Exception as e:
                print(f"  ⚠️ Error creating Altair dashboard: {e}")
        
        print(f"\n✅ Generated {len(results['matplotlib'])} Matplotlib, "
              f"{len(results['seaborn'])} Seaborn, and {len(results['altair'])} Altair visualizations")
        
        return results
    
    def generate_full_report(self) -> str:
        """
        Generate the complete report as text.
        
        Returns:
        --------
        str
            Complete report text
        """
        report = []
        report.append("=" * 70)
        report.append("EXPLORATORY CUSTOMER INSIGHTS REPORT")
        report.append("=" * 70)
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("=" * 70)
        report.append("")
        
        # Executive summary
        report.append(self.generate_executive_summary())
        report.append("")
        
        # Statistical profile
        report.append(self.generate_statistical_profile())
        report.append("")
        
        # Key findings
        report.append("=" * 70)
        report.append("KEY FINDINGS & RECOMMENDATIONS")
        report.append("=" * 70)
        report.append("")
        
        # Find top correlations
        num_cols = self.df.select_dtypes(include=[np.number]).columns
        num_cols = [c for c in num_cols if c != 'customer_id']
        if len(num_cols) >= 2:
            corr_matrix = self.df[num_cols].corr()
            
            report.append("🔗 Top 5 Correlations:")
            correlations = []
            for i in range(len(corr_matrix.columns)):
                for j in range(i+1, len(corr_matrix.columns)):
                    val = corr_matrix.iloc[i, j]
                    if not pd.isna(val):
                        correlations.append((corr_matrix.columns[i], corr_matrix.columns[j], val))
            
            correlations.sort(key=lambda x: abs(x[2]), reverse=True)
            
            for col1, col2, val in correlations[:5]:
                direction = "positive" if val > 0 else "negative"
                strength = "strong" if abs(val) > 0.5 else "moderate" if abs(val) > 0.3 else "weak"
                report.append(f"  • {col1} ↔ {col2}: {val:.3f} ({strength} {direction})")
        report.append("")
        
        # Segment analysis
        report.append("👥 Customer Segments:")
        
        # Age groups
        if 'age' in self.df.columns:
            age_groups = pd.cut(self.df['age'], bins=[0, 25, 35, 45, 55, 100],
                               labels=['Under 25', '25-35', '35-45', '45-55', '55+'])
            age_spending = self.df.groupby(age_groups)['avg_order_value'].mean()
            top_age = age_spending.idxmax()
            report.append(f"  • Highest spending age group: {top_age} (${age_spending.max():.2f})")
        
        # Income segments
        if 'income_bracket' in self.df.columns:
            income_spending = self.df.groupby('income_bracket')['avg_order_value'].mean()
            top_income = income_spending.idxmax()
            report.append(f"  • Highest spending income group: {top_income} (${income_spending.max():.2f})")
        
        # Category preferences
        if 'favorite_category' in self.df.columns:
            cat_counts = self.df['favorite_category'].value_counts()
            top_cat = cat_counts.index[0]
            report.append(f"  • Most popular category: {top_cat} ({cat_counts.iloc[0]:,} customers)")
        report.append("")
        
        report.append("=" * 70)
        report.append("END OF REPORT")
        report.append("=" * 70)
        
        return "\n".join(report)
    
    def run(self) -> dict:
        """
        Run the complete capstone report generation.
        
        Returns:
        --------
        dict
            Summary of generated outputs
        """
        print("=" * 70)
        print("CAPSTONE REPORT GENERATOR")
        print("=" * 70)
        
        # Generate report text
        print("\n📝 Generating report text...")
        report_text = self.generate_full_report()
        
        # Save report
        report_path = self.output_dir / 'customer_insights_report.txt'
        with open(report_path, 'w') as f:
            f.write(report_text)
        print(f"✅ Report saved: {report_path}")
        
        # Generate visualizations
        viz_results = self.generate_visualizations()
        
        # Generate summary
        summary = {
            'report_path': str(report_path),
            'matplotlib_figures': len(viz_results['matplotlib']),
            'seaborn_figures': len(viz_results['seaborn']),
            'altair_figures': len(viz_results['altair']),
            'output_dir': str(self.output_dir)
        }
        
        # Save summary
        summary_path = self.output_dir / 'summary.json'
        with open(summary_path, 'w') as f:
            json.dump(summary, f, indent=2)
        print(f"✅ Summary saved: {summary_path}")
        
        print("\n" + "=" * 70)
        print("CAPSTONE REPORT GENERATION COMPLETE")
        print("=" * 70)
        print(f"\n📁 Output directory: {self.output_dir}")
        print(f"📄 Report: {report_path}")
        print(f"📊 Figures: {sum(viz_results.values())}")
        print("\n💡 To view the interactive dashboard, run:")
        print("   python src/capstone_dashboard.py")
        
        return summary


if __name__ == "__main__":
    generator = CapstoneReportGenerator()
    generator.run()
```

---

##### Step 2: Create the Unified Dashboard

**File:** `src/capstone_dashboard.py`
```python
"""
Capstone: Unified Exploratory Dashboard

Combines static report viewing with interactive exploration
in a single Dash application.
"""

import dash
from dash import dcc, html, Input, Output, State, callback
import dash_bootstrap_components as dbc
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import numpy as np
from pathlib import Path
import json
import base64
import warnings
warnings.filterwarnings('ignore')

# Load data
df = pd.read_csv('data/customer_data.csv')
df['account_created'] = pd.to_datetime(df['account_created'])
df['last_purchase'] = pd.to_datetime(df['last_purchase'])
city_labels = {1: 'Major Metro', 2: 'Mid-size City', 3: 'Small City/Rural'}
df['city_tier_label'] = df['city_tier'].map(city_labels)
df['age_group'] = pd.cut(df['age'], bins=[0, 25, 35, 45, 55, 100],
                        labels=['Under 25', '25-35', '35-45', '45-55', '55+'])

# Load report content
report_path = Path('outputs/capstone/customer_insights_report.txt')
if report_path.exists():
    with open(report_path, 'r') as f:
        report_content = f.read()
else:
    report_content = "Report not found. Run capstone_report.py first."

# Initialize app
app = dash.Dash(
    __name__,
    external_stylesheets=[dbc.themes.FLATLY],
    title='Customer Insights Dashboard',
    suppress_callback_exceptions=True
)

# Color scheme
COLORS = {
    'primary': '#2C3E50',
    'secondary': '#3498DB',
    'success': '#27AE60',
    'warning': '#F39C12',
    'danger': '#E74C3C',
    'light': '#ECF0F1',
    'dark': '#2C3E50'
}

# ---------- LAYOUT ----------

app.layout = dbc.Container([
    # Header
    dbc.Row([
        dbc.Col([
            html.H1("📊 Exploratory Customer Insights Dashboard", 
                   className="text-center my-4",
                   style={'color': COLORS['primary']}),
            html.P("Static Report | Interactive Exploration | Data-Driven Insights",
                  className="text-center text-muted mb-4")
        ])
    ]),
    
    # Navigation tabs
    dbc.Row([
        dbc.Col([
            dbc.Tabs([
                dbc.Tab(label="📊 Overview", tab_id="tab-overview"),
                dbc.Tab(label="📈 Interactive Exploration", tab_id="tab-interactive"),
                dbc.Tab(label="📄 Static Report", tab_id="tab-report"),
                dbc.Tab(label="🔍 Customer Profiling", tab_id="tab-profile")
            ], id="tabs", active_tab="tab-overview", className="mb-4")
        ])
    ]),
    
    # Tab content
    dbc.Row([
        dbc.Col([
            html.Div(id="tab-content")
        ])
    ])
], fluid=True)


# ---------- TAB CONTENT GENERATORS ----------

def create_overview_tab():
    """Create the overview tab content."""
    return dbc.Row([
        # KPI Cards
        dbc.Row([
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Total Customers", className="text-muted"),
                        html.H2(f"{len(df):,}", className="text-primary"),
                        html.Small("Active customers")
                    ])
                ], className="mb-3")
            ], md=3),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Avg Order Value", className="text-muted"),
                        html.H2(f"${df['avg_order_value'].mean():.2f}", 
                                className="text-success"),
                        html.Small("Average per customer")
                    ])
                ], className="mb-3")
            ], md=3),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Avg Customer Rating", className="text-muted"),
                        html.H2(f"{df['customer_rating'].mean():.2f}/5.0", 
                                className="text-warning"),
                        html.Small("Out of 5.0")
                    ])
                ], className="mb-3")
            ], md=3),
            dbc.Col([
                dbc.Card([
                    dbc.CardBody([
                        html.H5("Return Rate", className="text-muted"),
                        html.H2(f"{df['return_rate'].mean():.1f}%", 
                                className="text-danger"),
                        html.Small("Average return percentage")
                    ])
                ], className="mb-3")
            ], md=3)
        ]),
        
        # Charts
        dbc.Row([
            dbc.Col([
                dbc.Card([
                    dbc.CardHeader("Demographics Overview", className="bg-primary text-white"),
                    dbc.CardBody([
                        dcc.Graph(
                            figure=create_demographics_figure(),
                            config={'displaylogo': False}
                        )
                    ])
                ], className="mb-4")
            ], md=6),
            dbc.Col([
                dbc.Card([
                    dbc.CardHeader("Purchase Behavior", className="bg-success text-white"),
                    dbc.CardBody([
                        dcc.Graph(
                            figure=create_purchase_figure(),
                            config={'displaylogo': False}
                        )
                    ])
                ], className="mb-4")
            ], md=6)
        ]),
        
        dbc.Row([
            dbc.Col([
                dbc.Card([
                    dbc.CardHeader("Engagement & Satisfaction", className="bg-info text-white"),
                    dbc.CardBody([
                        dcc.Graph(
                            figure=create_engagement_figure(),
                            config={'displaylogo': False}
                        )
                    ])
                ], className="mb-4")
            ], md=12)
        ])
    ])


def create_interactive_tab():
    """Create the interactive exploration tab."""
    return dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Interactive Filters", className="bg-secondary text-white"),
                dbc.CardBody([
                    dbc.Row([
                        dbc.Col([
                            html.Label("Income Bracket"),
                            dcc.Dropdown(
                                id='interactive-income',
                                options=[{'label': 'All', 'value': 'All'}] +
                                        [{'label': i, 'value': i} for i in 
                                         sorted(df['income_bracket'].unique())],
                                value='All'
                            )
                        ], md=3),
                        dbc.Col([
                            html.Label("Favorite Category"),
                            dcc.Dropdown(
                                id='interactive-category',
                                options=[{'label': 'All', 'value': 'All'}] +
                                        [{'label': c, 'value': c} for c in 
                                         sorted(df['favorite_category'].unique())],
                                value='All'
                            )
                        ], md=3),
                        dbc.Col([
                            html.Label("City Tier"),
                            dcc.Dropdown(
                                id='interactive-city',
                                options=[{'label': 'All', 'value': 'All'}] +
                                        [{'label': c, 'value': c} for c in 
                                         sorted(df['city_tier_label'].unique())],
                                value='All'
                            )
                        ], md=3),
                        dbc.Col([
                            html.Label("Age Range"),
                            dcc.RangeSlider(
                                id='interactive-age',
                                min=int(df['age'].min()),
                                max=int(df['age'].max()),
                                step=1,
                                value=[int(df['age'].min()), int(df['age'].max())],
                                marks={i: str(i) for i in range(20, 71, 10)}
                            )
                        ], md=3)
                    ])
                ])
            ], className="mb-4"),
            
            dbc.Card([
                dbc.CardHeader("Interactive Charts", className="bg-primary text-white"),
                dbc.CardBody([
                    dcc.Graph(id='interactive-scatter', config={'displaylogo': False})
                ])
            ], className="mb-4"),
            
            dbc.Row([
                dbc.Col([
                    dbc.Card([
                        dbc.CardBody([
                            dcc.Graph(id='interactive-hist', config={'displaylogo': False})
                        ])
                    ], className="mb-4")
                ], md=6),
                dbc.Col([
                    dbc.Card([
                        dbc.CardBody([
                            dcc.Graph(id='interactive-box', config={'displaylogo': False})
                        ])
                    ], className="mb-4")
                ], md=6)
            ])
        ])
    ])


def create_report_tab():
    """Create the report viewing tab."""
    return dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("📄 Full Report", className="bg-dark text-white"),
                dbc.CardBody([
                    html.Pre(
                        report_content,
                        style={
                            'whiteSpace': 'pre-wrap',
                            'wordWrap': 'break-word',
                            'maxHeight': '800px',
                            'overflowY': 'auto',
                            'backgroundColor': '#f8f9fa',
                            'padding': '20px',
                            'borderRadius': '5px'
                        }
                    )
                ])
            ], className="mb-4")
        ])
    ])


def create_profile_tab():
    """Create the customer profiling tab."""
    return dbc.Row([
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("🔍 Customer Profile Lookup", className="bg-info text-white"),
                dbc.CardBody([
                    dbc.Row([
                        dbc.Col([
                            html.Label("Select Customer ID"),
                            dcc.Dropdown(
                                id='profile-customer',
                                options=[{'label': cid, 'value': cid} for cid in 
                                         df['customer_id'].sample(min(50, len(df))).tolist()],
                                placeholder="Select a customer..."
                            )
                        ], md=6),
                        dbc.Col([
                            html.Label("View Options"),
                            dcc.Checklist(
                                id='profile-options',
                                options=[
                                    {'label': ' Show Demographics', 'value': 'demographics'},
                                    {'label': ' Show Purchase History', 'value': 'purchases'},
                                    {'label': ' Show Engagement', 'value': 'engagement'}
                                ],
                                value=['demographics', 'purchases', 'engagement'],
                                inline=True,
                                className='mt-2'
                            )
                        ], md=6)
                    ])
                ])
            ], className="mb-4"),
            
            dbc.Card([
                dbc.CardHeader("Customer Profile", className="bg-secondary text-white"),
                dbc.CardBody([
                    html.Div(id='profile-content')
                ])
            ], className="mb-4")
        ])
    ])


# ---------- FIGURE CREATION FUNCTIONS ----------

def create_demographics_figure():
    """Create demographics overview figure."""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Age Distribution', 'Gender Split',
                       'Income Distribution', 'City Tier Distribution'),
        specs=[[{'type': 'histogram'}, {'type': 'pie'}],
               [{'type': 'histogram'}, {'type': 'pie'}]]
    )
    
    # Age
    fig.add_trace(
        go.Histogram(x=df['age'].dropna(), nbinsx=20, name='Age',
                    marker_color='steelblue'),
        row=1, col=1
    )
    
    # Gender
    gender_counts = df['gender'].value_counts()
    fig.add_trace(
        go.Pie(labels=gender_counts.index, values=gender_counts.values,
              hole=0.3, name='Gender',
              marker_colors=['#3498DB', '#E74C3C', '#2ECC71']),
        row=1, col=2
    )
    
    # Income
    income_counts = df['income_bracket'].value_counts()
    fig.add_trace(
        go.Bar(x=income_counts.index, y=income_counts.values, name='Income',
              marker_color='coral'),
        row=2, col=1
    )
    
    # City
    city_counts = df['city_tier_label'].value_counts()
    fig.add_trace(
        go.Pie(labels=city_counts.index, values=city_counts.values,
              hole=0.3, name='City',
              marker_colors=['#2C3E50', '#3498DB', '#95A5A6']),
        row=2, col=2
    )
    
    fig.update_layout(height=500, showlegend=False, template='plotly_white')
    return fig


def create_purchase_figure():
    """Create purchase behavior figure."""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Order Frequency', 'Avg Order Value',
                       'Return Rate', 'Customer Rating'),
        specs=[[{'type': 'histogram'}, {'type': 'histogram'}],
               [{'type': 'histogram'}, {'type': 'histogram'}]]
    )
    
    fig.add_trace(
        go.Histogram(x=df['order_frequency'].dropna(), nbinsx=30,
                    name='Order Freq', marker_color='steelblue'),
        row=1, col=1
    )
    
    fig.add_trace(
        go.Histogram(x=df['avg_order_value'].dropna(), nbinsx=30,
                    name='Order Value', marker_color='coral'),
        row=1, col=2
    )
    
    fig.add_trace(
        go.Histogram(x=df['return_rate'].dropna(), nbinsx=20,
                    name='Return Rate', marker_color='forestgreen'),
        row=2, col=1
    )
    
    fig.add_trace(
        go.Histogram(x=df['customer_rating'].dropna(), nbinsx=20,
                    name='Rating', marker_color='purple'),
        row=2, col=2
    )
    
    fig.update_layout(height=500, showlegend=False, template='plotly_white')
    return fig


def create_engagement_figure():
    """Create engagement figure."""
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('Time on Site', 'Pages Viewed',
                       'Email Open Rate', 'Engagement Level'),
        specs=[[{'type': 'histogram'}, {'type': 'histogram'}],
               [{'type': 'histogram'}, {'type': 'pie'}]]
    )
    
    fig.add_trace(
        go.Histogram(x=df['time_on_site'].dropna(), nbinsx=30,
                    name='Time on Site', marker_color='steelblue'),
        row=1, col=1
    )
    
    fig.add_trace(
        go.Histogram(x=df['pages_viewed'].dropna(), nbinsx=30,
                    name='Pages Viewed', marker_color='coral'),
        row=1, col=2
    )
    
    fig.add_trace(
        go.Histogram(x=df['email_open_rate'].dropna(), nbinsx=20,
                    name='Email Open', marker_color='forestgreen'),
        row=2, col=1
    )
    
    # Engagement levels
    engagement_levels = pd.cut(df['time_on_site'], 
                              bins=[0, 5, 15, 100],
                              labels=['Low', 'Medium', 'High'])
    level_counts = engagement_levels.value_counts()
    
    fig.add_trace(
        go.Pie(labels=level_counts.index, values=level_counts.values,
              hole=0.3, name='Engagement',
              marker_colors=['#E74C3C', '#F39C12', '#27AE60']),
        row=2, col=2
    )
    
    fig.update_layout(height=500, showlegend=False, template='plotly_white')
    return fig


# ---------- CALLBACKS ----------

@app.callback(
    Output('tab-content', 'children'),
    Input('tabs', 'active_tab')
)
def render_tab_content(active_tab):
    """Render the selected tab content."""
    if active_tab == 'tab-overview':
        return create_overview_tab()
    elif active_tab == 'tab-interactive':
        return create_interactive_tab()
    elif active_tab == 'tab-report':
        return create_report_tab()
    elif active_tab == 'tab-profile':
        return create_profile_tab()
    return html.Div("Tab not found")


# Interactive tab callbacks
@callback(
    Output('interactive-scatter', 'figure'),
    Output('interactive-hist', 'figure'),
    Output('interactive-box', 'figure'),
    Input('interactive-income', 'value'),
    Input('interactive-category', 'value'),
    Input('interactive-city', 'value'),
    Input('interactive-age', 'value')
)
def update_interactive_charts(income, category, city, age_range):
    """Update interactive charts based on filters."""
    
    # Filter data
    filtered_df = df.copy()
    
    if income != 'All':
        filtered_df = filtered_df[filtered_df['income_bracket'] == income]
    if category != 'All':
        filtered_df = filtered_df[filtered_df['favorite_category'] == category]
    if city != 'All':
        filtered_df = filtered_df[filtered_df['city_tier_label'] == city]
    filtered_df = filtered_df[
        (filtered_df['age'] >= age_range[0]) & 
        (filtered_df['age'] <= age_range[1])
    ]
    
    # Scatter plot
    scatter = go.Figure()
    scatter.add_trace(go.Scatter(
        x=filtered_df['order_frequency'],
        y=filtered_df['avg_order_value'],
        mode='markers',
        marker=dict(
            size=8,
            color=filtered_df['customer_rating'],
            colorscale='Viridis',
            showscale=True,
            colorbar=dict(title='Rating')
        ),
        text=filtered_df['customer_id'],
        hovertemplate='<b>%{text}</b><br>Freq: %{x:.2f}<br>Value: $%{y:.2f}<extra></extra>'
    ))
    scatter.update_layout(
        title=f'Order Frequency vs Value ({len(filtered_df)} customers)',
        xaxis_title='Order Frequency',
        yaxis_title='Avg Order Value ($)',
        height=500,
        template='plotly_white'
    )
    
    # Histogram
    hist = go.Figure()
    hist.add_trace(go.Histogram(
        x=filtered_df['age'].dropna(),
        nbinsx=20,
        marker_color='steelblue'
    ))
    hist.update_layout(
        title='Age Distribution',
        xaxis_title='Age',
        yaxis_title='Count',
        height=300,
        template='plotly_white'
    )
    
    # Box plot
    box = go.Figure()
    if not filtered_df.empty:
        box.add_trace(go.Box(
            x=filtered_df['income_bracket'],
            y=filtered_df['avg_order_value'],
            marker_color='coral'
        ))
    box.update_layout(
        title='Order Value by Income',
        xaxis_title='Income Bracket',
        yaxis_title='Avg Order Value ($)',
        height=300,
        template='plotly_white'
    )
    
    return scatter, hist, box


# Profile tab callbacks
@callback(
    Output('profile-content', 'children'),
    Input('profile-customer', 'value'),
    Input('profile-options', 'value')
)
def update_profile(customer_id, options):
    """Update customer profile display."""
    if customer_id is None:
        return html.Div("Select a customer to view profile", className="text-muted")
    
    customer = df[df['customer_id'] == customer_id]
    if customer.empty:
        return html.Div("Customer not found", className="text-danger")
    
    customer = customer.iloc[0]
    
    profile_html = []
    
    # Basic info
    profile_html.append(html.H4(f"Customer: {customer_id}", className="text-primary"))
    profile_html.append(html.Hr())
    
    # Demographics
    if 'demographics' in options:
        profile_html.append(html.H5("Demographics", className="text-info"))
        profile_html.append(html.Div([
            html.P(f"Age: {customer['age']:.0f}"),
            html.P(f"Gender: {customer['gender']}"),
            html.P(f"Income: {customer['income_bracket']}"),
            html.P(f"City: {customer['city_tier_label']}")
        ]))
    
    # Purchases
    if 'purchases' in options:
        profile_html.append(html.H5("Purchase Behavior", className="text-success"))
        profile_html.append(html.Div([
            html.P(f"Order Frequency: {customer['order_frequency']:.2f}/month"),
            html.P(f"Avg Order Value: ${customer['avg_order_value']:.2f}"),
            html.P(f"Favorite Category: {customer['favorite_category']}"),
            html.P(f"Return Rate: {customer['return_rate']:.1f}%")
        ]))
    
    # Engagement
    if 'engagement' in options:
        profile_html.append(html.H5("Engagement", className="text-warning"))
        profile_html.append(html.Div([
            html.P(f"Time on Site: {customer['time_on_site']:.1f} min"),
            html.P(f"Pages Viewed: {customer['pages_viewed']:.0f}"),
            html.P(f"Email Open Rate: {customer['email_open_rate']:.1f}%")
        ]))
    
    # Customer rating
    profile_html.append(html.H5("Satisfaction", className="text-danger"))
    profile_html.append(html.Div([
        html.P(f"Customer Rating: {customer['customer_rating']:.1f}/5.0"),
        html.P(f"Return Rate: {customer['return_rate']:.1f}%")
    ]))
    
    # Segment classification
    profile_html.append(html.Hr())
    profile_html.append(html.H5("Segment Classification", className="text-primary"))
    
    # Determine segment
    if customer['avg_order_value'] > df['avg_order_value'].median():
        value_segment = "High Value"
    else:
        value_segment = "Low Value"
    
    if customer['order_frequency'] > df['order_frequency'].median():
        freq_segment = "Frequent"
    else:
        freq_segment = "Infrequent"
    
    if customer['customer_rating'] > df['customer_rating'].median():
        rating_segment = "Satisfied"
    else:
        rating_segment = "Dissatisfied"
    
    profile_html.append(html.Div([
        html.P(f"Value: {value_segment}", className="text-success" if value_segment == "High Value" else "text-warning"),
        html.P(f"Frequency: {freq_segment}", className="text-success" if freq_segment == "Frequent" else "text-warning"),
        html.P(f"Satisfaction: {rating_segment}", className="text-success" if rating_segment == "Satisfied" else "text-danger")
    ]))
    
    return html.Div(profile_html)


# ---------- MAIN ----------

if __name__ == '__main__':
    print("=" * 70)
    print("🚀 STARTING EXPLORATORY CUSTOMER INSIGHTS DASHBOARD")
    print("=" * 70)
    print("\n📊 Dashboard available at: http://127.0.0.1:8052")
    print("📁 Tabs:")
    print("   • Overview - Quick summary with KPIs and key charts")
    print("   • Interactive - Filter and explore data in real-time")
    print("   • Static Report - View the full report")
    print("   • Customer Profiling - Look up individual customers")
    print("\n💡 Press Ctrl+C to stop the server")
    print("=" * 70)
    
    app.run_server(debug=True, host='127.0.0.1', port=8052)
```

---

##### Step 3: Create the Main Startup Script

**File:** `run_capstone.py`
```python
"""
Capstone Project: Exploratory Customer Insights Dashboard

This script runs the complete capstone project:
1. Generates the static report with all visualizations
2. Launches the unified dashboard
"""

import sys
import subprocess
from pathlib import Path

def run_capstone():
    """Run the complete capstone project."""
    
    print("=" * 70)
    print("🏆 EXPLORATORY CUSTOMER INSIGHTS DASHBOARD")
    print("=" * 70)
    
    # Step 1: Generate report
    print("\n[Step 1] Generating static report...")
    print("-" * 50)
    
    try:
        sys.path.insert(0, str(Path(__file__).parent / 'src'))
        from capstone_report import CapstoneReportGenerator
        
        generator = CapstoneReportGenerator()
        summary = generator.run()
        print("✅ Report generation complete!")
    except Exception as e:
        print(f"❌ Error generating report: {e}")
        return
    
    # Step 2: Launch dashboard
    print("\n[Step 2] Launching dashboard...")
    print("-" * 50)
    
    dashboard_path = Path(__file__).parent / 'src' / 'capstone_dashboard.py'
    
    print("\n" + "=" * 70)
    print("🚀 DASHBOARD READY!")
    print("=" * 70)
    print("\n📊 Access the dashboard at: http://127.0.0.1:8052")
    print("\n📁 Report directory: outputs/capstone/")
    print("   • customer_insights_report.txt - Full report")
    print("   • figures/ - Static visualizations")
    print("   • altair/ - Interactive Altair charts")
    print("\n💡 Dashboard tabs:")
    print("   • Overview - Quick summary with KPIs and charts")
    print("   • Interactive - Real-time data exploration")
    print("   • Static Report - View the full report")
    print("   • Customer Profiling - Look up individual customers")
    print("\n" + "=" * 70)
    
    # Launch dashboard
    subprocess.run([sys.executable, str(dashboard_path)])

if __name__ == "__main__":
    run_capstone()
```

---

#### The Verification

**Verification 1: Generate the Capstone Report**

```bash
python src/capstone_report.py
```

Check the output:
```bash
# List generated files
ls -la outputs/capstone/
ls -la outputs/capstone/figures/
ls -la outputs/capstone/altair/

# View the report
cat outputs/capstone/customer_insights_report.txt
```

**Verification 2: Run the Dashboard**

```bash
# Using the main script
python run_capstone.py

# Or directly
python src/capstone_dashboard.py
```

Open your browser to http://127.0.0.1:8052

**Verification 3: Test Dashboard Features**

1. **Overview Tab:**
   - Check KPI cards update
   - Verify all charts render

2. **Interactive Tab:**
   - Apply filters and verify charts update
   - Hover for tooltips
   - Zoom and pan

3. **Static Report Tab:**
   - Scroll through full report
   - Verify content is readable

4. **Customer Profiling Tab:**
   - Select a customer
   - Toggle view options
   - Verify profile displays

**Verification 4: Validate All Outputs**

**File:** `src/validate_capstone.py`
```python
"""
Validate that all capstone outputs were generated correctly.
"""

import json
from pathlib import Path

def validate_capstone():
    """Validate capstone outputs."""
    
    print("=" * 70)
    print("VALIDATING CAPSTONE OUTPUTS")
    print("=" * 70)
    
    # Check report
    report_path = Path('outputs/capstone/customer_insights_report.txt')
    if report_path.exists():
        size = report_path.stat().st_size / 1024
        print(f"✅ Report: {size:.1f} KB")
    else:
        print("❌ Report missing")
        return
    
    # Check figures
    fig_dir = Path('outputs/capstone/figures')
    if fig_dir.exists():
        figures = list(fig_dir.glob('*.png'))
        print(f"✅ Figures: {len(figures)} PNG files")
        for f in figures[:5]:
            size = f.stat().st_size / 1024
            print(f"   • {f.name} ({size:.1f} KB)")
    else:
        print("❌ Figures directory missing")
    
    # Check Altair
    altair_dir = Path('outputs/capstone/altair')
    if altair_dir.exists():
        altair_files = list(altair_dir.glob('*.html'))
        print(f"✅ Altair charts: {len(altair_files)} HTML files")
    else:
        print("❌ Altair directory missing")
    
    # Check summary
    summary_path = Path('outputs/capstone/summary.json')
    if summary_path.exists():
        with open(summary_path, 'r') as f:
            summary = json.load(f)
        print(f"✅ Summary: {summary}")
    else:
        print("❌ Summary missing")
    
    print("\n" + "=" * 70)
    print("VALIDATION COMPLETE")
    print("=" * 70)
    
    print("\n🎉 CAPSTONE PROJECT IS READY!")
    print("📊 Launch the dashboard: python run_capstone.py")

if __name__ == "__main__":
    validate_capstone()
```

Run it:
```bash
python src/validate_capstone.py
```

---

#### What You've Built

Congratulations! You've completed the Phase 2 Capstone. You now have:

**1. A Complete Static Report:**
- Executive summary with key metrics
- Comprehensive statistical profiling
- Publication-quality visualizations
- Actionable recommendations

**2. An Interactive Dashboard:**
- Real-time filtering and exploration
- Multiple chart types synchronized
- Customer profiling and lookup
- Professional, responsive design

**3. A Unified Analytical Artifact:**
- Static report for formal presentation
- Interactive dashboard for ad-hoc exploration
- Complete end-to-end analysis pipeline
- Production-ready code with proper structure

**4. Reproducible Analysis:**
- All code is self-contained
- Generates synthetic data
- Produces consistent results
- Well-documented and organized

---

#### Final Summary: Phase 2 Complete

You've completed all of Phase 2: Exploratory Data Analysis & Visualization. Let's recap everything you've learned:

**Module 2.1: Systematic EDA & Data Profiling**
- ✅ Project setup and environment configuration
- ✅ Univariate analysis (distributions, statistics, outliers)
- ✅ Bivariate and multivariate analysis (correlations, associations)
- ✅ Automated EDA tools vs. custom visual inspection
- ✅ Statistical profiling and signal detection

**Module 2.2: Static & Declarative Visualizations**
- ✅ Matplotlib OO API and GridSpec layouts
- ✅ Seaborn statistical plots and multi-plot grids
- ✅ Altair declarative visualization with Vega-Lite
- ✅ Publication-quality figure design
- ✅ Grammar of Graphics principles

**Module 2.3: Interactive Data Exploration**
- ✅ Plotly Express and Graph Objects
- ✅ Interactive charts with hover, zoom, selection
- ✅ 3D visualizations and animation
- ✅ Dynamic controls (sliders, dropdowns)
- ✅ Dash web applications with cross-filtering

**Phase 2 Capstone: Exploratory Customer Insights Dashboard**
- ✅ Synthesized all modules into a unified product
- ✅ Created comprehensive static report
- ✅ Built interactive exploration dashboard
- ✅ Implemented customer profiling
- ✅ Delivered production-ready analytical artifact

---

#### What's Next

You're now ready for **Phase 3: Feature Engineering & Modeling** (future series), where you'll:

1. Transform raw data into predictive features
2. Build machine learning models for customer behavior
3. Deploy models in production
4. Create predictive dashboards

**Skills You've Acquired:**
- Professional data science project structure
- Systematic exploratory analysis
- Publication-quality visualization
- Interactive dashboard development
- End-to-end analytical workflow

**You're Now Capable Of:**
- Analyzing any dataset systematically
- Creating professional reports and dashboards
- Communicating insights effectively
- Building production-ready analytical products

---

# Series Complete 🎉

You've successfully completed the entire **Phase 2: Exploratory Data Analysis & Visualization** series!

**What You've Built:**
- Complete project structure with all code
- Statistical profiling pipeline
- Publication-quality visualizations
- Interactive dashboards
- Unified analytical artifact

**How to Use Your New Skills:**
1. Apply the framework to any dataset
2. Customize visualizations for your domain
3. Build dashboards for stakeholder review
4. Continue to Phase 3: Feature Engineering & Modeling

**Project Location:**
```
exploratory_data_analysis_series/
├── data/
│   └── customer_data.csv
├── src/
│   ├── generate_data.py
│   ├── univariate_analysis.py
│   ├── bivariate_analysis.py
│   ├── automated_eda.py
│   ├── custom_visual_inspection.py
│   ├── matplotlib_toolkit.py
│   ├── advanced_matplotlib_layouts.py
│   ├── seaborn_toolkit.py
│   ├── advanced_seaborn_examples.py
│   ├── altair_toolkit.py
│   ├── advanced_altair_examples.py
│   ├── plotly_toolkit.py
│   ├── advanced_plotly_examples.py
│   ├── dash_dashboard.py
│   ├── dash_advanced.py
│   ├── capstone_report.py
│   ├── capstone_dashboard.py
│   └── __init__.py
├── outputs/
│   ├── figures/
│   ├── reports/
│   ├── eda_reports/
│   └── capstone/
├── run_dashboard.py
├── run_capstone.py
└── requirements.txt
```

**Thank you for completing this series!** 🚀
