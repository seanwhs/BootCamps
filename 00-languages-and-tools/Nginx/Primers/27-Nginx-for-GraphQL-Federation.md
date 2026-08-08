# Primer 27: Nginx for GraphQL Federation

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for GraphQL federation and gateway implementation. Understanding these concepts is essential for building modern, federated GraphQL architectures at scale.

## P27.1 GraphQL Federation Architecture

### Federated GraphQL Gateway

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GRAPHQL FEDERATION ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX GRAPHQL GATEWAY                         │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    QUERY PLANNING                         │ │      │
│  │  │  • Query Parsing   • Field Selection   • Federation       │ │      │
│  │  │  • Execution Plans • Batching         • Caching           │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    FEDERATION LAYER                       │ │      │
│  │  │  • Service Discovery  • Schema Stitching  • Entity        │ │      │
│  │  │  • Reference Resolution • Context Propagation            │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PERFORMANCE LAYER                      │ │      │
│  │  │  • Query Batching   • Persistent Queries  • Defer/Stream  │ │      │
│  │  │  • Compression      • Caching           • Rate Limiting   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Users  │  │ Orders │  │Products│  │Reviews │  │Inventory│           │
│  │ GraphQL│  │ GraphQL│  │ GraphQL│  │ GraphQL│  │ GraphQL │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete GraphQL Federation Configuration

```nginx
# nginx-graphql.conf - Complete GraphQL Federation Gateway
# ============================================================================
# NGINX GRAPHQL FEDERATION GATEWAY
# Complete production-ready GraphQL federation configuration
# ============================================================================

http {
    # =========================================================================
    # BASIC SETTINGS
    # =========================================================================
    worker_processes auto;
    worker_rlimit_nofile 65535;
    
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
    client_max_body_size 10M;
    
    # =========================================================================
    # GRAPHQL SPECIFIC SETTINGS
    # =========================================================================
    # Large header for GraphQL queries
    large_client_header_buffers 4 16k;
    client_header_buffer_size 8k;
    
    # Long timeouts for complex queries
    proxy_read_timeout 60s;
    proxy_connect_timeout 10s;
    proxy_send_timeout 60s;
    
    # =========================================================================
    # LOGGING
    # =========================================================================
    log_format graphql escape=json '{'
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
        '"graphql_query":"$graphql_query",'
        '"graphql_operation":"$graphql_operation",'
        '"graphql_variables":"$graphql_variables"'
    '}';
    
    access_log /var/log/nginx/graphql.log graphql;
    error_log /var/log/nginx/error.log warn;
    
    # =========================================================================
    # GRAPHQL CACHE
    # =========================================================================
    proxy_cache_path /var/cache/nginx/graphql_cache
        levels=1:2
        keys_zone=graphql_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # GRAPHQL UPSTREAMS
    # =========================================================================
    # Users Service
    upstream users_graphql {
        server users-graphql:8001 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Orders Service
    upstream orders_graphql {
        server orders-graphql:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Products Service
    upstream products_graphql {
        server products-graphql:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Reviews Service
    upstream reviews_graphql {
        server reviews-graphql:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Inventory Service
    upstream inventory_graphql {
        server inventory-graphql:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # MAIN GRAPHQL GATEWAY
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name graphql.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/graphql.crt;
        ssl_certificate_key /etc/nginx/ssl/graphql.key;
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
        
        # CORS for GraphQL
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
        add_header Access-Control-Expose-Headers "X-Request-ID, X-GraphQL-Trace" always;
        
        # Preflight
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Length 0;
            return 204;
        }
        
        # =========================================================================
        # GRAPHQL REQUEST PROCESSING
        # =========================================================================
        location /graphql {
            # Rate limiting
            limit_req zone=graphql burst=20 nodelay;
            limit_conn conn 20;
            
            # GraphQL specific headers
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $cookie_user_id;
            proxy_set_header X-Session-ID $cookie_session_id;
            
            # Extract GraphQL query for logging
            set $graphql_query "";
            set $graphql_operation "";
            set $graphql_variables "";
            
            # Read body for GraphQL query
            # (Requires lua module or similar)
            
            # Route to appropriate service based on query
            # Using lua for dynamic routing (see below)
            
            # Default federation gateway
            proxy_pass http://federation-gateway/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # SERVICE-SPECIFIC GRAPHQL ENDPOINTS
        # =========================================================================
        location /graphql/users {
            proxy_pass http://users_graphql/graphql;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $cookie_user_id;
        }
        
        location /graphql/orders {
            proxy_pass http://orders_graphql/graphql;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $cookie_user_id;
        }
        
        location /graphql/products {
            proxy_pass http://products_graphql/graphql;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        location /graphql/reviews {
            proxy_pass http://reviews_graphql/graphql;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $cookie_user_id;
        }
        
        location /graphql/inventory {
            proxy_pass http://inventory_graphql/graphql;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # =========================================================================
        # GRAPHQL INTROSPECTION (PROTECTED)
        # =========================================================================
        location /graphql/introspection {
            # Only allow in development
            allow 10.0.0.0/8;
            allow 127.0.0.1;
            deny all;
            
            proxy_pass http://federation-gateway/introspection;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # =========================================================================
        # GRAPHQL PLAYGROUND (DEVELOPMENT)
        # =========================================================================
        location /graphql/playground {
            # Only allow in development
            allow 10.0.0.0/8;
            allow 127.0.0.1;
            deny all;
            
            alias /usr/share/nginx/html/playground;
            try_files $uri /index.html;
        }
        
        # =========================================================================
        # GRAPHQL STATUS
        # =========================================================================
        location /graphql/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "status":"healthy",
                "services":{
                    "users":"$upstream_addr",
                    "orders":"$upstream_addr",
                    "products":"$upstream_addr",
                    "reviews":"$upstream_addr",
                    "inventory":"$upstream_addr"
                },
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

## P27.2 Dynamic GraphQL Routing with Lua

### Lua GraphQL Router

```lua
-- graphql-router.lua - Dynamic GraphQL Routing
-- ============================================================================
-- LUA GRAPHQL ROUTER
-- Dynamic routing based on GraphQL query
-- ============================================================================

local graphql_router = {}

-- Service mapping
graphql_router.services = {
    users = {
        endpoint = "http://users_graphql/graphql",
        fields = {"user", "users", "profile", "me", "userSettings"},
    },
    orders = {
        endpoint = "http://orders_graphql/graphql",
        fields = {"order", "orders", "orderHistory", "checkout"},
    },
    products = {
        endpoint = "http://products_graphql/graphql",
        fields = {"product", "products", "productSearch", "categories"},
    },
    reviews = {
        endpoint = "http://reviews_graphql/graphql",
        fields = {"review", "reviews", "productReviews", "userReviews"},
    },
    inventory = {
        endpoint = "http://inventory_graphql/graphql",
        fields = {"inventory", "stock", "availability", "warehouse"},
    },
}

-- Parse GraphQL query to extract fields
function graphql_router.parse_query(query)
    -- Extract operation name
    local operation = query:match("query%s+(%w+)")
    if not operation then
        operation = query:match("mutation%s+(%w+)")
    end
    
    -- Extract top-level fields
    local fields = {}
    for field, _ in query:gmatch("{%s*([%w_]+)%s*[{:]") do
        if field and field ~= "query" and field ~= "mutation" then
            table.insert(fields, field)
        end
    end
    
    return operation, fields
end

-- Determine which service to route to
function graphql_router.determine_service(fields)
    local service_matches = {}
    
    -- Count field matches per service
    for service, config in pairs(graphql_router.services) do
        local count = 0
        for _, field in ipairs(fields) do
            for _, svc_field in ipairs(config.fields) do
                if field == svc_field then
                    count = count + 1
                    break
                end
            end
        end
        if count > 0 then
            table.insert(service_matches, {service = service, count = count})
        end
    end
    
    -- Sort by match count (highest first)
    table.sort(service_matches, function(a, b) return a.count > b.count end)
    
    if #service_matches > 0 then
        return service_matches[1].service
    end
    
    return nil
end

-- Main routing function
function graphql_router.route()
    -- Read request body
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    
    if not body then
        ngx.status = 400
        ngx.say('{"error":"Missing request body"}')
        return
    end
    
    -- Parse JSON
    local json = require("cjson")
    local data = json.decode(body)
    
    if not data or not data.query then
        ngx.status = 400
        ngx.say('{"error":"Invalid GraphQL request"}')
        return
    end
    
    -- Parse query
    local operation, fields = graphql_router.parse_query(data.query)
    
    -- Determine service
    local service = graphql_router.determine_service(fields)
    
    if not service then
        ngx.status = 404
        ngx.say('{"error":"No matching service found"}')
        return
    end
    
    -- Get service endpoint
    local service_config = graphql_router.services[service]
    local endpoint = service_config.endpoint
    
    -- Log routing decision
    ngx.log(ngx.INFO, "Routing GraphQL request to " .. service .. " (operation: " .. (operation or "unknown") .. ")")
    
    -- Add routing headers
    ngx.req.set_header("X-GraphQL-Service", service)
    ngx.req.set_header("X-GraphQL-Operation", operation or "")
    ngx.req.set_header("X-GraphQL-Fields", table.concat(fields, ","))
    
    -- Proxy to service
    ngx.exec(endpoint)
end

-- Register handler
return graphql_router
```

## P27.3 GraphQL Performance Optimization

### Query Optimization Configuration

```nginx
# nginx-graphql-optimization.conf - GraphQL Performance
# ============================================================================
# GRAPHQL PERFORMANCE OPTIMIZATION
# Optimizations for GraphQL federation
# ============================================================================

http {
    # =========================================================================
    # QUERY CACHING
    # =========================================================================
    
    # Cache by query hash
    proxy_cache_path /var/cache/nginx/graphql_query_cache
        levels=1:2
        keys_zone=graphql_query_cache:100m
        max_size=1g
        inactive=1h
        use_temp_path=off;
    
    # Persistent queries
    proxy_cache_path /var/cache/nginx/persistent_queries
        levels=1:2
        keys_zone=persistent_queries:50m
        max_size=500m
        inactive=30d
        use_temp_path=off;
    
    # =========================================================================
    # QUERY BATCHING
    # =========================================================================
    
    # Batch similar queries
    location /graphql {
        # Batch requests
        proxy_buffering on;
        proxy_buffer_size 16k;
        proxy_buffers 16 16k;
        proxy_busy_buffers_size 32k;
        
        # Enable request coalescing
        proxy_next_upstream error timeout;
        proxy_next_upstream_tries 2;
    }
    
    # =========================================================================
    # PERSISTENT QUERIES
    # =========================================================================
    
    location /graphql/persistent {
        # Store query by ID
        proxy_cache persistent_queries;
        proxy_cache_key $arg_id;
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1h;
        
        # Return query
        proxy_pass http://query_store/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
    }
}
```

## P27.4 GraphQL Monitoring

### GraphQL Analytics Dashboard

```bash
#!/bin/bash
# graphql-analytics.sh - GraphQL analytics dashboard

echo "=== GraphQL Analytics Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get operation types
get_operation_types() {
    echo "  Operation Types:"
    tail -10000 /var/log/nginx/graphql.log | \
        grep -o '"graphql_operation":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count op; do
            echo "    $op: $count"
        done
}

# Function: Get service usage
get_service_usage() {
    echo "  Service Usage:"
    tail -10000 /var/log/nginx/graphql.log | \
        grep -o '"upstream_addr":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count service; do
            echo "    $service: $count"
        done
}

# Function: Get slow queries
get_slow_queries() {
    echo "  Slow Queries (>1s):"
    tail -10000 /var/log/nginx/graphql.log | \
        grep -o '"request_time":[0-9.]*' | \
        cut -d':' -f2 | awk '$1 > 1 {print $1}' | \
        sort -nr | head -5 | \
        while read time; do
            echo "    ${time}s"
        done
}

# Function: Get error rate
get_error_rate() {
    local errors=$(tail -1000 /var/log/nginx/graphql.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "  Error Rate: $errors%"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              GRAPHQL ANALYTICS DASHBOARD                      ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 OPERATION STATISTICS:"
    get_operation_types
    echo ""
    
    echo "🔗 SERVICE USAGE:"
    get_service_usage
    echo ""
    
    echo "⏱️ PERFORMANCE:"
    get_slow_queries
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for GraphQL federation and gateway implementation. Use these techniques to build modern, federated GraphQL architectures at scale.
