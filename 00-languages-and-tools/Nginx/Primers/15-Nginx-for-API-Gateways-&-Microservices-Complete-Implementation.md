# Primer 15: Nginx for API Gateways & Microservices - Complete Implementation

## The Target

This primer provides the definitive, comprehensive guide to implementing an enterprise-grade API Gateway using Nginx. This is a complete, production-ready implementation that covers all aspects of API gateway functionality.

## P15.1 Complete API Gateway Architecture

### Enterprise API Gateway Design

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ENTERPRISE API GATEWAY ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    API GATEWAY (Nginx)                            │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SECURITY LAYER                          │ │      │
│  │  │  • TLS Termination    • Rate Limiting    • Authentication │ │      │
│  │  │  • JWT Validation     • API Keys         • CORS           │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ROUTING LAYER                           │ │      │
│  │  │  • Path Routing      • Versioning       • Blue-Green      │ │      │
│  │  │  • Load Balancing    • Circuit Breaker  • Canary          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PERFORMANCE LAYER                       │ │      │
│  │  │  • Caching          • Compression     • Connection Pool  │ │      │
│  │  │  • Buffering        • Timeouts        • Keepalive        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    OBSERVABILITY LAYER                     │ │      │
│  │  │  • Logging          • Metrics          • Tracing          │ │      │
│  │  │  • Monitoring       • Alerting         • Auditing         │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Auth   │  │ Users  │  │ Orders │  │Products│  │Payment │           │
│  │Service │  │Service │  │Service │  │Service │  │Service │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Gateway Configuration

```nginx
# nginx.conf - Enterprise API Gateway
# ============================================================================
# NGINX ENTERPRISE API GATEWAY
# Complete production-ready configuration
# ============================================================================

# ============================================================================
# GLOBAL SETTINGS
# ============================================================================
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
worker_priority -20;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# ============================================================================
# EVENTS
# ============================================================================
events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
    accept_mutex off;
}

# ============================================================================
# HTTP BLOCK
# ============================================================================
http {
    # ------------------------------------------------------------------------
    # BASIC SETTINGS
    # ------------------------------------------------------------------------
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server_tokens off;
    charset utf-8;

    # ------------------------------------------------------------------------
    # PERFORMANCE SETTINGS
    # ------------------------------------------------------------------------
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10M;

    # ------------------------------------------------------------------------
    # LOGGING
    # ------------------------------------------------------------------------
    log_format json escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"request_id":"$request_id",'
        '"remote_addr":"$remote_addr",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_status":$upstream_status,'
        '"upstream_response_time":$upstream_response_time,'
        '"api_key":"$http_x_api_key",'
        '"user_id":"$auth_user_id",'
        '"http_referer":"$http_referer",'
        '"http_user_agent":"$http_user_agent"'
    '}';
    
    access_log /var/log/nginx/gateway.log json;
    error_log /var/log/nginx/error.log warn;

    # ------------------------------------------------------------------------
    # REQUEST ID GENERATION
    # ------------------------------------------------------------------------
    map $http_x_request_id $request_id {
        default $http_x_request_id;
        '' $request_uuid;
    }
    
    set $request_uuid $request_id;
    if ($request_uuid = "") {
        set $request_uuid $request_id;
    }

    # =========================================================================
    # SECURITY HEADERS
    # =========================================================================
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=()" always;

    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    # Global limits
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

    # Endpoint-specific limits
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=admin:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=webhook:10m rate=30r/m;

    # Tier-based limits
    limit_req_zone $binary_remote_addr zone=free:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=basic:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=premium:10m rate=1000r/m;

    # =========================================================================
    # CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2
        keys_zone=api_cache:100m
        max_size=2g
        inactive=1h
        use_temp_path=off;

    proxy_cache_path /var/cache/nginx/micro_cache
        levels=1:2
        keys_zone=micro_cache:50m
        max_size=500m
        inactive=5s
        use_temp_path=off;

    proxy_cache_path /var/cache/nginx/static_cache
        levels=1:2
        keys_zone=static_cache:50m
        max_size=500m
        inactive=30d
        use_temp_path=off;

    # =========================================================================
    # COMPRESSION
    # =========================================================================
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_disable "msie6";
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

    # =========================================================================
    # TIER MAPPING
    # =========================================================================
    map $http_x_api_key $api_tier {
        default "free";
        ~^free_ "free";
        ~^basic_ "basic";
        ~^premium_ "premium";
    }

    # =========================================================================
    # UPSTREAM SERVICES
    # =========================================================================
    upstream auth_service {
        server auth:8001 max_fails=3 fail_timeout=30s;
        server auth-backup:8001 backup;
        keepalive 32;
    }

    upstream users_service {
        zone users 64k;
        server users:8002 max_fails=3 fail_timeout=30s;
        server users-backup:8002 backup;
        keepalive 32;
    }

    upstream orders_service {
        server orders:8003 max_fails=3 fail_timeout=30s;
        server orders-backup:8003 backup;
        keepalive 32;
    }

    upstream products_service {
        server products:8004 max_fails=3 fail_timeout=30s;
        server products-backup:8004 backup;
        keepalive 32;
    }

    upstream payments_service {
        server payments:8005 max_fails=3 fail_timeout=30s;
        server payments-backup:8005 backup;
        keepalive 32;
    }

    upstream webhook_service {
        server webhook:8006 max_fails=3 fail_timeout=30s;
        server webhook-backup:8006 backup;
        keepalive 32;
    }

    # =========================================================================
    # MAIN GATEWAY SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name api.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/api.crt;
        ssl_certificate_key /etc/nginx/ssl/api.key;
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

        # --------------------------------------------------------------------
        # REQUEST VALIDATION
        # --------------------------------------------------------------------
        limit_req zone=global burst=20 nodelay;
        limit_conn conn_limit 10;

        # Block suspicious agents
        if ($http_user_agent ~* "(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan)") {
            return 403;
        }

        # Block path traversal
        if ($request_uri ~* "\.\./") {
            return 403;
        }

        # Block SQL injection
        if ($query_string ~* "(union|select|insert|update|delete|drop|exec|eval|ALTER|CREATE|TABLE)") {
            return 403;
        }

        # Block XSS
        if ($query_string ~* "(<|>|%3C|%3E|javascript:|alert|onerror|onload)") {
            return 403;
        }

        # Validate API key
        if ($http_x_api_key = "") {
            return 401 '{"error":"API key required"}';
            add_header Content-Type application/json;
        }

        # --------------------------------------------------------------------
        # CORS CONFIGURATION
        # --------------------------------------------------------------------
        location / {
            # CORS headers
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-API-Key" always;
            add_header Access-Control-Expose-Headers "X-Request-ID, X-RateLimit-Limit, X-RateLimit-Remaining" always;

            # Preflight
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin "*" always;
                add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
                add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-API-Key" always;
                add_header Access-Control-Max-Age 86400;
                add_header Content-Length 0;
                return 204;
            }
        }

        # --------------------------------------------------------------------
        # ROUTE: AUTHENTICATION
        # --------------------------------------------------------------------
        location /auth/ {
            # Strict rate limiting
            limit_req zone=auth burst=2 nodelay;
            limit_conn conn_limit 1;

            proxy_pass http://auth_service/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;

            proxy_http_version 1.1;
            proxy_set_header Connection "";

            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }

        # --------------------------------------------------------------------
        # ROUTE: USERS
        # --------------------------------------------------------------------
        location /users/ {
            # Authentication check
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;

            # API tier rate limiting
            if ($api_tier = "free") {
                limit_req zone=free burst=5 nodelay;
            }
            if ($api_tier = "basic") {
                limit_req zone=basic burst=20 nodelay;
            }
            if ($api_tier = "premium") {
                limit_req zone=premium burst=50 nodelay;
            }

            proxy_pass http://users_service/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;

            proxy_http_version 1.1;
            proxy_set_header Connection "";

            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;

            # Rate limit headers
            add_header X-RateLimit-Limit $limit_req_zone_rate;
            add_header X-RateLimit-Remaining $limit_req_remaining;
            add_header X-RateLimit-Reset $limit_req_reset;
        }

        # --------------------------------------------------------------------
        # ROUTE: ORDERS
        # --------------------------------------------------------------------
        location /orders/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;

            # Order-specific rate limiting
            limit_req zone=api burst=20 nodelay;

            # Cache for GET requests
            if ($request_method = GET) {
                proxy_cache api_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                proxy_cache_valid 404 1m;
                proxy_cache_use_stale error timeout updating;
                proxy_cache_lock on;
                add_header X-Cache-Status $upstream_cache_status;
            }

            proxy_pass http://orders_service/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;

            proxy_http_version 1.1;
            proxy_set_header Connection "";

            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }

        # --------------------------------------------------------------------
        # ROUTE: PRODUCTS (PUBLIC)
        # --------------------------------------------------------------------
        location /products/ {
            # High rate limit for products
            limit_req zone=api burst=30 nodelay;

            # Aggressive caching
            proxy_cache api_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 10m;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            add_header X-Cache-Status $upstream_cache_status;

            proxy_pass http://products_service/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;

            proxy_http_version 1.1;
            proxy_set_header Connection "";

            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;

            # Compression for product data
            gzip on;
            gzip_comp_level 6;
            gzip_types application/json;
        }

        # --------------------------------------------------------------------
        # ROUTE: PAYMENTS (SECURE)
        # --------------------------------------------------------------------
        location /payments/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;

            # Very strict rate limiting
            limit_req zone=api burst=5 nodelay;
            limit_conn conn_limit 2;

            # No caching for payments
            proxy_no_cache 1;
            proxy_cache_bypass 1;

            proxy_pass http://payments_service/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;

            proxy_http_version 1.1;
            proxy_set_header Connection "";

            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;

            # Security headers for payments
            add_header Cache-Control "no-store, no-cache, must-revalidate" always;
            add_header Pragma "no-cache" always;
        }

        # --------------------------------------------------------------------
        # ROUTE: WEBHOOKS
        # --------------------------------------------------------------------
        location /webhooks/ {
            # Webhook rate limiting
            limit_req zone=webhook burst=10 nodelay;

            # Large body for webhooks
            client_max_body_size 10M;
            client_body_buffer_size 128k;

            proxy_pass http://webhook_service/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;

            # Buffer for large payloads
            proxy_buffering on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;

            proxy_http_version 1.1;
            proxy_set_header Connection "";

            # Long timeouts for webhook processing
            proxy_connect_timeout 10s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;

            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
        }

        # --------------------------------------------------------------------
        # ROUTE: ADMIN (INTERNAL)
        # --------------------------------------------------------------------
        location /admin/ {
            # IP-based access control
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;

            # Strict rate limiting
            limit_req zone=admin burst=2 nodelay;
            limit_conn conn_limit 1;

            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;

            proxy_pass http://users_service/admin/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;

            proxy_http_version 1.1;
            proxy_set_header Connection "";

            # Admin-specific headers
            add_header X-Robots-Tag "noindex, nofollow" always;
            add_header Cache-Control "no-store, no-cache, must-revalidate" always;
        }

        # --------------------------------------------------------------------
        # ROUTE: AUTH VALIDATION (INTERNAL)
        # --------------------------------------------------------------------
        location = /auth/validate {
            internal;

            proxy_pass http://auth_service/validate;
            proxy_pass_request_body off;

            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header X-API-Key $http_x_api_key;

            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_email $upstream_http_x_user_email;

            proxy_intercept_errors on;
            error_page 401 = /auth/error;
        }

        # --------------------------------------------------------------------
        # ROUTE: AUTH ERROR
        # --------------------------------------------------------------------
        location = /auth/error {
            return 401 '{"error":"Authentication required"}';
            add_header Content-Type application/json;
        }

        # --------------------------------------------------------------------
        # ROUTE: HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-Content-Type-Options "nosniff";

            # Check all upstream services
            set $health_checks "";
            set $health_status "healthy";

            # Check each service
            proxy_pass http://auth_service/health;
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;

            # Check all services
            include /etc/nginx/health-checks.conf;
        }

        # --------------------------------------------------------------------
        # ROUTE: NGINX STATUS
        # --------------------------------------------------------------------
        location /nginx-status {
            allow 127.0.0.1;
            deny all;
            stub_status on;
            access_log off;
        }

        # --------------------------------------------------------------------
        # ROUTE: METRICS (PROMETHEUS)
        # --------------------------------------------------------------------
        location /metrics {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            stub_status on;
            access_log off;
        }

        # --------------------------------------------------------------------
        # ROUTE: CATCH-ALL
        # --------------------------------------------------------------------
        location / {
            return 404 '{"error":"Not Found"}';
            add_header Content-Type application/json;
        }
    }

    # =========================================================================
    # HTTP REDIRECT
    # =========================================================================
    server {
        listen 80;
        listen [::]:80;
        server_name api.example.com;

        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

        return 301 https://$host$request_uri;
    }
}
```

## P15.2 Health Checks Configuration

```nginx
# health-checks.conf - Service health checks
location /health {
    # Initialize health status
    set $health_status "healthy";

    # Check Auth Service
    location /health/auth {
        internal;
        proxy_pass http://auth_service/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
        
        if ($upstream_status != 200) {
            set $health_status "degraded";
        }
    }

    # Check Users Service
    location /health/users {
        internal;
        proxy_pass http://users_service/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
        
        if ($upstream_status != 200) {
            set $health_status "degraded";
        }
    }

    # Check Orders Service
    location /health/orders {
        internal;
        proxy_pass http://orders_service/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
        
        if ($upstream_status != 200) {
            set $health_status "degraded";
        }
    }

    # Check Products Service
    location /health/products {
        internal;
        proxy_pass http://products_service/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
        
        if ($upstream_status != 200) {
            set $health_status "degraded";
        }
    }

    # Check Payments Service
    location /health/payments {
        internal;
        proxy_pass http://payments_service/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
        
        if ($upstream_status != 200) {
            set $health_status "degraded";
        }
    }

    # Check Webhook Service
    location /health/webhook {
        internal;
        proxy_pass http://webhook_service/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
        
        if ($upstream_status != 200) {
            set $health_status "degraded";
        }
    }

    # Aggregate health checks
    location /health/status {
        internal;
        return 200 '{"status":"$health_status"}';
        add_header Content-Type application/json;
    }

    return 200 '{"status":"$health_status","timestamp":"$time_iso8601"}';
    add_header Content-Type application/json;
    access_log off;
}
```

---

This primer provides the definitive, complete implementation of an enterprise-grade API Gateway using Nginx. Use this as your production baseline for building secure, scalable, and observable API gateways.
