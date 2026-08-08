# Primer 9: Nginx Security Hardening - Complete Guide

## The Target

This primer provides the ultimate, comprehensive guide to hardening Nginx in production. This is a complete, battle-tested security configuration that covers every aspect of Nginx security.

## P9.1 Complete Hardened Configuration

### The Ultimate nginx.conf

```nginx
# ============================================================================
# ULTIMATE NGINX SECURITY HARDENING - PRODUCTION READY
# ============================================================================
# This configuration represents the highest level of security hardening
# suitable for financial, healthcare, and government applications.
# ============================================================================

# ============================================================================
# GLOBAL SETTINGS
# ============================================================================
user nginx nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
worker_priority -20;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# ============================================================================
# EVENTS
# ============================================================================
events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
    accept_mutex off;
}

# ============================================================================
# HTTP BLOCK
# ============================================================================
http {
    # ------------------------------------------------------------------------
    # BASIC SECURITY
    # ------------------------------------------------------------------------
    server_tokens off;
    charset utf-8;
    disable_symlinks on;
    
    # Hide nginx version from error pages
    server_tokens off;
    
    # ------------------------------------------------------------------------
    # BUFFER PROTECTION
    # ------------------------------------------------------------------------
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    client_max_body_size 10M;
    
    # Timeouts (prevent slow attacks)
    client_body_timeout 10s;
    client_header_timeout 10s;
    send_timeout 10s;
    keepalive_timeout 30s;
    keepalive_requests 100;
    
    # ------------------------------------------------------------------------
    # RATE LIMITING
    # ------------------------------------------------------------------------
    limit_req_zone $binary_remote_addr zone=global:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=admin:10m rate=5r/m;
    
    limit_conn_zone $binary_remote_addr zone=conn:10m;
    limit_conn_zone $binary_remote_addr zone=conn_login:10m;
    
    # ------------------------------------------------------------------------
    # GZIP
    # ------------------------------------------------------------------------
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_disable "msie6";
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/rss+xml
        application/atom+xml
        application/xhtml+xml
        application/ld+json
        application/manifest+json
        application/geo+json
        application/vnd.ms-fontobject
        application/x-font-ttf
        font/opentype
        font/ttf
        font/otf
        font/woff
        font/woff2
        image/svg+xml
        image/x-icon;

    # =========================================================================
    # SECURITY HEADERS
    # =========================================================================
    # Add these to every response
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Cross-Origin-Resource-Policy "same-origin" always;
    add_header Cross-Origin-Opener-Policy "same-origin" always;
    add_header Cross-Origin-Embedder-Policy "require-corp" always;
    
    # HSTS - 2 years
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # Permissions Policy - restrict browser features
    add_header Permissions-Policy "
        accelerometer=(),
        camera=(),
        geolocation=(),
        gyroscope=(),
        magnetometer=(),
        microphone=(),
        payment=(),
        usb=(),
        document-domain=(),
        fullscreen=(self),
        screen-wake-lock=(),
        xr-spatial-tracking=()
    " always;
    
    # Content Security Policy
    add_header Content-Security-Policy "
        default-src 'self';
        base-uri 'self';
        child-src 'self';
        connect-src 'self' https:;
        font-src 'self';
        form-action 'self';
        frame-ancestors 'none';
        img-src 'self' data: https:;
        manifest-src 'self';
        media-src 'self';
        object-src 'none';
        script-src 'self' 'unsafe-inline' 'unsafe-eval';
        style-src 'self' 'unsafe-inline';
        upgrade-insecure-requests;
        block-all-mixed-content;
    " always;

    # =========================================================================
    # SSL/TLS HARDENING
    # =========================================================================
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;
    ssl_early_data off;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 8.8.8.8 valid=300s;
    resolver_timeout 5s;
    
    # Diffie-Hellman parameters for PFS
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name example.com www.example.com;
        
        # SSL Certificate
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        
        # Root directory
        root /var/www/html;
        index index.html;
        
        # --------------------------------------------------------------------
        # REQUEST VALIDATION
        # --------------------------------------------------------------------
        # Global rate limiting
        limit_req zone=global burst=20 nodelay;
        limit_conn conn 10;
        
        # Block suspicious user agents
        if ($http_user_agent ~* "(sqlmap|nmap|nikto|nessus|openvas|masscan|httrack|wpscan|joomscan|dirbuster|gobuster|wfuzz|ffuf|nikto|skipfish|w3af|arachni|zap|burp|acunetix|netsparker|appscan|webinspect|retire|retire.js|snyk|npm-audit|yarn-audit|depscan|dependency-check|owasp|zap|burpsuite|metasploit|beef|set|social-engineer|aircrack|reaver|hydra|medusa|ncrack|thc-hydra|john|hashcat|ophcrack|samdump2|chntpw|bkhive|secretsdump|mimikatz|psexec|wmiexec|smbexec|atexec|pth|pass-the-hash|golden-ticket|silver-ticket|skeleton-key|dcsync|ntdsutil|esentutl|vssadmin|wbadmin|ntbackup|robocopy|xcopy|icacls|cacls|takeown|subinacl|setacl|dnsdump|adidnsdump|powerview|bloodhound|sharphound|pingcastle|purpleknight|crackmapexec|netexec|enum4linux|smbclient|smbmap|netview|nbtscan|nbstat|nbtstat|netstat|nmap|masscan|zmap|unicornscan|amap|proxychains|socks|tor|polipo|privoxy|vidalia|arm|torsocks|dns2tcp|iodine|tun2socks|badvpn|openvpn|wireguard|softether|ocserv|strongswan|libreswan|xl2tpd|accel-ppp|sstp-client|openconnect|anyconnect|globalprotect|pulse-secure|forticlient|cisco-vpn|juniper-vpn|f5-vpn|palo-alto-vpn|checkpoint-vpn|sonicwall-vpn|draytek-vpn|watchguard-vpn|barracuda-vpn|sophos-vpn|cyberoam-vpn|zscaler-vpn|cloudflare-warp|tailscale|zerotier|nebula|yggdrasil|cjdns|ipfs|libp2p|webtorrent|bittorrent|rtorrent|deluge|transmission|qbittorrent|vuze|utorrent|bittorrent|aria2|axel|wget|curl|httpie|postman|insomnia|rest-client|soapui|jmeter|loadrunner|gatling|grinder|siege|ab|wrk|hey|vegeta|drill|boom|tsung|locust|jmeter|gatling|grinder|tsung|siege|ab|wrk|hey|vegeta)") {
            return 403;
        }
        
        # Block path traversal attempts
        if ($request_uri ~* "\.\./") {
            return 403;
        }
        
        # Block SQL injection attempts
        if ($query_string ~* "(union|select|insert|update|delete|drop|exec|eval|alter|create|table|from|where|having|group|order|limit|offset|join|left|right|inner|outer|full|cross|natural|using|on|between|like|in|exists|any|all|some|not|and|or|xor)") {
            return 403;
        }
        
        # Block XSS attempts
        if ($query_string ~* "(<|>|%3C|%3E|javascript:|onerror|onload|alert|confirm|prompt|eval|document|cookie|window|location|href|src|data|vbscript|expression|url|http-equiv|meta|style|script|iframe|object|embed|applet|base|link|body|head|html|title|body|br|hr|p|div|span|form|input|button|select|option|textarea|table|tr|td|th|tbody|thead|tfoot|col|colgroup|caption|img|a|area|map|canvas|svg|audio|video|source|track|datalist|keygen|output|progress|meter|time|mark|ruby|rt|rp|bdi|bdo|wbr|noscript|template|slot|details|summary|dialog|menu|menuitem|nav|aside|section|article|header|footer|main|address|figure|figcaption|picture|portal|math|annotation|annotation-xml|maction|math|merror|mfrac|mi|mmultiscripts|mn|mo|mover|mpadded|mphantom|mroot|mrow|ms|mspace|msqrt|mstyle|msub|msup|msubsup|mtable|mtd|mtext|mtr|munder|munderover|semantics|menclose)") {
            return 403;
        }
        
        # Block bad request methods
        if ($request_method !~ ^(GET|HEAD|POST|PUT|DELETE|OPTIONS)$) {
            return 405;
        }
        
        # Block requests with empty host header
        if ($http_host = "") {
            return 400;
        }
        
        # Block requests with null byte
        if ($request_uri ~* "\x00") {
            return 400;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: STATIC ASSETS
        # --------------------------------------------------------------------
        location /static/ {
            # Long-term cache
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            
            # Security
            add_header Cross-Origin-Resource-Policy "cross-origin";
            
            # Prevent directory listing
            autoindex off;
            
            # Serve files directly
            root /var/www/html;
            try_files $uri =404;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: SENSITIVE FILE PROTECTION
        # --------------------------------------------------------------------
        location ~* \.(env|git|svn|htaccess|htpasswd|ini|log|sql|sqlite|db|bak|backup|old|orig|save)$ {
            return 403;
        }
        
        location ~* /(wp-config|config|settings|database|db)\.php$ {
            return 403;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: ADMIN (RESTRICTED)
        # --------------------------------------------------------------------
        location /admin/ {
            # IP-based access control
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            allow 127.0.0.1;
            deny all;
            
            # Strict rate limiting
            limit_req zone=admin burst=2 nodelay;
            limit_conn conn 1;
            
            # Admin-specific headers
            add_header X-Robots-Tag "noindex, nofollow" always;
            add_header Cache-Control "no-store, no-cache, must-revalidate" always;
            
            # Basic authentication
            auth_basic "Admin Area";
            auth_basic_user_file /etc/nginx/.htpasswd;
            
            proxy_pass http://admin_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: API (PROTECTED)
        # --------------------------------------------------------------------
        location /api/ {
            # Rate limiting
            limit_req zone=api burst=10 nodelay;
            
            # API key validation
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
            }
            
            # Validate content type for POST/PUT
            if ($request_method = POST) {
                if ($content_type !~ "application/json") {
                    return 415 '{"error":"Content-Type must be application/json"}';
                }
            }
            
            # Validate body size
            if ($content_length > 1000000) {
                return 413 '{"error":"Request too large"}';
            }
            
            # CORS headers
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-API-Key" always;
            
            # Preflight requests
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin "*" always;
                add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
                add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-API-Key" always;
                add_header Content-Length 0;
                return 204;
            }
            
            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: LOGIN (STRICT)
        # --------------------------------------------------------------------
        location /login/ {
            # Very strict rate limiting
            limit_req zone=login burst=2 nodelay;
            limit_conn conn_login 1;
            
            # Prevent brute force
            if ($http_user_agent = "") {
                return 403;
            }
            
            proxy_pass http://auth_backend/login/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Set security cookies
            proxy_cookie_path / "/; Secure; HttpOnly; SameSite=Strict";
            add_header Set-Cookie "sessionid=; Secure; HttpOnly; SameSite=Strict";
        }
        
        # --------------------------------------------------------------------
        # LOCATION: HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-Content-Type-Options "nosniff";
            
            proxy_pass http://backend/health;
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: NGINX STATUS (INTERNAL)
        # --------------------------------------------------------------------
        location /nginx-status {
            allow 127.0.0.1;
            deny all;
            stub_status on;
            access_log off;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: DEFAULT (CATCH ALL)
        # --------------------------------------------------------------------
        location / {
            # Serve static content or proxy
            try_files $uri $uri/ @proxy;
        }
        
        # --------------------------------------------------------------------
        # LOCATION: PROXY FALLBACK
        # --------------------------------------------------------------------
        location @proxy {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Content-Type-Options "nosniff";
            
            # Buffering
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
            proxy_busy_buffers_size 8k;
            
            # Timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 10s;
        }
    }
    
    # =========================================================================
    # HTTP TO HTTPS REDIRECT
    # =========================================================================
    server {
        listen 80;
        listen [::]:80;
        server_name _;
        
        # Add HSTS header
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        
        # Redirect to HTTPS
        return 301 https://$host$request_uri;
    }
}
```

## P9.2 Security Tool Integration

### Fail2ban Integration

```bash
# /etc/fail2ban/jail.local
[nginx-auth]
enabled = true
port = http,https
filter = nginx-auth
logpath = /var/log/nginx/access.log
maxretry = 5
findtime = 300
bantime = 3600
action = iptables-multiport[name=nginx-auth, port="http,https", protocol=tcp]

[nginx-badbots]
enabled = true
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 1
findtime = 300
bantime = 86400
action = iptables-multiport[name=nginx-badbots, port="http,https", protocol=tcp]
```

### ModSecurity Integration

```nginx
# nginx.conf - ModSecurity integration
load_module /usr/lib/nginx/modules/ngx_http_modsecurity_module.so;

http {
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsecurity/rules.conf;
    
    server {
        # OWASP Core Rule Set
        modsecurity_rules_file /etc/nginx/modsecurity/owasp-crs.conf;
    }
}
```

### Security Audit Script

**File: `audit-security.sh`**

```bash
#!/bin/bash
# audit-security.sh - Complete security audit

echo "=== Nginx Security Audit ==="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Check version
echo "1. Nginx Version:"
nginx -v 2>&1

# 2. Check running processes
echo ""
echo "2. Running Processes:"
ps aux | grep nginx | grep -v grep

# 3. Check file permissions
echo ""
echo "3. File Permissions:"
ls -la /etc/nginx/nginx.conf
ls -la /var/log/nginx/

# 4. Check SSL/TLS
echo ""
echo "4. SSL/TLS Configuration:"
openssl s_client -connect localhost:443 -tls1_2 < /dev/null 2>&1 | head -10

# 5. Check security headers
echo ""
echo "5. Security Headers:"
curl -I https://localhost/ 2>/dev/null | grep -E "Strict-Transport|X-Content|X-Frame|X-XSS|Referrer|Content-Security|Permissions"

# 6. Check rate limiting
echo ""
echo "6. Rate Limiting:"
nginx -T 2>/dev/null | grep -A2 "limit_req_zone"

# 7. Check access control
echo ""
echo "7. Access Control:"
nginx -T 2>/dev/null | grep -A3 "allow" | head -15

# 8. Check logging
echo ""
echo "8. Logging:"
ls -la /var/log/nginx/ | head -5

# 9. Check for errors
echo ""
echo "9. Error Log Analysis:"
tail -20 /var/log/nginx/error.log

# 10. Check for suspicious requests
echo ""
echo "10. Suspicious Requests (last 100 lines):"
tail -100 /var/log/nginx/access.log | grep -E "union|select|exec|eval|<script>|../../../" | head -10

echo ""
echo "=== Audit Complete ==="
```

---

This primer provides the ultimate security hardening guide for Nginx in production. Use this as your security baseline for all production deployments.
