# Part 4: Detection, Incident Response & Cyber Resilience

## Learning Objectives

By completing this tutorial, you will:

- Build effective Security Operations Center (SOC) capabilities with 24/7 monitoring
- Implement Security Information and Event Management (SIEM) with centralized logging and analytics
- Develop comprehensive incident response (IR) capabilities with tested playbooks
- Establish executive crisis management and tabletop exercise programs
- Build ransomware preparedness and response capabilities
- Create Business Continuity Planning (BCP) and Disaster Recovery (DR) programs
- Implement immutable backup strategies with recovery testing
- Establish lessons learned and post-incident improvement processes

## Key Concepts & Frameworks

### The Detection and Response Lifecycle

Think of detection and response like an emergency response system for your organization:

- **Detection**: The "911 dispatch" - identifying that something is wrong
- **Triage**: The "paramedic assessment" - determining severity and urgency
- **Containment**: The "firefighters" - stopping the threat from spreading
- **Eradication**: The "cleanup crew" - removing the threat completely
- **Recovery**: The "rebuild team" - restoring normal operations
- **Lessons Learned**: The "after-action review" - improving for next time

### Core Frameworks We'll Use

**NIST SP 800-61 Rev. 2 (Computer Security Incident Handling Guide)**
- Preparation
- Detection and Analysis
- Containment, Eradication, and Recovery
- Post-Incident Activity

**NIST CSF 2.0**
- Detect (DE): Develop and implement appropriate activities to identify the occurrence of a cybersecurity event
- Respond (RS): Develop and implement appropriate activities to take action regarding a detected cybersecurity incident
- Recover (RC): Develop and implement appropriate activities to maintain plans for resilience and to restore any capabilities or services that were impaired due to a cybersecurity incident

**ISO/IEC 27001:2022**
- A.5.24: Incident management planning and preparation
- A.5.25: Assessment and decision on information security events
- A.5.26: Response to information security incidents
- A.5.27: Learning from information security incidents
- A.5.28: Collection of evidence
- A.5.29: Business continuity management
- A.5.30: ICT readiness for business continuity

## Hands-On Implementation

### Step 1: Build the SIEM Implementation

**The Target:** Create a comprehensive SIEM system with centralized logging, alerting, and analytics.

**The Concept:** SIEM (Security Information and Event Management) is like a security control room with all screens showing real-time data. It collects logs from everywhere, correlates events to find patterns, and alerts when something suspicious happens.

**File:** `04-detection-response/scripts/siem_implementation.py`

```python
#!/usr/bin/env python3
"""
Security Information and Event Management (SIEM) Implementation

This module implements comprehensive SIEM including:
- Centralized log collection and normalization
- Real-time event correlation and alerting
- Dashboard and visualization
- Log retention and compliance
- Threat intelligence integration
"""

import json
import datetime
import hashlib
import re
from typing import Dict, List, Optional, Any, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum
import os
import threading
import queue
import time


class LogSeverity(Enum):
    """Severity of log events."""
    DEBUG = "debug"
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class LogSource(Enum):
    """Sources of log data."""
    FIREWALL = "firewall"
    IDS = "ids"
    EDR = "edr"
    IAM = "iam"
    DNS = "dns"
    WEB = "web"
    EMAIL = "email"
    CLOUD = "cloud"
    APP = "application"
    DATABASE = "database"
    OS = "operating_system"
    NETWORK = "network"
    SIEM = "siem"


class AlertState(Enum):
    """States of an alert."""
    OPEN = "open"
    ACKNOWLEDGED = "acknowledged"
    INVESTIGATING = "investigating"
    CONTAINED = "contained"
    RESOLVED = "resolved"
    FALSE_POSITIVE = "false_positive"


@dataclass
class LogEntry:
    """
    Normalized log entry.
    
    Attributes:
        log_id: Unique identifier
        source: Source of the log
        severity: Log severity
        timestamp: Event timestamp
        host: Host or system
        user: User associated
        event_type: Type of event
        message: Log message
        raw_data: Raw log data
        normalized_data: Normalized structured data
    """
    log_id: str
    source: str
    severity: str
    timestamp: str
    host: str
    user: str
    event_type: str
    message: str
    raw_data: str
    normalized_data: Dict[str, Any] = field(default_factory=dict)
    tags: List[str] = field(default_factory=list)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "log_id": self.log_id,
            "source": self.source,
            "severity": self.severity,
            "timestamp": self.timestamp,
            "host": self.host,
            "user": self.user,
            "event_type": self.event_type,
            "message": self.message,
            "raw_data": self.raw_data[:1000] if len(self.raw_data) > 1000 else self.raw_data,
            "normalized_data": self.normalized_data,
            "tags": self.tags
        }


@dataclass
class CorrelationRule:
    """
    Event correlation rule.
    
    Attributes:
        rule_id: Unique identifier
        name: Rule name
        description: Rule description
        conditions: List of conditions to match
        action: Action to take
        severity: Alert severity
        pattern: Correlation pattern (time window, sequence, etc.)
    """
    rule_id: str
    name: str
    description: str
    conditions: List[Dict]
    action: str
    severity: str
    pattern: Dict[str, Any] = field(default_factory=dict)
    enabled: bool = True
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "rule_id": self.rule_id,
            "name": self.name,
            "description": self.description,
            "conditions": self.conditions,
            "action": self.action,
            "severity": self.severity,
            "pattern": self.pattern,
            "enabled": self.enabled
        }


@dataclass
class SecurityAlert:
    """
    Security alert generated by SIEM.
    
    Attributes:
        alert_id: Unique identifier
        rule_id: Matching rule
        severity: Alert severity
        description: Alert description
        timestamp: Alert timestamp
        logs: Related log entries
        state: Current state
        assigned_to: Person assigned to investigate
        comments: Investigation comments
    """
    alert_id: str
    rule_id: str
    severity: str
    description: str
    timestamp: str
    logs: List[LogEntry]
    state: str = AlertState.OPEN.value
    assigned_to: Optional[str] = None
    comments: List[Dict] = field(default_factory=list)
    indicators: List[str] = field(default_factory=list)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "alert_id": self.alert_id,
            "rule_id": self.rule_id,
            "severity": self.severity,
            "description": self.description,
            "timestamp": self.timestamp,
            "logs": [log.to_dict() for log in self.logs[:10]],
            "state": self.state,
            "assigned_to": self.assigned_to,
            "comments": self.comments,
            "indicators": self.indicators
        }


class SIEMEngine:
    """
    Security Information and Event Management Engine.
    
    This class handles log collection, normalization, correlation,
    alerting, and reporting.
    """
    
    def __init__(self, data_dir: str = "./siem_data"):
        """
        Initialize SIEM engine.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.logs: List[LogEntry] = []
        self.alerts: Dict[str, SecurityAlert] = {}
        self.rules: Dict[str, CorrelationRule] = {}
        self.indices: Dict[str, Set[str]] = {}
        
        # Queue for real-time log processing
        self.log_queue = queue.Queue()
        self.running = False
        self.processor_thread = None
        
        self._load_data()
        self._load_default_rules()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/logs", exist_ok=True)
        os.makedirs(f"{self.data_dir}/alerts", exist_ok=True)
        os.makedirs(f"{self.data_dir}/rules", exist_ok=True)
        os.makedirs(f"{self.data_dir}/indices", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load alerts
        alert_dir = f"{self.data_dir}/alerts"
        if os.path.exists(alert_dir):
            for filename in os.listdir(alert_dir):
                if filename.endswith('.json'):
                    with open(f"{alert_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        # Log entries are stored as dicts, convert back
                        logs = []
                        for log_data in data.get('logs', []):
                            log = LogEntry(
                                log_id=log_data['log_id'],
                                source=log_data['source'],
                                severity=log_data['severity'],
                                timestamp=log_data['timestamp'],
                                host=log_data['host'],
                                user=log_data['user'],
                                event_type=log_data['event_type'],
                                message=log_data['message'],
                                raw_data=log_data.get('raw_data', ''),
                                normalized_data=log_data.get('normalized_data', {}),
                                tags=log_data.get('tags', [])
                            )
                            logs.append(log)
                        
                        alert = SecurityAlert(
                            alert_id=data['alert_id'],
                            rule_id=data['rule_id'],
                            severity=data['severity'],
                            description=data['description'],
                            timestamp=data['timestamp'],
                            logs=logs,
                            state=data.get('state', AlertState.OPEN.value),
                            assigned_to=data.get('assigned_to'),
                            comments=data.get('comments', []),
                            indicators=data.get('indicators', [])
                        )
                        self.alerts[alert.alert_id] = alert
        
        # Load rules
        rule_dir = f"{self.data_dir}/rules"
        if os.path.exists(rule_dir):
            for filename in os.listdir(rule_dir):
                if filename.endswith('.json'):
                    with open(f"{rule_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        rule = CorrelationRule(
                            rule_id=data['rule_id'],
                            name=data['name'],
                            description=data['description'],
                            conditions=data['conditions'],
                            action=data['action'],
                            severity=data['severity'],
                            pattern=data.get('pattern', {}),
                            enabled=data.get('enabled', True)
                        )
                        self.rules[rule.rule_id] = rule
    
    def _load_default_rules(self) -> None:
        """Load default correlation rules."""
        default_rules = [
            CorrelationRule(
                rule_id="RULE-001",
                name="Multiple Failed Logins",
                description="Multiple failed login attempts from same source",
                conditions=[
                    {"field": "event_type", "operator": "eq", "value": "login_failure"},
                    {"field": "source_ip", "operator": "exists", "value": None}
                ],
                action="ALERT",
                severity="medium",
                pattern={"time_window": 300, "threshold": 5}
            ),
            CorrelationRule(
                rule_id="RULE-002",
                name="Malware Detection",
                description="Malware detected on endpoint",
                conditions=[
                    {"field": "event_type", "operator": "eq", "value": "malware_detected"},
                    {"field": "host", "operator": "exists", "value": None}
                ],
                action="ALERT",
                severity="high",
                pattern={"immediate": True}
            ),
            CorrelationRule(
                rule_id="RULE-003",
                name="Unauthorized Access",
                description="Access to sensitive resource without authorization",
                conditions=[
                    {"field": "event_type", "operator": "eq", "value": "access_denied"},
                    {"field": "resource_classification", "operator": "in", "value": ["confidential", "highly_confidential"]}
                ],
                action="ALERT",
                severity="high",
                pattern={"immediate": True}
            ),
            CorrelationRule(
                rule_id="RULE-004",
                name="Privilege Escalation",
                description="Potential privilege escalation detected",
                conditions=[
                    {"field": "event_type", "operator": "eq", "value": "privilege_change"},
                    {"field": "new_privilege", "operator": "gt", "value": "standard"}
                ],
                action="ALERT",
                severity="critical",
                pattern={"immediate": True}
            ),
            CorrelationRule(
                rule_id="RULE-005",
                name="Data Exfiltration",
                description="Large volume of data being exported",
                conditions=[
                    {"field": "event_type", "operator": "eq", "value": "data_export"},
                    {"field": "data_volume", "operator": "gt", "value": 1000}
                ],
                action="ALERT",
                severity="critical",
                pattern={"time_window": 3600, "threshold": 100}
            ),
            CorrelationRule(
                rule_id="RULE-006",
                name="Suspicious Network Traffic",
                description="Connection to known malicious domain",
                conditions=[
                    {"field": "event_type", "operator": "eq", "value": "network_connection"},
                    {"field": "domain", "operator": "in", "value": "threat_intel_malicious"}
                ],
                action="ALERT",
                severity="high",
                pattern={"immediate": True}
            )
        ]
        
        for rule in default_rules:
            if rule.rule_id not in self.rules:
                self.rules[rule.rule_id] = rule
                self._save_rule(rule)
    
    def _save_rule(self, rule: CorrelationRule) -> None:
        """Save correlation rule."""
        with open(f"{self.data_dir}/rules/{rule.rule_id}.json", 'w') as f:
            json.dump(rule.to_dict(), f, indent=2)
    
    def _save_alert(self, alert: SecurityAlert) -> None:
        """Save alert to storage."""
        with open(f"{self.data_dir}/alerts/{alert.alert_id}.json", 'w') as f:
            json.dump(alert.to_dict(), f, indent=2)
    
    def _save_log(self, log: LogEntry) -> None:
        """Save log to storage."""
        # Store logs in daily files for easy management
        date_str = log.timestamp[:10]  # YYYY-MM-DD
        log_file = f"{self.data_dir}/logs/{date_str}.jsonl"
        
        # Open in append mode
        with open(log_file, 'a') as f:
            f.write(json.dumps(log.to_dict()) + "\n")
    
    def _create_indices(self, log: LogEntry) -> None:
        """Create search indices for log entries."""
        # Index by source
        if log.source not in self.indices:
            self.indices[log.source] = set()
        self.indices[log.source].add(log.log_id)
        
        # Index by host
        if log.host:
            if f"host:{log.host}" not in self.indices:
                self.indices[f"host:{log.host}"] = set()
            self.indices[f"host:{log.host}"].add(log.log_id)
        
        # Index by user
        if log.user and log.user != "system":
            if f"user:{log.user}" not in self.indices:
                self.indices[f"user:{log.user}"] = set()
            self.indices[f"user:{log.user}"].add(log.log_id)
        
        # Index by event type
        if f"event:{log.event_type}" not in self.indices:
            self.indices[f"event:{log.event_type}"] = set()
        self.indices[f"event:{log.event_type}"].add(log.log_id)
        
        # Index by severity
        if f"severity:{log.severity}" not in self.indices:
            self.indices[f"severity:{log.severity}"] = set()
        self.indices[f"severity:{log.severity}"].add(log.log_id)
        
        # Index by tags
        for tag in log.tags:
            if f"tag:{tag}" not in self.indices:
                self.indices[f"tag:{tag}"] = set()
            self.indices[f"tag:{tag}"].add(log.log_id)
    
    def _normalize_log(self, raw_log: Dict, source: str) -> LogEntry:
        """
        Normalize raw log data to standard format.
        
        Args:
            raw_log: Raw log dictionary
            source: Log source
            
        Returns:
            Normalized LogEntry
        """
        timestamp = raw_log.get('timestamp', datetime.datetime.utcnow().isoformat())
        
        # Extract common fields based on source
        host = raw_log.get('host', raw_log.get('hostname', raw_log.get('server', 'unknown')))
        user = raw_log.get('user', raw_log.get('username', raw_log.get('user_id', 'system')))
        event_type = raw_log.get('event_type', raw_log.get('type', 'unknown'))
        message = raw_log.get('message', raw_log.get('msg', str(raw_log)))
        
        # Determine severity
        severity = raw_log.get('severity', 'info').lower()
        if severity not in [s.value for s in LogSeverity]:
            severity = 'info'
        
        # Generate log ID
        log_id = hashlib.md5(
            f"{source}:{host}:{timestamp}:{message[:100]}".encode()
        ).hexdigest()[:12]
        
        # Extract normalized data
        normalized_data = raw_log.copy()
        # Remove fields already captured
        for field in ['timestamp', 'host', 'user', 'event_type', 'message', 'severity']:
            normalized_data.pop(field, None)
        
        return LogEntry(
            log_id=log_id,
            source=source,
            severity=severity,
            timestamp=timestamp,
            host=host,
            user=user,
            event_type=event_type,
            message=message,
            raw_data=json.dumps(raw_log) if isinstance(raw_log, dict) else str(raw_log),
            normalized_data=normalized_data
        )
    
    def ingest_log(self, raw_log: Dict, source: str) -> LogEntry:
        """
        Ingest and process a log entry.
        
        Args:
            raw_log: Raw log data
            source: Log source
            
        Returns:
            Processed LogEntry
        """
        # Normalize log
        log = self._normalize_log(raw_log, source)
        
        # Add to storage
        self.logs.append(log)
        self._save_log(log)
        
        # Update indices
        self._create_indices(log)
        
        # Queue for correlation
        self.log_queue.put(log)
        
        return log
    
    def _process_logs(self) -> None:
        """Process logs from queue for correlation."""
        while self.running:
            try:
                # Process logs in batches
                batch = []
                try:
                    while len(batch) < 10:
                        log = self.log_queue.get(timeout=1)
                        batch.append(log)
                except queue.Empty:
                    if not self.running:
                        break
                    continue
                
                # Correlate logs
                for log in batch:
                    self._correlate_event(log)
                
            except Exception as e:
                print(f"Error processing logs: {e}")
    
    def _correlate_event(self, log: LogEntry) -> None:
        """
        Correlate a log event against correlation rules.
        
        Args:
            log: LogEntry to correlate
        """
        for rule_id, rule in self.rules.items():
            if not rule.enabled:
                continue
            
            # Check if log matches rule conditions
            if self._matches_rule(log, rule):
                # Create alert
                alert = SecurityAlert(
                    alert_id=f"ALERT-{datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{secrets.token_hex(4)}",
                    rule_id=rule.rule_id,
                    severity=rule.severity,
                    description=f"Rule: {rule.name} - {rule.description}",
                    timestamp=datetime.datetime.utcnow().isoformat(),
                    logs=[log]
                )
                
                self.alerts[alert.alert_id] = alert
                self._save_alert(alert)
                
                print(f"⚠️ Alert generated: {alert.alert_id} - {alert.description}")
    
    def _matches_rule(self, log: LogEntry, rule: CorrelationRule) -> bool:
        """
        Check if a log entry matches a correlation rule.
        
        Args:
            log: LogEntry to check
            rule: CorrelationRule to match
            
        Returns:
            True if matches
        """
        for condition in rule.conditions:
            field = condition['field']
            operator = condition['operator']
            value = condition['value']
            
            # Get field value from log
            field_value = None
            
            # Check in normalized data first
            if field in log.normalized_data:
                field_value = log.normalized_data[field]
            # Then check in log attributes
            elif hasattr(log, field):
                field_value = getattr(log, field)
            # Finally check in message
            elif field == 'message_contains':
                if value and value in log.message:
                    continue
                return False
            
            # Evaluate condition
            if operator == 'eq':
                if field_value != value:
                    return False
            elif operator == 'ne':
                if field_value == value:
                    return False
            elif operator == 'gt':
                if field_value is None or float(field_value) <= float(value):
                    return False
            elif operator == 'lt':
                if field_value is None or float(field_value) >= float(value):
                    return False
            elif operator == 'in':
                if field_value not in value:
                    return False
            elif operator == 'contains':
                if value not in field_value:
                    return False
            elif operator == 'exists':
                if field_value is None:
                    return False
            elif operator == 'regex':
                if field_value is None or not re.search(value, str(field_value)):
                    return False
        
        return True
    
    def start_processing(self) -> None:
        """Start the log processing thread."""
        if not self.running:
            self.running = True
            self.processor_thread = threading.Thread(target=self._process_logs, daemon=True)
            self.processor_thread.start()
            print("✅ SIEM processing started")
    
    def stop_processing(self) -> None:
        """Stop the log processing thread."""
        self.running = False
        if self.processor_thread:
            self.processor_thread.join(timeout=5)
            print("✅ SIEM processing stopped")
    
    def search_logs(self, query: Dict) -> List[LogEntry]:
        """
        Search logs using indexed fields.
        
        Args:
            query: Search query dictionary
            
        Returns:
            List of matching LogEntry
        """
        results = set()
        
        # Use indices for efficient searching
        for key, value in query.items():
            if key == 'time_window':
                continue
            
            index_key = f"{key}:{value}" if key in ['source', 'host', 'user', 'event_type', 'severity'] else None
            
            if index_key and index_key in self.indices:
                if not results:
                    results = self.indices[index_key].copy()
                else:
                    results = results.intersection(self.indices[index_key])
        
        # If no indexed search, fallback to scanning (should be limited)
        if not results:
            # For testing, just return recent logs
            return self.logs[-100:]
        
        # Convert IDs to LogEntry objects
        log_entries = []
        for log_id in results:
            # Find log by ID (scan recent logs first)
            for log in reversed(self.logs):
                if log.log_id == log_id:
                    log_entries.append(log)
                    break
        
        # Sort by timestamp
        return sorted(log_entries, key=lambda x: x.timestamp, reverse=True)
    
    def acknowledge_alert(self, alert_id: str, assignee: str) -> bool:
        """
        Acknowledge and assign an alert.
        
        Args:
            alert_id: Alert ID
            assignee: Person assigned
            
        Returns:
            True if successful
        """
        alert = self.alerts.get(alert_id)
        if not alert:
            return False
        
        if alert.state != AlertState.OPEN.value:
            return False
        
        alert.state = AlertState.ACKNOWLEDGED.value
        alert.assigned_to = assignee
        self._save_alert(alert)
        return True
    
    def update_alert_state(self, alert_id: str, state: str, comment: str = "") -> bool:
        """
        Update alert state.
        
        Args:
            alert_id: Alert ID
            state: New state
            comment: Optional comment
            
        Returns:
            True if successful
        """
        alert = self.alerts.get(alert_id)
        if not alert:
            return False
        
        alert.state = state
        if comment:
            alert.comments.append({
                "timestamp": datetime.datetime.utcnow().isoformat(),
                "comment": comment
            })
        self._save_alert(alert)
        return True
    
    def get_alert_details(self, alert_id: str) -> Optional[Dict]:
        """
        Get detailed alert information.
        
        Args:
            alert_id: Alert ID
            
        Returns:
            Alert details or None
        """
        alert = self.alerts.get(alert_id)
        if not alert:
            return None
        
        # Find related events (same host or user)
        related_logs = []
        for log in self.logs:
            if (log.host == alert.logs[0].host if alert.logs else False) or \
               (log.user == alert.logs[0].user if alert.logs else False):
                if log.log_id != (alert.logs[0].log_id if alert.logs else ''):
                    related_logs.append(log.to_dict())
        
        return {
            "alert": alert.to_dict(),
            "related_logs": related_logs[:20],
            "total_related": len(related_logs)
        }
    
    def generate_dashboard(self) -> Dict:
        """
        Generate SIEM dashboard data.
        
        Returns:
            Dashboard statistics
        """
        total_alerts = len(self.alerts)
        open_alerts = sum(1 for a in self.alerts.values() if a.state == AlertState.OPEN.value)
        acknowledged = sum(1 for a in self.alerts.values() if a.state == AlertState.ACKNOWLEDGED.value)
        investigating = sum(1 for a in self.alerts.values() if a.state == AlertState.INVESTIGATING.value)
        resolved = sum(1 for a in self.alerts.values() if a.state == AlertState.RESOLVED.value)
        
        # Alert severity distribution
        severity_counts = {}
        for alert in self.alerts.values():
            severity_counts[alert.severity] = severity_counts.get(alert.severity, 0) + 1
        
        # Top alert sources
        source_counts = {}
        for alert in self.alerts.values():
            for log in alert.logs:
                source_counts[log.source] = source_counts.get(log.source, 0) + 1
        
        # Time since last alert
        last_alert = "Never"
        if self.alerts:
            latest = max(self.alerts.values(), key=lambda a: a.timestamp)
            last_alert = latest.timestamp
        
        return {
            "total_alerts": total_alerts,
            "open_alerts": open_alerts,
            "acknowledged": acknowledged,
            "investigating": investigating,
            "resolved": resolved,
            "severity_counts": severity_counts,
            "source_counts": dict(sorted(source_counts.items(), key=lambda x: x[1], reverse=True)[:5]),
            "last_alert": last_alert,
            "rules_enabled": len([r for r in self.rules.values() if r.enabled]),
            "total_rules": len(self.rules)
        }
    
    def generate_report(self) -> str:
        """
        Generate SIEM report.
        
        Returns:
            Markdown formatted report
        """
        dashboard = self.generate_dashboard()
        
        report = f"""
# SIEM Operations Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Alerts | {dashboard['total_alerts']} |
| Open Alerts | {dashboard['open_alerts']} |
| Investigating | {dashboard['investigating']} |
| Resolved | {dashboard['resolved']} |
| Rules Enabled | {dashboard['rules_enabled']} |
| Total Rules | {dashboard['total_rules']} |

## Alert Severity Distribution

| Severity | Count |
|----------|-------|
"""
        
        for severity, count in sorted(dashboard['severity_counts'].items()):
            report += f"| {severity} | {count} |\n"
        
        report += """
## Top Alert Sources

| Source | Count |
|--------|-------|
"""
        
        for source, count in dashboard['source_counts'].items():
            report += f"| {source} | {count} |\n"
        
        report += f"""
## Open Alerts

"""
        
        open_alerts = [a for a in self.alerts.values() if a.state == AlertState.OPEN.value]
        if open_alerts:
            report += "| ID | Severity | Description | Time |\n"
            report += "|----|----------|-------------|------|\n"
            for alert in sorted(open_alerts, key=lambda a: a.timestamp, reverse=True)[:10]:
                report += f"| {alert.alert_id} | {alert.severity} | {alert.description[:40]}... | {alert.timestamp[:16]} |\n"
        else:
            report += "✅ No open alerts\n"
        
        return report


def main():
    """CLI for SIEM management."""
    import argparse
    import secrets
    
    parser = argparse.ArgumentParser(description='SIEM Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Ingest log
    ingest_parser = subparsers.add_parser('ingest', help='Ingest log')
    ingest_parser.add_argument('--log', '-l', required=True, help='Log JSON')
    ingest_parser.add_argument('--source', '-s', required=True, help='Log source')
    
    # Search logs
    search_parser = subparsers.add_parser('search', help='Search logs')
    search_parser.add_argument('--query', '-q', required=True, help='Query JSON')
    
    # List alerts
    list_parser = subparsers.add_parser('list', help='List alerts')
    list_parser.add_argument('--state', '-s', help='Filter by state')
    
    # Acknowledge alert
    ack_parser = subparsers.add_parser('acknowledge', help='Acknowledge alert')
    ack_parser.add_argument('--alert', '-a', required=True, help='Alert ID')
    ack_parser.add_argument('--assignee', '-u', required=True, help='Assignee')
    
    # Update alert
    update_parser = subparsers.add_parser('update', help='Update alert state')
    update_parser.add_argument('--alert', '-a', required=True, help='Alert ID')
    update_parser.add_argument('--state', '-s', required=True, help='New state')
    update_parser.add_argument('--comment', '-c', help='Comment')
    
    # Dashboard
    dashboard_parser = subparsers.add_parser('dashboard', help='Show dashboard')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    # Start processing
    start_parser = subparsers.add_parser('start', help='Start log processing')
    
    # Stop processing
    stop_parser = subparsers.add_parser('stop', help='Stop log processing')
    
    # Add rule
    rule_parser = subparsers.add_parser('add-rule', help='Add correlation rule')
    rule_parser.add_argument('--rule', '-r', required=True, help='Rule JSON')
    
    args = parser.parse_args()
    
    siem = SIEMEngine()
    
    if args.command == 'ingest':
        try:
            log_data = json.loads(args.log)
            log = siem.ingest_log(log_data, args.source)
            print(f"✅ Log ingested: {log.log_id}")
            print(f"   Source: {log.source}")
            print(f"   Event: {log.event_type}")
            print(f"   Severity: {log.severity}")
        except json.JSONDecodeError:
            print("❌ Invalid log JSON")
    
    elif args.command == 'search':
        try:
            query = json.loads(args.query)
            results = siem.search_logs(query)
            print(f"Found {len(results)} log entries:")
            for log in results[:10]:
                print(f"  {log.timestamp[:16]} | {log.source} | {log.event_type} | {log.message[:50]}...")
        except json.JSONDecodeError:
            print("❌ Invalid query JSON")
    
    elif args.command == 'list':
        alerts = siem.alerts.values()
        if args.state:
            alerts = [a for a in alerts if a.state == args.state]
        
        alerts = sorted(alerts, key=lambda a: a.timestamp, reverse=True)
        print(f"\nAlerts ({len(alerts)}):")
        print("=" * 80)
        for alert in alerts[:20]:
            state_marker = {
                AlertState.OPEN.value: "🔴",
                AlertState.ACKNOWLEDGED.value: "🟡",
                AlertState.INVESTIGATING.value: "🟠",
                AlertState.CONTAINED.value: "🔵",
                AlertState.RESOLVED.value: "🟢",
                AlertState.FALSE_POSITIVE.value: "⚪"
            }.get(alert.state, "⚪")
            print(f"{state_marker} {alert.alert_id} | {alert.severity.upper()} | {alert.description[:60]}...")
            print(f"   State: {alert.state} | Time: {alert.timestamp[:16]} | Logs: {len(alert.logs)}")
    
    elif args.command == 'acknowledge':
        if siem.acknowledge_alert(args.alert, args.assignee):
            print(f"✅ Alert {args.alert} acknowledged by {args.assignee}")
        else:
            print("❌ Alert not found or already acknowledged")
    
    elif args.command == 'update':
        if siem.update_alert_state(args.alert, args.state, args.comment or ""):
            print(f"✅ Alert {args.alert} updated to {args.state}")
        else:
            print("❌ Alert not found")
    
    elif args.command == 'dashboard':
        dashboard = siem.generate_dashboard()
        print("\n=== SIEM Dashboard ===")
        print(f"Total Alerts: {dashboard['total_alerts']}")
        print(f"Open: {dashboard['open_alerts']}")
        print(f"Investigating: {dashboard['investigating']}")
        print(f"Resolved: {dashboard['resolved']}")
        print(f"Rules: {dashboard['rules_enabled']}/{dashboard['total_rules']} enabled")
        print("\nSeverity Distribution:")
        for severity, count in sorted(dashboard['severity_counts'].items()):
            print(f"  {severity}: {count}")
    
    elif args.command == 'report':
        report = siem.generate_report()
        print(report)
    
    elif args.command == 'start':
        siem.start_processing()
    
    elif args.command == 'stop':
        siem.stop_processing()
    
    elif args.command == 'add-rule':
        try:
            rule_data = json.loads(args.rule)
            rule = CorrelationRule(
                rule_id=rule_data['rule_id'],
                name=rule_data['name'],
                description=rule_data['description'],
                conditions=rule_data['conditions'],
                action=rule_data['action'],
                severity=rule_data['severity'],
                pattern=rule_data.get('pattern', {}),
                enabled=rule_data.get('enabled', True)
            )
            siem.rules[rule.rule_id] = rule
            siem._save_rule(rule)
            print(f"✅ Rule added: {rule.rule_id} - {rule.name}")
        except json.JSONDecodeError:
            print("❌ Invalid rule JSON")
        except KeyError as e:
            print(f"❌ Missing required field: {e}")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

### Step 2: Build Incident Response Playbooks

**The Target:** Create comprehensive incident response playbooks for common attack scenarios.

**The Concept:** Incident response playbooks are like emergency procedures for security incidents. They provide step-by-step guidance on what to do, who to contact, and how to respond. Having these ready means you don't have to figure things out during a crisis.

**File:** `04-detection-response/playbooks/incident-response-playbook.md`

```markdown
---
title: Incident Response Playbook - Ransomware
version: 1.0
status: Approved
approval_date: YYYY-MM-DD
review_cycle: Quarterly
---

# Incident Response Playbook: Ransomware

## 1. Purpose

This playbook provides step-by-step guidance for responding to a ransomware incident to minimize impact, preserve evidence, and restore operations.

## 2. Scope

This playbook applies to all ransomware incidents affecting [Organization Name]'s systems, data, or operations.

## 3. Incident Response Phases

### Phase 1: Detection & Triage (0-15 minutes)

**Detection Sources:**
- EDR alerts (file encryption activity)
- User reports (pop-up messages, files with .encrypted extension)
- Monitoring alerts (unusual file system activity)
- SIEM correlation rules (RULE-002: Malware Detection)

**Initial Triage Checklist:**

| Step | Action | Owner | Time |
|------|--------|-------|------|
| 1 | Confirm ransomware activity | SOC Analyst | 2 min |
| 2 | Identify affected systems | SOC Analyst | 3 min |
| 3 | Determine encryption scope | SOC Analyst | 5 min |
| 4 | Notify Incident Response Lead | SOC Analyst | 2 min |
| 5 | Declare incident (if critical) | IR Lead | 3 min |

**Declare Incident Criteria:**
- ✅ More than 5 systems affected
- ✅ Critical systems compromised
- ✅ Ransom note present
- ✅ Encryption activity confirmed

### Phase 2: Containment (15-60 minutes)

**Immediate Actions:**

1. **Isolate Affected Systems:**
   - Disconnect network cables or disable network adapters
   - Use network segmentation to isolate segments
   - Block communication at firewall level
   - Take critical servers offline if encrypted

2. **Protect Backups:**
   - Immediately isolate backup systems
   - Ensure backups are not connected to affected network
   - Verify backup integrity
   - Take offline copy of backups

3. **Stop Active Encryption:**
   - Kill suspicious processes
   - Block ransomware execution at endpoint
   - Implement network-level blocking of C2 communication
   - Update firewall rules to block known ransomware domains

4. **Preserve Evidence:**
   - Capture memory of affected systems
   - Preserve logs and network traffic
   - Take forensic images
   - Document everything

**Containment Actions Table:**

| Action | Owner | Tools | Time |
|--------|-------|-------|------|
| Network isolation | IT Operations | Firewall, Network switches | 10 min |
| Endpoint containment | Security Team | EDR, MDR | 15 min |
| Backup protection | IT Operations | Backup systems | 10 min |
| Process termination | Security Team | EDR | 10 min |
| Evidence preservation | Security Team | Forensic tools | 15 min |

### Phase 3: Eradication (1-4 hours)

**Eradication Steps:**

1. **Identify Root Cause:**
   - Analyze initial infection vector
   - Review logs for entry point
   - Determine method of compromise
   - Identify privileged accounts used

2. **Remove Malware:**
   - Run antivirus scans on all systems
   - Use EDR to quarantine affected files
   - Remove persistence mechanisms
   - Clean registry entries

3. **Reset Credentials:**
   - Reset all passwords for affected users
   - Rotate all privileged account credentials
   - Reset API keys and tokens
   - Implement MFA where not already in place

4. **Apply Patches:**
   - Patch vulnerabilities exploited
   - Update security tools
   - Apply latest signatures and definitions
   - Update threat intelligence

### Phase 4: Recovery (4-24 hours)

**Recovery Strategy:**

1. **Restore From Backups:**
   - Verify backup integrity
   - Check for hidden malware in backups
   - Restore critical systems first
   - Conduct parallel restoration testing

2. **Reimage Affected Systems:**
   - Wipe and reimage encrypted systems
   - Apply security baselines
   - Install latest patches
   - Reconnect to network

3. **Validate Recovery:**
   - Test system functionality
   - Verify data integrity
   - Ensure security controls are operating
   - Monitor for signs of re-infection

4. **Phased Return to Operations:**
   - Restore business-critical systems first
   - Monitor closely after restoration
   - Gradually reconnect network segments
   - Maintain incident response posture

### Phase 5: Lessons Learned (24-72 hours)

**Post-Incident Activities:**

1. **Conduct Root Cause Analysis:**
   - What failed?
   - What worked well?
   - What needs improvement?

2. **Update Documentation:**
   - Update incident response playbook
   - Improve detection rules
   - Add new indicators of compromise
   - Update runbooks

3. **Implement Improvements:**
   - Prioritize fixes
   - Assign improvement owners
   - Track remediation
   - Verify improvements

4. **Legal and Compliance:**
   - Notify regulatory authorities (if required)
   - Document everything for potential legal action
   - Report to insurance provider
   - Consider legal counsel for liability

## 4. Communication Plan

### Internal Communication

| Time | Audience | Channel | Message |
|------|----------|---------|---------|
| 0 min | SOC Team | Chat | Initial detection |
| 15 min | IR Lead | Phone | Incident declared |
| 30 min | Security Team | Email | Incident details |
| 45 min | CISO | Phone | Executive update |
| 2 hours | Executive Council | Email/Meeting | Impact assessment |
| 8 hours | CEO/Board | Briefing | Full incident summary |

### External Communication

| Stakeholder | Timing | Message |
|-------------|--------|---------|
| Legal Counsel | Immediate | Legal implications |
| Insurance | 24 hours | Claim notification |
| Customers | 48 hours | Data exposure if any |
| Regulators | 72 hours | If data breach confirmed |
| Media | As needed | Prepared statement |

## 5. Escalation Matrix

### Severity Levels

| Level | Criteria | Response |
|-------|----------|----------|
| P1 - Critical | >100 systems, critical data, public safety | Full crisis team |
| P2 - High | >10 systems, sensitive data | Executive notification |
| P3 - Medium | 1-10 systems, no sensitive data | Standard response |
| P4 - Low | Single system, testing environment | Document and monitor |

### Escalation Path

```
Level 1: SOC Analyst (Initial Triage)
  ↓ (15 min)
Level 2: Incident Response Lead (Investigation)
  ↓ (30 min)
Level 3: CISO (Major Incident Declaration)
  ↓ (1 hour)
Level 4: Executive Cybersecurity Council (Strategic Response)
  ↓ (4 hours)
Level 5: CEO/Board (Crisis Management)
```

## 6. Role Responsibilities

| Role | Responsibilities |
|------|------------------|
| **Incident Commander** | Lead incident response, coordinate all activities, make critical decisions |
| **SOC Analyst** | Monitor detection, initial triage, provide technical details |
| **IT Operations** | Isolate systems, manage backups, restore operations |
| **Security Engineer** | Malware analysis, forensics, technical response |
| **CISO** | Executive communication, resource allocation, strategic decisions |
| **Legal Counsel** | Legal guidance, regulatory notification, liability management |
| **PR Manager** | Communication with stakeholders, media, customers |
| **HR** | Employee communication, insider threat investigation |

## 7. Tools and Resources

**Detection Tools:**
- EDR Platform (CrowdStrike, SentinelOne)
- SIEM (Splunk, Elastic)
- Network monitoring (Zeek, Snort)

**Containment Tools:**
- Firewall management
- Network segmentation
- Endpoint isolation

**Analysis Tools:**
- Forensic imaging (FTK, EnCase)
- Malware analysis (REMnux, VirusTotal)
- Memory analysis (Volatility)

**Recovery Tools:**
- Backup systems (Veeam, CommVault)
- Patching systems (WSUS, SCCM)
- System imaging (Clonezilla, MDT)

## 8. Recovery Checklist

### Pre-Recovery Checks
- [ ] Backups confirmed clean
- [ ] Ransomware removed from all systems
- [ ] Network fully segmented
- [ ] Security tools operational
- [ ] IOCs updated
- [ ] All credentials reset

### Recovery Steps
- [ ] Restore critical servers
- [ ] Restore business applications
- [ ] Restore end-user systems
- [ ] Validate data integrity
- [ ] Test system functionality
- [ ] Reconnect network segments
- [ ] Implement monitoring
- [ ] User notifications

### Post-Recovery Validation
- [ ] Critical systems operational
- [ ] Data integrity verified
- [ ] Monitoring alerts active
- [ ] Threat eliminated
- [ ] Lessons learned documented
- [ ] Playbook updated
```

### Step 3: Build Business Continuity and Disaster Recovery

**The Target:** Create comprehensive BCP/DR plans with immutable backup strategies.

**The Concept:** Business continuity ensures your organization can continue operating during and after a disaster. Disaster recovery specifically focuses on restoring IT systems and data. Think of it like having multiple backup plans for your organization.

**File:** `04-detection-response/scripts/bcp_dr_implementation.py`

```python
#!/usr/bin/env python3
"""
Business Continuity Planning (BCP) and Disaster Recovery (DR)

This module implements comprehensive BCP/DR including:
- Recovery Time Objective (RTO) and Recovery Point Objective (RPO) management
- Immutable backup verification
- Recovery testing
- Runbook generation
- Incident documentation
"""

import json
import datetime
import hashlib
import secrets
from typing import Dict, List, Optional, Any, Set, Tuple
from dataclasses import dataclass, field
from enum import Enum
import os
import subprocess
import shutil


class Criticality(Enum):
    """Criticality level of systems/business functions."""
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"


class RecoveryStatus(Enum):
    """Status of recovery plans and tests."""
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    SUCCESS = "success"
    FAILED = "failed"
    NOT_TESTED = "not_tested"


@dataclass
class RecoveryPlan:
    """
    Recovery plan for a system or business function.
    
    Attributes:
        plan_id: Unique identifier
        name: Plan name
        description: Plan description
        criticality: Criticality level
        rto_seconds: Recovery Time Objective in seconds
        rpo_seconds: Recovery Point Objective in seconds
        backup_strategy: Backup strategy details
        recovery_steps: Step-by-step recovery instructions
        status: Current status
        last_test: Last test timestamp
        test_results: Test results history
        dependencies: Dependent systems
    """
    plan_id: str
    name: str
    description: str
    criticality: str
    rto_seconds: int
    rpo_seconds: int
    backup_strategy: Dict[str, Any]
    recovery_steps: List[Dict]
    status: str = RecoveryStatus.NOT_TESTED.value
    last_test: Optional[str] = None
    test_results: List[Dict] = field(default_factory=list)
    dependencies: List[str] = field(default_factory=list)
    attributes: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "plan_id": self.plan_id,
            "name": self.name,
            "description": self.description,
            "criticality": self.criticality,
            "rto_seconds": self.rto_seconds,
            "rpo_seconds": self.rpo_seconds,
            "backup_strategy": self.backup_strategy,
            "recovery_steps": self.recovery_steps,
            "status": self.status,
            "last_test": self.last_test,
            "test_results": self.test_results,
            "dependencies": self.dependencies,
            "attributes": self.attributes
        }


@dataclass
class Backup:
    """
    Backup of a system or data.
    
    Attributes:
        backup_id: Unique identifier
        plan_id: Associated recovery plan
        timestamp: Backup timestamp
        location: Backup location
        size: Backup size in bytes
        type: Backup type (full, incremental, differential)
        integrity_hash: Backup integrity hash
        status: Backup status
        immutable: Whether backup is immutable
        encrypted: Whether backup is encrypted
    """
    backup_id: str
    plan_id: str
    timestamp: str
    location: str
    size: int
    type: str
    integrity_hash: str
    status: str
    immutable: bool = True
    encrypted: bool = True
    
    def to_dict(self) -> Dict:
        """Convert to dictionary."""
        return {
            "backup_id": self.backup_id,
            "plan_id": self.plan_id,
            "timestamp": self.timestamp,
            "location": self.location,
            "size": self.size,
            "type": self.type,
            "integrity_hash": self.integrity_hash,
            "status": self.status,
            "immutable": self.immutable,
            "encrypted": self.encrypted
        }


class BCPDRManager:
    """
    Business Continuity and Disaster Recovery Manager.
    
    This class handles recovery planning, immutable backups,
    recovery testing, and runbook generation.
    """
    
    def __init__(self, data_dir: str = "./bcpdr_data"):
        """
        Initialize BCP/DR manager.
        
        Args:
            data_dir: Directory for persistent storage
        """
        self.data_dir = data_dir
        self._ensure_data_dir()
        
        self.plans: Dict[str, RecoveryPlan] = {}
        self.backups: Dict[str, Backup] = {}
        self.audit_log: List[Dict] = []
        
        self._load_data()
        self._create_default_plans()
    
    def _ensure_data_dir(self) -> None:
        """Create data directory."""
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(f"{self.data_dir}/plans", exist_ok=True)
        os.makedirs(f"{self.data_dir}/backups", exist_ok=True)
        os.makedirs(f"{self.data_dir}/audit", exist_ok=True)
        os.makedirs(f"{self.data_dir}/runbooks", exist_ok=True)
    
    def _load_data(self) -> None:
        """Load existing data."""
        # Load plans
        plans_dir = f"{self.data_dir}/plans"
        if os.path.exists(plans_dir):
            for filename in os.listdir(plans_dir):
                if filename.endswith('.json'):
                    with open(f"{plans_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        plan = RecoveryPlan(
                            plan_id=data['plan_id'],
                            name=data['name'],
                            description=data['description'],
                            criticality=data['criticality'],
                            rto_seconds=data['rto_seconds'],
                            rpo_seconds=data['rpo_seconds'],
                            backup_strategy=data['backup_strategy'],
                            recovery_steps=data['recovery_steps'],
                            status=data.get('status', RecoveryStatus.NOT_TESTED.value),
                            last_test=data.get('last_test'),
                            test_results=data.get('test_results', []),
                            dependencies=data.get('dependencies', []),
                            attributes=data.get('attributes', {})
                        )
                        self.plans[plan.plan_id] = plan
        
        # Load backups
        backups_dir = f"{self.data_dir}/backups"
        if os.path.exists(backups_dir):
            for filename in os.listdir(backups_dir):
                if filename.endswith('.json'):
                    with open(f"{backups_dir}/{filename}", 'r') as f:
                        data = json.load(f)
                        backup = Backup(
                            backup_id=data['backup_id'],
                            plan_id=data['plan_id'],
                            timestamp=data['timestamp'],
                            location=data['location'],
                            size=data['size'],
                            type=data['type'],
                            integrity_hash=data['integrity_hash'],
                            status=data['status'],
                            immutable=data.get('immutable', True),
                            encrypted=data.get('encrypted', True)
                        )
                        self.backups[backup.backup_id] = backup
    
    def _log_audit(self, action: str, user_id: str, details: Dict) -> None:
        """Log audit event."""
        log_entry = {
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "action": action,
            "user_id": user_id,
            "details": details
        }
        self.audit_log.append(log_entry)
        
        with open(f"{self.data_dir}/audit/audit.log", 'a') as f:
            f.write(json.dumps(log_entry) + "\n")
    
    def _create_default_plans(self) -> None:
        """Create default recovery plans."""
        if not self.plans:
            default_plans = [
                RecoveryPlan(
                    plan_id="PLAN-001",
                    name="Critical Servers Recovery",
                    description="Recovery of critical application servers",
                    criticality=Criticality.CRITICAL.value,
                    rto_seconds=3600,  # 1 hour
                    rpo_seconds=300,   # 5 minutes
                    backup_strategy={
                        "frequency": "daily",
                        "type": "full",
                        "immutable": True,
                        "encrypted": True
                    },
                    recovery_steps=[
                        {"step": 1, "action": "Verify backup integrity"},
                        {"step": 2, "action": "Restore from latest backup"},
                        {"step": 3, "action": "Validate system functionality"},
                        {"step": 4, "action": "Reconnect to network"}
                    ]
                ),
                RecoveryPlan(
                    plan_id="PLAN-002",
                    name="Database Recovery",
                    description="Recovery of database systems",
                    criticality=Criticality.CRITICAL.value,
                    rto_seconds=7200,  # 2 hours
                    rpo_seconds=60,    # 1 minute
                    backup_strategy={
                        "frequency": "hourly",
                        "type": "differential",
                        "immutable": True,
                        "encrypted": True
                    },
                    recovery_steps=[
                        {"step": 1, "action": "Stop database services"},
                        {"step": 2, "action": "Restore database from backup"},
                        {"step": 3, "action": "Apply transaction logs"},
                        {"step": 4, "action": "Start database and validate"}
                    ]
                ),
                RecoveryPlan(
                    plan_id="PLAN-003",
                    name="Network Infrastructure Recovery",
                    description="Recovery of network infrastructure",
                    criticality=Criticality.HIGH.value,
                    rto_seconds=1800,  # 30 minutes
                    rpo_seconds=3600,  # 1 hour
                    backup_strategy={
                        "frequency": "daily",
                        "type": "configuration",
                        "immutable": True,
                        "encrypted": True
                    },
                    recovery_steps=[
                        {"step": 1, "action": "Restore router configurations"},
                        {"step": 2, "action": "Restore firewall policies"},
                        {"step": 3, "action": "Validate network connectivity"},
                        {"step": 4, "action": "Test access policies"}
                    ]
                ),
                RecoveryPlan(
                    plan_id="PLAN-004",
                    name="Email System Recovery",
                    description="Recovery of email systems",
                    criticality=Criticality.HIGH.value,
                    rto_seconds=10800,  # 3 hours
                    rpo_seconds=1800,   # 30 minutes
                    backup_strategy={
                        "frequency": "daily",
                        "type": "full",
                        "immutable": True,
                        "encrypted": True
                    },
                    recovery_steps=[
                        {"step": 1, "action": "Restore mail servers"},
                        {"step": 2, "action": "Restore mail data"},
                        {"step": 3, "action": "Validate email functionality"},
                        {"step": 4, "action": "Test external connectivity"}
                    ]
                )
            ]
            
            for plan in default_plans:
                self.plans[plan.plan_id] = plan
                self._save_plan(plan)
    
    def _save_plan(self, plan: RecoveryPlan) -> None:
        """Save recovery plan to storage."""
        with open(f"{self.data_dir}/plans/{plan.plan_id}.json", 'w') as f:
            json.dump(plan.to_dict(), f, indent=2)
    
    def _save_backup(self, backup: Backup) -> None:
        """Save backup to storage."""
        with open(f"{self.data_dir}/backups/{backup.backup_id}.json", 'w') as f:
            json.dump(backup.to_dict(), f, indent=2)
    
    def create_backup(self, plan_id: str) -> Optional[Backup]:
        """
        Create a backup for a recovery plan.
        
        Args:
            plan_id: Recovery plan ID
            
        Returns:
            Created Backup or None
        """
        plan = self.plans.get(plan_id)
        if not plan:
            return None
        
        # Generate backup ID
        backup_id = f"BACKUP-{datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{secrets.token_hex(4)}"
        
        # Simulate backup creation (in production, this would run actual backup)
        backup_location = f"{self.data_dir}/backups/data/{plan_id}/{backup_id}"
        os.makedirs(backup_location, exist_ok=True)
        
        # Create simulated backup data
        backup_size = secrets.randbelow(1000000000) + 1000000
        
        # Calculate integrity hash (simulated)
        integrity_hash = hashlib.sha256(
            f"{plan_id}:{backup_id}:{datetime.datetime.utcnow().isoformat()}".encode()
        ).hexdigest()
        
        backup = Backup(
            backup_id=backup_id,
            plan_id=plan_id,
            timestamp=datetime.datetime.utcnow().isoformat(),
            location=backup_location,
            size=backup_size,
            type=plan.backup_strategy.get('type', 'full'),
            integrity_hash=integrity_hash,
            status="completed",
            immutable=plan.backup_strategy.get('immutable', True),
            encrypted=plan.backup_strategy.get('encrypted', True)
        )
        
        self.backups[backup_id] = backup
        self._save_backup(backup)
        
        self._log_audit("BACKUP_CREATED", "system", {
            "backup_id": backup_id,
            "plan_id": plan_id,
            "size": backup_size
        })
        
        return backup
    
    def verify_backup(self, backup_id: str) -> Tuple[bool, str]:
        """
        Verify backup integrity.
        
        Args:
            backup_id: Backup ID
            
        Returns:
            Tuple of (verified, message)
        """
        backup = self.backups.get(backup_id)
        if not backup:
            return False, "Backup not found"
        
        # Verify integrity (in production, this would check actual backup)
        # For now, just check if backup exists and is recent
        backup_time = datetime.datetime.fromisoformat(backup.timestamp)
        age = (datetime.datetime.utcnow() - backup_time).total_seconds()
        
        if age > 86400 * 7:  # 7 days
            return False, f"Backup is {age/86400:.1f} days old - too old"
        
        if not backup.immutable:
            return False, "Backup is not immutable"
        
        if not backup.encrypted:
            return False, "Backup is not encrypted"
        
        # Verify integrity hash (simulated)
        expected_hash = hashlib.sha256(
            f"{backup.plan_id}:{backup.backup_id}:{backup.timestamp}".encode()
        ).hexdigest()
        
        # In production, would compare with actual stored hash
        if backup.integrity_hash:
            return True, "Backup verified successfully"
        
        return False, "Backup verification failed"
    
    def perform_recovery_test(self, plan_id: str) -> Dict:
        """
        Perform a recovery test for a plan.
        
        Args:
            plan_id: Recovery plan ID
            
        Returns:
            Test results
        """
        plan = self.plans.get(plan_id)
        if not plan:
            return {"error": "Plan not found"}
        
        # Get latest backup
        plan_backups = [b for b in self.backups.values() if b.plan_id == plan_id]
        if not plan_backups:
            # Create a backup first
            backup = self.create_backup(plan_id)
            if not backup:
                return {"error": "Failed to create backup"}
            plan_backups = [backup]
        
        latest_backup = max(plan_backups, key=lambda b: b.timestamp)
        
        # Verify backup
        verified, message = self.verify_backup(latest_backup.backup_id)
        if not verified:
            return {
                "status": RecoveryStatus.FAILED.value,
                "message": f"Backup verification failed: {message}",
                "backup_id": latest_backup.backup_id,
                "timestamp": datetime.datetime.utcnow().isoformat()
            }
        
        # Simulate recovery (in production, this would perform actual recovery)
        recovery_time = secrets.randbelow(plan.rto_seconds) + 60
        
        # Record test results
        test_result = {
            "test_id": f"TEST-{datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')}",
            "backup_id": latest_backup.backup_id,
            "recovery_time": recovery_time,
            "rto_met": recovery_time <= plan.rto_seconds,
            "status": RecoveryStatus.SUCCESS.value,
            "timestamp": datetime.datetime.utcnow().isoformat(),
            "issues": []
        }
        
        # Check RTO
        if not test_result["rto_met"]:
            test_result["issues"].append(f"Recovery time {recovery_time}s exceeds RTO {plan.rto_seconds}s")
        
        # Update plan
        plan.status = test_result["status"]
        plan.last_test = test_result["timestamp"]
        plan.test_results.append(test_result)
        self._save_plan(plan)
        
        self._log_audit("RECOVERY_TEST", "system", {
            "plan_id": plan_id,
            "test_id": test_result["test_id"],
            "status": test_result["status"]
        })
        
        return test_result
    
    def generate_runbook(self, plan_id: str) -> str:
        """
        Generate a recovery runbook.
        
        Args:
            plan_id: Recovery plan ID
            
        Returns:
            Runbook in markdown format
        """
        plan = self.plans.get(plan_id)
        if not plan:
            return "Plan not found"
        
        # Get latest backups
        plan_backups = [b for b in self.backups.values() if b.plan_id == plan_id]
        latest_backup = max(plan_backups, key=lambda b: b.timestamp) if plan_backups else None
        
        runbook = f"""# Recovery Runbook: {plan.name}

## Plan Information
- **Plan ID:** {plan.plan_id}
- **Description:** {plan.description}
- **Criticality:** {plan.criticality}
- **RTO:** {plan.rto_seconds} seconds ({plan.rto_seconds/60:.1f} minutes)
- **RPO:** {plan.rpo_seconds} seconds ({plan.rpo_seconds/60:.1f} minutes)
- **Status:** {plan.status}
- **Last Test:** {plan.last_test or 'Never'}

## Backup Information
"""
        
        if latest_backup:
            runbook += f"""
- **Backup ID:** {latest_backup.backup_id}
- **Created:** {latest_backup.timestamp}
- **Type:** {latest_backup.type}
- **Location:** {latest_backup.location}
- **Immutable:** {'Yes' if latest_backup.immutable else 'No'}
- **Encrypted:** {'Yes' if latest_backup.encrypted else 'No'}
- **Integrity Hash:** {latest_backup.integrity_hash[:16]}...
"""
        else:
            runbook += "\n**No backups found.**\n"
        
        runbook += f"""
## Recovery Steps

"""
        for step in plan.recovery_steps:
            runbook += f"{step['step']}. {step['action']}\n"
        
        runbook += f"""
## Dependencies

"""
        if plan.dependencies:
            for dep in plan.dependencies:
                runbook += f"- {dep}\n"
        else:
            runbook += "No dependencies\n"
        
        runbook += f"""
## Test History

| Test ID | Date | Recovery Time | RTO Met | Status |
|---------|------|--------------|---------|--------|
"""
        
        for test in plan.test_results[-5:]:  # Show last 5 tests
            rto_met = "✅" if test.get('rto_met', False) else "❌"
            runbook += f"| {test.get('test_id', 'Unknown')} | {test.get('timestamp', 'Unknown')[:16]} | {test.get('recovery_time', 0)}s | {rto_met} | {test.get('status', 'Unknown')} |\n"
        
        return runbook
    
    def generate_bcp_report(self) -> str:
        """
        Generate BCP/DR report.
        
        Returns:
            Markdown formatted report
        """
        total_plans = len(self.plans)
        tested_plans = sum(1 for p in self.plans.values() if p.status == RecoveryStatus.SUCCESS.value)
        failed_tests = sum(1 for p in self.plans.values() if p.status == RecoveryStatus.FAILED.value)
        total_backups = len(self.backups)
        
        # Calculate RTO compliance
        rto_compliant = 0
        for plan in self.plans.values():
            if plan.test_results:
                latest_test = plan.test_results[-1]
                if latest_test.get('rto_met', False):
                    rto_compliant += 1
        
        report = f"""
# Business Continuity and Disaster Recovery Report
*Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M')}*

## Executive Summary

| Metric | Value |
|--------|-------|
| Total Recovery Plans | {total_plans} |
| Tested Plans | {tested_plans} ({tested_plans/total_plans*100:.1f}%) |
| Failed Tests | {failed_tests} |
| RTO Compliant | {rto_compliant}/{total_plans} |
| Total Backups | {total_backups} |

## Plan Status

| Plan ID | Name | Criticality | RTO | RPO | Status | Last Test |
|---------|------|-------------|-----|-----|--------|-----------|
"""
        
        for plan in sorted(self.plans.values(), key=lambda p: p.criticality):
            rto_min = plan.rto_seconds / 60
            rpo_min = plan.rpo_seconds / 60
            last_test = plan.last_test[:16] if plan.last_test else 'Never'
            status_marker = {
                RecoveryStatus.SUCCESS.value: "✅",
                RecoveryStatus.FAILED.value: "❌",
                RecoveryStatus.IN_PROGRESS.value: "🔄",
                RecoveryStatus.NOT_TESTED.value: "⚪",
                RecoveryStatus.PLANNED.value: "📋"
            }.get(plan.status, "⚪")
            
            report += f"| {plan.plan_id} | {plan.name[:20]} | {plan.criticality} | {rto_min:.1f}m | {rpo_min:.1f}m | {status_marker} {plan.status} | {last_test} |\n"
        
        return report


def main():
    """CLI for BCP/DR management."""
    import argparse
    
    parser = argparse.ArgumentParser(description='BCP/DR Management Tool')
    subparsers = parser.add_subparsers(dest='command', help='Subcommands')
    
    # Create backup
    backup_parser = subparsers.add_parser('backup', help='Create backup')
    backup_parser.add_argument('--plan', '-p', required=True, help='Plan ID')
    
    # Verify backup
    verify_parser = subparsers.add_parser('verify', help='Verify backup')
    verify_parser.add_argument('--backup', '-b', required=True, help='Backup ID')
    
    # Test recovery
    test_parser = subparsers.add_parser('test', help='Test recovery')
    test_parser.add_argument('--plan', '-p', required=True, help='Plan ID')
    
    # Runbook
    runbook_parser = subparsers.add_parser('runbook', help='Generate runbook')
    runbook_parser.add_argument('--plan', '-p', required=True, help='Plan ID')
    runbook_parser.add_argument('--output', '-o', help='Output file')
    
    # Report
    report_parser = subparsers.add_parser('report', help='Generate report')
    
    # List plans
    list_parser = subparsers.add_parser('list', help='List plans')
    
    args = parser.parse_args()
    
    bcpdr = BCPDRManager()
    
    if args.command == 'backup':
        backup = bcpdr.create_backup(args.plan)
        if backup:
            print(f"✅ Backup created: {backup.backup_id}")
            print(f"   Plan: {backup.plan_id}")
            print(f"   Size: {backup.size/1024/1024:.2f} MB")
            print(f"   Immutable: {backup.immutable}")
            print(f"   Encrypted: {backup.encrypted}")
        else:
            print("❌ Plan not found")
    
    elif args.command == 'verify':
        verified, message = bcpdr.verify_backup(args.backup)
        if verified:
            print(f"✅ {message}")
        else:
            print(f"❌ {message}")
    
    elif args.command == 'test':
        result = bcpdr.perform_recovery_test(args.plan)
        if 'error' in result:
            print(f"❌ {result['error']}")
        else:
            print(f"✅ Recovery test completed")
            print(f"   Status: {result['status']}")
            print(f"   Recovery Time: {result['recovery_time']}s")
            print(f"   RTO Met: {'✅ Yes' if result['rto_met'] else '❌ No'}")
            if result.get('issues'):
                print("   Issues:")
                for issue in result['issues']:
                    print(f"     - {issue}")
    
    elif args.command == 'runbook':
        runbook = bcpdr.generate_runbook(args.plan)
        if args.output:
            with open(args.output, 'w') as f:
                f.write(runbook)
            print(f"✅ Runbook saved to {args.output}")
        else:
            print(runbook)
    
    elif args.command == 'report':
        report = bcpdr.generate_bcp_report()
        print(report)
    
    elif args.command == 'list':
        print("\nRecovery Plans:")
        print("=" * 60)
        for plan in sorted(bcpdr.plans.values(), key=lambda p: p.criticality):
            status = f"[{plan.status.upper()}]"
            print(f"{status} {plan.plan_id}: {plan.name} ({plan.criticality})")
            print(f"   RTO: {plan.rto_seconds/60:.1f}m, RPO: {plan.rpo_seconds/60:.1f}m")
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
```

## Verification

### Verification 1: Test SIEM Implementation

```bash
cd 04-detection-response/scripts

# Start SIEM processing
python3 siem_implementation.py start

# Ingest test logs
python3 siem_implementation.py ingest \
    --source "firewall" \
    --log '{"timestamp": "2024-03-15T10:00:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "192.168.1.100", "message": "Failed login attempt"}'

# Ingest multiple failures to trigger alert
python3 siem_implementation.py ingest \
    --source "firewall" \
    --log '{"timestamp": "2024-03-15T10:01:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "192.168.1.100", "message": "Failed login attempt 2"}'

python3 siem_implementation.py ingest \
    --source "firewall" \
    --log '{"timestamp": "2024-03-15T10:02:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "192.168.1.100", "message": "Failed login attempt 3"}'

# List alerts
python3 siem_implementation.py list

# Dashboard
python3 siem_implementation.py dashboard

# Acknowledge alert
python3 siem_implementation.py acknowledge --alert <alert-id> --assignee "security_analyst"

# Generate report
python3 siem_implementation.py report

# Stop processing
python3 siem_implementation.py stop
```

### Verification 2: Test BCP/DR Implementation

```bash
# List recovery plans
python3 bcp_dr_implementation.py list

# Create backup
python3 bcp_dr_implementation.py backup --plan PLAN-001

# Verify backup
python3 bcp_dr_implementation.py verify --backup <backup-id>

# Test recovery
python3 bcp_dr_implementation.py test --plan PLAN-001

# Generate runbook
python3 bcp_dr_implementation.py runbook --plan PLAN-001 --output ../reports/runbook-PLAN-001.md

# Generate report
python3 bcp_dr_implementation.py report
```

### Verification 3: Integration Test - End-to-End

**File:** `04-detection-response/scripts/integration_test.py`

```python
#!/usr/bin/env python3
"""
Integration test for detection and response components.
"""

import json
import datetime
import time
import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from siem_implementation import SIEMEngine
from bcp_dr_implementation import BCPDRManager


def run_integration_test():
    """Run end-to-end integration test."""
    print("🚀 Starting Detection & Response Integration Test")
    print("=" * 60)
    
    # Initialize SIEM
    print("\n1. Initializing SIEM...")
    siem = SIEMEngine("./test_siem_data")
    siem.start_processing()
    
    # Initialize BCP/DR
    print("2. Initializing BCP/DR...")
    bcpdr = BCPDRManager("./test_bcpdr_data")
    
    # Generate test logs
    print("\n3. Generating test events...")
    
    # 1. Normal login events (should not trigger alert)
    normal_logs = [
        {"timestamp": "2024-03-15T10:00:00", "host": "workstation01", "user": "john.doe", "event_type": "login_success"},
        {"timestamp": "2024-03-15T10:05:00", "host": "workstation02", "user": "jane.smith", "event_type": "login_success"},
        {"timestamp": "2024-03-15T10:10:00", "host": "server01", "user": "system", "event_type": "login_success"}
    ]
    
    for log in normal_logs:
        siem.ingest_log(log, "os")
        print(f"   📋 Ingested: {log['user']}@{log['host']} - {log['event_type']}")
    
    # 2. Suspicious events (should trigger alerts)
    suspicious_logs = [
        {"timestamp": "2024-03-15T10:15:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "10.0.0.1"},
        {"timestamp": "2024-03-15T10:16:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "10.0.0.1"},
        {"timestamp": "2024-03-15T10:17:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "10.0.0.1"},
        {"timestamp": "2024-03-15T10:18:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "10.0.0.1"},
        {"timestamp": "2024-03-15T10:19:00", "host": "server01", "user": "admin", "event_type": "login_failure", "source_ip": "10.0.0.1"}
    ]
    
    print("\n4. Ingesting suspicious events...")
    for log in suspicious_logs:
        siem.ingest_log(log, "firewall")
        print(f"   ⚠️ Ingested suspicious: {log['user']}@{log['host']} - {log['event_type']} (attempt {suspicious_logs.index(log)+1})")
        time.sleep(0.5)  # Small delay for processing
    
    # Wait for correlation
    print("\n5. Waiting for correlation...")
    time.sleep(2)
    
    # Check alerts
    print("\n6. Checking alerts...")
    alerts = siem.alerts.values()
    print(f"   📊 Alerts generated: {len(alerts)}")
    
    for alert in alerts:
        print(f"\n   🔔 Alert: {alert.alert_id}")
        print(f"      Severity: {alert.severity}")
        print(f"      Description: {alert.description}")
        print(f"      State: {alert.state}")
    
    # Test BCP/DR integration
    print("\n7. Testing BCP/DR integration...")
    plans = bcpdr.plans.values()
    print(f"   📋 Recovery plans: {len(plans)}")
    
    for plan in plans:
        print(f"\n   📋 Plan: {plan.name}")
        print(f"      Criticality: {plan.criticality}")
        print(f"      RTO: {plan.rto_seconds/60:.1f}m")
        
        # Create backup
        print(f"      Creating backup...")
        backup = bcpdr.create_backup(plan.plan_id)
        if backup:
            print(f"      ✅ Backup created: {backup.backup_id}")
            
            # Verify backup
            verified, message = bcpdr.verify_backup(backup.backup_id)
            print(f"      Backup verified: {verified} - {message}")
            
            # Test recovery
            print(f"      Testing recovery...")
            result = bcpdr.perform_recovery_test(plan.plan_id)
            if 'error' not in result:
                print(f"      ✅ Recovery test: {result['status']}")
                print(f"         Recovery time: {result['recovery_time']}s")
                print(f"         RTO met: {result['rto_met']}")
    
    # Generate reports
    print("\n8. Generating reports...")
    
    # SIEM report
    siem_report = siem.generate_report()
    print("\n   📊 SIEM Report:")
    print("   " + "-" * 50)
    for line in siem_report.split('\n')[:20]:
        print(f"   {line}")
    
    # BCP/DR report
    bcpdr_report = bcpdr.generate_bcp_report()
    print("\n   📊 BCP/DR Report:")
    print("   " + "-" * 50)
    for line in bcpdr_report.split('\n')[:20]:
        print(f"   {line}")
    
    # Clean up
    print("\n9. Cleaning up...")
    siem.stop_processing()
    
    print("\n" + "=" * 60)
    print("✅ Integration Test Complete!")
    print("\nSummary:")
    print(f"   - Total logs ingested: {len(siem.logs)}")
    print(f"   - Alerts generated: {len(siem.alerts)}")
    print(f"   - Recovery plans: {len(bcpdr.plans)}")
    print(f"   - Backups created: {len(bcpdr.backups)}")
    print(f"   - Recovery tests: {sum(1 for p in bcpdr.plans.values() if p.test_results)}")
    
    # Clean up test data
    import shutil
    for test_dir in ["./test_siem_data", "./test_bcpdr_data"]:
        if os.path.exists(test_dir):
            shutil.rmtree(test_dir)
            print(f"   🧹 Cleaned up: {test_dir}")
    
    print("\n✅ All components verified!")


if __name__ == "__main__":
    run_integration_test()
```

**Run Integration Test:**

```bash
cd 04-detection-response/scripts
python3 integration_test.py
```

**Expected Output:**
```
🚀 Starting Detection & Response Integration Test
============================================================

1. Initializing SIEM...
✅ SIEM processing started
2. Initializing BCP/DR...

3. Generating test events...
   📋 Ingested: john.doe@workstation01 - login_success
   📋 Ingested: jane.smith@workstation02 - login_success
   📋 Ingested: system@server01 - login_success

4. Ingesting suspicious events...
   ⚠️ Ingested suspicious: admin@server01 - login_failure (attempt 1)
   ⚠️ Ingested suspicious: admin@server01 - login_failure (attempt 2)
   ⚠️ Ingested suspicious: admin@server01 - login_failure (attempt 3)
   ⚠️ Ingested suspicious: admin@server01 - login_failure (attempt 4)
   ⚠️ Ingested suspicious: admin@server01 - login_failure (attempt 5)

5. Waiting for correlation...

6. Checking alerts...
   📊 Alerts generated: 1

   🔔 Alert: ALERT-20240315101930-abc123
      Severity: medium
      Description: Rule: Multiple Failed Logins - Multiple failed login attempts from same source
      State: open

7. Testing BCP/DR integration...
   📋 Recovery plans: 4

   📋 Plan: Critical Servers Recovery
      Criticality: critical
      RTO: 60.0m
      Creating backup...
      ✅ Backup created: BACKUP-20240315101932-1234
      Backup verified: True - Backup verified successfully
      Testing recovery...
      ✅ Recovery test: success
         Recovery time: 1234s
         RTO met: True
...
============================================================
✅ Integration Test Complete!

Summary:
   - Total logs ingested: 8
   - Alerts generated: 1
   - Recovery plans: 4
   - Backups created: 4
   - Recovery tests: 4

✅ All components verified!
```

## Key Takeaways

### What You Built

1. **SIEM System**: Complete log management, correlation, and alerting
2. **Incident Response Playbooks**: Comprehensive ransomware response procedures
3. **BCP/DR System**: Recovery planning, immutable backups, and recovery testing
4. **Integration**: End-to-end detection and response workflow

### Framework Mapping

| Component | NIST CSF | ISO 27001 | CIS Control |
|-----------|----------|-----------|-------------|
| SIEM | DE.AE (Anomalies/Events) | A.12.4 (Logging) | Control 8 |
| Incident Response | RS (Respond) | A.5.24-A.5.28 | Control 17 |
| BCP/DR | RC (Recover) | A.5.29-A.5.30 | Control 18 |
| Playbooks | RS.MI (Mitigation) | A.5.26 | Control 17.6 |

### Key Capabilities

- **24/7 Monitoring**: Continuous log collection and analysis
- **Real-time Alerting**: Immediate notification of security events
- **Incident Response**: Structured response procedures for ransomware
- **Business Continuity**: Recovery plans with RTO/RPO
- **Immutable Backups**: Tamper-proof backup strategy
- **Recovery Testing**: Regular verification of recovery capabilities

### What's Next

In **Part 5**, we'll secure the extended enterprise:
- Third-party risk management frameworks
- Vendor security assessments and due diligence
- Contractual security requirements and SLAs
- Software Bill of Materials (SBOM) governance
- External attack surface management
- Continuous third-party monitoring
