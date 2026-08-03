# Primer 5: Jupyter Notebooks for ML Development

## Complete Guide to Interactive ML Development with Jupyter

### The Target

This primer provides a comprehensive guide to Jupyter Notebooks and JupyterLab for machine learning development. It covers everything from basic usage to advanced features and best practices.

### The Concept

Jupyter Notebooks are the Swiss Army knife of data science—they combine code, visualizations, and narrative in a single document. Think of them as your interactive laboratory notebook where you can experiment, document, and share your work.

**Why this matters**: Jupyter Notebooks are the most popular tool for ML development. They enable:
- **Iterative development**: Run code cell by cell
- **Visual exploration**: See plots immediately
- **Documentation**: Explain your work with Markdown
- **Reproducibility**: Share complete notebooks with others

### Getting Started

#### Installing Jupyter

```bash
# Using pip
pip install jupyter jupyterlab ipywidgets

# Using conda
conda install jupyter jupyterlab ipywidgets

# Verify installation
jupyter --version
```

#### Starting Jupyter

```bash
# Start Jupyter Notebook
jupyter notebook

# Start JupyterLab (recommended)
jupyter lab

# Start with specific port
jupyter lab --port=8888

# Start without opening browser
jupyter lab --no-browser

# Start with specific notebook directory
jupyter lab --notebook-dir=/path/to/notebooks
```

### Jupyter Basics

#### Kernel Management

```python
# Check current kernel
import sys
print(sys.executable)  # Python interpreter path
print(sys.version)      # Python version

# Check installed packages
!pip list

# Install packages from notebook
!pip install numpy matplotlib

# Magic commands
%matplotlib inline   # Display plots inline
%load_ext autoreload # Auto-reload modules
%autoreload 2        # Auto-reload all modules
%timeit              # Time execution
%run                 # Run Python file
%who                 # List variables
```

#### Cells and Execution

```python
# Code cells
# Shift+Enter: Run cell and select next
# Ctrl+Enter: Run cell
# Alt+Enter: Run cell and insert below

# Basic operations
import numpy as np
import matplotlib.pyplot as plt

# Multiple lines
def square(x):
    return x ** 2

# Output
print("Hello, Jupyter!")
```

### Markdown in Jupyter

#### Basic Formatting

```markdown
# Heading 1
## Heading 2
### Heading 3
#### Heading 4

**Bold text**
*Italic text*
~~Strikethrough~~

[Link text](https://example.com)

- Bullet list
- Item 2
- Item 3

1. Numbered list
2. Item 2
3. Item 3

`inline code`

```python
# Code block
print("Hello World")
```

| Table | Header |
|-------|--------|
| Cell 1 | Cell 2 |
| Cell 3 | Cell 4 |
```

#### LaTeX Equations

```markdown
Inline equation: $E = mc^2$

Display equation:
$$
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
$$

Matrix:
$$
\begin{bmatrix}
a & b \\
c & d
\end{bmatrix}
$$

Greek letters:
$\alpha, \beta, \gamma, \delta, \epsilon$
```

### Rich Output

#### Images and Plots

```python
# Matplotlib
import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 10, 100)
y = np.sin(x)

plt.figure(figsize=(10, 6))
plt.plot(x, y)
plt.title('Sine Wave')
plt.xlabel('x')
plt.ylabel('sin(x)')
plt.grid(True)
plt.show()

# Display image from file
from IPython.display import Image
Image('image.png')

# Display HTML
from IPython.display import HTML
HTML('<h1>Hello World</h1>')
```

#### Interactive Widgets

```python
import ipywidgets as widgets
from IPython.display import display

# Slider
slider = widgets.IntSlider(value=5, min=0, max=10, step=1, description='Value:')
display(slider)

# Dropdown
dropdown = widgets.Dropdown(options=['Option 1', 'Option 2', 'Option 3'], description='Choose:')
display(dropdown)

# Button with callback
button = widgets.Button(description='Click Me!')
output = widgets.Output()

def on_button_click(b):
    with output:
        print('Button clicked!')

button.on_click(on_button_click)
display(button, output)

# Interactive function
from ipywidgets import interact

@interact(x=(0, 10, 1), y=(0, 10, 1))
def plot_point(x, y):
    plt.figure(figsize=(6, 6))
    plt.scatter([x], [y], s=100, color='red')
    plt.xlim(0, 10)
    plt.ylim(0, 10)
    plt.grid(True)
    plt.show()
```

### Jupyter Best Practices

#### Notebook Structure

```python
# 1. Setup and Imports
"""
# Setup and Dependencies
Import necessary libraries and configure the environment.
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Set random seed for reproducibility
np.random.seed(42)

# 2. Data Loading
"""
# Data Loading
Load the dataset and perform initial inspection.
"""

data = pd.read_csv('data.csv')
print(f"Data shape: {data.shape}")
data.head()

# 3. Data Exploration
"""
# Exploratory Data Analysis
Visualize and understand the data.
"""

# 4. Preprocessing
"""
# Data Preprocessing
Clean and prepare data for modeling.
"""

# 5. Modeling
"""
# Model Building
Train and evaluate machine learning models.
"""

# 6. Evaluation
"""
# Model Evaluation
Assess model performance and interpret results.
"""

# 7. Conclusion
"""
# Summary
Summarize findings and next steps.
"""
```

#### Naming Conventions

```python
# Descriptive variable names
training_data = load_data('train.csv')
test_data = load_data('test.csv')
features = ['age', 'income', 'education']
target = 'salary'

# Clear function names
def preprocess_data(data):
    """Clean and prepare data for modeling."""
    pass

# Use comments sparingly
# Complex operations need comments
# Self-explanatory code doesn't need comments

# Notebook naming
# 01_exploratory_analysis.ipynb
# 02_data_preprocessing.ipynb
# 03_model_training.ipynb
# 04_model_evaluation.ipynb
# 05_deployment.ipynb
```

#### Performance Optimization

```python
# Use vectorized operations
# BAD:
for i in range(len(data)):
    data[i] = data[i] * 2

# GOOD:
data = data * 2

# Profile code
import time

start = time.time()
# Code to profile
elapsed = time.time() - start
print(f"Elapsed: {elapsed:.4f} seconds")

# Use cell magic for timing
%timeit np.sin(np.linspace(0, 10, 1000000))

# Use memory profiler
%load_ext memory_profiler
%memit np.random.randn(1000000)
```

### Advanced Features

#### Magic Commands

```python
# Cell magic (%%)
%%timeit
# Time the whole cell
np.random.randn(1000, 1000).sum()

%%writefile script.py
# Write cell content to file
print("Hello, World!")

%%bash
# Run bash commands
ls -la

%%html
# Display HTML
<h1>Hello World</h1>

%%latex
# Display LaTeX
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
```

#### Custom Extensions

```python
# Install extensions
!pip install jupyter_contrib_nbextensions
!jupyter contrib nbextension install --user

# Enable extensions
!jupyter nbextension enable varInspector/main
!jupyter nbextension enable toc2/main
!jupyter nbextension enable execute_time/ExecuteTime
!jupyter nbextension enable codefolding/main

# Using magic commands
%load_ext autoreload
%autoreload 2

%load_ext watermark
%watermark -p numpy,scipy,matplotlib
```

#### Sharing Notebooks

```python
# Convert to Python script
!jupyter nbconvert --to script notebook.ipynb

# Convert to HTML
!jupyter nbconvert --to html notebook.ipynb

# Convert to PDF
!jupyter nbconvert --to pdf notebook.ipynb

# Convert to slides
!jupyter nbconvert --to slides notebook.ipynb

# Export to GitHub
!jupyter nbconvert --to markdown notebook.ipynb

# Export to ReStructuredText
!jupyter nbconvert --to rst notebook.ipynb
```

### Common Jupyter Workflows

#### Data Exploration Workflow

```python
# 1. Load data
import pandas as pd
df = pd.read_csv('data.csv')

# 2. Quick overview
df.info()
df.describe()
df.head()

# 3. Visualize distributions
import matplotlib.pyplot as plt
plt.figure(figsize=(10, 8))
for i, col in enumerate(df.columns[:4]):
    plt.subplot(2, 2, i+1)
    df[col].hist(bins=30)
    plt.title(col)
plt.tight_layout()
plt.show()

# 4. Check correlations
plt.figure(figsize=(10, 8))
sns.heatmap(df.corr(), annot=True, cmap='coolwarm')
plt.show()

# 5. Preprocess
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
X_scaled = scaler.fit_transform(df.drop('target', axis=1))

# 6. Model
from sklearn.linear_model import LogisticRegression
model = LogisticRegression()
model.fit(X_scaled, df['target'])

# 7. Evaluate
from sklearn.metrics import classification_report
y_pred = model.predict(X_scaled)
print(classification_report(df['target'], y_pred))
```

#### Model Development Workflow

```python
# 1. Setup
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

# 2. Load and preprocess
X, y = load_data()
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# 3. Model definition
class MyModel:
    def __init__(self, learning_rate=0.01):
        self.lr = learning_rate
        self.weights = None
    
    def fit(self, X, y):
        # Training code
        pass
    
    def predict(self, X):
        # Prediction code
        pass

# 4. Train
model = MyModel()
history = model.fit(X_train, y_train)

# 5. Visualize training
plt.figure(figsize=(10, 4))
plt.plot(history['loss'])
plt.title('Training Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.show()

# 6. Evaluate
y_pred = model.predict(X_test)
accuracy = np.mean(y_pred == y_test)
print(f"Test Accuracy: {accuracy:.4f}")

# 7. Iterate
# Modify model, hyperparameters, or data
```

### Troubleshooting

#### Common Issues

```python
# Issue: Kernel dead
# Solution: Restart kernel and re-run cells
# Kernel -> Restart Kernel

# Issue: Import error
# Check if package is installed
!pip list | grep package_name
# Install if missing
!pip install package_name

# Issue: Plot not showing
# Make sure %matplotlib inline is at top
%matplotlib inline

# Issue: Memory error
# Reduce data size, use memory-efficient operations
# Use chunks or generators for large data

# Issue: Long-running cell
# Use interrupt (I) to stop
# Use timeout for certain operations
%%timeout 30
long_running_function()
```

### Jupyter Cheat Sheet

#### Keyboard Shortcuts

```
Command Mode (Esc):
A - Insert cell above
B - Insert cell below
D,D - Delete cell
Z - Undo delete
C - Copy cell
V - Paste cell
Shift+Enter - Run cell
M - Markdown cell
Y - Code cell

Edit Mode (Enter):
Ctrl+Enter - Run cell
Shift+Enter - Run and select next
Ctrl+Z - Undo
Ctrl+S - Save
```

#### Magic Commands

```python
%matplotlib inline    # Inline plots
%load_ext             # Load extension
%run                  # Run Python file
%timeit               # Time code
%prun                 # Profile code
%who                  # List variables
%reset                # Reset namespace
%pdb                  # Debug mode
%cd                   # Change directory
%ls                   # List files
```

#### Best Practices Checklist

```
☐ Use descriptive notebook names
☐ Use Markdown cells for documentation
☐ Keep cells focused on single tasks
☐ Use consistent variable naming
☐ Set random seeds for reproducibility
☐ Use version control for notebooks
☐ Clear output before committing
☐ Use extensions for productivity
☐ Profile performance-critical code
☐ Document dependencies and versions
☐ Use widgets for interactive exploration
☐ Keep notebooks small and modular
```
