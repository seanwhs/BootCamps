# Primer 4: Nginx Security Deep Dive

## The Target

This primer provides a comprehensive, deep-dive explanation of Nginx security. Understanding these concepts is essential for protecting your applications from common attacks and vulnerabilities.

## P4.1 Security Fundamentals

### The Security Model

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                         NGINX SECURITY MODEL                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                           ┌─────────────────┐                              │
│                           │   Client Layer  │                              │
│                           │   (Browser,     │                              │
│                           │    API Client)  │                              │
│                           └────────┬────────┘                              │
│                                    │                                       │
│                                    ▼                                       │
│                           ┌─────────────────┐                              │
│                           │   TLS Layer     │                              │
│                           │   (Encryption,  │                              │
│                           │    Authentication)│                            │
│                           └────────┬────────┘                              │
│                                    │                                       │
│                                    ▼                                       │
│                           ┌─────────────────┐                              │
│                           │   Security      │                              │
│                           │   Headers       │                              │
│                           │   (HSTS, CSP,   │                              │
│                           │    X-Frame)     │                              │
│                           └────────┬────────┘                              │
│                                    │                                       │
│                                    ▼                                       │
│                           ┌─────────────────┐                              │
│                           │   Request       │                              │
│                           │   Validation    │                              │
│                           │   (Rate Limit,  │                              │
│                           │    Access Ctrl) │                              │
│                           └────────┬────────┘                              │
│                                    │                                       │
│                                    ▼                                       │
│                           ┌─────────────────┐                              │
│                           │   Proxy Layer   │                              │
│                           │   (Headers,     │                              │
│                           │    Filters)     │                              │
│                           └────────┬────────┘                              │
│                                    │                                       │
│                                    ▼                                       │
│                           ┌─────────────────┐                              │
│                           │   Application   │                              │
│                           │   Layer         │                              │
│                           └─────────────────┘                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Security Principles

| Principle | Description | Nginx Implementation |
|-----------|-------------|---------------------|
| **Defense in Depth** | Multiple layers of security | TLS + Headers + Rate Limiting + Validation |
| **Least Privilege** | Minimal access required | IP restrictions, allow/deny |
| **Secure by Default** | Secure configuration out of the box | Hardened defaults, server_tokens off |
| **Fail Secure** | Fail closed, not open | Timeouts, error handling |
| **Audit Trail** | Log everything | Structured logging, request IDs |

## P4.2 TLS/SSL Security

### TLS Configuration Hardening

```nginx
# nginx.conf - Hardened TLS configuration
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Certificate paths
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # Modern TLS versions (disable old, insecure versions)
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Secure cipher suites
    # - Only AEAD ciphers (authenticated encryption)
    # - No RC4, no 3DES, no AES-CBC
    # - Perfect Forward Secrecy (ECDHE, DHE)
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    
    # Let client choose (better compatibility)
    ssl_prefer_server_ciphers off;
    
    # Session cache for performance
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;
    
    # OCSP stapling for certificate validation
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;
    
    # DH parameters for Perfect Forward Secrecy
    # Generate with: openssl dhparam -out dhparam.pem 2048
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;
    
    # Disable SSL compression (CRIME attack)
    ssl_compression off;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
}
```

### Testing TLS Security

```bash
# 1. Test SSL/TLS configuration
openssl s_client -connect example.com:443 -tls1_2 -cipher 'ECDHE-RSA-AES128-GCM-SHA256'

# 2. Check certificate details
openssl x509 -in cert.pem -text -noout

# 3. Check certificate expiration
openssl x509 -in cert.pem -enddate -noout

# 4. Comprehensive SSL scan
testssl.sh https://example.com

# 5. Check supported ciphers
nmap --script ssl-enum-ciphers -p 443 example.com

# 6. Test for vulnerabilities
# - POODLE: https://example.com with SSLv3
# - Heartbleed: OpenSSL version check
# - CRIME: SSL compression check
```

## P4.3 Security Headers

### Complete Security Headers Implementation

```nginx
# nginx.conf - Complete security headers
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # 1. HSTS - Enforce HTTPS for 2 years
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # 2. CSP - Prevent XSS and injection
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
        block-all-mixed-content;
    " always;
    
    # 3. Prevent MIME type sniffing
    add_header X-Content-Type-Options "nosniff" always;
    
    # 4. Prevent clickjacking
    add_header X-Frame-Options "DENY" always;
    
    # 5. Enable XSS protection
    add_header X-XSS-Protection "1; mode=block" always;
    
    # 6. Control referrer information
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # 7. Restrict browser features
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
    
    # 8. Cross-origin protection
    add_header Cross-Origin-Resource-Policy "same-origin" always;
    add_header Cross-Origin-Opener-Policy "same-origin" always;
    add_header Cross-Origin-Embedder-Policy "require-corp" always;
    
    # 9. Hide server information
    server_tokens off;
}
```

### Security Headers Testing

```bash
# 1. Check all security headers
curl -I https://example.com | grep -E "Strict-Transport|Content-Security|X-Content|X-Frame|X-XSS|Referrer|Permissions"

# 2. Test CSP with reporting
curl -H "Content-Security-Policy-Report-Only: default-src 'self';" https://example.com

# 3. Validate HSTS
curl -I https://example.com | grep "Strict-Transport-Security"

# 4. Check for XSS protection
curl -I https://example.com | grep "X-XSS-Protection"

# 5. Security headers scanner
securityheaders.com scan https://example.com
```

## P4.4 Request Validation

### Input Validation

```nginx
# nginx.conf - Request validation
server {
    location /api/ {
        # 1. Method validation
        if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
            return 405;
        }
        
        # 2. Content-Type validation for POST/PUT
        if ($request_method = POST) {
            if ($content_type !~ "application/json") {
                return 415 "{\"error\":\"Unsupported media type\"}";
            }
        }
        
        # 3. Query parameter validation
        if ($query_string ~* "(union|select|insert|update|delete|drop|exec|eval)") {
            return 403;
        }
        
        # 4. Path traversal prevention
        if ($request_uri ~* "\.\./") {
            return 403;
        }
        
        # 5. Null byte prevention
        if ($request_uri ~* "\x00") {
            return 400;
        }
        
        # 6. Length validation
        if ($request_uri ~* "^(?:[^&]*&){50,}") {
            return 413;
        }
        
        # 7. User agent validation
        if ($http_user_agent ~* "(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan)") {
            return 403;
        }
        
        proxy_pass http://backend/;
    }
}
```

### SQL Injection Protection

```nginx
# SQL Injection prevention
location /api/ {
    # Block common SQL injection patterns
    if ($query_string ~* "(\%27)|(\')|(\-\-)|(\%23)|(#)") {
        return 403;
    }
    
    if ($query_string ~* "(\%22)|(\")") {
        return 403;
    }
    
    if ($query_string ~* "\b(union|select|insert|update|delete|drop|exec|eval|alter|create|table)\b") {
        return 403;
    }
    
    # Block SQL comments
    if ($query_string ~* "/\*.*\*/") {
        return 403;
    }
    
    # Block OR/AND attempts
    if ($query_string ~* "\b(OR|AND)\s+.*=") {
        return 403;
    }
    
    proxy_pass http://backend/;
}
```

### XSS Protection

```nginx
# XSS prevention
location /api/ {
    # Block script injection attempts
    if ($query_string ~* "<script.*>") {
        return 403;
    }
    
    if ($query_string ~* "javascript:") {
        return 403;
    }
    
    if ($query_string ~* "onerror\s*=") {
        return 403;
    }
    
    if ($query_string ~* "onload\s*=") {
        return 403;
    }
    
    if ($query_string ~* "alert\(") {
        return 403;
    }
    
    # Block encoded XSS
    if ($query_string ~* "%3C%53%43%52%49%50%54") {
        return 403;
    }
    
    proxy_pass http://backend/;
}
```

## P4.5 Rate Limiting and DDoS Protection

### Comprehensive Rate Limiting

```nginx
# nginx.conf - Complete rate limiting
http {
    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=admin:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=public:10m rate=300r/m;
    
    # Connection limiting
    limit_conn_zone $binary_remote_addr zone=conn:10m;
    
    # Bandwidth limiting
    limit_rate_zone $binary_remote_addr zone=rate:10m rate=1m;
    
    server {
        # 1. Global rate limiting
        limit_req zone=global burst=20 nodelay;
        limit_conn conn 10;
        
        # 2. Authentication (strict)
        location /auth/login {
            limit_req zone=auth burst=2 nodelay;
            limit_conn conn 1;
            proxy_pass http://auth/login;
        }
        
        # 3. API (moderate)
        location /api/ {
            limit_req zone=api burst=10 nodelay;
            proxy_pass http://api/;
        }
        
        # 4. Admin (very strict)
        location /admin/ {
            limit_req zone=admin burst=2 nodelay;
            limit_conn conn 1;
            proxy_pass http://admin/;
        }
        
        # 5. Public (permissive)
        location /public/ {
            limit_req zone=public burst=30 nodelay;
            proxy_pass http://public/;
        }
        
        # Custom error pages for rate limiting
        error_page 429 @rate_limited;
        location @rate_limited {
            return 429 "{\"error\":\"Rate limit exceeded. Try again later.\"}";
        }
    }
}
```

### DDoS Protection

```nginx
# nginx.conf - DDoS protection
http {
    # Client timeouts
    client_body_timeout 10s;
    client_header_timeout 10s;
    send_timeout 10s;
    
    # Client buffer limits
    client_body_buffer_size 128k;
    client_max_body_size 1M;
    
    # Request limiting
    limit_req_zone $binary_remote_addr zone=ddos:10m rate=30r/s;
    
    # Connection limiting per IP
    limit_conn_zone $binary_remote_addr zone=ddos_conn:10m;
    
    server {
        # DDoS protection with burst and delay
        limit_req zone=ddos burst=50 delay=10;
        limit_conn ddos_conn 20;
        
        location / {
            # Slowloris protection
            client_body_timeout 5s;
            client_header_timeout 5s;
            
            # Close connections quickly
            keepalive_timeout 10s;
            
            proxy_pass http://backend/;
        }
        
        # Custom DDoS blocking
        location /ddos-block {
            # Redirect to block page
            return 429 "Too many requests";
        }
    }
}
```

### Whitelisting and Blacklisting

```nginx
# nginx.conf - IP whitelisting/blacklisting
http {
    # Whitelist internal IPs
    geo $internal {
        default 0;
        10.0.0.0/8 1;
        172.16.0.0/12 1;
        192.168.0.0/16 1;
        127.0.0.1 1;
    }
    
    # Blacklist known bad IPs
    geo $blacklist {
        default 0;
        1.2.3.4 1;  # Known attacker
        5.6.7.8 1;  # Known attacker
        include /etc/nginx/blacklist.conf;
    }
    
    server {
        location /admin/ {
            # Only allow internal
            if ($internal = 0) {
                return 403;
            }
            
            # Block blacklisted IPs
            if ($blacklist = 1) {
                return 403;
            }
            
            proxy_pass http://admin/;
        }
        
        location /api/ {
            # Block blacklisted IPs
            if ($blacklist = 1) {
                return 403;
            }
            
            proxy_pass http://api/;
        }
    }
}
```

## P4.6 Authentication and Authorization

### Basic Authentication

```nginx
# nginx.conf - Basic authentication
location /admin/ {
    # Enable basic authentication
    auth_basic "Admin Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    # Restrict IPs
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    allow 192.168.0.0/16;
    deny all;
    
    proxy_pass http://admin/;
}
```

### JWT Authentication

```nginx
# nginx.conf - JWT authentication (requires auth_jwt module)
location /api/ {
    # JWT authentication
    auth_jwt "API Access" token=$http_authorization;
    auth_jwt_key_file /etc/nginx/jwt.pem;
    auth_jwt_issuer example.com;
    
    # Validate audience
    auth_jwt_audience api.example.com;
    
    # Extract user from JWT
    auth_jwt_claim_set $user_id sub;
    
    # Forward user ID
    proxy_set_header X-User-ID $user_id;
    
    proxy_pass http://api/;
}
```

### OAuth2 Proxy

```nginx
# nginx.conf - OAuth2 Proxy integration
location /oauth2/ {
    proxy_pass http://oauth2-proxy:4180/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    proxy_set_header Authorization "";
    proxy_set_header Cookie "";
}

location /api/ {
    # OAuth2 authentication
    auth_request /oauth2/auth;
    error_page 401 = /oauth2/start;
    
    # Extract user info
    auth_request_set $user $upstream_http_x_forwarded_user;
    auth_request_set $email $upstream_http_x_forwarded_email;
    
    # Forward user info
    proxy_set_header X-User $user;
    proxy_set_header X-Email $email;
    
    proxy_pass http://api/;
}
```

## P4.7 Logging and Monitoring

### Security Logging

```nginx
# nginx.conf - Security logging
http {
    # Security log format
    log_format security '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for" '
                        '"$http_authorization" "$cookie_sessionid" '
                        '"$upstream_addr" "$upstream_status" '
                        '"$request_time" "$upstream_response_time"';
    
    # Security log
    access_log /var/log/nginx/security.log security;
    
    # Include security events
    log_format json_security escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request_id":"$request_id",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"user_agent":"$http_user_agent",'
        '"auth_header":"$http_authorization",'
        '"cookie":"$http_cookie",'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_status":$upstream_status'
    '}';
    
    access_log /var/log/nginx/security.json json_security;
}
```

### Security Monitoring Script

**File: `security-monitor.sh`**

```bash
#!/bin/bash
# security-monitor.sh - Security monitoring

echo "=== Security Monitoring Report ==="
echo "Timestamp: $(date)"
echo ""

# 1. Failed authentication attempts
echo "1. Failed Authentication Attempts (last 5 min):"
grep "401" /var/log/nginx/access.log | tail -20
echo "Total: $(grep -c "401" /var/log/nginx/access.log)"
echo ""

# 2. Rate limiting hits
echo "2. Rate Limiting Hits (last 5 min):"
grep "429" /var/log/nginx/access.log | tail -20
echo "Total: $(grep -c "429" /var/log/nginx/access.log)"
echo ""

# 3. Suspicious requests
echo "3. Suspicious Requests (last 5 min):"
grep -E "union|select|insert|update|delete|drop|exec|eval|<script>|../../../" \
    /var/log/nginx/access.log | tail -20
echo "Total: $(grep -c -E "union|select|insert|update|delete|drop|exec|eval|<script>|../../../" \
    /var/log/nginx/access.log)"
echo ""

# 4. Error responses
echo "4. Error Responses (last 5 min):"
grep -E "5[0-9][0-9]" /var/log/nginx/access.log | tail -20
echo "Total: $(grep -c -E "5[0-9][0-9]" /var/log/nginx/access.log)"
echo ""

# 5. Blocked IPs
echo "5. Blocked IPs (last 5 min):"
grep "403" /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -10

# 6. SSL/TLS issues
echo ""
echo "6. SSL/TLS Issues (last 5 min):"
grep -i "ssl\|tls" /var/log/nginx/error.log | tail -10

# 7. Active connections
echo ""
echo "7. Active Connections:"
curl -s http://localhost/nginx-status 2>/dev/null | grep "Active connections"

echo ""
echo "=== Security Monitoring Complete ==="
```

## P4.8 Security Best Practices

### Security Checklist

- [ ] **TLS Configuration**
  - [ ] TLS 1.2/1.3 only
  - [ ] Strong ciphers (AEAD only)
  - [ ] HSTS enabled
  - [ ] OCSP stapling enabled
  - [ ] DH parameters generated

- [ ] **Security Headers**
  - [ ] HSTS header present
  - [ ] CSP header configured
  - [ ] X-Content-Type-Options: nosniff
  - [ ] X-Frame-Options: DENY
  - [ ] X-XSS-Protection: 1; mode=block
  - [ ] Referrer-Policy configured

- [ ] **Rate Limiting**
  - [ ] Global rate limiting
  - [ ] Specific limits per endpoint
  - [ ] Connection limiting
  - [ ] Burst capacity configured

- [ ] **Request Validation**
  - [ ] Method validation
  - [ ] Content-Type validation
  - [ ] SQL injection protection
  - [ ] XSS protection
  - [ ] Path traversal protection

- [ ] **Access Control**
  - [ ] Admin endpoints restricted
  - [ ] Debug endpoints restricted
  - [ ] IP whitelisting implemented
  - [ ] Authentication enforced

- [ ] **Logging**
  - [ ] Structured logging enabled
  - [ ] Security events logged
  - [ ] Request IDs generated
  - [ ] Log rotation configured

- [ ] **Best Practices**
  - [ ] Server tokens off
  - [ ] Regular updates
  - [ ] Minimal modules loaded
  - [ ] Non-root user
  - [ ] Regular security audits

---

This primer provides a deep understanding of Nginx security. Use these techniques to protect your applications from common attacks and vulnerabilities.
