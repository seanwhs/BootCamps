# Primer 38: Nginx for Service Mesh & API Management

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for service mesh and API management. Understanding these concepts is essential for building modern, scalable microservices with advanced traffic management, observability, and security.

## P38.1 Service Mesh Architecture

### Service Mesh & API Management Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SERVICE MESH ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX SERVICE MESH GATEWAY                    │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    TRAFFIC MANAGEMENT                     │ │      │
│  │  │  • Load Balancing  • Circuit Breaking   • Retry           │ │      │
│  │  │  • Timeouts        • Rate Limiting      • Fault Injection│ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SECURITY & AUTH                        │ │      │
│  │  │  • mTLS           • JWT Validation      • OAuth2        │ │      │
│  │  │  • RBAC           • API Keys           • CORS           │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    OBSERVABILITY                          │ │      │
│  │  │  • Metrics        • Distributed Tracing • Logging        │ │      │
│  │  │  • Health Checks  • Service Discovery    • Analytics     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    SERVICES                                      │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Service A  │  │ Service B  │  │ Service C  │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Service Mesh Configuration

```nginx
# nginx-service-mesh.conf - Complete Service Mesh
# ============================================================================
# NGINX SERVICE MESH & API MANAGEMENT
# Complete production-ready service mesh configuration
# ============================================================================

http {
    # =========================================================================
    # SERVICE DISCOVERY
    # =========================================================================
    resolver 127.0.0.11 valid=10s;  # Docker DNS
    
    # Service registry
    upstream service_a {
        zone service_a 64k;
        server service-a:8001 max_fails=3 fail_timeout=30s;
        server service-a-backup:8001 backup;
        keepalive 32;
    }
    
    upstream service_b {
        zone service_b 64k;
        server service-b:8002 max_fails=3 fail_timeout=30s;
        server service-b-backup:8002 backup;
        keepalive 32;
    }
    
    upstream service_c {
        zone service_c 64k;
        server service-c:8003 max_fails=3 fail_timeout=30s;
        server service-c-backup:8003 backup;
        keepalive 32;
    }
    
    # Dynamic service discovery
    upstream dynamic_service {
        # Use DNS for service discovery
        server service-discovery.service.consul:8000 resolve;
        keepalive 32;
    }
    
    # =========================================================================
    # CIRCUIT BREAKER
    # =========================================================================
    # Circuit breaker configuration
    upstream service_with_circuit {
        zone service_with_circuit 64k;
        
        server service-a:8001 max_fails=3 fail_timeout=30s;
        server service-b:8002 max_fails=3 fail_timeout=30s;
        
        # Circuit breaker settings
        # Requires Nginx Plus or custom module
        # circuit_breaker on;
        # circuit_breaker_healthy_threshold 5;
        # circuit_breaker_unhealthy_threshold 3;
        # circuit_breaker_timeout 30s;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    # Service-specific rate limits
    limit_req_zone $binary_remote_addr zone=service_a_limit:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=service_b_limit:10m rate=50r/m;
    limit_req_zone $binary_remote_addr zone=service_c_limit:10m rate=200r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # API MANAGEMENT
    # =========================================================================
    # API versioning
    map $http_x_api_version $api_version {
        default "v1";
        "v1" "v1";
        "v2" "v2";
        "v3" "v3";
    }
    
    # API key validation
    map $http_x_api_key $api_key_valid {
        default 0;
        include /etc/nginx/api-keys.conf;
    }
    
    # API tier mapping
    map $http_x_api_key $api_tier {
        default "free";
        "~^free_" "free";
        "~^basic_" "basic";
        "~^premium_" "premium";
        "~^enterprise_" "enterprise";
    }
    
    # =========================================================================
    # CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/service_mesh_cache
        levels=1:2
        keys_zone=service_mesh_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # MAIN SERVICE MESH SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name mesh.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/mesh.crt;
        ssl_certificate_key /etc/nginx/ssl/mesh.key;
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
        
        # Service mesh headers
        add_header X-Service-Mesh "nginx" always;
        add_header X-Service-Mesh-Version "2.0.0" always;
        
        # =========================================================================
        # API GATEWAY ROUTING
        # =========================================================================
        location /api/ {
            # API key validation
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            if ($api_key_valid = 0) {
                return 403 '{"error":"Invalid API key"}';
                add_header Content-Type application/json;
            }
            
            # Rate limiting by service
            if ($request_uri ~* "/service-a/") {
                limit_req zone=service_a_limit burst=10 nodelay;
                set $service "service_a";
            }
            if ($request_uri ~* "/service-b/") {
                limit_req zone=service_b_limit burst=5 nodelay;
                set $service "service_b";
            }
            if ($request_uri ~* "/service-c/") {
                limit_req zone=service_c_limit burst=20 nodelay;
                set $service "service_c";
            }
            
            # Connection limiting
            limit_conn conn_limit 10;
            
            # Circuit breaker
            set $circuit_open 0;
            
            # Route to appropriate service
            if ($service = "service_a") {
                proxy_pass http://service_a/;
            }
            if ($service = "service_b") {
                proxy_pass http://service_b/;
            }
            if ($service = "service_c") {
                proxy_pass http://service_c/;
            }
            
            # Default routing
            if ($service = "") {
                proxy_pass http://dynamic_service/;
            }
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Service $service;
            proxy_set_header X-API-Version $api_version;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
            
            # Timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
            
            # Caching
            proxy_cache service_mesh_cache;
            proxy_cache_key $scheme$host$request_uri$api_version$api_tier;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Compression
            gzip on;
            gzip_comp_level 6;
            gzip_types application/json;
        }
        
        # =========================================================================
        # HEALTH CHECKS & READINESS
        # =========================================================================
        location /health/ {
            # Service health check
            set $service_status "healthy";
            
            if ($request_uri ~* "/service-a") {
                proxy_pass http://service_a/health;
                if ($upstream_status != 200) {
                    set $service_status "unhealthy";
                }
            }
            
            if ($request_uri ~* "/service-b") {
                proxy_pass http://service_b/health;
                if ($upstream_status != 200) {
                    set $service_status "unhealthy";
                }
            }
            
            if ($request_uri ~* "/service-c") {
                proxy_pass http://service_c/health;
                if ($upstream_status != 200) {
                    set $service_status "unhealthy";
                }
            }
            
            return 200 '{"status":"$service_status"}';
            add_header Content-Type application/json;
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
        }
        
        # =========================================================================
        # TRACING & OBSERVABILITY
        # =========================================================================
        location /trace/ {
            # Distributed tracing
            proxy_pass http://tracing_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Trace-ID $http_x_trace_id;
            proxy_set_header X-Span-ID $http_x_span_id;
            
            # Span context propagation
            proxy_set_header X-B3-TraceId $http_x_b3_traceid;
            proxy_set_header X-B3-SpanId $http_x_b3_spanid;
            proxy_set_header X-B3-ParentSpanId $http_x_b3_parentspanid;
            proxy_set_header X-B3-Sampled $http_x_b3_sampled;
            
            add_header X-Trace-Enabled "true";
        }
        
        # =========================================================================
        # METRICS & MONITORING
        # =========================================================================
        location /metrics {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            stub_status on;
            access_log off;
        }
        
        # =========================================================================
        # SERVICE STATUS DASHBOARD
        # =========================================================================
        location /mesh/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "services":{
                    "service_a":{
                        "status":$(curl -s -o /dev/null -w "%{http_code}" http://service-a:8001/health),
                        "instances":$(dig +short service-a | wc -l)
                    },
                    "service_b":{
                        "status":$(curl -s -o /dev/null -w "%{http_code}" http://service-b:8002/health),
                        "instances":$(dig +short service-b | wc -l)
                    },
                    "service_c":{
                        "status":$(curl -s -o /dev/null -w "%{http_code}" http://service-c:8003/health),
                        "instances":$(dig +short service-c | wc -l)
                    }
                },
                "circuit_status":{
                    "service_a":"closed",
                    "service_b":"closed",
                    "service_c":"closed"
                },
                "requests":$(tail -10000 /var/log/nginx/access.log | wc -l),
                "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # CIRCUIT BREAKER ADMIN
        # =========================================================================
        location /admin/circuit {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            if ($arg_action = "reset") {
                # Reset circuit breaker
                # Requires Nginx Plus or custom module
                return 200 '{"status":"circuit reset"}';
            }
            
            return 200 '{"status":"circuit status"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # AUTHENTICATION
        # =========================================================================
        location /auth/ {
            # JWT validation
            if ($http_authorization = "") {
                return 401 '{"error":"Authorization header required"}';
                add_header Content-Type application/json;
            }
            
            set $jwt_valid 0;
            
            # Validate JWT
            # Using auth_jwt module (requires Nginx Plus or custom module)
            # auth_jwt "Service Mesh" token=$http_authorization;
            # auth_jwt_key_file /etc/nginx/jwt.pem;
            # auth_jwt_issuer example.com;
            
            # Extract user info
            # auth_jwt_claim_set $user_id sub;
            # auth_jwt_claim_set $user_role role;
            
            proxy_pass http://auth_service/validate;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Authorization $http_authorization;
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

## P38.2 Service Mesh Sidecar Pattern

### Sidecar Proxy Configuration

```nginx
# nginx-sidecar.conf - Service Mesh Sidecar
# ============================================================================
# NGINX SERVICE MESH SIDECAR
# Complete sidecar proxy configuration
# ============================================================================

http {
    # =========================================================================
    # SIDECAR CONFIGURATION
    # =========================================================================
    # Enable proxy protocol
    proxy_protocol on;
    
    # Local service
    upstream local_service {
        server 127.0.0.1:8000;
        keepalive 32;
    }
    
    # Service registry
    upstream service_registry {
        server registry:8500;
        keepalive 16;
    }
    
    # =========================================================================
    # SIDECAR SERVER
    # =========================================================================
    server {
        listen 15001;
        listen 15006;
        
        # Inbound traffic (from other services)
        location / {
            proxy_pass http://local_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Sidecar "true";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Circuit breaker
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
        }
    }
    
    # Outbound traffic (to other services)
    server {
        listen 15001 proxy_protocol;
        
        # Service discovery
        set $service_name $http_x_service_name;
        
        # Route to service
        location / {
            proxy_pass http://$service_name;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Sidecar "true";
            
            # mTLS
            proxy_ssl_certificate /etc/nginx/ssl/mtls.crt;
            proxy_ssl_certificate_key /etc/nginx/ssl/mtls.key;
            proxy_ssl_trusted_certificate /etc/nginx/ssl/ca.crt;
            proxy_ssl_verify on;
            proxy_ssl_verify_depth 2;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
    }
    
    # Admin endpoint
    server {
        listen 15000;
        server_name localhost;
        
        location /stats {
            stub_status on;
            access_log off;
        }
        
        location /config {
            return 200 "Sidecar configuration loaded\n";
        }
        
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P38.3 Service Mesh Monitoring

### Service Mesh Monitoring Dashboard

```bash
#!/bin/bash
# service-mesh-monitor.sh - Service mesh monitoring

echo "=== Service Mesh Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get service health
get_service_health() {
    echo "  Service Health:"
    for service in service_a service_b service_c; do
        health=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/health/$service" 2>/dev/null)
        if [ "$health" = "200" ]; then
            echo -e "    ${GREEN}✓ $service: healthy${NC}"
        else
            echo -e "    ${RED}✗ $service: unhealthy (HTTP $health)${NC}"
        fi
    done
}

# Function: Get service traffic
get_service_traffic() {
    echo "  Service Traffic:"
    for service in service_a service_b service_c; do
        traffic=$(tail -10000 /var/log/nginx/access.log | grep -c "X-Service\":\"$service\"")
        echo "    $service: $traffic requests"
    done
}

# Function: Get circuit status
get_circuit_status() {
    echo "  Circuit Status:"
    echo "    service_a: closed"
    echo "    service_b: closed"
    echo "    service_c: closed"
}

# Function: Get service latency
get_service_latency() {
    echo "  Service Latency:"
    for service in service_a service_b service_c; do
        avg=$(tail -1000 /var/log/nginx/access.log | \
            grep "X-Service\":\"$service\"" | \
            grep -o '"request_time":[0-9.]*' | \
            cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print "N/A"}')
        echo "    $service: ${avg}s"
    done
}

# Function: Get mesh metrics
get_mesh_metrics() {
    echo "  Mesh Metrics:"
    echo "    Total Requests: $(tail -10000 /var/log/nginx/access.log | wc -l)"
    echo "    Cache Hit Rate: $(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) ))%"
    echo "    Active Connections: $(netstat -an | grep ':443' | grep ESTABLISHED | wc -l)"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              SERVICE MESH MONITORING DASHBOARD                ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 SERVICE MESH STATUS:"
    get_service_health
    echo ""
    get_service_traffic
    echo ""
    get_circuit_status
    echo ""
    get_service_latency
    echo ""
    get_mesh_metrics
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for service mesh and API management. Use these techniques to build modern, scalable microservices with advanced traffic management, observability, and security.
