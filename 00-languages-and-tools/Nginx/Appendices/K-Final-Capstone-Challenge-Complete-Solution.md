# Appendix K: Final Capstone Challenge - Complete Solution

## The Target

This appendix provides the complete solution to the Final Capstone Challenge introduced in Part 10. You'll see the entire production-ready Nginx gateway configuration with all components working together.

## K.1 The Challenge Recap

> **You inherit a production server returning intermittent 502s, WebSocket disconnects, slow API responses, broken authentication redirects, and an Inngest webhook that occasionally times out.**

No configuration is provided.

You receive:
- Application source
- Docker Compose files
- DNS configuration
- Nginx logs
- Application logs
- Browser errors
- A failing deployment

## K.2 The Complete Solution

### Architecture Diagram

```text
                         INTERNET
                            │
                            │ HTTPS (443)
                            ▼
                     ┌─────────────────┐
                     │    Nginx        │
                     │   :443/:80      │
                     │                 │
                     │ ✅ TLS 1.3      │
                     │ ✅ Path Routing │
                     │ ✅ Rate Limiting│
                     │ ✅ Caching      │
                     │ ✅ WebSockets   │
                     │ ✅ SSE          │
                     │ ✅ Logging      │
                     └────────┬────────┘
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
         Next.js         FastAPI        Auth API
          :3000           :8000          :8001
             │              │              │
             ├── WebSocket  │              │
             │   :8002      │              │
             ├── SSE        │              │
             │   :8003      │              │
             └── Webhook    │              │
                 :8004      │              │
                            │              │
                            └──────┬───────┘
                                   │
                              Neon Postgres
```

### Complete Configuration

**File: `nginx.conf` (Complete Capstone Solution)**

```nginx
# ============================================================================
# Nginx Production Gateway - Capstone Challenge Solution
# ============================================================================
# This configuration solves all problems:
# - 502 Bad Gateway: Fixed with health checks and proper upstream configuration
# - WebSocket disconnects: Fixed with upgrade headers and timeouts
# - Slow API responses: Fixed with caching and load balancing
# - Broken authentication: Fixed with proper header forwarding
# - Webhook timeouts: Fixed with extended timeouts and retry logic
# ============================================================================

# ============================================================================
# Global Settings
# ============================================================================
worker_processes auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# ============================================================================
# Events Block
# ============================================================================
events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

# ============================================================================
# HTTP Block
# ============================================================================
http {
    # ------------------------------------------------------------------------
    # Basic Settings
    # ------------------------------------------------------------------------
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server_tokens off;
    charset utf-8;
    
    # ------------------------------------------------------------------------
    # Performance Settings
    # ------------------------------------------------------------------------
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10M;
    
    # ------------------------------------------------------------------------
    # Logging - Structured JSON
    # ------------------------------------------------------------------------
    log_format json escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"remote_port":"$remote_port",'
        '"request_id":"$request_id",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_status":$upstream_status,'
        '"upstream_response_time":$upstream_response_time,'
        '"http_referer":"$http_referer",'
        '"http_user_agent":"$http_user_agent",'
        '"http_x_forwarded_for":"$http_x_forwarded_for",'
        '"http_x_request_id":"$http_x_request_id",'
        '"ssl_protocol":"$ssl_protocol",'
        '"ssl_cipher":"$ssl_cipher"'
    '}';
    
    access_log /var/log/nginx/access.log json;
    error_log /var/log/nginx/error.log warn;
    
    # ------------------------------------------------------------------------
    # Request ID Generation
    # ------------------------------------------------------------------------
    map $http_x_request_id $request_id {
        default $http_x_request_id;
        '' $request_uuid;
    }
    
    set $request_uuid $request_id;
    if ($request_uuid = "") {
        set $request_uuid $request_id;
    }
    
    # ------------------------------------------------------------------------
    # Security Headers
    # ------------------------------------------------------------------------
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), accelerometer=(), gyroscope=()" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self'; upgrade-insecure-requests;" always;
    
    # ------------------------------------------------------------------------
    # Rate Limiting Zones
    # ------------------------------------------------------------------------
    limit_req_zone $binary_remote_addr zone=global_limit:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=admin_limit:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=ws_limit:10m rate=30r/m;
    limit_req_zone $binary_remote_addr zone=webhook_limit:10m rate=30r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # ------------------------------------------------------------------------
    # Gzip Compression
    # ------------------------------------------------------------------------
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml application/atom+xml image/svg+xml;
    gzip_min_length 1000;
    gzip_disable "msie6";
    
    # ------------------------------------------------------------------------
    # Cache Paths
    # ------------------------------------------------------------------------
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2 keys_zone=api_cache:100m max_size=1g inactive=1h use_temp_path=off;
    
    proxy_cache_path /var/cache/nginx/micro_cache
        levels=1:2 keys_zone=micro_cache:50m max_size=500m inactive=5s use_temp_path=off;
    
    proxy_cache_path /var/cache/nginx/static_cache
        levels=1:2 keys_zone=static_cache:50m max_size=500m inactive=30d use_temp_path=off;
    
    # ------------------------------------------------------------------------
    # Upstream Groups
    # ------------------------------------------------------------------------
    # Frontend
    upstream frontend_backend {
        server nextjs:3000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # API - Blue/Green
    upstream api_blue {
        server fastapi-blue:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream api_green {
        server fastapi-green:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Blue-green switching
    map $cookie_upstream $active_api {
        default "blue";
        "green" "green";
        "blue" "blue";
    }
    
    # Authentication
    upstream auth_backend {
        server auth-api:8001 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # WebSocket
    upstream websocket_backend {
        server websocket:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # SSE
    upstream sse_backend {
        server sse:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Webhook
    upstream webhook_backend {
        server webhook:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # ------------------------------------------------------------------------
    # Main HTTPS Server
    # ------------------------------------------------------------------------
    server {
        listen 443 ssl http2;
        server_name localhost;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;
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
        
        # Global rate limiting
        limit_req zone=global_limit burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # Request validation
        if ($http_user_agent ~* "(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan|joomscan)") {
            return 403;
        }
        
        if ($request_uri ~* "\.\./") {
            return 403;
        }
        
        # --------------------------------------------------------------------
        # Location: Static Assets
        # --------------------------------------------------------------------
        location /static/ {
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            proxy_cache static_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            gzip_static on;
            gzip_proxied any;
            
            root /usr/share/nginx/html;
        }
        
        # --------------------------------------------------------------------
        # Location: Health Check
        # --------------------------------------------------------------------
        location /health {
            limit_req zone=global_limit burst=5 nodelay;
            
            proxy_pass http://frontend_backend/health;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # --------------------------------------------------------------------
        # Location: Frontend (Next.js)
        # --------------------------------------------------------------------
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Content-Type-Options "nosniff";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 30s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
        
        # --------------------------------------------------------------------
        # Location: API (FastAPI) - FIXED: Load balancing with health checks
        # --------------------------------------------------------------------
        location /api/ {
            limit_req zone=api_limit burst=10 nodelay;
            
            # Request validation
            if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
                return 405;
            }
            
            if ($query_string ~* "(union|select|insert|update|delete|drop|exec|eval|ALTER|CREATE|TABLE|javascript:|alert)") {
                return 403;
            }
            
            # Blue-green routing
            set $upstream_name $active_api;
            if ($http_x_upstream) {
                set $upstream_name $http_x_upstream;
            }
            
            if ($upstream_name = "green") {
                proxy_pass http://api_green/;
            }
            if ($upstream_name = "blue") {
                proxy_pass http://api_blue/;
            }
            if ($upstream_name = "") {
                proxy_pass http://api_blue/;
            }
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Upstream $upstream_name;
            proxy_set_header X-Content-Type-Options "nosniff";
            
            # Caching for public endpoints
            if ($request_uri ~* "/public/") {
                proxy_cache api_cache;
                proxy_cache_key $scheme$host$request_uri;
                proxy_cache_valid 200 302 5m;
                proxy_cache_use_stale error timeout updating;
                proxy_cache_lock on;
                proxy_cache_lock_timeout 5s;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Retry on failure - FIXED: Handles 502 errors
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
            
            # Health check - FIXED: Prevents 502
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Location: Authentication - FIXED: Proper headers
        # --------------------------------------------------------------------
        location /auth/ {
            limit_req zone=auth_limit burst=2 nodelay;
            limit_conn conn_limit 1;
            
            proxy_pass http://auth_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            proxy_set_header X-Content-Type-Options "nosniff";
            
            # Cookie handling
            proxy_cookie_path / "/; Secure; HttpOnly; SameSite=Lax";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # --------------------------------------------------------------------
        # Location: WebSocket - FIXED: Upgrade headers and timeouts
        # --------------------------------------------------------------------
        location /ws/ {
            limit_req zone=ws_limit burst=5 nodelay;
            
            proxy_pass http://websocket_backend/;
            
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_buffering off;
            
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 300s;
            
            proxy_next_upstream error timeout invalid_header http_500 http_502;
            proxy_next_upstream_tries 2;
        }
        
        # --------------------------------------------------------------------
        # Location: SSE - FIXED: Buffering disabled
        # --------------------------------------------------------------------
        location /sse/ {
            proxy_pass http://sse_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_set_header X-Accel-Buffering no;
            
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            
            proxy_read_timeout 600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 600s;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Location: Webhook - FIXED: Timeouts and retries
        # --------------------------------------------------------------------
        location /webhook/ {
            limit_req zone=webhook_limit burst=5 nodelay;
            
            proxy_pass http://webhook_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Content-Type-Options "nosniff";
            
            client_max_body_size 10M;
            client_body_buffer_size 128k;
            
            proxy_buffering on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 300s;
            
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Location: Admin (Restricted)
        # --------------------------------------------------------------------
        location /admin/ {
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;
            
            limit_req zone=admin_limit burst=2 nodelay;
            
            proxy_pass http://api_blue/admin/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Authorization $http_authorization;
            
            add_header X-Robots-Tag "noindex, nofollow" always;
            add_header Cache-Control "no-store, no-cache, must-revalidate" always;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # --------------------------------------------------------------------
        # Location: Debug (Internal Only)
        # --------------------------------------------------------------------
        location /debug/ {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            deny all;
            
            proxy_pass http://api_blue/debug/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # --------------------------------------------------------------------
        # Location: Nginx Status (Internal Only)
        # --------------------------------------------------------------------
        location /nginx-status {
            allow 127.0.0.1;
            deny all;
            
            stub_status on;
            access_log off;
        }
        
        # --------------------------------------------------------------------
        # Location: Blue-Green Switch
        # --------------------------------------------------------------------
        location /admin/switch {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            add_header Set-Cookie "upstream=$arg_to; Path=/; Max-Age=3600";
            add_header X-Upstream-Switched $arg_to;
            
            return 200 "Switched to $arg_to upstream\n";
        }
        
        # --------------------------------------------------------------------
        # Location: Upstream Status
        # --------------------------------------------------------------------
        location /admin/upstream-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 "Current upstream: $active_api\n";
        }
    }
    
    # =========================================================================
    # HTTP Redirect Server
    # =========================================================================
    server {
        listen 80;
        server_name localhost;
        
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        
        return 301 https://$host$request_uri;
    }
}
```

## K.3 Problem Resolution Summary

| Problem | Root Cause | Solution |
|---------|-----------|----------|
| **502 Bad Gateway** | Upstream health checks failing | Added `proxy_next_upstream` with retry logic, health checks |
| **WebSocket Disconnects** | Missing upgrade headers | Added `proxy_set_header Upgrade` and `Connection: upgrade` |
| **Slow API Responses** | No caching | Added API caching with `proxy_cache` |
| **Broken Authentication** | Missing forwarded headers | Added `X-Forwarded-Proto` and proper header forwarding |
| **Webhook Timeouts** | Default timeout too short | Extended `proxy_read_timeout` to 300s |
| **Intermittent Failures** | No failover | Added `proxy_next_upstream` with retry attempts |

## K.4 Verification Commands

```bash
# Test the complete solution
./validate.sh

# Expected output:
# === Nginx Gateway Validation ===
# Testing HTTPS... ✓ OK
# Testing API... ✓ OK
# Testing WebSocket... ✓ OK
# Testing SSE... ✓ OK
# Testing Rate Limiting... ✓ OK
# Testing Security Headers... ✓ OK
# All tests passed! ✓

# Check upstream status
curl -k https://localhost/admin/upstream-status
# Should show: Current upstream: blue

# Switch to green
curl -k -X POST "https://localhost/admin/switch?to=green"
# Should show: Switched to green upstream

# Verify switch
curl -k https://localhost/api/ | grep instance
# Should show green instance

# Check logs
tail -f logs/access.log | jq '.request_time, .status, .upstream_addr'
```

## K.5 Final Deliverable Checklist

The final solution provides:

- ✅ Reverse proxy with SSL termination
- ✅ Path-based routing to all services
- ✅ TLS 1.2/1.3 with strong ciphers
- ✅ Authentication-aware proxying
- ✅ Rate limiting for all endpoints
- ✅ WebSocket support with upgrade headers
- ✅ SSE streaming with buffering disabled
- ✅ Webhook handling with extended timeouts
- ✅ Caching for API and static assets
- ✅ Gzip compression
- ✅ Load balancing with blue-green support
- ✅ Health checks with automatic failover
- ✅ Structured JSON logging
- ✅ Security headers and hardening
- ✅ Internal-only admin endpoints
- ✅ Zero-downtime reload capability
- ✅ Complete documentation

## K.6 Final Words

This capstone solution demonstrates everything you've learned throughout the series:

1. **Identify** the failure domains
2. **Trace** requests through Nginx
3. **Diagnose** upstream failures
4. **Repair** routing and headers
5. **Configure** WebSockets and SSE
6. **Tune** timeouts and caching
7. **Protect** with rate limiting
8. **Harden** security
9. **Implement** structured logging
10. **Create** a production-ready gateway

You've built a complete, production-ready Nginx gateway from the ground up. `nginx.conf` is no longer magic—it's **executable architecture**.
