# Phase 3, Part 1: Probability — The Language of Uncertainty

## Module 1: Probability Theory and Distributions

### The Target

We're building the probabilistic foundation for machine learning. This module covers probability theory, common distributions, and their role in modeling uncertainty—essential for classification, generative models, and Bayesian inference.

**Files we'll create:**
- `src/probability/__init__.py`
- `src/probability/distributions.py`
- `src/probability/stats.py`
- `tests/test_probability.py`

### The Concept

Imagine you're a weather forecaster. You can't say with certainty whether it will rain tomorrow, but you can say "there's a 70% chance of rain." That's **probability**—quantifying uncertainty.

In machine learning, probability is everywhere:

**Why probability matters for ML:**
1. **Data is noisy**: Measurements aren't perfect; probability models this noise
2. **Uncertainty quantification**: How confident is your model?
3. **Generative models**: Can the model generate new data like the training data?
4. **Bayesian inference**: Updating beliefs as new data arrives
5. **Decision making**: Making optimal choices under uncertainty

**Key concepts:**
- **Random variable**: A variable whose value is subject to randomness
- **Probability distribution**: How likely each value is
- **Mean**: The expected value (center of distribution)
- **Variance**: How spread out the distribution is
- **Conditional probability**: Probability of A given B (P(A|B))

**The connection to our previous work**: Neural networks produce point estimates (a single prediction). Probability theory extends this to distribution predictions—giving us not just "it will rain" but "70% chance of rain."

### The Implementation

#### Step 1: Set Up Probability Module

```bash
# From your project root
mkdir -p src/probability
touch src/probability/__init__.py
```

#### Step 2: Implement Probability Distributions

**File: `src/probability/distributions.py`**

```python
"""
Probability distributions for machine learning.

This module implements common probability distributions used in
machine learning, including their probability density functions,
cumulative distribution functions, and sampling methods.
"""

import math
import random
from typing import Tuple, List, Optional, Union
from src.linear_algebra import Vector, Matrix


class Distribution:
    """Base class for probability distributions."""
    
    def __init__(self, name: str = "Distribution"):
        self.name = name
    
    def pdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """Probability density function."""
        raise NotImplementedError
    
    def cdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """Cumulative distribution function."""
        raise NotImplementedError
    
    def sample(self, n: int = 1) -> Union[float, Vector, Matrix]:
        """Generate random samples from the distribution."""
        raise NotImplementedError
    
    def mean(self) -> float:
        """Expected value."""
        raise NotImplementedError
    
    def variance(self) -> float:
        """Variance of the distribution."""
        raise NotImplementedError
    
    def __repr__(self) -> str:
        return f"{self.name}()"


class GaussianDistribution(Distribution):
    """
    Gaussian (Normal) distribution: N(μ, σ²)
    
    The Gaussian is the most important distribution in machine learning:
    - Central Limit Theorem: sums of random variables tend to be Gaussian
    - Maximum entropy distribution for given mean and variance
    - Used in: linear regression (error terms), Bayesian inference, PCA
    
    Formula: f(x) = (1 / (σ * √(2π))) * exp(-0.5 * ((x-μ)/σ)²)
    
    Analogy: The bell curve! Heights of people, measurement errors,
    many natural phenomena follow this distribution.
    """
    
    def __init__(self, mean: float = 0.0, std: float = 1.0):
        """
        Initialize Gaussian distribution.
        
        Args:
            mean: The mean (center) of the distribution.
            std: The standard deviation (spread). Must be > 0.
        """
        super().__init__("Gaussian")
        self.mean = mean
        self.std = std
        self.var = std ** 2
    
    def pdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """
        Probability density function at x.
        
        The PDF gives the relative likelihood of different values.
        The height of the curve at each point.
        """
        if isinstance(x, Vector):
            return Vector([self._pdf_scalar(x[i]) for i in range(x.size)])
        return self._pdf_scalar(x)
    
    def _pdf_scalar(self, x: float) -> float:
        z = (x - self.mean) / self.std
        return math.exp(-0.5 * z * z) / (self.std * math.sqrt(2 * math.pi))
    
    def cdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """
        Cumulative distribution function at x.
        
        The CDF gives P(X ≤ x) - the probability of getting a value
        less than or equal to x.
        """
        if isinstance(x, Vector):
            return Vector([self._cdf_scalar(x[i]) for i in range(x.size)])
        return self._cdf_scalar(x)
    
    def _cdf_scalar(self, x: float) -> float:
        """CDF using the error function (approximation)."""
        z = (x - self.mean) / (self.std * math.sqrt(2))
        # Use approximation of erf (error function)
        return 0.5 * (1 + math.erf(z))
    
    def sample(self, n: int = 1) -> Union[float, Vector, Matrix]:
        """
        Generate samples from the Gaussian distribution.
        
        Uses the Box-Muller transform: generate uniform random numbers
        and transform to Gaussian.
        """
        if n == 1:
            # Box-Muller transform for one sample
            u1 = random.random()
            u2 = random.random()
            z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
            return self.mean + self.std * z
        else:
            # Generate multiple samples
            samples = []
            for _ in range(n):
                samples.append(self.sample(1))
            
            # Return as Vector or Matrix (for multivariate)
            if n > 0 and isinstance(samples[0], float):
                return Vector(samples)
            return Matrix([[s] for s in samples])
    
    def mean(self) -> float:
        """Expected value."""
        return self.mean
    
    def variance(self) -> float:
        """Variance."""
        return self.var
    
    def log_pdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """
        Log probability density (log-likelihood).
        
        Used in maximum likelihood estimation. Log is used because
        products of probabilities become sums, which is numerically stable.
        """
        if isinstance(x, Vector):
            return Vector([self._log_pdf_scalar(x[i]) for i in range(x.size)])
        return self._log_pdf_scalar(x)
    
    def _log_pdf_scalar(self, x: float) -> float:
        z = (x - self.mean) / self.std
        return -0.5 * math.log(2 * math.pi) - math.log(self.std) - 0.5 * z * z
    
    def __repr__(self) -> str:
        return f"Gaussian(mean={self.mean:.4f}, std={self.std:.4f})"


class BernoulliDistribution(Distribution):
    """
    Bernoulli distribution: Ber(p)
    
    Models a binary outcome (0 or 1). Used for:
    - Binary classification (logistic regression)
    - Coin flips
    - Success/failure experiments
    
    Formula: P(X=x) = p^x * (1-p)^(1-x) for x ∈ {0,1}
    
    Where p is the probability of success.
    """
    
    def __init__(self, p: float = 0.5):
        """
        Initialize Bernoulli distribution.
        
        Args:
            p: Probability of success (must be between 0 and 1).
        """
        super().__init__("Bernoulli")
        if not 0 <= p <= 1:
            raise ValueError("p must be between 0 and 1")
        self.p = p
    
    def pmf(self, x: Union[int, float, Vector]) -> Union[float, Vector]:
        """
        Probability mass function at x.
        
        For discrete distributions, PMF gives the exact probability.
        """
        if isinstance(x, Vector):
            return Vector([self._pmf_scalar(x[i]) for i in range(x.size)])
        return self._pmf_scalar(x)
    
    def _pmf_scalar(self, x: float) -> float:
        if x == 0:
            return 1 - self.p
        elif x == 1:
            return self.p
        return 0.0
    
    def cdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """
        Cumulative distribution function.
        
        P(X ≤ x) - probability of getting at most x.
        """
        if isinstance(x, Vector):
            return Vector([self._cdf_scalar(x[i]) for i in range(x.size)])
        return self._cdf_scalar(x)
    
    def _cdf_scalar(self, x: float) -> float:
        if x < 0:
            return 0.0
        elif x < 1:
            return 1 - self.p
        else:
            return 1.0
    
    def sample(self, n: int = 1) -> Union[float, Vector, Matrix]:
        """
        Generate samples from the Bernoulli distribution.
        """
        if n == 1:
            return 1.0 if random.random() < self.p else 0.0
        else:
            samples = [self.sample(1) for _ in range(n)]
            return Vector(samples)
    
    def mean(self) -> float:
        """Expected value."""
        return self.p
    
    def variance(self) -> float:
        """Variance."""
        return self.p * (1 - self.p)
    
    def entropy(self) -> float:
        """
        Entropy of the distribution.
        
        Measures uncertainty: max entropy at p=0.5, min at p=0 or 1.
        """
        if self.p == 0 or self.p == 1:
            return 0.0
        return -self.p * math.log(self.p) - (1 - self.p) * math.log(1 - self.p)
    
    def __repr__(self) -> str:
        return f"Bernoulli(p={self.p:.4f})"


class BinomialDistribution(Distribution):
    """
    Binomial distribution: Bin(n, p)
    
    Models the number of successes in n independent Bernoulli trials.
    Used for: counting successes, modeling repeated experiments.
    
    Formula: P(X=k) = C(n,k) * p^k * (1-p)^(n-k)
    
    Where:
    - n: number of trials
    - p: probability of success
    - C(n,k): binomial coefficient (n choose k)
    """
    
    def __init__(self, n: int, p: float = 0.5):
        """
        Initialize Binomial distribution.
        
        Args:
            n: Number of trials (must be > 0).
            p: Probability of success (must be between 0 and 1).
        """
        super().__init__("Binomial")
        if n <= 0:
            raise ValueError("n must be greater than 0")
        if not 0 <= p <= 1:
            raise ValueError("p must be between 0 and 1")
        self.n = n
        self.p = p
    
    def pmf(self, k: Union[int, Vector]) -> Union[float, Vector]:
        """
        Probability mass function at k.
        
        Args:
            k: Number of successes (0 to n).
        """
        if isinstance(k, Vector):
            return Vector([self._pmf_scalar(int(k[i])) for i in range(k.size)])
        return self._pmf_scalar(int(k))
    
    def _pmf_scalar(self, k: int) -> float:
        if k < 0 or k > self.n:
            return 0.0
        
        # Binomial coefficient: C(n,k)
        comb = math.comb(self.n, k)
        return comb * (self.p ** k) * ((1 - self.p) ** (self.n - k))
    
    def cdf(self, k: Union[int, Vector]) -> Union[float, Vector]:
        """
        Cumulative distribution function.
        
        P(X ≤ k) - probability of getting at most k successes.
        """
        if isinstance(k, Vector):
            return Vector([self._cdf_scalar(int(k[i])) for i in range(k.size)])
        return self._cdf_scalar(int(k))
    
    def _cdf_scalar(self, k: int) -> float:
        if k < 0:
            return 0.0
        if k >= self.n:
            return 1.0
        return sum(self._pmf_scalar(i) for i in range(k + 1))
    
    def sample(self, n_samples: int = 1) -> Union[int, Vector, Matrix]:
        """
        Generate samples from the Binomial distribution.
        
        Simulates n independent Bernoulli trials and counts successes.
        """
        if n_samples == 1:
            successes = 0
            for _ in range(self.n):
                if random.random() < self.p:
                    successes += 1
            return successes
        else:
            samples = [self.sample(1) for _ in range(n_samples)]
            return Vector(samples)
    
    def mean(self) -> float:
        """Expected value."""
        return self.n * self.p
    
    def variance(self) -> float:
        """Variance."""
        return self.n * self.p * (1 - self.p)
    
    def __repr__(self) -> str:
        return f"Binomial(n={self.n}, p={self.p:.4f})"


class ExponentialDistribution(Distribution):
    """
    Exponential distribution: Exp(λ)
    
    Models time between events in a Poisson process.
    Used for: waiting times, survival analysis, reliability.
    
    Formula: f(x) = λ * exp(-λx) for x ≥ 0
    
    Where λ is the rate parameter (inverse of expected time).
    """
    
    def __init__(self, rate: float = 1.0):
        """
        Initialize Exponential distribution.
        
        Args:
            rate: λ (rate parameter, must be > 0).
        """
        super().__init__("Exponential")
        if rate <= 0:
            raise ValueError("Rate must be greater than 0")
        self.rate = rate
    
    def pdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """
        Probability density function at x.
        
        Args:
            x: Time (must be ≥ 0).
        """
        if isinstance(x, Vector):
            return Vector([self._pdf_scalar(x[i]) for i in range(x.size)])
        return self._pdf_scalar(x)
    
    def _pdf_scalar(self, x: float) -> float:
        if x < 0:
            return 0.0
        return self.rate * math.exp(-self.rate * x)
    
    def cdf(self, x: Union[float, Vector]) -> Union[float, Vector]:
        """
        Cumulative distribution function.
        
        P(X ≤ x) = 1 - exp(-λx)
        """
        if isinstance(x, Vector):
            return Vector([self._cdf_scalar(x[i]) for i in range(x.size)])
        return self._cdf_scalar(x)
    
    def _cdf_scalar(self, x: float) -> float:
        if x < 0:
            return 0.0
        return 1 - math.exp(-self.rate * x)
    
    def sample(self, n: int = 1) -> Union[float, Vector, Matrix]:
        """
        Generate samples using the inverse transform method.
        
        For exponential: X = -ln(U) / λ where U ~ Uniform(0,1)
        """
        if n == 1:
            u = random.random()
            return -math.log(u) / self.rate
        else:
            samples = [self.sample(1) for _ in range(n)]
            return Vector(samples)
    
    def mean(self) -> float:
        """Expected value."""
        return 1.0 / self.rate
    
    def variance(self) -> float:
        """Variance."""
        return 1.0 / (self.rate ** 2)
    
    def __repr__(self) -> str:
        return f"Exponential(rate={self.rate:.4f})"


class PoissonDistribution(Distribution):
    """
    Poisson distribution: Poisson(λ)
    
    Models the number of events in a fixed interval.
    Used for: counts of rare events, call center arrivals, traffic.
    
    Formula: P(X=k) = (λ^k * e^(-λ)) / k!
    
    Where λ is the average number of events per interval.
    """
    
    def __init__(self, lam: float = 1.0):
        """
        Initialize Poisson distribution.
        
        Args:
            lam: λ (average count, must be > 0).
        """
        super().__init__("Poisson")
        if lam <= 0:
            raise ValueError("λ must be greater than 0")
        self.lam = lam
    
    def pmf(self, k: Union[int, Vector]) -> Union[float, Vector]:
        """
        Probability mass function at k.
        """
        if isinstance(k, Vector):
            return Vector([self._pmf_scalar(int(k[i])) for i in range(k.size)])
        return self._pmf_scalar(int(k))
    
    def _pmf_scalar(self, k: int) -> float:
        if k < 0:
            return 0.0
        return (self.lam ** k) * math.exp(-self.lam) / math.factorial(k)
    
    def cdf(self, k: Union[int, Vector]) -> Union[float, Vector]:
        """
        Cumulative distribution function.
        
        P(X ≤ k) - probability of at most k events.
        """
        if isinstance(k, Vector):
            return Vector([self._cdf_scalar(int(k[i])) for i in range(k.size)])
        return self._cdf_scalar(int(k))
    
    def _cdf_scalar(self, k: int) -> float:
        if k < 0:
            return 0.0
        return sum(self._pmf_scalar(i) for i in range(k + 1))
    
    def sample(self, n: int = 1) -> Union[int, Vector, Matrix]:
        """
        Generate samples from Poisson distribution.
        
        Uses the fact that Poisson(λ) counts events in interval length 1.
        """
        if n == 1:
            # Generate exponential inter-arrival times until exceeding 1
            count = 0
            time = 0.0
            while time < 1.0:
                # Sample exponential inter-arrival time
                u = random.random()
                time += -math.log(u) / self.lam
                if time < 1.0:
                    count += 1
            return count
        else:
            samples = [self.sample(1) for _ in range(n)]
            return Vector(samples)
    
    def mean(self) -> float:
        """Expected value."""
        return self.lam
    
    def variance(self) -> float:
        """Variance."""
        return self.lam
    
    def __repr__(self) -> str:
        return f"Poisson(λ={self.lam:.4f})"
```

#### Step 3: Implement Statistical Functions

**File: `src/probability/stats.py`**

```python
"""
Statistical functions for machine learning.

This module implements statistical measures and hypothesis tests
used in model evaluation and inference.
"""

from typing import List, Tuple, Optional, Union
import math
from src.linear_algebra import Vector, Matrix
from src.probability.distributions import GaussianDistribution


class Statistics:
    """
    Statistical functions for machine learning.
    
    Provides:
    - Descriptive statistics (mean, variance, covariance)
    - Hypothesis testing (t-test, chi-square)
    - Maximum Likelihood Estimation
    - Confidence intervals
    """
    
    # ==================== DESCRIPTIVE STATISTICS ====================
    
    @staticmethod
    def mean(data: Vector) -> float:
        """Compute the arithmetic mean."""
        if data.size == 0:
            raise ValueError("Cannot compute mean of empty data")
        return sum(data[i] for i in range(data.size)) / data.size
    
    @staticmethod
    def variance(data: Vector, ddof: int = 0) -> float:
        """Compute variance (ddof=0: population, ddof=1: sample)."""
        if data.size <= ddof:
            raise ValueError("Not enough data points")
        m = Statistics.mean(data)
        return sum((data[i] - m) ** 2 for i in range(data.size)) / (data.size - ddof)
    
    @staticmethod
    def standard_deviation(data: Vector, ddof: int = 0) -> float:
        """Compute standard deviation."""
        return math.sqrt(Statistics.variance(data, ddof))
    
    @staticmethod
    def covariance(x: Vector, y: Vector, ddof: int = 0) -> float:
        """Compute covariance between two vectors."""
        if x.size != y.size:
            raise ValueError("Vectors must have the same size")
        if x.size <= ddof:
            raise ValueError("Not enough data points")
        
        mean_x = Statistics.mean(x)
        mean_y = Statistics.mean(y)
        
        return sum((x[i] - mean_x) * (y[i] - mean_y) 
                   for i in range(x.size)) / (x.size - ddof)
    
    @staticmethod
    def correlation(x: Vector, y: Vector) -> float:
        """Compute Pearson correlation coefficient."""
        cov = Statistics.covariance(x, y, ddof=1)
        std_x = Statistics.standard_deviation(x, ddof=1)
        std_y = Statistics.standard_deviation(y, ddof=1)
        
        if std_x == 0 or std_y == 0:
            return 0.0
        
        return cov / (std_x * std_y)
    
    @staticmethod
    def covariance_matrix(data: Matrix) -> Matrix:
        """Compute covariance matrix from data matrix (samples x features)."""
        n = data.rows
        if n < 2:
            raise ValueError("Need at least 2 samples")
        
        # Center the data
        means = [Statistics.mean(data.col(j)) for j in range(data.cols)]
        centered_data = [[data[i, j] - means[j] for j in range(data.cols)] 
                        for i in range(data.rows)]
        centered = Matrix(centered_data)
        
        # Covariance: (1/(n-1)) * X^T * X
        covariance = centered.T @ centered / (n - 1)
        return covariance
    
    @staticmethod
    def correlation_matrix(data: Matrix) -> Matrix:
        """Compute correlation matrix from data."""
        cov = Statistics.covariance_matrix(data)
        n = cov.rows
        
        # Extract standard deviations (diagonal of covariance)
        stds = [math.sqrt(max(cov[i, i], 1e-10)) for i in range(n)]
        
        # Normalize
        corr_data = [[0.0] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                if stds[i] > 0 and stds[j] > 0:
                    corr_data[i][j] = cov[i, j] / (stds[i] * stds[j])
                else:
                    corr_data[i][j] = 1.0 if i == j else 0.0
        
        return Matrix(corr_data)
    
    # ==================== MAXIMUM LIKELIHOOD ESTIMATION ====================
    
    @staticmethod
    def mle_gaussian(data: Vector) -> Tuple[float, float]:
        """
        Maximum Likelihood Estimation for Gaussian distribution.
        
        Returns the MLE estimates of mean and standard deviation.
        
        μ_hat = (1/n) * Σ x_i
        σ_hat = sqrt((1/n) * Σ (x_i - μ_hat)^2)
        
        MLE is the foundation of parameter estimation in statistics.
        It finds the parameters that make the observed data most likely.
        """
        n = data.size
        if n == 0:
            raise ValueError("Cannot estimate from empty data")
        
        mean_hat = Statistics.mean(data)
        var_hat = Statistics.variance(data, ddof=0)  # Population variance for MLE
        std_hat = math.sqrt(var_hat)
        
        return mean_hat, std_hat
    
    @staticmethod
    def mle_bernoulli(data: Vector) -> float:
        """
        MLE for Bernoulli distribution.
        
        p_hat = (1/n) * Σ x_i
        
        For binary data, this is simply the proportion of successes.
        """
        n = data.size
        if n == 0:
            raise ValueError("Cannot estimate from empty data")
        
        return sum(data[i] for i in range(n)) / n
    
    @staticmethod
    def log_likelihood_gaussian(data: Vector, mean: float, std: float) -> float:
        """Compute log-likelihood of Gaussian parameters."""
        dist = GaussianDistribution(mean, std)
        log_likelihoods = dist.log_pdf(data)
        return sum(log_likelihoods[i] for i in range(log_likelihoods.size))
    
    # ==================== HYPOTHESIS TESTING ====================
    
    @staticmethod
    def t_test(data: Vector, population_mean: float = 0.0, 
               alpha: float = 0.05) -> Tuple[float, float, bool]:
        """
        One-sample t-test.
        
        Tests whether the sample mean is significantly different from
        a specified population mean.
        
        Args:
            data: Sample data.
            population_mean: Hypothesized mean.
            alpha: Significance level.
            
        Returns:
            Tuple of (t_statistic, p_value, reject_null).
        """
        n = data.size
        if n < 2:
            raise ValueError("Need at least 2 data points")
        
        sample_mean = Statistics.mean(data)
        sample_std = Statistics.standard_deviation(data, ddof=1)
        
        if sample_std == 0:
            # All values are identical
            return 0.0, 1.0, False
        
        # t-statistic
        t_stat = (sample_mean - population_mean) / (sample_std / math.sqrt(n))
        
        # Degrees of freedom
        df = n - 1
        
        # Approximate p-value using t-distribution
        # (Using Gaussian approximation for large n)
        if n > 30:
            # Use Gaussian approximation
            p_value = 2 * (1 - Statistics._normal_cdf(abs(t_stat)))
        else:
            # Use t-distribution approximation
            p_value = 2 * (1 - Statistics._t_cdf_approx(abs(t_stat), df))
        
        reject_null = p_value < alpha
        
        return t_stat, p_value, reject_null
    
    @staticmethod
    def _normal_cdf(x: float) -> float:
        """Approximate CDF of standard normal distribution."""
        return 0.5 * (1 + math.erf(x / math.sqrt(2)))
    
    @staticmethod
    def _t_cdf_approx(t_stat: float, df: int) -> float:
        """
        Approximate CDF of t-distribution.
        
        Uses a Gaussian approximation with adjusted degrees of freedom.
        """
        # For larger df, t approaches normal
        if df > 30:
            return Statistics._normal_cdf(t_stat)
        
        # Otherwise use a simplified approximation
        # This is a rough approximation for educational purposes
        # In practice, use scipy.stats.t.cdf
        return 0.5 * (1 + math.erf(t_stat / math.sqrt(2 * df / (df - 2))))
    
    @staticmethod
    def chi_square_test(observed: Matrix, expected: Matrix) -> Tuple[float, float, bool]:
        """
        Chi-square test for independence.
        
        Tests whether two categorical variables are independent.
        
        Args:
            observed: Observed contingency table.
            expected: Expected contingency table under independence.
            
        Returns:
            Tuple of (chi_square_statistic, p_value, reject_null).
        """
        if observed.shape != expected.shape:
            raise ValueError("Observed and expected matrices must have same shape")
        
        # Chi-square statistic
        chi_square = 0.0
        for i in range(observed.rows):
            for j in range(observed.cols):
                if expected[i, j] > 0:
                    diff = observed[i, j] - expected[i, j]
                    chi_square += (diff * diff) / expected[i, j]
        
        # Degrees of freedom: (rows - 1) * (cols - 1)
        df = (observed.rows - 1) * (observed.cols - 1)
        
        # Approximate p-value using chi-square distribution
        p_value = 1 - Statistics._chi_square_cdf_approx(chi_square, df)
        
        # Reject null if p < 0.05
        reject_null = p_value < 0.05
        
        return chi_square, p_value, reject_null
    
    @staticmethod
    def _chi_square_cdf_approx(x: float, df: int) -> float:
        """
        Approximate CDF of chi-square distribution.
        
        Uses a normal approximation (Wilson-Hilferty).
        """
        # Wilson-Hilferty approximation
        if df <= 0:
            return 0.0
        
        if x <= 0:
            return 0.0
        
        # For small df, use a rough approximation
        if df < 30:
            # This is a rough approximation for educational purposes
            # In practice, use scipy.stats.chi2.cdf
            z = math.pow(x / df, 1/3) - (1 - 2 / (9 * df))
            z /= math.sqrt(2 / (9 * df))
            return Statistics._normal_cdf(z)
        else:
            # Normal approximation
            mean = df
            var = 2 * df
            std = math.sqrt(var)
            z = (x - mean) / std
            return Statistics._normal_cdf(z)
    
    # ==================== CONFIDENCE INTERVALS ====================
    
    @staticmethod
    def confidence_interval(data: Vector, confidence: float = 0.95) -> Tuple[float, float]:
        """
        Compute confidence interval for the mean.
        
        Args:
            data: Sample data.
            confidence: Confidence level (e.g., 0.95 for 95% CI).
            
        Returns:
            Tuple of (lower_bound, upper_bound).
        """
        n = data.size
        if n < 2:
            raise ValueError("Need at least 2 data points")
        
        sample_mean = Statistics.mean(data)
        sample_std = Statistics.standard_deviation(data, ddof=1)
        
        # z-score for confidence level
        # 90% -> 1.645, 95% -> 1.96, 99% -> 2.576
        z_scores = {0.90: 1.645, 0.95: 1.96, 0.99: 2.576}
        z = z_scores.get(confidence, 1.96)
        
        margin = z * (sample_std / math.sqrt(n))
        
        return sample_mean - margin, sample_mean + margin
    
    # ==================== BAYESIAN STATISTICS ====================
    
    @staticmethod
    def bayes_rule(prior: float, likelihood: float, evidence: float) -> float:
        """
        Bayes' Rule: P(A|B) = P(B|A) * P(A) / P(B)
        
        This is the foundation of Bayesian inference.
        
        Args:
            prior: P(A) - prior probability of A.
            likelihood: P(B|A) - probability of B given A.
            evidence: P(B) - total probability of B.
            
        Returns:
            Posterior probability P(A|B).
        """
        if evidence == 0:
            raise ValueError("Evidence cannot be zero")
        return (likelihood * prior) / evidence
    
    @staticmethod
    def naive_bayes_classifier(X: Matrix, y: Vector, 
                               features: Vector) -> Tuple[float, float]:
        """
        Simple Naive Bayes classifier for binary classification.
        
        Naive Bayes assumes features are independent given the class.
        
        Args:
            X: Training data (samples x features).
            y: Labels (0 or 1).
            features: Features to classify (Vector).
            
        Returns:
            Tuple of (P(y=0|features), P(y=1|features)).
        """
        n_samples = X.rows
        n_features = X.cols
        
        # Prior probabilities
        p_y0 = sum(1 for i in range(n_samples) if y[i] == 0) / n_samples
        p_y1 = sum(1 for i in range(n_samples) if y[i] == 1) / n_samples
        
        # Estimate likelihoods using Gaussian distributions
        # For each class and feature, compute mean and std
        class0_data = []
        class1_data = []
        
        for i in range(n_samples):
            if y[i] == 0:
                class0_data.append(X.row(i))
            else:
                class1_data.append(X.row(i))
        
        # Convert to matrices
        if class0_data:
            X0 = Matrix([d.to_list() for d in class0_data])
        else:
            X0 = Matrix.zeros(1, n_features)
        
        if class1_data:
            X1 = Matrix([d.to_list() for d in class1_data])
        else:
            X1 = Matrix.zeros(1, n_features)
        
        # Compute likelihoods for each feature
        # P(feature | class) assuming Gaussian distribution
        likelihood0 = 1.0
        likelihood1 = 1.0
        
        for j in range(n_features):
            # For class 0
            col0 = X0.col(j)
            if col0.size > 1:
                mean0 = Statistics.mean(col0)
                std0 = Statistics.standard_deviation(col0, ddof=1)
                if std0 > 0:
                    dist0 = GaussianDistribution(mean0, std0)
                    likelihood0 *= dist0.pdf(features[j])
            
            # For class 1
            col1 = X1.col(j)
            if col1.size > 1:
                mean1 = Statistics.mean(col1)
                std1 = Statistics.standard_deviation(col1, ddof=1)
                if std1 > 0:
                    dist1 = GaussianDistribution(mean1, std1)
                    likelihood1 *= dist1.pdf(features[j])
        
        # Compute evidence (normalizing factor)
        evidence = likelihood0 * p_y0 + likelihood1 * p_y1
        
        # Posterior probabilities
        posterior0 = (likelihood0 * p_y0) / evidence if evidence > 0 else 0.5
        posterior1 = (likelihood1 * p_y1) / evidence if evidence > 0 else 0.5
        
        return posterior0, posterior1
```

#### Step 4: Update Package Initialization

**File: `src/probability/__init__.py`**

```python
"""
Probability and statistics package for machine learning.
"""

from src.probability.distributions import (
    Distribution, GaussianDistribution, BernoulliDistribution,
    BinomialDistribution, ExponentialDistribution, PoissonDistribution
)
from src.probability.stats import Statistics

__all__ = [
    'Distribution', 'GaussianDistribution', 'BernoulliDistribution',
    'BinomialDistribution', 'ExponentialDistribution', 'PoissonDistribution',
    'Statistics'
]
```

### The Verification

#### Step 1: Create the Test Suite

**File: `tests/test_probability.py`**

```python
"""
Unit tests for probability and statistics module.
"""

import pytest
import math
from src.probability import (
    GaussianDistribution, BernoulliDistribution, BinomialDistribution,
    ExponentialDistribution, PoissonDistribution, Statistics
)
from src.linear_algebra import Vector, Matrix


class TestDistributions:
    """Test probability distributions."""
    
    def test_gaussian(self):
        """Test Gaussian distribution."""
        g = GaussianDistribution(0.0, 1.0)
        
        # PDF at x=0 should be ~0.399
        assert g.pdf(0.0) == pytest.approx(0.3989, abs=1e-4)
        
        # PDF at x=1 should be ~0.242
        assert g.pdf(1.0) == pytest.approx(0.2420, abs=1e-4)
        
        # CDF at x=0 should be 0.5
        assert g.cdf(0.0) == pytest.approx(0.5, abs=1e-4)
        
        # Mean and variance
        assert g.mean() == 0.0
        assert g.variance() == 1.0
        
        # Samples
        samples = g.sample(1000)
        assert samples.size == 1000
        
        # Should be centered around mean
        sample_mean = Statistics.mean(samples)
        assert abs(sample_mean) < 0.1
    
    def test_bernoulli(self):
        """Test Bernoulli distribution."""
        b = BernoulliDistribution(0.7)
        
        # PMF
        assert b.pmf(0) == 0.3
        assert b.pmf(1) == 0.7
        
        # CDF
        assert b.cdf(0) == 0.3
        assert b.cdf(0.5) == 0.3
        assert b.cdf(1) == 1.0
        
        # Mean and variance
        assert b.mean() == 0.7
        assert b.variance() == 0.21
        
        # Entropy (should be positive for p=0.7)
        assert b.entropy() > 0
        
        # Samples
        samples = b.sample(1000)
        sample_mean = Statistics.mean(samples)
        assert abs(sample_mean - 0.7) < 0.05
    
    def test_binomial(self):
        """Test Binomial distribution."""
        b = BinomialDistribution(10, 0.5)
        
        # PMF at k=5 should be maximum
        pmf_5 = b.pmf(5)
        pmf_4 = b.pmf(4)
        pmf_6 = b.pmf(6)
        assert pmf_5 > pmf_4
        assert pmf_5 > pmf_6
        
        # Sum of PMF should be 1
        total = sum(b.pmf(k) for k in range(11))
        assert total == pytest.approx(1.0, abs=1e-6)
        
        # Mean and variance
        assert b.mean() == 5.0
        assert b.variance() == 2.5
    
    def test_exponential(self):
        """Test Exponential distribution."""
        e = ExponentialDistribution(2.0)
        
        # PDF at x=0 should be rate
        assert e.pdf(0.0) == 2.0
        
        # Mean should be 1/rate
        assert e.mean() == 0.5
        assert e.variance() == 0.25
        
        # CDF at infinity should be 1
        assert e.cdf(100) == pytest.approx(1.0, abs=1e-6)
    
    def test_poisson(self):
        """Test Poisson distribution."""
        p = PoissonDistribution(3.0)
        
        # PMF at k=3 should be maximum
        assert p.pmf(3) > p.pmf(2)
        assert p.pmf(3) > p.pmf(4)
        
        # Mean and variance should be λ
        assert p.mean() == 3.0
        assert p.variance() == 3.0


class TestStatistics:
    """Test statistical functions."""
    
    def test_mean_variance(self):
        """Test mean and variance computation."""
        data = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
        
        assert Statistics.mean(data) == 3.0
        assert Statistics.variance(data, ddof=0) == 2.0
        assert Statistics.variance(data, ddof=1) == 2.5
        
        # Empty data
        empty = Vector([])
        with pytest.raises(ValueError):
            Statistics.mean(empty)
    
    def test_covariance_correlation(self):
        """Test covariance and correlation."""
        x = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
        y = Vector([2.0, 4.0, 6.0, 8.0, 10.0])
        
        # Perfect positive correlation
        assert Statistics.covariance(x, y) == pytest.approx(2.5, abs=1e-4)
        assert Statistics.correlation(x, y) == pytest.approx(1.0, abs=1e-4)
        
        # Data matrix
        data = Matrix([[1.0, 2.0], [2.0, 4.0], [3.0, 6.0]])
        cov = Statistics.covariance_matrix(data)
        assert cov[0, 1] == pytest.approx(1.0, abs=1e-4)
        
        corr = Statistics.correlation_matrix(data)
        assert corr[0, 1] == pytest.approx(1.0, abs=1e-4)
    
    def test_mle(self):
        """Test Maximum Likelihood Estimation."""
        data = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
        
        # Gaussian MLE
        mean, std = Statistics.mle_gaussian(data)
        assert mean == 3.0
        assert std == pytest.approx(math.sqrt(2.0), abs=1e-4)
        
        # Bernoulli MLE
        binary = Vector([1.0, 0.0, 1.0, 1.0, 0.0])
        p = Statistics.mle_bernoulli(binary)
        assert p == 0.6
    
    def test_confidence_interval(self):
        """Test confidence interval computation."""
        data = Vector([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0])
        
        lower, upper = Statistics.confidence_interval(data, 0.95)
        assert lower < 5.0
        assert upper > 5.0
        
        # With less data, interval should be wider
        small_data = Vector([1.0, 2.0, 3.0])
        lower2, upper2 = Statistics.confidence_interval(small_data, 0.95)
        # Interval should be wider
        assert (upper2 - lower2) > (upper - lower)
    
    def test_naive_bayes(self):
        """Test Naive Bayes classifier."""
        # Create simple dataset
        X_data = [
            [1.0, 1.0],
            [2.0, 2.0],
            [10.0, 10.0],
            [11.0, 11.0]
        ]
        y = Vector([0.0, 0.0, 1.0, 1.0])
        X = Matrix(X_data)
        
        # Test classification
        test_point = Vector([5.0, 5.0])
        p0, p1 = Statistics.naive_bayes_classifier(X, y, test_point)
        
        # Should be more likely class 0 (closer to first cluster)
        assert p0 > p1
        
        test_point2 = Vector([12.0, 12.0])
        p0_2, p1_2 = Statistics.naive_bayes_classifier(X, y, test_point2)
        
        # Should be more likely class 1
        assert p1_2 > p0_2
```

#### Step 2: Run the Tests

```bash
# From the project root
pytest tests/test_probability.py -v
```

#### Step 3: Interactive Verification

```bash
python
```

```python
>>> from src.probability import GaussianDistribution, BernoulliDistribution, Statistics
>>> from src.linear_algebra import Vector, Matrix
>>> 
>>> # Gaussian distribution
>>> g = GaussianDistribution(0.0, 1.0)
>>> print(f"P(X=0) = {g.pdf(0.0):.4f}")
P(X=0) = 0.3989
>>> print(f"P(X≤0) = {g.cdf(0.0):.4f}")
P(X≤0) = 0.5000
>>> 
>>> # Generate samples
>>> samples = g.sample(10)
>>> print(f"Samples: {samples}")
Samples: [0.2842, -0.8470, -0.2187, 1.2510, 0.9417, -0.8994, 0.2455, -0.2443, -0.6709, -0.3249]
>>> 
>>> # Bernoulli distribution
>>> b = BernoulliDistribution(0.7)
>>> print(f"P(X=1) = {b.pmf(1):.4f}")
P(X=1) = 0.7000
>>> 
>>> # Statistics
>>> data = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
>>> print(f"Mean: {Statistics.mean(data):.2f}")
Mean: 3.00
>>> print(f"Variance: {Statistics.variance(data, ddof=1):.2f}")
Variance: 2.50
>>> 
>>> # Correlation
>>> x = Vector([1, 2, 3, 4, 5])
>>> y = Vector([2, 4, 6, 8, 10])
>>> print(f"Correlation: {Statistics.correlation(x, y):.4f}")
Correlation: 1.0000
```
---

*Next: We'll implement Bayes' Theorem, build a complete Bayesian classifier, and explore the bias-variance tradeoff—understanding why models generalize and how to evaluate them.*
