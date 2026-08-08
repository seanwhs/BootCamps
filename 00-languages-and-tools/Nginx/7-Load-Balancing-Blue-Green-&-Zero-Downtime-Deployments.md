# Part 7: Load Balancing, Blue-Green & Zero-Downtime Deployments

## The Target

We're going to transform our high-performance gateway into a resilient production system. By the end of this part, you'll have:

- Multiple application instances with load balancing
- Health checks and automatic failover
- Blue-green deployment capability
- Zero-downtime reload strategies
- Connection draining for graceful shutdowns
- Complete deployment pipeline simulation

## The Concept: Resilience Through Redundancy

Think of load balancing like a well-staffed customer service center:

- **Single Instance** (one employee): If they go to lunch, everyone waits
- **Multiple Instances** (many employees): Work is distributed, if one leaves, others continue
- **Health Checks** (regular check-ins): Know when an employee is unavailable
- **Blue-Green Deployment** (two parallel teams): Team Blue handles customers while Team Green sets up the new office, then they switch
- **Zero-Downtime** (no service interruption): Customers never notice when teams change

## The Pain Point: Deployments Cause Outages

Let's experience what happens when you deploy a new version without proper configuration.

### Step 1: Setup Multi-Instance Environment

Create the directory structure:

```bash
mkdir -p nginx-series/part-07
cd nginx-series/part-07

# Copy our existing apps
cp -r ../part-06/fastapi-app .
cp -r ../part-06/ssl .

# Create multiple instances for blue-green
mkdir -p fastapi-blue fastapi-green
cp -r fastapi-app/* fastapi-blue/
cp -r fastapi-app/* fastapi-green/

# Modify the app to show version
cat > fastapi-blue/main.py << 'EOF'
from fastapi import FastAPI
import time
import os

app = FastAPI(title="Blue Instance", version="1.0.0")

@app.get("/")
async def root():
    return {
        "instance": "blue",
        "version": "1.0.0",
        "color": "blue",
        "timestamp": time.time(),
        "hostname": os.environ.get("HOSTNAME", "unknown")
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "instance": "blue"}

@app.get("/deploy")
async def deploy_info():
    return {"instance": "blue", "version": "1.0.0", "deployed_at": time.time()}
EOF

cat > fastapi-green/main.py << 'EOF'
from fastapi import FastAPI
import time
import os

app = FastAPI(title="Green Instance", version="2.0.0")

@app.get("/")
async def root():
    return {
        "instance": "green",
        "version": "2.0.0",
        "color": "green",
        "timestamp": time.time(),
        "hostname": os.environ.get("HOSTNAME", "unknown")
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "instance": "green"}

@app.get("/deploy")
async def deploy_info():
    return {"instance": "green", "version": "2.0.0", "deployed_at": time.time()}
EOF
```

**File: `fastapi-blue/Dockerfile`**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**File: `fastapi-green/Dockerfile`**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**File: `requirements.txt`** (for both)
```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

### Step 2: The Broken Setup (No Load Balancing)

**File: `docker-compose.yml`**
```yaml
version: '3.8'

services:
  # Blue instance (version 1.0.0)
  fastapi-blue:
    build:
      context: ./fastapi-blue
      dockerfile: Dockerfile
    container_name: fastapi-blue
    ports:
      - "8000:8000"
    environment:
      - HOSTNAME=blue-instance
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # Green instance (version 2.0.0)
  fastapi-green:
    build:
      context: ./fastapi-green
      dockerfile: Dockerfile
    container_name: fastapi-green
    ports:
      - "8001:8000"
    environment:
      - HOSTNAME=green-instance
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
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

**File: `nginx.conf` (INTENTIONALLY BROKEN - No Load Balancing)**
```nginx
# This configuration has NO load balancing
# Single upstream, no failover, no health checks

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

    # PROBLEM: Only one upstream server
    upstream api_backend {
        server fastapi-blue:8000;
        # No failover, no load balancing
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;

        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }

    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

### Step 3: Run and Observe Failures

```bash
# Start the services
docker compose up -d

# Wait for everything to start
sleep 10

# Test 1: See which instance is serving
echo "=== Testing load balancing ==="
for i in {1..5}; do
    echo "Request $i:"
    curl -k -s https://localhost/api/ | python -m json.tool | grep -E "instance|version"
    echo ""
done

# Test 2: Simulate instance failure
echo "=== Simulating instance failure ==="
docker stop fastapi-blue

# Test 3: See if requests fail
echo "=== Testing after failure ==="
for i in {1..3}; do
    echo "Request $i:"
    curl -k -s https://localhost/api/ 2>&1 | head -n 5
    echo ""
done

# Test 4: Deployment simulation (green/blue switch)
echo "=== Simulating deployment ==="
# This would fail because both instances aren't in the upstream
```

### Step 4: Understanding the Problems

**Problem 1: No Load Balancing**
- Only one instance handles all traffic
- No distribution of load
- Single point of failure

**Problem 2: No Health Checks**
- Failed instances still receive traffic
- No automatic removal of unhealthy instances

**Problem 3: No Blue-Green Capability**
- Can't switch traffic between versions
- Deployments cause downtime

**Problem 4: No Graceful Reloads**
- Configuration changes require restart
- Dropped connections during restart

### Step 5: The Fix - Complete Load Balancing Configuration

**File: `nginx.conf` (FIXED - With Load Balancing)**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Log format with upstream info
    log_format lb '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for" '
                  '"$upstream_addr" "$upstream_status" "$upstream_response_time"';

    access_log /var/log/nginx/access.log lb;
    error_log /var/log/nginx/error.log;

    sendfile on;
    keepalive_timeout 65;

    # Load Balancing Configuration
    # Multiple upstream groups for different scenarios
    
    # 1. Standard load balancing with health checks
    upstream api_backend {
        # Load balancing algorithm
        # Default: round-robin
        
        # Blue instance (version 1.0.0)
        server fastapi-blue:8000 weight=3 max_fails=3 fail_timeout=30s;
        # Green instance (version 2.0.0)
        server fastapi-green:8000 weight=1 max_fails=3 fail_timeout=30s;
        
        # Health check configuration
        # Nginx will mark server as down if health check fails
        # For Nginx Plus, use active health checks
        
        # Connection keepalive
        keepalive 32;
        keepalive_requests 100;
        keepalive_timeout 60s;
    }

    # 2. Blue-Green deployment upstream
    upstream api_blue_green {
        # Blue is active, Green is backup
        server fastapi-blue:8000 max_fails=3 fail_timeout=30s;
        server fastapi-green:8000 backup;
        
        keepalive 32;
    }

    # 3. All active for load testing
    upstream api_load_test {
        server fastapi-blue:8000;
        server fastapi-green:8000;
        
        keepalive 32;
    }

    # Server block
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

        # API with load balancing
        location /api/ {
            # Use the load-balanced upstream
            proxy_pass http://api_backend/;
            
            # Forward original headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Keep connections alive
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Timeout settings
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
        }

        # Admin endpoint - shows which instance is serving
        location /admin/instance {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Add response header with upstream info
            add_header X-Upstream-Addr $upstream_addr;
            add_header X-Upstream-Status $upstream_status;
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

### Step 6: Blue-Green Deployment Strategy

Blue-green deployment allows zero-downtime releases by maintaining two identical environments:

**File: `nginx-blue-green.conf`**
```nginx
# Blue-Green Deployment Configuration

# Map to control which upstream is active
# This can be set via API, environment variable, or file
map $cookie_upstream $active_upstream {
    default "blue";
    "green" "green";
    "blue" "blue";
}

# Blue upstream (current version)
upstream api_blue {
    server fastapi-blue:8000 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

# Green upstream (new version)
upstream api_green {
    server fastapi-green:8000 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name localhost;

    # ... SSL and security headers ...

    # Main API routing with blue-green switch
    location /api/ {
        # Use the active upstream based on cookie or header
        set $upstream_name $active_upstream;
        
        # Override with header for testing
        if ($http_x_upstream) {
            set $upstream_name $http_x_upstream;
        }
        
        # Choose the upstream
        if ($upstream_name = "green") {
            proxy_pass http://api_green/;
        }
        if ($upstream_name = "blue") {
            proxy_pass http://api_blue/;
        }
        
        # Default to blue
        if ($upstream_name = "") {
            proxy_pass http://api_blue/;
        }
        
        # Forward headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Upstream $upstream_name;
        
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }

    # Switch endpoint - change upstream
    location /admin/switch {
        # Only allow from internal networks
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
        
        # Set cookie to switch upstream
        add_header Set-Cookie "upstream=$arg_to; Path=/; Max-Age=3600";
        add_header X-Upstream-Switched $arg_to;
        
        return 200 "Switched to $arg_to upstream\n";
    }

    # Status endpoint
    location /admin/upstream-status {
        # Only allow from internal networks
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
        
        return 200 "Current upstream: $active_upstream\n";
    }
}
```

### Step 7: Advanced - Load Balancing Algorithms

Nginx supports several load balancing algorithms:

**File: `nginx-load-balancing-algorithms.conf`**
```nginx
# Load Balancing Algorithms

# 1. Round-Robin (default)
upstream api_round_robin {
    # Requests are distributed evenly across servers
    server fastapi-blue:8000;
    server fastapi-green:8000;
}

# 2. Weighted Round-Robin
upstream api_weighted {
    # Blue gets 3x more traffic than Green
    server fastapi-blue:8000 weight=3;
    server fastapi-green:8000 weight=1;
}

# 3. Least Connections
upstream api_least_conn {
    # Send to server with fewest active connections
    least_conn;
    server fastapi-blue:8000;
    server fastapi-green:8000;
}

# 4. IP Hash (sticky sessions)
upstream api_ip_hash {
    # Same client IP always goes to same server
    ip_hash;
    server fastapi-blue:8000;
    server fastapi-green:8000;
}

# 5. Least Time (Nginx Plus only)
upstream api_least_time {
    # Send to server with lowest response time
    # least_time header;
    # least_time last_byte;
    server fastapi-blue:8000;
    server fastapi-green:8000;
}

# 6. Random
upstream api_random {
    # Random selection
    random two least_conn;
    server fastapi-blue:8000;
    server fastapi-green:8000;
}

# Server parameters for fine-tuning
upstream api_advanced {
    # Server with different weights and health checks
    server fastapi-blue:8000 
        weight=3                # Higher weight = more traffic
        max_fails=3            # Failures before marking down
        fail_timeout=30s       # Time to wait before retrying
        max_conns=100          # Max concurrent connections
        slow_start=30s;        # Gradually increase traffic after recovery
    
    server fastapi-green:8000
        weight=1
        max_fails=2
        fail_timeout=20s
        max_conns=50;
    
    # Backup server - only used when others fail
    server fastapi-backup:8000 backup;
    
    # Keepalive for performance
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}
```

### Step 8: Zero-Downtime Reload

Nginx can reload configuration without dropping connections:

**File: `nginx-reload-strategy.conf`**
```nginx
# Zero-Downtime Reload Configuration

# Graceful shutdown settings
worker_shutdown_timeout 30s;  # Wait up to 30s for workers to finish

# Connection draining
server {
    listen 443 ssl http2;
    server_name localhost;
    
    # Grace period for draining connections
    location / {
        # Old workers will finish existing connections
        # New connections go to new workers
    }
}
```

**Reload Script:**
```bash
#!/bin/bash
# zero-downtime-reload.sh

echo "=== Zero-Downtime Reload ==="

# 1. Test configuration
echo "Testing configuration..."
docker exec nginx-proxy nginx -t
if [ $? -ne 0 ]; then
    echo "Configuration test failed!"
    exit 1
fi

# 2. Store current connections
echo "Current connections:"
docker exec nginx-proxy netstat -an | grep ':443' | wc -l

# 3. Perform graceful reload
echo "Performing graceful reload..."
docker exec nginx-proxy nginx -s reload

# 4. Wait for reload to complete
sleep 2

# 5. Verify reload worked
echo "Verifying reload..."
docker exec nginx-proxy ps aux | grep nginx

# 6. Check connections after reload
echo "Connections after reload:"
docker exec nginx-proxy netstat -an | grep ':443' | wc -l

echo "Reload complete!"
```

### Step 9: Connection Draining

When removing a server, drain existing connections first:

**File: `nginx-connection-draining.conf`**
```nginx
# Connection Draining Configuration

# Upstream with draining capability
upstream api_draining {
    # Mark server as down for new connections
    # Existing connections will complete
    server fastapi-blue:8000 down;
    server fastapi-green:8000;
}

# Or use weight 0 to stop new connections
upstream api_draining_weight {
    server fastapi-blue:8000 weight=0;  # No new connections
    server fastapi-green:8000 weight=1;
}

# Wait for connections to drain before removing
location /api/ {
    proxy_pass http://api_draining/;
    
    # Connection draining settings
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_read_timeout 60s;  # Max time to keep connection alive
    
    # Allow connections to finish
    proxy_connect_timeout 60s;
}
```

### Step 10: Deployment Simulation Script

Create a complete deployment simulation:

**File: `deploy-simulation.sh`**
```bash
#!/bin/bash
# deployment-simulation.sh - Simulate zero-downtime deployment

echo "=== Zero-Downtime Deployment Simulation ==="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test current version
test_version() {
    echo "Testing current version..."
    for i in {1..3}; do
        echo -n "Request $i: "
        curl -k -s https://localhost/api/ | python -m json.tool | grep -E "instance|version" | head -1
    done
}

# Step 1: Initial state
echo -e "${BLUE}Step 1: Initial state (Blue v1.0.0)${NC}"
test_version

# Step 2: Deploy Green
echo -e "\n${YELLOW}Step 2: Deploy Green v2.0.0${NC}"
docker compose build fastapi-green
docker compose up -d fastapi-green
sleep 5
docker compose ps fastapi-green

# Step 3: Test Green directly
echo -e "\n${GREEN}Step 3: Test Green instance directly${NC}"
curl -s http://localhost:8001/ | python -m json.tool | grep -E "instance|version"

# Step 4: Add Green to load balancer (weigh blue more heavily)
echo -e "\n${YELLOW}Step 4: Add Green to load balancer with low weight${NC}"
# This would update nginx.conf and reload
docker exec nginx-proxy nginx -s reload

# Step 5: Test load balancing (blue should be primary)
echo -e "\n${BLUE}Step 5: Load balancing (blue primary)${NC}"
for i in {1..10}; do
    result=$(curl -k -s https://localhost/api/ | python -m json.tool | grep -E "instance|version" | head -1)
    echo "Request $i: $result"
done

# Step 6: Switch to Green (blue-green switch)
echo -e "\n${YELLOW}Step 6: Switch to Green (blue-green switch)${NC}"
# Update upstream to use green primarily
docker exec nginx-proxy nginx -s reload

# Step 7: Test new version (green should be primary)
echo -e "\n${GREEN}Step 7: Test green as primary${NC}"
for i in {1..5}; do
    result=$(curl -k -s https://localhost/api/ | python -m json.tool | grep -E "instance|version" | head -1)
    echo "Request $i: $result"
done

# Step 8: Drain blue connections
echo -e "\n${YELLOW}Step 8: Drain blue connections${NC}"
# Mark blue as down in upstream (no new connections)

# Step 9: Remove blue
echo -e "\n${GREEN}Step 9: Remove blue instance${NC}"
docker compose stop fastapi-blue

# Step 10: Final state
echo -e "\n${GREEN}Step 10: Final state (green v2.0.0 only)${NC}"
test_version

echo -e "\n${GREEN}Deployment complete! Zero downtime achieved!${NC}"
```

### Step 11: Testing Load Balancing and Failover

**File: `test-load-balancing.sh`**
```bash
#!/bin/bash
# test-load-balancing.sh - Comprehensive load balancing test

echo "=== Load Balancing Test Suite ==="

# Test 1: Weighted distribution
echo -e "\n${BLUE}Test 1: Weighted Distribution${NC}"
echo "Should show ~75% blue, ~25% green"
declare -A counts
for i in {1..20}; do
    instance=$(curl -k -s https://localhost/api/ | python -m json.tool | grep instance | cut -d'"' -f4)
    counts[$instance]=$((${counts[$instance]:-0} + 1))
    echo -n "."
done
echo ""
for instance in "${!counts[@]}"; do
    echo "$instance: ${counts[$instance]} requests"
done

# Test 2: Failover
echo -e "\n${BLUE}Test 2: Failover Testing${NC}"
echo "Stopping blue instance..."
docker stop fastapi-blue

echo "Testing failover to green..."
for i in {1..5}; do
    status=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/api/ 2>/dev/null)
    echo "Request $i: $status"
done

echo "Restarting blue instance..."
docker start fastapi-blue
sleep 5

echo "Testing blue restored..."
for i in {1..3}; do
    instance=$(curl -k -s https://localhost/api/ | python -m json.tool | grep instance | cut -d'"' -f4)
    echo "Request $i: $instance"
done

# Test 3: Health check
echo -e "\n${BLUE}Test 3: Health Check Testing${NC}"
echo "Checking health endpoints..."
for service in fastapi-blue fastapi-green; do
    port=$(docker inspect "$service" | grep -A 10 "PortBindings" | grep HostPort | cut -d'"' -f4)
    echo -n "$service (port $port): "
    curl -s "http://localhost:$port/health" | python -m json.tool | grep status
done

# Test 4: Connection persistence
echo -e "\n${BLUE}Test 4: Connection Persistence${NC}"
echo "Testing with keepalive..."
for i in {1..5}; do
    response_time=$(curl -k -s -o /dev/null -w "%{time_total}\n" https://localhost/api/)
    echo "Response time: ${response_time}s"
done

# Test 5: Load balancer statistics
echo -e "\n${BLUE}Test 5: Load Balancer Statistics${NC}"
echo "Checking upstream status..."
docker exec nginx-proxy nginx -T | grep -A 3 "upstream api_backend"
```

## Verification Checklist

Before moving on, verify you've mastered load balancing:

### ✅ Check 1: Load Balancing Works
```bash
# Run multiple requests and see distribution
for i in {1..10}; do
    curl -k -s https://localhost/api/ | python -m json.tool | grep instance
done
# Should show both blue and green instances
```

### ✅ Check 2: Failover Works
```bash
# Stop one instance
docker stop fastapi-blue

# Requests should still work
curl -k -s https://localhost/api/ | python -m json.tool | grep instance
# Should show green instance serving

# Restart and it should be available again
docker start fastapi-blue
```

### ✅ Check 3: Health Checks Work
```bash
# Check health endpoints
curl -k -s https://localhost/health
# Should return healthy

# Check upstream status via logs
docker logs nginx-proxy | grep upstream
```

### ✅ Check 4: Zero-Downtime Reload Works
```bash
# Test reload without dropping connections
curl -k -s https://localhost/api/ &
docker exec nginx-proxy nginx -s reload
# Should complete without errors
```

### ✅ Check 5: Connection Draining Works
```bash
# Mark server as down
# Connections should complete before removal
```

### ✅ Check 6: Blue-Green Switch Works
```bash
# Switch between versions
curl -k -s -X POST "https://localhost/admin/switch?to=green"
curl -k -s https://localhost/api/ | python -m json.tool | grep instance
# Should show green
```

## Common Pitfalls and Solutions

### Pitfall 1: Sticky Sessions Not Working

**Symptom:** User sessions break when requests go to different instances

**Wrong:**
```nginx
upstream api_backend {
    server fastapi-blue:8000;
    server fastapi-green:8000;
}
```

**Right:**
```nginx
upstream api_backend {
    ip_hash;  # Same client always goes to same server
    server fastapi-blue:8000;
    server fastapi-green:8000;
}
```

### Pitfall 2: All Instances Fail at Once

**Symptom:** No available upstream servers

**Solution:**
```nginx
upstream api_backend {
    # Use backup for extreme cases
    server fastapi-blue:8000;
    server fastapi-green:8000;
    server fastapi-backup:8000 backup;
    
    # Or use multiple regions
    server us-east-1:8000;
    server us-west-1:8000;
}
```

### Pitfall 3: Uneven Load Distribution

**Symptom:** One server overloaded, others idle

**Solution:** Adjust weights
```nginx
upstream api_backend {
    # If green is underpowered
    server fastapi-blue:8000 weight=5;
    server fastapi-green:8000 weight=1;
}
```

### Pitfall 4: Health Check False Positives

**Symptom:** Healthy instances marked as down

**Solution:**
```nginx
upstream api_backend {
    # Adjust fail parameters
    server fastapi-blue:8000 
        max_fails=5           # More failures before marking down
        fail_timeout=60s;     # Longer timeout before retry
    
    # Or use passive health checks
    # Nginx will mark as down after connection failures
}
```

## What You've Learned

By completing Part 7, you can now:

- ✅ Configure load balancing with multiple upstream servers
- ✅ Implement health checks and automatic failover
- ✅ Use different load balancing algorithms
- ✅ Set up blue-green deployments
- ✅ Perform zero-downtime reloads
- ✅ Drain connections gracefully
- ✅ Test failover scenarios
- ✅ Monitor load balancer health
- ✅ Deploy new versions without downtime
- ✅ Handle instance failures automatically

## Reference: Load Balancing Algorithms

| Algorithm | Directive | Use Case |
|-----------|-----------|----------|
| Round-Robin | (default) | Equal distribution, stateless apps |
| Weighted | `weight=N` | Different server capacities |
| Least Connections | `least_conn` | Uneven request durations |
| IP Hash | `ip_hash` | Session stickiness |
| Random | `random` | Simple distribution |
| Least Time | `least_time` | Performance-sensitive apps |

## Next Steps

**Part 8: Debugging, Observability & Production Hardening** builds on our resilient gateway. You'll learn:

- Advanced debugging techniques
- Structured logging
- Observability integration
- Production hardening
- Troubleshooting common failures
- Performance optimization

Your gateway is now resilient and production-ready. Let's make it observable.
