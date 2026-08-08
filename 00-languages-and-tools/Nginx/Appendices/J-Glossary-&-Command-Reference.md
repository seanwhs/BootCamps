# Appendix J: Glossary & Command Reference

## The Target

This appendix provides a comprehensive glossary of Nginx terminology and a complete command reference. Use this as your quick reference when working with Nginx.

## J.1 Nginx Terminology

### Core Concepts

| Term | Definition |
|------|------------|
| **Nginx** | Open-source web server and reverse proxy known for high performance and low memory usage |
| **Reverse Proxy** | Server that sits between clients and backend servers, forwarding requests and responses |
| **Upstream** | A group of backend servers that Nginx can proxy requests to |
| **Worker Process** | A single-threaded process that handles client connections |
| **Master Process** | The main Nginx process that reads configuration and manages worker processes |
| **Server Block** | Virtual server definition that handles requests for a specific domain/port |
| **Location Block** | URL pattern matching within a server block that defines how to handle specific paths |
| **Directive** | A configuration instruction in nginx.conf |
| **Context** | The scope in which a directive can be used (e.g., http, server, location) |
| **Variable** | A dynamic value that can be used in configuration (e.g., $remote_addr) |

### Proxy Concepts

| Term | Definition |
|------|------------|
| **Proxy Pass** | Directives that forwards requests to an upstream server |
| **Proxy Set Header** | Directive to set or modify HTTP headers before forwarding |
| **Proxy Buffer** | Temporary storage for response data before sending to client |
| **Proxy Cache** | Caching of responses from upstream servers |
| **Proxy Timeout** | Maximum time to wait for upstream responses |
| **Upstream Keepalive** | Persistent connections to upstream servers for better performance |
| **Health Check** | Verification that upstream servers are responsive |
| **Failover** | Automatic switch to backup servers when primary fails |
| **Load Balancing** | Distribution of requests across multiple servers |

### SSL/TLS Concepts

| Term | Definition |
|------|------------|
| **SSL/TLS** | Cryptographic protocols for secure communication |
| **Certificate** | Digital document that verifies server identity |
| **Private Key** | Cryptographic key used to decrypt SSL traffic |
| **HSTS** | HTTP Strict Transport Security - forces HTTPS usage |
| **OCSP Stapling** | Method to check certificate validity without contacting CA |
| **Cipher Suite** | Set of cryptographic algorithms for SSL/TLS |
| **Perfect Forward Secrecy** | Property where session keys are not compromised if private key is exposed |
| **SNI** | Server Name Indication - allows multiple certificates on same IP |

### Caching Concepts

| Term | Definition |
|------|------------|
| **Proxy Cache** | Caching of upstream responses on Nginx |
| **Cache Key** | Unique identifier for cached responses |
| **Cache Hit** | Request served from cache |
| **Cache Miss** | Request not found in cache, forwarded to upstream |
| **Cache Validation** | Checking if cached response is still fresh |
| **Micro-Caching** | Very short-lived caching (seconds) for dynamic content |
| **Cache Stampede** | Many requests hitting upstream simultaneously when cache expires |
| **Cache Warming** | Pre-populating cache with popular content |

### Rate Limiting Concepts

| Term | Definition |
|------|------------|
| **Rate Limiting** | Restricting request frequency from clients |
| **Zone** | Shared memory area for tracking request rates |
| **Burst** | Allowed exceeding of rate limit for short periods |
| **Nodelay** | Immediate processing of burst requests without delay |
| **Connection Limit** | Maximum concurrent connections from a client |

### Logging Concepts

| Term | Definition |
|------|------------|
| **Access Log** | Log of all client requests |
| **Error Log** | Log of errors and warnings |
| **Log Format** | Template for log entries |
| **Structured Logging** | Logs in machine-readable format (JSON) |
| **Request ID** | Unique identifier for a request across services |

## J.2 Complete Directive Reference

### Core Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `worker_processes` | main | Number of worker processes | `worker_processes auto;` |
| `worker_connections` | events | Max connections per worker | `worker_connections 1024;` |
| `user` | main | User to run as | `user nginx;` |
| `include` | any | Include external file | `include /etc/nginx/conf.d/*.conf;` |

### Server Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `server` | http | Virtual server definition | `server { ... }` |
| `listen` | server | Port to listen on | `listen 443 ssl http2;` |
| `server_name` | server | Domain names to match | `server_name example.com;` |
| `root` | server, location | Document root | `root /var/www/html;` |
| `index` | server, location | Default file | `index index.html;` |
| `error_page` | server, location | Custom error pages | `error_page 404 /404.html;` |

### Location Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `location` | server | URL pattern matching | `location /api/ { ... }` |
| `alias` | location | Alternative path | `alias /var/www/static/;` |
| `try_files` | location | File lookup sequence | `try_files $uri $uri/ =404;` |
| `expires` | location | Cache control | `expires 30d;` |
| `return` | server, location | Return response | `return 301 https://$host$uri;` |

### Proxy Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `proxy_pass` | location | Forward to upstream | `proxy_pass http://backend/;` |
| `proxy_set_header` | location | Set request headers | `proxy_set_header Host $host;` |
| `proxy_http_version` | location | HTTP version | `proxy_http_version 1.1;` |
| `proxy_buffering` | location | Enable buffering | `proxy_buffering off;` |
| `proxy_cache` | location | Enable caching | `proxy_cache my_cache;` |
| `proxy_cache_valid` | location | Cache validity | `proxy_cache_valid 200 5m;` |
| `proxy_cache_key` | location | Cache key | `proxy_cache_key $scheme$host$uri;` |
| `proxy_connect_timeout` | location | Connection timeout | `proxy_connect_timeout 5s;` |
| `proxy_read_timeout` | location | Read timeout | `proxy_read_timeout 60s;` |
| `proxy_send_timeout` | location | Send timeout | `proxy_send_timeout 60s;` |
| `proxy_next_upstream` | location | Retry on failure | `proxy_next_upstream error timeout;` |

### Upstream Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `upstream` | http | Server group definition | `upstream backend { ... }` |
| `server` | upstream | Upstream server | `server 10.0.0.1:8000 weight=3;` |
| `keepalive` | upstream | Keepalive connections | `keepalive 32;` |
| `least_conn` | upstream | Load balancing algorithm | `least_conn;` |
| `ip_hash` | upstream | Sticky sessions | `ip_hash;` |

### SSL Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `ssl_certificate` | server | Certificate path | `ssl_certificate /etc/nginx/ssl/cert.pem;` |
| `ssl_certificate_key` | server | Private key path | `ssl_certificate_key /etc/nginx/ssl/key.pem;` |
| `ssl_protocols` | server | TLS versions | `ssl_protocols TLSv1.2 TLSv1.3;` |
| `ssl_ciphers` | server | Cipher suites | `ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:...;` |
| `ssl_session_cache` | server | Session caching | `ssl_session_cache shared:SSL:10m;` |
| `ssl_stapling` | server | OCSP stapling | `ssl_stapling on;` |

### Rate Limiting Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `limit_req_zone` | http | Rate limit zone | `limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;` |
| `limit_req` | location | Apply rate limit | `limit_req zone=one burst=5 nodelay;` |
| `limit_conn_zone` | http | Connection limit zone | `limit_conn_zone $binary_remote_addr zone=addr:10m;` |
| `limit_conn` | location | Apply connection limit | `limit_conn addr 10;` |

### Logging Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `log_format` | http | Custom log format | `log_format main '$remote_addr -...';` |
| `access_log` | server, location | Access log | `access_log /var/log/nginx/access.log main;` |
| `error_log` | main, server | Error log | `error_log /var/log/nginx/error.log warn;` |

### Security Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `add_header` | server, location | Add response header | `add_header X-Frame-Options DENY;` |
| `allow` | location | Allow IP access | `allow 10.0.0.0/8;` |
| `deny` | location | Deny IP access | `deny all;` |
| `auth_request` | location | Authentication request | `auth_request /auth/validate;` |

### Compression Directives

| Directive | Context | Description | Example |
|-----------|---------|-------------|---------|
| `gzip` | http, server, location | Enable compression | `gzip on;` |
| `gzip_types` | http, server, location | Compress types | `gzip_types text/plain application/json;` |
| `gzip_comp_level` | http, server, location | Compression level | `gzip_comp_level 6;` |

## J.3 Complete Variable Reference

### Request Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `$remote_addr` | Client IP address | `192.168.1.100` |
| `$remote_port` | Client port | `54321` |
| `$request_method` | HTTP method | `GET` |
| `$request_uri` | Full request URI | `/api/users?page=1` |
| `$uri` | URI without query | `/api/users` |
| `$args` | Query string | `page=1` |
| `$query_string` | Full query string | `page=1&limit=10` |
| `$is_args` | "?" if args present | `?` or empty |
| `$host` | Host header | `example.com` |
| `$http_*` | HTTP headers | `$http_user_agent` |
| `$cookie_*` | Cookie values | `$cookie_sessionid` |

### Server Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `$server_name` | Server name | `example.com` |
| `$server_port` | Server port | `443` |
| `$server_addr` | Server IP | `10.0.0.1` |
| `$scheme` | Protocol | `https` |
| `$request_time` | Request processing time | `0.123` |
| `$request_id` | Unique request ID | `abc123def456` |
| `$status` | Response status | `200` |
| `$body_bytes_sent` | Response body size | `1024` |

### SSL Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `$ssl_protocol` | TLS version | `TLSv1.3` |
| `$ssl_cipher` | Cipher suite | `ECDHE-RSA-AES128-GCM-SHA256` |
| `$ssl_session_id` | Session ID | `abc123...` |
| `$ssl_client_verify` | Client verification | `SUCCESS` |

### Upstream Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `$upstream_addr` | Upstream address | `10.0.0.1:8000` |
| `$upstream_status` | Upstream status code | `200` |
| `$upstream_response_time` | Upstream response time | `0.123` |
| `$upstream_cache_status` | Cache status | `HIT`, `MISS`, `BYPASS` |

## J.4 Common Nginx Commands

### Configuration Commands

```bash
# Test configuration syntax
nginx -t

# Test with detailed output
nginx -T

# Test specific file
nginx -t -c /path/to/nginx.conf

# Show version
nginx -v

# Show version with modules
nginx -V

# Show help
nginx -h
```

### Process Management

```bash
# Start Nginx
nginx

# Stop Nginx (graceful)
nginx -s quit

# Stop Nginx (immediate)
nginx -s stop

# Reload configuration
nginx -s reload

# Reopen log files
nginx -s reopen

# Check if Nginx is running
ps aux | grep nginx
```

### Docker Commands

```bash
# Start Nginx in Docker
docker run -d --name nginx -p 80:80 nginx:alpine

# Stop container
docker stop nginx

# Start container
docker start nginx

# Restart container
docker restart nginx

# Exec into container
docker exec -it nginx /bin/sh

# Test config in container
docker exec nginx nginx -t

# Reload config in container
docker exec nginx nginx -s reload

# View logs
docker logs nginx
docker logs -f nginx
```

### Docker Compose Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart Nginx
docker compose restart nginx

# View logs
docker compose logs nginx
docker compose logs -f nginx

# Test config
docker compose run --rm nginx nginx -t

# Reload config
docker compose exec nginx nginx -s reload

# View status
docker compose ps
```

### Log Commands

```bash
# View access log
tail -f /var/log/nginx/access.log

# View error log
tail -f /var/log/nginx/error.log

# Search logs
grep "404" /var/log/nginx/access.log

# Count status codes
grep -c "502" /var/log/nginx/access.log

# View log with timestamps
tail -f /var/log/nginx/access.log | awk '{print $4, $7, $9}'

# Parse JSON logs
tail -f /var/log/nginx/access.log | jq '.'

# Rotate logs
logrotate -f /etc/logrotate.d/nginx
```

### Testing Commands

```bash
# Test HTTP
curl http://localhost

# Test HTTPS
curl -k https://localhost

# Test with headers
curl -v -H "Host: example.com" http://localhost

# Test WebSocket
curl -v -H "Connection: Upgrade" -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
    -H "Sec-WebSocket-Version: 13" \
    https://localhost/ws/

# Test performance
ab -n 1000 -c 10 https://localhost/api/

# Test SSL
openssl s_client -connect localhost:443

# Test DNS
dig backend
nslookup backend
```

### Debugging Commands

```bash
# Check network
netstat -tulpn | grep nginx
ss -lntp | grep nginx

# Check process
ps aux | grep nginx

# Check ports
lsof -i :80
lsof -i :443

# Check files
ls -la /etc/nginx/conf.d/

# Check permissions
ls -la /var/log/nginx/

# Check cache
ls -la /var/cache/nginx/
du -sh /var/cache/nginx/
```

## J.5 Nginx Upgrade Commands

### Linux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade nginx

# CentOS/RHEL
sudo yum update nginx

# Alpine
apk update && apk upgrade nginx
```

### Docker

```bash
# Pull new image
docker pull nginx:1.27-alpine

# Stop and remove old container
docker stop nginx
docker rm nginx

# Run new container
docker run -d --name nginx -p 80:80 nginx:1.27-alpine
```

### Docker Compose

```bash
# Pull new image
docker compose pull nginx

# Recreate container
docker compose up -d --force-recreate --no-deps nginx
```

## J.6 Environment Variables

### Nginx Docker Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NGINX_HOST` | Server name | `localhost` |
| `NGINX_PORT` | Port to listen on | `80` |
| `NGINX_SSL_PORT` | SSL port | `443` |
| `NGINX_WORKER_PROCESSES` | Number of workers | `auto` |
| `NGINX_WORKER_CONNECTIONS` | Connections per worker | `1024` |
| `NGINX_KEEPALIVE_TIMEOUT` | Keepalive timeout | `65` |
| `NGINX_MAX_BODY_SIZE` | Max request body size | `1M` |
| `NGINX_LOG_LEVEL` | Log level | `warn` |
| `NGINX_CACHE_SIZE` | Cache size | `100m` |
| `NGINX_RATE_LIMIT` | Rate limit | `1r/s` |

## J.7 File Locations

### Nginx File Locations

| File/Directory | Purpose |
|----------------|---------|
| `/etc/nginx/nginx.conf` | Main configuration file |
| `/etc/nginx/conf.d/` | Additional configuration files |
| `/etc/nginx/sites-available/` | Available virtual hosts |
| `/etc/nginx/sites-enabled/` | Enabled virtual hosts |
| `/etc/nginx/ssl/` | SSL certificates |
| `/var/log/nginx/access.log` | Access log |
| `/var/log/nginx/error.log` | Error log |
| `/var/cache/nginx/` | Cache directory |
| `/usr/share/nginx/html/` | Default document root |
| `/etc/nginx/mime.types` | MIME types |
| `/var/run/nginx.pid` | PID file |

### Docker Volume Locations

```yaml
volumes:
  - ./nginx.conf:/etc/nginx/nginx.conf:ro
  - ./conf.d:/etc/nginx/conf.d:ro
  - ./ssl:/etc/nginx/ssl:ro
  - ./logs:/var/log/nginx
  - ./cache:/var/cache/nginx
  - ./html:/usr/share/nginx/html:ro
```

---

This glossary and command reference provides a comprehensive quick-reference for all Nginx-related terminology and commands. Keep it handy when working with Nginx in development or production environments.
