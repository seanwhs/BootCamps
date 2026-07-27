# APPENDIX C: Environment Setup & Troubleshooting Guide

This appendix provides comprehensive instructions for setting up your development environment, along with solutions to the most common technical issues you might encounter throughout the series.

---

## C.1 System Requirements

### Minimum Hardware Specifications

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 4 cores | 8+ cores |
| **RAM** | 8 GB | 16+ GB |
| **Storage** | 20 GB free | 50+ GB free (SSD) |
| **Python** | 3.9+ | 3.11+ |

### Operating System Support

| OS | Version | Notes |
|----|---------|-------|
| **Linux** | Ubuntu 20.04+ | Best performance, native package management |
| **macOS** | 12.0+ (Monterey) | Works well, some package differences |
| **Windows** | 10/11 | Works with WSL2 or native |

---

## C.2 Complete Installation Guide

### Option 1: Local Installation (Recommended)

#### Step 1: Install Python

**Linux/macOS:**
```bash
# Check if Python is installed
python3 --version

# Install Python (Ubuntu/Debian)
sudo apt update
sudo apt install python3 python3-pip python3-venv

# Install Python (macOS with Homebrew)
brew install python@3.11
```

**Windows:**
1. Download Python from [python.org](https://www.python.org/downloads/)
2. Run installer
3. ✅ **CRITICAL:** Check "Add Python to PATH"
4. Click "Install Now"

#### Step 2: Create a Virtual Environment

```bash
# Create project directory
mkdir data-engineering-series
cd data-engineering-series

# Create virtual environment
python3 -m venv venv

# Activate it
# Linux/macOS:
source venv/bin/activate

# Windows:
venv\Scripts\activate
```

#### Step 3: Install Dependencies

Create `requirements.txt`:

```txt
# Core data processing
numpy==1.24.3
pandas==2.0.3
polars==0.18.15

# SQL and databases
duckdb==0.8.1
psycopg2-binary==2.9.6
sqlalchemy==2.0.19

# Data validation
pandera==0.16.1
pydantic==2.0.3

# Visualization
matplotlib==3.7.2
seaborn==0.12.2
plotly==5.15.0
altair==5.0.1

# Statistics
scipy==1.11.1
statsmodels==0.14.0
scikit-learn==1.3.0

# Utilities
python-dotenv==1.0.0
jupyter==1.0.0
pytest==7.4.0
black==23.7.0
missingno==0.5.2
```

Then install:

```bash
pip install -r requirements.txt
```

---

### Option 2: Docker Installation (Alternative)

If you prefer containerization or want to avoid dependency conflicts:

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

CMD ["python"]
```

Build and run:

```bash
docker build -t data-engineering .
docker run -it -v $(pwd):/app data-engineering python src/phase1/capstone_etl_pipeline.py
```

---

### Option 3: Conda Installation (Alternative)

For users who prefer Anaconda:

```bash
# Create environment
conda create -n data-engineering python=3.11

# Activate
conda activate data-engineering

# Install packages
conda install numpy pandas matplotlib seaborn scipy scikit-learn
pip install polars duckdb pandera pydantic plotly altair statsmodels
```

---

## C.3 PostgreSQL Setup

### Option 1: Local PostgreSQL

**Linux (Ubuntu/Debian):**
```bash
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo -u postgres psql -c "CREATE DATABASE data_engineering;"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```

**macOS (Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
createdb data_engineering
psql -c "ALTER USER $(whoami) WITH PASSWORD 'postgres';"
```

**Windows:**
1. Download from [postgresql.org](https://www.postgresql.org/download/windows/)
2. Run installer
3. Set password to `postgres` (or remember what you set)
4. Default port: 5432

### Option 2: PostgreSQL with Docker (Easiest)

```bash
# Pull and run PostgreSQL
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=data_engineering \
  -p 5432:5432 \
  postgres:15

# Wait for it to start
sleep 5

# Connect to verify
docker exec -it postgres psql -U postgres -d data_engineering
```

### PostgreSQL Connection Test

Create `.env` file:

```env
PG_HOST=localhost
PG_PORT=5432
PG_DATABASE=data_engineering
PG_USER=postgres
PG_PASSWORD=postgres
```

Test connection:

```python
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

try:
    conn = psycopg2.connect(
        host=os.getenv('PG_HOST'),
        port=os.getenv('PG_PORT'),
        database=os.getenv('PG_DATABASE'),
        user=os.getenv('PG_USER'),
        password=os.getenv('PG_PASSWORD')
    )
    print("✅ PostgreSQL connection successful!")
    conn.close()
except Exception as e:
    print(f"❌ Connection failed: {e}")
```

---

## C.4 Jupyter Setup

### Install Jupyter

```bash
pip install jupyter
```

### Launch Jupyter

```bash
# From project root
jupyter notebook

# Or with lab
jupyter lab
```

### Configure Jupyter to Use Your Virtual Environment

```bash
# Install ipykernel
pip install ipykernel

# Register the kernel
python -m ipykernel install --user --name=data-engineering
```

### Useful Jupyter Extensions

```bash
# Install extensions
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user

# Enable extensions
jupyter nbextension enable codefolding/main
jupyter nbextension enable toc2/main
jupyter nbextension enable collapsible_headings/main
```

---

## C.5 Troubleshooting Common Issues

### Issue 1: ModuleNotFoundError

**Problem:**
```python
ModuleNotFoundError: No module named 'polars'
```

**Solutions:**
```bash
# 1. Check if package is installed
pip list | grep polars

# 2. Install missing package
pip install polars

# 3. Check virtual environment is activated
which python  # Should point to venv/bin/python

# 4. Reinstall if corrupted
pip uninstall polars
pip install polars
```

---

### Issue 2: Memory Error (Out of Memory)

**Problem:**
```python
MemoryError: Unable to allocate 10.0 GiB for an array...
```

**Solutions:**
```python
# 1. Use chunking for large files
import pandas as pd

chunks = []
for chunk in pd.read_csv('large_file.csv', chunksize=100000):
    # Process chunk
    processed = process_chunk(chunk)
    chunks.append(processed)
    
df = pd.concat(chunks, ignore_index=True)

# 2. Use Polars lazy evaluation
import polars as pl

df = pl.scan_csv('large_file.csv')
filtered = df.filter(pl.col('value') > 0).collect()

# 3. Use DuckDB for SQL operations
import duckdb

conn = duckdb.connect(':memory:')
result = conn.execute("""
    SELECT * FROM 'large_file.csv' 
    WHERE value > 0
""").fetchdf()

# 4. Optimize data types
df = pd.read_csv('large_file.csv',
                 usecols=['id', 'value'],  # Only needed columns
                 dtype={'id': 'int32', 'value': 'float32'})
```

---

### Issue 3: PostgreSQL Connection Refused

**Problem:**
```
psycopg2.OperationalError: could not connect to server: Connection refused
```

**Solutions:**

**If using Docker:**
```bash
# Check if container is running
docker ps | grep postgres

# Start container if stopped
docker start postgres

# Check logs
docker logs postgres
```

**If using local PostgreSQL:**
```bash
# Linux
sudo systemctl status postgresql
sudo systemctl start postgresql

# macOS
brew services list | grep postgresql
brew services start postgresql

# Windows
# Check Services (Win+R → services.msc)
# Find PostgreSQL service and start it
```

**Check connection parameters:**
```python
# Verify your .env file has correct values
PG_HOST=localhost  # or 127.0.0.1
PG_PORT=5432       # Default PostgreSQL port
PG_USER=postgres
PG_PASSWORD=postgres
```

---

### Issue 4: Jupyter Kernel Dies

**Problem:**
```
The kernel appears to have died. It will restart automatically.
```

**Solutions:**

**1. Increase Jupyter memory limit:**
```bash
jupyter notebook --NotebookApp.iopub_data_rate_limit=10000000
```

**2. Use environment variable:**
```bash
export JUPYTER_ALLOW_INSECURE=1
```

**3. Reduce data size in notebook:**
```python
# Sample data for exploration
df_sample = df.sample(10000)

# Clear memory
import gc
gc.collect()

# Delete large variables
del large_var
```

**4. Use memory profiling:**
```python
%load_ext memory_profiler
%memit df = pd.read_csv('large_file.csv')
```

---

### Issue 5: Plotly Charts Not Displaying in Jupyter

**Problem:**
```
Plotly charts show blank or don't render
```

**Solutions:**

```bash
# 1. Install plotly extensions
pip install ipywidgets
jupyter nbextension enable --py widgetsnbextension

# 2. Enable plotly offline mode
import plotly.io as pio
pio.renderers.default = 'notebook'

# 3. For Jupyter Lab
pip install jupyterlab
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install plotlywidget
```

**Alternative: Render as HTML**
```python
fig.write_html('plot.html')
# Open in browser
import webbrowser
webbrowser.open('plot.html')
```

---

### Issue 6: Polars vs Pandas Conflicts

**Problem:**
```
TypeError: cannot convert Polars DataFrame to Pandas...
```

**Solutions:**

```python
# 1. Explicit conversion
df_pandas = df_polars.to_pandas()
df_polars = pl.from_pandas(df_pandas)

# 2. Use DuckDB for interoperability
import duckdb

conn = duckdb.connect(':memory:')
conn.register('pandas_df', df_pandas)
conn.register('polars_df', df_polars)

# Query both together
result = conn.execute("""
    SELECT * FROM pandas_df
    UNION ALL
    SELECT * FROM polars_df
""").fetchdf()
```

---

### Issue 7: Virtual Environment Not Activating

**Linux/macOS:**
```bash
# If permission denied
chmod +x venv/bin/activate
source venv/bin/activate

# If using fish shell
source venv/bin/activate.fish

# If using zsh
source venv/bin/activate
```

**Windows:**
```powershell
# Command Prompt
venv\Scripts\activate.bat

# PowerShell
venv\Scripts\Activate.ps1

# If execution policy blocks it
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
venv\Scripts\Activate.ps1
```

---

## C.6 Performance Optimization

### System-Level Optimizations

```bash
# 1. Increase swap space (Linux)
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 2. Set environment variables for performance
export OMP_NUM_THREADS=8
export MKL_NUM_THREADS=8
export NUMEXPR_NUM_THREADS=8

# 3. For Pandas
import pandas as pd
pd.set_option('display.max_rows', 100)
pd.set_option('display.max_columns', 50)
```

### Python-Level Optimizations

```python
# 1. Use appropriate libraries
# Polars > Pandas for large datasets
# DuckDB > Pandas for SQL operations

# 2. Use .eval() for complex Pandas expressions
df['result'] = df.eval('(a + b) / (c - d)')

# 3. Use .query() for filtering
df_filtered = df.query('age > 30 and income > 50000')

# 4. Use chunking
def process_large_csv(filename):
    chunks = []
    for chunk in pd.read_csv(filename, chunksize=100000):
        chunks.append(process_chunk(chunk))
    return pd.concat(chunks, ignore_index=True)

# 5. Use .transform() instead of .apply()
# Slow: df.groupby('cat')['value'].apply(lambda x: x - x.mean())
# Fast: df.groupby('cat')['value'].transform(lambda x: x - x.mean())
```

---

## C.7 IDE Setup Recommendations

### VS Code Extensions

```bash
# Install extensions
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension ms-python.vscode-pylance
code --install-extension eamodio.gitlens
code --install-extension ms-python.black-formatter

# Settings.json for Python
{
    "python.defaultInterpreterPath": "./venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "black",
    "editor.formatOnSave": true
}
```

### PyCharm Setup

1. **Set Interpreter:**
   - Preferences → Project → Python Interpreter
   - Add → Existing environment → Select `venv/bin/python`

2. **Enable Scientific Mode:**
   - View → Scientific Mode

3. **Configure Jupyter Integration:**
   - Tools → Python Scientific → Show plots in tool window

---

## C.8 Quick Diagnostic Commands

### Environment Info

```python
# Run this to diagnose your environment
import sys
import platform

print(f"Python version: {sys.version}")
print(f"Platform: {platform.platform()}")
print(f"Architecture: {platform.architecture()}")

# Package versions
import numpy
import pandas
import polars
import duckdb
import matplotlib
import seaborn
import scipy
import statsmodels

print(f"NumPy: {numpy.__version__}")
print(f"Pandas: {pandas.__version__}")
print(f"Polars: {polars.__version__}")
print(f"DuckDB: {duckdb.__version__}")
print(f"Matplotlib: {matplotlib.__version__}")
print(f"Seaborn: {seaborn.__version__}")
print(f"SciPy: {scipy.__version__}")
print(f"Statsmodels: {statsmodels.__version__}")
```

### Memory Check

```python
import psutil
import os

# System memory
mem = psutil.virtual_memory()
print(f"Total Memory: {mem.total / (1024**3):.2f} GB")
print(f"Available Memory: {mem.available / (1024**3):.2f} GB")
print(f"Used Memory: {mem.used / (1024**3):.2f} GB")

# Process memory
process = psutil.Process(os.getpid())
print(f"Process Memory: {process.memory_info().rss / (1024**2):.2f} MB")
```

---

## C.9 Quick Reference: Installation Commands

### Common Install Commands

```bash
# Core packages
pip install numpy pandas polars
pip install duckdb psycopg2-binary sqlalchemy
pip install pandera pydantic
pip install matplotlib seaborn plotly altair
pip install scipy statsmodels scikit-learn
pip install jupyter python-dotenv pytest black missingno

# All at once
pip install -r requirements.txt

# Upgrade packages
pip install --upgrade pandas

# Check installed packages
pip list
pip show pandas
```

### Clean Installation (Fresh Start)

```bash
# Remove old virtual environment
rm -rf venv

# Create fresh
python3 -m venv venv
source venv/bin/activate

# Install with --no-cache to avoid issues
pip install --no-cache-dir -r requirements.txt
```

---

**[APPENDIX C COMPLETE]**  
