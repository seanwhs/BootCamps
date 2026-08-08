# Primer 5: Nginx Troubleshooting Deep Dive

## The Target

This primer provides a comprehensive, deep-dive guide to troubleshooting Nginx in production. Understanding how to diagnose and resolve issues quickly is essential for maintaining high availability and performance.

## P5.1 The Troubleshooting Methodology

### The Diagnostic Framework

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                      TROUBLESHOOTING METHODOLOGY                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. IDENTIFY                                                                 │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ • What is the symptom? (error message, behavior, metrics)     │   │
│     │ • When did it start? (time, recent changes)                   │   │
│     │ • What is the scope? (all requests, specific endpoints)       │   │
│     │ • What is the impact? (users affected, business impact)       │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│                                    ▼                                       │
│  2. ISOLATE                                                                 │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ • Which layer is failing? (client, network, Nginx, upstream)   │   │
│     │ • Which component is affected? (specific server, location)     │   │
│     │ • Can you reproduce it? (test request, curl command)            │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│                                    ▼                                       │
│  3. INVESTIGATE                                                             │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ • Check logs (access, error, debug)                            │   │
│     │ • Check configuration (nginx -T)                               │   │
│     │ • Check system resources (CPU, memory, network)                │   │
│     │ • Check upstream services (health, logs)                       │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│                                    ▼                                       │
│  4. DIAGNOSE                                                                 │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ • What is the root cause? (configuration, code, resources)     │   │
│     │ • How did it happen? (sequence of events)                      │   │
│     │ • Why did it happen? (underlying issues)                       │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│                                    ▼                                       │
│  5. RESOLVE                                                                  │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ • What is the fix? (configuration change, restart, scaling)    │   │
│     │ • How to apply it? (rolling update, immediate fix)             │   │
│     │ • How to verify it works? (testing, monitoring)                │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│                                    ▼                                       │
│  6. PREVENT                                                                 │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ • How to prevent recurrence? (monitoring, automation)          │   │
│     │ • What to document? (runbook, lessons learned)                 │   │
│     │ • How to improve? (better logging, metrics, alerts)            │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Common Failure Layers

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FAILURE LAYERS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Layer 1: Client                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Symptoms: Timeouts, connection refused, invalid responses          │   │
│  │ Tools: Browser dev tools, curl, network monitoring                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│  Layer 2: Network                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Symptoms: Connection timeouts, DNS errors, packet loss             │   │
│  │ Tools: ping, traceroute, dig, netstat, tcpdump                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│  Layer 3: Nginx                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Symptoms: 502, 504, 499, configuration errors                      │   │
│  │ Tools: nginx -T, logs, stub_status, access/error logs              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│  Layer 4: Upstream                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Symptoms: 502, 504, slow responses, application errors             │   │
│  │ Tools: Application logs, health checks, direct access              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                       │
│  Layer 5: Infrastructure                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Symptoms: High memory, CPU, disk space, I/O waits                  │   │
│  │ Tools: top, free, df, iostat, vmstat, dmesg                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P5.2 Log Analysis

### Log Locations

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         LOG LOCATIONS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Standard Nginx Installation:                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ /var/log/nginx/access.log     # All client requests                 │   │
│  │ /var/log/nginx/error.log      # Errors and warnings                 │   │
│  │ /var/log/nginx/access.log.1   # Rotated logs                       │   │
│  │ /var/log/nginx/error.log.1    # Rotated error logs                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Docker/Container:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ docker logs nginx-proxy           # All container logs              │   │
│  │ docker logs -f nginx-proxy        # Follow logs                     │   │
│  │ docker logs --tail 100 nginx-proxy  # Last 100 lines               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Custom Locations (configuration dependent):                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ ./logs/access.log              # Mounted volume                     │   │
│  │ ./logs/error.log               # Mounted volume                     │   │
│  │ /var/log/nginx/api-access.log  # Separate API logs                  │   │
│  │ /var/log/nginx/static-access.log # Separate static logs             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Log Analysis Commands

```bash
# 1. View logs in real-time
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# 2. View last N lines
tail -100 /var/log/nginx/access.log
tail -100 /var/log/nginx/error.log

# 3. Search for errors
grep -i "error" /var/log/nginx/error.log
grep -E "5[0-9][0-9]" /var/log/nginx/access.log

# 4. Count occurrences
grep -c "502" /var/log/nginx/access.log
grep -c "error" /var/log/nginx/error.log

# 5. Filter by time
grep "2024-01-15" /var/log/nginx/access.log

# 6. Filter by IP
grep "192.168.1.100" /var/log/nginx/access.log

# 7. Analyze response times
tail -1000 /var/log/nginx/access.log | jq '.request_time' | sort -n

# 8. Analyze status codes
tail -1000 /var/log/nginx/access.log | jq '.status' | sort | uniq -c

# 9. Parse JSON logs
tail -f /var/log/nginx/access.log | jq '.'

# 10. Filter JSON logs
tail -f /var/log/nginx/access.log | jq 'select(.status == 502)'
```

### Structured Log Analysis

```bash
# 1. Request ID tracing
REQUEST_ID="abc123"
grep $REQUEST_ID /var/log/nginx/access.log | jq '.'
grep $REQUEST_ID /var/log/nginx/error.log

# 2. Top slow requests
tail -1000 /var/log/nginx/access.log | jq -s 'sort_by(.request_time) | reverse | .[0:10]'

# 3. Top error endpoints
tail -1000 /var/log/nginx/access.log | jq 'select(.status >= 500)' | jq -s 'group_by(.request_uri) | map({uri: .[0].request_uri, count: length}) | sort_by(.count) | reverse'

# 4. Cache hit ratio
tail -1000 /var/log/nginx/access.log | jq -r '.upstream_cache_status' | sort | uniq -c

# 5. Upstream performance
tail -1000 /var/log/nginx/access.log | jq -r '"\(.upstream_addr) \(.upstream_response_time)"' | sort

# 6. Geo distribution
tail -1000 /var/log/nginx/access.log | jq -r '.remote_addr' | sort | uniq -c | sort -nr | head -10
```

## P5.3 Configuration Debugging

### Testing Configuration

```bash
# 1. Test configuration syntax
nginx -t

# 2. Test with specific file
nginx -t -c /path/to/nginx.conf

# 3. Show full configuration
nginx -T

# 4. Show specific section
nginx -T | grep -A10 "upstream backend"

# 5. Validate includes
nginx -T | grep "include"

# 6. Check variable interpolation
nginx -T | grep "\$host"

# 7. Check for errors
nginx -t 2>&1 | grep error

# 8. Docker testing
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -T | grep "location"
```

### Common Configuration Errors

```nginx
# Error 1: Missing trailing slash in proxy_pass
# WRONG:
location /api/ {
    proxy_pass http://backend;  # Missing trailing slash
}
# This sends /api/users to /api/users (may 404)

# RIGHT:
location /api/ {
    proxy_pass http://backend/;  # With trailing slash
}
# This sends /api/users to /users

# Error 2: Incorrect server_name
# WRONG:
server {
    server_name example.com;  # Missing www
}

# RIGHT:
server {
    server_name example.com www.example.com;
}

# Error 3: Missing proxy headers
# WRONG:
location /api/ {
    proxy_pass http://backend/;
    # Missing X-Forwarded headers
}

# RIGHT:
location /api/ {
    proxy_pass http://backend/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# Error 4: Invalid upstream syntax
# WRONG:
upstream backend {
    server backend1:8000;  # No failover
}

# RIGHT:
upstream backend {
    server backend1:8000 max_fails=3 fail_timeout=30s;
    server backend2:8000 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

# Error 5: Incorrect location priority
# WRONG:
location /api/ {
    # This catches everything including /api/v1/
}
location /api/v1/ {
    # Never reached
}

# RIGHT:
location ^~ /api/v1/ {
    # Higher priority
}
location /api/ {
    # Lower priority
}
```

## P5.4 Performance Troubleshooting

### CPU Issues

```bash
# 1. Check CPU usage
top -p $(pgrep nginx | tr '\n' ',' | sed 's/,$//')

# 2. Check worker CPU
ps aux | grep nginx | grep worker

# 3. Check CPU utilization over time
pidstat -u -p $(pgrep nginx | head -1) 5

# 4. Profile CPU usage
perf top -p $(pgrep nginx | head -1)

# 5. Check for CPU spikes
htop

# 6. Check system load
uptime
```

**Common CPU Issues and Fixes**

```nginx
# Issue: High CPU from compression
# Fix: Reduce compression level
gzip_comp_level 3;  # Down from 6

# Issue: High CPU from SSL
# Fix: Enable session cache
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1h;

# Issue: High CPU from logging
# Fix: Buffer logs
access_log /var/log/nginx/access.log json buffer=32k flush=5s;

# Issue: High CPU from too many workers
# Fix: Reduce worker processes
worker_processes auto;  # Or fixed number
```

### Memory Issues

```bash
# 1. Check memory usage
free -h
ps aux | grep nginx | awk '{sum+=$6} END {print sum/1024 " MB"}'

# 2. Check per-worker memory
ps aux | grep nginx | grep worker | awk '{print $6/1024 " MB"}'

# 3. Check memory over time
vmstat 5

# 4. Check for memory leaks
valgrind --leak-check=full nginx -t

# 5. Check memory limits
ulimit -a
```

**Common Memory Issues and Fixes**

```nginx
# Issue: Too much memory from buffers
# Fix: Reduce buffer sizes
client_body_buffer_size 128k;  # Down from 256k
proxy_buffers 4 4k;  # Down from 8 8k

# Issue: Too much memory from cache
# Fix: Reduce cache size
proxy_cache_path /var/cache/nginx/cache
    keys_zone=my_cache:50m  # Down from 100m
    max_size=500m;  # Down from 1g

# Issue: Too many connections
# Fix: Reduce worker connections
events {
    worker_connections 2048;  # Down from 10240
}

# Issue: Memory leak
# Fix: Restart workers gracefully
nginx -s reload
```

## P5.5 Network Troubleshooting

### Connection Issues

```bash
# 1. Check listening ports
netstat -tulpn | grep nginx
ss -lntp | grep nginx

# 2. Check active connections
netstat -an | grep :443 | grep ESTABLISHED | wc -l
ss -an | grep :443 | grep ESTAB | wc -l

# 3. Check connection states
netstat -an | grep :443 | awk '{print $6}' | sort | uniq -c

# 4. Check connection rate
watch -n1 "netstat -an | grep :443 | grep ESTAB | wc -l"

# 5. Test connectivity
ping backend
telnet backend 8000
curl -v http://backend:8000/health

# 6. Check DNS
dig backend
nslookup backend

# 7. Check network interface
ifconfig
ip addr show
```

### Connection Error Types

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CONNECTION ERROR TYPES                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Connection Refused                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Error: connect() failed (111: Connection refused)                  │   │
│  │ Cause: Upstream not running, wrong port, firewall                  │   │
│  │ Fix: Check upstream service, verify port, check iptables           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Connection Timeout                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Error: upstream timed out (110: Connection timed out)              │   │
│  │ Cause: Network issues, firewall, overloaded upstream               │   │
│  │ Fix: Check network, increase timeouts, scale upstream              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Connection Reset                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Error: recv() failed (104: Connection reset by peer)               │   │
│  │ Cause: Upstream crashed, network reset, timeout                    │   │
│  │ Fix: Check upstream stability, increase timeouts                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Broken Pipe                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Error: write() failed (32: Broken pipe)                            │   │
│  │ Cause: Client disconnected, upstream closed connection              │   │
│  │ Fix: Check client behavior, increase timeouts                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P5.6 Upstream Troubleshooting

### Upstream Health Checks

```bash
# 1. Check upstream directly
curl -v http://backend:8000/health

# 2. Check upstream with specific headers
curl -v -H "Host: backend" http://backend:8000/health

# 3. Check upstream response time
time curl -s http://backend:8000/health

# 4. Check upstream logs
docker logs backend --tail 50

# 5. Check upstream processes
docker exec backend ps aux

# 6. Check upstream resources
docker stats backend

# 7. Check upstream network
docker exec backend netstat -an
```

### Upstream Error Patterns

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    UPSTREAM ERROR PATTERNS                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Error: 502 Bad Gateway                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • Cause: Upstream not running or unreachable                       │   │
│  │ • Solution: Start upstream, check connectivity                     │   │
│  │ • Prevention: Health checks, monitoring                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Error: 504 Gateway Timeout                                                 │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • Cause: Upstream too slow, timeout too short                      │   │
│  │ • Solution: Increase timeouts, optimize upstream                   │   │
│  │ • Prevention: Caching, load balancing                              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Error: 503 Service Unavailable                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ • Cause: No healthy upstream servers                               │   │
│  │ • Solution: Check all upstream instances                           │   │
│  │ • Prevention: Health checks, backup servers                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P5.7 Advanced Debugging Tools

### Debug Configuration

```nginx
# nginx.conf - Debug configuration
error_log /var/log/nginx/debug.log debug;

# Specific debug levels
error_log /var/log/nginx/core.log debug_core;
error_log /var/log/nginx/proxy.log debug_proxy;

# Debug headers
location /debug/ {
    # Show request information
    return 200 "Request Information:
        Method: $request_method
        URI: $request_uri
        Host: $http_host
        Remote: $remote_addr
        X-Forwarded-For: $http_x_forwarded_for
        Request ID: $request_id
        Response Time: $request_time
    ";
}

# Debug headers
location /debug/headers {
    add_header X-Debug-Request-ID $request_id;
    add_header X-Debug-Upstream $upstream_addr;
    add_header X-Debug-Cache $upstream_cache_status;
    add_header X-Debug-Time $request_time;
    
    proxy_pass http://backend/debug/headers;
}
```

### Debugging Tools

```bash
# 1. TCP Dump
tcpdump -i any -s 0 -A 'tcp port 80' -v
tcpdump -i any -s 0 -A 'tcp port 443' -v

# 2. Wireshark (for detailed analysis)
# tshark -i any -f "tcp port 80" -Y "http.request"

# 3. strace
strace -p $(pgrep nginx | head -1) -e trace=network

# 4. openssl debug
openssl s_client -connect localhost:443 -debug -trace

# 5. curl debug
curl -v https://localhost/api/
curl --trace-ascii - https://localhost/api/

# 6. nginx debug
# Compile with debug: ./configure --with-debug
# Enable debug: error_log /var/log/nginx/debug.log debug;
```

## P5.8 Troubleshooting Runbook

### Incident Response Template

```text
INCIDENT RESPONSE RUNBOOK
========================

1. INITIAL RESPONSE
   - What: [Description of incident]
   - When: [Time started]
   - Impact: [Users affected, business impact]
   
2. INVESTIGATION
   - Symptoms:
   - Recent changes:
   - Error messages:
   - Logs:
   - Metrics:

3. DIAGNOSIS
   - Root cause:
   - Contributing factors:
   - Evidence:

4. RESOLUTION
   - Actions taken:
   - Verification:
   - Rollback plan:

5. PREVENTION
   - Monitoring:
   - Alerts:
   - Automation:
   - Documentation:

6. FOLLOW-UP
   - Lessons learned:
   - Action items:
   - Owner:
   - Date:
```

### Common Issues Quick Reference

| Symptom | Likely Cause | First Check | Quick Fix |
|---------|--------------|-------------|-----------|
| 502 | Upstream down | `curl upstream/health` | Restart upstream |
| 504 | Timeout | `proxy_read_timeout` | Increase timeout |
| 499 | Client disconnect | Client network | Check client |
| 500 | App error | App logs | Fix app |
| 429 | Rate limit | Rate config | Increase limits |
| Slow | Performance | Response times | Enable caching |
| SSL error | Cert issue | `openssl s_client` | Renew cert |
| No response | Nginx down | `ps aux | grep nginx` | Start nginx |

---

This primer provides a comprehensive deep dive into troubleshooting Nginx in production. Use these techniques to quickly diagnose and resolve issues, minimizing downtime and impact on users.
