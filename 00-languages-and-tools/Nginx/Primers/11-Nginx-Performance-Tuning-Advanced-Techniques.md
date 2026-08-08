# Primer 11: Nginx Performance Tuning - Advanced Techniques

## The Target

This primer provides advanced performance tuning techniques for Nginx in production. These are the techniques used by large-scale deployments to handle millions of requests per second.

## P11.1 Advanced Buffer Optimization

### Complete Buffer Strategy

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BUFFER STRATEGY BY WORKLOAD                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  WORKLOAD: SMALL PAYLOADS (API, JSON, Microservices)                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ client_body_buffer_size    128k                                    │   │
│  │ client_header_buffer_size  1k                                      │   │
│  │ large_client_header_buffers 4 8k                                   │   │
│  │ output_buffers             8 8k                                    │   │
│  │ postpone_output            1460                                    │   │
│  │                                                                     │   │
│  │ proxy_buffer_size          4k                                      │   │
│  │ proxy_buffers              8 4k                                    │   │
│  │ proxy_busy_buffers_size    8k                                      │   │
│  │ proxy_temp_file_write_size 8k                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  WORKLOAD: LARGE PAYLOADS (Files, Images, Downloads)                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ client_body_buffer_size    512k                                    │   │
│  │ client_header_buffer_size  4k                                      │   │
│  │ large_client_header_buffers 8 8k                                   │   │
│  │ output_buffers             32 64k                                  │   │
│  │ postpone_output            0                                       │   │
│  │                                                                     │   │
│  │ proxy_buffer_size          16k                                     │   │
│  │ proxy_buffers              16 16k                                  │   │
│  │ proxy_busy_buffers_size    32k                                     │   │
│  │ proxy_temp_file_write_size 64k                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  WORKLOAD: STREAMING (SSE, WebSockets, Video)                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ client_body_buffer_size    128k                                    │   │
│  │ client_header_buffer_size  1k                                      │   │
│  │ large_client_header_buffers 4 8k                                   │   │
│  │ output_buffers             4 8k                                    │   │
│  │                                                                     │   │
│  │ proxy_buffering            off                                     │   │
│  │ proxy_buffer_size          4k                                      │   │
│  │ proxy_temp_file_write_size 8k                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Advanced Buffer Configuration

```nginx
# nginx.conf - Advanced buffer optimization
http {
    # ------------------------------------------------------------------------
    # Client Buffers
    # ------------------------------------------------------------------------
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    
    # Output Buffers
    output_buffers 32 32k;
    postpone_output 1460;
    
    # ------------------------------------------------------------------------
    # Proxy Buffers
    # ------------------------------------------------------------------------
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;
    proxy_temp_file_write_size 8k;
    proxy_max_temp_file_size 1024m;
    
    # ------------------------------------------------------------------------
    # FastCGI Buffers
    # ------------------------------------------------------------------------
    fastcgi_buffer_size 4k;
    fastcgi_buffers 8 4k;
    fastcgi_busy_buffers_size 8k;
    fastcgi_temp_file_write_size 8k;
    
    # ------------------------------------------------------------------------
    # Location-specific overrides
    # ------------------------------------------------------------------------
    # API endpoints (small payloads)
    location /api/ {
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
        output_buffers 8 8k;
    }
    
    # File downloads (large payloads)
    location /downloads/ {
        proxy_buffers 16 16k;
        proxy_busy_buffers_size 32k;
        output_buffers 32 64k;
        postpone_output 0;
    }
    
    # Streaming (buffering disabled)
    location /sse/ {
        proxy_buffering off;
        proxy_buffer_size 4k;
        output_buffers 4 8k;
    }
}
```

## P11.2 TCP Optimization Deep Dive

### Kernel Tuning for High Performance

```bash
# /etc/sysctl.conf - Ultimate TCP tuning

# Connection handling
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_abort_on_overflow = 1

# Connection reuse
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3

# Buffer sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_mem = 786432 1048576 1572864

# Port range
net.ipv4.ip_local_port_range = 1024 65000

# TCP optimization
net.ipv4.tcp_slow_start_after_idle = 0
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Apply settings
sysctl -p
```

### Nginx TCP Configuration

```nginx
# nginx.conf - TCP optimization
http {
    # Basic TCP settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    # Keepalive settings
    keepalive_timeout 65;
    keepalive_requests 1000;
    keepalive_disable msie6;
    
    # Connection pooling
    upstream backend {
        server backend1:8000;
        server backend2:8000;
        
        keepalive 32;
        keepalive_requests 1000;
        keepalive_timeout 60s;
    }
    
    # SSL TCP settings
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;
    
    # Location-specific TCP settings
    location /api/ {
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # TCP keepalive
        proxy_set_header Connection "keep-alive";
    }
}
```

## P11.3 SSL/TLS Performance

### SSL Session Caching

```nginx
# nginx.conf - SSL performance
http {
    # Session cache (critical for performance)
    ssl_session_cache shared:SSL:10m;  # 10MB = ~40000 sessions
    ssl_session_timeout 1h;
    ssl_session_tickets on;  # Faster than session cache
    
    # Session ticket key rotation
    ssl_session_ticket_key /etc/nginx/ssl/ticket.key1;
    ssl_session_ticket_key /etc/nginx/ssl/ticket.key2;
    
    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;
    
    # SSL hardware acceleration (if available)
    ssl_engine /dev/crypto;
    
    # Performance vs. security balance
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
}
```

### TLS 1.3 Performance

```nginx
# nginx.conf - TLS 1.3 optimization
http {
    # TLS 1.3 is faster (fewer round trips)
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Early data (0-RTT) - faster connections
    ssl_early_data on;
    
    # TLS 1.3 cipher suites (automatic with modern config)
    ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
    
    # Session resumption for TLS 1.3
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
}
```

## P11.4 Cache Performance Tuning

### Advanced Cache Configuration

```nginx
# nginx.conf - Advanced caching
http {
    # Multi-level cache
    proxy_cache_path /var/cache/nginx/l1_cache
        levels=1:2
        keys_zone=l1_cache:10m
        max_size=100m
        inactive=1m
        use_temp_path=off
        manager_files=100
        manager_threshold=200ms
        loader_files=100
        loader_threshold=200ms;
    
    proxy_cache_path /var/cache/nginx/l2_cache
        levels=2:2:2
        keys_zone=l2_cache:100m
        max_size=1g
        inactive=10m
        use_temp_path=off
        manager_files=50
        manager_threshold=100ms
        loader_files=50
        loader_threshold=100ms;
    
    # Cache control
    location /api/ {
        # L1 cache (fast, small)
        proxy_cache l1_cache;
        proxy_cache_key $scheme$host$request_uri;
        proxy_cache_valid 200 10s;
        proxy_cache_use_stale error timeout updating;
        
        # L2 cache (slower, larger)
        proxy_cache l2_cache;
        proxy_cache_key $scheme$host$request_uri$http_accept_language;
        proxy_cache_valid 200 5m;
        proxy_cache_use_stale error timeout updating;
        
        # Cache locking (prevent stampede)
        proxy_cache_lock on;
        proxy_cache_lock_timeout 5s;
        proxy_cache_lock_age 5s;
        
        # Background update
        proxy_cache_background_update on;
        
        # Cache revalidation
        proxy_cache_revalidate on;
        
        # Minimum cache usage
        proxy_cache_min_uses 1;
        
        # Add cache headers
        add_header X-Cache-Status $upstream_cache_status;
        add_header X-Cache-Layer "L1";
        
        proxy_pass http://backend/;
    }
}
```

### Micro-Caching for High Traffic

```nginx
# nginx.conf - Micro-caching
http {
    # Micro-cache zone (very short TTL)
    proxy_cache_path /var/cache/nginx/micro_cache
        levels=1:2
        keys_zone=micro_cache:10m
        max_size=100m
        inactive=5s
        use_temp_path=off;
    
    location /api/high-traffic/ {
        # 1-second micro-cache
        proxy_cache micro_cache;
        proxy_cache_key $scheme$host$request_uri;
        proxy_cache_valid 200 1s;
        proxy_cache_valid 404 0s;
        proxy_cache_use_stale error timeout updating;
        proxy_cache_lock on;
        proxy_cache_lock_timeout 500ms;
        
        add_header X-Cache-Status $upstream_cache_status;
        add_header X-Cache-TTL "1s";
        
        proxy_pass http://backend/;
    }
}
```

## P11.5 Thread Pool Optimization

### Thread Pool Configuration

```nginx
# nginx.conf - Thread pools
http {
    # Thread pools for I/O operations
    thread_pool default threads=32 max_queue=65536;
    thread_pool compression threads=16 max_queue=32768;
    
    # Use thread pool for sendfile
    aio threads=default;
    
    # Use thread pool for compression
    gzip on;
    gzip_threads compression;
    
    # Thread pool for direct I/O
    directio 4m;
    directio_alignment 512;
    
    # Location-specific thread pools
    location /static/ {
        aio threads=default;
        sendfile on;
        directio 4m;
    }
    
    location /downloads/ {
        aio threads=default;
        sendfile on;
        directio 8m;
        output_buffers 32 64k;
    }
}
```

## P11.6 Asynchronous Operations

### Async I/O Configuration

```nginx
# nginx.conf - Asynchronous operations
http {
    # Enable aio
    aio on;
    aio_write on;
    
    # Use threads for aio
    aio threads;
    
    # Location-specific async
    location /static/ {
        aio on;
        aio_write on;
        sendfile on;
        directio 4m;
        output_buffers 32 64k;
    }
    
    # For large file downloads
    location /downloads/ {
        aio on;
        aio_write on;
        sendfile on;
        directio 8m;
        output_buffers 64 128k;
        
        # Enable HTTP 1.1 range requests
        add_header Accept-Ranges bytes;
    }
}
```

## P11.7 Performance Monitoring

### Real-time Performance Dashboard

```bash
#!/bin/bash
# performance-dashboard.sh - Advanced performance monitoring

while true; do
    clear
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║             NGINX PERFORMANCE DASHBOARD (ADVANCED)             ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                    ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # 1. Request Rates
    REQUESTS=$(tail -60 logs/access.log 2>/dev/null | wc -l)
    ERROR_RATE=$(tail -100 logs/access.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    
    echo "📊 REQUEST RATES:"
    echo "  Requests/min: $((REQUESTS / 1))"
    echo "  Error Rate: $ERROR_RATE%"
    echo ""
    
    # 2. Response Times
    AVG_TIME=$(tail -100 logs/access.log 2>/dev/null | python -c "
import json, sys, statistics
times = []
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'request_time' in data:
            times.append(float(data['request_time']))
    except:
        pass
if times:
    print(f'Mean: {statistics.mean(times):.3f}s, Median: {statistics.median(times):.3f}s, 95th: {statistics.quantiles(times, n=20)[18]:.3f}s')
else:
    print('No data')
")
    echo "⏱️  RESPONSE TIMES:"
    echo "  $AVG_TIME"
    echo ""
    
    # 3. Cache Status
    HITS=$(tail -100 logs/access.log 2>/dev/null | grep -c '"upstream_cache_status":"HIT"')
    MISS=$(tail -100 logs/access.log 2>/dev/null | grep -c '"upstream_cache_status":"MISS"')
    TOTAL=$((HITS + MISS))
    if [ $TOTAL -gt 0 ]; then
        HIT_RATE=$((HITS * 100 / TOTAL))
    else
        HIT_RATE=0
    fi
    echo "💾 CACHE STATUS:"
    echo "  Hit Rate: $HIT_RATE% ($HITS hits, $MISS misses)"
    echo ""
    
    # 4. Connections
    CONNS=$(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep ESTABLISHED | wc -l)
    WAITING=$(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep TIME_WAIT | wc -l)
    echo "🔗 CONNECTIONS:"
    echo "  Active: $CONNS"
    echo "  Waiting: $WAITING"
    echo ""
    
    # 5. System Resources
    MEM=$(docker stats nginx-proxy --no-stream --format "{{.MemPerc}}" 2>/dev/null)
    CPU=$(docker stats nginx-proxy --no-stream --format "{{.CPUPerc}}" 2>/dev/null)
    echo "💻 SYSTEM RESOURCES:"
    echo "  Memory: $MEM"
    echo "  CPU: $CPU"
    echo ""
    
    # 6. Upstream Status
    echo "⚡ UPSTREAM STATUS:"
    curl -s http://localhost/nginx-status 2>/dev/null | grep -v "Active"
    echo ""
    
    sleep 2
done
```

### Performance Metrics Collection

```bash
#!/bin/bash
# collect-performance-metrics.sh

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="./metrics/$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

echo "Collecting performance metrics..."

# 1. Nginx stub status
curl -s http://localhost/nginx-status > "$OUTPUT_DIR/stub_status.txt"

# 2. Nginx metrics
curl -s http://localhost:9113/metrics > "$OUTPUT_DIR/metrics.txt"

# 3. Docker stats
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" > "$OUTPUT_DIR/docker_stats.txt"

# 4. System stats
{
    echo "CPU:"
    top -bn1 | head -10
    echo ""
    echo "Memory:"
    free -h
    echo ""
    echo "Disk:"
    df -h
    echo ""
    echo "Network:"
    netstat -an | grep ':443' | awk '{print $6}' | sort | uniq -c
} > "$OUTPUT_DIR/system_stats.txt"

# 5. Performance summary
{
    echo "PERFORMANCE SUMMARY"
    echo "==================="
    echo "Timestamp: $(date)"
    echo ""
    
    # Request rate
    REQUESTS=$(tail -60 /var/log/nginx/access.log 2>/dev/null | wc -l)
    echo "Request Rate: $((REQUESTS / 1)) req/min"
    
    # Error rate
    ERRORS=$(tail -100 /var/log/nginx/access.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "Error Rate: $ERRORS%"
    
    # Cache hit rate
    HITS=$(tail -100 /var/log/nginx/access.log 2>/dev/null | grep -c '"upstream_cache_status":"HIT"')
    MISS=$(tail -100 /var/log/nginx/access.log 2>/dev/null | grep -c '"upstream_cache_status":"MISS"')
    TOTAL=$((HITS + MISS))
    if [ $TOTAL -gt 0 ]; then
        HIT_RATE=$((HITS * 100 / TOTAL))
    else
        HIT_RATE=0
    fi
    echo "Cache Hit Rate: $HIT_RATE%"
    
    # Average response time
    AVG_TIME=$(tail -100 /var/log/nginx/access.log 2>/dev/null | python -c "
import json, sys, statistics
times = []
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'request_time' in data:
            times.append(float(data['request_time']))
    except:
        pass
if times:
    print(f'{statistics.mean(times):.3f}s')
else:
    print('N/A')
")
    echo "Average Response Time: $AVG_TIME"
} > "$OUTPUT_DIR/summary.txt"

echo "Metrics saved to $OUTPUT_DIR"
```

---

This primer provides advanced performance tuning techniques for Nginx in production. Use these techniques to achieve maximum performance in large-scale deployments.
