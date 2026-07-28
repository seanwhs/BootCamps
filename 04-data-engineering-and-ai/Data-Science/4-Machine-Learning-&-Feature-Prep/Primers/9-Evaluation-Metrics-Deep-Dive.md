# Primer 9: Evaluation Metrics Deep Dive

## Overview

This primer provides a comprehensive deep dive into evaluation metrics—the tools we use to measure model performance. Choosing the right metrics is crucial for building models that truly solve business problems. This primer covers classification, regression, and specialized metrics, along with guidance on when to use each.

---

## 1. Classification Metrics

### The Confusion Matrix

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONFUSION MATRIX                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                      Predicted                                 │
│                  Positive    Negative                          │
│          ┌─────────────────────────────┐                      │
│  Actual  │                             │                      │
│  Positive│     TP           FN         │                      │
│          │                             │                      │
│  Negative│     FP           TN         │                      │
│          │                             │                      │
│          └─────────────────────────────┘                      │
│                                                                 │
│  TP: True Positive   FN: False Negative                         │
│  FP: False Positive  TN: True Negative                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Key Metrics

```python
import numpy as np
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, average_precision_score, log_loss,
    confusion_matrix, classification_report
)

def compute_all_classification_metrics(y_true, y_pred, y_proba=None):
    """
    Compute all classification metrics.
    
    Args:
        y_true: True labels
        y_pred: Predicted labels
        y_proba: Predicted probabilities (optional)
    
    Returns:
        dict: All metrics
    """
    metrics = {}
    
    # Basic metrics
    metrics['accuracy'] = accuracy_score(y_true, y_pred)
    metrics['precision'] = precision_score(y_true, y_pred, average='weighted', zero_division=0)
    metrics['recall'] = recall_score(y_true, y_pred, average='weighted', zero_division=0)
    metrics['f1'] = f1_score(y_true, y_pred, average='weighted', zero_division=0)
    
    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    tn, fp, fn, tp = cm.ravel() if cm.size == 4 else (0, 0, 0, 0)
    metrics['true_positives'] = tp
    metrics['false_positives'] = fp
    metrics['true_negatives'] = tn
    metrics['false_negatives'] = fn
    
    # Additional metrics for binary classification
    if len(np.unique(y_true)) == 2:
        # Specialized binary metrics
        metrics['precision_binary'] = precision_score(y_true, y_pred, zero_division=0)
        metrics['recall_binary'] = recall_score(y_true, y_pred, zero_division=0)
        metrics['f1_binary'] = f1_score(y_true, y_pred, zero_division=0)
        metrics['specificity'] = tn / (tn + fp) if (tn + fp) > 0 else 0
        metrics['sensitivity'] = tp / (tp + fn) if (tp + fn) > 0 else 0
        
        # Probability-based metrics
        if y_proba is not None:
            metrics['roc_auc'] = roc_auc_score(y_true, y_proba)
            metrics['average_precision'] = average_precision_score(y_true, y_proba)
            metrics['log_loss'] = log_loss(y_true, y_proba)
    else:
        # Multi-class probability metrics
        if y_proba is not None:
            metrics['roc_auc_macro'] = roc_auc_score(y_true, y_proba, multi_class='ovr', average='macro')
            metrics['roc_auc_weighted'] = roc_auc_score(y_true, y_proba, multi_class='ovr', average='weighted')
            metrics['log_loss'] = log_loss(y_true, y_proba)
    
    # Per-class metrics
    report = classification_report(y_true, y_pred, output_dict=True, zero_division=0)
    for class_name in report.keys():
        if class_name not in ['accuracy', 'macro avg', 'weighted avg']:
            metrics[f'precision_class_{class_name}'] = report[class_name]['precision']
            metrics[f'recall_class_{class_name}'] = report[class_name]['recall']
            metrics[f'f1_class_{class_name}'] = report[class_name]['f1-score']
    
    return metrics

# Example usage
metrics = compute_all_classification_metrics(y_test, y_pred, y_proba)
print("Classification Metrics:")
for key, value in metrics.items():
    print(f"  {key}: {value:.4f}")
```

### When to Use Which Metric

```
┌─────────────────────────────────────────────────────────────────┐
│              METRIC SELECTION GUIDE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Metric          │ Best For                         │ Pitfalls │
├──────────────────┼──────────────────────────────────┼──────────┤
│  Accuracy        │ Balanced classes                 │ Imbalanced│
│                  │                                  │ data      │
│                  │                                  │          │
│  Precision       │ Minimize false positives         │ Misses   │
│                  │ (spam detection, fraud)          │ positives│
│                  │                                  │          │
│  Recall          │ Minimize false negatives         │ Many     │
│                  │ (disease detection)              │ false     │
│                  │                                  │ positives│
│                  │                                  │          │
│  F1 Score        │ Balance precision/recall         │ No       │
│                  │ (general use)                    │ threshold│
│                  │                                  │ tuning   │
│                  │                                  │          │
│  ROC-AUC         │ Overall performance              │ Imbalanced│
│                  │ (ranking)                        │ data can  │
│                  │                                  │ be        │
│                  │                                  │ optimistic│
│                  │                                  │          │
│  PR-AUC          │ Imbalanced data                  │ Harder to│
│                  │ (rare events)                    │ interpret│
│                  │                                  │          │
└─────────────────────────────────────────────────────────────────┘
```

### ROC vs PR Curve

```python
from sklearn.metrics import roc_curve, precision_recall_curve

def plot_roc_pr_curves(y_true, y_proba):
    """Plot ROC and Precision-Recall curves."""
    import matplotlib.pyplot as plt
    
    # ROC curve
    fpr, tpr, _ = roc_curve(y_true, y_proba)
    roc_auc = roc_auc_score(y_true, y_proba)
    
    # PR curve
    precision, recall, _ = precision_recall_curve(y_true, y_proba)
    pr_auc = average_precision_score(y_true, y_proba)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # ROC curve
    ax1.plot(fpr, tpr, label=f'ROC (AUC = {roc_auc:.3f})')
    ax1.plot([0, 1], [0, 1], 'k--', label='Random')
    ax1.set_xlabel('False Positive Rate')
    ax1.set_ylabel('True Positive Rate')
    ax1.set_title('ROC Curve')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # PR curve
    ax2.plot(recall, precision, label=f'PR (AUC = {pr_auc:.3f})')
    ax2.set_xlabel('Recall')
    ax2.set_ylabel('Precision')
    ax2.set_title('Precision-Recall Curve')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.show()
```

---

## 2. Regression Metrics

### Key Regression Metrics

```python
from sklearn.metrics import (
    mean_squared_error, mean_absolute_error, r2_score,
    mean_absolute_percentage_error, explained_variance_score
)

def compute_regression_metrics(y_true, y_pred):
    """Compute all regression metrics."""
    metrics = {}
    
    # Error metrics
    metrics['mse'] = mean_squared_error(y_true, y_pred)
    metrics['rmse'] = np.sqrt(metrics['mse'])
    metrics['mae'] = mean_absolute_error(y_true, y_pred)
    metrics['mape'] = mean_absolute_percentage_error(y_true, y_pred) * 100
    
    # Fit metrics
    metrics['r2'] = r2_score(y_true, y_pred)
    metrics['explained_variance'] = explained_variance_score(y_true, y_pred)
    
    # Relative metrics
    if np.mean(y_true) != 0:
        metrics['mape_actual'] = np.mean(np.abs((y_true - y_pred) / y_true)) * 100
    
    return metrics

# Example usage
metrics = compute_regression_metrics(y_test, y_pred)
print("Regression Metrics:")
for key, value in metrics.items():
    print(f"  {key}: {value:.4f}")
```

### When to Use Which Metric

```
┌─────────────────────────────────────────────────────────────────┐
│              METRIC SELECTION GUIDE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Metric          │ Best For                         │ Pitfalls │
├──────────────────┼──────────────────────────────────┼──────────┤
│  MAE             │ Interpretable errors             │ Less     │
│                  │ (robust to outliers)             │ sensitive│
│                  │                                  │ to large │
│                  │                                  │ errors   │
│                  │                                  │          │
│  MSE/RMSE        │ Large errors penalized           │ Sensitive│
│                  │ (stock prediction)               │ to       │
│                  │                                  │ outliers │
│                  │                                  │          │
│  MAPE            │ Interpretable percentage         │ Zero     │
│                  │ (business reporting)             │ values   │
│                  │                                  │          │
│  R²              │ Variance explained               │ Can be   │
│                  │ (model comparison)               │ negative │
│                  │                                  │          │
│  Explained Var   │ Variance explained (scaled)      │ Less     │
│                  │                                  │ common   │
│                  │                                  │          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Imbalanced Data Metrics

### Handling Imbalance

```python
from sklearn.metrics import balanced_accuracy_score, matthews_corrcoef

def imbalanced_metrics(y_true, y_pred):
    """Compute metrics specifically for imbalanced data."""
    metrics = {}
    
    # Balanced accuracy (average of recall per class)
    metrics['balanced_accuracy'] = balanced_accuracy_score(y_true, y_pred)
    
    # Matthews Correlation Coefficient (range: -1 to 1)
    metrics['mcc'] = matthews_corrcoef(y_true, y_pred)
    
    # Geometric mean of recall per class
    from sklearn.metrics import recall_score
    recalls = recall_score(y_true, y_pred, average=None)
    metrics['geometric_mean'] = np.prod(recalls) ** (1/len(recalls))
    
    return metrics
```

### Cost-Sensitive Metrics

```python
def cost_sensitive_metrics(y_true, y_pred, cost_matrix):
    """
    Compute cost-sensitive metrics.
    
    Args:
        y_true: True labels
        y_pred: Predicted labels
        cost_matrix: Cost matrix [[TN, FP], [FN, TP]]
    
    Returns:
        dict: Cost metrics
    """
    cm = confusion_matrix(y_true, y_pred)
    tn, fp, fn, tp = cm.ravel()
    
    # Cost matrix: [[cost_TN, cost_FP], [cost_FN, cost_TP]]
    total_cost = (tn * cost_matrix[0][0] + 
                  fp * cost_matrix[0][1] + 
                  fn * cost_matrix[1][0] + 
                  tp * cost_matrix[1][1])
    
    # Cost of perfect predictions
    perfect_tn = len(y_true[y_true == 0])
    perfect_tp = len(y_true[y_true == 1])
    perfect_cost = (perfect_tn * cost_matrix[0][0] + 
                    perfect_tp * cost_matrix[1][1])
    
    metrics = {
        'total_cost': total_cost,
        'perfect_cost': perfect_cost,
        'cost_ratio': total_cost / perfect_cost if perfect_cost > 0 else 0
    }
    
    return metrics
```

---

## 4. Multi-Class Metrics

### Micro, Macro, Weighted Averages

```python
from sklearn.metrics import precision_recall_fscore_support

def multi_class_metrics(y_true, y_pred):
    """Compute multi-class metrics with different averaging strategies."""
    
    # Per-class metrics
    precision, recall, f1, support = precision_recall_fscore_support(
        y_true, y_pred, average=None
    )
    
    # Macro average (unweighted mean)
    macro_precision = np.mean(precision)
    macro_recall = np.mean(recall)
    macro_f1 = np.mean(f1)
    
    # Weighted average (weighted by support)
    weighted_precision = np.average(precision, weights=support)
    weighted_recall = np.average(recall, weights=support)
    weighted_f1 = np.average(f1, weights=support)
    
    # Micro average (global TP, FP, FN)
    micro_precision, micro_recall, micro_f1, _ = precision_recall_fscore_support(
        y_true, y_pred, average='micro'
    )
    
    return {
        'per_class': {
            'precision': precision.tolist(),
            'recall': recall.tolist(),
            'f1': f1.tolist(),
            'support': support.tolist()
        },
        'macro': {'precision': macro_precision, 'recall': macro_recall, 'f1': macro_f1},
        'weighted': {'precision': weighted_precision, 'recall': weighted_recall, 'f1': weighted_f1},
        'micro': {'precision': micro_precision, 'recall': micro_recall, 'f1': micro_f1}
    }

# Example
metrics = multi_class_metrics(y_test, y_pred)
```

---

## 5. Calibration Metrics

### Calibration Plot

```python
from sklearn.calibration import calibration_curve

def plot_calibration_curve(y_true, y_proba, n_bins=10):
    """Plot calibration curve."""
    import matplotlib.pyplot as plt
    
    prob_true, prob_pred = calibration_curve(
        y_true, y_proba, n_bins=n_bins, strategy='uniform'
    )
    
    plt.figure(figsize=(8, 6))
    plt.plot(prob_pred, prob_true, marker='o', linewidth=2, label='Model')
    plt.plot([0, 1], [0, 1], 'k--', label='Perfect Calibration')
    plt.xlabel('Mean Predicted Probability')
    plt.ylabel('Fraction of Positives')
    plt.title('Calibration Plot')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.show()
```

### Brier Score

```python
from sklearn.metrics import brier_score_loss

def compute_calibration_metrics(y_true, y_proba):
    """Compute calibration metrics."""
    metrics = {}
    
    # Brier score (mean squared error of probabilities)
    metrics['brier_score'] = brier_score_loss(y_true, y_proba)
    
    # Expected Calibration Error (ECE)
    import numpy as np
    n_bins = 10
    bin_boundaries = np.linspace(0, 1, n_bins + 1)
    
    ece = 0.0
    for i in range(n_bins):
        bin_mask = (y_proba >= bin_boundaries[i]) & (y_proba < bin_boundaries[i+1])
        if np.sum(bin_mask) > 0:
            bin_acc = np.mean(y_true[bin_mask])
            bin_conf = np.mean(y_proba[bin_mask])
            ece += np.abs(bin_acc - bin_conf) * np.sum(bin_mask) / len(y_proba)
    
    metrics['ece'] = ece
    
    return metrics
```

---

## 6. Ranking Metrics

### AUC and beyond

```python
from sklearn.metrics import roc_auc_score, average_precision_score

def ranking_metrics(y_true, y_scores):
    """Compute ranking metrics."""
    metrics = {}
    
    # ROC-AUC
    metrics['roc_auc'] = roc_auc_score(y_true, y_scores)
    
    # PR-AUC
    metrics['pr_auc'] = average_precision_score(y_true, y_scores)
    
    # Concordance Index
    from sklearn.metrics import roc_curve
    fpr, tpr, thresholds = roc_curve(y_true, y_scores)
    metrics['concordance_index'] = 0.5 * (1 + 2 * roc_auc_score(y_true, y_scores) - 1)
    
    return metrics
```

---

## 7. Business Metrics

### Converting Model Metrics to Business Impact

```python
def business_impact_metrics(y_true, y_pred, cost_per_action, value_per_correct):
    """
    Calculate business impact of model decisions.
    
    Args:
        y_true: True labels
        y_pred: Predicted labels
        cost_per_action: Cost of taking action
        value_per_correct: Value of correct prediction
    
    Returns:
        dict: Business metrics
    """
    cm = confusion_matrix(y_true, y_pred)
    tn, fp, fn, tp = cm.ravel()
    
    # Business impact
    total_cost = (tp + fp) * cost_per_action  # Cost of actions taken
    total_value = tp * value_per_correct      # Value from correct actions
    net_benefit = total_value - total_cost
    
    # Potential impact if perfect
    perfect_value = (tp + fn) * value_per_correct
    perfect_cost = (tp + fn) * cost_per_action
    perfect_net = perfect_value - perfect_cost
    
    metrics = {
        'total_cost': total_cost,
        'total_value': total_value,
        'net_benefit': net_benefit,
        'perfect_net': perfect_net,
        'benefit_ratio': net_benefit / perfect_net if perfect_net > 0 else 0,
        'profit_per_prediction': net_benefit / len(y_true)
    }
    
    return metrics
```

---

## 8. Model Comparison Framework

```python
def compare_models(models, X_train, X_test, y_train, y_test):
    """
    Compare multiple models using various metrics.
    
    Args:
        models: Dict of model_name: model_instance
        X_train, X_test, y_train, y_test: Data
    
    Returns:
        pd.DataFrame: Comparison results
    """
    results = []
    
    for name, model in models.items():
        # Train
        model.fit(X_train, y_train)
        
        # Predict
        y_pred = model.predict(X_test)
        y_proba = model.predict_proba(X_test)[:, 1] if hasattr(model, 'predict_proba') else None
        
        # Compute metrics
        if y_proba is not None:
            metrics = compute_all_classification_metrics(y_test, y_pred, y_proba)
        else:
            metrics = compute_all_classification_metrics(y_test, y_pred)
        
        # Add to results
        results.append({
            'model': name,
            'accuracy': metrics['accuracy'],
            'precision': metrics['precision'],
            'recall': metrics['recall'],
            'f1': metrics['f1'],
            'roc_auc': metrics.get('roc_auc', np.nan),
            'pr_auc': metrics.get('average_precision', np.nan)
        })
    
    return pd.DataFrame(results).sort_values('f1', ascending=False)
```

---

## Quick Reference: Metric Selection

```
┌─────────────────────────────────────────────────────────────────┐
│           QUICK METRIC SELECTION GUIDE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Scenario                  │ Primary Metric  │ Secondary       │
├────────────────────────────┼─────────────────┼─────────────────┤
│  Balanced Classification   │ Accuracy        │ F1              │
│  Imbalanced Classification │ PR-AUC          │ F1              │
│  Spam Detection            │ Precision       │ Accuracy        │
│  Disease Detection         │ Recall          │ F1              │
│  Ranking                   │ ROC-AUC         │ PR-AUC          │
│  Multi-class               │ Macro F1        │ Accuracy        │
│  Regression (interpretable)│ MAE             │ R²              │
│  Regression (penalize)     │ RMSE            │ R²              │
│  Business Impact           │ Custom Cost     │ Profit          │
│  Model Calibration         │ Brier Score     │ ECE             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of evaluation metrics. You now understand:

1. **Classification metrics**: Accuracy, precision, recall, F1, ROC-AUC, PR-AUC
2. **Regression metrics**: MAE, RMSE, R², MAPE
3. **Imbalanced data metrics**: Balanced accuracy, MCC, geometric mean
4. **Multi-class metrics**: Micro, macro, weighted averages
5. **Calibration metrics**: Brier score, ECE
6. **Business metrics**: Cost-benefit analysis

**Next Steps:**
1. Practice with different datasets
2. Choose appropriate metrics for your problem
3. Implement custom business metrics
4. Create model comparison frameworks
5. Proceed to Part 1 of the series

---

*End of Primer 9*
