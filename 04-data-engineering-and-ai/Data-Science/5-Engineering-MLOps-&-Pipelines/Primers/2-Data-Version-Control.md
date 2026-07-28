# Primer 2: Data Version Control (DVC) Deep Dive

## The Target: Comprehensive Understanding of DVC Architecture and Internals

This primer provides an in-depth exploration of DVC's architecture, internals, and advanced usage patterns. Understanding these concepts will help you debug issues, design efficient pipelines, and leverage DVC's full capabilities.

## The Concept: How DVC Actually Works

Think of DVC like a library catalog system:
- **Git** = The catalog index (lightweight, text-based)
- **DVC Cache** = The actual books (stored in the warehouse)
- **DVC Remote** = Another library branch (shared across locations)
- **DVC Files** = Catalog cards (pointers to the books)

When you version a file with DVC, you're not storing the file in Git. Instead, you're storing a pointer file that tells DVC where to find the actual data.

---

## 1. DVC Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                      DVC Architecture                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Git Repository                        │  │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────────┐  │  │
│  │  │  .dvc/     │  │  *.dvc     │  │  dvc.yaml       │  │  │
│  │  │  Config    │  │  Files     │  │  Pipeline Def   │  │  │
│  │  └────────────┘  └────────────┘  └──────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   DVC Cache (.dvc/cache)                │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │  /a1/  │  /b2/  │  /c3/  │  ...  │  /zz/      │  │  │
│  │  │  MD5   │  MD5   │  MD5   │       │  MD5       │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Remote Storage                         │  │
│  │  ┌──────────────────────────────────────────────────┐  │  │
│  │  │  S3  │  GCS  │  Azure  │  SSH  │  Local        │  │  │
│  │  └──────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### File Structure

```bash
# DVC internal directory structure
.dvc/
├── cache/                    # Data cache
│   ├── a1/                   # First two chars of MD5 hash
│   │   └── b2c3d4e5...       # Actual cached data
│   ├── b2/
│   └── ...
├── config                    # DVC configuration
├── config.local              # Local overrides (gitignored)
├── plots/                    # Plot definitions
├── tmp/                      # Temporary files
└── state                     # State database (SQLite)

# DVC pointer files
data/raw/sensor_data.csv.dvc
├── outs:                     # Outputs tracked by this file
│   └── - md5: a1b2c3d4e5f6  # MD5 hash of the data
│        path: sensor_data.csv # Path to the data
│        size: 1024000        # File size in bytes
├── meta:                     # Metadata
│   └── ...
└── wdir: .                   # Working directory
```

### DVC Internals: The State Database

```python
# DVC uses SQLite for state management
import sqlite3

# View the state database
conn = sqlite3.connect('.dvc/state')
cursor = conn.cursor()

# Check tracked files
cursor.execute("SELECT * FROM state")
for row in cursor.fetchall():
    print(row)

# View cache information
cursor.execute("SELECT * FROM cache")
for row in cursor.fetchall():
    print(row)
```

---

## 2. DVC File Formats

### DVC File (.dvc) Structure

```yaml
# Example .dvc file structure
md5: 8d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a  # Hash of this file
outs:
- md5: 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d  # Hash of the data
  path: data/raw/sensor_data.csv          # Path to the data
  size: 1024000                           # Size in bytes
  hash: md5                               # Hash algorithm
  cache: true                             # Whether it's cached
  metric: false                           # Whether it's a metric
  persist: false                          # Whether to persist
wdir: .                                   # Working directory
```

### DVC Pipeline File (dvc.yaml)

```yaml
# dvc.yaml structure with variables
vars:
  - data_dir: data
  - model_dir: models

stages:
  generate_data:
    cmd: python src/data/generate.py --output ${data_dir}/raw/data.csv
    deps:
      - src/data/generate.py
    outs:
      - ${data_dir}/raw/data.csv
    params:
      - params.yaml#data.raw.hours
    meta:
      - description: "Generate raw sensor data"
      - owner: "data_science_team"

  process_data:
    cmd: python src/features/build.py --input ${data_dir}/raw/data.csv --output ${data_dir}/processed/features.csv
    deps:
      - src/features/build.py
      - ${data_dir}/raw/data.csv
    outs:
      - ${data_dir}/processed/features.csv
    params:
      - params.yaml#features.windows
    meta:
      - description: "Process features"
      - requires_gpu: false

  train_model:
    cmd: python models/training/train.py --features ${data_dir}/processed/features.csv --output ${model_dir}/model.pkl
    deps:
      - models/training/train.py
      - ${data_dir}/processed/features.csv
    outs:
      - ${model_dir}/model.pkl
    params:
      - params.yaml#model.training
    meta:
      - description: "Train model"
      - requires_gpu: true
```

---

## 3. DVC Cache Management

### Cache Structure

```bash
# Cache directory structure
.dvc/cache/
├── 1a/                    # First two characters of MD5
│   ├── 2b3c4d5e...        # Actual cached content
│   ├── 3c4d5e6f...        # Multiple files with same prefix
│   └── ...
├── files/                 # For large files
│   └── md5/               # Organized by MD5
│       └── 1a2b...
└── tmp/                   # Temporary cache during operations
```

### Cache Operations

```bash
# View cache usage
dvc cache dir
du -sh .dvc/cache

# View cache statistics
dvc status --caches

# Clean cache
dvc gc                     # Remove unused cache
dvc gc --workspace         # Keep only current workspace
dvc gc --all-commits       # Check all commits
dvc gc --force             # Force removal

# Debug cache issues
dvc cache verify           # Verify cache integrity
dvc cache checkout         # Restore from cache
```

### Manual Cache Management

```python
import hashlib
from pathlib import Path
import shutil

def compute_md5(file_path: Path) -> str:
    """Compute MD5 hash of a file."""
    with open(file_path, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def add_to_cache(file_path: Path, cache_dir: Path = Path('.dvc/cache')):
    """Manually add a file to DVC cache."""
    md5_hash = compute_md5(file_path)
    prefix = md5_hash[:2]
    cache_path = cache_dir / prefix / md5_hash
    
    # Copy to cache
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(file_path, cache_path)
    
    # Create symlink
    file_path.parent.mkdir(parents=True, exist_ok=True)
    file_path.symlink_to(cache_path)
    
    return md5_hash

def restore_from_cache(md5_hash: str, target_path: Path):
    """Restore a file from cache."""
    prefix = md5_hash[:2]
    cache_path = Path('.dvc/cache') / prefix / md5_hash
    
    if cache_path.exists():
        target_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(cache_path, target_path)
        return True
    return False
```

---

## 4. DVC Remote Storage

### Remote Configuration

```yaml
# .dvc/config
['remote "s3_remote"']
url = s3://my-bucket/dvc-storage
region = us-east-1
access_key_id = ${AWS_ACCESS_KEY_ID}
secret_access_key = ${AWS_SECRET_ACCESS_KEY}

['remote "gcs_remote"']
url = gs://my-bucket/dvc-storage
credentialpath = ${GOOGLE_APPLICATION_CREDENTIALS}

['remote "azure_remote"']
url = azure://container-name/path
account_name = ${AZURE_ACCOUNT_NAME}
account_key = ${AZURE_ACCOUNT_KEY}

['remote "ssh_remote"']
url = ssh://user@server:/path/to/dvc-storage
user = ${SSH_USER}
keyfile = ${SSH_KEYFILE}

# Default remote
['core']
remote = s3_remote
```

### Remote Storage Internals

```
# S3 Remote Structure
s3://my-bucket/dvc-storage/
├── 1a/                    # First two chars of MD5
│   └── 2b3c4d5e...        # Cached data (same as local)
├── b2/
│   └── 3c4d5e6f...
└── ...
```

### Advanced Remote Features

```bash
# Configure remote for specific data types
dvc remote modify s3_remote acl bucket-owner-full-control
dvc remote modify s3_remote sse AES256              # Encryption
dvc remote modify s3_remote version_aware true      # Versioning support

# Multiple remotes
dvc remote add prod_s3 s3://prod-bucket/dvc-storage
dvc remote add staging_s3 s3://staging-bucket/dvc-storage
dvc remote modify prod_s3 acl private

# Push to specific remote
dvc push --remote prod_s3

# Pull from specific remote
dvc pull --remote staging_s3

# Import from remote (not full pull)
dvc import --remote prod_s3 data/raw/sensor_data.csv
```

### Remote Verification

```python
import boto3
import json

def verify_s3_remote(bucket: str, prefix: str = "dvc-storage"):
    """Verify S3 remote structure."""
    s3 = boto3.client('s3')
    
    # List objects
    paginator = s3.get_paginator('list_objects_v2')
    pages = paginator.paginate(Bucket=bucket, Prefix=prefix)
    
    total_size = 0
    total_files = 0
    
    for page in pages:
        if 'Contents' in page:
            for obj in page['Contents']:
                total_size += obj['Size']
                total_files += 1
    
    return {
        'total_files': total_files,
        'total_size_mb': total_size / (1024 * 1024),
        'bucket': bucket,
        'prefix': prefix
    }
```

---

## 5. DVC Pipeline Execution

### Pipeline Execution Flow

```python
"""
DVC pipeline execution flow:
1. Parse dvc.yaml
2. Build dependency graph
3. Calculate MD5 hashes of dependencies
4. Compare with state database
5. Determine which stages need to run
6. Execute stages in topological order
7. Update state database
8. Commit changes
"""

# Simulated pipeline execution
class DVCStage:
    def __init__(self, name, cmd, deps, outs, params):
        self.name = name
        self.cmd = cmd
        self.deps = deps
        self.outs = outs
        self.params = params

class DVCPipeline:
    def __init__(self, stages):
        self.stages = {s.name: s for s in stages}
        self.graph = self._build_graph()
    
    def _build_graph(self):
        """Build dependency graph."""
        graph = {}
        for name, stage in self.stages.items():
            graph[name] = []
            for dep in stage.deps:
                # Find which stage produces this dependency
                for other_name, other_stage in self.stages.items():
                    if dep in other_stage.outs:
                        graph[name].append(other_name)
        return graph
    
    def topological_sort(self):
        """Topological sort of stages."""
        visited = set()
        result = []
        
        def dfs(node):
            visited.add(node)
            for neighbor in self.graph.get(node, []):
                if neighbor not in visited:
                    dfs(neighbor)
            result.append(node)
        
        for node in self.stages:
            if node not in visited:
                dfs(node)
        
        return result[::-1]
    
    def execute(self):
        """Execute pipeline in order."""
        ordered_stages = self.topological_sort()
        
        for stage_name in ordered_stages:
            stage = self.stages[stage_name]
            print(f"Executing {stage_name}")
            # Execute command
            import subprocess
            result = subprocess.run(
                stage.cmd,
                shell=True,
                check=True
            )
            # Update state
            self._update_state(stage)
    
    def _update_state(self, stage):
        """Update pipeline state."""
        # Calculate hashes of outputs
        for out in stage.outs:
            hash = compute_md5(Path(out))
            # Store in state database
            # ...
```

### Parallel Execution

```python
import concurrent.futures
import time

def execute_stage_parallel(stage_name, stage_commands):
    """Execute stages in parallel where dependencies allow."""
    # Build dependency graph
    deps = {name: deps for name, deps in stage_commands}
    
    # Track completed stages
    completed = set()
    results = {}
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        # Submit all stages that can run
        future_to_stage = {}
        
        while len(completed) < len(deps):
            # Find stages whose dependencies are complete
            available = []
            for name, stage_deps in deps.items():
                if name not in completed and all(d in completed for d in stage_deps):
                    available.append(name)
            
            # Submit available stages
            for name in available:
                future = executor.submit(execute_stage, name)
                future_to_stage[future] = name
            
            # Wait for completion
            for future in concurrent.futures.as_completed(future_to_stage):
                name = future_to_stage[future]
                results[name] = future.result()
                completed.add(name)
    
    return results
```

---

## 6. DVC with Large Files

### Handling Large Datasets

```python
import dvc.api
from pathlib import Path

class LargeDatasetHandler:
    def __init__(self, repo_path: str = "."):
        self.repo_path = repo_path
    
    def get_data_version(self, data_path: str) -> str:
        """Get the version hash of a tracked file."""
        with dvc.api.open(data_path, repo=self.repo_path) as f:
            return dvc.api.get_url(data_path, repo=self.repo_path)
    
    def stream_large_file(self, data_path: str, chunk_size: int = 1024*1024):
        """Stream a large file from DVC cache."""
        with dvc.api.open(data_path, repo=self.repo_path) as f:
            while True:
                chunk = f.read(chunk_size)
                if not chunk:
                    break
                yield chunk
    
    def get_file_metadata(self, data_path: str):
        """Get metadata for a tracked file."""
        import yaml
        dvc_file = Path(data_path).with_suffix(data_path.suffix + '.dvc')
        
        if not dvc_file.exists():
            return {'tracked': False}
        
        with open(dvc_file, 'r') as f:
            info = yaml.safe_load(f)
        
        return {
            'tracked': True,
            'md5': info['outs'][0]['md5'],
            'size': info['outs'][0]['size'],
            'path': info['outs'][0]['path']
        }
```

### Memory-Efficient Processing

```python
def process_large_dataset(data_path: str, batch_size: int = 10000):
    """
    Process a large dataset in batches using DVC streaming.
    """
    import pandas as pd
    import dvc.api
    
    # Get file metadata
    with dvc.api.open(data_path, repo='.') as f:
        # Process in chunks
        for chunk in pd.read_csv(f, chunksize=batch_size):
            # Process chunk
            yield process_chunk(chunk)
```

---

## 7. DVC API and Programmatic Usage

### Python API

```python
import dvc.api
import dvc.repo

# Get information about tracked files
info = dvc.api.get_url(
    'data/raw/sensor_data.csv',
    repo='.'
)

# Open tracked file
with dvc.api.open('data/raw/sensor_data.csv') as f:
    content = f.read()

# Get data from a specific version
with dvc.api.open(
    'data/raw/sensor_data.csv',
    rev='v1.0.0'
) as f:
    content = f.read()

# Programmatic DVC operations
repo = dvc.repo.Repo('.')

# Add file
repo.add('data/raw/new_data.csv')

# Run pipeline
repo.reproduce('dvc.yaml')

# Push data
repo.push()

# Pull data
repo.pull()

# Get pipeline status
status = repo.status()
for file, info in status.items():
    print(f"{file}: {info}")
```

### Advanced API Usage

```python
import dvc.repo
import json

class DVCAnalyzer:
    def __init__(self, repo_path: str = "."):
        self.repo = dvc.repo.Repo(repo_path)
    
    def get_pipeline_graph(self) -> dict:
        """Get the pipeline dependency graph."""
        stages = self.repo.stages()
        
        graph = {}
        for stage in stages:
            graph[stage.name] = {
                'deps': stage.deps,
                'outs': stage.outs,
                'cmd': stage.cmd
            }
        
        return graph
    
    def get_data_lineage(self, file_path: str) -> list:
        """Get the lineage of a data file."""
        lineage = []
        
        # Find which stage produces this file
        stages = self.repo.stages()
        for stage in stages:
            for out in stage.outs:
                if out.fs_path.endswith(file_path):
                    lineage.append({
                        'stage': stage.name,
                        'cmd': stage.cmd,
                        'deps': [d.fs_path for d in stage.deps]
                    })
                    break
        
        return lineage
    
    def compare_versions(self, file_path: str, rev1: str, rev2: str) -> dict:
        """Compare two versions of a data file."""
        import hashlib
        
        with self.repo.open(file_path, rev=rev1) as f1:
            hash1 = hashlib.md5(f1.read()).hexdigest()
        
        with self.repo.open(file_path, rev=rev2) as f2:
            hash2 = hashlib.md5(f2.read()).hexdigest()
        
        return {
            'file': file_path,
            'rev1': rev1,
            'rev2': rev2,
            'hash1': hash1,
            'hash2': hash2,
            'identical': hash1 == hash2
        }
```

---

## 8. DVC Best Practices

### Data Organization

```bash
# Recommended directory structure
data/
├── raw/          # Raw, immutable data
├── processed/    # Processed data (features)
├── external/     # External data sources
├── interim/      # Intermediate data
└── model/        # Model artifacts
```

### Versioning Strategy

```python
# Tag important data versions
dvc tag data/raw/sensor_data.csv v1.0.0
dvc tag data/raw/sensor_data.csv v2.0.0 --with-msg "Added new sensors"

# List tags
dvc tag list

# Checkout specific version
dvc checkout data/raw/sensor_data.csv --tag v1.0.0
```

### Pipeline Optimization

```python
# Use variables to avoid duplication
# dvc.yaml
vars:
  - data_dir: data
  - model_dir: models

# Use external dependencies
download_data:
  cmd: python scripts/download.py
  deps:
    - scripts/download.py
    - https://example.com/data.csv  # External URL as dep
  outs:
    - ${data_dir}/raw/data.csv

# Use metrics for tracking
evaluate_model:
  cmd: python scripts/evaluate.py
  deps:
    - ${model_dir}/model.pkl
  outs:
    - metrics.json
  metrics:
    - metrics.json: {cache: false}
```

---

## Troubleshooting DVC

### Common Issues and Solutions

```bash
# Issue: Cache corruption
dvc cache verify
dvc gc --force
dvc pull

# Issue: Remote connection problems
dvc remote modify <remote> --local
export AWS_ACCESS_KEY_ID=<key>
dvc push

# Issue: Lock file conflicts
dvc status
git pull
dvc pull
dvc repro

# Issue: Pipeline not updating
dvc status --checks
dvc repro --force

# Issue: Large cache
dvc gc --workspace
dvc gc --all-commits
```

### Debugging DVC

```bash
# Debug mode
dvc repro --verbose
dvc push --verbose
dvc pull --verbose

# Check DVC version
dvc version

# Check DVC configuration
dvc config --list
dvc config --system
dvc config --global
dvc config --local

# Check state database
sqlite3 .dvc/state "SELECT * FROM state;"
sqlite3 .dvc/state "SELECT * FROM cache;"
```

---

*End of Primer 2: Data Version Control (DVC) Deep Dive*
