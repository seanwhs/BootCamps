# Part 31: Reverse Proxy & Networking

## Building the Gateway to Your Application

Welcome to **Part 31** of the Django REST Framework & Next.js 16 masterclass. Now that we have our application configured for production, it's time to set up the reverse proxy and networking infrastructure. We'll configure Nginx to handle incoming traffic, manage SSL/TLS certificates, and route requests to the appropriate services.

In this part, we'll:
- Configure Nginx as a reverse proxy
- Set up SSL/TLS with Let's Encrypt
- Implement load balancing and caching
- Configure WebSocket support for Next.js
- Set up rate limiting at the proxy level
- Implement security headers

Think of the reverse proxy as your application's **reception desk**. Just as a receptionist greets visitors, directs them to the right department, and handles security, Nginx handles incoming requests, routes them to the right service, and manages security.

---

## The Target

We'll create a complete networking setup:

```
nginx/
├── nginx.conf                 # Main configuration
├── conf.d/
│   └── default.conf          # Site configuration
├── snippets/
│   ├── security-headers.conf # Security headers
│   └── ssl-params.conf      # SSL configuration
├── ssl/                      # SSL certificates
│   ├── cert.pem
│   └── key.pem
└── scripts/
    └── ssl-renewal.sh       # SSL certificate renewal
```

---

## The Concept

### Reverse Proxy Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Reverse Proxy Architecture                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      Internet                              │   │
│  └────────────────────────┬────────────────────────────────────┘   │
│                           │                                        │
│                           ▼                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Nginx (Port 80/443)                     │   │
│  │  - SSL/TLS Termination                                     │   │
│  │  - Load Balancing                                          │   │
│  │  - Rate Limiting                                           │   │
│  │  - Static File Serving                                     │   │
│  │  - Request Routing                                         │   │
│  └────────────────────────┬────────────────────────────────────┘   │
│                           │                                        │
│            ┌──────────────┴──────────────┐                        │
│            ▼                             ▼                        │
│  ┌─────────────────┐        ┌─────────────────┐                  │
│  │   /api/*        │        │   /*            │                  │
│  │   (Backend)     │        │   (Frontend)    │                  │
│  │   Port 8000     │        │   Port 3000     │                  │
│  └─────────────────┘        └─────────────────┘                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Nginx Features

| Feature | Purpose |
|---------|---------|
| **Reverse Proxy** | Route requests to internal services |
| **SSL/TLS Termination** | Handle HTTPS encryption |
| **Load Balancing** | Distribute traffic across multiple instances |
| **Static File Serving** | Serve static assets directly |
| **Caching** | Cache responses for better performance |
| **Rate Limiting** | Prevent abuse |
| **Security Headers** | Protect against attacks |
| **WebSocket Support** | Handle real-time connections |

---

## The Implementation

### Step 1: Update Nginx Configuration

**nginx/nginx.conf** (update)

```nginx
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# Load dynamic modules
# load_module modules/ngx_http_brotli_filter_module.so;
# load_module modules/ngx_http_brotli_static_module.so;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    log_format json escape=json '{'
        '"time_local":"$time_local",'
        '"remote_addr":"$remote_addr",'
        '"remote_user":"$remote_user",'
        '"request":"$request",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"http_referrer":"$http_referer",'
        '"http_user_agent":"$http_user_agent",'
        '"http_x_forwarded_for":"$http_x_forwarded_for"'
    '}';

    access_log /var/log/nginx/access.log json;

    # Performance settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 100;
    types_hash_max_size 2048;
    client_max_body_size 20M;
    client_body_timeout 60;
    client_header_timeout 60;

    # Buffers
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    output_buffers 32 32k;
    postpone_output 1460;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml image/svg+xml text/html;

    # Brotli compression (if module is available)
    # brotli on;
    # brotli_comp_level 6;
    # brotli_types text/plain text/css text/xml text/javascript 
    #             application/json application/javascript application/xml+rss 
    #             application/rss+xml image/svg+xml;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=2r/s;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Include site configurations
    include /etc/nginx/conf.d/*.conf;
}
```

### Step 2: Create Security Headers Snippet

**nginx/snippets/security-headers.conf** (create)

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

# HSTS (only for HTTPS)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Content Security Policy (adjust as needed)
add_header Content-Security-Policy "
    default-src 'self';
    img-src 'self' data: https:;
    style-src 'self' 'unsafe-inline';
    script-src 'self' 'unsafe-inline' 'unsafe-eval';
    font-src 'self' data:;
    connect-src 'self' https://api.taskflow.com wss://api.taskflow.com;
" always;
```

### Step 3: Create SSL Configuration Snippet

**nginx/snippets/ssl-params.conf** (create)

```nginx
# SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;

# SSL session settings
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;

# Diffie-Hellman parameters (generate with: openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048)
# ssl_dhparam /etc/nginx/ssl/dhparam.pem;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
```

### Step 4: Update Site Configuration

**nginx/conf.d/default.conf** (update)

```nginx
# Upstream definitions
upstream backend {
    server backend:8000;
    keepalive 32;
}

upstream frontend {
    server frontend:3000;
    keepalive 32;
}

# Rate limiting
limit_req_zone $binary_remote_addr zone=api_ratelimit:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth_ratelimit:10m rate=2r/s;

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name taskflow.com www.taskflow.com api.taskflow.com app.taskflow.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name taskflow.com www.taskflow.com api.taskflow.com app.taskflow.com;

    # SSL configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    include /etc/nginx/snippets/ssl-params.conf;

    # Security headers
    include /etc/nginx/snippets/security-headers.conf;

    # Health check endpoint (no logging)
    location /health/ {
        proxy_pass http://backend/health/;
        access_log off;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files (Django)
    location /static/ {
        alias /static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Media files (Django)
    location /media/ {
        alias /media/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # API endpoints
    location /api/ {
        limit_req zone=api_ratelimit burst=20 nodelay;
        
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
        
        # CORS headers
        add_header 'Access-Control-Allow-Origin' 'https://app.taskflow.com' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, PATCH, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        
        # Handle preflight
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' 'https://app.taskflow.com' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, PATCH, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        # Cache proxy responses
        proxy_cache_valid 200 302 5m;
        proxy_cache_valid 404 1m;
        proxy_cache_key "$scheme$request_method$host$request_uri";
    }

    # Authentication endpoints (stricter rate limit)
    location /api/v1/token/ {
        limit_req zone=auth_ratelimit burst=5 nodelay;
        
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
    }

    location /api/v1/users/register/ {
        limit_req zone=auth_ratelimit burst=5 nodelay;
        
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
    }

    # Admin interface (restrict by IP in production)
    location /admin/ {
        # Allow only specific IPs (optional)
        # allow 192.168.1.0/24;
        # deny all;
        
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API Documentation
    location /api/docs/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api/redoc/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend (all other routes)
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
        
        # WebSocket support for Next.js
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
        
        # Cache static assets
        location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            proxy_pass http://frontend;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

### Step 5: Create SSL Certificate Management Script

**nginx/scripts/ssl-setup.sh** (create)

```bash
#!/bin/bash

# SSL certificate setup script using Let's Encrypt

set -e

DOMAINS=("taskflow.com" "www.taskflow.com" "api.taskflow.com" "app.taskflow.com")
EMAIL="admin@taskflow.com"

echo "🔐 Setting up SSL certificates for: ${DOMAINS[*]}"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

# Stop Nginx for certificate generation
docker-compose -f docker-compose.prod.yml stop nginx

# Generate certificates
for DOMAIN in "${DOMAINS[@]}"; do
    echo "Processing $DOMAIN..."
    certbot certonly --standalone \
        --preferred-challenges http \
        --http-01-port 8080 \
        -d $DOMAIN \
        --email $EMAIL \
        --agree-tos \
        --non-interactive
done

# Copy certificates to Nginx directory
mkdir -p nginx/ssl
cp /etc/letsencrypt/live/taskflow.com/fullchain.pem nginx/ssl/cert.pem
cp /etc/letsencrypt/live/taskflow.com/privkey.pem nginx/ssl/key.pem

# Set proper permissions
chmod 600 nginx/ssl/key.pem

# Start Nginx
docker-compose -f docker-compose.prod.yml up -d nginx

echo "✅ SSL certificates installed successfully!"
```

### Step 6: Create SSL Renewal Script

**nginx/scripts/ssl-renewal.sh** (create)

```bash
#!/bin/bash

# SSL certificate renewal script

set -e

echo "🔄 Renewing SSL certificates..."

# Renew certificates
certbot renew --quiet

# Copy renewed certificates
cp /etc/letsencrypt/live/taskflow.com/fullchain.pem nginx/ssl/cert.pem
cp /etc/letsencrypt/live/taskflow.com/privkey.pem nginx/ssl/key.pem

# Restart Nginx to apply new certificates
docker-compose -f docker-compose.prod.yml restart nginx

echo "✅ SSL certificates renewed successfully!"
```

Make scripts executable:

```bash
chmod +x nginx/scripts/ssl-setup.sh
chmod +x nginx/scripts/ssl-renewal.sh
```

### Step 7: Create Network Security Configuration

**nginx/conf.d/security.conf** (create)

```nginx
# Security configuration

# Block common user agents
if ($http_user_agent ~* (wp-|python|java|perl|ruby|curl|wget)) {
    return 403;
}

# Block specific IPs (blacklist)
# deny 192.168.1.100;

# Rate limiting for specific paths
location /api/v1/token/ {
    limit_req zone=auth_ratelimit burst=5 nodelay;
}

# Prevent access to sensitive files
location ~* \.(sql|log|ini|conf|htaccess|htpasswd)$ {
    deny all;
}

# Prevent access to hidden files
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}
```

### Step 8: Update Docker Compose with SSL Volumes

**docker-compose.prod.yml** (update Nginx volumes)

```yaml
  nginx:
    image: nginx:alpine
    container_name: taskflow-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/snippets:/etc/nginx/snippets:ro
      - static_volume:/static:ro
      - media_volume:/media:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - ./logs/nginx:/var/log/nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
    networks:
      - taskflow-network
    restart: unless-stopped
```

---

## The Verification

### Step 1: Test Nginx Configuration

```bash
# Test Nginx configuration
docker-compose -f docker-compose.prod.yml exec nginx nginx -t
```

### Step 2: Start Services

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Step 3: Test Health Check

```bash
curl http://localhost/health/
```

### Step 4: Test API Endpoints

```bash
# Test API
curl http://localhost/api/v1/tasks/

# Test authentication (should be rate limited)
for i in {1..20}; do
    curl -X POST http://localhost/api/v1/token/ \
        -H "Content-Type: application/json" \
        -d '{"email":"test@example.com","password":"wrong"}' &
done
```

### Step 5: Test SSL (if configured)

```bash
# Test SSL certificate
openssl s_client -connect localhost:443 -servername taskflow.com

# Test HSTS headers
curl -I https://taskflow.com/
```

### Step 6: Test CORS

```bash
# Test CORS headers
curl -H "Origin: https://app.taskflow.com" \
     -H "Access-Control-Request-Method: POST" \
     -X OPTIONS https://api.taskflow.com/api/v1/tasks/ \
     -v
```

---

## Key Takeaways

1. **Reverse proxy** handles SSL termination, load balancing, and routing.

2. **SSL/TLS** encrypts all traffic between clients and the application.

3. **Rate limiting** at the proxy level prevents abuse.

4. **Security headers** protect against common vulnerabilities.

5. **WebSocket support** enables real-time features.

6. **Static file serving** offloads assets from the backend.

7. **CORS configuration** controls cross-origin access.

8. **SSL renewal** ensures continuous security.

---

## What's Next

In **Part 32**, we'll implement CI/CD:

- GitHub Actions workflow
- Automated testing
- Docker image building
- Deployment automation

---

**End of Part 31**

*Next: Part 32 - CI/CD*
