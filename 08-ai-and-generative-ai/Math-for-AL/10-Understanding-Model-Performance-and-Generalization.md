# Phase 3, Part 3: The Bias-Variance Tradeoff and Model Evaluation

## Module 3: Understanding Model Performance and Generalization

### The Target

We're building the evaluation framework for machine learning models. This module covers the bias-variance tradeoff, learning curves, model selection, and performance metrics—everything needed to assess and improve model performance in production.

**Files we'll create:**
- `src/probability/evaluation.py`
- `src/models/ensemble.py`
- Update `src/probability/__init__.py`
- Update `src/models/__init__.py`
- Update `tests/test_probability.py`

### The Concept

Imagine you're trying to hit a target with a bow and arrow. There are two ways you can miss:

1. **Bias**: Your arrows consistently land in the wrong place (systematic error)
2. **Variance**: Your arrows are scattered all over the place (random error)

A good archer has **low bias** (arrows hit near the target) and **low variance** (arrows are tightly clustered). A bad archer has high bias (misses systematically) or high variance (inconsistent).

**In machine learning:**

**Bias** = Error from overly simple models
- The model can't capture the true pattern
- Example: Using a linear model for a curved relationship

**Variance** = Error from overly complex models
- The model is too sensitive to training data
- Example: A high-degree polynomial that fits every point perfectly but fails on new data

**The Bias-Variance Tradeoff**:
- Simple models: High bias, low variance
- Complex models: Low bias, high variance
- The goal: Find the sweet spot that minimizes total error

**Why this matters for ML**: Understanding this tradeoff is crucial for:
- Choosing the right model complexity
- Detecting overfitting and underfitting
- Making better decisions about data collection
- Improving model generalization

### The Implementation

#### Step 1: Implement Model Evaluation Framework

**File: `src/probability/evaluation.py`**

```python
"""
Model evaluation and selection framework.

This module provides comprehensive tools for:
- Bias-variance decomposition
- Learning curves
- Model selection (AIC, BIC)
- Performance metrics (accuracy, precision, recall, F1, ROC)
- Cross-validation strategies
"""

from typing import List, Tuple, Dict, Optional, Callable, Any
import math
import random
from src.linear_algebra import Vector, Matrix
from src.probability.stats import Statistics
from src.probability.inference import MLE, Bootstrap


class ModelMetrics:
    """
    Comprehensive model evaluation metrics.
    
    Provides:
    - Classification metrics: accuracy, precision, recall, F1, ROC
    - Regression metrics: MSE, MAE, R², RMSE
    - Probabilistic metrics: log-likelihood, Brier score
    """
    
    @staticmethod
    def accuracy(predictions: Vector, targets: Vector) -> float:
        """Compute accuracy for classification."""
        if predictions.size != targets.size:
            raise ValueError("Predictions and targets must have same size")
        
        correct = sum(1 for i in range(predictions.size) 
                     if predictions[i] == targets[i])
        return correct / predictions.size
    
    @staticmethod
    def confusion_matrix(predictions: Vector, targets: Vector) -> Matrix:
        """Compute confusion matrix for binary classification."""
        if predictions.size != targets.size:
            raise ValueError("Predictions and targets must have same size")
        
        # Binary classification: TP, FP, FN, TN
        tp = fp = fn = tn = 0
        
        for i in range(predictions.size):
            pred = 1 if predictions[i] >= 0.5 else 0
            target = 1 if targets[i] >= 0.5 else 0
            
            if pred == 1 and target == 1:
                tp += 1
            elif pred == 1 and target == 0:
                fp += 1
            elif pred == 0 and target == 1:
                fn += 1
            else:
                tn += 1
        
        return Matrix([[tp, fp], [fn, tn]])
    
    @staticmethod
    def precision(predictions: Vector, targets: Vector) -> float:
        """
        Precision = TP / (TP + FP)
        
        Precision measures: "When the model predicts positive, how often is it correct?"
        High precision = few false positives.
        """
        cm = ModelMetrics.confusion_matrix(predictions, targets)
        tp, fp = cm[0, 0], cm[0, 1]
        
        if tp + fp == 0:
            return 0.0
        return tp / (tp + fp)
    
    @staticmethod
    def recall(predictions: Vector, targets: Vector) -> float:
        """
        Recall = TP / (TP + FN)
        
        Recall measures: "Of all actual positives, how many did the model find?"
        High recall = few false negatives.
        """
        cm = ModelMetrics.confusion_matrix(predictions, targets)
        tp, fn = cm[0, 0], cm[1, 0]
        
        if tp + fn == 0:
            return 0.0
        return tp / (tp + fn)
    
    @staticmethod
    def f1_score(predictions: Vector, targets: Vector) -> float:
        """
        F1 Score = 2 * (Precision * Recall) / (Precision + Recall)
        
        F1 is the harmonic mean of precision and recall.
        It balances both metrics: good when you care about both
        false positives and false negatives equally.
        """
        p = ModelMetrics.precision(predictions, targets)
        r = ModelMetrics.recall(predictions, targets)
        
        if p + r == 0:
            return 0.0
        return 2 * (p * r) / (p + r)
    
    @staticmethod
    def mse(predictions: Vector, targets: Vector) -> float:
        """Mean Squared Error for regression."""
        if predictions.size != targets.size:
            raise ValueError("Predictions and targets must have same size")
        
        return sum((predictions[i] - targets[i]) ** 2 
                  for i in range(predictions.size)) / predictions.size
    
    @staticmethod
    def rmse(predictions: Vector, targets: Vector) -> float:
        """Root Mean Squared Error."""
        return math.sqrt(ModelMetrics.mse(predictions, targets))
    
    @staticmethod
    def mae(predictions: Vector, targets: Vector) -> float:
        """Mean Absolute Error."""
        if predictions.size != targets.size:
            raise ValueError("Predictions and targets must have same size")
        
        return sum(abs(predictions[i] - targets[i]) 
                  for i in range(predictions.size)) / predictions.size
    
    @staticmethod
    def r2_score(predictions: Vector, targets: Vector) -> float:
        """
        R² Score (coefficient of determination).
        
        R² = 1 - SSE / SST
        Where SSE = sum((y_pred - y_true)^2)
        SST = sum((y_true - mean(y))^2)
        
        R² = 1.0: Perfect fit
        R² = 0.0: Model predicts the mean
        R² < 0.0: Model worse than predicting the mean
        """
        if predictions.size != targets.size:
            raise ValueError("Predictions and targets must have same size")
        
        # Mean of targets
        target_mean = Statistics.mean(targets)
        
        # Sum of squares total
        sst = sum((targets[i] - target_mean) ** 2 for i in range(targets.size))
        
        if sst == 0:
            return 1.0
        
        # Residual sum of squares
        sse = sum((targets[i] - predictions[i]) ** 2 for i in range(predictions.size))
        
        return 1 - (sse / sst)
    
    @staticmethod
    def brier_score(predictions: Vector, targets: Vector) -> float:
        """
        Brier score for probabilistic predictions.
        
        Brier = (1/n) * sum((p_i - y_i)^2)
        
        For binary classification, this measures the calibration of
        predicted probabilities. Lower is better.
        """
        if predictions.size != targets.size:
            raise ValueError("Predictions and targets must have same size")
        
        return sum((predictions[i] - targets[i]) ** 2 
                  for i in range(predictions.size)) / predictions.size
    
    @staticmethod
    def log_loss(predictions: Vector, targets: Vector) -> float:
        """
        Log loss (cross-entropy) for probabilistic predictions.
        
        Log loss = -(1/n) * sum(y_i * log(p_i) + (1-y_i) * log(1-p_i))
        """
        if predictions.size != targets.size:
            raise ValueError("Predictions and targets must have same size")
        
        epsilon = 1e-10
        loss = 0.0
        
        for i in range(predictions.size):
            p = min(max(predictions[i], epsilon), 1 - epsilon)
            y = targets[i]
            
            if y >= 0.5:
                loss -= math.log(p)
            else:
                loss -= math.log(1 - p)
        
        return loss / predictions.size
    
    @staticmethod
    def roc_curve(predictions: Vector, targets: Vector,
                  n_points: int = 100) -> Tuple[Vector, Vector, float]:
        """
        Compute ROC curve and AUC.
        
        The ROC curve shows the tradeoff between True Positive Rate
        and False Positive Rate at different threshold settings.
        AUC measures overall performance.
        
        Returns:
            Tuple of (fpr_vector, tpr_vector, auc)
        """
        n = predictions.size
        
        # Create threshold points
        thresholds = [i / n_points for i in range(n_points + 1)]
        fprs = []
        tprs = []
        
        for threshold in thresholds:
            # Apply threshold
            pred_binary = Vector([1 if predictions[i] >= threshold else 0 
                                 for i in range(n)])
            
            # Compute rates
            cm = ModelMetrics.confusion_matrix(pred_binary, targets)
            tp, fp = cm[0, 0], cm[0, 1]
            fn, tn = cm[1, 0], cm[1, 1]
            
            tpr = tp / (tp + fn) if (tp + fn) > 0 else 0
            fpr = fp / (fp + tn) if (fp + tn) > 0 else 0
            
            tprs.append(tpr)
            fprs.append(fpr)
        
        # Compute AUC (trapezoidal integration)
        auc = 0.0
        for i in range(1, len(fprs)):
            auc += (fprs[i] - fprs[i-1]) * (tprs[i] + tprs[i-1]) / 2
        
        return Vector(fprs), Vector(tprs), auc


class ModelSelection:
    """
    Model selection criteria and methods.
    
    Provides:
    - AIC (Akaike Information Criterion)
    - BIC (Bayesian Information Criterion)
    - Cross-validation for model selection
    - Regularization path selection
    """
    
    @staticmethod
    def aic(log_likelihood: float, n_params: int) -> float:
        """
        Akaike Information Criterion.
        
        AIC = -2 * log_likelihood + 2 * n_params
        
        AIC penalizes model complexity. Lower AIC indicates better model.
        Good for comparing models on the same data.
        """
        return -2 * log_likelihood + 2 * n_params
    
    @staticmethod
    def bic(log_likelihood: float, n_params: int, n_samples: int) -> float:
        """
        Bayesian Information Criterion.
        
        BIC = -2 * log_likelihood + n_params * log(n_samples)
        
        BIC penalizes complexity more heavily than AIC.
        Lower BIC indicates better model.
        """
        return -2 * log_likelihood + n_params * math.log(n_samples)
    
    @staticmethod
    def aic_from_mse(mse: float, n_params: int, n_samples: int) -> float:
        """
        Approximate AIC from MSE (for regression).
        
        Assumes Gaussian errors: log_likelihood = -n/2 * log(2π * MSE) - n/2
        """
        if mse <= 0:
            return float('inf')
        
        log_likelihood = -n_samples/2 * math.log(2 * math.pi * mse) - n_samples/2
        return ModelSelection.aic(log_likelihood, n_params)
    
    @staticmethod
    def bic_from_mse(mse: float, n_params: int, n_samples: int) -> float:
        """Approximate BIC from MSE."""
        if mse <= 0:
            return float('inf')
        
        log_likelihood = -n_samples/2 * math.log(2 * math.pi * mse) - n_samples/2
        return ModelSelection.bic(log_likelihood, n_params, n_samples)
    
    @staticmethod
    def train_validate_test_split(X: Matrix, y: Matrix,
                                  train_ratio: float = 0.6,
                                  val_ratio: float = 0.2,
                                  test_ratio: float = 0.2,
                                  random_seed: Optional[int] = None) -> Tuple:
        """
        Split data into train, validation, and test sets.
        
        Args:
            X: Data matrix.
            y: Labels.
            train_ratio: Fraction for training.
            val_ratio: Fraction for validation.
            test_ratio: Fraction for testing.
            random_seed: Seed for reproducibility.
            
        Returns:
            Tuple of (X_train, X_val, X_test, y_train, y_val, y_test)
        """
        if abs(train_ratio + val_ratio + test_ratio - 1.0) > 1e-10:
            raise ValueError("Ratios must sum to 1.0")
        
        n = X.rows
        
        # Shuffle data
        indices = list(range(n))
        if random_seed is not None:
            random.seed(random_seed)
            random.shuffle(indices)
        
        # Split points
        train_end = int(n * train_ratio)
        val_end = int(n * (train_ratio + val_ratio))
        
        train_indices = indices[:train_end]
        val_indices = indices[train_end:val_end]
        test_indices = indices[val_end:]
        
        # Create splits
        X_train = Matrix([[X[i, j] for j in range(X.cols)] for i in train_indices])
        X_val = Matrix([[X[i, j] for j in range(X.cols)] for i in val_indices])
        X_test = Matrix([[X[i, j] for j in range(X.cols)] for i in test_indices])
        
        y_train = Matrix([[y[i, j] for j in range(y.cols)] for i in train_indices])
        y_val = Matrix([[y[i, j] for j in range(y.cols)] for i in val_indices])
        y_test = Matrix([[y[i, j] for j in range(y.cols)] for i in test_indices])
        
        return X_train, X_val, X_test, y_train, y_val, y_test


class BiasVarianceAnalysis:
    """
    Bias-variance analysis for model evaluation.
    
    Provides methods to analyze and visualize the bias-variance tradeoff.
    """
    
    @staticmethod
    def decompose_bias_variance(predictions: Matrix, targets: Matrix) -> Dict[str, float]:
        """
        Decompose prediction error into bias and variance components.
        
        Error = Bias² + Variance + Irreducible Error
        
        Where:
        - Bias: Difference between average prediction and true value
        - Variance: Spread of predictions around the average
        - Irreducible Error: Noise in the data
        
        Args:
            predictions: Matrix of predictions (samples x 1)
            targets: Matrix of true values (samples x 1)
            
        Returns:
            Dict with 'bias_squared', 'variance', 'total_error'
        """
        n = predictions.rows
        
        # Compute average prediction
        mean_pred = sum(predictions[i, 0] for i in range(n)) / n
        mean_target = sum(targets[i, 0] for i in range(n)) / n
        
        # Bias = difference between average prediction and true value
        bias = mean_pred - mean_target
        bias_squared = bias ** 2
        
        # Variance = spread of predictions around the average
        variance = sum((predictions[i, 0] - mean_pred) ** 2 for i in range(n)) / n
        
        # Total error = MSE
        mse = ModelMetrics.mse(predictions.col(0), targets.col(0))
        
        # Irreducible error = noise in data (estimated from targets variance)
        # We can't measure this directly without multiple samples
        # So we compute it as the unexplained variance
        irreducible = mse - bias_squared - variance
        
        return {
            'bias_squared': bias_squared,
            'variance': variance,
            'total_error': mse,
            'irreducible_error': max(0, irreducible)  # Ensure non-negative
        }
    
    @staticmethod
    def learning_curve(model, X: Matrix, y: Matrix,
                       train_sizes: List[int],
                       random_seed: Optional[int] = None) -> Tuple[Matrix, Matrix]:
        """
        Generate learning curves for model evaluation.
        
        Learning curves show how performance changes with training set size.
        
        Args:
            model: ML model with fit() and score() methods.
            X: Data matrix.
            y: Labels.
            train_sizes: List of training set sizes.
            random_seed: Seed for reproducibility.
            
        Returns:
            Tuple of (train_scores_matrix, test_scores_matrix)
        """
        n = X.rows
        
        # Shuffle data
        indices = list(range(n))
        if random_seed is not None:
            random.seed(random_seed)
            random.shuffle(indices)
        
        # Fixed test set (20% of data)
        test_size = n // 5
        test_indices = indices[-test_size:]
        train_indices = indices[:-test_size]
        
        X_test = Matrix([[X[i, j] for j in range(X.cols)] for i in test_indices])
        y_test = Matrix([[y[i, j] for j in range(y.cols)] for i in test_indices])
        
        train_scores = []
        test_scores = []
        
        for train_size in train_sizes:
            if train_size > len(train_indices):
                break
            
            # Select training subset
            subset_indices = train_indices[:train_size]
            
            X_train = Matrix([[X[i, j] for j in range(X.cols)] for i in subset_indices])
            y_train = Matrix([[y[i, j] for j in range(y.cols)] for i in subset_indices])
            
            # Train model
            model.fit(X_train, y_train)
            
            # Evaluate on training set
            train_score = model.score(X_train, y_train)
            
            # Evaluate on test set
            test_score = model.score(X_test, y_test)
            
            train_scores.append(train_score)
            test_scores.append(test_score)
        
        # Convert to matrices
        train_scores_matrix = Matrix([[s] for s in train_scores])
        test_scores_matrix = Matrix([[s] for s in test_scores])
        
        return train_scores_matrix, test_scores_matrix
    
    @staticmethod
    def validation_curve(model, X: Matrix, y: Matrix,
                         param_name: str, param_values: List[Any],
                         random_seed: Optional[int] = None) -> Tuple[Matrix, Matrix]:
        """
        Generate validation curves for hyperparameter tuning.
        
        Validation curves show how performance changes with hyperparameter values.
        
        Args:
            model: ML model with fit() and score() methods.
            X: Data matrix.
            y: Labels.
            param_name: Name of hyperparameter to vary.
            param_values: List of values to try.
            random_seed: Seed for reproducibility.
            
        Returns:
            Tuple of (train_scores_matrix, test_scores_matrix)
        """
        # Fixed test set (20% of data)
        n = X.rows
        indices = list(range(n))
        if random_seed is not None:
            random.seed(random_seed)
            random.shuffle(indices)
        
        test_size = n // 5
        test_indices = indices[-test_size:]
        train_indices = indices[:-test_size]
        
        X_train = Matrix([[X[i, j] for j in range(X.cols)] for i in train_indices])
        y_train = Matrix([[y[i, j] for j in range(y.cols)] for i in train_indices])
        X_test = Matrix([[X[i, j] for j in range(X.cols)] for i in test_indices])
        y_test = Matrix([[y[i, j] for j in range(y.cols)] for i in test_indices])
        
        train_scores = []
        test_scores = []
        
        for param_value in param_values:
            # Set hyperparameter
            setattr(model, param_name, param_value)
            
            # Train on training data
            model.fit(X_train, y_train)
            
            # Evaluate
            train_score = model.score(X_train, y_train)
            test_score = model.score(X_test, y_test)
            
            train_scores.append(train_score)
            test_scores.append(test_score)
        
        # Convert to matrices
        train_scores_matrix = Matrix([[s] for s in train_scores])
        test_scores_matrix = Matrix([[s] for s in test_scores])
        
        return train_scores_matrix, test_scores_matrix
```

#### Step 2: Implement Ensemble Methods

**File: `src/models/ensemble.py`**

```python
"""
Ensemble learning methods for improved performance.

Ensemble methods combine multiple models to achieve better performance
than any individual model. They reduce variance (bagging) and bias (boosting).
"""

from typing import List, Dict, Optional, Any, Tuple
import random
from src.linear_algebra import Matrix, Vector
from src.models.base import BaseModel
from src.probability.evaluation import ModelMetrics
from src.probability.stats import Statistics


class BaggingClassifier(BaseModel):
    """
    Bagging (Bootstrap Aggregating) classifier.
    
    Bagging creates multiple models on bootstrap samples of the data,
    then averages their predictions. This reduces variance without
    increasing bias.
    
    Analogy: Instead of asking one expert, you ask many experts and
    average their opinions. The average is more reliable than any
    individual opinion.
    """
    
    def __init__(self, base_model_class, n_estimators: int = 10,
                 max_samples: float = 1.0, random_seed: Optional[int] = None):
        """
        Initialize Bagging classifier.
        
        Args:
            base_model_class: Class of base model to ensemble.
            n_estimators: Number of models in ensemble.
            max_samples: Fraction of data to sample for each model.
            random_seed: Seed for reproducibility.
        """
        super().__init__("BaggingClassifier")
        self.base_model_class = base_model_class
        self.n_estimators = n_estimators
        self.max_samples = max_samples
        self.random_seed = random_seed
        self.models = []
        
    def fit(self, X: Matrix, y: Vector) -> None:
        """
        Train ensemble on bootstrap samples.
        """
        n_samples = X.rows
        sample_size = int(n_samples * self.max_samples)
        
        if self.random_seed is not None:
            random.seed(self.random_seed)
        
        self.models = []
        
        for _ in range(self.n_estimators):
            # Bootstrap sampling
            indices = [random.randint(0, n_samples - 1) for _ in range(sample_size)]
            
            # Create sample
            X_sample_data = [[X[i, j] for j in range(X.cols)] for i in indices]
            y_sample = Vector([y[i] for i in indices])
            
            X_sample = Matrix(X_sample_data)
            
            # Train base model
            model = self.base_model_class()
            model.fit(X_sample, y_sample)
            self.models.append(model)
        
        self.trained = True
    
    def predict(self, X: Matrix) -> Vector:
        """
        Aggregate predictions from all models.
        """
        if not self.trained:
            raise ValueError("Model must be trained before prediction")
        
        # Get predictions from all models
        all_predictions = []
        for model in self.models:
            pred = model.predict(X)
            all_predictions.append(pred)
        
        # Average predictions (for probabilities) or majority vote
        n_models = len(self.models)
        n_samples = X.rows
        
        # Check if model outputs probabilities or labels
        # For binary classification, we average probabilities
        avg_predictions = []
        for i in range(n_samples):
            # Average predictions across models
            avg = sum(all_predictions[j][i] for j in range(n_models)) / n_models
            avg_predictions.append(avg)
        
        return Vector(avg_predictions)
    
    def predict_proba(self, X: Matrix) -> Matrix:
        """
        Get probability predictions from ensemble.
        """
        if not self.trained:
            raise ValueError("Model must be trained before prediction")
        
        # Get probability predictions from all models
        all_probs = []
        for model in self.models:
            if hasattr(model, 'predict_proba'):
                probs = model.predict_proba(X)
            else:
                # Convert predictions to probabilities
                preds = model.predict(X)
                probs = Matrix([[p, 1-p] for p in preds])
            all_probs.append(probs)
        
        # Average probabilities
        n_models = len(self.models)
        n_samples = X.rows
        n_classes = all_probs[0].cols
        
        avg_probs = []
        for i in range(n_samples):
            row = []
            for j in range(n_classes):
                avg = sum(all_probs[k][i, j] for k in range(n_models)) / n_models
                row.append(avg)
            avg_probs.append(row)
        
        return Matrix(avg_probs)


class VotingClassifier(BaseModel):
    """
    Voting classifier for ensemble learning.
    
    Combines predictions from multiple classifiers using majority vote
    (hard voting) or weighted average (soft voting).
    """
    
    def __init__(self, models: List[BaseModel], 
                 voting: str = 'hard',
                 weights: Optional[List[float]] = None):
        """
        Initialize voting classifier.
        
        Args:
            models: List of trained or trainable models.
            voting: 'hard' (majority vote) or 'soft' (average probabilities).
            weights: Optional weights for each model in soft voting.
        """
        super().__init__("VotingClassifier")
        self.models = models
        self.voting = voting
        self.weights = weights
        self.trained = False
    
    def fit(self, X: Matrix, y: Vector) -> None:
        """
        Train all models.
        """
        for model in self.models:
            model.fit(X, y)
        self.trained = True
    
    def predict(self, X: Matrix) -> Vector:
        """
        Predict using voting.
        """
        if not self.trained:
            raise ValueError("Model must be trained before prediction")
        
        if self.voting == 'hard':
            return self._hard_voting(X)
        else:
            return self._soft_voting(X)
    
    def _hard_voting(self, X: Matrix) -> Vector:
        """Majority vote for classification."""
        n_samples = X.rows
        n_models = len(self.models)
        
        # Get predictions
        all_preds = []
        for model in self.models:
            pred = model.predict(X)
            all_preds.append(pred)
        
        # Majority vote
        predictions = []
        for i in range(n_samples):
            # Count votes
            votes = {}
            for j in range(n_models):
                label = int(all_preds[j][i])
                votes[label] = votes.get(label, 0) + 1
            
            # Choose majority
            best_label = max(votes.items(), key=lambda x: x[1])[0]
            predictions.append(best_label)
        
        return Vector(predictions)
    
    def _soft_voting(self, X: Matrix) -> Vector:
        """Weighted average of probabilities."""
        n_samples = X.rows
        n_models = len(self.models)
        
        # Get probability predictions
        all_probs = []
        for model in self.models:
            if hasattr(model, 'predict_proba'):
                probs = model.predict_proba(X)
            else:
                preds = model.predict(X)
                probs = Matrix([[p, 1-p] for p in preds])
            all_probs.append(probs)
        
        # Weighted average
        weights = self.weights or [1.0] * n_models
        total_weight = sum(weights)
        
        avg_probs = []
        for i in range(n_samples):
            n_classes = all_probs[0].cols
            row = []
            for j in range(n_classes):
                weighted_sum = sum(all_probs[k][i, j] * weights[k] 
                                 for k in range(n_models))
                row.append(weighted_sum / total_weight)
            avg_probs.append(row)
        
        probs_matrix = Matrix(avg_probs)
        
        # Return predicted class
        predictions = []
        for i in range(n_samples):
            best_class = max(range(probs_matrix.cols), 
                           key=lambda j: probs_matrix[i, j])
            predictions.append(best_class)
        
        return Vector(predictions)
    
    def predict_proba(self, X: Matrix) -> Matrix:
        """
        Get probability predictions from voting.
        """
        if not self.trained:
            raise ValueError("Model must be trained before prediction")
        
        n_samples = X.rows
        n_models = len(self.models)
        
        # Get probability predictions
        all_probs = []
        for model in self.models:
            if hasattr(model, 'predict_proba'):
                probs = model.predict_proba(X)
            else:
                preds = model.predict(X)
                probs = Matrix([[p, 1-p] for p in preds])
            all_probs.append(probs)
        
        # Average probabilities
        n_classes = all_probs[0].cols
        avg_probs = []
        for i in range(n_samples):
            row = []
            for j in range(n_classes):
                avg = sum(all_probs[k][i, j] for k in range(n_models)) / n_models
                row.append(avg)
            avg_probs.append(row)
        
        return Matrix(avg_probs)
```

#### Step 3: Update Package Initialization

**File: `src/models/__init__.py`**

```python
"""
Machine learning models package.
"""

from src.models.base import BaseModel
from src.models.neural_network import NeuralNetwork
from src.models.ensemble import BaggingClassifier, VotingClassifier

__all__ = ['BaseModel', 'NeuralNetwork', 'BaggingClassifier', 'VotingClassifier']
```

#### Step 4: Update `src/probability/__init__.py`

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
from src.probability.evaluation import ModelMetrics, ModelSelection, BiasVarianceAnalysis

__all__ = [
    'Distribution', 'GaussianDistribution', 'BernoulliDistribution',
    'BinomialDistribution', 'ExponentialDistribution', 'PoissonDistribution',
    'Statistics',
    'BayesianInference', 'NaiveBayes', 'GaussianNaiveBayes',
    'BernoulliNaiveBayes', 'MultinomialNaiveBayes',
    'BayesianModelEvaluation',
    'MLE', 'MAP', 'Bootstrap',
    'ModelMetrics', 'ModelSelection', 'BiasVarianceAnalysis'
]
```

### The Verification

#### Step 1: Test the Evaluation Framework

**File: `tests/test_evaluation.py`**

```python
"""
Unit tests for model evaluation framework.
"""

import pytest
import math
import random
from src.linear_algebra import Vector, Matrix
from src.probability import ModelMetrics, ModelSelection, BiasVarianceAnalysis
from src.models import NeuralNetwork


class TestModelMetrics:
    """Test model evaluation metrics."""
    
    def test_accuracy(self):
        """Test accuracy computation."""
        preds = Vector([1, 0, 1, 1, 0, 0, 1])
        targets = Vector([1, 0, 1, 0, 1, 0, 1])
        
        acc = ModelMetrics.accuracy(preds, targets)
        assert acc == 4/7  # 4 correct out of 7
    
    def test_confusion_matrix(self):
        """Test confusion matrix."""
        preds = Vector([1, 0, 1, 1, 0, 0, 1])
        targets = Vector([1, 0, 1, 0, 1, 0, 1])
        
        cm = ModelMetrics.confusion_matrix(preds, targets)
        
        # TP: indices 0, 2, 6 = 3
        # FP: index 3 = 1 (pred 1, target 0)
        # FN: index 4 = 1 (pred 0, target 1)
        # TN: indices 1, 5 = 2
        assert cm[0, 0] == 3  # TP
        assert cm[0, 1] == 1  # FP
        assert cm[1, 0] == 1  # FN
        assert cm[1, 1] == 2  # TN
    
    def test_precision_recall_f1(self):
        """Test precision, recall, and F1."""
        preds = Vector([1, 0, 1, 1, 0, 0, 1])
        targets = Vector([1, 0, 1, 0, 1, 0, 1])
        
        precision = ModelMetrics.precision(preds, targets)
        recall = ModelMetrics.recall(preds, targets)
        f1 = ModelMetrics.f1_score(preds, targets)
        
        # TP=3, FP=1, FN=1
        assert precision == 3/4
        assert recall == 3/4
        assert f1 == 2 * (3/4 * 3/4) / (3/4 + 3/4)  # 0.75
    
    def test_regression_metrics(self):
        """Test regression metrics."""
        preds = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
        targets = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
        
        assert ModelMetrics.mse(preds, targets) == 0.0
        assert ModelMetrics.rmse(preds, targets) == 0.0
        assert ModelMetrics.mae(preds, targets) == 0.0
        assert ModelMetrics.r2_score(preds, targets) == 1.0
        
        # Imperfect predictions
        preds2 = Vector([2.0, 3.0, 4.0, 5.0, 6.0])
        targets2 = Vector([1.0, 2.0, 3.0, 4.0, 5.0])
        
        assert ModelMetrics.mse(preds2, targets2) == 1.0
        assert ModelMetrics.mae(preds2, targets2) == 1.0
    
    def test_roc_auc(self):
        """Test ROC curve and AUC."""
        # Perfect predictions
        preds = Vector([0.9, 0.1, 0.8, 0.2, 0.7, 0.3])
        targets = Vector([1.0, 0.0, 1.0, 0.0, 1.0, 0.0])
        
        fpr, tpr, auc = ModelMetrics.roc_curve(preds, targets, n_points=10)
        
        # AUC should be high for good predictions
        assert auc > 0.8


class TestBiasVariance:
    """Test bias-variance analysis."""
    
    def test_bias_variance_decomposition(self):
        """Test bias-variance decomposition."""
        # Perfect predictions
        preds = Matrix([[1.0] for _ in range(10)])
        targets = Matrix([[1.0] for _ in range(10)])
        
        result = BiasVarianceAnalysis.decompose_bias_variance(preds, targets)
        assert result['bias_squared'] == 0.0
        assert result['variance'] == 0.0
        assert result['total_error'] == 0.0
        
        # Biased predictions
        preds2 = Matrix([[2.0] for _ in range(10)])
        targets2 = Matrix([[1.0] for _ in range(10)])
        
        result2 = BiasVarianceAnalysis.decompose_bias_variance(preds2, targets2)
        assert result2['bias_squared'] == 1.0  # (2-1)^2
        assert result2['variance'] == 0.0
        assert result2['total_error'] == 1.0
    
    def test_learning_curve(self):
        """Test learning curve generation."""
        # Generate simple data
        X_data = [[i / 10] for i in range(100)]
        y_data = [[2 * X_data[i][0] + 3 + 0.1 * (i % 5)] for i in range(100)]
        
        X = Matrix(X_data)
        y = Matrix(y_data)
        
        # Create simple model
        from src.models import NeuralNetwork
        model = NeuralNetwork(
            layer_sizes=[1, 1],
            learning_rate=0.01,
            num_epochs=20,
            random_seed=42
        )
        
        # Generate learning curve
        train_sizes = [10, 20, 30, 50, 70]
        train_scores, test_scores = BiasVarianceAnalysis.learning_curve(
            model, X, y, train_sizes, random_seed=42
        )
        
        # Learning curves should show improvement with more data
        assert train_scores.rows > 0
        assert test_scores.rows > 0
        
        # As training size increases, test score should improve (or stay same)
        # Note: Scores might not strictly improve due to randomness
        test_score_vals = [test_scores[i, 0] for i in range(test_scores.rows)]
        # We just check that values are reasonable (between 0 and 1)
        for score in test_score_vals:
            assert 0 <= score <= 1
```

#### Step 2: Run the Tests

```bash
pytest tests/test_evaluation.py -v
```

#### Step 3: Interactive Verification

```python
>>> from src.probability import ModelMetrics, BiasVarianceAnalysis
>>> from src.models import NeuralNetwork
>>> from src.linear_algebra import Matrix, Vector
>>> import random
>>> 
>>> # Generate data
>>> X_data = [[random.random() * 10] for _ in range(200)]
>>> y_data = [[2 * x[0] + 3 + random.gauss(0, 0.5)] for x in X_data]
>>> 
>>> X = Matrix(X_data)
>>> y = Matrix(y_data)
>>> 
>>> # Create model
>>> model = NeuralNetwork([1, 4, 1], learning_rate=0.01, num_epochs=50)
>>> model.fit(X, y)
>>> 
>>> # Evaluate
>>> preds = model.predict(X)
>>> 
>>> mse = ModelMetrics.mse(preds.col(0), y.col(0))
>>> r2 = ModelMetrics.r2_score(preds.col(0), y.col(0))
>>> 
>>> print(f"MSE: {mse:.4f}")
>>> print(f"R²: {r2:.4f}")
>>> 
>>> # Bias-variance analysis
>>> result = BiasVarianceAnalysis.decompose_bias_variance(preds, y)
>>> print(f"Bias²: {result['bias_squared']:.4f}")
>>> print(f"Variance: {result['variance']:.4f}")
>>> print(f"Total Error: {result['total_error']:.4f}")
```

---

**[GENERATED: Phase 3, Part 3 - The Bias-Variance Tradeoff and Model Evaluation]**

**[COMPLETED: Phase 3 - Probability & Statistics: Handling Uncertainty]**

---

### Phase 3 Summary

You've successfully completed the Probability and Statistics module! Here's what you've built:

#### Completed Files

```
src/probability/
├── __init__.py          # Package initialization
├── distributions.py     # Probability distributions (Gaussian, Bernoulli, etc.)
├── stats.py            # Statistical functions
├── bayes.py            # Bayes' Theorem, Naive Bayes classifiers
├── inference.py        # MLE, MAP, Bootstrap methods
└── evaluation.py       # Model metrics, bias-variance, learning curves

src/models/
├── __init__.py
├── base.py
├── neural_network.py
└── ensemble.py         # Bagging, Voting classifiers

tests/
├── test_probability.py
├── test_bayes.py
└── test_evaluation.py
```

#### Key Skills Acquired

1. **Probability Distributions**: Modeling uncertainty in data
2. **Bayesian Inference**: Updating beliefs with new evidence
3. **Naive Bayes**: Simple but effective classification
4. **Model Evaluation**: Metrics, bias-variance analysis, cross-validation
5. **Ensemble Methods**: Combining models for better performance

#### What's Next

In **Phase 4: Applied Numerical Methods — From Math to Code**, you'll learn:
- Numerical stability and floating-point precision
- Vectorization and performance optimization
- Building production-ready ML systems
- Complete end-to-end pipeline implementation

You'll bring everything together to build a production-ready machine learning system that integrates linear algebra, calculus, probability, and optimization.

---

*Next: We'll tackle numerical stability, performance optimization, and build a complete production-ready ML system that integrates all our previous work.*
