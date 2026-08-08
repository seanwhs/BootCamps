# Primer 19: Nginx for Serverless & Edge Computing

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for serverless architectures and edge computing. Understanding these concepts is essential for building modern, distributed applications with low latency and high performance.

## P19.1 Serverless Architecture with Nginx

### Serverless Integration Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SERVERLESS ARCHITECTURE WITH NGINX                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX SERVERLESS GATEWAY                      │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ROUTING LAYER                           │ │      │
│  │  │  • Function Routing  • Event Triggers   • Webhooks        │ │      │
│  │  │  • API Gateway       • Request Routing  • Load Balancing │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EXECUTION LAYER                         │ │      │
│  │  │  • Function Invocation  • Cold Start Management           │ │      │
│  │  │  • Warm Pool            • Function Scaling               │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EDGE LAYER                              │ │      │
│  │  │  • Edge Compute       • CDN Integration                   │ │      │
│  │  │  • Geo Distribution   • Local Processing                  │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ AWS    │  │ Azure  │  │ Google │  │ Cloud  │  │ Edge   │           │
│  │ Lambda │  │Functions│  │ Cloud  │  │flare   │  │Nodes   │           │
│  │        │  │        │  │Functions│  │Workers │  │        │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Serverless Gateway Configuration

```nginx
# nginx-serverless.conf - Serverless Gateway
# ============================================================================
# NGINX SERVERLESS GATEWAY
# Complete production-ready serverless configuration
# ============================================================================

http {
    # =========================================================================
    # FUNCTION MAPPING
    # =========================================================================
    
    # Map URL paths to serverless functions
    map $request_uri $function_name {
        default "default";
        ~^/api/users "users-function";
        ~^/api/orders "orders-function";
        ~^/api/products "products-function";
        ~^/api/payments "payments-function";
        ~^/api/notifications "notifications-function";
    }

    # Map HTTP methods to function actions
    map $request_method $function_action {
        default "execute";
        GET "get";
        POST "create";
        PUT "update";
        DELETE "delete";
    }

    # =========================================================================
    # SERVERLESS UPSTREAMS
    # =========================================================================
    
    # AWS Lambda
    upstream aws_lambda {
        # AWS Lambda API endpoint
        server lambda.us-east-1.amazonaws.com:443;
        keepalive 32;
    }

    # Azure Functions
    upstream azure_functions {
        # Azure Functions endpoint
        server functions.azure.com:443;
        keepalive 32;
    }

    # Google Cloud Functions
    upstream gcp_functions {
        # GCP Functions endpoint
        server cloudfunctions.googleapis.com:443;
        keepalive 32;
    }

    # Cloudflare Workers
    upstream cloudflare_workers {
        # Cloudflare Workers endpoint
        server workers.cloudflare.com:443;
        keepalive 32;
    }

    # =========================================================================
    # FUNCTION ROUTER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name serverless.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/serverless.crt;
        ssl_certificate_key /etc/nginx/ssl/serverless.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # --------------------------------------------------------------------
        # FUNCTION INVOCATION
        # --------------------------------------------------------------------
        location /api/ {
            # Rate limiting for serverless functions
            limit_req zone=api burst=20 nodelay;
            limit_conn conn_limit 10;

            # Set function execution parameters
            set $function_provider "aws";
            set $function_timeout 30s;

            # Route to appropriate serverless provider
            if ($http_x_function_provider) {
                set $function_provider $http_x_function_provider;
            }

            # AWS Lambda
            if ($function_provider = "aws") {
                proxy_pass https://aws_lambda/2015-03-31/functions/$function_name/invocations;
                proxy_set_header X-Amz-Invocation-Type RequestResponse;
                proxy_set_header X-Amz-Log-Type Tail;
            }

            # Azure Functions
            if ($function_provider = "azure") {
                proxy_pass https://azure_functions/api/$function_name;
                proxy_set_header x-functions-key $http_x_functions_key;
            }

            # Google Cloud Functions
            if ($function_provider = "gcp") {
                proxy_pass https://gcp_functions/v1/projects/$project/locations/$location/functions/$function_name:execute;
                proxy_set_header Authorization "Bearer $http_x_gcp_id_token";
            }

            # Cloudflare Workers
            if ($function_provider = "cloudflare") {
                proxy_pass https://cloudflare_workers/$function_name;
                proxy_set_header CF-Access-Client-Id $http_x_cf_client_id;
                proxy_set_header CF-Access-Client-Secret $http_x_cf_client_secret;
            }

            # Common headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Content-Type application/json;

            # Function execution headers
            proxy_set_header X-Function-Name $function_name;
            proxy_set_header X-Function-Action $function_action;
            proxy_set_header X-Function-Time $function_timeout;

            # Timeouts for serverless functions
            proxy_connect_timeout 5s;
            proxy_read_timeout $function_timeout;
            proxy_send_timeout $function_timeout;

            # Cache control
            proxy_cache_bypass 1;
            proxy_no_cache 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }

        # --------------------------------------------------------------------
        # FUNCTION STATUS
        # --------------------------------------------------------------------
        location /status/ {
            # Function status endpoint
            proxy_pass https://aws_lambda/2015-03-31/functions/$function_name/status;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # Cache for 30s
            expires 30s;
        }
    }
}
```

## P19.2 Edge Computing

### Edge Computing Configuration

```nginx
# nginx-edge-compute.conf - Edge Computing
# ============================================================================
# NGINX EDGE COMPUTING
# Complete production-ready edge configuration
# ============================================================================

http {
    # =========================================================================
    # GEO-DISTRIBUTED ROUTING
    # =========================================================================
    
    # GeoIP database for edge routing
    geoip_country /usr/share/GeoIP/GeoIP.dat;
    geoip_city /usr/share/GeoIP/GeoLiteCity.dat;

    # Map country to edge location
    map $geoip_country_code $edge_location {
        default edge-us;
        US edge-us;
        CA edge-us;
        DE edge-eu;
        FR edge-eu;
        UK edge-eu;
        JP edge-ap;
        AU edge-ap;
        BR edge-sa;
    }

    # Map to edge endpoint
    map $edge_location $edge_endpoint {
        default "https://edge-us.example.com";
        edge-us "https://edge-us.example.com";
        edge-eu "https://edge-eu.example.com";
        edge-ap "https://edge-ap.example.com";
        edge-sa "https://edge-sa.example.com";
    }

    # =========================================================================
    # EDGE COMPUTE NODES
    # =========================================================================
    
    upstream edge_us {
        server edge-us:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    upstream edge_eu {
        server edge-eu:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    upstream edge_ap {
        server edge-ap:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    upstream edge_sa {
        server edge-sa:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    # =========================================================================
    # EDGE GATEWAY
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name edge.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/edge.crt;
        ssl_certificate_key /etc/nginx/ssl/edge.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # --------------------------------------------------------------------
        # EDGE ROUTING
        # --------------------------------------------------------------------
        location / {
            # Route to nearest edge location
            proxy_pass http://$edge_location/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Edge-Location $edge_location;
            proxy_set_header X-Geo-Country $geoip_country_code;
            proxy_set_header X-Geo-City $geoip_city;
        }
    }
}
```

## P19.3 Edge Workers

### Edge Worker Configuration

```lua
# nginx-edge-worker.lua - Edge Worker Implementation
# ============================================================================
# NGINX EDGE WORKER
# Serverless compute at the edge
# ============================================================================

-- Edge Worker Module
local edge_worker = {}

-- Worker configuration
edge_worker.config = {
    timeout = 30000,  -- 30 seconds
    memory = 128,     -- 128 MB
    cpu = 1,          -- 1 vCPU
}

-- Request handler
function edge_worker.handle_request(request)
    local response = {}
    
    -- Extract request details
    local method = request:get_method()
    local uri = request:get_uri()
    local headers = request:get_headers()
    local body = request:get_body()
    
    -- Route based on path
    if uri:match("^/api/") then
        response = edge_worker.handle_api(request)
    elseif uri:match("^/static/") then
        response = edge_worker.handle_static(request)
    elseif uri:match("^/auth/") then
        response = edge_worker.handle_auth(request)
    else
        response = edge_worker.handle_default(request)
    end
    
    return response
end

-- API handler
function edge_worker.handle_api(request)
    -- Parse request body
    local body = request:get_body()
    local data = cjson.decode(body)
    
    -- Process request
    local result = {}
    result.timestamp = os.time()
    result.request_id = request:get_header("X-Request-ID")
    result.data = data
    
    -- Add caching headers
    local response = {
        status = 200,
        headers = {
            ["Content-Type"] = "application/json",
            ["Cache-Control"] = "public, max-age=300",
            ["X-Edge-Worker"] = "true"
        },
        body = cjson.encode(result)
    }
    
    return response
end

-- Static handler
function edge_worker.handle_static(request)
    -- Serve from edge cache
    local uri = request:get_uri()
    local cache_key = "static:" .. uri
    
    -- Check cache
    local cached = edge_worker.cache_get(cache_key)
    if cached then
        return {
            status = 200,
            headers = {
                ["Content-Type"] = "text/plain",
                ["Cache-Control"] = "public, max-age=86400, immutable",
                ["X-Cache"] = "HIT",
                ["X-Edge-Worker"] = "true"
            },
            body = cached
        }
    end
    
    -- Fetch from origin
    local origin_response = edge_worker.fetch_origin(request)
    
    -- Cache response
    if origin_response.status == 200 then
        edge_worker.cache_set(cache_key, origin_response.body, 86400)
    end
    
    return origin_response
end

-- Auth handler
function edge_worker.handle_auth(request)
    -- Validate JWT
    local auth_header = request:get_header("Authorization")
    if not auth_header then
        return {
            status = 401,
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = '{"error":"Missing authorization header"}'
        }
    end
    
    -- Extract token
    local token = auth_header:gsub("^Bearer ", "")
    
    -- Validate token
    local valid, user = edge_worker.validate_jwt(token)
    if not valid then
        return {
            status = 401,
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = '{"error":"Invalid token"}'
        }
    end
    
    -- Forward to origin with user context
    local origin_response = edge_worker.fetch_origin(request)
    origin_response.headers["X-User-ID"] = user.id
    origin_response.headers["X-User-Role"] = user.role
    
    return origin_response
end

-- JWT validation
function edge_worker.validate_jwt(token)
    local jwt = require("resty.jwt")
    
    -- Validate signature
    local jwt_obj = jwt:verify("your-secret-key", token)
    if not jwt_obj.verified then
        return false, nil
    end
    
    -- Extract claims
    local user = {
        id = jwt_obj.payload.sub,
        email = jwt_obj.payload.email,
        role = jwt_obj.payload.role
    }
    
    return true, user
end

-- Cache operations
function edge_worker.cache_get(key)
    local cache = ngx.shared.edge_cache
    return cache:get(key)
end

function edge_worker.cache_set(key, value, ttl)
    local cache = ngx.shared.edge_cache
    cache:set(key, value, ttl)
end

-- Origin fetch
function edge_worker.fetch_origin(request)
    local http = require("resty.http")
    local httpc = http.new()
    
    httpc:set_timeout(edge_worker.config.timeout)
    
    local res, err = httpc:request_uri(
        "http://origin:8000" .. request:get_uri(),
        {
            method = request:get_method(),
            headers = request:get_headers(),
            body = request:get_body()
        }
    )
    
    if not res then
        return {
            status = 502,
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = '{"error":"Origin unavailable"}'
        }
    end
    
    return {
        status = res.status,
        headers = res.headers,
        body = res.body
    }
end

-- Register worker
ngx.ctx.edge_worker = edge_worker

-- Main request handler
ngx.req.read_body()

local request = {
    get_method = function() return ngx.var.request_method end,
    get_uri = function() return ngx.var.uri end,
    get_headers = function() return ngx.req.get_headers() end,
    get_body = function() return ngx.req.get_body_data() end,
    get_header = function(name) return ngx.req.get_headers()[name] end
}

local response = edge_worker.handle_request(request)

-- Send response
ngx.status = response.status
for key, value in pairs(response.headers) do
    ngx.header[key] = value
end
ngx.say(response.body)
```

## P19.4 Edge Cache Management

### Edge Cache Configuration

```nginx
# nginx-edge-cache.conf - Edge Cache Management
# ============================================================================
# NGINX EDGE CACHE
# Complete edge caching configuration
# ============================================================================

http {
    # =========================================================================
    # CACHE ZONES
    # =========================================================================
    
    # Global edge cache
    proxy_cache_path /var/cache/nginx/edge_cache
        levels=1:2
        keys_zone=edge_cache:200m
        max_size=20g
        inactive=30d
        use_temp_path=off
        manager_files=500
        manager_threshold=1000ms
        loader_files=500
        loader_threshold=1000ms;

    # API cache
    proxy_cache_path /var/cache/nginx/api_edge_cache
        levels=1:2
        keys_zone=api_edge_cache:50m
        max_size=2g
        inactive=1h
        use_temp_path=off;

    # =========================================================================
    # CACHE CONTROL
    # =========================================================================
    
    map $http_cache_control $bypass_cache {
        default 0;
        "no-cache" 1;
        "no-store" 1;
    }

    map $cookie_sessionid $cache_key_suffix {
        default "";
        "~^(.+)$" "-$1";
    }

    # =========================================================================
    # EDGE CACHE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name cache.edge.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/edge-cache.crt;
        ssl_certificate_key /etc/nginx/ssl/edge-cache.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # --------------------------------------------------------------------
        # CACHING HEADERS
        # --------------------------------------------------------------------
        location / {
            # Cache bypass
            proxy_cache_bypass $bypass_cache;
            proxy_no_cache $bypass_cache;
            
            # Cache settings
            proxy_cache edge_cache;
            proxy_cache_key $scheme$host$request_uri$cache_key_suffix;
            proxy_cache_valid 200 302 1h;
            proxy_cache_valid 304 30m;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            # Cache tags
            add_header X-Cache-Status $upstream_cache_status;
            add_header X-Cache-Key $proxy_cache_key;
            add_header X-Edge-Cache "true";
            
            # Browser cache
            expires 1h;
            add_header Cache-Control "public, max-age=3600";
            
            # Purge
            proxy_cache_purge $arg_purge;
            
            proxy_pass http://origin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Edge-Cache "true";
        }
    }
}
```

## P19.5 Edge Analytics

### Edge Analytics Configuration

```nginx
# nginx-edge-analytics.conf - Edge Analytics
# ============================================================================
# NGINX EDGE ANALYTICS
# Complete edge analytics configuration
# ============================================================================

http {
    # =========================================================================
    # ANALYTICS LOGGING
    # =========================================================================
    
    # Edge analytics log format
    log_format edge_analytics escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"request_id":"$request_id",'
        '"remote_addr":"$remote_addr",'
        '"edge_location":"$edge_location",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_response_time":$upstream_response_time,'
        '"cache_status":"$upstream_cache_status",'
        '"bytes_sent":$bytes_sent,'
        '"geoip_country":"$geoip_country_code",'
        '"geoip_city":"$geoip_city",'
        '"user_agent":"$http_user_agent",'
        '"referer":"$http_referer"'
    '}';

    access_log /var/log/nginx/edge_analytics.log edge_analytics;

    # =========================================================================
    # ANALYTICS PROCESSING
    # =========================================================================
    
    # Process analytics data
    location /analytics/ {
        internal;
        
        # Parse analytics data
        set $analytics_data "";
        
        # Aggregate stats
        if ($status = 200) {
            set $analytics_data "${analytics_data}success:1;";
        }
        if ($status >= 400) {
            set $analytics_data "${analytics_data}error:1;";
        }
        if ($upstream_cache_status = "HIT") {
            set $analytics_data "${analytics_data}cache:hit;";
        }
        if ($upstream_cache_status = "MISS") {
            set $analytics_data "${analytics_data}cache:miss;";
        }
        
        # Send to analytics backend
        proxy_pass http://analytics/ingest;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_body $analytics_data;
    }
}
```

### Edge Analytics Dashboard

```bash
#!/bin/bash
# edge-analytics.sh - Edge analytics dashboard

echo "=== Edge Analytics Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function: Get cache hit ratio
get_cache_hit_ratio() {
    local hits=$(tail -1000 /var/log/nginx/edge_analytics.log | grep -c '"cache_status":"HIT"')
    local total=$(tail -1000 /var/log/nginx/edge_analytics.log | wc -l)
    if [ $total -gt 0 ]; then
        echo "scale=2; $hits * 100 / $total" | bc
    else
        echo "0"
    fi
}

# Function: Get request distribution
get_request_distribution() {
    echo "Requests by Region:"
    tail -10000 /var/log/nginx/edge_analytics.log | \
        grep -o '"edge_location":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10
}

# Function: Get top endpoints
get_top_endpoints() {
    echo "Top Endpoints:"
    tail -10000 /var/log/nginx/edge_analytics.log | \
        grep -o '"request_uri":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10
}

# Main display
while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              EDGE ANALYTICS DASHBOARD                        ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 CACHE PERFORMANCE:"
    echo "  Hit Ratio: $(get_cache_hit_ratio)%"
    echo "  Cache Size: $(du -sh /var/cache/nginx/edge_cache 2>/dev/null | cut -f1)"
    echo ""
    
    echo "🌍 REQUEST DISTRIBUTION:"
    get_request_distribution
    echo ""
    
    echo "🔝 TOP ENDPOINTS:"
    get_top_endpoints
    echo ""
    
    echo "⚡ EDGE STATUS:"
    echo "  Active Edge Nodes: $(docker ps | grep -c edge)"
    echo "  Total Requests: $(wc -l < /var/log/nginx/edge_analytics.log 2>/dev/null)"
    
    echo ""
    echo "----------------------------------------"
    sleep 10
done
```

---

This primer provides a comprehensive deep dive into using Nginx for serverless architectures and edge computing. Use these techniques to build modern, distributed applications with low latency and high performance.
