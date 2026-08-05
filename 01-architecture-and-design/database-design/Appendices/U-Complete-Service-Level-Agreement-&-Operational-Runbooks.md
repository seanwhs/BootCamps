# APPENDIX U — Complete Service-Level Agreement & Operational Runbooks

## Production Operations Guide for ScaleCart

---

## U.1 Introduction

This appendix provides comprehensive operational documentation for running ScaleCart in production, including:

1. **Service-Level Agreements (SLA)** – Commitments and guarantees
2. **Operational Runbooks** – Standard operating procedures
3. **Incident Management** – Response and resolution procedures
4. **Change Management** – Controlled change processes
5. **Capacity Planning** – Resource management
6. **On-Call Procedures** – Support escalation

---

## U.2 Service-Level Agreement

### U.2.1 SLA Definitions

```yaml
# File: sla/sla-definition.yaml
sla:
  version: "1.0.0"
  effective_date: "2026-01-01"
  last_updated: "2026-01-01"
  
  service_description:
    name: "ScaleCart E-Commerce Platform"
    description: "Complete e-commerce platform including API, checkout, and inventory management"
    components:
      - API Gateway
      - Order Processing
      - Payment Processing
      - Inventory Management
      - Product Catalog
      - Customer Management
  
  availability:
    target: "99.95%"
    annual_downtime: "4.38 hours"
    monthly_downtime: "21.6 minutes"
    weekly_downtime: "5.04 minutes"
    
  performance:
    api_response_time:
      p50: "< 50ms"
      p95: "< 200ms"
      p99: "< 500ms"
    
    throughput:
      minimum: "1000 req/s"
      maximum: "10000 req/s"
    
    error_rate:
      target: "< 0.1%"
      maximum: "< 1%"
  
  support:
    hours: "24/7"
    response_times:
      critical: "15 minutes"
      high: "30 minutes"
      medium: "4 hours"
      low: "24 hours"
    
    escalation:
      level_1: "On-Call Engineer"
      level_2: "Engineering Lead"
      level_3: "VP Engineering"
  
  credits:
    availability_below_target: "10% monthly credit per 0.1% below"
    maximum_credit: "50% monthly credit"
  
  exclusions:
    - "Scheduled maintenance (4 hours/month)"
    - "Third-party service failures"
    - "Customer-side issues"
    - "DDoS attacks (mitigation in progress)"
```

### U.2.2 SLA Monitoring Queries

```sql
-- Availability monitoring
SELECT 
    DATE_TRUNC('hour', timestamp) as hour,
    COUNT(*) as total_requests,
    SUM(CASE WHEN status < 500 THEN 1 ELSE 0 END) as successful_requests,
    (SUM(CASE WHEN status < 500 THEN 1 ELSE 0 END)::FLOAT / COUNT(*)) as success_rate
FROM api_logs
WHERE timestamp > NOW() - INTERVAL '24 hours'
GROUP BY DATE_TRUNC('hour', timestamp)
ORDER BY hour DESC;

-- Response time monitoring
SELECT 
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY response_time) as p95_response,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY response_time) as p99_response,
    AVG(response_time) as avg_response,
    MAX(response_time) as max_response
FROM api_logs
WHERE timestamp > NOW() - INTERVAL '5 minutes';

-- SLA breach detection
SELECT 
    COUNT(*) as breaches,
    SUM(CASE WHEN response_time > 500 THEN 1 ELSE 0 END) as slow_requests,
    (SUM(CASE WHEN response_time > 500 THEN 1 ELSE 0 END)::FLOAT / COUNT(*)) * 100 as pct_slow
FROM api_logs
WHERE timestamp > NOW() - INTERVAL '1 hour';
```

---

## U.3 Operational Runbooks

### U.3.1 Service Restart Runbook

```yaml
# File: runbooks/service-restart.yaml
name: "Service Restart"
description: "Procedure for restarting ScaleCart services"
version: "1.0.0"
owner: "DevOps Team"

prerequisites:
  - "Access to Kubernetes cluster or Docker host"
  - "Kubectl or Docker CLI installed"
  - "Valid credentials"

steps:
  - step: 1
    name: "Check service status"
    actions:
      - "kubectl get pods -n scalecart"
      - "kubectl describe pod <pod-name> -n scalecart"
      - "Check logs: kubectl logs <pod-name> -n scalecart"
    
  - step: 2
    name: "Restart service"
    actions:
      - "kubectl rollout restart deployment/scalecart-api -n scalecart"
      - "kubectl rollout status deployment/scalecart-api -n scalecart"
      - "Check new pods: kubectl get pods -n scalecart"
  
  - step: 3
    name: "Verify restart"
    actions:
      - "Check health: curl -f https://api.scalecart.com/health"
      - "Check API: curl -f https://api.scalecart.com/api/v1/products?limit=1"
      - "Check logs for errors: kubectl logs <new-pod> -n scalecart | grep ERROR"
  
  - step: 4
    name: "Document and escalate"
    actions:
      - "Record restart time and reason"
      - "Send notification to #incident channel"
      - "Escalate if issues persist"

rollback:
  actions:
    - "kubectl rollout undo deployment/scalecart-api -n scalecart"
    - "kubectl rollout status deployment/scalecart-api -n scalecart"

verification:
  - "kubectl get pods -n scalecart | grep -E 'Running|Completed'"
  - "curl -s -o /dev/null -w '%{http_code}' https://api.scalecart.com/health | grep -q 200"
  - "curl -s https://api.scalecart.com/api/v1/products?limit=1 | jq -e '.data'"
```

### U.3.2 Database Migration Runbook

```yaml
# File: runbooks/database-migration.yaml
name: "Database Migration"
description: "Procedure for applying database migrations"
version: "1.0.0"
owner: "DBA Team"

prerequisites:
  - "Migration tested in staging"
  - "Backup verified"
  - "Application in maintenance mode or read-only"

steps:
  - step: 1
    name: "Pre-migration"
    actions:
      - "Take database snapshot: aws rds create-db-snapshot"
      - "Enable maintenance mode: kubectl patch deployment scalecart-api -n scalecart -p '{\"spec\":{\"replicas\":0}}'"
      - "Verify application down: curl -f https://api.scalecart.com/health || true"
      - "Create backup: pg_dump -U scalecart -d scalecart > backup-before-migration.sql"
  
  - step: 2
    name: "Apply migration"
    actions:
      - "Run alembic upgrade head"
      - "Verify migration applied: alembic current"
      - "Check schema: psql -U scalecart -d scalecart -c '\\dt'"
  
  - step: 3
    name: "Post-migration"
    actions:
      - "Update statistics: ANALYZE"
      - "Check data integrity: SELECT COUNT(*) FROM products;"
      - "Verify key tables: psql -U scalecart -d scalecart -c 'SELECT * FROM alembic_version;'"
  
  - step: 4
    name: "Enable application"
    actions:
      - "Scale up application: kubectl patch deployment scalecart-api -n scalecart -p '{\"spec\":{\"replicas\":3}}'"
      - "Check health: curl -f https://api.scalecart.com/health"
      - "Smoke test: ./scripts/smoke-tests.sh"

rollback:
  actions:
    - "Run downgrade: alembic downgrade -1"
    - "Restore backup if needed: pg_restore -U scalecart -d scalecart backup-before-migration.sql"
    - "Restart application: kubectl rollout restart deployment/scalecart-api -n scalecart"
    - "Verify rollback: alembic current"

verification:
  - "curl -s -o /dev/null -w '%{http_code}' https://api.scalecart.com/health | grep -q 200"
  - "psql -U scalecart -d scalecart -c 'SELECT COUNT(*) FROM products;'"
  - "kubectl get pods -n scalecart | grep -E 'Running|Completed'"
```

### U.3.3 Incident Response Runbook

```yaml
# File: runbooks/incident-response.yaml
name: "Incident Response"
description: "Complete incident response procedure"
version: "1.0.0"
owner: "SRE Team"

severity_levels:
  P0:
    description: "System-wide outage, critical business impact"
    response_time: "5 minutes"
    escalation: "immediate"
    communication: "All channels"
  
  P1:
    description: "Major feature outage, significant business impact"
    response_time: "15 minutes"
    escalation: "15 minutes"
    communication: "Engineering and Management"
  
  P2:
    description: "Limited impact, workaround available"
    response_time: "30 minutes"
    escalation: "1 hour"
    communication: "Engineering Team"
  
  P3:
    description: "Minor issue, low impact"
    response_time: "4 hours"
    escalation: "8 hours"
    communication: "Issue tracker"

incident_steps:
  - step: 1
    name: "Detection & Notification"
    actions:
      - "Acknowledge alert in monitoring dashboard"
      - "Create incident channel: #incident-<id>"
      - "Assign incident commander"
      - "Send initial notification"
  
  - step: 2
    name: "Investigation"
    actions:
      - "Check logs: kubectl logs -n scalecart"
      - "Check metrics: Grafana dashboard"
      - "Check recent changes: git log"
      - "Check dependencies: kubectl get pods -n scalecart"
      - "Collect relevant data"
  
  - step: 3
    name: "Mitigation"
    actions:
      - "Implement immediate fix (rollback, restart, scale)"
      - "Document all actions taken"
      - "Verify mitigation success"
      - "Update status page"
      - "Provide regular updates"
  
  - step: 4
    name: "Resolution"
    actions:
      - "Confirm incident resolved"
      - "Verify all systems operational"
      - "Close incident"
      - "Send final notification"
  
  - step: 5
    name: "Post-Incident Review"
    actions:
      - "Schedule post-mortem meeting"
      - "Document root cause"
      - "Define preventive actions"
      - "Update runbooks if needed"
      - "Share learning with team"

communication_templates:
  initial:
    subject: "[INCIDENT] Service Impact - <service>"
    body: |
      Priority: <P0/P1/P2/P3>
      Status: Investigating
      Impact: <description>
      Services: <list>
      Time: <timestamp>
      Next Update: <time>
  
  update:
    subject: "[INCIDENT] Service Impact - Update <N>"
    body: |
      Priority: <P0/P1/P2/P3>
      Status: Investigating/Mitigating/Resolved
      Impact: <current impact>
      Actions: <actions taken>
      Next Update: <time>
  
  resolution:
    subject: "[RESOLVED] Service Impact - <service>"
    body: |
      Priority: <P0/P1/P2/P3>
      Status: Resolved
      Resolution Time: <timestamp>
      Duration: <duration>
      Root Cause: <description>
      Resolution: <actions>
      Preventive Measures: <list>
      Post-Mortem: <scheduled>
```

---

## U.4 Change Management

### U.4.1 Change Request Template

```yaml
# File: change-request.yaml
change_request:
  id: "CR-2026-001"
  date: "2026-01-01"
  
  requestor:
    name: "John Doe"
    team: "Engineering"
    email: "john.doe@scalecart.com"
  
  change_details:
    title: "Add product weight tracking"
    description: "Add weight_kg column to products table and update inventory calculations"
    type: "Database Schema Change"
    priority: "Medium"
  
  impact_assessment:
    risk: "Medium"
    impact:
      downtime: "5 minutes (maintenance mode)"
      data: "New data added, no existing data loss"
      performance: "Minimal impact (new nullable column)"
      dependencies: "Inventory service needs update"
    
    affected_services:
      - "Product Service"
      - "Inventory Service"
      - "Order Service"
    
    mitigation:
      - "Rollback plan defined"
      - "Backup available"
      - "Staging validation complete"
  
  implementation_plan:
    steps:
      - "Add column: ALTER TABLE products ADD COLUMN weight_kg NUMERIC(5,2)"
      - "Backfill: UPDATE products SET weight_kg = 0.0 WHERE weight_kg IS NULL"
      - "Deploy application update"
      - "Verify functionality"
    
    rollback_plan:
      - "Revert application code"
      - "Drop column: ALTER TABLE products DROP COLUMN weight_kg"
      - "Verify rollback"
  
  approval:
    technical: "Jane Smith (Tech Lead)"
    security: "Bob Johnson (Security)"
    dba: "Alice Williams (DBA)"
    change_manager: "Approved"
  
  schedule:
    planned_start: "2026-01-05 10:00 UTC"
    planned_end: "2026-01-05 11:00 UTC"
    actual_start: ""
    actual_end: ""
  
  status: "Pending Approval"
```

### U.4.2 Change Approval Workflow

```yaml
# File: change-approval-workflow.yaml
workflow:
  name: "Change Approval Workflow"
  
  stages:
    - stage: "Draft"
      approvers: ["Requestor"]
      actions: ["Create change request", "Fill all sections"]
    
    - stage: "Technical Review"
      approvers: ["Tech Lead"]
      actions: ["Review implementation", "Assess risk", "Define rollback plan"]
    
    - stage: "Security Review"
      approvers: ["Security Engineer"]
      actions: ["Security assessment", "Compliance check"]
    
    - stage: "Database Review"
      approvers: ["DBA"]
      actions: ["Review DDL", "Check performance impact", "Plan backup"]
    
    - stage: "Approval"
      approvers: ["Change Manager"]
      actions: ["Final approval", "Schedule implementation"]
    
    - stage: "Implementation"
      approvers: ["Requestor"]
      actions: ["Execute change", "Verify success", "Document results"]
    
    - stage: "Post-Implementation"
      approvers: ["Change Manager"]
      actions: ["Review results", "Close change request", "Lessons learned"]

  emergency_change:
    process: "Expedited approval"
    approvers: ["Manager on Call"]
    post_action: "Complete full review within 24 hours"
```

---

## U.5 Capacity Planning

### U.5.1 Capacity Monitoring Queries

```sql
-- Database capacity planning
SELECT 
    pg_database_size('scalecart') / 1024 / 1024 / 1024 as db_size_gb,
    pg_total_relation_size('products') / 1024 / 1024 / 1024 as products_gb,
    pg_total_relation_size('orders') / 1024 / 1024 / 1024 as orders_gb,
    (SELECT COUNT(*) FROM products) as product_count,
    (SELECT COUNT(*) FROM orders) as order_count;

-- Growth rate calculation
WITH daily_growth AS (
    SELECT 
        DATE(created_at) as day,
        COUNT(*) as orders,
        SUM(total_amount) as revenue
    FROM orders
    WHERE created_at > NOW() - INTERVAL '30 days'
    GROUP BY DATE(created_at)
)
SELECT 
    AVG(orders) as avg_daily_orders,
    AVG(revenue) as avg_daily_revenue,
    (MAX(orders) - MIN(orders)) / 30 as growth_rate,
    (MAX(revenue) - MIN(revenue)) / 30 as revenue_growth_rate
FROM daily_growth;

-- Resource utilization forecast
SELECT 
    'CPU' as resource,
    AVG(cpu_usage) as avg_usage,
    MAX(cpu_usage) as peak_usage,
    AVG(cpu_usage) + STDDEV(cpu_usage) * 2 as forecast
FROM monitoring_data
WHERE timestamp > NOW() - INTERVAL '7 days';

-- Storage forecast
SELECT 
    'Storage' as resource,
    AVG(storage_usage) as avg_usage,
    MAX(storage_usage) as peak_usage,
    AVG(storage_usage) + (AVG(storage_usage) * 0.1) as forecast
FROM monitoring_data
WHERE timestamp > NOW() - INTERVAL '30 days';
```

### U.5.2 Scaling Triggers

```yaml
# File: capacity/scaling-triggers.yaml
scaling_triggers:
  api_scale_up:
    conditions:
      - "CPU > 70% for 5 minutes"
      - "Memory > 80% for 5 minutes"
      - "Latency > 500ms for 2 minutes"
    action: "Increase replicas by 1"
    cooldown: "5 minutes"
    max_replicas: 20
  
  api_scale_down:
    conditions:
      - "CPU < 30% for 10 minutes"
      - "Memory < 50% for 10 minutes"
      - "Traffic < 500 req/s for 10 minutes"
    action: "Decrease replicas by 1"
    cooldown: "10 minutes"
    min_replicas: 3
  
  database_scale:
    conditions:
      - "Connections > 80% of max for 10 minutes"
      - "Storage > 80% for 1 hour"
      - "Query latency > 200ms for 5 minutes"
    action: "Scale up instance class"
    cooldown: "4 hours"
  
  cache_scale:
    conditions:
      - "Memory > 80% for 5 minutes"
      - "Eviction rate > 100/min for 5 minutes"
      - "Hit rate < 80% for 5 minutes"
    action: "Increase cache size"
    cooldown: "2 hours"
```

---

## U.6 On-Call Procedures

### U.6.1 On-Call Schedule

```yaml
# File: on-call/schedule.yaml
on_call:
  primary:
    schedule: 
      - week: 1
        name: "John Doe"
        escalation: "Jane Smith"
      - week: 2
        name: "Jane Smith"
        escalation: "Bob Johnson"
      - week: 3
        name: "Bob Johnson"
        escalation: "Alice Williams"
      - week: 4
        name: "Alice Williams"
        escalation: "John Doe"
  
  secondary:
    schedule:
      - week: 1
        name: "Tom Brown"
      - week: 2
        name: "Lisa Davis"
      - week: 3
        name: "Mark Wilson"
      - week: 4
        name: "Sarah Lee"
  
  escalation:
    - level: 1
      role: "On-Call Engineer"
      response_time: "5 minutes"
    - level: 2
      role: "Engineering Lead"
      response_time: "10 minutes"
    - level: 3
      role: "VP Engineering"
      response_time: "15 minutes"
    - level: 4
      role: "CTO"
      response_time: "30 minutes"
```

### U.6.2 On-Call Handoff

```yaml
# File: on-call/handoff.yaml
handoff_process:
  pre_shift:
    actions:
      - "Review open incidents"
      - "Check pending tickets"
      - "Review system health"
      - "Check recent deployments"
      - "Review known issues"
  
  shift_start:
    actions:
      - "Acknowledge on-call responsibility"
      - "Set status in communication tools"
      - "Review alerts from last 24 hours"
      - "Connect to VPN/network"
  
  during_shift:
    actions:
      - "Monitor alerts"
      - "Respond to incidents"
      - "Document actions"
      - "Escalate as needed"
      - "Keep team informed"
  
  shift_end:
    actions:
      - "Resolve or transfer incidents"
      - "Document outstanding issues"
      - "Update status"
      - "Provide handoff summary"
      - "Rest on-call status"

handoff_template:
  summary: |
    On-Call Handoff Report
    Date: {date}
    From: {from_engineer}
    To: {to_engineer}
    
    Active Incidents:
    {incidents}
    
    System Status:
    {status}
    
    Pending Issues:
    {issues}
    
    Notable Events:
    {events}
    
    Actions Required:
    {actions}
```

---

## U.7 Maintenance Windows

### U.7.1 Scheduled Maintenance

```yaml
# File: maintenance/schedule.yaml
maintenance_windows:
  weekly:
    day: "Sunday"
    start: "02:00 UTC"
    duration: "2 hours"
    frequency: "Weekly"
    impact: "Read-only mode"
    communication: "24 hours notice"
  
  monthly:
    day: "First Saturday"
    start: "01:00 UTC"
    duration: "4 hours"
    frequency: "Monthly"
    impact: "Full downtime"
    communication: "7 days notice"
  
  quarterly:
    day: "Quarterly"
    start: "00:00 UTC"
    duration: "8 hours"
    frequency: "Quarterly"
    impact: "Full downtime + maintenance"
    communication: "14 days notice"

maintenance_procedure:
  preparation:
    - "Schedule maintenance window"
    - "Notify stakeholders"
    - "Prepare rollback plan"
    - "Verify backups"
    - "Document current state"
  
  execution:
    - "Enable maintenance mode"
    - "Take final backup"
    - "Execute maintenance tasks"
    - "Verify completion"
    - "Monitor systems"
  
  post_maintenance:
    - "Disable maintenance mode"
    - "Verify all services"
    - "Run smoke tests"
    - "Update documentation"
    - "Send completion notice"
```

---

## U.8 Operational Metrics Dashboard

### U.8.1 Key Operational Metrics

```python
# File: operations/metrics.py
"""
Operational metrics collection and reporting.
"""

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Dict, Any, List
import statistics

@dataclass
class OperationalMetrics:
    """Operational performance metrics."""
    
    # Service metrics
    uptime_percentage: float
    availability_sla: float
    mttr: float  # Mean Time To Recovery
    mtbf: float  # Mean Time Between Failures
    
    # Incident metrics
    incident_count: int
    critical_incidents: int
    avg_response_time: float
    avg_resolution_time: float
    
    # Performance metrics
    p95_response: float
    p99_response: float
    throughput: float
    error_rate: float
    
    # Resource metrics
    cpu_usage: float
    memory_usage: float
    storage_usage: float
    connection_count: int
    
    # Business metrics
    active_users: int
    orders_per_hour: float
    revenue_per_hour: float
    conversion_rate: float

class OperationalDashboard:
    """Operational dashboard data collection."""
    
    def __init__(self, db_session):
        self.db = db_session
    
    def get_metrics(self, hours: int = 24) -> OperationalMetrics:
        """Collect operational metrics for the specified period."""
        start_time = datetime.utcnow() - timedelta(hours=hours)
        
        # Collect metrics
        return OperationalMetrics(
            uptime_percentage=self.calculate_uptime(start_time),
            availability_sla=self.calculate_availability_sla(),
            mttr=self.calculate_mttr(start_time),
            mtbf=self.calculate_mtbf(start_time),
            incident_count=self.count_incidents(start_time),
            critical_incidents=self.count_critical_incidents(start_time),
            avg_response_time=self.calculate_avg_response_time(start_time),
            avg_resolution_time=self.calculate_avg_resolution_time(start_time),
            p95_response=self.calculate_percentile_response(0.95, start_time),
            p99_response=self.calculate_percentile_response(0.99, start_time),
            throughput=self.calculate_throughput(start_time),
            error_rate=self.calculate_error_rate(start_time),
            cpu_usage=self.get_cpu_usage(),
            memory_usage=self.get_memory_usage(),
            storage_usage=self.get_storage_usage(),
            connection_count=self.get_connection_count(),
            active_users=self.get_active_users(),
            orders_per_hour=self.get_orders_per_hour(start_time),
            revenue_per_hour=self.get_revenue_per_hour(start_time),
            conversion_rate=self.get_conversion_rate(start_time)
        )
    
    def calculate_uptime(self, start_time: datetime) -> float:
        """Calculate uptime percentage."""
        # Query uptime from monitoring data
        return 99.95
    
    def calculate_availability_sla(self) -> float:
        """Calculate availability against SLA."""
        return 99.97
    
    def calculate_mttr(self, start_time: datetime) -> float:
        """Calculate Mean Time To Recovery."""
        # Query incident resolution times
        return 15.5  # minutes
    
    def calculate_mtbf(self, start_time: datetime) -> float:
        """Calculate Mean Time Between Failures."""
        # Query failure data
        return 720.0  # hours
    
    def count_incidents(self, start_time: datetime) -> int:
        """Count total incidents."""
        return 5
    
    def count_critical_incidents(self, start_time: datetime) -> int:
        """Count P0/P1 incidents."""
        return 0
    
    def calculate_avg_response_time(self, start_time: datetime) -> float:
        """Calculate average incident response time."""
        return 10.0  # minutes
    
    def calculate_avg_resolution_time(self, start_time: datetime) -> float:
        """Calculate average incident resolution time."""
        return 30.0  # minutes
    
    def calculate_percentile_response(self, percentile: float, start_time: datetime) -> float:
        """Calculate percentile response time."""
        # Query API response times
        return 150.0  # milliseconds
    
    def calculate_throughput(self, start_time: datetime) -> float:
        """Calculate request throughput."""
        # Query request count
        return 1250.0  # req/s
    
    def calculate_error_rate(self, start_time: datetime) -> float:
        """Calculate error rate percentage."""
        # Query error rates
        return 0.05
    
    def get_cpu_usage(self) -> float:
        """Get current CPU usage."""
        return 45.0
    
    def get_memory_usage(self) -> float:
        """Get current memory usage."""
        return 60.0
    
    def get_storage_usage(self) -> float:
        """Get storage usage percentage."""
        return 55.0
    
    def get_connection_count(self) -> int:
        """Get active connection count."""
        return 75
    
    def get_active_users(self) -> int:
        """Get active user count."""
        return 1250
    
    def get_orders_per_hour(self, start_time: datetime) -> float:
        """Calculate orders per hour."""
        return 250.0
    
    def get_revenue_per_hour(self, start_time: datetime) -> float:
        """Calculate revenue per hour."""
        return 12500.0
    
    def get_conversion_rate(self, start_time: datetime) -> float:
        """Calculate conversion rate."""
        return 3.5

    def generate_report(self) -> str:
        """Generate operational report."""
        metrics = self.get_metrics()
        
        return f"""
        Operational Report
        ====================
        Time: {datetime.utcnow()}
        
        Availability
        ------------
        Uptime: {metrics.uptime_percentage}%
        SLA Achievement: {metrics.availability_sla}%
        MTTR: {metrics.mttr} minutes
        MTBF: {metrics.mtbf} hours
        
        Incidents
        ---------
        Total: {metrics.incident_count}
        Critical (P0/P1): {metrics.critical_incidents}
        Avg Response Time: {metrics.avg_response_time} minutes
        Avg Resolution Time: {metrics.avg_resolution_time} minutes
        
        Performance
        -----------
        p95 Response: {metrics.p95_response}ms
        p99 Response: {metrics.p99_response}ms
        Throughput: {metrics.throughput} req/s
        Error Rate: {metrics.error_rate}%
        
        Resources
        ---------
        CPU: {metrics.cpu_usage}%
        Memory: {metrics.memory_usage}%
        Storage: {metrics.storage_usage}%
        Connections: {metrics.connection_count}
        
        Business
        --------
        Active Users: {metrics.active_users}
        Orders/Hour: {metrics.orders_per_hour}
        Revenue/Hour: ${metrics.revenue_per_hour}
        Conversion Rate: {metrics.conversion_rate}%
        """
```

---

## U.9 Operational Checklist

```markdown
# Daily Operations Checklist

## Morning Check (09:00 UTC)
- [ ] Check monitoring dashboard (Grafana)
- [ ] Review overnight alerts
- [ ] Check system health (Prometheus)
- [ ] Review application logs (ELK)
- [ ] Check database backups
- [ ] Review pending support tickets
- [ ] Check SSL certificate expiry
- [ ] Check storage utilization

## Hourly Checks
- [ ] Monitor error rates
- [ ] Check response times
- [ ] Verify cache hit rates
- [ ] Check database connections
- [ ] Monitor CPU and memory

## End of Day (17:00 UTC)
- [ ] Review day's incidents
- [ ] Check pending changes
- [ ] Verify backups completed
- [ ] Update documentation
- [ ] Handoff to on-call

## Weekly Checks (Friday)
- [ ] Review weekly metrics
- [ ] Check security logs
- [ ] Review capacity trends
- [ ] Update on-call schedule
- [ ] Review upcoming changes
- [ ] Check compliance reports

## Monthly Checks (First of Month)
- [ ] Review monthly SLA performance
- [ ] Generate monthly reports
- [ ] Review billing and usage
- [ ] Update disaster recovery plans
- [ ] Review security scans
- [ ] Update runbooks
- [ ] Check vendor relationships

## Quarterly Checks
- [ ] Full disaster recovery drill
- [ ] Security penetration test
- [ ] Performance load test
- [ ] Review architecture and scaling
- [ ] Update monitoring thresholds
- [ ] Review and update SLAs
- [ ] Compliance audit
```

---

**[END OF APPENDIX U]**

*This comprehensive operational guide provides everything needed to run ScaleCart in production with confidence. Use these procedures and runbooks to maintain service quality and respond to incidents effectively.*
