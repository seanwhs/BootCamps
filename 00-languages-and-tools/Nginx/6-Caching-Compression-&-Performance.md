# Part 6: Caching, Compression & Performance

## The Target

We're going to transform our real-time gateway into a high-performance content delivery system. By the end of this part, you'll have:

- Static asset caching with proper cache headers and expiration
- Proxy caching for API responses to reduce application load
- Micro-caching for high-traffic endpoints
- Gzip compression for bandwidth reduction
- Cache invalidation strategies for dynamic content
- Performance benchmarks showing the impact of each optimization
- Complete understanding of when and what to cache

## The Concept: Caching as Performance Multipliers

Think of caching like having a well-organized kitchen:

- **Browser Cache** (customer's fridge): Store takeout leftovers for quick meals later
- **Proxy Cache** (kitchen pantry): Store frequently used ingredients ready for cooking
- **Micro-Caching** (mise en place): Prep ingredients for the next few minutes of service
- **Compression** (vacuum sealing): Make ingredients smaller to store more in less space

Without caching, every request is like cooking from scratch. With caching, you can serve most requests from prepared ingredients, dramatically reducing cook time.

## The Pain Point: High Traffic Overwhelms Applications

Let's experience what happens when an unoptimized application gets hammered with traffic.

### Step 1: Setup Performance Testing Environment

Create the directory structure:

```bash
mkdir -p nginx-series/part-06
cd nginx-series/part-06

# Copy our existing apps
cp -r ../part-05/nextjs-app .
cp -r ../part-05/fastapi-app .
cp -r ../part-05/auth-api .
cp -r ../part-05/websocket-app .
cp -r ../part-05/sse-app .
cp -r ../part-05/webhook-app .
cp -r ../part-05/ssl .
```

**File: `fastapi-app/main.py` (Enhanced for Performance Testing)**
```python
# Enhanced FastAPI with performance monitoring

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import time
import random
import asyncio
from typing import Dict, List

app = FastAPI(title="Performance API", version="1.0.0")

# Simulate database with slow queries
fake_db = {
    "products": [
        {"id": i, "name": f"Product {i}", "price": random.randint(10, 1000)}
        for i in range(1, 101)
    ],
    "users": [
        {"id": i, "name": f"User {i}", "email": f"user{i}@example.com"}
        for i in range(1, 51)
    ],
    "orders": [
        {"id": i, "user_id": random.randint(1, 50), "total": random.randint(50, 500)}
        for i in range(1, 201)
    ]
}

# Performance metrics
metrics = {
    "requests": 0,
    "cache_hits": 0,
    "cache_misses": 0,
    "average_response_time": 0
}

# Middleware to track performance
@app.middleware("http")
async def track_performance(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    
    metrics["requests"] += 1
    metrics["average_response_time"] = (
        (metrics["average_response_time"] * (metrics["requests"] - 1) + duration)
        / metrics["requests"]
    )
    
    # Add performance headers
    response.headers["X-Response-Time"] = f"{duration:.3f}s"
    response.headers["X-Request-ID"] = str(random.randint(1000, 9999))
    
    return response

# Cache control endpoint
@app.get("/")
async def root():
    return {
        "service": "Performance API",
        "version": "1.0.0",
        "endpoints": [
            "/public/",
            "/public/products",
            "/public/products/{id}",
            "/private/",
            "/dynamic/",
            "/slow/",
            "/stats"
        ]
    }

# Public endpoint - highly cacheable
@app.get("/public")
async def public_data():
    """
    Public data endpoint - safe to cache
    Returns static product catalog
    """
    # Simulate DB query (50ms)
    await asyncio.sleep(0.05)
    
    return {
        "data": fake_db["products"],
        "timestamp": int(time.time()),
        "source": "database (cached)"
    }

@app.get("/public/products")
async def public_products():
    """
    Public products endpoint - cacheable
    """
    # Simulate more expensive query (100ms)
    await asyncio.sleep(0.1)
    
    return {
        "products": fake_db["products"],
        "count": len(fake_db["products"]),
        "timestamp": int(time.time())
    }

@app.get("/public/products/{product_id}")
async def public_product(product_id: int):
    """
    Individual product - cacheable by ID
    """
    # Simulate query (30ms)
    await asyncio.sleep(0.03)
    
    product = next((p for p in fake_db["products"] if p["id"] == product_id), None)
    if not product:
        return JSONResponse(status_code=404, content={"error": "Product not found"})
    
    return product

# Private endpoint - NOT cacheable (user-specific)
@app.get("/private")
async def private_data(request: Request):
    """
    Private data endpoint - NOT cacheable
    Returns user-specific orders
    """
    # Extract user from headers (simplified)
    user_id = request.headers.get("X-User-ID", "1")
    
    # Simulate user-specific query (150ms)
    await asyncio.sleep(0.15)
    
    # Filter orders for this user
    user_orders = [o for o in fake_db["orders"] if o["user_id"] == int(user_id)]
    
    return {
        "user_id": user_id,
        "orders": user_orders,
        "timestamp": int(time.time()),
        "cacheable": False
    }

# Dynamic endpoint - cache for short time
@app.get("/dynamic")
async def dynamic_data():
    """
    Dynamic endpoint - cache for 5 seconds
    Returns frequently updated data
    """
    # Simulate query (80ms)
    await asyncio.sleep(0.08)
    
    return {
        "data": {
            "random": random.random(),
            "time": int(time.time()),
            "value": random.randint(1, 100)
        },
        "timestamp": int(time.time()),
        "ttl": 5  # Cache for 5 seconds
    }

# Slow endpoint - simulates heavy processing
@app.get("/slow")
async def slow_data():
    """
    Slow endpoint - simulates CPU-intensive work
    """
    # Simulate heavy computation (500ms)
    await asyncio.sleep(0.5)
    
    # Simulate some work
    result = sum([i**2 for i in range(10000)])
    
    return {
        "result": result,
        "computation_time": 0.5,
        "timestamp": int(time.time())
    }

# Stats endpoint
@app.get("/stats")
async def get_stats():
    return {
        "metrics": metrics,
        "db_size": {
            "products": len(fake_db["products"]),
            "users": len(fake_db["users"]),
            "orders": len(fake_db["orders"])
        }
    }

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

### Step 2: The Broken Setup (Performance Issues)

**File: `nginx.conf` (INTENTIONALLY BROKEN - No Caching)**
```nginx
# This configuration has NO caching or compression
# Every request hits the application

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    sendfile on;
    keepalive_timeout 65;

    upstream api_backend {
        server fastapi:8000;
        keepalive 32;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # Root - frontend
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - NO CACHING
        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Static assets - NO CACHING
        location /static/ {
            alias /usr/share/nginx/html/static/;
            # No cache headers - browsers will request every time
        }
    }

    # HTTP redirect to HTTPS
    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

**File: `docker-compose.yml`**
```yaml
version: '3.8'

services:
  fastapi:
    build:
      context: ./fastapi-app
      dockerfile: Dockerfile
    container_name: fastapi-performance
    ports:
      - "8000:8000"
    environment:
      - PYTHONUNBUFFERED=1
    networks:
      - app-network

  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-performance
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
      - ./cache:/var/cache/nginx
    depends_on:
      - fastapi
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### Step 3: Run Performance Baseline

```bash
# Start the services
docker compose up -d

# Wait for everything to start
sleep 10

# Run baseline performance test (no caching)
echo "=== BASELINE PERFORMANCE (NO CACHING) ==="

# Test 1: Public endpoint (cacheable)
echo "Test 1: Public endpoint (should be cacheable)"
time curl -k -s https://localhost/api/public > /dev/null

# Test 2: Multiple requests to public endpoint
echo "Test 2: 10 requests to public endpoint"
time for i in {1..10}; do
    curl -k -s https://localhost/api/public > /dev/null
done

# Test 3: Slow endpoint
echo "Test 3: Slow endpoint"
time curl -k -s https://localhost/api/slow > /dev/null

# Test 4: Static assets
echo "Test 4: Static asset request"
time curl -k -s https://localhost/static/test.js > /dev/null

# Check application metrics
curl -k -s https://localhost/api/stats | python -m json.tool
```

### Step 4: Understanding the Performance Problems

**Problem 1: No Browser Caching**
- Every request for static assets hits the server
- Browsers don't cache anything
- High bandwidth usage

**Problem 2: No Proxy Caching**
- Every API request hits the application
- Application CPU wasted on duplicate requests
- Database queries repeated unnecessarily

**Problem 3: No Compression**
- Responses are sent uncompressed
- Higher bandwidth usage
- Slower page loads

**Problem 4: No Micro-Caching**
- Even dynamic data is recomputed every request
- No protection against traffic spikes

### Step 5: The Fix - Complete Caching Configuration

**File: `nginx.conf` (FIXED - With Full Caching)**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Custom log format with cache status
    log_format cache '$remote_addr - $remote_user [$time_local] "$request" '
                     '$status $body_bytes_sent "$http_referer" '
                     '"$http_user_agent" "$http_x_forwarded_for" '
                     '"$upstream_cache_status" "$request_time"';

    access_log /var/log/nginx/access.log cache;
    error_log /var/log/nginx/error.log;

    sendfile on;
    keepalive_timeout 65;

    # Gzip Compression - reduces bandwidth
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/rss+xml
        application/atom+xml
        image/svg+xml;

    # Cache Definitions
    # Proxy cache for API responses
    proxy_cache_path /var/cache/nginx/api_cache
        levels=1:2
        keys_zone=api_cache:100m
        max_size=1g
        inactive=1h
        use_temp_path=off;

    # Micro-cache for dynamic data
    proxy_cache_path /var/cache/nginx/micro_cache
        levels=1:2
        keys_zone=micro_cache:50m
        max_size=500m
        inactive=5s
        use_temp_path=off;

    # Static file cache
    proxy_cache_path /var/cache/nginx/static_cache
        levels=1:2
        keys_zone=static_cache:50m
        max_size=500m
        inactive=30d
        use_temp_path=off;

    upstream api_backend {
        server fastapi:8000;
        keepalive 32;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # Static Assets - Browser Caching
        location /static/ {
            alias /usr/share/nginx/html/static/;
            
            # FIXED: Browser caching for static assets
            expires 30d;
            add_header Cache-Control "public, immutable";
            
            # FIXED: Enable static caching
            proxy_cache static_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            # Compression for static assets
            gzip_static on;
            gzip_proxied any;
            
            # Security headers
            add_header X-Content-Type-Options "nosniff";
        }

        # API - Public cacheable endpoints
        location /api/public/ {
            # FIXED: API caching with appropriate TTL
            proxy_cache api_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 5m;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            # Add cache status header
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://api_backend/public/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - Dynamic (micro-cache)
        location /api/dynamic/ {
            # FIXED: Micro-caching for dynamic data (5 second TTL)
            proxy_cache micro_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 5s;
            proxy_cache_valid 404 1s;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 1s;
            
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://api_backend/dynamic/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - Private (NO caching)
        location /api/private/ {
            # FIXED: No caching for private endpoints
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header X-Cache-Status "BYPASS";
            
            proxy_pass http://api_backend/private/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-User-ID $cookie_user_id;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - Slow endpoints (cache to reduce load)
        location /api/slow/ {
            # FIXED: Cache slow endpoints to reduce CPU usage
            proxy_cache api_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 302 10m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            proxy_cache_lock_timeout 10s;
            
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://api_backend/slow/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - Generic cache-aware endpoint
        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Root - frontend
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }

    # HTTP redirect to HTTPS
    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

### Step 6: Cache Bypass and Invalidation

Sometimes you need to bypass the cache or invalidate specific entries. Here's how:

**File: `nginx-cache-invalidation.conf`**
```nginx
# Cache Invalidation Configuration

# Cache purge endpoint (requires Nginx Plus or custom module)
location /purge/ {
    # Only allow from internal IPs
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    
    # Purge the cache for this URL
    proxy_cache_purge api_cache "$scheme$host$1";
}

# Cache bypass using headers
location /api/ {
    # Bypass cache if 'Cache-Control: no-cache' header is present
    proxy_cache_bypass $http_cache_control;
    proxy_no_cache $http_cache_control;
    
    # Or bypass using cookie
    proxy_cache_bypass $cookie_bypass_cache;
    proxy_no_cache $cookie_bypass_cache;
    
    proxy_pass http://api_backend/;
}

# Cache variations based on headers
location /api/ {
    # Cache different versions for different User-Agents
    proxy_cache_key "$scheme$host$request_uri$http_user_agent";
    
    # Or cache based on Accept-Encoding
    proxy_cache_key "$scheme$host$request_uri$http_accept_encoding";
    
    proxy_pass http://api_backend/;
}

# Conditional caching
location /api/ {
    # Cache only if response is 200 OK
    proxy_cache_valid 200 5m;
    # Don't cache errors
    proxy_cache_valid 404 0;
    proxy_cache_valid 500 0;
    
    proxy_pass http://api_backend/;
}
```

### Step 7: Performance Testing with Caching

```bash
# Reload Nginx with caching enabled
docker exec nginx-performance nginx -t
docker exec nginx-performance nginx -s reload

# Wait for reload
sleep 2

# Run performance test with caching
echo "=== PERFORMANCE WITH CACHING ==="

# Test 1: Public endpoint (cached)
echo "Test 1: Public endpoint - first request (cache miss)"
time curl -k -s -I https://localhost/api/public/ | grep -E "X-Cache|HTTP"
echo ""

echo "Test 1: Public endpoint - second request (cache hit)"
time curl -k -s -I https://localhost/api/public/ | grep -E "X-Cache|HTTP"
echo ""

# Test 2: Multiple requests to public endpoint
echo "Test 2: 10 requests to public endpoint (should be cached after first)"
time for i in {1..10}; do
    curl -k -s https://localhost/api/public/ > /dev/null
done
echo ""

# Test 3: Slow endpoint (cached)
echo "Test 3: Slow endpoint - first request (cache miss)"
time curl -k -s https://localhost/api/slow > /dev/null
echo ""

echo "Test 3: Slow endpoint - second request (cache hit)"
time curl -k -s https://localhost/api/slow > /dev/null
echo ""

# Test 4: Dynamic endpoint (micro-cache)
echo "Test 4: Dynamic endpoint (5s TTL)"
for i in {1..3}; do
    echo "Request $i (should show cache miss then hit):"
    curl -k -s -I https://localhost/api/dynamic/ | grep -E "X-Cache|HTTP"
    sleep 6  # Wait for cache to expire
    echo ""
done

# Test 5: Private endpoint (no cache)
echo "Test 5: Private endpoint (should always miss cache)"
for i in {1..3}; do
    echo "Request $i:"
    curl -k -s -I https://localhost/api/private/ | grep -E "X-Cache|HTTP"
done

# Test 6: Static asset (browser cache)
echo "Test 6: Static asset (should have cache headers)"
curl -k -s -I https://localhost/static/test.js | grep -E "Cache-Control|Expires|HTTP"

# Check cache statistics
echo "Cache Statistics:"
docker exec nginx-performance ls -la /var/cache/nginx/api_cache/
docker exec nginx-performance ls -la /var/cache/nginx/micro_cache/
```

### Step 8: Advanced - Cache Warming and Preloading

**File: `nginx-cache-warming.conf`**
```nginx
# Cache Warming Configuration

# Preload cache with frequently accessed URLs
# Run this script periodically or on deployment

location /warm/ {
    # Only allow from internal
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    
    # Warm the cache by making requests
    proxy_pass http://api_backend/;
    
    # Force cache to be populated
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
    proxy_cache_use_stale updating;
}
```

**Cache Warming Script:**
```bash
#!/bin/bash
# cache-warm.sh - Warm the cache for critical endpoints

URLS=(
    "https://localhost/api/public/"
    "https://localhost/api/public/products"
    "https://localhost/api/slow"
    "https://localhost/static/main.js"
    "https://localhost/static/styles.css"
)

echo "Warming cache..."
for url in "${URLS[@]}"; do
    echo "Warming: $url"
    curl -k -s "$url" > /dev/null
    sleep 0.5
done

echo "Cache warm complete!"
```

### Step 9: Monitoring Cache Performance

**File: `nginx-cache-monitoring.conf`**
```nginx
# Cache Monitoring Configuration

# Cache status endpoint
location /cache-status {
    # Only allow from internal
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    
    return 200 "Cache Status:\n\
        API Cache: $(find /var/cache/nginx/api_cache -type f | wc -l) files\n\
        Micro Cache: $(find /var/cache/nginx/micro_cache -type f | wc -l) files\n\
        Static Cache: $(find /var/cache/nginx/static_cache -type f | wc -l) files\n";
}

# Enable cache statistics in logs
log_format cache_stats '$remote_addr - $remote_user [$time_local] "$request" '
                       '$status $body_bytes_sent "$http_referer" '
                       '"$http_user_agent" "$upstream_cache_status"';
```

### Step 10: Performance Comparison

Let's run a comprehensive performance comparison:

```bash
# Save this as performance-test.sh
#!/bin/bash

echo "=== PERFORMANCE COMPARISON ==="
echo ""

# Function to test performance
test_endpoint() {
    local name=$1
    local url=$2
    local iterations=$3
    
    echo "Testing: $name"
    echo "URL: $url"
    echo "Iterations: $iterations"
    
    # First request (cache miss)
    echo "First request (cache miss):"
    time curl -k -s "$url" > /dev/null
    
    # Subsequent requests (cache hits)
    echo "Average of $((iterations-1)) subsequent requests (cache hits):"
    time for i in $(seq 2 $iterations); do
        curl -k -s "$url" > /dev/null
    done
    echo ""
}

# Test different endpoints
test_endpoint "Public (cacheable)" "https://localhost/api/public/" 5
test_endpoint "Products (cacheable)" "https://localhost/api/public/products" 5
test_endpoint "Dynamic (micro-cache)" "https://localhost/api/dynamic/" 5
test_endpoint "Slow (cacheable)" "https://localhost/api/slow" 5
test_endpoint "Private (no cache)" "https://localhost/api/private/" 5

echo "=== CACHE STATISTICS ==="
curl -k -s https://localhost/api/stats | python -m json.tool

echo "=== CACHE FILES ==="
echo "API Cache: $(docker exec nginx-performance find /var/cache/nginx/api_cache -type f 2>/dev/null | wc -l) files"
echo "Micro Cache: $(docker exec nginx-performance find /var/cache/nginx/micro_cache -type f 2>/dev/null | wc -l) files"
echo "Static Cache: $(docker exec nginx-performance find /var/cache/nginx/static_cache -type f 2>/dev/null | wc -l) files"
```

## Verification Checklist

Before moving on, verify you've mastered caching:

### ✅ Check 1: Cache Headers Present
```bash
curl -k -I https://localhost/api/public/ | grep -E "X-Cache|Cache-Control"
# Should show X-Cache: MISS then X-Cache: HIT
```

### ✅ Check 2: Static Assets Cached
```bash
curl -k -I https://localhost/static/test.js | grep "Cache-Control"
# Should show: Cache-Control: public, immutable
```

### ✅ Check 3: Micro-Caching Works
```bash
# First request (miss)
curl -k -I https://localhost/api/dynamic/ | grep "X-Cache"
# Should show: X-Cache: MISS

# Second request (hit)
curl -k -I https://localhost/api/dynamic/ | grep "X-Cache"
# Should show: X-Cache: HIT

# Wait 6 seconds (cache expires)
sleep 6

# Should be MISS again
curl -k -I https://localhost/api/dynamic/ | grep "X-Cache"
# Should show: X-Cache: MISS
```

### ✅ Check 4: Compression Enabled
```bash
curl -k -I https://localhost/api/public/ -H "Accept-Encoding: gzip"
# Should show: Content-Encoding: gzip
```

### ✅ Check 5: Private Endpoints Not Cached
```bash
curl -k -I https://localhost/api/private/ | grep "X-Cache"
# Should show: X-Cache: BYPASS
```

### ✅ Check 6: Performance Improvement
```bash
# Compare response times
echo "Without cache (slow endpoint):"
time curl -k -s https://localhost/api/slow > /dev/null

echo "With cache (slow endpoint):"
time curl -k -s https://localhost/api/slow > /dev/null
# Should be significantly faster
```

## Common Pitfalls and Solutions

### Pitfall 1: Caching Private Data

**Symptom:** Users see other users' data

**Wrong:**
```nginx
location /api/ {
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
}
```

**Right:**
```nginx
location /api/private/ {
    proxy_no_cache 1;
    proxy_cache_bypass 1;
}
```

### Pitfall 2: Cache Key Collisions

**Symptom:** Different users get same cached response

**Wrong:**
```nginx
proxy_cache_key $scheme$host$request_uri;
```

**Right:**
```nginx
# Include user-specific part in cache key
proxy_cache_key $scheme$host$request_uri$cookie_user_id;
# Or don't cache user-specific content
```

### Pitfall 3: Stale Cache After Updates

**Symptom:** Users see old data after update

**Solution:**
```nginx
# Use cache purging
location /purge/ {
    proxy_cache_purge api_cache "$scheme$host$1";
}

# Or use shorter TTLs for dynamic content
proxy_cache_valid 200 30s;
```

### Pitfall 4: Cache Stampede

**Symptom:** Cache expires, many requests hit application simultaneously

**Solution:**
```nginx
# Use cache locking
proxy_cache_lock on;
proxy_cache_lock_timeout 5s;
proxy_cache_use_stale updating;
```

## What You've Learned

By completing Part 6, you can now:

- ✅ Configure browser caching for static assets
- ✅ Set up proxy caching for API responses
- ✅ Implement micro-caching for dynamic content
- ✅ Enable and configure Gzip compression
- ✅ Cache different endpoints with different TTLs
- ✅ Bypass cache for private endpoints
- ✅ Invalidate cache when needed
- ✅ Cache warm and preload
- ✅ Monitor cache performance
- ✅ Handle cache stampede with locking
- ✅ Understand when NOT to cache

## Reference: Caching Patterns

| Pattern | Use Case | TTL | Locking | Nginx Directive |
|---------|----------|-----|---------|-----------------|
| Browser Cache | Static assets | 30 days | No | `expires 30d` |
| API Cache | Public endpoints | 5 minutes | Yes | `proxy_cache_valid 200 5m` |
| Micro-Cache | Dynamic data | 5 seconds | Yes | `proxy_cache_valid 200 5s` |
| No Cache | Private/user-specific | 0 | No | `proxy_no_cache 1` |
| Cache Bypass | Real-time updates | 0 | No | `proxy_cache_bypass 1` |

## Next Steps

**Part 7: Load Balancing, Blue-Green & Zero-Downtime Deployments** builds on our performance-optimized gateway. You'll learn:

- Load balancing with upstream groups
- Health checks and failover
- Blue-green deployments
- Zero-downtime reloads
- Connection draining
- Deployment strategies

Your gateway is fast and efficient. Now let's make it resilient.
