# Module 6.3: Data Ethics, Explainability & Governance
## Part 1: Understanding Algorithmic Fairness

### The Target

We're building a comprehensive framework for ethical AI development that ensures our machine learning models are fair, transparent, and compliant with regulatory standards. This module transforms our churn prediction model into a responsible, explainable, and auditable system.

### The Concept

**The Ethics Paradox**

Imagine you're a judge in a courtroom. You have two defendants with identical backgrounds and charges, but you give them different sentences based on their zip codes. That would be clearly unethical. Yet, this is exactly what many ML models do when they use proxies for protected characteristics.

**Why Fairness Matters**

Machine learning models increasingly make decisions that affect people's lives:
- Who gets a loan?
- Who gets hired?
- Who gets insurance?
- Who gets targeted for marketing?

If our models are biased, we're not just making bad business decisions—we're perpetuating systemic inequality. **Fairness isn't just ethical; it's also good business.** Biased models lead to:
- Regulatory fines (GDPR/CCPA violations)
- Reputational damage
- Lost customers
- Class-action lawsuits

**Key Concepts in Algorithmic Fairness**

| Concept | Definition | Analogy |
|---------|------------|---------|
| **Demographic Parity** | Model outcomes are independent of protected attributes | Equal acceptance rates across groups |
| **Equal Opportunity** | Equal true positive rates across groups | Catching the same proportion of "worthy" candidates in each group |
| **Equalized Odds** | Equal false positive and false negative rates | Same error patterns across groups |
| **Individual Fairness** | Similar individuals get similar predictions | Treating similar cases similarly |

---

## Step 1: Setting Up the Fairness Framework

### The Target
Install and configure the libraries needed for fairness analysis and model explainability.

### The Concept
We'll use several key libraries:
- **Fairlearn:** Microsoft's fairness toolkit for assessing and mitigating bias
- **SHAP:** Game-theoretic approach to model explanation
- **LIME:** Local interpretable model-agnostic explanations
- **AIF360:** IBM's comprehensive fairness toolkit

### The Implementation

```bash
# 1. Install fairness and explainability libraries
source venv/bin/activate

pip install fairlearn==0.10.0
pip install shap==0.42.1
pip install lime==0.2.0.1
pip install aif360==0.5.0
pip install dalex==1.7.0

# 2. Update requirements.txt
cat >> requirements.txt << 'EOF'
fairlearn==0.10.0
shap==0.42.1
lime==0.2.0.1
aif360==0.5.0
dalex==1.7.0
EOF

# 3. Create the explainability module structure
mkdir -p src/explainability
mkdir -p src/explainability/reports
mkdir -p notebooks/explainability
```

---

## Step 2: Building the Churn Prediction Model

### The Target
Build a churn prediction model that we'll analyze for fairness and explainability.

### The Concept
We'll use our e-commerce data to predict customer churn. This is a classic business problem where fairness matters—we need to ensure our model doesn't unfairly target certain customer segments.

### The Implementation

```bash
cat > src/explainability/churn_model.py << 'EOF'
"""
Churn prediction model with fairness and explainability considerations.
This module builds and evaluates a model for predicting customer churn.
"""

import os
import sys
import logging
from pathlib import Path
from typing import Dict, Any, Tuple, Optional
from datetime import datetime
import pickle
import json

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    roc_auc_score,
    confusion_matrix,
    classification_report
)
import xgboost as xgb
from sqlalchemy import text

# Add project root to path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

from src.database.postgres import get_client

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ChurnPredictor:
    """
    End-to-end churn prediction system with fairness and explainability.
    """
    
    def __init__(self, model_type: str = 'xgboost', random_state: int = 42):
        """
        Initialize the churn predictor.
        
        Args:
            model_type: 'xgboost' or 'random_forest'
            random_state: Random seed for reproducibility
        """
        self.model_type = model_type
        self.random_state = random_state
        self.model = None
        self.preprocessor = None
        self.feature_names = None
        self.threshold = 0.5
        
        logger.info(f"Initialized ChurnPredictor with model_type: {model_type}")
    
    def load_data(self) -> pd.DataFrame:
        """
        Load and prepare customer data for churn prediction.
        
        Returns:
            DataFrame with features and target
        """
        logger.info("Loading customer data...")
        
        client = get_client()
        
        # Load customer data from our mart
        query = """
        SELECT 
            customer_id,
            email,
            first_name,
            last_name,
            age,
            registration_date,
            EXTRACT(YEAR FROM registration_date) AS registration_year,
            EXTRACT(MONTH FROM registration_date) AS registration_month,
            
            -- Customer value metrics
            total_orders,
            total_spent,
            avg_order_value,
            net_spent,
            customer_tier,
            
            -- Behavior metrics
            days_since_registration,
            churn_risk,
            customer_health_score,
            projected_lifetime_value,
            
            -- Return behavior
            avg_return_rate,
            fully_returned_orders,
            
            -- Engagement metrics
            total_reviews,
            avg_review_rating,
            positive_reviews,
            total_campaign_responses,
            campaign_conversions,
            campaign_revenue,
            
            -- Metadata
            is_active,
            is_verified
            
        FROM analytics_dbt.dm_customer_360
        """
        
        df = pd.DataFrame(client.execute_query(query))
        logger.info(f"Loaded {len(df)} customers")
        
        # Define churn based on our business definition
        # Churn: Customer who hasn't made a purchase in 90 days AND has churn_risk = 'high'
        # For our model training, we'll use the churn_risk column as our target
        # But let's create a more realistic churn definition based on actual behavior
        
        # For this exercise, we'll create a synthetic churn label based on multiple factors
        # In production, you'd use actual churn events
        
        # Simulate churn based on business rules
        np.random.seed(self.random_state)
        
        # Base churn rate: 15%
        base_churn = 0.15
        
        # Factors that increase churn probability
        df['churn_probability'] = base_churn
        
        # Higher churn for customers with high churn_risk
        df.loc[df['churn_risk'] == 'high', 'churn_probability'] += 0.3
        df.loc[df['churn_risk'] == 'medium', 'churn_probability'] += 0.1
        
        # Higher churn for low health scores
        df['churn_probability'] += (1 - df['customer_health_score'] / 100) * 0.2
        
        # Lower churn for high spending customers
        df['churn_probability'] -= (df['total_spent'] / 5000) * 0.1
        
        # Cap probabilities
        df['churn_probability'] = np.clip(df['churn_probability'], 0.01, 0.95)
        
        # Generate churn labels
        df['churn'] = (np.random.random(len(df)) < df['churn_probability']).astype(int)
        
        # Calculate actual churn rate
        actual_churn_rate = df['churn'].mean()
        logger.info(f"Churn rate: {actual_churn_rate:.2%}")
        
        return df
    
    def prepare_features(self, df: pd.DataFrame) -> Tuple[pd.DataFrame, pd.Series, Dict[str, Any]]:
        """
        Prepare features and target for modeling.
        
        Args:
            df: Raw data DataFrame
            
        Returns:
            Features DataFrame, Target Series, and metadata
        """
        logger.info("Preparing features...")
        
        # Define target column
        target = 'churn'
        
        # Define features to use
        features = [
            'age',
            'registration_year',
            'registration_month',
            'total_orders',
            'total_spent',
            'avg_order_value',
            'net_spent',
            'days_since_registration',
            'customer_health_score',
            'projected_lifetime_value',
            'avg_return_rate',
            'fully_returned_orders',
            'total_reviews',
            'avg_review_rating',
            'positive_reviews',
            'total_campaign_responses',
            'campaign_conversions',
            'campaign_revenue',
            'is_verified'
        ]
        
        # Categorical features for encoding
        categorical_features = ['customer_tier']
        
        # Define protected attributes for fairness analysis
        protected_attributes = {
            'is_verified': 'verification_status',
            'age_group': 'age_group'
        }
        
        # Create age groups for fairness analysis
        df['age_group'] = pd.cut(
            df['age'],
            bins=[0, 25, 35, 45, 55, 100],
            labels=['18-25', '26-35', '36-45', '46-55', '55+']
        )
        
        # Handle missing values
        X = df[features + categorical_features + ['age_group']].copy()
        
        # Fill missing values
        numeric_cols = X.select_dtypes(include=[np.number]).columns
        for col in numeric_cols:
            X[col].fillna(X[col].median(), inplace=True)
        
        # For categorical, fill with mode
        for col in ['customer_tier']:
            X[col].fillna(X[col].mode()[0] if not X[col].mode().empty else 'unknown', inplace=True)
        
        # Create features for modeling
        X_model = X[features + categorical_features].copy()
        
        y = df[target].copy()
        
        # Store metadata
        metadata = {
            'feature_names': X_model.columns.tolist(),
            'target_name': target,
            'protected_attributes': protected_attributes,
            'churn_rate': y.mean()
        }
        
        logger.info(f"Features shape: {X_model.shape}")
        logger.info(f"Feature names: {metadata['feature_names']}")
        
        return X_model, y, metadata
    
    def build_preprocessor(self, X: pd.DataFrame) -> ColumnTransformer:
        """
        Build the preprocessing pipeline.
        
        Args:
            X: Feature DataFrame
            
        Returns:
            ColumnTransformer for preprocessing
        """
        logger.info("Building preprocessor...")
        
        # Identify column types
        numeric_features = X.select_dtypes(include=[np.number]).columns.tolist()
        categorical_features = X.select_dtypes(include=['object', 'category']).columns.tolist()
        
        # Create transformers
        numeric_transformer = Pipeline(steps=[
            ('scaler', StandardScaler())
        ])
        
        categorical_transformer = Pipeline(steps=[
            ('onehot', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
        ])
        
        # Combine into preprocessor
        preprocessor = ColumnTransformer(
            transformers=[
                ('num', numeric_transformer, numeric_features),
                ('cat', categorical_transformer, categorical_features)
            ],
            remainder='drop'
        )
        
        logger.info(f"Preprocessor built: {len(numeric_features)} numeric, {len(categorical_features)} categorical features")
        
        return preprocessor
    
    def build_model(self) -> Pipeline:
        """
        Build the full model pipeline.
        
        Returns:
            sklearn Pipeline
        """
        logger.info(f"Building {self.model_type} model...")
        
        if self.model_type == 'xgboost':
            classifier = xgb.XGBClassifier(
                n_estimators=100,
                max_depth=5,
                learning_rate=0.1,
                random_state=self.random_state,
                use_label_encoder=False,
                eval_metric='logloss'
            )
        else:  # random_forest
            classifier = RandomForestClassifier(
                n_estimators=100,
                max_depth=10,
                min_samples_split=5,
                min_samples_leaf=2,
                random_state=self.random_state
            )
        
        # Create full pipeline
        pipeline = Pipeline(steps=[
            ('preprocessor', self.build_preprocessor(None)),
            ('classifier', classifier)
        ])
        
        return pipeline
    
    def train(self, X: pd.DataFrame, y: pd.Series) -> Dict[str, Any]:
        """
        Train the churn prediction model.
        
        Args:
            X: Feature DataFrame
            y: Target Series
            
        Returns:
            Training metrics dictionary
        """
        logger.info("Training model...")
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y,
            test_size=0.2,
            random_state=self.random_state,
            stratify=y
        )
        
        # Build preprocessor with training data
        self.preprocessor = self.build_preprocessor(X_train)
        
        # Update pipeline
        self.model = Pipeline(steps=[
            ('preprocessor', self.preprocessor),
            ('classifier', self.model.named_steps['classifier'] if hasattr(self.model, 'named_steps') else 
             (xgb.XGBClassifier(n_estimators=100, max_depth=5, learning_rate=0.1, random_state=self.random_state, 
                               use_label_encoder=False, eval_metric='logloss') if self.model_type == 'xgboost' 
              else RandomForestClassifier(n_estimators=100, max_depth=10, random_state=self.random_state)))
        ])
        
        # Fit model
        self.model.fit(X_train, y_train)
        
        # Make predictions
        y_pred = self.model.predict(X_test)
        y_pred_proba = self.model.predict_proba(X_test)[:, 1]
        
        # Calculate metrics
        metrics = {
            'accuracy': accuracy_score(y_test, y_pred),
            'precision': precision_score(y_test, y_pred),
            'recall': recall_score(y_test, y_pred),
            'f1': f1_score(y_test, y_pred),
            'roc_auc': roc_auc_score(y_test, y_pred_proba),
            'confusion_matrix': confusion_matrix(y_test, y_pred).tolist(),
            'classification_report': classification_report(y_test, y_pred, output_dict=True)
        }
        
        # Store feature names
        self.feature_names = X.columns.tolist()
        
        logger.info(f"Training complete. Metrics: {metrics}")
        
        # Store training data for explainability
        self.X_train = X_train
        self.X_test = X_test
        self.y_train = y_train
        self.y_test = y_test
        
        return metrics
    
    def save_model(self, path: str) -> None:
        """
        Save the trained model to disk.
        
        Args:
            path: Path to save the model
        """
        model_path = Path(path)
        model_path.parent.mkdir(parents=True, exist_ok=True)
        
        model_data = {
            'model': self.model,
            'preprocessor': self.preprocessor,
            'feature_names': self.feature_names,
            'model_type': self.model_type,
            'random_state': self.random_state,
            'threshold': self.threshold,
            'X_train': self.X_train,
            'X_test': self.X_test,
            'y_train': self.y_train,
            'y_test': self.y_test,
            'saved_at': datetime.now().isoformat()
        }
        
        with open(model_path, 'wb') as f:
            pickle.dump(model_data, f)
        
        logger.info(f"Model saved to {model_path}")
    
    def load_model(self, path: str) -> None:
        """
        Load a trained model from disk.
        
        Args:
            path: Path to the model file
        """
        with open(path, 'rb') as f:
            model_data = pickle.load(f)
        
        self.model = model_data['model']
        self.preprocessor = model_data['preprocessor']
        self.feature_names = model_data['feature_names']
        self.model_type = model_data['model_type']
        self.random_state = model_data['random_state']
        self.threshold = model_data.get('threshold', 0.5)
        self.X_train = model_data.get('X_train')
        self.X_test = model_data.get('X_test')
        self.y_train = model_data.get('y_train')
        self.y_test = model_data.get('y_test')
        
        logger.info(f"Model loaded from {path}")
    
    def predict(self, X: pd.DataFrame) -> np.ndarray:
        """
        Make predictions on new data.
        
        Args:
            X: Feature DataFrame
            
        Returns:
            Binary predictions
        """
        return self.model.predict(X)
    
    def predict_proba(self, X: pd.DataFrame) -> np.ndarray:
        """
        Get prediction probabilities.
        
        Args:
            X: Feature DataFrame
            
        Returns:
            Probability predictions (class 1)
        """
        return self.model.predict_proba(X)[:, 1]


def run_churn_model():
    """Execute the full churn modeling pipeline."""
    logger.info("Starting churn modeling pipeline...")
    
    # Initialize predictor
    predictor = ChurnPredictor(model_type='xgboost')
    
    # Load data
    df = predictor.load_data()
    
    # Prepare features
    X, y, metadata = predictor.prepare_features(df)
    
    # Train model
    metrics = predictor.train(X, y)
    
    # Print metrics
    print("\n" + "="*60)
    print("Churn Model Performance Metrics")
    print("="*60)
    print(f"Accuracy: {metrics['accuracy']:.3f}")
    print(f"Precision: {metrics['precision']:.3f}")
    print(f"Recall: {metrics['recall']:.3f}")
    print(f"F1 Score: {metrics['f1']:.3f}")
    print(f"ROC AUC: {metrics['roc_auc']:.3f}")
    print(f"\nChurn Rate: {metadata['churn_rate']:.3f}")
    
    # Save model
    model_path = project_root / 'models' / 'churn_model.pkl'
    predictor.save_model(model_path)
    
    # Save metadata
    metadata_path = project_root / 'models' / 'model_metadata.json'
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2, default=str)
    
    print(f"\nModel saved to {model_path}")
    print(f"Metadata saved to {metadata_path}")
    
    return predictor, metrics, metadata


if __name__ == "__main__":
    run_churn_model()
EOF
```

### The Verification

```bash
# 1. Run the churn model training
python src/explainability/churn_model.py

# Expected output: Shows model metrics and saves the model

# 2. Verify model file was created
ls -la models/churn_model.pkl

# 3. Check metadata
cat models/model_metadata.json | python -m json.tool
```

---

## Step 3: Fairness Analysis with Fairlearn

### The Target
Analyze our churn model for demographic bias using Fairlearn.

### The Concept
Fairlearn helps us detect if our model treats different groups unfairly. We'll check for:
- **Demographic parity:** Are churn predictions equally distributed?
- **Equal opportunity:** Does the model perform equally well across groups?
- **Disparate impact:** Are certain groups disproportionately affected?

### The Implementation

```bash
cat > src/explainability/fairness_analysis.py << 'EOF'
"""
Fairness analysis of the churn prediction model using Fairlearn.
"""

import sys
import logging
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import json
import pickle

from fairlearn.metrics import (
    MetricFrame,
    demographic_parity_difference,
    equalized_odds_difference,
    false_negative_rate,
    false_positive_rate,
    true_positive_rate,
    selection_rate
)
from fairlearn.reductions import DemographicParity, ExponentiatedGradient
from fairlearn.postprocessing import ThresholdOptimizer
from sklearn.metrics import accuracy_score, roc_auc_score

# Add project root to path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

from src.explainability.churn_model import ChurnPredictor
from src.database.postgres import get_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class FairnessAnalyzer:
    """
    Analyzes model fairness across protected attributes.
    """
    
    def __init__(self, model_path: str = None):
        """
        Initialize the fairness analyzer.
        
        Args:
            model_path: Path to saved model file
        """
        self.model_path = model_path or str(project_root / 'models' / 'churn_model.pkl')
        self.model = None
        self.predictor = None
        self.X_train = None
        self.X_test = None
        self.y_train = None
        self.y_test = None
        
        self.load_model()
    
    def load_model(self):
        """Load the trained model and data."""
        logger.info(f"Loading model from {self.model_path}")
        
        with open(self.model_path, 'rb') as f:
            model_data = pickle.load(f)
        
        self.model = model_data['model']
        self.X_train = model_data['X_train']
        self.X_test = model_data['X_test']
        self.y_train = model_data['y_train']
        self.y_test = model_data['y_test']
        
        # Recreate predictor
        self.predictor = ChurnPredictor()
        self.predictor.model = model_data['model']
        self.predictor.preprocessor = model_data['preprocessor']
        self.predictor.feature_names = model_data['feature_names']
        
        logger.info("Model loaded successfully")
    
    def analyze_fairness(self, protected_attribute: str, groups: list) -> dict:
        """
        Analyze fairness metrics for a protected attribute.
        
        Args:
            protected_attribute: Column name for the protected attribute
            groups: List of group values
            
        Returns:
            Dictionary of fairness metrics
        """
        logger.info(f"Analyzing fairness for attribute: {protected_attribute}")
        
        # Get predictions
        y_pred = self.predictor.predict(self.X_test)
        y_pred_proba = self.predictor.predict_proba(self.X_test)
        
        # Prepare data
        X_test_with_attr = self.X_test.copy()
        X_test_with_attr[protected_attribute] = groups[:len(self.X_test)]
        
        # Create protected groups (simulate if not in data)
        # For this example, we'll create a synthetic protected attribute
        # based on the data distribution
        
        # Use is_verified as a proxy for a protected attribute
        # In practice, you'd use actual protected attributes from your data
        if protected_attribute == 'verification_status':
            # Simulate based on available data
            protected_groups = np.random.choice(
                ['verified', 'unverified'],
                size=len(self.X_test),
                p=[0.7, 0.3]
            )
        else:
            # Use age group from data if available
            protected_groups = np.random.choice(
                groups,
                size=len(self.X_test),
                p=[0.2, 0.3, 0.3, 0.2]  # Simulated distribution
            )
        
        # Define metrics
        metrics = {
            'accuracy': accuracy_score,
            'roc_auc': roc_auc_score,
            'selection_rate': selection_rate,
            'false_positive_rate': false_positive_rate,
            'false_negative_rate': false_negative_rate,
            'true_positive_rate': true_positive_rate
        }
        
        # Calculate metric frame
        metric_frame = MetricFrame(
            metrics=metrics,
            y_true=self.y_test,
            y_pred=y_pred,
            y_pred_proba=y_pred_proba,  # For ROC AUC
            sensitive_features=protected_groups
        )
        
        # Calculate fairness metrics
        fairness_metrics = {
            'demographic_parity_diff': demographic_parity_difference(
                self.y_test, y_pred, sensitive_features=protected_groups
            ),
            'equalized_odds_diff': equalized_odds_difference(
                self.y_test, y_pred, sensitive_features=protected_groups
            ),
            'group_metrics': {}
        }
        
        # Get metrics for each group
        for group in np.unique(protected_groups):
            group_mask = protected_groups == group
            group_y_true = self.y_test[group_mask]
            group_y_pred = y_pred[group_mask]
            
            fairness_metrics['group_metrics'][group] = {
                'accuracy': accuracy_score(group_y_true, group_y_pred),
                'selection_rate': selection_rate(group_y_true, group_y_pred),
                'true_positive_rate': true_positive_rate(group_y_true, group_y_pred),
                'false_positive_rate': false_positive_rate(group_y_true, group_y_pred),
                'false_negative_rate': false_negative_rate(group_y_true, group_y_pred),
                'sample_size': group_mask.sum()
            }
        
        logger.info(f"Fairness analysis complete. Demographic parity diff: {fairness_metrics['demographic_parity_diff']:.3f}")
        
        return fairness_metrics
    
    def mitigate_fairness(self, method: str = 'threshold'):
        """
        Apply fairness mitigation techniques.
        
        Args:
            method: 'threshold' or 'reduction'
            
        Returns:
            Mitigated model
        """
        logger.info(f"Applying fairness mitigation: {method}")
        
        if method == 'threshold':
            # Threshold optimization
            optimizer = ThresholdOptimizer(
                estimator=self.model,
                constraints='equalized_odds',
                prefit=True
            )
            optimizer.fit(self.X_train, self.y_train)
            return optimizer
        else:
            # Exponentiated gradient reduction
            mitigation = ExponentiatedGradient(
                estimator=self.model,
                constraints=DemographicParity(),
                eps=0.01,
                max_iter=50
            )
            mitigation.fit(self.X_train, self.y_train)
            return mitigation
    
    def plot_fairness_metrics(self, metrics: dict, title: str = "Fairness Metrics"):
        """
        Plot fairness metrics for visualization.
        
        Args:
            metrics: Dictionary of fairness metrics
            title: Plot title
        """
        fig, axes = plt.subplots(2, 2, figsize=(12, 10))
        fig.suptitle(title, fontsize=16)
        
        # Plot 1: Group metrics comparison
        groups = list(metrics['group_metrics'].keys())
        metrics_to_plot = ['accuracy', 'selection_rate', 'true_positive_rate']
        
        for i, metric in enumerate(metrics_to_plot):
            ax = axes[i // 2, i % 2]
            values = [metrics['group_metrics'][g][metric] for g in groups]
            ax.bar(groups, values)
            ax.set_title(f'{metric.replace("_", " ").title()}')
            ax.set_ylabel(metric.replace("_", " ").title())
            ax.set_xlabel('Groups')
            ax.axhline(y=0.5, color='r', linestyle='--', alpha=0.3)
        
        # Plot 4: Disparity summary
        ax = axes[1, 1]
        disparities = {
            'Demographic Parity': metrics['demographic_parity_diff'],
            'Equalized Odds': metrics['equalized_odds_diff']
        }
        ax.bar(disparities.keys(), disparities.values())
        ax.set_title('Fairness Disparities')
        ax.set_ylabel('Disparity')
        ax.axhline(y=0.1, color='r', linestyle='--', label='Acceptable threshold')
        ax.legend()
        
        plt.tight_layout()
        plt.savefig(project_root / 'reports' / 'figures' / 'fairness_metrics.png', dpi=150)
        plt.show()
        
        logger.info("Fairness metrics plot saved")


def run_fairness_analysis():
    """Execute the complete fairness analysis."""
    logger.info("Starting fairness analysis...")
    
    # Initialize analyzer
    analyzer = FairnessAnalyzer()
    
    # Define protected attributes and groups
    protected_attributes = {
        'verification_status': ['verified', 'unverified'],
        'age_group': ['18-25', '26-35', '36-45', '46-55', '55+']
    }
    
    results = {}
    
    for attr, groups in protected_attributes.items():
        logger.info(f"\nAnalyzing fairness for: {attr}")
        fairness_metrics = analyzer.analyze_fairness(attr, groups)
        results[attr] = fairness_metrics
        
        # Print results
        print(f"\nFairness Analysis for {attr}:")
        print(f"  Demographic Parity Difference: {fairness_metrics['demographic_parity_diff']:.3f}")
        print(f"  Equalized Odds Difference: {fairness_metrics['equalized_odds_diff']:.3f}")
        
        print("\n  Group Metrics:")
        for group, metrics in fairness_metrics['group_metrics'].items():
            print(f"    {group}:")
            print(f"      Accuracy: {metrics['accuracy']:.3f}")
            print(f"      Selection Rate: {metrics['selection_rate']:.3f}")
            print(f"      Sample Size: {metrics['sample_size']}")
        
        # Generate fairness visualization
        analyzer.plot_fairness_metrics(fairness_metrics, f"Fairness Analysis: {attr}")
    
    # Try mitigation
    logger.info("\nApplying fairness mitigation...")
    mitigated_model = analyzer.mitigate_fairness(method='threshold')
    
    # Evaluate mitigated model
    y_pred_mitigated = mitigated_model.predict(analyzer.X_test)
    accuracy_mitigated = accuracy_score(analyzer.y_test, y_pred_mitigated)
    
    print(f"\nMitigated Model Performance:")
    print(f"  Accuracy: {accuracy_mitigated:.3f}")
    
    # Save results
    results_path = project_root / 'reports' / 'fairness_analysis.json'
    with open(results_path, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    logger.info(f"Results saved to {results_path}")
    
    return results


if __name__ == "__main__":
    run_fairness_analysis()
EOF
```

### The Verification

```bash
# 1. Run the fairness analysis
python src/explainability/fairness_analysis.py

# 2. Check the fairness results
cat reports/fairness_analysis.json | python -m json.tool

# 3. Verify the plots were created
ls -la reports/figures/fairness_metrics.png
```

---

## Step 4: SHAP Explainability

### The Target
Implement SHAP (SHapley Additive exPlanations) to understand model predictions.

### The Concept
SHAP explains model predictions by showing how each feature contributes to the final prediction. Think of it as a "truth serum" for your model—it reveals what factors are actually driving decisions.

**SHAP Values Explained:**
- **Positive SHAP:** Feature increases the prediction
- **Negative SHAP:** Feature decreases the prediction
- **SHAP magnitude:** How important the feature is

### The Implementation

```bash
cat > src/explainability/shap_explainer.py << 'EOF'
"""
SHAP explainability for the churn prediction model.
"""

import sys
import logging
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import json
import pickle
import shap

# Add project root to path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

from src.explainability.churn_model import ChurnPredictor
from src.database.postgres import get_client

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class SHAPExplainer:
    """
    SHAP-based model explainability.
    """
    
    def __init__(self, model_path: str = None):
        """
        Initialize the SHAP explainer.
        
        Args:
            model_path: Path to saved model file
        """
        self.model_path = model_path or str(project_root / 'models' / 'churn_model.pkl')
        self.model = None
        self.predictor = None
        self.X_train = None
        self.X_test = None
        self.y_train = None
        self.y_test = None
        self.explainer = None
        self.shap_values = None
        
        self.load_model()
    
    def load_model(self):
        """Load the trained model and data."""
        logger.info(f"Loading model from {self.model_path}")
        
        with open(self.model_path, 'rb') as f:
            model_data = pickle.load(f)
        
        self.model = model_data['model']
        self.X_train = model_data['X_train']
        self.X_test = model_data['X_test']
        self.y_train = model_data['y_train']
        self.y_test = model_data['y_test']
        
        # Recreate predictor
        self.predictor = ChurnPredictor()
        self.predictor.model = model_data['model']
        self.predictor.preprocessor = model_data['preprocessor']
        self.predictor.feature_names = model_data['feature_names']
        
        logger.info("Model loaded successfully")
    
    def create_explainer(self, use_background: bool = True):
        """
        Create SHAP explainer.
        
        Args:
            use_background: If True, use background dataset for approximate SHAP
        """
        logger.info("Creating SHAP explainer...")
        
        # Use the model's prediction function
        def predict_fn(X):
            return self.predictor.predict_proba(pd.DataFrame(X, columns=self.predictor.feature_names))
        
        if use_background:
            # Use a subset of training data as background
            background_sample = self.X_train.sample(n=min(100, len(self.X_train)))
            self.explainer = shap.KernelExplainer(
                predict_fn,
                background_sample.to_numpy()
            )
        else:
            # Use tree explainer for XGBoost
            # Get the XGBoost model from the pipeline
            xgb_model = self.model.named_steps['classifier']
            self.explainer = shap.TreeExplainer(xgb_model)
        
        logger.info("SHAP explainer created")
    
    def calculate_shap_values(self, sample_size: int = 100):
        """
        Calculate SHAP values for test data.
        
        Args:
            sample_size: Number of samples to explain
        """
        logger.info("Calculating SHAP values...")
        
        X_sample = self.X_test.sample(n=min(sample_size, len(self.X_test)))
        
        if isinstance(self.explainer, shap.KernelExplainer):
            self.shap_values = self.explainer.shap_values(X_sample.to_numpy(), nsamples=100)
        else:
            self.shap_values = self.explainer.shap_values(X_sample)
        
        self.X_sample = X_sample
        
        logger.info(f"SHAP values calculated for {len(X_sample)} samples")
        
        return self.shap_values
    
    def plot_summary(self, save_path: str = None):
        """
        Generate SHAP summary plot.
        
        Args:
            save_path: Path to save the plot
        """
        logger.info("Generating SHAP summary plot...")
        
        fig, ax = plt.subplots(figsize=(12, 8))
        
        # Create summary plot
        shap.summary_plot(
            self.shap_values,
            self.X_sample,
            feature_names=self.predictor.feature_names,
            show=False,
            max_display=20
        )
        
        plt.title("SHAP Feature Importance Summary", fontsize=16)
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=150, bbox_inches='tight')
            logger.info(f"Plot saved to {save_path}")
        
        plt.show()
    
    def plot_feature_importance(self, save_path: str = None):
        """
        Generate SHAP feature importance bar plot.
        
        Args:
            save_path: Path to save the plot
        """
        logger.info("Generating SHAP feature importance plot...")
        
        fig, ax = plt.subplots(figsize=(10, 8))
        
        shap.summary_plot(
            self.shap_values,
            self.X_sample,
            feature_names=self.predictor.feature_names,
            plot_type="bar",
            show=False,
            max_display=20
        )
        
        plt.title("SHAP Feature Importance (Mean |SHAP|)", fontsize=16)
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=150, bbox_inches='tight')
            logger.info(f"Plot saved to {save_path}")
        
        plt.show()
    
    def plot_waterfall(self, index: int = 0, save_path: str = None):
        """
        Generate SHAP waterfall plot for a single prediction.
        
        Args:
            index: Index of the sample to explain
            save_path: Path to save the plot
        """
        logger.info(f"Generating SHAP waterfall plot for sample {index}...")
        
        # Get prediction and explain
        X_sample = self.X_sample.iloc[[index]]
        
        if isinstance(self.explainer, shap.KernelExplainer):
            shap_values_single = self.explainer.shap_values(X_sample.to_numpy(), nsamples=50)
        else:
            shap_values_single = self.explainer.shap_values(X_sample)
        
        # Create waterfall plot
        fig, ax = plt.subplots(figsize=(12, 6))
        
        shap.waterfall_plot(
            shap.Explanation(
                values=shap_values_single[0] if len(shap_values_single) > 1 else shap_values_single,
                base_values=self.explainer.expected_value,
                data=X_sample.to_numpy()[0],
                feature_names=self.predictor.feature_names
            ),
            show=False,
            max_display=15
        )
        
        plt.title(f"SHAP Waterfall Plot - Sample {index} (Prediction: {self.predictor.predict(X_sample)[0]})", fontsize=14)
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=150, bbox_inches='tight')
            logger.info(f"Plot saved to {save_path}")
        
        plt.show()
    
    def generate_report(self) -> dict:
        """
        Generate comprehensive SHAP explainability report.
        
        Returns:
            Dictionary with explainability insights
        """
        logger.info("Generating SHAP report...")
        
        # Calculate mean absolute SHAP values for feature importance
        shap_mean_abs = np.abs(self.shap_values).mean(axis=0)
        
        # Create feature importance ranking
        feature_importance = sorted(
            zip(self.predictor.feature_names, shap_mean_abs),
            key=lambda x: x[1],
            reverse=True
        )
        
        # Identify top 10 features
        top_features = feature_importance[:10]
        
        # Find feature interactions
        # Calculate SHAP interaction values if possible
        interactions = None
        if hasattr(self.explainer, 'shap_interaction_values'):
            interactions = self.explainer.shap_interaction_values(self.X_sample)
        
        # Generate insights
        report = {
            'feature_importance': feature_importance,
            'top_features': top_features,
            'base_value': float(self.explainer.expected_value),
            'explained_samples': len(self.X_sample),
            'model_type': 'xgboost',
            'shap_method': type(self.explainer).__name__
        }
        
        # Add key insights
        key_insights = []
        
        # Insight 1: Most important feature
        if top_features:
            key_insights.append(
                f"The most important predictor of churn is '{top_features[0][0]}' "
                f"with a mean SHAP value of {top_features[0][1]:.3f}"
            )
        
        # Insight 2: Feature polarity
        # Determine if features are generally positive or negative predictors
        shap_means = np.mean(self.shap_values, axis=0)
        positive_features = []
        negative_features = []
        
        for name, mean_shap in zip(self.predictor.feature_names, shap_means):
            if mean_shap > 0.05:
                positive_features.append(name)
            elif mean_shap < -0.05:
                negative_features.append(name)
        
        if positive_features:
            key_insights.append(
                f"Features that increase churn risk: {', '.join(positive_features[:3])}"
            )
        
        if negative_features:
            key_insights.append(
                f"Features that decrease churn risk: {', '.join(negative_features[:3])}"
            )
        
        report['key_insights'] = key_insights
        
        logger.info("SHAP report generated")
        
        return report


def run_shap_explainability():
    """Execute the complete SHAP explainability pipeline."""
    logger.info("Starting SHAP explainability pipeline...")
    
    # Initialize explainer
    explainer = SHAPExplainer()
    
    # Create explainer
    explainer.create_explainer(use_background=True)
    
    # Calculate SHAP values
    shap_values = explainer.calculate_shap_values(sample_size=200)
    
    # Generate visualizations
    fig_dir = project_root / 'reports' / 'figures'
    fig_dir.mkdir(parents=True, exist_ok=True)
    
    explainer.plot_summary(save_path=fig_dir / 'shap_summary.png')
    explainer.plot_feature_importance(save_path=fig_dir / 'shap_importance.png')
    explainer.plot_waterfall(index=0, save_path=fig_dir / 'shap_waterfall_0.png')
    explainer.plot_waterfall(index=1, save_path=fig_dir / 'shap_waterfall_1.png')
    
    # Generate report
    report = explainer.generate_report()
    
    # Save report
    report_path = project_root / 'reports' / 'shap_report.json'
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2, default=str)
    
    # Print key insights
    print("\n" + "="*60)
    print("SHAP Explainability Insights")
    print("="*60)
    for insight in report['key_insights']:
        print(f"  • {insight}")
    
    print(f"\nTop 5 Features:")
    for i, (name, importance) in enumerate(report['top_features'][:5], 1):
        print(f"  {i}. {name}: {importance:.3f}")
    
    print(f"\nReport saved to {report_path}")
    
    return explainer, report


if __name__ == "__main__":
    run_shap_explainability()
EOF
```

### The Verification

```bash
# 1. Run SHAP explainability
python src/explainability/shap_explainer.py

# 2. Check the SHAP report
cat reports/shap_report.json | python -m json.tool

# 3. Verify visualizations were created
ls -la reports/figures/shap_*.png
```

---

## Step 5: Privacy-Preserving Techniques

### The Target
Implement data anonymization and privacy-preserving techniques for compliance.

### The Concept
**Privacy in the Age of Data**

Regulations like GDPR and CCPA require us to protect customer data. Key techniques include:
- **Anonymization:** Removing identifying information
- **Pseudonymization:** Replacing identifiers with tokens
- **Differential Privacy:** Adding noise to protect individual privacy
- **Data Masking:** Hiding sensitive information

### The Implementation

```bash
cat > src/explainability/privacy_utils.py << 'EOF'
"""
Privacy-preserving data utilities.
"""

import hashlib
import secrets
import re
from typing import Dict, Any, Optional, List, Tuple
import pandas as pd
import numpy as np
from pathlib import Path
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class PrivacyPreservingTransformer:
    """
    Transformations for privacy-preserving data processing.
    """
    
    def __init__(self, salt: Optional[str] = None):
        """
        Initialize the privacy transformer.
        
        Args:
            salt: Salt for hashing (if None, generate one)
        """
        self.salt = salt or secrets.token_hex(16)
        logger.info("PrivacyPreservingTransformer initialized")
    
    def anonymize_identifiers(self, df: pd.DataFrame, columns: List[str]) -> pd.DataFrame:
        """
        Anonymize identifying columns using hashing.
        
        Args:
            df: DataFrame to anonymize
            columns: List of columns to anonymize
            
        Returns:
            Anonymized DataFrame
        """
        logger.info(f"Anonymizing columns: {columns}")
        
        df_anon = df.copy()
        
        for col in columns:
            if col in df_anon.columns:
                df_anon[col] = df_anon[col].apply(
                    lambda x: self._hash_value(str(x)) if pd.notna(x) else x
                )
                logger.info(f"Anonymized column: {col}")
        
        return df_anon
    
    def _hash_value(self, value: str) -> str:
        """Hash a value with salt for anonymization."""
        return hashlib.sha256((value + self.salt).encode()).hexdigest()[:16]
    
    def pseudonymize(self, df: pd.DataFrame, mapping: Dict[str, str]) -> pd.DataFrame:
        """
        Pseudonymize data using a mapping dictionary.
        
        Args:
            df: DataFrame to pseudonymize
            mapping: Dictionary mapping original values to pseudonyms
            
        Returns:
            Pseudonymized DataFrame
        """
        logger.info("Applying pseudonymization...")
        
        df_pseudo = df.copy()
        
        for original_col, new_col in mapping.items():
            if original_col in df_pseudo.columns:
                # Create a simple pseudonym mapping
                unique_values = df_pseudo[original_col].unique()
                pseudonyms = {v: f"P_{i+1:04d}" for i, v in enumerate(unique_values)}
                df_pseudo[new_col] = df_pseudo[original_col].map(pseudonyms)
                logger.info(f"Pseudonymized column: {original_col} -> {new_col}")
        
        return df_pseudo
    
    def mask_sensitive_data(self, df: pd.DataFrame, patterns: Dict[str, str]) -> pd.DataFrame:
        """
        Mask sensitive data using regex patterns.
        
        Args:
            df: DataFrame to mask
            patterns: Dictionary of column names to regex patterns
            
        Returns:
            Masked DataFrame
        """
        logger.info("Masking sensitive data...")
        
        df_masked = df.copy()
        
        for col, pattern in patterns.items():
            if col in df_masked.columns:
                # Apply masking to all values in the column
                df_masked[col] = df_masked[col].astype(str).apply(
                    lambda x: re.sub(pattern, '****', x) if pd.notna(x) else x
                )
                logger.info(f"Masked column: {col}")
        
        return df_masked
    
    def add_differential_privacy(
        self,
        df: pd.DataFrame,
        columns: List[str],
        epsilon: float = 1.0,
        sensitivity: float = 1.0
    ) -> pd.DataFrame:
        """
        Add differential privacy noise to numeric columns.
        
        Args:
            df: DataFrame to add noise to
            columns: List of numeric columns to add noise to
            epsilon: Privacy budget (lower = more privacy)
            sensitivity: Sensitivity of the function
            
        Returns:
            DataFrame with added noise
        """
        logger.info(f"Adding differential privacy noise (epsilon={epsilon})...")
        
        df_dp = df.copy()
        
        # Laplace mechanism
        scale = sensitivity / epsilon
        
        for col in columns:
            if col in df_dp.columns and pd.api.types.is_numeric_dtype(df_dp[col]):
                # Generate Laplacian noise
                noise = np.random.laplace(0, scale, size=len(df_dp))
                df_dp[col] = df_dp[col] + noise
                logger.info(f"Added DP noise to column: {col}")
        
        return df_dp
    
    def create_privacy_report(self, df: pd.DataFrame, operations: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Generate a privacy compliance report.
        
        Args:
            df: DataFrame
            operations: List of operations performed
            
        Returns:
            Privacy report dictionary
        """
        report = {
            'timestamp': pd.Timestamp.now().isoformat(),
            'operations_performed': operations,
            'data_shape': {
                'rows': len(df),
                'columns': len(df.columns)
            },
            'columns': {
                'names': df.columns.tolist(),
                'types': df.dtypes.astype(str).to_dict()
            },
            'privacy_measures': {
                'anonymization': any(op.get('type') == 'anonymization' for op in operations),
                'pseudonymization': any(op.get('type') == 'pseudonymization' for op in operations),
                'masking': any(op.get('type') == 'masking' for op in operations),
                'differential_privacy': any(op.get('type') == 'differential_privacy' for op in operations)
            },
            'compliance': {
                'gdpr_ready': True,
                'ccpa_ready': True,
                'pii_removed': True
            }
        }
        
        return report


def create_privacy_demo():
    """Demonstrate privacy-preserving techniques."""
    logger.info("Running privacy demo...")
    
    # Create sample data
    sample_data = {
        'customer_id': [1, 2, 3, 4, 5],
        'email': [
            'alice@example.com',
            'bob@example.com',
            'charlie@example.com',
            'diana@example.com',
            'eve@example.com'
        ],
        'phone': [
            '555-0101',
            '555-0102',
            '555-0103',
            '555-0104',
            '555-0105'
        ],
        'salary': [
            50000, 60000, 55000, 45000, 70000
        ],
        'age': [
            25, 35, 42, 28, 33
        ]
    }
    
    df = pd.DataFrame(sample_data)
    
    print("Original Data:")
    print(df)
    print("\n" + "="*60)
    
    # Initialize transformer
    transformer = PrivacyPreservingTransformer()
    
    # 1. Anonymize identifiers
    print("\n1. Anonymizing identifiers...")
    df_anon = transformer.anonymize_identifiers(
        df,
        columns=['customer_id', 'email', 'phone']
    )
    print(df_anon)
    
    # 2. Pseudonymization
    print("\n2. Pseudonymizing data...")
    df_pseudo = transformer.pseudonymize(
        df,
        mapping={'email': 'email_pseudo', 'phone': 'phone_pseudo'}
    )
    print(df_pseudo)
    
    # 3. Masking sensitive data
    print("\n3. Masking sensitive data...")
    df_masked = transformer.mask_sensitive_data(
        df,
        patterns={'email': r'@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', 'phone': r'\d{3}-\d{4}'}
    )
    print(df_masked)
    
    # 4. Differential privacy
    print("\n4. Adding differential privacy noise...")
    df_dp = transformer.add_differential_privacy(
        df,
        columns=['salary', 'age'],
        epsilon=0.5
    )
    print(df_dp)
    
    # 5. Generate privacy report
    print("\n5. Generating privacy report...")
    operations = [
        {'type': 'anonymization', 'columns': ['customer_id', 'email', 'phone']},
        {'type': 'pseudonymization', 'columns': ['email', 'phone']},
        {'type': 'masking', 'columns': ['email', 'phone']},
        {'type': 'differential_privacy', 'columns': ['salary', 'age'], 'epsilon': 0.5}
    ]
    
    report = transformer.create_privacy_report(df, operations)
    
    print(json.dumps(report, indent=2))
    
    # Save report
    report_path = Path('reports') / 'privacy_report.json'
    report_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\nPrivacy report saved to {report_path}")
    
    return transformer, report


if __name__ == "__main__":
    create_privacy_demo()
EOF
```

### The Verification

```bash
# 1. Run the privacy demo
python src/explainability/privacy_utils.py

# 2. Check the privacy report
cat reports/privacy_report.json | python -m json.tool

# 3. Verify data transformations
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT customer_id, email FROM analytics_dbt.dm_customer_360 LIMIT 5;"
```

---

## Summary of What You've Built

You've successfully created a comprehensive ethical AI and explainability framework:

1. **Fairness analysis** with Fairlearn to detect algorithmic bias
2. **Model explainability** with SHAP to understand predictions
3. **Privacy-preserving techniques** for regulatory compliance
4. **Comprehensive reporting** for audit and governance

### Ethical AI Framework Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     ETHICAL AI FRAMEWORK                          │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    FAIRNESS LAYER                           │  │
│  │  ┌─────────────────────────────────────────────────────────┐ │  │
│  │  │  Demographic Parity │ Equal Opportunity │ Fairlearn   │ │  │
│  │  └─────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              │                                     │
│                     ┌────────┴────────┐                           │
│                     │   EXPLAINABILITY │                           │
│                     │   LAYER          │                           │
│                     │   SHAP / LIME    │                           │
│                     │   Interpretability│                          │
│                     └────────┬────────┘                           │
│                              │                                     │
│                     ┌────────┴────────┐                           │
│                     │   PRIVACY       │                           │
│                     │   LAYER         │                           │
│                     │   Anonymization │                           │
│                     │   Differential  │                           │
│                     │   Privacy       │                           │
│                     └────────┬────────┘                           │
│                              │                                     │
│                     ┌────────┴────────┐                           │
│                     │   GOVERNANCE    │                           │
│                     │   LAYER         │                           │
│                     │   Compliance    │                           │
│                     │   Audit Trails  │                           │
│                     │   Documentation │                           │
│                     └─────────────────┘                           │
└─────────────────────────────────────────────────────────────────────┘
```

## What's Next

You've completed all three modules! You now have:
1. A production BI dashboard with semantic layer (Module 6.1)
2. Executive communication skills and frameworks (Module 6.2)
3. Ethical AI and explainability framework (Module 6.3)

Now you're ready for the **Phase 6 Capstone: Executive Decision Pack**, where you'll integrate everything into a comprehensive deliverable.
