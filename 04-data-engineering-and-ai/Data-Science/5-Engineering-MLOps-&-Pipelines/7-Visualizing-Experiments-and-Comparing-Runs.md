# Part 7: Visualizing Experiments and Comparing Runs

## The Target: Advanced Experiment Visualization and Comparison

In this part, we'll build powerful visualization and comparison tools for MLflow experiments, enabling you to make data-driven decisions about which models to promote. By the end, you'll have a comprehensive dashboard for analyzing and comparing all your experiments.

## The Concept: Making Sense of Your Experiments

Imagine you're a race car team manager:
- Each **experiment** is a race weekend
- Each **run** is a practice session with different car setups (parameters)
- **Metrics** are your lap times and performance data
- **Visualizations** are your telemetry displays showing which setups work best

The goal is to quickly identify the winning combination and understand why it worked.

## The Implementation: Advanced Visualization Tools

### Step 1: Create a Comprehensive Visualization Module

```bash
cat > src/visualization/mlflow_viz.py << 'EOF'
"""
Advanced MLflow experiment visualization module.
Creates interactive and static visualizations for experiment analysis.
"""

import mlflow
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import cm
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import logging
import warnings
warnings.filterwarnings('ignore')

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class MLflowVisualizer:
    """Advanced MLflow experiment visualization."""
    
    def __init__(self, tracking_uri: str = "./mlruns"):
        """
        Initialize the visualizer.
        
        Args:
            tracking_uri: MLflow tracking URI
        """
        mlflow.set_tracking_uri(tracking_uri)
        self.client = mlflow.tracking.MlflowClient()
        self.tracking_uri = tracking_uri
    
    def get_experiment_runs(self, experiment_name: str, max_results: int = 100) -> pd.DataFrame:
        """
        Get all runs for an experiment.
        
        Args:
            experiment_name: Name of the experiment
            max_results: Maximum number of runs to fetch
            
        Returns:
            DataFrame with run data
        """
        experiment = mlflow.get_experiment_by_name(experiment_name)
        if experiment is None:
            logger.error(f"Experiment not found: {experiment_name}")
            return pd.DataFrame()
        
        runs = mlflow.search_runs(
            experiment_ids=[experiment.experiment_id],
            order_by=["start_time DESC"],
            max_results=max_results
        )
        
        logger.info(f"Retrieved {len(runs)} runs from experiment {experiment_name}")
        return runs
    
    def create_parallel_coordinates(self, df: pd.DataFrame, metric_col: str = None, 
                                   output_file: str = None) -> go.Figure:
        """
        Create a parallel coordinates plot for multi-dimensional visualization.
        
        Args:
            df: DataFrame with runs data
            metric_col: Primary metric column for coloring
            output_file: Path to save the plot
            
        Returns:
            Plotly figure
        """
        # Extract metric and parameter columns
        metric_cols = [col for col in df.columns if col.startswith('metrics.')]
        param_cols = [col for col in df.columns if col.startswith('params.')]
        
        # Select numeric parameters
        numeric_params = []
        for col in param_cols:
            try:
                pd.to_numeric(df[col])
                numeric_params.append(col)
            except:
                pass
        
        # Choose columns to display
        display_cols = numeric_params[:8] + metric_cols[:3]
        
        if not display_cols:
            logger.warning("No numeric columns available for parallel coordinates")
            return None
        
        # Prepare data
        plot_data = df[display_cols].copy()
        plot_data = plot_data.dropna()
        
        # Clean column names
        clean_cols = [col.replace('params.', '').replace('metrics.', '') for col in display_cols]
        plot_data.columns = clean_cols
        
        # Create parallel coordinates
        fig = go.Figure(data=
            go.Parcoords(
                line=dict(
                    color=plot_data[metric_col] if metric_col in plot_data.columns else plot_data.iloc[:, -1],
                    colorscale='Viridis',
                    showscale=True
                ),
                dimensions=[
                    dict(
                        label=col,
                        values=plot_data[col],
                        range=[plot_data[col].min(), plot_data[col].max()]
                    ) for col in plot_data.columns
                ]
            )
        )
        
        fig.update_layout(
            title=f'Parallel Coordinates Plot - {len(plot_data)} Runs',
            height=600
        )
        
        if output_file:
            fig.write_html(output_file)
            logger.info(f"Saved parallel coordinates to {output_file}")
        
        return fig
    
    def create_radar_chart(self, df: pd.DataFrame, run_ids: List[str], 
                          output_file: str = None) -> go.Figure:
        """
        Create a radar chart comparing multiple runs.
        
        Args:
            df: DataFrame with runs data
            run_ids: List of run IDs to compare
            output_file: Path to save the plot
            
        Returns:
            Plotly figure
        """
        # Get metric columns
        metric_cols = [col for col in df.columns if col.startswith('metrics.')]
        
        # Filter to selected runs
        selected_runs = df[df['run_id'].isin(run_ids)]
        
        if selected_runs.empty:
            logger.warning("No selected runs found")
            return None
        
        # Choose metrics to display
        display_metrics = []
        for col in metric_cols:
            if not selected_runs[col].isna().all():
                display_metrics.append(col)
        
        display_metrics = display_metrics[:8]  # Limit to 8 metrics
        
        if not display_metrics:
            logger.warning("No metrics available for radar chart")
            return None
        
        # Create figure
        fig = go.Figure()
        
        for _, run in selected_runs.iterrows():
            values = []
            for metric in display_metrics:
                val = run[metric]
                if pd.isna(val):
                    val = 0
                values.append(val)
            
            # Normalize values
            max_val = max(values) if max(values) > 0 else 1
            normalized_values = [v / max_val for v in values]
            
            fig.add_trace(go.Scatterpolar(
                r=normalized_values,
                theta=[m.replace('metrics.', '') for m in display_metrics],
                fill='toself',
                name=run['run_name'] if 'run_name' in run else run['run_id'][:8]
            ))
        
        fig.update_layout(
            polar=dict(
                radialaxis=dict(
                    visible=True,
                    range=[0, 1]
                )),
            title='Radar Chart - Run Comparison',
            height=600,
            showlegend=True
        )
        
        if output_file:
            fig.write_html(output_file)
            logger.info(f"Saved radar chart to {output_file}")
        
        return fig
    
    def create_scatter_matrix(self, df: pd.DataFrame, output_file: str = None) -> go.Figure:
        """
        Create a scatter matrix for multi-dimensional analysis.
        
        Args:
            df: DataFrame with runs data
            output_file: Path to save the plot
            
        Returns:
            Plotly figure
        """
        # Get numeric columns
        numeric_cols = []
        for col in df.columns:
            try:
                pd.to_numeric(df[col])
                if not df[col].isna().all():
                    numeric_cols.append(col)
            except:
                pass
        
        # Select columns for display
        display_cols = numeric_cols[:6]
        
        if len(display_cols) < 2:
            logger.warning("Not enough numeric columns for scatter matrix")
            return None
        
        # Clean column names
        clean_cols = [col.replace('params.', '').replace('metrics.', '').replace('tags.', '') 
                     for col in display_cols]
        
        # Create figure
        fig = px.scatter_matrix(
            df[display_cols],
            dimensions=display_cols,
            title='Scatter Matrix of Parameters and Metrics',
            labels={col: clean_cols[i] for i, col in enumerate(display_cols)},
            height=800
        )
        
        if output_file:
            fig.write_html(output_file)
            logger.info(f"Saved scatter matrix to {output_file}")
        
        return fig
    
    def create_metric_trends(self, df: pd.DataFrame, metric_col: str, 
                            output_file: str = None) -> go.Figure:
        """
        Create a metric trend plot over time.
        
        Args:
            df: DataFrame with runs data
            metric_col: Metric to plot
            output_file: Path to save the plot
            
        Returns:
            Plotly figure
        """
        if metric_col not in df.columns:
            logger.warning(f"Metric column not found: {metric_col}")
            return None
        
        # Sort by start time
        df_sorted = df.sort_values('start_time') if 'start_time' in df.columns else df
        
        fig = go.Figure()
        
        fig.add_trace(go.Scatter(
            x=df_sorted['start_time'] if 'start_time' in df_sorted.columns else list(range(len(df_sorted))),
            y=df_sorted[metric_col],
            mode='lines+markers',
            name=metric_col.replace('metrics.', ''),
            text=df_sorted['run_name'] if 'run_name' in df_sorted.columns else None,
            hoverinfo='text+x+y'
        ))
        
        fig.update_layout(
            title=f'Metric Trend: {metric_col.replace("metrics.", "")}',
            xaxis_title='Time' if 'start_time' in df_sorted.columns else 'Run Index',
            yaxis_title=metric_col.replace('metrics.', ''),
            height=500
        )
        
        if output_file:
            fig.write_html(output_file)
            logger.info(f"Saved metric trend to {output_file}")
        
        return fig
    
    def create_parameter_effect_plot(self, df: pd.DataFrame, param_col: str, 
                                   metric_col: str, output_file: str = None) -> go.Figure:
        """
        Create a plot showing the effect of a parameter on a metric.
        
        Args:
            df: DataFrame with runs data
            param_col: Parameter column
            metric_col: Metric column
            output_file: Path to save the plot
            
        Returns:
            Plotly figure
        """
        if param_col not in df.columns or metric_col not in df.columns:
            logger.warning(f"Required columns not found")
            return None
        
        fig = go.Figure()
        
        fig.add_trace(go.Scatter(
            x=df[param_col],
            y=df[metric_col],
            mode='markers',
            text=df['run_name'] if 'run_name' in df.columns else None,
            hoverinfo='text+x+y',
            marker=dict(
                size=10,
                color=df[metric_col],
                colorscale='Viridis',
                showscale=True
            )
        ))
        
        fig.update_layout(
            title=f'Parameter Effect: {param_col.replace("params.", "")} vs {metric_col.replace("metrics.", "")}',
            xaxis_title=param_col.replace('params.', ''),
            yaxis_title=metric_col.replace('metrics.', ''),
            height=500
        )
        
        if output_file:
            fig.write_html(output_file)
            logger.info(f"Saved parameter effect plot to {output_file}")
        
        return fig
    
    def create_comprehensive_report(self, experiment_name: str, output_dir: str = "reports"):
        """
        Generate a comprehensive visualization report for an experiment.
        
        Args:
            experiment_name: Name of the experiment
            output_dir: Directory to save the report
        """
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"Generating comprehensive report for {experiment_name}")
        
        # Get runs
        df = self.get_experiment_runs(experiment_name)
        if df.empty:
            logger.error(f"No runs found for experiment {experiment_name}")
            return
        
        # Create HTML report
        html_file = output_dir / f"{experiment_name}_report.html"
        
        with open(html_file, 'w') as f:
            f.write(f"""<!DOCTYPE html>
<html>
<head>
    <title>MLflow Experiment Report - {experiment_name}</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }}
        .container {{ max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; }}
        .header {{ background-color: #2c3e50; color: white; padding: 20px; border-radius: 5px; }}
        .section {{ margin: 30px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }}
        .metric {{ display: inline-block; margin: 10px; padding: 15px; background-color: #ecf0f1; border-radius: 5px; }}
        .best {{ background-color: #27ae60; color: white; }}
        h1, h2, h3 {{ color: #2c3e50; }}
        table {{ width: 100%; border-collapse: collapse; }}
        th, td {{ padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }}
        th {{ background-color: #34495e; color: white; }}
        tr:hover {{ background-color: #f5f5f5; }}
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>MLflow Experiment Report</h1>
        <h2>{experiment_name}</h2>
        <p>Generated: {pd.Timestamp.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        <p>Total Runs: {len(df)}</p>
    </div>
""")
            
            # Summary statistics
            f.write("""
    <div class="section">
        <h2>Summary Statistics</h2>
""")
            
            # Find best performing run
            metric_cols = [col for col in df.columns if col.startswith('metrics.')]
            f1_cols = [col for col in metric_cols if 'f1' in col.lower()]
            
            if f1_cols:
                best_f1 = -1
                best_run = None
                for col in f1_cols:
                    for idx, run in df.iterrows():
                        if not pd.isna(run[col]) and run[col] > best_f1:
                            best_f1 = run[col]
                            best_run = run
                            best_metric = col
                
                if best_run is not None:
                    f.write(f"""
        <div class="metric best">
            <h3>Best Performing Run</h3>
            <p><strong>Run Name:</strong> {best_run.get('run_name', 'N/A')}</p>
            <p><strong>Run ID:</strong> {best_run.get('run_id', 'N/A')}</p>
            <p><strong>F1 Score:</strong> {best_f1:.4f}</p>
        </div>
""")
            
            f.write("""
        <table>
            <tr>
                <th>Metric</th>
                <th>Mean</th>
                <th>Std</th>
                <th>Min</th>
                <th>Max</th>
            </tr>
""")
            
            for col in metric_cols[:10]:
                if not df[col].isna().all():
                    f.write(f"""
            <tr>
                <td>{col.replace('metrics.', '')}</td>
                <td>{df[col].mean():.4f}</td>
                <td>{df[col].std():.4f}</td>
                <td>{df[col].min():.4f}</td>
                <td>{df[col].max():.4f}</td>
            </tr>
""")
            
            f.write("""
        </table>
    </div>
""")
            
            # Embed visualizations
            f.write("""
    <div class="section">
        <h2>Visualizations</h2>
""")
            
            # Create and embed visualizations
            viz_files = []
            
            # 1. Parallel coordinates
            fig1 = self.create_parallel_coordinates(df)
            if fig1:
                fig1_file = output_dir / f"{experiment_name}_parallel.html"
                fig1.write_html(fig1_file)
                viz_files.append(('Parallel Coordinates', fig1_file))
            
            # 2. Scatter matrix
            fig2 = self.create_scatter_matrix(df)
            if fig2:
                fig2_file = output_dir / f"{experiment_name}_scatter_matrix.html"
                fig2.write_html(fig2_file)
                viz_files.append(('Scatter Matrix', fig2_file))
            
            # 3. Metric trends
            if metric_cols:
                fig3 = self.create_metric_trends(df, metric_cols[0])
                if fig3:
                    fig3_file = output_dir / f"{experiment_name}_metric_trend.html"
                    fig3.write_html(fig3_file)
                    viz_files.append(('Metric Trend', fig3_file))
            
            # Embed visualizations
            for title, file_path in viz_files:
                f.write(f"""
        <div style="margin: 20px 0;">
            <h3>{title}</h3>
            <iframe src="{file_path.name}" width="100%" height="600px" frameborder="0"></iframe>
        </div>
""")
            
            f.write("""
    </div>
""")
            
            # Runs table
            f.write("""
    <div class="section">
        <h2>All Runs</h2>
        <table>
            <tr>
                <th>Run Name</th>
                <th>Run ID</th>
                <th>Best F1</th>
                <th>Accuracy</th>
                <th>Parameters</th>
            </tr>
""")
            
            for idx, run in df.head(20).iterrows():
                run_f1 = None
                for col in f1_cols[:1]:  # Just take first f1 metric
                    if not pd.isna(run[col]):
                        run_f1 = run[col]
                        break
                
                # Get some parameters
                params = []
                param_cols = [col for col in df.columns if col.startswith('params.')]
                for col in param_cols[:3]:
                    if not pd.isna(run[col]):
                        params.append(f"{col.replace('params.', '')}: {run[col]}")
                
                f.write(f"""
            <tr>
                <td>{run.get('run_name', 'N/A')}</td>
                <td>{run.get('run_id', 'N/A')[:8]}</td>
                <td>{run_f1:.4f if run_f1 else 'N/A'}</td>
                <td>{run.get('metrics.accuracy', 'N/A')}</td>
                <td>{', '.join(params)}</td>
            </tr>
""")
            
            f.write("""
        </table>
    </div>
""")
            
            # Close HTML
            f.write("""
</div>
</body>
</html>
""")
        
        logger.info(f"Comprehensive report saved to: {html_file}")
        return html_file


def create_advanced_comparison(experiment_names: List[str], output_dir: str = "reports"):
    """
    Create advanced comparison between multiple experiments.
    
    Args:
        experiment_names: List of experiment names to compare
        output_dir: Directory to save the report
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    visualizer = MLflowVisualizer()
    
    # Get data for all experiments
    all_runs = []
    for exp_name in experiment_names:
        df = visualizer.get_experiment_runs(exp_name)
        if not df.empty:
            df['experiment'] = exp_name
            all_runs.append(df)
    
    if not all_runs:
        logger.error("No runs found for any experiment")
        return
    
    combined_df = pd.concat(all_runs, ignore_index=True)
    
    # Create comparison HTML
    html_file = output_dir / "experiment_comparison.html"
    
    with open(html_file, 'w') as f:
        f.write(f"""<!DOCTYPE html>
<html>
<head>
    <title>MLflow Experiment Comparison</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }}
        .container {{ max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; }}
        .header {{ background-color: #2c3e50; color: white; padding: 20px; border-radius: 5px; }}
        .section {{ margin: 30px 0; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }}
        .experiment-box {{ display: inline-block; margin: 10px; padding: 15px; background-color: #ecf0f1; border-radius: 5px; min-width: 200px; }}
        .best {{ background-color: #27ae60; color: white; }}
        h1, h2, h3 {{ color: #2c3e50; }}
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>MLflow Experiment Comparison</h1>
        <p>Generated: {pd.Timestamp.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        <p>Experiments: {', '.join(experiment_names)}</p>
        <p>Total Runs: {len(combined_df)}</p>
    </div>
""")
        
        # Summary per experiment
        f.write("""
    <div class="section">
        <h2>Experiment Summary</h2>
""")
        
        for exp_name in experiment_names:
            exp_df = combined_df[combined_df['experiment'] == exp_name]
            
            # Find best f1
            f1_cols = [col for col in exp_df.columns if 'f1' in col.lower() and col.startswith('metrics.')]
            best_f1 = None
            if f1_cols:
                for col in f1_cols:
                    if not exp_df[col].isna().all():
                        best_f1 = exp_df[col].max()
                        break
            
            f.write(f"""
        <div class="experiment-box">
            <h3>{exp_name}</h3>
            <p>Runs: {len(exp_df)}</p>
            <p>Best F1: {best_f1:.4f if best_f1 else 'N/A'}</p>
        </div>
""")
        
        f.write("""
    </div>
""")
        
        # Visualizations
        f.write("""
    <div class="section">
        <h2>Comparison Visualizations</h2>
""")
        
        # Create comparison plots
        fig = go.Figure()
        
        for exp_name in experiment_names:
            exp_df = combined_df[combined_df['experiment'] == exp_name]
            if 'f1' in exp_df.columns:
                fig.add_trace(go.Box(
                    y=exp_df['f1'],
                    name=exp_name,
                    boxmean='sd'
                ))
        
        fig.update_layout(
            title='F1 Score Distribution by Experiment',
            yaxis_title='F1 Score',
            height=400
        )
        
        fig_file = output_dir / "comparison_boxplot.html"
        fig.write_html(fig_file)
        
        f.write(f"""
        <div style="margin: 20px 0;">
            <iframe src="{fig_file.name}" width="100%" height="450px" frameborder="0"></iframe>
        </div>
""")
        
        # Close HTML
        f.write("""
</div>
</body>
</html>
""")
    
    logger.info(f"Comparison report saved to: {html_file}")
    return html_file
EOF
```

### Step 2: Create a Visualization Script

```bash
cat > scripts/generate_visualizations.py << 'EOF'
#!/usr/bin/env python
"""
Generate comprehensive visualizations for MLflow experiments.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import argparse
from src.visualization.mlflow_viz import MLflowVisualizer, create_advanced_comparison


def main():
    parser = argparse.ArgumentParser(description="Generate MLflow visualizations")
    parser.add_argument("--experiment", type=str, help="Experiment name to visualize")
    parser.add_argument("--experiments", type=str, nargs="+", help="Multiple experiments to compare")
    parser.add_argument("--output", type=str, default="reports", help="Output directory")
    parser.add_argument("--compare", action="store_true", help="Compare multiple experiments")
    
    args = parser.parse_args()
    
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    if args.compare and args.experiments:
        # Compare multiple experiments
        create_advanced_comparison(args.experiments, args.output)
    
    elif args.experiment:
        # Generate report for single experiment
        visualizer = MLflowVisualizer()
        report_path = visualizer.create_comprehensive_report(args.experiment, args.output)
        print(f"Report generated: {report_path}")
    
    else:
        print("Please specify either --experiment or --experiments with --compare")


if __name__ == "__main__":
    main()
EOF

chmod +x scripts/generate_visualizations.py
```

### Step 3: Create Interactive Dashboard Script

```bash
cat > scripts/dashboard.py << 'EOF'
#!/usr/bin/env python
"""
Interactive MLflow dashboard using Dash.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import dash
from dash import dcc, html, Input, Output, State
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import mlflow
from src.visualization.mlflow_viz import MLflowVisualizer

# Initialize
visualizer = MLflowVisualizer()

# Get available experiments
experiments = mlflow.search_experiments()
experiment_names = [exp.name for exp in experiments if exp.lifecycle_stage == 'active']

# Create Dash app
app = dash.Dash(__name__, title="MLflow Dashboard")

app.layout = html.Div([
    html.H1("MLflow Experiment Dashboard", style={'textAlign': 'center'}),
    
    html.Div([
        html.Label("Select Experiment:"),
        dcc.Dropdown(
            id='experiment-selector',
            options=[{'label': name, 'value': name} for name in experiment_names],
            value=experiment_names[0] if experiment_names else None,
            style={'width': '50%'}
        ),
    ], style={'padding': '20px'}),
    
    html.Div([
        dcc.Graph(id='metric-trends', style={'display': 'inline-block', 'width': '48%'}),
        dcc.Graph(id='metric-distribution', style={'display': 'inline-block', 'width': '48%'}),
    ]),
    
    html.Div([
        dcc.Graph(id='parallel-coordinates', style={'width': '100%'}),
    ]),
    
    html.Div([
        dcc.Graph(id='parameter-effects', style={'width': '100%'}),
    ]),
    
    html.Div([
        html.H3("Best Runs"),
        html.Div(id='best-runs-table')
    ], style={'padding': '20px'}),
    
    dcc.Interval(
        id='interval-component',
        interval=60*1000,  # Update every minute
        n_intervals=0
    )
])


@app.callback(
    [Output('metric-trends', 'figure'),
     Output('metric-distribution', 'figure'),
     Output('parallel-coordinates', 'figure'),
     Output('parameter-effects', 'figure'),
     Output('best-runs-table', 'children')],
    [Input('experiment-selector', 'value'),
     Input('interval-component', 'n_intervals')]
)
def update_dashboard(experiment_name, n_intervals):
    """Update all dashboard components."""
    
    if experiment_name is None:
        return {}, {}, {}, {}, "No experiment selected"
    
    # Get runs
    df = visualizer.get_experiment_runs(experiment_name)
    
    if df.empty:
        return {}, {}, {}, {}, "No runs found"
    
    # 1. Metric trends
    metric_cols = [col for col in df.columns if col.startswith('metrics.')]
    metric_trends = go.Figure()
    
    for col in metric_cols[:5]:
        if not df[col].isna().all():
            metric_trends.add_trace(go.Scatter(
                x=df['start_time'] if 'start_time' in df.columns else list(range(len(df))),
                y=df[col],
                mode='lines+markers',
                name=col.replace('metrics.', '')
            ))
    
    metric_trends.update_layout(
        title="Metric Trends",
        xaxis_title="Time" if 'start_time' in df.columns else "Run Index",
        yaxis_title="Metric Value",
        height=400
    )
    
    # 2. Metric distribution
    if metric_cols:
        metric_dist = go.Figure()
        for col in metric_cols[:3]:
            if not df[col].isna().all():
                metric_dist.add_trace(go.Violin(
                    y=df[col],
                    name=col.replace('metrics.', ''),
                    box_visible=True,
                    meanline_visible=True
                ))
        
        metric_dist.update_layout(
            title="Metric Distribution",
            height=400
        )
    else:
        metric_dist = {}
    
    # 3. Parallel coordinates
    parallel_fig = visualizer.create_parallel_coordinates(df)
    
    # 4. Parameter effects
    param_cols = [col for col in df.columns if col.startswith('params.') and col not in ['params.dataset_info', 'params.feature_names']]
    param_effects = go.Figure()
    
    if param_cols and metric_cols:
        for param in param_cols[:2]:
            for metric in metric_cols[:1]:
                try:
                    pd.to_numeric(df[param])
                    param_effects.add_trace(go.Scatter(
                        x=df[param],
                        y=df[metric],
                        mode='markers',
                        name=f"{param.replace('params.', '')} vs {metric.replace('metrics.', '')}",
                        marker=dict(
                            size=10,
                            color=df[metric],
                            colorscale='Viridis',
                            showscale=True
                        )
                    ))
                except:
                    pass
        
        param_effects.update_layout(
            title="Parameter Effects",
            height=400
        )
    
    # 5. Best runs table
    best_runs = []
    if metric_cols:
        f1_cols = [col for col in metric_cols if 'f1' in col.lower()]
        if f1_cols:
            f1_col = f1_cols[0]
            top_runs = df.nlargest(10, f1_col)[['run_name', 'run_id', f1_col] + 
                                              [col for col in param_cols[:3] if col in df.columns]]
            
            best_runs = html.Table([
                html.Thead(html.Tr([
                    html.Th(col.replace('params.', '').replace('metrics.', '').replace('run_', ''))
                    for col in top_runs.columns
                ])),
                html.Tbody([
                    html.Tr([
                        html.Td(str(val))
                        for val in row
                    ]) for row in top_runs.values
                ])
            ])
    
    return metric_trends, metric_dist, parallel_fig, param_effects, best_runs


if __name__ == "__main__":
    app.run_server(debug=True, port=8050)
EOF

chmod +x scripts/dashboard.py
```

### Step 4: Run the Visualizations

```bash
# Generate comprehensive report for an experiment
python scripts/generate_visualizations.py \
    --experiment "Predictive_Maintenance_Full" \
    --output reports

# Compare multiple experiments
python scripts/generate_visualizations.py \
    --experiments "Predictive_Maintenance_Full" "Hyperparameter_Sweep" \
    --compare \
    --output reports

# Launch the interactive dashboard
python scripts/dashboard.py
# Open http://localhost:8050 in your browser
```

## The Verification: Testing Visualization Tools

### Verification 1: Check Generated Reports

```bash
# Check that reports were generated
ls -la reports/

# Open the HTML report in your browser
open reports/Predictive_Maintenance_Full_report.html

# Expected output: A comprehensive dashboard with:
# - Summary statistics
# - Best performing run
# - Interactive visualizations
# - All runs table
```

### Verification 2: Test Parallel Coordinates

```bash
# Generate parallel coordinates plot specifically
python -c "
from src.visualization.mlflow_viz import MLflowVisualizer
viz = MLflowVisualizer()
df = viz.get_experiment_runs('Predictive_Maintenance_Full')
fig = viz.create_parallel_coordinates(df, output_file='reports/parallel.html')
print('Parallel coordinates plot saved to reports/parallel.html')
"
```

### Verification 3: Test Interactive Dashboard

```bash
# Start the dashboard
python scripts/dashboard.py

# In another terminal, check it's running
curl http://localhost:8050

# Expected output: HTML content from the dashboard
```

## What We've Accomplished

You now have a comprehensive visualization system that:

1. **Creates parallel coordinates plots** for multi-dimensional analysis
2. **Generates radar charts** for run comparison
3. **Builds scatter matrices** for parameter correlation analysis
4. **Tracks metric trends** over time
5. **Shows parameter effects** on metrics
6. **Creates comprehensive HTML reports** with embedded visualizations
7. **Provides an interactive dashboard** for real-time experiment analysis
8. **Compares multiple experiments** side-by-side

## Next Steps

In Part 8, we'll:
- Implement the MLflow Model Registry
- Manage model lifecycle (Staging → Production)
- Set up automatic model promotion
- Create deployment pipelines

---

*End of Part 7: Visualizing Experiments and Comparing Runs*
