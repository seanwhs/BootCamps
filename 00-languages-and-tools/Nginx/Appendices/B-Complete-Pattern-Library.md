# Appendix B: Complete Pattern Library

## The Target

This appendix contains a comprehensive library of reusable Nginx configuration patterns. Each pattern is a complete, production-ready configuration snippet that you can adapt for your specific needs. Think of this as your Nginx cookbook—when you need to solve a common problem, look here first.

## B.1 Reverse Proxy Patterns

### Pattern RP-01: Basic Reverse Proxy

```nginx
# Basic reverse proxy with essential headers
location / {
    proxy_pass http://backend:8000;
    
    # Essential headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # HTTP version and keepalive
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

### Pattern RP-02: Reverse Proxy with Timeouts

```nginx
# Reverse proxy with configurable timeouts
location /api/ {
    proxy_pass http://backend:8000/;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Timeouts
    proxy_connect_timeout 10s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
    
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

### Pattern RP-03: Reverse Proxy with Retry

```nginx
# Reverse proxy with automatic retry on failure
location /api/ {
    proxy_pass http://backend:8000/;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Retry configuration
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
    proxy_next_upstream_tries 3;
    proxy_next_upstream_timeout 30s;
    
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

### Pattern RP-04: Proxy with Buffering Control

```nginx
# Reverse proxy with buffering configuration
location /api/ {
    proxy_pass http://backend:8000/;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Buffering control
    proxy_buffering on;
    proxy_buffer_size 8k;
    proxy_buffers 8 8k;
    proxy_busy_buffers_size 16k;
    proxy_temp_file_write_size 8k;
    
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

## B.2 Load Balancing Patterns

### Pattern LB-01: Round Robin Load Balancing

```nginx
# Default round-robin load balancing
upstream backend {
    server backend1:8000;
    server backend2:8000;
    server backend3:8000;
    
    keepalive 32;
}

location / {
    proxy_pass http://backend/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Pattern LB-02: Weighted Load Balancing

```nginx
# Weighted load balancing (different server capacities)
upstream backend {
    # backend1 is more powerful - gets 3x traffic
    server backend1:8000 weight=3 max_fails=3 fail_timeout=30s;
    # backend2 is standard - gets 1x traffic
    server backend2:8000 weight=1 max_fails=3 fail_timeout=30s;
    # backup server - only used when others fail
    server backup:8000 backup;
    
    keepalive 32;
}
```

### Pattern LB-03: Least Connections

```nginx
# Least connections algorithm
upstream backend {
    least_conn;
    server backend1:8000;
    server backend2:8000;
    server backend3:8000;
    
    keepalive 32;
}
```

### Pattern LB-04: IP Hash (Sticky Sessions)

```nginx
# Sticky sessions using client IP
upstream backend {
    ip_hash;
    server backend1:8000;
    server backend2:8000;
    server backend3:8000;
    
    keepalive 32;
}
```

### Pattern LB-05: Health Checks with Failover

```nginx
# Advanced health checks and failover
upstream backend {
    server backend1:8000 max_fails=3 fail_timeout=30s;
    server backend2:8000 max_fails=3 fail_timeout=30s;
    server backend3:8000 max_fails=3 fail_timeout=30s;
    
    # Backup servers
    server backup1:8000 backup;
    server backup2:8000 backup;
    
    keepalive 32;
}

# Health check endpoint
location /health {
    proxy_pass http://backend/health;
    proxy_connect_timeout 2s;
    proxy_read_timeout 5s;
    access_log off;
}
```

## B.3 Caching Patterns

### Pattern C-01: Proxy Caching

```nginx
# Define cache zone
proxy_cache_path /var/cache/nginx/cache
    levels=1:2
    keys_zone=my_cache:100m
    max_size=1g
    inactive=1h
    use_temp_path=off;

# Use cache
location /api/ {
    proxy_cache my_cache;
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_valid 200 302 5m;
    proxy_cache_valid 404 1m;
    proxy_cache_use_stale error timeout updating;
    proxy_cache_lock on;
    proxy_cache_lock_timeout 5s;
    
    add_header X-Cache-Status $upstream_cache_status;
    
    proxy_pass http://backend/;
    proxy_set_header Host $host;
}
```

### Pattern C-02: Micro-Caching

```nginx
# Micro-caching for high-traffic dynamic endpoints
proxy_cache_path /var/cache/nginx/micro_cache
    levels=1:2
    keys_zone=micro_cache:50m
    max_size=500m
    inactive=5s
    use_temp_path=off;

location /api/dynamic/ {
    proxy_cache micro_cache;
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_valid 200 302 5s;
    proxy_cache_valid 404 1s;
    proxy_cache_use_stale error timeout updating;
    proxy_cache_lock on;
    proxy_cache_lock_timeout 1s;
    
    add_header X-Cache-Status $upstream_cache_status;
    
    proxy_pass http://backend/dynamic/;
}
```

### Pattern C-03: Static Asset Caching

```nginx
# Browser caching for static assets
location /static/ {
    alias /var/www/static/;
    
    # Long-term caching
    expires 30d;
    add_header Cache-Control "public, immutable";
    add_header X-Content-Type-Options "nosniff";
    
    # Gzip static files
    gzip_static on;
    gzip_proxied any;
}

# File type-based caching
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
    add_header X-Content-Type-Options "nosniff";
}
```

### Pattern C-04: Cache Bypass

```nginx
# Bypass cache for specific conditions
location /api/ {
    proxy_cache my_cache;
    proxy_cache_key $scheme$host$request_uri;
    
    # Bypass cache for authenticated users
    proxy_cache_bypass $cookie_sessionid;
    proxy_no_cache $cookie_sessionid;
    
    # Bypass on specific header
    proxy_cache_bypass $http_cache_control;
    proxy_no_cache $http_cache_control;
    
    # Valid cache responses
    proxy_cache_valid 200 302 5m;
    
    proxy_pass http://backend/;
}
```

## B.4 Rate Limiting Patterns

### Pattern RL-01: Basic Rate Limiting

```nginx
# Define rate limiting zone
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;

location /api/ {
    limit_req zone=api_limit burst=10 nodelay;
    proxy_pass http://backend/;
}
```

### Pattern RL-02: Multi-Level Rate Limiting

```nginx
# Different limits for different endpoints
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
limit_req_zone $binary_remote_addr zone=admin_limit:10m rate=30r/m;

location /auth/login {
    limit_req zone=auth_limit burst=2 nodelay;
    proxy_pass http://auth_backend/login;
}

location /api/ {
    limit_req zone=api_limit burst=10 nodelay;
    proxy_pass http://api_backend/;
}

location /admin/ {
    limit_req zone=admin_limit burst=5 nodelay;
    proxy_pass http://admin_backend/;
}
```

### Pattern RL-03: Connection Limiting

```nginx
# Limit concurrent connections per IP
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

location /api/ {
    limit_conn conn_limit 10;
    limit_req zone=api_limit burst=10 nodelay;
    proxy_pass http://backend/;
}
```

### Pattern RL-04: Rate Limit with Whitelist

```nginx
# Whitelist internal IPs from rate limiting
geo $limit_whitelist {
    default 1;
    10.0.0.0/8 0;
    172.16.0.0/12 0;
    192.168.0.0/16 0;
    127.0.0.1 0;
}

limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;

location /api/ {
    limit_req zone=api_limit burst=10 nodelay if=$limit_whitelist;
    proxy_pass http://backend/;
}
```

## B.5 Security Patterns

### Pattern S-01: Security Headers

```nginx
# Complete security headers
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=()" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self'; upgrade-insecure-requests;" always;
```

### Pattern S-02: Request Validation

```nginx
# Validate and sanitize requests
location /api/ {
    # Block suspicious user agents
    if ($http_user_agent ~* "(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan)") {
        return 403;
    }
    
    # Block path traversal
    if ($request_uri ~* "\.\./") {
        return 403;
    }
    
    # Block SQL injection attempts
    if ($query_string ~* "(union|select|insert|update|delete|drop|exec|eval|ALTER|CREATE|TABLE)") {
        return 403;
    }
    
    # Block XSS attempts
    if ($query_string ~* "(<|>|%3C|%3E|javascript:|alert|onerror|onload)") {
        return 403;
    }
    
    # Only allow specific methods
    if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
        return 405;
    }
    
    proxy_pass http://backend/;
}
```

### Pattern S-03: IP-Based Access Control

```nginx
# Restrict access by IP
location /admin/ {
    # Allow internal networks
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    allow 192.168.0.0/16;
    allow 127.0.0.1;
    
    # Deny everyone else
    deny all;
    
    proxy_pass http://admin_backend/;
}
```

### Pattern S-04: CORS Configuration

```nginx
# CORS configuration for API
location /api/ {
    # Handle preflight requests
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Accept, X-Requested-With';
        add_header 'Access-Control-Max-Age' 86400;
        add_header 'Content-Length' 0;
        return 204;
    }
    
    # Main request
    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Credentials' 'true';
    
    proxy_pass http://api_backend/;
}
```

### Pattern S-05: TLS Hardening

```nginx
# TLS hardening configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1h;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 1.1.1.1 8.8.8.8 valid=300s;
resolver_timeout 5s;

# DH parameters for Perfect Forward Secrecy
ssl_dhparam /etc/nginx/ssl/dhparam.pem;

# Strict SSL settings
ssl_verify_client off;
ssl_verify_depth 1;
```

## B.6 WebSocket Patterns

### Pattern WS-01: Basic WebSocket Proxy

```nginx
# Basic WebSocket proxy
location /ws/ {
    proxy_pass http://websocket_backend/;
    
    # Required for WebSocket upgrade
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # Headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;
    
    # Disable buffering
    proxy_buffering off;
    
    # Long timeouts for WebSocket
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 300s;
}
```

### Pattern WS-02: WebSocket with Authentication

```nginx
# WebSocket with authentication
location /ws/ {
    # Validate authentication cookie/token
    if ($cookie_auth_token = "") {
        return 401;
    }
    
    proxy_pass http://websocket_backend/;
    
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # Forward authentication
    proxy_set_header Authorization $http_authorization;
    proxy_set_header Cookie $http_cookie;
    proxy_set_header X-Auth-Token $cookie_auth_token;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;
    
    proxy_buffering off;
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 300s;
}
```

## B.7 SSE Patterns

### Pattern SSE-01: Basic SSE Proxy

```nginx
# Basic SSE proxy
location /sse/ {
    proxy_pass http://sse_backend/;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;
    
    # CRITICAL: Disable buffering for SSE
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_set_header X-Accel-Buffering no;
    
    # Cache control for SSE
    add_header Cache-Control "no-cache, no-store, must-revalidate";
    add_header Pragma "no-cache";
    
    # Long timeouts for SSE
    proxy_read_timeout 600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 600s;
    
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

## B.8 Webhook Patterns

### Pattern WH-01: Basic Webhook Handler

```nginx
# Basic webhook handler
location /webhook/ {
    proxy_pass http://webhook_backend/;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;
    proxy_set_header X-Content-Type-Options "nosniff";
    
    # Webhook-specific settings
    client_max_body_size 10M;
    client_body_buffer_size 128k;
    
    # Buffer for large payloads
    proxy_buffering on;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
    
    # Timeouts for webhook processing
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 300s;
    
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

### Pattern WH-02: Inngest Webhook Integration

```nginx
# Inngest webhook handler
location /inngest/ {
    # Rate limiting for webhooks
    limit_req zone=webhook_limit burst=10 nodelay;
    
    proxy_pass http://webhook_backend/;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;
    proxy_set_header X-Inngest-Source "webhook";
    
    # Inngest-specific settings
    client_max_body_size 1M;
    client_body_buffer_size 128k;
    
    proxy_buffering on;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
    
    # Inngest expects quick acknowledgment
    proxy_read_timeout 30s;
    proxy_connect_timeout 10s;
    proxy_send_timeout 30s;
    
    # Retry configuration
    proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
    proxy_next_upstream_tries 3;
    proxy_next_upstream_timeout 30s;
    
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

## B.9 Blue-Green Patterns

### Pattern BG-01: Simple Blue-Green Switch

```nginx
# Blue-green deployment configuration
upstream api_blue {
    server blue:8000;
    keepalive 32;
}

upstream api_green {
    server green:8000;
    keepalive 32;
}

# Map to control upstream selection
map $cookie_upstream $active_api {
    default "blue";
    "green" "green";
    "blue" "blue";
}

location /api/ {
    # Select upstream based on cookie
    if ($active_api = "green") {
        proxy_pass http://api_green/;
    }
    if ($active_api = "blue") {
        proxy_pass http://api_blue/;
    }
    if ($active_api = "") {
        proxy_pass http://api_blue/;
    }
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;
}

# Switch endpoint
location /admin/switch {
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    
    add_header Set-Cookie "upstream=$arg_to; Path=/; Max-Age=3600";
    return 200 "Switched to $arg_to\n";
}
```

### Pattern BG-02: Weighted Blue-Green

```nginx
# Weighted blue-green (gradual rollout)
upstream api_blue {
    server blue:8000;
    keepalive 32;
}

upstream api_green {
    server green:8000;
    keepalive 32;
}

upstream api_mixed {
    server blue:8000 weight=5;
    server green:8000 weight=1;
    keepalive 32;
}

# Map to control rollout
map $cookie_upstream $active_api {
    default "mixed";
    "green" "green";
    "blue" "blue";
    "mixed" "mixed";
}

location /api/ {
    # Use different upstreams
    if ($active_api = "green") {
        proxy_pass http://api_green/;
    }
    if ($active_api = "blue") {
        proxy_pass http://api_blue/;
    }
    if ($active_api = "mixed") {
        proxy_pass http://api_mixed/;
    }
    if ($active_api = "") {
        proxy_pass http://api_mixed/;
    }
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## B.10 Observability Patterns

### Pattern O-01: Structured JSON Logging

```nginx
# JSON log format
log_format json escape=json '{'
    '"timestamp":"$time_iso8601",'
    '"remote_addr":"$remote_addr",'
    '"request_id":"$request_id",'
    '"request_method":"$request_method",'
    '"request_uri":"$request_uri",'
    '"status":$status,'
    '"body_bytes_sent":$body_bytes_sent,'
    '"request_time":$request_time,'
    '"upstream_addr":"$upstream_addr",'
    '"upstream_status":$upstream_status,'
    '"upstream_response_time":$upstream_response_time",'
    '"http_referer":"$http_referer",'
    '"http_user_agent":"$http_user_agent",'
    '"http_x_forwarded_for":"$http_x_forwarded_for",'
    '"ssl_protocol":"$ssl_protocol"'
'}';

access_log /var/log/nginx/access.log json;
```

### Pattern O-02: Request ID Generation

```nginx
# Generate and propagate request IDs
map $http_x_request_id $request_id {
    default $http_x_request_id;
    '' $request_uuid;
}

# Generate unique ID
set $request_uuid $request_id;
if ($request_uuid = "") {
    set $request_uuid $request_id;
}

location /api/ {
    # Forward request ID
    proxy_set_header X-Request-ID $request_uuid;
    
    # Add to response
    add_header X-Request-ID $request_uuid;
    
    proxy_pass http://backend/;
}
```

### Pattern O-03: Health Check Endpoints

```nginx
# Health check endpoint
location /health {
    proxy_pass http://backend/health;
    proxy_connect_timeout 2s;
    proxy_read_timeout 5s;
    access_log off;
}

# Detailed health with upstream status
location /health/detailed {
    proxy_pass http://backend/health/detailed;
    proxy_connect_timeout 2s;
    proxy_read_timeout 5s;
}

# Nginx health status
location /nginx-health {
    access_log off;
    return 200 "healthy\n";
}

# Stub status
location /nginx-status {
    allow 127.0.0.1;
    deny all;
    stub_status on;
    access_log off;
}
```

### Pattern O-04: Performance Metrics

```nginx
# Performance logging
log_format perf '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $body_bytes_sent '
                '$request_time $upstream_response_time '
                '"$upstream_addr" "$upstream_cache_status"';

# Separate performance log
access_log /var/log/nginx/perf.log perf;

# Add timing headers
location /api/ {
    proxy_pass http://backend/;
    
    # Add response time headers
    add_header X-Response-Time $request_time;
    add_header X-Upstream-Time $upstream_response_time;
    add_header X-Cache-Status $upstream_cache_status;
}
```

## B.11 Compression Patterns

### Pattern CP-01: Gzip Compression

```nginx
# Gzip compression configuration
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_min_length 1000;
gzip_disable "msie6";

# Gzip types
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
    image/svg+xml
    font/ttf
    font/otf
    font/woff
    font/woff2;

# Static file compression
location /static/ {
    gzip_static on;
    gzip_proxied any;
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

## B.12 Deployment Patterns

### Pattern D-01: Zero-Downtime Reload

```bash
#!/bin/bash
# zero-downtime-reload.sh

# Test configuration
echo "Testing configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "Configuration test failed!"
    exit 1
fi

# Perform graceful reload
echo "Reloading Nginx..."
nginx -s reload

# Wait for reload to complete
sleep 2

# Verify reload worked
echo "Verifying reload..."
ps aux | grep nginx
```

### Pattern D-02: Graceful Shutdown

```nginx
# Graceful shutdown settings
worker_shutdown_timeout 30s;

server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Connection draining
    proxy_read_timeout 30s;
    proxy_connect_timeout 30s;
    
    # Location with draining
    location /api/ {
        proxy_pass http://backend/;
        # Existing connections will complete
        # New connections will be handled by new workers
    }
}
```

## B.13 Debug Patterns

### Pattern DB-01: Debug Endpoints

```nginx
# Debug endpoints (restricted)
location /debug/ {
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    
    # Request info
    location /debug/info {
        return 200 "Method: $request_method\nURI: $request_uri\nHost: $http_host\nRemote: $remote_addr\n";
    }
    
    # Headers dump
    location /debug/headers {
        return 200 "Headers:\n$http_*\n";
    }
    
    # Connection info
    location /debug/connection {
        return 200 "Protocol: $ssl_protocol\nCipher: $ssl_cipher\nKeepalive: $keepalive\n";
    }
}
```

### Pattern DB-02: Trace Logging

```nginx
# Enable trace logging for debugging
location /debug/trace {
    access_log /var/log/nginx/trace-access.log json;
    error_log /var/log/nginx/trace-error.log debug;
    
    proxy_pass http://backend/;
    proxy_set_header X-Trace-Enabled "true";
}
```

## B.14 Docker Patterns

### Pattern DC-01: Docker Compose with Nginx

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:1.27-alpine
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
      - ./cache:/var/cache/nginx
    depends_on:
      - backend
    networks:
      - app-network

  backend:
    build: ./backend
    container_name: backend
    environment:
      - NODE_ENV=production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### Pattern DC-02: Health Check Configuration

```yaml
# Docker health check for service
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 30s
```

---

This pattern library contains everything you need to build production-ready Nginx configurations. Each pattern can be combined and adapted to create the perfect configuration for your use case.
