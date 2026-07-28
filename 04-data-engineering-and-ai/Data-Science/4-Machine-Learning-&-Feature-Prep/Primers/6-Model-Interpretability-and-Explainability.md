# Primer 6: Model Interpretability and Explainability

## Overview

This primer provides a comprehensive introduction to model interpretability and explainability—critical skills for building trust in ML systems, debugging models, and satisfying regulatory requirements. Understanding these concepts will help you explain your model's decisions to stakeholders, identify biases, and improve model performance.

---

## 1. Why Interpretability Matters

### The Interpretability Spectrum

```
┌─────────────────────────────────────────────────────────────────┐
│              INTERPRETABILITY SPECTRUM                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Simple ←─────────────────────────────────────────→ Complex     │
│                                                                 │
│  Linear        Decision   Random    XGBoost     Deep           │
│  Regression    Tree       Forest               Learning        │
│  ⭐⭐⭐⭐⭐      ⭐⭐⭐⭐     ⭐⭐⭐     ⭐⭐         ⭐             │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  High        │  │  Medium     │  │  Low        │            │
│  │  Interp.     │  │  Interp.    │  │  Interp.    │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why We Need Interpretability

| Reason | Description | Example |
|--------|-------------|---------|
| **Trust** | Build confidence in model decisions | Medical diagnosis |
| **Compliance** | Meet regulatory requirements | Fair lending, GDPR |
| **Debugging** | Identify model issues | Feature importance, bias |
| **Improvement** | Guide feature engineering | Understanding relationships |
| **Communication** | Explain to stakeholders | Business decisions |
| **Fairness** | Detect and mitigate bias | Demographic parity |

### Interpretability vs Explainability

```
┌─────────────────────────────────────────────────────────────────┐
│              INTERPRETABILITY VS EXPLAINABILITY                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   Interpretability║  ║   Explainability  ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
│  • Model is inherently │  • Model can be explained after       │
│    understandable     │    the fact                           │
│                                                                 │
│  • Simple models      │  • Complex models with explanation    │
│    (Linear, Trees)    │    tools (LIME, SHAP)                 │
│                                                                 │
│  • Understand the     │  • Understand individual predictions  │
│    entire model       │                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Global Interpretability

Global interpretability answers: **How does the model work overall?**

### Feature Importance

```python
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.inspection import permutation_importance

# Train model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Method 1: Built-in feature importance (Gini)
importance_gini = pd.DataFrame({
    'feature': X_train.columns,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)

print("Gini Importance:")
print(importance_gini)

# Method 2: Permutation importance
result = permutation_importance(model, X_test, y_test, n_repeats=10, random_state=42)
importance_perm = pd.DataFrame({
    'feature': X_train.columns,
    'importance': result.importances_mean,
    'std': result.importances_std
}).sort_values('importance', ascending=False)

print("\nPermutation Importance:")
print(importance_perm)

# Plot feature importance
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))

# Gini importance
importance_gini.head(10).plot(kind='barh', x='feature', y='importance', ax=ax1)
ax1.set_title('Gini Importance')

# Permutation importance
importance_perm.head(10).plot(kind='barh', x='feature', y='importance', xerr='std', ax=ax2)
ax2.set_title('Permutation Importance')

plt.tight_layout()
plt.show()
```

### Partial Dependence Plots (PDP)

Partial dependence plots show how a feature affects predictions on average.

```python
from sklearn.inspection import partial_dependence
import matplotlib.pyplot as plt

# Create partial dependence plots
features = ['age', 'income', 'tenure']
fig, axes = plt.subplots(1, 3, figsize=(15, 4))

for idx, feature in enumerate(features):
    pdp = partial_dependence(
        model, X_train, [feature],
        kind='average', grid_resolution=20
    )
    
    ax = axes[idx]
    ax.plot(pdp['values'][0], pdp['average'][0])
    ax.set_xlabel(feature)
    ax.set_ylabel('Partial Dependence')
    ax.set_title(f'PDP for {feature}')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

### SHAP Summary Plot (Global)

```python
import shap

# Create SHAP explainer
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)

# Summary plot (global importance)
shap.summary_plot(shap_values, X_test, plot_type="bar")

# Detailed summary
shap.summary_plot(shap_values, X_test)

# Force plot for average prediction
shap.force_plot(explainer.expected_value, shap_values.mean(0), X_test.iloc[0])
```

### LIME Global Explanation

```python
from lime.lime_tabular import LimeTabularExplainer

# Create LIME explainer
explainer = LimeTabularExplainer(
    X_train.values,
    feature_names=X_train.columns,
    class_names=['No Churn', 'Churn'],
    mode='classification'
)

# Explanation for a sample
exp = explainer.explain_instance(
    X_test.iloc[0].values,
    model.predict_proba,
    num_features=10
)

# Show explanation
exp.show_in_notebook()
```

### Model Visualization (Decision Trees)

```python
from sklearn.tree import DecisionTreeClassifier, plot_tree

# Train shallow tree for visualization
tree = DecisionTreeClassifier(max_depth=3, random_state=42)
tree.fit(X_train, y_train)

# Plot tree
plt.figure(figsize=(20, 10))
plot_tree(
    tree,
    feature_names=X_train.columns,
    class_names=['No Churn', 'Churn'],
    filled=True,
    rounded=True,
    fontsize=10
)
plt.show()

# Text representation
from sklearn.tree import export_text
text_repr = export_text(tree, feature_names=list(X_train.columns))
print(text_repr)
```

---

## 3. Local Interpretability

Local interpretability answers: **Why did the model make this specific prediction?**

### SHAP Force Plot (Local)

```python
import shap

# Force plot for a single prediction
shap.force_plot(
    explainer.expected_value,
    shap_values[0],
    X_test.iloc[0],
    matplotlib=True
)

# Waterfall plot
shap.waterfall_plot(
    shap.Explanation(
        values=shap_values[0],
        base_values=explainer.expected_value,
        data=X_test.iloc[0].values,
        feature_names=X_test.columns
    )
)

# Decision plot
shap.decision_plot(
    explainer.expected_value,
    shap_values[0],
    X_test.iloc[0]
)
```

### LIME Local Explanation

```python
from lime.lime_tabular import LimeTabularExplainer

# Create explainer
explainer = LimeTabularExplainer(
    X_train.values,
    feature_names=X_train.columns,
    class_names=['No Churn', 'Churn'],
    mode='classification'
)

# Explain a prediction
exp = explainer.explain_instance(
    X_test.iloc[1].values,
    model.predict_proba,
    num_features=8
)

# Show explanation
exp.show_in_notebook()
print(exp.as_list())
```

### Individual Conditional Expectation (ICE) Plots

```python
from sklearn.inspection import partial_dependence

# ICE plot for a feature
features = ['age']
pdp = partial_dependence(
    model, X_train, features,
    kind='both', grid_resolution=20
)

fig, ax = plt.subplots(figsize=(10, 6))

# PDP line
ax.plot(pdp['values'][0], pdp['average'][0], color='black', linewidth=2, label='PDP')

# Individual ICE lines
for i in range(min(10, len(X_train))):
    ax.plot(pdp['values'][0], pdp['individual'][0][i], alpha=0.3, color='blue')

ax.set_xlabel('Age')
ax.set_ylabel('Prediction')
ax.set_title('ICE Plot: Age')
ax.legend()
ax.grid(True, alpha=0.3)
plt.show()
```

---

## 4. Model-Specific Interpretability

### Linear Models

```python
from sklearn.linear_model import LogisticRegression

# Train linear model
linear_model = LogisticRegression()
linear_model.fit(X_train, y_train)

# Coefficients
coefficients = pd.DataFrame({
    'feature': X_train.columns,
    'coefficient': linear_model.coef_[0]
}).sort_values('coefficient', ascending=False)

print("Coefficients:")
print(coefficients)

# Interpretation
for i, row in coefficients.iterrows():
    direction = "increases" if row['coefficient'] > 0 else "decreases"
    print(f"{row['feature']}: {direction} churn probability by {abs(row['coefficient']):.3f}")
```

### Decision Trees

```python
from sklearn.tree import DecisionTreeClassifier, plot_tree

# Train tree
tree = DecisionTreeClassifier(max_depth=4, random_state=42)
tree.fit(X_train, y_train)

# Feature importance
importance_tree = pd.DataFrame({
    'feature': X_train.columns,
    'importance': tree.feature_importances_
}).sort_values('importance', ascending=False)

print("Tree Feature Importance:")
print(importance_tree)

# Path explanation for a prediction
def explain_tree_prediction(tree, X, feature_names):
    """Get decision path for a prediction."""
    path = tree.decision_path(X)
    leaf = tree.apply(X)
    
    node_indicator = path.toarray()
    feature = tree.tree_.feature
    threshold = tree.tree_.threshold
    
    explanation = []
    for i, node in enumerate(node_indicator[0]):
        if node == 1:
            if feature[i] >= 0:
                explanation.append({
                    'feature': feature_names[feature[i]],
                    'threshold': threshold[i],
                    'node': i
                })
    return explanation

# Explain first prediction
explanation = explain_tree_prediction(tree, X_test.iloc[0:1], X_train.columns)
for step in explanation:
    print(f"Feature: {step['feature']}, Threshold: {step['threshold']:.2f}")
```

### XGBoost Feature Importance

```python
import xgboost as xgb

# Train XGBoost model
xgb_model = xgb.XGBClassifier(n_estimators=100, random_state=42)
xgb_model.fit(X_train, y_train)

# Multiple importance types
importances = {
    'weight': xgb_model.get_booster().get_score(importance_type='weight'),
    'gain': xgb_model.get_booster().get_score(importance_type='gain'),
    'cover': xgb_model.get_booster().get_score(importance_type='cover')
}

# Convert to DataFrame
for name, importance in importances.items():
    df = pd.DataFrame({
        'feature': list(importance.keys()),
        'importance': list(importance.values())
    }).sort_values('importance', ascending=False)
    print(f"\n{name.upper()} Importance:")
    print(df.head())
```

---

## 5. Counterfactual Explanations

Counterfactual explanations answer: **What would need to change for the prediction to be different?**

```python
import dice_ml
from dice_ml import Dice

# Create Data Object
dice_data = dice_ml.Data(
    dataframe=pd.concat([X_train, y_train], axis=1),
    continuous_features=['age', 'income', 'tenure', 'monthly_charges'],
    outcome_name='churn'
)

# Create Model Object
dice_model = dice_ml.Model(model=model, backend='sklearn')

# Create DICE explainer
exp = Dice(dice_data, dice_model, method='genetic')

# Generate counterfactuals
query = X_test.iloc[0:1]
cf = exp.generate_counterfactuals(
    query,
    total_CFs=5,
    desired_class='opposite'
)

# Show counterfactuals
cf.visualize_as_dataframe()
print(cf.cf_examples_list[0].final_cfs_df)
```

---

## 6. Trust, Fairness, and Bias

### Bias Detection

```python
from fairlearn.metrics import demographic_parity_difference, equalized_odds_difference

# Sensitive features
sensitive_features = X_test['gender']

# Performance metrics by group
def evaluate_by_group(y_true, y_pred, sensitive_feature):
    """Evaluate performance across groups."""
    groups = sensitive_feature.unique()
    results = {}
    
    for group in groups:
        mask = sensitive_feature == group
        results[group] = {
            'accuracy': accuracy_score(y_true[mask], y_pred[mask]),
            'precision': precision_score(y_true[mask], y_pred[mask], zero_division=0),
            'recall': recall_score(y_true[mask], y_pred[mask], zero_division=0),
            'f1': f1_score(y_true[mask], y_pred[mask], zero_division=0)
        }
    
    return results

# Get predictions
y_pred = model.predict(X_test)

# Evaluate by group
group_results = evaluate_by_group(y_test, y_pred, sensitive_features)

print("Performance by Group:")
for group, metrics in group_results.items():
    print(f"\n{group}:")
    for metric, value in metrics.items():
        print(f"  {metric}: {value:.3f}")
```

### Fairness Metrics

```python
# Fairness metrics
from fairlearn.metrics import (
    demographic_parity_difference,
    equalized_odds_difference,
    false_negative_rate,
    false_positive_rate
)

# Demographic parity
dp_diff = demographic_parity_difference(
    y_true=y_test,
    y_pred=y_pred,
    sensitive_features=sensitive_features
)

# Equalized odds
eo_diff = equalized_odds_difference(
    y_true=y_test,
    y_pred=y_pred,
    sensitive_features=sensitive_features
)

print(f"Demographic Parity Difference: {dp_diff:.3f}")
print(f"Equalized Odds Difference: {eo_diff:.3f}")
```

### Mitigating Bias

```python
from fairlearn.reductions import ExponentiatedGradient, DemographicParity

# Create mitigation model
mitigator = ExponentiatedGradient(
    estimator=RandomForestClassifier(random_state=42),
    constraints=DemographicParity(),
    random_state=42
)

# Train with fairness constraint
mitigator.fit(X_train, y_train, sensitive_features=sensitive_features_train)

# Predict
y_pred_mitigated = mitigator.predict(X_test)

# Compare fairness
dp_diff_original = demographic_parity_difference(y_test, y_pred, sensitive_features)
dp_diff_mitigated = demographic_parity_difference(y_test, y_pred_mitigated, sensitive_features)

print(f"Original DP: {dp_diff_original:.3f}")
print(f"Mitigated DP: {dp_diff_mitigated:.3f}")
```

---

## 7. Interpretability Tools Summary

| Tool | Type | Best For | Complexity |
|------|------|----------|------------|
| **Feature Importance** | Global | Any model | ⭐ |
| **PDP/ICE** | Global | Any model | ⭐⭐ |
| **SHAP** | Global + Local | Any model | ⭐⭐⭐ |
| **LIME** | Local | Any model | ⭐⭐⭐ |
| **DICE** | Local | Any model | ⭐⭐⭐ |
| **Decision Tree** | Global | Tree models | ⭐ |
| **Coefficients** | Global | Linear models | ⭐ |

### Implementation Quick Reference

```python
# SHAP (most versatile)
import shap
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)
shap.summary_plot(shap_values, X_test)

# LIME (local explanations)
from lime.lime_tabular import LimeTabularExplainer
explainer = LimeTabularExplainer(X_train, feature_names=features)
exp = explainer.explain_instance(X_test[0], model.predict_proba)

# Partial Dependence
from sklearn.inspection import partial_dependence
pdp = partial_dependence(model, X_train, ['feature'])

# Permutation Importance
from sklearn.inspection import permutation_importance
result = permutation_importance(model, X_test, y_test)
```

---

## Conclusion

This primer covers the essential concepts of model interpretability and explainability. You now understand:

1. **Why interpretability matters**: Trust, compliance, debugging
2. **Global interpretability**: Feature importance, PDP, summary plots
3. **Local interpretability**: SHAP, LIME, counterfactuals
4. **Model-specific tools**: Linear coefficients, tree paths
5. **Fairness and bias**: Detection and mitigation
6. **Tool selection**: Choosing the right tool for the job

**Next Steps:**
1. Practice with SHAP on your models
2. Use LIME for local explanations
3. Implement bias detection
4. Create interpretability reports
5. Proceed to Part 1 of the series

---

*End of Primer 6*
