# Primer 21: Model Documentation and Governance

## Overview

This primer provides a comprehensive guide to model documentation and governance—the practices and processes for managing ML models throughout their lifecycle. Understanding these concepts is essential for building trustworthy, compliant, and maintainable ML systems.

---

## 1. Why Model Documentation Matters

### The Governance Challenge

```
┌─────────────────────────────────────────────────────────────────┐
│              THE GOVERNANCE CHALLENGE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ML Models in Production Face Increasing Scrutiny              │
│                                                                 │
│  Regulatory Requirements                                        │
│  ├── GDPR (Europe) - Right to explanation                      │
│  ├── CCPA (California) - Data rights                           │
│  ├── AI Act (EU) - Risk-based regulation                       │
│  └── Fair Lending (US) - Non-discrimination                    │
│                                                                 │
│  Business Requirements                                          │
│  ├── Audit trails                                              │
│  ├── Reproducibility                                           │
│  ├── Risk management                                           │
│  └── Stakeholder trust                                         │
│                                                                 │
│  Technical Requirements                                         │
│  ├── Debugging                                                 │
│  ├── Maintenance                                               │
│  ├── Knowledge transfer                                        │
│  └── Continuous improvement                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Documentation Principles

```
┌─────────────────────────────────────────────────────────────────┐
│              DOCUMENTATION PRINCIPLES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Accuracy                                                    │
│     └── Documentation must be correct and up-to-date           │
│                                                                 │
│  2. Completeness                                                │
│     └── Cover all aspects of the model lifecycle              │
│                                                                 │
│  3. Clarity                                                     │
│     └── Written for the target audience                        │
│                                                                 │
│  4. Accessibility                                               │
│     └── Easy to find and access                                │
│                                                                 │
│  5. Version Control                                             │
│     └── Track changes over time                                │
│                                                                 │
│  6. Automated                                                   │
│     └── Generate where possible                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Model Cards

### What is a Model Card?

A Model Card is a standardized document that provides information about a machine learning model, including its intended use, performance, limitations, and ethical considerations.

### Model Card Template

```python
class ModelCard:
    """
    Generate comprehensive model cards.
    """
    
    def __init__(self, model_name, version, model_type):
        self.model_name = model_name
        self.version = version
        self.model_type = model_type
        self.sections = {}
    
    def add_section(self, title, content):
        """Add a section to the model card."""
        self.sections[title] = content
    
    def generate_markdown(self):
        """Generate markdown version of model card."""
        card = []
        card.append(f"# Model Card: {self.model_name}")
        card.append(f"Version: {self.version}")
        card.append("")
        
        for title, content in self.sections.items():
            card.append(f"## {title}")
            card.append("")
            if isinstance(content, list):
                for item in content:
                    card.append(f"- {item}")
            elif isinstance(content, dict):
                for key, value in content.items():
                    card.append(f"- **{key}**: {value}")
            else:
                card.append(str(content))
            card.append("")
        
        return "\n".join(card)
    
    def generate_html(self):
        """Generate HTML version of model card."""
        html = []
        html.append("<!DOCTYPE html>")
        html.append("<html>")
        html.append("<head>")
        html.append("<style>")
        html.append("body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }")
        html.append("h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }")
        html.append("h2 { color: #34495e; margin-top: 30px; }")
        html.append(".section { background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0; }")
        html.append("</style>")
        html.append("</head>")
        html.append("<body>")
        
        html.append(f"<h1>Model Card: {self.model_name}</h1>")
        html.append(f"<p><strong>Version:</strong> {self.version}</p>")
        
        for title, content in self.sections.items():
            html.append(f"<div class='section'>")
            html.append(f"<h2>{title}</h2>")
            if isinstance(content, list):
                html.append("<ul>")
                for item in content:
                    html.append(f"<li>{item}</li>")
                html.append("</ul>")
            elif isinstance(content, dict):
                html.append("<ul>")
                for key, value in content.items():
                    html.append(f"<li><strong>{key}:</strong> {value}</li>")
                html.append("</ul>")
            else:
                html.append(f"<p>{content}</p>")
            html.append("</div>")
        
        html.append("</body>")
        html.append("</html>")
        
        return "\n".join(html)
    
    def save(self, output_path, format='markdown'):
        """
        Save model card to file.
        
        Args:
            output_path: Path to save
            format: 'markdown' or 'html'
        """
        if format == 'markdown':
            content = self.generate_markdown()
        elif format == 'html':
            content = self.generate_html()
        else:
            raise ValueError(f"Unsupported format: {format}")
        
        with open(output_path, 'w') as f:
            f.write(content)
        
        print(f"Model card saved to: {output_path}")

def create_churn_model_card():
    """
    Create a model card for churn prediction model.
    """
    card = ModelCard(
        model_name="Churn Prediction Model",
        version="2.1.0",
        model_type="Random Forest Classifier"
    )
    
    # Add sections
    card.add_section("Model Details", {
        "Model Type": "Random Forest Classifier",
        "Framework": "scikit-learn 1.3.0",
        "Training Data": "Customer data from 2020-2023",
        "Training Date": "2024-01-15",
        "Training Size": "50,000 samples",
        "Features": "25 features (demographic, behavioral, service)"
    })
    
    card.add_section("Intended Use", [
        "Predict customer churn probability",
        "Identify at-risk customers for retention",
        "Enable targeted retention campaigns",
        "Should be used for customers with similar profile"
    ])
    
    card.add_section("Performance Metrics", {
        "Accuracy": "0.85",
        "Precision": "0.82",
        "Recall": "0.78",
        "F1 Score": "0.80",
        "ROC-AUC": "0.92",
        "PR-AUC": "0.88"
    })
    
    card.add_section("Limitations", [
        "Performance may degrade with significant data drift",
        "Not suitable for customers in new markets",
        "Does not consider external economic factors",
        "Should be retrained quarterly"
    ])
    
    card.add_section("Ethical Considerations", [
        "Use of demographic features (age, gender) monitored for bias",
        "Fairness metrics evaluated across demographic groups",
        "Regular bias audits performed",
        "Retention offers designed to avoid discrimination"
    ])
    
    card.add_section("Maintenance", {
        "Frequency": "Quarterly retraining",
        "Monitoring": "Performance, drift, fairness",
        "Owner": "ML Team",
        "Review": "Quarterly business review"
    })
    
    return card

# Example usage
card = create_churn_model_card()
card.save('model_card.md', format='markdown')
card.save('model_card.html', format='html')
```

---

## 3. Model Registry with Documentation

### Enhanced Model Registry

```python
class ModelRegistryWithDocs:
    """
    Model registry with integrated documentation.
    """
    
    def __init__(self, registry_dir='models/registry'):
        self.registry_dir = Path(registry_dir)
        self.registry_dir.mkdir(parents=True, exist_ok=True)
        self.registry_file = self.registry_dir / 'registry.json'
        self.registry = self._load_registry()
    
    def _load_registry(self):
        if self.registry_file.exists():
            with open(self.registry_file, 'r') as f:
                return json.load(f)
        return {'models': [], 'deployments': {}}
    
    def _save_registry(self):
        with open(self.registry_file, 'w') as f:
            json.dump(self.registry, f, indent=2)
    
    def register_model(self, model, model_card, model_filepath=None):
        """
        Register model with documentation.
        
        Args:
            model: Trained model
            model_card: ModelCard object
            model_filepath: Path to saved model
        """
        import hashlib
        
        # Generate model ID
        model_id = f"model_{len(self.registry['models']) + 1:04d}"
        timestamp = datetime.now().isoformat()
        
        # Save model if filepath not provided
        if model_filepath is None:
            model_dir = self.registry_dir / model_id
            model_dir.mkdir(exist_ok=True)
            model_filepath = model_dir / 'model.joblib'
            joblib.dump(model, model_filepath)
        
        # Create registry entry
        entry = {
            'id': model_id,
            'name': model_card.model_name,
            'version': model_card.version,
            'timestamp': timestamp,
            'model_type': model_card.model_type,
            'filepath': str(model_filepath),
            'model_card': model_card.sections,
            'status': 'registered'
        }
        
        self.registry['models'].append(entry)
        self._save_registry()
        
        print(f"Model {model_id} registered with documentation")
        return entry
    
    def get_model_card(self, model_id):
        """
        Get model card for a specific model.
        
        Args:
            model_id: Model identifier
        
        Returns:
            ModelCard: Model card object
        """
        for model in self.registry['models']:
            if model['id'] == model_id:
                card = ModelCard(
                    model_name=model['name'],
                    version=model['version'],
                    model_type=model['model_type']
                )
                for title, content in model['model_card'].items():
                    card.add_section(title, content)
                return card
        return None
    
    def compare_models(self, model_ids, metric='accuracy'):
        """
        Compare models side by side.
        
        Args:
            model_ids: List of model IDs
            metric: Metric to compare
        
        Returns:
            pd.DataFrame: Comparison results
        """
        comparison = []
        
        for model_id in model_ids:
            entry = self.get_model(model_id)
            if entry:
                model_card = entry['model_card']
                if 'Performance Metrics' in model_card:
                    metrics = model_card['Performance Metrics']
                    if isinstance(metrics, dict):
                        comparison.append({
                            'Model': f"{entry['name']} ({entry['version']})",
                            metric: float(metrics.get(metric, 0))
                        })
        
        return pd.DataFrame(comparison).sort_values(metric, ascending=False)
```

---

## 4. Data Sheets for Datasets

### Dataset Documentation

```python
class DataSheet:
    """
    Documentation for datasets.
    """
    
    def __init__(self, dataset_name, version):
        self.dataset_name = dataset_name
        self.version = version
        self.sections = {}
    
    def add_section(self, title, content):
        """Add a section to the datasheet."""
        self.sections[title] = content
    
    def generate_markdown(self):
        """Generate markdown datasheet."""
        sheet = []
        sheet.append(f"# Data Sheet: {self.dataset_name}")
        sheet.append(f"Version: {self.version}")
        sheet.append("")
        
        for title, content in self.sections.items():
            sheet.append(f"## {title}")
            sheet.append("")
            if isinstance(content, list):
                for item in content:
                    sheet.append(f"- {item}")
            elif isinstance(content, dict):
                for key, value in content.items():
                    sheet.append(f"- **{key}**: {value}")
            else:
                sheet.append(str(content))
            sheet.append("")
        
        return "\n".join(sheet)

def create_churn_data_sheet():
    """
    Create a data sheet for churn dataset.
    """
    sheet = DataSheet(
        dataset_name="Customer Churn Dataset",
        version="2.0.0"
    )
    
    sheet.add_section("Dataset Details", {
        "Description": "Customer data for churn prediction",
        "Collection Period": "2020-01-01 to 2023-12-31",
        "Size": "50,000 records",
        "Variables": "25 features + target",
        "Format": "CSV"
    })
    
    sheet.add_section("Variables", [
        "Demographic: age, gender, income, location",
        "Account: tenure, contract type, payment method",
        "Service: internet, phone, security, support",
        "Behavior: monthly charges, total charges, service usage",
        "Target: churn (Yes/No)"
    ])
    
    sheet.add_section("Data Collection", {
        "Source": "CRM System",
        "Method": "Automated collection",
        "Frequency": "Monthly",
        "Quality": "Validated for completeness"
    })
    
    sheet.add_section("Preprocessing", [
        "Missing values imputed",
        "Outliers handled",
        "Categorical variables encoded",
        "Numeric variables scaled",
        "Duplicates removed"
    ])
    
    sheet.add_section("Ethical Considerations", {
        "Privacy": "PII removed or anonymized",
        "Consent": "Customer consent obtained",
        "Bias": "Checked for demographic bias",
        "Usage": "Only for internal retention use"
    })
    
    return sheet

# Example
sheet = create_churn_data_sheet()
sheet.save('data_sheet.md')
```

---

## 5. Governance Framework

### Model Governance Policies

```python
class ModelGovernance:
    """
    Model governance and policy enforcement.
    """
    
    def __init__(self, policies):
        self.policies = policies
        self.violations = []
    
    def check_model(self, model_card, model_performance):
        """
        Check model against governance policies.
        
        Args:
            model_card: ModelCard object
            model_performance: Performance metrics
        
        Returns:
            dict: Governance check results
        """
        results = {
            'passed': True,
            'checks': [],
            'violations': []
        }
        
        # Check policies
        for policy in self.policies:
            check = self._check_policy(policy, model_card, model_performance)
            results['checks'].append(check)
            
            if not check['passed']:
                results['passed'] = False
                results['violations'].append(check['violation'])
        
        return results
    
    def _check_policy(self, policy, model_card, model_performance):
        """Check a single policy."""
        check = {
            'policy': policy['name'],
            'passed': True
        }
        
        if policy['type'] == 'performance':
            # Check performance threshold
            metric = policy['metric']
            threshold = policy['threshold']
            comparison = policy['comparison']
            
            if comparison == 'min':
                if model_performance.get(metric, 0) < threshold:
                    check['passed'] = False
                    check['violation'] = f"Performance metric {metric} is below {threshold}"
            elif comparison == 'max':
                if model_performance.get(metric, float('inf')) > threshold:
                    check['passed'] = False
                    check['violation'] = f"Performance metric {metric} is above {threshold}"
        
        elif policy['type'] == 'fairness':
            # Check fairness metric
            metric = policy['metric']
            threshold = policy['threshold']
            
            if model_performance.get(metric, 1.0) < threshold:
                check['passed'] = False
                check['violation'] = f"Fairness metric {metric} is below {threshold}"
        
        elif policy['type'] == 'documentation':
            # Check documentation completeness
            required = policy['required_sections']
            missing = [s for s in required if s not in model_card.sections]
            
            if missing:
                check['passed'] = False
                check['violation'] = f"Missing documentation sections: {missing}"
        
        return check
    
    def approve_deployment(self, model_card, model_performance):
        """
        Approve model for deployment.
        
        Args:
            model_card: ModelCard object
            model_performance: Performance metrics
        
        Returns:
            dict: Approval result
        """
        results = self.check_model(model_card, model_performance)
        
        if results['passed']:
            approval = {
                'approved': True,
                'message': "Model approved for deployment",
                'timestamp': datetime.now().isoformat()
            }
        else:
            approval = {
                'approved': False,
                'message': "Model fails governance checks",
                'violations': results['violations'],
                'timestamp': datetime.now().isoformat()
            }
        
        return approval

# Example policies
policies = [
    {
        'name': 'Accuracy Threshold',
        'type': 'performance',
        'metric': 'accuracy',
        'threshold': 0.80,
        'comparison': 'min'
    },
    {
        'name': 'AUC Threshold',
        'type': 'performance',
        'metric': 'roc_auc',
        'threshold': 0.85,
        'comparison': 'min'
    },
    {
        'name': 'Fairness Requirement',
        'type': 'fairness',
        'metric': 'disparate_impact',
        'threshold': 0.8
    },
    {
        'name': 'Documentation Required',
        'type': 'documentation',
        'required_sections': [
            'Model Details',
            'Intended Use',
            'Performance Metrics',
            'Limitations',
            'Ethical Considerations'
        ]
    }
]

governance = ModelGovernance(policies)
approval = governance.approve_deployment(card, {'accuracy': 0.85, 'roc_auc': 0.92})
```

---

## Quick Reference: Model Documentation

### Documentation Checklist

```
□ 1. Model Details
│   ├── Model type and architecture
│   ├── Training data description
│   ├── Training date and duration
│   ├── Feature list
│   └── Framework and version
│
□ 2. Intended Use
│   ├── Primary use case
│   ├── Target users
│   ├── Out-of-scope uses
│   └── Deployment environment
│
□ 3. Performance
│   ├── Key metrics
│   ├── Performance by segment
│   ├── Calibration metrics
│   └── Benchmark comparisons
│
□ 4. Limitations
│   ├── Known failure modes
│   ├── Data limitations
│   ├── Domain limitations
│   └── Degradation expectations
│
□ 5. Ethics and Fairness
│   ├── Bias analysis
│   ├── Protected attributes
│   ├── Fairness metrics
│   └── Mitigation strategies
│
□ 6. Maintenance
│   ├── Retraining schedule
│   ├── Monitoring plan
│   ├── Owner/contact
│   └── Review process
```

### Governance Checklist

```
□ 1. Performance Requirements
│   ├── Minimum accuracy
│   ├── Minimum AUC
│   ├── Latency requirements
│   └── Throughput requirements
│
□ 2. Fairness Requirements
│   ├── Disparate impact threshold
│   ├── Equal opportunity threshold
│   ├── Monitoring frequency
│   └── Remediation plan
│
□ 3. Documentation Requirements
│   ├── Model card required
│   ├── Data sheet required
│   ├── Update frequency
│   └── Review process
│
□ 4. Compliance Requirements
│   ├── Regulatory compliance
│   ├── Privacy requirements
│   ├── Audit requirements
│   └── Incident response
│
□ 5. Operational Requirements
│   ├── Retraining schedule
│   ├── Monitoring requirements
│   ├── Escalation process
│   └── Rollback plan
```

---

## Conclusion

This primer covers the essential concepts of model documentation and governance. You now understand:

1. **Why documentation matters**: Regulatory compliance, business requirements
2. **Model cards**: Standardized model documentation
3. **Model registry**: Integrated documentation
4. **Data sheets**: Dataset documentation
5. **Governance policies**: Performance, fairness, documentation
6. **Approval processes**: Model deployment governance

**Next Steps:**
1. Create model cards for your models
2. Implement a model registry
3. Document your datasets
4. Establish governance policies
5. Proceed to Part 1 of the series

---

*End of Primer 21*
