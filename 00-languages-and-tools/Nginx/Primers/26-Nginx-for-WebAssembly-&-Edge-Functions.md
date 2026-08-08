# Primer 26: Nginx for WebAssembly & Edge Functions

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx with WebAssembly (Wasm) and edge functions for serverless computing at the edge. Understanding these concepts is essential for building modern, high-performance, and portable applications.

## P26.1 Wasm Edge Architecture

### WebAssembly Edge Computing Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WEBASSEMBLY EDGE ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX WASM GATEWAY                             │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    WASM RUNTIME LAYER                     │ │      │
│  │  │  • Wasmtime         • WasmEdge         • Wasmer          │ │      │
│  │  │  • Module Loading   • Instance Pooling  • Resource Mgmt  │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EDGE FUNCTION LAYER                    │ │      │
│  │  │  • Function Routing  • Request Handling  • Response Gen   │ │      │
│  │  │  • State Management  • Service Discovery • Cache Control  │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    INTEGRATION LAYER                       │ │      │
│  │  │  • HTTP Protocol    • WebSocket         • GRPC            │ │      │
│  │  │  • Database Access  • Cache Storage    • Message Queue    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Wasm   │  │ Wasm   │  │ Wasm   │  │ Wasm   │  │ Wasm   │           │
│  │ Module │  │ Module │  │ Module │  │ Module │  │ Module │           │
│  │ (Rust) │  │ (Go)   │  │ (C++)  │  │(Python)│  │ (JS)   │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Wasm Edge Configuration

```nginx
# nginx-wasm.conf - Complete Wasm Edge Configuration
# ============================================================================
# NGINX WEBASSEMBLY EDGE GATEWAY
# Complete production-ready Wasm configuration
# ============================================================================

# ============================================================================
# LOAD WASM MODULE
# ============================================================================
load_module modules/ngx_http_wasm_module.so;

# ============================================================================
# GLOBAL SETTINGS
# ============================================================================
worker_processes auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# ============================================================================
# EVENTS
# ============================================================================
events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
    accept_mutex off;
}

# ============================================================================
# HTTP BLOCK
# ============================================================================
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server_tokens off;
    charset utf-8;

    # =========================================================================
    # WASM SETTINGS
    # =========================================================================
    # Configure Wasm runtime
    wasm {
        # Runtime settings
        runtime wasmtime;
        pool_size 32;
        max_memory 256m;
        timeout 30s;
        
        # Module directories
        modules_path /etc/nginx/wasm/modules;
        cache_path /var/cache/nginx/wasm;
        
        # Module settings
        module hello_world {
            path /etc/nginx/wasm/modules/hello_world.wasm;
            handler hello_handler;
            instance_pool 8;
        }
        
        module api_gateway {
            path /etc/nginx/wasm/modules/api_gateway.wasm;
            handler api_handler;
            instance_pool 16;
        }
        
        module auth_module {
            path /etc/nginx/wasm/modules/auth.wasm;
            handler auth_handler;
            instance_pool 8;
        }
    }

    # =========================================================================
    # WASM CACHE
    # =========================================================================
    proxy_cache_path /var/cache/nginx/wasm_cache
        levels=1:2
        keys_zone=wasm_cache:100m
        max_size=1g
        inactive=1h
        use_temp_path=off;

    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name wasm.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/wasm.crt;
        ssl_certificate_key /etc/nginx/ssl/wasm.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;

        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # =========================================================================
        # WASM FUNCTIONS
        # =========================================================================
        
        # Hello World Wasm Function
        location /wasm/hello {
            # Execute Wasm module
            wasm_module hello_world;
            
            # Pass request to Wasm
            wasm_set_header X-Request-ID $request_id;
            wasm_set_header X-User-ID $cookie_user_id;
            
            # Cache response
            wasm_cache wasm_cache;
            wasm_cache_key $scheme$host$request_uri;
            wasm_cache_valid 200 5m;
            
            add_header X-Wasm-Module "hello_world";
        }

        # API Gateway Wasm Function
        location /wasm/api {
            wasm_module api_gateway;
            
            # Process request
            wasm_set_header X-API-Key $http_x_api_key;
            wasm_set_header X-Request-ID $request_id;
            
            # Rate limiting in Wasm
            wasm_rate_limit zone=wasm_api rate=60r/m burst=10;
            
            add_header X-Wasm-Module "api_gateway";
            
            proxy_pass http://backend;
        }

        # Auth Wasm Function
        location /wasm/auth {
            wasm_module auth_module;
            
            wasm_set_header X-Original-URI $request_uri;
            wasm_set_header Authorization $http_authorization;
            
            add_header X-Wasm-Module "auth";
            
            # If auth fails, return 401
            wasm_return_on_error 401;
        }

        # =========================================================================
        # WASM-POWERED API
        # =========================================================================
        location /api/ {
            # Use Wasm for API processing
            wasm_module api_gateway;
            
            # Set request context
            wasm_set_header X-Request-ID $request_id;
            wasm_set_header X-User-ID $cookie_user_id;
            wasm_set_header X-API-Key $http_x_api_key;
            
            # Rate limiting
            wasm_rate_limit zone=wasm_api rate=60r/m burst=20;
            
            # Cache responses
            wasm_cache wasm_cache;
            wasm_cache_key $scheme$host$request_uri$cookie_user_id;
            wasm_cache_valid 200 1m;
            
            add_header X-Wasm-Processed "true";
            
            proxy_pass http://api_backend/;
        }

        # =========================================================================
        # WASM STATUS
        # =========================================================================
        location /wasm-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "runtime":"$wasm_runtime",
                "modules":$wasm_modules,
                "instances":$wasm_instances,
                "memory":$wasm_memory,
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

## P26.2 Wasm Module Examples

### Rust Wasm Module

```rust
// hello_world.rs - Rust Wasm Module
// ============================================================================
// RUST WEBASSEMBLY MODULE FOR NGINX
// Simple hello world with request processing
// ============================================================================

use nginx_wasm::prelude::*;

#[wasm_func]
pub fn hello_handler(req: &mut Request) -> Result<Response> {
    // Extract request information
    let method = req.method().to_string();
    let uri = req.uri().to_string();
    let user_agent = req.header("User-Agent").unwrap_or("unknown");
    
    // Get user ID from cookie
    let user_id = req.cookie("user_id").unwrap_or("guest");
    
    // Process request
    let message = format!(
        "Hello {}!\n\
         Method: {}\n\
         URI: {}\n\
         User-Agent: {}\n\
         Request ID: {}",
        user_id,
        method,
        uri,
        user_agent,
        req.header("X-Request-ID").unwrap_or("unknown")
    );
    
    // Create response
    let mut resp = Response::new(200);
    resp.set_header("Content-Type", "text/plain");
    resp.set_header("X-Wasm-Module", "hello_world");
    resp.set_header("X-Wasm-Version", "1.0.0");
    resp.set_body(message);
    
    Ok(resp)
}
```

### Go Wasm Module

```go
// auth.go - Go Wasm Module
// ============================================================================
// GO WEBASSEMBLY MODULE FOR NGINX
// Authentication and authorization module
// ============================================================================

package main

import (
    "encoding/json"
    "fmt"
    "strings"
    "time"
    
    "github.com/nginx/nginx-wasm-go-sdk"
)

type AuthRequest struct {
    Method   string            `json:"method"`
    URI      string            `json:"uri"`
    Headers  map[string]string `json:"headers"`
    Cookies  map[string]string `json:"cookies"`
}

type AuthResponse struct {
    Authenticated bool   `json:"authenticated"`
    UserID        string `json:"user_id"`
    UserRole      string `json:"user_role"`
    Error         string `json:"error,omitempty"`
}

// Validate JWT token
func validateJWT(token string) (bool, string, string) {
    // JWT validation logic
    // In production, use proper JWT library
    
    if token == "" {
        return false, "", ""
    }
    
    // Simple validation for demo
    parts := strings.Split(token, ".")
    if len(parts) != 3 {
        return false, "", ""
    }
    
    // Extract claims (simplified)
    // In production, verify signature
    return true, "user-123", "admin"
}

// Auth handler function
func authHandler(req *Request) *Response {
    // Parse request
    authReq := &AuthRequest{
        Method:  req.Method(),
        URI:     req.URI(),
        Headers: make(map[string]string),
        Cookies: make(map[string]string),
    }
    
    // Extract headers
    for name, value := range req.Headers() {
        authReq.Headers[name] = value
    }
    
    // Extract cookies
    for name, value := range req.Cookies() {
        authReq.Cookies[name] = value
    }
    
    // Check for authorization token
    authHeader := authReq.Headers["Authorization"]
    if authHeader == "" {
        return &Response{
            Status: 401,
            Headers: map[string]string{
                "Content-Type": "application/json",
                "WWW-Authenticate": `Bearer realm="api"`,
            },
            Body: `{"error":"Missing authorization header"}`,
        }
    }
    
    // Extract token
    token := strings.TrimPrefix(authHeader, "Bearer ")
    if token == authHeader {
        return &Response{
            Status: 401,
            Headers: map[string]string{
                "Content-Type": "application/json",
                "WWW-Authenticate": `Bearer realm="api"`,
            },
            Body: `{"error":"Invalid token format"}`,
        }
    }
    
    // Validate token
    valid, userID, userRole := validateJWT(token)
    if !valid {
        return &Response{
            Status: 401,
            Headers: map[string]string{
                "Content-Type": "application/json",
            },
            Body: `{"error":"Invalid token"}`,
        }
    }
    
    // Check authorization
    // Role-based access control
    if strings.HasPrefix(authReq.URI, "/admin/") && userRole != "admin" {
        return &Response{
            Status: 403,
            Headers: map[string]string{
                "Content-Type": "application/json",
            },
            Body: `{"error":"Insufficient permissions"}`,
        }
    }
    
    // Success response
    authResp := AuthResponse{
        Authenticated: true,
        UserID:        userID,
        UserRole:      userRole,
    }
    
    body, _ := json.Marshal(authResp)
    
    resp := &Response{
        Status: 200,
        Headers: map[string]string{
            "Content-Type":      "application/json",
            "X-User-ID":         userID,
            "X-User-Role":       userRole,
            "X-Auth-Time":       time.Now().UTC().Format(time.RFC3339),
        },
        Body: string(body),
    }
    
    return resp
}

// Main function
func main() {
    nginx.RegisterHandler("/auth/validate", authHandler)
    nginx.Serve()
}
```

### JavaScript Wasm Module

```javascript
// api-gateway.js - JavaScript Wasm Module
// ============================================================================
// JAVASCRIPT WEBASSEMBLY MODULE FOR NGINX
// API Gateway with routing, rate limiting, and caching
// ============================================================================

// Import Nginx Wasm SDK
import { Request, Response, Cache, RateLimit } from 'nginx-wasm';

// Service registry
const services = {
    users: { host: 'users:8002', timeout: 5000 },
    orders: { host: 'orders:8003', timeout: 10000 },
    products: { host: 'products:8004', timeout: 5000 },
    payments: { host: 'payments:8005', timeout: 15000 },
};

// Route mapping
const routes = {
    '/users/': 'users',
    '/orders/': 'orders',
    '/products/': 'products',
    '/payments/': 'payments',
};

// Rate limit configurations
const rateLimits = {
    'default': { rate: 60, burst: 10 },
    'users': { rate: 100, burst: 20 },
    'payments': { rate: 10, burst: 5 },
};

// API Gateway handler
export async function apiHandler(req) {
    try {
        // 1. Extract request info
        const method = req.method;
        const uri = req.uri;
        const headers = req.headers;
        const body = req.body;
        const query = req.query;
        
        // 2. Route the request
        let service = 'default';
        for (const [path, svc] of Object.entries(routes)) {
            if (uri.startsWith(path)) {
                service = svc;
                break;
            }
        }
        
        // 3. Apply rate limiting
        const rateLimit = rateLimits[service] || rateLimits['default'];
        const key = `${service}:${headers['X-User-ID'] || 'anonymous'}`;
        const allowed = await RateLimit.check(key, rateLimit.rate, rateLimit.burst);
        
        if (!allowed) {
            return new Response(429, {
                'Content-Type': 'application/json',
                'X-RateLimit-Limit': rateLimit.rate,
                'X-RateLimit-Remaining': 0,
            }, JSON.stringify({
                error: 'Rate limit exceeded',
                retry_after: 60,
            }));
        }
        
        // 4. Check cache for GET requests
        if (method === 'GET') {
            const cacheKey = `${service}:${uri}`;
            const cached = await Cache.get(cacheKey);
            if (cached) {
                const response = JSON.parse(cached);
                return new Response(200, {
                    'Content-Type': 'application/json',
                    'X-Cache': 'HIT',
                    'X-Service': service,
                }, JSON.stringify(response));
            }
        }
        
        // 5. Forward to service
        const serviceConfig = services[service];
        if (!serviceConfig) {
            return new Response(404, {
                'Content-Type': 'application/json',
            }, JSON.stringify({
                error: 'Service not found',
            }));
        }
        
        // 6. Build upstream request
        const upstreamReq = {
            method: method,
            headers: {
                'Host': serviceConfig.host,
                'X-Real-IP': headers['X-Real-IP'] || '',
                'X-Forwarded-For': headers['X-Forwarded-For'] || '',
                'X-Request-ID': headers['X-Request-ID'] || '',
                'X-User-ID': headers['X-User-ID'] || '',
                'X-API-Key': headers['X-API-Key'] || '',
            },
            body: body,
            timeout: serviceConfig.timeout,
        };
        
        // 7. Call service
        const startTime = Date.now();
        const upstreamResp = await fetch(`http://${serviceConfig.host}${uri}`, upstreamReq);
        const duration = Date.now() - startTime;
        
        // 8. Process response
        const responseBody = await upstreamResp.text();
        
        // 9. Cache GET responses
        if (method === 'GET' && upstreamResp.status === 200) {
            const cacheKey = `${service}:${uri}`;
            await Cache.set(cacheKey, responseBody, 300); // 5 minutes
        }
        
        // 10. Return response
        return new Response(upstreamResp.status, {
            'Content-Type': 'application/json',
            'X-Service': service,
            'X-Response-Time': `${duration}ms`,
            'X-Cache': 'MISS',
        }, responseBody);
        
    } catch (error) {
        // Error handling
        console.error('API Gateway Error:', error);
        
        return new Response(500, {
            'Content-Type': 'application/json',
            'X-Error': error.message,
        }, JSON.stringify({
            error: 'Internal server error',
            request_id: req.headers['X-Request-ID'],
        }));
    }
}

// Register handlers
nginx.registerHandler('/api/', apiHandler);
```

## P26.3 Wasm Performance Monitoring

### Wasm Monitoring Script

```bash
#!/bin/bash
# wasm-monitor.sh - Wasm performance monitoring

echo "=== Wasm Edge Monitoring ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get Wasm module stats
get_module_stats() {
    echo "  Wasm Modules:"
    curl -s http://localhost/wasm-status 2>/dev/null | python -m json.tool | grep -E "modules|instances|memory"
}

# Function: Get execution time
get_execution_time() {
    local avg=$(tail -100 /var/log/nginx/access.log | \
        grep -o '"request_time":[0-9.]*' | \
        cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print "N/A"}')
    echo "  Avg Execution: ${avg}s"
}

# Function: Get cache performance
get_cache_performance() {
    local hits=$(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache":"HIT"')
    local total=$(tail -1000 /var/log/nginx/access.log | wc -l)
    if [ $total -gt 0 ]; then
        local rate=$((hits * 100 / total))
        echo "  Cache Hit Rate: $rate%"
    else
        echo "  Cache Hit Rate: N/A"
    fi
}

# Function: Get error rate
get_error_rate() {
    local errors=$(tail -1000 /var/log/nginx/access.log | grep -c '"status":5[0-9][0-9]')
    echo "  Error Rate: $errors%"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              WASM EDGE MONITORING DASHBOARD                   ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 WASM STATUS:"
    get_module_stats
    echo ""
    
    echo "⚡ PERFORMANCE:"
    get_execution_time
    get_cache_performance
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx with WebAssembly and edge functions. Use these techniques to build modern, high-performance, and portable edge computing applications.
