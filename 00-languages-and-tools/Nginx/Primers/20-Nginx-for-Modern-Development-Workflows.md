# Primer 20: Nginx for Modern Development Workflows

## The Target

This primer provides a comprehensive deep-dive guide to integrating Nginx into modern development workflows. Understanding these concepts is essential for building efficient CI/CD pipelines, development environments, and testing frameworks.

## P20.1 Development Environment Setup

### Complete Development Container

```yaml
# docker-compose.dev.yml - Development Environment
# ============================================================================
# COMPLETE DEVELOPMENT ENVIRONMENT
# Includes Nginx with hot-reload, debugging, and testing tools
# ============================================================================

version: '3.8'

services:
  # --------------------------------------------------------------------------
  # NGINX WITH HOT RELOAD
  # --------------------------------------------------------------------------
  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-dev
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"  # Admin/monitoring
    volumes:
      # Configuration with live reload
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf.d:/etc/nginx/conf.d:ro
      - ./sites:/etc/nginx/sites-enabled:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
      - ./cache:/var/cache/nginx
      - ./html:/usr/share/nginx/html:ro
      
      # Development tools
      - ./scripts:/scripts:ro
      - ./tests:/tests:ro
    environment:
      - NGINX_HOST=localhost
      - NGINX_PORT=80
      - NGINX_DEBUG=1
      - NGINX_LOG_LEVEL=debug
    networks:
      - dev-network
    depends_on:
      - backend
      - api
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
    command: >
      /bin/sh -c "
        nginx -g 'daemon off;'
      "

  # --------------------------------------------------------------------------
  # BACKEND SERVICE
  # --------------------------------------------------------------------------
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    container_name: backend-dev
    ports:
      - "3000:3000"
    volumes:
      - ./backend:/app:ro
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - NODE_OPTIONS=--inspect=0.0.0.0:9229
    networks:
      - dev-network
    command: npm run dev

  # --------------------------------------------------------------------------
  # API SERVICE
  # --------------------------------------------------------------------------
  api:
    build:
      context: ./api
      dockerfile: Dockerfile.dev
    container_name: api-dev
    ports:
      - "8000:8000"
      - "5678:5678"  # Python debug
    volumes:
      - ./api:/app:ro
    environment:
      - PYTHONUNBUFFERED=1
      - PYTHONDEBUG=1
    networks:
      - dev-network
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

  # --------------------------------------------------------------------------
  # DATABASE
  # --------------------------------------------------------------------------
  postgres:
    image: postgres:15-alpine
    container_name: postgres-dev
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=dev
      - POSTGRES_PASSWORD=dev123
      - POSTGRES_DB=app_dev
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./db/init:/docker-entrypoint-initdb.d
    networks:
      - dev-network

  redis:
    image: redis:7-alpine
    container_name: redis-dev
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - dev-network

  # --------------------------------------------------------------------------
  # DEVELOPMENT TOOLS
  # --------------------------------------------------------------------------
  # PHPMyAdmin for database management
  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: phpmyadmin-dev
    ports:
      - "8081:80"
    environment:
      - PMA_HOST=postgres
      - PMA_PORT=5432
      - UPLOAD_LIMIT=100M
    networks:
      - dev-network

  # Mailhog for email testing
  mailhog:
    image: mailhog/mailhog:latest
    container_name: mailhog-dev
    ports:
      - "8025:8025"
      - "1025:1025"
    networks:
      - dev-network

  # Prometheus for monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus-dev
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    networks:
      - dev-network
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'

  # Grafana for visualization
  grafana:
    image: grafana/grafana:latest
    container_name: grafana-dev
    ports:
      - "3000:3000"
    volumes:
      - ./monitoring/grafana:/etc/grafana/provisioning
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    networks:
      - dev-network

networks:
  dev-network:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
  prometheus-data:
  grafana-data:
```

## P20.2 Hot Reload Configuration

### Nginx with Live Reload

```nginx
# nginx-dev.conf - Development Configuration with Hot Reload
# ============================================================================
# NGINX DEVELOPMENT CONFIGURATION
# Optimized for development with hot reload and debugging
# ============================================================================

worker_processes auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log debug;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Development logging
    log_format dev escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"request_id":"$request_id",'
        '"remote_addr":"$remote_addr",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_response_time":$upstream_response_time"'
    '}';

    access_log /var/log/nginx/access.log dev;
    error_log /var/log/nginx/error.log debug;

    # Development settings
    sendfile off;  # Disable for development
    tcp_nopush off;
    tcp_nodelay on;
    keepalive_timeout 30;

    # Rate limiting (relaxed for dev)
    limit_req_zone $binary_remote_addr zone=dev:10m rate=100r/s;

    # =========================================================================
    # CORS FOR DEVELOPMENT
    # =========================================================================
    map $http_origin $cors_origin {
        default "*";
        ~^https?://(localhost|127.0.0.1|192.168\.|10\.).*$ $http_origin;
    }

    # =========================================================================
    # DEVELOPMENT SERVER
    # =========================================================================
    server {
        listen 80;
        listen [::]:80;
        server_name localhost dev.local;

        # Relaxed rate limiting
        limit_req zone=dev burst=50 nodelay;

        # CORS headers
        add_header Access-Control-Allow-Origin $cors_origin always;
        add_header Access-Control-Allow-Credentials true always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-API-Key" always;
        add_header Access-Control-Expose-Headers "X-Request-ID, X-Response-Time" always;

        # Development headers
        add_header X-Development "true" always;
        add_header X-Server "Nginx-Dev" always;
        add_header X-Response-Time $request_time always;

        # --------------------------------------------------------------------
        # LOCATION: API PROXY WITH HOT RELOAD
        # --------------------------------------------------------------------
        location /api/ {
            # Proxy to API service
            proxy_pass http://api:8000/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # Development timeouts
            proxy_connect_timeout 30s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;

            # Disable caching in development
            proxy_cache_bypass 1;
            proxy_no_cache 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            add_header Expires 0;
        }

        # --------------------------------------------------------------------
        # LOCATION: BACKEND PROXY
        # --------------------------------------------------------------------
        location / {
            # Proxy to backend service
            proxy_pass http://backend:3000/;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # WebSocket support for hot reload
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Development timeouts
            proxy_connect_timeout 30s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;

            # Disable caching
            proxy_cache_bypass 1;
            proxy_no_cache 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            add_header Expires 0;
        }

        # --------------------------------------------------------------------
        # LOCATION: STATIC FILES (DEVELOPMENT)
        # --------------------------------------------------------------------
        location /static/ {
            alias /usr/share/nginx/html/static/;

            # Relaxed caching for development
            expires 1m;
            add_header Cache-Control "public, max-age=60";

            # Enable directory listing for dev
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
        }

        # --------------------------------------------------------------------
        # LOCATION: DEVELOPMENT TOOLS
        # --------------------------------------------------------------------
        location /debug/ {
            # Development debug endpoints
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            deny all;

            # Return request info
            return 200 '
                Request Information
                ===================
                Method: $request_method
                URI: $request_uri
                Host: $http_host
                Remote: $remote_addr
                X-Forwarded-For: $http_x_forwarded_for
                Request ID: $request_id
                Response Time: $request_time
                Status: $status
                Upstream: $upstream_addr
                Cache: $upstream_cache_status
            ';
        }

        # --------------------------------------------------------------------
        # LOCATION: HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            return 200 "healthy\n";
        }

        # --------------------------------------------------------------------
        # LOCATION: NGINX STATUS
        # --------------------------------------------------------------------
        location /nginx-status {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
        }

        # --------------------------------------------------------------------
        # LOCATION: CONFIG RELOAD (DEVELOPMENT)
        # --------------------------------------------------------------------
        location /admin/reload {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;

            # Reload configuration
            nginx -s reload;
            return 200 'Configuration reloaded\n';
        }
    }
}
```

## P20.3 Development Workflow Tools

### Live Reload Script

```bash
#!/bin/bash
# dev-reload.sh - Development hot reload

echo "=== Development Hot Reload ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

WATCH_DIRS=("./nginx.conf" "./conf.d" "./sites" "./ssl")
INTERVAL=2

# Function: Reload Nginx
reload_nginx() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} Reloading Nginx..."
    
    # Test configuration
    docker exec nginx-dev nginx -t
    
    if [ $? -eq 0 ]; then
        docker exec nginx-dev nginx -s reload
        echo -e "${GREEN}✓ Reload successful${NC}"
    else
        echo -e "${YELLOW}⚠️ Configuration error, reload skipped${NC}"
    fi
}

# Function: Get file hash
get_file_hash() {
    local file=$1
    if [ -f "$file" ]; then
        md5sum "$file" 2>/dev/null | cut -d' ' -f1
    else
        echo ""
    fi
}

# Function: Watch for changes
watch_changes() {
    local hashes=()
    
    # Initialize hashes
    for dir in "${WATCH_DIRS[@]}"; do
        if [ -f "$dir" ]; then
            hashes+=("$dir:$(get_file_hash "$dir")")
        elif [ -d "$dir" ]; then
            find "$dir" -type f | while read -r file; do
                hashes+=("$file:$(get_file_hash "$file")")
            done
        fi
    done
    
    echo -e "${GREEN}Watching for configuration changes...${NC}"
    echo "Press Ctrl+C to stop"
    echo ""
    
    while true; do
        local changed=0
        local current_hashes=()
        
        # Check current hashes
        for dir in "${WATCH_DIRS[@]}"; do
            if [ -f "$dir" ]; then
                current_hashes+=("$dir:$(get_file_hash "$dir")")
            elif [ -d "$dir" ]; then
                find "$dir" -type f | while read -r file; do
                    current_hashes+=("$file:$(get_file_hash "$file")")
                done
            fi
        done
        
        # Compare with previous hashes
        for item in "${current_hashes[@]}"; do
            local file="${item%:*}"
            local hash="${item#*:}"
            
            # Find previous hash
            local old_hash=""
            for old_item in "${hashes[@]}"; do
                if [ "${old_item%:*}" = "$file" ]; then
                    old_hash="${old_item#*:}"
                    break
                fi
            done
            
            if [ "$hash" != "$old_hash" ]; then
                echo -e "${YELLOW}[$(date +'%H:%M:%S')]${NC} Change detected: $file"
                changed=1
            fi
        done
        
        # Reload if changes detected
        if [ $changed -eq 1 ]; then
            reload_nginx
            # Update hashes
            hashes=("${current_hashes[@]}")
        fi
        
        sleep $INTERVAL
    done
}

# Main execution
watch_changes
```

### Development Test Runner

```bash
#!/bin/bash
# dev-test.sh - Development test runner

echo "=== Development Test Runner ==="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TEST_DIR="./tests"
RESULT_DIR="./test-results"
mkdir -p "$RESULT_DIR"

# Function: Run configuration tests
run_config_tests() {
    echo -e "${BLUE}Running configuration tests...${NC}"
    
    # Test Nginx syntax
    echo -n "  Nginx syntax: "
    if docker exec nginx-dev nginx -t > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        docker exec nginx-dev nginx -t
        return 1
    fi
    
    # Test endpoints
    for endpoint in "/health" "/" "/api/health"; do
        echo -n "  Endpoint $endpoint: "
        status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost$endpoint" 2>/dev/null)
        if [ "$status" -ge 200 ] && [ "$status" -lt 400 ]; then
            echo -e "${GREEN}PASS${NC} (HTTP $status)"
        else
            echo -e "${RED}FAIL${NC} (HTTP $status)"
            return 1
        fi
    done
}

# Function: Run integration tests
run_integration_tests() {
    echo -e "${BLUE}Running integration tests...${NC}"
    
    # Test API endpoint
    echo -n "  API health: "
    response=$(curl -s http://localhost/api/health 2>/dev/null)
    if [[ "$response" == *"healthy"* ]]; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        return 1
    fi
    
    # Test database connectivity
    echo -n "  Database: "
    if docker exec postgres-dev pg_isready -U dev > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        return 1
    fi
    
    # Test Redis
    echo -n "  Redis: "
    if docker exec redis-dev redis-cli ping > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        return 1
    fi
}

# Function: Run performance tests
run_performance_tests() {
    echo -e "${BLUE}Running performance tests...${NC}"
    
    # Test response time
    echo -n "  Response time: "
    avg_time=$(curl -s -o /dev/null -w "%{time_total}" "http://localhost/" 2>/dev/null)
    if (( $(echo "$avg_time < 0.5" | bc -l) )); then
        echo -e "${GREEN}PASS${NC} (${avg_time}s)"
    else
        echo -e "${YELLOW}WARN${NC} (${avg_time}s)"
    fi
    
    # Test concurrent connections
    echo -n "  Concurrent: "
    if command -v ab &> /dev/null; then
        ab -n 100 -c 10 http://localhost/ > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${YELLOW}WARN${NC}"
        fi
    else
        echo "SKIP (ab not installed)"
    fi
}

# Main execution
echo ""
echo "Test Suite: $(date)"
echo "========================"
echo ""

# Run all tests
run_config_tests
CONFIG_RESULT=$?

run_integration_tests
INTEGRATION_RESULT=$?

run_performance_tests
PERFORMANCE_RESULT=$?

# Summary
echo ""
echo "Test Summary"
echo "============"
echo "Configuration: $([ $CONFIG_RESULT -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")"
echo "Integration: $([ $INTEGRATION_RESULT -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}")"
echo "Performance: $([ $PERFORMANCE_RESULT -eq 0 ] && echo -e "${GREEN}PASS${NC}" || echo -e "${YELLOW}WARN${NC}")"

if [ $CONFIG_RESULT -eq 0 ] && [ $INTEGRATION_RESULT -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi
```

### Development Dashboard

```bash
#!/bin/bash
# dev-dashboard.sh - Development environment dashboard

while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              NGINX DEVELOPMENT DASHBOARD                      ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Service status
    echo "📦 SERVICE STATUS:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -10
    echo ""
    
    # Nginx connections
    echo "🔗 CONNECTIONS:"
    curl -s http://localhost/nginx-status 2>/dev/null | grep -v "Active" || echo "  Unavailable"
    echo ""
    
    # Request rate
    echo "📊 REQUEST RATE:"
    REQUESTS=$(tail -60 /var/log/nginx/access.log 2>/dev/null | wc -l)
    echo "  Requests/min: $((REQUESTS / 1))"
    echo ""
    
    # Error rate
    ERRORS=$(tail -100 /var/log/nginx/access.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "❌ ERROR RATE:"
    echo "  Errors (last 100): $ERRORS"
    echo ""
    
    # Cache status
    echo "💾 CACHE STATUS:"
    echo "  Cache size: $(du -sh /var/cache/nginx 2>/dev/null | cut -f1)"
    HITS=$(tail -100 /var/log/nginx/access.log 2>/dev/null | grep -c '"upstream_cache_status":"HIT"')
    echo "  Hit rate: $HITS% (last 100)"
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    echo "Press Ctrl+C to exit"
    sleep 2
done
```

## P20.4 CI/CD Integration

### GitHub Actions Development Workflow

```yaml
# .github/workflows/dev.yml
name: Development CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Compose
        run: |
          docker compose -f docker-compose.dev.yml up -d
          sleep 10

      - name: Run tests
        run: |
          ./scripts/dev-test.sh

      - name: Run security scan
        run: |
          docker run --rm -v $(pwd):/app aquasec/trivy image --severity HIGH,CRITICAL nginx:1.27-alpine

      - name: Run lint
        run: |
          docker run --rm -v $(pwd):/app --entrypoint nginx nginx:1.27-alpine -t

      - name: Clean up
        run: |
          docker compose -f docker-compose.dev.yml down -v

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to staging
        run: |
          ssh user@staging-server "cd /app && git pull && docker compose up -d"
```

### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Check Nginx configuration
echo "Validating Nginx configuration..."
nginx -t 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ Nginx configuration invalid"
    exit 1
fi

# Check for secrets
echo "Checking for secrets..."
if grep -r "password\|secret\|key" --include="*.conf" ./; then
    echo "⚠️  Potential secrets found in configuration"
    echo "Please review and remove sensitive data"
fi

# Check formatting
echo "Checking formatting..."
if ! command -v nginxfmt &> /dev/null; then
    echo "⚠️  nginxfmt not installed, skipping formatting"
else
    nginxfmt --check ./nginx.conf
    if [ $? -ne 0 ]; then
        echo "❌ Formatting issues found"
        echo "Run: nginxfmt -w ./nginx.conf"
        exit 1
    fi
fi

echo "✅ Pre-commit checks passed"
```

---

This primer provides a comprehensive deep dive into integrating Nginx into modern development workflows. Use these techniques to build efficient development environments, testing frameworks, and CI/CD pipelines.
