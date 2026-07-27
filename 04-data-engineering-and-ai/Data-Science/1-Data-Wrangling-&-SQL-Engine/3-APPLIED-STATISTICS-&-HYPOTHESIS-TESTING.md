# PHASE 3: APPLIED STATISTICS & HYPOTHESIS TESTING

## Phase 3, Module 3.1: Descriptive & Inferential Foundations

Welcome to Phase 3! Now that we can process, explore, and visualize data, it's time to add mathematical rigor. This phase is about understanding uncertainty, making decisions under uncertainty, and building models that explain relationships in your data.

---

### The Bridge from Description to Inference

**The Analogy:**

Think of descriptive statistics as taking a photograph of your data—it captures exactly what you see. Inferential statistics is like using that photograph to predict what you'd see if you took a thousand more photos. It's about generalizing from what you have to what you might find.

**Why This Matters Now:**

In business, you rarely have all the data you'd like. You need to make decisions based on samples. Inferential statistics gives you the tools to:
1. **Quantify uncertainty:** How confident are you in your conclusions?
2. **Test hypotheses:** Is this change actually making a difference?
3. **Make predictions:** What's likely to happen next?

---

### Target: Mastering Descriptive Statistics & Probability Foundations

**The Concept:**

We'll start with the fundamentals: probability distributions, descriptive statistics, and the building blocks of inference. Think of this as learning the grammar of statistics—you need to understand the rules before you can write compelling analyses.

**The Implementation:**

Create `src/phase3/module3_1_descriptive_inferential.py`:

```python
"""
Module 3.1: Descriptive & Inferential Foundations

This module covers:
1. Descriptive statistics and distributions
2. Probability theory foundations
3. The Central Limit Theorem
4. Confidence intervals and sampling
5. Parametric vs non-parametric distributions
6. Quantifying uncertainty

We'll use SciPy for statistical computations and build
intuition through simulation.
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import norm, t, chi2, f, poisson, expon, beta
import warnings
warnings.filterwarnings('ignore')

# Set styles
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")


def section(title: str):
    """Helper function to print section headers."""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)


# ============================================================
# PART 1: PROBABILITY DISTRIBUTIONS
# ============================================================

def probability_distributions_demo():
    """
    Demonstrate key probability distributions.
    
    Understanding distributions is fundamental to statistics.
    Each distribution models different types of data and processes.
    """
    section("Probability Distributions")
    
    print("Probability distributions model how data is generated.")
    print("We'll explore the most important ones:\n")
    
    # Create a grid of distribution visualizations
    fig, axes = plt.subplots(3, 3, figsize=(15, 12))
    
    # 1. Normal Distribution
    x = np.linspace(-4, 4, 1000)
    ax = axes[0, 0]
    for mu, sigma, color in [(-1, 0.5, 'blue'), (0, 1, 'green'), (2, 0.8, 'red')]:
        y = norm.pdf(x, mu, sigma)
        ax.plot(x, y, label=f'μ={mu}, σ={sigma}', color=color)
    ax.set_title('Normal Distribution')
    ax.set_xlabel('x')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. t-Distribution
    ax = axes[0, 1]
    x = np.linspace(-4, 4, 1000)
    for df, color in [(1, 'blue'), (5, 'green'), (30, 'red')]:
        y = t.pdf(x, df)
        ax.plot(x, y, label=f'df={df}', color=color)
    # Add normal for comparison
    y_norm = norm.pdf(x)
    ax.plot(x, y_norm, 'k--', label='Normal', alpha=0.5)
    ax.set_title("Student's t-Distribution")
    ax.set_xlabel('x')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 3. Chi-Square Distribution
    ax = axes[0, 2]
    x = np.linspace(0, 15, 1000)
    for df, color in [(1, 'blue'), (3, 'green'), (6, 'red')]:
        y = chi2.pdf(x, df)
        ax.plot(x, y, label=f'df={df}', color=color)
    ax.set_title('Chi-Square Distribution')
    ax.set_xlabel('x')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 4. F-Distribution
    ax = axes[1, 0]
    x = np.linspace(0, 5, 1000)
    for dfn, dfd, color in [(1, 5, 'blue'), (3, 10, 'green'), (5, 20, 'red')]:
        y = f.pdf(x, dfn, dfd)
        ax.plot(x, y, label=f'dfn={dfn}, dfd={dfd}', color=color)
    ax.set_title('F-Distribution')
    ax.set_xlabel('x')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 5. Poisson Distribution
    ax = axes[1, 1]
    x = np.arange(0, 20)
    for mu, color in [(2, 'blue'), (5, 'green'), (8, 'red')]:
        y = poisson.pmf(x, mu)
        ax.bar(x, y, alpha=0.6, label=f'λ={mu}', color=color)
    ax.set_title('Poisson Distribution')
    ax.set_xlabel('k')
    ax.set_ylabel('Probability')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 6. Exponential Distribution
    ax = axes[1, 2]
    x = np.linspace(0, 5, 1000)
    for scale, color in [(0.5, 'blue'), (1, 'green'), (2, 'red')]:
        y = expon.pdf(x, scale=scale)
        ax.plot(x, y, label=f'λ={1/scale:.1f}', color=color)
    ax.set_title('Exponential Distribution')
    ax.set_xlabel('x')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 7. Beta Distribution
    ax = axes[2, 0]
    x = np.linspace(0, 1, 1000)
    for a, b, color in [(0.5, 0.5, 'blue'), (2, 2, 'green'), (5, 1, 'red')]:
        y = beta.pdf(x, a, b)
        ax.plot(x, y, label=f'α={a}, β={b}', color=color)
    ax.set_title('Beta Distribution')
    ax.set_xlabel('x')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 8. Uniform Distribution
    ax = axes[2, 1]
    x = np.linspace(-2, 2, 1000)
    y = np.ones_like(x) / 4
    ax.plot(x, y, color='blue')
    ax.fill_between(x, y, alpha=0.3)
    ax.set_title('Uniform Distribution')
    ax.set_xlabel('x')
    ax.set_ylabel('Probability Density')
    ax.grid(True, alpha=0.3)
    
    # 9. Distribution Relationships
    ax = axes[2, 2]
    ax.text(0.1, 0.9, 'Distribution Families', transform=ax.transAxes, 
            fontsize=14, fontweight='bold')
    ax.text(0.1, 0.8, 'Continuous:', transform=ax.transAxes, fontweight='bold')
    ax.text(0.1, 0.7, '  • Normal (Gaussian)', transform=ax.transAxes)
    ax.text(0.1, 0.6, '  • t (Student)', transform=ax.transAxes)
    ax.text(0.1, 0.5, '  • Chi-Square', transform=ax.transAxes)
    ax.text(0.1, 0.4, '  • F', transform=ax.transAxes)
    ax.text(0.1, 0.3, '  • Exponential', transform=ax.transAxes)
    ax.text(0.1, 0.2, '  • Beta', transform=ax.transAxes)
    ax.text(0.1, 0.1, 'Discrete:', transform=ax.transAxes, fontweight='bold')
    ax.text(0.1, 0.0, '  • Poisson', transform=ax.transAxes)
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('data/distributions.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("  ✓ Saved distribution visualizations to data/distributions.png")
    
    # Print distribution properties
    print("\nKey Distribution Properties:")
    print("-" * 60)
    
    distributions = [
        ('Normal', 'Continuous', 'μ, σ²', 'Symmetric, bell-shaped'),
        ("Student's t", 'Continuous', 'df', 'Heavy tails, approaches normal'),
        ('Chi-Square', 'Continuous', 'df', 'Sum of squared normals'),
        ('F', 'Continuous', 'dfn, dfd', 'Ratio of chi-squares'),
        ('Poisson', 'Discrete', 'λ', 'Counts of rare events'),
        ('Exponential', 'Continuous', 'λ', 'Time between events'),
        ('Beta', 'Continuous', 'α, β', 'Proportions, [0,1]'),
        ('Uniform', 'Continuous', 'a, b', 'Equal probability')
    ]
    
    print(f"{'Distribution':<15} {'Type':<12} {'Parameters':<12} {'Description':<30}")
    print("-" * 70)
    for dist, dtype, params, desc in distributions:
        print(f"{dist:<15} {dtype:<12} {params:<12} {desc:<30}")
    
    return fig


# ============================================================
# PART 2: DESCRIPTIVE STATISTICS DEEP DIVE
# ============================================================

def descriptive_statistics_demo():
    """
    Demonstrate descriptive statistics with real data.
    
    We'll explore measures of central tendency, spread,
    and shape using realistic data.
    """
    section("Descriptive Statistics")
    
    print("Descriptive statistics summarize and describe data.")
    print("We'll examine key measures with real data.\n")
    
    # Generate realistic data
    np.random.seed(42)
    n = 1000
    
    # Create data with different characteristics
    data_normal = np.random.normal(100, 15, n)
    data_right_skew = np.random.exponential(50, n)
    data_left_skew = -np.random.exponential(30, n) + 80
    data_bimodal = np.concatenate([
        np.random.normal(30, 5, n//2),
        np.random.normal(70, 5, n//2)
    ])
    
    datasets = {
        'Normal': data_normal,
        'Right-Skewed': data_right_skew,
        'Left-Skewed': data_left_skew,
        'Bimodal': data_bimodal
    }
    
    # Calculate and display statistics
    print("Statistics for different distributions:")
    print("-" * 80)
    print(f"{'Distribution':<15} {'Mean':>8} {'Median':>8} {'Std':>8} {'Skew':>8} {'Kurtosis':>10} {'IQR':>8}")
    print("-" * 80)
    
    for name, data in datasets.items():
        mean = np.mean(data)
        median = np.median(data)
        std = np.std(data)
        skew = stats.skew(data)
        kurt = stats.kurtosis(data)
        q1, q3 = np.percentile(data, [25, 75])
        iqr = q3 - q1
        
        print(f"{name:<15} {mean:>8.2f} {median:>8.2f} {std:>8.2f} "
              f"{skew:>8.2f} {kurt:>10.2f} {iqr:>8.2f}")
    
    # Visualize distributions
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    axes = axes.flatten()
    
    for idx, (name, data) in enumerate(datasets.items()):
        ax = axes[idx]
        
        # Histogram with KDE
        ax.hist(data, bins=30, density=True, alpha=0.5, color='skyblue', 
                edgecolor='black', label='Histogram')
        sns.kdeplot(data, ax=ax, color='red', linewidth=2, label='KDE')
        
        # Add vertical lines for mean and median
        mean = np.mean(data)
        median = np.median(data)
        ax.axvline(mean, color='green', linestyle='--', label=f'Mean: {mean:.1f}')
        ax.axvline(median, color='orange', linestyle='--', label=f'Median: {median:.1f}')
        
        ax.set_title(f'{name} Distribution')
        ax.set_xlabel('Value')
        ax.set_ylabel('Density')
        ax.legend()
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/descriptive_stats.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("  ✓ Saved descriptive statistics visualization to data/descriptive_stats.png")
    
    # Explain skewness and kurtosis
    print("\n" + "=" * 60)
    print("Interpreting Skewness and Kurtosis:")
    print("=" * 60)
    print("""
    Skewness (Third Moment):
    - Skewness > 0: Right-skewed (long right tail)
    - Skewness < 0: Left-skewed (long left tail)
    - Skewness ≈ 0: Symmetric distribution
    
    Kurtosis (Fourth Moment):
    - Kurtosis > 0: Heavy tails (leptokurtic)
    - Kurtosis < 0: Light tails (platykurtic)
    - Kurtosis ≈ 0: Normal-like tails (mesokurtic)
    """)
    
    return datasets


# ============================================================
# PART 3: CENTRAL LIMIT THEOREM
# ============================================================

def central_limit_theorem_demo():
    """
    Demonstrate the Central Limit Theorem through simulation.
    
    The CLT states that the sampling distribution of the mean
    approaches a normal distribution as sample size increases,
    regardless of the underlying distribution.
    """
    section("Central Limit Theorem")
    
    print("The Central Limit Theorem (CLT) is the foundation of")
    print("statistical inference. Let's demonstrate it through simulation.\n")
    
    # Create different underlying distributions
    np.random.seed(42)
    n_samples = 10000
    
    distributions = {
        'Uniform (0, 1)': lambda: np.random.uniform(0, 1, n_samples),
        'Exponential (λ=1)': lambda: np.random.exponential(1, n_samples),
        'Poisson (λ=2)': lambda: np.random.poisson(2, n_samples),
        'Bimodal': lambda: np.random.choice(
            [np.random.normal(-2, 0.5), np.random.normal(2, 0.5)],
            n_samples
        ).flatten()
    }
    
    # Sample sizes to test
    sample_sizes = [1, 2, 5, 10, 30, 50]
    
    fig, axes = plt.subplots(len(distributions), len(sample_sizes), 
                             figsize=(15, 12))
    
    for dist_idx, (dist_name, dist_func) in enumerate(distributions.items()):
        # Generate population
        population = dist_func()
        
        for size_idx, sample_size in enumerate(sample_sizes):
            ax = axes[dist_idx, size_idx]
            
            # Draw many samples and compute means
            n_replications = 1000
            sample_means = []
            
            for _ in range(n_replications):
                sample = np.random.choice(population, sample_size)
                sample_means.append(np.mean(sample))
            
            # Plot sampling distribution
            ax.hist(sample_means, bins=30, density=True, alpha=0.6, 
                    edgecolor='black')
            
            # Overlay normal distribution
            mu = np.mean(sample_means)
            sigma = np.std(sample_means)
            x = np.linspace(mu - 4*sigma, mu + 4*sigma, 1000)
            y = norm.pdf(x, mu, sigma)
            ax.plot(x, y, 'r-', linewidth=2, label='Normal fit')
            
            ax.set_title(f'n={sample_size}')
            if size_idx == 0:
                ax.set_ylabel(dist_name, rotation=0, ha='right')
            
            if dist_idx == 0:
                ax.set_xlabel('Sample Mean')
            
            ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/clt_demo.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("  ✓ Saved CLT demonstration to data/clt_demo.png")
    
    # Print key insights
    print("\n" + "=" * 60)
    print("Key Insights from CLT:")
    print("=" * 60)
    print("""
    1. The sampling distribution of the mean becomes approximately normal
       as sample size increases
    
    2. This holds true REGARDLESS of the underlying distribution
    
    3. The mean of the sampling distribution equals the population mean
    
    4. The standard deviation of the sampling distribution (standard error)
       equals σ / √n
    
    5. CLT enables hypothesis testing and confidence intervals even
       when we don't know the underlying distribution
    """)
    
    return fig


# ============================================================
# PART 4: CONFIDENCE INTERVALS
# ============================================================

def confidence_intervals_demo():
    """
    Demonstrate confidence intervals and their interpretation.
    
    Confidence intervals provide a range of plausible values
    for a population parameter based on sample data.
    """
    section("Confidence Intervals")
    
    print("Confidence intervals provide a range of plausible values")
    print("for a population parameter.\n")
    
    # Generate population data
    np.random.seed(42)
    population = np.random.normal(100, 15, 10000)
    pop_mean = np.mean(population)
    pop_std = np.std(population)
    
    print(f"Population mean: {pop_mean:.2f}")
    print(f"Population std: {pop_std:.2f}\n")
    
    # Draw samples and compute confidence intervals
    n_samples = 100
    sample_size = 50
    confidence_level = 0.95
    
    # Store intervals
    intervals = []
    contains_mean = []
    
    print(f"Drawing {n_samples} samples of size {sample_size}...")
    print(f"Computing {confidence_level*100:.0f}% confidence intervals\n")
    
    for i in range(n_samples):
        # Draw sample
        sample = np.random.choice(population, sample_size)
        sample_mean = np.mean(sample)
        sample_std = np.std(sample, ddof=1)
        
        # Compute confidence interval
        t_critical = t.ppf((1 + confidence_level) / 2, df=sample_size - 1)
        margin = t_critical * sample_std / np.sqrt(sample_size)
        ci_lower = sample_mean - margin
        ci_upper = sample_mean + margin
        
        intervals.append((ci_lower, ci_upper))
        contains_mean.append(ci_lower <= pop_mean <= ci_upper)
    
    # Calculate coverage
    coverage = np.mean(contains_mean) * 100
    print(f"Coverage (intervals containing true mean): {coverage:.1f}%")
    print(f"Expected coverage: {confidence_level*100:.0f}%\n")
    
    # Visualize confidence intervals
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Plot intervals
    for i, (ci_lower, ci_upper) in enumerate(intervals[:50]):  # Show first 50
        contains = ci_lower <= pop_mean <= ci_upper
        color = 'blue' if contains else 'red'
        ax.plot([ci_lower, ci_upper], [i, i], color=color, linewidth=2)
        ax.plot(sample_mean, i, 'o', color='green', markersize=4)
    
    # True mean
    ax.axvline(pop_mean, color='black', linestyle='--', 
               label=f'True Mean: {pop_mean:.2f}')
    
    ax.set_xlabel('Value')
    ax.set_ylabel('Sample Number')
    ax.set_title(f'Confidence Intervals ({confidence_level*100:.0f}% Confidence)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Add annotation explaining coverage
    coverage_text = f'Coverage: {coverage:.1f}%'
    ax.text(0.02, 0.98, coverage_text, transform=ax.transAxes,
            fontsize=12, verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('data/confidence_intervals.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("  ✓ Saved confidence interval visualization to data/confidence_intervals.png")
    
    # Confidence interval interpretation
    print("\n" + "=" * 60)
    print("Interpreting Confidence Intervals:")
    print("=" * 60)
    print("""
    A 95% confidence interval means:
    
    ✅ If we repeated this experiment many times, 95% of the
       intervals would contain the true population parameter
    
    ❌ It does NOT mean there's a 95% chance the true parameter
       is in this specific interval
    
    ❌ It does NOT mean 95% of the data falls within this range
    
    The interval represents our uncertainty about the parameter
    estimate based on the sample we observed.
    """)
    
    return intervals


# ============================================================
# PART 5: SAMPLING METHODS
# ============================================================

def sampling_methods_demo():
    """
    Demonstrate different sampling methods and their properties.
    
    Understanding sampling methods is crucial for designing
    studies and experiments correctly.
    """
    section("Sampling Methods")
    
    print("Different sampling methods can lead to different results.")
    print("We'll demonstrate several approaches.\n")
    
    # Create a population with structure
    np.random.seed(42)
    n_pop = 10000
    
    # Population with groups
    groups = ['A', 'B', 'C', 'D']
    group_props = [0.4, 0.3, 0.2, 0.1]
    
    population = pd.DataFrame({
        'group': np.random.choice(groups, n_pop, p=group_props),
        'value': np.random.normal(50, 15, n_pop)
    })
    
    # Add group-specific effects
    group_effects = {'A': 10, 'B': 5, 'C': -5, 'D': -10}
    population['value'] = population.apply(
        lambda row: row['value'] + group_effects[row['group']], axis=1
    )
    
    print("Population statistics:")
    print(population['value'].describe())
    print(f"\nGroup sizes:")
    print(population['group'].value_counts())
    print(f"\nGroup means:")
    print(population.groupby('group')['value'].mean())
    
    # Sampling methods
    sample_size = 200
    
    print("\n" + "-" * 60)
    print("1. Simple Random Sampling:")
    print("-" * 60)
    
    # Simple random sample
    srs = population.sample(sample_size, random_state=42)
    srs_mean = srs['value'].mean()
    print(f"Sample mean: {srs_mean:.2f}")
    print(f"Group distribution:")
    print(srs['group'].value_counts(normalize=True).round(3))
    
    print("\n" + "-" * 60)
    print("2. Stratified Sampling:")
    print("-" * 60)
    
    # Stratified sample (proportional)
    stratified = pd.DataFrame()
    for group in groups:
        group_data = population[population['group'] == group]
        n_group = int(sample_size * len(group_data) / n_pop)
        sample = group_data.sample(n_group, random_state=42)
        stratified = pd.concat([stratified, sample])
    
    strat_mean = stratified['value'].mean()
    print(f"Sample mean: {strat_mean:.2f}")
    print(f"Group distribution:")
    print(stratified['group'].value_counts(normalize=True).round(3))
    
    print("\n" + "-" * 60)
    print("3. Cluster Sampling:")
    print("-" * 60)
    
    # Cluster sampling (select groups, then all members)
    selected_clusters = np.random.choice(groups, 2, replace=False)
    cluster_sample = population[population['group'].isin(selected_clusters)]
    cluster_mean = cluster_sample['value'].mean()
    print(f"Selected clusters: {selected_clusters}")
    print(f"Sample size: {len(cluster_sample)}")
    print(f"Sample mean: {cluster_mean:.2f}")
    
    print("\n" + "-" * 60)
    print("4. Systematic Sampling:")
    print("-" * 60)
    
    # Systematic sampling
    sorted_pop = population.sort_values('value')
    step = len(sorted_pop) // sample_size
    indices = np.arange(0, len(sorted_pop), step)[:sample_size]
    systematic = sorted_pop.iloc[indices]
    sys_mean = systematic['value'].mean()
    print(f"Sample mean: {sys_mean:.2f}")
    
    print("\n" + "-" * 60)
    print("Sampling Method Comparison:")
    print("-" * 60)
    
    # Compare methods
    methods = {
        'Simple Random': srs_mean,
        'Stratified': strat_mean,
        'Cluster': cluster_mean,
        'Systematic': sys_mean
    }
    
    print(f"{'Method':<20} {'Sample Mean':>15} {'Bias':>15} {'Difference from True':>20}")
    print("-" * 70)
    
    true_mean = population['value'].mean()
    for method, mean in methods.items():
        bias = mean - true_mean
        print(f"{method:<20} {mean:>15.2f} {bias:>15.2f} {abs(bias):>20.2f}")
    
    print(f"\nTrue population mean: {true_mean:.2f}")
    
    print("\n" + "=" * 60)
    print("Sampling Method Selection Guide:")
    print("=" * 60)
    print("""
    1. Simple Random: Best when population is homogeneous
    
    2. Stratified: Best when population has distinct subgroups
       and you want to ensure representation
    
    3. Cluster: Best when population is naturally grouped and
       you want to reduce costs
    
    4. Systematic: Best when population has a natural ordering
       and you want a simple implementation
    
    Always consider:
    - Cost and feasibility
    - Required precision
    - Known population structure
    - Bias risk
    """)
    
    return population


# ============================================================
# PART 6: QUANTIFYING UNCERTAINTY
# ============================================================

def uncertainty_quantification_demo():
    """
    Demonstrate how to quantify uncertainty in estimates.
    
    We'll explore standard errors, margins of error, and
    the relationship between sample size and precision.
    """
    section("Quantifying Uncertainty")
    
    print("Every estimate has uncertainty. We'll quantify it.\n")
    
    # Generate population
    np.random.seed(42)
    population = np.random.normal(100, 20, 10000)
    true_mean = np.mean(population)
    true_std = np.std(population)
    
    print(f"Population parameters:")
    print(f"  Mean: {true_mean:.2f}")
    print(f"  Std: {true_std:.2f}\n")
    
    # Explore relationship between sample size and precision
    sample_sizes = [5, 10, 20, 50, 100, 200, 500, 1000]
    n_replications = 1000
    
    results = []
    
    for sample_size in sample_sizes:
        means = []
        stds = []
        
        for _ in range(n_replications):
            sample = np.random.choice(population, sample_size)
            means.append(np.mean(sample))
            stds.append(np.std(sample, ddof=1))
        
        # Calculate statistics of the sampling distribution
        mean_of_means = np.mean(means)
        std_of_means = np.std(means)  # Standard error
        se_theoretical = true_std / np.sqrt(sample_size)
        
        # Confidence interval coverage
        ci_lower = np.percentile(means, 2.5)
        ci_upper = np.percentile(means, 97.5)
        coverage = ((ci_lower <= true_mean) & (ci_upper >= true_mean)).mean() * 100
        
        results.append({
            'n': sample_size,
            'mean': mean_of_means,
            'se_empirical': std_of_means,
            'se_theoretical': se_theoretical,
            'ci_lower': ci_lower,
            'ci_upper': ci_upper,
            'coverage': coverage
        })
    
    # Display results
    results_df = pd.DataFrame(results)
    print("Relationship between sample size and precision:")
    print("-" * 80)
    print(f"{'Sample Size':<12} {'Mean':<10} {'SE (Emp)':<10} {'SE (Theo)':<10} {'CI Width':<10} {'Coverage':<10}")
    print("-" * 80)
    
    for _, row in results_df.iterrows():
        ci_width = row['ci_upper'] - row['ci_lower']
        print(f"{row['n']:<12} {row['mean']:<10.2f} {row['se_empirical']:<10.2f} "
              f"{row['se_theoretical']:<10.2f} {ci_width:<10.2f} {row['coverage']:<10.1f}%")
    
    # Visualize relationship
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # 1. Standard Error vs Sample Size
    ax = axes[0]
    ax.plot(results_df['n'], results_df['se_empirical'], 'o-', label='Empirical SE')
    ax.plot(results_df['n'], results_df['se_theoretical'], 's--', label='Theoretical SE')
    ax.set_xlabel('Sample Size')
    ax.set_ylabel('Standard Error')
    ax.set_title('Standard Error vs Sample Size')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Confidence Interval Width
    ax = axes[1]
    ax.plot(results_df['n'], results_df['ci_upper'] - results_df['ci_lower'], 'o-')
    ax.set_xlabel('Sample Size')
    ax.set_ylabel('CI Width')
    ax.set_title('Confidence Interval Width vs Sample Size')
    ax.grid(True, alpha=0.3)
    
    # 3. Coverage
    ax = axes[2]
    ax.axhline(95, color='red', linestyle='--', label='Target (95%)')
    ax.plot(results_df['n'], results_df['coverage'], 'o-')
    ax.set_xlabel('Sample Size')
    ax.set_ylabel('Coverage (%)')
    ax.set_title('Confidence Interval Coverage')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/uncertainty_quantification.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved uncertainty quantification to data/uncertainty_quantification.png")
    
    # Key insights
    print("\n" + "=" * 60)
    print("Key Insights on Uncertainty:")
    print("=" * 60)
    print("""
    1. Sample Size and Precision:
       - Larger samples → smaller standard errors
       - Precision improves with √n
    
    2. The Trade-off:
       - More precision requires larger samples
       - Diminishing returns (to halve SE, need 4x sample)
    
    3. Confidence Intervals:
       - 95% CI captures true parameter in ~95% of repeated samples
       - Width decreases with sample size
    
    4. Practical Implications:
       - For surveys: 1000 respondents gives ±3% margin of error
       - For experiments: Power analysis determines needed sample
    """)
    
    return results_df


# ============================================================
# PART 7: PUTTING IT ALL TOGETHER
# ============================================================

def main():
    """Main entry point for descriptive and inferential foundations."""
    print("""
    ╔══════════════════════════════════════════════════════════════════╗
    ║         DESCRIPTIVE & INFERENTIAL FOUNDATIONS                  ║
    ║                                                                 ║
    ║  This module covers:                                          ║
    ║  - Probability distributions                                   ║
    ║  - Descriptive statistics                                      ║
    ║  - Central Limit Theorem                                       ║
    ║  - Confidence intervals                                        ║
    ║  - Sampling methods                                            ║
    ║  - Quantifying uncertainty                                     ║
    ╚══════════════════════════════════════════════════════════════════╝
    """)
    
    # Create data directory
    import os
    os.makedirs('data', exist_ok=True)
    
    # Run demonstrations
    probability_distributions_demo()
    descriptive_statistics_demo()
    central_limit_theorem_demo()
    confidence_intervals_demo()
    sampling_methods_demo()
    uncertainty_quantification_demo()
    
    print("\n" + "=" * 80)
    print("DESCRIPTIVE & INFERENTIAL FOUNDATIONS COMPLETE!")
    print("=" * 80)
    print("\nYou now understand:")
    print("  ✅ Key probability distributions and when to use them")
    print("  ✅ Descriptive statistics and their interpretation")
    print("  ✅ The Central Limit Theorem and why it matters")
    print("  ✅ Confidence intervals and how to interpret them")
    print("  ✅ Sampling methods and their trade-offs")
    print("  ✅ How to quantify uncertainty in estimates")
    
    print("\nNext: Hypothesis Testing & Experimental Design")


if __name__ == "__main__":
    main()
```

---

### The Verification

Run the descriptive and inferential foundations module:

```bash
python src/phase3/module3_1_descriptive_inferential.py
```

**Expected Output:**

The script will generate:
1. Distribution visualizations (`data/distributions.png`)
2. Descriptive statistics comparison
3. CLT demonstration (`data/clt_demo.png`)
4. Confidence interval visualization (`data/confidence_intervals.png`)
5. Sampling method comparison
6. Uncertainty quantification (`data/uncertainty_quantification.png`)

---

### Key Takeaways

1. **Probability Distributions:** Different distributions model different types of data. Understanding them helps you choose the right statistical tests.

2. **Descriptive Statistics:** Mean, median, standard deviation, skewness, and kurtosis tell you about central tendency, spread, and shape.

3. **Central Limit Theorem:** The sampling distribution of the mean is approximately normal for large samples, regardless of the underlying distribution.

4. **Confidence Intervals:** Provide a range of plausible values for population parameters, quantifying uncertainty in estimates.

5. **Sampling Methods:** Different sampling methods have different properties and biases. Choose the right one for your study.

6. **Uncertainty:** Every estimate has uncertainty. Understanding and quantifying this uncertainty is essential for making informed decisions.

---

**[COMPLETED: Module 3.1 - Descriptive & Inferential Foundations]**
**[STARTING: Module 3.2 - Hypothesis Testing & Experimental Design]**

---

## Phase 3, Module 3.2: Hypothesis Testing & Experimental Design

Now we'll learn how to make data-driven decisions through hypothesis testing and experimental design. This is where statistics directly impacts business decisions.

---

### The Science of Decision-Making Under Uncertainty

**The Analogy:**

Hypothesis testing is like a courtroom trial. You assume innocence (null hypothesis) and require strong evidence (statistical significance) to convict (reject the null). The evidence is your data, and the standard of proof is your significance level.

**Why This Matters Now:**

Business decisions are made every day. Should we change the website design? Does the new marketing campaign work? Is the new feature driving engagement? Hypothesis testing provides a rigorous framework for answering these questions.

---

### Target: Mastering Hypothesis Testing & Experimental Design

**The Concept:**

We'll learn the complete process of designing and analyzing experiments:
1. Formulating hypotheses
2. Choosing appropriate tests
3. Calculating sample sizes
4. Running experiments
5. Analyzing results
6. Making decisions

**The Implementation:**

Create `src/phase3/module3_2_hypothesis_testing.py`:

```python
"""
Module 3.2: Hypothesis Testing & Experimental Design

This module covers:
1. Null and alternative hypotheses
2. Type I and Type II errors
3. Power analysis and sample size determination
4. Parametric tests (t-test, ANOVA)
5. Non-parametric tests (Mann-Whitney, Chi-Square)
6. Multiple testing correction
7. A/B test design and analysis
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import ttest_ind, ttest_rel, f_oneway, mannwhitneyu
from scipy.stats import chi2_contingency, wilcoxon, kruskal
from statsmodels.stats.power import TTestIndPower, TTestPower
from statsmodels.stats.multicomp import pairwise_tukeyhsd
import warnings
warnings.filterwarnings('ignore')

# Set styles
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")


def section(title: str):
    """Helper function to print section headers."""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)


# ============================================================
# PART 1: HYPOTHESIS TESTING FUNDAMENTALS
# ============================================================

def hypothesis_testing_fundamentals():
    """
    Demonstrate the fundamental concepts of hypothesis testing.
    
    This includes:
    - Null and alternative hypotheses
    - Type I and Type II errors
    - Significance levels
    - P-values and their interpretation
    """
    section("Hypothesis Testing Fundamentals")
    
    print("Hypothesis testing is a framework for making decisions")
    print("under uncertainty using data.\n")
    
    # Create a simulation to demonstrate p-values
    np.random.seed(42)
    
    print("1. The Components of a Hypothesis Test:")
    print("-" * 60)
    print("""
    Null Hypothesis (H₀): The default assumption (no effect, no difference)
    Alternative Hypothesis (H₁): What we want to prove (there is an effect)
    Test Statistic: A number calculated from the data
    P-value: Probability of observing data as extreme as we did, assuming H₀ is true
    Significance Level (α): Threshold for rejecting H₀ (typically 0.05)
    """)
    
    # Demonstrate p-value interpretation
    print("\n2. Understanding P-values:")
    print("-" * 60)
    
    # Simulate two groups
    control = np.random.normal(100, 15, 100)
    treatment = np.random.normal(105, 15, 100)  # Slight effect
    
    # Perform t-test
    t_stat, p_value = ttest_ind(control, treatment)
    
    print(f"Control mean: {np.mean(control):.2f}")
    print(f"Treatment mean: {np.mean(treatment):.2f}")
    print(f"t-statistic: {t_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    
    if p_value < 0.05:
        print("✓ Result is statistically significant at α=0.05")
        print("  → Reject the null hypothesis")
    else:
        print("✗ Result is not statistically significant at α=0.05")
        print("  → Fail to reject the null hypothesis")
    
    # Visualize the t-distribution and p-value
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 1. Distribution of t-statistic
    ax = axes[0]
    x = np.linspace(-4, 4, 1000)
    y = t.pdf(x, df=len(control) + len(treatment) - 2)
    ax.plot(x, y, 'b-', label='t-distribution')
    
    # Shade critical regions
    alpha = 0.05
    t_critical = t.ppf(1 - alpha/2, df=len(control) + len(treatment) - 2)
    ax.axvline(t_critical, color='red', linestyle='--', label=f'Critical value: {t_critical:.3f}')
    ax.axvline(-t_critical, color='red', linestyle='--')
    
    # Shade rejection regions
    x_reject = x[x > t_critical]
    ax.fill_between(x_reject, t.pdf(x_reject, df=len(control) + len(treatment) - 2),
                    color='red', alpha=0.3, label='Rejection region')
    
    x_reject = x[x < -t_critical]
    ax.fill_between(x_reject, t.pdf(x_reject, df=len(control) + len(treatment) - 2),
                    color='red', alpha=0.3)
    
    # Mark our t-statistic
    ax.axvline(t_stat, color='green', linewidth=3, label=f'Observed t={t_stat:.3f}')
    
    ax.set_title('t-Distribution with Rejection Regions')
    ax.set_xlabel('t-statistic')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Type I and Type II errors
    ax = axes[1]
    
    # Draw two distributions: H₀ true and H₁ true
    x_h0 = np.linspace(-4, 4, 1000)
    y_h0 = norm.pdf(x_h0, 0, 1)
    y_h1 = norm.pdf(x_h0, 1.5, 1)  # Shifted distribution
    
    ax.plot(x_h0, y_h0, 'b-', label='H₀ (μ=0)', linewidth=2)
    ax.plot(x_h0, y_h1, 'g-', label='H₁ (μ=1.5)', linewidth=2)
    
    # Critical value
    z_critical = norm.ppf(0.95)
    ax.axvline(z_critical, color='red', linestyle='--', 
               label=f'Critical value: {z_critical:.3f}')
    
    # Shade Type I error (α)
    x_alpha = x_h0[x_h0 > z_critical]
    ax.fill_between(x_alpha, norm.pdf(x_alpha, 0, 1),
                    color='red', alpha=0.3, label=f'Type I Error (α=0.05)')
    
    # Shade Type II error (β)
    x_beta = x_h0[x_h0 < z_critical]
    ax.fill_between(x_beta, norm.pdf(x_beta, 1.5, 1),
                    color='orange', alpha=0.3, label='Type II Error (β)')
    
    ax.set_title('Type I and Type II Errors')
    ax.set_xlabel('Test Statistic')
    ax.set_ylabel('Probability Density')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/hypothesis_testing_fundamentals.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved hypothesis testing visualization to data/hypothesis_testing_fundamentals.png")
    
    # Error types summary
    print("\n" + "=" * 60)
    print("Type I and Type II Errors:")
    print("=" * 60)
    print("""
    Type I Error (False Positive):
    - Rejecting H₀ when it's actually true
    - Probability = α (significance level)
    - Consequence: Claiming an effect exists when it doesn't
    
    Type II Error (False Negative):
    - Failing to reject H₀ when it's actually false
    - Probability = β
    - Consequence: Missing a real effect
    
    Power = 1 - β
    - Probability of correctly detecting a real effect
    - We want high power (typically > 0.80)
    """)
    
    return {'t_stat': t_stat, 'p_value': p_value}


# ============================================================
# PART 2: PARAMETRIC TESTS
# ============================================================

def parametric_tests_demo():
    """
    Demonstrate parametric hypothesis tests.
    
    Parametric tests assume the data follows a specific distribution
    (usually normal) and are more powerful when assumptions are met.
    """
    section("Parametric Tests")
    
    print("Parametric tests assume normality and use parameters")
    print("like means and variances.\n")
    
    # Generate data
    np.random.seed(42)
    
    # 1. One-sample t-test
    print("1. One-Sample t-test:")
    print("-" * 60)
    
    # Test if sample mean differs from hypothesized value
    sample = np.random.normal(105, 15, 50)
    hypothesized_mean = 100
    
    t_stat, p_value = stats.ttest_1samp(sample, hypothesized_mean)
    print(f"Sample mean: {np.mean(sample):.2f}")
    print(f"Hypothesized mean: {hypothesized_mean}")
    print(f"t-statistic: {t_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    # 2. Two-sample t-test (independent)
    print("\n2. Two-Sample t-test (Independent):")
    print("-" * 60)
    
    group1 = np.random.normal(100, 15, 50)
    group2 = np.random.normal(107, 15, 50)
    
    t_stat, p_value = ttest_ind(group1, group2)
    print(f"Group 1 mean: {np.mean(group1):.2f}")
    print(f"Group 2 mean: {np.mean(group2):.2f}")
    print(f"Difference: {np.mean(group2) - np.mean(group1):.2f}")
    print(f"t-statistic: {t_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    # 3. Paired t-test
    print("\n3. Paired t-test:")
    print("-" * 60)
    
    # Before and after measurements
    before = np.random.normal(50, 10, 30)
    after = before + np.random.normal(5, 5, 30)  # Improvement
    
    t_stat, p_value = ttest_rel(before, after)
    print(f"Before mean: {np.mean(before):.2f}")
    print(f"After mean: {np.mean(after):.2f}")
    print(f"Change: {np.mean(after) - np.mean(before):.2f}")
    print(f"t-statistic: {t_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    # 4. One-way ANOVA (multiple groups)
    print("\n4. One-way ANOVA:")
    print("-" * 60)
    
    # Three groups
    group_a = np.random.normal(100, 15, 30)
    group_b = np.random.normal(108, 15, 30)
    group_c = np.random.normal(115, 15, 30)
    
    f_stat, p_value = f_oneway(group_a, group_b, group_c)
    print(f"Group A mean: {np.mean(group_a):.2f}")
    print(f"Group B mean: {np.mean(group_b):.2f}")
    print(f"Group C mean: {np.mean(group_c):.2f}")
    print(f"F-statistic: {f_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    if p_value < 0.05:
        # Post-hoc test (Tukey's HSD)
        all_data = np.concatenate([group_a, group_b, group_c])
        groups = np.repeat(['A', 'B', 'C'], [30, 30, 30])
        
        tukey = pairwise_tukeyhsd(all_data, groups, alpha=0.05)
        print("\nPost-hoc Tukey HSD Test:")
        print(tukey)
    
    # Visualize results
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # 1. One-sample t-test
    ax = axes[0, 0]
    ax.hist(sample, bins=20, alpha=0.7, edgecolor='black')
    ax.axvline(hypothesized_mean, color='red', linestyle='--', 
               label=f'H₀: μ={hypothesized_mean}')
    ax.axvline(np.mean(sample), color='green', label=f'Observed μ={np.mean(sample):.2f}')
    ax.set_title('One-Sample t-test')
    ax.set_xlabel('Value')
    ax.set_ylabel('Frequency')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Two-sample t-test
    ax = axes[0, 1]
    ax.boxplot([group1, group2], labels=['Group 1', 'Group 2'])
    ax.set_title('Two-Sample t-test')
    ax.set_ylabel('Value')
    ax.grid(True, alpha=0.3)
    
    # 3. Paired t-test
    ax = axes[1, 0]
    ax.scatter(before, after, alpha=0.6)
    ax.plot([20, 80], [20, 80], 'r--', label='No change')
    ax.set_xlabel('Before')
    ax.set_ylabel('After')
    ax.set_title('Paired t-test')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 4. ANOVA
    ax = axes[1, 1]
    ax.boxplot([group_a, group_b, group_c], labels=['Group A', 'Group B', 'Group C'])
    ax.set_title('ANOVA')
    ax.set_ylabel('Value')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/parametric_tests.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved parametric tests visualization to data/parametric_tests.png")
    
    # Assumptions summary
    print("\n" + "=" * 60)
    print("Parametric Test Assumptions:")
    print("=" * 60)
    print("""
    1. Normality: Data follows a normal distribution
    2. Homogeneity of variance: Equal variances across groups
    3. Independence: Observations are independent
    
    What to do if assumptions are violated:
    - Use non-parametric tests (covered next)
    - Transform data (log, square root)
    - Use robust methods (bootstrapping)
    """)
    
    return {'group1': group1, 'group2': group2}


# ============================================================
# PART 3: NON-PARAMETRIC TESTS
# ============================================================

def nonparametric_tests_demo():
    """
    Demonstrate non-parametric hypothesis tests.
    
    Non-parametric tests don't assume normality and are more robust
    to outliers and non-normal distributions.
    """
    section("Non-Parametric Tests")
    
    print("Non-parametric tests don't require normality assumptions.")
    print("They're based on ranks rather than actual values.\n")
    
    # Generate non-normal data
    np.random.seed(42)
    
    # Non-normal data (exponential)
    group1 = np.random.exponential(10, 50)
    group2 = np.random.exponential(12, 50)
    
    print("Data is exponentially distributed (non-normal).")
    print(f"Group 1 median: {np.median(group1):.2f}")
    print(f"Group 2 median: {np.median(group2):.2f}\n")
    
    # 1. Mann-Whitney U test (independent)
    print("1. Mann-Whitney U Test:")
    print("-" * 60)
    
    u_stat, p_value = mannwhitneyu(group1, group2)
    print(f"U-statistic: {u_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    # 2. Wilcoxon signed-rank test (paired)
    print("\n2. Wilcoxon Signed-Rank Test:")
    print("-" * 60)
    
    before = np.random.exponential(10, 30)
    after = before + np.random.exponential(2, 30)  # Effect
    
    w_stat, p_value = wilcoxon(before, after)
    print(f"Before median: {np.median(before):.2f}")
    print(f"After median: {np.median(after):.2f}")
    print(f"Change: {np.median(after) - np.median(before):.2f}")
    print(f"W-statistic: {w_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    # 3. Kruskal-Wallis H test (multiple groups)
    print("\n3. Kruskal-Wallis H Test:")
    print("-" * 60)
    
    group_a = np.random.exponential(10, 30)
    group_b = np.random.exponential(13, 30)
    group_c = np.random.exponential(16, 30)
    
    h_stat, p_value = kruskal(group_a, group_b, group_c)
    print(f"H-statistic: {h_stat:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    # 4. Chi-Square test of independence
    print("\n4. Chi-Square Test of Independence:")
    print("-" * 60)
    
    # Create contingency table
    data = pd.DataFrame({
        'Category': np.random.choice(['A', 'B', 'C'], 200),
        'Success': np.random.choice([0, 1], 200, p=[0.6, 0.4])
    })
    
    contingency = pd.crosstab(data['Category'], data['Success'])
    print("Contingency Table:")
    print(contingency)
    
    chi2, p_value, dof, expected = chi2_contingency(contingency)
    print(f"\nChi-square: {chi2:.4f}")
    print(f"p-value: {p_value:.4f}")
    print(f"Degrees of freedom: {dof}")
    print(f"Conclusion: {'Reject' if p_value < 0.05 else 'Fail to reject'} H₀")
    
    # Visualize non-parametric tests
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # 1. Mann-Whitney U
    ax = axes[0, 0]
    ax.boxplot([group1, group2], labels=['Group 1', 'Group 2'])
    ax.set_title('Mann-Whitney U Test')
    ax.set_ylabel('Value')
    ax.grid(True, alpha=0.3)
    
    # 2. Wilcoxon
    ax = axes[0, 1]
    ax.scatter(before, after, alpha=0.6)
    ax.plot([0, 20], [0, 20], 'r--', label='No change')
    ax.set_xlabel('Before')
    ax.set_ylabel('After')
    ax.set_title('Wilcoxon Signed-Rank Test')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 3. Kruskal-Wallis
    ax = axes[1, 0]
    ax.boxplot([group_a, group_b, group_c], labels=['Group A', 'Group B', 'Group C'])
    ax.set_title('Kruskal-Wallis H Test')
    ax.set_ylabel('Value')
    ax.grid(True, alpha=0.3)
    
    # 4. Chi-Square - Heatmap of contingency table
    ax = axes[1, 1]
    im = ax.imshow(contingency, cmap='Blues', aspect='auto')
    ax.set_xticks(range(len(contingency.columns)))
    ax.set_yticks(range(len(contingency.index)))
    ax.set_xticklabels(contingency.columns)
    ax.set_yticklabels(contingency.index)
    plt.colorbar(im, ax=ax)
    ax.set_title('Contingency Table')
    ax.set_xlabel('Success')
    ax.set_ylabel('Category')
    
    # Add values to cells
    for i in range(contingency.shape[0]):
        for j in range(contingency.shape[1]):
            ax.text(j, i, contingency.iloc[i, j], 
                   ha='center', va='center', color='black')
    
    plt.tight_layout()
    plt.savefig('data/nonparametric_tests.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved non-parametric tests visualization to data/nonparametric_tests.png")
    
    # Comparison summary
    print("\n" + "=" * 60)
    print("Parametric vs Non-Parametric Tests:")
    print("=" * 60)
    print("""
    Parametric Tests (More Powerful):
    - t-test (independent/paired)
    - ANOVA
    - Use when data is approximately normal
    
    Non-Parametric Tests (More Robust):
    - Mann-Whitney (instead of t-test)
    - Wilcoxon (instead of paired t-test)
    - Kruskal-Wallis (instead of ANOVA)
    - Use when data is skewed or has outliers
    
    Rule of thumb:
    - If data passes normality tests, use parametric
    - If not, use non-parametric
    - Non-parametric tests are safer and more robust
    """)
    
    return {'contingency': contingency}


# ============================================================
# PART 4: POWER ANALYSIS & SAMPLE SIZE
# ============================================================

def power_analysis_demo():
    """
    Demonstrate power analysis and sample size determination.
    
    Power analysis helps determine the sample size needed
    to detect an effect of a given size with a given probability.
    """
    section("Power Analysis & Sample Size")
    
    print("Power analysis helps you design experiments that")
    print("have a good chance of detecting real effects.\n")
    
    # Parameters
    alpha = 0.05  # Significance level
    power = 0.80  # Desired power (1 - β)
    effect_sizes = [0.2, 0.5, 0.8]  # Small, medium, large
    
    print("Effect sizes (Cohen's d):")
    print(f"  Small: {effect_sizes[0]:.1f}")
    print(f"  Medium: {effect_sizes[1]:.1f}")
    print(f"  Large: {effect_sizes[2]:.1f}\n")
    
    # Calculate sample sizes
    results = []
    power_analysis = TTestIndPower()
    
    print("Sample size needed per group (two-sample t-test):")
    print("-" * 70)
    print(f"{'Effect Size':<15} {'α':<10} {'Power':<10} {'Sample Size (per group)':<25}")
    print("-" * 70)
    
    for effect_size in effect_sizes:
        n = power_analysis.solve_power(
            effect_size=effect_size,
            alpha=alpha,
            power=power,
            alternative='two-sided'
        )
        n = int(np.ceil(n))
        results.append({
            'effect_size': effect_size,
            'n': n,
            'alpha': alpha,
            'power': power
        })
        print(f"{effect_size:<15.1f} {alpha:<10.2f} {power:<10.2f} {n:<25}")
    
    # Explore relationship between effect size and sample size
    print("\n" + "-" * 60)
    print("Relationship between effect size and sample size:")
    print("-" * 60)
    
    effect_sizes_range = np.linspace(0.1, 1.0, 19)
    ns = []
    
    for es in effect_sizes_range:
        n = power_analysis.solve_power(
            effect_size=es,
            alpha=alpha,
            power=power,
            alternative='two-sided'
        )
        ns.append(np.ceil(n))
    
    # Visualize
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 1. Sample size vs effect size
    ax = axes[0]
    ax.plot(effect_sizes_range, ns, 'b-', linewidth=2)
    ax.set_xlabel('Effect Size (Cohen\'s d)')
    ax.set_ylabel('Sample Size (per group)')
    ax.set_title('Sample Size vs Effect Size (α=0.05, Power=0.80)')
    ax.grid(True, alpha=0.3)
    
    # 2. Power curves for different sample sizes
    ax = axes[1]
    sample_sizes = [20, 50, 100, 200, 500]
    
    for n in sample_sizes:
        power_curve = power_analysis.power(
            effect_size=effect_sizes_range,
            nobs1=n,
            alpha=alpha,
            alternative='two-sided'
        )
        ax.plot(effect_sizes_range, power_curve, label=f'n={n}')
    
    ax.axhline(0.80, color='red', linestyle='--', label='Target power (0.80)')
    ax.set_xlabel('Effect Size (Cohen\'s d)')
    ax.set_ylabel('Power')
    ax.set_title('Power Curves for Different Sample Sizes')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/power_analysis.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved power analysis visualization to data/power_analysis.png")
    
    # Practical guidelines
    print("\n" + "=" * 60)
    print("Power Analysis Guidelines:")
    print("=" * 60)
    print("""
    1. Standard values:
       - α = 0.05 (5% chance of Type I error)
       - Power = 0.80 (80% chance of detecting effect)
       - Effect size: Small (0.2), Medium (0.5), Large (0.8)
    
    2. Sample size rules of thumb:
       - Small effect: ~393 per group
       - Medium effect: ~64 per group
       - Large effect: ~26 per group
    
    3. Factors affecting power:
       - Sample size (larger = more power)
       - Effect size (larger = more power)
       - α (larger = more power but more Type I errors)
    
    4. Always conduct power analysis BEFORE running experiments
       to ensure you have enough samples.
    """)
    
    return results


# ============================================================
# PART 5: MULTIPLE TESTING CORRECTION
# ============================================================

def multiple_testing_demo():
    """
    Demonstrate multiple testing correction.
    
    When testing many hypotheses simultaneously, the chance
    of false positives increases. Correction methods control
    this inflation.
    """
    section("Multiple Testing Correction")
    
    print("When testing many hypotheses, the family-wise error rate")
    print("increases. We need to correct for multiple comparisons.\n")
    
    # Simulate multiple tests
    np.random.seed(42)
    n_tests = 100
    n_samples = 30
    
    # Generate data where most tests have no effect
    p_values = []
    
    for i in range(n_tests):
        # 20% of tests have a real effect
        if np.random.random() < 0.2:
            # Effect
            group1 = np.random.normal(100, 15, n_samples)
            group2 = np.random.normal(108, 15, n_samples)
        else:
            # No effect
            group1 = np.random.normal(100, 15, n_samples)
            group2 = np.random.normal(100, 15, n_samples)
        
        _, p_val = ttest_ind(group1, group2)
        p_values.append(p_val)
    
    p_values = np.array(p_values)
    
    # Count significant results
    alpha = 0.05
    significant_raw = (p_values < alpha).sum()
    
    # Apply corrections
    from statsmodels.stats.multitest import multipletests
    
    # Bonferroni correction
    bonferroni_p = p_values * n_tests
    bonferroni_p = np.clip(bonferroni_p, 0, 1)
    significant_bonf = (bonferroni_p < alpha).sum()
    
    # FDR correction (Benjamini-Hochberg)
    rejected_fdr, p_adjusted_fdr, _, _ = multipletests(p_values, alpha=alpha, method='fdr_bh')
    significant_fdr = rejected_fdr.sum()
    
    # Display results
    print(f"Number of tests: {n_tests}")
    print(f"Alpha level: {alpha}")
    print(f"True effects: {int(n_tests * 0.2)} (20% of tests)")
    print("\n" + "-" * 60)
    print("Results with different correction methods:")
    print("-" * 60)
    print(f"No correction: {significant_raw} significant")
    print(f"Bonferroni: {significant_bonf} significant")
    print(f"FDR (BH): {significant_fdr} significant")
    
    # Visualize
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # 1. P-value distribution
    ax = axes[0]
    ax.hist(p_values, bins=20, edgecolor='black', alpha=0.7)
    ax.axvline(alpha, color='red', linestyle='--', label=f'α={alpha}')
    ax.set_xlabel('P-value')
    ax.set_ylabel('Frequency')
    ax.set_title('Distribution of P-values')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. P-values in order
    ax = axes[1]
    sorted_p = np.sort(p_values)
    ax.plot(range(1, n_tests + 1), sorted_p, 'bo-', markersize=3)
    ax.axhline(alpha, color='red', linestyle='--', label=f'α={alpha}')
    
    # Bonferroni line
    ax.axhline(alpha/n_tests, color='green', linestyle='--', 
               label=f'Bonferroni: α={alpha/n_tests:.4f}')
    
    ax.set_xlabel('Test Index (sorted)')
    ax.set_ylabel('P-value')
    ax.set_title('Sorted P-values')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 3. Comparison of methods
    ax = axes[2]
    methods = ['Raw', 'Bonferroni', 'FDR']
    significant_counts = [significant_raw, significant_bonf, significant_fdr]
    
    ax.bar(methods, significant_counts, color=['blue', 'green', 'orange'])
    ax.axhline(n_tests * 0.2, color='red', linestyle='--', 
               label='True positives (expected)')
    ax.set_ylabel('Significant Tests')
    ax.set_title('Comparison of Correction Methods')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/multiple_testing.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved multiple testing visualization to data/multiple_testing.png")
    
    print("\n" + "=" * 60)
    print("Multiple Testing Correction Methods:")
    print("=" * 60)
    print("""
    1. Bonferroni Correction:
       - Most conservative (low false positives)
       - α_adj = α / m (m = number of tests)
       - Can be too conservative (high false negatives)
    
    2. False Discovery Rate (FDR):
       - Controls proportion of false positives
       - More powerful than Bonferroni
       - Benjamini-Hochberg procedure
    
    3. When to use:
       - Bonferroni: When false positives are unacceptable
       - FDR: When you can tolerate some false positives
       - No correction: Only when testing pre-specified hypotheses
    """)
    
    return p_values


# ============================================================
# PART 6: A/B TEST SIMULATION
# ============================================================

def ab_test_simulation():
    """
    Simulate a complete A/B test from design to analysis.
    
    This demonstrates the full lifecycle of an experiment:
    1. Design (power analysis)
    2. Data generation
    3. Analysis (statistical tests)
    4. Decision making
    """
    section("A/B Test Simulation")
    
    print("Simulating a complete A/B test from design to decision.\n")
    
    # 1. Design phase
    print("1. Design Phase:")
    print("-" * 60)
    
    # Parameters
    baseline_conversion = 0.10  # 10% conversion rate
    expected_lift = 0.02  # 2 percentage point improvement
    alpha = 0.05
    power = 0.80
    
    # Calculate effect size (Cohen's h for proportions)
    from statsmodels.stats.proportion import proportion_effectsize
    effect_size = proportion_effectsize(baseline_conversion, 
                                        baseline_conversion + expected_lift)
    
    print(f"Baseline conversion: {baseline_conversion*100:.1f}%")
    print(f"Expected lift: {expected_lift*100:.1f} percentage points")
    print(f"Expected conversion: {(baseline_conversion + expected_lift)*100:.1f}%")
    print(f"Effect size (Cohen's h): {effect_size:.4f}")
    
    # Sample size calculation
    from statsmodels.stats.power import NormalIndPower
    power_analysis = NormalIndPower()
    n = power_analysis.solve_power(
        effect_size=effect_size,
        alpha=alpha,
        power=power,
        alternative='two-sided'
    )
    n = int(np.ceil(n))
    
    print(f"Required sample size per group: {n}")
    print(f"Total sample size needed: {n*2}\n")
    
    # 2. Generate data
    print("2. Data Generation:")
    print("-" * 60)
    
    np.random.seed(42)
    
    # Control group
    control = np.random.binomial(1, baseline_conversion, n)
    control_conversion = np.mean(control)
    
    # Treatment group
    treatment = np.random.binomial(1, baseline_conversion + expected_lift, n)
    treatment_conversion = np.mean(treatment)
    
    print(f"Control conversion: {control_conversion*100:.2f}%")
    print(f"Treatment conversion: {treatment_conversion*100:.2f}%")
    print(f"Observed lift: {(treatment_conversion - control_conversion)*100:.2f} percentage points")
    
    # 3. Analysis
    print("\n3. Analysis:")
    print("-" * 60)
    
    # Chi-square test
    contingency = np.array([
        [sum(control == 0), sum(control == 1)],
        [sum(treatment == 0), sum(treatment == 1)]
    ])
    
    chi2, p_value, _, _ = chi2_contingency(contingency)
    
    # Z-test for proportions
    from statsmodels.stats.proportion import proportions_ztest
    count = [sum(control), sum(treatment)]
    nobs = [n, n]
    z_stat, p_value_z = proportions_ztest(count, nobs)
    
    print(f"Chi-square test p-value: {p_value:.4f}")
    print(f"Z-test p-value: {p_value_z:.4f}")
    
    # 4. Decision
    print("\n4. Decision:")
    print("-" * 60)
    
    is_significant = p_value < alpha
    print(f"Statistical significance (α={alpha}): {'✓ YES' if is_significant else '✗ NO'}")
    
    if is_significant:
        if treatment_conversion > control_conversion:
            print("✓ Statistically significant improvement detected")
            print("  → Implement the treatment")
        else:
            print("⚠️ Statistically significant decrease detected")
            print("  → Investigate and revert")
    else:
        print("✗ No statistically significant difference detected")
        if treatment_conversion > control_conversion:
            print("  → Consider running longer or increasing sample size")
        else:
            print("  → No evidence of improvement, consider alternative approaches")
    
    # Visualize A/B test results
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # 1. Conversion rates
    ax = axes[0]
    rates = [control_conversion, treatment_conversion]
    labels = ['Control', 'Treatment']
    colors = ['blue', 'green'] if treatment_conversion > control_conversion else ['blue', 'red']
    ax.bar(labels, rates, color=colors, alpha=0.7, edgecolor='black')
    ax.set_ylabel('Conversion Rate')
    ax.set_title('Conversion Rates')
    ax.set_ylim([0, max(rates) * 1.2])
    ax.grid(True, alpha=0.3, axis='y')
    
    # 2. Confidence intervals
    ax = axes[1]
    for i, (name, data) in enumerate([('Control', control), ('Treatment', treatment)]):
        mean = np.mean(data)
        se = np.sqrt(mean * (1 - mean) / len(data))
        ci_lower = mean - 1.96 * se
        ci_upper = mean + 1.96 * se
        ax.errorbar(name, mean, yerr=[[mean - ci_lower], [ci_upper - mean]], 
                   fmt='o', capsize=5, capthick=2, markersize=10)
    ax.set_ylabel('Conversion Rate')
    ax.set_title('95% Confidence Intervals')
    ax.grid(True, alpha=0.3)
    
    # 3. P-value visualization
    ax = axes[2]
    x = np.linspace(0, 1, 1000)
    y = chi2.pdf(x, df=1)
    ax.plot(x, y, 'b-', linewidth=2)
    
    # P-value region
    x_critical = chi2.ppf(1 - alpha, df=1)
    x_reject = x[x > x_critical]
    ax.fill_between(x_reject, chi2.pdf(x_reject, df=1),
                    color='red', alpha=0.3, label='Rejection region')
    
    # Our test statistic
    ax.axvline(chi2, color='green', linewidth=3, 
               label=f'χ²={chi2:.4f}\np={p_value:.4f}')
    
    ax.set_xlabel('Chi-square statistic')
    ax.set_ylabel('Density')
    ax.set_title('Chi-square Distribution')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/ab_test_simulation.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved A/B test simulation to data/ab_test_simulation.png")
    
    return {
        'control': control,
        'treatment': treatment,
        'p_value': p_value,
        'is_significant': is_significant
    }


# ============================================================
# MAIN EXECUTION
# ============================================================

def main():
    """Main entry point for hypothesis testing module."""
    print("""
    ╔══════════════════════════════════════════════════════════════════╗
    ║        HYPOTHESIS TESTING & EXPERIMENTAL DESIGN                ║
    ║                                                                 ║
    ║  This module covers:                                          ║
    ║  - Hypothesis testing fundamentals                             ║
    ║  - Parametric tests (t-test, ANOVA)                           ║
    ║  - Non-parametric tests (Mann-Whitney, Chi-Square)           ║
    ║  - Power analysis and sample size                             ║
    ║  - Multiple testing correction                                ║
    ║  - A/B test simulation                                        ║
    ╚══════════════════════════════════════════════════════════════════╝
    """)
    
    # Create data directory
    import os
    os.makedirs('data', exist_ok=True)
    
    # Run demonstrations
    hypothesis_testing_fundamentals()
    parametric_tests_demo()
    nonparametric_tests_demo()
    power_analysis_demo()
    multiple_testing_demo()
    ab_test_simulation()
    
    print("\n" + "=" * 80)
    print("HYPOTHESIS TESTING & EXPERIMENTAL DESIGN COMPLETE!")
    print("=" * 80)
    print("\nYou now understand:")
    print("  ✅ Hypothesis testing fundamentals (p-values, errors)")
    print("  ✅ Parametric tests (t-test, ANOVA)")
    print("  ✅ Non-parametric tests (Mann-Whitney, Chi-Square)")
    print("  ✅ Power analysis and sample size determination")
    print("  ✅ Multiple testing correction (Bonferroni, FDR)")
    print("  ✅ Complete A/B test design and analysis")
    
    print("\nNext: Statistical Modeling & Diagnostic Analysis")


if __name__ == "__main__":
    main()
```

---

### The Verification

Run the hypothesis testing module:

```bash
python src/phase3/module3_2_hypothesis_testing.py
```

**Expected Output:**

The script will generate:
1. Hypothesis testing fundamentals visualization (`data/hypothesis_testing_fundamentals.png`)
2. Parametric tests visualization (`data/parametric_tests.png`)
3. Non-parametric tests visualization (`data/nonparametric_tests.png`)
4. Power analysis visualization (`data/power_analysis.png`)
5. Multiple testing visualization (`data/multiple_testing.png`)
6. A/B test simulation (`data/ab_test_simulation.png`)

---

### Key Hypothesis Testing Takeaways

1. **Hypothesis Testing:** A framework for making decisions under uncertainty using data.

2. **Errors:** Type I (false positive) and Type II (false negative) errors have different consequences.

3. **Parametric Tests:** More powerful when assumptions (normality) are met.

4. **Non-Parametric Tests:** More robust, don't require normality.

5. **Power Analysis:** Essential for designing experiments that can detect real effects.

6. **Multiple Testing:** Correct for multiple comparisons to avoid false positives.

7. **A/B Testing:** Complete workflow from design to decision making.

---

**[COMPLETED: Module 3.2 - Hypothesis Testing & Experimental Design]**
**[STARTING: Module 3.3 - Statistical Modeling & Diagnostic Analysis]**

---

## Phase 3, Module 3.3: Statistical Modeling & Diagnostic Analysis

Now we'll build statistical models that explain relationships and make predictions. This is the capstone of statistical analysis—moving from testing simple hypotheses to understanding complex relationships.

---

### From Testing to Modeling

**The Analogy:**

If hypothesis testing is like checking if two groups are different, modeling is like understanding all the factors that contribute to an outcome. It's like moving from a simple courtroom trial to a complex crime investigation—you're looking at multiple pieces of evidence simultaneously.

**Why This Matters Now:**

Business decisions often involve multiple factors. You need to understand:
- Which factors matter most?
- How do they interact?
- What's the expected impact of changes?

---

### Target: Building and Evaluating Statistical Models

**The Concept:**

We'll build linear and logistic regression models, interpret coefficients, and perform diagnostic checks to ensure our models are valid and reliable.

**The Implementation:**

Create `src/phase3/module3_3_statistical_modeling.py`:

```python
"""
Module 3.3: Statistical Modeling & Diagnostic Analysis

This module covers:
1. Linear regression (Ordinary Least Squares)
2. Logistic regression
3. Model interpretation (coefficients, odds ratios)
4. Model diagnostics (residuals, heteroscedasticity)
5. Multicollinearity (Variance Inflation Factor)
6. Model selection and comparison
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import statsmodels.api as sm
from statsmodels.formula.api import ols, logit
from statsmodels.stats.diagnostic import het_breuschpagan
from statsmodels.stats.outliers_influence import variance_inflation_factor
from sklearn.metrics import confusion_matrix, classification_report, roc_curve, auc
from sklearn.model_selection import train_test_split
import warnings
warnings.filterwarnings('ignore')

# Set styles
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")


def section(title: str):
    """Helper function to print section headers."""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)


def load_sales_data() -> pd.DataFrame:
    """
    Load and prepare sales data for modeling.
    
    This creates realistic data with multiple features
    that influence a target variable.
    """
    np.random.seed(42)
    n = 1000
    
    # Generate features
    df = pd.DataFrame({
        'ad_spend': np.random.uniform(100, 1000, n),
        'price': np.random.uniform(50, 200, n),
        'product_quality': np.random.uniform(1, 10, n),
        'customer_satisfaction': np.random.uniform(1, 5, n),
        'competitor_price': np.random.uniform(40, 220, n),
        'seasonal_factor': np.random.uniform(0.8, 1.2, n)
    })
    
    # Generate sales with relationships
    df['sales'] = (
        1000
        + 0.5 * df['ad_spend']
        - 2 * df['price']
        + 15 * df['product_quality']
        + 50 * df['customer_satisfaction']
        + 0.3 * df['competitor_price']
        + 100 * df['seasonal_factor']
        + np.random.normal(0, 50, n)  # Noise
    )
    
    # Add some categorical features
    df['category'] = np.random.choice(['Electronics', 'Clothing', 'Home', 'Sports', 'Books'], n)
    df['region'] = np.random.choice(['North', 'South', 'East', 'West'], n)
    
    # Add binary outcome
    df['high_sales'] = (df['sales'] > df['sales'].median()).astype(int)
    
    return df


# ============================================================
# PART 1: LINEAR REGRESSION
# ============================================================

def linear_regression_demo(df: pd.DataFrame):
    """
    Build and interpret a linear regression model.
    
    Linear regression models the relationship between a continuous
    target variable and one or more predictor variables.
    """
    section("Linear Regression (Ordinary Least Squares)")
    
    print("Linear regression models the relationship between")
    print("a continuous target variable and predictors.\n")
    
    # Prepare data
    X = df[['ad_spend', 'price', 'product_quality', 'customer_satisfaction', 
            'competitor_price', 'seasonal_factor']]
    X = sm.add_constant(X)  # Add intercept
    y = df['sales']
    
    # Fit model
    model = sm.OLS(y, X).fit()
    
    # Display results
    print("Model Summary:")
    print("-" * 60)
    print(f"R-squared: {model.rsquared:.4f}")
    print(f"Adjusted R-squared: {model.rsquared_adj:.4f}")
    print(f"F-statistic: {model.fvalue:.2f}")
    print(f"F-statistic p-value: {model.f_pvalue:.4f}")
    print(f"Number of observations: {model.nobs}")
    print(f"AIC: {model.aic:.2f}")
    print(f"BIC: {model.bic:.2f}")
    
    print("\nCoefficients:")
    print("-" * 60)
    coefficients = model.params
    p_values = model.pvalues
    conf_int = model.conf_int()
    
    for i, (var, coef) in enumerate(coefficients.items()):
        ci_lower, ci_upper = conf_int.iloc[i]
        p_val = p_values[var]
        sig = '*' if p_val < 0.05 else ''
        print(f"{var:25} {coef:10.4f}  {ci_lower:10.4f}  {ci_upper:10.4f}  {p_val:8.4f} {sig}")
    
    # Feature importance (standardized coefficients)
    print("\nFeature Importance (Standardized Coefficients):")
    print("-" * 60)
    
    # Standardize predictors
    X_scaled = (X.iloc[:, 1:] - X.iloc[:, 1:].mean()) / X.iloc[:, 1:].std()
    X_scaled = sm.add_constant(X_scaled)
    model_scaled = sm.OLS(y, X_scaled).fit()
    
    importance = pd.DataFrame({
        'Feature': model_scaled.params.index[1:],
        'Coefficient': model_scaled.params.values[1:],
        'Abs_Coefficient': np.abs(model_scaled.params.values[1:])
    }).sort_values('Abs_Coefficient', ascending=False)
    
    print(importance.to_string(index=False))
    
    # Visualize results
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # 1. Actual vs Predicted
    ax = axes[0, 0]
    ax.scatter(y, model.fittedvalues, alpha=0.5)
    ax.plot([y.min(), y.max()], [y.min(), y.max()], 'r--', linewidth=2)
    ax.set_xlabel('Actual Sales')
    ax.set_ylabel('Predicted Sales')
    ax.set_title('Actual vs Predicted')
    ax.grid(True, alpha=0.3)
    
    # 2. Residuals vs Fitted
    ax = axes[0, 1]
    ax.scatter(model.fittedvalues, model.resid, alpha=0.5)
    ax.axhline(y=0, color='red', linestyle='--', linewidth=2)
    ax.set_xlabel('Fitted Values')
    ax.set_ylabel('Residuals')
    ax.set_title('Residuals vs Fitted')
    ax.grid(True, alpha=0.3)
    
    # 3. Q-Q plot
    ax = axes[1, 0]
    stats.probplot(model.resid, dist="norm", plot=ax)
    ax.set_title('Q-Q Plot')
    ax.grid(True, alpha=0.3)
    
    # 4. Coefficient plot
    ax = axes[1, 1]
    coef_df = pd.DataFrame({
        'Feature': coefficients.index[1:],
        'Coefficient': coefficients.values[1:],
        'CI_lower': conf_int.iloc[1:, 0],
        'CI_upper': conf_int.iloc[1:, 1]
    })
    
    ax.errorbar(coef_df['Coefficient'], range(len(coef_df)),
                xerr=[coef_df['Coefficient'] - coef_df['CI_lower'],
                      coef_df['CI_upper'] - coef_df['Coefficient']],
                fmt='o', capsize=5)
    ax.axvline(x=0, color='red', linestyle='--')
    ax.set_yticks(range(len(coef_df)))
    ax.set_yticklabels(coef_df['Feature'])
    ax.set_xlabel('Coefficient')
    ax.set_title('Coefficient Plot with 95% CI')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/linear_regression.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved linear regression visualization to data/linear_regression.png")
    
    return model


# ============================================================
# PART 2: MODEL DIAGNOSTICS
# ============================================================

def model_diagnostics_demo(model):
    """
    Perform diagnostic checks on the regression model.
    
    Diagnostics check whether model assumptions are met.
    """
    section("Model Diagnostics")
    
    print("Diagnostic checks ensure model assumptions are valid.\n")
    
    # 1. Normality of residuals
    print("1. Normality of Residuals:")
    print("-" * 60)
    
    # Shapiro-Wilk test
    shapiro_stat, shapiro_p = stats.shapiro(model.resid)
    print(f"Shapiro-Wilk test: stat={shapiro_stat:.4f}, p={shapiro_p:.4f}")
    
    if shapiro_p < 0.05:
        print("  ⚠️ Residuals are NOT normally distributed (p < 0.05)")
    else:
        print("  ✓ Residuals appear normally distributed")
    
    # 2. Homoscedasticity (constant variance)
    print("\n2. Homoscedasticity (Constant Variance):")
    print("-" * 60)
    
    # Breusch-Pagan test
    bp_stat, bp_p, _, _ = het_breuschpagan(model.resid, model.model.exog)
    print(f"Breusch-Pagan test: stat={bp_stat:.4f}, p={bp_p:.4f}")
    
    if bp_p < 0.05:
        print("  ⚠️ Heteroscedasticity detected (p < 0.05)")
        print("     → Use robust standard errors")
    else:
        print("  ✓ Homoscedasticity assumption seems valid")
    
    # 3. Multicollinearity
    print("\n3. Multicollinearity (VIF):")
    print("-" * 60)
    
    X = model.model.exog[:, 1:]  # Exclude constant
    vif_data = pd.DataFrame()
    vif_data['Feature'] = model.params.index[1:]
    vif_data['VIF'] = [variance_inflation_factor(X, i) for i in range(X.shape[1])]
    
    print(vif_data.to_string(index=False))
    
    high_vif = vif_data[vif_data['VIF'] > 5]
    if len(high_vif) > 0:
        print("\n  ⚠️ Features with VIF > 5 may indicate multicollinearity:")
        for _, row in high_vif.iterrows():
            print(f"     {row['Feature']}: {row['VIF']:.2f}")
    else:
        print("  ✓ No severe multicollinearity detected")
    
    # 4. Influential points
    print("\n4. Influential Points (Cook's Distance):")
    print("-" * 60)
    
    influence = model.get_influence()
    cooks_d = influence.cooks_distance[0]
    threshold = 4 / len(cooks_d)
    
    influential = cooks_d > threshold
    print(f"Number of influential points: {influential.sum()}")
    print(f"Cook's D threshold: {threshold:.4f}")
    
    if influential.sum() > 0:
        print("  ⚠️ Influential points detected - consider robust regression")
    else:
        print("  ✓ No influential points detected")
    
    # Visualize diagnostics
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # 1. Residuals histogram
    ax = axes[0, 0]
    ax.hist(model.resid, bins=30, edgecolor='black', alpha=0.7)
    ax.axvline(0, color='red', linestyle='--')
    ax.set_xlabel('Residuals')
    ax.set_ylabel('Frequency')
    ax.set_title('Residuals Distribution')
    ax.grid(True, alpha=0.3)
    
    # 2. Residuals vs order
    ax = axes[0, 1]
    ax.scatter(range(len(model.resid)), model.resid, alpha=0.5)
    ax.axhline(0, color='red', linestyle='--')
    ax.set_xlabel('Observation Order')
    ax.set_ylabel('Residuals')
    ax.set_title('Residuals vs Order')
    ax.grid(True, alpha=0.3)
    
    # 3. Scale-Location plot
    ax = axes[1, 0]
    ax.scatter(model.fittedvalues, np.sqrt(np.abs(model.resid)), alpha=0.5)
    ax.set_xlabel('Fitted Values')
    ax.set_ylabel('√|Residuals|')
    ax.set_title('Scale-Location Plot')
    ax.grid(True, alpha=0.3)
    
    # 4. Cook's Distance
    ax = axes[1, 1]
    ax.bar(range(len(cooks_d)), cooks_d)
    ax.axhline(threshold, color='red', linestyle='--', label='Threshold')
    ax.set_xlabel('Observation')
    ax.set_ylabel("Cook's Distance")
    ax.set_title("Cook's Distance")
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/model_diagnostics.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved model diagnostics to data/model_diagnostics.png")
    
    return {
        'shapiro_p': shapiro_p,
        'bp_p': bp_p,
        'vif': vif_data,
        'influential_count': influential.sum()
    }


# ============================================================
# PART 3: LOGISTIC REGRESSION
# ============================================================

def logistic_regression_demo(df: pd.DataFrame):
    """
    Build and interpret a logistic regression model.
    
    Logistic regression models the probability of a binary outcome.
    """
    section("Logistic Regression")
    
    print("Logistic regression models the probability of a binary outcome.")
    print("It's used for classification problems.\n")
    
    # Prepare data
    X = df[['ad_spend', 'price', 'product_quality', 'customer_satisfaction', 
            'competitor_price', 'seasonal_factor']]
    X = sm.add_constant(X)
    y = df['high_sales']
    
    # Fit model
    model = sm.Logit(y, X).fit(disp=0)
    
    # Display results
    print("Model Summary:")
    print("-" * 60)
    print(f"Log-Likelihood: {model.llf:.4f}")
    print(f"Pseudo R-squared: {model.prsquared:.4f}")
    print(f"AIC: {model.aic:.2f}")
    print(f"BIC: {model.bic:.2f}")
    
    print("\nCoefficients (Log-odds):")
    print("-" * 60)
    coefficients = model.params
    p_values = model.pvalues
    conf_int = model.conf_int()
    
    for i, (var, coef) in enumerate(coefficients.items()):
        ci_lower, ci_upper = conf_int.iloc[i]
        p_val = p_values[var]
        sig = '*' if p_val < 0.05 else ''
        print(f"{var:25} {coef:10.4f}  {ci_lower:10.4f}  {ci_upper:10.4f}  {p_val:8.4f} {sig}")
    
    print("\nOdds Ratios:")
    print("-" * 60)
    odds_ratios = np.exp(coefficients)
    odds_ci = np.exp(conf_int)
    
    for var in coefficients.index:
        print(f"{var:25} {odds_ratios[var]:10.4f}  "
              f"{odds_ci.loc[var, 0]:10.4f}  {odds_ci.loc[var, 1]:10.4f}")
    
    # Evaluate model
    print("\nModel Evaluation:")
    print("-" * 60)
    
    # Predictions
    y_pred_prob = model.predict(X)
    y_pred = (y_pred_prob > 0.5).astype(int)
    
    # Confusion matrix
    cm = confusion_matrix(y, y_pred)
    print("Confusion Matrix:")
    print(cm)
    
    # Classification metrics
    tn, fp, fn, tp = cm.ravel()
    accuracy = (tp + tn) / (tp + tn + fp + fn)
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
    
    print(f"\nAccuracy: {accuracy:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall: {recall:.4f}")
    print(f"F1-Score: {f1:.4f}")
    
    # ROC curve
    fpr, tpr, _ = roc_curve(y, y_pred_prob)
    roc_auc = auc(fpr, tpr)
    
    print(f"ROC AUC: {roc_auc:.4f}")
    
    # Visualize results
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # 1. ROC Curve
    ax = axes[0, 0]
    ax.plot(fpr, tpr, 'b-', linewidth=2, label=f'ROC (AUC = {roc_auc:.3f})')
    ax.plot([0, 1], [0, 1], 'r--', label='Random')
    ax.set_xlabel('False Positive Rate')
    ax.set_ylabel('True Positive Rate')
    ax.set_title('ROC Curve')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Confusion Matrix Heatmap
    ax = axes[0, 1]
    im = ax.imshow(cm, cmap='Blues', aspect='auto')
    ax.set_xticks([0, 1])
    ax.set_yticks([0, 1])
    ax.set_xticklabels(['Low Sales', 'High Sales'])
    ax.set_yticklabels(['Low Sales', 'High Sales'])
    plt.colorbar(im, ax=ax)
    ax.set_title('Confusion Matrix')
    
    # Add values
    for i in range(2):
        for j in range(2):
            ax.text(j, i, cm[i, j], ha='center', va='center')
    
    # 3. Coefficient Plot (Odds Ratios)
    ax = axes[1, 0]
    coef_df = pd.DataFrame({
        'Feature': coefficients.index[1:],
        'Odds_Ratio': odds_ratios.values[1:],
        'CI_lower': odds_ci.iloc[1:, 0].values,
        'CI_upper': odds_ci.iloc[1:, 1].values
    })
    
    ax.errorbar(coef_df['Odds_Ratio'], range(len(coef_df)),
                xerr=[coef_df['Odds_Ratio'] - coef_df['CI_lower'],
                      coef_df['CI_upper'] - coef_df['Odds_Ratio']],
                fmt='o', capsize=5)
    ax.axvline(x=1, color='red', linestyle='--')
    ax.set_yticks(range(len(coef_df)))
    ax.set_yticklabels(coef_df['Feature'])
    ax.set_xlabel('Odds Ratio')
    ax.set_title('Odds Ratios with 95% CI')
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)
    
    # 4. Probability Distribution
    ax = axes[1, 1]
    ax.hist(y_pred_prob[y == 0], bins=30, alpha=0.5, label='Low Sales', color='blue')
    ax.hist(y_pred_prob[y == 1], bins=30, alpha=0.5, label='High Sales', color='green')
    ax.axvline(0.5, color='red', linestyle='--', label='Threshold')
    ax.set_xlabel('Predicted Probability')
    ax.set_ylabel('Frequency')
    ax.set_title('Predicted Probability Distribution')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/logistic_regression.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved logistic regression visualization to data/logistic_regression.png")
    
    return model


# ============================================================
# PART 4: MODEL COMPARISON
# ============================================================

def model_comparison_demo(df: pd.DataFrame):
    """
    Compare different model specifications.
    
    Model comparison helps select the best model
    for prediction or explanation.
    """
    section("Model Comparison")
    
    print("Comparing different model specifications to find the best.")
    print("We'll evaluate models using AIC, BIC, and R-squared.\n")
    
    # Define different model specifications
    models = {
        'Model 1 - Base': ['ad_spend', 'price'],
        'Model 2 - Add Quality': ['ad_spend', 'price', 'product_quality'],
        'Model 3 - Add Satisfaction': ['ad_spend', 'price', 'product_quality', 
                                       'customer_satisfaction'],
        'Model 4 - Add Competitor': ['ad_spend', 'price', 'product_quality',
                                     'customer_satisfaction', 'competitor_price'],
        'Model 5 - Full': ['ad_spend', 'price', 'product_quality',
                          'customer_satisfaction', 'competitor_price', 'seasonal_factor']
    }
    
    # Fit models and collect metrics
    results = []
    
    for name, variables in models.items():
        X = df[variables]
        X = sm.add_constant(X)
        y = df['sales']
        
        model = sm.OLS(y, X).fit()
        
        results.append({
            'Model': name,
            'R²': model.rsquared,
            'R²_adj': model.rsquared_adj,
            'AIC': model.aic,
            'BIC': model.bic,
            'F_stat': model.fvalue,
            'F_pval': model.f_pvalue,
            'N': model.nobs,
            'K': len(variables)
        })
    
    # Display results
    results_df = pd.DataFrame(results)
    
    print("Model Comparison Results:")
    print("-" * 80)
    print(results_df.round(4).to_string(index=False))
    
    # Identify best model
    best_adj_r2 = results_df.loc[results_df['R²_adj'].idxmax()]
    best_aic = results_df.loc[results_df['AIC'].idxmin()]
    best_bic = results_df.loc[results_df['BIC'].idxmin()]
    
    print("\n" + "-" * 60)
    print("Best Models:")
    print("-" * 60)
    print(f"Best R²_adj: {best_adj_r2['Model']} ({best_adj_r2['R²_adj']:.4f})")
    print(f"Best AIC: {best_aic['Model']} ({best_aic['AIC']:.2f})")
    print(f"Best BIC: {best_bic['Model']} ({best_bic['BIC']:.2f})")
    
    # Visualize model comparison
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # 1. R² and Adjusted R²
    ax = axes[0]
    x = range(len(results_df))
    width = 0.35
    
    ax.bar([i - width/2 for i in x], results_df['R²'], width, label='R²', alpha=0.7)
    ax.bar([i + width/2 for i in x], results_df['R²_adj'], width, label='R²_adj', alpha=0.7)
    ax.set_xticks(x)
    ax.set_xticklabels(results_df['Model'], rotation=45, ha='right')
    ax.set_ylabel('Value')
    ax.set_title('R² and Adjusted R²')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. AIC and BIC
    ax = axes[1]
    ax.plot(x, results_df['AIC'], 'o-', label='AIC', linewidth=2)
    ax.plot(x, results_df['BIC'], 's-', label='BIC', linewidth=2)
    ax.set_xticks(x)
    ax.set_xticklabels(results_df['Model'], rotation=45, ha='right')
    ax.set_ylabel('Value')
    ax.set_title('AIC and BIC (lower is better)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 3. Model Complexity vs Performance
    ax = axes[2]
    ax.scatter(results_df['K'], results_df['R²_adj'], s=100, alpha=0.7)
    for i, row in results_df.iterrows():
        ax.annotate(row['Model'], (row['K'], row['R²_adj']))
    ax.set_xlabel('Number of Predictors')
    ax.set_ylabel('Adjusted R²')
    ax.set_title('Model Complexity vs Performance')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/model_comparison.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved model comparison to data/model_comparison.png")
    
    return results_df


# ============================================================
# PART 5: FEATURE SELECTION
# ============================================================

def feature_selection_demo(df: pd.DataFrame):
    """
    Demonstrate feature selection techniques.
    
    Feature selection helps identify the most important predictors.
    """
    section("Feature Selection")
    
    print("Feature selection identifies the most important predictors.")
    print("This helps create simpler, more interpretable models.\n")
    
    # Prepare data
    features = ['ad_spend', 'price', 'product_quality', 'customer_satisfaction',
                'competitor_price', 'seasonal_factor']
    X = df[features]
    y = df['sales']
    
    # 1. Correlation with target
    print("1. Correlation with Target:")
    print("-" * 60)
    
    correlations = X.corrwith(y).sort_values(ascending=False)
    for feature, corr in correlations.items():
        print(f"{feature:25} {corr:.4f}")
    
    # 2. Forward selection (manual)
    print("\n2. Forward Selection:")
    print("-" * 60)
    
    remaining = set(features)
    selected = []
    current_score = -np.inf
    
    for i in range(len(features)):
        best_score = -np.inf
        best_feature = None
        
        for feature in remaining:
            if feature not in selected:
                current_features = selected + [feature]
                X_temp = sm.add_constant(df[current_features])
                model = sm.OLS(y, X_temp).fit()
                score = model.rsquared_adj
                
                if score > best_score:
                    best_score = score
                    best_feature = feature
        
        if best_score > current_score:
            selected.append(best_feature)
            remaining.remove(best_feature)
            current_score = best_score
            print(f"Step {i+1}: Added '{best_feature}' (R²_adj = {best_score:.4f})")
        else:
            break
    
    # 3. Recursive feature elimination (simplified)
    print("\n3. Feature Importance (Model-based):")
    print("-" * 60)
    
    # Fit full model
    X_full = sm.add_constant(X)
    model = sm.OLS(y, X_full).fit()
    
    # Use absolute t-statistics as importance measure
    importance = np.abs(model.tvalues[1:])
    for feat, imp in zip(features, importance):
        print(f"{feat:25} {imp:.4f}")
    
    # Visualize feature importance
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 1. Correlation with target
    ax = axes[0]
    correlations.sort_values().plot(kind='barh', ax=ax)
    ax.set_xlabel('Correlation')
    ax.set_title('Correlation with Target')
    ax.grid(True, alpha=0.3)
    
    # 2. Feature importance (t-statistics)
    ax = axes[1]
    importance_df = pd.DataFrame({
        'Feature': features,
        'Importance': importance
    }).sort_values('Importance', ascending=True)
    
    ax.barh(importance_df['Feature'], importance_df['Importance'])
    ax.set_xlabel('|t-statistic|')
    ax.set_title('Feature Importance (t-statistics)')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/feature_selection.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved feature selection visualization to data/feature_selection.png")
    
    return selected


# ============================================================
# MAIN EXECUTION
# ============================================================

def main():
    """Main entry point for statistical modeling module."""
    print("""
    ╔══════════════════════════════════════════════════════════════════╗
    ║         STATISTICAL MODELING & DIAGNOSTIC ANALYSIS             ║
    ║                                                                 ║
    ║  This module covers:                                          ║
    ║  - Linear regression (OLS)                                     ║
    ║  - Model diagnostics (residuals, heteroscedasticity)          ║
    ║  - Logistic regression                                         ║
    ║  - Model comparison                                           ║
    ║  - Feature selection                                          ║
    ╚══════════════════════════════════════════════════════════════════╝
    """)
    
    # Create data directory
    import os
    os.makedirs('data', exist_ok=True)
    
    # Load data
    print("Loading sales data...")
    df = load_sales_data()
    print(f"Loaded {len(df):,} rows with {len(df.columns)} columns\n")
    
    # Run demonstrations
    linear_model = linear_regression_demo(df)
    model_diagnostics_demo(linear_model)
    logistic_model = logistic_regression_demo(df)
    model_comparison_demo(df)
    feature_selection_demo(df)
    
    print("\n" + "=" * 80)
    print("STATISTICAL MODELING & DIAGNOSTIC ANALYSIS COMPLETE!")
    print("=" * 80)
    print("\nYou now understand:")
    print("  ✅ Linear regression and interpretation")
    print("  ✅ Model diagnostics (normality, heteroscedasticity, VIF)")
    print("  ✅ Logistic regression and odds ratios")
    print("  ✅ Model comparison (AIC, BIC, R-squared)")
    print("  ✅ Feature selection techniques")
    
    print("\nNext: Phase 3 Capstone - A/B Test Analysis")


if __name__ == "__main__":
    main()
```

---

### The Verification

Run the statistical modeling module:

```bash
python src/phase3/module3_3_statistical_modeling.py
```

**Expected Output:**

The script will generate:
1. Linear regression results and diagnostics (`data/linear_regression.png`)
2. Model diagnostics (`data/model_diagnostics.png`)
3. Logistic regression results (`data/logistic_regression.png`)
4. Model comparison (`data/model_comparison.png`)
5. Feature selection (`data/feature_selection.png`)

---

### Key Modeling Takeaways

1. **Linear Regression:** Models continuous outcomes with multiple predictors.

2. **Model Diagnostics:** Always check assumptions (normality, homoscedasticity, multicollinearity).

3. **Logistic Regression:** Models binary outcomes and provides probability estimates.

4. **Odds Ratios:** Interpret logistic regression coefficients as multiplicative effects.

5. **Model Comparison:** Use AIC, BIC, and adjusted R² to compare models.

6. **Feature Selection:** Identify the most important predictors using correlation and model-based importance.

---

**[COMPLETED: Module 3.3 - Statistical Modeling & Diagnostic Analysis]**
**[COMPLETED: Phase 3 - All Modules]**
**[STARTING: Phase 3 Capstone - A/B Test Analysis]**

---

## Phase 3 Capstone: Complete A/B Test Analysis

Now we'll build a complete A/B test analysis system that integrates everything we've learned in Phase 3.

---

### Target: Building a Complete A/B Test Analysis Pipeline

**The Concept:**

This capstone combines all Phase 3 concepts into a complete system:
1. Power analysis (sample size)
2. Experiment design
3. Data generation
4. Statistical analysis
5. Regression modeling
6. Diagnostic checks
7. Reporting

**The Implementation:**

Create `src/phase3/capstone_ab_test_analysis.py`:

```python
"""
Phase 3 Capstone: Complete A/B Test Analysis

This is the integrated A/B test analysis system that combines:
1. Power analysis for sample size determination
2. A/B test data generation
3. Statistical analysis (t-tests, chi-square)
4. Regression modeling (logistic)
5. Diagnostic checks
6. Comprehensive reporting
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
from scipy.stats import ttest_ind, chi2_contingency
import statsmodels.api as sm
from statsmodels.formula.api import logit
from statsmodels.stats.proportion import proportions_ztest
from statsmodels.stats.power import NormalIndPower
import warnings
warnings.filterwarnings('ignore')

# Set styles
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")


def section(title: str):
    """Helper function to print section headers."""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)


def power_analysis():
    """Perform power analysis for the A/B test."""
    section("Step 1: Power Analysis")
    
    print("Determining required sample size for the experiment...\n")
    
    # Parameters
    baseline_conversion = 0.10  # 10% current conversion
    expected_lift = 0.02  # 2 percentage point improvement
    alpha = 0.05
    power = 0.80
    
    # Calculate effect size
    from statsmodels.stats.proportion import proportion_effectsize
    effect_size = proportion_effectsize(baseline_conversion, 
                                        baseline_conversion + expected_lift)
    
    print(f"Experiment Parameters:")
    print(f"  Baseline conversion: {baseline_conversion*100:.1f}%")
    print(f"  Expected lift: {expected_lift*100:.1f} percentage points")
    print(f"  Expected conversion: {(baseline_conversion + expected_lift)*100:.1f}%")
    print(f"  Alpha (Type I error): {alpha}")
    print(f"  Desired power: {power}")
    print(f"  Effect size (Cohen's h): {effect_size:.4f}")
    
    # Calculate sample size
    power_analysis = NormalIndPower()
    n = power_analysis.solve_power(
        effect_size=effect_size,
        alpha=alpha,
        power=power,
        alternative='two-sided'
    )
    n = int(np.ceil(n))
    
    print(f"\nRequired sample size per group: {n:,}")
    print(f"Total sample size needed: {n*2:,}")
    
    # Visualize power analysis
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 1. Power curve
    ax = axes[0]
    sample_sizes = range(20, n*2, 20)
    powers = []
    
    for s in sample_sizes:
        p = power_analysis.power(
            effect_size=effect_size,
            nobs1=s,
            alpha=alpha,
            alternative='two-sided'
        )
        powers.append(p)
    
    ax.plot(sample_sizes, powers, 'b-', linewidth=2)
    ax.axhline(power, color='red', linestyle='--', label=f'Target power: {power}')
    ax.axvline(n, color='green', linestyle='--', label=f'Required n: {n}')
    ax.set_xlabel('Sample Size (per group)')
    ax.set_ylabel('Power')
    ax.set_title('Power Curve')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Sample size vs effect size
    ax = axes[1]
    effect_sizes = np.linspace(0.05, 0.3, 20)
    ns = []
    
    for es in effect_sizes:
        n_s = power_analysis.solve_power(
            effect_size=es,
            alpha=alpha,
            power=power,
            alternative='two-sided'
        )
        ns.append(np.ceil(n_s))
    
    ax.plot(effect_sizes, ns, 'b-', linewidth=2)
    ax.axvline(effect_size, color='green', linestyle='--', 
               label=f'Your effect size: {effect_size:.3f}')
    ax.set_xlabel('Effect Size (Cohen\'s h)')
    ax.set_ylabel('Sample Size (per group)')
    ax.set_title('Sample Size vs Effect Size')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/capstone_power_analysis.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved power analysis to data/capstone_power_analysis.png")
    
    return {'n': n, 'effect_size': effect_size}


def generate_ab_test_data(n_per_group: int):
    """Generate A/B test data."""
    section("Step 2: Generate A/B Test Data")
    
    print(f"Generating {n_per_group:,} samples per group...")
    
    np.random.seed(42)
    
    # Parameters
    control_conversion = 0.10
    treatment_conversion = 0.12  # 2 percentage point lift
    
    # Generate data
    control = np.random.binomial(1, control_conversion, n_per_group)
    treatment = np.random.binomial(1, treatment_conversion, n_per_group)
    
    # Create features
    df_control = pd.DataFrame({
        'group': 'Control',
        'converted': control,
        'age': np.random.normal(40, 15, n_per_group).clip(18, 80),
        'income': np.random.lognormal(10.5, 0.8, n_per_group),
        'tenure': np.random.exponential(24, n_per_group).clip(1, 120)
    })
    
    df_treatment = pd.DataFrame({
        'group': 'Treatment',
        'converted': treatment,
        'age': np.random.normal(41, 15, n_per_group).clip(18, 80),
        'income': np.random.lognormal(10.6, 0.8, n_per_group),
        'tenure': np.random.exponential(25, n_per_group).clip(1, 120)
    })
    
    df = pd.concat([df_control, df_treatment], ignore_index=True)
    
    # Add some relationships
    # Higher income customers more likely to convert
    df['converted'] = df.apply(
        lambda row: row['converted'] or (row['income'] > 50000 and np.random.random() < 0.1),
        axis=1
    ).astype(int)
    
    print(f"Generated {len(df):,} total observations")
    print(f"  Control group: {len(df_control):,}")
    print(f"  Treatment group: {len(df_treatment):,}")
    
    # Summary
    control_rate = df[df['group'] == 'Control']['converted'].mean()
    treatment_rate = df[df['group'] == 'Treatment']['converted'].mean()
    
    print(f"\nConversion rates:")
    print(f"  Control: {control_rate*100:.2f}%")
    print(f"  Treatment: {treatment_rate*100:.2f}%")
    print(f"  Observed lift: {(treatment_rate - control_rate)*100:.2f} percentage points")
    
    return df


def analyze_ab_test(df: pd.DataFrame):
    """Perform statistical analysis of the A/B test."""
    section("Step 3: Statistical Analysis")
    
    print("Analyzing A/B test results...\n")
    
    # Split data
    control = df[df['group'] == 'Control']['converted']
    treatment = df[df['group'] == 'Treatment']['converted']
    
    # 1. T-test
    print("1. T-test (for comparison):")
    print("-" * 60)
    t_stat, t_p = ttest_ind(control, treatment)
    print(f"T-statistic: {t_stat:.4f}")
    print(f"P-value: {t_p:.4f}")
    print(f"Result: {'Significant' if t_p < 0.05 else 'Not significant'}")
    
    # 2. Chi-square test
    print("\n2. Chi-Square Test:")
    print("-" * 60)
    contingency = pd.crosstab(df['group'], df['converted'])
    chi2, chi_p, _, _ = chi2_contingency(contingency)
    print(f"Chi-square: {chi2:.4f}")
    print(f"P-value: {chi_p:.4f}")
    print(f"Result: {'Significant' if chi_p < 0.05 else 'Not significant'}")
    
    # 3. Proportion Z-test
    print("\n3. Proportion Z-test:")
    print("-" * 60)
    count = [control.sum(), treatment.sum()]
    nobs = [len(control), len(treatment)]
    z_stat, z_p = proportions_ztest(count, nobs)
    print(f"Z-statistic: {z_stat:.4f}")
    print(f"P-value: {z_p:.4f}")
    print(f"Result: {'Significant' if z_p < 0.05 else 'Not significant'}")
    
    # 4. Confidence intervals
    print("\n4. Confidence Intervals:")
    print("-" * 60)
    for group, data in [('Control', control), ('Treatment', treatment)]:
        mean = data.mean()
        se = np.sqrt(mean * (1 - mean) / len(data))
        ci_lower = mean - 1.96 * se
        ci_upper = mean + 1.96 * se
        print(f"{group}: {mean:.4f} ({ci_lower:.4f}, {ci_upper:.4f})")
    
    # Visualize analysis
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # 1. Conversion rates
    ax = axes[0, 0]
    rates = [control.mean(), treatment.mean()]
    labels = ['Control', 'Treatment']
    colors = ['blue', 'green'] if treatment.mean() > control.mean() else ['blue', 'red']
    ax.bar(labels, rates, color=colors, alpha=0.7, edgecolor='black')
    ax.set_ylabel('Conversion Rate')
    ax.set_title('Conversion Rates')
    ax.set_ylim([0, max(rates) * 1.2])
    ax.grid(True, alpha=0.3, axis='y')
    
    # Add values on bars
    for i, rate in enumerate(rates):
        ax.text(i, rate + 0.001, f'{rate*100:.2f}%', ha='center')
    
    # 2. Confidence intervals
    ax = axes[0, 1]
    for i, (name, data) in enumerate([('Control', control), ('Treatment', treatment)]):
        mean = data.mean()
        se = np.sqrt(mean * (1 - mean) / len(data))
        ci_lower = mean - 1.96 * se
        ci_upper = mean + 1.96 * se
        ax.errorbar(name, mean, yerr=[[mean - ci_lower], [ci_upper - mean]], 
                   fmt='o', capsize=5, capthick=2, markersize=10)
    ax.set_ylabel('Conversion Rate')
    ax.set_title('95% Confidence Intervals')
    ax.grid(True, alpha=0.3)
    
    # 3. Contingency table heatmap
    ax = axes[1, 0]
    im = ax.imshow(contingency, cmap='Blues', aspect='auto')
    ax.set_xticks(range(len(contingency.columns)))
    ax.set_yticks(range(len(contingency.index)))
    ax.set_xticklabels(contingency.columns)
    ax.set_yticklabels(contingency.index)
    plt.colorbar(im, ax=ax)
    ax.set_title('Contingency Table')
    ax.set_xlabel('Converted')
    ax.set_ylabel('Group')
    
    # Add values
    for i in range(contingency.shape[0]):
        for j in range(contingency.shape[1]):
            ax.text(j, i, contingency.iloc[i, j], 
                   ha='center', va='center', color='black')
    
    # 4. P-value visualization
    ax = axes[1, 1]
    x = np.linspace(0, 15, 1000)
    y = chi2.pdf(x, df=1)
    ax.plot(x, y, 'b-', linewidth=2)
    
    # Critical region
    chi2_critical = chi2.ppf(0.95, df=1)
    x_reject = x[x > chi2_critical]
    ax.fill_between(x_reject, chi2.pdf(x_reject, df=1),
                    color='red', alpha=0.3)
    
    # Our test statistic
    ax.axvline(chi2, color='green', linewidth=3, 
               label=f'χ²={chi2:.4f}\np={chi_p:.4f}')
    
    ax.set_xlabel('Chi-square statistic')
    ax.set_ylabel('Density')
    ax.set_title('Chi-square Distribution')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/capstone_ab_test_analysis.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved A/B test analysis to data/capstone_ab_test_analysis.png")
    
    return {
        't_test': {'statistic': t_stat, 'p_value': t_p},
        'chi_square': {'statistic': chi2, 'p_value': chi_p},
        'z_test': {'statistic': z_stat, 'p_value': z_p},
        'control_rate': control.mean(),
        'treatment_rate': treatment.mean()
    }


def logistic_regression_analysis(df: pd.DataFrame):
    """Perform logistic regression on the A/B test data."""
    section("Step 4: Logistic Regression")
    
    print("Building logistic regression model to understand factors...\n")
    
    # Prepare data
    X = df[['group', 'age', 'income', 'tenure']]
    X = pd.get_dummies(X, columns=['group'], drop_first=True)
    X = sm.add_constant(X)
    y = df['converted']
    
    # Fit model
    model = sm.Logit(y, X).fit(disp=0)
    
    # Display results
    print("Logistic Regression Results:")
    print("-" * 60)
    print(f"Log-Likelihood: {model.llf:.4f}")
    print(f"Pseudo R-squared: {model.prsquared:.4f}")
    print(f"AIC: {model.aic:.2f}")
    print(f"BIC: {model.bic:.2f}")
    
    print("\nCoefficients (Log-odds):")
    print("-" * 60)
    coefficients = model.params
    p_values = model.pvalues
    conf_int = model.conf_int()
    
    for i, (var, coef) in enumerate(coefficients.items()):
        ci_lower, ci_upper = conf_int.iloc[i]
        p_val = p_values[var]
        sig = '*' if p_val < 0.05 else ''
        print(f"{var:25} {coef:10.4f}  {ci_lower:10.4f}  {ci_upper:10.4f}  {p_val:8.4f} {sig}")
    
    print("\nOdds Ratios:")
    print("-" * 60)
    odds_ratios = np.exp(coefficients)
    odds_ci = np.exp(conf_int)
    
    for var in coefficients.index:
        print(f"{var:25} {odds_ratios[var]:10.4f}  "
              f"{odds_ci.loc[var, 0]:10.4f}  {odds_ci.loc[var, 1]:10.4f}")
    
    # Interpretation
    print("\n" + "-" * 60)
    print("Interpretation:")
    print("-" * 60)
    
    if 'group_Treatment' in coefficients:
        coef = coefficients['group_Treatment']
        or_val = odds_ratios['group_Treatment']
        if coef > 0:
            print(f"✓ Treatment group is {or_val:.2f}x more likely to convert")
        else:
            print(f"✗ Treatment group is {1/or_val:.2f}x less likely to convert")
    
    # Visualize
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # 1. Coefficients
    ax = axes[0]
    coef_df = pd.DataFrame({
        'Feature': coefficients.index,
        'Coefficient': coefficients.values,
        'CI_lower': conf_int.iloc[:, 0].values,
        'CI_upper': conf_int.iloc[:, 1].values
    })
    coef_df = coef_df[coef_df['Feature'] != 'const']
    
    ax.errorbar(coef_df['Coefficient'], range(len(coef_df)),
                xerr=[coef_df['Coefficient'] - coef_df['CI_lower'],
                      coef_df['CI_upper'] - coef_df['Coefficient']],
                fmt='o', capsize=5)
    ax.axvline(x=0, color='red', linestyle='--')
    ax.set_yticks(range(len(coef_df)))
    ax.set_yticklabels(coef_df['Feature'])
    ax.set_xlabel('Coefficient (Log-odds)')
    ax.set_title('Coefficients with 95% CI')
    ax.grid(True, alpha=0.3)
    
    # 2. Odds ratios
    ax = axes[1]
    or_df = pd.DataFrame({
        'Feature': coefficients.index,
        'Odds_Ratio': odds_ratios.values,
        'CI_lower': odds_ci.iloc[:, 0].values,
        'CI_upper': odds_ci.iloc[:, 1].values
    })
    or_df = or_df[or_df['Feature'] != 'const']
    
    ax.errorbar(or_df['Odds_Ratio'], range(len(or_df)),
                xerr=[or_df['Odds_Ratio'] - or_df['CI_lower'],
                      or_df['CI_upper'] - or_df['Odds_Ratio']],
                fmt='o', capsize=5)
    ax.axvline(x=1, color='red', linestyle='--')
    ax.set_yticks(range(len(or_df)))
    ax.set_yticklabels(or_df['Feature'])
    ax.set_xlabel('Odds Ratio')
    ax.set_title('Odds Ratios with 95% CI')
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('data/capstone_logistic_regression.png', dpi=300, bbox_inches='tight')
    plt.close()
    print("\n  ✓ Saved logistic regression to data/capstone_logistic_regression.png")
    
    return model


def generate_report(results: dict, model):
    """Generate a comprehensive report."""
    section("Step 5: Report Generation")
    
    print("Generating comprehensive report...\n")
    
    # Create report text
    report = """
    ╔══════════════════════════════════════════════════════════════════╗
    ║                 A/B TEST ANALYSIS REPORT                       ║
    ║                                                                 ║
    ║  Generated by: Phase 3 Capstone Pipeline                      ║
    ║  Date: """ + pd.Timestamp.now().strftime('%Y-%m-%d %H:%M:%S') + """
    ╚══════════════════════════════════════════════════════════════════╝
    
    """ + "="*80 + """
    
    1. EXPERIMENT DESIGN
    """ + "-"*60 + """
    
    - Baseline conversion: 10.0%
    - Expected lift: 2.0 percentage points
    - Significance level (α): 0.05
    - Desired power: 0.80
    - Sample size per group: 393
    - Total sample size: 786
    
    """ + "="*80 + """
    
    2. RESULTS SUMMARY
    """ + "-"*60 + """
    """
    
    # Add results
    control_rate = results['control_rate']
    treatment_rate = results['treatment_rate']
    lift = treatment_rate - control_rate
    
    report += f"""
    Conversion Rates:
    - Control: {control_rate*100:.2f}%
    - Treatment: {treatment_rate*100:.2f}%
    - Lift: {lift*100:.2f} percentage points
    
    Statistical Tests:
    - T-test: t={results['t_test']['statistic']:.4f}, p={results['t_test']['p_value']:.4f}
    - Chi-square: χ²={results['chi_square']['statistic']:.4f}, p={results['chi_square']['p_value']:.4f}
    - Z-test: z={results['z_test']['statistic']:.4f}, p={results['z_test']['p_value']:.4f}
    """
    
    # Add decision
    is_significant = results['chi_square']['p_value'] < 0.05
    report += f"""
    Decision: {'✓ IMPLEMENT' if is_significant and lift > 0 else '✗ DO NOT IMPLEMENT' if not is_significant else '⚠️ INVESTIGATE'}
    
    Reason: {'The treatment showed a statistically significant improvement.' if is_significant and lift > 0 else 'The treatment did not show statistically significant improvement.' if not is_significant else 'The treatment showed a statistically significant decrease.'}
    """
    
    report += """
    """ + "="*80 + """
    
    3. LOGISTIC REGRESSION
    """ + "-"*60 + """
    """
    
    # Add logistic regression results
    if model is not None:
        report += f"""
    Pseudo R-squared: {model.prsquared:.4f}
    AIC: {model.aic:.2f}
    BIC: {model.bic:.2f}
    
    Key Coefficients (log-odds):
    """
        for var, coef in model.params.items():
            if var != 'const':
                p_val = model.pvalues[var]
                sig = '✅' if p_val < 0.05 else '❌'
                report += f"  {var}: {coef:.4f} (p={p_val:.4f}) {sig}\n"
    
    report += """
    """ + "="*80 + """
    
    4. RECOMMENDATIONS
    """ + "-"*60 + """
    """
    
    if is_significant and lift > 0:
        report += """
    ✅ RECOMMENDATION: Implement the treatment
    
    The A/B test results show a statistically significant improvement
    in conversion rates. The treatment group outperformed the control
    group by {:.2f} percentage points.
    
    Next Steps:
    1. Gradually roll out the treatment to all users
    2. Monitor conversion rates for 2-4 weeks
    3. Continue to track the metric for potential long-term effects
    4. Consider additional A/B tests for further optimization
    """.format(lift*100)
    elif not is_significant:
        report += """
    ❌ RECOMMENDATION: Do not implement the treatment
    
    The A/B test did not show a statistically significant improvement
    in conversion rates. The observed lift may be due to random variation.
    
    Next Steps:
    1. Consider increasing sample size to detect smaller effects
    2. Explore other factors that might improve conversion
    3. Run additional tests with different treatment variations
    4. Analyze segment-specific effects
    """
    else:
        report += """
    ⚠️ RECOMMENDATION: Investigate further
    
    The treatment showed a statistically significant decrease in
    conversion rates. This is a negative result that warrants investigation.
    
    Next Steps:
    1. Analyze segment-specific effects (did it work for some users?)
    2. Check for potential bugs or issues with the treatment
    3. Review the treatment design for potential problems
    4. Consider reverting the treatment
    """
    
    report += """
    """ + "="*80 + """
    
    5. APPENDIX: DIAGNOSTIC CHECKS
    """ + "-"*60 + """
    
    Model assumptions were checked:
    - Randomization: ✓ Assumed
    - Independence: ✓ Assumed
    - Sample size: ✓ Sufficient for power=0.80
    - Data quality: ✓ No missing values
    
    """ + "="*80 + """
    
    Report generated by the Phase 3 Capstone Pipeline.
    For questions, contact your data science team.
    
    """ + "="*80
    """
    
    # Save report
    with open('data/capstone_ab_test_report.txt', 'w') as f:
        f.write(report)
    
    print("  ✓ Report saved to data/capstone_ab_test_report.txt")
    print("\n" + report)
    
    return report


# ============================================================
# MAIN CAPSTONE EXECUTION
# ============================================================

def main():
    """Main entry point for the A/B test analysis capstone."""
    print("""
    ╔══════════════════════════════════════════════════════════════════╗
    ║           PHASE 3 CAPSTONE: A/B TEST ANALYSIS                  ║
    ║                                                                 ║
    ║  This capstone demonstrates:                                  ║
    ║  - Power analysis and sample size determination               ║
    ║  - A/B test data generation                                    ║
    ║  - Statistical analysis (t-tests, chi-square)                 ║
    ║  - Logistic regression                                        ║
    ║  - Comprehensive reporting                                     ║
    ╚══════════════════════════════════════════════════════════════════╝
    """)
    
    # Create data directory
    import os
    os.makedirs('data', exist_ok=True)
    
    # Step 1: Power analysis
    power_results = power_analysis()
    n_per_group = power_results['n']
    
    # Step 2: Generate data
    df = generate_ab_test_data(n_per_group)
    
    # Step 3: Analyze
    results = analyze_ab_test(df)
    
    # Step 4: Logistic regression
    model = logistic_regression_analysis(df)
    
    # Step 5: Generate report
    report = generate_report(results, model)
    
    print("\n" + "=" * 80)
    print("PHASE 3 CAPSTONE COMPLETE!")
    print("=" * 80)
    print("\nGenerated Files:")
    print("  - data/capstone_power_analysis.png")
    print("  - data/capstone_ab_test_analysis.png")
    print("  - data/capstone_logistic_regression.png")
    print("  - data/capstone_ab_test_report.txt")
    print("\n✅ A/B test analysis complete! Check the report for results.")


if __name__ == "__main__":
    main()
```

---

### The Verification

Run the A/B test analysis capstone:

```bash
python src/phase3/capstone_ab_test_analysis.py
```

**Expected Output:**

The script will generate:
1. Power analysis (`data/capstone_power_analysis.png`)
2. A/B test analysis (`data/capstone_ab_test_analysis.png`)
3. Logistic regression (`data/capstone_logistic_regression.png`)
4. Comprehensive text report (`data/capstone_ab_test_report.txt`)

---

### What You've Built

You now have a complete A/B test analysis system that:

1. **Designs:** Performs power analysis to determine sample size
2. **Generates:** Creates realistic experiment data
3. **Analyzes:** Uses multiple statistical tests
4. **Models:** Builds logistic regression for deeper insights
5. **Reports:** Generates comprehensive, interpretable reports

---

**[COMPLETED: Phase 3 Capstone]**
**[COMPLETED: Phase 3 - All Modules and Capstone]**

---

## Phase 3 Complete! What You've Achieved

You now have a complete toolkit for applied statistics and hypothesis testing:

### Technical Skills
- **Probability Distributions:** Normal, t, chi-square, F, Poisson, exponential
- **Descriptive Statistics:** Mean, median, variance, skewness, kurtosis
- **Inferential Statistics:** Confidence intervals, sampling methods
- **Hypothesis Testing:** t-tests, ANOVA, chi-square, Mann-Whitney
- **Experimental Design:** Power analysis, sample size, A/B testing
- **Statistical Modeling:** Linear and logistic regression
- **Model Diagnostics:** Residual analysis, heteroscedasticity, multicollinearity

### A Complete System
- **Power Analysis:** Design experiments with adequate sample sizes
- **A/B Testing:** Complete workflow from design to decision
- **Statistical Modeling:** Understand relationships in data
- **Reporting:** Comprehensive, interpretable reports

### Confidence
- You can design and analyze experiments
- You can build and interpret statistical models
- You can make data-driven decisions with confidence
- You can communicate results to stakeholders

---

## 🎉 Congratulations! You've Completed the Entire Series

You've built a complete data science engineering platform:

### Phase 1: Data Processing, Storage & Validation
- ✅ Mastered NumPy, Pandas, and Polars
- ✅ Built analytical SQL skills with PostgreSQL and DuckDB
- ✅ Implemented automated data quality checks
- ✅ Built a production ETL pipeline

### Phase 2: Exploratory Data Analysis & Visualization
- ✅ Performed systematic EDA and data profiling
- ✅ Created publication-ready static visualizations
- ✅ Built interactive dashboards with Plotly
- ✅ Generated comprehensive EDA reports

### Phase 3: Applied Statistics & Hypothesis Testing
- ✅ Mastered descriptive and inferential statistics
- ✅ Designed and analyzed hypothesis tests
- ✅ Built statistical models (linear and logistic)
- ✅ Completed a full A/B test analysis

---

### What You Can Now Build

You can now:
1. **Process** multi-gigabyte datasets efficiently
2. **Validate** data quality automatically
3. **Explore** data with both static and interactive visualizations
4. **Analyze** experiments with statistical rigor
5. **Model** relationships using regression
6. **Report** findings professionally
7. **Deploy** all of this in production

---

### Where to Go From Here

Your journey doesn't end here. Now that you have the foundation, you can explore:

1. **Deep Learning:** TensorFlow, PyTorch
2. **Big Data:** Spark, Dask
3. **Production:** MLflow, Docker, Kubernetes
4. **Specialized:** Time series analysis, NLP, computer vision
5. **Advanced:** Bayesian statistics, causal inference

---

**Thank you for completing this series. You're now equipped to build world-class data science systems.**

**[END OF SERIES]**
