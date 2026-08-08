# Primer 29: Nginx for Mobile Backend as a Service (MBaaS)

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx as a Mobile Backend as a Service (MBaaS) gateway. Understanding these concepts is essential for building scalable, secure, and feature-rich mobile backends.

## P29.1 MBaaS Architecture

### Complete MBaaS Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MBaaS ARCHITECTURE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX MBaaS GATEWAY                            │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    USER MANAGEMENT                        │ │      │
│  │  │  • Authentication    • Authorization    • User Profiles   │ │      │
│  │  │  • Social Login      • Password Reset    • Email         │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DATA MANAGEMENT                        │ │      │
│  │  │  • CRUD Operations  • Real-time Sync    • Offline          │ │      │
│  │  │  • Push Notifications • File Storage    • Analytics       │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    MOBILE OPTIMIZATION                    │ │      │
│  │  │  • Network Optimization • Data Compression                │ │      │
│  │  │  • Offline Support     • Bandwidth Management             │ │      │
│  │  │  • Cache Strategies    • Connection Management            │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Auth   │  │ User   │  │ Data   │  │ Files  │  │ Push   │           │
│  │ Service│  │ Service│  │ Service│  │ Service│  │ Service│           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete MBaaS Configuration

```nginx
# nginx-mbaas.conf - Complete MBaaS Gateway
# ============================================================================
# NGINX MOBILE BACKEND AS A SERVICE
# Complete production-ready MBaaS configuration
# ============================================================================

http {
    # =========================================================================
    # MOBILE OPTIMIZATION SETTINGS
    # =========================================================================
    # Small payloads for mobile
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    client_max_body_size 10M;
    
    # Connection management for mobile
    keepalive_timeout 30;
    keepalive_requests 100;
    
    # Mobile timeouts
    client_body_timeout 15s;
    client_header_timeout 15s;
    send_timeout 15s;
    
    # =========================================================================
    # MOBILE CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/mobile_cache
        levels=1:2
        keys_zone=mobile_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    proxy_cache_path /var/cache/nginx/offline_cache
        levels=1:2
        keys_zone=offline_cache:100m
        max_size=1g
        inactive=30d
        use_temp_path=off;
    
    # =========================================================================
    # MBaaS UPSTREAMS
    # =========================================================================
    upstream auth_service {
        server auth:8001 max_fails=3 fail_timeout=30s;
        server auth-backup:8001 backup;
        keepalive 32;
    }
    
    upstream user_service {
        server users:8002 max_fails=3 fail_timeout=30s;
        server users-backup:8002 backup;
        keepalive 32;
    }
    
    upstream data_service {
        server data:8003 max_fails=3 fail_timeout=30s;
        server data-backup:8003 backup;
        keepalive 32;
    }
    
    upstream file_service {
        server files:8004 max_fails=3 fail_timeout=30s;
        server files-backup:8004 backup;
        keepalive 32;
    }
    
    upstream push_service {
        server push:8005 max_fails=3 fail_timeout=30s;
        server push-backup:8005 backup;
        keepalive 32;
    }
    
    upstream analytics_service {
        server analytics:8006 max_fails=3 fail_timeout=30s;
        keepalive 16;
    }
    
    # =========================================================================
    # MBaaS SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name mbaas.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/mbaas.crt;
        ssl_certificate_key /etc/nginx/ssl/mbaas.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # CORS for mobile
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-Client-ID, X-Client-Version" always;
        add_header Access-Control-Expose-Headers "X-Request-ID, X-MBaaS-Status, X-Cache-Status" always;
        
        # Mobile headers
        add_header X-MBaaS-Version "2.0.0" always;
        add_header X-MBaaS-Response-Time $request_time always;
        
        # Preflight
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-Client-ID, X-Client-Version" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Length 0;
            return 204;
        }
        
        # =========================================================================
        # MOBILE AUTHENTICATION
        # =========================================================================
        location /auth/ {
            # Rate limiting for auth
            limit_req zone=auth burst=2 nodelay;
            limit_conn conn 2;
            
            proxy_pass http://auth_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Client-ID $http_x_client_id;
            proxy_set_header X-Client-Version $http_x_client_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # USER MANAGEMENT
        # =========================================================================
        location /users/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Device-specific rate limiting
            limit_req zone=users burst=10 nodelay;
            
            # Cache user profiles
            if ($request_method = GET) {
                proxy_cache mobile_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://user_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Client-ID $http_x_client_id;
            proxy_set_header X-Client-Version $http_x_client_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # Mobile caching headers
            add_header Cache-Control "private, max-age=300";
        }
        
        # =========================================================================
        # DATA CRUD OPERATIONS
        # =========================================================================
        location /data/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Data rate limiting
            limit_req zone=api burst=20 nodelay;
            
            # Cache GET requests
            if ($request_method = GET) {
                proxy_cache mobile_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 1m;
                proxy_cache_use_stale error timeout updating;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://data_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Client-ID $http_x_client_id;
            proxy_set_header X-Client-Version $http_x_client_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # Data compression
            gzip on;
            gzip_comp_level 6;
            gzip_types application/json;
        }
        
        # =========================================================================
        # FILE STORAGE (MOBILE UPLOADS)
        # =========================================================================
        location /files/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # File upload limits
            client_max_body_size 50M;
            client_body_buffer_size 1M;
            
            # Rate limiting for uploads
            limit_req zone=api burst=5 nodelay;
            limit_conn conn 5;
            
            proxy_pass http://file_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Client-ID $http_x_client_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Buffer for file uploads
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            
            # Cache file metadata
            if ($request_method = GET) {
                proxy_cache mobile_cache;
                proxy_cache_key $scheme$host$request_uri;
                proxy_cache_valid 200 1h;
                add_header X-Cache-Status $upstream_cache_status;
            }
        }
        
        # =========================================================================
        # PUSH NOTIFICATIONS
        # =========================================================================
        location /push/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Push rate limiting
            limit_req zone=api burst=5 nodelay;
            
            proxy_pass http://push_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Client-ID $http_x_client_id;
            proxy_set_header X-Device-Token $http_x_device_token;
            proxy_set_header X-Platform $http_x_platform; # ios/android
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # OFFLINE SYNC
        # =========================================================================
        location /offline/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Offline data sync
            proxy_pass http://data_service/offline/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Client-ID $http_x_client_id;
            proxy_set_header X-Sync-Token $http_x_sync_token;
            proxy_set_header X-Sync-Timestamp $http_x_sync_timestamp;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Offline sync cache
            proxy_cache offline_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id$http_x_sync_token;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
            add_header X-Offline-Sync "true";
        }
        
        # =========================================================================
        # MOBILE ANALYTICS
        # =========================================================================
        location /analytics/ {
            # Analytics ingestion
            limit_req zone=event_ingest burst=50 nodelay;
            
            # Disable buffering
            proxy_buffering off;
            proxy_request_buffering off;
            
            proxy_pass http://analytics_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Client-ID $http_x_client_id;
            proxy_set_header X-Client-Version $http_x_client_version;
            proxy_set_header X-Device-ID $http_x_device_id;
            proxy_set_header X-OS-Version $http_x_os_version;
            proxy_set_header X-App-Version $http_x_app_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://auth_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header X-Client-ID $http_x_client_id;
            
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_role $upstream_http_x_user_role;
            
            proxy_intercept_errors on;
            error_page 401 = /auth-error;
        }
        
        # =========================================================================
        # AUTH ERROR
        # =========================================================================
        location = /auth-error {
            return 401 '{"error":"Authentication required"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # MBaaS STATUS
        # =========================================================================
        location /mbaas/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "version":"2.0.0",
                "services":{
                    "auth":"$upstream_addr",
                    "users":"$upstream_addr",
                    "data":"$upstream_addr",
                    "files":"$upstream_addr",
                    "push":"$upstream_addr",
                    "analytics":"$upstream_addr"
                },
                "mobile_stats":{
                    "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                    "requests":$(tail -10000 /var/log/nginx/access.log | wc -l),
                    "cache_hits":$(tail -10000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"')
                },
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P29.2 Mobile Performance Optimization

### Mobile-Specific Optimizations

```nginx
# nginx-mobile-optimization.conf - Mobile Optimizations
# ============================================================================
# NGINX MOBILE PERFORMANCE OPTIMIZATIONS
# Complete mobile optimization configuration
# ============================================================================

http {
    # =========================================================================
    # MOBILE CACHING STRATEGIES
    # =========================================================================
    
    # Edge caching for mobile
    proxy_cache_path /var/cache/nginx/mobile_edge
        levels=1:2
        keys_zone=mobile_edge:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # MOBILE COMPRESSION
    # =========================================================================
    # Aggressive compression for mobile
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 9;
    gzip_min_length 500;
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
        image/svg+xml;
    
    # Brotli for mobile (if available)
    # brotli on;
    # brotli_comp_level 11;
    # brotli_types text/plain text/css application/json application/javascript;
    
    # =========================================================================
    # MOBILE CONNECTION MANAGEMENT
    # =========================================================================
    # Optimize for mobile networks
    keepalive_timeout 30;
    keepalive_requests 50;
    
    # Mobile timeouts
    client_body_timeout 15s;
    client_header_timeout 15s;
    send_timeout 15s;
    
    # Connection pooling
    upstream mobile_backend {
        server backend:8000;
        keepalive 32;
        keepalive_requests 100;
        keepalive_timeout 30s;
    }
    
    # =========================================================================
    # MOBILE RESPONSE OPTIMIZATION
    # =========================================================================
    location /api/ {
        # Mobile device detection
        if ($http_user_agent ~* "(android|iphone|ipad|mobile)") {
            set $device_type "mobile";
        }
        
        # Mobile-specific caching
        proxy_cache mobile_edge;
        proxy_cache_key $scheme$host$request_uri$device_type;
        proxy_cache_valid 200 5m;
        
        # Mobile response headers
        add_header X-Device-Type $device_type;
        add_header X-Mobile-Optimized "true";
        
        proxy_pass http://backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Device-Type $device_type;
        
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
    
    # =========================================================================
    # MOBILE IMAGE OPTIMIZATION
    # =========================================================================
    location /images/ {
        # Image optimization for mobile
        set $image_quality "85";
        set $image_format "webp";
        
        if ($http_user_agent ~* "android|iphone") {
            set $image_format "webp";
        }
        
        # Serve optimized images
        try_files $uri @image_optimizer;
    }
    
    location @image_optimizer {
        proxy_pass http://image-optimizer/optimize;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Format $image_format;
        proxy_set_header X-Quality $image_quality;
        
        # Cache optimized images
        proxy_cache mobile_edge;
        proxy_cache_key $scheme$host$request_uri$image_format$image_quality;
        proxy_cache_valid 200 30d;
        
        add_header X-Image-Optimized "true";
        add_header X-Image-Format $image_format;
        add_header X-Image-Quality $image_quality;
    }
}
```

## P29.3 MBaaS Monitoring

### MBaaS Mobile Dashboard

```bash
#!/bin/bash
# mbaas-mobile-dashboard.sh - MBaaS mobile monitoring

echo "=== MBaaS Mobile Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get platform distribution
get_platform_distribution() {
    echo "  Platforms:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Platform":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count platform; do
            echo "    $platform: $count"
        done
}

# Function: Get client versions
get_client_versions() {
    echo "  Client Versions:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Client-Version":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count version; do
            echo "    $version: $count"
        done
}

# Function: Get active devices
get_active_devices() {
    local devices=$(tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Device-ID":"[^"]*"' | \
        cut -d'"' -f4 | sort -u | wc -l)
    echo "  Active Devices: $devices"
}

# Function: Get cache performance
get_cache_performance() {
    local hits=$(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"')
    local total=$(tail -1000 /var/log/nginx/access.log | wc -l)
    if [ $total -gt 0 ]; then
        local rate=$((hits * 100 / total))
        echo "  Cache Hit Rate: $rate%"
    else
        echo "  Cache Hit Rate: N/A"
    fi
}

# Function: Get error rate
get_error_rate() {
    local errors=$(tail -1000 /var/log/nginx/access.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "  Error Rate: $errors%"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              MBaaS MOBILE DASHBOARD                           ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 MBaaS STATISTICS:"
    get_platform_distribution
    echo ""
    get_client_versions
    echo ""
    get_active_devices
    echo ""
    
    echo "⚡ PERFORMANCE:"
    get_cache_performance
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx as a Mobile Backend as a Service (MBaaS) gateway. Use these techniques to build scalable, secure, and feature-rich mobile backends.
