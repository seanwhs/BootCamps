# APPENDIX Q — Complete Monitoring & Alerting Configuration

## Production Observability Stack for ScaleCart

---

## Q.1 Introduction

This appendix provides comprehensive monitoring and alerting configurations for the ScaleCart platform. It covers:

1. **Prometheus Configuration** – Metrics collection
2. **Alert Manager Rules** – Alerting definitions
3. **Grafana Dashboards** – Visualization templates
4. **Logging Configuration** – ELK/EFK stack
5. **Tracing Configuration** – Jaeger/OpenTelemetry
6. **SLO/SLI Definitions** – Service Level Objectives

---

## Q.2 Prometheus Configuration

### Q.2.1 Complete Prometheus Config

```yaml
# File: prometheus.yml
# Production Prometheus configuration

global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s
  
  external_labels:
    environment: production
    cluster: scalecart-prod
    region: us-east-1

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093
      timeout: 10s
      api_version: v2

# Rule files
rule_files:
  - "alerts/*.yml"
  - "alerts/*.yaml"

# Scrape configurations
scrape_configs:
  # ============================================
  # PROMETHEUS SELF
  # ============================================
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 30s

  # ============================================
  # API SERVICE
  # ============================================
  - job_name: 'scalecart-api'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - scalecart
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: scalecart
      - source_labels: [__meta_kubernetes_pod_label_component]
        action: keep
        regex: api
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: pod
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: namespace

  # ============================================
  # POSTGRESQL
  # ============================================
  - job_name: 'postgresql'
    static_configs:
      - targets:
          - postgres-exporter:9187
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: postgres

  # ============================================
  # REDIS
  # ============================================
  - job_name: 'redis'
    static_configs:
      - targets:
          - redis-exporter:9121
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: redis

  # ============================================
  # MONGODB
  # ============================================
  - job_name: 'mongodb'
    static_configs:
      - targets:
          - mongodb-exporter:9216
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: mongodb

  # ============================================
  # NEO4J
  # ============================================
  - job_name: 'neo4j'
    static_configs:
      - targets:
          - neo4j-exporter:9100
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        replacement: neo4j

  # ============================================
  # NODE EXPORTER (Host Metrics)
  # ============================================
  - job_name: 'node'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor

  # ============================================
  # KUBERNETES CLUSTER
  # ============================================
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: kubernetes_pod_name

  # ============================================
  # KUBERNETES API SERVER
  # ============================================
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
    relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

  # ============================================
  # KUBERNETES NODES
  # ============================================
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
```

### Q.2.2 PostgreSQL Exporter Configuration

```yaml
# File: postgres-exporter-config.yaml
# PostgreSQL Exporter configuration

apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-exporter-config
  namespace: scalecart
data:
  queries.yaml: |
    # Custom queries for PostgreSQL exporter
    queries:
      - name: "table_sizes"
        query: |
          SELECT 
            schemaname,
            tablename,
            pg_total_relation_size(schemaname||'.'||tablename) as total_bytes,
            pg_relation_size(schemaname||'.'||tablename) as table_bytes,
            pg_indexes_size(schemaname||'.'||tablename) as index_bytes
          FROM pg_tables
          WHERE schemaname = 'public'
        metrics:
          - schemaname:
              usage: "LABEL"
              description: "Schema name"
          - tablename:
              usage: "LABEL"
              description: "Table name"
          - total_bytes:
              usage: "GAUGE"
              description: "Total table size in bytes"
          - table_bytes:
              usage: "GAUGE"
              description: "Table data size in bytes"
          - index_bytes:
              usage: "GAUGE"
              description: "Index size in bytes"

      - name: "active_connections"
        query: |
          SELECT 
            state,
            COUNT(*) as connections
          FROM pg_stat_activity
          GROUP BY state
        metrics:
          - state:
              usage: "LABEL"
              description: "Connection state"
          - connections:
              usage: "GAUGE"
              description: "Number of connections in this state"

      - name: "database_stats"
        query: |
          SELECT 
            datname,
            numbackends,
            xact_commit,
            xact_rollback,
            blks_read,
            blks_hit,
            tup_returned,
            tup_fetched,
            tup_inserted,
            tup_updated,
            tup_deleted,
            conflicts,
            temp_files,
            temp_bytes,
            deadlocks
          FROM pg_stat_database
          WHERE datname = 'scalecart'
        metrics:
          - datname:
              usage: "LABEL"
              description: "Database name"
          - numbackends:
              usage: "GAUGE"
              description: "Number of backends connected"
          - xact_commit:
              usage: "COUNTER"
              description: "Transactions committed"
          - xact_rollback:
              usage: "COUNTER"
              description: "Transactions rolled back"
          - blks_read:
              usage: "COUNTER"
              description: "Blocks read"
          - blks_hit:
              usage: "COUNTER"
              description: "Cache hits"
          - tup_returned:
              usage: "COUNTER"
              description: "Rows returned"
          - tup_fetched:
              usage: "COUNTER"
              description: "Rows fetched"
          - tup_inserted:
              usage: "COUNTER"
              description: "Rows inserted"
          - tup_updated:
              usage: "COUNTER"
              description: "Rows updated"
          - tup_deleted:
              usage: "COUNTER"
              description: "Rows deleted"
          - conflicts:
              usage: "COUNTER"
              description: "Conflicts"
          - temp_files:
              usage: "COUNTER"
              description: "Temporary files"
          - temp_bytes:
              usage: "COUNTER"
              description: "Temporary bytes"
          - deadlocks:
              usage: "COUNTER"
              description: "Deadlocks"
```

---

## Q.3 Alerting Rules

### Q.3.1 Critical Alerts

```yaml
# File: alerts/critical.yml
# Critical severity alerts

groups:
  - name: critical_alerts
    interval: 30s
    rules:
      # ============================================
      # SERVICE AVAILABILITY
      # ============================================
      
      - alert: APIServiceDown
        expr: absent(up{job="scalecart-api"}) or up{job="scalecart-api"} == 0
        for: 1m
        labels:
          severity: critical
          tier: application
          service: api
        annotations:
          summary: "API service is down"
          description: "The ScaleCart API service has been unreachable for {{ .Labels.instance }} for more than 1 minute."
          runbook: "https://runbooks.scalecart.com/api-down"
          dashboard: "https://grafana.scalecart.com/d/api-performance"

      - alert: DatabaseServiceDown
        expr: absent(pg_up{job="postgresql"})
        for: 1m
        labels:
          severity: critical
          tier: database
          service: postgres
        annotations:
          summary: "PostgreSQL service is down"
          description: "PostgreSQL has been unreachable for more than 1 minute."

      - alert: RedisServiceDown
        expr: absent(redis_up{job="redis"})
        for: 1m
        labels:
          severity: critical
          tier: cache
          service: redis
        annotations:
          summary: "Redis service is down"
          description: "Redis has been unreachable for more than 1 minute."

      # ============================================
      # DATABASE CRITICAL
      # ============================================

      - alert: DatabaseConnectionExhaustion
        expr: pg_stat_database_numbackends{datname="scalecart"} > 150
        for: 2m
        labels:
          severity: critical
          tier: database
          service: postgres
        annotations:
          summary: "Database connections critically high"
          description: "Database connections have exceeded 150. Current: {{ $value }}"
          runbook: "https://runbooks.scalecart.com/db-connections"

      - alert: DatabaseDeadlocks
        expr: increase(pg_stat_database_deadlocks{datname="scalecart"}[5m]) > 0
        for: 1m
        labels:
          severity: critical
          tier: database
          service: postgres
        annotations:
          summary: "Database deadlocks detected"
          description: "{{ $value }} deadlocks detected in the last 5 minutes"
          runbook: "https://runbooks.scalecart.com/deadlocks"

      - alert: DatabaseDiskSpaceCritical
        expr: (pg_database_size_bytes{datname="scalecart"} / 1024 / 1024 / 1024) > 80
        for: 1m
        labels:
          severity: critical
          tier: database
          service: postgres
        annotations:
          summary: "Database disk space critically low"
          description: "Database size is {{ $value }}GB. Disk space is running out."

      # ============================================
      # APPLICATION CRITICAL
      # ============================================

      - alert: HighAPIErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5..", job="scalecart-api"}[5m])) /
          sum(rate(http_requests_total{job="scalecart-api"}[5m])) > 0.10
        for: 5m
        labels:
          severity: critical
          tier: application
          service: api
        annotations:
          summary: "API error rate critically high"
          description: "API 5xx error rate is {{ $value | humanizePercentage }} for the last 5 minutes"
          runbook: "https://runbooks.scalecart.com/high-error-rate"

      - alert: SlowAPIResponses
        expr: |
          histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{job="scalecart-api"}[5m])) > 2
        for: 5m
        labels:
          severity: critical
          tier: application
          service: api
        annotations:
          summary: "API response time critically slow"
          description: "99th percentile response time is {{ $value }}s, exceeding 2s threshold"

      - alert: APICacheHitRateLow
        expr: |
          (redis_keyspace_hits_total - redis_keyspace_hits_total offset 5m) /
          ((redis_keyspace_hits_total - redis_keyspace_hits_total offset 5m) +
           (redis_keyspace_misses_total - redis_keyspace_misses_total offset 5m)) < 0.6
        for: 10m
        labels:
          severity: critical
          tier: cache
          service: redis
        annotations:
          summary: "Cache hit rate critically low"
          description: "Cache hit rate is {{ $value | humanizePercentage }}, below 60% threshold"

      # ============================================
      # INFRASTRUCTURE CRITICAL
      # ============================================

      - alert: NodeDiskSpaceCritical
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) < 0.05
        for: 5m
        labels:
          severity: critical
          tier: infrastructure
        annotations:
          summary: "Node disk space critically low"
          description: "Node {{ $labels.instance }} has only {{ $value | humanizePercentage }} disk space remaining"

      - alert: NodeMemoryCritical
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.95
        for: 5m
        labels:
          severity: critical
          tier: infrastructure
        annotations:
          summary: "Node memory critically high"
          description: "Node {{ $labels.instance }} memory usage is {{ $value | humanizePercentage }}"
```

### Q.3.2 Warning Alerts

```yaml
# File: alerts/warning.yml
# Warning severity alerts

groups:
  - name: warning_alerts
    interval: 60s
    rules:
      # ============================================
      # DATABASE WARNINGS
      # ============================================

      - alert: DatabaseConnectionHigh
        expr: pg_stat_database_numbackends{datname="scalecart"} > 100
        for: 5m
        labels:
          severity: warning
          tier: database
          service: postgres
        annotations:
          summary: "Database connections high"
          description: "Database connections at {{ $value }}, approaching limit"
          dashboard: "https://grafana.scalecart.com/d/database"

      - alert: DatabaseSlowQueries
        expr: increase(pg_stat_statements_mean_time{mean_time > 1000}[5m]) > 5
        for: 5m
        labels:
          severity: warning
          tier: database
          service: postgres
        annotations:
          summary: "Slow queries detected"
          description: "{{ $value }} queries slower than 1s in the last 5 minutes"

      - alert: DatabaseBloat
        expr: (pg_table_bloat_pct) > 30
        for: 1h
        labels:
          severity: warning
          tier: database
          service: postgres
        annotations:
          summary: "Table bloat detected"
          description: "Table bloat is {{ $value }}%, consider VACUUM"

      # ============================================
      # CACHE WARNINGS
      # ============================================

      - alert: RedisMemoryHigh
        expr: redis_memory_used_bytes / redis_memory_max_bytes > 0.8
        for: 10m
        labels:
          severity: warning
          tier: cache
          service: redis
        annotations:
          summary: "Redis memory usage high"
          description: "Redis is using {{ $value | humanizePercentage }} of allocated memory"

      - alert: RedisCPUHigh
        expr: rate(redis_cpu_sys_seconds_total[5m]) > 0.5
        for: 10m
        labels:
          severity: warning
          tier: cache
          service: redis
        annotations:
          summary: "Redis CPU usage high"
          description: "Redis CPU usage is {{ $value }}%"

      # ============================================
      # APPLICATION WARNINGS
      # ============================================

      - alert: HighAPIErrorRateWarning
        expr: |
          sum(rate(http_requests_total{status=~"4..", job="scalecart-api"}[5m])) /
          sum(rate(http_requests_total{job="scalecart-api"}[5m])) > 0.05
        for: 5m
        labels:
          severity: warning
          tier: application
          service: api
        annotations:
          summary: "API client error rate high"
          description: "API 4xx error rate is {{ $value | humanizePercentage }}"

      - alert: SlowAPIResponsesWarning
        expr: |
          histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{job="scalecart-api"}[5m])) > 1
        for: 5m
        labels:
          severity: warning
          tier: application
          service: api
        annotations:
          summary: "API response time slow"
          description: "95th percentile response time is {{ $value }}s, exceeding 1s threshold"

      # ============================================
      # INFRASTRUCTURE WARNINGS
      # ============================================

      - alert: NodeCPUHigh
        expr: (100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 80
        for: 10m
        labels:
          severity: warning
          tier: infrastructure
        annotations:
          summary: "Node CPU usage high"
          description: "Node {{ $labels.instance }} CPU usage is {{ $value }}%"

      - alert: NodeMemoryHigh
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.85
        for: 10m
        labels:
          severity: warning
          tier: infrastructure
        annotations:
          summary: "Node memory usage high"
          description: "Node {{ $labels.instance }} memory usage is {{ $value | humanizePercentage }}"

      - alert: NodeDiskSpaceWarning
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) < 0.15
        for: 5m
        labels:
          severity: warning
          tier: infrastructure
        annotations:
          summary: "Node disk space low"
          description: "Node {{ $labels.instance }} has only {{ $value | humanizePercentage }} disk space remaining"
```

---

## Q.4 Grafana Dashboards

### Q.4.1 API Performance Dashboard

```json
{
  "dashboard": {
    "title": "ScaleCart API Performance",
    "uid": "api-performance",
    "timezone": "browser",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[1m])) by (method)",
            "legendFormat": "{{method}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "title": "Response Time (p95)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint))",
            "legendFormat": "{{endpoint}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100",
            "legendFormat": "Error Rate"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 0, "y": 8}
      },
      {
        "title": "Active Requests",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(http_requests_in_progress)",
            "legendFormat": "Active"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 4, "y": 8}
      },
      {
        "title": "Throughput (req/s)",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[1m]))",
            "legendFormat": "Throughput"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 8, "y": 8}
      },
      {
        "title": "Endpoint Performance",
        "type": "table",
        "targets": [
          {
            "expr": "topk(10, sum(rate(http_request_duration_seconds_sum[1h])) by (endpoint))",
            "legendFormat": "{{endpoint}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 12}
      },
      {
        "title": "Status Code Distribution",
        "type": "piechart",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (status)",
            "legendFormat": "{{status}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 12}
      }
    ],
    "time": {"from": "now-1h", "to": "now"}
  }
}
```

### Q.4.2 Database Dashboard

```json
{
  "dashboard": {
    "title": "ScaleCart Database",
    "uid": "database",
    "panels": [
      {
        "title": "Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends{datname=\"scalecart\"}",
            "legendFormat": "Connections"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "title": "Cache Hit Ratio",
        "type": "graph",
        "targets": [
          {
            "expr": "(sum(pg_stat_database_blks_hit) / (sum(pg_stat_database_blks_hit) + sum(pg_stat_database_blks_read))) * 100",
            "legendFormat": "Cache Hit %"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "title": "Transactions",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(pg_stat_database_xact_commit[5m])",
            "legendFormat": "Commits"
          },
          {
            "expr": "rate(pg_stat_database_xact_rollback[5m])",
            "legendFormat": "Rollbacks"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "title": "Database Size",
        "type": "stat",
        "targets": [
          {
            "expr": "pg_database_size_bytes{datname=\"scalecart\"} / 1024 / 1024 / 1024",
            "legendFormat": "Size (GB)"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 12, "y": 8}
      },
      {
        "title": "Slow Queries",
        "type": "graph",
        "targets": [
          {
            "expr": "increase(pg_stat_statements_mean_time{mean_time > 1000}[5m])",
            "legendFormat": "Slow Queries"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 16}
      }
    ]
  }
}
```

### Q.4.3 Redis Dashboard

```json
{
  "dashboard": {
    "title": "ScaleCart Redis",
    "uid": "redis",
    "panels": [
      {
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "redis_memory_used_bytes",
            "legendFormat": "Used"
          },
          {
            "expr": "redis_memory_max_bytes",
            "legendFormat": "Max"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "title": "Hit Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "(redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total)) * 100",
            "legendFormat": "Hit Rate %"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 12, "y": 0}
      },
      {
        "title": "Commands per Second",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(redis_commands_total[1m])",
            "legendFormat": "Commands/s"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "title": "Connected Clients",
        "type": "stat",
        "targets": [
          {
            "expr": "redis_connected_clients",
            "legendFormat": "Clients"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 12, "y": 8}
      }
    ]
  }
}
```

---

## Q.5 Logging Configuration

### Q.5.1 Filebeat Configuration

```yaml
# File: filebeat.yml
# Filebeat configuration for log shipping

filebeat.inputs:
  - type: container
    paths:
      - /var/lib/docker/containers/*/*.log
    processors:
      - add_docker_metadata:
          host: "unix:///var/run/docker.sock"

  - type: log
    enabled: true
    paths:
      - /var/log/scalecart/*.log
    fields:
      log_type: scalecart-app

  - type: log
    enabled: true
    paths:
      - /var/log/postgresql/*.log
    fields:
      log_type: postgresql

  - type: log
    enabled: true
    paths:
      - /var/log/nginx/*.log
    fields:
      log_type: nginx

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "scalecart-%{+yyyy.MM.dd}"
  username: "elastic"
  password: "${ELASTIC_PASSWORD}"

setup.kibana:
  host: "kibana:5601"

setup.template.name: "scalecart"
setup.template.pattern: "scalecart-*"

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~
```

### Q.5.2 Logstash Pipeline

```ruby
# File: logstash.conf
# Logstash pipeline configuration

input {
  beats {
    port => 5044
  }
  tcp {
    port => 5000
    codec => json_lines
  }
}

filter {
  # Parse JSON logs
  if [log_type] == "scalecart-app" {
    json {
      source => "message"
      target => "json"
    }
    
    # Extract log level
    if [json][level] {
      mutate {
        add_field => { "log_level" => "%{[json][level]}" }
      }
    }
    
    # Extract request ID for tracing
    if [json][request_id] {
      mutate {
        add_field => { "request_id" => "%{[json][request_id]}" }
      }
    }
    
    # GeoIP lookup
    geoip {
      source => "[json][client_ip]"
      target => "geoip"
      database => "/usr/share/logstash/GeoLite2-City.mmdb"
    }
  }
  
  # Parse PostgreSQL logs
  if [log_type] == "postgresql" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:log_level}:  %{GREEDYDATA:query}" }
    }
    
    # Extract query duration
    if [query] {
      grok {
        match => { "query" => "duration: %{NUMBER:duration} ms" }
      }
    }
  }
  
  # Parse Nginx logs
  if [log_type] == "nginx" {
    grok {
      match => { "message" => "%{IP:client_ip} - %{USER:user} \[%{HTTPDATE:timestamp}\] \"%{WORD:method} %{URIPATHPARAM:request} HTTP/%{NUMBER:http_version}\" %{NUMBER:response_code} %{NUMBER:bytes_sent} \"%{URI:referrer}\" \"%{DATA:user_agent}\"" }
    }
    
    # Extract response time
    if [request] {
      grok {
        match => { "request" => "%{URIPATHPARAM:uri} \?%{GREEDYDATA:query_string}" }
      }
    }
  }
  
  # Remove sensitive data
  if [json][password] {
    mutate {
      remove_field => ["[json][password]"]
    }
  }
  
  if [json][credit_card] {
    mutate {
      remove_field => ["[json][credit_card]"]
    }
  }
  
  # Add application metadata
  mutate {
    add_field => {
      "app_name" => "scalecart"
      "environment" => "production"
    }
  }
  
  # Parse date
  date {
    match => [ "timestamp", "ISO8601" ]
    target => "@timestamp"
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "scalecart-%{+YYYY.MM.dd}"
    user => "elastic"
    password => "${ELASTIC_PASSWORD}"
  }
  
  # Forward to monitoring
  if [log_level] == "ERROR" or [log_level] == "CRITICAL" {
    stdout {
      codec => rubydebug
    }
  }
}
```

---

## Q.6 Distributed Tracing

### Q.6.1 OpenTelemetry Configuration

```python
# File: src/utils/tracing.py
"""
OpenTelemetry configuration for distributed tracing.
"""

from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.instrumentation.redis import RedisInstrumentor
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.trace.sampling import TraceIdRatioBased
import os

def configure_tracing(app, db_engine):
    """Configure OpenTelemetry tracing."""
    
    # Create tracer provider
    resource = Resource(attributes={
        SERVICE_NAME: "scalecart-api",
        "environment": os.getenv("APP_ENV", "production"),
        "service.version": "1.0.0"
    })
    
    tracer_provider = TracerProvider(
        resource=resource,
        sampler=TraceIdRatioBased(0.1)  # Sample 10% of traces
    )
    
    # Configure Jaeger exporter
    jaeger_exporter = JaegerExporter(
        agent_host_name=os.getenv("JAEGER_AGENT_HOST", "jaeger"),
        agent_port=int(os.getenv("JAEGER_AGENT_PORT", 6831))
    )
    
    # Add span processor
    span_processor = BatchSpanProcessor(jaeger_exporter)
    tracer_provider.add_span_processor(span_processor)
    
    # Set as global tracer provider
    trace.set_tracer_provider(tracer_provider)
    
    # Instrument FastAPI
    FastAPIInstrumentor.instrument_app(
        app,
        tracer_provider=tracer_provider,
        excluded_urls="/health,/health/ready,/metrics"
    )
    
    # Instrument requests
    RequestsInstrumentor().instrument(tracer_provider=tracer_provider)
    
    # Instrument SQLAlchemy
    SQLAlchemyInstrumentor().instrument(
        engine=db_engine,
        tracer_provider=tracer_provider
    )
    
    # Instrument Redis
    RedisInstrumentor().instrument(tracer_provider=tracer_provider)
    
    return tracer_provider

# Usage in FastAPI
from fastapi import FastAPI
from src.utils.tracing import configure_tracing

app = FastAPI()
tracer = configure_tracing(app, db_engine)

# Add custom spans
from opentelemetry import trace

@router.get("/api/v1/products")
async def get_products():
    tracer = trace.get_tracer(__name__)
    
    with tracer.start_as_current_span("get_products") as span:
        span.set_attribute("category", "electronics")
        
        # Your business logic here
        products = await fetch_products()
        
        span.set_attribute("product_count", len(products))
        return products
```

---

## Q.7 SLO/SLI Definitions

### Q.7.1 SLO Configuration

```yaml
# File: slo.yaml
# Service Level Objectives for ScaleCart

apiVersion: v1
kind: ConfigMap
metadata:
  name: scalecart-slo
  namespace: scalecart
data:
  slo.yaml: |
    service_levels:
      api:
        availability:
          target: 99.9
          window: 30d
          measurement: "sum(up{job='scalecart-api'}) / count(up{job='scalecart-api'})"
          error_budget: 0.001
        
        latency:
          target: 95
          threshold: 200ms
          window: 30d
          measurement: "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
        
        error_rate:
          target: 99
          threshold: 1%
          window: 30d
          measurement: "sum(rate(http_requests_total{status=~'5..'}[5m])) / sum(rate(http_requests_total[5m]))"
      
      database:
        availability:
          target: 99.95
          window: 30d
          measurement: "pg_up"
        
        response_time:
          target: 95
          threshold: 50ms
          window: 30d
          measurement: "histogram_quantile(0.95, rate(pg_stat_database_blks_hit[5m]))"
      
      cache:
        availability:
          target: 99.99
          window: 30d
          measurement: "redis_up"
        
        hit_rate:
          target: 90
          window: 30d
          measurement: "redis_keyspace_hits_total / (redis_keyspace_hits_total + redis_keyspace_misses_total)"
```

---

## Q.8 Monitoring Commands

### Q.8.1 Quick Monitoring Commands

```bash
# ============================================
# QUICK STATUS CHECKS
# ============================================

# Check all services
kubectl get pods -n scalecart

# Check API health
curl -s http://localhost:8000/health | jq '.'

# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[].scrapeUrl'

# Check Alertmanager status
curl -s http://localhost:9093/api/v1/status | jq '.'

# Check Grafana health
curl -s http://localhost:3000/api/health | jq '.'

# Check Elasticsearch health
curl -s http://localhost:9200/_cluster/health | jq '.'

# Check Kibana status
curl -s http://localhost:5601/api/status | jq '.'

# ============================================
# METRICS QUERIES
# ============================================

# Query Prometheus API
curl -s 'http://localhost:9090/api/v1/query?query=up{job="scalecart-api"}' | jq '.data.result'

# Query for API error rate
curl -s 'http://localhost:9090/api/v1/query?query=sum(rate(http_requests_total{status=~"5.."}[5m]))/sum(rate(http_requests_total[5m]))*100' | jq '.data.result[0].value[1]'

# ============================================
# LOG QUERIES
# ============================================

# Search Elasticsearch logs
curl -X GET "http://localhost:9200/scalecart-*/_search?q=ERROR" | jq '.hits.hits[]._source.message'

# Get recent application logs
curl -X GET "http://localhost:9200/scalecart-*/_search?q=log_type:scalecart-app&sort=@timestamp:desc&size=10" | jq '.hits.hits[]._source'
```

---

**[END OF APPENDIX Q]**

*This comprehensive monitoring appendix provides everything needed to observe and alert on the ScaleCart platform in production. Use these configurations to ensure high availability and performance.*
