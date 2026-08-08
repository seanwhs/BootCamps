# Primer 52: Nginx for Platform Engineering & Developer Portals

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for platform engineering and developer portals. Understanding these concepts is essential for building internal developer platforms, API gateways, and self-service infrastructure.

## P52.1 Developer Portal Architecture

### Developer Platform Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DEVELOPER PORTAL ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX DEVELOPER PORTAL                         │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    API MANAGEMENT                         │ │      │
│  │  │  • API Catalog      • Documentation      • SDK Download    │ │      │
│  │  │  • API Keys         • Rate Limits        • Usage Analytics │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SELF-SERVICE                           │ │      │
│  │  │  • Provisioning     • Credentials        • Configuration   │ │      │
│  │  │  • Deployment       • Monitoring        • Alerts          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PLATFORM SERVICES                      │ │      │
│  │  │  • Service Mesh     • Observability      • CI/CD          │ │      │
│  │  │  • Authentication   • Authorization      • Secrets        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    PLATFORM SERVICES                              │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ API        │  │ Identity   │  │ CI/CD      │  │ Monitoring│ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service   │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Developer Portal Configuration

```nginx
# nginx-developer-portal.conf - Complete Developer Portal
# ============================================================================
# NGINX DEVELOPER PORTAL & PLATFORM ENGINEERING
# Complete production-ready developer portal configuration
# ============================================================================

http {
    # =========================================================================
    # DEVELOPER PORTAL SETTINGS
    # =========================================================================
    client_max_body_size 50M;
    client_body_buffer_size 1M;
    
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # =========================================================================
    # DEVELOPER PORTAL CACHING
    # =========================================================================
    # API catalog cache
    proxy_cache_path /var/cache/nginx/api_catalog_cache
        levels=1:2
        keys_zone=api_catalog_cache:500m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    # Documentation cache
    proxy_cache_path /var/cache/nginx/doc_cache
        levels=1:2
        keys_zone=doc_cache:500m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # DEVELOPER PORTAL UPSTREAMS
    # =========================================================================
    # API Catalog Service
    upstream api_catalog {
        least_conn;
        server catalog1:8001 max_fails=3 fail_timeout=30s;
        server catalog2:8001 max_fails=3 fail_timeout=30s;
        server catalog3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Documentation Service
    upstream doc_service {
        least_conn;
        server doc1:8002 max_fails=3 fail_timeout=30s;
        server doc2:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # API Gateway Service
    upstream api_gateway {
        least_conn;
        server gateway1:8003 max_fails=3 fail_timeout=30s;
        server gateway2:8003 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Identity Service
    upstream identity_service {
        server identity1:8004 max_fails=3 fail_timeout=30s;
        server identity2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Platform Service
    upstream platform_service {
        server platform1:8005 max_fails=3 fail_timeout=30s;
        server platform2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Analytics Service
    upstream analytics_service {
        server analytics1:8006 max_fails=3 fail_timeout=30s;
        server analytics2:8006 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=developer:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=api_catalog:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=docs:10m rate=200r/m;
    limit_req_zone $binary_remote_addr zone=api_gateway:10m rate=100r/s;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # DEVELOPER PORTAL SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name developer.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/developer.crt;
        ssl_certificate_key /etc/nginx/ssl/developer.key;
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
        
        # Developer portal headers
        add_header X-Developer-Portal "nginx" always;
        add_header X-Developer-Version "2.0.0" always;
        
        # Global Rate Limiting
        limit_req zone=developer burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # =========================================================================
        # API CATALOG
        # =========================================================================
        location /catalog/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=api_catalog burst=10 nodelay;
            
            # Cache catalog
            proxy_cache api_catalog_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://api_catalog/catalog/;
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
        # API DOCUMENTATION
        # =========================================================================
        location /docs/ {
            # Cache documentation
            proxy_cache doc_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://doc_service/docs/;
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
        # API GATEWAY (Developer Access)
        # =========================================================================
        location /api/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=api_gateway burst=50 nodelay;
            limit_conn conn_limit 20;
            
            # API key validation
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Route to API gateway
            proxy_pass http://api_gateway/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-API-Key $http_x_api_key;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # SELF-SERVICE PROVISIONING
        # =========================================================================
        location /provision/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=developer burst=5 nodelay;
            limit_conn conn_limit 5;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://platform_service/provision/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Resource-Type $http_x_resource_type;
            proxy_set_header X-Resource-Config $http_x_resource_config;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
        
        # =========================================================================
        # API KEY MANAGEMENT
        # =========================================================================
        location /keys/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=developer burst=5 nodelay;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://identity_service/keys/;
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
        # USAGE ANALYTICS
        # =========================================================================
        location /analytics/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=developer burst=10 nodelay;
            
            # Cache analytics (short TTL)
            proxy_cache api_catalog_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 30s;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://analytics_service/analytics/;
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
        # SDK DOWNLOADS
        # =========================================================================
        location /sdk/ {
            # Cache SDKs
            proxy_cache doc_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
            
            # SDK headers
            add_header Cache-Control "public, max-age=86400";
            add_header Content-Disposition "attachment; filename=\"$http_x_sdk_name\"";
            
            proxy_pass http://doc_service/sdk/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-SDK-Language $http_x_sdk_language;
            proxy_set_header X-SDK-Version $http_x_sdk_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # SERVICE STATUS
        # =========================================================================
        location /status/ {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            # Service health check
            location /status/health {
                return 200 '{"status":"healthy"}';
                add_header Content-Type application/json;
            }
            
            return 200 '{
                "services":{
                    "api_catalog":$(curl -s -o /dev/null -w "%{http_code}" http://catalog1:8001/health),
                    "documentation":$(curl -s -o /dev/null -w "%{http_code}" http://doc1:8002/health),
                    "api_gateway":$(curl -s -o /dev/null -w "%{http_code}" http://gateway1:8003/health),
                    "identity":$(curl -s -o /dev/null -w "%{http_code}" http://identity1:8004/health),
                    "platform":$(curl -s -o /dev/null -w "%{http_code}" http://platform1:8005/health),
                    "analytics":$(curl -s -o /dev/null -w "%{http_code}" http://analytics1:8006/health)
                },
                "developer_activity":{
                    "api_keys":$(tail -10000 /var/log/nginx/access.log | grep -c "/keys/"),
                    "provisioning":$(tail -10000 /var/log/nginx/access.log | grep -c "/provision/"),
                    "api_calls":$(tail -10000 /var/log/nginx/access.log | grep -c "/api/"),
                    "docs_views":$(tail -10000 /var/log/nginx/access.log | grep -c "/docs/")
                },
                "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://identity_service/validate;
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
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P52.2 Developer Experience Features

### Documentation Gateway

```nginx
# nginx-doc-gateway.conf - Documentation Gateway
# ============================================================================
# NGINX DOCUMENTATION GATEWAY
# Complete documentation delivery configuration
# ============================================================================

http {
    # =========================================================================
    # DOCUMENTATION UPSTREAMS
    # =========================================================================
    upstream doc_storage {
        server docs:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # DOCUMENTATION SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name docs.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/docs.crt;
        ssl_certificate_key /etc/nginx/ssl/docs.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # =========================================================================
        # STATIC DOCUMENTATION
        # =========================================================================
        location / {
            # Cache documentation
            proxy_cache doc_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Security headers
            add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
            add_header X-Content-Type-Options "nosniff" always;
            add_header X-Frame-Options "DENY" always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
            
            proxy_pass http://doc_storage;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # API REFERENCE
        # =========================================================================
        location /api-reference/ {
            # API documentation with versioning
            proxy_cache doc_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://doc_storage/api-reference/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Version $http_x_api_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

## P52.3 Developer Portal Monitoring

### Developer Portal Dashboard

```bash
#!/bin/bash
# developer-portal-monitor.sh - Developer portal monitoring

echo "=== Developer Portal Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get developer activity
get_developer_activity() {
    local api_keys=$(tail -10000 /var/log/nginx/access.log | grep -c "/keys/")
    local provisioning=$(tail -10000 /var/log/nginx/access.log | grep -c "/provision/")
    local api_calls=$(tail -10000 /var/log/nginx/access.log | grep -c "/api/")
    local docs_views=$(tail -10000 /var/log/nginx/access.log | grep -c "/docs/")
    echo "  Developer Activity:"
    echo "    API Keys Created: $api_keys"
    echo "    Resources Provisioned: $provisioning"
    echo "    API Calls: $api_calls"
    echo "    Documentation Views: $docs_views"
}

# Function: Get API usage
get_api_usage() {
    local top_endpoints=$(tail -10000 /var/log/nginx/access.log | grep "/api/" | awk '{print $7}' | sort | uniq -c | sort -nr | head -5)
    echo "  Top API Endpoints:"
    echo "$top_endpoints" | while read count endpoint; do
        echo "    $endpoint: $count"
    done
}

# Function: Get SDK downloads
get_sdk_downloads() {
    local sdks=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-SDK-Language":"[^"]*"' | cut -d'"' -f4 | sort | uniq -c | sort -nr)
    echo "  SDK Downloads:"
    echo "$sdks" | while read count sdk; do
        echo "    $sdk: $count"
    done
}

# Function: Get service health
get_service_health() {
    echo "  Service Health:"
    for service in catalog doc gateway identity platform analytics; do
        health=$(curl -s -o /dev/null -w "%{http_code}" "http://${service}1:8001/health" 2>/dev/null)
        if [ "$health" = "200" ]; then
            echo -e "    ${GREEN}✓ $service: healthy${NC}"
        else
            echo -e "    ${RED}✗ $service: unhealthy (HTTP $health)${NC}"
        fi
    done
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              DEVELOPER PORTAL MONITORING DASHBOARD            ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "👨‍💻 DEVELOPER ACTIVITY:"
    get_developer_activity
    echo ""
    echo "📊 API USAGE:"
    get_api_usage
    echo ""
    echo "📦 SDK DOWNLOADS:"
    get_sdk_downloads
    echo ""
    echo "🏥 SERVICE HEALTH:"
    get_service_health
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for platform engineering and developer portals. Use these techniques to build internal developer platforms, API gateways, and self-service infrastructure.
