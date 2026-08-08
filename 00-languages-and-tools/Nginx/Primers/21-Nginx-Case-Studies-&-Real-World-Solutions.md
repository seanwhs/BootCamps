# Primer 21: Nginx Case Studies & Real-World Solutions

## The Target

This primer provides real-world case studies and solutions for common Nginx challenges. Understanding these practical applications is essential for solving real production problems.

## P21.1 E-Commerce Platform

### Case Study: High-Traffic E-Commerce

**Challenge:** An e-commerce platform handling 50,000+ concurrent users during flash sales.

**Requirements:**
- Handle 10,000+ req/s during peak
- 99.99% uptime
- Sub-100ms latency
- Geographic distribution
- Session stickiness
- Secure payment processing
- Real-time inventory updates

**Solution:**

```nginx
# nginx-ecommerce.conf - E-Commerce Platform
# ============================================================================
# E-COMMERCE NGINX CONFIGURATION
# High-traffic, high-availability e-commerce platform
# ============================================================================

http {
    # =========================================================================
    # PERFORMANCE SETTINGS
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
    
    # =========================================================================
    # CACHE CONFIGURATION
    # =========================================================================
    proxy_cache_path /var/cache/nginx/products_cache
        levels=1:2
        keys_zone=products_cache:500m
        max_size=20g
        inactive=1h
        use_temp_path=off
        manager_files=500
        manager_threshold=1000ms
        loader_files=500
        loader_threshold=1000ms;
    
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2
        keys_zone=api_cache:200m
        max_size=5g
        inactive=5m
        use_temp_path=off;
    
    # =========================================================================
    # REGIONAL UPSTREAMS
    # =========================================================================
    # US Region
    upstream us_backend {
        server us-app1:8000 max_fails=3 fail_timeout=30s;
        server us-app2:8000 max_fails=3 fail_timeout=30s;
        server us-app3:8000 max_fails=3 fail_timeout=30s;
        
        # Sticky sessions
        cookie srv_id expires=1h path=/;
        keepalive 64;
        keepalive_requests 1000;
    }
    
    # EU Region
    upstream eu_backend {
        server eu-app1:8000 max_fails=3 fail_timeout=30s;
        server eu-app2:8000 max_fails=3 fail_timeout=30s;
        server eu-app3:8000 max_fails=3 fail_timeout=30s;
        cookie srv_id expires=1h path=/;
        keepalive 64;
    }
    
    # AP Region
    upstream ap_backend {
        server ap-app1:8000 max_fails=3 fail_timeout=30s;
        server ap-app2:8000 max_fails=3 fail_timeout=30s;
        server ap-app3:8000 max_fails=3 fail_timeout=30s;
        cookie srv_id expires=1h path=/;
        keepalive 64;
    }
    
    # Payment (high security)
    upstream payment_backend {
        server payment1:8005 max_fails=2 fail_timeout=10s;
        server payment2:8005 max_fails=2 fail_timeout=10s;
        server payment3:8005 max_fails=2 fail_timeout=10s;
        keepalive 16;
    }
    
    # =========================================================================
    # GEO ROUTING
    # =========================================================================
    geoip_country /usr/share/GeoIP/GeoIP.dat;
    
    map $geoip_country_code $region {
        default us;
        US us;
        CA us;
        GB eu;
        DE eu;
        FR eu;
        JP ap;
        AU ap;
        IN ap;
        BR sa;
    }
    
    map $region $region_upstream {
        us us_backend;
        eu eu_backend;
        ap ap_backend;
        sa us_backend;  # Fallback to US
        default us_backend;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/s;
    limit_req_zone $binary_remote_addr zone=checkout:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    
    limit_conn_zone $binary_remote_addr zone=conn:10m;
    
    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name shop.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/shop.crt;
        ssl_certificate_key /etc/nginx/ssl/shop.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # Global Rate Limiting
        limit_req zone=global burst=50 nodelay;
        limit_conn conn 20;
        
        # --------------------------------------------------------------------
        # PRODUCT CATALOG (CACHED)
        # --------------------------------------------------------------------
        location /products/ {
            # Heavy caching
            proxy_cache products_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 302 1h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            add_header X-Cache-Status $upstream_cache_status;
            add_header Cache-Control "public, max-age=3600";
            
            proxy_pass http://$region_upstream/products/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Region $region;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # API (CACHED, AUTHENTICATED)
        # --------------------------------------------------------------------
        location /api/ {
            # Authentication check
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting by endpoint
            if ($request_uri ~* "/checkout") {
                limit_req zone=checkout burst=5 nodelay;
            }
            
            # Cache GET requests
            if ($request_method = GET) {
                proxy_cache api_cache;
                proxy_cache_key $scheme$host$request_uri$http_authorization;
                proxy_cache_valid 200 5m;
                proxy_cache_valid 404 30s;
                proxy_cache_use_stale error timeout updating;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://$region_upstream/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Region $region;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # --------------------------------------------------------------------
        # PAYMENT (SECURE)
        # --------------------------------------------------------------------
        location /payment/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Strict rate limiting
            limit_req zone=checkout burst=2 nodelay;
            limit_conn conn 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            
            proxy_pass http://payment_backend/payment/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # --------------------------------------------------------------------
        # STATIC ASSETS (CDN)
        # --------------------------------------------------------------------
        location /static/ {
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            proxy_cache products_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            
            proxy_pass http://$region_upstream/static/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # --------------------------------------------------------------------
        # HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            
            # Check all upstreams
            set $health_status "healthy";
            
            # Check region upstream
            proxy_pass http://$region_upstream/health;
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            
            if ($upstream_status != 200) {
                set $health_status "degraded";
            }
            
            # Check payment
            location /health/payment {
                internal;
                proxy_pass http://payment_backend/health;
                proxy_connect_timeout 2s;
                proxy_read_timeout 5s;
                if ($upstream_status != 200) {
                    set $health_status "degraded";
                }
            }
            
            return 200 '{"status":"$health_status","region":"$region","timestamp":"$time_iso8601"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://$region_upstream/auth/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header X-Region $region;
            
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_role $upstream_http_x_user_role;
            
            proxy_intercept_errors on;
            error_page 401 = /auth/error;
        }
        
        location = /auth/error {
            return 401 '{"error":"Authentication required"}';
            add_header Content-Type application/json;
        }
    }
}
```

**Results:**
- 12,000 req/s handled during peak
- 99.995% uptime achieved
- Average latency: 45ms
- 90% cache hit rate
- Zero payment failures during flash sales

## P21.2 SaaS Platform

### Case Study: Multi-Tenant SaaS

**Challenge:** A SaaS platform serving 1,000+ tenants with custom domains.

**Requirements:**
- Multi-tenant isolation
- Custom domain support
- Tenant-specific rate limiting
- Feature flags per tenant
- API versioning
- Tenant analytics

**Solution:**

```nginx
# nginx-saas.conf - Multi-Tenant SaaS
# ============================================================================
# MULTI-TENANT SAAS NGINX CONFIGURATION
# Supporting 1,000+ tenants with custom domains
# ============================================================================

http {
    # =========================================================================
    # TENANT MAPPING
    # =========================================================================
    # Map tenant from hostname
    map $http_host $tenant_id {
        default "unknown";
        "~^(?<tenant>[^.]+)\.app\.example\.com$" $tenant;
        "~^(?<tenant>[^.]+)\.example\.com$" $tenant;
        "~^app\.(?<tenant>.+)\.example\.com$" $tenant;
        "~^(?<tenant>.+)\.example\.io$" $tenant;
    }
    
    # Tenant configuration lookup
    map $tenant_id $tenant_config {
        default "default";
        include /etc/nginx/tenants/*.conf;
    }
    
    # Tenant upstreams
    map $tenant_id $tenant_upstream {
        default app-default:8000;
        tenant1 app-tenant1:8000;
        tenant2 app-tenant2:8000;
        include /etc/nginx/tenant-upstreams.conf;
    }
    
    # =========================================================================
    # TENANT ISOLATION
    # =========================================================================
    # Tenant-specific rate limiting
    limit_req_zone $tenant_id zone=tenant_global:100m rate=100r/s;
    limit_req_zone $tenant_id zone=tenant_api:100m rate=10r/s;
    limit_req_zone $tenant_id zone=tenant_auth:100m rate=5r/m;
    
    # Tenant-specific connection limits
    limit_conn_zone $tenant_id zone=tenant_conn:100m;
    
    # =========================================================================
    # FEATURE FLAGS
    # =========================================================================
    map $tenant_id $features {
        default "";
        tenant1 "feature-a,feature-b,feature-c";
        tenant2 "feature-a,feature-d";
        tenant3 "feature-b,feature-e";
        include /etc/nginx/tenant-features.conf;
    }
    
    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name ~^(?<tenant>.+)\.app\.example\.com$ app.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/wildcard.crt;
        ssl_certificate_key /etc/nginx/ssl/wildcard.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # Tenant detection
        set $tenant $tenant_id;
        set $tenant_config $tenant_config;
        
        if ($tenant = "unknown") {
            return 404 '{"error":"Tenant not found"}';
        }
        
        # Tenant rate limiting
        limit_req zone=tenant_global burst=20 nodelay;
        limit_conn tenant_conn 50;
        
        # --------------------------------------------------------------------
        # TENANT ROUTING
        # --------------------------------------------------------------------
        location / {
            # Feature flags
            add_header X-Tenant $tenant;
            add_header X-Features $features;
            
            proxy_pass http://$tenant_upstream/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Tenant $tenant;
            proxy_set_header X-Tenant-Config $tenant_config;
            proxy_set_header X-Features $features;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # TENANT API
        # --------------------------------------------------------------------
        location /api/ {
            limit_req zone=tenant_api burst=10 nodelay;
            
            proxy_pass http://$tenant_upstream/api/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Tenant $tenant;
            proxy_set_header X-Features $features;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Tenant-specific caching
            proxy_cache api_cache;
            proxy_cache_key $scheme$host$request_uri$tenant;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
        }
        
        # --------------------------------------------------------------------
        # TENANT AUTH
        # --------------------------------------------------------------------
        location /auth/ {
            limit_req zone=tenant_auth burst=2 nodelay;
            limit_conn tenant_conn 5;
            
            proxy_pass http://$tenant_upstream/auth/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Tenant $tenant;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # TENANT STATS
        # --------------------------------------------------------------------
        location /stats {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "tenant":"$tenant",
                "requests":$(tail -10000 /var/log/nginx/access.log | grep -c "$tenant"),
                "errors":$(tail -10000 /var/log/nginx/access.log | grep "$tenant" | grep -c '"status":5[0-9][0-9]'),
                "cache_hits":$(tail -10000 /var/log/nginx/access.log | grep "$tenant" | grep -c '"upstream_cache_status":"HIT"')
            }';
            add_header Content-Type application/json;
        }
        
        # --------------------------------------------------------------------
        # HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

**Results:**
- 1,200+ tenants served
- Zero tenant data leakage
- Custom domains working
- < 100ms tenant detection overhead
- 99.99% availability

## P21.3 Real-Time Analytics

### Case Study: Real-Time Analytics Platform

**Challenge:** An analytics platform processing 1M+ events per second.

**Requirements:**
- 1M+ events/sec ingestion
- < 10ms processing delay
- Real-time aggregation
- WebSocket streaming
- Historical data access
- Multi-dimensional queries

**Solution:**

```nginx
# nginx-analytics.conf - Real-Time Analytics
# ============================================================================
# REAL-TIME ANALYTICS NGINX CONFIGURATION
# Processing 1M+ events per second
# ============================================================================

http {
    # =========================================================================
    # INGESTION OPTIMIZATION
    # =========================================================================
    # Buffer settings for high throughput
    client_body_buffer_size 256k;
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    client_max_body_size 10M;
    client_body_timeout 5s;
    client_header_timeout 5s;
    
    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 30;
    keepalive_requests 1000;
    
    # =========================================================================
    # INGESTION UPSTREAMS
    # =========================================================================
    # Event ingestion (high throughput)
    upstream ingest_backend {
        least_conn;
        server ingest1:8000 max_fails=3 fail_timeout=30s;
        server ingest2:8000 max_fails=3 fail_timeout=30s;
        server ingest3:8000 max_fails=3 fail_timeout=30s;
        server ingest4:8000 max_fails=3 fail_timeout=30s;
        keepalive 128;
        keepalive_requests 10000;
    }
    
    # Query (read-heavy)
    upstream query_backend {
        least_conn;
        server query1:8001 max_fails=3 fail_timeout=30s;
        server query2:8001 max_fails=3 fail_timeout=30s;
        server query3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # WebSocket (real-time)
    upstream websocket_backend {
        ip_hash;
        server ws1:8002 max_fails=3 fail_timeout=30s;
        server ws2:8002 max_fails=3 fail_timeout=30s;
        server ws3:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=ingest:10m rate=1000r/s;
    limit_req_zone $binary_remote_addr zone=query:10m rate=100r/s;
    limit_conn_zone $binary_remote_addr zone=conn:10m;
    
    # =========================================================================
    # CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/query_cache
        levels=1:2
        keys_zone=query_cache:500m
        max_size=20g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name analytics.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/analytics.crt;
        ssl_certificate_key /etc/nginx/ssl/analytics.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # =========================================================================
        # EVENT INGESTION (HIGH THROUGHPUT)
        # =========================================================================
        location /ingest/ {
            # Very high rate limit
            limit_req zone=ingest burst=100 nodelay;
            limit_conn conn 100;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            # Disable buffering for speed
            proxy_buffering off;
            proxy_request_buffering off;
            
            proxy_pass http://ingest_backend/ingest/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Short timeouts
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
        }
        
        # =========================================================================
        # QUERY (READ-HEAVY)
        # =========================================================================
        location /query/ {
            limit_req zone=query burst=20 nodelay;
            
            # Cache queries
            proxy_cache query_cache;
            proxy_cache_key $scheme$host$request_uri$http_authorization;
            proxy_cache_valid 200 5m;
            proxy_cache_valid 404 30s;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://query_backend/query/;
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
        # WEBSOCKET (REAL-TIME)
        # =========================================================================
        location /ws/ {
            # WebSocket configuration
            proxy_pass http://websocket_backend/ws/;
            
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_buffering off;
            
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 300s;
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
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            
            # Check all upstreams
            set $health_status "healthy";
            
            # Check ingestion
            proxy_pass http://ingest_backend/health;
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            
            if ($upstream_status != 200) {
                set $health_status "degraded";
            }
            
            return 200 '{"status":"$health_status","timestamp":"$time_iso8601"}';
            add_header Content-Type application/json;
        }
    }
}
```

**Results:**
- 1.2M events/sec ingested
- Average latency: 8ms
- 95% cache hit rate for queries
- WebSocket connections: 50,000+
- Zero data loss during maintenance

## P21.4 Comparison Summary

| Use Case | Key Challenge | Nginx Solution | Results |
|----------|--------------|----------------|---------|
| **E-Commerce** | Flash sales traffic | Geo routing, caching, rate limiting | 12K req/s, 45ms latency |
| **SaaS** | Multi-tenant isolation | Dynamic routing, tenant mapping | 1,200+ tenants, 100ms overhead |
| **Analytics** | 1M+ events/sec | High-throughput ingestion, buffering | 1.2M events/sec, 8ms latency |

---

This primer provides real-world case studies and solutions for common Nginx challenges. Use these patterns to solve similar problems in your own production environments.
