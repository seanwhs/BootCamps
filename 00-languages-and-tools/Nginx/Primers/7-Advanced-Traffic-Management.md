# Primer 7: Advanced Traffic Management

## The Target

This primer provides a comprehensive, deep-dive guide to advanced traffic management with Nginx. Understanding these concepts is essential for building sophisticated routing, load balancing, and traffic control systems.

## P7.1 Advanced Load Balancing

### Load Balancing Algorithms

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    LOAD BALANCING ALGORITHMS                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Round-Robin (Default)                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Requests distributed evenly in sequence                             │   │
│  │ upstream backend {                                                  │   │
│  │     server backend1:8000;                                           │   │
│  │     server backend2:8000;                                           │   │
│  │     server backend3:8000;                                           │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  2. Weighted Round-Robin                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Requests distributed based on server weights                        │   │
│  │ upstream backend {                                                  │   │
│  │     server backend1:8000 weight=3;  # 3x traffic                   │   │
│  │     server backend2:8000 weight=1;  # 1x traffic                   │   │
│  │     server backend3:8000 weight=2;  # 2x traffic                   │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  3. Least Connections                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Requests sent to server with fewest active connections             │   │
│  │ upstream backend {                                                  │   │
│  │     least_conn;                                                     │   │
│  │     server backend1:8000;                                           │   │
│  │     server backend2:8000;                                           │   │
│  │     server backend3:8000;                                           │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  4. IP Hash (Sticky Sessions)                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Same client always goes to same server                             │   │
│  │ upstream backend {                                                  │   │
│  │     ip_hash;                                                        │   │
│  │     server backend1:8000;                                           │   │
│  │     server backend2:8000;                                           │   │
│  │     server backend3:8000;                                           │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  5. Random                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Random selection with optional weighting                            │   │
│  │ upstream backend {                                                  │   │
│  │     random two least_conn;  # Two random, pick least connections   │   │
│  │     server backend1:8000;                                           │   │
│  │     server backend2:8000;                                           │   │
│  │     server backend3:8000;                                           │   │
│  │ }                                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Advanced Upstream Configuration

```nginx
# nginx.conf - Advanced upstream configuration
http {
    # Upstream with dynamic failover
    upstream backend {
        # Active servers
        server backend1:8000 max_fails=3 fail_timeout=30s;
        server backend2:8000 max_fails=3 fail_timeout=30s;
        server backend3:8000 max_fails=3 fail_timeout=30s;
        
        # Backup servers (only used when all active fail)
        server backup1:8000 backup;
        server backup2:8000 backup;
        
        # Performance tuning
        keepalive 32;
        keepalive_requests 1000;
        keepalive_timeout 60s;
        
        # Sticky sessions with cookie
        sticky cookie srv_id expires=1h path=/;
    }
    
    # DNS-based upstream (dynamic service discovery)
    upstream dns_backend {
        # Resolve DNS names
        server backend.service.consul:8000 resolve;
        server backend2.service.consul:8000 resolve;
        
        # DNS refresh interval
        resolver 127.0.0.11 valid=10s;
    }
    
    # Service mesh integration
    upstream mesh_backend {
        # Local service mesh
        zone mesh 64k;
        
        server localhost:8000;
        server localhost:8001;
        
        # Circuit breaker
        # Requires Nginx Plus
        # server localhost:8000 max_fails=3 fail_timeout=30s;
    }
}
```

## P7.2 Traffic Splitting and A/B Testing

### Advanced Traffic Splitting

```nginx
# nginx.conf - Traffic splitting
http {
    # Split traffic using split_clients
    split_clients $remote_addr $variant {
        10%   "A";
        20%   "B";
        30%   "C";
        40%   "D";
        *     "E";
    }
    
    # Map variant to upstream
    map $variant $upstream_target {
        "A" "http://backend_a/";
        "B" "http://backend_b/";
        "C" "http://backend_c/";
        "D" "http://backend_d/";
        default "http://backend_default/";
    }
    
    # User-agent based routing
    map $http_user_agent $device_type {
        default desktop;
        ~*"(android|iphone|ipad|mobile)" mobile;
        ~*"(tablet|kindle)" tablet;
    }
    
    # Geographic routing
    map $geoip_country_code $region {
        default us-west;
        US us-west;
        CA us-west;
        DE eu-west;
        FR eu-west;
        JP ap-northeast;
        AU ap-southeast;
    }
    
    server {
        location /api/ {
            # A/B testing with cookie
            if ($cookie_ab_test = "B") {
                proxy_pass http://backend_b/;
                set $ab_group "B";
            }
            
            # Default to A
            proxy_pass http://backend_a/;
            set $ab_group "A";
            
            # Track variant
            add_header X-AB-Group $ab_group;
            add_header X-Variant $variant;
            
            proxy_set_header X-AB-Group $ab_group;
            proxy_set_header X-Variant $variant;
        }
        
        # Device-specific routing
        location / {
            proxy_pass http://$device_type/;
            proxy_set_header X-Device-Type $device_type;
        }
        
        # Geographic routing
        location /api/ {
            proxy_pass http://$region/;
            proxy_set_header X-Geo-Region $region;
            proxy_set_header X-Geo-Country $geoip_country_code;
        }
    }
}
```

### Gradual Rollout (Canary)

```nginx
# nginx.conf - Canary deployment
http {
    upstream api_stable {
        server api-v1:8000;
        keepalive 32;
    }
    
    upstream api_canary {
        server api-v2:8000;
        keepalive 32;
    }
    
    # Split traffic by percentage
    split_clients $remote_addr $canary_group {
        5%   "canary";   # 5% to canary
        *    "stable";   # 95% to stable
    }
    
    # Cookie-based sticky canary
    map $cookie_canary $canary_override {
        default "none";
        "true" "canary";
    }
    
    server {
        location /api/ {
            # Determine target
            set $target "stable";
            
            # Override with cookie
            if ($canary_override = "canary") {
                set $target "canary";
            }
            
            # Override with percentage
            if ($canary_group = "canary") {
                set $target "canary";
            }
            
            # Route to appropriate upstream
            if ($target = "canary") {
                proxy_pass http://api_canary/;
                add_header X-Canary "true";
            }
            if ($target = "stable") {
                proxy_pass http://api_stable/;
                add_header X-Canary "false";
            }
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Canary $target;
            
            # Set canary cookie for stickyness
            add_header Set-Cookie "canary=$target; Path=/; Max-Age=3600; HttpOnly";
        }
    }
}
```

## P7.3 Rate Limiting Advanced Patterns

### Dynamic Rate Limiting

```nginx
# nginx.conf - Dynamic rate limiting
http {
    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;
    
    # Dynamic rate limit based on API key tier
    map $http_x_api_key $api_tier {
        default "free";
        ~^basic_ "basic";
        ~^premium_ "premium";
    }
    
    # Tier-based limits
    limit_req_zone $binary_remote_addr zone=free:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=basic:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=premium:10m rate=1000r/m;
    
    server {
        location /api/ {
            # Dynamic rate limit by tier
            if ($api_tier = "premium") {
                limit_req zone=premium burst=50 nodelay;
                set $rate_limit "1000r/m";
            }
            if ($api_tier = "basic") {
                limit_req zone=basic burst=10 nodelay;
                set $rate_limit "100r/m";
            }
            if ($api_tier = "free") {
                limit_req zone=free burst=2 nodelay;
                set $rate_limit "10r/m";
            }
            
            # Rate limit headers
            add_header X-RateLimit-Limit $rate_limit;
            add_header X-RateLimit-Remaining $limit_req_remaining;
            add_header X-RateLimit-Reset $limit_req_reset;
            
            proxy_pass http://api/;
        }
    }
}
```

### Concurrent Request Limiting

```nginx
# nginx.conf - Concurrent request limiting
http {
    # Connection limits
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    limit_conn_zone $server_name zone=total_conn:10m;
    
    # Request queueing
    limit_req_zone $binary_remote_addr zone=queue:10m rate=10r/s;
    
    server {
        location /api/ {
            # Per-IP connection limit
            limit_conn conn_limit 10;
            
            # Total connection limit
            limit_conn total_conn 1000;
            
            # Request queuing with burst and delay
            limit_req zone=queue burst=50 delay=10;
            
            # Queue timeout
            limit_req_status 429;
            
            proxy_pass http://api/;
        }
        
        location /api/slow/ {
            # Stricter limits for slow endpoints
            limit_conn conn_limit 2;
            limit_req zone=queue burst=5;
            
            proxy_pass http://api/slow/;
            proxy_read_timeout 300s;
        }
    }
}
```

## P7.4 Geographic Routing

### GeoIP-Based Routing

```nginx
# nginx.conf - Geographic routing with GeoIP
http {
    # GeoIP database
    geoip_country /usr/share/GeoIP/GeoIP.dat;
    geoip_city /usr/share/GeoIP/GeoLiteCity.dat;
    
    # Country-to-datacenter mapping
    map $geoip_country_code $datacenter {
        default us-east;
        US us-east;
        CA us-east;
        GB eu-west;
        DE eu-west;
        FR eu-west;
        JP ap-northeast;
        AU ap-southeast;
        IN ap-south;
        BR sa-east;
    }
    
    # City-to-datacenter mapping
    map $geoip_city $city_dc {
        default us-east;
        "San Francisco" us-west;
        "Los Angeles" us-west;
        "London" eu-west;
        "Paris" eu-west;
        "Tokyo" ap-northeast;
        "Singapore" ap-southeast;
    }
    
    # Upstreams per region
    upstream us-east {
        server us-east-1:8000;
        server us-east-2:8000;
        keepalive 32;
    }
    
    upstream us-west {
        server us-west-1:8000;
        server us-west-2:8000;
        keepalive 32;
    }
    
    upstream eu-west {
        server eu-west-1:8000;
        server eu-west-2:8000;
        keepalive 32;
    }
    
    upstream ap-northeast {
        server ap-northeast-1:8000;
        server ap-northeast-2:8000;
        keepalive 32;
    }
    
    server {
        location /api/ {
            # Route by country
            proxy_pass http://$datacenter/;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Geo-Country $geoip_country_code;
            proxy_set_header X-Geo-City $geoip_city;
            proxy_set_header X-Geo-Region $geoip_region;
            proxy_set_header X-Geo-Lat $geoip_latitude;
            proxy_set_header X-Geo-Lon $geoip_longitude;
        }
    }
}
```

### Content-Based Routing

```nginx
# nginx.conf - Content-based routing
http {
    # Route by Accept header
    map $http_accept $content_type {
        default "json";
        ~*"application/json" "json";
        ~*"application/xml" "xml";
        ~*"text/html" "html";
        ~*"image/" "image";
    }
    
    # Route by User-Agent
    map $http_user_agent $device_type {
        default "desktop";
        ~*"(android|iphone|ipad|mobile)" "mobile";
        ~*"(tablet|kindle)" "tablet";
        ~*"(crawler|bot|spider)" "crawler";
    }
    
    # Route by request path
    map $request_uri $service {
        default "default";
        ~^/api/users "users";
        ~^/api/orders "orders";
        ~^/api/products "products";
        ~^/api/admin "admin";
    }
    
    # Service upstreams
    upstream users {
        server users:8000;
        keepalive 32;
    }
    
    upstream orders {
        server orders:8001;
        keepalive 32;
    }
    
    upstream products {
        server products:8002;
        keepalive 32;
    }
    
    server {
        # Content-type routing
        location /api/ {
            if ($content_type = "xml") {
                proxy_pass http://xml-api/;
            }
            if ($content_type = "json") {
                proxy_pass http://json-api/;
            }
            proxy_pass http://default-api/;
        }
        
        # Device-specific routing
        location / {
            proxy_pass http://$device_type/;
            proxy_set_header X-Device-Type $device_type;
        }
        
        # Service-based routing
        location /api/ {
            proxy_pass http://$service/;
            proxy_set_header X-Service $service;
        }
    }
}
```

## P7.5 WebSocket and SSE Advanced

### WebSocket Cluster

```nginx
# nginx.conf - WebSocket cluster
http {
    upstream websocket_cluster {
        # Sticky sessions for WebSocket
        ip_hash;
        
        server ws1:8002 max_fails=3 fail_timeout=30s;
        server ws2:8002 max_fails=3 fail_timeout=30s;
        server ws3:8002 max_fails=3 fail_timeout=30s;
        
        keepalive 64;
    }
    
    server {
        location /ws/ {
            # WebSocket configuration
            proxy_pass http://websocket_cluster/;
            
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # WebSocket timeouts
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 300s;
            
            # Disable buffering
            proxy_buffering off;
            
            # Health check
            proxy_next_upstream error timeout invalid_header http_500 http_502;
            proxy_next_upstream_tries 2;
        }
    }
}
```

### SSE Optimization

```nginx
# nginx.conf - SSE optimization
http {
    upstream sse_cluster {
        server sse1:8003;
        server sse2:8003;
        keepalive 32;
    }
    
    server {
        location /sse/ {
            proxy_pass http://sse_cluster/;
            
            # SSE-specific settings
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # CRITICAL: Disable buffering
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_set_header X-Accel-Buffering no;
            
            # Cache control
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            
            # Long timeouts
            proxy_read_timeout 600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 600s;
            
            # Keep connection alive
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

## P7.6 Service Mesh Integration

### Consul Integration

```nginx
# nginx.conf - Consul service discovery
http {
    # DNS resolver for Consul
    resolver 127.0.0.11 valid=10s;
    
    upstream backend {
        # Service discovery with Consul
        server backend.service.consul:8000 resolve;
        server backend2.service.consul:8000 resolve;
        server backend3.service.consul:8000 resolve;
        
        keepalive 32;
    }
    
    # Health check with Consul
    location /health/consul {
        proxy_pass http://consul:8500/v1/health/service/backend;
        proxy_set_header Host $host;
        
        # Convert Consul health to Nginx health
        if ($upstream_status != 200) {
            return 503;
        }
    }
}
```

### Envoy Integration

```nginx
# nginx.conf - Envoy sidecar integration
http {
    # Envoy sidecar proxy
    upstream service_mesh {
        server localhost:9901;  # Envoy admin port
        keepalive 32;
    }
    
    server {
        location /api/ {
            # Route through Envoy
            proxy_pass http://service_mesh/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Envoy headers
            proxy_set_header X-Envoy-Original-Path $request_uri;
            proxy_set_header X-Envoy-Expected-Rq-Timeout-ms 30000;
            
            # Service mesh integration
            proxy_set_header X-Service-Mesh "envoy";
            proxy_set_header X-Service-Version $envoy_service_version;
        }
    }
}
```

## P7.7 Traffic Mirroring and Shadow Testing

### Mirror Traffic

```nginx
# nginx.conf - Traffic mirroring
http {
    # Mirror upstreams
    upstream backend_primary {
        server primary:8000;
        keepalive 32;
    }
    
    upstream backend_mirror {
        server mirror:8000;
        keepalive 32;
    }
    
    server {
        location /api/ {
            # Primary traffic
            proxy_pass http://backend_primary/;
            
            # Mirror traffic (shadow testing)
            mirror /mirror-api;
            mirror_request_body on;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Mirror endpoint (internal)
        location = /mirror-api {
            internal;
            
            proxy_pass http://backend_mirror$request_uri;
            
            # Mirror headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Mirrored "true";
            proxy_set_header X-Original-Request-ID $request_id;
            
            # Disable logging for mirror traffic
            access_log off;
            
            # Don't wait for mirror response
            proxy_connect_timeout 1s;
            proxy_read_timeout 1s;
            proxy_send_timeout 1s;
        }
    }
}
```

---

This primer provides a comprehensive deep dive into advanced traffic management with Nginx. Use these techniques to build sophisticated routing, load balancing, and traffic control systems for your applications.
