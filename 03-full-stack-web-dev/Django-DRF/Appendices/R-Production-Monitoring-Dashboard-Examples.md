# Appendix R: Production Monitoring Dashboard Examples

## Complete Monitoring Dashboard Examples

Welcome to **Appendix R** of the Django REST Framework & Next.js 16 masterclass. This appendix provides complete examples of production monitoring dashboards using Prometheus and Grafana, along with key metrics and alerts you should monitor in production.

---

## Section 1: API Monitoring Dashboard

### 1.1 Key Metrics to Monitor

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| **Request Rate** | Requests per second | Traffic spikes/drops |
| **Error Rate** | Percentage of 5xx errors | > 5% over 5 minutes |
| **Response Time** | P95 response time | > 500ms |
| **Active Users** | Concurrent users | Scaling decisions |
| **API Availability** | Uptime percentage | < 99.9% |

### 1.2 Prometheus Queries

```promql
# Request rate per endpoint
sum(rate(http_requests_total[5m])) by (endpoint)

# Error rate percentage
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100

# 95th percentile response time
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint))

# 99th percentile response time
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint))

# Average response time
sum(rate(http_request_duration_seconds_sum[5m])) / sum(rate(http_request_duration_seconds_count[5m]))

# Active connections
sum(nginx_http_connections) by (state)
```

### 1.3 Grafana Dashboard JSON

```json
{
  "title": "TaskFlow - API Monitoring",
  "uid": "api-dashboard",
  "tags": ["taskflow", "api", "production"],
  "timezone": "browser",
  "schemaVersion": 16,
  "version": 1,
  "refresh": "30s",
  "panels": [
    {
      "title": "Request Rate",
      "type": "graph",
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
      "targets": [
        {
          "expr": "sum(rate(http_requests_total[5m])) by (endpoint)",
          "legendFormat": "{{ endpoint }}"
        }
      ]
    },
    {
      "title": "Response Time (P95)",
      "type": "graph",
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
      "targets": [
        {
          "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint))",
          "legendFormat": "{{ endpoint }}"
        }
      ]
    },
    {
      "title": "Error Rate",
      "type": "graph",
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8},
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100",
          "legendFormat": "Error %"
        }
      ]
    },
    {
      "title": "Active Users",
      "type": "stat",
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8},
      "targets": [
        {
          "expr": "active_users"
        }
      ]
    }
  ]
}
```

---

## Section 2: Database Monitoring Dashboard

### 2.1 Key PostgreSQL Metrics

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| **Connections** | Active database connections | > 80% of pool |
| **Query Duration** | Average query execution time | > 100ms |
| **Cache Hit Ratio** | Percentage of cache hits | < 95% |
| **Transaction Rate** | Transactions per second | Traffic spikes |
| **Table Size** | Database table sizes | Growth alerts |

### 2.2 Prometheus Queries

```promql
# Active connections
pg_stat_database_numbackends{datname="taskflow_db"}

# Cache hit ratio
(pg_stat_database_blks_hit{datname="taskflow_db"} / 
 (pg_stat_database_blks_hit{datname="taskflow_db"} + 
  pg_stat_database_blks_read{datname="taskflow_db"})) * 100

# Query duration (if using pg_stat_statements)
rate(pg_stat_statements_total_time[5m]) / rate(pg_stat_statements_calls[5m])

# Table size
pg_table_size_bytes{relname="tasks_task"} / 1024 / 1024
```

### 2.3 PostgreSQL Monitoring Grafana Dashboard

```json
{
  "title": "TaskFlow - Database Monitoring",
  "uid": "db-dashboard",
  "tags": ["taskflow", "database", "postgres"],
  "panels": [
    {
      "title": "Database Connections",
      "type": "graph",
      "targets": [
        {
          "expr": "pg_stat_database_numbackends{datname=\"taskflow_db\"}",
          "legendFormat": "Active Connections"
        }
      ]
    },
    {
      "title": "Cache Hit Ratio",
      "type": "graph",
      "targets": [
        {
          "expr": "(pg_stat_database_blks_hit{datname=\"taskflow_db\"} / (pg_stat_database_blks_hit{datname=\"taskflow_db\"} + pg_stat_database_blks_read{datname=\"taskflow_db\"})) * 100",
          "legendFormat": "Cache Hit %"
        }
      ]
    },
    {
      "title": "Table Sizes",
      "type": "graph",
      "targets": [
        {
          "expr": "pg_table_size_bytes / 1024 / 1024",
          "legendFormat": "{{relname}}"
        }
      ]
    }
  ]
}
```

---

## Section 3: System Monitoring Dashboard

### 3.1 Key System Metrics

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| **CPU Usage** | CPU utilization | > 80% sustained |
| **Memory Usage** | Memory utilization | > 85% |
| **Disk Usage** | Disk space utilization | > 80% |
| **Network I/O** | Network throughput | Traffic spikes |
| **Container Health** | Container status | Any unhealthy |

### 3.2 Prometheus Queries

```promql
# CPU usage
(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100

# Memory usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Container CPU usage
rate(container_cpu_usage_seconds_total[5m]) / container_spec_cpu_quota

# Container memory usage
container_memory_working_set_bytes / container_spec_memory_limit_bytes * 100
```

---

## Section 4: Alert Rules Configuration

### 4.1 prometheus-rules.yml

```yaml
groups:
  - name: api_alerts
    rules:
      - alert: HighErrorRate
        expr: 'sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05'
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: 'High error rate: {{ $value }}%'
          description: 'Error rate is {{ $value }}% on {{ $labels.instance }}'

      - alert: SlowResponseTime
        expr: 'histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 0.5'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'Slow response time: {{ $value }}s'
          description: 'P95 response time is {{ $value }}s'

  - name: infrastructure_alerts
    rules:
      - alert: HighCPUUsage
        expr: '(1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100 > 80'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'High CPU usage: {{ $value }}%'
          description: 'CPU usage is {{ $value }}% on {{ $labels.instance }}'

      - alert: HighMemoryUsage
        expr: '(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'High memory usage: {{ $value }}%'
          description: 'Memory usage is {{ $value }}% on {{ $labels.instance }}'

      - alert: LowDiskSpace
        expr: '(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 80'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'Low disk space: {{ $value }}% used'
          description: 'Disk usage is {{ $value }}% on {{ $labels.instance }}'

      - alert: DatabaseConnectionHigh
        expr: 'pg_stat_database_numbackends{datname="taskflow_db"} > 20'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'Database connections high: {{ $value }}'
          description: 'Database connections: {{ $value }}'

      - alert: ContainerDown
        expr: 'container_state_running == 0'
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: 'Container {{ $labels.container }} is down'
          description: 'Container {{ $labels.container }} is not running'

  - name: cache_alerts
    rules:
      - alert: LowCacheHitRate
        expr: '(redis_keyspace_hits / (redis_keyspace_hits + redis_keyspace_misses)) * 100 < 80'
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: 'Low cache hit rate: {{ $value }}%'
          description: 'Cache hit rate is {{ $value }}%'

      - alert: RedisMemoryHigh
        expr: 'redis_memory_used_bytes / redis_memory_max_bytes * 100 > 85'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'Redis memory high: {{ $value }}%'
          description: 'Redis is using {{ $value }}% of max memory'
```

---

## Section 5: Log Aggregation Configuration

### 5.1 Loki Configuration

**loki-config.yml:**
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s
  max_transfer_retries: 0

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/boltdb-shipper-active
    cache_location: /loki/boltdb-shipper-cache
    cache_ttl: 24h
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
```

### 5.2 LogQL Queries

```logql
# Error logs
{container="taskflow-backend"} |= "ERROR"

# API errors
{container="taskflow-backend"} |= "status=5"

# Slow requests
{container="taskflow-backend"} |= "duration" | duration > 0.5

# User actions
{container="taskflow-backend"} |= "user_id" | json

# Rate of errors
count_over_time({container="taskflow-backend"} |= "ERROR" [5m])

# Error rate by endpoint
sum by (path) (count_over_time({container="taskflow-backend"} |= "status=5" [5m]))
```

---

## Section 6: Alertmanager Configuration

**alertmanager.yml:**
```yaml
route:
  group_by: ['alertname', 'cluster']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'default'

receivers:
- name: 'default'
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/xxx/yyy/zzz'
    channel: '#alerts'
    send_resolved: true
    title: '{{ .GroupLabels.alertname }}'
    text: |
      {{ range .Alerts }}
      *Alert:* {{ .Annotations.summary }}
      *Description:* {{ .Annotations.description }}
      *Severity:* {{ .Labels.severity }}
      *Instance:* {{ .Labels.instance }}
      *Value:* {{ .Annotations.value }}
      {{ end }}

  email_configs:
  - to: 'team@taskflow.com'
    from: 'alerts@taskflow.com'
    smarthost: 'smtp.gmail.com:587'
    auth_username: 'alerts@taskflow.com'
    auth_password: 'app-password'

inhibit_rules:
- source_match:
    severity: 'critical'
  target_match:
    severity: 'warning'
  equal: ['alertname', 'cluster']
```

---

*This concludes Appendix R. Use these examples to set up comprehensive monitoring for your production application.*
