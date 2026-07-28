# Phase 2: Exploratory Data Analysis & Visualization

## Module 2.2: Static & Declarative Visualizations

### Part 1: Matplotlib - Mastering the Object-Oriented API for Custom Layouts

---

#### The Target

In this part, we'll build a comprehensive toolkit for creating publication-ready figures using Matplotlib's object-oriented API. By the end, you'll have:

1. A deep understanding of Matplotlib's architecture (Figure, Axes, Artists)
2. The ability to create complex multi-panel layouts using GridSpec
3. Fine-tuned control over axes formatting, annotations, and styling
4. A reusable class for generating professional, publication-quality figures
5. Complete knowledge of how to customize every element of a plot

---

#### The Concept

**Understanding Matplotlib's Architecture**

Think of Matplotlib like building a house:

- **Figure** = The entire house (the canvas where everything lives)
- **Axes** = Individual rooms (each subplot is a separate Axes object)
- **Artists** = Everything inside the rooms (lines, text, shapes, legends)
- **GridSpec** = The floor plan (how the rooms are arranged)

The object-oriented (OO) API gives you total control over every element. Unlike the pyplot `plt.plot()` shortcut, the OO approach lets you:
- Create and modify individual elements after they're drawn
- Build complex layouts with nested subplots
- Share axes between subplots
- Fine-tune spacing, alignment, and sizing

**Why the OO API matters:**

```python
# pyplot style (quick but limited)
plt.plot(x, y)
plt.title("My Plot")
plt.show()

# OO style (complete control)
fig, ax = plt.subplots()
ax.plot(x, y)
ax.set_title("My Plot")
ax.set_xlabel("X Axis")
ax.tick_params(axis='x', rotation=45)
fig.savefig("my_plot.png", dpi=300)
```

The OO style is more verbose but essential for professional work.

---

#### The Implementation

##### Step 1: Create the Matplotlib Toolkit Module

**File:** `src/matplotlib_toolkit.py`
```python
"""
Matplotlib Object-Oriented Visualization Toolkit

A comprehensive module for creating publication-quality figures
using Matplotlib's object-oriented API with GridSpec layouts,
fine-tuned formatting, and reusable components.
"""

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import Rectangle
from matplotlib.ticker import MultipleLocator, FormatStrFormatter, AutoMinorLocator
import numpy as np
import pandas as pd
from pathlib import Path
import warnings
warnings.filterwarnings('ignore')

# Set global style for consistent professional look
plt.style.use('seaborn-v0_8-darkgrid')
plt.rcParams['figure.dpi'] = 100
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.size'] = 10
plt.rcParams['axes.labelsize'] = 12
plt.rcParams['axes.titlesize'] = 14
plt.rcParams['legend.fontsize'] = 10
plt.rcParams['xtick.labelsize'] = 10
plt.rcParams['ytick.labelsize'] = 10


class MatplotlibFigureBuilder:
    """
    A class for building complex, publication-quality figures
    using Matplotlib's object-oriented API with GridSpec.
    
    This class provides methods for:
    - Creating complex multi-panel layouts
    - Customizing axes formatting
    - Adding annotations and highlights
    - Saving high-resolution figures
    
    Attributes:
        fig (plt.Figure): The figure object
        output_dir (Path): Directory for saving figures
    """
    
    def __init__(self, figsize=(12, 8), dpi=100, output_dir="outputs/figures"):
        """
        Initialize the figure builder.
        
        Parameters:
        -----------
        figsize : tuple
            Figure size in inches (width, height)
        dpi : int
            Figure resolution
        output_dir : str
            Directory for saving figures
        """
        self.fig = plt.figure(figsize=figsize, dpi=dpi)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.axes_dict = {}
        
    def create_gridspec_layout(self, nrows: int, ncols: int, 
                               width_ratios: list = None,
                               height_ratios: list = None,
                               hspace: float = 0.3,
                               wspace: float = 0.3) -> gridspec.GridSpec:
        """
        Create a GridSpec layout with customizable spacing.
        
        GridSpec allows you to define a grid and then selectively
        span subplots across multiple rows or columns.
        
        Parameters:
        -----------
        nrows : int
            Number of rows in the grid
        ncols : int
            Number of columns in the grid
        width_ratios : list
            Relative widths of columns (e.g., [1, 2, 1])
        height_ratios : list
            Relative heights of rows (e.g., [1, 2])
        hspace : float
            Height space between subplots (as fraction of average axis height)
        wspace : float
            Width space between subplots (as fraction of average axis width)
            
        Returns:
        --------
        gridspec.GridSpec
            The GridSpec object
        """
        gs = gridspec.GridSpec(
            nrows=nrows,
            ncols=ncols,
            figure=self.fig,
            width_ratios=width_ratios,
            height_ratios=height_ratios,
            hspace=hspace,
            wspace=wspace
        )
        
        return gs
    
    def add_subplot_from_gridspec(self, gs: gridspec.GridSpec, 
                                   row: int, col: int,
                                   row_span: int = 1,
                                   col_span: int = 1,
                                   name: str = None) -> plt.Axes:
        """
        Add a subplot at a specific GridSpec position.
        
        Parameters:
        -----------
        gs : gridspec.GridSpec
            The GridSpec object
        row : int
            Starting row index
        col : int
            Starting column index
        row_span : int
            Number of rows to span
        col_span : int
            Number of columns to span
        name : str
            Optional name for the axes (for later reference)
            
        Returns:
        --------
        plt.Axes
            The created Axes object
        """
        ax = self.fig.add_subplot(gs[row:row+row_span, col:col+col_span])
        
        if name is not None:
            self.axes_dict[name] = ax
            
        return ax
    
    # ---------- AXES FORMATTING ----------
    
    def format_axes(self, ax: plt.Axes, 
                   title: str = None,
                   xlabel: str = None,
                   ylabel: str = None,
                   xlim: tuple = None,
                   ylim: tuple = None,
                   xscale: str = 'linear',
                   yscale: str = 'linear',
                   grid: bool = True,
                   legend: bool = False,
                   x_tick_rotation: float = 0,
                   y_tick_rotation: float = 0,
                   x_tick_format: str = None,
                   y_tick_format: str = None,
                   x_tick_multiple: float = None,
                   y_tick_multiple: float = None,
                   add_minor_ticks: bool = True,
                   spine_color: str = 'black',
                   spine_linewidth: float = 1.0) -> None:
        """
        Apply comprehensive formatting to an Axes object.
        
        This method provides fine-grained control over every aspect
        of an Axes object, ensuring publication-quality appearance.
        
        Parameters:
        -----------
        ax : plt.Axes
            The Axes object to format
        title : str
            Axes title
        xlabel : str
            X-axis label
        ylabel : str
            Y-axis label
        xlim : tuple
            X-axis limits (min, max)
        ylim : tuple
            Y-axis limits (min, max)
        xscale : str
            Scale for x-axis ('linear', 'log', 'symlog', 'logit')
        yscale : str
            Scale for y-axis
        grid : bool
            Whether to show grid lines
        legend : bool
            Whether to show legend (if present)
        x_tick_rotation : float
            Rotation angle for x-tick labels
        y_tick_rotation : float
            Rotation angle for y-tick labels
        x_tick_format : str
            Format string for x-tick labels (e.g., '%.2f')
        y_tick_format : str
            Format string for y-tick labels
        x_tick_multiple : float
            Set major ticks at multiples of this value
        y_tick_multiple : float
            Set major ticks at multiples of this value
        add_minor_ticks : bool
            Whether to add minor tick marks
        spine_color : str
            Color for spines (borders)
        spine_linewidth : float
            Linewidth for spines
        """
        # Title and labels
        if title:
            ax.set_title(title, fontweight='bold', pad=15)
        if xlabel:
            ax.set_xlabel(xlabel, fontweight='medium', labelpad=10)
        if ylabel:
            ax.set_ylabel(ylabel, fontweight='medium', labelpad=10)
        
        # Scales
        ax.set_xscale(xscale)
        ax.set_yscale(yscale)
        
        # Limits
        if xlim:
            ax.set_xlim(xlim)
        if ylim:
            ax.set_ylim(ylim)
        
        # Ticks and tick formatting
        if x_tick_multiple:
            ax.xaxis.set_major_locator(MultipleLocator(x_tick_multiple))
        if y_tick_multiple:
            ax.yaxis.set_major_locator(MultipleLocator(y_tick_multiple))
        
        if x_tick_format:
            ax.xaxis.set_major_formatter(FormatStrFormatter(x_tick_format))
        if y_tick_format:
            ax.yaxis.set_major_formatter(FormatStrFormatter(y_tick_format))
        
        # Tick rotation
        ax.tick_params(axis='x', rotation=x_tick_rotation, labelsize=10)
        ax.tick_params(axis='y', rotation=y_tick_rotation, labelsize=10)
        
        # Minor ticks
        if add_minor_ticks:
            ax.xaxis.set_minor_locator(AutoMinorLocator())
            ax.yaxis.set_minor_locator(AutoMinorLocator())
            ax.tick_params(which='minor', length=3, width=0.8, color='gray')
            ax.tick_params(which='major', length=6, width=1.2)
        
        # Grid
        if grid:
            ax.grid(True, alpha=0.3, linestyle='--', linewidth=0.8)
            ax.grid(True, which='minor', alpha=0.1, linestyle=':', linewidth=0.5)
        
        # Spines (borders)
        for spine in ax.spines.values():
            spine.set_color(spine_color)
            spine.set_linewidth(spine_linewidth)
        
        # Legend
        if legend:
            ax.legend(frameon=True, fancybox=True, shadow=True, loc='best')
    
    # ---------- ANNOTATIONS ----------
    
    def add_annotation(self, ax: plt.Axes, text: str, x: float, y: float,
                      fontsize: int = 10, color: str = 'black',
                      background_color: str = 'white', alpha: float = 0.8,
                      arrowprops: dict = None) -> None:
        """
        Add an annotation with optional arrow.
        
        Parameters:
        -----------
        ax : plt.Axes
            The Axes object
        text : str
            Annotation text
        x : float
            X position in data coordinates
        y : float
            Y position in data coordinates
        fontsize : int
            Font size
        color : str
            Text color
        background_color : str
            Background color of annotation box
        alpha : float
            Transparency of annotation box
        arrowprops : dict
            Arrow properties dictionary
        """
        bbox_props = dict(
            boxstyle='round,pad=0.5',
            facecolor=background_color,
            alpha=alpha,
            edgecolor='gray'
        )
        
        ax.annotate(
            text,
            xy=(x, y),
            xytext=(x, y),
            fontsize=fontsize,
            color=color,
            bbox=bbox_props,
            arrowprops=arrowprops,
            ha='center',
            va='center'
        )
    
    def add_highlight_region(self, ax: plt.Axes, xmin: float, xmax: float,
                            ymin: float = None, ymax: float = None,
                            color: str = 'yellow', alpha: float = 0.2,
                            label: str = None) -> None:
        """
        Add a highlighted region to the plot.
        
        Useful for highlighting specific ranges or periods of interest.
        
        Parameters:
        -----------
        ax : plt.Axes
            The Axes object
        xmin : float
            Minimum x boundary
        xmax : float
            Maximum x boundary
        ymin : float
            Minimum y boundary (if None, uses axes limits)
        ymax : float
            Maximum y boundary (if None, uses axes limits)
        color : str
            Color of the highlight
        alpha : float
            Transparency of the highlight
        label : str
            Label for the legend
        """
        if ymin is None:
            ymin, ymax = ax.get_ylim()
        
        ax.axvspan(xmin, xmax, ymin=0, ymax=1, alpha=alpha, color=color, label=label)
    
    # ---------- SAVING ----------
    
    def save_figure(self, filename: str, dpi: int = 300, 
                   bbox_inches: str = 'tight',
                   facecolor: str = 'white',
                   edgecolor: str = 'white') -> Path:
        """
        Save the figure with publication-quality settings.
        
        Parameters:
        -----------
        filename : str
            Output filename (without path)
        dpi : int
            Resolution in dots per inch
        bbox_inches : str
            Bounding box to save ('tight' or 'standard')
        facecolor : str
            Figure face color
        edgecolor : str
            Figure edge color
            
        Returns:
        --------
        Path
            Path to the saved file
        """
        # Ensure filename has .png extension
        if not filename.endswith('.png'):
            filename += '.png'
        
        filepath = self.output_dir / filename
        self.fig.savefig(
            filepath,
            dpi=dpi,
            bbox_inches=bbox_inches,
            facecolor=facecolor,
            edgecolor=edgecolor,
            format='png'
        )
        
        print(f"  ✅ Figure saved: {filepath}")
        return filepath
    
    def show(self) -> None:
        """Display the figure (for interactive use)."""
        plt.show()
    
    def close(self) -> None:
        """Close the figure to free memory."""
        plt.close(self.fig)


# ---------- PRE-BUILT FIGURE TEMPLATES ----------

class FigureTemplates:
    """
    A collection of pre-built figure templates using Matplotlib.
    
    These templates demonstrate best practices for common
    visualization types and can be customized for specific needs.
    """
    
    def __init__(self, output_dir: str = "outputs/figures"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def create_distribution_grid(self, df: pd.DataFrame, 
                                 cols: list,
                                 n_cols: int = 3,
                                 figsize: tuple = (15, 10)) -> plt.Figure:
        """
        Create a grid of distribution plots with histograms and KDE.
        
        This template creates a professional-looking grid of
        distribution plots with consistent formatting.
        
        Parameters:
        -----------
        df : pd.DataFrame
            The dataset
        cols : list
            List of column names to plot
        n_cols : int
            Number of columns in the grid
        figsize : tuple
            Figure size
            
        Returns:
        --------
        plt.Figure
            The figure object
        """
        n_rows = (len(cols) + n_cols - 1) // n_cols
        
        builder = MatplotlibFigureBuilder(
            figsize=figsize,
            output_dir=str(self.output_dir)
        )
        
        gs = builder.create_gridspec_layout(
            nrows=n_rows,
            ncols=n_cols,
            hspace=0.4,
            wspace=0.3
        )
        
        for idx, col in enumerate(cols):
            row = idx // n_cols
            col_idx = idx % n_cols
            ax = builder.add_subplot_from_gridspec(gs, row, col_idx, name=col)
            
            # Get data (drop missing)
            data = df[col].dropna()
            
            # Plot histogram with KDE
            ax.hist(data, bins=30, density=True, alpha=0.6, color='steelblue', edgecolor='black')
            
            # Add KDE (kernel density estimate) manually using numpy
            from scipy.stats import gaussian_kde
            if len(data) > 1:
                kde = gaussian_kde(data)
                x_range = np.linspace(data.min(), data.max(), 200)
                ax.plot(x_range, kde(x_range), 'r-', linewidth=2, label='KDE')
            
            # Format the axes
            builder.format_axes(
                ax,
                title=f'Distribution of {col}',
                xlabel=col,
                ylabel='Density',
                grid=True,
                add_minor_ticks=True
            )
            
            # Add summary statistics
            stats_text = f"n={len(data):,}\nμ={data.mean():.2f}\nσ={data.std():.2f}"
            builder.add_annotation(
                ax,
                stats_text,
                x=0.95,
                y=0.95,
                background_color='white',
                alpha=0.8
            )
        
        # Hide empty subplots
        for idx in range(len(cols), n_rows * n_cols):
            row = idx // n_cols
            col_idx = idx % n_cols
            if row < n_rows and col_idx < n_cols:
                ax = builder.add_subplot_from_gridspec(gs, row, col_idx)
                ax.axis('off')
        
        plt.suptitle('Distribution Analysis Grid', fontsize=16, fontweight='bold')
        plt.tight_layout()
        
        builder.save_figure('template_distribution_grid.png')
        
        return builder.fig
    
    def create_correlation_heatmap(self, df: pd.DataFrame,
                                   cols: list = None,
                                   figsize: tuple = (10, 8)) -> plt.Figure:
        """
        Create a professional correlation heatmap.
        
        Parameters:
        -----------
        df : pd.DataFrame
            The dataset
        cols : list
            Columns to include (if None, uses all numerical)
        figsize : tuple
            Figure size
            
        Returns:
        --------
        plt.Figure
            The figure object
        """
        if cols is None:
            cols = df.select_dtypes(include=[np.number]).columns.tolist()
        
        # Compute correlation
        corr_data = df[cols].dropna()
        corr_matrix = corr_data.corr()
        
        builder = MatplotlibFigureBuilder(figsize=figsize)
        gs = builder.create_gridspec_layout(nrows=1, ncols=1)
        ax = builder.add_subplot_from_gridspec(gs, 0, 0)
        
        # Create heatmap
        im = ax.imshow(corr_matrix, cmap='RdBu_r', vmin=-1, vmax=1, aspect='auto')
        
        # Add colorbar
        cbar = builder.fig.colorbar(im, ax=ax, shrink=0.8)
        cbar.set_label('Correlation Coefficient', fontsize=12)
        
        # Set ticks
        ax.set_xticks(np.arange(len(corr_matrix.columns)))
        ax.set_yticks(np.arange(len(corr_matrix.columns)))
        ax.set_xticklabels(corr_matrix.columns, rotation=45, ha='right')
        ax.set_yticklabels(corr_matrix.columns)
        
        # Add text annotations
        for i in range(len(corr_matrix.columns)):
            for j in range(len(corr_matrix.columns)):
                if i != j:
                    text = ax.text(j, i, f'{corr_matrix.iloc[i, j]:.2f}',
                                 ha="center", va="center", color="black",
                                 fontsize=8, fontweight='bold')
        
        builder.format_axes(
            ax,
            title='Correlation Heatmap',
            grid=False,
            add_minor_ticks=False
        )
        
        plt.tight_layout()
        builder.save_figure('template_correlation_heatmap.png')
        
        return builder.fig
    
    def create_time_series_panel(self, df: pd.DataFrame,
                                 date_col: str,
                                 value_cols: list,
                                 figsize: tuple = (14, 8)) -> plt.Figure:
        """
        Create a multi-panel time series figure.
        
        Parameters:
        -----------
        df : pd.DataFrame
            The dataset
        date_col : str
            Column containing dates
        value_cols : list
            Columns to plot over time
        figsize : tuple
            Figure size
            
        Returns:
        --------
        plt.Figure
            The figure object
        """
        # Convert to datetime
        df[date_col] = pd.to_datetime(df[date_col])
        
        # Aggregate by date
        agg_data = df.groupby(pd.Grouper(key=date_col, freq='D'))[value_cols].mean().dropna()
        
        n_cols = min(2, len(value_cols))
        n_rows = (len(value_cols) + n_cols - 1) // n_cols
        
        builder = MatplotlibFigureBuilder(figsize=figsize)
        gs = builder.create_gridspec_layout(
            nrows=n_rows,
            ncols=n_cols,
            hspace=0.3,
            wspace=0.2
        )
        
        for idx, col in enumerate(value_cols):
            row = idx // n_cols
            col_idx = idx % n_cols
            ax = builder.add_subplot_from_gridspec(gs, row, col_idx, name=col)
            
            # Plot time series
            ax.plot(agg_data.index, agg_data[col], 'b-', linewidth=2, label=col)
            
            # Add trend line (simple moving average)
            ma_window = min(7, len(agg_data))
            ma = agg_data[col].rolling(window=ma_window, center=True).mean()
            ax.plot(agg_data.index, ma, 'r--', linewidth=1.5, label=f'{ma_window}-day MA')
            
            builder.format_axes(
                ax,
                title=f'{col} Over Time',
                xlabel='Date',
                ylabel=col,
                grid=True,
                legend=True,
                x_tick_rotation=45,
                add_minor_ticks=True
            )
        
        plt.suptitle('Time Series Analysis Panel', fontsize=16, fontweight='bold')
        plt.tight_layout()
        
        builder.save_figure('template_time_series_panel.png')
        
        return builder.fig


# ---------- DEMONSTRATION ----------

def demonstrate_matplotlib_toolkit(data_path: str = "data/customer_data.csv"):
    """
    Run a demonstration of the Matplotlib toolkit.
    
    This function demonstrates all the capabilities of the toolkit
    using the customer dataset.
    """
    
    print("=" * 60)
    print("MATPLOTLIB TOOLKIT DEMONSTRATION")
    print("=" * 60)
    
    # Load data
    print("\n📂 Loading dataset...")
    df = pd.read_csv(data_path)
    print(f"✅ Loaded {df.shape[0]} rows and {df.shape[1]} columns")
    
    # Create templates
    templates = FigureTemplates()
    
    # 1. Distribution grid
    print("\n📊 Creating distribution grid...")
    numerical_cols = df.select_dtypes(include=[np.number]).columns.tolist()
    # Remove ID columns
    numerical_cols = [c for c in numerical_cols if c not in ['customer_id', 'city_tier']]
    # Take first 6 for demonstration
    demo_cols = numerical_cols[:6]
    templates.create_distribution_grid(df, demo_cols)
    
    # 2. Correlation heatmap
    print("\n📈 Creating correlation heatmap...")
    templates.create_correlation_heatmap(df, numerical_cols[:8])
    
    print("\n" + "=" * 60)
    print("DEMONSTRATION COMPLETE")
    print("=" * 60)
    print("\n📁 Figures saved to: outputs/figures/")
    print("  • template_distribution_grid.png")
    print("  • template_correlation_heatmap.png")


if __name__ == "__main__":
    demonstrate_matplotlib_toolkit()
```

---

##### Step 2: Create an Advanced Custom Layout Example

**File:** `src/advanced_matplotlib_layouts.py`
```python
"""
Advanced Matplotlib GridSpec Layouts

Demonstrates complex layouts with GridSpec including:
- Nested grids
- Spanning subplots
- Mixed plot types
- Custom positioning
"""

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import numpy as np
import pandas as pd
from matplotlib_toolkit import MatplotlibFigureBuilder, FigureTemplates
from pathlib import Path


def create_magazine_layout(data_path: str = "data/customer_data.csv"):
    """
    Create a magazine-style layout with multiple plot types.
    
    This demonstrates a complex layout with:
    - A large main plot spanning multiple cells
    - Smaller supporting plots around it
    - Custom spacing and alignment
    """
    
    print("\n📊 Creating magazine-style layout...")
    
    # Load data
    df = pd.read_csv(data_path)
    
    # Create a custom figure
    fig = plt.figure(figsize=(16, 12))
    
    # Create a complex GridSpec with different column widths
    # Layout: 
    # [  Main Plot  ] [ Small Plot 1 ]
    # [  Main Plot  ] [ Small Plot 2 ]
    # [   Bottom Spanning Plot         ]
    gs = fig.add_gridspec(
        nrows=3,
        ncols=3,
        width_ratios=[2, 1, 1],
        height_ratios=[1.5, 1, 1],
        hspace=0.3,
        wspace=0.3
    )
    
    # --- Plot 1: Main plot (spans 2 rows, 1 column) ---
    ax_main = fig.add_subplot(gs[0:2, 0])
    
    # Scatter plot: Income vs Order Value with color by age
    plot_data = df.dropna(subset=['avg_order_value', 'order_frequency', 'age'])
    
    # Create income numeric mapping
    income_order = ['<$25K', '$25K-$50K', '$50K-$75K', '$75K-$100K', '>$100K']
    income_numeric = plot_data['income_bracket'].map({v: i for i, v in enumerate(income_order)})
    
    scatter = ax_main.scatter(
        plot_data['order_frequency'],
        plot_data['avg_order_value'],
        c=plot_data['age'],
        cmap='viridis',
        alpha=0.6,
        s=50,
        vmin=18,
        vmax=70
    )
    
    # Add colorbar
    cbar = fig.colorbar(scatter, ax=ax_main, shrink=0.8)
    cbar.set_label('Age', fontsize=12)
    
    ax_main.set_xlabel('Order Frequency (orders/month)', fontsize=12)
    ax_main.set_ylabel('Average Order Value ($)', fontsize=12)
    ax_main.set_title('Purchase Behavior by Age\n(Main Analysis Plot)', fontsize=14, fontweight='bold')
    ax_main.grid(True, alpha=0.3)
    
    # --- Plot 2: Small plot - Distribution of age ---
    ax_age = fig.add_subplot(gs[0, 1])
    age_data = df['age'].dropna()
    ax_age.hist(age_data, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
    ax_age.axvline(age_data.mean(), color='red', linestyle='--', linewidth=2, label=f'Mean: {age_data.mean():.1f}')
    ax_age.axvline(age_data.median(), color='green', linestyle='-.', linewidth=2, label=f'Median: {age_data.median():.1f}')
    ax_age.set_xlabel('Age')
    ax_age.set_ylabel('Frequency')
    ax_age.set_title('Age Distribution')
    ax_age.legend(fontsize=8)
    ax_age.grid(True, alpha=0.3)
    
    # --- Plot 3: Small plot - Boxplot of order frequency by gender ---
    ax_freq = fig.add_subplot(gs[1, 1])
    gender_data = df.dropna(subset=['order_frequency', 'gender'])
    gender_data.boxplot(column='order_frequency', by='gender', ax=ax_freq, patch_artist=True)
    ax_freq.set_title('Order Frequency by Gender')
    ax_freq.set_xlabel('Gender')
    ax_freq.set_ylabel('Order Frequency')
    ax_freq.grid(True, alpha=0.3)
    
    # --- Plot 4: Bar chart - Top product categories ---
    ax_cat = fig.add_subplot(gs[0:2, 2])
    category_counts = df['favorite_category'].value_counts()
    bars = ax_cat.barh(category_counts.index, category_counts.values, 
                       color='coral', edgecolor='black')
    ax_cat.set_xlabel('Number of Customers')
    ax_cat.set_title('Favorite Product Categories')
    
    # Add value labels
    for bar in bars:
        width = bar.get_width()
        ax_cat.text(width + 10, bar.get_y() + bar.get_height()/2,
                   f'{int(width)}', va='center', fontsize=9)
    ax_cat.grid(True, alpha=0.3, axis='x')
    
    # --- Plot 5: Bottom spanning plot - Time series ---
    ax_time = fig.add_subplot(gs[2, :])
    
    # Aggregate orders by month (using account_created as proxy)
    if 'account_created' in df.columns:
        df['account_created'] = pd.to_datetime(df['account_created'])
        monthly_counts = df.groupby(pd.Grouper(key='account_created', freq='M')).size()
        
        ax_time.plot(monthly_counts.index, monthly_counts.values, 
                    'b-', linewidth=2, marker='o', markersize=6)
        ax_time.fill_between(monthly_counts.index, 0, monthly_counts.values, 
                            alpha=0.3, color='blue')
        ax_time.set_xlabel('Date')
        ax_time.set_ylabel('Number of New Customers')
        ax_time.set_title('Customer Acquisition Over Time')
        ax_time.grid(True, alpha=0.3)
        ax_time.tick_params(axis='x', rotation=45)
    
    plt.suptitle('Customer Analytics Dashboard\nComprehensive Multi-Panel Figure',
                fontsize=18, fontweight='bold', y=0.98)
    plt.tight_layout()
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / "advanced_magazine_layout.png"
    plt.savefig(filepath, dpi=300, bbox_inches='tight', facecolor='white')
    print(f"  ✅ Saved: {filepath}")
    
    plt.show()
    
    return fig


def create_nested_grid_layout(data_path: str = "data/customer_data.csv"):
    """
    Create a layout with nested GridSpec for complex compositions.
    
    This demonstrates how to create layouts within layouts for
    maximum control over positioning.
    """
    
    print("\n📊 Creating nested grid layout...")
    
    df = pd.read_csv(data_path)
    
    fig = plt.figure(figsize=(14, 10))
    
    # Outer GridSpec: 2 rows, 2 columns
    outer_gs = fig.add_gridspec(2, 2, width_ratios=[1.5, 1], height_ratios=[1, 1])
    
    # --- Top Left: Large panel with inner GridSpec ---
    # This creates a 2x2 grid inside the top-left cell
    inner_left = gridspec.GridSpecFromSubplotSpec(
        2, 2, 
        subplot_spec=outer_gs[0, 0],
        hspace=0.2,
        wspace=0.2
    )
    
    # Top-left of inner: Scatter plot
    ax1 = fig.add_subplot(inner_left[0, 0])
    scatter_data = df.dropna(subset=['time_on_site', 'pages_viewed'])
    ax1.scatter(scatter_data['time_on_site'], scatter_data['pages_viewed'], 
               alpha=0.4, s=20, c='steelblue')
    ax1.set_xlabel('Time on Site (min)')
    ax1.set_ylabel('Pages Viewed')
    ax1.set_title('Engagement Pattern')
    ax1.grid(True, alpha=0.3)
    
    # Top-right of inner: KDE plot
    ax2 = fig.add_subplot(inner_left[0, 1])
    ax2.hist(df['time_on_site'].dropna(), bins=30, density=True, 
             alpha=0.6, color='green', edgecolor='black')
    from scipy.stats import gaussian_kde
    data = df['time_on_site'].dropna()
    if len(data) > 1:
        kde = gaussian_kde(data)
        x_range = np.linspace(data.min(), data.max(), 200)
        ax2.plot(x_range, kde(x_range), 'r-', linewidth=2)
    ax2.set_xlabel('Time on Site (min)')
    ax2.set_ylabel('Density')
    ax2.set_title('Time Distribution')
    ax2.grid(True, alpha=0.3)
    
    # Bottom-left of inner: Bar chart of city tiers
    ax3 = fig.add_subplot(inner_left[1, 0])
    city_counts = df['city_tier'].value_counts().sort_index()
    city_labels = {1: 'Major Metro', 2: 'Mid-size', 3: 'Small City'}
    ax3.bar([city_labels[i] for i in city_counts.index], city_counts.values,
            color='purple', alpha=0.7, edgecolor='black')
    ax3.set_xlabel('City Tier')
    ax3.set_ylabel('Count')
    ax3.set_title('Customer Distribution by City')
    ax3.tick_params(axis='x', rotation=45)
    ax3.grid(True, alpha=0.3, axis='y')
    
    # Bottom-right of inner: Boxplot of rating by city tier
    ax4 = fig.add_subplot(inner_left[1, 1])
    rating_data = df.dropna(subset=['customer_rating', 'city_tier'])
    rating_data['city_tier_label'] = rating_data['city_tier'].map(city_labels)
    rating_data.boxplot(column='customer_rating', by='city_tier_label', ax=ax4, patch_artist=True)
    ax4.set_title('Customer Rating by City')
    ax4.set_xlabel('City Tier')
    ax4.set_ylabel('Rating')
    ax4.grid(True, alpha=0.3)
    
    # --- Top Right: Distribution of order frequency ---
    ax_top_right = fig.add_subplot(outer_gs[0, 1])
    ax_top_right.hist(df['order_frequency'].dropna(), bins=30, 
                      color='orange', edgecolor='black', alpha=0.7)
    ax_top_right.axvline(df['order_frequency'].mean(), color='red', 
                        linestyle='--', label=f'Mean: {df["order_frequency"].mean():.2f}')
    ax_top_right.set_xlabel('Order Frequency')
    ax_top_right.set_ylabel('Count')
    ax_top_right.set_title('Order Frequency Distribution')
    ax_top_right.legend()
    ax_top_right.grid(True, alpha=0.3)
    
    # --- Bottom Left: Correlation between key metrics ---
    ax_bottom_left = fig.add_subplot(outer_gs[1, 0])
    # Create correlation matrix for a subset
    corr_cols = ['order_frequency', 'avg_order_value', 'customer_rating', 'return_rate']
    corr_data = df[corr_cols].dropna()
    corr_matrix = corr_data.corr()
    
    im = ax_bottom_left.imshow(corr_matrix, cmap='RdBu_r', vmin=-1, vmax=1)
    ax_bottom_left.set_xticks(range(len(corr_matrix.columns)))
    ax_bottom_left.set_yticks(range(len(corr_matrix.columns)))
    ax_bottom_left.set_xticklabels(corr_matrix.columns, rotation=45, ha='right')
    ax_bottom_left.set_yticklabels(corr_matrix.columns)
    
    # Add text annotations
    for i in range(len(corr_matrix.columns)):
        for j in range(len(corr_matrix.columns)):
            text = ax_bottom_left.text(j, i, f'{corr_matrix.iloc[i, j]:.2f}',
                                     ha="center", va="center", color="black",
                                     fontsize=9, fontweight='bold')
    
    ax_bottom_left.set_title('Correlation Matrix\nKey Metrics', fontweight='bold')
    fig.colorbar(im, ax=ax_bottom_left, shrink=0.6)
    
    # --- Bottom Right: Boxplot of order value by rating ---
    ax_bottom_right = fig.add_subplot(outer_gs[1, 1])
    # Create rating groups
    rating_data = df.dropna(subset=['customer_rating', 'avg_order_value'])
    rating_data['rating_group'] = pd.cut(rating_data['customer_rating'], 
                                         bins=[0, 2, 3, 4, 5],
                                         labels=['Poor (0-2)', 'Fair (2-3)', 
                                                'Good (3-4)', 'Excellent (4-5)'])
    rating_data.boxplot(column='avg_order_value', by='rating_group', ax=ax_bottom_right, patch_artist=True)
    ax_bottom_right.set_title('Order Value by Rating Group')
    ax_bottom_right.set_xlabel('Customer Rating')
    ax_bottom_right.set_ylabel('Avg Order Value ($)')
    ax_bottom_right.grid(True, alpha=0.3)
    
    plt.suptitle('Nested Grid Layout: Maximum Control Over Positioning',
                fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout()
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / "nested_grid_layout.png"
    plt.savefig(filepath, dpi=300, bbox_inches='tight', facecolor='white')
    print(f"  ✅ Saved: {filepath}")
    
    plt.show()
    
    return fig


def demonstrate_spine_customization(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate fine-grained spine and axis customization.
    """
    
    print("\n📊 Creating spine customization demonstration...")
    
    df = pd.read_csv(data_path)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # 1. Default spines
    ax1 = axes[0, 0]
    ax1.hist(df['age'].dropna(), bins=30, color='steelblue', edgecolor='black')
    ax1.set_title('Default Spines')
    ax1.set_xlabel('Age')
    ax1.set_ylabel('Count')
    
    # 2. Custom colors and linewidths
    ax2 = axes[0, 1]
    ax2.hist(df['age'].dropna(), bins=30, color='steelblue', edgecolor='black')
    ax2.set_title('Custom Spines')
    ax2.set_xlabel('Age')
    ax2.set_ylabel('Count')
    for spine in ax2.spines.values():
        spine.set_color('darkred')
        spine.set_linewidth(2.5)
    
    # 3. Hide top and right spines
    ax3 = axes[1, 0]
    ax3.hist(df['age'].dropna(), bins=30, color='steelblue', edgecolor='black')
    ax3.set_title('Hide Top & Right Spines')
    ax3.set_xlabel('Age')
    ax3.set_ylabel('Count')
    ax3.spines['top'].set_visible(False)
    ax3.spines['right'].set_visible(False)
    
    # 4. Move spines to center (for scientific plots)
    ax4 = axes[1, 1]
    ax4.hist(df['age'].dropna(), bins=30, color='steelblue', edgecolor='black')
    ax4.set_title('Centered Spines')
    ax4.set_xlabel('Age')
    ax4.set_ylabel('Count')
    ax4.spines['left'].set_position('center')
    ax4.spines['bottom'].set_position('center')
    ax4.spines['right'].set_visible(False)
    ax4.spines['top'].set_visible(False)
    ax4.xaxis.set_ticks_position('bottom')
    ax4.yaxis.set_ticks_position('left')
    
    plt.suptitle('Spine Customization Examples', fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / "spine_customization.png"
    plt.savefig(filepath, dpi=300, bbox_inches='tight', facecolor='white')
    print(f"  ✅ Saved: {filepath}")
    
    plt.show()
    
    return fig


def run_all_matplotlib_demos(data_path: str = "data/customer_data.csv"):
    """
    Run all Matplotlib demonstrations.
    """
    
    print("=" * 60)
    print("MATPLOTLIB ADVANCED LAYOUTS DEMONSTRATION")
    print("=" * 60)
    
    # Run demonstrations
    create_magazine_layout(data_path)
    create_nested_grid_layout(data_path)
    demonstrate_spine_customization(data_path)
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)
    print("\n📁 All figures saved to: outputs/figures/")
    print("  • advanced_magazine_layout.png")
    print("  • nested_grid_layout.png")
    print("  • spine_customization.png")
    print("  • template_distribution_grid.png")
    print("  • template_correlation_heatmap.png")


if __name__ == "__main__":
    run_all_matplotlib_demos()
```

---

#### The Verification

**Verification 1: Run the Matplotlib Toolkit**

```bash
# Run the toolkit demonstration
python src/matplotlib_toolkit.py

# Run the advanced layouts
python src/advanced_matplotlib_layouts.py
```

**Verification 2: Check Generated Figures**

```bash
# List all generated figures
ls -la outputs/figures/*.png
```

You should see:
- `template_distribution_grid.png`
- `template_correlation_heatmap.png`
- `advanced_magazine_layout.png`
- `nested_grid_layout.png`
- `spine_customization.png`

**Verification 3: Visual Inspection**

Open each figure to verify:
1. All subplots are properly positioned
2. Labels and titles are readable
3. Colors and styling are consistent
4. Annotations are clear
5. Overall figure is publication-ready

**Verification 4: Quick Script to Validate Figure Dimensions**

**File:** `src/validate_figures.py`
```python
"""
Validate generated figure dimensions and properties.
"""

from PIL import Image
from pathlib import Path

def validate_figures():
    """Check dimensions and quality of generated figures."""
    
    print("=" * 60)
    print("VALIDATING FIGURE PROPERTIES")
    print("=" * 60)
    
    fig_dir = Path("outputs/figures")
    figures = list(fig_dir.glob("*.png"))
    
    print(f"\n📁 Found {len(figures)} figures")
    
    total_size = 0
    for fig_path in figures:
        with Image.open(fig_path) as img:
            width, height = img.size
            size_kb = fig_path.stat().st_size / 1024
            total_size += size_kb
            
            print(f"\n  {fig_path.name}:")
            print(f"    Dimensions: {width}x{height} pixels")
            print(f"    Size: {size_kb:.1f} KB")
            print(f"    Aspect ratio: {width/height:.2f}:1")
            
            # Check minimum quality
            if width < 1200 or height < 800:
                print(f"    ⚠️ Resolution might be low for publication")
            else:
                print(f"    ✅ Publication-ready resolution")
    
    print(f"\n📊 Total size: {total_size:.1f} KB")
    print("\n" + "=" * 60)

if __name__ == "__main__":
    validate_figures()
```

Run it:
```bash
python src/validate_figures.py
```

---

#### What We've Accomplished

In this part, we've:

1. ✅ Mastered Matplotlib's object-oriented API:
   - **Figure:** The overall canvas
   - **Axes:** Individual plotting areas
   - **Artists:** All visual elements (lines, text, shapes)
   - **GridSpec:** Layout management

2. ✅ Built a comprehensive `MatplotlibFigureBuilder` class with:
   - GridSpec layout creation
   - Comprehensive axes formatting
   - Annotation and highlighting
   - High-quality figure saving

3. ✅ Created reusable templates:
   - Distribution grid for multiple variables
   - Correlation heatmap
   - Time series panel

4. ✅ Advanced layout techniques:
   - Magazine-style layouts with varying cell sizes
   - Nested GridSpec for complex compositions
   - Spine customization for scientific visuals
   - Fine-grained control over every element

5. ✅ Learned best practices for publication-quality figures:
   - Consistent styling and typography
   - Proper labeling and annotations
   - High resolution (300 DPI)
   - Professional color schemes

---

#### Deep Dive Reference: Matplotlib Architecture and Styling

**The Matplotlib Object Hierarchy**

```
Figure
  ├── Axes (subplots)
  │   ├── Artists (lines, patches, text)
  │   ├── XAxis
  │   │   ├── Major ticks, Minor ticks
  │   │   └── Tick labels
  │   ├── YAxis
  │   │   ├── Major ticks, Minor ticks
  │   │   └── Tick labels
  │   ├── Spines (top, bottom, left, right)
  │   ├── Title
  │   └── Legend
  ├── GridSpec (layout management)
  └── Colorbar
```

**GridSpec vs. subplot2grid vs. add_subplot**

| Method | Use Case | Advantages |
|--------|----------|------------|
| `add_subplot(2,2,1)` | Simple grids | Quick and easy |
| `subplot2grid((3,3), (0,0), colspan=2)` | Simple spanning | Readable for simple layouts |
| **GridSpec** | Complex layouts | Full control, nested grids, variable sizing |

**Recommended GridSpec Patterns:**

```python
# 1. Unequal column widths
gs = gridspec.GridSpec(2, 3, width_ratios=[1, 2, 1])

# 2. Unequal row heights
gs = gridspec.GridSpec(3, 2, height_ratios=[0.5, 1, 0.5])

# 3. Spanning rows/columns
ax_big = fig.add_subplot(gs[0:2, :])  # Span first 2 rows, all columns

# 4. Nested grids
inner_gs = gridspec.GridSpecFromSubplotSpec(2, 2, subplot_spec=outer_gs[0, 0])
```

**Color and Styling Best Practices**

1. **Color Palettes:**
   - Use perceptually uniform colormaps: 'viridis', 'plasma', 'RdBu_r'
   - For categorical: use predefined palettes: 'Set2', 'tab10'
   - Consider colorblind-friendly options

2. **Font Choices:**
   - Sans-serif for clarity: 'Arial', 'Helvetica'
   - Consistent sizes: Title > Axis Labels > Ticks
   - Use weight distinctions: bold for titles, regular for labels

3. **Spacing and Sizing:**
   - `tight_layout()` automatically adjusts spacing
   - Manual spacing: `subplots_adjust(left=0.1, right=0.9, top=0.9, bottom=0.1)`
   - Figure size: 12x8 inches for presentations, 6x4 for papers

**Saving for Different Purposes:**

| Purpose | DPI | Format | bbox_inches |
|---------|-----|--------|-------------|
| Web/Notebook | 72-100 | PNG | 'tight' |
| Presentation | 150-200 | PNG | 'tight' |
| Publication | 300+ | PNG/PDF | 'tight' |
| Vector Graphics | N/A | PDF/SVG | 'standard' |

---

#### Next Up

In **Part 2: Seaborn - Statistical Visualizations and Multi-Plot Grids**, we'll build on our Matplotlib foundation to create:
- High-level statistical plots (distributions, categorical plots)
- Multi-plot grids with FacetGrid and PairGrid
- Customizing seaborn with our Matplotlib knowledge
- Creating publication-ready statistical summaries
