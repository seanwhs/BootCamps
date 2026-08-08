# Primer 8: Microservices & API Gateway Patterns

## The Target

This primer provides a comprehensive, deep-dive guide to using Nginx as an API gateway and microservices router. Understanding these patterns is essential for building modern, scalable microservices architectures.

## P8.1 API Gateway Fundamentals

### API Gateway Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    API GATEWAY ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐                                                           │
│  │   Client    │                                                           │
│  │  (Browser,  │                                                           │
│  │   Mobile)   │                                                           │
│  └──────┬──────┘                                                           │
│         │                                                                  │
│         ▼                                                                  │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                       API GATEWAY (Nginx)                        │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌───────────┐ │      │
│  │  │   Routing  │  │    Auth    │  │  Rate      │  │   Caching │ │      │
│  │  │            │  │            │  │  Limiting  │  │           │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └───────────┘ │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌───────────┐ │      │
│  │  │   Logging  │  │  Circuit   │  │   Request  │  │  Response │ │      │
│  │  │            │  │  Breaker   │  │  Validation│  │  Transform│ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └───────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│         │                                                                  │
│         ▼                                                                  │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Auth   │  │ Users  │  │ Orders │  │Products│  │Payment │           │
│  │Service │  │Service │  │Service │  │Service │  │Service │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete API Gateway Configuration

```nginx
# nginx.conf - Complete API Gateway
http {
    # ------------------------------------------------------------------------
    # Upstream Services
    # ------------------------------------------------------------------------
    upstream auth_service {
        server auth:8001 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream users_service {
        server users:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream orders_service {
        server orders:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream products_service {
        server products:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream payments_service {
        server payments:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # ------------------------------------------------------------------------
    # Rate Limiting
    # ------------------------------------------------------------------------
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;
    
    # ------------------------------------------------------------------------
    # API Gateway Server
    # ------------------------------------------------------------------------
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/api.crt;
        ssl_certificate_key /etc/nginx/ssl/api.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header Content-Security-Policy "default-src 'self';" always;
        
        # Global Rate Limiting
        limit_req zone=global burst=20 nodelay;
        
        # --------------------------------------------------------------------
        # Authentication Routes
        # --------------------------------------------------------------------
        location /auth/ {
            limit_req zone=auth burst=2 nodelay;
            
            proxy_pass http://auth_service/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # User Routes
        # --------------------------------------------------------------------
        location /users/ {
            # Authentication check
            auth_request /auth/validate;
            
            proxy_pass http://users_service/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Order Routes
        # --------------------------------------------------------------------
        location /orders/ {
            auth_request /auth/validate;
            
            proxy_pass http://orders_service/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Product Routes (Public)
        # --------------------------------------------------------------------
        location /products/ {
            limit_req zone=api burst=10 nodelay;
            
            # Enable caching
            proxy_cache api_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 5m;
            proxy_cache_use_stale error timeout updating;
            
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://products_service/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Payment Routes
        # --------------------------------------------------------------------
        location /payments/ {
            auth_request /auth/validate;
            
            # Strict rate limiting for payments
            limit_req zone=api burst=5;
            
            proxy_pass http://payments_service/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # Auth Validation Endpoint
        # --------------------------------------------------------------------
        location = /auth/validate {
            internal;
            
            proxy_pass http://auth_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            
            # Capture user ID from auth response
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # If auth fails, return 401
            proxy_intercept_errors on;
            error_page 401 = /auth/error;
        }
        
        # --------------------------------------------------------------------
        # Auth Error Handler
        # --------------------------------------------------------------------
        location = /auth/error {
            return 401 '{"error":"Authentication required"}';
            add_header Content-Type application/json;
        }
    }
}
```

## P8.2 Request Validation & Transformation

### Request Validation Gateway

```nginx
# nginx.conf - Request validation gateway
http {
    # Validators for each service
    map $content_type $is_valid_json {
        default 0;
        "application/json" 1;
        "application/x-www-form-urlencoded" 1;
    }
    
    map $request_uri $has_valid_path {
        default 0;
        ~^/(auth|users|orders|products|payments)/[a-zA-Z0-9_-]+$ 1;
        ~^/(auth|users|orders|products|payments)$ 1;
    }
    
    server {
        location /api/ {
            # Validate path
            if ($has_valid_path = 0) {
                return 404 '{"error":"Invalid path"}';
            }
            
            # Validate content type for POST/PUT
            if ($request_method = POST) {
                if ($content_type !~ "application/json") {
                    return 415 '{"error":"Content-Type must be application/json"}';
                }
            }
            
            # Validate body size
            if ($content_length > 1000000) {
                return 413 '{"error":"Request too large"}';
            }
            
            # Validate query parameters
            if ($query_string ~* "(union|select|exec|eval)") {
                return 400 '{"error":"Invalid query parameters"}';
            }
            
            # Validate headers
            if ($http_x_request_id = "") {
                return 400 '{"error":"X-Request-ID header required"}';
            }
            
            proxy_pass http://backend/;
        }
    }
}
```

### Response Transformation

```nginx
# nginx.conf - Response transformation
http {
    # Substitution filters
    location /api/ {
        proxy_pass http://backend/;
        
        # Transform JSON responses
        sub_filter 'old_field' 'new_field';
        sub_filter_once off;
        sub_filter_types application/json;
        
        # Add response headers
        add_header X-API-Version "2.0";
        add_header X-Response-Time $request_time;
        
        # Remove sensitive headers
        proxy_hide_header Server;
        proxy_hide_header X-Powered-By;
        
        # Cache control
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        
        # CORS headers
        add_header Access-Control-Allow-Origin "*";
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID";
        
        # Handle preflight requests
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*";
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID";
            add_header Content-Length 0;
            return 204;
        }
    }
}
```

## P8.3 Circuit Breaker Pattern

### Circuit Breaker Implementation

```nginx
# nginx.conf - Circuit breaker with Nginx
http {
    upstream backend {
        zone backend 64k;
        
        server backend1:8000 max_fails=3 fail_timeout=30s;
        server backend2:8000 max_fails=3 fail_timeout=30s;
        server backend3:8000 max_fails=3 fail_timeout=30s;
        
        # Failure detection
        server backend1:8000 max_fails=3 fail_timeout=30s;
        server backend2:8000 max_fails=3 fail_timeout=30s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://backend/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
    }
    
    # Circuit breaker with fallback
    location /api/ {
        # Check circuit status
        set $circuit_open 0;
        
        # Check upstream health
        if ($upstream_addr = "") {
            set $circuit_open 1;
        }
        
        # Return fallback if circuit open
        if ($circuit_open) {
            return 503 '{"error":"Service temporarily unavailable"}';
        }
        
        proxy_pass http://backend/;
        
        # Error handling
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 2;
        
        # Fallback on failure
        proxy_intercept_errors on;
        error_page 502 503 504 = @fallback;
    }
    
    # Fallback response
    location @fallback {
        return 503 '{"error":"Service temporarily unavailable","retry_after":"30s"}';
        add_header Content-Type application/json;
        add_header Retry-After 30;
    }
}
```

## P8.4 Service Discovery

### Dynamic Service Discovery

```nginx
# nginx.conf - Dynamic service discovery with Consul
http {
    # DNS resolver with Consul
    resolver 127.0.0.11 valid=10s;
    resolver_timeout 5s;
    
    # Dynamic upstreams
    upstream auth {
        server auth.service.consul:8001 resolve;
        server auth2.service.consul:8001 resolve;
        keepalive 32;
    }
    
    upstream users {
        server users.service.consul:8002 resolve;
        server users2.service.consul:8002 resolve;
        keepalive 32;
    }
    
    upstream orders {
        server orders.service.consul:8003 resolve;
        server orders2.service.consul:8003 resolve;
        keepalive 32;
    }
    
    # Health check endpoint
    location /health/service {
        proxy_pass http://consul:8500/v1/health/service/$arg_service;
        proxy_set_header Host $host;
        
        # Convert Consul health status
        set $service_status "healthy";
        
        if ($upstream_status != 200) {
            set $service_status "unhealthy";
        }
        
        return 200 '{"status":"$service_status"}';
    }
}
```

## P8.5 API Versioning

### Version-Based Routing

```nginx
# nginx.conf - API versioning
http {
    # Version-specific upstreams
    upstream api_v1 {
        server api-v1:8000;
        keepalive 32;
    }
    
    upstream api_v2 {
        server api-v2:8001;
        keepalive 32;
    }
    
    upstream api_v3 {
        server api-v3:8002;
        keepalive 32;
    }
    
    # Version mapping
    map $http_accept $api_version {
        default "v1";
        ~*"version=v2" "v2";
        ~*"version=v3" "v3";
    }
    
    # URL versioning
    map $request_uri $version_from_url {
        default "";
        ~^/v1/ "v1";
        ~^/v2/ "v2";
        ~^/v3/ "v3";
    }
    
    server {
        # Header-based versioning
        location /api/ {
            # Determine version
            set $version $api_version;
            
            # Override with URL version
            if ($version_from_url != "") {
                set $version $version_from_url;
            }
            
            # Route to appropriate version
            if ($version = "v1") {
                proxy_pass http://api_v1/;
                add_header X-API-Version "v1";
            }
            if ($version = "v2") {
                proxy_pass http://api_v2/;
                add_header X-API-Version "v2";
            }
            if ($version = "v3") {
                proxy_pass http://api_v3/;
                add_header X-API-Version "v3";
            }
            
            # Default to v1
            if ($version = "") {
                proxy_pass http://api_v1/;
                add_header X-API-Version "v1";
            }
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Version $version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # URL versioning
        location ~ ^/(v1|v2|v3)/(.*)$ {
            set $version $1;
            set $service_path $2;
            
            if ($version = "v1") {
                proxy_pass http://api_v1/$service_path$is_args$args;
            }
            if ($version = "v2") {
                proxy_pass http://api_v2/$service_path$is_args$args;
            }
            if ($version = "v3") {
                proxy_pass http://api_v3/$service_path$is_args$args;
            }
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Version $version;
        }
    }
}
```

## P8.6 Request Aggregation

### Aggregation Pattern

```nginx
# nginx.conf - Request aggregation with subrequests
http {
    # Lua configuration for aggregation
    lua_shared_dict response_cache 10m;
    
    server {
        location /api/dashboard {
            # Aggregation endpoint
            content_by_lua_block {
                local cjson = require("cjson")
                local http = require("resty.http")
                
                -- Create HTTP client
                local httpc = http.new()
                httpc:set_timeout(5000)
                
                -- Get authentication token
                local auth = ngx.var.http_authorization
                local headers = {
                    Authorization = auth,
                    ["Content-Type"] = "application/json",
                    ["X-Request-ID"] = ngx.var.request_id
                }
                
                -- Fetch data from multiple services in parallel
                local responses = {}
                local services = {
                    user = { host = "users:8002", path = "/me" },
                    orders = { host = "orders:8003", path = "/recent" },
                    products = { host = "products:8004", path = "/featured" }
                }
                
                -- Use ngx.thread for parallel requests
                local threads = {}
                
                for name, service in pairs(services) do
                    local thread = ngx.thread.spawn(function()
                        local res, err = httpc:request_uri(
                            "http://" .. service.host .. service.path,
                            { headers = headers }
                        )
                        
                        if res and res.status == 200 then
                            return cjson.decode(res.body)
                        end
                        return nil
                    end)
                    
                    threads[name] = thread
                end
                
                -- Wait for all threads
                for name, thread in pairs(threads) do
                    local ok, result = ngx.thread.wait(thread)
                    if ok and result then
                        responses[name] = result
                    else
                        responses[name] = { error = "Service unavailable" }
                    end
                end
                
                -- Combine responses
                local result = {
                    user = responses.user,
                    orders = responses.orders,
                    products = responses.products,
                    timestamp = os.time()
                }
                
                -- Add response headers
                ngx.header["X-Content-Type-Options"] = "nosniff"
                ngx.header["Cache-Control"] = "no-cache"
                
                -- Return combined response
                ngx.status = 200
                ngx.say(cjson.encode(result))
            }
        }
    }
}
```

## P8.7 Rate Limiting by Service

### Service-Specific Rate Limiting

```nginx
# nginx.conf - Service-specific rate limiting
http {
    # Rate limiting zones per service
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=users:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=orders:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=products:10m rate=200r/m;
    limit_req_zone $binary_remote_addr zone=payments:10m rate=10r/m;
    
    # Connection limits per service
    limit_conn_zone $binary_remote_addr zone=conn_auth:10m;
    limit_conn_zone $binary_remote_addr zone=conn_payments:10m;
    
    server {
        # Auth - strict limits
        location /auth/ {
            limit_req zone=auth burst=2 nodelay;
            limit_conn conn_auth 1;
            proxy_pass http://auth_service/;
        }
        
        # Users - moderate limits
        location /users/ {
            limit_req zone=users burst=10 nodelay;
            proxy_pass http://users_service/;
        }
        
        # Orders - high limits
        location /orders/ {
            limit_req zone=orders burst=20 nodelay;
            proxy_pass http://orders_service/;
        }
        
        # Products - high limits (cached)
        location /products/ {
            limit_req zone=products burst=30 nodelay;
            proxy_cache products_cache;
            proxy_pass http://products_service/;
        }
        
        # Payments - strict limits with connection limit
        location /payments/ {
            limit_req zone=payments burst=5 nodelay;
            limit_conn conn_payments 1;
            proxy_pass http://payments_service/;
        }
    }
}
```

---

This primer provides a comprehensive deep dive into using Nginx as an API gateway and microservices router. Use these patterns to build modern, scalable, and resilient microservices architectures.
