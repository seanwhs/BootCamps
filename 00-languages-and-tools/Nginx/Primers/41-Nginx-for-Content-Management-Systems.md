# Primer 41: Nginx for Content Management Systems (CMS)

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for Content Management Systems (CMS). Understanding these concepts is essential for building scalable, performant, and secure CMS architectures.

## P41.1 CMS Architecture

### CMS Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CMS ARCHITECTURE                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX CMS GATEWAY                              │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONTENT DELIVERY                       │ │      │
│  │  │  • Page Caching    • Edge Caching      • CDN             │ │      │
│  │  │  • Static Assets   • Image Optimization  • Compression   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONTENT MANAGEMENT                     │ │      │
│  │  │  • Admin Interface  • Content API      • Workflow         │ │      │
│  │  │  • Media Handling   • Version Control   • Preview        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PERFORMANCE OPTIMIZATION               │ │      │
│  │  │  • Page Caching     • Asset Optimization  • Lazy Loading  │ │      │
│  │  │  • Static Generation • Server Push       • Prefetching   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    CMS SERVICES                                   │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Content    │  │ Media      │  │ User       │  │ Workflow │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete CMS Configuration

```nginx
# nginx-cms.conf - Complete CMS Configuration
# ============================================================================
# NGINX CMS GATEWAY
# Complete production-ready CMS configuration
# ============================================================================

http {
    # =========================================================================
    # CMS SPECIFIC SETTINGS
    # =========================================================================
    # Large uploads for media
    client_max_body_size 100M;
    client_body_buffer_size 1M;
    
    # Buffer settings
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Timeouts
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # =========================================================================
    # CMS CACHING
    # =========================================================================
    # Page cache
    proxy_cache_path /var/cache/nginx/page_cache
        levels=1:2
        keys_zone=page_cache:500m
        max_size=10g
        inactive=1h
        use_temp_path=off;
    
    # Media cache
    proxy_cache_path /var/cache/nginx/media_cache
        levels=1:2
        keys_zone=media_cache:1g
        max_size=50g
        inactive=30d
        use_temp_path=off;
    
    # API cache
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2
        keys_zone=api_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # CMS UPSTREAMS
    # =========================================================================
    # Content Service
    upstream content_service {
        server content:8001 max_fails=3 fail_timeout=30s;
        server content-backup:8001 backup;
        keepalive 32;
    }
    
    # Media Service
    upstream media_service {
        server media:8002 max_fails=3 fail_timeout=30s;
        server media-backup:8002 backup;
        keepalive 32;
    }
    
    # Admin Service
    upstream admin_service {
        server admin:8003 max_fails=3 fail_timeout=30s;
        server admin-backup:8003 backup;
        keepalive 32;
    }
    
    # API Service
    upstream api_service {
        server api:8004 max_fails=3 fail_timeout=30s;
        server api-backup:8004 backup;
        keepalive 32;
    }
    
    # =========================================================================
    # CMS SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name cms.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cms.crt;
        ssl_certificate_key /etc/nginx/ssl/cms.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # CMS headers
        add_header X-CMS "nginx" always;
        add_header X-CMS-Version "2.0.0" always;
        
        # =========================================================================
        # FRONTEND CONTENT DELIVERY
        # =========================================================================
        location / {
            # Browser caching for pages
            expires 1h;
            add_header Cache-Control "public, max-age=3600";
            
            # Page cache
            proxy_cache page_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 302 1h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Serve content
            proxy_pass http://content_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # MEDIA FILES
        # =========================================================================
        location /media/ {
            # Long-term caching for media
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            # Media cache
            proxy_cache media_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Serve media
            proxy_pass http://media_service/media/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Large file support
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            proxy_max_temp_file_size 1024m;
        }
        
        # =========================================================================
        # IMAGE OPTIMIZATION
        # =========================================================================
        location ~* \.(jpg|jpeg|png|gif|ico|svg|webp|avif)$ {
            # Image optimization
            set $image_quality "85";
            set $image_format "webp";
            
            # WebP support
            if ($http_accept ~* "webp") {
                set $image_format "webp";
            }
            
            # Image caching
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            # Serve optimized images
            try_files $uri @image_optimizer;
        }
        
        location @image_optimizer {
            proxy_pass http://media_service/optimize;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Format $image_format;
            proxy_set_header X-Quality $image_quality;
            
            # Cache optimized images
            proxy_cache media_cache;
            proxy_cache_key $scheme$host$request_uri$image_format$image_quality;
            proxy_cache_valid 200 30d;
            add_header X-Image-Optimized "true";
            add_header X-Image-Format $image_format;
        }
        
        # =========================================================================
        # ADMIN INTERFACE
        # =========================================================================
        location /admin/ {
            # IP-based access control
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;
            
            # Admin authentication
            auth_basic "CMS Admin";
            auth_basic_user_file /etc/nginx/.htpasswd;
            
            # Strict rate limiting
            limit_req zone=admin_limit burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            add_header X-Robots-Tag "noindex, nofollow";
            
            # Serve admin
            proxy_pass http://admin_service/admin/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # CONTENT API
        # =========================================================================
        location /api/ {
            # API authentication
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Rate limiting
            limit_req zone=api_limit burst=20 nodelay;
            
            # Content API caching
            if ($request_method = GET) {
                proxy_cache api_cache;
                proxy_cache_key $scheme$host$request_uri$http_accept_language;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            # Serve API
            proxy_pass http://api_service/api/;
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
            
            # Compression for API responses
            gzip on;
            gzip_comp_level 6;
            gzip_types application/json;
        }
        
        # =========================================================================
        # STATIC ASSETS
        # =========================================================================
        location /static/ {
            alias /var/www/html/static/;
            
            # Browser caching
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            # Compression
            gzip_static on;
            gzip_proxied any;
            
            # Open file cache
            open_file_cache max=10000 inactive=30s;
            open_file_cache_valid 30s;
            open_file_cache_min_uses 2;
            open_file_cache_errors on;
            
            # Sendfile optimization
            sendfile on;
            tcp_nopush on;
        }
        
        # =========================================================================
        # WEBHOOKS (Content Updates)
        # =========================================================================
        location /webhooks/ {
            # Webhook authentication
            if ($http_x_webhook_secret = "") {
                return 401 '{"error":"Webhook secret required"}';
                add_header Content-Type application/json;
            }
            
            # Rate limiting
            limit_req zone=webhook_limit burst=5 nodelay;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            # Serve webhooks
            proxy_pass http://content_service/webhooks/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Webhook-Secret $http_x_webhook_secret;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # Webhook specific headers
            add_header X-Webhook-Received "true";
        }
        
        # =========================================================================
        # CONTENT PREVIEW
        # =========================================================================
        location /preview/ {
            # Preview authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # No caching for preview
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-Preview "true";
            
            # Serve preview
            proxy_pass http://content_service/preview/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://admin_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            
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
        # CMS STATUS
        # =========================================================================
        location /cms/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "cache_status":{
                    "page_cache_size":"$(du -sh /var/cache/nginx/page_cache | cut -f1)",
                    "media_cache_size":"$(du -sh /var/cache/nginx/media_cache | cut -f1)",
                    "api_cache_size":"$(du -sh /var/cache/nginx/api_cache | cut -f1)"
                },
                "performance":{
                    "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
                    "avg_response_time":$(tail -100 /var/log/nginx/access.log | grep -o '"request_time":[0-9.]*' | cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print 0}')
                },
                "content_stats":{
                    "pages_cached":$(find /var/cache/nginx/page_cache -type f | wc -l),
                    "media_files":$(find /var/cache/nginx/media_cache -type f | wc -l)
                },
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # CACHE PURGE
        # =========================================================================
        location /cms/purge {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            # Purge page cache
            proxy_cache_purge page_cache "$scheme$host$1";
            proxy_cache_purge media_cache "$scheme$host$1";
            
            return 200 '{"status":"cache purged","path":"$1"}';
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

## P41.2 CMS Performance Optimization

### Performance Configuration

```nginx
# nginx-cms-performance.conf - CMS Performance
# ============================================================================
# NGINX CMS PERFORMANCE OPTIMIZATION
# Complete performance optimization for CMS
# ============================================================================

http {
    # =========================================================================
    # CACHE WARMING
    # =========================================================================
    # Preload popular pages
    location /cms/warm {
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
        
        # Warm cache for popular URLs
        proxy_pass http://content_service/warm;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        proxy_send_timeout 5s;
        
        return 200 '{"status":"warming started"}';
        add_header Content-Type application/json;
    }
    
    # =========================================================================
    # STATIC FILE CACHING
    # =========================================================================
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ {
        # Long-term caching
        expires 30d;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options "nosniff";
        
        # Compression
        gzip_static on;
        gzip_proxied any;
        
        # Open file cache
        open_file_cache max=10000 inactive=30s;
        open_file_cache_valid 30s;
        open_file_cache_min_uses 2;
        open_file_cache_errors on;
        
        # Sendfile
        sendfile on;
        tcp_nopush on;
        
        root /var/www/html;
        try_files $uri =404;
    }
    
    # =========================================================================
    # HTML CACHING WITH STALE-WHILE-REVALIDATE
    # =========================================================================
    location / {
        # Browser caching with stale-while-revalidate
        expires 1h;
        add_header Cache-Control "public, max-age=3600, stale-while-revalidate=3600";
        
        # Edge caching
        proxy_cache page_cache;
        proxy_cache_key $scheme$host$request_uri$http_accept_language;
        proxy_cache_valid 200 302 1h;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating;
        proxy_cache_lock on;
        add_header X-Cache-Status $upstream_cache_status;
        
        proxy_pass http://content_service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

## P41.3 CMS Security Hardening

### Security Configuration

```nginx
# nginx-cms-security.conf - CMS Security
# ============================================================================
# NGINX CMS SECURITY HARDENING
# Complete security configuration for CMS
# ============================================================================

http {
    # =========================================================================
    # SECURITY HEADERS
    # =========================================================================
    # Content Security Policy
    add_header Content-Security-Policy "
        default-src 'self';
        script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.example.com;
        style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
        img-src 'self' data: https:;
        font-src 'self' https://fonts.gstatic.com;
        connect-src 'self' https://api.example.com;
        frame-ancestors 'none';
        form-action 'self';
        base-uri 'self';
        upgrade-insecure-requests;
        block-all-mixed-content;
    " always;
    
    # Other security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=()" always;
    
    # =========================================================================
    # SENSITIVE FILE PROTECTION
    # =========================================================================
    location ~* \.(env|git|svn|htaccess|htpasswd|ini|log|sql|sqlite|db|bak|backup|old|orig|save)$ {
        return 403;
    }
    
    location ~* /(wp-config|config|settings|database|db)\.(php|ini|yaml|yml|json|xml)$ {
        return 403;
    }
    
    # =========================================================================
    # ADMIN PROTECTION
    # =========================================================================
    location /admin/ {
        # IP restrictions
        allow 10.0.0.0/8;
        allow 172.16.0.0/12;
        allow 192.168.0.0/16;
        allow 127.0.0.1;
        deny all;
        
        # Authentication
        auth_basic "CMS Admin";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        # Rate limiting
        limit_req zone=admin_limit burst=2 nodelay;
        limit_conn conn_limit 2;
        
        # No caching
        add_header Cache-Control "no-store, no-cache, must-revalidate";
        add_header X-Robots-Tag "noindex, nofollow";
        
        proxy_pass http://admin_service/admin/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

## P41.4 CMS Monitoring Dashboard

### CMS Monitoring Dashboard

```bash
#!/bin/bash
# cms-monitor.sh - CMS monitoring dashboard

echo "=== CMS Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

# Function: Get content stats
get_content_stats() {
    local pages=$(find /var/cache/nginx/page_cache -type f 2>/dev/null | wc -l)
    local media=$(find /var/cache/nginx/media_cache -type f 2>/dev/null | wc -l)
    echo "  Cached Pages: $pages"
    echo "  Cached Media: $media"
}

# Function: Get cache sizes
get_cache_sizes() {
    echo "  Cache Sizes:"
    echo "    Page Cache: $(du -sh /var/cache/nginx/page_cache 2>/dev/null | cut -f1)"
    echo "    Media Cache: $(du -sh /var/cache/nginx/media_cache 2>/dev/null | cut -f1)"
    echo "    API Cache: $(du -sh /var/cache/nginx/api_cache 2>/dev/null | cut -f1)"
}

# Function: Get request rates
get_request_rates() {
    local total=$(tail -60 /var/log/nginx/access.log | wc -l)
    local api=$(tail -60 /var/log/nginx/access.log | grep -c "/api/")
    local admin=$(tail -60 /var/log/nginx/access.log | grep -c "/admin/")
    echo "  Request Rates:"
    echo "    Total: $((total / 1)) req/min"
    echo "    API: $((api / 1)) req/min"
    echo "    Admin: $((admin / 1)) req/min"
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
    echo "║              CMS MONITORING DASHBOARD                         ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 CACHE PERFORMANCE:"
    get_cache_performance
    get_cache_sizes
    echo ""
    get_content_stats
    echo ""
    get_request_rates
    echo ""
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for Content Management Systems. Use these techniques to build scalable, performant, and secure CMS architectures.
