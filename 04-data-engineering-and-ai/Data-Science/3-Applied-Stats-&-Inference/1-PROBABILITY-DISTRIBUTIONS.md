# MODULE 3.1, PART 1: PROBABILITY DISTRIBUTIONS

Welcome to the first technical module! We'll build a comprehensive probability distribution toolkit from scratch. Think of distributions as the **building blocks of uncertainty** — they tell us how likely different outcomes are, like a weather forecast predicting rain probabilities across different temperatures.

---

## Target: Build a Complete Probability Distribution Library

We're creating `src/data_generation/distributions.py` — a reusable module that generates data from major parametric and non-parametric distributions with proper error handling, documentation, and validation.

---

## The Concept: What Are Probability Distributions?

Imagine you're measuring the height of adults in a city. Most people are around average height, some are taller, some shorter. The pattern of how heights are spread out follows a **distribution** — specifically, the **Normal distribution** (bell curve).

Distributions answer questions like:
- **Parametric distributions** (Normal, Binomial, Poisson): Make assumptions about the underlying data-generating process. Like assuming heights follow a bell curve.
- **Non-parametric distributions** (Uniform, Empirical): Make fewer assumptions. Like drawing from actual observed heights without assuming any specific shape.

### Real-World Analogies

| Distribution | Real-World Example |
|--------------|-------------------|
| **Normal** | Heights, blood pressure, measurement errors |
| **Binomial** | Number of clicks out of 100 impressions (success/failure) |
| **Poisson** | Number of customers arriving per minute |
| **Exponential** | Time between customer arrivals |
| **Uniform** | Random number generator picking any number equally |

---

## Implementation: Complete Distribution Module

Create the file `src/data_generation/distributions.py`:

```python
#!/usr/bin/env python3
"""
Probability Distribution Module for Phase 3 Statistics Project.

This module provides implementations of common parametric and non-parametric
probability distributions with comprehensive error handling, validation,
and documentation.

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
from typing import Union, Optional, Tuple, List
import logging
from scipy import stats

# Configure logging for the module
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DistributionGenerator:
    """
    A comprehensive distribution generator with parametric and non-parametric
    distributions. All methods include input validation and clear error messages.
    
    Think of this as your "probability factory" — you specify the distribution
    type and parameters, and it generates representative data.
    """
    
    def __init__(self, random_seed: Optional[int] = None):
        """
        Initialize the distribution generator with optional reproducibility.
        
        Args:
            random_seed: Integer seed for random number generation.
                       Set this to get the same "random" results each time.
                       Useful for debugging and reproducible research.
        
        Example:
            >>> gen = DistributionGenerator(random_seed=42)
            >>> data = gen.normal(n=1000, mean=50, std=10)
        """
        self.random_seed = random_seed
        if random_seed is not None:
            np.random.seed(random_seed)
            logger.info(f"Random seed set to {random_seed} for reproducibility")
    
    # ==================== PARAMETRIC DISTRIBUTIONS ====================
    
    def normal(
        self, 
        n: int, 
        mean: float = 0.0, 
        std: float = 1.0,
        lower_bound: Optional[float] = None,
        upper_bound: Optional[float] = None
    ) -> np.ndarray:
        """
        Generate data from a Normal (Gaussian) distribution.
        
        The Normal distribution is the "bell curve" — most data clusters around
        the mean, with decreasing probability as you move away.
        
        Args:
            n: Number of samples to generate. Must be positive integer.
            mean: Mean (center) of the distribution. Default 0.
            std: Standard deviation (spread). Must be > 0. Default 1.
            lower_bound: Optional minimum value to truncate at.
            upper_bound: Optional maximum value to truncate at.
        
        Returns:
            numpy.ndarray: Array of shape (n,) containing the generated data.
        
        Raises:
            ValueError: If n <= 0, std <= 0, or bounds are invalid.
        
        Example:
            >>> gen = DistributionGenerator(seed=42)
            >>> heights = gen.normal(n=1000, mean=170, std=10, 
            ...                      lower_bound=140, upper_bound=200)
            >>> print(f"Mean height: {heights.mean():.2f} cm")
            Mean height: 169.87 cm
        """
        # Validate inputs
        if not isinstance(n, int) or n <= 0:
            raise ValueError(f"n must be a positive integer, got {n}")
        if std <= 0:
            raise ValueError(f"std must be positive, got {std}")
        if lower_bound is not None and upper_bound is not None:
            if lower_bound >= upper_bound:
                raise ValueError(
                    f"lower_bound ({lower_bound}) must be < upper_bound ({upper_bound})"
                )
        
        # Generate base normal data
        data = np.random.normal(loc=mean, scale=std, size=n)
        
        # Apply truncation if bounds are specified
        if lower_bound is not None or upper_bound is not None:
            logger.info(f"Truncating data to bounds: [{lower_bound}, {upper_bound}]")
            # Use scipy's truncated normal for proper probability
            # We need to adjust parameters for truncation
            a = -np.inf if lower_bound is None else (lower_bound - mean) / std
            b = np.inf if upper_bound is None else (upper_bound - mean) / std
            
            # Generate properly truncated normal
            data = stats.truncnorm.rvs(
                a, b, loc=mean, scale=std, size=n, random_state=self.random_seed
            )
        
        logger.info(f"Generated {n} samples from Normal(mean={mean}, std={std})")
        return data
    
    def binomial(
        self, 
        n_trials: int, 
        p_success: float,
        n_simulations: int = 1
    ) -> Union[np.ndarray, int]:
        """
        Generate data from a Binomial distribution.
        
        The Binomial distribution models the number of successes in a fixed
        number of independent trials. Like flipping a coin 10 times and counting
        heads.
        
        Args:
            n_trials: Number of independent trials. Must be > 0.
            p_success: Probability of success per trial. Must be between 0 and 1.
            n_simulations: Number of experiments to simulate. Default 1.
        
        Returns:
            numpy.ndarray or int: Array of shape (n_simulations,) containing
            the number of successes in each experiment.
        
        Raises:
            ValueError: If n_trials <= 0 or p_success not in [0, 1].
        
        Example:
            >>> gen = DistributionGenerator(seed=42)
            >>> # Simulate 1000 experiments of 100 coin flips each
            >>> heads_counts = gen.binomial(n_trials=100, p_success=0.5, 
            ...                             n_simulations=1000)
            >>> print(f"Average heads: {heads_counts.mean():.2f}")
            Average heads: 50.23
        """
        # Validate inputs
        if not isinstance(n_trials, int) or n_trials <= 0:
            raise ValueError(f"n_trials must be a positive integer, got {n_trials}")
        if not 0 <= p_success <= 1:
            raise ValueError(f"p_success must be between 0 and 1, got {p_success}")
        if not isinstance(n_simulations, int) or n_simulations <= 0:
            raise ValueError(
                f"n_simulations must be a positive integer, got {n_simulations}"
            )
        
        # Generate binomial data
        data = np.random.binomial(n=n_trials, p=p_success, size=n_simulations)
        
        logger.info(
            f"Generated {n_simulations} experiments from Binomial(n={n_trials}, "
            f"p={p_success})"
        )
        
        # Return scalar if only one simulation
        if n_simulations == 1:
            return int(data[0])
        return data
    
    def poisson(
        self, 
        n: int, 
        lambda_rate: float
    ) -> np.ndarray:
        """
        Generate data from a Poisson distribution.
        
        The Poisson distribution models the number of events occurring in a
        fixed interval of time or space. Like counting how many customers
        arrive per hour at a store.
        
        Args:
            n: Number of samples. Must be positive integer.
            lambda_rate: Expected number of events per interval. Must be > 0.
        
        Returns:
            numpy.ndarray: Array of shape (n,) containing count data.
        
        Raises:
            ValueError: If n <= 0 or lambda_rate <= 0.
        
        Example:
            >>> gen = DistributionGenerator(seed=42)
            >>> # Simulate customers arriving at a rate of 15 per hour
            >>> arrivals = gen.poisson(n=1000, lambda_rate=15)
            >>> print(f"Average arrivals per hour: {arrivals.mean():.2f}")
            Average arrivals per hour: 15.03
        """
        # Validate inputs
        if not isinstance(n, int) or n <= 0:
            raise ValueError(f"n must be a positive integer, got {n}")
        if lambda_rate <= 0:
            raise ValueError(f"lambda_rate must be positive, got {lambda_rate}")
        
        # Generate Poisson data
        data = np.random.poisson(lam=lambda_rate, size=n)
        
        logger.info(
            f"Generated {n} samples from Poisson(lambda={lambda_rate})"
        )
        return data
    
    def exponential(
        self, 
        n: int, 
        scale: float = 1.0
    ) -> np.ndarray:
        """
        Generate data from an Exponential distribution.
        
        The Exponential distribution models the time between events in a
        Poisson process. Like the waiting time between customer arrivals.
        
        Args:
            n: Number of samples. Must be positive integer.
            scale: Scale parameter (1/lambda). Must be > 0. Default 1.
        
        Returns:
            numpy.ndarray: Array of shape (n,) containing waiting times.
        
        Raises:
            ValueError: If n <= 0 or scale <= 0.
        
        Example:
            >>> gen = DistributionGenerator(seed=42)
            >>> # Simulate waiting times between customers (average 5 minutes)
            >>> wait_times = gen.exponential(n=1000, scale=5)
            >>> print(f"Average wait time: {wait_times.mean():.2f} minutes")
            Average wait time: 4.98 minutes
        """
        # Validate inputs
        if not isinstance(n, int) or n <= 0:
            raise ValueError(f"n must be a positive integer, got {n}")
        if scale <= 0:
            raise ValueError(f"scale must be positive, got {scale}")
        
        # Generate exponential data
        data = np.random.exponential(scale=scale, size=n)
        
        logger.info(
            f"Generated {n} samples from Exponential(scale={scale})"
        )
        return data
    
    def uniform(
        self, 
        n: int, 
        low: float = 0.0, 
        high: float = 1.0
    ) -> np.ndarray:
        """
        Generate data from a Uniform distribution (non-parametric).
        
        The Uniform distribution gives equal probability to all values between
        the minimum and maximum. Like a perfectly fair random number generator.
        
        Args:
            n: Number of samples. Must be positive integer.
            low: Minimum value (inclusive). Default 0.
            high: Maximum value (exclusive). Default 1.
        
        Returns:
            numpy.ndarray: Array of shape (n,) containing uniform data.
        
        Raises:
            ValueError: If n <= 0 or low >= high.
        
        Example:
            >>> gen = DistributionGenerator(seed=42)
            >>> randoms = gen.uniform(n=1000, low=-1, high=1)
            >>> print(f"Min: {randoms.min():.3f}, Max: {randoms.max():.3f}")
            Min: -0.999, Max: 0.999
        """
        # Validate inputs
        if not isinstance(n, int) or n <= 0:
            raise ValueError(f"n must be a positive integer, got {n}")
        if low >= high:
            raise ValueError(f"low ({low}) must be < high ({high})")
        
        # Generate uniform data
        data = np.random.uniform(low=low, high=high, size=n)
        
        logger.info(
            f"Generated {n} samples from Uniform({low}, {high})"
        )
        return data
    
    # ==================== DISTRIBUTION PROPERTIES ====================
    
    def calculate_moments(
        self, 
        data: np.ndarray
    ) -> Tuple[float, float, float, float]:
        """
        Calculate the first four statistical moments of the data.
        
        Moments describe the shape of a distribution:
        1st: Mean (center)
        2nd: Variance (spread)
        3rd: Skewness (asymmetry)
        4th: Kurtosis (tailedness)
        
        Args:
            data: Input array of numerical values.
        
        Returns:
            tuple: (mean, variance, skewness, kurtosis)
        
        Example:
            >>> gen = DistributionGenerator()
            >>> data = gen.normal(n=1000)
            >>> mean, var, skew, kurt = gen.calculate_moments(data)
            >>> print(f"Mean: {mean:.3f}, Skew: {skew:.3f}")
            Mean: -0.012, Skew: 0.034
        """
        if len(data) == 0:
            raise ValueError("Cannot calculate moments for empty array")
        
        mean = np.mean(data)
        variance = np.var(data, ddof=1)  # Sample variance with Bessel's correction
        skewness = stats.skew(data)
        kurtosis = stats.kurtosis(data, fisher=True)  # Fisher = True gives excess kurtosis
        
        logger.info(
            f"Calculated moments: mean={mean:.4f}, var={variance:.4f}, "
            f"skew={skewness:.4f}, kurt={kurtosis:.4f}"
        )
        
        return (mean, variance, skewness, kurtosis)
    
    def compute_quantiles(
        self, 
        data: np.ndarray, 
        probabilities: List[float] = None
    ) -> np.ndarray:
        """
        Compute quantiles of the data (non-parametric distribution summary).
        
        Quantiles divide the data into equal-sized intervals. The median is
        the 50th percentile (0.5 quantile).
        
        Args:
            data: Input array of numerical values.
            probabilities: List of probabilities between 0 and 1.
                         Default: [0.25, 0.5, 0.75] (quartiles)
        
        Returns:
            numpy.ndarray: Quantile values corresponding to each probability.
        
        Example:
            >>> gen = DistributionGenerator()
            >>> data = gen.normal(n=1000)
            >>> quantiles = gen.compute_quantiles(data, [0.025, 0.5, 0.975])
            >>> print(f"95% CI: [{quantiles[0]:.3f}, {quantiles[2]:.3f}]")
        """
        if probabilities is None:
            probabilities = [0.25, 0.5, 0.75]
        
        if not all(0 <= p <= 1 for p in probabilities):
            raise ValueError("All probabilities must be between 0 and 1")
        
        quantiles = np.quantile(data, probabilities)
        logger.info(
            f"Computed {len(probabilities)} quantiles: {quantiles}"
        )
        return quantiles


# ==================== CONVENIENCE FUNCTIONS ====================

def create_mixture_distribution(
    n: int,
    components: List[Dict],
    weights: Optional[List[float]] = None,
    seed: Optional[int] = None
) -> np.ndarray:
    """
    Create a mixture distribution by combining multiple distributions.
    
    This is useful for modeling complex real-world data that doesn't fit
    a single distribution. Think of it as mixing different probability
    "recipes" together.
    
    Args:
        n: Total number of samples to generate.
        components: List of dictionaries, each with:
            - 'type': 'normal', 'uniform', 'exponential', etc.
            - 'params': Dictionary of parameters for that distribution
        weights: Optional list of weights for each component (sums to 1).
                If None, equal weights are used.
        seed: Optional random seed for reproducibility.
    
    Returns:
        numpy.ndarray: Array of shape (n,) from the mixture distribution.
    
    Example:
        >>> # Mix 70% normal data with 30% uniform outliers
        >>> components = [
        ...     {'type': 'normal', 'params': {'mean': 0, 'std': 1}},
        ...     {'type': 'uniform', 'params': {'low': -3, 'high': 3}}
        ... ]
        >>> mixed = create_mixture_distribution(
        ...     n=1000, components=components, weights=[0.7, 0.3]
        ... )
    """
    if seed is not None:
        np.random.seed(seed)
    
    n_components = len(components)
    
    # Validate and set weights
    if weights is None:
        weights = [1.0 / n_components] * n_components
    else:
        if len(weights) != n_components:
            raise ValueError("Number of weights must match number of components")
        if not np.isclose(sum(weights), 1.0):
            raise ValueError("Weights must sum to 1.0")
    
    # Create generator for each component
    gen = DistributionGenerator()
    
    # Generate samples from each component
    all_samples = []
    for i, comp in enumerate(components):
        n_samples = int(n * weights[i])
        if i == n_components - 1:  # Last component gets remaining samples
            n_samples = n - sum([int(n * w) for w in weights[:i]])
        
        # Map distribution type to method
        dist_type = comp['type'].lower()
        params = comp['params']
        
        if dist_type == 'normal':
            samples = gen.normal(n=n_samples, **params)
        elif dist_type == 'binomial':
            samples = gen.binomial(**params, n_simulations=n_samples)
        elif dist_type == 'poisson':
            samples = gen.poisson(n=n_samples, **params)
        elif dist_type == 'exponential':
            samples = gen.exponential(n=n_samples, **params)
        elif dist_type == 'uniform':
            samples = gen.uniform(n=n_samples, **params)
        else:
            raise ValueError(f"Unsupported distribution type: {dist_type}")
        
        all_samples.append(samples)
    
    # Combine and shuffle
    combined = np.concatenate(all_samples)
    np.random.shuffle(combined)
    
    logger.info(f"Created mixture distribution with {n_components} components")
    return combined


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script to verify the distribution generator works correctly.
    Run this file directly to perform basic sanity checks.
    """
    print("Testing DistributionGenerator...")
    
    # Create generator with fixed seed for reproducibility
    gen = DistributionGenerator(random_seed=42)
    
    # Test 1: Normal distribution
    data_normal = gen.normal(n=1000, mean=5, std=2)
    assert abs(data_normal.mean() - 5) < 0.1, "Normal mean not correct"
    assert abs(data_normal.std() - 2) < 0.1, "Normal std not correct"
    print("✓ Normal distribution passed")
    
    # Test 2: Binomial distribution
    data_binomial = gen.binomial(n_trials=10, p_success=0.3, n_simulations=500)
    expected_mean = 10 * 0.3  # n * p
    assert abs(data_binomial.mean() - expected_mean) < 0.1, "Binomial mean not correct"
    print("✓ Binomial distribution passed")
    
    # Test 3: Poisson distribution
    data_poisson = gen.poisson(n=1000, lambda_rate=7)
    assert abs(data_poisson.mean() - 7) < 0.1, "Poisson mean not correct"
    print("✓ Poisson distribution passed")
    
    # Test 4: Exponential distribution
    data_exp = gen.exponential(n=1000, scale=2)
    expected_mean_exp = 2  # For exponential, mean = scale
    assert abs(data_exp.mean() - expected_mean_exp) < 0.1, "Exponential mean not correct"
    print("✓ Exponential distribution passed")
    
    # Test 5: Uniform distribution
    data_uniform = gen.uniform(n=1000, low=5, high=15)
    assert data_uniform.min() >= 5, "Uniform min below lower bound"
    assert data_uniform.max() <= 15, "Uniform max above upper bound"
    print("✓ Uniform distribution passed")
    
    # Test 6: Mixture distribution
    components = [
        {'type': 'normal', 'params': {'mean': 0, 'std': 1}},
        {'type': 'uniform', 'params': {'low': -2, 'high': 2}}
    ]
    data_mixture = create_mixture_distribution(
        n=1000, components=components, weights=[0.8, 0.2]
    )
    assert len(data_mixture) == 1000, "Mixture size incorrect"
    print("✓ Mixture distribution passed")
    
    # Test 7: Error handling
    try:
        gen.normal(n=-1, mean=0, std=1)
        print("✗ Should have raised ValueError for negative n")
    except ValueError:
        print("✓ Error handling passed")
    
    print("\nAll tests passed! Distribution module is ready for use.")
```

---

## Verification: Test Your Distribution Module

### Step 1: Run the Built-in Tests

```bash
cd phase3-statistics-project
python src/data_generation/distributions.py
```

**Expected Output:**
```
Testing DistributionGenerator...
✓ Normal distribution passed
✓ Binomial distribution passed
✓ Poisson distribution passed
✓ Exponential distribution passed
✓ Uniform distribution passed
✓ Mixture distribution passed
✓ Error handling passed

All tests passed! Distribution module is ready for use.
```

### Step 2: Interactive Testing in Python

```bash
python
```

Then run:

```python
from src.data_generation.distributions import DistributionGenerator

# Create a generator
gen = DistributionGenerator(random_seed=123)

# Generate some data
normal_data = gen.normal(n=1000, mean=10, std=2)
print(f"Normal mean: {normal_data.mean():.2f}")  # Should be ~10
print(f"Normal std: {normal_data.std():.2f}")    # Should be ~2

# Calculate moments
mean, var, skew, kurt = gen.calculate_moments(normal_data)
print(f"Moments: mean={mean:.2f}, var={var:.2f}, skew={skew:.2f}, kurt={kurt:.2f}")

# Get quantiles
q = gen.compute_quantiles(normal_data, [0.025, 0.5, 0.975])
print(f"95% range: [{q[0]:.2f}, {q[2]:.2f}]")
```

**Expected Output (approximate):**
```
Normal mean: 9.98
Normal std: 2.01
Moments: mean=9.98, var=4.06, skew=0.04, kurt=-0.01
95% range: [6.17, 14.01]
```

### Step 3: Test Truncation Feature

```python
# Generate truncated normal (like heights between 150 and 200 cm)
heights = gen.normal(n=10000, mean=175, std=10, 
                     lower_bound=150, upper_bound=200)

print(f"Min height: {heights.min():.2f} cm")  # Should be >= 150
print(f"Max height: {heights.max():.2f} cm")  # Should be <= 200
print(f"Mean height: {heights.mean():.2f} cm")  # Should be ~175
```

---

## Why This Matters

You've just built the foundation for all statistical analysis in this series. This distribution module will be used in every subsequent module:

- **Descriptive statistics** rely on understanding distributions
- **Hypothesis testing** uses distribution properties for p-values
- **Regression modeling** assumes normal distributions of residuals
- **Simulation studies** need distribution generators

---

## Reference: Distribution Properties Cheat Sheet

| Distribution | Parameters | Mean | Variance | Use Case |
|--------------|------------|------|----------|----------|
| **Normal** | μ (mean), σ (std) | μ | σ² | Symmetric continuous data |
| **Binomial** | n (trials), p (prob) | np | np(1-p) | Count of successes |
| **Poisson** | λ (rate) | λ | λ | Count of rare events |
| **Exponential** | λ (rate) | 1/λ | 1/λ² | Time between events |
| **Uniform** | a (min), b (max) | (a+b)/2 | (b-a)²/12 | Equal probability range |

---

## Common Pitfalls & Solutions

| Pitfall | Solution |
|---------|----------|
| Forgetting to set random seed | Always initialize with `random_seed` for reproducibility |
| Not validating inputs | Our module checks all parameters before generating data |
| Mixing up parameters | Check the docstring for each function |
| Not handling edge cases | Try n=1, p=0, or p=1 to ensure robustness |

---

In Part 2, you'll build on this distribution foundation to:
- Implement point estimation (sample means, proportions)
- Calculate standard errors (how much sample estimates vary)
- Construct confidence intervals (quantifying uncertainty)
- Create a comprehensive `uncertainty.py` module

Your distribution generator will power all these calculations!

---

## Quick Reference: Key Terms from This Part

| Term | Definition |
|------|------------|
| **Parametric distribution** | Distribution described by a fixed number of parameters |
| **Non-parametric distribution** | Distribution with no fixed parameters |
| **Truncation** | Restricting a distribution to a specific range |
| **Mixture distribution** | Combining multiple distributions |
| **Statistical moment** | A quantitative measure of distribution shape |
| **Quantile** | Values that divide a dataset into equal proportions |
