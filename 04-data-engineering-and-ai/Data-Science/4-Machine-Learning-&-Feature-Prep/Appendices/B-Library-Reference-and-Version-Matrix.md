# Appendix B: Library Reference and Version Matrix

## Core Dependencies

| Library | Minimum Version | Recommended Version | Purpose | Installation |
|---------|----------------|-------------------|---------|--------------|
| Python | 3.9 | 3.10+ | Programming language | [python.org](https://python.org) |
| numpy | 1.21.0 | 1.24.0+ | Numerical computing | `pip install numpy` |
| pandas | 1.4.0 | 2.0.0+ | Data manipulation | `pip install pandas` |
| scikit-learn | 1.1.0 | 1.3.0+ | ML algorithms | `pip install scikit-learn` |
| matplotlib | 3.5.0 | 3.7.0+ | Visualization | `pip install matplotlib` |
| seaborn | 0.11.0 | 0.12.0+ | Statistical visualization | `pip install seaborn` |

## Machine Learning Libraries

| Library | Minimum Version | Recommended Version | Purpose | Installation |
|---------|----------------|-------------------|---------|--------------|
| xgboost | 1.6.0 | 1.7.0+ | Gradient boosting | `pip install xgboost` |
| lightgbm | 3.3.0 | 4.0.0+ | Fast gradient boosting | `pip install lightgbm` |
| catboost | 1.0.0 | 1.2.0+ | Boosting with categoricals | `pip install catboost` |
| torch | 1.12.0 | 2.0.0+ | Deep learning | `pip install torch torchvision` |
| optuna | 3.0.0 | 3.3.0+ | Hyperparameter optimization | `pip install optuna` |
| imbalanced-learn | 0.9.0 | 0.11.0+ | Imbalance handling | `pip install imbalanced-learn` |

## Web/API Libraries

| Library | Minimum Version | Recommended Version | Purpose | Installation |
|---------|----------------|-------------------|---------|--------------|
| fastapi | 0.85.0 | 0.100.0+ | Web API framework | `pip install fastapi` |
| uvicorn | 0.18.0 | 0.23.0+ | ASGI server | `pip install uvicorn` |
| pydantic | 1.10.0 | 2.0.0+ | Data validation | `pip install pydantic` |
| python-multipart | 0.0.6 | 0.0.6+ | Form data parsing | `pip install python-multipart` |

## Utilities

| Library | Minimum Version | Recommended Version | Purpose | Installation |
|---------|----------------|-------------------|---------|--------------|
| loguru | 0.6.0 | 0.7.0+ | Logging | `pip install loguru` |
| python-dotenv | 0.20.0 | 1.0.0+ | Environment variables | `pip install python-dotenv` |
| joblib | 1.1.0 | 1.3.0+ | Model serialization | `pip install joblib` |
| pyyaml | 6.0.0 | 6.0.0+ | YAML configuration | `pip install pyyaml` |
| tqdm | 4.65.0 | 4.65.0+ | Progress bars | `pip install tqdm` |

## Testing and Development

| Library | Minimum Version | Recommended Version | Purpose | Installation |
|---------|----------------|-------------------|---------|--------------|
| pytest | 7.0.0 | 7.4.0+ | Testing framework | `pip install pytest` |
| pytest-cov | 4.0.0 | 4.1.0+ | Coverage reporting | `pip install pytest-cov` |
| black | 22.0.0 | 23.0.0+ | Code formatting | `pip install black` |
| flake8 | 5.0.0 | 6.0.0+ | Code linting | `pip install flake8` |
| mypy | 0.980 | 1.4.0+ | Type checking | `pip install mypy` |
| isort | 5.10.0 | 5.12.0+ | Import sorting | `pip install isort` |

## Optional Libraries

| Library | Purpose | When to Use | Installation |
|---------|---------|-------------|--------------|
| umap-learn | Dimensionality reduction | Large datasets, visualization | `pip install umap-learn` |
| mlflow | Experiment tracking | Managing experiments | `pip install mlflow` |
| plotly | Interactive visualizations | Dashboarding, web apps | `pip install plotly` |
| shap | Model interpretation | Explaining predictions | `pip install shap` |
| eli5 | Model debugging | Understanding predictions | `pip install eli5` |

---

## Version Compatibility Matrix

### Scikit-learn Compatibility

| Package | sklearn 1.1 | sklearn 1.2 | sklearn 1.3 |
|---------|-------------|-------------|-------------|
| XGBoost 1.6+ | ✅ | ✅ | ✅ |
| XGBoost 1.7+ | ✅ | ✅ | ✅ |
| LightGBM 3.3+ | ✅ | ✅ | ✅ |
| LightGBM 4.0+ | ✅ | ✅ | ✅ |
| CatBoost 1.0+ | ✅ | ✅ | ✅ |
| Optuna 3.0+ | ✅ | ✅ | ✅ |
| imbalanced-learn 0.9+ | ✅ | ✅ | ✅ |
| imbalanced-learn 0.11+ | ✅ | ✅ | ✅ |

### PyTorch Compatibility

| Package | PyTorch 1.12 | PyTorch 1.13 | PyTorch 2.0 |
|---------|--------------|--------------|-------------|
| torchvision 0.13+ | ✅ | ✅ | ✅ |
| torchvision 0.15+ | ✅ | ✅ | ✅ |
| XGBoost 1.6+ | ✅ | ✅ | ✅ |
| Optuna 3.0+ | ✅ | ✅ | ✅ |

### GPU Support

| Framework | CUDA 11.7 | CUDA 11.8 | CUDA 12.0 | Apple MPS |
|-----------|-----------|-----------|-----------|-----------|
| PyTorch 1.12 | ✅ | ✅ | ❌ | ❌ |
| PyTorch 1.13 | ✅ | ✅ | ❌ | ❌ |
| PyTorch 2.0 | ✅ | ✅ | ✅ | ✅ |
| XGBoost 1.6+ | ✅ | ✅ | ✅ | ❌ |
| LightGBM 4.0+ | ✅ | ✅ | ✅ | ❌ |
| CatBoost 1.2+ | ✅ | ✅ | ✅ | ❌ |

---

## Python Version Support

| Python Version | Support Status | Notes |
|----------------|----------------|-------|
| Python 3.7 | ⚠️ Deprecated | End of life June 2023 |
| Python 3.8 | ✅ Supported | End of life October 2024 |
| Python 3.9 | ✅ Recommended | End of life October 2025 |
| Python 3.10 | ✅ Recommended | End of life October 2026 |
| Python 3.11 | ✅ Recommended | End of life October 2027 |
| Python 3.12 | ✅ Experimental | May have compatibility issues |

---

## Complete Requirements.txt

```txt
# Core scientific computing
numpy==1.24.3
pandas==2.0.3
scipy==1.10.1

# Machine Learning
scikit-learn==1.3.0
xgboost==1.7.6
lightgbm==4.0.0
catboost==1.2.0

# Deep Learning
torch==2.0.1
torchvision==0.15.2

# Optimization
optuna==3.3.0

# API and Web
fastapi==0.100.0
uvicorn==0.23.1
python-multipart==0.0.6

# Data Validation
pydantic==2.1.0
pydantic-settings==2.0.2

# Utilities
python-dotenv==1.0.0
joblib==1.3.1
loguru==0.7.2
pyyaml==6.0.1
tqdm==4.65.0

# Testing
pytest==7.4.0
pytest-cov==4.1.0

# Visualization
matplotlib==3.7.2
seaborn==0.12.2
plotly==5.15.0

# Code Quality (dev only)
black==23.7.0
flake8==6.0.0
mypy==1.4.0
isort==5.12.0

# Experiment Tracking
mlflow==2.5.0

# Feature Engineering
feature-engine==1.6.0

# Imbalanced Learning
imbalanced-learn==0.11.0

# Model Interpretation (optional)
shap==0.41.0
eli5==0.13.0

# Dimensionality Reduction (optional)
umap-learn==0.5.3

# Additional Utilities
requests==2.31.0
docker==6.1.3
```

---

## Installation Commands by Use Case

### Minimal Installation (Core Only)
```bash
pip install numpy pandas scikit-learn
```

### Full Machine Learning Installation
```bash
pip install numpy pandas scikit-learn xgboost lightgbm catboost optuna imbalanced-learn
```

### Deep Learning Installation
```bash
# CPU only
pip install torch torchvision

# CUDA 11.7
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu117

# CUDA 11.8
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.0
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu120

# Apple MPS (Mac)
pip install torch torchvision
```

### API and Deployment Installation
```bash
pip install fastapi uvicorn python-multipart pydantic docker
```

### Development Installation
```bash
pip install pytest pytest-cov black flake8 mypy isort
```

### Complete Installation
```bash
pip install -r requirements.txt
```

---

## Environment Setup

### Virtual Environment
```bash
# Create
python -m venv venv

# Activate (Linux/Mac)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Deactivate
deactivate
```

### Conda Environment
```bash
# Create
conda create -n ml-pipeline python=3.10

# Activate
conda activate ml-pipeline

# Install packages
conda install numpy pandas scikit-learn matplotlib seaborn
pip install xgboost lightgbm catboost optuna
```

### Environment Variables (.env)
```bash
# Environment
ENVIRONMENT=development

# Data paths
DATA_RAW_PATH=./data/raw
DATA_PROCESSED_PATH=./data/processed

# Logging
LOG_LEVEL=INFO
LOG_PATH=./logs

# Model
MODEL_PATH=./models
MODEL_VERSION=1.0.0

# API
API_HOST=0.0.0.0
API_PORT=8000
```

---

## Troubleshooting Installation Issues

### Issue: `pip install` fails with "Could not find a version that satisfies the requirement"
**Solution**: Upgrade pip and try again
```bash
pip install --upgrade pip
```

### Issue: `ImportError: libcudart.so.x.x: cannot open shared object file`
**Solution**: Install CUDA toolkit or use CPU version
```bash
# For PyTorch CPU
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
```

### Issue: MemoryError during installation
**Solution**: Use `--no-cache-dir` flag
```bash
pip install --no-cache-dir -r requirements.txt
```

### Issue: Version conflicts between packages
**Solution**: Use `pip-tools` for dependency resolution
```bash
pip install pip-tools
pip-compile requirements.in
pip-sync
```

---

This appendix serves as your comprehensive reference for all library dependencies, version requirements, and compatibility information needed throughout the series.
