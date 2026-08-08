# Appendix A: Nginx Quick Reference Guide

## The Target

This appendix serves as your go-to reference for everything Nginx. Whether you're debugging a configuration, looking up a directive, or need a quick reminder of how something works, this guide has you covered.

## A.1 Nginx Architecture Overview

### Request Processing Flow

```
Client Request
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│                    NGINX REQUEST LIFE CYCLE                 │
├─────────────────────────────────────────────────────────────┤
│  1. Accept Connection    →  listen, server_name            │
│  2. Read Request         →  request_line, headers          │
│  3. Server Selection     →  server block matching          │
│  4. Location Selection   →  location directive             │
│  5. Handler Execution    →  proxy_pass, try_files          │
│  6. Content Generation   →  upstream response              │
│  7. Response Filtering   →  gzip, headers, sub_filter      │
│  8. Logging              →  access_log, error_log          │
│  9. Connection Close     →  keepalive_timeout              │
└─────────────────────────────────────────────────────────────┘
      │
      ▼
Client Response
```

### Nginx Process Model

```
                   ┌─────────────────────┐
                   │   Master Process    │
                   │  (reads config,     │
                   │   manages workers)  │
                   └──────────┬──────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  Worker 1     │    │  Worker 2     │    │  Worker N     │
│ (handles      │    │ (handles      │    │ (handles      │
│  connections) │    │  connections) │    │  connections) │
└───────────────┘    └───────────────┘    └───────────────┘
```

## A.2 Configuration Structure

### Main Configuration Hierarchy

```
nginx.conf
├── user                # Process user
├── worker_processes    # Number of workers
├── error_log           # Error log location/level
├── pid                 # PID file location
├── events { ... }      # Connection handling
└── http {              # HTTP protocol settings
    ├── include mime.types
    ├── default_type
    ├── log_format
    ├── access_log
    ├── sendfile
    ├── keepalive_timeout
    ├── gzip
    ├── upstream { ... }    # Upstream server groups
    ├── server {            # Virtual server
    │   ├── listen
    │   ├── server_name
    │   ├── ssl_*
    │   ├── location / {    # URL matching
    │   │   ├── proxy_pass
    │   │   ├── proxy_set_header
    │   │   └── ...
    │   │   }
    │   └── ...
    │   }
    └── ...
    }
```

### Directive Types

| Type | Syntax | Example |
|------|--------|---------|
| **Standard** | `directive value;` | `worker_processes auto;` |
| **Block** | `directive { ... }` | `server { ... }` |
| **Context** | `context { ... }` | `events { ... }` |
| **Array** | Multiple lines | `proxy_set_header Host $host;` |

## A.3 Core Directives Reference

### Global Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `worker_processes` | Number of worker processes | `auto;` |
| `worker_connections` | Max connections per worker | `1024;` |
| `user` | User to run as | `nginx;` |
| `pid` | PID file location | `/var/run/nginx.pid;` |
| `error_log` | Error log | `/var/log/nginx/error.log warn;` |
| `include` | Include external files | `include /etc/nginx/conf.d/*.conf;` |

### HTTP Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `sendfile` | Efficient file transfer | `on;` |
| `tcp_nopush` | Optimize packet sending | `on;` |
| `tcp_nodelay` | Disable Nagle's algorithm | `on;` |
| `keepalive_timeout` | Keep connection alive | `65;` |
| `client_max_body_size` | Max request body size | `10M;` |
| `default_type` | Default MIME type | `application/octet-stream;` |
| `include` | Include mime types | `include /etc/nginx/mime.types;` |
| `server_tokens` | Show/hide nginx version | `off;` |

### Server Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `listen` | Port/interface to bind to | `443 ssl http2;` |
| `server_name` | Domain name(s) | `example.com www.example.com;` |
| `root` | Document root | `/var/www/html;` |
| `index` | Default file | `index.html;` |
| `error_page` | Custom error pages | `404 /404.html;` |

### SSL Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `ssl_certificate` | Certificate path | `/etc/nginx/ssl/cert.pem;` |
| `ssl_certificate_key` | Private key path | `/etc/nginx/ssl/key.pem;` |
| `ssl_protocols` | TLS versions | `TLSv1.2 TLSv1.3;` |
| `ssl_ciphers` | Cipher suites | `ECDHE-RSA-AES128-GCM-SHA256:...;` |
| `ssl_prefer_server_ciphers` | Server chooses cipher | `off;` |
| `ssl_session_cache` | Session caching | `shared:SSL:10m;` |
| `ssl_session_timeout` | Session timeout | `1h;` |
| `ssl_stapling` | OCSP stapling | `on;` |

### Location Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `location` | URL pattern match | `location /api/ { ... }` |
| `alias` | Alternative path | `alias /var/www/static/;` |
| `try_files` | Try files in order | `try_files $uri $uri/ =404;` |
| `expires` | Cache control | `expires 30d;` |
| `return` | Return status/redirect | `return 301 https://$host$uri;` |
| `rewrite` | Rewrite URL | `rewrite ^/old/(.*) /new/$1 permanent;` |

### Proxy Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `proxy_pass` | Upstream address | `http://backend:8000/;` |
| `proxy_set_header` | Set request headers | `X-Forwarded-Proto $scheme;` |
| `proxy_http_version` | HTTP version | `1.1;` |
| `proxy_buffering` | Enable/disable buffering | `off;` |
| `proxy_cache` | Enable cache | `api_cache;` |
| `proxy_cache_valid` | Cache validity | `200 5m;` |
| `proxy_cache_key` | Cache key | `$scheme$host$request_uri;` |
| `proxy_connect_timeout` | Connect timeout | `5s;` |
| `proxy_read_timeout` | Read timeout | `60s;` |
| `proxy_send_timeout` | Send timeout | `60s;` |

### Upstream Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `upstream` | Server group definition | `api_backend { ... }` |
| `server` | Upstream server | `server 10.0.0.1:8000 weight=3;` |
| `keepalive` | Keepalive connections | `keepalive 32;` |
| `least_conn` | Load balancing algorithm | `least_conn;` |
| `ip_hash` | Sticky sessions | `ip_hash;` |
| `max_fails` | Failure count to mark down | `max_fails=3;` |
| `fail_timeout` | Timeout for failure detection | `fail_timeout=30s;` |
| `backup` | Backup server | `server 10.0.0.2:8000 backup;` |

### Logging Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `log_format` | Custom log format | `log_format main '$remote_addr -...';` |
| `access_log` | Access log path/format | `access_log /var/log/nginx/access.log main;` |
| `error_log` | Error log path/level | `error_log /var/log/nginx/error.log warn;` |

### Rate Limiting Settings

| Directive | Description | Example |
|-----------|-------------|---------|
| `limit_req_zone` | Rate limiting zone | `limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;` |
| `limit_req` | Apply rate limit | `limit_req zone=one burst=5;` |
| `limit_conn_zone` | Connection limit zone | `limit_conn_zone $binary_remote_addr zone=addr:10m;` |
| `limit_conn` | Apply connection limit | `limit_conn addr 10;` |

## A.4 Location Matching Rules

### Location Types (Priority Order)

```
1. Exact Match       location = /exact    → Highest Priority
2. Preferential      location ^~ /pref   → Highest before regex
3. Regex (case-sens) location ~ /regex   → Higher
4. Regex (no case)   location ~* /regex  → Higher
5. Prefix Match      location /prefix    → Lower Priority
6. Catch-all         location /          → Lowest Priority
```

### Location Examples

```nginx
# 1. Exact match - matches ONLY /exact
location = /exact {
    return 200 "Exact match\n";
}

# 2. Preferential prefix - matches /pref/*, stops regex
location ^~ /preferred/ {
    return 200 "Preferential prefix match\n";
}

# 3. Case-sensitive regex - matches /pattern/ with case
location ~ /pattern/ {
    return 200 "Case-sensitive regex match\n";
}

# 4. Case-insensitive regex - matches /pattern/ (any case)
location ~* /pattern/ {
    return 200 "Case-insensitive regex match\n";
}

# 5. Prefix match - matches /docs/*
location /docs {
    return 200 "Prefix match\n";
}

# 6. Catch-all - matches everything else
location / {
    return 200 "Catch-all match\n";
}
```

### Request Matching Examples

| Request URI | `=/api` | `^~/api/` | `~/api/v[0-9]/` | `/api/` |
|-------------|---------|-----------|-----------------|---------|
| `/api` | ✅ | ❌ | ❌ | ❌ |
| `/api/` | ❌ | ✅ | ❌ | ✅ |
| `/api/v1/` | ❌ | ❌ | ✅ | ✅ |
| `/api/v2/` | ❌ | ❌ | ✅ | ✅ |
| `/api/v3/` | ❌ | ❌ | ✅ | ✅ |

### Location Precedence Examples

```nginx
location /api/ {                    # Priority 5
    proxy_pass http://backend1/;
}

location ~ /api/v[0-9]+/ {          # Priority 3 (regex)
    proxy_pass http://backend2/;
}

location ^~ /api/v2/ {              # Priority 2 (preferential)
    proxy_pass http://backend3/;
}

location = /api/v2/status {         # Priority 1 (exact)
    proxy_pass http://backend4/;
}

# Request: /api/v2/status
# Matches: exact match → backend4

# Request: /api/v2/users
# Matches: preferential prefix → backend3

# Request: /api/v1/users
# Matches: regex → backend2

# Request: /api/status
# Matches: prefix → backend1
```

## A.5 Variable Reference

### Core Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `$args` | Request query string | `?q=test` |
| `$http_*` | Request headers | `$http_user_agent` |
| `$remote_addr` | Client IP address | `192.168.1.100` |
| `$remote_port` | Client port | `54321` |
| `$request_method` | Request method | `GET`, `POST` |
| `$request_uri` | Full request URI | `/api/users?page=1` |
| `$uri` | URI without query string | `/api/users` |
| `$host` | Host header | `example.com` |
| `$hostname` | Server hostname | `server1` |
| `$server_name` | Server name from config | `example.com` |
| `$server_port` | Server port | `443` |
| `$scheme` | Protocol scheme | `http` or `https` |
| `$is_args` | "?" if arguments exist | `?` or empty |
| `$query_string` | Query string (same as args) | `q=test` |
| `$request_time` | Request processing time | `0.123` |
| `$request_id` | Unique request ID | `abc123` |
| `$status` | Response status | `200` |
| `$body_bytes_sent` | Response body size | `1024` |
| `$content_length` | Content-Length header | `1024` |
| `$content_type` | Content-Type header | `application/json` |
| `$cookie_*` | Cookie values | `$cookie_sessionid` |
| `$http_user_agent` | User-Agent header | `Mozilla/5.0...` |
| `$http_referer` | Referer header | `https://google.com` |

### SSL Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `$ssl_protocol` | SSL/TLS version | `TLSv1.3` |
| `$ssl_cipher` | SSL cipher suite | `ECDHE-RSA-AES128-GCM-SHA256` |
| `$ssl_session_id` | SSL session ID | `abc123` |
| `$ssl_client_cert` | Client certificate | `-----BEGIN CERTIFICATE...` |
| `$ssl_client_verify` | Client verification status | `SUCCESS` |

### Upstream Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `$upstream_addr` | Upstream server address | `10.0.0.1:8000` |
| `$upstream_status` | Upstream status code | `200` |
| `$upstream_response_time` | Response time | `0.123` |
| `$upstream_cache_status` | Cache status | `HIT`, `MISS`, `BYPASS` |
| `$upstream_connect_time` | Connect time | `0.001` |
| `$upstream_header_time` | Header time | `0.005` |

## A.6 Common Patterns

### Pattern 1: Basic Reverse Proxy

```nginx
location / {
    proxy_pass http://backend:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Pattern 2: Path-Based Routing

```nginx
location /api/ {
    proxy_pass http://api_backend/;
    proxy_set_header Host $host;
}

location /admin/ {
    proxy_pass http://admin_backend/;
    proxy_set_header Host $host;
}
```

### Pattern 3: WebSocket Proxy

```nginx
location /ws/ {
    proxy_pass http://websocket_backend/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 300s;
}
```

### Pattern 4: Caching Configuration

```nginx
proxy_cache_path /var/cache/nginx/cache levels=1:2 keys_zone=my_cache:100m max_size=1g inactive=1h;

location /api/ {
    proxy_cache my_cache;
    proxy_cache_key $scheme$host$request_uri;
    proxy_cache_valid 200 302 5m;
    proxy_cache_use_stale error timeout updating;
    add_header X-Cache-Status $upstream_cache_status;
    proxy_pass http://backend/;
}
```

### Pattern 5: Rate Limiting

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;

location /api/ {
    limit_req zone=api_limit burst=10 nodelay;
    proxy_pass http://backend/;
}
```

### Pattern 6: Load Balancing

```nginx
upstream backend {
    server 10.0.0.1:8000 weight=3 max_fails=3 fail_timeout=30s;
    server 10.0.0.2:8000 weight=1 max_fails=3 fail_timeout=30s;
    server 10.0.0.3:8000 backup;
    keepalive 32;
}

location / {
    proxy_pass http://backend/;
}
```

### Pattern 7: SSL Termination

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:...;
    
    location / {
        proxy_pass http://backend/;
    }
}

server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}
```

### Pattern 8: Security Headers

```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self';" always;
```

### Pattern 9: Static Files

```nginx
location /static/ {
    alias /var/www/static/;
    expires 30d;
    add_header Cache-Control "public, immutable";
    add_header X-Content-Type-Options "nosniff";
}

location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}
```

### Pattern 10: Health Checks

```nginx
location /health {
    proxy_pass http://backend/health;
    proxy_connect_timeout 2s;
    proxy_read_timeout 5s;
    access_log off;
}

location = /nginx-health {
    access_log off;
    return 200 "healthy\n";
}
```

## A.7 Error Codes and Troubleshooting

### Common Error Codes

| Code | Description | Common Causes |
|------|-------------|---------------|
| 400 | Bad Request | Invalid headers, malformed request |
| 401 | Unauthorized | Missing/invalid authentication |
| 403 | Forbidden | Access denied by configuration |
| 404 | Not Found | Missing file/route |
| 405 | Method Not Allowed | HTTP method not supported |
| 429 | Too Many Requests | Rate limit exceeded |
| 499 | Client Closed Request | Client disconnected |
| 500 | Internal Server Error | Application error |
| 502 | Bad Gateway | Upstream connection failed |
| 503 | Service Unavailable | No upstream available |
| 504 | Gateway Timeout | Upstream timeout |

### Debugging Commands

```bash
# Test configuration
nginx -t

# Test with full configuration dump
nginx -T

# Check version and modules
nginx -V

# View running configuration
docker exec nginx-proxy nginx -T

# Reload configuration
nginx -s reload
docker exec nginx-proxy nginx -s reload

# Check logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# Debug with curl
curl -v https://localhost/api/
curl -I https://localhost/api/
curl -H "Host: example.com" https://localhost/

# Test upstream directly
curl http://localhost:8000/health

# Check DNS resolution
dig backend
nslookup backend

# Check ports
netstat -tulpn | grep 80
ss -lntp | grep 443
```

### Troubleshooting Flow

```
1. Is Nginx running?
   ├── ps aux | grep nginx
   └── systemctl status nginx

2. Is configuration valid?
   ├── nginx -t
   └── Check error logs

3. Is the upstream running?
   ├── curl http://upstream:port/health
   └── Check application logs

4. Is network connectivity working?
   ├── ping upstream
   └── telnet upstream port

5. Are timeouts sufficient?
   ├── Check proxy_*_timeout
   └── Check application processing time

6. Are headers correct?
   ├── Check proxy_set_header
   └── Check application logs

7. Is caching causing issues?
   ├── Check X-Cache-Status
   └── Disable cache for testing
```

## A.8 Quick Commands Reference

### Service Management

```bash
# Start Nginx
nginx
docker compose up -d nginx

# Stop Nginx
nginx -s stop
docker compose down nginx

# Reload configuration (zero-downtime)
nginx -s reload
docker exec nginx-proxy nginx -s reload

# Test configuration
nginx -t
docker exec nginx-proxy nginx -t

# Show running configuration
nginx -T
docker exec nginx-proxy nginx -T
```

### Log Management

```bash
# View access logs
tail -f /var/log/nginx/access.log

# View error logs
tail -f /var/log/nginx/error.log

# Filter logs
grep "502" /var/log/nginx/access.log
grep -i "error" /var/log/nginx/error.log

# Parse JSON logs
tail -f /var/log/nginx/access.log | jq '.'

# Log rotation
logrotate /etc/logrotate.d/nginx
```

### Cache Management

```bash
# View cache stats
ls -la /var/cache/nginx/

# Clear cache
rm -rf /var/cache/nginx/*

# View cache size
du -sh /var/cache/nginx/
```

### SSL/TLS Testing

```bash
# Test SSL certificate
openssl s_client -connect localhost:443

# Test TLS 1.3
openssl s_client -connect localhost:443 -tls1_3

# Test specific cipher
openssl s_client -connect localhost:443 -cipher ECDHE-RSA-AES128-GCM-SHA256

# Get certificate details
openssl x509 -in cert.pem -text -noout

# Test certificate expiry
openssl x509 -in cert.pem -enddate -noout
```

## A.9 Useful Snippets

### Docker Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### Environment Variable Substitution

```nginx
# In Docker environment (using envsubst)
location / {
    proxy_pass http://${BACKEND_HOST}:${BACKEND_PORT}/;
}

# Using map for dynamic values
map $host $backend {
    default backend1:8000;
    api.example.com backend2:8000;
}
```

### Conditional Logic

```nginx
# Based on request method
if ($request_method = POST) {
    proxy_pass http://backend_write/;
}

# Based on user agent
if ($http_user_agent ~* "curl") {
    return 403;
}

# Based on cookie
if ($cookie_sessionid) {
    proxy_pass http://auth_backend/;
}
```

### Log Rotation Configuration

```nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 nginx nginx
    postrotate
        nginx -s reload
    endscript
}
```

This appendix should be your first stop whenever you need a quick Nginx reference. Keep it handy!
