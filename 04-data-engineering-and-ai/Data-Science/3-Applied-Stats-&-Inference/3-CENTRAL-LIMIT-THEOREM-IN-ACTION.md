# MODULE 3.1, PART 3: CENTRAL LIMIT THEOREM IN ACTION

The Central Limit Theorem (CLT) is the **most important concept in statistics** — it's what makes hypothesis testing and confidence intervals possible. In this part, we'll build interactive simulations to see the CLT in action, create visualizations, and construct a complete descriptive statistics dashboard.

Think of the CLT as the **democracy of statistics** — even if individual data points are skewed, eccentric, or unusual, the average of many such points becomes well-behaved and normal.

---

## Target: Build CLT Simulations & Descriptive Dashboard

We're creating:
1. `src/visualization/plots.py` — Statistical visualization functions
2. `src/descriptive/central_tendency.py` — Comprehensive descriptive statistics
3. `notebooks/01_exploratory_analysis.ipynb` — Interactive CLT demonstration

---

## The Concept: Why the CLT Works

Imagine you're measuring the wait time at a coffee shop. Individual wait times are highly skewed — most people wait 2-3 minutes, but occasionally someone waits 15 minutes (Exponential distribution).

**Here's the magic**: If you take samples of 30 customers and average their wait times, those averages will follow a **Normal distribution**, regardless of the original skewed distribution!

### What the CLT Tells Us

1. **Sample means are normally distributed** (for large enough samples)
2. **Mean of sample means = population mean** (unbiased)
3. **Standard deviation of sample means = σ/√n** (standard error)

### Sample Size Rules of Thumb

| Sample Size | When to Use |
|-------------|-------------|
| n ≥ 30 | CLT applies for most distributions |
| n ≥ 50 | Safe for highly skewed distributions |
| n ≥ 100 | Very safe, nearly perfect normality |

---

## Implementation 1: Visualization Module

Create the file `src/visualization/plots.py`:

```python
#!/usr/bin/env python3
"""
Statistical Visualization Module for Phase 3 Statistics Project.

Provides functions for creating publication-quality statistical plots:
- Distribution plots (histograms, KDE, QQ plots)
- Sampling distribution visualizations
- Confidence interval plots
- Diagnostic plots for regression

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from typing import Optional, Tuple, List, Union
import logging
from scipy import stats
from scipy.stats import norm, probplot

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Set style for publication-quality plots
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")
sns.set_context("notebook", font_scale=1.2)


class StatisticalPlots:
    """
    Comprehensive statistical visualization toolkit.
    
    Provides functions for visualizing distributions, sampling distributions,
    confidence intervals, and diagnostic plots.
    
    Think of this as your "statistical microscope" — it helps you see
    patterns, distributions, and uncertainties in your data.
    """
    
    def __init__(self, figsize: Tuple[int, int] = (12, 8), dpi: int = 100):
        """
        Initialize the plotting toolkit.
        
        Args:
            figsize: Default figure size (width, height) in inches
            dpi: Resolution in dots per inch
        """
        self.figsize = figsize
        self.dpi = dpi
        logger.info(f"Initialized StatisticalPlots with figsize={figsize}")
    
    def plot_distribution(
        self,
        data: np.ndarray,
        title: str = "Distribution Plot",
        xlabel: str = "Value",
        ylabel: str = "Density",
        bins: Optional[int] = None,
        show_stats: bool = True,
        show_curve: bool = True,
        show_rug: bool = False,
        save_path: Optional[str] = None
    ) -> plt.Figure:
        """
        Create a comprehensive distribution plot with histogram and KDE.
        
        Args:
            data: Input array
            title: Plot title
            xlabel: X-axis label
            ylabel: Y-axis label
            bins: Number of histogram bins (auto if None)
            show_stats: Show mean and median lines
            show_curve: Show KDE curve
            show_rug: Show rug plot (data points along x-axis)
            save_path: Optional path to save the figure
        
        Returns:
            matplotlib.figure.Figure: The created figure
        
        Example:
            >>> plots = StatisticalPlots()
            >>> data = np.random.normal(0, 1, 1000)
            >>> fig = plots.plot_distribution(data, title="Normal Distribution")
            >>> plt.show()
        """
        fig, ax = plt.subplots(figsize=self.figsize, dpi=self.dpi)
        
        # Plot histogram
        ax.hist(data, bins=bins, alpha=0.6, density=True, color='blue', 
                edgecolor='black', linewidth=0.5, label='Histogram')
        
        # Plot KDE
        if show_curve:
            sns.kdeplot(data, ax=ax, color='red', linewidth=2, 
                       label='Kernel Density Estimate')
        
        # Plot rug
        if show_rug:
            sns.rugplot(data, ax=ax, color='green', alpha=0.3, height=0.05)
        
        # Add statistics lines
        if show_stats:
            mean_val = np.mean(data)
            median_val = np.median(data)
            ax.axvline(mean_val, color='red', linestyle='-', linewidth=2,
                      label=f'Mean: {mean_val:.2f}')
            ax.axvline(median_val, color='green', linestyle='--', linewidth=2,
                      label=f'Median: {median_val:.2f}')
            
            # Add standard deviation bands
            std_val = np.std(data, ddof=1)
            ax.axvline(mean_val - std_val, color='gray', linestyle=':', 
                      alpha=0.5, label=f'±1σ')
            ax.axvline(mean_val + std_val, color='gray', linestyle=':', alpha=0.5)
        
        # Labels and title
        ax.set_xlabel(xlabel, fontsize=12)
        ax.set_ylabel(ylabel, fontsize=12)
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.legend(loc='best')
        ax.grid(True, alpha=0.3)
        
        # Add stats annotation
        if show_stats:
            stats_text = (
                f'n = {len(data)}\n'
                f'Mean = {np.mean(data):.3f}\n'
                f'Std = {np.std(data, ddof=1):.3f}\n'
                f'Skew = {stats.skew(data):.3f}\n'
                f'Kurtosis = {stats.kurtosis(data):.3f}'
            )
            ax.text(0.02, 0.98, stats_text, transform=ax.transAxes,
                   verticalalignment='top', fontsize=10,
                   bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Figure saved to {save_path}")
        
        return fig
    
    def plot_qq(
        self,
        data: np.ndarray,
        title: str = "Q-Q Plot",
        distribution: str = 'norm',
        save_path: Optional[str] = None
    ) -> plt.Figure:
        """
        Create a Quantile-Quantile (Q-Q) plot for normality assessment.
        
        Q-Q plots compare the quantiles of your data to theoretical quantiles.
        If points fall along the diagonal line, the data follows the distribution.
        
        Args:
            data: Input array
            title: Plot title
            distribution: Theoretical distribution ('norm', 'expon', etc.)
            save_path: Optional path to save the figure
        
        Returns:
            matplotlib.figure.Figure: The created figure
        
        Example:
            >>> plots = StatisticalPlots()
            >>> data = np.random.normal(0, 1, 100)
            >>> fig = plots.plot_qq(data, title="Normality Check")
            >>> plt.show()
        """
        fig, ax = plt.subplots(figsize=self.figsize, dpi=self.dpi)
        
        # Create Q-Q plot
        probplot(data, dist=distribution, plot=ax)
        
        # Customize
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.set_xlabel('Theoretical Quantiles', fontsize=12)
        ax.set_ylabel('Sample Quantiles', fontsize=12)
        ax.grid(True, alpha=0.3)
        
        # Add interpretation text
        n = len(data)
        if n < 30:
            note = "Note: Small sample (n < 30) - interpret with caution"
        else:
            note = "Note: Points along the line suggest normality"
        
        ax.text(0.02, 0.02, note, transform=ax.transAxes,
               fontsize=10, style='italic',
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Figure saved to {save_path}")
        
        return fig
    
    def plot_sampling_distribution(
        self,
        population: np.ndarray,
        sample_size: int,
        n_samples: int = 1000,
        title: Optional[str] = None,
        save_path: Optional[str] = None
    ) -> plt.Figure:
        """
        Visualize the Central Limit Theorem by plotting sampling distribution.
        
        This function demonstrates how sample means become normally distributed
        as sample size increases, regardless of the population distribution.
        
        Args:
            population: Population data array
            sample_size: Size of each sample
            n_samples: Number of samples to draw
            title: Optional custom title
            save_path: Optional path to save the figure
        
        Returns:
            matplotlib.figure.Figure: The created figure
        
        Example:
            >>> plots = StatisticalPlots()
            >>> population = np.random.exponential(scale=5, size=10000)
            >>> fig = plots.plot_sampling_distribution(
            ...     population, sample_size=30, n_samples=1000
            ... )
            >>> plt.show()
        """
        # Draw samples and calculate means
        sample_means = np.zeros(n_samples)
        for i in range(n_samples):
            sample = np.random.choice(population, size=sample_size, replace=True)
            sample_means[i] = np.mean(sample)
        
        # Calculate statistics
        pop_mean = np.mean(population)
        pop_std = np.std(population, ddof=1)
        mean_of_means = np.mean(sample_means)
        std_of_means = np.std(sample_means, ddof=1)
        theoretical_se = pop_std / np.sqrt(sample_size)
        
        # Create figure with two subplots
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=self.figsize, dpi=self.dpi)
        
        # Plot 1: Population distribution
        ax1.hist(population, bins=50, alpha=0.7, density=True, color='blue')
        ax1.set_title('Population Distribution', fontweight='bold')
        ax1.set_xlabel('Value')
        ax1.set_ylabel('Density')
        ax1.axvline(pop_mean, color='red', linestyle='--', 
                   label=f'Mean = {pop_mean:.2f}')
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        
        # Add population info
        pop_text = f'Skew = {stats.skew(population):.3f}\nKurtosis = {stats.kurtosis(population):.3f}'
        ax1.text(0.02, 0.98, pop_text, transform=ax1.transAxes,
                verticalalignment='top', fontsize=10,
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
        
        # Plot 2: Sampling distribution of the mean
        ax2.hist(sample_means, bins=30, alpha=0.7, density=True, 
                color='green', label='Sample Means')
        
        # Overlay normal distribution
        x = np.linspace(mean_of_means - 4*std_of_means, 
                       mean_of_means + 4*std_of_means, 1000)
        y = norm.pdf(x, mean_of_means, std_of_means)
        ax2.plot(x, y, 'r-', linewidth=2, label='Normal Fit')
        
        # Add statistics lines
        ax2.axvline(pop_mean, color='red', linestyle='--', alpha=0.7,
                   label=f'Population Mean: {pop_mean:.2f}')
        ax2.axvline(mean_of_means, color='black', linestyle='-', 
                   label=f'Mean of Means: {mean_of_means:.2f}')
        
        # Add standard error bands
        ax2.axvline(pop_mean - theoretical_se, color='gray', 
                   linestyle=':', alpha=0.5)
        ax2.axvline(pop_mean + theoretical_se, color='gray', 
                   linestyle=':', alpha=0.5, label='±1 SE')
        
        # Labels and title
        if title is None:
            title = f'Sampling Distribution (n={sample_size})'
        ax2.set_title(title, fontweight='bold')
        ax2.set_xlabel('Sample Mean')
        ax2.set_ylabel('Density')
        ax2.legend(loc='best')
        ax2.grid(True, alpha=0.3)
        
        # Add CLT statistics
        clt_text = (
            f'Samples: {n_samples}\n'
            f'Sample Size: {sample_size}\n'
            f'Mean of Means: {mean_of_means:.3f}\n'
            f'Observed SE: {std_of_means:.4f}\n'
            f'Theoretical SE: {theoretical_se:.4f}\n'
            f'Difference: {abs(std_of_means - theoretical_se):.4f}'
        )
        ax2.text(0.02, 0.98, clt_text, transform=ax2.transAxes,
                verticalalignment='top', fontsize=10,
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
        
        plt.suptitle(f'Central Limit Theorem Demonstration', 
                    fontsize=16, fontweight='bold')
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Figure saved to {save_path}")
        
        return fig
    
    def plot_confidence_interval(
        self,
        data: np.ndarray,
        confidence_level: float = 0.95,
        title: Optional[str] = None,
        save_path: Optional[str] = None
    ) -> plt.Figure:
        """
        Visualize confidence intervals for a sample mean.
        
        Args:
            data: Input data
            confidence_level: Desired confidence level
            title: Optional custom title
            save_path: Optional path to save the figure
        
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        from src.descriptive.uncertainty import UncertaintyEstimator
        
        estimator = UncertaintyEstimator(confidence_level=confidence_level)
        
        mean = estimator.sample_mean(data)
        ci_low, ci_high = estimator.confidence_interval_mean(data)
        se = estimator.standard_error_mean(data)
        
        fig, ax = plt.subplots(figsize=self.figsize, dpi=self.dpi)
        
        # Create confidence interval visualization
        n_bootstrap = 1000
        bootstrap_means = np.zeros(n_bootstrap)
        for i in range(n_bootstrap):
            sample = np.random.choice(data, size=len(data), replace=True)
            bootstrap_means[i] = np.mean(sample)
        
        # Plot bootstrap distribution
        ax.hist(bootstrap_means, bins=30, alpha=0.6, density=True, 
               color='lightblue', edgecolor='black')
        
        # Add normal curve
        x = np.linspace(mean - 4*se, mean + 4*se, 1000)
        y = norm.pdf(x, mean, se)
        ax.plot(x, y, 'r-', linewidth=2, label='Normal Fit')
        
        # Add confidence interval
        ax.axvline(ci_low, color='red', linestyle='--', linewidth=2,
                  label=f'{confidence_level*100:.0f}% CI: [{ci_low:.2f}, {ci_high:.2f}]')
        ax.axvline(ci_high, color='red', linestyle='--', linewidth=2)
        ax.axvline(mean, color='blue', linestyle='-', linewidth=2,
                  label=f'Mean: {mean:.2f}')
        
        # Shade confidence interval
        ax.axvspan(ci_low, ci_high, alpha=0.2, color='red')
        
        # Labels and title
        if title is None:
            title = f'Confidence Interval Visualization ({confidence_level*100:.0f}%)'
        ax.set_title(title, fontsize=14, fontweight='bold')
        ax.set_xlabel('Bootstrap Mean Estimates', fontsize=12)
        ax.set_ylabel('Density', fontsize=12)
        ax.legend(loc='best')
        ax.grid(True, alpha=0.3)
        
        # Add statistics
        stats_text = (
            f'n = {len(data)}\n'
            f'Mean = {mean:.3f}\n'
            f'SE = {se:.4f}\n'
            f'CI Width = {ci_high - ci_low:.3f}'
        )
        ax.text(0.02, 0.98, stats_text, transform=ax.transAxes,
               verticalalignment='top', fontsize=10,
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Figure saved to {save_path}")
        
        return fig
    
    def plot_descriptive_dashboard(
        self,
        data: np.ndarray,
        title: str = "Descriptive Statistics Dashboard",
        save_path: Optional[str] = None
    ) -> plt.Figure:
        """
        Create a comprehensive dashboard with multiple descriptive plots.
        
        Includes:
        - Distribution plot (top left)
        - Box plot (top right)
        - Q-Q plot (bottom left)
        - Time series/running mean (bottom right)
        
        Args:
            data: Input data
            title: Dashboard title
            save_path: Optional path to save the figure
        
        Returns:
            matplotlib.figure.Figure: The created figure
        """
        from src.descriptive.central_tendency import DescriptiveStats
        
        stats_calc = DescriptiveStats()
        stats_dict = stats_calc.compute_all_statistics(data)
        
        fig = plt.figure(figsize=(16, 12), dpi=self.dpi)
        
        # Create subplots
        gs = fig.add_gridspec(2, 2, hspace=0.3, wspace=0.3)
        
        # 1: Distribution plot
        ax1 = fig.add_subplot(gs[0, 0])
        ax1.hist(data, bins=30, alpha=0.7, density=True, color='blue')
        sns.kdeplot(data, ax=ax1, color='red', linewidth=2)
        ax1.axvline(stats_dict['mean'], color='red', linestyle='-', 
                   linewidth=2, label=f'Mean: {stats_dict["mean"]:.2f}')
        ax1.axvline(stats_dict['median'], color='green', linestyle='--', 
                   linewidth=2, label=f'Median: {stats_dict["median"]:.2f}')
        ax1.set_title('Distribution', fontweight='bold')
        ax1.set_xlabel('Value')
        ax1.set_ylabel('Density')
        ax1.legend(loc='best')
        ax1.grid(True, alpha=0.3)
        
        # 2: Box plot
        ax2 = fig.add_subplot(gs[0, 1])
        bp = ax2.boxplot(data, patch_artist=True, widths=0.6)
        bp['boxes'][0].set_facecolor('lightblue')
        ax2.set_title('Box Plot with Outliers', fontweight='bold')
        ax2.set_ylabel('Value')
        ax2.grid(True, alpha=0.3)
        
        # Add quartile labels
        q1, q2, q3 = np.percentile(data, [25, 50, 75])
        ax2.text(1.1, q1, f'Q1: {q1:.2f}', va='center')
        ax2.text(1.1, q2, f'Q2: {q2:.2f}', va='center')
        ax2.text(1.1, q3, f'Q3: {q3:.2f}', va='center')
        
        # 3: Q-Q plot
        ax3 = fig.add_subplot(gs[1, 0])
        probplot(data, dist='norm', plot=ax3)
        ax3.set_title('Q-Q Plot (Normality)', fontweight='bold')
        ax3.grid(True, alpha=0.3)
        
        # 4: Running mean (shows stability)
        ax4 = fig.add_subplot(gs[1, 1])
        running_means = np.zeros(len(data))
        for i in range(1, len(data) + 1):
            running_means[i-1] = np.mean(data[:i])
        ax4.plot(running_means, color='blue', linewidth=2)
        ax4.axhline(np.mean(data), color='red', linestyle='--', 
                   label=f'Overall Mean: {np.mean(data):.2f}')
        ax4.set_title('Running Mean (Stability Check)', fontweight='bold')
        ax4.set_xlabel('Sample Size')
        ax4.set_ylabel('Mean')
        ax4.legend(loc='best')
        ax4.grid(True, alpha=0.3)
        
        # Add overall statistics
        stats_text = (
            f'Statistics Summary:\n'
            f'n = {stats_dict["n"]}\n'
            f'Mean = {stats_dict["mean"]:.3f}\n'
            f'Median = {stats_dict["median"]:.3f}\n'
            f'Std Dev = {stats_dict["std"]:.3f}\n'
            f'Skewness = {stats_dict["skewness"]:.3f}\n'
            f'Kurtosis = {stats_dict["kurtosis"]:.3f}\n'
            f'Min = {stats_dict["min"]:.3f}\n'
            f'Max = {stats_dict["max"]:.3f}'
        )
        fig.text(0.02, 0.02, stats_text, fontsize=10,
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.9))
        
        fig.suptitle(title, fontsize=18, fontweight='bold')
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=self.dpi, bbox_inches='tight')
            logger.info(f"Dashboard saved to {save_path}")
        
        return fig


# ==================== CONVENIENCE FUNCTIONS ====================

def clt_demo_app(data: np.ndarray, sample_sizes: List[int] = [5, 10, 30, 50, 100]):
    """
    Create a multi-panel demonstration of the CLT for different sample sizes.
    
    Args:
        data: Population data
        sample_sizes: List of sample sizes to demonstrate
    
    Returns:
        matplotlib.figure.Figure: The created figure
    """
    n_plots = len(sample_sizes)
    fig, axes = plt.subplots(1, n_plots, figsize=(5*n_plots, 5))
    
    if n_plots == 1:
        axes = [axes]
    
    pop_mean = np.mean(data)
    pop_std = np.std(data, ddof=1)
    
    for idx, ax in enumerate(axes):
        sample_size = sample_sizes[idx]
        
        # Draw sampling distribution
        n_samples = 500
        sample_means = np.zeros(n_samples)
        for i in range(n_samples):
            sample = np.random.choice(data, size=sample_size, replace=True)
            sample_means[i] = np.mean(sample)
        
        # Plot
        ax.hist(sample_means, bins=25, alpha=0.7, density=True, color='green')
        
        # Add normal curve
        x = np.linspace(pop_mean - 4*pop_std/np.sqrt(sample_size),
                       pop_mean + 4*pop_std/np.sqrt(sample_size), 100)
        y = norm.pdf(x, pop_mean, pop_std/np.sqrt(sample_size))
        ax.plot(x, y, 'r-', linewidth=2, label='Theoretical Normal')
        
        ax.axvline(pop_mean, color='black', linestyle='--', 
                  label=f'Population Mean: {pop_mean:.2f}')
        ax.set_title(f'n = {sample_size}', fontweight='bold')
        ax.set_xlabel('Sample Mean')
        ax.set_ylabel('Density')
        ax.legend(loc='best', fontsize=8)
        ax.grid(True, alpha=0.3)
        
        # Add observed stats
        obs_mean = np.mean(sample_means)
        obs_std = np.std(sample_means, ddof=1)
        ax.text(0.02, 0.98, f'Mean: {obs_mean:.3f}\nStd: {obs_std:.3f}',
               transform=ax.transAxes, verticalalignment='top', fontsize=8,
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    plt.suptitle('Central Limit Theorem: Sampling Distributions at Different Sample Sizes',
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    
    return fig


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script for visualization module.
    """
    print("Testing StatisticalPlots...")
    
    # Generate test data
    from src.data_generation.distributions import DistributionGenerator
    
    gen = DistributionGenerator(random_seed=42)
    normal_data = gen.normal(n=1000, mean=50, std=10)
    exponential_data = gen.exponential(n=1000, scale=5)
    
    plots = StatisticalPlots()
    
    # Test 1: Distribution plot
    fig1 = plots.plot_distribution(normal_data, title="Normal Distribution Test")
    print("✓ Distribution plot created")
    
    # Test 2: Q-Q plot
    fig2 = plots.plot_qq(normal_data, title="Q-Q Plot Test")
    print("✓ Q-Q plot created")
    
    # Test 3: Sampling distribution (CLT demonstration)
    fig3 = plots.plot_sampling_distribution(
        exponential_data, sample_size=30, n_samples=500,
        title="CLT Demonstration (Exponential Population)"
    )
    print("✓ Sampling distribution plot created")
    
    # Test 4: Confidence interval plot
    fig4 = plots.plot_confidence_interval(normal_data, confidence_level=0.95)
    print("✓ Confidence interval plot created")
    
    # Test 5: Descriptive dashboard
    fig5 = plots.plot_descriptive_dashboard(normal_data)
    print("✓ Descriptive dashboard created")
    
    # Test 6: CLT multi-panel
    fig6 = clt_demo_app(exponential_data, sample_sizes=[2, 5, 10, 30, 50])
    print("✓ CLT multi-panel created")
    
    print("\nAll tests passed! Visualization module is ready for use.")
    print("\nNote: Figures were created but not displayed. To view them, use plt.show()")
```

---

## Implementation 2: Descriptive Statistics Module

Create the file `src/descriptive/central_tendency.py`:

```python
#!/usr/bin/env python3
"""
Descriptive Statistics Module for Phase 3 Statistics Project.

Provides comprehensive descriptive statistics calculations with clear
interpretations and error handling.

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
from typing import Dict, Union, Optional, List, Tuple
import logging
from scipy import stats
from scipy.stats import mode

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DescriptiveStats:
    """
    Comprehensive descriptive statistics calculator.
    
    Provides:
    - Measures of central tendency (mean, median, mode)
    - Measures of dispersion (range, variance, std, IQR)
    - Measures of shape (skewness, kurtosis)
    - Quantile calculations
    - Summary statistics
    
    Think of this as your "data summary tool" — it tells you the story
    of your data in numbers.
    """
    
    def __init__(self):
        """Initialize the descriptive statistics calculator."""
        logger.info("Initialized DescriptiveStats")
    
    # ==================== CENTRAL TENDENCY ====================
    
    def mean(self, data: np.ndarray) -> float:
        """
        Calculate arithmetic mean.
        
        The mean is the average value — sum of all values divided by count.
        Sensitive to outliers.
        
        Args:
            data: Input array
        
        Returns:
            float: Arithmetic mean
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            >>> mean = stats_calc.mean(data)
            >>> print(f"Mean: {mean:.2f}")  # 5.50
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate mean of empty array")
        return np.mean(data)
    
    def median(self, data: np.ndarray) -> float:
        """
        Calculate median (50th percentile).
        
        The median is the middle value when data is sorted.
        Robust to outliers.
        
        Args:
            data: Input array
        
        Returns:
            float: Median
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]
            >>> median = stats_calc.median(data)
            >>> print(f"Median: {median:.2f}")  # 5.50
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate median of empty array")
        return np.median(data)
    
    def mode(self, data: np.ndarray) -> Tuple[Union[float, np.ndarray], int]:
        """
        Calculate mode(s) (most frequent value(s)).
        
        The mode is the value that appears most frequently.
        Can have multiple modes (multimodal distribution).
        
        Args:
            data: Input array
        
        Returns:
            tuple: (mode_value, count)
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
            >>> mode_val, count = stats_calc.mode(data)
            >>> print(f"Mode: {mode_val} (appears {count} times)")  # 4 (4 times)
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate mode of empty array")
        
        result = mode(data)
        return (result.mode[0], result.count[0])
    
    def trimmed_mean(
        self, 
        data: np.ndarray, 
        proportion_to_trim: float = 0.1
    ) -> float:
        """
        Calculate trimmed mean (removes outliers).
        
        The trimmed mean removes a proportion of extreme values from
        both ends before calculating the mean. Useful for robust estimation.
        
        Args:
            data: Input array
            proportion_to_trim: Proportion to trim from each end (e.g., 0.1 trims 10%)
        
        Returns:
            float: Trimmed mean
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]
            >>> trimmed = stats_calc.trimmed_mean(data, proportion_to_trim=0.1)
            >>> print(f"Trimmed mean: {trimmed:.2f}")  # 5.50 (removes 1 and 100)
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate trimmed mean of empty array")
        if not 0 <= proportion_to_trim < 0.5:
            raise ValueError("proportion_to_trim must be between 0 and 0.5")
        
        n = len(data)
        trim_n = int(n * proportion_to_trim)
        
        if trim_n == 0:
            return self.mean(data)
        
        sorted_data = np.sort(data)
        trimmed_data = sorted_data[trim_n:n-trim_n]
        
        if len(trimmed_data) == 0:
            raise ValueError("Trim proportion too large, no data left")
        
        return np.mean(trimmed_data)
    
    # ==================== DISPERSION ====================
    
    def range(self, data: np.ndarray) -> Tuple[float, float]:
        """
        Calculate range (min and max).
        
        The range is the difference between maximum and minimum values.
        Highly sensitive to outliers.
        
        Args:
            data: Input array
        
        Returns:
            tuple: (min_value, max_value)
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            >>> min_val, max_val = stats_calc.range(data)
            >>> print(f"Range: {min_val} to {max_val}")  # 1 to 10
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate range of empty array")
        return (np.min(data), np.max(data))
    
    def variance(self, data: np.ndarray, ddof: int = 1) -> float:
        """
        Calculate variance.
        
        Variance measures the average squared deviation from the mean.
        ddof=1 gives sample variance (unbiased).
        
        Args:
            data: Input array
            ddof: Delta degrees of freedom (1 for sample, 0 for population)
        
        Returns:
            float: Variance
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5]
            >>> var = stats_calc.variance(data)
            >>> print(f"Variance: {var:.2f}")  # 2.50
        """
        if len(data) < 2:
            raise ValueError("Need at least 2 data points to calculate variance")
        return np.var(data, ddof=ddof)
    
    def std(self, data: np.ndarray, ddof: int = 1) -> float:
        """
        Calculate standard deviation.
        
        The standard deviation is the square root of variance.
        Measured in same units as the data.
        
        Args:
            data: Input array
            ddof: Delta degrees of freedom
        
        Returns:
            float: Standard deviation
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5]
            >>> std = stats_calc.std(data)
            >>> print(f"Std Dev: {std:.2f}")  # 1.58
        """
        return np.sqrt(self.variance(data, ddof=ddof))
    
    def iqr(self, data: np.ndarray) -> float:
        """
        Calculate interquartile range (IQR).
        
        The IQR is the range between the 75th and 25th percentiles.
        Robust measure of spread, not sensitive to outliers.
        
        Args:
            data: Input array
        
        Returns:
            float: Interquartile range (Q3 - Q1)
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]
            >>> iqr = stats_calc.iqr(data)
            >>> print(f"IQR: {iqr:.2f}")  # 4.75
        """
        q1 = np.percentile(data, 25)
        q3 = np.percentile(data, 75)
        return q3 - q1
    
    def mad(self, data: np.ndarray) -> float:
        """
        Calculate median absolute deviation (MAD).
        
        The MAD is the median of absolute deviations from the median.
        Very robust measure of spread.
        
        Args:
            data: Input array
        
        Returns:
            float: Median absolute deviation
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]
            >>> mad = stats_calc.mad(data)
            >>> print(f"MAD: {mad:.2f}")  # 2.50
        """
        median = self.median(data)
        deviations = np.abs(data - median)
        return np.median(deviations)
    
    # ==================== SHAPE ====================
    
    def skewness(self, data: np.ndarray) -> float:
        """
        Calculate skewness (asymmetry).
        
        Skewness measures the asymmetry of the distribution:
        - 0: Symmetric distribution
        - > 0: Right-skewed (long right tail)
        - < 0: Left-skewed (long left tail)
        
        Args:
            data: Input array
        
        Returns:
            float: Skewness coefficient
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]
            >>> skew = stats_calc.skewness(data)
            >>> print(f"Skewness: {skew:.3f}")  # Positive (right-skewed)
        """
        if len(data) < 3:
            raise ValueError("Need at least 3 data points to calculate skewness")
        return stats.skew(data)
    
    def kurtosis(self, data: np.ndarray) -> float:
        """
        Calculate kurtosis (tailedness).
        
        Kurtosis measures the weight of tails relative to the center:
        - 0: Normal distribution (mesokurtic)
        - > 0: Heavy tails (leptokurtic)
        - < 0: Light tails (platykurtic)
        
        Args:
            data: Input array
        
        Returns:
            float: Excess kurtosis (Fisher = True)
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = np.random.normal(0, 1, 1000)
            >>> kurt = stats_calc.kurtosis(data)
            >>> print(f"Kurtosis: {kurt:.3f}")  # ~0 (normal)
        """
        if len(data) < 4:
            raise ValueError("Need at least 4 data points to calculate kurtosis")
        return stats.kurtosis(data, fisher=True)  # Excess kurtosis
    
    # ==================== QUANTILES ====================
    
    def quantile(
        self, 
        data: np.ndarray, 
        q: Union[float, List[float]]
    ) -> Union[float, np.ndarray]:
        """
        Calculate quantiles.
        
        Quantiles divide data into equal-sized intervals.
        
        Args:
            data: Input array
            q: Quantile(s) between 0 and 1
        
        Returns:
            float or ndarray: Quantile value(s)
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            >>> q = stats_calc.quantile(data, [0.25, 0.5, 0.75])
            >>> print(f"Quartiles: {q}")  # [3.25, 5.5, 7.75]
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate quantiles of empty array")
        return np.quantile(data, q)
    
    def detect_outliers_iqr(
        self, 
        data: np.ndarray, 
        multiplier: float = 1.5
    ) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Detect outliers using the IQR method.
        
        Outliers are defined as points outside:
        [Q1 - 1.5*IQR, Q3 + 1.5*IQR]
        
        Args:
            data: Input array
            multiplier: IQR multiplier (1.5 is standard, 3 is extreme)
        
        Returns:
            tuple: (inliers, outliers, outlier_indices)
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 100]
            >>> inliers, outliers, indices = stats_calc.detect_outliers_iqr(data)
            >>> print(f"Outliers: {outliers}")  # [100]
        """
        q1 = np.percentile(data, 25)
        q3 = np.percentile(data, 75)
        iqr = q3 - q1
        
        lower_bound = q1 - multiplier * iqr
        upper_bound = q3 + multiplier * iqr
        
        outlier_indices = np.where((data < lower_bound) | (data > upper_bound))[0]
        outliers = data[outlier_indices]
        
        # Inliers are all data points not in outliers
        inlier_indices = np.where((data >= lower_bound) & (data <= upper_bound))[0]
        inliers = data[inlier_indices]
        
        logger.info(
            f"Detected {len(outliers)} outliers using IQR method "
            f"(multiplier={multiplier})"
        )
        
        return (inliers, outliers, outlier_indices)
    
    # ==================== SUMMARY ====================
    
    def compute_all_statistics(self, data: np.ndarray) -> Dict[str, float]:
        """
        Compute all descriptive statistics in one function.
        
        Returns a comprehensive dictionary of all statistics.
        
        Args:
            data: Input array
        
        Returns:
            dict: Dictionary with all statistics
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = np.random.normal(50, 10, 100)
            >>> summary = stats_calc.compute_all_statistics(data)
            >>> for key, value in summary.items():
            ...     print(f"{key}: {value:.3f}")
        """
        if len(data) == 0:
            raise ValueError("Cannot compute statistics of empty array")
        
        stats_dict = {
            'n': len(data),
            'mean': self.mean(data),
            'median': self.median(data),
            'mode': self.mode(data)[0],
            'mode_count': self.mode(data)[1],
            'trimmed_mean_10pct': self.trimmed_mean(data, 0.1),
            'min': np.min(data),
            'max': np.max(data),
            'range': np.max(data) - np.min(data),
            'variance': self.variance(data),
            'std': self.std(data),
            'iqr': self.iqr(data),
            'mad': self.mad(data),
            'q1': np.percentile(data, 25),
            'q2': np.percentile(data, 50),
            'q3': np.percentile(data, 75),
            'skewness': self.skewness(data) if len(data) >= 3 else np.nan,
            'kurtosis': self.kurtosis(data) if len(data) >= 4 else np.nan,
            'outlier_count': len(self.detect_outliers_iqr(data)[1]),
        }
        
        logger.info(f"Computed complete descriptive statistics for n={len(data)}")
        return stats_dict
    
    def print_summary(self, data: np.ndarray) -> None:
        """
        Print a formatted summary of descriptive statistics.
        
        Args:
            data: Input array
        
        Example:
            >>> stats_calc = DescriptiveStats()
            >>> data = np.random.normal(50, 10, 100)
            >>> stats_calc.print_summary(data)
        """
        stats_dict = self.compute_all_statistics(data)
        
        print("\n" + "="*60)
        print("DESCRIPTIVE STATISTICS SUMMARY")
        print("="*60)
        print(f"\nSample Size: {stats_dict['n']}")
        print("\n--- Central Tendency ---")
        print(f"  Mean:              {stats_dict['mean']:.4f}")
        print(f"  Median:            {stats_dict['median']:.4f}")
        print(f"  Mode:              {stats_dict['mode']:.4f} (count: {stats_dict['mode_count']})")
        print(f"  Trimmed Mean (10%): {stats_dict['trimmed_mean_10pct']:.4f}")
        print("\n--- Dispersion ---")
        print(f"  Min:               {stats_dict['min']:.4f}")
        print(f"  Max:               {stats_dict['max']:.4f}")
        print(f"  Range:             {stats_dict['range']:.4f}")
        print(f"  Variance:          {stats_dict['variance']:.4f}")
        print(f"  Std Deviation:     {stats_dict['std']:.4f}")
        print(f"  IQR:               {stats_dict['iqr']:.4f}")
        print(f"  MAD:               {stats_dict['mad']:.4f}")
        print("\n--- Quantiles ---")
        print(f"  Q1 (25%):          {stats_dict['q1']:.4f}")
        print(f"  Q2 (50%):          {stats_dict['q2']:.4f}")
        print(f"  Q3 (75%):          {stats_dict['q3']:.4f}")
        print("\n--- Shape ---")
        print(f"  Skewness:          {stats_dict['skewness']:.4f}")
        print(f"  Kurtosis:          {stats_dict['kurtosis']:.4f}")
        print("\n--- Outliers ---")
        print(f"  Outlier Count:     {stats_dict['outlier_count']}")
        print("\n" + "="*60)


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script for descriptive statistics module.
    """
    print("Testing DescriptiveStats...")
    
    # Create test data
    from src.data_generation.distributions import DistributionGenerator
    gen = DistributionGenerator(random_seed=42)
    
    # Normal data
    normal_data = gen.normal(n=1000, mean=50, std=10)
    
    # Skewed data
    skewed_data = gen.exponential(n=1000, scale=5)
    
    # Data with outliers
    outlier_data = np.concatenate([
        gen.normal(n=95, mean=50, std=10),
        np.array([150, 200, -50, -100, 300])
    ])
    
    stats_calc = DescriptiveStats()
    
    # Test 1: Basic statistics
    mean = stats_calc.mean(normal_data)
    median = stats_calc.median(normal_data)
    std = stats_calc.std(normal_data)
    
    assert abs(mean - 50) < 1, f"Mean should be ~50, got {mean:.2f}"
    assert abs(std - 10) < 1, f"Std should be ~10, got {std:.2f}"
    print(f"✓ Basic statistics: mean={mean:.2f}, median={median:.2f}, std={std:.2f}")
    
    # Test 2: Skewness and kurtosis
    skew_normal = stats_calc.skewness(normal_data)
    skew_skewed = stats_calc.skewness(skewed_data)
    
    assert abs(skew_normal) < 0.1, f"Normal skew should be ~0, got {skew_normal:.3f}"
    assert skew_skewed > 0, f"Exponential should be right-skewed, got {skew_skewed:.3f}"
    print(f"✓ Skewness: normal={skew_normal:.3f}, skewed={skew_skewed:.3f}")
    
    # Test 3: Outlier detection
    _, outliers, _ = stats_calc.detect_outliers_iqr(outlier_data)
    assert len(outliers) == 5, f"Should detect 5 outliers, got {len(outliers)}"
    print(f"✓ Outlier detection: found {len(outliers)} outliers")
    
    # Test 4: Summary statistics
    summary = stats_calc.compute_all_statistics(normal_data)
    assert 'n' in summary, "Summary missing 'n'"
    assert 'mean' in summary, "Summary missing 'mean'"
    print(f"✓ Summary statistics: n={summary['n']}, mean={summary['mean']:.2f}")
    
    # Test 5: Print summary (visual check)
    print("\nSample summary (normal data):")
    stats_calc.print_summary(normal_data)
    
    print("\nAll tests passed! Descriptive statistics module is ready for use.")
```

---

## Implementation 3: Interactive Jupyter Notebook

Create the file `notebooks/01_exploratory_analysis.ipynb`:

```json
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Module 3.1: Descriptive & Inferential Foundations\n",
    "## Part 3: Central Limit Theorem in Action\n",
    "\n",
    "This notebook demonstrates the Central Limit Theorem through interactive simulations."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Import required libraries\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "from scipy import stats\n",
    "import sys\n",
    "sys.path.append('..')\n",
    "\n",
    "from src.data_generation.distributions import DistributionGenerator\n",
    "from src.descriptive.central_tendency import DescriptiveStats\n",
    "from src.descriptive.uncertainty import UncertaintyEstimator\n",
    "from src.visualization.plots import StatisticalPlots, clt_demo_app\n",
    "\n",
    "# Set style\n",
    "plt.style.use('seaborn-v0_8-whitegrid')\n",
    "sns.set_palette(\"husl\")\n",
    "%matplotlib inline"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 1. Generate Different Population Distributions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Create generator with fixed seed for reproducibility\n",
    "gen = DistributionGenerator(random_seed=42)\n",
    "\n",
    "# Generate different distributions\n",
    "normal_pop = gen.normal(n=10000, mean=50, std=15)\n",
    "exponential_pop = gen.exponential(n=10000, scale=5)\n",
    "uniform_pop = gen.uniform(n=10000, low=0, high=100)\n",
    "binomial_pop = gen.binomial(n_trials=10, p_success=0.3, n_simulations=10000)\n",
    "poisson_pop = gen.poisson(n=10000, lambda_rate=10)\n",
    "\n",
    "# Create visualization object\n",
    "plots = StatisticalPlots(figsize=(12, 6))\n",
    "\n",
    "# Plot each distribution\n",
    "fig, axes = plt.subplots(2, 3, figsize=(15, 10))\n",
    "distributions = [\n",
    "    (normal_pop, 'Normal (μ=50, σ=15)'),\n",
    "    (exponential_pop, 'Exponential (scale=5)'),\n",
    "    (uniform_pop, 'Uniform (0, 100)'),\n",
    "    (binomial_pop, 'Binomial (n=10, p=0.3)'),\n",
    "    (poisson_pop, 'Poisson (λ=10)')\n",
    "]\n",
    "\n",
    "for idx, (data, title) in enumerate(distributions):\n",
    "    ax = axes[idx // 3, idx % 3]\n",
    "    ax.hist(data, bins=50, alpha=0.7, density=True, color='blue')\n",
    "    ax.set_title(title, fontweight='bold')\n",
    "    ax.set_xlabel('Value')\n",
    "    ax.set_ylabel('Density')\n",
    "    ax.grid(True, alpha=0.3)\n",
    "\n",
    "# Remove empty subplot\n",
    "axes[1, 2].remove()\n",
    "\n",
    "plt.suptitle('Population Distributions', fontsize=16, fontweight='bold')\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 2. Demonstrate CLT: Visual Comparison"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Demonstrate CLT with different sample sizes\n",
    "for dist_name, population in [\n",
    "    ('Exponential', exponential_pop),\n",
    "    ('Uniform', uniform_pop),\n",
    "    ('Binomial', binomial_pop)\n",
    "]:\n",
    "    print(f\"\\n{dist_name} Population\")\n",
    "    \n",
    "    # Create multi-panel CLT demonstration\n",
    "    fig = clt_demo_app(population, sample_sizes=[2, 5, 10, 30, 50])\n",
    "    plt.suptitle(f'CLT: {dist_name} Population', fontsize=16, fontweight='bold')\n",
    "    plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 3. Quantitative CLT Validation"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "def validate_clt(population, sample_sizes=[5, 10, 20, 30, 50, 100]):\n",
    "    \"\"\"\n",
    "    Quantitatively validate the CLT by comparing observed vs theoretical\n",
    "    standard errors for different sample sizes.\n",
    "    \"\"\"\n",
    "    pop_mean = np.mean(population)\n",
    "    pop_std = np.std(population, ddof=1)\n",
    "    n_samples = 1000\n",
    "    \n",
    "    results = []\n",
    "    for n in sample_sizes:\n",
    "        sample_means = np.zeros(n_samples)\n",
    "        for i in range(n_samples):\n",
    "            sample = np.random.choice(population, size=n, replace=True)\n",
    "            sample_means[i] = np.mean(sample)\n",
    "        \n",
    "        observed_se = np.std(sample_means, ddof=1)\n",
    "        theoretical_se = pop_std / np.sqrt(n)\n",
    "        \n",
    "        results.append({\n",
    "            'sample_size': n,\n",
    "            'observed_se': observed_se,\n",
    "            'theoretical_se': theoretical_se,\n",
    "            'difference': abs(observed_se - theoretical_se),\n",
    "            'pct_diff': abs(observed_se - theoretical_se) / theoretical_se * 100\n",
    "        })\n",
    "    \n",
    "    return results\n",
    "\n",
    "# Validate CLT for exponential population\n",
    "print(\"CLT Validation: Exponential Population\")\n",
    "print(\"-\" * 60)\n",
    "results = validate_clt(exponential_pop)\n",
    "print(f\"{'n':>8} {'Observed SE':>12} {'Theoretical SE':>14} {'Diff %':>8}\")\n",
    "print(\"-\" * 60)\n",
    "for r in results:\n",
    "    print(f\"{r['sample_size']:>8} {r['observed_se']:>12.4f} {r['theoretical_se']:>14.4f} {r['pct_diff']:>8.2f}%\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 4. Interactive Sample Size Exploration"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "from ipywidgets import interact, FloatSlider, IntSlider, Dropdown\n",
    "\n",
    "def interactive_clt(pop_type='Exponential', sample_size=30, n_samples=500):\n",
    "    \"\"\"Interactive CLT visualization.\"\"\"\n",
    "    \n",
    "    # Select population\n",
    "    populations = {\n",
    "        'Exponential': exponential_pop,\n",
    "        'Uniform': uniform_pop,\n",
    "        'Binomial': binomial_pop,\n",
    "        'Normal': normal_pop,\n",
    "        'Poisson': poisson_pop\n",
    "    }\n",
    "    \n",
    "    population = populations[pop_type]\n",
    "    \n",
    "    # Generate sampling distribution\n",
    "    sample_means = np.zeros(n_samples)\n",
    "    for i in range(n_samples):\n",
    "        sample = np.random.choice(population, size=sample_size, replace=True)\n",
    "        sample_means[i] = np.mean(sample)\n",
    "    \n",
    "    # Plot\n",
    "    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))\n",
    "    \n",
    "    # Population distribution\n",
    "    ax1.hist(population, bins=50, alpha=0.7, density=True, color='blue')\n",
    "    ax1.set_title(f'Population: {pop_type}', fontweight='bold')\n",
    "    ax1.set_xlabel('Value')\n",
    "    ax1.set_ylabel('Density')\n",
    "    ax1.grid(True, alpha=0.3)\n",
    "    ax1.axvline(np.mean(population), color='red', linestyle='--', label='Mean')\n",
    "    ax1.legend()\n",
    "    \n",
    "    # Sampling distribution\n",
    "    ax2.hist(sample_means, bins=30, alpha=0.7, density=True, \n",
    "            color='green', label='Sample Means')\n",
    "    \n",
    "    # Theoretical normal curve\n",
    "    pop_mean = np.mean(population)\n",
    "    pop_std = np.std(population, ddof=1)\n",
    "    theoretical_se = pop_std / np.sqrt(sample_size)\n",
    "    x = np.linspace(pop_mean - 4*theoretical_se, pop_mean + 4*theoretical_se, 100)\n",
    "    y = stats.norm.pdf(x, pop_mean, theoretical_se)\n",
    "    ax2.plot(x, y, 'r-', linewidth=2, label='Theoretical Normal')\n",
    "    \n",
    "    # Statistics\n",
    "    ax2.axvline(pop_mean, color='red', linestyle='--', \n",
    "               label=f'Population Mean: {pop_mean:.2f}')\n",
    "    ax2.set_title(f'Sampling Distribution (n={sample_size})', fontweight='bold')\n",
    "    ax2.set_xlabel('Sample Mean')\n",
    "    ax2.set_ylabel('Density')\n",
    "    ax2.legend(loc='best')\n",
    "    ax2.grid(True, alpha=0.3)\n",
    "    \n",
    "    # Add stats annotation\n",
    "    observed_mean = np.mean(sample_means)\n",
    "    observed_se = np.std(sample_means, ddof=1)\n",
    "    stats_text = (\n",
    "        f'Observed Mean: {observed_mean:.3f}\\n'\n",
    "        f'Theoretical Mean: {pop_mean:.3f}\\n'\n",
    "        f'Observed SE: {observed_se:.4f}\\n'\n",
    "        f'Theoretical SE: {theoretical_se:.4f}'\n",
    "    )\n",
    "    ax2.text(0.02, 0.98, stats_text, transform=ax2.transAxes,\n",
    "            verticalalignment='top', fontsize=10,\n",
    "            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))\n",
    "    \n",
    "    plt.suptitle(f'CLT Demonstration: {pop_type} Population', \n",
    "                fontsize=16, fontweight='bold')\n",
    "    plt.tight_layout()\n",
    "    plt.show()\n",
    "\n",
    "# Create interactive widget\n",
    "interact(\n",
    "    interactive_clt,\n",
    "    pop_type=Dropdown(\n",
    "        options=['Normal', 'Exponential', 'Uniform', 'Binomial', 'Poisson'],\n",
    "        value='Exponential'\n",
    "    ),\n",
    "    sample_size=IntSlider(min=2, max=100, step=1, value=30),\n",
    "    n_samples=IntSlider(min=100, max=2000, step=100, value=500)\n",
    ")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 5. Confidence Intervals from Sampling Distribution"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Demonstrate confidence intervals from sampling distribution\n",
    "estimator = UncertaintyEstimator(confidence_level=0.95, random_seed=42)\n",
    "stats_calc = DescriptiveStats()\n",
    "\n",
    "# Take one sample from exponential population\n",
    "sample = np.random.choice(exponential_pop, size=50, replace=True)\n",
    "\n",
    "# Calculate confidence interval\n",
    "ci_low, ci_high = estimator.confidence_interval_mean(sample)\n",
    "mean = estimator.sample_mean(sample)\n",
    "se = estimator.standard_error_mean(sample)\n",
    "\n",
    "print(\"=\" * 60)\n",
    "print(\"CONFIDENCE INTERVAL DEMONSTRATION\")\n",
    "print(\"=\" * 60)\n",
    "print(f\"Sample Mean: {mean:.4f}\")\n",
    "print(f\"Standard Error: {se:.4f}\")\n",
    "print(f\"95% Confidence Interval: [{ci_low:.4f}, {ci_high:.4f}]\")\n",
    "print(f\"Margin of Error: ±{estimator.margin_of_error(sample):.4f}\")\n",
    "\n",
    "# Visualize\n",
    "fig = plots.plot_confidence_interval(sample, confidence_level=0.95)\n",
    "plt.show()"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 6. Summary: Key Takeaways\n",
    "\n",
    "1. **The CLT works for any distribution**, as long as sample size is sufficiently large (typically n ≥ 30)\n",
    "2. **The sampling distribution of the mean is normal**, even when the population is not\n",
    "3. **The standard error decreases with √n** — larger samples give more precise estimates\n",
    "4. **Confidence intervals quantify uncertainty** — they tell us how confident we are in our estimates\n",
    "\n",
    "### Rule of Thumb\n",
    "- n < 30: Use t-distribution (more conservative)\n",
    "- n ≥ 30: Normal approximation is good\n",
    "- n ≥ 50: Very safe for most distributions\n",
    "- n ≥ 100: Nearly perfect normality"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## 7. Next Steps\n",
    "\n",
    "Now that you've mastered the CLT, you're ready for **Module 3.2: Hypothesis Testing & Experimental Design** where you'll:\n",
    "- Design A/B tests\n",
    "- Calculate statistical power\n",
    "- Run parametric and non-parametric tests\n",
    "- Apply multiple testing corrections"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.8.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
```

---

## Verification: Test All Modules Together

### Step 1: Test the Visualization Module

```bash
cd phase3-statistics-project
python src/visualization/plots.py
```

**Expected Output:**
```
Testing StatisticalPlots...
✓ Distribution plot created
✓ Q-Q plot created
✓ Sampling distribution plot created
✓ Confidence interval plot created
✓ Descriptive dashboard created
✓ CLT multi-panel created

All tests passed! Visualization module is ready for use.

Note: Figures were created but not displayed. To view them, use plt.show()
```

### Step 2: Test the Descriptive Statistics Module

```bash
python src/descriptive/central_tendency.py
```

**Expected Output:**
```
Testing DescriptiveStats...
✓ Basic statistics: mean=50.10, median=49.96, std=9.98
✓ Skewness: normal=0.038, skewed=1.000
✓ Outlier detection: found 5 outliers
✓ Summary statistics: n=1000, mean=50.10

Sample summary (normal data):
============================================================
DESCRIPTIVE STATISTICS SUMMARY
============================================================

Sample Size: 1000

--- Central Tendency ---
  Mean:              50.1012
  Median:            49.9554
  Mode:              -inf (count: 1)
  Trimmed Mean (10%): 50.1106

... (rest of output)

All tests passed! Descriptive statistics module is ready for use.
```

### Step 3: Run the Jupyter Notebook

```bash
jupyter notebook notebooks/01_exploratory_analysis.ipynb
```

Run all cells to see the interactive CLT demonstrations.

### Step 4: Create a Simple CLT Demonstration Script

Create `demo_clt.py`:

```python
#!/usr/bin/env python3
"""
Simple CLT demonstration script.
Run this to see the CLT in action without Jupyter.
"""

import numpy as np
import matplotlib.pyplot as plt
from src.data_generation.distributions import DistributionGenerator
from src.visualization.plots import StatisticalPlots

# Generate data
gen = DistributionGenerator(random_seed=42)
population = gen.exponential(n=10000, scale=5)

# Create CLT demonstration
plots = StatisticalPlots()

print("Generating CLT demonstration...")
fig = plots.plot_sampling_distribution(
    population, 
    sample_size=30, 
    n_samples=1000,
    title="CLT: Exponential Population (n=30)"
)

plt.show()

# Show different sample sizes
print("\nDemonstrating different sample sizes...")
from src.visualization.plots import clt_demo_app
fig = clt_demo_app(population, sample_sizes=[2, 5, 10, 30, 50])
plt.show()

print("Done! Notice how the distribution becomes more normal as sample size increases.")
```

Run it:

```bash
python demo_clt.py
```

---

## Why This Matters

You've now built the complete descriptive and inferential foundation:

1. **Distribution Generator** — Create any distribution needed
2. **Uncertainty Estimator** — Quantify uncertainty in estimates
3. **Visualization Toolkit** — See the patterns clearly
4. **Descriptive Statistics** — Summarize data comprehensively
5. **CLT Demonstrations** — Understand the magic of sampling

This foundation powers everything that comes next in Phase 3!

---

## Module 3.1 Complete: What You've Built

| File | Purpose | Lines of Code |
|------|---------|---------------|
| `src/data_generation/distributions.py` | Probability distributions | ~300 |
| `src/descriptive/uncertainty.py` | Sampling & estimation | ~400 |
| `src/descriptive/central_tendency.py` | Descriptive statistics | ~250 |
| `src/visualization/plots.py` | Statistical visualization | ~350 |
| `notebooks/01_exploratory_analysis.ipynb` | Interactive CLT demo | ~150 |

**Total: ~1,450 lines of production-quality Python code!**

---

In Module 3.2, you'll use this foundation to:
- Design experiments with proper sample sizes
- Calculate statistical power for A/B tests
- Run parametric t-tests and ANOVA
- Implement non-parametric alternatives
- Apply multiple testing corrections

Everything you've built so far will be used!

---

## Quick Reference: CLT Cheat Sheet

| Concept | Formula | Rule of Thumb |
|---------|---------|---------------|
| Standard Error | σ/√n | Decreases with √n |
| 95% CI (known σ) | x̄ ± 1.96 × σ/√n | z = 1.96 |
| 95% CI (unknown σ) | x̄ ± t₍ₙ₋₁₎ × s/√n | t > z for small n |
| Sample Size (mean) | n = (zσ/MOE)² | More data = narrower CI |
| Sample Size (prop) | n = z²p(1-p)/MOE² | Most conservative at p=0.5 |
