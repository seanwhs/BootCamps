# Primer 44: Nginx for Healthcare Applications

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for healthcare applications. Understanding these concepts is essential for building secure, compliant, and high-performance healthcare platforms.

## P44.1 Healthcare Architecture

### Healthcare Application Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    HEALTHCARE ARCHITECTURE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX HEALTHCARE GATEWAY                       │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PATIENT MANAGEMENT                     │ │      │
│  │  │  • EHR/EMR Access   • Patient Records    • Consent        │ │      │
│  │  │  • Scheduling        • Billing           • Insurance      │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SECURITY & COMPLIANCE                  │ │      │
│  │  │  • HIPAA              • GDPR            • HITECH         │ │      │
│  │  │  • mTLS               • Encryption      • Audit Logs     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    REAL-TIME MONITORING                   │ │      │
│  │  │  • Patient Monitoring  • Alerting         • Analytics     │ │      │
│  │  │  • Telemedicine        • IoT Integration  • ML Predictions│ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    HEALTHCARE SERVICES                            │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ EHR        │  │ Scheduling │  │ Billing    │  │ Telemed  │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Healthcare Configuration

```nginx
# nginx-healthcare.conf - Complete Healthcare Configuration
# ============================================================================
# NGINX HEALTHCARE GATEWAY
# Complete production-ready healthcare configuration
# ============================================================================

http {
    # =========================================================================
    # HEALTHCARE SECURITY SETTINGS
    # =========================================================================
    # HIPAA compliance headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Healthcare headers
    add_header X-Healthcare-Gateway "nginx" always;
    add_header X-Healthcare-Version "2.0.0" always;
    
    # =========================================================================
    # TLS/SSL HARDENING FOR HEALTHCARE
    # =========================================================================
    # HIPAA requires strong encryption
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    # =========================================================================
    # RATE LIMITING FOR HEALTHCARE
    # =========================================================================
    # Healthcare-specific rate limits
    limit_req_zone $binary_remote_addr zone=ehr:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=scheduling:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=billing:10m rate=30r/m;
    limit_req_zone $binary_remote_addr zone=telemed:10m rate=20r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # HEALTHCARE UPSTREAMS
    # =========================================================================
    # EHR/EMR Service
    upstream ehr_service {
        server ehr1:8001 max_fails=3 fail_timeout=30s;
        server ehr2:8001 max_fails=3 fail_timeout=30s;
        server ehr3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Scheduling Service
    upstream scheduling_service {
        server schedule1:8002 max_fails=3 fail_timeout=30s;
        server schedule2:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Billing Service
    upstream billing_service {
        server billing1:8003 max_fails=2 fail_timeout=10s;
        server billing2:8003 max_fails=2 fail_timeout=10s;
        keepalive 16;
    }
    
    # Telemedicine Service
    upstream telemed_service {
        server telemed1:8004 max_fails=3 fail_timeout=30s;
        server telemed2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Patient Service
    upstream patient_service {
        server patient1:8005 max_fails=3 fail_timeout=30s;
        server patient2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # HEALTHCARE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name healthcare.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/healthcare.crt;
        ssl_certificate_key /etc/nginx/ssl/healthcare.key;
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
        
        # Healthcare headers
        add_header X-Healthcare-Gateway "nginx" always;
        add_header X-Healthcare-Version "2.0.0" always;
        
        # =========================================================================
        # EHR/EMR ACCESS
        # =========================================================================
        location /ehr/ {
            # Strict authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_role $upstream_http_x_user_role;
            
            # Rate limiting
            limit_req zone=ehr burst=10 nodelay;
            limit_conn conn_limit 10;
            
            # Role-based access control (RBAC)
            if ($auth_user_role !~ ^(doctor|nurse|admin)$) {
                return 403 '{"error":"Insufficient permissions"}';
                add_header Content-Type application/json;
            }
            
            # HIPAA headers
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
            add_header X-HIPAA "protected-health-information";
            
            # No caching for EHR
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            
            proxy_pass http://ehr_service/ehr/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-User-Role $auth_user_role;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
        
        # =========================================================================
        # PATIENT RECORDS
        # =========================================================================
        location /patients/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_role $upstream_http_x_user_role;
            
            # Rate limiting
            limit_req zone=ehr burst=10 nodelay;
            
            # Role-based access
            if ($auth_user_role !~ ^(doctor|nurse|admin)$) {
                return 403 '{"error":"Insufficient permissions"}';
                add_header Content-Type application/json;
            }
            
            # Cache patient data (non-sensitive)
            if ($request_method = GET) {
                proxy_cache product_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://patient_service/patients/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-User-Role $auth_user_role;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # SCHEDULING
        # =========================================================================
        location /scheduling/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=scheduling burst=10 nodelay;
            
            # Cache scheduling data
            if ($request_method = GET) {
                proxy_cache product_cache;
                proxy_cache_key $scheme$host$request_uri;
                proxy_cache_valid 200 1m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://scheduling_service/scheduling/;
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
        # BILLING
        # =========================================================================
        location /billing/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Strict rate limiting
            limit_req zone=billing burst=5 nodelay;
            limit_conn conn_limit 5;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-HIPAA "financial-information";
            
            proxy_pass http://billing_service/billing/;
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
        }
        
        # =========================================================================
        # TELEMEDICINE (WEBSOCKET)
        # =========================================================================
        location /telemed/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=telemed burst=5 nodelay;
            limit_conn conn_limit 5;
            
            # WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Disable buffering
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://telemed_service/telemed/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            add_header X-HIPAA "telemedicine-session";
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://patient_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_role $upstream_http_x_user_role;
            auth_request_set $auth_user_consent $upstream_http_x_user_consent;
            
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
        # CONSENT MANAGEMENT
        # =========================================================================
        location /consent/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=ehr burst=10 nodelay;
            
            proxy_pass http://patient_service/consent/;
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
            
            add_header X-HIPAA "consent-management";
        }
        
        # =========================================================================
        # HEALTHCARE STATUS
        # =========================================================================
        location /healthcare/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "ehr":$(curl -s -o /dev/null -w "%{http_code}" http://ehr1:8001/health),
                    "scheduling":$(curl -s -o /dev/null -w "%{http_code}" http://schedule1:8002/health),
                    "billing":$(curl -s -o /dev/null -w "%{http_code}" http://billing1:8003/health),
                    "telemed":$(curl -s -o /dev/null -w "%{http_code}" http://telemed1:8004/health),
                    "patient":$(curl -s -o /dev/null -w "%{http_code}" http://patient1:8005/health)
                },
                "active_patients":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
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

## P44.2 Healthcare Security & Compliance

### HIPAA Compliance Configuration

```nginx
# nginx-hipaa.conf - HIPAA Compliance
# ============================================================================
# NGINX HIPAA COMPLIANCE CONFIGURATION
# Complete HIPAA compliance for healthcare
# ============================================================================

http {
    # =========================================================================
    # HIPAA SECURITY RULES
    # =========================================================================
    # 164.312(e)(1) - Transmission Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    
    # 164.312(a)(2)(i) - Access Control
    # Implemented via auth_request and RBAC
    
    # 164.312(b) - Audit Controls
    log_format hipaa escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"request_id":"$request_id",'
        '"user_id":"$auth_user_id",'
        '"remote_addr":"$remote_addr",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"request_time":$request_time',
        '"upstream_addr":"$upstream_addr"'
    '}';
    
    access_log /var/log/nginx/hipaa.log hipaa;
    
    # =========================================================================
    # HIPAA HEADERS
    # =========================================================================
    # 164.312(e)(2)(ii) - Encryption
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # =========================================================================
    # DATA PROTECTION
    # =========================================================================
    # Mask PHI in logs
    location /ehr/ {
        # Log without PHI
        access_log /var/log/nginx/ehr.log hipaa;
    }
}
```

## P44.3 Healthcare Monitoring

### Healthcare Services Monitoring

```bash
#!/bin/bash
# healthcare-monitor.sh - Healthcare monitoring

echo "=== Healthcare Services Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get patient stats
get_patient_stats() {
    local patients=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    local ehr_access=$(tail -10000 /var/log/nginx/access.log | grep -c "/ehr/")
    local appointments=$(tail -10000 /var/log/nginx/access.log | grep -c "/scheduling/")
    echo "  Patient Statistics:"
    echo "    Active Patients: $patients"
    echo "    EHR Accesses: $ehr_access"
    echo "    Appointments: $appointments"
}

# Function: Get service health
get_service_health() {
    echo "  Service Health:"
    for service in ehr scheduling billing telemed patient; do
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
    local hipaa_headers=$(curl -s -I https://localhost/ehr/ 2>/dev/null | grep -c "X-HIPAA")
    if [ $hipaa_headers -gt 0 ]; then
        echo -e "    ${GREEN}✓ HIPAA headers present${NC}"
    else
        echo -e "    ${RED}✗ HIPAA headers missing${NC}"
    fi
}

# Function: Get error rate
get_error_rate() {
    local errors=$(tail -1000 /var/log/nginx/access.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "  Error Rate: $errors%"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              HEALTHCARE SERVICES MONITORING DASHBOARD         ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 PATIENT STATISTICS:"
    get_patient_stats
    echo ""
    get_service_health
    echo ""
    get_compliance_status
    echo ""
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for healthcare applications. Use these techniques to build secure, compliant, and high-performance healthcare platforms.
