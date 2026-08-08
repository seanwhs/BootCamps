# Appendix E: Performance Tuning Guide

## The Target

This appendix provides a comprehensive guide to tuning Nginx for maximum performance. Whether you're handling thousands of concurrent connections or optimizing for low latency, this guide covers everything you need.

## E.1 Performance Metrics

### Key Performance Indicators

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Response Time** | < 100ms | `$request_time` in logs |
| **Throughput** | 10,000+ req/s | `ab` or `wrk` load testing |
| **Connection Rate** | 500+ conn/s | `netstat -an | grep ESTABLISHED` |
| **Error Rate** | < 0.1% | `grep -c "5[0-9][0-9]" access.log` |
| **Cache Hit Ratio** | > 80% | `$upstream_cache_status` |
| **SSL Handshake Time** | < 100ms | `openssl s_client -connect` |
| **Worker CPU Usage** | < 80% | `top -p $(pgrep nginx)` |
| **Memory Usage** | < 500MB | `ps aux | grep nginx` |

### Measuring Performance

```bash
# 1. Basic benchmark with Apache Bench
ab -n 10000 -c 100 https://localhost/api/

# 2. More advanced with wrk
wrk -t12 -c400 -d30s https://localhost/api/

# 3. Check response times from logs
tail -1000 /var/log/nginx/access.log | jq '.request_time' | sort -n

# 4. Calculate average response time
tail -1000 /var/log/nginx/access.log | jq '.request_time' | awk '{sum+=$1} END {print sum/NR}'

# 5. Check upstream response times
tail -1000 /var/log/nginx/access.log | jq '.upstream_response_time' | awk '{sum+=$1} END {print sum/NR}'
```

## E.2 OS and System Tuning

### Linux Kernel Tuning

**File: `/etc/sysctl.conf`**

```bash
# Network Performance Tuning
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0  # Disable in modern kernels
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_mem = 786432 1048576 1572864
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.ip_local_port_range = 1024 65000

# File descriptor limits
fs.file-max = 2097152

# Apply changes
sysctl -p
```

### File Descriptor Limits

**File: `/etc/security/limits.conf`**

```bash
# Increase file descriptor limits
nginx soft nofile 65535
nginx hard nofile 65535
root soft nofile 65535
root hard nofile 65535

# Increase process limits
nginx soft nproc 65535
nginx hard nproc 65535
```

**File: `/etc/nginx/nginx.conf`**

```nginx
# Use these settings
worker_rlimit_nofile 65535;
worker_processes auto;
worker_connections 65535;
```

### Docker-Specific Tuning

```yaml
# docker-compose.yml
services:
  nginx:
    # Increase ulimits
    ulimits:
      nofile:
        soft: 65535
        hard: 65535
    # CPU and memory limits
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

## E.3 Nginx Core Configuration

### Worker Process Tuning

```nginx
# nginx.conf
worker_processes auto;           # One per CPU core
worker_rlimit_nofile 65535;      # Max open files
worker_priority -20;             # Higher priority for Nginx

# In events block
events {
    worker_connections 65535;    # Max connections per worker
    use epoll;                   # Efficient I/O (Linux only)
    multi_accept on;             # Accept multiple connections
    accept_mutex off;            # Disable (better performance with epoll)
}
```

### Connection Processing Optimization

```nginx
# nginx.conf
http {
    # Basic performance settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 1000;
    types_hash_max_size 2048;
    
    # Buffer sizes
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    output_buffers 32 32k;
    postpone_output 1460;
    
    # Timeouts (tune for your application)
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    
    # Disable unused features
    server_tokens off;
    server_names_hash_bucket_size 64;
    
    # Static file handling
    open_file_cache max=10000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
}
```

### SSL/TLS Performance Tuning

```nginx
# nginx.conf
http {
    # SSL session caching (critical for performance)
    ssl_session_cache shared:SSL:10m;    # 10MB = ~40000 sessions
    ssl_session_timeout 1h;
    ssl_session_tickets off;
    
    # Modern TLS - fast and secure
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # OCSP stapling (reduces SSL handshake time)
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;
}
```

## E.4 Caching Optimization

### Proxy Cache Tuning

```nginx
# nginx.conf
http {
    # Cache path with performance settings
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2
        keys_zone=api_cache:100m
        max_size=2g
        inactive=1h
        use_temp_path=off  # Faster (no temp file)
        manager_files=100
        manager_threshold=200ms
        loader_files=100
        loader_threshold=200ms;
    
    # Cache settings
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_valid 200 302 5m;
    proxy_cache_use_stale error timeout updating;
    proxy_cache_lock on;
    proxy_cache_lock_timeout 5s;
    proxy_cache_min_uses 1;
    
    # Enable cache revalidation
    proxy_cache_revalidate on;
    
    # Background update
    proxy_cache_background_update on;
}
```

### Static File Caching

```nginx
# nginx.conf
location /static/ {
    alias /var/www/static/;
    
    # Browser caching
    expires 30d;
    add_header Cache-Control "public, immutable";
    
    # Edge caching
    proxy_cache static_cache;
    proxy_cache_valid 200 30d;
    proxy_cache_use_stale error timeout updating;
    
    # Static file optimization
    open_file_cache max=10000 inactive=30s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    
    # Sendfile optimization
    sendfile on;
    tcp_nopush on;
    
    # Compression
    gzip_static on;
    gzip_proxied any;
}
```

### FastCGI Cache (for PHP/Python Apps)

```nginx
# nginx.conf
http {
    fastcgi_cache_path /var/cache/nginx/fastcgi_cache
        levels=1:2
        keys_zone=fastcgi_cache:100m
        max_size=1g
        inactive=1h
        use_temp_path=off;
    
    location ~ \.php$ {
        fastcgi_cache fastcgi_cache;
        fastcgi_cache_key $scheme$host$request_uri;
        fastcgi_cache_valid 200 302 5m;
        fastcgi_cache_use_stale error timeout updating;
        fastcgi_cache_lock on;
        fastcgi_cache_lock_timeout 5s;
        fastcgi_cache_min_uses 1;
        
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## E.5 Compression Optimization

### Gzip Configuration

```nginx
# nginx.conf
http {
    # Enable compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;      # Balance between compression and CPU
    gzip_min_length 1000;   # Don't compress small files
    gzip_disable "msie6";   # Skip old browsers
    
    # Compress these types
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/rss+xml
        application/atom+xml
        application/xhtml+xml
        application/ld+json
        application/manifest+json
        application/geo+json
        application/vnd.ms-fontobject
        application/x-font-ttf
        font/opentype
        font/ttf
        font/otf
        font/woff
        font/woff2
        image/svg+xml
        image/x-icon;
    
    # Pre-compressed static files
    gzip_static on;
}
```

### Brotli Compression (Optional)

```nginx
# Requires brotli module
http {
    # Brotli compression (better than gzip)
    brotli on;
    brotli_comp_level 6;
    brotli_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/rss+xml
        application/atom+xml;
    brotli_static on;
}
```

## E.6 Load Balancing Optimization

### Upstream Keepalive

```nginx
# nginx.conf
upstream backend {
    # Servers with health checks
    server backend1:8000 max_fails=3 fail_timeout=30s;
    server backend2:8000 max_fails=3 fail_timeout=30s;
    server backend3:8000 max_fails=3 fail_timeout=30s;
    
    # Keepalive connections (critical for performance)
    keepalive 32;              # Keep 32 connections open
    keepalive_requests 1000;   # Reuse connection for 1000 requests
    keepalive_timeout 60s;     # Keep connection alive for 60s
    
    # Load balancing algorithm
    # least_conn;              # Least connections
    # ip_hash;                 # Sticky sessions
    # random two least_conn;   # Random with least connections
}
```

### Buffer Configuration

```nginx
# nginx.conf
location /api/ {
    # Buffer configuration for performance
    proxy_buffering on;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;
    proxy_temp_file_write_size 8k;
    
    # Disable buffering for large files
    proxy_max_temp_file_size 1024m;
    
    # Response caching
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
    
    # Keepalive to upstream
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    
    proxy_pass http://backend/;
}
```

## E.7 Logging Optimization

### Minimize Logging Overhead

```nginx
# nginx.conf
http {
    # Buffer logs for performance
    access_log /var/log/nginx/access.log json buffer=32k flush=5s;
    error_log /var/log/nginx/error.log warn;
    
    # Separate logs for different endpoints
    access_log /var/log/nginx/api-access.log json if=$is_api_request;
    access_log /var/log/nginx/static-access.log json if=$is_static_request;
    
    # Disable logging for health checks
    location /health {
        access_log off;
        proxy_pass http://backend/health;
    }
}

# Map requests to different logs
map $request_uri $is_api_request {
    ~^/api/  1;
    default  0;
}

map $request_uri $is_static_request {
    ~*\.(jpg|jpeg|png|gif|ico|css|js|svg)$ 1;
    default 0;
}
```

## E.8 Rate Limiting Performance

### Efficient Rate Limiting

```nginx
# nginx.conf
http {
    # Use binary_remote_addr (more memory efficient)
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    location /api/ {
        # Rate limit with burst
        limit_req zone=api_limit burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # Return 429 quickly (don't wait)
        limit_req_status 429;
        
        proxy_pass http://backend/;
    }
}
```

## E.9 Performance Testing Script

**File: `performance-test.sh`**

```bash
#!/bin/bash
# performance-test.sh - Complete performance testing

echo "=== Nginx Performance Testing ==="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test 1: Response time
echo -e "${BLUE}Test 1: Response Time${NC}"
echo "Average response time (100 requests):"
ab -n 100 -c 10 https://localhost/api/ 2>&1 | grep "Time per request"

# Test 2: Throughput
echo ""
echo -e "${BLUE}Test 2: Throughput${NC}"
echo "Requests per second (1000 requests, 50 concurrent):"
ab -n 1000 -c 50 https://localhost/api/ 2>&1 | grep "Requests per second"

# Test 3: Connection handling
echo ""
echo -e "${BLUE}Test 3: Connection Handling${NC}"
echo "Testing with wrk (if installed):"
if command -v wrk &> /dev/null; then
    wrk -t4 -c100 -d10s https://localhost/api/ 2>&1 | grep -E "Thread Stats|Requests/sec"
else
    echo "wrk not installed. Skipping."
fi

# Test 4: SSL handshake
echo ""
echo -e "${BLUE}Test 4: SSL Handshake${NC}"
echo "SSL handshake time:"
time openssl s_client -connect localhost:443 -tls1_3 < /dev/null 2>&1 | grep "SSL handshake has read"

# Test 5: Cache hit ratio
echo ""
echo -e "${BLUE}Test 5: Cache Hit Ratio${NC}"
echo "Making 50 requests to warm cache..."
for i in {1..50}; do
    curl -k -s https://localhost/api/public/ > /dev/null
done

echo "Cache statistics:"
tail -100 logs/access.log | grep -E '"upstream_cache_status":"(HIT|MISS)"' | \
    awk -F'"' '{print $4}' | sort | uniq -c

# Test 6: Memory usage
echo ""
echo -e "${BLUE}Test 6: Memory Usage${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.MemPerc}}\t{{.MemUsage}}" | grep nginx

# Test 7: Connection count
echo ""
echo -e "${BLUE}Test 7: Active Connections${NC}"
CONNS=$(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep ESTABLISHED | wc -l)
echo "Active connections: $CONNS"

# Test 8: Error rate
echo ""
echo -e "${BLUE}Test 8: Error Rate${NC}"
TOTAL=$(tail -1000 logs/access.log 2>/dev/null | wc -l)
ERRORS=$(tail -1000 logs/access.log 2>/dev/null | grep -E '"status":5[0-9]{2}' | wc -l)
if [ $TOTAL -gt 0 ]; then
    ERROR_RATE=$(echo "scale=2; $ERRORS * 100 / $TOTAL" | bc)
    echo "Error rate: $ERROR_RATE% ($ERRORS of $TOTAL requests)"
else
    echo "No data available"
fi

echo ""
echo -e "${GREEN}Performance test complete!${NC}"
```

## E.10 Performance Optimization Checklist

### Before Launch

- [ ] OS tuned (sysctl.conf)
- [ ] File descriptor limits increased
- [ ] Worker processes set to auto
- [ ] Worker connections configured (65535)
- [ ] epoll selected
- [ ] sendfile enabled
- [ ] tcp_nopush/tcp_nodelay enabled
- [ ] keepalive configured
- [ ] SSL session caching enabled
- [ ] gzip compression enabled
- [ ] Proxy caching configured
- [ ] Log buffering enabled
- [ ] Open file cache configured
- [ ] Buffer sizes optimized
- [ ] Timeouts tuned

### Performance Testing

```bash
# Run baseline test
./performance-test.sh

# Load test with increasing concurrency
for c in 10 50 100 200; do
    echo "Testing with concurrency: $c"
    ab -n 1000 -c $c https://localhost/api/ | grep "Requests per second"
done

# Monitor while testing
watch -n1 'docker stats nginx-proxy --no-stream'
```

### Monitoring

```bash
# Set up continuous monitoring
while true; do
    clear
    echo "=== Nginx Performance Dashboard ==="
    echo "Time: $(date)"
    echo ""
    
    # Response time
    AVG=$(tail -100 logs/access.log | jq '.request_time' | awk '{sum+=$1} END {print sum/NR}')
    echo "Avg Response Time: ${AVG}s"
    
    # Request rate
    RATE=$(tail -60 logs/access.log | wc -l)
    echo "Request Rate: $((RATE / 1)) req/min"
    
    # Cache hit ratio
    HITS=$(tail -100 logs/access.log | grep '"upstream_cache_status":"HIT"' | wc -l)
    echo "Cache Hit Rate: $HITS%"
    
    # Connections
    CONNS=$(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep ESTABLISHED | wc -l)
    echo "Active Connections: $CONNS"
    
    # Memory
    MEM=$(docker stats nginx-proxy --no-stream --format "{{.MemPerc}}")
    echo "Memory Usage: $MEM"
    
    sleep 2
done
```

---

This performance tuning guide will help you get the most out of your Nginx installation. Remember: **measure first, then optimize**. Always validate that changes actually improve performance before deploying to production.
