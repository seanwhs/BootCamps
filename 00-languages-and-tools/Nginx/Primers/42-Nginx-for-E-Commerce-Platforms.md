# Primer 42: Nginx for E-Commerce Platforms

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for e-commerce platforms. Understanding these concepts is essential for building scalable, secure, and high-performance online stores.

## P42.1 E-Commerce Architecture

### E-Commerce Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    E-COMMERCE ARCHITECTURE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX E-COMMERCE GATEWAY                       │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PRODUCT DISCOVERY                      │ │      │
│  │  │  • Catalog Search   • Product Listing    • Categories     │ │      │
│  │  │  • Filtering         • Sorting           • Pagination    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CART & CHECKOUT                        │ │      │
│  │  │  • Cart Management  • Checkout Flow      • Payment        │ │      │
│  │  │  • Shipping          • Tax Calculation   • Order          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CUSTOMER MANAGEMENT                    │ │      │
│  │  │  • User Profiles    • Authentication    • Orders          │ │      │
│  │  │  • Wish Lists       • Reviews           • Returns        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    E-COMMERCE SERVICES                           │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Catalog    │  │ Cart       │  │ Payment    │  │ User     │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete E-Commerce Configuration

```nginx
# nginx-ecommerce.conf - Complete E-Commerce Configuration
# ============================================================================
# NGINX E-COMMERCE PLATFORM
# Complete production-ready e-commerce configuration
# ============================================================================

http {
    # =========================================================================
    # E-COMMERCE SETTINGS
    # =========================================================================
    # Large payloads for orders
    client_max_body_size 20M;
    client_body_buffer_size 256k;
    
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
    # E-COMMERCE CACHING
    # =========================================================================
    # Product cache
    proxy_cache_path /var/cache/nginx/product_cache
        levels=1:2
        keys_zone=product_cache:1g
        max_size=20g
        inactive=1h
        use_temp_path=off;
    
    # Category cache
    proxy_cache_path /var/cache/nginx/category_cache
        levels=1:2
        keys_zone=category_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # Search cache
    proxy_cache_path /var/cache/nginx/search_cache
        levels=1:2
        keys_zone=search_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # Image cache
    proxy_cache_path /var/cache/nginx/image_cache
        levels=1:2
        keys_zone=image_cache:500m
        max_size=10g
        inactive=30d
        use_temp_path=off;
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    # Global limits
    limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # Endpoint-specific limits
    limit_req_zone $binary_remote_addr zone=checkout:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=search:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    
    # =========================================================================
    # E-COMMERCE UPSTREAMS
    # =========================================================================
    # Catalog Service
    upstream catalog_service {
        least_conn;
        server catalog1:8001 max_fails=3 fail_timeout=30s;
        server catalog2:8001 max_fails=3 fail_timeout=30s;
        server catalog3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Cart Service
    upstream cart_service {
        least_conn;
        server cart1:8002 max_fails=3 fail_timeout=30s;
        server cart2:8002 max_fails=3 fail_timeout=30s;
        server cart3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Payment Service
    upstream payment_service {
        server payment1:8003 max_fails=2 fail_timeout=10s;
        server payment2:8003 max_fails=2 fail_timeout=10s;
        server payment3:8003 max_fails=2 fail_timeout=10s;
        keepalive 16;
    }
    
    # User Service
    upstream user_service {
        server users1:8004 max_fails=3 fail_timeout=30s;
        server users2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Search Service
    upstream search_service {
        server search1:8005 max_fails=3 fail_timeout=30s;
        server search2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Recommendation Service
    upstream recommendation_service {
        server rec1:8006 max_fails=3 fail_timeout=30s;
        server rec2:8006 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # E-COMMERCE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name shop.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/shop.crt;
        ssl_certificate_key /etc/nginx/ssl/shop.key;
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
        
        # E-commerce headers
        add_header X-Ecommerce "nginx" always;
        add_header X-Ecommerce-Version "2.0.0" always;
        
        # Global Rate Limiting
        limit_req zone=global burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # =========================================================================
        # PRODUCT CATALOG
        # =========================================================================
        location /products/ {
            # Product catalog with heavy caching
            proxy_cache product_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://catalog_service/products/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # PRODUCT SEARCH
        # =========================================================================
        location /search/ {
            # Search with rate limiting
            limit_req zone=search burst=10 nodelay;
            
            proxy_cache search_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 5m;
            proxy_cache_valid 404 30s;
            proxy_cache_use_stale error timeout updating;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://search_service/search/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # CART
        # =========================================================================
        location /cart/ {
            # Cart authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # No caching for cart
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://cart_service/cart/;
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
        # CHECKOUT
        # =========================================================================
        location /checkout/ {
            # Strict rate limiting for checkout
            limit_req zone=checkout burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # Checkout authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://payment_service/checkout/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            proxy_intercept_errors on;
            error_page 502 503 504 = /checkout-fallback;
        }
        
        # =========================================================================
        # CHECKOUT FALLBACK
        # =========================================================================
        location = /checkout-fallback {
            return 503 '{"error":"Checkout service temporarily unavailable","retry_after":"30s"}';
            add_header Content-Type application/json;
            add_header Retry-After 30;
        }
        
        # =========================================================================
        # PAYMENT
        # =========================================================================
        location /payment/ {
            # Very strict rate limiting
            limit_req zone=checkout burst=2 nodelay;
            limit_conn conn_limit 1;
            
            # Payment authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Security headers for payment
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            add_header Pragma "no-cache";
            add_header X-Content-Type-Options "nosniff";
            
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
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
        }
        
        # =========================================================================
        # USER ACCOUNTS
        # =========================================================================
        location /users/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Cache user profiles
            if ($request_method = GET) {
                proxy_cache product_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://user_service/users/;
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
        # RECOMMENDATIONS
        # =========================================================================
        location /recommendations/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Cache recommendations
            proxy_cache product_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://recommendation_service/recommendations/;
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
        # AUTHENTICATION
        # =========================================================================
        location /auth/ {
            # Login rate limiting
            limit_req zone=login burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://user_service/auth/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://user_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            auth_request_set $auth_user_role $upstream_http_x_user_role;
            
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
        # E-COMMERCE STATUS
        # =========================================================================
        location /shop/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "cache_status":{
                    "product_cache_size":"$(du -sh /var/cache/nginx/product_cache | cut -f1)",
                    "image_cache_size":"$(du -sh /var/cache/nginx/image_cache | cut -f1)",
                    "search_cache_size":"$(du -sh /var/cache/nginx/search_cache | cut -f1)"
                },
                "performance":{
                    "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
                    "avg_response_time":$(tail -100 /var/log/nginx/access.log | grep -o '"request_time":[0-9.]*' | cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print 0}')
                },
                "active_sessions":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
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

## P42.2 E-Commerce Security

### PCI Compliance Configuration

```nginx
# nginx-pci-compliance.conf - PCI Compliance
# ============================================================================
# NGINX PCI COMPLIANCE CONFIGURATION
# Complete PCI DSS compliance for e-commerce
# ============================================================================

http {
    # =========================================================================
    # PCI DSS SECURITY HEADERS
    # =========================================================================
    # Strong security headers for payment pages
    server {
        listen 443 ssl http2;
        server_name secure.shop.example.com;
        
        # PCI DSS compliance headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        
        # Payment-specific headers
        add_header Content-Security-Policy "
            default-src 'self';
            script-src 'self' 'unsafe-inline' https://payment-gateway.com;
            style-src 'self' 'unsafe-inline';
            img-src 'self' data: https:;
            connect-src 'self' https://payment-gateway.com;
            frame-src https://payment-gateway.com;
            frame-ancestors 'none';
            form-action 'self';
            upgrade-insecure-requests;
            block-all-mixed-content;
        " always;
        
        # =========================================================================
        # PAYMENT FORM RESTRICTIONS
        # =========================================================================
        location /payment/ {
            # Only allow HTTPS
            if ($scheme != "https") {
                return 301 https://$host$request_uri;
            }
            
            # Strict rate limiting
            limit_req zone=checkout burst=2 nodelay;
            limit_conn conn_limit 1;
            
            # Payment validation
            if ($request_method !~ ^(POST|GET)$) {
                return 405;
            }
            
            # Add security headers
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
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # PCI DSS LOGGING
        # =========================================================================
        # Mask sensitive data in logs
        location /payment/ {
            # Log without sensitive data
            access_log /var/log/nginx/payment.log pci;
        }
        
        # PCI compliant log format
        log_format pci escape=json '{'
            '"timestamp":"$time_iso8601",'
            '"request_id":"$request_id",'
            '"remote_addr":"$remote_addr",'
            '"status":$status,'
            '"request_time":$request_time,'
            '"upstream_addr":"$upstream_addr",'
            '"request_method":"$request_method"'
        '}';
    }
}
```

## P42.3 E-Commerce Monitoring

### E-Commerce Dashboard

```bash
#!/bin/bash
# ecommerce-monitor.sh - E-commerce monitoring

echo "=== E-Commerce Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get sales stats
get_sales_stats() {
    local orders=$(tail -10000 /var/log/nginx/access.log | grep -c "/checkout/")
    local revenue=$(tail -10000 /var/log/nginx/access.log | grep "/checkout/" | grep -o '"total":[0-9.]*' | cut -d':' -f2 | awk '{sum+=$1} END {print sum}')
    echo "  Sales Statistics:"
    echo "    Orders: $orders"
    echo "    Revenue: $$revenue"
}

# Function: Get cart stats
get_cart_stats() {
    local carts=$(tail -10000 /var/log/nginx/access.log | grep -c "/cart/")
    local abandoned=$(tail -10000 /var/log/nginx/access.log | grep "/cart/" | grep -c "abandoned")
    echo "  Cart Statistics:"
    echo "    Active Carts: $carts"
    echo "    Abandoned: $abandoned"
}

# Function: Get product stats
get_product_stats() {
    local products=$(tail -10000 /var/log/nginx/access.log | grep -c "/products/")
    local searches=$(tail -10000 /var/log/nginx/access.log | grep -c "/search/")
    echo "  Product Statistics:"
    echo "    Products Viewed: $products"
    echo "    Searches: $searches"
}

# Function: Get conversion rate
get_conversion_rate() {
    local visitors=$(tail -10000 /var/log/nginx/access.log | grep -c "/")
    local orders=$(tail -10000 /var/log/nginx/access.log | grep -c "/checkout/")
    if [ $visitors -gt 0 ]; then
        local rate=$((orders * 100 / visitors))
        echo "  Conversion Rate: $rate%"
    else
        echo "  Conversion Rate: N/A"
    fi
}

# Function: Get cache performance
get_cache_performance() {
    local hits=$(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"')
    local total=$(tail -1000 /var/log/nginx/access.log | wc -l)
    if [ $total -gt 0 ]; then
        local rate=$((hits * 100 / total))
        echo "  Cache Hit Rate: $rate%"
    else
        echo "  Cache Hit Rate: N/A"
    fi
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              E-COMMERCE MONITORING DASHBOARD                  ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 SALES STATISTICS:"
    get_sales_stats
    echo ""
    get_cart_stats
    echo ""
    get_product_stats
    echo ""
    get_conversion_rate
    echo ""
    get_cache_performance
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for e-commerce platforms. Use these techniques to build scalable, secure, and high-performance online stores.
