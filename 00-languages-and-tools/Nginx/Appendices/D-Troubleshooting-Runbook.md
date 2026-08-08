# Appendix D: Troubleshooting Runbook

## The Target

This appendix is your comprehensive troubleshooting guide for Nginx in production. When something breaks—and it will—this is where you start. Each section follows a consistent pattern: symptom, investigation, diagnosis, resolution, and prevention.

## D.1 Quick Reference: Error Code Map

| Error | Most Likely Cause | First Action |
|-------|-------------------|--------------|
| 400 | Malformed request | Check request headers |
| 401 | Missing/invalid auth | Verify authentication headers |
| 403 | Access denied | Check IP restrictions/permissions |
| 404 | Missing resource | Verify path and routing |
| 405 | Method not allowed | Check allowed methods |
| 413 | Payload too large | Increase client_max_body_size |
| 429 | Rate limit exceeded | Check rate limiting configuration |
| 499 | Client disconnected | Check client-side network |
| 500 | Application error | Check application logs |
| 502 | Upstream connection failed | Check upstream service |
| 503 | No upstream available | Check all upstream instances |
| 504 | Upstream timeout | Check timeouts and performance |

## D.2 Common Scenarios

### Scenario 1: 502 Bad Gateway

**Symptom:**
```text
HTTP/1.1 502 Bad Gateway
Server: nginx/1.27.0
```

**Investigation:**

```bash
# 1. Check Nginx error log
tail -50 /var/log/nginx/error.log | grep "502"

# 2. Check upstream service status
docker ps | grep backend
curl http://localhost:8000/health

# 3. Test connectivity from Nginx
docker exec nginx-proxy ping backend
docker exec nginx-proxy curl -v http://backend:8000/health

# 4. Check network configuration
docker network ls
docker network inspect app-network

# 5. Verify Nginx configuration
nginx -T | grep -A10 "upstream backend"
```

**Diagnosis:**

Common causes in order of frequency:

1. **Upstream service is down**
   ```bash
   # Check if service is running
   docker ps | grep backend
   # If not, start it
   docker compose up -d backend
   ```

2. **Wrong hostname or port**
   ```nginx
   # Check proxy_pass in config
   proxy_pass http://backend:8000;  # Should match service name and port
   ```
   
   ```yaml
   # Check service name in docker-compose.yml
   backend:
     container_name: backend
     ports:
       - "8000:8000"
   ```

3. **Upstream service not ready**
   ```bash
   # Check service logs
   docker logs backend --tail 50
   # Look for "Application startup complete" or similar
   ```

4. **Connection timeout**
   ```nginx
   # Increase timeouts
   proxy_connect_timeout 10s;
   proxy_read_timeout 60s;
   ```

**Resolution:**

```bash
# Most common fix: restart upstream
docker compose restart backend

# Or restart all services
docker compose restart

# Or reload Nginx
docker exec nginx-proxy nginx -s reload
```

**Prevention:**

```yaml
# docker-compose.yml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
```

```nginx
# nginx.conf
upstream backend {
    server backend1:8000 max_fails=3 fail_timeout=30s;
    server backend2:8000 max_fails=3 fail_timeout=30s;
    keepalive 32;
}
```

### Scenario 2: 504 Gateway Timeout

**Symptom:**
```text
HTTP/1.1 504 Gateway Timeout
Server: nginx/1.27.0
```

**Investigation:**

```bash
# 1. Check request times
tail -100 /var/log/nginx/access.log | grep "request_time"

# 2. Test upstream directly
time curl -v http://localhost:8000/slow-endpoint

# 3. Check Nginx timeouts
nginx -T | grep -E "proxy_(read|connect|send)_timeout"

# 4. Check application performance
docker logs backend --tail 50 | grep -i "slow\|timeout"
```

**Diagnosis:**

1. **Application is too slow**
   ```python
   # Check for slow queries, external API calls, or heavy processing
   # Add timing logs to identify bottlenecks
   import time
   start = time.time()
   # ... slow operation ...
   logger.info(f"Operation took {time.time() - start}s")
   ```

2. **Timeout too short**
   ```nginx
   # Default is 60s - increase if needed
   proxy_read_timeout 120s;
   proxy_connect_timeout 10s;
   proxy_send_timeout 120s;
   ```

3. **Long-running requests without response**
   ```nginx
   # For streaming responses, disable buffering
   proxy_buffering off;
   proxy_request_buffering off;
   ```

**Resolution:**

```nginx
# Increase timeouts for slow endpoints
location /slow/ {
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 300s;
    proxy_pass http://backend/slow/;
}
```

**Prevention:**

```nginx
# Add caching for slow endpoints
location /slow/ {
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
    proxy_cache_use_stale error timeout updating;
    proxy_cache_lock on;
    proxy_pass http://backend/slow/;
}
```

### Scenario 3: 429 Too Many Requests

**Symptom:**
```text
HTTP/1.1 429 Too Many Requests
```

**Investigation:**

```bash
# 1. Check rate limiting configuration
nginx -T | grep -A5 "limit_req"

# 2. View rate limiting logs
grep "429" /var/log/nginx/access.log

# 3. Count requests per IP
tail -100 /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -nr

# 4. Check current rates
docker exec nginx-proxy nginx -T | grep "limit_req_zone"
```

**Diagnosis:**

1. **Too aggressive rate limit**
   ```nginx
   # Current limit might be too low
   limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/m;
   # Increase if legitimate traffic
   limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
   ```

2. **Legitimate traffic pattern**
   ```bash
   # Monitor traffic patterns
   tail -f /var/log/nginx/access.log | awk '{print $1}' | uniq -c
   ```

3. **Too many burst requests**
   ```nginx
   # Add burst capacity
   limit_req zone=api_limit burst=20 nodelay;
   ```

**Resolution:**

```nginx
# Adjust rate limits
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;

location /api/ {
    limit_req zone=api_limit burst=20 nodelay;
    proxy_pass http://backend/;
}
```

**Prevention:**

```nginx
# Whitelist internal IPs
geo $limit_whitelist {
    default 1;
    10.0.0.0/8 0;
    172.16.0.0/12 0;
    192.168.0.0/16 0;
}

limit_req zone=api_limit burst=10 nodelay if=$limit_whitelist;
```

### Scenario 4: SSL/TLS Issues

**Symptom:**
```text
SSL handshake failed
SSL certificate error
Mixed content warnings
```

**Investigation:**

```bash
# 1. Check certificate validity
openssl x509 -in /etc/nginx/ssl/cert.pem -text -noout
openssl x509 -in /etc/nginx/ssl/cert.pem -enddate -noout

# 2. Test TLS connection
openssl s_client -connect localhost:443 -tls1_3

# 3. Check SSL configuration
nginx -T | grep -A10 "ssl_"

# 4. Test from browser
curl -kv https://localhost/api/
```

**Diagnosis:**

1. **Expired certificate**
   ```bash
   # Check expiration date
   openssl x509 -in cert.pem -enddate -noout
   ```

2. **Wrong certificate paths**
   ```nginx
   # Verify paths in nginx.conf
   ssl_certificate /etc/nginx/ssl/cert.pem;
   ssl_certificate_key /etc/nginx/ssl/key.pem;
   ```

3. **Weak cipher configuration**
   ```nginx
   # Ensure modern ciphers
   ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:...';
   ```

**Resolution:**

```bash
# Renew certificate
# For Let's Encrypt:
docker exec certbot certbot renew

# For self-signed:
./generate-ssl.sh

# Reload Nginx
docker exec nginx-proxy nginx -s reload
```

**Prevention:**

```bash
# Set up automatic renewal (Let's Encrypt)
0 0 * * * /usr/local/bin/nginx-certbot-renew.sh

# Monitor certificate expiry
check_ssl_cert() {
    expiry=$(openssl x509 -in cert.pem -enddate -noout | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry" +%s)
    now=$(date +%s)
    days=$(( ($expiry_epoch - $now) / 86400 ))
    if [ $days -lt 30 ]; then
        echo "WARNING: Certificate expires in $days days"
    fi
}
```

### Scenario 5: WebSocket Connection Issues

**Symptom:**
```text
WebSocket connection failed
WebSocket disconnects immediately
Error: Unexpected response code: 400
```

**Investigation:**

```bash
# 1. Test WebSocket upgrade
curl -v -H "Connection: Upgrade" \
     -H "Upgrade: websocket" \
     -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
     -H "Sec-WebSocket-Version: 13" \
     https://localhost/ws/

# 2. Check Nginx configuration
nginx -T | grep -A20 "location /ws/"

# 3. View WebSocket logs
grep -i "websocket\|upgrade" /var/log/nginx/access.log
```

**Diagnosis:**

1. **Missing upgrade headers**
   ```nginx
   # Required for WebSocket
   proxy_http_version 1.1;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "upgrade";
   ```

2. **Buffering enabled**
   ```nginx
   # WebSockets need buffering disabled
   proxy_buffering off;
   ```

3. **Timeout too short**
   ```nginx
   # WebSockets need long timeouts
   proxy_read_timeout 300s;
   ```

**Resolution:**

```nginx
location /ws/ {
    proxy_pass http://websocket_backend/;
    
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_buffering off;
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 300s;
    
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### Scenario 6: Mixed Content Warnings

**Symptom:**
```text
Mixed Content: The page at 'https://example.com' was loaded over HTTPS, 
but requested an insecure resource 'http://example.com/api/'
```

**Investigation:**

```bash
# 1. Check forwarded protocol headers
curl -kv https://localhost/api/debug | grep -i "x-forwarded-proto"

# 2. Verify application configuration
# Check if application knows it's behind HTTPS
```

**Diagnosis:**

1. **Missing X-Forwarded-Proto**
   ```nginx
   # Add this to proxy
   proxy_set_header X-Forwarded-Proto $scheme;
   ```

2. **Application generating HTTP URLs**
   ```python
   # In FastAPI/Django, check:
   # - FORCE_SSL settings
   # - SECURE_PROXY_SSL_HEADER
   # - X-Forwarded-Proto usage
   ```

3. **Static assets with HTTP URLs**
   ```html
   <!-- Change from -->
   <img src="http://example.com/image.png">
   <!-- To -->
   <img src="//example.com/image.png">
   ```

**Resolution:**

```nginx
location /api/ {
    proxy_pass http://backend/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;  # Critical
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

**Prevention:**

```python
# FastAPI - ensure protocol is forwarded
@app.middleware("http")
async def add_forwarded_headers(request: Request, call_next):
    # X-Forwarded-Proto is already set by Nginx
    response = await call_next(request)
    return response

# Next.js - use environment variables
const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://localhost/api';
```

## D.3 Debugging Toolkit

### Essential Commands

```bash
# Configuration
nginx -t                    # Test configuration
nginx -T                    # Show full configuration
nginx -s reload             # Reload without downtime

# Logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
grep -i "error" /var/log/nginx/error.log

# Testing
curl -v https://localhost/api/
curl -I https://localhost/api/
curl -H "Host: example.com" https://localhost/api/
curl --resolve example.com:443:127.0.0.1 https://example.com/api/

# Network
netstat -tulpn | grep 80
ss -lntp | grep 443
docker exec nginx-proxy netstat -an | grep ':443'

# Docker
docker ps
docker logs nginx-proxy --tail 50
docker exec nginx-proxy nginx -T
docker compose up -d
docker compose down
docker compose restart nginx
```

### Debugging with Headers

```bash
# Add debug headers to see what's happening
curl -v -H "X-Debug: true" https://localhost/api/

# Check if headers are being forwarded
curl -v -H "X-Test-Header: test-value" https://localhost/debug/headers
```

### Tracing a Request

```bash
# 1. Generate a request ID
REQUEST_ID=$(uuidgen)

# 2. Make request with ID
curl -v -H "X-Request-ID: $REQUEST_ID" https://localhost/api/

# 3. Find the request in logs
grep "$REQUEST_ID" /var/log/nginx/access.log
grep "$REQUEST_ID" /var/log/nginx/error.log

# 4. Check application logs
docker logs backend | grep "$REQUEST_ID"
```

### Performance Profiling

```bash
# 1. Check response times
tail -100 /var/log/nginx/access.log | jq '.request_time'

# 2. Find slow requests
tail -100 /var/log/nginx/access.log | jq 'select(.request_time > 1)'

# 3. Check upstream response times
tail -100 /var/log/nginx/access.log | jq '.upstream_response_time'

# 4. Monitor cache hit ratio
tail -100 /var/log/nginx/access.log | jq -r '.upstream_cache_status' | sort | uniq -c
```

## D.4 Emergency Procedures

### Emergency: Nginx Won't Start

```bash
# 1. Check configuration
nginx -t

# If config test fails:
# - Check syntax errors
# - Validate file permissions
# - Check for missing include files

# 2. View error log
tail -50 /var/log/nginx/error.log

# 3. Start with minimal config
cp nginx.conf nginx.conf.backup
cat > nginx.conf << 'EOF'
events {}
http {
    server {
        listen 80;
        location / {
            return 200 "Emergency mode\n";
        }
    }
}
EOF

# 4. Start Nginx
nginx

# 5. Restore working config
cp nginx.conf.backup nginx.conf
nginx -t && nginx -s reload
```

### Emergency: High Memory/CPU

```bash
# 1. Check memory usage
free -h
ps aux | grep nginx

# 2. Check connections
netstat -an | grep :443 | wc -l

# 3. Reduce worker processes
worker_processes 1;  # Temporarily

# 4. Disable aggressive features
gzip off;
proxy_buffering off;

# 5. Reload with lighter config
nginx -s reload

# 6. After resolving, restore normal config
nginx -s reload
```

### Emergency: Security Breach

```bash
# 1. Block all traffic except internal
iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 443 -j DROP
iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 80 -j ACCEPT

# 2. Disable all remote access
# Comment out all server_name directives
# Add: default_type text/plain; return 403;

# 3. Check logs for intrusion
grep -E "POST|DELETE|PUT" /var/log/nginx/access.log | tail -100

# 4. Rotate logs for forensic analysis
nginx -s reopen

# 5. After securing, restore configuration
nginx -t && nginx -s reload
```

## D.5 Diagnostic Checklists

### Before Calling for Help

- [ ] Checked Nginx is running: `ps aux | grep nginx`
- [ ] Tested configuration: `nginx -t`
- [ ] Checked error logs: `tail -50 /var/log/nginx/error.log`
- [ ] Checked access logs: `tail -50 /var/log/nginx/access.log`
- [ ] Verified upstream is running: `curl http://localhost:8000/health`
- [ ] Checked network connectivity: `ping backend`
- [ ] Verified SSL certificate: `openssl s_client -connect localhost:443`
- [ ] Tested with curl: `curl -v https://localhost/api/`
- [ ] Checked system resources: `top`, `df -h`

### Production Deployment Checklist

- [ ] Configuration tested: `nginx -t`
- [ ] SSL certificates valid: `openssl x509 -in cert.pem -enddate -noout`
- [ ] Security headers present: `curl -I https://localhost/ | grep -E "Strict-Transport|X-Content"`
- [ ] Rate limiting configured: `nginx -T | grep "limit_req"`
- [ ] Caching configured: `nginx -T | grep "proxy_cache"`
- [ ] Health checks working: `curl https://localhost/health`
- [ ] Logs configured: `ls -la /var/log/nginx/`
- [ ] Backup configuration exists: `cp nginx.conf nginx.conf.backup`
- [ ] Monitoring set up: `./monitor.sh`
- [ ] Documentation updated: `README.md`

## D.6 Common Error Messages

| Error Message | Meaning | Solution |
|---------------|---------|----------|
| `connect() failed (111: Connection refused)` | Upstream not running | Start upstream service |
| `connect() failed (113: No route to host)` | Network issue | Check network configuration |
| `upstream timed out (110: Connection timed out)` | Upstream slow/unresponsive | Increase timeouts or optimize app |
| `no live upstreams while connecting to upstream` | All upstreams failed | Check health of all instances |
| `ssl_certificate: no such file or directory` | Missing certificate | Check path and file permissions |
| `ssl: error:1408A0C1:SSL routines:ssl3_get_client_hello` | TLS version mismatch | Update TLS configuration |
| `client intended to send too large body` | Payload too large | Increase `client_max_body_size` |
| `too many redirects` | Redirect loop | Check proxy_set_header and X-Forwarded-* |

---

This runbook is your first line of defense when things go wrong. Keep it handy, update it with your own experiences, and remember: every failure is an opportunity to learn.
