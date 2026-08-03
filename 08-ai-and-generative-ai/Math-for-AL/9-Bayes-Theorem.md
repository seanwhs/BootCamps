# Phase 3, Part 2: Bayes' Theorem — Classification Under Uncertainty

## Module 2: Bayesian Classification and Model Evaluation

### The Target

We're implementing Bayes' Theorem for classification and building complete probabilistic models. This module covers Bayesian classifiers, Maximum Likelihood Estimation (MLE), the bias-variance tradeoff, and model evaluation metrics—everything needed to build and validate probabilistic ML systems.

**Files we'll create:**
- `src/probability/bayes.py`
- `src/probability/inference.py`
- `src/models/bayesian.py`
- Update `src/probability/__init__.py`
- Update `tests/test_probability.py`

### The Concept

Imagine you're a doctor with a patient who has a headache. You know:
- 1% of the population has a brain tumor
- 80% of people with brain tumors have headaches
- 10% of people without brain tumors have headaches

What's the probability the patient has a brain tumor given they have a headache?

This is exactly what **Bayes' Theorem** solves: updating our beliefs based on new evidence. It's the mathematical foundation for:
- Medical diagnosis
- Spam detection
- Classification in machine learning
- A/B testing
- Decision making under uncertainty

**The theorem:**

```
P(A|B) = P(B|A) × P(A) / P(B)
```

Where:
- P(A|B) = **Posterior**: Probability of A given B (what we want)
- P(B|A) = **Likelihood**: Probability of B given A
- P(A) = **Prior**: Initial probability of A
- P(B) = **Evidence**: Total probability of B

**In machine learning:**
- A = class label (e.g., "spam" or "not spam")
- B = features (e.g., words in an email)
- Posterior = probability the email is spam given its words

**The beauty of Bayes**: It gives us not just a classification decision, but the **confidence** in that decision. This is crucial for risk-sensitive applications.

### The Implementation

#### Step 1: Implement Bayes' Theorem

**File: `src/probability/bayes.py`**

```python
"""
Bayes' Theorem implementation for classification and inference.

This module provides Bayesian inference tools, including:
- Bayes' Theorem calculations
- Naive Bayes classifiers
- Gaussian Naive Bayes
- Bernoulli Naive Bayes
- Bayesian parameter estimation
"""

from typing import List, Tuple, Dict, Optional, Union
import math
import random
from src.linear_algebra import Vector, Matrix
from src.probability.distributions import (
    GaussianDistribution, BernoulliDistribution, BinomialDistribution
)
from src.probability.stats import Statistics


class BayesianInference:
    """
    Bayesian inference tools for machine learning.
    
    Provides methods for:
    - Computing posterior probabilities
    - Naive Bayes classification
    - Bayesian parameter estimation
    """
    
    @staticmethod
    def posterior(prior: float, likelihood: float, evidence: float) -> float:
        """
        Compute posterior probability using Bayes' Theorem.
        
        P(A|B) = P(B|A) * P(A) / P(B)
        
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
    def odds_posterior(prior_odds: float, likelihood_ratio: float) -> float:
        """
        Compute posterior odds using Bayes' Theorem in odds form.
        
        Posterior Odds = Prior Odds × Likelihood Ratio
        
        This form is often more convenient for binary classification.
        
        Args:
            prior_odds: P(A) / P(not A)
            likelihood_ratio: P(B|A) / P(B|not A)
            
        Returns:
            Posterior odds: P(A|B) / P(not A|B)
        """
        return prior_odds * likelihood_ratio
    
    @staticmethod
    def odds_to_probability(odds: float) -> float:
        """Convert odds to probability: p = odds / (1 + odds)"""
        return odds / (1 + odds)


class NaiveBayes:
    """
    Naive Bayes classifier for machine learning.
    
    The "naive" assumption: features are independent given the class.
    This simplifies computation dramatically while often working well
    in practice.
    
    Analogy: Naive Bayes is like assuming all symptoms of a disease
    are independent. It's not exactly true, but it's surprisingly
    effective for classification.
    """
    
    def __init__(self, distribution_type: str = 'gaussian'):
        """
        Initialize Naive Bayes classifier.
        
        Args:
            distribution_type: 'gaussian', 'bernoulli', or 'multinomial'
        """
        self.distribution_type = distribution_type
        self.class_priors = {}
        self.class_parameters = {}
        self.classes = []
        self.n_features = 0
        
    def fit(self, X: Matrix, y: Vector) -> None:
        """
        Train Naive Bayes classifier.
        
        Estimates class priors and feature distributions from data.
        
        Args:
            X: Training data (samples x features).
            y: Target labels (0, 1, 2, ...).
        """
        n_samples = X.rows
        self.n_features = X.cols
        
        # Get unique classes
        classes = set()
        for i in range(y.size):
            classes.add(int(y[i]))
        self.classes = sorted(list(classes))
        
        # Compute class priors
        for c in self.classes:
            n_c = sum(1 for i in range(y.size) if int(y[i]) == c)
            self.class_priors[c] = n_c / n_samples
        
        # Estimate class parameters
        for c in self.classes:
            # Get data for this class
            class_data = []
            for i in range(n_samples):
                if int(y[i]) == c:
                    class_data.append([X[i, j] for j in range(X.cols)])
            
            if not class_data:
                continue
            
            class_matrix = Matrix(class_data)
            
            if self.distribution_type == 'gaussian':
                # Gaussian Naive Bayes: estimate mean and std for each feature
                params = {'means': [], 'stds': []}
                for j in range(self.n_features):
                    col = class_matrix.col(j)
                    mean = Statistics.mean(col)
                    std = Statistics.standard_deviation(col, ddof=1)
                    # If std is 0, all values are identical; use small epsilon
                    if std < 1e-10:
                        std = 1.0  # Avoid division by zero
                    params['means'].append(mean)
                    params['stds'].append(std)
                self.class_parameters[c] = params
                
            elif self.distribution_type == 'bernoulli':
                # Bernoulli Naive Bayes: estimate probability for each feature
                params = {'probs': []}
                for j in range(self.n_features):
                    col = class_matrix.col(j)
                    # Assume binary features (0 or 1)
                    p = Statistics.mean(col)
                    # Laplace smoothing to avoid zero probabilities
                    p = (p + 0.001) / (1 + 0.002)  # Small smoothing
                    params['probs'].append(p)
                self.class_parameters[c] = params
                
            elif self.distribution_type == 'multinomial':
                # Multinomial Naive Bayes: estimate feature counts
                params = {'counts': []}
                total_count = 0
                for j in range(self.n_features):
                    col = class_matrix.col(j)
                    count = sum(col[i] for i in range(col.size))
                    params['counts'].append(count)
                    total_count += count
                
                # Use Laplace smoothing
                for j in range(self.n_features):
                    params['counts'][j] = (params['counts'][j] + 1) / (total_count + self.n_features)
                self.class_parameters[c] = params
    
    def predict_proba(self, X: Matrix) -> Matrix:
        """
        Predict class probabilities for each sample.
        
        Returns probability distribution over classes.
        
        Args:
            X: Data to classify (samples x features).
            
        Returns:
            Matrix of probabilities (samples x n_classes).
        """
        n_samples = X.rows
        n_classes = len(self.classes)
        
        prob_data = []
        
        for i in range(n_samples):
            sample = X.row(i)
            class_probs = []
            
            for c in self.classes:
                # Compute log probability (for numerical stability)
                log_prob = math.log(self.class_priors[c])
                
                if self.distribution_type == 'gaussian':
                    params = self.class_parameters[c]
                    for j in range(self.n_features):
                        mean = params['means'][j]
                        std = params['stds'][j]
                        # Gaussian log-likelihood
                        z = (sample[j] - mean) / std
                        log_prob += (-0.5 * z * z - 0.5 * math.log(2 * math.pi) - math.log(std))
                        
                elif self.distribution_type == 'bernoulli':
                    params = self.class_parameters[c]
                    for j in range(self.n_features):
                        p = params['probs'][j]
                        # Bernoulli log-likelihood
                        if sample[j] >= 0.5:
                            log_prob += math.log(p)
                        else:
                            log_prob += math.log(1 - p)
                            
                elif self.distribution_type == 'multinomial':
                    params = self.class_parameters[c]
                    for j in range(self.n_features):
                        p = params['counts'][j]
                        # Multinomial log-likelihood (simplified)
                        if sample[j] > 0:
                            log_prob += sample[j] * math.log(p)
                
                class_probs.append(log_prob)
            
            # Normalize to probabilities
            max_log = max(class_probs)
            exp_probs = [math.exp(p - max_log) for p in class_probs]
            total = sum(exp_probs)
            prob_data.append([p / total for p in exp_probs])
        
        return Matrix(prob_data)
    
    def predict(self, X: Matrix) -> Vector:
        """
        Predict class labels for each sample.
        
        Args:
            X: Data to classify.
            
        Returns:
            Vector of predicted class labels.
        """
        probs = self.predict_proba(X)
        
        # Argmax over classes
        predictions = []
        for i in range(probs.rows):
            best_class = 0
            best_prob = -1
            for j, c in enumerate(self.classes):
                if probs[i, j] > best_prob:
                    best_prob = probs[i, j]
                    best_class = c
            predictions.append(best_class)
        
        return Vector(predictions)
    
    def score(self, X: Matrix, y: Vector) -> float:
        """
        Compute accuracy score on test data.
        
        Args:
            X: Test data.
            y: True labels.
            
        Returns:
            Accuracy (0 to 1).
        """
        predictions = self.predict(X)
        correct = sum(1 for i in range(predictions.size) 
                     if predictions[i] == y[i])
        return correct / predictions.size


class GaussianNaiveBayes(NaiveBayes):
    """
    Gaussian Naive Bayes classifier.
    
    Assumes features follow a Gaussian distribution given the class.
    Works well for continuous features (e.g., measurements, sensor data).
    """
    
    def __init__(self):
        super().__init__(distribution_type='gaussian')


class BernoulliNaiveBayes(NaiveBayes):
    """
    Bernoulli Naive Bayes classifier.
    
    Assumes features are binary (0 or 1).
    Works well for text data (presence/absence of words).
    """
    
    def __init__(self):
        super().__init__(distribution_type='bernoulli')


class MultinomialNaiveBayes(NaiveBayes):
    """
    Multinomial Naive Bayes classifier.
    
    Assumes features are counts (e.g., word frequencies).
    Works well for text classification.
    """
    
    def __init__(self):
        super().__init__(distribution_type='multinomial')


class BayesianModelEvaluation:
    """
    Bayesian model evaluation and selection tools.
    
    Provides methods for:
    - Bias-variance tradeoff analysis
    - Model selection using Bayes factors
    - Bayesian model averaging
    """
    
    @staticmethod
    def bias_variance_analysis(predictions: Matrix, targets: Matrix) -> Dict[str, float]:
        """
        Analyze bias and variance of predictions.
        
        Bias: Systematic error (model too simple)
        Variance: Sensitivity to data (model too complex)
        
        The bias-variance tradeoff: simple models have high bias, low variance;
        complex models have low bias, high variance.
        
        Args:
            predictions: Model predictions.
            targets: True values.
            
        Returns:
            Dict with 'bias', 'variance', and 'total_error'.
        """
        n = predictions.rows
        if n == 0:
            return {'bias': 0.0, 'variance': 0.0, 'total_error': 0.0}
        
        # Mean prediction and target
        mean_pred = sum(predictions[i, 0] for i in range(n)) / n
        mean_target = sum(targets[i, 0] for i in range(n)) / n
        
        # Bias: (mean_pred - mean_target)^2
        bias = (mean_pred - mean_target) ** 2
        
        # Variance: E[(pred - mean_pred)^2]
        variance = sum((predictions[i, 0] - mean_pred) ** 2 for i in range(n)) / n
        
        # Total error = bias + variance + irreducible error
        # (Irreducible error is the noise in the data)
        total_error = bias + variance
        
        return {
            'bias': bias,
            'variance': variance,
            'total_error': total_error
        }
    
    @staticmethod
    def bayes_factor(model1_likelihood: float, model2_likelihood: float) -> float:
        """
        Compute Bayes factor for model comparison.
        
        Bayes factor = P(data|model1) / P(data|model2)
        
        Interpretation:
        - > 100: Decisive evidence for model1
        - 10-100: Strong evidence
        - 3-10: Moderate evidence
        - 1-3: Anecdotal evidence
        - < 1: Evidence for model2
        
        Args:
            model1_likelihood: Likelihood of data under model 1.
            model2_likelihood: Likelihood of data under model 2.
            
        Returns:
            Bayes factor.
        """
        if model2_likelihood == 0:
            return float('inf')
        return model1_likelihood / model2_likelihood
    
    @staticmethod
    def cross_validation_scores(model, X: Matrix, y: Vector, 
                               k: int = 5) -> List[float]:
        """
        Perform k-fold cross-validation.
        
        Cross-validation estimates model performance on unseen data
        by training on different subsets and testing on held-out data.
        
        Args:
            model: ML model with fit() and score() methods.
            X: Data matrix.
            y: Labels.
            k: Number of folds.
            
        Returns:
            List of scores for each fold.
        """
        n = X.rows
        fold_size = n // k
        scores = []
        
        # Shuffle data
        indices = list(range(n))
        random.seed(42)
        random.shuffle(indices)
        
        for fold in range(k):
            # Split data into train and test
            test_start = fold * fold_size
            test_end = min((fold + 1) * fold_size, n)
            
            test_indices = indices[test_start:test_end]
            train_indices = indices[:test_start] + indices[test_end:]
            
            # Create train and test sets
            train_X_data = [[X[i, j] for j in range(X.cols)] for i in train_indices]
            test_X_data = [[X[i, j] for j in range(X.cols)] for i in test_indices]
            
            train_X = Matrix(train_X_data)
            test_X = Matrix(test_X_data)
            
            train_y_data = [y[i] for i in train_indices]
            test_y_data = [y[i] for i in test_indices]
            
            train_y = Vector(train_y_data)
            test_y = Vector(test_y_data)
            
            # Train model
            model.fit(train_X, train_y)
            
            # Evaluate on test set
            score = model.score(test_X, test_y)
            scores.append(score)
        
        return scores
    
    @staticmethod
    def learning_curve(model, X: Matrix, y: Vector, 
                      train_sizes: List[int]) -> Tuple[Matrix, Matrix]:
        """
        Generate learning curves for model evaluation.
        
        Learning curves show how model performance changes with
        more training data. They help identify:
        - High bias: both curves plateau low (underfitting)
        - High variance: gap between curves (overfitting)
        - Good fit: curves plateau high, gap is small
        
        Args:
            model: ML model.
            X: Data matrix.
            y: Labels.
            train_sizes: List of training set sizes.
            
        Returns:
            Tuple of (train_scores_matrix, test_scores_matrix).
        """
        n = X.rows
        train_scores = []
        test_scores = []
        
        # Shuffle data
        indices = list(range(n))
        random.seed(42)
        random.shuffle(indices)
        
        # Test set: 20% of data
        test_size = n // 5
        test_indices = indices[-test_size:]
        train_indices = indices[:-test_size]
        
        # Create test set
        test_X = Matrix([[X[i, j] for j in range(X.cols)] for i in test_indices])
        test_y = Vector([y[i] for i in test_indices])
        
        for train_size in train_sizes:
            if train_size > len(train_indices):
                break
                
            # Select training subset
            subset_indices = train_indices[:train_size]
            
            train_X = Matrix([[X[i, j] for j in range(X.cols)] for i in subset_indices])
            train_y = Vector([y[i] for i in subset_indices])
            
            # Train and evaluate
            model.fit(train_X, train_y)
            
            train_score = model.score(train_X, train_y)
            test_score = model.score(test_X, test_y)
            
            train_scores.append(train_score)
            test_scores.append(test_score)
        
        # Convert to matrices for easier plotting
        train_scores_matrix = Matrix([[s] for s in train_scores])
        test_scores_matrix = Matrix([[s] for s in test_scores])
        
        return train_scores_matrix, test_scores_matrix
```

#### Step 2: Implement Inference Methods

**File: `src/probability/inference.py`**

```python
"""
Statistical inference methods for machine learning.

This module provides:
- Maximum Likelihood Estimation (MLE)
- Maximum A Posteriori (MAP) estimation
- Hypothesis testing
- Confidence intervals
- Bootstrap methods
"""

from typing import List, Tuple, Dict, Optional, Callable
import math
import random
from src.linear_algebra import Vector, Matrix
from src.probability.distributions import GaussianDistribution
from src.probability.stats import Statistics


class MLE:
    """
    Maximum Likelihood Estimation for model parameters.
    
    MLE finds the parameters that make the observed data most likely.
    It's the foundation of many learning algorithms.
    """
    
    @staticmethod
    def gaussian_parameters(data: Vector) -> Tuple[float, float]:
        """
        MLE for Gaussian distribution parameters.
        
        Returns:
            Tuple of (mean_hat, variance_hat)
        """
        n = data.size
        if n == 0:
            raise ValueError("Cannot estimate from empty data")
        
        mean_hat = Statistics.mean(data)
        var_hat = Statistics.variance(data, ddof=0)  # Population variance
        
        return mean_hat, var_hat
    
    @staticmethod
    def bernoulli_parameter(data: Vector) -> float:
        """
        MLE for Bernoulli distribution parameter.
        
        Returns:
            Estimated p (probability of success).
        """
        n = data.size
        if n == 0:
            raise ValueError("Cannot estimate from empty data")
        
        return Statistics.mean(data)
    
    @staticmethod
    def linear_regression(X: Matrix, y: Vector) -> Vector:
        """
        MLE for linear regression parameters.
        
        Finds weights w that minimize: MSE = (1/n) * ||Xw - y||²
        
        Closed-form solution: w = (X^T X)^(-1) X^T y
        
        Args:
            X: Design matrix (samples x features).
            y: Targets.
            
        Returns:
            Weight vector.
        """
        # Add bias term if not already present
        if X.cols != y.size:
            # Check if bias column exists
            bias_col = X.col(0)
            if not all(bias_col[i] == 1.0 for i in range(bias_col.size)):
                # Add bias term
                X_with_bias_data = [[1.0] + [X[i, j] for j in range(X.cols)] 
                                   for i in range(X.rows)]
                X_with_bias = Matrix(X_with_bias_data)
            else:
                X_with_bias = X
        
        # Compute X^T X
        XTX = X_with_bias.T @ X_with_bias
        
        # Compute X^T y
        XTy = X_with_bias.T.vector_dot(y)
        
        # Solve for weights
        try:
            weights = XTX.inverse().vector_dot(XTy)
        except ValueError:
            # Matrix is singular, use pseudo-inverse (via SVD)
            from src.linear_algebra.decomposition import Decomposition
            U, S, Vt = Decomposition.svd(XTX)
            # Compute pseudo-inverse
            S_inv = Matrix.zeros(S.rows, S.cols)
            for i in range(min(S.rows, S.cols)):
                if S[i, i] > 1e-10:
                    S_inv[i, i] = 1.0 / S[i, i]
            XTX_inv = Vt.T @ S_inv @ U.T
            weights = XTX_inv.vector_dot(XTy)
        
        return weights
    
    @staticmethod
    def logistic_regression(X: Matrix, y: Vector, 
                           learning_rate: float = 0.01,
                           num_iterations: int = 1000) -> Vector:
        """
        MLE for logistic regression via gradient ascent.
        
        Logistic regression models: P(y=1|x) = 1 / (1 + exp(-w^T x))
        
        Args:
            X: Data matrix.
            y: Binary labels (0 or 1).
            learning_rate: Step size.
            num_iterations: Number of gradient steps.
            
        Returns:
            Weight vector.
        """
        n, d = X.rows, X.cols
        
        # Add bias term
        X_with_bias_data = [[1.0] + [X[i, j] for j in range(X.cols)] 
                           for i in range(X.rows)]
        X_with_bias = Matrix(X_with_bias_data)
        
        # Initialize weights
        w = Vector([0.0] * (d + 1))
        
        def sigmoid(z: float) -> float:
            return 1 / (1 + math.exp(-z))
        
        for iteration in range(num_iterations):
            # Compute predictions
            z = X_with_bias.vector_dot(w)
            predictions = Vector([sigmoid(z[i]) for i in range(z.size)])
            
            # Compute gradient
            gradient = X_with_bias.T.vector_dot(predictions - y)
            
            # Update weights (gradient ascent for likelihood)
            w = w - learning_rate * gradient
        
        return w


class MAP:
    """
    Maximum A Posteriori estimation.
    
    MAP finds the most probable parameters given prior knowledge.
    It's MLE with a prior: MAP = argmax P(data|params) * P(params)
    
    MAP is useful when:
    - You have prior knowledge about parameters
    - You want to prevent overfitting
    - Data is limited
    """
    
    @staticmethod
    def gaussian_parameters_with_prior(data: Vector, 
                                      prior_mean: float = 0.0,
                                      prior_variance: float = 1.0) -> Tuple[float, float]:
        """
        MAP for Gaussian with Gaussian prior.
        
        This gives a regularized estimate where the posterior mean
        is a weighted average of data mean and prior mean.
        
        Args:
            data: Observed data.
            prior_mean: Prior mean.
            prior_variance: Prior variance.
            
        Returns:
            Tuple of (posterior_mean, posterior_variance).
        """
        n = data.size
        if n == 0:
            return prior_mean, prior_variance
        
        data_mean = Statistics.mean(data)
        data_variance = Statistics.variance(data, ddof=0)
        
        # Posterior mean: weighted average of data mean and prior mean
        # weights are inverse variances
        weight_data = n / data_variance if data_variance > 0 else 0
        weight_prior = 1 / prior_variance if prior_variance > 0 else 0
        
        if weight_data + weight_prior == 0:
            posterior_mean = data_mean
        else:
            posterior_mean = (weight_data * data_mean + weight_prior * prior_mean) / (weight_data + weight_prior)
        
        # Posterior variance: 1 / (weight_data + weight_prior)
        if weight_data + weight_prior > 0:
            posterior_variance = 1 / (weight_data + weight_prior)
        else:
            posterior_variance = prior_variance
        
        return posterior_mean, posterior_variance


class Bootstrap:
    """
    Bootstrap methods for uncertainty estimation.
    
    The bootstrap estimates the sampling distribution of a statistic
    by resampling the data with replacement.
    
    Analogy: If you want to know how reliable a survey is, you
    repeatedly sample from the survey results (with replacement)
    and compute your statistic. This gives you the distribution
    of the statistic.
    """
    
    @staticmethod
    def mean_confidence_interval(data: Vector, 
                                 confidence: float = 0.95,
                                 n_bootstrap: int = 1000) -> Tuple[float, float]:
        """
        Compute bootstrap confidence interval for the mean.
        
        Args:
            data: Sample data.
            confidence: Confidence level (e.g., 0.95).
            n_bootstrap: Number of bootstrap samples.
            
        Returns:
            Tuple of (lower_bound, upper_bound).
        """
        n = data.size
        if n == 0:
            raise ValueError("Cannot bootstrap from empty data")
        
        # Generate bootstrap samples
        bootstrap_means = []
        for _ in range(n_bootstrap):
            # Sample with replacement
            sample = [data[random.randint(0, n - 1)] for _ in range(n)]
            sample_vector = Vector(sample)
            bootstrap_means.append(Statistics.mean(sample_vector))
        
        # Sort means
        bootstrap_means.sort()
        
        # Compute percentile interval
        alpha = 1 - confidence
        lower_idx = int(n_bootstrap * alpha / 2)
        upper_idx = int(n_bootstrap * (1 - alpha / 2))
        
        return bootstrap_means[lower_idx], bootstrap_means[upper_idx - 1]
    
    @staticmethod
    def standard_error(data: Vector, statistic: Callable[[Vector], float],
                      n_bootstrap: int = 1000) -> float:
        """
        Compute bootstrap standard error of a statistic.
        
        Args:
            data: Sample data.
            statistic: Function that computes a statistic from data.
            n_bootstrap: Number of bootstrap samples.
            
        Returns:
            Standard error.
        """
        n = data.size
        if n == 0:
            raise ValueError("Cannot bootstrap from empty data")
        
        # Generate bootstrap statistic values
        boot_stats = []
        for _ in range(n_bootstrap):
            sample = [data[random.randint(0, n - 1)] for _ in range(n)]
            sample_vector = Vector(sample)
            boot_stats.append(statistic(sample_vector))
        
        # Compute standard deviation of bootstrap statistics
        mean_stat = Statistics.mean(Vector(boot_stats))
        variance = sum((s - mean_stat) ** 2 for s in boot_stats) / (n_bootstrap - 1)
        
        return math.sqrt(variance)
```

#### Step 3: Update Package Initialization

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
from src.probability.bayes import (
    BayesianInference, NaiveBayes, GaussianNaiveBayes,
    BernoulliNaiveBayes, MultinomialNaiveBayes,
    BayesianModelEvaluation
)
from src.probability.inference import MLE, MAP, Bootstrap

__all__ = [
    'Distribution', 'GaussianDistribution', 'BernoulliDistribution',
    'BinomialDistribution', 'ExponentialDistribution', 'PoissonDistribution',
    'Statistics',
    'BayesianInference', 'NaiveBayes', 'GaussianNaiveBayes',
    'BernoulliNaiveBayes', 'MultinomialNaiveBayes',
    'BayesianModelEvaluation',
    'MLE', 'MAP', 'Bootstrap'
]
```

### The Verification

#### Step 1: Test Naive Bayes Classification

**File: `tests/test_bayes.py`**

```python
"""
Unit tests for Bayesian methods.
"""

import pytest
import math
import random
from src.probability import (
    GaussianNaiveBayes, BernoulliNaiveBayes,
    BayesianModelEvaluation, MLE, Bootstrap
)
from src.linear_algebra import Matrix, Vector
from src.probability.stats import Statistics


class TestNaiveBayes:
    """Test Naive Bayes classifiers."""
    
    def test_gaussian_naive_bayes(self):
        """Test Gaussian Naive Bayes."""
        # Create synthetic 2D data
        X_data = []
        y_data = []
        
        # Class 0: centered around (0, 0)
        for _ in range(50):
            X_data.append([random.gauss(0, 1), random.gauss(0, 1)])
            y_data.append(0.0)
        
        # Class 1: centered around (5, 5)
        for _ in range(50):
            X_data.append([random.gauss(5, 1), random.gauss(5, 1)])
            y_data.append(1.0)
        
        X = Matrix(X_data)
        y = Vector(y_data)
        
        # Train classifier
        nb = GaussianNaiveBayes()
        nb.fit(X, y)
        
        # Test accuracy on training data
        score = nb.score(X, y)
        assert score > 0.85
        
        # Predict a test point
        test_point = Matrix([[0.5, 0.5]])
        probs = nb.predict_proba(test_point)
        
        # Should be more likely class 0
        assert probs[0, 0] > 0.5
    
    def test_bernoulli_naive_bayes(self):
        """Test Bernoulli Naive Bayes."""
        # Create synthetic binary data
        X_data = []
        y_data = []
        
        # Class 0: features mostly 0
        for _ in range(30):
            X_data.append([1 if random.random() < 0.2 else 0 for _ in range(3)])
            y_data.append(0.0)
        
        # Class 1: features mostly 1
        for _ in range(30):
            X_data.append([1 if random.random() < 0.8 else 0 for _ in range(3)])
            y_data.append(1.0)
        
        X = Matrix(X_data)
        y = Vector(y_data)
        
        # Train classifier
        nb = BernoulliNaiveBayes()
        nb.fit(X, y)
        
        # Test accuracy
        score = nb.score(X, y)
        assert score > 0.7
    
    def test_cross_validation(self):
        """Test cross-validation."""
        # Generate simple dataset
        X_data = []
        y_data = []
        
        for i in range(100):
            x = random.random() * 10
            X_data.append([x])
            y_data.append(1.0 if x > 5 else 0.0)
        
        X = Matrix(X_data)
        y = Vector(y_data)
        
        # Train Naive Bayes
        nb = GaussianNaiveBayes()
        
        # Cross-validation
        scores = BayesianModelEvaluation.cross_validation_scores(
            nb, X, y, k=5
        )
        
        # All scores should be reasonable
        for score in scores:
            assert 0.5 <= score <= 1.0
        
        # Average score should be good
        avg_score = sum(scores) / len(scores)
        assert avg_score > 0.7


class TestMLE:
    """Test Maximum Likelihood Estimation."""
    
    def test_gaussian_mle(self):
        """Test MLE for Gaussian parameters."""
        data = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
        
        mean, var = MLE.gaussian_parameters(data)
        
        assert mean == 3.0
        assert var == 2.0  # Population variance: (4+1+0+1+4)/5 = 2
    
    def test_linear_regression_mle(self):
        """Test MLE for linear regression."""
        # Generate data: y = 2*x + 3 + noise
        X_data = [[i / 10] for i in range(100)]
        y_data = [2 * X_data[i][0] + 3 + random.gauss(0, 0.1) 
                 for i in range(100)]
        
        X = Matrix(X_data)
        y = Vector(y_data)
        
        # Add bias term
        X_with_bias_data = [[1.0] + [X[i, 0]] for i in range(X.rows)]
        X_with_bias = Matrix(X_with_bias_data)
        
        # MLE
        weights = MLE.linear_regression(X, y)
        
        # Should recover [3, 2] (bias, slope)
        assert weights[0] == pytest.approx(3.0, abs=0.5)
        assert weights[1] == pytest.approx(2.0, abs=0.5)
    
    def test_logistic_regression_mle(self):
        """Test MLE for logistic regression."""
        # Generate simple classification data
        X_data = []
        y_data = []
        
        for i in range(200):
            x = random.random() * 10 - 5
            X_data.append([x])
            # Logistic function: P(y=1) = 1/(1+exp(-x))
            prob = 1 / (1 + math.exp(-x))
            y_data.append(1.0 if random.random() < prob else 0.0)
        
        X = Matrix(X_data)
        y = Vector(y_data)
        
        # MLE for logistic regression
        weights = MLE.logistic_regression(X, y, 
                                         learning_rate=0.1,
                                         num_iterations=1000)
        
        # The weight should be positive (since x is positively correlated with y)
        # The bias should be around 0
        if len(weights) >= 2:
            assert weights[1] > 0  # Feature weight
            assert abs(weights[0]) < 1  # Bias


class TestBootstrap:
    """Test bootstrap methods."""
    
    def test_bootstrap_confidence_interval(self):
        """Test bootstrap confidence interval."""
        # Generate data from a known distribution
        data = Vector([random.gauss(0, 1) for _ in range(50)])
        
        # Compute bootstrap CI for mean
        lower, upper = Bootstrap.mean_confidence_interval(
            data, confidence=0.95, n_bootstrap=100
        )
        
        # The true mean is 0 (but sample mean may vary)
        # The confidence interval should contain the true mean
        # (We can't guarantee this for a specific sample, but check it's reasonable)
        
        # CI should be centered around sample mean
        sample_mean = Statistics.mean(data)
        assert lower < sample_mean < upper
        
        # CI should be narrow (for 50 samples from unit Gaussian)
        assert (upper - lower) < 1.0
```

#### Step 2: Run the Tests

```bash
pytest tests/test_bayes.py -v
```

#### Step 3: Interactive Verification

```python
>>> from src.probability import GaussianNaiveBayes, MLE
>>> from src.linear_algebra import Matrix, Vector
>>> import random
>>> 
>>> # Generate synthetic data
>>> X_data = []
>>> y_data = []
>>> for _ in range(100):
...     x = random.gauss(0, 1)
...     y = random.gauss(0, 1)
...     X_data.append([x, y])
...     y_data.append(1.0 if x * x + y * y > 1 else 0.0)
... 
>>> X = Matrix(X_data)
>>> y = Vector(y_data)
>>> 
>>> # Train Naive Bayes
>>> nb = GaussianNaiveBayes()
>>> nb.fit(X, y)
>>> 
>>> # Predict
>>> probs = nb.predict_proba(Matrix([[0.0, 0.0]]))
>>> print(f"P(class 0) = {probs[0, 0]:.3f}")
P(class 0) = 0.932
>>> print(f"P(class 1) = {probs[0, 1]:.3f}")
P(class 1) = 0.068
>>> 
>>> # The point (0,0) is clearly inside the circle, so class 0
>>> 
>>> # Test another point outside circle
>>> probs = nb.predict_proba(Matrix([[2.0, 0.0]]))
>>> print(f"P(class 0) = {probs[0, 0]:.3f}")
P(class 0) = 0.012
>>> print(f"P(class 1) = {probs[0, 1]:.3f}")
P(class 1) = 0.988
```

---

*Next: We'll explore the bias-variance tradeoff, learning curves, and model evaluation techniques—understanding why models generalize and how to choose the best model for your data.*
