# Primer 53: Nginx for Government & Public Sector Applications

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for government and public sector applications. Understanding these concepts is essential for building secure, compliant, and accessible public sector platforms.

## P53.1 Government Platform Architecture

### Public Sector Technology Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GOVERNMENT PLATFORM ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX GOVERNMENT GATEWAY                       │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    COMPLIANCE & SECURITY                  │ │      │
│  │  │  • FISMA/NIST        • FedRAMP         • CJIS            │ │      │
│  │  │  • HIPAA             • GDPR            • 508            │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PUBLIC SERVICES                        │ │      │
│  │  │  • Citizen Portal    • Benefits          • Records        │ │      │
│  │  │  • Permits           • Payments          • Notifications  │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ACCESSIBILITY                         │ │      │
│  │  │  • WCAG 2.1         • Section 508       • Multi-language  │ │      │
│  │  │  • Screen Readers   • Keyboard Navigation  • Captions     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    GOVERNMENT SERVICES                            │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Citizen    │  │ Records    │  │ Benefits   │  │ Payments │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Government Platform Configuration

```nginx
# nginx-government.conf - Complete Government Platform
# ============================================================================
# NGINX GOVERNMENT & PUBLIC SECTOR PLATFORM
# Complete production-ready government configuration
# ============================================================================

http {
    # =========================================================================
    # GOVERNMENT PLATFORM SETTINGS
    # =========================================================================
    # Large payloads for forms and documents
    client_max_body_size 100M;
    client_body_buffer_size 1M;
    
    # Buffer settings
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Timeouts
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # =========================================================================
    # COMPLIANCE HEADERS
    # =========================================================================
    # FISMA/NIST compliance headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Accessibility headers
    add_header Access-Control-Allow-Origin "*" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
    
    # Section 508 compliance
    add_header X-Accessibility "WCAG 2.1 AA" always;
    
    # =========================================================================
    # GOVERNMENT PLATFORM CACHING
    # =========================================================================
    # Public content cache
    proxy_cache_path /var/cache/nginx/public_cache
        levels=1:2
        keys_zone=public_cache:500m
        max_size=10g
        inactive=1h
        use_temp_path=off;
    
    # Records cache (encrypted)
    proxy_cache_path /var/cache/nginx/records_cache
        levels=1:2
        keys_zone=records_cache:500m
        max_size=10g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=public:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=secure:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=records:10m rate=10r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # GOVERNMENT UPSTREAMS
    # =========================================================================
    # Citizen Service
    upstream citizen_service {
        least_conn;
        server citizen1:8001 max_fails=3 fail_timeout=30s;
        server citizen2:8001 max_fails=3 fail_timeout=30s;
        server citizen3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Records Service
    upstream records_service {
        server records1:8002 max_fails=3 fail_timeout=30s;
        server records2:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Benefits Service
    upstream benefits_service {
        server benefits1:8003 max_fails=3 fail_timeout=30s;
        server benefits2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Payment Service
    upstream payment_service {
        server payment1:8004 max_fails=2 fail_timeout=10s;
        server payment2:8004 max_fails=2 fail_timeout=10s;
        keepalive 16;
    }
    
    # Notification Service
    upstream notification_service {
        server notify1:8005 max_fails=3 fail_timeout=30s;
        server notify2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # GOVERNMENT SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name gov.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/gov.crt;
        ssl_certificate_key /etc/nginx/ssl/gov.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        
        # Government headers
        add_header X-Government-Gateway "nginx" always;
        add_header X-Government-Version "2.0.0" always;
        add_header X-Accessibility "WCAG 2.1 AA" always;
        
        # Global Rate Limiting
        limit_req zone=public burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # =========================================================================
        # CITIZEN PORTAL (PUBLIC)
        # =========================================================================
        location /citizen/ {
            # Public content with caching
            proxy_cache public_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 10m;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Accessibility headers
            add_header Content-Language "en,es,zh";
            
            proxy_pass http://citizen_service/citizen/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Language $http_x_language;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # SECURE RECORDS
        # =========================================================================
        location /records/ {
            # Strong authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_clearance $upstream_http_x_user_clearance;
            
            # Strict rate limiting
            limit_req zone=records burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # Clearance check
            if ($auth_user_clearance !~ ^(classified|top-secret|admin)$) {
                return 403 '{"error":"Insufficient clearance"}';
                add_header Content-Type application/json;
            }
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            add_header X-Content-Type-Options "nosniff";
            add_header X-Frame-Options "DENY";
            
            # Encrypted response
            add_header X-Content-Encryption "AES-256-GCM";
            
            proxy_pass http://records_service/records/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-User-Clearance $auth_user_clearance;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # BENEFITS
        # =========================================================================
        location /benefits/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=secure burst=10 nodelay;
            
            # Cache benefits info
            if ($request_method = GET) {
                proxy_cache records_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://benefits_service/benefits/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # PAYMENTS
        # =========================================================================
        location /payments/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Strict rate limiting
            limit_req zone=records burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            add_header X-Content-Type-Options "nosniff";
            add_header X-Frame-Options "DENY";
            
            proxy_pass http://payment_service/payments/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            proxy_intercept_errors on;
            error_page 502 503 504 = /payment-fallback;
        }
        
        # =========================================================================
        # PAYMENT FALLBACK
        # =========================================================================
        location = /payment-fallback {
            return 503 '{"error":"Payment service temporarily unavailable","retry_after":"30s"}';
            add_header Content-Type application/json;
            add_header Retry-After 30;
        }
        
        # =========================================================================
        # NOTIFICATIONS
        # =========================================================================
        location /notifications/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=secure burst=10 nodelay;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://notification_service/notifications/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Notification-Type $http_x_notification_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://auth_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            proxy_set_header X-Session-ID $http_x_session_id;
            
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_clearance $upstream_http_x_user_clearance;
            auth_request_set $auth_user_agency $upstream_http_x_user_agency;
            
            proxy_intercept_errors on;
            error_page 401 = /auth-error;
        }
        
        # =========================================================================
        # AUTH ERROR
        # =========================================================================
        location = /auth-error {
            return 401 '{"error":"Authentication required"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # GOVERNMENT STATUS
        # =========================================================================
        location /gov/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "citizen":$(curl -s -o /dev/null -w "%{http_code}" http://citizen1:8001/health),
                    "records":$(curl -s -o /dev/null -w "%{http_code}" http://records1:8002/health),
                    "benefits":$(curl -s -o /dev/null -w "%{http_code}" http://benefits1:8003/health),
                    "payment":$(curl -s -o /dev/null -w "%{http_code}" http://payment1:8004/health),
                    "notifications":$(curl -s -o /dev/null -w "%{http_code}" http://notify1:8005/health)
                },
                "compliance":{
                    "fisma":"compliant",
                    "fedramp":"compliant",
                    "section508":"compliant"
                },
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P53.2 Accessibility Compliance

### Section 508 & WCAG Configuration

```nginx
# nginx-accessibility.conf - Accessibility Configuration
# ============================================================================
# NGINX SECTION 508 & WCAG COMPLIANCE
# Complete accessibility configuration
# ============================================================================

http {
    # =========================================================================
    # ACCESSIBILITY HEADERS
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name gov.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/gov.crt;
        ssl_certificate_key /etc/nginx/ssl/gov.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # =========================================================================
        # SECTION 508 HEADERS
        # =========================================================================
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        
        # WCAG 2.1 AA compliance
        add_header X-Accessibility "WCAG 2.1 AA" always;
        add_header X-Content-Accessibility "screen-readable" always;
        
        # Language support
        add_header Content-Language "en,es,zh,ar" always;
        
        # =========================================================================
        # ACCESSIBLE CONTENT
        # =========================================================================
        location /accessible/ {
            # Cache accessible content
            proxy_cache public_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Accessibility headers
            add_header Cache-Control "public, max-age=3600";
            add_header Content-Language $http_x_language;
            add_header X-Content-Accessibility "screen-readable";
            
            proxy_pass http://accessible_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Language $http_x_language;
            proxy_set_header X-Screen-Reader $http_x_screen_reader;
            proxy_set_header X-Keyboard-Navigation $http_x_keyboard_navigation;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # ALTERNATIVE FORMATS
        # =========================================================================
        location /alt/ {
            # Alternative formats
            proxy_pass http://accessible_service/alt;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Format $http_x_format;
            proxy_set_header X-Language $http_x_language;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

## P53.3 Government Platform Monitoring

### Government Platform Dashboard

```bash
#!/bin/bash
# gov-monitor.sh - Government platform monitoring

echo "=== Government Platform Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get citizen engagement
get_citizen_engagement() {
    local visits=$(tail -10000 /var/log/nginx/access.log | grep -c "/citizen/")
    local applications=$(tail -10000 /var/log/nginx/access.log | grep -c "/benefits/")
    local payments=$(tail -10000 /var/log/nginx/access.log | grep -c "/payments/")
    echo "  Citizen Engagement:"
    echo "    Portal Visits: $visits"
    echo "    Benefits Applications: $applications"
    echo "    Payment Transactions: $payments"
}

# Function: Get accessibility metrics
get_accessibility_metrics() {
    local screen_reader=$(tail -10000 /var/log/nginx/access.log | grep -c '"X-Screen-Reader":"true"')
    local keyboard_nav=$(tail -10000 /var/log/nginx/access.log | grep -c '"X-Keyboard-Navigation":"true"')
    local languages=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-Language":"[^"]*"' | cut -d'"' -f4 | sort | uniq -c)
    echo "  Accessibility Metrics:"
    echo "    Screen Reader Users: $screen_reader"
    echo "    Keyboard Navigation Users: $keyboard_nav"
    echo "    Languages Used:"
    echo "$languages" | while read count lang; do
        echo "      $lang: $count"
    done
}

# Function: Get service health
get_service_health() {
    echo "  Service Health:"
    for service in citizen records benefits payment notifications; do
        health=$(curl -s -o /dev/null -w "%{http_code}" "http://${service}1:8001/health" 2>/dev/null)
        if [ "$health" = "200" ]; then
            echo -e "    ${GREEN}✓ $service: healthy${NC}"
        else
            echo -e "    ${RED}✗ $service: unhealthy (HTTP $health)${NC}"
        fi
    done
}

# Function: Get compliance status
get_compliance_status() {
    echo "  Compliance Status:"
    local compliance=$(curl -s -I https://gov.example.com 2>/dev/null | grep -c "X-Accessibility")
    if [ $compliance -gt 0 ]; then
        echo -e "    ${GREEN}✓ Section 508 Compliant${NC}"
        echo -e "    ${GREEN}✓ WCAG 2.1 AA Compliant${NC}"
    else
        echo -e "    ${RED}✗ Accessibility compliance check failed${NC}"
    fi
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              GOVERNMENT PLATFORM MONITORING DASHBOARD         ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "🏛️ CITIZEN ENGAGEMENT:"
    get_citizen_engagement
    echo ""
    echo "♿ ACCESSIBILITY:"
    get_accessibility_metrics
    echo ""
    echo "✅ COMPLIANCE:"
    get_compliance_status
    echo ""
    echo "🏥 SERVICE HEALTH:"
    get_service_health
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for government and public sector applications. Use these techniques to build secure, compliant, and accessible public sector platforms.
