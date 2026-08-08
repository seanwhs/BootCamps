# Primer 36: Nginx for Edge Caching & Content Optimization - Complete Reference

## The Target

This primer provides the definitive, complete reference guide for edge caching and content optimization with Nginx. It consolidates all caching patterns, optimization techniques, and configuration strategies into a single complete reference.

## P36.1 Edge Caching Fundamentals

### Complete Caching Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EDGE CACHING ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX EDGE CACHE                               │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CACHE STRATEGIES                       │ │      │
│  │  │  • Browser Cache       • Edge Cache        • CDN Cache   │ │      │
│  │  │  • Micro-Cache         • Static Cache      • Dynamic     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONTENT OPTIMIZATION                   │ │      │
│  │  │  • Compression        • Minification      • Image Opt    │ │      │
│  │  │  • Lazy Loading       • Prefetch          • Preload      │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CACHE MANAGEMENT                       │ │      │
│  │  │  • Invalidation       • Purging          • Warming       │ │      │
│  │  │  • Stale-While-Revalidate • Cache Tags   • Versioning   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Browser│  │ Edge   │  │ CDN    │  │ Origin │  │ Cache  │           │
│  │ Cache  │  │ Cache  │  │ Cache  │  │ Server │  │ Store  │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Edge Cache Configuration

```nginx
# nginx-edge-cache.conf - Complete Edge Caching
# ============================================================================
# NGINX EDGE CACHING COMPLETE REFERENCE
# All caching patterns in one configuration
# ============================================================================

http {
    # =========================================================================
    # CACHE SETTINGS
    # =========================================================================
    # Basic cache settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    
    # Cache keys
    proxy_cache_key $scheme$host$request_uri;
    
    # Cache lock (prevent cache stampede)
    proxy_cache_lock on;
    proxy_cache_lock_timeout 5s;
    proxy_cache_lock_age 5s;
    
    # Stale cache (serve stale while updating)
    proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
    
    # Background updates
    proxy_cache_background_update on;
    
    # Cache revalidation
    proxy_cache_revalidate on;
    
    # Minimum cache usage
    proxy_cache_min_uses 1;
    
    # =========================================================================
    # CACHE PATHS
    # =========================================================================
    # Browser/Edge cache (long TTL)
    proxy_cache_path /var/cache/nginx/browser_cache
        levels=1:2
        keys_zone=browser_cache:200m
        max_size=5g
        inactive=30d
        use_temp_path=off
        manager_files=500
        manager_threshold=1000ms
        loader_files=500
        loader_threshold=1000ms;
    
    # API cache (medium TTL)
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2
        keys_zone=api_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # Micro-cache (short TTL)
    proxy_cache_path /var/cache/nginx/micro_cache
        levels=1:2
        keys_zone=micro_cache:50m
        max_size=500m
        inactive=5s
        use_temp_path=off;
    
    # Static cache (very long TTL)
    proxy_cache_path /var/cache/nginx/static_cache
        levels=1:2
        keys_zone=static_cache:100m
        max_size=10g
        inactive=90d
        use_temp_path=off;
    
    # Fragment cache (for ESI/SSI)
    proxy_cache_path /var/cache/nginx/fragment_cache
        levels=1:2
        keys_zone=fragment_cache:100m
        max_size=1g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # CACHE CONTROL
    # =========================================================================
    # Cache bypass
    map $http_cache_control $bypass_cache {
        default 0;
        "no-cache" 1;
        "no-store" 1;
        "max-age=0" 1;
    }
    
    # Cache by cookie
    map $cookie_sessionid $cache_key_suffix {
        default "";
        "~^(.+)$" "-$1";
    }
    
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
    # MAIN CACHE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name cache.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cache.crt;
        ssl_certificate_key /etc/nginx/ssl/cache.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # Cache headers
        add_header X-Edge-Cache "nginx" always;
        add_header X-Cache-Status $upstream_cache_status always;
        
        # =========================================================================
        # LOCATION: STATIC ASSETS (BROWSER CACHE)
        # =========================================================================
        location ~* \.(jpg|jpeg|png|gif|ico|svg|webp|avif|css|js|woff|woff2|ttf|eot|otf)$ {
            # Browser cache: 30 days
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            # Edge cache: 30 days
            proxy_cache static_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            
            # Compression
            gzip_static on;
            gzip_proxied any;
            
            # Serve from origin
            proxy_pass http://origin/static/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Open file cache
            open_file_cache max=10000 inactive=30s;
            open_file_cache_valid 30s;
            open_file_cache_min_uses 2;
            
            # Sendfile optimization
            sendfile on;
            tcp_nopush on;
        }
        
        # =========================================================================
        # LOCATION: API CONTENT (MICRO-CACHING)
        # =========================================================================
        location /api/ {
            # Cache by user
            proxy_cache micro_cache;
            proxy_cache_key $scheme$host$request_uri$http_authorization;
            proxy_cache_valid 200 5s;
            proxy_cache_valid 404 1s;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            
            # Cache headers
            add_header X-Cache-Status $upstream_cache_status;
            add_header X-Cache-TTL "5s";
            
            # Cache bypass
            proxy_cache_bypass $bypass_cache;
            proxy_no_cache $bypass_cache;
            
            # Serve from origin
            proxy_pass http://api_origin/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Authorization $http_authorization;
            
            # Short timeouts
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
        }
        
        # =========================================================================
        # LOCATION: HTML CONTENT (STALE-WHILE-REVALIDATE)
        # =========================================================================
        location / {
            # Browser cache: 1 hour
            expires 1h;
            add_header Cache-Control "public, max-age=3600, stale-while-revalidate=3600";
            
            # Edge cache: 1 hour
            proxy_cache browser_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 302 1h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            
            # Cache tags for invalidation
            add_header X-Cache-Tags "html,page-$request_uri";
            
            # Serve from origin
            proxy_pass http://origin/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Buffer for HTML
            proxy_buffering on;
            proxy_buffer_size 8k;
            proxy_buffers 16 8k;
            proxy_busy_buffers_size 16k;
        }
        
        # =========================================================================
        # LOCATION: SENSITIVE CONTENT (NO CACHE)
        # =========================================================================
        location /sensitive/ {
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            add_header Pragma "no-cache";
            add_header Expires "0";
            
            # Serve from origin
            proxy_pass http://origin/sensitive/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # =========================================================================
        # LOCATION: CACHE PURGE
        # =========================================================================
        location /purge/ {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            # Purge by URL
            proxy_cache_purge browser_cache "$scheme$host$1";
            proxy_cache_purge api_cache "$scheme$host$1";
            proxy_cache_purge static_cache "$scheme$host$1";
            
            # Purge by tag
            if ($arg_tag) {
                # Tag-based purge would require custom module
                # Using Lua or external module for tag-based purge
            }
            
            return 200 '{"status":"purged","path":"$1"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # LOCATION: CACHE STATUS
        # =========================================================================
        location /cache-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "browser_cache_size":"$(du -sh /var/cache/nginx/browser_cache | cut -f1)",
                "api_cache_size":"$(du -sh /var/cache/nginx/api_cache | cut -f1)",
                "micro_cache_size":"$(du -sh /var/cache/nginx/micro_cache | cut -f1)",
                "static_cache_size":"$(du -sh /var/cache/nginx/static_cache | cut -f1)",
                "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
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

## P36.2 Content Optimization

### Image Optimization

```nginx
# nginx-image-optimization.conf - Image Optimization
# ============================================================================
# NGINX IMAGE OPTIMIZATION
# Complete image optimization configuration
# ============================================================================

http {
    # =========================================================================
    # IMAGE OPTIMIZATION SETTINGS
    # =========================================================================
    # Image types
    image_filter on;
    image_filter_jpeg_quality 85;
    image_filter_webp_quality 80;
    image_filter_png_quality 90;
    
    # Image dimensions
    set $image_width 0;
    set $image_height 0;
    
    # =========================================================================
    # IMAGE OPTIMIZATION LOCATION
    # =========================================================================
    location ~* \.(jpg|jpeg|png|gif|ico|webp)$ {
        # Image optimization
        image_filter resize 800 600;
        image_filter_jpeg_quality 85;
        
        # WebP conversion
        if ($http_accept ~* "webp") {
            image_filter webp;
            image_filter_webp_quality 80;
        }
        
        # Browser caching
        expires 30d;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options "nosniff";
        
        # Edge caching
        proxy_cache static_cache;
        proxy_cache_key $scheme$host$request_uri$image_width$image_height;
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating;
        
        # Serve optimized images
        try_files $uri @image_optimizer;
    }
    
    # =========================================================================
    # IMAGE OPTIMIZER
    # =========================================================================
    location @image_optimizer {
        proxy_pass http://image-optimizer/optimize;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Width $image_width;
        proxy_set_header X-Height $image_height;
        
        # Cache optimized images
        proxy_cache static_cache;
        proxy_cache_key $scheme$host$request_uri$image_width$image_height;
        proxy_cache_valid 200 30d;
        add_header X-Image-Optimized "true";
    }
}
```

### Minification

```nginx
# nginx-minification.conf - Content Minification
# ============================================================================
# NGINX CONTENT MINIFICATION
# Complete minification configuration
# ============================================================================

http {
    # =========================================================================
    # MINIFICATION SETTINGS
    # =========================================================================
    # Minify CSS
    location ~* \.css$ {
        # CSS minification
        sub_filter '  ' ' ';
        sub_filter ' { ' '{';
        sub_filter ' } ' '}';
        sub_filter '; ' ';';
        sub_filter ': ' ':';
        sub_filter '\n' '';
        sub_filter '\r' '';
        sub_filter '\t' ' ';
        sub_filter_once off;
        sub_filter_types text/css;
        
        # Browser caching
        expires 30d;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options "nosniff";
        
        # Edge caching
        proxy_cache static_cache;
        proxy_cache_key $scheme$host$request_uri;
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating;
        
        proxy_pass http://origin;
    }
    
    # =========================================================================
    # MINIFY JAVASCRIPT
    # =========================================================================
    location ~* \.js$ {
        # JavaScript minification
        sub_filter '  ' ' ';
        sub_filter ' { ' '{';
        sub_filter ' } ' '}';
        sub_filter '; ' ';';
        sub_filter ': ' ':';
        sub_filter '\n' '';
        sub_filter '\r' '';
        sub_filter '\t' ' ';
        sub_filter_once off;
        sub_filter_types application/javascript;
        
        # Browser caching
        expires 30d;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options "nosniff";
        
        # Edge caching
        proxy_cache static_cache;
        proxy_cache_key $scheme$host$request_uri;
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating;
        
        proxy_pass http://origin;
    }
}
```

## P36.3 Cache Warmup & Invalidation

### Cache Warmup Script

```bash
#!/bin/bash
# cache-warmup.sh - Cache warmup script

echo "=== Cache Warmup ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# URLs to warm
URLS=(
    "/"
    "/static/css/main.css"
    "/static/js/main.js"
    "/images/logo.png"
    "/api/health"
    "/api/public/products"
    "/api/public/categories"
)

# Warmup function
warm_cache() {
    local url=$1
    
    echo -n "  Warming: $url... "
    
    # Make request to populate cache
    response=$(curl -s -o /dev/null -w "%{http_code}" "https://cache.example.com$url" 2>/dev/null)
    
    if [ "$response" -eq 200 ] || [ "$response" -eq 304 ]; then
        echo -e "${GREEN}DONE${NC} (HTTP $response)"
    else
        echo -e "${RED}FAILED${NC} (HTTP $response)"
    fi
}

# Warm with concurrency
warm_parallel() {
    echo -e "${BLUE}Warming cache in parallel...${NC}"
    
    # Create temp directory for background processes
    local tmp_dir=$(mktemp -d)
    
    # Run in parallel
    for url in "${URLS[@]}"; do
        warm_cache "$url" &
    done
    
    # Wait for all to complete
    wait
    
    rm -rf "$tmp_dir"
    
    echo -e "${GREEN}Cache warmup complete!${NC}"
}

# Main execution
echo ""
warm_parallel
```

### Cache Invalidation Script

```bash
#!/bin/bash
# cache-invalidate.sh - Cache invalidation script

echo "=== Cache Invalidation ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Invalidate single URL
invalidate_url() {
    local url=$1
    
    echo -n "  Invalidating: $url... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -X PURGE "https://cache.example.com/purge$url" 2>/dev/null)
    
    if [ "$response" -eq 200 ]; then
        echo -e "${GREEN}DONE${NC}"
    else
        echo -e "${RED}FAILED${NC} (HTTP $response)"
    fi
}

# Function: Invalidate pattern
invalidate_pattern() {
    local pattern=$1
    
    echo -e "${BLUE}Invalidating pattern: $pattern${NC}"
    
    # Invalidate all matching URLs
    # In production, this would use a cache tag system
    invalidate_url "$pattern"
}

# Function: Invalidate all
invalidate_all() {
    echo -e "${RED}Invalidating all cache!${NC}"
    read -p "Are you sure? (yes/no) " -r
    
    if [[ $REPLY =~ ^[Yy]es$ ]]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -X PURGE "https://cache.example.com/purge/*" 2>/dev/null)
        
        if [ "$response" -eq 200 ]; then
            echo -e "${GREEN}All cache invalidated!${NC}"
        else
            echo -e "${RED}Failed to invalidate all cache${NC}"
        fi
    else
        echo "Cancelled"
    fi
}

# Main execution
case "$1" in
    url)
        if [ -z "$2" ]; then
            echo "Usage: $0 url <url>"
            exit 1
        fi
        invalidate_url "$2"
        ;;
    pattern)
        if [ -z "$2" ]; then
            echo "Usage: $0 pattern <pattern>"
            exit 1
        fi
        invalidate_pattern "$2"
        ;;
    all)
        invalidate_all
        ;;
    *)
        echo "Usage: $0 {url <url>|pattern <pattern>|all}"
        echo ""
        echo "Commands:"
        echo "  url <url>      - Invalidate specific URL"
        echo "  pattern <pattern> - Invalidate pattern"
        echo "  all            - Invalidate all cache"
        exit 1
        ;;
esac
```

---

This primer provides the definitive, complete reference guide for edge caching and content optimization with Nginx. It consolidates all caching patterns, optimization techniques, and configuration strategies into a single complete reference.
