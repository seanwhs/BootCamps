# Primer 25: Nginx for Microservices - Complete Reference

## The Target

This primer provides the definitive, complete reference guide for using Nginx in microservices architectures. It consolidates all microservices patterns, practices, and configurations into a single comprehensive reference.

## P25.1 Microservices Patterns Reference

### Pattern Catalog

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MICROSERVICES PATTERN CATALOG                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PATTERN 01: API Gateway                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Single entry point for all services                                  │   │
│  │ Benefits: Centralized routing, security, monitoring                 │   │
│  │ Use When: Multiple services, different clients                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PATTERN 02: Service Discovery                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Dynamic service location                                             │   │
│  │ Benefits: Auto-scaling, resilience, no hardcoded addresses          │   │
│  │ Use When: Dynamic environments, containerized services               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PATTERN 03: Circuit Breaker                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Prevent cascading failures                                            │   │
│  │ Benefits: Resilience, graceful degradation, fallback                 │   │
│  │ Use When: Critical services, external dependencies                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PATTERN 04: Load Balancing                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Distribute traffic across instances                                  │   │
│  │ Benefits: Scalability, availability, performance                     │   │
│  │ Use When: Multiple instances, high traffic                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PATTERN 05: Rate Limiting                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Control request rates                                                 │   │
│  │ Benefits: Protection, fairness, cost control                         │   │
│  │ Use When: Public APIs, tiered services                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PATTERN 06: Caching                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Cache responses at the edge                                           │   │
│  │ Benefits: Performance, reduced load, lower latency                   │   │
│  │ Use When: Read-heavy workloads, stable data                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PATTERN 07: Authentication & Authorization                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Centralized auth at the gateway                                       │   │
│  │ Benefits: Single auth point, consistent security                     │   │
│  │ Use When: Multiple services requiring auth                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  PATTERN 08: Canary Deployment                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Gradual rollout of new versions                                      │   │
│  │ Benefits: Safe deployments, rollback capability                      │   │
│  │ Use When: Production deployments, high-risk changes                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P25.2 Complete Microservices Configuration

### Ultimate Microservices Gateway

```nginx
# nginx-microservices.conf - Complete Microservices Gateway
# ============================================================================
# NGINX MICROSERVICES GATEWAY - ULTIMATE REFERENCE
# Complete production-ready microservices configuration
# ============================================================================

http {
    # =========================================================================
    # GLOBAL SETTINGS
    # =========================================================================
    worker_processes auto;
    worker_rlimit_nofile 65535;
    worker_priority -20;
    
    events {
        worker_connections 65535;
        use epoll;
        multi_accept on;
        accept_mutex off;
    }
    
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server_tokens off;
    charset utf-8;
    
    # =========================================================================
    # PERFORMANCE SETTINGS
    # =========================================================================
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 1000;
    types_hash_max_size 2048;
    client_max_body_size 10M;
    
    # =========================================================================
    # LOGGING
    # =========================================================================
    log_format microservices escape=json '{'
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
        '"service":"$service_name",'
        '"user_id":"$auth_user_id",'
        '"api_key":"$http_x_api_key"'
    '}';
    
    access_log /var/log/nginx/microservices.log microservices;
    error_log /var/log/nginx/error.log warn;
    
    # =========================================================================
    # REQUEST ID
    # =========================================================================
    map $http_x_request_id $request_id {
        default $http_x_request_id;
        '' $request_uuid;
    }
    
    set $request_uuid $request_id;
    if ($request_uuid = "") {
        set $request_uuid $request_id;
    }
    
    # =========================================================================
    # SERVICE DISCOVERY
    # =========================================================================
    resolver 127.0.0.11 valid=10s;  # Docker DNS
    
    # Service mapping
    map $request_uri $service_name {
        default "unknown";
        ~^/auth/ "auth";
        ~^/users/ "users";
        ~^/orders/ "orders";
        ~^/products/ "products";
        ~^/payments/ "payments";
        ~^/notifications/ "notifications";
        ~^/analytics/ "analytics";
    }
    
    # Service endpoints
    map $service_name $service_endpoint {
        default "http://localhost:8000";
        auth "http://auth:8001";
        users "http://users:8002";
        orders "http://orders:8003";
        products "http://products:8004";
        payments "http://payments:8005";
        notifications "http://notifications:8006";
        analytics "http://analytics:8007";
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    # Global
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_conn_zone $binary_remote_addr zone=conn:10m;
    
    # Service-specific
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=users:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=orders:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=products:10m rate=200r/m;
    limit_req_zone $binary_remote_addr zone=payments:10m rate=10r/m;
    
    # =========================================================================
    # CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/microservices_cache
        levels=1:2
        keys_zone=microservices_cache:200m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # CIRCUIT BREAKER
    # =========================================================================
    # Upstream with circuit breaker pattern
    upstream auth_service {
        zone auth 64k;
        server auth:8001 max_fails=3 fail_timeout=30s;
        server auth-backup:8001 backup;
        keepalive 32;
    }
    
    upstream users_service {
        zone users 64k;
        server users:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream orders_service {
        zone orders 64k;
        server orders:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream products_service {
        zone products 64k;
        server products:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream payments_service {
        zone payments 64k;
        server payments:8005 max_fails=2 fail_timeout=10s;
        keepalive 16;
    }
    
    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name api.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/api.crt;
        ssl_certificate_key /etc/nginx/ssl/api.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # CORS
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-API-Key" always;
        add_header Access-Control-Expose-Headers "X-Request-ID, X-RateLimit-Limit, X-RateLimit-Remaining" always;
        
        # Preflight
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-API-Key" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Length 0;
            return 204;
        }
        
        # Global Rate Limiting
        limit_req zone=global burst=20 nodelay;
        limit_conn conn 20;
        
        # =========================================================================
        # ROUTING - AUTH
        # =========================================================================
        location /auth/ {
            limit_req zone=auth burst=2 nodelay;
            limit_conn conn 2;
            
            proxy_pass http://auth_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Service "auth";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # ROUTING - USERS
        # =========================================================================
        location /users/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            limit_req zone=users burst=10 nodelay;
            
            proxy_pass http://users_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Service "users";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # ROUTING - ORDERS
        # =========================================================================
        location /orders/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            limit_req zone=orders burst=20 nodelay;
            
            # Cache GET requests
            if ($request_method = GET) {
                proxy_cache microservices_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                proxy_cache_valid 404 1m;
                proxy_cache_use_stale error timeout updating;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://orders_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Service "orders";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
        
        # =========================================================================
        # ROUTING - PRODUCTS (PUBLIC)
        # =========================================================================
        location /products/ {
            limit_req zone=products burst=30 nodelay;
            
            # Heavy caching
            proxy_cache microservices_cache;
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
            proxy_set_header X-Service "products";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # ROUTING - PAYMENTS
        # =========================================================================
        location /payments/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            limit_req zone=payments burst=5 nodelay;
            limit_conn conn 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            
            proxy_pass http://payments_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Service "payments";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # Circuit breaker
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            proxy_intercept_errors on;
            error_page 502 503 504 = /payments-fallback;
        }
        
        # =========================================================================
        # PAYMENTS FALLBACK (CIRCUIT BREAKER)
        # =========================================================================
        location = /payments-fallback {
            return 503 '{"error":"Payment service temporarily unavailable","retry_after":"30s"}';
            add_header Content-Type application/json;
            add_header Retry-After 30;
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
            proxy_set_header X-API-Key $http_x_api_key;
            
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
        # SERVICE STATUS
        # =========================================================================
        location /status/ {
            internal;
            
            proxy_pass http://$service_name/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
        }
        
        # =========================================================================
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            
            set $health_status "healthy";
            set $health_services "";
            
            # Check all services
            location /health/auth {
                internal;
                proxy_pass http://auth_service/health;
                proxy_connect_timeout 2s;
                proxy_read_timeout 5s;
                if ($upstream_status != 200) {
                    set $health_status "degraded";
                    set $health_services "${health_services}auth:down;";
                }
            }
            
            return 200 '{
                "status":"$health_status",
                "services":"$health_services",
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # METRICS
        # =========================================================================
        location /metrics {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            stub_status on;
            access_log off;
        }
        
        # =========================================================================
        # NGINX STATUS
        # =========================================================================
        location /nginx-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            stub_status on;
            access_log off;
        }
    }
}
```

## P25.3 Quick Reference: Microservices Directives

### Essential Directives

| Directive | Purpose | Example |
|-----------|---------|---------|
| `proxy_pass` | Forward to service | `proxy_pass http://users/;` |
| `proxy_set_header` | Set request headers | `proxy_set_header X-User-ID $user_id;` |
| `auth_request` | Authentication check | `auth_request /auth/validate;` |
| `limit_req` | Rate limiting | `limit_req zone=api burst=10;` |
| `proxy_cache` | Response caching | `proxy_cache microservices_cache;` |
| `proxy_next_upstream` | Failover | `proxy_next_upstream error timeout;` |
| `split_clients` | A/B testing | `split_clients $remote_addr $variant 10% "B";` |

## P25.4 Troubleshooting Commands

### Service Discovery

```bash
# Check service resolution
docker exec nginx-proxy nslookup users

# Check service health
curl http://users:8002/health

# Check upstream status
curl http://localhost/health
```

### Rate Limiting

```bash
# Test rate limits
for i in {1..20}; do
    curl -s -o /dev/null -w "%{http_code}\n" http://localhost/api/
done

# Check rate limit hits
tail -100 /var/log/nginx/microservices.log | grep -c '"status":429'
```

### Circuit Breaker

```bash
# Test circuit breaker
curl http://localhost/payments/
# Should return 503 if payment service is down

# Check failover
curl -v http://localhost/orders/ 2>&1 | grep "X-Upstream"
```

---

This primer provides the definitive, complete reference guide for using Nginx in microservices architectures. It consolidates all patterns, practices, and configurations into a single comprehensive reference.
