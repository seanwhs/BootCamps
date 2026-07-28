# Primer 4: Dagster Architecture and Advanced Patterns

## The Target: Comprehensive Understanding of Dagster Internals and Advanced Usage

This primer provides an in-depth exploration of Dagster's architecture, execution model, and advanced patterns for building robust data pipelines. Understanding these concepts will help you design efficient pipelines, debug issues, and leverage Dagster's full capabilities in production.

## The Concept: Dagster's Execution Model

Think of Dagster like a concert hall's stage management system:
- **Assets** = Musical instruments (the data/artifacts)
- **Ops** = Musicians (the transformations)
- **Jobs** = Concerts (complete performances)
- **Schedules** = Calendar of performances (automated runs)
- **Sensors** = Conductor's ears (reacting to changes)
- **Resources** = Stage equipment (shared services)
- **I/O Managers** = Stagehands (moving instruments)

Everything is designed to be testable, observable, and recoverable.

---

## 1. Dagster Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                      Dagster Architecture                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   User Code (Definitions)                │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │   Assets     │  │    Ops       │  │   Jobs       │  │  │
│  │  │   (Data)     │  │   (Logic)    │  │   (Graphs)   │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Dagster API (gRPC)                     │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │   Execution  │  │   Schedule   │  │   Sensors    │  │  │
│  │  │    Engine    │  │    Manager   │  │   Manager    │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                    │
│                           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Storage Layer                          │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │  Run Storage │  │  Event Log   │  │  Asset Store │  │  │
│  │  │  (PostgreSQL)│  │  (PostgreSQL)│  │  (S3/GCS)    │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Component Interactions

```python
"""
Component interaction flow:
1. User defines Assets/Ops/Jobs in Python
2. Dagster parses definitions into a graph
3. Schedules/Sensors trigger execution
4. Execution engine resolves dependencies
5. Run storage tracks execution state
6. Event log records everything
7. Asset store manages data artifacts
"""

# High-level execution flow
class DagsterExecutionFlow:
    def execute_job(self, job_def):
        # 1. Parse job definition
        graph = self._build_graph(job_def)
        
        # 2. Resolve dependencies
        execution_plan = self._create_execution_plan(graph)
        
        # 3. Execute steps in order
        for step in execution_plan:
            # 4. Check dependencies
            if self._dependencies_ready(step):
                # 5. Execute step
                result = self._execute_step(step)
                
                # 6. Store result
                self._store_result(step, result)
                
                # 7. Log event
                self._log_event(step, result)
            else:
                self._wait_for_dependencies(step)
```

---

## 2. Dagster Data Model

### Core Entities

```python
"""
Dagster Data Model:
- Asset: Data artifact with lineage
- Op: Transformation function
- Job: Graph of Ops to execute
- Schedule: Time-based trigger
- Sensor: Event-based trigger
- Resource: Shared service/connection
- IOManager: Data persistence
"""

# Asset definition
@asset
def my_asset(context: AssetExecutionContext) -> pd.DataFrame:
    """
    Asset: A data artifact in the pipeline.
    - Has a unique key (name)
    - Can depend on other assets
    - Is materialized by ops
    - Has lineage tracking
    """
    return pd.DataFrame({'col': [1, 2, 3]})

# Op definition
@op(
    ins={'input': In(dagster_type=pd.DataFrame)},
    out={'output': Out(dagster_type=pd.DataFrame)}
)
def my_op(context: OpExecutionContext, input: pd.DataFrame) -> pd.DataFrame:
    """
    Op: A transformation function.
    - Has inputs and outputs
    - Isolated unit of work
    - Can have retry policies
    - Can be composed into graphs
    """
    return input * 2

# Job definition
@job
def my_job():
    """
    Job: A complete pipeline.
    - Composed of ops
    - Has execution plan
    - Can be scheduled
    - Has run configuration
    """
    result = my_op(my_asset())
    return result
```

### Metadata and Annotations

```python
from dagster import metadata, MetadataValue

@asset
def model_asset(context):
    """Asset with rich metadata."""
    # Your code here
    
    return Output(
        model,
        metadata={
            "accuracy": MetadataValue.float(0.95),
            "model_type": MetadataValue.text("random_forest"),
            "feature_count": MetadataValue.int(50),
            "metrics": MetadataValue.json({
                'f1': 0.93,
                'precision': 0.94,
                'recall': 0.92
            }),
            "preview": MetadataValue.md("```python\nmodel summary\n```")
        }
    )
```

---

## 3. Execution Engine

### Step-by-Step Execution

```python
"""
Execution Flow:
1. Job submitted to Dagster
2. Graph is analyzed for dependencies
3. Execution plan is generated
4. Steps are scheduled for execution
5. Resources are initialized
6. Each op is executed in order
7. Results are persisted
8. Events are logged
"""

class SimpleExecutionEngine:
    def __init__(self):
        self.steps = []
        self.results = {}
    
    def create_execution_plan(self, job_def):
        """Create execution plan from job definition."""
        # Build dependency graph
        graph = self._build_graph(job_def)
        
        # Topological sort
        plan = self._topological_sort(graph)
        
        return plan
    
    def execute_step(self, step, inputs):
        """Execute a single step."""
        # Get op function
        op_fn = step.op
        
        # Execute with inputs
        result = op_fn(**inputs)
        
        # Store result
        self.results[step.name] = result
        
        return result
    
    def run_job(self, job_def):
        """Execute full job."""
        # Create execution plan
        plan = self.create_execution_plan(job_def)
        
        # Execute steps
        for step in plan:
            # Get inputs from previous steps
            inputs = {}
            for input_name, dep in step.dependencies.items():
                if dep in self.results:
                    inputs[input_name] = self.results[dep]
            
            # Execute
            self.execute_step(step, inputs)
        
        return self.results
```

### Parallel Execution

```python
import concurrent.futures
import asyncio

class ParallelExecutionEngine:
    def __init__(self, max_workers: int = 4):
        self.max_workers = max_workers
        self.results = {}
        self.lock = asyncio.Lock()
    
    async def execute_step_async(self, step, inputs):
        """Execute step asynchronously."""
        # Execute op
        result = step.op(**inputs)
        
        # Store result
        async with self.lock:
            self.results[step.name] = result
        
        return result
    
    async def run_job_async(self, job_def):
        """Execute job with parallel steps."""
        # Create execution plan
        plan = self._create_execution_plan(job_def)
        
        # Build dependency graph
        dependencies = self._build_dependencies(plan)
        
        # Execute in parallel where possible
        with concurrent.futures.ThreadPoolExecutor(
            max_workers=self.max_workers
        ) as executor:
            # Submit all steps
            future_to_step = {}
            for step in plan:
                # Check dependencies
                deps = dependencies[step.name]
                if all(d in self.results for d in deps):
                    inputs = self._get_inputs(step, deps)
                    future = executor.submit(
                        self.execute_step_sync,
                        step, inputs
                    )
                    future_to_step[future] = step
            
            # Collect results
            for future in concurrent.futures.as_completed(future_to_step):
                step = future_to_step[future]
                try:
                    result = future.result()
                    self.results[step.name] = result
                except Exception as e:
                    self._handle_error(step, e)
        
        return self.results
```

---

## 4. Resources and I/O Managers

### Resource Architecture

```python
from dagster import resource, Resource, IOManager, OutputContext, InputContext

# Resource: Shared service/connection
class DatabaseResource(Resource):
    """PostgreSQL database resource."""
    
    def __init__(self, connection_string: str):
        self.connection_string = connection_string
        self._connection = None
    
    def get_connection(self):
        """Get database connection."""
        if self._connection is None:
            import psycopg2
            self._connection = psycopg2.connect(self.connection_string)
        return self._connection
    
    def execute_query(self, query: str):
        """Execute query and return results."""
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(query)
        return cursor.fetchall()
    
    def close(self):
        """Close database connection."""
        if self._connection:
            self._connection.close()
            self._connection = None

# Custom IOManager
class CustomIOManager(IOManager):
    """Custom I/O manager for handling data persistence."""
    
    def __init__(self, base_path: str = "./data"):
        self.base_path = Path(base_path)
        self.base_path.mkdir(parents=True, exist_ok=True)
    
    def handle_output(self, context: OutputContext, obj: Any):
        """Save output to storage."""
        # Determine format from context
        metadata = context.metadata or {}
        format = metadata.get('format', 'parquet')
        
        file_path = self.base_path / f"{context.step_key}.{format}"
        
        if isinstance(obj, pd.DataFrame):
            if format == 'csv':
                obj.to_csv(file_path, index=False)
            elif format == 'parquet':
                obj.to_parquet(file_path, index=False)
            elif format == 'json':
                obj.to_json(file_path, orient='records')
        else:
            # Binary serialization
            import pickle
            with open(file_path, 'wb') as f:
                pickle.dump(obj, f)
        
        context.add_output_metadata({
            "path": str(file_path),
            "format": format,
            "size_bytes": file_path.stat().st_size
        })
    
    def load_input(self, context: InputContext) -> Any:
        """Load input from storage."""
        # Determine format from upstream
        metadata = context.upstream_output.metadata or {}
        format = metadata.get('format', 'parquet')
        
        file_path = self.base_path / f"{context.upstream_output.step_key}.{format}"
        
        if not file_path.exists():
            raise FileNotFoundError(f"Input not found: {file_path}")
        
        if format == 'csv':
            return pd.read_csv(file_path)
        elif format == 'parquet':
            return pd.read_parquet(file_path)
        elif format == 'json':
            return pd.read_json(file_path)
        else:
            import pickle
            with open(file_path, 'rb') as f:
                return pickle.load(f)
```

---

## 5. Asset System

### Asset Lineage

```python
from dagster import asset, multi_asset, AssetKey, materialize

@asset
def raw_data() -> pd.DataFrame:
    """Raw data asset."""
    return pd.DataFrame({'id': [1, 2, 3], 'value': [10, 20, 30]})

@asset
def processed_data(raw_data: pd.DataFrame) -> pd.DataFrame:
    """Processed data asset."""
    return raw_data * 2

@asset(
    ins={'processed': AssetKey('processed_data')}
)
def model_data(processed_data: pd.DataFrame) -> pd.DataFrame:
    """Model-ready data asset."""
    return processed_data / 10

@asset
def feature_store(
    processed_data: pd.DataFrame,
    model_data: pd.DataFrame
) -> pd.DataFrame:
    """Combined feature store."""
    return pd.concat([processed_data, model_data], axis=1)

# Multi-asset (multiple outputs)
@multi_asset(
    outs={
        'train_data': AssetOut(),
        'test_data': AssetOut()
    }
)
def split_data(feature_store: pd.DataFrame) -> dict:
    """Split data into train and test."""
    from sklearn.model_selection import train_test_split
    train, test = train_test_split(feature_store, test_size=0.2)
    return {'train_data': train, 'test_data': test}
```

### Asset Materialization

```python
from dagster import asset, materialize, AssetMaterialization

@asset
def dynamic_asset(context: AssetExecutionContext) -> pd.DataFrame:
    """Asset with dynamic materialization."""
    # Determine what to materialize
    if context.run_config and 'materialize_all' in context.run_config:
        # Materialize everything
        data = self._generate_large_dataset()
    else:
        # Only materialize subset
        data = self._generate_sample()
    
    # Yield materialization
    yield AssetMaterialization(
        asset_key=context.asset_key,
        description=f"Generated {len(data)} rows",
        metadata={
            "rows": len(data),
            "columns": len(data.columns),
            "is_sample": len(data) < 1000
        }
    )
    
    return data

# Manual materialization
def materialize_assets():
    """Manually materialize assets."""
    result = materialize([raw_data, processed_data, feature_store])
    
    if result.success:
        print("Assets materialized successfully")
        for asset_key, value in result.asset_values.items():
            print(f"  {asset_key.path}: {len(value)} rows")
    else:
        print(f"Materialization failed: {result.failure_data}")
```

---

## 6. Schedules and Sensors

### Schedule Types

```python
from dagster import schedule, ScheduleDefinition, cron_schedule, CronSchedule

# Basic schedule
@schedule(
    job=my_job,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def daily_schedule(context):
    """Daily pipeline run."""
    return {}

# Parameterized schedule
@schedule(
    job=my_job,
    cron_schedule="0 0 * * 0",  # Weekly on Sunday
    execution_timezone="UTC"
)
def weekly_schedule(context):
    """Weekly pipeline with parameters."""
    return {
        "ops": {
            "my_op": {
                "config": {
                    "batch_size": 1000,
                    "is_full_retrain": True
                }
            }
        }
    }

# Dynamic schedule
class DynamicSchedule(ScheduleDefinition):
    """Schedule with dynamic logic."""
    
    @cron_schedule("0 0 * * *")
    def evaluate_schedule(self, context):
        """Evaluate whether to run."""
        import datetime
        now = datetime.datetime.now()
        
        # Run only on weekdays
        if now.weekday() >= 5:
            return None  # Skip weekend
        
        # Run only if data available
        if self._data_available():
            return {}
        return None
```

### Sensor Types

```python
from dagster import sensor, RunRequest, SkipReason, SensorExecutionContext
from pathlib import Path

# File sensor
@sensor(job=my_job)
def file_sensor(context: SensorExecutionContext):
    """Trigger when file appears."""
    file_path = Path("data/new_data.csv")
    
    if not file_path.exists():
        return SkipReason("No new data file")
    
    # Check if already processed
    processed_path = Path("data/new_data.processed")
    if processed_path.exists():
        mtime = file_path.stat().st_mtime
        processed_mtime = processed_path.stat().st_mtime
        if mtime <= processed_mtime:
            return SkipReason("Data already processed")
    
    # Trigger pipeline
    return RunRequest(
        run_key=f"file_{int(file_path.stat().st_mtime)}",
        tags={"trigger": "file_sensor", "file": str(file_path)}
    )

# Multi-file sensor
@sensor(job=my_job)
def multi_file_sensor(context: SensorExecutionContext):
    """Trigger when any file changes."""
    watched_files = ["data/file1.csv", "data/file2.csv"]
    
    # Get current file hashes
    hashes = {}
    for file_path in watched_files:
        if Path(file_path).exists():
            with open(file_path, 'rb') as f:
                import hashlib
                hashes[file_path] = hashlib.md5(f.read()).hexdigest()
    
    # Check cursor
    cursor_data = context.cursor if context.cursor else {}
    previous_hashes = json.loads(cursor_data) if cursor_data else {}
    
    # Check for changes
    changes = []
    for file_path, file_hash in hashes.items():
        if previous_hashes.get(file_path) != file_hash:
            changes.append(file_path)
    
    if changes:
        # Update cursor
        context.update_cursor(json.dumps(hashes))
        
        return RunRequest(
            run_key=f"files_{len(changes)}",
            tags={"changed_files": ",".join(changes)}
        )
    
    return SkipReason("No file changes")
```

---

## 7. Error Handling and Retries

### Retry Policies

```python
from dagster import op, RetryPolicy

# Basic retry
@op(
    retry_policy=RetryPolicy(
        max_retries=3,
        delay=10,  # seconds
        backoff=2  # exponential backoff
    )
)
def retryable_op(context):
    """Operation with retry logic."""
    import random
    if random.random() < 0.3:
        raise ValueError("Transient error")
    return "success"

# Conditional retry
class CustomRetryPolicy(RetryPolicy):
    """Custom retry policy based on error type."""
    
    def __init__(self, error_types: list):
        self.error_types = error_types
        super().__init__(max_retries=3, delay=5, backoff=2)
    
    def should_retry(self, error: Exception):
        """Determine if error is retryable."""
        return any(isinstance(error, etype) for etype in self.error_types)

@op
def conditional_retry_op(context):
    """Operation with conditional retry."""
    try:
        # Simulate different error types
        import random
        error_type = random.choice(['transient', 'permanent', 'nothing'])
        
        if error_type == 'transient':
            raise ValueError("Transient error")
        elif error_type == 'permanent':
            raise TypeError("Permanent error")
        else:
            return "success"
    
    except ValueError as e:
        # Retry on ValueError
        raise
    except TypeError as e:
        # Don't retry on TypeError
        raise

# Custom retry with state
@op
def stateful_retry_op(context: OpExecutionContext):
    """Operation with retry state tracking."""
    attempt = context.op_retry_count + 1
    
    context.log.info(f"Attempt {attempt}")
    
    if attempt < 3:
        raise ValueError(f"Retry attempt {attempt}")
    
    return f"Success after {attempt} attempts"
```

---

## 8. Testing Patterns

### Unit Testing Ops

```python
from dagster import build_op_context, build_asset_context

def test_my_op():
    """Unit test for an op."""
    # Build context
    context = build_op_context()
    
    # Define input
    input_data = pd.DataFrame({'col': [1, 2, 3]})
    
    # Execute op
    result = my_op(context, input_data)
    
    # Assert
    assert len(result) == 3
    assert result.iloc[0] == 2

def test_asset():
    """Unit test for an asset."""
    # Build context
    context = build_asset_context()
    
    # Execute asset
    result = my_asset(context)
    
    # Assert
    assert isinstance(result, pd.DataFrame)
    assert 'col' in result.columns
```

### Integration Testing

```python
from dagster import execute_job, materialize

def test_job():
    """Integration test for a job."""
    # Execute job
    result = execute_job(my_job)
    
    # Check success
    assert result.success
    
    # Check outputs
    output_values = result.output_values()
    assert 'result' in output_values
    assert output_values['result'] is not None

def test_assets():
    """Integration test for assets."""
    # Materialize assets
    result = materialize([raw_data, processed_data, feature_store])
    
    # Check success
    assert result.success
    
    # Check all assets were materialized
    assert 'raw_data' in result.asset_values
    assert 'processed_data' in result.asset_values
    assert 'feature_store' in result.asset_values
```

---

## Troubleshooting Dagster

### Common Issues

```python
"""
Common Dagster issues and solutions:
1. Port conflicts - Change webserver port
2. Storage errors - Check database connections
3. Op failures - Check logs and retry
4. Asset materialization failures - Check dependencies
5. Schedule not running - Check daemon
6. Sensor not triggering - Check cursor/conditions
"""

def diagnose_dagster():
    """Diagnose common Dagster issues."""
    from dagster import DagsterInstance
    
    # Check instance
    instance = DagsterInstance.get()
    print(f"Dagster instance: {instance}")
    
    # Check runs
    runs = instance.get_runs(limit=10)
    print(f"Recent runs: {len(runs)}")
    
    # Check status
    for run in runs:
        print(f"  {run.run_id}: {run.status}")
        if run.status == 'FAILURE':
            print(f"    Error: {run.failure_message}")
    
    # Check schedules
    from dagster.schedule import Schedule
    schedules = instance.schedule_storage.all_schedules()
    print(f"Active schedules: {len([s for s in schedules if s.enabled])}")
    
    # Check sensors
    from dagster.sensor import Sensor
    sensors = instance.sensor_storage.all_sensors()
    print(f"Active sensors: {len([s for s in sensors if s.enabled])}")
```

---

*End of Primer 4: Dagster Architecture and Advanced Patterns*
