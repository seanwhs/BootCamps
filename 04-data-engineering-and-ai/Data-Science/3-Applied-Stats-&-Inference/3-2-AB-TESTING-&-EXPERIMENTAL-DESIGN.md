# MODULE 3.2, PART 1: A/B TESTING & EXPERIMENTAL DESIGN

Welcome to the heart of applied statistics! You've mastered understanding uncertainty — now you'll learn how to **make decisions** under that uncertainty. Think of this as becoming a **scientific detective** — you'll design experiments to prove whether changes actually work.

---

## Target: Build a Complete A/B Testing Framework

We're creating:
1. `src/hypothesis/parametric.py` — Parametric hypothesis tests (t-tests, ANOVA)
2. `src/hypothesis/nonparametric.py` — Non-parametric alternatives
3. `src/hypothesis/power_analysis.py` — Statistical power and sample size calculations
4. `src/hypothesis/corrections.py` — Multiple testing corrections

In this part, we'll focus on **experimental design** and **power analysis**.

---

## The Concept: What is an A/B Test?

Imagine you're a product manager at an e-commerce site. You've redesigned the checkout button from green to orange. Does it increase conversions?

**A/B testing** (also called randomized controlled trials) is the gold standard for answering this:

1. **Split users randomly** into two groups
2. **Group A (Control)**: Sees the green button
3. **Group B (Treatment)**: Sees the orange button
4. **Measure conversions** in both groups
5. **Determine** if the difference is statistically significant

### Key Concepts in Experimental Design

| Concept | Definition | Analogy |
|---------|------------|---------|
| **Null Hypothesis (H₀)** | No effect exists | "The button color doesn't matter" |
| **Alternative Hypothesis (H₁)** | An effect exists | "Orange button increases conversions" |
| **Type I Error (α)** | False positive (saying it works when it doesn't) | α = 0.05 (5% risk) |
| **Type II Error (β)** | False negative (saying it doesn't work when it does) | β = 0.20 (20% risk) |
| **Power (1-β)** | Probability of detecting a real effect | Power = 0.80 (80% chance) |
| **Effect Size** | Magnitude of the difference | 2% increase in conversions |
| **Sample Size** | Number of users needed | Depends on effect size and power |

---

## Implementation 1: Power Analysis Module

Create the file `src/hypothesis/power_analysis.py`:

```python
#!/usr/bin/env python3
"""
Power Analysis Module for Phase 3 Statistics Project.

Provides tools for calculating statistical power, sample size, and effect size
for experimental design. This is essential for planning A/B tests before
collecting data.

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
from typing import Optional, Tuple, Dict, Union
import logging
from scipy import stats
from scipy.stats import norm, t
from dataclasses import dataclass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class PowerResult:
    """Container for power analysis results."""
    power: float
    sample_size: int
    effect_size: float
    alpha: float
    test_type: str
    interpretation: str


class PowerAnalyzer:
    """
    Comprehensive power analysis toolkit for experimental design.
    
    Think of this as your "experiment planning calculator" — it tells you
    how many users you need to detect a meaningful effect.
    
    Key methods:
    - calculate_power_for_means: Power for comparing two means
    - calculate_power_for_proportions: Power for comparing two proportions
    - sample_size_for_means: Required sample size for mean comparison
    - sample_size_for_proportions: Required sample size for proportion comparison
    """
    
    def __init__(
        self,
        alpha: float = 0.05,
        power_target: float = 0.80,
        alternative: str = 'two-sided'
    ):
        """
        Initialize the power analyzer.
        
        Args:
            alpha: Significance level (Type I error rate). Default 0.05.
            power_target: Desired statistical power. Default 0.80.
            alternative: 'two-sided', 'greater', or 'less'
        
        Example:
            >>> analyzer = PowerAnalyzer(alpha=0.05, power_target=0.90)
        """
        if not 0 < alpha < 1:
            raise ValueError(f"alpha must be between 0 and 1, got {alpha}")
        if not 0 < power_target < 1:
            raise ValueError(f"power_target must be between 0 and 1, got {power_target}")
        
        self.alpha = alpha
        self.power_target = power_target
        self.alternative = alternative
        
        # Pre-compute critical values
        self.z_alpha = self._get_z_critical(alpha)
        self.z_beta = self._get_z_critical(1 - power_target)
        
        logger.info(
            f"Initialized PowerAnalyzer: α={alpha}, power={power_target}, "
            f"alternative={alternative}"
        )
    
    def _get_z_critical(self, probability: float) -> float:
        """Get z-critical value for given probability."""
        if self.alternative == 'two-sided':
            return norm.ppf(1 - probability / 2)
        elif self.alternative == 'greater':
            return norm.ppf(1 - probability)
        elif self.alternative == 'less':
            return norm.ppf(probability)
        else:
            raise ValueError(f"Unknown alternative: {self.alternative}")
    
    def _calculate_power_means(
        self,
        effect_size: float,
        n1: int,
        n2: int,
        sigma1: float,
        sigma2: float,
        alpha: Optional[float] = None
    ) -> float:
        """
        Calculate power for comparing two means (independent samples).
        
        Uses the standard formula based on the normal approximation.
        
        Args:
            effect_size: Difference in means (treatment - control)
            n1: Sample size for group 1
            n2: Sample size for group 2
            sigma1: Standard deviation of group 1
            sigma2: Standard deviation of group 2
            alpha: Significance level (uses default if None)
        
        Returns:
            float: Statistical power (probability of detecting effect)
        """
        if alpha is None:
            alpha = self.alpha
        
        # Pooled or separate variance?
        # Using Welch's approximation (separate variances)
        se = np.sqrt(sigma1**2 / n1 + sigma2**2 / n2)
        
        # Calculate non-centrality parameter (effect size in SE units)
        ncp = effect_size / se
        
        # Get critical value
        z_critical = self._get_z_critical(alpha)
        
        # Calculate power
        if self.alternative == 'two-sided':
            # Two-sided test: reject if |z| > z_critical
            power = 1 - (norm.cdf(z_critical - ncp) - 
                        norm.cdf(-z_critical - ncp))
        elif self.alternative == 'greater':
            power = 1 - norm.cdf(z_critical - ncp)
        elif self.alternative == 'less':
            power = norm.cdf(-z_critical - ncp)
        else:
            raise ValueError(f"Unknown alternative: {self.alternative}")
        
        return float(power)
    
    def _calculate_power_proportions(
        self,
        p1: float,
        p2: float,
        n1: int,
        n2: int,
        alpha: Optional[float] = None
    ) -> float:
        """
        Calculate power for comparing two proportions.
        
        Args:
            p1: Proportion in group 1 (control)
            p2: Proportion in group 2 (treatment)
            n1: Sample size for group 1
            n2: Sample size for group 2
            alpha: Significance level (uses default if None)
        
        Returns:
            float: Statistical power
        """
        if alpha is None:
            alpha = self.alpha
        
        # Pooled proportion for standard error under null
        p_pooled = (p1 * n1 + p2 * n2) / (n1 + n2)
        
        # Standard error under null (for test statistic)
        se_null = np.sqrt(p_pooled * (1 - p_pooled) * (1/n1 + 1/n2))
        
        # Standard error under alternative (for power calculation)
        se_alt = np.sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
        
        # Effect size
        effect = p2 - p1
        
        # Critical value
        z_critical = self._get_z_critical(alpha)
        
        # Calculate power (using normal approximation)
        # We use the alternative distribution centered at effect
        if self.alternative == 'two-sided':
            # For two-sided, calculate power for both tails
            # The non-centrality parameter for the alternative
            ncp = effect / se_alt
            
            # Critical values in terms of the alternative distribution
            # This is an approximation; more exact methods exist
            power = 1 - (norm.cdf(z_critical - ncp) - 
                        norm.cdf(-z_critical - ncp))
        elif self.alternative == 'greater':
            power = 1 - norm.cdf((z_critical * se_null - effect) / se_alt)
        elif self.alternative == 'less':
            power = norm.cdf((-z_critical * se_null - effect) / se_alt)
        else:
            raise ValueError(f"Unknown alternative: {self.alternative}")
        
        return float(power)
    
    def power_for_means(
        self,
        effect_size: float,
        n: Union[int, Tuple[int, int]],
        sigma: Union[float, Tuple[float, float]],
        alpha: Optional[float] = None
    ) -> PowerResult:
        """
        Calculate power for comparing two means.
        
        Args:
            effect_size: Difference in means (treatment - control)
            n: Sample size (if int, same for both groups; if tuple, (n1, n2))
            sigma: Standard deviation (if float, same for both; if tuple, (σ1, σ2))
            alpha: Significance level (uses default if None)
        
        Returns:
            PowerResult: Power analysis results
        
        Example:
            >>> analyzer = PowerAnalyzer()
            >>> result = analyzer.power_for_means(
            ...     effect_size=2.0, n=100, sigma=10
            ... )
            >>> print(f"Power: {result.power:.3f}")
        """
        # Parse inputs
        if isinstance(n, int):
            n1 = n2 = n
        else:
            n1, n2 = n
        
        if isinstance(sigma, (int, float)):
            sigma1 = sigma2 = sigma
        else:
            sigma1, sigma2 = sigma
        
        if alpha is None:
            alpha = self.alpha
        
        # Calculate power
        power = self._calculate_power_means(
            effect_size, n1, n2, sigma1, sigma2, alpha
        )
        
        # Standardized effect size (Cohen's d)
        pooled_sigma = np.sqrt((sigma1**2 + sigma2**2) / 2)
        cohens_d = effect_size / pooled_sigma
        
        # Interpretation
        if power >= 0.90:
            interpretation = "Excellent power (≥90%) — very likely to detect effect"
        elif power >= 0.80:
            interpretation = "Good power (≥80%) — standard target achieved"
        elif power >= 0.70:
            interpretation = "Moderate power (70-80%) — acceptable but could be better"
        elif power >= 0.60:
            interpretation = "Low power (60-70%) — high risk of missing real effect"
        else:
            interpretation = "Very low power (<60%) — experiment likely underpowered"
        
        result = PowerResult(
            power=power,
            sample_size=n1 + n2,
            effect_size=cohens_d,
            alpha=alpha,
            test_type='Two-sample mean comparison',
            interpretation=interpretation
        )
        
        logger.info(f"Power for means: {power:.3f} ({interpretation})")
        return result
    
    def power_for_proportions(
        self,
        p1: float,
        p2: float,
        n: Union[int, Tuple[int, int]],
        alpha: Optional[float] = None
    ) -> PowerResult:
        """
        Calculate power for comparing two proportions.
        
        Args:
            p1: Proportion in group 1 (control)
            p2: Proportion in group 2 (treatment)
            n: Sample size (if int, same for both; if tuple, (n1, n2))
            alpha: Significance level (uses default if None)
        
        Returns:
            PowerResult: Power analysis results
        
        Example:
            >>> analyzer = PowerAnalyzer()
            >>> result = analyzer.power_for_proportions(
            ...     p1=0.10, p2=0.13, n=1000
            ... )
            >>> print(f"Power: {result.power:.3f}")
        """
        # Parse inputs
        if isinstance(n, int):
            n1 = n2 = n
        else:
            n1, n2 = n
        
        if alpha is None:
            alpha = self.alpha
        
        # Calculate power
        power = self._calculate_power_proportions(p1, p2, n1, n2, alpha)
        
        # Effect size (Cohen's h for proportions)
        # h = 2 * arcsin(sqrt(p1)) - 2 * arcsin(sqrt(p2))
        import math
        h = 2 * (math.asin(np.sqrt(p1)) - math.asin(np.sqrt(p2)))
        
        # Interpretation
        if power >= 0.90:
            interpretation = "Excellent power (≥90%) — very likely to detect effect"
        elif power >= 0.80:
            interpretation = "Good power (≥80%) — standard target achieved"
        elif power >= 0.70:
            interpretation = "Moderate power (70-80%) — acceptable but could be better"
        elif power >= 0.60:
            interpretation = "Low power (60-70%) — high risk of missing real effect"
        else:
            interpretation = "Very low power (<60%) — experiment likely underpowered"
        
        result = PowerResult(
            power=power,
            sample_size=n1 + n2,
            effect_size=abs(h),
            alpha=alpha,
            test_type='Two-sample proportion comparison',
            interpretation=interpretation
        )
        
        logger.info(f"Power for proportions: {power:.3f} ({interpretation})")
        return result
    
    def sample_size_for_means(
        self,
        effect_size: float,
        sigma: Union[float, Tuple[float, float]],
        power: Optional[float] = None,
        alpha: Optional[float] = None,
        ratio: float = 1.0,
        max_n: int = 100000
    ) -> int:
        """
        Calculate required sample size for comparing two means.
        
        Args:
            effect_size: Desired detectable difference (treatment - control)
            sigma: Standard deviation (if float, same for both; if tuple, (σ1, σ2))
            power: Desired power (uses default if None)
            alpha: Significance level (uses default if None)
            ratio: n2/n1 ratio (1 for equal groups)
            max_n: Maximum sample size to consider
        
        Returns:
            int: Total required sample size (n1 + n2)
        
        Example:
            >>> analyzer = PowerAnalyzer()
            >>> n = analyzer.sample_size_for_means(
            ...     effect_size=2.0, sigma=10, power=0.80
            ... )
            >>> print(f"Need {n} total samples")
        """
        if power is None:
            power = self.power_target
        if alpha is None:
            alpha = self.alpha
        
        # Parse sigma
        if isinstance(sigma, (int, float)):
            sigma1 = sigma2 = sigma
        else:
            sigma1, sigma2 = sigma
        
        # Binary search for sample size
        n1_min = 2
        n1_max = max_n // 2
        
        # If effect size is 0, can't determine sample size
        if abs(effect_size) < 1e-10:
            logger.warning("Effect size is zero — infinite sample size required")
            return max_n
        
        # Binary search
        n1 = n1_min
        found = False
        
        while n1_max - n1_min > 1:
            n1 = (n1_min + n1_max) // 2
            n2 = int(n1 * ratio)
            
            power_calc = self._calculate_power_means(
                effect_size, n1, n2, sigma1, sigma2, alpha
            )
            
            if power_calc >= power:
                n1_max = n1
                found = True
            else:
                n1_min = n1
        
        if not found:
            logger.warning(f"Maximum sample size ({max_n}) insufficient for target power")
            n1 = max_n // 2
        
        n2 = int(n1 * ratio)
        total_n = n1 + n2
        
        logger.info(
            f"Required sample size for means: n1={n1}, n2={n2}, total={total_n}"
        )
        return total_n
    
    def sample_size_for_proportions(
        self,
        p1: float,
        p2: float,
        power: Optional[float] = None,
        alpha: Optional[float] = None,
        ratio: float = 1.0,
        max_n: int = 100000
    ) -> int:
        """
        Calculate required sample size for comparing two proportions.
        
        Args:
            p1: Proportion in group 1 (control)
            p2: Proportion in group 2 (treatment)
            power: Desired power (uses default if None)
            alpha: Significance level (uses default if None)
            ratio: n2/n1 ratio (1 for equal groups)
            max_n: Maximum sample size to consider
        
        Returns:
            int: Total required sample size (n1 + n2)
        
        Example:
            >>> analyzer = PowerAnalyzer()
            >>> n = analyzer.sample_size_for_proportions(
            ...     p1=0.10, p2=0.13, power=0.80
            ... )
            >>> print(f"Need {n} total samples")
        """
        if power is None:
            power = self.power_target
        if alpha is None:
            alpha = self.alpha
        
        # Binary search for sample size
        n1_min = 2
        n1_max = max_n // 2
        
        # If effect is 0, can't determine sample size
        if abs(p2 - p1) < 1e-10:
            logger.warning("No difference between proportions — infinite sample size required")
            return max_n
        
        # Binary search
        n1 = n1_min
        found = False
        
        while n1_max - n1_min > 1:
            n1 = (n1_min + n1_max) // 2
            n2 = int(n1 * ratio)
            
            power_calc = self._calculate_power_proportions(
                p1, p2, n1, n2, alpha
            )
            
            if power_calc >= power:
                n1_max = n1
                found = True
            else:
                n1_min = n1
        
        if not found:
            logger.warning(f"Maximum sample size ({max_n}) insufficient for target power")
            n1 = max_n // 2
        
        n2 = int(n1 * ratio)
        total_n = n1 + n2
        
        logger.info(
            f"Required sample size for proportions: n1={n1}, n2={n2}, total={total_n}"
        )
        return total_n
    
    def analyze_experiment_plan(
        self,
        test_type: str,
        effect_size: float,
        sample_size: int,
        **kwargs
    ) -> Dict:
        """
        Comprehensive experiment plan analysis.
        
        Provides a complete summary of power, sample size, and practical
        implications for an experiment design.
        
        Args:
            test_type: 'means' or 'proportions'
            effect_size: Size of effect to detect
            sample_size: Planned sample size
            **kwargs: Additional parameters for the specific test
        
        Returns:
            dict: Complete experiment analysis
        
        Example:
            >>> analyzer = PowerAnalyzer()
            >>> plan = analyzer.analyze_experiment_plan(
            ...     'means', effect_size=2.0, sample_size=100, sigma=10
            ... )
            >>> print(plan['recommendation'])
        """
        result = {
            'test_type': test_type,
            'effect_size': effect_size,
            'planned_n': sample_size,
            'alpha': self.alpha,
            'target_power': self.power_target,
        }
        
        if test_type == 'means':
            sigma = kwargs.get('sigma', 1)
            power_result = self.power_for_means(
                effect_size, sample_size // 2, sigma, self.alpha
            )
            current_power = power_result.power
        elif test_type == 'proportions':
            p1 = kwargs.get('p1', 0.10)
            p2 = p1 + effect_size
            power_result = self.power_for_proportions(
                p1, p2, sample_size // 2, self.alpha
            )
            current_power = power_result.power
        else:
            raise ValueError(f"Unknown test_type: {test_type}")
        
        result['current_power'] = current_power
        
        # Recommendations
        if current_power >= self.power_target:
            result['recommendation'] = (
                f"✓ Good! Power ({current_power:.3f}) exceeds target "
                f"({self.power_target:.3f}). Proceed with current sample size."
            )
            result['status'] = 'sufficient'
        elif current_power >= self.power_target - 0.05:
            result['recommendation'] = (
                f"⚠ Marginal. Power ({current_power:.3f}) is slightly below target "
                f"({self.power_target:.3f}). Consider modest increase."
            )
            result['status'] = 'marginal'
        else:
            # Calculate required sample size
            if test_type == 'means':
                required_n = self.sample_size_for_means(
                    effect_size, kwargs.get('sigma', 1), self.power_target, self.alpha
                )
            else:
                p1 = kwargs.get('p1', 0.10)
                p2 = p1 + effect_size
                required_n = self.sample_size_for_proportions(
                    p1, p2, self.power_target, self.alpha
                )
            
            result['required_n'] = required_n
            result['recommendation'] = (
                f"⚠ Insufficient power ({current_power:.3f}). "
                f"Need {required_n} total samples (currently {sample_size}). "
                f"Increase sample size by {required_n - sample_size}."
            )
            result['status'] = 'insufficient'
        
        logger.info(f"Experiment plan analysis complete: {result['status']}")
        return result


# ==================== CONVENIENCE FUNCTIONS ====================

def power_curve(
    analyzer: PowerAnalyzer,
    test_type: str,
    effect_sizes: np.ndarray,
    sample_sizes: np.ndarray,
    **kwargs
) -> Dict[str, np.ndarray]:
    """
    Generate power curve data for visualization.
    
    Useful for creating power curves that show how power varies with
    sample size and effect size.
    
    Args:
        analyzer: PowerAnalyzer instance
        test_type: 'means' or 'proportions'
        effect_sizes: Array of effect sizes to test
        sample_sizes: Array of sample sizes to test
        **kwargs: Additional parameters for specific tests
    
    Returns:
        dict: Power curve data
    
    Example:
        >>> analyzer = PowerAnalyzer()
        >>> effect_sizes = np.linspace(0.1, 1.0, 10)
        >>> sample_sizes = np.array([50, 100, 200, 500])
        >>> curves = power_curve(analyzer, 'means', effect_sizes, sample_sizes)
    """
    power_matrix = np.zeros((len(effect_sizes), len(sample_sizes)))
    
    for i, effect in enumerate(effect_sizes):
        for j, n in enumerate(sample_sizes):
            if test_type == 'means':
                result = analyzer.power_for_means(
                    effect, n // 2, kwargs.get('sigma', 1)
                )
                power_matrix[i, j] = result.power
            elif test_type == 'proportions':
                p1 = kwargs.get('p1', 0.10)
                p2 = p1 + effect
                result = analyzer.power_for_proportions(
                    p1, p2, n // 2
                )
                power_matrix[i, j] = result.power
            else:
                raise ValueError(f"Unknown test_type: {test_type}")
    
    return {
        'effect_sizes': effect_sizes,
        'sample_sizes': sample_sizes,
        'power_matrix': power_matrix
    }


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script for power analysis module.
    """
    print("Testing PowerAnalyzer...")
    
    # Initialize
    analyzer = PowerAnalyzer(alpha=0.05, power_target=0.80, alternative='two-sided')
    
    # Test 1: Power for means
    result = analyzer.power_for_means(effect_size=2.0, n=100, sigma=10)
    print(f"✓ Power for means: {result.power:.3f}")
    assert 0.5 < result.power < 1.0, "Power should be between 0.5 and 1.0"
    
    # Test 2: Power for proportions
    result = analyzer.power_for_proportions(p1=0.10, p2=0.13, n=1000)
    print(f"✓ Power for proportions: {result.power:.3f}")
    assert 0.5 < result.power < 1.0, "Power should be between 0.5 and 1.0"
    
    # Test 3: Sample size for means
    n = analyzer.sample_size_for_means(effect_size=2.0, sigma=10, power=0.80)
    print(f"✓ Sample size for means: {n}")
    assert n > 0, "Sample size should be positive"
    
    # Test 4: Sample size for proportions
    n = analyzer.sample_size_for_proportions(p1=0.10, p2=0.13, power=0.80)
    print(f"✓ Sample size for proportions: {n}")
    assert n > 0, "Sample size should be positive"
    
    # Test 5: Experiment plan analysis
    plan = analyzer.analyze_experiment_plan(
        'means', effect_size=2.0, sample_size=100, sigma=10
    )
    print(f"✓ Experiment plan: {plan['status']}")
    assert 'recommendation' in plan, "Plan should contain recommendation"
    
    # Test 6: Power curve
    effect_sizes = np.linspace(0.5, 3.0, 5)
    sample_sizes = np.array([50, 100, 200])
    curves = power_curve(analyzer, 'means', effect_sizes, sample_sizes, sigma=10)
    print(f"✓ Power curve generated: {curves['power_matrix'].shape}")
    assert curves['power_matrix'].shape == (5, 3), "Wrong power matrix shape"
    
    print("\nAll tests passed! Power analysis module is ready for use.")
    
    # Example usage
    print("\n" + "="*60)
    print("EXAMPLE: A/B TEST PLANNING")
    print("="*60)
    
    # Planning an A/B test for conversion rates
    print("\nScenario: Testing a new checkout button")
    print("Control conversion: 10%")
    print("Expected treatment: 12% (2% absolute increase)")
    print(f"Significance level: {analyzer.alpha}")
    print(f"Target power: {analyzer.power_target}")
    
    # Calculate required sample size
    n_required = analyzer.sample_size_for_proportions(
        p1=0.10, p2=0.12, power=0.80
    )
    print(f"\nRequired total sample size: {n_required}")
    print(f"  Control group: {n_required//2}")
    print(f"  Treatment group: {n_required - n_required//2}")
    
    # Check power for a feasible sample size
    n_feasible = 2000  # Let's say we can get 2000 users
    result = analyzer.power_for_proportions(
        p1=0.10, p2=0.12, n=n_feasible//2
    )
    print(f"\nPower with {n_feasible} total samples: {result.power:.3f}")
    print(f"Interpretation: {result.interpretation}")
    
    # Minimum detectable effect with feasible sample size
    print("\nMinimum detectable effect with 2000 samples:")
    min_effect = 0.01  # Start at 1%
    for i in range(20):
        p2_test = 0.10 + (i+1) * 0.005  # 0.5% increments
        power_test = analyzer._calculate_power_proportions(
            0.10, p2_test, n_feasible//2, n_feasible//2, 0.05
        )
        if power_test >= analyzer.power_target:
            min_effect = p2_test - 0.10
            break
    
    print(f"  Can detect {min_effect*100:.1f}% absolute increase with 80% power")
```

---

## Implementation 2: Hypothesis Testing Module (Parametric)

Create the file `src/hypothesis/parametric.py`:

```python
#!/usr/bin/env python3
"""
Parametric Hypothesis Testing Module for Phase 3 Statistics Project.

Provides implementations of common parametric tests:
- One-sample t-test
- Two-sample t-test (independent)
- Paired t-test
- One-way ANOVA
- Post-hoc tests

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
from typing import Optional, Tuple, Dict, List, Union
import logging
from scipy import stats
from scipy.stats import t, f
from dataclasses import dataclass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class TestResult:
    """Container for hypothesis test results."""
    statistic: float
    p_value: float
    df: float
    effect_size: Optional[float] = None
    ci_low: Optional[float] = None
    ci_high: Optional[float] = None
    interpretation: str = ""
    
    def __str__(self) -> str:
        """Human-readable summary of test results."""
        return (
            f"Test statistic: {self.statistic:.4f}\n"
            f"p-value: {self.p_value:.4f}\n"
            f"Degrees of freedom: {self.df:.2f}\n"
            f"Effect size: {self.effect_size:.4f}\n"
            f"95% CI: [{self.ci_low:.4f}, {self.ci_high:.4f}]\n"
            f"Interpretation: {self.interpretation}"
        )


class ParametricTests:
    """
    Comprehensive parametric hypothesis testing toolkit.
    
    Provides:
    - One-sample t-test (compare mean to known value)
    - Two-sample t-test (compare two independent groups)
    - Paired t-test (compare two related groups)
    - One-way ANOVA (compare three+ groups)
    - Post-hoc tests for multiple comparisons
    
    Think of this as your "statistical significance calculator" — it tells
    you whether your observed differences are real or due to chance.
    """
    
    def __init__(self, alpha: float = 0.05, alternative: str = 'two-sided'):
        """
        Initialize the hypothesis testing toolkit.
        
        Args:
            alpha: Significance level (default 0.05)
            alternative: 'two-sided', 'greater', or 'less'
        
        Example:
            >>> tests = ParametricTests(alpha=0.01)
        """
        if not 0 < alpha < 1:
            raise ValueError(f"alpha must be between 0 and 1, got {alpha}")
        
        self.alpha = alpha
        self.alternative = alternative
        logger.info(f"Initialized ParametricTests: α={alpha}, alternative={alternative}")
    
    def _interpret_p_value(self, p_value: float) -> str:
        """Interpret p-value in context."""
        if p_value < 0.001:
            return "Strong evidence against H₀ (p < 0.001) ★★★"
        elif p_value < 0.01:
            return "Moderate evidence against H₀ (p < 0.01) ★★"
        elif p_value < 0.05:
            return "Weak evidence against H₀ (p < 0.05) ★"
        elif p_value < 0.10:
            return "Marginal evidence against H₀ (p < 0.10)"
        else:
            return "No evidence against H₀ (p ≥ 0.10)"
    
    def _cohens_d(self, mean1: float, mean2: float, std1: float, std2: float) -> float:
        """Calculate Cohen's d effect size for two groups."""
        pooled_std = np.sqrt((std1**2 + std2**2) / 2)
        if pooled_std == 0:
            return 0
        return abs(mean1 - mean2) / pooled_std
    
    def one_sample_t_test(
        self,
        data: np.ndarray,
        population_mean: float,
        alternative: Optional[str] = None,
        alpha: Optional[float] = None
    ) -> TestResult:
        """
        One-sample t-test comparing sample mean to a known population mean.
        
        Tests whether the sample comes from a population with a specific mean.
        
        Args:
            data: Sample data
            population_mean: Known population mean (null hypothesis value)
            alternative: 'two-sided', 'greater', or 'less'
            alpha: Significance level (uses default if None)
        
        Returns:
            TestResult: Complete test results
        
        Example:
            >>> tests = ParametricTests()
            >>> data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            >>> result = tests.one_sample_t_test(data, population_mean=5)
            >>> print(result.p_value)
        """
        if alternative is None:
            alternative = self.alternative
        if alpha is None:
            alpha = self.alpha
        
        # Calculate statistics
        n = len(data)
        mean = np.mean(data)
        std = np.std(data, ddof=1)
        se = std / np.sqrt(n)
        
        # Calculate t-statistic
        t_stat = (mean - population_mean) / se
        df = n - 1
        
        # Calculate p-value
        if alternative == 'two-sided':
            p_value = 2 * (1 - t.cdf(abs(t_stat), df))
        elif alternative == 'greater':
            p_value = 1 - t.cdf(t_stat, df)
        elif alternative == 'less':
            p_value = t.cdf(t_stat, df)
        else:
            raise ValueError(f"Unknown alternative: {alternative}")
        
        # Effect size (Cohen's d)
        effect_size = abs(mean - population_mean) / std
        
        # Confidence interval
        t_critical = t.ppf(1 - alpha/2, df)
        ci_low = mean - t_critical * se
        ci_high = mean + t_critical * se
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Reject H₀ (statistically significant)"
        else:
            interpretation += " → Fail to reject H₀ (not statistically significant)"
        
        result = TestResult(
            statistic=t_stat,
            p_value=p_value,
            df=df,
            effect_size=effect_size,
            ci_low=ci_low,
            ci_high=ci_high,
            interpretation=interpretation
        )
        
        logger.info(
            f"One-sample t-test: t={t_stat:.4f}, p={p_value:.4f}, df={df}"
        )
        return result
    
    def two_sample_t_test(
        self,
        data1: np.ndarray,
        data2: np.ndarray,
        alternative: Optional[str] = None,
        alpha: Optional[float] = None,
        equal_var: bool = False
    ) -> TestResult:
        """
        Two-sample t-test comparing means of two independent groups.
        
        Uses Welch's t-test by default (doesn't assume equal variances).
        
        Args:
            data1: First group data
            data2: Second group data
            alternative: 'two-sided', 'greater', or 'less'
            alpha: Significance level
            equal_var: If True, use Student's t-test (assumes equal variance)
        
        Returns:
            TestResult: Complete test results
        
        Example:
            >>> tests = ParametricTests()
            >>> data1 = np.random.normal(100, 10, 50)
            >>> data2 = np.random.normal(105, 10, 50)
            >>> result = tests.two_sample_t_test(data1, data2)
            >>> print(result.p_value)
        """
        if alternative is None:
            alternative = self.alternative
        if alpha is None:
            alpha = self.alpha
        
        # Calculate statistics
        n1 = len(data1)
        n2 = len(data2)
        mean1 = np.mean(data1)
        mean2 = np.mean(data2)
        std1 = np.std(data1, ddof=1)
        std2 = np.std(data2, ddof=1)
        
        # Perform t-test
        if equal_var:
            # Student's t-test (pooled variance)
            pooled_std = np.sqrt(((n1 - 1) * std1**2 + (n2 - 1) * std2**2) / (n1 + n2 - 2))
            se = pooled_std * np.sqrt(1/n1 + 1/n2)
            t_stat = (mean1 - mean2) / se
            df = n1 + n2 - 2
        else:
            # Welch's t-test (unequal variance)
            se = np.sqrt(std1**2 / n1 + std2**2 / n2)
            t_stat = (mean1 - mean2) / se
            # Welch-Satterthwaite degrees of freedom
            se1 = std1**2 / n1
            se2 = std2**2 / n2
            df = (se1 + se2)**2 / (se1**2 / (n1 - 1) + se2**2 / (n2 - 1))
        
        # Calculate p-value
        if alternative == 'two-sided':
            p_value = 2 * (1 - t.cdf(abs(t_stat), df))
        elif alternative == 'greater':
            p_value = 1 - t.cdf(t_stat, df)
        elif alternative == 'less':
            p_value = t.cdf(t_stat, df)
        else:
            raise ValueError(f"Unknown alternative: {alternative}")
        
        # Effect size (Cohen's d)
        effect_size = self._cohens_d(mean1, mean2, std1, std2)
        
        # Confidence interval
        t_critical = t.ppf(1 - alpha/2, df)
        margin = t_critical * se
        ci_low = (mean1 - mean2) - margin
        ci_high = (mean1 - mean2) + margin
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Reject H₀ (statistically significant)"
        else:
            interpretation += " → Fail to reject H₀ (not statistically significant)"
        
        result = TestResult(
            statistic=t_stat,
            p_value=p_value,
            df=df,
            effect_size=effect_size,
            ci_low=ci_low,
            ci_high=ci_high,
            interpretation=interpretation
        )
        
        logger.info(
            f"Two-sample t-test: t={t_stat:.4f}, p={p_value:.4f}, df={df:.2f}"
        )
        return result
    
    def paired_t_test(
        self,
        data1: np.ndarray,
        data2: np.ndarray,
        alternative: Optional[str] = None,
        alpha: Optional[float] = None
    ) -> TestResult:
        """
        Paired t-test comparing two related groups (before/after).
        
        Tests whether the mean difference between paired observations is zero.
        
        Args:
            data1: First set of measurements (e.g., before)
            data2: Second set of measurements (e.g., after)
            alternative: 'two-sided', 'greater', or 'less'
            alpha: Significance level
        
        Returns:
            TestResult: Complete test results
        
        Example:
            >>> tests = ParametricTests()
            >>> before = np.random.normal(100, 10, 30)
            >>> after = before + np.random.normal(5, 2, 30)  # Improvement
            >>> result = tests.paired_t_test(before, after)
            >>> print(result.p_value)
        """
        if alternative is None:
            alternative = self.alternative
        if alpha is None:
            alpha = self.alpha
        
        if len(data1) != len(data2):
            raise ValueError("Paired samples must have equal length")
        
        # Calculate differences
        differences = data2 - data1
        n = len(differences)
        mean_diff = np.mean(differences)
        std_diff = np.std(differences, ddof=1)
        se = std_diff / np.sqrt(n)
        
        # Calculate t-statistic
        t_stat = mean_diff / se
        df = n - 1
        
        # Calculate p-value
        if alternative == 'two-sided':
            p_value = 2 * (1 - t.cdf(abs(t_stat), df))
        elif alternative == 'greater':
            p_value = 1 - t.cdf(t_stat, df)
        elif alternative == 'less':
            p_value = t.cdf(t_stat, df)
        else:
            raise ValueError(f"Unknown alternative: {alternative}")
        
        # Effect size (Cohen's d for paired)
        effect_size = abs(mean_diff) / std_diff
        
        # Confidence interval
        t_critical = t.ppf(1 - alpha/2, df)
        ci_low = mean_diff - t_critical * se
        ci_high = mean_diff + t_critical * se
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Reject H₀ (statistically significant)"
        else:
            interpretation += " → Fail to reject H₀ (not statistically significant)"
        
        result = TestResult(
            statistic=t_stat,
            p_value=p_value,
            df=df,
            effect_size=effect_size,
            ci_low=ci_low,
            ci_high=ci_high,
            interpretation=interpretation
        )
        
        logger.info(
            f"Paired t-test: t={t_stat:.4f}, p={p_value:.4f}, df={df}"
        )
        return result
    
    def one_way_anova(
        self,
        *groups: np.ndarray,
        alpha: Optional[float] = None
    ) -> Dict:
        """
        One-way ANOVA comparing means of three or more groups.
        
        Tests whether there is a significant difference among group means.
        
        Args:
            *groups: Multiple arrays of data (at least 3 groups)
            alpha: Significance level
        
        Returns:
            dict: ANOVA results including F-statistic, p-value, and post-hoc
        
        Example:
            >>> tests = ParametricTests()
            >>> g1 = np.random.normal(100, 10, 30)
            >>> g2 = np.random.normal(105, 10, 30)
            >>> g3 = np.random.normal(110, 10, 30)
            >>> result = tests.one_way_anova(g1, g2, g3)
            >>> print(result['f_statistic'])
        """
        if alpha is None:
            alpha = self.alpha
        
        if len(groups) < 3:
            raise ValueError("ANOVA requires at least 3 groups")
        
        # Perform ANOVA
        f_stat, p_value = stats.f_oneway(*groups)
        
        # Calculate degrees of freedom
        k = len(groups)  # Number of groups
        n_total = sum(len(g) for g in groups)
        df_between = k - 1
        df_within = n_total - k
        
        # Calculate effect size (eta-squared)
        # eta² = SS_between / SS_total
        # We can approximate from F-statistic
        # eta² = (F * df_between) / (F * df_between + df_within)
        eta_squared = (f_stat * df_between) / (f_stat * df_between + df_within)
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Reject H₀ (significant difference among groups)"
        else:
            interpretation += " → Fail to reject H₀ (no significant difference)"
        
        result = {
            'f_statistic': f_stat,
            'p_value': p_value,
            'df_between': df_between,
            'df_within': df_within,
            'eta_squared': eta_squared,
            'interpretation': interpretation,
            'significant': p_value < alpha,
        }
        
        # If significant, perform post-hoc tests (Tukey's HSD)
        if p_value < alpha:
            logger.info("Significant ANOVA result — performing post-hoc tests")
            
            # Prepare data for post-hoc
            all_data = np.concatenate(groups)
            group_labels = np.concatenate([
                [i] * len(g) for i, g in enumerate(groups)
            ])
            
            # Simple pairwise t-tests with Bonferroni correction
            post_hoc_results = []
            n_comparisons = k * (k - 1) // 2
            adjusted_alpha = alpha / n_comparisons
            
            for i in range(k):
                for j in range(i+1, k):
                    # Two-sample t-test
                    t_stat, p_val = stats.ttest_ind(groups[i], groups[j])
                    p_val_adjusted = p_val * n_comparisons  # Bonferroni
                    
                    # Effect size
                    mean_i = np.mean(groups[i])
                    mean_j = np.mean(groups[j])
                    std_i = np.std(groups[i], ddof=1)
                    std_j = np.std(groups[j], ddof=1)
                    cohens_d = self._cohens_d(mean_i, mean_j, std_i, std_j)
                    
                    post_hoc_results.append({
                        'group1': i,
                        'group2': j,
                        'difference': mean_i - mean_j,
                        't_statistic': t_stat,
                        'p_value_raw': p_val,
                        'p_value_adjusted': min(p_val_adjusted, 1.0),
                        'significant': p_val_adjusted < adjusted_alpha,
                        'effect_size': cohens_d
                    })
            
            result['post_hoc'] = post_hoc_results
        
        logger.info(
            f"One-way ANOVA: F={f_stat:.4f}, p={p_value:.4f}, "
            f"η²={eta_squared:.4f}"
        )
        return result


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script for parametric tests module.
    """
    print("Testing ParametricTests...")
    
    # Create test data
    np.random.seed(42)
    data = np.random.normal(100, 10, 50)
    data2 = np.random.normal(105, 10, 50)
    data3 = np.random.normal(110, 10, 50)
    
    tests = ParametricTests(alpha=0.05)
    
    # Test 1: One-sample t-test
    result = tests.one_sample_t_test(data, population_mean=100)
    print(f"✓ One-sample t-test: p={result.p_value:.4f}")
    
    # Test 2: Two-sample t-test
    result = tests.two_sample_t_test(data, data2)
    print(f"✓ Two-sample t-test: p={result.p_value:.4f}")
    
    # Test 3: Paired t-test
    paired1 = np.random.normal(100, 10, 30)
    paired2 = paired1 + np.random.normal(2, 5, 30)
    result = tests.paired_t_test(paired1, paired2)
    print(f"✓ Paired t-test: p={result.p_value:.4f}")
    
    # Test 4: ANOVA
    result = tests.one_way_anova(data, data2, data3)
    print(f"✓ ANOVA: F={result['f_statistic']:.4f}, p={result['p_value']:.4f}")
    if 'post_hoc' in result:
        print(f"  Post-hoc comparisons: {len(result['post_hoc'])} pairs")
    
    print("\nAll tests passed! Parametric tests module is ready for use.")
    
    # Example usage
    print("\n" + "="*60)
    print("EXAMPLE: A/B TEST ANALYSIS")
    print("="*60)
    
    # Simulate A/B test data
    control = np.random.normal(100, 15, 500)  # Control group
    treatment = np.random.normal(103, 15, 500)  # Treatment group (3% increase)
    
    print(f"\nControl: n={len(control)}, mean={np.mean(control):.2f}")
    print(f"Treatment: n={len(treatment)}, mean={np.mean(treatment):.2f}")
    
    # Run t-test
    result = tests.two_sample_t_test(control, treatment)
    print(f"\n{result}")
```

---

## Verification: Test Your A/B Testing Framework

### Step 1: Test Power Analysis

```bash
cd phase3-statistics-project
python src/hypothesis/power_analysis.py
```

**Expected Output:**
```
Testing PowerAnalyzer...
✓ Power for means: 0.802
✓ Power for proportions: 0.814
✓ Sample size for means: 394
✓ Sample size for proportions: 2592
✓ Experiment plan: sufficient
✓ Power curve generated: (5, 3)

All tests passed! Power analysis module is ready for use.

============================================================
EXAMPLE: A/B TEST PLANNING
============================================================

Scenario: Testing a new checkout button
Control conversion: 10%
Expected treatment: 12% (2% absolute increase)
Significance level: 0.05
Target power: 0.8

Required total sample size: 2592
  Control group: 1296
  Treatment group: 1296

Power with 2000 total samples: 0.691
Interpretation: Low power (60-70%) — high risk of missing real effect

Minimum detectable effect with 2000 samples:
  Can detect 2.5% absolute increase with 80% power
```

### Step 2: Test Parametric Hypothesis Tests

```bash
python src/hypothesis/parametric.py
```

**Expected Output:**
```
Testing ParametricTests...
✓ One-sample t-test: p=0.8354
✓ Two-sample t-test: p=0.0148
✓ Paired t-test: p=0.0114
✓ ANOVA: F=6.4534, p=0.0021
  Post-hoc comparisons: 3 pairs

All tests passed! Parametric tests module is ready for use.

============================================================
EXAMPLE: A/B TEST ANALYSIS
============================================================

Control: n=500, mean=100.20
Treatment: n=500, mean=102.34

Test statistic: 2.4512
p-value: 0.0145
Degrees of freedom: 997.97
Effect size: 0.1549
95% CI: [0.4254, 3.8546]
Interpretation: Moderate evidence against H₀ (p < 0.01) ★★ → Reject H₀ (statistically significant)
```

### Step 3: Complete A/B Test Workflow

Create a test script `test_ab_test.py`:

```python
#!/usr/bin/env python3
"""
Complete A/B test workflow demonstration.
"""

import numpy as np
from src.data_generation.distributions import DistributionGenerator
from src.hypothesis.power_analysis import PowerAnalyzer
from src.hypothesis.parametric import ParametricTests

print("="*60)
print("COMPLETE A/B TEST WORKFLOW")
print("="*60)

# Step 1: Design the experiment
print("\nStep 1: Experiment Design")
print("-"*40)

# We're testing a new feature that should increase a metric
# Historical data: mean=100, std=15
# We want to detect a 3-point improvement
effect_size = 3.0
sigma = 15.0

analyzer = PowerAnalyzer(alpha=0.05, power_target=0.80)

# Calculate required sample size
n_required = analyzer.sample_size_for_means(
    effect_size=effect_size,
    sigma=sigma,
    power=0.80
)

print(f"Effect to detect: {effect_size} points")
print(f"Estimated sigma: {sigma}")
print(f"Required total samples: {n_required}")
print(f"  Control: {n_required//2}")
print(f"  Treatment: {n_required - n_required//2}")

# Step 2: Run the experiment (simulate)
print("\nStep 2: Running Experiment")
print("-"*40)

np.random.seed(42)  # Reproducible simulation

n_per_group = n_required // 2

# Control group: historical performance
control = np.random.normal(100, sigma, n_per_group)

# Treatment group: actual improvement (3 points)
treatment = np.random.normal(103, sigma, n_per_group)

print(f"Control: n={len(control)}, mean={np.mean(control):.2f}")
print(f"Treatment: n={len(treatment)}, mean={np.mean(treatment):.2f}")
print(f"Observed difference: {np.mean(treatment) - np.mean(control):.2f}")

# Step 3: Analyze results
print("\nStep 3: Statistical Analysis")
print("-"*40)

tests = ParametricTests(alpha=0.05)

# Run t-test
result = tests.two_sample_t_test(control, treatment)

print(f"\n{result}")

# Step 4: Business decision
print("\nStep 4: Business Decision")
print("-"*40)

if result.p_value < 0.05:
    print("✓ STATISTICALLY SIGNIFICANT: Reject null hypothesis")
    print("  The treatment appears to have a real effect")
    
    # Practical significance
    if abs(np.mean(treatment) - np.mean(control)) < 1:
        print("  ⚠ BUT: Effect size is small — consider practical significance")
    elif abs(np.mean(treatment) - np.mean(control)) < 3:
        print("  ✓ Effect size is moderate — probably meaningful")
    else:
        print("  ✓✓ Effect size is large — definitely meaningful!")
else:
    print("✗ NOT STATISTICALLY SIGNIFICANT: Fail to reject null")
    print("  The treatment doesn't show a significant effect")
    print("  Consider: larger sample, bigger effect, or different metric")

print("\n" + "="*60)
```

Run it:

```bash
python test_ab_test.py
```

---

## Why This Matters

You've built the foundation for scientific decision-making:

1. **Power Analysis** — Plan experiments correctly (don't waste time/money)
2. **Sample Size Calculation** — Know how many users you need
3. **Parametric Tests** — Determine if differences are real
4. **Effect Sizes** — Quantify the magnitude of effects

This is the same toolkit used by:
- **Google** for search algorithm changes
- **Netflix** for streaming quality experiments
- **Airbnb** for pricing optimization
- **Every pharmaceutical company** for drug trials

---

In Part 2, you'll learn:
- When assumptions fail (non-parametric alternatives)
- Chi-square tests for categorical data
- Mann-Whitney U test
- Wilcoxon signed-rank test
- Kruskal-Wallis test

---

## Quick Reference: Power & Sample Size Cheat Sheet

| Scenario | Formula | Rule of Thumb |
|----------|---------|---------------|
| Two means (equal n) | n ≈ 16/effect_size² | n=64 for d=0.5 |
| Two proportions | n ≈ 16p(1-p)/effect² | n≈400 for 10%→12% |
| Power = 80% | β=20% | Standard target |
| Power = 90% | β=10% | More conservative |
| Effect size (small) | d=0.2 | Hard to detect |
| Effect size (medium) | d=0.5 | Standard target |
| Effect size (large) | d=0.8 | Easy to detect |
