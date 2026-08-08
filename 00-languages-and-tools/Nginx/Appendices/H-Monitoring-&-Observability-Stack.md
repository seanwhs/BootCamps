# Appendix H: Monitoring & Observability Stack

## The Target

This appendix provides a complete monitoring and observability stack for Nginx in production. You'll learn how to set up metrics collection, visualization, alerting, and log analysis to ensure your Nginx gateway is always performing optimally.

## H.1 Complete Monitoring Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                    NGINX GATEWAY                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  Metrics    │  │   Logs      │  │   Traces    │            │
│  │  /metrics   │  │  /logs      │  │  /traces    │            │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘            │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                   OBSERVABILITY STACK                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Prometheus      │  Elasticsearch   │  Jaeger          │   │
│  │  (Metrics)       │  (Logs)          │  (Traces)        │   │
│  └─────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Grafana          │  Kibana          │  Jaeger UI       │   │
│  │  (Dashboards)     │  (Visualization) │  (Traces UI)     │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ALERT MANAGER                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Alertmanager   │  PagerDuty      │  Email             │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## H.2 Nginx Metrics Configuration

### Prometheus Metrics Endpoint

**File: `nginx-prometheus.conf`**

```nginx
# Enable Prometheus metrics in nginx.conf

http {
    # ... other configuration ...
    
    server {
        listen 127.0.0.1:9113;
        server_name localhost;
        
        location /metrics {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
        }
        
        location /health {
            return 200 "OK\n";
            access_log off;
        }
    }
}
```

### Prometheus Exporter (Docker)

**File: `docker-compose.metrics.yml`**

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:1.27-alpine
    volumes:
      - ./nginx-prometheus.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"
      - "443:443"
      - "9113:9113"

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    volumes:
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
      - grafana-data:/var/lib/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource

volumes:
  prometheus-data:
  grafana-data:
```

**File: `prometheus.yml`**

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    environment: production

scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']
    metrics_path: '/metrics'
    
  - job_name: 'nginx-exporter'
    static_configs:
      - targets: ['nginx-exporter:9113']
    metrics_path: '/metrics'
    
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

## H.3 Log Aggregation with ELK Stack

### Elasticsearch, Logstash, Kibana (ELK)

**File: `docker-compose.elk.yml`**

```yaml
version: '3.8'

services:
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
      - elk-network

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
      - elk-network

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
      - elk-network

networks:
  elk-network:
    driver: bridge

volumes:
  elasticsearch-data:
```

**File: `logstash.conf`**

```ruby
# logstash.conf - Parse Nginx JSON logs

input {
  file {
    path => "/var/log/nginx/access.log"
    codec => json
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
  
  file {
    path => "/var/log/nginx/error.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
}

filter {
  if [path] == "/var/log/nginx/access.log" {
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
  }
  
  if [path] == "/var/log/nginx/error.log" {
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
  
  stdout {
    codec => rubydebug
  }
}
```

## H.4 Distributed Tracing with Jaeger

### Jaeger Integration

**File: `docker-compose.tracing.yml`**

```yaml
version: '3.8'

services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: jaeger
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
      - "16686:16686"
      - "14268:14268"
      - "14250:14250"
      - "9411:9411"
    environment:
      - COLLECTOR_ZIPKIN_HOST_PORT=:9411
      - COLLECTOR_OTLP_ENABLED=true
    networks:
      - tracing-network

networks:
  tracing-network:
    driver: bridge
```

**File: `nginx-tracing.conf`**

```nginx
# Nginx tracing configuration with OpenTracing

http {
    # Load OpenTracing module
    # Note: Requires nginx-opentracing module
    
    opentracing on;
    opentracing_load_tracer /usr/local/lib/libjaeger.so /etc/nginx/jaeger-config.json;
    
    server {
        location /api/ {
            opentracing_operation_name "API Request";
            opentracing_propagate_context;
            
            proxy_pass http://backend/;
            
            # Add trace headers
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Trace-ID $opentracing_context_id;
        }
    }
}
```

**File: `jaeger-config.json`**

```json
{
  "service_name": "nginx-gateway",
  "sampler": {
    "type": "const",
    "param": 1
  },
  "reporter": {
    "localAgentHostPort": "jaeger:6831"
  },
  "headers": {
    "jaegerHeader": "uber-trace-id"
  },
  "baggage_restrictions": {
    "denyBaggageOnInitializationFailure": false,
    "hostPort": ""
  }
}
```

## H.5 Grafana Dashboards

### Nginx Dashboard Configuration

**File: `nginx-dashboard.json`**

```json
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
        "title": "Response Times",
        "type": "graph",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "targets": [
          {
            "expr": "nginx_http_request_duration_seconds",
            "legendFormat": "{{quantile}}"
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
        "title": "Top Endpoints",
        "type": "table",
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 12},
        "targets": [
          {
            "expr": "topk(10, sum(rate(nginx_http_requests_total[1h])) by (uri))"
          }
        ]
      },
      {
        "title": "Upstream Status",
        "type": "table",
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 12},
        "targets": [
          {
            "expr": "nginx_upstream_status"
          }
        ]
      }
    ]
  }
}
```

### Alert Rules

**File: `alert-rules.yml`**

```yaml
groups:
  - name: nginx_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: sum(rate(nginx_http_requests_total{status=~"5.."}[5m])) / sum(rate(nginx_http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate on Nginx"
          description: "Error rate is {{ $value }}%"

      - alert: HighResponseTime
        expr: histogram_quantile(0.95, sum(rate(nginx_http_request_duration_seconds_bucket[5m])) by (le)) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time"
          description: "95th percentile response time is {{ $value }}s"

      - alert: UpstreamDown
        expr: nginx_upstream_status{status=~"5.."} > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Upstream service is down"
          description: "{{ $labels.upstream }} is returning errors"

      - alert: LowCacheHitRate
        expr: sum(rate(nginx_cache_status{HIT})) / sum(rate(nginx_cache_status)) < 0.6
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Low cache hit rate"
          description: "Cache hit rate is {{ $value }}%"

      - alert: ConnectionExhaustion
        expr: nginx_connections_active > nginx_connections_available * 0.8
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Nginx connections exhausted"
          description: "Active connections: {{ $value }}"

      - alert: SSLExpiry
        expr: nginx_ssl_cert_expiry < 86400 * 30
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "SSL certificate expiring soon"
          description: "Certificate expires in {{ $value }} seconds"
```

## H.6 Monitoring Scripts

### Health Check Script

**File: `health-check.sh`**

```bash
#!/bin/bash
# health-check.sh - Comprehensive health monitoring

echo "=== Nginx Health Check ==="
echo "Timestamp: $(date)"
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
    
    response=$(curl -k -s -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null)
    
    if [ "$response" = "$expected" ]; then
        echo -e "${GREEN}✓ $name is healthy${NC}"
        return 0
    else
        echo -e "${RED}✗ $name is unhealthy (HTTP $response)${NC}"
        return 1
    fi
}

# Check services
echo "1. Service Health:"
check_service "Nginx" "https://localhost/health" "200"
check_service "API" "https://localhost/api/health" "200"
check_service "Auth" "https://localhost/auth/health" "200"

echo ""
echo "2. Metrics:"
curl -s http://localhost:9090/api/v1/query?query=nginx_connections_active \
    | python -m json.tool

echo ""
echo "3. System Resources:"
echo "Memory: $(docker stats --no-stream --format "{{.MemPerc}}" nginx-proxy)"
echo "CPU: $(docker stats --no-stream --format "{{.CPUPerc}}" nginx-proxy)"

echo ""
echo "4. Log Status:"
echo "Access log size: $(du -h logs/access.log | cut -f1)"
echo "Error log size: $(du -h logs/error.log | cut -f1)"
echo "Error count (last 100 lines): $(tail -100 logs/error.log | grep -c 'error')"

echo ""
echo "5. Connections:"
echo "Active: $(docker exec nginx-proxy netstat -an | grep ':443' | grep ESTABLISHED | wc -l)"
echo "Waiting: $(docker exec nginx-proxy netstat -an | grep ':443' | grep TIME_WAIT | wc -l)"

echo ""
echo "6. Cache Status:"
echo "Cache size: $(du -sh cache/ 2>/dev/null | cut -f1)"
echo "Cache files: $(find cache/ -type f 2>/dev/null | wc -l)"

echo ""
echo "Health check complete!"
```

### Metrics Collection Script

**File: `collect-metrics.sh`**

```bash
#!/bin/bash
# collect-metrics.sh - Collect and store metrics

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="./metrics/$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

echo "Collecting Nginx metrics..."

# Collect Nginx stub status
curl -s http://localhost:9113/metrics > "$OUTPUT_DIR/metrics.txt"

# Collect Docker stats
docker stats --no-stream --format \
    "table {{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}" \
    > "$OUTPUT_DIR/docker-stats.txt"

# Collect system info
cat /proc/loadavg > "$OUTPUT_DIR/loadavg.txt"
free -m > "$OUTPUT_DIR/memory.txt"
df -h > "$OUTPUT_DIR/disk.txt"

# Collect log statistics
tail -1000 logs/access.log | \
    awk '{print $9}' | sort | uniq -c > "$OUTPUT_DIR/status-codes.txt"

# Generate summary
cat > "$OUTPUT_DIR/summary.txt" << EOF
Metrics Collected: $(date)
---
Request Rate: $(tail -60 logs/access.log | wc -l) req/min
Error Rate: $(tail -100 logs/access.log | grep -c '"status":5[0-9][0-9]') errors
Active Connections: $(docker exec nginx-proxy netstat -an | grep ':443' | grep ESTABLISHED | wc -l)
Cache Size: $(du -sh cache/ 2>/dev/null | cut -f1)
EOF

echo "Metrics saved to $OUTPUT_DIR"
```

### Performance Dashboard Script

**File: `performance-dashboard.sh`**

```bash
#!/bin/bash
# performance-dashboard.sh - Real-time performance dashboard

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              NGINX PERFORMANCE DASHBOARD                     ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Request rates
    REQUESTS=$(tail -60 logs/access.log 2>/dev/null | wc -l)
    echo "📊 Request Rate: $((REQUESTS / 1)) req/min"
    
    # Response times
    AVG_TIME=$(tail -100 logs/access.log 2>/dev/null | \
        python -c "import json, sys; times=[float(j['request_time']) for j in [json.loads(l) for l in sys.stdin if l.strip()] if 'request_time' in j]; print(f'{sum(times)/len(times):.3f}' if times else 'N/A')")
    echo "⏱️  Avg Response: ${AVG_TIME}s"
    
    # Error rate
    ERRORS=$(tail -100 logs/access.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "❌ Error Rate: $ERRORS errors (last 100 req)"
    
    # Cache hit ratio
    HITS=$(tail -100 logs/access.log 2>/dev/null | grep -c '"upstream_cache_status":"HIT"')
    echo "💾 Cache Hit: $HITS% (last 100 req)"
    
    # Connections
    CONNS=$(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep ESTABLISHED | wc -l)
    echo "🔗 Active Conn: $CONNS"
    
    # Memory
    MEM=$(docker stats nginx-proxy --no-stream --format "{{.MemPerc}}" 2>/dev/null)
    echo "💻 Memory: $MEM"
    
    # CPU
    CPU=$(docker stats nginx-proxy --no-stream --format "{{.CPUPerc}}" 2>/dev/null)
    echo "⚡ CPU: $CPU"
    
    # Top IPs
    echo ""
    echo "Top IPs (last 100 requests):"
    tail -100 logs/access.log 2>/dev/null | \
        python -c "import json, sys, collections; ips=collections.Counter([j['remote_addr'] for j in [json.loads(l) for l in sys.stdin if l.strip()] if 'remote_addr' in j]); [print(f'  {ip}: {count}') for ip, count in ips.most_common(5)]"
    
    sleep 2
done
```

## H.7 Monitoring Best Practices

### Metrics to Monitor

| Category | Metrics | Alert Threshold |
|----------|---------|-----------------|
| **Performance** | Response time | > 1s (p95) |
| **Reliability** | Error rate | > 5% |
| **Capacity** | Active connections | > 80% of max |
| **Cache** | Hit ratio | < 60% |
| **Upstream** | Status codes | 5xx > 1% |
| **SSL** | Certificate expiry | < 30 days |
| **System** | Memory usage | > 80% |
| **System** | CPU usage | > 80% |

### Dashboard Organization

1. **Overview Dashboard**
   - Request rate (total, by status)
   - Response time percentiles
   - Error rate
   - Active connections

2. **Performance Dashboard**
   - Request time distribution
   - Upstream response time
   - Cache hit ratio
   - Static asset performance

3. **Security Dashboard**
   - Rate limit hits (429s)
   - Auth failures (401s)
   - Suspicious requests
   - SSL/TLS metrics

4. **Capacity Dashboard**
   - Connection usage
   - Memory usage
   - CPU usage
   - Disk usage (logs, cache)

5. **Business Dashboard**
   - Top endpoints
   - User agents
   - Geographic distribution
   - Traffic patterns

---

This monitoring stack provides complete observability for your Nginx gateway in production. With proper monitoring, you'll detect issues before they impact users and maintain high availability and performance.
