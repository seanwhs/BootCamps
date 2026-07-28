# Primer 5: Data Engineering for ML

## Overview

This primer provides a crash course in data engineering concepts essential for machine learning. It covers data collection, storage, processing, and quality management—the foundation upon which all ML systems are built. Understanding these concepts is crucial for building robust, scalable ML pipelines.

---

## 1. The Data Engineering Landscape

### The Data Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA PIPELINE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│  │  Data       │───▶│  Data       │───▶│  Data       │        │
│  │  Collection │    │  Storage    │    │  Processing │        │
│  └─────────────┘    └─────────────┘    └─────────────┘        │
│         │                  │                  │                │
│         ▼                  ▼                  ▼                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Data Quality │ Data Governance │ Data Security         │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│  │  Feature    │───▶│  Model      │───▶│  Prediction │        │
│  │  Store      │    │  Training   │    │  Serving    │        │
│  └─────────────┘    └─────────────┘    └─────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Engineering vs Data Science

```
┌─────────────────────────────────────────────────────────────────┐
│              DATA ENGINEERING VS DATA SCIENCE                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   Data Engineer   ║  ║   Data Scientist  ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
│  • Infrastructure       │  • Analysis                         │
│  • Data Pipelines       │  • Modeling                         │
│  • Data Quality         │  • Feature Engineering              │
│  • Data Warehousing     │  • Experimentation                  │
│  • ETL/ELT              │  • Visualization                    │
│  • Data Governance      │  • Business Insights                │
│  • Performance          │  • Algorithms                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Types and Storage

### Data Types

| Type | Description | Examples | Storage |
|------|-------------|----------|---------|
| **Structured** | Tabular, organized | CSV, SQL tables | RDBMS, Data Warehouses |
| **Semi-structured** | Some structure | JSON, XML, Parquet | NoSQL, Object storage |
| **Unstructured** | No predefined format | Text, Images, Audio | Object storage, Blobs |
| **Streaming** | Continuous flow | Events, Logs | Message queues, Kafka |

### Storage Systems

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORAGE SYSTEMS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Databases                                                     │
│  ├── Relational (PostgreSQL, MySQL)                           │
│  ├── NoSQL (MongoDB, Cassandra)                               │
│  └── Vector Databases (Pinecone, Milvus)                     │
│                                                                 │
│  Data Warehouses                                               │
│  ├── Snowflake                                                 │
│  ├── BigQuery                                                  │
│  ├── Redshift                                                  │
│  └── Databricks                                                │
│                                                                 │
│  Data Lakes                                                    │
│  ├── S3                                                        │
│  ├── Azure Blob                                                │
│  ├── GCS                                                       │
│  └── HDFS                                                      │
│                                                                 │
│  File Formats                                                  │
│  ├── CSV (Universal, slow)                                    │
│  ├── Parquet (Columnar, fast)                                 │
│  ├── Avro (Row-based, schema)                                 │
│  ├── ORC (Optimized, Hadoop)                                  │
│  └── JSON (Semi-structured)                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Choosing a Storage Format

```python
# CSV - Simple but inefficient
df.to_csv('data.csv', index=False)
df = pd.read_csv('data.csv')

# Parquet - Columnar, fast, compressed
df.to_parquet('data.parquet', compression='snappy')
df = pd.read_parquet('data.parquet')

# JSON - Flexible but slower
df.to_json('data.json', orient='records')
df = pd.read_json('data.json', orient='records')

# HDF5 - Hierarchical, scientific data
df.to_hdf('data.h5', key='df', mode='w')
df = pd.read_hdf('data.h5', key='df')
```

---

## 3. ETL/ELT Pipelines

### ETL vs ELT

```
┌─────────────────────────────────────────────────────────────────┐
│                    ETL VS ELT                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ETL (Extract, Transform, Load)                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Extract ──▶ Transform ──▶ Load ──▶ Analytics           │  │
│  │  (Source)    (Compute)    (DW)    (Reports)              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ELT (Extract, Load, Transform)                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Extract ──▶ Load ──▶ Transform ──▶ Analytics           │  │
│  │  (Source)    (DW)     (Compute)   (Reports)              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Simple ETL Pipeline

```python
import pandas as pd
from sqlalchemy import create_engine
from loguru import logger

class ETLPipeline:
    """Simple ETL pipeline implementation."""
    
    def __init__(self, config):
        self.config = config
        self.engine = create_engine(config['database_url'])
    
    def extract(self, source_config):
        """Extract data from source."""
        logger.info(f"Extracting from {source_config['type']}")
        
        if source_config['type'] == 'csv':
            return pd.read_csv(source_config['path'])
        elif source_config['type'] == 'sql':
            return pd.read_sql(source_config['query'], self.engine)
        elif source_config['type'] == 'api':
            import requests
            response = requests.get(source_config['url'])
            return pd.DataFrame(response.json())
        else:
            raise ValueError(f"Unknown source type: {source_config['type']}")
    
    def transform(self, df, transforms):
        """Apply transformations to data."""
        logger.info("Applying transformations")
        
        for transform in transforms:
            if transform['type'] == 'clean':
                df = self._clean_data(df, transform.get('params', {}))
            elif transform['type'] == 'filter':
                df = self._filter_data(df, transform['condition'])
            elif transform['type'] == 'aggregate':
                df = self._aggregate_data(df, transform['group_by'], transform['agg'])
            elif transform['type'] == 'join':
                df = self._join_data(df, transform['other'], transform['on'])
        
        return df
    
    def load(self, df, target_config):
        """Load data to target."""
        logger.info(f"Loading to {target_config['type']}")
        
        if target_config['type'] == 'csv':
            df.to_csv(target_config['path'], index=False)
        elif target_config['type'] == 'sql':
            df.to_sql(target_config['table'], self.engine, 
                     if_exists='replace', index=False)
        elif target_config['type'] == 'parquet':
            df.to_parquet(target_config['path'], index=False)
        else:
            raise ValueError(f"Unknown target type: {target_config['type']}")
    
    def _clean_data(self, df, params):
        """Clean data."""
        # Remove duplicates
        if params.get('remove_duplicates'):
            df = df.drop_duplicates()
        
        # Handle missing values
        if params.get('fill_missing'):
            df = df.fillna(params.get('fill_value', 0))
        
        # Convert types
        if params.get('dtypes'):
            for col, dtype in params['dtypes'].items():
                if col in df.columns:
                    df[col] = df[col].astype(dtype)
        
        return df
    
    def _filter_data(self, df, condition):
        """Filter data by condition."""
        return df.query(condition)
    
    def _aggregate_data(self, df, group_by, agg):
        """Aggregate data."""
        return df.groupby(group_by).agg(agg).reset_index()
    
    def _join_data(self, df, other_df, on):
        """Join data."""
        return pd.merge(df, other_df, on=on, how='left')
    
    def run(self):
        """Run the complete ETL pipeline."""
        logger.info("Starting ETL pipeline")
        
        # Extract
        df = self.extract(self.config['source'])
        
        # Transform
        df = self.transform(df, self.config['transforms'])
        
        # Load
        self.load(df, self.config['target'])
        
        logger.info(f"ETL pipeline complete. Shape: {df.shape}")
        return df

# Example usage
config = {
    'source': {'type': 'csv', 'path': 'data/raw/customers.csv'},
    'transforms': [
        {'type': 'clean', 'params': {'remove_duplicates': True}},
        {'type': 'filter', 'condition': 'age > 18'},
        {'type': 'aggregate', 'group_by': 'city', 'agg': {'spend': 'sum'}}
    ],
    'target': {'type': 'parquet', 'path': 'data/processed/customers_agg.parquet'}
}

pipeline = ETLPipeline(config)
df = pipeline.run()
```

---

## 4. Data Quality

### Data Quality Dimensions

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA QUALITY DIMENSIONS                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   Completeness   ║  ║   Accuracy        ║                  │
│  ║  (Missing values)║  ║  (Correct values) ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   Consistency     ║  ║   Timeliness      ║                  │
│  ║  (Same format)    ║  ║  (Up-to-date)     ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
│  ╔═══════════════════╗  ╔═══════════════════╗                  │
│  ║   Validity        ║  ║   Uniqueness      ║                  │
│  ║  (Within range)   ║  ║  (No duplicates)  ║                  │
│  ╚═══════════════════╝  ╚═══════════════════╝                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Quality Checks

```python
class DataQualityChecker:
    """
    Comprehensive data quality checker.
    """
    
    def __init__(self):
        self.results = {}
    
    def check_completeness(self, df):
        """Check for missing values."""
        results = {}
        for col in df.columns:
            null_count = df[col].isnull().sum()
            null_pct = (null_count / len(df)) * 100
            results[col] = {
                'null_count': null_count,
                'null_percentage': null_pct,
                'status': 'pass' if null_pct < 5 else 'warn' if null_pct < 20 else 'fail'
            }
        return results
    
    def check_accuracy(self, df, rules):
        """Check data accuracy against rules."""
        results = {}
        for col, rule in rules.items():
            if col in df.columns:
                if rule['type'] == 'value_range':
                    invalid = df[(df[col] < rule['min']) | (df[col] > rule['max'])]
                elif rule['type'] == 'allowed_values':
                    invalid = df[~df[col].isin(rule['values'])]
                elif rule['type'] == 'regex':
                    invalid = df[~df[col].astype(str).str.match(rule['pattern'])]
                else:
                    invalid = pd.DataFrame()
                
                invalid_count = len(invalid)
                invalid_pct = (invalid_count / len(df)) * 100
                results[col] = {
                    'invalid_count': invalid_count,
                    'invalid_percentage': invalid_pct,
                    'status': 'pass' if invalid_pct < 1 else 'warn' if invalid_pct < 5 else 'fail'
                }
        return results
    
    def check_consistency(self, df):
        """Check data consistency."""
        results = {}
        for col in df.columns:
            # Check for mixed types
            types = df[col].apply(type).unique()
            if len(types) > 1:
                results[col] = {
                    'mixed_types': True,
                    'types': [str(t) for t in types],
                    'status': 'fail'
                }
            else:
                results[col] = {
                    'mixed_types': False,
                    'type': str(types[0]),
                    'status': 'pass'
                }
        return results
    
    def check_uniqueness(self, df, key_columns=None):
        """Check for duplicates."""
        if key_columns is None:
            duplicates = df.duplicated().sum()
        else:
            duplicates = df.duplicated(subset=key_columns).sum()
        
        duplicate_pct = (duplicates / len(df)) * 100
        return {
            'duplicate_count': duplicates,
            'duplicate_percentage': duplicate_pct,
            'status': 'pass' if duplicate_pct < 1 else 'warn' if duplicate_pct < 5 else 'fail'
        }
    
    def check_schema(self, df, schema):
        """Check if data matches expected schema."""
        results = {
            'passed': True,
            'checks': {}
        }
        
        # Check required columns
        required_cols = schema.get('required_columns', [])
        missing_cols = [c for c in required_cols if c not in df.columns]
        results['checks']['required_columns'] = {
            'missing': missing_cols,
            'status': 'fail' if missing_cols else 'pass'
        }
        if missing_cols:
            results['passed'] = False
        
        # Check column types
        for col, dtype in schema.get('column_types', {}).items():
            if col in df.columns:
                actual = str(df[col].dtype)
                expected = dtype
                matches = actual == expected
                results['checks'][f'type_{col}'] = {
                    'expected': expected,
                    'actual': actual,
                    'matches': matches,
                    'status': 'pass' if matches else 'fail'
                }
                if not matches:
                    results['passed'] = False
        
        return results
    
    def generate_report(self, df, schema=None, rules=None):
        """Generate complete data quality report."""
        report = {
            'timestamp': datetime.now().isoformat(),
            'row_count': len(df),
            'column_count': len(df.columns)
        }
        
        # Run all checks
        report['completeness'] = self.check_completeness(df)
        
        if rules:
            report['accuracy'] = self.check_accuracy(df, rules)
        
        report['consistency'] = self.check_consistency(df)
        report['uniqueness'] = self.check_uniqueness(df)
        
        if schema:
            report['schema'] = self.check_schema(df, schema)
        
        # Calculate overall quality score
        all_results = []
        for check in ['completeness', 'accuracy', 'consistency', 'uniqueness']:
            if check in report:
                for col, result in report[check].items():
                    if isinstance(result, dict) and 'status' in result:
                        all_results.append(result['status'])
        
        if all_results:
            pass_count = sum(1 for s in all_results if s == 'pass')
            report['quality_score'] = (pass_count / len(all_results)) * 100
        
        return report

# Example usage
checker = DataQualityChecker()

schema = {
    'required_columns': ['id', 'age', 'income', 'city'],
    'column_types': {
        'id': 'int64',
        'age': 'int64',
        'income': 'float64'
    }
}

rules = {
    'age': {'type': 'value_range', 'min': 0, 'max': 120},
    'income': {'type': 'value_range', 'min': 0, 'max': 1000000},
    'city': {'type': 'allowed_values', 'values': ['NYC', 'LA', 'Chicago', 'Boston']}
}

report = checker.generate_report(df, schema, rules)
print(f"Quality Score: {report['quality_score']:.2f}%")
```

---

## 5. Data Versioning

### Why Data Versioning Matters

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA VERSIONING BENEFITS                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Reproducibility                                            │
│     └── Same data + same code = same results                  │
│                                                                 │
│  2. Rollback                                                   │
│     └── Revert to previous data if issues found               │
│                                                                 │
│  3. Experiment Tracking                                        │
│     └── Track which data version was used for each experiment  │
│                                                                 │
│  4. Collaboration                                               │
│     └── Team members work with same data                      │
│                                                                 │
│  5. Auditing                                                    │
│     └── Track data lineage and changes                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Simple Data Versioning with DVC

```bash
# Initialize DVC
dvc init

# Track data files
dvc add data/raw/customers.csv
dvc add data/raw/transactions.csv

# Commit data version
git add data/raw/customers.csv.dvc data/raw/transactions.csv.dvc
git commit -m "Added initial data"

# Push to remote storage
dvc push

# Update data
dvc pull data/raw/customers.csv.dvc  # Get specific version
```

### Programmatic Data Versioning

```python
import hashlib
import json
from pathlib import Path
from datetime import datetime

class DataVersioner:
    """
    Simple data versioning system.
    """
    
    def __init__(self, version_dir='data/versions'):
        self.version_dir = Path(version_dir)
        self.version_dir.mkdir(parents=True, exist_ok=True)
        self.manifest_file = self.version_dir / 'manifest.json'
        self.manifest = self._load_manifest()
    
    def _load_manifest(self):
        """Load version manifest."""
        if self.manifest_file.exists():
            with open(self.manifest_file, 'r') as f:
                return json.load(f)
        return {'versions': []}
    
    def _save_manifest(self):
        """Save version manifest."""
        with open(self.manifest_file, 'w') as f:
            json.dump(self.manifest, f, indent=2)
    
    def _compute_hash(self, filepath):
        """Compute hash of a file."""
        hasher = hashlib.sha256()
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b''):
                hasher.update(chunk)
        return hasher.hexdigest()
    
    def version_data(self, filepath, metadata=None):
        """Create a new version of data."""
        filepath = Path(filepath)
        
        # Compute hash
        file_hash = self._compute_hash(filepath)
        
        # Check if version already exists
        for version in self.manifest['versions']:
            if version['hash'] == file_hash:
                print(f"Version already exists: {version['id']}")
                return version['id']
        
        # Create new version
        version_id = f"v{len(self.manifest['versions']) + 1:04d}"
        version_path = self.version_dir / version_id
        version_path.mkdir(exist_ok=True)
        
        # Copy file
        import shutil
        shutil.copy(filepath, version_path / filepath.name)
        
        # Save metadata
        version_info = {
            'id': version_id,
            'hash': file_hash,
            'path': str(filepath),
            'size': filepath.stat().st_size,
            'created_at': datetime.now().isoformat(),
            'metadata': metadata or {}
        }
        
        self.manifest['versions'].append(version_info)
        self._save_manifest()
        
        return version_id
    
    def get_version(self, version_id=None):
        """Get a specific version or latest."""
        if version_id is None:
            # Return latest
            return self.manifest['versions'][-1] if self.manifest['versions'] else None
        
        for version in self.manifest['versions']:
            if version['id'] == version_id:
                return version
        return None
    
    def restore_version(self, version_id, target_path):
        """Restore a version to a target path."""
        version = self.get_version(version_id)
        if not version:
            raise ValueError(f"Version {version_id} not found")
        
        source_path = Path(version['path'])
        version_path = self.version_dir / version_id / source_path.name
        
        import shutil
        shutil.copy(version_path, target_path)
        
        print(f"Restored {version_id} to {target_path}")
        return True
    
    def list_versions(self):
        """List all versions."""
        return [
            {
                'id': v['id'],
                'path': v['path'],
                'created_at': v['created_at'],
                'metadata': v['metadata']
            }
            for v in self.manifest['versions']
        ]

# Example usage
versioner = DataVersioner()

# Version data
version_id = versioner.version_data(
    'data/raw/customers.csv',
    metadata={'source': 'CRM', 'date': '2024-01-01'}
)

# List versions
for version in versioner.list_versions():
    print(f"{version['id']}: {version['path']} - {version['created_at']}")

# Restore version
versioner.restore_version(version_id, 'data/restored/customers.csv')
```

---

## 6. Data Lineage

### What is Data Lineage?

Data lineage tracks the flow of data from its source through transformations to its final destination.

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA LINEAGE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Source ──▶ Transform 1 ──▶ Transform 2 ──▶ Destination        │
│                                                                 │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    │
│  │  CRM    │───▶│ Clean   │───▶│ Feature │───▶│ Model   │    │
│  │  Data   │    │ Data    │    │ Engine  │    │ Training│    │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘    │
│                                                                 │
│  Lineage helps:                                                │
│  • Understand data flow                                        │
│  • Debug issues                                                │
│  • Track dependencies                                          │
│  • Ensure compliance                                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Simple Lineage Tracking

```python
class DataLineageTracker:
    """
    Simple data lineage tracking.
    """
    
    def __init__(self):
        self.lineage = {}
        self.current_context = None
    
    def start_context(self, name, metadata=None):
        """Start a new lineage context."""
        self.current_context = {
            'id': f"ctx_{len(self.lineage) + 1}",
            'name': name,
            'started_at': datetime.now().isoformat(),
            'metadata': metadata or {},
            'steps': []
        }
        return self.current_context['id']
    
    def add_step(self, operation, input_data, output_data, params=None):
        """Add a processing step to the context."""
        if self.current_context is None:
            raise ValueError("No context started. Call start_context() first.")
        
        step = {
            'operation': operation,
            'input': self._get_data_info(input_data),
            'output': self._get_data_info(output_data),
            'params': params or {},
            'timestamp': datetime.now().isoformat()
        }
        
        self.current_context['steps'].append(step)
        return step
    
    def end_context(self):
        """End the current context."""
        if self.current_context is None:
            return
        
        self.current_context['ended_at'] = datetime.now().isoformat()
        self.lineage[self.current_context['id']] = self.current_context
        self.current_context = None
    
    def _get_data_info(self, data):
        """Get information about data."""
        if isinstance(data, pd.DataFrame):
            return {
                'type': 'dataframe',
                'shape': data.shape,
                'columns': data.columns.tolist(),
                'memory': data.memory_usage(deep=True).sum() / 1024**2
            }
        elif isinstance(data, str) or isinstance(data, Path):
            return {
                'type': 'file',
                'path': str(data)
            }
        else:
            return {
                'type': str(type(data).__name__)
            }
    
    def get_lineage(self, context_id=None):
        """Get lineage for a specific context or all."""
        if context_id:
            return self.lineage.get(context_id)
        return self.lineage
    
    def visualize(self, context_id=None):
        """Print lineage visualization."""
        if context_id:
            contexts = [self.lineage.get(context_id)]
        else:
            contexts = self.lineage.values()
        
        for ctx in contexts:
            if not ctx:
                continue
            
            print(f"\n📊 Lineage: {ctx['name']}")
            print(f"   Started: {ctx['started_at']}")
            
            for i, step in enumerate(ctx['steps'], 1):
                print(f"   Step {i}: {step['operation']}")
                print(f"      Input: {step['input']['type']} - {step['input'].get('shape', '')}")
                print(f"      Output: {step['output']['type']} - {step['output'].get('shape', '')}")

# Example usage
tracker = DataLineageTracker()

# Start tracking
tracker.start_context('Customer Data Pipeline', {'team': 'Data Science'})

# Load data
df_raw = pd.read_csv('data/raw/customers.csv')
tracker.add_step('load_csv', 'data/raw/customers.csv', df_raw)

# Clean data
df_clean = df_raw.drop_duplicates().fillna(0)
tracker.add_step('clean_data', df_raw, df_clean, {'remove_duplicates': True})

# Aggregate
df_agg = df_clean.groupby('city').agg({'spend': 'sum'}).reset_index()
tracker.add_step('aggregate', df_clean, df_agg, {'group_by': 'city', 'agg': 'sum'})

# Save
df_agg.to_parquet('data/processed/customers_agg.parquet')
tracker.add_step('save_parquet', df_agg, 'data/processed/customers_agg.parquet')

# End tracking
tracker.end_context()

# Visualize lineage
tracker.visualize()
```

---

## 7. Data Pipeline Orchestration

### What is Orchestration?

Orchestration is the automated coordination of data pipeline tasks, ensuring they run in the correct order, at the right time, and recover from failures.

### Simple Orchestrator

```python
import time
from datetime import datetime, timedelta
from typing import Dict, List, Callable, Any

class Task:
    """A task in the pipeline."""
    
    def __init__(self, name, func, dependencies=None, schedule=None):
        self.name = name
        self.func = func
        self.dependencies = dependencies or []
        self.schedule = schedule
        self.status = 'pending'
        self.result = None
        self.error = None
        self.start_time = None
        self.end_time = None

class PipelineOrchestrator:
    """
    Simple pipeline orchestrator.
    """
    
    def __init__(self, name):
        self.name = name
        self.tasks = {}
        self.execution_id = None
    
    def add_task(self, name, func, dependencies=None, schedule=None):
        """Add a task to the pipeline."""
        self.tasks[name] = Task(name, func, dependencies, schedule)
        return self
    
    def _check_dependencies(self, task_name):
        """Check if all dependencies are complete."""
        task = self.tasks[task_name]
        for dep in task.dependencies:
            if dep not in self.tasks:
                return False, f"Unknown dependency: {dep}"
            if self.tasks[dep].status not in ['completed', 'skipped']:
                return False, f"Dependency {dep} not complete"
        return True, ""
    
    def _run_task(self, task_name):
        """Run a single task."""
        task = self.tasks[task_name]
        
        # Check dependencies
        deps_ok, dep_error = self._check_dependencies(task_name)
        if not deps_ok:
            task.status = 'failed'
            task.error = dep_error
            return False
        
        # Run task
        task.start_time = datetime.now()
        task.status = 'running'
        
        try:
            # Get dependency results
            dep_results = {}
            for dep in task.dependencies:
                dep_results[dep] = self.tasks[dep].result
            
            # Execute task
            task.result = task.func(dep_results)
            task.status = 'completed'
            task.end_time = datetime.now()
            return True
            
        except Exception as e:
            task.status = 'failed'
            task.error = str(e)
            task.end_time = datetime.now()
            return False
    
    def run(self, execution_id=None):
        """Run the pipeline."""
        self.execution_id = execution_id or f"exec_{int(time.time())}"
        
        print(f"🚀 Starting pipeline: {self.name} (execution: {self.execution_id})")
        
        # Get task order (simple sequential for now)
        task_order = list(self.tasks.keys())
        
        for task_name in task_order:
            print(f"  ⏳ Running: {task_name}")
            success = self._run_task(task_name)
            
            task = self.tasks[task_name]
            duration = (task.end_time - task.start_time).total_seconds() if task.end_time else 0
            
            if success:
                print(f"  ✅ Complete: {task_name} ({duration:.2f}s)")
            else:
                print(f"  ❌ Failed: {task_name} - {task.error}")
                print(f"  ⛔ Pipeline stopped due to failure")
                return False
        
        print(f"✅ Pipeline complete: {self.name}")
        return True
    
    def get_status(self):
        """Get status of all tasks."""
        return {
            task_name: {
                'status': task.status,
                'error': task.error,
                'duration': (task.end_time - task.start_time).total_seconds() if task.end_time else None
            }
            for task_name, task in self.tasks.items()
        }

# Example usage
def extract_data(deps):
    print("  📥 Extracting data...")
    time.sleep(2)
    return {'data': [1, 2, 3, 4, 5]}

def transform_data(deps):
    print("  🔄 Transforming data...")
    data = deps['extract']['data']
    time.sleep(1)
    return {'data': [x * 2 for x in data]}

def load_data(deps):
    print("  💾 Loading data...")
    data = deps['transform']['data']
    time.sleep(1)
    return {'loaded': True, 'count': len(data)}

# Build pipeline
pipeline = PipelineOrchestrator("ETL Pipeline")
pipeline.add_task("extract", extract_data)
pipeline.add_task("transform", transform_data, dependencies=["extract"])
pipeline.add_task("load", load_data, dependencies=["transform"])

# Run pipeline
pipeline.run()

# Get status
print("\n📊 Status:")
for name, status in pipeline.get_status().items():
    print(f"  {name}: {status['status']}")
```

---

## Quick Reference: Data Engineering for ML

### Data Storage

```
┌─────────────────────────────────────────────────────────────────┐
│  FORMAT    │ USE CASE                    │ SIZE  │ SPEED     │
├────────────┼─────────────────────────────┼───────┼───────────┤
│  CSV       │ Small datasets, portability │ Large │ Slow      │
│  Parquet   │ Large datasets, analytics   │ Small │ Fast      │
│  Avro      │ Streaming, schema evolution │ Med   │ Fast      │
│  JSON      │ APIs, web data              │ Large │ Slow      │
│  HDF5      │ Scientific data             │ Med   │ Fast      │
└─────────────────────────────────────────────────────────────────┘
```

### Data Quality Checklist

```
□ 1. Check for missing values
□ 2. Validate data types
□ 3. Check value ranges
□ 4. Remove duplicates
□ 5. Check for consistency
□ 6. Validate schema
□ 7. Check for outliers
□ 8. Monitor data drift
□ 9. Document data sources
□ 10. Version data
```

### Pipeline Checklist

```
□ 1. Define data sources
□ 2. Plan transformations
□ 3. Choose storage format
□ 4. Implement ETL/ELT
□ 5. Add data quality checks
□ 6. Implement versioning
□ 7. Set up monitoring
□ 8. Document lineage
□ 9. Automate orchestration
□ 10. Plan for failure recovery
```

---

## Conclusion

This primer covers the essential data engineering concepts for ML. You now understand:

1. **Data types and storage**: How to choose the right format
2. **ETL/ELT pipelines**: How to build data pipelines
3. **Data quality**: How to ensure data quality
4. **Data versioning**: How to track data changes
5. **Data lineage**: How to trace data flow
6. **Orchestration**: How to automate pipelines

**Next Steps:**
1. Practice with different data formats
2. Build a data quality system
3. Implement data versioning
4. Create an orchestrated pipeline
5. Proceed to Part 1 of the series

---

*End of Primer 5*
