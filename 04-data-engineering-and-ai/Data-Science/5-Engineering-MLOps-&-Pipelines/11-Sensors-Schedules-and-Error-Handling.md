# Part 11: Sensors, Schedules, and Error Handling

## The Target: Event-Driven Pipelines and Error Management

In this part, we'll implement production-grade scheduling, event-driven triggers, and comprehensive error handling. By the end, you'll have a self-managing pipeline system that runs automatically and handles failures gracefully.

## The Concept: Automated Pipeline Management

Think of this like a smart home automation system:
- **Schedules** are like your morning alarm (runs at specific times)
- **Sensors** are like motion detectors (triggers when something changes)
- **Error handling** is like a backup generator (keeps things running when problems occur)
- **Monitoring** is like security cameras (gives you visibility into what's happening)

## The Implementation: Advanced Automation

### Step 1: Create Sophisticated Schedules

```bash
cat > pipelines/advanced_schedules.py << 'EOF'
"""
Advanced scheduling for Dagster pipelines.
Includes cron schedules, timezone handling, and conditional scheduling.
"""

from dagster import (
    ScheduleDefinition, 
    schedule, 
    JobDefinition,
    OpExecutionContext,
    RunRequest,
    RunConfig,
    SkipReason,
    run_failure_sensor
)
from dagster.utils import parseable_cron_schedule
from datetime import datetime, timedelta
import pytz
import json
from pathlib import Path

from pipelines.advanced_pipeline import advanced_mlops_pipeline
from pipelines.pipeline_ops import mlops_pipeline


# ============= BASIC SCHEDULES =============

@schedule(
    job=mlops_pipeline,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def daily_midnight_schedule(context):
    """
    Daily pipeline run at midnight UTC.
    """
    return {}


@schedule(
    job=advanced_mlops_pipeline,
    cron_schedule="0 12 * * *",  # Daily at noon
    execution_timezone="America/New_York"
)
def daily_noon_ny_schedule(context):
    """
    Daily pipeline run at noon New York time.
    """
    return {}


# ============= WEEKLY SCHEDULES =============

@schedule(
    job=advanced_mlops_pipeline,
    cron_schedule="0 0 * * 0",  # Weekly on Sunday
    execution_timezone="UTC"
)
def weekly_sunday_schedule(context):
    """
    Weekly pipeline run on Sunday midnight UTC.
    Useful for full retraining.
    """
    return {}


# ============= HOURLY SCHEDULES (Development) =============

@schedule(
    job=mlops_pipeline,
    cron_schedule="0 * * * *",  # Every hour
    execution_timezone="UTC"
)
def hourly_dev_schedule(context):
    """
    Hourly pipeline run for development/testing.
    """
    # Check if we should run (only run during working hours)
    current_hour = datetime.now(pytz.UTC).hour
    
    if 9 <= current_hour <= 17:
        return {}
    else:
        return SkipReason("Outside working hours")


# ============= CONDITIONAL SCHEDULES =============

@schedule(
    job=advanced_mlops_pipeline,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def conditional_daily_schedule(context):
    """
    Daily pipeline with conditional execution based on data.
    """
    # Check if new data is available
    data_file = Path("data/raw/sensor_data.csv")
    
    if not data_file.exists():
        return SkipReason("Data file not available")
    
    # Check if data is recent (within last 24 hours)
    last_modified = datetime.fromtimestamp(data_file.stat().st_mtime)
    age = datetime.now() - last_modified
    
    if age > timedelta(hours=24):
        return SkipReason(f"Data is too old ({age})")
    
    # Check if model needs retraining
    model_file = Path("models/registry/best_model.pkl")
    
    if model_file.exists():
        model_age = datetime.fromtimestamp(model_file.stat().st_mtime)
        model_age_days = (datetime.now() - model_age).days
        
        # Only retrain weekly if data hasn't changed much
        if model_age_days < 7:
            return SkipReason(f"Model is recent ({model_age_days} days old)")
    
    return {
        "tags": {
            "trigger": "conditional_daily_schedule",
            "data_age": str(age),
            "run_reason": "data available and model outdated"
        }
    }


# ============= DYNAMIC SCHEDULES =============

@schedule(
    job=advanced_mlops_pipeline,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def dynamic_interval_schedule(context):
    """
    Schedule with dynamic interval based on conditions.
    """
    # Check system load
    import psutil
    cpu_percent = psutil.cpu_percent(interval=1)
    memory_percent = psutil.virtual_memory().percent
    
    # If system is busy, skip or adjust
    if cpu_percent > 80 or memory_percent > 80:
        return SkipReason(f"System too busy: CPU={cpu_percent}%, Memory={memory_percent}%")
    
    return {}


# ============= SCHEDULES WITH RUN CONFIG =============

@schedule(
    job=advanced_mlops_pipeline,
    cron_schedule="0 0 1 * *",  # Monthly on 1st
    execution_timezone="UTC"
)
def monthly_full_schedule(context):
    """
    Monthly full pipeline run with specific configuration.
    """
    return RunRequest(
        run_key=f"monthly_full_{datetime.now().strftime('%Y%m')}",
        run_config={
            "ops": {
                "generate_batch_data": {
                    "config": {
                        "n_samples": 10000,
                        "anomaly_rate": 0.05
                    }
                },
                "create_features_advanced": {
                    "config": {
                        "window_sizes": [5, 10, 30, 60]
                    }
                },
                "train_random_forest": {
                    "config": {
                        "n_estimators": 500,
                        "max_depth": 20,
                        "cv_folds": 5
                    }
                }
            }
        },
        tags={
            "schedule_name": "monthly_full_schedule",
            "run_type": "full_retraining"
        }
    )


# ============= EXCEPTION HANDLING SCHEDULES =============

@schedule(
    job=advanced_mlops_pipeline,
    cron_schedule="0 */4 * * *",  # Every 4 hours
    execution_timezone="UTC"
)
def retry_on_failure_schedule(context):
    """
    Schedule that runs every 4 hours to retry failed runs.
    """
    # Check for failed runs in the last 4 hours
    from dagster import DagsterInstance
    instance = DagsterInstance.get()
    
    # Get recent runs
    since_time = datetime.now() - timedelta(hours=4)
    recent_runs = instance.get_runs(
        limit=10,
        filters={"updated_after": since_time}
    )
    
    # Find failed runs for this job
    failed_runs = [
        run for run in recent_runs 
        if run.job_name == advanced_mlops_pipeline.name and run.is_failure
    ]
    
    if failed_runs:
        context.log.info(f"Found {len(failed_runs)} failed runs, triggering retry")
        return {
            "tags": {
                "schedule_name": "retry_on_failure_schedule",
                "failed_run_ids": ",".join([run.run_id for run in failed_runs]),
                "is_retry": "true"
            }
        }
    
    return SkipReason("No failed runs to retry")


# ============= MAINTENANCE SCHEDULES =============

@schedule(
    job=advanced_mlops_pipeline,
    cron_schedule="0 2 * * 0",  # Weekly on Sunday at 2 AM
    execution_timezone="UTC"
)
def weekly_maintenance_schedule(context):
    """
    Weekly maintenance schedule for cleanup and reporting.
    """
    # Only run if maintenance is needed
    maintenance_file = Path("logs/maintenance_needed.txt")
    
    if not maintenance_file.exists():
        return SkipReason("No maintenance needed")
    
    return {
        "tags": {
            "schedule_name": "weekly_maintenance_schedule",
            "run_type": "maintenance"
        }
    }


# Export all schedules
schedules = [
    daily_midnight_schedule,
    daily_noon_ny_schedule,
    weekly_sunday_schedule,
    hourly_dev_schedule,
    conditional_daily_schedule,
    dynamic_interval_schedule,
    monthly_full_schedule,
    retry_on_failure_schedule,
    weekly_maintenance_schedule,
]
EOF
```

### Step 2: Create Advanced Sensors

```bash
cat > pipelines/advanced_sensors.py << 'EOF'
"""
Advanced sensors for event-driven pipeline triggers.
Includes file monitoring, API triggers, and condition-based sensors.
"""

from dagster import (
    sensor, 
    RunRequest, 
    SensorExecutionContext, 
    SkipReason,
    pipeline_failure_sensor,
    run_failure_sensor,
    run_status_sensor,
    RunStatus,
    EventLogEntry,
    DagsterRunStatus
)
from dagster.core.storage.event_log import EventLogEntry
import hashlib
import json
from pathlib import Path
import time
from datetime import datetime, timedelta
import pandas as pd

from pipelines.advanced_pipeline import advanced_mlops_pipeline
from pipelines.pipeline_ops import mlops_pipeline


# ============= FILE-BASED SENSORS =============

@sensor(
    job=advanced_mlops_pipeline,
    minimum_interval_seconds=60  # Check every minute
)
def data_file_sensor(context: SensorExecutionContext):
    """
    Sensor that triggers when a data file appears or changes.
    """
    data_file = Path("data/raw/new_data.csv")
    
    if not data_file.exists():
        return SkipReason("Data file not found")
    
    # Check if file has been processed
    processed_file = Path("data/raw/new_data.processed")
    
    if processed_file.exists():
        # Check if file is newer than processed marker
        if data_file.stat().st_mtime <= processed_file.stat().st_mtime:
            return SkipReason("Data file already processed")
    
    # Get file info
    file_mtime = datetime.fromtimestamp(data_file.stat().st_mtime)
    file_size = data_file.stat().st_size
    
    # Read file metadata
    try:
        df = pd.read_csv(data_file, nrows=5)
        columns = df.columns.tolist()
    except Exception as e:
        return SkipReason(f"Could not read data file: {e}")
    
    # Create run request
    return RunRequest(
        run_key=f"data_file_{int(file_mtime.timestamp())}",
        run_config={
            "ops": {
                "generate_batch_data": {
                    "config": {
                        "file_path": str(data_file)
                    }
                }
            }
        },
        tags={
            "sensor_name": "data_file_sensor",
            "file_path": str(data_file),
            "file_size": str(file_size),
            "file_mtime": file_mtime.isoformat(),
            "columns": ",".join(columns[:5])
        }
    )


@sensor(
    job=advanced_mlops_pipeline,
    minimum_interval_seconds=300  # Check every 5 minutes
)
def model_file_sensor(context: SensorExecutionContext):
    """
    Sensor that triggers when a model file changes.
    """
    model_dir = Path("models/registry")
    
    if not model_dir.exists():
        return SkipReason("Model directory not found")
    
    # Find the most recent model file
    model_files = list(model_dir.glob("*.pkl"))
    
    if not model_files:
        return SkipReason("No model files found")
    
    # Get latest model
    latest_model = max(model_files, key=lambda f: f.stat().st_mtime)
    model_mtime = datetime.fromtimestamp(latest_model.stat().st_mtime)
    
    # Check cursor
    cursor = context.cursor if context.cursor else "0"
    
    if float(cursor) >= model_mtime.timestamp():
        return SkipReason("No new model changes")
    
    # Trigger pipeline
    context.update_cursor(str(model_mtime.timestamp()))
    
    return RunRequest(
        run_key=f"model_change_{int(model_mtime.timestamp())}",
        tags={
            "sensor_name": "model_file_sensor",
            "model_file": latest_model.name,
            "model_mtime": model_mtime.isoformat()
        }
    )


@sensor(
    job=advanced_mlops_pipeline,
    minimum_interval_seconds=600  # Check every 10 minutes
)
def multiple_file_sensor(context: SensorExecutionContext):
    """
    Sensor that monitors multiple files and triggers when any change.
    """
    # Files to monitor
    watch_files = [
        "data/raw/sensor_data.csv",
        "data/processed/features.csv",
        "configs/model_thresholds.json"
    ]
    
    # Get file hashes
    file_hashes = {}
    for file_path in watch_files:
        path = Path(file_path)
        if path.exists():
            with open(path, 'rb') as f:
                file_hash = hashlib.md5(f.read()).hexdigest()
            file_hashes[file_path] = file_hash
    
    # Check cursor
    cursor_data = context.cursor if context.cursor else "{}"
    previous_hashes = json.loads(cursor_data)
    
    # Check for changes
    changes = []
    for file_path, file_hash in file_hashes.items():
        previous_hash = previous_hashes.get(file_path)
        if previous_hash is None:
            changes.append(f"{file_path}: new file")
        elif previous_hash != file_hash:
            changes.append(f"{file_path}: changed")
    
    if not changes:
        return SkipReason("No file changes detected")
    
    # Update cursor
    context.update_cursor(json.dumps(file_hashes))
    
    return RunRequest(
        run_key=f"file_change_{int(time.time())}",
        tags={
            "sensor_name": "multiple_file_sensor",
            "changes": ",".join(changes)
        }
    )


# ============= SCHEDULE-BASED SENSORS =============

@sensor(
    job=advanced_mlops_pipeline,
    minimum_interval_seconds=1800  # Every 30 minutes
)
def time_based_sensor(context: SensorExecutionContext):
    """
    Sensor that triggers based on time conditions.
    """
    current_time = datetime.now()
    
    # Trigger only if data is available
    data_file = Path("data/raw/sensor_data.csv")
    
    if not data_file.exists():
        return SkipReason("Data file not available")
    
    # Check if data is recent
    data_age = datetime.now() - datetime.fromtimestamp(data_file.stat().st_mtime)
    
    if data_age > timedelta(hours=6):
        return SkipReason(f"Data is too old ({data_age})")
    
    # Check if we should process now
    # Only process on odd hours
    if current_time.hour % 2 == 0:
        return SkipReason("Processing only on odd hours")
    
    return RunRequest(
        run_key=f"time_based_{current_time.strftime('%Y%m%d_%H%M')}",
        tags={
            "sensor_name": "time_based_sensor",
            "data_age": str(data_age)
        }
    )


# ============= HTTP API SENSORS =============

@sensor(
    job=advanced_mlops_pipeline,
    minimum_interval_seconds=60
)
def api_trigger_sensor(context: SensorExecutionContext):
    """
    Sensor that checks an API endpoint for triggers.
    """
    import requests
    
    try:
        # Check API endpoint
        response = requests.get(
            "http://localhost:8000/trigger_status",
            timeout=5
        )
        
        if response.status_code != 200:
            return SkipReason(f"API returned {response.status_code}")
        
        data = response.json()
        
        if not data.get('trigger', False):
            return SkipReason("API trigger not active")
        
        return RunRequest(
            run_key=f"api_trigger_{data.get('timestamp', int(time.time()))}",
            run_config=data.get('run_config', {}),
            tags={
                "sensor_name": "api_trigger_sensor",
                "trigger_id": data.get('id', 'unknown')
            }
        )
    
    except requests.RequestException as e:
        return SkipReason(f"API request failed: {e}")


# ============= DATABASE QUERY SENSORS =============

@sensor(
    job=advanced_mlops_pipeline,
    minimum_interval_seconds=900  # Every 15 minutes
)
def db_query_sensor(context: SensorExecutionContext):
    """
    Sensor that triggers based on database query results.
    """
    try:
        # Simulate database check
        # In practice, use actual database connection
        import sqlite3
        
        conn = sqlite3.connect('data/pipeline_metadata.db')
        cursor = conn.cursor()
        
        # Check for new data in database
        cursor.execute("""
            SELECT COUNT(*) FROM incoming_data 
            WHERE processed = 0
        """)
        
        count = cursor.fetchone()[0]
        conn.close()
        
        if count == 0:
            return SkipReason("No unprocessed data in database")
        
        return RunRequest(
            run_key=f"db_query_{int(time.time())}",
            tags={
                "sensor_name": "db_query_sensor",
                "unprocessed_count": str(count)
            }
        )
    
    except Exception as e:
        return SkipReason(f"Database query failed: {e}")


# ============= LOG-BASED SENSORS =============

@sensor(
    job=advanced_mlops_pipeline,
    minimum_interval_seconds=300  # Every 5 minutes
)
def log_analysis_sensor(context: SensorExecutionContext):
    """
    Sensor that analyzes logs and triggers on patterns.
    """
    log_file = Path("logs/pipeline.log")
    
    if not log_file.exists():
        return SkipReason("Log file not found")
    
    # Check cursor
    cursor = int(context.cursor) if context.cursor else 0
    file_size = log_file.stat().st_size
    
    if file_size <= cursor:
        return SkipReason("No new log entries")
    
    # Read new log entries
    with open(log_file, 'r') as f:
        f.seek(cursor)
        new_logs = f.read()
    
    # Update cursor
    context.update_cursor(str(file_size))
    
    # Check for error patterns
    if "CRITICAL" in new_logs or "ERROR" in new_logs:
        return RunRequest(
            run_key=f"log_error_{int(time.time())}",
            tags={
                "sensor_name": "log_analysis_sensor",
                "trigger_reason": "error_detected_in_logs"
            }
        )
    
    return SkipReason("No critical errors in logs")


# ============= RUN STATUS SENSORS =============

@run_status_sensor(
    job=advanced_mlops_pipeline,
    run_status=DagsterRunStatus.SUCCESS,
    monitored_jobs=[advanced_mlops_pipeline.name]
)
def on_run_success_sensor(context: SensorExecutionContext, event: EventLogEntry):
    """
    Sensor that triggers after successful pipeline run.
    """
    context.log.info(f"Pipeline run {event.run_id} completed successfully")
    
    # Trigger another pipeline or action
    return RunRequest(
        run_key=f"after_success_{event.run_id}",
        tags={
            "sensor_name": "on_run_success_sensor",
            "parent_run_id": event.run_id,
            "triggered_by": "success"
        }
    )


@run_failure_sensor(
    monitored_jobs=[advanced_mlops_pipeline.name]
)
def on_run_failure_sensor(context: SensorExecutionContext, event: EventLogEntry):
    """
    Sensor that triggers on pipeline failure.
    """
    context.log.error(f"Pipeline run {event.run_id} failed")
    
    # Send alert
    send_alert(event.run_id, event.message)
    
    return SkipReason("Alert sent for pipeline failure")


def send_alert(run_id: str, error_message: str):
    """
    Send alert notification.
    """
    # In practice, send email, Slack, PagerDuty, etc.
    alert_file = Path("logs/alerts.txt")
    with open(alert_file, 'a') as f:
        f.write(f"{datetime.now().isoformat()}: Run {run_id} failed: {error_message}\n")


# Export sensors
sensors = [
    data_file_sensor,
    model_file_sensor,
    multiple_file_sensor,
    time_based_sensor,
    api_trigger_sensor,
    db_query_sensor,
    log_analysis_sensor,
    on_run_success_sensor,
    on_run_failure_sensor,
]
EOF
```

### Step 3: Create Comprehensive Error Handling

```bash
cat > pipelines/error_handling.py << 'EOF'
"""
Advanced error handling for Dagster pipelines.
Includes custom error types, recovery strategies, and alerting.
"""

from dagster import (
    op, 
    job, 
    Failure, 
    RetryPolicy, 
    OpExecutionContext,
    Out,
    In,
    get_dagster_logger
)
import time
import random
import json
from pathlib import Path
from datetime import datetime
import traceback


# ============= CUSTOM EXCEPTIONS =============

class DataValidationError(Exception):
    """Raised when data validation fails."""
    pass


class ModelTrainingError(Exception):
    """Raised when model training fails."""
    pass


class DeploymentError(Exception):
    """Raised when deployment fails."""
    pass


class TransientError(Exception):
    """Raised for transient errors that can be retried."""
    pass


class PermanentError(Exception):
    """Raised for permanent errors that cannot be retried."""
    pass


# ============= ERROR HANDLING HOOKS =============

from dagster import op_failure_hook, HookContext


@op_failure_hook
def handle_retryable_error(context: HookContext, failure: Failure):
    """
    Hook for handling retryable errors.
    """
    logger = get_dagster_logger()
    
    # Check if this is a retryable error
    if "retryable" in str(failure.message).lower():
        logger.warning(f"Retryable error detected: {failure.message}")
        
        # Log for monitoring
        log_error(
            context.op.name,
            failure.message,
            context.run_id,
            "retryable"
        )
    else:
        logger.error(f"Non-retryable error: {failure.message}")
        log_error(
            context.op.name,
            failure.message,
            context.run_id,
            "fatal"
        )
        
        # Send alert for fatal errors
        send_alert(
            context.op.name,
            failure.message,
            context.run_id
        )


# ============= OPS WITH ERROR HANDLING =============

@op(
    retry_policy=RetryPolicy(
        max_retries=3,
        delay=10,  # seconds
        backoff=2  # exponential backoff multiplier
    ),
    tags={"stage": "data_validation"}
)
def validate_data_with_retry(context: OpExecutionContext, data: dict) -> dict:
    """
    Validate data with retry logic.
    """
    logger = context.log
    
    try:
        # Simulate validation
        if random.random() < 0.2:  # 20% chance of validation failure
            raise DataValidationError("Data validation failed: missing required fields")
        
        logger.info("Data validation passed")
        return {"validated": True, "data": data}
    
    except DataValidationError as e:
        # Check if this is retryable
        if "retryable" in str(e).lower():
            raise TransientError(f"Retryable validation error: {e}")
        else:
            raise


@op(
    retry_policy=RetryPolicy(
        max_retries=5,
        delay=5,
        backoff=2
    ),
    tags={"stage": "model_training"}
)
def train_model_with_retry(context: OpExecutionContext, data: dict) -> dict:
    """
    Train model with exponential backoff retry.
    """
    logger = context.log
    
    # Get attempt number
    attempt = context.op_retry_count + 1
    logger.info(f"Training attempt {attempt}")
    
    try:
        # Simulate training
        if random.random() < 0.1 * attempt:  # More likely to fail on later attempts
            if attempt < 3:
                raise TransientError(f"Training failed (attempt {attempt}), retrying...")
            else:
                raise ModelTrainingError(f"Training failed permanently after {attempt} attempts")
        
        # Simulate training time
        time.sleep(1)
        
        # Return trained model
        model = {
            "type": "random_forest",
            "parameters": {"n_estimators": 100},
            "accuracy": 0.85 + random.random() * 0.1
        }
        
        logger.info(f"Training completed on attempt {attempt}")
        return {"trained": True, "model": model}
    
    except TransientError as e:
        raise
    except Exception as e:
        raise ModelTrainingError(f"Training failed: {e}")


@op(
    retry_policy=RetryPolicy(
        max_retries=0,  # No retries for this op
        delay=0
    ),
    tags={"stage": "deployment"}
)
def deploy_model_with_fallback(context: OpExecutionContext, model: dict) -> dict:
    """
    Deploy model with fallback logic (no retry).
    """
    logger = context.log
    
    try:
        # Simulate deployment
        if random.random() < 0.3:  # 30% chance of deployment failure
            raise DeploymentError("Deployment failed: API not available")
        
        logger.info("Model deployed successfully")
        return {"deployed": True, "model": model}
    
    except DeploymentError as e:
        # Log the error
        logger.error(f"Deployment failed: {e}")
        
        # Try fallback deployment
        logger.info("Attempting fallback deployment...")
        time.sleep(2)
        
        # Simulate fallback success
        return {
            "deployed": True,
            "model": model,
            "fallback": True,
            "original_error": str(e)
        }


# ============= ERROR LOGGING HELPERS =============

def log_error(op_name: str, error_message: str, run_id: str, severity: str):
    """
    Log error to persistent storage.
    """
    error_dir = Path("logs/errors")
    error_dir.mkdir(parents=True, exist_ok=True)
    
    error_file = error_dir / f"{datetime.now().strftime('%Y%m%d')}.json"
    
    error_entry = {
        "op_name": op_name,
        "error_message": error_message,
        "run_id": run_id,
        "severity": severity,
        "timestamp": datetime.now().isoformat()
    }
    
    # Append to log file
    with open(error_file, 'a') as f:
        f.write(json.dumps(error_entry) + "\n")


def send_alert(op_name: str, error_message: str, run_id: str):
    """
    Send alert for fatal errors.
    """
    # In practice, integrate with Slack, PagerDuty, Email, etc.
    alert_file = Path("logs/alerts.txt")
    with open(alert_file, 'a') as f:
        f.write(f"[{datetime.now().isoformat()}] ALERT: {op_name} failed: {error_message} (Run: {run_id})\n")


# ============= ERROR RECOVERY OP =============

@op
def recover_from_failure(context: OpExecutionContext, error_info: dict) -> dict:
    """
    Attempt to recover from a failed operation.
    """
    logger = context.log
    
    logger.info("Attempting recovery...")
    
    # Check error type
    error_type = error_info.get('type', 'unknown')
    
    if error_type == 'data_validation':
        logger.info("Recovering from data validation failure...")
        # Could use default data, skip, etc.
        return {
            "recovered": True,
            "strategy": "used_default_data",
            "original_error": error_info.get('message')
        }
    
    elif error_type == 'model_training':
        logger.info("Recovering from model training failure...")
        # Could use previous model, simpler model, etc.
        return {
            "recovered": True,
            "strategy": "used_previous_model",
            "original_error": error_info.get('message')
        }
    
    else:
        logger.warning(f"Unknown error type: {error_type}")
        return {
            "recovered": False,
            "strategy": "no_recovery_available",
            "original_error": error_info.get('message')
        }


# ============= HEALTH CHECK OP =============

@op
def check_system_health(context: OpExecutionContext) -> dict:
    """
    Check system health before running pipeline.
    """
    logger = context.log
    
    health_status = {
        "healthy": True,
        "checks": {}
    }
    
    # Check disk space
    import shutil
    disk_usage = shutil.disk_usage('/')
    free_space_gb = disk_usage.free / (1024**3)
    
    health_status["checks"]["disk_space"] = {
        "free_gb": free_space_gb,
        "healthy": free_space_gb > 10  # At least 10GB free
    }
    
    if free_space_gb < 10:
        health_status["healthy"] = False
        logger.warning(f"Low disk space: {free_space_gb:.2f}GB")
    
    # Check memory
    import psutil
    memory = psutil.virtual_memory()
    memory_percent = memory.percent
    
    health_status["checks"]["memory"] = {
        "percent_used": memory_percent,
        "healthy": memory_percent < 80
    }
    
    if memory_percent > 80:
        health_status["healthy"] = False
        logger.warning(f"High memory usage: {memory_percent}%")
    
    # Check connectivity to external services
    # Could check MLflow, DVC remote, database, etc.
    
    return health_status


# ============= COMPLETE PIPELINE WITH ERROR HANDLING =============

@job
def error_resilient_pipeline():
    """
    Pipeline with comprehensive error handling.
    """
    from pipelines.advanced_pipeline import generate_batch_data, clean_and_validate_data
    
    # Check health first
    health = check_system_health()
    
    # Branch based on health
    def process_data():
        data = generate_batch_data()
        try:
            validated = validate_data_with_retry(data)
            model = train_model_with_retry(validated)
            deployed = deploy_model_with_fallback(model)
            return deployed
        except Exception as e:
            # Recover from failure
            error_info = {
                "type": type(e).__name__,
                "message": str(e),
                "traceback": traceback.format_exc()
            }
            return recover_from_failure(error_info)
    
    result = process_data()
    return result


# Export jobs
jobs = [error_resilient_pipeline]
EOF
```

### Step 4: Create Monitoring and Alerting Scripts

```bash
cat > scripts/monitor_pipeline.py << 'EOF'
#!/usr/bin/env python
"""
Monitoring script for pipeline health and performance.
"""

import json
import time
from pathlib import Path
from datetime import datetime, timedelta
import pandas as pd
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import requests


class PipelineMonitor:
    """Monitor pipeline health and send alerts."""
    
    def __init__(self, log_dir: str = "logs"):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)
    
    def check_pipeline_health(self) -> dict:
        """Check overall pipeline health."""
        health_status = {
            "healthy": True,
            "checks": {},
            "timestamp": datetime.now().isoformat()
        }
        
        # Check last run
        last_run = self.get_last_run_status()
        health_status["checks"]["last_run"] = last_run
        
        if not last_run.get("success", False):
            health_status["healthy"] = False
        
        # Check error rate
        error_rate = self.get_error_rate()
        health_status["checks"]["error_rate"] = error_rate
        
        if error_rate.get("rate", 0) > 0.2:  # More than 20% failure rate
            health_status["healthy"] = False
        
        # Check data freshness
        data_freshness = self.check_data_freshness()
        health_status["checks"]["data_freshness"] = data_freshness
        
        if data_freshness.get("age_hours", 0) > 24:  # Data older than 24 hours
            health_status["healthy"] = False
        
        return health_status
    
    def get_last_run_status(self) -> dict:
        """Get status of the last pipeline run."""
        # In practice, query Dagster API
        try:
            response = requests.get("http://localhost:3000/graphql", 
                json={"query": "query { runs(limit:1) { id, status, startTime, endTime } }"}
            )
            if response.status_code == 200:
                data = response.json()
                runs = data.get("data", {}).get("runs", [])
                if runs:
                    run = runs[0]
                    return {
                        "success": run.get("status") == "SUCCESS",
                        "run_id": run.get("id"),
                        "time": run.get("startTime")
                    }
        except:
            pass
        
        # Fallback: check log files
        log_file = self.log_dir / "pipeline_status.json"
        if log_file.exists():
            with open(log_file, 'r') as f:
                return json.load(f)
        
        return {"success": None, "run_id": None, "time": None}
    
    def get_error_rate(self) -> dict:
        """Calculate error rate from recent runs."""
        error_file = self.log_dir / "errors" / f"{datetime.now().strftime('%Y%m%d')}.json"
        
        if not error_file.exists():
            return {"rate": 0, "total": 0, "errors": 0}
        
        errors = []
        with open(error_file, 'r') as f:
            for line in f:
                if line.strip():
                    errors.append(json.loads(line))
        
        total = len(errors)
        if total == 0:
            return {"rate": 0, "total": 0, "errors": 0}
        
        fatal_errors = sum(1 for e in errors if e.get("severity") == "fatal")
        rate = fatal_errors / total
        
        return {"rate": rate, "total": total, "errors": fatal_errors}
    
    def check_data_freshness(self) -> dict:
        """Check how fresh the data is."""
        data_file = Path("data/raw/sensor_data.csv")
        
        if not data_file.exists():
            return {"age_hours": None, "exists": False}
        
        mtime = datetime.fromtimestamp(data_file.stat().st_mtime)
        age = datetime.now() - mtime
        age_hours = age.total_seconds() / 3600
        
        return {"age_hours": age_hours, "exists": True}
    
    def send_alert(self, health_status: dict):
        """Send alert if health check fails."""
        if health_status["healthy"]:
            return
        
        # Create alert message
        message = "🚨 PIPELINE HEALTH ALERT 🚨\n\n"
        message += f"Time: {health_status['timestamp']}\n"
        message += "Issues found:\n"
        
        for check, status in health_status["checks"].items():
            if isinstance(status, dict) and not status.get("success", True):
                message += f"  - {check}: {status}\n"
        
        # Send via email (configure with your SMTP)
        self.send_email(message)
        
        # Send via Slack webhook
        self.send_slack(message)
        
        # Log alert
        alert_file = self.log_dir / "alerts.txt"
        with open(alert_file, 'a') as f:
            f.write(f"[{datetime.now().isoformat()}] {message}\n")
    
    def send_email(self, message: str):
        """Send email alert."""
        # Configure email settings
        smtp_host = "smtp.gmail.com"
        smtp_port = 587
        sender = "pipeline-alerts@yourdomain.com"
        recipient = "team@yourdomain.com"
        
        msg = MIMEMultipart()
        msg['From'] = sender
        msg['To'] = recipient
        msg['Subject'] = "Pipeline Health Alert"
        msg.attach(MIMEText(message, 'plain'))
        
        try:
            server = smtplib.SMTP(smtp_host, smtp_port)
            server.starttls()
            # server.login("username", "password")
            server.send_message(msg)
            server.quit()
        except Exception as e:
            print(f"Failed to send email: {e}")
    
    def send_slack(self, message: str):
        """Send Slack alert."""
        webhook_url = "https://hooks.slack.com/services/your/webhook/url"
        
        payload = {"text": message}
        
        try:
            requests.post(webhook_url, json=payload)
        except Exception as e:
            print(f"Failed to send Slack alert: {e}")
    
    def run(self):
        """Run the monitoring cycle."""
        print("Running pipeline health check...")
        
        health_status = self.check_pipeline_health()
        
        print(json.dumps(health_status, indent=2))
        
        if not health_status["healthy"]:
            print("⚠️ Health check failed! Sending alert...")
            self.send_alert(health_status)
        else:
            print("✅ All systems healthy")
        
        return health_status


if __name__ == "__main__":
    monitor = PipelineMonitor()
    monitor.run()
EOF

chmod +x scripts/monitor_pipeline.py
```

### Step 5: Run and Test

```bash
# Start Dagster with all components
export DAGSTER_HOME=$(pwd)/dagster_home
dagster-webserver -m pipelines

# In another terminal, start daemon
dagster-daemon run

# Check schedule and sensor status
dagster schedule list
dagster sensor list

# Test error handling
python -c "
from dagster import execute_job
from pipelines.error_handling import error_resilient_pipeline
result = execute_job(error_resilient_pipeline)
print(f'Success: {result.success}')
"

# Run monitoring
python scripts/monitor_pipeline.py
```

## The Verification: Testing Automation

### Verification 1: Check Schedules

```bash
# List active schedules
dagster schedule list

# Check schedule status
dagster schedule status daily_midnight_schedule

# Preview next run
dagster schedule preview daily_midnight_schedule
```

### Verification 2: Test Sensors

```bash
# Test file sensor by creating a file
touch data/raw/new_data.csv
echo "test,data" > data/raw/new_data.csv

# Check sensor status
dagster sensor list

# Check sensor logs
dagster sensor logs data_file_sensor
```

### Verification 3: Test Error Handling

```bash
# Run error-resilient pipeline
dagster job execute -f pipelines/error_handling.py -j error_resilient_pipeline -l DEBUG

# Check error logs
cat logs/errors/*.json

# Check alerts
cat logs/alerts.txt
```

## What We've Accomplished

You now have a fully automated pipeline system with:

1. **Multiple schedule types** (daily, weekly, monthly, conditional)
2. **Event-driven sensors** (file, API, database, log-based)
3. **Comprehensive error handling** (retries, fallbacks, recovery)
4. **Health monitoring** and alerting
5. **Run status sensors** for chaining pipelines
6. **System health checks** before execution

## Next Steps

In Part 12, we'll:
- Integrate DVC with Dagster
- Integrate MLflow with Dagster  
- Build the complete end-to-end pipeline
- Create deployment automation

---

*End of Part 11: Sensors, Schedules, and Error Handling*
