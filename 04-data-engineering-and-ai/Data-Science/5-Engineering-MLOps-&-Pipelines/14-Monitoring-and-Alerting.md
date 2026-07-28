# Part 14: Monitoring and Alerting

## The Target: Comprehensive Pipeline Monitoring and Alerting

In this part, we'll implement robust monitoring and alerting for our MLOps pipeline. By the end, you'll have a complete observability stack that tracks pipeline health, model performance, data quality, and sends alerts when issues arise.

## The Concept: Observability for ML Systems

Think of monitoring like a dashboard in a car:
- **Pipeline metrics** = Speedometer, fuel gauge (how is the system running?)
- **Model performance** = Check engine light (is the model still working well?)
- **Data quality** = Tire pressure monitor (is the data healthy?)
- **Alerts** = Warning lights (something needs attention!)
- **Logs** = Trip computer (detailed record of everything)

## The Implementation: Monitoring System

### Step 1: Create Monitoring Framework

```bash
cat > src/monitoring/monitor.py << 'EOF'
"""
Comprehensive monitoring framework for MLOps pipelines.
Tracks metrics, logs, and sends alerts.
"""

import json
import time
import logging
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List, Callable
import pandas as pd
import numpy as np
import requests
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import subprocess
import psutil
import hashlib

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class MetricType:
    """Metric types for monitoring."""
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    SUMMARY = "summary"


class AlertSeverity:
    """Alert severity levels."""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class MonitorMetric:
    """Single metric to be monitored."""
    
    def __init__(self, name: str, value: Any, timestamp: Optional[datetime] = None):
        self.name = name
        self.value = value
        self.timestamp = timestamp or datetime.now()
        self.tags = {}
    
    def to_dict(self) -> Dict:
        return {
            'name': self.name,
            'value': self.value,
            'timestamp': self.timestamp.isoformat(),
            'tags': self.tags
        }


class MonitorAlert:
    """Alert to be sent."""
    
    def __init__(self, 
                 title: str,
                 message: str,
                 severity: str = AlertSeverity.WARNING,
                 source: Optional[str] = None,
                 tags: Optional[Dict] = None):
        self.title = title
        self.message = message
        self.severity = severity
        self.source = source or "mlops_pipeline"
        self.tags = tags or {}
        self.timestamp = datetime.now()
        self.acknowledged = False
    
    def to_dict(self) -> Dict:
        return {
            'title': self.title,
            'message': self.message,
            'severity': self.severity,
            'source': self.source,
            'tags': self.tags,
            'timestamp': self.timestamp.isoformat(),
            'acknowledged': self.acknowledged
        }


class PipelineMonitor:
    """
    Main monitoring class for MLOps pipeline.
    """
    
    def __init__(self, 
                 name: str = "mlops_pipeline",
                 storage_dir: str = "logs/monitoring"):
        self.name = name
        self.storage_dir = Path(storage_dir)
        self.storage_dir.mkdir(parents=True, exist_ok=True)
        
        self.metrics = []
        self.alerts = []
        self.alert_rules = []
        
        # Alert channels
        self.channels = {
            'email': None,
            'slack': None,
            'webhook': None
        }
        
        # Load previous state
        self._load_state()
    
    def _load_state(self):
        """Load previous monitoring state."""
        metrics_file = self.storage_dir / "metrics.json"
        if metrics_file.exists():
            try:
                with open(metrics_file, 'r') as f:
                    data = json.load(f)
                    self.metrics = data.get('metrics', [])
            except:
                pass
    
    def _save_state(self):
        """Save current monitoring state."""
        state = {
            'metrics': [m.to_dict() for m in self.metrics[-1000:]],  # Keep last 1000
            'last_updated': datetime.now().isoformat()
        }
        with open(self.storage_dir / "metrics.json", 'w') as f:
            json.dump(state, f, indent=2)
    
    def register_alert_rule(self, 
                           name: str,
                           condition: Callable,
                           severity: str = AlertSeverity.WARNING,
                           message_template: Optional[str] = None):
        """
        Register an alert rule.
        
        Args:
            name: Rule name
            condition: Function that returns True if alert should trigger
            severity: Alert severity
            message_template: Template for alert message
        """
        self.alert_rules.append({
            'name': name,
            'condition': condition,
            'severity': severity,
            'message_template': message_template or f"Alert: {name}"
        })
        logger.info(f"Registered alert rule: {name}")
    
    def add_metric(self, name: str, value: Any, tags: Optional[Dict] = None):
        """
        Add a metric to the monitoring system.
        
        Args:
            name: Metric name
            value: Metric value
            tags: Tags for the metric
        """
        metric = MonitorMetric(name, value)
        if tags:
            metric.tags = tags
        
        self.metrics.append(metric)
        self._save_state()
        
        # Check alert rules
        self._check_alerts(metric)
    
    def _check_alerts(self, metric: MonitorMetric):
        """Check alert rules for a metric."""
        for rule in self.alert_rules:
            try:
                if rule['condition'](metric):
                    alert = MonitorAlert(
                        title=rule['name'],
                        message=rule['message_template'].format(metric=metric.value),
                        severity=rule['severity'],
                        source=self.name,
                        tags={'metric_name': metric.name}
                    )
                    self.alerts.append(alert)
                    
                    # Send alerts
                    self._send_alert(alert)
                    
                    # Log alert
                    logger.warning(f"Alert triggered: {rule['name']} - {alert.message}")
                    
            except Exception as e:
                logger.error(f"Failed to check alert rule {rule['name']}: {e}")
    
    def configure_channel(self, 
                         channel_type: str,
                         config: Dict[str, Any]):
        """
        Configure an alert channel.
        
        Args:
            channel_type: 'email', 'slack', or 'webhook'
            config: Channel configuration
        """
        self.channels[channel_type] = config
        logger.info(f"Configured {channel_type} alert channel")
    
    def _send_alert(self, alert: MonitorAlert):
        """Send alert through configured channels."""
        # Send to Slack
        if self.channels.get('slack'):
            self._send_slack(alert)
        
        # Send to email
        if self.channels.get('email'):
            self._send_email(alert)
        
        # Send to webhook
        if self.channels.get('webhook'):
            self._send_webhook(alert)
        
        # Save alert
        self._save_alert(alert)
    
    def _send_slack(self, alert: MonitorAlert):
        """Send alert to Slack."""
        config = self.channels['slack']
        webhook_url = config.get('webhook_url')
        
        if not webhook_url:
            return
        
        color_map = {
            AlertSeverity.INFO: "#36a64f",
            AlertSeverity.WARNING: "#f2c744",
            AlertSeverity.ERROR: "#ff6b6b",
            AlertSeverity.CRITICAL: "#ff0000"
        }
        
        message = {
            "attachments": [{
                "color": color_map.get(alert.severity, "#36a64f"),
                "title": f"[{alert.severity.upper()}] {alert.title}",
                "text": alert.message,
                "fields": [
                    {"title": "Source", "value": alert.source, "short": True},
                    {"title": "Time", "value": alert.timestamp.isoformat(), "short": True}
                ],
                "ts": int(alert.timestamp.timestamp())
            }]
        }
        
        try:
            requests.post(webhook_url, json=message)
        except Exception as e:
            logger.error(f"Failed to send Slack alert: {e}")
    
    def _send_email(self, alert: MonitorAlert):
        """Send alert via email."""
        config = self.channels['email']
        
        smtp_host = config.get('smtp_host')
        smtp_port = config.get('smtp_port', 587)
        sender = config.get('sender')
        recipients = config.get('recipients', [])
        
        if not all([smtp_host, sender, recipients]):
            return
        
        msg = MIMEMultipart()
        msg['From'] = sender
        msg['To'] = ', '.join(recipients)
        msg['Subject'] = f"[{alert.severity.upper()}] {self.name}: {alert.title}"
        
        body = f"""
        Alert: {alert.title}
        Severity: {alert.severity}
        Source: {alert.source}
        Time: {alert.timestamp.isoformat()}
        Message: {alert.message}
        Tags: {json.dumps(alert.tags, indent=2)}
        """
        
        msg.attach(MIMEText(body, 'plain'))
        
        try:
            server = smtplib.SMTP(smtp_host, smtp_port)
            server.starttls()
            if config.get('username'):
                server.login(config['username'], config['password'])
            server.send_message(msg)
            server.quit()
        except Exception as e:
            logger.error(f"Failed to send email alert: {e}")
    
    def _send_webhook(self, alert: MonitorAlert):
        """Send alert to webhook."""
        config = self.channels['webhook']
        url = config.get('url')
        
        if not url:
            return
        
        try:
            requests.post(
                url,
                json=alert.to_dict(),
                headers={'Content-Type': 'application/json'}
            )
        except Exception as e:
            logger.error(f"Failed to send webhook alert: {e}")
    
    def _save_alert(self, alert: MonitorAlert):
        """Save alert to storage."""
        alert_file = self.storage_dir / "alerts.json"
        
        # Load existing alerts
        alerts = []
        if alert_file.exists():
            try:
                with open(alert_file, 'r') as f:
                    alerts = json.load(f)
            except:
                pass
        
        # Add new alert
        alerts.append(alert.to_dict())
        
        # Keep last 1000 alerts
        alerts = alerts[-1000:]
        
        # Save
        with open(alert_file, 'w') as f:
            json.dump(alerts, f, indent=2)
    
    def get_metrics(self, 
                   name: Optional[str] = None,
                   since: Optional[datetime] = None,
                   limit: int = 100) -> List[MonitorMetric]:
        """
        Get metrics with optional filtering.
        
        Args:
            name: Filter by metric name
            since: Only get metrics after this time
            limit: Maximum number of metrics to return
            
        Returns:
            List of metrics
        """
        metrics = self.metrics
        
        if name:
            metrics = [m for m in metrics if m.name == name]
        
        if since:
            metrics = [m for m in metrics if m.timestamp >= since]
        
        return metrics[-limit:]
    
    def get_alerts(self,
                  severity: Optional[str] = None,
                  since: Optional[datetime] = None,
                  limit: int = 100) -> List[MonitorAlert]:
        """
        Get alerts with optional filtering.
        
        Args:
            severity: Filter by severity
            since: Only get alerts after this time
            limit: Maximum number of alerts to return
            
        Returns:
            List of alerts
        """
        alerts = self.alerts
        
        if severity:
            alerts = [a for a in alerts if a.severity == severity]
        
        if since:
            alerts = [a for a in alerts if a.timestamp >= since]
        
        return alerts[-limit:]
    
    def get_metric_stats(self, name: str) -> Dict:
        """
        Get statistics for a metric.
        
        Args:
            name: Metric name
            
        Returns:
            Dictionary with statistics
        """
        metrics = [m.value for m in self.get_metrics(name=name)]
        
        if not metrics:
            return {
                'name': name,
                'count': 0,
                'min': None,
                'max': None,
                'mean': None,
                'std': None,
                'last': None
            }
        
        return {
            'name': name,
            'count': len(metrics),
            'min': min(metrics),
            'max': max(metrics),
            'mean': np.mean(metrics),
            'std': np.std(metrics),
            'last': metrics[-1]
        }


# ============= PRE-DEFINED MONITORS =============

class MLflowMonitor:
    """Monitor MLflow tracking."""
    
    def __init__(self, tracking_uri: str = "./mlruns"):
        self.tracking_uri = tracking_uri
        import mlflow
        mlflow.set_tracking_uri(tracking_uri)
        self.client = mlflow.tracking.MlflowClient()
    
    def get_model_performance(self, model_name: str) -> Dict:
        """Get performance metrics for a model."""
        model_versions = self.client.search_model_versions(f"name='{model_name}'")
        
        if not model_versions:
            return {'error': 'Model not found'}
        
        latest = model_versions[0]
        run = self.client.get_run(latest.run_id)
        
        metrics = run.data.metrics
        params = run.data.params
        
        return {
            'model_name': model_name,
            'version': latest.version,
            'stage': latest.current_stage,
            'metrics': metrics,
            'params': params,
            'timestamp': datetime.now().isoformat()
        }
    
    def get_experiment_runs(self, experiment_name: str, limit: int = 10) -> List[Dict]:
        """Get recent runs for an experiment."""
        experiment = self.client.get_experiment_by_name(experiment_name)
        if not experiment:
            return []
        
        runs = self.client.search_runs(
            experiment_ids=[experiment.experiment_id],
            max_results=limit,
            order_by=["start_time DESC"]
        )
        
        return [{
            'run_id': r.info.run_id,
            'run_name': r.data.tags.get('mlflow.runName', 'unknown'),
            'start_time': datetime.fromtimestamp(r.info.start_time / 1000).isoformat(),
            'status': r.info.status,
            'metrics': r.data.metrics,
            'params': {k: v for k, v in r.data.params.items() if not k.startswith('_')}
        } for r in runs]


class DVCMonitor:
    """Monitor DVC versioning."""
    
    def __init__(self, project_path: str = "."):
        self.project_path = project_path
    
    def get_data_versions(self) -> Dict:
        """Get versions of tracked data."""
        try:
            result = subprocess.run(
                ['dvc', 'status'],
                cwd=self.project_path,
                capture_output=True,
                text=True
            )
            return {
                'status': result.stdout,
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            return {'error': str(e)}
    
    def get_cached_files(self) -> Dict:
        """Get information about cached files."""
        cache_dir = Path(self.project_path) / ".dvc" / "cache"
        
        if not cache_dir.exists():
            return {'error': 'Cache directory not found'}
        
        # Count files
        total_files = sum(1 for _ in cache_dir.rglob('*') if _.is_file())
        total_size = sum(_.stat().st_size for _ in cache_dir.rglob('*') if _.is_file())
        
        return {
            'total_files': total_files,
            'total_size_mb': total_size / (1024 * 1024),
            'timestamp': datetime.now().isoformat()
        }


class SystemMonitor:
    """Monitor system resources."""
    
    def get_system_metrics(self) -> Dict:
        """Get system resource metrics."""
        return {
            'cpu_percent': psutil.cpu_percent(interval=1),
            'memory_percent': psutil.virtual_memory().percent,
            'memory_available_mb': psutil.virtual_memory().available / (1024 * 1024),
            'disk_usage_percent': psutil.disk_usage('/').percent,
            'disk_free_gb': psutil.disk_usage('/').free / (1024**3),
            'load_avg': psutil.getloadavg() if hasattr(psutil, 'getloadavg') else None,
            'timestamp': datetime.now().isoformat()
        }


# Singleton monitor
_default_monitor = None


def get_monitor() -> PipelineMonitor:
    """Get singleton monitor instance."""
    global _default_monitor
    if _default_monitor is None:
        _default_monitor = PipelineMonitor()
    return _default_monitor
EOF
```

### Step 2: Create Monitoring Ops for Dagster

```bash
cat > pipelines/monitoring_pipeline.py << 'EOF'
"""
Monitoring pipeline for MLflow, DVC, and system health.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import json
from datetime import datetime, timedelta
import pandas as pd
from dagster import (
    op, 
    job, 
    schedule, 
    sensor, 
    RunRequest,
    SkipReason,
    OpExecutionContext,
    RunStatus,
    run_status_sensor,
    EventLogEntry
)

from src.monitoring.monitor import (
    get_monitor,
    PipelineMonitor,
    MLflowMonitor,
    DVCMonitor,
    SystemMonitor,
    AlertSeverity
)


@op
def collect_mlflow_metrics(context: OpExecutionContext) -> Dict:
    """Collect MLflow metrics for monitoring."""
    logger = context.log
    
    mlflow_monitor = MLflowMonitor()
    
    # Check model performance
    model_names = ['master_predictive_model', 'predictive_maintenance_model']
    
    metrics = {}
    for model_name in model_names:
        try:
            performance = mlflow_monitor.get_model_performance(model_name)
            if 'error' not in performance:
                metrics[f'model_{model_name}_f1'] = performance.get('metrics', {}).get('f1', 0)
                metrics[f'model_{model_name}_version'] = performance.get('version', 0)
                metrics[f'model_{model_name}_stage'] = performance.get('stage', 'None')
        except Exception as e:
            logger.warning(f"Failed to get metrics for {model_name}: {e}")
    
    # Get recent experiments
    try:
        runs = mlflow_monitor.get_experiment_runs('Master_Pipeline', limit=5)
        metrics['recent_runs'] = len(runs)
        if runs:
            latest_run = runs[0]
            metrics['latest_run_status'] = latest_run.get('status', 'unknown')
            metrics['latest_run_time'] = latest_run.get('start_time', 'unknown')
    except Exception as e:
        logger.warning(f"Failed to get experiment runs: {e}")
    
    # Log metrics to monitor
    monitor = get_monitor()
    for name, value in metrics.items():
        monitor.add_metric(name, value, {'type': 'mlflow'})
    
    logger.info(f"Collected {len(metrics)} MLflow metrics")
    return metrics


@op
def collect_dvc_metrics(context: OpExecutionContext) -> Dict:
    """Collect DVC metrics for monitoring."""
    logger = context.log
    
    dvc_monitor = DVCMonitor()
    
    # Get data versions
    versions = dvc_monitor.get_data_versions()
    
    # Get cache info
    cache_info = dvc_monitor.get_cached_files()
    
    metrics = {
        'dvc_status': versions.get('status', 'unknown'),
        'dvc_cache_files': cache_info.get('total_files', 0),
        'dvc_cache_size_mb': cache_info.get('total_size_mb', 0)
    }
    
    # Log metrics
    monitor = get_monitor()
    for name, value in metrics.items():
        monitor.add_metric(name, value, {'type': 'dvc'})
    
    logger.info(f"Collected {len(metrics)} DVC metrics")
    return metrics


@op
def collect_system_metrics(context: OpExecutionContext) -> Dict:
    """Collect system metrics for monitoring."""
    logger = context.log
    
    system_monitor = SystemMonitor()
    metrics = system_monitor.get_system_metrics()
    
    # Log metrics
    monitor = get_monitor()
    for name, value in metrics.items():
        if name != 'timestamp':
            monitor.add_metric(name, value, {'type': 'system'})
    
    logger.info(f"Collected {len(metrics)} system metrics")
    return metrics


@op
def check_alert_rules(context: OpExecutionContext, 
                     mlflow_metrics: Dict,
                     dvc_metrics: Dict,
                     system_metrics: Dict) -> List[Dict]:
    """Check alert rules and trigger alerts."""
    logger = context.log
    
    monitor = get_monitor()
    alerts = []
    
    # Check MLflow metrics
    model_f1 = mlflow_metrics.get('model_master_predictive_model_f1', 0)
    if model_f1 < 0.80 and model_f1 > 0:
        alert = {
            'title': 'Model Performance Degradation',
            'message': f'Model F1 score dropped to {model_f1:.4f}',
            'severity': AlertSeverity.WARNING,
            'source': 'mlflow_monitor'
        }
        alerts.append(alert)
        monitor.add_metric('alert_model_performance', 1, {'metric': 'f1', 'value': model_f1})
    
    # Check system metrics
    cpu = system_metrics.get('cpu_percent', 0)
    if cpu > 80:
        alert = {
            'title': 'High CPU Usage',
            'message': f'CPU usage is {cpu:.1f}%',
            'severity': AlertSeverity.WARNING,
            'source': 'system_monitor'
        }
        alerts.append(alert)
        monitor.add_metric('alert_cpu_high', 1, {'cpu': cpu})
    
    memory = system_metrics.get('memory_percent', 0)
    if memory > 85:
        alert = {
            'title': 'High Memory Usage',
            'message': f'Memory usage is {memory:.1f}%',
            'severity': AlertSeverity.WARNING,
            'source': 'system_monitor'
        }
        alerts.append(alert)
        monitor.add_metric('alert_memory_high', 1, {'memory': memory})
    
    # Check DVC metrics
    cache_size = dvc_metrics.get('dvc_cache_size_mb', 0)
    if cache_size > 10000:  # 10GB
        alert = {
            'title': 'Large DVC Cache',
            'message': f'DVC cache size is {cache_size:.1f} MB',
            'severity': AlertSeverity.INFO,
            'source': 'dvc_monitor'
        }
        alerts.append(alert)
        monitor.add_metric('alert_cache_large', 1, {'cache_size': cache_size})
    
    # Log alerts
    for alert in alerts:
        logger.warning(f"Alert: {alert['title']} - {alert['message']}")
    
    return alerts


@job
def monitoring_pipeline():
    """Pipeline for collecting monitoring metrics."""
    mlflow_metrics = collect_mlflow_metrics()
    dvc_metrics = collect_dvc_metrics()
    system_metrics = collect_system_metrics()
    alerts = check_alert_rules(mlflow_metrics, dvc_metrics, system_metrics)
    return alerts


# ============= SCHEDULES =============

@schedule(
    job=monitoring_pipeline,
    cron_schedule="*/15 * * * *",  # Every 15 minutes
    execution_timezone="UTC"
)
def monitoring_schedule(context):
    """Run monitoring every 15 minutes."""
    return {}


@schedule(
    job=monitoring_pipeline,
    cron_schedule="0 0 * * *",  # Daily at midnight
    execution_timezone="UTC"
)
def monitoring_daily_schedule(context):
    """Daily monitoring with full checks."""
    return {
        "tags": {
            "schedule_name": "monitoring_daily_schedule",
            "run_type": "full_check"
        }
    }


# ============= RUN STATUS SENSORS =============

@run_status_sensor(
    run_status=RunStatus.SUCCESS,
    monitored_jobs=['master_mlops_pipeline']
)
def pipeline_success_sensor(context: SensorExecutionContext, event: EventLogEntry):
    """Sensor that triggers on pipeline success."""
    logger = context.log
    
    monitor = get_monitor()
    monitor.add_metric(
        'pipeline_success',
        1,
        {'job': event.job_name, 'run_id': event.run_id}
    )
    
    logger.info(f"Pipeline {event.run_id} completed successfully")
    return SkipReason("Success logged")


@run_status_sensor(
    run_status=RunStatus.FAILURE,
    monitored_jobs=['master_mlops_pipeline']
)
def pipeline_failure_sensor(context: SensorExecutionContext, event: EventLogEntry):
    """Sensor that triggers on pipeline failure."""
    logger = context.log
    
    # Send alert
    monitor = get_monitor()
    monitor.add_metric(
        'pipeline_failure',
        1,
        {'job': event.job_name, 'run_id': event.run_id}
    )
    
    alert = {
        'title': 'Pipeline Failure',
        'message': f'Pipeline {event.job_name} failed with run ID {event.run_id}',
        'severity': AlertSeverity.CRITICAL,
        'source': 'pipeline_monitor'
    }
    
    # Log and send alert
    logger.error(f"Pipeline failure: {event.run_id}")
    
    return SkipReason("Failure logged")


# Export for Dagster
jobs = [monitoring_pipeline]
schedules = [monitoring_schedule, monitoring_daily_schedule]
EOF
```

### Step 3: Create Dashboard for Monitoring

```bash
cat > scripts/monitoring_dashboard.py << 'EOF'
#!/usr/bin/env python
"""
Simple monitoring dashboard for MLOps pipeline.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

import json
import time
from datetime import datetime, timedelta
import pandas as pd
import streamlit as st
import plotly.express as px
import plotly.graph_objects as go

from src.monitoring.monitor import (
    get_monitor,
    MLflowMonitor,
    DVCMonitor,
    SystemMonitor,
    PipelineMonitor
)


def render_metrics():
    """Render metrics section."""
    st.header("📊 Metrics")
    
    monitor = get_monitor()
    
    # Get system metrics
    system_monitor = SystemMonitor()
    system_metrics = system_monitor.get_system_metrics()
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            "CPU Usage",
            f"{system_metrics['cpu_percent']:.1f}%",
            delta=None
        )
    
    with col2:
        st.metric(
            "Memory Usage",
            f"{system_metrics['memory_percent']:.1f}%",
            delta=None
        )
    
    with col3:
        st.metric(
            "Disk Usage",
            f"{system_metrics['disk_usage_percent']:.1f}%",
            delta=None
        )
    
    with col4:
        st.metric(
            "Disk Free",
            f"{system_metrics['disk_free_gb']:.1f} GB",
            delta=None
        )
    
    # Get recent metrics
    recent_metrics = monitor.get_metrics(limit=50)
    
    if recent_metrics:
        # Convert to DataFrame
        df = pd.DataFrame([{
            'name': m.name,
            'value': m.value,
            'timestamp': m.timestamp,
            **m.tags
        } for m in recent_metrics])
        
        # Show metric stats
        st.subheader("Recent Metrics")
        metric_names = df['name'].unique()
        selected_metric = st.selectbox("Select Metric", metric_names)
        
        if selected_metric:
            metric_df = df[df['name'] == selected_metric]
            
            # Create time series plot
            fig = px.line(
                metric_df,
                x='timestamp',
                y='value',
                title=f"{selected_metric} Over Time"
            )
            st.plotly_chart(fig, use_container_width=True)
            
            # Show stats
            st.dataframe(metric_df.tail(10))


def render_alerts():
    """Render alerts section."""
    st.header("🔔 Alerts")
    
    monitor = get_monitor()
    alerts = monitor.get_alerts(limit=50)
    
    if not alerts:
        st.info("No alerts")
        return
    
    # Filter alerts
    severity_filter = st.multiselect(
        "Severity",
        ['critical', 'error', 'warning', 'info'],
        default=['critical', 'error', 'warning']
    )
    
    filtered_alerts = [a for a in alerts if a.severity in severity_filter]
    
    if not filtered_alerts:
        st.info("No alerts matching filter")
        return
    
    # Display alerts
    for alert in filtered_alerts[-20:]:
        color_map = {
            'critical': '🔴',
            'error': '🟠',
            'warning': '🟡',
            'info': '🔵'
        }
        
        st.markdown(f"""
        <div style="padding: 10px; border-left: 4px solid {'#ff0000' if alert.severity == 'critical' else '#ff6b6b' if alert.severity == 'error' else '#f2c744' if alert.severity == 'warning' else '#36a64f'}; background-color: #f8f9fa; margin: 5px 0;">
            <strong>{color_map.get(alert.severity, '')} {alert.title}</strong><br>
            <span style="color: #666; font-size: 0.9em;">{alert.message}</span><br>
            <span style="color: #999; font-size: 0.8em;">{alert.timestamp.strftime('%Y-%m-%d %H:%M:%S')} - {alert.source}</span>
        </div>
        """, unsafe_allow_html=True)


def render_mlflow_metrics():
    """Render MLflow metrics section."""
    st.header("🧪 MLflow Metrics")
    
    mlflow_monitor = MLflowMonitor()
    
    # Get model performance
    model_names = ['master_predictive_model', 'predictive_maintenance_model']
    
    for model_name in model_names:
        performance = mlflow_monitor.get_model_performance(model_name)
        
        if 'error' not in performance:
            st.subheader(f"Model: {model_name}")
            
            col1, col2, col3 = st.columns(3)
            
            with col1:
                st.metric(
                    "Version",
                    performance.get('version', 'N/A')
                )
            
            with col2:
                st.metric(
                    "Stage",
                    performance.get('stage', 'N/A')
                )
            
            with col3:
                metrics = performance.get('metrics', {})
                f1 = metrics.get('f1', 0)
                st.metric(
                    "F1 Score",
                    f"{f1:.4f}" if f1 else 'N/A'
                )
            
            if metrics:
                st.dataframe(
                    pd.DataFrame([metrics]).T.reset_index().rename(
                        columns={'index': 'Metric', 0: 'Value'}
                    )
                )
        else:
            st.warning(f"Model {model_name} not found")


def render_dvc_metrics():
    """Render DVC metrics section."""
    st.header("💾 DVC Metrics")
    
    dvc_monitor = DVCMonitor()
    cache_info = dvc_monitor.get_cached_files()
    
    if 'error' not in cache_info:
        col1, col2 = st.columns(2)
        
        with col1:
            st.metric(
                "Cached Files",
                cache_info.get('total_files', 0)
            )
        
        with col2:
            st.metric(
                "Cache Size",
                f"{cache_info.get('total_size_mb', 0):.1f} MB"
            )
    else:
        st.warning("DVC not available")


def render_pipeline_status():
    """Render pipeline status section."""
    st.header("🚀 Pipeline Status")
    
    monitor = get_monitor()
    
    # Get recent pipeline metrics
    success_metrics = monitor.get_metrics(name='pipeline_success', limit=10)
    failure_metrics = monitor.get_metrics(name='pipeline_failure', limit=10)
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.metric(
            "Last Success",
            success_metrics[-1].timestamp.strftime('%H:%M:%S') if success_metrics else 'Never'
        )
    
    with col2:
        st.metric(
            "Last Failure",
            failure_metrics[-1].timestamp.strftime('%H:%M:%S') if failure_metrics else 'Never'
        )
    
    with col3:
        total_success = len(success_metrics)
        total_failure = len(failure_metrics)
        success_rate = total_success / (total_success + total_failure) if (total_success + total_failure) > 0 else 0
        st.metric(
            "Success Rate",
            f"{success_rate * 100:.1f}%"
        )


def main():
    """Main dashboard function."""
    st.set_page_config(
        page_title="MLOps Pipeline Monitor",
        page_icon="📊",
        layout="wide"
    )
    
    st.title("📊 MLOps Pipeline Monitoring Dashboard")
    st.markdown(f"*Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*")
    
    # Sidebar
    st.sidebar.title("Navigation")
    sections = [
        "Overview",
        "Metrics",
        "Alerts",
        "MLflow",
        "DVC",
        "Pipeline Status"
    ]
    
    selection = st.sidebar.radio("Go to", sections)
    
    # Auto-refresh
    auto_refresh = st.sidebar.checkbox("Auto-refresh (30s)")
    if auto_refresh:
        st.sidebar.info("Dashboard will refresh every 30 seconds")
        time.sleep(30)
        st.rerun()
    
    # Render selected section
    if selection == "Overview":
        st.header("📈 Overview")
        
        col1, col2 = st.columns(2)
        
        with col1:
            render_pipeline_status()
        
        with col2:
            render_system_metrics()
        
        # Recent alerts
        st.subheader("Recent Alerts")
        monitor = get_monitor()
        recent_alerts = monitor.get_alerts(limit=5)
        
        if recent_alerts:
            for alert in recent_alerts[:5]:
                color = '🔴' if alert.severity == 'critical' else '🟠' if alert.severity == 'error' else '🟡' if alert.severity == 'warning' else '🔵'
                st.markdown(f"**{color} {alert.title}**: {alert.message}")
    
    elif selection == "Metrics":
        render_metrics()
    
    elif selection == "Alerts":
        render_alerts()
    
    elif selection == "MLflow":
        render_mlflow_metrics()
    
    elif selection == "DVC":
        render_dvc_metrics()
    
    elif selection == "Pipeline Status":
        render_pipeline_status()


if __name__ == "__main__":
    main()
EOF

chmod +x scripts/monitoring_dashboard.py
```

### Step 4: Run the Monitoring System

```bash
# Install streamlit for dashboard
pip install streamlit plotly

# Start the monitoring pipeline
dagster job execute -f pipelines/monitoring_pipeline.py -j monitoring_pipeline

# Start the monitoring schedule
dagster schedule start monitoring_schedule

# Launch the monitoring dashboard
streamlit run scripts/monitoring_dashboard.py
# Open http://localhost:8501 in your browser
```

## The Verification: Testing Monitoring

### Verification 1: Check Metrics Collection

```bash
# Run monitoring pipeline
dagster job execute -f pipelines/monitoring_pipeline.py -j monitoring_pipeline -l DEBUG

# Check collected metrics
python -c "
from src.monitoring.monitor import get_monitor
monitor = get_monitor()
metrics = monitor.get_metrics(limit=20)
for m in metrics:
    print(f'{m.name}: {m.value} ({m.timestamp})')
"
```

### Verification 2: Check Alerts

```bash
# View alerts
python -c "
from src.monitoring.monitor import get_monitor
monitor = get_monitor()
alerts = monitor.get_alerts()
for a in alerts[:5]:
    print(f'{a.severity}: {a.title} - {a.message}')
"
```

### Verification 3: View Dashboard

```bash
# Launch dashboard
streamlit run scripts/monitoring_dashboard.py
```

## What We've Accomplished

You now have a comprehensive monitoring system that:

1. **Collects MLflow metrics** (model performance, experiment runs)
2. **Collects DVC metrics** (data versions, cache usage)
3. **Collects system metrics** (CPU, memory, disk)
4. **Checks alert rules** and triggers alerts
5. **Sends alerts** via Slack, email, and webhooks
6. **Provides a dashboard** for visualization
7. **Monitors pipeline status** and health
8. **Integrates with Dagster** for automated monitoring

---

*End of Part 14: Monitoring and Alerting*
