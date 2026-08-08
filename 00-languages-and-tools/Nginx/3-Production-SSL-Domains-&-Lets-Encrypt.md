# Part 3: Production SSL, Domains & Let's Encrypt

## The Target

We're going to transform our HTTP-only gateway into a production-ready HTTPS server. By the end of this part, you'll have:

- A fully functioning HTTPS server with TLS termination
- Automatic HTTP to HTTPS redirection
- Real SSL certificates from Let's Encrypt (in a test environment)
- Certificate renewal automation
- All services communicating securely with proper forwarded protocol headers
- A hardened TLS configuration with modern security standards

## The Concept: HTTPS as the Modern Standard

Think of HTTPS like a secure package delivery service. Without it, you're sending postcards through the mail—anyone handling the package can read your message. With HTTPS, you're using a locked, tamper-evident container that only the intended recipient can open.

**Why HTTPS matters:**
- **Encryption**: Prevents eavesdropping on sensitive data
- **Authentication**: Proves your users are talking to YOUR server, not an imposter
- **Integrity**: Ensures data isn't tampered with in transit
- **SEO**: Google ranks HTTPS sites higher
- **Trust**: Browsers show "Not Secure" for HTTP sites
- **Modern Features**: Service Workers, Geolocation, and other APIs require HTTPS

## The Pain Point: Mixed Content and Insecure Cookies

Let's experience the problems HTTP causes when you try to add HTTPS.

### Step 1: Setup a Domain for Testing

For local testing, we'll use `localhost` with self-signed certificates. Later, we'll use a real domain with Let's Encrypt.

First, let's create our directory structure:

```bash
mkdir -p nginx-series/part-03
cd nginx-series/part-03

# Create directories for services (copy from Part 2)
cp -r ../part-02/nextjs-app .
cp -r ../part-02/fastapi-app .
cp -r ../part-02/flask-app .

# Create SSL directory
mkdir -p ssl
```

### Step 2: Generate Self-Signed Certificates (For Testing)

For local development, we'll generate self-signed certificates:

```bash
# Generate a self-signed certificate for localhost
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/localhost.key \
    -out ssl/localhost.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Verify the certificate was created
ls -la ssl/
# Should show localhost.crt and localhost.key
```

### Step 3: The Broken Setup (Mixed Content)

Let's create a configuration that tries to use HTTPS but has problems:

**File: `docker-compose.yml`**
```yaml
version: '3.8'

services:
  nextjs:
    build:
      context: ./nextjs-app
      dockerfile: Dockerfile
    container_name: nextjs-app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  fastapi:
    build:
      context: ./fastapi-app
      dockerfile: Dockerfile
    container_name: fastapi-api
    ports:
      - "8000:8000"
    environment:
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  flask:
    build:
      context: ./flask-app
      dockerfile: Dockerfile
    container_name: flask-admin
    ports:
      - "5000:5000"
    environment:
      - FLASK_APP=app.py
      - FLASK_ENV=production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/"]
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
      - "443:443"  # HTTPS port
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro  # Mount SSL certificates
      - ./logs:/var/log/nginx
    depends_on:
      nextjs:
        condition: service_healthy
      fastapi:
        condition: service_healthy
      flask:
        condition: service_healthy
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

**File: `nginx.conf` (INTENTIONALLY BROKEN)**
```nginx
# This configuration has multiple problems:
# 1. No HTTP->HTTPS redirect
# 2. Missing forwarded protocol headers
# 3. Self-signed certificate issues
# 4. Mixed content problems

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

    upstream admin_backend {
        server flask:5000;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    # HTTPS server block - uses self-signed certificates
    server {
        listen 443 ssl;
        server_name localhost;

        # Path to SSL certificates (self-signed for testing)
        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        # PROBLEM 1: No HTTP->HTTPS redirect
        # Users can still access via HTTP

        # PROBLEM 2: Missing forwarded protocol headers
        # Applications don't know they're behind HTTPS

        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # MISSING: X-Forwarded-Proto - app thinks it's HTTP!

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # MISSING: X-Forwarded-Proto

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        location /admin/ {
            proxy_pass http://admin_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # MISSING: X-Forwarded-Proto

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }

    # HTTP server block - should redirect to HTTPS
    # PROBLEM 3: It exists but doesn't redirect
    server {
        listen 80;
        server_name localhost;

        # PROBLEM: Just serves content over HTTP
        # Should redirect to HTTPS instead
        location / {
            # This is WRONG - should be return 301 https://$host$request_uri;
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### Step 4: Run and Observe the Broken Behavior

```bash
# Start the services
docker compose up -d

# Wait for everything to start
sleep 10

# Test 1: HTTP access - WORKS (but it shouldn't)
curl -v http://localhost
# ✅ Returns content, but should redirect to HTTPS

# Test 2: HTTPS access - WORKS (with warnings)
curl -k -v https://localhost
# ✅ Returns content, but uses self-signed cert (browser would warn)

# Test 3: Check forwarded protocol
curl -k -s https://localhost/api/debug | python -m json.tool
# Look at the headers - shows "x-forwarded-proto": "https" is missing!
# Apps can't tell they're behind HTTPS
```

### Step 5: Understanding the Problems

**Problem 1: No HTTP→HTTPS Redirect**
- Users accessing `http://localhost` don't get redirected
- They're served HTTP content (insecure)
- Browsers show "Not Secure"

**Problem 2: Missing Forwarded Protocol**
- Applications don't know if the original request was HTTP or HTTPS
- They generate HTTP URLs internally
- This causes mixed content warnings

**Problem 3: Self-Signed Certificates**
- Browsers show security warnings
- Not trusted by default
- Only useful for testing

### Step 6: The Fix - Complete HTTPS Configuration

**File: `nginx.conf` (FIXED)**
```nginx
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

    upstream admin_backend {
        server flask:5000;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    # HTTPS server block - main entry point
    server {
        listen 443 ssl http2;
        server_name localhost;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        # SSL Protocol and Cipher Configuration
        # Only allow secure protocols
        ssl_protocols TLSv1.2 TLSv1.3;
        # Use modern secure ciphers
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # HSTS (HTTP Strict Transport Security)
        # Tells browsers to always use HTTPS
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Other security headers
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options DENY;

        # Root path
        location / {
            proxy_pass http://frontend_backend;
            
            # CRITICAL: Forward the original protocol
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;  # FIXED: App knows it's HTTPS
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API path
        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;  # FIXED
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Admin path
        location /admin/ {
            proxy_pass http://admin_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;  # FIXED
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }

    # HTTP server - Redirects all traffic to HTTPS
    server {
        listen 80;
        server_name localhost;

        # FIXED: Redirect all HTTP requests to HTTPS
        return 301 https://$host$request_uri;
    }
}
```

### Step 7: Apply the Fix

```bash
# Test the configuration
docker exec nginx-proxy nginx -t
# Should show: syntax is ok

# Reload Nginx
docker exec nginx-proxy nginx -s reload
```

Now test the behavior:

```bash
# Test 1: HTTP redirects to HTTPS
curl -v http://localhost
# Should show:
# < HTTP/1.1 301 Moved Permanently
# < Location: https://localhost/

# Test 2: HTTPS works
curl -k -s https://localhost | grep "Next.js"
# Should show Next.js HTML content

# Test 3: Forwarded protocol header works
curl -k -s https://localhost/api/debug | python -m json.tool
# Should show "x-forwarded-proto": "https" in the headers

# Test 4: Check HSTS header
curl -k -I https://localhost
# Should show: Strict-Transport-Security: max-age=31536000; includeSubDomains
```

### Step 8: Real Domains and Let's Encrypt

Now let's set up real SSL certificates with Let's Encrypt. **This requires a real domain name and port 80/443 accessible from the internet.**

#### Option A: Using Certbot with Docker

**File: `docker-compose-letsencrypt.yml`**
```yaml
version: '3.8'

services:
  # ... existing services ...

  # Certbot service - obtains and renews certificates
  certbot:
    image: certbot/certbot:latest
    container_name: certbot
    volumes:
      - ./certbot/www:/var/www/certbot
      - ./certbot/conf:/etc/letsencrypt
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
    networks:
      - app-network

  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx-letsencrypt.conf:/etc/nginx/nginx.conf:ro
      - ./certbot/conf:/etc/nginx/ssl:ro
      - ./certbot/www:/var/www/certbot
      - ./logs:/var/log/nginx
    depends_on:
      - certbot
    networks:
      - app-network
```

**File: `nginx-letsencrypt.conf`**
```nginx
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

    upstream admin_backend {
        server flask:5000;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    # HTTP server - handles ACME challenge and redirects
    server {
        listen 80;
        server_name yourdomain.com;

        # ACME challenge for Let's Encrypt
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        # Redirect everything else to HTTPS
        location / {
            return 301 https://$host$request_uri;
        }
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name yourdomain.com;

        # SSL certificates from Let's Encrypt
        ssl_certificate /etc/nginx/ssl/live/yourdomain.com/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/live/yourdomain.com/privkey.pem;

        # SSL configuration
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # HSTS
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Security headers
        add_header X-Content-Type-Options nosniff;
        add_header X-Frame-Options DENY;

        # Root path
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API path
        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Admin path
        location /admin/ {
            proxy_pass http://admin_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

#### Initial Certificate Obtaining

```bash
# First, run the certbot container to obtain certificates
docker run -it --rm \
    -v ./certbot/www:/var/www/certbot \
    -v ./certbot/conf:/etc/letsencrypt \
    certbot/certbot \
    certonly --webroot \
    -w /var/www/certbot \
    -d yourdomain.com \
    --email your@email.com \
    --agree-tos \
    --non-interactive

# Then start the full stack
docker compose -f docker-compose-letsencrypt.yml up -d
```

#### Automatic Renewal

Certbot renews certificates automatically when they're about to expire. The container runs a renewal check every 12 hours.

### Step 9: Production-Ready TLS Configuration

Let's create a hardened TLS configuration for production:

**File: `nginx-tls-hardened.conf`**
```nginx
# This is a snippet to include in your main nginx.conf
# It provides hardened TLS settings

# SSL Session Cache - improves performance
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1h;
ssl_session_tickets off;

# Modern TLS configuration
ssl_protocols TLSv1.2 TLSv1.3;

# Secure cipher suites
# - Only AES-GCM and ChaCha20-Poly1305 (modern, authenticated encryption)
# - No RC4, no 3DES, no AES-CBC
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;

# Enable OCSP stapling - improves SSL handshake performance
ssl_stapling on;
ssl_stapling_verify on;
resolver 1.1.1.1 8.8.8.8 valid=300s;
resolver_timeout 5s;

# Security Headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# SSL certificate paths (replace with your actual paths)
ssl_certificate /etc/nginx/ssl/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/nginx/ssl/live/yourdomain.com/privkey.pem;

# Perfect Forward Secrecy - DHE parameters
# Generate with: openssl dhparam -out dhparam.pem 2048
ssl_dhparam /etc/nginx/ssl/dhparam.pem;
```

**Generate DH Parameters:**
```bash
# Generate DH parameters (takes about 30 seconds)
openssl dhparam -out dhparam.pem 2048

# Move to SSL directory
mv dhparam.pem ssl/
```

### Step 10: Testing TLS Security

Now let's test our TLS configuration for security:

```bash
# Test 1: Check SSL certificate details
openssl s_client -connect localhost:443 -showcerts < /dev/null

# Test 2: Check for weak ciphers
nmap --script ssl-enum-ciphers -p 443 localhost

# Test 3: Online SSL tests (requires public domain)
# Go to: https://www.ssllabs.com/ssltest/
# Enter your domain to get a full security report

# Test 4: Check HTTP headers
curl -k -I https://localhost
# Should show:
# Strict-Transport-Security
# X-Content-Type-Options
# X-Frame-Options
# etc.
```

## Verification Checklist

Before moving on, verify you've mastered SSL/TLS configuration:

### ✅ Check 1: HTTP Redirects to HTTPS
```bash
curl -I http://localhost 2>/dev/null | grep Location
# Should show: Location: https://localhost/
```

### ✅ Check 2: HTTPS Works
```bash
curl -k -I https://localhost
# Should show: HTTP/1.1 200 OK
```

### ✅ Check 3: Forwarded Protocol Headers
```bash
curl -k -s https://localhost/api/debug | python -m json.tool | grep -A5 "x-forwarded-proto"
# Should show: "x-forwarded-proto": "https"
```

### ✅ Check 4: Security Headers Present
```bash
curl -k -I https://localhost | grep -E "Strict-Transport|X-Content|X-Frame"
# Should show HSTS and other security headers
```

### ✅ Check 5: TLS Version Supported
```bash
# Test TLS 1.3 support
openssl s_client -connect localhost:443 -tls1_3 < /dev/null 2>&1 | grep "TLSv1.3"
# Should show TLSv1.3 handshake

# Test TLS 1.2 support
openssl s_client -connect localhost:443 -tls1_2 < /dev/null 2>&1 | grep "TLSv1.2"
# Should show TLSv1.2 handshake
```

### ✅ Check 6: No Weak Protocols
```bash
# Test TLS 1.1 (should fail)
openssl s_client -connect localhost:443 -tls1_1 < /dev/null 2>&1 | grep "TLSv1.1"
# Should show failure
```

### ✅ Check 7: Applications Know They're Behind HTTPS
```bash
# FastAPI should know it's HTTPS
curl -k -s https://localhost/api/debug | python -m json.tool | grep -A10 "url"
# The URL should show "https://localhost/api/debug"
```

## Common Pitfalls and Solutions

### Pitfall 1: Missing Forwarded Protocol Headers

**Symptom:** Application generates HTTP URLs instead of HTTPS

**Wrong:**
```nginx
location /api/ {
    proxy_pass http://api_backend/;
    proxy_set_header Host $host;
    # Missing X-Forwarded-Proto
}
```

**Right:**
```nginx
location /api/ {
    proxy_pass http://api_backend/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;  # Add this
}
```

### Pitfall 2: HTTP Redirect Creates Redirect Loop

**Symptom:** Browser shows "Too many redirects"

**Wrong:**
```nginx
server {
    listen 80;
    server_name localhost;
    return 301 https://localhost$request_uri;  # Missing $scheme
}
```

**Right:**
```nginx
server {
    listen 80;
    server_name localhost;
    return 301 https://$host$request_uri;  # Full URL
}
```

### Pitfall 3: Self-Signed Certificates in Browser

**Symptom:** "Your connection is not private"

**Cause:** Self-signed certificates aren't trusted by browsers

**Solutions:**
1. Use Let's Encrypt for real domains
2. For testing, add the certificate to your browser's trust store
3. Accept the warning (not recommended for production)

### Pitfall 4: Mixed Content Warnings

**Symptom:** Browser shows "Mixed Content" warnings

**Cause:** Page loaded over HTTPS but requests resources over HTTP

**Fix:**
1. Ensure all internal URLs use `//` or `https://`
2. In Next.js: Set `NEXT_PUBLIC_API_URL` to HTTPS
3. In Django: Set `SECURE_PROXY_SSL_HEADER`
4. Use `X-Forwarded-Proto` header

### Pitfall 5: Expired Certificates

**Symptom:** Users see security warnings after certificate expires

**Solution:** Automatic renewal with Let's Encrypt
```bash
# Test renewal process
docker exec certbot certbot renew --dry-run

# Set up cron job for renewal
0 0 * * * docker exec certbot certbot renew && docker exec nginx-proxy nginx -s reload
```

### Pitfall 6: HSTS Issues During Development

**Symptom:** Browser remembers HSTS and blocks HTTP even during local development

**Solution:**
1. Remove HSTS header during development
2. Or clear HSTS cache in browser
3. Use a separate subdomain for development

## What You've Learned

By completing Part 3, you can now:

- ✅ Configure Nginx for HTTPS with SSL/TLS termination
- ✅ Set up HTTP to HTTPS redirects
- ✅ Forward protocol headers to applications
- ✅ Generate and use self-signed certificates for testing
- ✅ Obtain real certificates with Let's Encrypt
- ✅ Configure automatic certificate renewal
- ✅ Harden TLS with modern security settings
- ✅ Add security headers (HSTS, X-Content-Type-Options, etc.)
- ✅ Test SSL/TLS configuration for security
- ✅ Handle mixed content issues

## Reference: SSL/TLS Deep Dive

### SSL/TLS Handshake Process

1. **Client Hello**: Client sends supported SSL/TLS versions, cipher suites
2. **Server Hello**: Server chooses SSL/TLS version and cipher
3. **Certificate**: Server sends certificate chain
4. **Key Exchange**: Server and client agree on session keys
5. **Finished**: Both sides confirm secure connection established

### Nginx SSL Directives Reference

| Directive | Purpose | Example |
|-----------|---------|---------|
| `ssl_certificate` | Path to certificate file | `/etc/nginx/ssl/cert.pem` |
| `ssl_certificate_key` | Path to private key | `/etc/nginx/ssl/key.pem` |
| `ssl_protocols` | Allowed TLS versions | `TLSv1.2 TLSv1.3` |
| `ssl_ciphers` | Allowed cipher suites | `ECDHE-RSA-AES128-GCM-SHA256:...` |
| `ssl_session_cache` | Cache SSL sessions for performance | `shared:SSL:10m` |
| `ssl_session_timeout` | Session timeout | `1h` |
| `ssl_prefer_server_ciphers` | Server chooses cipher order | `off` |
| `ssl_stapling` | Enable OCSP stapling | `on` |
| `ssl_dhparam` | DH parameters for PFS | `/etc/nginx/ssl/dhparam.pem` |

### Security Headers Explained

| Header | Purpose | Example |
|--------|---------|---------|
| `Strict-Transport-Security` | Enforce HTTPS for a specified time | `max-age=31536000; includeSubDomains` |
| `X-Content-Type-Options` | Prevent MIME type sniffing | `nosniff` |
| `X-Frame-Options` | Prevent clickjacking | `DENY` or `SAMEORIGIN` |
| `X-XSS-Protection` | Enable XSS protection | `1; mode=block` |
| `Referrer-Policy` | Control referrer header | `strict-origin-when-cross-origin` |

### Forwarded Headers Reference

| Header | Purpose |
|--------|---------|
| `X-Forwarded-Proto` | Original protocol (http/https) |
| `X-Forwarded-Host` | Original hostname |
| `X-Forwarded-For` | Original client IP chain |
| `X-Forwarded-Port` | Original port |
| `X-Real-IP` | Original client IP (single) |

### Let's Encrypt Renewal Schedule

Let's Encrypt certificates are valid for 90 days. Automatic renewal should run:

- Every 60 days (safety margin)
- Check twice daily to ensure renewal
- Renewal can start 30 days before expiration

**Cron job for renewal:**
```bash
# Run twice daily at midnight and noon
0 0,12 * * * /usr/local/bin/nginx-certbot-renew.sh
```

**Renewal script:**
```bash
#!/bin/bash
# nginx-certbot-renew.sh
docker exec certbot certbot renew
docker exec nginx-proxy nginx -s reload
```

## Next Steps

**Part 4: Authentication, Cookies, Headers & Rate Limiting** builds on our secure gateway. You'll learn:

- Forwarding authentication headers correctly
- Handling cookies behind a proxy
- Rate limiting to prevent abuse
- Protecting sensitive endpoints
- Configuring different rate limits per path

Your gateway is now secure. Let's make it intelligent.
