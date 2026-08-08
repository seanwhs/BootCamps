# Primer 6: Production Deployment & Operations Deep Dive

## The Target

This primer provides a comprehensive, deep-dive guide to deploying and operating Nginx in production. Understanding these concepts is essential for maintaining high availability, reliability, and operational excellence.

## P6.1 Deployment Strategies

### Deployment Models

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DEPLOYMENT MODELS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Rolling Deployment                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Gradual update of instances one at a time                           │   │
│  │ Pros: Minimal downtime, simple                                     │   │
│  │ Cons: Slow, requires careful monitoring                            │   │
│  │                                                                     │   │
│  │ Server1 [v1] → [v2] ─┐                                              │   │
│  │ Server2 [v1] → [v2]  ├─ Traffic gradually shifts                   │   │
│  │ Server3 [v1] → [v2] ─┘                                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  2. Blue-Green Deployment                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Two identical environments, switch between them                    │   │
│  │ Pros: Instant switch, easy rollback                                │   │
│  │ Cons: Double resources required                                    │   │
│  │                                                                     │   │
│  │ Blue (v1) ────────┐                                                 │   │
│  │                   ├─── Router ──── Traffic                          │   │
│  │ Green (v2) ───────┘                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  3. Canary Deployment                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Gradual rollout with monitoring                                    │   │
│  │ Pros: Safety, canary metrics                                       │   │
│  │ Cons: Slow, requires monitoring                                    │   │
│  │                                                                     │   │
│  │ v1 (90%) ─────────────┐                                             │   │
│  │                        ├─ Router ──── Traffic                       │   │
│  │ v2 (10%) ─────────────┘                                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Zero-Downtime Reload

```nginx
# nginx.conf - Zero-downtime reload configuration
worker_shutdown_timeout 30s;  # Wait for workers to finish

# Graceful shutdown
server {
    # Connection draining
    proxy_read_timeout 30s;
    proxy_connect_timeout 30s;
    
    # Allow connections to complete
    keepalive_timeout 30s;
}
```

**Reload Script:**

```bash
#!/bin/bash
# zero-downtime-reload.sh

echo "=== Zero-Downtime Reload ==="

# 1. Test configuration
echo "Testing configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "Configuration test failed!"
    exit 1
fi

# 2. Check current connections
echo "Current connections:"
curl -s http://localhost/nginx-status | grep "Active connections"

# 3. Perform graceful reload
echo "Performing graceful reload..."
nginx -s reload

# 4. Wait for reload to complete
sleep 2

# 5. Verify reload worked
echo "Verifying reload..."
ps aux | grep nginx | grep -v grep

# 6. Check connections after reload
echo "Connections after reload:"
curl -s http://localhost/nginx-status | grep "Active connections"

echo "Reload complete!"
```

### Blue-Green Deployment Configuration

```nginx
# nginx.conf - Blue-Green deployment
http {
    upstream api_blue {
        server blue:8000;
        keepalive 32;
    }
    
    upstream api_green {
        server green:8000;
        keepalive 32;
    }
    
    # Map for blue-green switching
    map $cookie_upstream $active_upstream {
        default "blue";
        "green" "green";
        "blue" "blue";
    }
    
    server {
        location /api/ {
            # Blue-green switch
            set $upstream_name $active_upstream;
            
            # Override with header for testing
            if ($http_x_upstream) {
                set $upstream_name $http_x_upstream;
            }
            
            # Route to appropriate upstream
            if ($upstream_name = "green") {
                proxy_pass http://api_green/;
            }
            if ($upstream_name = "blue") {
                proxy_pass http://api_blue/;
            }
            if ($upstream_name = "") {
                proxy_pass http://api_blue/;
            }
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Upstream $upstream_name;
        }
        
        # Switch endpoint
        location /admin/switch {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            add_header Set-Cookie "upstream=$arg_to; Path=/; Max-Age=3600";
            add_header X-Upstream-Switched $arg_to;
            
            return 200 "Switched to $arg_to upstream\n";
        }
    }
}
```

## P6.2 Monitoring and Alerting

### Monitoring Stack

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
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
      - ./grafana:/etc/grafana/provisioning
      - grafana-data:/var/lib/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource

  alertmanager:
    image: prom/alertmanager:latest
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    ports:
      - "9093:9093"

volumes:
  prometheus-data:
  grafana-data:
```

### Prometheus Configuration

```yaml
# prometheus.yml
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

### Alert Rules

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

      - alert: SSLExpiry
        expr: nginx_ssl_cert_expiry < 86400 * 30
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "SSL certificate expiring soon"
          description: "Certificate expires in {{ $value }} seconds"
```

### Health Check Script

**File: `health-check.sh`**

```bash
#!/bin/bash
# health-check.sh - Comprehensive health check

echo "=== Nginx Health Check ==="
echo "Timestamp: $(date)"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check endpoint
check_endpoint() {
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

# Check Nginx
echo "1. Nginx Status:"
check_endpoint "Nginx" "https://localhost/nginx-health" "200"
check_endpoint "Nginx Stub Status" "https://localhost/nginx-status" "200"

# Check services
echo ""
echo "2. Service Health:"
check_endpoint "Frontend" "https://localhost/health" "200"
check_endpoint "API" "https://localhost/api/health" "200"
check_endpoint "Auth" "https://localhost/auth/health" "200"
check_endpoint "WebSocket" "https://localhost/ws/health" "200"
check_endpoint "SSE" "https://localhost/sse/health" "200"
check_endpoint "Webhook" "https://localhost/webhook/health" "200"

# Check metrics
echo ""
echo "3. Performance Metrics:"
echo "Response Time: $(curl -s -o /dev/null -w "%{time_total}s" https://localhost/api/)"
echo "Request Rate: $(tail -60 /var/log/nginx/access.log 2>/dev/null | wc -l) req/min"
echo "Cache Hit Ratio: $(tail -100 /var/log/nginx/access.log 2>/dev/null | grep -c '"upstream_cache_status":"HIT"')%"

# Check system
echo ""
echo "4. System Resources:"
echo "Memory: $(docker stats --no-stream --format "{{.MemPerc}}" nginx-proxy 2>/dev/null)"
echo "CPU: $(docker stats --no-stream --format "{{.CPUPerc}}" nginx-proxy 2>/dev/null)"
echo "Connections: $(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep ESTABLISHED | wc -l)"

echo ""
echo "Health check complete!"
```

## P6.3 Disaster Recovery

### Backup and Restore

```bash
#!/bin/bash
# backup-nginx.sh - Backup Nginx configuration and data

BACKUP_DIR="/backups/nginx"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/nginx_backup_$TIMESTAMP"

echo "=== Nginx Backup ==="

# Create backup directory
mkdir -p $BACKUP_PATH

# 1. Backup configuration
echo "Backing up configuration..."
cp -r /etc/nginx $BACKUP_PATH/
cp -r /etc/nginx/conf.d $BACKUP_PATH/
cp -r /etc/nginx/sites-available $BACKUP_PATH/
cp -r /etc/nginx/ssl $BACKUP_PATH/

# 2. Backup custom files
echo "Backing up custom files..."
cp -r /var/www/html $BACKUP_PATH/ 2>/dev/null || true

# 3. Backup cache (optional)
# tar -czf $BACKUP_PATH/cache.tar.gz /var/cache/nginx 2>/dev/null || true

# 4. Backup logs (optional)
# tar -czf $BACKUP_PATH/logs.tar.gz /var/log/nginx 2>/dev/null || true

# 5. Create archive
echo "Creating archive..."
tar -czf $BACKUP_DIR/nginx_backup_$TIMESTAMP.tar.gz -C $BACKUP_PATH .

# 6. Cleanup
rm -rf $BACKUP_PATH

# 7. List recent backups
echo ""
echo "Recent backups:"
ls -la $BACKUP_DIR/*.tar.gz | tail -5

echo "Backup complete: $BACKUP_DIR/nginx_backup_$TIMESTAMP.tar.gz"
```

### Restore Procedure

```bash
#!/bin/bash
# restore-nginx.sh - Restore Nginx from backup

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    exit 1
fi

BACKUP_FILE=$1
RESTORE_DIR="/tmp/nginx_restore"

echo "=== Nginx Restore ==="
echo "Restoring from: $BACKUP_FILE"

# 1. Extract backup
echo "Extracting backup..."
mkdir -p $RESTORE_DIR
tar -xzf $BACKUP_FILE -C $RESTORE_DIR

# 2. Backup current configuration
echo "Backing up current configuration..."
cp -r /etc/nginx /etc/nginx.backup.$(date +%Y%m%d_%H%M%S)

# 3. Restore configuration
echo "Restoring configuration..."
cp -r $RESTORE_DIR/etc/nginx/* /etc/nginx/

# 4. Restore SSL certificates
cp -r $RESTORE_DIR/etc/nginx/ssl /etc/nginx/ssl

# 5. Test configuration
echo "Testing configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "Configuration test failed!"
    echo "Restoring previous configuration..."
    cp -r /etc/nginx.backup.*/* /etc/nginx/
    exit 1
fi

# 6. Reload Nginx
echo "Reloading Nginx..."
nginx -s reload

# 7. Cleanup
rm -rf $RESTORE_DIR

echo "Restore complete!"
```

## P6.4 Capacity Planning

### Scaling Decisions

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SCALING DECISION MATRIX                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Scale Up (Vertical)                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ When to use:                                                         │   │
│  │ • Resource bottlenecks (CPU, memory)                               │   │
│  │ • Single service with high requirements                            │   │
│  │ • Cost-effective for small to medium loads                          │   │
│  │                                                                     │   │
│  │ Actions:                                                             │   │
│  │ • Increase CPU/memory                                               │   │
│  │ • Enable caching                                                    │   │
│  │ • Optimize configuration                                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Scale Out (Horizontal)                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ When to use:                                                         │   │
│  │ • High traffic volume                                              │   │
│  │ • Multiple services                                                │   │
│  │ • High availability requirements                                   │   │
│  │ • Geographic distribution                                           │   │
│  │                                                                     │   │
│  │ Actions:                                                             │   │
│  │ • Add more Nginx instances                                          │   │
│  │ • Add more upstream servers                                         │   │
│  │ • Use load balancing                                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Capacity Calculation

```bash
#!/bin/bash
# capacity-calc.sh - Calculate capacity requirements

echo "=== Capacity Planning Calculator ==="
echo ""

# Get current metrics
REQUESTS_PER_SECOND=$(tail -60 /var/log/nginx/access.log 2>/dev/null | wc -l)
ACTIVE_CONNECTIONS=$(curl -s http://localhost/nginx-status 2>/dev/null | grep "Active connections" | awk '{print $3}')
MEMORY_USAGE=$(ps aux | grep nginx | awk '{sum+=$6} END {print sum/1024 " MB"}')

echo "Current Metrics:"
echo "Requests per second: $REQUESTS_PER_SECOND"
echo "Active connections: $ACTIVE_CONNECTIONS"
echo "Memory usage: $MEMORY_USAGE"
echo ""

# Calculate capacity
CPU_CORES=$(nproc)
MAX_CONNECTIONS=$((CPU_CORES * 1024))
MAX_REQUESTS=$((MAX_CONNECTIONS * 10))  # Assumption: 10 req/conn

echo "Calculated Capacity:"
echo "Maximum connections: $MAX_CONNECTIONS"
echo "Maximum requests/second: $MAX_REQUESTS"
echo ""

# Calculate scaling needs
if [ $ACTIVE_CONNECTIONS -gt $((MAX_CONNECTIONS * 80 / 100)) ]; then
    echo "⚠️  WARNING: Active connections approaching limit!"
    echo "Consider adding more instances or scaling up."
fi

echo ""
echo "Recommended scaling actions:"
echo "1. Enable/optimize caching"
echo "2. Increase worker connections"
echo "3. Add more Nginx instances"
echo "4. Optimize upstream performance"
```

## P6.5 Log Management

### Log Rotation

```nginx
# /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 nginx nginx
    sharedscripts
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}
```

### Log Aggregation

```yaml
# docker-compose.logging.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    volumes:
      - es-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
      - ./logs:/var/log/nginx:ro
    ports:
      - "5000:5000"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

volumes:
  es-data:
```

## P6.6 Security Operations

### Security Updates

```bash
#!/bin/bash
# security-update.sh - Security update script

echo "=== Nginx Security Update ==="

# 1. Check current version
echo "Current version:"
nginx -v

# 2. Check for updates (Docker)
echo "Checking for updates..."
docker pull nginx:1.27-alpine

# 3. Test new image
echo "Testing new image..."
docker run --rm nginx:1.27-alpine nginx -t

# 4. Update container
echo "Updating container..."
docker compose stop nginx
docker compose rm -f nginx
docker compose up -d nginx

# 5. Verify update
echo "Verifying update..."
docker exec nginx-proxy nginx -v
docker exec nginx-proxy curl -s localhost/health

# 6. Check logs
echo "Checking logs..."
docker logs nginx-proxy --tail 20

echo "Update complete!"
```

### Compliance Audit

```bash
#!/bin/bash
# security-audit.sh - Security audit

echo "=== Nginx Security Audit ==="
echo ""

# 1. Check version
echo "1. Nginx Version:"
nginx -v
echo ""

# 2. Check SSL/TLS
echo "2. SSL/TLS Configuration:"
openssl s_client -connect localhost:443 -tls1_3 < /dev/null 2>&1 | head -5
echo ""

# 3. Check security headers
echo "3. Security Headers:"
curl -I https://localhost/ | grep -E "Strict-Transport|X-Content|X-Frame|X-XSS|Referrer|Content-Security"
echo ""

# 4. Check rate limiting
echo "4. Rate Limiting:"
nginx -T | grep -A2 "limit_req_zone"
echo ""

# 5. Check access control
echo "5. Access Control:"
nginx -T | grep -A3 "allow" | head -10
echo ""

# 6. Check logging
echo "6. Logging:"
ls -la /var/log/nginx/
echo ""

# 7. Check configuration
echo "7. Configuration Security:"
nginx -T | grep -E "server_tokens|sendfile|keepalive_timeout"
echo ""

# 8. Check modules
echo "8. Loaded Modules:"
nginx -V 2>&1 | grep "configure arguments"
```

---

This primer provides a comprehensive deep dive into deploying and operating Nginx in production. Use these techniques to maintain high availability, reliability, and operational excellence in your production environments.
