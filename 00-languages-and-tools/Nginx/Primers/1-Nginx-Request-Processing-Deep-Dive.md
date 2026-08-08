# Primer 1: Nginx Request Processing Deep Dive

## The Target

This primer provides a comprehensive, deep-dive explanation of how Nginx processes HTTP requests from the moment they arrive until the response is sent. Understanding this flow is essential for debugging, performance tuning, and advanced configuration.

## P1.1 The Nginx Architecture

### Process Model

```text
┌─────────────────────────────────────────────────────────────────┐
│                         MASTER PROCESS                         │
│  ┌────────────────────────────────────────────────────────┐   │
│  │ • Reads and validates configuration                    │   │
│  │ • Manages worker processes (start/stop/reload)        │   │
│  │ • Handles signals (SIGTERM, SIGHUP, SIGUSR1)          │   │
│  │ • Binds to ports (listening sockets)                  │   │
│  └────────────────────────────────────────────────────────┘   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  WORKER 1     │   │  WORKER 2     │   │  WORKER N     │
│               │   │               │   │               │
│ • Accepts     │   │ • Accepts     │   │ • Accepts     │
│   connections │   │   connections │   │   connections │
│ • Reads       │   │ • Reads       │   │ • Reads       │
│   requests    │   │   requests    │   │   requests    │
│ • Processes   │   │ • Processes   │   │ • Processes   │
│   requests    │   │   requests    │   │   requests    │
│ • Generates   │   │ • Generates   │   │ • Generates   │
│   responses   │   │   responses   │   │   responses   │
│ • Writes logs │   │ • Writes logs │   │ • Writes logs │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Why This Architecture?

- **Master Process**: Single-threaded, handles configuration and lifecycle
- **Worker Processes**: Multi-threaded, handle actual client connections
- **Benefits**:
  - **Reliability**: Worker crashes don't affect other workers or the master
  - **Scalability**: Workers run on separate CPU cores
  - **Performance**: Non-blocking, event-driven architecture

## P1.2 The 11-Phase Request Lifecycle

### Phase 1: Connection Establishment

**What happens:**
1. Client initiates TCP connection to Nginx port (80 or 443)
2. Operating system completes TCP handshake (SYN, SYN-ACK, ACK)
3. Nginx accepts the connection

**Nginx internals:**
```nginx
# Nginx configuration that affects this phase
events {
    worker_connections 1024;    # Max connections per worker
    multi_accept on;            # Accept multiple connections at once
    accept_mutex off;           # Disable accept mutex (better with epoll)
}
```

```text
Client → TCP SYN → Nginx
Nginx  → TCP SYN-ACK → Client
Client → TCP ACK → Nginx
[Connection Established]
```

**Key variables available:**
- `$remote_addr`: Client IP address
- `$remote_port`: Client source port
- `$connection`: Connection identifier
- `$connection_requests`: Number of requests on this connection

### Phase 2: SSL/TLS Handshake (HTTPS Only)

**What happens (if HTTPS):**
1. Nginx presents SSL certificate to client
2. Client verifies certificate
3. Both parties negotiate encryption parameters
4. Secure channel established

**Nginx internals:**
```nginx
# SSL configuration affecting this phase
server {
    listen 443 ssl http2;
    
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:...';
    ssl_session_cache shared:SSL:10m;  # Reuse sessions
    ssl_session_timeout 1h;
}
```

```text
Client → ClientHello → Nginx
Nginx  → ServerHello, Certificate, ServerHelloDone → Client
Client → ClientKeyExchange, ChangeCipherSpec, Finished → Nginx
Nginx  → ChangeCipherSpec, Finished → Client
[Secure Channel Established]
```

**Key variables available after SSL:**
- `$ssl_protocol`: TLS version (e.g., `TLSv1.3`)
- `$ssl_cipher`: Cipher suite used
- `$ssl_session_id`: Session identifier

### Phase 3: Request Reading

**What happens:**
1. Nginx reads HTTP request line (method, URI, protocol)
2. Reads headers
3. Parses and validates the request

**Nginx internals:**
```nginx
# Settings affecting request reading
http {
    client_header_timeout 60s;      # Time to read headers
    client_body_timeout 60s;        # Time to read body
    client_max_body_size 10M;       # Maximum body size
    client_header_buffer_size 1k;   # Buffer for headers
    large_client_header_buffers 4 8k;  # Buffers for large headers
}
```

```text
HTTP Request Example:
GET /api/users?page=1 HTTP/1.1
Host: example.com
User-Agent: Mozilla/5.0
Accept: application/json
Authorization: Bearer token123
Cookie: session=abc123

[Request Line]   → method, URI, protocol
[Headers]        → key: value pairs
[Body]           → optional POST/PUT data
```

**Key variables populated:**
- `$request_method`: HTTP method (GET, POST, etc.)
- `$request_uri`: Full URI including query string
- `$uri`: URI without query string
- `$args`: Query string parameters
- `$http_*`: All HTTP headers (e.g., `$http_user_agent`)

### Phase 4: Server Selection (Virtual Host Selection)

**What happens:**
1. Nginx matches the `Host` header against `server_name` directives
2. If multiple matches, Nginx uses the most specific match

**Nginx internals:**
```nginx
# Server selection
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;  # Matches these domains
}

server {
    listen 443 ssl http2;
    server_name api.example.com;               # Matches api subdomain
}

server {
    listen 443 ssl http2;
    server_name _;                             # Default catch-all
}
```

**Matching priority:**
1. Exact match: `server_name example.com`
2. Wildcard match: `server_name *.example.com`
3. Regex match: `server_name ~^(www\.)?example\.com$`
4. Default server (first in file)

**Key variables at this stage:**
- `$host`: Host header value
- `$server_name`: Matched server name

### Phase 5: Location Selection

**What happens:**
1. Nginx matches the request URI against `location` blocks
2. Uses priority-based matching algorithm

**Nginx internals:**
```nginx
# Location matching priority
server {
    # 1. Exact match (highest priority)
    location = /exact {
        proxy_pass http://backend1;
    }
    
    # 2. Preferential prefix (highest before regex)
    location ^~ /static/ {
        root /var/www/static;
    }
    
    # 3. Case-sensitive regex
    location ~ \.php$ {
        proxy_pass http://php-backend;
    }
    
    # 4. Case-insensitive regex
    location ~* \.(jpg|png|gif)$ {
        expires 30d;
    }
    
    # 5. Prefix match (lowest priority)
    location /api/ {
        proxy_pass http://api-backend;
    }
    
    # 6. Catch-all (lowest priority)
    location / {
        proxy_pass http://default-backend;
    }
}
```

**Matching examples:**

| Request URI | Match | Why |
|------------|-------|-----|
| `/exact` | `location = /exact` | Exact match takes priority |
| `/static/css/style.css` | `location ^~ /static/` | Preferential prefix stops regex |
| `/api/users` | `location /api/` | Prefix match, no regex matches |
| `/admin/users` | `location /` | Catch-all (no other matches) |

### Phase 6: Request Validation and Filtering

**What happens:**
1. Nginx applies any `if` conditions
2. Rate limiting is checked
3. Authentication is verified (if configured)
4. Access restrictions are applied

**Nginx internals:**
```nginx
# Request validation
location /api/ {
    # Rate limiting
    limit_req zone=api_limit burst=10 nodelay;
    limit_conn conn_limit 10;
    
    # IP restrictions
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    deny all;
    
    # Authentication
    auth_request /auth/validate;
    auth_request_set $auth_user $upstream_http_x_user;
    
    # Request validation
    if ($request_method !~ ^(GET|POST|PUT|DELETE)$) {
        return 405;
    }
    
    if ($query_string ~* "union|select|exec") {
        return 403;
    }
}
```

### Phase 7: Handler Execution

**What happens:**
1. Nginx executes the appropriate handler for the location
2. Common handlers: `proxy_pass`, `try_files`, `return`, `rewrite`

**Nginx internals:**
```nginx
# Different handler types

# 1. Proxy handler
location /api/ {
    proxy_pass http://backend/;
}

# 2. Static file handler
location /static/ {
    root /var/www/html;
    try_files $uri $uri/ =404;
}

# 3. Return handler
location /health {
    access_log off;
    return 200 "healthy\n";
}

# 4. Rewrite handler
location /old/ {
    rewrite ^/old/(.*) /new/$1 permanent;
}

# 5. Internal redirect
location / {
    try_files $uri $uri/ @fallback;
}

location @fallback {
    proxy_pass http://backend;
}
```

### Phase 8: Proxy Processing (For proxy_pass)

**What happens:**
1. Nginx builds the upstream request
2. Applies header transformations
3. Selects an upstream server
4. Opens connection to upstream

**Nginx internals:**
```nginx
# Proxy processing
location /api/ {
    # Build upstream request
    proxy_pass http://backend/;
    
    # Transform headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Request-ID $request_id;
    
    # Apply transformations
    proxy_redirect off;
    proxy_cookie_path / /;
    
    # Upstream selection
    proxy_next_upstream error timeout http_502;
    proxy_next_upstream_tries 3;
}
```

**URI transformation with trailing slashes:**

| Client Request | Location | proxy_pass | Upstream Request |
|----------------|----------|------------|------------------|
| `/api/users` | `/api/` | `http://backend` | `/api/users` |
| `/api/users` | `/api/` | `http://backend/` | `/users` |
| `/api/users` | `/api/` | `http://backend/v1` | `/v1/api/users` |
| `/api/users` | `/api/` | `http://backend/v1/` | `/v1/users` |

### Phase 9: Response Generation

**What happens:**
1. Nginx receives response from upstream
2. Applies response transformations
3. Buffers response (if configured)
4. Adds response headers

**Nginx internals:**
```nginx
# Response handling
location /api/ {
    proxy_pass http://backend/;
    
    # Response buffering
    proxy_buffering on;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;
    
    # Cache response
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
    proxy_cache_use_stale error timeout updating;
    
    # Add response headers
    add_header X-Cache-Status $upstream_cache_status;
    add_header X-Response-Time $request_time;
    
    # Transform response
    proxy_redirect http:// https://;
}
```

### Phase 10: Response Transmission

**What happens:**
1. Nginx sends response to client
2. May use chunked encoding for streaming
3. Handles keep-alive connections

**Nginx internals:**
```nginx
# Response transmission settings
http {
    sendfile on;           # Efficient file transfer
    tcp_nopush on;         # Optimize packet sending
    tcp_nodelay on;        # Disable Nagle's algorithm
    
    keepalive_timeout 65;   # Keep connections alive
    keepalive_requests 100;  # Max requests per connection
    
    send_timeout 60s;       # Time to send response
}
```

### Phase 11: Logging

**What happens:**
1. Nginx records request details to access log
2. Records errors to error log
3. Records cache status, upstream details

**Nginx internals:**
```nginx
# Logging
http {
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
        '"upstream_response_time":$upstream_response_time"'
    '}';
    
    access_log /var/log/nginx/access.log json;
    error_log /var/log/nginx/error.log warn;
}
```

## P1.3 The Connection Lifecycle in Detail

### HTTP 1.0 Connections

```text
[Client] → [Connection Open] → [Request] → [Response] → [Connection Close] → [Client]
```

- One request per connection
- Connection closes after response

### HTTP 1.1 Keep-Alive

```text
[Client] → [Connection Open] → [Request 1] → [Response 1] → [Request 2] → [Response 2] → ... → [Connection Close] → [Client]
```

- Multiple requests per connection
- `keepalive_timeout` controls idle time
- `keepalive_requests` controls max requests

### HTTP/2 Multiplexing

```text
[Client] → [Connection Open] → [Stream 1: Request/Response]
                              → [Stream 2: Request/Response]
                              → [Stream 3: Request/Response] → [Connection Close] → [Client]
```

- Multiple concurrent streams
- Single connection
- Header compression (HPACK)
- Server push

## P1.4 Request Processing Flow Diagram

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                           REQUEST PROCESSING FLOW                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Client Request                                                             │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 1: Connection Establishment                           │           │
│  │ TCP Handshake → listener.accept()                          │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 2: SSL/TLS Handshake (HTTPS)                         │           │
│  │ Certificate → Key Exchange → Secure Channel                 │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 3: Request Reading                                    │           │
│  │ Method → URI → Headers → Body                              │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 4: Server Selection                                   │           │
│  │ Host header → server_name matching                         │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 5: Location Selection                                 │           │
│  │ URI → location matching (priority order)                   │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 6: Request Validation                                 │           │
│  │ Rate Limiting → Auth → Access Control → Validation         │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 7: Handler Execution                                  │           │
│  │ proxy_pass / try_files / return / rewrite                  │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 8: Proxy Processing (if proxy_pass)                  │           │
│  │ Build Request → Transform Headers → Connect → Forward      │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 9: Response Generation                                │           │
│  │ Receive → Transform → Cache → Buffering                    │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 10: Response Transmission                            │           │
│  │ Sendfile → TCP → Keep-Alive                                 │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │ Phase 11: Logging                                           │           │
│  │ Access Log → Error Log → Metrics                           │           │
│  └─────────────────────────────────────────────────────────────┘           │
│        │                                                                     │
│        ▼                                                                     │
│  Client Response                                                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P1.5 Event-Driven Architecture

### How Nginx Handles Connections

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EVENT-DRIVEN ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Worker Process 1                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Event Loop                                                           │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │ 1. epoll_wait() - Wait for events                             │ │   │
│  │  │                                                               │ │   │
│  │  │ 2. For each event:                                            │ │   │
│  │  │    ├── Read event?   → Read client data                       │ │   │
│  │  │    ├── Write event?  → Send response                          │ │   │
│  │  │    ├── Accept event? → Accept new connection                  │ │   │
│  │  │    └── Timer event?  → Handle timeout                         │ │   │
│  │  │                                                               │ │   │
│  │  │ 3. Process any completed tasks                                │ │   │
│  │  │                                                               │ │   │
│  │  │ 4. Repeat                                                     │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Event Types:                                                               │
│  • EPOLLIN:  Data available to read                                        │
│  • EPOLLOUT: Ready to write                                                │
│  • EPOLLERR: Error occurred                                                │
│  • EPOLLHUP: Connection hung up                                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Why Non-Blocking Matters

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    BLOCKING VS NON-BLOCKING I/O                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  BLOCKING (Apache)                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Thread 1: Accept → Read → Process → Send → Wait                   │   │
│  │ Thread 2: Accept → Read → Process → Send → Wait                   │   │
│  │ Thread 3: Accept → Read → Process → Send → Wait                   │   │
│  │ Thread N: ...                                                      │   │
│  │                                                                     │   │
│  │ Problem: Each connection needs a thread (memory/CPU overhead)      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  NON-BLOCKING (Nginx)                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Worker 1:                                                           │   │
│  │  Connection 1: Read  ┐                                              │   │
│  │  Connection 2:       ─┤ Process (non-blocking)                     │   │
│  │  Connection 3:     Send ┘                                          │   │
│  │                                                                     │   │
│  │  Connection 4: Wait for data (event)                               │   │
│  │  Connection 5: Process  ┐                                          │   │
│  │  Connection 6: Send     ─┤ All in single thread                   │   │
│  │  Connection 7: Read      ┘                                        │   │
│  │                                                                     │   │
│  │ Benefit: One thread handles thousands of connections                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P1.6 Memory and Buffer Management

### Memory Layout

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MEMORY MANAGEMENT                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Nginx Memory Pools                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ Connection Pool (per connection)                                     │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │ • Client headers (1k)                                        │ │   │
│  │  │ • Request line (4k)                                          │ │   │
│  │  │ • Client body (configurable)                                 │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  │                                                                     │   │
│  │  Shared Memory Zones                                                │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │ • SSL sessions (SSL:10m)                                     │ │   │
│  │  │ • Rate limiting (zone:10m)                                   │ │   │
│  │  │ • Cache (keys_zone:100m)                                     │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  │                                                                     │   │
│  │  Buffer Pools                                                       │   │
│  │  ┌───────────────────────────────────────────────────────────────┐ │   │
│  │  │ • Client body buffers (128k)                                  │ │   │
│  │  │ • Proxy buffers (8k × 8)                                      │ │   │
│  │  │ • Output buffers (32k × 32)                                   │ │   │
│  │  └───────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Buffer Lifecycle

```text
1. Request Arrives
   │
   ▼
2. Read into Client Header Buffer (client_header_buffer_size)
   │
   ▼
3. If headers > buffer → use Large Client Header Buffers
   │
   ▼
4. Read Body into Client Body Buffer (client_body_buffer_size)
   │
   ▼
5. If body > buffer → write to temporary file
   │
   ▼
6. Proxy to upstream → read into Proxy Buffer (proxy_buffer_size)
   │
   ▼
7. Buffer response → send to client (output_buffers)
```

## P1.7 Practical Debugging

### Debugging the Request Lifecycle

```nginx
# Enable debug logging
error_log /var/log/nginx/debug.log debug;

# Add trace headers
location /api/ {
    # Log request ID
    add_header X-Request-ID $request_id;
    
    # Log timing
    add_header X-Request-Time $request_time;
    add_header X-Upstream-Time $upstream_response_time;
    
    # Log cache status
    add_header X-Cache-Status $upstream_cache_status;
    
    # Log upstream
    add_header X-Upstream-Addr $upstream_addr;
    
    proxy_pass http://backend/;
}
```

### Tracing Tools

```bash
# 1. Trace full request
curl -v -H "X-Trace: true" https://localhost/api/

# 2. Check headers
curl -v -H "X-Debug: true" https://localhost/api/ 2>&1 | grep -E "X-|HTTP"

# 3. Log request ID
REQUEST_ID=$(uuidgen)
curl -H "X-Request-ID: $REQUEST_ID" https://localhost/api/
grep $REQUEST_ID /var/log/nginx/access.log

# 4. Watch live processing
tail -f /var/log/nginx/access.log | jq '.request_time, .status, .upstream_addr'
```

### Common Debug Points

| Phase | Debug Check | Command |
|-------|------------|---------|
| Connection | Is Nginx listening? | `netstat -tulpn | grep 80` |
| SSL | Certificate valid? | `openssl s_client -connect localhost:443` |
| Server Selection | Correct server block? | `nginx -T | grep -A10 "server_name"` |
| Location Selection | Correct location? | `nginx -T | grep -A10 "location"` |
| Proxy | Upstream reachable? | `curl http://backend:8000/health` |
| Headers | Headers forwarded? | `curl -v https://localhost/debug/headers` |
| Caching | Cache working? | `grep -c "HIT" access.log` |
| Logging | Logs being written? | `tail -f /var/log/nginx/access.log` |

---

This primer provides the foundation for understanding everything Nginx does with every request. Master this, and you'll be able to debug any issue and optimize any configuration.
