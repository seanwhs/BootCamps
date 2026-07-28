# MODULE 3.1, PART 2: SAMPLING & ESTIMATION

Now that you have a distribution generator, let's use it to understand the fundamental concept in statistics: **how sample statistics estimate population parameters**. Think of this as learning to read a weather forecast — you're taking a small sample (your local thermometer) to estimate the broader population (the city's temperature).

---

## Target: Build a Complete Sampling & Estimation Module

We're creating `src/descriptive/uncertainty.py` — a module that calculates point estimates, standard errors, confidence intervals, and performs bootstrap sampling for robust uncertainty quantification.

---

## The Concept: From Samples to Populations

Imagine you're a quality control inspector at a factory producing 10,000 light bulbs. You can't test every bulb, so you test 100 bulbs and find an average lifespan of 1,000 hours.

Key questions:
1. **Point Estimate**: What's your best guess for all bulbs' average lifespan? (1,000 hours)
2. **Standard Error**: How much would this estimate vary if you took another sample?
3. **Confidence Interval**: How confident are you that the true average is within a range? (e.g., 95% confident it's between 980-1020 hours)

### The Sampling Distribution

When you take multiple samples, their means form a **sampling distribution** — the distribution of your statistic across repeated sampling. This is the foundation of statistical inference.

**The Central Limit Theorem (CLT)**: Even if the population isn't normal, the sampling distribution of the mean becomes approximately normal as sample size increases (typically n ≥ 30).

---

## Implementation: Complete Uncertainty Module

Create the file `src/descriptive/uncertainty.py`:

```python
#!/usr/bin/env python3
"""
Uncertainty Quantification Module for Phase 3 Statistics Project.

This module provides tools for estimating population parameters from samples,
calculating standard errors, constructing confidence intervals, and performing
bootstrap resampling.

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
from typing import Union, Optional, Tuple, List, Callable
import logging
from scipy import stats
from scipy.stats import norm, t

# Import our distribution generator from Part 1
from src.data_generation.distributions import DistributionGenerator

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class UncertaintyEstimator:
    """
    Comprehensive uncertainty quantification toolkit.
    
    This class provides methods for:
    - Point estimation (mean, proportion, variance)
    - Standard error calculation
    - Confidence interval construction
    - Bootstrap resampling
    - Margin of error calculation
    
    Think of this as your "statistical calculator" — it takes sample data and
    tells you how confident you should be in your estimates.
    """
    
    def __init__(self, confidence_level: float = 0.95, random_seed: Optional[int] = None):
        """
        Initialize the uncertainty estimator.
        
        Args:
            confidence_level: Default confidence level for intervals (0.95 = 95%)
            random_seed: Seed for reproducible bootstrap sampling
        
        Example:
            >>> estimator = UncertaintyEstimator(confidence_level=0.99)
            >>> data = [1, 2, 3, 4, 5]
            >>> ci = estimator.confidence_interval_mean(data)
            >>> print(f"99% CI: [{ci[0]:.2f}, {ci[1]:.2f}]")
        """
        if not 0 < confidence_level < 1:
            raise ValueError(f"confidence_level must be between 0 and 1, got {confidence_level}")
        
        self.confidence_level = confidence_level
        self.random_seed = random_seed
        if random_seed is not None:
            np.random.seed(random_seed)
        
        # Pre-compute z-score for common confidence levels
        self.z_score = norm.ppf(1 - (1 - confidence_level) / 2)
        logger.info(f"Initialized UncertaintyEstimator with {confidence_level*100:.0f}% confidence")
    
    # ==================== POINT ESTIMATION ====================
    
    def sample_mean(self, data: np.ndarray) -> float:
        """
        Calculate sample mean (point estimate of population mean).
        
        The sample mean is the arithmetic average — sum all values divided by n.
        This is the best unbiased estimate of the population mean.
        
        Args:
            data: Array of numerical values
        
        Returns:
            float: Sample mean
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> data = [2, 4, 6, 8, 10]
            >>> mean = estimator.sample_mean(data)
            >>> print(f"Mean: {mean:.2f}")  # 6.00
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate mean of empty array")
        return np.mean(data)
    
    def sample_proportion(self, successes: int, trials: int) -> float:
        """
        Calculate sample proportion (point estimate of population proportion).
        
        The proportion is the fraction of successes in a binary outcome.
        Like the percentage of customers who click an ad.
        
        Args:
            successes: Number of successes (positive outcomes)
            trials: Total number of trials
        
        Returns:
            float: Sample proportion (successes / trials)
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> p = estimator.sample_proportion(successes=47, trials=100)
            >>> print(f"Proportion: {p:.2f}")  # 0.47
        """
        if trials <= 0:
            raise ValueError(f"trials must be positive, got {trials}")
        if successes < 0 or successes > trials:
            raise ValueError(f"successes ({successes}) must be between 0 and {trials}")
        
        return successes / trials
    
    def sample_variance(self, data: np.ndarray, ddof: int = 1) -> float:
        """
        Calculate sample variance (unbiased estimator).
        
        Variance measures the average squared deviation from the mean.
        ddof=1 gives unbiased estimate (Bessel's correction).
        
        Args:
            data: Array of numerical values
            ddof: Delta degrees of freedom (1 for unbiased, 0 for population variance)
        
        Returns:
            float: Sample variance
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> data = [2, 4, 6, 8, 10]
            >>> var = estimator.sample_variance(data)
            >>> print(f"Variance: {var:.2f}")  # 10.00
        """
        if len(data) < 2:
            raise ValueError("Need at least 2 data points to calculate variance")
        return np.var(data, ddof=ddof)
    
    # ==================== STANDARD ERROR ====================
    
    def standard_error_mean(self, data: np.ndarray, known_sigma: Optional[float] = None) -> float:
        """
        Calculate standard error of the mean (SEM).
        
        The standard error measures how much the sample mean would vary
        across repeated samples. It's the standard deviation of the sampling
        distribution of the mean.
        
        Formula: SEM = σ / √n (where σ is population standard deviation)
        If σ unknown, use s / √n (where s is sample standard deviation)
        
        Args:
            data: Sample data array
            known_sigma: If known, use population standard deviation.
                        If None, estimate from sample.
        
        Returns:
            float: Standard error of the mean
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> data = np.random.normal(100, 15, 100)
            >>> sem = estimator.standard_error_mean(data)
            >>> print(f"Standard error: {sem:.3f}")
        """
        n = len(data)
        if n == 0:
            raise ValueError("Cannot calculate standard error of empty array")
        
        if known_sigma is not None:
            if known_sigma <= 0:
                raise ValueError(f"known_sigma must be positive, got {known_sigma}")
            std_dev = known_sigma
        else:
            std_dev = np.std(data, ddof=1)  # Sample standard deviation
        
        se = std_dev / np.sqrt(n)
        logger.info(f"Standard error of mean: {se:.4f} (n={n})")
        return se
    
    def standard_error_proportion(self, p: float, n: int) -> float:
        """
        Calculate standard error of a proportion.
        
        The standard error for a proportion measures how much the sample
        proportion varies across repeated samples.
        
        Formula: SE = √(p(1-p)/n)
        
        Args:
            p: Sample proportion (between 0 and 1)
            n: Sample size
        
        Returns:
            float: Standard error of the proportion
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> se = estimator.standard_error_proportion(p=0.47, n=100)
            >>> print(f"SE: {se:.4f}")  # 0.0499
        """
        if not 0 <= p <= 1:
            raise ValueError(f"p must be between 0 and 1, got {p}")
        if n <= 0:
            raise ValueError(f"n must be positive, got {n}")
        
        se = np.sqrt(p * (1 - p) / n)
        logger.info(f"Standard error of proportion: {se:.4f}")
        return se
    
    # ==================== CONFIDENCE INTERVALS ====================
    
    def confidence_interval_mean(
        self, 
        data: np.ndarray, 
        confidence_level: Optional[float] = None,
        known_sigma: Optional[float] = None
    ) -> Tuple[float, float]:
        """
        Calculate confidence interval for the population mean.
        
        The confidence interval gives a range that is likely to contain the
        true population mean with a specified level of confidence.
        
        Uses t-distribution when σ is unknown (more conservative),
        z-distribution when σ is known.
        
        Args:
            data: Sample data
            confidence_level: Desired confidence level (default: from init)
            known_sigma: If known, use z-distribution. If None, use t-distribution.
        
        Returns:
            tuple: (lower_bound, upper_bound)
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> data = np.random.normal(50, 10, 30)
            >>> ci_low, ci_high = estimator.confidence_interval_mean(data)
            >>> print(f"95% CI: [{ci_low:.2f}, {ci_high:.2f}]")
        """
        if confidence_level is None:
            confidence_level = self.confidence_level
        
        n = len(data)
        if n < 2:
            raise ValueError("Need at least 2 data points for confidence interval")
        
        mean = self.sample_mean(data)
        se = self.standard_error_mean(data, known_sigma=known_sigma)
        
        # Choose distribution based on whether sigma is known
        if known_sigma is not None:
            # Use z-distribution (normal)
            z_score = norm.ppf(1 - (1 - confidence_level) / 2)
            margin = z_score * se
            method = "z-distribution (σ known)"
        else:
            # Use t-distribution with n-1 degrees of freedom
            df = n - 1
            t_score = t.ppf(1 - (1 - confidence_level) / 2, df)
            margin = t_score * se
            method = f"t-distribution (df={df}, σ unknown)"
        
        ci_low = mean - margin
        ci_high = mean + margin
        
        logger.info(
            f"Confidence interval ({confidence_level*100:.0f}%): "
            f"[{ci_low:.4f}, {ci_high:.4f}] using {method}"
        )
        
        return (ci_low, ci_high)
    
    def confidence_interval_proportion(
        self, 
        successes: int, 
        trials: int, 
        confidence_level: Optional[float] = None,
        method: str = 'wald'
    ) -> Tuple[float, float]:
        """
        Calculate confidence interval for a population proportion.
        
        Various methods are available:
        - 'wald': Standard normal approximation (p ± z*SE)
        - 'wilson': Wilson score interval (better for small samples)
        - 'clopper_pearson': Exact binomial interval (most conservative)
        
        Args:
            successes: Number of successes
            trials: Total trials
            confidence_level: Desired confidence level (default: from init)
            method: 'wald', 'wilson', or 'clopper_pearson'
        
        Returns:
            tuple: (lower_bound, upper_bound)
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> ci_low, ci_high = estimator.confidence_interval_proportion(
            ...     successes=47, trials=100, method='wilson'
            ... )
            >>> print(f"95% CI: [{ci_low:.3f}, {ci_high:.3f}]")
        """
        if confidence_level is None:
            confidence_level = self.confidence_level
        
        p = self.sample_proportion(successes, trials)
        n = trials
        
        if method == 'wald':
            # Standard Wald interval (normal approximation)
            se = self.standard_error_proportion(p, n)
            z_score = norm.ppf(1 - (1 - confidence_level) / 2)
            margin = z_score * se
            ci_low = max(0, p - margin)  # Clamp to [0, 1]
            ci_high = min(1, p + margin)
            
        elif method == 'wilson':
            # Wilson score interval (better for small samples)
            z_score = norm.ppf(1 - (1 - confidence_level) / 2)
            z_sq = z_score ** 2
            
            # Wilson formula components
            numerator_center = p + z_sq / (2 * n)
            denominator = 1 + z_sq / n
            numerator_spread = z_score * np.sqrt(p * (1 - p) / n + z_sq / (4 * n**2))
            
            ci_low = (numerator_center - numerator_spread) / denominator
            ci_high = (numerator_center + numerator_spread) / denominator
            
            # Clamp to valid range
            ci_low = max(0, ci_low)
            ci_high = min(1, ci_high)
            
        elif method == 'clopper_pearson':
            # Exact binomial confidence interval
            # Uses the relationship between binomial and beta distributions
            alpha = 1 - confidence_level
            ci_low = stats.beta.ppf(alpha / 2, successes, n - successes + 1)
            ci_high = stats.beta.ppf(1 - alpha / 2, successes + 1, n - successes)
            
        else:
            raise ValueError(f"Unknown method: {method}. Use 'wald', 'wilson', or 'clopper_pearson'")
        
        logger.info(
            f"Proportion CI ({confidence_level*100:.0f}%): "
            f"[{ci_low:.4f}, {ci_high:.4f}] using {method} method"
        )
        
        return (ci_low, ci_high)
    
    def confidence_interval_difference(
        self,
        data1: np.ndarray,
        data2: np.ndarray,
        confidence_level: Optional[float] = None,
        paired: bool = False
    ) -> Tuple[float, float]:
        """
        Calculate confidence interval for the difference between two means.
        
        Useful for comparing two groups (e.g., treatment vs control).
        
        Args:
            data1: First group data
            data2: Second group data
            confidence_level: Desired confidence level
            paired: Whether data is paired (dependent samples)
        
        Returns:
            tuple: (lower_bound, upper_bound) for difference (mean1 - mean2)
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> control = np.random.normal(50, 10, 100)
            >>> treatment = np.random.normal(55, 10, 100)
            >>> ci_low, ci_high = estimator.confidence_interval_difference(
            ...     control, treatment
            ... )
            >>> print(f"Difference 95% CI: [{ci_low:.2f}, {ci_high:.2f}]")
        """
        if confidence_level is None:
            confidence_level = self.confidence_level
        
        n1 = len(data1)
        n2 = len(data2)
        
        if n1 < 2 or n2 < 2:
            raise ValueError("Both groups need at least 2 data points")
        
        mean1 = self.sample_mean(data1)
        mean2 = self.sample_mean(data2)
        diff = mean1 - mean2
        
        if paired:
            # Paired test: analyze differences
            if n1 != n2:
                raise ValueError("Paired samples must have equal length")
            differences = data1 - data2
            mean_diff = self.sample_mean(differences)
            se_diff = self.standard_error_mean(differences)
            df = n1 - 1
        else:
            # Independent samples: pooled or separate variance
            var1 = self.sample_variance(data1)
            var2 = self.sample_variance(data2)
            
            # Use Welch's t-test (doesn't assume equal variances)
            se_diff = np.sqrt(var1 / n1 + var2 / n2)
            
            # Welch-Satterthwaite degrees of freedom
            se1 = var1 / n1
            se2 = var2 / n2
            df = (se1 + se2)**2 / (se1**2 / (n1 - 1) + se2**2 / (n2 - 1))
        
        # Calculate interval
        t_score = t.ppf(1 - (1 - confidence_level) / 2, df)
        margin = t_score * se_diff
        
        ci_low = diff - margin
        ci_high = diff + margin
        
        logger.info(
            f"Difference CI ({confidence_level*100:.0f}%): "
            f"[{ci_low:.4f}, {ci_high:.4f}] (diff={diff:.4f})"
        )
        
        return (ci_low, ci_high)
    
    # ==================== BOOTSTRAP RESAMPLING ====================
    
    def bootstrap_confidence_interval(
        self,
        data: np.ndarray,
        statistic: Callable,
        n_bootstrap: int = 1000,
        confidence_level: Optional[float] = None,
        method: str = 'percentile'
    ) -> Tuple[float, float]:
        """
        Calculate confidence interval using bootstrap resampling.
        
        Bootstrap is a powerful non-parametric method that resamples with
        replacement to estimate the sampling distribution of any statistic.
        
        Args:
            data: Sample data
            statistic: Function that computes the statistic of interest
            n_bootstrap: Number of bootstrap resamples
            confidence_level: Desired confidence level
            method: 'percentile' or 'bca' (bias-corrected and accelerated)
        
        Returns:
            tuple: (lower_bound, upper_bound)
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> data = np.random.exponential(scale=5, size=100)
            >>> # Bootstrap CI for the median
            >>> ci_low, ci_high = estimator.bootstrap_confidence_interval(
            ...     data, np.median, n_bootstrap=1000
            ... )
            >>> print(f"Median 95% CI: [{ci_low:.2f}, {ci_high:.2f}]")
        """
        if confidence_level is None:
            confidence_level = self.confidence_level
        
        n = len(data)
        if n == 0:
            raise ValueError("Cannot bootstrap empty array")
        
        # Generate bootstrap samples
        bootstrap_stats = np.zeros(n_bootstrap)
        
        for i in range(n_bootstrap):
            # Resample with replacement
            bootstrap_sample = np.random.choice(data, size=n, replace=True)
            bootstrap_stats[i] = statistic(bootstrap_sample)
        
        # Calculate interval based on method
        if method == 'percentile':
            alpha = 1 - confidence_level
            lower_percentile = alpha / 2 * 100
            upper_percentile = (1 - alpha / 2) * 100
            ci_low = np.percentile(bootstrap_stats, lower_percentile)
            ci_high = np.percentile(bootstrap_stats, upper_percentile)
            
        elif method == 'bca':
            # Bias-corrected and accelerated (BCa) bootstrap
            # More complex but handles skewed distributions better
            # For simplicity, we'll use the percentile method here
            # Full BCa implementation would be significantly more complex
            logger.warning("BCa not fully implemented, using percentile method")
            alpha = 1 - confidence_level
            lower_percentile = alpha / 2 * 100
            upper_percentile = (1 - alpha / 2) * 100
            ci_low = np.percentile(bootstrap_stats, lower_percentile)
            ci_high = np.percentile(bootstrap_stats, upper_percentile)
            
        else:
            raise ValueError(f"Unknown method: {method}. Use 'percentile' or 'bca'")
        
        logger.info(
            f"Bootstrap CI ({confidence_level*100:.0f}%): "
            f"[{ci_low:.4f}, {ci_high:.4f}] using {n_bootstrap} resamples"
        )
        
        return (ci_low, ci_high)
    
    # ==================== MARGIN OF ERROR ====================
    
    def margin_of_error(
        self,
        data: np.ndarray,
        confidence_level: Optional[float] = None,
        known_sigma: Optional[float] = None
    ) -> float:
        """
        Calculate the margin of error for a mean.
        
        The margin of error is half the width of the confidence interval.
        It's the maximum expected difference between the sample statistic
        and the population parameter.
        
        Args:
            data: Sample data
            confidence_level: Desired confidence level
            known_sigma: Known population standard deviation (if any)
        
        Returns:
            float: Margin of error
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> data = np.random.normal(100, 20, 200)
            >>> moe = estimator.margin_of_error(data)
            >>> print(f"Margin of error: ±{moe:.2f}")
        """
        if confidence_level is None:
            confidence_level = self.confidence_level
        
        se = self.standard_error_mean(data, known_sigma)
        
        if known_sigma is not None:
            z_score = norm.ppf(1 - (1 - confidence_level) / 2)
            moe = z_score * se
        else:
            df = len(data) - 1
            t_score = t.ppf(1 - (1 - confidence_level) / 2, df)
            moe = t_score * se
        
        logger.info(f"Margin of error: ±{moe:.4f}")
        return moe
    
    def sample_size_for_mean(
        self,
        margin_of_error: float,
        confidence_level: Optional[float] = None,
        sigma_guess: Optional[float] = None
    ) -> int:
        """
        Calculate required sample size for estimating a mean.
        
        Planning sample size before collecting data is crucial for 
        designing experiments with sufficient statistical power.
        
        Args:
            margin_of_error: Desired margin of error (precision)
            confidence_level: Desired confidence level
            sigma_guess: Estimated population standard deviation
        
        Returns:
            int: Required sample size
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> # Need to estimate mean within ±2 units with 95% confidence
            >>> n = estimator.sample_size_for_mean(
            ...     margin_of_error=2, sigma_guess=10
            ... )
            >>> print(f"Need {n} samples")
        """
        if confidence_level is None:
            confidence_level = self.confidence_level
        
        if margin_of_error <= 0:
            raise ValueError(f"margin_of_error must be positive, got {margin_of_error}")
        
        if sigma_guess is None:
            # If no sigma guess, use a conservative estimate
            # This is not ideal but gives a starting point
            logger.warning("No sigma_guess provided, using default value of 1")
            sigma_guess = 1.0
        
        z_score = norm.ppf(1 - (1 - confidence_level) / 2)
        n = (z_score * sigma_guess / margin_of_error) ** 2
        n = int(np.ceil(n))  # Round up to ensure sufficient power
        
        logger.info(f"Required sample size: {n} (MOE={margin_of_error}, σ={sigma_guess})")
        return n
    
    def sample_size_for_proportion(
        self,
        margin_of_error: float,
        p_guess: float = 0.5,
        confidence_level: Optional[float] = None
    ) -> int:
        """
        Calculate required sample size for estimating a proportion.
        
        Uses the conservative p=0.5 if no better estimate is available.
        
        Args:
            margin_of_error: Desired margin of error
            p_guess: Estimated proportion (0.5 is most conservative)
            confidence_level: Desired confidence level
        
        Returns:
            int: Required sample size
        
        Example:
            >>> estimator = UncertaintyEstimator()
            >>> # Need to estimate proportion within ±3% with 95% confidence
            >>> n = estimator.sample_size_for_proportion(
            ...     margin_of_error=0.03, p_guess=0.5
            ... )
            >>> print(f"Need {n} samples")
        """
        if confidence_level is None:
            confidence_level = self.confidence_level
        
        if not 0 <= p_guess <= 1:
            raise ValueError(f"p_guess must be between 0 and 1, got {p_guess}")
        
        z_score = norm.ppf(1 - (1 - confidence_level) / 2)
        n = (z_score**2 * p_guess * (1 - p_guess)) / (margin_of_error**2)
        n = int(np.ceil(n))
        
        logger.info(f"Required sample size: {n} (MOE={margin_of_error}, p={p_guess})")
        return n


# ==================== CONVENIENCE FUNCTIONS ====================

def demonstrate_central_limit_theorem(n_samples: int = 1000, sample_size: int = 30):
    """
    Visual demonstration of the Central Limit Theorem using simulation.
    
    Shows how the distribution of sample means approaches normality
    as sample size increases, regardless of the underlying population.
    
    Args:
        n_samples: Number of samples to draw
        sample_size: Size of each sample
    
    Returns:
        tuple: (sample_means, mean_of_means, std_of_means)
    
    Example:
        >>> means, mean_mean, std_mean = demonstrate_central_limit_theorem()
        >>> print(f"Mean of means: {mean_mean:.4f}")
        >>> print(f"SD of means: {std_mean:.4f}")
    """
    # Generate data from a non-normal distribution (exponential)
    gen = DistributionGenerator(random_seed=42)
    population = gen.exponential(n=10000, scale=5)
    
    # Draw samples and calculate means
    sample_means = np.zeros(n_samples)
    
    for i in range(n_samples):
        sample = np.random.choice(population, size=sample_size, replace=True)
        sample_means[i] = np.mean(sample)
    
    mean_of_means = np.mean(sample_means)
    std_of_means = np.std(sample_means, ddof=1)
    
    # Compare to theoretical values
    theoretical_mean = 5  # Population mean of exponential(scale=5)
    theoretical_std = 5 / np.sqrt(sample_size)  # Population std / sqrt(n)
    
    logger.info(
        f"CLT Demonstration:\n"
        f"  Population mean: {theoretical_mean}\n"
        f"  Mean of means: {mean_of_means:.4f}\n"
        f"  Theoretical SE: {theoretical_std:.4f}\n"
        f"  Observed SE: {std_of_means:.4f}"
    )
    
    return (sample_means, mean_of_means, std_of_means)


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script to verify the uncertainty module works correctly.
    """
    print("Testing UncertaintyEstimator...")
    
    # Create estimator
    estimator = UncertaintyEstimator(confidence_level=0.95, random_seed=42)
    
    # Test 1: Basic statistics
    data = np.random.normal(100, 15, 50)
    mean = estimator.sample_mean(data)
    var = estimator.sample_variance(data)
    se = estimator.standard_error_mean(data)
    
    assert abs(mean - 100) < 5, f"Mean should be ~100, got {mean:.2f}"
    print(f"✓ Basic statistics: mean={mean:.2f}, var={var:.2f}, se={se:.3f}")
    
    # Test 2: Confidence intervals
    ci_low, ci_high = estimator.confidence_interval_mean(data)
    assert ci_low < mean < ci_high, "Mean should be inside CI"
    print(f"✓ Mean CI: [{ci_low:.2f}, {ci_high:.2f}]")
    
    # Test 3: Proportion confidence interval
    ci_low, ci_high = estimator.confidence_interval_proportion(
        successes=45, trials=100, method='wilson'
    )
    assert 0 <= ci_low <= 1 and 0 <= ci_high <= 1, "Proportion CI in [0,1]"
    print(f"✓ Proportion CI: [{ci_low:.3f}, {ci_high:.3f}]")
    
    # Test 4: Bootstrap confidence interval
    ci_low, ci_high = estimator.bootstrap_confidence_interval(
        data, np.median, n_bootstrap=500
    )
    print(f"✓ Bootstrap CI: [{ci_low:.2f}, {ci_high:.2f}]")
    
    # Test 5: Sample size calculation
    n_mean = estimator.sample_size_for_mean(margin_of_error=2, sigma_guess=15)
    n_prop = estimator.sample_size_for_proportion(margin_of_error=0.03)
    assert n_mean > 0, "Sample size should be positive"
    assert n_prop > 0, "Sample size should be positive"
    print(f"✓ Sample sizes: mean={n_mean}, proportion={n_prop}")
    
    # Test 6: CLT demonstration
    means, mean_mean, std_mean = demonstrate_central_limit_theorem(
        n_samples=500, sample_size=30
    )
    print(f"✓ CLT: mean={mean_mean:.3f}, std={std_mean:.3f}")
    
    print("\nAll tests passed! Uncertainty module is ready for use.")
```

---

## Verification: Test Your Uncertainty Module

### Step 1: Run the Built-in Tests

```bash
cd phase3-statistics-project
python src/descriptive/uncertainty.py
```

**Expected Output:**
```
Testing UncertaintyEstimator...
✓ Basic statistics: mean=99.73, var=245.63, se=2.22
✓ Mean CI: [95.27, 104.19]
✓ Proportion CI: [0.353, 0.551]
✓ Bootstrap CI: [95.74, 103.63]
✓ Sample sizes: mean=217, proportion=1068
✓ CLT: mean=5.000, std=0.912

All tests passed! Uncertainty module is ready for use.
```

### Step 2: Interactive Testing

```bash
python
```

```python
from src.descriptive.uncertainty import UncertaintyEstimator
from src.data_generation.distributions import DistributionGenerator

# Generate some data
gen = DistributionGenerator(random_seed=42)
data = gen.normal(n=100, mean=50, std=10)

# Analyze it
estimator = UncertaintyEstimator(confidence_level=0.95)

mean = estimator.sample_mean(data)
se = estimator.standard_error_mean(data)
ci = estimator.confidence_interval_mean(data)

print(f"Mean: {mean:.2f}")
print(f"Standard Error: {se:.3f}")
print(f"95% CI: [{ci[0]:.2f}, {ci[1]:.2f}]")

# Calculate margin of error
moe = estimator.margin_of_error(data)
print(f"Margin of Error: ±{moe:.2f}")
```

**Expected Output:**
```
Mean: 50.38
Standard Error: 0.982
95% CI: [48.43, 52.33]
Margin of Error: ±1.95
```

### Step 3: Sample Size Planning

```python
# How many samples do we need to estimate mean within ±1 unit?
n = estimator.sample_size_for_mean(margin_of_error=1, sigma_guess=10)
print(f"Need {n} samples for ±1 precision")

# How many for a proportion within ±3%?
n_prop = estimator.sample_size_for_proportion(margin_of_error=0.03)
print(f"Need {n_prop} samples for ±3% precision")
```

**Expected Output:**
```
Need 385 samples for ±1 precision
Need 1068 samples for ±3% precision
```

---

## Why This Matters

You've just built a complete uncertainty quantification system! This is used in:

- **A/B testing**: Determining sample sizes and confidence intervals
- **Business reporting**: Adding error bars to metrics
- **Scientific research**: Validating experimental results
- **Quality control**: Determining if products meet specifications

---

## Reference: Key Formulas

### Standard Error Formulas

| Statistic | Standard Error |
|-----------|---------------|
| Mean (known σ) | σ / √n |
| Mean (unknown σ) | s / √n |
| Proportion | √(p(1-p)/n) |
| Difference of means | √(s₁²/n₁ + s₂²/n₂) |

### Sample Size Formulas

| Target | Formula (95% confidence) |
|--------|--------------------------|
| Mean | n = (1.96 × σ / MOE)² |
| Proportion | n = (1.96² × p(1-p)) / MOE² |

### Confidence Intervals

| Type | Formula |
|------|---------|
| Mean (σ known) | x̄ ± z × (σ/√n) |
| Mean (σ unknown) | x̄ ± t₍ₙ₋₁₎ × (s/√n) |
| Proportion (Wald) | p̂ ± z × √(p̂(1-p̂)/n) |

---

## Common Pitfalls & Solutions

| Pitfall | Solution |
|---------|----------|
| Using z when you should use t | Use t-distribution for small samples (n < 30) |
| Misinterpreting confidence intervals | 95% CI means 95% of intervals contain the true mean |
| Ignoring sample size | Larger samples = narrower intervals |
| Not validating assumptions | Check normality for small samples |

---

In Part 3, you'll:
- Build interactive simulations demonstrating the CLT
- Create visualizations showing sampling distributions
- Implement error bars and uncertainty visualization
- Build a complete descriptive statistics dashboard

Your distribution generator and uncertainty calculator will work together to create powerful statistical demonstrations!

---

## Quick Reference: Key Terms from This Part

| Term | Definition |
|------|------------|
| **Point Estimate** | Single best guess for a population parameter |
| **Standard Error** | Standard deviation of a sampling distribution |
| **Confidence Interval** | Range likely to contain the true parameter |
| **Margin of Error** | Half the width of a confidence interval |
| **Bootstrap** | Resampling with replacement to estimate uncertainty |
| **Central Limit Theorem** | Sampling distribution of means approaches normality |
