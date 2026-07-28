# Part 2: Versioning Datasets and Feature Stores

## The Target: Managing Multiple Data Assets with DVC

In this part, we'll expand our DVC usage to handle multiple datasets, create data processing pipelines, and version intermediate artifacts like feature stores. By the end, you'll have a complete data versioning workflow that tracks raw data, processed features, and everything in between.

## The Concept: Data Pipeline as Code

Think of your data pipeline like an assembly line in a factory:
- **Raw materials** (raw data) come in at the beginning
- **Processing stations** (your scripts) transform the materials
- **Intermediate products** (processed data, features) move between stations
- **Final product** (feature store) comes out at the end

DVC lets you version every product along this assembly line. When a defect is found (a bug in processing), you can roll back any component to a known good state.

## The Implementation: Building Our Data Pipeline

### Step 1: Create a Realistic Dataset

First, let's create a more realistic dataset for our predictive maintenance system. We'll generate synthetic sensor data that mimics industrial equipment:

```bash
# Create a Python script to generate synthetic data
cat > src/data/generate_sensor_data.py << 'EOF'
#!/usr/bin/env python
"""
Synthetic sensor data generator for predictive maintenance.
Generates realistic vibration, temperature, and pressure readings
with occasional anomalies.
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import argparse
import os
from pathlib import Path


def generate_sensor_data(
    num_hours: int = 24,
    sampling_rate_seconds: int = 60,
    anomaly_probability: float = 0.05,
    output_path: str = "data/raw/sensor_data.csv",
) -> None:
    """
    Generate synthetic sensor data for predictive maintenance.
    
    Args:
        num_hours: Number of hours of data to generate
        sampling_rate_seconds: Time between samples (seconds)
        anomaly_probability: Probability of an anomaly at each timestep
        output_path: Where to save the CSV file
    """
    
    # Calculate number of samples
    num_samples = int((num_hours * 3600) / sampling_rate_seconds)
    
    # Create timestamp range
    start_time = datetime.now() - timedelta(hours=num_hours)
    timestamps = [start_time + timedelta(seconds=i * sampling_rate_seconds) 
                  for i in range(num_samples)]
    
    # Base values for normal operation
    base_temperature = 75.0  # degrees Celsius
    base_pressure = 1.2  # bar
    base_vibration = 0.5  # mm/s
    
    # Generate normal sensor readings with some noise
    np.random.seed(42)  # For reproducibility
    
    # Temperature: follows daily cycle with random noise
    hour_of_day = np.array([ts.hour for ts in timestamps])
    daily_temp_variation = 5.0 * np.sin(2 * np.pi * hour_of_day / 24)
    temperature = base_temperature + daily_temp_variation + np.random.normal(0, 2.0, num_samples)
    
    # Pressure: slight drift over time with noise
    time_factor = np.linspace(0, 0.1, num_samples)
    pressure = base_pressure + time_factor + np.random.normal(0, 0.05, num_samples)
    
    # Vibration: random with occasional spikes
    vibration = base_vibration + np.random.exponential(0.1, num_samples)
    
    # Sensor readings (3 sensors)
    sensor_1 = 20.0 + np.random.normal(0, 5.0, num_samples)
    sensor_2 = 30.0 + np.random.normal(0, 5.0, num_samples)
    sensor_3 = 50.0 + np.random.normal(0, 5.0, num_samples)
    
    # Introduce anomalies
    anomaly_indices = np.random.choice(
        num_samples, 
        size=int(num_samples * anomaly_probability), 
        replace=False
    )
    
    # For anomalies, spike the readings
    temperature[anomaly_indices] += np.random.uniform(10, 30, len(anomaly_indices))
    pressure[anomaly_indices] += np.random.uniform(0.3, 1.0, len(anomaly_indices))
    vibration[anomaly_indices] += np.random.uniform(1.0, 3.0, len(anomaly_indices))
    sensor_1[anomaly_indices] += np.random.uniform(10, 20, len(anomaly_indices))
    sensor_2[anomaly_indices] += np.random.uniform(10, 20, len(anomaly_indices))
    sensor_3[anomaly_indices] += np.random.uniform(10, 20, len(anomaly_indices))
    
    # Create labels (1 for anomaly, 0 for normal)
    labels = np.zeros(num_samples, dtype=int)
    labels[anomaly_indices] = 1
    
    # Build DataFrame
    df = pd.DataFrame({
        'timestamp': timestamps,
        'sensor_1': sensor_1,
        'sensor_2': sensor_2,
        'sensor_3': sensor_3,
        'temperature': temperature,
        'pressure': pressure,
        'vibration': vibration,
        'label': labels
    })
    
    # Round to 2 decimal places for realistic precision
    df = df.round(2)
    
    # Ensure output directory exists
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    
    # Save to CSV
    df.to_csv(output_path, index=False)
    print(f"Generated {len(df):,} samples and saved to {output_path}")
    print(f"Anomalies: {df['label'].sum():,} ({df['label'].mean()*100:.1f}%)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate synthetic sensor data")
    parser.add_argument("--hours", type=int, default=24, help="Number of hours of data")
    parser.add_argument("--sampling_rate", type=int, default=60, help="Sampling rate in seconds")
    parser.add_argument("--anomaly_rate", type=float, default=0.05, help="Anomaly probability")
    parser.add_argument("--output", type=str, default="data/raw/sensor_data.csv", 
                       help="Output path")
    
    args = parser.parse_args()
    
    generate_sensor_data(
        num_hours=args.hours,
        sampling_rate_seconds=args.sampling_rate,
        anomaly_probability=args.anomaly_rate,
        output_path=args.output
    )
EOF

# Make the script executable
chmod +x src/data/generate_sensor_data.py
```

### Step 2: Generate and Version Raw Data

Now let's generate our first dataset and version it with DVC:

```bash
# Generate 48 hours of sensor data
python src/data/generate_sensor_data.py --hours 48 --output data/raw/sensor_data_48h.csv

# View the generated data
head -n 5 data/raw/sensor_data_48h.csv

# Track with DVC
dvc add data/raw/sensor_data_48h.csv

# Commit to Git
git add src/data/generate_sensor_data.py data/raw/sensor_data_48h.csv.dvc
git commit -m "Add synthetic sensor data generator and 48h dataset"
```

### Step 3: Create a Feature Engineering Pipeline

Now let's build a feature engineering script that transforms our raw data into features suitable for machine learning:

```bash
cat > src/features/build_features.py << 'EOF'
#!/usr/bin/env python
"""
Feature engineering pipeline for predictive maintenance.
Extracts time-based features, rolling statistics, and other derived features.
"""

import pandas as pd
import numpy as np
from pathlib import Path
import argparse
import logging
from typing import Tuple

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def load_raw_data(input_path: str) -> pd.DataFrame:
    """
    Load raw sensor data from CSV.
    
    Args:
        input_path: Path to raw data CSV
        
    Returns:
        DataFrame with parsed timestamps
    """
    df = pd.read_csv(input_path, parse_dates=['timestamp'])
    logger.info(f"Loaded {len(df):,} rows from {input_path}")
    return df


def create_time_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create time-based features from timestamp column.
    
    Args:
        df: DataFrame with 'timestamp' column
        
    Returns:
        DataFrame with additional time features
    """
    df = df.copy()
    
    # Extract time components
    df['hour'] = df['timestamp'].dt.hour
    df['day_of_week'] = df['timestamp'].dt.dayofweek
    df['month'] = df['timestamp'].dt.month
    df['day_of_year'] = df['timestamp'].dt.dayofyear
    df['quarter'] = df['timestamp'].dt.quarter
    
    # Cyclical encoding for hour (to preserve circular nature)
    df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
    df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)
    
    # Cyclical encoding for day of week
    df['dow_sin'] = np.sin(2 * np.pi * df['day_of_week'] / 7)
    df['dow_cos'] = np.cos(2 * np.pi * df['day_of_week'] / 7)
    
    # Drop original time components (except the cyclical ones)
    df = df.drop(['hour', 'day_of_week', 'month', 'day_of_year', 'quarter'], axis=1)
    
    logger.info(f"Created time-based features")
    return df


def create_rolling_features(df: pd.DataFrame, windows: list = [5, 10, 30]) -> pd.DataFrame:
    """
    Create rolling statistics from sensor readings.
    
    Args:
        df: DataFrame with sensor columns
        windows: List of window sizes for rolling statistics
        
    Returns:
        DataFrame with rolling features
    """
    df = df.copy()
    
    # Columns that contain sensor readings
    sensor_cols = ['sensor_1', 'sensor_2', 'sensor_3', 'temperature', 'pressure', 'vibration']
    
    for col in sensor_cols:
        for window in windows:
            # Rolling mean
            df[f'{col}_rolling_mean_{window}'] = df[col].rolling(window=window, min_periods=1).mean()
            
            # Rolling standard deviation
            df[f'{col}_rolling_std_{window}'] = df[col].rolling(window=window, min_periods=1).std()
            
            # Rolling max
            df[f'{col}_rolling_max_{window}'] = df[col].rolling(window=window, min_periods=1).max()
            
            # Rolling min
            df[f'{col}_rolling_min_{window}'] = df[col].rolling(window=window, min_periods=1).min()
            
            # Rolling range (max - min)
            df[f'{col}_rolling_range_{window}'] = (
                df[f'{col}_rolling_max_{window}'] - df[f'{col}_rolling_min_{window}']
            )
    
    logger.info(f"Created rolling statistics for windows {windows}")
    return df


def create_interaction_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Create interaction features between sensors.
    
    Args:
        df: DataFrame with sensor columns
        
    Returns:
        DataFrame with interaction features
    """
    df = df.copy()
    
    # Sensor ratios and products
    df['sensor_1_2_ratio'] = df['sensor_1'] / (df['sensor_2'] + 1e-6)  # Avoid division by zero
    df['sensor_1_3_ratio'] = df['sensor_1'] / (df['sensor_3'] + 1e-6)
    df['sensor_2_3_ratio'] = df['sensor_2'] / (df['sensor_3'] + 1e-6)
    
    # Temperature and pressure interaction
    df['temp_pressure_interaction'] = df['temperature'] * df['pressure']
    
    # Sensor combinations
    df['sensor_sum'] = df['sensor_1'] + df['sensor_2'] + df['sensor_3']
    df['sensor_mean'] = df[['sensor_1', 'sensor_2', 'sensor_3']].mean(axis=1)
    df['sensor_variance'] = df[['sensor_1', 'sensor_2', 'sensor_3']].var(axis=1)
    
    logger.info("Created interaction features")
    return df


def build_features(
    input_path: str,
    output_path: str,
    rolling_windows: list = [5, 10, 30]
) -> None:
    """
    Main feature engineering pipeline.
    
    Args:
        input_path: Path to raw data CSV
        output_path: Where to save features CSV
        rolling_windows: Window sizes for rolling statistics
    """
    logger.info("Starting feature engineering pipeline")
    
    # 1. Load raw data
    df = load_raw_data(input_path)
    
    # 2. Create time features
    df = create_time_features(df)
    
    # 3. Create rolling features
    df = create_rolling_features(df, windows=rolling_windows)
    
    # 4. Create interaction features
    df = create_interaction_features(df)
    
    # 5. Handle any NaN values (from rolling windows)
    # Forward fill for missing values at the beginning of each window
    df = df.fillna(method='ffill')
    # Any remaining NaN values get filled with 0
    df = df.fillna(0)
    
    # 6. Ensure output directory exists
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    
    # 7. Save features
    df.to_csv(output_path, index=False)
    
    logger.info(f"Built {len(df.columns) - 1} features (excluding label) and saved to {output_path}")
    logger.info(f"Feature columns: {list(df.columns)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build features from raw sensor data")
    parser.add_argument("--input", type=str, default="data/raw/sensor_data_48h.csv", 
                       help="Input CSV path")
    parser.add_argument("--output", type=str, default="data/processed/features_48h.csv", 
                       help="Output CSV path")
    parser.add_argument("--windows", type=int, nargs="+", default=[5, 10, 30],
                       help="Window sizes for rolling statistics")
    
    args = parser.parse_args()
    
    build_features(
        input_path=args.input,
        output_path=args.output,
        rolling_windows=args.windows
    )
EOF

# Make the script executable
chmod +x src/features/build_features.py
```

### Step 4: Run the Feature Pipeline and Version Output

```bash
# Build features from our raw data
python src/features/build_features.py \
    --input data/raw/sensor_data_48h.csv \
    --output data/processed/features_48h.csv

# Check the output
head -n 3 data/processed/features_48h.csv
wc -l data/processed/features_48h.csv

# Version the processed features with DVC
dvc add data/processed/features_48h.csv

# Commit to Git
git add src/features/build_features.py data/processed/features_48h.csv.dvc
git commit -m "Add feature engineering pipeline and processed features"
```

### Step 5: Create a DVC Pipeline

DVC pipelines allow you to define dependencies between your data and processing steps:

```bash
# Create a DVC pipeline file
cat > dvc.yaml << 'EOF'
# DVC pipeline for data processing
stages:
  generate_raw_data:
    cmd: python src/data/generate_sensor_data.py --hours 48 --output data/raw/sensor_data_48h.csv
    deps:
      - src/data/generate_sensor_data.py
    outs:
      - data/raw/sensor_data_48h.csv
    
  build_features:
    cmd: python src/features/build_features.py --input data/raw/sensor_data_48h.csv --output data/processed/features_48h.csv
    deps:
      - src/features/build_features.py
      - data/raw/sensor_data_48h.csv
    outs:
      - data/processed/features_48h.csv
EOF

# Run the entire pipeline
dvc repro

# This should output something like:
# Stage 'generate_raw_data' unchanged
# Stage 'build_features' unchanged
# Data and pipelines are up to date.
```

### Step 6: Test Pipeline Reproducibility

Let's test that our pipeline is truly reproducible:

```bash
# First, commit the DVC pipeline
git add dvc.yaml
git commit -m "Add DVC pipeline for data processing"

# Now simulate a fresh environment
# (DO NOT run this in production - just for testing)
mkdir -p /tmp/test_clone
cp -r . /tmp/test_clone/
cd /tmp/test_clone

# Remove the raw data file
rm data/raw/sensor_data_48h.csv

# Check DVC status
dvc status

# This should show that 'data/raw/sensor_data_48h.csv' is missing

# Restore everything
dvc pull

# Check that files are restored
ls -la data/raw/ data/processed/

# Run the pipeline (should do nothing since everything is up to date)
dvc repro

# Clean up
cd - && rm -rf /tmp/test_clone
```

### Step 7: Create a More Complex Dataset

Let's generate a larger dataset with different parameters:

```bash
# Generate 168 hours (1 week) of data
python src/data/generate_sensor_data.py \
    --hours 168 \
    --sampling_rate 30 \
    --anomaly_rate 0.03 \
    --output data/raw/sensor_data_168h.csv

# Add the new dataset to DVC
dvc add data/raw/sensor_data_168h.csv

# Build features from the new dataset
python src/features/build_features.py \
    --input data/raw/sensor_data_168h.csv \
    --output data/processed/features_168h.csv \
    --windows 5 10 30 60 120

# Add the new features to DVC
dvc add data/processed/features_168h.csv

# Update the DVC pipeline to handle both datasets
cat > dvc.yaml << 'EOF'
stages:
  generate_raw_data_48h:
    cmd: python src/data/generate_sensor_data.py --hours 48 --output data/raw/sensor_data_48h.csv
    deps:
      - src/data/generate_sensor_data.py
    outs:
      - data/raw/sensor_data_48h.csv
  
  generate_raw_data_168h:
    cmd: python src/data/generate_sensor_data.py --hours 168 --sampling_rate 30 --anomaly_rate 0.03 --output data/raw/sensor_data_168h.csv
    deps:
      - src/data/generate_sensor_data.py
    outs:
      - data/raw/sensor_data_168h.csv
  
  build_features_48h:
    cmd: python src/features/build_features.py --input data/raw/sensor_data_48h.csv --output data/processed/features_48h.csv
    deps:
      - src/features/build_features.py
      - data/raw/sensor_data_48h.csv
    outs:
      - data/processed/features_48h.csv
  
  build_features_168h:
    cmd: python src/features/build_features.py --input data/raw/sensor_data_168h.csv --output data/processed/features_168h.csv --windows 5 10 30 60 120
    deps:
      - src/features/build_features.py
      - data/raw/sensor_data_168h.csv
    outs:
      - data/processed/features_168h.csv
EOF

# Commit everything
git add dvc.yaml data/raw/*.dvc data/processed/*.dvc
git commit -m "Add 168h dataset and update DVC pipeline"
```

## The Verification: Testing Our Data Versioning System

### Verification 1: Check All DVC-Tracked Files

```bash
# List all files tracked by DVC
dvc list --all

# Expected output should show all our datasets:
# data/raw/sensor_data_48h.csv
# data/raw/sensor_data_168h.csv  
# data/processed/features_48h.csv
# data/processed/features_168h.csv
```

### Verification 2: Verify Pipeline Dependencies

```bash
# Show the pipeline graph
dvc dag

# Expected output shows the dependency tree:
# +----------------+      
# | generate_raw_* |      
# +----------------+      
#         *            
#         *            
# +----------------+      
# | build_features |      
# +----------------+      
```

### Verification 3: Test Specific Version Checkout

```bash
# Checkout a specific version of the 48h dataset
git checkout HEAD~2  # Go back 2 commits
dvc checkout data/raw/sensor_data_48h.csv

# This should restore the older version
head -n 3 data/raw/sensor_data_48h.csv

# Return to the latest version
git checkout main
dvc checkout data/raw/sensor_data_48h.csv
```

### Verification 4: Compare Dataset Versions

```bash
# Compare the 48h and 168h datasets
python -c "
import pandas as pd
df_48h = pd.read_csv('data/processed/features_48h.csv')
df_168h = pd.read_csv('data/processed/features_168h.csv')
print(f'48h dataset: {len(df_48h):,} rows, {len(df_48h.columns)} columns')
print(f'168h dataset: {len(df_168h):,} rows, {len(df_168h.columns)} columns')
print(f'Column overlap: {set(df_48h.columns).intersection(set(df_168h.columns))}')
"
```

### Verification 5: Test Pipeline Re-execution

```bash
# Force a pipeline re-run
dvc repro --single-item build_features_48h

# This should show that the feature building is up to date

# Now modify the feature building script
echo "# New comment" >> src/features/build_features.py

# Check the status again
dvc status

# This should show that build_features_48h and build_features_168h are changed
```

## Advanced DVC Features

### Data Metrics

```bash
# Calculate and track data metrics
cat > metrics.yaml << 'EOF'
# Define metrics to track
data:
  raw:
    sensor_data_48h:
      rows: 2881
      columns: 8
      anomalies: 144
    sensor_data_168h:
      rows: 20161
      columns: 8
      anomalies: 605
  processed:
    features_48h:
      rows: 2881
      columns: 55
    features_168h:
      rows: 20161
      columns: 67
EOF

dvc metrics add metrics.yaml
git add metrics.yaml
git commit -m "Add data metrics tracking"
```

### Data Version Tags

```bash
# Tag important data versions
dvc tag data/raw/sensor_data_48h.csv v1.0.0
dvc tag data/raw/sensor_data_48h.csv v2.0.0 --with-msg "Increased sampling rate"

# List tags
dvc tag list
```

## What We've Accomplished

By completing this part, you have:

1. **Created a realistic dataset** with synthetic sensor data
2. **Built a feature engineering pipeline** that transforms raw data into ML-ready features
3. **Versioned both raw and processed data** with DVC
4. **Created a reproducible DVC pipeline** that defines dependencies between processing steps
5. **Added multiple datasets** (48h and 168h versions)
6. **Implemented data metrics tracking**
7. **Tested data versioning** with checkout and restore operations

## Common DVC Pipeline Commands

| Command | Purpose |
|---------|---------|
| `dvc repro` | Execute the pipeline (only if needed) |
| `dvc status` | Check which pipeline stages have changed |
| `dvc dag` | Visualize the pipeline dependency graph |
| `dvc metrics` | View tracked metrics |
| `dvc plots` | Generate plots from tracked data |
| `dvc diff` | Compare pipeline states across commits |

## Troubleshooting

**Issue:** Pipeline stages show as "changed" after committing
```bash
# Solution: Commit the .dvc.lock file
git add *.dvc.lock
git commit -m "Update DVC lock file"
```

**Issue:** Large data files taking up too much space
```bash
# Solution: Use DVC's cache management
dvc gc --workspace  # Remove files not in current workspace
dvc gc --all-commits  # Remove files not referenced by any commit
```

**Issue:** Slow feature engineering
```bash
# Solution: Use DVC's caching
# The pipeline will only re-run stages where inputs or code have changed
# This is automatic with DVC
```

## Next Steps

You now have a complete data versioning system with DVC! In Part 3, we'll:
- Set up remote storage (AWS S3 or GCS)
- Configure credentials and security
- Push data to the cloud
- Collaborate with team members

---

*End of Part 2: Versioning Datasets and Feature Stores*
