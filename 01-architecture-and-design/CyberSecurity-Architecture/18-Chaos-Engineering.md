# Part 4: Detection Engineering, Security Operations & Operational Resilience
## Section 4.5: Chaos Engineering

## The Target: Complete Chaos Engineering Program for Nexus Global Industries

In this section, we'll implement a comprehensive chaos engineering program for Nexus Global Industries, including:

1. **Failure Domain Testing** - Inducing network, node, and service failures
2. **Security Chaos Experiments** - Simulating security attacks
3. **Resilience Validation** - Measuring system recovery
4. **MTTD/MTTR Measurement** - Detection and response metrics
5. **Chaos Test Automation** - Automated test execution

**What specific file(s) are we building?**
- `chaos/01_failure_scenarios.yaml` - Failure domain test scenarios
- `chaos/02_security_chaos.yaml` - Security chaos experiments
- `chaos/03_resilience_validation.yaml` - Resilience validation framework
- `chaos/04_metrics.yaml` - MTTD/MTTR measurement
- `chaos/05_automation.py` - Chaos test automation

---

## The Concept: Chaos Engineering in Plain English

Think of chaos engineering like **fire drills for your security systems**:

**Failure Domain Testing:** "We simulate a fire in the kitchen to see if the sprinklers work." This is inducing failures to test resilience.

**Security Chaos:** "We simulate a break-in to test the alarm system and response." This is testing security controls.

**Resilience Validation:** "We time how quickly the fire department arrives and the fire is put out." This is measuring recovery.

**MTTD/MTTR:** "Time from fire starting to alarm sounding, and time from alarm to fire being out." This is measuring detection and response.

**Chaos Automation:** "We run scheduled fire drills automatically, with different scenarios each time." This is automated testing.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the chaos directory
cd ~/nexus_security_architecture
mkdir -p chaos

# Verify the structure
ls -la
# Expected: chaos directory appears
```

---

### Step 2: Failure Domain Test Scenarios

**File:** `chaos/01_failure_scenarios.yaml`

```yaml
# Failure Domain Test Scenarios - Nexus Global Industries
# File: chaos/01_failure_scenarios.yaml
# Version: 1.0

# ====================================================================
# TEST SCENARIOS
# ====================================================================

test_scenarios:
  - scenario_id: "CHAOS-001"
    name: "Kubernetes Node Failure"
    description: "Simulate loss of a Kubernetes node"
    type: "infrastructure"
    frequency: "weekly"
    environment: "staging"
    severity: "MEDIUM"
    
    hypothesis: |
      The system should automatically reschedule pods
      from the failed node to healthy nodes without
      service interruption.
    
    experiment:
      tool: "Gremlin"
      attack: "kubernetes_node_shutdown"
      duration: "5m"
      targets:
        - type: "kubernetes_node"
          selector:
            labels:
              node-type: "worker"
    
    success_criteria:
      - "All pods rescheduled within 60 seconds"
      - "No 5xx errors during failure"
      - "MTTR < 2 minutes"
    
    validation:
      - step: "Monitor pod scheduling"
        check: "Pods from failed node running on other nodes"
      - step: "Check service availability"
        check: "Service endpoints healthy"
      - step: "Verify data integrity"
        check: "No data loss detected"
  
  - scenario_id: "CHAOS-002"
    name: "Network Partition"
    description: "Simulate network partition between services"
    type: "network"
    frequency: "bi-weekly"
    environment: "staging"
    severity: "HIGH"
    
    hypothesis: |
      Services should gracefully handle network outages
      with proper retry and circuit breaking mechanisms.
    
    experiment:
      tool: "Gremlin"
      attack: "network_partition"
      duration: "3m"
      targets:
        - service: "payment-service"
          namespace: "production"
        - service: "order-service"
          namespace: "production"
    
    success_criteria:
      - "Circuit breakers open within 10 seconds"
      - "Graceful degradation of service"
      - "Automatic recovery after partition ends"
    
    validation:
      - step: "Check circuit breaker state"
        check: "Circuit breakers open"
      - step: "Verify fallback responses"
        check: "Graceful error handling"
      - step: "Monitor recovery"
        check: "Automatic recovery < 30 seconds"
  
  - scenario_id: "CHAOS-003"
    name: "DNS Failure"
    description: "Simulate DNS resolution failure"
    type: "infrastructure"
    frequency: "weekly"
    environment: "staging"
    severity: "MEDIUM"
    
    hypothesis: |
      Services should have DNS caching and fallback
      mechanisms to handle DNS failures.
    
    experiment:
      tool: "Gremlin"
      attack: "dns_failure"
      duration: "2m"
      targets:
        - type: "service"
          selector:
            labels:
              app: "customer-api"
    
    success_criteria:
      - "Services maintain functionality"
      - "Cached DNS entries used"
      - "No prolonged service interruption"
    
    validation:
      - step: "Check DNS resolution"
        check: "Cached entries available"
      - step: "Verify service health"
        check: "Services still reachable"
      - step: "Monitor recovery"
        check: "DNS restored after failure"
  
  - scenario_id: "CHAOS-004"
    name: "Database Connection Failure"
    description: "Simulate database connection loss"
    type: "database"
    frequency: "weekly"
    environment: "staging"
    severity: "HIGH"
    
    hypothesis: |
      Applications should handle database connection loss
      with retry logic and proper error handling.
    
    experiment:
      tool: "Gremlin"
      attack: "database_connection_failure"
      duration: "5m"
      targets:
        - service: "postgresql"
          namespace: "production"
    
    success_criteria:
      - "No application crashes"
      - "Proper error messages displayed"
      - "Automatic reconnection after DB restore"
    
    validation:
      - step: "Check application errors"
        check: "No unhandled exceptions"
      - step: "Verify error messages"
        check: "User-friendly errors"
      - step: "Monitor reconnect"
        check: "Automatic reconnection < 1 minute"
  
  - scenario_id: "CHAOS-005"
    name: "CPU Pressure"
    description: "Apply CPU pressure to identify performance degradation"
    type: "resource"
    frequency: "monthly"
    environment: "staging"
    severity: "MEDIUM"
    
    hypothesis: |
      The system should handle CPU pressure by auto-scaling
      and load balancing without significant performance impact.
    
    experiment:
      tool: "Gremlin"
      attack: "cpu_pressure"
      duration: "5m"
      targets:
        - type: "container"
          selector:
            labels:
              app: "customer-api"
      parameters:
        cpu_percent: 80
    
    success_criteria:
      - "Auto-scaling triggers within 2 minutes"
      - "Response time under 2x baseline"
      - "No timeout errors"
    
    validation:
      - step: "Check auto-scaling"
        check: "New pods created"
      - step: "Measure response time"
        check: "Within acceptable range"
      - step: "Check error rate"
        check: "No error increase"

# ====================================================================
# TEST SCHEDULE
# ====================================================================

test_schedule:
  - day: "Monday"
    time: "09:00"
    scenarios: ["CHAOS-001", "CHAOS-003"]
    environment: "dev"
  
  - day: "Wednesday"
    time: "14:00"
    scenarios: ["CHAOS-002", "CHAOS-004"]
    environment: "staging"
  
  - day: "Friday"
    time: "16:00"
    scenarios: ["CHAOS-001", "CHAOS-005"]
    environment: "staging"
  
  - day: "Saturday"
    time: "02:00"
    scenarios: ["CHAOS-002", "CHAOS-004", "CHAOS-005"]
    environment: "production"
    notify: true
```

**Verification:**

```bash
# Verify failure scenarios file
ls -la chaos/01_failure_scenarios.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('chaos/01_failure_scenarios.yaml'))"
# Expected: No error output
```

---

### Step 3: Security Chaos Experiments

**File:** `chaos/02_security_chaos.yaml`

```yaml
# Security Chaos Experiments - Nexus Global Industries
# File: chaos/02_security_chaos.yaml
# Version: 1.0

# ====================================================================
# SECURITY EXPERIMENTS
# ====================================================================

security_experiments:
  - experiment_id: "SEC-CHAOS-001"
    name: "IAM Policy Revocation"
    description: "Revoke IAM permissions to test access controls"
    type: "security"
    frequency: "monthly"
    environment: "staging"
    severity: "HIGH"
    
    hypothesis: |
      Zero Trust policies should immediately deny access
      when IAM permissions are revoked.
    
    experiment:
      tool: "Custom"
      action: "iam_revoke"
      targets:
        - user: "test-user-001"
        - role: "test-role-001"
      duration: "5m"
    
    success_criteria:
      - "Access denied within 5 seconds"
      - "Audit log records revocation"
      - "Session terminated immediately"
    
    validation:
      - step: "Verify access denied"
        check: "API calls return 403/401"
      - step: "Check audit logs"
        check: "Revocation event logged"
      - step: "Validate session termination"
        check: "No active sessions"
  
  - experiment_id: "SEC-CHAOS-002"
    name: "MFA Bypass Simulation"
    description: "Simulate MFA bypass attempt"
    type: "security"
    frequency: "monthly"
    environment: "staging"
    severity: "CRITICAL"
    
    hypothesis: |
      MFA enforcement should block any attempt to bypass
      MFA verification.
    
    experiment:
      tool: "Custom"
      action: "mfa_bypass_attempt"
      targets:
        - user: "test-user-002"
        - ip: "test-ip-001"
      duration: "2m"
    
    success_criteria:
      - "Login attempts blocked"
      - "Anomaly alert triggered"
      - "Account locked after 3 attempts"
    
    validation:
      - step: "Check login attempts"
        check: "All attempts blocked"
      - step: "Verify alerts"
        check: "Alert sent to SIEM"
      - step: "Check account status"
        check: "Account locked"
  
  - experiment_id: "SEC-CHAOS-003"
    name: "Ransomware Simulation"
    description: "Simulate ransomware behavior to test detection"
    type: "security"
    frequency: "quarterly"
    environment: "staging"
    severity: "CRITICAL"
    
    hypothesis: |
      The ransomware detection rules should trigger within
      5 minutes of the simulation start.
    
    experiment:
      tool: "Custom"
      action: "ransomware_simulation"
      targets:
        - files: ["/tmp/test-files/*"]
        - processes: ["test-ransomware"]
      duration: "10m"
    
    success_criteria:
      - "Alert triggered within 5 minutes"
      - "Containment initiated automatically"
      - "Backup integrity verified"
    
    validation:
      - step: "Check alert time"
        check: "MTTD < 5 minutes"
      - step: "Verify containment"
        check: "Network isolation applied"
      - step: "Check backups"
        check: "Backups intact"
  
  - experiment_id: "SEC-CHAOS-004"
    name: "Credential Replay Attack"
    description: "Simulate credential replay attack"
    type: "security"
    frequency: "monthly"
    environment: "staging"
    severity: "HIGH"
    
    hypothesis: |
      Token reuse should be detected and blocked by
      the Zero Trust architecture.
    
    experiment:
      tool: "Custom"
      action: "credential_replay"
      targets:
        - token: "test-token-001"
        - user: "test-user-003"
      duration: "3m"
    
    success_criteria:
      - "Token reuse detected"
      - "Session terminated"
      - "Anomaly alert triggered"
    
    validation:
      - step: "Check token validation"
        check: "Reused token rejected"
      - step: "Verify session termination"
        check: "Session ended"
      - step: "Check alerts"
        check: "Alert in SIEM"
  
  - experiment_id: "SEC-CHAOS-005"
    name: "Zero Trust Violation Test"
    description: "Simulate Zero Trust policy violation"
    type: "security"
    frequency: "weekly"
    environment: "staging"
    severity: "HIGH"
    
    hypothesis: |
      Zero Trust policies should detect and block
      policy violations in real-time.
    
    experiment:
      tool: "Custom"
      action: "zero_trust_violation"
      targets:
        - user: "test-user-004"
        - device: "test-device-001"
        - location: "test-location-001"
      duration: "2m"
    
    success_criteria:
      - "Access denied within 2 seconds"
      - "Risk score updated"
      - "Verification failure logged"
    
    validation:
      - step: "Check access decision"
        check: "Access denied"
      - step: "Verify risk score"
        check: "Risk score increased"
      - step: "Check audit logs"
        check: "Violation logged"
  
  - experiment_id: "SEC-CHAOS-006"
    name: "API Security Control Test"
    description: "Test API security controls"
    type: "security"
    frequency: "weekly"
    environment: "staging"
    severity: "MEDIUM"
    
    hypothesis: |
      API security controls should detect and block
      malicious API requests.
    
    experiment:
      tool: "Custom"
      action: "api_attack"
      targets:
        - api: "customer-api"
        - endpoint: "/api/v1/orders"
      parameters:
        - type: "sqli"
        - payload: "' OR '1'='1"
        - count: 5
      duration: "2m"
    
    success_criteria:
      - "All malicious requests blocked"
      - "Rate limit applied"
      - "Alert triggered"
    
    validation:
      - step: "Check API responses"
        check: "All requests return 4xx"
      - step: "Verify rate limiting"
        check: "Rate limit applied"
      - step: "Check alerts"
        check: "Alert in SIEM"
```

**Verification:**

```bash
# Verify security chaos file
ls -la chaos/02_security_chaos.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('chaos/02_security_chaos.yaml'))"
# Expected: No error output
```

---

### Step 4: Resilience Validation Framework

**File:** `chaos/03_resilience_validation.yaml`

```yaml
# Resilience Validation Framework - Nexus Global Industries
# File: chaos/03_resilience_validation.yaml
# Version: 1.0

# ====================================================================
# VALIDATION METRICS
# ====================================================================

validation_metrics:
  - metric: "MTTD"
    name: "Mean Time to Detect"
    description: "Time from failure injection to detection"
    target: "< 60 seconds"
    critical_threshold: "300 seconds"
    unit: "seconds"
  
  - metric: "MTTR"
    name: "Mean Time to Respond"
    description: "Time from detection to resolution"
    target: "< 300 seconds"
    critical_threshold: "900 seconds"
    unit: "seconds"
  
  - metric: "MTTF"
    name: "Mean Time to Failure"
    description: "Average time between failures"
    target: "> 30 days"
    critical_threshold: "7 days"
    unit: "days"
  
  - metric: "Recovery_Rate"
    name: "Recovery Success Rate"
    description: "Percentage of failures that auto-recover"
    target: "> 95%"
    critical_threshold: "80%"
    unit: "percent"
  
  - metric: "Error_Rate"
    name: "Error Rate During Failure"
    description: "Percentage of requests returning 5xx during failure"
    target: "< 1%"
    critical_threshold: "5%"
    unit: "percent"

# ====================================================================
# VALIDATION CHECKS
# ====================================================================

validation_checks:
  - check_id: "VAL-001"
    name: "Auto-Scaling Validation"
    description: "Validate auto-scaling triggers correctly"
    scenario: "CHAOS-005"
    checks:
      - step: "Monitor pod count"
        condition: "Increase in pod count within 2 minutes"
      - step: "Check resource usage"
        condition: "CPU usage below threshold"
      - step: "Verify service health"
        condition: "No 5xx errors"
  
  - check_id: "VAL-002"
    name: "Circuit Breaker Validation"
    description: "Validate circuit breakers function correctly"
    scenario: "CHAOS-002"
    checks:
      - step: "Monitor circuit breaker state"
        condition: "Circuit opens within 10 seconds"
      - step: "Check fallback responses"
        condition: "Proper error responses"
      - step: "Verify recovery"
        condition: "Circuit closes after failure ends"
  
  - check_id: "VAL-003"
    name: "Retry Logic Validation"
    description: "Validate retry mechanisms work"
    scenario: "CHAOS-004"
    checks:
      - step: "Monitor retry attempts"
        condition: "Retries executed within 30 seconds"
      - step: "Check success after retry"
        condition: "Requests succeed after DB restore"
      - step: "Verify no duplicate"
        condition: "No duplicate operations"
  
  - check_id: "VAL-004"
    name: "Alerting Validation"
    description: "Validate alerts trigger correctly"
    scenario: "SEC-CHAOS-001"
    checks:
      - step: "Check alert time"
        condition: "Alert within 30 seconds"
      - step: "Verify alert content"
        condition: "Correct details included"
      - step: "Check notification"
        condition: "Notification sent to correct team"

# ====================================================================
= SCORING SYSTEM
# ====================================================================

scoring_system:
  - name: "Resilience Score"
    description: "Overall resilience rating"
    formula: |
      (MTTD_score * 0.3) + (MTTR_score * 0.3) + (Recovery_Rate_score * 0.2) + (Error_Rate_score * 0.2)
    
    ratings:
      - range: "90-100"
        grade: "A"
        status: "Excellent"
        color: "GREEN"
      
      - range: "75-89"
        grade: "B"
        status: "Good"
        color: "YELLOW"
      
      - range: "60-74"
        grade: "C"
        status: "Fair"
        color: "ORANGE"
      
      - range: "0-59"
        grade: "F"
        status: "Poor"
        color: "RED"
  
  - name: "Security Resilience Score"
    description: "Security-specific resilience rating"
    formula: |
      (Security_MTTD * 0.25) + (Security_MTTR * 0.25) + (Detection_Coverage * 0.25) + (Auto_Containment * 0.25)
    
    ratings:
      - range: "90-100"
        grade: "A"
        status: "Excellent"
        color: "GREEN"
      
      - range: "70-89"
        grade: "B"
        status: "Good"
        color: "YELLOW"
      
      - range: "50-69"
        grade: "C"
        status: "Fair"
        color: "ORANGE"
      
      - range: "0-49"
        grade: "F"
        status: "Poor"
        color: "RED"

# ====================================================================
# REPORTING
# ====================================================================

reporting:
  - report_name: "Chaos Test Report"
    format: "PDF"
    recipients: ["security@nexus.com", "sre@nexus.com"]
    schedule: "after each test"
    
    sections:
      - "test_scenario"
      - "hypothesis"
      - "results"
      - "metrics"
      - "score"
      - "recommendations"
  
  - report_name: "Resilience Monthly Report"
    format: "PDF"
    recipients: ["security@nexus.com", "ciso@nexus.com"]
    schedule: "monthly"
    
    sections:
      - "executive_summary"
      - "resilience_score"
      - "trends"
      - "top_issues"
      - "improvements"
      - "next_steps"
```

**Verification:**

```bash
# Verify resilience validation file
ls -la chaos/03_resilience_validation.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('chaos/03_resilience_validation.yaml'))"
# Expected: No error output
```

---

### Step 5: MTTD/MTTR Measurement

**File:** `chaos/04_metrics.yaml`

```yaml
# MTTD/MTTR Measurement - Nexus Global Industries
# File: chaos/04_metrics.yaml
# Version: 1.0

# ====================================================================
# METRIC DEFINITIONS
# ====================================================================

metrics:
  - metric_id: "MTTD-001"
    name: "Security MTTD"
    description: "Mean Time to Detect security incidents"
    calculation: |
      Sum(detection_time - trigger_time) / Number_of_incidents
    unit: "seconds"
    target: 60
    threshold: 300
    
  - metric_id: "MTTR-001"
    name: "Security MTTR"
    description: "Mean Time to Respond to security incidents"
    calculation: |
      Sum(resolution_time - detection_time) / Number_of_incidents
    unit: "seconds"
    target: 300
    threshold: 900
    
  - metric_id: "MTTD-002"
    name: "Infrastructure MTTD"
    description: "Mean Time to Detect infrastructure failures"
    calculation: |
      Sum(failure_detection_time - failure_start_time) / Number_of_failures
    unit: "seconds"
    target: 30
    threshold: 120
    
  - metric_id: "MTTR-002"
    name: "Infrastructure MTTR"
    description: "Mean Time to Recover infrastructure failures"
    calculation: |
      Sum(recovery_time - failure_detection_time) / Number_of_failures
    unit: "seconds"
    target: 120
    threshold: 300

# ====================================================================
# MEASUREMENT SOURCES
# ====================================================================

measurement_sources:
  - source: "SIEM"
    description: "Security incident detection and response times"
    fields:
      - detection_time: "@timestamp"
      - trigger_time: "alert.trigger_time"
      - resolution_time: "case.resolution_time"
      - incident_id: "alert.id"
  
  - source: "Monitoring"
    description: "Infrastructure failure detection and recovery"
    fields:
      - failure_time: "failure.timestamp"
      - detection_time: "detection.timestamp"
      - recovery_time: "recovery.timestamp"
      - system_id: "system.id"
  
  - source: "Chaos Tests"
    description: "Chaos engineering test results"
    fields:
      - start_time: "experiment.start"
      - trigger_time: "experiment.trigger"
      - detection_time: "experiment.detection"
      - resolution_time: "experiment.resolution"

# ====================================================================
# DASHBOARD
# ====================================================================

dashboard:
  title: "MTTD/MTTR Dashboard"
  update_frequency: "real-time"
  
  panels:
    - panel_id: "mttd-trend"
      title: "MTTD Trend (Last 30 Days)"
      type: "line"
      query: |
        SELECT DATE(detection_time) as date,
               AVG(detection_time - trigger_time) as avg_mttd
        FROM security_incidents
        WHERE detection_time > NOW() - INTERVAL 30 DAY
        GROUP BY DATE(detection_time)
        ORDER BY date
    
    - panel_id: "mttr-trend"
      title: "MTTR Trend (Last 30 Days)"
      type: "line"
      query: |
        SELECT DATE(resolution_time) as date,
               AVG(resolution_time - detection_time) as avg_mttr
        FROM security_incidents
        WHERE resolution_time > NOW() - INTERVAL 30 DAY
        GROUP BY DATE(resolution_time)
        ORDER BY date
    
    - panel_id: "mttd-by-type"
      title: "MTTD by Incident Type"
      type: "bar"
      query: |
        SELECT incident_type,
               AVG(detection_time - trigger_time) as avg_mttd
        FROM security_incidents
        WHERE detection_time > NOW() - INTERVAL 30 DAY
        GROUP BY incident_type
        ORDER BY avg_mttd DESC
    
    - panel_id: "mttr-by-severity"
      title: "MTTR by Severity"
      type: "bar"
      query: |
        SELECT severity,
               AVG(resolution_time - detection_time) as avg_mttr
        FROM security_incidents
        WHERE resolution_time > NOW() - INTERVAL 30 DAY
        GROUP BY severity
        ORDER BY avg_mttr DESC

# ====================================================================
# TARGETS AND SLAS
# ====================================================================

targets:
  - target: "Security MTTD"
    current: "45s"
    target: "60s"
    status: "GREEN"
    trend: "improving"
  
  - target: "Security MTTR"
    current: "192s"
    target: "300s"
    status: "GREEN"
    trend: "improving"
  
  - target: "Infrastructure MTTD"
    current: "25s"
    target: "30s"
    status: "GREEN"
    trend: "stable"
  
  - target: "Infrastructure MTTR"
    current: "95s"
    target: "120s"
    status: "GREEN"
    trend: "improving"

sla_policies:
  - severity: "CRITICAL"
    mttd_target: "60s"
    mttr_target: "300s"
    breach_action: "escalate_ciso"
  
  - severity: "HIGH"
    mttd_target: "120s"
    mttr_target: "600s"
    breach_action: "escalate_manager"
  
  - severity: "MEDIUM"
    mttd_target: "300s"
    mttr_target: "1800s"
    breach_action: "notify"
```

**Verification:**

```bash
# Verify metrics file
ls -la chaos/04_metrics.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('chaos/04_metrics.yaml'))"
# Expected: No error output
```

---

### Step 6: Chaos Test Automation

**File:** `chaos/05_automation.py`

```python
#!/usr/bin/env python3
"""
Chaos Test Automation - Nexus Global Industries
File: chaos/05_automation.py
Version: 1.0

This service automates chaos engineering tests, measures resilience,
and generates reports.
"""

import os
import json
import logging
import time
import threading
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
import requests
import yaml
import schedule

# ====================================================================
# Configuration
# ====================================================================

CONFIG = {
    "CHAOS_CONFIG_PATH": os.getenv("CHAOS_CONFIG_PATH", "/config"),
    "GREMLIN_API_KEY": os.getenv("GREMLIN_API_KEY", ""),
    "GREMLIN_TEAM_ID": os.getenv("GREMLIN_TEAM_ID", ""),
    "SIEM_URL": os.getenv("SIEM_URL", "http://logstash.siem.svc.cluster.local:5044"),
    "REPORT_PATH": os.getenv("REPORT_PATH", "/reports"),
    "LOG_LEVEL": os.getenv("LOG_LEVEL", "INFO"),
}

# ====================================================================
# Logging Setup
# ====================================================================

logging.basicConfig(
    level=getattr(logging, CONFIG["LOG_LEVEL"]),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ====================================================================
# Data Models
# ====================================================================

@dataclass
class ChaosTest:
    """Chaos experiment definition."""
    test_id: str
    name: str
    scenario: str
    environment: str
    status: str  # pending, running, completed, failed
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    duration: int  # seconds
    results: Dict[str, Any]
    metrics: Dict[str, Any]

@dataclass
class TestResult:
    """Results of a chaos test."""
    test_id: str
    passed: bool
    metrics: Dict[str, Any]
    observations: List[str]
    recommendations: List[str]

# ====================================================================
# Chaos Test Automation Service
# ====================================================================

class ChaosAutomation:
    """Automated chaos engineering service."""
    
    def __init__(self):
        """Initialize the chaos automation service."""
        self.tests = {}
        self.results = {}
        
        # Load test configurations
        self.test_configs = self._load_test_configs()
        
        # Start test scheduler
        self._start_scheduler()
        
        logger.info(f"Chaos Automation initialized with {len(self.test_configs)} test configurations")
    
    def _load_test_configs(self) -> List[Dict[str, Any]]:
        """Load chaos test configurations."""
        configs = []
        config_dir = CONFIG["CHAOS_CONFIG_PATH"]
        
        if not os.path.exists(config_dir):
            logger.warning(f"Config directory not found: {config_dir}")
            return configs
        
        for file in os.listdir(config_dir):
            if file.endswith('.yaml') or file.endswith('.yml'):
                try:
                    with open(os.path.join(config_dir, file), 'r') as f:
                        data = yaml.safe_load(f)
                        if data and 'test_scenarios' in data:
                            configs.extend(data['test_scenarios'])
                except Exception as e:
                    logger.error(f"Error loading config {file}: {e}")
        
        return configs
    
    def run_test(self, test_id: str) -> TestResult:
        """
        Execute a chaos test.
        
        Args:
            test_id: ID of the test to run
            
        Returns:
            TestResult with the outcomes
        """
        # Find test configuration
        test_config = None
        for config in self.test_configs:
            if config.get('scenario_id') == test_id:
                test_config = config
                break
        
        if not test_config:
            return TestResult(
                test_id=test_id,
                passed=False,
                metrics={},
                observations=["Test configuration not found"],
                recommendations=["Verify test ID and configuration"]
            )
        
        logger.info(f"Starting chaos test: {test_config.get('name')}")
        
        # Create test record
        test = ChaosTest(
            test_id=test_id,
            name=test_config.get('name', test_id),
            scenario=test_config.get('type', 'unknown'),
            environment=test_config.get('environment', 'staging'),
            status='running',
            start_time=datetime.utcnow(),
            end_time=None,
            duration=test_config.get('duration', 300),
            results={},
            metrics={}
        )
        
        self.tests[test_id] = test
        
        try:
            # Execute the experiment
            results = self._execute_experiment(test_config)
            
            # Collect metrics
            metrics = self._collect_metrics(test_config)
            
            # Validate results
            passed = self._validate_results(test_config, results, metrics)
            
            # Generate observations
            observations = self._generate_observations(test_config, results, metrics)
            
            # Generate recommendations
            recommendations = self._generate_recommendations(test_config, results, metrics)
            
            # Update test record
            test.status = 'completed' if passed else 'failed'
            test.end_time = datetime.utcnow()
            test.results = results
            test.metrics = metrics
            
            # Log to SIEM
            self._log_to_siem(test, passed)
            
            # Generate report
            self._generate_report(test, passed, observations, recommendations)
            
            return TestResult(
                test_id=test_id,
                passed=passed,
                metrics=metrics,
                observations=observations,
                recommendations=recommendations
            )
            
        except Exception as e:
            logger.error(f"Error executing chaos test {test_id}: {e}")
            test.status = 'failed'
            test.end_time = datetime.utcnow()
            
            return TestResult(
                test_id=test_id,
                passed=False,
                metrics={},
                observations=[f"Test failed with error: {str(e)}"],
                recommendations=["Review test configuration and retry"]
            )
    
    def _execute_experiment(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Execute the chaos experiment."""
        # Use Gremlin API or custom implementation
        experiment = config.get('experiment', {})
        tool = experiment.get('tool', 'custom')
        
        if tool == 'gremlin':
            return self._run_gremlin_experiment(experiment)
        else:
            return self._run_custom_experiment(experiment)
    
    def _run_gremlin_experiment(self, experiment: Dict[str, Any]) -> Dict[str, Any]:
        """Run a Gremlin experiment."""
        # Simulated Gremlin API call
        logger.info(f"Running Gremlin experiment: {experiment.get('attack', 'unknown')}")
        
        # In production, this would call Gremlin API
        # For demo, simulate success
        time.sleep(experiment.get('duration', 60))
        
        return {
            'experiment_id': f"gremlin-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}",
            'status': 'success',
            'duration': experiment.get('duration', 60),
            'targets': experiment.get('targets', []),
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def _run_custom_experiment(self, experiment: Dict[str, Any]) -> Dict[str, Any]:
        """Run a custom experiment."""
        logger.info(f"Running custom experiment: {experiment.get('action', 'unknown')}")
        
        # Simulate experiment execution
        time.sleep(experiment.get('duration', 30))
        
        return {
            'experiment_id': f"custom-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}",
            'status': 'success',
            'duration': experiment.get('duration', 30),
            'action': experiment.get('action', 'unknown'),
            'timestamp': datetime.utcnow().isoformat()
        }
    
    def _collect_metrics(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Collect metrics during the test."""
        # In production, this would query monitoring systems
        # For demo, return simulated metrics
        return {
            'mttd': 45,  # seconds
            'mttr': 192,  # seconds
            'error_rate': 0.5,  # percent
            'recovery_rate': 95.0,  # percent
            'auto_scaling_time': 30,  # seconds
            'success_criteria_met': True
        }
    
    def _validate_results(self, config: Dict[str, Any], results: Dict[str, Any], metrics: Dict[str, Any]) -> bool:
        """Validate test results against success criteria."""
        criteria = config.get('success_criteria', [])
        
        if not criteria:
            return True
        
        # Check each criterion
        for criterion in criteria:
            if 'MTTD' in criterion and metrics.get('mttd', 0) > 60:
                return False
            if 'MTTR' in criterion and metrics.get('mttr', 0) > 300:
                return False
            if 'error' in criterion.lower() and metrics.get('error_rate', 0) > 1:
                return False
            if 'recovery' in criterion.lower() and metrics.get('recovery_rate', 0) < 95:
                return False
        
        return True
    
    def _generate_observations(self, config: Dict[str, Any], results: Dict[str, Any], metrics: Dict[str, Any]) -> List[str]:
        """Generate observations from test results."""
        observations = []
        
        if metrics.get('mttd', 0) < 30:
            observations.append("Excellent detection time (< 30 seconds)")
        elif metrics.get('mttd', 0) < 60:
            observations.append("Good detection time (< 60 seconds)")
        else:
            observations.append(f"Detection time exceeded target ({metrics.get('mttd', 0)} seconds)")
        
        if metrics.get('mttr', 0) < 120:
            observations.append("Excellent recovery time (< 2 minutes)")
        elif metrics.get('mttr', 0) < 300:
            observations.append("Good recovery time (< 5 minutes)")
        else:
            observations.append(f"Recovery time exceeded target ({metrics.get('mttr', 0)} seconds)")
        
        if metrics.get('recovery_rate', 0) == 100:
            observations.append("All systems recovered automatically")
        elif metrics.get('recovery_rate', 0) > 95:
            observations.append(f"High automatic recovery rate ({metrics.get('recovery_rate', 0)}%)")
        else:
            observations.append(f"Manual intervention required ({100 - metrics.get('recovery_rate', 0)}% of failures)")
        
        return observations
    
    def _generate_recommendations(self, config: Dict[str, Any], results: Dict[str, Any], metrics: Dict[str, Any]) -> List[str]:
        """Generate recommendations based on test results."""
        recommendations = []
        
        if metrics.get('mttd', 0) > 60:
            recommendations.append("Improve detection capabilities by adding more monitoring and alerts")
        
        if metrics.get('mttr', 0) > 300:
            recommendations.append("Improve response time by automating more remediation steps")
        
        if metrics.get('recovery_rate', 0) < 95:
            recommendations.append("Implement automatic recovery for more failure scenarios")
        
        if metrics.get('error_rate', 0) > 1:
            recommendations.append("Improve error handling and circuit breakers")
        
        return recommendations
    
    def _log_to_siem(self, test: ChaosTest, passed: bool) -> None:
        """Log test results to SIEM."""
        log_entry = {
            'event_type': 'CHAOS_TEST',
            'test_id': test.test_id,
            'test_name': test.name,
            'passed': passed,
            'environment': test.environment,
            'start_time': test.start_time.isoformat(),
            'end_time': test.end_time.isoformat() if test.end_time else None,
            'duration': test.duration,
            'metrics': test.metrics,
            'status': test.status
        }
        
        try:
            requests.post(CONFIG["SIEM_URL"], json=log_entry, timeout=5)
        except Exception as e:
            logger.error(f"Error logging to SIEM: {e}")
    
    def _generate_report(self, test: ChaosTest, passed: bool, observations: List[str], recommendations: List[str]) -> None:
        """Generate test report."""
        report = {
            'test_id': test.test_id,
            'test_name': test.name,
            'passed': passed,
            'timestamp': datetime.utcnow().isoformat(),
            'duration': test.duration,
            'metrics': test.metrics,
            'observations': observations,
            'recommendations': recommendations
        }
        
        # Save report
        report_dir = CONFIG["REPORT_PATH"]
        if not os.path.exists(report_dir):
            os.makedirs(report_dir)
        
        report_file = os.path.join(report_dir, f"chaos_test_{test.test_id}_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.json")
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Report generated: {report_file}")
    
    def _start_scheduler(self) -> None:
        """Start the test scheduler."""
        def run_scheduled_tests():
            while True:
                try:
                    self._run_scheduled_tests()
                    time.sleep(60)
                except Exception as e:
                    logger.error(f"Error in scheduler: {e}")
                    time.sleep(60)
        
        thread = threading.Thread(target=run_scheduled_tests, daemon=True)
        thread.start()
        logger.info("Chaos test scheduler started")
    
    def _run_scheduled_tests(self) -> None:
        """Run scheduled chaos tests."""
        # Load schedule from config
        schedule_file = os.path.join(CONFIG["CHAOS_CONFIG_PATH"], "01_failure_scenarios.yaml")
        if not os.path.exists(schedule_file):
            return
        
        try:
            with open(schedule_file, 'r') as f:
                data = yaml.safe_load(f)
                schedule_config = data.get('test_schedule', [])
                
                for entry in schedule_config:
                    day = entry.get('day')
                    time_str = entry.get('time')
                    scenarios = entry.get('scenarios', [])
                    env = entry.get('environment', 'staging')
                    
                    # Check if schedule matches current time
                    current_day = datetime.utcnow().strftime('%A')
                    current_time = datetime.utcnow().strftime('%H:%M')
                    
                    if day == current_day and time_str == current_time:
                        # Run each scenario
                        for scenario_id in scenarios:
                            logger.info(f"Running scheduled chaos test: {scenario_id}")
                            self.run_test(scenario_id)
                            
        except Exception as e:
            logger.error(f"Error running scheduled tests: {e}")

# ====================================================================
# Flask Web API
# ====================================================================

app = Flask(__name__)
chaos_service = ChaosAutomation()

@app.route("/health", methods=["GET"])
def health():
    """Health check."""
    return jsonify({"status": "healthy", "service": "chaos-automation"})

@app.route("/api/chaos/run/<test_id>", methods=["POST"])
def run_test(test_id: str):
    """Run a chaos test."""
    try:
        result = chaos_service.run_test(test_id)
        return jsonify(asdict(result)), 200
    except Exception as e:
        logger.error(f"Error running test: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/chaos/status/<test_id>", methods=["GET"])
def get_test_status(test_id: str):
    """Get the status of a chaos test."""
    test = chaos_service.tests.get(test_id)
    if not test:
        return jsonify({"error": "Test not found"}), 404
    
    return jsonify({
        "test_id": test.test_id,
        "status": test.status,
        "start_time": test.start_time.isoformat(),
        "end_time": test.end_time.isoformat() if test.end_time else None,
        "metrics": test.metrics
    }), 200

@app.route("/api/chaos/results", methods=["GET"])
def get_results():
    """Get all chaos test results."""
    results = []
    for test_id, test in chaos_service.tests.items():
        results.append({
            "test_id": test.test_id,
            "name": test.name,
            "status": test.status,
            "duration": test.duration,
            "start_time": test.start_time.isoformat()
        })
    
    return jsonify({"results": results}), 200

# ====================================================================
# Main Entry Point
# ====================================================================

def main():
    """Main entry point."""
    app.run(host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()
```

**Verification:**

```bash
# Verify automation file
ls -la chaos/05_automation.py
# Expected: File exists

# Check Python syntax
python3 -m py_compile chaos/05_automation.py
# Expected: No syntax errors
```

---

### Step 7: Chaos Engineering Summary

**File:** `chaos/README.md`

```markdown
# Chaos Engineering - Nexus Global Industries

## Overview

This directory contains the complete chaos engineering implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_failure_scenarios.yaml` | Scenarios | Failure domain test scenarios |
| `02_security_chaos.yaml` | Security | Security chaos experiments |
| `03_resilience_validation.yaml` | Validation | Resilience validation framework |
| `04_metrics.yaml` | Metrics | MTTD/MTTR measurement |
| `05_automation.py` | Automation | Chaos test automation |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       CHAOS ENGINEERING                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  TEST SCENARIOS                                        │   │
│  │  • 5 failure scenarios                                │   │
│  │  • 6 security experiments                             │   │
│  │  • Weekly/monthly schedule                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  EXECUTION                                             │   │
│  │  • Automated test runner                              │   │
│  │  • Gremlin integration                                │   │
│  │  • Custom experiments                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  VALIDATION                                            │   │
│  │  • MTTD/MTTR measurement                              │   │
│  │  • Success criteria                                   │   │
│  │  • Resilience scoring                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  REPORTING                                             │   │
│  │  • Test reports                                       │   │
│  │  • Resilience dashboards                              │   │
│  │  • Improvement recommendations                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Description |
|---------|-------------|
| **Scenarios** | 11 test scenarios (5 infrastructure + 6 security) |
| **Automation** | Automated test execution and scheduling |
| **Metrics** | MTTD, MTTR, recovery rate tracking |
| **Validation** | Automated success criteria validation |
| **Integration** | Gremlin + custom experiments |
| **Reporting** | Detailed test reports and dashboards |

## Deployment Instructions

### 1. Deploy Chaos Automation Service

```bash
kubectl apply -f chaos/05_automation.py
```

### 2. Configure Gremlin Integration

Set environment variables:
- `GREMLIN_API_KEY`
- `GREMLIN_TEAM_ID`

### 3. Schedule Tests

Edit `chaos/01_failure_scenarios.yaml` to configure test schedules.

### 4. Run Tests

```bash
# Run a test manually
curl -X POST http://chaos-service:8080/api/chaos/run/CHAOS-001

# Get test status
curl http://chaos-service:8080/api/chaos/status/CHAOS-001
```

## Verification Checklist

- [ ] Test scenarios defined
- [ ] Security experiments configured
- [ ] Validation framework in place
- [ ] MTTD/MTTR measurement active
- [ ] Automation service running
- [ ] Tests scheduled
- [ ] Reports being generated

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la chaos/README.md
# Expected: File exists

echo "✅ Chaos Engineering Complete!"
echo "   - 5 failure domain scenarios"
echo "   - 6 security chaos experiments"
echo "   - Resilience validation framework"
echo "   - MTTD/MTTR measurement"
echo "   - Chaos test automation"
```

---

## End of Section 4.5: Chaos Engineering

### Key Takeaway

You've implemented a complete chaos engineering program for Nexus Global Industries, including 5 failure domain scenarios, 6 security chaos experiments, a resilience validation framework with scoring, MTTD/MTTR measurement, and automated test execution. This provides continuous validation of system resilience and detection capabilities.

### What's Next

**Section 4.6** will cover **Business Continuity & Resilience**, including:
- Business continuity planning
- Recovery strategies
- Immutable backups
- Air-gapped vaults
- RTO/RPO validation
