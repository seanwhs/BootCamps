# Primer 4: Matplotlib and Visualization for ML

## Complete Guide to Plotting and Visualizing Data for Machine Learning

### The Target

This primer provides a comprehensive guide to Matplotlib and data visualization for machine learning. It covers everything from basic plots to advanced visualization techniques used throughout the series.

### The Concept

Data visualization is how we understand our data, debug our models, and communicate our results. Think of it as your "eyes" into the data—without good visualization, you're working blind.

**Why this matters**: Visualization is essential for every stage of ML:
- **Exploratory Data Analysis**: Understand data distributions and relationships
- **Model Debugging**: See where models fail
- **Results Communication**: Explain findings to stakeholders
- **Model Interpretation**: Visualize feature importance, decision boundaries

### Matplotlib Basics

#### Importing Matplotlib

```python
import matplotlib.pyplot as plt
import numpy as np

# For Jupyter notebooks
%matplotlib inline

# Check version
print(plt.matplotlib.__version__)
```

#### Basic Plotting

```python
# Simple line plot
x = np.linspace(0, 10, 100)
y = np.sin(x)

plt.figure(figsize=(10, 6))
plt.plot(x, y, label='sin(x)', linewidth=2, color='blue')
plt.xlabel('x')
plt.ylabel('sin(x)')
plt.title('Sine Function')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

#### Multiple Plots

```python
# Multiple lines on same plot
x = np.linspace(0, 10, 100)
y1 = np.sin(x)
y2 = np.cos(x)
y3 = np.sin(x) * np.cos(x)

plt.figure(figsize=(10, 6))
plt.plot(x, y1, label='sin(x)', linewidth=2)
plt.plot(x, y2, label='cos(x)', linewidth=2)
plt.plot(x, y3, label='sin(x)*cos(x)', linewidth=2, linestyle='--')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Trigonometric Functions')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

#### Subplots

```python
# Multiple subplots
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

x = np.linspace(0, 10, 100)

# Plot 1: Sine
axes[0, 0].plot(x, np.sin(x))
axes[0, 0].set_title('Sine')
axes[0, 0].grid(True)

# Plot 2: Cosine
axes[0, 1].plot(x, np.cos(x))
axes[0, 1].set_title('Cosine')
axes[0, 1].grid(True)

# Plot 3: Tangent
axes[1, 0].plot(x, np.tan(x))
axes[1, 0].set_title('Tangent')
axes[1, 0].set_ylim(-5, 5)
axes[1, 0].grid(True)

# Plot 4: Exponential
axes[1, 1].plot(x, np.exp(x))
axes[1, 1].set_title('Exponential')
axes[1, 1].grid(True)

plt.tight_layout()
plt.show()
```

### Common Plot Types for ML

#### Scatter Plots

```python
# Scatter plot for data points
np.random.seed(42)
x = np.random.randn(100)
y = 2 * x + 1 + np.random.randn(100) * 0.3

plt.figure(figsize=(8, 6))
plt.scatter(x, y, alpha=0.6, color='blue', s=50)
plt.xlabel('Feature X')
plt.ylabel('Target Y')
plt.title('Scatter Plot: Data Points')
plt.grid(True, alpha=0.3)
plt.show()

# Color-coded scatter plot (classification)
np.random.seed(42)
X1 = np.random.randn(50, 2) + [2, 2]
X2 = np.random.randn(50, 2) + [-2, -2]
X = np.vstack([X1, X2])
y = np.array([0]*50 + [1]*50)

plt.figure(figsize=(8, 6))
plt.scatter(X[y==0, 0], X[y==0, 1], label='Class 0', alpha=0.6, s=50)
plt.scatter(X[y==1, 0], X[y==1, 1], label='Class 1', alpha=0.6, s=50)
plt.xlabel('Feature 1')
plt.ylabel('Feature 2')
plt.title('Scatter Plot: Classification Data')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

#### Histograms

```python
# Histogram for data distribution
np.random.seed(42)
data = np.random.randn(1000)

plt.figure(figsize=(10, 6))
plt.hist(data, bins=30, alpha=0.7, color='blue', edgecolor='black', density=True)
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.title('Histogram: Data Distribution')
plt.grid(True, alpha=0.3)

# Add normal distribution overlay
x = np.linspace(-4, 4, 100)
y = 1/(np.sqrt(2*np.pi)) * np.exp(-x**2/2)
plt.plot(x, y, 'r-', linewidth=2, label='Normal distribution')
plt.legend()
plt.show()

# Multiple histograms
data1 = np.random.randn(1000)
data2 = np.random.randn(1000) + 2

plt.figure(figsize=(10, 6))
plt.hist(data1, bins=30, alpha=0.5, label='Class 0', color='blue', edgecolor='black')
plt.hist(data2, bins=30, alpha=0.5, label='Class 1', color='red', edgecolor='black')
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.title('Histograms: Comparison of Distributions')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

#### Box Plots

```python
# Box plot for distribution summary
np.random.seed(42)
data1 = np.random.randn(100)
data2 = np.random.randn(100) + 2
data3 = np.random.randn(100) - 1

plt.figure(figsize=(10, 6))
plt.boxplot([data1, data2, data3], labels=['Class 0', 'Class 1', 'Class 2'])
plt.ylabel('Value')
plt.title('Box Plot: Distribution Comparison')
plt.grid(True, alpha=0.3)
plt.show()
```

#### Heatmaps

```python
# Heatmap for correlation matrix or confusion matrix
np.random.seed(42)
data = np.random.randn(10, 10)
corr = np.corrcoef(data)

plt.figure(figsize=(8, 6))
im = plt.imshow(corr, cmap='RdBu_r', vmin=-1, vmax=1)
plt.colorbar(im)
plt.title('Correlation Heatmap')
plt.xticks(range(10), [f'F{i}' for i in range(10)])
plt.yticks(range(10), [f'F{i}' for i in range(10)])
plt.show()
```

### Customization and Styling

#### Figure Customization

```python
# Comprehensive customization
x = np.linspace(0, 10, 100)
y = np.sin(x)

fig, ax = plt.subplots(figsize=(10, 6))

# Custom line
ax.plot(x, y, 
        color='blue',          # Line color
        linestyle='-',         # Line style
        linewidth=2,           # Line width
        marker='o',            # Marker style
        markersize=4,          # Marker size
        markerfacecolor='red', # Marker color
        markevery=10,          # Marker frequency
        label='sin(x)')

# Custom axes
ax.set_xlabel('x', fontsize=12, fontweight='bold')
ax.set_ylabel('sin(x)', fontsize=12, fontweight='bold')
ax.set_title('Customized Sine Plot', fontsize=14, fontweight='bold')

# Custom grid
ax.grid(True, linestyle='--', alpha=0.6, color='gray')

# Custom legend
ax.legend(loc='upper right', fontsize=10, framealpha=0.9)

# Custom limits
ax.set_xlim(0, 10)
ax.set_ylim(-1.2, 1.2)

# Custom ticks
ax.set_xticks(np.arange(0, 11, 2))
ax.set_yticks(np.arange(-1, 1.5, 0.5))

plt.tight_layout()
plt.show()
```

#### Color Maps

```python
# Different colormaps
x = np.linspace(0, 10, 100)
y = np.linspace(0, 10, 100)
X, Y = np.meshgrid(x, y)
Z = np.sin(X) * np.cos(Y)

fig, axes = plt.subplots(1, 3, figsize=(15, 4))

# Viridis (recommended for sequential data)
im1 = axes[0].imshow(Z, cmap='viridis', extent=[0, 10, 0, 10])
axes[0].set_title('Viridis')
plt.colorbar(im1, ax=axes[0])

# RdBu (good for diverging data)
im2 = axes[1].imshow(Z, cmap='RdBu_r', extent=[0, 10, 0, 10])
axes[1].set_title('RdBu')
plt.colorbar(im2, ax=axes[1])

# Plasma (good for perceptual uniformity)
im3 = axes[2].imshow(Z, cmap='plasma', extent=[0, 10, 0, 10])
axes[2].set_title('Plasma')
plt.colorbar(im3, ax=axes[2])

plt.tight_layout()
plt.show()
```

### Machine Learning Visualizations

#### Training Curves

```python
# Plot loss and accuracy during training
np.random.seed(42)
epochs = np.arange(1, 51)

# Simulated training curves
train_loss = 1.0 / np.sqrt(epochs) + 0.1 * np.random.randn(50)
val_loss = 1.0 / np.sqrt(epochs) + 0.2 * np.random.randn(50) + 0.1
train_acc = 0.9 - 0.8 / np.sqrt(epochs) + 0.03 * np.random.randn(50)
val_acc = 0.9 - 0.8 / np.sqrt(epochs) + 0.05 * np.random.randn(50) - 0.05

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Loss plot
ax1.plot(epochs, train_loss, label='Train Loss', linewidth=2)
ax1.plot(epochs, val_loss, label='Validation Loss', linewidth=2)
ax1.set_xlabel('Epoch')
ax1.set_ylabel('Loss')
ax1.set_title('Training and Validation Loss')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Accuracy plot
ax2.plot(epochs, train_acc, label='Train Accuracy', linewidth=2)
ax2.plot(epochs, val_acc, label='Validation Accuracy', linewidth=2)
ax2.set_xlabel('Epoch')
ax2.set_ylabel('Accuracy')
ax2.set_title('Training and Validation Accuracy')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1)

plt.tight_layout()
plt.show()
```

#### Confusion Matrix Visualization

```python
# Visualize confusion matrix
def plot_confusion_matrix(cm, classes, title='Confusion Matrix'):
    """Plot confusion matrix."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    im = ax.imshow(cm, interpolation='nearest', cmap='Blues')
    plt.colorbar(im)
    
    # Add values
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, format(cm[i, j], 'd'),
                    ha='center', va='center',
                    color='white' if cm[i, j] > cm.max()/2 else 'black')
    
    ax.set_xticks(np.arange(len(classes)))
    ax.set_yticks(np.arange(len(classes)))
    ax.set_xticklabels(classes)
    ax.set_yticklabels(classes)
    ax.set_xlabel('Predicted Label')
    ax.set_ylabel('True Label')
    ax.set_title(title)
    
    plt.tight_layout()
    return fig, ax

# Example confusion matrix
np.random.seed(42)
cm = np.array([[45, 3, 2],
               [2, 42, 6],
               [1, 5, 44]])
classes = ['Class 0', 'Class 1', 'Class 2']
plot_confusion_matrix(cm, classes)
plt.show()
```

#### Decision Boundary Visualization

```python
# Plot decision boundary for classifiers
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.datasets import make_classification

def plot_decision_boundary(classifier, X, y, title='Decision Boundary'):
    """Plot decision boundary for a classifier."""
    # Train classifier
    classifier.fit(X, y)
    
    # Create mesh grid
    x_min, x_max = X[:, 0].min() - 1, X[:, 0].max() + 1
    y_min, y_max = X[:, 1].min() - 1, X[:, 1].max() + 1
    xx, yy = np.meshgrid(np.arange(x_min, x_max, 0.02),
                         np.arange(y_min, y_max, 0.02))
    
    # Predict on mesh
    Z = classifier.predict(np.c_[xx.ravel(), yy.ravel()])
    Z = Z.reshape(xx.shape)
    
    # Plot
    fig, ax = plt.subplots(figsize=(10, 8))
    
    # Decision boundary
    ax.contourf(xx, yy, Z, alpha=0.4, cmap='RdBu_r')
    
    # Data points
    scatter = ax.scatter(X[:, 0], X[:, 1], c=y, cmap='RdBu_r', 
                        edgecolor='black', s=100, alpha=0.8)
    
    ax.set_xlabel('Feature 1')
    ax.set_ylabel('Feature 2')
    ax.set_title(title)
    ax.set_xlim(x_min, x_max)
    ax.set_ylim(y_min, y_max)
    ax.grid(True, alpha=0.3)
    
    return fig, ax

# Generate data
np.random.seed(42)
X, y = make_classification(n_samples=200, n_features=2, n_informative=2,
                          n_redundant=0, n_clusters_per_class=1, random_state=42)

# Logistic Regression
lr = LogisticRegression()
plot_decision_boundary(lr, X, y, 'Logistic Regression Decision Boundary')
plt.show()

# SVM with RBF kernel
svm = SVC(kernel='rbf')
plot_decision_boundary(svm, X, y, 'SVM Decision Boundary')
plt.show()
```

#### Learning Curve Visualization

```python
# Plot learning curves
from sklearn.model_selection import learning_curve
from sklearn.linear_model import LogisticRegression

def plot_learning_curve(estimator, X, y, cv=5, train_sizes=np.linspace(0.1, 1.0, 10)):
    """Plot learning curves."""
    train_sizes, train_scores, test_scores = learning_curve(
        estimator, X, y, cv=cv, train_sizes=train_sizes, 
        scoring='accuracy', n_jobs=-1
    )
    
    # Calculate mean and std
    train_mean = np.mean(train_scores, axis=1)
    train_std = np.std(train_scores, axis=1)
    test_mean = np.mean(test_scores, axis=1)
    test_std = np.std(test_scores, axis=1)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Plot
    ax.fill_between(train_sizes, train_mean - train_std, train_mean + train_std, 
                    alpha=0.1, color='blue')
    ax.fill_between(train_sizes, test_mean - test_std, test_mean + test_std, 
                    alpha=0.1, color='red')
    
    ax.plot(train_sizes, train_mean, 'o-', color='blue', label='Training Score')
    ax.plot(train_sizes, test_mean, 'o-', color='red', label='Cross-Validation Score')
    
    ax.set_xlabel('Training Set Size')
    ax.set_ylabel('Score')
    ax.set_title('Learning Curves')
    ax.legend(loc='best')
    ax.grid(True, alpha=0.3)
    
    return fig, ax

# Example
X, y = make_classification(n_samples=1000, n_features=20, random_state=42)
lr = LogisticRegression(max_iter=1000)
plot_learning_curve(lr, X, y)
plt.show()
```

### Seaborn Integration

```python
import seaborn as sns

# Set style
sns.set_style('whitegrid')
sns.set_palette('husl')

# Pairplot for multivariate data
np.random.seed(42)
data = np.random.randn(100, 4)
columns = ['Feature A', 'Feature B', 'Feature C', 'Feature D']
df = pd.DataFrame(data, columns=columns)
df['Target'] = (df.sum(axis=1) > 0).astype(int)

sns.pairplot(df, hue='Target', diag_kind='kde')
plt.show()

# Heatmap with seaborn
corr = df.corr()
plt.figure(figsize=(8, 6))
sns.heatmap(corr, annot=True, cmap='RdBu_r', center=0)
plt.title('Correlation Matrix')
plt.show()

# Violin plot
plt.figure(figsize=(10, 6))
sns.violinplot(data=df[['Feature A', 'Feature B', 'Feature C', 'Feature D']])
plt.title('Distribution of Features')
plt.show()

# Joint plot
sns.jointplot(x='Feature A', y='Feature B', data=df, kind='reg')
plt.show()
```

### Plotting for Model Interpretation

```python
# Feature importance visualization
def plot_feature_importance(importance, feature_names, title='Feature Importance'):
    """Plot feature importance."""
    # Sort by importance
    indices = np.argsort(importance)[::-1]
    
    plt.figure(figsize=(10, 6))
    plt.barh(range(len(indices)), importance[indices])
    plt.yticks(range(len(indices)), [feature_names[i] for i in indices])
    plt.xlabel('Importance')
    plt.title(title)
    plt.tight_layout()
    plt.show()

# Example
np.random.seed(42)
feature_names = [f'Feature_{i}' for i in range(10)]
importance = np.random.rand(10)
plot_feature_importance(importance, feature_names)

# Residual plot
def plot_residuals(y_true, y_pred):
    """Plot residuals for regression."""
    residuals = y_true - y_pred
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Residual scatter
    axes[0].scatter(y_pred, residuals, alpha=0.6)
    axes[0].axhline(y=0, color='red', linestyle='--')
    axes[0].set_xlabel('Predicted')
    axes[0].set_ylabel('Residual')
    axes[0].set_title('Residual Plot')
    axes[0].grid(True, alpha=0.3)
    
    # Residual histogram
    axes[1].hist(residuals, bins=30, alpha=0.7, color='blue', edgecolor='black')
    axes[1].set_xlabel('Residual')
    axes[1].set_ylabel('Frequency')
    axes[1].set_title('Residual Distribution')
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.show()

# Example
np.random.seed(42)
y_true = np.random.randn(100)
y_pred = y_true + np.random.randn(100) * 0.5
plot_residuals(y_true, y_pred)
```

### Saving Figures

```python
# Save figure to file
plt.savefig('plot.png', dpi=300, bbox_inches='tight', pad_inches=0.1)

# Supported formats: png, pdf, svg, eps
plt.savefig('plot.pdf')  # Vector format for publications

# High quality
plt.savefig('plot.png', dpi=300, quality=95, optimize=True)

# With transparent background
plt.savefig('plot.png', transparent=True)
```

### Matplotlib Cheat Sheet

#### Basic Plotting
```python
plt.plot(x, y)                    # Line plot
plt.scatter(x, y)                 # Scatter plot
plt.bar(x, y)                     # Bar plot
plt.hist(data)                    # Histogram
plt.boxplot(data)                 # Box plot
plt.imshow(matrix)                # Image/heatmap
plt.contour(X, Y, Z)              # Contour plot
```

#### Figure Setup
```python
plt.figure(figsize=(10, 6))       # Create figure
plt.subplot(2, 2, 1)              # Subplot
plt.subplots(2, 2)                # Multiple subplots
plt.tight_layout()                # Adjust spacing
plt.savefig('plot.png')           # Save figure
```

#### Axes and Labels
```python
plt.xlabel('x label')             # X-axis label
plt.ylabel('y label')             # Y-axis label
plt.title('Title')                # Title
plt.xlim(0, 10)                   # X-axis limits
plt.ylim(0, 10)                   # Y-axis limits
plt.xticks([0, 1, 2])             # X-axis ticks
plt.yticks([0, 1, 2])             # Y-axis ticks
plt.legend()                      # Legend
plt.grid(True)                    # Grid
```

#### Common Customizations
```python
color='blue'                      # Line color
linestyle='--'                    # Line style
linewidth=2                       # Line width
marker='o'                        # Marker style
markersize=5                      # Marker size
alpha=0.5                         # Transparency
label='Data'                      # Legend label
cmap='viridis'                    # Color map
vmin=0, vmax=1                    # Color limits
```

---

**[END OF PRIMER 4]**
