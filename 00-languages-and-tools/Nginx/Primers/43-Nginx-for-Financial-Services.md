# Primer 43: Nginx for Financial Services

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for financial services applications. Understanding these concepts is essential for building secure, compliant, and high-performance fintech platforms.

## P43.1 Financial Services Architecture

### Fintech Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FINANCIAL SERVICES ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX FINANCIAL GATEWAY                        │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    TRANSACTION PROCESSING                 │ │      │
│  │  │  • Payment Processing  • Fund Transfer    • Settlement    │ │      │
│  │  │  • Reconciliation      • Fraud Detection   • KYC/AML     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SECURITY & COMPLIANCE                  │ │      │
│  │  │  • PCI DSS            • SOC 2          • GDPR            │ │      │
│  │  │  • mTLS               • Encryption      • Audit Logs     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    REAL-TIME MONITORING                   │ │      │
│  │  │  • Fraud Detection    • Transaction Monitoring            │ │      │
│  │  │  • Anomaly Detection  • Risk Scoring     • Alerts        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    FINANCIAL SERVICES                            │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Payment    │  │ Account    │  │ Trading    │  │ Fraud    │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Financial Services Configuration

```nginx
# nginx-financial.conf - Complete Financial Services
# ============================================================================
# NGINX FINANCIAL SERVICES GATEWAY
# Complete production-ready financial services configuration
# ============================================================================

http {
    # =========================================================================
    # FINANCIAL SECURITY SETTINGS
    # =========================================================================
    # Strong security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Financial services headers
    add_header X-Financial-Gateway "nginx" always;
    add_header X-Financial-Version "2.0.0" always;
    
    # =========================================================================
    # TLS/SSL HARDENING FOR FINANCIAL SERVICES
    # =========================================================================
    # Strong TLS configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    # Strong DH parameters
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;
    
    # =========================================================================
    # RATE LIMITING FOR FINANCIAL SERVICES
    # =========================================================================
    # Strict rate limiting for financial endpoints
    limit_req_zone $binary_remote_addr zone=payment:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=trading:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=transfer:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=fraud:10m rate=100r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # FINANCIAL UPSTREAMS
    # =========================================================================
    # Payment Processing
    upstream payment_service {
        server payment1:8001 max_fails=2 fail_timeout=10s;
        server payment2:8001 max_fails=2 fail_timeout=10s;
        server payment3:8001 max_fails=2 fail_timeout=10s;
        keepalive 16;
    }
    
    # Account Management
    upstream account_service {
        server account1:8002 max_fails=3 fail_timeout=30s;
        server account2:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Trading Service
    upstream trading_service {
        server trading1:8003 max_fails=2 fail_timeout=10s;
        server trading2:8003 max_fails=2 fail_timeout=10s;
        keepalive 16;
    }
    
    # Fraud Detection
    upstream fraud_service {
        server fraud1:8004 max_fails=3 fail_timeout=30s;
        server fraud2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # KYC/AML Service
    upstream kyc_service {
        server kyc1:8005 max_fails=3 fail_timeout=30s;
        server kyc2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # FINANCIAL SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name financial.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/financial.crt;
        ssl_certificate_key /etc/nginx/ssl/financial.key;
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
        
        # Financial headers
        add_header X-Financial-Gateway "nginx" always;
        add_header X-Financial-Version "2.0.0" always;
        
        # =========================================================================
        # PAYMENT PROCESSING
        # =========================================================================
        location /payment/ {
            # Strict rate limiting
            limit_req zone=payment burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # mTLS authentication for payment
            proxy_ssl_certificate /etc/nginx/ssl/mtls.crt;
            proxy_ssl_certificate_key /etc/nginx/ssl/mtls.key;
            proxy_ssl_trusted_certificate /etc/nginx/ssl/ca.crt;
            proxy_ssl_verify on;
            proxy_ssl_verify_depth 2;
            
            # Authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Security headers
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            add_header Pragma "no-cache";
            add_header X-Content-Type-Options "nosniff";
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            
            proxy_pass http://payment_service/payment/;
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
        # FUND TRANSFER
        # =========================================================================
        location /transfer/ {
            # Strict rate limiting
            limit_req zone=transfer burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # mTLS authentication
            proxy_ssl_certificate /etc/nginx/ssl/mtls.crt;
            proxy_ssl_certificate_key /etc/nginx/ssl/mtls.key;
            proxy_ssl_trusted_certificate /etc/nginx/ssl/ca.crt;
            proxy_ssl_verify on;
            
            # Authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            
            proxy_pass http://account_service/transfer/;
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
        # TRADING
        # =========================================================================
        location /trading/ {
            # Very strict rate limiting
            limit_req zone=trading burst=1 nodelay;
            limit_conn conn_limit 1;
            
            # mTLS authentication
            proxy_ssl_certificate /etc/nginx/ssl/mtls.crt;
            proxy_ssl_certificate_key /etc/nginx/ssl/mtls.key;
            proxy_ssl_trusted_certificate /etc/nginx/ssl/ca.crt;
            proxy_ssl_verify on;
            
            # Authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            
            proxy_pass http://trading_service/trading/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # FRAUD DETECTION
        # =========================================================================
        location /fraud/ {
            # Rate limiting for fraud checks
            limit_req zone=fraud burst=20 nodelay;
            
            # Authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://fraud_service/fraud/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Transaction-ID $http_x_transaction_id;
            proxy_set_header X-Transaction-Amount $http_x_transaction_amount;
            proxy_set_header X-Transaction-Type $http_x_transaction_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # KYC/AML
        # =========================================================================
        location /kyc/ {
            # Rate limiting
            limit_req zone=payment burst=5 nodelay;
            
            # Authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://kyc_service/kyc/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-KYC-Type $http_x_kyc_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # ACCOUNT MANAGEMENT
        # =========================================================================
        location /accounts/ {
            # Authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=payment burst=10 nodelay;
            
            # Cache for account info
            if ($request_method = GET) {
                proxy_cache product_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://account_service/accounts/;
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
        # AUDIT LOGGING
        # =========================================================================
        # Log all financial transactions
        location / {
            # Audit log format
            log_format audit escape=json '{'
                '"timestamp":"$time_iso8601",'
                '"request_id":"$request_id",'
                '"user_id":"$auth_user_id",'
                '"remote_addr":"$remote_addr",'
                '"request_method":"$request_method",'
                '"request_uri":"$request_uri",'
                '"status":$status,'
                '"request_time":$request_time,'
                '"upstream_addr":"$upstream_addr",'
                '"upstream_status":$upstream_status,'
                '"user_agent":"$http_user_agent"'
            '}';
            
            access_log /var/log/nginx/audit.log audit;
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://account_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            proxy_set_header X-Client-Cert $ssl_client_cert;
            
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_role $upstream_http_x_user_role;
            auth_request_set $auth_user_level $upstream_http_x_user_level;
            
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
        # FINANCIAL STATUS
        # =========================================================================
        location /financial/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "payment":$(curl -s -o /dev/null -w "%{http_code}" http://payment1:8001/health),
                    "account":$(curl -s -o /dev/null -w "%{http_code}" http://account1:8002/health),
                    "trading":$(curl -s -o /dev/null -w "%{http_code}" http://trading1:8003/health),
                    "fraud":$(curl -s -o /dev/null -w "%{http_code}" http://fraud1:8004/health),
                    "kyc":$(curl -s -o /dev/null -w "%{http_code}" http://kyc1:8005/health)
                },
                "transaction_count":$(tail -10000 /var/log/nginx/access.log | grep -c "/payment/"),
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

## P43.2 Financial Security & Compliance

### Regulatory Compliance Configuration

```nginx
# nginx-financial-compliance.conf - Regulatory Compliance
# ============================================================================
# NGINX FINANCIAL SERVICES COMPLIANCE
# Complete regulatory compliance configuration
# ============================================================================

http {
    # =========================================================================
    # COMPLIANCE HEADERS
    # =========================================================================
    # PCI DSS compliance
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # GDPR compliance
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # SOC 2 compliance
    add_header Access-Control-Allow-Origin "*" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-User-ID" always;
    add_header Access-Control-Expose-Headers "X-Request-ID, X-Transaction-ID" always;
    
    # =========================================================================
    # ENCRYPTION
    # =========================================================================
    # Strong encryption for financial data
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1h;
    
    # =========================================================================
    # DATA PROTECTION
    # =========================================================================
    # Mask sensitive data in logs
    location /payment/ {
        # Log without sensitive data
        access_log /var/log/nginx/payment.log mask;
    }
    
    # Mask log format
    log_format mask escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"request_id":"$request_id",'
        '"status":$status,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr"'
    '}';
}
```

## P43.3 Financial Monitoring

### Financial Services Monitoring

```bash
#!/bin/bash
# financial-monitor.sh - Financial services monitoring

echo "=== Financial Services Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get transaction stats
get_transaction_stats() {
    local payments=$(tail -10000 /var/log/nginx/access.log | grep -c "/payment/")
    local transfers=$(tail -10000 /var/log/nginx/access.log | grep -c "/transfer/")
    local trades=$(tail -10000 /var/log/nginx/access.log | grep -c "/trading/")
    echo "  Transaction Statistics:"
    echo "    Payments: $payments"
    echo "    Transfers: $transfers"
    echo "    Trades: $trades"
}

# Function: Get fraud stats
get_fraud_stats() {
    local fraud_checks=$(tail -10000 /var/log/nginx/access.log | grep -c "/fraud/")
    local fraud_alerts=$(tail -10000 /var/log/nginx/access.log | grep "/fraud/" | grep -c "alert")
    echo "  Fraud Statistics:"
    echo "    Checks: $fraud_checks"
    echo "    Alerts: $fraud_alerts"
}

# Function: Get KYC stats
get_kyc_stats() {
    local kyc_checks=$(tail -10000 /var/log/nginx/access.log | grep -c "/kyc/")
    local kyc_completed=$(tail -10000 /var/log/nginx/access.log | grep "/kyc/" | grep -c "completed")
    echo "  KYC Statistics:"
    echo "    Checks: $kyc_checks"
    echo "    Completed: $kyc_completed"
}

# Function: Get service health
get_service_health() {
    echo "  Service Health:"
    for service in payment account trading fraud kyc; do
        health=$(curl -s -o /dev/null -w "%{http_code}" "http://${service}1:8001/health" 2>/dev/null)
        if [ "$health" = "200" ]; then
            echo -e "    ${GREEN}✓ $service: healthy${NC}"
        else
            echo -e "    ${RED}✗ $service: unhealthy (HTTP $health)${NC}"
        fi
    done
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
    echo "║              FINANCIAL SERVICES MONITORING DASHBOARD          ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 TRANSACTION STATISTICS:"
    get_transaction_stats
    echo ""
    get_fraud_stats
    echo ""
    get_kyc_stats
    echo ""
    get_service_health
    echo ""
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for financial services applications. Use these techniques to build secure, compliant, and high-performance fintech platforms.
