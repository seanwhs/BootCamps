# Appendix I: Environment Setup Guide

## Overview

This guide provides step-by-step instructions for setting up your development environment for the ML Pipeline Project. It covers everything from installing Python to configuring your IDE and verifying your installation.

---

## 1. System Requirements

### Minimum Requirements

| Component | Requirement |
|-----------|-------------|
| Operating System | Windows 10+, macOS 10.15+, or Linux (Ubuntu 18.04+) |
| Python Version | 3.9 or higher |
| RAM | 8GB (16GB recommended) |
| Storage | 20GB free space |
| Processor | Intel Core i5 or equivalent |

### Optional Requirements

| Component | Requirement |
|-----------|-------------|
| GPU | NVIDIA GPU with CUDA support (for deep learning) |
| CUDA Version | 11.7 or higher |
| RAM | 32GB+ (for large datasets) |
| Storage | 50GB+ (for large datasets and models) |

---

## 2. Python Installation

### Windows

1. Download Python from [python.org](https://python.org)
2. Run the installer
3. **IMPORTANT**: Check "Add Python to PATH"
4. Verify installation:
```bash
python --version
# Should output: Python 3.9.x or higher
```

### macOS

**Using Homebrew** (Recommended):
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python
brew install python@3.10

# Verify
python3 --version
```

### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install Python
sudo apt install python3.10 python3.10-dev python3-pip

# Verify
python3 --version
```

---

## 3. Virtual Environment Setup

### Using venv (Built-in)

```bash
# Navigate to project root
cd ml-pipeline-project

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Verify activation
which python  # Should show path to venv/bin/python
```

### Using conda (Alternative)

```bash
# Create conda environment
conda create -n ml-pipeline python=3.10

# Activate conda environment
conda activate ml-pipeline
```

---

## 4. Project Setup

### Clone or Create Project

```bash
# If using existing project
git clone <repository-url>
cd ml-pipeline-project

# Or create new project
mkdir ml-pipeline-project
cd ml-pipeline-project
```

### Install Dependencies

```bash
# Ensure virtual environment is activated
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install requirements
pip install --upgrade pip
pip install -r requirements.txt

# Install in development mode
pip install -e .

# Verify installation
python -c "import numpy, pandas, sklearn; print('All good!')"
```

### Set Up Environment Variables

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your settings (optional)
# Windows:
notepad .env
# macOS/Linux:
nano .env
```

### Create Required Directories

```bash
# Create data directories
mkdir -p data/raw data/processed data/external

# Create model directory
mkdir -p models

# Create log directory
mkdir -p logs

# Create report directory
mkdir -p reports
```

---

## 5. IDE Setup

### VS Code (Recommended)

1. Download VS Code from [code.visualstudio.com](https://code.visualstudio.com)
2. Install Python extension:
   - Open VS Code
   - Click Extensions icon (or Ctrl+Shift+X)
   - Search for "Python"
   - Install the official Microsoft Python extension
3. Install recommended extensions:
   - Pylance
   - Jupyter
   - GitLens
4. Configure settings:
   - Open settings (Ctrl+,)
   - Search for "Python"
   - Set "Python Default Interpreter Path" to `./venv/bin/python` or `./venv/Scripts/python.exe`

### VS Code Settings (Recommended)

```json
{
    "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "python.formatting.provider": "black",
    "python.analysis.typeCheckingMode": "basic",
    "files.autoSave": "onFocusChange",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
```

### PyCharm (Alternative)

1. Download PyCharm from [jetbrains.com/pycharm](https://www.jetbrains.com/pycharm/)
2. Open project
3. Set interpreter:
   - File → Settings → Project → Python Interpreter
   - Click gear icon → Add
   - Select "Existing environment"
   - Browse to `venv/bin/python` or `venv/Scripts/python.exe`
4. Install plugins:
   - Markdown Support
   - Jupyter Notebook Support

---

## 6. GPU Setup (Optional)

### NVIDIA CUDA Setup

1. Check GPU compatibility:
```bash
nvidia-smi
# Should show GPU information
```

2. Install CUDA Toolkit:
   - Download from [developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads)
   - Follow installation instructions for your OS

3. Install cuDNN:
   - Download from [developer.nvidia.com/cudnn](https://developer.nvidia.com/cudnn)
   - Follow installation instructions

4. Verify PyTorch GPU support:
```python
import torch
print(torch.cuda.is_available())  # Should return True
print(torch.cuda.get_device_name(0))  # Should show GPU name
```

### Apple MPS Setup (Mac)

```bash
# PyTorch with MPS support is included in PyTorch 2.0+
python -c "import torch; print(torch.backends.mps.is_available())"
# Should return True for Apple Silicon Macs
```

---

## 7. Git Setup

### Install Git

**Windows**: Download from [git-scm.com](https://git-scm.com)

**macOS**:
```bash
brew install git
```

**Linux**:
```bash
sudo apt install git
```

### Configure Git

```bash
# Set user information
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set line endings
# Windows:
git config --global core.autocrlf true
# macOS/Linux:
git config --global core.autocrlf input

# Set editor
git config --global core.editor "code --wait"  # VS Code
```

### Git Ignore File

```bash
# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
*.so
*.egg
*.egg-info/
dist/
build/

# Virtual environment
venv/
env/
.venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Data
data/raw/*
data/processed/*
!data/raw/.gitkeep
!data/processed/.gitkeep

# Models
*.joblib
*.pkl
*.pt
*.pth

# Logs
logs/*.log
logs/*.jsonl

# Reports
reports/*.html
reports/*.json

# Environment
.env
.env.local

# Jupyter
.ipynb_checkpoints/
*.ipynb

# System
.DS_Store
Thumbs.db

# Tests
.pytest_cache/
.coverage
htmlcov/
EOF
```

---

## 8. Docker Setup

### Install Docker

**Windows/macOS**: Download Docker Desktop from [docker.com](https://docker.com)

**Linux**:
```bash
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Logout and login again for group changes to take effect
```

### Verify Docker Installation

```bash
docker --version
docker-compose --version
```

### Build Docker Image

```bash
docker build -t ml-pipeline:latest .
```

### Run with Docker Compose

```bash
docker-compose up -d
```

---

## 9. Verification Script

Create and run this script to verify your environment:

```python
# verify_setup.py
import sys
import importlib

def check_package(name, min_version=None):
    try:
        module = importlib.import_module(name)
        version = getattr(module, '__version__', 'unknown')
        print(f"✅ {name}: {version}")
        return True
    except ImportError:
        print(f"❌ {name}: Not installed")
        return False

def main():
    print("=" * 60)
    print("Environment Verification")
    print("=" * 60)
    
    # Python version
    print(f"\nPython Version: {sys.version}")
    
    # Critical packages
    print("\nCore Packages:")
    packages = [
        'numpy',
        'pandas',
        'sklearn',
        'xgboost',
        'lightgbm',
        'catboost',
        'torch',
        'optuna',
        'fastapi',
        'uvicorn',
        'pydantic',
        'loguru'
    ]
    
    for pkg in packages:
        check_package(pkg)
    
    # GPU check
    print("\nGPU Status:")
    try:
        import torch
        if torch.cuda.is_available():
            print(f"✅ CUDA: {torch.cuda.get_device_name(0)}")
        elif torch.backends.mps.is_available():
            print("✅ MPS: Available")
        else:
            print("⚠️ GPU: Not available (CPU only)")
    except:
        print("⚠️ GPU: Could not check")
    
    print("\n" + "=" * 60)
    print("Verification complete!")

if __name__ == "__main__":
    main()
```

Run the verification script:
```bash
python verify_setup.py
```

---

## 10. Common Issues and Solutions

### Issue: `pip install` fails with SSL certificate error

**Solution**: Upgrade pip or use trusted host
```bash
pip install --upgrade pip
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt
```

### Issue: `ModuleNotFoundError: No module named 'src'`

**Solution**: Install project in development mode
```bash
pip install -e .
```

### Issue: `Permission denied` when creating directories

**Solution**: Use sudo or check permissions
```bash
# Check permissions
ls -la

# Fix permissions (Linux/macOS)
chmod 755 .
```

### Issue: Virtual environment activation fails on Windows

**Solution**:
```bash
# If execution policy is restricted
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: GPU not detected by PyTorch

**Solution**:
1. Check CUDA installation: `nvidia-smi`
2. Check PyTorch CUDA version: `python -c "import torch; print(torch.version.cuda)"`
3. Install PyTorch with correct CUDA version

---

## 11. Quick Start Summary

```bash
# 1. Clone project
git clone <repository-url>
cd ml-pipeline-project

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows

# 3. Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# 4. Setup environment
cp .env.example .env
mkdir -p data/raw data/processed data/external models logs reports

# 5. Verify setup
python verify_setup.py

# 6. Run tests
pytest tests/

# 7. Start development
python src/pipeline/trainer.py --config configs/base.yaml --data data/raw/data.csv --target target
```

---

This environment setup guide ensures you have everything needed to follow along with the series. Use the verification script to confirm your setup is correct before proceeding with development.
