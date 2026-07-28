# Primer 15: Feature Importance and Model Interpretation

## Overview

This primer provides a comprehensive deep dive into feature importance and model interpretation—critical skills for understanding why your model makes certain predictions, debugging issues, and building trust with stakeholders. This primer covers various techniques for extracting and visualizing feature importance across different model types.

---

## 1. Why Feature Importance Matters

### The Importance of Understanding Models

```
┌─────────────────────────────────────────────────────────────────┐
│              WHY FEATURE IMPORTANCE MATTERS                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Debugging                                                     │
│  └── Identify unexpected patterns or data issues              │
│                                                                 │
│  Feature Engineering                                           │
│  └── Guide feature selection and creation                     │
│                                                                 │
│  Model Simplification                                          │
│  └── Remove unimportant features                              │
│                                                                 │
│  Stakeholder Communication                                     │
│  └── Explain model decisions to non-technical audiences       │
│                                                                 │
│  Regulatory Compliance                                         │
│  └── Document model behavior for audits                       │
│                                                                 │
│  Trust Building                                                │
│  └── Build confidence in model predictions                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Types of Feature Importance

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPES OF FEATURE IMPORTANCE                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Global Importance                                             │
│  └── Which features are most important overall?               │
│      • Model-based importance                                  │
│      • Permutation importance                                  │
│      • SHAP global importance                                  │
│                                                                 │
│  Local Importance                                              │
│  └── Why did the model make this specific prediction?         │
│      • SHAP local explanations                                 │
│      • LIME explanations                                       │
│      • Individual Conditional Expectation                     │
│                                                                 │
│  Interaction Importance                                        │
│  └── How do features interact?                                │
│      • SHAP interaction values                                 │
│      • Partial dependence plots                                │
│      • H-statistic                                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Model-Based Feature Importance

### Tree-Based Models

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
import xgboost as xgb
import lightgbm as lgb
import catboost as cb

def get_tree_importance(model, feature_names, importance_type='default'):
    """
    Extract feature importance from tree-based models.
    
    Args:
        model: Trained tree-based model
        feature_names: List of feature names
        importance_type: Type of importance ('default', 'gain', 'cover', 'split')
    
    Returns:
        pd.DataFrame: Feature importance sorted by importance
    """
    # Get importance based on model type
    if isinstance(model, RandomForestClassifier):
        if importance_type == 'default':
            importances = model.feature_importances_
        else:
            importances = model.feature_importances_
    
    elif isinstance(model, GradientBoostingClassifier):
        importances = model.feature_importances_
    
    elif isinstance(model, xgb.XGBClassifier):
        # XGBoost importance types: 'weight', 'gain', 'cover'
        if importance_type in ['weight', 'gain', 'cover']:
            importances = model.get_booster().get_score(importance_type=importance_type)
            # Convert to array aligned with features
            importance_array = np.zeros(len(feature_names))
            for i, name in enumerate(feature_names):
                key = f'f{i}'
                if key in importances:
                    importance_array[i] = importances[key]
            importances = importance_array
        else:
            importances = model.feature_importances_
    
    elif isinstance(model, lgb.LGBMClassifier):
        importances = model.feature_importances_
    
    elif isinstance(model, cb.CatBoostClassifier):
        importances = model.feature_importances_
    
    else:
        raise ValueError(f"Unsupported model type: {type(model)}")
    
    # Create DataFrame
    importance_df = pd.DataFrame({
        'feature': feature_names,
        'importance': importances
    }).sort_values('importance', ascending=False)
    
    return importance_df

def plot_importance(importance_df, title="Feature Importance", top_k=20, figsize=(10, 8)):
    """
    Plot feature importance.
    
    Args:
        importance_df: DataFrame with 'feature' and 'importance' columns
        title: Plot title
        top_k: Number of top features to show
        figsize: Figure size
    """
    top_features = importance_df.head(top_k)
    
    fig, ax = plt.subplots(figsize=figsize)
    bars = ax.barh(top_features['feature'], top_features['importance'])
    
    # Color bars by importance
    colors = plt.cm.viridis(top_features['importance'] / top_features['importance'].max())
    for bar, color in zip(bars, colors):
        bar.set_color(color)
    
    ax.set_xlabel('Importance')
    ax.set_title(title)
    ax.invert_yaxis()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig

# Example usage
rf_model = RandomForestClassifier()
rf_model.fit(X_train, y_train)

importance_df = get_tree_importance(rf_model, X_train.columns)
print(importance_df.head(10))

fig = plot_importance(importance_df, title="Random Forest Feature Importance")
```

### Linear Models

```python
def get_linear_importance(model, feature_names):
    """
    Extract importance from linear models.
    
    Args:
        model: Trained linear model
        feature_names: List of feature names
    
    Returns:
        pd.DataFrame: Feature importance
    """
    if hasattr(model, 'coef_'):
        coefficients = model.coef_
        if len(coefficients.shape) > 1:
            coefficients = coefficients[0]
    elif hasattr(model, 'feature_importances_'):
        coefficients = model.feature_importances_
    else:
        raise ValueError("Model has no coefficients or feature importance")
    
    importance_df = pd.DataFrame({
        'feature': feature_names,
        'coefficient': coefficients,
        'abs_coefficient': np.abs(coefficients)
    }).sort_values('abs_coefficient', ascending=False)
    
    return importance_df

def plot_linear_coefficients(importance_df, title="Linear Model Coefficients", figsize=(10, 8)):
    """
    Plot linear model coefficients.
    
    Args:
        importance_df: DataFrame with 'feature' and 'coefficient' columns
        title: Plot title
        figsize: Figure size
    """
    fig, ax = plt.subplots(figsize=figsize)
    
    # Split positive and negative coefficients
    positive = importance_df[importance_df['coefficient'] > 0]
    negative = importance_df[importance_df['coefficient'] < 0]
    
    # Plot
    if not positive.empty:
        ax.barh(positive['feature'], positive['coefficient'], color='green', alpha=0.7, label='Positive')
    if not negative.empty:
        ax.barh(negative['feature'], negative['coefficient'], color='red', alpha=0.7, label='Negative')
    
    ax.axvline(x=0, color='black', linestyle='-', linewidth=0.5)
    ax.set_xlabel('Coefficient')
    ax.set_title(title)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig
```

---

## 3. Permutation Importance

```python
from sklearn.inspection import permutation_importance
from sklearn.model_selection import train_test_split

def compute_permutation_importance(model, X, y, n_repeats=10, n_jobs=-1):
    """
    Compute permutation importance.
    
    Args:
        model: Trained model
        X: Feature matrix
        y: Target vector
        n_repeats: Number of permutations
        n_jobs: Number of parallel jobs
    
    Returns:
        pd.DataFrame: Permutation importance
    """
    result = permutation_importance(
        model, X, y,
        n_repeats=n_repeats,
        random_state=42,
        n_jobs=n_jobs
    )
    
    importance_df = pd.DataFrame({
        'feature': X.columns,
        'importance_mean': result.importances_mean,
        'importance_std': result.importances_std
    }).sort_values('importance_mean', ascending=False)
    
    return importance_df

def plot_permutation_importance(importance_df, title="Permutation Importance", figsize=(10, 8)):
    """
    Plot permutation importance with error bars.
    
    Args:
        importance_df: DataFrame with 'feature', 'importance_mean', 'importance_std'
        title: Plot title
        figsize: Figure size
    """
    fig, ax = plt.subplots(figsize=figsize)
    
    top_features = importance_df.head(20)
    
    ax.barh(
        top_features['feature'],
        top_features['importance_mean'],
        xerr=top_features['importance_std'],
        capsize=5,
        color='steelblue',
        alpha=0.7
    )
    
    ax.set_xlabel('Importance')
    ax.set_title(title)
    ax.invert_yaxis()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig
```

---

## 4. SHAP Values

### SHAP Global Importance

```python
import shap

def compute_shap_importance(model, X, model_type='tree'):
    """
    Compute SHAP importance.
    
    Args:
        model: Trained model
        X: Feature matrix
        model_type: 'tree', 'linear', 'deep', 'kernel'
    
    Returns:
        tuple: (shap_values, explainer)
    """
    if model_type == 'tree':
        explainer = shap.TreeExplainer(model)
    elif model_type == 'linear':
        explainer = shap.LinearExplainer(model, X)
    elif model_type == 'kernel':
        explainer = shap.KernelExplainer(model.predict, X)
    else:
        raise ValueError(f"Unsupported model type: {model_type}")
    
    shap_values = explainer.shap_values(X)
    
    return shap_values, explainer

def get_shap_global_importance(shap_values, feature_names):
    """
    Get SHAP global importance.
    
    Args:
        shap_values: SHAP values from TreeExplainer
        feature_names: List of feature names
    
    Returns:
        pd.DataFrame: SHAP importance
    """
    # Handle multi-class
    if isinstance(shap_values, list):
        # Average absolute SHAP values across classes
        shap_abs = np.mean([np.abs(sv).mean(axis=0) for sv in shap_values], axis=0)
    else:
        shap_abs = np.abs(shap_values).mean(axis=0)
    
    importance_df = pd.DataFrame({
        'feature': feature_names,
        'shap_importance': shap_abs
    }).sort_values('shap_importance', ascending=False)
    
    return importance_df

def plot_shap_summary(shap_values, X, feature_names, plot_type='bar'):
    """
    Plot SHAP summary.
    
    Args:
        shap_values: SHAP values
        X: Feature matrix
        feature_names: Feature names
        plot_type: 'bar', 'dot', 'violin'
    """
    if plot_type == 'bar':
        shap.summary_plot(shap_values, X, feature_names=feature_names, plot_type="bar")
    elif plot_type == 'dot':
        shap.summary_plot(shap_values, X, feature_names=feature_names)
    elif plot_type == 'violin':
        shap.summary_plot(shap_values, X, feature_names=feature_names, plot_type="violin")
```

### SHAP Local Explanations

```python
def explain_shap_local(shap_values, X, sample_idx, feature_names):
    """
    Explain a single prediction using SHAP.
    
    Args:
        shap_values: SHAP values
        X: Feature matrix
        sample_idx: Index of sample to explain
        feature_names: Feature names
    
    Returns:
        dict: Local explanation
    """
    # Get SHAP values for the sample
    if isinstance(shap_values, list):
        # Multi-class: take first class
        shap_sample = shap_values[0][sample_idx]
        # Get predicted class
        pred_class = 0
    else:
        shap_sample = shap_values[sample_idx]
        pred_class = 0
    
    # Get feature values
    feature_values = X.iloc[sample_idx].values
    
    # Create explanation
    explanation = {
        'prediction': pred_class,
        'base_value': explainer.expected_value,
        'feature_contributions': []
    }
    
    for i, name in enumerate(feature_names):
        explanation['feature_contributions'].append({
            'feature': name,
            'value': feature_values[i],
            'shap_value': shap_sample[i]
        })
    
    # Sort by absolute SHAP value
    explanation['feature_contributions'].sort(
        key=lambda x: abs(x['shap_value']), reverse=True
    )
    
    return explanation

def plot_shap_waterfall(shap_values, X, sample_idx, feature_names, max_display=10):
    """
    Plot SHAP waterfall plot.
    
    Args:
        shap_values: SHAP values
        X: Feature matrix
        sample_idx: Index of sample to explain
        feature_names: Feature names
        max_display: Maximum number of features to show
    """
    # Get SHAP values for the sample
    if isinstance(shap_values, list):
        shap_sample = shap_values[0][sample_idx]
    else:
        shap_sample = shap_values[sample_idx]
    
    # Create Explanation object
    exp = shap.Explanation(
        values=shap_sample,
        base_values=explainer.expected_value if hasattr(explainer, 'expected_value') else 0,
        data=X.iloc[sample_idx].values,
        feature_names=feature_names
    )
    
    shap.waterfall_plot(exp, max_display=max_display)

def plot_shap_force(shap_values, X, sample_idx, feature_names):
    """
    Plot SHAP force plot.
    
    Args:
        shap_values: SHAP values
        X: Feature matrix
        sample_idx: Index of sample to explain
        feature_names: Feature names
    """
    if isinstance(shap_values, list):
        shap_sample = shap_values[0][sample_idx]
    else:
        shap_sample = shap_values[sample_idx]
    
    shap.force_plot(
        explainer.expected_value if hasattr(explainer, 'expected_value') else 0,
        shap_sample,
        X.iloc[sample_idx],
        feature_names=feature_names,
        matplotlib=True
    )
```

### SHAP Interaction Values

```python
def compute_shap_interactions(model, X):
    """
    Compute SHAP interaction values.
    
    Args:
        model: Trained model
        X: Feature matrix
    
    Returns:
        np.ndarray: SHAP interaction values
    """
    explainer = shap.TreeExplainer(model)
    shap_interaction = explainer.shap_interaction_values(X)
    return shap_interaction

def get_top_interactions(shap_interaction, feature_names, top_k=10):
    """
    Get top feature interactions.
    
    Args:
        shap_interaction: SHAP interaction values
        feature_names: Feature names
        top_k: Number of top interactions to show
    
    Returns:
        pd.DataFrame: Top interactions
    """
    # Compute interaction strengths
    interactions = []
    for i in range(len(feature_names)):
        for j in range(i+1, len(feature_names)):
            # Average absolute interaction value
            interaction_strength = np.mean(np.abs(shap_interaction[:, i, j]))
            interactions.append({
                'feature1': feature_names[i],
                'feature2': feature_names[j],
                'interaction_strength': interaction_strength
            })
    
    interaction_df = pd.DataFrame(interactions)
    interaction_df = interaction_df.sort_values('interaction_strength', ascending=False)
    
    return interaction_df.head(top_k)

def plot_shap_interaction_summary(shap_interaction, feature_names, top_k=10):
    """
    Plot SHAP interaction summary.
    
    Args:
        shap_interaction: SHAP interaction values
        feature_names: Feature names
        top_k: Number of top interactions to show
    """
    # Get top interactions
    top_interactions = get_top_interactions(shap_interaction, feature_names, top_k)
    
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Create labels
    labels = [f"{row['feature1']} × {row['feature2']}" for _, row in top_interactions.iterrows()]
    
    ax.barh(range(len(labels)), top_interactions['interaction_strength'])
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels)
    ax.set_xlabel('Interaction Strength')
    ax.set_title('Top Feature Interactions')
    ax.invert_yaxis()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig
```

---

## 5. Partial Dependence Plots (PDP)

```python
from sklearn.inspection import partial_dependence, PartialDependenceDisplay

def compute_pdp(model, X, features, grid_resolution=20):
    """
    Compute partial dependence plots.
    
    Args:
        model: Trained model
        X: Feature matrix
        features: Features to compute PDP for
        grid_resolution: Number of grid points
    
    Returns:
        dict: PDP results
    """
    pdp_results = {}
    
    for feature in features:
        pdp = partial_dependence(
            model, X, [feature],
            kind='average',
            grid_resolution=grid_resolution
        )
        pdp_results[feature] = {
            'values': pdp['values'][0],
            'average': pdp['average'][0]
        }
    
    return pdp_results

def plot_pdp(pdp_results, feature_name, figsize=(8, 6)):
    """
    Plot partial dependence plot.
    
    Args:
        pdp_results: PDP results from compute_pdp
        feature_name: Feature to plot
        figsize: Figure size
    """
    fig, ax = plt.subplots(figsize=figsize)
    
    values = pdp_results[feature_name]['values']
    avg = pdp_results[feature_name]['average']
    
    ax.plot(values, avg, linewidth=2)
    ax.fill_between(values, avg - 0.1, avg + 0.1, alpha=0.2)
    
    ax.set_xlabel(feature_name)
    ax.set_ylabel('Partial Dependence')
    ax.set_title(f'Partial Dependence Plot: {feature_name}')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig

def plot_ice(model, X, feature, grid_resolution=20, n_samples=50):
    """
    Plot Individual Conditional Expectation (ICE) plots.
    
    Args:
        model: Trained model
        X: Feature matrix
        feature: Feature to plot
        grid_resolution: Number of grid points
        n_samples: Number of ICE lines to show
    """
    from sklearn.inspection import partial_dependence
    
    pdp = partial_dependence(
        model, X, [feature],
        kind='both',
        grid_resolution=grid_resolution
    )
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Plot PDP
    ax.plot(pdp['values'][0], pdp['average'][0], color='black', linewidth=2, label='PDP')
    
    # Plot ICE lines
    ice_lines = pdp['individual'][0][:n_samples]
    for i in range(min(n_samples, ice_lines.shape[0])):
        ax.plot(pdp['values'][0], ice_lines[i], alpha=0.3, color='blue')
    
    ax.set_xlabel(feature)
    ax.set_ylabel('Prediction')
    ax.set_title(f'ICE Plot: {feature}')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig
```

---

## 6. LIME Explanations

```python
from lime.lime_tabular import LimeTabularExplainer

def create_lime_explainer(X_train, feature_names, mode='classification'):
    """
    Create LIME explainer.
    
    Args:
        X_train: Training data
        feature_names: Feature names
        mode: 'classification' or 'regression'
    
    Returns:
        LimeTabularExplainer: LIME explainer
    """
    explainer = LimeTabularExplainer(
        X_train.values,
        feature_names=feature_names,
        mode=mode,
        discretize_continuous=True,
        verbose=False
    )
    return explainer

def explain_lime_local(explainer, model, X_sample, num_features=10):
    """
    Explain a single prediction using LIME.
    
    Args:
        explainer: LIME explainer
        model: Trained model
        X_sample: Sample to explain
        num_features: Number of features to show
    
    Returns:
        dict: LIME explanation
    """
    # Prediction function
    if hasattr(model, 'predict_proba'):
        def predict_fn(x):
            return model.predict_proba(x)
    else:
        def predict_fn(x):
            return model.predict(x)
    
    explanation = explainer.explain_instance(
        X_sample.iloc[0].values,
        predict_fn,
        num_features=num_features
    )
    
    return explanation

def plot_lime_explanation(explanation, feature_names=None):
    """
    Plot LIME explanation.
    
    Args:
        explanation: LIME explanation object
        feature_names: Feature names (optional)
    """
    explanation.show_in_notebook()
    
    # Get the explanation as a list
    explanation_list = explanation.as_list()
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    features = [item[0] for item in explanation_list]
    values = [item[1] for item in explanation_list]
    
    colors = ['green' if v > 0 else 'red' for v in values]
    ax.barh(range(len(features)), values, color=colors)
    ax.set_yticks(range(len(features)))
    ax.set_yticklabels(features)
    ax.set_xlabel('Contribution to Prediction')
    ax.set_title('LIME Explanation')
    ax.axvline(x=0, color='black', linestyle='-', linewidth=0.5)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig
```

---

## 7. Comprehensive Interpretation Report

```python
class InterpretationReport:
    """
    Generate comprehensive interpretation report.
    """
    
    def __init__(self, model, X_train, X_test, feature_names):
        self.model = model
        self.X_train = X_train
        self.X_test = X_test
        self.feature_names = feature_names
    
    def generate_report(self, output_path=None):
        """
        Generate interpretation report.
        
        Args:
            output_path: Path to save report
        
        Returns:
            str: Report text
        """
        report = []
        report.append("=" * 70)
        report.append("MODEL INTERPRETATION REPORT")
        report.append("=" * 70)
        report.append("")
        
        # 1. Model Summary
        report.append("1. MODEL SUMMARY")
        report.append("-" * 50)
        report.append(f"Model Type: {type(self.model).__name__}")
        report.append(f"Training Samples: {len(self.X_train)}")
        report.append(f"Test Samples: {len(self.X_test)}")
        report.append(f"Number of Features: {len(self.feature_names)}")
        report.append("")
        
        # 2. Global Feature Importance
        report.append("2. GLOBAL FEATURE IMPORTANCE")
        report.append("-" * 50)
        
        # Try different importance methods
        try:
            # Model-based importance
            importance_df = get_tree_importance(self.model, self.feature_names)
            report.append("\nTop 10 Features (Model-based):")
            for i, row in importance_df.head(10).iterrows():
                report.append(f"  {row['feature']}: {row['importance']:.4f}")
        except:
            report.append("  Could not compute model-based importance")
        
        report.append("")
        
        # 3. SHAP Summary
        report.append("3. SHAP ANALYSIS")
        report.append("-" * 50)
        try:
            shap_values, _ = compute_shap_importance(self.model, self.X_test[:100])
            shap_importance = get_shap_global_importance(shap_values, self.feature_names)
            report.append("\nTop 10 Features (SHAP):")
            for i, row in shap_importance.head(10).iterrows():
                report.append(f"  {row['feature']}: {row['shap_importance']:.4f}")
        except:
            report.append("  Could not compute SHAP values")
        
        report.append("")
        
        # 4. Key Insights
        report.append("4. KEY INSIGHTS")
        report.append("-" * 50)
        
        # Analyze importance for insights
        try:
            top_features = importance_df.head(3)['feature'].tolist()
            report.append(f"Most important features: {', '.join(top_features)}")
            
            # Check for features with near-zero importance
            zero_features = importance_df[importance_df['importance'] < 0.001]['feature'].tolist()
            if zero_features:
                report.append(f"Features with minimal importance: {', '.join(zero_features[:5])}")
        except:
            pass
        
        report.append("")
        
        # 5. Recommendations
        report.append("5. RECOMMENDATIONS")
        report.append("-" * 50)
        
        # Based on feature importance
        try:
            top_features = importance_df.head(5)['feature'].tolist()
            report.append(f"Focus feature engineering on: {', '.join(top_features)}")
            
            # Features to consider removing
            bottom_features = importance_df.tail(5)['feature'].tolist()
            if bottom_features:
                report.append(f"Consider removing: {', '.join(bottom_features)}")
        except:
            pass
        
        report.append("\n" + "=" * 70)
        
        report_text = "\n".join(report)
        
        if output_path:
            with open(output_path, 'w') as f:
                f.write(report_text)
            print(f"Report saved to: {output_path}")
        
        return report_text
```

---

## Quick Reference: Feature Importance

### Importance Methods Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│  METHOD          │ SPEED    │ INTERPRETABLE  │ MODEL-AGNOSTIC │
├──────────────────┼──────────┼────────────────┼─────────────────┤
│  Model-based     │ Fast     │ Yes            │ No              │
│  Permutation     │ Medium   │ Yes            │ Yes             │
│  SHAP            │ Slow     │ Yes            │ Yes             │
│  PDP/ICE         │ Slow     │ Yes            │ Yes             │
│  LIME            │ Medium   │ Yes            │ Yes             │
└─────────────────────────────────────────────────────────────────┘
```

### SHAP Plot Types

```
┌─────────────────────────────────────────────────────────────────┐
│  PLOT TYPE     │ BEST FOR                                      │
├────────────────┼───────────────────────────────────────────────┤
│  Summary Bar   │ Global importance ranking                     │
│  Summary Dot   │ Global importance + direction                 │
│  Waterfall     │ Individual prediction explanation             │
│  Force         │ Interactive individual explanation            │
│  Dependence    │ Feature effect vs feature value               │
│  Interaction   │ Feature interaction effects                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of feature importance and model interpretation. You now understand:

1. **Why importance matters**: Debugging, feature engineering, communication
2. **Model-based importance**: Tree-based, linear models
3. **Permutation importance**: Model-agnostic importance
4. **SHAP values**: Global and local explanations, interactions
5. **Partial dependence**: PDP and ICE plots
6. **LIME**: Local explanations
7. **Comprehensive reports**: Bringing it all together

**Next Steps:**
1. Practice with SHAP on your models
2. Create interpretation reports
3. Use importance for feature selection
4. Explain predictions to stakeholders
5. Proceed to Part 1 of the series

---

*End of Primer 15*
