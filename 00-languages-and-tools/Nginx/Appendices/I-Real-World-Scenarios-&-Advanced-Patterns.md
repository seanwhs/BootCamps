# Appendix I: Real-World Scenarios & Advanced Patterns

## The Target

This appendix covers real-world production scenarios and advanced Nginx patterns that you'll encounter in complex environments. Each scenario includes a problem statement, solution, and complete configuration.

## I.1 Multi-Domain Hosting

### Scenario: Host Multiple Domains on One Nginx

**Problem:** You need to serve multiple domains (example.com, api.example.com, admin.example.com) from the same Nginx instance.

**Solution:**

```nginx
# nginx.conf
http {
    # Common settings
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Upstream groups for different domains
    upstream example_com {
        server app1:3000;
        server app2:3000;
        keepalive 32;
    }
    
    upstream api_example_com {
        server api1:8000;
        server api2:8000;
        keepalive 32;
    }
    
    upstream admin_example_com {
        server admin1:5000;
        server admin2:5000;
        keepalive 32;
    }
    
    # Main domain - example.com
    server {
        listen 443 ssl http2;
        server_name example.com www.example.com;
        
        ssl_certificate /etc/nginx/ssl/example.com/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/example.com/privkey.pem;
        
        location / {
            proxy_pass http://example_com;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    
    # API subdomain - api.example.com
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        ssl_certificate /etc/nginx/ssl/api.example.com/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/api.example.com/privkey.pem;
        
        location / {
            proxy_pass http://api_example_com;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    
    # Admin subdomain - admin.example.com
    server {
        listen 443 ssl http2;
        server_name admin.example.com;
        
        ssl_certificate /etc/nginx/ssl/admin.example.com/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/admin.example.com/privkey.pem;
        
        location / {
            proxy_pass http://admin_example_com;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    
    # HTTP to HTTPS redirect for all domains
    server {
        listen 80;
        server_name example.com www.example.com api.example.com admin.example.com;
        return 301 https://$host$request_uri;
    }
}
```

### Dynamic Domain Routing

```nginx
# Map domain to upstream
http {
    map $host $backend {
        default backend_default:8000;
        api.example.com api_backend:8000;
        admin.example.com admin_backend:5000;
        ~^dev-.*\.example\.com$ dev_backend:3000;
    }
    
    server {
        listen 443 ssl http2;
        server_name *.example.com;
        
        ssl_certificate /etc/nginx/ssl/wildcard/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/wildcard/privkey.pem;
        
        location / {
            proxy_pass http://$backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## I.2 A/B Testing and Canary Deployments

### Scenario: Gradually Roll Out New Features

**Problem:** You want to test a new version with 10% of users before full deployment.

**Solution:**

```nginx
# nginx.conf
http {
    # Upstream groups
    upstream api_v1 {
        server api-v1:8000 weight=9;  # 90% traffic
        keepalive 32;
    }
    
    upstream api_v2 {
        server api-v2:8000 weight=1;  # 10% traffic
        keepalive 32;
    }
    
    # Split traffic using cookie or header
    split_clients $remote_addr $upstream_backend {
        10%   api_v2;
        *     api_v1;
    }
    
    # Or use cookie-based routing
    map $cookie_ab_test $ab_backend {
        default api_v1;
        "v2" api_v2;
        "v1" api_v1;
    }
    
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        # Method 1: Random split
        location /api/ {
            proxy_pass http://$upstream_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Version "v1";
            
            # Add cookie for stickyness
            add_header Set-Cookie "ab_test=$cookie_ab_test; Path=/; Max-Age=3600";
        }
        
        # Method 2: Header-based routing (for API testing)
        location /api/ {
            if ($http_x_ab_test = "v2") {
                proxy_pass http://api_v2/;
                proxy_set_header X-Version "v2";
            }
            
            proxy_pass http://api_v1/;
            proxy_set_header X-Version "v1";
        }
    }
}
```

### Canary Deployment with Gradual Rollout

```nginx
# Gradually increase traffic to new version
http {
    upstream api_canary {
        server api-v1:8000;
        server api-v2:8000 weight=0;  # Start at 0%
    }
    
    server {
        # Rollout script updates this block
        location /api/ {
            proxy_pass http://api_canary/;
            proxy_set_header Host $host;
            
            # Weight can be changed via API or config reload
        }
    }
}
```

**Rollout Script:**

```bash
#!/bin/bash
# canary-rollout.sh - Gradually increase canary weight

WEIGHT=$1
if [ -z "$WEIGHT" ]; then
    echo "Usage: $0 <weight>"
    exit 1
fi

# Update nginx configuration
sed -i "s/weight=[0-9]*/weight=$WEIGHT/" nginx.conf

# Reload Nginx
nginx -t && nginx -s reload

echo "Canary traffic set to $WEIGHT%"
```

## I.3 Geographic Routing

### Scenario: Route Traffic Based on User Location

**Problem:** You have servers in US, EU, and Asia and want to route users to the nearest datacenter.

**Solution:**

```nginx
# nginx.conf
http {
    # GeoIP database (requires geoip module)
    geoip_country /usr/share/GeoIP/GeoIP.dat;
    geoip_city /usr/share/GeoIP/GeoLiteCity.dat;
    
    # Map country to datacenter
    map $geoip_country_code $datacenter {
        default us-east;
        US us-east;
        CA us-east;
        DE eu-west;
        FR eu-west;
        UK eu-west;
        JP ap-northeast;
        AU ap-southeast;
    }
    
    # Upstream groups per region
    upstream us-east {
        server us-1:8000;
        server us-2:8000;
        keepalive 32;
    }
    
    upstream eu-west {
        server eu-1:8000;
        server eu-2:8000;
        keepalive 32;
    }
    
    upstream ap-northeast {
        server ap-1:8000;
        server ap-2:8000;
        keepalive 32;
    }
    
    upstream ap-southeast {
        server au-1:8000;
        server au-2:8000;
        keepalive 32;
    }
    
    server {
        listen 443 ssl http2;
        server_name example.com;
        
        location /api/ {
            # Route based on country
            proxy_pass http://$datacenter/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Geo-Country $geoip_country_code;
            proxy_set_header X-Geo-City $geoip_city;
        }
    }
}
```

## I.4 API Gateway Pattern

### Scenario: Build a Complete API Gateway

**Problem:** You need a unified entry point for all microservices with authentication, rate limiting, and routing.

**Solution:**

```nginx
# nginx.conf - Complete API Gateway
http {
    # Rate limiting for different tiers
    limit_req_zone $binary_remote_addr zone=free:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=basic:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=premium:10m rate=1000r/m;
    
    # API key validation
    map $http_x_api_key $api_tier {
        default free;
        "key-free-123" free;
        "key-basic-456" basic;
        "key-premium-789" premium;
    }
    
    # Service discovery (via DNS)
    upstream auth_service {
        server auth:8001;
        keepalive 32;
    }
    
    upstream users_service {
        server users:8002;
        keepalive 32;
    }
    
    upstream orders_service {
        server orders:8003;
        keepalive 32;
    }
    
    upstream products_service {
        server products:8004;
        keepalive 32;
    }
    
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        # Global rate limiting by tier
        location / {
            # Apply rate limit based on API key
            limit_req zone=$api_tier burst=10 nodelay;
            
            # Validate API key
            if ($http_x_api_key = "") {
                return 401 "{\"error\":\"API key required\"}";
            }
            
            # Route based on path
            rewrite ^/(auth|users|orders|products)/(.*)$ /$1/$2 break;
        }
        
        # Authentication routes
        location /auth/ {
            proxy_pass http://auth_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
        }
        
        # Users routes
        location /users/ {
            proxy_pass http://users_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
        }
        
        # Orders routes
        location /orders/ {
            proxy_pass http://orders_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
        }
        
        # Products routes
        location /products/ {
            proxy_pass http://products_service/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
        }
    }
}
```

## I.5 Microservices Aggregation

### Scenario: Aggregate Multiple Microservices in One Request

**Problem:** Frontend needs data from multiple services; you want to reduce round trips.

**Solution:**

```nginx
# nginx.conf - Request aggregation using subrequests
http {
    # Upstream services
    upstream users { server users:8000; keepalive 32; }
    upstream orders { server orders:8001; keepalive 32; }
    upstream products { server products:8002; keepalive 32; }
    
    server {
        listen 443 ssl http2;
        server_name api.example.com;
        
        # Aggregated endpoint
        location /api/dashboard {
            # Use subrequests to fetch from multiple services
            auth_request /auth/validate;
            
            # Set up variables for subrequests
            set $user_data "";
            set $order_data "";
            set $product_data "";
            
            # Fetch user data
            subrequest /internal/users/me {
                proxy_pass http://users/me;
                proxy_set_header Authorization $http_authorization;
                body_filter @set_user_data;
            }
            
            # Fetch orders
            subrequest /internal/orders/recent {
                proxy_pass http://orders/recent;
                proxy_set_header Authorization $http_authorization;
                body_filter @set_order_data;
            }
            
            # Fetch products
            subrequest /internal/products/featured {
                proxy_pass http://products/featured;
                body_filter @set_product_data;
            }
            
            # Combine results
            return 200 '{"user": $user_data, "orders": $order_data, "products": $product_data}';
        }
    }
}
```

**Alternative: Using Lua for Aggregation**

```nginx
# nginx.conf with Lua module
http {
    lua_shared_dict response_cache 10m;
    
    server {
        location /api/dashboard {
            content_by_lua_block {
                -- Fetch from multiple services
                local http = require("resty.http")
                local cjson = require("cjson")
                
                -- Create HTTP client
                local httpc = http.new()
                httpc:set_timeout(5000)
                
                -- Parallel requests using cosocket
                local responses = {}
                
                local function fetch(service, path, headers)
                    local res, err = httpc:request_uri(
                        "http://" .. service .. "/" .. path,
                        { headers = headers }
                    )
                    if res then
                        return cjson.decode(res.body)
                    end
                    return nil
                end
                
                -- Fetch all services in parallel
                local user = fetch("users", "me", { Authorization = ngx.var.http_authorization })
                local orders = fetch("orders", "recent", { Authorization = ngx.var.http_authorization })
                local products = fetch("products", "featured", {})
                
                -- Combine responses
                local result = {
                    user = user,
                    orders = orders,
                    products = products
                }
                
                ngx.say(cjson.encode(result))
            }
        }
    }
}
```

## I.6 Rate Limiting with Different Tiers

### Scenario: Different Rate Limits for Different API Tiers

**Problem:** Free users get 10 req/min, Premium get 1000 req/min.

**Solution:**

```nginx
# nginx.conf - Tier-based rate limiting
http {
    # Shared dictionaries for rate limiting
    limit_req_zone $binary_remote_addr zone=free:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=basic:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=premium:10m rate=1000r/m;
    
    # API key to tier mapping
    map $http_x_api_key $api_tier {
        default free;
        ~^free_ free;
        ~^basic_ basic;
        ~^premium_ premium;
    }
    
    # Dynamic rate limiting
    server {
        location /api/ {
            # Apply different limits based on tier
            if ($api_tier = "premium") {
                limit_req zone=premium burst=50 nodelay;
                set $rate_limit 1000r/m;
            }
            if ($api_tier = "basic") {
                limit_req zone=basic burst=10 nodelay;
                set $rate_limit 100r/m;
            }
            if ($api_tier = "free") {
                limit_req zone=free burst=2 nodelay;
                set $rate_limit 10r/m;
            }
            
            # Add rate limit headers
            add_header X-RateLimit-Limit $rate_limit;
            add_header X-RateLimit-Remaining $limit_req_remaining;
            add_header X-RateLimit-Reset $limit_req_reset;
            
            proxy_pass http://backend/;
            proxy_set_header X-API-Tier $api_tier;
        }
    }
}
```

## I.7 WebSocket and SSE with Authentication

### Scenario: Secure Real-Time Connections

**Problem:** WebSocket and SSE connections need authentication.

**Solution:**

```nginx
# nginx.conf - Authenticated real-time connections
http {
    # Authentication service
    upstream auth {
        server auth:8001;
        keepalive 32;
    }
    
    # WebSocket with auth
    server {
        location /ws/ {
            # Validate authentication before upgrade
            auth_request /auth/validate;
            auth_request_set $auth_status $upstream_status;
            
            # If auth fails, return 401
            if ($auth_status != 200) {
                return 401;
            }
            
            # Proxy to WebSocket backend
            proxy_pass http://websocket/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_read_timeout 300s;
            proxy_buffering off;
        }
        
        # SSE with auth
        location /sse/ {
            # Validate authentication
            auth_request /auth/validate;
            auth_request_set $auth_status $upstream_status;
            
            if ($auth_status != 200) {
                return 401;
            }
            
            proxy_pass http://sse/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_buffering off;
            proxy_set_header X-Accel-Buffering no;
            proxy_read_timeout 600s;
        }
        
        # Auth validation endpoint
        location = /auth/validate {
            internal;
            proxy_pass http://auth/validate;
            proxy_pass_request_body off;
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            
            # Capture user ID from auth response
            auth_request_set $auth_user_id $upstream_http_x_user_id;
        }
    }
}
```

## I.8 Advanced Caching Strategies

### Scenario: Cache Different Content with Different Strategies

**Problem:** Different types of content need different caching strategies (HTML, API, images, etc.).

**Solution:**

```nginx
# nginx.conf - Multi-level caching
http {
    # Cache zones
    proxy_cache_path /var/cache/nginx/html_cache
        levels=1:2 keys_zone=html_cache:50m max_size=1g inactive=1h;
    
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2 keys_zone=api_cache:100m max_size=2g inactive=5m;
    
    proxy_cache_path /var/cache/nginx/image_cache
        levels=1:2 keys_zone=image_cache:200m max_size=5g inactive=30d;
    
    proxy_cache_path /var/cache/nginx/fragment_cache
        levels=1:2 keys_zone=fragment_cache:50m max_size=500m inactive=10m;
    
    server {
        # HTML pages - cache by URL and headers
        location / {
            proxy_cache html_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            
            proxy_pass http://web/;
            proxy_set_header Host $host;
        }
        
        # API - short cache with validation
        location /api/ {
            proxy_cache api_cache;
            proxy_cache_key $scheme$host$request_uri$http_authorization;
            proxy_cache_valid 200 302 1m;
            proxy_cache_valid 204 304 30s;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_revalidate on;
            
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://api/;
            proxy_set_header Host $host;
        }
        
        # Images - long cache
        location ~* \.(jpg|jpeg|png|gif|ico|svg)$ {
            proxy_cache image_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            
            expires 30d;
            add_header Cache-Control "public, immutable";
            
            proxy_pass http://static/;
            proxy_set_header Host $host;
        }
        
        # Edge-side includes (ESI) - fragment caching
        location /fragment/ {
            proxy_cache fragment_cache;
            proxy_cache_key $scheme$host$request_uri$cookie_user_id;
            proxy_cache_valid 200 302 5m;
            
            # Don't cache authenticated fragments
            proxy_no_cache $cookie_sessionid;
            proxy_cache_bypass $cookie_sessionid;
            
            proxy_pass http://fragment/;
            proxy_set_header Host $host;
        }
    }
}
```

## I.9 Graceful Downtime and Maintenance

### Scenario: Show Maintenance Page During Deployments

**Problem:** You need to display a maintenance page while deploying new versions.

**Solution:**

```nginx
# nginx.conf - Maintenance mode
http {
    # Maintenance mode flag (can be toggled)
    set $maintenance_mode 0;
    
    # Maintenance page location
    location /maintenance {
        root /var/www/html;
        try_files /maintenance.html /index.html;
    }
    
    server {
        listen 443 ssl http2;
        server_name example.com;
        
        # Check for maintenance mode
        if ($maintenance_mode) {
            return 503;
        }
        
        # Custom error page for maintenance
        error_page 503 @maintenance;
        location @maintenance {
            rewrite ^ /maintenance last;
        }
        
        # Normal requests
        location / {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

**Toggle Maintenance Script:**

```bash
#!/bin/bash
# maintenance-toggle.sh

MODE=$1

if [ "$MODE" = "on" ]; then
    sed -i 's/set $maintenance_mode 0/set $maintenance_mode 1/' nginx.conf
    echo "Maintenance mode enabled"
elif [ "$MODE" = "off" ]; then
    sed -i 's/set $maintenance_mode 1/set $maintenance_mode 0/' nginx.conf
    echo "Maintenance mode disabled"
else
    echo "Usage: $0 [on|off]"
    exit 1
fi

nginx -t && nginx -s reload
```

## I.10 Request Throttling and Queueing

### Scenario: Throttle Requests and Queue Excess

**Problem:** You need to handle traffic spikes without overwhelming the backend.

**Solution:**

```nginx
# nginx.conf - Request throttling
http {
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=throttle:10m rate=100r/s;
    
    # Queue requests beyond rate limit
    server {
        location /api/ {
            # Allow burst of 50, queue the rest
            limit_req zone=throttle burst=50 nodelay;
            
            # Queue requests if backend is busy
            proxy_pass http://backend/;
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Backend connection limits
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Queue configuration
            proxy_queue_limit 100;
            proxy_queue_timeout 30s;
            
            # Health check
            proxy_next_upstream error timeout invalid_header http_500 http_502;
            proxy_next_upstream_tries 3;
        }
    }
}
```

---

This appendix covers advanced real-world scenarios that you'll encounter in production environments. Each pattern is battle-tested and can be adapted to your specific use case.
