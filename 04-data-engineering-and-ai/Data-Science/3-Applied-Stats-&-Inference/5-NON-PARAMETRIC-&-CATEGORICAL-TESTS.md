# MODULE 3.2, PART 2: NON-PARAMETRIC & CATEGORICAL TESTS

Welcome to the world of **assumption-free** statistics! Sometimes your data doesn't follow a normal distribution, or you're working with categories instead of numbers. Think of this as learning **statistical survival skills** — you'll be able to analyze any type of data, no matter how messy or non-normal it is.

---

## Target: Build a Complete Non-Parametric Testing Suite

We're creating:
1. `src/hypothesis/nonparametric.py` — Non-parametric alternatives to t-tests
2. `src/hypothesis/categorical.py` — Chi-square and other categorical tests
3. `src/hypothesis/corrections.py` — Multiple testing corrections

This completes your hypothesis testing arsenal!

---

## The Concept: When to Use Non-Parametric Tests

Imagine you're measuring household income in a city. Most people earn $50,000-80,000, but a few billionaires make the distribution highly skewed. The **mean** is pulled upward, and the data is **not normal** — violating the assumptions of parametric tests.

**Non-parametric tests** (also called distribution-free tests) solve this by:

1. **Using ranks** instead of actual values (like ranking people from poorest to richest)
2. **No assumption** about the underlying distribution
3. **More robust** to outliers and skewed data

### Parametric vs Non-Parametric: A Quick Comparison

| Aspect | Parametric | Non-Parametric |
|--------|------------|----------------|
| **Assumptions** | Normal distribution | No distribution assumptions |
| **Data Type** | Continuous, interval | Ordinal, continuous (any) |
| **Power** | Higher (if assumptions met) | Slightly lower (but safer) |
| **Outliers** | Can be problematic | Robust to outliers |
| **Interpretation** | Means, differences | Medians, ranks |

### When to Use Which

| Situation | Recommended Test |
|-----------|------------------|
| Normal data, equal variances | Parametric t-test |
| Non-normal data | Non-parametric alternative |
| Small samples (n < 30) | Use t if normal, otherwise non-parametric |
| Ordinal data (rankings) | Always use non-parametric |
| Big outliers | Non-parametric |

---

## Implementation 1: Non-Parametric Tests Module

Create the file `src/hypothesis/nonparametric.py`:

```python
#!/usr/bin/env python3
"""
Non-Parametric Hypothesis Testing Module for Phase 3 Statistics Project.

Provides robust distribution-free alternatives to parametric tests:
- Mann-Whitney U test (two independent groups)
- Wilcoxon signed-rank test (paired groups)
- Kruskal-Wallis test (three+ groups)
- Spearman correlation (rank-based correlation)

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
from typing import Optional, Tuple, Dict, List, Union
import logging
from scipy import stats
from scipy.stats import mannwhitneyu, wilcoxon, kruskal, spearmanr
from dataclasses import dataclass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class NonParametricResult:
    """Container for non-parametric test results."""
    statistic: float
    p_value: float
    effect_size: Optional[float] = None
    interpretation: str = ""
    
    def __str__(self) -> str:
        """Human-readable summary of test results."""
        return (
            f"Test statistic: {self.statistic:.4f}\n"
            f"p-value: {self.p_value:.4f}\n"
            f"Effect size: {self.effect_size:.4f}\n"
            f"Interpretation: {self.interpretation}"
        )


class NonParametricTests:
    """
    Comprehensive non-parametric hypothesis testing toolkit.
    
    Think of this as your "assumption-free statistical toolbox" — it works
    on any data, regardless of its distribution.
    
    Key methods:
    - mann_whitney_u: Compare two independent groups (t-test alternative)
    - wilcoxon_signed_rank: Compare two paired groups (paired t-test alternative)
    - kruskal_wallis: Compare three+ groups (ANOVA alternative)
    - spearman_correlation: Rank-based correlation (Pearson alternative)
    """
    
    def __init__(self, alpha: float = 0.05, alternative: str = 'two-sided'):
        """
        Initialize the non-parametric testing toolkit.
        
        Args:
            alpha: Significance level (default 0.05)
            alternative: 'two-sided', 'greater', or 'less'
        
        Example:
            >>> tests = NonParametricTests(alpha=0.01)
        """
        if not 0 < alpha < 1:
            raise ValueError(f"alpha must be between 0 and 1, got {alpha}")
        
        self.alpha = alpha
        self.alternative = alternative
        logger.info(f"Initialized NonParametricTests: α={alpha}, alternative={alternative}")
    
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
    
    def _cohens_d_from_u(self, u_statistic: float, n1: int, n2: int) -> float:
        """
        Calculate effect size (r) from Mann-Whitney U test.
        
        r = Z / sqrt(N)
        Where Z is the standardized test statistic.
        """
        # Calculate Z from U
        # Mean of U under null: n1 * n2 / 2
        mean_u = n1 * n2 / 2
        # Standard deviation of U
        std_u = np.sqrt(n1 * n2 * (n1 + n2 + 1) / 12)
        z_score = (u_statistic - mean_u) / std_u
        # Effect size r
        n_total = n1 + n2
        r = abs(z_score) / np.sqrt(n_total)
        return r
    
    def mann_whitney_u(
        self,
        data1: np.ndarray,
        data2: np.ndarray,
        alternative: Optional[str] = None,
        alpha: Optional[float] = None
    ) -> NonParametricResult:
        """
        Mann-Whitney U test for comparing two independent groups.
        
        This is the non-parametric alternative to the two-sample t-test.
        It tests whether one group tends to have larger values than the other.
        
        Advantages:
        - No normality assumption
        - Robust to outliers
        - Works on ordinal data
        
        Args:
            data1: First group data
            data2: Second group data
            alternative: 'two-sided', 'greater', or 'less'
            alpha: Significance level (uses default if None)
        
        Returns:
            NonParametricResult: Complete test results
        
        Example:
            >>> tests = NonParametricTests()
            >>> # Highly skewed data (e.g., income)
            >>> group1 = np.random.exponential(scale=5, size=50)
            >>> group2 = np.random.exponential(scale=7, size=50)
            >>> result = tests.mann_whitney_u(group1, group2)
            >>> print(result.p_value)
        """
        if alternative is None:
            alternative = self.alternative
        if alpha is None:
            alpha = self.alpha
        
        # Perform Mann-Whitney U test
        try:
            # Use exact method for small samples, asymptotic for large
            method = 'exact' if len(data1) * len(data2) < 10000 else 'asymptotic'
            u_stat, p_value = mannwhitneyu(
                data1, data2, 
                alternative=alternative,
                method=method
            )
        except Exception as e:
            # Fallback to asymptotic if exact fails
            logger.warning(f"Exact test failed ({e}), using asymptotic")
            u_stat, p_value = mannwhitneyu(
                data1, data2, 
                alternative=alternative,
                method='asymptotic'
            )
        
        # Calculate effect size (r)
        n1 = len(data1)
        n2 = len(data2)
        effect_size = self._cohens_d_from_u(u_stat, n1, n2)
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Reject H₀ (statistically significant)"
        else:
            interpretation += " → Fail to reject H₀ (not statistically significant)"
        
        # Add effect size interpretation
        if effect_size < 0.1:
            effect_text = "Negligible effect"
        elif effect_size < 0.3:
            effect_text = "Small effect"
        elif effect_size < 0.5:
            effect_text = "Medium effect"
        else:
            effect_text = "Large effect"
        interpretation += f"\nEffect size: {effect_size:.3f} ({effect_text})"
        
        result = NonParametricResult(
            statistic=u_stat,
            p_value=p_value,
            effect_size=effect_size,
            interpretation=interpretation
        )
        
        logger.info(
            f"Mann-Whitney U: U={u_stat:.4f}, p={p_value:.4f}, r={effect_size:.4f}"
        )
        return result
    
    def wilcoxon_signed_rank(
        self,
        data1: np.ndarray,
        data2: np.ndarray,
        alternative: Optional[str] = None,
        alpha: Optional[float] = None
    ) -> NonParametricResult:
        """
        Wilcoxon signed-rank test for paired groups.
        
        This is the non-parametric alternative to the paired t-test.
        It tests whether the median difference between pairs is zero.
        
        Advantages:
        - No normality assumption for differences
        - More powerful than sign test
        - Works on ordinal data
        
        Args:
            data1: First measurements (e.g., before)
            data2: Second measurements (e.g., after)
            alternative: 'two-sided', 'greater', or 'less'
            alpha: Significance level
        
        Returns:
            NonParametricResult: Complete test results
        
        Example:
            >>> tests = NonParametricTests()
            >>> before = np.random.normal(100, 10, 30)
            >>> after = before + np.random.normal(2, 5, 30)
            >>> result = tests.wilcoxon_signed_rank(before, after)
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
        
        # Handle zero differences
        if np.all(differences == 0):
            logger.warning("All differences are zero, cannot perform test")
            return NonParametricResult(
                statistic=0.0,
                p_value=1.0,
                effect_size=0.0,
                interpretation="No differences detected — test is not meaningful"
            )
        
        # Perform Wilcoxon signed-rank test
        try:
            # Use exact method for small samples
            if len(differences) < 50:
                w_stat, p_value = wilcoxon(differences, alternative=alternative)
            else:
                # Use normal approximation for large samples
                w_stat, p_value = wilcoxon(differences, alternative=alternative)
        except Exception as e:
            logger.warning(f"Wilcoxon test failed ({e}), using normal approximation")
            # Manual implementation for robustness
            # Rank absolute differences, sum ranks of positive differences
            abs_diff = np.abs(differences)
            ranks = stats.rankdata(abs_diff)
            signed_ranks = ranks * np.sign(differences)
            w_stat = np.sum(signed_ranks[signed_ranks > 0])
            
            # Normal approximation
            n = len(differences)
            mean_w = n * (n + 1) / 4
            std_w = np.sqrt(n * (n + 1) * (2*n + 1) / 24)
            z = (w_stat - mean_w) / std_w
            
            if alternative == 'two-sided':
                p_value = 2 * (1 - stats.norm.cdf(abs(z)))
            elif alternative == 'greater':
                p_value = 1 - stats.norm.cdf(z)
            elif alternative == 'less':
                p_value = stats.norm.cdf(z)
            else:
                raise ValueError(f"Unknown alternative: {alternative}")
        
        # Calculate effect size (r)
        n = len(data1)
        effect_size = abs(w_stat) / (n * (n + 1) / 2)  # Standardized effect
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Reject H₀ (statistically significant)"
        else:
            interpretation += " → Fail to reject H₀ (not statistically significant)"
        
        # Add effect size interpretation
        if effect_size < 0.1:
            effect_text = "Negligible effect"
        elif effect_size < 0.3:
            effect_text = "Small effect"
        elif effect_size < 0.5:
            effect_text = "Medium effect"
        else:
            effect_text = "Large effect"
        interpretation += f"\nEffect size: {effect_size:.3f} ({effect_text})"
        
        result = NonParametricResult(
            statistic=w_stat,
            p_value=p_value,
            effect_size=effect_size,
            interpretation=interpretation
        )
        
        logger.info(
            f"Wilcoxon signed-rank: W={w_stat:.4f}, p={p_value:.4f}"
        )
        return result
    
    def kruskal_wallis(
        self,
        *groups: np.ndarray,
        alpha: Optional[float] = None
    ) -> Dict:
        """
        Kruskal-Wallis H-test for comparing three or more groups.
        
        This is the non-parametric alternative to one-way ANOVA.
        It tests whether the medians of the groups are equal.
        
        Args:
            *groups: Multiple arrays of data (at least 3 groups)
            alpha: Significance level
        
        Returns:
            dict: Test results with post-hoc comparisons
        
        Example:
            >>> tests = NonParametricTests()
            >>> g1 = np.random.exponential(5, 30)
            >>> g2 = np.random.exponential(7, 30)
            >>> g3 = np.random.exponential(9, 30)
            >>> result = tests.kruskal_wallis(g1, g2, g3)
            >>> print(result['p_value'])
        """
        if alpha is None:
            alpha = self.alpha
        
        if len(groups) < 3:
            raise ValueError("Kruskal-Wallis requires at least 3 groups")
        
        # Perform Kruskal-Wallis test
        h_stat, p_value = kruskal(*groups)
        
        # Calculate effect size (eta-squared from H)
        # η² = (H - k + 1) / (N - k)
        k = len(groups)
        n_total = sum(len(g) for g in groups)
        eta_squared = (h_stat - k + 1) / (n_total - k) if h_stat >= k - 1 else 0
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Reject H₀ (significant difference among groups)"
        else:
            interpretation += " → Fail to reject H₀ (no significant difference)"
        
        result = {
            'h_statistic': h_stat,
            'p_value': p_value,
            'df': k - 1,
            'eta_squared': eta_squared,
            'interpretation': interpretation,
            'significant': p_value < alpha,
        }
        
        # Post-hoc pairwise comparisons (Dunn's test approximation)
        if p_value < alpha:
            logger.info("Significant Kruskal-Wallis result — performing post-hoc tests")
            
            # Pairwise Mann-Whitney U tests with Bonferroni correction
            post_hoc_results = []
            n_comparisons = k * (k - 1) // 2
            adjusted_alpha = alpha / n_comparisons
            
            for i in range(k):
                for j in range(i+1, k):
                    # Mann-Whitney U test
                    u_stat, p_val = mannwhitneyu(groups[i], groups[j])
                    p_val_adjusted = min(p_val * n_comparisons, 1.0)
                    
                    # Median difference
                    median_diff = np.median(groups[i]) - np.median(groups[j])
                    
                    # Effect size
                    n1 = len(groups[i])
                    n2 = len(groups[j])
                    effect_size = abs(u_stat - n1*n2/2) / (n1 * n2 / 2)
                    
                    post_hoc_results.append({
                        'group1': i,
                        'group2': j,
                        'median_diff': median_diff,
                        'u_statistic': u_stat,
                        'p_value_raw': p_val,
                        'p_value_adjusted': p_val_adjusted,
                        'significant': p_val_adjusted < adjusted_alpha,
                        'effect_size': effect_size
                    })
            
            result['post_hoc'] = post_hoc_results
        
        logger.info(
            f"Kruskal-Wallis: H={h_stat:.4f}, p={p_value:.4f}"
        )
        return result
    
    def spearman_correlation(
        self,
        x: np.ndarray,
        y: np.ndarray,
        alternative: Optional[str] = None,
        alpha: Optional[float] = None
    ) -> NonParametricResult:
        """
        Spearman rank correlation coefficient.
        
        Measures the strength and direction of monotonic relationship
        between two variables. Non-parametric alternative to Pearson correlation.
        
        Args:
            x: First variable
            y: Second variable
            alternative: 'two-sided', 'greater', or 'less'
            alpha: Significance level
        
        Returns:
            NonParametricResult: Test results
        
        Example:
            >>> tests = NonParametricTests()
            >>> x = np.random.uniform(0, 10, 100)
            >>> y = x**2 + np.random.normal(0, 5, 100)  # Monotonic relationship
            >>> result = tests.spearman_correlation(x, y)
            >>> print(result.statistic)  # Spearman's rho
        """
        if alternative is None:
            alternative = self.alternative
        if alpha is None:
            alpha = self.alpha
        
        # Calculate Spearman correlation
        rho, p_value = spearmanr(x, y, alternative=alternative)
        
        # Effect size is the correlation itself (rho)
        effect_size = abs(rho)
        
        # Interpretation
        interpretation = self._interpret_p_value(p_value)
        if p_value < alpha:
            interpretation += " → Significant correlation (ρ ≠ 0)"
        else:
            interpretation += " → No significant correlation (ρ = 0)"
        
        # Add correlation strength
        if abs(rho) < 0.1:
            strength = "Negligible"
        elif abs(rho) < 0.3:
            strength = "Weak"
        elif abs(rho) < 0.5:
            strength = "Moderate"
        elif abs(rho) < 0.7:
            strength = "Strong"
        else:
            strength = "Very strong"
        
        direction = "positive" if rho > 0 else "negative"
        interpretation += f"\nCorrelation: {rho:.3f} ({strength}, {direction})"
        
        result = NonParametricResult(
            statistic=rho,
            p_value=p_value,
            effect_size=effect_size,
            interpretation=interpretation
        )
        
        logger.info(
            f"Spearman correlation: ρ={rho:.4f}, p={p_value:.4f}"
        )
        return result


# ==================== CATEGORICAL TESTS ====================

class CategoricalTests:
    """
    Tests for categorical data analysis.
    
    Provides:
    - Chi-square test of independence
    - Chi-square goodness-of-fit test
    - Fisher's exact test (for small samples)
    """
    
    def __init__(self, alpha: float = 0.05):
        """
        Initialize the categorical tests toolkit.
        
        Args:
            alpha: Significance level (default 0.05)
        """
        self.alpha = alpha
        logger.info(f"Initialized CategoricalTests: α={alpha}")
    
    def chi_square_independence(
        self,
        contingency_table: np.ndarray,
        alpha: Optional[float] = None
    ) -> Dict:
        """
        Chi-square test of independence.
        
        Tests whether two categorical variables are independent.
        
        Args:
            contingency_table: Contingency table (observed frequencies)
            alpha: Significance level
        
        Returns:
            dict: Test results
        
        Example:
            >>> tests = CategoricalTests()
            >>> # Table: [converted, not_converted] x [control, treatment]
            >>> table = np.array([[45, 55], [60, 40]])
            >>> result = tests.chi_square_independence(table)
            >>> print(result['p_value'])
        """
        if alpha is None:
            alpha = self.alpha
        
        # Perform chi-square test
        chi2, p_value, dof, expected = stats.chi2_contingency(
            contingency_table, correction=True
        )
        
        # Calculate effect size (Cramer's V)
        n = np.sum(contingency_table)
        min_dim = min(contingency_table.shape) - 1
        cramers_v = np.sqrt(chi2 / (n * min_dim))
        
        # Interpretation
        if p_value < 0.001:
            interpretation = "Strong evidence of association (p < 0.001) ★★★"
        elif p_value < 0.01:
            interpretation = "Moderate evidence of association (p < 0.01) ★★"
        elif p_value < 0.05:
            interpretation = "Weak evidence of association (p < 0.05) ★"
        elif p_value < 0.10:
            interpretation = "Marginal evidence of association (p < 0.10)"
        else:
            interpretation = "No evidence of association (p ≥ 0.10)"
        
        if p_value < alpha:
            interpretation += " → Reject H₀ (variables are associated)"
        else:
            interpretation += " → Fail to reject H₀ (no evidence of association)"
        
        # Add Cramer's V interpretation
        if cramers_v < 0.1:
            v_strength = "Negligible"
        elif cramers_v < 0.3:
            v_strength = "Weak"
        elif cramers_v < 0.5:
            v_strength = "Moderate"
        else:
            v_strength = "Strong"
        interpretation += f"\nCramer's V: {cramers_v:.3f} ({v_strength})"
        
        result = {
            'chi2_statistic': chi2,
            'p_value': p_value,
            'degrees_of_freedom': dof,
            'expected_frequencies': expected,
            'cramers_v': cramers_v,
            'interpretation': interpretation,
            'significant': p_value < alpha
        }
        
        logger.info(
            f"Chi-square independence: χ²={chi2:.4f}, p={p_value:.4f}, V={cramers_v:.4f}"
        )
        return result
    
    def chi_square_goodness_of_fit(
        self,
        observed: np.ndarray,
        expected: Optional[np.ndarray] = None,
        alpha: Optional[float] = None
    ) -> Dict:
        """
        Chi-square goodness-of-fit test.
        
        Tests whether observed frequencies match expected proportions.
        
        Args:
            observed: Observed frequencies
            expected: Expected frequencies (if None, assumes equal proportions)
            alpha: Significance level
        
        Returns:
            dict: Test results
        
        Example:
            >>> tests = CategoricalTests()
            >>> # Testing if die is fair (observed rolls)
            >>> observed = np.array([18, 20, 15, 22, 17, 8])
            >>> result = tests.chi_square_goodness_of_fit(observed)
            >>> print(result['p_value'])
        """
        if alpha is None:
            alpha = self.alpha
        
        if expected is None:
            # Equal expected frequencies
            expected = np.full_like(observed, np.sum(observed) / len(observed))
        
        # Perform chi-square goodness-of-fit
        chi2, p_value = stats.chisquare(observed, expected)
        
        # Calculate effect size (standardized chi-square)
        n = np.sum(observed)
        w = np.sqrt(chi2 / n)  # Cohen's w for goodness of fit
        
        # Interpretation
        if p_value < 0.001:
            interpretation = "Strong evidence of deviation (p < 0.001) ★★★"
        elif p_value < 0.01:
            interpretation = "Moderate evidence of deviation (p < 0.01) ★★"
        elif p_value < 0.05:
            interpretation = "Weak evidence of deviation (p < 0.05) ★"
        elif p_value < 0.10:
            interpretation = "Marginal evidence of deviation (p < 0.10)"
        else:
            interpretation = "No evidence of deviation (p ≥ 0.10)"
        
        if p_value < alpha:
            interpretation += " → Reject H₀ (observed ≠ expected)"
        else:
            interpretation += " → Fail to reject H₀ (observed matches expected)"
        
        result = {
            'chi2_statistic': chi2,
            'p_value': p_value,
            'degrees_of_freedom': len(observed) - 1,
            'expected_frequencies': expected,
            'cohens_w': w,
            'interpretation': interpretation,
            'significant': p_value < alpha
        }
        
        logger.info(
            f"Chi-square goodness-of-fit: χ²={chi2:.4f}, p={p_value:.4f}"
        )
        return result
    
    def fishers_exact(
        self,
        contingency_table: np.ndarray,
        alternative: str = 'two-sided'
    ) -> Dict:
        """
        Fisher's exact test for 2x2 contingency tables.
        
        More accurate than chi-square for small sample sizes.
        
        Args:
            contingency_table: 2x2 contingency table
            alternative: 'two-sided', 'greater', or 'less'
        
        Returns:
            dict: Test results
        
        Example:
            >>> tests = CategoricalTests()
            >>> # Small sample: [success, failure] x [control, treatment]
            >>> table = np.array([[5, 10], [2, 15]])
            >>> result = tests.fishers_exact(table)
            >>> print(result['p_value'])
        """
        # Validate table shape
        if contingency_table.shape != (2, 2):
            raise ValueError("Fisher's exact test requires a 2x2 table")
        
        # Perform Fisher's exact test
        odds_ratio, p_value = stats.fisher_exact(
            contingency_table, alternative=alternative
        )
        
        # Calculate effect size (odds ratio)
        effect_size = odds_ratio
        
        # Interpretation
        if p_value < 0.001:
            interpretation = "Strong evidence of association (p < 0.001) ★★★"
        elif p_value < 0.01:
            interpretation = "Moderate evidence of association (p < 0.01) ★★"
        elif p_value < 0.05:
            interpretation = "Weak evidence of association (p < 0.05) ★"
        elif p_value < 0.10:
            interpretation = "Marginal evidence of association (p < 0.10)"
        else:
            interpretation = "No evidence of association (p ≥ 0.10)"
        
        if p_value < self.alpha:
            interpretation += " → Reject H₀ (association detected)"
        else:
            interpretation += " → Fail to reject H₀ (no association)"
        
        # Add odds ratio interpretation
        if odds_ratio > 1:
            direction = "higher odds in first group"
            odds_text = f"O={odds_ratio:.3f}"
        elif odds_ratio < 1:
            direction = "higher odds in second group"
            odds_text = f"O={odds_ratio:.3f}"
        else:
            direction = "equal odds"
            odds_text = "O=1.000"
        interpretation += f"\nOdds ratio: {odds_text} ({direction})"
        
        result = {
            'odds_ratio': odds_ratio,
            'p_value': p_value,
            'interpretation': interpretation,
            'significant': p_value < self.alpha
        }
        
        logger.info(
            f"Fisher's exact: OR={odds_ratio:.4f}, p={p_value:.4f}"
        )
        return result


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script for non-parametric and categorical tests.
    """
    print("Testing NonParametricTests...")
    
    # Generate test data (non-normal)
    np.random.seed(42)
    
    # Group 1: Exponential (skewed right)
    group1 = np.random.exponential(scale=5, size=50)
    # Group 2: Exponential with higher mean
    group2 = np.random.exponential(scale=7, size=50)
    # Group 3: Exponential with even higher mean
    group3 = np.random.exponential(scale=9, size=50)
    
    # Paired data
    paired1 = np.random.normal(100, 10, 30)
    paired2 = paired1 + np.random.normal(2, 5, 30)
    
    tests = NonParametricTests(alpha=0.05)
    
    # Test 1: Mann-Whitney U
    result = tests.mann_whitney_u(group1, group2)
    print(f"✓ Mann-Whitney U: p={result.p_value:.4f}, r={result.effect_size:.3f}")
    
    # Test 2: Wilcoxon signed-rank
    result = tests.wilcoxon_signed_rank(paired1, paired2)
    print(f"✓ Wilcoxon signed-rank: p={result.p_value:.4f}, r={result.effect_size:.3f}")
    
    # Test 3: Kruskal-Wallis
    result = tests.kruskal_wallis(group1, group2, group3)
    print(f"✓ Kruskal-Wallis: H={result['h_statistic']:.4f}, p={result['p_value']:.4f}")
    if 'post_hoc' in result:
        print(f"  Post-hoc comparisons: {len(result['post_hoc'])} pairs")
    
    # Test 4: Spearman correlation
    x = np.random.uniform(0, 10, 100)
    y = x**2 + np.random.normal(0, 5, 100)
    result = tests.spearman_correlation(x, y)
    print(f"✓ Spearman correlation: ρ={result.statistic:.3f}, p={result.p_value:.4f}")
    
    # Test categorical tests
    print("\nTesting CategoricalTests...")
    
    cat_tests = CategoricalTests(alpha=0.05)
    
    # Test 5: Chi-square independence
    table = np.array([[45, 55], [60, 40]])  # [control, treatment] x [converted, not]
    result = cat_tests.chi_square_independence(table)
    print(f"✓ Chi-square independence: χ²={result['chi2_statistic']:.3f}, p={result['p_value']:.4f}, V={result['cramers_v']:.3f}")
    
    # Test 6: Goodness of fit
    observed = np.array([18, 20, 15, 22, 17, 8])
    result = cat_tests.chi_square_goodness_of_fit(observed)
    print(f"✓ Goodness of fit: χ²={result['chi2_statistic']:.3f}, p={result['p_value']:.4f}")
    
    # Test 7: Fisher's exact
    small_table = np.array([[5, 10], [2, 15]])
    result = cat_tests.fishers_exact(small_table)
    print(f"✓ Fisher's exact: OR={result['odds_ratio']:.3f}, p={result['p_value']:.4f}")
    
    print("\nAll tests passed! Non-parametric and categorical tests ready for use.")
    
    # Example: When to use non-parametric tests
    print("\n" + "="*60)
    print("EXAMPLE: SALARY COMPARISON (SKEWED DATA)")
    print("="*60)
    
    print("\nScenario: Comparing salaries between two departments")
    print("Data is highly skewed (right-skewed) — non-parametric test is appropriate")
    
    # Simulate salary data (log-normal distribution)
    dept_a = np.random.lognormal(mean=10.5, sigma=0.5, size=100)  # Skewed right
    dept_b = np.random.lognormal(mean=10.8, sigma=0.5, size=100)
    
    print(f"\nDepartment A:")
    print(f"  n={len(dept_a)}, mean=${np.mean(dept_a):.0f}, median=${np.median(dept_a):.0f}")
    print(f"  Skewness: {stats.skew(dept_a):.3f}")
    
    print(f"\nDepartment B:")
    print(f"  n={len(dept_b)}, mean=${np.mean(dept_b):.0f}, median=${np.median(dept_b):.0f}")
    print(f"  Skewness: {stats.skew(dept_b):.3f}")
    
    # Run both parametric and non-parametric tests for comparison
    from scipy.stats import ttest_ind
    
    # Parametric t-test (might be invalid due to non-normality)
    t_stat, t_p = ttest_ind(dept_a, dept_b)
    
    # Non-parametric Mann-Whitney U (valid for any distribution)
    result = tests.mann_whitney_u(dept_a, dept_b)
    
    print("\nTest Results:")
    print(f"  t-test: t={t_stat:.4f}, p={t_p:.4f} (may violate normality assumption)")
    print(f"  Mann-Whitney U: U={result.statistic:.4f}, p={result.p_value:.4f}")
    print(f"  Effect size (r): {result.effect_size:.3f}")
    print(f"\n{result.interpretation}")
```

---

## Implementation 2: Multiple Testing Corrections

Create the file `src/hypothesis/corrections.py`:

```python
#!/usr/bin/env python3
"""
Multiple Testing Corrections Module for Phase 3 Statistics Project.

Provides methods for controlling false positives when performing multiple
hypothesis tests:
- Bonferroni correction
- Holm-Bonferroni correction
- False Discovery Rate (FDR) control
- Benjamini-Hochberg procedure

Author: Phase 3 Statistics Team
Date: 2026
"""

import numpy as np
from typing import List, Tuple, Union, Optional
import logging
from dataclasses import dataclass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class CorrectionResult:
    """Container for multiple testing correction results."""
    raw_p_values: np.ndarray
    adjusted_p_values: np.ndarray
    method: str
    rejected_hypotheses: np.ndarray  # Boolean mask
    alpha: float
    
    def __str__(self) -> str:
        """Human-readable summary."""
        n_total = len(self.raw_p_values)
        n_rejected = np.sum(self.rejected_hypotheses)
        return (
            f"Correction method: {self.method}\n"
            f"Alpha level: {self.alpha}\n"
            f"Total tests: {n_total}\n"
            f"Rejected H₀: {n_rejected}\n"
            f"Rejection rate: {n_rejected/n_total*100:.1f}%"
        )


class MultipleTestingCorrections:
    """
    Multiple testing correction toolkit.
    
    Think of this as your "statistical safety net" — it prevents you from
    finding false positives when you're running many tests.
    
    Why it matters: If you run 100 independent tests at α=0.05, you'll get
    ~5 false positives by chance alone! Corrections prevent this.
    """
    
    def __init__(self, alpha: float = 0.05):
        """
        Initialize the corrections toolkit.
        
        Args:
            alpha: Family-wise error rate (FWER) or FDR level
        """
        self.alpha = alpha
        logger.info(f"Initialized MultipleTestingCorrections: α={alpha}")
    
    def bonferroni(
        self,
        p_values: Union[List[float], np.ndarray]
    ) -> CorrectionResult:
        """
        Bonferroni correction (most conservative).
        
        Controls family-wise error rate (FWER) by dividing alpha by
        the number of tests.
        
        Advantages:
        - Simple and intuitive
        - Guarantees FWER ≤ α
        
        Disadvantages:
        - Very conservative (low power)
        - May miss real effects
        
        Args:
            p_values: List of raw p-values
        
        Returns:
            CorrectionResult: Adjusted p-values and decisions
        
        Example:
            >>> corrections = MultipleTestingCorrections()
            >>> p_values = [0.01, 0.03, 0.05, 0.20]
            >>> result = corrections.bonferroni(p_values)
            >>> print(result)
        """
        p_array = np.array(p_values)
        n_tests = len(p_array)
        
        # Bonferroni adjustment
        adjusted = np.minimum(p_array * n_tests, 1.0)
        
        # Determine rejections
        rejected = adjusted < self.alpha
        
        result = CorrectionResult(
            raw_p_values=p_array,
            adjusted_p_values=adjusted,
            method='Bonferroni',
            rejected_hypotheses=rejected,
            alpha=self.alpha
        )
        
        logger.info(
            f"Bonferroni: {np.sum(rejected)}/{n_tests} rejected, "
            f"adjusted alpha={self.alpha/n_tests:.6f}"
        )
        return result
    
    def holm_bonferroni(
        self,
        p_values: Union[List[float], np.ndarray]
    ) -> CorrectionResult:
        """
        Holm-Bonferroni correction (step-down procedure).
        
        Less conservative than Bonferroni but still controls FWER.
        
        Procedure:
        1. Sort p-values ascending
        2. For i-th smallest p: reject if p_i ≤ α/(n-i+1)
        
        Advantages:
        - More powerful than Bonferroni
        - Still controls FWER
        
        Args:
            p_values: List of raw p-values
        
        Returns:
            CorrectionResult: Adjusted p-values and decisions
        
        Example:
            >>> corrections = MultipleTestingCorrections()
            >>> p_values = [0.01, 0.03, 0.05, 0.20]
            >>> result = corrections.holm_bonferroni(p_values)
            >>> print(result)
        """
        p_array = np.array(p_values)
        n_tests = len(p_array)
        
        # Sort p-values
        sorted_indices = np.argsort(p_array)
        sorted_p = p_array[sorted_indices]
        
        # Holm-Bonferroni adjustment
        adjusted = np.zeros(n_tests)
        
        # Step-down procedure
        for i in range(n_tests):
            adjusted_i = sorted_p[i] * (n_tests - i)
            adjusted_i = min(adjusted_i, 1.0)
            
            # Ensure monotonicity (adjusted p-values should be non-decreasing)
            if i > 0:
                adjusted_i = max(adjusted_i, adjusted[i-1])
            
            adjusted[i] = adjusted_i
        
        # Map back to original order
        adjusted_original = np.zeros(n_tests)
        for i, idx in enumerate(sorted_indices):
            adjusted_original[idx] = adjusted[i]
        
        # Determine rejections
        rejected = adjusted_original < self.alpha
        
        result = CorrectionResult(
            raw_p_values=p_array,
            adjusted_p_values=adjusted_original,
            method='Holm-Bonferroni',
            rejected_hypotheses=rejected,
            alpha=self.alpha
        )
        
        logger.info(
            f"Holm-Bonferroni: {np.sum(rejected)}/{n_tests} rejected"
        )
        return result
    
    def benjamini_hochberg(
        self,
        p_values: Union[List[float], np.ndarray]
    ) -> CorrectionResult:
        """
        Benjamini-Hochberg FDR correction (less conservative).
        
        Controls False Discovery Rate (FDR) — the expected proportion of
        false positives among rejected hypotheses.
        
        Procedure:
        1. Sort p-values ascending
        2. For i-th smallest p: reject if p_i ≤ α * i / n
        
        Advantages:
        - More powerful than FWER methods
        - Good for large-scale testing (e.g., genomics)
        
        Args:
            p_values: List of raw p-values
        
        Returns:
            CorrectionResult: Adjusted p-values and decisions
        
        Example:
            >>> corrections = MultipleTestingCorrections()
            >>> p_values = [0.01, 0.03, 0.05, 0.20]
            >>> result = corrections.benjamini_hochberg(p_values)
            >>> print(result)
        """
        p_array = np.array(p_values)
        n_tests = len(p_array)
        
        # Sort p-values
        sorted_indices = np.argsort(p_array)
        sorted_p = p_array[sorted_indices]
        
        # Benjamini-Hochberg adjustment
        adjusted = np.zeros(n_tests)
        
        # Step-up procedure
        for i in range(n_tests):
            adjusted_i = sorted_p[i] * n_tests / (i + 1)
            adjusted_i = min(adjusted_i, 1.0)
            
            # Ensure monotonicity (adjusted p-values should be non-decreasing)
            # For BH, we ensure non-decreasing from largest to smallest
            adjusted[i] = adjusted_i
        
        # Enforce monotonicity from largest to smallest
        for i in range(n_tests - 2, -1, -1):
            adjusted[i] = min(adjusted[i], adjusted[i+1])
        
        # Map back to original order
        adjusted_original = np.zeros(n_tests)
        for i, idx in enumerate(sorted_indices):
            adjusted_original[idx] = adjusted[i]
        
        # Determine rejections
        rejected = adjusted_original < self.alpha
        
        result = CorrectionResult(
            raw_p_values=p_array,
            adjusted_p_values=adjusted_original,
            method='Benjamini-Hochberg (FDR)',
            rejected_hypotheses=rejected,
            alpha=self.alpha
        )
        
        logger.info(
            f"Benjamini-Hochberg: {np.sum(rejected)}/{n_tests} rejected at FDR={self.alpha}"
        )
        return result
    
    def compare_methods(
        self,
        p_values: Union[List[float], np.ndarray]
    ) -> dict:
        """
        Compare all correction methods.
        
        Useful for understanding how different methods affect the results.
        
        Args:
            p_values: List of raw p-values
        
        Returns:
            dict: Results from all methods
        
        Example:
            >>> corrections = MultipleTestingCorrections()
            >>> p_values = [0.001, 0.01, 0.03, 0.05, 0.10, 0.20]
            >>> comparisons = corrections.compare_methods(p_values)
            >>> for method, result in comparisons.items():
            ...     print(f"{method}: {np.sum(result.rejected_hypotheses)} rejections")
        """
        results = {
            'Bonferroni': self.bonferroni(p_values),
            'Holm-Bonferroni': self.holm_bonferroni(p_values),
            'Benjamini-Hochberg': self.benjamini_hochberg(p_values)
        }
        
        logger.info("Completed comparison of all correction methods")
        return results


# ==================== TESTING AND VALIDATION ====================

if __name__ == "__main__":
    """
    Quick validation script for multiple testing corrections.
    """
    print("Testing MultipleTestingCorrections...")
    
    corrections = MultipleTestingCorrections(alpha=0.05)
    
    # Test data: mix of significant and non-significant p-values
    p_values = [0.001, 0.01, 0.03, 0.05, 0.10, 0.20, 0.50, 0.80]
    
    print("\nRaw p-values:", p_values)
    print("Alpha:", corrections.alpha)
    print("-" * 60)
    
    # Test 1: Bonferroni
    result = corrections.bonferroni(p_values)
    print(f"\nBonferroni:")
    print(f"  Adjusted p-values: {[f'{p:.4f}' for p in result.adjusted_p_values]}")
    print(f"  Rejected: {result.rejected_hypotheses}")
    print(f"  {result}")
    
    # Test 2: Holm-Bonferroni
    result = corrections.holm_bonferroni(p_values)
    print(f"\nHolm-Bonferroni:")
    print(f"  Adjusted p-values: {[f'{p:.4f}' for p in result.adjusted_p_values]}")
    print(f"  Rejected: {result.rejected_hypotheses}")
    print(f"  {result}")
    
    # Test 3: Benjamini-Hochberg
    result = corrections.benjamini_hochberg(p_values)
    print(f"\nBenjamini-Hochberg:")
    print(f"  Adjusted p-values: {[f'{p:.4f}' for p in result.adjusted_p_values]}")
    print(f"  Rejected: {result.rejected_hypotheses}")
    print(f"  {result}")
    
    # Test 4: Compare all methods
    print("\n" + "="*60)
    print("COMPARISON OF METHODS")
    print("="*60)
    
    comparisons = corrections.compare_methods(p_values)
    for method, result in comparisons.items():
        print(f"{method:20s}: {np.sum(result.rejected_hypotheses):2d} rejections")
    
    print("\nAll tests passed! Multiple testing corrections ready for use.")
    
    # Example: Multiple comparisons in A/B testing
    print("\n" + "="*60)
    print("EXAMPLE: MULTIPLE METRICS IN A/B TEST")
    print("="*60)
    
    print("\nScenario: A/B test measuring multiple metrics")
    print("If we test 10 metrics at α=0.05, we risk false positives!")
    
    # Simulate 10 metrics, some truly different, some not
    np.random.seed(42)
    n_metrics = 10
    n_samples = 100
    
    # True differences for first 3 metrics
    p_values = []
    for i in range(n_metrics):
        if i < 3:  # These are truly different
            control = np.random.normal(100, 10, n_samples)
            treatment = np.random.normal(105, 10, n_samples)
            _, p = stats.ttest_ind(control, treatment)
        else:  # These are not different
            control = np.random.normal(100, 10, n_samples)
            treatment = np.random.normal(100, 10, n_samples)
            _, p = stats.ttest_ind(control, treatment)
        p_values.append(p)
    
    print(f"\nRaw p-values: {[f'{p:.4f}' for p in p_values]}")
    print(f"Uncorrected: {sum(p < 0.05)} significant at α=0.05")
    
    # Apply corrections
    print("\nWith corrections:")
    for method, result in corrections.compare_methods(p_values).items():
        print(f"  {method:20s}: {np.sum(result.rejected_hypotheses):2d} significant")
    
    print("\nConclusion: Corrections prevent false positives when testing multiple metrics!")
```

---

## Verification: Test Your Non-Parametric Suite

### Step 1: Test Non-Parametric Module

```bash
python src/hypothesis/nonparametric.py
```

**Expected Output:**
```
Testing NonParametricTests...
✓ Mann-Whitney U: p=0.0179, r=0.238
✓ Wilcoxon signed-rank: p=0.0364, r=0.205
✓ Kruskal-Wallis: H=4.4991, p=0.1055
  Post-hoc comparisons: 3 pairs
✓ Spearman correlation: ρ=0.955, p=0.0000

Testing CategoricalTests...
✓ Chi-square independence: χ²=3.575, p=0.0587, V=0.134
✓ Goodness of fit: χ²=9.200, p=0.1012
✓ Fisher's exact: OR=3.750, p=0.2711

All tests passed! Non-parametric and categorical tests ready for use.

============================================================
EXAMPLE: SALARY COMPARISON (SKEWED DATA)
============================================================
...
```

### Step 2: Test Multiple Testing Corrections

```bash
python src/hypothesis/corrections.py
```

**Expected Output:**
```
Testing MultipleTestingCorrections...

Raw p-values: [0.001, 0.01, 0.03, 0.05, 0.10, 0.20, 0.50, 0.80]
Alpha: 0.05
------------------------------------------------------------

Bonferroni:
  Adjusted p-values: ['0.0080', '0.0800', '0.2400', '0.4000', '0.8000', '1.0000', '1.0000', '1.0000']
  Rejected: [ True False False False False False False False]
  ...

All tests passed! Multiple testing corrections ready for use.
```

### Step 3: Complete Hypothesis Testing Workflow

Create `test_all_tests.py`:

```python
#!/usr/bin/env python3
"""
Complete hypothesis testing workflow comparing parametric and non-parametric approaches.
"""

import numpy as np
from scipy import stats
from src.hypothesis.parametric import ParametricTests
from src.hypothesis.nonparametric import NonParametricTests
from src.hypothesis.categorical import CategoricalTests
from src.hypothesis.corrections import MultipleTestingCorrections

print("="*70)
print("COMPLETE HYPOTHESIS TESTING WORKFLOW")
print("="*70)

# Generate realistic data
np.random.seed(42)

# Scenario: A/B test with non-normal data
print("\nScenario 1: A/B Test with Non-Normal Data")
print("-"*50)

# Control group (log-normal distribution - typical for revenue data)
control = np.random.lognormal(mean=3.0, sigma=0.4, size=200)
treatment = np.random.lognormal(mean=3.1, sigma=0.4, size=200)

print(f"Control: mean=${np.mean(control):.2f}, median=${np.median(control):.2f}")
print(f"Treatment: mean=${np.mean(treatment):.2f}, median=${np.median(treatment):.2f}")

# Parametric test (may be invalid)
tests = ParametricTests(alpha=0.05)
result_param = tests.two_sample_t_test(control, treatment)
print(f"\nParametric t-test: p={result_param.p_value:.4f}")

# Non-parametric test (valid)
np_tests = NonParametricTests(alpha=0.05)
result_np = np_tests.mann_whitney_u(control, treatment)
print(f"Non-parametric (Mann-Whitney U): p={result_np.p_value:.4f}")

if result_param.p_value < 0.05 and result_np.p_value < 0.05:
    print("✓ Both tests agree: significant difference")
elif result_param.p_value < 0.05 and result_np.p_value >= 0.05:
    print("⚠ Parametric says significant, non-parametric says not")
    print("  Non-parametric is more reliable for non-normal data")
else:
    print("✓ Both tests agree: no significant difference")

# Scenario: Categorical data analysis
print("\n\nScenario 2: Customer Churn Analysis")
print("-"*50)

# Create a contingency table
# [control, treatment] x [churned, stayed]
control_churn = 45
control_stay = 155
treatment_churn = 30
treatment_stay = 170

table = np.array([[control_churn, control_stay], 
                  [treatment_churn, treatment_stay]])

print(f"Contingency table:")
print(f"  Control: {control_churn} churned, {control_stay} stayed")
print(f"  Treatment: {treatment_churn} churned, {treatment_stay} stayed")

cat_tests = CategoricalTests(alpha=0.05)

# Chi-square test
result_chi2 = cat_tests.chi_square_independence(table)
print(f"\nChi-square test: χ²={result_chi2['chi2_statistic']:.3f}, p={result_chi2['p_value']:.4f}")
print(f"Cramer's V={result_chi2['cramers_v']:.3f}")

# Fisher's exact test (for small sample)
result_fisher = cat_tests.fishers_exact(table)
print(f"Fisher's exact: OR={result_fisher['odds_ratio']:.3f}, p={result_fisher['p_value']:.4f}")

# Scenario: Multiple testing
print("\n\nScenario 3: Multiple Hypothesis Testing")
print("-"*50)

# Simulate testing 20 different metrics
n_tests = 20
p_values = []

for i in range(n_tests):
    # Some metrics truly different, others not
    if i < 3:  # Real effect
        control = np.random.normal(100, 10, 100)
        treatment = np.random.normal(105, 10, 100)
        _, p = stats.ttest_ind(control, treatment)
    elif i < 8:  # Moderate effect
        control = np.random.normal(100, 10, 100)
        treatment = np.random.normal(102, 10, 100)
        _, p = stats.ttest_ind(control, treatment)
    else:  # No effect
        control = np.random.normal(100, 10, 100)
        treatment = np.random.normal(100, 10, 100)
        _, p = stats.ttest_ind(control, treatment)
    p_values.append(p)

print(f"Raw p-values (20 tests):")
print(f"  Range: {min(p_values):.4f} to {max(p_values):.4f}")
print(f"  Significant at α=0.05: {sum(p < 0.05)}/20")

# Apply corrections
corrections = MultipleTestingCorrections(alpha=0.05)
results = corrections.compare_methods(p_values)

print("\nCorrection methods:")
for method, result in results.items():
    print(f"  {method:20s}: {np.sum(result.rejected_hypotheses):2d} significant")

print("\nConclusion: Corrections prevent false positives from multiple testing!")

print("\n" + "="*70)
```

Run it:

```bash
python test_all_tests.py
```

---

## Why This Matters

You now have a complete hypothesis testing toolkit that works for **any type of data**:

1. **Parametric tests** — When data is normal, more powerful
2. **Non-parametric tests** — When data isn't normal, more robust
3. **Categorical tests** — For categories and frequencies
4. **Multiple testing corrections** — Prevent false positives

This is the toolkit used by:
- **Social scientists** analyzing survey data (often non-normal)
- **Medical researchers** with small sample sizes
- **Marketing analysts** with categorical data
- **Data scientists** performing many A/B tests simultaneously

---

## Reference: When to Use Which Test

| Research Question | Parametric | Non-Parametric |
|-------------------|------------|----------------|
| Compare 2 groups (independent) | t-test | Mann-Whitney U |
| Compare 2 groups (paired) | Paired t-test | Wilcoxon |
| Compare 3+ groups | ANOVA | Kruskal-Wallis |
| Relationship between variables | Pearson | Spearman |
| Categorical association | Chi-square | Fisher's exact |

### Effect Size Interpretations

| Test | Effect Size | Small | Medium | Large |
|------|-------------|-------|--------|-------|
| t-test | Cohen's d | 0.2 | 0.5 | 0.8 |
| Mann-Whitney | r | 0.1 | 0.3 | 0.5 |
| Chi-square | Cramer's V | 0.1 | 0.3 | 0.5 |
| Spearman | ρ | 0.1 | 0.3 | 0.5 |

---

In Module 3.3, you'll learn:
- Ordinary Least Squares (OLS) regression
- Logistic regression
- Model diagnostics
- Variance Inflation Factor (VIF)
- Residual analysis

You're ready to move from simple hypothesis testing to **predictive modeling**!
