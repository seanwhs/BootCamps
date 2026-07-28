# Phase 2: Exploratory Data Analysis & Visualization

## Module 2.2: Static & Declarative Visualizations

### Part 2: Seaborn - Statistical Visualizations and Multi-Plot Grids

---

#### The Target

In this part, we'll build a comprehensive Seaborn toolkit that leverages its high-level statistical plotting capabilities. By the end, you'll have:

1. Mastery of Seaborn's statistical plot types (distribution, categorical, regression)
2. The ability to create multi-plot grids using FacetGrid and PairGrid
3. Integration of Seaborn with Matplotlib for fine-tuning
4. A reusable class for generating statistical visualizations
5. Publication-ready statistical summaries with proper annotations

---

#### The Concept

**Seaborn: Matplotlib's Statistical Supercharger**

Think of Matplotlib as a manual transmission car—you have complete control over every gear, clutch, and brake. Seaborn is like adding a smart automatic transmission and advanced driver assistance systems. It handles the complex statistical calculations and aesthetic details while still letting you take control when needed.

**What Seaborn does for you:**

1. **Statistical transformations:** Automatically computes KDE, histograms, confidence intervals, and regression lines
2. **Aesthetic defaults:** Beautiful color palettes and styling out of the box
3. **Multi-plot management:** FacetGrid and PairGrid handle complex multi-panel layouts
4. **Integration:** Works seamlessly with pandas DataFrames and Matplotlib

**The Seaborn Ecosystem:**

- **Distribution plots:** `histplot`, `kdeplot`, `ecdfplot`, `rugplot`, `displot`
- **Categorical plots:** `boxplot`, `violinplot`, `boxenplot`, `pointplot`, `barplot`, `countplot`
- **Regression plots:** `regplot`, `lmplot`, `residplot`
- **Matrix plots:** `heatmap`, `clustermap`
- **Grids:** `FacetGrid`, `PairGrid`, `JointGrid`

---

#### The Implementation

##### Step 1: Create the Seaborn Toolkit Module

**File:** `src/seaborn_toolkit.py`
```python
"""
Seaborn Statistical Visualization Toolkit

A comprehensive module for creating statistical visualizations
using Seaborn with Matplotlib integration for fine-tuning.

This module provides:
- Distribution analysis plots
- Categorical relationship plots
- Regression and correlation plots
- Multi-plot grids (FacetGrid, PairGrid)
- Publication-ready statistical summaries
"""

import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd
from pathlib import Path
from scipy import stats
import warnings
warnings.filterwarnings('ignore')

# Set Seaborn style with Matplotlib integration
sns.set_theme(style='darkgrid')
sns.set_context('notebook', font_scale=1.2)


class SeabornVisualizer:
    """
    A class for creating statistical visualizations with Seaborn.
    
    This class provides high-level methods for common statistical
    plots with consistent formatting and annotation.
    
    Attributes:
        df (pd.DataFrame): The dataset
        output_dir (Path): Directory for saving figures
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
        
        # Detect column types
        self.numerical_cols = self.df.select_dtypes(include=[np.number]).columns.tolist()
        self.categorical_cols = self.df.select_dtypes(include=['object', 'category']).columns.tolist()
        
        # Set default color palette
        self.palette = sns.color_palette('husl', 8)
        
    # ---------- DISTRIBUTION PLOTS ----------
    
    def plot_histogram_with_kde(self, col: str, bins: int = 30,
                               save: bool = True) -> plt.Figure:
        """
        Create a histogram with KDE overlay.
        
        Parameters:
        -----------
        col : str
            Column to visualize
        bins : int
            Number of histogram bins
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        fig, ax = plt.subplots(figsize=(10, 6))
        
        # Use Seaborn's histplot
        sns.histplot(
            data=self.df,
            x=col,
            bins=bins,
            kde=True,
            color='steelblue',
            edgecolor='white',
            linewidth=0.5,
            ax=ax
        )
        
        # Add statistical annotations
        data = self.df[col].dropna()
        mean = data.mean()
        median = data.median()
        std = data.std()
        
        # Add vertical lines for mean and median
        ax.axvline(mean, color='red', linestyle='--', linewidth=2, label=f'Mean: {mean:.2f}')
        ax.axvline(median, color='green', linestyle='-.', linewidth=2, label=f'Median: {median:.2f}')
        
        # Add annotation box with statistics
        stats_text = (
            f'n = {len(data):,}\n'
            f'μ = {mean:.2f}\n'
            f'σ = {std:.2f}\n'
            f'Skew = {data.skew():.2f}'
        )
        ax.text(
            0.02, 0.98, stats_text,
            transform=ax.transAxes,
            fontsize=10,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8)
        )
        
        ax.set_title(f'Distribution of {col}', fontsize=14, fontweight='bold')
        ax.set_xlabel(col, fontsize=12)
        ax.set_ylabel('Density', fontsize=12)
        ax.legend(loc='upper right')
        
        plt.tight_layout()
        
        if save:
            filepath = self.output_dir / f'seaborn_{col}_histogram.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return fig
    
    def plot_violin_with_box(self, numerical_col: str, categorical_col: str,
                           save: bool = True) -> plt.Figure:
        """
        Create a violin plot with boxplot overlay.
        
        Violin plots combine boxplots with KDE to show distribution shape.
        
        Parameters:
        -----------
        numerical_col : str
            Numerical column to plot
        categorical_col : str
            Categorical column for grouping
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        fig, ax = plt.subplots(figsize=(12, 7))
        
        # Create violin plot
        sns.violinplot(
            data=self.df,
            x=categorical_col,
            y=numerical_col,
            inner='quartile',  # Show quartiles inside violin
            palette=self.palette,
            scale='width',  # All violins same width
            ax=ax
        )
        
        # Add strip plot for individual points (with transparency)
        sns.stripplot(
            data=self.df,
            x=categorical_col,
            y=numerical_col,
            color='black',
            alpha=0.3,
            size=3,
            jitter=True,
            ax=ax
        )
        
        # Add statistical annotation
        stats_df = self.df.groupby(categorical_col)[numerical_col].agg(['mean', 'median', 'count']).round(2)
        ax.text(
            0.02, 0.98, 
            f'Group Statistics:\n{stats_df.to_string()}',
            transform=ax.transAxes,
            fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8)
        )
        
        ax.set_title(f'Distribution of {numerical_col} by {categorical_col}', 
                    fontsize=14, fontweight='bold')
        ax.set_xlabel(categorical_col, fontsize=12)
        ax.set_ylabel(numerical_col, fontsize=12)
        ax.tick_params(axis='x', rotation=45)
        
        plt.tight_layout()
        
        if save:
            filepath = self.output_dir / f'seaborn_{numerical_col}_by_{categorical_col}_violin.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return fig
    
    def plot_pairwise_distribution(self, cols: list = None,
                                  max_cols: int = 5,
                                  save: bool = True) -> plt.Figure:
        """
        Create a PairGrid showing pairwise distributions.
        
        This creates a matrix of plots showing:
        - Diagonal: Histograms (or KDE)
        - Off-diagonal: Scatter plots with regression lines
        
        Parameters:
        -----------
        cols : list
            Columns to include (if None, uses all numerical)
        max_cols : int
            Maximum number of columns (to avoid overloaded plots)
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        if cols is None:
            cols = self.numerical_cols
        
        # Limit columns
        if len(cols) > max_cols:
            # Select columns with highest variance
            variances = self.df[cols].var().sort_values(ascending=False)
            cols = variances.head(max_cols).index.tolist()
            print(f"  ⚠️ Limited to {max_cols} columns for pair plot")
        
        # Drop missing values
        plot_data = self.df[cols].dropna()
        
        # Create pair grid
        g = sns.PairGrid(
            plot_data,
            diag_sharey=False,
            height=2.5,
            aspect=1
        )
        
        # Upper triangle: scatter plot with regression
        g.map_upper(sns.regplot, 
                    scatter_kws={'alpha': 0.3, 's': 20},
                    line_kws={'color': 'red', 'linewidth': 2})
        
        # Lower triangle: scatter plot with density
        g.map_lower(sns.scatterplot, alpha=0.3, s=20)
        
        # Diagonal: histogram with KDE
        g.map_diag(sns.histplot, kde=True, edgecolor='black', linewidth=0.5)
        
        # Add title
        g.fig.suptitle('Pairwise Distribution Matrix', 
                      fontsize=16, fontweight='bold', y=1.02)
        
        plt.tight_layout()
        
        if save:
            filepath = self.output_dir / 'seaborn_pairgrid.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return g.fig
    
    # ---------- CATEGORICAL PLOTS ----------
    
    def plot_categorical_comparison(self, numerical_col: str,
                                   categorical_col: str,
                                   plot_type: str = 'box',
                                   save: bool = True) -> plt.Figure:
        """
        Create a categorical comparison plot.
        
        Parameters:
        -----------
        numerical_col : str
            Numerical column to compare
        categorical_col : str
            Categorical column for grouping
        plot_type : str
            'box', 'boxen', 'violin', 'point', 'bar'
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        fig, ax = plt.subplots(figsize=(12, 7))
        
        plot_functions = {
            'box': sns.boxplot,
            'boxen': sns.boxenplot,
            'violin': sns.violinplot,
            'point': sns.pointplot,
            'bar': sns.barplot
        }
        
        if plot_type not in plot_functions:
            print(f"  ⚠️ Plot type '{plot_type}' not recognized. Using 'box'.")
            plot_type = 'box'
        
        # Create plot
        plot_functions[plot_type](
            data=self.df,
            x=categorical_col,
            y=numerical_col,
            palette=self.palette,
            ax=ax
        )
        
        # Add statistical annotation
        stats_df = self.df.groupby(categorical_col)[numerical_col].agg(['mean', 'std', 'count']).round(2)
        stats_text = "Group Statistics:\n" + stats_df.to_string()
        ax.text(
            0.02, 0.98, stats_text,
            transform=ax.transAxes,
            fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8)
        )
        
        ax.set_title(f'{plot_type.title()} Plot: {numerical_col} by {categorical_col}',
                    fontsize=14, fontweight='bold')
        ax.set_xlabel(categorical_col, fontsize=12)
        ax.set_ylabel(numerical_col, fontsize=12)
        ax.tick_params(axis='x', rotation=45)
        ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        
        if save:
            filepath = self.output_dir / f'seaborn_{numerical_col}_by_{categorical_col}_{plot_type}.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return fig
    
    def plot_count_with_hue(self, categorical_col: str,
                           hue_col: str = None,
                           normalize: bool = False,
                           save: bool = True) -> plt.Figure:
        """
        Create a count plot with optional hue grouping.
        
        Parameters:
        -----------
        categorical_col : str
            Column to count
        hue_col : str
            Column for hue grouping
        normalize : bool
            Whether to show proportions instead of counts
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        fig, ax = plt.subplots(figsize=(12, 7))
        
        if normalize:
            # Calculate proportions
            if hue_col:
                # Proportions within each hue group
                sns.histplot(
                    data=self.df,
                    x=categorical_col,
                    hue=hue_col,
                    stat='proportion',
                    multiple='dodge',
                    shrink=0.8,
                    ax=ax
                )
                ylabel = 'Proportion within group'
            else:
                # Overall proportions
                sns.histplot(
                    data=self.df,
                    x=categorical_col,
                    stat='proportion',
                    shrink=0.8,
                    ax=ax
                )
                ylabel = 'Proportion'
        else:
            # Counts
            sns.countplot(
                data=self.df,
                x=categorical_col,
                hue=hue_col,
                palette=self.palette,
                ax=ax
            )
            ylabel = 'Count'
        
        # Add count labels on bars
        for p in ax.patches:
            height = p.get_height()
            if height > 0:
                ax.text(
                    p.get_x() + p.get_width() / 2.,
                    height + (height * 0.01),
                    f'{int(height)}',
                    ha='center',
                    va='bottom',
                    fontsize=9
                )
        
        ax.set_title(f'Distribution of {categorical_col}' + 
                    (f' by {hue_col}' if hue_col else ''),
                    fontsize=14, fontweight='bold')
        ax.set_xlabel(categorical_col, fontsize=12)
        ax.set_ylabel(ylabel, fontsize=12)
        ax.tick_params(axis='x', rotation=45)
        ax.grid(True, alpha=0.3, axis='y')
        
        plt.tight_layout()
        
        if save:
            suffix = 'proportions' if normalize else 'counts'
            hue_suffix = f'_{hue_col}' if hue_col else ''
            filepath = self.output_dir / f'seaborn_{categorical_col}{hue_suffix}_{suffix}.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return fig
    
    # ---------- REGRESSION AND CORRELATION ----------
    
    def plot_regression(self, x_col: str, y_col: str,
                       hue_col: str = None,
                       save: bool = True) -> plt.Figure:
        """
        Create a regression plot with confidence bands.
        
        Parameters:
        -----------
        x_col : str
            X-axis column
        y_col : str
            Y-axis column
        hue_col : str
            Column for hue grouping
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        fig, ax = plt.subplots(figsize=(10, 8))
        
        # Create regression plot
        sns.regplot(
            data=self.df,
            x=x_col,
            y=y_col,
            hue=hue_col,
            scatter_kws={'alpha': 0.4, 's': 30},
            line_kws={'linewidth': 2},
            ci=95,  # 95% confidence interval
            ax=ax
        )
        
        # Calculate and display correlation
        clean_data = self.df[[x_col, y_col]].dropna()
        if len(clean_data) > 1:
            pearson_r, pearson_p = stats.pearsonr(clean_data[x_col], clean_data[y_col])
            spearman_r, spearman_p = stats.spearmanr(clean_data[x_col], clean_data[y_col])
            
            corr_text = (
                f"Pearson r = {pearson_r:.3f} (p={pearson_p:.4f})\n"
                f"Spearman ρ = {spearman_r:.3f} (p={spearman_p:.4f})"
            )
            
            # Interpret correlation
            if abs(pearson_r) > 0.7:
                strength = "Strong"
            elif abs(pearson_r) > 0.4:
                strength = "Moderate"
            elif abs(pearson_r) > 0.2:
                strength = "Weak"
            else:
                strength = "Very weak"
            
            direction = "positive" if pearson_r > 0 else "negative"
            
            ax.text(
                0.02, 0.98, 
                f"{corr_text}\n{strength} {direction} relationship",
                transform=ax.transAxes,
                fontsize=10,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8)
            )
        
        ax.set_title(f'Regression: {y_col} vs {x_col}', 
                    fontsize=14, fontweight='bold')
        ax.set_xlabel(x_col, fontsize=12)
        ax.set_ylabel(y_col, fontsize=12)
        ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        
        if save:
            hue_suffix = f'_{hue_col}' if hue_col else ''
            filepath = self.output_dir / f'seaborn_regression_{x_col}_vs_{y_col}{hue_suffix}.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return fig
    
    def plot_correlation_heatmap(self, cols: list = None,
                                method: str = 'pearson',
                                mask_upper: bool = True,
                                annot: bool = True,
                                save: bool = True) -> plt.Figure:
        """
        Create a correlation heatmap with significance annotations.
        
        Parameters:
        -----------
        cols : list
            Columns to include (if None, uses all numerical)
        method : str
            'pearson', 'spearman', or 'kendall'
        mask_upper : bool
            Whether to mask the upper triangle
        annot : bool
            Whether to show correlation values
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        if cols is None:
            cols = self.numerical_cols
        
        # Compute correlation
        corr_data = self.df[cols].dropna()
        corr_matrix = corr_data.corr(method=method)
        
        # Compute p-values
        def calculate_pvalues(df):
            """Calculate p-values for correlation matrix."""
            dfcols = pd.DataFrame(columns=df.columns)
            pvalues = dfcols.transpose().join(dfcols, how='outer')
            for r in df.columns:
                for c in df.columns:
                    if r != c:
                        pvalues[c][r] = stats.pearsonr(df[r], df[c])[1]
                    else:
                        pvalues[c][r] = 0
            return pvalues
        
        pvalues = calculate_pvalues(corr_data)
        
        # Create figure
        fig, ax = plt.subplots(figsize=(12, 10))
        
        # Create mask for upper triangle
        mask = np.triu(np.ones_like(corr_matrix, dtype=bool)) if mask_upper else None
        
        # Create heatmap
        sns.heatmap(
            corr_matrix,
            mask=mask,
            annot=annot,
            fmt='.2f',
            cmap='RdBu_r',
            center=0,
            square=True,
            linewidths=0.5,
            cbar_kws={'shrink': 0.8},
            ax=ax
        )
        
        # Add significance asterisks
        if annot:
            for i in range(len(corr_matrix.columns)):
                for j in range(len(corr_matrix.columns)):
                    if not mask_upper or i <= j:
                        p_val = pvalues.iloc[i, j]
                        if p_val < 0.001:
                            sig = '***'
                        elif p_val < 0.01:
                            sig = '**'
                        elif p_val < 0.05:
                            sig = '*'
                        else:
                            sig = ''
                        if sig:
                            ax.text(
                                j + 0.5, i + 0.85, sig,
                                ha='center', va='center',
                                color='black', fontsize=8, fontweight='bold'
                            )
        
        ax.set_title(f'Correlation Heatmap ({method.title()})', 
                    fontsize=14, fontweight='bold')
        
        plt.tight_layout()
        
        if save:
            filepath = self.output_dir / f'seaborn_correlation_{method}_heatmap.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return fig
    
    # ---------- MULTI-PLOT GRIDS ----------
    
    def create_facet_grid(self, col: str, row: str = None,
                         plot_type: str = 'hist',
                         n_cols: int = 3,
                         save: bool = True) -> plt.Figure:
        """
        Create a FacetGrid for conditional relationships.
        
        FacetGrid creates multiple subplots for each combination
        of categorical variables, showing the distribution of a variable
        conditional on those categories.
        
        Parameters:
        -----------
        col : str
            Column to facet by (creates columns)
        row : str
            Column to facet by (creates rows)
        plot_type : str
            'hist', 'kde', 'box', 'violin', 'scatter'
        n_cols : int
            Number of columns for the grid
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        # Determine the variable to plot
        # For hist/kde, use a numerical column if available
        if plot_type in ['hist', 'kde']:
            # Use the first numerical column
            vars_to_plot = self.numerical_cols[0] if self.numerical_cols else None
            if vars_to_plot is None:
                print("  ⚠️ No numerical columns found for histogram")
                return None
        elif plot_type in ['box', 'violin']:
            # Need both a numerical and categorical column
            if not self.numerical_cols:
                print("  ⚠️ No numerical columns found")
                return None
            vars_to_plot = self.numerical_cols[0]
        else:  # scatter
            # Need two numerical columns
            if len(self.numerical_cols) < 2:
                print("  ⚠️ Need at least two numerical columns for scatter")
                return None
            vars_to_plot = self.numerical_cols[0]
        
        # Create the grid
        g = sns.FacetGrid(
            self.df,
            col=col,
            row=row,
            height=4,
            aspect=1.2,
            col_wrap=n_cols if row is None else None,
            margin_titles=True
        )
        
        # Map the plot type
        if plot_type == 'hist':
            g.map(sns.histplot, vars_to_plot, kde=True, edgecolor='black', linewidth=0.5)
            g.set_axis_labels(vars_to_plot, 'Count')
        elif plot_type == 'kde':
            g.map(sns.kdeplot, vars_to_plot, fill=True, alpha=0.6)
            g.set_axis_labels(vars_to_plot, 'Density')
        elif plot_type == 'box':
            # For box plots, we need to map differently
            g.map_dataframe(sns.boxplot, x=col, y=vars_to_plot)
            g.set_axis_labels(col, vars_to_plot)
        elif plot_type == 'violin':
            g.map_dataframe(sns.violinplot, x=col, y=vars_to_plot)
            g.set_axis_labels(col, vars_to_plot)
        elif plot_type == 'scatter':
            # Need a second numerical column for y
            if len(self.numerical_cols) >= 2:
                y_col = self.numerical_cols[1]
                g.map(sns.scatterplot, vars_to_plot, y_col, alpha=0.5)
                g.set_axis_labels(vars_to_plot, y_col)
            else:
                print("  ⚠️ Not enough numerical columns for scatter plot")
                return None
        
        # Add title
        title = f'Facet Grid: {plot_type.title()} of {vars_to_plot}'
        if col:
            title += f' by {col}'
        if row:
            title += f' and {row}'
        g.fig.suptitle(title, fontsize=14, fontweight='bold', y=1.02)
        
        plt.tight_layout()
        
        if save:
            filepath = self.output_dir / f'seaborn_facetgrid_{plot_type}_{col}{f"_{row}" if row else ""}.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return g.fig
    
    def create_joint_plot(self, x_col: str, y_col: str,
                         kind: str = 'scatter',
                         save: bool = True) -> plt.Figure:
        """
        Create a joint plot showing bivariate distribution.
        
        Joint plots combine univariate distributions (on the margins)
        with a bivariate plot (in the center).
        
        Parameters:
        -----------
        x_col : str
            X-axis column
        y_col : str
            Y-axis column
        kind : str
            'scatter', 'hex', 'kde', 'reg', 'resid'
        save : bool
            Whether to save the figure
            
        Returns:
        --------
        plt.Figure
            The matplotlib figure
        """
        # Create joint plot
        g = sns.jointplot(
            data=self.df,
            x=x_col,
            y=y_col,
            kind=kind,
            height=8,
            ratio=5,
            marginal_kws={'bins': 30, 'kde': True},
            joint_kws={'alpha': 0.5}
        )
        
        # Add correlation annotation
        clean_data = self.df[[x_col, y_col]].dropna()
        if len(clean_data) > 1:
            pearson_r, _ = stats.pearsonr(clean_data[x_col], clean_data[y_col])
            spearman_r, _ = stats.spearmanr(clean_data[x_col], clean_data[y_col])
            
            corr_text = f'Pearson r = {pearson_r:.3f}\nSpearman ρ = {spearman_r:.3f}'
            g.fig.text(
                0.82, 0.82, corr_text,
                fontsize=10,
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8)
            )
        
        g.fig.suptitle(f'Joint Distribution: {x_col} vs {y_col}',
                      fontsize=14, fontweight='bold', y=1.02)
        
        plt.tight_layout()
        
        if save:
            filepath = self.output_dir / f'seaborn_joint_{x_col}_vs_{y_col}_{kind}.png'
            plt.savefig(filepath, dpi=300, bbox_inches='tight')
            print(f"  ✅ Saved: {filepath}")
        
        return g.fig
    
    # ---------- COMPREHENSIVE ANALYSIS ----------
    
    def analyze_all(self, save_figures: bool = True) -> dict:
        """
        Run a comprehensive set of statistical visualizations.
        
        This method generates a complete set of visualizations
        for understanding the dataset.
        
        Parameters:
        -----------
        save_figures : bool
            Whether to save figures
            
        Returns:
        --------
        dict
            Dictionary of generated figures
        """
        results = {'figures': []}
        
        print("\n" + "=" * 60)
        print("SEABORN STATISTICAL VISUALIZATIONS - STARTING")
        print("=" * 60)
        
        # 1. Distribution plots for numerical columns
        print("\n📊 Creating distribution plots...")
        for col in self.numerical_cols[:5]:  # Limit to 5 for speed
            if col not in ['customer_id']:
                try:
                    fig = self.plot_histogram_with_kde(col, save=save_figures)
                    results['figures'].append(('histogram', col, fig))
                except Exception as e:
                    print(f"  ⚠️ Error plotting {col}: {e}")
        
        # 2. Categorical comparisons
        print("\n📊 Creating categorical comparisons...")
        if self.categorical_cols and self.numerical_cols:
            for cat_col in self.categorical_cols[:2]:  # Limit to 2
                for num_col in self.numerical_cols[:2]:  # Limit to 2
                    try:
                        fig = self.plot_violin_with_box(num_col, cat_col, save=save_figures)
                        results['figures'].append(('violin', f'{num_col}_by_{cat_col}', fig))
                    except Exception as e:
                        print(f"  ⚠️ Error plotting {num_col} vs {cat_col}: {e}")
        
        # 3. Regression plots
        print("\n📊 Creating regression plots...")
        if len(self.numerical_cols) >= 2:
            # Find two columns with reasonable correlation
            corr_data = self.df[self.numerical_cols].dropna()
            if len(corr_data.columns) >= 2:
                corr_matrix = corr_data.corr()
                # Find strongest correlation
                max_corr = 0
                best_pair = None
                for i in range(len(corr_matrix.columns)):
                    for j in range(i+1, len(corr_matrix.columns)):
                        corr_val = abs(corr_matrix.iloc[i, j])
                        if corr_val > max_corr and corr_val < 1:
                            max_corr = corr_val
                            best_pair = (corr_matrix.columns[i], corr_matrix.columns[j])
                
                if best_pair:
                    try:
                        fig = self.plot_regression(best_pair[0], best_pair[1], save=save_figures)
                        results['figures'].append(('regression', f'{best_pair[0]}_vs_{best_pair[1]}', fig))
                    except Exception as e:
                        print(f"  ⚠️ Error creating regression plot: {e}")
        
        # 4. Correlation heatmap
        print("\n📊 Creating correlation heatmap...")
        if len(self.numerical_cols) >= 3:
            try:
                fig = self.plot_correlation_heatmap(save=save_figures)
                results['figures'].append(('heatmap', 'correlation', fig))
            except Exception as e:
                print(f"  ⚠️ Error creating heatmap: {e}")
        
        # 5. Pair grid
        print("\n📊 Creating pair grid...")
        if len(self.numerical_cols) >= 3:
            try:
                fig = self.plot_pairwise_distribution(save=save_figures)
                results['figures'].append(('pairgrid', 'all', fig))
            except Exception as e:
                print(f"  ⚠️ Error creating pair grid: {e}")
        
        # 6. Facet grid (if categorical columns exist)
        if self.categorical_cols and self.numerical_cols:
            print("\n📊 Creating facet grid...")
            cat_col = self.categorical_cols[0]
            if self.df[cat_col].nunique() <= 5:  # Only if reasonable number of categories
                try:
                    fig = self.create_facet_grid(col=cat_col, plot_type='hist', save=save_figures)
                    results['figures'].append(('facetgrid', cat_col, fig))
                except Exception as e:
                    print(f"  ⚠️ Error creating facet grid: {e}")
        
        print("\n" + "=" * 60)
        print("SEABORN VISUALIZATIONS - COMPLETE")
        print("=" * 60)
        print(f"\n✅ Generated {len(results['figures'])} visualizations")
        
        return results


# ---------- UTILITY FUNCTIONS ----------

def run_seaborn_analysis(data_path: str = "data/customer_data.csv",
                        output_dir: str = "outputs/figures") -> dict:
    """
    Convenience function to run Seaborn analysis.
    
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
    visualizer = SeabornVisualizer(df, output_dir=output_dir)
    
    # Run analysis
    results = visualizer.analyze_all(save_figures=True)
    
    return results


if __name__ == "__main__":
    results = run_seaborn_analysis()
```

---

##### Step 2: Create Advanced Seaborn Examples

**File:** `src/advanced_seaborn_examples.py`
```python
"""
Advanced Seaborn Visualization Examples

Demonstrates advanced Seaborn techniques including:
- Customizing Seaborn with Matplotlib
- Creating publication-ready statistical plots
- Multi-plot grid customization
- Statistical annotations and tests
"""

import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import pandas as pd
from pathlib import Path
from scipy import stats
from seaborn_toolkit import SeabornVisualizer


def demonstrate_statistical_annotations(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate statistical annotations on Seaborn plots.
    
    Shows how to add:
    - Significance tests (t-test, ANOVA)
    - Effect sizes
    - Confidence intervals
    """
    
    print("\n📊 Creating plots with statistical annotations...")
    
    df = pd.read_csv(data_path)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # 1. Boxplot with t-test annotation
    ax1 = axes[0, 0]
    # Compare two groups (e.g., male vs female for order frequency)
    male_orders = df[df['gender'] == 'Male']['order_frequency'].dropna()
    female_orders = df[df['gender'] == 'Female']['order_frequency'].dropna()
    
    # Perform t-test
    t_stat, p_val = stats.ttest_ind(male_orders, female_orders)
    
    sns.boxplot(data=df, x='gender', y='order_frequency', ax=ax1, palette='Set2')
    ax1.set_title(f'Order Frequency by Gender\nT-test: p={p_val:.4f} {"(significant)" if p_val < 0.05 else "(not significant)"}')
    ax1.set_ylabel('Order Frequency')
    
    # 2. Bar plot with error bars and effect size
    ax2 = axes[0, 1]
    # Compare means across income groups
    income_means = df.groupby('income_bracket')['avg_order_value'].mean()
    income_sems = df.groupby('income_bracket')['avg_order_value'].sem()
    
    ax2.bar(income_means.index, income_means.values, yerr=income_sems.values,
            capsize=5, color='steelblue', alpha=0.7, edgecolor='black')
    ax2.set_title('Avg Order Value by Income\n(Error bars = SEM)')
    ax2.set_xlabel('Income Bracket')
    ax2.set_ylabel('Avg Order Value ($)')
    ax2.tick_params(axis='x', rotation=45)
    
    # 3. Regression with confidence bands
    ax3 = axes[1, 0]
    sns.regplot(data=df, x='time_on_site', y='pages_viewed', 
               ax=ax3, scatter_kws={'alpha': 0.3}, 
               line_kws={'color': 'red'}, ci=95)
    ax3.set_title('Time on Site vs Pages Viewed\n(95% Confidence Band)')
    
    # 4. Violin with significance bridge
    ax4 = axes[1, 1]
    # Compare ratings across city tiers
    city_order = [1, 2, 3]
    city_labels = ['Major Metro', 'Mid-size', 'Small City']
    df['city_tier_label'] = df['city_tier'].map({1: 'Major Metro', 2: 'Mid-size', 3: 'Small City'})
    sns.violinplot(data=df, x='city_tier_label', y='customer_rating', 
                  ax=ax4, palette='viridis', inner='quartile')
    ax4.set_title('Customer Rating by City Tier')
    ax4.set_xlabel('City Tier')
    ax4.set_ylabel('Customer Rating')
    
    plt.suptitle('Statistical Annotations on Seaborn Plots', fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / "seaborn_statistical_annotations.png"
    plt.savefig(filepath, dpi=300, bbox_inches='tight')
    print(f"  ✅ Saved: {filepath}")
    
    plt.show()
    
    return fig


def demonstrate_custom_palettes(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate custom color palettes and styling in Seaborn.
    """
    
    print("\n🎨 Creating plots with custom palettes...")
    
    df = pd.read_csv(data_path)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # 1. Sequential palette (order_frequency by category)
    ax1 = axes[0, 0]
    # Create ordered palette based on mean values
    cat_means = df.groupby('favorite_category')['order_frequency'].mean().sort_values()
    palette = sns.color_palette('Blues_d', n_colors=len(cat_means))
    # Reverse palette so highest value gets darkest color
    palette = list(reversed(palette))
    sns.boxplot(data=df, x='favorite_category', y='order_frequency',
               order=cat_means.index, palette=palette, ax=ax1)
    ax1.set_title('Order Frequency by Category\n(Sequential palette by mean)')
    ax1.tick_params(axis='x', rotation=45)
    
    # 2. Diverging palette (rating vs city tier)
    ax2 = axes[0, 1]
    # Create a pivot table
    pivot = df.pivot_table(values='customer_rating', 
                          index='favorite_category', 
                          columns='city_tier',
                          aggfunc='mean')
    sns.heatmap(pivot, annot=True, fmt='.2f', cmap='RdBu_r', 
               center=3.5, ax=ax2, cbar_kws={'label': 'Mean Rating'})
    ax2.set_title('Rating: Category × City Tier\n(Diverging palette)')
    
    # 3. Custom qualitative palette
    ax3 = axes[1, 0]
    custom_palette = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
    sns.violinplot(data=df, x='income_bracket', y='avg_order_value',
                  palette=custom_palette, ax=ax3)
    ax3.set_title('Order Value by Income\n(Custom qualitative palette)')
    ax3.tick_params(axis='x', rotation=45)
    
    # 4. Cyclical palette (for multiple categories)
    ax4 = axes[1, 1]
    # Create categorical grouping
    df['age_group'] = pd.cut(df['age'], bins=[0, 25, 35, 45, 55, 100],
                            labels=['<25', '25-35', '35-45', '45-55', '55+'])
    sns.boxplot(data=df, x='age_group', y='order_frequency',
               palette='husl', ax=ax4)
    ax4.set_title('Order Frequency by Age Group\n(Cyclical palette)')
    
    plt.suptitle('Custom Palettes and Styling in Seaborn', fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    # Save
    output_dir = Path("outputs/figures")
    output_dir.mkdir(parents=True, exist_ok=True)
    filepath = output_dir / "seaborn_custom_palettes.png"
    plt.savefig(filepath, dpi=300, bbox_inches='tight')
    print(f"  ✅ Saved: {filepath}")
    
    plt.show()
    
    return fig


def demonstrate_multiple_statistical_tests(data_path: str = "data/customer_data.csv"):
    """
    Demonstrate multiple statistical tests integrated with Seaborn.
    
    Shows:
    - ANOVA
    - Correlation tests
    - Distribution tests
    """
    
    print("\n📈 Demonstrating statistical tests...")
    
    df = pd.read_csv(data_path)
    
    # 1. ANOVA test for income effect on order value
    income_groups = [df[df['income_bracket'] == bracket]['avg_order_value'].dropna()
                    for bracket in df['income_bracket'].unique()]
    
    f_stat, p_val = stats.f_oneway(*income_groups)
    print(f"ANOVA: Income effect on Order Value")
    print(f"  F-statistic: {f_stat:.3f}")
    print(f"  p-value: {p_val:.4f}")
    print(f"  {'✅ Significant at p<0.05' if p_val < 0.05 else '❌ Not significant'}")
    
    # 2. Correlation tests
    print("\nCorrelation tests:")
    for col1, col2 in [('age', 'order_frequency'), ('income_numeric', 'avg_order_value')]:
        if col1 in df.columns and col2 in df.columns:
            clean_data = df[[col1, col2]].dropna()
            pearson_r, pearson_p = stats.pearsonr(clean_data[col1], clean_data[col2])
            spearman_r, spearman_p = stats.spearmanr(clean_data[col1], clean_data[col2])
            print(f"  {col1} vs {col2}:")
            print(f"    Pearson: r={pearson_r:.3f}, p={pearson_p:.4f}")
            print(f"    Spearman: r={spearman_r:.3f}, p={spearman_p:.4f}")
    
    # 3. Distribution tests (normality)
    print("\nDistribution tests:")
    for col in ['age', 'order_frequency', 'avg_order_value']:
        if col in df.columns:
            data = df[col].dropna()
            if len(data) > 8:  # Need at least 8 samples
                shapiro_stat, shapiro_p = stats.shapiro(data)
                print(f"  {col}: Shapiro-Wilk p={shapiro_p:.4f} {'(normal)' if shapiro_p > 0.05 else '(non-normal)'}")
    
    return


def run_all_seaborn_examples(data_path: str = "data/customer_data.csv"):
    """
    Run all Seaborn demonstrations.
    """
    
    print("=" * 60)
    print("SEABORN ADVANCED EXAMPLES")
    print("=" * 60)
    
    # Run basic analysis
    print("\n🔍 Running basic Seaborn analysis...")
    run_seaborn_analysis(data_path)
    
    # Run advanced examples
    demonstrate_statistical_annotations(data_path)
    demonstrate_custom_palettes(data_path)
    demonstrate_multiple_statistical_tests(data_path)
    
    print("\n" + "=" * 60)
    print("ALL SEABORN EXAMPLES COMPLETE")
    print("=" * 60)
    print("\n📁 Figures saved to: outputs/figures/")
    print("  • seaborn_*.png (multiple files)")
    print("  • seaborn_statistical_annotations.png")
    print("  • seaborn_custom_palettes.png")


if __name__ == "__main__":
    run_all_seaborn_examples()
```

---

#### The Verification

**Verification 1: Run the Seaborn Analysis**

```bash
# Run the main analysis
python src/seaborn_toolkit.py

# Run advanced examples
python src/advanced_seaborn_examples.py
```

**Verification 2: Check Generated Figures**

```bash
# List all generated Seaborn figures
ls -la outputs/figures/seaborn_*.png
```

You should see multiple figures including:
- `seaborn_*_histogram.png`
- `seaborn_*_by_*_violin.png`
- `seaborn_pairgrid.png`
- `seaborn_correlation_heatmap.png`
- `seaborn_facetgrid_*.png`
- `seaborn_joint_*.png`
- `seaborn_statistical_annotations.png`
- `seaborn_custom_palettes.png`

**Verification 3: Validate Statistical Accuracy**

**File:** `src/validate_seaborn_stats.py`
```python
"""
Validate statistical accuracy of Seaborn visualizations.
"""

import pandas as pd
import numpy as np
from scipy import stats

def validate_statistics():
    """Validate statistical computations in Seaborn visualizations."""
    
    print("=" * 60)
    print("VALIDATING SEABORN STATISTICS")
    print("=" * 60)
    
    df = pd.read_csv("data/customer_data.csv")
    
    print("\n🔍 Validating correlation computations...")
    
    # Check a known correlation: time_on_site vs pages_viewed
    # These should be strongly positively correlated (we designed them that way)
    clean_data = df[['time_on_site', 'pages_viewed']].dropna()
    pearson_r, pearson_p = stats.pearsonr(clean_data['time_on_site'], clean_data['pages_viewed'])
    
    print(f"  Time on Site vs Pages Viewed:")
    print(f"    Pearson r = {pearson_r:.3f}")
    print(f"    p-value = {pearson_p:.4f}")
    
    if pearson_r > 0.5:
        print("    ✅ Strong positive correlation (as expected)")
    else:
        print("    ⚠️ Expected stronger correlation")
    
    # Validate t-test for gender difference in order frequency
    male_orders = df[df['gender'] == 'Male']['order_frequency'].dropna()
    female_orders = df[df['gender'] == 'Female']['order_frequency'].dropna()
    
    t_stat, p_val = stats.ttest_ind(male_orders, female_orders)
    print(f"\n  Gender difference in Order Frequency:")
    print(f"    T-statistic = {t_stat:.3f}")
    print(f"    p-value = {p_val:.4f}")
    
    if p_val > 0.05:
        print("    ✅ No significant difference (as expected)")
    else:
        print("    ⚠️ Unexpected significant difference")
    
    print("\n" + "=" * 60)
    print("VALIDATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    validate_statistics()
```

Run it:
```bash
python src/validate_seaborn_stats.py
```

---

#### What We've Accomplished

In this part, we've:

1. ✅ Built a comprehensive `SeabornVisualizer` class with:
   - Distribution plots (histograms with KDE)
   - Categorical comparisons (violin, box, point, bar)
   - Regression plots with confidence bands
   - Correlation heatmaps with significance annotations
   - Multi-plot grids (PairGrid, FacetGrid)
   - Joint plots for bivariate analysis

2. ✅ Demonstrated advanced Seaborn techniques:
   - Statistical annotations (t-test, ANOVA)
   - Custom color palettes (sequential, diverging, qualitative)
   - Confidence intervals and error bars
   - Multiple statistical tests integrated with visualizations

3. ✅ Integrated Seaborn with Matplotlib:
   - Used Matplotlib for fine-tuning
   - Combined Seaborn's statistical power with Matplotlib's control
   - Created publication-ready figures

4. ✅ Learned best practices:
   - Choosing appropriate plot types for data
   - Adding statistical annotations
   - Using color effectively
   - Creating multi-panel figures

---

#### Deep Dive Reference: Statistical Plot Selection Guide

**Choosing the Right Plot Type**

| Data Type | Question | Recommended Plot |
|-----------|----------|------------------|
| **1 Numerical** | What's the distribution? | Histogram + KDE |
| **1 Numerical** | How skewed is it? | Boxplot (with outliers) |
| **1 Categorical** | What are the proportions? | Countplot, Pie chart |
| **2 Numerical** | What's the relationship? | Scatter plot + Regression |
| **2 Numerical** | What's the correlation? | Heatmap |
| **1 Num + 1 Cat** | How does distribution vary? | Violin/Boxplot + Strip |
| **1 Num + 2 Cat** | How do categories interact? | FacetGrid, Catplot |
| **Multiple Num** | What are all relationships? | PairGrid |
| **Multiple Num + Cat** | How do patterns vary by category? | PairGrid with hue |

**Statistical Test Selection**

| Comparison | Test | When to Use |
|------------|------|-------------|
| 2 groups (numeric) | T-test | Normal data |
| 2 groups (numeric) | Mann-Whitney U | Non-normal data |
| >2 groups (numeric) | ANOVA | Normal data |
| >2 groups (numeric) | Kruskal-Wallis | Non-normal data |
| 2 categorical | Chi-squared | Counts |
| Categorical association | Cramér's V | Association strength |
| Correlation | Pearson | Linear, normal |
| Correlation | Spearman | Non-linear, ordinal |

---

#### Next Up

In **Part 3: Altair - Declarative Visualization with Vega-Lite**, we'll learn a completely different approach to visualization. Instead of imperatively building plots step-by-step, Altair lets you declare what you want to see using a grammar of graphics. This is especially powerful for creating interactive visualizations and reproducible analysis.
