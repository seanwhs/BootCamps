# Phase 2: Exploratory Data Analysis & Visualization

## Module 2.2: Static & Declarative Visualizations

### Part 3: Altair - Declarative Visualization with Vega-Lite

---

#### The Target

In this part, we'll master Altair's declarative visualization paradigm using the Vega-Lite grammar. By the end, you'll have:

1. A deep understanding of the Grammar of Graphics and declarative visualization
2. The ability to build complex visualizations by mapping data to visual channels
3. Interactive visualizations with selections, filters, and tooltips
4. A reusable toolkit for creating Altair charts with consistent styling
5. Integration of Altair with Jupyter notebooks and web deployment

---

#### The Concept

**Declarative vs. Imperative Visualization**

Think of the difference between giving a chef a recipe versus describing the finished dish you want.

- **Imperative (Matplotlib/Seaborn):** You give step-by-step instructions: "Create a figure, add an axes object, plot these points, color them red, add a title..."
- **Declarative (Altair):** You describe what you want: "I want a scatter plot with order_frequency on x, avg_order_value on y, colored by income_bracket, with a title."

Altair handles all the implementation details. This makes it:
1. **More concise:** Less code to write
2. **More expressive:** Focus on what matters (the data-viz relationship)
3. **More interactive:** Built-in interactivity with selections
4. **More reproducible:** The specification is data-independent

**The Grammar of Graphics**

Altair is based on the Grammar of Graphics, which formalizes the components of a visualization:

1. **Data:** What are we visualizing?
2. **Marks:** What geometric shapes? (points, bars, lines, areas)
3. **Encodings:** How are data fields mapped to visual properties? (x, y, color, size, shape)
4. **Scales:** How are data values mapped to visual values? (linear, log, ordinal)
5. **Guides:** What labels, legends, and titles help interpret the chart?
6. **Faceting:** How are charts split into multiple views?

**The Vega-Lite Specification**

Altair generates Vega-Lite JSON specifications that describe the visualization. This JSON is then rendered by Vega-Embed, which can run in any modern browser.

---

#### The Implementation

##### Step 1: Create the Altair Toolkit Module

**File:** `src/altair_toolkit.py`
```python
"""
Altair Declarative Visualization Toolkit

A comprehensive module for creating declarative visualizations
using Altair and Vega-Lite.

This module provides:
- Grammar of Graphics-based chart construction
- Interactive visualizations with selections
- Consistent styling and theming
- Integration with Jupyter notebooks
- Export to HTML and JSON
"""

import altair as alt
import pandas as pd
import numpy as np
from pathlib import Path
import json
import warnings
warnings.filterwarnings('ignore')

# Set Altair renderer for Jupyter
alt.renderers.enable('notebook')
alt.data_transformers.disable_max_rows()


class AltairVisualizer:
    """
    A class for creating declarative visualizations with Altair.
    
    This class provides methods for common chart types using
    the Grammar of Graphics with consistent styling.
    
    Attributes:
        df (pd.DataFrame): The dataset
        output_dir (Path): Directory for saving charts
        theme (dict): Default theme settings
    """
    
    def __init__(self, df: pd.DataFrame, output_dir: str = "outputs/figures"):
        """
        Initialize the visualizer.
        
        Parameters:
        -----------
        df : pd.DataFrame
            The dataset to visualize
        output_dir : str
            Directory for saving figures
        """
        self.df = df.copy()
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Define default theme
        self.theme = {
            'background': 'white',
            'font': 'sans-serif',
            'axis': {
                'titleFontSize': 14,
                'labelFontSize': 12,
                'gridColor': '#e0e0e0',
                'gridOpacity': 0.6
            },
            'legend': {
                'titleFontSize': 12,
                'labelFontSize': 11
            }
        }
        
        # Set Altair theme
        alt.themes.enable('default')
        
        # Detect column types
        self.numerical_cols = self.df.select_dtypes(include=[np.number]).columns.tolist()
        self.categorical_cols = self.df.select_dtypes(include=['object', 'category']).columns.tolist()
        
        # Remove ID columns
        self.numerical_cols = [c for c in self.numerical_cols if c not in ['customer_id']]
        
        print(f"📊 Visualizing {len(self.numerical_cols)} numerical and {len(self.categorical_cols)} categorical columns")
    
    # ---------- CHART CREATION ----------
    
    def create_scatter_plot(self, x_col: str, y_col: str,
                           color_col: str = None,
                           size_col: str = None,
                           shape_col: str = None,
                           title: str = None,
                           interactive: bool = True,
                           save: bool = True) -> alt.Chart:
        """
        Create a scatter plot with optional encodings.
        
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
        shape_col : str
            Column for shape encoding
        title : str
            Chart title
        interactive : bool
            Whether to add interactive tooltips
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        alt.Chart
            The Altair chart object
        """
        # Base chart
        chart = alt.Chart(self.df).mark_circle(
            size=60,
            opacity=0.7,
            stroke='white',
            strokeWidth=0.5
        ).encode(
            x=alt.X(x_col, title=x_col),
            y=alt.Y(y_col, title=y_col)
        )
        
        # Add color encoding
        if color_col:
            if color_col in self.categorical_cols:
                chart = chart.encode(
                    color=alt.Color(color_col, 
                                   title=color_col,
                                   scale=alt.Scale(scheme='category10'))
                )
            else:
                chart = chart.encode(
                    color=alt.Color(color_col, 
                                   title=color_col,
                                   scale=alt.Scale(scheme='viridis'))
                )
        
        # Add size encoding
        if size_col:
            chart = chart.encode(
                size=alt.Size(size_col, title=size_col)
            )
        
        # Add shape encoding (for categorical only)
        if shape_col and shape_col in self.categorical_cols:
            chart = chart.encode(
                shape=alt.Shape(shape_col, 
                               title=shape_col,
                               scale=alt.Scale(scheme='category10'))
            )
        
        # Add interactive tooltips
        if interactive:
            tooltip_cols = [x_col, y_col]
            if color_col:
                tooltip_cols.append(color_col)
            if size_col:
                tooltip_cols.append(size_col)
            if shape_col:
                tooltip_cols.append(shape_col)
            
            chart = chart.encode(
                tooltip=[alt.Tooltip(col, title=col) for col in tooltip_cols]
            )
        
        # Add title and styling
        if title is None:
            title = f'Scatter Plot: {y_col} vs {x_col}'
        
        chart = chart.properties(
            title=title,
            width=600,
            height=400
        ).interactive()
        
        if save:
            self.save_chart(chart, f'altair_scatter_{x_col}_vs_{y_col}')
        
        return chart
    
    def create_bar_chart(self, x_col: str, y_col: str = None,
                        color_col: str = None,
                        horizontal: bool = False,
                        stacked: bool = False,
                        title: str = None,
                        save: bool = True) -> alt.Chart:
        """
        Create a bar chart with optional grouping.
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis (categorical)
        y_col : str
            Column for y-axis (numerical or 'count')
        color_col : str
            Column for color grouping
        horizontal : bool
            Whether to create horizontal bars
        stacked : bool
            Whether to stack bars (if color_col is used)
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        alt.Chart
            The Altair chart object
        """
        # Determine if we're counting or aggregating
        if y_col is None:
            # Count of x_col
            chart = alt.Chart(self.df).mark_bar(
                opacity=0.8,
                stroke='white',
                strokeWidth=0.5
            ).encode(
                x=alt.X(x_col, title=x_col, type='nominal'),
                y=alt.Y('count()', title='Count')
            )
        else:
            # Aggregate y_col by x_col
            chart = alt.Chart(self.df).mark_bar(
                opacity=0.8,
                stroke='white',
                strokeWidth=0.5
            ).encode(
                x=alt.X(x_col, title=x_col, type='nominal'),
                y=alt.Y(f'mean({y_col})', title=f'Mean {y_col}')
            )
        
        # Add color encoding
        if color_col:
            chart = chart.encode(
                color=alt.Color(color_col, 
                               title=color_col,
                               scale=alt.Scale(scheme='category10'))
            )
            
            if stacked:
                # Stack bars
                chart = chart.encode(
                    color=alt.Color(color_col, title=color_col),
                    y=alt.Y(f'mean({y_col})' if y_col else 'count()',
                            title=f'Mean {y_col}' if y_col else 'Count',
                            stack='normalize' if stacked else None)
                )
        
        # Make horizontal if requested
        if horizontal:
            chart = chart.encode(
                x=alt.X(f'mean({y_col})' if y_col else 'count()',
                        title=f'Mean {y_col}' if y_col else 'Count'),
                y=alt.Y(x_col, title=x_col, type='nominal')
            )
        
        # Add title
        if title is None:
            if y_col is None:
                title = f'Count of {x_col}'
            else:
                title = f'Mean {y_col} by {x_col}'
        
        chart = chart.properties(
            title=title,
            width=600,
            height=400
        ).interactive()
        
        if save:
            suffix = f'{x_col}_vs_{y_col}' if y_col else f'{x_col}_count'
            self.save_chart(chart, f'altair_bar_{suffix}')
        
        return chart
    
    def create_histogram(self, col: str, bins: int = 30,
                        color_col: str = None,
                        title: str = None,
                        save: bool = True) -> alt.Chart:
        """
        Create a histogram with KDE overlay.
        
        Parameters:
        -----------
        col : str
            Column to visualize
        bins : int
            Number of bins
        color_col : str
            Column for color grouping
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        alt.Chart
            The Altair chart object
        """
        # Create histogram
        chart = alt.Chart(self.df).mark_bar(
            opacity=0.7,
            stroke='white',
            strokeWidth=0.5
        ).encode(
            x=alt.X(col, title=col, bin=alt.Bin(maxbins=bins)),
            y=alt.Y('count()', title='Count')
        )
        
        # Add color encoding
        if color_col:
            chart = chart.encode(
                color=alt.Color(color_col, 
                               title=color_col,
                               scale=alt.Scale(scheme='category10'))
            )
        
        # Add KDE overlay (using a separate layer)
        # Convert to density
        kde_data = self.df[col].dropna()
        if len(kde_data) > 1 and not color_col:
            # Create density plot
            density = alt.Chart(self.df).transform_density(
                col,
                as_=[col, 'density'],
                extent=[kde_data.min(), kde_data.max()],
                groupby=[]
            ).mark_line(
                color='red',
                strokeWidth=2
            ).encode(
                x=alt.X(col, title=col),
                y=alt.Y('density:Q', title='Density')
            )
            
            # Combine histogram and density
            chart = alt.layer(chart, density).resolve_scale(
                y='independent'
            )
        
        # Add title
        if title is None:
            title = f'Distribution of {col}'
        
        chart = chart.properties(
            title=title,
            width=600,
            height=400
        ).interactive()
        
        if save:
            self.save_chart(chart, f'altair_histogram_{col}')
        
        return chart
    
    def create_box_plot(self, numerical_col: str, categorical_col: str,
                       title: str = None,
                       save: bool = True) -> alt.Chart:
        """
        Create a box plot for numerical vs categorical.
        
        Parameters:
        -----------
        numerical_col : str
            Numerical column
        categorical_col : str
            Categorical column for grouping
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        alt.Chart
            The Altair chart object
        """
        chart = alt.Chart(self.df).mark_boxplot(
            extent='min-max',
            ticks=True,
            opacity=0.8
        ).encode(
            x=alt.X(categorical_col, title=categorical_col, type='nominal'),
            y=alt.Y(numerical_col, title=numerical_col),
            color=alt.Color(categorical_col, 
                           title=categorical_col,
                           scale=alt.Scale(scheme='category10'))
        )
        
        # Add title
        if title is None:
            title = f'Distribution of {numerical_col} by {categorical_col}'
        
        chart = chart.properties(
            title=title,
            width=600,
            height=400
        ).interactive()
        
        if save:
            self.save_chart(chart, f'altair_box_{numerical_col}_by_{categorical_col}')
        
        return chart
    
    def create_violin_plot(self, numerical_col: str, categorical_col: str,
                          title: str = None,
                          save: bool = True) -> alt.Chart:
        """
        Create a violin plot for numerical vs categorical.
        
        Note: Altair doesn't have native violin plots, so we use
        density and area marks.
        
        Parameters:
        -----------
        numerical_col : str
            Numerical column
        categorical_col : str
            Categorical column for grouping
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        alt.Chart
            The Altair chart object
        """
        # Use transform_density to create violin-like plots
        chart = alt.Chart(self.df).transform_density(
            numerical_col,
            as_=[numerical_col, 'density'],
            groupby=[categorical_col]
        ).mark_area(
            orient='horizontal',
            opacity=0.7,
            stroke='black',
            strokeWidth=0.5
        ).encode(
            x=alt.X('density:Q', title='Density'),
            y=alt.Y(numerical_col, title=numerical_col),
            color=alt.Color(categorical_col, 
                           title=categorical_col,
                           scale=alt.Scale(scheme='category10'))
        )
        
        # Add title
        if title is None:
            title = f'Distribution of {numerical_col} by {categorical_col} (Violin)'
        
        chart = chart.properties(
            title=title,
            width=600,
            height=400
        ).interactive()
        
        if save:
            self.save_chart(chart, f'altair_violin_{numerical_col}_by_{categorical_col}')
        
        return chart
    
    def create_heatmap(self, x_col: str, y_col: str,
                      value_col: str = None,
                      agg_func: str = 'mean',
                      title: str = None,
                      save: bool = True) -> alt.Chart:
        """
        Create a heatmap for two categorical or binned columns.
        
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
        alt.Chart
            The Altair chart object
        """
        if value_col is None:
            # Count of combinations
            chart = alt.Chart(self.df).mark_rect().encode(
                x=alt.X(x_col, title=x_col, type='nominal'),
                y=alt.Y(y_col, title=y_col, type='nominal'),
                color=alt.Color('count()', 
                               title='Count',
                               scale=alt.Scale(scheme='viridis'))
            )
        else:
            # Aggregate value_col by x_col and y_col
            chart = alt.Chart(self.df).mark_rect().encode(
                x=alt.X(x_col, title=x_col, type='nominal'),
                y=alt.Y(y_col, title=y_col, type='nominal'),
                color=alt.Color(f'{agg_func}({value_col})', 
                               title=f'{agg_func} {value_col}',
                               scale=alt.Scale(scheme='viridis'))
            )
        
        # Add text labels
        text = chart.mark_text(
            font='sans-serif',
            fontSize=10
        ).encode(
            text=alt.Text('count()' if value_col is None else f'{agg_func}({value_col})')
        )
        
        chart = (chart + text).properties(
            title=title or f'Heatmap: {x_col} vs {y_col}',
            width=600,
            height=400
        ).interactive()
        
        if save:
            self.save_chart(chart, f'altair_heatmap_{x_col}_vs_{y_col}')
        
        return chart
    
    # ---------- INTERACTIVE CHARTS ----------
    
    def create_interactive_dashboard(self, x_col: str, y_col: str,
                                    color_col: str = None,
                                    filter_col: str = None,
                                    title: str = None,
                                    save: bool = True) -> alt.Chart:
        """
        Create an interactive dashboard with linked selection.
        
        This demonstrates Altair's interactive capabilities:
        - Selection by clicking/lasso
        - Cross-filtering
        - Dynamic updates
        
        Parameters:
        -----------
        x_col : str
            Column for x-axis
        y_col : str
            Column for y-axis
        color_col : str
            Column for color encoding
        filter_col : str
            Column for filtering (creates a selection widget)
        title : str
            Chart title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        alt.Chart
            The Altair chart object
        """
        # Create a selection
        selection = alt.selection_interval(
            bind='scales',
            name='brush'
        )
        
        # Base chart
        base = alt.Chart(self.df).mark_circle(
            size=60,
            opacity=0.7
        ).encode(
            x=alt.X(x_col, title=x_col),
            y=alt.Y(y_col, title=y_col)
        ).add_selection(
            selection
        )
        
        # Add color encoding
        if color_col:
            base = base.encode(
                color=alt.Color(color_col, 
                               title=color_col,
                               scale=alt.Scale(scheme='viridis'))
            )
        
        # Add filter widget
        if filter_col and filter_col in self.categorical_cols:
            # Create dropdown filter
            filter_widget = alt.binding_select(
                options=['All'] + list(self.df[filter_col].unique()),
                name=f'Filter by {filter_col}: '
            )
            filter_selection = alt.selection_single(
                fields=[filter_col],
                bind=filter_widget,
                name='filter_select',
                init={'filter_select': 'All'}
            )
            
            # Apply filter
            base = base.add_selection(filter_selection)
            
            # Transform data based on filter
            base = base.transform_filter(
                (alt.datum[filter_col] == filter_selection[filter_col]) | 
                (filter_selection[filter_col] == 'All')
            )
        
        # Add histogram in a separate chart (linked)
        hist = alt.Chart(self.df).mark_bar(
            opacity=0.7
        ).add_selection(
            selection
        ).encode(
            x=alt.X(x_col, bin=alt.Bin(maxbins=30), title=x_col),
            y=alt.Y('count()', title='Count'),
            color=alt.condition(
                selection,
                alt.ColorValue('steelblue'),
                alt.ColorValue('lightgray')
            )
        ).properties(
            width=600,
            height=150
        )
        
        # Combine charts
        dashboard = alt.vconcat(
            base.properties(
                title=title or f'Interactive Dashboard: {y_col} vs {x_col}',
                width=600,
                height=400
            ),
            hist
        )
        
        if save:
            self.save_chart(dashboard, f'altair_dashboard_{x_col}_vs_{y_col}')
        
        return dashboard
    
    def create_multi_panel_figure(self, charts: list, 
                                 layout: str = 'vconcat',
                                 title: str = None,
                                 save: bool = True) -> alt.Chart:
        """
        Create a multi-panel figure from multiple charts.
        
        Parameters:
        -----------
        charts : list
            List of Altair charts
        layout : str
            'vconcat' for vertical, 'hconcat' for horizontal
        title : str
            Overall title
        save : bool
            Whether to save the chart
            
        Returns:
        --------
        alt.Chart
            The combined Altair chart
        """
        if layout == 'vconcat':
            combined = alt.vconcat(*charts)
        else:
            combined = alt.hconcat(*charts)
        
        if title:
            combined = combined.properties(title=title)
        
        if save:
            self.save_chart(combined, f'altair_multi_panel_{layout}')
        
        return combined
    
    # ---------- SAVING AND EXPORTING ----------
    
    def save_chart(self, chart: alt.Chart, name: str, 
                   formats: list = ['html', 'json', 'png']) -> None:
        """
        Save chart in multiple formats.
        
        Parameters:
        -----------
        chart : alt.Chart
            The Altair chart to save
        name : str
            Base name for files
        formats : list
            Formats to save ('html', 'json', 'png')
        """
        for fmt in formats:
            try:
                if fmt == 'html':
                    filepath = self.output_dir / f'{name}.html'
                    chart.save(str(filepath))
                    print(f"  ✅ Saved: {filepath}")
                
                elif fmt == 'json':
                    filepath = self.output_dir / f'{name}.json'
                    with open(filepath, 'w') as f:
                        json.dump(chart.to_dict(), f, indent=2)
                    print(f"  ✅ Saved: {filepath}")
                
                elif fmt == 'png':
                    filepath = self.output_dir / f'{name}.png'
                    chart.save(str(filepath))
                    print(f"  ✅ Saved: {filepath}")
            
            except Exception as e:
                print(f"  ⚠️ Could not save {fmt} for {name}: {e}")
    
    # ---------- COMPREHENSIVE ANALYSIS ----------
    
    def analyze_all(self, save_formats: list = ['html', 'json']) -> dict:
        """
        Run a comprehensive set of Altair visualizations.
        
        Parameters:
        -----------
        save_formats : list
            Formats to save charts ('html', 'json', 'png')
            
        Returns:
        --------
        dict
            Dictionary of generated charts
        """
        results = {'charts': []}
        
        print("\n" + "=" * 60)
        print("ALTAIR DECLARATIVE VISUALIZATIONS - STARTING")
        print("=" * 60)
        
        # 1. Scatter plots
        print("\n📊 Creating scatter plots...")
        if len(self.numerical_cols) >= 2:
            # Create scatter plot for first two numerical columns
            x_col = self.numerical_cols[0]
            y_col = self.numerical_cols[1]
            try:
                chart = self.create_scatter_plot(
                    x_col, y_col,
                    color_col='income_bracket' if 'income_bracket' in self.categorical_cols else None,
                    save=False
                )
                results['charts'].append(('scatter', f'{x_col}_vs_{y_col}', chart))
                self.save_chart(chart, f'altair_scatter_{x_col}_vs_{y_col}', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating scatter plot: {e}")
        
        # 2. Histograms
        print("\n📊 Creating histograms...")
        for col in self.numerical_cols[:3]:  # Limit to 3 for speed
            try:
                chart = self.create_histogram(col, save=False)
                results['charts'].append(('histogram', col, chart))
                self.save_chart(chart, f'altair_histogram_{col}', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating histogram for {col}: {e}")
        
        # 3. Bar charts
        print("\n📊 Creating bar charts...")
        if self.categorical_cols:
            cat_col = self.categorical_cols[0]
            try:
                chart = self.create_bar_chart(cat_col, save=False)
                results['charts'].append(('bar', cat_col, chart))
                self.save_chart(chart, f'altair_bar_{cat_col}_count', save_formats)
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
                self.save_chart(chart, f'altair_box_{num_col}_by_{cat_col}', save_formats)
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
                self.save_chart(chart, f'altair_heatmap_categorical', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating heatmap: {e}")
        
        # 6. Interactive dashboard
        print("\n📊 Creating interactive dashboard...")
        if len(self.numerical_cols) >= 2 and self.categorical_cols:
            try:
                chart = self.create_interactive_dashboard(
                    self.numerical_cols[0],
                    self.numerical_cols[1],
                    color_col='income_bracket' if 'income_bracket' in self.categorical_cols else None,
                    filter_col=self.categorical_cols[0],
                    save=False
                )
                results['charts'].append(('dashboard', 'interactive', chart))
                self.save_chart(chart, f'altair_dashboard_interactive', save_formats)
            except Exception as e:
                print(f"  ⚠️ Error creating dashboard: {e}")
        
        print("\n" + "=" * 60)
        print("ALTAIR VISUALIZATIONS - COMPLETE")
        print("=" * 60)
        print(f"\n✅ Generated {len(results['charts'])} visualizations")
        
        return results


# ---------- UTILITY FUNCTIONS ----------

def run_altair_analysis(data_path: str = "data/customer_data.csv",
                       output_dir: str = "outputs/figures") -> dict:
    """
    Convenience function to run Altair analysis.
    
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
    visualizer = AltairVisualizer(df, output_dir=output_dir)
    
    # Run analysis
    results = visualizer.analyze_all(save_formats=['html', 'json'])
    
    return results


if __name__ == "__main__":
    results = run_altair_analysis()
```

---

##### Step 2: Create Advanced Altair Examples

**File:** `src/advanced_altair_examples.py`
```python
"""
Advanced Altair Visualization Examples

Demonstrates advanced Altair techniques including:
- Custom transformations
- Layered charts
- Faceted charts
- Interactive selections
- Custom styling
"""

import altair as alt
import pandas as pd
import numpy as np
from pathlib import Path
from altair_toolkit import AltairVisualizer


def demonstrate_layered_charts(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate layered charts in Altair.
    
    Shows how to combine multiple marks in one chart.
    """
    
    print("\n📊 Creating layered charts...")
    
    df = pd.read_csv(data_path)
    
    # Create base chart
    base = alt.Chart(df).encode(
        x=alt.X('order_frequency', bin=alt.Bin(maxbins=30), title='Order Frequency'),
        y=alt.Y('count()', title='Count')
    )
    
    # Histogram layer
    histogram = base.mark_bar(
        opacity=0.7,
        color='steelblue',
        stroke='white',
        strokeWidth=0.5
    )
    
    # KDE layer (using transform_density)
    density = alt.Chart(df).transform_density(
        'order_frequency',
        as_=['order_frequency', 'density'],
        extent=[df['order_frequency'].min(), df['order_frequency'].max()]
    ).mark_line(
        color='red',
        strokeWidth=3
    ).encode(
        x=alt.X('order_frequency:Q', title='Order Frequency'),
        y=alt.Y('density:Q', title='Density', scale=alt.Scale(domain=(0, 1.5)))
    )
    
    # Combine layers with independent y-scales
    layered = alt.layer(
        histogram,
        density
    ).resolve_scale(
        y='independent'
    ).properties(
        title='Order Frequency Distribution with KDE',
        width=600,
        height=400
    )
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    layered.save(str(output_dir / 'altair_layered_histogram.html'))
    print(f"  ✅ Saved: {output_dir / 'altair_layered_histogram.html'}")
    
    return layered


def demonstrate_faceted_charts(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate faceted charts in Altair.
    
    Shows how to create small multiples (Treelifts).
    """
    
    print("\n📊 Creating faceted charts...")
    
    df = pd.read_csv(data_path)
    
    # Create base chart
    base = alt.Chart(df).encode(
        x=alt.X('order_frequency:Q', title='Order Frequency'),
        y=alt.Y('count()', title='Count')
    ).transform_filter(
        alt.datum.income_bracket != 'NULL'
    )
    
    # Facet by income bracket
    chart = base.mark_bar(
        opacity=0.7,
        color='steelblue',
        stroke='white',
        strokeWidth=0.5
    ).facet(
        facet=alt.Facet('income_bracket:N', title='Income Bracket'),
        columns=3
    ).properties(
        title='Order Frequency Distribution by Income Bracket',
        width=200,
        height=200
    )
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    chart.save(str(output_dir / 'altair_faceted_histogram.html'))
    print(f"  ✅ Saved: {output_dir / 'altair_faceted_histogram.html'}")
    
    return chart


def demonstrate_interactive_selections(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate interactive selections in Altair.
    
    Shows:
    - Brush selection
    - Click selection
    - Multi-view linking
    - Legend selection
    """
    
    print("\n📊 Creating interactive selection examples...")
    
    df = pd.read_csv(data_path)
    
    # Create selection
    selection = alt.selection_interval()
    
    # Main scatter plot
    scatter = alt.Chart(df).mark_circle(
        size=60,
        opacity=0.7
    ).add_selection(
        selection
    ).encode(
        x=alt.X('avg_order_value:Q', title='Avg Order Value ($)'),
        y=alt.Y('order_frequency:Q', title='Order Frequency'),
        color=alt.condition(
            selection,
            alt.Color('income_bracket:N', 
                     title='Income',
                     scale=alt.Scale(scheme='category10')),
            alt.ColorValue('lightgray')
        ),
        tooltip=['customer_rating', 'income_bracket', 'avg_order_value']
    ).properties(
        title='Select points to filter other views',
        width=500,
        height=400
    )
    
    # Histogram that updates based on selection
    hist = alt.Chart(df).mark_bar(
        opacity=0.7,
        color='steelblue',
        stroke='white',
        strokeWidth=0.5
    ).add_selection(
        selection
    ).encode(
        x=alt.X('age:Q', bin=alt.Bin(maxbins=20), title='Age'),
        y=alt.Y('count()', title='Count'),
        color=alt.condition(
            selection,
            alt.ColorValue('steelblue'),
            alt.ColorValue('lightgray')
        )
    ).properties(
        title='Age Distribution (filtered)',
        width=500,
        height=200
    )
    
    # Combine
    dashboard = alt.vconcat(scatter, hist)
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    dashboard.save(str(output_dir / 'altair_interactive_selections.html'))
    print(f"  ✅ Saved: {output_dir / 'altair_interactive_selections.html'}")
    
    return dashboard


def demonstrate_custom_visualizations(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate custom Altair visualizations.
    
    Shows:
    - Custom color scales
    - Custom transforms    - Custom tooltips
    - Custom axis formatting
    """
    
    print("\n📊 Creating custom visualizations...")
    
    df = pd.read_csv(data_path)
    
    # Create a chart with custom styling
    chart = alt.Chart(df).mark_bar(
        cornerRadiusTopLeft=3,
        cornerRadiusTopRight=3
    ).transform_aggregate(
        mean_rating='mean(customer_rating)',
        count='count()',
        groupby=['income_bracket']
    ).encode(
        x=alt.X('income_bracket:N', 
                title='Income Bracket',
                sort=['<$25K', '$25K-$50K', '$50K-$75K', '$75K-$100K', '>$100K']),
        y=alt.Y('mean_rating:Q', 
                title='Mean Customer Rating',
                scale=alt.Scale(domain=[3, 5])),
        color=alt.Color('mean_rating:Q',
                        title='Mean Rating',
                        scale=alt.Scale(scheme='plasma')),
        tooltip=[
            alt.Tooltip('income_bracket:N', title='Income'),
            alt.Tooltip('mean_rating:Q', title='Mean Rating', format='.2f'),
            alt.Tooltip('count:Q', title='Count', format=',.0f')
        ],
        text=alt.Text('mean_rating:Q', format='.2f')
    ).properties(
        title='Customer Rating by Income Bracket',
        width=600,
        height=400
    )
    
    # Add text labels on bars
    text = chart.mark_text(
        align='center',
        baseline='bottom',
        dy=-5,
        color='black',
        fontSize=12,
        fontWeight='bold'
    ).encode(
        text=alt.Text('mean_rating:Q', format='.2f')
    )
    
    combined = chart + text
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    combined.save(str(output_dir / 'altair_custom_barchart.html'))
    print(f"  ✅ Saved: {output_dir / 'altair_custom_barchart.html'}")
    
    return combined


def run_all_altair_examples(data_path: str = "data/customer_data.csv"):
    """
    Run all Altair demonstrations.
    """
    
    print("=" * 60)
    print("ALTAIR ADVANCED EXAMPLES")
    print("=" * 60)
    
    # Run basic analysis
    print("\n🔍 Running basic Altair analysis...")
    run_altair_analysis(data_path)
    
    # Run advanced examples
    demonstrate_layered_charts(data_path)
    demonstrate_faceted_charts(data_path)
    demonstrate_interactive_selections(data_path)
    demonstrate_custom_visualizations(data_path)
    
    print("\n" + "=" * 60)
    print("ALL ALTAIR EXAMPLES COMPLETE")
    print("=" * 60)
    print("\n📁 HTML files saved to: outputs/figures/")
    print("  • altair_*.html (multiple files)")
    print("  • altair_layered_histogram.html")
    print("  • altair_faceted_histogram.html")
    print("  • altair_interactive_selections.html")
    print("  • altair_custom_barchart.html")
    print("\n💡 Open these in your browser to view interactive charts!")


if __name__ == "__main__":
    run_all_altair_examples()
```

---

#### The Verification

**Verification 1: Run the Altair Analysis**

```bash
# Run the main analysis
python src/altair_toolkit.py

# Run advanced examples
python src/advanced_altair_examples.py
```

**Verification 2: Check Generated Files**

```bash
# List all generated HTML files
ls -la outputs/figures/*.html

# List JSON specifications
ls -la outputs/figures/*.json
```

**Verification 3: View Interactive Charts**

Open one of the HTML files in your browser:
```bash
# On macOS:
open outputs/figures/altair_dashboard_interactive.html

# On Linux:
xdg-open outputs/figures/altair_dashboard_interactive.html

# On Windows:
start outputs/figures/altair_dashboard_interactive.html
```

Interact with the chart to verify:
- Tooltips appear on hover
- Selections highlight points
- Cross-filtering works between charts
- Legends filter data

**Verification 4: Validate Altair Specifications**

**File:** `src/validate_altair_charts.py`
```python
"""
Validate Altair chart specifications.
"""

import json
from pathlib import Path

def validate_altair_charts():
    """Validate that Altair JSON specifications are valid."""
    
    print("=" * 60)
    print("VALIDATING ALTAIR CHARTS")
    print("=" * 60)
    
    json_dir = Path("outputs/figures")
    json_files = list(json_dir.glob("*.json"))
    
    print(f"\n📁 Found {len(json_files)} JSON specifications")
    
    valid_count = 0
    for json_path in json_files:
        try:
            with open(json_path, 'r') as f:
                spec = json.load(f)
            
            # Check for required Vega-Lite properties
            required_fields = ['$schema', 'data', 'mark', 'encoding']
            missing = [field for field in required_fields if field not in spec]
            
            if missing:
                print(f"  ❌ {json_path.name}: Missing fields {missing}")
            else:
                print(f"  ✅ {json_path.name}: Valid Vega-Lite specification")
                valid_count += 1
                
        except json.JSONDecodeError as e:
            print(f"  ❌ {json_path.name}: Invalid JSON - {e}")
        except Exception as e:
            print(f"  ❌ {json_path.name}: Error - {e}")
    
    print(f"\n✅ {valid_count}/{len(json_files)} valid specifications")
    print("=" * 60)

if __name__ == "__main__":
    validate_altair_charts()
```

Run it:
```bash
python src/validate_altair_charts.py
```

---

#### What We've Accomplished

In this part, we've:

1. ✅ Mastered Altair's declarative approach:
   - Grammar of Graphics principles
   - Data → Mark → Encoding pipeline
   - Interactive selections and filters
   - Multi-panel compositions

2. ✅ Built a comprehensive `AltairVisualizer` class:
   - Scatter plots with color, size, and shape encodings
   - Bar charts with grouping and stacking
   - Histograms with KDE overlays
   - Box and violin plots
   - Heatmaps with text annotations
   - Interactive dashboards

3. ✅ Demonstrated advanced Altair techniques:
   - Layered charts (combining multiple marks)
   - Faceted charts (Treelifts/small multiples)
   - Interactive selections (brush, click, legend)
   - Custom styling and transformations

4. ✅ Learned the declarative visualization workflow:
   - Define what you want → Altair builds it
   - Export to HTML for sharing
   - Export to JSON for reproducibility

---

#### Deep Dive Reference: The Grammar of Graphics

**The Six Components of a Visualization**

1. **Data:** The source data (DataFrame)
2. **Marks:** The geometric shapes
   - `mark_point()` - Scatter plots
   - `mark_bar()` - Bar charts
   - `mark_line()` - Line charts
   - `mark_area()` - Area charts
   - `mark_rect()` - Heatmaps
3. **Encodings:** Mappings from data to visual properties
   - Position (x, y, x2, y2)
   - Color (color)
   - Size (size)
   - Shape (shape)
   - Opacity (opacity)
4. **Scales:** Mappings from data values to visual values
   - `Scale(scheme='viridis')`
   - `Scale(type='log')`
   - `Scale(domain=[0, 100])`
5. **Guides:** Legends, axis labels, titles
   - `title=...`
   - `axis=alt.Axis(...)`
   - `legend=alt.Legend(...)`
6. **Facets:** Splitting into multiple charts
   - `facet=...`
   - `row=...`, `column=...`

**Common Transformations**

Altair's power comes from its built-in transformations:

```python
# Aggregation
transform_aggregate(mean_rating='mean(rating)', groupby=['category'])

# Binning
transform_bin('age_binned', field='age', bin=alt.Bin(maxbins=10))

# Filtering
transform_filter(alt.datum.income > 50000)

# Sorting
sort=[...]  # Custom order

# Calculation
transform_calculate('age_squared', 'datum.age * datum.age')

# Density estimation
transform_density('age', as_=['age', 'density'])

# Window functions
transform_window(rank='rank()', sort=[...])
```

**Choosing Between Altair and Other Libraries**

| Aspect | Altair | Matplotlib | Seaborn |
|--------|--------|------------|---------|
| **Paradigm** | Declarative | Imperative | Hybrid |
| **Code Length** | Short | Long | Medium |
| **Interactivity** | Built-in | Manual | Limited |
| **Web Integration** | Native | Limited | Limited |
| **Learning Curve** | Moderate | Steep | Moderate |
| **Flexibility** | Good | Excellent | Good |
| **Statistical Power** | Limited | Manual | Built-in |

**When to use Altair:**
- Web-based dashboards and reports
- Interactive exploratory analysis
- Reproducible analysis pipelines
- Sharing visualizations with non-technical stakeholders

**When to use Matplotlib/Seaborn:**
- Publication-quality static figures
- Highly customized or unusual chart types
- Deep integration with other Python libraries
- Performance-critical applications

---

#### Module 2.2 Summary

Congratulations! You've completed Module 2.2: Static & Declarative Visualizations. You now have mastery over three powerful visualization libraries:

**Matplotlib: Total Control**
- Object-oriented API for fine-grained control
- GridSpec for complex layouts
- Complete customization of every element
- Publication-quality figures

**Seaborn: Statistical Power**
- High-level statistical plots
- Beautiful default styling
- Multi-plot grids (FacetGrid, PairGrid)
- Integration with pandas and statistical tests

**Altair: Declarative Excellence**
- Grammar of Graphics approach
- Interactive visualizations built-in
- Web-native (HTML/JSON export)
- Reproducible specifications

**What's Next:**

In **Module 2.3: Interactive Data Exploration**, we'll build on everything we've learned to create dynamic, interactive dashboards with Plotly and Dash. You'll learn how to:
- Create responsive scatter plots, distributions, and heatmaps
- Implement dynamic sliders and filters
- Build linked cross-filtering dashboards
- Deploy interactive web applications
