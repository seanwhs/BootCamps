# Primer 3: Nginx Performance Optimization Deep Dive

## The Target

This primer provides a comprehensive, deep-dive explanation of Nginx performance optimization. Understanding these concepts is essential for achieving maximum throughput, minimal latency, and efficient resource utilization.

## P3.1 Performance Fundamentals

### The Performance Triangle

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PERFORMANCE TRIANGLE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                              ┌─────────────┐                               │
│                             │   Throughput │                               │
│                             │   (Requests/ │                               │
│                             │    Second)   │                               │
│                              └──────┬──────┘                               │
│                                     │                                      │
│                    ┌────────────────┼────────────────┐                     │
│                    │                │                │                     │
│                    ▼                ▼                ▼                     │
│              ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│              │   Latency   │  │  Resource   │  │  Concurrency│           │
│              │  (Response  │  │  Utilization│  │  (Connections│           │
│              │    Time)    │  │   (CPU/Mem) │  │   Handled)  │           │
│              └─────────────┘  └─────────────┘  └─────────────┘           │
│                                                                             │
│  Trade-offs:                                                                │
│  • Higher throughput → may increase latency                                │
│  • Lower latency → may require more resources                              │
│  • More concurrency → may reduce throughput per connection                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Performance Metrics

| Metric | Definition | Target | How to Measure |
|--------|------------|--------|----------------|
| **Throughput** | Requests per second | 10,000+ req/s | `ab`, `wrk`, `hey` |
| **Latency** | Time to first byte | < 50ms | `curl -w`, logs |
| **Concurrency** | Active connections | 10,000+ | `netstat`, stub_status |
| **Error Rate** | Failed requests | < 0.1% | Log analysis |
| **CPU Usage** | Worker CPU utilization | < 80% | `top`, `ps` |
| **Memory Usage** | RSS per worker | < 50MB | `ps aux` |
| **Network I/O** | Throughput | Max bandwidth | `iftop`, `nload` |

## P3.2 Worker Process Optimization

### Worker Count Calculation

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      WORKER PROCESS OPTIMIZATION                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Determining the optimal number of worker processes:                       │
│                                                                             │
│  1. CPU-Bound Workloads                                                     │
│     worker_processes = number of CPU cores                                 │
│                                                                             │
│  2. I/O-Bound Workloads                                                     │
│     worker_processes = number of CPU cores * 1.5 - 2x                      │
│                                                                             │
│  3. Mixed Workloads                                                         │
│     worker_processes = number of CPU cores + 1                             │
│                                                                             │
│  Examples:                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # 4-core CPU                                                        │   │
│  │ worker_processes 4;         # Standard                              │   │
│  │ worker_processes 6;         # I/O-heavy                             │   │
│  │ worker_processes auto;      # Automatic (recommended)               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  How to check CPU cores:                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Linux                                                             │   │
│  │ nproc                                                               │   │
│  │ grep -c processor /proc/cpuinfo                                     │   │
│  │                                                                     │   │
│  │ # Docker                                                           │   │
│  │ docker exec nginx nproc                                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Worker Connection Limits

```nginx
# Optimized worker configuration
worker_processes auto;
worker_rlimit_nofile 65535;
worker_priority -20;  # Higher priority for Nginx

events {
    worker_connections 65535;   # Max connections per worker
    use epoll;                  # Event model (Linux only)
    multi_accept on;            # Accept multiple connections
    accept_mutex off;           # Disable accept mutex
}

# Alternative configurations for different workloads:

# 1. High throughput (static content)
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
    accept_mutex off;
}

# 2. Low latency (API gateway)
worker_processes 2;  # Fewer workers, less context switching
worker_rlimit_nofile 16384;

events {
    worker_connections 8192;
    use epoll;
    multi_accept off;
    accept_mutex on;
}

# 3. Mixed workloads
worker_processes auto;
worker_rlimit_nofile 32768;

events {
    worker_connections 32768;
    use epoll;
    multi_accept on;
    accept_mutex off;
}
```

### CPU Affinity

```nginx
# Pin workers to specific CPU cores
worker_processes 4;
worker_cpu_affinity 0001 0010 0100 1000;

# Auto-calculate affinity
worker_processes auto;
worker_cpu_affinity auto;

# Example: 8-core system
worker_processes 8;
worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
```

## P3.3 Connection Handling

### Keepalive Optimization

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      KEEPALIVE OPTIMIZATION                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Keepalive benefits:                                                        │
│  • Reduces TCP handshake overhead                                          │
│  • Reuses connections for multiple requests                                │
│  • Improves throughput and latency                                         │
│                                                                             │
│  Configuration:                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Client keepalive                                                 │   │
│  │ keepalive_timeout 65;           # Time to keep idle connections    │   │
│  │ keepalive_requests 1000;        # Max requests per connection      │   │
│  │                                                                     │   │
│  │ # Upstream keepalive                                               │   │
│  │ upstream backend {                                                  │   │
│  │     server backend1:8000;                                          │   │
│  │     server backend2:8000;                                          │   │
│  │     keepalive 32;                 # Idle connections to keep       │   │
│  │     keepalive_requests 1000;      # Max requests per connection    │   │
│  │     keepalive_timeout 60s;        # Idle connection timeout        │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Keepalive Trade-offs:                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Longer timeout:                                                      │   │
│  │ ✅ Higher throughput (reuse connections)                            │   │
│  │ ❌ More memory usage (connections kept open)                        │   │
│  │ ❌ More resource usage (file descriptors)                          │   │
│  │                                                                     │   │
│  │ Shorter timeout:                                                     │   │
│  │ ✅ Lower resource usage                                             │   │
│  │ ❌ More connection setup overhead                                   │   │
│  │ ❌ Higher latency for new connections                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Buffer Configuration

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      BUFFER OPTIMIZATION                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Buffer Sizing Guidelines:                                                  │
│                                                                             │
│  1. Small Buffers (Low memory, potential fragmentation)                    │
│  2. Large Buffers (High memory, better performance)                        │
│  3. Balance based on workload                                              │
│                                                                             │
│  Configuration:                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Client buffers                                                    │   │
│  │ client_body_buffer_size 128k;     # Body buffer                     │   │
│  │ client_header_buffer_size 1k;     # Header buffer                   │   │
│  │ large_client_header_buffers 4 8k; # Large header buffers            │   │
│  │                                                                     │   │
│  │ # Output buffers                                                    │   │
│  │ output_buffers 32 32k;            # Output buffers                  │   │
│  │ postpone_output 1460;             # Buffer before sending          │   │
│  │                                                                     │   │
│  │ # Proxy buffers                                                     │   │
│  │ proxy_buffer_size 4k;             # Response buffer                 │   │
│  │ proxy_buffers 8 4k;              # Response buffers                │   │
│  │ proxy_busy_buffers_size 8k;       # Busy buffers                    │   │
│  │ proxy_temp_file_write_size 8k;    # Temporary file write size      │   │
│  │ proxy_max_temp_file_size 1024m;   # Max temp file size             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Buffer Optimization by Workload:                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Static content (large files)                                     │   │
│  │ output_buffers 64 64k;                                             │   │
│  │ proxy_buffers 16 16k;                                              │   │
│  │                                                                     │   │
│  │ # API (small JSON responses)                                       │   │
│  │ output_buffers 8 8k;                                               │   │
│  │ proxy_buffers 4 8k;                                                │   │
│  │                                                                     │   │
│  │ # Streaming (SSE, WebSockets)                                      │   │
│  │ proxy_buffering off;                                               │   │
│  │ proxy_buffer_size 4k;                                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P3.4 Sendfile and TCP Optimization

### Sendfile Optimization

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      SENDFILE OPTIMIZATION                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Sendfile reduces CPU usage for static file delivery:                      │
│                                                                             │
│  Without sendfile:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Disk → Kernel → Userspace (Nginx) → Kernel → Network               │   │
│  │         │               │               │                           │   │
│  │         2x copying      │               │                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  With sendfile:                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Disk → Kernel → Network                                             │   │
│  │         │                                                            │   │
│  │         1x copying (zero-copy)                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Configuration:                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Basic sendfile                                                    │   │
│  │ sendfile on;                                                        │   │
│  │ tcp_nopush on;                    # Optimize packet sending         │   │
│  │ tcp_nodelay on;                   # Disable Nagle's algorithm       │   │
│  │                                                                     │   │
│  │ # With direct I/O (large files)                                    │   │
│  │ sendfile on;                                                        │   │
│  │ directio 4m;                      # Use direct I/O for large files  │   │
│  │ directio_alignment 512;           # Alignment for direct I/O        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### TCP Stack Optimization

```nginx
# /etc/sysctl.conf - TCP optimization for Nginx

# Connection handling
net.ipv4.tcp_max_syn_backlog = 65535
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535

# Connection reuse
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 3

# Buffer sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_mem = 786432 1048576 1572864

# Port range
net.ipv4.ip_local_port_range = 1024 65000

# Apply changes
sysctl -p
```

## P3.5 Caching Optimization

### Cache Configuration

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CACHE OPTIMIZATION                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Cache Performance Metrics:                                                 │
│  • Hit Rate: Percentage of requests served from cache                      │
│  • Miss Rate: Percentage that go to upstream                              │
│  • Hit Time: Time to serve from cache                                     │
│  • Miss Time: Time to fetch from upstream                                 │
│                                                                             │
│  Configuration:                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Cache path with performance settings                              │   │
│  │ proxy_cache_path /var/cache/nginx/cache                             │   │
│  │     levels=1:2                    # Directory structure             │   │
│  │     keys_zone=my_cache:100m       # Key zone size                   │   │
│  │     max_size=2g                   # Maximum cache size              │   │
│  │     inactive=1h                   # Time before eviction            │   │
│  │     use_temp_path=off             # No temporary files              │   │
│  │     manager_files=100             # Files to manage per cycle       │   │
│  │     manager_threshold=200ms       # Max time per cycle              │   │
│  │     loader_files=100              # Files to load per cycle         │   │
│  │     loader_threshold=200ms        # Max time per cycle              │   │
│  │     loader_sleep=50ms;            # Sleep between cycles            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Cache Optimization:                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Cache key optimization                                            │   │
│  │ proxy_cache_key $scheme$host$request_uri;                           │   │
│  │                                                                     │   │
│  │ # Cache locking (prevent cache stampede)                           │   │
│  │ proxy_cache_lock on;                                                │   │
│  │ proxy_cache_lock_timeout 5s;                                        │   │
│  │ proxy_cache_lock_age 5s;                                           │   │
│  │                                                                     │   │
│  │ # Background update (serve stale while updating)                   │   │
│  │ proxy_cache_use_stale error timeout updating;                       │   │
│  │ proxy_cache_background_update on;                                   │   │
│  │                                                                     │   │
│  │ # Cache revalidation                                               │   │
│  │ proxy_cache_revalidate on;                                          │   │
│  │                                                                     │   │
│  │ # Minimum cache usage                                               │   │
│  │ proxy_cache_min_uses 1;                                            │   │
│  │                                                                     │   │
│  │ # Cache bypass                                                      │   │
│  │ proxy_cache_bypass $http_cache_control;                            │   │
│  │ proxy_no_cache $http_cache_control;                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Cache Hit Ratio Optimization

```nginx
# Different caching strategies for different content types

# 1. Static content (long TTL)
location /static/ {
    proxy_cache static_cache;
    proxy_cache_valid 200 30d;
    proxy_cache_valid 404 1m;
    expires 30d;
    add_header Cache-Control "public, immutable";
}

# 2. API content (short TTL)
location /api/ {
    proxy_cache api_cache;
    proxy_cache_valid 200 1m;
    proxy_cache_valid 404 5s;
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_use_stale error timeout updating;
    add_header X-Cache-Status $upstream_cache_status;
}

# 3. Dynamic content (micro-cache)
location /dynamic/ {
    proxy_cache micro_cache;
    proxy_cache_valid 200 5s;
    proxy_cache_key $scheme$host$request_uri$http_authorization;
    proxy_cache_lock on;
    proxy_cache_lock_timeout 1s;
    add_header X-Cache-Status $upstream_cache_status;
}

# 4. User-specific content (no cache)
location /private/ {
    proxy_no_cache 1;
    proxy_cache_bypass 1;
    add_header X-Cache-Status "BYPASS";
}
```

## P3.6 Gzip and Compression Optimization

### Compression Settings

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      COMPRESSION OPTIMIZATION                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Compression Trade-offs:                                                    │
│  • Higher compression = lower bandwidth, more CPU                          │
│  • Lower compression = higher bandwidth, less CPU                          │
│                                                                             │
│  Configuration:                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Enable compression                                               │   │
│  │ gzip on;                                                            │   │
│  │ gzip_vary on;                    # Vary: Accept-Encoding            │   │
│  │ gzip_proxied any;                # Compress proxied responses       │   │
│  │ gzip_comp_level 6;               # Balance CPU vs compression       │   │
│  │ gzip_min_length 1000;            # Don't compress small files       │   │
│  │ gzip_disable "msie6";            # Skip old browsers                │   │
│  │                                                                     │   │
│  │ # Types to compress                                                │   │
│  │ gzip_types                                                          │   │
│  │     text/plain                                                      │   │
│  │     text/css                                                        │   │
│  │     text/xml                                                        │   │
│  │     text/javascript                                                 │   │
│  │     application/json                                                │   │
│  │     application/javascript                                          │   │
│  │     application/xml+rss                                             │   │
│  │     application/rss+xml                                             │   │
│  │     application/atom+xml                                            │   │
│  │     application/xhtml+xml                                           │   │
│  │     application/ld+json                                             │   │
│  │     application/manifest+json                                       │   │
│  │     image/svg+xml                                                   │   │
│  │     font/ttf                                                        │   │
│  │     font/otf                                                        │   │
│  │     font/woff                                                       │   │
│  │     font/woff2;                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Compression Level by Content Type:                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ # Static assets (compress once, serve multiple times)              │   │
│  │ gzip_static on;                    # Pre-compressed files          │   │
│  │ gzip_comp_level 9;                 # Maximum compression            │   │
│  │                                                                     │   │
│  │ # Dynamic content (compress each request)                          │   │
│  │ gzip_comp_level 3;                 # Faster compression             │   │
│  │                                                                     │   │
│  │ # API responses (small payloads)                                   │   │
│  │ gzip_comp_level 4;                 # Balanced                       │   │
│  │ gzip_min_length 500;               # Lower threshold                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P3.7 Performance Testing

### Load Testing Tools

```bash
# 1. Apache Bench (ab)
ab -n 10000 -c 100 https://localhost/api/
ab -n 10000 -c 100 -H "Authorization: Bearer token" https://localhost/api/

# 2. wrk (more efficient)
wrk -t12 -c400 -d30s https://localhost/api/
wrk -t12 -c400 -d30s --header "Authorization: Bearer token" https://localhost/api/

# 3. hey (Go-based)
hey -n 10000 -c 100 -H "Authorization: Bearer token" https://localhost/api/

# 4. Vegeta (HTTP load testing)
echo "GET https://localhost/api/" | vegeta attack -duration=10s -rate=100 | vegeta report

# 5. Siege
siege -c 100 -t 30s https://localhost/api/
```

### Performance Analysis Commands

```bash
# 1. Check Nginx request rate
tail -100 /var/log/nginx/access.log | wc -l

# 2. Check response times
tail -1000 /var/log/nginx/access.log | jq '.request_time' | sort -n | tail -10

# 3. Check cache hit ratio
tail -1000 /var/log/nginx/access.log | jq -r '.upstream_cache_status' | sort | uniq -c

# 4. Check upstream response times
tail -1000 /var/log/nginx/access.log | jq '.upstream_response_time' | awk '{sum+=$1} END {print sum/NR}'

# 5. Check error rates
tail -1000 /var/log/nginx/access.log | grep -c '"status":5[0-9][0-9]'

# 6. Check active connections
curl -s http://localhost/nginx-status | grep "Active connections"

# 7. Check worker CPU usage
ps aux | grep nginx | grep worker

# 8. Check memory usage
ps aux | grep nginx | awk '{sum+=$6} END {print sum/1024 " MB"}'
```

### Performance Tuning Script

**File: `performance-tune.sh`**

```bash
#!/bin/bash
# performance-tune.sh - Automated performance tuning

echo "=== Nginx Performance Tuning ==="

# Check CPU cores
CPU_CORES=$(nproc)
echo "CPU cores: $CPU_CORES"

# Calculate optimal worker count
if [ $CPU_CORES -le 2 ]; then
    WORKER_COUNT=$CPU_CORES
else
    WORKER_COUNT=$((CPU_CORES * 2))
fi
echo "Optimal worker count: $WORKER_COUNT"

# Check memory
MEMORY=$(free -m | grep Mem | awk '{print $2}')
echo "Total memory: ${MEMORY}MB"

# Calculate optimal connections
if [ $MEMORY -gt 4096 ]; then
    MAX_CONNS=65535
else
    MAX_CONNS=$((MEMORY * 8))
fi
echo "Optimal connections: $MAX_CONNS"

# Update nginx.conf
sed -i "s/worker_processes .*/worker_processes $WORKER_COUNT;/" /etc/nginx/nginx.conf
sed -i "s/worker_connections .*/worker_connections $MAX_CONNS;/" /etc/nginx/nginx.conf

# Test configuration
nginx -t

# Reload if successful
if [ $? -eq 0 ]; then
    nginx -s reload
    echo "Performance tuning applied successfully!"
else
    echo "Configuration test failed!"
    exit 1
fi

echo "Tuning complete!"
```

## P3.8 Advanced Performance Patterns

### Micro-Caching for High Traffic

```nginx
# Micro-caching for extremely high traffic endpoints
proxy_cache_path /var/cache/nginx/micro_cache
    levels=1:2
    keys_zone=micro_cache:10m
    max_size=100m
    inactive=10s
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
```

### Adaptive Rate Limiting

```nginx
# Adaptive rate limiting based on system load
limit_req_zone $binary_remote_addr zone=adaptive:10m rate=100r/s;

location /api/ {
    # Reduce rate limit when system is under load
    if ($connection_requests > 100) {
        set $rate_limit "10r/s";
    }
    
    # Dynamic rate limiting
    limit_req zone=adaptive burst=20 nodelay;
    
    # Prioritize healthy endpoints
    proxy_pass http://$backend;
    
    # Skip cache on high load
    proxy_cache_bypass $http_cache_control;
}
```

### Staggered Caching

```nginx
# Multi-level caching for different stale times
location /api/ {
    # Level 1: Memory cache (fast, small)
    proxy_cache api_mem_cache;
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_valid 200 5s;
    proxy_cache_use_stale error timeout updating;
    
    # Level 2: Disk cache (slower, larger)
    proxy_cache api_disk_cache;
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_valid 200 1m;
    
    # Level 3: Fallback cache
    proxy_cache api_fallback_cache;
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_valid 200 5m;
    proxy_cache_use_stale error timeout updating;
    
    proxy_pass http://backend/;
}
```

---

This primer provides a deep understanding of Nginx performance optimization. Use these techniques to achieve maximum throughput, minimal latency, and efficient resource utilization.
