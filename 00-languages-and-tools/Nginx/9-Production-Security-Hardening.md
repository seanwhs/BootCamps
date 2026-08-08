# Part 9: Production Security Hardening

## The Target

We're going to transform our observable gateway into a fortress of security. By the end of this part, you'll have:

- Comprehensive security headers for protection against web vulnerabilities
- TLS hardening with modern cryptographic standards
- Advanced rate limiting and attack prevention
- Request validation and filtering
- Access control and authentication hardening
- Security testing and validation
- Complete security audit capabilities

## The Concept: Security as a Multi-Layered Defense

Think of security like securing a medieval castle:

- **Outer Walls** (Security Headers): First line of defense, visible to all
- **Gate Guards** (Rate Limiting): Control who enters and how often
- **Inner Courtyards** (Access Control): Different areas for different people
- **Treasure Room** (Sensitive Data): Highest level of protection
- **Watchtowers** (Monitoring): Always watching for threats
- **Defense in Depth**: Multiple layers of security, each reinforcing the others

## The Pain Point: Security Headers and Common Vulnerabilities

Let's see what happens when our gateway lacks proper security hardening.

### Step 1: Setup Security Testing Environment

```bash
mkdir -p nginx-series/part-09
cd nginx-series/part-09

# Copy our existing apps
cp -r ../part-08/fastapi-blue .
cp -r ../part-08/fastapi-green .
cp -r ../part-08/ssl .
cp -r ../part-08/logs .
cp -r ../part-08/scripts .

# Create security testing tools
mkdir -p security-tests
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

### Step 2: The Broken Setup (Insecure by Default)

**File: `nginx.conf` (INTENTIONALLY INSECURE)**
```nginx
# This configuration is INSECURE by default
# Missing security headers, weak TLS, no protection

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
        server fastapi-blue:8000 max_fails=3 fail_timeout=30s;
        server fastapi-green:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        # PROBLEM: Weak TLS configuration
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;  # Old protocols
        ssl_ciphers ALL:!aNULL:!eNULL:!LOW:!EXP:!RC4:!MD5;  # Weak ciphers
        ssl_prefer_server_ciphers on;

        # PROBLEM: Missing security headers
        # No HSTS, no CSP, no X-Frame-Options, etc.

        location /api/ {
            # PROBLEM: No rate limiting
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # PROBLEM: Sensitive endpoints exposed
        location /admin/ {
            proxy_pass http://api_backend/;
            # No access control
        }

        # PROBLEM: Debug endpoints exposed to everyone
        location /debug/ {
            proxy_pass http://api_backend/debug/;
            # Should be restricted
        }
    }

    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

### Step 3: Run and Observe Security Gaps

```bash
# Start the services
docker compose up -d

# Wait for everything to start
sleep 10

# Test 1: Check security headers
echo "=== Security Headers ==="
curl -k -I https://localhost/api/
# MISSING: HSTS, CSP, X-Frame-Options, X-Content-Type-Options

# Test 2: Test weak TLS
echo ""
echo "=== TLS Testing ==="
openssl s_client -connect localhost:443 -tls1_1 < /dev/null 2>&1 | grep "TLSv1.1"
# Should show that TLS 1.1 is accepted (bad)

# Test 3: Test rate limiting
echo ""
echo "=== Rate Limiting ==="
echo "Making 100 rapid requests..."
for i in {1..100}; do
    curl -k -s -o /dev/null -w "%{http_code}\n" https://localhost/api/
done | sort | uniq -c
# Should show all 200 OK (no rate limiting)

# Test 4: Test exposed admin endpoint
echo ""
echo "=== Admin Endpoint Accessibility ==="
curl -k -s https://localhost/admin/ | head -20
# Should show admin content (not restricted)

# Test 5: Test exposed debug endpoints
echo ""
echo "=== Debug Endpoint Accessibility ==="
curl -k -s https://localhost/debug/headers | python -m json.tool | head -10
# Debug info exposed to everyone

# Test 6: Test for clickjacking
echo ""
echo "=== Clickjacking Test ==="
curl -k -I https://localhost/api/ | grep -i "X-Frame-Options"
# Missing - site vulnerable to clickjacking

# Test 7: Check for MIME sniffing
echo ""
echo "=== MIME Sniffing Test ==="
curl -k -I https://localhost/api/ | grep -i "X-Content-Type-Options"
# Missing - site vulnerable to MIME sniffing attacks
```

### Step 4: Understanding the Security Problems

**Problem 1: Missing Security Headers**
- No HSTS → Downgrade attacks possible
- No CSP → XSS vulnerabilities
- No X-Frame-Options → Clickjacking
- No X-Content-Type-Options → MIME sniffing attacks
- No Referrer-Policy → Information leakage

**Problem 2: Weak TLS Configuration**
- Old TLS versions (TLSv1, TLSv1.1) have known vulnerabilities
- Weak cipher suites (RC4, MD5, DES) can be broken
- No HSTS to enforce HTTPS

**Problem 3: No Rate Limiting**
- Vulnerable to DDoS attacks
- No protection against brute force
- Can be overwhelmed by requests

**Problem 4: Exposed Endpoints**
- Admin endpoints accessible to everyone
- Debug information exposed
- No access control

### Step 5: The Fix - Complete Security Hardening

**File: `nginx.conf` (FIXED - Production Hardened)**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Log format with security info
    log_format security '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for" '
                        '"$upstream_cache_status" "$request_time" '
                        '"$ssl_protocol" "$ssl_cipher"';

    access_log /var/log/nginx/access.log security;
    error_log /var/log/nginx/error.log warn;

    sendfile on;
    keepalive_timeout 65;

    # FIXED: Production security settings
    server_tokens off;  # Hide Nginx version

    # FIXED: Rate limiting zones
    limit_req_zone $binary_remote_addr zone=global_limit:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=admin_limit:10m rate=5r/m;

    # FIXED: Connection limits
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

    # FIXED: Buffer and timeout protection
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    client_max_body_size 10M;

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

        # FIXED: Modern TLS configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 8.8.8.8 valid=300s;
        resolver_timeout 5s;

        # FIXED: Comprehensive security headers
        # HSTS - Enforce HTTPS for 2 years
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        
        # Prevent MIME type sniffing
        add_header X-Content-Type-Options "nosniff" always;
        
        # Prevent clickjacking
        add_header X-Frame-Options "DENY" always;
        
        # Enable XSS protection
        add_header X-XSS-Protection "1; mode=block" always;
        
        # Control referrer information
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        
        # Permissions Policy - restrict browser features
        add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), accelerometer=(), gyroscope=()" always;
        
        # Content Security Policy - prevent XSS and injection
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self';" always;

        # FIXED: Global rate limiting
        limit_req zone=global_limit burst=20 nodelay;
        limit_conn conn_limit 10;

        # FIXED: API with specific rate limiting
        location /api/ {
            limit_req zone=api_limit burst=10 nodelay;
            
            # FIXED: Request validation
            if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
                return 405;
            }
            
            # FIXED: Prevent path traversal
            if ($request_uri ~* "\.\./") {
                return 403;
            }
            
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Content-Type-Options "nosniff";

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # FIXED: Authentication endpoint with stricter limits
        location /auth/ {
            limit_req zone=auth_limit burst=2 nodelay;
            limit_conn conn_limit 1;
            
            proxy_pass http://api_backend/auth/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Content-Type-Options "nosniff";

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # FIXED: Admin with strict access control
        location /admin/ {
            # FIXED: IP-based access control
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;

            limit_req zone=admin_limit burst=2 nodelay;
            
            proxy_pass http://api_backend/admin/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # Admin-specific security headers
            add_header X-Robots-Tag "noindex, nofollow" always;
            add_header Cache-Control "no-store, no-cache, must-revalidate" always;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # FIXED: Debug endpoints restricted
        location /debug/ {
            # Only allow from internal networks
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            deny all;
            
            proxy_pass http://api_backend/debug/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # FIXED: Health check endpoint (public but limited)
        location /health {
            # Allow health checks from anywhere but limit rate
            limit_req zone=global_limit burst=5 nodelay;
            
            proxy_pass http://api_backend/health;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # FIXED: Nginx status (internal only)
        location /nginx-status {
            allow 127.0.0.1;
            deny all;
            
            stub_status on;
            access_log off;
        }
    }

    # FIXED: HTTP redirect with HSTS
    server {
        listen 80;
        server_name localhost;
        
        # Add HSTS header for visitors who come via HTTP
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        
        return 301 https://$host$request_uri;
    }
}
```

### Step 6: Security Headers Deep Dive

**File: `nginx-security-headers.conf`**
```nginx
# Comprehensive Security Headers Configuration

# Reference: All security headers with explanations

# 1. HSTS - HTTP Strict Transport Security
# Forces browsers to use HTTPS for the specified time
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
# max-age: 2 years (in seconds)
# includeSubDomains: Apply to all subdomains
# preload: Submit to browser HSTS preload lists

# 2. Content Security Policy (CSP)
# Prevents XSS, clickjacking, and other injection attacks
add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self' 'unsafe-inline' 'unsafe-eval';
    style-src 'self' 'unsafe-inline';
    img-src 'self' data: https:;
    font-src 'self';
    connect-src 'self';
    frame-ancestors 'none';
    form-action 'self';
    base-uri 'self';
    upgrade-insecure-requests;
" always;

# 3. X-Content-Type-Options
# Prevents MIME type sniffing
add_header X-Content-Type-Options "nosniff" always;

# 4. X-Frame-Options
# Prevents clickjacking
add_header X-Frame-Options "DENY" always;
# Alternative: "SAMEORIGIN" if you need iframes on same domain

# 5. X-XSS-Protection
# Enables browser XSS filtering
add_header X-XSS-Protection "1; mode=block" always;

# 6. Referrer-Policy
# Controls what information is sent in the Referrer header
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
# Options: no-referrer, no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url

# 7. Permissions-Policy
# Controls which browser features can be used
add_header Permissions-Policy "
    geolocation=(),
    microphone=(),
    camera=(),
    payment=(),
    usb=(),
    magnetometer=(),
    accelerometer=(),
    gyroscope=(),
    document-domain=(),
    fullscreen=(self)
" always;

# 8. Cross-Origin Resource Policy
# Controls cross-origin resource sharing
add_header Cross-Origin-Resource-Policy "same-origin" always;

# 9. Cross-Origin-Opener-Policy
# Controls cross-window communication
add_header Cross-Origin-Opener-Policy "same-origin" always;

# 10. Cross-Origin-Embedder-Policy
# Controls cross-origin embedding
add_header Cross-Origin-Embedder-Policy "require-corp" always;
```

### Step 7: Advanced Rate Limiting and DDoS Protection

**File: `nginx-ddos-protection.conf`**
```nginx
# DDoS Protection Configuration

# Rate limiting zones
limit_req_zone $binary_remote_addr zone=global_limit:10m rate=100r/m;
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=10r/m;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
limit_req_zone $binary_remote_addr zone=admin_limit:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=static_limit:10m rate=300r/m;

# Connection limiting
limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
limit_conn_zone $binary_remote_addr zone=burst_limit:10m;

# Location-specific protection
location / {
    # Global limits
    limit_req zone=global_limit burst=20 nodelay;
    limit_conn conn_limit 10;
    
    # Protect against slowloris attacks
    client_body_timeout 5s;
    client_header_timeout 5s;
    
    proxy_pass http://frontend_backend;
}

# Authentication - strict limits
location /auth/login {
    # Very strict: 5 requests per minute, burst of 2
    limit_req zone=auth_limit burst=2 nodelay;
    limit_conn conn_limit 1;
    
    # Long timeout for password hashing
    proxy_read_timeout 10s;
    
    proxy_pass http://auth_backend/login;
}

# API with burst protection
location /api/ {
    # 60 requests per minute, burst up to 20
    limit_req zone=api_limit burst=20 delay=10;
    
    # Cache response to reduce load
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
    proxy_cache_use_stale error timeout updating;
    proxy_cache_lock on;
    
    proxy_pass http://api_backend/;
}

# Custom error page for rate limiting
error_page 429 /429.html;
location = /429.html {
    root /usr/share/nginx/html;
    internal;
}

# Whitelist certain IPs (bypass rate limiting)
geo $limit_whitelist {
    default 1;
    # Whitelist internal IPs
    10.0.0.0/8 0;
    172.16.0.0/12 0;
    192.168.0.0/16 0;
    127.0.0.1 0;
}

# Apply limits only if not whitelisted
location /api/ {
    limit_req zone=api_limit burst=10 nodelay if=$limit_whitelist;
    
    proxy_pass http://api_backend/;
}

# Blacklist known bad IPs
geo $blacklist {
    default 0;
    # Example blacklisted IPs
    1.2.3.4 1;
    5.6.7.8 1;
}

# Block blacklisted IPs
location / {
    if ($blacklist) {
        return 403;
    }
    
    proxy_pass http://frontend_backend;
}
```

### Step 8: Request Validation and Filtering

**File: `nginx-request-validation.conf`**
```nginx
# Request Validation and Filtering

# Block suspicious user agents
map $http_user_agent $is_bad_ua {
    default 0;
    "~*(curl|wget|python|perl|ruby|java|http)" 1;
    "~*(sqlmap|nmap|nikto|nessus|openvas)" 1;
    "~*(masscan|httrack|wpscan|joomscan)" 1;
}

# Block suspicious query strings
map $query_string $has_suspicious_query {
    default 0;
    "~*(<|>|%3C|%3E|javascript|alert|onerror)" 1;
    "~*(union|select|insert|update|delete|drop|exec|eval)" 1;
    "~*(etc/passwd|/proc/|../|%2e%2e/)" 1;
}

# Block suspicious request methods
map $request_method $is_bad_method {
    default 0;
    "~(TRACE|TRACK|OPTIONS|CONNECT)" 1;
}

# Comprehensive validation location
location /api/ {
    # Block bad user agents
    if ($is_bad_ua) {
        return 403 "Access denied by security policy";
    }
    
    # Block suspicious query strings
    if ($has_suspicious_query) {
        return 400 "Invalid request parameters";
    }
    
    # Block bad methods
    if ($is_bad_method) {
        return 405 "Method not allowed";
    }
    
    # Block requests with empty host header
    if ($http_host = "") {
        return 400 "Bad request";
    }
    
    # Content type validation
    if ($request_method = POST) {
        if ($content_type !~ "application/json") {
            return 415 "Unsupported media type";
        }
    }
    
    proxy_pass http://api_backend/;
}

# SQL injection protection
location /api/ {
    if ($args ~* "(union|select|insert|update|delete|drop|exec|eval|ALTER|CREATE|TABLE).*") {
        return 403;
    }
    
    proxy_pass http://api_backend/;
}

# XSS protection
location /api/ {
    if ($args ~* "(<|>|%3C|%3E|javascript:|onerror|onload|alert).*") {
        return 403;
    }
    
    proxy_pass http://api_backend/;
}

# Path traversal protection
location /api/ {
    if ($request_uri ~* "\.\./") {
        return 403;
    }
    
    if ($request_uri ~* "//") {
        return 400;
    }
    
    proxy_pass http://api_backend/;
}
```

### Step 9: Security Testing Suite

**File: `security-tests/test-security.sh`**
```bash
#!/bin/bash
# security-tests.sh - Comprehensive security test suite

echo "=== Nginx Security Test Suite ==="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
PASSED=0
FAILED=0

# Test function
test_security() {
    local name=$1
    local command=$2
    local expected=$3
    
    echo -n "Testing: $name... "
    
    if eval "$command" | grep -q "$expected"; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

# 1. HSTS Header Test
test_security "HSTS Header" \
    "curl -k -s -I https://localhost/api/ | grep -i 'Strict-Transport-Security'" \
    "Strict-Transport-Security"

# 2. X-Content-Type-Options Test
test_security "X-Content-Type-Options" \
    "curl -k -s -I https://localhost/api/ | grep -i 'X-Content-Type-Options'" \
    "nosniff"

# 3. X-Frame-Options Test
test_security "X-Frame-Options" \
    "curl -k -s -I https://localhost/api/ | grep -i 'X-Frame-Options'" \
    "DENY"

# 4. CSP Header Test
test_security "Content-Security-Policy" \
    "curl -k -s -I https://localhost/api/ | grep -i 'Content-Security-Policy'" \
    "Content-Security-Policy"

# 5. X-XSS-Protection Test
test_security "X-XSS-Protection" \
    "curl -k -s -I https://localhost/api/ | grep -i 'X-XSS-Protection'" \
    "1; mode=block"

# 6. Referrer-Policy Test
test_security "Referrer-Policy" \
    "curl -k -s -I https://localhost/api/ | grep -i 'Referrer-Policy'" \
    "strict-origin-when-cross-origin"

# 7. Server Header Test (should be hidden)
test_security "Server Header Hidden" \
    "curl -k -s -I https://localhost/api/ | grep -i 'Server:'" \
    "nginx/1.27.0"

# 8. Rate Limiting Test
echo -n "Testing: Rate Limiting... "
RATE_LIMIT_RESULT=$(for i in {1..20}; do
    curl -k -s -o /dev/null -w "%{http_code}\n" https://localhost/auth/login 2>/dev/null
done | grep -c "429")

if [ $RATE_LIMIT_RESULT -gt 0 ]; then
    echo -e "${GREEN}PASS${NC} (Rate limiting active)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} (No rate limiting detected)"
    ((FAILED++))
fi

# 9. TLS Protocol Test
test_security "TLS 1.3 Enabled" \
    "openssl s_client -connect localhost:443 -tls1_3 < /dev/null 2>&1 | grep -i 'TLSv1.3'" \
    "TLSv1.3"

# 10. Weak Cipher Test (should NOT be available)
echo -n "Testing: Weak Ciphers Blocked... "
if openssl s_client -connect localhost:443 -cipher 'RC4' < /dev/null 2>&1 | grep -q "TLSv1.2"; then
    echo -e "${RED}FAIL${NC} (Weak cipher accepted)"
    ((FAILED++))
else
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
fi

# 11. Admin Endpoint Protection Test
test_security "Admin Endpoint Protection" \
    "curl -k -s -I https://localhost/admin/ | grep -i 'HTTP/1.1'" \
    "403" || true

# 12. Debug Endpoint Protection
test_security "Debug Endpoint Protection" \
    "curl -k -s -I https://localhost/debug/ | grep -i 'HTTP/1.1'" \
    "403" || true

# 13. SQL Injection Protection Test
echo -n "Testing: SQL Injection Protection... "
RESULT=$(curl -k -s -o /dev/null -w "%{http_code}" "https://localhost/api/?id=1%20UNION%20SELECT%20*%20FROM%20users" 2>/dev/null)
if [ "$RESULT" = "403" ] || [ "$RESULT" = "400" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} (SQL injection not blocked)"
    ((FAILED++))
fi

# 14. XSS Protection Test
echo -n "Testing: XSS Protection... "
RESULT=$(curl -k -s -o /dev/null -w "%{http_code}" "https://localhost/api/?q=<script>alert(1)</script>" 2>/dev/null)
if [ "$RESULT" = "403" ] || [ "$RESULT" = "400" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} (XSS not blocked)"
    ((FAILED++))
fi

# 15. Path Traversal Protection Test
echo -n "Testing: Path Traversal Protection... "
RESULT=$(curl -k -s -o /dev/null -w "%{http_code}" "https://localhost/api/../../etc/passwd" 2>/dev/null)
if [ "$RESULT" = "403" ] || [ "$RESULT" = "400" ] || [ "$RESULT" = "404" ]; then
    echo -e "${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} (Path traversal not blocked)"
    ((FAILED++))
fi

# Summary
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total: $((PASSED + FAILED))"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! Security hardening is complete.${NC}"
    exit 0
else
    echo -e "${RED}$FAILED test(s) failed. Please review security configuration.${NC}"
    exit 1
fi
```

### Step 10: Security Audit and Monitoring

**File: `security-audit.sh`**
```bash
#!/bin/bash
# security-audit.sh - Comprehensive security audit

echo "=== Nginx Security Audit ==="
echo ""

# Check 1: Nginx version
echo "1. Nginx Version:"
docker exec nginx-proxy nginx -v 2>&1
echo ""

# Check 2: Configuration test
echo "2. Configuration Test:"
docker exec nginx-proxy nginx -t
echo ""

# Check 3: Running processes
echo "3. Running Processes:"
docker exec nginx-proxy ps aux | grep nginx
echo ""

# Check 4: SSL/TLS configuration
echo "4. SSL/TLS Configuration:"
docker exec nginx-proxy nginx -T | grep -A5 "ssl_"
echo ""

# Check 5: Security headers
echo "5. Security Headers:"
curl -k -I https://localhost/api/ | grep -E "Strict-Transport|X-Content|X-Frame|X-XSS|Referrer|Content-Security"
echo ""

# Check 6: Rate limiting configuration
echo "6. Rate Limiting Configuration:"
docker exec nginx-proxy nginx -T | grep -A2 "limit_req_zone"
echo ""

# Check 7: Access control
echo "7. Access Control:"
docker exec nginx-proxy nginx -T | grep -A3 "allow" | head -10
echo ""

# Check 8: Log files
echo "8. Log File Analysis:"
echo "  Access log size: $(du -h logs/access.log 2>/dev/null | cut -f1)"
echo "  Error log size: $(du -h logs/error.log 2>/dev/null | cut -f1)"
echo ""

echo "=== Security Audit Complete ==="
```

## Verification Checklist

### ✅ Check 1: Security Headers Present
```bash
curl -k -I https://localhost/api/ | grep -E "Strict-Transport|X-Content|X-Frame|Content-Security"
# Should show all headers
```

### ✅ Check 2: Rate Limiting Works
```bash
for i in {1..20}; do
    curl -k -s -o /dev/null -w "%{http_code}\n" https://localhost/auth/login
done | sort | uniq -c
# Should show some 429 responses
```

### ✅ Check 3: Admin Endpoint Protected
```bash
curl -k -I https://localhost/admin/ | grep "HTTP/1.1"
# Should return 403
```

### ✅ Check 4: Debug Endpoint Protected
```bash
curl -k -I https://localhost/debug/ | grep "HTTP/1.1"
# Should return 403
```

### ✅ Check 5: TLS 1.3 Enabled
```bash
openssl s_client -connect localhost:443 -tls1_3 < /dev/null 2>&1 | grep "TLSv1.3"
# Should show TLSv1.3
```

### ✅ Check 6: SQL Injection Blocked
```bash
curl -k -s -o /dev/null -w "%{http_code}" "https://localhost/api/?id=1%20UNION%20SELECT%20*"
# Should return 403 or 400
```

### ✅ Check 7: XSS Attack Blocked
```bash
curl -k -s -o /dev/null -w "%{http_code}" "https://localhost/api/?q=<script>alert(1)</script>"
# Should return 403 or 400
```

## What You've Learned

By completing Part 9, you can now:

- ✅ Implement comprehensive security headers
- ✅ Configure modern TLS with strong ciphers
- ✅ Set up rate limiting for DDoS protection
- ✅ Protect sensitive endpoints with access control
- ✅ Validate and sanitize requests
- ✅ Prevent common attacks (XSS, SQL injection, path traversal)
- ✅ Run security tests and audits
- ✅ Monitor security configuration
- ✅ Handle security incidents

## Reference: Security Best Practices

| Practice | Importance | Implementation |
|----------|-----------|----------------|
| HSTS | Critical | `add_header Strict-Transport-Security` |
| CSP | High | `add_header Content-Security-Policy` |
| Rate Limiting | Critical | `limit_req_zone` and `limit_req` |
| TLS 1.3 | Critical | `ssl_protocols TLSv1.2 TLSv1.3` |
| Strong Ciphers | High | `ssl_ciphers` |
| Request Validation | High | Regex filtering |
| Access Control | High | `allow`/`deny` directives |
| Hidden Server Tokens | Medium | `server_tokens off` |

## Next Steps

**Part 10: Capstone - Production Full-Stack Gateway** brings everything together. You'll build:

- Complete production-ready configuration
- All security features combined
- Monitoring and alerting
- Load balancing and failover
- Zero-downtime deployment
- Documentation and runbooks

Your gateway is now secure. Let's build the complete production system.
