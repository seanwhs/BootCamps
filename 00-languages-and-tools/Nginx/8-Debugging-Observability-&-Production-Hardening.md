# Part 8: Debugging, Observability & Production Hardening

## The Target

We're going to transform our resilient gateway into an observable, debuggable production system. By the end of this part, you'll have:

- Structured JSON logging for machine-readable logs
- Request tracing with unique request IDs
- Comprehensive error handling and reporting
- Advanced debugging techniques
- Observability stack integration (metrics, logs, traces)
- Production hardening for maximum security and reliability
- Complete troubleshooting runbook for common failures

## The Concept: Making the Invisible Visible

Think of observability like having a complete dashboard for a car:

- **Logs** (trip recorder): Detailed records of everything that happens
- **Metrics** (dashboard): Speed, temperature, fuel level in real-time
- **Traces** (GPS history): Complete path of each request through the system
- **Debugging** (mechanic's toolkit): Tools to diagnose and fix problems

Without observability, a production failure is like a car breakdown in the dark. With observability, you can see exactly what's happening, why it's happening, and how to fix it.

## The Pain Point: Production Failures Are Invisible

Let's experience what happens when a production system fails without proper observability.

### Step 1: Setup Observability Environment

Create the directory structure:

```bash
mkdir -p nginx-series/part-08
cd nginx-series/part-08

# Copy our existing apps
cp -r ../part-07/fastapi-blue .
cp -r ../part-07/fastapi-green .
cp -r ../part-07/ssl .

# Add logging and debugging tools
mkdir -p logs monitoring scripts
```

**File: `fastapi-blue/main.py` (Enhanced with logging)**
```python
# FastAPI with comprehensive logging and debugging

from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
import time
import uuid
import json
import logging
import sys
import os

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

app = FastAPI(title="Blue Instance (Observable)", version="1.0.0")

# Middleware for request tracing and logging
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log all requests with unique IDs"""
    # Generate unique request ID
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    
    # Start timing
    start_time = time.time()
    
    # Log request
    logger.info(json.dumps({
        "type": "request",
        "request_id": request_id,
        "method": request.method,
        "path": request.url.path,
        "query": str(request.query_params),
        "client_ip": request.client.host if request.client else "unknown",
        "user_agent": request.headers.get("user-agent", ""),
        "request_id": request_id
    }))
    
    # Process request
    try:
        response = await call_next(request)
        
        # Calculate duration
        duration = time.time() - start_time
        
        # Log response
        logger.info(json.dumps({
            "type": "response",
            "request_id": request_id,
            "status_code": response.status_code,
            "duration": duration,
            "duration_ms": duration * 1000
        }))
        
        # Add response headers
        response.headers["X-Request-ID"] = request_id
        response.headers["X-Response-Time"] = f"{duration:.3f}s"
        
        return response
        
    except Exception as e:
        # Log error
        logger.error(json.dumps({
            "type": "error",
            "request_id": request_id,
            "error": str(e),
            "error_type": type(e).__name__
        }))
        
        return JSONResponse(
            status_code=500,
            content={
                "error": "Internal Server Error",
                "request_id": request_id
            }
        )

# Health endpoint with detailed info
@app.get("/health")
async def health(request: Request):
    return {
        "status": "healthy",
        "instance": "blue",
        "version": "1.0.0",
        "timestamp": time.time(),
        "request_id": request.headers.get("X-Request-ID", "unknown")
    }

# Main endpoint
@app.get("/")
async def root(request: Request):
    return {
        "instance": "blue",
        "version": "1.0.0",
        "color": "blue",
        "timestamp": time.time(),
        "hostname": os.environ.get("HOSTNAME", "unknown"),
        "request_id": request.headers.get("X-Request-ID", "unknown")
    }

# Debug endpoint for testing errors
@app.get("/debug/error")
async def trigger_error(request: Request):
    """Intentionally trigger an error for testing"""
    logger.error(json.dumps({
        "type": "debug_error",
        "request_id": request.headers.get("X-Request-ID", "unknown"),
        "message": "Intentional error triggered"
    }))
    raise Exception("Intentional error for testing")

# Debug endpoint for slow responses
@app.get("/debug/slow")
async def slow_response(request: Request):
    """Simulate a slow response for testing timeouts"""
    delay = int(request.query_params.get("delay", 5))
    logger.info(json.dumps({
        "type": "slow_request",
        "request_id": request.headers.get("X-Request-ID", "unknown"),
        "delay": delay
    }))
    time.sleep(delay)
    return {
        "message": f"Completed after {delay} seconds",
        "request_id": request.headers.get("X-Request-ID", "unknown")
    }

# Debug endpoint for headers inspection
@app.get("/debug/headers")
async def inspect_headers(request: Request):
    """Show all headers received"""
    return {
        "headers": dict(request.headers),
        "request_id": request.headers.get("X-Request-ID", "unknown"),
        "client_ip": request.client.host if request.client else "unknown"
    }
```

**File: `fastapi-green/main.py`**
```python
# Green instance with logging
from fastapi import FastAPI, Request
import time
import uuid
import json
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Green Instance (Observable)", version="2.0.0")

@app.middleware("http")
async def log_requests(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    start_time = time.time()
    
    response = await call_next(request)
    
    duration = time.time() - start_time
    logger.info(json.dumps({
        "type": "request_complete",
        "request_id": request_id,
        "path": request.url.path,
        "status": response.status_code,
        "duration_ms": duration * 1000
    }))
    
    response.headers["X-Request-ID"] = request_id
    response.headers["X-Response-Time"] = f"{duration:.3f}s"
    
    return response

@app.get("/")
async def root(request: Request):
    return {
        "instance": "green",
        "version": "2.0.0",
        "color": "green",
        "timestamp": time.time(),
        "hostname": os.environ.get("HOSTNAME", "unknown"),
        "request_id": request.headers.get("X-Request-ID", "unknown")
    }

@app.get("/health")
async def health(request: Request):
    return {
        "status": "healthy",
        "instance": "green",
        "version": "2.0.0",
        "timestamp": time.time()
    }
```

### Step 2: The Broken Setup (Poor Observability)

**File: `nginx.conf` (INTENTIONALLY BROKEN - No Observability)**
```nginx
# This configuration has NO observability features
# No structured logging, no request IDs, no debugging

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # PROBLEM: Basic log format without useful information
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    sendfile on;
    keepalive_timeout 65;

    upstream api_backend {
        server fastapi-blue:8000 max_fails=3 fail_timeout=30s;
        server fastapi-green:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;

        # PROBLEM: No request ID generation or propagation
        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            # MISSING: X-Request-ID

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # PROBLEM: No debugging endpoints
        # No way to inspect current state
    }

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
  fastapi-blue:
    build:
      context: ./fastapi-blue
      dockerfile: Dockerfile
    container_name: fastapi-blue
    ports:
      - "8000:8000"
    environment:
      - HOSTNAME=blue-instance
    networks:
      - app-network

  fastapi-green:
    build:
      context: ./fastapi-green
      dockerfile: Dockerfile
    container_name: fastapi-green
    ports:
      - "8001:8000"
    environment:
      - HOSTNAME=green-instance
    networks:
      - app-network

  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
    depends_on:
      - fastapi-blue
      - fastapi-green
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### Step 3: Run and Observe Lack of Observability

```bash
# Start the services
docker compose up -d

# Wait for everything to start
sleep 10

# Test 1: Make some requests
echo "=== Making test requests ==="
for i in {1..5}; do
    curl -k -s https://localhost/api/ > /dev/null
done

# Test 2: Check logs - what information is available?
echo "=== Access logs ==="
tail -10 logs/access.log

echo ""
echo "=== Error logs ==="
tail -10 logs/error.log

echo ""
echo "=== Problem: What happened to each request?"""
echo "No request IDs, no timing info, no upstream details"

# Test 3: Simulate an error
echo "=== Simulating error ==="
curl -k -s https://localhost/api/debug/error
echo ""
echo "Logs show error but no correlation between request and error"

# Test 4: Simulate a slow request
echo "=== Simulating slow request ==="
timeout 10 curl -k -s https://localhost/api/debug/slow?delay=6 > /dev/null
echo ""
echo "No indication of which request was slow or why"
```

### Step 4: Understanding the Observability Problems

**Problem 1: No Request Tracing**
- Can't correlate requests across services
- No unique request IDs
- Hard to debug distributed issues

**Problem 2: Basic Logging**
- Missing timing information
- No upstream details
- No client information
- Hard to parse

**Problem 3: No Debugging Endpoints**
- Can't inspect current state
- No health information
- No way to test components

**Problem 4: No Error Correlation**
- Can't see what caused errors
- No request context in error logs
- Hard to reproduce issues

### Step 5: The Fix - Complete Observability Configuration

**File: `nginx.conf` (FIXED - With Full Observability)**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # FIXED: Structured JSON logging
    log_format json escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request_id":"$request_id",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_status":$upstream_status,'
        '"upstream_response_time":$upstream_response_time,'
        '"http_referer":"$http_referer",'
        '"http_user_agent":"$http_user_agent",'
        '"http_x_forwarded_for":"$http_x_forwarded_for"'
    '}';

    # FIXED: Use JSON logs
    access_log /var/log/nginx/access.log json;
    error_log /var/log/nginx/error.log;

    # FIXED: Add request ID to every request
    # Generate unique ID if not provided
    map $http_x_request_id $request_id {
        default $http_x_request_id;
        '' $request_uuid;
    }

    # Generate unique ID for each request
    # Use built-in variable if available, otherwise generate
    server_tokens off;

    sendfile on;
    keepalive_timeout 65;

    upstream api_backend {
        server fastapi-blue:8000 max_fails=3 fail_timeout=30s;
        server fastapi-green:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
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
        add_header X-XSS-Protection "1; mode=block" always;

        # FIXED: Request ID generation and propagation
        location /api/ {
            # Generate request ID
            set $request_uuid $request_id;
            if ($request_uuid = "") {
                set $request_uuid $request_id;
            }
            
            proxy_pass http://api_backend/;
            
            # FIXED: Forward request ID to upstream
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_uuid;
            
            # FIXED: Log request ID in access log
            proxy_set_header X-Request-ID $request_uuid;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # FIXED: Debug endpoints for observability
        location /debug/headers {
            proxy_pass http://api_backend/debug/headers;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # Health check endpoint
        location /health {
            proxy_pass http://api_backend/health;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # FIXED: Nginx status endpoint
        location /nginx-status {
            # Only allow from internal networks
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            stub_status on;
            access_log off;
        }

        # FIXED: Configuration test endpoint
        location /nginx-config {
            # Only allow from internal networks
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 "Configuration loaded at: $time_iso8601\n";
        }

        # FIXED: Upstream status check
        location /upstream-status {
            # Only allow from internal networks
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            proxy_pass http://api_backend/health;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
    }

    # HTTP redirect
    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

### Step 6: Structured Logging Deep Dive

**File: `nginx-structured-logging.conf`**
```nginx
# Comprehensive Structured Logging Configuration

# Detailed JSON log format with all available fields
log_format json_detailed escape=json '{'
    '"timestamp":"$time_iso8601",'
    '"remote_addr":"$remote_addr",'
    '"remote_port":"$remote_port",'
    '"request_id":"$request_id",'
    '"request_method":"$request_method",'
    '"request_uri":"$request_uri",'
    '"request_length":$request_length,'
    '"status":$status,'
    '"body_bytes_sent":$body_bytes_sent,'
    '"bytes_sent":$bytes_sent,'
    '"request_time":$request_time,'
    '"upstream_addr":"$upstream_addr",'
    '"upstream_status":$upstream_status,'
    '"upstream_response_time":$upstream_response_time,'
    '"upstream_connect_time":$upstream_connect_time,'
    '"upstream_header_time":$upstream_header_time,'
    '"http_host":"$http_host",'
    '"http_referer":"$http_referer",'
    '"http_user_agent":"$http_user_agent",'
    '"http_x_forwarded_for":"$http_x_forwarded_for",'
    '"http_x_request_id":"$http_x_request_id",'
    '"ssl_protocol":"$ssl_protocol",'
    '"ssl_cipher":"$ssl_cipher",'
    '"server_name":"$server_name",'
    '"server_port":"$server_port"'
'}';

# Access log with detailed format
access_log /var/log/nginx/access.log json_detailed;
error_log /var/log/nginx/error.log warn;

# Separate logs for different components
access_log /var/log/nginx/api-access.log json_detailed if=$is_api_request;
access_log /var/log/nginx/static-access.log json_detailed if=$is_static_request;

# Map requests to different log files
map $request_uri $is_api_request {
    ~^/api/  1;
    default  0;
}

map $request_uri $is_static_request {
    ~*\.(jpg|jpeg|png|gif|ico|css|js|svg)$ 1;
    default 0;
}
```

### Step 7: Advanced Debugging Tools

**File: `nginx-debug-tools.conf`**
```nginx
# Advanced Debugging Tools

# Debugging with headers
location /debug/request {
    # Echo back all request information
    return 200 "Request Information:\n"
        "Method: $request_method\n"
        "URI: $request_uri\n"
        "Host: $http_host\n"
        "Remote Addr: $remote_addr\n"
        "X-Forwarded-For: $http_x_forwarded_for\n"
        "Request ID: $request_id\n"
        "User Agent: $http_user_agent\n"
        "Referer: $http_referer\n"
        "Request Time: $request_time\n";
}

# Debugging with trace logging
location /debug/trace {
    # Enable trace logging for this request
    access_log /var/log/nginx/trace-access.log json_detailed;
    error_log /var/log/nginx/trace-error.log debug;
    
    proxy_pass http://api_backend/;
    proxy_set_header X-Trace-Enabled "true";
    proxy_set_header X-Request-ID $request_id;
}

# Performance debugging
location /debug/perf {
    # Measure time spent in each phase
    set $start_time $msec;
    set $upstream_start_time $upstream_response_time;
    
    proxy_pass http://api_backend/;
    
    # Add timing headers
    add_header X-Total-Time $request_time;
    add_header X-Upstream-Time $upstream_response_time;
    
    # Log performance data
    access_log /var/log/nginx/perf-access.log json_detailed;
}

# Connection debugging
location /debug/connections {
    # Show connection information
    return 200 "Connection Information:\n"
        "Remote Addr: $remote_addr:$remote_port\n"
        "Local Addr: $server_addr:$server_port\n"
        "SSL Protocol: $ssl_protocol\n"
        "SSL Cipher: $ssl_cipher\n"
        "Connection: $connection\n"
        "Keepalive: $keepalive\n";
}

# Request validation
location /debug/validate {
    # Validate request integrity
    if ($http_x_request_id = "") {
        return 400 "Missing X-Request-ID header";
    }
    
    # Validate content type
    if ($content_type != "application/json") {
        return 400 "Invalid content type";
    }
    
    proxy_pass http://api_backend/;
}
```

### Step 8: Production Hardening

**File: `nginx-production-hardening.conf`**
```nginx
# Production Hardening Configuration

# Security Headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=()" always;

# Rate Limiting
limit_req_zone $binary_remote_addr zone=global_limit:10m rate=100r/m;
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=10r/m;

# Connection Limits
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

# Server Hardening
server_tokens off;  # Hide Nginx version
client_max_body_size 10M;
client_body_timeout 60s;
client_header_timeout 60s;
send_timeout 60s;

# Buffer Protection
client_body_buffer_size 128k;
client_header_buffer_size 1k;
large_client_header_buffers 4 8k;

# Request Limits
limit_req zone=global_limit burst=20 nodelay;
limit_conn conn_limit 10;

# SSL Hardening
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1h;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;

# Access Control
location /admin/ {
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    allow 192.168.0.0/16;
    deny all;
}

# Method Restrictions
if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
    return 405;
}

# Prevent Query String Injection
if ($query_string ~* "<.*>") {
    return 400;
}

# Protect Against Path Traversal
if ($request_uri ~* "\.\./") {
    return 403;
}
```

### Step 9: Monitoring and Alerting

**File: `monitoring-health-check.sh`**
```bash
#!/bin/bash
# health-check.sh - Comprehensive health monitoring

echo "=== Health Check Report ==="
echo ""

# Check 1: Nginx is running
echo "1. Nginx Status:"
docker ps | grep nginx-proxy
echo ""

# Check 2: Nginx endpoints
echo "2. Endpoint Health:"
for endpoint in / /health /debug/headers /api/; do
    status=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost$endpoint 2>/dev/null)
    echo "  $endpoint: $status"
done
echo ""

# Check 3: Upstream health
echo "3. Upstream Health:"
for service in fastapi-blue fastapi-green; do
    port=$(docker inspect "$service" 2>/dev/null | grep -A 10 "PortBindings" | grep HostPort | cut -d'"' -f4)
    if [ -n "$port" ]; then
        status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port/health" 2>/dev/null)
        echo "  $service (port $port): $status"
    else
        echo "  $service: not running"
    fi
done
echo ""

# Check 4: Log health
echo "4. Log Health:"
echo "  Access logs:"
    tail -3 logs/access.log | python -m json.tool 2>/dev/null | head -5
echo ""
echo "  Error logs:"
tail -3 logs/error.log
echo ""

# Check 5: Performance metrics
echo "5. Performance Metrics:"
if [ -f logs/access.log ]; then
    echo "  Total requests: $(cat logs/access.log | wc -l)"
    echo "  Average response time: $(tail -100 logs/access.log | python -c "
import json, sys, statistics
times = []
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'request_time' in data:
            times.append(float(data['request_time']))
    except:
        pass
if times:
    print(f\"{statistics.mean(times):.3f}s (mean), {statistics.median(times):.3f}s (median), {max(times):.3f}s (max)\")
else:
    print('No data')
")"
fi
echo ""

# Check 6: Cache status
echo "6. Cache Status:"
if [ -d /var/cache/nginx ]; then
    echo "  Cache size: $(du -sh /var/cache/nginx 2>/dev/null | cut -f1)"
    echo "  Cache files: $(find /var/cache/nginx -type f 2>/dev/null | wc -l)"
fi
echo ""

# Check 7: Disk usage
echo "7. Disk Usage:"
df -h /var/lib/docker | tail -1
echo ""

# Check 8: Memory usage
echo "8. Memory Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.MemPerc}}" | head -10
echo ""

# Check 9: Connection count
echo "9. Active Connections:"
docker exec nginx-proxy netstat -an | grep ':443' | wc -l
echo ""

echo "=== Health Check Complete ==="
```

**File: `alerting-rules.sh`**
```bash
#!/bin/bash
# alerting-rules.sh - Production alerting rules

# Alert if too many errors
ERROR_COUNT=$(tail -100 logs/access.log | python -c "
import json, sys
errors = 0
for line in sys.stdin:
    try:
        data = json.loads(line)
        if data.get('status', 200) >= 500:
            errors += 1
    except:
        pass
print(errors)
")
if [ $ERROR_COUNT -gt 10 ]; then
    echo "ALERT: High error rate ($ERROR_COUNT errors in last 100 requests)"
fi

# Alert on high response time
AVG_TIME=$(tail -100 logs/access.log | python -c "
import json, sys, statistics
times = []
for line in sys.stdin:
    try:
        data = json.loads(line)
        if 'request_time' in data:
            times.append(float(data['request_time']))
    except:
        pass
if times:
    print(statistics.mean(times))
else:
    print(0)
")
if (( $(echo "$AVG_TIME > 2.0" | bc -l) )); then
    echo "ALERT: High average response time ($AVG_TIME seconds)"
fi

# Alert if upstream is unhealthy
for service in fastapi-blue fastapi-green; do
    if ! docker ps | grep -q $service; then
        echo "ALERT: $service is not running"
    fi
done

# Alert on high memory usage
MEM_USAGE=$(docker stats --no-stream --format "{{.MemPerc}}" | head -1 | cut -d'%' -f1)
if (( $(echo "$MEM_USAGE > 80" | bc -l) )); then
    echo "ALERT: High memory usage ($MEM_USAGE%)"
fi
```

### Step 10: Troubleshooting Runbook

**File: `troubleshooting-runbook.md`**
```markdown
# Nginx Production Troubleshooting Runbook

## Symptom: 502 Bad Gateway

### Investigation
1. Check upstream health:
   ```bash
   curl -k https://localhost/upstream-status
   ```

2. Check upstream logs:
   ```bash
   docker logs fastapi-blue --tail 50
   docker logs fastapi-green --tail 50
   ```

3. Check Nginx logs for upstream errors:
   ```bash
   grep "upstream" logs/error.log
   ```

### Common Causes
- Upstream service crashed
- Port configuration mismatch
- Network connectivity issues
- Timeout configuration too low

### Resolution
1. Restart upstream:
   ```bash
   docker compose restart fastapi-blue
   ```

2. Verify connectivity:
   ```bash
   docker exec nginx-proxy ping fastapi-blue
   ```

3. Increase timeouts if needed:
   ```nginx
   proxy_connect_timeout 10s;
   proxy_read_timeout 120s;
   ```

## Symptom: 504 Gateway Timeout

### Investigation
1. Check request times:
   ```bash
   tail -100 logs/access.log | python -m json.tool | grep request_time
   ```

2. Test upstream directly:
   ```bash
   time curl -s http://localhost:8000/api/slow
   ```

### Resolution
1. Increase timeout:
   ```nginx
   proxy_read_timeout 300s;
   ```

2. Optimize upstream:
   - Add caching for slow endpoints
   - Scale horizontally with load balancing

## Symptom: 503 Service Unavailable

### Investigation
1. Check all upstream instances:
   ```bash
   curl -k https://localhost/upstream-status
   ```

2. Check resource usage:
   ```bash
   docker stats
   ```

### Resolution
1. Increase upstream instances
2. Adjust load balancing weights
3. Increase memory/CPU limits

## Symptom: 429 Too Many Requests

### Investigation
1. Check rate limiting configuration:
   ```bash
   grep -A5 "limit_req" nginx.conf
   ```

2. Monitor current rate:
   ```bash
   watch -n1 "tail -100 logs/access.log | wc -l"
   ```

### Resolution
1. Increase rate limits if legitimate:
   ```nginx
   limit_req zone=api_limit rate=100r/m;
   ```

2. Add burst capacity:
   ```nginx
   limit_req zone=api_limit burst=20 nodelay;
   ```

## Generic Debugging Process

### Step 1: Identify the Failure Layer
1. Browser devtools -> Check response status
2. Nginx logs -> Check upstream status
3. Application logs -> Check application errors

### Step 2: Isolate with Direct Access
```bash
# Bypass Nginx
curl -v http://localhost:8000/api/

# Test with headers
curl -v -H "X-Request-ID: test" https://localhost/api/
```

### Step 3: Enable Debug Logging
```nginx
# In nginx.conf
error_log /var/log/nginx/debug.log debug;
```

### Step 4: Reproduce and Trace
```bash
# Trace full request path
curl -v -H "X-Trace: enabled" https://localhost/api/
```

### Step 5: Fix and Verify
```bash
# Apply fix
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -s reload

# Verify
curl -v https://localhost/api/
```
```

### Step 11: Testing Observability

```bash
# Reload Nginx with observability
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -s reload

# Wait for reload
sleep 2

echo "=== Test 1: Request Tracing ==="
# Make request with custom request ID
curl -k -H "X-Request-ID: test-123" https://localhost/api/
echo ""
echo "Check logs for request ID: test-123"
tail -5 logs/access.log | grep test-123 | python -m json.tool

echo ""
echo "=== Test 2: Structured Logging ==="
curl -k -s https://localhost/api/ > /dev/null
echo "Structured logs:"
tail -3 logs/access.log | python -m json.tool

echo ""
echo "=== Test 3: Debug Endpoints ==="
echo "Headers debug:"
curl -k -s https://localhost/debug/headers | python -m json.tool | head -10

echo ""
echo "Health check:"
curl -k -s https://localhost/health | python -m json.tool

echo ""
echo "=== Test 4: Performance Monitoring ==="
curl -k -s https://localhost/api/debug/slow?delay=1 > /dev/null
echo "Check response time in logs:"
tail -3 logs/access.log | grep "slow" | python -m json.tool

echo ""
echo "=== Test 5: Error Tracking ==="
curl -k -s https://localhost/api/debug/error > /dev/null
echo "Check error log:"
tail -5 logs/error.log

echo ""
echo "=== Test 6: Upstream Status ==="
curl -k -s https://localhost/upstream-status | python -m json.tool

echo ""
echo "Observability testing complete!"
```

## Verification Checklist

### ✅ Check 1: Request IDs Propagate
```bash
curl -k -I -H "X-Request-ID: test-123" https://localhost/api/ | grep "X-Request-ID"
# Should show: X-Request-ID: test-123
```

### ✅ Check 2: Structured Logging Works
```bash
tail -1 logs/access.log | python -m json.tool
# Should show valid JSON
```

### ✅ Check 3: Debug Endpoints Accessible
```bash
curl -k -s https://localhost/debug/headers | python -m json.tool
# Should show headers
```

### ✅ Check 4: Health Check Works
```bash
curl -k -s https://localhost/health | python -m json.tool
# Should show healthy
```

### ✅ Check 5: Error Logging Works
```bash
curl -k -s https://localhost/api/debug/error > /dev/null
tail -1 logs/error.log | grep "error"
# Should show error
```

## Common Pitfalls and Solutions

### Pitfall 1: Logging Not Structured
**Symptom:** Logs are hard to parse
**Solution:** Use JSON format
```nginx
log_format json escape=json '{...}';
access_log /var/log/nginx/access.log json;
```

### Pitfall 2: Missing Request IDs
**Symptom:** Can't trace requests across services
**Solution:** Generate and forward request IDs
```nginx
proxy_set_header X-Request-ID $request_id;
```

### Pitfall 3: Too Much Logging
**Symptom:** Log files grow too quickly
**Solution:** Use log rotation and appropriate log levels
```nginx
error_log /var/log/nginx/error.log warn;
```

## What You've Learned

By completing Part 8, you can now:

- ✅ Configure structured JSON logging
- ✅ Generate and propagate request IDs
- ✅ Debug with comprehensive tools
- ✅ Monitor system health
- ✅ Set up alerting rules
- ✅ Production harden Nginx
- ✅ Troubleshoot common failures
- ✅ Create troubleshooting runbooks

## Next Steps

**Part 9: Production Security Hardening** builds on our observable gateway. You'll learn:

- Advanced security headers
- TLS hardening
- Rate limiting strategies
- Attack prevention
- Security testing

Your gateway is now observable. Let's make it bulletproof.
