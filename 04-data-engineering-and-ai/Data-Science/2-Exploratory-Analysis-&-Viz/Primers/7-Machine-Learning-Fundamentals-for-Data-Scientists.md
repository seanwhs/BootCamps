# Primer 7: Machine Learning Fundamentals for Data Scientists

## Core Concepts for Understanding and Applying ML to Customer Data

---

#### Purpose of This Primer

This primer covers the machine learning fundamentals you'll need as you move beyond exploratory analysis into predictive modeling. While the main series focuses on EDA and visualization, understanding ML concepts helps you:
- Recognize patterns worth modeling
- Design effective features
- Evaluate model performance
- Communicate with data science teams
- Prepare for Phase 3: Feature Engineering & Modeling

---

## P7.1 What is Machine Learning?

### P7.1.1 Definition and Types

**Machine Learning:** A subset of artificial intelligence where systems learn patterns from data without being explicitly programmed.

**The Three Main Types:**

```
Machine Learning
├── Supervised Learning
│   ├── Regression (predict continuous values)
│   │   └── Example: Predict customer lifetime value
│   └── Classification (predict categories)
│       └── Example: Predict if customer will churn
├── Unsupervised Learning
│   ├── Clustering (group similar items)
│   │   └── Example: Segment customers by behavior
│   └── Dimensionality Reduction (simplify data)
│       └── Example: PCA for visualization
└── Reinforcement Learning
    └── Learn through trial and error
        └── Example: Dynamic pricing optimization
```

### P7.1.2 The ML Workflow

```python
# 1. Define the problem
#    - What are we predicting?
#    - What data do we need?

# 2. Collect and prepare data
#    - Load data
#    - Clean missing values
#    - Handle outliers

# 3. Feature engineering
#    - Create new features
#    - Transform existing features
#    - Select important features

# 4. Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# 5. Train model
model = RandomForestClassifier()
model.fit(X_train, y_train)

# 6. Evaluate model
predictions = model.predict(X_test)
accuracy = accuracy_score(y_test, predictions)

# 7. Deploy model
#    - Save model
#    - Create API
#    - Monitor performance

# 8. Iterate
#    - Improve features
#    - Try different models
#    - Update with new data
```

---

## P7.2 Supervised Learning

### P7.2.1 Regression

**Purpose:** Predict continuous numerical values.

**Common Algorithms:**

| Algorithm | When to Use | Pros | Cons |
|-----------|-------------|------|------|
| **Linear Regression** | Simple, linear relationships | Fast, interpretable | Can't capture complex patterns |
| **Ridge/Lasso** | Many features, multicollinearity | Handles overfitting | Less interpretable |
| **Decision Tree** | Non-linear relationships | Interpretable, handles non-linearity | Prone to overfitting |
| **Random Forest** | Complex patterns, high-dimensional | Powerful, handles non-linearity | Less interpretable |
| **Gradient Boosting** | Complex patterns, high accuracy | State-of-the-art performance | Slow training, can overfit |

**Example: Predicting Customer Lifetime Value**

```python
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score

# Prepare features
X = df[['age', 'order_frequency', 'avg_order_value', 'time_on_site']]
y = df['customer_lifetime_value']

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train model
model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Predict and evaluate
y_pred = model.predict(X_test)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))
r2 = r2_score(y_test, y_pred)

print(f"RMSE: {rmse:.2f}")
print(f"R²: {r2:.2f}")
```

### P7.2.2 Classification

**Purpose:** Predict categorical outcomes.

**Common Algorithms:**

| Algorithm | When to Use | Pros | Cons |
|-----------|-------------|------|------|
| **Logistic Regression** | Binary classification | Fast, interpretable, probabilities | Linear decision boundary |
| **Decision Tree** | Interpretable classification | Visual, handles mixed data | Prone to overfitting |
| **Random Forest** | High accuracy, complex data | Powerful, handles non-linearity | Less interpretable |
| **XGBoost** | Competition-level accuracy | State-of-the-art performance | Complex tuning |
| **SVM** | High-dimensional data | Effective in high dimensions | Slow, less interpretable |
| **Naive Bayes** | Text classification | Fast, works with small data | Independence assumption |

**Example: Predicting Customer Churn**

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report

# Prepare features
X = df[['age', 'order_frequency', 'avg_order_value', 'customer_rating', 'return_rate']]
y = df['churn']  # 0 = not churned, 1 = churned

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# Train model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Predict and evaluate
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
cm = confusion_matrix(y_test, y_pred)

print(f"Accuracy: {accuracy:.2%}")
print("\nConfusion Matrix:")
print(cm)
print("\nClassification Report:")
print(classification_report(y_test, y_pred))

# Feature importance
importances = model.feature_importances_
for feature, importance in zip(X.columns, importances):
    print(f"{feature}: {importance:.3f}")
```

### P7.2.3 Evaluation Metrics

#### Regression Metrics

```python
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# Mean Absolute Error (MAE)
mae = mean_absolute_error(y_test, y_pred)

# Mean Squared Error (MSE)
mse = mean_squared_error(y_test, y_pred)

# Root Mean Squared Error (RMSE)
rmse = np.sqrt(mse)

# R² Score (coefficient of determination)
r2 = r2_score(y_test, y_pred)
```

**Interpretation:**
- **MAE:** Average absolute error (same units as target)
- **RMSE:** Standard deviation of residuals (penalizes large errors)
- **R²:** Proportion of variance explained (0-1, higher is better)

#### Classification Metrics

```python
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

# Accuracy
accuracy = accuracy_score(y_test, y_pred)

# Precision
precision = precision_score(y_test, y_pred)

# Recall (Sensitivity)
recall = recall_score(y_test, y_pred)

# F1 Score (harmonic mean of precision and recall)
f1 = f1_score(y_test, y_pred)
```

**Interpretation:**
- **Accuracy:** Overall correctness (good for balanced data)
- **Precision:** Of predicted positives, how many are correct
- **Recall:** Of actual positives, how many were found
- **F1:** Balance between precision and recall

**Choosing the Right Metric:**
- **Balanced data:** Accuracy
- **Imbalanced data:** F1, AUC-ROC
- **Costly false positives:** Precision
- **Costly false negatives:** Recall

---

## P7.3 Unsupervised Learning

### P7.3.1 Clustering

**Purpose:** Group similar data points together.

**Common Algorithms:**

| Algorithm | When to Use | Pros | Cons |
|-----------|-------------|------|------|
| **K-Means** | Large datasets, spherical clusters | Fast, scalable | Assumes spherical clusters |
| **DBSCAN** | Arbitrary shapes, outliers | Finds arbitrary shapes | Sensitive to parameters |
| **Hierarchical** | Small datasets, dendrograms | Visual, hierarchical | O(n²) complexity |
| **Gaussian Mixture** | Overlapping clusters, soft assignments | Probabilistic | Can overfit |

**Example: Customer Segmentation**

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

# Prepare features
features = ['age', 'order_frequency', 'avg_order_value', 'time_on_site']
X = df[features]

# Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Find optimal number of clusters (Elbow Method)
inertias = []
for k in range(2, 11):
    kmeans = KMeans(n_clusters=k, random_state=42)
    kmeans.fit(X_scaled)
    inertias.append(kmeans.inertia_)

# Plot elbow curve
plt.plot(range(2, 11), inertias, 'o-')
plt.xlabel('Number of Clusters (k)')
plt.ylabel('Inertia')
plt.title('Elbow Method for Optimal k')
plt.show()

# Train final model
kmeans = KMeans(n_clusters=5, random_state=42)
df['segment'] = kmeans.fit_predict(X_scaled)

# Analyze segments
segment_profile = df.groupby('segment')[features].mean()
print(segment_profile)
```

### P7.3.2 Dimensionality Reduction

**Purpose:** Reduce number of features while preserving important information.

**Common Algorithms:**

| Algorithm | When to Use | Pros | Cons |
|-----------|-------------|------|------|
| **PCA** | Linear relationships, compression | Fast, interpretable | Linear only |
| **t-SNE** | Visualization, non-linear | Great for visualization | Slow, stochastic |
| **UMAP** | Visualization, non-linear | Fast, preserves structure | Complex parameters |

**Example: PCA for Visualization**

```python
from sklearn.decomposition import PCA

# Prepare features
X = df[['age', 'order_frequency', 'avg_order_value', 'time_on_site', 
        'customer_rating', 'return_rate']]

# Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_scaled)

# Create visualization
plt.figure(figsize=(10, 8))
scatter = plt.scatter(X_pca[:, 0], X_pca[:, 1], 
                     c=df['segment'], cmap='viridis', alpha=0.7)
plt.colorbar(scatter, label='Segment')
plt.xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.2%} variance)')
plt.ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.2%} variance)')
plt.title('Customer Segments in 2D (PCA)')
plt.show()
```

---

## P7.4 Feature Engineering

### P7.4.1 Types of Features

```python
# Numerical features
# - Continuous: age, order_frequency, avg_order_value
# - Discrete: pages_viewed, number_of_orders

# Categorical features
# - Nominal: gender, favorite_category, country
# - Ordinal: income_bracket, education_level

# Temporal features
# - Timestamps: account_created, last_purchase
# - Time since: days_since_last_purchase

# Text features
# - Sentiment scores, word counts, TF-IDF

# Derived features
# - Ratios: value_per_page = avg_order_value / pages_viewed
# - Interactions: age * income
# - Aggregations: average_order_value_per_category
```

### P7.4.2 Feature Transformation

```python
# Scaling
from sklearn.preprocessing import StandardScaler, MinMaxScaler, RobustScaler

# StandardScaler: mean=0, std=1 (for normal distributions)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# MinMaxScaler: [0, 1] range (for neural networks)
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)

# RobustScaler: median, IQR (for outliers)
scaler = RobustScaler()
X_scaled = scaler.fit_transform(X)

# Encoding Categorical Variables
from sklearn.preprocessing import LabelEncoder, OneHotEncoder

# Label Encoding (for ordinal)
le = LabelEncoder()
df['income_encoded'] = le.fit_transform(df['income_bracket'])

# One-Hot Encoding (for nominal)
dummies = pd.get_dummies(df['favorite_category'], prefix='category')
df = pd.concat([df, dummies], axis=1)

# Frequency Encoding
freq_map = df['country'].value_counts(normalize=True).to_dict()
df['country_freq'] = df['country'].map(freq_map)

# Target Encoding (for categorical with target)
# (Careful: risk of overfitting)
```

### P7.4.3 Feature Selection

```python
from sklearn.feature_selection import SelectKBest, f_classif, RFE
from sklearn.ensemble import RandomForestClassifier

# Method 1: Univariate Selection
selector = SelectKBest(score_func=f_classif, k=10)
X_selected = selector.fit_transform(X, y)

# Method 2: Feature Importance (Tree-based)
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)
importances = pd.DataFrame({
    'feature': X.columns,
    'importance': model.feature_importances_
}).sort_values('importance', ascending=False)

# Method 3: Recursive Feature Elimination
selector = RFE(model, n_features_to_select=10)
X_selected = selector.fit_transform(X, y)

# Method 4: L1 Regularization (Lasso)
from sklearn.linear_model import LassoCV
lasso = LassoCV(cv=5).fit(X, y)
selected_features = X.columns[lasso.coef_ != 0]
```

---

## P7.5 Model Selection and Tuning

### P7.5.1 Choosing the Right Model

**Decision Tree:**

```
1. What is the problem type?
   ├── Classification → Go to 2
   └── Regression → Go to 3

2. Is interpretability important?
   ├── Yes → Logistic Regression, Decision Tree
   └── No → Random Forest, XGBoost, SVM

3. Is interpretability important?
   ├── Yes → Linear Regression, Decision Tree
   └── No → Random Forest, XGBoost

4. Is data large?
   ├── Yes → Consider deep learning, XGBoost
   └── No → Any model works

5. Is data high-dimensional?
   ├── Yes → SVM, PCA + model
   └── No → Any model
```

### P7.5.2 Hyperparameter Tuning

```python
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.ensemble import RandomForestClassifier

# Grid Search (exhaustive)
param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [None, 10, 20, 30],
    'min_samples_split': [2, 5, 10]
}

grid_search = GridSearchCV(
    RandomForestClassifier(random_state=42),
    param_grid,
    cv=5,
    scoring='accuracy',
    n_jobs=-1
)
grid_search.fit(X_train, y_train)
print(f"Best parameters: {grid_search.best_params_}")
print(f"Best CV score: {grid_search.best_score_:.3f}")

# Random Search (faster, good for large spaces)
random_search = RandomizedSearchCV(
    RandomForestClassifier(random_state=42),
    param_grid,
    n_iter=20,
    cv=5,
    scoring='accuracy',
    random_state=42,
    n_jobs=-1
)
random_search.fit(X_train, y_train)
```

### P7.5.3 Cross-Validation

```python
from sklearn.model_selection import cross_val_score, StratifiedKFold

# Standard CV
scores = cross_val_score(model, X, y, cv=5, scoring='accuracy')
print(f"CV Accuracy: {scores.mean():.3f} (+/- {scores.std():.3f})")

# Stratified CV (maintains class distribution)
skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model, X, y, cv=skf, scoring='accuracy')

# Custom CV with evaluation
from sklearn.model_selection import cross_validate
scoring = {'accuracy': 'accuracy', 'f1': 'f1_macro', 'roc_auc': 'roc_auc'}
cv_results = cross_validate(model, X, y, cv=5, scoring=scoring)
```

---

## P7.6 Overfitting and Underfitting

### P7.6.1 Understanding the Trade-off

```
Bias-Variance Trade-off:
    ├── High Bias → Underfitting
    │   └── Model is too simple
    │   └── Poor performance on training AND test
    ├── High Variance → Overfitting
    │   └── Model is too complex
    │   └── Excellent training, poor test
    └── Balanced → Good Generalization
        └── Good performance on both
```

### P7.6.2 Detecting and Preventing

```python
# Learning Curves
from sklearn.model_selection import learning_curve

train_sizes, train_scores, val_scores = learning_curve(
    model, X, y, cv=5, 
    train_sizes=np.linspace(0.1, 1.0, 10),
    scoring='accuracy'
)

# Plot learning curves
plt.plot(train_sizes, train_scores.mean(axis=1), label='Training')
plt.plot(train_sizes, val_scores.mean(axis=1), label='Validation')
plt.xlabel('Training Size')
plt.ylabel('Score')
plt.legend()
plt.show()

# Preventing Overfitting
# 1. More training data
# 2. Regularization (L1, L2)
# 3. Pruning (for trees)
# 4. Early stopping
# 5. Dropout (for neural networks)
# 6. Ensemble methods

# Example: Regularized Regression
from sklearn.linear_model import Ridge, Lasso

# L2 Regularization (Ridge)
ridge = Ridge(alpha=1.0)
ridge.fit(X_train, y_train)

# L1 Regularization (Lasso) - also does feature selection
lasso = Lasso(alpha=1.0)
lasso.fit(X_train, y_train)
```

---

## P7.7 Ensemble Methods

### P7.7.1 Types of Ensembles

```python
# 1. Bagging (Bootstrap Aggregating)
#    - Train models on bootstrapped samples
#    - Average predictions
#    - Example: Random Forest

# 2. Boosting
#    - Train models sequentially
#    - Each model corrects previous errors
#    - Example: AdaBoost, XGBoost

# 3. Stacking
#    - Train multiple models
#    - Meta-model learns from their predictions
#    - Example: StackingClassifier

# 4. Voting
#    - Combine predictions from multiple models
#    - Hard vote (majority) or soft vote (average probabilities)
#    - Example: VotingClassifier
```

### P7.7.2 Implementing Ensembles

```python
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.ensemble import VotingClassifier, StackingClassifier
from sklearn.linear_model import LogisticRegression

# Voting Ensemble
clf1 = LogisticRegression(max_iter=1000)
clf2 = RandomForestClassifier(n_estimators=50)
clf3 = GradientBoostingClassifier(n_estimators=50)

voting_clf = VotingClassifier(
    estimators=[('lr', clf1), ('rf', clf2), ('gb', clf3)],
    voting='soft'  # or 'hard'
)
voting_clf.fit(X_train, y_train)

# Stacking Ensemble
estimators = [
    ('rf', RandomForestClassifier(n_estimators=50)),
    ('gb', GradientBoostingClassifier(n_estimators=50))
]

stacking_clf = StackingClassifier(
    estimators=estimators,
    final_estimator=LogisticRegression()
)
stacking_clf.fit(X_train, y_train)
```

---

## P7.8 Model Interpretability

### P7.8.1 Why Interpretability Matters

1. **Trust:** Users need to trust the model
2. **Debugging:** Find when and why models fail
3. **Compliance:** Regulatory requirements (GDPR, etc.)
4. **Insights:** Learn about the data
5. **Communication:** Explain predictions to stakeholders

### P7.8.2 Interpretability Techniques

```python
# 1. Feature Importance (Tree-based models)
importances = model.feature_importances_
plt.barh(X.columns, importances)
plt.xlabel('Importance')
plt.title('Feature Importance')

# 2. SHAP (SHapley Additive exPlanations)
import shap

# Create explainer
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)

# Summary plot
shap.summary_plot(shap_values, X_test)

# 3. LIME (Local Interpretable Model-agnostic Explanations)
import lime
from lime.lime_tabular import LimeTabularExplainer

explainer = LimeTabularExplainer(
    X_train.values,
    feature_names=X_train.columns,
    class_names=['Not Churn', 'Churn'],
    mode='classification'
)

# Explain a single prediction
i = 0  # First test sample
exp = explainer.explain_instance(
    X_test.values[i],
    model.predict_proba,
    num_features=5
)
exp.show_in_notebook()

# 4. Partial Dependence Plots
from sklearn.inspection import PartialDependenceDisplay

PartialDependenceDisplay.from_estimator(
    model, X_train, ['age', 'order_frequency'],
    feature_names=X_train.columns
)
plt.show()
```

---

## P7.9 Common ML Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| **Data Leakage** | Overestimates performance | Careful train/test split |
| **Imbalanced Data** | Biased model | Use stratified sampling, class weights |
| **Overfitting** | Poor generalization | Regularization, cross-validation |
| **Underfitting** | Poor performance | More complex model, better features |
| **Ignoring Missing Values** | Biased model | Handle missing values properly |
| **Ignoring Outliers** | Skewed results | Detect and handle outliers |
| **No Validation** | Can't assess performance | Use train/validation/test split |
| **Feature Scale Issues** | Incorrect importance | Scale features |

---

## P7.10 Machine Learning in the Series Context

### P7.10.1 What You're Learning (Phase 2 vs Phase 3)

```python
# Phase 2: EDA and Visualization
# - Understand patterns
# - Identify relationships
# - Find segments
# - Form hypotheses

# Phase 3: Feature Engineering & Modeling (Future Series)
# - Transform data into features
# - Build predictive models
# - Deploy models
# - Monitor performance
```

### P7.10.2 Preparing for Modeling

```python
# Things to do in Phase 2:
# 1. Understand data distribution
# 2. Identify relationships
# 3. Find important variables
# 4. Detect data quality issues
# 5. Form modeling hypotheses

# Example: Preparing for customer churn modeling
def prepare_for_modeling(df):
    # 1. Handle missing values
    df = df.dropna(subset=['customer_rating'])
    
    # 2. Create target variable
    df['churn'] = (df['last_purchase'] < '2024-01-01').astype(int)
    
    # 3. Create features
    features = [
        'age',
        'gender',
        'income_bracket',
        'order_frequency',
        'avg_order_value',
        'time_on_site',
        'customer_rating',
        'return_rate'
    ]
    
    # 4. Encode categorical
    df = pd.get_dummies(df, columns=['gender', 'income_bracket'])
    
    # 5. Scale features
    scaler = StandardScaler()
    df[features] = scaler.fit_transform(df[features])
    
    return df, features
```

---

## P7.11 Key Takeaways

1. **ML is about finding patterns in data** - The models learn from examples
2. **Start simple** - Linear models first, then complex
3. **Feature engineering is key** - Better features = better models
4. **Validate rigorously** - Cross-validation, holdout sets
5. **Interpretability matters** - Understand what your model is doing
6. **Watch for pitfalls** - Data leakage, overfitting, imbalance
7. **Domain knowledge matters** - Understand the business problem
8. **It's iterative** - Try, evaluate, improve, repeat

---

## P7.12 Quick Reference: Common ML Operations

```python
# Data Preparation
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Scaling
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X_train)

# Models
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.tree import DecisionTreeClassifier, DecisionTreeRegressor
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.svm import SVC, SVR

# Evaluation
from sklearn.metrics import accuracy_score, precision_score, recall_score
from sklearn.metrics import mean_squared_error, r2_score

# Selection
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.feature_selection import SelectKBest, RFE

# Saving/Loading
import joblib
joblib.dump(model, 'model.pkl')
model = joblib.load('model.pkl')
```

This primer covers the essential machine learning concepts you'll encounter as you prepare for Phase 3. It provides the foundation for understanding how to build predictive models from the customer data you've been exploring throughout this series.
