# Appendix C: Complete API Reference

## The Target: Comprehensive API Documentation for All Components

This appendix provides a complete reference for all APIs, classes, and functions used throughout the series. Use this as a quick reference when developing or debugging your MLOps pipeline.

## The Concept: API Encyclopedia

Think of this like a technical manual for all the tools in your workshop:
- **Each tool** has a specific purpose
- **Each function** has precise inputs and outputs
- **Each class** has clear properties and methods
- **Each error** has known causes and solutions

---

## 1. MLflow API Reference

### Tracking API

```python
import mlflow

# === Core Tracking Functions ===

mlflow.set_tracking_uri(uri: str) -> None
"""
Set the tracking server URI.

Args:
    uri: Tracking server URI (e.g., "http://localhost:5000", "file:./mlruns")
"""

mlflow.get_tracking_uri() -> str
"""
Get the current tracking URI.
"""

mlflow.create_experiment(
    name: str,
    artifact_location: Optional[str] = None,
    tags: Optional[Dict[str, str]] = None
) -> str
"""
Create a new experiment.

Args:
    name: Experiment name
    artifact_location: Location for artifacts (default: tracking server default)
    tags: Tags for the experiment

Returns:
    Experiment ID
"""

mlflow.set_experiment(experiment_name: str) -> Experiment
"""
Set the active experiment.

Args:
    experiment_name: Name of the experiment

Returns:
    Experiment object
"""

mlflow.get_experiment(experiment_id: str) -> Experiment
"""
Get an experiment by ID.

Args:
    experiment_id: Experiment ID

Returns:
    Experiment object
```

### Run Management

```python
# === Run Management ===

mlflow.start_run(
    run_id: Optional[str] = None,
    experiment_id: Optional[str] = None,
    run_name: Optional[str] = None,
    nested: bool = False,
    tags: Optional[Dict[str, str]] = None
) -> ActiveRun
"""
Start a new run.

Args:
    run_id: Run ID (for resuming)
    experiment_id: Experiment ID (default: current)
    run_name: Name of the run
    nested: Whether this is a nested run
    tags: Tags for the run

Returns:
    ActiveRun context manager
"""

mlflow.end_run(status: str = "FINISHED") -> None
"""
End the current run.

Args:
    status: Run status ("FINISHED", "FAILED", "KILLED")
"""

mlflow.active_run() -> Optional[Run]
"""
Get the current active run.
"""

mlflow.search_runs(
    experiment_ids: Optional[List[str]] = None,
    filter_string: Optional[str] = None,
    run_view_type: int = 1,
    max_results: int = 1000,
    order_by: List[str] = ["start_time DESC"]
) -> pd.DataFrame
"""
Search for runs.

Args:
    experiment_ids: List of experiment IDs
    filter_string: SQL-like filter string
    run_view_type: 1=ACTIVE, 2=DELETED, 3=ALL
    max_results: Maximum number of results
    order_by: Sort order

Returns:
    DataFrame with run information
"""

# === Logging Functions ===

mlflow.log_param(key: str, value: Any) -> None
"""
Log a parameter to the current run.

Args:
    key: Parameter name
    value: Parameter value (will be converted to string)
"""

mlflow.log_params(params: Dict[str, Any]) -> None
"""
Log multiple parameters.

Args:
    params: Dictionary of parameters
"""

mlflow.log_metric(
    key: str,
    value: float,
    step: Optional[int] = None,
    timestamp: Optional[int] = None
) -> None
"""
Log a metric to the current run.

Args:
    key: Metric name
    value: Metric value
    step: Training step (for iterative metrics)
    timestamp: Unix timestamp
"""

mlflow.log_metrics(metrics: Dict[str, float], step: Optional[int] = None) -> None
"""
Log multiple metrics.

Args:
    metrics: Dictionary of metrics
    step: Training step
"""

mlflow.set_tag(key: str, value: Any) -> None
"""
Set a tag on the current run.

Args:
    key: Tag name
    value: Tag value
"""

mlflow.set_tags(tags: Dict[str, Any]) -> None
"""
Set multiple tags.

Args:
    tags: Dictionary of tags
"""

# === Artifact Logging ===

mlflow.log_artifact(local_path: str, artifact_path: Optional[str] = None) -> None
"""
Log a single artifact.

Args:
    local_path: Path to local file
    artifact_path: Path within artifact directory
"""

mlflow.log_artifacts(local_dir: str, artifact_path: Optional[str] = None) -> None
"""
Log all artifacts in a directory.

Args:
    local_dir: Path to local directory
    artifact_path: Path within artifact directory
"""

mlflow.log_text(text: str, artifact_file: str) -> None
"""
Log text as an artifact.

Args:
    text: Text content
    artifact_file: Artifact file name
"""

mlflow.log_dict(dictionary: Dict, artifact_file: str) -> None
"""
Log a dictionary as JSON.

Args:
    dictionary: Dictionary to log
    artifact_file: Artifact file name
"""

mlflow.log_image(image: Any, artifact_file: str) -> None
"""
Log an image.

Args:
    image: Image object (PIL, numpy, etc.)
    artifact_file: Artifact file name
"""

mlflow.log_figure(figure: Any, artifact_file: str) -> None
"""
Log a figure (matplotlib, plotly, etc.).

Args:
    figure: Figure object
    artifact_file: Artifact file name
"""
```

### Model Logging

```python
# === Model Logging ===

mlflow.sklearn.log_model(
    sk_model: Any,
    artifact_path: str,
    registered_model_name: Optional[str] = None,
    conda_env: Optional[Dict] = None,
    code_paths: Optional[List[str]] = None,
    **kwargs
) -> ModelInfo
"""
Log a scikit-learn model.

Args:
    sk_model: Trained sklearn model
    artifact_path: Path for model artifacts
    registered_model_name: Name for model registry
    conda_env: Conda environment specification
    code_paths: Paths to code files to include
"""

mlflow.pytorch.log_model(
    pytorch_model: Any,
    artifact_path: str,
    registered_model_name: Optional[str] = None,
    conda_env: Optional[Dict] = None,
    code_paths: Optional[List[str]] = None,
    **kwargs
) -> ModelInfo
"""
Log a PyTorch model.
"""

mlflow.tensorflow.log_model(
    tf_model: Any,
    artifact_path: str,
    registered_model_name: Optional[str] = None,
    conda_env: Optional[Dict] = None,
    code_paths: Optional[List[str]] = None,
    **kwargs
) -> ModelInfo
"""
Log a TensorFlow model.
"""

mlflow.xgboost.log_model(
    xgb_model: Any,
    artifact_path: str,
    registered_model_name: Optional[str] = None,
    conda_env: Optional[Dict] = None,
    code_paths: Optional[List[str]] = None,
    **kwargs
) -> ModelInfo
"""
Log an XGBoost model.
```

### Model Registry API

```python
from mlflow.tracking import MlflowClient

# === Client Initialization ===

client = MlflowClient(tracking_uri: Optional[str] = None)
"""
Create an MLflow client.

Args:
    tracking_uri: Tracking server URI
"""

# === Registered Model Management ===

client.create_registered_model(
    name: str,
    tags: Optional[Dict[str, str]] = None,
    description: Optional[str] = None
) -> RegisteredModel
"""
Create a new registered model.

Args:
    name: Model name
    tags: Tags for the model
    description: Model description

Returns:
    RegisteredModel object
"""

client.search_registered_models(
    filter_string: Optional[str] = None,
    max_results: int = 100
) -> List[RegisteredModel]
"""
Search for registered models.

Args:
    filter_string: Filter string
    max_results: Maximum results

Returns:
    List of RegisteredModel objects
```

### Model Version Management

```python
# === Model Version Management ===

client.create_model_version(
    name: str,
    source: str,
    run_id: Optional[str] = None,
    tags: Optional[Dict[str, str]] = None,
    description: Optional[str] = None
) -> ModelVersion
"""
Create a new model version.

Args:
    name: Model name
    source: Source path (e.g., "runs:/<run_id>/model")
    run_id: Source run ID
    tags: Tags for the version
    description: Version description

Returns:
    ModelVersion object
"""

client.transition_model_version_stage(
    name: str,
    version: int,
    stage: str,
    archive_existing_versions: bool = False
) -> ModelVersion
"""
Transition a model version to a new stage.

Args:
    name: Model name
    version: Version number
    stage: Target stage ("Staging", "Production", "Archived")
    archive_existing_versions: Archive other versions in this stage

Returns:
    ModelVersion object
"""

client.get_latest_versions(
    name: str,
    stages: Optional[List[str]] = None
) -> List[ModelVersion]
"""
Get latest versions of a model.

Args:
    name: Model name
    stages: Filter by stages

Returns:
    List of ModelVersion objects
"""

client.set_model_version_tag(
    name: str,
    version: int,
    key: str,
    value: str
) -> None
"""
Set a tag on a model version.

Args:
    name: Model name
    version: Version number
    key: Tag key
    value: Tag value
"""

client.update_model_version(
    name: str,
    version: int,
    description: Optional[str] = None
) -> ModelVersion
"""
Update a model version.

Args:
    name: Model name
    version: Version number
    description: New description

Returns:
    ModelVersion object
```

---

## 2. DVC API Reference

### Core DVC Operations

```python
import dvc.api
import dvc.repo

# === Repository Operations ===

repo = dvc.repo.Repo(path: str = ".")
"""
Create a DVC repository object.

Args:
    path: Path to repository
"""

repo.add(targets: List[str], **kwargs) -> None
"""
Add files to DVC tracking.

Args:
    targets: List of file paths to add
"""

repo.status(targets: Optional[List[str]] = None, **kwargs) -> Dict[str, Dict]
"""
Get status of tracked files.

Args:
    targets: Specific files to check

Returns:
    Dictionary with status information
"""

repo.push(targets: Optional[List[str]] = None, **kwargs) -> None
"""
Push data to remote storage.

Args:
    targets: Specific files to push
"""

repo.pull(targets: Optional[List[str]] = None, **kwargs) -> None
"""
Pull data from remote storage.
"""

repo.checkout(targets: Optional[List[str]] = None, **kwargs) -> None
"""
Checkout data from cache.
"""

# === Pipeline Operations ===

repo.reproduce(
    targets: Optional[List[str]] = None,
    single_item: bool = False,
    force: bool = False,
    dry: bool = False
) -> List[dict]
"""
Reproduce pipeline stages.

Args:
    targets: Specific stages to reproduce
    single_item: Run only specific stage
    force: Force reproduction
    dry: Dry run only

Returns:
    List of stage results
"""

repo.stages() -> List[Stage]
"""
Get all pipeline stages.

Returns:
    List of Stage objects
```

### Data Management

```python
# === Data Management ===

dvc.api.get_url(path: str, repo: str = ".") -> str
"""
Get the cache URL for a tracked file.

Args:
    path: Path to tracked file
    repo: Repository path

Returns:
    Cache URL
"""

dvc.api.open(path: str, repo: str = ".", rev: Optional[str] = None, **kwargs)
"""
Open a tracked file.

Args:
    path: Path to tracked file
    repo: Repository path
    rev: Git revision/tag

Returns:
    File-like object
"""

dvc.api.read(path: str, repo: str = ".", rev: Optional[str] = None) -> bytes
"""
Read a tracked file.

Args:
    path: Path to tracked file
    repo: Repository path
    rev: Git revision/tag

Returns:
    File contents as bytes
```

### Remote Management

```python
# === Remote Management ===

repo.remote.add(name: str, url: str, default: bool = False) -> None
"""
Add a remote storage.

Args:
    name: Remote name
    url: Remote URL
    default: Set as default
"""

repo.remote.remove(name: str) -> None
"""
Remove a remote storage.

Args:
    name: Remote name
"""

repo.remote.default() -> str
"""
Get default remote name.

Returns:
    Default remote name
"""

repo.remote.list() -> List[str]
"""
List all remotes.

Returns:
    List of remote names
"""

repo.remote.modify(
    name: str,
    option: str,
    value: str,
    local: bool = False
) -> None
"""
Modify remote configuration.

Args:
    name: Remote name
    option: Configuration option
    value: Option value
    local: Modify local config only
"""
```

---

## 3. Dagster API Reference

### Core Decorators

```python
from dagster import op, asset, job, schedule, sensor

# === Op Decorator ===

@op(
    name: Optional[str] = None,
    description: Optional[str] = None,
    ins: Optional[Dict[str, In]] = None,
    out: Optional[Dict[str, Out]] = None,
    required_resource_keys: Optional[Set[str]] = None,
    config_schema: Optional[Any] = None,
    tags: Optional[Dict[str, Any]] = None,
    retry_policy: Optional[RetryPolicy] = None
)
def op_function(context: OpExecutionContext, *args, **kwargs):
    """
    Define an operation (op).

    Parameters:
        name: Op name (defaults to function name)
        description: Op description
        ins: Input definitions
        out: Output definitions
        required_resource_keys: Required resources
        config_schema: Configuration schema
        tags: Tags for the op
        retry_policy: Retry policy

    Returns:
        Op definition
    """

# === Asset Decorator ===

@asset(
    name: Optional[str] = None,
    description: Optional[str] = None,
    config_schema: Optional[Any] = None,
    required_resource_keys: Optional[Set[str]] = None,
    tags: Optional[Dict[str, Any]] = None,
    compute_kind: Optional[str] = None,
    group_name: Optional[str] = None
)
def asset_function(context: AssetExecutionContext):
    """
    Define an asset.

    Parameters:
        name: Asset name
        description: Asset description
        config_schema: Configuration schema
        required_resource_keys: Required resources
        tags: Tags for the asset
        compute_kind: Compute kind (e.g., "pandas", "spark")
        group_name: Asset group name
    """

# === Job Decorator ===

@job(
    name: Optional[str] = None,
    description: Optional[str] = None,
    resource_defs: Optional[Dict[str, Resource]] = None,
    config: Optional[Any] = None,
    tags: Optional[Dict[str, Any]] = None,
    hooks: Optional[Dict[str, Hook]] = None
)
def job_function():
    """
    Define a job.

    Parameters:
        name: Job name
        description: Job description
        resource_defs: Resource definitions
        config: Configuration
        tags: Tags for the job
        hooks: Hooks for the job
    """

# === Schedule Decorator ===

@schedule(
    job: JobDefinition,
    cron_schedule: str,
    execution_timezone: Optional[str] = None,
    name: Optional[str] = None,
    description: Optional[str] = None,
    tags: Optional[Dict[str, Any]] = None
)
def schedule_function(context: ScheduleExecutionContext):
    """
    Define a schedule.

    Parameters:
        job: Job to run
        cron_schedule: Cron expression
        execution_timezone: Timezone
        name: Schedule name
        description: Schedule description
        tags: Tags for the schedule
    """

# === Sensor Decorator ===

@sensor(
    job: JobDefinition,
    minimum_interval_seconds: Optional[int] = None,
    name: Optional[str] = None,
    description: Optional[str] = None,
    tags: Optional[Dict[str, Any]] = None
)
def sensor_function(context: SensorExecutionContext):
    """
    Define a sensor.

    Parameters:
        job: Job to run
        minimum_interval_seconds: Minimum interval between runs
        name: Sensor name
        description: Sensor description
        tags: Tags for the sensor
    """
```

### Context Objects

```python
# === Op Context ===

class OpExecutionContext:
    """Context for op execution."""
    
    @property
    def run_id(self) -> str:
        """Get the run ID."""
    
    @property
    def job_name(self) -> str:
        """Get the job name."""
    
    @property
    def op_name(self) -> str:
        """Get the op name."""
    
    @property
    def op_retry_count(self) -> int:
        """Get the retry count."""
    
    @property
    def resources(self) -> ResourceManager:
        """Get resource manager."""
    
    @property
    def log(self) -> Logger:
        """Get logger."""
    
    @property
    def run_config(self) -> Dict[str, Any]:
        """Get run configuration."""
    
    def add_metadata(self, metadata: Dict[str, Any]) -> None:
        """Add metadata to the op."""
    
    def yield_event(self, event: DagsterEvent) -> None:
        """Yield a Dagster event."""

# === Asset Context ===

class AssetExecutionContext:
    """Context for asset execution."""
    
    @property
    def asset_key(self) -> AssetKey:
        """Get the asset key."""
    
    @property
    def partition_key(self) -> Optional[str]:
        """Get the partition key."""
    
    @property
    def run_id(self) -> str:
        """Get the run ID."""
    
    @property
    def resources(self) -> ResourceManager:
        """Get resource manager."""
    
    @property
    def log(self) -> Logger:
        """Get logger."""
    
    def add_metadata(self, metadata: Dict[str, Any]) -> None:
        """Add metadata to the asset."""
```

### Resource Classes

```python
from dagster import resource, Resource, IOManager, OutputContext, InputContext

# === Resource Decorator ===

@resource(
    config_schema: Optional[Any] = None,
    description: Optional[str] = None,
    required_resource_keys: Optional[Set[str]] = None
)
def resource_function(context: InitResourceContext):
    """
    Define a resource.

    Parameters:
        config_schema: Configuration schema
        description: Resource description
        required_resource_keys: Required resources

    Returns:
        Resource instance
    """

# === Resource Class ===

class Resource:
    """Base resource class."""
    
    def __init__(self, **kwargs):
        """Initialize resource."""
    
    def get_resource(self) -> Any:
        """Get the resource instance."""

# === I/O Manager Class ===

class IOManager:
    """Base I/O manager class."""
    
    def handle_output(self, context: OutputContext, obj: Any) -> None:
        """Handle output."""
        raise NotImplementedError()
    
    def load_input(self, context: InputContext) -> Any:
        """Load input."""
        raise NotImplementedError()
```

### Error Handling

```python
from dagster import Failure, RetryPolicy, HookContext, hook

# === Failure Class ===

class Failure(Exception):
    """Dagster failure exception."""
    
    def __init__(
        self,
        message: str,
        metadata: Optional[Dict[str, Any]] = None,
        cause: Optional[Exception] = None
    ):
        """
        Create a failure.

        Args:
            message: Error message
            metadata: Error metadata
            cause: Original exception
        """

# === Retry Policy ===

class RetryPolicy:
    """Retry policy for ops."""
    
    def __init__(
        self,
        max_retries: int = 3,
        delay: float = 5.0,
        backoff: float = 2.0,
        jitter: float = 0.1
    ):
        """
        Create a retry policy.

        Args:
            max_retries: Maximum number of retries
            delay: Initial delay in seconds
            backoff: Backoff multiplier
            jitter: Random jitter factor
        """

# === Hook Decorator ===

@hook(required_resource_keys: Optional[Set[str]] = None)
def hook_function(context: HookContext, **kwargs):
    """
    Define a hook.

    Parameters:
        required_resource_keys: Required resources
    """
```

---

## 4. Python Standard Library API Reference

### Path Operations

```python
from pathlib import Path

# === Path Class ===

Path.cwd() -> Path
"""
Get current working directory.
"""

Path.home() -> Path
"""
Get user home directory.
"""

Path.exists() -> bool
"""
Check if path exists.
"""

Path.mkdir(mode: int = 0o777, parents: bool = False, exist_ok: bool = False) -> None
"""
Create directory.

Args:
    mode: Directory permissions
    parents: Create parent directories
    exist_ok: Don't raise if exists
"""

Path.glob(pattern: str) -> Iterator[Path]
"""
Glob for files matching pattern.
"""

Path.rglob(pattern: str) -> Iterator[Path]
"""
Recursively glob for files matching pattern.
"""

Path.read_text(encoding: Optional[str] = None) -> str
"""
Read file as text.
"""

Path.write_text(data: str, encoding: Optional[str] = None) -> int
"""
Write text to file.
"""

Path.read_bytes() -> bytes
"""
Read file as bytes.
"""

Path.write_bytes(data: bytes) -> int
"""
Write bytes to file.
"""

Path.rename(target: Union[str, Path]) -> Path
"""
Rename file/directory.
"""

Path.stat() -> os.stat_result
"""
Get file statistics.
"""

Path.absolute() -> Path
"""
Get absolute path.
"""

Path.resolve() -> Path
"""
Resolve path (resolve symlinks).
"""

Path.parent -> Path
"""
Get parent directory.
"""

Path.name -> str
"""
Get file/directory name.
"""

Path.stem -> str
"""
Get filename without extension.
"""

Path.suffix -> str
"""
Get file extension.
"""

Path.suffixes -> List[str]
"""
Get all file extensions.
"""

Path.is_file() -> bool
"""
Check if path is a file.
"""

Path.is_dir() -> bool
"""
Check if path is a directory.
"""

Path.unlink(missing_ok: bool = False) -> None
"""
Delete file.

Args:
    missing_ok: Don't raise if file missing
"""

Path.rmdir() -> None
"""
Remove empty directory.
"""

Path.iterdir() -> Iterator[Path]
"""
Iterate over directory contents.
"""

### File Operations

```python
import json

# === JSON ===

json.dump(obj: Any, fp: IO, *, indent: Optional[int] = None) -> None
"""
Write JSON to file.

Args:
    obj: Object to serialize
    fp: File-like object
    indent: Indentation level
"""

json.dumps(obj: Any, *, indent: Optional[int] = None) -> str
"""
Serialize object to JSON string.

Args:
    obj: Object to serialize
    indent: Indentation level

Returns:
    JSON string
"""

json.load(fp: IO) -> Any
"""
Load JSON from file.

Args:
    fp: File-like object

Returns:
    Deserialized object
"""

json.loads(s: str) -> Any
"""
Load JSON from string.

Args:
    s: JSON string

Returns:
    Deserialized object
"""

# === YAML ===

import yaml

yaml.dump(data: Any, stream: IO, default_flow_style: bool = False) -> None
"""
Write YAML to file.

Args:
    data: Data to serialize
    stream: File-like object
    default_flow_style: Use flow style
"""

yaml.safe_load(stream: IO) -> Any
"""
Load YAML from file.

Args:
    stream: File-like object

Returns:
    Deserialized object
"""

yaml.safe_loads(s: str) -> Any
"""
Load YAML from string.

Args:
    s: YAML string

Returns:
    Deserialized object
"""

# === Pickle ===

import pickle

pickle.dump(obj: Any, file: IO, protocol: int = pickle.HIGHEST_PROTOCOL) -> None
"""
Write pickle to file.

Args:
    obj: Object to serialize
    file: File-like object
    protocol: Pickle protocol
"""

pickle.load(file: IO) -> Any
"""
Load pickle from file.

Args:
    file: File-like object

Returns:
    Deserialized object
"""

pickle.dumps(obj: Any, protocol: int = pickle.HIGHEST_PROTOCOL) -> bytes
"""
Serialize object to bytes.

Args:
    obj: Object to serialize
    protocol: Pickle protocol

Returns:
    Serialized bytes
"""

pickle.loads(data: bytes) -> Any
"""
Load pickle from bytes.

Args:
    data: Serialized bytes

Returns:
    Deserialized object
"""
```

### Data Processing

```python
import pandas as pd
import numpy as np

# === Pandas DataFrame ===

pd.read_csv(filepath_or_buffer: Union[str, Path, IO], **kwargs) -> pd.DataFrame
"""
Read CSV file to DataFrame.

Args:
    filepath_or_buffer: File path or buffer
    **kwargs: Additional pandas options

Returns:
    DataFrame
"""

df.to_csv(path_or_buf: Union[str, Path, IO], **kwargs) -> None
"""
Write DataFrame to CSV.

Args:
    path_or_buf: File path or buffer
    **kwargs: Additional pandas options
"""

df.to_parquet(path: Union[str, Path], **kwargs) -> None
"""
Write DataFrame to Parquet.

Args:
    path: File path
    **kwargs: Additional pandas options
"""

df.groupby(by: Union[str, List[str]]) -> pd.DataFrameGroupBy
"""
Group DataFrame by columns.

Args:
    by: Column(s) to group by

Returns:
    GroupBy object
"""

df.merge(right: pd.DataFrame, **kwargs) -> pd.DataFrame
"""
Merge DataFrames.

Args:
    right: Other DataFrame
    **kwargs: Merge options

Returns:
    Merged DataFrame
"""

df.isnull() -> pd.DataFrame
"""
Check for null values.

Returns:
    Boolean DataFrame
"""

df.fillna(value: Any) -> pd.DataFrame
"""
Fill null values.

Args:
    value: Value to fill

Returns:
    Filled DataFrame
"""

# === NumPy ===

np.array(object, dtype=None) -> np.ndarray
"""
Create NumPy array.

Args:
    object: Input data
    dtype: Data type

Returns:
    NumPy array
"""

np.random.normal(loc: float = 0.0, scale: float = 1.0, size: Optional[int] = None) -> np.ndarray
"""
Generate normal distribution.

Args:
    loc: Mean
    scale: Standard deviation
    size: Output shape

Returns:
    Random values
"""

np.random.choice(a: int, size: Optional[int] = None) -> np.ndarray
"""
Random choice from array.

Args:
    a: Array or range
    size: Output shape

Returns:
    Random values
"""

np.mean(a: np.ndarray, axis: Optional[int] = None) -> float
"""
Calculate mean.

Args:
    a: Array
    axis: Axis to calculate along

Returns:
    Mean value
"""

np.std(a: np.ndarray, axis: Optional[int] = None) -> float
"""
Calculate standard deviation.

Args:
    a: Array
    axis: Axis to calculate along

Returns:
    Standard deviation
"""
```

---

## 5. Scikit-learn API Reference

### Model Classes

```python
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC

# === Random Forest ===

RandomForestClassifier(
    n_estimators: int = 100,
    max_depth: Optional[int] = None,
    min_samples_split: int = 2,
    min_samples_leaf: int = 1,
    max_features: Union[str, int] = "sqrt",
    random_state: Optional[int] = None,
    n_jobs: int = -1,
    class_weight: Optional[dict] = None
) -> RandomForestClassifier
"""
Random Forest classifier.

Parameters:
    n_estimators: Number of trees
    max_depth: Maximum tree depth
    min_samples_split: Minimum samples to split
    min_samples_leaf: Minimum samples in leaf
    max_features: Number of features to consider
    random_state: Random seed
    n_jobs: Number of parallel jobs
    class_weight: Class weights
"""

# === Gradient Boosting ===

GradientBoostingClassifier(
    n_estimators: int = 100,
    learning_rate: float = 0.1,
    max_depth: int = 3,
    min_samples_split: int = 2,
    min_samples_leaf: int = 1,
    random_state: Optional[int] = None,
    validation_fraction: float = 0.1
) -> GradientBoostingClassifier
"""
Gradient Boosting classifier.

Parameters:
    n_estimators: Number of boosting stages
    learning_rate: Learning rate
    max_depth: Maximum tree depth
    min_samples_split: Minimum samples to split
    min_samples_leaf: Minimum samples in leaf
    random_state: Random seed
    validation_fraction: Validation fraction
"""

# === Logistic Regression ===

LogisticRegression(
    penalty: str = "l2",
    C: float = 1.0,
    max_iter: int = 100,
    random_state: Optional[int] = None,
    class_weight: Optional[dict] = None
) -> LogisticRegression
"""
Logistic Regression classifier.

Parameters:
    penalty: Regularization penalty
    C: Inverse regularization strength
    max_iter: Maximum iterations
    random_state: Random seed
    class_weight: Class weights
"""

# === Support Vector Machine ===

SVC(
    C: float = 1.0,
    kernel: str = "rbf",
    gamma: Union[str, float] = "scale",
    probability: bool = False,
    random_state: Optional[int] = None
) -> SVC
"""
Support Vector Classifier.

Parameters:
    C: Regularization parameter
    kernel: Kernel type
    gamma: Kernel coefficient
    probability: Enable probability estimates
    random_state: Random seed
"""

### Training and Evaluation

```python
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score,
    f1_score, roc_auc_score, confusion_matrix,
    classification_report
)

# === Data Splitting ===

X_train, X_test, y_train, y_test = train_test_split(
    X: np.ndarray,
    y: np.ndarray,
    test_size: float = 0.2,
    random_state: Optional[int] = None,
    stratify: Optional[np.ndarray] = None
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]
"""
Split data into train and test sets.

Args:
    X: Feature data
    y: Target data
    test_size: Test set proportion
    random_state: Random seed
    stratify: Stratification labels

Returns:
    X_train, X_test, y_train, y_test
"""

# === Cross-Validation ===

scores = cross_val_score(
    estimator: Any,
    X: np.ndarray,
    y: np.ndarray,
    cv: int = 5,
    scoring: Optional[str] = None,
    n_jobs: int = -1
) -> np.ndarray
"""
Perform cross-validation.

Args:
    estimator: Model instance
    X: Feature data
    y: Target data
    cv: Number of folds
    scoring: Scoring metric
    n_jobs: Number of parallel jobs

Returns:
    Cross-validation scores
"""

# === Evaluation Metrics ===

accuracy_score(y_true: np.ndarray, y_pred: np.ndarray) -> float
"""
Calculate accuracy.

Args:
    y_true: True labels
    y_pred: Predicted labels

Returns:
    Accuracy score
"""

precision_score(y_true: np.ndarray, y_pred: np.ndarray, average: str = "binary") -> float
"""
Calculate precision.

Args:
    y_true: True labels
    y_pred: Predicted labels
    average: Averaging method

Returns:
    Precision score
"""

recall_score(y_true: np.ndarray, y_pred: np.ndarray, average: str = "binary") -> float
"""
Calculate recall.

Args:
    y_true: True labels
    y_pred: Predicted labels
    average: Averaging method

Returns:
    Recall score
"""

f1_score(y_true: np.ndarray, y_pred: np.ndarray, average: str = "binary") -> float
"""
Calculate F1 score.

Args:
    y_true: True labels
    y_pred: Predicted labels
    average: Averaging method

Returns:
    F1 score
"""

roc_auc_score(y_true: np.ndarray, y_score: np.ndarray, average: str = "macro") -> float
"""
Calculate ROC-AUC score.

Args:
    y_true: True labels
    y_score: Prediction scores
    average: Averaging method

Returns:
    ROC-AUC score
"""

confusion_matrix(y_true: np.ndarray, y_pred: np.ndarray) -> np.ndarray
"""
Calculate confusion matrix.

Args:
    y_true: True labels
    y_pred: Predicted labels

Returns:
    Confusion matrix
"""

classification_report(y_true: np.ndarray, y_pred: np.ndarray) -> str
"""
Generate classification report.

Args:
    y_true: True labels
    y_pred: Predicted labels

Returns:
    Classification report string
"""
```

### Preprocessing

```python
from sklearn.preprocessing import StandardScaler, MinMaxScaler, LabelEncoder
from sklearn.impute import SimpleImputer

# === StandardScaler ===

scaler = StandardScaler()
"""
StandardScaler for feature standardization.

Methods:
    fit(X): Fit the scaler
    transform(X): Transform features
    fit_transform(X): Fit and transform
"""

scaler.fit(X: np.ndarray) -> StandardScaler
"""
Fit the scaler.

Args:
    X: Feature data

Returns:
    Fitted scaler
"""

X_scaled = scaler.transform(X: np.ndarray) -> np.ndarray
"""
Transform features.

Args:
    X: Feature data

Returns:
    Scaled features
"""

# === MinMaxScaler ===

scaler = MinMaxScaler(feature_range: Tuple[float, float] = (0, 1))
"""
MinMaxScaler for feature scaling.

Parameters:
    feature_range: Range to scale to
"""

# === SimpleImputer ===

imputer = SimpleImputer(strategy: str = "mean", fill_value: Optional[Any] = None)
"""
SimpleImputer for missing values.

Parameters:
    strategy: Imputation strategy ("mean", "median", "most_frequent", "constant")
    fill_value: Value for constant strategy
"""

# === LabelEncoder ===

encoder = LabelEncoder()
"""
LabelEncoder for encoding labels.

Methods:
    fit(y): Fit the encoder
    transform(y): Transform labels
    fit_transform(y): Fit and transform
    inverse_transform(y): Convert back to original labels
"""
```

---

## 6. FastAPI API Reference

### Core Application

```python
from fastapi import FastAPI, HTTPException, Request, Depends
from pydantic import BaseModel

# === FastAPI App ===

app = FastAPI(
    title: str = "ML Model API",
    version: str = "1.0.0",
    description: str = "API for ML predictions",
    docs_url: str = "/docs",
    redoc_url: str = "/redoc"
)
"""
FastAPI application.

Parameters:
    title: API title
    version: API version
    description: API description
    docs_url: URL for Swagger docs
    redoc_url: URL for ReDoc docs
"""

# === Route Decorators ===

@app.get(path: str)
def get_endpoint():
    """GET endpoint."""

@app.post(path: str)
def post_endpoint():
    """POST endpoint."""

@app.put(path: str)
def put_endpoint():
    """PUT endpoint."""

@app.delete(path: str)
def delete_endpoint():
    """DELETE endpoint."""

# === Pydantic Models ===

class PredictionRequest(BaseModel):
    """Request model for predictions."""
    features: List[float]

class PredictionResponse(BaseModel):
    """Response model for predictions."""
    prediction: float
    confidence: float

# === Dependency Injection ===

def get_model():
    """Dependency for model loading."""
    # Load model
    model = load_model()
    return model

@app.post("/predict")
def predict(
    request: PredictionRequest,
    model: Model = Depends(get_model)
) -> PredictionResponse:
    """Make a prediction."""
    # Use model
    prediction = model.predict(request.features)
    return PredictionResponse(
        prediction=float(prediction),
        confidence=0.95
    )
```

---

## 7. Error Codes Reference

### Common Error Codes

```python
"""
HTTP Error Codes:
    200: OK
    201: Created
    400: Bad Request
    401: Unauthorized
    403: Forbidden
    404: Not Found
    409: Conflict
    422: Unprocessable Entity
    500: Internal Server Error
    503: Service Unavailable
"""

"""
MLflow Error Codes:
    INVALID_PARAMETER_VALUE: Invalid parameter
    RESOURCE_ALREADY_EXISTS: Resource already exists
    RESOURCE_DOES_NOT_EXIST: Resource not found
    INTERNAL_ERROR: Internal server error
    INVALID_STATE: Invalid state transition
"""

"""
DVC Error Codes:
    1: General error
    2: Missing dependency
    3: Invalid configuration
    4: Remote connection failed
    5: Data integrity error
    6: Pipeline error
    7: Permission denied
"""

"""
Dagster Error Codes:
    FAILURE: General failure
    OP_FAILURE: Op execution failure
    ASSET_FAILURE: Asset materialization failure
    RECONFIGURATION_FAILURE: Reconfiguration failure
    RESOURCE_INITIALIZATION_FAILURE: Resource init failure
    SCHEDULE_ERROR: Schedule execution error
    SENSOR_ERROR: Sensor execution error
"""
```

---

*End of Appendix C: Complete API Reference*
