# Primer 11: Production ML Monitoring

## Overview

This primer provides a comprehensive guide to monitoring machine learning models in production. Monitoring is essential for maintaining model performance, detecting issues early, and ensuring business value over time. This primer covers what to monitor, how to monitor it, and how to respond to issues.

---

## 1. Why Monitoring Matters

### The ML Monitoring Challenge

```
┌─────────────────────────────────────────────────────────────────┐
│              WHY MONITORING MATTERS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Models in Production Face Constant Change                     │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Training Time                    │  Production Time    │  │
│  │  ╭──────────╮                     │  ╭──────────╮      │  │
│  │  │  Data    │                     │  │  Data    │      │  │
│  │  │  Today   │                     │  │  Tomorrow│      │  │
│  │  ╰──────────╯                     │  ╰──────────╯      │  │
│  │                                   │                     │  │
│  │  Static Environment               │  Dynamic            │  │
│  │  Controlled                       │  Uncontrolled       │  │
│  │  Well-understood                  │  Evolving           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  WITHOUT MONITORING:                                           │
│  • Model degrades silently                                     │
│  • Business impact unknown                                     │
│  • Hard to debug issues                                        │
│  • Hard to know when to retrain                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### The Monitoring Pyramid

```
                    ┌─────────────────┐
                    │   Business      │
                    │   Metrics       │
                    ├─────────────────┤
                    │   Model         │
                    │   Performance   │
                    ├─────────────────┤
                    │   Data &        │
                    │   Feature Drift │
                    ├─────────────────┤
                    │   System        │
                    │   Health        │
                    ├─────────────────┤
                    │   Infrastructure│
                    └─────────────────┘
```

---

## 2. What to Monitor

### Monitoring Categories

```python
class ModelMonitor:
    """
    Comprehensive model monitoring system.
    """
    
    def __init__(self, config):
        self.config = config
        self.metrics = {
            'system': [],
            'data': [],
            'model': [],
            'business': []
        }
    
    def collect_system_metrics(self):
        """Collect system health metrics."""
        import psutil
        import time
        
        return {
            'cpu_usage': psutil.cpu_percent(),
            'memory_usage': psutil.virtual_memory().percent,
            'disk_usage': psutil.disk_usage('/').percent,
            'latency': 0.0,  # Measure from recent requests
            'request_rate': 0.0,  # Requests per second
            'error_rate': 0.0  # Error percentage
        }
    
    def collect_data_metrics(self, X):
        """Collect data quality metrics."""
        metrics = {}
        
        # Missing values
        missing = X.isnull().sum()
        metrics['missing_count'] = int(missing.sum())
        metrics['missing_percentage'] = float(missing.sum() / (len(X) * len(X.columns)) * 100)
        
        # Feature statistics
        for col in X.columns:
            if pd.api.types.is_numeric_dtype(X[col]):
                metrics[f'{col}_mean'] = float(X[col].mean())
                metrics[f'{col}_std'] = float(X[col].std())
                metrics[f'{col}_min'] = float(X[col].min())
                metrics[f'{col}_max'] = float(X[col].max())
            else:
                metrics[f'{col}_nunique'] = X[col].nunique()
        
        return metrics
    
    def collect_model_metrics(self, y_true, y_pred, y_proba=None):
        """Collect model performance metrics."""
        from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
        
        metrics = {
            'accuracy': accuracy_score(y_true, y_pred),
            'precision': precision_score(y_true, y_pred, average='weighted', zero_division=0),
            'recall': recall_score(y_true, y_pred, average='weighted', zero_division=0),
            'f1': f1_score(y_true, y_pred, average='weighted', zero_division=0)
        }
        
        # Add probabilities if available
        if y_proba is not None:
            from sklearn.metrics import roc_auc_score
            try:
                metrics['roc_auc'] = roc_auc_score(y_true, y_proba)
            except:
                pass
        
        return metrics
    
    def collect_business_metrics(self, y_true, y_pred, cost_config):
        """Collect business impact metrics."""
        from sklearn.metrics import confusion_matrix
        
        cm = confusion_matrix(y_true, y_pred)
        tn, fp, fn, tp = cm.ravel()
        
        # Cost model
        cost_tn = cost_config.get('cost_tn', 0)
        cost_fp = cost_config.get('cost_fp', 10)
        cost_fn = cost_config.get('cost_fn', 50)
        cost_tp = cost_config.get('cost_tp', -100)  # Negative cost = profit
        
        total_cost = (tn * cost_tn + fp * cost_fp + 
                      fn * cost_fn + tp * cost_tp)
        
        return {
            'total_cost': total_cost,
            'cost_per_prediction': total_cost / len(y_true),
            'true_positives': int(tp),
            'false_positives': int(fp),
            'true_negatives': int(tn),
            'false_negatives': int(fn)
        }
```

---

## 3. Data Drift Detection

### Types of Drift

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPES OF DRIFT                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Data Drift (Feature Drift)                                    │
│  └── Distribution of input features changes                    │
│      • Covariate shift                                         │
│      • Seasonal variations                                     │
│      • User behavior changes                                   │
│                                                                 │
│  Target Drift (Label Drift)                                    │
│  └── Distribution of target variable changes                   │
│      • Concept drift                                           │
│      • Class imbalance changes                                 │
│      • New patterns emerging                                   │
│                                                                 │
│  Data Quality Drift                                            │
│  └── Quality of data changes                                   │
│      • More missing values                                     │
│      • Different data types                                    │
│      • Outlier patterns                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Statistical Drift Detection

```python
from scipy import stats
import numpy as np
import pandas as pd

class DriftDetector:
    """
    Detect data drift using statistical tests.
    """
    
    def __init__(self, reference_data, threshold=0.05):
        """
        Initialize drift detector.
        
        Args:
            reference_data: Reference data (training data)
            threshold: Significance threshold (default: 0.05)
        """
        self.reference_data = reference_data
        self.threshold = threshold
        self.reference_stats = self._compute_stats(reference_data)
    
    def _compute_stats(self, data):
        """Compute reference statistics."""
        stats_dict = {}
        
        for col in data.columns:
            if pd.api.types.is_numeric_dtype(data[col]):
                stats_dict[col] = {
                    'type': 'numeric',
                    'mean': data[col].mean(),
                    'std': data[col].std(),
                    'min': data[col].min(),
                    'max': data[col].max(),
                    'q1': data[col].quantile(0.25),
                    'q3': data[col].quantile(0.75)
                }
            else:
                stats_dict[col] = {
                    'type': 'categorical',
                    'value_counts': data[col].value_counts(normalize=True).to_dict()
                }
        
        return stats_dict
    
    def detect_drift(self, current_data):
        """
        Detect drift in current data.
        
        Args:
            current_data: Current data to check
        
        Returns:
            dict: Drift detection results
        """
        results = {
            'drift_detected': False,
            'drift_by_column': {},
            'summary': []
        }
        
        for col in current_data.columns:
            if col not in self.reference_stats:
                continue
            
            col_drift = self._check_column_drift(
                current_data[col],
                self.reference_stats[col]
            )
            
            results['drift_by_column'][col] = col_drift
            if col_drift['drift_detected']:
                results['drift_detected'] = True
                results['summary'].append({
                    'column': col,
                    'drift_type': col_drift['drift_type'],
                    'p_value': col_drift.get('p_value'),
                    'severity': col_drift.get('severity', 'medium')
                })
        
        return results
    
    def _check_column_drift(self, current_series, ref_stats):
        """Check drift for a single column."""
        col_type = ref_stats['type']
        
        if col_type == 'numeric':
            return self._check_numeric_drift(current_series, ref_stats)
        else:
            return self._check_categorical_drift(current_series, ref_stats)
    
    def _check_numeric_drift(self, current_series, ref_stats):
        """Check drift for numeric column."""
        # Remove missing values
        current_values = current_series.dropna()
        if len(current_values) < 2:
            return {
                'drift_detected': False,
                'drift_type': 'insufficient_data',
                'severity': 'low',
                'message': 'Insufficient data for drift detection'
            }
        
        # Kolmogorov-Smirnov test
        ks_stat, p_value = stats.ks_2samp(
            current_values,
            self.reference_data[current_series.name].dropna()
        )
        
        drift_detected = p_value < self.threshold
        
        # Determine severity
        if drift_detected:
            # Calculate distribution change
            mean_change = abs(current_values.mean() - ref_stats['mean']) / ref_stats['std']
            if mean_change > 0.5:
                severity = 'high'
            elif mean_change > 0.2:
                severity = 'medium'
            else:
                severity = 'low'
        else:
            severity = 'none'
        
        return {
            'drift_detected': drift_detected,
            'drift_type': 'distribution',
            'p_value': float(p_value),
            'severity': severity,
            'statistic': float(ks_stat),
            'current_mean': float(current_values.mean()),
            'reference_mean': ref_stats['mean'],
            'mean_change': float(mean_change) if drift_detected else None
        }
    
    def _check_categorical_drift(self, current_series, ref_stats):
        """Check drift for categorical column."""
        # Get current distribution
        current_counts = current_series.value_counts(normalize=True)
        
        # Align categories
        all_cats = set(ref_stats['value_counts'].keys()) | set(current_counts.index)
        ref_aligned = [ref_stats['value_counts'].get(cat, 0) for cat in all_cats]
        cur_aligned = [current_counts.get(cat, 0) for cat in all_cats]
        
        # Chi-square test
        chi2_stat, p_value = stats.chisquare(cur_aligned, f_exp=ref_aligned)
        
        drift_detected = p_value < self.threshold
        
        # Calculate total variation distance
        tvd = sum(abs(c - r) for c, r in zip(cur_aligned, ref_aligned)) / 2
        
        # Determine severity
        if drift_detected:
            if tvd > 0.3:
                severity = 'high'
            elif tvd > 0.1:
                severity = 'medium'
            else:
                severity = 'low'
        else:
            severity = 'none'
        
        return {
            'drift_detected': drift_detected,
            'drift_type': 'distribution',
            'p_value': float(p_value),
            'severity': severity,
            'statistic': float(chi2_stat),
            'tvd': float(tvd)
        }
    
    def generate_drift_report(self, drift_results):
        """Generate a drift report."""
        report = []
        report.append("=" * 60)
        report.append("DATA DRIFT REPORT")
        report.append("=" * 60)
        report.append(f"Drift Detected: {'Yes' if drift_results['drift_detected'] else 'No'}")
        report.append(f"Columns with Drift: {len(drift_results['summary'])}")
        
        if drift_results['summary']:
            report.append("\nColumns with Drift:")
            for item in drift_results['summary']:
                report.append(f"  {item['column']}: {item['drift_type']} (severity: {item['severity']})")
        
        return "\n".join(report)
```

### Concept Drift Detection

```python
from sklearn.metrics import accuracy_score
import numpy as np

class ConceptDriftDetector:
    """
    Detect concept drift using sliding window.
    """
    
    def __init__(self, window_size=1000, threshold=0.05):
        self.window_size = window_size
        self.threshold = threshold
        self.predictions = []
        self.actuals = []
    
    def update(self, y_pred, y_true):
        """Update detector with new predictions."""
        self.predictions.append(y_pred)
        self.actuals.append(y_true)
        
        # Keep only recent window
        if len(self.predictions) > self.window_size:
            self.predictions = self.predictions[-self.window_size:]
            self.actuals = self.actuals[-self.window_size:]
    
    def detect_drift(self):
        """Detect concept drift."""
        if len(self.predictions) < 50:
            return {'drift_detected': False, 'message': 'Insufficient data'}
        
        # Calculate current performance
        current_acc = accuracy_score(self.actuals[-100:], self.predictions[-100:])
        
        # Calculate historical performance
        historical_acc = accuracy_score(
            self.actuals[:-100] if len(self.actuals) > 100 else self.actuals,
            self.predictions[:-100] if len(self.predictions) > 100 else self.predictions
        )
        
        # Detect drift
        performance_drop = historical_acc - current_acc
        
        drift_detected = performance_drop > self.threshold
        
        return {
            'drift_detected': drift_detected,
            'current_accuracy': current_acc,
            'historical_accuracy': historical_acc,
            'performance_drop': performance_drop,
            'threshold': self.threshold,
            'message': 'Performance degradation detected' if drift_detected else 'No drift detected'
        }
```

---

## 4. Alerting and Response

### Alert System

```python
import smtplib
from email.mime.text import MIMEText
import json
from datetime import datetime

class AlertSystem:
    """
    Alert system for model monitoring.
    """
    
    def __init__(self, config):
        self.config = config
        self.alerts = []
        self.alert_levels = ['info', 'warning', 'critical']
    
    def check_and_alert(self, monitor_results):
        """
        Check monitor results and send alerts if needed.
        
        Args:
            monitor_results: Results from monitoring
        """
        # Check for critical issues
        alerts = []
        
        # 1. Data drift
        if monitor_results.get('drift_detected', False):
            drift_count = len(monitor_results.get('drift_summary', []))
            if drift_count > 3:
                alerts.append({
                    'level': 'critical',
                    'type': 'data_drift',
                    'message': f'Significant data drift detected in {drift_count} features',
                    'details': monitor_results.get('drift_summary', [])
                })
            elif drift_count > 0:
                alerts.append({
                    'level': 'warning',
                    'type': 'data_drift',
                    'message': f'Data drift detected in {drift_count} features',
                    'details': monitor_results.get('drift_summary', [])
                })
        
        # 2. Model performance
        if monitor_results.get('performance_drop', 0) > 0.1:
            alerts.append({
                'level': 'critical',
                'type': 'performance_degradation',
                'message': f'Model performance dropped {monitor_results["performance_drop"]*100:.1f}%',
                'details': {
                    'current': monitor_results.get('current_performance'),
                    'historical': monitor_results.get('historical_performance')
                }
            })
        elif monitor_results.get('performance_drop', 0) > 0.05:
            alerts.append({
                'level': 'warning',
                'type': 'performance_degradation',
                'message': f'Model performance dropped {monitor_results["performance_drop"]*100:.1f}%',
                'details': {
                    'current': monitor_results.get('current_performance'),
                    'historical': monitor_results.get('historical_performance')
                }
            })
        
        # 3. Data quality
        if monitor_results.get('missing_percentage', 0) > 20:
            alerts.append({
                'level': 'critical',
                'type': 'data_quality',
                'message': f'High missing values: {monitor_results["missing_percentage"]:.1f}%',
                'details': {'missing_percentage': monitor_results.get('missing_percentage')}
            })
        elif monitor_results.get('missing_percentage', 0) > 10:
            alerts.append({
                'level': 'warning',
                'type': 'data_quality',
                'message': f'Elevated missing values: {monitor_results["missing_percentage"]:.1f}%',
                'details': {'missing_percentage': monitor_results.get('missing_percentage')}
            })
        
        # 4. System health
        if monitor_results.get('error_rate', 0) > 0.05:
            alerts.append({
                'level': 'critical',
                'type': 'system_health',
                'message': f'High error rate: {monitor_results["error_rate"]*100:.1f}%',
                'details': {'error_rate': monitor_results.get('error_rate')}
            })
        
        # Send alerts
        for alert in alerts:
            self.send_alert(alert)
    
    def send_alert(self, alert):
        """Send an alert."""
        self.alerts.append({
            'alert': alert,
            'timestamp': datetime.now().isoformat()
        })
        
        # Log alert
        print(f"ALERT [{alert['level'].upper()}]: {alert['message']}")
        
        # Send email if configured
        if self.config.get('email_enabled'):
            self._send_email_alert(alert)
        
        # Send Slack if configured
        if self.config.get('slack_enabled'):
            self._send_slack_alert(alert)
    
    def _send_email_alert(self, alert):
        """Send email alert."""
        # Implementation would use SMTP
        pass
    
    def _send_slack_alert(self, alert):
        """Send Slack alert."""
        # Implementation would use Slack webhook
        pass
    
    def get_alert_history(self, level=None):
        """Get alert history."""
        if level:
            return [a for a in self.alerts if a['alert']['level'] == level]
        return self.alerts
```

---

## 5. Monitoring Dashboard

### Simple Dashboard

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import plotly.express as px

class MonitoringDashboard:
    """
    Create monitoring dashboards.
    """
    
    def __init__(self):
        self.fig = None
    
    def create_dashboard(self, monitor_results):
        """Create a monitoring dashboard."""
        # Create subplots
        fig = make_subplots(
            rows=3, cols=2,
            subplot_titles=(
                'Model Performance', 'Data Drift',
                'Feature Distributions', 'Missing Values',
                'System Health', 'Business Metrics'
            )
        )
        
        # 1. Model Performance
        if 'performance_history' in monitor_results:
            fig.add_trace(
                go.Scatter(
                    x=monitor_results['timestamps'],
                    y=monitor_results['performance_history'],
                    mode='lines+markers',
                    name='Performance'
                ),
                row=1, col=1
            )
        
        # 2. Data Drift
        if 'drift_summary' in monitor_results:
            drift_data = monitor_results['drift_summary']
            fig.add_trace(
                go.Bar(
                    x=[d['column'] for d in drift_data],
                    y=[d['severity_score'] for d in drift_data],
                    name='Drift Severity'
                ),
                row=1, col=2
            )
        
        # 3. Feature Distributions
        if 'feature_distributions' in monitor_results:
            for col, dist in monitor_results['feature_distributions'].items():
                fig.add_trace(
                    go.Histogram(
                        x=dist['values'],
                        name=col,
                        opacity=0.7
                    ),
                    row=2, col=1
                )
        
        # 4. Missing Values
        if 'missing_values' in monitor_results:
            fig.add_trace(
                go.Bar(
                    x=monitor_results['missing_values']['columns'],
                    y=monitor_results['missing_values']['percentages'],
                    name='Missing %'
                ),
                row=2, col=2
            )
        
        # 5. System Health
        if 'system_metrics' in monitor_results:
            fig.add_trace(
                go.Indicator(
                    mode="gauge+number",
                    value=monitor_results['system_metrics']['health_score'],
                    title={'text': "Health Score"},
                    domain={'row': 0, 'column': 0}
                ),
                row=3, col=1
            )
        
        # 6. Business Metrics
        if 'business_metrics' in monitor_results:
            fig.add_trace(
                go.Bar(
                    x=['Cost', 'Savings', 'ROI'],
                    y=[
                        monitor_results['business_metrics']['total_cost'],
                        monitor_results['business_metrics']['savings'],
                        monitor_results['business_metrics']['roi']
                    ],
                    name='Business Impact'
                ),
                row=3, col=2
            )
        
        # Update layout
        fig.update_layout(
            height=1000,
            showlegend=True,
            title_text="ML Model Monitoring Dashboard",
            template="plotly_white"
        )
        
        self.fig = fig
        return fig
    
    def show(self):
        """Display the dashboard."""
        if self.fig:
            self.fig.show()
```

---

## 6. Automated Retraining

### Retraining Trigger

```python
class RetrainingManager:
    """
    Manage automated model retraining.
    """
    
    def __init__(self, config):
        self.config = config
        self.drift_threshold = config.get('drift_threshold', 0.05)
        self.performance_threshold = config.get('performance_threshold', 0.05)
        self.retrain_every = config.get('retrain_every', 30)  # days
    
    def should_retrain(self, monitor_results):
        """
        Determine if model should be retrained.
        
        Returns:
            tuple: (should_retrain, reason)
        """
        # Check 1: Significant data drift
        if monitor_results.get('drift_detected', False):
            drift_count = len(monitor_results.get('drift_summary', []))
            if drift_count > 5:
                return True, f'Significant data drift in {drift_count} features'
            if drift_count > 0:
                # Check if any feature has high severity drift
                for d in monitor_results.get('drift_summary', []):
                    if d.get('severity') == 'high':
                        return True, f'High severity drift in {d["column"]}'
        
        # Check 2: Performance degradation
        performance_drop = monitor_results.get('performance_drop', 0)
        if performance_drop > self.performance_threshold:
            return True, f'Performance drop of {performance_drop*100:.1f}%'
        
        # Check 3: Time-based retraining
        days_since_train = monitor_results.get('days_since_train', 0)
        if days_since_train > self.retrain_every:
            return True, f'Model is {days_since_train} days old'
        
        # Check 4: Data volume
        new_samples = monitor_results.get('new_samples', 0)
        if new_samples > 10000:
            return True, f'Accumulated {new_samples} new samples'
        
        return False, 'No retraining needed'
    
    def trigger_retraining(self, reason):
        """Trigger model retraining."""
        print(f"🔄 Triggering retraining: {reason}")
        # This would trigger your training pipeline
        # Could be: API call, message queue, or airflow DAG
        pass
```

---

## Quick Reference: Monitoring Checklist

```
□ 1. System Health
│   ├── CPU/Memory usage
│   ├── Request latency
│   ├── Error rate
│   └── Throughput
│
□ 2. Data Quality
│   ├── Missing values
│   ├── Data types
│   ├── Value ranges
│   └── Schema validation
│
□ 3. Data Drift
│   ├── Feature distributions
│   ├── Statistical tests
│   ├── Visual inspection
│   └── Drift severity
│
□ 4. Model Performance
│   ├── Accuracy (when available)
│   ├── Error analysis
│   ├── Confusion matrix
│   └── Calibration
│
□ 5. Business Metrics
│   ├── Cost impact
│   ├── Revenue impact
│   ├── ROI
│   └── KPIs
│
□ 6. Alerting
│   ├── Thresholds
│   ├── Notification channels
│   ├── Escalation
│   └── Response plans
│
□ 7. Retraining
│   ├── Trigger conditions
│   ├── Automated pipeline
│   ├── Validation
│   └── Deployment
```

---

## Conclusion

This primer covers the essential concepts of production ML monitoring. You now understand:

1. **Why monitoring matters**: Performance degradation, drift, business impact
2. **What to monitor**: System, data, model, business metrics
3. **How to detect drift**: Statistical tests, visualizations
4. **Alerting**: When and how to alert
5. **Dashboards**: Visualizing monitoring data
6. **Retraining**: When to retrain models

**Next Steps:**
1. Implement basic monitoring for your model
2. Set up drift detection
3. Create a monitoring dashboard
4. Define alerting thresholds
5. Proceed to Part 1 of the series

---

*End of Primer 11*
