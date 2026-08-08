# Primer 12: Nginx Observability & Distributed Tracing

## The Target

This primer provides a comprehensive deep-dive guide to implementing complete observability for Nginx. Understanding these concepts is essential for monitoring, debugging, and optimizing production systems.

## P12.1 Complete Observability Stack

### Observability Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    OBSERVABILITY ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                         NGINX GATEWAY                            │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐                │      │
│  │  │  Metrics   │  │    Logs    │  │   Traces   │                │      │
│  │  │  (Stats)   │  │  (JSON)    │  │  (ID)      │                │      │
│  │  └────────────┘  └────────────┘  └────────────┘                │      │
│  └──────────────────────────┬───────────────────────────────────────┘      │
│                             │                                              │
│  ┌──────────────────────────┼──────────────────────────────────────┐      │
│  │                          ▼                                      │      │
│  │          ┌─────────────────────────────────────────┐           │      │
│  │          │            COLLECTOR LAYER              │           │      │
│  │          │  ┌─────────┐  ┌─────────┐  ┌─────────┐│           │      │
│  │          │  │Prometheus│  │Logstash │  │ Jaeger ││           │      │
│  │          │  │Exporter │  │(Logs)   │  │(Traces)││           │      │
│  │          │  └─────────┘  └─────────┘  └─────────┘│           │      │
│  │          └─────────────────────────────────────────┘           │      │
│  │                          │                                      │      │
│  │          ┌─────────────────────────────────────────┐           │      │
│  │          │           STORAGE LAYER                 │           │      │
│  │          │  ┌─────────┐  ┌─────────┐  ┌─────────┐│           │      │
│  │          │  │Prometheus│  │Elastic- │  │  Jaeger ││           │      │
│  │          │  │  TSDB   │  │ search  │  │  Store  ││           │      │
│  │          │  └─────────┘  └─────────┘  └─────────┘│           │      │
│  │          └─────────────────────────────────────────┘           │      │
│  │                          │                                      │      │
│  │          ┌─────────────────────────────────────────┐           │      │
│  │          │           VISUALIZATION LAYER           │           │      │
│  │          │  ┌─────────┐  ┌─────────┐  ┌─────────┐│           │      │
│  │          │  │ Grafana │  │ Kibana  │  │  Jaeger ││           │      │
│  │          │  │Dashboards│  │   UI    │  │   UI   ││           │      │
│  │          │  └─────────┘  └─────────┘  └─────────┘│           │      │
│  │          └─────────────────────────────────────────┘           │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Docker Compose for Observability

```yaml
# docker-compose.observability.yml
version: '3.8'

services:
  # --------------------------------------------------------------------------
  # Prometheus - Metrics Collection
  # --------------------------------------------------------------------------
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
    networks:
      - observability-network

  # --------------------------------------------------------------------------
  # Grafana - Visualization
  # --------------------------------------------------------------------------
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
      - grafana-data:/var/lib/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel
    networks:
      - observability-network

  # --------------------------------------------------------------------------
  # Elasticsearch - Log Storage
  # --------------------------------------------------------------------------
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
      - xpack.security.enabled=false
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
    networks:
      - observability-network

  # --------------------------------------------------------------------------
  # Logstash - Log Processing
  # --------------------------------------------------------------------------
  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    container_name: logstash
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
      - ./logs:/var/log/nginx:ro
    ports:
      - "5000:5000"
      - "9600:9600"
    depends_on:
      - elasticsearch
    networks:
      - observability-network

  # --------------------------------------------------------------------------
  # Kibana - Log Visualization
  # --------------------------------------------------------------------------
  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    networks:
      - observability-network

  # --------------------------------------------------------------------------
  # Jaeger - Distributed Tracing
  # --------------------------------------------------------------------------
  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: jaeger
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
      - "16686:16686"  # UI
      - "14268:14268"
      - "14250:14250"
      - "9411:9411"
    environment:
      - COLLECTOR_ZIPKIN_HOST_PORT=:9411
      - COLLECTOR_OTLP_ENABLED=true
    networks:
      - observability-network

  # --------------------------------------------------------------------------
  # Nginx with OpenTracing
  # --------------------------------------------------------------------------
  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-observability
    ports:
      - "80:80"
      - "443:443"
      - "9113:9113"  # Metrics
    volumes:
      - ./nginx-observability.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
      - ./cache:/var/cache/nginx
    depends_on:
      - prometheus
      - elasticsearch
      - jaeger
    networks:
      - observability-network

networks:
  observability-network:
    driver: bridge

volumes:
  prometheus-data:
  grafana-data:
  elasticsearch-data:
```

## P12.2 Metrics Collection

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    environment: production
    region: us-east-1

scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']
    metrics_path: '/metrics'
    scrape_interval: 10s
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: prometheus:9090

  - job_name: 'nginx-stats'
    static_configs:
      - targets: ['nginx:80']
    metrics_path: '/nginx-status'
    scrape_interval: 5s

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'nginx-exporter'
    static_configs:
      - targets: ['nginx-exporter:9113']

rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

### Nginx Metrics Endpoint

```nginx
# nginx-observability.conf - Metrics endpoint
http {
    server {
        listen 127.0.0.1:9113;
        server_name localhost;
        
        location /metrics {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            # Prometheus format
            # Use nginx-prometheus-exporter for proper format
        }
    }
}
```

## P12.3 Log Aggregation

### Logstash Configuration

```ruby
# logstash.conf
input {
  file {
    path => "/var/log/nginx/access.log"
    codec => json
    start_position => "beginning"
    sincedb_path => "/dev/null"
    type => "nginx-access"
  }
  
  file {
    path => "/var/log/nginx/error.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
    type => "nginx-error"
  }
}

filter {
  if [type] == "nginx-access" {
    # Parse timestamp
    date {
      match => [ "timestamp", "ISO8601" ]
      target => "@timestamp"
    }
    
    # GeoIP lookup
    geoip {
      source => "remote_addr"
      target => "geoip"
      database => "/usr/share/logstash/GeoLite2-City.mmdb"
    }
    
    # User agent parsing
    useragent {
      source => "http_user_agent"
      target => "user_agent"
    }
    
    # Extract request details
    grok {
      match => {
        "request_uri" => "%{URIPATH:uri_path}(?:\?%{URIPARAM:query_string})?"
      }
    }
    
    # Performance metrics
    if [request_time] {
      mutate {
        convert => { "request_time" => "float" }
      }
    }
  }
  
  if [type] == "nginx-error" {
    # Parse error logs
    grok {
      match => {
        "message" => "(?<timestamp>%{TIMESTAMP_ISO8601}) \[%{LOGLEVEL:level}\] %{GREEDYDATA:message}"
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "nginx-logs-%{+YYYY.MM.dd}"
    user => "elastic"
    password => "changeme"
  }
  
  # Console output for debugging
  stdout {
    codec => rubydebug
  }
}
```

### Kibana Dashboard Configuration

```json
// kibana-dashboard.json
{
  "version": "8.10.0",
  "objects": [
    {
      "id": "nginx-logs",
      "type": "dashboard",
      "attributes": {
        "title": "Nginx Logs Dashboard",
        "panels": [
          {
            "id": "logs-count",
            "type": "visualization",
            "gridData": {"x": 0, "y": 0, "w": 6, "h": 3},
            "panelIndex": 1
          },
          {
            "id": "status-codes",
            "type": "visualization",
            "gridData": {"x": 6, "y": 0, "w": 6, "h": 3},
            "panelIndex": 2
          },
          {
            "id": "request-times",
            "type": "visualization",
            "gridData": {"x": 0, "y": 3, "w": 12, "h": 4},
            "panelIndex": 3
          },
          {
            "id": "geo-location",
            "type": "visualization",
            "gridData": {"x": 0, "y": 7, "w": 6, "h": 4},
            "panelIndex": 4
          },
          {
            "id": "error-analysis",
            "type": "visualization",
            "gridData": {"x": 6, "y": 7, "w": 6, "h": 4},
            "panelIndex": 5
          }
        ]
      }
    }
  ]
}
```

## P12.4 Distributed Tracing

### OpenTracing Configuration

```nginx
# nginx-tracing.conf
http {
    # Load OpenTracing module
    # Note: Requires nginx-opentracing module
    
    opentracing on;
    opentracing_load_tracer /usr/local/lib/libjaeger.so /etc/nginx/jaeger-config.json;
    
    server {
        location /api/ {
            # Start a new span for each request
            opentracing_operation_name "API Request";
            opentracing_propagate_context;
            opentracing_operation_name $request_uri;
            
            # Add custom tags
            opentracing_tag "http.method" $request_method;
            opentracing_tag "http.url" $request_uri;
            opentracing_tag "http.status" $status;
            
            # Extract trace context from headers
            opentracing_operation_name $request_uri;
            opentracing_propagate_context;
            
            proxy_pass http://backend/;
            
            # Forward trace headers
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Trace-ID $opentracing_context_id;
            proxy_set_header X-Span-ID $opentracing_span_id;
            
            # Inject trace context into upstream request
            opentracing_propagate_context;
            opentracing_inject_context "uber-trace-id";
        }
    }
}
```

### Jaeger Configuration

```json
// jaeger-config.json
{
  "service_name": "nginx-gateway",
  "sampler": {
    "type": "probabilistic",
    "param": 0.1
  },
  "reporter": {
    "localAgentHostPort": "jaeger:6831",
    "flushInterval": 1000,
    "maxQueueSize": 10000
  },
  "headers": {
    "jaegerHeader": "uber-trace-id",
    "baggageHeaderPrefix": "baggage-"
  },
  "baggage_restrictions": {
    "denyBaggageOnInitializationFailure": false,
    "hostPort": ""
  },
  "throttler": {
    "hostPort": "",
    "refreshInterval": 60
  }
}
```

## P12.5 Grafana Dashboards

### Complete Nginx Dashboard

```json
// grafana-nginx-dashboard.json
{
  "dashboard": {
    "title": "Nginx Production Dashboard",
    "tags": ["nginx", "production"],
    "timezone": "browser",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "targets": [
          {
            "expr": "rate(nginx_http_requests_total[1m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ]
      },
      {
        "title": "Response Times (Percentiles)",
        "type": "graph",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(nginx_http_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "p95"
          },
          {
            "expr": "histogram_quantile(0.99, sum(rate(nginx_http_request_duration_seconds_bucket[5m])) by (le))",
            "legendFormat": "p99"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "gridPos": {"h": 4, "w": 4, "x": 0, "y": 8},
        "targets": [
          {
            "expr": "sum(rate(nginx_http_requests_total{status=~\"5..\"}[5m])) / sum(rate(nginx_http_requests_total[5m]))"
          }
        ]
      },
      {
        "title": "Active Connections",
        "type": "stat",
        "gridPos": {"h": 4, "w": 4, "x": 4, "y": 8},
        "targets": [
          {
            "expr": "nginx_connections_active"
          }
        ]
      },
      {
        "title": "Cache Hit Ratio",
        "type": "stat",
        "gridPos": {"h": 4, "w": 4, "x": 8, "y": 8},
        "targets": [
          {
            "expr": "sum(rate(nginx_cache_status{HIT})) / sum(rate(nginx_cache_status))"
          }
        ]
      },
      {
        "title": "Upstream Status",
        "type": "table",
        "gridPos": {"h": 8, "w": 6, "x": 0, "y": 12},
        "targets": [
          {
            "expr": "nginx_upstream_status"
          }
        ]
      },
      {
        "title": "Top Endpoints",
        "type": "table",
        "gridPos": {"h": 8, "w": 6, "x": 6, "y": 12},
        "targets": [
          {
            "expr": "topk(10, sum(rate(nginx_http_requests_total[1h])) by (uri))"
          }
        ]
      },
      {
        "title": "Geographic Distribution",
        "type": "worldmap",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 12},
        "targets": [
          {
            "expr": "sum(rate(nginx_http_requests_total[1h])) by (country)"
          }
        ]
      }
    ]
  }
}
```

## P12.6 Alert Rules

### Prometheus Alert Rules

```yaml
# alerts.yml
groups:
  - name: nginx_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: sum(rate(nginx_http_requests_total{status=~"5.."}[5m])) / sum(rate(nginx_http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
          service: nginx
        annotations:
          summary: "High error rate on Nginx"
          description: "Error rate is {{ $value }}% for the last 5 minutes"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, sum(rate(nginx_http_request_duration_seconds_bucket[5m])) by (le)) > 1
        for: 5m
        labels:
          severity: warning
          service: nginx
        annotations:
          summary: "High response time on Nginx"
          description: "95th percentile response time is {{ $value }}s"

      - alert: UpstreamDown
        expr: nginx_upstream_status{status=~"5.."} > 0
        for: 1m
        labels:
          severity: critical
          service: nginx
        annotations:
          summary: "Upstream service is down"
          description: "{{ $labels.upstream }} is returning errors"

      - alert: LowCacheHitRate
        expr: sum(rate(nginx_cache_status{HIT})) / sum(rate(nginx_cache_status)) < 0.6
        for: 10m
        labels:
          severity: warning
          service: nginx
        annotations:
          summary: "Low cache hit rate"
          description: "Cache hit rate is {{ $value }}%"

      - alert: SSLExpiry
        expr: nginx_ssl_cert_expiry < 86400 * 30
        for: 1m
        labels:
          severity: critical
          service: nginx
        annotations:
          summary: "SSL certificate expiring soon"
          description: "Certificate expires in {{ $value }} seconds"

      - alert: ConnectionExhaustion
        expr: nginx_connections_active > nginx_connections_available * 0.8
        for: 2m
        labels:
          severity: warning
          service: nginx
        annotations:
          summary: "Nginx connections exhausted"
          description: "Active connections: {{ $value }}"

      - alert: RequestRateDrop
        expr: sum(rate(nginx_http_requests_total[5m])) < sum(rate(nginx_http_requests_total[1h])) * 0.5
        for: 5m
        labels:
          severity: critical
          service: nginx
        annotations:
          summary: "Sudden drop in request rate"
          description: "Request rate dropped by 50% compared to average"

      - alert: HighMemoryUsage
        expr: (nginx_process_memory_usage_bytes / 1024 / 1024) > 500
        for: 5m
        labels:
          severity: warning
          service: nginx
        annotations:
          summary: "High memory usage on Nginx"
          description: "Memory usage is {{ $value }}MB"
```

## P12.7 Monitoring Scripts

### Health Check Script

**File: `observability-health-check.sh`**

```bash
#!/bin/bash
# observability-health-check.sh - Complete health check

echo "=== Observability Health Check ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check service
check_service() {
    local name=$1
    local endpoint=$2
    local expected=$3
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null)
    
    if [ "$response" = "$expected" ]; then
        echo -e "${GREEN}✓ $name is healthy${NC}"
        return 0
    else
        echo -e "${RED}✗ $name is unhealthy (HTTP $response)${NC}"
        return 1
    fi
}

# Check all services
echo "1. Service Health:"
check_service "Prometheus" "http://prometheus:9090/-/healthy" "200"
check_service "Grafana" "http://grafana:3000/api/health" "200"
check_service "Elasticsearch" "http://elasticsearch:9200/_cluster/health" "200"
check_service "Logstash" "http://logstash:9600/_node/stats" "200"
check_service "Kibana" "http://kibana:5601/api/status" "200"
check_service "Jaeger" "http://jaeger:16686/api/services" "200"

echo ""
echo "2. Metrics Collection:"
echo "Nginx metrics: $(curl -s http://prometheus:9090/api/v1/query?query=nginx_connections_active | python -m json.tool | grep -c 'result')"
echo ""

echo "3. Log Collection:"
echo "Log entries in Elasticsearch:"
curl -s -X GET "http://elasticsearch:9200/nginx-logs-*/_count" | python -m json.tool | grep count

echo ""
echo "4. Tracing Collection:"
echo "Traces in Jaeger: $(curl -s http://jaeger:16686/api/traces | python -m json.tool | grep -c 'traceID')"

echo ""
echo "5. System Resources:"
echo "Memory: $(docker stats --no-stream --format "{{.MemPerc}}" 2>/dev/null | head -1)"
echo "CPU: $(docker stats --no-stream --format "{{.CPUPerc}}" 2>/dev/null | head -1)"

echo ""
echo "Observability stack health check complete!"
```

---

This primer provides a comprehensive deep dive into implementing complete observability for Nginx. Use these techniques to monitor, debug, and optimize your production systems effectively.
