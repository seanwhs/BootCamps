# Part 10: Capstone - Production Full-Stack Gateway

## The Target

Welcome to the final part of our journey. We're going to build the complete production-ready Nginx gateway that brings together everything you've learned. By the end of this part, you'll have:

- A complete production-grade Nginx configuration
- All seven architectural levels integrated
- Full observability and monitoring
- Zero-downtime deployment capability
- Complete security hardening
- Comprehensive documentation
- A working Docker Compose environment
- A troubleshooting runbook

## The Concept: Executable Architecture

Think of this final configuration like a complete building blueprint:

- **Foundation** (HTTP/HTTPS): The basics that support everything
- **Framework** (Routing): The structure that organizes traffic
- **Walls** (Security): Protection from the outside world
- **Rooms** (Services): The functional spaces users interact with
- **Systems** (Observability): Monitoring, heating, electrical
- **Management** (Operations): How to maintain and update

By the end, `nginx.conf` will stop looking like magic. It will look like **executable architecture**—a living document that defines how your application actually works.

## The Complete Application Stack

```text
                         INTERNET
                            │
                            │ HTTPS (443)
                            ▼
                     ┌─────────────┐
                     │    Nginx    │
                     │             │
                     │ ✅ TLS 1.3  │
                     │ ✅ Routing  │
                     │ ✅ Rate Lim │
                     │ ✅ Logging  │
                     │ ✅ Caching  │
                     │ ✅ Security │
                     └──────┬──────┘
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
         Next.js         FastAPI        Auth API
          :3000           :8000          :8001
             │              │              │
             │              └──────┬───────┘
             │                     │
             ├── WebSocket        Neon
             │   :8002
             ├── SSE
             │   :8003
             └── Webhook
                 :8004
```

### Step 1: Setup Complete Environment

```bash
mkdir -p nginx-series/part-10
cd nginx-series/part-10

# Copy all applications from previous parts
cp -r ../part-09/fastapi-blue .
cp -r ../part-09/fastapi-green .
cp -r ../part-09/ssl .
cp -r ../part-09/logs .
cp -r ../part-09/scripts .
cp -r ../part-09/security-tests .

# Copy additional apps
cp -r ../part-05/websocket-app .
cp -r ../part-05/sse-app .
cp -r ../part-05/webhook-app .
cp -r ../part-01/nextjs-app .

# Create final configuration directories
mkdir -p conf.d snippets
```

### Step 2: The Complete nginx.conf

**File: `nginx.conf` (Complete Production Gateway)**

```nginx
# ============================================================================
# Nginx Production Gateway - Complete Configuration
# ============================================================================
# This configuration combines everything from the series:
# - Reverse proxy fundamentals (Part 1)
# - Path-based routing (Part 2)
# - SSL/TLS termination (Part 3)
# - Authentication & rate limiting (Part 4)
# - WebSockets, SSE & webhooks (Part 5)
# - Caching & compression (Part 6)
# - Load balancing & zero-downtime (Part 7)
# - Observability & debugging (Part 8)
# - Security hardening (Part 9)
# ============================================================================

# ============================================================================
# Global Settings
# ============================================================================
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;

# Error log configuration
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
    # Security Headers
    # ------------------------------------------------------------------------
    # HSTS - Enforce HTTPS
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # MIME sniffing prevention
    add_header X-Content-Type-Options "nosniff" always;
    
    # Clickjacking prevention
    add_header X-Frame-Options "DENY" always;
    
    # XSS protection
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Referrer policy
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Permissions policy
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), accelerometer=(), gyroscope=()" always;
    
    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self'; upgrade-insecure-requests;" always;
    
    # ------------------------------------------------------------------------
    # Rate Limiting Zones
    # ------------------------------------------------------------------------
    # Global rate limit
    limit_req_zone $binary_remote_addr zone=global_limit:10m rate=100r/m;
    
    # Authentication rate limit (strict)
    limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/m;
    
    # API rate limit
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
    
    # Admin rate limit (very strict)
    limit_req_zone $binary_remote_addr zone=admin_limit:10m rate=5r/m;
    
    # WebSocket rate limit
    limit_req_zone $binary_remote_addr zone=ws_limit:10m rate=30r/m;
    
    # Webhook rate limit
    limit_req_zone $binary_remote_addr zone=webhook_limit:10m rate=30r/m;
    
    # Connection limiting
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # ------------------------------------------------------------------------
    # Gzip Compression
    # ------------------------------------------------------------------------
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
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
        image/svg+xml;
    gzip_min_length 1000;
    gzip_disable "msie6";
    
    # ------------------------------------------------------------------------
    # Proxy Cache Paths
    # ------------------------------------------------------------------------
    # API cache - 1GB, 1 hour inactive
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2
        keys_zone=api_cache:100m
        max_size=1g
        inactive=1h
        use_temp_path=off;
    
    # Micro-cache - 500MB, 5 second TTL
    proxy_cache_path /var/cache/nginx/micro_cache
        levels=1:2
        keys_zone=micro_cache:50m
        max_size=500m
        inactive=5s
        use_temp_path=off;
    
    # Static cache - 500MB, 30 days
    proxy_cache_path /var/cache/nginx/static_cache
        levels=1:2
        keys_zone=static_cache:50m
        max_size=500m
        inactive=30d
        use_temp_path=off;
    
    # ------------------------------------------------------------------------
    # Request ID Generation
    # ------------------------------------------------------------------------
    map $http_x_request_id $request_id {
        default $http_x_request_id;
        '' $request_uuid;
    }
    
    # Generate unique ID if not provided
    set $request_uuid $request_id;
    if ($request_uuid = "") {
        set $request_uuid $request_id;
    }
    
    # ------------------------------------------------------------------------
    # Upstream Groups
    # ------------------------------------------------------------------------
    # Frontend - Next.js
    upstream frontend_backend {
        server nextjs:3000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # API - FastAPI (Blue/Green)
    upstream api_blue {
        server fastapi-blue:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream api_green {
        server fastapi-green:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Map for blue-green switching
    map $cookie_upstream $active_api {
        default "blue";
        "green" "green";
        "blue" "blue";
    }
    
    # Authentication API
    upstream auth_backend {
        server auth-api:8001 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # WebSocket server
    upstream websocket_backend {
        server websocket:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # SSE server
    upstream sse_backend {
        server sse:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Webhook server
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
        
        # --------------------------------------------------------------------
        # SSL Configuration
        # --------------------------------------------------------------------
        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;
        
        # Modern TLS settings
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;
        
        # Session caching
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        ssl_session_tickets off;
        
        # OCSP stapling
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 8.8.8.8 valid=300s;
        resolver_timeout 5s;
        
        # --------------------------------------------------------------------
        # Request Validation
        # --------------------------------------------------------------------
        # Apply global rate limiting
        limit_req zone=global_limit burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # Block suspicious user agents
        if ($http_user_agent ~* "(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan|joomscan)") {
            return 403;
        }
        
        # Block path traversal attempts
        if ($request_uri ~* "\.\./") {
            return 403;
        }
        
        # --------------------------------------------------------------------
        # Location: Static Assets
        # --------------------------------------------------------------------
        location /static/ {
            # Static caching (30 days)
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            # Serve from cache
            proxy_cache static_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            # Compression for static assets
            gzip_static on;
            gzip_proxied any;
            
            root /usr/share/nginx/html;
        }
        
        # --------------------------------------------------------------------
        # Location: Health Check
        # --------------------------------------------------------------------
        location /health {
            # Public health check with limited rate
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
            
            # Timeouts
            proxy_connect_timeout 30s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
        
        # --------------------------------------------------------------------
        # Location: API (FastAPI with Blue-Green)
        # --------------------------------------------------------------------
        location /api/ {
            # API rate limiting
            limit_req zone=api_limit burst=10 nodelay;
            
            # Request validation
            if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
                return 405;
            }
            
            if ($query_string ~* "(union|select|insert|update|delete|drop|exec|eval|ALTER|CREATE|TABLE|javascript:|alert)") {
                return 403;
            }
            
            # Choose upstream based on cookie
            set $upstream_name $active_api;
            
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
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Upstream $upstream_name;
            proxy_set_header X-Content-Type-Options "nosniff";
            
            # API caching (public endpoints only)
            # Cache based on request path to avoid caching private endpoints
            if ($request_uri ~* "/public/") {
                proxy_cache api_cache;
                proxy_cache_key $scheme$host$request_uri;
                proxy_cache_valid 200 302 5m;
                proxy_cache_use_stale error timeout updating;
                proxy_cache_lock on;
                proxy_cache_lock_timeout 5s;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            # Connection settings
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
        }
        
        # --------------------------------------------------------------------
        # Location: Authentication
        # --------------------------------------------------------------------
        location /auth/ {
            # Strict rate limiting for auth
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
            
            # Auth timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # --------------------------------------------------------------------
        # Location: WebSocket
        # --------------------------------------------------------------------
        location /ws/ {
            limit_req zone=ws_limit burst=5 nodelay;
            
            proxy_pass http://websocket_backend/;
            
            # WebSocket upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Disable buffering
            proxy_buffering off;
            
            # WebSocket timeouts
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 300s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502;
            proxy_next_upstream_tries 2;
        }
        
        # --------------------------------------------------------------------
        # Location: Server-Sent Events (SSE)
        # --------------------------------------------------------------------
        location /sse/ {
            # SSE doesn't use upgrade but needs persistent connection
            proxy_pass http://sse_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Critical: Disable buffering for SSE
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_set_header X-Accel-Buffering no;
            
            # Cache control
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            
            # SSE timeouts (longer than normal)
            proxy_read_timeout 600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 600s;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Location: Webhooks
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
            
            # Webhook-specific settings
            client_max_body_size 10M;
            client_body_buffer_size 128k;
            
            # Buffer for large webhook payloads
            proxy_buffering on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            
            # Webhook timeouts (longer for processing)
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 300s;
            
            # Retry configuration
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
            # IP-based access control
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;
            
            # Strict rate limiting
            limit_req zone=admin_limit burst=2 nodelay;
            
            # Route to API backend
            proxy_pass http://api_blue/admin/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Authorization $http_authorization;
            
            # Admin-specific headers
            add_header X-Robots-Tag "noindex, nofollow" always;
            add_header Cache-Control "no-store, no-cache, must-revalidate" always;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Admin timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # --------------------------------------------------------------------
        # Location: Debug (Internal Only)
        # --------------------------------------------------------------------
        location /debug/ {
            # Only internal access
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
        # Location: Blue-Green Switch (Internal Only)
        # --------------------------------------------------------------------
        location /admin/switch {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            # Set cookie to switch upstream
            add_header Set-Cookie "upstream=$arg_to; Path=/; Max-Age=3600";
            add_header X-Upstream-Switched $arg_to;
            
            return 200 "Switched to $arg_to upstream\n";
        }
        
        # --------------------------------------------------------------------
        # Location: Upstream Status (Internal Only)
        # --------------------------------------------------------------------
        location /admin/upstream-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 "Current upstream: $active_api\n";
        }
        
        # --------------------------------------------------------------------
        # Location: Configuration Test (Internal Only)
        # --------------------------------------------------------------------
        location /admin/config {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 "Configuration loaded at: $time_iso8601\n";
        }
    }
    
    # =========================================================================
    # HTTP Redirect Server
    # =========================================================================
    server {
        listen 80;
        server_name localhost;
        
        # Add HSTS for visitors who come via HTTP
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        
        # Redirect all HTTP traffic to HTTPS
        return 301 https://$host$request_uri;
    }
}
```

### Step 3: Complete Docker Compose

**File: `docker-compose.yml`**

```yaml
version: '3.8'

services:
  # --------------------------------------------------------------------------
  # Next.js Frontend
  # --------------------------------------------------------------------------
  nextjs:
    build:
      context: ./nextjs-app
      dockerfile: Dockerfile
    container_name: nextjs-app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=https://localhost/api
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # --------------------------------------------------------------------------
  # FastAPI Blue (Version 1.0.0)
  # --------------------------------------------------------------------------
  fastapi-blue:
    build:
      context: ./fastapi-blue
      dockerfile: Dockerfile
    container_name: fastapi-blue
    ports:
      - "8000:8000"
    environment:
      - HOSTNAME=blue-instance
      - VERSION=1.0.0
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # --------------------------------------------------------------------------
  # FastAPI Green (Version 2.0.0)
  # --------------------------------------------------------------------------
  fastapi-green:
    build:
      context: ./fastapi-green
      dockerfile: Dockerfile
    container_name: fastapi-green
    ports:
      - "8001:8000"
    environment:
      - HOSTNAME=green-instance
      - VERSION=2.0.0
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # --------------------------------------------------------------------------
  # Authentication API
  # --------------------------------------------------------------------------
  auth-api:
    build:
      context: ./auth-api
      dockerfile: Dockerfile
    container_name: auth-api
    ports:
      - "8002:8001"
    environment:
      - SECRET_KEY=your-secret-key-change-in-production
      - HOSTNAME=auth-instance
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # --------------------------------------------------------------------------
  # WebSocket Server
  # --------------------------------------------------------------------------
  websocket:
    build:
      context: ./websocket-app
      dockerfile: Dockerfile
    container_name: websocket-app
    ports:
      - "8003:8002"
    environment:
      - HOSTNAME=websocket-instance
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8002/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # --------------------------------------------------------------------------
  # SSE Server
  # --------------------------------------------------------------------------
  sse:
    build:
      context: ./sse-app
      dockerfile: Dockerfile
    container_name: sse-app
    ports:
      - "8004:8003"
    environment:
      - HOSTNAME=sse-instance
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8003/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # --------------------------------------------------------------------------
  # Webhook Receiver
  # --------------------------------------------------------------------------
  webhook:
    build:
      context: ./webhook-app
      dockerfile: Dockerfile
    container_name: webhook-app
    ports:
      - "8005:8004"
    environment:
      - HOSTNAME=webhook-instance
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8004/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # --------------------------------------------------------------------------
  # Nginx Gateway
  # --------------------------------------------------------------------------
  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
      - ./cache:/var/cache/nginx
    depends_on:
      - nextjs
      - fastapi-blue
      - fastapi-green
      - auth-api
      - websocket
      - sse
      - webhook
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### Step 4: Deployment Script

**File: `deploy.sh`**

```bash
#!/bin/bash
# deploy.sh - Production deployment script

set -e

echo "=== Nginx Gateway Deployment ==="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Step 1: Build
echo -e "${BLUE}Step 1: Building services${NC}"
docker compose build

# Step 2: Test configuration
echo -e "${BLUE}Step 2: Testing configuration${NC}"
docker compose run --rm nginx nginx -t

# Step 3: Start services
echo -e "${BLUE}Step 3: Starting services${NC}"
docker compose up -d

# Step 4: Wait for health
echo -e "${BLUE}Step 4: Waiting for services to become healthy${NC}"
sleep 10

# Step 5: Verify deployment
echo -e "${BLUE}Step 5: Verifying deployment${NC}"
for i in {1..5}; do
    status=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/health)
    if [ "$status" -eq 200 ]; then
        echo -e "${GREEN}✓ Gateway healthy${NC}"
        break
    fi
    if [ $i -eq 5 ]; then
        echo -e "${RED}✗ Gateway not healthy after 5 attempts${NC}"
        exit 1
    fi
    sleep 2
done

# Step 6: Run security tests
echo -e "${BLUE}Step 6: Running security tests${NC}"
./security-tests/test-security.sh

# Step 7: Show status
echo -e "${BLUE}Step 7: Deployment status${NC}"
docker compose ps

echo -e "${GREEN}=== Deployment Complete! ===${NC}"
echo "Gateway available at: https://localhost"
echo "API available at: https://localhost/api/"
echo "WebSocket available at: wss://localhost/ws/"
echo "SSE available at: https://localhost/sse/"
echo "Webhooks available at: https://localhost/webhook/"
```

### Step 5: Monitoring Script

**File: `monitor.sh`**

```bash
#!/bin/bash
# monitor.sh - Production monitoring script

echo "=== Nginx Gateway Monitoring ==="
echo ""

# Check 1: Uptime
echo "1. Uptime:"
docker ps --format "table {{.Names}}\t{{.Status}}" | head -10
echo ""

# Check 2: Request rates
echo "2. Request Rates (last minute):"
REQUESTS=$(tail -60 logs/access.log 2>/dev/null | wc -l)
echo "  $REQUESTS requests/min"
echo ""

# Check 3: Error rates
echo "3. Error Rates (last minute):"
ERRORS=$(tail -60 logs/access.log 2>/dev/null | grep -E '"status":5[0-9]{2}' | wc -l)
echo "  $ERRORS errors/min"
if [ $ERRORS -gt 10 ]; then
    echo -e "  ${RED}⚠ High error rate!${NC}"
fi
echo ""

# Check 4: Response times
echo "4. Average Response Time (last 100 requests):"
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
    print(f\"{statistics.mean(times):.3f}s\")
else:
    print(\"No data\")
")
echo "  $AVG_TIME"
echo ""

# Check 5: Cache hit rate
echo "5. Cache Hit Rate:"
TOTAL=$(tail -100 logs/access.log 2>/dev/null | wc -l)
HITS=$(tail -100 logs/access.log 2>/dev/null | grep -E '"upstream_cache_status":"HIT"' | wc -l)
if [ $TOTAL -gt 0 ]; then
    RATE=$(echo "scale=2; $HITS * 100 / $TOTAL" | bc)
    echo "  $RATE% ($HITS of $TOTAL requests)"
else
    echo "  No data"
fi
echo ""

# Check 6: Active connections
echo "6. Active Connections:"
CONNS=$(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep ESTABLISHED | wc -l)
echo "  $CONNS active connections"
echo ""

# Check 7: Memory usage
echo "7. Memory Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.MemPerc}}" | head -10
echo ""

# Check 8: Disk usage
echo "8. Disk Usage:"
echo "  Logs: $(du -sh logs/ 2>/dev/null | cut -f1)"
echo "  Cache: $(du -sh cache/ 2>/dev/null | cut -f1)"
echo ""

# Check 9: Upstream health
echo "9. Upstream Health:"
for service in fastapi-blue fastapi-green auth-api websocket sse webhook; do
    if docker ps | grep -q $service; then
        echo "  ✓ $service running"
    else
        echo "  ✗ $service not running"
    fi
done
```

### Step 6: Validation Script

**File: `validate.sh`**

```bash
#!/bin/bash
# validate.sh - Complete validation suite

echo "=== Nginx Gateway Validation ==="
echo ""

# Test 1: HTTPS works
echo -n "Testing HTTPS... "
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost/ | grep -q 200; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 2: HTTP redirects to HTTPS
echo -n "Testing HTTP redirect... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q 301; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 3: API works
echo -n "Testing API... "
if curl -k -s https://localhost/api/ | grep -q "instance"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 4: WebSocket works
echo -n "Testing WebSocket... "
if curl -k -s -H "Connection: Upgrade" -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
    -H "Sec-WebSocket-Version: 13" \
    https://localhost/ws/ 2>&1 | grep -q "101"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 5: SSE works
echo -n "Testing SSE... "
if curl -k -s -N https://localhost/sse/stream 2>&1 | head -5 | grep -q "data:"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 6: Rate limiting works
echo -n "Testing Rate Limiting... "
RATE_LIMIT_RESULT=$(for i in {1..10}; do
    curl -k -s -o /dev/null -w "%{http_code}\n" https://localhost/auth/login 2>/dev/null
done | grep -c "429")
if [ $RATE_LIMIT_RESULT -gt 0 ]; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test 7: Security headers present
echo -n "Testing Security Headers... "
HEADERS=$(curl -k -s -I https://localhost/ | grep -E "Strict-Transport-Security|X-Content-Type-Options|X-Frame-Options|Content-Security-Policy" | wc -l)
if [ $HEADERS -ge 4 ]; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

echo ""
echo "=== All tests passed! Gateway is production-ready! ==="
```

### Step 7: The Complete Documentation

**File: `README.md`**

```markdown
# Nginx Production Gateway

## Overview

A production-ready Nginx gateway serving multiple services with:
- HTTPS/TLS termination
- Path-based routing
- Blue-green deployments
- Rate limiting
- Caching
- WebSocket/SSE support
- Structured logging
- Security hardening

## Architecture

```
Internet → Nginx (443) → [Next.js, FastAPI, Auth, WebSocket, SSE, Webhook]
```

## Quick Start

```bash
# Start the gateway
./deploy.sh

# Monitor the gateway
./monitor.sh

# Validate the gateway
./validate.sh

# Run security tests
./security-tests/test-security.sh
```

## Services

| Service | Port | Path | Description |
|---------|------|------|-------------|
| Next.js | 3000 | / | Frontend application |
| FastAPI Blue | 8000 | /api/ | API v1 |
| FastAPI Green | 8001 | /api/ | API v2 (blue-green) |
| Auth API | 8002 | /auth/ | Authentication |
| WebSocket | 8003 | /ws/ | WebSocket server |
| SSE | 8004 | /sse/ | Server-Sent Events |
| Webhook | 8005 | /webhook/ | Webhook receiver |

## Blue-Green Deployment

Switch between API versions:

```bash
# Switch to green
curl -X POST "https://localhost/admin/switch?to=green"

# Switch to blue
curl -X POST "https://localhost/admin/switch?to=blue"

# Check current
curl https://localhost/admin/upstream-status
```

## Configuration Files

- `nginx.conf` - Main Nginx configuration
- `docker-compose.yml` - Service definitions
- `deploy.sh` - Deployment script
- `monitor.sh` - Monitoring script
- `validate.sh` - Validation script

## Monitoring

```bash
# View logs
tail -f logs/access.log | jq '.'

# Check status
curl https://localhost/nginx-status

# Check health
curl https://localhost/health

# Check upstream
curl https://localhost/admin/upstream-status
```

## Troubleshooting

1. **Gateway not responding:**
   ```bash
   docker compose logs nginx
   ```

2. **Service not healthy:**
   ```bash
   docker compose ps
   ```

3. **Configuration error:**
   ```bash
   docker compose run --rm nginx nginx -t
   ```

4. **Certificate issue:**
   ```bash
   openssl s_client -connect localhost:443
   ```

## Security

- TLS 1.2/1.3 only
- Strong ciphers
- HSTS enabled
- CSP headers
- Rate limiting
- IP-based access control
- Request validation

## Performance

- Gzip compression
- Caching (API, micro, static)
- Keepalive connections
- Load balancing
- Connection pooling

## License

MIT
```

### Step 8: Final Verification

Now let's run the complete validation:

```bash
# Make deploy script executable
chmod +x deploy.sh monitor.sh validate.sh security-tests/test-security.sh

# Deploy everything
./deploy.sh

# Validate everything works
./validate.sh

# Run monitoring
./monitor.sh

# Run security tests
./security-tests/test-security.sh
```

## Congratulations! 🎉

You've now built a complete production-ready Nginx gateway. Let's reflect on what you've accomplished:

### The Complete Journey

You started with nothing and built:

| Part | Skill | Level |
|------|-------|-------|
| 1 | Reverse proxy fundamentals | ✅ |
| 2 | Path-based routing | ✅ |
| 3 | SSL/TLS termination | ✅ |
| 4 | Authentication & rate limiting | ✅ |
| 5 | WebSockets, SSE & webhooks | ✅ |
| 6 | Caching & compression | ✅ |
| 7 | Load balancing & zero-downtime | ✅ |
| 8 | Observability & debugging | ✅ |
| 9 | Security hardening | ✅ |
| 10 | Production gateway | ✅ |

### The Core Outcome

Remember what we set out to achieve:

> **"Given any production HTTP failure, understand where Nginx fits in the request path, identify what went wrong, and make the smallest correct configuration change."**

You can now:

- ✅ **Diagnose** failures by inspecting logs and observability tools
- ✅ **Understand** how every directive affects the system
- ✅ **Configure** Nginx from scratch for any scenario
- ✅ **Secure** your applications with best practices
- ✅ **Optimize** performance with caching and compression
- ✅ **Deploy** with zero downtime
- ✅ **Monitor** in production
- ✅ **Troubleshoot** complex issues

### What's Next

You've built the foundation. Now you can:

1. **Adapt** this configuration to your own applications
2. **Extend** with additional services
3. **Optimize** for your specific use case
4. **Automate** the deployment pipeline
5. **Scale** to handle more traffic
6. **Monitor** and improve over time

### Final Thought

`nginx.conf` is no longer magic. It's **executable architecture**—a blueprint that defines how your entire application stack works, secure and observable, ready for production.

You built this.

Now go build something amazing. 🚀

---

**Series Summary:**

- **Parts:** 0-10
- **Topics:** 11 modules
- **Configuration files:** 15+
- **Scripts:** 10+
- **Services:** 7
- **Lines of code:** 1000+
- **Skills gained:** 50+
- **Time invested:** 12+ hours

You are now a **Nginx Production Architect**.

Well done! 🎉
