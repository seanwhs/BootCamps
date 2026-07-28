# Part 1: DVC Setup and Initial Configuration

## The Target: Setting Up DVC with Git

In this first technical part, we'll set up DVC (Data Version Control) and configure our repository for data versioning. By the end, you'll have a DVC-enabled project that can track data files just like Git tracks code.

## The Concept: Why DVC?

Imagine you're building a house. You have a blueprint (your code), but you also need building materials (your data). If you store the materials in the blueprint's repository, it becomes enormous and unwieldy. Instead, you store a manifest that tells you where to get the materials and what version you need.

DVC works exactly like this:
- **Git** handles the blueprint (code, scripts, configurations)
- **DVC** handles the materials (datasets, feature stores, trained models)

DVC creates lightweight text files that point to your actual data files. These text files are stored in Git, while the actual data lives in your local machine or remote storage (S3, GCS, etc.). This means your Git repository stays small and fast, while your data is versioned with the same rigor as your code.

## The Implementation: Step-by-Step Setup

### Step 1: Initialize the Project Structure

Open your terminal and navigate to your project directory:

```bash
# Create the project root if you haven't already
mkdir -p mlops-pipeline-series
cd mlops-pipeline-series

# Create our directory structure
mkdir -p data/{raw,processed,external}
mkdir -p models/{training,inference,registry}
mkdir -p notebooks
mkdir -p src/{data,features,utils}
mkdir -p tests
mkdir -p pipelines

# Initialize Git
git init
```

**Important:** This is a production-grade setup, so we need a proper `.gitignore` file that excludes sensitive and large files:

```bash
# Create a comprehensive .gitignore file
cat > .gitignore << 'EOF'
# Python-specific ignores
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
*.egg-info/
*.egg
dist/
build/

# Virtual environment directories
venv/
.venv/
.env/

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo

# Jupyter notebooks - ignore outputs
.ipynb_checkpoints/
*.ipynb
!notebooks/README.md

# DVC files - ignore actual data, track .dvc files
data/raw/
data/processed/
data/external/
models/registry/
*.dvc.lock  # Lock file can be ignored but we'll track it for reproducibility

# MLflow tracking files
mlruns/
mlflow.db

# Dagster storage
dagster_home/

# Environment variables
.env
.env.local

# OS specific files
.DS_Store
Thumbs.db

# Logs
*.log
logs/
EOF
```

### Step 2: Install Required Packages

Create a comprehensive `requirements.txt` file with specific versions for reproducibility:

```bash
cat > requirements.txt << 'EOF'
# Core data science libraries
numpy==1.24.3
pandas==2.0.3
scikit-learn==1.3.0
scipy==1.10.1

# Machine learning frameworks
torch==2.0.1
tensorflow==2.13.0
xgboost==1.7.6

# Data versioning
dvc==3.15.3
dvc-s3==3.15.3          # For AWS S3 support
dvc-gs==3.15.3          # For Google Cloud Storage support

# Experiment tracking
mlflow==2.4.1

# Pipeline orchestration
dagster==1.5.3
dagster-webserver==1.5.3
dagster-docker==0.21.3

# Database connectors
psycopg2-binary==2.9.7
sqlalchemy==2.0.19

# Data validation
pydantic==2.3.0
great-expectations==0.17.19

# API and web frameworks
fastapi==0.100.0
uvicorn==0.23.2

# Utility libraries
python-dotenv==1.0.0
click==8.1.7
pyyaml==6.0.1
tqdm==4.65.0

# Testing
pytest==7.4.0
pytest-cov==4.1.0
black==23.7.0
flake8==6.1.0
mypy==1.5.1
EOF
```

Create a Python virtual environment and install dependencies:

```bash
# Create virtual environment
python3 -m venv venv

# Activate it (Linux/macOS)
source venv/bin/activate

# Or on Windows:
# venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip

# Install all dependencies
pip install -r requirements.txt
```

### Step 3: Initialize DVC

Now we'll initialize DVC and configure it to work with Git:

```bash
# Initialize DVC in the project root
dvc init

# This creates:
# - .dvc/ directory (DVC's internal storage)
# - .dvcignore (similar to .gitignore but for DVC)
```

### Step 4: Configure DVC

Configure DVC to work with your preferred remote storage. We'll start with local storage and later move to cloud storage:

```bash
# Add a local remote storage (temporary - we'll switch to S3 later)
dvc remote add -d local_storage /tmp/dvc-storage

# This creates a .dvc/config file with:
# ['remote "local_storage"']
# url = /tmp/dvc-storage
```

### Step 5: Create Our First DVC-Tracked File

Let's create a sample dataset to version. In a real project, this would be your actual data:

```bash
# Create a sample CSV file with some data
cat > data/raw/sample_data.csv << 'EOF'
id,timestamp,sensor_1,sensor_2,sensor_3,temperature,pressure,vibration,label
1,2024-01-01 00:00:00,12.5,23.4,45.6,78.2,1.23,0.45,normal
2,2024-01-01 00:01:00,13.2,24.1,46.3,79.1,1.34,0.52,normal
3,2024-01-01 00:02:00,11.8,22.9,44.8,77.5,1.19,0.41,normal
4,2024-01-01 00:03:00,14.1,25.3,47.2,80.4,1.45,0.58,anomaly
5,2024-01-01 00:04:00,12.9,23.8,45.9,78.8,1.28,0.47,normal
6,2024-01-01 00:05:00,13.7,24.6,46.8,79.7,1.39,0.54,normal
7,2024-01-01 00:06:00,11.5,22.4,44.2,76.9,1.15,0.39,normal
8,2024-01-01 00:07:00,15.2,26.1,48.3,81.2,1.52,0.62,anomaly
9,2024-01-01 00:08:00,13.0,23.9,46.1,79.0,1.30,0.48,normal
10,2024-01-01 00:09:00,12.7,23.6,45.7,78.5,1.25,0.44,normal
EOF

# Now track this file with DVC
dvc add data/raw/sample_data.csv

# This creates data/raw/sample_data.csv.dvc - a lightweight metadata file
# The actual CSV is now stored in .dvc/cache/
```

### Step 6: Commit Changes to Git

Now we commit both our code and DVC metadata to Git:

```bash
# Stage all files for commit
git add .gitignore requirements.txt .dvc/ data/raw/sample_data.csv.dvc .dvcignore

# Commit with a meaningful message
git commit -m "Initial project setup with DVC and sample dataset versioned"

# Check the status to see what's tracked
git status
```

### Step 7: Push to Remote Repository (Optional)

If you're using a remote Git repository (GitHub, GitLab, etc.), push your changes:

```bash
# Add your remote repository (replace with your actual URL)
git remote add origin https://github.com/yourusername/mlops-pipeline-series.git

# Push to main branch
git push -u origin main
```

## The Verification: Testing DVC Works

Let's verify that everything is working correctly:

### Verification 1: Check DVC Status

```bash
# This should show that your data is tracked
dvc status

# Expected output:
# Data and pipelines are up to date.
```

### Verification 2: View DVC Tracked Files

```bash
# List all files tracked by DVC
dvc list

# Expected output:
# data/raw/sample_data.csv
```

### Verification 3: Test Data Restoration

DVC should be able to restore your data from cache:

```bash
# First, simulate losing the data file
rm data/raw/sample_data.csv

# Now restore it from DVC
dvc checkout

# Verify the file is back
ls -la data/raw/sample_data.csv

# Expected output: file exists with proper permissions
```

### Verification 4: View Git History

```bash
# See what Git is tracking (should be small)
git log --oneline

# See what files Git is tracking (should NOT include the actual CSV)
git ls-files

# Expected output should NOT include data/raw/sample_data.csv
# But SHOULD include data/raw/sample_data.csv.dvc
```

### Verification 5: Test DVC Remote

```bash
# Push data to remote storage
dvc push

# Expected output:
# 1 file pushed

# Pull data from remote (simulate a fresh clone)
# First, remove local cache
rm -rf .dvc/cache
rm data/raw/sample_data.csv

# Pull from remote
dvc pull

# Verify data is restored
ls -la data/raw/sample_data.csv
```

## What Just Happened?

You've successfully set up DVC and versioned your first dataset! Let's break down what happened:

1. **DVC created a pointer file** (`data/raw/sample_data.csv.dvc`) that contains metadata about your data file - its MD5 hash, size, and other information
2. **Git tracks the pointer file** while DVC handles the actual data
3. **The .dvc/cache/** directory stores the actual data, organized by hash
4. **You can now version, share, and restore your data** just like you do with code

## Common DVC Commands Cheat Sheet

| Command | Purpose |
|---------|---------|
| `dvc add <file>` | Start tracking a data file |
| `dvc status` | Check which files have changed |
| `dvc commit` | Save changes to tracked files |
| `dvc checkout` | Restore data to last committed version |
| `dvc push` | Upload data to remote storage |
| `dvc pull` | Download data from remote storage |
| `dvc list` | Show all tracked files |

## Troubleshooting Common Issues

**Issue:** `dvc add` fails with "Permission denied"
```bash
# Solution: Check file permissions
ls -la data/raw/sample_data.csv
chmod 644 data/raw/sample_data.csv  # Fix permissions
```

**Issue:** DVC cache is taking too much space
```bash
# Solution: Clean old cache entries
dvc gc  # Garbage collect unused cache
```

**Issue:** Remote storage connection fails
```bash
# Solution: Verify remote configuration
dvc remote list
dvc remote default
```

## Next Steps

You now have DVC configured and working! In Part 2, we'll:
- Add multiple datasets and version them
- Create a data processing pipeline with DVC
- Track intermediate artifacts (processed data, feature stores)
- Implement data versioning workflows

---

*End of Part 1: DVC Setup and Initial Configuration*
