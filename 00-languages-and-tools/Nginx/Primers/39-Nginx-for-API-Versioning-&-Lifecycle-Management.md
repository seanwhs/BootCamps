# Primer 39: Nginx for API Versioning & Lifecycle Management

## The Target

This primer provides a comprehensive deep-dive guide to API versioning and lifecycle management with Nginx. Understanding these concepts is essential for managing API evolution, maintaining backward compatibility, and ensuring smooth transitions between versions.

## P39.1 API Versioning Architecture

### API Lifecycle Management Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    API LIFECYCLE MANAGEMENT                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX API MANAGEMENT GATEWAY                   │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    VERSIONING STRATEGIES                  │ │      │
│  │  │  • URL Path          • Query Parameter   • Header         │ │      │
│  │  │  • Content Negotiation • Subdomain       • Custom         │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    LIFECYCLE MANAGEMENT                   │ │      │
│  │  │  • Alpha/Beta        • Canary         • Sunset           │ │      │
│  │  │  • Deprecation       • EOL            • Migration        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    COMPATIBILITY LAYER                    │ │      │
│  │  │  • Request/Response Transformation  • Schema Evolution   │ │      │
│  │  │  • Field Mapping     • Type Coercion   • Defaults        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    API VERSIONS                                  │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ API v1     │  │ API v2     │  │ API v3     │  │ API v4   │ │      │
│  │  │ (Active)   │  │ (Active)   │  │ (Beta)     │  │ (Alpha)  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete API Versioning Configuration

```nginx
# nginx-api-versioning.conf - Complete API Versioning
# ============================================================================
# NGINX API VERSIONING & LIFECYCLE MANAGEMENT
# Complete production-ready API versioning configuration
# ============================================================================

http {
    # =========================================================================
    # VERSIONING STRATEGIES
    # =========================================================================
    
    # 1. URL Path Versioning
    map $request_uri $version_from_path {
        default "";
        ~^/v(?<version>\d+)/ "$version";
        ~^/api/v(?<version>\d+)/ "$version";
    }
    
    # 2. Header Versioning
    map $http_api_version $version_from_header {
        default "";
        "1" "v1";
        "2" "v2";
        "3" "v3";
        "4" "v4";
        "v1" "v1";
        "v2" "v2";
        "v3" "v3";
        "v4" "v4";
    }
    
    # 3. Query Parameter Versioning
    map $arg_version $version_from_query {
        default "";
        "1" "v1";
        "2" "v2";
        "3" "v3";
        "4" "v4";
        "v1" "v1";
        "v2" "v2";
        "v3" "v3";
        "v4" "v4";
    }
    
    # 4. Content Negotiation
    map $http_accept $version_from_accept {
        default "";
        "~*version=v(?<version>\d+)" "v$version";
        "~*application/vnd\.example\.v(?<version>\d+)\+json" "v$version";
    }
    
    # =========================================================================
    # VERSION SELECTION (PRIORITY ORDER)
    # =========================================================================
    # Priority: Path > Header > Query > Accept
    set $api_version "";
    
    if ($version_from_path != "") {
        set $api_version $version_from_path;
    }
    
    if ($version_from_header != "") {
        set $api_version $version_from_header;
    }
    
    if ($version_from_query != "" && $api_version = "") {
        set $api_version $version_from_query;
    }
    
    if ($version_from_accept != "" && $api_version = "") {
        set $api_version $version_from_accept;
    }
    
    # Default version
    if ($api_version = "") {
        set $api_version "v1";
    }
    
    # =========================================================================
    # VERSION MAPPING TO UPSTREAMS
    # =========================================================================
    map $api_version $version_upstream {
        default "v1_backend";
        "v1" "v1_backend";
        "v2" "v2_backend";
        "v3" "v3_backend";
        "v4" "v4_backend";
    }
    
    # =========================================================================
    # VERSION STATUS (LIFECYCLE)
    # =========================================================================
    map $api_version $version_status {
        default "active";
        "v1" "sunset";      # Going away soon
        "v2" "active";      # Current version
        "v3" "beta";        # Beta preview
        "v4" "alpha";       # Alpha testing
    }
    
    # =========================================================================
    # DEPRECATION WARNINGS
    # =========================================================================
    map $api_version $deprecation_warning {
        default "";
        "v1" "299 - API v1 is deprecated and will be removed on 2024-12-31";
        "v2" "299 - API v2 is deprecated, please migrate to v3";
    }
    
    # =========================================================================
    # COMPATIBILITY TRANSFORMATIONS
    # =========================================================================
    map $api_version $transform_request {
        default "none";
        "v1" "legacy";
        "v2" "none";
    }
    
    # =========================================================================
    # API UPSTREAMS
    # =========================================================================
    upstream v1_backend {
        server api-v1:8001 max_fails=3 fail_timeout=30s;
        server api-v1-backup:8001 backup;
        keepalive 32;
    }
    
    upstream v2_backend {
        server api-v2:8002 max_fails=3 fail_timeout=30s;
        server api-v2-backup:8002 backup;
        keepalive 32;
    }
    
    upstream v3_backend {
        server api-v3:8003 max_fails=3 fail_timeout=30s;
        server api-v3-backup:8003 backup;
        keepalive 32;
    }
    
    upstream v4_backend {
        server api-v4:8004 max_fails=3 fail_timeout=30s;
        server api-v4-backup:8004 backup;
        keepalive 32;
    }
    
    # =========================================================================
    # MAIN API GATEWAY
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name api.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/api.crt;
        ssl_certificate_key /etc/nginx/ssl/api.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # API headers
        add_header X-API-Version $api_version always;
        add_header X-API-Status $version_status always;
        
        # Deprecation warning
        if ($deprecation_warning != "") {
            add_header Deprecation $deprecation_warning always;
            add_header Sunset "2024-12-31T00:00:00Z" always;
        }
        
        # =========================================================================
        # API ROUTING
        # =========================================================================
        location /api/ {
            # Rate limiting
            limit_req zone=api_limit burst=20 nodelay;
            limit_conn conn_limit 10;
            
            # Version routing
            proxy_pass http://$version_upstream/;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Version $api_version;
            proxy_set_header X-API-Status $version_status;
            
            # Compatibility transformation
            if ($transform_request = "legacy") {
                # Legacy transformation
                # Could use Lua or sub_filter for response transformation
                proxy_set_header X-Transform "legacy";
            }
            
            # Timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Retry
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            
            # Caching
            if ($request_method = GET) {
                proxy_cache api_cache;
                proxy_cache_key $scheme$host$request_uri$api_version;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            # Version-specific headers
            if ($api_version = "v1") {
                add_header X-API-Deprecated "true";
                add_header X-API-Sunset-Date "2024-12-31";
            }
            
            if ($api_version = "v3") {
                add_header X-API-Beta "true";
                add_header X-API-Feedback "https://feedback.example.com";
            }
            
            if ($api_version = "v4") {
                add_header X-API-Alpha "true";
                add_header X-API-Experimental "true";
            }
        }
        
        # =========================================================================
        # VERSION MANAGEMENT ENDPOINTS
        # =========================================================================
        location /api/versions {
            # API version information
            add_header Content-Type application/json;
            
            return 200 '{
                "versions": [
                    {
                        "version": "v1",
                        "status": "sunset",
                        "deprecated": true,
                        "sunset_date": "2024-12-31",
                        "docs": "https://docs.example.com/v1"
                    },
                    {
                        "version": "v2",
                        "status": "active",
                        "deprecated": false,
                        "docs": "https://docs.example.com/v2"
                    },
                    {
                        "version": "v3",
                        "status": "beta",
                        "deprecated": false,
                        "docs": "https://docs.example.com/v3"
                    },
                    {
                        "version": "v4",
                        "status": "alpha",
                        "deprecated": false,
                        "docs": "https://docs.example.com/v4"
                    }
                ],
                "current": "$api_version",
                "timestamp": "$time_iso8601"
            }';
        }
        
        # =========================================================================
        # API MIGRATION (VERSION UPGRADE)
        # =========================================================================
        location /api/migrate {
            # Migration endpoint
            set $target_version $arg_target;
            
            if ($target_version = "") {
                return 400 '{"error":"target version required"}';
                add_header Content-Type application/json;
            }
            
            # Validate target version
            if ($target_version !~ ^(v1|v2|v3|v4)$) {
                return 400 '{"error":"invalid target version"}';
                add_header Content-Type application/json;
            }
            
            # Migration logic
            proxy_pass http://migration_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Target-Version $target_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_read_timeout 300s;
            
            add_header X-Migration-Target $target_version;
        }
        
        # =========================================================================
        # CANARY ROUTING (VERSION TESTING)
        # =========================================================================
        location /api/canary {
            # Canary deployment for new versions
            set $canary_target "v2";
            
            # Split traffic
            split_clients $remote_addr $canary_split {
                95%   "stable";   # 95% to stable
                5%    "canary";   # 5% to canary
            }
            
            if ($canary_split = "canary") {
                set $canary_target "v3";
                add_header X-Canary "true";
            }
            
            proxy_pass http://${canary_target}_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Canary-Target $canary_target;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # VERSION ANALYTICS
        # =========================================================================
        location /admin/analytics {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "version_usage": {
                    "v1": $(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v1"' | wc -l),
                    "v2": $(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v2"' | wc -l),
                    "v3": $(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v3"' | wc -l),
                    "v4": $(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v4"' | wc -l)
                },
                "deprecated_usage": $(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v1"' | wc -l),
                "beta_usage": $(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v3"' | wc -l),
                "alpha_usage": $(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v4"' | wc -l),
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

## P39.2 API Lifecycle Management

### Lifecycle Configuration

```nginx
# nginx-api-lifecycle.conf - API Lifecycle Management
# ============================================================================
# NGINX API LIFECYCLE MANAGEMENT
# Complete lifecycle management configuration
# ============================================================================

http {
    # =========================================================================
    # LIFECYCLE STATES
    # =========================================================================
    map $api_version $api_lifecycle {
        default "active";
        "v1" "sunset";
        "v2" "active";
        "v3" "beta";
        "v4" "alpha";
    }
    
    # =========================================================================
    # LIFECYCLE ACTIONS
    # =========================================================================
    map $api_lifecycle $lifecycle_action {
        default "route";
        "alpha" "route_with_warning";
        "beta" "route_with_warning";
        "sunset" "route_with_deprecation";
        "eol" "block_with_message";
    }
    
    # =========================================================================
    # LIFECYCLE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/api.crt;
        ssl_certificate_key /etc/nginx/ssl/api.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # =========================================================================
        # LIFECYCLE ROUTING
        # =========================================================================
        location /api/ {
            # Lifecycle-based routing
            if ($lifecycle_action = "block_with_message") {
                return 410 '{"error":"API version is no longer available"}';
                add_header Content-Type application/json;
            }
            
            if ($lifecycle_action = "route_with_deprecation") {
                add_header Deprecation "true";
                add_header Sunset "2024-12-31T00:00:00Z";
                add_header Link "</api/versions>; rel=\"successor-version\"";
            }
            
            if ($lifecycle_action = "route_with_warning") {
                add_header X-API-Status "preview";
                add_header X-API-Feedback "https://feedback.example.com";
            }
            
            # Route to appropriate backend
            proxy_pass http://${api_version}_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Version $api_version;
            proxy_set_header X-API-Lifecycle $api_lifecycle;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

## P39.3 API Versioning Monitoring

### API Version Monitoring Dashboard

```bash
#!/bin/bash
# api-version-monitor.sh - API version monitoring

echo "=== API Version Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get version usage
get_version_usage() {
    echo "  Version Usage:"
    for version in v1 v2 v3 v4; do
        count=$(tail -10000 /var/log/nginx/access.log | grep -c "\"X-API-Version\":\"$version\"")
        echo "    $version: $count requests"
    done
}

# Function: Get version status
get_version_status() {
    echo "  Version Status:"
    for version in v1 v2 v3 v4; do
        status=$(tail -10000 /var/log/nginx/access.log | grep "\"X-API-Version\":\"$version\"" | \
            grep -o '"X-API-Status":"[^"]*"' | tail -1 | cut -d'"' -f4)
        echo "    $version: $status"
    done
}

# Function: Get deprecated usage
get_deprecated_usage() {
    local deprecated=$(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v1"' | wc -l)
    echo "  Deprecated Usage: $deprecated requests"
}

# Function: Get beta usage
get_beta_usage() {
    local beta=$(tail -10000 /var/log/nginx/access.log | grep '"X-API-Version":"v3"' | wc -l)
    echo "  Beta Usage: $beta requests"
}

# Function: Get migration status
get_migration_status() {
    echo "  Migration Status:"
    local total=$(tail -10000 /var/log/nginx/access.log | wc -l)
    local v1=$(tail -10000 /var/log/nginx/access.log | grep -c '"X-API-Version":"v1"')
    local v2=$(tail -10000 /var/log/nginx/access.log | grep -c '"X-API-Version":"v2"')
    local v3=$(tail -10000 /var/log/nginx/access.log | grep -c '"X-API-Version":"v3"')
    local v4=$(tail -10000 /var/log/nginx/access.log | grep -c '"X-API-Version":"v4"')
    
    if [ $total -gt 0 ]; then
        echo "    v1: $((v1 * 100 / total))%"
        echo "    v2: $((v2 * 100 / total))%"
        echo "    v3: $((v3 * 100 / total))%"
        echo "    v4: $((v4 * 100 / total))%"
    fi
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              API VERSION MONITORING DASHBOARD                 ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 VERSION STATISTICS:"
    get_version_usage
    echo ""
    get_version_status
    echo ""
    get_deprecated_usage
    get_beta_usage
    echo ""
    get_migration_status
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into API versioning and lifecycle management with Nginx. Use these techniques to manage API evolution, maintain backward compatibility, and ensure smooth transitions between versions.
