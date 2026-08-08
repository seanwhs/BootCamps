# Primer 23: Nginx for Real-Time Personalization

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for real-time personalization, A/B testing, feature flags, and dynamic content delivery. Understanding these concepts is essential for building modern, personalized user experiences.

## P23.1 Personalization Architecture

### Real-Time Personalization Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PERSONALIZATION ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX PERSONALIZATION LAYER                    │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    USER IDENTIFICATION                    │ │      │
│  │  │  • Cookies          • JWT Tokens      • Session IDs      │ │      │
│  │  │  • Device Fingerprint • Geo Location  • User-Agent       │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONTENT SELECTION                      │ │      │
│  │  │  • A/B Testing       • Feature Flags    • Personalization│ │      │
│  │  │  • Geo Targeting     • Device Detection  • Time-based   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    RESPONSE MODIFICATION                  │ │      │
│  │  │  • Content Injection  • Header Modification              │ │      │
│  │  │  • HTML Rewriting     • JSON Transformation              │ │      │
│  │  │  • Dynamic Caching    • Edge Side Includes              │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ User   │  │ Content│  │ Feature│  │ A/B    │  │Analytics│           │
│  │ Profile│  │ Service│  │ Flags  │  │ Engine │  │ Service │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Personalization Configuration

```nginx
# nginx-personalization.conf - Complete Personalization
# ============================================================================
# NGINX REAL-TIME PERSONALIZATION
# Complete production-ready personalization configuration
# ============================================================================

http {
    # =========================================================================
    # USER IDENTIFICATION
    # =========================================================================
    
    # Extract user ID from JWT or cookie
    map $http_authorization $user_id {
        default "";
        "~^Bearer (?<token>.+)$" $token;
    }
    
    # Fallback to cookie
    map $cookie_user_id $user_id_fallback {
        default "";
        "~^(?<id>.+)$" $id;
    }
    
    # Final user ID
    set $user_id $user_id;
    if ($user_id = "") {
        set $user_id $user_id_fallback;
    }
    
    # User segmentation
    map $user_id $user_segment {
        default "guest";
        include /etc/nginx/user-segments.conf;
    }
    
    # Device detection
    map $http_user_agent $device_type {
        default "desktop";
        ~*"(android|iphone|ipad|mobile)" "mobile";
        ~*"(tablet|kindle)" "tablet";
        ~*"(tv|smart-tv|roku|apple-tv)" "tv";
    }
    
    # =========================================================================
    # FEATURE FLAGS
    # =========================================================================
    map $user_segment $features {
        default "";
        "premium" "feature-a,feature-b,feature-c,feature-d";
        "basic" "feature-a,feature-b";
        "guest" "feature-a";
    }
    
    # Feature flag check
    map $features $feature_a_enabled {
        default 0;
        "~*feature-a" 1;
    }
    
    map $features $feature_b_enabled {
        default 0;
        "~*feature-b" 1;
    }
    
    map $features $feature_c_enabled {
        default 0;
        "~*feature-c" 1;
    }
    
    # =========================================================================
    # A/B TESTING
    # =========================================================================
    # A/B test assignment
    split_clients $user_id $ab_test_group {
        25%   "A";
        25%   "B";
        25%   "C";
        25%   "D";
        *     "control";
    }
    
    # A/B test variants
    map $ab_test_group $ab_variant {
        default "control";
        "A" "variant-a";
        "B" "variant-b";
        "C" "variant-c";
        "D" "variant-d";
    }
    
    # =========================================================================
    # CONTENT VARIATIONS
    # =========================================================================
    # Content variation based on segment
    map $user_segment $content_variant {
        default "default";
        "premium" "premium";
        "vip" "vip";
        "enterprise" "enterprise";
    }
    
    # Geo-targeted content
    geoip_country /usr/share/GeoIP/GeoIP.dat;
    
    map $geoip_country_code $geo_variant {
        default "global";
        US "us";
        GB "uk";
        DE "de";
        FR "fr";
        JP "jp";
    }
    
    # Time-based content
    map $time_iso8601 $time_variant {
        default "day";
        "~^.*T(0[6-9]|1[0-7]):" "day";
        "~^.*T(1[8-9]|2[0-3]|0[0-5]):" "night";
    }
    
    # =========================================================================
    # CACHE BY USER SEGMENT
    # =========================================================================
    proxy_cache_path /var/cache/nginx/personalized_cache
        levels=1:2
        keys_zone=personalized_cache:500m
        max_size=10g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # MAIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # User identification headers
        add_header X-User-ID $user_id;
        add_header X-User-Segment $user_segment;
        add_header X-Features $features;
        add_header X-AB-Group $ab_test_group;
        
        # --------------------------------------------------------------------
        # MAIN LOCATION
        # --------------------------------------------------------------------
        location / {
            # Set personalized headers
            proxy_set_header X-User-ID $user_id;
            proxy_set_header X-User-Segment $user_segment;
            proxy_set_header X-Features $features;
            proxy_set_header X-AB-Group $ab_test_group;
            proxy_set_header X-Device-Type $device_type;
            proxy_set_header X-Geo-Country $geoip_country_code;
            proxy_set_header X-Time-Variant $time_variant;
            
            # Cache by user segment
            proxy_cache personalized_cache;
            proxy_cache_key $scheme$host$request_uri$user_segment$device_type$ab_test_group;
            proxy_cache_valid 200 5m;
            proxy_cache_use_stale error timeout updating;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # API WITH FEATURE FLAGS
        # --------------------------------------------------------------------
        location /api/ {
            # Feature flags as headers
            proxy_set_header X-Feature-A $feature_a_enabled;
            proxy_set_header X-Feature-B $feature_b_enabled;
            proxy_set_header X-Feature-C $feature_c_enabled;
            
            # A/B test variant
            proxy_set_header X-AB-Variant $ab_variant;
            
            # Device type
            proxy_set_header X-Device-Type $device_type;
            
            proxy_pass http://backend/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            proxy_set_header X-User-Segment $user_segment;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # --------------------------------------------------------------------
        # PERSONALIZED CONTENT
        # --------------------------------------------------------------------
        location /content/ {
            # Content variation based on segment
            proxy_pass http://backend/content/$content_variant/;
            
            # Geo-targeted content
            if ($geo_variant != "global") {
                proxy_pass http://backend/content/$geo_variant/;
            }
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            proxy_set_header X-User-Segment $user_segment;
        }
        
        # --------------------------------------------------------------------
        # A/B TEST TRACKING
        # --------------------------------------------------------------------
        location /ab/track {
            # Log A/B test exposure
            access_log /var/log/nginx/ab-test.log;
            add_header X-AB-Group $ab_test_group;
            add_header X-AB-Variant $ab_variant;
            
            # Return pixel
            return 204;
        }
        
        # --------------------------------------------------------------------
        # PERSONALIZATION DASHBOARD
        # --------------------------------------------------------------------
        location /personalization-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "user_id":"$user_id",
                "segment":"$user_segment",
                "features":"$features",
                "ab_group":"$ab_test_group",
                "ab_variant":"$ab_variant",
                "device":"$device_type",
                "geo":"$geoip_country_code",
                "time_variant":"$time_variant",
                "content_variant":"$content_variant",
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # --------------------------------------------------------------------
        # HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P23.2 Edge Side Includes (ESI)

### ESI Implementation

```nginx
# nginx-esi.conf - Edge Side Includes
# ============================================================================
# NGINX EDGE SIDE INCLUDES
# Dynamic content assembly at the edge
# ============================================================================

http {
    # =========================================================================
    # ESI CACHE
    # =========================================================================
    proxy_cache_path /var/cache/nginx/esi_cache
        levels=1:2
        keys_zone=esi_cache:200m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # FRAGMENT SERVICES
    # =========================================================================
    upstream user_profile {
        server profile:8001;
        keepalive 32;
    }
    
    upstream cart_service {
        server cart:8002;
        keepalive 32;
    }
    
    upstream recommendations {
        server recs:8003;
        keepalive 32;
    }
    
    upstream notifications {
        server notifications:8004;
        keepalive 32;
    }
    
    # =========================================================================
    # ESI SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # --------------------------------------------------------------------
        # MAIN PAGE WITH ESI
        # --------------------------------------------------------------------
        location /dashboard {
            # Get main layout
            proxy_pass http://backend/dashboard;
            
            # Enable ESI processing
            esi on;
            esi_types text/html text/plain;
            
            # Set up ESI variables
            set $user_id $cookie_user_id;
            set $session_id $cookie_session_id;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            
            # Cache the main layout
            proxy_cache esi_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 5m;
        }
        
        # --------------------------------------------------------------------
        # ESI FRAGMENTS
        # --------------------------------------------------------------------
        # User profile fragment
        location /esi/profile {
            internal;
            
            proxy_pass http://user_profile/profile;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            
            # Short cache for profile
            proxy_cache esi_cache;
            proxy_cache_key $scheme$host$request_uri$user_id;
            proxy_cache_valid 200 30s;
        }
        
        # Cart fragment
        location /esi/cart {
            internal;
            
            proxy_pass http://cart_service/cart;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            proxy_set_header X-Session-ID $session_id;
            
            # No cache for cart
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # Recommendations fragment
        location /esi/recommendations {
            internal;
            
            proxy_pass http://recommendations/recommendations;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            
            # Cache recommendations
            proxy_cache esi_cache;
            proxy_cache_key $scheme$host$request_uri$user_id;
            proxy_cache_valid 200 5m;
        }
        
        # Notifications fragment
        location /esi/notifications {
            internal;
            
            proxy_pass http://notifications/notifications;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            
            # Short cache for notifications
            proxy_cache esi_cache;
            proxy_cache_key $scheme$host$request_uri$user_id;
            proxy_cache_valid 200 30s;
        }
    }
}
```

## P23.3 Dynamic Content Injection

### Content Injection with SSI

```nginx
# nginx-ssi.conf - Server Side Includes
# ============================================================================
# NGINX SERVER SIDE INCLUDES
# Dynamic content injection
# ============================================================================

http {
    # =========================================================================
    # SSI SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        
        # Enable SSI
        ssi on;
        ssi_types text/html text/plain;
        ssi_value_length 1024;
        
        # --------------------------------------------------------------------
        # PERSONALIZED PAGE
        # --------------------------------------------------------------------
        location /page {
            # Set variables for SSI
            set $user_name $cookie_user_name;
            set $user_email $cookie_user_email;
            set $user_segment $cookie_user_segment;
            
            # Inject user-specific content
            proxy_pass http://backend/page;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $user_id;
            
            # Process SSI in response
            ssi on;
            
            # Custom SSI variables
            set $greeting "Welcome back";
            if ($time_iso8601 ~* "T(0[6-9]|1[0-7]):") {
                set $greeting "Good morning";
            }
        }
        
        # --------------------------------------------------------------------
        # SSI TEMPLATES
        # --------------------------------------------------------------------
        location /templates/ {
            alias /var/www/templates/;
            
            # Enable SSI in templates
            ssi on;
            
            # Template variables
            set $header_template "header.html";
            set $footer_template "footer.html";
            
            # Dynamic template selection
            if ($user_segment = "premium") {
                set $header_template "header-premium.html";
            }
        }
    }
}
```

## P23.4 Analytics & Optimization

### Personalization Analytics

```bash
#!/bin/bash
# personalization-analytics.sh - Personalization analytics

echo "=== Personalization Analytics ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function: Get user segment distribution
get_segment_distribution() {
    echo "User Segments:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-User-Segment":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count segment; do
            echo "  $segment: $count"
        done
}

# Function: Get A/B test results
get_ab_results() {
    echo "A/B Test Groups:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-AB-Group":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count group; do
            echo "  $group: $count"
        done
}

# Function: Get device distribution
get_device_distribution() {
    echo "Device Types:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Device-Type":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count device; do
            echo "  $device: $count"
        done
}

# Function: Get feature usage
get_feature_usage() {
    echo "Feature Usage:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Features":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count features; do
            echo "  $features: $count"
        done
}

# Function: Get geo distribution
get_geo_distribution() {
    echo "Geo Distribution:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Geo-Country":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -10 | \
        while read count country; do
            echo "  $country: $count"
        done
}

# Main display
echo "📊 PERSONALIZATION ANALYTICS"
echo ""
get_segment_distribution
echo ""
get_ab_results
echo ""
get_device_distribution
echo ""
get_feature_usage
echo ""
get_geo_distribution
```

---

This primer provides a comprehensive deep dive into using Nginx for real-time personalization, A/B testing, feature flags, and dynamic content delivery. Use these techniques to build modern, personalized user experiences.
