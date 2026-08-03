# Primer 2: Setting Up Your Machine Learning Environment

## Complete Guide to Installing and Configuring Your ML Workstation

### The Target

This primer provides a comprehensive guide to setting up a professional machine learning development environment. It covers everything from Python installation to IDE configuration and package management.

### The Concept

Before you can build machine learning models, you need a properly configured workspace. Think of this as setting up your workshop—organizing your tools, ensuring everything works together, and creating a comfortable environment for development.

**Why this matters**: A well-configured environment saves hours of debugging, prevents version conflicts, and makes development more enjoyable. This guide will get you from zero to a working ML environment in under 30 minutes.

### System Requirements

#### Minimum Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | Intel i5 / AMD Ryzen 5 | Intel i7 / AMD Ryzen 7 |
| **RAM** | 8 GB | 16 GB or more |
| **Storage** | 20 GB free | 50 GB+ SSD |
| **OS** | Windows 10 / macOS 10.15 / Ubuntu 20.04 | Latest OS |
| **GPU** | None (CPU only) | NVIDIA GPU with 4GB+ VRAM |

#### Operating System

This guide works for:
- **Windows** (10 or 11)
- **macOS** (10.15 Catalina or newer)
- **Linux** (Ubuntu 20.04+, Debian, or similar)

### Step 1: Install Python

#### Windows

```bash
# Option 1: Download from python.org
# Go to https://www.python.org/downloads/
# Download Python 3.8+
# Check "Add Python to PATH" during installation

# Option 2: Using Chocolatey
choco install python

# Verify installation
python --version
# Should output: Python 3.8.x or higher
```

#### macOS

```bash
# Option 1: Using Homebrew
# Install Homebrew first if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python
brew install python

# Option 2: Download from python.org
# Go to https://www.python.org/downloads/
# Download and install

# Verify installation
python3 --version
```

#### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install Python and pip
sudo apt install python3 python3-pip python3-venv

# Verify installation
python3 --version
pip3 --version
```

### Step 2: Create a Virtual Environment

#### Why Virtual Environments?

Virtual environments isolate your project dependencies. This prevents conflicts between different projects and makes your work reproducible.

```bash
# Create a virtual environment
python -m venv ml_env

# Activate it

# Windows
ml_env\Scripts\activate

# macOS/Linux
source ml_env/bin/activate

# You should see (ml_env) in your terminal prompt

# Deactivate when done
deactivate
```

#### Using Conda (Alternative)

```bash
# Install Miniconda
# Windows: Download from https://docs.conda.io/en/latest/miniconda.html
# macOS/Linux:
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Create environment
conda create -n ml_env python=3.9

# Activate
conda activate ml_env

# Deactivate
conda deactivate
```

### Step 3: Install Essential Packages

#### Core ML Packages

```bash
# First, upgrade pip
pip install --upgrade pip

# Install core packages
pip install numpy==1.24.3 \
            scipy==1.10.1 \
            matplotlib==3.7.1 \
            seaborn==0.12.2 \
            pandas==2.0.3 \
            scikit-learn==1.2.2 \
            jupyter==1.0.0 \
            pytest==7.3.1
```

#### Deep Learning Packages (Optional)

```bash
# PyTorch (CPU version)
pip install torch torchvision torchaudio

# PyTorch (CUDA 11.8)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# TensorFlow
pip install tensorflow

# JAX
pip install jax jaxlib
```

#### Development Tools

```bash
# Code quality
pip install black pylint mypy isort

# Notebook tools
pip install jupyterlab ipywidgets

# Visualization
pip install plotly streamlit

# ML tools
pip install mlflow tensorboard
```

### Step 4: Verify Installation

#### Create a Test Script

Create a file called `test_environment.py`:

```python
"""
Test script to verify ML environment setup.
"""

import sys
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import sklearn


def test_numpy():
    """Test NumPy installation."""
    print(f"NumPy version: {np.__version__}")
    
    # Create arrays
    a = np.array([1, 2, 3, 4, 5])
    b = np.array([5, 4, 3, 2, 1])
    
    # Basic operations
    print(f"a + b = {a + b}")
    print(f"a * b = {a * b}")
    print(f"Dot product: {np.dot(a, b)}")
    
    # Matrix operations
    A = np.random.randn(3, 3)
    B = np.random.randn(3, 3)
    C = A @ B
    print(f"Matrix shape: {C.shape}")
    
    return True


def test_visualization():
    """Test matplotlib and plotting."""
    print(f"Matplotlib version: {plt.matplotlib.__version__}")
    
    # Create simple plot
    x = np.linspace(0, 10, 100)
    y = np.sin(x)
    
    plt.figure(figsize=(8, 4))
    plt.plot(x, y, label='sin(x)')
    plt.xlabel('x')
    plt.ylabel('sin(x)')
    plt.title('Test Plot')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.savefig('test_plot.png')
    print("Plot saved as test_plot.png")
    
    return True


def test_sklearn():
    """Test scikit-learn."""
    print(f"Scikit-learn version: {sklearn.__version__}")
    
    from sklearn.datasets import make_classification
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import train_test_split
    
    # Generate data
    X, y = make_classification(n_samples=100, n_features=2, n_informative=2,
                               n_redundant=0, n_clusters_per_class=1, random_state=42)
    
    # Split and train
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = LogisticRegression()
    model.fit(X_train, y_train)
    
    # Evaluate
    accuracy = model.score(X_test, y_test)
    print(f"Model accuracy: {accuracy:.2f}")
    
    return True


def main():
    """Run all tests."""
    print("=" * 50)
    print("Testing ML Environment")
    print("=" * 50)
    print(f"Python version: {sys.version}")
    print()
    
    tests = [
        ("NumPy", test_numpy),
        ("Visualization", test_visualization),
        ("Scikit-learn", test_sklearn),
    ]
    
    passed = 0
    for name, test_func in tests:
        print(f"\nTesting {name}...")
        try:
            if test_func():
                print(f"✓ {name} passed")
                passed += 1
            else:
                print(f"✗ {name} failed")
        except Exception as e:
            print(f"✗ {name} failed with error: {e}")
    
    print("\n" + "=" * 50)
    print(f"Summary: {passed}/{len(tests)} tests passed")
    print("=" * 50)
    
    return passed == len(tests)


if __name__ == "__main__":
    sys.exit(0 if main() else 1)
```

#### Run the Test

```bash
python test_environment.py
```

Expected output:
```
==================================================
Testing ML Environment
==================================================
Python version: 3.9.16 (main, Jan 11 2023, 09:16:26) 

Testing NumPy...
NumPy version: 1.24.3
a + b = [6 6 6 6 6]
a * b = [5 8 9 8 5]
Dot product: 35
Matrix shape: (3, 3)
✓ NumPy passed

Testing Visualization...
Matplotlib version: 3.7.1
Plot saved as test_plot.png
✓ Visualization passed

Testing Scikit-learn...
Scikit-learn version: 1.2.2
Model accuracy: 0.90
✓ Scikit-learn passed

==================================================
Summary: 3/3 tests passed
==================================================
```

### Step 5: Choose an IDE

#### Recommended IDEs

| IDE | Best For | Free? |
|-----|----------|-------|
| **VS Code** | General ML development | Yes |
| **PyCharm** | Large Python projects | Community Edition free |
| **Jupyter** | Exploration and prototyping | Yes |
| **Spyder** | Scientific computing | Yes |
| **DataSpell** | Data science focused | Paid (trial available) |

#### Setting Up VS Code

```bash
# Install VS Code
# Download from https://code.visualstudio.com/

# Install essential extensions:
# - Python (Microsoft)
# - Jupyter (Microsoft)
# - Python Docstring Generator
# - Live Share
# - GitLens
# - Bracket Pair Colorizer
```

#### VS Code Settings for ML

Create `.vscode/settings.json`:

```json
{
    "python.defaultInterpreterPath": "${workspaceFolder}/ml_env/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.formatting.provider": "black",
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "jupyter.interactiveWindow.textEditor.executeSelection": true
}
```

### Step 6: Install GPU Support (Optional)

#### CUDA Setup (NVIDIA)

```bash
# Check GPU
nvidia-smi
# If this works, you have NVIDIA GPU

# Install CUDA Toolkit
# Visit https://developer.nvidia.com/cuda-downloads

# For Ubuntu 22.04:
sudo apt install nvidia-cuda-toolkit

# Install cuDNN
# Download from https://developer.nvidia.com/cudnn

# Verify CUDA
nvcc --version
```

#### PyTorch with GPU

```bash
# Check CUDA version
nvidia-smi

# Install PyTorch for specific CUDA version
# CUDA 11.8:
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Verify
python -c "import torch; print(torch.cuda.is_available())"
# Should print: True
```

### Step 7: Project Structure

#### Recommended Project Structure

```
project/
├── .gitignore
├── README.md
├── requirements.txt
├── setup.py
├── config/
│   ├── __init__.py
│   └── config.yaml
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── notebooks/
│   ├── 01_exploratory.ipynb
│   └── 02_modeling.ipynb
├── src/
│   ├── __init__.py
│   ├── data/
│   │   ├── __init__.py
│   │   ├── make_dataset.py
│   │   └── preprocessing.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── train_model.py
│   │   └── predict_model.py
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── test_data.py
│   └── test_models.py
└── scripts/
    ├── run_pipeline.py
    └── deploy.py
```

#### Creating the Structure

```bash
# Create directories
mkdir -p project/{data/{raw,processed,external},notebooks,src/{data,models,utils},tests,scripts,config}

# Create __init__.py files
touch project/src/__init__.py
touch project/src/data/__init__.py
touch project/src/models/__init__.py
touch project/src/utils/__init__.py
touch project/tests/__init__.py
touch project/config/__init__.py

# Create base files
touch project/README.md
touch project/requirements.txt
touch project/.gitignore
```

#### Sample `.gitignore`

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv
pip-log.txt
pip-delete-this-directory.txt
.pytest_cache/
.coverage
htmlcov/

# Jupyter
.ipynb_checkpoints/
*.ipynb

# Data
data/raw/
data/processed/
*.csv
*.h5
*.pkl

# Models
models/
*.pth
*.pt
*.h5
*.onnx

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log
```

### Step 8: Configuration Management

#### Using Config Files

Create `config/config.yaml`:

```yaml
# Project configuration

data:
  raw_path: data/raw/
  processed_path: data/processed/
  test_size: 0.2
  random_seed: 42

model:
  type: neural_network
  layer_sizes: [64, 32]
  learning_rate: 0.001
  batch_size: 32
  epochs: 100

logging:
  level: INFO
  file: logs/project.log

training:
  early_stopping: true
  patience: 10
  validation_freq: 5
```

#### Loading Configuration in Python

```python
import yaml
from pathlib import Path

def load_config(config_path="config/config.yaml"):
    """Load configuration from YAML file."""
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    return config

# Usage
config = load_config()
print(f"Data path: {config['data']['raw_path']}")
print(f"Learning rate: {config['model']['learning_rate']}")
```

### Common Issues and Solutions

#### Issue 1: 'python' not found

```
# Windows: Add Python to PATH
# Reinstall Python and check "Add to PATH"

# macOS/Linux: Use python3 instead
python3 --version

# Create alias
alias python=python3
```

#### Issue 2: pip install fails

```bash
# Upgrade pip
python -m pip install --upgrade pip

# Use --user flag
pip install --user package_name

# Use conda instead
conda install package_name
```

#### Issue 3: Virtual environment not activating

```bash
# Windows
ml_env\Scripts\activate.bat
# If error, use:
ml_env\Scripts\Activate.ps1
# Then:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# macOS/Linux
source ml_env/bin/activate
# If permission denied:
chmod +x ml_env/bin/activate
```

### Quick Setup Script

Create `setup.sh`:

```bash
#!/bin/bash

echo "Setting up ML Environment..."

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv ml_env

# Activate
echo "Activating virtual environment..."
source ml_env/bin/activate

# Install requirements
echo "Installing packages..."
pip install --upgrade pip
pip install numpy scipy matplotlib seaborn pandas scikit-learn jupyter pytest

# Create directories
echo "Creating project structure..."
mkdir -p data/raw data/processed notebooks src tests config

# Create initial files
echo "Creating initial files..."
touch README.md requirements.txt .gitignore

echo "Setup complete!"
echo "To activate environment: source ml_env/bin/activate"
```

### Summary Checklist

```
☐ Python installed (3.8+)
☐ Virtual environment created and activated
☐ Core packages installed (NumPy, SciPy, Matplotlib, etc.)
☐ Test script runs successfully
☐ IDE installed and configured
☐ GPU drivers installed (if applicable)
☐ Project structure created
☐ Version control initialized (git init)
☐ README and requirements created
```

---

**[END OF PRIMER 2]**
