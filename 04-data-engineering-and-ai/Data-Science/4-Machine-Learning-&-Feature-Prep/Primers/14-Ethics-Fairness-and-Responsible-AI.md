# Primer 14: Ethics, Fairness, and Responsible AI

## Overview

This primer provides a comprehensive introduction to ethics, fairness, and responsible AI—critical considerations for building machine learning systems that are trustworthy, equitable, and beneficial to society. Understanding these concepts is essential for developing ML systems that don't inadvertently harm individuals or groups.

---

## 1. Why Responsible AI Matters

### The Impact of AI Decisions

```
┌─────────────────────────────────────────────────────────────────┐
│              AI DECISIONS AFFECT PEOPLE'S LIVES                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Healthcare                                                     │
│  └── Diagnosis, treatment recommendations, insurance          │
│                                                                 │
│  Finance                                                        │
│  └── Credit scoring, loan approvals, fraud detection          │
│                                                                 │
│  Employment                                                     │
│  └── Hiring, promotion, performance evaluation                │
│                                                                 │
│  Criminal Justice                                               │
│  └── Risk assessment, sentencing, parole decisions            │
│                                                                 │
│  Education                                                      │
│  └── Admissions, grading, personalized learning               │
│                                                                 │
│  Social Services                                                │
│  └── Welfare eligibility, child protection, resource allocation│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The AI Ethics Framework

```
┌─────────────────────────────────────────────────────────────────┐
│              RESPONSIBLE AI FRAMEWORK                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║     Fairness      ║  ║   Accountability  ║                  │
│  ║  No discrimination║  ║  Clear ownership  ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   Transparency    ║  ║    Privacy        ║                  │
│  ║  Explainable AI   ║  ║  Data protection  ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║    Reliability    ║  ║     Safety        ║                  │
│  ║  Robust systems   ║  ║  No harm to users ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Fairness in Machine Learning

### Types of Fairness

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPES OF FAIRNESS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Demographic Parity (Statistical Parity)                       │
│  └── Equal positive rates across groups                        │
│      P(ŷ=1|A=a) = P(ŷ=1|A=b)                                  │
│                                                                 │
│  Equal Opportunity                                             │
│  └── Equal true positive rates across groups                   │
│      P(ŷ=1|Y=1, A=a) = P(ŷ=1|Y=1, A=b)                       │
│                                                                 │
│  Equalized Odds                                                 │
│  └── Equal TPR and FPR across groups                           │
│      P(ŷ=1|Y=y, A=a) = P(ŷ=1|Y=y, A=b)                       │
│                                                                 │
│  Individual Fairness                                           │
│  └── Similar individuals get similar outcomes                  │
│      d(x_i, x_j) ≤ ε → |ŷ_i - ŷ_j| ≤ δ                       │
│                                                                 │
│  Counterfactual Fairness                                       │
│  └── Decisions don't depend on protected attributes            │
│      ŷ = f(x) where x doesn't include A                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Fairness Metrics Implementation

```python
import numpy as np
import pandas as pd
from sklearn.metrics import confusion_matrix

class FairnessMetrics:
    """
    Compute fairness metrics for model predictions.
    """
    
    def __init__(self, y_true, y_pred, sensitive_attributes):
        """
        Initialize fairness metrics calculator.
        
        Args:
            y_true: True labels
            y_pred: Predicted labels
            sensitive_attributes: Dict of attribute_name -> attribute_values
        """
        self.y_true = np.array(y_true)
        self.y_pred = np.array(y_pred)
        self.sensitive_attributes = sensitive_attributes
    
    def demographic_parity_difference(self, attribute):
        """
        Compute demographic parity difference.
        
        Returns:
            float: Maximum difference in positive rates across groups
        """
        groups = self.sensitive_attributes[attribute]
        unique_groups = np.unique(groups)
        
        positive_rates = {}
        for group in unique_groups:
            mask = groups == group
            positive_rates[group] = np.mean(self.y_pred[mask])
        
        return max(positive_rates.values()) - min(positive_rates.values())
    
    def equalized_odds_difference(self, attribute):
        """
        Compute equalized odds difference.
        
        Returns:
            float: Maximum difference in TPR and FPR across groups
        """
        groups = self.sensitive_attributes[attribute]
        unique_groups = np.unique(groups)
        
        tprs = {}
        fprs = {}
        
        for group in unique_groups:
            mask = groups == group
            y_true_group = self.y_true[mask]
            y_pred_group = self.y_pred[mask]
            
            cm = confusion_matrix(y_true_group, y_pred_group)
            tn, fp, fn, tp = cm.ravel()
            
            tprs[group] = tp / (tp + fn) if (tp + fn) > 0 else 0
            fprs[group] = fp / (fp + tn) if (fp + tn) > 0 else 0
        
        tpr_diff = max(tprs.values()) - min(tprs.values())
        fpr_diff = max(fprs.values()) - min(fprs.values())
        
        return max(tpr_diff, fpr_diff)
    
    def equal_opportunity_difference(self, attribute):
        """
        Compute equal opportunity difference.
        
        Returns:
            float: Maximum difference in TPR across groups
        """
        groups = self.sensitive_attributes[attribute]
        unique_groups = np.unique(groups)
        
        tprs = {}
        
        for group in unique_groups:
            mask = groups == group
            y_true_group = self.y_true[mask]
            y_pred_group = self.y_pred[mask]
            
            # Only consider positive cases
            pos_mask = y_true_group == 1
            if np.sum(pos_mask) == 0:
                tprs[group] = 1.0  # No positive cases, treat as perfect
            else:
                tprs[group] = np.mean(y_pred_group[pos_mask])
        
        return max(tprs.values()) - min(tprs.values())
    
    def disparate_impact(self, attribute):
        """
        Compute disparate impact ratio.
        
        Returns:
            float: Ratio of positive rates (min/max), should be > 0.8
        """
        groups = self.sensitive_attributes[attribute]
        unique_groups = np.unique(groups)
        
        positive_rates = {}
        for group in unique_groups:
            mask = groups == group
            positive_rates[group] = np.mean(self.y_pred[mask])
        
        min_rate = min(positive_rates.values())
        max_rate = max(positive_rates.values())
        
        if min_rate == 0:
            return 0.0
        
        return min_rate / max_rate
    
    def get_all_metrics(self):
        """
        Get all fairness metrics.
        
        Returns:
            dict: All fairness metrics
        """
        metrics = {}
        
        for attr in self.sensitive_attributes.keys():
            metrics[attr] = {
                'demographic_parity_difference': self.demographic_parity_difference(attr),
                'equal_opportunity_difference': self.equal_opportunity_difference(attr),
                'equalized_odds_difference': self.equalized_odds_difference(attr),
                'disparate_impact': self.disparate_impact(attr)
            }
        
        return metrics
    
    def generate_report(self):
        """
        Generate fairness report.
        
        Returns:
            str: Formatted report
        """
        metrics = self.get_all_metrics()
        
        report = []
        report.append("=" * 60)
        report.append("FAIRNESS REPORT")
        report.append("=" * 60)
        
        for attr, attr_metrics in metrics.items():
            report.append(f"\nProtected Attribute: {attr}")
            report.append("-" * 40)
            report.append(f"  Demographic Parity Difference: {attr_metrics['demographic_parity_difference']:.4f}")
            report.append(f"  Equal Opportunity Difference: {attr_metrics['equal_opportunity_difference']:.4f}")
            report.append(f"  Equalized Odds Difference: {attr_metrics['equalized_odds_difference']:.4f}")
            report.append(f"  Disparate Impact: {attr_metrics['disparate_impact']:.4f}")
            
            # Interpretation
            di = attr_metrics['disparate_impact']
            if di < 0.8:
                report.append("  ⚠️  Disparate impact detected (should be > 0.8)")
            elif di < 0.95:
                report.append("  ⚠️  Slight disparate impact detected")
            else:
                report.append("  ✅ No significant disparate impact")
        
        report.append("\n" + "=" * 60)
        
        return "\n".join(report)

# Example usage
fairness = FairnessMetrics(
    y_true=y_test,
    y_pred=y_pred,
    sensitive_attributes={
        'gender': gender_test,
        'age_group': age_group_test,
        'race': race_test
    }
)

print(fairness.generate_report())
```

### Mitigating Bias

```python
from fairlearn.reductions import ExponentiatedGradient, DemographicParity, EqualizedOdds
from fairlearn.postprocessing import ThresholdOptimizer

class BiasMitigator:
    """
    Mitigate bias in machine learning models.
    """
    
    def __init__(self, model, sensitive_features, method='reductions'):
        """
        Initialize bias mitigator.
        
        Args:
            model: Base model
            sensitive_features: Sensitive feature values
            method: Mitigation method ('reductions' or 'postprocessing')
        """
        self.model = model
        self.sensitive_features = sensitive_features
        self.method = method
    
    def fit(self, X, y):
        """
        Fit the bias-mitigated model.
        
        Args:
            X: Feature matrix
            y: Target vector
        """
        if self.method == 'reductions':
            # Exponentiated Gradient reduction
            self.mitigated_model = ExponentiatedGradient(
                estimator=self.model,
                constraints=DemographicParity(),
                random_state=42
            )
            self.mitigated_model.fit(X, y, sensitive_features=self.sensitive_features)
            
        elif self.method == 'postprocessing':
            # Threshold optimization
            self.mitigated_model = ThresholdOptimizer(
                estimator=self.model,
                constraints='demographic_parity',
                random_state=42
            )
            self.mitigated_model.fit(X, y, sensitive_features=self.sensitive_features)
        
        return self
    
    def predict(self, X):
        """
        Make predictions.
        
        Args:
            X: Feature matrix
        
        Returns:
            np.ndarray: Predictions
        """
        if self.method == 'reductions':
            return self.mitigated_model.predict(X)
        elif self.method == 'postprocessing':
            return self.mitigated_model.predict(X, sensitive_features=self.sensitive_features)

# Example usage
from sklearn.ensemble import RandomForestClassifier

mitigator = BiasMitigator(
    model=RandomForestClassifier(random_state=42),
    sensitive_features=gender_train,
    method='reductions'
)

mitigator.fit(X_train, y_train)
y_pred_fair = mitigator.predict(X_test)
```

---

## 3. Explainability and Transparency

### Model Explanations

```python
import shap
import lime
from lime.lime_tabular import LimeTabularExplainer
import matplotlib.pyplot as plt

class ModelExplainer:
    """
    Provide explanations for model predictions.
    """
    
    def __init__(self, model, X_train, feature_names, mode='classification'):
        """
        Initialize explainer.
        
        Args:
            model: Trained model
            X_train: Training data
            feature_names: Feature names
            mode: 'classification' or 'regression'
        """
        self.model = model
        self.X_train = X_train
        self.feature_names = feature_names
        self.mode = mode
        
        # Initialize SHAP explainer
        if mode == 'classification':
            self.shap_explainer = shap.TreeExplainer(model)
        else:
            self.shap_explainer = shap.TreeExplainer(model)
        
        # Initialize LIME explainer
        self.lime_explainer = LimeTabularExplainer(
            X_train.values,
            feature_names=feature_names,
            mode=mode,
            discretize_continuous=True
        )
    
    def explain_shap(self, X_sample, plot_type='summary'):
        """
        Get SHAP explanations.
        
        Args:
            X_sample: Sample to explain
            plot_type: 'summary', 'bar', 'waterfall', 'force'
        """
        shap_values = self.shap_explainer.shap_values(X_sample)
        
        if plot_type == 'summary':
            shap.summary_plot(shap_values, X_sample, feature_names=self.feature_names)
        elif plot_type == 'bar':
            shap.summary_plot(shap_values, X_sample, plot_type="bar", feature_names=self.feature_names)
        elif plot_type == 'waterfall':
            shap.waterfall_plot(
                shap.Explanation(
                    values=shap_values[0] if isinstance(shap_values, list) else shap_values,
                    base_values=self.shap_explainer.expected_value,
                    data=X_sample.values[0],
                    feature_names=self.feature_names
                )
            )
        elif plot_type == 'force':
            shap.force_plot(
                self.shap_explainer.expected_value,
                shap_values[0] if isinstance(shap_values, list) else shap_values,
                X_sample.iloc[0],
                feature_names=self.feature_names,
                matplotlib=True
            )
        
        return shap_values
    
    def explain_lime(self, X_sample, num_features=10):
        """
        Get LIME explanations.
        
        Args:
            X_sample: Sample to explain
            num_features: Number of features to show
        """
        if self.mode == 'classification':
            def predict_fn(x):
                return self.model.predict_proba(x)
        else:
            def predict_fn(x):
                return self.model.predict(x)
        
        explanation = self.lime_explainer.explain_instance(
            X_sample.iloc[0].values,
            predict_fn,
            num_features=num_features
        )
        
        explanation.show_in_notebook()
        return explanation
    
    def generate_report(self, X_sample):
        """
        Generate comprehensive explanation report.
        
        Args:
            X_sample: Sample to explain
        """
        report = []
        report.append("=" * 60)
        report.append("MODEL EXPLANATION REPORT")
        report.append("=" * 60)
        
        # Model output
        if self.mode == 'classification':
            proba = self.model.predict_proba(X_sample)[0]
            pred = np.argmax(proba)
            report.append(f"\nPrediction: Class {pred} (Probability: {proba[pred]:.3f})")
        else:
            pred = self.model.predict(X_sample)[0]
            report.append(f"\nPrediction: {pred:.3f}")
        
        # SHAP summary
        report.append("\nTop 5 Features (SHAP):")
        shap_values = self.shap_explainer.shap_values(X_sample)
        if isinstance(shap_values, list):
            shap_values = shap_values[0]
        
        shap_df = pd.DataFrame({
            'feature': self.feature_names,
            'shap_value': shap_values[0] if len(shap_values.shape) > 1 else shap_values
        }).sort_values('shap_value', key=abs, ascending=False)
        
        for i, row in shap_df.head(5).iterrows():
            direction = "increases" if row['shap_value'] > 0 else "decreases"
            report.append(f"  {row['feature']}: {direction} prediction by {abs(row['shap_value']):.3f}")
        
        return "\n".join(report)
```

### Model Cards

```python
class ModelCard:
    """
    Generate model cards for documentation.
    """
    
    def __init__(self, model, model_name, version, training_data, target):
        self.model = model
        self.model_name = model_name
        self.version = version
        self.training_data = training_data
        self.target = target
    
    def generate_card(self, metrics, limitations=None, ethical_considerations=None):
        """
        Generate model card.
        
        Args:
            metrics: Performance metrics
            limitations: Model limitations
            ethical_considerations: Ethical considerations
        
        Returns:
            str: Model card markdown
        """
        card = []
        card.append(f"# Model Card: {self.model_name}")
        card.append(f"Version: {self.version}")
        card.append("")
        
        card.append("## Model Details")
        card.append(f"- Model Type: {self.model.__class__.__name__}")
        card.append(f"- Target: {self.target}")
        card.append(f"- Training Data Shape: {self.training_data.shape}")
        card.append("")
        
        card.append("## Performance")
        for metric_name, value in metrics.items():
            card.append(f"- {metric_name}: {value:.4f}")
        card.append("")
        
        card.append("## Limitations")
        if limitations:
            for limitation in limitations:
                card.append(f"- {limitation}")
        else:
            card.append("- No limitations specified")
        card.append("")
        
        card.append("## Ethical Considerations")
        if ethical_considerations:
            for consideration in ethical_considerations:
                card.append(f"- {consideration}")
        else:
            card.append("- No ethical considerations specified")
        card.append("")
        
        card.append("## Fairness")
        card.append("- Fairness analysis should be conducted before deployment")
        card.append("- Monitor for disparate impact in production")
        
        return "\n".join(card)
```

---

## 4. Privacy and Data Protection

### Differential Privacy

```python
class DifferentialPrivacy:
    """
    Add differential privacy to ML pipelines.
    """
    
    def __init__(self, epsilon=1.0, delta=1e-5):
        """
        Initialize differential privacy.
        
        Args:
            epsilon: Privacy budget
            delta: Failure probability
        """
        self.epsilon = epsilon
        self.delta = delta
    
    def add_noise_to_gradient(self, gradient, sensitivity=1.0):
        """
        Add noise to gradients for DP-SGD.
        
        Args:
            gradient: Gradient values
            sensitivity: L2 sensitivity
        
        Returns:
            np.ndarray: Noisy gradient
        """
        import numpy as np
        
        # Scale noise based on privacy budget
        noise_scale = sensitivity * np.sqrt(2 * np.log(1.25 / self.delta)) / self.epsilon
        noise = np.random.normal(0, noise_scale, gradient.shape)
        
        return gradient + noise
    
    def clip_gradient(self, gradient, clipping_norm=1.0):
        """
        Clip gradients to bound sensitivity.
        
        Args:
            gradient: Gradient values
            clipping_norm: L2 norm clipping threshold
        
        Returns:
            np.ndarray: Clipped gradient
        """
        norm = np.linalg.norm(gradient)
        if norm > clipping_norm:
            gradient = gradient * clipping_norm / norm
        return gradient
    
    def dp_aggregate(self, data, sensitivity=1.0):
        """
        Compute DP aggregate.
        
        Args:
            data: Data to aggregate
            sensitivity: L1 sensitivity
        
        Returns:
            np.ndarray: DP aggregate
        """
        # Compute true aggregate
        aggregate = np.mean(data, axis=0) if len(data.shape) > 1 else np.mean(data)
        
        # Add Laplace noise (for L1 sensitivity)
        noise = np.random.laplace(0, sensitivity / self.epsilon, aggregate.shape)
        
        return aggregate + noise

# Example usage
dp = DifferentialPrivacy(epsilon=0.5, delta=1e-5)
dp_gradient = dp.add_noise_to_gradient(gradient)
```

### Data Anonymization

```python
def anonymize_data(df, sensitive_columns, method='k_anonymity', k=5):
    """
    Anonymize sensitive data.
    
    Args:
        df: DataFrame
        sensitive_columns: Columns to anonymize
        method: 'k_anonymity', 'generalization', 'suppression'
        k: k-anonymity parameter
    
    Returns:
        pd.DataFrame: Anonymized DataFrame
    """
    df_anon = df.copy()
    
    if method == 'k_anonymity':
        # Implement k-anonymity (simplified)
        for col in sensitive_columns:
            if df_anon[col].dtype == 'object':
                # Generalize text
                df_anon[col] = df_anon[col].apply(lambda x: x[0] if len(x) > 0 else '')
            else:
                # Bin numeric values
                df_anon[col] = pd.cut(
                    df_anon[col],
                    bins=k,
                    labels=[f'range_{i}' for i in range(k)]
                )
    
    elif method == 'suppression':
        # Suppress sensitive values
        for col in sensitive_columns:
            df_anon[col] = df_anon[col].apply(lambda x: '*' * len(str(x)))
    
    elif method == 'generalization':
        # Generalize values
        for col in sensitive_columns:
            if df_anon[col].dtype == 'object':
                df_anon[col] = df_anon[col].apply(lambda x: x[:3] + '***')
            else:
                df_anon[col] = df_anon[col].apply(lambda x: round(x, -1))
    
    return df_anon
```

---

## 5. Responsible AI Checklist

### Pre-Development

```
□ 1. Define problem and use cases
□ 2. Identify stakeholders and affected groups
□ 3. Assess potential harms and benefits
□ 4. Determine fairness criteria
□ 5. Establish ethical guidelines
□ 6. Plan for transparency and explainability
□ 7. Consider privacy implications
□ 8. Ensure diverse team input
```

### Development

```
□ 1. Collect representative data
□ 2. Check for data biases
□ 3. Document data sources and limitations
□ 4. Use fairness metrics
□ 5. Implement bias mitigation
□ 6. Create model explanations
□ 7. Test for edge cases
□ 8. Document model limitations
```

### Deployment

```
□ 1. Conduct ethical review
□ 2. Create model card
□ 3. Set up monitoring for bias
□ 4. Establish oversight committee
□ 5. Plan for feedback collection
□ 6. Create appeals process
□ 7. Set up incident response
□ 8. Schedule regular audits
```

---

## Quick Reference: Responsible AI

### Fairness Metrics Thresholds

```
┌─────────────────────────────────────────────────────────────────┐
│  METRIC                    │ ACCEPTABLE  │ NEEDS ATTENTION     │
├────────────────────────────┼─────────────┼─────────────────────┤
│  Disparate Impact          │ > 0.8       │ < 0.8               │
│  Demographic Parity Diff   │ < 0.05      │ > 0.05              │
│  Equal Opportunity Diff    │ < 0.05      │ > 0.05              │
│  Equalized Odds Diff       │ < 0.05      │ > 0.05              │
└─────────────────────────────────────────────────────────────────┘
```

### Ethical AI Principles

```
┌─────────────────────────────────────────────────────────────────┐
│  PRINCIPLE      │ DESCRIPTION                                  │
├─────────────────┼───────────────────────────────────────────────┤
│  Fairness       │ No discrimination or bias                    │
│  Accountability │ Clear ownership and responsibility           │
│  Transparency   │ Explainable and understandable decisions     │
│  Privacy        │ Protect personal data                        │
│  Reliability    │ Robust and consistent performance            │
│  Safety         │ No harm to individuals or society            │
│  Human-centered │ Designed for human well-being                │
│  Sustainability │ Environmentally and socially sustainable     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This primer covers the essential concepts of ethics, fairness, and responsible AI. You now understand:

1. **Why responsible AI matters**: Impact on people's lives
2. **Fairness metrics**: Demographic parity, equal opportunity, equalized odds
3. **Bias mitigation**: Reductions, post-processing
4. **Explainability**: SHAP, LIME, model cards
5. **Privacy**: Differential privacy, anonymization
6. **Responsible AI practices**: Checklist and principles

**Next Steps:**
1. Audit your models for bias
2. Implement fairness metrics
3. Create model cards
4. Consider ethical implications in your work
5. Proceed to Part 1 of the series

---

*End of Primer 14*
