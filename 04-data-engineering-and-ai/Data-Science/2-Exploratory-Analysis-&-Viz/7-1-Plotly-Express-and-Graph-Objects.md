# Phase 2: Exploratory Data Analysis & Visualization

## Module 2.3: Interactive Data Exploration

### Part 1: Plotly Express and Graph Objects - Interactive Visualizations

---

#### The Target

In this part, we'll build a comprehensive toolkit for creating interactive visualizations using Plotly Express and Graph Objects. By the end, you'll have:

1. Mastery of Plotly Express for quick, interactive chart creation
2. Deep understanding of Plotly Graph Objects for fine-grained control
3. The ability to create interactive scatter plots, distributions, heatmaps, and 3D visualizations
4. Dynamic sliders, dropdowns, and hover tooltips
5. A reusable class for generating interactive visualizations

---

#### The Concept

**Plotly: Interactive Visualization for the Web**

Think of Plotly as creating a mini-web application every time you make a chart. Unlike static Matplotlib figures that are just images, Plotly charts are interactive HTML components that your users can explore:

- **Hover** to see data values
- **Zoom** and pan to examine details
- **Click** to highlight or filter
- **Select** regions to isolate data
- **Toggle** legend items to show/hide traces

**Plotly Express vs. Graph Objects**

- **Plotly Express (px):** The high-level API. Think of it like Seaborn for Plotly—quick, concise, and great for common chart types. One line of code can create a complex interactive chart.

- **Graph Objects (go):** The low-level API. Think of it like Matplotlib's OO API—you build charts piece by piece. Gives you complete control over every element.

**Why Interactive Visualization Matters**

1. **Exploration:** Users can investigate data on their own terms
2. **Communication:** Interactive charts engage audiences more effectively
3. **Discovery:** Zooming and filtering reveals patterns not visible in static charts
4. **Flexibility:** One chart can serve multiple analytical needs

---

#### The Implementation

##### Step 1: Create the Plotly Toolkit Module

**File:** `src/plotly_toolkit.py`
```python
"""
Plotly Interactive Visualization Toolkit

A comprehensive module for creating interactive visualizations
using Plotly Express and Graph Objects.

This module provides:
- Quick charts with Plotly Express
- Fine-grained control with Graph Objects
- Interactive features (hover, zoom, selection)
- 3D visualizations
- Dynamic updates with sliders and dropdowns
"""

import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np
from pathlib import Path
import json
import warnings
warnings.filterwarnings('ignore')

# Set default template for consistent styling
DEFAULT_TEMPLATE = 'plotly_white'


class PlotlyVisualizer:
    """
    A class for creating interactive visualizations with Plotly.
    
    This class provides methods for both Plotly Express and
    Graph Objects, with consistent styling and interactivity.
    
    Attributes:
        df (pd.DataFrame): The dataset
        output_dir (Path): Directory for saving charts
        template (str): Plotly template for styling
    """
    
    def __init__(self, df: pd.DataFrame, 
                 output_dir: str = "outputs/figures",
                 template: str = DEFAULT_TEMPLATE):
        """
        Initialize the visualizer.
        
        Parameters:
        -----------
        df : pd.DataFrame
            The dataset to visualize
        output_dir : str
            Directory for saving figures
        template : str
            Plotly template name
        """
        self.df = df.copy()
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.template = template
        
        # Detect column types
        self.numerical_cols = self.df.select_dtypes(include=[np.number]).columns.tolist()
        self.categorical_cols = self.df.select_dtypes(include=['object', 'category']).columns.tolist()
        
        # Remove ID columns
        self.numerical_cols = [c for c in self.numerical_cols if c not in ['customer_id']]
        
        # Set up color palettes
        self.color_discrete_sequence = px.colors.qualitative.Set2
        self.color_continuous_scale = px.colors.sequential.Viridis
        
        print(f"📊 Visualizing {len(self.numerical_cols)} numerical and {len(self.categorical_cols)} categorical columns")
    
    # ---------- PLOTLY EXPRESS CHARTS ----------
    
    def create_scatter_plot(self, x_col: str, y_col: str,
                           color_col: str = None,
                           size_col: str = None,
                           hover_cols: list = None,
                           title: str = None,
                           trendline: bool = False,
                           log_x: bool = False,
                           log_y: bool = False,
                           save: bool = True) -> go.Figure:
        """
        Create an interactive scatter plot using Plotly Express.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis
        y_col : str
            Column for y-axis
        color_col : str
            Column for color encoding
        size_col : str
            Column for size encoding
        hover_cols : list
            Additional columns for hover tooltips
        title : str
            Chart title
        trendline : bool
            Whether to add trendline
        log_x : bool
            Whether to use log scale for x-axis
        log_y : bool
            Whether to use log scale for y-axis
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        # Prepare hover data
        if hover_cols is None:
            hover_cols = [x_col, y_col]
            if color_col:
                hover_cols.append(color_col)
            if size_col:
                hover_cols.append(size_col)
        
        # Create the scatter plot
        fig = px.scatter(
            self.df,
            x=x_col,
            y=y_col,
            color=color_col,
            size=size_col,
            hover_data=hover_cols,
            title=title or f'Scatter Plot: {y_col} vs {x_col}',
            template=self.template,
            color_discrete_sequence=self.color_discrete_sequence,
            color_continuous_scale=self.color_continuous_scale,
            log_x=log_x,
            log_y=log_y,
            trendline='ols' if trendline else None,
            trendline_color_override='red'
        )
        
        # Customize layout
        fig.update_layout(
            xaxis_title=x_col,
            yaxis_title=y_col,
            hovermode='closest',
            width=800,
            height=600
        )
        
        # Add hover mode
        fig.update_traces(
            hovertemplate='<b>%{text}</b><br>' +
                         f'{x_col}: %{{x}}<br>' +
                         f'{y_col}: %{{y}}<br>' +
                         '<extra></extra>',
            text=self.df.index
        )
        
        if save:
            self.save_figure(fig, f'plotly_scatter_{x_col}_vs_{y_col}')
        
        return fig
    
    def create_histogram(self, col: str,
                        color_col: str = None,
                        nbins: int = 30,
                        title: str = None,
                        marginal: str = 'box',
                        save: bool = True) -> go.Figure:
        """
        Create an interactive histogram.
        
        Parameters:
        -----------
        col : str
            Column to visualize
        color_col : str
            Column for color grouping
        nbins : int
            Number of bins
        title : str
            Chart title
        marginal : str
            Marginal plot type ('box', 'violin', 'rug', None)
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        fig = px.histogram(
            self.df,
            x=col,
            color=color_col,
            nbins=nbins,
            title=title or f'Distribution of {col}',
            template=self.template,
            color_discrete_sequence=self.color_discrete_sequence,
            color_continuous_scale=self.color_continuous_scale,
            marginal=marginal if marginal != 'none' else None,
            barmode='overlay'
        )
        
        # Customize layout
        fig.update_layout(
            xaxis_title=col,
            yaxis_title='Count',
            hovermode='closest',
            width=800,
            height=600,
            bargap=0.1
        )
        
        # Add hover info
        fig.update_traces(
            hovertemplate=f'<b>{col}</b>: %{{x}}<br>Count: %{{y}}<extra></extra>'
        )
        
        if save:
            self.save_figure(fig, f'plotly_histogram_{col}')
        
        return fig
    
    def create_bar_chart(self, x_col: str, y_col: str = None,
                        color_col: str = None,
                        title: str = None,
                        horizontal: bool = False,
                        stacked: bool = False,
                        save: bool = True) -> go.Figure:
        """
        Create an interactive bar chart.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis (categorical)
        y_col : str
            Column for y-axis (numerical or 'count')
        color_col : str
            Column for color grouping
        title : str
            Chart title
        horizontal : bool
            Whether to create horizontal bars
        stacked : bool
            Whether to stack bars
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        # Determine if we're counting or aggregating
        if y_col is None:
            # Count of x_col
            aggregated = self.df.groupby(x_col).size().reset_index(name='count')
            fig = px.bar(
                aggregated,
                x=x_col if not horizontal else 'count',
                y='count' if not horizontal else x_col,
                color=color_col if color_col else None,
                title=title or f'Count of {x_col}',
                template=self.template,
                color_discrete_sequence=self.color_discrete_sequence,
                orientation='h' if horizontal else 'v',
                barmode='stack' if stacked else 'group'
            )
        else:
            # Aggregate y_col by x_col
            aggregated = self.df.groupby(x_col)[y_col].mean().reset_index()
            aggregated.columns = [x_col, f'mean_{y_col}']
            
            fig = px.bar(
                aggregated,
                x=x_col if not horizontal else f'mean_{y_col}',
                y=f'mean_{y_col}' if not horizontal else x_col,
                title=title or f'Mean {y_col} by {x_col}',
                template=self.template,
                color_discrete_sequence=self.color_discrete_sequence,
                orientation='h' if horizontal else 'v'
            )
        
        # Customize layout
        fig.update_layout(
            xaxis_title=x_col if not horizontal else f'Mean {y_col}' if y_col else 'Count',
            yaxis_title='Count' if y_col is None else f'Mean {y_col}',
            hovermode='closest',
            width=800,
            height=600
        )
        
        # Add hover info
        fig.update_traces(
            hovertemplate='<b>%{x}</b><br>Value: %{y}<extra></extra>'
        )
        
        if save:
            suffix = f'{x_col}_vs_{y_col}' if y_col else f'{x_col}_count'
            self.save_figure(fig, f'plotly_bar_{suffix}')
        
        return fig
    
    def create_heatmap(self, x_col: str, y_col: str,
                      value_col: str = None,
                      agg_func: str = 'mean',
                      title: str = None,
                      save: bool = True) -> go.Figure:
        """
        Create an interactive heatmap.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis
        y_col : str
            Column for y-axis
        value_col : str
            Column for values (if None, counts)
        agg_func : str
            Aggregation function ('count', 'mean', 'sum', etc.)
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        # Create pivot table
        if value_col is None:
            pivot = self.df.pivot_table(
                index=y_col,
                columns=x_col,
                values=value_col,
                aggfunc='count',
                fill_value=0
            )
            title = title or f'Heatmap: {y_col} vs {x_col} (Counts)'
        else:
            pivot = self.df.pivot_table(
                index=y_col,
                columns=x_col,
                values=value_col,
                aggfunc=agg_func,
                fill_value=0
            )
            title = title or f'Heatmap: {y_col} vs {x_col} ({agg_func} of {value_col})'
        
        # Create heatmap
        fig = px.imshow(
            pivot,
            title=title,
            template=self.template,
            color_continuous_scale=self.color_continuous_scale,
            aspect='auto',
            text_auto=True
        )
        
        # Customize layout
        fig.update_layout(
            xaxis_title=x_col,
            yaxis_title=y_col,
            width=800,
            height=600
        )
        
        # Add hover info
        fig.update_traces(
            hovertemplate='<b>%{x}</b><br>%{y}<br>Value: %{z}<extra></extra>'
        )
        
        if save:
            self.save_figure(fig, f'plotly_heatmap_{x_col}_vs_{y_col}')
        
        return fig
    
    def create_box_plot(self, numerical_col: str, categorical_col: str,
                       title: str = None,
                       points: str = 'all',
                       save: bool = True) -> go.Figure:
        """
        Create an interactive box plot.
        
        Parameters:
        -----------
        numerical_col : str
            Numerical column
        categorical_col : str
            Categorical column for grouping
        title : str
            Chart title
        points : str
            How to show points ('all', 'outliers', 'suspectedoutliers', False)
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        fig = px.box(
            self.df,
            x=categorical_col,
            y=numerical_col,
            title=title or f'Distribution of {numerical_col} by {categorical_col}',
            template=self.template,
            color=categorical_col,
            color_discrete_sequence=self.color_discrete_sequence,
            points=points
        )
        
        # Customize layout
        fig.update_layout(
            xaxis_title=categorical_col,
            yaxis_title=numerical_col,
            hovermode='closest',
            width=800,
            height=600
        )
        
        # Add hover info
        fig.update_traces(
            hovertemplate='<b>%{x}</b><br>%{y}<extra></extra>'
        )
        
        if save:
            self.save_figure(fig, f'plotly_box_{numerical_col}_by_{categorical_col}')
        
        return fig
    
    def create_violin_plot(self, numerical_col: str, categorical_col: str,
                          title: str = None,
                          box: bool = True,
                          save: bool = True) -> go.Figure:
        """
        Create an interactive violin plot.
        
        Parameters:
        -----------
        numerical_col : str
            Numerical column
        categorical_col : str
            Categorical column for grouping
        title : str
            Chart title
        box : bool
            Whether to show box plot inside violin
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        fig = px.violin(
            self.df,
            x=categorical_col,
            y=numerical_col,
            title=title or f'Distribution of {numerical_col} by {categorical_col}',
            template=self.template,
            color=categorical_col,
            color_discrete_sequence=self.color_discrete_sequence,
            box=box,
            points='all' if box else 'outliers'
        )
        
        # Customize layout
        fig.update_layout(
            xaxis_title=categorical_col,
            yaxis_title=numerical_col,
            hovermode='closest',
            width=800,
            height=600
        )
        
        if save:
            self.save_figure(fig, f'plotly_violin_{numerical_col}_by_{categorical_col}')
        
        return fig
    
    # ---------- 3D VISUALIZATIONS ----------
    
    def create_3d_scatter(self, x_col: str, y_col: str, z_col: str,
                         color_col: str = None,
                         size_col: str = None,
                         title: str = None,
                         save: bool = True) -> go.Figure:
        """
        Create a 3D scatter plot.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis
        y_col : str
            Column for y-axis
        z_col : str
            Column for z-axis
        color_col : str
            Column for color encoding
        size_col : str
            Column for size encoding
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        fig = px.scatter_3d(
            self.df,
            x=x_col,
            y=y_col,
            z=z_col,
            color=color_col,
            size=size_col,
            title=title or f'3D Scatter: {x_col}, {y_col}, {z_col}',
            template=self.template,
            color_discrete_sequence=self.color_discrete_sequence,
            color_continuous_scale=self.color_continuous_scale
        )
        
        # Customize layout
        fig.update_layout(
            scene=dict(
                xaxis_title=x_col,
                yaxis_title=y_col,
                zaxis_title=z_col
            ),
            width=900,
            height=700
        )
        
        if save:
            self.save_figure(fig, f'plotly_3d_scatter_{x_col}_{y_col}_{z_col}')
        
        return fig
    
    def create_3d_surface(self, x_col: str, y_col: str, z_col: str,
                         title: str = None,
                         save: bool = True) -> go.Figure:
        """
        Create a 3D surface plot.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis (categorical or binned)
        y_col : str
            Column for y-axis (categorical or binned)
        z_col : str
            Column for z-axis (numerical)
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        # Create pivot table for surface
        pivot = self.df.pivot_table(
            index=y_col,
            columns=x_col,
            values=z_col,
            aggfunc='mean',
            fill_value=0
        )
        
        fig = go.Figure(data=[
            go.Surface(
                z=pivot.values,
                x=pivot.columns,
                y=pivot.index,
                colorscale=self.color_continuous_scale,
                hovertemplate='<b>%{x}</b><br>%{y}<br>%{z}<extra></extra>'
            )
        ])
        
        fig.update_layout(
            title=title or f'3D Surface: {z_col} by {x_col} and {y_col}',
            scene=dict(
                xaxis_title=x_col,
                yaxis_title=y_col,
                zaxis_title=z_col
            ),
            width=900,
            height=700,
            template=self.template
        )
        
        if save:
            self.save_figure(fig, f'plotly_3d_surface_{x_col}_{y_col}_{z_col}')
        
        return fig
    
    # ---------- GRAPH OBJECTS (FINE-GRAINED CONTROL) ----------
    
    def create_custom_subplots(self, rows: int, cols: int,
                              subplot_titles: list = None,
                              shared_xaxes: bool = True,
                              shared_yaxes: bool = False,
                              title: str = None,
                              save: bool = True) -> go.Figure:
        """
        Create a custom subplot layout with Graph Objects.
        
        This provides low-level control for complex multi-panel figures.
        
        Parameters:
        -----------
        rows : int
            Number of rows
        cols : int
            Number of columns
        subplot_titles : list
            Titles for each subplot
        shared_xaxes : bool
            Whether to share x-axes
        shared_yaxes : bool
            Whether to share y-axes
        title : str
            Overall figure title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        fig = make_subplots(
            rows=rows,
            cols=cols,
            subplot_titles=subplot_titles,
            shared_xaxes=shared_xaxes,
            shared_yaxes=shared_yaxes
        )
        
        # Add custom traces (to be filled by user)
        fig.update_layout(
            title=title,
            template=self.template,
            width=800 * cols,
            height=500 * rows
        )
        
        if save:
            self.save_figure(fig, 'plotly_custom_subplots')
        
        return fig
    
    def create_dynamic_line_chart(self, x_col: str, y_col: str,
                                 group_col: str = None,
                                 title: str = None,
                                 save: bool = True) -> go.Figure:
        """
        Create a dynamic line chart with Graph Objects.
        
        Demonstrates fine-grained control over line styling.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis
        y_col : str
            Column for y-axis
        group_col : str
            Column for grouping lines
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        fig = go.Figure()
        
        # Sort data
        sorted_df = self.df.sort_values(x_col)
        
        if group_col:
            # Create separate traces for each group
            for group in sorted_df[group_col].unique():
                group_data = sorted_df[sorted_df[group_col] == group]
                fig.add_trace(go.Scatter(
                    x=group_data[x_col],
                    y=group_data[y_col],
                    name=str(group),
                    mode='lines+markers',
                    marker=dict(size=6),
                    line=dict(width=2),
                    hovertemplate=f'<b>{group}</b><br>' +
                                 f'{x_col}: %{{x}}<br>' +
                                 f'{y_col}: %{{y}}<extra></extra>'
                ))
        else:
            # Single line
            fig.add_trace(go.Scatter(
                x=sorted_df[x_col],
                y=sorted_df[y_col],
                mode='lines+markers',
                marker=dict(size=6, color='steelblue'),
                line=dict(width=2, color='steelblue'),
                hovertemplate=f'{x_col}: %{{x}}<br>{y_col}: %{{y}}<extra></extra>'
            ))
        
        fig.update_layout(
            title=title or f'Line Chart: {y_col} vs {x_col}',
            xaxis_title=x_col,
            yaxis_title=y_col,
            hovermode='closest',
            template=self.template,
            width=800,
            height=600,
            legend=dict(
                yanchor='top',
                y=0.99,
                xanchor='left',
                x=0.01
            )
        )
        
        if save:
            self.save_figure(fig, f'plotly_line_{x_col}_vs_{y_col}')
        
        return fig
    
    # ---------- INTERACTIVE CONTROLS ----------
    
    def create_chart_with_slider(self, x_col: str, y_col: str,
                                slider_col: str,
                                title: str = None,
                                save: bool = True) -> go.Figure:
        """
        Create a chart with a dynamic slider.
        
        Demonstrates adding interactive controls to explore
        data over a temporal or sequential dimension.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis
        y_col : str
            Column for y-axis
        slider_col : str
            Column for slider control
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        go.Figure
            The Plotly figure object
        """
        # Create figure
        fig = go.Figure()
        
        # Get unique slider values
        slider_values = sorted(self.df[slider_col].unique())
        
        # Add traces for each slider value
        for i, value in enumerate(slider_values):
            data = self.df[self.df[slider_col] == value]
            
            fig.add_trace(go.Scatter(
                x=data[x_col],
                y=data[y_col],
                mode='markers',
                marker=dict(
                    size=8,
                    color=self.color_continuous_scale[i % len(self.color_continuous_scale)]
                ),
                name=f'{slider_col}={value}',
                visible=(i == 0),  # Only first trace visible initially
                hovertemplate=f'{slider_col}: {value}<br>' +
                             f'{x_col}: %{{x}}<br>{y_col}: %{{y}}<extra></extra>'
            ))
        
        # Create slider
        steps = []
        for i, value in enumerate(slider_values):
            step = dict(
                method='update',
                args=[{'visible': [False] * len(fig.data)}],
                label=str(value)
            )
            step['args'][0]['visible'][i] = True
            steps.append(step)
        
        sliders = [dict(
            active=0,
            currentvalue={'prefix': f'{slider_col}: '},
            pad={'t': 50},
            steps=steps
        )]
        
        # Update layout
        fig.update_layout(
            title=title or f'{y_col} vs {x_col} (slider: {slider_col})',
            xaxis_title=x_col,
            yaxis_title=y_col,
            sliders=sliders,
            template=self.template,
            width=800,
            height=600
        )
        
        if save:
            self.save_figure(fig, f'plotly_slider_{x_col}_vs_{y_col}')
        
        return fig
    
    # ---------- SAVING ----------
    
    def save_figure(self, fig: go.Figure, name: str,
                   formats: list = ['html', 'json']) -> None:
        """
        Save figure in multiple formats.
        
        Parameters:
        -----------
        fig : go.Figure
            The Plotly figure to save
        name : str
            Base name for files
        formats : list
            Formats to save ('html', 'json', 'png')
        """
        for fmt in formats:
            try:
                if fmt == 'html':
                    filepath = self.output_dir / f'{name}.html'
                    fig.write_html(str(filepath))
                    print(f"  ✅ Saved: {filepath}")
                
                elif fmt == 'json':
                    filepath = self.output_dir / f'{name}.json'
                    with open(filepath, 'w') as f:
                        json.dump(fig.to_dict(), f, indent=2)
                    print(f"  ✅ Saved: {filepath}")
                
                elif fmt == 'png':
                    filepath = self.output_dir / f'{name}.png'
                    fig.write_image(str(filepath))
                    print(f"  ✅ Saved: {filepath}")
            
            except Exception as e:
                print(f"  ⚠️ Could not save {fmt} for {name}: {e}")
    
    # ---------- COMPREHENSIVE ANALYSIS ----------
    
    def analyze_all(self, save_formats: list = ['html']) -> dict:
        """
        Run a comprehensive set of Plotly visualizations.
        
        Parameters:
        -----------
        save_formats : list
            Formats to save charts
            
        Returns:
        --------
        dict
            Dictionary of generated charts
        """
        results = {'charts': []}
        
        print("\n" + "=" * 60)
        print("PLOTLY INTERACTIVE VISUALIZATIONS - STARTING")
        print("=" * 60)
        
        # 1. Scatter plots
        print("\n📊 Creating scatter plots...")
        if len(self.numerical_cols) >= 2:
            x_col = self.numerical_cols[0]
            y_col = self.numerical_cols[1]
            try:
                chart = self.create_scatter_plot(
                    x_col, y_col,
                    color_col='income_bracket' if 'income_bracket' in self.categorical_cols else None,
                    save=False
                )
                results['charts'].append(('scatter', f'{x_col}_vs_{y_col}', chart))
                self.save_figure(chart, f'plotly_scatter_{x_col}_vs_{y_col}', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating scatter plot: {e}")
        
        # 2. Histograms
        print("\n📊 Creating histograms...")
        for col in self.numerical_cols[:3]:
            try:
                chart = self.create_histogram(col, save=False)
                results['charts'].append(('histogram', col, chart))
                self.save_figure(chart, f'plotly_histogram_{col}', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating histogram for {col}: {e}")
        
        # 3. Bar charts
        print("\n📊 Creating bar charts...")
        if self.categorical_cols:
            cat_col = self.categorical_cols[0]
            try:
                chart = self.create_bar_chart(cat_col, save=False)
                results['charts'].append(('bar', cat_col, chart))
                self.save_figure(chart, f'plotly_bar_{cat_col}_count', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating bar chart: {e}")
        
        # 4. Box plots
        print("\n📊 Creating box plots...")
        if self.categorical_cols and self.numerical_cols:
            cat_col = self.categorical_cols[0]
            num_col = self.numerical_cols[0]
            try:
                chart = self.create_box_plot(num_col, cat_col, save=False)
                results['charts'].append(('box', f'{num_col}_by_{cat_col}', chart))
                self.save_figure(chart, f'plotly_box_{num_col}_by_{cat_col}', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating box plot: {e}")
        
        # 5. Heatmap
        print("\n📊 Creating heatmap...")
        if len(self.categorical_cols) >= 2:
            try:
                chart = self.create_heatmap(
                    self.categorical_cols[0],
                    self.categorical_cols[1],
                    value_col=self.numerical_cols[0] if self.numerical_cols else None,
                    save=False
                )
                results['charts'].append(('heatmap', 'categorical', chart))
                self.save_figure(chart, f'plotly_heatmap_categorical', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating heatmap: {e}")
        
        # 6. 3D scatter
        print("\n📊 Creating 3D scatter plot...")
        if len(self.numerical_cols) >= 3:
            try:
                chart = self.create_3d_scatter(
                    self.numerical_cols[0],
                    self.numerical_cols[1],
                    self.numerical_cols[2],
                    color_col='income_bracket' if 'income_bracket' in self.categorical_cols else None,
                    save=False
                )
                results['charts'].append(('3d_scatter', '3d', chart))
                self.save_figure(chart, f'plotly_3d_scatter', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating 3D scatter: {e}")
        
        # 7. Chart with slider
        print("\n📊 Creating chart with slider...")
        if len(self.numerical_cols) >= 2 and 'order_frequency' in self.numerical_cols:
            try:
                # Use income_bracket as slider
                slider_col = 'income_bracket' if 'income_bracket' in self.categorical_cols else self.categorical_cols[0]
                chart = self.create_chart_with_slider(
                    self.numerical_cols[0],
                    self.numerical_cols[1],
                    slider_col,
                    save=False
                )
                results['charts'].append(('slider', 'dynamic', chart))
                self.save_figure(chart, f'plotly_slider_demo', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating slider chart: {e}")
        
        print("\n" + "=" * 60)
        print("PLOTLY VISUALIZATIONS - COMPLETE")
        print("=" * 60)
        print(f"\n✅ Generated {len(results['charts'])} visualizations")
        print(f"💡 Open the .html files in your browser for interactive exploration!")
        
        return results


# ---------- UTILITY FUNCTIONS ----------

def run_plotly_analysis(data_path: str = "data/customer_data.csv",
                       output_dir: str = "outputs/figures") -> dict:
    """
    Convenience function to run Plotly analysis.
    
    Parameters:
    -----------
    data_path : str
        Path to the CSV file
    output_dir : str
        Directory for saving figures
        
    Returns:
    --------
    dict
        Results of the analysis
    """
    print("📂 Loading dataset...")
    df = pd.read_csv(data_path)
    print(f"✅ Loaded {df.shape[0]} rows and {df.shape[1]} columns")
    
    # Create visualizer
    visualizer = PlotlyVisualizer(df, output_dir=output_dir)
    
    # Run analysis
    results = visualizer.analyze_all(save_formats=['html'])
    
    return results


if __name__ == "__main__":
    results = run_plotly_analysis()
```

---

##### Step 2: Create Advanced Plotly Examples

**File:** `src/advanced_plotly_examples.py`
```python
"""
Advanced Plotly Visualization Examples

Demonstrates advanced Plotly techniques including:
- Custom annotations and shapes
- Animation frames
- Dropdown menus
- Custom hover templates
- Mixed chart types
"""

import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd
import numpy as np
from pathlib import Path
from plotly_toolkit import PlotlyVisualizer


def demonstrate_animated_chart(data_path: str = "data/customer_data.csv"):
    """
    Create an animated chart showing changes over time.
    
    Demonstrates Plotly's animation capabilities.
    """
    
    print("\n🎬 Creating animated chart...")
    
    df = pd.read_csv(data_path)
    
    # Create animated scatter plot
    fig = go.Figure()
    
    # Use income_bracket as frame dimension
    income_brackets = sorted(df['income_bracket'].unique())
    
    # Create frames
    frames = []
    for bracket in income_brackets:
        frame_data = df[df['income_bracket'] == bracket]
        
        # Calculate aggregate stats
        agg_data = frame_data.groupby('favorite_category').agg({
            'avg_order_value': 'mean',
            'order_frequency': 'mean'
        }).reset_index()
        
        frame = go.Frame(
            data=[
                go.Scatter(
                    x=agg_data['order_frequency'],
                    y=agg_data['avg_order_value'],
                    mode='markers+text',
                    text=agg_data['favorite_category'],
                    textposition='top center',
                    marker=dict(
                        size=agg_data['avg_order_value'] / 10,
                        color=list(agg_data['avg_order_value']),
                        colorscale='Viridis',
                        showscale=True
                    ),
                    name=bracket
                )
            ],
            name=bracket
        )
        frames.append(frame)
    
    # Initial frame
    initial_data = df[df['income_bracket'] == income_brackets[0]]
    agg_initial = initial_data.groupby('favorite_category').agg({
        'avg_order_value': 'mean',
        'order_frequency': 'mean'
    }).reset_index()
    
    fig.add_trace(go.Scatter(
        x=agg_initial['order_frequency'],
        y=agg_initial['avg_order_value'],
        mode='markers+text',
        text=agg_initial['favorite_category'],
        textposition='top center',
        marker=dict(
            size=agg_initial['avg_order_value'] / 10,
            color=agg_initial['avg_order_value'],
            colorscale='Viridis',
            showscale=True,
            colorbar=dict(title='Avg Order Value')
        ),
        name=income_brackets[0]
    ))
    
    fig.frames = frames
    
    # Create slider
    fig.update_layout(
        title='Order Frequency vs Order Value by Income Bracket',
        xaxis_title='Order Frequency',
        yaxis_title='Avg Order Value ($)',
        updatemenus=[dict(
            type='buttons',
            showactive=False,
            buttons=[
                dict(label='Play',
                     method='animate',
                     args=[None, dict(frame=dict(duration=500, redraw=True),
                                    fromcurrent=True)]),
                dict(label='Pause',
                     method='animate',
                     args=[[None], dict(frame=dict(duration=0, redraw=False),
                                      mode='immediate')])
            ]
        )],
        sliders=[dict(
            active=0,
            steps=[
                dict(method='animate',
                     args=[[bracket], dict(mode='immediate')],
                     label=bracket)
                for bracket in income_brackets
            ],
            transition=dict(duration=300)
        )],
        width=1000,
        height=700,
        template='plotly_white'
    )
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    fig.write_html(str(output_dir / 'plotly_animated_chart.html'))
    print(f"  ✅ Saved: {output_dir / 'plotly_animated_chart.html'}")
    
    return fig


def demonstrate_dropdown_filters(data_path: str = "data/customer_data.csv"):
    """
    Create a chart with dropdown menu filters.
    
    Demonstrates adding interactive controls to filter data.
    """
    
    print("\n📋 Creating chart with dropdown filters...")
    
    df = pd.read_csv(data_path)
    
    # Create base figure
    fig = go.Figure()
    
    # Get unique categories
    categories = df['favorite_category'].unique()
    
    # Add a trace for each category (initially hidden)
    for category in categories:
        cat_data = df[df['favorite_category'] == category]
        avg_by_income = cat_data.groupby('income_bracket')['avg_order_value'].mean().reset_index()
        
        fig.add_trace(go.Bar(
            x=avg_by_income['income_bracket'],
            y=avg_by_income['avg_order_value'],
            name=category,
            visible=(category == categories[0]),  # Only first visible initially
            hovertemplate='<b>%{x}</b><br>Avg Order Value: $%{y:.2f}<extra></extra>'
        ))
    
    # Create dropdown buttons
    buttons = []
    for i, category in enumerate(categories):
        visibility = [False] * len(categories)
        visibility[i] = True
        
        buttons.append(
            dict(
                label=category,
                method='update',
                args=[{'visible': visibility},
                      {'title': f'Avg Order Value by Income - {category}'}]
            )
        )
    
    # Add 'All' button
    buttons.append(
        dict(
            label='All',
            method='update',
            args=[{'visible': [True] * len(categories)},
                  {'title': 'Avg Order Value by Income - All Categories'}]
        )
    )
    
    # Update layout
    fig.update_layout(
        title=f'Avg Order Value by Income - {categories[0]}',
        xaxis_title='Income Bracket',
        yaxis_title='Avg Order Value ($)',
        updatemenus=[dict(
            type='dropdown',
            buttons=buttons,
            direction='down',
            showactive=True,
            x=0.02,
            y=0.98,
            xanchor='left',
            yanchor='top'
        )],
        width=900,
        height=600,
        template='plotly_white',
        barmode='group'
    )
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    fig.write_html(str(output_dir / 'plotly_dropdown_filter.html'))
    print(f"  ✅ Saved: {output_dir / 'plotly_dropdown_filter.html'}")
    
    return fig


def demonstrate_custom_annotations(data_path: str = "data/customer_data.csv"):
    """
    Create a chart with custom annotations and shapes.
    
    Demonstrates adding custom elements to highlight insights.
    """
    
    print("\n✏️ Creating chart with custom annotations...")
    
    df = pd.read_csv(data_path)
    
    # Create figure
    fig = go.Figure()
    
    # Add scatter trace
    fig.add_trace(go.Scatter(
        x=df['time_on_site'],
        y=df['pages_viewed'],
        mode='markers',
        marker=dict(
            size=8,
            color=df['order_frequency'],
            colorscale='Plasma',
            showscale=True,
            colorbar=dict(title='Order Freq')
        ),
        text=df['customer_id'],
        hovertemplate='<b>%{text}</b><br>' +
                     'Time: %{x:.1f} min<br>' +
                     'Pages: %{y}<br>' +
                     'Order Freq: %{marker.color:.2f}<extra></extra>'
    ))
    
    # Add vertical line at average time
    avg_time = df['time_on_site'].mean()
    fig.add_vline(
        x=avg_time,
        line_dash='dash',
        line_color='red',
        line_width=2,
        annotation=dict(
            text=f'Avg Time: {avg_time:.1f} min',
            font=dict(size=12, color='red'),
            xanchor='left',
            yanchor='bottom'
        )
    )
    
    # Add horizontal line at average pages
    avg_pages = df['pages_viewed'].mean()
    fig.add_hline(
        y=avg_pages,
        line_dash='dash',
        line_color='blue',
        line_width=2,
        annotation=dict(
            text=f'Avg Pages: {avg_pages:.1f}',
            font=dict(size=12, color='blue'),
            xanchor='left',
            yanchor='top'
        )
    )
    
    # Add annotation box with key stats
    fig.add_annotation(
        x=0.98,
        y=0.98,
        xref='paper',
        yref='paper',
        text=f'<b>Key Statistics</b><br>'
             f'n = {len(df):,}<br>'
             f'Avg Time: {avg_time:.1f} min<br>'
             f'Avg Pages: {avg_pages:.1f}<br>'
             f'Avg Order Freq: {df["order_frequency"].mean():.2f}',
        showarrow=False,
        font=dict(size=12),
        bgcolor='rgba(255, 255, 255, 0.8)',
        bordercolor='gray',
        borderwidth=1
    )
    
    # Highlight high-engagement customers
    high_engagement = df[(df['time_on_site'] > 20) & (df['pages_viewed'] > 20)]
    if not high_engagement.empty:
        fig.add_trace(go.Scatter(
            x=high_engagement['time_on_site'],
            y=high_engagement['pages_viewed'],
            mode='markers',
            marker=dict(
                size=15,
                symbol='star',
                color='gold',
                line=dict(color='black', width=1)
            ),
            name='High Engagement',
            hovertemplate='<b>High Engagement</b><br>'
        ))
    
    fig.update_layout(
        title='Engagement Analysis: Time vs Pages',
        xaxis_title='Time on Site (minutes)',
        yaxis_title='Pages Viewed',
        width=900,
        height=600,
        template='plotly_white',
        hovermode='closest'
    )
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    fig.write_html(str(output_dir / 'plotly_custom_annotations.html'))
    print(f"  ✅ Saved: {output_dir / 'plotly_custom_annotations.html'}")
    
    return fig


def demonstrate_subplots_with_different_types(data_path: str = "data/customer_data.csv"):
    """
    Create subplots with different chart types.
    
    Demonstrates combining multiple chart types in one figure.
    """
    
    print("\n📊 Creating mixed subplots...")
    
    df = pd.read_csv(data_path)
    
    # Create subplots with 2 rows, 2 cols
    fig = make_subplots(
        rows=2,
        cols=2,
        subplot_titles=('Scatter: Time vs Pages', 
                       'Histogram: Order Frequency',
                       'Box: Rating by City', 
                       'Bar: Category Count'),
        specs=[
            [{'type': 'scatter'}, {'type': 'histogram'}],
            [{'type': 'box'}, {'type': 'bar'}]
        ],
        shared_xaxes=False,
        shared_yaxes=False
    )
    
    # 1. Scatter plot (row=1, col=1)
    fig.add_trace(
        go.Scatter(
            x=df['time_on_site'],
            y=df['pages_viewed'],
            mode='markers',
            marker=dict(
                size=6,
                color='steelblue',
                opacity=0.6
            ),
            hovertemplate='Time: %{x:.1f}<br>Pages: %{y}<extra></extra>'
        ),
        row=1, col=1
    )
    
    # 2. Histogram (row=1, col=2)
    fig.add_trace(
        go.Histogram(
            x=df['order_frequency'],
            nbinsx=30,
            marker=dict(color='steelblue'),
            hovertemplate='Freq: %{x}<br>Count: %{y}<extra></extra>'
        ),
        row=1, col=2
    )
    
    # 3. Box plot (row=2, col=1)
    city_labels = {1: 'Metro', 2: 'Mid', 3: 'Small'}
    df['city_label'] = df['city_tier'].map(city_labels)
    
    fig.add_trace(
        go.Box(
            x=df['city_label'],
            y=df['customer_rating'],
            boxmean='sd',
            marker=dict(color='steelblue'),
            hovertemplate='City: %{x}<br>Rating: %{y}<extra></extra>'
        ),
        row=2, col=1
    )
    
    # 4. Bar chart (row=2, col=2)
    category_counts = df['favorite_category'].value_counts()
    fig.add_trace(
        go.Bar(
            x=category_counts.index,
            y=category_counts.values,
            marker=dict(color='coral'),
            hovertemplate='Category: %{x}<br>Count: %{y}<extra></extra>'
        ),
        row=2, col=2
    )
    
    # Update layout
    fig.update_layout(
        title='Comprehensive Customer Analysis Dashboard',
        height=800,
        width=1000,
        template='plotly_white',
        showlegend=False
    )
    
    # Update axes
    fig.update_xaxes(title_text='Time on Site', row=1, col=1)
    fig.update_yaxes(title_text='Pages Viewed', row=1, col=1)
    fig.update_xaxes(title_text='Order Frequency', row=1, col=2)
    fig.update_yaxes(title_text='Count', row=1, col=2)
    fig.update_xaxes(title_text='City Tier', row=2, col=1)
    fig.update_yaxes(title_text='Rating', row=2, col=1)
    fig.update_xaxes(title_text='Category', row=2, col=2)
    fig.update_yaxes(title_text='Count', row=2, col=2)
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    fig.write_html(str(output_dir / 'plotly_mixed_subplots.html'))
    print(f"  ✅ Saved: {output_dir / 'plotly_mixed_subplots.html'}")
    
    return fig


def run_all_plotly_examples(data_path: str = "data/customer_data.csv"):
    """
    Run all Plotly demonstrations.
    """
    
    print("=" * 60)
    print("PLOTLY ADVANCED EXAMPLES")
    print("=" * 60)
    
    # Run basic analysis
    print("\n🔍 Running basic Plotly analysis...")
    run_plotly_analysis(data_path)
    
    # Run advanced examples
    demonstrate_animated_chart(data_path)
    demonstrate_dropdown_filters(data_path)
    demonstrate_custom_annotations(data_path)
    demonstrate_subplots_with_different_types(data_path)
    
    print("\n" + "=" * 60)
    print("ALL PLOTLY EXAMPLES COMPLETE")
    print("=" * 60)
    print("\n📁 HTML files saved to: outputs/figures/")
    print("  • plotly_*.html (multiple files)")
    print("  • plotly_animated_chart.html")
    print("  • plotly_dropdown_filter.html")
    print("  • plotly_custom_annotations.html")
    print("  • plotly_mixed_subplots.html")
    print("\n💡 Open these in your browser to explore interactive features!")


if __name__ == "__main__":
    run_all_plotly_examples()
```

---

#### The Verification

**Verification 1: Run the Plotly Analysis**

```bash
# Run the main analysis
python src/plotly_toolkit.py

# Run advanced examples
python src/advanced_plotly_examples.py
```

**Verification 2: Check Generated Files**

```bash
# List all generated HTML files
ls -la outputs/figures/plotly_*.html
```

You should see multiple HTML files including:
- `plotly_scatter_*.html`
- `plotly_histogram_*.html`
- `plotly_box_*.html`
- `plotly_heatmap_*.html`
- `plotly_3d_scatter.html`
- `plotly_slider_demo.html`
- `plotly_animated_chart.html`
- `plotly_dropdown_filter.html`
- `plotly_custom_annotations.html`
- `plotly_mixed_subplots.html`

**Verification 3: View Interactive Charts**

Open the HTML files in your browser and verify:

```bash
# Open interactive dashboard
open outputs/figures/plotly_dashboard_interactive.html

# Open 3D scatter
open outputs/figures/plotly_3d_scatter.html
```

Test the following interactive features:
1. **Hover** over data points to see tooltips
2. **Zoom** by clicking and dragging
3. **Pan** by shift-dragging
4. **Click** legend items to toggle traces
5. **Use sliders and dropdowns** to filter data
6. **Play animations** to see data evolve

**Verification 4: Quick Validation Script**

**File:** `src/validate_plotly_charts.py`
```python
"""
Validate Plotly chart properties.
"""

import json
from pathlib import Path

def validate_plotly_charts():
    """Validate that Plotly HTML files contain valid interactive charts."""
    
    print("=" * 60)
    print("VALIDATING PLOTLY CHARTS")
    print("=" * 60)
    
    html_dir = Path("outputs/figures")
    html_files = list(html_dir.glob("plotly_*.html"))
    
    print(f"\n📁 Found {len(html_files)} Plotly HTML files")
    
    for html_path in html_files[:5]:  # Check first 5
        size = html_path.stat().st_size / 1024
        print(f"  • {html_path.name}: {size:.1f} KB")
        
        # Check if file contains interactive elements
        with open(html_path, 'r') as f:
            content = f.read()
            if 'Plotly' in content and 'figure' in content:
                print(f"    ✅ Contains interactive elements")
            else:
                print(f"    ⚠️ May not be interactive")
    
    # Check for JSON specifications
    json_files = list(html_dir.glob("plotly_*.json"))
    if json_files:
        print(f"\n📁 Found {len(json_files)} JSON specifications")
        for json_path in json_files[:3]:
            print(f"  • {json_path.name}")
    
    print("\n" + "=" * 60)
    print("VALIDATION COMPLETE")
    print("=" * 60)
    print("\n💡 To view charts:")
    print("   Open any .html file in your browser")

if __name__ == "__main__":
    validate_plotly_charts()
```

Run it:
```bash
python src/validate_plotly_charts.py
```

---

#### What We've Accomplished

In this part, we've:

1. ✅ Built a comprehensive `PlotlyVisualizer` class with:
   - Plotly Express for quick, interactive charts
   - Graph Objects for fine-grained control
   - 3D visualizations (scatter, surface)
   - Dynamic controls (sliders, dropdowns)
   - Animated charts

2. ✅ Created interactive visualizations:
   - Scatter plots with hover, zoom, selection
   - Histograms with marginal plots
   - Box and violin plots
   - Heatmaps with hover details
   - 3D scatter plots for multivariate analysis

3. ✅ Demonstrated advanced Plotly features:
   - Animation frames for temporal exploration
   - Dropdown filters for categorical selection
   - Custom annotations and shapes
   - Mixed subplots with different chart types
   - Interactive controls for data filtering

4. ✅ Learned the interactive exploration workflow:
   - Build charts with Plotly Express
   - Customize with Graph Objects
   - Add interactivity with controls
   - Export to HTML for sharing

---

#### Deep Dive Reference: Interactive Visualization Best Practices

**When to Use Interactive Visualizations**

| Use Case | Static (Matplotlib/Seaborn) | Interactive (Plotly) |
|----------|----------------------------|---------------------|
| **Publication** | ✅ Best | ❌ Not supported |
| **Exploration** | ❌ Limited | ✅ Excellent |
| **Presentation** | ✅ Good | ✅ Better |
| **Dashboard** | ❌ No | ✅ Perfect |
| **Data Cleaning** | ❌ Poor | ✅ Excellent |
| **Stakeholder Review** | ✅ Good | ✅ Better |

**Interactive Features Guide**

| Feature | Best For | Implementation |
|---------|----------|----------------|
| **Hover** | Showing values, IDs | `hovertemplate` |
| **Zoom** | Examining details | Built-in |
| **Selection** | Isolating subsets | `dragmode='select'` |
| **Legend** | Toggling traces | `legend` |
| **Sliders** | Sequential data | `sliders` |
| **Dropdowns** | Category selection | `updatemenus` |
| **Animation** | Temporal changes | `frames` |

**Performance Considerations**

1. **Data Size:** Plotly handles up to ~10,000 points interactively
2. **For larger datasets:** Use aggregation or sampling
3. **WebGL:** Use `scattergl` for large scatter plots
4. **Optimization:** Reduce unnecessary hover data

**Common Interactive Patterns**

1. **Linked Brushing:** Selecting in one chart filters another
2. **Drill-down:** Clicking reveals more details
3. **Dynamic Filtering:** Dropdowns and sliders update data
4. **Animation:** Temporal evolution of data
5. **Tooltips:** Contextual information on hover

---

#### Next Up

In **Part 2: Dash - Interactive Web Dashboards**, we'll build on our Plotly skills to create complete web applications with Dash. You'll learn how to:

- Structure a Dash application with layouts and callbacks
- Create interactive dashboards with cross-filtering
- Implement drill-down capabilities
- Deploy interactive web applications for stakeholder review
