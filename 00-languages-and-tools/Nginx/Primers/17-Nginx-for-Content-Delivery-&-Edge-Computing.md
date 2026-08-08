# Primer 17: Nginx for Content Delivery & Edge Computing

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for content delivery, edge computing, and CDN architectures. Understanding these concepts is essential for building globally distributed, high-performance applications.

## P17.1 CDN Architecture

### Global Content Delivery Network

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GLOBAL CONTENT DELIVERY NETWORK                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                          ┌─────────────────────┐                           │
│                          │   Origin Server     │                           │
│                          │   (Central)         │                           │
│                          └──────────┬──────────┘                           │
│                                     │                                      │
│              ┌──────────────────────┼──────────────────────┐              │
│              │                      │                      │              │
│              ▼                      ▼                      ▼              │
│  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐    │
│  │   Edge Node       │  │   Edge Node       │  │   Edge Node       │    │
│  │   US-East         │  │   EU-West         │  │   Asia-Pacific    │    │
│  │  ┌─────────────┐  │  │  ┌─────────────┐  │  │  ┌─────────────┐  │    │
│  │  │  Nginx      │  │  │  │  Nginx      │  │  │  │  Nginx      │  │    │
│  │  │  Cache      │  │  │  │  Cache      │  │  │  │  Cache      │  │    │
│  │  └─────────────┘  │  │  └─────────────┘  │  │  └─────────────┘  │    │
│  │  ┌─────────────┐  │  │  ┌─────────────┐  │  │  ┌─────────────┐  │    │
│  │  │  Static     │  │  │  │  Static     │  │  │  │  Static     │  │    │
│  │  │  Content    │  │  │  │  Content    │  │  │  │  Content    │  │    │
│  │  └─────────────┘  │  │  └─────────────┘  │  │  └─────────────┘  │    │
│  └───────────────────┘  └───────────────────┘  └───────────────────┘    │
│              │                      │                      │              │
│              └──────────────────────┼──────────────────────┘              │
│                                     │                                      │
│                          ┌──────────┴──────────┐                          │
│                          │   Global DNS        │                          │
│                          │   Anycast Routing   │                          │
│                          └─────────────────────┘                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Edge Node Configuration

```nginx
# nginx-edge.conf - Edge Node Configuration
# ============================================================================
# NGINX EDGE NODE - CDN & CONTENT DELIVERY
# Complete production-ready edge configuration
# ============================================================================

# ============================================================================
# GLOBAL SETTINGS
# ============================================================================
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;

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
    log_format edge escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request_id":"$request_id",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_response_time":$upstream_response_time,'
        '"cache_status":"$upstream_cache_status",'
        '"edge_location":"$edge_location",'
        '"http_x_forwarded_for":"$http_x_forwarded_for"'
    '}';

    access_log /var/log/nginx/edge.log edge;
    error_log /var/log/nginx/error.log warn;

    # =========================================================================
    # CACHE CONFIGURATION
    # =========================================================================
    # Static content cache (large, long TTL)
    proxy_cache_path /var/cache/nginx/static_cache
        levels=1:2
        keys_zone=static_cache:200m
        max_size=10g
        inactive=30d
        use_temp_path=off
        manager_files=200
        manager_threshold=500ms
        loader_files=200
        loader_threshold=500ms;

    # Dynamic content cache (small, short TTL)
    proxy_cache_path /var/cache/nginx/dynamic_cache
        levels=1:2
        keys_zone=dynamic_cache:50m
        max_size=1g
        inactive=5m
        use_temp_path=off;

    # Micro-cache (very short TTL)
    proxy_cache_path /var/cache/nginx/micro_cache
        levels=1:2
        keys_zone=micro_cache:10m
        max_size=100m
        inactive=10s
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
    # GEO-LOCATION MAPPING
    # =========================================================================
    # Edge location (set by deployment)
    map $host $edge_location {
        default "us-east";
        "*.us.example.com" "us-east";
        "*.eu.example.com" "eu-west";
        "*.ap.example.com" "ap-southeast";
        "*.sa.example.com" "sa-east";
    }

    # Origin mapping based on location
    map $edge_location $origin_server {
        default "origin-us:8000";
        "us-east" "origin-us:8000";
        "eu-west" "origin-eu:8000";
        "ap-southeast" "origin-ap:8000";
        "sa-east" "origin-sa:8000";
    }

    # =========================================================================
    # UPSTREAM ORIGINS
    # =========================================================================
    upstream origin_us {
        server origin-us:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    upstream origin_eu {
        server origin-eu:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    upstream origin_ap {
        server origin-ap:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    upstream origin_sa {
        server origin-sa:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    # =========================================================================
    # EDGE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name ~^(?<subdomain>.+)\.example\.com$;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/edge.crt;
        ssl_certificate_key /etc/nginx/ssl/edge.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;

        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Edge-Location $edge_location always;

        # --------------------------------------------------------------------
        # LOCATION: STATIC CONTENT (HEAVILY CACHED)
        # --------------------------------------------------------------------
        location /static/ {
            # Edge caching
            proxy_cache static_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_encoding;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;

            # Browser caching
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Cache-Status $upstream_cache_status;

            # Serve from edge or origin
            proxy_pass http://$origin_server/static/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Edge-Location $edge_location;
        }

        # --------------------------------------------------------------------
        # LOCATION: API CONTENT (MICRO-CACHING)
        # --------------------------------------------------------------------
        location /api/ {
            # Micro-caching for API
            proxy_cache micro_cache;
            proxy_cache_key $scheme$host$request_uri$http_authorization;
            proxy_cache_valid 200 5s;
            proxy_cache_valid 404 1s;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;

            add_header X-Cache-Status $upstream_cache_status;
            add_header X-Cache-TTL "5s";

            proxy_pass http://$origin_server/api/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Edge-Location $edge_location;
        }

        # --------------------------------------------------------------------
        # LOCATION: IMAGES (OPTIMIZED CACHING)
        # --------------------------------------------------------------------
        location ~* \.(jpg|jpeg|png|gif|ico|webp|svg|avif)$ {
            # Aggressive caching
            proxy_cache static_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;

            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Cache-Status $upstream_cache_status;

            proxy_pass http://$origin_server;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Edge-Location $edge_location;
        }

        # --------------------------------------------------------------------
        # LOCATION: DYNAMIC CONTENT (SHORT CACHE)
        # --------------------------------------------------------------------
        location /dynamic/ {
            # Dynamic cache
            proxy_cache dynamic_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 302 5m;
            proxy_cache_valid 404 10s;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;

            add_header X-Cache-Status $upstream_cache_status;
            add_header X-Cache-TTL "5m";

            proxy_pass http://$origin_server/dynamic/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Edge-Location $edge_location;
        }

        # --------------------------------------------------------------------
        # LOCATION: ORIGIN FALLBACK
        # --------------------------------------------------------------------
        location / {
            # Try cache first
            try_files $uri @origin_fallback;
        }

        # --------------------------------------------------------------------
        # LOCATION: ORIGIN FALLBACK HANDLER
        # --------------------------------------------------------------------
        location @origin_fallback {
            proxy_pass http://$origin_server/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Edge-Location $edge_location;

            # Timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;

            # Retry
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
        }

        # --------------------------------------------------------------------
        # LOCATION: CACHE PURGE
        # --------------------------------------------------------------------
        location /purge/ {
            # Only allow from internal
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;

            # Purge cache
            proxy_cache_purge static_cache "$scheme$host$1";
            proxy_cache_purge dynamic_cache "$scheme$host$1";
            proxy_cache_purge micro_cache "$scheme$host$1";

            return 200 '{"status":"purged","path":"$1"}';
            add_header Content-Type application/json;
        }

        # --------------------------------------------------------------------
        # LOCATION: CACHE STATUS
        # --------------------------------------------------------------------
        location /cache-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;

            return 200 '{
                "edge_location":"$edge_location",
                "static_cache_size":"$(du -sh /var/cache/nginx/static_cache | cut -f1)",
                "dynamic_cache_size":"$(du -sh /var/cache/nginx/dynamic_cache | cut -f1)",
                "micro_cache_size":"$(du -sh /var/cache/nginx/micro_cache | cut -f1)",
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }

        # --------------------------------------------------------------------
        # LOCATION: HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            return 200 "healthy\n";
        }

        # --------------------------------------------------------------------
        # LOCATION: NGINX STATUS
        # --------------------------------------------------------------------
        location /nginx-status {
            allow 127.0.0.1;
            deny all;
            stub_status on;
            access_log off;
        }
    }

    # =========================================================================
    # HTTP REDIRECT
    # =========================================================================
    server {
        listen 80;
        listen [::]:80;
        server_name _;

        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

        return 301 https://$host$request_uri;
    }
}
```

## P17.2 Cache Invalidation & Purge

### Cache Purge System

```bash
#!/bin/bash
# cache-purge.sh - Cache invalidation system

echo "=== Cache Purge System ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
EDGE_NODES=(
    "https://us-edge.example.com/purge/"
    "https://eu-edge.example.com/purge/"
    "https://ap-edge.example.com/purge/"
    "https://sa-edge.example.com/purge/"
)

# Function: Purge cache on all edge nodes
purge_all() {
    local path=$1
    local response
    
    echo -e "${BLUE}Purging: $path${NC}"
    
    for node in "${EDGE_NODES[@]}"; do
        echo -n "  Purging on ${node}... "
        
        response=$(curl -s -k -X PURGE "$node$path" 2>/dev/null)
        
        if [[ $response == *"purged"* ]]; then
            echo -e "${GREEN}SUCCESS${NC}"
        else
            echo -e "${RED}FAILED${NC}"
            echo "    Response: $response"
        fi
    done
}

# Function: Purge all cache for a URL pattern
purge_pattern() {
    local pattern=$1
    
    echo -e "${BLUE}Purging pattern: $pattern${NC}"
    
    # Remove leading slash if present
    pattern=${pattern#/}
    
    purge_all "$pattern"
}

# Function: Purge by URL pattern with wildcard
purge_wildcard() {
    local pattern=$1
    
    # Remove leading slash
    pattern=${pattern#/}
    
    # If pattern ends with *, remove it
    if [[ $pattern == *\* ]]; then
        pattern=${pattern%\*}
        purge_all "$pattern*"
    else
        purge_all "$pattern"
    fi
}

# Function: Show cache stats
show_stats() {
    echo -e "${BLUE}Cache Statistics:${NC}"
    
    for node in "${EDGE_NODES[@]}"; do
        echo "  $node:"
        response=$(curl -s -k "$node/../cache-status" 2>/dev/null)
        if [ -n "$response" ]; then
            echo "$response" | python -m json.tool | sed 's/^/    /'
        else
            echo "    Unavailable"
        fi
        echo ""
    done
}

# Main command handler
case "$1" in
    purge)
        if [ -z "$2" ]; then
            echo "Usage: $0 purge <path>"
            echo "Example: $0 purge /static/js/main.js"
            exit 1
        fi
        purge_pattern "$2"
        ;;
    wildcard)
        if [ -z "$2" ]; then
            echo "Usage: $0 wildcard <pattern>"
            echo "Example: $0 wildcard /static/js/*"
            exit 1
        fi
        purge_wildcard "$2"
        ;;
    stats)
        show_stats
        ;;
    all)
        # Purge all cache
        echo -e "${RED}⚠️  Purging all cache!${NC}"
        read -p "Are you sure? (yes/no) " -r
        if [[ $REPLY =~ ^[Yy]es$ ]]; then
            purge_all "*"
        fi
        ;;
    *)
        echo "Usage: $0 {purge <path>|wildcard <pattern>|stats|all}"
        echo ""
        echo "Commands:"
        echo "  purge <path>    - Purge specific path"
        echo "  wildcard <pattern> - Purge with wildcard"
        echo "  stats           - Show cache statistics"
        echo "  all             - Purge all cache"
        exit 1
        ;;
esac
```

## P17.3 Performance Optimization

### Edge Performance Tuning

```nginx
# nginx-edge-perf.conf - Edge performance tuning
http {
    # =========================================================================
    # PERFORMANCE OPTIMIZATION
    # =========================================================================
    
    # Connection pooling
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # Buffer optimization
    proxy_buffering on;
    proxy_buffer_size 16k;
    proxy_buffers 32 16k;
    proxy_busy_buffers_size 64k;
    
    # Sendfile optimization
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    # File cache
    open_file_cache max=10000 inactive=30s;
    open_file_cache_valid 60s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    # =========================================================================
    # CACHE OPTIMIZATION
    # =========================================================================
    
    # Cache locking (prevent cache stampede)
    proxy_cache_lock on;
    proxy_cache_lock_timeout 5s;
    proxy_cache_lock_age 5s;
    
    # Background updates
    proxy_cache_background_update on;
    proxy_cache_use_stale error timeout updating;
    
    # Cache revalidation
    proxy_cache_revalidate on;
    
    # Minimum cache usage
    proxy_cache_min_uses 1;
    
    # =========================================================================
    # TIMEOUT OPTIMIZATION
    # =========================================================================
    
    # Connection timeouts
    proxy_connect_timeout 5s;
    proxy_read_timeout 30s;
    proxy_send_timeout 30s;
    
    # Client timeouts
    client_body_timeout 10s;
    client_header_timeout 10s;
    send_timeout 10s;
}
```

### Edge Cache Warming Script

```bash
#!/bin/bash
# cache-warm.sh - Pre-populate edge cache

echo "=== Edge Cache Warming ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
EDGE_DOMAIN="https://us-edge.example.com"
WARM_URLS=(
    "/"
    "/static/css/main.css"
    "/static/js/main.js"
    "/api/health"
    "/products"
    "/products/featured"
    "/images/logo.png"
)

# Function: Warm cache
warm_cache() {
    local url=$1
    
    echo -n "  Warming: $url... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$EDGE_DOMAIN$url" 2>/dev/null)
    
    if [[ $response -eq 200 ]] || [[ $response -eq 304 ]]; then
        echo -e "${GREEN}DONE${NC} (HTTP $response)"
    else
        echo "FAILED (HTTP $response)"
    fi
}

# Function: Warm with parallel requests
warm_parallel() {
    local urls=("$@")
    
    echo -e "${BLUE}Warming cache in parallel...${NC}"
    
    # Run in background
    for url in "${urls[@]}"; do
        warm_cache "$url" &
    done
    
    # Wait for all to complete
    wait
    
    echo -e "${GREEN}Cache warming complete!${NC}"
}

# Function: Warm with staggered requests
warm_staggered() {
    local urls=("$@")
    
    echo -e "${BLUE}Warming cache with staggered requests...${NC}"
    
    for url in "${urls[@]}"; do
        warm_cache "$url"
        sleep 0.5
    done
}

# Main execution
echo "Starting cache warming..."
echo ""

# Warm primary URLs
warm_parallel "${WARM_URLS[@]}"

echo ""
echo -e "${GREEN}Cache warming complete!${NC}"
```

## P17.4 Edge Monitoring

### Edge Health Monitoring

```bash
#!/bin/bash
# edge-monitor.sh - Edge node monitoring

echo "=== Edge Monitoring ==="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
EDGE_NODES=(
    "https://us-edge.example.com"
    "https://eu-edge.example.com"
    "https://ap-edge.example.com"
    "https://sa-edge.example.com"
)

# Function: Check node health
check_node() {
    local node=$1
    
    echo "Checking: $node"
    
    # Check health endpoint
    health=$(curl -s -o /dev/null -w "%{http_code}" "$node/health" 2>/dev/null)
    
    if [[ $health -eq 200 ]]; then
        echo -e "  ${GREEN}✓ Health: OK${NC}"
    else
        echo -e "  ${RED}✗ Health: FAILED (HTTP $health)${NC}"
    fi
    
    # Check response time
    response_time=$(curl -s -o /dev/null -w "%{time_total}" "$node/health" 2>/dev/null)
    echo -e "  Response Time: ${response_time}s"
    
    # Check cache status
    cache_hit_rate=$(curl -s -k "$node/cache-status" 2>/dev/null | \
        python -c "import json, sys; data=json.loads(sys.stdin.read()); print(data.get('cache_hit_rate', 'N/A'))" 2>/dev/null)
    
    if [ -n "$cache_hit_rate" ]; then
        echo -e "  Cache Hit Rate: $cache_hit_rate"
    fi
    
    echo ""
}

# Function: Check all nodes
check_all() {
    echo "Edge Node Health Check"
    echo "======================"
    echo ""
    
    for node in "${EDGE_NODES[@]}"; do
        check_node "$node"
    done
}

# Function: Compare nodes
compare_nodes() {
    echo "Edge Node Comparison"
    echo "===================="
    echo ""
    
    local results=()
    
    for node in "${EDGE_NODES[@]}"; do
        response_time=$(curl -s -o /dev/null -w "%{time_total}" "$node/health" 2>/dev/null)
        results+=("$node: ${response_time}s")
    done
    
    for result in "${results[@]}"; do
        echo "$result"
    done
}

# Main execution
case "$1" in
    all)
        check_all
        ;;
    compare)
        compare_nodes
        ;;
    *)
        echo "Usage: $0 {all|compare}"
        echo ""
        echo "Commands:"
        echo "  all       - Check all edge nodes"
        echo "  compare   - Compare edge node performance"
        exit 1
        ;;
esac
```

---

This primer provides a comprehensive deep dive into using Nginx for content delivery and edge computing. Use these techniques to build globally distributed, high-performance content delivery networks.
